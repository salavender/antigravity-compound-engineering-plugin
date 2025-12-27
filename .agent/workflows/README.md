# Compound Engineering Workflows

> **Quick Start:** New to this project? Read [critical-patterns.md](../docs/solutions/patterns/critical-patterns.md) first.
> **Technical Architecture:** For the complete system architecture, see [docs/architecture/compound-system.md](../docs/architecture/compound-system.md).

## Core Loop

```
/explore (optional) → /specs (large) → /plan (per phase) → /work → /review → /compound → /housekeeping → repeat
```

| Command | When | Purpose |
|---------|------|---------|
| `/explore` | Before planning | Deep investigation, best practices, multi-order analysis |
| `/specs` | Before multi-week initiatives | Create structured specification with phases |
| `/plan` | Before significant work | Research, design, create implementation plan |
| `/plan-review` | Before executing plan | Review plan quality and completeness |
| `/work` | During implementation | Execute plan systematically |
| `/review` | After work complete | Quality check before merge |
| `/compound` | After solving problems | Capture knowledge for reuse |
| `/housekeeping` | Before git push | Archive completed work, fix drift |

## Support Commands

### Todos & Triage
| Command | Purpose |
|---------|---------|
| `/triage` | Prioritize pending todo items |
| `/resolve-todo` | Batch-process ready todos |

### Code Review
| Command | Purpose |
|---------|---------|
| `/resolve-pr` | Address PR feedback systematically |
| `/plan-review` | Review plan quality before execution |

### Release & Docs
| Command | Purpose |
|---------|---------|
| `/changelog` | Generate changelog from commits |
| `/release-docs` | Prepare release documentation |
| `/deploy-docs` | Deploy documentation updates |

### Debugging
| Command | Purpose |
|---------|---------|
| `/report-bug` | Create structured bug report |
| `/reproduce-bug` | Systematically reproduce a bug |

### Skills & Extensions
| Command | Purpose |
|---------|---------|
| `/create-agent-skill` | Add new modular capabilities |
| `/heal-skill` | Diagnose and fix broken skills |
| `/generate-command` | Create new workflow commands |

### Platform-Specific
| Command | Purpose |
|---------|---------|
| `/xcode-test` | Run Xcode tests for iOS |

### Maintenance
| Command | Purpose |
|---------|---------|
| `/housekeeping` | Pre-push cleanup: archive completed work, fix state drift |
| `/compound-health` | Weekly health check: monitor knowledge base vitals |
| `check-docs-freshness` | Verify documentation updates for code changes |

### Modular Skills
| Skill | Purpose | Entry Point |
|-------|---------|-------------|
| `session-resume` | Establish session state | `skills/session-resume/SKILL.md` |
| `compound-docs` | Search/Document solutions | `skills/compound-docs/SKILL.md` |
| `file-todos` | Manage file-based tasks | `skills/file-todos/SKILL.md` |
| `code-review` | Systematic quality gates | `skills/code-review/SKILL.md` |
| `testing` | Unified test patterns | `skills/testing/SKILL.md` |
| `debug` | Structured root cause analysis | `skills/debug/SKILL.md` |

---

## Before You Start Any Work

### 1. Resume Session (STRICTLY REQUIRED)

Always run this first when starting a new conversation:
```bash
# Read and follow the checklist
cat skills/session-resume/SKILL.md
```

### 2. Search Existing Solutions

```bash
# Check if this problem was solved before
grep -r "{keywords}" docs/solutions/

# Check critical patterns
cat docs/solutions/patterns/critical-patterns.md
```

### 2. Check Pending Work

```bash
# Any active specs?
ls docs/specs/*/README.md 2>/dev/null | grep -v templates

# Any ready todos?
ls todos/*-ready-*.md 2>/dev/null

# Any in-progress plans?
ls plans/*.md 2>/dev/null
```

---

## Directory Structure

```
.agent/workflows/     # You are here - all workflow commands
docs/solutions/       # Persistent knowledge base
├── patterns/         # Critical patterns (READ FIRST)
├── schema.yaml       # Solution validation schema
└── {categories}/     # Categorized solutions
docs/explorations/    # Deep investigations & research
skills/               # Modular capabilities
plans/                # Implementation plans from /plan
└── archive/          # Completed plans
todos/                # Work items from /review, /triage
└── archive/          # Completed todos
docs/specs/           # Multi-session specifications
└── archive/          # Completed specs
```

---

## Key Principles

1. **Search before solving** - Check `docs/solutions/` and `docs/explorations/`
2. **Document after solving** - Run `/compound` when you fix something
3. **Follow patterns** - Reference `critical-patterns.md`
4. **Create todos for deferred work** - Don't just document in artifacts
5. **Use conventional commits** - Enables changelog automation
6. **Housekeeping before push** - Run `/housekeeping` to archive completed work

---

*Last updated: 2025-12-20*
