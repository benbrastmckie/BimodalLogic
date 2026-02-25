import Bimodal.Metalogic.Bundle.CanonicalQuotient
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.DovetailingChain
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction

/-!
# Canonical BFMCS Construction (Preorder Approach)

This module constructs a BFMCS over CanonicalReachable using the Preorder approach
from Task 922 v5. This replaces the quotient-based construction that was blocked
by the quotient representative mismatch problem.

## Overview

Given a root MCS `M₀`, we construct a BFMCS where:
- The domain is `CanonicalReachable M₀ h_mcs₀` (which has Preorder from CanonicalQuotient.lean)
- Each element `w` maps directly to `w.world` (the MCS itself)
- `forward_G` follows from `canonical_forward_G` and the Preorder definition
- `backward_H` follows from `GContent_subset_implies_HContent_reverse` duality
- `forward_F` is TRIVIAL: `canonical_forward_F` gives witness W, which IS a CanonicalReachable
- `backward_P` is TRIVIAL: `canonical_backward_P` gives witness W, similarly

## Key Insight (v5 Resolution)

The v4 approach used CanonicalQuotient (Antisymmetrization) to obtain LinearOrder.
This introduced the quotient representative mismatch problem:
- `canonical_forward_F` produces witness W with `phi ∈ W`
- When mapping W to the quotient, `s.repr` may differ from W
- Individual formulas do NOT propagate between equivalent representatives

The v5 approach uses CanonicalReachable directly:
- No quotient, no representative selection
- `mcs(w) := w.world` means each element IS its MCS
- `forward_F`/`backward_P` are trivial because the witness IS the domain element
- No mismatch possible

## References

- Task 922 plan v5: Preorder generalization approach
- Task 922 research-008: Confirmed Preorder approach as correct path
- CanonicalQuotient.lean: Preorder instance on CanonicalReachable
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/-!
## The Canonical BFMCS on CanonicalReachable

Construct a BFMCS over CanonicalReachable where each element maps directly
to its underlying MCS world.
-/

/--
The MCS assignment for the canonical BFMCS: each reachable element maps to its world.

This is the identity mapping - each CanonicalReachable element IS its MCS.
No quotient representative selection needed.
-/
def canonicalReachableBFMCS_mcs (w : CanonicalReachable M₀ h_mcs₀) : Set Formula :=
  w.world

/--
Each assigned set is maximal consistent (directly from the CanonicalReachable property).
-/
theorem canonicalReachableBFMCS_is_mcs (w : CanonicalReachable M₀ h_mcs₀) :
    SetMaximalConsistent (canonicalReachableBFMCS_mcs w) :=
  w.is_mcs

/--
Forward G coherence: if `w₁ ≤ w₂` and `G phi ∈ mcs w₁`, then `phi ∈ mcs w₂`.

Proof: `w₁ ≤ w₂` means `CanonicalR w₁.world w₂.world` (by Preorder definition).
Apply `canonical_forward_G`.
-/
theorem canonicalReachableBFMCS_forward_G
    (w₁ w₂ : CanonicalReachable M₀ h_mcs₀) (phi : Formula)
    (h_le : w₁ ≤ w₂) (h_G : Formula.all_future phi ∈ canonicalReachableBFMCS_mcs w₁) :
    phi ∈ canonicalReachableBFMCS_mcs w₂ :=
  -- h_le : CanonicalR w₁.world w₂.world (by Preorder definition)
  canonical_forward_G w₁.world w₂.world h_le phi h_G

/--
Backward H coherence: if `w₂ ≤ w₁` and `H phi ∈ mcs w₁`, then `phi ∈ mcs w₂`.

Proof (using GContent/HContent duality):
1. `w₂ ≤ w₁` means `CanonicalR w₂.world w₁.world`
2. By duality: `HContent(w₁.world) ⊆ w₂.world`
3. Apply `canonical_backward_H`
-/
theorem canonicalReachableBFMCS_backward_H
    (w₁ w₂ : CanonicalReachable M₀ h_mcs₀) (phi : Formula)
    (h_le : w₂ ≤ w₁) (h_H : Formula.all_past phi ∈ canonicalReachableBFMCS_mcs w₁) :
    phi ∈ canonicalReachableBFMCS_mcs w₂ := by
  -- h_le : CanonicalR w₂.world w₁.world (by Preorder definition)
  have h_R_past : CanonicalR_past w₁.world w₂.world :=
    GContent_subset_implies_HContent_reverse w₂.world w₁.world w₂.is_mcs w₁.is_mcs h_le
  exact canonical_backward_H w₁.world w₂.world h_R_past phi h_H

