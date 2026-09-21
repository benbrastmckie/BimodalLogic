# Implementation Plan: Remove the upward edges by relocation

- **Task**: 633 - Remove the upward edges by relocation
- **Status**: [IMPLEMENTING]
- **Effort**: 9 hours
- **Dependencies**: 630 (landed at `b1ab4bf3a`); 632 (landed at `b1ab4bf3a`)
- **Research Inputs**: `specs/633_upward_edges_by_relocation/reports/01_upward-edges-relocation.md`
- **Artifacts**: plans/01_upward-edges-relocation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`FormalSystem/`'s import graph carries 70 upward lines at HEAD, 15 of them running into
`Automation/`. Eleven of those 15 exist only because three tiny attribute-registration modules
(`TruthNormAttr`, `NormalizationAttr`, `LemmaDB` — five declarations, zero lemmas) sit under
`Automation/` while `Syntax/`, `Semantics/`, `ProofSystem/` and `Theorems/` all need the
attributes they register. This plan deletes those edges by relocation rather than by renumbering:
a new layer-0 `FormalSystem/Tactic/` directory absorbs the attribute declarations and `Init.lean`
imports it, so every module inherits the attributes transitively and the eleven import lines are
deleted outright. Three further relocations (`PropDecide` + its `Meta.lean` dependency,
`DeductionTheorem`, `Periodicity`) close the remaining misfilings, after which the measured layer
order is corrected in `measure-refactor-partitions.py`, asserted mechanically by an extension to
`check-metalogic-cycles.sh`, and written into `ORGANISATION.md` and `docs/ARCHITECTURE.md`.

Definition of done: `python3 scripts/measure-refactor-partitions.py upward-edges` reports zero
lines into `Automation/` from `Syntax`, `Semantics`, `ProofSystem` and `Theorems`, and an empty
`theorems_files_importing_metalogic`; the build-inclusive invariant harness is green; the new
layer-order assertion passes.

### Research Integration

The research report re-measured every count at HEAD `b1ab4bf3a` and simulated all four
relocations against the live import graph. Four findings shape this plan and override the task
description:

1. **The `cut ProofSearch.Core -> SuccessPatterns` item is a no-op and is struck, not done.** Both
   endpoints are inside `Automation/`, so the edge is intra-directory under every candidate layer
   assignment. The predecessor decision (BimodalTools split) already resolved that
   `SuccessPatterns` stays whole in the library. Phase 6 records the strike in
   `docs/development/PUBLICATION_REFACTOR.md` so it is not rediscovered as unfinished work.
2. **`Automation/Tactics/Meta.lean` must move with `PropDecide`.** `PropDecide` calls
   `extractDerivationGoal` and `isNilContext` from it; relocating `PropDecide` alone trades one
   `Metalogic -> Automation` line for another. Target: `FormalSystem/Tactic/Meta.lean`, beside
   `Attr.lean`, since `Commands.lean` and `Search.lean` also consume it and stay in `Automation/`.
3. **The layer-order assertion is an allowlist equality, not a zero-check.** After every
   relocation, exactly 7 upward lines remain, all from
   `Syntax/MinusLanguage/AxiomDischarge.lean -> Theorems/*`, which a later programme phase owns.
   The assertion must fail on surplus *and* shortfall, mirroring the existing "exactly 1 cycle"
   shape in `check-metalogic-cycles.sh`.
4. **Layer assignment A is mandatory, and the reason is an acceptance-integrity one (R-8).**
   `measure_upward_edges` derives `into_automation` from an already layer-filtered `edges` list.
   Placing `Automation` beside `Theorems` would make every `Theorems -> Automation` line invisible
   to the measurement, so a quarter of the acceptance criterion would read zero by renumbering
   instead of by relocation. Assignment A keeps all four acceptance source directories strictly
   below `Automation`.

### Prior Plan Reference

No prior plan. This is round 01.

### Roadmap Alignment

No `specs/ROADMAP.md` in this repository; `roadmap_flag` was not set on this dispatch. The
programme this task advances is `docs/development/PUBLICATION_REFACTOR.md` Phase 4 (lines
344-365), whose corrections Phase 6 writes back.

## Goals & Non-Goals

**Goals**:
- Delete the 11 attribute-driven upward import lines by creating `FormalSystem/Tactic/Attr.lean`
  at layer 0 and importing it from `FormalSystem/Init.lean`.
- Relocate `Automation/Tactics/{Meta,PropDecide}.lean`, `Metalogic/Core/DeductionTheorem.lean` and
  `Metalogic/Decidability/FMP/Periodicity.lean` to the directories their dependencies and
  namespaces already imply.
- Correct `LAYERS` in `scripts/measure-refactor-partitions.py` to the measured order
  (`{Syntax, ProofSystem, ForMathlib, Init, Tactic} 0 -> Semantics 1 -> Theorems 2 ->
  {Metalogic, Automation} 3 -> Examples 4`).
- Extend `scripts/check-metalogic-cycles.sh` with a second, independent layer-order assertion:
  the upward set equals a recorded 7-line allowlist.
- Rewrite `ORGANISATION.md`'s layer table and reconcile `docs/ARCHITECTURE.md` with it.
- Record the `SuccessPatterns` strike and refresh the stale counts in
  `docs/development/PUBLICATION_REFACTOR.md`.
- Keep the build-inclusive invariant harness green, including C25 (`lean_exe` roots), throughout.

