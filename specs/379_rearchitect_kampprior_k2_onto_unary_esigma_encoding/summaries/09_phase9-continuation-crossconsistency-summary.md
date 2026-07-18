# Phase 9 continuation (9(cont)-a) — cross-consistency filter + forward infrastructure

- **Task**: 379 — rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Phase**: 9 (α restated), sub-step 9(cont)-a
- **Session**: sess_1784408397_6a5f80
- **Status**: PARTIAL (9(cont)-a complete green; 9(cont)-b/c deferred per reports/10 sanction)
- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ConjInterleave.lean` (orphan, off live import path)

## What was accomplished (all sorry-free, committed per green sub-step)

The dispatch resolved the adjudicated backward-direction blocker from
`reports/10_conjinterleave-cross-consistency-audit.md` (the point-vs-interval cross-consistency gap
that left the previous Phase 9 dispatch PARTIAL) and pre-built the reusable rank infrastructure for
both proof directions:

1. `MergePair.crossConsistent` (def) + `Decidable` instance — the point-vs-interval filter
   (audit §2): symmetric, interiority-guarded, `Finset` membership (not equality).
2. Folded the `crossConsistent` conjunct into the `conjInterleave` enumerator filter.
3. `crossConsistent_of_holds` — forward-preservation lemma (audit §3, the critical invariant):
   genuine witnesses auto-satisfy cross-consistency because `nf_eval_unique` collapses the realized
   interval completion at an interior point to that point's complete type.
4. `mergedFormula_mem_conjInterleave` — membership assembly (`List.mem_flatMap` / `Finset.mem_toList`
   / `List.mem_map`) in one reusable step.
5. `orderEmbOfFin_symm_apply` — rank round-trip `w (eₖ i) = xₖ i`.
6. `strictMono_rank` — rank-map strict monotonicity.
7. `rank_orderEmbOfFin` — reverse rank identity (joint surjectivity).
8. Added import `Mathlib.Data.Finset.Sort`; updated the `conjInterleave_forward` docstring to record
   the new `crossConsistent` obligation and the landed helper inventory.

## Verification

- Scoped build `Bimodal.Metalogic.WeakCanonical.Kamp.ConjInterleave`: green.
- Full `lake build`: green (1770 jobs).
- `#print axioms completeness_discrete`: `[propext, sorryAx, Classical.choice, Lean.ofReduceBool,
  Lean.trustCompiler, Quot.sound]` — identical to baseline (orphan module; `sorryAx` is the
  pre-existing on-path `KampPrior.lean:562`, not from `conjInterleave_forward`).
- New sorries: 0. New axioms: 0. Vacuous defs: 0.

## Remaining sorries (tracked)

- `conjInterleave_forward` (`ConjInterleave.lean:446`) — tracked strategic; retired in 9(cont)-b.
- `KampPrior.lean:562` (`nf_nvar_exist_all_depths`) — pre-existing on-path; owned by Phase 13.

## Continuation target (per reports/10 §5 steps 4-6)

- **9(cont)-b**: prove the `belowCount`↔position slot-correspondence rank lemma
  (`w a < y ↔ a.val < #{j | w j < y}` for the sorted enumeration; no one-shot Mathlib lemma exists —
  loogle-confirmed), then discharge the `efSat` merged-formula interval clauses and `crossConsistent`
  (via `crossConsistent_of_holds`) and assemble via `mergedFormula_mem_conjInterleave` to retire
  `conjInterleave_forward`.
- **9(cont)-c**: full `conjInterleave_iff` backward — project `e₁`/`e₂`; merged open sub-intervals via
  `intervalHolds_inter_left`/`_right` + `intervalHolds_mono`; merged interior points via
  `crossConsistent` membership + `nf_eval_unique`.
- then `veeConj` / `veeConj_iff` (Lemma 3.4-∧) in a new `VeeConj.lean` (create only at that point).

## Plan deviations

None beyond the plan-sanctioned split: reports/10 and plan Phase 9 both explicitly permit keeping the
forward rank-realization bookkeeping (9(cont)-b) and the backward direction (9(cont)-c) as their own
dispatches. The design-finding checklist item is annotated RESOLVED in the plan file.
