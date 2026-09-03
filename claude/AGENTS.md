## Coding

- Avoid defensive code. Prefer to fail with exception to wrap something in an `if` just in case.
- Avoid overflow-hidden in css. Only add it when it serves real purpose.
- Avoid using mocks in tests. Always ask me if you can't think of any other way to test something.
- Don't comment self-descriptive code. Only genuinely non-obvious or confusing code deserves a comment (a gotcha, a non-local invariant, why a line has to exist). If a well-named constant, function, or line already says what it does, add nothing. Rationale belongs in spec/docs, not inline.

## Browser Automation

Use `agent-browser` for web automation. Run `agent-browser --help` for all commands.

Core workflow:
1. `agent-browser open <url>` - Navigate to page
2. `agent-browser snapshot -i` - Get interactive elements with refs (@e1, @e2)
3. `agent-browser click @e1` / `fill @e2 "text"` - Interact using refs
4. Re-snapshot after page changes
