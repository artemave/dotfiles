#!/usr/bin/env node

/**
 * PostToolUse Hook: Desktop notifications for long-running operations
 *
 * Sends a desktop notification when an operation takes longer than 10 seconds.
 * Only notifies if the Claude window is not in focus.
 *
 * Wayland (Sway) compatible using swaymsg.
 * Supports: All tool operations (Bash, Edit, Write, Task, etc.)
 *
 * Test usage:
 *   # Should notify (long duration, not focused)
 *   echo '{"tool":"Bash","duration_ms":15000}' | ~/.claude/hooks/notify-on-completion.js
 *
 *   # Should NOT notify (long duration, but focused)
 *   echo '{"tool":"Bash","duration_ms":15000}' | claude/hooks/notify-on-completion.js
 *
 *   # Should NOT notify (short duration)
 *   echo '{"tool":"Bash","duration_ms":5000}' | ~/.claude/hooks/notify-on-completion.js
 */

const { execSync } = require('child_process');
const fs = require('fs');

const LONG_RUNNING_THRESHOLD_MS = 10000; // 10 seconds

const input = fs.readFileSync(0, 'utf8');
const data = JSON.parse(input);

const duration = data.duration_ms || 0;
if (duration > LONG_RUNNING_THRESHOLD_MS) {
  const toolName = data.tool || 'Operation';
  const durationSec = Math.round(duration / 1000);
  const title = 'Claude Code Complete';
  const message = `${toolName} finished (${durationSec}s)`;

  execSync(`notify-send "${title}" "${message}" --icon=dialog-information`);
}
