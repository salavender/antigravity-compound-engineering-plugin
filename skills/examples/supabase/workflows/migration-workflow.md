# Database Migration Workflow

Safe, systematic approach to creating and applying database migrations in [PROJECT_NAME].

## When To Use

- Adding new tables or columns
- Modifying existing schema
- Creating indexes or constraints
- Setting up RLS policies
- Creating database functions or triggers

---

## Prerequisites

- [ ] Understand the schema change required
- [ ] Know which tables/columns are affected
- [ ] Have a rollback plan

---

## Workflow

### Step 1: Plan the Migration

**What needs to change?**
- New tables?
- New columns?
- Indexes?
- RLS policies?
- Functions or triggers?

**Document:**
```markdown
## Migration Purpose
{What this migration accomplishes}

## Affected Tables
- {table1}
- {table2}

## Dependencies
- {existing migration}
- {required tables}
```

---

### Step 2: Create Migration File

**Naming convention:** `YYYYMMDD_description.sql`

```bash
# Example
touch backend/migrations/$(date +%Y%m%d)_add_user_preferences.sql
```

**File structure:** Use the migration template from `templates/migration-template.sql`

---

### Step 3: Write Migration SQL

**Follow [PROJECT_NAME] patterns:**

1. **Add header comment:**
   ```sql
   -- Migration: {Description}
   -- Date: {YYYY-MM-DD}
   -- Purpose: {What this accomplishes}
   -- Requirements: {Requirement IDs if applicable}
   -- Feature: {feature-name}
   ```

2. **Use idempotent operations:**
   ```sql
   -- Good: Safe to run multiple times
   CREATE TABLE IF NOT EXISTS ...
   CREATE INDEX IF NOT EXISTS ...
   
   -- For types, wrap in error handling
   DO $$ BEGIN
       CREATE TYPE status_type AS ENUM ('active', 'inactive');
   EXCEPTION
       WHEN duplicate_object THEN null;
   END $$;
   ```

3. **Add indexes for foreign keys and common queries:**
   ```sql
   CREATE INDEX IF NOT EXISTS idx_table_column 
   ON schema.table (column);
   ```

4. **Enable RLS on new tables:**
   ```sql
   ALTER TABLE schema.table ENABLE ROW LEVEL SECURITY;
   ```

5. **Add documentation comments:**
   ```sql
   COMMENT ON TABLE schema.table IS 'Description of table purpose';
   COMMENT ON COLUMN schema.table.column IS 'Description of column';
   ```

---

### Step 4: Review Migration

**Checklist:**
- [ ] Header comment includes date, purpose, requirements
- [ ] All operations are idempotent (safe to re-run)
- [ ] Foreign keys have ON DELETE CASCADE or appropriate action
- [ ] Indexes created for foreign keys
- [ ] RLS enabled on tables with sensitive data
- [ ] COMMENT statements document purpose
- [ ] Migration follows existing patterns in `backend/migrations/`

**Review similar migrations:**
```bash
# Find similar migrations for reference
ls backend/migrations/ | grep -i {keyword}
```

---

### Step 5: Test Migration

**Local testing:**

1. Apply migration to local database
2. Verify schema changes
3. Test queries affected by the change
4. Verify RLS policies work correctly

**Common issues:**
- Duplicate type definitions → Use DO $$ error handling
- Missing CASCADE on foreign keys → Data orphaning
- Missing indexes → Slow queries
- RLS not enabled → Data exposure

---

### Step 6: Document Breaking Changes

If migration affects existing code:

```markdown
## Breaking Changes

**Affected:**
- API endpoint: `{endpoint}`
- Component: `{component}`

**Migration path:**
- Update queries to use new column names
- Add null checks for new non-null columns
```

---

## Common Patterns

### Pattern: Add Column with Default

```sql
-- Add column with safe default
ALTER TABLE schema.table 
ADD COLUMN IF NOT EXISTS new_column TEXT DEFAULT 'default_value';

-- Remove default after backfill if needed
ALTER TABLE schema.table 
ALTER COLUMN new_column DROP DEFAULT;
```

### Pattern: Create Trigger for updated_at

```sql
-- Reuse existing function
CREATE TRIGGER update_table_updated_at
    BEFORE UPDATE ON schema.table
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();
```

### Pattern: Multi-Tenancy RLS

```sql
-- Policy: Users see only their fund's data
CREATE POLICY "Users see own fund data"
ON schema.table
FOR SELECT
TO authenticated
USING (
    fund_id IN (
        SELECT fund_id FROM user_fund_access
        WHERE user_id = auth.uid()
    )
);
```

---

## Expected Output

✅ Migration file created in `backend/migrations/`  
✅ Migration follows [PROJECT_NAME] conventions  
✅ Schema changes documented  
✅ Breaking changes noted (if any)  
✅ Ready for deployment
