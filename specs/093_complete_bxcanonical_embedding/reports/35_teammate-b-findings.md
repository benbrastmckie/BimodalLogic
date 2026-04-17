# Teammate B: Bundle Infrastructure Analysis

## Key Findings

### 1. FMCS Structure and Properties

The FMCS structure (`FMCSDef.lean:99-117`) is parameterized by a preordered type D and assigns an MCS to each time point:

```
FMCS D:
  mcs : D → Set Formula
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  forward_G : ∀ t t' φ, t ≤ t' → G(φ) ∈ mcs(t) → φ ∈ mcs(t')
  backward_H : ∀ t t' φ, t' ≤ t → H(φ) ∈ mcs(t) → φ ∈ mcs(t')
```

Uses reflexive (non-strict) inequalities. The structure does NOT include forward_F or backward_P. Those are in `TemporalCoherentFamily` (`TemporalCoherence.lean:147-153`), which extends FMCS with:
- `forward_F : ∀ t φ, F(φ) ∈ mcs(t) → ∃ s > t, φ ∈ mcs(s)` (STRICT)
- `backward_P : ∀ t φ, P(φ) ∈ mcs(t) → ∃ s < t, φ ∈ mcs(s)` (STRICT)

### 2. g_content and f_content Definitions

From `TemporalContent.lean`:
- `g_content(M) = {φ | G(φ) ∈ M}` — formulas under universal future
- `f_content(M) = {φ | F(φ) ∈ M}` — formulas under existential future
- `h_content(M) = {φ | H(φ) ∈ M}` — formulas under universal past
- `p_content(M) = {φ | P(φ) ∈ M}` — formulas under existential past

**Critical note** from docstring (`TemporalContent.lean:47-49`): "g_content strips F-formulas. If F(ψ) is in M, ψ will NOT appear in g_content(M) unless G(ψ) is also in M."

### 3. SuccExistence: How Successor MCS Are Built

Three seed constructions exist:

**a) Basic successor_deferral_seed** (`SuccExistence.lean:87-88`):
```
g_content(u) ∪ deferralDisjunctions(u)
```
where `deferralDisjunctions(u) = {φ ∨ F(φ) | F(φ) ∈ u}`.

**b) Constrained successor seed** (`SuccExistence.lean:411-412`):
```
g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas(u)
```

**c) Restricted constrained successor seed** (`SuccExistence.lean:355-356`):
```
g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas_restricted(phi, u)
```

All seeds are consistent because under BX1 (reflexive G), `g_content(u) ⊆ u` and `deferralDisjunctions(u) ⊆ u` (since `F(ψ) → ψ ∨ F(ψ)` is derivable), so the entire seed ⊆ u.

**Key Property**: The Succ relation (`SuccRelation.lean:59-60`) is:
```
Succ u v := g_content(u) ⊆ v ∧ f_content(u) ⊆ v ∪ f_content(v)
```
- G-persistence: universal future formulas propagate
- F-step: each F-obligation is either resolved (φ ∈ v) or deferred (F(φ) ∈ v)

### 4. WitnessSeed Construction

The `forward_temporal_witness_seed` (`WitnessSeed.lean:50-51`):
```
{ψ} ∪ g_content(M)
```
Proven consistent when `F(ψ) ∈ M` (`WitnessSeed.lean:81-128`). The proof uses generalized temporal K: if the seed is inconsistent, derive `G(¬ψ) ∈ M` which contradicts `F(ψ) = ¬G(¬ψ) ∈ M`.

**The seed does NOT include f_carry.** This is the critical gap: when building a witness for F(ψ), other F-obligations from M are not preserved in the seed.

### 5. TemporalCoherence: What It Proves

`TemporalCoherence.lean` provides:
- `temporal_backward_G`: If φ ∈ fam.mcs(s) for all s > t, then G(φ) ∈ fam.mcs(t) — proven by contraposition using forward_F
- `temporal_backward_H`: Symmetric using backward_P
- Restricted variants that only need forward_F/backward_P for formulas in deferralClosure(root)
- Until/Since coherence definitions (both full and restricted)

**It does NOT prove forward_F or backward_P.** These must come from the chain construction.

### 6. Bundle Chain vs BXCanonical Chain