**Non-Goals**:
- Fixing the 7 residual `Syntax/MinusLanguage/AxiomDischarge.lean -> Theorems/*` upward lines.
  A later programme phase (the `XLanguage/` merges) owns that file; this task records them in the
  allowlist and names the owner in an in-script comment.
- Cutting `ProofSearch.Core -> SuccessPatterns`. Struck as a no-op (see Research Integration).
- Fixing the two pre-existing red checks: `readme-lint.sh` (21 `../Boneyard/` links one `../`
  short) and `typst-sync-check.sh` (`sorry-total: committed=4 live=0`, plus 9
  `docs/training/PIPELINE.md` line-range violations). Neither is caused by nor cured by this task.
  The bar for those two is **no new rows**, not zero rows.
- Any new Lean declaration, lemma or proof. This task moves and deletes text; it proves nothing.
- The `Metalogic/Expressiveness/` extraction and `mk_all --check` adoption (later phases).

## Lean Challenge Statements

None. This task introduces no new Lean declaration: it relocates existing modules, deletes import
lines, and edits scripts and prose. The `- **Goals**:` bullets above name no Lean identifier, so
the identifier set this section must match is empty and no fenced block is present. A challenge
snapshot of this plan is vacuous by construction, not by omission.

## Risks & Mitigations

| # | Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|---|
| R-1 | **Typst chapter compile breaks.** `typst/chapters/p4-proof-automation.typ` carries `#assert(roles.len() == automation-module-map.len())`; the regenerated map loses the `Tactics/Meta.lean` and `Tactics/PropDecide.lean` rows | H | H (it is a hard assert) | Edit the two `roles` entries, re-path the line-48 prose, and regenerate the map in the same commit as the Phase 2 move; run the actual typst compile, not only `typst-sync-check.sh` |
| R-2 | **`deductionTheorem` unreachable at some of 51 fully-qualified call sites** across 13 files after Phase 3, because several consumers reach the declaration only transitively through `Metalogic/Core/` | H | M | Phase 3 is its own commit gated on a full `lake build`; on a break, add a direct `import FormalSystem.Theorems.DeductionTheorem` at the failing site rather than re-parenting the moved file |
| R-3 | **`move-modules.py` corrupts historical prose.** The tool cannot distinguish a current-location citation from a historical statement about an old location, and has twice collapsed "from X to Y" into "from Y to Y" — observed in ADRs, a refactor document, a before/after table and a harness header comment | H | M (the shape is present in `docs/ARCHITECTURE.md`, `docs/development/PUBLICATION_REFACTOR.md` and `FormalSystem/Automation/README.md`) | Mandatory `--dry-run` first; hand-read **every** non-`.lean` diff hunk, and every hunk under `docs/`, `scripts/` and any ADR, before the real run; check the tool's own bare-form audit line for a zero delta |
| R-4 | **A green `lake build` certifies nothing about the `lean_exe` roots.** In the predecessor split, `lake build`, the new library and `lake test` were all green while 5 of 13 exe roots failed to compile — exe roots sit outside every build closure and only the build-inclusive harness (C25) sees them | H | M | Never gate a phase on `lake build` alone. Every phase that changes the import graph closes on `bash scripts/check-module-invariants.sh` (full, build-inclusive). `--no-build` skips C1/C2/C6/C16/C24/C25 and is a fast structural pre-check only |
| R-5 | **Agent stalls waiting on a background job.** Agents that waited on a background job or a monitor were repeatedly never woken and stalled 15-30 minutes | M | M | Run `lake build` and the full harness in the **foreground with a blocking call**. Do not background them, do not poll a monitor, and do not end a turn in order to wait |
| R-6 | **C8 fails**: `FormalSystem/Tactic/` has no sibling aggregator (`ENFORCE_C8=1`, and `FormalSystem/` is a walked parent) | H | H if forgotten | Create `FormalSystem/Tactic.lean` in the same commit that creates the directory |
| R-7 | **readme-lint Check 1 fails**: `FormalSystem/Tactic/` has `.lean` files and no README (Check 1 is gated) | M | H if forgotten | Create `FormalSystem/Tactic/README.md` in the same commit |
| R-8 | **C6 flags `FormalSystem.Tactic` as unreachable** — the new aggregator is in no import closure | M | M | Add `import FormalSystem.Tactic` to `FormalSystem/FormalSystem.lean`; do not add a C6 manifest row for something trivially reachable |
| R-9 | **C24 fails on the new aggregator.** In Phase 1 `FormalSystem/Tactic.lean` imports only `Tactic.Attr`, which imports `Lean` alone, so the aggregator reaches no `FormalSystem.Init` path | M | M | Give `FormalSystem/Tactic.lean` an explicit `import FormalSystem.Init` — the same pattern `FormalSystem/ForMathlib.lean` already uses. This closes no cycle: `Init` imports `Tactic.Attr`, not `Tactic` |
| R-10 | **Duplicate attribute registration.** `Tactic/Attr.lean` and the three original modules cannot coexist in one build closure — `register_simp_attr truth_norm` twice is an elaboration error | H | H if staged | Phase 1 is a declared `atomic-batch`: creation, deletion and the 13 import-line removals land as one commit with expected-red intermediate states |
| R-11 | **A renumber satisfies the acceptance criterion instead of the relocation doing so** (R-8 in the research report) | H | H if assignment B is chosen | Use assignment A. If the implementer deviates, `measure_upward_edges` must first be rewritten so `into_automation` enumerates its source directories independently of `LAYERS` |
| R-12 | **`ORGANISATION.md` and `docs/ARCHITECTURE.md` contradict each other.** `ORGANISATION.md` defers the layer graph to `ARCHITECTURE.md`, and `ARCHITECTURE.md` is independently stale (calls `Semantics -> ProofSystem` upward though its own diagram puts ProofSystem below; names `DataExport.lean`, `TraceExporterMain.lean`, `TableauProofStepsMain.lean` as `Automation/` modules though all three now live in `BimodalTools/`; lists a top-level `PlusLanguage/`) | M | H | Rewrite both in Phase 6. No mechanical check catches a contradiction between claims — C5/C12/C13 verify paths and links only |
| R-13 | **Attribute unavailable at a tag site** if some module tags `@[tmLemma]`/`@[truth_norm]` without reaching `Init` | H | L | Already measured: the only module losing its `Init` path is the pre-excepted `ForMathlib/Order/PFilter`, which tags nothing. C24 in build mode is the gate |
| R-14 | **`Semantics/Periodicity.lean` confused with the existing `Semantics/Correspondence/FwdRecPeriodicity.lean`** | L | L | One-line disambiguation in `FormalSystem/Semantics/README.md` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3, 4 | -- |
| 2 | 2 | 1 |
| 3 | 5 | 1, 2, 3, 4 |
| 4 | 6 | 5 |

