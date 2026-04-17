# Implementation Plan: Close BXCanonical Embedding (v29 -- Semantic Forward_F + ROAD_MAP Update)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None (task 102 completed; truth lemma sorry-free)
- **Research Inputs**: reports/29_team-research.md, reports/28_depth-zero-base-case.md, reports/27_team-research.md
- **Artifacts**: plans/29_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Six sorry sites in `RootScopedChain.lean` (lines 3644, 3688, 3695, 3748, 3753, 3758) block `bx_completeness`. Plan v28 (DRM Succ chain + bounded_witness) was found structurally blocked by Report 29: `SetMaximalConsistent` negation completeness is required but DRM provides only `DeferralRestrictedMCS`, three independent gaps make the approach unimplementable. Report 29 identifies a KEY new insight: the targeted seed `{psi} union g_content(u)` IS provably consistent when `F(psi) in subformulaClosure(phi)`, and recommends Sub-approach 1c (literature-aligned): restructure `dd_countermodel` to use semantic `forward_F` from `bx_forward_witness` rather than chain-level forward_F. This plan begins with a ROAD_MAP.md update (Phase 1) to document Report 29's findings, then implements the semantic forward_F approach. Definition of done: `lake build` succeeds with zero sorry in `RootScopedChain.lean`.

### Research Integration

- **Report 29** (team research, 4 teammates): DRM bounded_witness blocked (Finding 1), targeted seed consistent (Finding 4), literature consensus against one-chain-all-obligations (Finding 14), sorry 6 has independent Until persistence obstacle (Finding 12). Recommends Sub-approach 1c (semantic forward_F via `bx_forward_witness`).
- **Report 28** (depth-0 base case): Paths A (omega-squared), C (counting), F (circularity) blocked. Path D (DRM) recommended but now superseded by Report 29.
- **Report 27** (team research): Goldblatt WF-induction convergence. DRM approach a refinement, now known to be blocked.

### Prior Plan Reference

Plan v28 (18 hours, 5 phases) focused on DRM Succ chain extraction from Boneyard + bounded_witness within DRM. Phase 1 (extract DRM chain from Boneyard) marked COMPLETED. Phase 2 (DRM bounded_witness) marked PARTIAL. Research 29 found Plan 28's core premise wrong: `SetMaximalConsistent` required but DRM only provides `DeferralRestrictedMCS`. Lesson learned: approaches requiring type-level properties unavailable in DRM states are systematically blocked. Effort calibration: Phase 1 extraction took ~2 hours (as estimated), validating that infrastructure extraction tasks are well-calibrated.

### Roadmap Alignment

- Closes `rr_fwd_chain_forward_F` (PRIMARY BLOCKER, ROAD_MAP sorry inventory)
- Makes `dd_countermodel` sorry-free, resolving `Completeness.lean:154`
- Unblocks task 95 (`#print axioms` audit on `bx_completeness`)
- Eliminates all 6 active-path sorries in the BXCanonical module

## Goals & Non-Goals

**Goals**:
- Update ROAD_MAP.md with Report 29 findings (dead ends 27-29, updated strategy, corrected sorry line numbers)
- Close all 6 sorry sites in `RootScopedChain.lean` using semantic forward_F approach
- Achieve `lake build` with zero sorry in active BXCanonical path
- Prove targeted seed consistency lemma (key mathematical breakthrough from Report 29)

**Non-Goals**:
- Modifying the truth lemma or quasimodel infrastructure (sorry-free, proven correct)
- Dense completeness (independent task 68)
- Cleaning up Boneyard code (separate effort)
- Game-theoretic approach (3000+ new LOC, not justified)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Semantic forward_F from `bx_forward_witness` produces BXPoint not on chain -- cannot wire into `dd_fmcs` signature | H | M (40%) | Sub-approach 1c restructures dd_countermodel to accept per-formula witnesses. The truth lemma goes through BXPoints, not chain indices. Alternatively, define dd_fmcs to allow per-query witness injection. |
| Targeted seed consistency lemma harder than expected in Lean | M | L (20%) | The math is clear (generalized temporal K argument). The Lean proof follows `forward_temporal_witness_seed_consistent` pattern in WitnessSeed.lean. |
| Sorry 6 (forward Until coherence) has independent Until persistence obstacle beyond forward_F | M | M (35%) | Report 29 Finding 12 identifies this. Budget separate time in Phase 5. Use BX5 self-accumulation + BX7 induction_until for guard propagation. |
| Backward_P case (sorry 3) requires symmetric construction not yet built | M | L (25%) | `bx_backward_witness` is sorry-free (symmetric to `bx_forward_witness`). The backward targeted seed is symmetric. |
| Quasimodel bridge fallback more complex than estimated | M | M (30%) | Budget 600-1000 LOC per Report 29. The sorry-free infrastructure is mature (1,816 lines). Only execute if semantic forward_F fails. |

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