**Bundle chain** (SuccExistence.lean): Uses Succ relation with deferral disjunctions. Proven: successor_exists, predecessor_exists. The `single_step_forcing` theorem (`SuccRelation.lean:232-268`) shows: if F(φ) ∈ u and FF(φ) ∉ u and Succ(u,v), then φ ∈ v. This gives bounded witnesses for F-obligations at known F-nesting depth.

**BXCanonical chain** (RootScopedChain.lean): Uses three step primitives:
1. `fwd_succ M ψ` (`CanonicalModel.lean:66-72`): If F(ψ) ∈ M, seed = `{ψ} ∪ g_content(M)` (resolving mode). Otherwise, seed = `g_content(M) ∪ f_carry(M)` (non-resolving mode, preserves F-formulas).
2. `enriched_fwd_step M target sigma_list` (`RootScopedChain.lean:583-590`): Uses BX11 (temporal linearity) to build a seed that resolves at least one defect while protecting all other F-formulas from sigma_list.
3. `defect_fwd_step_choice` (`RootScopedChain.lean:2030-2034`): Selects from `defect_step_from_earliest`, which uses the BX11 fold to resolve the earliest witness.

### 7. The dd_fmcs and forward_F Sorry Site

The Int-indexed `dd_chain` (`RootScopedChain.lean:678`) combines:
- Forward: `rr_fwd_chain` (round-robin with enriched steps) for t ≥ 0
- Backward: `rr_bwd_chain` (standard bwd_pred) for t < 0

The key sorry is `defect_fwd_chain_forward_F` (`RootScopedChain.lean:2190-2196`):
```
∀ n ψ, ψ ∈ defects → F(ψ) ∈ chain(n) → ∃ s > n, ψ ∈ chain(s)
```

The symmetric backward sorry is `defect_bwd_chain_backward_P` (`RootScopedChain.lean:2283-2289`).

### 8. F-Defect Discharge: What's Proven and What's Not

**Proven infrastructure**:
- `enriched_resolving_seed_consistent` (`OrderedSeedConsistency.lean:70-104`): If `F(ψ ∧ α) ∈ M`, then `{ψ, α} ∪ g_content(M)` is consistent
- `defect_fwd_chain_F_obligation_persists` (`RootScopedChain.lean:2120-2133`): F-obligations persist step-to-step (both via defect_fwd_step_choice and enriched_fwd_step)
- `defect_fwd_chain_F_obligation_constant` (`RootScopedChain.lean:2135-2146`): F-obligations persist across ranges
- `FF_imp_F` (`RootScopedChain.lean:61-84`): F(F(ψ)) → F(ψ) is derivable in BX (uses temp_4 contrapositive)
- `self_resolving_fwd_step` (`RootScopedChain.lean:1961-1966`): Given F(ψ) ∈ M, builds M' with ψ ∈ M', F(ψ) ∈ M', and g_content(M) ⊆ M'

**NOT proven (sorry)**:
- The base case of `rr_fwd_chain_forward_F` at F-nesting depth 0 (`RootScopedChain.lean:1413`)
- `defect_fwd_chain_forward_F` (`RootScopedChain.lean:2196`)
- `defect_bwd_chain_backward_P` (`RootScopedChain.lean:2289`)

### 9. bx_forward_witness and bx_backward_witness

These exist in `Frame.lean:164-185`. They are simple Lindenbaum witnesses:
- `bx_forward_witness w ψ h_F`: Given F(ψ) ∈ w, extends `{ψ} ∪ g_content(w)` to MCS v with bx_le w v and ψ ∈ v
- `bx_backward_witness w ψ h_P`: Given P(ψ) ∈ w, extends `{ψ} ∪ h_content(w)` to MCS v with bx_le v w and ψ ∈ v

These provide frame-level witnesses but NOT chain-level witnesses (they don't produce elements at specific chain indices).

### 10. The EXACT Interface BXCanonical/RootScopedChain Expects

The chain must produce an `FMCS Int` satisfying:
- `forward_G`: G(φ) ∈ mcs(t), t ≤ t' → φ ∈ mcs(t') — guaranteed by g_content propagation at each step
- `backward_H`: H(φ) ∈ mcs(t), t' ≤ t → φ ∈ mcs(t') — guaranteed by h_content duality
- `forward_F`: F(φ) ∈ mcs(t) → ∃ s > t, φ ∈ mcs(s) — THIS IS THE SORRY
- `backward_P`: P(φ) ∈ mcs(t) → ∃ s < t, φ ∈ mcs(s) — THIS IS THE SORRY

