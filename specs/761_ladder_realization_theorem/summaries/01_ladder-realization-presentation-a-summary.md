# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem: `LadderCons` and `ladderRealized` per ladder cell for all φ including box/stab letters
- **Status**: [BLOCKED]
- **Started**: 2026-10-18T22:25:36Z
- **Completed**: 2026-10-18T23:35:00Z
- **Effort**: ~1.2 hours
- **Dependencies**: 760, 775, 805, 806, 819, 820 — all six discharged
- **Artifacts**: plans/01_ladder-realization-presentation-a.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Three of this round's nine open phases landed: the records were corrected (Phase 1), the pin
lemma's lift half was promoted into `RunLayer.lean` (Phase 7), and the K-free label-level
certificate layer was promoted into a new library module `Certificate.lean` (Phase 8). Phase 9
then surfaced, and COMPILED, a refutation of two of the five recorded Goals: `ladderRealized` and
`cellAt_const_of_kappa_eq`, as written in the plan's `## Lean Challenge Statements` block, are
FALSE — they quantify over the counter-quotient parameters with no constraint, and at the all-zero
parameters the quotient is a subsingleton. Phases 9 and 13 are `[BLOCKED]`; Phases 10-12 and 14-15
are `[NOT STARTED]`. Nothing was papered over: no `sorry`, no axiom, no vacuous definition, no
weakened statement, and no edit to either side of the recorded Challenge.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` — the pin lemma's lift half
  ported verbatim from the compiled oracle `counter-lift-gates.lean` (`Probe820`): `pinCands`,
  `mem_pinCands`, `walkPin`, `drift_extension_of_pins` (the McShane extension through a compatible
  pin family), `exists_rlad_hist_of_walk` (the lift of an object walk carrying its forced
  countdown), plus the four `Count` letter-pair unfoldings `count_tt`/`count_tf`/`count_ft`/
  `count_ff` the lift proof consumes and the library did not carry. All nine elaborated signatures
  diff IDENTICAL against the probe's.
- `FormalSystem/Metalogic/Decidability/RaySummary/Certificate.lean` — NEW, 1451 lines. The K-free,
  label-level certificate of realizable closure types, promoted from
  `certificate-sufficiency-dovetailing.lean` (`Probe815`) and, through it,
  `realizable-type-certificate.lean` (`Probe809C`): the existential until-fixpoint
  (`euStep`/`euIter`/`euLfp` through `eu_mem_lfp_path_le_card`), the dovetailing theorem
  `exists_dovetail_chain`, the product layer (`ClType`, `ProdState`, `locCoh`, `untlLink`, `coh`,
  `coh_iff`), the backward arm (`snceLink`, `cohBi`, `cohBi_iff`), the certificate predicates with
  the relation as a parameter (`certLoc`, `certBiInf`, `certFwd`, `certBwd`, `certStab`,
  `certBox`, `certAdm`, `certAdm_iff`), the forward and backward chain constructions, `Realizes`,
  the splice, and the label-level sufficiency `realizes_of_certAdm_cohBi`. New here: the
  IDLE-EXTENDED relation `cohIdle` with `cohIdle_eq_cohBi_of_pend` and `cohIdle_of_cohBi`.
- `specs/evidence/seam-gluing-ray-product/ladder-unconstrained-parameter-refutation.lean` — NEW,
  wired. The fourteenth wired probe of this record: `ck_zero_subsingleton`,
  `const_shape_refuted_of_separating_pair`, `realized_shape_refuted_of_separating_pair`,
  `const_shape_refuted`, `realized_shape_refuted`, `separating_pair_nonvacuous`.
- Wiring: `RaySummary.lean` (import + module-list docstring), `FormalSystem.lean` (import),
  `scripts/check-module-invariants.sh` (two C14 baseline/`#print axioms` pairs),
  `scripts/nolints.json` (one `unusedArguments` exemption), `scripts/check-evidence-probes.sh`
  (one table row, one WIRED entry), four regenerated inventory blocks,
  `typst/generated/status.typ`.
