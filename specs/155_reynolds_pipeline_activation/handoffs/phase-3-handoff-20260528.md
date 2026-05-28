# Phase 3 Handoff: CharacteristicFormula Existence Sorries Closed

## What Was Done
- Closed both existence sorries in CharacteristicFormula.lean:
  - `x_t_formula_exists` (line 221): proved via NF profile enumeration + rank_type_separator
  - `x_interval_formula_exists` (line 285): proved via disjunction of x_t_formulas over NF profiles
- Added import for StaviCompleteness.lean (provides stavi_table_mu_correct, stavi_fo_depth_le_twice_depth)
- Added helper infrastructure:
  - `nf_profile`: NF characteristic on extendedStructureWithMu at depth 2*r
  - `nf_profile_determines_stavi_truth`: same NF profile => same mu-truth for depth-<=r formulas
  - `nf_profile_determines_rank_type`: same NF profile => same rank_type
  - `rank_type_ne_of_nf_profile_ne`: different rank_type => different NF profile

## Key Decisions
- Used NF profiles at depth 2*r (not r) because stavi_fo_depth can be up to 2*stavi_depth
- Used doets_lemma_1_1 + stavi_table_mu_correct chain for the bridge (same pattern as nf_determines_stavi_truth_depth in Claim1.lean)
- Avoided defining x_t_sep as a noncomputable def (caused split/dif issues with Classical.propDecidable); instead used by_cases inside the proof

## Verification
- `#print axioms` on all 4 key definitions: no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.CharacteristicFormula` passes
- `grep -n sorry CharacteristicFormula.lean`: only in comments

## Next Action
Phase 4: Tactic Infrastructure (order_reverse, same_order_type_grid_uh in EFGameTactics.lean)
OR Phase 5/6 (Case II rewrite, Cases III/IV) which depend on Phase 3 being done.
