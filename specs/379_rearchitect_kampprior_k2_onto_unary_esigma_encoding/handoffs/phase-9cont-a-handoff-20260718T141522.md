# Phase 9 continuation — sub-step 9(cont)-a handoff

## Immediate Next Action
Sub-step 9(cont)-b: prove the `belowCount`↔position slot-correspondence rank lemma in
`ConjInterleave.lean`, then discharge the `efSat` merged-formula interval clauses and
`MergePair.crossConsistent` (via `crossConsistent_of_holds`), and assemble `veeSat` via
`mergedFormula_mem_conjInterleave` to retire the `conjInterleave_forward` strategic sorry (line 446).

## Current State (this dispatch, all green + committed)
Phase 9 continuation sub-step 9(cont)-a COMPLETE (the adjudicated cross-consistency blocker from
reports/10 is fully resolved). Added to `ConjInterleave.lean`, all sorry-free:
- `MergePair.crossConsistent` (def) + `Decidable` instance — point-vs-interval filter (audit sec2)
- folded `crossConsistent` conjunct into the `conjInterleave` `Finset.univ.filter`
- `crossConsistent_of_holds` — forward-preservation lemma (audit sec3, the critical invariant)
- `mergedFormula_mem_conjInterleave` — membership assembly (List.mem_flatMap/mem_map bookkeeping)
- `orderEmbOfFin_symm_apply` — rank round-trip `w (eₖ i) = xₖ i`
- `strictMono_rank` — rank-map strict monotonicity
- `rank_orderEmbOfFin` — reverse rank identity (joint surjectivity)
- added import `Mathlib.Data.Finset.Sort`
- updated `conjInterleave_forward` docstring: crossConsistent obligation + landed helper inventory

Build: scoped `ConjInterleave` green; full `lake build` green (1770 jobs). Sorry count: 1 tracked
strategic (`conjInterleave_forward`, line 446) + the pre-existing on-path `KampPrior.lean:562`.
`#print axioms completeness_discrete` unchanged from baseline (orphan module, off live import path).

## Key Decisions
- Followed reports/10 sec2 verbatim for the `crossConsistent` shape (symmetric, interiority-guarded,
  membership `∈` not equality) — the adjudicated design, no re-litigation.
- `.symm.strictMono` (OrderIso) + `Subtype.ext rfl` gave the rank monotonicity/identity cheaply.
- `Finset.orderEmbOfFin`/`orderIsoOfFin` live in `Mathlib.Data.Finset.Sort` (not previously imported).
- No one-shot Mathlib rank lemma `w a < y ↔ a.val < #{j | w j < y}` exists (loogle-confirmed); the
  slot correspondence is a manual build — deferred to 9(cont)-b per the audit's explicit split sanction.

## Remaining (9(cont)-b then 9(cont)-c), per reports/10 sec5 steps 4-6
- 9(cont)-b: slot-correspondence rank lemma → retire `conjInterleave_forward`.
- 9(cont)-c: full `conjInterleave_iff` backward (project e₁/e₂; `intervalHolds_inter_left/right`+`mono`
  for merged open sub-intervals; `crossConsistent` membership + `nf_eval_unique` for interior points).
- then `veeConj`/`veeConj_iff` (Lemma 3.4-∧) in a NEW `VeeConj.lean` (create only at that point).

## Sorry Inventory
See `.orchestrator-handoff.json` `sorry_inventory` (2 entries: `conjInterleave_forward` strategic,
`KampPrior.lean:562` pre-existing on-path).
