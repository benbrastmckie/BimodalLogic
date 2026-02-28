import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.DovetailingChain
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula

/-!
# Canonical Frame for Bimodal Completeness

This module defines the canonical frame for the Canonical Quotient approach to
bimodal completeness (Task 922). Instead of building a linear chain of MCSes
(which fails due to the "linear chain topology constraint"), we define the
canonical frame where:

- **Worlds** = all maximal consistent sets (MCSes)
- **Future relation** `CanonicalR M M'` iff `GContent M ⊆ M'`
- **Past relation** `CanonicalR_past M M'` iff `HContent M ⊆ M'`

In this frame, `forward_F` and `backward_P` become trivial because each
F-obligation gets its own independently-constructed witness MCS via Lindenbaum.

## Key Results

- `canonical_forward_F`: F(psi) in M implies exists MCS W with psi in W and CanonicalR M W
- `canonical_backward_P`: P(psi) in M implies exists MCS W with psi in W and CanonicalR_past M W
- `canonical_forward_G`: G(phi) in M and CanonicalR M M' implies phi in M'
- `canonical_backward_H`: H(phi) in M and CanonicalR_past M M' implies phi in M'

## Design

The critical insight (from research-001) is that in the canonical model, each
F-obligation `F(psi) ∈ M` gets its own witness `W = Lindenbaum({psi} ∪ GContent(M))`.
This avoids the inter-obligation interference that blocked all 12 prior chain-based
approaches. The proven lemma `forward_temporal_witness_seed_consistent` (in
DovetailingChain.lean) guarantees `{psi} ∪ GContent(M)` is consistent, and
`set_lindenbaum` extends it to an MCS.

## References

- Task 922 research-001.md: Strategy study identifying Canonical Quotient approach
- Task 922 research-002.md: Cross-pollination analysis confirming approach
- Goldblatt 1992, Logics of Time and Computation (canonical model for tense logics)
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
## Canonical Relations

The canonical future relation connects M to M' when all G-formulas of M are
satisfied at M'. The canonical past relation connects M to M' when all
H-formulas of M are satisfied at M'.
-/

/--
Canonical future relation: `M` sees `M'` in the future iff `GContent M ⊆ M'`.

