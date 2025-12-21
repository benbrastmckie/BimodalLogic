# Loogle Search Results: adjust

**Search Query**: "adjust"
**Date**: Sun Dec 21 2025
**Matches Found**: 21

## Search Summary

- Total matches: 21
- Mathlib matches: 14
- Std matches: 2
- Lean core matches: 2
- Other libraries: 3

## All Matches

### Mathlib Functions

#### 1. **Module.Basis.adjustToOrientation**
- **Type**: `{R : Type u_1} [CommRing R] [LinearOrder R] [IsStrictOrderedRing R] {M : Type u_2} [AddCommGroup M] [Module R M] {ι : Type u_3} [Fintype ι] [DecidableEq ι] [Nonempty ι] (e : Module.Basis ι R M) (x : Orientation R M ι) : Module.Basis ι R M`
- **Module**: `Mathlib.LinearAlgebra.Orientation`
- **Library**: Mathlib
- **Description**: Given a basis and an orientation, return a basis giving that orientation: either the original basis, or one constructed by negating a single (arbitrary) basis vector.

#### 2. **Module.Basis.orientation_adjustToOrientation**
- **Type**: `{R : Type u_1} [CommRing R] [LinearOrder R] [IsStrictOrderedRing R] {M : Type u_2} [AddCommGroup M] [Module R M] {ι : Type u_3} [Fintype ι] [DecidableEq ι] [Nonempty ι] (e : Module.Basis ι R M) (x : Orientation R M ι) : (e.adjustToOrientation x).orientation = x`
- **Module**: `Mathlib.LinearAlgebra.Orientation`
- **Library**: Mathlib
- **Description**: `adjust_to_orientation` gives a basis with the required orientation.

#### 3. **Module.Basis.adjustToOrientation.congr_simp**
- **Type**: `{R : Type u_1} [CommRing R] [LinearOrder R] [IsStrictOrderedRing R] {M : Type u_2} [AddCommGroup M] [Module R M] {ι : Type u_3} [Fintype ι] [DecidableEq ι] [Nonempty ι] (e e✝ : Module.Basis ι R M) (e_e : e = e✝) (x x✝ : Orientation R M ι) (e_x : x = x✝) : e.adjustToOrientation x = e✝.adjustToOrientation x✝`
- **Module**: `Mathlib.LinearAlgebra.Orientation`
- **Library**: Mathlib
- **Description**: None provided

#### 4. **Module.Basis.adjustToOrientation_apply_eq_or_eq_neg**
- **Type**: `{R : Type u_1} [CommRing R] [LinearOrder R] [IsStrictOrderedRing R] {M : Type u_2} [AddCommGroup M] [Module R M] {ι : Type u_3} [Fintype ι] [DecidableEq ι] [Nonempty ι] (e : Module.Basis ι R M) (x : Orientation R M ι) (i : ι) : (e.adjustToOrientation x) i = e i ∨ (e.adjustToOrientation x) i = -e i`
- **Module**: `Mathlib.LinearAlgebra.Orientation`
- **Library**: Mathlib
- **Description**: Every basis vector from `adjust_to_orientation` is either that from the original basis or its negation.

#### 5. **Module.Basis.det_adjustToOrientation**
- **Type**: `{R : Type u_1} [CommRing R] [LinearOrder R] [IsStrictOrderedRing R] {M : Type u_2} [AddCommGroup M] [Module R M] {ι : Type u_3} [Fintype ι] [DecidableEq ι] [Nonempty ι] (e : Module.Basis ι R M) (x : Orientation R M ι) : (e.adjustToOrientation x).det = e.det ∨ (e.adjustToOrientation x).det = -e.det`
- **Module**: `Mathlib.LinearAlgebra.Orientation`
- **Library**: Mathlib
- **Description**: None provided

