# Implementation Summary: Task #867

- **Task**: 867 - Formalize Gabbay separation over discrete time for PlusFormula
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-06T18:05:00Z
- **Completed**: 2026-11-06T18:45:00Z
- **Effort**: ~40 minutes
- **Dependencies**: Phase 20 (landed in dispatch 14)
- **Artifacts**: plans/01_gabbay-separation-ztime-plusformula.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 21 of 28. Removed the single source of `untl`-type contamination in the landed
`snce`-side elimination layer, so that every separated right-hand side the layer produces
mentions `untl` only as `untl B A`. This reinstates the half of GHR Lemma 10.2.4's conclusion
that Phase 20's `#### Reasoned Exclusions` record excluded — now as the proved witness
`isUTyped_sepSnce`, not a prose claim — and makes `uTypeCount` well-posed over the layer
Phase 22 has to measure. Decision D-g (route 1: a second, additive Case 2 lemma at GHR's printed
right-hand side) was the governing ruling and was followed without modification. Phases 22-28
remain `[NOT STARTED]`; Phase 22 was sized but deliberately not opened, for the reason recorded
under Follow-ups.

## What Changed

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Eliminations.lean` — added
  `case2RhsPrinted` (GHR's printed three-disjunct Case 2, quoted and corpus-cited in its
  docstring), `case3RhsPrinted`, the two equivalences `usTruth_case2_printed` and
  `usTruth_case3_printed`, and the two `IsSeparated` witnesses
  `isSeparated_case2RhsPrinted` / `isSeparated_case3RhsPrinted`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/ElimHard.lean` — added `case8RhsPrinted`,
  `case7RhsPrinted` and `case6RhsPrinted`, each identical to its landed sibling except in the
  one slot reaching Case 2 or Case 3, with `usTruth_case8_printed`, `usTruth_case7_printed`,
  `usTruth_case6_printed` and their three `isSeparated_*Printed` witnesses.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean` — added nine
  right-hand-side typedness witnesses (`isUTyped_case1Rhs`, `isUTyped_case2RhsPrinted`,
  `isUTyped_case3RhsPrinted`, `isUTyped_case4Rhs`, `isUTyped_case5W`, `isUTyped_case5Rhs`,
  `isUTyped_case6RhsPrinted`, `isUTyped_case7RhsPrinted`, `isUTyped_case8RhsPrinted`) and
  `isUTyped_sepSnce`; rebuilt `sepSnce`'s body over `case7RhsPrinted` / `case5Rhs` /
  `case8RhsPrinted` / `case6RhsPrinted` at the four unchanged `substU` parameter pairs; amended
  the module docstring.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` — module rows, Key Results, and
  the "Not landed" section brought into line with the two proved conclusion halves.
- `README.md`, `FormalSystem/Metalogic/README.md`, `typst/generated/status.typ` — regenerated
  count blocks.

## Decisions

- `usTruth_case2_printed` goes through the landed `usTruth_case2` plus `usTruth_neg_untl`
  (GHR 10.2.2) in the `←` direction — GHR's own omitted third step, "using lemma 10.2.2 again
  (in reverse)". The residue is Boolean: one `simp only` over three prepared congruence `Iff`s
  (`q ∧ ¬A` against `¬A ∧ q` as an `snce` guard, one event re-association, and the fold) then
  `tauto`. No trichotomy on a witness occurs anywhere in it, which is the plan's own stated test
  that the fold was *used* rather than reconstructed.
- `usTruth_case6_printed`'s Case 3 congruence is stated universally in the substituted parameter
  (`∀ c : USForm, …`) rather than at the literal term, to stay inside the 100-column lint. A
  `set`-based alternative was rejected: it does not fold the post-`rw` goal, so the congruence
  would not match.
- The `IsUTyped` witnesses take the four `IsSOnly` hypotheses only. The two `IsUOnly` halves of
  GHR's standing hypothesis on `A` and `B` are needed for separatedness, never for typedness;
  asking for them here would have been a gratuitous strengthening, and D-f forbids
  `IsSeparated` at an input position where the weaker predicate suffices.

## Plan Deviations

- **Phase 21, final task item** altered: the plan named only `typst/generated/status.typ` as a
  generated artifact to refresh, but the phase's own GATES require `check-module-invariants.sh`
  green, and that check's INV group went red on the generated inventory blocks in `README.md`
  and `FormalSystem/Metalogic/README.md`. Both were regenerated through the sanctioned
  `check-module-invariants.sh --emit-inventory` entry point. `SeparationZ/README.md` was also
  amended by hand, because its "Not landed" section asserted that the typedness half of GHR
  10.2.4's conclusion is unproved — a claim this phase falsifies. Annotated inline on the
  checklist item. No `.lean` plan step was skipped, altered or deferred.

## Verification

- Build: Success. Guarded full unscoped `lake build` — guard exit 0, zero `error:` across both
  captured streams, "Build completed successfully (2960 jobs)", and `.olean` newer than source
  for all three touched modules. Guarded scoped builds of `Eliminations`, `ElimHard` and
  `NormalForm` were green at each phase sub-step first.
- Sorry count: 0 (`lean-sorry-census.sh` over all resolved source roots: `sorry_count: 0`;
  zero `sorry` occurrences in all seven `SeparationZ/` modules).
- Vacuous count: 0 introduced. The single repo-wide grep hit is pre-existing, in
  `FormalSystem/Examples/TemporalStructures.lean` (a `trivial` whose goal genuinely is
  `True`-shaped), in a file this phase does not touch.
