import os
import json

cacheFilePath = os.path.expanduser('~/.local/share/auto_floating/store.jsonl')

os.system(f'mkdir -p {os.path.dirname(cacheFilePath)}')
os.system(f'touch {cacheFilePath}')

def cacheKey(container):
    props = {
        'window_class': container.window_class,
        'window_instance': container.window_instance,
        'window_role': container.window_role,
        'window_title': container.window_title,
    }

    return json.dumps(props)

