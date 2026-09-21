#!/usr/bin/env bash
# check-metalogic-cycles.sh
#
# THREE ASSERTIONS BEHIND ONE EXIT CODE:
#
#   A. FormalSystem/Metalogic/ contains exactly ONE directory-level import cycle.
#   B. The library-wide UPWARD import set equals a recorded 7-line allowlist.
#   C. Inside the language directories, no syntax module imports a semantics module.
#
# A and B are independent: A is a single-subtree cycle claim, B is a whole-library layer-order
# claim. C is implied by B today and is asserted separately on purpose (see its section below).
# The script exits 0 only when all three hold, and prints the result of all three before exiting.
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
#   does -- `layer_of` and the two tables behind it (`LAYERS`, `LANGUAGE_FILE_LAYERS`) in
#   scripts/measure-refactor-partitions.py, loaded by importlib so there is exactly one copy of
#   those tables in the repository, and scripts/lib/import_graph.py's leading-
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
#   shortfall means an allowlisted line is no longer measured, which someone should confirm
#   rather than have silently absorbed.
#
#   THE ALLOWLIST HOLDS 7 LINES, all `FormalSystem.MinusLanguage.AxiomDischarge` (layer 0) importing
#   a `Theorems` module (layer 2). They are recorded, not excused. The same 7 lines were recorded
#   under the file's old path, `Syntax/MinusLanguage/AxiomDischarge.lean`, until the
#   language-extension merge (docs/development/PUBLICATION_REFACTOR.md Phase 5) moved the file
#   into a directory the layer table did not cover; the list then read empty because the edges
#   had stopped being measured, not because one of them had turned downward. Two mechanisms now
#   keep that from recurring:
#
#     * THE LANGUAGE DIRECTORIES ARE LAYERED PER FILE. `MinusLanguage/`, `PlusLanguage/` and
#       `StarLanguage/` each hold syntax, proof system and semantics (`OpenLanguage/`,
#       `HybridLanguage/` and `QuantLanguage/`, created after the merge, hold syntax and
#       semantics only), so no single layer fits
#       them; `LANGUAGE_FILE_LAYERS` in the measurement script gives every file the layer of the
#       directory it occupied before the merge (0, 1, or 3 for `MinusLanguage/Soundness.lean`).
#     * THE LOOKUP FAILS LOUDLY. `layer_of` raises for any module under `FormalSystem/` that
#       matches no row -- a new top-level directory, or a new file in a language directory -- and
#       this assertion prints that as a `FAIL` line naming the module and the table that needs
#       the row. A per-file row whose file has gone is reported as a `STALE ROW` and fails too,
#       so the table cannot drift in either direction.
#
# ASSERTION C -- SYNTAX BEFORE SEMANTICS INSIDE A LANGUAGE DIRECTORY:
#   Before the merge the directory boundary enforced this: nothing under a language's `Syntax/`
#   directory imported anything from `Semantics/`. With both halves in one directory nothing
#   structural does, so it is asserted: no layer-0 file of `LANGUAGE_FILE_LAYERS` imports a
#   layer-1 file of any of the language directories, nor anything under
#   `FormalSystem.Semantics`. It has a non-vacuity guard (either set empty is a failure).
#
#   Under the per-file layering such an import is already a SURPLUS line in assertion B. C exists
#   anyway so that the failure names the invariant, and so that it survives a future allowlist
#   entry that would otherwise absorb such a line.
#
# NOT WIRED INTO check-module-invariants.sh, deliberately: that harness is the phase gate for the
# whole tree, and these are standalone structural assertions with their own exit code. Run it
# directly. It is catalogued in docs/development/MODULE_INVARIANTS.md and cited by
# FormalSystem/Metalogic/README.md.
#
# Exit codes: 0 all three assertions hold; 1 any fails. Assertion A fails on any cycle count other
# than one (including zero -- a zero would mean the documented BXCanonical <-> WeakCanonical pair
# vanished, which is a finding, not a silent pass). Assertion B fails on any surplus or shortfall
# against the allowlist, on an unlayered module, and on a stale per-file row. Assertion C fails on
# any syntax-to-semantics import line and on an empty syntax or semantics set.

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
LIB, layer_of = _measure.LIB, _measure.layer_of

# The recorded allowlist: 7 lines, all from `FormalSystem.MinusLanguage.AxiomDischarge`
# (layer 0 by its pre-merge origin, `Syntax/MinusLanguage/`) into `Theorems` (layer 2).
# They are recorded, not excused: the file discharges the Minus axioms through derived
# theorems of the base logic, and relocating it is separate work.  Every entry is derived
# by running `measure-refactor-partitions.py upward-edges`, never hand-copied from a plan.
_SRC = "FormalSystem.MinusLanguage.AxiomDischarge"
ALLOWLIST = frozenset((_SRC, "FormalSystem.Theorems." + t) for t in (
    "Combinators",
    "DedekindDerived",
    "DeductionTheorem",
    "DiscreteUnfolding",
    "GeneralizedNecessitation",
    "Propositional.Core",
    "TemporalDerived",
))

g = ImportGraph()


def is_sibling_aggregator(module):
    """``FormalSystem.Metalogic.Core`` with ``Metalogic/Core/`` beside it -- excluded
    as an edge source (see this script's header)."""
    path = g.modules.get(module)
    return bool(path) and os.path.isdir(path[: -len(".lean")])


