CREATE DATABASE my_database;
CREATE SCHEMA my_schema;
CREATE ROLE my_user WITH LOGIN PASSWORD 'secure_password' ENCRYPTED;
ALTER ROLE my_user SET search_path TO my_schema;
GRANT ALL PRIVILEGES ON DATABASE my_database TO my_user;
GRANT ALL ON SCHEMA my_schema TO my_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA my_schema GRANT ALL ON TABLES TO my_user;
REVOKE ALL ON SCHEMA public FROM my_user;
