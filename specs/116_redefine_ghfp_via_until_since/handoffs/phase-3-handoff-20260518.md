# Phase 3 Handoff - Task 116

## Immediate Next Action

Fix the 38 remaining errors in `Theories/Bimodal/Metalogic/Soundness.lean`. All errors follow the same pattern: `simp only [truth_at]` no longer unfolds `all_future`/`all_past`/`some_future`/`some_past` because these are now `def` abbreviations, not constructors.

## Fix Pattern

For each broken theorem in Soundness.lean:

1. After `intro F M Omega h_sc tau h_mem t`, add rewrites for temporal operators in the goal:
   ```lean
   show truth_at M Omega tau t <formula> → truth_at M Omega tau t <result>
   rw [Truth.future_iff Omega]  -- for all_future in hypothesis or goal
   rw [Truth.past_iff Omega]    -- for all_past
   rw [Truth.some_future_iff Omega]  -- for some_future
   rw [Truth.some_past_iff Omega]    -- for some_past
   ```

2. For nested temporal operators (e.g., `G(G(phi))`), apply rewrites multiple times.

3. For complex formulas with `Formula.and`/`Formula.or`/`Formula.neg` wrapping temporal operators, unfold those first, then apply temporal rewrites.

## Key Decisions

- Phase 2 (derive temp_k_dist/temp_4) deferred - not blocking build fixes
- Used `sorry` for F/G duality `rfl` issues - needs helper lemma
- Bridge.lean and LindenbaumQuotient.lean fixed sorry-free by adding `swap_temporal_all_future`/`swap_temporal_all_past` to simp sets

## Current State

- Build: 49 errors in 4 files (Soundness: 38, SuccRelation: ~5, BXCanonical.Frame: ~3, ParametricTruthLemma: ~3)
- All errors are the same `truth_at` unfolding pattern
- Phases 1 and 3 (partial) complete, Phases 2, 4-10 not started

## Files Modified

- `Theories/Bimodal/ProofSystem/Substitution.lean` - Fixed (Phase 1)
- `Theories/Bimodal/Semantics/Truth.lean` - Docstring rename (Phase 1)
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Partial fix with sorry
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - 2 sorry
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - 2 sorry
- `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` - Fixed (sorry-free)
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` - 2 sorry
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` - 8 sorry
- `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean` - Fixed (sorry-free)
- `Theories/Bimodal/Metalogic/Soundness.lean` - 2 sorry, 38 errors remain
