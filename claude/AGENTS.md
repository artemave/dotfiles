## Coding

- Avoid defensive code. Prefer to fail with exception to wrap something in an `if` just in case.
- Avoid overflow-hidden in css. Only add it when it serves real purpose.
- Avoid using mocks in tests. Always ask me if you can't think of any other way to test something.
- Don't comment self-descriptive code. Only genuinely non-obvious or confusing code deserves a comment (a gotcha, a non-local invariant, why a line has to exist). If a well-named constant, function, or line already says what it does, add nothing. Rationale belongs in spec/docs, not inline.
- A comment that just translates the code's own identifiers into English (e.g. narrating
  "rescue X, raise Y" as "this turns X into Y, so a forged signature 404s like anything
  else") is still self-descriptive — the names already carry that meaning. Comment only
  the reason behind a choice that the names themselves don't state.
- When genuinely unsure whether a comment clears the bar, don't write it. Test: would a
  reviewer, reading the code without the comment, actually stop and ask about it — or
  would they just read past it? If the latter, cut it.
- Don't explain an invariant that belongs to something you're merely calling.
  If understanding this line only requires trusting the callee's name (a
  scope, a method) — not knowing why the callee is correct — that correctness
  argument belongs as a comment where the callee is defined, not repeated or
  summarized at every call site. Ask: does the reader need this fact to
  follow *this* code, or are they just being handed the callee's own
  documented invariant a second time?
- Before keeping a comment for being a non-obvious/external-system fact, check
  whether that same fact is already stated in project docs (docs/**, readme).
  If it is, strip the duplicated part and re-run the self-descriptive test on
  whatever's left. If nothing genuinely non-obvious survives — the method/line
  was already going to read fine without a comment — cut it entirely; do not
  leave a bare "see docs" pointer with no local content just to mark that a
  doc exists. Keep a pointer only when it's attached to something that still
  needs local explanation (a gotcha, a non-local invariant) which the doc
  reference alone doesn't supply.

## Docs

- Docs state what is true right now. Never narrate history — no "no longer", "used to", "previously", "is now", "we've since", "changed to", "renamed from". If a behaviour changed, describe the current behaviour and delete the old one. Migration notes are the sole exception, and only while a real migration is in flight.

## Browser Automation

Use `agent-browser` for web automation. Run `agent-browser --help` for all commands.

Core workflow:
1. `agent-browser open <url>` - Navigate to page
2. `agent-browser snapshot -i` - Get interactive elements with refs (@e1, @e2)
3. `agent-browser click @e1` / `fill @e2 "text"` - Interact using refs
4. Re-snapshot after page changes