Phases within the same wave can execute in parallel.

**Parallelism caveat**: Phases 1, 3 and 4 are genuinely file-disjoint, but `move-modules.py`
rewrites citations tree-wide and closes by running the whole-tree harness, so two of them running
concurrently in the same worktree would collide. A single implementation agent should execute
them in the listed order (1, 3, 4); true parallel execution requires separate worktrees.

**Standing gate discipline for every phase below** (do not restate per phase):
- `lake build` and `bash scripts/check-module-invariants.sh` run in the **foreground with a
  blocking call**. Never background them; never wait on a monitor (R-5).
- A green `lake build` is never sufficient on its own for a phase that changes the import graph;
  the build-inclusive harness is what covers the 13 `lean_exe` roots via C25 (R-4).
- `readme-lint.sh` and `typst-sync-check.sh` both print `FAIL` and both exit 0 through a pipe.
  Compare row counts against the recorded baseline (21 broken refs; `sorry-total committed=4
  live=0` plus 9 PIPELINE.md violations); the bar is **no new rows**.

---

### Phase 1: Create the Tactic/ layer and merge the attribute modules [COMPLETED]

- **Goal:** Delete all 11 attribute-driven upward import lines by moving five attribute
  declarations to a single layer-0 module that `Init.lean` imports.
