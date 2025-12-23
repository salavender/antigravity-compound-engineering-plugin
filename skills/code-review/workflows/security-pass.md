# Security Review Pass

## Checklist

### 1. Authentication & Authorization
- [ ] **Auth Guards**: Are protected pages wrapped in `AuthGuard` or middleware check?
- [ ] **RLS Policies**: Do Supabase queries rely on RLS (Row Level Security)?
  - *Check*: Are we using `supabase-js` client (enforces RLS) or `service_role` (bypasses RLS)?
  - *Rule*: ONLY use `service_role` in backend API routes or Edge Functions, NEVER in frontend.
- [ ] **User Ownership**: Do write operations verify `user_id` matches the authenticated user?

### 2. Data Validation
- [ ] **Input Sanitization**: Are inputs validated (Zod/Yup)?
- [ ] **Type Safety**: Are we using strict TypeScript types? avoiding `any`?
- [ ] **SQL Injection**: Are we using parameterized queries (Supabase does this by default)?

### 3. Secrets Management
- [ ] **Environment Variables**: Are secrets (API keys) prefixed with `NEXT_PUBLIC_` ONLY if they are safe for public exposure?
- [ ] **Hardcoding**: `grep` for hardcoded keys or tokens.

## Verification Commands

```bash
# Find service role usage (potential bypass)
grep -r "createClient" . | grep "service_role"

# Find dangerous public keys
grep -r "NEXT_PUBLIC" . | grep "SECRET"
```
