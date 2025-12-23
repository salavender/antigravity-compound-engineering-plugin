-- Migration: {Brief description of what this migration does}
-- Date: {YYYY-MM-DD}
-- Purpose: {Detailed explanation of why this migration is needed}
-- Requirements: {Requirement IDs if applicable, e.g., "4.1, 4.2"}
-- Feature: {feature-name if part of a larger feature}

-- ============================================================================
-- TODO: Replace placeholders with actual migration code
-- ============================================================================

-- Example: Create ENUM type (use DO block for idempotency)
DO $$ BEGIN
    CREATE TYPE {type_name} AS ENUM ('{value1}', '{value2}');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Example: Create table
CREATE TABLE IF NOT EXISTS {schema}.{table_name} (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    {column_name} {data_type} {constraints},
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Example: Create indexes
CREATE INDEX IF NOT EXISTS idx_{table}_{column} 
ON {schema}.{table} ({column});

-- Example: Create updated_at trigger
DROP TRIGGER IF EXISTS update_{table}_updated_at ON {schema}.{table};
CREATE TRIGGER update_{table}_updated_at
    BEFORE UPDATE ON {schema}.{table}
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Example: Enable Row Level Security
ALTER TABLE {schema}.{table} ENABLE ROW LEVEL SECURITY;

-- Example: Create RLS policy
CREATE POLICY "{policy description}"
ON {schema}.{table}
FOR {operation}
TO authenticated
USING ({condition});

-- Example: Add documentation
COMMENT ON TABLE {schema}.{table} IS '{table description}';
COMMENT ON COLUMN {schema}.{table}.{column} IS '{column description}';
