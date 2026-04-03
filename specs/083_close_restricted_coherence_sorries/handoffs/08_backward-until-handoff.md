# Handoff: Until Backward Direction (Phase 4)

## Current State

Phases 1-3 are complete. The forward direction of the Until truth lemma is proved.
The backward direction has a sorry at line ~1030 of CanonicalConstruction.lean.

## What's Done

- Phase 1: Half-open semantic change (r < s for Until guard, s < r for Since guard)
- Phase 2: Filled until_intro/since_intro soundness; marked unsound axioms as sorry
- Phase 3: Forward Until truth lemma complete (F(ψ) via U-Induction, minimal witness via Nat.strongRecOn, φ guard via G(φ U ψ) + unfold)

## The Backward Direction Problem

Goal: Given semantic Until witnesses (s >= t, ψ true at s, φ true on [t,s)), prove φ U ψ in mcs(t).

### Approach 1: Strong induction on distance + restricted_temporal_backward_G

Need G(φ U ψ) in mcs(t), which requires φ U ψ in mcs(j) for ALL j >= t.
- For j in [t+1, s]: by IH on distance s-j < s-t. Works.
- For j > s: Need φ U ψ in mcs(j) but no semantic witnesses available for j > s.
- Blocker: Cannot extend φ U ψ past the witness point s.

### Approach 2: Contradiction via forward_F

Assume neg(φ U ψ) in mcs(t). Derive F(neg(φ U ψ)) in mcs(t) via contrapositive of until_intro.
forward_F gives witness w >= t with neg(φ U ψ) in mcs(w).
- For w in (t, s]: φ U ψ in mcs(w) by IH. Contradiction.
- For w = s: φ U ψ in mcs(s) from ψ in mcs(s) + until_intro. Contradiction.
- For w > s: No contradiction available. forward_F might overshoot.
- For w = t: No progress.

### Approach 3: U-Induction with chosen chi

Use until_induction: G(ψ -> chi) ∧ G(φ ∧ chi -> G(chi)) -> (φ U ψ -> chi).
Contrapositive: neg(chi) ∧ (φ U ψ) -> neg(G(ψ -> chi)) ∨ neg(G(φ ∧ chi -> G(chi))).
Need clever choice of chi. Candidates: F(ψ), ψ ∨ F(ψ), neg(neg(φ U ψ)).
None explored to completion.

### Approach 4: Derive G(φ U ψ) at s and propagate

From ψ in mcs(s), get φ U ψ in mcs(s). If we could get G(φ U ψ) in mcs(s),
then φ U ψ in mcs(j) for all j >= s via forward_G. Combined with IH for [t,s),
this would give φ U ψ for all j >= t, enabling restricted_temporal_backward_G.

The question: how to get G(φ U ψ) from ψ in mcs(s)?
- ψ -> G(ψ) is NOT derivable.
- ψ -> G(F(ψ)) IS derivable (discreteness_forward).
- G(F(ψ)) does not give G(φ U ψ).
- Would need ψ -> G(φ U ψ), which is equivalent to ψ -> ∀ j >= s, φ U ψ at j.

### Recommended Next Steps

1. Try Approach 3 with chi = "neg(neg(φ U ψ))" (double negation) or chi chosen to
   encode "ψ will eventually hold or has already held."

2. Alternatively, examine the specific FMCS chain construction to see if forward_F
   always returns witnesses within a bounded range (the dovetailed chain construction
   has specific deferral scheduling that might guarantee this).

3. Consider adding a derived lemma: ψ ∈ mcs(s) ∧ s ≥ t ∧ φ ∈ mcs(r) for [t,s) →
   G(φ U ψ) ∈ mcs(t), proved using the chain structure rather than pure axiom manipulation.

4. Look at Xu (1988) or Reynolds (2003) for the standard Until completeness proof
   in discrete temporal logic with G-based axioms.

## Files Modified

- `Theories/Bimodal/Semantics/Truth.lean` — semantic definition change
- `Theories/Bimodal/Metalogic/Soundness.lean` — until_intro/since_intro proofs
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` — forward Until proof + sorry backward

## Build Status

`lake build` passes with 35 sorry warnings (2 original Until/Since sorries partially replaced;
the backward directions remain sorry; Since case fully sorry).
