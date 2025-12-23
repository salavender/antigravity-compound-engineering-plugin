# Row Level Security (RLS) Policy Design

Systematic approach to designing and implementing secure RLS policies in Supabase.

## When To Use

- Creating new tables with sensitive data
- Implementing multi-tenancy
- Setting up role-based access control
- Reviewing security requirements

---

## Prerequisites

- [ ] Understand data access requirements
- [ ] Know user roles and permissions
- [ ] Have auth.uid() available (Supabase auth enabled)

---

## Workflow

### Step 1: Define Access Requirements

**Questions to answer:**

1. **Who can READ this data?**
   - Own data only?
   - All users in same fund?
   - Fund managers only?
   - Public data?

2. **Who can WRITE (INSERT/UPDATE/DELETE)?**
   - Owner only?
   - Fund managers?
   - System/service role only?

3. **What's the ownership model?**
   - User-owned (profiles, preferences)
   - Fund-owned (investments, transactions)
   - Shared (multi-tenancy)

---

### Step 2: Enable RLS on Table

```sql
-- Always enable RLS first
ALTER TABLE schema.table ENABLE ROW LEVEL SECURITY;
```

> **Critical:** Without RLS enabled, data is publicly accessible!

---

### Step 3: Implement Policies

**Choose the appropriate pattern:**

#### Pattern A: User Owns Data

```sql
-- Policy: Users can view own data
CREATE POLICY "Users can view own data"
ON schema.table
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Policy: Users can update own data
CREATE POLICY "Users can update own data"
ON schema.table
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());
```

#### Pattern B: Role-Based Access

```sql
-- Policy: Fund Managers can view all
CREATE POLICY "Fund Managers can view all"
ON schema.table
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'fund_manager'
    )
);
```

#### Pattern C: Fund-Scoped Multi-Tenancy

```sql
-- Policy: Users see data from their funds only
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

#### Pattern D: Insert with Service Role

```sql
-- Policy: Service role can insert (for automated processes)
CREATE POLICY "Service role can insert"
ON schema.table
FOR INSERT
TO authenticated
WITH CHECK (true);
```

---

### Step 4: Test Policies

**Test matrix:**

| User Type | Can Read? | Can Write? | Expected Result |
|-----------|-----------|------------|-----------------|
| Owner | ✓ | ✓ | See own data only |
| Fund Manager | ✓ | ✓ | See all fund data |
| Other User | ✗ | ✗ | No access |
| Anonymous | ✗ | ✗ | No access |

**Testing approach:**

1. Create test users with different roles
2. Attempt access with each role
3. Verify policies enforce expected behavior

```sql
-- Test as specific user
SET LOCAL role authenticated;
SET LOCAL request.jwt.claims.sub = '{user_id}';

-- Run query
SELECT * FROM schema.table;

-- Reset
RESET role;
```

---

### Step 5: Document Policies

**Add policy documentation:**

```sql
COMMENT ON POLICY "Policy name" ON schema.table IS 
'Description of who can access and why';
```

---

## Security Checklist

Before deploying RLS policies:

- [ ] RLS enabled on all sensitive tables?
- [ ] Policies cover all operations (SELECT, INSERT, UPDATE, DELETE)?
- [ ] Tested with different user roles?
- [ ] No `WITH CHECK (true)` without justification?
- [ ] Service roles explicitly documented?
- [ ] Policies reference `auth.uid()` correctly?
- [ ] Multi-tenancy enforced at data level?

---

## Common Pitfalls

### ❌ WRONG: Missing WITH CHECK

```sql
-- Allows users to UPDATE to claim data they don't own
CREATE POLICY "Users update own data"
ON schema.table
FOR UPDATE
TO authenticated
USING (user_id = auth.uid());
-- Missing: WITH CHECK (user_id = auth.uid())
```

### ✅ CORRECT: Enforce ownership on write

```sql
CREATE POLICY "Users update own data"
ON schema.table
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());
```

### ❌ WRONG: Exposed service operations

```sql
-- Too permissive - allows anyone to insert
CREATE POLICY "Allow insert"
ON schema.table
FOR INSERT
TO authenticated
WITH CHECK (true);
```

### ✅ CORRECT: Document and limit

```sql
-- Only specific operations should allow unrestricted insert
CREATE POLICY "Service role can insert for registration"
ON public.profiles
FOR INSERT
TO authenticated
WITH CHECK (true);
-- Document: Required for user registration flow
```

---

## Reference

**Existing RLS examples:**
- `backend/migrations/20251203_create_profiles_and_app_role.sql`
- `backend/migrations/20251129_multi_fund_architecture.sql`

**Supabase client:**
- Client enforces RLS: `lib/supabaseClient.ts` (uses anon key)
- Service role bypasses RLS: Only for admin operations

**See also:**
- `workflows/migration-workflow.md` for creating migrations with RLS
- `references/best-practices.md` for security guidelines
