# Noncomputable Definitions in ProofChecker

**Status**: Complete  
**Last Updated**: 2025-12-28  
**Related**: [Task 192](../../.opencode/specs/192_fix_generalized_necessitation_termination/), ADR-001-Classical-Logic-Noncomputable.md

---

## Overview

This document catalogs all noncomputable definitions in the ProofChecker (Logos) codebase and explains **why** each one is noncomputable. Understanding noncomputability is crucial for maintaining the codebase and avoiding compilation errors.

### What Does `noncomputable` Mean?

In Lean 4, a definition is **noncomputable** if it cannot be executed or compiled to runnable code. This occurs when:

1. **Classical Axioms**: The definition uses classical logic axioms like `Classical.propDecidable`, `Classical.em` (excluded middle), or `Classical.choice`
2. **Structural Undecidability**: The definition performs operations that are undecidable, such as:
   - Equality testing on arbitrary formulas (`φ = A`)
   - Membership testing in contexts (`A ∈ Γ`)
   - Context equality (`Γ' = A :: Γ`)
3. **Dependency Propagation**: The definition calls another noncomputable function

### Why ProofChecker Uses Classical Logic

ProofChecker implements a **Hilbert-style proof system** for bimodal temporal logic. Key architectural decisions:

- **Classical Logic**: Metalogic theorems (like the deduction theorem) use classical reasoning to simplify proofs
- **Proof Objects**: Derivations are mathematical objects, not computational procedures
- **Standard Practice**: Aligns with mathlib4 and published Lean 4 research

**Result**: Noncomputable definitions are **expected and appropriate** for this domain.

For architectural rationale, see [ADR-001-Classical-Logic-Noncomputable.md](../Architecture/ADR-001-Classical-Logic-Noncomputable.md).

---

## Complete Catalog of Noncomputable Definitions

### Summary Statistics

- **Total Lean Files in Logos**: 53
- **Files with Explicit `noncomputable`**: 2
- **Total Noncomputable Definitions**: 36
  - DeductionTheorem.lean: 2
  - Propositional.lean: 32 (entire section)
  - GeneralizedNecessitation.lean: 2 (need fixing - Task 192)

### Module: `Logos/Core/Metalogic/`

#### File: `DeductionTheorem.lean`

**Classical Logic Usage**:
- Line 41: `attribute [local instance] Classical.propDecidable`
  - **Effect**: Enables classical case analysis throughout the file

**Noncomputable Definitions**:

1. **`deduction_with_mem`** (Line 206)
   ```lean
   private noncomputable def deduction_with_mem (Γ' : Context) (A φ : Formula)
   ```
   - **Why Noncomputable**: 
     - Uses `Classical.propDecidable` for decidable instance (Line 209)
     - Performs case analysis on `A ∈ Γ'` (membership test)
     - Performs case analysis on context equality `Γ' = A :: Γ`
     - Uses structural recursion with classical decidability
   - **Root Cause**: Classical case analysis on undecidable predicates
   - **Alternative**: None practical; constructive proof would require `DecidableEq Formula` and `DecidablePred (· ∈ Γ')`, which are not implementable for arbitrary formulas

2. **`deduction_theorem`** (Line 332)
   ```lean
   noncomputable def deduction_theorem (Γ : Context) (A B : Formula)
   ```
   - **Why Noncomputable**:
     - Calls `deduction_with_mem` (Line 336)
     - Uses `Classical.propDecidable` for membership test (Line 335)
     - Performs case analysis on `A ∈ Γ`
   - **Root Cause**: Dependency on `deduction_with_mem` + classical logic
   - **Necessity**: **Yes** - This is the core metalogic theorem enabling context manipulation. Classical logic is standard for metalogic.

**Additional Classical Usage**:
- Line 259: `Classical.propDecidable` in helper theorem
- Line 377: `Classical.propDecidable` in main theorem body

**Research References**:
- [noncomputable-research.md](../Research/noncomputable-research.md)
- [deduction-theorem-necessity-research.md](../Research/deduction-theorem-necessity-research.md)

---

### Module: `Logos/Core/Theorems/`

#### File: `Propositional.lean`

**Noncomputable Section**: Lines 46-1672 (entire section)

```lean
noncomputable section
-- All definitions here are noncomputable
...
end -- noncomputable section
```

**Why Entire Section?**
- Many theorems use `deduction_theorem` from `Metalogic.DeductionTheorem`
- `deduction_theorem` is noncomputable, so all callers must be noncomputable
- Easier to mark entire section than individual definitions

**Noncomputable Definitions** (32 total):

