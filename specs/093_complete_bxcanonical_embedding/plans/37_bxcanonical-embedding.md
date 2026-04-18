# Implementation Plan: Extended Seed Oracle + Hybrid BFMCS (v37)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [PARTIAL]
- **Effort**: 8 hours
- **Dependencies**: Task 92 (truth lemma sorry-free)
- **Research Inputs**: reports/37_team-research.md, reports/36_team-research.md
- **Artifacts**: plans/37_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan closes the 3 sorry sites reachable from `bx_completeness` (lines 1517, 1522, 1527 in RootScopedChain.lean), which are `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, and `dd_bfmcs_restricted_fuc`. The approach combines two strategies from round 37 research: (1) `self_resolving_fwd_step` chains for forward F-eventuality discharge (avoiding the BX11 perpetual deferral entirely), and (2) extended-seed oracle construction for Until/Since coherence via the already sorry-free `hintikka_chain_exists` quasimodel infrastructure. The plan constructs a new `qm_bfmcs` that replaces `dd_bfmcs` in `dd_countermodel`. Frame.lean and Completeness.lean are already sorry-free. Definition of done: `lake build` succeeds and `lean_verify bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

- **Report 37** (team, 4 teammates): Key breakthrough -- extended Lindenbaum seed `{psi} U g_content(w) U {active Until defects}` resolves the Until propagation blocker. Seed consistency follows from subset-of-MCS argument. Oracle always returns `Or.inl` (one-step discharge), yielding chains of length at most 2. `self_resolving_fwd_step` provides a separate, simpler path for forward F-eventuality.
- **Report 36** (team, 4 teammates): Confirmed quasimodel oracle feasibility. Identified SubformulaClosure temporal closure properties (now proved). Established that `dd_bfmcs` must be REPLACED not patched.

### Prior Plan Reference

Plan v36 used the same oracle + quasimodel architecture but underestimated the Until propagation difficulty. Phase 1 was partially completed (SubformulaClosure closure properties proved, ~155 LOC). Key lessons: (1) bare `bx_forward_witness` seed is insufficient -- need extended seed with Until defects; (2) `self_resolving_fwd_step` is a proven, simpler alternative for pure F-eventuality; (3) the `WitnessedHintikka` signature change is needed for the oracle. Effort recalibrated from 10h to 8h based on completed Phase 1 work and clearer architecture from round 37.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Construct `HintikkaStepOracle` using extended Lindenbaum seed (forward Until) and symmetric backward oracle (Since)
- Build `qm_bfmcs` backed by quasimodel chains from `hintikka_chain_exists`
- Prove full Until/Since coherence on `qm_bfmcs`
- Derive restricted temporal coherence via BX12 bridge
- Wire `qm_bfmcs` into `dd_countermodel`, closing all 3 reachable sorry sites
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- Closing the 5 dead-code sorry sites (lines 1413, 1457, 1464, 2196, 2289) -- unreachable from `bx_completeness`
- Modifying Construction.lean or HintikkaPoint.lean (already sorry-free)
- Dense completeness (separate task 68)
- Fixing the `defect_bwd_chain` non-resolving step design (dead code)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Extended seed consistency proof fails due to Until formula interactions | H | L (15%) | Consistency follows from all seed elements (except psi_target) being in w.formulas. Pattern matches existing `forward_temporal_witness_seed_consistent`. |
| `WitnessedHintikka` signature change breaks `hintikka_chain_exists` | M | L (10%) | The chain starts from and produces `WitnessedHintikka` -- signature change is additive, not breaking. |
| Int extension of finite quasimodel chain breaks g_content propagation | M | M (30%) | Fallback: use `self_resolving_fwd_step` chain (already proved) for forward direction, extending with reflexive last-point repetition. g_content(M) subset M holds for MCS by BX4/T. |
| Multiple Until defects require iterative chain composition | M | M (25%) | Each `hintikka_chain_exists` handles one target. Compose sequentially -- chain from defect 1 produces endpoint, use as start for defect 2. Finitely many defects (bounded by Sigma). |
| BX12 bridge: `(top U psi)` not in subformulaClosure for restricted coherence | M | L (20%) | Prove FULL (unrestricted) coherence first, then restricted versions follow as corollaries -- avoids closure membership entirely. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Extended Seed Oracle Construction [BLOCKED]

**Goal**: Build `HintikkaStepOracle` using the extended Lindenbaum seed that includes Until defects, and symmetric backward oracle for Since.

