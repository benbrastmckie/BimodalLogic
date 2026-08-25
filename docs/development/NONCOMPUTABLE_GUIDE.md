# Noncomputable Definitions in ProofChecker

**Status**: Complete  
**Last Updated**: 2025-12-28  
**Related**: ADR-001-Classical-Logic-Noncomputable.md

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

For architectural rationale, see [ADR-001-Classical-Logic-Noncomputable.md](../architecture/ADR-001-Classical-Logic-Noncomputable.md).

---

## Complete Catalog of Noncomputable Definitions

### Summary Statistics

- **Total Lean Files in Logos**: 53
- **Files with Explicit `noncomputable`**: 2
- **Total Noncomputable Definitions**: 36
  - DeductionTheorem.lean: 2
  - Propositional.lean: 32 (entire section)
  - GeneralizedNecessitation.lean: 2 (need fixing - Task 192)

### Module: `FormalSystem/Metalogic/`

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

2. **`deductionTheorem`** (Line 332)
   ```lean
   noncomputable def deductionTheorem (Γ : Context) (A B : Formula)
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
- [NONCOMPUTABLE.md](../research/NONCOMPUTABLE.md)
- [DEDUCTION_THEOREM_NECESSITY.md](../research/DEDUCTION_THEOREM_NECESSITY.md)

---

### Module: `FormalSystem/Theorems/`

#### File: `Propositional.lean`

**Noncomputable Section**: Lines 46-1672 (entire section)

```lean
noncomputable section
-- All definitions here are noncomputable
...
end -- noncomputable section
```

**Why Entire Section?**
- Many theorems use `deductionTheorem` from `Metalogic.DeductionTheorem`
- `deductionTheorem` is noncomputable, so all callers must be noncomputable
- Easier to mark entire section than individual definitions

**Noncomputable Definitions** (32 total):

| Line | Definition | Uses Deduction Theorem? | Classical Logic? |
|------|------------|-------------------------|------------------|
| 70 | `em` | No | Indirect (via identity) |
| 84 | `efqAxiom` | No | No (axiom wrapper) |
| 94 | `peirceAxiom` | No | No (axiom wrapper) |
| 140 | `doubleNegation` | No | Uses Peirce's Law |
| 225 | `botOfAndNeg` | No | No (direct proof) |
| 285 | `impNegImp` | No | No (direct proof) |
| 359 | `impOfNeg` | No | No (direct proof) |
| 378 | `negImp` | No | Alias for `impOfNeg` |
| 390 | `orInl` | No | No (direct proof) |
| 453 | `orInr` | No | No (direct proof) |
| 489 | `impOfNegImpNeg` | No | No (direct proof) |
| 579 | `andLeft` | No | No (direct proof) |
| 658 | `andRight` | No | No (direct proof) |
| 737 | `lceImp` | **Yes** | Line 740: `deductionTheorem [] (A.and B) A h` |
| 755 | `rceImp` | **Yes** | Line 758: `deductionTheorem [] (A.and B) B h` |
| 785 | `classicalMerge` | **Yes** | Lines 848, 853, 857 use `deductionTheorem` |
| 971 | `iffIntro` | No | No (direct proof) |
| 988 | `iffElimLeft` | No | No (direct proof) |
| 1018 | `iffElimRight` | No | No (direct proof) |
| 1054 | `contraposeImp` | No | No (direct proof) |
| 1069 | `contraposition` | No | No (direct proof) |
| 1091 | `contraposeIff` | No | No (direct proof) |
| 1128 | `iffNegIntro` | No | No (direct proof) |
| 1143 | `demorganConjNegForward` | No | No (direct proof) |
| 1209 | `demorganConjNegBackward` | **Yes** | Lines 1328, 1336 use `deductionTheorem` |
| 1352 | `demorganConjNeg` | No | Calls `demorganConjNegForward/backward` |
| 1370 | `demorganDisjNegForward` | No | No (direct proof) |
| 1439 | `demorganDisjNegBackward` | No | No (direct proof) |
| 1477 | `demorganDisjNeg` | No | Calls `demorganDisjNegForward/backward` |
| 1507 | `ni` | No | No (direct proof) |
| 1545 | `ci` | No | No (direct proof) |
| 1614 | `de` | **Yes** | Disjunction elimination using `deductionTheorem` |

**Key Observations**:
- **Direct Noncomputable Dependencies**: 6 definitions directly call `deductionTheorem`
  - `lceImp`, `rceImp`, `classicalMerge`, `demorganConjNegBackward`, `de`
- **Indirect Dependencies**: Remaining 26 definitions are in noncomputable section for consistency
- **Why Section Marker?**: Simplifies code maintenance; avoids marking each definition individually

**Most Important Noncomputable Definition**: `de` (Disjunction Elimination)
```lean
noncomputable def de (Γ : Context) (A B C : Formula) (h1 : (A :: Γ) ⊢ C) (h2 : (B :: Γ) ⊢ C) :
  (A.or B :: Γ) ⊢ C
