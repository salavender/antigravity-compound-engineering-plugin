# Supabase Debugging Workflow

Systematic approach to diagnosing and resolving Supabase issues.

## When To Use

- Auth errors (login failures, session issues)
- Query errors (RLS blocking, missing data)
- Performance problems (slow queries, timeouts)
- Connection issues

---

## Common Issues

### Issue 1: Auth State Mismatch

**Symptoms:**
- User shows as logged in frontend, but API returns 401
- Session lost on page refresh
- "No rows returned" despite data existing

**Diagnosis:**

1. Check Supabase auth state:
   ```javascript
   const { data: { session } } = await supabase.auth.getSession();
   console.log('Session:', session);
   ```

2. Verify SessionStore:
   ```javascript
   // Check lib/auth/SessionStore.ts
   const stored = SessionStore.getSession();
   console.log('Stored session:', stored);
   ```

3. Check sync between SessionStore and Supabase:
   ```javascript
   // In AuthContext, verify setSession was called
   await supabase.auth.setSession(sessionData);
   ```

**Solution:**
- Ensure `AuthContext` properly hydrates Supabase from SessionStore on init
- Verify `persistSession: false` in `supabaseClient.ts`
- Check SessionStore is single source of truth

**Reference:** `lib/supabaseClient.ts` architecture comments

---

### Issue 2: RLS Policy Blocking Query

**Symptoms:**
- Query returns empty array despite data existing
- "permission denied" errors
- Works in Supabase dashboard, fails in app

**Diagnosis:**

1. Verify RLS is the issue:
   ```sql
   -- Test query with RLS disabled (in Supabase SQL editor)
   ALTER TABLE schema.table DISABLE ROW LEVEL SECURITY;
   SELECT * FROM schema.table;
   ALTER TABLE schema.table ENABLE ROW LEVEL SECURITY;
   ```

2. Check user's auth.uid():
   ```sql
   SELECT auth.uid();
   ```

3. Review table policies:
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'your_table';
   ```

**Solution:**
- Create missing policy for the operation
- Verify policy USING clause matches auth.uid() correctly
- Check if user has required role in profiles table

**See:** `workflows/rls-policies.md` for policy patterns

---

### Issue 3: N+1 Query Problem

**Symptoms:**
- Slow page loads
- Many sequential database queries
- High database CPU usage

**Diagnosis:**

1. Check for missing joins:
   ```typescript
   // ❌ BAD: N+1 queries
   const users = await supabase.from('users').select('*');
   for (const user of users.data) {
       const profile = await supabase.from('profiles')
           .select('*')
           .eq('user_id', user.id);
   }
   
   // ✅ GOOD: Single query with join
   const users = await supabase
       .from('users')
       .select('*, profiles(*)');
   ```

2. Enable query logging:
   ```typescript
   // Add to supabaseClient.ts for debugging
   Logger.debug('[Supabase] Query:', { url, method });
   ```

**Solution:**
- Use Supabase joins: `.select('*, related_table(*)')`
- Create database views for complex joins
- Add indexes for foreign keys

---

### Issue 4: Missing Environment Variables

**Symptoms:**
- "Missing NEXT_PUBLIC_SUPABASE_ANON_KEY" error
- Supabase client not initialized
- 404 on API calls

**Diagnosis:**

1. Check `.env.local`:
   ```bash
   cat .env.local | grep SUPABASE
   ```

2. Verify environment variables loaded:
   ```bash
   echo $NEXT_PUBLIC_SUPABASE_URL
   ```

**Solution:**
- Copy from `.env.local.example` if exists
- Get keys from Supabase Dashboard > Project Settings > API
- Restart dev server after adding env vars

---

### Issue 5: CORS Errors

**Symptoms:**
- "CORS policy" errors in browser console
- Requests blocked from localhost
- Works in production, fails locally

**Diagnosis:**

1. Check Supabase project settings:
   - Dashboard > Authentication > URL Configuration
   - Redirect URLs should include `http://localhost:3000`

2. Verify request origin:
   ```javascript
   console.log('Origin:', window.location.origin);
   ```

**Solution:**
- Add localhost to allowed redirect URLs in Supabase
- Add site URL to authentication settings
- Ensure using HTTPS in production

---

### Issue 6: Timeout on Large Queries

**Symptoms:**
- "AbortError: The operation was aborted"
- Queries taking >15 seconds
- Timeout on complex joins

**Diagnosis:**

1. Check query performance:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM large_table WHERE ...;
   ```

2. Look for missing indexes:
   ```sql
   -- Check if index exists
   SELECT * FROM pg_indexes WHERE tablename = 'your_table';
   ```

**Solution:**
- Add indexes for WHERE clause columns
- Add indexes for foreign keys
- Paginate results (use `.range(start, end)`)
- Increase timeout in `supabaseClient.ts` if justified

**Reference:** `lib/supabaseClient.ts` - 15 second timeout configured

---

## Debugging Checklist

When encountering Supabase errors:

- [ ] Check browser console for errors
- [ ] Verify auth session exists
- [ ] Test query in Supabase SQL editor
- [ ] Review RLS policies on affected tables
- [ ] Check for missing indexes
- [ ] Verify environment variables loaded
- [ ] Check network tab for failed requests
- [ ] Review Supabase client configuration

---

## Tools

### Log Supabase Queries

Add to `lib/supabaseClient.ts`:

```typescript
global: {
    fetch: (url, options = {}) => {
        Logger.debug('[Supabase] Request:', { url, method: options.method });
        // ... existing timeout logic
    },
}
```

### Test RLS in SQL Editor

```sql
-- Simulate authenticated user
SET LOCAL role authenticated;
SET LOCAL request.jwt.claims.sub = 'user-uuid-here';

-- Run your query
SELECT * FROM your_table;

-- Reset
RESET role;
```

---

## Expected Output

✅ Issue identified and root cause understood  
✅ Solution implemented or workaround documented  
✅ Verified fix resolves the problem  
✅ Added prevention measures (indexes, policies, etc.)
