# Common Supabase Patterns in [PROJECT_NAME]

Recurring patterns used across the [PROJECT_NAME] codebase.

---

## Pattern 1: Multi-Fund Tenancy

**Use case:** Isolate data between different funds

**Implementation:**

```sql
-- Core fund table
CREATE TABLE funds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Fund-scoped data
CREATE TABLE fund_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fund_id UUID NOT NULL REFERENCES funds(id) ON DELETE CASCADE,
    -- ... other columns
);

-- User access mapping
CREATE TABLE user_fund_access (
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    fund_id UUID REFERENCES funds(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, fund_id)
);

-- RLS enforces isolation
CREATE POLICY "Users see own fund data"
ON fund_data FOR SELECT TO authenticated
USING (
    fund_id IN (
        SELECT fund_id FROM user_fund_access
        WHERE user_id = auth.uid()
    )
);
```

**Example:** `backend/migrations/20251129_multi_fund_architecture.sql`

---

## Pattern 2: Role-Based Access Control

**Use case:** Different permissions for fund managers vs investors

**Implementation:**

```sql
-- Role enum
CREATE TYPE app_role AS ENUM ('fund_manager', 'investor');

-- Profiles with role
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    role app_role NOT NULL DEFAULT 'investor',
    -- ... other columns
);

-- Role-based policy
CREATE POLICY "Fund Managers can view all"
ON sensitive_table FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'fund_manager'
    )
);

-- Regular users see filtered data
CREATE POLICY "Users see limited data"
ON sensitive_table FOR SELECT TO authenticated
USING (
    user_id = auth.uid()
    OR EXISTS (
        SELECT 1 FROM profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'fund_manager'
    )
);
```

**Example:** `backend/migrations/20251203_create_profiles_and_app_role.sql`

---

## Pattern 3: Audit Logging

**Use case:** Track sensitive operations for compliance

**Implementation:**

```sql
CREATE TABLE audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type TEXT NOT NULL,
    actor_id UUID REFERENCES profiles(id),
    resource_type TEXT NOT NULL,
    resource_id UUID NOT NULL,
    metadata JSONB,
    ip_address INET,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes for querying
CREATE INDEX idx_audit_events_actor 
ON audit_events (actor_id, created_at DESC);

CREATE INDEX idx_audit_events_resource 
ON audit_events (resource_type, resource_id);

-- RLS: Only fund managers can view audit logs
CREATE POLICY "Fund Managers can view audit logs"
ON audit_events FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'fund_manager'
    )
);
```

**Example:** `backend/migrations/20251202_create_audit_events.sql`

---

## Pattern 4: Performance Indexes

**Use case:** Optimize common queries

**Implementation:**

```sql
-- Foreign key indexes (always)
CREATE INDEX idx_transactions_fund_id 
ON transactions (fund_id);

CREATE INDEX idx_transactions_investor_id 
ON transactions (investor_id);

-- Composite index for fund + date queries
CREATE INDEX idx_transactions_fund_date 
ON transactions (fund_id, created_at DESC);

-- Partial index for pending items only
CREATE INDEX idx_transactions_pending 
ON transactions (status, created_at)
WHERE status = 'pending';

-- Index for frequent WHERE clauses
CREATE INDEX idx_profiles_investor_code 
ON profiles (investor_code) WHERE investor_code IS NOT NULL;
```

**Example:** `backend/migrations/performance_indexes.sql`

---

## Pattern 5: KYC Status Tracking

**Use case:** Track investor verification status

**Implementation:**

```sql
-- Status in profiles
ALTER TABLE profiles 
ADD COLUMN kyc_status TEXT DEFAULT 'PENDING';

-- Index for compliance queries
CREATE INDEX idx_profiles_kyc_status 
ON profiles (kyc_status);

-- RLS: Users can see own status, managers see all
CREATE POLICY "Users can view own KYC status"
ON profiles FOR SELECT TO authenticated
USING (id = auth.uid());

CREATE POLICY "Fund Managers can view all KYC status"
ON profiles FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = auth.uid()
        AND p.role = 'fund_manager'
    )
);
```

