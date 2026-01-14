# Research Report: DeductionTheorem.lean Build Errors - Classical Reasoning Patterns

**Project**: #183  
**Date**: 2025-12-25  
**Research Type**: Comprehensive Error Analysis and Solution Design  
**File**: `Logos/Core/Metalogic/DeductionTheorem.lean`

## Research Question

How to fix three build errors in DeductionTheorem.lean related to classical reasoning and decidability in Lean 4, specifically the "unknown tactic" errors when using `(em P).elim` patterns inside match expressions?

## Sources Consulted

### Codebase Analysis
- **DeductionTheorem.lean**: Lines 39 (`open Classical`), 130, 215, 256, 343, 369
- **Formula.lean**: Line 75 (`DecidableEq` derivation)
- **Soundness.lean**: Line 282 (`by_cases` pattern)
- **Truth.lean**: Lines 789-825 (nested `by_cases` pattern)

### Mathlib4 Patterns
- **CategoryTheory/Limits/Shapes/Biproducts.lean**: `rcases Classical.em` pattern
- **Algebra/Polynomial/Div.lean**: `(Classical.em ...).elim` in term mode
- **MeasureTheory/Measure/MeasureSpace.lean**: `rcases Classical.em` with existential
- **RingTheory/MvPolynomial/WeightedHomogeneous.lean**: `rcases Classical.em` with equality

### Build Errors
- Direct compilation output from `lake build Logos.Core.Metalogic.DeductionTheorem`
- Error messages at lines 256, 297, 369

## Error Analysis

### Error 1: Line 256 - "unknown tactic" in `deduction_with_mem`

**Location**: Line 256, inside weakening case of `deduction_with_mem`

**Code Context**:
```lean
| DerivationTree.weakening Γ'' _ ψ h1 h2 =>
    -- Check if A ∈ Γ''
    (em (A ∈ Γ'')).elim
      (fun hA' =>
        -- A ∈ Γ'', recurse on h1
        have ih : (removeAll Γ'' A) ⊢ A.imp ψ :=
          deduction_with_mem Γ'' A ψ h1 hA'
        -- ... rest of proof
```

**Error Messages**:
```
error: ././././Logos/Core/Metalogic/DeductionTheorem.lean:256:8: unknown tactic
error: ././././Logos/Core/Metalogic/DeductionTheorem.lean:253:43: unsolved goals
Γ'[DAGGER] : Context
A φ : Formula
h : Γ'[DAGGER] ⊢ φ
Γ' : Context
ψ : Formula
Γ'' : Context
h1 : Γ'' ⊢ ψ
h2 : Γ'' ⊆ Γ'
hA : A ∈ Γ'
⊢ Logos.Core.Metalogic.removeAll Γ' A ⊢ A.imp ψ
```

**Root Cause**:
The `.elim` method is being used directly on `(em (A ∈ Γ''))` inside a `match` expression. Lean 4's tactic mode doesn't recognize `.elim` as a tactic when used this way. The pattern `(em P).elim (fun h => ...) (fun h => ...)` is a **term-mode** construct, not a tactic.

**Why This Fails**:
- Inside `match` expressions in tactic mode, Lean expects tactics or term-mode expressions
- `.elim` on `em` creates a term, but the surrounding context expects a proof/tactic
- The `open Classical` at the top of the file makes `em` available, but doesn't change how `.elim` works in this context
- Lean cannot infer that this is meant to be a case split in tactic mode

### Error 2: Line 297 - "no goals" in termination proof

**Location**: Line 297, inside `decreasing_by` clause for `deduction_with_mem`

**Code Context**:
```lean
termination_by h.height
decreasing_by
  simp_wf
  · -- Goal 1: h1.height < h.height (modus_ponens left)
    exact DerivationTree.mp_height_gt_left h1 h2
  · -- Goal 2: h2.height < h.height (modus_ponens right)
    exact DerivationTree.mp_height_gt_right h1 h2
  · -- Goal 3: h1.height < h.height (weakening with A ∈ Γ'')
    exact DerivationTree.subderiv_height_lt h1 h2
```

