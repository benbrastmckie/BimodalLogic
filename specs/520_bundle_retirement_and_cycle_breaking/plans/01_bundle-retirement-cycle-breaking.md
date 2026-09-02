# Implementation Plan: Bundle Retirement and Cycle Breaking

- **Task**: 520 - Bundle retirement and cycle breaking
- **Status**: [IMPLEMENTING]
- **Effort**: 7.5 hours
- **Dependencies**: Task 518
- **Research Inputs**: specs/520_bundle_retirement_and_cycle_breaking/reports/01_bundle-retirement-cycle-breaking.md
- **Artifacts**: plans/01_bundle-retirement-cycle-breaking.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Break the `Core -> Bundle` directory cycle in `FormalSystem/Metalogic/` by relocating the
pure-syntax iterated-temporal machinery into `Syntax/SubformulaClosure/`, migrate the live
derivation-tree helpers out of `Bundle/ModalSaturation.lean`, and retire the resulting dead half of
`Bundle/` to the archive. Definition of done: `Metalogic/` has exactly one directory-level import
cycle (the documented `BXCanonical <-> WeakCanonical` one), every module remaining in `Bundle/` has
a live consumer, `lake build` is green, `check-module-invariants.sh` reports ALL CHECKS PASSED, and
the C2 flagship axiom baseline is byte-identical.

The work is a sequence of file relocations and import-graph surgery. Every phase is ordered so
imports are re-pointed before (or in the same commit as) the sources they name, and every phase
boundary is a green `lake build`.

### Research Integration

The research report re-measured every claim in the task description and materially revised the
scope. This plan is built on the report's measurements, not the description's. The three
load-bearing revisions:

1. **The dead set is 5 files / 2,214 lines, not 3 / 611.** Breaking the `Core -> Bundle` edge
   removes `CanonicalTaskRelation.lean`'s only live importer, orphaning it (1,050 lines), which
   cascades to `SuccRelation.lean` (553) and `CanonicalFrame.lean` (312). This is an import-edge
   fact, not a heuristic.
2. **The extraction block is 29 declarations across 3 source ranges, not 24 across 2.**
   `iter_F_succ_eq` at `CanonicalTaskRelation.lean:557-561` is an F-side lemma stranded between
   `CanonicalTask_converse` and `CanonicalTask_forward_MCS`; the description's two ranges miss it.
3. **`negBoxToBoxNegBox` is not a live shared helper.** It is declared twice and every live call
   site resolves to the `BXCanonical/Frame.lean:578` copy. The fifth live `ModalSaturation` helper
   is `dneTheorem`, which the description omits.

### Corrections to the Research Report

Two report claims were re-measured against the tree during planning and do not hold. Both make the
scope *larger*, and both are folded into the phases below.

- **The saturation layer is entirely dead, including `SaturatedBFMCS`.** Report section 2 says
  `SaturatedBFMCS` "**is** referenced by `Metalogic/Algebraic/FlowFrame.lean`" and asks the
  implementer to verify that consumer before archiving. Measured: a tree-wide grep for
  `SaturatedBFMCS|IsModallySaturated|needs_modal_witness|saturated_modal_backward|diamond_*|dniTheorem`
  across live `FormalSystem/` and `Tests/`, excluding `ModalSaturation.lean` itself, returns
  **zero** hits, and `FlowFrame.lean` does not import `ModalSaturation` at all (its only `Bundle`
  import is `TemporalCoherence`, line 9). The report's hit was a false positive on
  `TaskFrame.Saturation` / `multiFamGen_saturation`, unrelated names that grew more common after
  the Spherical-to-Saturation frame-axiom rename.

  **Consequence**: `ModalSaturation.lean` holds 18 declarations. Seven migrate (Phase 3); the
  other eleven are dead. **The file therefore retires whole, as a sixth member of the dead set**,
  rather than surviving as the report's "Survivors" list assumes. The dead set is
  **6 files / 2,735 lines**.

