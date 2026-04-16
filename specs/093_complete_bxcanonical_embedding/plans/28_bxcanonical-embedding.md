# Implementation Plan: Close BXCanonical Embedding (v28 -- DRM Succ Chain + Quasimodel Fallback)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: None (phases 1-2 of plan v27 completed; depth >= 1 proved sorry-free)
- **Research Inputs**: reports/28_depth-zero-base-case.md, reports/27_team-research.md, reports/26_defect-reentry-analysis.md
- **Artifacts**: plans/28_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Six sorry sites in `RootScopedChain.lean` (lines 3644, 3688, 3695, 3748, 3753, 3758) block `bx_completeness`. Plan v27 completed phases 1-2 (ROAD_MAP update, proof sketch) and partially completed phase 3 (depth >= 1 proved sorry-free via `rr_fwd_chain_forward_F_depth_pos`). The sole remaining obstacle is the depth-0 base case: when `F(psi)` is in `chain(n)` and `f_nesting_depth(psi) = 0`, prove `psi` appears at some `chain(s)` for `s > n`. Report 28 identified Path D (DRM-based Succ chain using `single_step_forcing` + `bounded_witness`) as the primary approach and Path B (Quasimodel bridge) as the fallback. This plan details both approaches with explicit go/no-go decision points. Definition of done: `lake build` succeeds with zero sorry in `RootScopedChain.lean`.

### Research Integration

- **Report 28** (depth-0 base case analysis): Conclusively establishes that Paths A (omega-squared), C (counting), and F (circularity exploit) are blocked. Path D (DRM Succ chain) is recommended: the Boneyard's `ResolvingChain.lean` already proves that `simplified_restricted_successor` satisfies the `Succ` relation (sorry-free), and `bounded_witness` (sorry-free) provides forward_F within DRM chains where F-nesting is bounded by `closure_F_bound`. Path B (Quasimodel bridge) is viable fallback at 800-1200 LOC.
- **Report 26**: Perpetual deferral is semantically consistent in the enriched chain -- the BX11 fold can permanently favor one formula over another. Any approach using the existing `rr_fwd_chain`/`enriched_fwd_step` directly will fail for depth 0.
- **Report 27**: Four teammates converge on Goldblatt WF-induction. The DRM approach (Path D) is a refinement: it uses the same WF structure but with concrete infrastructure already in the codebase.

### Prior Plan Reference

Plan v27 (35 hours, 6 phases) established the proof sketch (Phase 2) and proved depth >= 1 (Phase 3 partial). Key lessons: (1) The enriched chain's F-obligation constancy does NOT help because perpetual deferral is possible (Report 26); (2) The depth-0 case cannot be solved within full MCS because F-reflexivity (`phi_in_mcs_imp_F_phi`) prevents `single_step_forcing` from applying; (3) Working within `deferralClosure` (DRM) avoids F-reflexivity because F-nesting beyond `closure_F_bound` exits the closure. Effort calibration: the prior plan estimated 12 hours for Phase 3 (chain construction) but the depth >= 1 portion was proved in ~3 hours, suggesting the infrastructure is more mature than expected.

### Roadmap Alignment

- Closes `rr_fwd_chain_forward_F` (PRIMARY BLOCKER, ROAD_MAP line 24)
- Makes `dd_countermodel` sorry-free, resolving `Completeness.lean:154`
- Unblocks task 95 (`#print axioms` audit on `bx_completeness`)
- Eliminates all 6 active-path sorries in the BXCanonical module

## Goals & Non-Goals

**Goals**:
- Close the depth-0 base case of `rr_fwd_chain_forward_F` (line 3644)
- Close all 6 sorry sites in `RootScopedChain.lean`
- Achieve `lake build` with zero sorry in active BXCanonical path
- Provide clear go/no-go decision points between DRM approach and Quasimodel fallback

