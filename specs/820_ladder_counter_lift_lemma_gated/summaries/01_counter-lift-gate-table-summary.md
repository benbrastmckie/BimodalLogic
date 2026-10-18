# Implementation Summary: Task #820

- **Task**: 820 - The counter-lift lemma, research-first and gated: compile the gate table
- **Status**: [COMPLETED]
- **Started**: 2026-10-18T18:45:00Z
- **Completed**: 2026-10-18T20:25:00Z
- **Effort**: ~9 phases across three dispatches (this one resumed a stalled dispatch on phases 7-9)
- **Dependencies**: 819 (the presentation decision) — discharged
- **Artifacts**: plans/01_counter-lift-gate-table.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The counter-lift lemma was run as a GATE TABLE on a 4-cycle fixture of product period four,
before any sufficiency attempt, exactly as the research-first contract required. Every gate row
now carries a compiled verdict, the pin lemma's lift half is compiled, and **both decision gates
COLLIDE** — so neither hazard is a seventh mechanism, the ladder route is not closed, and the
counter-lift lemma's two halves are LICENSED in pumping form (licensed, not proved). The
positionwise statement shape is refuted for every finite counter quotient.

## What Changed

- `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` — the wired probe, 3104 lines,
  0 `sorry`, 0 warnings, `lake env lean` exit 0. Theorems of record:
  - Arithmetic layer: `forward_window` (`|L - n| ≤ c + j`), `backward_constraint`
    (`n ∈ [c - 1, c + 2s + 1]`, pin `c + s`), `region_doubling` (`L' ≤ 2L + j + 1`),
    `doubling_attained` (the bound attained at `j = 1`), `iter_doubling`
    (`a k + J + 1 ≤ 2^k (a 0 + J + 1)`).
  - Statement shape: `no_positionwise_lift` — for EVERY finite `K`, every `κ`, and every sound
    local relation on `Bool × K`, some chain is the projection of no history.
  - Separation rows: `gate1_cell_ne`, `gate2_cell_ne`, `gate9_sep_cell_ne`,
    `short_idle_cell_ne` (with `short_idle_shape_collides`, `short_idle_threshold_refuted`).
  - **Decision gates, both COLLISION**: `gate9_col_cell_eq` and `gap_shift_cell_eq`, each an
    EQUALITY of `cellAt` values, with non-vacuity witnessed on both sides first.
  - The gap-shift absorber as its own theorem: `absorber4`.
  - Gap-shift supporting layer (this dispatch): `past7`, `past7_in`/`_start`/`_deep_true`/
    `_deep_false`, `past7_junction`, `wit7` and its lemmas, `StartAt`, `startAt_unique`,
    `startAt_or_forever`, `startAt_pend_neg_one`, `back_index`, `start_index`, `at0_S1`,
    `at0_S2`, `at0_U1`, `at0_S1_forever`, `at0_S2_forever`, `at0_p7`, `at0_l7`, `at0_Ynp7`,
    `at0_Yp7`, `at0_XB7`, `agree7`, `tpOf_eq_of_datum'`, `HasDatum7`, `exists_datum7`,
    `truth_of_datum7`, `D7`, `datum7_achievable`, `datum7_achievable_shift`,
    `datum7_realized_forever`/`_start`/`_fresh`, `cell_subset_of_datum7`.
  - Pin lemma, lift half: `drift_extension_of_pins`, `exists_rlad_hist_of_walk` (plus
    `pinCands`, `mem_pinCands`, `walkPin`).
- `scripts/check-evidence-probes.sh` — the decision-row block rewritten with the final verdicts
  and the decision they hold in place; the probe stays `WIRED`.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — one new (W) paragraph citing the
  probe by filename and theorem names.