**Example:** `backend/migrations/20251203_alter_profiles_for_identity_fortress.sql`

---

## Pattern 6: Updated At Trigger

**Use case:** Auto-update `updated_at` on row changes

**Implementation:**

```sql
-- Create reusable function (once per database)
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to any table
CREATE TRIGGER update_{table}_updated_at
    BEFORE UPDATE ON {schema}.{table}
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();
```

**Usage:** All tables with `updated_at` column

---

## Pattern 7: Realtime Subscriptions

**Use case:** Live updates for fund data

**Implementation:**

```typescript
// Client-side subscription
const subscription = supabase
    .channel('fund-updates')
    .on(
        'postgres_changes',
        {
            event: '*',
            schema: 'public',
            table: 'transactions',
            filter: `fund_id=eq.${fundId}`
        },
        (payload) => {
            console.log('Change detected:', payload);
            // Update UI
        }
    )
    .subscribe();

// Cleanup
return () => subscription.unsubscribe();
```

**Example:** `lib/realtime/fundUpdates.ts`

---

## Pattern 8: Safe Enum Migration

**Use case:** Add new enum value without breaking

**Implementation:**

```sql
-- Original enum
CREATE TYPE status AS ENUM ('pending', 'approved');

-- Safe way to add value (PostgreSQL 12+)
ALTER TYPE status ADD VALUE IF NOT EXISTS 'rejected';

-- For pre-12, must create new type and migrate
DO $$ BEGIN
    -- Only if type doesn't exist
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_v2') THEN
        CREATE TYPE status_v2 AS ENUM ('pending', 'approved', 'rejected');
        
        -- Migrate column
        ALTER TABLE table_name 
        ALTER COLUMN status TYPE status_v2 
        USING status::text::status_v2;
        
        -- Drop old type
        DROP TYPE status;
        
        -- Rename new type
        ALTER TYPE status_v2 RENAME TO status;
    END IF;
END $$;
```

---

## Pattern 9: Pending Cash Adjustments

**Use case:** Track transaction adjustments before approval

**Implementation:**

```sql
CREATE TABLE pending_cash_adjustments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_request_id UUID REFERENCES transaction_requests(id) ON DELETE CASCADE,
    fund_id UUID NOT NULL REFERENCES funds(id),
    adjustment_amount NUMERIC(12,2) NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Prevent duplicate adjustments
CREATE UNIQUE INDEX idx_pending_adjustments_unique 
ON pending_cash_adjustments (transaction_request_id);

-- RLS: Only fund managers can view/manage
CREATE POLICY "Fund Managers manage adjustments"
ON pending_cash_adjustments FOR ALL TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'fund_manager'
    )
);
```

**Example:** `backend/migrations/20251127_add_pending_cash_adjustments.sql`

---

## Pattern 10: System Logs with Test Flag

**Use case:** Separate test from production logs

**Implementation:**

```sql
CREATE TABLE system_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type TEXT NOT NULL,
    message TEXT,
    metadata JSONB,
    is_test BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index excluding test logs
CREATE INDEX idx_system_logs_production 
ON system_logs (created_at DESC)
WHERE is_test = FALSE;

-- Query production logs only
SELECT * FROM system_logs 
WHERE is_test = FALSE 
ORDER BY created_at DESC;
```

**Example:** `backend/migrations/20251126_add_is_test_to_system_logs.sql`

---

## Reference Migrations

Study these for real-world examples:

- **Multi-tenancy:** `20251129_multi_fund_architecture.sql`
- **RBAC:** `20251203_create_profiles_and_app_role.sql`
- **Audit:** `20251202_create_audit_events.sql`
- **Performance:** `performance_indexes.sql`
- **Triggers:** `20251203_create_claims_sync_trigger.sql`