**Non-Goals**:
- Modifying the truth lemma or quasimodel infrastructure (sorry-free, proven correct)
- Dense completeness (independent task 68)
- Cleaning up Boneyard code (separate effort)
- Updating ROAD_MAP.md (already done in plan v27 Phase 1)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `targeted_restricted_seed_consistent` sorry in SimplifiedChain.lean blocks DRM chain usage | H | H (70%) | This sorry IS in the targeted seed (which adds one formula to the simplified seed). The simplified seed (g_content + deferralDisjunctions + p_step_blocking) is sorry-free. The DRM approach uses ONLY the simplified seed via `simplified_restricted_successor`, which is sorry-free. The targeted seed sorry is irrelevant. |
| `simplified_restricted_successor` imports Boneyard dependencies that don't compile | H | M (40%) | ResolvingChain.lean imports from Boneyard; may have stale dependencies. Mitigation: extract the 240 lines of ResolvingChain.lean into active codebase as a new file, updating imports. |
| DRM chain does not satisfy `CanonicalTask_forward_MCS` (needed by `bounded_witness`) | H | M (35%) | `CanonicalTask_forward_MCS` requires each pair to satisfy `Succ` AND both states to be `SetMaximalConsistent`. DRM states are `DeferralRestrictedMCS`, not full `SetMaximalConsistent`. Must either: (a) lift DRM to full MCS first, then show Succ still holds, or (b) prove a DRM-specific analog of `bounded_witness`. Option (b) is cleaner. |
| DRM forward_F does not wire into existing `rr_fwd_chain_forward_F` signature | M | M (40%) | The existing theorem is about `rr_fwd_chain` (enriched chain). The DRM chain is a DIFFERENT chain. Must either: (a) replace `rr_fwd_chain` entirely, or (b) prove a bridge lemma showing DRM forward_F implies enriched chain forward_F. Option (a) is cleaner but requires re-wiring dd_fmcs. |
| backward_P case requires symmetric DRM backward chain | M | L (20%) | The backward chain uses `bwd_pred` (symmetric to `fwd_succ`). The Succ relation has a symmetric `Pred` analog. The construction is structurally identical. |
| Until/Since coherence (sorries 5/6) harder than expected | M | M (30%) | Report 27 Finding 12 confirms these depend on forward_F. Budget 3 hours. BX5 self-accumulation + BX10 eventuality extraction + BX8 since-init provide the machinery. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel (though this plan is fully sequential due to mathematical dependencies).

---

### Phase 1: Extract DRM Chain Infrastructure from Boneyard [NOT STARTED]

**Goal**: Move the sorry-free DRM chain construction from `Boneyard/ChainCompleteness/Bundle/` into the active codebase, verify it compiles, and establish the foundation for the forward_F proof.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/DRMChain.lean` with the following content extracted from `Boneyard/ChainCompleteness/Bundle/ResolvingChain.lean` (lines 47-240):
  - `simplified_restricted_successor` (noncomputable def)
  - `simplified_restricted_successor_is_drm` (DRM preservation)
  - `simplified_restricted_successor_extends` (seed extension)
  - `simplified_restricted_successor_g_persistence` (g_content propagation)
  - `simplified_restricted_successor_f_step` (f_content resolve-or-defer)
  - `simplified_restricted_successor_succ` (Succ relation satisfaction)
- [ ] Update imports: the extracted code depends on `SimplifiedChain.lean` (also Boneyard). Extract `simplified_restricted_seed`, `simplified_restricted_seed_subset_u`, `simplified_restricted_seed_consistent`, `simplified_restricted_seed_subset_dc` from `SimplifiedChain.lean` (lines 59-96, all sorry-free) into the new file or a companion file
- [ ] Also extract the following from `SimplifiedChain.lean` that the ResolvingChain needs:
  - `deferralDisjunctions_subset_deferral_restricted_mcs`
  - `g_content_subset_deferral_restricted_mcs`
  - `p_step_blocking_restricted_subset`
  - `g_content_subset_deferralClosure`
  - `deferralDisjunctions_subset_deferralClosure`
  - `p_step_blocking_restricted_subset_deferralClosure`
  - `deferralDisjunction_eq` (used in the f_step proof)
  - `or_elim_neg_neg` (propositional combinator, may already exist in active codebase)
- [ ] Verify these are all sorry-free via `grep -n sorry DRMChain.lean`
- [ ] Add import to `RootScopedChain.lean`
- [ ] Run `lake build` to verify compilation

**Mathematical detail**: The extracted code proves that for any `DeferralRestrictedMCS phi u` with `F(neg bot) in u` (seriality), the `simplified_restricted_successor phi u h_drm h_F_top` is:
1. Also a `DeferralRestrictedMCS phi` (same closure)
2. Satisfies `Succ u v` (both g_persistence and f_step)
3. Is sorry-free (consistency follows from seed being a subset of u)

The critical difference from the full MCS chain: the DRM successor uses `deferralDisjunctions` (phi_or_F(phi) for each F(phi) in u) which are PROVABLY in u (because each is derivable from F(phi) in u via the axiom `F(phi) -> phi_or_F(phi)`). This means the seed is a subset of u, making consistency trivial -- no G-lift argument needed.

**Timing**: 2 hours

**Depends on**: none

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/BXCanonical/DRMChain.lean` -- new file, extracted from Boneyard
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add import

