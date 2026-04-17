# Implementation Plan: Close BXCanonical Embedding (v29r1 -- Per-Formula FMCS via bx_forward_witness)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (task 102 completed; truth lemma sorry-free)
- **Research Inputs**: reports/29_team-research.md, reports/28_depth-zero-base-case.md, reports/27_team-research.md, handoffs/01_forward-f-analysis.md
- **Artifacts**: plans/29_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Six sorry sites in `RootScopedChain.lean` (lines 3644, 3688, 3695, 3748, 3753, 3758) block `bx_completeness`. Plan v29 (semantic forward_F via targeted seed) assumed `bx_forward_witness` could be wired into the existing `rr_fwd_chain` architecture. Handoff 01 found this approach blocked: (1) BX11 hijacking in `enriched_fwd_fold_with_witness` means `rr_fwd_chain_forward_F` is mathematically unprovable for the existing chain; (2) extended seed `{target, F(psi)} union g_content(M)` can be inconsistent; (3) `F(psi) -> G(F(psi))` is not a theorem so F-obligations cannot propagate via g_content. This revised plan abandons proving `rr_fwd_chain_forward_F` and instead restructures `dd_bfmcs` to use per-formula witnesses from `bx_forward_witness`/`bx_backward_witness` directly, bypassing the chain entirely for temporal coherence. Definition of done: `lake build` succeeds with zero sorry in `RootScopedChain.lean`.

### Research Integration

- **Report 29** (team research, 4 teammates): DRM bounded_witness blocked, targeted seed consistent, literature consensus for per-formula resolution, sorry 6 has Until persistence obstacle.
- **Report 28** (depth-0 base case): Paths A/C/F blocked, Path D (DRM) recommended but superseded.
- **Report 27** (team research): Goldblatt WF-induction convergence, DRM refinement now known blocked.
- **Handoff 01** (forward_F analysis): Confirmed BX11 hijacking blocks `rr_fwd_chain_forward_F`. Identified 3 alternative approaches. Approach A (per-formula FMCS) recommended. All 6 sorries depend on sorry 1.

### Prior Plan Reference

Plan v29 (14 hours, 5 phases) assumed targeted seed + semantic forward_F could be wired into the chain. Phase 1 (ROAD_MAP update) was marked BLOCKED pending architecture decision. Handoff 01 confirmed the chain approach is mathematically blocked: BX11 fold may resolve a different formula at each step (hijacking), making `rr_fwd_chain_forward_F` unprovable. This revision restructures the approach entirely: instead of proving forward_F for the chain, prove it directly using `bx_forward_witness` and restructure the sorry sites to accept per-formula existential witnesses.

### Roadmap Alignment

- Closes `rr_fwd_chain_forward_F` (PRIMARY BLOCKER, ROAD_MAP sorry inventory) -- by replacing the approach
- Makes `dd_countermodel` sorry-free, resolving `Completeness.lean:154`
- Unblocks task 95 (`#print axioms` audit on `bx_completeness`)
- Eliminates all 6 active-path sorries in the BXCanonical module

## Goals & Non-Goals

**Goals**:
- Close all 6 sorry sites in `RootScopedChain.lean` using per-formula BXPoint witnesses
- Restructure `dd_bfmcs_restricted_tc` to use `bx_forward_witness`/`bx_backward_witness` directly
- Close `dd_bfmcs_restricted_fuc` and `dd_bfmcs_restricted_buc` (Until/Since coherence)
- Achieve `lake build` with zero sorry in active BXCanonical path
- Update ROAD_MAP.md with dead ends 27-30 and new strategy

