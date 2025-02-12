FROM postgres:15

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv \
    barman-cli barman-cli-cloud \
    net-tools nano ssh curl build-essential libpq-dev \
    pgbouncer && \
    rm -rf /var/lib/apt/lists/*


WORKDIR /venv

RUN python3 -m venv /venv && /venv/bin/pip install --no-cache-dir \
    psycopg==3.2.4 \
    patroni[etcd3,psycopg3,aws,barman]~=4.0.4 && \
    mkdir -p /etc/patroni /etc/pgbouncer /etc/barman.d /var/log

COPY ./patroni/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ./patroni/create_users.sh /usr/local/bin/create_users.sh
COPY ./patroni/patroni.yml /etc/patroni/patroni.yml

COPY ./pgbouncer/pgbouncer.ini /etc/pgbouncer/pgbouncer.ini
COPY ./pgbouncer/userlist.txt /etc/pgbouncer/userlist.txt

# SSH Keys
COPY --chown=postgres:postgres ./ssh-keys/id_rsa_postgres  /var/lib/postgresql/.ssh/id_rsa
COPY --chown=postgres:postgres ./ssh-keys/id_rsa_postgres.pub  /var/lib/postgresql/.ssh/id_rsa.pub
COPY --chown=postgres:postgres ./ssh-keys/id_rsa_postgres.pub /var/lib/postgresql/.ssh/authorized_keys

COPY ./ssh-keys/server-keys /etc

RUN mkdir -p /var/lib/postgresql/.ssh && \
    chmod 0700  /var/lib/postgresql && \
    chmod 0700  /var/lib/postgresql/.ssh && \
    chmod 0600  /var/lib/postgresql/.ssh/id_rsa && \
    chmod 0600  /var/lib/postgresql/.ssh/id_rsa.pub && \
    chmod 0600  /var/lib/postgresql/.ssh/authorized_keys && \
    chown -R postgres:postgres  /var/lib/postgresql

RUN mkdir -p /run/sshd /etc/sudoers.d && \
    echo 'Port 22' >> /etc/ssh/sshd_config && \
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config && \
    echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'StrictModes no' >> /etc/ssh/sshd_config && \
    echo 'Host *\n    StrictHostKeyChecking no' >> /var/lib/postgresql/.ssh/config && \
    chmod 0600 /var/lib/postgresql/.ssh/config

# Sudoers Configuration
RUN echo 'postgres ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/postgres

# Logs
RUN mkdir -p /var/log/patroni && \
    chmod 0755 /var/log/patroni && \
    chown postgres:postgres /var/log/patroni

RUN touch /var/log/pgbouncer.log && \
    chmod 0644 /var/log/pgbouncer.log && \
    chown postgres:postgres /var/log/pgbouncer.log

# TODO Remove hardcode permissions
RUN chmod 0750 /var/lib/postgresql /var/lib/postgresql/data

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/setup.sh

RUN chown -R postgres:postgres /var/lib/postgresql /venv /usr/local/bin/entrypoint.sh /etc/pgbouncer

EXPOSE 5432 8008 6432 22

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
