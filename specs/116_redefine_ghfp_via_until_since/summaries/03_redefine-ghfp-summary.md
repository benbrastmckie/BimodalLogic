# Implementation Summary: Task 116 - Redefine G/H/F/P via U/S (Partial)

## Status: PARTIAL

Build errors reduced from 114 to 49. Primary remaining file: Soundness.lean (38 errors).

## Phases Completed

### Phase 1: Fix Substitution.lean and Rename Docstrings [COMPLETED]
- Removed redundant `all_past`/`all_future` match arms from `Formula.subst` (they expand to `imp`/`snce`/`untl`)
- Fixed `subst_some_past`/`subst_some_future` proofs (changed from broken simp to `rfl`)
- Removed invalid `all_past`/`all_future` induction arms from 3 proofs (`subst_fresh_eq`, `subst_atoms`, `swap_temporal_subst`)
- Renamed "bridge lemma" to "semantic characterization theorem" in Truth.lean docstrings
- All sorry-free

### Phase 3: Fix Currently-Failing Files [PARTIAL]
- **TemporalContent.lean**: 2 sorry markers (F/G and P/H duality `rfl` broken)
- **TemporalCoherence.lean**: 2 sorry markers (same F/G duality issue)
- **Bridge.lean**: Fixed 3 errors (added `swap_temporal_all_future` to simp sets) - sorry-free
- **Table.lean**: 2 sorry markers (overlapping `@[match_pattern]` arms block `simp` reduction)
- **SoundnessLemmas.lean**: ~15 sorry markers (truth_at unfolding pattern)
- **LindenbaumQuotient.lean**: Fixed 2 errors (swap_temporal lemmas) - sorry-free
- **WitnessSeed.lean**: 8 sorry markers (F=neg(G(neg)) rfl broken)
- **Soundness.lean**: 2 sorry markers added, 38 errors remain

## Root Cause Analysis

All errors stem from a single design issue: after redefining G/H/F/P as abbreviations via `def` + `@[match_pattern]`:

1. **`truth_at` no longer unfolds G/H/F/P directly**: Since `truth_at` only has 6 arms (atom, bot, imp, box, untl, snce), evaluating `truth_at (all_future phi)` goes through the `imp` case, producing a nested form instead of the clean `forall s > t, ...` expected by proofs.

2. **F(phi) != neg(G(neg phi)) by `rfl`**: `some_future phi = untl phi top` while `neg(all_future(neg phi)) = neg(neg(some_future(neg(neg phi))))`. These are propositionally equivalent but structurally different.

3. **`@[match_pattern]` arm ordering**: For functions like `table` that have `all_future`/`all_past` arms before `imp`, Lean generates guards that prevent `simp` from reducing the `imp` case for generic arguments.

## Fix Pattern (for remaining errors)

All 49 remaining errors can be fixed by applying semantic characterization theorems:

```lean
-- Before truth_at intro for G/H/F/P:
rw [Truth.future_iff Omega]  -- for all_future
rw [Truth.past_iff Omega]    -- for all_past  
rw [Truth.some_future_iff Omega]  -- for some_future
rw [Truth.some_past_iff Omega]    -- for some_past

-- For the F=neg(G(neg)) duality:
-- Needs a helper lemma proving Formula.some_future psi = (Formula.all_future psi.neg).neg
-- via a Lean proof (not rfl, requires showing untl phi top = untl phi.neg.neg top in MCS context)
```

## Plan Deviations

- Phase 2 (derive temp_k_dist/temp_4): Deferred - independent of build errors, complex derivation
- Phase 3 errors in Soundness.lean: 38 errors not yet fixed (repetitive pattern, needs systematic application of Truth.future_iff rewrites)

## Metrics

| Metric | Before | After |
|--------|--------|-------|
| Build errors | 114 (5 files) | 49 (4 files) |
| Failing modules | 5 | 4 |
| Sorry count | ~300 | ~331 |
| Sorry added | - | ~31 |
| Sorry-free fixes | - | Substitution, Bridge, LindenbaumQuotient |

## Next Steps

1. Fix remaining 38 errors in Soundness.lean (apply Truth.future_iff/past_iff pattern)
2. Fix 3 downstream files (SuccRelation, BXCanonical.Frame, ParametricTruthLemma)
3. Add helper lemma: `some_future_eq_neg_all_future_neg : some_future phi = (all_future phi.neg).neg`
4. Continue with Phases 4-10