- **Tasks:**
  - [ ] Create `FormalSystem/Tactic/Attr.lean` carrying all five declarations from
        `Automation/{TruthNormAttr, NormalizationAttr, LemmaDB}.lean`: `register_simp_attr
        truth_norm`, `reflect_time_norm`, `formula_unfold`, `formula_fold`, and
        `register_label_attr tmLemma`. Import `Lean` **only** — `FormalSystem.Init` must not be
        imported (that is the cycle), and the research verified via `lean_run_code` that both
        commands are core Lean and elaborate under a bare `import Lean`.
  - [ ] Drop the inert `namespace FormalSystem.Automation.LemmaDB` wrapper. Attribute and simp-set
        identifiers are global and zero call sites reference a `LemmaDB.`-qualified name.
  - [ ] Preserve the same-compilation-unit docstring the source files carry (`register_simp_attr`
        expands to an `initialize` block, so neither the attribute nor the simp-set identifier is
        usable in the declaring file). The merge strengthens this constraint rather than relaxing
        it: `Init.lean` is by construction upstream of every module.
  - [ ] Create `FormalSystem/Tactic.lean` sibling aggregator importing `FormalSystem.Init` and
        `FormalSystem.Tactic.Attr` (R-6, R-9).
  - [ ] Create `FormalSystem/Tactic/README.md` stating the directory constraint: `Attr.lean`
        carries attribute and simp-set declarations only — no lemmas, no definitions — because
        `Init.lean` imports it and anything heavier would be forced upstream of the entire
        library (R-7).
  - [ ] Add `import FormalSystem.Tactic.Attr` to `FormalSystem/Init.lean`; correct its docstring's
        "the eleven minimal elements of the internal import DAG" to eight, and remove the now-false
        claim that "this repo has no local lint/tactic-attribute module to pin alongside
        `Mathlib.Init`".
  - [ ] Add `import FormalSystem.Tactic` to `FormalSystem/FormalSystem.lean` (R-8).
  - [ ] Add `` `FormalSystem.Tactic.Attr `` to `exceptions` in `scripts/CheckInitImportsMain.lean`
        with a comment naming the cycle it avoids; apply the same "eleven" -> eight correction to
        that file's header prose.
  - [ ] Delete `FormalSystem/Automation/{TruthNormAttr, NormalizationAttr, LemmaDB}.lean`.
  - [ ] Delete the 13 import lines that named them, in: `Syntax/Formula.lean`,
        `Semantics/Truth.lean`, `ProofSystem/DerivedAxioms.lean`, `Theorems/Combinators.lean`,
        `Theorems/ModalS5.lean`, `Theorems/TemporalDerived.lean`,
        `Theorems/Perpetuity/{Helpers, Principles}.lean`,
        `Theorems/Propositional/{Core, Connectives, Reasoning}.lean`,
        `Automation/Normalization.lean`, `Automation/Tactics/Search.lean`. Delete outright — do
        not re-point to `FormalSystem.Tactic.Attr`; every one of these modules reaches `Init`
        transitively (C24 asserts it), which is the entire point of the relocation.
  - [ ] Rewrite the prose citations of the three deleted modules in
        `FormalSystem/Automation/README.md`, `FormalSystem/Automation/Tactics/README.md`,
        `Boneyard/RetiredTactics/README.md`, `Automation/Tactics/Search.lean:286`, and the
        comment in `scripts/measure-refactor-partitions.py`. Read each hunk by hand for the
        historical-statement shape (R-3).
  - [ ] Run the full harness and resolve whatever C5/C9/C10 (stale path citation) rows the
        deletions raise, inside this same commit.
- **Timing:** 2 hours
- **Depends on:** none
- **Verification Tier:** full
- **Commit Mode:** atomic-batch
- **Scope Hypothesis:** 13 import lines across 13 files, of which 11 are upward; 3 modules
  deleted; 5 non-`.lean` citation files. Confirm at implementation time with
  `grep -rn 'FormalSystem\.Automation\.\(TruthNormAttr\|NormalizationAttr\|LemmaDB\)'` over
  `FormalSystem/ Tests/ scripts/` and a repo-wide citation grep excluding `specs/`, `.lake/` and
  `.git/`. A count that differs is a finding to record, not a number to force.
- **Files to modify**:
  - `FormalSystem/Tactic/Attr.lean` - new; the five merged attribute declarations, `import Lean` only
  - `FormalSystem/Tactic.lean` - new; sibling aggregator, imports `Init` and `Tactic.Attr`
  - `FormalSystem/Tactic/README.md` - new; states the attributes-only constraint
  - `FormalSystem/Init.lean` - add the `Tactic.Attr` import; "eleven" -> eight; drop the stale claim
  - `FormalSystem/FormalSystem.lean` - add `import FormalSystem.Tactic`
  - `scripts/CheckInitImportsMain.lean` - add the `Tactic.Attr` exception; "eleven" -> eight
  - `FormalSystem/Automation/{TruthNormAttr,NormalizationAttr,LemmaDB}.lean` - deleted
  - 13 importer files listed above - import line deleted
  - `FormalSystem/Automation/README.md`, `FormalSystem/Automation/Tactics/README.md`,
    `Boneyard/RetiredTactics/README.md`, `scripts/measure-refactor-partitions.py` - citations
- **Verification**:
  - `lake build` exits 0 (foreground, blocking).
  - `bash scripts/check-module-invariants.sh` — ALL CHECKS PASSED, including C24 and C25.
  - `lake exe checkInitImports` passes with exactly two exceptions consumed.
  - `python3 scripts/measure-refactor-partitions.py upward-edges` — `into_automation` shows zero
    lines from `Syntax`, `Semantics`, `ProofSystem` and `Theorems` (the 4 `Metalogic -> Automation`
    lines remain; Phases 2 and 5 address them).
  - `bash scripts/readme-lint.sh` — no new rows beyond the 21-row baseline.

---

### Phase 2: Relocate PropDecide and its Meta.lean dependency [COMPLETED]

- **Goal:** Move the propositional-decision tactic under `Metalogic/Decidability/` and its shared
  `MetaM` plumbing to layer 0, so the `Metalogic -> Automation` `PropDecide` line disappears
  without creating a replacement.
- **Tasks:**
  - [ ] `git mv FormalSystem/Automation/Tactics/Meta.lean FormalSystem/Tactic/Meta.lean`. It
        imports `FormalSystem.ProofSystem` + `Lean`, so it reaches `Init` and needs no C24
        exception; it is ordinary metaprogramming that merely has no natural home above
        `Automation/`. Note the distinction in `FormalSystem/Tactic/README.md`: `Attr.lean`
        carries the attributes-only constraint, `Meta.lean` does not.
  - [ ] `git mv FormalSystem/Automation/Tactics/PropDecide.lean
        FormalSystem/Metalogic/Decidability/Propositional/Tactic.lean`.
  - [ ] Drive both moves with `python3 scripts/move-modules.py --module-map FILE --dry-run` first;
        read every non-`.lean` hunk by hand, and confirm the bare-form audit line reports a zero
        delta, before the real run (R-3).
  - [ ] Re-point `FormalSystem/Automation.lean`'s `Tactics.PropDecide` import to
        `FormalSystem.Metalogic.Decidability.Propositional.Tactic`, keeping the user-facing tactic
        surface intact.
  - [ ] Re-point `Automation/Tactics/{Commands,Search,Deduction}.lean`'s `Tactics.Meta` imports to
        `FormalSystem.Tactic.Meta`.
  - [ ] Add `import FormalSystem.Tactic.Meta` to `FormalSystem/Tactic.lean`.
  - [ ] Add the relocated module to `FormalSystem/Metalogic/Decidability/Propositional.lean` (or
        whichever aggregator covers that directory) and remove it from any `Automation/Tactics`
        aggregator that named it.
  - [ ] Rewrite `Tests/BimodalTest/Metalogic/PropDecideTest.lean`'s import (the file is already
        under `Tests/.../Metalogic/`; no test relocation needed).
  - [ ] Regenerate `typst/generated/automation-module-map.typ` via
        `bash scripts/typst-module-map.sh`. Expect the two departing rows and a total moving
        3577 -> 3320.
  - [ ] Remove the `"Tactics/Meta.lean"` and `"Tactics/PropDecide.lean"` entries from the `roles`
        dictionary in `typst/chapters/p4-proof-automation.typ` (lines 115-116) or the
        `#assert(roles.len() == automation-module-map.len())` fails the compile (R-1).
  - [ ] Re-path the `Tactics/PropDecide.lean` prose citation at
        `typst/chapters/p4-proof-automation.typ:48` to the new location.
  - [ ] Narrate the two departures in `scripts/typst-module-map.sh`'s header, the way the chapter
        already narrates `EFGameTactics.lean` living outside `Automation/`.