### Phase 1: Update ROAD_MAP.md [NOT STARTED]

**Goal**: Update `specs/ROAD_MAP.md` with Report 29 findings before implementation begins. Add dead ends 27-29, update strategy section from "Goldblatt WF-induction" to "semantic forward_F via targeted seed", update sorry line numbers if changed, and correct the "Current Strategy" narrative.

**Tasks**:
- [ ] Add dead ends 27-29 to the "Dead Ends (Archived)" section:
  - (27) DRM bounded_witness via single_step_forcing: negation completeness gap at F-nesting boundary. `SetMaximalConsistent` required but DRM provides only `DeferralRestrictedMCS`. Three independent gaps make the approach unimplementable (Report 29, Findings 1, 11).
  - (28) Full MCS bounded_witness: F-reflexivity (`phi_in_mcs_imp_F_phi`) makes all `iter_F` present in full MCS, so the exit condition `iter_F(d+1, psi) NOT in M` never holds. `bounded_witness` designed for restricted MCS only (Report 29, Finding 2).
  - (29) DRM chain preventing perpetual deferral: DRM chain's `f_step` condition has the same Lindenbaum non-determinism as `enriched_fwd_step`. Merely relocates the non-determinism (Report 29, Finding 3).
- [ ] Update the "Current Strategy" subsection (currently "Goldblatt WF-Induction Chain (Plan v27)") to describe the new approach:
  - Strategy: Semantic forward_F via targeted seed consistency + `bx_forward_witness`
  - Key insight: targeted seed `{psi} union g_content(u)` is provably consistent when `F(psi) in subformulaClosure(phi)` (generalized temporal K argument)
  - Literature alignment: per-formula resolution rather than one-chain-all-obligations (Burgess, GHR, Goldblatt)
  - Plan reference: v29
- [ ] Update sorry line numbers in the "Active-Path Sorry Inventory" table if they have changed from the values listed (currently 1321, 1352, 1359, 1412, 1417, 1422 -- actual current values are 3644, 3688, 3695, 3748, 3753, 3758)
- [ ] Update the "Task 93: Progress and Infrastructure" subsection to note Report 29 findings and the DRM approach being blocked
- [ ] Update the "last updated" timestamp and description at bottom of file
- [ ] Verify ROAD_MAP.md is internally consistent after edits

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `specs/ROAD_MAP.md` -- dead ends, strategy section, sorry line numbers, progress notes

**Verification**:
- Dead ends 27, 28, 29 appear in the Dead Ends section
- Strategy section references "semantic forward_F" and "targeted seed consistency"
- Sorry line numbers match actual file (3644, 3688, 3695, 3748, 3753, 3758)
- Last-updated timestamp is current

---

### Phase 2: Prove Targeted Seed Consistency Lemma [NOT STARTED]

**Goal**: Prove in Lean that `{psi} union g_content(u)` is consistent when `F(psi) in u` and `u` is a BXPoint (MCS). This is the key mathematical breakthrough from Report 29 Finding 4 and is required by all subsequent phases.

