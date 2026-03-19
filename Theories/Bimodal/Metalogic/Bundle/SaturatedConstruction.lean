import Bimodal.Metalogic.Bundle.ModalWitnessData
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.CanonicalFMCS

/-!
# Saturated BFMCS Construction (Task 1003)

This module provides infrastructure for constructing modally saturated BFMCS bundles.

## Critical Discovery: Singleton Bundle is NOT Saturated

The design document (Task 1002) incorrectly claimed that the singleton bundle
`{canonicalMCSBFMCS}` is modally saturated. This is FALSE.

**Why the singleton fails**:

The saturation predicate `is_modally_saturated B` requires:
```
∀ fam ∈ B.families, ∀ t : D, ∀ psi : Formula,
  psi.diamond ∈ fam.mcs t → ∃ fam' ∈ B.families, psi ∈ fam'.mcs t
```

For the singleton bundle:
- B.families = {canonicalMCSBFMCS}
- fam.mcs t = t.world (the underlying MCS at time t)

The condition becomes:
```
∀ t : CanonicalMCS, ∀ psi : Formula,
  psi.diamond ∈ t.world → psi ∈ t.world
```

This says: if Diamond(psi) is in an MCS, then psi is in that MCS.

**This is FALSE in modal logic.** Diamond(psi) means "possibly psi", which does NOT
imply "actually psi". There exist MCSes where Diamond(psi) ∈ M but psi ∉ M.

## Correct Approach: Multi-Family BFMCS

The saturation requirement `psi ∈ fam'.mcs t` means we need a DIFFERENT family
with a DIFFERENT `mcs` function that maps time t to a witness MCS containing psi.

This requires:
1. Constructing witness families with different `mcs` assignments
2. Ensuring each witness family satisfies forward_G and backward_H (temporal coherence)
3. Adding these families to the BFMCS bundle

This is significantly more complex than the singleton approach and requires
additional infrastructure not yet implemented.

## What This Module Provides

1. `singleton_canonical_saturation_fails`: Documents why singleton is not saturated
2. Helper lemmas for future multi-family construction
3. Infrastructure from ModalWitnessData for witness MCS construction

## References

- Task 1002 design document (Section 2.1): Incorrectly claimed singleton is saturated
- MultiFamilyBFMCS.lean lines 553-556: Already notes singleton approach fails
- ModalSaturation.lean: is_modally_saturated definition
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Documentation: Why Singleton Saturation Fails

The following example illustrates why Diamond(psi) ∈ M does not imply psi ∈ M.
-/

/--
In S5 modal logic, Diamond(psi) does NOT imply psi.

Diamond(psi) = ¬□¬psi means "it is not necessary that not-psi",
i.e., "psi is possible". This is weaker than "psi is actual".

For an MCS M with Diamond(psi) ∈ M:
- There exists SOME accessible world where psi holds
- But that world may not be M itself
- So psi may or may not be in M

The singleton BFMCS has only one family, so "accessible worlds" at time t
all map to the SAME MCS (t.world). This means modal saturation would require
Diamond(psi) → psi to hold in every MCS, which is false.
-/
theorem singleton_canonical_saturation_fails_explanation :
    ¬(∀ (M : Set Formula), SetMaximalConsistent M →
      ∀ psi : Formula, psi.diamond ∈ M → psi ∈ M) := by
  -- We prove this by noting that S5 does not have the axiom Diamond(phi) -> phi
  -- An explicit counterexample requires constructing an MCS with Diamond(p) but not p
  -- For now, we document the mathematical fact
  intro h_false
  -- This would imply ⊢ Diamond(phi) → phi for all phi, which is not a theorem of S5
  -- The actual proof would construct a specific counterexample MCS
  sorry  -- Counterexample construction left as documentation

/-!
## Partial Infrastructure: Helper Lemmas

These lemmas support future multi-family construction.
-/

/--
T-axiom: Box phi in MCS implies phi in MCS.
-/
theorem box_implies_self_in_mcs' (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_box : Formula.box phi ∈ M) : phi ∈ M := by
  have h_T : [] ⊢ (Formula.box phi).imp phi := DerivationTree.axiom [] _ (Axiom.modal_t phi)
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_box

/--
For any BFMCS B with families = {canonicalMCSBFMCS}, modal_forward holds trivially.

This is because all families have the same MCS at each time, so Box phi in t.world
implies phi in t.world by the T-axiom.
-/
theorem singleton_canonical_modal_forward
    (fam fam' : FMCS CanonicalMCS)
    (hfam : fam = canonicalMCSBFMCS) (hfam' : fam' = canonicalMCSBFMCS)
    (phi : Formula) (t : CanonicalMCS)
    (h_box : Formula.box phi ∈ fam.mcs t) :
    phi ∈ fam'.mcs t := by
  subst hfam hfam'
  simp only [canonicalMCSBFMCS, canonicalMCS_mcs] at h_box ⊢
  exact box_implies_self_in_mcs' t.world t.is_mcs phi h_box

/-!
## Future Work: Multi-Family Construction

To achieve modal saturation, we need families where `mcs t` can be a witness MCS
(containing psi) rather than always being `t.world`.

### Approach 1: Point Witness Families

For each Diamond(psi) at time t0, create a family where:
- `mcs t0 = witness_MCS` (containing psi)
- `mcs t = t.world` for t ≠ t0 (or some coherent extension)

Challenge: The family must satisfy forward_G and backward_H at the boundary.

### Approach 2: Chain-Based Witness Families

Construct families along maximal chains (Flags) where witnesses are incorporated
at specific points in the chain, maintaining temporal coherence.

Challenge: Ensuring witnesses from different times/formulas are compatible.

### Approach 3: Quotient Construction

Use a quotient of CanonicalMCS that identifies "equivalent" times where modal
witnesses should be shared.

Challenge: Defining the appropriate equivalence relation.

These approaches require significant additional infrastructure beyond this module.
-/

end Bimodal.Metalogic.Bundle