# `layer_of(src)` is evaluated BEFORE the aggregator exclusion, for every library module, so a
# module with no row raises here even when it is an aggregator and would otherwise be skipped.
measured = set()
try:
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
except _measure.UnlayeredModuleError as e:
    print(f"FAIL  unlayered module `{e.module}`: {e.table} has no row `{e.missing_row}`")
    print("      A module with no layer contributes no edge in either direction, so the upward set")
    print("      below it would be measured on a partial graph. Add the row in")
    print("      scripts/measure-refactor-partitions.py and ORGANISATION.md together, then re-run.")
    sys.exit(1)

stale = _measure.stale_language_rows(g)
surplus = sorted(measured - ALLOWLIST)
shortfall = sorted(ALLOWLIST - measured)

for m in stale:
    print(f"STALE ROW  {m}")
if stale:
    print(f"FAIL  {len(stale)} per-file layer row(s) name a module that does not exist")
    print("      The file was renamed, moved or deleted and its LANGUAGE_FILE_LAYERS row in")
    print("      scripts/measure-refactor-partitions.py stayed behind. Delete or rename the row.")

for s, t in surplus:
    print(f"SURPLUS    {s} -> {t}")
for s, t in shortfall:
    print(f"SHORTFALL  {s} -> {t}")

if not surplus and not shortfall and not stale:
    if ALLOWLIST:
        print(f"PASS  upward import set is exactly the recorded {len(ALLOWLIST)} line(s)")
        for s_, t_ in sorted(ALLOWLIST):
            print(f"      {s_} -> {t_}")
    else:
        print("PASS  zero upward import lines; the recorded allowlist is empty")
    sys.exit(0)

if surplus or shortfall:
    print(f"FAIL  upward import set is not the recorded allowlist "
          f"({len(surplus)} surplus, {len(shortfall)} shortfall)")
if surplus:
    print("      A surplus is a new upward edge. Relocate the module, or -- if the edge is")
    print("      genuinely correct -- change the layer table in")
    print("      scripts/measure-refactor-partitions.py and ORGANISATION.md together.")
if shortfall:
    print("      A shortfall is a finding, not a pass: an allowlisted line is no longer measured.")
    print("      Either the import was removed, or its source or target stopped being measured -- a")
    print("      file move once emptied this list that way without turning one edge downward. Confirm")
    print("      which, and delete the entry from ALLOWLIST above only for a removed import.")
sys.exit(1)
PYEOF

# ---------------------------------------------------------------------------
# Assertion C: inside the language directories, no syntax module imports a semantics module
# ---------------------------------------------------------------------------

echo
SYNTAX_STATUS=0
python3 - <<'PYEOF' || SYNTAX_STATUS=$?
import importlib.util
import os
import sys

root = os.getcwd()
sys.path.insert(0, os.path.join(root, "scripts", "lib"))
from import_graph import ImportGraph  # noqa: E402

# The same single copy of the per-file table assertion B reads, loaded the same way.
_spec = importlib.util.spec_from_file_location(
    "_measure_refactor_partitions",
    os.path.join(root, "scripts", "measure-refactor-partitions.py"),
)
_measure = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_measure)
LIB, TABLE = _measure.LIB, _measure.LANGUAGE_FILE_LAYERS

g = ImportGraph()

# Both language-directory sets are read off the table AND intersected with the import graph, so
# a directory that moved away leaves them empty and trips the guard below instead of passing.
# Sibling aggregators have no row in the table, so they are never a source here either.
syntax = {f"{LIB}.{d}.{leaf}" for d, rows in TABLE.items() for leaf, n in rows.items() if n == 0}
lang_semantics = {f"{LIB}.{d}.{leaf}" for d, rows in TABLE.items() for leaf, n in rows.items() if n == 1}
syntax &= set(g.modules)
lang_semantics &= set(g.modules)
SEM = f"{LIB}.Semantics"


def is_semantics(module):
    return module in lang_semantics or module == SEM or module.startswith(SEM + ".")


# An empty set makes the assertion vacuously true -- the same degenerate-partition failure the
# measurement script's --check branch guards against.  Fail loudly instead.
if not syntax or not lang_semantics:
    print(f"FAIL  degenerate syntax-before-semantics sets: {len(syntax)} language-directory syntax "
          f"module(s), {len(lang_semantics)} language-directory semantics module(s); neither may be empty.")
    print("      The sets are the layer-0 and layer-1 rows of LANGUAGE_FILE_LAYERS in")
    print("      scripts/measure-refactor-partitions.py that still name a live file. Re-point the")
    print("      table rather than accepting the PASS.")
    sys.exit(1)

violations = sorted((s, t) for s in syntax for t in g.edges[s] if is_semantics(t))
for s, t in violations:
    print(f"SYNTAX->SEMANTICS  {s} -> {t}")

if not violations:
    print(f"PASS  no language-directory syntax module imports a semantics module "
          f"({len(syntax)} syntax modules, {len(lang_semantics)} language-directory semantics modules "
          f"plus everything under {SEM})")
    sys.exit(0)

print(f"FAIL  syntax before semantics: {len(violations)} import line(s) from a language-directory "
      f"syntax module into a semantics module")
print("      Inside MinusLanguage/, PlusLanguage/, StarLanguage/, OpenLanguage/, HybridLanguage/ and")
print("      QuantLanguage/ the syntax and proof-system")
print("      files must not import a semantics file of any language, nor anything under")
print("      FormalSystem/Semantics/. Move the declaration that needs the import into a semantics")
print("      file; or, if the source file really is a semantics file, reclassify it in")
print("      LANGUAGE_FILE_LAYERS (scripts/measure-refactor-partitions.py) and ORGANISATION.md together.")
sys.exit(1)
PYEOF

if [ "$CYCLES_STATUS" -eq 0 ] && [ "$LAYERS_STATUS" -eq 0 ] && [ "$SYNTAX_STATUS" -eq 0 ]; then
  exit 0
fi
exit 1
