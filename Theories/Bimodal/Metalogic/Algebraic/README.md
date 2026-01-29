# Algebraic Representation Theorem

This directory contains an alternative algebraic approach to the representation theorem, independent from the seed-extension approach in `Representation/CoherentConstruction.lean`.

## Overview

The algebraic approach proves the representation theorem using Lindenbaum-Tarski algebra and ultrafilter theory, providing an independent verification path for completeness.

**Note**: This is an isolated, self-contained alternative. It does not modify or depend on the existing `Representation/` implementation and can be removed without affecting other metalogic code.

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `Algebraic.lean` | Module root, re-exports all components | Complete |
| `LindenbaumQuotient.lean` | Quotient by provable equivalence | **Proven** |
| `BooleanStructure.lean` | Boolean algebra instance | **Proven** |
| `InteriorOperators.lean` | G/H as interior operators | **Proven** |
| `UltrafilterMCS.lean` | Ultrafilter-MCS bijection | **Proven** |
| `AlgebraicRepresentation.lean` | Main representation theorem | **Proven** |
| `AlgebraicSemanticBridge.lean` | Bridge to standard Kripke semantics | Has sorries (modal/temporal) |
| `HybridCompleteness.lean` | Hybrid algebraic + FMP completeness path | Has 1 sorry (truth lemma gap) |

## Key Definitions

### Lindenbaum Quotient (`LindenbaumQuotient.lean`)

```lean
def ProvEquiv (phi psi : Formula) : Prop := Derives phi psi /\ Derives psi phi
def LindenbaumAlg : Type := Quotient ProvEquiv.setoid
```

The Lindenbaum-Tarski algebra is the quotient of formulas by provable equivalence.

### Boolean Structure (`BooleanStructure.lean`)

```lean
instance : BooleanAlgebra LindenbaumAlg where
  -- Order: [phi] <= [psi] <-> derives phi psi
  -- Operations: [phi] ⊔ [psi] = [phi ∨ psi], etc.
```

The quotient forms a Boolean algebra with order defined by derivability.

### Interior Operators (`InteriorOperators.lean`)

```lean
structure InteriorOp (alpha : Type*) [PartialOrder alpha] where
  toFun : alpha -> alpha
  le_self : forall a, toFun a <= a         -- Deflationary
  monotone : forall a b, a <= b -> toFun a <= toFun b
  idempotent : forall a, toFun (toFun a) = toFun a
```

G and H are shown to be interior operators using the T and 4 axioms.

### Ultrafilter-MCS Correspondence (`UltrafilterMCS.lean`)

```lean
structure Ultrafilter (alpha : Type*) [BooleanAlgebra alpha] where
  carrier : Set alpha
  -- Ultrafilter axioms

def mcs_to_ultrafilter : SetMaximalConsistent S -> Ultrafilter LindenbaumAlg
def ultrafilter_to_mcs : Ultrafilter LindenbaumAlg -> Set Formula
```

Establishes the bijection between ultrafilters of the Lindenbaum algebra and maximal consistent sets.

## Mathematical Overview

The algebraic approach proceeds as follows:

1. **Lindenbaum-Tarski Algebra**: Define provable equivalence `phi ~ psi <-> derives phi <-> psi` and form the quotient `LindenbaumAlg := Formula / ~`

2. **Boolean Structure**: Show `LindenbaumAlg` is a `BooleanAlgebra` where:
   - Order: `[phi] <= [psi] <-> derives phi -> psi`
   - Operations: `[phi] ⊔ [psi] = [phi ∨ psi]`, `[phi] ⊓ [psi] = [phi ∧ psi]`, etc.

3. **Interior Operators**: Show G and H are interior operators:
   - Deflationary: `G[phi] <= [phi]` (from T-axiom `G phi -> phi`)
   - Monotone: `[phi] <= [psi] -> G[phi] <= G[psi]` (from K-distribution)
   - Idempotent: `G(G[phi]) = G[phi]` (from 4-axiom `G phi -> GG phi`)

4. **Ultrafilter-MCS Correspondence**: Establish bijection between:
   - Ultrafilters of `LindenbaumAlg`
   - Maximal consistent sets

5. **Representation Theorem**: Prove satisfiability via ultrafilters:
   - `satisfiable phi <-> not (derives neg phi)`

## Design Principles

- **Isolated**: All code in `Algebraic/` - can be removed without affecting existing code
- **Self-contained**: Does not modify existing metalogic files
- **Alternative path**: Provides independent proof, not replacement

## Current State (Updated 2026-01-29)

The core algebraic modules are now **sorry-free**:
- `LindenbaumQuotient.lean` - Complete
- `BooleanStructure.lean` - Complete
- `InteriorOperators.lean` - Complete
- `UltrafilterMCS.lean` - Complete
- `AlgebraicRepresentation.lean` - Complete

### Completeness Paths

**1. Existing sorry-free path** (`FMP/SemanticCanonicalModel.lean`):
```lean
semantic_weak_completeness : (forall w, semantic_truth_at_v2 phi w) -> derives phi
```
This works by contrapositive - constructing a countermodel when phi is not provable.

**2. Hybrid path** (`HybridCompleteness.lean`):
```lean
hybrid_weak_completeness : valid phi -> derives phi
```
This connects algebraic consistency to FMP via:
```
not-provable -> AlgConsistent phi.neg -> ultrafilter U -> MCS Gamma -> closure MCS -> FMP countermodel
```
The remaining sorry is in connecting `valid phi` (truth at ALL models) to `semantic_truth_at_v2` (truth in specific model).

### Remaining Sorry Analysis

| Location | Description | Root Cause |
|----------|-------------|------------|
| `AlgebraicSemanticBridge.lean` | Box/temporal cases in truth lemma | Box quantifies over ALL histories; single ultrafilter insufficient |
| `HybridCompleteness.lean` | `valid_implies_semantic_truth` | Forward truth lemma gap: recursive truth != assignment check |

**Key insight**: The gap is in proving that `truth_at` (recursive evaluation, especially for box) matches `semantic_truth_at_v2` (boolean assignment check). For MCS-derived states, this SHOULD hold, but proving it requires showing the model IS the canonical model, which is circular.

## Dependencies

- Mathlib: `BooleanAlgebra`, `Ultrafilter`, `ClosureOperator`
- ProofChecker: `Bimodal.ProofSystem`, `Bimodal.Metalogic.Core`

## Related Files

- `../Representation/README.md` - Primary representation theorem (seed-extension approach)
- `../Core/README.md` - MCS foundations shared by both approaches
- `../README.md` - Overall metalogic architecture

## References

- Modal Logic, Blackburn et al., Chapter 5 (Algebraic Semantics)
- Research report: algebraic representation approach documentation

---

*Last updated: 2026-01-29*
