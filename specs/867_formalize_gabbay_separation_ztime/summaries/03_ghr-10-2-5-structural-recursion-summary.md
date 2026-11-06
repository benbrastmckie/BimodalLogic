# Implementation Summary: Task #867

- **Task**: 867 - Formalize Gabbay separation over discrete time for PlusFormula
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-06T19:24:05Z
- **Completed**: 2026-11-06T20:30:31Z
- **Effort**: ~1.5 hours across dispatch 17 and its stall re-prompt
- **Dependencies**: Phases 1-21 and 22.1 (landed in earlier dispatches)
- **Artifacts**: plans/03_structural-route-measure-split.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Dispatch 17 closed Phases 22.1 and 22.2 of plan 03, landing GHR Lemma 10.2.5 in full over
`USForm` at `ℤ`: first its actual input hypothesis `IsUSingleType` — which the landed `IsUTyped`
is strictly too strong to serve as — and then the lemma itself as the structural recursion
`sepU` with all three of its conclusions. Decision D-h's route ruling held: the source's own
induction on the maximum nested-`S` depth above a `U(A,B)` is not formalized and needs no
measure, because the two landed halves of Lemma 10.2.4 chain at every `snce` node. The task is
not complete — Phases 22.3 through 28 remain, carrying Lemmas 10.2.6 to 10.2.8, Theorem 10.2.9,
the `SeparationOver TaskFrame.IsZTime` discharge and the computable translation `trZ`.

## What Changed

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Hierarchy.lean` — created at Phase 22.1 with
  `IsUSingleType` (whose `snce` constructor recurses where `IsUTyped`'s demands `IsSOnly` of both
  arguments), its four Boolean closure lemmas `IsUSingleType.ofIsSOnly`/`.neg`/`.and`/`.or`, the
  one-way implication `isUSingleType_of_isUTyped`, and the two witnesses
  `not_isUTyped_snce_untl`/`isUSingleType_snce_untl` that prove the strictness at `S(⊥, U(A,B))`
  rather than asserting it. Extended at Phase 22.2 to 268 lines with GHR Lemma 10.2.5 itself:
  `sepU` (a plain `def` by structural recursion over `USForm`), `isUTyped_sepU` (the conclusion's
  "`U` only appears as the formula `U(A,B)`" clause), `usTruth_sepU` (the equivalence) and
  `isSeparated_sepU` (the separatedness).
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean` — one docstring addition at
  `IsUTyped` naming the weaker sibling and which lemma consumes which. No declaration changed.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` — module row, one Key Results
  bullet, and the `## Not landed` section, which now opens at Lemma 10.2.6 rather than 10.2.5.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` — regenerated
  inventory blocks (the new module and its growth move the per-directory counts those blocks pin).
- `typst/generated/status.typ` — regenerated declaration counts.

## Decisions

- **Decision D-h taken as ruled, not re-litigated.** `sepU` is a plain structural recursion with
  no depth measure, no `hasUntl` decision procedure and no one-level rewriting operator. The
  observable consequence the Scope Hypothesis asks for holds:
  `grep -rn 'snceDepthAbove\|hasUntl'` over `FormalSystem/Metalogic/Expressiveness/SeparationZ/`
  returns nothing, so the measure route's machinery is absent from the tree rather than merely
  unused.
- **`isUTyped_sepU` is proved before the equivalence**, because it supplies the hypotheses
  `usTruth_sepSnce` demands at every `snce` node. The plan's warning that attempting the
  equivalence first makes the phase look harder than it is proved accurate.
- **The `snce` arm crosses its arguments**: `snce ψ φ ↦ sepSnce A B (sepU A B φ) (sepU A B ψ)`,
  because `USForm.snce` takes guard first and event second while `sepSnce A B C F` takes event
  `C` first and guard `F` second. An uncrossed transcription typechecks and is wrong;
  `usTruth_sepSnce`'s own statement is the authority and is cited in the docstring.
- **The `untl` arm is the identity.** Under `IsUSingleType` the only `untl` node is `untl B A`, so
  no decidable-equality test and no `sepU A B A = A` lemma is needed. A test here would
  reconstruct a case analysis the precondition already supplies.
- **`IsUTyped` is untouched as a declaration.** The ruling that an input position asking for a
  stronger predicate than the step needs is a defect was applied one predicate further out, not
  by weakening anything landed. No landed signature changed anywhere.
- **No `isSeparated_of_isUSingleType` exists and the module docstring records that none can**: a
  `snce` carrying an `untl` argument is not syntactically separated, which is the exact content of
  "strictly weaker". Producing the separated form is what `sepU` is for.

## Plan Deviations

- **Phase 22.1** altered: three generated inventory blocks required regeneration beyond the
  phase's named file list, because the new module changes the per-directory counts those blocks
  pin and the phase's gates require `check-module-invariants.sh` green.
- **Phase 22.1** altered: three `Paper: —` docstrings were reflowed so no continuation line
  begins with the token `theorem`, which was producing three false hits in the declaration-counting
  grep the Scope Hypothesis asks for.
- **Phase 22.2** altered: two generated inventory blocks (`README.md`,
  `FormalSystem/Metalogic/README.md`) required the same regeneration, for the same reason. All
  three repairs went through the sanctioned `--emit-inventory` entry point. This collision has now
  recurred at Phases 21, 22.1 and 22.2 and is a standing cost of this task rather than a one-off.