Equivalently: for all phi, if `G phi ∈ M` then `phi ∈ M'`.
-/
def CanonicalR (M M' : Set Formula) : Prop :=
  GContent M ⊆ M'

/--
Canonical past relation: `M` sees `M'` in the past iff `HContent M ⊆ M'`.

Equivalently: for all phi, if `H phi ∈ M` then `phi ∈ M'`.
-/
def CanonicalR_past (M M' : Set Formula) : Prop :=
  HContent M ⊆ M'

/-!
## Forward G and Backward H (Trivial by Definition)

These properties follow directly from the definition of CanonicalR/CanonicalR_past.
-/

/--
G-forward property: If `G phi ∈ M` and `CanonicalR M M'`, then `phi ∈ M'`.

This is trivial: `G phi ∈ M` means `phi ∈ GContent M`, and `CanonicalR M M'`
means `GContent M ⊆ M'`, so `phi ∈ M'`.
-/
theorem canonical_forward_G (M M' : Set Formula)
    (h_R : CanonicalR M M') (phi : Formula) (h_G : Formula.all_future phi ∈ M) :
    phi ∈ M' := by
  exact h_R h_G

/--
H-backward property: If `H phi ∈ M` and `CanonicalR_past M M'`, then `phi ∈ M'`.

Symmetric to canonical_forward_G using HContent.
-/
theorem canonical_backward_H (M M' : Set Formula)
    (h_R : CanonicalR_past M M') (phi : Formula) (h_H : Formula.all_past phi ∈ M) :
    phi ∈ M' := by
  exact h_R h_H

/-!
## Forward F (The Key Trivial Property)

In the canonical model, `forward_F` is trivial because each F-obligation gets
its own fresh Lindenbaum witness. This is the property that was IMPOSSIBLE to
prove in the linear chain approach.

The proof uses:
1. `forward_temporal_witness_seed_consistent`: `F(psi) ∈ M` implies `{psi} ∪ GContent(M)` is consistent
2. `set_lindenbaum`: Any consistent set can be extended to an MCS
3. The resulting MCS contains `psi` (from the seed) and `GContent(M)` (from the seed)
4. Therefore `CanonicalR M W` holds and `psi ∈ W`
-/

/--
F-forward property: If `F(psi) ∈ M` and `M` is MCS, then there exists an MCS `W`
such that `CanonicalR M W` and `psi ∈ W`.

This is the property that all 12 chain-based approaches failed to prove.
In the canonical frame, it is trivial.
-/
theorem canonical_forward_F (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ psi ∈ W := by
  -- Step 1: {psi} ∪ GContent(M) is consistent
  have h_seed_cons : SetConsistent (ForwardTemporalWitnessSeed M psi) :=
    forward_temporal_witness_seed_consistent M h_mcs psi h_F
  -- Step 2: Extend to an MCS via Lindenbaum
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum (ForwardTemporalWitnessSeed M psi) h_seed_cons
  -- Step 3: W is the witness
  use W, h_W_mcs
  constructor
  · -- CanonicalR M W: GContent M ⊆ W
    -- GContent M ⊆ ForwardTemporalWitnessSeed M psi ⊆ W
    exact Set.Subset.trans (GContent_subset_ForwardTemporalWitnessSeed M psi) h_extends
  · -- psi ∈ W: psi ∈ ForwardTemporalWitnessSeed M psi ⊆ W
    exact h_extends (psi_mem_ForwardTemporalWitnessSeed M psi)

/-!
## Backward P (Symmetric Key Property)

Same as forward_F but for the past direction.
-/

/--
P-backward property: If `P(psi) ∈ M` and `M` is MCS, then there exists an MCS `W`
such that `CanonicalR_past M W` and `psi ∈ W`.

This is the past-symmetric version of canonical_forward_F.
-/
theorem canonical_backward_P (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_P : Formula.some_past psi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR_past M W ∧ psi ∈ W := by
  -- Step 1: {psi} ∪ HContent(M) is consistent
  have h_seed_cons : SetConsistent (PastTemporalWitnessSeed M psi) :=
    past_temporal_witness_seed_consistent M h_mcs psi h_P
  -- Step 2: Extend to an MCS via Lindenbaum
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum (PastTemporalWitnessSeed M psi) h_seed_cons
  -- Step 3: W is the witness
  use W, h_W_mcs
  constructor
  · -- CanonicalR_past M W: HContent M ⊆ W
    -- HContent M ⊆ PastTemporalWitnessSeed M psi ⊆ W
    exact Set.Subset.trans (HContent_subset_PastTemporalWitnessSeed M psi) h_extends
  · -- psi ∈ W: psi ∈ PastTemporalWitnessSeed M psi ⊆ W
    exact h_extends (psi_mem_PastTemporalWitnessSeed M psi)

/-!
## Reflexivity of Canonical Relations

The canonical relations are reflexive for MCSes, using the T-axioms
(temp_t_future: G phi -> phi, temp_t_past: H phi -> phi).
-/

/--
CanonicalR is reflexive for MCSes: `CanonicalR M M` holds for any MCS `M`.

Proof: If `G phi ∈ M`, then by T-axiom `G phi -> phi` and MCS closure, `phi ∈ M`.
-/
theorem canonicalR_reflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    CanonicalR M M := by
  intro phi h_G_phi
  -- phi ∈ GContent M means G phi ∈ M
  -- By T-axiom: ⊢ G phi → phi
  have h_T : [] ⊢ (Formula.all_future phi).imp phi :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_future phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G_phi

/--
CanonicalR_past is reflexive for MCSes: `CanonicalR_past M M` holds for any MCS `M`.

Proof: If `H phi ∈ M`, then by T-axiom `H phi -> phi` and MCS closure, `phi ∈ M`.
-/
theorem canonicalR_past_reflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    CanonicalR_past M M := by
  intro phi h_H_phi
  -- phi ∈ HContent M means H phi ∈ M
  -- By T-axiom: ⊢ H phi → phi
  have h_T : [] ⊢ (Formula.all_past phi).imp phi :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_past phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H_phi

/-!
## Transitivity of Canonical Relations

The canonical relations are transitive using the Temporal 4 axiom (G phi -> GG phi).
-/

/--
CanonicalR is transitive: If `CanonicalR M M'` and `CanonicalR M' M''`, then `CanonicalR M M''`.

Proof: If `G phi ∈ M`, by Temporal 4 `G phi -> GG phi`, so `GG phi ∈ M`, thus `G phi ∈ GContent M ⊆ M'`.
But wait - we need: `G phi ∈ M` implies `phi ∈ M''`.
From `G phi ∈ M` and Temp 4, `G(G phi) ∈ M`. So `G phi ∈ GContent M ⊆ M'`.
Then `phi ∈ GContent M' ⊆ M''`.
-/
theorem canonicalR_transitive (M M' M'' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_R1 : CanonicalR M M') (h_R2 : CanonicalR M' M'') :
    CanonicalR M M'' := by
  intro phi h_G_phi
  -- phi ∈ GContent M means G phi ∈ M
  -- By Temporal 4: ⊢ G phi → G(G phi), so G(G phi) ∈ M
  have h_T4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_4 phi)
  have h_GG : Formula.all_future (Formula.all_future phi) ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T4) h_G_phi
  -- G phi ∈ GContent M, and GContent M ⊆ M' by h_R1
  have h_G_in_M' : Formula.all_future phi ∈ M' := h_R1 h_GG
  -- phi ∈ GContent M', and GContent M' ⊆ M'' by h_R2
  exact h_R2 h_G_in_M'

/--
HContent chain transitivity: If `HContent V ⊆ N` and `HContent N ⊆ M`, then `HContent V ⊆ M`.

This is the backward (past) analogue of `canonicalR_transitive`.
The proof uses the Temporal 4 axiom for the past direction: `H phi → H(H phi)`.

Given `phi ∈ HContent V` (i.e., `H phi ∈ V`):
1. By `temp_4_past`: `H(H phi) ∈ V`
2. So `H phi ∈ HContent V ⊆ N`
3. So `phi ∈ HContent N ⊆ M`
-/
theorem HContent_chain_transitive (M N V : Set Formula)
    (h_mcs_V : SetMaximalConsistent V)
    (hNV : HContent V ⊆ N) (hMN : HContent N ⊆ M) :
    HContent V ⊆ M := by
  intro phi h_H_phi
  -- h_H_phi : phi ∈ HContent V, i.e., H phi ∈ V
  -- By Temporal 4 for H: H phi → H(H phi), so H(H phi) ∈ V
  have h_H4 := temp_4_past phi
  have h_HH_in_V := set_mcs_implication_property h_mcs_V (theorem_in_mcs h_mcs_V h_H4) h_H_phi
  -- H phi ∈ HContent V, and HContent V ⊆ N, so H phi ∈ N
  have h_Hphi_in_N := hNV h_HH_in_V
  -- phi ∈ HContent N, and HContent N ⊆ M, so phi ∈ M
  exact hMN h_Hphi_in_N

end Bimodal.Metalogic.Bundle
