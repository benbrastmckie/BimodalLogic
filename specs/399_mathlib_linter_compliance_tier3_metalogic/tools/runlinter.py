#!/usr/bin/env python3
"""Parse `lake exe runLinter Bimodal` output into the task's findings JSON, and diff two runs.

Row format (matches baseline/runlinter-findings.json):  [linter, relpath, line, message]

Header regex is `^/-+ The \\`(\\w+)\\` linter reports:` -- note the header opens with `/-`,
NOT `/--`, so a `/--`-anchored regex silently matches nothing.

`LINTER FAILED` rows are counted SEPARATELY from `simpNF`. The baseline artifact folds its 115
`LINTER FAILED` rows into its `simpNF` bucket, so a naive per-linter diff against the baseline
shows a spurious -115 on `simpNF`; `--diff` compensates via --fold-failed on the OLD side.

Usage:
  runlinter.py parse  <raw.txt> <out.json>
  runlinter.py counts <findings.json> [--tier3-only]
  runlinter.py diff   <old.json> <new.json>
"""
import json
import re
import sys
from collections import Counter

HEADER = re.compile(r"^/-+ The `(\w+)` linter reports:")
ROW = re.compile(r"^(/\S*?\.lean):(\d+):(\d+): error: (.*)$")
# Positionless `#check <decl> /- LINTER FAILED ...` rows: the baseline artifact records these
# under the pseudo-path "(#check form)", and they are 37 of the 115 `LINTER FAILED` rows.
CHECK_ROW = re.compile(r"^#check .*LINTER FAILED")
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
            rows.append(["LINTER FAILED", "(#check form)", 0, line])
            continue
        m = ROW.match(line)
        if not m:
            continue
        path, ln, _col, msg = m.groups()
        path = path.replace(REPO, "")
        cat = "LINTER FAILED" if "LINTER FAILED" in msg else linter
        rows.append([cat, path, int(ln), msg])
    return rows


def counts(rows, tier3_only=False):
    """Category census, normalised so old and new artifacts are directly comparable.

    `baseline/runlinter-findings.json` files its 115 `LINTER FAILED` rows under `simpNF`;
    later artifacts break them out. Reclassifying by message text on BOTH sides removes the
    spurious -115 a naive per-linter diff would report on `simpNF`.
    """
    c = Counter()
    for cat, path, _ln, msg in rows:
        if tier3_only and ("/Automation/" in path or "/Boneyard/" in path):
            continue
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
    elif cmd == "counts":
        rows = json.load(open(sys.argv[2]))
        t3 = "--tier3-only" in sys.argv
        for k, v in counts(rows, t3).most_common():
            print(f"{v:5d}  {k}")
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
