# Fix Attempt: splitting_seed_consistent Since Condition Proof

## Summary of Changes

Applied the user's alternative strategy to restructure the proof in `splitting_seed_consistent` (PointInsertion.lean). The main changes:

1. **Restructured h_since_all placement**: Moved the Since condition proof inside the `h_neg_until` proof block, making the dependency structure clearer.

2. **Added detailed documentation**: Documented why the monotonicity approach (using `snce_left_mono_thm`) cannot work:
   - `snce_left_mono_thm` requires `⊢ β₁ → β₂` to transform `snce(β₁, γ)` to `snce(β₂, γ)`
   - To get from `snce(beta, alpha)` to `snce(beta ∧ β, alpha)`, we need `⊢ beta → (beta ∧ β)`
   - This implication is not provable (it's false in general)
   - The reverse implication `(beta ∧ β) → beta` (from `rce_imp`) gives the wrong direction

3. **Build passes**: The file compiles successfully with `lake build`.

## Remaining Sorry Sites

The following 4 sorry sites remain in `splitting_seed_consistent`:

1. **Line 1126**: Since condition proof (`h_since_all`)
   - Needs: `∀ (beta : Formula), beta ∈ B → ∀ (alpha : Formula), alpha ∈ A → snce (beta ∧ β) alpha ∈ C`
   - Challenge: Cannot use direct monotonicity from `snce(beta, alpha)` because implication direction is wrong
   - Potential approach: Use `g_content A ⊆ C` hypothesis with temporal reasoning

2. **Line 1178**: Propositional tautology (`h_event_implies_beta_neg`)
   - Needs: DerivationTree showing the event implies β.neg
   - This is a propositional tautology provable with standard derivation infrastructure

3. **Line 1199**: Seed consistency in consistent case
   - Needs: Show `{β.neg} ∪ g_content(A) ∪ h_content(C)` is consistent
   - Have: `F(β.neg) ∈ A` implies `{β.neg} ∪ g_content(A)` consistent, and `h_content(C)` consistent

4. **Line 1215**: Seed consistency in inconsistent case
   - Needs: Show seed is consistent when `β.neg ∈ B`
   - Have: `β.neg ∈ B` and `g_content(A) ⊆ C` gives seed ⊆ `B ∪ C`

## Mathematical Analysis

The core issue is establishing:
```
snce(beta ∧ β, alpha) ∈ C  from  snce(beta, alpha) ∈ C
```

The monotonicity lemma goes the wrong direction. The correct approach likely involves:
1. Using the deductive closure structure of `DC({β} ∪ B)`
2. Leveraging `g_content A ⊆ C` for temporal consistency
3. Applying the Since condition properties of `burgessR3` directly

## Verification

- Build: ✓ Passes (`lake build` succeeds)
- Remaining sorries: 4 in `splitting_seed_consistent`, 7 in other functions
- No new axioms introduced (no `axiom` declarations)
- No new `sorry` sites added beyond the 4 already identified
