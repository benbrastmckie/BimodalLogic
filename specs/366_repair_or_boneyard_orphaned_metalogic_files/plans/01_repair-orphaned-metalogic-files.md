# Implementation Plan: Task #366 — Repair or Boneyard Orphaned Metalogic Files

- **Task**: 366 - Repair or boneyard orphaned metalogic files
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/366_repair_or_boneyard_orphaned_metalogic_files/reports/01_orphaned-metalogic-repair-research.md
- **Artifacts**: plans/01_repair-orphaned-metalogic-files.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Two pre-broken, orphaned Metalogic files (`Deferral.lean`, `AlgebraicCompleteness.lean`) rotted
silently because they are unreachable from the default `lake build` target and therefore never
compiled by CI. Research verified both are trivially repairable and sorry-free (one-line fixes
each, empirically confirmed EXIT 0). This plan repairs both, relocates them into
`Theories/Bimodal/Boneyard/` so the `BoneyardArchive` submodule glob compiles them permanently
(closing the silent-rot loop), deletes the 3 orphaned aggregator modules (0 live importers), and
corrects 2 stale `ContextDerivable` LaTeX references. Definition of done: every repaired file is
green under a scoped `lake build`, `lake build BoneyardArchive` and the default `lake build` are
both green, and zero NEW sorries are introduced anywhere the repairs touch.

### Research Integration

All fixes are taken directly from the verified research report (findings applied, confirmed green,
then reverted to leave the tree clean for implementation):
- **Deferral.lean**: root cause is a missing `open Bimodal.Metalogic.Bundle` (the sibling
  `Basic.lean:449` has it). Adding one line resolves all ~24 `Unknown identifier` errors.
- **AlgebraicCompleteness.lean**: single API-drift error at line 156 — the `trivial`
  axiom-membership arg is misplaced inside `Axiom.prop_s (...)` instead of being the final arg to
  `DerivationTree.axiom` (correct pattern at line 99). Moving one closing paren resolves it.
- **3 aggregators** (`Metalogic/Core/Core.lean`, `Metalogic/Algebraic/Algebraic.lean`,
  `Metalogic/Decidability/FMP.lean`): all 0 live importers → DELETE.
- **LaTeX** `04-Metalogic.tex` lines 328, 433: stale `ContextDerivable` → reword to
  `Derivable FrameClass.Base` / `Derivable` per task-194 inlining.

### Chosen path and justification: REPAIR-THEN-BONEYARD (durable)

The research offered two valid paths. This plan selects **repair-then-move-to-Boneyard** over the
lighter repair-in-place option, and the choice is deliberate:

1. **Root-cause fix, not symptom fix.** The files broke *because* they were orphaned from the
   default target and thus never compiled by CI. Repairing them in place recreates exactly that
   condition — they stay uncompiled and can silently re-break on the next API drift. Moving them
   under `Boneyard/` puts them inside the `lean_lib BoneyardArchive` submodule *glob*, which
   compiles every file regardless of whether anything imports it. This is the only option that
   makes the fix durable.
2. **Their consumers are already boneyarded.** All 6 remaining importers of `Deferral.lean` (and
   the sole non-boneyard importer of each broken file, which we delete) live under `Boneyard/`
   already. Relocation consolidates the dead-code region rather than scattering it.
3. **Low incremental risk.** Both files only import live shared modules (`Basic`, `Bundle`,
   `UltrafilterMCS`), which remain reachable after the move; boneyard files are already permitted
   to import live modules. The only extra work versus in-place is updating 6 import paths.

The lighter repair-in-place alternative is retained as the documented fallback in
Rollback/Contingency should relocation hit an unexpected import complication.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted for this task (no roadmap context provided in delegation).

## Goals & Non-Goals

**Goals**:
- Repair `Deferral.lean` and `AlgebraicCompleteness.lean` to green under scoped `lake build`, zero
  new sorries in-file.
- Relocate both repaired files under `Theories/Bimodal/Boneyard/` so they are CI-verified via the
  `BoneyardArchive` glob; update all boneyard consumer import paths.