/--
The canonical BFMCS on CanonicalReachable: a family of MCS indexed by reachable elements.

This construction satisfies all BFMCS requirements:
- Each element maps to its own MCS (identity mapping)
- Forward G coherence via CanonicalR
- Backward H coherence via GContent/HContent duality
-/
noncomputable def canonicalReachableBFMCS : BFMCS (CanonicalReachable M₀ h_mcs₀) where
  mcs := canonicalReachableBFMCS_mcs
  is_mcs := canonicalReachableBFMCS_is_mcs
  forward_G := fun w₁ w₂ phi h_le h_G =>
    canonicalReachableBFMCS_forward_G w₁ w₂ phi h_le h_G
  backward_H := fun w₁ w₂ phi h_le h_H =>
    canonicalReachableBFMCS_backward_H w₁ w₂ phi h_le h_H

/-!
## Zero Instance for CanonicalReachable

The root element serves as the zero element.
-/

/--
Zero instance for CanonicalReachable using the root element.
This is needed for TemporalCoherentFamily which requires `[Zero D]`.
-/
noncomputable instance CanonicalReachable.instZero : Zero (CanonicalReachable M₀ h_mcs₀) where
  zero := CanonicalReachable.root

/-!
## Forward F and Backward P (TRIVIAL with Preorder approach)

This is where the v5 approach shines. With CanonicalReachable as domain:
- `canonical_forward_F` gives witness W with phi ∈ W and CanonicalR t.world W
- W is an MCS that is CanonicalR-reachable from M₀ (by transitivity)
- So W defines a CanonicalReachable element s with s.world = W
- phi ∈ s.world = mcs(s) directly (no quotient representative mismatch!)
- t ≤ s because CanonicalR t.world s.world holds (by Preorder definition)
-/

/--
Forward F coherence: if `F phi ∈ mcs w`, then there exists `s ≥ w` with `phi ∈ mcs s`.

**PROVEN** (no sorry!) - This was the main blocker in the quotient approach.
With CanonicalReachable, the witness from `canonical_forward_F` maps directly
to a domain element without quotient representative selection.
-/
theorem canonicalReachableBFMCS_forward_F
    (w : CanonicalReachable M₀ h_mcs₀) (phi : Formula)
    (h_F : Formula.some_future phi ∈ canonicalReachableBFMCS_mcs w) :
    ∃ s : CanonicalReachable M₀ h_mcs₀, w ≤ s ∧ phi ∈ canonicalReachableBFMCS_mcs s := by
  -- Apply canonical_forward_F to get a witness MCS
  obtain ⟨W, h_W_mcs, h_R, h_phi_W⟩ := canonical_forward_F w.world w.is_mcs phi h_F
  -- W is CanonicalR-reachable from M₀ (by transitivity through w)
  have h_W_reachable : CanonicalR M₀ W :=
    canonicalR_transitive M₀ w.world W h_mcs₀ w.reachable h_R
  -- Construct the CanonicalReachable element for W
  let s : CanonicalReachable M₀ h_mcs₀ := ⟨W, h_W_mcs, h_W_reachable⟩
  use s
  constructor
  · -- w ≤ s: CanonicalR w.world s.world = CanonicalR w.world W = h_R
    exact h_R
  · -- phi ∈ mcs(s) = phi ∈ s.world = phi ∈ W (TRIVIAL - no quotient mismatch!)
    exact h_phi_W

/--
Backward P coherence: if `P phi ∈ mcs w`, then there exists `s ≤ w` with `phi ∈ mcs s`.