**Tasks**:
- [ ] Define `targeted_forward_seed (u : BXPoint) (psi : Formula) : Set Formula` as `{psi} union g_content(u.formulas)` in a suitable location (either `RootScopedChain.lean` or a new helper section)
- [ ] Prove `targeted_forward_seed_consistent`: if `F(psi) in u.formulas` and `u.is_mcs`, then `targeted_forward_seed u psi` is consistent
  - **Proof sketch**: Suppose `targeted_forward_seed u psi` is inconsistent. Then `{psi} union g_content(u)` derives `bot`. By deduction theorem, `g_content(u) derives neg(psi)`. By `g_content_closed_derivation` (Frame.lean:79-94), `G(neg(psi)) in u.formulas`. But `F(psi) = neg(G(neg(psi)))` is in `u.formulas` (hypothesis), and `u` is an MCS, so both `G(neg(psi))` and `neg(G(neg(psi)))` are in `u.formulas`, contradicting consistency.
- [ ] Prove `targeted_forward_seed_extends_g_content`: `g_content(u.formulas) subset targeted_forward_seed u psi` (trivial by definition)
- [ ] Prove `targeted_forward_seed_contains_target`: `psi in targeted_forward_seed u psi` (trivial)
- [ ] Verify `targeted_forward_seed_consistent` compiles sorry-free

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- new lemmas for targeted seed

**Verification**:
- `targeted_forward_seed_consistent` compiles without sorry
- `lake build` succeeds
- The proof uses only sorry-free dependencies (Frame.lean:79-94 `g_content_closed_derivation` is sorry-free)

---

### Phase 3: Implement Semantic Forward_F and Close Sorries 1-3 [NOT STARTED]

**Goal**: Use `targeted_forward_seed_consistent` + `set_lindenbaum` to prove existential forward_F for the chain, then close sorry sites 1-3 (lines 3644, 3688, 3695).

**Tasks**:
- [ ] Prove `semantic_forward_F_witness`: given `F(psi) in u.formulas` for BXPoint `u`, construct a BXPoint `v` with `psi in v.formulas` and `bx_le u v`
  - **Approach**: This may already be `bx_forward_witness` (Frame.lean:164-171, sorry-free). Verify its signature matches the need. If `bx_forward_witness` already provides this, no new proof needed.
  - If `bx_forward_witness` does NOT directly give `psi in v` (only `bx_le u v` for G-content), then use the targeted seed: extend `targeted_forward_seed u psi` via `set_lindenbaum` to a full MCS `v_mcs`, then wrap as BXPoint. `psi in v_mcs` by seed containment. `bx_le u v` because `g_content(u) subset targeted_forward_seed subset v_mcs`.

- [ ] Close sorry site 1: `rr_fwd_chain_forward_F` depth-0 base case (line 3644)
  - **Strategy**: Given `F(psi) in rr_fwd_chain(n)` with `f_nesting_depth(psi) = 0`:
    1. Apply `semantic_forward_F_witness` to `rr_fwd_chain(n)` and `psi`
    2. Get BXPoint `v` with `psi in v` and `bx_le rr_fwd_chain(n) v`
    3. The problem: `v` may not be `rr_fwd_chain(s)` for any `s > n`
    4. **Resolution**: Redefine `dd_fmcs` to inject the targeted witness at the right step, OR restructure the forward_F obligation to accept per-formula existential witnesses from outside the chain
  - **If chain injection is needed**: Modify `rr_fwd_chain` to splice in the targeted witness. At step `n+1`, instead of using `enriched_fwd_step`, use the targeted MCS from `semantic_forward_F_witness`. The spliced chain still satisfies g_content propagation (by construction: `g_content(chain(n)) subset targeted_seed subset chain(n+1)`).
  - **If dd_fmcs restructuring is chosen**: Modify `dd_fmcs` forward_F to accept an existential witness BXPoint rather than requiring the witness to be a chain member. This changes the FMCS interface but aligns with the literature (per-formula resolution).

- [ ] Close sorry site 2: `dd_fmcs_forward_F` t < 0 case (line 3688)
  - **Strategy**: For `t < 0`, `F(psi) in dd_chain(t)` where `t` is in the backward chain. Apply `semantic_forward_F_witness` directly to `dd_chain(t)` to get witness BXPoint `v` with `psi in v` and `bx_le dd_chain(t) v`. Wire `v` into the dd_fmcs family at some index `s > t`.

