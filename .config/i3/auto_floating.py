#!/usr/bin/env python3
import os

from i3ipc import Connection
from i3ipc import Event

i3 = Connection()

os.system('touch ~/.config/i3/.auto_floating_windows')

def cacheKey(container):
    props = [
            container.window_class,
            container.window_instance,
            container.window_role,
            container.window_title,
            ]

    # Filter out None values
    props = [p for p in props if isinstance(p, str)]

    return '\t'.join(props)


def on_window_new(i3, e):
    key = cacheKey(e.container)

    if len(key) == 0:
        return

    with open(os.path.expanduser('~/.config/i3/.auto_floating_windows'), 'r') as f:
        if key in f.read():
            i3.command('[con_id=%s] floating enable' % e.container.id)


def on_window_floating(_, e):
    key = cacheKey(e.container)

    if len(key) == 0:
        return

    with open(os.path.expanduser('~/.config/i3/.auto_floating_windows'), 'r+') as f:
        lines = f.read().splitlines()

        if e.container.floating == 'user_on' and key not in lines:
            lines.append(key)

        if e.container.floating == 'user_off' and key in lines:
            lines.remove(key)

        f.seek(0)
        f.truncate()
        f.write("\n".join(lines))


i3.on(Event.WINDOW_FLOATING, on_window_floating)
i3.on(Event.WINDOW_NEW, on_window_new)

i3.main()