- Records: `specs/state.json` (761's STATEMENT paragraph now names the fibre equation; the
  withdrawn `hitOf (truncate B …)` line is marked withdrawn; all six edges recorded as
  discharged), `specs/TODO.md` (regenerated),
  `specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md` (dated
  `**Amended by**` paragraphs in Sections A and C), and
  `specs/761_ladder_realization_theorem/records/design-of-record-amendment-2026-10-18.md` (a
  durable copy, because `specs/archive/` is gitignored).

## The refutation, stated precisely

`cellAt_const_of_kappa_eq` and `ladderRealized` both universally quantify `(Tc Tn P B : Nat)` and
carry NO hypothesis relating those parameters to the object, to the formula, or to each other. The
parameter constraints the design names — (K1) `P` a common multiple of the certificate graph's
cycle lengths on saturated classes, (K2) `Tc` at least the cascade bound and the semantic
periodicity threshold, (K3) `Tn ≥ Tc + 2ℓ₀ - 1` and `Tc ≥ 2 T_short + T_idle + 2`, (K4)
`B ≥ max (2 d_back + 1) 2` — appear in no statement.

At `Tc = Tn = P = B = 0` the quotient `CK 0 0 0 0 = Fin 1 × Fin 1 × Fin 1 × Fin 1 × Fin 1` has
exactly one inhabitant (`ck_zero_subsingleton` by `decide`; inhabited, `ckZero`), so
`kappa 0 0 0 0` identifies every counter pair whatever `kappa` is. `cellAt_const_of_kappa_eq` then
asserts the cell is constant in `(c, n)` outright; `ladderRealized`'s right-hand side reads
`(c, n)` only through `kappa Tc Tn P B (c, n)`, so it too is constant. Both contradict
`cell_succ_ne`: the cells at `(q, c, n)` and `(q, c + 1, n)` differ for EVERY `c` and `n` with the
next deadline held FIXED, because the formula reads the parity of the countdown at the region end,
a distance `c + 1` away.

The refutation holds for EVERY `kappa` and every candidate `Dmax` — both are universally
quantified outside the refuted statement — and its proof uses no property of `Dmax`, so it is not
an artefact of a degenerate candidate set. The separating pair is COMPILED, not assumed:
`cell_succ_ne` on the four-state tag object, ported verbatim from the wired probe
`ladder-cell-index-obstructions.lean`, over `ladderFrameAdm` with `ladderFrameAdm_isRegular` —
the record's own frame, with `[Fintype Q]` and `[Nonempty Q]` on the OBJECT only. Non-vacuity is
witnessed on both sides: `separating_pair_nonvacuous` exhibits a type in each cell.

**What is NOT refuted.** The PRESENTATION stands entirely: the set-valued per-state datum, the
fibre equation over the maximum certified subset, and the factorization lemma as a COROLLARY. So
do three of the five Goals — `ladderSound` (whose conclusion is an existential over `Dmax`, which
a coarser quotient can satisfy), `ladderLift`, and `ladderCons_localRun`. Route A stays closed. No
bound is asserted anywhere; every quantity named is a count; no device-discrimination claim is
made.

**The repair, pointed at and NOT taken.** Adding `(hp : ParamsOk Tc Tn P B)` to the two refuted
statements, with `ParamsOk` defined beside `CK`/`kappa` as the conjunction of (K1)-(K4), would
remove the all-zero tuple from their scope. That is a change to a recorded Challenge statement.
`plan-compliance.md`'s Statement Fidelity section routes a genuinely wrong recorded statement to
`[BLOCKED]` and an explicit raise, and forbids both quietly changing the implementation to match a
different statement and quietly editing the recorded Challenge to match what was implemented.
Neither move was made.

## Per-obligation status