- **Archiving these files breaks `Boneyard/README.md`'s tree-wide EVENT-FIRST banner.** That banner
  asserts *every* file under `FormalSystem/Boneyard/` predates the guard-first `untl`/`snce`
  migration. The retiring files are live-tree files and are therefore **guard-first**:
  `SuccRelation.lean` has 10 `untl`/`snce` occurrences, `CanonicalFrame.lean` 2, and
  `CanonicalTaskRelation.lean` 2 -- 14 in total. Moving them in without a carve-out makes the
  banner false in exactly the way it warns is dangerous ("a half-swapped file compiles and silently
  means something different"). The report does not mention this. Phase 5 carries the carve-out.

### Scope Decision (user)

The conflict between the description's literal WORK list and its own acceptance criterion was put
to the user, who decided: **retire the full cascade; the acceptance criterion wins over the literal
WORK list.** This plan implements that decision.

The decision was taken on the report's 5-file framing. The planning-time re-measurement above adds
`ModalSaturation.lean` as a sixth file, and it is retired here **under the same principle the user
just chose**, not as an independent expansion of scope: once its 7 live helpers migrate, its
remaining 11 declarations have no live consumer, so leaving it in `Bundle/` would fail the very
criterion the decision prioritized. If the user wants the retirement held to exactly the five files
named in the decision, `ModalSaturation.lean` must instead be added to
`scripts/module-invariants-manifest.txt` and the acceptance criterion relaxed to "zero modules with
no live consumer, except `ModalSaturation.lean`" -- that trade is theirs to make, and this plan
flags it rather than assuming it.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `specs/ROADMAP.md` in this repository; no roadmap phases required.

## Reachability of the Stated Acceptance Criteria

The team lead asked for an explicit statement wherever the revised scope makes a stated criterion
unreachable or changes its meaning. Four items:

| Stated item | Status under revised scope |
|---|---|
| ACCEPTANCE: "`Bundle/` has zero modules with no live consumer" | **Reachable, but only at 6 retirements, not 3.** Following the description's literal WORK list (retire 3, keep `CanonicalTaskRelation` and `SuccRelation` pointed at the new module) leaves a 1,050-line orphan and *fails this criterion*. Verified reachable at 6: each of the 9 survivors (`BFMCS`, `FMCSDef`, `LimitMCS`, `LimitMCSCoherence`, `RealExtension`, `RealExtensionBundle`, `TemporalCoherence`, `TemporalContent`, `WitnessSeed`) has at least one live importer outside the unreachable `Bundle.lean` aggregator, and the `LimitMCS -> LimitMCSCoherence -> RealExtension -> RealExtensionBundle` chain is rooted in four `BXCanonical/Chronicle/` modules. |
| WORK: "delete the `SuccRelation` diary (`:432-543`) leaving a two-sentence note on why `h_p_step` is a hypothesis" | **Unreachable as written; discharged differently.** `SuccRelation.lean` is retired whole in Phase 4, so there is no live file left to hold the note. The plan does **not** silently drop the item: Phase 4's archive README records the diary's existence, its true range (`:434-541`, 108 lines, not `:432-543`/85 -- `:432-433` are real step-6 code), and the `h_p_step` explanation the note would have carried. Editing a file in the same phase it is archived is churn with no verification value. |
| WORK: fix the F-21 docstring error at `SuccRelation.lean:131-143` (measured `:135-148`) | **Discharged by removal, not by edit** -- same reasoning. The false definitional claim `F(phi) = neg(G(neg(phi)))` leaves the live tree with the file. Its contradiction source (`WitnessSeed.lean:50-53`) stays live and correct. |
| WORK: fix `UltrafilterMCS.lean:26` "Contains sorries pending MCS helper lemmas" | **In scope, with a declared file-scope deviation.** `Metalogic/Algebraic/` is not in the file scope the team lead stated, but the task WORK names the file and the fix is a single false sentence (the file has zero `sorry`; C3 asserts zero tree-wide; C14 misses it because it scans numeric counts, not this phrasing). Task 519 owns `SoundnessLemmas/`, `Soundness.lean` and `Decidability/Verified/Decidable.lean` -- `Algebraic/` collides with neither. Done in Phase 5. |

Two further description-vs-tree corrections, carried into the phases rather than argued here:
`UntilSinceCoherence.lean` forwards **three** imports, not two; and `ModalSaturation` has **4**
live direct importers and **9** live consumer modules -- the description's "nine route modules"
conflates import with use.

## Goals & Non-Goals

**Goals**:
- Eliminate the `Bundle <-> Core` directory cycle, leaving exactly one cycle in `Metalogic/`.
- Relocate 29 pure-syntax declarations verbatim (no renames) to `Syntax/SubformulaClosure/IteratedTemporal.lean`.
- Migrate the 7 live derivation-tree / MCS helpers out of `Bundle/ModalSaturation.lean` to their
  correct homes and re-point all 9 consumer modules.
- Retire the 6-file dead set to `FormalSystem/Boneyard/BundleDeadHalf/` with a README, keeping C11
  green by repointing every archived import that names them.
- Bring `Bundle/README.md`, `Metalogic/README.md` and `Boneyard/README.md` back into agreement with
  the tree.
- Keep `lake build` green and `check-module-invariants.sh` ALL PASS at every phase boundary, with
  the C2 axiom baseline unchanged.

**Non-Goals**:
- Re-proving, renaming, or restructuring any relocated declaration. Every move is verbatim; C2
  safety depends on it.
- Touching `FormalSystem/Metalogic/SoundnessLemmas/`, `Soundness.lean`, or
  `Decidability/Verified/Decidable.lean` -- task 519's territory.
- Widening the pre-existing `Theorems <-> Metalogic` top-level cycle. It exists today (four edges,
  all to `Metalogic.Core.DeductionTheorem`), is outside `Metalogic/`, and is untouched by this task.
- Migrating `untl`/`snce` argument order in the archived files. The archive is uncompiled; the
  banner gets a carve-out instead (Phase 5).
- Consolidating the MCS API or the iteration-boundedness lemmas -- that is task 526's work, which
  consumes this task's `IteratedTemporal.lean` relocation.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A relocation leaves the tree red between phases | H | M | Every phase adds the destination and re-points consumers before or in the same commit as the source deletion. Phases 3 and 4 are declared `atomic-batch`: their intermediate per-file states are expected red and must not be committed. |
| C2 axiom baseline drifts | H | L | Nothing is re-proved. Phase 1 records the baseline; Phases 3 and 5 re-run C2 with `--no-build` omitted and compare byte-for-byte. Any divergence is a HARD STOP, never a new baseline. |
| C6 fails mid-plan because a module becomes unreachable before it is archived | M | H | Anticipated, not discovered: Phase 2 adds a temporary manifest line for `CanonicalTaskRelation`, Phase 3 adds one for `ModalSaturation`, and Phase 4 deletes both plus the pre-existing `Construction` line. C6 fails both on an unmanifested unreachable module *and* on a manifest entry naming a nonexistent one, so the add and the delete are both mandatory. |
| C11 fails because archived imports dangle after the move | H | H | The moved files import each other (5 intra-set lines) and 23 archived files import them from outside. All 28 are re-pointed in the same phase as the move. The waiver file is explicitly not the escape hatch when a unique target exists. |
| C5 fails on `Bundle/README.md`'s module-shaped paths | M | H | `Bundle/README.md:142-143,151-153` contain `FormalSystem.Metalogic.Bundle.Construction` and `...CanonicalFrame` in usage blocks. C5 asserts every module-shaped path in non-specs markdown resolves; these break the moment the files move. **The whole of `Bundle/README.md` is therefore regenerated inside Phase 4, the phase that moves the files** -- the document the move breaks is repaired by the same commit, so no phase boundary is ever left with a red gate. |
| Name ambiguity when a migrated helper is visible under two namespaces | M | M | Phase 3 is a single atomic batch: no window exists in which both the `Bundle` and the `Theorems.ModalDerived` copy are in scope. `Tests/BimodalTest/TableauConformance.lean:201`'s `private def iterF` was checked and cleared -- Lean 4 prefers the current-namespace declaration over an `open`ed one. |
| Phases 2 and 3 run in parallel and collide on the manifest | L | M | `scripts/module-invariants-manifest.txt` is the only file both touch. Each appends one line in its own block; a collision is a trivial textual merge. If dispatched in parallel, assign the manifest to whichever finishes second, or serialize. |
| Deleting `ChronicleToCountermodelBasic.lean:9` outright reddens the build | M | L | Measured: the import-closure delta is exactly one substantive module (`Bundle.SuccRelation`), and the file's only `Succ` match is `:1139`, a docstring about `Order.SuccPred`. Delete outright and let `lake build` adjudicate. Under the 6-file retirement there is no fallback import to add, so a red build here means a genuine hidden dependency and must be investigated, not papered over. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel. Phases 2 and 3 are file-disjoint except for
`scripts/module-invariants-manifest.txt`; see the Risks table.

---

### Phase 1: Capture the baseline and confirm the revised scope [COMPLETED]

**Goal**: Record the pre-edit gate state so "C2 baseline unchanged" and "ALL PASS" are verifiable
claims at the end, and confirm at implementation time every count this plan asserts.

**Tasks**:
- [x] Run `bash scripts/check-module-invariants.sh` (full, with build) and save the complete output
      to `specs/520_bundle_retirement_and_cycle_breaking/summaries/00_baseline.md`. Record
      verbatim: the four C2 axiom lines, the C4 import-line total, the C7 live/reachable/unreachable
      counts, and the C11 archived-import-line and waived counts.
- [x] Confirm the extraction block: `CanonicalTaskRelation.lean` ranges `:59-196` (13 decls),
      `:557-561` (1 decl, `iter_F_succ_eq`), `:699-844` (15 decls) = 29. Record the exact
      declaration names in the baseline file.
- [x] Confirm purity of the block: grep the three ranges for `SetMaximalConsistent`,
      `MaximalConsistent`, `Succ`, `GContent`, `FContent`, `HContent`, `PContent`, `FrameClass`,
      `Derivable`, `Consistent`, `Provable` -- expect zero hits.
- [x] Confirm the `ModalSaturation` consumer matrix: 9 consumer modules, and 2 unqualified
      `SetMaximalConsistent.contrapositive` sites (`CanonicalModel.lean:839`,
      `CompletenessDedekind.lean:477`). Record file:line for **every** reference.
      **Settle the fully-qualified count here.** The report's prose says 7 such references, but its
      own consumer matrix marks 5 modules "fully qualified" carrying 9 references between them,
      plus one "mixed" module -- the two numbers do not reconcile. Every hand-written
      `FormalSystem.Metalogic.Bundle.<name>` reference must be rewritten, not merely re-imported,
      so the enumeration is what matters, not the total. Produce it by grepping the live tree for
      `FormalSystem\.Metalogic\.Bundle\.(dneTheorem|boxDneTheorem|modal5CollapseTheorem|axiom5NegativeIntrospection|negBoxToBoxNegBox|SetMaximalConsistent)` and record every hit.
- [x] Re-confirm the saturation layer is fully dead (see "Corrections" above): tree-wide grep for
      `SaturatedBFMCS|IsModallySaturated|needs_modal_witness|saturated_modal_backward|diamond_eq|diamond_excludes_box_neg|diamond_and_not_psi_implies_neg|diamond_implies_psi_consistent|dniTheorem`
      across live `FormalSystem/` and `Tests/`, excluding `Bundle/ModalSaturation.lean`. **Expect
      zero.** A nonzero result invalidates the 6th retirement and must be reported before Phase 3
      proceeds.
- [x] Confirm the archived import inventory: 22 lines naming the 5 original dead files plus 1
      naming `ModalSaturation` (`StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean:6`) = 23
      external, plus 5 intra-set lines (`Construction:8`, `UntilSinceCoherence:8`,
      `CanonicalTaskRelation:7,8`, `SuccRelation:8`) = **28 total**. Record each as file:line.
- [x] Confirm each of the 9 `Bundle/` survivors has a live importer outside `Bundle.lean`.
- [x] Count the `untl`/`snce` occurrences in the retiring files (expected 14: SuccRelation 10,
      CanonicalFrame 2, CanonicalTaskRelation 2) for the Phase 5 banner carve-out.
      *(deviation: altered -- the plan's per-file figures are lines, mine were occurrences.
      `SuccRelation.lean` has 12 occurrences on 10 lines; `CanonicalTaskRelation.lean`'s 2 sit
      inside the relocated block and moved to the live `IteratedTemporal.lean` in Phase 2, so they
      never reach the archive. What travels: 14 occurrences / 12 lines / 2 files. The plan's
      total of 14 stands; only the split changed.)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase exists to convert every count in this plan from hypothesis to
measurement. Asserted: 29 extracted declarations across 3 ranges; 6 files / 2,735 lines in the dead
set; 18 declarations in `ModalSaturation.lean` of which 7 migrate and 11 are dead; 9 consumer
modules with 7 fully-qualified references; 28 archived import lines to re-point; 9 surviving
`Bundle/` modules each with a live importer; 14 `untl`/`snce` occurrences moving into the archive.
Confirm each by the command in its task bullet and record the result. **Any divergence is reported
in the phase summary before the dependent phase starts** -- a count that comes back different is a
finding, not a number to quietly overwrite.

**Files to modify**:
- `specs/520_bundle_retirement_and_cycle_breaking/summaries/00_baseline.md` - new; the recorded
  pre-edit gate state and confirmed counts

**Verification**:
- The baseline file exists and contains the four C2 axiom lines verbatim.
- `check-module-invariants.sh` reports ALL CHECKS PASSED before any edit.
- Every count above is recorded with the command that produced it.

---

### Phase 2: Break the Core -> Bundle cycle via IteratedTemporal.lean [COMPLETED]

**Goal**: Move the 29 pure-syntax iterated-temporal declarations into `Syntax/SubformulaClosure/`
and delete the single `Core -> Bundle` import edge, taking `Metalogic/`'s directory-level cycle
count from 2 to 1.

**Tasks**:
- [x] Create `FormalSystem/Syntax/SubformulaClosure/IteratedTemporal.lean` with the standard
      copyright header, `import FormalSystem.Syntax.SubformulaClosure.NestingDepth` as its **sole**
      import, and `namespace FormalSystem.Syntax`.
- [x] Copy the 29 declarations **verbatim, no renames**, preserving source order within each range:
      - from `:59-196`: `iterF`, `iter_F_zero`, `iter_F_succ`, `some_future_complexity`,
        `iter_F_complexity`, `iter_F_complexity_strictly_increasing`, `iter_F_injective`,
        `iter_F_one_eq_some_future`, `iter_F_f_nesting_depth`, `closureFBound`,
        `iter_F_exceeds_max_depth`, `iter_F_not_mem_closureWithNeg`, `iter_F_leaves_closure`
      - from `:557-561`: `iter_F_succ_eq`
      - from `:699-844`: `iterP`, `iter_P_zero`, `iter_P_succ`, `iter_P_some_past`,
        `iter_P_succ_eq`, `some_past_complexity`, `iter_P_complexity`,
        `iter_P_complexity_strictly_increasing`, `iter_P_injective`, `iter_P_one_eq_some_past`,
        `iter_P_p_nesting_depth`, `closurePBound`, `iter_P_exceeds_max_depth`,
        `iter_P_not_mem_closureWithNeg`, `iter_P_leaves_closure`
- [x] Add `import FormalSystem.Syntax.SubformulaClosure.IteratedTemporal` to `FormalSystem/Syntax.lean`
      (after the `TemporalFormulas` line at `:12`).
- [x] `FormalSystem/Metalogic/Core/RestrictedMCS/Basic.lean`: replace `:12`'s
      `import FormalSystem.Metalogic.Bundle.CanonicalTaskRelation` with
      `import FormalSystem.Syntax.SubformulaClosure.IteratedTemporal`, and **delete `:459`'s
      `open FormalSystem.Metalogic.Bundle`** -- it exists solely for these names, and `:51` already
      carries `open FormalSystem.Syntax`.
- [x] `FormalSystem/Metalogic/Bundle/CanonicalTaskRelation.lean`: delete the three ranges, add
      `import FormalSystem.Syntax.SubformulaClosure.IteratedTemporal`. `:55` already has
      `open FormalSystem.Syntax`, so its remaining 32 declarations keep resolving unqualified.
- [x] Add `FormalSystem.Metalogic.Bundle.CanonicalTaskRelation` to
      `scripts/module-invariants-manifest.txt` under a comment marking it **temporary, deleted in
      Phase 4**. The file loses its only live importer in this phase and becomes unreachable;
      without this line C6 fails.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Asserts 29 declarations across three named ranges, that `Basic.lean` uses
exactly 10 of them and nothing else from `CanonicalTaskRelation.lean`, and that
`IteratedTemporal.lean` needs exactly one import. Confirm by: the Phase 1 record; building
`IteratedTemporal.lean` in isolation with only the `NestingDepth` import (a second required import
means the purity claim was wrong and must be reported); and grepping `Basic.lean` for any surviving
`CanonicalTaskRelation` name after the swap.

**Files to modify**:
- `FormalSystem/Syntax/SubformulaClosure/IteratedTemporal.lean` - new; 29 verbatim declarations, one import
- `FormalSystem/Syntax.lean` - +1 import line
- `FormalSystem/Metalogic/Core/RestrictedMCS/Basic.lean` - `:12` import swap; `:459` `open` deletion
- `FormalSystem/Metalogic/Bundle/CanonicalTaskRelation.lean` - delete 3 ranges; +1 import
- `scripts/module-invariants-manifest.txt` - +1 temporary entry

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` ALL PASS, including C6's isolated compile of the newly
  manifested `CanonicalTaskRelation`.
- C2 axiom output byte-identical to the Phase 1 baseline.
- `grep -rn "Metalogic.Bundle" FormalSystem/Metalogic/Core/` returns nothing -- the `Core -> Bundle`
  edge is gone.
- No declaration in `IteratedTemporal.lean` differs from its source by anything but position.
- C8 is unaffected: `SubformulaClosure/` is depth-2 and outside C8's scan of `FormalSystem/` and
  `FormalSystem/Metalogic/` subdirectories, so no sibling `SubformulaClosure.lean` is owed.

---

### Phase 3: Migrate the live ModalSaturation helpers [COMPLETED]

**Goal**: Move the 7 live helpers out of `Bundle/ModalSaturation.lean` to their correct homes and
re-point all 9 consumer modules, leaving `ModalSaturation.lean` holding only dead declarations.

**Tasks**:
- [x] Create `FormalSystem/Theorems/ModalDerived.lean`, `namespace FormalSystem.Theorems.ModalDerived`
      (matching the sibling convention in `Theorems/`: `ModalS4`, `ModalS5`, `TemporalDerived`,
      `DedekindDerived` all use `FormalSystem.Theorems.<Module>`). Imports:
      `FormalSystem.Theorems.Propositional.Connectives` plus whatever `Syntax`/`ProofSystem` the
      moved bodies need. **No `Metalogic` import** -- adding one would widen the pre-existing
      `Theorems <-> Metalogic` cycle as a side effect.
- [x] Move verbatim into it, from `Bundle/ModalSaturation.lean`: `dneTheorem` (`:229`),
      `boxDneTheorem` (`:262`), `modal5CollapseTheorem` (`:404`), `axiom5NegativeIntrospection`
      (`:422`), `negBoxToBoxNegBox` (`:502`). Note `negBoxToBoxNegBox` moves as an internal
      dependency of `neg_box_implies_box_neg_box`, **not** as a public helper -- it has zero live
      cross-file consumers, every live call site resolving to the independent
      `BXCanonical/Frame.lean:578` proof.
- [x] Move verbatim into it, as consolidation: `gDneTheorem` and `hDneTheorem`
      (`Bundle/TemporalCoherence.lean:66,82`) and `pastTempA` (`Bundle/WitnessSeed.lean:567`). All
      three are file-local today with zero cross-file consumers; both host files already import
      `Theorems.*`, so no new directory edge appears.
- [x] Move `SetMaximalConsistent.contrapositive` (`:281`) and
      `SetMaximalConsistent.neg_box_implies_box_neg_box` (`:511`) into
      `FormalSystem/Metalogic/Core/MCSProperties.lean`, **not** into `Theorems/ModalDerived.lean`.
      They need `theorem_in_mcs` (`Core/MaximalConsistent.lean:491`) and
      `SetMaximalConsistent.implication_property` (`MCSProperties.lean:157`); hosting them in
      `Theorems/` would widen the `Theorems <-> Metalogic` edge. `MCSProperties.lean` already
      imports `Theorems.TemporalDerived`, so adding `import FormalSystem.Theorems.ModalDerived`
      introduces no cycle: the chain `ModalDerived -> Propositional.Connectives ->
      Propositional.Core -> Core.DeductionTheorem` never returns to `MCSProperties`.
- [x] Delete all 7 declarations from their source files.
- [x] Add `import FormalSystem.Theorems.ModalDerived` to `FormalSystem/Theorems.lean`.
- [x] Re-point the 9 consumers, adding `import FormalSystem.Theorems.ModalDerived` (and/or the
      `MCSProperties` import where absent) and fixing references:
      - `Bundle/TemporalCoherence.lean` -- `dneTheorem` at `:68,84,108,126,138` (unqualified)
      - `BXCanonical/CanonicalModel.lean` -- `boxDneTheorem` `:840`, `SMC.contrapositive` `:839` (unqualified)
      - `BXCanonical/CompletenessDedekind.lean` -- `:478`, `:477` (mixed)
      - `BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- `:1160`, `:1159` (fully qualified)
      - `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` -- `:588`, `:587` (fully qualified)
      - `WeakCanonical/GroupModel/CountermodelBase.lean` -- `:299`, `:298` (fully qualified)
      - `WeakCanonical/IntegerModel/ReynoldsBridge.lean` -- `:1119`, `:1118` (fully qualified)
      - `BXCanonical/Chronicle/ChronicleTypes.lean` -- `axiom5NegativeIntrospection` `:224` (fully qualified)
      - `BXCanonical/Chronicle/MCSMixedCase.lean` -- `neg_box_implies_box_neg_box` `:58` (unqualified)
- [x] Rewrite **every** hand-written fully-qualified `FormalSystem.Metalogic.Bundle.<name>`
      reference, per the enumeration Phase 1 produced -- re-importing alone does not fix them. Use
      the enumeration, not the report's unreconciled count of 7.
- [x] At `CanonicalModel.lean:839` and `CompletenessDedekind.lean:477`, add
      `open FormalSystem.Metalogic.Core` (or requalify): neither file currently opens the
      destination namespace for the unqualified `SetMaximalConsistent.contrapositive`. No call site
      uses generalized field notation (`h.contrapositive`), so no dot-notation resolution is at risk.
      *(deviation: skipped -- both files already carry `open FormalSystem.Metalogic.Core`
      (`CanonicalModel.lean:33`, `CompletenessDedekind.lean:58`), so the unqualified references
      resolve at the new home with no edit. `Chronicle/MCSMixedCase.lean:58` is the same case and
      needed no edit either.)*
- [x] Consumers referencing the derivation-tree helpers unqualified need
      `open FormalSystem.Theorems.ModalDerived` (or requalification) -- the new namespace is
      `Theorems.ModalDerived`, not bare `Theorems`.
      *(deviation: altered -- every cross-file reference was fully qualified as
      `FormalSystem.Theorems.ModalDerived.<name>` instead, including the previously unqualified
      `CanonicalModel.lean:840`. Only the two files that host unqualified uses of `dneTheorem`
      internally (`Bundle/TemporalCoherence.lean`, `Bundle/ModalSaturation.lean`) got the `open`.)*
- [x] Fix the `pastTempA` docstring at its new home: the body is
      `DerivationTree.axiom [] _ (Axiom.connect_past psi) trivial`, a **direct axiom application**,
      not a derivation. `temp_a` is not an `Axiom` constructor (`ProofSystem/Axioms.lean:174` has
      `connect_past`); it survives only as a tactic-facing string in `Automation/` and tests. The
      nonexistent name appears **three** times in `WitnessSeed.lean` (`:561`, `:565-566`, `:573`) --
      correct all three, not just the one the description names.
      *(deviation: altered -- measured **four** `temp_a` lines in `WitnessSeed.lean`
      (`:561`, `:565`, `:566`, `:572`), not three. `:565-566` is `pastTempA`'s own docstring and
      travelled with the declaration, rewritten at its new home; `:561` and `:572` were corrected
      in place to name `Axiom.connect_future` / `Axiom.connect_past`.)*
- [x] `dniTheorem` (`:238`) has zero references anywhere, internal or external. Do **not** move it;
      it retires with the file in Phase 4.
- [x] Add `FormalSystem.Metalogic.Bundle.ModalSaturation` to
      `scripts/module-invariants-manifest.txt` under a comment marking it **temporary, deleted in
      Phase 4**. Its live importers after this phase are `Bundle.lean` (unreachable aggregator) and
      `Bundle/Construction.lean` (itself unreachable and manifested), so it becomes unreachable.
      `Construction.lean` references none of the migrating names -- verified -- so C6's isolated
      compile of it still succeeds.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Asserts 7 declarations move, 9 consumer modules are re-pointed, 2 sites need
an added `open`, and `dniTheorem` is dead. The count of fully-qualified rewrites is deliberately
**not** asserted -- the report's prose (7) and its own matrix (9 across 5 modules plus a mixed
sixth) disagree, so Phase 1's enumeration is authoritative. Confirm against the Phase 1 record,
then close the loop with a tree-wide grep for
`FormalSystem.Metalogic.Bundle.(dneTheorem|boxDneTheorem|modal5CollapseTheorem|axiom5NegativeIntrospection|negBoxToBoxNegBox|contrapositive|neg_box_implies_box_neg_box)`
across live files -- expect zero hits after the phase.

