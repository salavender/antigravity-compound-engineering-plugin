---
description: Operational performance measurement. Establish and track system performance metrics.
triggers: [compound, explore, housekeeping, refactor]
uses: []
---

# /bench - Performance Measurement and Monitoring

Establish baseline performance metrics, run benchmarks, and track system health over time. This workflow ensures visibility into latency, resource usage, and operational efficiency.

> **Why benchmark systematically?** Performance degrades invisibly. Regular measurement catches regressions early and validates optimizations.

## When To Use

- Before major releases
- After performance-sensitive changes
- Quarterly as part of operational health checks
- When investigating slow features
- As validation after `/refactor` work

---

## Workflow

### Phase 1: Baseline Establishment

#### Step 1: Define Benchmark Scope

Identify critical paths and targets.

#### Step 2: Establish metrics

```bash
# Capture baseline metrics for your project
# e.g., curl -w "@curl-format.txt" -o /dev/null -s https://api.yourproject.com/health
```

### Phase 2: Benchmark Execution

#### Step 3: Run Backend Benchmarks

```bash
# Run unit-level benchmarks or API latency tests
# e.g., pytest --benchmark-only
```

#### Step 4: Run Frontend Benchmarks

```bash
# measure build time, bundle size, or Lighthouse scores
# e.g., time npm run build
```

#### Step 5: Run Database Benchmarks

Analyze critical queries.

### Phase 3: Analysis & Reporting

#### Step 6: Compare Against Baseline

Evaluate changes in latency or resource consumption.

#### Step 7: Create Performance Report

Document findings in `docs/explorations/performance-benchmark-{date}.md`.

### Phase 4: Action & Improvement

#### Step 8: Create Optimization Todos

For regressions or target misses, create todos matching project patterns.

---

## Related Workflows

- **Validation:** Use `/bench` after `/refactor` to verify improvements
- **Deep Dive:** Use `/explore` for bottleneck investigation
- **Maintenance:** Run quarterly as part of `/housekeeping`

---

## Instrumentation

```bash
./scripts/log-skill.sh "bench" "workflow" "$$"
```
