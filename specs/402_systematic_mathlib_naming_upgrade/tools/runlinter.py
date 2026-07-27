#!/usr/bin/env python3
"""Parse `lake exe batteries/runLinter <root>` output into findings JSON.

Recovered from specs/archive/400_clear_lean_v433_deprecation_warnings/tools/runlinter.py and
repaired per the migration plan:

  * ROW now strips the pretty-printer's leading `@`.  batteries pretty-prints `@Name` for
    declarations carrying implicit arguments; not stripping it silently loses 425 of 861
    `defsWithUnderscore` names.
  * `names` subcommand emits the fully-qualified declaration names for one linter category.

Preserved traps from the original:
  * The header regex opens with `/-`, NOT `/--`.  A `/--`-anchored regex matches nothing.
  * `LINTER FAILED` has two row shapes and can appear mid-message, so it is reclassified by
    message text on both sides of a diff.
  * Raw `lean` emits `PATH:L:C: severity: msg` while lake emits `severity: PATH:L:C: msg`;
    both shapes are accepted.

Usage:
  runlinter.py parse  <raw.txt> <out.json>
  runlinter.py counts <findings.json>
  runlinter.py names  <findings.json> <linter>
  runlinter.py diff   <old.json> <new.json>
"""
import json
import re
import sys
from collections import Counter

HEADER = re.compile(r"^/-+ The `(\w+)` linter reports:")
# lean shape:  PATH:L:C: severity: msg
ROW_LEAN = re.compile(r"^(/\S*?\.lean):(\d+):(\d+): (?:error|warning): (.*)$")
# lake shape:  severity: PATH:L:C: msg
ROW_LAKE = re.compile(r"^(?:error|warning): (/\S*?\.lean):(\d+):(\d+): (.*)$")
CHECK_ROW = re.compile(r"^#check .*LINTER FAILED")
# The declaration name leads the message.  batteries prints `@Name` when the declaration has
# implicit arguments; the `@` MUST be stripped (postmortem constraint 12).
DECL = re.compile(r"^@?([A-Za-z_À-￿«][^\s]*)")
REPO = "/home/benjamin/Projects/BimodalLogic/"


def parse(raw_path):
    rows = []
    linter = None
    for line in open(raw_path, encoding="utf-8"):
        line = line.rstrip("\n")
        h = HEADER.match(line)
        if h:
            linter = h.group(1)
            continue
        if CHECK_ROW.match(line):
            rows.append(["LINTER FAILED", "(#check form)", 0, line, ""])
            continue
        m = ROW_LEAN.match(line) or ROW_LAKE.match(line)
        if not m:
            continue
        path, ln, _col, msg = m.groups()
        path = path.replace(REPO, "")
        cat = "LINTER FAILED" if "LINTER FAILED" in msg else linter
        d = DECL.match(msg)
        name = d.group(1) if d else ""
        rows.append([cat, path, int(ln), msg, name])
    return rows


def counts(rows):
    c = Counter()
    for row in rows:
        cat, _path, _ln, msg = row[0], row[1], row[2], row[3]
        c["LINTER FAILED" if "LINTER FAILED" in msg else cat] += 1
    return c


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    cmd = sys.argv[1]
    if cmd == "parse":
        rows = parse(sys.argv[2])
        json.dump(rows, open(sys.argv[3], "w"), ensure_ascii=False, indent=0)
        for k, v in counts(rows).most_common():
            print(f"{v:5d}  {k}")
        print(f"{sum(counts(rows).values()):5d}  TOTAL")
    elif cmd == "counts":
        rows = json.load(open(sys.argv[2]))
        for k, v in counts(rows).most_common():
            print(f"{v:5d}  {k}")
        print(f"{sum(counts(rows).values()):5d}  TOTAL")
    elif cmd == "names":
        rows = json.load(open(sys.argv[2]))
        want = sys.argv[3]
        for row in rows:
            if row[0] == want and row[4]:
                print(row[4])
    elif cmd == "diff":
        old = counts(json.load(open(sys.argv[2])))
        new = counts(json.load(open(sys.argv[3])))
        for k in sorted(set(old) | set(new)):
            o, n = old.get(k, 0), new.get(k, 0)
            flag = "" if o == n else ("  <-- CHANGED" if n > o else "  <-- reduced")
            print(f"{k:22s} {o:5d} -> {n:5d}{flag}")
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
