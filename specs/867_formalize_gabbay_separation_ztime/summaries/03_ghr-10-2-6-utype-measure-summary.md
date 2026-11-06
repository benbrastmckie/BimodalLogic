# Implementation Summary: Task #867

- **Task**: 867 - Formalize Gabbay separation over discrete time for `PlusFormula`
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-06T23:10:27Z
- **Completed**: 2026-11-06T23:25:00Z
- **Effort**: ~15 min wall clock, one phase (22.3)
- **Dependencies**: Phases 1-22.2 (all landed)
- **Artifacts**: plans/03_structural-route-measure-split.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 22.3 of plan 03 landed the `U`-type measure and GHR Lemma 10.2.6 in full — the equivalence,
the separatedness and the type-preservation clause — over `PlusFormula`'s auxiliary until/since
syntax `USForm`, together with the abstraction-and-reindexing device the lemma's induction needs
and which the plan had wrongly recorded as already present. Six phases remain (23-28); the
`SeparationOver TaskFrame.IsZTime` discharge is still ahead at Phase 25.

## What Changed

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Hierarchy.lean` (268 -> 1000 lines, all
  additive) — 48 new declarations in five groups:
  - **The measure**: `uTypes` (maximal `untl` subformulas, deduplicated), `uTypeCount`, their
    equation and membership lemmas, `uTypes_nodup`, and the measure's API
    (`uTypes_eq_singleton_of_mem`, `maxLeaf_le_of_mem_uTypes`, `uTypes_eq_nil_of_isSOnly`,
    `isSOnly_of_uTypes_empty`, `isSOnly_of_uTypeCount_le_zero`, and the two bridges
    `uTypes_of_isUTyped` and `isUSingleType_of_uTypes`).
  - **GHR 10.2.6's precondition**: `IsPureType`, `HasPureUTypes`, with
    `uTypes_eq_self_of_isPureType` and `isSeparated_of_isPureType`. No new inductive predicate:
    the hypothesis is a condition on the measured list, which is what GHR's own statement says.
  - **The abstraction and reindexing device**: `mapU`, `mapS`, `substLeaf`, `usTruth_substLeaf`,
    `substLeaf_eq_self_of_lt`, `abstrFn`, `unabstrFn`, `unabstrFn_of_lt`,
    `unabstrFn_abstrFn_of_mem`, `unabstrFn_cases`, `mem_uTypes_unabstrFn`, `mapS_unabstrFn`,
    `isSeparated_unabstrFn`, `mem_uTypes_mapU`, `substLeaf_mapU_abstr`.
  - **The three strict-decrease obligations, separately named and none standing in for another**:
    `uTypes_mapU_abstr` with its instance `uTypes_mapU_abstr_eq_head` (part a, abstraction drops
    the abstracted types); `uTypes_sepU` (part b, a one-line citation of Phase 22.2's
    `isUTyped_sepU`, never of `isUTyped_sepSnce`); `uTypeCount_snce_substLeaf_le` with
    `mem_uTypes_substLeaf_of_isSOnly` and `hasPureUTypes_snce_substLeaf` (part c, the bound that
    licenses the recursive call).
  - **GHR Lemma 10.2.6**: `mapS_substLeaf_spec` (the reindex-and-recurse pass), `sepBody`,
    `sepBody_nil`, `sepBody_cons`, `sepFuel`, `sepMulti`, `sepFuel_spec`, and the three
    conclusions `isSeparated_sepMulti`, `usTruth_sepMulti`, `uTypes_sepMulti`, plus
    `hasPureUTypes_sepMulti` (10.2.6's conclusion re-establishes its own hypothesis).
  - Plus two new imports (`Mathlib.Data.List.Dedup`, `Mathlib.Data.List.Perm.Subperm`) and a
    rewritten module docstring recording the two formalization choices below.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` — module row, three Key Results
  bullets, and the `## Not landed` section, which now opens at Lemma 10.2.7 rather than 10.2.6.
