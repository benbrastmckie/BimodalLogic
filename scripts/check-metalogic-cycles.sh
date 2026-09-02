#!/usr/bin/env bash
# check-metalogic-cycles.sh
#
# Assert that FormalSystem/Metalogic/ contains exactly ONE directory-level import cycle.
#
# WHY THIS EXISTS: "Metalogic/ has exactly one directory-level cycle" was, until this script
# landed, an argued claim -- re-derived by hand from a grep every time someone needed to trust it,
# and recorded in Metalogic/README.md as prose that could and did go stale. The claim is
# mechanical, so it is checked mechanically. `Metalogic/README.md` cites this script.
#
# WHAT A "DIRECTORY-LEVEL EDGE" IS: for every live .lean file at
# `Metalogic/<Src>/...`, every `import FormalSystem.Metalogic.<Dst>...` where `<Dst>` names a real
# subdirectory of `Metalogic/` and `<Dst> != <Src>` contributes the edge `<Src> -> <Dst>`. A cycle
# is a pair {A, B} with both `A -> B` and `B -> A` present. This is the same notion
# `Metalogic/README.md` documents, not a stricter or looser one.
#
# TWO DELIBERATE EXCLUSIONS, both recorded so a future reader does not read them as bugs:
#   1. Sibling aggregators (`Metalogic/<X>.lean`, beside `<X>/`) are excluded as edge SOURCES.
#      An aggregator's whole job is to import its own directory's contents; counting it as a
#      source would manufacture a cycle out of a convention artifact. They are NOT excluded as
#      edge targets -- `BXCanonical/Completeness.lean` importing the `WeakCanonical` aggregator is
#      a real dependency of BXCanonical on WeakCanonical, and is counted.
#   2. `Metalogic/Boneyard/` would be skipped if it existed. It does not today (the single
#      archive is `FormalSystem/Boneyard/`, outside this subtree), but the guard is cheap and the
#      repository has had a nested archive before.
#
# NOT WIRED INTO check-module-invariants.sh, deliberately: that harness is the phase gate for the
# whole tree, and this is a single-subtree structural assertion with its own exit code. Run it
# directly. It is catalogued in docs/development/MODULE_INVARIANTS.md and cited by
# FormalSystem/Metalogic/README.md.
#
# Exit codes: 0 exactly one cycle; 1 any other count (including zero -- a zero would mean the
# documented BXCanonical <-> WeakCanonical pair vanished, which is a finding, not a silent pass).

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

BASE="FormalSystem/Metalogic"
[ -d "$BASE" ] || { echo "FAIL  no $BASE directory under $ROOT"; exit 1; }

python3 - "$BASE" <<'PYEOF'
import os, re, sys

base = sys.argv[1]

# Sibling aggregators: Metalogic/<X>.lean sitting beside Metalogic/<X>/.
aggregators = {
    e[:-5] for e in os.listdir(base)
    if e.endswith(".lean") and os.path.isdir(os.path.join(base, e[:-5]))
}

import_re = re.compile(r"^import (FormalSystem\.Metalogic\.[A-Za-z0-9_.]+)", re.M)
edges = {}

for dirpath, dirnames, filenames in os.walk(base):
    dirnames[:] = [d for d in dirnames if d != "Boneyard"]
    for fn in filenames:
        if not fn.endswith(".lean"):
            continue
        path = os.path.join(dirpath, fn)
        rel = os.path.relpath(path, base)
        parts = rel.split(os.sep)
        if len(parts) < 2:
            continue          # a sibling aggregator: excluded as a source (see header)
        src = parts[0]
        try:
            text = open(path, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        for module in import_re.findall(text):
            dst = module[len("FormalSystem.Metalogic."):].split(".")[0]
            if dst == src or not os.path.isdir(os.path.join(base, dst)):
                continue
            edges.setdefault((src, dst), []).append(f"{rel} -> {module}")

cycles = sorted({tuple(sorted(p)) for p in edges if (p[1], p[0]) in edges})

for a, b in cycles:
    print(f"CYCLE  {a} <-> {b}")
    for x, y in ((a, b), (b, a)):
        lines = edges[(x, y)]
        print(f"         {x} -> {y}  ({len(lines)} import line{'' if len(lines)==1 else 's'})")
        for line in sorted(lines):
            print(f"           {line}")

n = len(cycles)
if n == 1:
    print(f"PASS  exactly 1 directory-level import cycle in {base}/")
    sys.exit(0)
print(f"FAIL  expected exactly 1 directory-level import cycle in {base}/, found {n}")
if n == 0:
    print("      Zero is a finding, not a pass: the documented BXCanonical <-> WeakCanonical")
    print("      pair is expected to be present. Confirm it was broken deliberately.")
sys.exit(1)
PYEOF