**Error Message**:
```
error: ././././Logos/Core/Metalogic/DeductionTheorem.lean:253:43: unsolved goals
```

**Root Cause**:
The termination proof structure doesn't match the actual recursive calls because the `(em (A ∈ Γ'')).elim` pattern fails to compile. Once the `.elim` pattern is fixed, the termination proof should work correctly.

**Why This Fails**:
- The error at line 253 (the weakening case) indicates that the termination checker can't verify termination
- This is a **cascading error** from Error 1 - the `.elim` pattern fails first
- The `decreasing_by` clause has 3 bullet points which is correct:
  - 2 for modus ponens case (left and right subderivations)
  - 1 for weakening case (only when A ∈ Γ'')
- Once the tactic error is fixed, this should resolve automatically

### Error 3: Line 369 - "unknown tactic" in `deduction_theorem`

**Location**: Line 369, inside weakening case of `deduction_theorem`

**Code Context**:
```lean
| DerivationTree.weakening Γ' _ φ h1 h2 =>
    -- Subcase 1: Check if Γ' = A :: Γ
    (em (Γ' = A :: Γ)).elim
      (fun h_eq =>
        deduction_theorem Γ A φ (h_eq ▸ h1))
      (fun h_eq =>
        -- Subcase 2: Check if A ∈ Γ'
        (em (A ∈ Γ')).elim
          (fun hA =>
            -- ... recursive call
```

**Error Messages**:
```
error: ././././Logos/Core/Metalogic/DeductionTheorem.lean:369:8: unknown tactic
error: ././././Logos/Core/Metalogic/DeductionTheorem.lean:362:42: unsolved goals
Γ : Context
A B : Formula
h : A :: Γ ⊢ B
φ : Formula
Γ' : Context
h1 : Γ' ⊢ φ
h2 : Γ' ⊆ A :: Γ
⊢ Γ ⊢ A.imp φ
```

**Root Cause**:
Same issue as Error 1: nested `.elim` patterns inside `match` expressions. The code has:
1. Outer `.elim` for `(em (Γ' = A :: Γ))`
2. Inner `.elim` for `(em (A ∈ Γ'))` inside the second branch

Both fail because `.elim` is not recognized as a tactic in this context.

## Key Findings

### 1. Classical Reasoning Patterns in Lean 4

#### Pattern 1: `by_cases` Tactic (Recommended for Tactic Mode)

**Working Pattern from Soundness.lean** (line 282):
```lean
by_cases h : truth_at M τ t ht φ
· -- Case 1: φ is true
  exact h
· -- Case 2: φ is false
  -- ... proof
```

**Working Pattern from Truth.lean** (line 789):
```lean
by_cases h_ut : u < t
· -- Case: u < t
  apply Classical.byContradiction
  intro h_neg
  -- ... proof
· -- Case: u ≥ t
  by_cases h_eq : u = t
  · -- Case: u = t
    -- ... proof
  · -- Case: u > t
    -- ... proof
```

**Key Insight**: Use `by_cases h : P` tactic, NOT `(em P).elim` in match expressions.

#### Pattern 2: `rcases Classical.em` (Alternative for Tactic Mode)

**Working Pattern from mathlib4 CategoryTheory/Limits/Shapes/Biproducts.lean**:
```lean
rcases Classical.em (i = j) with (rfl | h)
· -- Case: i = j (using rfl pattern)
  rw [if_neg (Classical.not_not.2 rfl), comp_zero, comp_zero, KernelFork.condition]
· -- Case: i ≠ j
  rw [if_pos (Ne.symm h), Category.comp_id]
```

**Working Pattern from mathlib4 MeasureTheory/Measure/MeasureSpace.lean**:
```lean
rcases Classical.em (∃ i, μ (t i) = ∞) with (⟨i, hi⟩ | htop)
· -- Case: exists i with μ (t i) = ∞
  -- ... proof
· -- Case: all finite
  -- ... proof
```

**Key Insight**: `rcases Classical.em P with (h1 | h2)` is another valid pattern that works in tactic mode.

