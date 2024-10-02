grant all privileges on database picasso_dwh_storage to edw_dbt_user;

-- Create destination schema and make edw_dbt_user the owner
create schema if not exists dw_stg;
alter schema dw_stg owner to edw_dbt_user;

create schema if not exists dw_raw;
alter schema dw_raw owner to edw_airbyte_user;

create schema if not exists dw_fact;
alter schema dw_fact owner to edw_dbt_user;

create schema if not exists dw_dim;
alter schema dw_dim owner to edw_dbt_user;

-- Grant read permissions on the source schema
grant usage on schema dw_stg to edw_dbt_user;
grant select on all tables in schema dw_stg to edw_dbt_user;
alter default privileges in schema dw_stg grant select on tables to edw_dbt_user;

grant usage on schema dw_raw to edw_dbt_user;
grant select on all tables in schema dw_raw to edw_dbt_user;
alter default privileges in schema dw_raw grant select on tables to edw_dbt_user;

grant usage on schema dw_fact to edw_dbt_user;
grant select on all tables in schema dw_fact to edw_dbt_user;
alter default privileges in schema dw_fact grant select on tables to edw_dbt_user;

grant usage on schema dw_dim to edw_dbt_user;
grant select on all tables in schema dw_dim to edw_dbt_user;
alter default privileges in schema dw_dim grant select on tables to edw_dbt_user;

-- Grant write permissions on the destination schema
grant usage on schema dw_stg to edw_dbt_user;
grant create on schema dw_stg to edw_dbt_user;
grant insert, update, delete, truncate on all tables in schema dw_stg to edw_dbt_user;
alter default privileges in schema dw_stg grant insert, update, delete, truncate on tables to edw_dbt_user;

grant usage on schema dw_fact to edw_dbt_user;
grant create on schema dw_fact to edw_dbt_user;
grant insert, update, delete, truncate on all tables in schema dw_fact to edw_dbt_user;
alter default privileges in schema dw_fact grant insert, update, delete, truncate on tables to edw_dbt_user;

grant usage on schema dw_dim to edw_dbt_user;
grant create on schema dw_dim to edw_dbt_user;
grant insert, update, delete, truncate on all tables in schema dw_dim to edw_dbt_user;
alter default privileges in schema dw_dim grant insert, update, delete, truncate on tables to edw_dbt_user;
