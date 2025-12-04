# Temporal Duality Options Comparison: Research Report

**Date:** 2025-12-04
**Context:** Generalization of Logos temporal semantics from `Int` to polymorphic `T : Type*` with `LinearOrderedAddCommGroup T`
**Issue:** `is_valid` definition causing universe level mismatches in TemporalDuality section

---

## Executive Summary

**Recommendation: Option A (Fix is_valid to a specific T)**

After comprehensive analysis of semantic correctness, proof complexity, Mathlib patterns, and technical feasibility, **Option A is strongly recommended**. The polymorphic `is_valid` (Option B) introduces fundamental type theory issues that are not solvable through proof threading, while Option A maintains semantic correctness, aligns with Mathlib patterns, and requires minimal proof effort.

**Key Finding:** The polymorphic quantification `∀ {U : Type*}` in `is_valid` creates universe level conflicts because:
1. The outer formula induction binds `{U : Type*}` implicitly
2. The inner `h_valid` application requires a fresh universe variable `{U' : Type*}`
3. Lean 4's universe unification cannot equate these distinct universe variables

**Implementation Path:** Change `is_valid` from polymorphic to monomorphic, inheriting `T` from section variable. Estimated effort: 2-4 hours total.

---

## 1. Current State Analysis

### 1.1 The is_valid Definition (Current - Polymorphic)

```lean
private def is_valid (φ : Formula) : Prop :=
  ∀ {U : Type*} [LinearOrderedAddCommGroup U] (F : TaskFrame U) (M : TaskModel F)
    (τ : WorldHistory F) (t : U) (ht : τ.domain t),
    truth_at M τ t ht φ
```

This definition quantifies over **all** temporal types `U`, making it maximally general but creating universe issues.

### 1.2 Error Pattern Observed

From compilation output:
```
error: application type mismatch
  @h_valid U
argument
  U
has type
  Type u_2 : Type (u_2 + 1)
but is expected to have type
  Type u_3 : Type (u_3 + 1)
```

This occurs in 6+ theorems:
- `valid_at_triple`
- `truth_swap_of_valid_at_triple` (3 cases)
- Axiom swap validity theorems (multiple instances)

### 1.3 Root Cause

The universe mismatch arises from **nested quantification**:

1. Outer scope: `theorem truth_swap_of_valid_at_triple ... {U : Type*} ...`
2. Inner scope: `is_valid φ` expands to `∀ {U' : Type*} ...`
3. Lean cannot unify `u_2` (from outer `U`) with `u_3` (from inner `U'`)

This is not a proof technique issue - it's a fundamental type theory limitation.

---

## 2. Option A: Fix is_valid to Specific T

### 2.1 Proposed Definition

```lean
section TemporalDuality

variable {T : Type*} [LinearOrderedAddCommGroup T]

private def is_valid (φ : Formula) : Prop :=
  ∀ (F : TaskFrame T) (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t),
    truth_at M τ t ht φ
```

The `T` is inherited from the section variable, making `is_valid` monomorphic within the section.

### 2.2 Semantic Correctness

**Question:** Does this capture the intended notion of validity from the JPL paper?

**Answer:** **Yes, with important clarification**.

The JPL paper (app:TaskSemantics) defines validity as "true at all task frames". The paper's time group `G = ⟨T, +, ≤⟩` is a **fixed mathematical structure** for a given interpretation, not a quantification over all possible time structures.

**Key Insight from Paper:**
- The paper uses `Int` (or implicitly `Z`) for discrete time
- Alternative time structures (`Rat`, `Real`) represent **different physical interpretations**
- Validity is relative to a **choice of temporal domain**

**Analogy:** Just as first-order logic validity is relative to a choice of signature, TM validity is relative to a choice of temporal structure.

**Conclusion:** Fixing `T` in `is_valid` accurately represents "validity within a temporal interpretation". The polymorphism belongs at the **module/theorem level**, not the validity definition itself.

### 2.3 Proof Complexity

**Estimated Changes:**

