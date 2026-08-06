# Research: inherited from spawn analysis

- **Source**: `specs/428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md`
- **Parent task**: 428 (`engine_totality_at_a_quantified_branch_budget`)
- **Status**: inherited stub — this task was created by `/spawn`, and its research input is the
  parent's blocker analysis rather than an independent research pass.

## Why this task exists

The parent task's terminus `buildTableauAt_isSome_of_budget`
(`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:4416`) is proved,
sorry-free and axiom-free, but is **conditional** on four unproved residual hypotheses. This task
discharges one of them. Read the source analysis above before starting — it records the discharge
condition for each residual, the two plan premises that were refuted in-source, and the eight-entry
do-not-re-attempt register adjacent to the terminus.

## Task description

Discharge `DifficultyBounded fc U D` (at `β >= 3`), defined at FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:3914, one of the four residual hypotheses on the totality termin

## Before you start

- Read the parent plan's "Status at plan close" block and Success Criterion 11 in
  `specs/428_engine_totality_at_a_quantified_branch_budget/plans/04_ordtimesknown-strengthening-totality.md`.
- Read the do-not-re-attempt register in `MintBound.lean` (section C9, adjacent to the terminus).
  Do not propose or attempt anything it forbids.
- `Fuel.lean`, `Saturation.lean` and `Tableau.lean` are md5-pinned byte-identical by the parent
  plan. Changing any of them is a deliberate scope decision, not an incidental edit.