#### Pattern 3: `.elim` in Term Mode (NOT for Match Expressions)

**Working Pattern from mathlib4 Algebra/Polynomial/Div.lean**:
```lean
(Classical.em (q = 0)).elim 
  (fun hq ↦ (show p = q by simpa [hq] using h₁) ▸ Associated.refl p)
  (fun hq ↦ ...)
```

**Key Insight**: `.elim` works in **term mode** (when constructing a term), but NOT in **tactic mode** inside match expressions.

### 2. Decidability vs Classical Reasoning

**Formula has DecidableEq** (Formula.lean line 75):
```lean
inductive Formula : Type where
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | all_past : Formula → Formula
  | all_future : Formula → Formula
  deriving Repr, DecidableEq, BEq, Hashable
```

**But List.mem is not automatically decidable in all contexts**:
- `DecidableEq Formula` provides decidable equality for formulas
- `List.mem` requires `DecidableEq` for the element type
- However, `by_cases h : A ∈ Γ` works **classically** without explicit decidability

**Why by_cases works**:
- With `open Classical` at the top of the file, `by_cases` uses `Classical.propDecidable`
- This provides decidability for any proposition classically (via excluded middle)
- No need to provide explicit `Decidable (A ∈ Γ)` instance

**When to use each approach**:
- **Decidable instances**: When you want computational/executable code
- **Classical reasoning**: When you only need proofs (non-computational)
- **by_cases with open Classical**: Best for proof-only contexts like DeductionTheorem

### 3. Match Expressions vs Tactic Mode

**The Problem**:
```lean
match h with
| DerivationTree.weakening Γ' _ φ h1 h2 =>
    (em (A ∈ Γ')).elim  -- [FAIL] FAILS: .elim is not a tactic
      (fun hA => ...)
      (fun hA => ...)
```

**The Solution**:
```lean
match h with
| DerivationTree.weakening Γ' _ φ h1 h2 =>
    by_cases hA : A ∈ Γ'  -- [PASS] WORKS: by_cases is a tactic
    · -- Case: A ∈ Γ'
      ...
    · -- Case: A ∉ Γ'
      ...
```

**Why This Works**:
- `by_cases` is a **tactic** that splits the goal into two cases
- It works inside `match` expressions in tactic mode
- With `open Classical`, it uses excluded middle automatically
- The `·` bullet points clearly delimit the two cases

### 4. Nested Case Analysis

**Pattern from Truth.lean** (nested by_cases):
```lean
by_cases h_ut : u < t
· -- Case: u < t
  apply Classical.byContradiction
  intro h_neg
  -- ... proof
· -- Case: u ≥ t
  by_cases h_eq : u = t
  · -- Case: u = t
    -- ... proof
  · -- Case: u > t
    -- ... proof
```

**Application to deduction_theorem**:
```lean
by_cases h_eq : Γ' = A :: Γ
· -- Case: Γ' = A :: Γ
  deduction_theorem Γ A φ (h_eq ▸ h1)
· -- Case: Γ' ≠ A :: Γ
  by_cases hA : A ∈ Γ'
  · -- Case: A ∈ Γ'
    have ih : removeAll Γ' A ⊢ A.imp φ :=
      deduction_with_mem Γ' A φ h1 hA
    -- ... rest
  · -- Case: A ∉ Γ'
    -- ... rest
```

**Key Insight**: Nested `by_cases` is idiomatic and works perfectly in Lean 4.

### 5. Termination Proof Structure

**Current Structure** (3 bullets):
```lean
decreasing_by
  simp_wf
  · exact DerivationTree.mp_height_gt_left h1 h2
  · exact DerivationTree.mp_height_gt_right h1 h2
  · exact DerivationTree.subderiv_height_lt h1 h2
```

**Expected Structure** (depends on recursive calls):
- Modus ponens case: 2 recursive calls → 2 goals
- Weakening case with `by_cases`: 1 recursive call (only in first branch) → 1 goal
- **Total**: 3 goals [YES]

