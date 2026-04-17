# Implementation Plan: Quasimodel-Derived Chain for BXCanonical Completeness

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (task 102 completed; truth lemma sorry-free)
- **Research Inputs**: reports/30_team-research.md, reports/29_team-research.md, handoffs/02_enriched-chain-analysis.md, handoffs/01_forward-f-analysis.md
- **Artifacts**: plans/30_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

After 29 research rounds and 26 documented dead ends, all four Round 30 teammates converge on a single solution: replace the round-robin chain construction (`rr_fwd_chain` / `enriched_fwd_step`) with a quasimodel-derived chain where forward_F is built INTO the construction rather than proved ABOUT it. The existing sorry-free quasimodel infrastructure (1,816 lines across 6 files in `Quasimodel/`) builds finite Hintikka chains with targeted defect-discharge where each F-obligation is resolved within a bounded number of steps. This plan first archives the dead round-robin approach and updates ROAD_MAP.md, then builds a new `qm_chain` construction that embeds quasimodel defect-discharge chains into Int-indexed FMCS families. Definition of done: `lake build` succeeds with zero sorry in `RootScopedChain.lean`.

### Research Integration

- **Report 30** (team research, 4 teammates): All 4 converge on quasimodel-derived chain. Round-robin chain is permanently blocked by BX11 hijacking (perpetual deferral). Quasimodel step oracle holds target fixed until resolved, avoiding the hijacking. Literature consensus: Burgess 1982, GHR 1994, Goldblatt 1992, Verbrugge 2004 all build forward_F into the construction.
- **Handoff 02** (enriched chain analysis): Per-formula witness approaches blocked because `restricted_temporally_coherent` requires witnesses ON the chain (same family), but `bx_forward_witness` produces BXPoints outside the chain.
- **Report 29** (team research): DRM bounded_witness blocked; targeted seed consistent; per-formula resolution; BX11 hijacking confirmed.

### Prior Plan Reference

Plans v1-v29 (19 plan versions, 30 research rounds) explored: round-robin scheduling, enriched seeds, f_carry propagation, fuel-based recursion, BX11 acyclicity, DRM chains, per-formula witnesses, Goldblatt WF-induction. All failed because they attempt to PROVE forward_F about a chain rather than BUILD it in. Key calibration from v29: estimated 12 hours was too low for an approach that turned out to be blocked. Effort for the quasimodel bridge (estimated 500-800 LOC by Report 30) is better calibrated.

### Roadmap Alignment

- Advances: Close all 6 `RootScopedChain.lean` sorries (ROAD_MAP "Active-Path Sorry Inventory")
- Advances: Make `dd_countermodel` sorry-free, resolving `Completeness.lean:154`
- Unblocks: Task 95 (`#print axioms` audit on `bx_completeness`)
- Updates: ROAD_MAP.md dead ends, strategy section, sorry inventory

## Goals & Non-Goals

**Goals**:
- Archive dead round-robin chain code to `Boneyard/` and update ROAD_MAP.md
- Replace `rr_fwd_chain` with a quasimodel-derived chain construction (`qm_chain`)
- Close all 6 sorry sites in `RootScopedChain.lean`
- Achieve `lake build` with zero sorry in active BXCanonical path
- Forward_F is definitional (built into `qm_chain`), not a theorem about it

**Non-Goals**:
- Proving `rr_fwd_chain_forward_F` for the existing round-robin chain (confirmed blocked across 26 dead ends)
- Modifying the truth lemma or quasimodel infrastructure (sorry-free, proven correct)
- Dense completeness (independent task 68)
- Game-theoretic approach (3000+ LOC, not justified)
- The BX11 closure + G(F(psi)) case split (novel but only 40% viable per Report 30; quasimodel bridge is more robust)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Quasimodel produces finite Hintikka chains but FMCS requires Int-indexed infinite chain | H | M (35%) | Extend finite quasimodel chain to infinite by repeating `fwd_succ` with non-resolving steps beyond the defect-discharge region. g_content propagation is sorry-free. |
| Hintikka points are sigma-restricted, not full MCS; Lindenbaum extension may not preserve all formulas | H | M (30%) | The quasimodel's `HintikkaPoint` is maximal within sigma-closure. Lindenbaum extension to full MCS preserves all sigma-closure formulas (superset property). |
| Backward chain (t < 0) needs symmetric quasimodel construction | M | L (25%) | `bx_backward_witness` and `bwd_pred` are sorry-free. The backward direction uses H-content and `bx_backward_witness`, which is symmetric to the forward case. |
| Until/Since coherence (`restricted_fuc`/`restricted_buc`) may need additional machinery beyond forward_F | M | M (30%) | By BX10, `(phi U psi) -> F(psi)`. Once forward_F is structural, Until coherence follows from BX10 + the quasimodel's Until-specific defect discharge (already in Construction.lean). |
| `DRMChain.lean` (286 lines, 1 sorry) interacts with the chain construction | L | L (15%) | DRMChain.lean is independent dead code from a rejected approach. Archive to Boneyard with the round-robin code. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel (though this plan is fully sequential due to mathematical dependencies).

