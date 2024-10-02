FROM postgres:15

RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    libpq-dev
RUN python3 -m venv /venv && mkdir /venv/etc

WORKDIR /venv
RUN ./bin/pip install \
    psycopg2==2.9.9 \
    patroni[etcd3,psycopg2]

WORKDIR /var/lib/postgresql
COPY ./patroni/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
EXPOSE 5432 8008
