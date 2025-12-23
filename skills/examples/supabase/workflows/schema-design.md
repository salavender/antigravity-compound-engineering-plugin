# Database Schema Design

Best practices for designing Supabase database schemas in [PROJECT_NAME].

## When To Use

- Designing new features with database requirements
- Planning data model for new functionality
- Refactoring existing schema
- Reviewing schema design decisions

---

## Design Principles

### 1. Normalize Data (Usually)

**Good schema:**
```sql
-- Separate tables with clear relationships
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email TEXT UNIQUE NOT NULL
);

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES users(id),
    investor_code TEXT UNIQUE,
    role app_role NOT NULL
);
```

**Avoid:**
```sql
-- Denormalized with repeated data
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email TEXT,
    profile_investor_code TEXT,
    profile_role TEXT,
    profile_mfa_enabled BOOLEAN,
    -- ... many profile fields
);
```

**When to denormalize:**
- Read-heavy tables with expensive joins
- Reporting tables (create views)
- Calculated fields updated via triggers

---

### 2. Use Foreign Keys

**Always include:**
```sql
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fund_id UUID NOT NULL REFERENCES funds(id) ON DELETE CASCADE,
    investor_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
```

**ON DELETE actions:**
- `CASCADE`: Delete children when parent deleted (ownership)
- `RESTRICT`: Prevent deletion if children exist (safeguard)
- `SET NULL`: Orphan children (rarely used)

---

### 3. Add Timestamps

**Standard pattern:**
```sql
CREATE TABLE table_name (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- ... other columns
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Trigger for updated_at
CREATE TRIGGER update_table_updated_at
    BEFORE UPDATE ON table_name
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();
```

---

### 4. Use Appropriate Types

**Common types:**

| Use Case | Type | Example |
|----------|------|---------|
| UUID | `UUID` | User IDs, primary keys |
| Money | `NUMERIC(12,2)` | Prices, amounts |
| Enum | `CREATE TYPE` | Status, role |
| Timestamp | `TIMESTAMPTZ` | Dates with timezone |
| Boolean | `BOOLEAN` | Flags |
| IP Address | `INET` | Login IPs |
| JSON | `JSONB` | Flexible data |

**Avoid:**
- `TEXT` for numbers (use `NUMERIC`)
- `VARCHAR(N)` (use `TEXT` with CHECK constraint if needed)
- `TIMESTAMP` without TZ (use `TIMESTAMPTZ`)
- Raw strings for enums (create `TYPE`)

---

### 5. Create Indexes

**Index these:**
- Foreign keys
- Columns in WHERE clauses
- Columns in JOIN conditions
- Columns in ORDER BY
- Unique constraints

**Example:**
```sql
-- Foreign key index
CREATE INDEX IF NOT EXISTS idx_transactions_fund_id 
ON transactions (fund_id);

-- Composite index for common query
CREATE INDEX IF NOT EXISTS idx_transactions_fund_date 
ON transactions (fund_id, created_at DESC);

-- Unique constraint
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_investor_code 
ON profiles (investor_code) WHERE investor_code IS NOT NULL;
```

---

### 6. Enable RLS by Default

**On all tables with sensitive data:**
```sql
CREATE TABLE sensitive_table (...);

-- Immediately enable RLS
ALTER TABLE sensitive_table ENABLE ROW LEVEL SECURITY;

-- Add appropriate policies
CREATE POLICY "Users see own data"
ON sensitive_table FOR SELECT TO authenticated
USING (user_id = auth.uid());
```

**See:** `workflows/rls-policies.md` for policy patterns

---

### 7. Add Documentation

**Document schema decisions:**
```sql
COMMENT ON TABLE transactions IS 
'Financial transactions between investors and funds. All amounts in USD.';

COMMENT ON COLUMN transactions.amount IS 
'Transaction amount in USD. Positive for investments, negative for redemptions.';

COMMENT ON COLUMN transactions.status IS 
'Status: pending (awaiting approval), approved (processed), rejected (denied)';
```

---

## Schema Review Checklist

Before creating migration:

**Tables:**
- [ ] Table name plural and lowercase? (`users`, not `User`)
- [ ] Primary key UUID with `gen_random_uuid()`?
- [ ] Foreign keys with appropriate ON DELETE?
- [ ] `created_at` and `updated_at` timestamps?
- [ ] RLS enabled on sensitive tables?

**Columns:**
- [ ] Appropriate data types?
- [ ] NOT NULL where required?
- [ ] DEFAULT values where sensible?
- [ ] Unique constraints where needed?

**Performance:**
- [ ] Indexes on foreign keys?
- [ ] Indexes on frequently queried columns?
- [ ] Composite indexes for multi-column queries?

**Security:**
- [ ] RLS policies cover all operations?
- [ ] Sensitive data properly protected?
- [ ] No PII in logs or comments?

**Documentation:**
- [ ] Table purpose documented?
- [ ] Complex columns explained?
- [ ] Migration header complete?

---

## [PROJECT_NAME] Patterns

### Multi-Fund Architecture

```sql
-- Funds are first-class entities
CREATE TABLE funds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Many entities reference fund_id
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fund_id UUID NOT NULL REFERENCES funds(id) ON DELETE CASCADE,
    -- ... other columns
);

-- RLS enforces fund-level isolation
CREATE POLICY "Users see own fund data"
ON transactions FOR SELECT TO authenticated
USING (
    fund_id IN (
        SELECT fund_id FROM user_fund_access
        WHERE user_id = auth.uid()
    )
);
```

### Audit Logging

```sql
-- Audit trail for sensitive operations
CREATE TABLE audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type TEXT NOT NULL,
    actor_id UUID REFERENCES profiles(id),
    resource_type TEXT NOT NULL,
    resource_id UUID NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index for querying by resource
CREATE INDEX idx_audit_events_resource 
ON audit_events (resource_type, resource_id);
```

### Soft Deletes (When Needed)

```sql
-- For records that must be preserved
CREATE TABLE important_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    deleted_at TIMESTAMPTZ,
    -- ... other columns
);

-- Query helper
CREATE VIEW active_records AS
SELECT * FROM important_records
WHERE deleted_at IS NULL;

-- RLS excludes soft-deleted
CREATE POLICY "Users see active records"
ON important_records FOR SELECT TO authenticated
USING (deleted_at IS NULL AND user_id = auth.uid());
```

---

## Anti-Patterns

### ❌ Missing Foreign Key Constraints

Results in orphaned data and data integrity issues.

### ❌ Generic JSONB Fields

```sql
-- BAD: Everything in JSON
CREATE TABLE entities (
    id UUID PRIMARY KEY,
    data JSONB  -- Contains everything
);
```

Use structured columns for queryable data. Reserve JSONB for truly flexible metadata.

### ❌ No Indexes on Foreign Keys

Results in full table scans on JOINs.

### ❌ Timestamps Without Timezone

```sql
-- BAD
created_at TIMESTAMP

-- GOOD
created_at TIMESTAMPTZ
```

---

## Expected Output

✅ Well-designed schema following [PROJECT_NAME] patterns  
✅ Proper constraints and indexes  
✅ RLS policies designed  
✅ Migration ready to create  
✅ Schema documented
