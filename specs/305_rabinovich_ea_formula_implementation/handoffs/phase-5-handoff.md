# Phase 5 Handoff — Task 305

## Immediate Next Action

Begin Phase 6: Rewire `existPart_succ_n1_bypass` (k>0 case) in KampBypass.lean to use EA negation closure instead of PriorComposition.

## Current State

- **Phase 4**: COMPLETED — `EANegationClosure.lean` with `neg_interval_formula` and `neg_bounded_exists` (sorry-free)
- **Phase 5**: COMPLETED — `neg_vecEA2` and `neg_2var_vec_ea` (Prop 4.2, sorry-free)
- **Build**: Clean (`lake build Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure` passes)
- **Sorry count in EANegationClosure.lean**: 0

## Key Decisions Made

1. Used `HasAttainedINF` as the hypothesis (not raw `semantic_prior_UZ`) for most theorems
2. Named `TemporalPred.eval_at_neg'` (with prime) to avoid conflict with any future name in VecEAClosure
3. For `neg_bounded_exists` n=0 base case: handled via `by_cases h_nonempty` on the interval (rather than `prior_UZ_successor`)
4. All theorems are model-dependent/forward-only (avoid biconditional)

## Phase 6 Requirements

The k>0 case in `existPart_succ_n1_bypass` (KampBypass.lean:480-840) currently uses:
- `prior_2var_transfer_until` (line 646) — has sorry inside
- `prior_2var_transfer_since` (line 713) — has sorry inside

To eliminate these, need an alternative proof path:
1. Map `nf_eval_nf M (k'+2) 2 (Fin.cons x (fun _ => t)) sub_nf` to VecEA2/VVecEA2
2. Use `neg_2var_vec_ea` for the negation closure step
3. Use `VVecEA2.translateLeft` to produce the formula

Key challenge: the mapping from 2-var NF to VecEA2 is non-trivial. Need to understand how CharPart/NfCharFormula relates point types and segment types to NormalForm atoms.

## Sorry Inventory

| File | Line | Statement | Status |
|------|------|-----------|--------|
| PriorComposition.lean | 459,462,554,559,610,614 | prior_nonconstenv_2var_agree_until/since | Live on critical path |
| EANegation.lean | 1047 | neg_bracket_is_vbracket (backward, beta_0(r0) case) | Non-critical (bypassed) |
| EANegation.lean | 1172 | neg_partialBracketExist_is_vbracket (backward n+1) | Non-critical (bypassed) |
| NfCharFormula.lean | 542 | Dead code | Non-critical |

## References

- Plan: `specs/305_rabinovich_ea_formula_implementation/plans/06_vecEA2-negation-plan.md`
- New file: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean`
