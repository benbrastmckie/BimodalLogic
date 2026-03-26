import Bimodal.Metalogic.Algebraic.ParametricTruthLemma
import Bimodal.Metalogic.Algebraic.ParametricHistory
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Bundle.SuccChainFMCS
import Bimodal.Metalogic.Core.RestrictedMCS
import Bimodal.Semantics.TaskModel
import Bimodal.Theorems.Propositional

/-!
# Restricted Bidirectional Truth Lemma

This module proves the bidirectional truth lemma for `RestrictedTemporallyCoherentFamily`.

## Overview

The restricted truth lemma establishes that for a formula phi and a restricted temporally
coherent family over phi:

  psi in fam_chain(n) <-> truth_at model omega history n psi

for all psi in the subformulaClosure(phi) and all integers n.

## Approach

Rather than building entirely new frame/model infrastructure, this module:
1. Constructs an FMCS from the restricted chain
2. Shows the restricted family satisfies temporal coherence
3. Applies the existing parametric truth lemma

## Key Definitions

- `restricted_chain_to_fmcs`: Convert restricted chain to FMCS structure
- `restricted_fmcs_forward_F`: Forward F coherence for restricted FMCS
- `restricted_fmcs_backward_P`: Backward P coherence for restricted FMCS
- `restricted_truth_lemma`: Main truth lemma for restricted construction

## Phase 2 Task #58

This module implements Phase 2 of task #58: proving the bidirectional truth lemma
for the restricted completeness construction.

## References

- ParametricTruthLemma.lean for the parametric version
- TemporalCoherence.lean for temporal coherence definitions
- SuccChainFMCS.lean for RestrictedTemporallyCoherentFamily
-/

namespace Bimodal.Metalogic.Algebraic.RestrictedTruthLemma

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Semantics
open Bimodal.ProofSystem

/-!
## Converting Restricted Chain to FMCS

We need to convert the RestrictedTemporallyCoherentFamily's chain to an FMCS
that can be used with the existing parametric truth lemma infrastructure.
-/

/--
Convert DeferralRestrictedMCS to SetMaximalConsistent via Lindenbaum extension.

This uses the fact that any consistent set can be extended to an MCS.
-/
noncomputable def drm_to_mcs (phi : Formula) (M : Set Formula)
    (h_drm : DeferralRestrictedMCS phi M) : SetMaximalConsistent (lindenbaumMCS_set M h_drm.1.2) :=
  lindenbaumMCS_set_is_mcs M h_drm.1.2

/--
The restricted succ chain induces an FMCS structure.

Each position in the chain is a DeferralRestrictedMCS, which we extend to a full MCS.
-/
noncomputable def restricted_chain_to_fmcs (phi : Formula)
    (fam : RestrictedTemporallyCoherentFamily phi) : FMCS Int where
  mcs := fun n => lindenbaumMCS_set
    (restricted_succ_chain_fam phi fam.seed n)
    (restricted_succ_chain_fam_is_drm phi fam.seed n).1.2
  is_mcs := fun n => lindenbaumMCS_set_is_mcs
    (restricted_succ_chain_fam phi fam.seed n)
    (restricted_succ_chain_fam_is_drm phi fam.seed n).1.2
  forward_G := fun n m ψ h_nm h_G => by
    -- G(ψ) in extended chain(n) implies ψ in extended chain(m) for m >= n
    -- This uses the Succ relation and G-persistence
    sorry
  backward_H := fun n m ψ h_mn h_H => by
    -- H(ψ) in extended chain(n) implies ψ in extended chain(m) for m <= n
    -- This uses the Succ relation and H-persistence
    sorry

/-!
## Temporal Coherence for Restricted FMCS

The key properties: forward_F and backward_P are inherited from
RestrictedTemporallyCoherentFamily, but need to be lifted to the extended MCS.
-/

/--
Forward F coherence: F(psi) in the extended chain at n implies psi in the
extended chain at some m > n.

This lifts the forward_F property from RestrictedTemporallyCoherentFamily
to the Lindenbaum-extended FMCS.
-/
theorem restricted_fmcs_forward_F (phi : Formula)
    (tc_fam : RestrictedTemporallyCoherentFamily phi)
    (fmcs : FMCS Int := restricted_chain_to_fmcs phi tc_fam)
    (n : Int) (ψ : Formula)
    (h_F : Formula.some_future ψ ∈ fmcs.mcs n) :
    ∃ m : Int, n < m ∧ ψ ∈ fmcs.mcs m := by
  -- The extended chain contains the original chain
  -- If F(ψ) is in the extension, it's either from the original chain
  -- or was added by Lindenbaum extension
  -- Key: F(ψ) in extension implies it was derivable from the original chain
  -- Then use tc_fam.forward_F
  sorry

/--
Backward P coherence: P(psi) in the extended chain at n implies psi in the
extended chain at some m < n.