#### 6. **Module.Basis.abs_det_adjustToOrientation**
- **Type**: `{R : Type u_1} [CommRing R] [LinearOrder R] [IsStrictOrderedRing R] {M : Type u_2} [AddCommGroup M] [Module R M] {ι : Type u_3} [Fintype ι] [DecidableEq ι] [Nonempty ι] (e : Module.Basis ι R M) (x : Orientation R M ι) (v : ι → M) : |(e.adjustToOrientation x).det v| = |e.det v|`
- **Module**: `Mathlib.LinearAlgebra.Orientation`
- **Library**: Mathlib
- **Description**: None provided

#### 7. **Module.Basis.adjustToOrientation.eq_1**
- **Type**: `{R : Type u_1} [CommRing R] [LinearOrder R] [IsStrictOrderedRing R] {M : Type u_2} [AddCommGroup M] [Module R M] {ι : Type u_3} [Fintype ι] [DecidableEq ι] [Nonempty ι] (e : Module.Basis ι R M) (x : Orientation R M ι) : e.adjustToOrientation x = if e.orientation = x then e else e.unitsSMul (Function.update 1 (Classical.arbitrary ι) (-1))`
- **Module**: `Mathlib.LinearAlgebra.Orientation`
- **Library**: Mathlib
- **Description**: None provided

#### 8. **OrthonormalBasis.adjustToOrientation**
- **Type**: `{E : Type u_1} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {ι : Type u_2} [Fintype ι] [DecidableEq ι] (e : OrthonormalBasis ι ℝ E) (x : Orientation ℝ E ι) [Nonempty ι] : OrthonormalBasis ι ℝ E`
- **Module**: `Mathlib.Analysis.InnerProductSpace.Orientation`
- **Library**: Mathlib
- **Description**: Given an orthonormal basis and an orientation, return an orthonormal basis giving that orientation: either the original basis, or one constructed by negating a single (arbitrary) basis vector.

#### 9. **OrthonormalBasis.orientation_adjustToOrientation**
- **Type**: `{E : Type u_1} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {ι : Type u_2} [Fintype ι] [DecidableEq ι] (e : OrthonormalBasis ι ℝ E) (x : Orientation ℝ E ι) [Nonempty ι] : (e.adjustToOrientation x).toBasis.orientation = x`
- **Module**: `Mathlib.Analysis.InnerProductSpace.Orientation`
- **Library**: Mathlib
- **Description**: `adjustToOrientation` gives an orthonormal basis with the required orientation.

#### 10. **OrthonormalBasis.toBasis_adjustToOrientation**
- **Type**: `{E : Type u_1} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {ι : Type u_2} [Fintype ι] [DecidableEq ι] (e : OrthonormalBasis ι ℝ E) (x : Orientation ℝ E ι) [Nonempty ι] : (e.adjustToOrientation x).toBasis = e.toBasis.adjustToOrientation x`
- **Module**: `Mathlib.Analysis.InnerProductSpace.Orientation`
- **Library**: Mathlib
- **Description**: None provided

#### 11. **OrthonormalBasis.adjustToOrientation_apply_eq_or_eq_neg**
- **Type**: `{E : Type u_1} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {ι : Type u_2} [Fintype ι] [DecidableEq ι] (e : OrthonormalBasis ι ℝ E) (x : Orientation ℝ E ι) [Nonempty ι] (i : ι) : (e.adjustToOrientation x) i = e i ∨ (e.adjustToOrientation x) i = -e i`
- **Module**: `Mathlib.Analysis.InnerProductSpace.Orientation`
- **Library**: Mathlib
- **Description**: Every basis vector from `adjustToOrientation` is either that from the original basis or its negation.

#### 12. **OrthonormalBasis.orthonormal_adjustToOrientation**
- **Type**: `{E : Type u_1} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {ι : Type u_2} [Fintype ι] [DecidableEq ι] (e : OrthonormalBasis ι ℝ E) (x : Orientation ℝ E ι) [Nonempty ι] : Orthonormal ℝ ⇑(e.toBasis.adjustToOrientation x)`
- **Module**: `Mathlib.Analysis.InnerProductSpace.Orientation`
- **Library**: Mathlib
- **Description**: `OrthonormalBasis.adjustToOrientation`, applied to an orthonormal basis, preserves the property of orthonormality.