| Component | Change Required | Effort |
|-----------|----------------|--------|
| `is_valid` definition | Add `T` parameter to section | 5 min |
| `valid_at_triple` | Remove `{U : Type*}`, use section `T` | 10 min |
| `truth_swap_of_valid_at_triple` | Remove `{U : Type*}`, use section `T` | 15 min |
| Axiom swap theorems (10) | No changes (already use section `T`) | 0 min |
| Rule preservation (4) | No changes | 0 min |
| `derivable_implies_swap_valid` | No changes | 0 min |

**Total Estimated Effort:** 30-45 minutes of mechanical changes

**Risk:** Very low - changes are straightforward deletions of redundant type parameters

### 2.4 Advantages

1. **Eliminates universe conflicts** - Single `T` throughout the section
2. **Matches Mathlib patterns** - Satisfiability is typically monomorphic (see Section 4)
3. **Simpler type inference** - No universe unification required
4. **Zero proof changes** - Only signature simplification
5. **Semantically correct** - Aligns with paper's intent

### 2.5 Disadvantages

1. **Appears less general** - Seems to restrict validity to one temporal type
2. **Requires understanding** - Users must understand polymorphism is at module level

**Mitigation:** Document clearly that polymorphism is achieved through module instantiation, not internal quantification.

---

## 3. Option B: Restructure Proofs with Explicit Type Parameters

### 3.1 Approach

Keep polymorphic `is_valid`, fix all proofs using `@` syntax and careful universe management:

```lean
theorem valid_at_triple {φ : Formula} (h_valid : is_valid φ)
    {U : Type u} [LinearOrderedAddCommGroup U]
    (F : TaskFrame U) (M : TaskModel F) (τ : WorldHistory F)
    (t : U) (ht : τ.domain t) :
    truth_at M τ t ht φ :=
  @h_valid U _ F M τ t ht
```

### 3.2 Semantic Correctness

**Question:** Does this preserve the intended semantics?

**Answer:** **Yes**, but it's semantically equivalent to Option A with more complexity.

The polymorphic quantification `∀ {U : Type*}` means "for every temporal type U". But in practice:
- Each proof uses a **specific** `U`
- The generality is **never exploited** within a single proof
- Polymorphism only matters at the **theorem statement level**

**Key Insight:** Polymorphic `is_valid` doesn't enable any proofs that monomorphic can't - it just complicates type checking.

### 3.3 Proof Complexity

**Estimated Changes:**

| Component | Change Required | Effort |
|-----------|----------------|--------|
| `valid_at_triple` | Add explicit universe variables, use `@` | 30 min |
| `truth_swap_of_valid_at_triple` | Add universe params to induction, thread through all cases | 3-4 hours |
| Axiom swap theorems | Add universe management to each | 2-3 hours |
| Rule preservation | Thread universe params through composition | 1-2 hours |
| `derivable_implies_swap_valid` | Universe polymorphic induction | 2-3 hours |

**Total Estimated Effort:** 8.5-12.5 hours

**Risk:** High - universe unification is fragile, errors cascade

### 3.4 Technical Feasibility Analysis

**Critical Issue:** Nested formula induction with polymorphic validity

In `truth_swap_of_valid_at_triple`:
```lean
theorem truth_swap_of_valid_at_triple (φ : Formula) {U : Type u} ... :
    is_valid φ → truth_at M τ t ht φ.swap_past_future := by
  intro h_valid
  induction φ generalizing F M τ t ht with
  | box ψ ih =>
    -- h_valid : ∀ {U' : Type u'} (F' : TaskFrame U') ...
    -- ih : ∀ (F : TaskFrame U) ... is_valid ψ → ...
    -- Problem: is_valid ψ quantifies over U', but we need it at U
    have h_ψ_valid : is_valid ψ := by
      intro U' inst F' M' τ' t' ht'
      have h_box := @h_valid U _ F M τ t ht  -- Works here
      exact h_box τ' ht'                      -- But this uses τ' : WorldHistory F', where F' : TaskFrame U
                                               -- Type error: U ≠ U'
```

