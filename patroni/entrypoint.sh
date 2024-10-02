#!/bin/bash

set -e

echo "PostgreSQL wait for Patroni to start..."

POSTGRES_DB=${POSTGRES_DB:-picasso_dwh_storage}
POSTGRES_USER=${POSTGRES_USER:-edw_admin_user}

if [ ! -d "/var/lib/postgresql/data" ]; then
    echo "Initializing PostgreSQL data directory..."

    mkdir -p /var/lib/postgresql/data
    chmod 0700 /var/lib/postgresql/data
    chown postgres:postgres /var/lib/postgresql/data

    gosu postgres initdb -D /var/lib/postgresql/data

    echo "Creating initial database and granting privileges..."

    exec psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
        CREATE DATABASE "${POSTGRES_DB}";
        GRANT ALL PRIVILEGES ON DATABASE "${POSTGRES_DB}" TO "${POSTGRES_USER}";
EOSQL

else
    echo "Data directory already exists, skipping initialization."
    chmod 0700 /var/lib/postgresql/data
fi

exec gosu postgres /venv/bin/patroni /venv/etc/patroni.yml
