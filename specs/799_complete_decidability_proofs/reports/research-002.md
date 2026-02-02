# Research Report: Task #799 - Follow-up Diagnosis

**Task**: Complete Decidability Proofs - Phase 1 Blockage Analysis
**Date**: 2026-02-02
**Focus**: Diagnose blockage in `closed_extend_closed` and `add_neg_causes_closure` proofs

## Summary

The blockage in Phase 1 is **provable with the right strategy**. The key insight is that the proof requires building up from simpler monotonicity lemmas, then using Mathlib's `List.any_of_mem` theorem to bridge the gap. The proofs are not fundamentally difficult, but require careful decomposition. I recommend continuing with implementation rather than converting to axioms.

## Detailed Problem Analysis

### The Core Challenge

The `checkContradiction` function uses `findSome?` with a predicate that depends on the list itself:

```lean
def checkContradiction (b : Branch) : Option ClosureReason :=
  b.findSome? fun sf =>
    if sf.isPos ∧ b.hasNeg sf.formula then
      some (.contradiction sf.formula)
    else none
```

When proving `closed_extend_closed`, we need to show that if `checkContradiction b = some reason`, then `checkContradiction (sf :: b) = some _`. The challenge is:
1. The predicate in `findSome?` references `b.hasNeg sf.formula`
2. For the extended branch `(x :: b)`, the predicate becomes `(x :: b).hasNeg sf.formula`
3. These are different predicates - standard `findSome?` lemmas don't directly apply

### Why Standard Approaches Don't Work

1. **Direct `findSome?_cons` application**: This lemma handles adding to the *list being searched*, not changes to the *predicate*.

2. **Abstract monotonicity for `findSome?`**: No existing Mathlib lemma handles the case where predicates change monotonically.

## Key Findings from Mathlib Search

### Useful Lemmas Found

| Lemma | Type | Relevance |
|-------|------|-----------|
| `List.any_of_mem` | `a ∈ l → p a → any l p` | Core building block for monotonicity |
| `List.subset_cons` | `l ⊆ (a :: l)` | Shows original list is subset of extended |
| `List.subset_cons_of_subset` | `l₁ ⊆ l₂ → l₁ ⊆ (a :: l₂)` | Composition lemma |

### Missing but Constructible Lemmas

The following lemmas do **not** exist in Mathlib but can be proved from first principles:

1. **`hasNeg_mono`**: `hasNeg b φ → hasNeg (x :: b) φ`
   - Proof: Unfold `hasNeg`, use `any_of_mem` with membership in `x :: b`
   - Estimated effort: ~5 lines

2. **`hasPos_mono`**: `hasPos b φ → hasPos (x :: b) φ`
   - Proof: Similar to `hasNeg_mono`
   - Estimated effort: ~5 lines

3. **`hasBotPos_mono`**: `hasBotPos b → hasBotPos (x :: b)`
   - Proof: Direct unfolding + `any_of_mem`
   - Estimated effort: ~5 lines

4. **`checkContradiction_mono`**: `(checkContradiction b).isSome → (checkContradiction (x :: b)).isSome`
   - Proof strategy below
   - Estimated effort: ~20 lines

## Recommended Proof Strategy

### For `checkContradiction_mono`

The key insight is to work with the *witness* of the contradiction rather than reasoning about `findSome?` directly:

```lean
theorem checkContradiction_mono (b : Branch) (x : SignedFormula) :
    (checkContradiction b).isSome → (checkContradiction (x :: b)).isSome := by
  intro h
  -- Extract the formula that caused the contradiction
  simp only [checkContradiction, List.findSome?_isSome_iff] at h ⊢
  obtain ⟨sf, hsf_mem, hsf_cond⟩ := h
  -- sf was in b and satisfied the contradiction condition
  -- Show it's still in (x :: b) and still satisfies the condition
  refine ⟨sf, List.mem_cons_of_mem x hsf_mem, ?_⟩
  -- The condition: sf.isPos ∧ (x :: b).hasNeg sf.formula
  simp only [Bool.and_eq_true] at hsf_cond ⊢
  obtain ⟨hpos, hneg⟩ := hsf_cond
  exact ⟨hpos, hasNeg_mono b x sf.formula hneg⟩
```

**Critical**: This approach requires `List.findSome?_isSome_iff` which states:
```lean
(l.findSome? f).isSome ↔ ∃ a ∈ l, (f a).isSome
```

### For `closed_extend_closed`

With `checkContradiction_mono` proved, the main theorem follows by case analysis:

