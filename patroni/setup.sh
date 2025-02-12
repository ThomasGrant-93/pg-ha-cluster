#!/bin/bash

set -e

echo "Creating additional users in PostgreSQL..."

psql "${PATRONI_SUPERUSER_URL}" <<-EOSQL
    CREATE ROLE pgbouncer WITH LOGIN SUPERUSER ENCRYPTED PASSWORD 'pgbouncer';
    CREATE ROLE edw_airflow_user WITH LOGIN ENCRYPTED PASSWORD 'edw_airflow_user';
    CREATE ROLE edw_admin_user WITH LOGIN SUPERUSER CREATEDB CREATEROLE REPLICATION BYPASSRLS ENCRYPTED PASSWORD 'edw_admin_user';
    CREATE ROLE barman WITH LOGIN SUPERUSER CREATEDB CREATEROLE REPLICATION ENCRYPTED PASSWORD 'barman';
    CREATE ROLE edw_dbt_user WITH LOGIN ENCRYPTED PASSWORD 'edw_dbt_user';
    CREATE ROLE edw_superset_user WITH LOGIN ENCRYPTED PASSWORD 'edw_superset_user';
    CREATE ROLE edw_airbyte_user WITH LOGIN ENCRYPTED PASSWORD 'edw_airbyte_user';
EOSQL

echo "Users created successfully."

echo "Change permissions for /var/lib/postgresql/data/pg_wal recursive"

chmod 0750 /var/lib/postgresql/data
chmod 0750 /var/lib/postgresql/data/pg_wal
