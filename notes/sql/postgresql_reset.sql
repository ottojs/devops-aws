-- ============================================================
-- PostgreSQL Database and User Reset Script
-- ============================================================
-- Purpose: Completely reset a database and user with full privileges
-- WARNING: This script will DELETE the existing database and all its data
-- Use in: Development/testing environments only
-- ============================================================

-- Clean slate: Remove existing database and user if they exist
-- This ensures no conflicts with previous installations
DROP DATABASE IF EXISTS appdb;
DROP USER IF EXISTS appuser;

-- Create fresh database and user
CREATE DATABASE appdb;
-- SECURITY NOTE: Replace 'app-password' with a secure password in production
CREATE USER appuser WITH PASSWORD 'app-password';

-- Grant basic connection rights to the database
GRANT CONNECT ON DATABASE appdb TO appuser;
-- Grant all database-level privileges (create schemas, etc.)
GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;

-- Switch connection to the newly created database
-- Required to grant schema-level privileges
\c appdb

-- Grant all privileges on the public schema itself
-- This allows appuser to create objects in the public schema
GRANT ALL PRIVILEGES ON SCHEMA public TO appuser;

-- Grant privileges on all existing objects in the public schema
-- These apply to tables/sequences that already exist
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO appuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO appuser;

-- Set default privileges for future objects created by the current role
-- This ensures appuser automatically gets privileges on new tables/sequences
-- created by the role executing this script
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO appuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO appuser;

-- Explicitly grant CREATE privilege to allow appuser to create objects
GRANT CREATE ON SCHEMA public TO appuser;

-- Set default privileges for objects created by customadmin role
-- This ensures appuser gets privileges on tables/sequences that
-- the customadmin role creates in the future
ALTER DEFAULT PRIVILEGES FOR ROLE customadmin IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO appuser;
ALTER DEFAULT PRIVILEGES FOR ROLE customadmin IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO appuser;
