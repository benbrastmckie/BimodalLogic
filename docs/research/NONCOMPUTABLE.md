# Research Report: The `noncomputable` Keyword in Lean 4

**Task**: 192 (Research Extension)  
**Research Date**: 2025-12-28  
**Researcher**: AI Assistant  
**Status**: Research Complete

---

## Executive Summary

This report provides a comprehensive technical explanation of the `noncomputable` keyword in Lean 4, specifically in the context of task 192 (fixing GeneralizedNecessitation.lean termination errors) and the broader ProofChecker codebase. The `noncomputable` keyword is a critical annotation that marks definitions which cannot be compiled to executable code, typically because they depend on classical axioms or constructively uncomputable operations.

**Key Takeaways**:
- `noncomputable` is a computability annotation, not a logical correctness marker
- Required when definitions depend on classical axioms (Law of Excluded Middle, Choice)
- Propagates transitively through dependency chains
- No impact on type-checking, proofs, or logical soundness
- Essential for theorem proving with classical logic

---

## What is `noncomputable` in Lean 4?

### Definition

The `noncomputable` keyword in Lean 4 marks a definition that cannot be evaluated or compiled to executable code. It tells Lean's compiler to skip code generation for this definition while still allowing it to be used in proofs and type-checking.

**Syntax**:
```lean
noncomputable def function_name (args) : return_type := body
```

### Purpose

Lean 4 is both a proof assistant AND a functional programming language. By default, Lean expects all definitions to be:
1. **Computable**: Can be compiled to executable bytecode
2. **Normalizable**: Can be evaluated to a canonical form
3. **Constructive**: Built from computationally meaningful operations

However, theorem proving often requires **classical reasoning** (like Law of Excluded Middle) which has no computational content. The `noncomputable` keyword bridges this gap by allowing non-executable definitions while preserving Lean's type safety guarantees.

---

## Computational vs. Non-Computational Definitions

### Computable Definitions

Definitions that can be compiled to executable code:

```lean
-- Computable: direct pattern matching
def factorial : Nat → Nat
  | 0 => 1
  | n + 1 => (n + 1) * factorial n

-- Computable: constructive proof
def even_or_odd (n : Nat) : (Even n) ∨ (Odd n) := by
  induction n
  case zero => left; exact ⟨0, rfl⟩
  case succ n ih => 
    cases ih
    · right; -- even n → odd (n+1)
    · left;  -- odd n → even (n+1)
```

### Non-Computable Definitions

Definitions that cannot be compiled to executable code:

```lean
-- Non-computable: uses Classical.choice
noncomputable def some_element {α : Type} (h : Nonempty α) : α :=
  Classical.choice h

-- Non-computable: uses Law of Excluded Middle
noncomputable def decidable_proposition (P : Prop) : Bool :=
  if Classical.em P then true else false

-- Non-computable: depends on another noncomputable definition
noncomputable def uses_choice {α : Type} (h : Nonempty α) : α × α :=
  let x := some_element h
  (x, x)
```

---

## Why Definitions Become Non-Computable

### 1. **Classical Axioms**

Using classical axioms makes definitions non-computable:

**Law of Excluded Middle (EM)**:
```lean
axiom Classical.em (P : Prop) : P ∨ ¬P
```

This axiom states that every proposition is either true or false, but provides no **constructive method** to determine which. Using `em` in a definition makes it non-computable:

```lean
-- Non-computable: uses em to decide membership
noncomputable def contains {α : Type} (l : List α) (a : α) : Bool :=
  if Classical.em (a ∈ l) then true else false
```

**Axiom of Choice**:
```lean
axiom Classical.choice {α : Type} : Nonempty α → α
```

This axiom guarantees existence but not construction:

```lean
-- Non-computable: choice doesn't tell us HOW to get the element
noncomputable def pick_element {α : Type} (h : ∃ x : α, P x) : α :=
  Classical.choice ⟨Classical.choose h⟩
```

### 2. **Structural Induction on Non-Finite Types**

Induction on infinite or non-constructive types:

