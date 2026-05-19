# Phase 6 Handoff - Task 116

## Status

Phases 1-5 completed. Phase 6 partial. Build has 5 failing files with ~114 errors.

## What Was Done

1. **Phase 1**: Prototyped `@[match_pattern]` -- WORKS for pattern matching but NOT for induction. Added canonical `Formula.top`. Consolidated 4 local top definitions.

2. **Phase 2**: DEFERRED. `temp_k_dist`/`temp_4` remain as axiom constructors. They reference the new def-based `all_future`/`all_past` transparently.

3. **Phase 3**: Core redefinition done. Formula.lean has 6 constructors (atom, bot, imp, box, untl, snce). `all_future`, `all_past`, `some_future`, `some_past` are `@[match_pattern] def` abbreviations. BEq, swap_temporal, atoms all updated.

4. **Phase 4**: Subformulas.lean, Context.lean, Substitution.lean updated. Removed all_past/all_future induction arms.

5. **Phase 5**: Truth.lean updated with bridge lemmas (past_iff, future_iff, some_future_iff, some_past_iff, top_true, neg_iff). SubformulaClosure.lean updated with sorry for deferralClosure proofs (Formula.noConfusion broken).

6. **Partial Phase 6+**: Fixed GeneralizedNecessitation, Perpetuity/Helpers, Validity, SignedFormula, MCSProperties, TemporalDerived, SuccessPatterns, Quasimodel/SubformulaClosure. Pattern: move @[match_pattern] arms before .imp, add swap_temporal lemmas to simp.

## Remaining Failing Files

1. **SoundnessLemmas.lean** (~100 errors): Every proof that unfolds `truth_at` through `all_past`/`all_future` is broken because `truth_at` no longer has those constructor arms. Fix: use `Truth.past_iff`/`Truth.future_iff` bridge lemmas to convert.

2. **Table.lean** (2 errors): `table_correctness` induction proof has all_past/all_future arms that are no longer valid constructors. Fix: remove arms, add cases within imp for the match_pattern forms.

3. **Bridge.lean** (3 errors): `swap_temporal` simp failures. Fix: add temporal swap lemmas.

4. **TemporalCoherence.lean**: Likely `truth_at` unfolding issue.

5. **TemporalContent.lean**: Likely `truth_at` unfolding issue.

## Key Pattern for Remaining Fixes

The dominant error pattern is: proofs that do `simp only [..., truth_at]` and then `intro h s h_lt` to destructure `∀ s, s < t → ...` now fail because `truth_at (all_past φ)` no longer reduces to `∀ s, s < t → truth_at s φ`. Instead it reduces to an `imp`/`snce` expansion.

**Fix template**:
```lean
-- OLD: simp only [truth_at]; intro h s hst; ...
-- NEW: rw [Truth.past_iff]; intro h s hst; ...
```

Or more mechanically:
```lean
-- For all_past:
have h := (Truth.past_iff Omega φ).mp h_all_past
-- For all_future:
have h := (Truth.future_iff Omega φ).mp h_all_future
-- For some_future:
have h := (Truth.some_future_iff Omega φ).mp h_some_future
-- For some_past:
have h := (Truth.some_past_iff Omega φ).mp h_some_past
```

## Immediate Next Action

Fix SoundnessLemmas.lean by replacing `simp only [..., truth_at]` calls with bridge lemma rewrites. This is mechanical but voluminous (~100 errors across a 2452-line file).

## Key Decisions Made

1. Used `@[match_pattern]` (works for pattern matching, not induction)
2. Deferred Phase 2 (temp_k_dist/temp_4 derivation) -- axiom constructors remain
3. Added Truth.lean bridge lemmas (past_iff, future_iff, etc.) as the primary API for downstream code
4. Used sorry for SubformulaClosure deferralClosure proofs where Formula.noConfusion is broken
5. Moved @[match_pattern] arms before .imp in all function definitions to preserve semantics
