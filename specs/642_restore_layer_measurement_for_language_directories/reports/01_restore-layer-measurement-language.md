# Research Report: Task #642

**Task**: 642 - Restore layer measurement for the language directories
**Started**: 2026-09-21T18:00:27Z
**Completed**: 2026-09-21T18:06:04Z
**Effort**: 2-3 hours of implementation (two scripts, seven document groups, three hand negative tests)
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `scripts/measure-refactor-partitions.py`, `scripts/check-metalogic-cycles.sh`,
  `scripts/lib/import_graph.py`, `ORGANISATION.md`, `docs/ARCHITECTURE.md`,
  `docs/development/{PUBLICATION_REFACTOR,MODULE_INVARIANTS}.md`, `scripts/README.md`, the three
  language-directory READMEs
- Git history: merge commit `e2b646c84` (rename table for every moved file)
- Archived artifacts: task 633 and task 634 summaries
- Three read-only prototype measurements run against the live import graph (no repository file
  was modified)
**Artifacts**:
- `specs/642_restore_layer_measurement_for_language_directories/reports/01_restore-layer-measurement-language.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **No single per-directory layer is consistent with the tree.** Measured for every candidate
  layer L assigned to all three language directories: L=0 gives 23 upward lines, L=1 gives 9,
  L=2 gives 5, L=3 gives 3. The constraints are contradictory (`MinusLanguage/Soundness.lean`
  imports `Metalogic/`, which needs L >= 3; `Semantics/DeterministicBridge.lean` and
  `Semantics/StateLocalTransfer.lean` import language files, which needs L <= 1). The
  per-file sub-layer is the only honest option, and this is a measured result rather than a
  preference.
- **The directories hold three sub-layers, not two.** The task description names syntax and
  semantics; `MinusLanguage/Soundness.lean` came from `Metalogic/Conservativity/` and imports two
  `Metalogic` modules. A two-way syntax/semantics split would put it at layer 1 and manufacture 2
  upward lines.
- **Recommended classification rule: each file keeps the layer of the directory it occupied
  before the merge**, read off commit `e2b646c84`'s rename table. It is mechanical, it cannot be
  tuned to make an edge disappear, and it agrees file-for-file with the "Syntax before semantics"
  lists the three language READMEs already carry.
- **Prototyped result under that rule: exactly 7 upward lines, all
  `FormalSystem.MinusLanguage.AxiomDischarge -> FormalSystem.Theorems.*`, and nothing else.** No
  additional finding surfaces. The intra-directory syntax-imports-semantics set is empty today.
- **Deliverable (4) is subsumed by deliverable (2) under the per-file scheme** — a syntax file
  (0) importing a semantics file (1) *is* an upward edge — and the per-file scheme is strictly
  stronger than the task-634 grep, because it also catches a cross-language case
  (`StarLanguage` syntax importing `PlusLanguage` semantics). A separately named assertion is
  still worth adding so its failure message names the invariant.
- **Fail-loud needs two levels**: an unknown top-level directory, *and* an unlisted file inside a
  language directory. It also forces rows for `FormalSystem/MainResults.lean` and
  `FormalSystem/Version.lean`, the only two other `None` paths under `FormalSystem/`.
- **One stale design statement contradicts the task.** `PUBLICATION_REFACTOR.md` Phase 5 says
  the `AxiomDischarge` imports "become ordinary downward edges from an extension language to the
  base logic". The measurement refutes that reading (see L=2 and L=3 above). It is outside the
  task's named document list and should be corrected alongside it.

## Context & Scope

The task asks for a layering decision for `FormalSystem/{Plus,Minus,Star}Language/`, an extension
of `LAYERS`/`layer_of` that fails loudly, a re-derived allowlist, an intra-directory
syntax-before-semantics assertion, hand negative tests, and document updates. This research
establishes what the tree actually contains, measures each candidate design against it, and
prototypes the recommended design end to end on an in-memory copy of the import graph.

Constraint observed throughout: nothing under the repository was edited. All three prototypes
live in the session scratchpad and read the graph through `scripts/lib/import_graph.py`, the same
parser both scripts use, so the figures below are the figures the implementation will see.

## Findings

### Codebase Patterns

**How the blind spot works.** `layer_of` (`scripts/measure-refactor-partitions.py:172`) is
`LAYERS.get(top_dir(module))`. `LAYERS` has ten keys; the three language directories are not among
them, so `layer_of` returns `None`. `measure_upward_edges` skips a `None` source
(`:193`) and a `None` target (`:197`). Assertion B in `scripts/check-metalogic-cycles.sh` loads
the same `layer_of` by path (`:160`) and has the same two skips (`:185`, `:189`). One table, one
function, two consumers — so one fix repairs both, which is the property the scripts' headers say
they were built for.

**The complete `None` set under `FormalSystem/`.** Measured: the 33 language-directory modules
(30 files plus 3 sibling aggregators), `FormalSystem.MainResults` and `FormalSystem.Version`.
Nothing else. The root `FormalSystem` module is `FormalSystem.lean` at the repository root, not
under `FormalSystem/`, so it is outside the acceptance criterion.

- `MainResults` imports `Metalogic` and `Semantics` and is imported only by the root.
- `Version` imports `Init` and is imported only by the root.

Giving them rows (`MainResults: 4`, `Version: 0`) adds no upward edge — verified in the
prototype, which carried both rows and still measured 7.

**The origin table** (from `git show -M --name-status e2b646c84`):

| Pre-merge directory | Layer | Files |
|---|---|---|
| `Syntax/MinusLanguage/` | 0 | `Formula`, `Translation`, `Axioms`, `Derivation`, `AxiomDischarge` |
| `Syntax/PlusLanguage/` | 0 | `Formula`, `Axioms`, `Derivation`, `Substitution` |
| `Syntax/StarLanguage/` | 0 | `Formula`, `Axioms`, `Derivation`, `Embedding` |
| `Semantics/MinusLanguage/` | 1 | `MinusFrame`, `MinusTruth`, `MinusValidity`, `MinusSchemaValidity` |
| `Semantics/PlusLanguage/` | 1 | `PlusTruth`, `PlusValidity`, `PlusDeterminism`, `PlusLimitClosure`, `PlusNonValidities`, `PlusPasting`, `PlusStateLocal` |
| `Semantics/StarLanguage/` | 1 | `StarTruth`, `StarValidity`, `StarDeterminism`, `StarNonValidities`, `StarStateLocal` |
| `Metalogic/Conservativity/` (as `MinusLanguageSoundness.lean`) | 3 | `MinusLanguage/Soundness` |

30 files, 13 + 16 + 1. Two cross-checks agree with it. First, the "Syntax before semantics"
section of each language README names exactly the layer-0 files above as its syntax half.
Second, a naming regularity holds: every layer-1 file carries its language's name as a prefix
(`PlusTruth`, `MinusFrame`, `StarValidity`), and every unprefixed file is layer 0 — with
`Soundness` as the one exception, which is why a prefix heuristic must not replace the table.

One disagreement to resolve in the documents: `FormalSystem/MinusLanguage/README.md` lists
`Soundness.lean` in its *semantic modules* table. By origin and by imports it is a metalogic
module; at layer 1 it would show 2 upward lines.

**Measured single-layer alternatives** (aggregator sources excluded, as assertion B does):

| Directory layer L | Upward lines | Classes |
|---|---|---|
| 0 | 23 | language -> `Semantics` 14, `MinusLanguage` -> `Theorems` 7, `MinusLanguage` -> `Metalogic` 2 |
| 1 | 9 | `MinusLanguage` -> `Theorems` 7, `MinusLanguage` -> `Metalogic` 2 |
| 2 | 5 | `MinusLanguage` -> `Metalogic` 2, `Semantics` -> `PlusLanguage` 2, `Semantics` -> `StarLanguage` 1 |
| 3 | 3 | `Semantics` -> `PlusLanguage` 2, `Semantics` -> `StarLanguage` 1 |

The three `Semantics` -> language lines are `DeterministicBridge -> PlusLanguage.PlusDeterminism`,
`StateLocalTransfer -> PlusLanguage.PlusStateLocal` and
`StateLocalTransfer -> StarLanguage.StarStateLocal`. Under the per-file scheme all three are
intra-layer (1 -> 1), which matches what the Plus README says about them: cross-language bridges
that "stay at the `Semantics/` root".

**Prototype of the recommended design** (in-memory, live graph):

| Run | Result |
|---|---|
| Baseline upward set | 7 lines, all `MinusLanguage.AxiomDischarge -> Theorems.{Combinators, DedekindDerived, DeductionTheorem, DiscreteUnfolding, GeneralizedNecessitation, Propositional.Core, TemporalDerived}` |
| Baseline syntax-imports-semantics set | empty |
| Table rows without a file / files without a row | none / none, all three directories |
| Simulated surplus: `PlusLanguage.Formula` imports `PlusLanguage.PlusTruth` | reported by the upward set *and* by the named assertion |
| Simulated shortfall: drop `AxiomDischarge -> Theorems.TemporalDerived` | reported as shortfall |
| `layer_of("FormalSystem.PlusLanguage.Brand")` | raises, naming the missing per-file row |
| `layer_of("FormalSystem.NewDir.Thing")` | raises, naming the missing `LAYERS` row |
| `layer_of` on `Mathlib.*`, `BimodalTest.*`, root `FormalSystem` | `None`, as today |

The simulated runs are not the task's negative tests — those must be real file edits observed
through the real scripts — but they show the design produces both failure directions.

**A difference between the two consumers, currently harmless.** `measure_upward_edges` counts
sibling aggregators as edge sources; assertion B excludes them. The two agreed on "7" only
because no aggregator had an upward import. A language aggregator imports both layer-0 and
layer-1 files, so it needs a declared layer of its own; at layer 1 it contributes nothing in
either script. (`MinusLanguage.lean` does not import `Soundness`, and cannot: `Soundness` imports
`Metalogic.Conservativity.Backward`, which imports the aggregator.)

### External Resources

None needed. The question is entirely about this repository's own measurement; no external
convention bears on it.

### Recommendations

1. **Layering decision: per-file sub-layer, keyed on pre-merge origin.** Record the reason as the
   measured table above — every per-directory layer yields a non-empty upward set that reflects
   the choice of number rather than the tree.

2. **Shape of the change in `measure-refactor-partitions.py`:**
   - Add `Version: 0` and `MainResults: 4` to `LAYERS`.
   - Add a second table, keyed by language directory then by file leaf, holding the 30 rows
     above, plus one declared layer for the three sibling aggregators (1).
   - Rewrite `layer_of` to return `None` only for a module that is not under `FormalSystem/`
     (first component is not `FormalSystem`, or it is the bare root), and to **raise** a dedicated
     exception otherwise when no row matches — with a message naming the module and which table
     lacks the row.
   - Keep the `if ls is None: continue` guards; they now only ever fire for non-library modules.
   - Add a stale-row report (a table row whose file no longer exists), in the same spirit as
     assertion B's shortfall branch.
   - Rewrite the module docstring's "Measured on the tree" block and remove its CAVEAT paragraph.

3. **`check-metalogic-cycles.sh`:** restore `ALLOWLIST` to the 7 measured lines under their new
   module names, derived by running `upward-edges`, not copied from this report. Add a third
   assertion for syntax-before-semantics with its own PASS/FAIL line and its own status variable
   feeding the single exit code. Rewrite the header, which currently describes two assertions and
   an empty allowlist.

4. **Negative tests, by hand, reverted afterwards** (both are text-only; the import parser reads
   the leading import block, so no build is needed):
   - Surplus: add `import FormalSystem.PlusLanguage.PlusTruth` to
     `FormalSystem/PlusLanguage/Formula.lean`. Expect a SURPLUS line and the new assertion's FAIL.
     (In Lean this line would be an import cycle; that is immaterial, because nothing is built
     while it is in place.)
   - Shortfall: delete `import FormalSystem.Theorems.TemporalDerived` from
     `FormalSystem/MinusLanguage/AxiomDischarge.lean`. Expect a SHORTFALL line.
   - Fail-loud: create an empty `FormalSystem/PlusLanguage/Scratch.lean`, observe the raise,
     delete it.
   - Revert by reverse edit, then confirm with `git diff --quiet -- <path>`. The repository's
     destructive-git guard blocks `git checkout -- <path>` on a dirty tree, and the tree is dirty
     (a sibling task has uncommitted work), so a checkout-based revert will be refused.

5. **Documents to update** — the task names two; the measurement is recorded in seven:

   | File | What is stale |
   |---|---|
   | `ORGANISATION.md` | "measured upward set is now empty"; the whole "sit outside this table" subsection; layer table lacks the per-file rows, `MainResults`, `Version` |
   | `docs/ARCHITECTURE.md` | the "Outside the stack / unmeasured / 0 lines" box in the diagram; "The upward set is empty — and what that now hides"; the `Syntax/` table row saying the family is "outside the layer table". Its "Verifying this page" block already says 7 and becomes true again |
   | `docs/development/MODULE_INVARIANTS.md` | assertion B prose already says 7 lines from the new path (correct after the fix); needs the third assertion and the fail-loud behaviour described |
   | `docs/development/PUBLICATION_REFACTOR.md` | the measurement-table row "0 since Phase 5 landed"; Phase 5's "become ordinary downward edges" bullet, which the measurement refutes |
   | `scripts/README.md` | says "7-line allowlist" (correct after the fix) and "two independent assertions" (becomes three) |
   | `README.md` | the Architecture link text says "its two upward edges" — matches neither 0 nor 7 |
   | The three language READMEs and aggregator docstrings | each says "No mechanical check enforces it"; `MinusLanguage/README.md` files `Soundness.lean` under semantic modules |

6. **Deliverable-text rule.** None of the script or document edits may cite a task number; the
   repository's write-time gate blocks it. The current text already uses durable anchors ("the
   language-extension merge", "PUBLICATION_REFACTOR.md Phase 5"); keep to those.

## Decisions

- Per-file sub-layer over per-directory layer, on the measured evidence that no directory layer is
  consistent.
- Origin directory as the classification rule, over a content judgement. A content judgement could
  place `AxiomDischarge` at layer 2 and empty the allowlist again by assertion — the same failure
  the task exists to undo, reached by a different route. The task's acceptance criterion
  ("non-vacuous allowlist") also requires the 7 lines.
- `Soundness.lean` at layer 3 by the same rule applied uniformly, rather than at layer 1 as the
  Minus README groups it. Reported here as a finding, since the task description did not
  anticipate a third sub-layer.
- An explicit 30-row table over a filename-prefix heuristic. The heuristic is right for 29 of 30
  files today and would classify a new file silently, which is the going-dark failure in a
  smaller form.
- No user decision is required: the task description fixes the expected outcome, and the
  measurement agrees with it.

## Risks & Mitigations

- **A raising `layer_of` turns CI red on any new top-level directory or language-directory
  file.** `check-metalogic-cycles.sh` runs in `.github/workflows/ci.yml`. This is the intended
  behaviour; the mitigation is an error message that says exactly which table needs which row.
- **`layer_of` is also called on import targets.** A target that names no real file would raise.
  Lean rejects such an import first, so this cannot occur on a building tree.
- **The per-file table can drift from the tree.** Mitigated by the fail-loud on a missing row and
  the stale-row report on a surplus row; the prototype confirmed both are empty today.
- **Shared working tree.** A sibling task is editing README files under `FormalSystem/Metalogic/`,
  `FormalSystem/Automation/` and `FormalSystem/README.md`. None of this task's files overlap —
  the three language READMEs are not in its scope — but every file should be re-read immediately
  before editing, and only explicit file lists staged.
- **Docstring edits in `.lean` aggregators trigger a rebuild** of their dependents. They are
  comment-only; if build time matters, the README edits alone carry the correction.
- **`check-module-invariants.sh` C5/C12 resolve dotted module names and slash paths in
  documents.** New prose must name real paths, or the harness will flag it.

## Context Extension Recommendations

- **Topic**: the library's layer table and its two measuring scripts
- **Gap**: `.claude/context/repo/project-overview.md` describes the agent system's own two-layer
  architecture but says nothing about `FormalSystem/`'s import layering or the scripts that
  assert it.
- **Recommendation**: a short pointer to `ORGANISATION.md` and `docs/ARCHITECTURE.md` would be
  enough; the content itself belongs in those files, not in agent context.

## Appendix

**Prototype scripts** (session scratchpad, not committed): `lang_edges.py` (every import into and
out of the three directories), `proto.py` (origin-based measurement), `proto2.py` (single-layer
alternatives and the unlayered top-level modules), `proto3.py` (recommended design with simulated
surplus, shortfall and unmapped-path runs).

**Commands used**

```bash
git show -M --name-status --format='%h %s' e2b646c84      # the origin table
python3 scripts/measure-refactor-partitions.py upward-edges   # reports 0 today
bash scripts/check-metalogic-cycles.sh                        # green today, vacuously for B
```

**Inbound edges worth knowing when reading the measurement.** 31 `Metalogic` lines import
language files (all downward under the per-file scheme, including the five that import
`MinusLanguage.Soundness`, which become 3 -> 3). 7 `StarLanguage` lines import `PlusLanguage`
files, every one of them same-layer (syntax to syntax, semantics to semantics).

**References**
- `specs/archive/633_upward_edges_by_relocation/summaries/01_upward-edges-relocation-summary.md` (negative-test method)
- `specs/archive/634_language_extension_directories_and_probe_tests/summaries/01_language-extension-directory-merge-summary.md` (the blind-spot note and the proposed grep assertion)
