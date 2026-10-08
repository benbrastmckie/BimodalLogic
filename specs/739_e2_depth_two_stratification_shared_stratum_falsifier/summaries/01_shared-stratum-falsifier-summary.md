# Implementation Summary: Task #739

- **Task**: 739 - Run E2's real test: the depth-2 stratification falsifier on a fixture with two states sharing a depth-1 stratum
- **Status**: [COMPLETED]
- **Started**: 2026-10-08T20:50:27Z
- **Completed**: 2026-10-08T21:09:48Z
- **Effort**: ~1.5 hours (plan estimate 6 hours)
- **Dependencies**: None
- **Artifacts**: plans/01_shared-stratum-falsifier.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

A new evidence probe, `specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean`
(namespace `Probe739SharedStratum`), runs the depth-2 stratification falsifier on the research
report's four-state Fixture D, where two distinct states genuinely share the depth-1 stratum
`⊡Fp` in both directions (`{a, c}` share False, `{b, d}` share True). Five depth-2 shapes are
computed directly and through the strata, exactly as the landed `stab-depth-two-probe.lean` does,
and the falsifier's question is asked non-vacuously on each class. The outcome is MIXED and the
refutations are the headline: the literal one-bit reading of "function of the stratum" is REFUTED,
machine-checked, for the landed shape `⊡(Fp → ⊡Fp)` (on `{a, c}`), the mixed shape
`⊡(Fp → ⊡Pp)` (on `{b, d}`), and the past mirror `⊡P(⊡Fp)` (on `{b, d}`), while `⊡F(⊡Fp)`,
`⊡(Pp → ⊡Fp)` and `⊡(Fp → ⊡Fp)`-on-`{b, d}` survive non-vacuously — the real upgrade of E2 for
those shapes. The landed probe's positive on its own fixture is untouched; both results stand.

## What Changed

- `specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean` — created (1,169
  lines). Fixture (carrier `S`, hand-built `Fintype`, `edge`, `Rg`, bi-seriality as the named
  theorems `Rg_fwd`/`Rg_bwd`, `ofSlicedStep` frame with `IsRegular`, model `Mg`); neighbour
  tables by `decide`; generic closure lemmas `stays_fwd`/`stays_bwd` over
  `Int.leInduction`/`Int.leInductionDown`; constructed histories `stay` (`stayA`, `stayB`,
  `stayC`), `jumpB`, `fromA`, `viaD`; depth-1 strata `stab_will_iff` (b ∨ d) and
  `stab_past_iff` (d) with per-state corollaries; the five direct depth-2 characterizations
  `depth2_S1_iff` (b ∨ d), `depth2_S2_iff` (≠ a), `depth2_M1_iff` (c ∨ d), `depth2_M2_true`,
  `depth2_S1past_iff` (d), plus the two unpinned optional rows `depth2_optPastImp_iff` (≠ b)
  and `depth2_optPastPast_false`; fresh-atom lemmas `stab_fp_iff_fresh`, `stab_pp_iff_fresh`,
  `atom_iff_fresh`; `depth2_via_strata_{S1,S2,M1,M2,S1past}` and
  `strata_is_atomize_{S1,S2,M1,M2,S1past}` (each a `plusTruthAt_iff_atomize` citation);
  certificates `shared_false_stratum` (a vs c), `shared_true_stratum` (b vs d); positive checks
  `value_is_function_of_stratum_S1`, `_M2`, `_S2_on_true_class`; refutations
  `not_function_of_stratum_S2`, `_M1`, `_S1past`; final header; 29-line `#print axioms` foot.
- `scripts/check-evidence-probes.sh` — append-only: one `WIRED` entry (last) and one table row
  after the `stab-depth-two-probe` row, labelled `E2 (probe iii)` (34 lines added, 0 deleted).
- `specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean` — one header line extended
  in place with the pointer "(the follow-up is `stab-depth-two-shared-stratum.lean`)"; nothing
  else.

## Decisions

- Per-state lemmas first, `_iff` theorems assembled by `rcases hs : (τ.state t).2 with _ | _ | _ | _`
  (the equation form generalizes the goal, so positive cases close by `rfl`).
- Three sink helpers `not_Fp_at_c`, `not_Pp_at_a`, `not_Pp_at_c` factor every vacuous cell.
- Refutation witnesses discharged by `rw [<shape>_iff, <history>_state_t]; decide`.
- `value_is_function_of_stratum_M2` keeps the pinned (unused) hypothesis `h` under a scoped
  `set_option linter.unusedVariables false in`, so the signature stays verbatim.
- The two optional past rows were added because Phase 2 finished well under budget, exactly as
  the plan conditions; they are unpinned and have no foot line.
- Header axiom record states that `Rg_fwd`/`Rg_bwd` use `[propext]` alone (a strict subset of
  the permitted profile), the other 27 all three.

## Plan Deviations

- None (implementation followed plan). Notes that are not deviations: the plan's Phase 3 count
  "19 pinned names" undercounts by one (there are 20; the 29 total is correct); the plan's
  Phase 4 "all 20 wired probe(s)" counts the `WIRED` array alone — the gate sums `WIRED` (20)
  and `WIRED_REPO` (3) and prints 23; the landed-probe pointer extends an existing line rather
  than adding a new one (numstat 1/1), since the plan asks for it to follow "is a follow-up".

## Verification

- Build: Success — full `lake build` through `lake-build-guard.sh` (detached): guard exit 0,
  "Build completed successfully (2836 jobs)", 0 `error:` lines; the `.olean` check is vacuous
  (no module in the build graph is touched; `git status --short FormalSystem/` is empty).
- Probe compile: `lake env lean` through the guard exit 0, no errors, no warnings; the 29 foot
  lines: 27 at `[propext, Classical.choice, Quot.sound]`, `Rg_fwd`/`Rg_bwd` at `[propext]`;
  no `sorryAx`.
- Collection gate: `bash scripts/check-evidence-probes.sh` exit 0; new probe PASS; landed
  `stab-depth-two-probe` PASS; `PASS  all 23 wired probe(s) compile`.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved roots and over the probe directory)
- Vacuous count: 0 in this task's files (the roots grep hits one pre-existing
  `:= trivial` at `FormalSystem/Examples/TemporalStructures.lean:495`, untouched, from an earlier
  task; it proves a definitionally true domain predicate)
- Axiom count: 14 `^axiom ` lines under the roots, unchanged (roots untouched); 0 in the probe
- Tests: N/A (evidence probe; the gate is its test)
- Files verified: Yes
- Comparator gate: not run (`compare_flag` not set; no Challenge manifest exists for this task)

## Impacts

- The evidence gate now holds in place that the time-axis summary route may assume NO
  one-bit-per-depth summary: the per-state label must carry the closure-indexed alphabet (one
  label per `⊡`-subformula, backward labels included even for forward targets), which is what
  `plusTruthAt_iff_atomize` / `stab_state_only` license and Probe 718 already records.
- The finite per-time alphabet survives in its closure-indexed form; nothing under
  `FormalSystem/` changes.

## Follow-ups

- None required. Possible later: "function of the full closure labelling" is not proved; a
  probe quantifying over the closure tuple rather than fixed shapes would be the next falsifier.

## References

- specs/739_e2_depth_two_stratification_shared_stratum_falsifier/plans/01_shared-stratum-falsifier.md
- specs/739_e2_depth_two_stratification_shared_stratum_falsifier/reports/01_shared-stratum-falsifier.md
- specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean (the landed E2 probe ii)
- specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean (this probe)
- scripts/check-evidence-probes.sh
