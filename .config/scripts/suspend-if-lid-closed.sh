#!/bin/bash
# swayidle idle action: suspend, but only when the lid is shut.
#
# Backstop for the one case logind structurally cannot handle: it ignores lid
# events for HoldoffTimeoutSec (30s) after every resume, so a lid close in that
# window is dropped and nothing else is coming. The holdoff has to stay — this
# laptop emits a spurious "Lid closed." on resume (three times since Jul 22),
# and without the holdoff that would re-suspend the machine the instant the lid
# is opened.
#
# Gated on the lid rather than plain idle, so a long build with the lid open is
# never interrupted, and working on the external screen with the lid shut only
# suspends once there's genuinely been no input.
lid=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 \
        org.freedesktop.login1.Manager LidClosed)

if [[ $lid == "b true" ]]; then
  logger "[swayidle] Idle with the lid shut. Suspending."
  systemctl suspend
fi