#### 13. **OrthonormalBasis.adjustToOrientation.congr_simp**
- **Type**: `{E : Type u_1} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {ι : Type u_2} [Fintype ι] [DecidableEq ι] (e e✝ : OrthonormalBasis ι ℝ E) (e_e : e = e✝) (x x✝ : Orientation ℝ E ι) (e_x : x = x✝) [Nonempty ι] : e.adjustToOrientation x = e✝.adjustToOrientation x✝`
- **Module**: `Mathlib.Analysis.InnerProductSpace.Orientation`
- **Library**: Mathlib
- **Description**: None provided

#### 14. **OrthonormalBasis.abs_det_adjustToOrientation**
- **Type**: `{E : Type u_1} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {ι : Type u_2} [Fintype ι] [DecidableEq ι] (e : OrthonormalBasis ι ℝ E) (x : Orientation ℝ E ι) [Nonempty ι] (v : ι → E) : |(e.adjustToOrientation x).toBasis.det v| = |e.adjustToOrientation x).toBasis.det v|`
- **Module**: `Mathlib.Analysis.InnerProductSpace.Orientation`
- **Library**: Mathlib
- **Description**: None provided

#### 15. **OrthonormalBasis.det_adjustToOrientation**
- **Type**: `{E : Type u_1} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {ι : Type u_2} [Fintype ι] [DecidableEq ι] (e : OrthonormalBasis ι ℝ E) (x : Orientation ℝ E ι) [Nonempty ι] : (e.adjustToOrientation x).toBasis.det = e.toBasis.det ∨ (e.adjustToOrientation x).toBasis.det = -e.toBasis.det`
- **Module**: `Mathlib.Analysis.InnerProductSpace.Orientation`
- **Library**: Mathlib
- **Description**: None provided

#### 16. **Ordnode.adjustWith**
- **Type**: `{α : Type u_1} [LE α] [DecidableLE α] (f : α → α) (x : α) : Ordnode α → Ordnode α`
- **Module**: `Mathlib.Data.Ordmap.Ordnode`
- **Library**: Mathlib
- **Description**: O(log n). Modify an element in the set with the given function, doing nothing if the key is not found. Note that the element returned by `f` must be equivalent to `x`. Examples: `adjustWith f 0 {1, 2, 3} = {1, 2, 3}`, `adjustWith f 1 {1, 2, 3} = {f 1, 2, 3}`. Using a preorder on `ℕ × ℕ` that only compares the first coordinate: `adjustWith f (1, 1) {(0, 1), (1, 2)} = {(0, 1), f (1, 2)}`, `adjustWith f (3, 1) {(0, 1), (1, 2)} = {(0, 1), (1, 2)}`.

#### 17. **NumberField.mixedEmbedding.adjust_f**
- **Type**: `(K : Type u_1) [Field K] {f : NumberField.InfinitePlace K → NNReal} [NumberField K] {w₁ : NumberField.InfinitePlace K} (B : NNReal) (hf : ∀ (w : NumberField.InfinitePlace K), w ≠ w₁ → f w ≠ 0) : ∃ g, (∀ (w : NumberField.InfinitePlace K), w ≠ w₁ → g w = f w) ∧ ∏ w, g w ^ w.mult = B`
- **Module**: `Mathlib.NumberTheory.NumberField.CanonicalEmbedding.ConvexBody`
- **Library**: Mathlib
- **Description**: This is a technical result: quite often, we want to impose conditions at all infinite places but one and choose the value at the remaining place so that we can apply `exists_ne_zero_mem_ringOfIntegers_lt`.

### Std Library Functions

#### 18. **Std.DTreeMap.Internal.Impl.BalancedAtRoot.adjust_left**
- **Type**: `{l l' r : ℕ} : Std.DTreeMap.Internal.Impl.BalancedAtRoot l r → l - 1 ≤ l' → l' ≤ l + 1 → Std.DTreeMap.Internal.Impl.BalanceLErasePrecond l' r ∨ Std.DTreeMap.Internal.Impl.BalanceLErasePrecond r l'`
- **Module**: `Std.Data.DTreeMap.Internal.Balancing`
- **Library**: Std
- **Description**: None provided