- `specs/ROADMAP.md` — both `/orchestrate 820` lines dropped, 761 un-gated, the Stage 1 adequacy
  bullet's gate dispositions moved to the compiled verdicts.
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`
  (SOURCE STORE, never the deployed mirror) — the pin lemma as a "What the counters constrain"
  item; the pumping-form paragraph beside the parameter-origin rule citing `no_positionwise_lift`;
  the cascade bound added as `T`'s third source with `iter_doubling` its arithmetic; the three
  formerly-DERIVED items relabelled COMPILED with their theorem names, and the two hazards given
  their compiled verdicts.

## Decisions

- **The gap-shift closure's datum is a flat 5-tuple, not an `Option`-valued one.**
  `Datum7T = Bool × Bool × Fin 4 × Bool × Bool` = (position `-1` pending; the past has a region
  start at all; the region's age residue; the previous idle run has length exactly 1; the next
  region starts at once). The flat shape kept the `⊆` direction of the achievability equality to
  two lemmas (`startAt_or_forever`, `startAt_pend_neg_one`) instead of `Option` juggling.
- **`T₀ = 1` and `g₀ = 1`, both counts, and the reason differs from the plan's anticipation.**
  With the previous idle run pinned at length 1, `chi` does not pin the previous region at all,
  so that region may be pending forever with its deadline unconstrained: the cascade terminates
  at depth 2 WITHOUT any `region_doubling` application, and imposes no lower bound on `c`. The
  threshold the gate does need is forced by a different closure member — `X (p ∧ ℓ j₀)` reads
  position 1, which the current region must still fill. `g₀ = 1` is what makes the age-0 datum
  realizable (at age 0 the pin forces `n ≤ c + 1`).
- **`j₀ = idx c` is what makes the shift work**: `idx (c + 4) = idx c`, so the same closure serves
  both states of the pair.
- **The achievable datum set `D7` mentions neither `c` nor `n`.** That is what the absorber buys,
  and it makes `datum7_achievable_shift` the same set on both sides rather than a pumping argument
  on a given history.
- A fragile `simp only` chain in the stalled dispatch's `absorber4` fragment was replaced by four
  `past7` evaluation lemmas plus `dsimp only` after each rewrite group — `rw` leaves tuple
  projections unreduced inside the `Rlad` conjuncts, which was the root cause of all eight errors
  the fragment carried.

## Plan Deviations

- **Phase 7, `T₀` computation** altered: the hand computation came out stronger than the Scope
  Hypothesis anticipated (no `region_doubling` application, no cascade-forced lower bound on `c`);
  `T₀ = 1` is forced by a different closure member. Recorded in the probe header as a count.
- **Phase 7, the datum-set equality** altered: the `⊆` direction needed only `startAt_or_forever`
  and `startAt_pend_neg_one`, not `backward_constraint` or `region_doubling`; the `⊇` direction is
  three explicit witness families rather than a pumping of a given history. No statement narrowed.
- **Phase 7 contingency** skipped: not reached — the equality compiled, so no modulus-8 retry and
  no `gap_shift_refuted`.
- **Phase 9, context file** extended beyond the three listed edits: the three DERIVED counter items
  were relabelled COMPILED with their theorem names and the two hazards given their compiled
  verdicts, since the phase's goal is that every record say exactly what was compiled.

## Verification

- Build: Success — full `lake build` through `lake-build-guard.sh`, guard exit 0,
  "Build completed successfully (2888 jobs)", 0 `error:` across both captured streams. No Lean
  module under a Lake target root was touched by this task (the probe lives outside every target
  root; the README change is markdown), and `RunLayer.olean` is newer than its source.
- Probe: `lake env lean specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` exit 0,
  0 errors, 0 warnings.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots; and 0 in the probe).
- Vacuous count: 1 pre-existing occurrence, NOT introduced here and NOT vacuous —
  `FormalSystem/Examples/TemporalStructures.lean:495`
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`, whose goal
  genuinely reduces to `True`; last touched four days before this task by an unrelated commit.
  Zero vacuous definitions were introduced by this task.
