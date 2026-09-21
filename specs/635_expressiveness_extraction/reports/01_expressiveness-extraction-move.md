# Research Report: Expressiveness Extraction out of `WeakCanonical/`

**Task**: 635 - Extract the 141-file Expressiveness set into `Metalogic/Expressiveness/`
**Started**: 2026-09-21
**Completed**: 2026-09-21
**Effort**: large (two scripted commits, each build-green)
**Dependencies**: task 634 (landed; HEAD is `d3f912858`)
**Sources/Inputs**:
- Codebase at `d3f912858`, measured live (never copied from a document)
- `scripts/measure-refactor-partitions.py`, `scripts/move-modules.py`,
  `scripts/check-metalogic-cycles.sh`, `scripts/check-module-invariants.sh`,
  `scripts/typst-status-counts.sh`, `scripts/typst-sync-check.sh`, `scripts/readme-lint.sh`
- `docs/architecture/ADR-011-Extract-Expressiveness.md`,
  `docs/architecture/ADR-006-Metalogic-No-Physical-Regroup.md`,
  `docs/development/PUBLICATION_REFACTOR.md` Phase 6

**Artifacts**: - `specs/635_expressiveness_extraction/reports/01_expressiveness-extraction-move.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The pre-move gate passes at HEAD.** `python3 scripts/measure-refactor-partitions.py --check`
  exits **0**: `PASS Expressiveness set (141 files) has no edge into the residual WeakCanonical
  set (38 files) or BXCanonical`. All four counts in the task description re-measure correctly:
  141 moved files / 104,087 lines, residual 38 / 28,498 lines, 0 leaking edges, 0 modules
  reaching `BXCanonical` by closure.
- **The cycle count survives — proved by simulation, not argued.** Renaming the 141 modules and
  recomputing `check-metalogic-cycles.sh`'s assertion-A directory graph over the post-move names
  yields **exactly 1** cycle, still `BXCanonical <-> WeakCanonical` (now 5 lines each way, down
  from 9 and 5). `Metalogic/Expressiveness/` is a pure directory-level **sink**: 0 outgoing edges,
  incoming from `BXCanonical` and `WeakCanonical` only.
- **The measurement blind spot flagged by the orchestrator does NOT apply here.**
  `Metalogic/Expressiveness` has `top_dir == "Metalogic"`, so `layer_of` returns layer 3 and the
  directory is fully covered by `LAYERS`. Assertion B (upward edges) stays green with its empty
  allowlist; the simulation produced no new upward edge.
- **The `--namespace-map` question has a hard answer: exactly one namespace prefix is shared, and
  it cannot be mapped.** `FormalSystem.Metalogic.WeakCanonical` (the bare prefix) is declared by
  **29 of the 141 moved files and 28 of the 38 residual files**. A map row on that prefix is a
  repo-wide string rewrite that corrupts the residual set — demonstrably: the C14 baseline
  `'FormalSystem.Metalogic.WeakCanonical.countermodel_discrete'` (residual) and
  `'FormalSystem.Metalogic.WeakCanonical.uSExpressivelyCompleteOverPrior'` (moved) sit **two lines
  apart** in `scripts/check-module-invariants.sh` and are indistinguishable to a prefix rule.
- **The safe map is narrow; the remainder is a bounded hand-scripted edit.** Only
  `...WeakCanonical.Kamp` and `...WeakCanonical.Separation` are prefixes unique to the moved set.
  The bare-namespace remainder costs **29 `namespace`/`end` pairs + 104 `open` lines inside the
  moved tree + 10 `open` lines outside it + 8 FQN citations repo-wide** — small, enumerable, and
  verified below.
- **Regenerating `typst/generated` WITHOUT a one-line fix deletes a true statement.** Confirmed by
  running the generator: it rewrites `sorry-total = 4` to `0` and zeroes
  `("WeakCanonical/ (archived, Boneyard/Kamp/)", 4)`. Root cause found: `typst-status-counts.sh`
  `cd`s into `FormalSystem/` and then looks for `Boneyard/Kamp/KampWeakCanonical` **relative to
  that directory**, a path that stopped existing when the archive moved to the repository root.
  The committed `4` is correct — I recomputed it at the real path with the script's own
  comment-stripping methodology and got exactly **4**.
- **`--check` becomes vacuous the moment the move lands** and must be re-pointed in the same
  commit, or the standing gate ADR-011 promises silently passes on an empty set forever.

## Context & Scope

Phase 6 of `docs/development/PUBLICATION_REFACTOR.md`, accepting ADR-011. Two commits: a scripted
path-plus-namespace move of 141 modules, then content renames and stub deletion. The research
question was which of the move's mechanics are already safe, which are traps, and what the
`--namespace-map` option actually does to a shared prefix.

Everything below was measured at `d3f912858`. Nothing is quoted from a document without
re-deriving it.

## Findings

### 1. Pre-move gate and the four counts (re-measured at HEAD)

```
$ python3 scripts/measure-refactor-partitions.py --check
PASS  Expressiveness set (141 files) has no edge into the residual WeakCanonical set (38 files) or BXCanonical
EXIT=0
```

| Figure | Task description | Measured at HEAD | Agrees |
|---|---|---|---|
| Moved set | 141 files | 141 files / 104,087 lines | yes |
| Residual `WeakCanonical` | 38 files | 38 files / 28,498 lines | yes |
| Leaking edges | 0 (implied by exit 0) | 0 | yes |
| Cycle count | exactly 1 | 1 now; **1 after the move** (simulated) | yes |
| Paper-numbered files | 39 | **see §7 — not mechanically defined; a strict re-derivation gives 14 + 12** | **no** |

`residual lines` reads 28,498 against the 28,472 recorded in ADR-011 and in the measurement
script's own docstring. The script's header states the rule for this case explicitly ("Where a
document and this output disagree, this output is right"), so the two recorded 28,472 figures are
stale by 26 lines and should be refreshed in the same commit.

### 2. The cycle assertion after the move (simulated, not argued)

I renamed every module in the moved set (`WeakCanonical.X -> Expressiveness.X`, with
`WeakCanonical.Expressiveness -> Expressiveness.GameTransfer`) and recomputed
`check-metalogic-cycles.sh` assertion A's directory-level edge relation over the renamed graph,
reproducing its two deliberate exclusions (sibling aggregators excluded as sources, not as
targets).

```
POST-MOVE directory-level cycles in Metalogic/: 1
 CYCLE BXCanonical <-> WeakCanonical
   BXCanonical -> WeakCanonical: 5 lines
   WeakCanonical -> BXCanonical: 5 lines