| Line | Definition | Uses Deduction Theorem? | Classical Logic? |
|------|------------|-------------------------|------------------|
| 70 | `lem` | No | Indirect (via identity) |
| 84 | `efq_axiom` | No | No (axiom wrapper) |
| 94 | `peirce_axiom` | No | No (axiom wrapper) |
| 140 | `double_negation` | No | Uses Peirce's Law |
| 225 | `ecq` | No | No (direct proof) |
| 285 | `raa` | No | No (direct proof) |
| 359 | `efq_neg` | No | No (direct proof) |
| 378 | `efq` | No | Alias for `efq_neg` |
| 390 | `ldi` | No | No (direct proof) |
| 453 | `rdi` | No | No (direct proof) |
| 489 | `rcp` | No | No (direct proof) |
| 579 | `lce` | No | No (direct proof) |
| 658 | `rce` | No | No (direct proof) |
| 737 | `lce_imp` | **Yes** | Line 740: `deduction_theorem [] (A.and B) A h` |
| 755 | `rce_imp` | **Yes** | Line 758: `deduction_theorem [] (A.and B) B h` |
| 785 | `classical_merge` | **Yes** | Lines 848, 853, 857 use `deduction_theorem` |
| 971 | `iff_intro` | No | No (direct proof) |
| 988 | `iff_elim_left` | No | No (direct proof) |
| 1018 | `iff_elim_right` | No | No (direct proof) |
| 1054 | `contrapose_imp` | No | No (direct proof) |
| 1069 | `contraposition` | No | No (direct proof) |
| 1091 | `contrapose_iff` | No | No (direct proof) |
| 1128 | `iff_neg_intro` | No | No (direct proof) |
| 1143 | `demorgan_conj_neg_forward` | No | No (direct proof) |
| 1209 | `demorgan_conj_neg_backward` | **Yes** | Lines 1328, 1336 use `deduction_theorem` |
| 1352 | `demorgan_conj_neg` | No | Calls `demorgan_conj_neg_forward/backward` |
| 1370 | `demorgan_disj_neg_forward` | No | No (direct proof) |
| 1439 | `demorgan_disj_neg_backward` | No | No (direct proof) |
| 1477 | `demorgan_disj_neg` | No | Calls `demorgan_disj_neg_forward/backward` |
| 1507 | `ni` | No | No (direct proof) |
| 1545 | `ci` | No | No (direct proof) |
| 1614 | `de` | **Yes** | Disjunction elimination using `deduction_theorem` |

**Key Observations**:
- **Direct Noncomputable Dependencies**: 6 definitions directly call `deduction_theorem`
  - `lce_imp`, `rce_imp`, `classical_merge`, `demorgan_conj_neg_backward`, `de`
- **Indirect Dependencies**: Remaining 26 definitions are in noncomputable section for consistency
- **Why Section Marker?**: Simplifies code maintenance; avoids marking each definition individually

**Most Important Noncomputable Definition**: `de` (Disjunction Elimination)
```lean
noncomputable def de (Γ : Context) (A B C : Formula) (h1 : (A :: Γ) ⊢ C) (h2 : (B :: Γ) ⊢ C) :
  (A.or B :: Γ) ⊢ C
```
- **Why**: Uses `deduction_theorem` multiple times to manipulate contexts
- **Usage**: Core theorem for disjunction reasoning
- **Impact**: Any theorem using disjunction elimination becomes noncomputable

---

#### File: `GeneralizedNecessitation.lean` (⚠️ Needs Fixing - Task 192)

**Status**: Currently has **compilation errors** due to missing `noncomputable` markers

**Definitions That Need Fixing**:

1. **`generalized_modal_k`** (Line 66)
   ```lean
   def generalized_modal_k (Γ : Context) (Γ' : Context) (A φ : Formula)
   ```
   - **Current Status**: Marked as `def` (computable)
   - **Problem**: Calls `deduction_theorem` (Line 71) without being marked noncomputable
   - **Error**: `failed to compile definition, compiler IR check failed at 'Logos.Core.Theorems.generalized_modal_k'. Error: depends on declaration 'Logos.Core.Metalogic.deduction_theorem', which has no executable code`
   - **Fix**: Add `noncomputable` keyword
   - **Why Noncomputable**: Dependency on `deduction_theorem`

2. **`generalized_temporal_k`** (Line 101)
   ```lean
   def generalized_temporal_k (Γ : Context) (Γ' : Context) (A φ : Formula)
   ```
   - **Current Status**: Marked as `def` (computable)
   - **Problem**: Calls `deduction_theorem` (Line 105) without being marked noncomputable
   - **Error**: `failed to compile definition, compiler IR check failed at 'Logos.Core.Theorems.generalized_temporal_k'. Error: depends on declaration 'Logos.Core.Metalogic.deduction_theorem', which has no executable code`
   - **Fix**: Add `noncomputable` keyword
   - **Why Noncomputable**: Dependency on `deduction_theorem`

