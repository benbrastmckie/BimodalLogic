/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Bundle.TemporalContent
import FormalSystem.Metalogic.Bundle.WitnessSeed
import FormalSystem.Metalogic.Core.MaximalConsistent
import FormalSystem.Metalogic.Core.MCSProperties
import FormalSystem.Syntax.Formula

/-!
# Canonical Frame for Bimodal Completeness

This module defines the canonical frame for the Canonical Quotient approach to
bimodal completeness. Instead of building a linear chain of MCSes
(which fails due to the "linear chain topology constraint"), we define the
canonical frame where:

- **Worlds** = all maximal consistent sets (MCSes)
- **Future relation** `ExistsTask M M'` iff `GContent M ⊆ M'`
- **Past relation** `ExistsTaskPast M M'` iff `HContent M ⊆ M'`

In this frame, `forward_F` and `backward_P` become trivial because each
F-obligation gets its own independently-constructed witness MCS via Lindenbaum.

## Key Results

- `canonical_forward_F`: F(psi) in M implies exists MCS W with psi in W and ExistsTask M W
- `canonical_backward_P`: P(psi) in M implies exists MCS W with psi in W and ExistsTaskPast M W
- `canonical_forward_G`: G(phi) in M and ExistsTask M M' implies phi in M'
- `canonical_backward_H`: H(phi) in M and ExistsTaskPast M M' implies phi in M'

## Design

The critical insight (from research-001) is that in the canonical model, each
F-obligation `F(psi) ∈ M` gets its own witness `W = Lindenbaum({psi} ∪ GContent(M))`.
This avoids the inter-obligation interference that blocked all 12 prior chain-based
approaches. The proven lemma `forward_temporal_witness_seed_consistent` (in
WitnessSeed.lean) guarantees `{psi} ∪ GContent(M)` is consistent, and
`set_lindenbaum` extends it to an MCS.

## References

- Goldblatt 1992, Logics of Time and Computation (canonical model for tense logics)
-/

namespace FormalSystem.Metalogic.Bundle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core

/-!
## Canonical Relations

The canonical future relation connects M to M' when all G-formulas of M are
satisfied at M'. The canonical past relation connects M to M' when all
H-formulas of M are satisfied at M'.
-/

/--
Canonical future relation: `M` sees `M'` in the future iff `GContent M ⊆ M'`.

Equivalently: for all phi, if `G phi ∈ M` then `phi ∈ M'`.