**Files to modify**:
- `FormalSystem/Theorems/ModalDerived.lean` - new; 8 derivation-tree helpers
- `FormalSystem/Theorems.lean` - +1 import line
- `FormalSystem/Metalogic/Core/MCSProperties.lean` - +2 `SetMaximalConsistent` lemmas, +1 import
- `FormalSystem/Metalogic/Bundle/ModalSaturation.lean` - delete 7 declarations
- `FormalSystem/Metalogic/Bundle/TemporalCoherence.lean` - delete `gDneTheorem`/`hDneTheorem`; re-point `dneTheorem`
- `FormalSystem/Metalogic/Bundle/WitnessSeed.lean` - delete `pastTempA`; fix 3 `temp_a` mentions
- `FormalSystem/Metalogic/BXCanonical/CanonicalModel.lean` - re-point; add `open`
- `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` - re-point; add `open`
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - re-point (qualified)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` - re-point (qualified)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` - re-point (qualified)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean` - re-point
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` - re-point (qualified)
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` - re-point (qualified)
- `scripts/module-invariants-manifest.txt` - +1 temporary entry

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` ALL PASS.
- **C2 axiom output byte-identical to the Phase 1 baseline.** This is the phase most likely to move
  it -- relocation changes namespaces, not axiom sets, and stays safe only while nothing is
  re-proved. Divergence is a HARD STOP.
