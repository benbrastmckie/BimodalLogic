# Research Report: DeductionTheorem.lean Build Errors

**Project**: #183  
**Date**: 2025-12-25  
**Research Type**: Error Analysis and Solution Design  
**File**: `Logos/Core/Metalogic/DeductionTheorem.lean`

## Research Question

How to fix three build errors in DeductionTheorem.lean related to classical reasoning and decidability in Lean 4?

## Sources Consulted

- **Codebase Analysis**: DeductionTheorem.lean, Formula.lean, Context.lean, Soundness.lean, Truth.lean
- **Lean 4 Patterns**: Existing classical reasoning patterns in Logos codebase
- **Build Errors**: Direct compilation output from `lake build`

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

**Error Message**:
```
error: ././././Logos/Core/Metalogic/DeductionTheorem.lean:256:8: unknown tactic
error: ././././Logos/Core/Metalogic/DeductionTheorem.lean:253:43: unsolved goals
```

**Root Cause**:
The `.elim` method is being used directly on `(em (A ∈ Γ''))` inside a `match` expression. Lean 4's tactic mode doesn't recognize `.elim` as a tactic when used this way. The pattern `(em P).elim (fun h => ...) (fun h => ...)` is a **term-mode** construct, not a tactic.

**Why This Fails**:
- Inside `match` expressions in tactic mode, Lean expects tactics or term-mode expressions
- `.elim` on `em` creates a term, but the surrounding context expects a proof/tactic
- The `open Classical` at the top of the file makes `em` available, but doesn't change how `.elim` works in this context

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
The termination proof structure doesn't match the actual recursive calls. The error at line 253 (the weakening case) suggests that the termination checker can't verify termination because:

1. The `(em (A ∈ Γ'')).elim` pattern creates **two branches** (A ∈ Γ'' and A ∉ Γ'')
2. Only the **first branch** (A ∈ Γ'') has a recursive call to `deduction_with_mem`
3. The `decreasing_by` clause has 3 bullet points, but the actual structure may differ

**Why This Fails**:
- `simp_wf` simplifies well-founded recursion goals, but the number of goals depends on the actual recursive call structure
- The `.elim` pattern may create goals differently than expected
- The termination proof needs to match the exact structure of recursive calls

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

**Error Message**:
```
error: ././././Logos/Core/Metalogic/DeductionTheorem.lean:369:8: unknown tactic
error: ././././Logos/Core/Metalogic/DeductionTheorem.lean:362:42: unsolved goals
```

**Root Cause**:
Same issue as Error 1: nested `.elim` patterns inside `match` expressions. The code has:
1. Outer `.elim` for `(em (Γ' = A :: Γ))`
2. Inner `.elim` for `(em (A ∈ Γ'))` inside the second branch

Both fail because `.elim` is not recognized as a tactic in this context.

## Key Findings

### 1. Classical Reasoning Patterns in Lean 4

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

**But List.mem is not automatically decidable**:
- `DecidableEq Formula` provides decidable equality for formulas
- `List.mem` requires `DecidableEq` for the element type
- However, `by_cases h : A ∈ Γ` works **classically** without explicit decidability

**Why by_cases works**:
- With `open Classical` at the top of the file, `by_cases` uses `Classical.propDecidable`
- This provides decidability for any proposition classically (via excluded middle)
- No need to provide explicit `Decidable (A ∈ Γ)` instance

### 3. Match Expressions vs Tactic Mode

**The Problem**:
```lean
match h with
| DerivationTree.weakening Γ' _ φ h1 h2 =>
    (em (A ∈ Γ')).elim  -- ❌ FAILS: .elim is not a tactic
      (fun hA => ...)
      (fun hA => ...)
```

**The Solution**:
```lean
match h with
| DerivationTree.weakening Γ' _ φ h1 h2 =>
    by_cases hA : A ∈ Γ'  -- ✅ WORKS: by_cases is a tactic
    · -- Case: A ∈ Γ'
      ...
    · -- Case: A ∉ Γ'
      ...
```

**Why This Works**:
- `by_cases` is a **tactic** that splits the goal into two cases
- It works inside `match` expressions in tactic mode
- With `open Classical`, it uses excluded middle automatically

### 4. Termination Proof Structure

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
- **Total**: 3 goals ✓

**The Issue**:
- The termination proof structure is correct in principle
- But the `.elim` pattern may create goals differently than `by_cases`
- Once we switch to `by_cases`, the termination proof should work

### 5. Nested Case Analysis

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

## Recommended Solution

### Solution Overview

Replace all `(em P).elim` patterns with `by_cases h : P` tactic in both functions.

### Detailed Changes

#### Change 1: Fix `deduction_with_mem` weakening case (Line 253-286)

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

**After**:
```lean
| DerivationTree.weakening Γ'' _ ψ h1 h2 =>
    -- Check if A ∈ Γ''
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

#### Change 2: Fix `deduction_theorem` weakening case (Line 362-434)

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
            -- ... rest of proof
```

