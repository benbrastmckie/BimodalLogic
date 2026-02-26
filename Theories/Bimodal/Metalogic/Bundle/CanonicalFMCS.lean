import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.FMCSDef
import Bimodal.Metalogic.Bundle.DovetailingChain
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction

/-!
# Canonical FMCS Construction (All-MCS Approach)

This module constructs a FMCS over ALL maximal consistent sets using the Preorder
approach from Task 922 v5. The original plan used CanonicalReachable (future-reachable
fragment), but backward_P requires past witnesses which are NOT in the future-reachable
fragment. The solution uses ALL MCSes as the domain, making both forward_F and backward_P
trivial.

## Overview

Given a root MCS `M₀`, we construct a FMCS where:
- The domain is `CanonicalMCS` (all maximal consistent sets, with CanonicalR Preorder)
- Each element `w` maps directly to `w.world` (the MCS itself)
- `forward_G` follows from `canonical_forward_G` and the Preorder definition
- `backward_H` follows from `GContent_subset_implies_HContent_reverse` duality
- `forward_F` uses `canonical_forward_F` - the witness MCS IS a domain element
- `backward_P` uses `canonical_backward_P` - the witness MCS IS a domain element

## Key Insight (Why All-MCS, Not CanonicalReachable)

The v5 plan originally proposed using CanonicalReachable (future-reachable from M₀).
This works for forward_F (future witnesses are future-reachable by transitivity),
but FAILS for backward_P because:
- `canonical_backward_P` gives witness W with `HContent(w.world) ⊆ W`
- For W to be in CanonicalReachable, we need `CanonicalR M₀ W` (= `GContent(M₀) ⊆ W`)
- There is no TM axiom that derives `GContent(M₀) ⊆ W` from the available hypotheses
- The G and H modalities are independent; `G(phi) ∈ M₀` does NOT imply `H(phi) ∈ w.world`

The all-MCS approach sidesteps this entirely:
- Every MCS is in the domain by construction
- No reachability requirement for witnesses
- forward_F and backward_P are genuinely trivial

## Compatibility

The FMCS and TemporalCoherentFamily only require `[Preorder D]`, not totality.
The completeness chain (TruthLemma, Completeness) does NOT use totality, IsTotal,
or LinearOrder. So using the non-total CanonicalR Preorder on all MCSes is sound.

The CanonicalReachable/CanonicalQuotient constructions and their totality (IsTotal)
have been archived to Boneyard (task 933) as they are not used by any active code.

## References

- Task 922 plan v5: Preorder generalization approach
- Task 922 research-008: Confirmed Preorder approach as correct path
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## CanonicalMCS: The Type of All Maximal Consistent Sets

This type wraps all MCSes with a CanonicalR-based Preorder. Unlike CanonicalReachable,
it includes ALL MCSes, not just those future-reachable from a root. This ensures both
forward and backward witnesses are always in the domain.
-/

/--
A maximal consistent set, used as a domain element for the canonical FMCS.

This is a structure (not an abbrev for Subtype) to avoid diamond instance conflicts:
`Set Formula` has `LE` (subset), so `Subtype (Set Formula)` would inherit `Subtype.instLE`
(where `a ≤ b := a.val ⊆ b.val`). Our Preorder uses `CanonicalR` (where `a ≤ b :=
GContent(a.val) ⊆ b.val`), which is different. Using a structure avoids the conflict.
-/
structure CanonicalMCS where
  /-- The underlying set of formulas -/
  world : Set Formula
  /-- Proof that the set is maximal consistent -/
  is_mcs : SetMaximalConsistent world

/--
Preorder on CanonicalMCS via CanonicalR.

`a ≤ b` iff `CanonicalR a.world b.world` iff `GContent(a.world) ⊆ b.world`.

This is reflexive (by T-axiom: G(phi) → phi) and transitive (by Temp 4: G(phi) → G(G(phi))).
Note: this Preorder is NOT total in general. Totality only holds within the reachable
fragment from a fixed root (see CanonicalQuotient.lean). But the FMCS infrastructure
only requires Preorder, not totality.
-/
noncomputable instance : Preorder CanonicalMCS where
  le a b := CanonicalR a.world b.world
  le_refl a := canonicalR_reflexive a.world a.is_mcs
  le_trans a b c hab hbc := canonicalR_transitive a.world b.world c.world a.is_mcs hab hbc

/-!
## The Canonical FMCS on All MCSes

Construct a FMCS over CanonicalMCS where each element maps directly
to its underlying MCS.
-/

/--
The MCS assignment for the canonical FMCS: each element maps to its underlying set.

