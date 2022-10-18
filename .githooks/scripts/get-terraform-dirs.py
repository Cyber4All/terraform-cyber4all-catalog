#!/usr/bin/env python3
import os

def findDirs():
    dirs = []
    for root, _, files in os.walk('.'):
        for file in files:
            if '.terraform' not in root and 'examples' not in root and '.tf' in file:
                dirs.append(root)
                break
    return ' '.join(tuple(dirs))

print(findDirs())