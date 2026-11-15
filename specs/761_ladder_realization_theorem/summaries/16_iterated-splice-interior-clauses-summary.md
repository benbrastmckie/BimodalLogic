# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem
- **Status**: [BLOCKED]
- **Started**: 2026-11-14T23:21:00Z
- **Completed**: 2026-11-14T23:59:00Z
- **Effort**: ~0.7 h
- **Dependencies**: 760, 775, 805, 806, 819, 820 (all DISCHARGED); 836 artifacts consumed as input, not as an edge
- **Artifacts**: plans/15_depth-stratified-threshold-margins.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 11.19 of plan v15 (route S-2) asked for two clauses of the iterated splice that the landed
pump theorem does not expose: the interior-copy countdown and the interior register. The first is
LANDED and green. The second is REFUTED — not merely unproved — by two compiled theorems, and the
refutation breaks the recorded S-2 obligation, which names both clauses as prerequisites of any
depth induction, as well as Phase 11.20's `~_d` relation, whose `n = n'` conjunct the pump's own
position pairs do not satisfy. The phase closes `[BLOCKED]` with the goal state recorded and a
blocking `user_decision` returned.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — three new theorems and three
  supporting declarations, plus a section docstring, an amended module Contract paragraph, and the
  in-source `longFile` baseline raised from `2000` to `2400` (1,991 → 2,344 lines):
  - `exists_iterSpliced_ladderPath_idx_interior_of_pend_past` — **LANDED**. A sibling of
    `exists_iterSpliced_ladderPath_idx_of_pend_past` (`LadderChain.lean:855`) carrying all FOUR of
    its parent's clauses plus a fifth: for `i ≤ d` and `j < l`,
    `cntAt g' (u + i·l + j) = cntAt g (u + j) + (d − i)·l`, at exactly the positions
    `iterSpliceIdx_add_mul` retracts to `u + j`. One call delivers all five clauses. Proved by
    re-running the parent's induction on `d` with the clause carried; the clause is NOT derived
    from the parent, whose existential exposes no interior countdown to derive it from. Neither
    parent, nor `iterSpliceIdx`, nor any of its characterization lemmas was edited.
  - `iterSpliced_register_interior_forces_block_drift` — **the obstruction**. On any ladder path,
    the register clause at `i ≤ 1` alone implies `Drift (nxtAt g (u + (l − 1))) (nxtAt g u)`: the
    clause makes the step from the top of copy `0` to the bottom of copy `1` one step of `g'`
    between those two values of the ORIGINAL's register.
  - `iterSpliced_register_interior_refuted` — **the refutation**. On
    `ClimbWitness.climb` with the block `[0, 3)` of its pending-forever past, every hypothesis of
    the parent holds — `0 < l`, `l ≤ cntAt g u`, the uniformly pending past, the object-closed
    block, a history over the path, the realized-type equality at the block's two ends, and the
    stab-free closure condition — and yet NO ladder path at all satisfies the register clause
    there, because `nxtAt` climbs `0, 1, 2` across the block.
  - Supporting: `fwdT`, `bwdT` (the admissible carrier's two seriality conditions for the
    two-state object `stepT`/`pendT`; `no_fwd`/`no_bwd_of_idle` refute them on the UNRESTRICTED
    carrier, and the admissible restriction is what makes them hold), `labT` (the all-true
    labelling), and `tpOf_labT_atom_const` (under `labT` every realized type of an atomic formula
    is position-independent, which is what makes the pump's type hypothesis free on the witness).
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — a layer docstring and three
  `#guard_msgs`-pinned `#print axioms` entries (3,057 → 3,097 lines; the in-source baseline is
  `3100`, so three lines of headroom remain — the plan's "eight lines of headroom" note was stale
  and the re-measured figure before editing was 43).
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/README.md`,
  `README.md` — regenerated inventory counts plus hand-written prose on the `LadderCell.lean` row
  describing the landed clause and the refuted one.
- `typst/generated/status.typ` — regenerated line counts.
- `specs/761_ladder_realization_theorem/plans/15_depth-stratified-threshold-margins.md` —
  Phase 11.19 marked `[BLOCKED]` with a structured `**BLOCKER**` record; its five checklist items
  annotated; Phase 11.20's `Depends on` annotated `WAITING, NOT ENTERABLE`.

## Decisions

- **The refutation is stated against the parent's FULL hypothesis set, not a structural subset.**
  The cheaper route — exhibit a path satisfying `hl`/`hcl`/`hpast`/`hrep` and leave the
  model-level `hty` undischarged — would have left open whether `hty` is false for every
  register-climbing block, which would make the clause vacuously true there. Discharging `hty` at
  an atomic formula under the all-true labelling (`tpOf_labT_atom_const`) closes that gap, at the
  cost of `fwdT`/`bwdT`. The refutation is therefore complete, not "modulo `hty`".
- **The already-landed `ClimbWitness.climb` path was reused rather than a new fixture authored.**
  Its register climbs `0, 1, 2` over `[0, 3)` while the past is uniformly pending, which is
  exactly the shape the obstruction needs.
- **Home is `LadderCell.lean`, not `LadderChain.lean`,** as the plan directs: re-measured before
  editing, `LadderChain.lean` had 14 lines of headroom against its in-source baseline `3000` and
  `LadderCell.lean` had 9 against `2000`, so the length remedy was a certainty in either module.
  The baseline was raised in place; the contingency module `LadderCascade.lean` was NOT created and
  no import edge was added.
- **The plan's second sibling was not landed under a weakened signature.** Adding a
  register-repeat hypothesis `nxtAt g u = nxtAt g (u + l)` would make the clause provable (the
  periodic extension is then `Drift`-compatible at the copy boundaries), but
  `exists_typeBlock_of_spacing` (`LadderChain.lean:564`) samples `(objAt, tpOf)` only, so no
  consumer could discharge it. Per `plan-compliance.md`, that is a blocker to raise, not a
  deviation to annotate and proceed past.

## Plan Deviations

- **Phase 11.19, task 1** altered: only the first sibling is landed; the second is not, because
  its clause is refuted. Neither parent was edited.
- **Phase 11.19, task 3** skipped: the register clause is refuted. The phase's own question —
  whether the register is held at the interior because the walk determines it or because the
  re-lift pins it — is answered NEITHER, and that answer is recorded in the section docstring.

## Verification

- Build: Success. `lake build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell` exits 0
  with 0 warnings and 0 errors; `lake build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0
  with 0 warnings and 0 errors (2,413 jobs), its three new axiom pins green. Both guarded, with an
  explicit `--timeout`, in the bounded single-call idiom. A full-project build was NOT run: the
  phase closes `[BLOCKED]`, so no phase-closing commit is fired on it.
- Sorry count: 0 (`lean-sorry-census.sh` over the four resolved source roots, exit 0).
- Vacuous count: 0 module-scoped; 1 repository-wide, unchanged from its baseline.
- Axiom count: 14 `^axiom ` occurrences over `FormalSystem`/`Tests`, unchanged — no `axiom` was
  introduced. `#print axioms` on each new declaration reports a subset of
  `[propext, Classical.choice, Quot.sound]`; `iterSpliced_register_interior_forces_block_drift`,
  `fwdT` and `bwdT` sit BELOW the standard profile.
- Parents byte-identical: `git diff` names no change to `LadderChain.lean` at all, so
  `exists_iterSpliced_ladderPath_idx_of_pend_past`,
  `exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past` and `iterSpliceIdx` are untouched.
- Gates: `check-module-invariants.sh` exit 0, `readme-lint.sh` exit 0, `typst-sync-check.sh` exit 0
  after `--fix` regenerated `status.typ`, `check-evidence-probes.sh` exit 0,
  `check-task-references.sh --quiet` exit 0.
- Certificate-freedom grep over the touched module: UNCHANGED, not empty — `LadderCell.lean` is
  not certificate-free by design, and this phase added no certificate reference.
- Tests: N/A beyond the axiom-profile test module above.
- Files verified: Yes.

## Carried-Figure Discipline

The three flagged `## Description` lines were checked against live state:

- `Realize.lean` at 1,004 lines — CONFIRMED unchanged (`wc -l` reports 1004).
- `w-soundness-shape-refuted.lean` present in `specs/evidence/seam-gluing-ray-product/` —
  CONFIRMED present.
- The CONTINGENCY line's prohibitions (no sorry, axiom, vacuous definition, trace-level
  hypothesis, finite-fibre or finite-width assumption) — CONFIRMED honoured: sorry count 0, no new
  axiom, no vacuous definition, and the landed theorem's hypotheses are the parent's, which are
  `HitPresented`-free and carry no fibre or width bound.