| Obligation | Status |
|---|---|
| (S) `ladderSound` | NOT ATTEMPTED — Phase 11 `[NOT STARTED]`, gated behind Phase 9 |
| (C') `ladderLift` | NOT ATTEMPTED — Phase 12 `[NOT STARTED]`, the plan's own not-costable contingency point |
| `ladderCons_localRun` | NOT ATTEMPTED — Phase 10 `[NOT STARTED]`, needs Phase 9's K-indexed `certAdm` |
| `cellAt_const_of_kappa_eq` | REFUTED as recorded — Phase 13 `[BLOCKED]` |
| `ladderRealized` | REFUTED as recorded — Phase 13 `[BLOCKED]` |
| (K1)-(K4) the parameter sources | BLOCKED — Phase 9; the constraints are referenced by no statement that consumes `K` |
| Gate 8 (`stab` acceptance on a `stab`-bearing fixture) | STILL SIDESTEPPED — Phase 14 `[NOT STARTED]`; no fixture's closure yet carries a `⊡` member |

## Decisions

- Nine declarations ported in Phase 7, not the five predicted: the four `Count` letter-pair
  unfoldings are probe-local and the lift proof consumes them, which the phase's own Scope
  Hypothesis licenses.
- `certStab` and `certAdm` WERE promoted in Phase 8, at the K-free carrier `ProdState Q φ`,
  against that phase's Scope Hypothesis. `realizes_of_certAdm_cohBi`, which the same task list
  requires, is stated in terms of `certAdm` and its proof destructures `certAdm_iff`'s six fields
  including the `stab` one; the theorem cannot be promoted without both. The K-indexed versions
  are over a different carrier and would carry different names (`certStabK`, `certAdmK`).
- `cohIdle` takes no `pend` parameter. Dropping `cohBi`'s two `pend` conjuncts removes the
  relation's dependence on the pending bit entirely, so carrying the parameter unused would both
  trip `linter.unusedVariables` and misrepresent the relation.
- `lean-challenge-snapshot.sh` was NOT forced past its status gate. It refused (exit 73, status
  already `implementing`) and its own banner states that a Challenge produced after implementation
  has started certifies nothing; forcing one would commit misleading provenance. Signature
  fidelity was verified by direct diff against the plan's Challenge block instead.
- Phase 7's two `show` → `change` rewrites and Phase 8's nine are linter-forced and
  statement-preserving, each recorded at its site and in the module headers. `coh_iff` keeps the
  probe's two unused instance binders under a scoped `set_option` plus a `nolints.json` entry,
  because dropping a hypothesis changes a verbatim-ported statement.

## Plan Deviations

- **Phase 1**, `.blocker-research.json` correction: skipped — the file does not exist; the landed
  route was recorded in `specs/state.json`'s amended description instead.
- **Phase 1**, the snapshot: altered — `lean-challenge-snapshot.sh` refused on the status gate and
  was not forced; `--check` is therefore unavailable to later phases.
- **Phase 1**, the design-of-record amendment: altered — `specs/archive/` is gitignored
  (`.gitignore:94`), so the two amendment paragraphs were additionally reproduced verbatim in
  `records/design-of-record-amendment-2026-10-18.md` so they survive a fresh clone.
- **Phase 7**, the port: altered — nine declarations moved, not five.
- **Phase 8**, the promoted set: altered — `certStab` and `certAdm` promoted too, at the K-free
  carrier, because `realizes_of_certAdm_cohBi` cannot be stated without them.
- **Phase 8**, the wiring list: altered — three files beyond the three named, all demanded by
  `check-module-invariants.sh`.
- **Phases 9, 13**: BLOCKED on the refutation above.
- **Phases 10, 11, 12, 14, 15**: not started. Phase 10 needs Phase 9's K-indexed `certAdm`, and no
  phase after 9 can proceed until the repair is decided.

## Verification

- Build: Success — full guarded `lake build`, exit 0, 0 `error:` and 0 `warning:` across both
  captured streams, 2889 jobs, `Build completed successfully`; `.olean` newer than source for both
  touched library modules.
- Sorry count: 0
- Vacuous count: 1, UNCHANGED from the dispatch's starting commit. The single hit is pre-existing
  at HEAD — `FormalSystem/Examples/TemporalStructures.lean:495` `int_domain_universal`, whose
  `:= trivial` closes a real goal because membership in the universal domain is `True` by
  definition. The plan's "count 0" criterion was unmeetable as written; reported as
  baseline-unchanged instead.
- Axiom count: 14, unchanged from baseline.
- `#print axioms` on every new headline theorem: `[propext, Classical.choice, Quot.sound]` — no
  `sorryAx`, no custom axiom, no `native_decide`. `drift_extension_of_pins` and
  `exists_rlad_hist_of_walk` carry exactly the probe's recorded profile;
  `realizes_of_certAdm_cohBi` and `exists_dovetail_chain` are now C14-pinned.
- `check-evidence-probes.sh`: exit 0, all 44 wired probes PASS, including the new one.
- `check-module-invariants.sh`: ALL CHECKS PASSED. `readme-lint.sh`: PASS.
  `typst-sync-check.sh`: PASS. `verify-deploy.sh`: exit 0.
- `check-task-references.sh`: 0 unexempted occurrences outside `specs/`.
- `AnchorLayer.lean` untouched: `git diff HEAD` on it is empty, so `anchorCells_finite` and
  `anchorCells_ncard_le` are unchanged.
- Signature fidelity: Phase 7's nine declarations diff IDENTICAL against the probe's elaborated
  signatures; Phase 8's promoted body diffs against its probe source with 22 hunks, every one a
  recorded adaptation (nine `show`→`change`, eleven docstrings, the C29 reason comment and its two
  `set_option` lines, two wrapped long lines, three blank lines) and ZERO statement changes.
- Tests: N/A — no test target touched.
- Files verified: Yes.

## Guardrail read-through

(a) The letters stay closure-indexed over the time axis with the `box`/`stab` bits included:
`certBox` and `certStab` are conditions of `certAdm` in the promoted layer and are never dropped.
(b) Infinite width, no fibre bound: the only finiteness anywhere added is `[Fintype Q]` on the
OBJECT, exactly as the probes have it; the ladder slice stays infinite
(`Rlad_slice_infinite`). (c) No upper bound is claimed: `euLfp` is a fixpoint of a monotone
operator on a `Finset`, `eu_lfp_eq_iter_card` is a count of iterations, and the refutation names
no quantity that is not a count. (d) Zero debt: no Büchi or MSO lemma is cited in place of a
proof, nothing external is required, no cslib dependency was added. (e) The ladder's structural
liveness is FORWARD-ONLY, machine-checked — `gPast_isPath`, `gPast_pending_past`, `gPast_count`
show a ladder history can be pending at every past time, so `Count` discharges `ulive` forward and
never `slive` backward; a ladder bundle replaces `ulive` only and retains `slive`. No
device-discrimination claim is made anywhere.

## Impacts

- `RunLayer.lean`'s pin lemma lift half and `Certificate.lean`'s whole label-level layer are now
  available to the library, so the counter half of the lift and the certificate sufficiency no
  longer live only in probes. 763 (the lift and the `Decidable (PlusValidZTime φ)` corollary)
  consumes this record and remains gated on it.
- The refutation changes this record's definition of done: `ladderRealized` cannot be proved as
  recorded, so the record needs a `/revise` that rewrites the two refuted statements before any
  further phase runs.

## Follow-ups

- **User decision required**: how to repair `cellAt_const_of_kappa_eq` and `ladderRealized`. The
  shape the refutation points at is `(hp : ParamsOk Tc Tn P B)` on both, with `ParamsOk` defined
  in Phase 9 as the conjunction of (K1)-(K4); existentially quantifying the parameters is the
  other obvious reading. `ladderSound`, `ladderLift` and `ladderCons_localRun` need no change.
- Phase 9 must additionally DEFINE `ParamsOk` if that repair is chosen; it is not in its current
  task list.
- Gate 8 remains SIDESTEPPED: no fixture's closure carries a `⊡` member. Phase 14 is the step that
  would build one.
- `lean-challenge-snapshot.sh` cannot be taken for this task any more without `--force`; a future
  round should snapshot at `planned`, before the status moves to `implementing`.
- `lake-build-guard.sh` replays a completed result whose scope key matches, so repeated
  `build -- env lean <same scratch path>` invocations need `--no-share`.

## References

- `specs/761_ladder_realization_theorem/plans/01_ladder-realization-presentation-a.md`
- `specs/761_ladder_realization_theorem/reports/01_ladder-realization-theorem.md`
- `specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md`
- `specs/820_ladder_counter_lift_lemma_gated/summaries/01_counter-lift-gate-table-summary.md`
- `specs/evidence/seam-gluing-ray-product/ladder-unconstrained-parameter-refutation.lean`
- `specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean`
- `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`
- `specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean`
- `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean`
- `specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean`
- `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`
