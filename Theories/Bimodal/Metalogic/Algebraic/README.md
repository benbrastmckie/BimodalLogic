# Algebraic Representation Theorem

This directory contains an alternative algebraic approach to the representation theorem, independent from the seed-extension approach in `Representation/CoherentConstruction.lean`.

## Overview

The algebraic approach proves the representation theorem using Lindenbaum-Tarski algebra and ultrafilter theory, providing an independent verification path for completeness.

**Note**: This is an isolated, self-contained alternative. It does not modify or depend on the existing `Representation/` implementation and can be removed without affecting other metalogic code.

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `Algebraic.lean` | Module root, re-exports all components | Complete |
| `LindenbaumQuotient.lean` | Quotient by provable equivalence | Proven |
| `BooleanStructure.lean` | Boolean algebra instance | Has sorries |
| `InteriorOperators.lean` | G/H as interior operators | Partial |
| `UltrafilterMCS.lean` | Ultrafilter-MCS bijection | Has sorries |
| `AlgebraicRepresentation.lean` | Main representation theorem | Has sorries |

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

## Known Sorries

| Location | Description | Status |
|----------|-------------|--------|
| `BooleanStructure.lean` | Various Boolean algebra axioms | Pending propositional helpers |
| `InteriorOperators.lean` | Idempotence from 4-axiom | Partial |
| `UltrafilterMCS.lean` | Bijection completeness | Pending MCS helpers |
| `AlgebraicRepresentation.lean` | Main theorem | Depends on earlier phases |

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
