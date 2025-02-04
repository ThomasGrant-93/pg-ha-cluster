FROM postgres:15

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    libpq-dev \
    pgbouncer && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /venv
RUN python3 -m venv . && mkdir -p /etc/patroni /var/log

RUN ./bin/pip install --no-cache-dir \
    psycopg==3.2.4 \
    patroni[etcd3,psycopg3,aws]

COPY ./patroni/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ./patroni/create_users.sh /usr/local/bin/create_users.sh
COPY ./patroni/patroni.yml /etc/patroni/patroni.yml
COPY ./pgbouncer/pgbouncer.ini /etc/pgbouncer/pgbouncer.ini
COPY ./pgbouncer/userlist.txt /etc/pgbouncer/userlist.txt

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/create_users.sh && \
    touch /var/log/pgbouncer.log && \
    chown postgres:postgres /var/log/pgbouncer.log && \
    chmod 644 /var/log/pgbouncer.log && \
    chown -R postgres:postgres /var/lib/postgresql /venv /usr/local/bin/entrypoint.sh /etc/pgbouncer

EXPOSE 5432 8008 6432

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