---

### Phase 1: Archive Dead Approaches and Update ROAD_MAP.md [NOT STARTED]

**Goal**: Clean house before building the new solution. Archive the round-robin chain code and all dead-end attempt artifacts to Boneyard. Update ROAD_MAP.md with dead ends 27-30 and the new quasimodel-derived chain strategy.

**Tasks**:
- [ ] Create `Boneyard/RoundRobinChain/` directory
- [ ] Move `DRMChain.lean` to `Boneyard/RoundRobinChain/` (286 lines, 1 sorry, dead code)
- [ ] Extract the round-robin chain construction from `RootScopedChain.lean` (the `enriched_fwd_step`, `rr_fwd_chain`, `rr_bwd_chain`, `dd_chain`, and all helper theorems that are ONLY used by the round-robin approach) into a new Boneyard file. Keep the FMCS/BFMCS/countermodel definitions and the sorry sites in place.
- [ ] Verify `lake build` still succeeds after archival (the sorry sites remain but their supporting dead code is removed or moved)
- [ ] Add dead ends 27-30 to ROAD_MAP.md "Dead Ends (Archived)" section:
  - (27) DRM bounded_witness via single_step_forcing: negation completeness gap
  - (28) Full MCS bounded_witness: F-reflexivity blocks exit condition
  - (29) DRM chain preventing perpetual deferral: relocates non-determinism
  - (30) Per-formula witness wired into same-family membership: `restricted_temporally_coherent` requires witnesses ON the chain, but `bx_forward_witness` gives BXPoints outside
- [ ] Update ROAD_MAP.md "Current Strategy" to describe quasimodel-derived chain approach
- [ ] Update ROAD_MAP.md task 93 entry to reference plan v30
- [ ] Update ROAD_MAP.md "last updated" timestamp

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- remove dead round-robin helper code (keep FMCS/BFMCS structure)
- `Theories/Bimodal/Metalogic/BXCanonical/DRMChain.lean` -- move to Boneyard
- `Theories/Bimodal/Boneyard/RoundRobinChain/` -- new directory for archived code
- `specs/ROAD_MAP.md` -- dead ends, strategy, timestamp

**Verification**:
- `lake build` succeeds
- `DRMChain.lean` no longer in active path
- Dead ends 27-30 present in ROAD_MAP.md
- Strategy section references quasimodel-derived chain

---

### Phase 2: Build Quasimodel-Derived Forward Chain [NOT STARTED]

**Goal**: Replace `rr_fwd_chain` with a new `qm_fwd_chain` that embeds the quasimodel's defect-discharge mechanism into the Nat-indexed forward chain. Forward_F is definitional: the chain resolves every F-obligation within a bounded number of steps because the quasimodel's `defect_count` strictly decreases.

**Tasks**:
- [ ] Study the quasimodel infrastructure to identify the key extraction points:
  - `Construction.lean`: `QuasimodelChain`, `hintikka_step`, `defect_count`, `UntilDefect`
  - `Realization.lean`: `until_eventuality_resolution`, `until_forward_seed`
  - `Filtration/DefectChain.lean`: `sigma_defect_count`, `defect_step_phi`
- [ ] Define `qm_fwd_chain`: given root MCS M0 and sigma_list, build the forward chain by:
  1. At each position n, compute the set of unresolved F-obligations in `deferralClosure(root)` present at chain(n)
  2. If there are unresolved obligations, pick one and use `fwd_succ` (sorry-free) with targeted seed to resolve it. This mimics the quasimodel's defect-discharge: each step resolves one defect, and `defect_count` strictly decreases.
  3. If no unresolved obligations, extend using `fwd_succ` with any target (non-resolving step).
  4. The chain terminates its defect-discharge phase within `|deferralClosure(root)|` steps (bounded by number of formulas in closure).
