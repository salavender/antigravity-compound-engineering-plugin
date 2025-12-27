---
name: standard-security-auth
description: Security & Authentication Specialist - Expert in JWT, cookie-based auth, MFA, and generic security patterns
last_updated: 2025-12-27
file_triggers:
  - "middleware.ts"
  - "**/auth/**"
  - "app/contexts/AuthContext.tsx"
  - "lib/apiClient.ts"
---

# Security & Authentication Specialist

## Overview

An expert agent specializing in the project's authentication system, security patterns, and API integration. This agent understands JWT, cookie-based, and multi-factor authentication flows, as well as proxy architectures for secure backend communication.

## When To Use

- **Authentication Implementation**: When implementing or modifying auth flows
- **Security Review**: When reviewing code for security vulnerabilities
- **API Integration**: When connecting new features to the auth system
- **MFA/Role-based Logic**: When working with multi-factor authentication or role-based access
- **Audit Compliance**: When ensuring code follows audit logging requirements

## Instrumentation

```bash
# Log usage when using this skill
./scripts/log-skill.sh "standard-security-auth" "manual" "$$"
```

## What do you want to do?

1. **Implement Authentication Flow** → See "Auth Flow Patterns" below
2. **Review Security Vulnerabilities** → See "Security Checklist" below
3. **Connect API to Auth System** → See "API Integration" below
4. **MFA/Role-based Access** → See "Role Management" below
5. **Audit & Compliance** → See "Audit Patterns" below

---

## Auth Flow Patterns

### Cookie-Based Authentication
- Use the standard API client for calls that require authentication
- Never manually attach Authorization headers in cookie mode
- The middleware automatically handles JWT validation and refresh
- Session state is maintained in a centralized `AuthContext`

### JWT Token Management
- Tokens are stored in HttpOnly cookies for security
- Middleware handles proactive refresh before expiration
- Multi-Factor Authentication (MFA) sessions require secondary verification
- Role-based access is enforced at both middleware and component levels

---

## Security Checklist

### Critical Security Checks
- [ ] All API calls use the canonical API client
- [ ] No hardcoded API URLs or fallbacks (use environment variables)
- [ ] Middleware route protection is properly configured
- [ ] Role-based access control is enforced at both frontend and backend
- [ ] No sensitive data is stored in unencrypted local storage
- [ ] Content Security Policy (CSP) headers are properly applied

---

## API Integration

### Proxy Architecture
The application uses a Backend for Frontend (BFF) proxy pattern:

```typescript
// Correct way to make authenticated API calls
import { fetchWithAuth } from '@/lib/apiClient';

const response = await fetchWithAuth('/api/resource/data');
```

---

## Role Management

### Role Definitions
- `admin`: Full administrative access, typically requires MFA
- `user`: Standard access to personal/assigned resources

### Route Protection
Routes are typically configured in `middleware.ts`:
- Public routes: Login, callback, and landing pages
- Protected routes: Administrative and user dashboard routes

---

## Audit Patterns

### Security Event Logging
All security-relevant events must be logged:
- Token refresh events
- Login/logout success and failure
- Role access violations
- Critical data modifications

---

## Common Pitfalls & Solutions

### Pitfall: Guest State Handling
- ❌ **WRONG**: Auth status endpoint returns 401 for unauthenticated users (causes browser noise)
- ✅ **CORRECT**: Auth status endpoint returns 200 with `{ authenticated: false }`

### Pitfall: Duplicate API Calls
- ❌ **WRONG**: Session initialization called multiple times outside of controlled effects
- ✅ **CORRECT**: Use controlled effects with proper guards to prevent duplicate calls

---

## Troubleshooting

### Debugging Authentication Issues
1. Check browser cookies for valid auth tokens
2. Verify the token is a properly formatted JWT
3. Check middleware logs for route protection decisions
4. Confirm user role matches expected access level