**Verification**:
- `grep -n sorry DRMChain.lean` returns zero
- `lake build` succeeds
- `simplified_restricted_successor_succ` is available in the active codebase

**GO/NO-GO DECISION POINT**: If any of the Boneyard dependencies (e.g., `SuccExistence.lean`, `SuccChainFMCS.lean`) pull in sorry-bearing code that cannot be disentangled, STOP and evaluate whether to:
(a) Inline the needed lemmas directly (preferred, ~50 extra LOC)
(b) Switch to Phase 1-ALT: begin the Quasimodel bridge (Phase 5)

---

### Phase 2: Build DRM Forward Chain and Prove forward_F within DRM [NOT STARTED]

**Goal**: Define an iterated DRM chain using `simplified_restricted_successor`, prove it satisfies `Succ` at each step, and apply `bounded_witness` (or a DRM-specific analog) to prove forward_F for formulas in `deferralClosure`.

**Tasks**:
- [ ] Define `drm_fwd_chain`: an iterated chain of DRM states
  ```
  drm_fwd_chain(phi, u, h_drm, h_F_top, 0) = u
  drm_fwd_chain(phi, u, h_drm, h_F_top, n+1) =
    simplified_restricted_successor(phi, drm_fwd_chain(..., n), ...)
  ```
  This requires carrying forward the DRM property and seriality (`F(neg bot) in u`) at each step. Prove:
  - `drm_fwd_chain_is_drm`: each state is a `DeferralRestrictedMCS`
  - `drm_fwd_chain_seriality`: `F(neg bot)` is in each state (follows from `deferralDisjunction` for `neg bot`: `neg bot or F(neg bot)` is in successor, and `neg bot` is a tautology, so `neg bot` is in every consistent set, hence `F(neg bot)` is derivable from it)

- [ ] Prove `drm_fwd_chain_succ`: consecutive states satisfy `Succ`
  ```
  Succ (drm_fwd_chain ... n) (drm_fwd_chain ... (n+1))
  ```
  This follows directly from `simplified_restricted_successor_succ`.