- [ ] Prove `qm_fwd_chain_forward_F`: If `F(psi) in qm_fwd_chain(n)` and `psi in deferralClosure(root)`, then there exists `s > n` with `psi in qm_fwd_chain(s)`. This follows directly from the construction: the defect-discharge loop targets every unresolved F-obligation.
- [ ] Prove `qm_fwd_chain_g_content`: `g_content(chain(n)) subset chain(n+1)` -- follows from `fwd_succ_g_content` (sorry-free).
- [ ] Prove `qm_fwd_chain_mcs`: each element is MCS -- follows from `fwd_succ_mcs` (sorry-free).
- [ ] Prove `qm_fwd_chain_box_stable`: box formulas stable across the chain -- follows from `fwd_succ_box_stable` or existing `modal_fix` infrastructure.
- [ ] Build symmetric `qm_bwd_chain` using `bwd_pred` (sorry-free) with targeted defect-discharge for P-obligations.
- [ ] Assemble `qm_dd_chain : Int -> Set Formula` from `qm_fwd_chain` (t >= 0) and `qm_bwd_chain` (t < 0).
- [ ] Run `lake build` to verify the new chain construction compiles.

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add `qm_fwd_chain`, `qm_bwd_chain`, `qm_dd_chain` and their properties

**Verification**:
- `qm_fwd_chain_forward_F` compiles without sorry
- `qm_fwd_chain_g_content`, `qm_fwd_chain_mcs`, `qm_fwd_chain_box_stable` compile without sorry
- `lake build` succeeds

---

### Phase 3: Wire Quasimodel Chain into FMCS/BFMCS and Close Temporal Coherence [NOT STARTED]

**Goal**: Replace `dd_fmcs` / `dd_bfmcs` to use `qm_dd_chain` and close sorry sites 1-4 (`rr_fwd_chain_forward_F`, `dd_fmcs_forward_F`, `dd_fmcs_backward_P`, `dd_bfmcs_restricted_tc`).

**Tasks**:
- [ ] Redefine `dd_fmcs` to use `qm_dd_chain` instead of the round-robin `dd_chain`. Keep the same signature (`FMCS Int`).
- [ ] Reprove `dd_fmcs` properties (`dd_fmcs_mcs`, `dd_chain_g_content`, `dd_chain_h_content`, etc.) using the new chain. These should follow directly from the `qm_fwd_chain` / `qm_bwd_chain` properties.
- [ ] Close sorry site 1 (`rr_fwd_chain_forward_F` or its replacement): This is now trivial -- `qm_fwd_chain_forward_F` IS the proof. Wire it through.
- [ ] Close sorry site 2 (`dd_fmcs_forward_F` for t < 0): For `F(psi) in dd_chain(t)` with t < 0, the backward chain element at t has `F(psi)`. Since `g_content` propagates forward from the backward chain through M0 to the forward chain, and `F(psi)` either persists via g_content or is resolved by the forward chain's defect-discharge.
- [ ] Close sorry site 3 (`dd_fmcs_backward_P`): Symmetric to forward_F using `qm_bwd_chain` and `bx_backward_witness` infrastructure.
- [ ] Close sorry site 4 (`dd_bfmcs_restricted_tc`): For each family `fam in dd_bfmcs.families` (which is `shifted_dd_fmcs N h_N sigma_list s` for some box-equivalent N), the temporal coherence follows from `qm_fwd_chain_forward_F` applied to each family's chain. Each family uses the same `qm_dd_chain` construction (just with a different root N and shift s), so `forward_F` is structural in every family.
- [ ] Run `lake build` and verify sorry count is reduced to 2 (sites 5-6 remain).

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- redefine `dd_fmcs`, close sorry sites 1-4

**Verification**:
- Sorry sites at original lines 3644, 3688, 3695, 3748 are closed
- `lake build` succeeds
- `grep -n sorry RootScopedChain.lean` shows at most 2 remaining (sites 5-6)

---

### Phase 4: Close Until/Since Coherence and Final Verification [NOT STARTED]