```lean
-- Non-computable: structural induction on derivation trees
-- (which can be arbitrarily large and non-canonical)
noncomputable def deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) : Γ ⊢ A.imp B := by
  match h with  -- Pattern matching on derivation structure
  | DerivationTree.axiom ... => ...
  | DerivationTree.assumption ... => ...
  | DerivationTree.modus_ponens ... => ...
  | DerivationTree.weakening ... => ...
```

### 3. **Dependency Propagation**

If `f` depends on a noncomputable `g`, then `f` must also be noncomputable:

```lean
-- g is noncomputable
noncomputable def g (x : Nat) : Nat := 
  if Classical.em (Even x) then x else x + 1

-- f depends on g, so f must be noncomputable
noncomputable def f (x : Nat) : Nat :=
  g x + g (x + 1)
```

This is exactly what happens in task 192:
- `deduction_theorem` is `noncomputable` (uses structural induction + classical reasoning)
- `generalized_modal_k` calls `deduction_theorem`
- Therefore `generalized_modal_k` MUST be `noncomputable`

---

## Task 192: The GeneralizedNecessitation.lean Case

### Context

**File**: `Logos/Core/Theorems/GeneralizedNecessitation.lean`

**Errors**:
```
Error (Line 66): fail to show termination for generalized_modal_k
depends on 'Logos.Core.Metalogic.deduction_theorem', which has no executable code

Error (Line 101): fail to show termination for generalized_temporal_k
depends on 'Logos.Core.Metalogic.deduction_theorem', which has no executable code
```

### Analysis

**Current Definitions** (Lines 66, 101):
```lean
def generalized_modal_k : (Γ : Context) → (φ : Formula) →
    (h : Γ ⊢ φ) → ((Context.map Formula.box Γ) ⊢ Formula.box φ)
  | [], φ, h => DerivationTree.necessitation φ h
  | A :: Γ', φ, h =>
    let h_deduction : Γ' ⊢ A.imp φ := deduction_theorem Γ' A φ h  -- CALLS noncomputable
    ...
```

**Dependency Chain**:
1. `deduction_theorem` (DeductionTheorem.lean:332) is `noncomputable`
2. `generalized_modal_k` calls `deduction_theorem` at line 71
3. `generalized_temporal_k` calls `deduction_theorem` at line 105
4. Both functions inherit the non-computability

### Why `deduction_theorem` is Non-Computable

From `DeductionTheorem.lean`:

```lean
noncomputable def deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) : Γ ⊢ A.imp B := by
  match h with
  | DerivationTree.axiom _ φ h_ax => ...
  | DerivationTree.assumption _ φ h_mem =>
      by_cases h_eq : φ = A  -- Uses Classical decidability
      ...
  | DerivationTree.weakening Γ' _ φ h1 h2 =>
      by_cases h_eq : Γ' = A :: Γ  -- Uses Classical decidability
      ...
```

**Reasons for Non-Computability**:

1. **Classical Decidability** (Line 41):
   ```lean
   attribute [local instance] Classical.propDecidable
   ```
   This enables `by_cases` on arbitrary propositions, using `Classical.em`.

2. **Structural Induction on Derivations**:
   The function pattern matches on `DerivationTree`, which represents proof trees. These trees:
   - Can be arbitrarily large (no size bound)
   - Have no canonical form (many proofs for same theorem)
   - Use `by_cases` on propositions like `φ = A` which is undecidable constructively

3. **Well-Founded Recursion** (Line 436):
   ```lean
   termination_by h.height
   decreasing_by simp_wf; ...
   ```
   Uses well-founded recursion on derivation height, which is a semantic (not syntactic) measure.

### The Fix

**Required Changes**:
```lean
-- Line 66: Add noncomputable
noncomputable def generalized_modal_k : (Γ : Context) → (φ : Formula) →
    (h : Γ ⊢ φ) → ((Context.map Formula.box Γ) ⊢ Formula.box φ)
  | [], φ, h => DerivationTree.necessitation φ h
  | A :: Γ', φ, h =>
    let h_deduction : Γ' ⊢ A.imp φ := deduction_theorem Γ' A φ h
    ...

-- Line 101: Add noncomputable
noncomputable def generalized_temporal_k : (Γ : Context) → (φ : Formula) →
    (h : Γ ⊢ φ) → ((Context.map Formula.all_future Γ) ⊢ Formula.all_future φ)
  | [], φ, h => DerivationTree.temporal_necessitation φ h
  | A :: Γ', φ, h =>
    let h_deduction : Γ' ⊢ A.imp φ := deduction_theorem Γ' A φ h
    ...
```

