#!/usr/bin/env python3
"""xref: update cross references in note files

Usage: xref [dir]

Scans .md and .txt files for [[wiki-links]], builds a reverse
link map, and rewrites the References: line in each target's
frontmatter. Prints warnings to stderr for missing targets.
"""

import os
import re
import sys
from collections import defaultdict

link_re = re.compile(r'\[\[([0-9A-Za-z_/.-]+)\]\]')
prefix_re = re.compile(r'^(Z/R/n/|Z/R/)')


def files(root):
    result = []
    for dirpath, _, names in os.walk(root):
        for name in names:
            if name.endswith('.md') or name.endswith('.txt'):
                result.append(os.path.join(dirpath, name))
    result.sort()
    return result


def links(root):
    out = []
    for path in files(root):
        seen, ll = set(), []
        with open(path, encoding='utf-8') as f:
            for line in f:
                if line.strip().startswith('References:'):
                    continue
                for m in link_re.finditer(line):
                    t = m.group(1)
                    if t not in seen:
                        seen.add(t)
                        ll.append(t)
        if ll:
            out.append((path, ll))
    return out


def revlinks(root):
    raw = defaultdict(list)
    for src, targets in links(root):
        for t in targets:
            key = prefix_re.sub('', t)
            if src not in raw[key]:
                raw[key].append(src)

    merge = {}
    for k in list(raw):
        cands = [m for m in raw
                 if k != m and len(k) < len(m)
                 and (m.startswith(k) or m.endswith('/' + k))]
        if len(cands) == 1:
            merge[k] = cands[0]

    for k, m in merge.items():
        for src in raw[k]:
            if src not in raw[m]:
                raw[m].append(src)
        del raw[k]

    return dict(raw)


def find(fs, key):
    pat = re.compile(r'(^|/)' + re.escape(key) + r'[^/]*$', re.IGNORECASE)
    return next((f for f in fs if pat.search(f)), None)


def stem(path, root):
    name = os.path.relpath(path, root)
    name = prefix_re.sub('', name)
    return re.sub(r'\.(md|txt)$', '', name)


def rewrite(text, refs):
    lines = text.split('\n')
    infront = False
    for i, line in enumerate(lines):
        if line.rstrip() == '---':
            infront = not infront
            continue
        if infront and line.startswith('References:'):
            lines[i] = 'References: ' + refs if refs else 'References:'
            break
    return '\n'.join(lines)


def run(root):
    root = os.path.realpath(root)
    fs = files(root)
    rev = revlinks(root)
    warnings = []

    for key, sources in rev.items():
        target = find(fs, key)
        if not target:
            names = ' '.join(f'[[{stem(s, root)}]]' for s in sources)
            warnings.append(f'file not found: following [[{key}]] from {names}')
            continue

        refs = ' '.join(sorted(f'[[{stem(s, root)}]]' for s in sources))
        with open(target, encoding='utf-8') as f:
            text = f.read()
        with open(target, 'w', encoding='utf-8') as f:
            f.write(rewrite(text, refs))

    return warnings


if __name__ == '__main__':
    d = sys.argv[1] if len(sys.argv) > 1 else os.environ.get('NROOT', '.')
    for w in run(d):
        print('xref: ' + w, file=sys.stderr)