Outgoing dir edges FROM Expressiveness: []
Incoming dir edges TO Expressiveness: ['BXCanonical', 'WeakCanonical']
```

Two consequences the plan should carry:

- The acceptance criterion holds. The cycle is unchanged in identity; only its
  `BXCanonical -> WeakCanonical` leg shrinks from 9 lines to 5, because 4 of
  `ChronicleMonadicBridge.lean`'s lines now point at `Expressiveness`.
- I explicitly checked the one way a new cycle could have appeared: **no moved file imports the
  bare `FormalSystem.Metalogic.WeakCanonical` aggregator** (0 of 141). This matters because
  `measure_weakcanonical`'s leak check excludes the aggregator from `resid_set`, so an
  aggregator import would have passed `--check` and still produced an
  `Expressiveness -> WeakCanonical` directory edge. It does not exist; the gate is sound here by
  luck confirmed, not by construction.

### 3. `LAYERS` coverage — the blind spot does not extend to this move

`layer_of` reads `parts[1]` of the module name. `FormalSystem.Metalogic.Expressiveness.Kamp.X`
gives `"Metalogic"`, which is in `LAYERS` at layer 3. The previous task's blind spot came from
directories placed at the **library root** (`MinusLanguage/`, `PlusLanguage/`, `StarLanguage/`),
which is not what happens here. The simulation produced no upward edge, so assertion B stays green
against its empty `ALLOWLIST`, and `measure-refactor-partitions.py upward-edges` continues to
report 0.

### 4. `--namespace-map`: what it does, and the one prefix that cannot be mapped

**Mechanics, read from source.** `NamespaceMapping.dotted_re` is
`(?<![A-Za-z0-9_.])<old_ns>(?![A-Za-z0-9_])`, applied by `rewrite_text` to **every line of every
file the walk reaches** — all `.lean`/`.md`/`.typ` anywhere outside `PRUNE_DIRS`, plus
`scripts/*.{sh,py,txt}`. It is not scoped to the moved files. The lookbehind rejects a preceding
`.`, and the lookahead does **not** reject a following `.`, so an entry is a prefix rule.

**The namespace census.** Declared `namespace` lines, counted per file across both sets:

| Namespace | Moved (141) | Residual (38) |
|---|---:|---:|
| `FormalSystem.Metalogic.WeakCanonical` | **29** | **28** |
| `FormalSystem.Metalogic.WeakCanonical.Kamp` | 105 | 0 |
| `FormalSystem.Metalogic.WeakCanonical.Separation` | 3 | 0 |
| `FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery` | 0 | 8 |
| `FormalSystem.Metalogic.BXCanonical.Chronicle` | 0 | 2 |
| local/unqualified (`Kamp`, `NegFixGateProbe`, `IsConvexEquiv`, …) | 6 | 7 |

**Exactly one prefix is shared: the bare `FormalSystem.Metalogic.WeakCanonical`.** The answer to
the dispatch question is therefore:

- The map **can** be written without touching the residual set, but only as the two narrow rows
  `...WeakCanonical.Kamp -> ...Expressiveness.Kamp` and
  `...WeakCanonical.Separation -> ...Expressiveness.Separation`.
- Those two rows leave **29 moved files still declaring `namespace
  FormalSystem.Metalogic.WeakCanonical`** while sitting under `Metalogic/Expressiveness/`, which
  ADR-011 Decision §1 forbids ("the fully-qualified prefix changes … for **every** declaration in
  the set") and which would add 29 entries to the namespace audit's `unrelated` bucket (today: 8,
  every one a recorded exception).
- There is **no namespace-granularity key** that renames the bare prefix for the moved files only.
  The finest safe key is the individual declaration FQN.

**Proof that the prefix row is unsafe** — the two C14 baselines, in the same file:

```
scripts/check-module-invariants.sh:1740  'FormalSystem.Metalogic.WeakCanonical.countermodel_discrete'          # RESIDUAL — must not change
scripts/check-module-invariants.sh:1781  'FormalSystem.Metalogic.WeakCanonical.Kamp.kampPriorExpressiveCompleteness'  # moved
scripts/check-module-invariants.sh:1782  'FormalSystem.Metalogic.WeakCanonical.uSExpressivelyCompleteOverPrior'       # MOVED — must change
```

`countermodel_discrete` is declared in `WeakCanonical/GroupModel/CountermodelBase.lean` (residual,
stays); `uSExpressivelyCompleteOverPrior` in `WeakCanonical/PriorExpressiveness.lean` (moves). A
prefix rule cannot separate them. (This also independently re-confirms the reconciliation note:
`GroupModel/CountermodelBase.lean` is residual, so the citation from task 412 does not drift.)

**Dry run with the narrow map** (`--dry-run`, nothing written):

```
class 1  import lines                369 occurrence(s) in  149 file(s)
class 2  dotted citations            638 occurrence(s) in  215 file(s)
class 3  slash-path citations        149 occurrence(s) in   27 file(s)
class 4  namespace/open/FQN            0 occurrence(s) in    0 file(s)
class 5  axiom baselines               2 occurrence(s) in    2 file(s)
class 6  tree moves                   13 path(s)
class 7  relative links                6 re-based in    6 file(s)
audit    bare-form occurrences        232 before,   232 after, in 65 file(s)
files changed                                        282
```

Two things to note. **Class 4 reads 0** because the module map's own `dotted_re` is the identical
string and consumes every occurrence first — the namespace map is redundant for the prefix
classes. But it is **not** optional: `baseline_re` in `rewrite_text` is gated on
`if ns_mappings`, so class 5's dedicated handling of the two axiom-baseline sites only runs when
a namespace map is supplied. Pass it. Only **2** of the 3 WeakCanonical baselines are rewritten —
the third is `uSExpressivelyCompleteOverPrior`, the bare-namespace gap.

### 5. Cost of completing the bare-namespace rename (the 29 files)

All measured:

| Edit | Count | Where |
|---|---:|---|
| `namespace FormalSystem.Metalogic.WeakCanonical` | 29 | the 29 moved files (perfectly paired) |
| `end FormalSystem.Metalogic.WeakCanonical` | 29 | same files, 29/29, no mismatch |
| `open FormalSystem.Metalogic.WeakCanonical` inside the moved tree | 104 lines in 104 files | rewrite to `...Expressiveness` |
| same, in the 38 residual files | 5 lines in 5 files | **keep, and add** the new open |
| same, elsewhere | 5 lines in 2 files (`BXCanonical/CompletenessDedekind.lean` ×4, `BXCanonical/Chronicle/ChronicleMonadicBridge.lean` ×1) | **keep, and add** the new open |
| FQN citations of moved bare-namespace declarations | **8** total | see below |

The 104 in-tree `open` rewrites are provably safe: `--check` guarantees no moved file imports a
residual module, so a bare `open` inside the moved tree can only ever resolve to declarations that
move together. Files outside the moved set import from **both** sides, so their bare `open` must
be kept and supplemented rather than rewritten.

The complete FQN citation set — 598 declarations live in those 29 files, but only 8 citations name
one by fully-qualified name anywhere in the repository:

```
6×  FormalSystem.Metalogic.WeakCanonical.uSExpressivelyCompleteOverPrior
      FormalSystem/MainResults.lean
      docs/architecture/ADR-011-Extract-Expressiveness.md
      docs/theorem-index.md
      scripts/check-module-invariants.sh
2×  FormalSystem.Metalogic.WeakCanonical.MonadicSignature
      Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean
      Boneyard/DeadChronicleGapElimination/GapElimination.lean
```

(One further site uses the primed `uSExpressivelyCompleteOverPrior'`; a per-declaration map entry
catches it too, because the class-4 lookahead `(?![A-Za-z0-9_])` permits a trailing `'`.)

Checked and **clear**, contrary to the standing hazard: `resolve_move`'s directory-over-file
preference does not bite. None of the 13 module-map rows names a stem that is both a directory and
a `.lean` file. The two such pairs that do exist — `Kamp/EANegationFix.lean` beside
`Kamp/EANegationFix/`, and `Kamp/NfMultiAnchorBridge.lean` beside `Kamp/NfMultiAnchorBridge/` —
are **inside** the `Kamp` subtree and travel in that one `git mv`. `WeakCanonical/Expressiveness/`
has no sibling `Expressiveness.lean`, so the `GameTransfer` row is a plain directory move.

### 6. "from X to Y" prose collapse — the concrete sites

The rewrite is a string substitution with no notion of tense, and two recorded historical
statements will be silently falsified:

- **`docs/architecture/ADR-011-Extract-Expressiveness.md:104`** — the *Today* column of "The two
  names that change". It holds `FormalSystem.Metalogic.WeakCanonical.Kamp.kampPriorExpressiveCompleteness`
  and would be rewritten to the *After* value, collapsing the table to `After | After`. This is
  the exact failure mode observed four times earlier in this run.
- **`docs/architecture/ADR-006-Metalogic-No-Physical-Regroup.md:40-43`** — four lines of a
  9-line historical cycle enumeration. Rewriting them produces a block headed
  `BXCanonical → WeakCanonical (9 import lines)` that lists `Expressiveness` targets, which is
  internally contradictory. ADR-011's own Consequences section already prescribes the correct
  treatment: those four lines *leave* the enumeration. My simulation independently confirms the
  post-move count is **5**, so the header must read 5 and the four lines must be **removed**, not
  rewritten.

`docs/development/PUBLICATION_REFACTOR.md`, `docs/development/MODULE_INVARIANTS.md` and
`ORGANISATION.md` carry **zero** dotted or slash citations of the moved set and are unaffected by
class 2/3. `docs/theorem-index.md` carries 1 dotted + 2 slash citations (rows 218-219), which the
rewrite handles correctly provided the bare-namespace rename lands in the same commit; C15's
anchor assertion will verify both rows.

### 7. The "39 paper-numbered files" has no mechanical definition

The figure comes from a hand-written inventory row (`PUBLICATION_REFACTOR.md:63`) and is not
produced by any script. Re-deriving it at HEAD with a strict pattern over the 141 moved leaf
names:

- **14** genuinely paper-numbered: `Expressiveness/{Claim1, Theorem6}`, `Kamp/{Lemma53,
  Lemma53Faithful, Lemma53FaithfulPast, Prop35Assembly, Prop35Chain, Prop35ExistsForall,
  Prop42Contentful, Prop42ExistsForall, Prop42Faithful, Prop42NegationGeneral, Prop42Vacuity,
  Prop43Translate}`
- **12** further history-suffixed: `Kamp/{EANegationFix, EFSatNegationGeneral,
  NfDepth0Generalized}`, `Kamp/EANegationFix/{BoundedFix, NegFix, VecEANegFix}`,
  `Kamp/NfMultiAnchorBridge/{AggregateOffDiagK1, AggregatePointMergeK1, ExteriorFiberKitK1,
  ExteriorNavFutK1, ExteriorNavPastK1, SubBracket2}`

Union: **26**, not 39. Widening the suffix pattern (`…Faithful`, `…Past`, `…K1` on more files)
pushes it up; the number is entirely pattern-dependent. Phase 6.2's scope must be an **explicit
enumerated list in the plan**, with the `39` in the inventory row corrected to whatever that list
holds.

**Declaration-free files** are, by contrast, mechanical — there are exactly **4** across all 179,
all in the moved set:

| Module | Lines | Note |
|---|---:|---|
| `Expressiveness.Theorem6` | 25 | true stub |
| `Kamp.EANegationFix` | 35 | true stub |
| `Kamp.Prop35ExistsForall` | 45 | true stub |
| `Kamp.NfMultiAnchorBridge` | 413 | **NOT a stub** — the sibling aggregator for `NfMultiAnchorBridge/`; C8 requires it to exist |

Deleting the fourth would break C8 and every importer. The plan must scope stub deletion to the
first three and say why the fourth is excluded.

### 8. `typst/generated` regeneration deletes a true statement (root cause found)

I ran `scripts/typst-status-counts.sh` and it rewrote `typst/generated/status.typ`
(since restored to HEAD content — the working tree is clean):

```
-#let sorry-total = 4
+#let sorry-total = 0
-  ("WeakCanonical/ (archived, Boneyard/Kamp/)", 4),
+  ("WeakCanonical/ (archived, Boneyard/Kamp/)", 0),
```

**Root cause.** The script `cd`s to `${BIMODAL_DIR}` (`FormalSystem/`) at line 43, then at line 120
runs `strip_and_count_sorries "Boneyard/Kamp/KampWeakCanonical"` — resolved as
`FormalSystem/Boneyard/Kamp/KampWeakCanonical`, which has not existed since the archive moved to
the repository root. `strip_and_count_sorries` returns `0` for a missing path by design, so the
breakage is silent.

**The committed 4 is the true value.** I recomputed it at the real path
`Boneyard/Kamp/KampWeakCanonical` (63 `.lean` files) using the script's own comment-stripping
routine and got exactly **4**.

**Fix** (one line, required *before* regenerating): resolve that one path against `${REPO_ROOT}`
rather than the current directory, e.g.
`SORRY_KAMP_BONEYARD=$(strip_and_count_sorries "${REPO_ROOT}/Boneyard/Kamp/KampWeakCanonical")`.
With it, regeneration is a no-op on both figures and `typst-sync-check.sh` Check 2 goes from
`MISMATCH_COUNT=2` to `0`.

### 9. Pre-existing red baselines (confirmed; not this task's to fix)

| Gate | State at HEAD | Effect of this task |
|---|---|---|
| `scripts/check-module-invariants.sh --no-build` | **green**, all 36 checks | must stay green |
| `scripts/readme-lint.sh` | FAIL, **21** broken refs | unchanged: 9 of the 21 live in READMEs this task moves, but every move preserves directory depth, so their `../../../Boneyard/…` targets resolve identically before and after. Count stays 21. |
| `scripts/typst-sync-check.sh` Check 1 | FAIL, **9** violations, all `docs/training/PIPELINE.md` (the directory does not exist) | untouched; this gate cannot go fully green in this task |
| `scripts/typst-sync-check.sh` Check 2 | FAIL, 2 mismatches | **fixable here** via §8 |
| C20 `file.lean:NNN` citations | green, 1030 tier-1 citations | low risk: only **1** such citation points into the moved tree, and class-1 import rewrites are 1-for-1 line replacements that shift nothing. Adding `open` lines to outside files does shift — keep those additions below any cited line, or re-check C20. |

### 10. Work the move tool does *not* do

- **`FormalSystem/Metalogic/WeakCanonical/README.md` carries ~19 bare-form citations of the moved
  names** (`Kamp/`×2, `EFGames/`×3, `Separation/`×3, `Expressiveness/`×2, and one each for the
  nine single modules). `move-modules.py` deliberately leaves bare-form citations alone — that is
  what the `232 before, 232 after` audit line asserts — so these become dangling the moment the
  subtrees leave, and C5/C12/C13 (all green today) will go red. This README must be rewritten by
  hand in the same commit, and a new `FormalSystem/Metalogic/Expressiveness/README.md` authored.
- **`FormalSystem/Metalogic/WeakCanonical.lean` holds exactly 14 imports into the moved set**
  (lines 11, 13-17, 19-23, 27-29 of 40). The tool rewrites them in place, leaving a sibling
  aggregator importing a *sibling directory's* contents. They must be **moved** into a new
  `FormalSystem/Metalogic/Expressiveness.lean`, which `FormalSystem/Metalogic.lean` must then
  import (it currently has 13 imports, one of them `...WeakCanonical`). C8 requires the new
  aggregator to exist; C6 requires any module left unreachable to be manifested.
- **`--check` becomes vacuous.** After the move, `g.under(WEAK)` finds only the residual 38, so
  `expr` is empty, `leaking_edges` is empty, and `--check` prints
  `PASS Expressiveness set (0 files) …` and exits 0 forever. ADR-011 Consequences promises it
  "becomes a standing pre-move gate"; to honour that, `WEAK`/`EXPRESSIVENESS_SET` must be
  re-pointed at `Metalogic.Expressiveness` in the same commit (or the check given an explicit
  empty-set failure branch). Note the acceptance criterion "residual set at 38 files" is satisfied
  either way — including degenerately — so it cannot be relied on to catch this.

## Decisions

1. **Recommend ADR-011's full rename (Option A), not the reduced one.** Leaving the bare namespace
   alone would be cheap, but it strands `uSExpressivelyCompleteOverPrior` — one of the two
   headline names ADR-011 exists to fix — under a `WeakCanonical` FQN, and adds 29 `unrelated`
   entries to the namespace audit. The cost of doing it properly is bounded and enumerated in §5.
2. **The `--namespace-map` file carries two rows only** (`Kamp`, `Separation`). Everything on the
   bare prefix is done by a separate, explicitly scoped script step after the `git mv`, when the
   29 files are already under `Metalogic/Expressiveness/` and a path-scoped edit can no longer
   reach the residual set.
3. **`--namespace-map` is still passed**, despite class 4 reading 0, because class 5's
   axiom-baseline handling is gated on its presence.
4. **Fix `typst-status-counts.sh` before regenerating**, not after. Regenerating first commits a
   false zero.
5. **Enumerate Phase 6.2's rename list explicitly in the plan.** The `39` is not reproducible.
6. **Stub deletion covers 3 files, not 4.** `Kamp/NfMultiAnchorBridge.lean` is an aggregator.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| A prefix namespace row corrupts residual declarations | Never write `FormalSystem.Metalogic.WeakCanonical` as a map key. After the run, assert `grep -c 'FormalSystem\.Metalogic\.WeakCanonical\.countermodel_discrete' scripts/check-module-invariants.sh` is still 1. |
| ADR-011:104 and ADR-006:40-43 silently falsified | Snapshot both files before the tool runs and restore/hand-edit them after; ADR-006's block becomes 5 lines, ADR-011's *Today* column is restored verbatim. |
| Regenerated `status.typ` publishes a false sorry count | §8 one-line fix first; verify `typst-sync-check.sh` Check 2 reads `MISMATCH_COUNT=0`. |
| `check-metalogic-cycles.sh` reads 0 or 2 | Simulated result is 1. If it reads otherwise, the discrepancy is in the aggregator wiring (§10), not in the module partition. |
| `lake build` green but an exe root broken | Run the **build-inclusive** `check-module-invariants.sh` (C25) after each of the two commits, not `lake build` alone. `--no-build` is green at HEAD and is the correct fast inner-loop gate, but it does not cover C2/C14 axiom pinning or C25. |
| Residual README left dangling | C5/C12/C13 will catch it; rewrite `WeakCanonical/README.md` and author `Expressiveness/README.md` inside commit 1. |
| `open` insertions shift C20 line citations | Only 1 `file.lean:NNN` citation points into the moved tree; re-run C20 after the outside-file `open` additions. |

## Tactic Survey Results

- Not applicable (no Lean proof goals were investigated; this task is a structural relocation with
  no proof obligations).

## Context Extension Recommendations

- **Topic**: `move-modules.py` namespace-map semantics on a shared prefix.
  **Gap**: three tasks in this run have now independently re-derived that `--namespace-map` is a
  repo-wide prefix rewrite with no file scoping, each at the cost of reading the source.
  **Recommendation**: add a "Shared-prefix rule" paragraph to the tool's own module docstring,
  beside the existing "bare-token trap" section — a map key must be a prefix that no file
  remaining in place declares, and the finest safe key is a declaration FQN.
- **Topic**: generator paths after the archive relocation.
  **Gap**: `typst-status-counts.sh` silently returned 0 for a path that stopped existing; the same
  `cd`-then-relative-path shape appears elsewhere in `scripts/`.
  **Recommendation**: a short audit item in `docs/development/MODULE_INVARIANTS.md` — any
  generator path outside the `cd` target must be anchored at `${REPO_ROOT}`, and a missing-path
  zero should warn rather than pass silently.

## Appendix

### Commands run

```bash
python3 scripts/measure-refactor-partitions.py --check              # exit 0, 141/38
python3 scripts/measure-refactor-partitions.py                      # full four-measurement report
python3 scripts/move-modules.py --module-map … --namespace-map … --dry-run
bash scripts/check-module-invariants.sh --no-build                  # green, 36 checks
bash scripts/typst-sync-check.sh                                    # 9 + 2 pre-existing failures
bash scripts/typst-status-counts.sh                                 # regenerated status.typ (restored)
bash scripts/readme-lint.sh                                         # 21 broken refs, pre-existing
```

Four purpose-built measurement scripts were written to the session scratchpad (post-move cycle
simulation, namespace census, FQN citation census, `open`/`end` pairing census). They are
throwaway; every figure they produced is reproduced in this report.

### Module map used for the dry run

```
FormalSystem.Metalogic.WeakCanonical.Expressiveness -> FormalSystem.Metalogic.Expressiveness.GameTransfer
FormalSystem.Metalogic.WeakCanonical.Kamp -> FormalSystem.Metalogic.Expressiveness.Kamp
FormalSystem.Metalogic.WeakCanonical.EFGames -> FormalSystem.Metalogic.Expressiveness.EFGames
FormalSystem.Metalogic.WeakCanonical.Separation -> FormalSystem.Metalogic.Expressiveness.Separation
FormalSystem.Metalogic.WeakCanonical.NormalForm -> FormalSystem.Metalogic.Expressiveness.NormalForm
FormalSystem.Metalogic.WeakCanonical.MonadicFO -> FormalSystem.Metalogic.Expressiveness.MonadicFO
FormalSystem.Metalogic.WeakCanonical.StaviConnectives -> FormalSystem.Metalogic.Expressiveness.StaviConnectives
FormalSystem.Metalogic.WeakCanonical.PriorDefs -> FormalSystem.Metalogic.Expressiveness.PriorDefs
FormalSystem.Metalogic.WeakCanonical.PriorDefsDense -> FormalSystem.Metalogic.Expressiveness.PriorDefsDense
FormalSystem.Metalogic.WeakCanonical.PriorExpressiveness -> FormalSystem.Metalogic.Expressiveness.PriorExpressiveness
FormalSystem.Metalogic.WeakCanonical.PriorExpressivenessDense -> FormalSystem.Metalogic.Expressiveness.PriorExpressivenessDense
FormalSystem.Metalogic.WeakCanonical.Table -> FormalSystem.Metalogic.Expressiveness.Table
FormalSystem.Metalogic.WeakCanonical.EFGameTactics -> FormalSystem.Metalogic.Expressiveness.EFGameTactics
```

Namespace map (two rows only):

```
FormalSystem.Metalogic.WeakCanonical.Kamp -> FormalSystem.Metalogic.Expressiveness.Kamp
FormalSystem.Metalogic.WeakCanonical.Separation -> FormalSystem.Metalogic.Expressiveness.Separation
```

### References

- `docs/architecture/ADR-011-Extract-Expressiveness.md` — Decision §§1-6, "The two names that change"
- `docs/architecture/ADR-006-Metalogic-No-Physical-Regroup.md` — the cycle enumeration at lines 34-50
- `docs/development/PUBLICATION_REFACTOR.md` — Phase 6.1/6.2 and inventory row 4b
- `scripts/move-modules.py` — `classes_for`, `rewrite_text`, `NamespaceMapping`, `resolve_move`, `move_trees`
- `scripts/measure-refactor-partitions.py` — `LAYERS`, `EXPRESSIVENESS_SET`, `measure_weakcanonical`, `--check`
- `scripts/check-metalogic-cycles.sh` — assertions A and B
- `scripts/typst-status-counts.sh:43,119-121` — the `cd` and the mis-rooted archive path