## Verification

- Build: Success. Full unscoped guarded `lake build` — guard exit 0, zero `error:` across both
  captured streams, 2961 jobs, and `.olean` newer than source for the touched module. The scoped
  guarded build of `...SeparationZ.Hierarchy` was green first (exit 0, zero `error:`, 1492 jobs).
- Sorry count: 0 (`lean-sorry-census.sh` across all eight resolved source roots).
- Vacuous count: 0 introduced. The single grep hit is pre-existing at
  `FormalSystem/Examples/TemporalStructures.lean:495` — a `trivial` whose goal genuinely is
  `True`-shaped — in a file neither phase touches.
- Axiom count: 14 `axiom ` declarations, unchanged from the pre-task baseline, none in a touched
  file. Axiom profiles measured by `#print axioms` under `lake env lean`, never hand-typed: all
  eight Phase 22.1 declarations depend on no axioms at all; `sepU` likewise depends on no axioms;
  `isUTyped_sepU` and `isSeparated_sepU` depend on `propext`; `usTruth_sepU` on
  `propext, Classical.choice, Quot.sound`. All within the three standard axioms the landed
  eliminations already carry — nothing new.
- Blocking check — `sepU` compiles without `noncomputable`: passed. The only occurrence of the
  token in the module is inside `sepU`'s own docstring explaining its absence. The Phase 26
  executability deliverable is not compromised through this layer.
- `check-module-invariants.sh`: ALL CHECKS PASSED (exit 0), after the inventory regeneration.
- `check-metalogic-cycles.sh`: exit 0, recorded cycle and upward import set unchanged. The
  allowlist was not altered.
- `typst-sync-check.sh --fix`: PASS (status.typ regenerated; automation module map and machine
  appendix already in sync, `MA_COUNT_MISMATCHES=0`).
- Files verified: Yes.

### Plan compliance verdict, stated plainly

`lean-plan-compliance-check.sh` reports `COMPLIANCE_CHECK: failed`. This is a measurement
artifact of running an end-state check mid-task, not a divergence from the plan. Its entire
MISSING list is the task's end-state deliverables — `sepZ`, `sepZ_sepClauses`,
`separationOver_ztime`, `trZ`, `openTruthAt_iff_trZ`, `openValidIn_ztime_iff_trZ`,
`plusTruthAt_sepZ_iff` — produced by Phases 25 and 26 and reachable by no earlier phase; `tr`,
the one name that exists today, is reported `[OK]`. The verdict is identical against plan 01 and
plan 03, so it is attributable to neither this dispatch nor the plan revision, and it will
recur on every remaining dispatch of this task until Phase 26 lands. `verification_passed` is
therefore reported true on the strength of the gates above, and no user review is requested,
because there is no user judgment the artifacts cannot supply. The verdict is recorded in
`metadata.compliance_check` and in `issues.jsonl` as a `tooling` issue rather than suppressed.

## Impacts

- GHR Lemma 10.2.5 is now available in full to the downstream layer, so Phase 22.3's part (b)
  obligation — "separation does not raise the `untl`-type count" — can cite `isUTyped_sepU`,
  which covers it at 10.2.5, rather than `isUTyped_sepSnce`, which covers it only at 10.2.4.
- `IsUSingleType` is available as the correct input hypothesis for every later step whose
  precondition relaxes the no-`untl`-under-`snce` restriction, and the one-way implication plus
  the refutation at `S(⊥, U(A,B))` pin exactly how it sits against `IsUTyped`.
- `sepU` carries no axioms and no `noncomputable`, so the executable-translation deliverable
  remains reachable through this layer.
- `FormalSystem/Metalogic/Independence/` was not touched and the metalogic-cycles allowlist was
  not altered, as the task's scope requires.

## Follow-ups

- Phases 22.3 through 28 remain: `uTypeCount` and Lemma 10.2.6, Lemma 10.2.7, junction depth with
  Lemma 10.2.8 and Theorem 10.2.9, the CNF packaging and the `SeparationOver TaskFrame.IsZTime`
  discharge, the computable `trZ`, the theorem-index restatement with re-measured axiom baselines,
  and the full gate sweep. The plan's own primary stall candidate — Phase 24's junction-depth
  strict decrease, asserted without proof in the source — has not yet been reached.
- The generated-inventory collision will recur on every phase that changes a module's line count.
  It is cheap to repair but is not currently part of any phase's named file list.
- Dispatch 17 stalled once before this re-prompt: the harness forcibly backgrounds any foreground
  Bash call exceeding 180 seconds regardless of the call's own timeout, so the mandated
  single-call bounded-waiter idiom cannot complete in one call for a full `lake build`. The
  workaround used here — detach with a sentinel file, then poll in repeated sub-180s foreground
  calls — is recorded in `issues.jsonl` and is worth promoting into the wait-discipline guidance.

## References

- `specs/867_formalize_gabbay_separation_ztime/plans/03_structural-route-measure-split.md`
- `specs/867_formalize_gabbay_separation_ztime/handoffs/phase-22.1-handoff-20261106T193746Z.md`
- `specs/867_formalize_gabbay_separation_ztime/handoffs/phase-22.2-handoff-20261106T202829Z.md`
- `specs/867_formalize_gabbay_separation_ztime/summaries/02_type-clean-case2-printed-rederivations-summary.md`
- `specs/867_formalize_gabbay_separation_ztime/issues.jsonl`
