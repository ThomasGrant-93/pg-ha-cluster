FROM python:3.11-slim-bullseye AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    libpq-dev \
    libssl-dev

RUN useradd -m -s /bin/bash barman

WORKDIR /home/barman/app

RUN git clone https://github.com/EnterpriseDB/pg-backup-api.git \
    && cd pg-backup-api/pg_backup_api \
    && git fetch --tags \
    && LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`) \
    && git checkout $LATEST_TAG \
    && python -m venv /home/barman/app/venv \
    && /home/barman/app/venv/bin/pip install --upgrade pip \
    && /home/barman/app/venv/bin/pip install . \
    && /home/barman/app/venv/bin/pip install gunicorn boto3

RUN chown -R barman:barman /home/barman/app

FROM python:3.11-slim-bullseye

RUN apt-get update && \
    apt-get install -y curl gnupg2 lsb-release && \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    postgresql-client-15 \
    rsync \
    barman \
    barman-cli \
    barman-cli-cloud \
    net-tools \
    nano \
    ssh && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/barman/certs /home/barman/app

COPY --chown=barman:barman ./barman/barman.conf /etc/barman.conf
COPY --chown=barman:barman ./barman/barman.d /etc/barman.d
COPY --chown=barman:barman ./barman/entrypoint.sh /home/barman/app/entrypoint.sh

# SSH Keys
COPY --chown=barman:barman ./ssh-keys/id_rsa_postgres  /var/lib/barman/.ssh/id_rsa
COPY --chown=barman:barman ./ssh-keys/id_rsa_postgres.pub  /var/lib/barman/.ssh/id_rsa.pub
COPY --chown=barman:barman ./ssh-keys/id_rsa_postgres.pub /var/lib/barman/.ssh/authorized_keys

COPY --chown=barman:barman ./ssh-keys/server-keys /etc

RUN mkdir -p /var/lib/barman/.ssh && \
    chmod 0755  /var/lib/barman && \
    chmod 0700  /var/lib/barman/.ssh && \
    chmod 0600  /var/lib/barman/.ssh/id_rsa && \
    chmod 0600  /var/lib/barman/.ssh/id_rsa.pub && \
    chmod 0600  /var/lib/barman/.ssh/authorized_keys && \
    chown -R barman:barman  /var/lib/barman


RUN mkdir -p /run/sshd /etc/sudoers.d && \
    echo 'Port 22' >> /etc/ssh/sshd_config && \
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config && \
    echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'StrictModes no' >> /etc/ssh/sshd_config && \
    echo 'Host *\n    StrictHostKeyChecking no' >> /var/lib/barman/.ssh/config && \
    chmod 0600 /var/lib/barman/.ssh/config

COPY ./ssl-keys/server.crt /home/barman/certs/server.crt
COPY ./ssl-keys/server.key /home/barman/certs/server.key

COPY ./barman/pg-backup-api-config.py /etc/pg-backup-api-config.py

RUN chown barman:barman /home/barman/certs/server.crt /home/barman/certs/server.key && \
    chmod 600 /home/barman/certs/server.key

# Sudoers Configuration
RUN echo 'barman ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/barman && \
    echo 'postgres ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/postgres

RUN mkdir -p /var/log/barman && \
    touch /var/log/barman/barman.log && \
    chmod 755 /var/log/barman && \
    chmod 644 /var/log/barman/barman.log && \
    chown -R barman:barman /var/log/barman

RUN chmod +x /home/barman/app/entrypoint.sh

USER barman

WORKDIR /home/barman/app

COPY --from=builder --chown=barman:barman /home/barman/app /home/barman/app

ENV PATH="/home/barman/app/venv/bin:/usr/lib/postgresql/15/bin:/usr/bin:$PATH"

EXPOSE 7480 22 443

ENTRYPOINT ["/home/barman/app/entrypoint.sh"]
