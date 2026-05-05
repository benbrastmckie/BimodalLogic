# Phase 3 Handoff: Convention Fix and Seed Consistency

## Session: sess_1777995146_d95bf9
## Date: 2026-05-05
## Status: PARTIAL - convention fixes applied, seed consistency still sorry

## Critical Finding: Burgess Convention Was Misaligned

### The Problem

The previous code had `lemma_2_7` with:
- `h_eta_not_B : eta ∉ B` (EVENT not in B)
- Output: `xi ∈ D ∧ eta ∈ B'` (GUARD in D, EVENT in B')

But Burgess Lemma 2.7 states:
- `U(ξ, η) ∈ A` with `η ∉ B` where η = GUARD (second arg of U)
- Output: ξ ∈ D (EVENT), η ∈ B' (GUARD)

### Convention Resolution

Burgess `U(α, β)` semantics (from literature line 39):
- First arg α = EVENT (what happens at endpoint y)
- Second arg β = GUARD (what holds on interval (x,y))

Our `untl(φ, ψ)` semantics (from Truth.lean line 127):
- First arg φ = GUARD (what holds on interval)
- Second arg ψ = EVENT (what happens at endpoint)

So `untl(xi, eta)` = `U(eta, xi)` in Burgess. Arguments ARE swapped.

Mapping: Our `xi` = Burgess `η` (guard), Our `eta` = Burgess `ξ` (event).

### Fix Applied (in PointInsertion.lean)

1. **Seed definition** (`lemma_2_7_seed`): Changed from `{xi}` to `{eta}` singleton, and from `snce(β∧eta, α)` to `snce(β∧xi, α)` in 5th component.

2. **Seed consistency** (`lemma_2_7_seed_consistent`): Changed `h_eta_not_B` to `h_xi_not_B` (guard not in B).

3. **Main theorem** (`lemma_2_7`): Changed condition to `h_xi_not_B : xi ∉ B`, output to `eta ∈ D ∧ xi ∈ B'`.

4. **Internal proof steps**: All references updated (snce(β∧xi,..) instead of snce(β∧eta,..), DC({xi}) instead of DC({eta}), etc.)

### Why This Matters for BX7

With the OLD convention (eta ∉ B = event not in B):
- BX5 + BX7 combined guard = (xi∧untl(xi,eta))∧(beta0∧untl(beta0,gamma0))
- This does NOT contain eta, so D1/D2 elimination via left_mono to beta0∧eta FAILS
- The proof was fundamentally blocked

With the FIXED convention (xi ∉ B = guard not in B):
- Same BX7 combined guard = (xi∧untl(xi,eta))∧(beta0∧untl(beta0,gamma0))
- This CONTAINS xi, so D1/D2 elimination works:
  - D1 = untl(g1∧g2, eta∧gamma0). left_mono(g1∧g2 → beta0∧xi), right_mono(eta∧gamma0 → gamma0) → untl(beta0∧xi, gamma0) ∈ A. Contradicts ¬untl(beta0∧xi, gamma0) ∈ A.
  - D3 survives. Apply BX14 + BX13 + BX10 chain.

### Remaining Issues

1. **Seed consistency (`sorry`)**: The finite subset consistency proof following Burgess's BX5+BX7+BX14+BX13+BX10 chain needs to be implemented. The convention fix UNBLOCKS this.

2. **Guard consistency subtlety**: The `lemma_2_7` proof body needs `{xi}` to be consistent (for DC({xi}) to be a valid DCS). Under open guard semantics on discrete orders, a formula with ⊢ ¬xi can still have untl(xi,eta) in an MCS (vacuous guard). If {xi}∪B is inconsistent, xi.neg ∈ B but xi ∉ B (compatible). The proof has a `sorry` for this case. This is the same DCS consistency issue as Phase 2.

3. **D2 elimination details**: Need to verify D2 elimination works. D2 = untl(g1∧g2, eta∧g2). right_mono(eta∧g2 → gamma0) requires g2 → gamma0, i.e., beta0∧untl(beta0,gamma0) → gamma0, which is NOT derivable. Alternative: left_mono(g1∧g2 → beta0∧xi) gives untl(beta0∧xi, eta∧g2). Then right_mono with eta∧g2 → eta gives untl(beta0∧xi, eta). Then... this doesn't directly give untl(beta0∧xi, gamma0). Need a different D2 elimination strategy, possibly via BX14.

## Files Modified

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` - Convention fixes to lemma_2_7_seed, lemma_2_7_seed_consistent, lemma_2_7
- `/home/benjamin/Projects/ProofChecker/specs/107_chain_design_diagnostics_for_representation_theorem/plans/58_implementation-plan.md` - Phase 2 marked BLOCKED, Phase 3 IN PROGRESS

## Recommended Next Steps

1. **Verify the D2 elimination argument** in detail using lean_goal at the BX7 output
2. **Implement `lemma_2_7_seed_consistent`** following Burgess's chain: BX5 on both Untils → BX7 three-way → eliminate D1,D2 → D3 survives → right_mono to event gamma0 → BX14 separation → BX13 enrichment → BX10 → event implies seed
3. **Resolve guard consistency** either by adding precondition `SetConsistent ({xi} ∪ B)` or by structural alignment with Burgess (remove consistency requirement from DCS)
4. **Run `lake build`** to verify all changes compile

## Key Infrastructure (Verified)

All needed lemmas exist:
- `self_accum_until_mcs`: BX5 at MCS level
- `separation_until_mcs`: BX14 at MCS level
- `enrichment_until_mcs`: BX13 at MCS level
- `until_implies_F_mcs`: BX10 at MCS level
- `untl_left_mono_deriv/thm`: BX2 at derivation/MCS level
- `untl_right_mono_deriv`: BX3 at derivation level
- `BurgessR3Maximal_extension_fails`: Maximality witness extraction
- `dc_delta_B_controlled`: DC extension analysis
- `iterated_enrichment`: Iterated BX13 for alpha lists
- `burgess_zeta_consistent`: Full BX chain (used in Lemma 2.6)
- `Axiom.linear_until`: BX7 axiom (4 params: φ ψ χ θ)
