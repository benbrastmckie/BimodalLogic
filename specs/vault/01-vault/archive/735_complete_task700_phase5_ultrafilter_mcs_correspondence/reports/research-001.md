# Research Report: Task #735

**Task**: Complete phase 5 of task 700: Ultrafilter-MCS Correspondence
**Date**: 2026-01-29
**Focus**: ultrafilterToSet_mcs consistency proof - show that if L ⊢ ⊥ and all [φᵢ] ∈ U, then ⊥ ∈ U

## Summary

This research analyzes the remaining sorry in `ultrafilterToSet_mcs` at `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean:162`. The proof requires showing that ultrafilterToSet produces a consistent set. The key challenge is relating list derivation (`L ⊢ ⊥`) to the Boolean algebra ordering (`fold ≤ ⊥`).

## Findings

### Current Proof State

The sorry is located in the consistency branch of `ultrafilterToSet_mcs` (line 162). The proof has already established:

1. **h_meet_in_U**: `List.foldl (fun acc φ => acc ⊓ toQuot φ) ⊤ L ∈ U.carrier` - the fold of quotients is in U
2. **d_bot**: `DerivationTree L Formula.bot` - the list L derives bottom

**What's missing**: Showing that the fold being ≤ ⊥ would imply ⊥ ∈ U (via upward closure), contradicting `U.bot_not_mem`.

### Key Mathematical Insight

The proof requires establishing that:
```
L ⊢ ⊥  ⟹  List.foldl (fun acc φ => acc ⊓ toQuot φ) ⊤ L ≤ ⊥
```

This is equivalent to showing:
```
L ⊢ ⊥  ⟹  [⨀L] ≤ [⊥]  in the Lindenbaum algebra
```

Where `⨀L` denotes the logical conjunction of all formulas in L.

### Proof Strategy

The proof can be completed using a **list conjunction lemma** that connects the two representations:

#### Step 1: Define List Conjunction-Derivation Relationship

The fold `List.foldl (fun acc φ => acc ⊓ toQuot φ) ⊤ L` computes `[φ₁] ⊓ [φ₂] ⊓ ... ⊓ [φₙ]` starting from ⊤.

In the Lindenbaum algebra, this equals `[φ₁ ∧ φ₂ ∧ ... ∧ φₙ]` (or `⊤` if L is empty).

#### Step 2: Apply Deduction Theorem Iteratively

From `L ⊢ ⊥`, we can apply the deduction theorem repeatedly:
- `[φ₁, ..., φₙ] ⊢ ⊥`
- By deduction theorem: `[φ₂, ..., φₙ] ⊢ φ₁ → ⊥`
- Continue: `[] ⊢ φ₁ → (φ₂ → ... (φₙ → ⊥)...)`

This is equivalent to `⊢ (⨀L) → ⊥`.

#### Step 3: Translate to Ordering

`⊢ (⨀L) → ⊥` means `Derives (⨀L) ⊥`, which by definition means `[⨀L] ≤ [⊥] = ⊥`.

#### Step 4: Use Upward Closure

Since:
- `[⨀L] ∈ U` (by h_meet_in_U, assuming the fold equals the conjunction quotient)
- `[⨀L] ≤ ⊥`
- U is upward closed (`mem_of_le`)

We would get `⊥ ∈ U`, contradicting `U.bot_not_mem`.

### Required Helper Lemmas

1. **fold_eq_listConj_quot**: Relate fold of quotients to quotient of conjunction
   ```lean
   theorem fold_eq_listConj_quot (L : List Formula) :
       List.foldl (fun acc φ => acc ⊓ toQuot φ) ⊤ L = toQuot (listConj L)
   ```
   Where `listConj` is the logical conjunction of a list (to be defined).

2. **derives_implies_le_bot**: From derivation to ordering
   ```lean
   theorem derives_implies_le_bot (L : List Formula) (h : DerivationTree L Formula.bot) :
       toQuot (listConj L) ≤ ⊥
   ```

3. **listConj_def**: Define list conjunction
   ```lean
   def listConj : List Formula → Formula
     | [] => Formula.bot.imp Formula.bot  -- Truth
     | [φ] => φ
     | φ :: L => φ.and (listConj L)
   ```

### Alternative Approach: Direct Proof Without List Conjunction

A simpler approach avoids defining `listConj` explicitly by proving directly:

```lean
theorem fold_le_bot_of_derives_bot (L : List Formula) (h : DerivationTree L Formula.bot) :
    List.foldl (fun acc φ => acc ⊓ toQuot φ) ⊤ L ≤ ⊥
```