- Axiom count: unchanged. 14 `axiom ` declarations repo-wide, all pre-existing and none in a
  touched file. Measured profiles (`#print axioms` under `lake env lean`, never hand-typed): the
  five `usTruth_*_printed` equivalences and `usTruth_sepSnce` carry
  `[propext, Classical.choice, Quot.sound]`; `isSeparated_sepSnce` and `isUTyped_sepSnce` carry
  `[propext]`; all nine `isUTyped_*` right-hand-side witnesses and all five
  `isSeparated_*Printed` witnesses depend on no axioms at all.
- Gates: `check-module-invariants.sh` ALL CHECKS PASSED (exit 0, including C14's pinned axiom
  baselines and C33's generated root); `check-metalogic-cycles.sh` exit 0 with the one recorded
  directory cycle and the recorded 10-line upward import set both unchanged;
  `typst-sync-check.sh --fix` PASS.
- Blocking check — nothing landed is weakened: `git diff` carries no deleted or re-signed
  declaration. `case2Rhs`, `usTruth_case2`, `isSeparated_case2Rhs`, `case3Rhs`, `case6Rhs`,
  `case7Rhs` and `case8Rhs` are byte-identical. `sepSnce` keeps its name and signature, and
  `usTruth_sepSnce` and `isSeparated_sepSnce` keep their exact statements with only their proof
  bodies swapped to the `_printed` siblings — the one landed body this phase is authorized to
  edit.
- Blocking check — no `IsSeparated` at an input position: confirmed mechanically; every
  `isUTyped_*` witness takes `IsSOnly` hypotheses only, and no declaration added here takes
  `IsSeparated` as a hypothesis.
- Scope Hypothesis confirmed by keyword count: 5 new `def`s and 20 new `theorem`s (5
  equivalences, 5 `IsSeparated` witnesses, 10 `IsUTyped` witnesses), one edited definition body,
  zero new modules — exactly the plan's figure, so no re-derivation was attempted where a
  congruence substitution was specified.
- Tests: N/A (no test library module touched).
- Files verified: Yes.

## Impacts

- GHR Lemma 10.2.4 now carries both halves of its conclusion as proved witnesses, so the
  deliverable Phase 20 excluded is reinstated and the second `#### Reasoned Exclusions` row of
  Phase 20 is discharged.
- Phase 22's recorded blocker is resolved rather than worked around: `uTypeCount` is well-posed
  over the `snce`-side layer because `isUTyped_sepSnce` supplies part 2 of the shared
  measure-decrease decomposition ("separation does not raise the count") directly, so Phase 22
  cites it instead of re-establishing type-cleanliness.
- `SeparationOver TaskFrame.IsZTime` is still NOT discharged, and no `tr` row of
  `OpenFutureElimination.lean` changes. Nothing in `FormalSystem/Metalogic/Independence/` was
  touched and the metalogic-cycles allowlist was not altered.

## Follow-ups

- Phase 22 (GHR Lemmas 10.2.5 and 10.2.6) was sized, as the plan's shared measure-decrease
  section instructs, and deliberately not opened. Two prerequisites its task list does not
  decompose dominate its cost. First, GHR 10.2.5's precondition has no landed predicate:
  `IsUTyped A B` is strictly too strong, since its `snce` constructor demands `IsSOnly`
  arguments — no `untl` under any `snce` — which is exactly the restriction 10.2.5 relaxes, so a
  third predicate (every `untl` occurrence is `untl B A`, nesting unconstrained) plus its Boolean
  closure lemmas is forced. Second, inducting on `snceDepthAbove` needs a `hasUntl` decision and
  a one-level rewriting operator applying 10.2.4 at exactly the deepest
  `snce`-containing-an-`untl`, with four lemmas about it (truth preservation, precondition
  preservation, the `snceDepthAbove` bound, and `sepSnce`-has-depth-0). Both are prior to the
  three-part obligation the plan does decompose, which attaches to 10.2.6, 10.2.7 and 10.2.8
  and not to 10.2.5.
- A route question for the next planning cycle, not for an implementation dispatch to settle:
  there is a structural-recursion route to 10.2.5 that needs no measure at all, because
  `usTruth_sepSnce` and the now-landed `isUTyped_sepSnce` compose directly at every `snce` node
  (a bottom-up pass `.snce ψ φ ↦ sepSnce A B (f φ) (f ψ)` carries the new predicate to
  `IsUTyped A B` in one structural induction). It is strictly cheaper than the measure route
  Phase 22 specifies. `plan-compliance.md` forbids an implementation dispatch substituting it
  silently, so it is recorded here rather than taken.
- `ElimHard.lean`'s docstring still cites "Claim C of the Phase 16 gate record", an ephemeral
  task-management anchor in a deliverable. Pre-existing and out of this phase's scope.

## References

- `specs/867_formalize_gabbay_separation_ztime/plans/01_gabbay-separation-ztime-plusformula.md`
  — Phase 21, and the dispatch-15 anchor-verification table it cites
- `specs/867_formalize_gabbay_separation_ztime/handoffs/phase-21-handoff-20261106T183827Z.md`
- `specs/867_formalize_gabbay_separation_ztime/.decisions.json` — decision D-g (route 1)
- `~/Projects/Literature/sources/gabbay_1994/ch1001_chapter-10-expressive-completeness-of-si.md`
  — GHR vol. 1, Lemma 10.2.3 Case 2 and Lemma 10.2.4
