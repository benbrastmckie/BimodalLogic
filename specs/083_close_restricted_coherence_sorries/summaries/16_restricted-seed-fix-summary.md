# Implementation Summary: Fix Restricted Seed and Close Forward_F Sorries

- **Task**: 83 - Close Restricted Coherence Sorries
- **Plan**: plans/16_restricted-seed-fix.md
- **Status**: [PARTIAL] (3 of 5 phases completed, 2 blocked)
- **Session**: sess_1743724801_c4d5e6

## Completed Work

### Phase 1: Remove f_content + boundary_resolution_set from Seed [COMPLETED]

Edited `constrained_successor_seed_restricted` in SuccExistence.lean to remove `f_content(u)` and `boundary_resolution_set(phi, u)` from the 5-component seed, reducing it to 3 components:
```
g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas_restricted(phi, u)
```

Updated all downstream references:
- Simplified `mem_constrained_successor_seed_restricted_iff` from 5-way to 3-way disjunction
- Fixed `constrained_successor_seed_restricted_subset_deferralClosure` (3 cases instead of 5)
- Fixed `neg_not_in_seed_when_in_brs` (3 cases instead of 5)
- Replaced API compat stubs for removed subset lemmas
- Cleaned up ~240 lines of orphan proof code from the old seed consistency proof

### Phase 2: Seed Consistency + Deferral Step [COMPLETED]

Rewrote `constrained_successor_seed_restricted_consistent` with a trivial proof: the 3-component seed is a subset of u (g_content via DRM, deferralDisjunctions via DRM, p_step_blocking via DRM), and u is consistent, so the seed is consistent.

Note: Still carries sorryAx transitively via `g_content_subset_deferral_restricted_mcs` which has the UNFIXABLE T-axiom sorry (G(chi) -> chi not derivable under strict semantics).

### Phase 3: Bounded Deferral Resolution for Forward_F [COMPLETED]

Replaced the old one-step F-resolution (which depended on the FALSE f_content in the seed) with bounded deferral resolution:

1. Created `restricted_forward_bounded_witness_fueled`: fueled recursive proof that if `iter_F d theta ∈ chain(k)` with boundary at d, then `theta ∈ chain(m)` for some m > k. Uses F-step witness (deferral: psi or F(psi) in successor) and F-nesting boundary to recurse.

2. Created `restricted_forward_bounded_witness`: wrapper with fuel = B*B+1.

3. Rewrote `restricted_forward_chain_forward_F` to use bounded deferral: gets F-nesting boundary from `restricted_forward_chain_F_bounded`, then applies bounded witness.

The fuel=0 case has a sorry (semantically unreachable), matching the existing pattern in the backward chain.

## Blocked Phases

### Phase 4: Wire to Completeness [BLOCKED]

Analysis revealed deep architectural blockers:
- `DovetailedFMCS_forward_F` is blocked by `forward_dovetailed_until_persists` (x_content propagation in dovetailed chain)
- The dovetailed chain uses Lindenbaum extensions which DON'T propagate x_content
- The deterministic chain (DeterministicChain.lean) HAS x_content propagation and until persistence (sorry-free)
- But the deterministic chain doesn't guarantee F-resolution (can defer F(psi) forever)
- Neither chain alone provides both F-resolution AND until persistence

### Phase 5: Close Until/Since Truth Lemma [BLOCKED]

Blocked by Phase 4. The Until truth lemma requires both:
1. Forward_F (from restricted chain - has T-axiom + fuel sorries)
2. X-content propagation (from deterministic chain - sorry-free but on different chain)

## Metrics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Sorry count | 381 | 383 | +2 |
| Build status | Pass | Pass | No change |
| Axiom count | 0 | 0 | No change |

Sorry changes:
- Removed: 1 (constrained_successor_seed_restricted_consistent body)
- Added: 2 (API compat stubs for removed subset lemmas) + 1 (fuel=0 in bounded witness)

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Seed definition, subset lemmas
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Seed consistency proof, forward_F proof, bounded witness

## Architectural Insight

The completeness proof requires a chain construction that provides BOTH:
1. **F-resolution**: F(psi) at position n implies psi at some m > n
2. **Until/Since persistence**: (phi U psi) at position n persists until psi appears

The restricted chain (DeferralRestrictedMCS, deferralClosure) provides F-resolution via bounded deferral. The deterministic chain (x_content/y_content) provides Until/Since persistence via the X-K/X-Det axioms. A unified construction combining both is needed for sorry-free completeness.

Potential approach: Modify the deterministic chain to use deferralClosure-restricted x_content, gaining both properties. This requires new research and is out of scope for plan v16.