The name `ExistsTask` reflects the semantic interpretation: there exists a temporal
task (F-obligation) connecting M to M'. This is derived from the CanonicalTask
relation in the staged construction where `CanonicalTask M n M'` witnesses n steps
of F-chaining from M to M'.
-/
def ExistsTask (M M' : Set Formula) : Prop :=
  GContent M ⊆ M'

/-- Unfolding lemma for ExistsTask. -/
@[simp] lemma ExistsTask_def {M M' : Set Formula} : ExistsTask M M' = (GContent M ⊆ M') := rfl


/--
Canonical past relation: `M` sees `M'` in the past iff `HContent M ⊆ M'`.

Equivalently: for all phi, if `H phi ∈ M` then `phi ∈ M'`.
-/
def ExistsTaskPast (M M' : Set Formula) : Prop :=
  HContent M ⊆ M'

/-- Unfolding lemma for ExistsTaskPast. -/
@[simp] lemma ExistsTask_past_def {M M' : Set Formula} : ExistsTaskPast M M' = (HContent M ⊆ M')
    := rfl


/-!
## Forward G and Backward H (Trivial by Definition)

These properties follow directly from the definition of ExistsTask/ExistsTaskPast.
-/

/--
G-forward property: If `G phi ∈ M` and `ExistsTask M M'`, then `phi ∈ M'`.

This is trivial: `G phi ∈ M` means `phi ∈ GContent M`, and `ExistsTask M M'`
means `GContent M ⊆ M'`, so `phi ∈ M'`.
-/
theorem canonical_forward_G (M M' : Set Formula)
    (h_R : ExistsTask M M') (phi : Formula) (h_G : Formula.allFuture phi ∈ M) :
    phi ∈ M' := by
  exact h_R h_G

/--
H-backward property: If `H phi ∈ M` and `ExistsTaskPast M M'`, then `phi ∈ M'`.

Symmetric to canonical_forward_G using HContent.
-/
theorem canonical_backward_H (M M' : Set Formula)
    (h_R : ExistsTaskPast M M') (phi : Formula) (h_H : Formula.allPast phi ∈ M) :
    phi ∈ M' := by
  exact h_R h_H

/-!
## Forward F (The Key Trivial Property)

In the canonical model, `forward_F` is trivial because each F-obligation gets
its own fresh Lindenbaum witness. This is the property that was IMPOSSIBLE to
prove in the linear chain approach.

The proof uses:
1. `forward_temporal_witness_seed_consistent`: `F(psi) ∈ M` implies `{psi} ∪ GContent(M)` is
consistent
2. `set_lindenbaum`: Any consistent set can be extended to an MCS
3. The resulting MCS contains `psi` (from the seed) and `GContent(M)` (from the seed)
4. Therefore `ExistsTask M W` holds and `psi ∈ W`
-/

/--
F-forward property: If `F(psi) ∈ M` and `M` is MCS, then there exists an MCS `W`
such that `ExistsTask M W` and `psi ∈ W`.

This is the property that all 12 chain-based approaches failed to prove.
In the canonical frame, it is trivial.
-/
theorem canonical_forward_F (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (psi : Formula) (h_F : Formula.someFuture psi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent (fc := FrameClass.Base) W ∧ ExistsTask M W ∧ psi ∈
        W := by
  -- Step 1: {psi} ∪ GContent(M) is consistent
  have h_seed_cons : SetConsistent (ForwardTemporalWitnessSeed M psi) :=
    forward_temporal_witness_seed_consistent M h_mcs psi h_F
  -- Step 2: Extend to an MCS via Lindenbaum
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum (ForwardTemporalWitnessSeed M psi) h_seed_cons
  -- Step 3: W is the witness
  use W, h_W_mcs
  constructor
  · -- ExistsTask M W: GContent M ⊆ W
    -- GContent M ⊆ ForwardTemporalWitnessSeed M psi ⊆ W
    exact Set.Subset.trans (g_content_subset_forward_temporal_witness_seed M psi) h_extends
  · -- psi ∈ W: psi ∈ ForwardTemporalWitnessSeed M psi ⊆ W
    exact h_extends (psi_mem_forward_temporal_witness_seed M psi)

/-!
## Backward P (Symmetric Key Property)

Same as forward_F but for the past direction.
-/

/--
P-backward property: If `P(psi) ∈ M` and `M` is MCS, then there exists an MCS `W`
such that `ExistsTaskPast M W` and `psi ∈ W`.

This is the past-symmetric version of canonical_forward_F.
-/
theorem canonical_backward_P (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (psi : Formula) (h_P : Formula.somePast psi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent (fc := FrameClass.Base) W ∧ ExistsTaskPast M W ∧ psi ∈
        W := by
  -- Step 1: {psi} ∪ HContent(M) is consistent
  have h_seed_cons : SetConsistent (fc := FrameClass.Base) (PastTemporalWitnessSeed M psi) :=
    past_temporal_witness_seed_consistent M h_mcs psi h_P
  -- Step 2: Extend to an MCS via Lindenbaum
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum (PastTemporalWitnessSeed M psi) h_seed_cons
  -- Step 3: W is the witness
  use W, h_W_mcs
  constructor
  · -- ExistsTaskPast M W: HContent M ⊆ W
    -- HContent M ⊆ PastTemporalWitnessSeed M psi ⊆ W
    exact Set.Subset.trans (h_content_subset_past_temporal_witness_seed M psi) h_extends
  · -- psi ∈ W: psi ∈ PastTemporalWitnessSeed M psi ⊆ W
    exact h_extends (psi_mem_past_temporal_witness_seed M psi)

/-!
## Forward U and Backward S (Until/Since Witness Properties)

These properties provide witnesses for Until/Since obligations in the canonical model.
They are key to the dovetailed chain construction (Phase 6).
-/

/--
U-forward property: If `φ U ψ ∈ M` and `M` is MCS, then there exists an MCS `W`
such that `ExistsTask M W` and `ψ ∈ W`.

**Key insight**: The until_induction axiom ensures that `{ψ} ∪ GContent(M)`
is consistent when `φ U ψ ∈ M`. This is what makes Until different from F:
with just `F(ψ) ∈ M`, the same seed consistency follows directly from the
definition of F as ¬G(¬ψ). With Until, the consistency proof uses the
induction axiom to prevent perpetual deferral of ψ.

**Usage**: In the dovetailed chain (Phase 6), when a Until obligation `φ U ψ`
is scheduled for resolution, this theorem provides the witness MCS where ψ holds.
-/
theorem canonical_forward_U (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (φ ψ : Formula) (h_U : Formula.untlQ φ ψ ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent (fc := FrameClass.Base) W ∧ ExistsTask M W ∧ ψ ∈ W := by
  -- Step 1: {ψ} ∪ GContent(M) is consistent (uses until_induction)
  have h_seed_cons : SetConsistent (fc := FrameClass.Base) (UntilWitnessSeed M ψ) :=
    until_witness_seed_consistent M h_mcs φ ψ h_U
  -- Step 2: Extend to an MCS via Lindenbaum
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum (UntilWitnessSeed M ψ) h_seed_cons
  -- Step 3: W is the witness
  use W, h_W_mcs
  constructor
  · -- ExistsTask M W: GContent M ⊆ W
    exact Set.Subset.trans (g_content_subset_until_witness_seed M ψ) h_extends
  · -- ψ ∈ W
    exact h_extends (psi_mem_until_witness_seed M ψ)

/--
S-backward property: If `φ S ψ ∈ M` and `M` is MCS, then there exists an MCS `W`
such that `ExistsTaskPast M W` and `ψ ∈ W`.

Symmetric to `canonical_forward_U` using since_induction.
-/
theorem canonical_backward_S (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (φ ψ : Formula) (h_S : Formula.snceQ φ ψ ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent (fc := FrameClass.Base) W ∧ ExistsTaskPast M W ∧ ψ ∈
        W := by
  -- Step 1: {ψ} ∪ HContent(M) is consistent (uses since_induction)
  have h_seed_cons : SetConsistent (fc := FrameClass.Base) (PastTemporalWitnessSeed M ψ) :=
    since_witness_seed_consistent M h_mcs φ ψ h_S
  -- Step 2: Extend to an MCS via Lindenbaum
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum (PastTemporalWitnessSeed M ψ) h_seed_cons
  -- Step 3: W is the witness
  use W, h_W_mcs
  constructor
  · -- ExistsTaskPast M W: HContent M ⊆ W
    exact Set.Subset.trans (h_content_subset_past_temporal_witness_seed M ψ) h_extends
  · -- ψ ∈ W
    exact h_extends (psi_mem_past_temporal_witness_seed M ψ)

/-!
## Transitivity of Canonical Relations

The canonical relations are transitive using the Temporal 4 axiom (G phi -> GG phi).
-/

/--
ExistsTask is transitive: If `ExistsTask M M'` and `ExistsTask M' M''`, then `ExistsTask M M''`.

Proof: If `G phi ∈ M`, by Temporal 4 `G phi -> GG phi`, so `GG phi ∈ M`, thus `G phi ∈ GContent M
⊆ M'`.
But wait - we need: `G phi ∈ M` implies `phi ∈ M''`.
From `G phi ∈ M` and Temp 4, `G(G phi) ∈ M`. So `G phi ∈ GContent M ⊆ M'`.
Then `phi ∈ GContent M' ⊆ M''`.
-/
theorem existsTask_transitive {fc : FrameClass} (M M' M'' : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) M)
    (h_R1 : ExistsTask M M') (h_R2 : ExistsTask M' M'') :
    ExistsTask M M'' := by
  intro phi h_G_phi
  -- phi ∈ GContent M means G phi ∈ M
  -- By Temporal 4: ⊢ G phi → G(G phi), so G(G phi) ∈ M
  have h_T4 : DerivationTree fc [] ((Formula.allFuture phi).imp
      (Formula.allFuture (Formula.allFuture phi))) :=
    (FormalSystem.Theorems.TemporalDerived.temporal4Derived phi).lift (by cases fc <;> trivial)
  have h_GG : Formula.allFuture (Formula.allFuture phi) ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T4) h_G_phi
  -- G phi ∈ GContent M, and GContent M ⊆ M' by h_R1
  have h_G_in_M' : Formula.allFuture phi ∈ M' := h_R1 h_GG
  -- phi ∈ GContent M', and GContent M' ⊆ M'' by h_R2
  exact h_R2 h_G_in_M'

/--
HContent chain transitivity: If `HContent V ⊆ N` and `HContent N ⊆ M`, then `HContent V ⊆ M`.

This is the backward (past) analogue of `existsTask_transitive`.
The proof uses the Temporal 4 axiom for the past direction: `H phi → H(H phi)`.

Given `phi ∈ HContent V` (i.e., `H phi ∈ V`):
1. By `temporal4Past`: `H(H phi) ∈ V`
2. So `H phi ∈ HContent V ⊆ N`
3. So `phi ∈ HContent N ⊆ M`
-/
theorem h_content_chain_transitive {fc : FrameClass} (M N V : Set Formula)
    (h_mcs_V : SetMaximalConsistent (fc := fc) V)
    (hNV : HContent V ⊆ N) (hMN : HContent N ⊆ M) :
    HContent V ⊆ M := by
  intro phi h_H_phi
  -- h_H_phi : phi ∈ HContent V, i.e., H phi ∈ V
  -- By Temporal 4 for H: H phi → H(H phi), so H(H phi) ∈ V
  have h_H4 : DerivationTree fc [] (phi.allPast.imp phi.allPast.allPast) :=
    (temporal4Past phi).lift (by cases fc <;> trivial)
  have h_HH_in_V := SetMaximalConsistent.implication_property h_mcs_V (theorem_in_mcs h_mcs_V h_H4)
      h_H_phi
  -- H phi ∈ HContent V, and HContent V ⊆ N, so H phi ∈ N
  have h_Hphi_in_N := hNV h_HH_in_V
  -- phi ∈ HContent N, and HContent N ⊆ M, so phi ∈ M
  exact hMN h_Hphi_in_N

end FormalSystem.Metalogic.Bundle