**Why This Works**:
- Marking functions as `noncomputable` tells Lean: "Don't try to compile this"
- Lean skips code generation but still type-checks and allows proof usage
- The dependency on `noncomputable deduction_theorem` is now properly declared
- No change to logical correctness, only computability annotation

---

## Implications and Impact

### What `noncomputable` Does

**Allows**:
- ✅ Type-checking and proof verification
- ✅ Usage in other proofs and theorems
- ✅ Pattern matching and case analysis
- ✅ All logical reasoning and derivations

**Prevents**:
- ❌ Compilation to executable bytecode
- ❌ Evaluation in `#eval` or `#reduce` commands
- ❌ Use in computable functions (without marking them `noncomputable`)
- ❌ Export to computational backends

### What `noncomputable` Does NOT Affect

**Unchanged**:
- Logical correctness (proofs remain valid)
- Type signatures (function types unchanged)
- Theorem statements (propositions unchanged)
- Usage in proofs (can still be applied)
- Soundness or consistency (no axioms added)

### Performance Considerations

**Runtime**: None. Non-computable functions are never executed at runtime.

**Compile-time**: Slight reduction in compile time because code generation is skipped.

**Proof-time**: No impact. Type-checking and proof verification work identically.

---

## Broader Context in ProofChecker

### Non-Computable Definitions in ProofChecker

From the codebase:

1. **DeductionTheorem.lean** (2 definitions):
   - `deduction_with_mem` (line 206): Helper using structural recursion
   - `deduction_theorem` (line 332): Main theorem using classical logic

2. **Propositional.lean** (1 definition):
   - `de` (disjunction elimination): Uses `deduction_theorem`, inherits non-computability

3. **GeneralizedNecessitation.lean** (after fix, 2 definitions):
   - `generalized_modal_k`: Depends on `deduction_theorem`
   - `generalized_temporal_k`: Depends on `deduction_theorem`

### Pattern in Metalogic Modules

**Common Pattern**:
```lean
-- Metalogic theorems use Classical logic
open Classical
attribute [local instance] Classical.propDecidable

-- Main theorems are noncomputable
noncomputable def soundness_theorem ... := by
  by_cases h : ... -- Uses em
  ...

noncomputable def completeness_theorem ... := by
  -- Uses choice to construct canonical model
  let model := Classical.choice ⟨canonical_model⟩
  ...
```

**Why**: Metalogic (proving properties ABOUT the logic) often requires classical reasoning that object-level logic doesn't need.

---

## Classical Logic and Computability

### The Law of Excluded Middle

**Statement**: For any proposition P, either P is true or P is false.
```lean
axiom Classical.em (P : Prop) : P ∨ ¬P
```

**Why Non-Computable**:
- Given an arbitrary proposition P (e.g., "the 10^100th digit of π is 7"), we cannot **algorithmically determine** whether P is true or false
- Classical logic assumes P ∨ ¬P holds, but provides no **witness** or **decision procedure**
- Using `em` in a definition makes it non-constructive → non-computable

**Example**:
```lean
-- Constructive (computable): provides algorithm
def is_even_constructive (n : Nat) : Bool :=
  n % 2 == 0

-- Classical (non-computable): uses em
noncomputable def is_even_classical (n : Nat) : Bool :=
  if Classical.em (Even n) then true else false
```

The first is computable because we have an algorithm (modulo). The second uses `em` which gives no algorithm, just existence of truth value.

### Axiom of Choice

**Statement**: If every set is non-empty, we can choose an element from each.
```lean
axiom Classical.choice {α : Type} : Nonempty α → α
```

**Why Non-Computable**:
- Given `Nonempty α` (proof that α has at least one element), `choice` magically produces an element
- But the proof gives no **constructive information** about which element or how to find it
- The choice is **arbitrary and unspecified**