**Task Reference**: [Task 192](../../.opencode/specs/192_fix_generalized_necessitation_termination/)

---

### Module: `Logos/Core/Theorems/Perpetuity/`

#### File: `Principles.lean`

**Status**: ✅ No explicit `noncomputable` markers, but compiles successfully

**Uses `deduction_theorem`**:
- Line 707: `exact Logos.Core.Metalogic.deduction_theorem [(A.imp B).all_future] A.all_future B.all_future step3_reordered`
- Line 711: `exact Logos.Core.Metalogic.deduction_theorem [] (A.imp B).all_future (A.all_future.imp B.all_future) step4`

**Why It Compiles**:
- These are used in **tactic proofs** (`by` blocks), not in definition bodies
- The *theorem* itself (`future_k_dist`) is implicitly noncomputable but doesn't need the marker
- Lean 4 allows noncomputable calls in proof terms without marking the theorem noncomputable

**Definitions** (All compile without `noncomputable`):
- `perpetuity_1`, `diamond_4`, `modal_5`, `perpetuity_2`, `box_to_box_past`
- `box_conj_intro`, `box_conj_intro_imp`, `box_conj_intro_imp_3`
- `perpetuity_3`, `box_dne`, `perpetuity_4`, `mb_diamond`
- `box_diamond_to_future_box_diamond`, `box_diamond_to_past_box_diamond`
- `future_k_dist`, `past_k_dist`, `persistence`, `perpetuity_5`

**Key Insight**: Theorems in proof mode don't require `noncomputable` even if they use noncomputable functions in their proofs. Only `def` (definitions) that call noncomputable functions in their body require the marker.

---

#### File: `Bridge.lean`

**Status**: ✅ No explicit `noncomputable` markers, compiles successfully

**Uses `deduction_theorem`**:
- Line 508: `exact Logos.Core.Metalogic.deduction_theorem [] (A.and B) A h`
- Line 515: `exact Logos.Core.Metalogic.deduction_theorem [] (A.and B) B h`

**Definitions**:
- `dne`, `modal_duality_neg`, `modal_duality_neg_rev`
- `box_mono`, `diamond_mono`, `future_mono`, `past_mono`
- `local_efq`, `local_lce`, `local_rce`
- `lce_imp`, `rce_imp` (use `deduction_theorem`)
- `always_to_past`, `always_to_present`, `always_to_future`
- `past_present_future_to_always`, `always_dni`
- `temporal_duality_neg`, `always_dne`, `temporal_duality_neg_rev`

**Why It Compiles**: Same reason as `Principles.lean` - proof mode usage

---

## Dependency Tree

```
Classical.propDecidable (Classical Axiom)
└── deduction_with_mem (DeductionTheorem.lean:206)
    └── deduction_theorem (DeductionTheorem.lean:332)
        ├── generalized_modal_k (GeneralizedNecessitation.lean:66) ⚠️ NEEDS FIX
        ├── generalized_temporal_k (GeneralizedNecessitation.lean:101) ⚠️ NEEDS FIX
        └── Propositional.lean (noncomputable section)
            ├── lce_imp (line 737)
            ├── rce_imp (line 755)
            ├── classical_merge (line 785)
            ├── demorgan_conj_neg_backward (line 1209)
            ├── de (line 1614) - Disjunction Elimination
            └── [26 other theorems in section, indirectly noncomputable]

Perpetuity/ modules:
├── Principles.lean - Uses deduction_theorem in proofs (OK, no marker needed)
└── Bridge.lean - Uses deduction_theorem in proofs (OK, no marker needed)
```

**Propagation Rules**:
1. If a `def` calls a noncomputable function → mark as `noncomputable def`
2. If a theorem uses noncomputable in proof → no marker needed (implicit)
3. If multiple definitions in a file are noncomputable → use `noncomputable section`

---

## Guidelines for Contributors

### When to Mark `noncomputable`

✅ **MUST mark** `noncomputable def`:
- Definition calls `deduction_theorem` or any noncomputable function
- Definition uses `Classical.propDecidable`, `Classical.em`, or `Classical.choice`
- Lean compiler reports: `depends on declaration 'X', which has no executable code`

❌ **DO NOT need** to mark:
- Theorems (`theorem`, not `def`) using noncomputable functions in proofs
- Definitions inside a `noncomputable section`