- Zero live occurrences of the 7 migrated names under the `FormalSystem.Metalogic.Bundle` prefix.
- `Metalogic/` still has exactly the one cycle Phase 2 left; `Theorems <-> Metalogic` is unchanged
  at four edges, all to `Metalogic.Core.DeductionTheorem`.

---

### Phase 4: Retire the dead set and re-point the archive [COMPLETED]

**Goal**: Move the 6 dead modules to `FormalSystem/Boneyard/BundleDeadHalf/`, delete the live
imports that named them, and keep C11 green by re-pointing all 28 archived import lines.

**Tasks**:
- [x] Create `FormalSystem/Boneyard/BundleDeadHalf/` and `git mv` into it:
      `CanonicalFrame.lean`, `Construction.lean`, `UntilSinceCoherence.lean`,
      `CanonicalTaskRelation.lean`, `SuccRelation.lean`, `ModalSaturation.lean`.
- [x] Re-point the **5 intra-set** import lines to the new
      `FormalSystem.Boneyard.BundleDeadHalf.<Module>` paths: `Construction.lean:8` (ModalSaturation),
      `UntilSinceCoherence.lean:8` (SuccRelation), `CanonicalTaskRelation.lean:7,8` (SuccRelation,
      CanonicalFrame), `SuccRelation.lean:8` (CanonicalFrame). Their imports of *surviving* Bundle
      and Core modules still resolve and stay as they are.
