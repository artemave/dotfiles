#!/usr/bin/env python3
import os

from i3ipc import Connection
from i3ipc import Event

i3 = Connection()

os.system('touch ~/.config/i3/.auto_floating_windows')


def on_window_new(i3, e):
    # Ignore NoneType windows
    if not isinstance(e.container.window_class, str):
        return

    with open(os.path.expanduser('~/.config/i3/.auto_floating_windows'), 'r') as f:
        if e.container.window_class in f.read():
            i3.command('[con_id=%s] floating enable' % e.container.id)


def on_window_floating(_, e):
    # Ignore NoneType windows
    if not isinstance(e.container.window_class, str):
        return

    with open(os.path.expanduser('~/.config/i3/.auto_floating_windows'), 'r+') as f:
        lines = f.read().splitlines()

        if e.container.floating == 'user_on' and e.container.window_class not in lines:
            lines.append(e.container.window_class)

        if e.container.floating == 'user_off' and e.container.window_class in lines:
            lines.remove(e.container.window_class)

        f.seek(0)
        f.truncate()
        f.write("\n".join(lines))


i3.on(Event.WINDOW_FLOATING, on_window_floating)
i3.on(Event.WINDOW_NEW, on_window_new)

i3.main()