**Goal**: Close sorry sites 5-6 (`dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc`) and perform final verification. Once done, `bx_completeness` is sorry-free.

**Tasks**:
- [ ] Close sorry site 6 (`dd_bfmcs_restricted_fuc`, forward Until/Since coherence):
  - **Forward Until** `(phi U psi)`: Given `(phi U psi) in fam.mcs(t)`:
    1. By BX10 (`until_F`): `F(psi) in fam.mcs(t)`
    2. By `dd_bfmcs_restricted_tc` (now proved): `exists s > t, psi in fam.mcs(s)` (since `psi in deferralClosure(root)`)
    3. Guard propagation: BX5 (`self_accum_until`) gives `(phi AND (phi U psi)) U psi in fam.mcs(t)`, so `phi U psi` persists at intermediate points via g_content, and BX9 (`until_elim`) gives `phi OR psi` at each point.
    4. The minimum witness argument: take the s from forward_F. At each r in [t,s), `phi U psi in fam.mcs(r)` (from g_content propagation of the enriched formula), and `psi not in fam.mcs(r)` (otherwise s is not minimal), so by BX9: `phi in fam.mcs(r)`.
  - **Forward Since** `(phi S psi)`: Symmetric using backward_P
- [ ] Close sorry site 5 (`dd_bfmcs_restricted_buc`, backward Until/Since coherence):
  - This is the converse direction: given semantic witnesses (psi at s, phi on guard), derive `(phi U psi) in fam.mcs(t)`.
  - Use BX8 (`refl_intro_until`): `psi -> (phi U psi)` gives `(phi U psi) in fam.mcs(s)`.
  - Then propagate backward from s to t using the chain's g_content and `G(phi U psi)` if available.
  - Alternative: use the restricted parametric truth lemma to convert semantic truth to MCS membership directly.
  - If circular dependency detected (truth lemma needs backward coherence to prove backward coherence), restructure to prove backward Until independently using BX axioms at the chain level.
- [ ] Run `grep -n sorry RootScopedChain.lean` to verify zero executable sorry
- [ ] Run `lake build` to verify compilation
- [ ] Use `lean_verify` on `bx_completeness` to confirm axioms are exactly `{propext, Classical.choice, Quot.sound}`
- [ ] Update ROAD_MAP.md sorry inventory to show 0 active-path sorries
- [ ] Verify no new sorry introduced in any active-path file

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry sites 5-6
- `specs/ROAD_MAP.md` -- update sorry inventory to 0

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `grep -n sorry RootScopedChain.lean` returns only comment-embedded occurrences
- `lake build` succeeds
- `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `grep -n sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero executable sorry (after Phase 4)
- [ ] `lean_verify` on `dd_countermodel` shows no sorry-dependent axioms
- [ ] `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No new sorry introduced in any active-path file
- [ ] ROAD_MAP.md dead ends 27-30 present and strategy section updated (after Phase 1)
- [ ] ROAD_MAP.md sorry inventory shows 0 active-path sorries (after Phase 4)
- [ ] `DRMChain.lean` and round-robin dead code archived to Boneyard (after Phase 1)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- 6 sorry sites closed, new quasimodel-derived chain
- `Theories/Bimodal/Boneyard/RoundRobinChain/` -- archived dead code
- `specs/ROAD_MAP.md` -- updated dead ends, strategy, sorry inventory
- `specs/093_complete_bxcanonical_embedding/plans/30_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

1. **Full success (all 6 sorries closed via quasimodel-derived chain)**: Target outcome. No rollback needed.

2. **Quasimodel chain works for forward_F/backward_P but Until/Since coherence blocked (~20%)**: Keep temporal coherence proofs (reduces sorry count from 6 to 2). Spawn focused follow-up task for Until/Since using the restricted truth lemma approach.

3. **Finite-to-infinite extension blocked (~25%)**: If extending the quasimodel's finite defect-discharge chain to an infinite Int-indexed chain proves harder than expected, consider using the quasimodel chain for the finite prefix and `fwd_succ` with non-resolving steps for the infinite tail. The key property (every F-obligation resolved within bounded steps) only needs the finite prefix.

4. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` restores the current state. Boneyard archival (Phase 1) and ROAD_MAP.md updates are independently valuable and should be kept.