**After**:
```lean
| DerivationTree.weakening Γ' _ φ h1 h2 =>
    -- Subcase 1: Check if Γ' = A :: Γ
    by_cases h_eq : Γ' = A :: Γ
    · -- Case: Γ' = A :: Γ
      deduction_theorem Γ A φ (h_eq ▸ h1)
    · -- Case: Γ' ≠ A :: Γ, so Γ' is a proper subset of A :: Γ
      -- Subcase 2: Check if A ∈ Γ'
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

#### Change 3: Verify termination proof (Lines 288-301, 436-452)

The termination proofs should work as-is once the `.elim` patterns are replaced with `by_cases`. The structure is:

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
- Modus ponens case: 2 recursive calls → 2 goals ✓
- Weakening case (deduction_with_mem): 1 recursive call (only when A ∈ Γ'') → 1 goal ✓
- Weakening case (deduction_theorem): 1 recursive call (only when Γ' = A :: Γ) → 1 goal ✓
- **Total**: 3 goals for each function ✓

## Alternative Approaches

### Alternative 1: Use `have` bindings before match

Instead of `by_cases` inside match, use `have` to bind the excluded middle result:

```lean
| DerivationTree.weakening Γ'' _ ψ h1 h2 =>
    have h_em := Classical.em (A ∈ Γ'')
    match h_em with
    | Or.inl hA' =>
      -- A ∈ Γ''
      ...
    | Or.inr hA' =>
      -- A ∉ Γ''
      ...
```

**Pros**: More explicit about using classical logic
**Cons**: More verbose, less idiomatic in Lean 4

### Alternative 2: Use `dite` with `Classical.propDecidable`

Use dependent if-then-else with classical decidability:

```lean
| DerivationTree.weakening Γ'' _ ψ h1 h2 =>
    dite (A ∈ Γ'')
      (fun hA' : A ∈ Γ'' =>
        -- A ∈ Γ''
        ...)
      (fun hA' : A ∉ Γ'' =>
        -- A ∉ Γ''
        ...)
```

**Pros**: Works in term mode, no tactic needed
**Cons**: Requires explicit type annotations, less readable

### Alternative 3: Restructure to avoid nested case analysis

Split the weakening case into separate helper lemmas:

```lean
private def deduction_weakening_mem (Γ' Γ'' : Context) (A ψ : Formula)
    (h1 : Γ'' ⊢ ψ) (h2 : Γ'' ⊆ Γ') (hA : A ∈ Γ') (hA' : A ∈ Γ'') :
    (removeAll Γ' A) ⊢ A.imp ψ := ...

private def deduction_weakening_not_mem (Γ' Γ'' : Context) (A ψ : Formula)
    (h1 : Γ'' ⊢ ψ) (h2 : Γ'' ⊆ Γ') (hA : A ∈ Γ') (hA' : A ∉ Γ'') :
    (removeAll Γ' A) ⊢ A.imp ψ := ...
```

**Pros**: Cleaner separation of concerns, easier to test
**Cons**: More code, more functions to maintain

## Recommendations

### Primary Recommendation: Use `by_cases` tactic

**Rationale**:
1. **Idiomatic**: `by_cases` is the standard Lean 4 pattern for case analysis
2. **Proven**: Used extensively in Soundness.lean and Truth.lean
3. **Simple**: Minimal changes to existing code structure
4. **Maintainable**: Clear and readable

**Implementation Steps**:
1. Replace `(em P).elim (fun h => ...) (fun h => ...)` with `by_cases h : P`
2. Use `·` bullet points for the two cases
3. Remove closing parentheses from `.elim` patterns
4. Verify termination proofs still work (they should)

### Secondary Recommendation: Add documentation

Add comments explaining the classical reasoning:

```lean
-- Classical case analysis: either A ∈ Γ'' or A ∉ Γ''
-- This uses excluded middle (Classical.em) via by_cases
by_cases hA' : A ∈ Γ''
```

### Testing Strategy

1. **Build Test**: Run `lake build Logos.Core.Metalogic.DeductionTheorem`
2. **Verify No Errors**: All 3 errors should be resolved
3. **Run Existing Tests**: Ensure no regressions in metalogic tests
4. **Spot Check**: Manually verify the deduction theorem still works correctly

## Further Research Needed

None. The solution is clear and well-supported by existing patterns in the codebase.

## Implementation Checklist

- [ ] Replace `.elim` pattern in `deduction_with_mem` (line 256)
- [ ] Replace `.elim` patterns in `deduction_theorem` (lines 369, 376)
- [ ] Verify termination proofs compile
- [ ] Run `lake build Logos.Core.Metalogic.DeductionTheorem`
- [ ] Run metalogic tests
- [ ] Update SORRY_REGISTRY.md if needed
- [ ] Document classical reasoning patterns in LEAN_STYLE_GUIDE.md

## References

- **DeductionTheorem.lean**: Lines 39 (`open Classical`), 130, 215, 256, 343, 369
- **Soundness.lean**: Line 282 (`by_cases` pattern)
- **Truth.lean**: Lines 789-825 (nested `by_cases` pattern)
- **Formula.lean**: Line 75 (`DecidableEq` derivation)
- **Lean 4 Documentation**: Classical module, `by_cases` tactic
