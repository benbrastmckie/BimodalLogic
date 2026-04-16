# Handoff: Quasimodel Bridge Design

**Task**: 93 - Complete BXCanonical Embedding
**Session**: sess_1776379144_14819a
**Phase**: 5 (Quasimodel Bridge) IN PROGRESS
**Prior handoff**: `handoffs/01_drm-chain-obstacle.md` (DRM approach blocked)

## Summary

The DRM approach (Phases 1-3) is blocked by a negation completeness gap. This handoff documents the Phase 5 Quasimodel Bridge design after extensive codebase exploration.

## Architecture Understanding

### The 6 Sorry Sites

All in `RootScopedChain.lean`:

| Line | Theorem | Type |
|------|---------|------|
| 3644 | `rr_fwd_chain_forward_F` | depth-0 forward_F base case |
| 3688 | `dd_fmcs_forward_F` | t < 0 forward_F |
| 3695 | `dd_fmcs_backward_P` | backward_P |
| 3748 | `dd_bfmcs_restricted_tc` | restricted temporal coherence |
| 3753 | `dd_bfmcs_restricted_buc` | restricted backward Until/Since |
| 3758 | `dd_bfmcs_restricted_fuc` | restricted forward Until/Since |

### Consumer

`dd_countermodel` (line 3762) uses sorry sites 4-6 via:
```
fully_restricted_parametric_representation_from_neg_membership
  (dd_bfmcs M h_mcs sigma_list) phi
  (dd_bfmcs_restricted_tc ...)     -- sorry 4
  (dd_bfmcs_restricted_buc ...)    -- sorry 5
  (dd_bfmcs_restricted_fuc ...)    -- sorry 6
```

Sorry sites 1-3 are intermediate; 4-6 are the real requirements.

### Key Existing Infrastructure

#### BXPoint Eventuality Resolution (sorry-free)
- `bx_forward_witness`: F(psi) in w -> exists v, bx_le w v and psi in v
- `bx_backward_witness`: P(psi) in w -> exists v, bx_le v w and psi in v
- `bx_until_eventuality_resolution`: (phi U psi) in w, psi not in w -> exists v, bx_le w v, psi in v, phi in w
- `bx_since_eventuality_resolution`: (phi S psi) in w, psi not in w -> exists v, bx_le v w, psi in v, phi in w
- `bx_modal_equiv_of_bx_le`: bx_le w v -> box-equivalence
- `bx_H_forward`: bx_le v w and H(phi) in w -> phi in v

#### BX Axiom Lemmas at MCS level (CanonicalChain.lean, Construction.lean)
- `F_imp_top_until_mcs`: F(psi) in w -> (top U psi) in w
- `P_imp_top_since_mcs`: P(psi) in w -> (top S psi) in w
- `psi_imp_until_mcs`: psi in w -> (phi U psi) in w (BX8)
- `F_of_mem`: psi in w -> F(psi) in w (MCS F-reflexivity)
- `P_of_mem`: psi in w -> P(psi) in w

#### FMCS/BFMCS Structure
- FMCS requires: `mcs : D -> Set Formula`, `is_mcs`, `forward_G`, `backward_H`
- BFMCS adds: families set, modal_forward, modal_backward, eval_family
- `bx_le` directly gives `forward_G` between BXPoints
- `bx_H_forward` gives `backward_H`

## Recommended Design: BXPoint-Based BFMCS

### Core Idea

Replace `dd_bfmcs` with a new BFMCS constructor built from BXPoint chains where:
1. Each family is an Int-indexed BXPoint chain with `bx_le` between consecutive elements
2. forward_F comes from `bx_forward_witness` applied AT CHAIN CONSTRUCTION TIME (not after)
3. Until/Since coherence comes from `bx_until_eventuality_resolution` / `bx_since_eventuality_resolution`

### The Key Challenge: Forward_F

