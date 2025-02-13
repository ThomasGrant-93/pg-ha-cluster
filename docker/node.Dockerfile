FROM postgres:15

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev libpython3-dev \
    python3 python3-distutils python3-pip python3-venv \
    patroni \
    barman-cli barman-cli-cloud \
    net-tools nano ssh curl build-essential libpq-dev \
    pgbouncer && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir psycopg~=3.2.4

ENV PATH="/opt/venv/bin:$PATH"

RUN mkdir -p /etc/patroni /etc/pgbouncer /etc/barman.d /var/log

# Configs
COPY patroni/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY patroni/setup.sh /usr/local/bin/setup.sh
COPY patroni/patroni.yml /etc/patroni/patroni.yml
COPY pgbouncer/pgbouncer.ini /etc/pgbouncer/pgbouncer.ini
COPY pgbouncer/userlist.txt /etc/pgbouncer/userlist.txt

# SSH Keys
COPY --chown=postgres:postgres --chmod=0600 ssh-keys/id_rsa ssh-keys/id_rsa.pub /var/lib/postgresql/.ssh/
COPY --chown=postgres:postgres --chmod=0600 ssh-keys/id_rsa.pub /var/lib/postgresql/.ssh/authorized_keys
COPY ssh-keys/server-keys /etc

RUN mkdir -p /run/sshd && \
    echo 'Port 22\nPermitRootLogin no\nPasswordAuthentication no\nPubkeyAuthentication yes\nStrictModes no' > /etc/ssh/sshd_config && \
    echo 'Host *\n\tStrictHostKeyChecking no' > /var/lib/postgresql/.ssh/config && \
    chmod 0600 /var/lib/postgresql/.ssh/config

RUN mkdir -p /var/lib/postgresql/.ssh && \
    chmod 0750 /var/lib/postgresql && \
    chmod 0700 /var/lib/postgresql/.ssh && \
    chown -R postgres:postgres  /var/lib/postgresql

# Logs
RUN mkdir -p /var/log/patroni && \
    chmod 0755 /var/log/patroni && \
    chown postgres:postgres /var/log/patroni

RUN touch /var/log/pgbouncer.log && \
    chmod 0644 /var/log/pgbouncer.log && \
    chown postgres:postgres /var/log/pgbouncer.log

RUN chmod 0750 /var/lib/postgresql/data

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/setup.sh

RUN chown -R postgres:postgres /var/lib/postgresql /usr/local/bin/entrypoint.sh /etc/pgbouncer

EXPOSE 5432 8008 6432 22

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