```
- **Why**: Uses `deductionTheorem` multiple times to manipulate contexts
- **Usage**: Core theorem for disjunction reasoning
- **Impact**: Any theorem using disjunction elimination becomes noncomputable

---

#### File: `GeneralizedNecessitation.lean` (⚠️ Needs Fixing - Task 192)

**Status**: Currently has **compilation errors** due to missing `noncomputable` markers

**Definitions That Need Fixing**:

1. **`generalizedModalK`** (Line 66)
   ```lean
   def generalizedModalK (Γ : Context) (Γ' : Context) (A φ : Formula)
   ```
   - **Current Status**: Marked as `def` (computable)
   - **Problem**: Calls `deductionTheorem` (Line 71) without being marked noncomputable
   - **Error**: `failed to compile definition, compiler IR check failed at 'FormalSystem.Theorems.generalized_modal_k'. Error: depends on declaration 'FormalSystem.Metalogic.Core.deduction_theorem', which has no executable code`
   - **Fix**: Add `noncomputable` keyword
   - **Why Noncomputable**: Dependency on `deductionTheorem`

2. **`generalizedTemporalK`** (Line 101)
   ```lean
   def generalizedTemporalK (Γ : Context) (Γ' : Context) (A φ : Formula)
   ```
   - **Current Status**: Marked as `def` (computable)
   - **Problem**: Calls `deductionTheorem` (Line 105) without being marked noncomputable
   - **Error**: `failed to compile definition, compiler IR check failed at 'FormalSystem.Theorems.generalized_temporal_k'. Error: depends on declaration 'FormalSystem.Metalogic.Core.deduction_theorem', which has no executable code`
   - **Fix**: Add `noncomputable` keyword
   - **Why Noncomputable**: Dependency on `deductionTheorem`

---

### Module: `FormalSystem/Theorems/Perpetuity/`

#### File: `Principles.lean`

**Status**: ✅ No explicit `noncomputable` markers, but compiles successfully

**Uses `deductionTheorem`**:
- Line 707: `exact FormalSystem.Metalogic.Core.deductionTheorem [(A.imp B).allFuture] A.allFuture B.allFuture step3_reordered`
- Line 711: `exact FormalSystem.Metalogic.Core.deductionTheorem [] (A.imp B).allFuture (A.allFuture.imp B.allFuture) step4`

**Why It Compiles**:
- These are used in **tactic proofs** (`by` blocks), not in definition bodies
- The *theorem* itself (`futureKDist`) is implicitly noncomputable but doesn't need the marker
- Lean 4 allows noncomputable calls in proof terms without marking the theorem noncomputable

**Definitions** (All compile without `noncomputable`):
- `perpetuity_1`, `diamond4`, `modal5`, `perpetuity_2`, `boxToBoxPast`
- `boxConjIntro`, `boxConjIntroImp`, `boxConjIntroImp3`
- `perpetuity3`, `boxDne`, `perpetuity4`, `mbDiamond`
- `boxDiamondToFutureBoxDiamond`, `boxDiamondToPastBoxDiamond`
- `futureKDist`, `pastKDist`, `persistence`, `perpetuity5`

**Key Insight**: Theorems in proof mode don't require `noncomputable` even if they use noncomputable functions in their proofs. Only `def` (definitions) that call noncomputable functions in their body require the marker.

---

#### File: `Bridge.lean`

**Status**: ✅ No explicit `noncomputable` markers, compiles successfully

**Uses `deductionTheorem`**:
- Line 508: `exact FormalSystem.Metalogic.Core.deductionTheorem [] (A.and B) A h`
- Line 515: `exact FormalSystem.Metalogic.Core.deductionTheorem [] (A.and B) B h`

**Definitions**:
- `dne`, `modalDualityNeg`, `modalDualityNegRev`
- `boxMono`, `diamondMono`, `futureMono`, `pastMono`
- `local_efq`, `local_lce`, `local_rce`
- `lceImp`, `rceImp` (use `deductionTheorem`)
- `alwaysToPast`, `alwaysToPresent`, `alwaysToFuture`
- `pastPresentFutureToAlways`, `alwaysDni`
- `temporalDualityNeg`, `alwaysDne`, `temporalDualityNegRev`

**Why It Compiles**: Same reason as `Principles.lean` - proof mode usage

---

## Dependency Tree

```
Classical.propDecidable (Classical Axiom)
└── deduction_with_mem (DeductionTheorem.lean:206)
    └── deductionTheorem (DeductionTheorem.lean:332)
        ├── generalizedModalK (GeneralizedNecessitation.lean:66) ⚠️ NEEDS FIX
        ├── generalizedTemporalK (GeneralizedNecessitation.lean:101) ⚠️ NEEDS FIX
        └── Propositional.lean (noncomputable section)
            ├── lceImp (line 737)
            ├── rceImp (line 755)
            ├── classicalMerge (line 785)
            ├── demorganConjNegBackward (line 1209)
            ├── de (line 1614) - Disjunction Elimination
            └── [26 other theorems in section, indirectly noncomputable]

Perpetuity/ modules:
├── Principles.lean - Uses deductionTheorem in proofs (OK, no marker needed)
└── Bridge.lean - Uses deductionTheorem in proofs (OK, no marker needed)
```

**Propagation Rules**:
1. If a `def` calls a noncomputable function → mark as `noncomputable def`
2. If a theorem uses noncomputable in proof → no marker needed (implicit)
3. If multiple definitions in a file are noncomputable → use `noncomputable section`

---

## Guidelines for Contributors

### When to Mark `noncomputable`

✅ **MUST mark** `noncomputable def`:
- Definition calls `deductionTheorem` or any noncomputable function
- Definition uses `Classical.propDecidable`, `Classical.em`, or `Classical.choice`
- Lean compiler reports: `depends on declaration 'X', which has no executable code`

❌ **DO NOT need** to mark:
- Theorems (`theorem`, not `def`) using noncomputable functions in proofs
- Definitions inside a `noncomputable section`

### How to Fix Noncomputable Errors

**Error Message**:
```
failed to compile definition, compiler IR check failed at 'FormalSystem.Theorems.my_function'. 
Error: depends on declaration 'FormalSystem.Metalogic.Core.deduction_theorem', which has no executable code; 
consider marking definition as 'noncomputable'
```

**Solution**:
```lean
-- Before (causes error):
def my_function (Γ : Context) (A B : Formula) : Γ ⊢ A.imp B := by
  let h := deductionTheorem Γ A B proof
  exact h

-- After (fixed):
noncomputable def my_function (Γ : Context) (A B : Formula) : Γ ⊢ A.imp B := by
  let h := deductionTheorem Γ A B proof
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
- [ ] Any `def` calling `deductionTheorem` marked `noncomputable`?
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

### Q2: Can we make `deductionTheorem` computable?

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

`Principles.lean` uses `deductionTheorem` in **proof mode** (`by` blocks), not in definition bodies. Lean 4 distinguishes:
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
- Many definitions in the file depend on `deductionTheorem`
- Example: `Propositional.lean` (32 definitions)

**Use individual markers when**:
- Only a few definitions are noncomputable
- Example: `GeneralizedNecessitation.lean` (2 definitions)

---

## Related Documentation

- **Architecture Decision**: [ADR-001-Classical-Logic-Noncomputable.md](../architecture/ADR-001-Classical-Logic-Noncomputable.md)
- **Research Reports**:
  - [Noncomputable Keyword Explanation](../research/NONCOMPUTABLE.md)
  - [Deduction Theorem Necessity Analysis](../research/DEDUCTION_THEOREM_NECESSITY.md)
- **Style Guide**: [LEAN_STYLE_GUIDE.md](LEAN_STYLE_GUIDE.md) (see "Noncomputable Patterns" section)
- **Task Tracker**: [specs/TODO.md](../../specs/TODO.md)

---

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 2025-12-28 | Claude | Initial comprehensive catalog |
| | | - Audited all 53 Lean files in Logos |
| | | - Documented 36 noncomputable definitions |
| | | - Created dependency tree |
| | | - Added contributor guidelines |
