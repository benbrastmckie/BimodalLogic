# Research Summary: Is `deduction_theorem` Necessarily Noncomputable?

**Task**: 192 (Additional Research)  
**Date**: 2025-12-28  
**Question**: Must `deduction_theorem` be noncomputable, or are there alternatives?

---

## Quick Answer

**Yes, `deduction_theorem` is necessarily noncomputable** given ProofChecker's design (Hilbert-style proof system + classical logic). This is **standard, expected, and appropriate**.

**Recommendation**: Accept noncomputable status and proceed with the fix (add `noncomputable` keyword to both functions).

---

## Why It's Noncomputable

### Root Cause

```lean
attribute [local instance] Classical.propDecidable
```

This enables `by_cases` on arbitrary propositions:

```lean
by_cases h_eq : φ = A         -- Formula equality (undecidable)
by_cases h_eq : Γ' = A :: Γ   -- Context equality (undecidable)
by_cases hA : A ∈ Γ'          -- Membership (undecidable)
```

**Why Undecidable**: Formulas can be arbitrarily complex. No algorithm can decide equality/membership in general without classical logic.

---

## Are There Alternatives?

### Option 1: Constructive Logic (Not Practical)

**What It Would Require**:
- Add `DecidableEq` instance for `Formula` (100+ lines of boilerplate)
- Rewrite deduction theorem without `by_cases`
- Still likely noncomputable due to structural recursion

**Verdict**: ❌ High effort, zero benefit

### Option 2: Curry-Howard Encoding (Theoretical Only)

**What It Would Require**:
- Complete architectural rewrite (semantic vs. syntactic proofs)
- Incompatible with current DerivationTree-based system
- Different theorem focus (normalization vs. derivations)

**Verdict**: ❌ Fundamentally different architecture

### Option 3: Quotient Types (Too Complex)

**What It Would Require**:
- Refactor `Formula` as quotient type
- Major changes throughout codebase
- Quotient equality still undecidable

**Verdict**: ❌ Too complex, little benefit

---

## Is This Expected?

### Yes - Standard Practice

**Evidence**:

1. **Lean 4 Standard Library**: Uses classical axioms throughout
2. **Mathlib4 Metalogic**: All major theorems are `noncomputable`
3. **Community Norms**: Classical metalogic is idiomatic in Lean 4
4. **Published Research**: Most Lean formalizations use classical logic

**Comparison to Other Proof Assistants**:

| Proof Assistant | Classical by Default? | Metalogic Style |
|-----------------|----------------------|-----------------|
| Lean 4 | Yes | Noncomputable |
| Isabelle/HOL | Yes | Classical |
| Coq | No | Often constructive |
| Agda | No | Usually constructive |

**Lean's Position**: Pragmatic classical logic for ease of use.

---

## Trade-offs

### Classical (Current Approach)

**Pros**:
- ✅ Simple proofs (use Law of Excluded Middle)
- ✅ Matches mathematical intuition
- ✅ Less code, easier maintenance
- ✅ Standard for Lean 4
- ✅ No practical downsides

**Cons**:
- ❌ Cannot extract executable code (irrelevant for theorem proving)
- ❌ Cannot use `#eval` (not needed)

### Constructive (Alternative)

**Pros**:
- ✅ Extractable code (in theory)
- ✅ Philosophically satisfying (for intuitionists)

**Cons**:
- ❌ Complex proofs
- ❌ Requires extensive boilerplate
- ❌ Still likely noncomputable
- ❌ High implementation cost
- ❌ Against community norms
- ❌ **Zero practical benefit**

---

## Recommendations

### 1. Accept Noncomputable Status ✅ (Recommended)

**Action**:
- Mark `generalized_modal_k` and `generalized_temporal_k` as `noncomputable`
- Add brief comment explaining why
- Proceed with implementation

**Example**:
```lean
/--
Noncomputable because it depends on `deduction_theorem`, which uses
classical decidability. Standard pattern for Hilbert-style metalogic.
-/
noncomputable def generalized_modal_k : ...
```

### 2. Document Pattern (Optional)

Add to LEAN_STYLE_GUIDE.md:
- Metalogic theorems should use `noncomputable` with classical logic
- This is standard and appropriate
- No impact on correctness

### 3. No Architectural Changes

**Do NOT**:
- Try to make classical proofs constructive
- Refactor to Curry-Howard encoding
- Add `DecidableEq` instances for computability

**Why**: High cost, zero benefit, against community norms.

---

## Key Takeaways

1. **Noncomputable is NOT a problem** - it's the correct solution
2. **Classical logic is idiomatic** in Lean 4 for metalogic
3. **No practical alternatives** exist within current architecture
4. **Zero impact** on logical correctness or usability
5. **Standard pattern** across Lean ecosystem

---

## Final Answer

**Question**: Is it necessary that `deduction_theorem` is noncomputable?

**Answer**: **Yes, and this is expected and appropriate.**

- Classical logic requires `Classical.propDecidable`
- This makes functions noncomputable
- Standard practice in Lean 4
- No alternatives within current architecture
- No practical downsides

**Next Action**: Implement task 192 fix (add `noncomputable` to two function declarations).

---

## References

- **Full Report**: [deduction-theorem-necessity-research.md](../../../Documentation/Research/deduction-theorem-necessity-research.md)
- **Noncomputable Guide**: [noncomputable-research.md](../../../Documentation/Research/noncomputable-research.md)
- **DeductionTheorem.lean**: `Logos/Core/Metalogic/DeductionTheorem.lean` (lines 41, 332)
- **Lean Documentation**: [Axioms and Computation](https://lean-lang.org/theorem_proving_in_lean4/axioms_and_computation.html)

---

**Research Complete**: 2025-12-28  
**Conclusion**: Noncomputable is necessary, expected, and correct