This is the identity mapping - each CanonicalMCS element IS its MCS.
-/
def canonicalMCS_mcs (w : CanonicalMCS) : Set Formula :=
  w.world

/--
Each assigned set is maximal consistent (directly from the CanonicalMCS property).
-/
theorem canonicalMCS_is_mcs (w : CanonicalMCS) :
    SetMaximalConsistent (canonicalMCS_mcs w) :=
  w.is_mcs

/--
Forward G coherence: if `w₁ ≤ w₂` and `G phi ∈ mcs w₁`, then `phi ∈ mcs w₂`.

Proof: `w₁ ≤ w₂` means `CanonicalR w₁.world w₂.world` (by Preorder definition).
Apply `canonical_forward_G`.
-/
theorem canonicalMCS_forward_G
    (w₁ w₂ : CanonicalMCS) (phi : Formula)
    (h_le : w₁ ≤ w₂) (h_G : Formula.all_future phi ∈ canonicalMCS_mcs w₁) :
    phi ∈ canonicalMCS_mcs w₂ :=
  canonical_forward_G w₁.world w₂.world h_le phi h_G

/--
Backward H coherence: if `w₂ ≤ w₁` and `H phi ∈ mcs w₁`, then `phi ∈ mcs w₂`.

Proof (using GContent/HContent duality):
1. `w₂ ≤ w₁` means `CanonicalR w₂.world w₁.world`
2. By duality: `HContent(w₁.world) ⊆ w₂.world`
3. Apply `canonical_backward_H`
-/
theorem canonicalMCS_backward_H
    (w₁ w₂ : CanonicalMCS) (phi : Formula)
    (h_le : w₂ ≤ w₁) (h_H : Formula.all_past phi ∈ canonicalMCS_mcs w₁) :
    phi ∈ canonicalMCS_mcs w₂ := by
  have h_R_past : CanonicalR_past w₁.world w₂.world :=
    GContent_subset_implies_HContent_reverse w₂.world w₁.world w₂.is_mcs w₁.is_mcs h_le
  exact canonical_backward_H w₁.world w₂.world h_R_past phi h_H

/--
The canonical FMCS on all MCSes: a family of MCS indexed by CanonicalMCS.

This construction satisfies all FMCS requirements:
- Each element maps to its own MCS (identity mapping)
- Forward G coherence via CanonicalR
- Backward H coherence via GContent/HContent duality
-/
noncomputable def canonicalMCSBFMCS : FMCS CanonicalMCS where
  mcs := canonicalMCS_mcs
  is_mcs := canonicalMCS_is_mcs
  forward_G := fun w₁ w₂ phi h_le h_G =>
    canonicalMCS_forward_G w₁ w₂ phi h_le h_G
  backward_H := fun w₁ w₂ phi h_le h_H =>
    canonicalMCS_backward_H w₁ w₂ phi h_le h_H

/-!
## Zero Instance for CanonicalMCS

Given a root MCS M₀, we use it as the zero element.
-/

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/--
Zero instance for CanonicalMCS using a given root MCS.
This is needed for TemporalCoherentFamily which requires `[Zero D]`.
-/
noncomputable instance CanonicalMCS.instZero : Zero CanonicalMCS where
  zero := { world := M₀, is_mcs := h_mcs₀ }

/-!
## Forward F and Backward P (TRIVIAL with All-MCS approach)

With ALL MCSes as the domain, both forward_F and backward_P are genuinely trivial:
- `canonical_forward_F` gives witness W which is an MCS, hence in CanonicalMCS
- `canonical_backward_P` gives witness W which is an MCS, hence in CanonicalMCS
No reachability requirement, no enriched seeds, no consistency proofs needed.
-/

/--
Forward F coherence: if `F phi ∈ mcs w`, then there exists `s ≥ w` with `phi ∈ mcs s`.

**PROVEN** (no sorry!) - The witness from `canonical_forward_F` is an MCS,
hence a CanonicalMCS element. No reachability check needed.
-/
theorem canonicalMCS_forward_F
    (w : CanonicalMCS) (phi : Formula)
    (h_F : Formula.some_future phi ∈ canonicalMCS_mcs w) :
    ∃ s : CanonicalMCS, w ≤ s ∧ phi ∈ canonicalMCS_mcs s := by
  obtain ⟨W, h_W_mcs, h_R, h_phi_W⟩ := canonical_forward_F w.world w.is_mcs phi h_F
  let s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
  exact ⟨s, h_R, h_phi_W⟩

/--
Backward P coherence: if `P phi ∈ mcs w`, then there exists `s ≤ w` with `phi ∈ mcs s`.

**PROVEN** (no sorry!) - The witness from `canonical_backward_P` is an MCS,
hence a CanonicalMCS element. The Preorder condition `s ≤ w` follows from
HContent/GContent duality. No reachability check needed.