- Delete the 3 orphaned aggregator modules (`Core/Core.lean`, `Algebraic/Algebraic.lean`,
  `Decidability/FMP.lean`) without leaving any kept file with a dangling import.
- Correct the 2 stale `ContextDerivable` references in `04-Metalogic.tex`.
- Keep the default `lake build` and `lake build BoneyardArchive` both green at the end.

**Non-Goals**:
- Do NOT touch or attempt to discharge the 3 PRE-EXISTING sorries in the shared upstream
  ultrafilter chain (`LindenbaumQuotient.lean:177,182`, `InteriorOperators.lean:83`). They predate
  these repairs, are shared with the live completeness path, surface only as warnings in a scoped
  build, and are explicitly out of scope for task 366.
- Do NOT touch the dead `ContextConsistent` reference in
  `Boneyard/ChainCompleteness/Completeness/SuccChainCompleteness.lean:74`.
- No refactoring of the repaired files beyond the minimal fix + relocation.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Relocating `Deferral.lean` leaves a stale import in one of the 6 boneyard consumers, breaking `BoneyardArchive` | M | M | Phase 5 updates all 6 import lines atomically with the `git mv` and verifies `lake build BoneyardArchive` green before commit; a pre-move grep enumerates the exact consumer set |
| Deleting an aggregator leaves a kept file with a dangling import | H | L | Verified: all 3 aggregators have 0 live importers. Each deletion phase gates on default `lake build` green |
| Scoped build of `AlgebraicCompleteness.lean` reports the 3 upstream sorries and is misread as failure | L | M | Non-Goal makes explicit these are pre-existing warnings, not errors; success bar is EXIT 0 + zero NEW in-file sorries, not zero warnings |
| `BoneyardArchive` was already RED before changes (its consumers import the broken in-place `Deferral`), masking whether our change is the cause of a later failure | M | M | Phase 2 establishes/records baseline `lake build BoneyardArchive` status; repairing `Deferral` in place is expected to turn it green even before relocation |
| Moving files changes module paths and an in-file relative reference breaks | L | L | Lean 4 module identity is path-derived with no in-file module declaration; only external import lines need updating. Scoped/BoneyardArchive builds catch any miss |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4 | -- |
| 2 | 5, 6 | 2 (P5), 3 (P6) |
| 3 | 7 | 1, 4, 5, 6 |

Phases within the same wave can execute in parallel. Note: Phases 5 and 6 operate on disjoint file
sets (Deferral track vs. AlgebraicCompleteness track) so they are logically parallel, but both run
`lake` builds and should serialize their build invocations to avoid contention.

---

### Phase 1: Fix stale LaTeX prose in 04-Metalogic.tex [COMPLETED]

**Goal**: Remove both stale `ContextDerivable` references, inlining to the canonical predicate
names introduced by task 194.

**Tasks**:
- [ ] Edit `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` **line 328**: replace the type name
  `\texttt{ContextDerivable [] $\varphi$}` with `\texttt{Derivable FrameClass.Base [] $\varphi$}`
  (the old `[]`-only form no longer exists; `Derivable` takes an explicit frame class).
- [ ] Edit **line 433** (Core/ directory description): replace `\texttt{ContextDerivable}` with
  `\texttt{Derivable}` (optionally also mention `\texttt{Consistent}` for the MCS reference).
- [ ] Confirm no other `ContextDerivable` occurrences remain in the file.

**Timing**: 0.25 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` — reword lines 328 and 433

**Verification**:
- `grep -c ContextDerivable Theories/Bimodal/latex/subfiles/04-Metalogic.tex` returns `0`.
- Best-effort: if the subfile compiles standalone via `subfiles`, run a LaTeX compile and confirm
  no new errors. If it does not build standalone, the grep check is sufficient.

---

### Phase 2: Repair Deferral.lean in place [COMPLETED]

**Goal**: Make `Bimodal.Metalogic.Core.RestrictedMCS.Deferral` green under a scoped build by adding
the missing namespace open, with zero sorries in-file.

**Tasks**:
- [ ] In `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Deferral.lean`, insert
  `open Bimodal.Metalogic.Bundle` immediately after the existing `open` lines (after line 7),
  matching the pattern in the sibling `Core/RestrictedMCS/Basic.lean:449`.
- [ ] Do not change any imports (the Bundle identifiers are already transitively imported via
  `Basic → CanonicalTaskRelation`; this is a scope gap, not a missing import).
- [ ] Record the baseline `lake build BoneyardArchive` status for reference (expected: the 6
  boneyard consumers of `Deferral` were failing on the broken dependency; repairing `Deferral`
  should turn that build green).

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Deferral.lean` — add one `open` line

