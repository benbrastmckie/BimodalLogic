# Algebraic Representation Infrastructure

**Status**: Active -- Contains the primary completeness path via deterministic chains

This directory contains:
1. An algebraic approach to the representation theorem using Lindenbaum-Tarski algebra and ultrafilter theory
2. The parametric truth lemma and representation infrastructure
3. The deterministic chain construction (primary completeness path)
4. The deprecated dovetailed chain construction (architecturally blocked)

## Purpose

The algebraic modules provide:
1. An alternative verification path for completeness via Boolean algebra theory
2. Infrastructure for Stone duality and algebraic topology extensions
3. A cleaner mathematical foundation for future algebraic modal logic research

**Note**: The main completeness proof uses `Bundle/` (BFMCS). This algebraic path is
supplementary infrastructure, not required for the current proof architecture.

## Modules

### Boolean Algebra Foundation
| Module | Purpose | Status |
|--------|---------|--------|
| `Algebraic.lean` | Module root, re-exports all components | Complete |
| `LindenbaumQuotient.lean` | Quotient by provable equivalence | **Sorry-free** |
| `BooleanStructure.lean` | Boolean algebra instance | **Sorry-free** |
| `InteriorOperators.lean` | G/H as interior operators | **Sorry-free** |
| `TenseS5Algebra.lean` | Tense S5 algebra structure | **Sorry-free** |
| `UltrafilterMCS.lean` | Ultrafilter-MCS bijection | **Sorry-free** |
| `AlgebraicRepresentation.lean` | Main representation theorem | **Sorry-free** |

### Parametric Infrastructure
| Module | Purpose | Status |
|--------|---------|--------|
| `UltrafilterChain.lean` | Ultrafilter chain construction | **Sorry-free** |
| `ParametricHistory.lean` | Parametric history infrastructure | **Sorry-free** |
| `ParametricTruthLemma.lean` | Parametric truth lemma | **Sorry-free** |
| `ParametricRepresentation.lean` | Parametric representation theorem | **Sorry-free** |
| `ParametricCanonical.lean` | Parametric canonical model | **Sorry-free** |
| `RestrictedTruthLemma.lean` | Restricted truth lemma | **Sorry-free** |

### Chain Constructions
| Module | Purpose | Status |
|--------|---------|--------|
| `DeterministicChain.lean` | Deterministic chain construction | **Sorry-free** |
| `DeterministicFMCS.lean` | FMCS/BFMCS bundle + completeness wiring | **4 sorries** (see below) |
| `FiniteDeferral.lean` | Finite deferral infrastructure for forward_F | In progress |
| `DovetailedChain.lean` | Dovetailed chain (deprecated) | **DEPRECATED** |

### Sorry Status (DeterministicFMCS.lean)

4 sorries remain, all depending on two leaf lemmas:
- `deterministic_forward_F` -- intra-family F witness (leaf)
- `deterministic_backward_P` -- intra-family P witness (leaf)
- forward Until in `usc` -- depends on `forward_F`
- forward Since in `usc` -- depends on `backward_P`

## Dependency Flowchart

```
Boolean Algebra Path:

                LindenbaumQuotient
                         │
            ┌────────────┼────────────┐
            v            v            v
    BooleanStructure  InteriorOps  TenseS5Algebra
            │            │
            └────────────┤
                         v
              UltrafilterMCS
                         │
                         v
           AlgebraicRepresentation

Completeness Path:

    UltrafilterChain ──> ParametricHistory ──> ParametricTruthLemma
                                                        │
                                                        v
                                              ParametricRepresentation
                                                        │
                              DeterministicChain ───────>│
                                                        v
                                              DeterministicFMCS
                                                        │
                                    FiniteDeferral ────>│
                                                        v
                                              (Completeness wiring)
```

## Key Definitions

### Lindenbaum Quotient (`LindenbaumQuotient.lean`)

```lean
def ProvEquiv (phi psi : Formula) : Prop := Derives phi psi ∧ Derives psi phi
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
  le_self : ∀ a, toFun a <= a         -- Deflationary
  monotone : ∀ a b, a <= b -> toFun a <= toFun b
  idempotent : ∀ a, toFun (toFun a) = toFun a
```

G and H are shown to be interior operators using the T and 4 axioms.

### Ultrafilter-MCS Correspondence (`UltrafilterMCS.lean`)

```lean
def mcsToUltrafilter : SetMaximalConsistent S -> Ultrafilter LindenbaumAlg
def ultrafilterToSet : Ultrafilter LindenbaumAlg -> Set Formula
theorem SetMaximalConsistent.ultrafilter_correspondence : -- Bijection
```

Establishes the bijection between ultrafilters of the Lindenbaum algebra and maximal
consistent sets.

## Mathematical Overview

The algebraic approach proceeds as follows:

1. **Lindenbaum-Tarski Algebra**: Define provable equivalence `phi ~ psi <-> derives phi <-> psi`
   and form the quotient `LindenbaumAlg := Formula / ~`

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

5. **Representation Theorem**: Prove satisfiability via ultrafilters

## Relationship to Main Proof Path

The main completeness proof architecture uses:
- `Core/` - MCS foundations (shared)
- `Bundle/` - BFMCS completeness via bundled MCS families

This algebraic path provides:
- Independent verification that MCS theory is sound
- Alternative route from consistency to satisfiability
- Foundation for future Stone duality extensions

## Future Extension Opportunities

1. **Stone Duality**: Connect ultrafilters to points of Stone space
2. **Algebraic Topology**: Extend interior operators to topological semantics
3. **Coalgebraic Methods**: Duality with canonical coalgebra structures
4. **Alternative Completeness**: Finish algebraic completeness path if desired

## Dependencies

- **Mathlib**: `BooleanAlgebra`, `Quotient`, `Filter`
- **ProofChecker**: `Bimodal.ProofSystem`, `Bimodal.Metalogic.Core`

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Core README](../Core/README.md) - MCS foundations shared by both approaches
- [Bundle README](../Bundle/README.md) - Primary BFMCS completeness approach
- [Decidability README](../Decidability/README.md) - Decision procedure

## References

- Modal Logic, Blackburn et al., Chapter 5 (Algebraic Semantics)
- Stone Duality: Boolean Algebras and Topological Spaces

---

*Last updated: 2026-04-06*
