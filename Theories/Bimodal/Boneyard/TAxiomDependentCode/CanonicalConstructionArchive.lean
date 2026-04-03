/-
  ARCHIVED: T-Axiom Dependent Code from CanonicalConstruction.lean
  Date: 2026-04-03
  Reason: The forward_G/backward_H fields depend on the T-axiom,
          which is NOT valid under strict temporal semantics.
          Independent Lindenbaum extensions cannot propagate G/H across time points.
  Source: Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean
  Task: 83 Phase 1

  This file does NOT compile. It is preserved for historical reference only.
-/

-- ORIGINAL: lines 1003-1058
noncomputable def restricted_tc_family_to_fmcs (phi : Formula)
    (rtcf : RestrictedTemporallyCoherentFamily phi) : FMCS Int where
  mcs := fun t => restricted_chain_ext phi rtcf t
  is_mcs := fun t => restricted_chain_ext_is_mcs phi rtcf t
  forward_G := fun t t' ψ htt' h_G => by
    -- G(ψ) ∈ extended MCS at t
    -- Need: ψ ∈ extended MCS at t'
    --
    -- Approach:
    -- 1. If t = t': use T-axiom (G(ψ) → ψ derivable, MCS closed under derivation)
    -- 2. If t < t': use a combination of MCS properties and chain structure
    --
    -- For MCS: G(ψ) → ψ is derivable via temp_t_future axiom
    -- Since MCS is closed under derivation, G(ψ) ∈ M implies ψ ∈ M (at same time)
    --
    -- For t < t' case:
    -- The extended MCSes are independent Lindenbaum extensions, so they don't
    -- directly preserve G-propagation. However, we can use the fact that:
    -- - Every MCS contains all theorems
    -- - G(ψ) → ψ is derivable
    -- - But this only gives ψ at t, not at t'
    --
    -- The key insight: for formulas in deferralClosure, we can use the restricted
    -- chain's Succ properties. For arbitrary formulas, we use MCS maximality.
    --
    -- Actually, looking at this more carefully:
    -- The extended MCS at t' is independent of the one at t.
    -- We CANNOT prove G(ψ) at t implies ψ at t' in general!
    --
    -- HOWEVER: For completeness, we only evaluate ONE formula (phi or neg(phi)).
    -- The truth lemma is only applied to the evaluation formula and its subformulas.
    -- For these formulas, we can check if ψ ∈ deferralClosure.
    --
    -- The cleanest solution: prove this for ALL formulas using MCS properties.
    --
    -- For now: apply T-axiom at t', since all MCS are independent.
    -- G(ψ) at t doesn't help for t' independently, but...
    --
    -- Wait, there's a simpler argument:
    -- At t': G(ψ) → ψ is a theorem (temp_t_future)
    -- If G(ψ) ∈ MCS at t', then ψ ∈ MCS at t' (by MCS closure)
    -- The question is: is G(ψ) ∈ MCS at t' given G(ψ) ∈ MCS at t?
    --
    -- This is NOT necessarily true for independent extensions.
    -- The gap remains for the general case.
    --
    -- For completeness purposes, we use a weaker property:
    -- Build a variant that only satisfies forward_G for subformulaClosure formulas.
    --
    -- Since this blocks the general FMCS construction, we use sorry for now
    -- and implement completeness via a different path.
    sorry
  backward_H := fun t t' ψ htt' h_H => by
    -- Symmetric to forward_G: H(ψ) → ψ via temp_t_past, but
    -- we cannot propagate across independent Lindenbaum extensions.
    sorry
