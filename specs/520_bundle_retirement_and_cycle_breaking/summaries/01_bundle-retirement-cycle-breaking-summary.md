# Implementation Summary: Bundle Retirement and Cycle Breaking

- **Task**: 520
- **Plan**: `specs/520_bundle_retirement_and_cycle_breaking/plans/01_bundle-retirement-cycle-breaking.md`
- **Baseline**: `specs/520_bundle_retirement_and_cycle_breaking/summaries/00_baseline.md`
- **Phases**: 5 of 5 completed
- **Type**: lean4

## What was done

The `Core -> Bundle` directory import cycle in `FormalSystem/Metalogic/` is gone, and the half of
`Bundle/` it was keeping alive is archived.

**Phase 1** recorded the pre-edit gate (ALL CHECKS PASSED at `2bd4dfba2`) and re-measured every
count the plan asserts. Three came back different; see "Divergences" below.

**Phase 2** relocated 29 pure-syntax declarations -- `iterF`/`iterP` and their complexity,
injectivity, nesting-depth and closure-escape lemmas -- verbatim from
`Metalogic/Bundle/CanonicalTaskRelation.lean` to a new
`Syntax/SubformulaClosure/IteratedTemporal.lean` whose sole import is `NestingDepth`.
`Core/RestrictedMCS/Basic.lean` now imports that module instead of `Bundle/`, and its
`open FormalSystem.Metalogic.Bundle` (which existed only for those names) is deleted. That was the
sole `Core -> Bundle` edge; `grep -rn "Metalogic.Bundle" FormalSystem/Metalogic/Core/` now returns
nothing.

**Phase 3** moved the seven live helpers out of `Bundle/ModalSaturation.lean`. Five
derivation-tree theorems (`dneTheorem`, `boxDneTheorem`, `modal5CollapseTheorem`,
`axiom5NegativeIntrospection`, `negBoxToBoxNegBox`) went to a new `Theorems/ModalDerived.lean`,
joined as consolidation by `gDneTheorem`/`hDneTheorem` from `Bundle/TemporalCoherence.lean` and
`pastTempA` from `Bundle/WitnessSeed.lean` -- eight declarations, no `Metalogic` import, so the
pre-existing `Theorems <-> Metalogic` edge is not widened. The two `SetMaximalConsistent` lemmas
(`contrapositive`, `neg_box_implies_box_neg_box`) went to `Core/MCSProperties.lean` rather than
`Theorems/`, for the same reason. All nine consumer modules were re-pointed and all ten
hand-written fully-qualified `FormalSystem.Metalogic.Bundle.<name>` references rewritten.

**Phase 4** `git mv`-ed the six dead modules to `Boneyard/BundleDeadHalf/` with a README, deleted
the live imports that named them, re-pointed all 28 archived import lines, removed all three
manifest entries, and regenerated `Bundle/README.md` in the same commit as the move.

**Phase 5** brought `Metalogic/README.md` and `Boneyard/README.md` back into agreement with the
tree, removed a false "contains sorries" claim from `Algebraic/UltrafilterMCS.lean`, and added
`scripts/check-metalogic-cycles.sh` so the cycle count is checked rather than argued.

## Acceptance criteria

| Criterion | Result |
|---|---|
| Directory-level import cycles in `Metalogic/` = 1 | **Met.** `bash scripts/check-metalogic-cycles.sh` reports exactly 1, and it is the `BXCanonical <-> WeakCanonical` pair (9 forward / 5 backward import lines, each enumerated). |
| `Bundle/` has zero modules with no live consumer | **Met.** All 9 survivors have a live importer outside the `Bundle.lean` aggregator; the table is in the baseline file, and C6 would fail on any unmanifested unreachable module. |
| `lake build` green | **Met**, guarded and detached, at every phase boundary. |
| `check-module-invariants.sh` ALL PASS | **Met at every phase boundary**, C5 included, with no carve-out. |
| C2 flagship axiom baseline unchanged | **Met.** Byte-identical at every phase: all four theorems `[propext, Classical.choice, Quot.sound]`. |

## Measured before/after

| Quantity | Before | After |
|---|---:|---:|
| Live `.lean` under `Metalogic/` (C7) | 321 | 315 |
| Modules in `Metalogic/Bundle/` | 15 | 9 |
| Lines in `Metalogic/Bundle/` | 6,073 | 3,299 |
| `Bundle -> Core` import lines / files | 18 / 10 | 9 / 5 |
| `Core -> Bundle` import lines | 1 | 0 |
| Directory-level cycles in `Metalogic/` | 2 | 1 |
| Archived `.lean` files (C11) | 156 | 162 |
| Archived import lines (C11) | 497 | 527 |
| Archived lines | 88,275 | 90,535 |
| Unreachable live modules (C6) | 17 | 16 |
| Live import lines (C4) | 1,499 | 1,479 |

## Divergences from the plan

Each was measured, not assumed, and each is annotated inline on the plan's checklist.

1. **The fully-qualified reference count is 10, across 6 modules** -- neither the report's prose
   figure (7) nor its matrix figure (9). The plan deliberately declined to assert this and made
   Phase 1's enumeration authoritative; that enumeration is section 4 of the baseline file. All 10
   were rewritten by hand.
