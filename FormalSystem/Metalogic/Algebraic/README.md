# Algebraic Representation Infrastructure

**Status**: Active, on two different footings. `FlowFrame.lean` is infrastructure consumed by
the live completeness proof. The Boolean-algebra/ultrafilter layer (`LindenbaumQuotient.lean`,
`BooleanStructure.lean`, `InteriorOperators.lean`, `UltrafilterMCS.lean`) is standalone
sorry-free infrastructure with **no current consumer**; it is covered by `lake build` because
`Metalogic.lean` imports the sibling aggregator `../Algebraic.lean`.

This directory contains:
1. An algebraic approach to the representation theorem using Lindenbaum-Tarski algebra and ultrafilter theory
2. The generic flow-frame countermodel engine (`FlowFrame.lean`) and the re-hosted dense truth lemma
3. Boolean-algebra and ultrafilter foundations shared with `Core/`

The deterministic and dovetailed chain constructions that this directory once hosted are
**archived** to `Boneyard/ChainCompleteness/`; see the Chain Constructions table below.

## Purpose

The algebraic modules provide:
1. An alternative verification path for completeness via Boolean algebra theory
2. Infrastructure for Stone duality and algebraic topology extensions
3. A cleaner mathematical foundation for future algebraic modal logic research

**Note**: `BXCanonical/` is the wired completeness entry point, and **`FlowFrame.lean` is not
optional relative to it** — but that claim is about that one file, not about this directory as a
whole. `Algebraic.FlowFrame` has six live importers, and they are not all under `BXCanonical/`:
`BXCanonical/Completeness.lean`, `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`,
`BXCanonical/Chronicle/ChronicleMonadicBridge.lean` and `BXCanonical/DiscreteCarrierProbe.lean`,
plus `Bundle/LimitMCS.lean` and `WeakCanonical/GroupModel/CountermodelBase.lean`. That one file
is therefore part of the live proof, not merely adjacent to it.

The other four modules do stand beside it: they have no consumer anywhere in the live tree.
They are compiled by `lake build` (via the sibling aggregator, imported from `Metalogic.lean`),
not depended on by any proof. See [Metalogic README](../README.md) for the route diagram.

## Modules

The directory holds **5 `.lean` files, 2,887 lines**: `BooleanStructure.lean` (441),
`FlowFrame.lean` (806), `InteriorOperators.lean` (176), `LindenbaumQuotient.lean` (393), and
`UltrafilterMCS.lean` (1,071). Rows below that name any other file describe **archived** modules
under `Boneyard/` and are labelled as such.

### Boolean Algebra Foundation
| Module | Purpose | Status |
|--------|---------|--------|
| `../Algebraic.lean` | Re-export module for the Algebraic package. **Sibling aggregator**, at `FormalSystem/Metalogic/Algebraic.lean` — not a file inside this directory | Complete |
| `LindenbaumQuotient.lean` | Quotient by provable equivalence | **Sorry-free** |
| `BooleanStructure.lean` | Boolean algebra instance | **Sorry-free** |
| `InteriorOperators.lean` | Box as interior operator; H monotonicity | **Sorry-free** |
| `TenseS5Algebra.lean` | Tense S5 algebra structure | **Archived** (3 sorries; moved to `Boneyard/UltrafilterFrame/`) |
| `UltrafilterMCS.lean` | Ultrafilter-MCS bijection | **Sorry-free** |

### Ultrafilter Frame Infrastructure (Archived to `Boneyard/UltrafilterFrame/`)
| Module | Purpose | Status |
|--------|---------|--------|
| `UltrafilterFrame.lean` | R_G/R_H/R_Box, UltrafilterChain, F/P resolution | **Archived** (2 sorries for temp_4) |

### Flow-Frame Countermodel Engine
| Module | Purpose | Status |
|--------|---------|--------|
| `FlowFrame.lean` | Generic multi-family flow frame, four-axiom conformance + totality layer, bundle flow frame/model, re-hosted dense truth lemma | **Sorry-free** |

