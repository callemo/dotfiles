"""Shared snippet parameters."""

import re


def params(args, *defaults):
    if len(args) > len(defaults):
        noun = "argument" if len(defaults) == 1 else "arguments"
        raise ValueError(f"expected at most {len(defaults)} {noun}, got {len(args)}")
    return [*args, *defaults[len(args):]]


def options(spec, reserved="h"):
    if not re.fullmatch(r":?(?:[A-Za-z]:?)*", spec):
        raise ValueError("opts must contain letters, each followed by : if it takes a value")
    opts = []
    seen = set()
    for name, colon in re.findall(r"([A-Za-z])(:?)", spec):
        if name in seen:
            raise ValueError(f"duplicate option: {name}")
        if name in reserved:
            raise ValueError(f"option {name} is built in")
        seen.add(name)
        opts.append((name, bool(colon)))
    return opts


def synopsis(opts):
    return " ".join(f"[-{name}{' value' if value else ''}]" for name, value in opts)


def ident(name):
    return bool(re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name))
