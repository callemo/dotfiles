"""Note snippet expansions."""

import datetime
import re


def _expand_nfile(_builder, args):
    """Note file name."""
    note_id = datetime.datetime.today().strftime("%Y%m%d%H%M")
    title = "_".join(args)
    title = re.sub("[^A-Za-z0-9_-]", "", title)
    if title:
        return note_id + "-" + title.lower() + ".txt"
    return note_id + ".txt"


def _expand_nmeta(builder, args):
    """Note metadata. [title] [key:value pairs] - Define metadata like date, tags, etc."""
    # Default values
    metadata = {
        "Date": datetime.datetime.today().isoformat(timespec="seconds"),
        "Title": "",
        "Tags": "",
        "References": "",
        "ISBN": "",
        "URL": "",
        "Author": "",
        "Year": "",
        "Month": "",
    }

    # Separate title words from key:value pairs
    title_words = [arg for arg in args if ":" not in arg]
    metadata["Title"] = " ".join(title_words)

    # Process key:value pairs
    for arg in (a for a in args if ":" in a):
        key, value = arg.split(":", 1)
        key = key.capitalize()
        if key in metadata:
            metadata[key] = value

    # Write metadata section
    builder.write("---")
    for key, value in metadata.items():
        builder.write(f"{key}: {value}")
    builder.write("---")
    builder.write("")

    # Add title as heading if provided
    if metadata["Title"]:
        builder.write("# " + metadata["Title"])
        builder.write("")


SNIPPETS = {
    "nfile": _expand_nfile,
    "nmeta": _expand_nmeta,
}
