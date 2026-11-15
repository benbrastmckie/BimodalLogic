# Phase 11.19 Handoff — the iterated splice's interior clauses

- **Task**: 761
- **Phase**: 11.19 (plan v15, route S-2) — closed `[BLOCKED]`
- **Dispatch**: 44, session `sess_1794715258_f96bc3`
- **Written**: 2026-11-14T23:55:00Z

## Immediate next action

Do NOT enter Phase 11.20 or Phase 11.6. Rule on the register coordinate first — the blocking
`user_decision` on `.return-meta.json` names three routes (W-1 register-closed blocks, W-2 a
weaker register conjunct in the invariant, W-3 block the record whole) and recommends W-2. Then
`/revise` plan v15 off that ruling.

## What landed

`FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean`, new section
`## The iterated splice's two interior clauses` (module `longFile` baseline raised `2000` → `2400`,
1,991 → 2,344 lines):

- `exists_iterSpliced_ladderPath_idx_interior_of_pend_past` — the first Goal clause. All four
  clauses of `exists_iterSpliced_ladderPath_idx_of_pend_past` plus
  `cntAt g' (u + i·l + j) = cntAt g (u + j) + (d − i)·l` for `i ≤ d`, `j < l`, in ONE call. Proved
  by re-running the parent's induction on `d` with the clause carried.
- `iterSpliced_register_interior_forces_block_drift` — the register clause at `i ≤ 1` implies
  `Drift (nxtAt g (u + (l − 1))) (nxtAt g u)` on any ladder path.
- `iterSpliced_register_interior_refuted` — a ladder path satisfying EVERY hypothesis of the
  parent (including the model-level `hty`, discharged at an atomic formula under the all-true
  labelling) on which that `Drift` fails, so no `g'` satisfies the clause there.
- Support: `fwdT`, `bwdT`, `labT`, `tpOf_labT_atom_const`.

Wired: three axiom pins in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (3,057 →
3,097; baseline `3100`, three lines left), the `LadderCell.lean` inventory row's prose, and the
regenerated counts in `typst/generated/status.typ`.

## Proof state at the block

The register clause's obstruction is not a goal left open — it is a refutation. The register
inside a pumped window is built by `drift_extension_of_pins` (`RunLayer.lean:388`) from the NEW
path's pins, and `walkPin` pins only at `0` and at each idle→pend region start. A block of a
pending-forever past has no region start (`hpast`), and `Count`'s only register clause is
`count_ft` (`c' = n`) at a region start, so inside the window the register's sole constraint is
`Drift`. The clause would force the original's register to be periodic with period `l` across the
copies, which needs `|nxtAt g (u + l − 1) − nxtAt g u| ≤ 1`; `nxtAt_lipschitz_two_sided` gives
only `≤ l − 1`, and `exists_typeBlock_of_spacing` (`LadderChain.lean:564`) samples
`(objAt, tpOf)` only, so no consumer can supply the missing property either.

## Key decisions

- The refutation was stated against the parent's FULL hypothesis set rather than a structural
  subset, so no vacuity escape remains.
- `ClimbWitness.climb` was reused as the witness (register climbs `0, 1, 2` over `[0, 3)` with a
  uniformly pending past) rather than authoring a new fixture.
- The second sibling was NOT landed under an added register-repeat hypothesis: no consumer could
  discharge it, so per `plan-compliance.md` that is a blocker to raise, not a deviation to
  annotate.

## Deviations

- Phase 11.19 task 1 **altered** (one sibling, not two); task 3 **skipped** (clause refuted).
  Both annotated inline on the plan's checklist, with the `**BLOCKER**` record above them.

## Verification at this point

Full `lake build` exit 0, 0 `error:` lines, 2,975 jobs, `.olean` newer than source for the touched
module. `LadderCell` and `KTypeSummaryAxiomTest` module builds exit 0 with 0 warnings. Sorry count
0; vacuous 0 module-scoped and 1 repo-wide (baseline); 14 `^axiom ` occurrences, unchanged.
`check-module-invariants.sh`, `readme-lint.sh`, `typst-sync-check.sh` (after `--fix`),
`check-evidence-probes.sh` and `check-task-references.sh --quiet` each exit 0.
