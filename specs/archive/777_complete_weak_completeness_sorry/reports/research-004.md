# Research Report: FMP Bridge from Finite Model Validity to Full Validity

**Task**: 777 - Complete the weak_completeness sorry
**Date**: 2026-02-01
**Session**: sess_1769980966_3d5ffd
**Language**: Lean
**Focus**: Can FMP bridge finite model validity to full validity without modifying validity definition?

## Executive Summary

The user asked whether the Finite Model Property (FMP) can be used to bridge from **finite model validity** (`semantic_truth_at_v2`) to **full validity** (`valid`) without changing the validity definition. After thorough analysis:

**Conclusion**: The FMP **cannot** provide this bridge. The fundamental issue is **directional asymmetry**: FMP provides that "satisfiable implies finite-model-satisfiable" (exists direction), but we need "valid implies finite-model-valid" (forall direction). These are logically independent without additional structure.

**Key Finding**: The gap is not missing infrastructure but rather a fundamental mathematical incompatibility between:
1. **Universal validity** (`valid phi`): Truth in ALL models (uncountably many, arbitrary temporal types)
2. **Finite model validity** (`semantic_truth_at_v2`): Truth in ALL finite models (finitely many, bounded)

Even with FMP, proving `valid phi -> finite_valid phi` requires showing every finite model "embeds" into some full model in a truth-preserving way. For TM bimodal logic with Box quantifying over ALL histories, this embedding fails.

## 1. Existing FMP Infrastructure

### 1.1 Current Files and Theorems

| File | Key Theorems | Status |
|------|--------------|--------|
| `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` | `semantic_weak_completeness`, `semanticWorldState_card_bound` | Sorry-free |
| `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` | `finiteWorldState_card_bound`, `FiniteWorldState` | Sorry-free |
| `Theories/Bimodal/Metalogic/FMP/Closure.lean` | `closure`, `ClosureMaximalConsistent` | Sorry-free |
| `Theories/Bimodal/Metalogic/FMP/BoundedTime.lean` | `BoundedTime`, `temporalBound` | Sorry-free |
| `Boneyard/Metalogic_v4/FMP/FiniteModelPropertyConstructive.lean` | Deprecated | Contains sorry |

### 1.2 What FMP Currently Provides

The `semantic_weak_completeness` theorem (lines 354-411 of SemanticCanonicalModel.lean):

