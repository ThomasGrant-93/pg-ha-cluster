create role edw_airflow_user with login encrypted password 'edw_airflow_user';
create role pgbouncer with login superuser encrypted password 'pgbouncer';
create role edw_dbt_user with login encrypted password 'edw_dbt_user';
create role edw_superset_user with login encrypted password 'edw_superset_user';
create role edw_airbyte_user with login encrypted password 'edw_airbyte_user';
create role edw_repl_user with login replication encrypted password 'edw_repl_user';
