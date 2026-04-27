-- Run as postgres superuser against database: brainforge

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'bf_developer') THEN
        CREATE ROLE bf_developer LOGIN PASSWORD 'bf_developer';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'bf_airbyte') THEN
        CREATE ROLE bf_airbyte LOGIN PASSWORD 'bf_airbyte';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'bf_dbt') THEN
        CREATE ROLE bf_dbt LOGIN PASSWORD 'bf_dbt';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'bf_bi') THEN
        CREATE ROLE bf_bi LOGIN PASSWORD 'bf_bi';
    END IF;
END
$$;

-- Database access
GRANT CONNECT ON DATABASE brainforge TO bf_developer, bf_airbyte, bf_dbt, bf_bi;
GRANT CREATE, TEMP ON DATABASE brainforge TO bf_dbt, bf_developer;

-- Lock down public a bit
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- =========================================================
-- RAW SCHEMA
-- airbyte = write
-- dbt = read only
-- developer = read only
-- bi = no access
-- =========================================================
GRANT USAGE ON SCHEMA raw TO bf_airbyte, bf_dbt, bf_developer;
GRANT CREATE ON SCHEMA raw TO bf_airbyte;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA raw TO bf_airbyte;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA raw TO bf_airbyte;

GRANT SELECT ON ALL TABLES IN SCHEMA raw TO bf_dbt, bf_developer;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA raw TO bf_dbt, bf_developer;

ALTER DEFAULT PRIVILEGES FOR ROLE bf_airbyte IN SCHEMA raw
GRANT SELECT ON TABLES TO bf_dbt, bf_developer;

ALTER DEFAULT PRIVILEGES FOR ROLE bf_airbyte IN SCHEMA raw
GRANT USAGE, SELECT ON SEQUENCES TO bf_dbt, bf_developer;

-- =========================================================
-- ANALYTICS_STAGING SCHEMA
-- dbt = read/write/create
-- developer = read/write/create
-- airbyte = no access
-- bi = no access
-- =========================================================
GRANT USAGE ON SCHEMA analytics_staging TO bf_dbt, bf_developer;
GRANT CREATE ON SCHEMA analytics_staging TO bf_dbt, bf_developer;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA analytics_staging TO bf_dbt, bf_developer;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA analytics_staging TO bf_dbt, bf_developer;

ALTER DEFAULT PRIVILEGES FOR ROLE bf_dbt IN SCHEMA analytics_staging
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO bf_developer;

ALTER DEFAULT PRIVILEGES FOR ROLE bf_dbt IN SCHEMA analytics_staging
GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO bf_developer;

-- =========================================================
-- ANALYTICS SCHEMA
-- dbt = read/write/create
-- developer = read only
-- bi = read only
-- airbyte = no access
-- =========================================================
GRANT USAGE ON SCHEMA analytics TO bf_dbt, bf_developer, bf_bi;
GRANT CREATE ON SCHEMA analytics TO bf_dbt;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA analytics TO bf_dbt;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA analytics TO bf_dbt;

GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO bf_developer, bf_bi;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA analytics TO bf_developer, bf_bi;

ALTER DEFAULT PRIVILEGES FOR ROLE bf_dbt IN SCHEMA analytics
GRANT SELECT ON TABLES TO bf_developer, bf_bi;

ALTER DEFAULT PRIVILEGES FOR ROLE bf_dbt IN SCHEMA analytics
GRANT USAGE, SELECT ON SEQUENCES TO bf_developer, bf_bi;