- **Timing:** 1.5 hours
- **Depends on:** 1
- **Verification Tier:** interface
- **Commit Mode:** atomic-batch
- **Scope Hypothesis:** 2 Lean modules moved; 3 `Automation/Tactics/*` consumers of `Meta.lean`
  plus 1 aggregator re-pointed; 1 test import; 2 `roles` rows and 1 prose line in the typst
  chapter. Confirm with `grep -rn 'Tactics\.Meta\|Tactics/Meta\|Tactics\.PropDecide\|Tactics/PropDecide'`
  over the tree excluding `specs/` before the move, and re-run it after to confirm zero residue.
- **Files to modify**:
  - `FormalSystem/Tactic/Meta.lean` - moved from `Automation/Tactics/Meta.lean`
  - `FormalSystem/Metalogic/Decidability/Propositional/Tactic.lean` - moved from `Automation/Tactics/PropDecide.lean`
  - `FormalSystem/Tactic.lean`, `FormalSystem/Automation.lean`, the `Decidability/Propositional` aggregator - import edits
  - `FormalSystem/Automation/Tactics/{Commands,Search,Deduction}.lean` - import re-point
  - `Tests/BimodalTest/Metalogic/PropDecideTest.lean` - import re-point
  - `typst/generated/automation-module-map.typ` - regenerated
  - `typst/chapters/p4-proof-automation.typ` - two `roles` rows removed, line-48 prose re-pathed
  - `scripts/typst-module-map.sh` - header narration
  - `FormalSystem/Tactic/README.md`, `FormalSystem/Automation/Tactics/README.md` - contents updated
- **Verification**:
  - `lake build` exits 0; `bash scripts/check-module-invariants.sh` — ALL CHECKS PASSED.
  - `typst compile` of the chapter (or the full document) succeeds — the `#assert` is the gate,
    and `typst-sync-check.sh` alone does not run it.
  - `bash scripts/typst-sync-check.sh` — no new rows beyond the recorded baseline.
  - `grep -rn 'FormalSystem\.Automation' FormalSystem/Metalogic/ | grep -v Boneyard` returns only
    the three `ProofSearch`/`Normalization` lines Phase 5 re-documents as intra-layer.
  - `python3 scripts/measure-refactor-partitions.py upward-edges` — `Metalogic -> Automation` is
    down to 3 lines (`ProofSearch.Core`, `Normalization`, `ProofSearch.Strategies`).

---

### Phase 3: Move DeductionTheorem.lean to Theorems/ [COMPLETED]

- **Goal:** Delete the 4 `Theorems -> Metalogic` lines by moving the one module all four of them
  import, keeping its namespace so the 51 fully-qualified call sites are untouched.
- **Tasks:**
  - [ ] `git mv FormalSystem/Metalogic/Core/DeductionTheorem.lean
        FormalSystem/Theorems/DeductionTheorem.lean`, driven by `move-modules.py` with a
        **module map only and no namespace map** — the namespace deliberately does not move.
  - [ ] `--dry-run` first and hand-read every non-`.lean` hunk (R-3).
  - [ ] Keep `namespace FormalSystem.Metalogic.Core` in the moved file. 51 fully-qualified
        `FormalSystem.Metalogic.Core.deductionTheorem*` references across 13 files make any
        alternative disproportionate.
  - [ ] Record the resulting namespace-audit `unrelated` row in the moved file's module docstring:
        module `FormalSystem.Theorems.DeductionTheorem`, namespace `FormalSystem.Metalogic.Core`,
        with the reason. The bucket is informational and never gated, but the exception must be
        *recorded*, not rediscovered.
  - [ ] Add `import FormalSystem.Theorems.DeductionTheorem` to `FormalSystem/Theorems.lean`.
  - [ ] Drop the `DeductionTheorem` import from `FormalSystem/Metalogic/Core.lean` (this
        aggregator is on the C6 manifest).
  - [ ] Confirm the move creates no cycle: the file imports `ProofSystem.Derivation`,
        `ProofSystem.Derivable` and `Theorems.Combinators`, all at or below the Theorems layer,
        and `Combinators`' own `LemmaDB` edge was deleted in Phase 1.
- **Timing:** 1.5 hours
- **Depends on:** none
- **Verification Tier:** full
- **Scope Hypothesis:** 4 `Theorems/` files import the module directly (`DedekindDerived`,
  `DiscreteUnfolding`, `GeneralizedNecessitation`, `Propositional/Core`) and 51 fully-qualified
  references sit across 13 files, several reaching the declaration only transitively. Only a full
  `lake build` confirms the transitive paths survive (R-2); confirm the direct-import set with
  `grep -rn 'Metalogic\.Core\.DeductionTheorem' FormalSystem/ Tests/` before and after.
- **Files to modify**:
  - `FormalSystem/Theorems/DeductionTheorem.lean` - moved; namespace unchanged; docstring records the exception
  - `FormalSystem/Theorems.lean` - add the import
  - `FormalSystem/Metalogic/Core.lean` - drop the import
  - Import lines in the 4 direct importers, rewritten by `move-modules.py`
  - `FormalSystem/Metalogic/Core/README.md`, `FormalSystem/Theorems/README.md` - inventory rows
