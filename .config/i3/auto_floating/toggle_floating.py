#!/usr/bin/env python3

import os
import json
from types import SimpleNamespace
import subprocess
import json
from shared import cacheKey, cacheFilePath

def get_floating_state():
    result = subprocess.run(['i3-msg', '-t', 'get_tree'], capture_output=True, text=True)

    tree = json.loads(result.stdout)

    focused_node = find_focused_node(tree)

    if focused_node:
        floating_state = focused_node.get('floating', None)
        window_class = focused_node.get('window_properties', {}).get('class')
        window_title = focused_node.get('name')
        window_role = focused_node.get('window_properties', {}).get('window_role', None)
        window_instance = focused_node.get('window_properties', {}).get('instance')

        props = SimpleNamespace(**{
            'window_class': window_class,
            'window_title': window_title,
            'window_role': window_role,
            'window_instance': window_instance
        })

        return (
            floating_state,
            props
        )
    else:
        return (None, None)

def find_focused_node(node):
    # Recursively search for the focused node in the tree
    if isinstance(node, dict):
        if node.get('focused', False):
            return node
        else:
            for _, value in node.items():
                result = find_focused_node(value)
                if result:
                    return result
    elif isinstance(node, list):
        for item in node:
            result = find_focused_node(item)
            if result:
                return result
    return None


os.system('i3-msg floating toggle')

floating_state, props = get_floating_state()

if floating_state:
    key = cacheKey(props)

    with open(cacheFilePath, 'r+') as f:
        lines = f.read().splitlines()

        if floating_state == 'user_on' and key not in lines:
            lines.append(key)

        if floating_state == 'user_off' and key in lines:
            lines.remove(key)

        f.seek(0)
        f.truncate()
        f.write('\n'.join(lines))