**The Issue**:
- The termination proof structure is correct in principle
- But the `.elim` pattern fails to compile, causing cascading errors
- Once we switch to `by_cases`, the termination proof should work as-is

## Solution Approaches

### Approach 1: Use `by_cases` Tactic (RECOMMENDED)

**Pros**:
- [PASS] Idiomatic Lean 4 pattern
- [PASS] Proven in Soundness.lean and Truth.lean
- [PASS] Minimal changes to existing code structure
- [PASS] Clear and readable
- [PASS] Works with existing termination proofs

**Cons**:
- None significant

**Implementation**:
Replace `(em P).elim (fun h => ...) (fun h => ...)` with `by_cases h : P` and use `·` bullet points.

### Approach 2: Use `rcases Classical.em` Pattern

**Pros**:
- [PASS] More explicit about using classical logic
- [PASS] Proven in mathlib4
- [PASS] Allows pattern matching (e.g., `rfl` for equality)

**Cons**:
- [WARN] Slightly more verbose than `by_cases`
- [WARN] Less familiar to readers not familiar with `rcases`

**Implementation**:
Replace `(em P).elim` with `rcases Classical.em P with (h | h)`.

### Approach 3: Use `have` bindings with term-mode `.elim`

**Pros**:
- [PASS] More explicit about using classical logic
- [PASS] Separates case analysis from match expression

**Cons**:
- [FAIL] More verbose
- [FAIL] Less idiomatic in Lean 4
- [FAIL] Harder to read

**Implementation**:
```lean
| DerivationTree.weakening Γ'' _ ψ h1 h2 =>
    have h_em := Classical.em (A ∈ Γ'')
    match h_em with
    | Or.inl hA' => ...
    | Or.inr hA' => ...
```

## Code Examples

### Example 1: Fix `deduction_with_mem` weakening case (Line 253-286)

**Before**:
```lean
| DerivationTree.weakening Γ'' _ ψ h1 h2 =>
    -- Check if A ∈ Γ''
    (em (A ∈ Γ'')).elim
      (fun hA' =>
        -- A ∈ Γ'', recurse on h1
        have ih : (removeAll Γ'' A) ⊢ A.imp ψ :=
          deduction_with_mem Γ'' A ψ h1 hA'
        -- Weaken to removeAll Γ' A
        have h_sub : removeAll Γ'' A ⊆ removeAll Γ' A := by
          intro x hx
          unfold removeAll at hx ⊢
          simp [List.filter] at hx ⊢
          exact ⟨h2 hx.1, hx.2⟩
        DerivationTree.weakening (removeAll Γ'' A) (removeAll Γ' A) (A.imp ψ) ih h_sub)
      (fun hA' =>
        -- A ∉ Γ'', so Γ'' ⊆ removeAll Γ' A
        have h_sub : Γ'' ⊆ removeAll Γ' A := by
          intro x hx
          unfold removeAll
          simp [List.filter]
          exact ⟨h2 hx, by
            intro h_eq
            subst h_eq
            exact absurd hx hA'⟩
        -- Γ'' ⊢ ψ and Γ'' ⊆ removeAll Γ' A
        have h_weak : (removeAll Γ' A) ⊢ ψ :=
          DerivationTree.weakening Γ'' (removeAll Γ' A) ψ h1 h_sub
        -- Use S axiom
        have s_ax : ⊢ ψ.imp (A.imp ψ) :=
          DerivationTree.axiom [] _ (Axiom.prop_s ψ A)
        have s_weak : (removeAll Γ' A) ⊢ ψ.imp (A.imp ψ) :=
          DerivationTree.weakening [] (removeAll Γ' A) _ s_ax (List.nil_subset _)
        DerivationTree.modus_ponens (removeAll Γ' A) ψ (A.imp ψ) s_weak h_weak)
```

