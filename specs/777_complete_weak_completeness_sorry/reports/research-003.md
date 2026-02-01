# Research Report: Algebraic Approach to Weak Completeness

**Task**: 777 - Complete the weak_completeness sorry
**Date**: 2026-02-01
**Session**: sess_1769980439_a246e1
**Language**: Lean
**Focus**: What would it take to advance the algebraic approach far enough to establish full weak completeness?

## Executive Summary

The algebraic infrastructure in `Theories/Bimodal/Metalogic/Algebraic/` is **substantial and well-developed**, but suffers from the **same fundamental gap** as the canonical model approach. The gap is not missing lemmas but rather a fundamental incompatibility between:

1. **Universal validity** (`valid phi`): Truth in ALL models at ALL times in ALL histories
2. **Algebraic validity** (`[phi] = top` or equivalently `AlgSatisfiable phi.neg = False`): A quotient class property

The bridge lemma `valid phi -> [phi.neg] not-in any ultrafilter` requires the **forward truth lemma**, which fails because Box semantics quantifies over ALL histories while ultrafilters encode ONE consistent theory.

**Conclusion**: The algebraic approach cannot fix the completeness gap without changing the validity definition or Box semantics.

## 1. Current Algebraic Infrastructure

### 1.1 File Structure

```
Theories/Bimodal/Metalogic/Algebraic/
├── Algebraic.lean               (umbrella import)
├── LindenbaumQuotient.lean      (quotient construction)
├── BooleanStructure.lean        (Boolean algebra instance)
├── InteriorOperators.lean       (G, H, Box as interior operators)
├── UltrafilterMCS.lean          (ultrafilter-MCS bijection)
└── AlgebraicRepresentation.lean (main representation theorem)
```

### 1.2 Key Definitions

| Definition | Location | Type |
|------------|----------|------|
| `ProvEquiv phi psi` | LindenbaumQuotient.lean:50 | `Derives phi psi /\ Derives psi phi` |
| `LindenbaumAlg` | LindenbaumQuotient.lean:119 | `Quotient provEquivSetoid` |
| `toQuot phi` | LindenbaumQuotient.lean:124 | `Formula -> LindenbaumAlg` |
| `Ultrafilter alpha` | UltrafilterMCS.lean:38 | Custom structure (proper filter, complete) |
| `AlgConsistent phi` | AlgebraicRepresentation.lean:59 | `not Nonempty (DT [] phi.neg)` |
| `AlgSatisfiable phi` | AlgebraicRepresentation.lean:64 | `exists U : AlgWorld, algTrueAt U phi` |
| `AlgWorld` | AlgebraicRepresentation.lean:43 | `Ultrafilter LindenbaumAlg` |
| `algTrueAt U phi` | AlgebraicRepresentation.lean:50 | `toQuot phi in U.carrier` |

### 1.3 Main Theorems Proven

| Theorem | Statement | Status |
|---------|-----------|--------|
| `algebraic_representation_theorem` | `AlgSatisfiable phi <-> AlgConsistent phi` | **Proven (sorry-free)** |
| `consistent_implies_satisfiable` | `AlgConsistent phi -> AlgSatisfiable phi` | Proven |
| `satisfiable_implies_consistent` | `AlgSatisfiable phi -> AlgConsistent phi` | Proven |
| `mcs_ultrafilter_correspondence` | Bijection between MCS and ultrafilters | Proven |
| `G_interior`, `H_interior`, `box_interior` | G, H, Box are interior operators | Proven |
| Boolean algebra on `LindenbaumAlg` | Full `BooleanAlgebra` instance | Proven |

### 1.4 Infrastructure Quality Assessment

**Strengths**:
- Complete Boolean algebra structure with all lattice operations
- Ultrafilter definition is well-formulated
- MCS-ultrafilter bijection is fully proven (both directions + inverses)
- Interior operator properties for all three modalities
- Congruence properties for all logical operations

**Infrastructure is NOT the gap** - all the algebraic machinery is in place and working.

## 2. The Algebraic Validity Gap

### 2.1 What Would Be Needed

To prove `valid phi -> ContextDerivable [] phi` via algebra, we would need:

```lean
-- The gap lemma
theorem valid_implies_alg_not_satisfiable_neg (phi : Formula) :
    valid phi -> not (AlgSatisfiable phi.neg)
```

Which is equivalent to:

```lean
-- Forward direction: validity to ultrafilter exclusion
theorem valid_implies_neg_not_in_ultrafilter (phi : Formula) :
    valid phi -> forall U : AlgWorld, toQuot phi.neg not-in U.carrier
```

### 2.2 Why This Fails

**The Gap Analysis**:

1. **What `valid phi` means**:
   - For ALL temporal types D
   - For ALL task frames F
   - For ALL models M
   - For ALL world histories tau
   - For ALL times t
   - `truth_at M tau t phi` holds