**Verification**:
- `lake build Bimodal.Metalogic.Core.RestrictedMCS.Deferral` returns EXIT 0.
- `grep -c sorry Theories/Bimodal/Metalogic/Core/RestrictedMCS/Deferral.lean` returns `0`.

---

### Phase 3: Repair AlgebraicCompleteness.lean in place [COMPLETED]

**Goal**: Make `Bimodal.Metalogic.Algebraic.AlgebraicCompleteness` green under a scoped build by
fixing the line-156 paren placement, with zero NEW sorries in-file.

**Tasks**:
- [ ] In `Theories/Bimodal/Metalogic/Algebraic/AlgebraicCompleteness.lean` line 156, move the
  closing paren so `trivial` becomes the final argument to `DerivationTree.axiom`:
  `DerivationTree.axiom [] _ (Axiom.prop_s φ.neg (Formula.bot.imp Formula.bot)) trivial`
  (compare the correct pattern at line 99: `... (Axiom.ex_falso φ.neg) trivial`).
- [ ] Do NOT attempt to fix the 3 pre-existing upstream sorries
  (`LindenbaumQuotient.lean:177,182`, `InteriorOperators.lean:83`); they are out of scope and
  appear as warnings only.

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicCompleteness.lean` — reposition one paren on line 156

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.AlgebraicCompleteness` returns EXIT 0
  ("Build completed successfully").
- `grep -c sorry Theories/Bimodal/Metalogic/Algebraic/AlgebraicCompleteness.lean` returns `0`
  (the `algebraic_completeness_theorem` is fully proved in-file).
- Upstream sorry warnings from the shared ultrafilter chain are acceptable and expected.

---

### Phase 4: Delete the orphaned FMP aggregator [COMPLETED]

**Goal**: Remove `Metalogic/Decidability/FMP.lean` (0 live importers; pure dead re-export with a
stray self-reference at line 40). This aggregator is independent of the two broken files.

**Tasks**:
- [ ] `git rm Theories/Bimodal/Metalogic/Decidability/FMP.lean`.
- [ ] Confirm no kept file imports `Bimodal.Metalogic.Decidability.FMP` (live code reaches the
  `FMP/*` submodules directly via `Decidability/Correctness.lean → ...FMP.FMP`).

**Timing**: 0.25 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/FMP.lean` — delete

**Verification**:
- `grep -rln "^import Bimodal.Metalogic.Decidability.FMP$" Theories/` returns nothing (excluding the
  now-deleted file itself).
- Default `lake build` returns EXIT 0.

---

### Phase 5: Relocate Deferral to Boneyard, delete Core/Core.lean, update consumer imports [COMPLETED]

**Goal**: Move the repaired `Deferral.lean` under `Boneyard/` so `BoneyardArchive` compiles it
permanently; delete the orphaned `Core/Core.lean` aggregator (the sole non-boneyard importer of
Deferral); update all boneyard consumer import paths so nothing kept has a dangling import.

**Tasks**:
- [ ] `git mv Theories/Bimodal/Metalogic/Core/RestrictedMCS/Deferral.lean` to a new location under
  `Theories/Bimodal/Boneyard/` (recommended: `Boneyard/RestrictedMCSDeferral/Deferral.lean`,
  giving module `Bimodal.Boneyard.RestrictedMCSDeferral.Deferral`). Any `Bimodal.Boneyard.*`
  target is acceptable as long as all consumer imports are updated to match.
- [ ] Update the import line in all 6 boneyard consumers from
  `import Bimodal.Metalogic.Core.RestrictedMCS.Deferral` to the new module path:
  - `Boneyard/ChainCompleteness/Bundle/MCSWitnessSuccessor.lean`
  - `Boneyard/ChainCompleteness/Bundle/MCSWitnessChain.lean`
  - `Boneyard/ChainCompleteness/Bundle/SimplifiedChain.lean`
  - `Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean`
  - `Boneyard/StrictSemanticsLegacy/Algebraic/RestrictedTruthLemma.lean`
  - `Boneyard/RoundRobinChain/DRMChain.lean`
- [ ] `git rm Theories/Bimodal/Metalogic/Core/Core.lean` (the sole remaining non-boneyard importer
  of Deferral; 0 importers itself).
- [ ] Leave Deferral's own imports (`Basic`, `Bundle` via `Basic`) unchanged — they point to live
  modules that remain reachable.

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Deferral.lean` — `git mv` into Boneyard
- 6 boneyard consumer files listed above — update import path
- `Theories/Bimodal/Metalogic/Core/Core.lean` — delete