**Tasks**:
- [ ] Define `extended_oracle_seed`: `{psi_target} U g_content(w) U {active Until defects from w.formulas intersected with Sigma}`
- [ ] Prove `extended_oracle_seed_consistent`: All elements except `psi_target` are in `w.formulas`, so if the seed is inconsistent, derive contradiction with `w` being MCS (same pattern as `forward_temporal_witness_seed_consistent`)
- [ ] Build Lindenbaum extension `v'` from extended seed; prove `psi_target in v'`, `g_content(w) subset v'`, and all Until defects `(alpha_i U beta_i) in v'`
- [ ] Construct `h' = sigma_signature(v', Sigma)` from the Lindenbaum extension
- [ ] Verify `hintikka_step h h'`: G-propagation via `g_content(w) subset v'` + `SubformulaClosure_G_closed`; H-backward via `bx_H_forward` with `bx_le w v'`; Until propagation via extended seed membership
- [ ] Prove oracle always returns `Or.inl` (psi in h' directly, via BX8 `refl_intro_until_mcs`)
- [ ] Package as `bx_forward_oracle : HintikkaStepOracle Sigma phi psi` for all Until formulas in Sigma
- [ ] Build symmetric `bx_backward_oracle` using `bx_backward_witness` + extended seed with Since defects
- [ ] Verify: `lake build` succeeds, no sorry in new code

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- oracle construction

**Verification**:
- `bx_forward_oracle` and `bx_backward_oracle` compile without sorry
- `lake build` succeeds

---

### Phase 2: Quasimodel-Backed BFMCS Construction [NOT STARTED]

**Goal**: Build `qm_bfmcs : BFMCS Int` from quasimodel chains produced by `hintikka_chain_exists` with the oracle from Phase 1. This replaces the sorry-carrying `dd_bfmcs`.

**Tasks**:
- [ ] Define `qm_fwd_chain`: Given BXPoint `w0`, use `hintikka_chain_exists` with `bx_forward_oracle` to produce a finite chain resolving all Until defects. Compose chains sequentially for multiple defects (each invocation handles one target defect).
- [ ] Define `qm_bwd_chain`: Symmetric using `hintikka_chain_exists_since` with `bx_backward_oracle`
- [ ] Define `qm_to_int_fmcs`: Extend finite forward/backward chains to Int-indexed FMCS. Forward (t >= 0): walk forward chains, repeat last BXPoint beyond chain length. Backward (t < 0): walk backward chains, repeat last BXPoint.
- [ ] Prove `qm_fmcs_is_mcs`: each position is MCS (from backing BXPoint.is_mcs)
- [ ] Prove `qm_fmcs_g_content`: `g_content(mcs(t)) subset mcs(t+1)`. Within chain: from `bx_le` between consecutive points. Extension region: `g_content(M) subset M` from T axiom (BX4).
- [ ] Define `qm_bfmcs`: full BFMCS construction with modal families via `bx_modal_witness`
- [ ] Verify compilation

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add `qm_bfmcs` construction

**Verification**:
- `qm_bfmcs` definition compiles
- `qm_fmcs_is_mcs` and `qm_fmcs_g_content` compile without sorry
- `lake build` succeeds

---

### Phase 3: Until/Since Coherence on qm_bfmcs [NOT STARTED]

**Goal**: Prove full (unrestricted) Until/Since coherence on `qm_bfmcs`. The quasimodel chain structure gives this directly from `hintikka_chain_exists` properties.

**Tasks**:
- [ ] Prove forward Until coherence: `(phi U psi) in mcs(t)` implies witness `s >= t` with `psi in mcs(s)` and `phi` guarding `[t, s)`. Follows from quasimodel chain construction: the oracle chain starting at `t` resolves the defect within at most 2 steps (research finding 4).
- [ ] Prove forward Since coherence: `(phi S psi) in mcs(t)` implies past witness. Symmetric using backward oracle chain.
- [ ] Prove backward Until coherence: Given semantic witnesses (psi at s, phi guarding [t,s)), derive `(phi U psi) in mcs(t)`. By backward induction from `s` to `t`: at `s`, BX8 gives `(phi U psi) in mcs(s)`; at each step `r`, `(phi U psi) in mcs(r+1)` and `phi in mcs(r)` and `F(phi U psi) in mcs(r)` (from g_content chain) gives `(phi U psi) in mcs(r)` by BX8.
- [ ] Prove backward Since coherence: symmetric
- [ ] Derive restricted versions as corollaries (drop subformulaClosure check)

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- coherence proofs

**Verification**:
- Full Until/Since coherence theorems compile without sorry
- Restricted coherence corollaries compile
- `lake build` succeeds

---

### Phase 4: BX12 Bridge + Countermodel Rewiring [NOT STARTED]

**Goal**: Derive restricted temporal coherence via BX12 bridge, then wire `qm_bfmcs` into `dd_countermodel` to close the 3 sorry sites.

**Tasks**:
- [ ] Prove `qm_bfmcs_forward_F`: `F(psi) in mcs(t)` -> BX12 (`F_imp_top_until_mcs`) -> `(top U psi) in mcs(t)` -> full Until coherence -> witness `s > t` with `psi in mcs(s)`
- [ ] Prove `qm_bfmcs_backward_P`: symmetric using BX12' (`P_imp_top_since_mcs`)
- [ ] Prove `qm_bfmcs_restricted_tc`: restricted temporal coherence from forward_F and backward_P restricted to `deferralClosure root`
- [ ] Prove `qm_bfmcs_restricted_buc`: from full backward Until/Since coherence
- [ ] Prove `qm_bfmcs_restricted_fuc`: from full forward Until/Since coherence
- [ ] Replace `dd_bfmcs` with `qm_bfmcs` in `dd_countermodel`: change the 3 calls from `dd_bfmcs_restricted_tc/buc/fuc` to `qm_bfmcs_restricted_tc/buc/fuc`
- [ ] Verify `dd_countermodel` compiles without sorry
- [ ] Verify `bx_completeness` compiles without sorry
- [ ] Run `lean_verify` on `bx_completeness`

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- BX12 bridge, dd_countermodel rewiring

**Verification**:
- `dd_countermodel` compiles without sorry
- `bx_completeness` compiles without sorry
- `lean_verify` shows only `propext`, `Classical.choice`, `Quot.sound`
- `lake build` succeeds

---

### Phase 5: Cleanup and Dead Code Annotation [NOT STARTED]

**Goal**: Annotate dead code, add docstrings to new theorems, verify full build.

**Tasks**:
- [ ] Annotate the 5 dead-code sorry sites (1413, 1457, 1464, 2196, 2289) with comments explaining they are unreachable from `bx_completeness`
- [ ] Mark BX11-based `enriched_fwd_step` / `resolving_enriched_fwd_exists` as dead code (superseded by oracle approach)
- [ ] Add docstrings to all new theorems: oracle construction, qm_bfmcs, coherence proofs, BX12 bridge
- [ ] Run full `lake build`
- [ ] Run `lean_verify` on `bx_completeness` (final check)
- [ ] Grep for remaining sorry in BXCanonical files; verify none reachable from `bx_completeness`

**Timing**: 0.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- annotations, docstrings

**Verification**:
- `lake build` succeeds
- `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- No reachable sorry from `bx_completeness`

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_verify` on `bx_forward_oracle` after Phase 1 -- no sorry dependency
- [ ] `lean_verify` on `qm_bfmcs` after Phase 2 -- no sorry dependency
- [ ] `lean_verify` on full Until/Since coherence after Phase 3 -- no sorry dependency
- [ ] `lean_verify` on `dd_countermodel` after Phase 4 -- no sorry dependency
- [ ] `lean_verify` on `bx_completeness` after Phase 4 -- only `propext`, `Classical.choice`, `Quot.sound`
- [ ] All new theorems have docstrings after Phase 5

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/37_bxcanonical-embedding.md` -- this plan
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- oracle construction (Phase 1)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- qm_bfmcs, coherence, BX12 bridge, dd_countermodel rewiring (Phases 2-5)

## Rollback/Contingency

1. **Full success**: `bx_completeness` sorry-free. No rollback needed.

2. **Oracle construction blocked (~15%)**: If extended seed consistency proof is harder than expected, fall back to building oracle from `self_resolving_fwd_step` chain directly (already proved sorry-free). This gives forward F-eventuality but not Until coherence. Until coherence would need a separate approach (iterative Lindenbaum with explicit Until formula tracking).

3. **Int extension blocked (~30%)**: If finite-to-Int chain extension breaks g_content, use existing `dd_fmcs` Int-indexing infrastructure and only replace chain contents with quasimodel-derived BXPoints.

4. **Backward Until coherence blocked (~15%)**: Forward direction still succeeds. Close `qm_bfmcs_restricted_fuc` and `qm_bfmcs_restricted_tc` (via BX12). Spawn focused task for backward coherence.

5. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/` restores current state. All sorry-free infrastructure is preserved.