**The Problem:** You cannot extract `is_valid ψ` (quantifying over all `U'`) from `is_valid (box ψ)` instantiated at a specific `U`, because the universal quantifier is **inside the box semantics**, not outside.

**Mathematical Issue:** This is trying to prove:
```
(∀ U, ∀ F:TaskFrame(U), ... ∀ σ, ψ at σ)  →  (∀ U', ∀ F':TaskFrame(U'), ... ψ at F')
```

But the premise only gives ψ validity **when extracted from box validity at all F:TaskFrame(U)**, not at arbitrary `F':TaskFrame(U')` for `U' ≠ U`.

**Conclusion:** Option B is **not technically feasible** without restructuring the entire proof strategy (e.g., proving `is_valid φ ↔ is_valid_at_U φ` for all U, which introduces circularity).

### 3.5 Advantages

1. **Appears maximally general** - Definition looks polymorphic
2. **No semantic questions** - Obviously captures "all types"

### 3.6 Disadvantages

1. **Universe hell** - Constant `@` syntax, explicit universe threading
2. **Fragile** - Universe constraints break on refactoring
3. **High effort** - 8.5-12.5 hours of delicate work
4. **Not actually feasible** - Fundamental type theory issue in nested quantification
5. **False generality** - Polymorphism unused within proofs

---

## 4. Mathlib Precedent Research

### 4.1 Mathlib.ModelTheory.Satisfiability