For Until/Since, the chain also needs step transfer properties.

### 11. Critical Question: fwd_succ Seed and f_carry

When `F(target) ∈ M` (resolving mode), `fwd_succ` uses `{target} ∪ g_content(M)`. This seed does NOT include f_carry. This means:
- Other F-obligations (F(χ) for χ ≠ target) may be lost
- The Lindenbaum extension is nondeterministic; it might not include F(χ)

When `F(target) ∉ M` (non-resolving mode), `fwd_succ` uses `g_content(M) ∪ f_carry(M)`. This preserves all F-obligations but resolves nothing.

**The `enriched_fwd_step`** addresses this by using BX11 temporal linearity to build a seed that resolves at least one formula while protecting others. Specifically, `resolving_enriched_fwd_exists` uses a BX11 fold across all formulas in sigma_list to produce a conjunction `F(ψ ∧ conj)` where conj contains all the F-obligations. Then `enriched_resolving_seed_consistent` gives a seed `{ψ, conj} ∪ g_content(M)`.

**Can f_carry be added to the basic resolving seed?** No, because adding arbitrary F-formulas to `{ψ} ∪ g_content(M)` can produce inconsistency (if both F(A) and F(¬A) are in M, adding A and ¬A to the seed is inconsistent). The BX11-based enrichment is the correct approach.

## Recommended Approach

The gap between Bundle infrastructure and BXCanonical needs is narrow but deep:

1. **Bundle provides** the Succ relation, seed consistency, deferral disjunctions, g/h content duality, and single-step forcing. These are all proven and sorr-free.

2. **BXCanonical provides** the chain construction with BX11-based enrichment that preserves F-obligations across steps (`defect_fwd_chain_F_obligation_persists`).

3. **The gap** is proving that the chain eventually resolves each F-defect. The `defect_fwd_chain_forward_F` sorry requires showing that if F(ψ) persists in every chain element, eventually ψ appears directly.

4. **For a quasimodel bridge**: The key insight is that `bx_forward_witness` already gives frame-level witnesses. A quasimodel would use these witnesses to define the temporal structure, bypassing the chain-level obligation discharge entirely. The quasimodel's temporal order would be defined over BXPoints with the bx_le relation, and forward_F would follow from `bx_forward_witness` plus the quasimodel's chain extraction.

5. **The self-resolving infrastructure** (`self_resolving_fwd_step`, lines 1961-1996) shows that given F(ψ) ∈ M, we can build M' with BOTH ψ ∈ M' and F(ψ) ∈ M'. This means we can construct an infinite chain where F(ψ) persists forever AND ψ appears at every step. The challenge is integrating this into the multi-defect round-robin.

## Evidence/Examples

- Succ definition: `SuccRelation.lean:59-60`
- Forward witness seed: `WitnessSeed.lean:50-51`
- Seed consistency proof: `WitnessSeed.lean:81-128`
- Enriched resolving seed: `OrderedSeedConsistency.lean:56-57`
- F-obligation persistence: `RootScopedChain.lean:2120-2133`
- Self-resolving step: `RootScopedChain.lean:1961-1996`
- forward_F sorry: `RootScopedChain.lean:2196`
- backward_P sorry: `RootScopedChain.lean:2289`
- bx_forward_witness: `Frame.lean:164-171`
- bx_backward_witness: `Frame.lean:176-185`
- FF_imp_F derivability: `RootScopedChain.lean:61-84`
- g_content does NOT include F-formulas: `TemporalContent.lean:47-49`

## Confidence Level

**HIGH** — All findings are based on direct reading of the complete source files. The analysis correctly identifies:
- The exact structure of seeds and their proven consistency
- The specific sorry sites and their mathematical content
- The f_carry gap and the BX11-based mitigation
- The relationship between Bundle-level and Frame-level witness constructions
- The self-resolving infrastructure that was added in the most recent commits
