# Research Summary: The `noncomputable` Keyword in Lean 4

**Task**: 192 (Research Extension)  
**Date**: 2025-12-28  
**Status**: Complete

---

## Quick Summary

The `noncomputable` keyword marks Lean 4 definitions that cannot be compiled to executable code. In task 192, `generalized_modal_k` and `generalized_temporal_k` must be marked `noncomputable` because they depend on `deduction_theorem`, which uses classical logic (Law of Excluded Middle).

**Fix**: Add `noncomputable` before `def` on lines 66 and 101 of GeneralizedNecessitation.lean.

---

## Core Concepts

### What `noncomputable` Means

- **Prevents**: Compilation to executable bytecode
- **Allows**: Use in proofs, type-checking, theorem statements
- **Impact**: None on logical correctness or proof validity

### Why Definitions Become Non-Computable

1. **Classical Axioms**: Using Law of Excluded Middle (`Classical.em`) or Axiom of Choice (`Classical.choice`)
2. **Structural Induction**: Pattern matching on non-canonical types (like derivation trees)
3. **Dependency Propagation**: Calling another `noncomputable` function

### Computability vs. Correctness

| Aspect | Computable | Non-Computable |
|--------|-----------|----------------|
| **Logical Correctness** | ✅ | ✅ |
| **Type-Checking** | ✅ | ✅ |
| **Proof Usage** | ✅ | ✅ |
| **Executable Code** | ✅ | ❌ |
| **#eval Command** | ✅ | ❌ |

---

## Task 192 Context

### The Dependency Chain

```
deduction_theorem (noncomputable)
    ↓
    ├─→ generalized_modal_k (needs noncomputable)
    └─→ generalized_temporal_k (needs noncomputable)
```

### Why `deduction_theorem` is Non-Computable

From `DeductionTheorem.lean:332`:
```lean
noncomputable def deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) : Γ ⊢ A.imp B := by
  match h with
  | ... =>
      by_cases h_eq : φ = A  -- Uses Classical.em
      ...
```

**Reasons**:
1. Uses `Classical.propDecidable` for `by_cases` on arbitrary propositions
2. Structural induction on derivation trees (non-canonical, potentially infinite)
3. Well-founded recursion on semantic height measure

### The Fix

**Before** (Lines 66, 101):
```lean
def generalized_modal_k : (Γ : Context) → ...
def generalized_temporal_k : (Γ : Context) → ...
```

**After**:
```lean
noncomputable def generalized_modal_k : (Γ : Context) → ...
noncomputable def generalized_temporal_k : (Γ : Context) → ...
```

**Result**: Errors disappear, no logic changes, functions work identically in proofs.

---

## Classical Logic and Computability

### Law of Excluded Middle

**Statement**: For any proposition P, either P or ¬P holds.

**Why Non-Computable**: Given arbitrary P (e.g., "the 10^100th digit of π is 7"), we cannot algorithmically determine which holds. Classical logic assumes P ∨ ¬P but provides no decision procedure.

**Example**:
```lean
-- Constructive (computable): explicit algorithm
def is_even (n : Nat) : Bool := n % 2 == 0

-- Classical (noncomputable): uses em, no algorithm
noncomputable def is_even_classical (n : Nat) : Bool :=
  if Classical.em (Even n) then true else false
```

### Axiom of Choice

**Statement**: If every set is non-empty, we can choose an element from each.

**Why Non-Computable**: Given proof that α is non-empty, `Classical.choice` produces an element, but the proof provides no information about WHICH element or HOW to construct it.

---

## Practical Implications

### What Changes

- ❌ Cannot use `#eval` on these functions
- ❌ Cannot compile to executable bytecode
- ❌ Cannot call from `def` (only from `noncomputable def`)

### What Stays the Same

- ✅ Type signatures unchanged
- ✅ Theorem statements unchanged
- ✅ Proof validity unchanged
- ✅ Usage in other proofs works
- ✅ Type-checking complexity unchanged

### Performance

- **Compile-time**: Slightly faster (code generation skipped)
- **Proof-time**: Identical (type-checking unchanged)
- **Runtime**: N/A (functions never executed)

---

## Best Practices

### 1. Mark Dependencies Explicitly

If function calls `noncomputable` dependency, mark it `noncomputable`:
```lean
noncomputable def caller := noncomputable_function ...
```

### 2. Document Reasons

```lean
/--
Noncomputable because:
- Uses Classical.em for case analysis on propositions
- Structural induction on derivation trees
-/
noncomputable def theorem_name ... := ...
```

### 3. Use `noncomputable section` for Groups

```lean
noncomputable section MetaTheorems
  def soundness ... := ...
  def completeness ... := ...
end MetaTheorems
```

### 4. Accept Non-Computability for Theorem Proving

For proof assistants (vs. program extraction), classical convenience > executable code.

---

## Common Patterns in ProofChecker

### Metalogic Modules

Pattern:
```lean
open Classical
attribute [local instance] Classical.propDecidable

noncomputable def metatheorem (proof : derivation) : result := by
  match proof with
  | case1 => by_cases h : ... -- Uses em
  | case2 => Classical.choice ... -- Uses choice
```

### Current Non-Computable Definitions

1. **DeductionTheorem.lean** (2):
   - `deduction_with_mem` (line 206)
   - `deduction_theorem` (line 332)

2. **Propositional.lean** (1):
   - `de` (disjunction elimination)

3. **GeneralizedNecessitation.lean** (after fix, 2):
   - `generalized_modal_k`
   - `generalized_temporal_k`

---

## Key Takeaways

1. **`noncomputable` is a computability annotation, not a correctness marker**
   - Has no effect on logical soundness
   - Only prevents code generation

2. **Classical logic requires non-computability**
   - Law of Excluded Middle provides no decision procedure
   - Axiom of Choice provides no construction method

3. **Propagates transitively**
   - If `f` calls `noncomputable g`, then `f` must be `noncomputable`
   - This is what happens in task 192

4. **Standard for theorem proving**
   - Most metalogic theorems use classical reasoning
   - Non-computability is expected and acceptable

5. **Simple fix for task 192**
   - Add `noncomputable` keyword (one word per function)
   - No logic changes needed
   - Errors resolve immediately

---

## References

- **Full Report**: `.opencode/specs/192_.../reports/noncomputable-research.md`
- **Original Research**: `.opencode/specs/192_.../reports/research-001.md`
- **Lean Documentation**: [Axioms and Computation](https://lean-lang.org/theorem_proving_in_lean4/axioms_and_computation.html)
- **Source Files**:
  - `Logos/Core/Metalogic/DeductionTheorem.lean` (noncomputable examples)
  - `Logos/Core/Theorems/GeneralizedNecessitation.lean` (functions to fix)

---

**Summary Complete**: 2025-12-28  
**Next Action**: Implement fix (add `noncomputable` to lines 66, 101)