**After (using by_cases)**:
```lean
| DerivationTree.weakening Γ'' _ ψ h1 h2 =>
    -- Classical case analysis: either A ∈ Γ'' or A ∉ Γ''
    by_cases hA' : A ∈ Γ''
    · -- Case: A ∈ Γ'', recurse on h1
      have ih : (removeAll Γ'' A) ⊢ A.imp ψ :=
        deduction_with_mem Γ'' A ψ h1 hA'
      -- Weaken to removeAll Γ' A
      have h_sub : removeAll Γ'' A ⊆ removeAll Γ' A := by
        intro x hx
        unfold removeAll at hx ⊢
        simp [List.filter] at hx ⊢
        exact ⟨h2 hx.1, hx.2⟩
      DerivationTree.weakening (removeAll Γ'' A) (removeAll Γ' A) (A.imp ψ) ih h_sub
    · -- Case: A ∉ Γ'', so Γ'' ⊆ removeAll Γ' A
      have h_sub : Γ'' ⊆ removeAll Γ' A := by
        intro x hx
        unfold removeAll
        simp [List.filter]
        exact ⟨h2 hx, by
          intro h_eq
          subst h_eq
          exact absurd hx hA'⟩
      -- Γ'' ⊢ ψ and Γ'' ⊆ removeAll Γ' A
      have h_weak : (removeAll Γ' A) ⊢ ψ :=
        DerivationTree.weakening Γ'' (removeAll Γ' A) ψ h1 h_sub
      -- Use S axiom
      have s_ax : ⊢ ψ.imp (A.imp ψ) :=
        DerivationTree.axiom [] _ (Axiom.prop_s ψ A)
      have s_weak : (removeAll Γ' A) ⊢ ψ.imp (A.imp ψ) :=
        DerivationTree.weakening [] (removeAll Γ' A) _ s_ax (List.nil_subset _)
      DerivationTree.modus_ponens (removeAll Γ' A) ψ (A.imp ψ) s_weak h_weak
```

**Key Changes**:
- Replace `(em (A ∈ Γ'')).elim (fun hA' => ...) (fun hA' => ...)` with `by_cases hA' : A ∈ Γ''`
- Use `·` bullet points for the two cases
- Remove closing parentheses (no longer needed)
- Add comment explaining classical reasoning

### Example 2: Fix `deduction_theorem` weakening case (Line 362-434)

**Before**:
```lean
| DerivationTree.weakening Γ' _ φ h1 h2 =>
    -- Subcase 1: Check if Γ' = A :: Γ
    (em (Γ' = A :: Γ)).elim
      (fun h_eq =>
        deduction_theorem Γ A φ (h_eq ▸ h1))
      (fun h_eq =>
        -- Γ' ≠ A :: Γ, so Γ' is a proper subset of A :: Γ
        -- Subcase 2: Check if A ∈ Γ'
        (em (A ∈ Γ')).elim
          (fun hA =>
            -- A ∈ Γ' but Γ' ≠ A :: Γ
            have ih : removeAll Γ' A ⊢ A.imp φ :=
              deduction_with_mem Γ' A φ h1 hA
            -- Weaken to Γ
            have h_sub : removeAll Γ' A ⊆ Γ :=
              removeAll_subset hA h2
            DerivationTree.weakening (removeAll Γ' A) Γ (A.imp φ) ih h_sub)
          (fun hA =>
            -- A ∉ Γ', so φ is derivable from Γ' without using A
            -- ... rest
```

