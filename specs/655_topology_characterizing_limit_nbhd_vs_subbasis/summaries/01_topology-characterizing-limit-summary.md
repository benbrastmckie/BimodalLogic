# Implementation Summary: Task #655

- **Task**: 655 - Topology characterizing Limit: cone-neighbourhood topology 𝒩_F vs subbasis topology 𝒯_F
- **Status**: [BLOCKED]
- **Started**: 2026-09-22T17:07:02Z
- **Completed**: 2026-09-22T17:26:00Z
- **Effort**: ~20 minutes wall clock (5 phase commits)
- **Dependencies**: None
- **Artifacts**: plans/01_topology-characterizing-limit.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Hardened the research round's probe deliverable under the task directory only (no edits to
`FormalSystem/`, `Tests/`, or the manuscript): all six probes now compile with `lake env lean`,
every headline theorem carries a self-checking `#print axioms` line, and four of the plan's five
UNVERIFIED targets are discharged by new sorry-free declarations. Phases 1, 2, 4 and 5 are
`[COMPLETED]`; Phase 3 is `[BLOCKED]` because its pinned intermediate statement
`RTO_triangle : Triangle' RTO` is false (compiled refutation recorded in the plan), and Phase 6
(report reconciliation) depends on Phase 3 and was not opened.

## What Changed