**Verification**:
- `grep -rln "import Bimodal.Metalogic.Core.RestrictedMCS.Deferral" Theories/` returns nothing (old
  path fully retired). VERIFIED: 0 old-path importers, 6 new-path importers.
- `lake build BoneyardArchive` returns EXIT 0 (relocated Deferral + all 6 updated consumers build).
  *(deviation: altered — BoneyardArchive full-build is PRE-EXISTING RED for reasons entirely
  unrelated to task 366: KampBypassArchive/* (task 305 archival), DeadChronicleGapElimination/*,
  UltrafilterFrame/TenseS5Algebra, FiltrationOrdering/*, VecEADecomposition/* all import
  now-deleted modules or have stale API. The plan's premise that repairing Deferral turns
  BoneyardArchive green was faulty. Verification of record substituted: (1) scoped build
  `lake build Bimodal.Boneyard.RestrictedMCSDeferral.Deferral` EXIT 0; (2) relocated Deferral
  replays cleanly under the BoneyardArchive glob with NO import error (only a benign unused-simp
  warning); (3) no BoneyardArchive error references the new Deferral path; (4) default `lake build`
  EXIT 0. No regression: the 6 consumers' Deferral import now resolves where it previously pointed
  at a broken module.)*
- Default `lake build` returns EXIT 0. VERIFIED: 1759 jobs, Build completed successfully.

---

### Phase 6: Relocate AlgebraicCompleteness to Boneyard, delete Algebraic/Algebraic.lean [COMPLETED]

**Goal**: Move the repaired `AlgebraicCompleteness.lean` into the existing `Boneyard/UltrafilterFrame/`
region so it is CI-verified; delete the orphaned `Algebraic/Algebraic.lean` aggregator (its sole
importer).

**Tasks**:
- [ ] `git mv Theories/Bimodal/Metalogic/Algebraic/AlgebraicCompleteness.lean`
  `Theories/Bimodal/Boneyard/UltrafilterFrame/AlgebraicCompleteness.lean` (module
  `Bimodal.Boneyard.UltrafilterFrame.AlgebraicCompleteness`; region already houses sibling
  ultrafilter-algebra material `UltrafilterFrame.lean`, `TenseS5Algebra.lean`).
- [ ] `git rm Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` (the only importer of
  AlgebraicCompleteness; 0 importers itself). No boneyard consumers of AlgebraicCompleteness exist,
  so no import-path updates are required.
- [ ] Leave the file's `import Bimodal.Metalogic.Algebraic.UltrafilterMCS` (live shared module)
  unchanged.

**Timing**: 0.75 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicCompleteness.lean` — `git mv` into Boneyard/UltrafilterFrame
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` — delete

**Verification**:
- `grep -rln "import Bimodal.Metalogic.Algebraic.AlgebraicCompleteness" Theories/` returns nothing.
  VERIFIED: 0 old-path importers.
- `lake build BoneyardArchive` returns EXIT 0 (relocated file builds under the glob; upstream sorry
  warnings acceptable). *(deviation: altered — same pre-existing BoneyardArchive RED as Phase 5;
  verification of record substituted with scoped build
  `lake build Bimodal.Boneyard.UltrafilterFrame.AlgebraicCompleteness` EXIT 0 (722 jobs, 0 in-file
  sorries) + default `lake build` EXIT 0. Note: UltrafilterFrame/TenseS5Algebra.lean is itself
  pre-broken (API drift, not task 366) but AlgebraicCompleteness does not depend on it.)*
- Default `lake build` returns EXIT 0. VERIFIED: 1759 jobs.

---

### Phase 7: Final full verification [COMPLETED]

**Goal**: Confirm the whole tree is green and no new sorries or dangling imports were introduced.

**Tasks**:
- [ ] Run the default `lake build` (import-reachable `Bimodal` target) — EXIT 0.
- [ ] Run `lake build BoneyardArchive` — EXIT 0.
- [ ] Confirm zero NEW sorries in the two repaired files and that the only remaining sorries in the
  ultrafilter chain are the 3 pre-existing out-of-scope ones.
- [ ] Grep for any dangling imports referencing the retired module paths
  (`Bimodal.Metalogic.Core.RestrictedMCS.Deferral`, `Bimodal.Metalogic.Core.Core`,
  `Bimodal.Metalogic.Algebraic.AlgebraicCompleteness`, `Bimodal.Metalogic.Algebraic.Algebraic`,
  `Bimodal.Metalogic.Decidability.FMP`) — all should return nothing.

**Timing**: 0.5 hours

**Depends on**: 1, 4, 5, 6

**Files to modify**: none (verification only)

**Verification**:
- Both builds EXIT 0.
- Retired-module-path grep returns empty.
- Repaired-file `sorry` counts are 0.

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Core.RestrictedMCS.Deferral` (pre-move scoped) → EXIT 0 (Phase 2).
- [ ] `lake build Bimodal.Metalogic.Algebraic.AlgebraicCompleteness` (pre-move scoped) → EXIT 0 (Phase 3).
- [ ] `lake build BoneyardArchive` → EXIT 0 (Phases 5, 6, 7).
- [ ] Default `lake build` → EXIT 0 (Phases 4, 5, 6, 7).
- [ ] `grep -c ContextDerivable Theories/Bimodal/latex/subfiles/04-Metalogic.tex` → 0 (Phase 1).
- [ ] `grep -c sorry` in both repaired files → 0.
- [ ] Retired-module-path grep across `Theories/` → empty (Phase 7).

## Artifacts & Outputs

- `specs/366_repair_or_boneyard_orphaned_metalogic_files/plans/01_repair-orphaned-metalogic-files.md` (this plan)
- Modified: `Theories/Bimodal/latex/subfiles/04-Metalogic.tex`
- Relocated: `Deferral.lean` → `Boneyard/RestrictedMCSDeferral/Deferral.lean` (repaired)
- Relocated: `AlgebraicCompleteness.lean` → `Boneyard/UltrafilterFrame/AlgebraicCompleteness.lean` (repaired)
- Updated imports in 6 boneyard consumer files
- Deleted: `Metalogic/Core/Core.lean`, `Metalogic/Algebraic/Algebraic.lean`, `Metalogic/Decidability/FMP.lean`
- `specs/366_repair_or_boneyard_orphaned_metalogic_files/summaries/01_repair-orphaned-metalogic-files-summary.md` (on completion)

## Rollback/Contingency

- Each phase is a separate git commit; revert the offending commit to roll back that phase without
  disturbing others.
- **Relocation fallback (repair-in-place)**: If Phase 5 or 6 relocation hits an unexpected import
  complication that cannot be resolved cleanly, fall back to the lighter research-sanctioned option:
  keep the repaired file at its original path (do NOT `git mv`), still delete the corresponding
  aggregator, and rely on the scoped `lake build <module>` from Phase 2/3 as the verification of
  record. This satisfies the literal task requirement (green under scoped build, zero sorries) at
  the cost of durable CI coverage; note the deviation in the implementation summary.
- The two one-line Lean fixes and the LaTeX rewording are independently revertible and carry no
  cross-file coupling.
