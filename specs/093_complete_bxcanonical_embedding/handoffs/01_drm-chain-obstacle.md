# Handoff: DRM Chain Obstacle Analysis

**Task**: 93 - Complete BXCanonical Embedding
**Session**: sess_1776379144_14819a
**Phase Completed**: 1 (DRM chain infrastructure extracted), 2 partially (chain defined, forward_F blocked)
**Remaining**: 2 (forward_F), 3 (wiring), 4 (Until/Since coherence)

## What Was Done

### Phase 1: DRM Chain Infrastructure (COMPLETED)

Created `Theories/Bimodal/Metalogic/BXCanonical/DRMChain.lean` with sorry-free infrastructure:

1. **Simplified restricted seed** (`simplified_restricted_seed`): `g_content ∪ deferralDisjunctions ∪ p_step_blocking` -- all subsets of any DRM containing them.

2. **Component subset proofs** (all sorry-free):
   - `g_content_subset_drm`: g_content(u) ⊆ u for DRM u (via temp_t_future T-axiom argument)
   - `deferralDisjunctions_subset_drm`: deferralDisjunctions(u) ⊆ u (via deferral_disjunction_from_F)
   - `simplified_restricted_seed_subset_u`: seed ⊆ u
   - `simplified_restricted_seed_consistent`: seed is consistent
   - `simplified_restricted_seed_subset_dc`: seed ⊆ deferralClosure

3. **DRM successor** (`simplified_restricted_successor`): Lindenbaum extension of seed within deferralClosure.
   - `simplified_restricted_successor_is_drm`: successor is a DRM
   - `simplified_restricted_successor_extends`: seed ⊆ successor
   - `simplified_restricted_successor_g_persistence`: g_content propagation
   - `simplified_restricted_successor_f_step`: f_step (resolve-or-defer)
   - `simplified_restricted_successor_succ`: satisfies Succ relation

4. **F(neg bot) theorem**: Proved `F(neg bot)` is a theorem of the proof system (`F_neg_bot_theorem`), hence in any DRM (`F_neg_bot_in_drm`).

5. **Iterated DRM chain** (`drm_fwd_chain`): Mutually recursive with DRM proof.
   - `drm_fwd_chain_is_drm`: each state is a DRM
   - `drm_fwd_chain_succ`: consecutive states satisfy Succ

### Phase 2: Forward_F (BLOCKED)

The `drm_fwd_chain_forward_F` theorem has a sorry. The obstacle:

## Blocking Obstacle: DRM Negation Completeness for iter_F Formulas

The standard `bounded_witness` proof requires `single_step_forcing`:
- `F(X) ∈ u`, `FF(X) ∉ u`, `Succ u v` → `X ∈ v`

This works by: `FF(X) ∉ u` → `neg(FF(X)) ∈ u` (negation completeness) → `GG(neg X) ∈ u` → `G(neg X) ∈ v` → `F(X) ∉ v` → `X ∈ v` (by f_step).

**In a DRM**, negation completeness `FF(X) ∉ u → neg(FF(X)) ∈ u` requires:
1. `FF(X) ∈ deferralClosure` AND
2. `neg(FF(X)) ∈ deferralClosure`

For `X = iter_F(d-1, psi)` with `d` chosen via `deferral_restricted_mcs_F_bounded`:
- `FF(X) = iter_F(d+1, psi)` might NOT be in deferralClosure (when d+1 >= closure_F_bound)
- Even if it is, `neg(iter_F(d+1, psi))` has the same f_nesting_depth, so also NOT in deferralClosure

This blocks the standard single_step_forcing argument in the DRM.

## Viable Alternatives

### Option A: Prove targeted_restricted_seed_consistent

The Boneyard `SimplifiedChain.lean` has a sorry for `targeted_restricted_seed_consistent` (adding {psi} to the seed when F(psi) ∈ u). If this were proved, we could force psi into the successor directly, bypassing single_step_forcing entirely.

The obstacle there is the G-lift argument: the seed contains non-G-liftable elements (deferralDisjunctions, p_step_blocking). The G-lift is needed to derive G(neg(psi)) from u ⊢ neg(psi) to get a contradiction with F(psi) ∈ u.

### Option B: Quasimodel Bridge (Plan Phase 5)

Use `F_until_equiv`: `F(psi) → (neg(bot) U psi)`. This converts F-obligations to Until-defects. The quasimodel infrastructure (sorry-free) constructs Hintikka chains discharging Until-defects. Lift to MCS chains.

Estimated: 800-1200 LOC. The quasimodel infrastructure handles Until/Since directly, bypassing the DRM single_step_forcing issue.

### Option C: Restricted single_step_forcing for subformulaClosure formulas

If `iter_F(d+1, psi) ∈ subformulaClosure(phi)`, then `neg(iter_F(d+1, psi)) ∈ closureWithNeg ⊆ deferralClosure`, and the standard argument works. This restricts the forward_F theorem to formulas where the iter_F chain stays within subformulaClosure.

For the application in `rr_fwd_chain_forward_F`, sigma_list = extendedDeferralClosure(phi).toList, and the formulas come from deferralClosure which includes subformulaClosure. Many formulas DO have their iter_F chain within subformulaClosure.

### Option D: Direct proof via DRM closure under derivation

Instead of going through neg(FF(X)) → GG(neg X), directly derive G(neg X) ∈ u from the fact that FF(X) ∉ deferralClosure. This would require showing that `G(neg X) ∈ deferralClosure` and that there exists a derivation `premises_in_u ⊢ G(neg X)`.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/DRMChain.lean` (NEW, 290 lines, 1 sorry)
- `specs/093_complete_bxcanonical_embedding/plans/28_bxcanonical-embedding.md` (phase markers updated)

## Build Status

`lake build` succeeds. No new sorry in active-path files except the planned one in DRMChain.lean.