## Impacts

- Phase 11.20 is NOT enterable and is annotated `WAITING, NOT ENTERABLE`: its `~_d` relation
  carries `n = n'` and its membership cases 3 and 4 were to be discharged by the refuted clause.
  Phases 11.6 and 12–18 remain downstream of it.
- The recorded S-2 obligation is NOT discharged as filed. Its first requirement names both clauses
  and requires both BEFORE any depth induction; one is refuted. A blocking `user_decision` is
  returned naming the register coordinate as the second obstruction S-2 leaves unaddressed, per the
  dispatch's Prior-Decisions contract.
- The landed countdown clause is independently reusable: it is the pump's own bookkeeping and is
  consumed by nothing yet, so it survives whatever ruling is taken on the register.

## Follow-ups

- The ruling the blocker asks for: either a pigeonhole that samples the register (so a block is
  register-closed, which is exactly what makes the periodic extension `Drift`-compatible at the
  copy boundaries), or a transport invariant whose register conjunct is weaker than equality.
- `exists_typeBlock_of_spacing`'s sample alphabet is `Q × Finset PlusFormula`; adding a register
  coordinate to it is not free — the register is unbounded in a pending-forever region, so a
  register-sampled pigeonhole needs a bounded register observable, which is a design question and
  not a proof step.
- The plan's "eight lines of headroom" figure for `KTypeSummaryAxiomTest.lean` was stale (43 at
  this dispatch's measurement, 3 after this phase's additions); a successor phase adding pins there
  should re-measure, and the baseline `3100` will need raising.

## References

- `specs/761_ladder_realization_theorem/plans/15_depth-stratified-threshold-margins.md` —
  Phases 11.19 (now `[BLOCKED]`) and 11.20 (annotated waiting)
- `specs/761_ladder_realization_theorem/reports/15_stab-bit-copy-pair-decision.md` — the round-15
  evidence that put the plan on route S-2
- `specs/761_ladder_realization_theorem/summaries/16_depth-stratified-threshold-margins-summary.md`
  — Phase 11.18, the margin half of the S-2 obligation's first requirement
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — the untouched pump spine
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — this phase's additions