The former parametric canonical stack (`ParametricHistory`/`ParametricTruthLemma`/
`ParametricCanonical`/`ParametricCompleteness`/`RestrictedParametricTruthLemma`) is deleted:
its frame violated the frame definition's *Limit* axiom over dense duration types, and its
truth lemma is re-hosted on `bundleFlowFrame` in `FlowFrame.lean`.

### Chain Constructions (Archived to Boneyard/ChainCompleteness)
| Module | Purpose | Status |
|--------|---------|--------|
| `DeterministicChain.lean` | Deterministic chain construction | **Archived** |
| `DeterministicFMCS.lean` | FMCS/BFMCS bundle + completeness wiring | **Archived** |
| `FiniteDeferral.lean` | Finite deferral infrastructure for forward_F | **Archived** |

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
           (ultrafilter representation; no completeness theorem is stated here)

Completeness Path (current):

    FlowFrame (generic frame + conformance + totality)
        │
        v
    FlowFrame (bundleFlowFrame/Model/Omega + re-hosted truth lemma)
        │
        v
    BXCanonical countermodels (Completeness.lean, CompletenessDedekind.lean)
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

`boxInterior` (`InteriorOperators.lean:142`) is the only `InteriorOp` built here. It is
assembled from `box_le_self` (`:101`), `box_monotone` (`:112`) and `box_idempotent` (`:130`),
which hold because the modal T-axiom `Box phi -> phi` is valid under S5 accessibility.

G and H are **not** interior operators under strict temporal semantics: `G phi -> phi` and
`H phi -> phi` fail when G and H quantify over strictly future/past times. `H_monotone` (`:80`)
is the only surviving G/H-family result, and there is **no G operator on the quotient at all** —
the quotient carries `boxQuot` (`LindenbaumQuotient.lean:289`), `hQuot` (`:296`) and `negQuot`
(`:261`), with no G counterpart anywhere in the tree. The module's own docstring
(`InteriorOperators.lean:29-43`) states this and is the model this section follows.

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

3. **Interior Operators**: Show Box is an interior operator on the quotient (`boxInterior`):
   - Deflationary: `Box[phi] <= [phi]` (from the modal T-axiom `Box phi -> phi`)
   - Monotone: `[phi] <= [psi] -> Box[phi] <= Box[psi]` (from K-distribution)
   - Idempotent: `Box(Box[phi]) = Box[phi]` (from the modal 4-axiom `Box phi -> Box Box phi`)

   G and H are not interior operators here: under strict temporal semantics their T-axioms
   fail, so only `H_monotone` survives and no G operator is defined on the quotient.

4. **Ultrafilter-MCS Correspondence**: Establish bijection between:
   - Ultrafilters of `LindenbaumAlg`
   - Maximal consistent sets

5. **Representation Theorem**: Prove satisfiability via ultrafilters

## Relationship to Main Proof Path

The wired completeness entry point is `BXCanonical/`, which consumes this directory's
`FlowFrame.lean` directly. The supporting layers are:
- `Core/` - MCS foundations (shared)
- `Bundle/` - BFMCS canonical-frame construction via bundled MCS families
- `Algebraic/` - Boolean-algebra and ultrafilter foundations, plus the flow-frame countermodel
  engine that `BXCanonical` imports

This directory additionally provides:
- Independent verification that MCS theory is sound
- An alternative route from consistency to satisfiability
- Foundation for future Stone duality extensions

## Future Extension Opportunities

1. **Stone Duality**: Connect ultrafilters to points of Stone space
2. **Algebraic Topology**: Extend interior operators to topological semantics
3. **Coalgebraic Methods**: Duality with canonical coalgebra structures
4. **Alternative Completeness**: Finish algebraic completeness path if desired

## Dependencies

- **Mathlib**: `BooleanAlgebra`, `Quotient`, `Filter`
- **ProofChecker**: `FormalSystem.ProofSystem`, `FormalSystem.Metalogic.Core`

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Core README](../Core/README.md) - MCS foundations shared by both approaches
- [Bundle README](../Bundle/README.md) - BFMCS canonical-frame construction
- [Decidability README](../Decidability/README.md) - Decision procedure

## References

- Modal Logic, Blackburn et al., Chapter 5 (Algebraic Semantics)
- Stone Duality: Boolean Algebras and Topological Spaces

---

*Last updated: 2026-08-26*