**Non-Goals**:
- Proving `rr_fwd_chain_forward_F` for the existing chain (confirmed blocked)
- Modifying the truth lemma or quasimodel infrastructure (sorry-free, proven correct)
- Dense completeness (independent task 68)
- Cleaning up Boneyard code (separate effort)
- Game-theoretic approach (3000+ new LOC, not justified)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `restricted_temporally_coherent` requires witnesses ON the chain (not arbitrary BXPoints) | H | M (35%) | Read the truth lemma to verify it only needs `exists s, t < s AND psi in fam.mcs(s)` -- if `fam.mcs` is restructured to include per-formula witnesses, this is satisfied. Alternative: prove the coherence properties hold for any `shifted_dd_fmcs` family by showing `bx_forward_witness` output relates to the family's MCS at some time index. |
| Wiring `bx_forward_witness` output into `dd_fmcs.mcs(s)` requires showing the witness equals some chain element | H | M (40%) | Key insight: `dd_bfmcs_restricted_tc` quantifies over `fam in B.families`. Each `fam` is a `shifted_dd_fmcs N h_N sigma_list s`. The witness from `bx_forward_witness` for `F(psi) in fam.mcs(t)` gives a BXPoint `v` with `psi in v` and `g_content(fam.mcs(t)) subset v`. We need `v = fam.mcs(s)` for some `s > t`. This may require constructing a NEW family containing `v` and proving it is in `dd_bfmcs.families`. |
| Until/Since coherence requires a witness at a specific chain position, not just existence of a BXPoint | M | M (35%) | Forward Until needs `psi in fam.mcs(s)` for `s >= t` with guard `phi in fam.mcs(r)` for `r in [t,s)`. The guard propagation uses g_content and the chain structure. May need to construct a specialized family or use the restricted truth lemma to convert. |
| Sorry sites 2-3 (t < 0 forward_F, backward_P) need symmetric constructions | M | L (20%) | `bx_backward_witness` is sorry-free and symmetric. The backward case follows the same pattern. |
| Quasimodel bridge fallback more complex than estimated | M | M (30%) | Budget 600-1000 LOC per Report 29. The sorry-free quasimodel infrastructure is mature (1,816 lines). Only execute if per-formula witness approach fails at Phase 2. |

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

### Phase 1: Architecture Spike -- Verify Per-Formula Witness Approach [BLOCKED]

**Goal**: Determine the exact interface needed to close `dd_bfmcs_restricted_tc` and whether `bx_forward_witness` output can satisfy it. This is the critical go/no-go decision point for the approach.

**Tasks**:
- [ ] Read the `RestrictedParametricTruthLemma` (lines 270-487) to trace exactly which coherence properties it invokes and what types are required
- [ ] Read the `restricted_temporally_coherent` definition (TemporalCoherence.lean:295-300): confirm it requires `exists s : D, t < s AND psi in fam.mcs s` where `fam : FMCS Int`
- [ ] Examine `dd_bfmcs.families` membership: each family is `shifted_dd_fmcs N h_N sigma_list s` where `N` is box-equivalent to `M0`. The family `fam.mcs(t) = dd_chain N h_N sigma_list (t - s)`
- [ ] Determine approach for connecting `bx_forward_witness` output to family membership:
  - **Option 1 (Direct)**: Given `F(psi) in fam.mcs(t)`, apply `bx_forward_witness` to the BXPoint `(fam.mcs(t), fam.is_mcs(t))` to get BXPoint `v` with `psi in v` and `bx_le (fam.mcs(t)) v`. Then show `v` must appear somewhere on the forward chain of `N` at some index `s > t`. This requires showing the chain visits `v` or a superset.
  - **Option 2 (Family construction)**: Construct a NEW `shifted_dd_fmcs` family rooted at `v` that is in `dd_bfmcs.families`. Since `v` has the same box content as `M0` (because `bx_le` preserves g_content which includes box formulas), `v` qualifies as a root for a new family. Then `psi in v = new_fam.mcs(0)`.
  - **Option 3 (Restructure dd_fmcs)**: Replace `dd_fmcs` with a demand-driven chain that incorporates per-formula witnesses at construction time.
- [ ] Write a brief analysis comment in `RootScopedChain.lean` documenting the chosen approach
- [ ] If all options fail, document why and prepare for quasimodel bridge fallback (Phase 5)

**Timing**: 2 hours

**Depends on**: none

**Files to read**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` (270-487)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` (295-300, 535-544, 565-574)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (164-186)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (3697-3758)

**Verification**:
- Chosen approach documented with clear rationale
- If Option 2 (family construction): verify box-equivalence holds for `bx_forward_witness` output
- Go/no-go decision made for Phases 2-4 vs fallback Phase 5

---

### Phase 2: Close Forward_F and Backward_P (Sorry Sites 1-3) [NOT STARTED]

**Goal**: Close sorry sites 1 (line 3644), 2 (line 3688), and 3 (line 3695) using the approach determined in Phase 1. These are the forward_F base case, forward_F for t < 0, and backward_P respectively.

**Tasks**:
- [ ] **Sorry site 1** (`rr_fwd_chain_forward_F` depth-0 base case, line 3644): This is the core blocker. Rather than proving the chain resolves every F-obligation, restructure the proof:
  - If Option 1 (direct): Show `bx_forward_witness` applied to chain element `rr_fwd_chain(n)` produces a BXPoint that must appear on the chain at some later index (requires showing the chain is "complete" in visiting all accessible successors -- likely blocked by same issue)
  - If Option 2 (family construction): Defer this sorry to Phase 3 by restructuring `dd_bfmcs_restricted_tc` to not depend on `rr_fwd_chain_forward_F` at all. Instead prove restricted_tc directly using `bx_forward_witness` at the BFMCS level.
  - If Option 3: Implement the demand-driven chain