```lean
theorem closed_extend_closed (b : Branch) (sf : SignedFormula) :
    isClosed b → isClosed (sf :: b) := by
  intro h
  simp only [isClosed, findClosure] at h ⊢
  -- Case analysis on which closure reason was found
  cases hbot : checkBotPos b with
  | some => simp [checkBotPos_mono b sf hbot]
  | none =>
    cases hcontra : checkContradiction b with
    | some =>
      have := checkContradiction_mono b sf (by simp [hcontra])
      simp [Option.isSome_iff_exists] at this ⊢
      exact Or.inr (Or.inl this)
    | none =>
      cases hax : checkAxiomNeg b with
      | some => simp [checkAxiomNeg_mono b sf hax]
      | none => simp [hbot, hcontra, hax] at h
```

### For `add_neg_causes_closure`

This is actually simpler - we can construct the witness directly:

```lean
theorem add_neg_causes_closure (b : Branch) (φ : Formula) :
    b.hasPos φ → isClosed (SignedFormula.neg φ :: b) := by
  intro hpos
  simp only [isClosed, findClosure, checkBotPos, checkContradiction]
  -- Either checkBotPos succeeds or we find the contradiction
  cases hbot : (SignedFormula.neg φ :: b).hasBotPos with
  | true => simp [hbot]
  | false =>
    -- The contradiction: T(φ) is in b (given), F(φ) is at head
    simp only [Bool.false_eq_true, ↓reduceIte]
    -- findSome? will find the witness in b
    simp only [List.findSome?_cons]
    -- ... unfold to show the positive formula in b creates the contradiction
    sorry -- Detailed unfolding
```

## Alternative Approaches Considered

### 1. Restructure Definitions (Not Recommended)

One could redefine `checkContradiction` to return the witnessing formula more explicitly, making proofs trivial. However:
- This would require changing the API
- Downstream code would need updates
- The current definitions are semantically clean

### 2. Use Axioms (Not Recommended)

Converting these to axioms would be premature technical debt:
- The proofs are tractable with proper helper lemmas
- These are fundamental properties that should be proved
- Axioms here would undermine trust in the decidability module

### 3. Use `decide` Tactic (Partial Solution)

For specific small cases, `decide` might work, but:
- Won't scale to the polymorphic statements needed
- Doesn't provide insight into proof structure

## Recommendations

### Primary Recommendation: Continue Implementation

1. **Add helper lemmas** (15-20 min):
   ```lean
   theorem hasNeg_mono (b : Branch) (x : SignedFormula) (φ : Formula) :
       hasNeg b φ → hasNeg (x :: b) φ

   theorem hasPos_mono (b : Branch) (x : SignedFormula) (φ : Formula) :
       hasPos b φ → hasPos (x :: b) φ

   theorem hasBotPos_mono (b : Branch) (x : SignedFormula) :
       hasBotPos b → hasBotPos (x :: b)
   ```

2. **Verify `List.findSome?_isSome_iff` exists** in the project or add it:
   ```lean
   theorem findSome?_isSome_iff {f : α → Option β} {l : List α} :
       (l.findSome? f).isSome ↔ ∃ a ∈ l, (f a).isSome
   ```

3. **Prove `checkContradiction_mono`** using the strategy above

4. **Prove `checkAxiomNeg_mono`** (similar structure, handles axiom negation case)

5. **Complete `closed_extend_closed`** by case analysis

6. **Complete `add_neg_causes_closure`** by direct construction

### Estimated Time to Complete Phase 1

- Helper lemmas: 30 minutes
- `checkContradiction_mono`: 45 minutes
- `checkAxiomNeg_mono`: 30 minutes
- `closed_extend_closed`: 30 minutes
- `add_neg_causes_closure`: 20 minutes
- **Total**: ~2.5 hours

## Verification Checklist

Before implementing, verify these lemmas exist in the project or Mathlib:
- [ ] `List.any_of_mem` (found in Mathlib.Data.Bool.AllAny)
- [ ] `List.mem_cons_of_mem` (in standard library)
- [ ] `List.findSome?_isSome_iff` or equivalent

## References

- Mathlib: `Mathlib.Data.Bool.AllAny` - `any_of_mem` lemma
- Mathlib: `Mathlib.Data.List.Basic` - List subset and membership lemmas
- Lean Core: `Init.Data.List.Basic` - `findSome?_cons` definition

## Next Steps

1. Resume implementation with the helper lemma approach
2. If `findSome?_isSome_iff` is not available, prove it first (standard induction on list)
3. Build up from `hasNeg_mono` to `checkContradiction_mono` to `closed_extend_closed`
4. Proceed to Phase 2 (Saturation.lean) after Phase 1 completes
