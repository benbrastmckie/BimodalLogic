# Core Metalogic Foundations

**Status**: Self-Contained (No Boneyard Dependencies)

This directory contains the foundational theory for maximal consistent sets (MCS) and the
deduction theorem, which underpin all canonical model constructions in the metalogic.

## Overview

The Core modules provide essential infrastructure shared by both the `Bundle/` (BMCS) and
`Algebraic/` approaches:
- **Maximal Consistent Sets (MCS)**: Sets that are consistent and cannot be extended
- **Lindenbaum's Lemma**: Extending consistent sets to MCS using Zorn's lemma
- **Deduction Theorem**: Converting `A :: Gamma ⊢ B` to `Gamma ⊢ A → B`
- **MCS Properties**: Lemmas about formula membership and closure

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `Core.lean` | Module root, re-exports components | Complete |
| `MaximalConsistent.lean` | Complete MCS theory with Lindenbaum | **Sorry-free** |
| `DeductionTheorem.lean` | Deduction theorem infrastructure | **Sorry-free** |
| `MCSProperties.lean` | Essential MCS lemmas | **Sorry-free** |
| `RestrictedMCS.lean` | MCS restricted to subformula closure | **Sorry-free** |

## Dependency Flowchart

```
                  MaximalConsistent.lean
                         │
           ┌─────────────┼─────────────┐
           │             │             │
           v             v             v
    DeductionTheorem  MCSProperties   (exports to
           │             │             other modules)
           │             │
           v             v
        Core.lean (aggregator)
```

## Key Definitions

### Maximal Consistent Sets (`MaximalConsistent.lean`)

```lean
def Consistent (Gamma : Context) : Prop :=
  ¬Nonempty (DerivationTree Gamma Formula.bot)

def SetConsistent (S : Set Formula) : Prop :=
  ∀ (L : List Formula), (∀ φ ∈ L, φ ∈ S) → Consistent L

def SetMaximalConsistent (S : Set Formula) : Prop :=
  SetConsistent S ∧ ∀ φ, φ ∉ S → ¬SetConsistent (insert φ S)
```

A set is **SetConsistent** if every finite subset is consistent (cannot derive ⊥).
A set is **SetMaximalConsistent** if it is consistent and any extension is inconsistent.

**Key Theorems**:
- `set_lindenbaum`: Lindenbaum's lemma (extend consistent to MCS via Zorn's lemma)
- `mcs_contains_or_neg`: Either φ or ¬φ in MCS (negation completeness)
- `theorem_in_mcs`: All theorems are in every MCS
- `set_mcs_modus_ponens`: Modus ponens reflected in membership
- `inconsistent_derives_bot`: Inconsistent contexts derive ⊥

### Deduction Theorem (`DeductionTheorem.lean`)

```lean
theorem deduction_theorem {Gamma : Context} {A B : Formula}
    (h : A :: Gamma ⊢ B) : Gamma ⊢ A.imp B
```

The deduction theorem converts a derivation from an extended context into an implication derivation.

**Supporting lemmas**:
- `deduction_axiom`: If φ is an axiom, then `Gamma ⊢ A → φ`
- `deduction_assumption_same`: `Gamma ⊢ A → A` (identity)
- `deduction_assumption_other`: If `B ∈ Gamma`, then `Gamma ⊢ A → B`
- `deduction_mp`: Modus ponens under implication

**Implementation Note**: The proof uses well-founded recursion on derivation height to handle
the recursive structure of derivation trees.

### MCS Properties (`MCSProperties.lean`)

```lean
lemma set_mcs_closed_under_derivation {S : Set Formula} {phi : Formula}
    (h_mcs : SetMaximalConsistent S)
    (L : List Formula) (h_sub : ∀ psi ∈ L, psi ∈ S)
    (h_deriv : DerivationTree L phi) : phi ∈ S

lemma set_mcs_implication_property {S : Set Formula} {phi psi : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_imp : phi.imp psi ∈ S) (h_phi : phi ∈ S) : psi ∈ S

lemma set_mcs_negation_complete {S : Set Formula} {phi : Formula}
    (h_mcs : SetMaximalConsistent S) :
    phi ∈ S ∨ phi.neg ∈ S
```

Essential lemmas for canonical model construction:
- Derivable formulas are in MCS
- Modus ponens reflected in membership
- Negation completeness

**Temporal Properties**:
```lean
lemma set_mcs_all_future_all_future {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) {phi : Formula}
    (h : Formula.all_future phi ∈ S) : Formula.all_future (Formula.all_future phi) ∈ S

lemma set_mcs_all_past_all_past {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) {phi : Formula}
    (h : Formula.all_past phi ∈ S) : Formula.all_past (Formula.all_past phi) ∈ S
```

These use the derived 4-axiom for temporal operators.

## Design Notes

### Self-Contained MCS Theory

The MCS theory is fully self-contained in this directory. All definitions and proofs are in
`MaximalConsistent.lean`.

### Deduction Theorem Complexity

The deduction theorem for Hilbert systems requires careful handling:
- Must track derivation structure (axiom, assumption, modus ponens, weakening)
- Modal/temporal K rules do not apply with non-empty contexts
- Uses well-founded recursion on derivation height

### Relationship to Other Modules

The Core modules are prerequisites for:
- `Bundle/` - BMCS completeness uses MCS extension and truth lemma
- `Algebraic/UltrafilterMCS.lean` - Uses MCS definitions for ultrafilter correspondence
- `FMP/` - Uses consistency and Lindenbaum's lemma for finite model construction

## Dependencies

- **ProofSystem**: Derivation trees and axioms
- **Theorems/Propositional**: Propositional combinator infrastructure

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Bundle README](../Bundle/README.md) - BMCS completeness (uses Core)
- [Algebraic README](../Algebraic/README.md) - Algebraic approach (uses Core)
- [FMP README](../FMP/README.md) - Finite model property (uses Core)

## References

- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)
- Lindenbaum's Lemma: Standard application of Zorn's lemma
- Hilbert-style deduction theorem: Standard proof technique

---

*Last updated: 2026-02-03*
