# Phase 8 Handoff — Re-quantify (C1') over `trans`, Plus side; defect record emptied

- **Task**: 696
- **Phase**: 8 [COMPLETED]
- **Timestamp**: 2026-09-29
- **Session**: sess_1790680388_3d4c26 (dispatch 7)

## The Scope Hypothesis was confirmed by the compiler, before anything was removed

With the Plus-side re-quantification applied and `Incompleteness.lean` untouched, the build
failed on exactly that one module, with four errors: two in `snce_share_congr` (lines 130-131)
and two in `untl_shift_share_congr` (lines 156-157). Every other module in the tree compiled.
The three `not_plusCertifies_*` theorems each consume one of those two congruences as their only
route to a contradiction, so the authoritative retirement set is the five the plan named, and no
theorem the plan expected to fail still elaborated.

## Immediate next action

Start Phase 9: Family A in `PlusWitnessFamily/Examples.lean`, the `snce`-side certificate for
`Pp → ⊡Pp` at non-trivial sharing. Two things to know going in.

First, every producer landed so far supplies `transFullOf` — the all-true succession matrix —
so on every existing family `trans u i j ↔ share (u + 1) i j` and the re-quantification is
content-preserving. Family A is the first producer that must supply a proper sub-matrix, and if
it does not, it will reproduce the old collapse while type-checking.

Second, `not_plusValidZTime_stabSnce` in `Incompleteness.lean` is now the specification: it
names the exact target the certificate must refute.

## State at phase end

`lake build` green over all 2771 jobs, zero sorries, axiom count 14 (unchanged),
`scripts/check-module-invariants.sh` reporting ALL CHECKS PASSED with C2 at fourteen rows.

## What was retired, and where

Five declarations from `PlusWitnessFamily/Incompleteness.lean`: `snce_share_congr`,
`untl_shift_share_congr`, `not_plusCertifies_stabSnce`, `not_plusCertifies_stabSnce_premise`,
`not_plusCertifies_stabUntl`. Their C2 baseline rows and `#print axioms` lines came out of
`scripts/check-module-invariants.sh` in the same edit (nineteen rows to fourteen, pass message
updated), and their five rows came out of `docs/theorem-index.md`. The script's block comment now
states that the rows were retired as the intended signal of a successful repair, not dropped.

What survives: `stabSnceTarget`, `notStabSnceTarget`, `stabUntlTarget`,
`not_plusValidZTime_stabSnce`, `not_plusValidZTime_stabUntl`. The module docstring was rewritten
to say what the module records now.

## Soundness

`plusTruth_iff_mem` and `plusRefutes_of_certifies` are byte-identical in the diff. The only
changes to `PlusWitnessFamily/Agreement.lean` are two side-condition arguments and one docstring
line.

## Documentation debt handed to Phase 12

`PlusWitnessFamily/README.md`'s "What this certificate cannot refute" and
`WitnessFamily/Sharing/README.md`'s "Correction: (C1') is not a repair on either temporal side"
each carry a SUPERSEDED status banner naming what changed. Both need the full rewrite Phase 12
is scoped for; the banners exist so neither reads as a current claim in the meantime.
