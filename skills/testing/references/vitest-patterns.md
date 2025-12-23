# Vitest & Testing Library Patterns

## Common Mocking Patterns

### Mocking a Module
```tsx
vi.mock('next/navigation', () => ({
  useRouter: () => ({
    push: vi.fn(),
    replace: vi.fn(),
  }),
}));
```

### Mocking a Component
```tsx
vi.mock('./ChildComponent', () => ({
  ChildComponent: () => <div data-testid="child-mock">Mocked Child</div>,
}));
```

## Async Testing

Wait for element to appear:
```tsx
await waitFor(() => {
  expect(screen.getByText('Loaded')).toBeInTheDocument();
});
```

Verify element disappears:
```tsx
await waitFor(() => {
  expect(screen.queryByText('Loading...')).not.toBeInTheDocument();
});
```

## User Interaction

Use `fireEvent` for simple events, or `userEvent` (if setup) for complex ones.

```tsx
fireEvent.change(input, { target: { value: 'New Value' } });
fireEvent.click(button);
```