**Proof by induction on L**:
- **Base case (L = [])**: fold is ⊤, and from `[] ⊢ ⊥` we get `⊤ ≤ ⊥`. But wait - `[] ⊢ ⊥` is impossible unless ⊥ is provable, which it isn't.

  Actually, if L = [], then h_L : `∀ φ ∈ L, φ ∈ ultrafilterToSet U` is vacuously true, and `Consistent []` is true (can't derive ⊥ from empty context). So we never get `[] ⊢ ⊥`.

- **Cons case (L = φ :: L')**:
  - From `DerivationTree (φ :: L') Formula.bot`
  - By deduction theorem: `DerivationTree L' (φ.neg)` (i.e., `L' ⊢ φ → ⊥`)
  - The fold becomes: `(⊤ ⊓ [φ]) ⊓ fold(L') = [φ] ⊓ fold(L')`
  - We need to show this is ≤ ⊥

  This reduces to showing that if `L' ⊢ φ → ⊥`, then `[φ] ⊓ fold(L') ≤ ⊥`.

### Existing Infrastructure

From the codebase:

1. **Deduction theorem** (`Bimodal.Metalogic.Core.deduction_theorem`):
   `(A :: Γ) ⊢ B → Γ ⊢ A → B`

2. **Derives definition** (`LindenbaumQuotient.lean:43`):
   `Derives φ ψ := Nonempty (DerivationTree [] (φ.imp ψ))`

3. **Order on LindenbaumAlg** (`BooleanStructure.lean:41`):
   `a ≤ b ↔ Derives φ ψ` (for representatives φ, ψ)

4. **Ultrafilter upward closure** (`UltrafilterMCS.lean:46`):
   `mem_of_le : ∀ {a b}, a ∈ carrier → a ≤ b → b ∈ carrier`

### Recommended Proof Approach

The cleanest approach is to prove a helper that directly connects list derivation to quotient ordering:

```lean
/-- If L derives ψ, then the meet of quotients of L is ≤ [ψ]. -/
theorem fold_le_of_derives (L : List Formula) (ψ : Formula)
    (h : DerivationTree L ψ) :
    List.foldl (fun acc φ => acc ⊓ toQuot φ) ⊤ L ≤ toQuot ψ := by
  -- Proof by induction on L, using deduction theorem
  sorry
```

Then instantiate with `ψ = Formula.bot` to complete the sorry.

### Mathlib Lemmas of Interest

- `inf_le_iff`: `b ⊓ c ≤ a ↔ b ≤ a ∨ c ≤ a`
- `le_inf`: `a ≤ b → a ≤ c → a ≤ b ⊓ c`
- `bot_inf_eq`: `⊥ ⊓ a = ⊥`
- `inf_bot_eq`: `a ⊓ ⊥ = ⊥`

### Dependencies

The proof depends on:
1. `Bimodal.Metalogic.Core.deduction_theorem` - Already available
2. `Bimodal.Metalogic.Algebraic.BooleanStructure` - Boolean algebra on LindenbaumAlg
3. `Bimodal.Metalogic.Algebraic.LindenbaumQuotient` - Quotient construction and Derives

## Recommendations

1. **Implement `fold_le_of_derives`**: A helper lemma showing that if `L ⊢ ψ`, then `fold(L) ≤ [ψ]`. This is the key missing piece.

2. **Proof strategy**: Use induction on L with the deduction theorem:
   - Empty case: trivial (fold = ⊤, any formula implies top)
   - Cons case: Apply deduction theorem, then use `inf_le` properties

3. **Estimated effort**: 1-2 hours for a skilled Lean developer familiar with the codebase.

4. **Complexity**: Medium - requires understanding the interplay between derivations, the deduction theorem, and the Boolean algebra structure.

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Fold direction issues | The fold goes left-to-right starting from ⊤. May need lemmas about fold commutativity in Boolean algebras. |
| Deduction theorem termination | Already handled via well-founded recursion on derivation height. |
| Quotient manipulation | Use Quotient.ind for induction on quotient elements. |

## References

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean:162` - The sorry location
- `Theories/Bimodal/Metalogic/Algebraic/BooleanStructure.lean` - Boolean algebra proofs
- `Theories/Bimodal/Boneyard/Metalogic_v2/Core/DeductionTheorem.lean` - Deduction theorem
- `specs/700_research_algebraic_representation_theorem_proof/summaries/implementation-summary-20260129.md` - Context

## Next Steps

1. Create implementation plan with the `fold_le_of_derives` helper lemma
2. Implement the helper using induction on L
3. Complete the sorry by applying the helper with `ψ = Formula.bot`
4. Verify with `lake build`