2. **What `toQuot phi.neg not-in U` means**:
   - In the quotient algebra, `[not-phi]` is not in ultrafilter U
   - Equivalently, `[phi] in U` (by ultrafilter completeness)
   - This is a statement about ONE algebraic object

3. **The Bridge Requires**:
   - Showing truth in ALL models implies a quotient class property
   - This is the same forward truth lemma problem:
     - `truth_at M tau t phi` (recursive evaluation)
     - implies `[phi] in U` (membership in algebraic structure)

4. **Box is the Problem** (same as canonical model approach):
   - `truth_at M tau t (Box psi)` = `psi` true at ALL histories (universal quantification)
   - `[Box psi] in U` = membership in ONE ultrafilter (local property)
   - Cannot derive the local property from the universal one

### 2.3 Precise Statement of Missing Lemma

The **exact** theorem that would need to be proven (and cannot be):

```lean
-- IMPOSSIBLE: Validity-to-Algebraic Bridge
theorem valid_to_alg_bridge (phi : Formula) :
    valid phi -> toQuot phi = top

-- Equivalently (contrapositive of representation)
theorem valid_to_alg_bridge' (phi : Formula) :
    valid phi -> not (AlgSatisfiable phi.neg)
```

**Why it's impossible**:

Consider `phi = Box psi`. Assume `valid (Box psi)`.

- This means: for all D, F, M, tau, t, `truth_at M tau t (Box psi)`
- Which means: for all D, F, M, tau, t, and for all histories sigma, `truth_at M sigma t psi`
- We need to show: `toQuot (Box psi) = top`
- Which means: `Derives (bot.imp bot) (Box psi)`, i.e., `|- Box psi`

But the inference from "true in all models" to "provable" is exactly weak completeness - what we're trying to prove! This is circular.

## 3. Comparison with Canonical Model Approach

| Aspect | Canonical Model | Algebraic |
|--------|-----------------|-----------|
| **World construction** | MCS indexed by time | Ultrafilters of Lindenbaum algebra |
| **Truth definition** | MCS membership | Ultrafilter membership |
| **Working direction** | Consistent -> Satisfiable | Consistent -> Satisfiable |
| **Broken direction** | Valid -> MCS membership | Valid -> Quotient = top |
| **Root cause** | Box over ALL histories | Same |
| **Sorries needed** | 2 (temporal boundary) | 0 (representation theorem) |

**Key insight**: The algebraic approach has FEWER sorries for the representation theorem but faces the SAME gap for connecting to universal validity.

## 4. What Would Fix This?

### Option A: Redefine Validity Algebraically

```lean
-- New definition
def alg_valid (phi : Formula) : Prop := toQuot phi = top

-- Completeness becomes trivial
theorem alg_completeness (phi : Formula) : alg_valid phi -> |- phi := by
  intro h
  -- toQuot phi = top means [phi] = [top]
  -- Which means ProvEquiv phi (bot.imp bot)
  -- Which means |- top -> phi (since |- top)
  -- Therefore |- phi
  sorry -- Actually provable from h
```

**Problem**: This changes what "validity" means. It's validity in the Lindenbaum algebra, not validity in all Kripke models.

### Option B: Prove Universal and Algebraic Validity Coincide

This requires a representation theorem in the opposite direction:

```lean
-- Would need: Every model arises from an ultrafilter
theorem model_from_ultrafilter :
    forall (D : Type) (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    exists (U : AlgWorld), forall psi, truth_at M tau t psi <-> algTrueAt U psi
```

**Problem**: This is essentially Jonsson-Tarski representation for TM semantics, and it fails because:
- A model M has states indexed by histories
- An ultrafilter is a single maximal consistent theory
- Cannot encode "all histories" in one ultrafilter

### Option C: Restrict Universal Validity

Define validity over "algebraically definable" frames:

```lean
def alg_definable_valid (phi : Formula) : Prop :=
  forall U : AlgWorld, algTrueAt U phi

-- Then algebraic completeness holds
theorem alg_def_completeness (phi : Formula) :
    alg_definable_valid phi -> |- phi := by
  intro h
  by_contra h_not
  -- If not provable, then neg phi is consistent
  -- By representation theorem, exists U with neg phi in U
  -- But alg_definable_valid says phi is in all U
  -- Contradiction since ultrafilters exclude complements
  ...
```

**Problem**: This weakens the theorem statement. It's completeness with respect to algebraic models, not Kripke models.

## 5. Mathlib Resources

### 5.1 Relevant Mathlib Structures

| Mathlib | Description | Relevance |
|---------|-------------|-----------|
| `BoolAlg` | Bundled Boolean algebras | Category structure available |
| `Ultrafilter alpha` | Mathlib ultrafilter | Different from project's; uses Filter API |
| `ultrafilterBasis` | Stone space topology | Could help with topological representation |
| `isDenseEmbedding_pure` | Principal ultrafilter embedding | Stone representation basis |

### 5.2 Missing from Mathlib

