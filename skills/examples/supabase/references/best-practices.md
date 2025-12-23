# Supabase Best Practices for [PROJECT_NAME]

[PROJECT_NAME]-specific guidelines for working with Supabase.

---

## Migration Conventions

### Naming

**Format:** `YYYYMMDD_description.sql`

**Examples:**
- `20251203_create_profiles_and_app_role.sql`
- `20251129_multi_fund_architecture.sql`
- `20251124_add_lot_performance.sql`

**Rules:**
- Use current date (not future dates)
- Use underscores, not hyphens
- Be descriptive but concise
- Use `create`, `add`, `update`, `remove` prefixes

### Header Comments

**Always include:**
```sql
-- Migration: {Description}
-- Date: {YYYY-MM-DD}
-- Purpose: {Why this is needed}
-- Requirements: {IDs if applicable}
-- Feature: {feature-name if applicable}
```

**Example:**
```sql
-- Migration: Create app_role ENUM and profiles table for Identity Fortress
-- Date: 2025-12-03
-- Purpose: Establish role-based authentication foundation with JWT custom claims
-- Requirements: 4.1
-- Feature: identity-fortress
```

### Idempotency

**All operations must be safe to re-run:**

```sql
-- ✅ GOOD: Safe to re-run
CREATE TABLE IF NOT EXISTS ...
CREATE INDEX IF NOT EXISTS ...
ALTER TABLE ... ADD COLUMN IF NOT EXISTS ...

-- ✅ GOOD: Type handling
DO $$ BEGIN
    CREATE TYPE status_type AS ENUM ('active', 'inactive');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ❌ BAD: Fails on re-run
CREATE TABLE ...
CREATE INDEX ...
CREATE TYPE ...
```

---

## Auth Integration

### Stateless Client Pattern

[PROJECT_NAME] uses a **stateless Supabase client** with SessionStore as single source of truth.

**Architecture:**
```
SessionStore (localStorage)
    ↓ hydrates ↓
Supabase Client (in-memory only)
```

**Configuration (`lib/supabaseClient.ts`):**
```typescript
export const supabase = createClient(url, anonKey, {
    auth: {
        persistSession: false,  // ← SessionStore handles persistence
        autoRefreshToken: true,
        detectSessionInUrl: true,
    },
});
```

**Why this pattern?**
- Single source of truth (no sync issues)
- Explicit session management
- No localStorage conflicts
- Proper session validation

**See:** `lib/supabaseClient.ts` for full implementation

---

## RLS Security

### Enable by Default

**On all tables with sensitive data:**
```sql
CREATE TABLE table_name (...);
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
```

### Policy Naming

**Use descriptive names:**
```sql
-- ✅ GOOD
CREATE POLICY "Users can view own profile" ...
CREATE POLICY "Fund Managers can view all profiles" ...

-- ❌ BAD
CREATE POLICY "select_policy" ...
CREATE POLICY "policy1" ...
```

### Always Use WITH CHECK

**For UPDATE/INSERT operations:**
```sql
-- ✅ GOOD: Enforces ownership on write
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());  -- ← Prevents claiming other data

-- ❌ BAD: Allows escalation
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid());  -- Missing WITH CHECK
```

---

## Performance

### Index Foreign Keys

**Always create indexes for foreign keys:**
```sql
CREATE TABLE transactions (
    id UUID PRIMARY KEY,
    fund_id UUID NOT NULL REFERENCES funds(id),
    investor_id UUID NOT NULL REFERENCES profiles(id)
);

-- Required indexes
CREATE INDEX idx_transactions_fund_id ON transactions (fund_id);
CREATE INDEX idx_transactions_investor_id ON transactions (investor_id);
```

### Composite Indexes for Common Queries

```sql
-- If querying by fund_id + created_at frequently
CREATE INDEX idx_transactions_fund_date 
ON transactions (fund_id, created_at DESC);
```

### Avoid N+1 Queries

**Use Supabase joins:**
```typescript
// ❌ BAD: N+1 queries
const funds = await supabase.from('funds').select('*');
for (const fund of funds.data) {
    const transactions = await supabase
        .from('transactions')
        .select('*')
        .eq('fund_id', fund.id);
}

// ✅ GOOD: Single query
const funds = await supabase
    .from('funds')
    .select('*, transactions(*)');
```

---

## Data Types

### Standard Types

| Use Case | Type | Notes |
|----------|------|-------|
| Primary Key | `UUID DEFAULT gen_random_uuid()` | Always UUID |
| Money | `NUMERIC(12,2)` | Never FLOAT |
| Timestamps | `TIMESTAMPTZ` | Always with timezone |
| Booleans | `BOOLEAN` | Not TEXT |
| Enums | `CREATE TYPE` | Not TEXT strings |
| IP Address | `INET` | Native support |
| JSON | `JSONB` | Not TEXT |

### Always Add Timestamps

```sql
CREATE TABLE table_name (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- ... columns
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

## Documentation

### Comment Everything

```sql
COMMENT ON TABLE profiles IS 
'Extended user profiles with role-based access control';

COMMENT ON COLUMN profiles.role IS 
'User role (fund_manager or investor) for authorization';

COMMENT ON COLUMN profiles.kyc_status IS 
'KYC verification status (PENDING, APPROVED, REJECTED)';
```

**Why?**
- Helps future developers
- Shows up in database tools
- Documents business logic

---

## Common Pitfalls

### ❌ Missing ON DELETE Actions

```sql
-- BAD: No ON DELETE action
user_id UUID REFERENCES users(id)

-- GOOD: Explicit cascade or restrict
user_id UUID REFERENCES users(id) ON DELETE CASCADE
```

### ❌ TIMESTAMP Instead of TIMESTAMPTZ

```sql
-- BAD: Loses timezone info
created_at TIMESTAMP

-- GOOD: Preserves timezone
created_at TIMESTAMPTZ
```

### ❌ No RLS on Sensitive Tables

```sql
-- BAD: Anyone can read all data
CREATE TABLE sensitive_data (...);

-- GOOD: RLS enforced
CREATE TABLE sensitive_data (...);
ALTER TABLE sensitive_data ENABLE ROW LEVEL SECURITY;
CREATE POLICY "..." ON sensitive_data ...;
```

### ❌ Using Service Role in Client

```typescript
// ❌ BAD: Bypasses ALL RLS policies
const supabase = createClient(url, serviceRoleKey);

// ✅ GOOD: Enforces RLS
const supabase = createClient(url, anonKey);
```

**Service role only for:**
- Admin operations
- Server-side code
- Database migrations

---

## Migration Workflow

1. **Plan** - Document what needs to change
2. **Create file** - Use date prefix naming
3. **Write SQL** - Use idempotent operations
4. **Add indexes** - For foreign keys and queries
5. **Enable RLS** - On sensitive tables
6. **Add comments** - Document tables and columns
7. **Test locally** - Verify migration works
8. **Review** - Check against this guide
9. **Deploy** - Apply to production

---

## References

- **Existing migrations:** `backend/migrations/`
- **Supabase client:** `lib/supabaseClient.ts`
- **Auth context:** `context/AuthContext.tsx`
- **Session storage:** `lib/auth/SessionStore.ts`
