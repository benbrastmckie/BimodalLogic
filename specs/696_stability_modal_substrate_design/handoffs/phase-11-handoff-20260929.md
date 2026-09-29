# Phase 11 Handoff — The closure obstruction, wired as an evidence probe

- **Task**: 696
- **Phase**: 11 [COMPLETED]
- **Timestamp**: 2026-09-29
- **Session**: sess_1790680388_3d4c26 (dispatch 7)

## What this phase establishes

`specs/evidence/stability-modal-substrate/closure-field-is-necessary.lean` holds
`stabFamily_not_liftable_at_transId`: take the landed (C5) witness, replace its free-succession
matrices by the no-hopping bundle and change nothing else, and `LiftableRaw` becomes false. So
the `lift` field is a genuine obligation, not a defensive one, and a future dispatch that tries
to eliminate it as boilerplate now has a machine-checked counterexample to contend with.

The probe is wired into `scripts/check-evidence-probes.sh`'s `WIRED` array with a header table
entry naming the decision it holds in place. The checker now reports seven wired probes, all
passing.

## Scope Hypothesis verdict

Held with a correction to the statement's shape. `stabFamily` as it stands supplies
`transFullOf`, so its own `lift` field IS discharged; the obstruction is about the alternative
design, not about the landed family. The probe says so explicitly, and its own docstring records
why that is a refutation of a named alternative rather than a restatement of the field's
existence.

## Immediate next action

Start Phase 12, the last: documentation, the hand-off contract, and the full gate set. The two
README status banners Phase 8 left in place are the main debt —
`PlusWitnessFamily/README.md`'s "What this certificate cannot refute" and
`WitnessFamily/Sharing/README.md`'s "Correction: (C1') is not a repair on either temporal side"
both still narrate the defect as current, under a SUPERSEDED banner, and Phase 12 is scoped to
rewrite them.

## State at phase end

`lake build` green, zero sorries, axiom count 14 (unchanged),
`scripts/check-module-invariants.sh` ALL CHECKS PASSED with C2 at eighteen rows,
`scripts/check-evidence-probes.sh` passing all seven wired probes.