- `specs/655_…/probes/NbhdTopology.lean` — fixed a syntax error present at `9ec16ee08` (`omit … in` placed after a docstring, so the research-round file did not compile); added `discreteTopology_nbhdTopology_iff` (𝒩_F discrete iff every state has a dwell time, report item 3.5); 14 `#print axioms` lines.
- `specs/655_…/probes/FourState.lean` — new section "Histories over the funnel": `IsHistory'`, `R4_history_low_past`, `R4_history_high_future`, `R4_history_shift_fixed`, `R4_history_invariant_of_le` (helper: the shift-invariance set of a funnel history is convex), **`R4_sep`** (`ShiftSet.sep` holds on the funnel's histories although Limit fails, over any nontrivial ordered group — no density, no Archimedean property; report item 1.6), **`not_continuous_coneTopology_R4_history`** (a funnel history over ℝ that is not 𝒯_F-continuous); 9 `#print axioms` lines.
- `specs/655_…/probes/Hedgehog.lean` — **new file**: the hedgehog frame `HH`/`RHH` over ℝ with `RHH_serial`, `RHH_compositional`, `RHH_limit`, `t1Space_nbhdTopology_RHH`; `hedgehogOpen` with `not_isOpen_nbhdTopology_hedgehogOpen`, three history lemmas (`RHH_history_single_ray`, `RHH_history_centre_past`, `RHH_history_reach`), `isOpen_preimage_hedgehogOpen_of_history`, **`finalTopology_ne_nbhdTopology_RHH`** (𝒩_F is strictly below the final topology of all histories, report item 2.3), and **`not_continuous_coneTopology_RHH_history`** (in-class 𝒯_F-discontinuity via `c_mem_cone_p`, `singleton_c_eq_inter_cone`, `isOpen_coneTopology_singleton_c`); 8 `#print axioms` lines.
- `specs/655_…/probes/{IntPartition,RealFrames,TwoOrigins}.lean` — `#print axioms` lines only (4, 7, 5 theorems).
- `specs/655_…/plans/01_topology-characterizing-limit.md` — phase markers, inline completion/deviation annotations, and the Phase 3 BLOCKER entry with the refutation and the repair route.
- `specs/655_…/handoffs/phase-{1,2,3,4,5}-handoff-*.md` — per-phase recovery points.

## Decisions

- Followed `plan-compliance.md`'s Statement Fidelity rule for the false `RTO_triangle`: marked Phase 3 `[BLOCKED]` with a compiled refutation (`o true ⇒₁ p ⟨1⟩ ⇒₋₁ o false` has no shortcut since `RTO (o true) t (o false)` is `true = false`) rather than proving a same-named weaker statement or rerouting the two true headline theorems on my own authority. The BLOCKER entry spells out the direct cone-openness route (explicit radii per cone) so the revision is mechanical.
- Kept the refutation out of `TwoOrigins.lean` (an unplanned declaration in a `.lean` file); it is reproduced verbatim in the plan's BLOCKER entry.
- Did not open Phase 6 (depends on Phase 3); the report therefore still carries its research-round UNVERIFIED labels for items 1.6, 2.3, 3.5 and the table cells, even though the probes now discharge them — the reconciliation is one bounded prose phase once Phase 3 lands.
- Proved `R4_sep` by convexity of the shift-invariance set rather than the plan sketch's closing case split, which only closes under an extra `2·y₂ ≤ y₁` bound; the pinned statement is unchanged.

## Plan Deviations

- **Phase 1, item 3** altered: `NbhdTopology.lean` did not compile as committed (syntax error at 341:73); moved `omit [Nontrivial D] in` above the docstring of `limit_of_t1Space_coneTopology`.
- **Phase 2, item 4** altered: `R4_sep`'s proof route (convexity helper `R4_history_invariant_of_le` + a third application of the hypothesis at radius `|d|`) replaces the sketch's final case split; statement verbatim.
- **Phase 3, items 2-5** blocked: `RTO_triangle : Triangle' RTO` is false; `coneTopology_eq_nbhdTopology_RTO` and `not_t2Space_coneTopology_RTO` (both true) not attempted pending plan revision. Item 1 (`discreteTopology_nbhdTopology_iff`) completed.
- **Phase 6** not opened (dependency on Phase 3 unmet).

## Verification

- Build: Success — full guarded `lake build` (`lake-build-guard.sh build --timeout 1800 -- build`, detached): `Build completed successfully (2704 jobs)`, guard exit 0, zero `error:` lines; `TaskFrame.olean` newer than its source (the only library module the probes import).
- Probes: `lake env lean` exit 0 with no errors or warnings on all six (`NbhdTopology`, `FourState`, `IntPartition`, `RealFrames`, `TwoOrigins`, `Hedgehog`).
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots; the probes' only `sorry` hit is the docstring word at `NbhdTopology.lean:18`; no `native_decide`, no `admit`).
- Vacuous count: 0 for this task's files. (The repo-wide grep hits `FormalSystem/Examples/TemporalStructures.lean:483`, a pre-existing, untouched theorem whose statement is genuinely trivial.)
- Axiom count: 14 `^axiom` lines in the source roots before (`d9cfc7f61`) and after — no increase. Every one of the 47 audited probe theorems depends on exactly `[propext, Classical.choice, Quot.sound]`.
- Plan compliance: failed — 10 of 13 Goals identifiers present; missing `RTO_triangle`, `coneTopology_eq_nbhdTopology_RTO`, `not_t2Space_coneTopology_RTO` (the blocked phase).
- Tests: N/A (no library or test change).
- Files verified: Yes.
- Territory: `FormalSystem/`, `Tests/` untouched by this task. Observed three untracked files under `FormalSystem/Metalogic/Conservativity/` (`MinusCanonicalFrame.lean`, `MinusMCS.lean`, `MinusTemporalDerived.lean`) — inside sibling task 651's declared `file_scope`, in flight; not touched, reported here.

## Impacts

- Report items 1.6 (`R4_sep`), 2.3 (`finalTopology_ne_nbhdTopology_RHH`), 3.5 (`discreteTopology_nbhdTopology_iff`) and the "history continuity, 𝒯_F over ℚ/ℝ" cell (`not_continuous_coneTopology_R4_history`, `not_continuous_coneTopology_RHH_history`) now have machine-checked evidence; the report text still says UNVERIFIED for them until Phase 6 runs.
- The refactor task's counterexample-module list (report section 5 item 4) gains the hedgehog frame, the `sep` witness, and the two 𝒯_F-discontinuity witnesses, all lift-ready (bare relations, explicit hypotheses, standard axioms).
- The "𝒯_F over ℝ is not Hausdorff" cell remains UNVERIFIED until the revised Phase 3 lands.

## Follow-ups

- Revise the plan per the Phase 3 BLOCKER (drop `RTO_triangle`/`Triangle'` from the phase and from the Lean Challenge Statements block; route `coneTopology_eq_nbhdTopology_RTO` through cone-openness with the recorded radii), then dispatch Phase 3 and Phase 6.
- Phase 6 should also append the verification log above to the report's Appendix and add `probes/Hedgehog.lean` to its Artifacts block.

## References

- Plan: `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/plans/01_topology-characterizing-limit.md`
- Report: `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/reports/01_topology-characterizing-limit.md`
- Probes: `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/{NbhdTopology,FourState,IntPartition,RealFrames,TwoOrigins,Hedgehog}.lean`
- Handoffs: `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/handoffs/`
- Commits: `14f5b8c6a` (phase 1), `1978725b2` (phase 2), `a5facc8f6` (phase 3, blocked), `3ce6476e0` (phase 4), `14ca2db2a` (phase 5)
