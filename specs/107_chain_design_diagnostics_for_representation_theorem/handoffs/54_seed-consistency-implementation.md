# Handoff: Seed Consistency Implementation (2026-05-01)

## Session: sess_1777696621_abe53e

## Summary

Implemented structural cleanup of `lemma_2_6_splitting` and consolidated sorry sites for the Burgess D0 seed consistency proof.

## Changes Made

### Job 1: Remove g_content dead code (COMPLETED)

- Removed `g_content A ⊆ D ∧ g_content D ⊆ C` from `lemma_2_6_splitting` output type
- Deleted ~85 lines of Step 7 (g_content proofs with 2 sorry sites)
- Updated docstring to reflect simplified output
- Final output type: `∃ B' D B'', BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C ∧ SetMaximalConsistent D ∧ β.neg ∈ D`
- `h_gc : g_content A ⊆ C` retained (used by `burgess_D0_seed_consistent` internally)

### Job 2: Factor burgess_D0_seed_consistent (PARTIAL)

- Created `burgess_D0_finite_subset_consistent` (consistent case helper) with full docstring of Burgess argument
- Created `burgess_D0_finite_subset_consistent_incons` (inconsistent case helper) with full docstring
- Both delegate the sorry to the minimal mathematical claim: the Burgess compression argument
- Removed redundant comments from both cases (~60 lines of exploration notes cleaned up)
- BX chain (BX5+BX14+BX10) from lines 1130-1232 remains intact and proven

## Current Sorry Sites in PointInsertion.lean (4 total)

| Line | Theorem | Description |
|------|---------|-------------|
| ~1092 | `burgess_D0_finite_subset_consistent` | Burgess compression for consistent case |
| ~1116 | `burgess_D0_finite_subset_consistent_incons` | Burgess compression for inconsistent case |
| ~1552 | `lemma_2_7_seed_consistent` | Same pattern as above (shared machinery) |
| ~1625 | `h_eta_B'` in `lemma_2_7` | eta membership in Zorn-maximal B' |

## Mathematical Analysis: What's Needed to Close the Sorry

The Burgess compression argument requires:

### Step 1: List-level conjunction in DCS
Given finite L_B ⊆ B (with B a DCS), produce b = ∧L_B ∈ B.
- Requires induction on List with `conj_mcs` or DCS conjunction closure
- DCS is closed under derivation: if L ⊆ B and L ⊢ φ then φ ∈ B
- So ∧L_B ∈ B follows from B being DCS (derive conjunction from elements)

### Step 2: Guard weakening for Until/Since
From `untl(β'_i, γ_i) ∈ A` for each i, and b = ∧β'_i ∈ B:
- Need `untl(b, γ_i) ∈ A` via `left_mono_until` with `⊢ b → β'_i`
- ⊢ b → β'_i holds because b is a conjunction containing β'_i

### Step 3: Event conjunction for Until
From multiple `untl(b, γ_i) ∈ A`, produce single `untl(b, ∧γ_i) ∈ A`.
- This needs `right_mono_until` with `⊢ ∧γ_i → γ_i` (conjunction elimination)
- Actually goes the WRONG direction! `right_mono_until` gives: if ⊢ψ→χ then U(φ,ψ)→U(φ,χ)
- So from U(b, ∧γ_i) we get U(b, γ_i), not the reverse.
- The correct direction: we need U(b, ∧γ_i) which is STRONGER than each U(b, γ_i).
- This is NOT directly provable from individual U(b, γ_i)!
- Burgess handles this by NOT combining U-formulas: instead, the single U-formula
  comes from the BX chain applied to a SINGLE untl(b, γ₀) from burgessR3.

### Step 4: BX chain for consistency
The BX5+BX14+BX13+BX10 chain (already proved at lines 1130-1232) produces an event
formula that is consistent (F(event) ∈ A ⟹ event is consistent by seriality).
The event implies β.neg (proved at lines 1187-1224).

### Step 5: Event implies all L elements
Show: event ⊢ l_i for each l_i ∈ L.
- For l_i ∈ B: event contains β₀ (from q = β₀ ∧ untl(β₀,γ₀)), and ⊢ β₀ → l_i 
  only if β₀ = ∧L_B which requires the compression step.
- For l_i = untl(β'_i, γ_i): need event ⊢ untl(β'_i, γ_i). The event is a propositional
  formula, not a temporal one. So we can't derive untl from it propositionally.

### Key Insight: Why full compression is needed

The Burgess argument doesn't just show the event is consistent. It shows that the
SINGLE CONJUNCTION ζ = b ∧ β.neg ∧ untl(b, γ̂) ∧ snce(b, α̂) is consistent.
The proof: construct U(ζ, b) ∈ A (using BX5+BX14+BX13 to pack ζ into the event
of an Until formula), then BX10 gives F(ζ) ∈ A, so ζ is consistent.

The ζ implies all L elements:
- b ∧ β.neg implies each B-element and β.neg (conjunction elimination)
- untl(b, γ̂) implies each untl(β'_i, γ_i) via left_mono (⊢ b → β'_i)
  and right_mono (⊢ γ̂ → γ_i)
- snce(b, α̂) implies each snce(β'_j, α_j) via left_mono (⊢ b → β'_j)
  and... event_mono? snce(b, α̂) → snce(β'_j, α_j) needs ⊢ b → β'_j (left weakening)
  and ⊢ α̂ → α_j (event weakening). Both are conjunction eliminations.

So if ζ ⊢ l_i for all i, and L ⊢ ⊥, then ζ ⊢ ⊥ (by composition: from ζ derive all
l_i, then apply the L ⊢ ⊥ derivation). This contradicts ζ being consistent.

### Implementation Path

1. **Conjunction in DCS**: `dcs_conj_list : ∀ L ⊆ B, (∧L) ∈ B` (induction on List)
2. **Guard weakening helpers**: Already have `left_mono_until_mcs`, `right_mono_until_mcs`
3. **BX chain for ζ**: Adapt existing chain (lines 1130-1232) to work with arbitrary b∈B
4. **Derivation composition**: From DerivationTree [ζ] l_i and DerivationTree L ⊥,
   construct DerivationTree [ζ] ⊥ via weakening + modus ponens
5. **Contradiction**: F(ζ) ∈ A means {ζ} is consistent, contradicting [ζ] ⊢ ⊥

Estimated effort: 4-6 hours for full implementation.

## Build Status

`lake build` succeeds with 4 sorry sites in PointInsertion.lean (down from 7).

## Recommendations for Next Implementation

1. Implement `dcs_conj_list` (list conjunction membership for DCS)
2. Generalize the BX chain to work with arbitrary b∈B (currently hardcoded to beta0)
3. Prove the "ζ implies each L element" step using existing left_mono/right_mono helpers
4. Close `burgess_D0_finite_subset_consistent` using the general machinery
5. The inconsistent case uses the same machinery (β.neg already in B simplifies it)
6. `lemma_2_7_seed_consistent` uses nearly identical structure (share the helper)