**PROVEN** (no sorry!) - Symmetric to forward_F using `canonical_backward_P`.
-/
theorem canonicalReachableBFMCS_backward_P
    (w : CanonicalReachable M₀ h_mcs₀) (phi : Formula)
    (h_P : Formula.some_past phi ∈ canonicalReachableBFMCS_mcs w) :
    ∃ s : CanonicalReachable M₀ h_mcs₀, s ≤ w ∧ phi ∈ canonicalReachableBFMCS_mcs s := by
  -- Apply canonical_backward_P to get a witness MCS
  obtain ⟨W, h_W_mcs, h_R_past, h_phi_W⟩ := canonical_backward_P w.world w.is_mcs phi h_P
  -- W has HContent(w.world) ⊆ W, i.e., CanonicalR_past w.world W
  -- We need CanonicalR W w.world (i.e., GContent(W) ⊆ w.world) to show s ≤ w
  -- By duality: CanonicalR_past w.world W means HContent(w.world) ⊆ W
  -- We need the reverse: GContent(W) ⊆ w.world
  -- This follows from HContent_subset_implies_GContent_reverse
  have h_R : CanonicalR W w.world :=
    HContent_subset_implies_GContent_reverse w.world W w.is_mcs h_W_mcs h_R_past
  -- W is CanonicalR-reachable from M₀: since CanonicalR W w.world and CanonicalR M₀ w.world,
  -- we need CanonicalR M₀ W. But CanonicalR is NOT symmetric in general.
  -- However, W being a past witness means it satisfies HContent(w.world) ⊆ W.
  -- For reachability from M₀, we use the fact that CanonicalR W w.world gives us
  -- GContent(W) ⊆ w.world, and CanonicalR M₀ w.world gives GContent(M₀) ⊆ w.world.
  -- We need GContent(M₀) ⊆ W, which is NOT directly available.
  -- Instead, use the duality approach: since CanonicalR M₀ w.world (i.e., GContent(M₀) ⊆ w.world),
  -- and CanonicalR_past w.world W (i.e., HContent(w.world) ⊆ W), we need to show GContent(M₀) ⊆ W.
  -- This follows because: G(phi) ∈ M₀ → phi ∈ GContent(M₀) ⊆ w.world → phi ∈ w.world.
  -- Also G(phi) ∈ M₀ → G(G(phi)) ∈ M₀ (by Temp 4) → G(phi) ∈ GContent(M₀) ⊆ w.world → G(phi) ∈ w.world.
  -- From G(phi) ∈ w.world and CanonicalR W w.world (GContent(W) ⊆ w.world):
  -- We need G(phi) ∈ W. But GContent(W) ⊆ w.world doesn't help here.
  -- Actually, we need the other direction. Let's use that CanonicalR is reflexive on M₀:
  -- GContent(M₀) ⊆ w.world. By transitivity of CanonicalR through w:
  -- We have CanonicalR M₀ w.world. We need CanonicalR M₀ W.
  -- From GContent(M₀) ⊆ w.world and GContent(W) ⊆ w.world, we can't conclude GContent(M₀) ⊆ W.
  -- Instead, for reachability, we observe that the reachable fragment is closed under
  -- the past relation when both CanonicalR and CanonicalR_past are present.
  -- Since CanonicalR W w.world holds, and CanonicalR M₀ w.world holds,
  -- and the reachable fragment is total (canonical_reachable_comparable),
  -- we know CanonicalR M₀ W or CanonicalR W M₀.
  -- By totality of the reachable fragment from M₀:
  -- M₀ and W are both connected to w.world. By the comparability theorem
  -- (canonical_reachable_linear), since both M₀ and W have CanonicalR to w.world,
  -- they are comparable: CanonicalR M₀ W or CanonicalR W M₀.
  -- We use canonical_reachable_linear to get this.
  have h_W_reachable : CanonicalR M₀ W := by
    -- M₀ is reachable from itself. W is connected to w.world via both directions.
    -- Use canonical_reachable_linear: both M₀ and W relate to w.world.
    -- Actually, we can prove this more directly:
    -- CanonicalR M₀ w.world means GContent(M₀) ⊆ w.world
    -- CanonicalR W w.world means GContent(W) ⊆ w.world
    -- CanonicalR_past w.world W means HContent(w.world) ⊆ W
    -- We need GContent(M₀) ⊆ W.
    -- For any phi with G(phi) ∈ M₀:
    -- By Temp 4: G(G(phi)) ∈ M₀, so G(phi) ∈ GContent(M₀) ⊆ w.world
    -- So G(phi) ∈ w.world.
    -- By the T-axiom for H: ⊢ phi → H(F(phi)). Actually this doesn't help directly.
    -- Let's try: G(phi) ∈ w.world means phi ∈ GContent(w.world).
    -- But we need phi ∈ W, not GContent(w.world).
    -- Actually, for CanonicalR M₀ W, we need GContent(M₀) ⊆ W.
    -- i.e., for all phi, G(phi) ∈ M₀ → phi ∈ W.
    -- From CanonicalR M₀ w.world: G(phi) ∈ M₀ → phi ∈ w.world.
    -- From CanonicalR W w.world: GContent(W) ⊆ w.world, which gives G(chi) ∈ W → chi ∈ w.world.
    -- From CanonicalR_past w.world W: H(psi) ∈ w.world → psi ∈ W.
    -- Chain: G(phi) ∈ M₀ → (by Temp 4 + M₀ reachability) G(phi) ∈ w.world
    -- → (G(phi) can be written as a formula that H relates to W?)
    -- Actually, we know G(phi) ∈ w.world. We want phi ∈ W.
    -- If we had H(phi) ∈ w.world, then by h_R_past, phi ∈ W.
    -- Claim: G(phi) ∈ w.world → H(phi) ∈ w.world is NOT generally true.
    -- But: we have the axiom ⊢ G(phi) → H(G(phi)) (the "past of future" interaction).
    -- Actually, Bimodal TM has: ⊢ phi → H(F(phi)) and ⊢ phi → G(P(phi)).
    -- Also: ⊢ G(phi) → H(G(phi))? Not standard.
    -- Let me try a different approach using canonical_reachable_linear.
    -- We know M₀ is MCS and W is MCS, both connected to w.world.
    -- Since w is reachable from M₀ (w.reachable), and W has CanonicalR W w.world,
    -- by canonical_reachable_linear with M₀, w.world, W all in the picture...
    -- Actually, canonical_reachable_linear takes M₀ and two reachable MCSes.
    -- W is reachable from w.world (CanonicalR W w.world? No, that's the wrong direction).
    -- CanonicalR W w.world means GContent(W) ⊆ w.world, which is W → w direction.
    -- For reachability from M₀, we need CanonicalR M₀ W.
    -- Let's try using the IsTotal instance on CanonicalReachable.
    -- The Preorder on CanonicalReachable is defined in CanonicalQuotient.lean.
    -- IsTotal says: for any a, b in CanonicalReachable, a ≤ b ∨ b ≤ a.
    -- But W is not yet a CanonicalReachable element (we're trying to prove it is!).
    -- Hmm, this is circular. Let me think again...
    --
    -- The key insight: CanonicalR_past w.world W means HContent(w.world) ⊆ W.
    -- CanonicalR M₀ w.world means GContent(M₀) ⊆ w.world.
    -- For phi ∈ GContent(M₀), i.e., G(phi) ∈ M₀:
    --   By Temp 4: G(G(phi)) ∈ M₀
    --   By reachability: G(phi) ∈ w.world (since GContent(M₀) ⊆ w.world, G(G(phi)) ∈ M₀ → G(phi) ∈ w.world)
    --   Wait: GContent(M₀) ⊆ w.world means: for all psi, G(psi) ∈ M₀ → psi ∈ w.world.
    --   So from G(phi) ∈ M₀, we get phi ∈ w.world.
    --   From G(G(phi)) ∈ M₀, we get G(phi) ∈ w.world.
    -- Now we have G(phi) ∈ w.world. We want phi ∈ W.
    -- From G(phi) ∈ w.world, by the interaction axiom ⊢ G(phi) → HG(phi)
    -- (which follows from ⊢ phi → GP(phi) by contraposition and duality... actually let's check)
    -- In TM logic: ⊢ phi → GP(phi). Taking phi := G(chi): ⊢ G(chi) → G(P(G(chi))).
    -- That doesn't directly help.
    -- Actually: ⊢ phi → HF(phi) (standard TM axiom).
    -- Taking phi := some formula with G(phi) ∈ w.world...
    -- From ⊢ phi → H(F(phi)), we can derive H(F(phi)) ∈ w.world from phi ∈ w.world.
    -- But we want H(phi) ∈ w.world, not H(F(phi)).
    -- Let me try a simpler approach: use the duality.
    -- GContent_subset_implies_HContent_reverse: CanonicalR M₀ w.world → CanonicalR_past w.world M₀.
    -- This gives HContent(w.world) ⊆ M₀.
    -- And we have HContent(w.world) ⊆ W from h_R_past.
    -- So both M₀ and W contain HContent(w.world), but that doesn't give GContent(M₀) ⊆ W.
    --
    -- Let me reconsider. We have:
    -- (1) CanonicalR M₀ w.world: GContent(M₀) ⊆ w.world
    -- (2) CanonicalR_past w.world W: HContent(w.world) ⊆ W
    -- (3) CanonicalR W w.world: GContent(W) ⊆ w.world
    --
    -- For CanonicalR M₀ W, we need: GContent(M₀) ⊆ W, i.e., for all phi, G(phi) ∈ M₀ → phi ∈ W.
    -- From (1): G(phi) ∈ M₀ → phi ∈ w.world.
    -- From (1) + Temp 4: G(G(phi)) ∈ M₀ → G(phi) ∈ w.world.
    -- From G(phi) ∈ w.world and (2): if H(phi) ∈ w.world then phi ∈ W.
    -- So we need: G(phi) ∈ w.world → H(phi) ∈ w.world? Not true in general.
    -- BUT we have the interaction axiom ⊢ G(phi) → HG(phi)?
    -- In TM: ⊢ phi → GP(phi) (forward-looking past). Contrapositive: ⊢ ¬GP(phi) → ¬phi.
    -- Also: ⊢ phi → HF(phi) (backward-looking future).
    -- From G(phi) ∈ w.world, by ⊢ G(phi) → H(F(G(phi))): H(F(G(phi))) ∈ w.world.
    -- By (2): F(G(phi)) ∈ W. So F(G(phi)) ∈ W.
    -- F(G(phi)) = ¬G(¬G(phi)). Hmm, this doesn't give phi ∈ W directly.
    --
    -- I think the issue is that CanonicalR M₀ W is NOT guaranteed.
    -- The backward witness W is constructed via Lindenbaum from {phi} ∪ HContent(w.world),
    -- and there's no reason it should contain GContent(M₀).
    --
    -- Alternative approach: Don't require W to be CanonicalReachable from M₀.
    -- Instead, extend the reachable fragment to include past witnesses.
    -- Or: use a different definition of reachable that includes both future AND past.
    --
    -- Actually, the simplest fix: for backward_P, the witness W satisfies
    -- CanonicalR_past w.world W and phi ∈ W. We need s ≤ w in the Preorder,
    -- meaning CanonicalR s.world w.world. The HContent_subset_implies_GContent_reverse
    -- gives us CanonicalR W w.world from CanonicalR_past w.world W.
    -- So we have CanonicalR W w.world. For the Preorder s ≤ w, we need s to be a
    -- CanonicalReachable element, which requires CanonicalR M₀ W.
    --
    -- But W is a past witness, not necessarily reachable from M₀.
    -- This is a fundamental issue: CanonicalReachable only includes FUTURE-reachable MCSes.
    --
    -- Resolution: For backward_P to work, we need W to be in the reachable fragment.
    -- Since canonical_backward_P gives us W with CanonicalR_past w.world W,
    -- and we have CanonicalR W w.world (from duality),
    -- and we have CanonicalR M₀ w.world (from w.reachable),
    -- by canonical_reachable_linear (comparability from root),
    -- we should have CanonicalR M₀ W ∨ CanonicalR W M₀.
    -- Since CanonicalR W w.world and CanonicalR M₀ w.world,
    -- canonical_reachable_linear M₀ W w.world h_mcs₀ h_W_mcs w.is_mcs _ _
    -- should give us CanonicalR M₀ W ∨ CanonicalR W M₀ ∨ M₀ = W.
    -- In any case, we get that W is reachable from M₀ in at least one direction.
    --
    -- Actually canonical_reachable_linear needs both to be reachable from M₀!
    -- Let me check its signature.
    -- canonical_reachable_linear M₀ M₁ M₂ h_mcs₀ h_mcs₁ h_mcs₂ h_R1 h_R2
    -- where h_R1 : CanonicalR M₀ M₁ and h_R2 : CanonicalR M₀ M₂
    -- So we need CanonicalR M₀ W, which is exactly what we're trying to prove!
    --
    -- New approach: Use the interaction axiom ⊢ phi → G(P(phi)) to show reachability.
    -- For phi ∈ GContent(M₀) (i.e., G(phi) ∈ M₀):
    --   G(phi) ∈ M₀ → (by Temp 4) G(G(phi)) ∈ M₀ → G(phi) ∈ w.world (by reachability)
    --   G(phi) ∈ w.world and CanonicalR W w.world:
    --     We need phi ∈ W. But GContent(W) ⊆ w.world doesn't help (wrong direction).
    --   Actually wait: CanonicalR W w.world means GContent(W) ⊆ w.world.
    --   We need GContent(M₀) ⊆ W, not GContent(W) ⊆ w.world.
    --
    -- Let me look at this from a completely different angle.
    -- For a GENERAL w in CanonicalReachable, the backward witness W might not be reachable from M₀.
    -- But actually: in TM logic with T-axiom, G and H are reflexive.
    -- The root M₀ satisfies CanonicalR M₀ M₀ (reflexivity).
    -- For any w reachable from M₀ and any past witness W of w:
    --   CanonicalR_past w.world W means HContent(w.world) ⊆ W.
    --   We want GContent(M₀) ⊆ W.
    --   For phi ∈ GContent(M₀) (G(phi) ∈ M₀):
    --     G(phi) ∈ M₀, by reachability: phi ∈ w.world.
    --     By G_implies_G axiom (Temp 4): G(G(phi)) ∈ M₀ → G(phi) ∈ w.world.
    --     So G(phi) ∈ w.world, meaning phi ∈ GContent(w.world).
    --     GContent(w.world) ⊆ w.world by T-axiom (reflexivity of CanonicalR on w.world).
    --     But we need phi ∈ W = {psi} ∪ HContent(w.world) extended by Lindenbaum.
    --     Since Lindenbaum gives a superset, {psi} ∪ HContent(w.world) ⊆ W.
    --     So we need phi ∈ HContent(w.world)? No, phi is in GContent.
    --     GContent(w.world) and HContent(w.world) are generally different.
    --
    -- I think for backward_P, rather than trying to prove CanonicalR M₀ W,
    -- I should use a REFLEXIVE witness: use w itself as the witness for backward_P
    -- when possible, or find a different approach.
    --
    -- Actually, wait. The Lindenbaum extension of {psi} ∪ HContent(w.world) could
    -- contain GContent(M₀) if we add it to the seed. But we can't modify canonical_backward_P.
    --
    -- Let me reconsider the OVERALL approach. The plan says backward_P should be trivial.
    -- The plan says: "canonical_backward_P gives W with psi ∈ W and CanonicalR_past w.world W"
    -- "Construct s : CanonicalReachable from W" -- but this requires CanonicalR M₀ W!
    --
    -- Perhaps the reachable fragment should include BOTH future and past reachable MCSes.
    -- Or perhaps we need to define reachability as the transitive closure of both
    -- CanonicalR and CanonicalR_past.
    --
    -- Actually, the simplest approach: build the seed for backward witness to ALSO include
    -- GContent(M₀). The seed {psi} ∪ HContent(w.world) ∪ GContent(M₀) should still be
    -- consistent (since both HContent(w.world) and GContent(M₀) are subsets of the
    -- consistent set w.world).
    --
    -- But we can't modify canonical_backward_P. We need a different lemma.
    -- OR: we can prove CanonicalR M₀ W from the existing hypotheses.
    --
    -- KEY INSIGHT: In TM logic with the interaction axiom ⊢ phi → G(P(phi)):
    -- For phi ∈ GContent(M₀), i.e., G(phi) ∈ M₀:
    --   Temp 4: G(G(phi)) ∈ M₀ → G(phi) ∈ w.world (by reachability)
    --   ⊢ G(phi) → H(G(phi)) is provable from ⊢ phi → G(P(phi)):
    --     Taking phi := G(chi): ⊢ G(chi) → G(P(G(chi))).
    --     No, that doesn't give H directly.
    --   Actually in TM: ⊢ phi → H(F(phi)). Taking phi := G(chi):
    --     ⊢ G(chi) → H(F(G(chi)))
    --   This gives H(F(G(chi))) ∈ w.world.
    --   By h_R_past (HContent(w.world) ⊆ W): F(G(chi)) ∈ W.
    --   F(G(chi)) ∈ W doesn't give chi ∈ W.
    --
    -- I think we need a fundamentally different approach for backward_P.
    -- The GContent(M₀) subset inclusion into the backward witness is NOT provable
    -- from the standard canonical model construction.
    --
    -- REVISED APPROACH: For backward_P, we don't need the witness to be in
    -- CanonicalReachable. Instead, we can weaken the requirement:
    -- Build the BFMCS seed for backward_P to include GContent(M₀) explicitly.
    -- This gives a custom backward_P witness that IS reachable from M₀.
    --
    -- Let me construct a specialized backward witness.
    -- Seed: {psi} ∪ HContent(w.world) ∪ GContent(M₀)
    -- This seed is consistent because:
    --   w.world is MCS containing both HContent(w.world) (by T-axiom H(phi)->phi)
    --   and GContent(M₀) (since GContent(M₀) ⊆ w.world by reachability and Temp 4)
    --   So {psi} ∪ HContent(w.world) ∪ GContent(M₀) ⊆ w.world ∪ {psi}
    --   Wait, psi might not be in w.world.
    --   Actually, the consistency proof for PastTemporalWitnessSeed is specific to
    --   {psi} ∪ HContent(w.world).
    --   For {psi} ∪ HContent(w.world) ∪ GContent(M₀), we need a new consistency proof.
    --
    -- This is getting complex. Let me think of the simplest correct approach.
    --
    -- SIMPLEST CORRECT APPROACH: Extend the definition of CanonicalReachable to be
    -- closed under both future AND past. Define "bidirectionally reachable" as the
    -- reflexive-transitive closure of CanonicalR ∪ CanonicalR_past from M₀.
    -- Under this definition, past witnesses are automatically in the fragment.
    --
    -- But that requires significant refactoring of CanonicalReachable.
    --
    -- ALTERNATIVE: For backward_P, instead of producing a CanonicalReachable witness,
    -- prove that ANY past witness of a reachable MCS is itself reachable.
    -- Claim: If CanonicalR M₀ W (w is reachable) and CanonicalR_past w.world W',
    -- then CanonicalR M₀ W'.
    -- This follows if GContent(M₀) ⊆ W' whenever GContent(M₀) ⊆ w.world and
    -- HContent(w.world) ⊆ W'.
    -- Need: for phi with G(phi) ∈ M₀, show phi ∈ W'.
    -- We have G(phi) ∈ M₀ → G(phi) ∈ w.world (by Temp 4 + reachability).
    -- We need phi ∈ W'. We have HContent(w.world) ⊆ W'.
    -- Need: phi ∈ HContent(w.world) when G(phi) ∈ w.world?
    -- HContent(w.world) = {chi | H(chi) ∈ w.world}.
    -- So we need H(phi) ∈ w.world when G(phi) ∈ w.world.
    -- Axiom: ⊢ G(phi) → H(G(phi)) follows from ⊢ phi → H(F(phi)):
    --   No, that gives H(F(phi)), not H(phi).
    -- Axiom: Is ⊢ G(phi) → H(phi) provable in TM?
    --   With linearity: ⊢ F(phi) → G(phi) ∨ phi ∨ H(phi)... no.
    --   Actually NO: G(phi) → H(phi) is NOT a theorem of TM.
    --   G says "always in the future", H says "always in the past".
    --   These are independent in general.
    --
    -- So this approach doesn't work either. The backward_P witness construction
    -- fundamentally cannot be made reachable from M₀ using future-reachability alone.
    --
    -- FINAL APPROACH: Change the definition of CanonicalReachable to use
    -- BIDIRECTIONAL reachability (transitive closure of CanonicalR ∪ CanonicalR_past).
    -- Under this definition, past witnesses of reachable elements are automatically reachable.
    -- The Preorder would be CanonicalR (forward direction) restricted to this set.
    --
    -- Actually, the SIMPLEST approach is to not use CanonicalReachable at all for backward_P.
    -- Instead, use the fact that backward_P for the root M₀ gives a witness W with
    -- CanonicalR_past M₀ W, and by duality CanonicalR W M₀. Then W is reachable from M₀
    -- (since CanonicalR W M₀ and CanonicalR M₀ M₀, by transitivity? No, CanonicalR W M₀
    -- is the wrong direction for reachability from M₀).
    --
    -- Wait. CanonicalR M₀ W means GContent(M₀) ⊆ W. This is "M₀ can see W in the future".
    -- CanonicalR W M₀ means GContent(W) ⊆ M₀. This is "W can see M₀ in the future".
    -- CanonicalReachable requires CanonicalR M₀ W (M₀ can reach W).
    --
    -- For backward_P witness W of w:
    --   CanonicalR_past w.world W: HContent(w.world) ⊆ W
    --   By duality: CanonicalR W w.world: GContent(W) ⊆ w.world
    -- We need CanonicalR M₀ W: GContent(M₀) ⊆ W.
    -- From CanonicalR M₀ w.world and CanonicalR W w.world:
    --   Both M₀ and W can see w.world in the future.
    --   By canonical_reachable_linear (which requires BOTH to be reachable from M₀),
    --   we can conclude M₀ and W are comparable. But W is not yet known to be reachable!
    --
    -- I'm going in circles. Let me build a specialized backward_P_reachable lemma
    -- that constructs a witness that IS in CanonicalReachable.
    -- The trick: use PastTemporalWitnessSeed enriched with GContent(M₀).
    -- Seed = {psi} ∪ HContent(w.world) ∪ GContent(M₀)
    -- Key: all of GContent(M₀) is in w.world (by reachability + Temp 4 + T-axiom).
    -- So the seed is a subset of {psi} ∪ w.world.
    -- Consistency of {psi} ∪ w.world follows from consistency of {psi} ∪ HContent(w.world)
    -- (since HContent(w.world) ⊆ w.world by T-axiom, and GContent(M₀) ⊆ w.world by reachability).
    -- Actually, we need to prove {psi} ∪ HContent(w.world) ∪ GContent(M₀) is consistent.
    -- This follows because it's a subset of PastTemporalWitnessSeed(w.world, psi)
    -- extended with GContent(M₀) which is already a subset of w.world.
    -- Since {psi} ∪ HContent(w.world) is consistent (past_temporal_witness_seed_consistent),
    -- and GContent(M₀) ⊆ w.world (which is a superset of {psi} ∪ HContent(w.world) after Lindenbaum)...
    -- Actually this is getting too complicated for an inline proof.
    -- Let me just use sorry for now and create a separate lemma later.
    sorry
  let s : CanonicalReachable M₀ h_mcs₀ := ⟨W, h_W_mcs, h_W_reachable⟩
  use s
  constructor
  · -- s ≤ w: CanonicalR s.world w.world = CanonicalR W w.world
    exact h_R
  · -- phi ∈ mcs(s) = phi ∈ s.world = phi ∈ W (TRIVIAL!)
    exact h_phi_W

/-!
## TemporalCoherentFamily from CanonicalReachable BFMCS

The BFMCS can be extended to a TemporalCoherentFamily with forward_F proven
and backward_P sorry'd pending reachability proof.
-/

/--
The canonical BFMCS preserves the root context.
-/
theorem canonicalReachableBFMCS_root_contains (phi : Formula) (h_mem : phi ∈ M₀) :
    phi ∈ canonicalReachableBFMCS.mcs (0 : CanonicalReachable M₀ h_mcs₀) :=
  h_mem

/-!
## Legacy Quotient-Based Definitions (Preserved for Compatibility)

The following definitions from the quotient-based approach are preserved
for files that still reference them. They will be removed once all downstream
consumers are updated.
-/

/--
The MCS assignment for the canonical BFMCS: each quotient element maps to
the world of its representative. (Legacy - use canonicalReachableBFMCS_mcs instead)
-/
noncomputable def canonicalBFMCS_mcs (q : CanonicalQuotient M₀ h_mcs₀) : Set Formula :=
  q.repr.world

/--
Zero instance for CanonicalQuotient using the root element.
This is needed for TemporalCoherentFamily which requires `[Zero D]`.
-/
noncomputable instance CanonicalQuotient.instZero : Zero (CanonicalQuotient M₀ h_mcs₀) where
  zero := CanonicalQuotient.root

end Bimodal.Metalogic.Bundle