This was the main blocker in the CanonicalReachable approach: the backward witness
is NOT future-reachable from M₀. With all-MCS domain, this is a non-issue.
-/
theorem canonicalMCS_backward_P
    (w : CanonicalMCS) (phi : Formula)
    (h_P : Formula.some_past phi ∈ canonicalMCS_mcs w) :
    ∃ s : CanonicalMCS, s ≤ w ∧ phi ∈ canonicalMCS_mcs s := by
  obtain ⟨W, h_W_mcs, h_R_past, h_phi_W⟩ := canonical_backward_P w.world w.is_mcs phi h_P
  -- W is an MCS, so it's a CanonicalMCS element (no reachability needed!)
  let s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
  -- s ≤ w means CanonicalR s.world w.world = CanonicalR W w.world
  -- This follows from HContent_subset_implies_GContent_reverse applied to h_R_past
  have h_R : CanonicalR W w.world :=
    HContent_subset_implies_GContent_reverse w.world W w.is_mcs h_W_mcs h_R_past
  exact ⟨s, h_R, h_phi_W⟩

/--
The canonical FMCS preserves the root context.

Note: We reference the root MCS directly rather than using `0` because
the Zero instance requires explicit binding of `M₀` and `h_mcs₀`.
-/
theorem canonicalMCSBFMCS_root_contains (phi : Formula) (h_mem : phi ∈ M₀) :
    phi ∈ canonicalMCSBFMCS.mcs ({ world := M₀, is_mcs := h_mcs₀ } : CanonicalMCS) :=
  h_mem

/-!
## Temporal Coherent Family Existence for CanonicalMCS

This section proves that a temporally coherent family exists over CanonicalMCS,
eliminating the generic `temporal_coherent_family_exists` sorry for this domain.

The proof:
1. Extends the consistent context Gamma to an MCS M₀ via Lindenbaum
2. Uses `canonicalMCSBFMCS` with M₀ as the root element
3. Context preservation: `mcs(root) = M₀ ⊇ Gamma` (by Lindenbaum extension)
4. Forward F: proven in `canonicalMCS_forward_F` (sorry-free)
5. Backward P: proven in `canonicalMCS_backward_P` (sorry-free)
-/

/--
Temporal coherent family existence for CanonicalMCS - SORRY-FREE.

Given a consistent context Gamma, there exists a `FMCS CanonicalMCS` and a
root element such that:
1. All formulas of Gamma are in the family's MCS at the root
2. Forward_F holds (F phi at t implies witness at s >= t)
3. Backward_P holds (P phi at t implies witness at s <= t)

This eliminates the `temporal_coherent_family_exists` sorry for `D = CanonicalMCS`.
The Int-generic version remains sorry-backed because Int uses DovetailingChain
which has F/P witness sorries.

Note: We state this with an explicit root element rather than using `0` because
the Zero instance for CanonicalMCS depends on implicit variables in scope.
-/
theorem temporal_coherent_family_exists_CanonicalMCS
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (fam : FMCS CanonicalMCS) (root : CanonicalMCS),
      (∀ gamma ∈ Gamma, gamma ∈ fam.mcs root) ∧
      (∀ t : CanonicalMCS, ∀ φ : Formula,
        Formula.some_future φ ∈ fam.mcs t → ∃ s : CanonicalMCS, t ≤ s ∧ φ ∈ fam.mcs s) ∧
      (∀ t : CanonicalMCS, ∀ φ : Formula,
        Formula.some_past φ ∈ fam.mcs t → ∃ s : CanonicalMCS, s ≤ t ∧ φ ∈ fam.mcs s) := by
  -- Step 1: Extend Gamma to MCS M₀' via Lindenbaum
  let M₀' := lindenbaumMCS Gamma h_cons
  have h_mcs₀' : SetMaximalConsistent M₀' := lindenbaumMCS_is_mcs Gamma h_cons
  have h_extends : contextAsSet Gamma ⊆ M₀' := lindenbaumMCS_extends Gamma h_cons
  -- Step 2: The root element is the Lindenbaum MCS
  let root : CanonicalMCS := { world := M₀', is_mcs := h_mcs₀' }
  -- Step 3: Use canonicalMCSBFMCS as the family
  exact ⟨canonicalMCSBFMCS, root,
    fun gamma h_mem => h_extends (by simp [contextAsSet]; exact h_mem),
    fun t φ h_F => canonicalMCS_forward_F t φ h_F,
    fun t φ h_P => canonicalMCS_backward_P t φ h_P⟩

end Bimodal.Metalogic.Bundle
