-- Grant connect on database
grant all privileges on database picasso_dwh_storage to edw_airbyte_user;

-- Create destination schema and make edw_airbyte_user the owner if needed
create schema if not exists dw_raw;
alter schema dw_raw owner to edw_airbyte_user;

-- Grant read permissions on the dw_raw schema
grant usage on schema dw_raw to edw_airbyte_user;
grant select on all tables in schema dw_raw to edw_airbyte_user;
alter default privileges in schema dw_raw grant select on tables to edw_airbyte_user;

-- Grant write permissions on the dw_raw schema
grant usage on schema dw_raw to edw_airbyte_user;
grant create on schema dw_raw to edw_airbyte_user;
grant insert, update, delete, truncate on all tables in schema dw_raw to edw_airbyte_user;
alter default privileges in schema dw_raw grant insert, update, delete, truncate on tables to edw_airbyte_user;

-- Create destination schema and make edw_airbyte_user the owner if needed
create schema if not exists airbyte;
alter schema airbyte owner to edw_airbyte_user;

-- Grant read permissions on the airbyte schema
grant usage on schema airbyte to edw_airbyte_user;
grant select on all tables in schema airbyte to edw_airbyte_user;
alter default privileges in schema airbyte grant select on tables to edw_airbyte_user;

-- Grant write permissions on the airbyte schema
grant usage on schema airbyte to edw_airbyte_user;
grant create on schema airbyte to edw_airbyte_user;
grant insert, update, delete, truncate on all tables in schema airbyte to edw_airbyte_user;
alter default privileges in schema airbyte grant insert, update, delete, truncate on tables to edw_airbyte_user;