- [ ] Close sorry site 3: `dd_fmcs_backward_P` (line 3695)
  - **Strategy**: Symmetric to forward_F using `bx_backward_witness` (sorry-free). Given `P(psi) in dd_chain(t)`, construct BXPoint `v` with `psi in v` and `bx_le v dd_chain(t)` (i.e., `g_content(v) subset dd_chain(t)`). This is the targeted backward seed: `{psi} union h_content(u)` is consistent by the symmetric argument (using `h_content_closed_derivation`, Frame.lean:101-114).

- [ ] Run `lake build` and verify sorry count reduced from 6 to 3

**Timing**: 5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry sites 1-3, potentially restructure dd_fmcs

**Verification**:
- Sorry sites at lines 3644, 3688, 3695 are closed
- `lake build` succeeds
- `grep -n sorry RootScopedChain.lean` shows at most 3 remaining (sites 4-6)

---

### Phase 4: Close Restricted Temporal Coherence (Sorry Site 4) [NOT STARTED]

**Goal**: Close `dd_bfmcs_restricted_tc` (line 3748) using the forward_F and backward_P results from Phase 3.

**Tasks**:
- [ ] Examine the `restricted_temporally_coherent` definition to understand what it requires beyond forward_F and backward_P
  - Expected: forward_G (G-formulas propagate forward, follows from g_content and bx_le), backward_H (symmetric), forward_F (proved in Phase 3), backward_P (proved in Phase 3)
- [ ] Prove `dd_bfmcs_restricted_tc` by assembling the four temporal coherence properties:
  - `forward_G`: follows from `dd_chain_g_content` (existing, sorry-free) -- if `G(psi) in dd_chain(t)`, then `psi in g_content(dd_chain(t)) subset dd_chain(t+1)`
  - `backward_H`: symmetric via `dd_chain_h_content`
  - `forward_F`: from `dd_fmcs_forward_F` (Phase 3)
  - `backward_P`: from `dd_fmcs_backward_P` (Phase 3)
- [ ] Run `lake build`

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry site 4

**Verification**:
- Sorry site at line 3748 is closed
- `lake build` succeeds
- `grep -n sorry RootScopedChain.lean` shows at most 2 remaining (sites 5-6)

---

### Phase 5: Close Until/Since Coherence (Sorry Sites 5-6) [NOT STARTED]

**Goal**: Close `dd_bfmcs_restricted_buc` (line 3753) and `dd_bfmcs_restricted_fuc` (line 3758), achieving zero sorry in `RootScopedChain.lean`.

**Tasks**:
- [ ] Examine `restricted_backward_until_since_coherent` and `restricted_forward_until_since_coherent` definitions to understand their exact requirements

- [ ] Close sorry site 6: `dd_bfmcs_restricted_fuc` (forward Until/Since coherence, line 3758)
  - **Mathematical argument for Until `(phi U psi)` in `fam.mcs(t)`**:
    1. By BX10 (`until_F`): `(phi U psi) -> F(psi)`. So `F(psi) in fam.mcs(t)`.
    2. By `dd_fmcs_forward_F` (now proved): exists `s > t` with `psi in fam.mcs(s)`.
    3. Need guard: `phi in fam.mcs(r)` for all `r in [t, s)`.
    4. By BX5 (`self_accum_until`): `(phi U psi) -> ((phi AND (phi U psi)) U psi)`. The Until formula enriches its own guard.
    5. Inductive guard propagation: At each `r in [t, s)`, if `psi not in fam.mcs(r)`, then by BX9 (`until_elim`) applied to the enriched formula, `phi in fam.mcs(r)`. The `(phi U psi)` component propagates forward via BX7 (`induction_until`): if `psi` does not hold now, then `G(phi U psi)` holds, so `(phi U psi)` is in g_content and propagates.
    6. Termination: `psi` appears at `s` (from step 2), so the induction terminates.
  - **Note on Report 29 Finding 12**: Sorry 6 has an independent Until persistence obstacle. The guard propagation in step 5 requires `(phi U psi) in fam.mcs(r)` for intermediate `r`, which comes from BX7's `G(phi U psi)` -- this IS guaranteed by g_content propagation once we have `G(phi U psi)` at time `t`. BX7 gives `(phi U psi) -> (psi OR (phi AND G(phi U psi)))`, and since `psi` does not hold at `t` (otherwise `s = t`), we get `G(phi U psi) in fam.mcs(t)`.
  - For Since: symmetric via backward_P and H-content propagation.