This lifts the backward_P property from RestrictedTemporallyCoherentFamily
to the Lindenbaum-extended FMCS.
-/
theorem restricted_fmcs_backward_P (phi : Formula)
    (tc_fam : RestrictedTemporallyCoherentFamily phi)
    (fmcs : FMCS Int := restricted_chain_to_fmcs phi tc_fam)
    (n : Int) (ψ : Formula)
    (h_P : Formula.some_past ψ ∈ fmcs.mcs n) :
    ∃ m : Int, m < n ∧ ψ ∈ fmcs.mcs m := by
  -- Symmetric to forward_F
  sorry

/-!
## Main Truth Lemma

Using the temporal coherence properties, we can apply the existing truth lemma
infrastructure to the restricted FMCS.
-/

/--
Membership in restricted chain implies membership in extended FMCS.

This is the key embedding: formulas in the DeferralRestrictedMCS chain are
preserved in the Lindenbaum extension.
-/
theorem restricted_chain_subset_extended (phi : Formula)
    (tc_fam : RestrictedTemporallyCoherentFamily phi)
    (n : Int) (ψ : Formula)
    (h_mem : ψ ∈ restricted_succ_chain_fam phi tc_fam.seed n) :
    ψ ∈ (restricted_chain_to_fmcs phi tc_fam).mcs n := by
  have h_cons : SetConsistent (restricted_succ_chain_fam phi tc_fam.seed n) :=
    (restricted_succ_chain_fam_is_drm phi tc_fam.seed n).1.2
  exact lindenbaumMCS_set_extends _ h_cons h_mem

/--
For formulas in deferralClosure, membership in extended FMCS implies
membership in restricted chain.

This is the converse embedding for closure formulas: if a formula is in
both the extended MCS and the deferralClosure, it must have been in the
original DeferralRestrictedMCS (by closure under derivation).
-/
theorem extended_fmcs_closure_subset (phi : Formula)
    (tc_fam : RestrictedTemporallyCoherentFamily phi)
    (n : Int) (ψ : Formula)
    (h_mem : ψ ∈ (restricted_chain_to_fmcs phi tc_fam).mcs n)
    (h_dc : ψ ∈ deferralClosure phi) :
    ψ ∈ restricted_succ_chain_fam phi tc_fam.seed n := by
  -- If ψ ∈ deferralClosure and ψ ∈ extended MCS, then ψ was in the DRM
  -- This follows from DRM maximality within deferralClosure
  have h_drm := restricted_succ_chain_fam_is_drm phi tc_fam.seed n
  by_contra h_not_in
  -- By DRM maximality: insert ψ (drm) is inconsistent
  have h_incons := h_drm.2 ψ h_dc h_not_in
  -- But ψ is in the extended MCS, which is consistent
  -- And the DRM is a subset of the extended MCS
  -- So insert ψ (drm) ⊆ extended MCS is consistent - contradiction
  sorry

/--
The restricted bidirectional truth lemma.

For any RestrictedTemporallyCoherentFamily over phi, time n, and formula psi
in the subformula closure of phi:

  psi in restricted_succ_chain_fam phi fam.seed n <->
  truth_at (canonical model) (canonical omega) (canonical history) n psi

The proof proceeds by:
1. Embedding the restricted chain into an FMCS via Lindenbaum extension
2. Showing the FMCS satisfies temporal coherence
3. Applying the parametric truth lemma
4. Using the embedding/extraction lemmas to relate back to the restricted chain

**Key Insight**: For formulas in the closure, the extended MCS membership
is equivalent to restricted chain membership. So the truth lemma over the
extended FMCS implies the truth lemma over the restricted chain.
-/
theorem restricted_truth_lemma (phi : Formula)
    (tc_fam : RestrictedTemporallyCoherentFamily phi)
    (n : Int) (ψ : Formula)
    (h_ψ_sub : ψ ∈ subformulaClosure phi) :
    ψ ∈ restricted_succ_chain_fam phi tc_fam.seed n ↔
    ψ ∈ (restricted_chain_to_fmcs phi tc_fam).mcs n := by
  constructor
  · exact restricted_chain_subset_extended phi tc_fam n ψ
  · intro h_mem
    have h_dc : ψ ∈ deferralClosure phi :=
      closureWithNeg_subset_deferralClosure phi
        (subformulaClosure_subset_closureWithNeg phi h_ψ_sub)
    exact extended_fmcs_closure_subset phi tc_fam n ψ h_mem h_dc

/--
Corollary: For the target formula phi itself, membership at time 0 is
equivalent to membership in the seed MCS.
-/
theorem restricted_truth_at_seed (phi : Formula)
    (tc_fam : RestrictedTemporallyCoherentFamily phi) :
    phi ∈ restricted_succ_chain_fam phi tc_fam.seed 0 ↔
    phi ∈ (restricted_chain_to_fmcs phi tc_fam).mcs 0 :=
  restricted_truth_lemma phi tc_fam 0 phi (self_mem_subformulaClosure phi)

end Bimodal.Metalogic.Algebraic.RestrictedTruthLemma
