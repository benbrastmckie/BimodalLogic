# Core Metalogic Foundations

This directory contains the foundational theory for maximal consistent sets (MCS) and the deduction theorem, which underpin all canonical model constructions in the metalogic.

## Overview

The Core modules provide essential infrastructure shared by both the `Representation/` (seed-extension) and `Algebraic/` approaches:
- **Maximal Consistent Sets (MCS)**: Sets that are consistent and cannot be extended
- **Deduction Theorem**: Converting `A :: Gamma |- B` to `Gamma |- A -> B`
- **MCS Properties**: Lemmas about formula membership and closure

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `Core.lean` | Module root, re-exports components | Complete |
| `MaximalConsistent.lean` | MCS definitions (re-exports from Boneyard) | Complete |
| `DeductionTheorem.lean` | Deduction theorem infrastructure | Proven |
| `MCSProperties.lean` | Essential MCS lemmas | Proven |

## Key Definitions

### Maximal Consistent Sets (`MaximalConsistent.lean`)

```lean
def SetConsistent (S : Set Formula) : Prop :=
  forall (L : List Formula), (forall phi in L, phi in S) -> Consistent L

def SetMaximalConsistent (S : Set Formula) : Prop :=
  SetConsistent S /\ forall phi, phi not in S -> not (SetConsistent (insert phi S))
```

A set is **SetConsistent** if every finite subset is consistent (cannot derive bot).
A set is **SetMaximalConsistent** if it is consistent and any extension is inconsistent.

**Re-exported lemmas**:
- `set_lindenbaum`: Lindenbaum's lemma (extend consistent to MCS)
- `maximal_negation_complete`: Either phi or neg phi in MCS
- `maximal_consistent_closed`: MCS is closed under derivability
- `theorem_in_mcs`: All theorems are in every MCS

### Deduction Theorem (`DeductionTheorem.lean`)

```lean
theorem deduction_theorem {Gamma : Context} {A B : Formula}
    (h : A :: Gamma |- B) : Gamma |- A.imp B
```

The deduction theorem converts a derivation from an extended context into an implication derivation.

**Supporting lemmas**:
- `deduction_axiom`: If phi is an axiom, then `Gamma |- A -> phi`
- `deduction_assumption_same`: `Gamma |- A -> A` (identity)
- `deduction_assumption_other`: If `B in Gamma`, then `Gamma |- A -> B`
- `deduction_mp`: Modus ponens under implication

**Implementation Note**: The proof uses well-founded recursion on derivation height to handle the recursive structure of derivation trees.

### MCS Properties (`MCSProperties.lean`)

```lean
lemma set_mcs_closed_under_derivation {S : Set Formula} {phi : Formula}
    (h_mcs : SetMaximalConsistent S)
    (L : List Formula) (h_sub : forall psi in L, psi in S)
    (h_deriv : DerivationTree L phi) : phi in S

lemma set_mcs_implication_property {S : Set Formula} {phi psi : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_imp : phi.imp psi in S) (h_phi : phi in S) : psi in S

lemma set_mcs_negation_complete {S : Set Formula} {phi : Formula}
    (h_mcs : SetMaximalConsistent S) :
    phi in S ∨ phi.neg in S
```

Essential lemmas for canonical model construction:
- Derivable formulas are in MCS
- Modus ponens reflected in membership
- Negation completeness

**Temporal Properties**:
```lean
lemma set_mcs_all_future_all_future {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) {phi : Formula}
    (h : Formula.all_future phi in S) : Formula.all_future (Formula.all_future phi) in S

lemma set_mcs_all_past_all_past {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) {phi : Formula}
    (h : Formula.all_past phi in S) : Formula.all_past (Formula.all_past phi) in S
```

These use the derived 4-axiom for temporal operators.

## Architecture

```
                    Core/
                      |
        +-------------+-------------+
        |             |             |
        v             v             v
MaximalConsistent  Deduction    MCSProperties
        |          Theorem           |
        |             |              |
        v             v              v
   Boneyard/      Combinators     Both layers
   Metalogic_v2      |               |
                     v               v
              ProofSystem     Representation/
                                    &
                              Algebraic/
```

## Dependencies

- **Boneyard**: Re-exports proven MCS theory from `Bimodal.Boneyard.Metalogic_v2.Core`
- **ProofSystem**: Derivation trees and axioms
- **Combinators**: Propositional combinator infrastructure for deduction theorem

## Design Notes

### Why Re-export from Boneyard?

The MCS theory in `Boneyard/Metalogic_v2/Core/` is complete and proven. Rather than duplicating this work, we re-export the essential definitions and add only the additional lemmas needed for the parametric approach.

### Deduction Theorem Complexity

The deduction theorem for Hilbert systems requires careful handling:
- Must track derivation structure (axiom, assumption, modus ponens, weakening)
- Modal/temporal K rules do not apply with non-empty contexts
- Uses well-founded recursion on derivation height

### Relationship to Representation

The Core modules are prerequisites for:
- `Representation/CoherentConstruction.lean` - Uses MCS extension and deduction theorem
- `Algebraic/UltrafilterMCS.lean` - Uses MCS definitions for ultrafilter correspondence

## Related Files

- `../Representation/README.md` - Representation theorem (uses Core)
- `../Algebraic/README.md` - Algebraic approach (uses Core)
- `../README.md` - Overall metalogic architecture
- `../../Boneyard/Metalogic_v2/Core/` - Source of re-exported MCS theory

## References

- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)
- Hilbert-style deduction theorem: standard proof technique

---

*Last updated: 2026-01-29*