**After (using by_cases)**:
```lean
| DerivationTree.weakening Γ' _ φ h1 h2 =>
    -- Classical case analysis: check if Γ' = A :: Γ
    by_cases h_eq : Γ' = A :: Γ
    · -- Case: Γ' = A :: Γ, recurse directly
      deduction_theorem Γ A φ (h_eq ▸ h1)
    · -- Case: Γ' ≠ A :: Γ, so Γ' is a proper subset of A :: Γ
      -- Nested case analysis: check if A ∈ Γ'
      by_cases hA : A ∈ Γ'
      · -- Case: A ∈ Γ' but Γ' ≠ A :: Γ
        have ih : removeAll Γ' A ⊢ A.imp φ :=
          deduction_with_mem Γ' A φ h1 hA
        -- Weaken to Γ
        have h_sub : removeAll Γ' A ⊆ Γ :=
          removeAll_subset hA h2
        DerivationTree.weakening (removeAll Γ' A) Γ (A.imp φ) ih h_sub
      · -- Case: A ∉ Γ', so φ is derivable from Γ' without using A
        have h_sub : Γ' ⊆ Γ := by
          intro x hx
          have := h2 hx
          simp at this
          cases this with
          | inl h_eq_x =>
            -- x = A, but A ∉ Γ', contradiction
            subst h_eq_x
            exact absurd hx hA
          | inr h_mem => exact h_mem
        -- Now Γ' ⊢ φ and Γ' ⊆ Γ, so Γ ⊢ φ
        have h_weak : Γ ⊢ φ := DerivationTree.weakening Γ' Γ φ h1 h_sub
        -- Use S axiom to get Γ ⊢ A → φ
        have s_ax : ⊢ φ.imp (A.imp φ) :=
          DerivationTree.axiom [] _ (Axiom.prop_s φ A)
        have s_weak : Γ ⊢ φ.imp (A.imp φ) :=
          DerivationTree.weakening [] Γ _ s_ax (List.nil_subset Γ)
        DerivationTree.modus_ponens Γ φ (A.imp φ) s_weak h_weak
```

**Key Changes**:
- Replace outer `(em (Γ' = A :: Γ)).elim` with `by_cases h_eq : Γ' = A :: Γ`
- Replace inner `(em (A ∈ Γ')).elim` with `by_cases hA : A ∈ Γ'`
- Use nested `·` bullet points for the cases
- Remove all closing parentheses from `.elim` patterns
- Add comments explaining the case analysis

### Example 3: Termination Proofs (No Changes Needed)

The termination proofs should work as-is once the `.elim` patterns are replaced with `by_cases`:

**For `deduction_with_mem`**:
```lean
termination_by h.height
decreasing_by
  simp_wf
  · -- Goal 1: h1.height < h.height (modus_ponens left)
    exact DerivationTree.mp_height_gt_left h1 h2
  · -- Goal 2: h2.height < h.height (modus_ponens right)
    exact DerivationTree.mp_height_gt_right h1 h2
  · -- Goal 3: h1.height < h.height (weakening with A ∈ Γ'')
    exact DerivationTree.subderiv_height_lt h1 h2
```

**For `deduction_theorem`**:
```lean
termination_by h.height
decreasing_by
  simp_wf
  · exact DerivationTree.mp_height_gt_left _ _
  · exact DerivationTree.mp_height_gt_right _ _
  · have : (h_eq ▸ h1).height = h1.height := by
      subst h_eq
      rfl
    simp [this, DerivationTree.height]
```