- [x] Re-point the **23 external archived** import lines across 14 archived files:
      - `Bundle.CanonicalFrame` (6): `SorriedDeclExcisions/BundleUntilSinceStep.lean:8`,
        `DeadCanonicalModel/CanonicalIrreflexivity.lean:1`,
        `SorriedDeclExcisions/SingletonSorriedDecls.lean:6`,
        `ChainCompleteness/Algebraic/DeterministicFMCS.lean:6`,
        `ChainCompleteness/Bundle/TargetedChain.lean:2`,
        `StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean:2`
      - `Bundle.Construction` (2): `BundleSuccessorSeed/SuccExistence.lean:9`,
        `ChainCompleteness/Completeness/SuccChainCompleteness.lean:2`
      - `Bundle.UntilSinceCoherence` (4): `QuasimodelOracle/OracleCoherence.lean:4`,
        `DefectDirectedChain/RootScopedChain.lean:3`, `ScheduleBasedBFMCS/RootScopedChain.lean:2`,
        `StrictSemanticsLegacy/FrameConditions/Completeness.lean:5`
      - `Bundle.CanonicalTaskRelation` (4): `RoundRobinChain/DRMChain.lean:4`,
        `DeadCanonicalModel/CanonicalIrreflexivity.lean:4`,
        `ChainCompleteness/Bundle/ResolvingChain.lean:3`,
        `StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:2`
      - `Bundle.SuccRelation` (6): `DeadCanonicalModel/CanonicalIrreflexivity.lean:3`,
        `RoundRobinChain/DRMChain.lean:3`, `ChainCompleteness/Bundle/ResolvingChain.lean:4`,
        `SorriedDeclExcisions/UntilSinceCoherence.lean:2`,
        `ChainCompleteness/Algebraic/DeterministicChain.lean:5`,
        `BundleSuccessorSeed/SuccExistence.lean:7`
      - `Bundle.ModalSaturation` (1): `StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean:6`
      Do **not** reach for `scripts/boneyard-import-waivers.txt`: a waiver is for an import with no
      unique target, and every one of these has one.
      *(deviation: altered -- the 23 external lines sit in **18** archived files, not 14. The
      plan's own enumeration lists 23 entries over 18 distinct paths; `CanonicalIrreflevity`
      appears 3x and `DRMChain`/`ResolvingChain`/`SuccExistence` 2x each, which is where the
      14 came from. No waiver was added.)*
