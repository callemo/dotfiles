"""Note snippet expansions."""

import datetime
import re


def nfile(builder, args):
    """[text] Note filename. [title ...]

    usage: snip nfile [title ...]

    arguments:
      title  Title words; default: no title.

    Prints YYYYMMDDHHMM-title.txt using local time. Joins title words with
    underscores, lowercases them, and keeps ASCII letters, digits, underscores
    and hyphens. Without a title, prints YYYYMMDDHHMM.txt. Creates no file.

    examples:
      snip nfile
      snip nfile Meeting notes
    """
    stamp = datetime.datetime.today().strftime("%Y%m%d%H%M")
    title = re.sub("[^A-Za-z0-9_-]", "", "_".join(args)).lower()
    if title:
        stamp += f"-{title}"
    return f"{stamp}.txt"


def nmeta(builder, args):
    """[text] Plain note metadata. [title ...] [key:value ...]

    usage: snip nmeta [title ...] [key:value ...]

    arguments:
      title      Words without colons form the title.
      key:value  Set a metadata field. Keys are case-insensitive; values may
                 contain colons. Quote an argument that contains spaces.

    Keys: Date, Title, Tags, References, ISBN, URL, Author, Year, Month.
    Date defaults to local time. Other fields are blank unless supplied.
    Title overrides the title words. Repeated keys use the last value;
    unknown keys are ignored. Prints plain text, not YAML.

    examples:
      snip nmeta Meeting notes 'tags:#work #ideas'
      snip nmeta 'title:Reading notes' URL:https://example.org
    """
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

    metadata["Title"] = " ".join(arg for arg in args if ":" not in arg)
    keys = {key.lower(): key for key in metadata}
    for arg in args:
        key, sep, value = arg.partition(":")
        key = keys.get(key.lower())
        if sep and key:
            metadata[key] = value

    builder.write("---")
    for key, value in metadata.items():
        builder.write(f"{key}: {value}")
    builder.write("---")
    builder.write("")

    if metadata["Title"]:
        builder.write("# " + metadata["Title"])
        builder.write("")


SNIPPETS = {
    "nfile": nfile,
    "nmeta": nmeta,
}