**Verification**:
- Modus ponens case: 2 recursive calls → 2 goals [YES]
- Weakening case (deduction_with_mem): 1 recursive call (only when A ∈ Γ'') → 1 goal [YES]
- Weakening case (deduction_theorem): 1 recursive call (only when Γ' = A :: Γ) → 1 goal [YES]
- **Total**: 3 goals for each function [YES]

## Termination Proof Guidance

### Understanding the Termination Structure

The termination proofs use well-founded recursion on `h.height` (the height of the derivation tree). Each recursive call must be on a derivation with strictly smaller height.

**For `deduction_with_mem`**:
- **Modus ponens case**: Two recursive calls on `h1` and `h2` (subderivations)
  - Both have height strictly less than `h.height`
  - Proven by `DerivationTree.mp_height_gt_left` and `DerivationTree.mp_height_gt_right`
- **Weakening case**: One recursive call on `h1` (only in the `A ∈ Γ''` branch)
  - Has height strictly less than `h.height`
  - Proven by `DerivationTree.subderiv_height_lt`

**For `deduction_theorem`**:
- **Modus ponens case**: Two recursive calls (same as above)
- **Weakening case**: One recursive call (only in the `Γ' = A :: Γ` branch)
  - The cast `h_eq ▸ h1` preserves height
  - Need to prove `(h_eq ▸ h1).height < h.height`
  - This reduces to `h1.height < h.height` which is true

### Common Issues

1. **Number of goals doesn't match**: If `simp_wf` creates a different number of goals than expected, check:
   - Are all recursive calls accounted for?
   - Are there recursive calls in both branches of a case split?
   - Did the case split syntax change the goal structure?

2. **Cast height preservation**: When using `h_eq ▸ h1`, need to prove the cast doesn't change height:
   ```lean
   have : (h_eq ▸ h1).height = h1.height := by
     subst h_eq
     rfl
   ```

3. **Implicit arguments**: Use `_` for implicit arguments in termination proofs when Lean can infer them.

## Recommended Solution

### Primary Recommendation: Use `by_cases` tactic

**Rationale**:
1. **Idiomatic**: `by_cases` is the standard Lean 4 pattern for case analysis in tactic mode
2. **Proven**: Used extensively in Soundness.lean and Truth.lean in the same codebase
3. **Simple**: Minimal changes to existing code structure
4. **Maintainable**: Clear and readable for future developers
5. **Compatible**: Works with existing termination proofs without modification

**Implementation Steps**:
1. Replace `(em P).elim (fun h => ...) (fun h => ...)` with `by_cases h : P`
2. Use `·` bullet points for the two cases
3. Remove closing parentheses from `.elim` patterns
4. Add brief comments explaining classical reasoning
5. Verify termination proofs still work (they should)

### Secondary Recommendation: Add documentation

Add comments explaining the classical reasoning pattern:

```lean
-- Classical case analysis: either A ∈ Γ'' or A ∉ Γ''
-- This uses excluded middle (Classical.em) via by_cases
by_cases hA' : A ∈ Γ''
```

This helps readers understand that we're using classical logic, which is important for a metalogic proof.

### Testing Strategy

1. **Build Test**: Run `lake build Logos.Core.Metalogic.DeductionTheorem`
2. **Verify No Errors**: All 3 errors should be resolved
3. **Run Existing Tests**: Ensure no regressions in metalogic tests
4. **Spot Check**: Manually verify the deduction theorem still works correctly

## Implementation Checklist

- [ ] Replace `.elim` pattern in `deduction_with_mem` (line 256)
- [ ] Replace outer `.elim` pattern in `deduction_theorem` (line 369)
- [ ] Replace inner `.elim` pattern in `deduction_theorem` (line 376)
- [ ] Add comments explaining classical reasoning
- [ ] Verify termination proofs compile
- [ ] Run `lake build Logos.Core.Metalogic.DeductionTheorem`
- [ ] Run metalogic tests
- [ ] Update SORRY_REGISTRY.md if needed
- [ ] Document classical reasoning patterns in LEAN_STYLE_GUIDE.md (optional)

## Further Research Needed

None. The solution is clear and well-supported by:
- Existing patterns in the Logos codebase (Soundness.lean, Truth.lean)
- Proven patterns in mathlib4
- Understanding of Lean 4's tactic mode vs term mode distinction

## References

### Logos Codebase
- **DeductionTheorem.lean**: Lines 39 (`open Classical`), 130, 215, 256, 343, 369
- **Soundness.lean**: Line 282 (`by_cases` pattern)
- **Truth.lean**: Lines 789-825 (nested `by_cases` pattern)
- **Formula.lean**: Line 75 (`DecidableEq` derivation)

### Mathlib4
- **CategoryTheory/Limits/Shapes/Biproducts.lean**: `rcases Classical.em` pattern
- **Algebra/Polynomial/Div.lean**: `(Classical.em ...).elim` in term mode
- **MeasureTheory/Measure/MeasureSpace.lean**: `rcases Classical.em` with existential
- **RingTheory/MvPolynomial/WeightedHomogeneous.lean**: `rcases Classical.em` with equality

### Lean 4 Documentation
- Classical module: Excluded middle and classical reasoning
- `by_cases` tactic: Case analysis on propositions
- Termination proofs: Well-founded recursion with `termination_by` and `decreasing_by`
