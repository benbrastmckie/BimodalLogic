import Bimodal.ProofSystem.Axioms
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.BaseCompleteness
import Bimodal.Metalogic.DenseCompleteness
import Bimodal.Metalogic.DiscreteCompleteness
import Bimodal.Metalogic.Bundle.CanonicalFMCS

/-!
# Logic Variants - TM Base, Dense, and Discrete

This module provides a summary of the three TM logic variants and their
soundness/completeness results.

## Logic Variants Overview

The TM (Tense and Modality) bimodal logic has three variants based on
frame conditions:

### TM Base (18 axioms)

The core logic valid on all linear orders. No special frame conditions required.

**Axioms**: prop_k, prop_s, ex_falso, peirce, modal_t, modal_4, modal_b,
modal_5_collapse, modal_k_dist, temp_k_dist, temp_4, temp_t_future,
temp_t_past, temp_a, temp_l, modal_future, temp_future, temp_linearity

**Frame Condition**: Linear temporal order (no additional constraints)

### TM Dense (Base + 1 axiom = 19 axioms)

Extension for densely ordered temporal domains.

**Additional Axiom**: density (DN) = `Fφ → FFφ`

**Frame Condition**: `DenselyOrdered D` - between any two distinct times
exists another time.

### TM Discrete (Base + 3 axioms = 21 axioms)

Extension for discretely ordered temporal domains.

**Additional Axioms**:
- discreteness_forward (DF) = `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)`
- seriality_future (SF) = `F(¬⊥)`
- seriality_past (SP) = `P(¬⊥)`

**Frame Condition**: `SuccOrder D`, `PredOrder D`, `NoMaxOrder D`, `NoMinOrder D`

## Soundness/Completeness Status

| Variant | Soundness | Completeness | Notes |
|---------|-----------|--------------|-------|
| Base | Proven | Documented | Truth lemma over Int proven |
| Dense | Proven | Documented | Domain mismatch gap (see DenseCompleteness) |
| Discrete | Proven | Framework | Blocked on task 974 (SuccOrder) |

All soundness results are sorry-free. Completeness infrastructure is in place
but final theorem wiring depends on domain construction issues.

## Resolved: DN Dependency in Discrete Construction (Task 980)

**Previously**: The `discrete_staged_has_future` and `discrete_staged_has_past` theorems
in `CantorPrereqs.lean` used the density axiom DN via `iterated_future_in_mcs` and
`iterated_past_in_mcs`, even though the discrete logic should NOT include DN.

**Resolution (Task 980)**: The discrete construction now uses MCS Richness, a DN-free
approach based on the observation that every MCS contains F-formulas with arbitrarily
large encodings:

- For any atom i, `F(neg bot ∨ atom(i)) ∈ M` by negation completeness (either this or
  `G(bot ∧ neg(atom(i))) ∈ M`, but the latter implies `G(bot) ∈ M` contradicting seriality)
- Since there are infinitely many atoms and encodings are injective, the formulas
  `(neg bot ∨ atom(i))` have unbounded encodings

**Key Lemmas Added**:
- `SetMaximalConsistent.F_or_atom_in`: F(neg bot ∨ atom(i)) ∈ M for all atoms
- `SetMaximalConsistent.mcs_has_large_F_formula`: For any N, ∃ phi with encoding ≥ N and F(phi) ∈ M
- `SetMaximalConsistent.P_or_atom_in`: P(neg bot ∨ atom(i)) ∈ M for all atoms (symmetric)
- `SetMaximalConsistent.mcs_has_large_P_formula`: For any N, ∃ phi with encoding ≥ N and P(phi) ∈ M

**Status**: RESOLVED - The discrete construction no longer depends on DN.

## References

- `BaseCompleteness.lean`: Base logic completeness infrastructure
- `DenseCompleteness.lean`: Dense logic completeness documentation
- `DiscreteCompleteness.lean`: Discrete logic completeness framework
- `ProofSystem/Axioms.lean`: FrameClass enumeration
- Task 977: Organization task that created this file
- Task 978: Planned typeclass-based refactor
-/

