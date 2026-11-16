# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-16T01:35:17Z
- **Completed**: 2026-11-16T02:05:00Z
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Artifacts**: plans/21_refutation-first-run-level-adequacy.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 11.29 — Round 1 of route (E-5), the attempt to REFUTE the filed
`cellAt_const_of_kappa_eq` — was executed and closed with **outcome (b): OPEN WITH A MEASURED
ACCOUNT**, with zero `sorry`. The predicted separating type was exhibited and both of its cell
memberships compile, but its instantiation at a `kappa`-collision is refuted: (K2)'s margin puts
`Tc` above `2 ^ card (closure φ)`, so every countdown the formula can record lies where `kappa`
is injective, and the agreement is PROVED at the separating family. The filed statement is
neither refuted nor proved.

## What Changed

- `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` — second section
  appended after the original `end Probe761C` (nothing above edited; +505 lines). Declarations:
  `nxtF`/`nxtN`/`sepC` (`X^(k+1) ¬p`) and `stabSepC` (`⊡ sepC`); `truth_nxtF`, `truth_nxtN`,
  `truth_sepC`; `sepC_mem_of_cnt_eq` (positive membership), `sepC_not_mem_of_lt_cnt` (negative
  membership), `sepC_cell_ne`; `sepC_closure_card`, `lt_Tc_of_closure_card`
  (`card (closure φ) < Tc` under `ParamsOk` at any `φ`), `sepC_no_collision`; `sepC_cell_eq`,
  `sepC_agreement_at_collision`; `exists_non_atom_preserving_count_move`; `stabSepC_cell_ne`,
  `stabSepC_no_collision`; `RefutationTargetC` (the undecided target, a `def … : Prop`),
  `refutationTargetC_margin`, `round_one_verdict`. Fourteen `#print axioms` lines, all
  `[propext, Quot.sound]` or `[propext, Classical.choice, Quot.sound]`.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — docstring-only section
  "The refutation attempt on the agreement over counter classes: the verdict". No declaration.
- `docs/theorem-index.md` — paragraph recording OPEN WITH A MEASURED ACCOUNT against the filed
  name.
- `scripts/check-evidence-probes.sh` — the probe's table row extended with the second section.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/README.md`,
  `README.md`, `typst/generated/status.typ` — regenerated (line counts and stamp only).
- `specs/761_ladder_realization_theorem/records/round-21-refutation-verdict.md` — the durable
  verdict record (created).
- `specs/761_ladder_realization_theorem/handoffs/phase-11.29-handoff-20261116T020024Z.md`.

## Decisions

- The failing step is carried as compiled NEGATIVES (`sepC_no_collision`,
  `sepC_agreement_at_collision`) rather than a `sorry`-bodied goal, because the goal is not
  unclosed — its negation compiles. The still-undecided general target is a `def` of type `Prop`.
- A `⊡`-prefixed sibling candidate was added so the account covers one `⊡`-bearing family.
- Phase 11.32 (Round 3) was NOT entered in this dispatch: it is NOT COSTABLE and owes a general
  construction; its fixture-level instance is already landed by this round.

## Plan Deviations

- **Phase 11.29, "state the separating type … two `theorem` signatures with `sorry` bodies"**
  altered: the `def`s were stated first, but no `sorry`-bodied signature was committed; both
  memberships closed on first compile.
- **Phase 11.29, "On outcome (a)"** skipped: outcome (a) not reached.
- **Phase 11.29, "On outcome (b): … `sorry` isolated to the one unclosed membership goal"**
  altered: zero `sorry`; neither membership is unclosed. The plan's verification line "on outcome
  (b) EXACTLY ONE [`sorry`]" is therefore not met as written — the fixture has none.
- **Phase 11.29, "Either way: record …"** altered: no new library declaration, so no
  `check-module-invariants.sh` pin and no `KTypeSummaryAxiomTest.lean` pin were owed or added.
- **Scope Hypothesis** exceeded: two formulas and fourteen printed theorems instead of one and
  one; still one fixture, no new file, no library declaration.

## Verification

- Build: Success — full `lake build` through the guard, exit 0, 2975 jobs, zero `error:` lines;
  run at phase end and again at final verification; `LadderCell.olean` newer than its source.
- Sorry count: 0
- Vacuous count: 1 by the single-line grep, pre-existing and not introduced here
  (`FormalSystem/Examples/TemporalStructures.lean:495`, a real statement proved by `trivial`); 0
  introduced.
- Axiom count: 14 (unchanged from the parent commit).
- Tests: `scripts/check-evidence-probes.sh` PASS (63 wired probes, this fixture among them);
  `scripts/check-module-invariants.sh` ALL CHECKS PASSED (after `--emit-inventory`);
  `.claude/scripts/verify-deploy.sh` PASS (15 checks).
- Plan compliance spot-check: FAILED, as expected for a plan whose Goal statements
  (`cellAt_const_of_kappa_eq`, `ladderSound`, `ladderLift`, `ladderRealized`, …) are open; not
  caused by this phase.
- Prohibited-workaround grep (`cellAt_const_of_kappa_eq_of_covered|hno|stabFree`) over the
  additions: no hit. `ParamsOk` appears only as a hypothesis at the formula under test.
- Files verified: Yes

## Impacts

- Decision entry (E-5)'s Obligation is discharged in form (b). Its own routing sends (b) to
  Round 3 (Phase 11.32); Phases 11.30/11.31 (Round 2) are excluded on this branch.
- The plan's stated reason the refutation was "predicted to work" is itself refuted for the
  `X`-chain family: thresholds are functions of the formula and outgrow its reach.
- Not established: that NO formula refutes the agreement. Families tried are box-free,
  `⊡`-depth ≤ 1, on one two-state object.

## Follow-ups

- Phase 11.32: the general non-atom-preserving count move. This round's instance
  (`exists_non_atom_preserving_count_move`) differs its atom rows beyond the formula's reach;
  a general version needs a notion of reach for `until`/`since`/`⊡` that the library does not
  have. Likely needs a `/revise` to state that obligation before an implement round.
- Four phases remain `[BLOCKED]` and eleven `[NOT STARTED]`, all downstream of the agreement.

## References

- `specs/761_ladder_realization_theorem/plans/21_refutation-first-run-level-adequacy.md`
- `specs/761_ladder_realization_theorem/records/round-21-refutation-verdict.md`
- `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`
- `specs/761_ladder_realization_theorem/.decisions.json` (route (E-5))
