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
 *   echo '{"tool":"Bash","duration_ms":15000}' | CLAUDE_FOCUSED=false node ~/.claude/hooks/notify-on-completion.js
 *
 *   # Should NOT notify (long duration, but focused)
 *   echo '{"tool":"Bash","duration_ms":15000}' | CLAUDE_FOCUSED=true node ~/.claude/hooks/notify-on-completion.js
 *
 *   # Should NOT notify (short duration)
 *   echo '{"tool":"Bash","duration_ms":5000}' | CLAUDE_FOCUSED=false node ~/.claude/hooks/notify-on-completion.js
 */

const { execSync } = require('child_process');
const fs = require('fs');

const LONG_RUNNING_THRESHOLD_MS = 10000; // 10 seconds

try {
  // Read JSON input from stdin
  const input = fs.readFileSync(0, 'utf8');
  const data = JSON.parse(input);

  // Check if operation took longer than threshold
  const duration = data.duration_ms || 0;
  if (duration < LONG_RUNNING_THRESHOLD_MS) {
    return;
  }

  // Check if Claude window is focused
  if (isClaudeWindowFocused()) {
    return;
  }

  // Send notification
  const toolName = data.tool || 'Operation';
  const durationSec = Math.round(duration / 1000);
  const title = 'Claude Code Complete';
  const message = `${toolName} finished (${durationSec}s)`;

  sendNotification(title, message);

} catch (error) {
  console.error('Notification hook error:', error.message);
}

/**
 * Check if any window with "Claude" in the title has focus (Wayland/Sway)
 * Returns true if Claude window is focused, false otherwise
 */
function isClaudeWindowFocused() {
  // Allow overriding for testing
  if (process.env.CLAUDE_FOCUSED !== undefined) {
    return process.env.CLAUDE_FOCUSED === 'true';
  }

  try {
    const result = execSync('swaymsg -t get_tree', {
      encoding: 'utf8',
      timeout: 2000
    });

    const tree = JSON.parse(result);
    const focused = findFocusedWindow(tree);

    if (focused && focused.name) {
      return focused.name.toLowerCase().includes('claude');
    }

    return false;

  } catch (error) {
    return false;
  }
}

/**
 * Recursively find the focused window in Sway tree
 */
function findFocusedWindow(node) {
  if (node.focused && node.type === 'con') {
    return node;
  }

  if (node.nodes) {
    for (const child of node.nodes) {
      const result = findFocusedWindow(child);
      if (result) return result;
    }
  }

  if (node.floating_nodes) {
    for (const child of node.floating_nodes) {
      const result = findFocusedWindow(child);
      if (result) return result;
    }
  }

  return null;
}

/**
 * Send desktop notification using notify-send
 */
function sendNotification(title, message) {
  try {
    execSync(`notify-send "${title}" "${message}" --icon=dialog-information`, {
      timeout: 2000
    });
  } catch (error) {
    // Silently fail if notification can't be sent
  }
}