- [ ] **Sorry site 2** (`dd_fmcs_forward_F` t < 0 case, line 3688): Given `F(psi) in dd_chain(t)` for `t < 0` (backward chain):
  - The backward chain propagates h_content, not F-obligations
  - Apply `bx_forward_witness` directly to `dd_chain(t)` as a BXPoint
  - Wire the resulting BXPoint into the proof
- [ ] **Sorry site 3** (`dd_fmcs_backward_P`, line 3695): Symmetric to forward_F using `bx_backward_witness`:
  - Given `P(psi) in dd_fmcs.mcs(t)`, apply `bx_backward_witness` to get BXPoint `v` with `psi in v` and `bx_le v (dd_fmcs.mcs(t))`
  - Wire into the proof
- [ ] If Option 2 is chosen: sorry sites 1-3 may be bypassed entirely if `dd_fmcs_forward_F` and `dd_fmcs_backward_P` are no longer needed (their consumers are `dd_bfmcs_restricted_tc` which would be proved directly). In that case, mark these theorems as obsolete or prove them as corollaries.
- [ ] Run `lake build` and check sorry count

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close or bypass sorry sites 1-3

**Verification**:
- Sorry sites at lines 3644, 3688, 3695 are closed (or the theorems are no longer needed)
- `lake build` succeeds
- If theorems bypassed: verify `dd_bfmcs_restricted_tc` no longer calls them

---

### Phase 3: Close Restricted Temporal Coherence (Sorry Site 4) [NOT STARTED]

**Goal**: Close `dd_bfmcs_restricted_tc` (line 3748). This is the central sorry: it needs forward_F and backward_P for every family in `dd_bfmcs`.

**Tasks**:
- [ ] Prove `dd_bfmcs_restricted_tc` using per-formula witnesses:
  - The definition requires: for every `fam in dd_bfmcs.families`, for every `t : Int`, for every `phi in deferralClosure(root)`:
    - If `F(phi) in fam.mcs(t)`, then `exists s > t, phi in fam.mcs(s)`
    - If `P(phi) in fam.mcs(t)`, then `exists s < t, phi in fam.mcs(s)`
  - Each family `fam = shifted_dd_fmcs N h_N sigma_list shift` where `N` is box-equivalent to `M0`
  - For forward_F: `F(phi) in fam.mcs(t) = dd_chain N h_N sigma_list (t - shift)`
    - Apply `bx_forward_witness` to the BXPoint `(dd_chain N h_N sigma_list (t - shift), dd_chain_is_mcs ...)` and `phi`
    - Get BXPoint `v` with `phi in v` and `g_content(dd_chain(t-shift)) subset v`
    - **Key step**: Show `v.formulas` appears as `fam.mcs(s)` for some `s > t`. This is where the approach must be determined in Phase 1.
    - If Option 2: construct `shifted_dd_fmcs v.formulas v.is_mcs sigma_list t` as a new family, show it is in `dd_bfmcs.families` (requires box-equivalence), then `phi in new_fam.mcs(t)`. But we need `phi in fam.mcs(s)` for the SAME family `fam`, not a different one.
  - **Alternative approach for the SAME family**: Since `fam.mcs(t+1) = dd_chain N h_N sigma_list (t+1-shift)` and `dd_chain` at positive index uses `rr_fwd_chain`, and `g_content(fam.mcs(t)) subset fam.mcs(t+1)` by construction, the g_content propagation is there. The issue is getting `phi` specifically into some `fam.mcs(s)`. If `G(phi) in fam.mcs(t)` then `phi in fam.mcs(s)` for all `s > t`. But we only have `F(phi)`, not `G(phi)`.
  - **Possible restructuring**: Modify `dd_chain` construction to be demand-driven: when building `dd_chain(n+1)` from `dd_chain(n)`, if there exists `phi in deferralClosure(root)` with `F(phi) in dd_chain(n)` that is not yet resolved, use targeted seed `{phi} union g_content(dd_chain(n))` instead of `enriched_fwd_step`. This makes the chain resolve every F-obligation within `deferralClosure(root)`.
