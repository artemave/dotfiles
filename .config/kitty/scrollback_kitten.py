import os
import re
import tempfile
from time import monotonic

from kittens.tui.handler import result_handler
from kitty.fast_data_types import add_timer, remove_timer
from kitty.launch import launch, parse_launch_args

KITTEN = os.path.expanduser('~/.config/kitty/scrollback_kitten.py')
VIEWER = ('nvim', '--noplugin', '-n', '-i', 'NONE', '-u', os.path.expanduser('~/.config/kitty/scrollback.lua'))
# Matched on screen state because under ssh and containers the foreground process is not claude.
# The title alone is not enough: it loses its glyph when idle and can become a session topic.
CLAUDE_TITLE = re.compile('^[✳⠀-⣿]|Claude Code')
CLAUDE_PROMPT_BOX = re.compile(r'^❯.*(?:\n.*)*?\n─{20,}', re.MULTILINE)
TRANSCRIPT_FOOTER = 'Showing detailed transcript'
POLL_SECONDS = 0.02
TRANSCRIPT_OPEN_TIMEOUT = 1
TRANSCRIPT_DUMP_TIMEOUT = 30


def main(args):
    pass


def when(condition, action, timeout):
    deadline = monotonic() + timeout

    def tick(timer_id):
        if condition():
            remove_timer(timer_id)
            action()
        elif monotonic() > deadline:
            remove_timer(timer_id)

    add_timer(tick, POLL_SECONDS, True)


def open_overlay(boss, window, *args):
    spec = parse_launch_args(['--type=overlay', f'--next-to=id:{window.id}', *args])
    launch(boss, spec.opts, spec.args)


def show_dump(boss, window, lines_before):
    lines = window.as_text(as_ansi=True, add_history=True).split('\n')
    plain_lines = window.as_text(add_history=True).split('\n')
    footer = max(i for i, line in enumerate(plain_lines) if TRANSCRIPT_FOOTER in line)
    # A full 100k scrollback shifts lines_before, leaving nothing after it.
    dump = lines[lines_before:footer - 1] or lines[:footer - 1]

    fd, path = tempfile.mkstemp(prefix='kitty-scrollback-')
    with os.fdopen(fd, 'w') as f:
        f.write('\n'.join(dump))

    open_overlay(
        boss, window, f'--watcher={KITTEN}', f'--var=claude_window={window.id}',
        'sh', '-c', 'f=$1; shift; exec <"$f"; rm "$f"; exec "$@"', 'sh', path, *VIEWER,
    )


def dump_claude_transcript(boss, window):
    # Each dump adds a full copy to history, starting from the top of the main screen.
    lines_before = (
        len(window.as_text(add_history=True, alternate_screen=True).split('\n'))
        - len(window.as_text(alternate_screen=True).split('\n'))
    )

    def in_transcript():
        return TRANSCRIPT_FOOTER in window.as_text()

    def dumped():
        return window.screen.is_main_linebuf() and in_transcript()

    def dump():
        window.send_key('[')
        when(dumped, lambda: show_dump(boss, window, lines_before), TRANSCRIPT_DUMP_TIMEOUT)

    if in_transcript():
        dump()
    else:
        window.send_key('ctrl+o')
        # Waiting matters: outside the transcript, `[` would be typed into the prompt.
        when(in_transcript, dump, TRANSCRIPT_OPEN_TIMEOUT)


def is_claude_fullscreen(window):
    if window.screen.is_main_linebuf():
        return False
    return bool(CLAUDE_TITLE.search(window.title) or CLAUDE_PROMPT_BOX.search(window.as_text()))


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map[target_window_id]
    if is_claude_fullscreen(window):
        dump_claude_transcript(boss, window)
    else:
        open_overlay(boss, window, '--stdin-source=@screen_scrollback', '--stdin-add-formatting', *VIEWER)


def on_close(boss, window, data):
    # Gone when the overlay closes because its Claude window did.
    claude_window = boss.window_id_map.get(int(window.user_vars['claude_window']))
    if claude_window:
        # A footer left on the main screen would make the next dump look finished before it starts.
        claude_window.screen.erase_in_display(2, False)
        claude_window.send_key('q')