The fundamental difficulty with ANY chain construction:
- `bx_forward_witness` gives v with `bx_le w v` and `psi in v`
- But v is not necessarily in the chain
- The chain must be INFINITE, so we can't just add v

**Solution: Interleaved chain construction**

Build the forward chain by interleaving:
1. For each formula `psi` in `sigma_list` with `F(psi)` in the current state, schedule a visit
2. At the visit, use `bx_forward_witness` to get a successor containing `psi`
3. This successor becomes the next chain state

The round-robin schedule (already in `rrSchedule`) ensures each formula is visited periodically.

**Why this works (unlike rr_fwd_chain)**:
- `bx_forward_witness w psi (h_F_psi)` gives `v` with `bx_le w v` AND `psi in v`
- The key: `psi` is DIRECTLY placed in `v` by the seed construction
- In `rr_fwd_chain`, `enriched_fwd_step` resolves one formula but may not resolve the TARGET
- In the new chain, the target IS resolved because we use `bx_forward_witness` with the specific psi

**Wait -- bx_forward_witness already gives the specific psi!** This is different from the enriched_fwd_step which may resolve a different formula.

So the construction:
```
chain(0) = w₀
chain(n+1) = if F(target(n)) in chain(n)
             then (bx_forward_witness chain(n) target(n) ...).choose
             else (some default successor with bx_le)
```
where `target(n) = rrSchedule sigma_list n`.

At the visit step for psi, `bx_forward_witness` gives `psi in chain(visit_step + 1)`. This resolves the F-obligation.

But `bx_le chain(n) chain(n+1)` gives g_content propagation. And `bx_forward_witness` gives `bx_le`. So the chain IS temporally ordered!

### Implementation Plan

1. Create `Theories/Bimodal/Metalogic/BXCanonical/BXPointChain.lean`:
   - Define `bx_fwd_chain`: forward chain using `bx_forward_witness` with round-robin schedule
   - Define `bx_bwd_chain`: backward chain using `bx_backward_witness`
   - Define `bx_dd_chain`: Int-indexed assembly
   - Prove `forward_G` and `backward_H` from `bx_le`
   - Prove `forward_F` using the visit schedule
   - Prove `backward_P` symmetrically
   - Build FMCS from the chain
   - Build BFMCS from families of shifted chains

2. In `RootScopedChain.lean`:
   - Add import for `BXPointChain`
   - Prove `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc` using the new BFMCS

   OR (simpler):
   - Replace `dd_bfmcs` in `dd_countermodel` with the new BFMCS
   - Close sorry sites 4-6 directly

### Why This Should Work

The key difference from `rr_fwd_chain`:
- `enriched_fwd_step` uses a complex seed (g_content + f_carry + resolving enrichment) and the Lindenbaum extension may NOT include the target psi
- `bx_forward_witness` uses a seed `{psi} ∪ g_content` and the Lindenbaum extension MUST include psi (it's in the seed)
- So `bx_forward_witness` GUARANTEES psi is in the successor, breaking perpetual deferral

### Estimated Effort

- BXPointChain.lean: ~300-500 lines
- Wiring into RootScopedChain: ~100-200 lines
- Total: ~400-700 lines (much less than the 800-1200 in plan Phase 5)

### Risks

1. The backward chain needs `bx_backward_witness`, which requires `P(neg bot) in w`. This is symmetric to the forward case.
2. The BXPoint chain states may not satisfy the `f_step` property of `Succ` (only g_content propagation is guaranteed by `bx_le`). This is fine because the FMCS only requires `forward_G` and `backward_H`, not `Succ`.
3. Box stability: all states in the chain must agree on box-formulas. This follows from `bx_modal_equiv_of_bx_le`.

## Files

- `Theories/Bimodal/Metalogic/BXCanonical/DRMChain.lean` (from Phase 1, keep for reference)
- `specs/093_complete_bxcanonical_embedding/handoffs/01_drm-chain-obstacle.md`
- This file