- **Verification**:
  - `lake build` exits 0 — this is the gate that matters for R-2. On a failure, add a direct
    import at the failing site; do not re-parent the moved file.
  - `bash scripts/check-module-invariants.sh` — ALL CHECKS PASSED, including C6.
  - `python3 scripts/measure-refactor-partitions.py upward-edges` —
    `theorems_files_importing_metalogic` is empty.
  - `python3 scripts/measure-refactor-partitions.py namespace-audit` — the `unrelated` bucket
    gains exactly the one recorded `FormalSystem.Theorems.DeductionTheorem` row.

---

### Phase 4: Move Periodicity.lean to Semantics/ [COMPLETED]

- **Goal:** Delete the `Semantics -> Metalogic` line by moving a module that already declares
  `namespace FormalSystem.Semantics` into the directory that namespace names.
- **Tasks:**
  - [ ] `git mv FormalSystem/Metalogic/Decidability/FMP/Periodicity.lean
        FormalSystem/Semantics/Periodicity.lean` via `move-modules.py`, `--dry-run` first (R-3).
        The file needs **no in-file edit**: it already declares `namespace FormalSystem.Semantics`
        and imports only `FormalSystem.Semantics.IntNormalForm` plus two Mathlib modules.
  - [ ] Rewrite the import in its four importers: `Metalogic/Decidability/FMP/FMP.lean`,
        `Metalogic/Decidability/BiLasso/GoodCycle.lean`,
        `Metalogic/Decidability/IntPresentation.lean`,
        `Semantics/Extension/PeriodicExtension.lean`.
  - [ ] Add `import FormalSystem.Semantics.Periodicity` to `FormalSystem/Semantics.lean` and drop
        the row from `FormalSystem/Metalogic/Decidability/FMP.lean` if that aggregator names it.
  - [ ] Add a one-line disambiguation to `FormalSystem/Semantics/README.md` distinguishing
        `Semantics/Periodicity.lean` from the existing
        `Semantics/Correspondence/FwdRecPeriodicity.lean` (R-14).
- **Timing:** 1 hour
- **Depends on:** none
- **Verification Tier:** interface
- **Scope Hypothesis:** 4 importers, 2 aggregators, 1 README line, 0 in-file edits. Confirm with
  `grep -rn 'FMP\.Periodicity\|FMP/Periodicity' FormalSystem/ Tests/ docs/ typst/ scripts/` before
  the move and re-run after for zero residue.
- **Files to modify**:
  - `FormalSystem/Semantics/Periodicity.lean` - moved, contents unchanged
  - The 4 importers listed above - import line rewritten
  - `FormalSystem/Semantics.lean`, `FormalSystem/Metalogic/Decidability/FMP.lean` - aggregator rows
  - `FormalSystem/Semantics/README.md`, `FormalSystem/Metalogic/Decidability/FMP/README.md` - inventory
- **Verification**:
  - `lake build` exits 0; `bash scripts/check-module-invariants.sh` — ALL CHECKS PASSED.
  - `python3 scripts/measure-refactor-partitions.py upward-edges` — the `Semantics -> Metalogic`
    class is gone.
  - `python3 scripts/measure-refactor-partitions.py namespace-audit` — the `unrelated` bucket
    loses the `Periodicity` row (net 24 -> 23 once Phases 2-4 have all landed).

---

### Phase 5: Correct LAYERS and install the layer-order assertion [NOT STARTED]

- **Goal:** Make the measured layer order the recorded one, and turn it into a mechanical
  assertion that fails on surplus and shortfall alike.
- **Tasks:**
  - [ ] Rewrite `LAYERS` in `scripts/measure-refactor-partitions.py` to assignment A:
        `"Syntax": 0, "ProofSystem": 0, "ForMathlib": 0, "Init": 0, "Tactic": 0, "Semantics": 1,
        "Theorems": 2, "Metalogic": 3, "Automation": 3, "Examples": 4`. The `Tactic: 0` entry is
        load-bearing: without it `layer_of` returns `None` for every `Tactic` module and the new
        directory contributes no edges in either direction.
  - [ ] Update the comment block above `theorems_to_metalogic` / `metalogic_to_theorems`: those
        two are computed directly precisely because the table's relative order makes one of them
        invisible to `edges`, and the direction of that asymmetry flips with this renumber.
  - [ ] Update the `into_automation` source-tuple comment and the "five lower layers" wording to
        match the new table, and refresh the "Measured on commit 220e94ea4" narrative.
  - [ ] Extend `scripts/check-metalogic-cycles.sh` with a **second, independent** pass that:
        (a) computes the upward set over the whole library using the same `LAYERS` table, reusing
        `scripts/lib/import_graph.py` rather than the script's own regex; (b) excludes sibling
        aggregators as edge sources, citing the reason already in the script's header; (c) asserts
        the set **equals** a recorded allowlist of the 7
        `Syntax.MinusLanguage.AxiomDischarge -> Theorems.{Combinators, DedekindDerived,
        DeductionTheorem, DiscreteUnfolding, GeneralizedNecessitation, Propositional.Core,
        TemporalDerived}` lines; (d) fails on a **surplus and on a shortfall alike** — a shortfall
        means the later programme phase landed and the allowlist is stale, which is a finding, in
        the same spirit as the existing "zero cycles is a finding, not a pass" branch.
  - [ ] Add an in-script comment naming `docs/development/PUBLICATION_REFACTOR.md` Phase 5 (the
        `XLanguage/` merges) as the work that empties the allowlist.
  - [ ] Keep the existing cycle assertion intact and unchanged. Update the script header to say
        it now makes two independent assertions behind one exit code, and keep the "not wired into
        check-module-invariants.sh, deliberately" rationale.
