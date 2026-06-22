# Phase 1 Handoff: Depth-1 Gap Analysis (Plan v12)

## Immediate Next Action

Choose resolution approach: (a) write nf_eval_boost_prior helper lemma, (b) restructure outer strong induction to all-arity, or (c) add variable projection lemma. Then re-dispatch Phase 1 implementation.

## Current State

- Phase 1 BLOCKED after exhaustive analysis of 6 approaches
- No code changes made to PriorComposition.lean (sorry sites unchanged)
- Plan v12 Phase 1 heading updated to [BLOCKED] with detailed blocker documentation
- Sorry count: 5 (unchanged from prior dispatch)

## Key Decisions

1. **Confirmed depth-1 gap is fundamental**: Every compositional approach (cross_extend, ih_strong transfer, nvar_transfer, reconstruction, exist_transfer, NF eval boost) fails at the same one-depth offset between available agreement and needed agreement.

2. **Identified three resolution paths**:
   - **(a) nf_eval_boost_prior**: New helper lemma doing depth induction (Nat.rec on d, r universally quantified) with Prior-UZ/SZ for d=0 base case. Most targeted fix, ~100-150 lines. Requires threading h_t/h_x through all recursive levels.
   - **(b) All-arity restructure**: Change `prior_nonconstenv_2var_agree_until/since` to prove `∀ r` agreement simultaneously. ih_strong then provides h_rvar for nvar_transfer. Cleaner but modifies existing sorry-free architecture.
   - **(c) Variable projection**: Add lemma extracting m-var agreement from n-var (m <= n, subset of variables). Enables extracting 2-var at zone boundary pairs from higher-arity agreements at each recursive level.

3. **EF game translation is constructive**: The duplicator strategy works: at each round (depth d), find witness via exist_transfer (getting d-1 agreement), then verify by IH at d-1. Chain: depth-K 3-var -> depth-(K-1) 4-var -> ... -> depth-0 (K+3)-var. At depth 0: purely atomic. The proof terminates after K+1 steps.

## Sorry Inventory

| File | Line | Statement | Status |
|------|------|-----------|--------|
| PriorComposition.lean | 524 | prior_exist_transfer_one_dir | Pre-existing sorry, architecturally wrong signature |
| PriorComposition.lean | 595 | forward Until existential | BLOCKED: depth-1 gap |
| PriorComposition.lean | 599 | backward Until existential | BLOCKED: same |
| PriorComposition.lean | 650 | forward Since existential | BLOCKED: same |
| PriorComposition.lean | 654 | backward Since existential | BLOCKED: same |

## References

- Plan v12: `specs/305_rabinovich_ea_formula_implementation/plans/12_zone-decomposition-plan.md`
- Prior research reports 06-07 (zone-3 analysis)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (lines 540-600)
- Key lemmas: `exist_transfer_from_full_agree`, `nvar_transfer_from_1var_agree`, `reconstruction_depth_agree`, `HasAttainedINF.first_occ`