- Axiom count: 14, unchanged from the dispatch's starting commit. No `axiom` declaration added.
- Per-theorem axiom profile, from the final `#print axioms` run: `[propext, Quot.sound]` on
  `iter_doubling`, `doubling_attained`, `short_idle_shape_collides`;
  `[propext, Classical.choice, Quot.sound]` on every other headline theorem, including both
  decision gates and both pin-lemma theorems. No `sorryAx`, no custom axiom, no `native_decide`.
- `bash scripts/check-evidence-probes.sh` exit 0 — all 43 wired probes compile.
- `bash scripts/check-module-invariants.sh` exit 0.
- `bash .claude/scripts/verify-deploy.sh` exit 0 (15 checks, 0 failures).
- `bash .claude/scripts/check-task-references.sh` — 0 unexempted occurrences outside `specs/`.
- `bash .claude/scripts/validate-artifact.sh ... plan` — PASS, 0 warnings.
- Plan compliance spot-check: all seven names in the plan's **Goals** (`forward_window`,
  `backward_constraint`, `region_doubling`, `iter_doubling`, `no_positionwise_lift`,
  `drift_extension_of_pins`, `exists_rlad_hist_of_walk`) are declared in the probe. Passed.
- Statement fidelity: `lean-challenge-snapshot.sh --check` is UNAVAILABLE for this task (exit 71,
  "no manifest found" — the snapshot was never taken at plan time). That is an unavailable
  advisory check, not a drift finding, and it is recorded here rather than treated as a pass. In
  its place both pinned signatures were compared token-by-token against the plan's
  `## Lean Challenge Statements` block and match verbatim, and that block was re-compiled
  standalone: exactly seven `declaration uses 'sorry'` warnings, no errors.
- Tests: N/A (no test target touched).
- Files verified: Yes.

## Hard Constraints, Re-checked

- No tuple index stated as a candidate at any parameters; `K` stays a carrier coordinate.
- No seventh coordinate proposed — and neither decision gate exhibited one.
- No complexity claim and no upper bound: every quantity is a count, including `T₀ = 1` and
  `g₀ = 1`.
- No finiteness added: `anchorCells_finite` and `anchorCells_ncard_le` untouched.
- The `box`/`stab` acceptance clause is never dropped from any statement.
- Zero debt: no Büchi or MSO lemma cited in place of a proof.
- Route A not entered; the decision record remains the presentation-decision report.
- Gate 8 SIDESTEPPED (no `stab` member in any closure), gate 3 CARRIED.

## Impacts

- Task 761 (`ladderRealized`/`LadderCons`, the ladder realization record) is un-gated: all six of
  its declared edges are discharged and the positive branch licenses the pumping form it needs.
  761 inherits the obligation to discharge (S), (C') and (K1)-(K4) — licensed is not proved.
- Task 763 (the lift `not_plusValidZTime_iff_ladderRefutes` and `Decidable (PlusValidZTime φ)`)
  continues to wait on 761 alone.
- The pin lemma's lift half is available generically in `Q`, `step`, `pend`; moving it into
  `RunLayer.lean` is a successor's choice, deliberately outside this task's `file_scope`.

## Follow-ups

- `certStab` must still be rebuilt per `(q, κ)` (`stab_mem_tpOf_iff` is per cell) — obligation (4),
  untouched here and owed by the successor record.
- Gate 8 stays SIDESTEPPED until a `stab`-bearing fixture is run; that fixture does not exist yet.
- No Challenge snapshot exists for this task, so the mechanical signature check could not run.
  Taking the snapshot at plan time would make it available for the successor record.
- The gap-shift gate is compiled at modulus 4 on one fixture; a gate probing one coordinate
  certifies one coordinate.

## References

- `specs/820_ladder_counter_lift_lemma_gated/plans/01_counter-lift-gate-table.md`
- `specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md`
- `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`
- `specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean`
- `specs/820_ladder_counter_lift_lemma_gated/handoffs/` (per-phase handoffs, phases 1-8)