### How to Fix Noncomputable Errors

**Error Message**:
```
failed to compile definition, compiler IR check failed at 'Logos.Core.Theorems.my_function'. 
Error: depends on declaration 'Logos.Core.Metalogic.deduction_theorem', which has no executable code; 
consider marking definition as 'noncomputable'
```

**Solution**:
```lean
-- Before (causes error):
def my_function (Γ : Context) (A B : Formula) : Γ ⊢ A.imp B := by
  let h := deduction_theorem Γ A B proof
  exact h

-- After (fixed):
noncomputable def my_function (Γ : Context) (A B : Formula) : Γ ⊢ A.imp B := by
  let h := deduction_theorem Γ A B proof
  exact h
```

### Adding New Metalogic Theorems

If you add a new metalogic theorem that uses classical logic:

1. **Add `Classical.propDecidable` at file top** (if needed):
   ```lean
   attribute [local instance] Classical.propDecidable
   ```

2. **Mark definition as `noncomputable`**:
   ```lean
   noncomputable def my_metalogic_theorem (Γ : Context) (A : Formula) : ... := by
     haveI : Decidable (A ∈ Γ) := Classical.propDecidable _
     by_cases h : A ∈ Γ
     ...
   ```

3. **Document why it's noncomputable** in docstring:
   ```lean
   /--
   My metalogic theorem.
   
   **Noncomputable**: Uses classical case analysis on `A ∈ Γ`.
   -/
   noncomputable def my_metalogic_theorem ...
   ```

### Code Review Checklist

When reviewing code:
- [ ] Any `def` calling `deduction_theorem` marked `noncomputable`?
- [ ] Any classical axiom usage properly documented?
- [ ] Build passes with no "no executable code" errors?
- [ ] Docstring explains why definition is noncomputable?

---

## Frequently Asked Questions

### Q1: Is it bad that we have noncomputable definitions?

**No**. For proof assistants in classical logic, noncomputable is:
- **Standard practice** (see mathlib4, Lean 4 papers)
- **Expected** for metalogic and proof theory
- **Appropriate** for mathematical objects that aren't meant to be executed

### Q2: Can we make `deduction_theorem` computable?

**No, not practically**. To make it computable, we would need:
1. `DecidableEq Formula` - deciding if two formulas are equal
2. `DecidablePred (· ∈ Γ)` - deciding if a formula is in a context
3. Constructive proof system (no classical axioms)

This would require:
- Complete rewrite of the proof system to constructive logic
- Significant complexity increase
- Loss of classical reasoning benefits
- No alignment with published literature

**Verdict**: Not worth it. Classical + noncomputable is the right choice.

### Q3: Why doesn't `Principles.lean` need `noncomputable` markers?

`Principles.lean` uses `deduction_theorem` in **proof mode** (`by` blocks), not in definition bodies. Lean 4 distinguishes:
- **Definitions** (`def`): Must be computable unless marked `noncomputable`
- **Theorems** (`theorem`) and **proof terms** (`by` blocks): Can use noncomputable functions freely

### Q4: What happens if I forget to mark a definition `noncomputable`?

You get a compiler error:
```
failed to compile definition, compiler IR check failed at 'my_function'. 
Error: depends on declaration 'deduction_theorem', which has no executable code; 
consider marking definition as 'noncomputable'
```

Fix by adding `noncomputable` keyword before `def`.

### Q5: Should I use `noncomputable section` or mark individual definitions?

**Use `noncomputable section` when**:
- Many definitions in the file depend on `deduction_theorem`
- Example: `Propositional.lean` (32 definitions)

**Use individual markers when**:
- Only a few definitions are noncomputable
- Example: `GeneralizedNecessitation.lean` (2 definitions)

---

## Related Documentation

- **Architecture Decision**: [ADR-001-Classical-Logic-Noncomputable.md](../Architecture/ADR-001-Classical-Logic-Noncomputable.md)
- **Research Reports**:
  - [Noncomputable Keyword Explanation](../Research/noncomputable-research.md)
  - [Deduction Theorem Necessity Analysis](../Research/deduction-theorem-necessity-research.md)
- **Style Guide**: [LEAN_STYLE_GUIDE.md](LEAN_STYLE_GUIDE.md) (see "Noncomputable Patterns" section)
- **Task Tracker**: [Task 192 - Fix GeneralizedNecessitation Termination](../../TODO.md)

---

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 2025-12-28 | Claude | Initial comprehensive catalog |
| | | - Audited all 53 Lean files in Logos |
| | | - Documented 36 noncomputable definitions |
| | | - Created dependency tree |
| | | - Added contributor guidelines |