namespace Bimodal.LogicVariants

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Bundle.Canonical

/-!
## Soundness Re-exports

All axioms are valid on their respective frame classes.
-/

/-- Base axioms are valid on all linear orders. -/
theorem base_axiom_valid {φ : Formula} (h : Axiom φ) (hb : h.isBase) : valid φ :=
  axiom_base_valid h hb

/-- Dense-compatible axioms are valid on dense orders. -/
theorem dense_axiom_valid {φ : Formula} (h : Axiom φ) (hdc : h.isDenseCompatible) :
    valid_dense φ :=
  axiom_valid_dense h hdc

/-- Discrete-compatible axioms are valid on discrete orders. -/
theorem discrete_axiom_valid {φ : Formula} (h : Axiom φ) (hdc : h.isDiscreteCompatible) :
    valid_discrete φ :=
  axiom_valid_discrete h hdc

/-!
## Completeness Re-exports

Infrastructure for completeness proofs (see individual modules for details).
-/

/-- Base completeness infrastructure: truth lemma for Int-indexed canonical model. -/
theorem base_truth_lemma_export
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (φ : Formula) :
    φ ∈ fam.mcs t ↔
      truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t φ :=
  BaseCompleteness.base_truth_lemma B h_tc fam hfam t φ

/-- Dense completeness components are all proven (Cantor isomorphism, FMCS construction). -/
theorem dense_components_export
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs) :
    (Nonempty (StagedConstruction.TimelineQuot root_mcs root_mcs_proof ≃o Rat)) ∧
    (∀ Gamma : List Formula, ContextConsistent Gamma →
      ∃ (fam : FMCS CanonicalMCS) (root : CanonicalMCS),
        (∀ gamma ∈ Gamma, gamma ∈ fam.mcs root) ∧
        (∀ t : CanonicalMCS, ∀ ψ : Formula,
          Formula.some_future ψ ∈ fam.mcs t → ∃ s : CanonicalMCS, t ≤ s ∧ ψ ∈ fam.mcs s) ∧
        (∀ t : CanonicalMCS, ∀ ψ : Formula,
          Formula.some_past ψ ∈ fam.mcs t → ∃ s : CanonicalMCS, s ≤ t ∧ ψ ∈ fam.mcs s)) :=
  DenseCompleteness.dense_components_proven root_mcs root_mcs_proof

/-!
## FrameClass Characterization

The `FrameClass` enumeration provides type-safe classification of axioms.
-/

/-- Base axioms have frame class Base. -/
theorem base_axioms_have_base_class {φ : Formula} (h : Axiom φ) :
    h.frameClass = .Base ↔ h.isBase :=
  h.frameClass_eq_base_iff_isBase

/-- Discrete-compatible axioms have frame class not Dense. -/
theorem discrete_compatible_not_dense {φ : Formula} (h : Axiom φ) :
    h.isDiscreteCompatible ↔ h.frameClass ≠ .Dense :=
  h.isDiscreteCompatible_iff_frameClass

/-!
## Logic Variant Incompatibility

Dense and discrete extensions are incompatible: no domain satisfies both
`DenselyOrdered D` and `SuccOrder D` (except degenerate cases).

This is reflected in the axiom structure:
- DN (density) has frame class Dense
- DF, SF, SP have frame class Discrete

A consistent logic cannot include both DN and DF.
-/

/-- The density axiom has frame class Dense. -/
theorem density_is_dense (φ : Formula) :
    (Axiom.density φ).frameClass = .Dense := rfl

/-- The discreteness forward axiom has frame class Discrete. -/
theorem discreteness_forward_is_discrete (φ : Formula) :
    (Axiom.discreteness_forward φ).frameClass = .Discrete := rfl

/-- Seriality axioms have frame class Discrete. -/
theorem seriality_is_discrete :
    (Axiom.seriality_future).frameClass = .Discrete ∧
    (Axiom.seriality_past).frameClass = .Discrete :=
  ⟨rfl, rfl⟩

end Bimodal.LogicVariants
