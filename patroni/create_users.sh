#!/bin/bash

set -e

echo "Creating additional users in PostgreSQL..."

psql "${PATRONI_SUPERUSER_URL}" <<-EOSQL
    CREATE ROLE pgbouncer WITH LOGIN SUPERUSER ENCRYPTED PASSWORD 'pgbouncer';
    CREATE ROLE edw_airflow_user WITH LOGIN ENCRYPTED PASSWORD 'edw_airflow_user';
    CREATE ROLE edw_dbt_user WITH LOGIN ENCRYPTED PASSWORD 'edw_dbt_user';
    CREATE ROLE edw_superset_user WITH LOGIN ENCRYPTED PASSWORD 'edw_superset_user';
    CREATE ROLE edw_airbyte_user WITH LOGIN ENCRYPTED PASSWORD 'edw_airbyte_user';
EOSQL

echo "Users created successfully."