- [x] Delete `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:9`
      (`import ...Bundle.UntilSinceCoherence`) outright. The measured closure delta is one
      substantive module (`Bundle.SuccRelation`), which the file does not use -- its only `Succ`
      match is `:1139`, a docstring about `Order.SuccPred`. `TemporalCoherence` and
      `Theorems.TemporalDerived` are already reachable via `ChronicleConstruction`/`CanonicalModel`,
      so the description's "import TemporalCoherence and SuccRelation directly" over-corrects on
      both counts.
- [x] Delete `FormalSystem/Metalogic/BXCanonical/Frame.lean:11`
      (`import ...Bundle.CanonicalFrame`) -- unused; `:223` and `:235` re-prove the same content as
      `bx_forward_witness`/`bx_backward_witness`.
- [x] `FormalSystem/Metalogic/Bundle.lean`: delete the 6 imports of the retired modules **and** the
      duplicate `import FormalSystem.Metalogic.Bundle.FMCSDef` (declared at both `:11` and `:12`).
- [x] `scripts/module-invariants-manifest.txt`: delete the pre-existing
      `FormalSystem.Metalogic.Bundle.Construction` line and both temporary entries added in Phases 2
      and 3. C6 fails on a manifest entry naming a nonexistent module, so all three deletions are
      mandatory in this phase.
- [x] Write `FormalSystem/Boneyard/BundleDeadHalf/README.md` recording: what each of the 6 modules
      was, why it died (the `Core -> Bundle` cycle break and its cascade), the retirement date, and
      three specific notes --
      (a) the `SuccRelation.lean:434-541` proof diary is preserved as archived, and `h_p_step` is a
      **hypothesis** because `Succ` supplies the F-step (`FContent u` subset of `v` union
      `FContent v`) but not its P-dual, so callers that construct predecessors discharge it;
      (b) `Succ_implies_CanonicalR` (`SuccRelation.lean:97`) was the only consumer of
      `CanonicalFrame.ExistsTask`, and its body `h.1` is identical to `Succ.g_persistence`
      (`SuccRelation.lean:78`) -- it was retired as a duplicate rather than relocated, and
      `ExistsTaskPast`/`ExistsTask_past_def` had zero uses of any kind;
      (c) `Construction.lean` advertised `constantBFMCS` at `:20` and `:246` but never declared it
      (`:71` is a `## REMOVED:` tombstone) and its `## History` heading at `:22` was empty --
      recorded here rather than fixed in place;
      (d) **these files are GUARD-FIRST** and are the exception to the archive-wide EVENT-FIRST
      banner (see Phase 5).