- [ ] Prove `drm_fwd_chain_forward_MCS_analog`: the DRM chain forms a `CanonicalTask_forward_MCS`-like chain. Two sub-approaches:

  **Sub-approach A (preferred)**: Prove a DRM-specific bounded_witness directly.

  The key insight: `bounded_witness` requires `CanonicalTask_forward_MCS u n v`, which requires each intermediate state to be `SetMaximalConsistent`. DRM states are NOT `SetMaximalConsistent` (they're maximal only within `deferralClosure`). However, the proof of `bounded_witness` only uses three properties of MCS:
  1. Negation completeness (to get `neg(FF(phi)) in u` from `FF(phi) not in u`)
  2. Consistency (to derive contradictions)
  3. Succ between consecutive states

  For DRM states, (1) holds for formulas in `subformulaClosure(phi)` (via `deferral_restricted_mcs_negation_complete`), and iter_F formulas up to `closure_F_bound` ARE in `deferralClosure` (which contains `closureWithNeg`). Property (2) holds by `deferral_restricted_mcs_is_consistent`. Property (3) holds by `simplified_restricted_successor_succ`.

  Therefore: prove `drm_bounded_witness`, a copy of `bounded_witness` where `SetMaximalConsistent` is replaced by `DeferralRestrictedMCS phi` and all formulas are required to be in `deferralClosure phi`. The proof structure is identical; only the negation completeness and consistency lemmas change.

  **Sub-approach B (fallback)**: Lift each DRM state to a full MCS via Lindenbaum, prove the lifted chain satisfies `Succ`, and apply the existing `bounded_witness`. This is more complex because the Lindenbaum extension may add formulas that break `Succ` (the extension includes formulas outside `deferralClosure` that could violate f_step).

- [ ] Prove `drm_fwd_chain_forward_F`: the key theorem
  ```
  For any psi in deferralClosure(phi) with f_nesting_depth(psi) = 0:
    if F(psi) in drm_fwd_chain(phi, u, ..., n),
    then exists s > n, psi in drm_fwd_chain(phi, u, ..., s).
  ```

  **Proof**: Since `psi` has `f_nesting_depth = 0`, it has no outer F-operators. We need `iter_F(d, psi)` for some `d` such that `iter_F(d, psi) in u` but `iter_F(d+1, psi) not in u`.

  Step 1: `F(psi) in drm_fwd_chain(n)`. Since `F(psi) in deferralClosure(phi)`, we can iterate: `F(F(psi)) = iter_F(2, psi)`. Is `iter_F(2, psi) in drm_fwd_chain(n)`?

  In a full MCS, yes (by `phi_in_mcs_imp_F_phi`: `F(psi) in M` implies `F(F(psi)) in M`). But in a DRM, `phi_in_mcs_imp_F_phi` does NOT hold because `F(F(psi))` may not be in `deferralClosure`. Specifically, `iter_F(k, psi)` exits `deferralClosure` when `k >= closure_F_bound(phi)`.

  Step 2: By `drm_iter_F_exit` (from `RestrictedMCS.lean:1111-1118`): there exists `d` such that `iter_F(d, psi) not in drm_fwd_chain(n)` (because `iter_F(closure_F_bound(phi), psi) not in deferralClosure(phi)`, hence not in any DRM state).

  Step 3: Let `d_max` be the largest `d` such that `iter_F(d, psi) in drm_fwd_chain(n)`. Then `iter_F(d_max, psi) in drm_fwd_chain(n)` and `iter_F(d_max + 1, psi) not in drm_fwd_chain(n)`.

  Step 4: The DRM chain from step `n` to step `n + d_max` forms a `d_max`-step Succ chain. Apply `drm_bounded_witness` to get `psi in drm_fwd_chain(n + d_max)`.

  **Critical verification**: We need `d_max >= 1` (otherwise `F(psi)` itself is not in the DRM, contradicting our hypothesis). Since `F(psi) in drm_fwd_chain(n)` and `F(psi) = iter_F(1, psi)`, we have `d_max >= 1`. The bounded_witness with `d_max` steps gives `psi in drm_fwd_chain(n + d_max)` where `n + d_max > n`. Done.

- [ ] Verify the entire forward_F proof compiles sorry-free

**Timing**: 5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/DRMChain.lean` -- chain iteration, drm_bounded_witness, forward_F

**Verification**:
- `drm_fwd_chain_forward_F` compiles without sorry
- `lake build` succeeds
- The proof uses only sorry-free dependencies

**GO/NO-GO DECISION POINT**: If `drm_bounded_witness` cannot be proved because the DRM negation completeness is insufficient (e.g., `neg_FF_implies_GG_neg_in_mcs` requires full MCS double-negation elimination that the DRM lacks), evaluate:
(a) Whether `deferral_restricted_mcs_double_negation_elim` (RestrictedMCS.lean:860-867) suffices -- it requires `psi in deferralClosure(phi)`, which holds for `iter_F(d, psi)` when `d < closure_F_bound`
(b) If (a) fails, switch to the Quasimodel fallback (Phase 5)

---

### Phase 3: Wire DRM forward_F into RootScopedChain Sorry Sites [NOT STARTED]

**Goal**: Bridge the DRM-based `drm_fwd_chain_forward_F` into the existing `rr_fwd_chain_forward_F` theorem, then close sorry sites 1-4 (lines 3644, 3688, 3695, 3748).

**Tasks**:
- [ ] Close sorry site 1: `rr_fwd_chain_forward_F` depth-0 base case (line 3644)

  **Strategy**: Replace the chain construction. Instead of trying to prove forward_F for the existing `rr_fwd_chain` (which uses `enriched_fwd_step` and faces perpetual deferral), construct a NEW chain that has forward_F and expose it through the same `dd_fmcs` / `dd_bfmcs` interface.

  **Concrete approach**: Replace `rr_fwd_chain` with `drm_lifted_fwd_chain`:
  1. Build the DRM chain: `drm_fwd_chain(phi, M0_restricted, ...)` where `M0_restricted` is M0 intersected with `deferralClosure(phi)` (extended to a DRM via `deferral_restricted_lindenbaum`)
  2. Lift each DRM state to a full MCS via `lindenbaum` (the standard Lindenbaum lemma for full MCS)
  3. The lifted chain inherits forward_F for deferralClosure formulas (membership in DRM implies membership in the MCS extension, since the DRM is a SUBSET of the extension)

  **Alternative approach** (simpler): Modify the proof of `rr_fwd_chain_forward_F` to use `drm_fwd_chain_forward_F` as a black box. The argument:
  - Given `F(psi) in rr_fwd_chain(n)` with `f_nesting_depth(psi) = 0`
  - Restrict `rr_fwd_chain(n)` to `deferralClosure(root)` to get a DRM seed
  - Extend to `DeferralRestrictedMCS` via `deferral_restricted_lindenbaum`
  - Build a DRM chain from this point
  - Apply `drm_fwd_chain_forward_F` to get `psi in drm_fwd_chain(s)` for some `s`
  - Lift `drm_fwd_chain(s)` to a full MCS
  - **PROBLEM**: the lifted MCS is NOT the same as `rr_fwd_chain(s)`. The theorem requires `psi in rr_fwd_chain(s)`, not in some other MCS.

  **Resolution**: The theorem `rr_fwd_chain_forward_F` is about a SPECIFIC chain (`rr_fwd_chain`). We cannot prove forward_F for this specific chain (Report 26 proves it's blocked). Therefore, we MUST replace the chain. This means:
  1. Define `drm_lifted_fwd_chain` as the replacement for `rr_fwd_chain`
  2. Prove it has all the properties that `dd_fmcs` needs:
     - Each state is an MCS (by Lindenbaum lift)
     - g_content propagation (from DRM's g_persistence, preserved by Lindenbaum lift since g_content formulas are in deferralClosure)
     - forward_F for sigma_list formulas (from `drm_fwd_chain_forward_F`, preserved by lift)
     - M0 at step 0 (the lift of the initial DRM extends M0's restriction, so M0-formulas in deferralClosure are preserved; M0-formulas outside deferralClosure need separate handling)
  3. Replace `rr_fwd_chain` with `drm_lifted_fwd_chain` in `dd_chain` and propagate

- [ ] Handle the M0-consistency issue: The DRM chain starts from `M0 intersect deferralClosure(root)` extended to a DRM. The lifted chain starts from a full MCS extending this DRM. This full MCS may DIFFER from M0 on formulas outside `deferralClosure(root)`. For `dd_fmcs`, we need `dd_chain(0) = M0`.

  **Solution**: Instead of starting from an arbitrary DRM extension, start from M0 itself (which is a full MCS). Observe that M0, restricted to `deferralClosure(root)`, IS a DRM (proof: M0 is consistent, and M0 restricted to deferralClosure is maximal within deferralClosure because for any `psi in deferralClosure`, either `psi in M0` or `neg(psi) in M0`, and if `psi not in M0 intersect deferralClosure` but `psi in deferralClosure`, then `psi not in M0`, so `neg(psi) in M0`, and inserting `psi` into `M0 intersect deferralClosure` is inconsistent because it together with `neg(psi)` from `M0` -- wait, we need to be careful here because the DRM only sees formulas in `deferralClosure`, and `neg(psi)` may not be in `deferralClosure`).

  **Actually**: Use `deferral_restricted_lindenbaum` starting from the set `{phi in M0 | phi in deferralClosure(root)}`. This gives a DRM that extends M0's deferralClosure-restricted part. Build the DRM chain from this. At step 0, the DRM state contains all of M0's deferralClosure formulas. The full-MCS lift at step 0 can be chosen to be M0 itself (by Lindenbaum starting from M0's deferralClosure formulas, which is consistent because M0 is consistent, and extending to full MCS can recover M0).

  **Cleaner solution**: Keep `dd_chain(0) = M0`. For the forward chain, use the DRM chain starting from the DRM restriction of M0. The forward_F proof gives `psi in drm_chain(s)`. Since `psi in deferralClosure(root)` and the DRM chain state at `s` is a subset of the lifted MCS chain state at `s`, we get `psi in lifted_chain(s)`. Define `drm_lifted_fwd_chain(0) = M0` and `drm_lifted_fwd_chain(n+1) = lift(drm_chain(n+1))` with the lift chosen to include the DRM state as a subset.

- [ ] Close sorry site 2: `dd_fmcs_forward_F` t < 0 case (line 3688)

  **Strategy**: For `t < 0`, we're in the backward chain. `F(psi) in bwd_chain(|t|)` means F(psi) is present at a backward state. The backward chain is built via `bwd_pred` (symmetric to `fwd_succ`).

  **Approach**: If `F(psi) in dd_chain(t)` for `t < 0`:
  - By g_content propagation backwards-to-forwards: `F(psi) in dd_chain(t)` does NOT automatically give `F(psi) in dd_chain(0)` (g_content goes forward, h_content goes backward)
  - However, if `G(F(psi)) in dd_chain(t)`, then `F(psi) in g_content(dd_chain(t))`, hence `F(psi) in dd_chain(t+1)`, ..., `F(psi) in dd_chain(0)`, and then use forward_F in the forward chain.
  - But `G(F(psi))` may not be in `dd_chain(t)`.
  - **Alternative**: build a DRM FORWARD chain starting from dd_chain(t) itself (not from M0). The DRM forward_F gives `psi in drm_chain(s)` for some `s > 0`. The lifted chain gives `psi` at an absolute position `t + s > t`. Wire this into dd_fmcs by extending dd_chain to include these additional forward states from the backward endpoint.
  - **Simplest approach**: Modify `dd_chain` so that for each backward state, a forward DRM chain extends from it. Then `dd_fmcs_forward_F` for `t < 0` follows from the DRM forward_F applied to the state at time `t`.

- [ ] Close sorry site 3: `dd_fmcs_backward_P` (line 3695)

  **Strategy**: Symmetric to forward_F, using the backward DRM chain with `p_nesting_depth` and `Pred` relation.

- [ ] Close sorry site 4: `dd_bfmcs_restricted_tc` (line 3748)

  **Strategy**: `restricted_temporally_coherent` requires forward_F and backward_P for deferralClosure formulas. With sites 1-3 closed, this assembles from `dd_fmcs_forward_F` + `dd_fmcs_backward_P`.

- [ ] Run `lake build`

**Timing**: 5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace chain construction, close sorry sites 1-4
- `Theories/Bimodal/Metalogic/BXCanonical/DRMChain.lean` -- additional lemmas for chain lifting

**Verification**:
- Sorry sites at lines 3644, 3688, 3695, 3748 are closed
- `lake build` succeeds
- `grep -n sorry RootScopedChain.lean` shows at most 2 remaining (sites 5-6)

---

### Phase 4: Close Until/Since Coherence (Sorry Sites 5-6) [NOT STARTED]

**Goal**: Close `dd_bfmcs_restricted_buc` (line 3753) and `dd_bfmcs_restricted_fuc` (line 3758), achieving zero sorry in `RootScopedChain.lean`.

**Tasks**:
- [ ] Close sorry site 5: `dd_bfmcs_restricted_fuc` (forward Until/Since coherence, line 3758)

  **Mathematical argument for Until `(phi U psi)` in `fam.mcs(t)`:
  1. By BX10 (`until_F`): `(phi U psi) -> F(psi)`. So `F(psi) in fam.mcs(t)`.
  2. By `dd_fmcs_forward_F` (now proved): exists `s > t` with `psi in fam.mcs(s)`.
  3. Need guard: `phi in fam.mcs(r)` for all `r in [t, s)` (half-open, reflexive semantics).
  4. By BX5 (`self_accum_until`): `(phi U psi) -> ((phi AND (phi U psi)) U psi)`. So at time `t`, `((phi AND (phi U psi)) U psi)` holds.
  5. At each `r in [t, s)`: if `psi not in fam.mcs(r)` (which holds since `r < s` and `s` is the first witness), then by BX9 (`until_elim`): `(phi U psi) -> (phi OR psi)`, and since `psi not in fam.mcs(r)`, `phi in fam.mcs(r)`.
  6. Actually, step 5 requires `(phi U psi) in fam.mcs(r)` for all `r in [t, s)`. This follows from g_content propagation: `(phi U psi)` is G-stable (if `G(phi U psi) in fam.mcs(t)`, it propagates). But we don't have `G(phi U psi)` directly.
  7. **Inductive argument**: At time `t`: `(phi U psi) in fam.mcs(t)`. By BX5 + BX9: `phi in fam.mcs(t)` or `psi in fam.mcs(t)`. If `psi in fam.mcs(t)`, take `s = t` (reflexive witness). If `phi in fam.mcs(t)`, we need `(phi U psi) in fam.mcs(t+1)`. Use BX7 (`induction_until`): `(phi U psi) -> (psi OR (phi AND G(phi U psi)))`. If `psi not in fam.mcs(t)`, then `phi AND G(phi U psi) in fam.mcs(t)`. So `G(phi U psi) in fam.mcs(t)`, hence `(phi U psi) in fam.mcs(t+1)` by g_content propagation. Repeat until `psi` appears at some step.
  8. This induction terminates because `psi` DOES appear (from step 2), so the guard holds on `[t, s)`.

  **For Since**: Symmetric via backward_P and H-content propagation.

- [ ] Close sorry site 6: `dd_bfmcs_restricted_buc` (backward Until/Since coherence, line 3753)

  **Mathematical argument**: Given witness pattern (`psi at s`, `phi` on guard for `r in [t, s)`), derive `(phi U psi) in fam.mcs(t)`.

  1. At time `s`: `psi in fam.mcs(s)`. By BX8 (`since_init` / `until_init`): `psi -> (phi U psi)`. So `(phi U psi) in fam.mcs(s)`.
  2. At time `s-1` (if `s > t`): `phi in fam.mcs(s-1)` (guard). `(phi U psi) in fam.mcs(s)`. By g_content: if `G(phi U psi) in fam.mcs(s-1)`, then `(phi U psi) in fam.mcs(s)` -- but we need the REVERSE: `(phi U psi) in fam.mcs(s)` does not directly give `(phi U psi) in fam.mcs(s-1)`.
  3. **Use restricted_temporal_backward_G_strict** (now available because forward_F is proved): If `(phi U psi) in fam.mcs(r)` for all `r > s-1` (which is just `r = s` when `s = t+1`), and `neg(phi U psi) in deferralClosure(root)`, then `G(phi U psi) in fam.mcs(s-1)`.
  4. With `G(phi U psi) in fam.mcs(s-1)` and `phi in fam.mcs(s-1)`, use BX6 (`absorb_until`): `phi AND G(phi U psi) -> (phi U psi)`. So `(phi U psi) in fam.mcs(s-1)`.
  5. Repeat backward induction from `s-1` to `t`.

  **For Since**: Symmetric via backward direction.

- [ ] Run `grep -n sorry RootScopedChain.lean` to verify zero sorry
- [ ] Run `lake build`

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry sites 5-6

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `grep -n sorry RootScopedChain.lean` returns only comment-embedded occurrences
- `lake build` succeeds

---

### Phase 5: Quasimodel Bridge (FALLBACK -- execute only if Phases 1-3 fail) [NOT STARTED]

**Goal**: If the DRM approach fails at any go/no-go decision point, implement the Quasimodel bridge: extract an Int-indexed FMCS family from the sorry-free Quasimodel infrastructure and wire it into `dd_bfmcs`.

**Tasks**:
- [ ] Define `BXPoint_to_FMCS_family`: a functor from BXPoint chains to FMCS families

  **Mathematical detail**: The Quasimodel infrastructure (1,816 lines, all sorry-free) constructs finite chains of `HintikkaPoint` / `BXPoint` that discharge Until/Since defects. The key structures:
  - `HintikkaPoint` (HintikkaPoint.lean): a subset of `subformulaClosure(root)` satisfying Hintikka conditions (propositionally consistent, boolean closure, temporal consistency)
  - `BXPoint` (Construction.lean): extends HintikkaPoint with modal information (box-formulas consistent with S5)
  - `bx_le` (Construction.lean): preorder on BXPoints capturing "later or equal" -- `bx_le u v` means every G-formula in u is also in v
  - `quasimodel_chain_exists` (Construction.lean): for any satisfiable root, there exists a BXPoint chain discharging all defects

  The bridge construction:
  1. Start from `quasimodel_chain_exists` to get a `List BXPoint` chain
  2. For each BXPoint `b`, define `lift_to_MCS(b)`: extend `b.formulas` (a subset of `subformulaClosure(root)`) to a full MCS via `lindenbaum`
  3. Index the resulting MCS chain by `Int` (forward from 0, backward from 0)
  4. Prove the lifted chain has the FMCS properties:
     - Each state is MCS (by construction)
     - g_content propagation: follows from `bx_le` (G-formulas propagate forward) + Lindenbaum preserving g_content
     - forward_F: follows from the quasimodel's defect-discharge property
     - backward_P: symmetric

- [ ] Prove `quasimodel_fmcs_forward_F`:

  **Mathematical argument**: The quasimodel chain discharges all F-defects. For F(psi) in BXPoint(n), the chain construction ensures psi appears at some BXPoint(s) for s > n. Since `psi in BXPoint(s).formulas` implies `psi in lift_to_MCS(BXPoint(s))`, forward_F transfers to the lifted chain.

- [ ] Prove `quasimodel_fmcs_backward_P`: symmetric.

- [ ] Handle modal coherence across chain segments:

  **Critical obstacle** (Report 28, Realization.lean:29-30): The `bx_le` preorder is NOT total. Different BXPoint chains from different modal worlds may have incomparable G-content. For the BFMCS construction, we need a FAMILY of FMCS (one per modal world), and all families must agree on box-formulas.

  **Approach**: For each modal world `w` (from the S5 modal equivalence class), build a separate BXPoint chain and lift to FMCS. Box-formula agreement follows from S5 (all worlds in the same equivalence class agree on box-formulas). The BFMCS's `modal_forward` and `modal_backward` properties follow from S5 axioms.

- [ ] Wire quasimodel FMCS into `dd_bfmcs` replacing the current `dd_fmcs`-based construction
- [ ] Close all 6 sorry sites using the quasimodel-based BFMCS
- [ ] Run `lake build`

**Timing**: 8 hours (only executed if DRM approach fails)

**Depends on**: failure of Phases 1-3 (conditional execution)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/BXCanonical/QuasimodelBridge.lean` -- new file
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace chain construction

**Verification**:
- All 6 sorry sites closed
- `lake build` succeeds
- `grep -n sorry RootScopedChain.lean` returns only comment-embedded occurrences

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `grep -n sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero executable sorry (after Phase 4 or Phase 5)
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/DRMChain.lean` returns zero (after Phase 1)
- [ ] `lean_verify` on `dd_countermodel` shows no sorry-dependent axioms
- [ ] `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No new sorry introduced in any active-path file
- [ ] `drm_fwd_chain_forward_F` proof uses only sorry-free dependencies (no transitive sorry contamination through Boneyard imports)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/DRMChain.lean` -- DRM chain construction, drm_bounded_witness, drm_fwd_chain_forward_F
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- 6 sorry sites closed
- `Theories/Bimodal/Metalogic/BXCanonical/QuasimodelBridge.lean` -- (conditional, only if DRM fails)
- `specs/093_complete_bxcanonical_embedding/plans/28_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

1. **Full success (all 6 sorries closed via DRM)**: Target outcome. No rollback needed.

2. **DRM approach succeeds for forward_F but Until/Since blocked (~15%)**: Keep forward_F/backward_P/restricted_tc proofs (reduces sorry count from 6 to 2). Spawn focused follow-up for Until/Since coherence.

3. **DRM approach blocked at Phase 1 (Boneyard dependency issues, ~20%)**: Switch to Phase 5 (Quasimodel bridge). The DRM extraction work is wasted (~2 hours), but the analysis informs the bridge design.

4. **DRM approach blocked at Phase 2 (drm_bounded_witness fails, ~15%)**: Switch to Phase 5. The DRM chain infrastructure is still useful as intermediate steps.

5. **Both approaches fail (~5%)**: Commit partial progress (DRM chain extraction, Quasimodel bridge skeleton). The depth-0 forward_F problem is a genuine mathematical obstacle that may require a fundamentally different approach (e.g., Gabbay-rule style fixed-point construction, or a direct semantic argument).

6. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/` restores the current state. New files (`DRMChain.lean`, `QuasimodelBridge.lean`) can be deleted.