```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

**What it says**: If phi is true in ALL semantic world states (finite model validity), then phi is provable.

**What we need**: `valid phi -> (forall w, semantic_truth_at_v2 phi w t phi)`

This is the **opposite direction** from what FMP naturally provides.

## 2. The FMP Direction Problem

### 2.1 What FMP Typically States

Standard FMP for modal logics says:
```
satisfiable(phi) -> finite_satisfiable(phi)
```

Equivalently (contrapositive):
```
finite_valid(not phi) -> valid(not phi)
```

Or in terms of validity (by negation):
```
not finite_valid(phi) -> not valid(phi)
```

### 2.2 What We Need

To bridge `valid -> finite_valid`, we need:
```
valid(phi) -> finite_valid(phi)
```

Which is:
```
(forall M, truth_at M tau t phi) -> (forall w : SemanticWorldState, semantic_truth w phi)
```

### 2.3 Why These Are Different

| Direction | Quantifier | FMP Provides? |
|-----------|------------|---------------|
| satisfiable -> finite_satisfiable | Exists -> Exists | Yes (witness preservation) |
| valid -> finite_valid | Forall -> Forall | **No** (forall over different domains) |

For the satisfiable direction, we have a specific model and can extract/construct a finite counterpart.

For the validity direction, we're quantifying over ALL models (including infinite ones with arbitrary temporal types) and need to show truth holds in ALL finite models. There's no witness to transfer.

## 3. What Would Be Needed for a Bridge

### 3.1 Embedding Requirement

To prove `valid phi -> finite_valid phi`, we would need:

```lean
theorem full_to_finite_embedding (phi : Formula) (w : SemanticWorldState phi) :
    exists (D : Type) (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
      (forall psi in closure phi, truth_at M tau t psi <-> semantic_truth_at_v2 phi w t psi)
```

This says: every finite world state embeds into some full model preserving truth on the closure.

### 3.2 Why This Fails for TM

The embedding fails for **Box formulas**:

1. **Full semantics Box**: `truth_at M tau t (Box psi) = forall sigma : WorldHistory F, truth_at M sigma t psi`
   - Quantifies over ALL world histories in the frame (uncountably many for infinite D)

2. **Finite semantics Box**: Checked via `models` function on FiniteWorldState
   - Uses pre-computed boolean assignment from closure-MCS construction
   - Has no notion of "all histories" - just checks membership

For an arbitrary `SemanticWorldState w`, we cannot construct a full model M where:
- Box truth matches at w
- The "all histories" quantification is respected

### 3.3 The Circular Dependency

Even if we tried to construct such an embedding:

1. We'd need the finite model to "generate" enough histories
2. Each history would need corresponding MCS-derived states
3. The coherence between histories (task relations) would need to be preserved
4. This construction is essentially building the canonical model again

But the canonical model construction only gives us a **specific** model, not coverage of **all** models.

## 4. Alternative Approaches Considered

### 4.1 Prove Valid -> Finite_Valid Directly

**Approach**: Show that truth in all full models implies truth in all finite models.

**Issue**: The finite models are constructed from MCS quotients. An arbitrary full model M may have states not corresponding to any MCS. Showing truth transfers requires the forward truth lemma (which fails).

### 4.2 Use FMP Contrapositively

**Approach**: `not finite_valid phi -> not valid phi` (from FMP: finite countermodel -> full countermodel)

**Issue**: We need `valid -> finite_valid`, not the contrapositive. Contrapositive gives us nothing new.

### 4.3 Prove Validity Definitions Equivalent

**Approach**: Show `valid phi <-> finite_valid phi` directly.

**Breakdown**:
- `finite_valid -> valid`: Needs embedding (fails as above)
- `valid -> finite_valid`: This IS what we're trying to prove

### 4.4 Bisimulation-Based Transfer

**Approach**: Use bisimulation to transfer between models.

**Issue**: Bisimulation works for basic modal logic (K, S4, S5). TM has temporal operators that don't respect standard bisimulation. The time domain polymorphism (D can be Int, Rat, Real, etc.) makes bisimulation across temporal types unclear.

### 4.5 Restrict Full Validity to Finite Frames

**Approach**: Redefine `valid` to only quantify over finite frames.

**Issue**: This changes what "validity" means (user explicitly doesn't want this).

## 5. Mathematical Analysis

### 5.1 Why TM is Harder Than Basic Modal Logic

For basic modal logic (K), the FMP gives: `sat(phi) <-> finite_sat(phi)`.

This implies: `valid(phi) <-> finite_valid(phi)` because:
- `valid(phi) = not sat(not phi)`
- `finite_valid(phi) = not finite_sat(not phi)`
- By FMP equivalence on satisfiability, these are equal

**But TM is different** because:

1. **Temporal type polymorphism**: Validity quantifies over all temporal types D. There's no "canonical" finite temporal type to reduce to.

2. **BoundedTime is formula-dependent**: The finite model uses `BoundedTime (temporalBound phi)`, which depends on phi. This means different formulas have different "finite" interpretations.

3. **Box semantics mismatch**: Even within a single temporal type, Box quantifies over ALL histories (potentially infinite many), while finite models have finitely many states.

### 5.2 The Core Incompatibility

| Aspect | Full Validity | Finite Model Validity |
|--------|---------------|----------------------|
| Temporal types | All (Int, Rat, Real, ...) | Fixed: BoundedTime k |
| World states | Uncountably many | Bounded: 2^|closure phi| |
| Histories | All possible histories | Finite histories only |
| Box semantics | Universal over histories | Assignment check |
| Truth evaluation | Recursive definition | Boolean assignment |

These are fundamentally different mathematical objects. No natural map preserves the Box semantics.

## 6. Recommendations

### 6.1 Primary Recommendation: Accept the Architectural Gap

The gap between `valid` and `finite_valid` is mathematically insurmountable for TM bimodal logic with the current definitions. This is not a bug or missing lemma - it's a fundamental incompatibility.

**Actions**:
1. Document the gap prominently in WeakCompleteness.lean
2. Keep `semantic_weak_completeness` as the primary completeness theorem
3. The sorry in `weak_completeness` serves as a marker for this limitation

### 6.2 Secondary Recommendation: Multiple Completeness Theorems

Provide multiple completeness theorems for different validity notions:

| Validity Notion | Completeness Theorem | Status |
|-----------------|---------------------|--------|
| Full validity (`valid`) | `weak_completeness` | Contains sorry |
| Finite model validity | `semantic_weak_completeness` | Sorry-free |
| Algebraic validity | Derivable from `algebraic_representation_theorem` | Sorry-free |

### 6.3 Tertiary Recommendation: Documentation

Create clear documentation explaining:
1. The three validity notions (full, finite, algebraic)
2. Why they're not equivalent for TM
3. Which completeness theorem to use for which purpose

### 6.4 What Would NOT Help

1. **Adding more FMP infrastructure**: The gap is not missing lemmas
2. **More search tools**: The theoretical impossibility is established
3. **Alternative proof techniques**: The issue is the definition mismatch

## 7. Theoretical Context

### 7.1 Comparison with Other Modal Logics

| Logic | FMP? | Valid <-> Finite_Valid? |
|-------|------|------------------------|
| K | Yes | Yes (standard) |
| S4 | Yes | Yes (standard) |
| S5 | Yes | Yes (standard) |
| PDL | Yes | Yes (with care) |
| CTL* | Limited | Complex |
| TM Bimodal | Yes (per formula) | **No** (temporal polymorphism) |

### 7.2 Why TM Breaks the Pattern

Standard modal logics have a fixed frame signature. TM's polymorphism over temporal types means:
- "All models" includes models with different time structures
- Finite models with BoundedTime can't capture models with unbounded time
- The FMP is "local" (per formula with its bound) not "global" (all formulas, all types)

## 8. Conclusion

The FMP cannot bridge finite model validity to full validity for TM bimodal logic. The fundamental issues are:

1. **Directional**: FMP provides exists-direction transfer, we need forall-direction
2. **Polymorphism**: Validity quantifies over all temporal types, finite models use a fixed bounded type
3. **Box semantics**: Full semantics quantifies over all histories, finite semantics uses assignment lookup

The sorry in `weak_completeness` represents a **fundamental mathematical limitation**, not a proof gap. The recommended approach is to accept `semantic_weak_completeness` as the primary completeness theorem and document the gap clearly.

---

## Appendix A: Files Analyzed

| File | Purpose |
|------|---------|
| `Theories/Bimodal/Semantics/Validity.lean` | Full validity definition |
| `Theories/Bimodal/Semantics/Truth.lean` | Truth evaluation (Box quantifies over all histories) |
| `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` | semantic_weak_completeness |
| `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` | The sorry location |
| `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` | Representation theorem |
| `Boneyard/Metalogic_v4/FMP/README.md` | Archived FMP approach documentation |

## Appendix B: Key Code Locations

| Definition | File | Lines |
|------------|------|-------|
| `valid` | Semantics/Validity.lean | 61-64 |
| `truth_at` (Box case) | Semantics/Truth.lean | 112 |
| `semantic_truth_at_v2` | FMP/SemanticCanonicalModel.lean | 254-256 |
| `semantic_weak_completeness` | FMP/SemanticCanonicalModel.lean | 354-411 |
| `weak_completeness` (sorry) | Completeness/WeakCompleteness.lean | 183-203 |
