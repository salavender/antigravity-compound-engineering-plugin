# {Spec Name} - Design

> Defines HOW we're building it - architecture, data models, and APIs.
> 
> **Note:** This document is optional for simple specs. Include it for complex initiatives with significant architecture decisions.

---

## Overview

{High-level description of the technical approach}

---

## Architecture

### System Diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│    API      │────▶│  Database   │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Components

| Component | Purpose | Technology |
|-----------|---------|------------|
| {Component 1} | {What it does} | {Tech stack} |
| {Component 2} | {What it does} | {Tech stack} |

---

## Data Model

### Database Schema

```sql
-- {Table name}
CREATE TABLE {table_name} (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  {column_1} {TYPE} NOT NULL,
  {column_2} {TYPE},
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX idx_{table}_{column} ON {table_name}({column});
```

### Entity Relationships

```
{Entity A} 1──────N {Entity B}
    │
    └── 1──────N {Entity C}
```

---

## API Design

### Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/{resource}` | List all |
| GET | `/api/{resource}/:id` | Get by ID |
| POST | `/api/{resource}` | Create |
| PUT | `/api/{resource}/:id` | Update |
| DELETE | `/api/{resource}/:id` | Delete |

### Request/Response Examples

**GET /api/{resource}/:id**

Request:
```bash
curl -X GET /api/{resource}/123
```

Response:
```json
{
  "id": "123",
  "name": "{name}",
  "created_at": "2025-01-01T00:00:00Z"
}
```

---

## Frontend Architecture

### Component Hierarchy

```
{PageComponent}
├── {ContainerComponent}
│   ├── {PresentationalComponent}
│   └── {PresentationalComponent}
└── {SidebarComponent}
```

### State Management

| State | Location | Scope |
|-------|----------|-------|
| {User state} | Context | Global |
| {Form state} | Local | Component |
| {Server state} | React Query | Cached |

---

## Correctness Properties

> [!TIP]
> **Correctness Properties** are formal statements about what the system MUST do across all valid executions. They bridge the gap between human-readable requirements and machine-verifiable tests.

### Property 1: {Property Title}
*For any* {input/state}, THE {system} SHALL {behavior}
**Validates: REQ-001.1**

### Property 2: {Property Title}
*For any* {input/state}, THE {system} SHALL {behavior}
**Validates: REQ-001.2**

---

## Security Considerations

- [ ] Authentication: {How users are authenticated}
- [ ] Authorization: {How permissions are checked}
- [ ] Data validation: {How input is validated}
- [ ] Rate limiting: {How abuse is prevented}

---

## Performance Considerations

- [ ] Caching strategy: {What's cached and how}
- [ ] Query optimization: {Key queries to optimize}
- [ ] Pagination: {How large lists are handled}

---

## Migration Strategy

> [!IMPORTANT]
> Include this section for refactors or changes to existing systems.

### Phase 1: {Phase name}
- {Migration step 1}
- {Migration step 2}

### Rollback Plan
- {How to revert if something goes wrong}

---

**Last Updated**: {YYYY-MM-DD}