#### 19. **Std.DTreeMap.Internal.Impl.BalancedAtRoot.adjust_right**
- **Type**: `{l r r' : ℕ} : Std.DTreeMap.Internal.Impl.BalancedAtRoot l r → r - 1 ≤ r' → r' ≤ r + 1 → Std.DTreeMap.Internal.Impl.BalanceLErasePrecond l r' ∨ Std.DTreeMap.Internal.Impl.BalanceLErasePrecond r' l`
- **Module**: `Std.Data.DTreeMap.Internal.Balancing`
- **Library**: Std
- **Description**: None provided

### Lean Core Functions

#### 20. **Lean.OLeanLevel.adjustFileName**
- **Type**: `(base : System.FilePath) : Lean.OLeanLevel → System.FilePath`
- **Module**: `Lean.Environment`
- **Library**: Lean
- **Description**: None provided

#### 21. **Lean.trace.profiler.threshold.unitAdjusted**
- **Type**: `(o : Lean.Options) : Float`
- **Module**: `Lean.Util.Trace`
- **Library**: Lean
- **Description**: None provided

## Usage Recommendations

### For Data Structure Manipulation

**Ordnode.adjustWith** (`Mathlib.Data.Ordmap.Ordnode`) is the most relevant function for general-purpose data structure updates:
- Provides O(log n) modification of elements in ordered sets/maps
- Applies a function to modify an element in place
- Preserves ordering invariants (the modified element must be equivalent to the original)
- Useful for implementing functional updates to balanced tree structures

### For Linear Algebra and Orientation

The **adjustToOrientation** family of functions (in `Mathlib.LinearAlgebra.Orientation` and `Mathlib.Analysis.InnerProductSpace.Orientation`) provide:
- Basis adjustment to match a desired orientation
- Preservation of orthonormality properties
- Determinant and absolute determinant invariants
- Two main variants:
  - `Module.Basis.adjustToOrientation` for general bases
  - `OrthonormalBasis.adjustToOrientation` for orthonormal bases

### For Tree Balancing (Internal)

The **adjust_left** and **adjust_right** functions in Std's DTreeMap are internal implementation details for:
- Maintaining balance invariants during tree erasure operations
- Should not typically be used directly by end users

### For Number Theory (Specialized)

**NumberField.mixedEmbedding.adjust_f** is a highly specialized function for:
- Number field embeddings
- Adjusting functions across infinite places
- Technical lemmas in algebraic number theory

## Common Patterns

### Pattern 1: Orientation Adjustment
Functions that take a basis/structure and an orientation, returning a modified version that matches the orientation:
```lean
adjustToOrientation : Basis → Orientation → Basis
```

### Pattern 2: In-Place Modification
Functions that apply a transformation function to a specific element in a data structure:
```lean
adjustWith : (α → α) → α → Structure α → Structure α
```

### Pattern 3: Balance Adjustment (Internal)
Functions that adjust balance predicates after structural changes:
```lean
adjust_left/adjust_right : BalancedAtRoot → Preconditions → BalancePrecond
```

### Pattern 4: Path/Configuration Adjustment
Functions that modify file paths or configuration values:
```lean
adjustFileName : FilePath → Level → FilePath
unitAdjusted : Options → Float
```

## Key Observations

1. **Mathlib dominates**: 14 out of 21 functions (67%) are from Mathlib, showing its comprehensive coverage
2. **Orientation is a major theme**: 15 functions relate to basis orientation adjustment
3. **Data structure support**: Limited to `Ordnode.adjustWith` for general-purpose use
4. **No direct List.adjust**: Interestingly, there's no `List.adjust` function, which might be expected
5. **Internal vs. External**: Many functions are internal implementation details (DTreeMap balancing) rather than user-facing APIs

## Potential Gaps

Based on this search, ProofChecker might benefit from:
- A general `List.adjust` function for list element modification
- Array/vector adjustment functions
- More general functional update patterns for custom data structures
