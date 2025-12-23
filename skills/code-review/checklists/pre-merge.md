# Pre-Merge Checklist

## Functional Verification
- [ ] Does the feature meet all implementation plan requirements?
- [ ] Have all acceptance criteria been verified?
- [ ] Are there any console errors in the browser?
- [ ] Is the UI responsive on mobile (simulated)?

## Code Quality
- [ ] **Linting**: `npm run lint` passes with 0 errors.
- [ ] **Formatting**: Code formatting is consistent.
- [ ] **Patterns**: Project patterns are followed (e.g., UI components, file naming).
- [ ] **Comments**: Complex logic is commented; dead code is removed.

## Testing
- [ ] **Unit Tests**: Added/updated tests for new logic?
- [ ] **Pass Rate**: `npm test` passes (or at least no *new* failures).

## Security
- [ ] **Secrets**: No secrets committed.
- [ ] **Permissions**: Data access controls verified.

## Documentation
- [ ] **Changelog**: Entry adds to/is covered by changelog generation.
- [ ] **Artifacts**: Task and plan updated.
