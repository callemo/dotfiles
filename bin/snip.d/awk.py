"""AWK snippet expansions.

Reference material (fields, functions, formats, math, regex, system)
moved to awk-reference.txt in this directory.
"""


def _expand_awkbasic(builder, _args):
    """AWK basic program structure."""
    builder.write("#!/usr/bin/awk -f")
    builder.write("")
    builder.write("BEGIN {")
    builder.indent()
    builder.write("# setup")
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("/pattern/ {")
    builder.indent()
    builder.write("# action")
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("END {")
    builder.indent()
    builder.write("# summary")
    builder.dedent()
    builder.write("}")


def _expand_awkarray(builder, _args):
    """AWK array operations."""
    builder.write("BEGIN {")
    builder.indent()
    builder.write("# associative arrays")
    builder.write('count["red"] = 5')
    builder.write('count["blue"] = 7')
    builder.write("")
    builder.write("# iterate over array")
    builder.write("for (c in count)")
    builder.indent()
    builder.write("print c, count[c]")
    builder.dedent()
    builder.write("")
    builder.write("# check if key exists")
    builder.write('if ("red" in count)')
    builder.indent()
    builder.write('print "found red:", count["red"]')
    builder.dedent()
    builder.write("")
    builder.write("# delete element")
    builder.write('delete count["red"]')
    builder.write("")
    builder.write("# multi-dimensional arrays")
    builder.write('items["fruit", "apple"] = 5')
    builder.write('items["veg", "carrot"] = 10')
    builder.dedent()
    builder.write("}")


def _expand_awkcsv(builder, _args):
    """AWK CSV file processing."""
    builder.write('BEGIN { FS = ","; hdr = 0 }')
    builder.write("")
    builder.write("# process header")
    builder.write("NR == 1 {")
    builder.indent()
    builder.write("for (i = 1; i <= NF; i++)")
    builder.indent()
    builder.write("col[i] = $i")
    builder.dedent()
    builder.write("hdr = 1")
    builder.write("next")
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("# process data rows")
    builder.write("{")
    builder.indent()
    builder.write("for (i = 1; i <= NF; i++)")
    builder.indent()
    builder.write("row[col[i]] = $i")
    builder.dedent()
    builder.write("")
    builder.write("# use column by name")
    builder.write('print row["price"] * row["quantity"]')
    builder.dedent()
    builder.write("}")


def _expand_awkgroup(builder, _args):
    """AWK grouping and summarizing data."""
    builder.write("# Group and sum by first field")
    builder.write("{")
    builder.indent()
    builder.write("sum[$1] += $2")
    builder.write("cnt[$1]++")
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("END {")
    builder.indent()
    builder.write("for (grp in sum) {")
    builder.indent()
    builder.write('printf("%s: %d items, sum = %.2f, avg = %.2f\\n",')
    builder.indent()
    builder.write("grp, cnt[grp], sum[grp], sum[grp]/cnt[grp])")
    builder.dedent()
    builder.dedent()
    builder.write("}")
    builder.dedent()
    builder.write("}")


def _expand_awkfile(builder, _args):
    """AWK file operations."""
    builder.write("# read from multiple input files")
    builder.write("# awk 'program' file1 file2")
    builder.write("")
    builder.write("# knowing which file is being processed")
    builder.write('FILENAME == "data.txt" { print "In data.txt:", $0 }')
    builder.write("")
    builder.write("# write to file")
    builder.write("{")
    builder.indent()
    builder.write('print $1 > "results.txt"   # overwrites file')
    builder.write('print $2 >> "append.txt"   # appends to file')
    builder.write('print $3 | "sort"          # pipe to command')
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("# close file explicitly (good practice)")
    builder.write("END {")
    builder.indent()
    builder.write('close("results.txt")')
    builder.write('close("append.txt")')
    builder.write('close("sort")')
    builder.dedent()
    builder.write("}")


SNIPPETS = {
    "awkarray": _expand_awkarray,
    "awkbasic": _expand_awkbasic,
    "awkcsv": _expand_awkcsv,
    "awkfile": _expand_awkfile,
    "awkgroup": _expand_awkgroup,
}