- [ ] If demand-driven restructuring is needed, implement `targeted_fwd_step` as a replacement for `enriched_fwd_step` within `deferralClosure(root)` scope
- [ ] For backward_P: symmetric construction using `bx_backward_witness` and targeted backward seed
- [ ] Run `lake build`

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry site 4, potentially add `targeted_fwd_step`

**Verification**:
- Sorry site at line 3748 is closed
- `lake build` succeeds
- `grep -n sorry RootScopedChain.lean` shows at most 2 remaining (sites 5-6)

---

### Phase 4: Close Until/Since Coherence (Sorry Sites 5-6) [NOT STARTED]

**Goal**: Close `dd_bfmcs_restricted_buc` (line 3753) and `dd_bfmcs_restricted_fuc` (line 3758), achieving zero sorry in `RootScopedChain.lean`.

**Tasks**:
- [ ] Close sorry site 6: `dd_bfmcs_restricted_fuc` (forward Until/Since coherence, line 3758)
  - **Forward Until** `(phi U psi)`: Given `(phi U psi) in fam.mcs(t)`, need `exists s >= t, psi in fam.mcs(s) AND forall r in [t,s), phi in fam.mcs(r)`:
    1. By BX10 (`until_F`): `(phi U psi) -> F(psi)`, so `F(psi) in fam.mcs(t)`
    2. By `dd_bfmcs_restricted_tc` (now proved): exists `s > t` with `psi in fam.mcs(s)` (provided `psi in deferralClosure(root)`, which holds since `(phi U psi) in subformulaClosure(root)` implies `psi in subformulaClosure(root) subset deferralClosure(root)`)
    3. Guard propagation for `phi in fam.mcs(r)` for `r in [t, s)`:
       - By BX7 (`induction_until`): `(phi U psi) -> (psi OR (phi AND G(phi U psi)))`
       - If `psi in fam.mcs(t)`, take `s = t` (done)
       - Otherwise `phi AND G(phi U psi) in fam.mcs(t)`, so `G(phi U psi) in fam.mcs(t)`
       - By g_content propagation: `(phi U psi) in g_content(fam.mcs(t)) subset fam.mcs(r)` for all `r > t`
       - At each `r in [t, s)`: `(phi U psi) in fam.mcs(r)`. Apply BX7 again: either `psi in fam.mcs(r)` (contradicts minimality of `s` if `r < s`) or `phi in fam.mcs(r)` (the guard we need)
    4. Find the MINIMUM `s >= t` with `psi in fam.mcs(s)` -- may require well-ordering argument or direct construction
    5. Note: step 4 may be unnecessary if we take the `s` from forward_F and prove the guard holds for `[t, s)` without minimality
  - **Forward Since** `(phi S psi)`: Given `(phi S psi) in fam.mcs(t)`, need `exists s <= t, psi in fam.mcs(s) AND forall r in (s,t], phi in fam.mcs(r)`. Symmetric using backward_P and H-content.

- [ ] Close sorry site 5: `dd_bfmcs_restricted_buc` (backward Until/Since coherence, line 3753)
  - **Backward Until**: Given semantic witness (psi at s, phi on guard for r in [t,s)), derive `(phi U psi) in fam.mcs(t)`:
    1. Use the restricted parametric truth lemma to convert between semantic truth and MCS membership
    2. The truth lemma for Until at `fam.mcs(t)` says: `(phi U psi) in fam.mcs(t)` iff `truth_at ... t (phi U psi)` iff `exists s >= t, psi at s AND phi on [t,s)`
    3. The semantic witness IS the right-hand side, so `(phi U psi) in fam.mcs(t)` follows
    4. Note: this requires the truth lemma to be applicable, which needs all coherence properties including the forward ones (circular?). Investigate whether the backward direction can be proved independently.
  - **Alternative for backward Until**: Direct syntactic proof using BX axioms:
    1. At time `s`: `psi in fam.mcs(s)`, so by BX8 (`refl_intro_until`): `(phi U psi) in fam.mcs(s)`
    2. At time `s-1`: `phi in fam.mcs(s-1)` (guard) and `(phi U psi) in fam.mcs(s)` (from step 1). Need `(phi U psi) in fam.mcs(s-1)`.
    3. Since `G(phi U psi) in fam.mcs(s-1)` iff `(phi U psi) in g_content(fam.mcs(s-1)) subset fam.mcs(s)` -- this is backwards. We need `(phi U psi)` to propagate BACKWARD, but g_content goes forward.
    4. Use BX12 (`F_until_equiv`): `F(psi) -> (top U psi)`. At `s-1`, `F(psi) in fam.mcs(s-1)` (since `psi in fam.mcs(s)` and `s > s-1`). So `(top U psi) in fam.mcs(s-1)`. Need to strengthen `top` to `phi` -- requires BX2 left monotonicity with `G(phi)`, which does not hold in general.
    5. This direction likely requires the restricted truth lemma. Wire through `RestrictedParametricTruthLemma`.
  - **Backward Since**: Symmetric.

