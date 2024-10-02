-- Grant connect on database
grant connect on database picasso_dwh_storage to edw_airflow_user;

-- Create destination schema and make edw_airflow_user the owner if needed
create schema if not exists dw_raw;
alter schema dw_raw owner to edw_airflow_user;

-- Grant read permissions on the dw_raw schema
grant usage on schema dw_raw to edw_airflow_user;
grant select on all tables in schema dw_raw to edw_airflow_user;
alter default privileges in schema dw_raw grant select on tables to edw_airflow_user;

-- Grant write permissions on the dw_raw schema
grant usage on schema dw_raw to edw_airflow_user;
grant create on schema dw_raw to edw_airflow_user;
grant insert, update, delete, truncate on all tables in schema dw_raw to edw_airflow_user;
alter default privileges in schema dw_raw grant insert, update, delete, truncate on tables to edw_airflow_user;