- `typst/generated/status.typ`, `README.md`, `FormalSystem/Metalogic/README.md` — regenerated
  counts.
- `specs/867_formalize_gabbay_separation_ztime/plans/03_structural-route-measure-split.md` —
  Phase 22.3 marked `[COMPLETED]`, checklist items checked, two deviations annotated inline, and
  a confirmed-false Scope Hypothesis record added.

## Decisions

- **The measure is read off the formula, not threaded through as GHR's parameter list.** This is
  the plan's own instruction, kept; `HasPureUTypes` then states GHR's hypothesis verbatim ("the
  only appearances of U in D are in the form U(Aᵢ,Bᵢ)", each `Aᵢ`/`Bᵢ` built without S or U).
- **The induction carries the count as an explicit budget (`sepFuel`), not as Lean well-founded
  recursion on `uTypeCount`.** This is forced, not preferred: the recursive call is fired by
  `mapS` at the separated form's `snce` constituents, which are neither syntactic subterms of the
  definition's argument nor in scope when the definition is elaborated, so no `decreasing_by`
  goal can be stated for it at all. `sepMulti` instantiates the budget at the measure, so the
  budget never reaches the statement of the lemma. Recorded at `sepFuel` and in the module
  docstring.
- **`usTruth_congr_of_update` is unused, and was the wrong tool.** `usTruth_substLeaf` moves the
  substitution onto the leaf valuation and is strictly stronger, so 10.2.6's equivalence half is
  a five-line `calc` with no freshness side-condition on the valuation anywhere. `freshLeaf` is
  still load-bearing, but only so that `substLeaf` inverts `mapU` *syntactically*
  (`substLeaf_mapU_abstr`).
- **No input position asks for more than the step needs** (decision D-f): 10.2.5's hypothesis is
  discharged as `IsUSingleType`, 10.2.4's as `IsUTyped`, and `IsSeparated` appears at no input
  position.
- `List.dedup` was chosen over `List.union` for the measure: it needs only the already-derived
  `DecidableEq USForm`, and `List.mem_dedup` / `List.nodup_dedup` are the only two library lemmas
  the measure's API rests on.

## Plan Deviations

- **Phase 22.3, "prove it by strong recursion on `uTypeCount`"** altered: the route, the measure
  and every step are exactly as specified, but two sub-claims of the bullet did not hold — the
  budget-versus-well-founded-recursion point and the `usTruth_congr_of_update` point, both
  recorded under Decisions above and annotated inline on the checklist item.
- **Phase 22.3, the typst regeneration item** altered: two generated inventory blocks
  (`README.md`, `FormalSystem/Metalogic/README.md`) also required regeneration through
  `check-module-invariants.sh --emit-inventory`, because the module's line count moved. Fourth
  consecutive phase with this collision (21, 22.1, 22.2, 22.3).
- **Phase 22.3's Scope Hypothesis is CONFIRMED FALSE, and its own diagnosis of an overshoot is
  also false.** 48 new `def`/`theorem`/`inductive` declarations against a predicted five (the
  "zero new modules" half did hold). The hypothesis said an overshoot would mean part (b) had been
  re-proved where a citation was specified; part (b) is a one-line citation, so that cause is
  ruled out. The actual cause is the phase's own task text, which asserted that "Phase 1's
  `freshLeaf` and `usTruth_congr_of_update` are the whole device" — the tree carries no
  substitution operation on `USForm` in either direction, so the device had to be built from
  nothing here. Phases 23 and 24 are sized on the same assumption and should be re-sized before
  being started; the device is now landed and reusable, so the correction should be downward.

## Verification

- Build: Success. Full unscoped guarded `lake build`: exit 0, zero `error:`, 2961 jobs, `.olean`
  newer than source for the touched module. Scoped guarded build of
  `...SeparationZ.Hierarchy`: exit 0, zero `error:`, zero warnings, 1492 jobs.
- Sorry count: 0 (`lean-sorry-census.sh` across all eight resolved source roots).
- Vacuous count: 1 hit, pre-existing at `FormalSystem/Examples/TemporalStructures.lean:495` (a
  `trivial` whose goal genuinely is `True`-shaped), in a file this phase does not touch; 0 new.
- Axiom count: 14 `axiom ` declarations, unchanged from the Phase 22.2 baseline, none in a
  touched file. Axiom profiles measured by `#print axioms` under `lake env lean`: `uTypes` and
  `uTypeCount` depend on no axioms; `sepBody`, `sepFuel`, `sepMulti` on `propext`; every theorem
  of this phase on `propext, Classical.choice, Quot.sound`. All within the three standard axioms
  the landed eliminations already carry — nothing new.
- Blocking checks: the separating function compiles without `noncomputable` (`#eval sepMulti ...`
  returns a value, and the only occurrences of the token in the module are docstrings explaining
  its absence); `uTypeCount` is a total structural recursion with no `partial` and no
  well-founded `sorry`; the D-h ruling is not bypassed (`snceDepthAbove`/`hasUntl` absent from
  the `SeparationZ/` subtree).
- Gates: `check-module-invariants.sh` ALL CHECKS PASSED (exit 0) after inventory regeneration;
  `check-metalogic-cycles.sh` exit 0 with the recorded cycle and upward import set unchanged;
  `typst-sync-check.sh --fix` PASS.
- Tests: N/A (no test-suite change; the library build covers `Tests/BimodalTest`).
- Files verified: Yes.

## Impacts

- GHR Lemma 10.2.6 is available in full to Phase 23, with `hasPureUTypes_sepMulti` closing the
  loop so that a 10.2.7 step consuming a 10.2.6 output needs no fresh type-cleanliness argument.
- The abstraction and reindexing device (`mapU`, `mapS`, `substLeaf`, `abstrFn`, `unabstrFn` and
  their lemmas) is now landed and reusable by Phases 23 and 24, whose own abstract/reindex steps
  are structurally identical. This is the main reason the next phases should re-size downward.
- `usTruth_substLeaf` supersedes `usTruth_congr_of_update` for every abstract/reindex step in the
  subtree: it removes the freshness side-condition on the valuation entirely.
- `sepMulti` is computable, so the Phase 26 executability deliverable is not compromised through
  this layer.

## Follow-ups

- **Re-size Phases 23 and 24 before dispatching them.** Both rest on the same false premise about
  the device that Phase 22.3's Scope Hypothesis did. A plan revision is the clean route.
- Phase 23's part (b) has no landed counterpart by the plan's own admission — what must be shown
  is that `sepMulti`'s output has `untlDepth` no greater than its input's, which is a fresh
  obligation, not a transfer of `isUTyped_sepU`. It is the first place the development could
  genuinely stall, ahead of Phase 24's junction-depth decrease (the plan's named primary stall
  candidate).
- The `--emit-inventory` collision is now a standing per-phase cost rather than an incident; if
  it recurs at Phase 23 it is worth folding the regeneration into each phase's task list instead
  of annotating it as a deviation each time.

## References

- `specs/867_formalize_gabbay_separation_ztime/plans/03_structural-route-measure-split.md` —
  Phase 22.3's task list, Scope Hypothesis and the decisions D-f, D-g, D-h it cites
- `specs/867_formalize_gabbay_separation_ztime/handoffs/phase-22.3-handoff-20261106T232000Z.md` —
  this phase's own handoff, with the full measured-gate record
- `specs/867_formalize_gabbay_separation_ztime/handoffs/phase-22.2-handoff-20261106T202829Z.md` —
  the predecessor phase, which landed `sepU` and `isUTyped_sepU`
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` — the subtree's module map and
  `## Not landed` record