**Example**:
```lean
-- Constructive: explicit element
def first_nat : Nat := 0

-- Non-constructive: uses choice
noncomputable def some_nat (h : Nonempty Nat) : Nat :=
  Classical.choice h  -- Which Nat? We don't know!
```

### Decidability vs. Classical Decidability

**Decidable** (Computable):
```lean
instance : Decidable (n = m) := ...  -- Can actually compute equality
```

**Classically Decidable** (Non-Computable):
```lean
attribute [local instance] Classical.propDecidable
-- Now `by_cases h : P` works for ANY P, using em
```

The difference:
- Decidable: "I can write a program to decide this"
- Classically decidable: "I assume this has a truth value, but I can't compute it"

---

## Historical and Philosophical Context

### Constructivism vs. Classical Mathematics

**Constructive Mathematics** (Intuitionism):
- Every proof must provide a construction or algorithm
- Existence requires exhibiting a witness
- P ∨ ¬P is NOT universally valid (requires proof for each P)
- Computable in Lean 4

**Classical Mathematics**:
- Proofs can use non-constructive methods (em, choice)
- Existence doesn't require construction
- P ∨ ¬P is assumed for all P
- Non-computable in Lean 4

### Why Lean Supports Both

Lean 4 is designed to support BOTH paradigms:

**By Default** (Constructive):
- All definitions are computable
- Can extract programs from proofs
- Aligns with intuitionistic type theory

**With `noncomputable`** (Classical):
- Can use classical axioms for convenience
- Matches standard mathematical practice
- Enables proof techniques from classical logic

**Trade-off**:
- Constructive: More effort, but get executable code
- Classical: Less effort, but lose executability