- **Timing:** 1.5 hours
- **Depends on:** 1, 2, 3, 4
- **Verification Tier:** local
- **Scope Hypothesis:** the allowlist is exactly 7 lines, all sourced at
  `Syntax/MinusLanguage/AxiomDischarge.lean`. Do not hand-copy it from this plan: derive it by
  running `python3 scripts/measure-refactor-partitions.py upward-edges` after Phases 1-4 have
  landed and transcribe the measured set. A count other than 7 means an earlier phase is
  incomplete — stop and diagnose rather than widening the allowlist.
- **Files to modify**:
  - `scripts/measure-refactor-partitions.py` - `LAYERS` table, `into_automation` and
    `theorems_to_metalogic` comments, the "five lower layers" wording, the measurement narrative
  - `scripts/check-metalogic-cycles.sh` - new layer-order pass, allowlist, header rewrite
- **Verification**:
  - `bash scripts/check-metalogic-cycles.sh` exits 0, printing both the "exactly 1 cycle" result
    and the layer-order result.
  - Negative test, run by hand and reverted: add one upward import line, confirm the script exits
    non-zero naming the surplus; delete one allowlist entry, confirm it exits non-zero naming the
    shortfall. A gate that has never been seen to fail has not been tested.
  - `python3 scripts/measure-refactor-partitions.py upward-edges` — `into_automation_line_count`
    is 0 (the 3 `Metalogic -> Automation` lines become intra-layer under assignment A) and the
    total upward count is 7.
  - `bash scripts/check-module-invariants.sh --no-build` — no new rows (this phase touches no
    Lean source, so the fast structural pass suffices here; the full harness ran at Phase 4).

---

### Phase 6: Rewrite the layer documentation and correct the programme record [NOT STARTED]

- **Goal:** Make the prose agree with the measurement, and record the two programme corrections so
  neither is rediscovered as unfinished work.
- **Tasks:**
  - [ ] Rewrite `ORGANISATION.md`'s layer table to assignment A. State in prose — not by the
        absence of a table row — that `Decidability -> {ProofSearch, Normalization}` is a
        legitimate intra-layer edge, which is what placing library automation *beside* Metalogic
        means and what the programme's Phase 4 bullet 5 asks for.
  - [ ] Add `Tactic/` to the directory inventory in `ORGANISATION.md` with its attributes-only
        constraint.
  - [ ] Rewrite `docs/ARCHITECTURE.md`: the layer diagram, both "upward edge" sections, and the
        independently stale claims — `Semantics -> ProofSystem` described as upward though the
        diagram puts ProofSystem below; `DataExport.lean`, `TraceExporterMain.lean` and
        `TableauProofStepsMain.lean` listed as `Automation/` modules though all three now live in
        `BimodalTools/`; a top-level `PlusLanguage/` that is now `Syntax/PlusLanguage/`;
        `Automation/` described as holding "the ML dataset pipeline" (R-12).
  - [ ] In `docs/development/PUBLICATION_REFACTOR.md`: strike the `ProofSearch.Core ->
        SuccessPatterns` cut at line 358, recording that the predecessor phase decided
        `SuccessPatterns` stays whole in the library and why (pure data; two library call sites in
        `ProofSearch/{Core,Strategies}`; tooling importers use only `PatternKey`, `GoalCategory`
        and `goalCategory`). Do not silently delete the bullet — record the decision.
  - [ ] Refresh line 271's stale "16 lines (11 attribute-only)" to the measured figures, and mark
        Phase 4's bullets as landed, naming the residual `AxiomDischarge` lines as Phase 5's.
  - [ ] Sweep the remaining path/module citations flagged by C5/C12/C13 across
        `docs/project-info/tactic-registry.md`, `docs/reference/tactic-reference.md`,
        `docs/reference/API_REFERENCE.md`, `docs/development/MODULE_ORGANIZATION.md`,
        `docs/development/NAMING_CONVENTION_DEVIATION.md`,
        `docs/project-info/FEATURE_REGISTRY.md`, `docs/project-info/implementation-status.md`,
        `FormalSystem/Metalogic/Algebraic/README.md`.
  - [ ] Read every hunk this phase produces by hand. `move-modules.py` may have already touched
        several of these files in Phases 2-4; the "from X to Y" collapse is exactly the shape that
        survives a passing rewrite total (R-3).
- **Timing:** 1.5 hours
- **Depends on:** 5
- **Verification Tier:** prose
- **Scope Hypothesis:** roughly 12 documentation files. The list above comes from the research
  report's inventory, not from a fresh scan; re-derive it at implementation time by running the
  full harness and collecting the C5/C10/C12/C13 rows, plus
  `bash scripts/readme-lint.sh`. Files on the list that need no edit should be recorded as
  checked, not silently dropped.
- **Files to modify**:
  - `ORGANISATION.md` - layer table rewrite, `Tactic/` inventory row, intra-layer prose
  - `docs/ARCHITECTURE.md` - diagram, both upward-edge sections, the four stale claims
  - `docs/development/PUBLICATION_REFACTOR.md` - `SuccessPatterns` strike, line 271 counts, Phase 4 status
  - The 8 documentation files listed above - path/module citations