2. **The two unqualified `SetMaximalConsistent.contrapositive` sites needed no added `open`.**
   `CanonicalModel.lean:33` and `CompletenessDedekind.lean:58` already carry
   `open FormalSystem.Metalogic.Core`, so the references resolve at the new home unchanged.
   `Chronicle/MCSMixedCase.lean:58` is the same case and needed no edit at all, which is why that
   file is absent from the diff.
3. **`WitnessSeed.lean` has four `temp_a` mentions, not three** (`:561`, `:565`, `:566`, `:572`).
   `:565-566` is `pastTempA`'s own docstring and travelled with the declaration; the other two were
   corrected in place to name `Axiom.connect_future` / `Axiom.connect_past`, which are the real
   constructors.
4. **The 23 external archived import lines sit in 18 files, not 14.** The plan's own enumeration
   lists 23 entries over 18 distinct paths; four files appear more than once, which is where the 14
   came from.
5. **C11's archived import-line total is not unchanged, and the plan's reasoning there was wrong.**
   It went 497 -> 527 because the six moved files bring their own 30 import lines into the archived
   population -- something "lines are re-pointed, not added or removed" overlooked. All 527 resolve;
   the waived count is unchanged at 7.
6. **`Metalogic/README.md`'s Cycle 2 section and three `docs/architecture/BFMCS_ARCHITECTURE.md`
   slash paths had to be fixed in Phase 4, not Phase 5.** `Metalogic/README.md:98` named
   `FormalSystem.Metalogic.Bundle.CanonicalTaskRelation`, a module-shaped path C5 resolves, and
   `BFMCS_ARCHITECTURE.md:165,168,297` named three retired modules in the slash shape C12 resolves.
   Deferring either would have left the Phase 4 boundary red, which the plan forbids. The remaining
   `Metalogic/README.md` work stayed in Phase 5.
7. **The `untl`/`snce` figure needed a unit correction, not a value correction.** The plan's
   per-file numbers are lines; `SuccRelation.lean` has 12 occurrences on 10 lines.
   `CanonicalTaskRelation.lean`'s 2 sit inside the relocated block and moved to the live
   `IteratedTemporal.lean` in Phase 2, so they never reach the archive. What travels is
   **14 occurrences across 12 lines in 2 files**, so the plan's total of 14 stands.
8. **`Metalogic/README.md` carried three further stale rows unrelated to this task**
   (`Independence/` 3 -> 6 files, `SoundnessLemmas/` 5 -> 3, and a top-line 314 that C7 reported as
   321). Phase 5's instruction to reconcile every count in the touched READMEs against the gate
   output covers them, so they were corrected rather than left half-right.

## Reasoned exclusion

**The new script is not catalogued in `.claude/docs/reference/utility-scripts-inventory.md`.**
That path is gitignored in this repository (`.gitignore:85`), and its source store
(`agent-system/extensions/**`) is not present here, so a hand-authored entry would be discarded by
the next deploy and never reach version control. It is catalogued instead in
`docs/development/MODULE_INVARIANTS.md`, which is tracked, sits beside the harness it is a sibling
to, and is cited from `FormalSystem/Metalogic/README.md`.

## Discharged by removal rather than by edit

Two WORK items name defects in files that left the live tree in this task. Both are recorded in
`FormalSystem/Boneyard/BundleDeadHalf/README.md` rather than patched in an archived file:

- The `SuccRelation.lean` proof diary. Its true range is `:434-541` (108 lines), not the
  `:432-543`/85 the task description gives -- `:432-433` are real step-6 code and `:542-543` resume
  real code. Why `h_p_step` is a hypothesis is stated in the archive README: `Succ` yields
  `GContent u ⊆ v` and `FContent u ⊆ v ∪ FContent v` and has no P-dual, so callers that construct
  predecessors discharge it.
- The F-21 docstring error at `SuccRelation.lean:135-148`, which asserts
  `F(phi) = neg(G(neg(phi)))` as definitional. It is false and backwards:
  `someFuture φ = untl top φ` is primitive (`Syntax/Formula.lean:147`) and `allFuture` is derived
  from it (`:167`). The correct statement survives in the live tree at `Bundle/WitnessSeed.lean:53`.

## Plan Deviations

See "Divergences from the plan" above -- items 1 through 8, each annotated inline on the
corresponding plan checklist item.

## Artifacts

- `FormalSystem/Syntax/SubformulaClosure/IteratedTemporal.lean` (new, 29 declarations)
- `FormalSystem/Theorems/ModalDerived.lean` (new, 8 declarations)
- `FormalSystem/Boneyard/BundleDeadHalf/` (new: 6 relocated modules + README.md)
- `scripts/check-metalogic-cycles.sh` (new)
- `specs/520_bundle_retirement_and_cycle_breaking/summaries/00_baseline.md`
- `specs/520_bundle_retirement_and_cycle_breaking/summaries/01_bundle-retirement-cycle-breaking-summary.md` (this file)