For theorem proving (ProofChecker's use case), we typically prefer classical convenience over executable code.

---

## Common Patterns and Best Practices

### 1. Mark Dependencies Explicitly

**Good**:
```lean
noncomputable def deduction_theorem ... := ...

noncomputable def uses_deduction ... :=
  deduction_theorem ...  -- Explicitly noncomputable
```

**Bad** (causes errors):
```lean
noncomputable def deduction_theorem ... := ...

def uses_deduction ... :=  -- ERROR: depends on noncomputable
  deduction_theorem ...
```

### 2. Document Why Noncomputable

**Good**:
```lean
/--
The deduction theorem is noncomputable because it uses:
- Classical decidability for `by_cases` on proposition equality
- Structural induction on derivation trees (non-canonical form)
- Well-founded recursion on semantic height measure
-/
noncomputable def deduction_theorem ... := ...
```

### 3. Minimize Scope

**Prefer**:
```lean
-- Only helper is noncomputable
private noncomputable def helper ... :=
  Classical.choice ...

-- Main theorem uses computable tactics
theorem main_theorem ... := by
  have h := helper ...
  exact h
```

**Over**:
```lean
-- Entire theorem noncomputable when only helper needs it
noncomputable def main_theorem ... :=
  Classical.choice ...
```

### 4. Use `noncomputable section` for Multiple Definitions

**Convenient**:
```lean
noncomputable section DeductionTheorems

def deduction_theorem ... := ...
def reverse_deduction ... := ...
def deduction_mp ... := ...

end DeductionTheorems
```

**Equivalent to**:
```lean
noncomputable def deduction_theorem ... := ...
noncomputable def reverse_deduction ... := ...
noncomputable def deduction_mp ... := ...
```

---

## Debugging Non-Computability Errors

### Error: "has no executable code"

**Message**:
```
failed to compile definition, compiler IR check failed at 'Logos.Core.Theorems.generalized_modal_k'.
Error: depends on declaration 'Logos.Core.Metalogic.deduction_theorem', which has no executable code;
consider marking definition as 'noncomputable'
```

**Diagnosis**:
1. Function `generalized_modal_k` is marked `def` (computable)
2. It calls `deduction_theorem` which is `noncomputable`
3. Computable functions cannot depend on non-computable functions

**Fix**: Mark caller as `noncomputable`:
```lean
noncomputable def generalized_modal_k ... := ...
```

### Error: "fail to show termination"

**Message**:
```
error: fail to show termination for generalized_modal_k
with errors
failed to compile definition, compiler IR check failed ...
```

**Misleading**: Error says "termination" but root cause is non-computability!

**Why**: Lean's compiler tries to:
1. Check termination (needs to analyze recursion)
2. Generate executable code (needs computability)

When (2) fails due to non-computability, error message mentions (1) which was attempted first.

**Diagnosis**: Look for "has no executable code" in error details.

**Fix**: Add `noncomputable`, not termination proof.

---

## Advanced Topics

### Partial Computability

Some functions are "partially computable" - computable on some inputs, non-computable on others:

```lean
-- Computable for concrete inputs, noncomputable in general
noncomputable def example (n : Nat) : Nat :=
  if Classical.em (n > 100) then n else 0

#eval example 50  -- ERROR: noncomputable
```

Lean requires the ENTIRE definition to be computable or non-computable.

### Code Extraction

**Computable**:
```lean
def factorial (n : Nat) : Nat := ...

-- Can extract to Haskell/OCaml/C:
#eval factorial 10  -- Runs!
```

**Non-Computable**:
```lean
noncomputable def deduction_theorem ... := ...

#eval deduction_theorem ...  -- ERROR
```

For ProofChecker, we don't need code extraction (only proof verification), so `noncomputable` is fine.

### Performance of Type-Checking

**Myth**: "noncomputable definitions slow down type-checking"

**Reality**: Type-checking complexity is the same. The `noncomputable` keyword only affects code generation (which is skipped), not type elaboration or proof checking.

---

## Conclusion

### Summary

**What is `noncomputable`**:
- Annotation marking definitions that cannot be compiled to executable code
- Required for classical reasoning (em, choice) and certain induction patterns
- Propagates through dependency chains

**Why needed in Task 192**:
- `deduction_theorem` uses classical logic → noncomputable
- `generalized_modal_k` and `generalized_temporal_k` call `deduction_theorem`
- Must mark callers as `noncomputable` to satisfy dependency constraint

**Impact**:
- No effect on logical correctness or proofs
- Prevents execution but allows proof usage
- Standard pattern for classical theorem proving

### Key Principles

1. **Computability is Separate from Correctness**: `noncomputable` is an implementation detail, not a soundness concern.

2. **Classical Logic Requires Non-Computability**: Using em or choice makes definitions non-constructive.

3. **Propagation is Automatic**: If `f` calls `noncomputable g`, then `f` must be `noncomputable`.

4. **Document Why**: Good practice to explain why each definition is noncomputable.

5. **No Performance Cost**: Type-checking complexity unchanged, only code generation skipped.

### Recommendations for ProofChecker

1. **Accept Non-Computability**: For theorem proving, classical logic is more convenient than constructive alternatives.

2. **Mark Explicitly**: Always mark functions using classical logic as `noncomputable` upfront.

3. **Document Dependencies**: Note which axioms (em, choice) make functions noncomputable.

4. **Style Guide**: Add guideline: "Metalogic theorems using Classical logic should be `noncomputable`"

5. **Consistency**: Audit similar modules (Soundness, Completeness) to ensure consistent annotations.

---

## References

### Lean 4 Documentation

1. **Theorem Proving in Lean 4**: [Axioms and Computation](https://lean-lang.org/theorem_proving_in_lean4/axioms_and_computation.html)
2. **Lean Manual**: Noncomputable Definitions section
3. **Lean 4 API Docs**: `Classical.em`, `Classical.choice`

### ProofChecker Files

1. **DeductionTheorem.lean**: Lines 206, 332 (noncomputable definitions)
2. **GeneralizedNecessitation.lean**: Lines 66, 101 (functions needing fix)
3. **Propositional.lean**: Example of propagated non-computability

### Mathematical Background

1. **Intuitionism**: Brouwer, Heyting (constructive mathematics)
2. **Classical Logic**: Hilbert (non-constructive methods)
3. **Type Theory**: Martin-Löf (computational interpretation of proofs)

---

**Research Complete**: 2025-12-28  
**Report Type**: Technical Deep Dive  
**Audience**: ProofChecker developers, Lean 4 theorem provers  
**Status**: Ready for implementation (task 192) and reference
