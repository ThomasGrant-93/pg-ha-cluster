-- Grant connect on database
grant connect on database picasso_dwh_storage to edw_superset_user;

-- Grant read permissions on the dw_fact schema
grant usage on schema dw_fact to edw_superset_user;
grant select on all tables in schema dw_fact to edw_superset_user;
alter default privileges in schema dw_fact grant select on tables to edw_superset_user;

-- Grant read permissions on the dw_dim schema
grant usage on schema dw_dim to edw_superset_user;
grant select on all tables in schema dw_dim to edw_superset_user;
alter default privileges in schema dw_dim grant select on tables to edw_superset_user;