From [Mathlib4 ModelTheory docs](https://leanprover-community.github.io/mathlib4_docs/Mathlib/ModelTheory/Satisfiability.html):

```lean
-- Mathlib defines satisfiability at a FIXED signature L
structure Language where
  Functions : ℕ → Type u₁
  Relations : ℕ → Type u₂

def Theory.IsSatisfiable (T : Theory L) : Prop :=
  Nonempty (T.Model)
```

**Key Observation:** Satisfiability is relative to a **fixed language** `L`, not quantifying over all languages.

**Parallel to Logos:**
- Mathlib: Satisfiability at fixed signature `L`
- Logos: Validity at fixed temporal type `T`

### 4.2 Universe Polymorphism Guidelines

From [Lean 4 Reference Manual](https://lean-lang.org/doc/reference/latest/The-Type-System/Universes/):

> "When you define a universe-polymorphic constant, you are really defining a parametric family of constants, denoted `a.{u}`. It's not like `a` exists in some particular universe `u`, rather there is a different `a` at each universe."

**Implication:** Polymorphism should be at the **definition level** (different `is_valid.{T}` for each `T`), not internal quantification.

### 4.3 Lean 4 Best Practices

From [Functional Programming in Lean](https://docs.lean-lang.org/functional_programming_in_lean/functor-applicative-monad/universes.html):

> "Independent type arguments should have different universe variables... Try to put the new type in as small of a universe as possible."

**Application:** The temporal type `T` should be a **parameter** to the section/module, not internally quantified in `is_valid`.

### 4.4 Conclusion from Mathlib

**Pattern Match:** Option A follows Mathlib's design pattern exactly:
- Fixed background structure (language `L` / temporal type `T`)
- Polymorphism via module instantiation
- Internal definitions assume fixed structure

---

## 5. Future Extensibility

### 5.1 Adding New Temporal Types

**Option A Approach:**
```lean
-- Discrete time
section DiscreteTime
variable {T : Type*} [LinearOrderedAddCommGroup T] [DiscreteOrdered T]
-- Use is_valid as defined
end DiscreteTime

-- Dense time
section DenseTime
variable {T : Type*} [LinearOrderedAddCommGroup T] [DenselyOrdered T]
-- Same is_valid definition, different T constraints
end DenseTime

-- Real time
section RealTime
#check @is_valid Real _  -- Instantiate with Real
end RealTime
```

**Option B Approach:**
```lean
-- Must thread universe parameters through everything
theorem discrete_time_property {U : Type u} [LinearOrderedAddCommGroup U] [DiscreteOrdered U] :
  is_valid φ → ... := by
  intro h_valid
  -- Every use of h_valid requires @h_valid U _ ...
```

**Winner:** Option A - cleaner module organization, no universe threading

### 5.2 Metatheorems About Validity

**Example:** Proving temporal logic valid in `Int` iff valid in `Z` (integer group).

**Option A:**
```lean
theorem valid_int_iff_valid_group (φ : Formula) :
  @is_valid Int _ φ ↔ @is_valid ℤ _ φ := ...
```

Clean statement of equivalence between temporal structures.

**Option B:**
```lean
-- How do you even state this? is_valid already quantifies over all types
-- Would need a different definition for type-specific validity
```

**Winner:** Option A - enables metatheory about temporal structures

### 5.3 Integration with Model Checking

From `Documentation/UserGuide/INTEGRATION.md` (inferred from structure):

Model checkers typically work with **specific temporal domains**:
- Bounded model checking: finite intervals
- LTL model checking: `ℕ` or `ℤ`
- Real-time verification: `ℝ≥0`

**Option A:** Natural interface - model checker picks `T`, uses `is_valid` at that `T`

**Option B:** Awkward - model checker must deal with polymorphic `is_valid` even though it uses a specific `T`

**Winner:** Option A - better external integration

---

## 6. Detailed Comparison Table

| Criterion | Option A (Fix T) | Option B (Polymorphic) | Winner |
|-----------|-----------------|----------------------|---------|
| **Semantic Correctness** | ✅ Matches JPL paper intent | ✅ Matches JPL paper literally | Tie |
| **Proof Effort** | 30-45 min | 8.5-12.5 hours | **A** |
| **Technical Feasibility** | ✅ Straightforward | ❌ Fundamental issues | **A** |
| **Mathlib Alignment** | ✅ Matches ModelTheory patterns | ❌ Unusual internal quantification | **A** |
| **Universe Management** | None required | Extensive `@` threading | **A** |
| **Code Maintainability** | High - simple types | Low - fragile universes | **A** |
| **Future Extensibility** | ✅ Module-level polymorphism | ⚠️ Awkward metatheory | **A** |
| **External Integration** | ✅ Clean interfaces | ⚠️ Unnecessary complexity | **A** |
| **Conceptual Clarity** | ✅ "Validity at a temporal structure" | ⚠️ "Validity over all structures" | **A** |
| **Error Messages** | Clear, simple types | Confusing universe errors | **A** |

**Overall:** Option A wins 9/10 criteria (1 tie)

---

## 7. Implementation Recommendations

### 7.1 Recommended Changes (Option A)

**Step 1:** Add section variable (5 minutes)
```lean
section TemporalDuality

variable {T : Type*} [LinearOrderedAddCommGroup T]

private def is_valid (φ : Formula) : Prop :=
  ∀ (F : TaskFrame T) (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t),
    truth_at M τ t ht φ
```

**Step 2:** Simplify `valid_at_triple` (10 minutes)
```lean
-- Before
theorem valid_at_triple {φ : Formula} (h_valid : is_valid φ)
    {U : Type*} [LinearOrderedAddCommGroup U]
    (F : TaskFrame U) (M : TaskModel F) ...

-- After
theorem valid_at_triple {φ : Formula} (h_valid : is_valid φ)
    (F : TaskFrame T) (M : TaskModel F) ...
```

**Step 3:** Simplify `truth_swap_of_valid_at_triple` (15 minutes)
```lean
-- Remove {U : Type*} [LinearOrderedAddCommGroup U] from signature
-- Change all F : TaskFrame U to F : TaskFrame T
-- Remove @h_valid U _ applications, use h_valid directly
```

**Step 4:** Verify compilation (5 minutes)
```bash
lake build Logos.Semantics.Truth
```

**Total Time:** 35 minutes

### 7.2 Testing Strategy

1. **Compilation Test:** Ensure Truth.lean builds without errors
2. **Soundness Test:** Verify Soundness.lean still compiles (uses TemporalDuality theorems)
3. **Example Instantiation:** Add test showing polymorphism at module level:
   ```lean
   example : @is_valid Int _ (Formula.box (Formula.atom "p")) := ...
   example : @is_valid Rat _ (Formula.box (Formula.atom "p")) := ...
   ```

### 7.3 Documentation Updates

1. **Truth.lean docstring:** Explain that `is_valid` is polymorphic via section variable
2. **ARCHITECTURE.md:** Clarify temporal type polymorphism is at module level
3. **KNOWN_LIMITATIONS.md:** Remove any notes about polymorphic validity issues

---

## 8. Addressing Potential Objections

### 8.1 Objection: "Option A is less general"

**Response:** False. Option A provides **identical generality** through module-level polymorphism:
- Option B: One `is_valid` with internal `∀ U`
- Option A: Family of `is_valid T` for each `T` (via section parameter)

These are **isomorphic** in expressive power, but Option A has better type checking.

### 8.2 Objection: "JPL paper says 'all temporal structures'"

**Response:** The paper's "all temporal structures" refers to **choice of interpretation**, not internal quantification:
- Paper uses `Int` (implicitly) for discrete time examples
- Paper would use `Real` for continuous time examples
- These are **different interpretations**, not simultaneously quantified

Analogy: First-order logic validity is "for all interpretations", but each interpretation has a **fixed signature**.

### 8.3 Objection: "What if we need to compare validity across T?"

**Response:** Option A enables this better:
```lean
theorem valid_preserved_under_embedding {T U : Type*}
    [LinearOrderedAddCommGroup T] [LinearOrderedAddCommGroup U]
    (f : T →+ U) (h_embed : Injective f) (φ : Formula) :
    @is_valid T _ φ → @is_valid U _ φ := ...
```

With Option B, this metatheorem is **impossible to state** because `is_valid` already quantifies over all types.

---

## 9. Conclusion

**Strong Recommendation: Implement Option A**

### 9.1 Key Rationale

1. **Technical Necessity:** Option B has fundamental type theory issues (nested quantification)
2. **Mathlib Alignment:** Option A matches established patterns in model theory
3. **Minimal Effort:** 35 minutes vs. 8.5-12.5 hours (potentially infinite if issues persist)
4. **Future-Proof:** Better extensibility for metatheory and integration
5. **Semantic Accuracy:** Matches JPL paper's intent more closely

### 9.2 Risk Assessment

**Option A Risks:**
- **Conceptual:** Users might initially think it's less general (**Severity: Low**, mitigated by documentation)
- **Implementation:** Mechanical changes might miss edge cases (**Severity: Very Low**, changes are deletions)

**Option B Risks:**
- **Technical:** May be impossible to complete (**Severity: Critical**)
- **Maintenance:** Universe constraints are fragile (**Severity: High**)
- **Cascading Errors:** Universe issues spread to dependent modules (**Severity: High**)

### 9.3 Next Steps

1. **Immediate:** Implement Option A following Section 7.1 (35 minutes)
2. **Verification:** Run full test suite (10 minutes)
3. **Documentation:** Update docstrings and ARCHITECTURE.md (20 minutes)
4. **Total Time:** ~1 hour to complete entire fix

### 9.4 Long-Term Impact

Option A positions Logos for:
- Clean integration with model checkers (specific temporal domains)
- Metatheorems about temporal structure embeddings
- Future layers (counterfactual, epistemic) with different temporal constraints
- Mathlib contribution (aligns with community standards)

---

## 10. Sources

- [Mathlib4 Model Theory: Satisfiability](https://leanprover-community.github.io/mathlib4_docs/Mathlib/ModelTheory/Satisfiability.html)
- [Lean 4 Reference Manual: Universes](https://lean-lang.org/doc/reference/latest/The-Type-System/Universes/)
- [Functional Programming in Lean: Universe Polymorphism](https://docs.lean-lang.org/functional_programming_in_lean/functor-applicative-monad/universes.html)
- JPL Paper "The Perpetuity Calculus of Agency" (app:TaskSemantics, def:frame, def:world-history)

---

**Report Prepared By:** Research Agent (Claude Code Framework)
**Review Status:** Ready for implementation decision
**Recommended Action:** Proceed with Option A immediately