- [x] Note in the README that `Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:2990` calls
      `FormalSystem.Metalogic.Bundle.iter_F_f_nesting_depth` by fully-qualified name, which went
      stale in Phase 2. C11 checks imports, not identifiers, so no gate fails; the record is the fix.
- [x] **Regenerate `FormalSystem/Metalogic/Bundle/README.md` in this phase, not a later one.** The
      move breaks it, so the move repairs it -- this is what keeps C5 green at the phase boundary:
      - **Fix the C5-load-bearing usage blocks `:142-143` and `:151-153`.** They contain the
        module-shaped paths `FormalSystem.Metalogic.Bundle.Construction` and `...CanonicalFrame`;
        C5 asserts every module-shaped `FormalSystem.*` path in non-specs markdown resolves, so
        these fail the instant the files move. Not cosmetic.
      - Regenerate the architecture block `:44-60`. It currently lists three files that do not
        exist (`FMCS.lean:46`, `CanonicalIrreflexivity.lean:54`, `SuccExistence.lean:56`) **and
        omits four that do** (`LimitMCS.lean`, `LimitMCSCoherence.lean`, `RealExtension.lean`,
        `RealExtensionBundle.lean`). Rebuild it from the 9 surviving modules.
      - Rebuild the Main Theorems table `:66-68` -- two of its three rows point at retired files.
      - Update `:18` and `:171`, which also reference retired material.
      *(deviation: altered -- `Metalogic/README.md`'s Cycle 2 section had to be deleted in this
      phase too, not Phase 5. `:98` names `FormalSystem.Metalogic.Bundle.CanonicalTaskRelation`,
      a module-shaped path C5 resolves, so the move reddened C5 there as well as in
      `Bundle/README.md`. The diagram back-edge, the "two cycles" wording and the Cycle 2 block
      are therefore Phase 4 work; the remaining `Metalogic/README.md` items (Cycle 1 edge counts,
      aggregator row, inventory row, declined-regroup paragraph) stay in Phase 5.
      `docs/architecture/BFMCS_ARCHITECTURE.md:165,168,297` broke C12 for the same reason --
      slash-shaped paths to three retired modules -- and were re-pointed here.)*

**Timing**: 2.5 hours

**Depends on**: 2, 3

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Asserts 6 files move, 28 archived import lines are re-pointed (5 intra-set +
23 external across 14 files), 3 manifest lines are deleted, and 2 live imports plus 7 aggregator
lines are removed. Confirm against the Phase 1 record; then close the loop with
`grep -rn "^import FormalSystem\.Metalogic\.Bundle\.\(CanonicalFrame\|Construction\|UntilSinceCoherence\|CanonicalTaskRelation\|SuccRelation\|ModalSaturation\)$" FormalSystem/`
-- expect zero hits tree-wide, live and archived.

**Files to modify**:
- `FormalSystem/Boneyard/BundleDeadHalf/` - new directory; 6 relocated modules + README.md
- `FormalSystem/Metalogic/Bundle/{CanonicalFrame,Construction,UntilSinceCoherence,CanonicalTaskRelation,SuccRelation,ModalSaturation}.lean` - removed (git mv)
- `FormalSystem/Metalogic/Bundle.lean` - delete 6 retired imports + 1 duplicate
- `FormalSystem/Metalogic/BXCanonical/Frame.lean` - delete `:11`
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` - delete `:9`
- 14 files under `FormalSystem/Boneyard/` - 23 import-line re-points
- `FormalSystem/Metalogic/Bundle/README.md` - C5 usage blocks, architecture block, Main Theorems table, `:18`, `:171`
- `scripts/module-invariants-manifest.txt` - delete 3 entries

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` reports **ALL CHECKS PASSED** -- C5 included. The
  `Bundle/README.md` regeneration is in this phase precisely so this boundary is green; a C5
  failure here means a module-shaped path was missed, not that the fix is owed to a later phase.
- C11 is the sharp check. **The plan's prediction here was wrong and the measured behaviour is
  correct**: the total is not unchanged. It went 497 -> 527 because the six moved files bring
  their own 30 import lines into the archived population, which the "lines are re-pointed, not
  added or removed" reasoning overlooked. All 527 resolve, the waived count is unchanged at 7,
  and the archived-file count went 156 -> 162.
- C2 axiom output byte-identical to the Phase 1 baseline.
- `ls FormalSystem/Metalogic/Bundle/` shows exactly the 9 survivors.

---

### Phase 5: Documentation coherence and final gate [NOT STARTED]

**Goal**: Bring the documents that describe `Metalogic/` and the archive as a whole back into
agreement with the tree, discharge the remaining live-tree docstring defect, and make the
cycle-count acceptance criterion mechanically checkable.

`Bundle/README.md` is deliberately **not** in this phase: it is regenerated in Phase 4, alongside
the move that breaks it, so no phase boundary is left with a red C5.

**Tasks**:
- [ ] `FormalSystem/Metalogic/README.md`:
      - ASCII diagram at `:50,54` -- remove the `Core/ <-> Bundle/` back-edge.
      - Change "There are exactly **two** directory-level cycles" to one.
      - **Correct the stale Cycle 1 edge counts before deleting Cycle 2.** The file records
        `BXCanonical -> WeakCanonical (2 import lines)` and `WeakCanonical -> BXCanonical (4)`;
        measured today they are **9 and 6**, with `Chronicle/ChronicleMonadicBridge.lean` alone
        contributing 6 forward edges the README never mentions. Re-enumerate from the tree.
      - Delete the Cycle 2 section at `:93-99`.
      - Rewrite the declined-regroup paragraph at `:115-118`, which records breaking this cycle as
        "touches 9 files" for a different, abandoned plan (relocating `Basic.lean` itself).
      - Update the `Bundle.lean | 52` aggregator row at `:128` and the `Bundle/ | 15 | 6,106`
        inventory row at `:183` -- the row is also wrong today (actual 6,073, not 6,106); recount
        rather than subtracting from the stale figure.
