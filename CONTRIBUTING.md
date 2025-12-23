# Contributing to Antigravity Compound Engineering Plugin

Thank you for your interest in contributing! This is a community-driven system for AI agents to compound their capabilities.

## Credits

This project is inspired by the original [Compound Engineering Plugin](https://github.com/EveryInc/compound-engineering-plugin) by [Every Inc](https://github.com/EveryInc).

## How to Contribute

### New Workflows
1. Add to `.agent/workflows/{workflow-name}.md`
2. Document in `.agent/workflows/README.md`
3. Submit a PR

### New Skills
1. Create `skills/{skill-name}/SKILL.md`
2. Include instrumentation (`./scripts/log-skill.sh`)
3. Add to `docs/architecture/compound-system.md`
4. Submit a PR

### Critical Patterns
1. Document in `docs/solutions/{category}/{solution-name}.md`
2. If recurring 3+ times, run `/promote_pattern`
3. Add to `docs/solutions/patterns/critical-patterns.md`
4. Submit a PR

## Development Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run `./scripts/validate-compound.sh` to ensure integrity
5. Commit (`git commit -m 'feat: add amazing feature'`)
6. Push and open a Pull Request

## Code Style

- Use conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`)
- Run validation scripts before committing
- Follow existing patterns in the codebase

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