- Modal logic algebraic semantics (Jonsson-Tarski for modal algebras)
- Closure algebra / interior algebra definitions
- Representation theorems connecting modal algebras to Kripke frames

### 5.3 Potential Mathlib Imports

The project could potentially use:
- `Mathlib.Topology.UltrafilterSpace` for Stone space topology
- `Mathlib.Order.Filter.Ultrafilter` for alternative ultrafilter definition
- `Mathlib.Order.BooleanAlgebra.Defs` (already imported)

However, these would not resolve the fundamental gap.

## 6. Precise Requirements for Full Completeness

To prove `valid phi -> |- phi` via algebraic methods, one would need **exactly one** of:

### Requirement 1: Forward Truth Bridge
```lean
theorem forward_bridge (phi : Formula) (U : AlgWorld) :
    (forall D F M tau t, truth_at M tau t phi) -> algTrueAt U phi
```
**Status**: Impossible due to Box quantifying over all histories

### Requirement 2: Model Generation
```lean
theorem ultrafilter_generates_model (U : AlgWorld) :
    exists D F M tau t,
      forall psi, algTrueAt U psi <-> truth_at M tau t psi
```
**Status**: Possible for some U, but not the correspondence needed

### Requirement 3: Restrict Validity Definition
```lean
def restricted_valid (phi : Formula) : Prop :=
    forall U : AlgWorld, algTrueAt U phi
```
**Status**: Changes theorem statement

### Requirement 4: Weaken Box Semantics
```lean
-- Only quantify over "reachable" histories
def weak_truth_at M tau t (Box psi) :=
    forall sigma in ReachableHistories M tau, truth_at M sigma t psi
```
**Status**: Changes the logic itself

## 7. Recommendations

### Primary Recommendation: Document and Accept

The algebraic infrastructure is excellent and provides:
1. `AlgSatisfiable phi <-> AlgConsistent phi` (representation theorem)
2. Full Boolean algebra structure
3. Interior operators for modalities
4. Ultrafilter-MCS bijection

**Use algebraic completeness** as an alternative completeness result:
```lean
-- This IS provable and useful
theorem alg_completeness (phi : Formula) :
    (forall U : AlgWorld, algTrueAt U phi) -> |- phi
```

### Secondary Recommendation: Separate Validity Notions

Document that TM bimodal logic has multiple natural notions of validity:
1. **Universal Kripke validity** (`valid`): Truth in all models
2. **Finite model validity** (`finite_valid`): Truth in bounded models
3. **Algebraic validity** (`alg_valid`): [phi] = top in Lindenbaum algebra

Each has a completeness theorem:
- Universal: Sorry (gap documented)
- Finite model: `semantic_weak_completeness` (proven)
- Algebraic: Derivable from representation theorem (provable)

### Tertiary Recommendation: Future Research

For future exploration:
1. **Investigate alternative Box semantics** that might close the gap
2. **Study temporal algebra literature** for specialized representation theorems
3. **Consider game semantics** as alternative characterization

## 8. Conclusion

The algebraic approach to weak completeness faces the **same fundamental gap** as the canonical model approach. The issue is not missing infrastructure - the Lindenbaum algebra, Boolean structure, and ultrafilter correspondence are all fully developed.

The gap is **inherent** in the definition of TM Box semantics:
- Box quantifies over ALL world histories (uncountably many)
- Algebraic structures (ultrafilters, MCS) encode ONE consistent theory
- No finite algebraic structure can capture "all histories"

**The sorry in `weak_completeness` cannot be eliminated** by advancing the algebraic approach. The alternatives are:
1. Accept `semantic_weak_completeness` (finite model validity)
2. Accept algebraic completeness (algebraic validity)
3. Change the validity definition or Box semantics

---

## Appendix A: Key Code Locations

| Component | File | Lines |
|-----------|------|-------|
| `valid` definition | `Semantics/Validity.lean` | 61-64 |
| `AlgSatisfiable` | `Algebraic/AlgebraicRepresentation.lean` | 64 |
| `algebraic_representation_theorem` | `Algebraic/AlgebraicRepresentation.lean` | 180-182 |
| `mcs_ultrafilter_correspondence` | `Algebraic/UltrafilterMCS.lean` | 768-880 |
| `BooleanAlgebra LindenbaumAlg` | `Algebraic/BooleanStructure.lean` | 431-449 |
| `weak_completeness` sorry | `Completeness/WeakCompleteness.lean` | 183-203 |

## Appendix B: Search Queries Performed

- `lean_local_search "valid"` - Found validity-related theorems
- `lean_local_search "alg"` - Found algebraic representation theorems
- `lean_local_search "Lindenbaum"` - Found LindenbaumAlg definition
- `lean_leanfinder "Stone representation theorem ultrafilter Boolean algebra"` - Mathlib ultrafilter structures
- `lean_loogle "Ultrafilter ?a -> BooleanAlgebra"` - No direct results
