#!/usr/bin/env bash
# check-metalogic-cycles.sh
#
# TWO INDEPENDENT ASSERTIONS BEHIND ONE EXIT CODE:
#
#   A. FormalSystem/Metalogic/ contains exactly ONE directory-level import cycle.
#   B. The library-wide UPWARD import set equals a recorded allowlist, now empty.
#
# Neither subsumes the other: A is a single-subtree cycle claim, B is a whole-library layer-order
# claim. The script exits 0 only when both hold, and prints the result of both before exiting.
#
# WHY THIS EXISTS: "Metalogic/ has exactly one directory-level cycle" was, until this script
# landed, an argued claim -- re-derived by hand from a grep every time someone needed to trust it,
# and recorded in Metalogic/README.md as prose that could and did go stale. The claim is
# mechanical, so it is checked mechanically. `Metalogic/README.md` cites this script. The layer
# order added in assertion B was in exactly the same position: ORGANISATION.md stated a table
# that the tree had not matched for some time, and nothing noticed.
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
#      archive is `Boneyard/`, outside this subtree), but the guard is cheap and the
#      repository has had a nested archive before.
#
# ASSERTION B -- THE LAYER-ORDER ALLOWLIST:
#   It reads the layer table and the import graph from the SAME places the measurement script
#   does -- `LAYERS` in scripts/measure-refactor-partitions.py, loaded by importlib so there is
#   exactly one copy of that table in the repository, and scripts/lib/import_graph.py's leading-
#   import parser rather than assertion A's own regex (a bare `^import` grep additionally matches
#   usage examples inside module docstrings; see that module's header).
#
#   Sibling aggregators (`FormalSystem/<X>.lean` beside `<X>/`, at any depth) are excluded as edge
#   SOURCES for the same reason assertion A excludes them: an aggregator's whole job is to import
#   its own directory's contents, so counting it as a source manufactures findings out of a
#   convention artifact. They are NOT excluded as targets.
#
#   It asserts the upward set EQUALS the allowlist -- it fails on a SURPLUS and on a SHORTFALL
#   alike, in the same spirit as assertion A's "zero cycles is a finding, not a pass" branch. A
#   shortfall means the work that empties the allowlist has landed and this list is now stale,
#   which someone should confirm rather than have silently absorbed.
#
#   The allowlist is now EMPTY, and that is the landed end state rather than a not-yet-filled
#   one. Its 7 entries all keyed on `Syntax/MinusLanguage/AxiomDischarge.lean`; the
#   language-extension merge moved that file to `FormalSystem/MinusLanguage/AxiomDischarge.lean`,
#   a top-level directory outside `LAYERS`, so `layer_of` returns None for it and it contributes
#   no measured edge at all. Note what that costs: every import into and out of the three
#   language-extension directories is now invisible to this measurement. See ORGANISATION.md's
#   layer-table note.
#
#   THE WORK THAT EMPTIED THEM: docs/development/PUBLICATION_REFACTOR.md Phase 5, the
#   {Plus,Minus,Star}Language directory merges.  A future entry is recorded, not excused.
#
# NOT WIRED INTO check-module-invariants.sh, deliberately: that harness is the phase gate for the
# whole tree, and these are standalone structural assertions with their own exit code. Run it
# directly. It is catalogued in docs/development/MODULE_INVARIANTS.md and cited by
# FormalSystem/Metalogic/README.md.
#
# Exit codes: 0 both assertions hold; 1 either fails. Assertion A fails on any cycle count other
# than one (including zero -- a zero would mean the documented BXCanonical <-> WeakCanonical pair
# vanished, which is a finding, not a silent pass). Assertion B fails on any surplus or shortfall
# against the allowlist.

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

BASE="FormalSystem/Metalogic"
[ -d "$BASE" ] || { echo "FAIL  no $BASE directory under $ROOT"; exit 1; }

CYCLES_STATUS=0
python3 - "$BASE" <<'PYEOF' || CYCLES_STATUS=$?
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

# ---------------------------------------------------------------------------
# Assertion B: the library-wide upward import set equals the recorded allowlist
# ---------------------------------------------------------------------------

echo
LAYERS_STATUS=0
python3 - <<'PYEOF' || LAYERS_STATUS=$?
import importlib.util
import os
import sys

root = os.getcwd()
sys.path.insert(0, os.path.join(root, "scripts", "lib"))
from import_graph import ImportGraph  # noqa: E402

# One copy of the layer table in the repository, not two.  The measurement
# script's filename is not an importable identifier, so it is loaded by path.
_spec = importlib.util.spec_from_file_location(
    "_measure_refactor_partitions",
    os.path.join(root, "scripts", "measure-refactor-partitions.py"),
)
_measure = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_measure)
LAYERS, LIB, layer_of = _measure.LAYERS, _measure.LIB, _measure.layer_of

# The recorded allowlist, now EMPTY.  It held 7 entries, all keyed on
# `FormalSystem.Syntax.MinusLanguage.AxiomDischarge`; PUBLICATION_REFACTOR.md Phase 5
# (the {Plus,Minus,Star}Language merges) moved that module to
# `FormalSystem.MinusLanguage.AxiomDischarge`, at the library root and outside `LAYERS`,
# so it no longer contributes a measured upward edge.  Any future entry is derived by
# running `measure-refactor-partitions.py upward-edges`, never hand-copied from a plan.
ALLOWLIST = frozenset()

g = ImportGraph()


def is_sibling_aggregator(module):
    """``FormalSystem.Metalogic.Core`` with ``Metalogic/Core/`` beside it -- excluded
    as an edge source (see this script's header)."""
    path = g.modules.get(module)
    return bool(path) and os.path.isdir(path[: -len(".lean")])


measured = set()
for src in g.modules:
    if not src.startswith(LIB + "."):
        continue
    ls = layer_of(src)
    if ls is None or is_sibling_aggregator(src):
        continue
    for tgt in g.edges[src]:
        lt = layer_of(tgt)
        if lt is not None and lt > ls:
            measured.add((src, tgt))

surplus = sorted(measured - ALLOWLIST)
shortfall = sorted(ALLOWLIST - measured)

for s, t in surplus:
    print(f"SURPLUS    {s} -> {t}")
for s, t in shortfall:
    print(f"SHORTFALL  {s} -> {t}")

if not surplus and not shortfall:
    if ALLOWLIST:
        print(f"PASS  upward import set is exactly the recorded {len(ALLOWLIST)} line(s)")
        for s_, t_ in sorted(ALLOWLIST):
            print(f"      {s_} -> {t_}")
    else:
        print("PASS  zero upward import lines; the recorded allowlist is empty")
    sys.exit(0)

print(f"FAIL  upward import set is not the recorded allowlist "
      f"({len(surplus)} surplus, {len(shortfall)} shortfall)")
if surplus:
    print("      A surplus is a new upward edge. Relocate the module, or -- if the edge is")
    print("      genuinely correct -- change the layer table in")
    print("      scripts/measure-refactor-partitions.py and ORGANISATION.md together.")
if shortfall:
    print("      A shortfall is a finding, not a pass: it means an allowlisted line was removed")
    print("      (PUBLICATION_REFACTOR.md Phase 5 did this once, emptying the list). Confirm it landed")
    print("      deliberately, then delete the entry from ALLOWLIST above.")
sys.exit(1)
PYEOF

if [ "$CYCLES_STATUS" -eq 0 ] && [ "$LAYERS_STATUS" -eq 0 ]; then
  exit 0
fi
exit 1