- [ ] If backward Until coherence requires the truth lemma, ensure no circular dependency: the truth lemma needs forward coherence (proved in Phase 3) and backward coherence (being proved here). Check whether the truth lemma's Until case depends on backward Until coherence or only on forward Until coherence.

- [ ] Run `grep -n sorry RootScopedChain.lean` to verify zero executable sorry
- [ ] Run `lake build` to verify compilation

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry sites 5-6

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `grep -n sorry RootScopedChain.lean` returns only comment-embedded occurrences (no executable sorry)
- `lake build` succeeds

---

### Phase 5: ROAD_MAP Update and Final Verification [NOT STARTED]

**Goal**: Update `specs/ROAD_MAP.md` with findings from Handoff 01 and Reports 27-29, and perform final verification of zero sorry.

**Tasks**:
- [ ] Add dead ends 27-30 to the "Dead Ends (Archived)" section:
  - (27) DRM bounded_witness via single_step_forcing: negation completeness gap (Report 29, Findings 1, 11)
  - (28) Full MCS bounded_witness: F-reflexivity blocks exit condition (Report 29, Finding 2)
  - (29) DRM chain preventing perpetual deferral: relocates non-determinism (Report 29, Finding 3)
  - (30) Semantic forward_F wired into existing chain: BX11 hijacking blocks `rr_fwd_chain_forward_F`; extended seed inconsistency; `F(psi) -> G(F(psi))` not a theorem (Handoff 01, Findings 1-3)
- [ ] Update the "Current Strategy" subsection to describe per-formula witness approach
- [ ] Update sorry line numbers in the "Active-Path Sorry Inventory" table if they have changed
- [ ] Update the "Task 93: Progress and Infrastructure" subsection
- [ ] Update the "last updated" timestamp
- [ ] Run final verification:
  - `lake build` succeeds
  - `grep -n sorry RootScopedChain.lean` shows zero executable sorry
  - `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Verify no new sorry introduced in any active-path file

**Timing**: 1 hour (reduced from v29's 1.5 hours since ROAD_MAP update is lower risk after implementation)

**Depends on**: 4

**Files to modify**:
- `specs/ROAD_MAP.md` -- dead ends, strategy section, sorry line numbers, progress notes

**Verification**:
- Dead ends 27-30 appear in the Dead Ends section
- Strategy section references "per-formula witness" approach
- All executable sorry eliminated from `RootScopedChain.lean`
- `lake build` succeeds
- `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `grep -n sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero executable sorry (after Phase 4)
- [ ] `lean_verify` on `dd_countermodel` shows no sorry-dependent axioms
- [ ] `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No new sorry introduced in any active-path file
- [ ] ROAD_MAP.md dead ends 27-30 present and strategy section updated (after Phase 5)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- 6 sorry sites closed (Phases 2-4)
- `specs/ROAD_MAP.md` -- updated with Handoff 01 and Report 29 findings (Phase 5)
- `specs/093_complete_bxcanonical_embedding/plans/29_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

1. **Full success (all 6 sorries closed via per-formula witnesses)**: Target outcome. No rollback needed.

2. **Per-formula witnesses work for forward_F/backward_P but Until/Since coherence blocked (~25%)**: Keep temporal coherence proofs (reduces sorry count from 6 to 2). Spawn focused follow-up task for Until/Since using quasimodel infrastructure or restricted truth lemma approach.

3. **Per-formula witnesses cannot be wired into same-family membership (~30%)**: Switch to quasimodel bridge approach (Report 29, Component 2). Build Int-indexed FMCS families from sorry-free Quasimodel infrastructure. Estimated 600-1000 LOC, handles forward_F and Until coherence together.

4. **Demand-driven chain restructuring too invasive (~20%)**: If replacing `enriched_fwd_step` with `targeted_fwd_step` within deferralClosure scope creates cascading type changes, consider a lighter wrapper that proves the coherence properties post-hoc using `bx_forward_witness` at the BFMCS level without modifying the chain.

5. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` restores the current state. ROAD_MAP.md changes (Phase 5) are independently valuable and should be kept.
