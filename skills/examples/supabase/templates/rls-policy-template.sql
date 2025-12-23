-- Row Level Security Policy Template
-- Table: {schema}.{table_name}
-- Description: {What data access this policy controls}

-- ============================================================================
-- Policy: User-Owned Data
-- Use when: Users should only see/modify their own data
-- ============================================================================

CREATE POLICY "Users can view own data"
ON {schema}.{table}
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can update own data"
ON {schema}.{table}
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ============================================================================
-- Policy: Role-Based Access
-- Use when: Certain roles should have broader access
-- ============================================================================

CREATE POLICY "Fund Managers can view all"
ON {schema}.{table}
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'fund_manager'
    )
);

-- ============================================================================
-- Policy: Fund-Scoped Multi-Tenancy
-- Use when: Data belongs to a fund and users should see only their fund's data
-- ============================================================================

CREATE POLICY "Users see own fund data"
ON {schema}.{table}
FOR SELECT
TO authenticated
USING (
    fund_id IN (
        SELECT fund_id FROM user_fund_access
        WHERE user_id = auth.uid()
    )
);

-- ============================================================================
-- Policy: Service Role Operations
-- Use when: System operations need unrestricted access
-- ============================================================================

CREATE POLICY "Service role can insert"
ON {schema}.{table}
FOR INSERT
TO authenticated
WITH CHECK (true);
-- NOTE: Document why unrestricted access is needed

-- ============================================================================
-- Policy: Public Read
-- Use when: Data is public and anyone can read it
-- ============================================================================

CREATE POLICY "Public can view"
ON {schema}.{table}
FOR SELECT
TO anon, authenticated
USING (true);