- **Verification**:
  - `bash scripts/check-module-invariants.sh` — ALL CHECKS PASSED (full, build-inclusive; this is
    the task's final gate and the one that covers C25).
  - `bash scripts/check-metalogic-cycles.sh` exits 0 on both assertions.
  - `bash scripts/readme-lint.sh` — no new rows beyond the 21-row baseline.
  - `bash scripts/typst-sync-check.sh` — no new rows beyond the recorded baseline.
  - `ORGANISATION.md`'s table and `measure-refactor-partitions.py`'s `LAYERS` agree entry for
    entry, read side by side.

## Testing & Validation

- [ ] `lake build` exits 0.
- [ ] `lake build BimodalTest` (or `lake test`) exits 0.
- [ ] `bash scripts/check-module-invariants.sh` — ALL CHECKS PASSED, run **without**
      `--no-build` so C1/C2/C6/C16/C24/C25 all execute. C25 compile-checks all 13 `lean_exe`
      roots, which no library build closure reaches (R-4).
- [ ] `lake exe checkInitImports` passes with exactly two recorded exceptions
      (`FormalSystem.Init`, `FormalSystem.ForMathlib.Order.PFilter`) plus the new
      `FormalSystem.Tactic.Attr`.
- [ ] `python3 scripts/measure-refactor-partitions.py upward-edges` reports **zero** lines into
      `Automation/` from `Syntax`, `Semantics`, `ProofSystem` and `Theorems`, and an empty
      `theorems_files_importing_metalogic`. **This is the task's acceptance criterion.**
- [ ] The same command's total upward-line count is 7, all from
      `Syntax/MinusLanguage/AxiomDischarge.lean`.
- [ ] `python3 scripts/measure-refactor-partitions.py namespace-audit` — the `unrelated` bucket is
      23 rows: 24 at baseline, minus `PropDecide` and `Periodicity`, plus the recorded
      `Theorems.DeductionTheorem` row.
- [ ] `bash scripts/check-metalogic-cycles.sh` exits 0 on both the cycle assertion and the new
      layer-order assertion, and has been seen to fail on a hand-induced surplus and on a
      hand-induced shortfall.
- [ ] The typst chapter compiles — the `#assert(roles.len() == automation-module-map.len())` is a
      hard assert that `typst-sync-check.sh` does not exercise.
- [ ] `bash scripts/readme-lint.sh` and `bash scripts/typst-sync-check.sh` show **no new rows**
      against their recorded red baselines. Both print `FAIL` and both exit 0 through a pipe, so
      compare counts rather than reading either the word or the exit code.

## Artifacts & Outputs

- `specs/633_upward_edges_by_relocation/plans/01_upward-edges-relocation.md` (this file)
- `specs/633_upward_edges_by_relocation/summaries/01_upward-edges-relocation-summary.md`
- New: `FormalSystem/Tactic/Attr.lean`, `FormalSystem/Tactic/Meta.lean`,
  `FormalSystem/Tactic.lean`, `FormalSystem/Tactic/README.md`
- Moved: `FormalSystem/Metalogic/Decidability/Propositional/Tactic.lean`,
  `FormalSystem/Theorems/DeductionTheorem.lean`, `FormalSystem/Semantics/Periodicity.lean`
- Deleted: `FormalSystem/Automation/{TruthNormAttr, NormalizationAttr, LemmaDB}.lean`
- Regenerated: `typst/generated/automation-module-map.typ`
- Extended: `scripts/check-metalogic-cycles.sh` (layer-order assertion),
  `scripts/measure-refactor-partitions.py` (`LAYERS`), `scripts/CheckInitImportsMain.lean`
- Rewritten: `ORGANISATION.md`, `docs/ARCHITECTURE.md`,
  `docs/development/PUBLICATION_REFACTOR.md`

## Rollback/Contingency

Each phase is its own commit against a green build-inclusive harness, so reverting one phase is
`git revert <sha>` on a clean tree — no snapshot needed and no working-tree discard involved.

Phases 1 and 2 are declared `atomic-batch`: their intermediate per-file states are expected red
(duplicate attribute registration in Phase 1; a broken typst `#assert` in Phase 2) and MUST NOT be
committed individually. If either batch cannot be brought green, `git checkout` of the batch's own
files is not the recovery route while other uncommitted work is present — take a durable,
non-reverting checkpoint first with `bash .claude/scripts/git-snapshot.sh 633 --no-revert`, then
continue fixing forward. A genuine whole-tree rollback (discarding uncommitted work) is a
snapshot-then-rollback recipe: see `.claude/context/contracts/recovery.md`'s rollback rung for the
exact invocation, including its out-of-scope override flag.

Per-phase contingencies:
- **Phase 1** — if `Tactic/Attr.lean` importing `Lean` alone turns out insufficient for some
  declaration, do not add `import FormalSystem.Init` (that is the cycle). Split the offending
  declaration back out into an `Automation/` module and record the residual upward edge as a
  finding; the other four declarations still move.
- **Phase 3** — a `deductionTheorem` unreachability failure is fixed by adding a direct
  `import FormalSystem.Theorems.DeductionTheorem` at the failing site, never by re-parenting the
  moved file (R-2).
- **Phase 5** — if the measured residual is not exactly 7 lines, an earlier phase is incomplete.
  Diagnose and finish it; do not widen the allowlist to make the assertion pass.

If the whole task must be abandoned mid-flight, the phases are independently revertible in reverse
order (6, 5, 4, 3, 2, 1) with no cross-phase coupling except Phase 5's allowlist, which is only
correct once 1-4 have landed.