- [ ] `FormalSystem/Boneyard/README.md`:
      - Update the counts table: +6 files, +1 subdirectory, and the measured line delta. **Recount
        the moved lines rather than using 2,735**: Phase 2 removed ~289 lines from
        `CanonicalTaskRelation.lean` and Phase 3 removed 7 declarations from `ModalSaturation.lean`
        before either moved.
      - **Add a carve-out to the CONVENTION WARNING at `:7`.** The banner asserts every file in the
        tree is event-first and predates the guard-first migration. `BundleDeadHalf/` is the first
        exception: its files are guard-first, with 14 `untl`/`snce` occurrences
        (`SuccRelation.lean` 10, `CanonicalFrame.lean` 2, `CanonicalTaskRelation.lean` 2). Name the
        directory explicitly and say its contents need **no** argument swap on resurrection --
        applying the banner's swap instruction to them would silently invert their meaning, which is
        exactly the failure mode the banner exists to prevent.
- [ ] `FormalSystem/Metalogic/Algebraic/UltrafilterMCS.lean:26`: delete the false claim "Contains
      sorries pending MCS helper lemmas." The file has zero `sorry` occurrences and C3 asserts zero
      tree-wide; C14 misses it because it scans numeric counts, not this phrasing. **This is a
      declared deviation from the stated file scope** -- `Metalogic/Algebraic/` was not listed, but
      the task WORK names the file, it is a one-line prose fix, and it collides with no file task
      519 owns.
- [ ] Add `scripts/check-metalogic-cycles.sh`: enumerate directory-level import edges within
      `FormalSystem/Metalogic/`, excluding sibling aggregators as edge *sources* (an aggregator
      importing its own directory is a convention artifact, not a design cycle), and assert the
      cycle count equals 1. This makes "cycles = 1" mechanically verifiable instead of argued --
      research Open Decision 5. Keep it standalone (catalogued as a utility script); do not wire it
      into `check-module-invariants.sh` in this task.
- [ ] Run the full gate and reconcile every count in the touched READMEs against its output.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: Asserts `Metalogic/README.md`'s Cycle 1 edge counts are 9 and 6 (not the
recorded 2 and 4), the `Bundle/` inventory row is wrong today at 6,106 vs. an actual 6,073, and
`Boneyard/README.md`'s current baseline is 156 files / 88,275 lines / 35 top-level dirs. Confirm all
by recounting from the tree at implementation time; every figure written into a README must come
from a command run in this phase, not from this plan.

**Files to modify**:
- `FormalSystem/Metalogic/README.md` - diagram, cycle count, Cycle 1 edge list, delete Cycle 2, aggregator row, inventory row, declined-regroup paragraph
- `FormalSystem/Boneyard/README.md` - counts table, EVENT-FIRST banner carve-out
- `FormalSystem/Metalogic/Algebraic/UltrafilterMCS.lean` - `:26` false sorry claim
- `scripts/check-metalogic-cycles.sh` - new

**Verification**:
- `bash scripts/check-module-invariants.sh` reports **ALL CHECKS PASSED**, C5 included.
- `bash scripts/check-metalogic-cycles.sh` reports exactly 1 cycle.
- C2 axiom output byte-identical to the Phase 1 baseline.
- No module-shaped path in any non-specs markdown names a retired `Bundle/` module.
- `Boneyard/README.md`'s banner names `BundleDeadHalf/` as guard-first.

---

## Testing & Validation

- [ ] `lake build` green at every phase boundary (Phases 2, 3, 4, 5).
- [ ] `bash scripts/check-module-invariants.sh` ALL CHECKS PASSED at the end of **every** phase,
      C5 included. No phase boundary is permitted to leave a check red: `Bundle/README.md` is
      regenerated inside Phase 4, the phase whose move would otherwise break it.
- [ ] C2: the four flagship axiom lines byte-identical to the Phase 1 baseline at the end of every
      phase. Divergence is a HARD STOP, never a re-baselining.
- [ ] C3 unaffected: zero structural sorries before and after; nothing here introduces one.
- [ ] C11: archived import-line total unchanged from baseline, waived count unchanged, zero dangling.
- [ ] C6: zero unmanifested unreachable modules, zero manifest entries naming a nonexistent or
      reachable module.
- [ ] ACCEPTANCE -- directory-level import cycles in `Metalogic/` = 1, and it is the
      `BXCanonical <-> WeakCanonical` one: verified by `scripts/check-metalogic-cycles.sh` and by
      `grep -rn "Metalogic.Bundle" FormalSystem/Metalogic/Core/` returning nothing.
- [ ] ACCEPTANCE -- `Bundle/` has zero modules with no live consumer: for each of the 9 survivors,
      at least one live importer outside `Bundle.lean`.
- [ ] `Tests/BimodalTest` builds; `TableauConformance.lean`'s `private def iterF` still resolves to
      its own declaration in preference to the `open`ed `FormalSystem.Syntax.iterF`.

## Artifacts & Outputs

- `specs/520_bundle_retirement_and_cycle_breaking/plans/01_bundle-retirement-cycle-breaking.md` (this file)
- `specs/520_bundle_retirement_and_cycle_breaking/summaries/00_baseline.md` (Phase 1)
- `specs/520_bundle_retirement_and_cycle_breaking/summaries/01_bundle-retirement-cycle-breaking-summary.md` (final)
- `FormalSystem/Syntax/SubformulaClosure/IteratedTemporal.lean` (new, 29 declarations)
- `FormalSystem/Theorems/ModalDerived.lean` (new, 8 declarations)
- `FormalSystem/Boneyard/BundleDeadHalf/` (new, 6 relocated modules + README.md)
- `scripts/check-metalogic-cycles.sh` (new)

## Rollback/Contingency

Each phase is a separate commit (Phases 3 and 4 as single atomic-batch commits), so
`git revert <sha>` unwinds any one phase without disturbing the others. Phase ordering makes
partial rollback safe in the reverse direction: reverting Phase 5 leaves the tree building with
stale docs; reverting Phase 4 restores the 6 modules and their imports but requires re-adding the
Phase 2 and 3 temporary manifest entries; reverting Phases 2 or 3 restores the pre-edit import
graph wholesale.

If a phase reddens the build mid-way, **fix forward** -- correct the source. Never discard
uncommitted changes to reach a passing build. If forward progress stalls, run
`bash .claude/scripts/git-snapshot.sh 520` before any rollback.

The one irreversible-feeling step is the `git mv` in Phase 4; it is a rename, fully recorded in
history, and `git mv` back restores the prior paths exactly.