- [ ] Close sorry site 5: `dd_bfmcs_restricted_buc` (backward Until/Since coherence, line 3753)
  - **Mathematical argument**: Given semantic witness pattern (psi at s, phi on guard for r in [t, s)), derive `(phi U psi) in fam.mcs(t)`.
    1. At time `s`: `psi in fam.mcs(s)`. By BX8 (`refl_intro_until`): `psi -> (phi U psi)`. So `(phi U psi) in fam.mcs(s)`.
    2. Backward induction from `s` to `t`: At each `r in [t, s)`, `phi in fam.mcs(r)` (guard hypothesis) and `(phi U psi) in fam.mcs(r+1)` (inductive hypothesis). Need to derive `(phi U psi) in fam.mcs(r)`.
    3. Use BX4 (`connect_future`): `(phi U psi) -> H(F(phi U psi))` at `r+1`. Actually, need a different axiom.
    4. Alternative: At `r`, `phi in fam.mcs(r)` and `F(psi) in fam.mcs(r)` (since `psi in fam.mcs(s)` and `s > r`). By BX12 (`F_until_equiv`): `F(psi) -> (top U psi)`. So `(top U psi) in fam.mcs(r)`. By left monotonicity (BX2): if `G(phi -> top)` holds (tautology), then `(phi U psi) in fam.mcs(r)` follows from `(top U psi)`. Actually BX2 gives `G(top -> phi) -> ((top U psi) -> (phi U psi))`, which requires `G(top -> phi)` = `G(phi)`. This does NOT hold in general.
    5. Simpler approach: At `r`, `phi in fam.mcs(r)`. `psi in fam.mcs(s)` for `s > r`. `phi` holds on `[r, s)`. This is exactly the semantic condition for `(phi U psi)` at `r`. The restricted truth lemma (already proved) converts this semantic condition to syntactic membership. But we need the CHAIN-level membership, not the model-level truth.
    6. This direction (backward Until coherence) may require the restricted parametric truth lemma to convert between semantic truth and MCS membership. Investigate the exact interface.

- [ ] If backward Until coherence requires truth lemma conversion, wire through `RestrictedParametricTruthLemma` (already imported, sorry-free)
- [ ] Run `grep -n sorry RootScopedChain.lean` to verify zero executable sorry
- [ ] Run `lake build` to verify compilation

**Timing**: 4 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry sites 5-6

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `grep -n sorry RootScopedChain.lean` returns only comment-embedded occurrences (no executable sorry)
- `lake build` succeeds
- `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `grep -n sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero executable sorry (after Phase 5)
- [ ] `lean_verify` on `dd_countermodel` shows no sorry-dependent axioms
- [ ] `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No new sorry introduced in any active-path file
- [ ] ROAD_MAP.md dead ends 27-29 present and strategy section updated (after Phase 1)

## Artifacts & Outputs

- `specs/ROAD_MAP.md` -- updated with Report 29 findings (Phase 1)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- 6 sorry sites closed (Phases 2-5)
- `specs/093_complete_bxcanonical_embedding/plans/29_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

1. **Full success (all 6 sorries closed via semantic forward_F)**: Target outcome. No rollback needed.

2. **Semantic forward_F succeeds but Until/Since coherence blocked (~20%)**: Keep forward_F/backward_P/restricted_tc proofs (reduces sorry count from 6 to 2). Spawn focused follow-up task for Until/Since coherence using quasimodel infrastructure.

3. **Semantic forward_F cannot wire into dd_fmcs interface (~25%)**: Switch to quasimodel bridge approach (Report 29, Component 2). Build Int-indexed FMCS families from sorry-free Quasimodel infrastructure. Estimated 600-1000 LOC, handles forward_F and Until coherence together.

4. **DRM-specific bounded_witness as intermediate fallback (~15%)**: If semantic approach is too invasive but dd_fmcs restructuring too complex, prove DRM-specific `single_step_forcing` + `bounded_witness` within deferralClosure. Adds ~150 LOC per Report 29 Component 3.

5. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` restores the current state. ROAD_MAP.md changes (Phase 1) are independently valuable and should be kept.
