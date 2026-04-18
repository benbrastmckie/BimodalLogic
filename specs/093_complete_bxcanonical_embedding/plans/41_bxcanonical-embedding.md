# Implementation Plan: DD-BFMCS Scheduling Chain Coherence

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: Task 92 (truth lemma sorry-free) -- satisfied
- **Research Inputs**: reports/41_team-research.md
- **Artifacts**: plans/41_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan pivots from Plan v40's oracle-based `qm_bfmcs` approach to the `dd_bfmcs` scheduling chain approach identified by Report 41 as the live proof path. The key insight is that the Hintikka chain machinery (`hintikka_chain_exists`, `HintikkaStepOracle`, `WitnessedHintikka`) and the entire `qm_bfmcs_restricted_*` construction (lines 1823-1961 of RootScopedChain.lean) are dead code -- never called by `dd_countermodel`. The live sorry sites are `dd_bfmcs_restricted_tc` (line 953), `dd_bfmcs_restricted_buc` (line 958), and `dd_bfmcs_restricted_fuc` (line 963), which use the scheduling chain (`fwd_chain_of_sigma` / `bwd_chain_of_sigma`) not the oracle chain. Phase 1 archives dead code and updates ROAD_MAP.md. Subsequent phases close the three live sorries using the scheduling chain's F-persistence from `defect_fwd_step_choice_spec` and enriched backward oracle seed for backward Until coherence. Definition of done: `lake build` succeeds and `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

- **Report 41** (team, 4 teammates): Confirmed `qm_bfmcs_restricted_*` and Hintikka chain machinery are dead code on the active path. Identified F-persistence in the scheduling chain via `defect_fwd_step_choice_spec` for closing `dd_bfmcs_restricted_tc`. Proposed enriched backward oracle seed for backward Until coherence. Confirmed `phi /\ F(phi U psi) -> phi U psi` is semantically invalid (all 4 teammates). Recommended 3-phase hybrid approach.

### Prior Plan Reference

**Plan v40** (Quasimodel BFMCS, 6 phases, 12 hours): Phases 1-2 completed (Boneyard archival + validation). Phases 3-4 partial (oracle step construction + qm_fmcs/qm_bfmcs built but coherence proofs sorry'd). Phases 5-6 not started. Key lessons: (1) The oracle chain approach (`qm_bfmcs`) successfully built the chain infrastructure (sorry-free `qm_fmcs`, `qm_bfmcs`, box stability, g/h_content propagation) but hit the same Lindenbaum non-determinism wall for coherence proofs; (2) Effort calibration: archival took ~1.5 hours as estimated; (3) The `dd_countermodel` wiring was NOT changed to use `qm_bfmcs`, confirming the live path remains `dd_bfmcs`.

### Roadmap Alignment

- **Task 93** (ROAD_MAP.md): Close RootScopedChain.lean sorries (6 listed, 3 live + 3 dead on qm path)
- **Task 95**: `#print axioms` audit (depends on task 93)
- ROAD_MAP.md sorry inventory needs updating: line numbers are stale (reference 1413-1527 but actual are 953-963), and the 6-sorry count should be revised to 3 live + 9 dead (qm path)

## Goals & Non-Goals

**Goals**:
- Archive dead code (qm_bfmcs construction, Hintikka chain sorry sites, OracleStep.lean sorry-bearing theorems) to Boneyard/
- Update ROAD_MAP.md to reflect current sorry state (3 live sorries, not 6)
- Close `dd_bfmcs_restricted_tc` using scheduling chain F-persistence
- Close `dd_bfmcs_restricted_buc` using enriched backward oracle seed
- Close `dd_bfmcs_restricted_fuc` using restricted_tc + oracle chain Until propagation
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- Closing sorry sites in `qm_bfmcs_restricted_*` (dead code, being archived)
- Closing OracleStep.lean sorry sites for general `HintikkaStepOracle` (dead code)
- Dense completeness (task 68)
- Deleting the oracle step infrastructure that IS used by the dd_chain (qm_oracle_step, qm_oracle_step_bwd)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `defect_fwd_step_choice_spec` F-persistence only covers scheduled formula, not all F-obligations | H | M (30%) | Verify by reading the spec carefully. The spec says "forall chi in defects, F(chi) in M'" -- if this is true for ALL defects, F-persistence holds globally. If only for the scheduled one, need to chain through schedule surjectivity. |
| Enriched backward seed breaks existing backward chain infrastructure | M | L (15%) | The backward chain (`bwd_chain_of_sigma`) uses `bwd_pred` which is independent of the oracle seed. Enrichment targets `qm_oracle_seed_bwd` used only by `qm_bwd_chain`, which is dead code being archived. For dd_bfmcs_restricted_buc, the proof strategy uses induction on witness distance, not backward chain modification. |
| Guard argument for restricted_fuc requires Until-persistence across scheduling steps | H | M (25%) | The oracle chain has `qm_fwd_chain_until_persists` (sorry-free). For the scheduling chain, Until persistence may need a new lemma. The scheduling step preserves g_content, so Until formulas propagate via G(phi U psi) if present. Alternative: use BX9 + BX5 directly. |
| Boneyard archival breaks imports or removes needed definitions | M | L (10%) | Phase 1 includes `lake build` verification. Archive only definitions proven dead (not called from live path). Keep OracleStep.lean's `qm_oracle_step*` definitions since they ARE imported by RootScopedChain. |
| restricted_buc backward step transfer still invalid for scheduling chain | H | M (20%) | Report 41's enriched backward seed approach targets the oracle chain. For the scheduling chain (bwd_chain_of_sigma), backward Until coherence may need a different argument: induction on u-t with BX8 base case and BX9 + g_content step case. Validate mathematically before coding. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Archive Dead Code to Boneyard and Update ROAD_MAP.md [NOT STARTED]

**Goal**: Remove all dead code from the active codebase that was identified by Report 41. This includes the entire `qm_bfmcs_restricted_*` section, the Hintikka chain comment-based sorry references, and updating ROAD_MAP.md to reflect the actual 3-sorry state.

**Tasks**:
- [ ] Identify dead code in RootScopedChain.lean: everything from line 1823 (`/-! ## Restricted Temporal Coherence for qm_bfmcs`) through line 1963 (end of `qm_bfmcs_restricted_fuc`). This includes `qm_bfmcs_restricted_tc`, `qm_bfmcs_restricted_buc`, `qm_bfmcs_restricted_fuc`, and `F_phi_gives_top_until_defect`.
- [ ] Archive dead code to `Boneyard/OracleCoherence.lean` (separate from existing `Boneyard/RoundRobinChain.lean`)
- [ ] Verify that `qm_fwd_chain`, `qm_bwd_chain`, `qm_chain`, `qm_fmcs`, `qm_bfmcs` definitions (lines 1500-1788) are NOT dead -- they are imported by the dead coherence theorems but also may be independently useful. Keep these in RootScopedChain.lean if removing only the sorry-bearing coherence theorems.
- [ ] Alternatively, if qm_fmcs/qm_bfmcs are also unreachable from dd_countermodel, archive them too. Check: does dd_countermodel reference qm_bfmcs? (Answer from codebase: NO -- dd_countermodel uses dd_bfmcs at line 977)
- [ ] Archive the full qm_* construction (lines 1484-1963) to Boneyard/ since none is called by dd_countermodel
- [ ] Keep `defect_fwd_step_choice` and `defect_fwd_step_choice_spec` (lines 1460-1482) -- these are on the potentially live path for restricted_tc
- [ ] Update ROAD_MAP.md:
  - Change sorry count from 6 to 3 (dd_bfmcs_restricted_tc/buc/fuc)
  - Update line numbers to current values (953, 958, 963)
  - Remove references to `rr_fwd_chain_forward_F`, `dd_fmcs_forward_F`, `dd_fmcs_backward_P` (these were from the old round-robin era and are already gone from the code)
  - Add note about dead code archival
  - Update "Current Strategy" section to reflect scheduling chain approach
- [ ] Verify `lake build` succeeds after archival

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- remove dead qm_* coherence code (lines 1484-1963)
- `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/OracleCoherence.lean` -- new file, archived dead code
- `specs/ROAD_MAP.md` -- update sorry inventory, strategy description, line numbers

**Verification**:
- `lake build` succeeds
- `grep -c 'sorry' RootScopedChain.lean` shows exactly 3 (lines 953, 958, 963)
- ROAD_MAP.md sorry table lists exactly 3 active-path sorries
- No definition referenced by `dd_countermodel` was removed

---

### Phase 2: Close dd_bfmcs_restricted_tc (Scheduling Chain F-Persistence) [NOT STARTED]

**Goal**: Prove that F-eventualities are eventually resolved in the scheduling chain. This is the primary blocker -- restricted_fuc depends on it.

**Tasks**:
- [ ] Verify `defect_fwd_step_choice_spec` provides F-persistence for ALL defects (line 1480-1481): confirm `forall chi in defects, F(chi) in M'` -- this means ALL F-obligations are preserved, not just the scheduled one
- [ ] Verify that the scheduled defect is RESOLVED (line 1478-1479): `exists w in defects, w in M'` -- the earliest defect enters M'
- [ ] Understand `fwd_chain_of_sigma`: at step n, the target is `sigma_list[n % len]`. This is round-robin scheduling over sigma_list. Each formula in sigma_list is scheduled infinitely often.
- [ ] Proof sketch for forward direction (`F(phi) in mcs(t) -> exists s > t, phi in mcs(s)`):
  1. By BX12: `F(phi) -> top U phi`, so `top U phi in mcs(t)`.
  2. Need `top U phi in sigma_list` (from `h_sub: deferralClosure root -> sigma_list`).
  3. By `fwd_succ_resolves`: when `fwd_succ M hM target` is called with `target = top U phi` and `F(top U phi) in M`, then `target in fwd_succ(M)` -- i.e., `top U phi` is resolved.
  4. Wait -- `fwd_succ` resolves the TARGET, not an arbitrary formula. The scheduling chain calls `fwd_succ` with target = `sigma_list[n % len]`. So `top U phi` is resolved at step n where `sigma_list[n % len] = top U phi`. But we need `F(top U phi) in M` at that step.
  5. F-persistence: `F(top U phi) in mcs(t) -> F(top U phi) in mcs(t+1)` by g_content propagation? No -- g_content gives `G(F(top U phi))`, not `F(top U phi)`. Need `G(F(top U phi)) in mcs(t)` which requires `F(top U phi)` to be a theorem of the form `G(...)`.
  6. Alternative: use `defect_fwd_step_choice_spec` which preserves `F(chi)` for all defects. But `fwd_chain_of_sigma` uses `fwd_succ`, not `defect_fwd_step_choice`. Check if they are the same.
- [ ] **CRITICAL**: Determine whether `fwd_succ` preserves F-obligations. Read `fwd_succ` definition and its properties.
- [ ] If `fwd_succ` does NOT preserve F-obligations: consider rewiring `fwd_chain_of_sigma` to use `defect_fwd_step_choice` instead, or prove restricted_tc via a different argument.
- [ ] If F-persistence holds: prove `dd_bfmcs_restricted_tc` by:
  - Forward: F(phi) in mcs(t), by schedule surjectivity phi is scheduled at some step s > t, F(phi) persists to step s, fwd_succ resolves phi at step s.
  - Backward: symmetric using bwd_pred and Since/P.
- [ ] Write the formal Lean proof.

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry at line 953

**Verification**:
- `dd_bfmcs_restricted_tc` compiles without sorry
- `lake build` succeeds
- `lean_verify` on `dd_bfmcs_restricted_tc` shows no sorry dependency

---

### Phase 3: Close dd_bfmcs_restricted_buc (Backward Until/Since Coherence) [NOT STARTED]

**Goal**: Prove backward Until/Since coherence: given a witness (psi at time u with guard phi on [t,u)), show phi U psi in mcs(t).

**Tasks**:
- [ ] Validate the backward step transfer mathematically. The goal is: given `phi U psi in mcs(r+1)` and `phi in mcs(r)`, show `phi U psi in mcs(r)`. This is the step that Report 41 confirmed is NOT derivable from `phi /\ F(phi U psi) -> phi U psi` (semantically invalid).
- [ ] Alternative approach via induction on u - t with BX8 base case:
  - Base case (u = t): psi in mcs(t), by BX8: phi U psi in mcs(t). Done.
  - Step case: psi in mcs(u), guard phi in mcs(r) for r in [t, u). By IH: phi U psi in mcs(t+1). Need phi U psi in mcs(t).
  - From phi U psi in mcs(t+1): by h_content backward propagation, H(phi U psi) in mcs(t)? No -- h_content gives H-formulas only for formulas of the form H(...).
  - From phi U psi in mcs(t+1): this means at the chain level, the successor MCS contains phi U psi. But we need it in the predecessor.
- [ ] Alternative approach: build the Until formula directly from the guard and witness using BX axioms:
  - We have phi in mcs(t), phi in mcs(t+1), ..., phi in mcs(u-1), psi in mcs(u).
  - By BX8: phi U psi in mcs(u) (from psi in mcs(u)).
  - At step u-1: phi in mcs(u-1). Need phi U psi in mcs(u-1). This requires the backward step transfer which is blocked.
- [ ] Consider using the scheduling chain's specific structure. `fwd_succ M hM target` builds a successor with `g_content(M) subset fwd_succ(M)`. If `G(phi U psi) in mcs(u)`, then `phi U psi in g_content(mcs(u))`, so `phi U psi in mcs(u+1)`. But we need backward, not forward.
- [ ] **Key insight from Report 41**: The enriched backward oracle seed approach. Modify `bwd_pred` (or build a new backward chain variant) to include Until-formulas from the successor in the backward seed. Then phi U psi in mcs(r+1) is in the backward seed for mcs(r), so after Lindenbaum extension, phi U psi in mcs(r).
- [ ] If modifying `bwd_pred`: this changes the backward chain construction. Alternatively, build a new `bwd_pred_enriched` that includes Until-carrying and prove the restricted_buc for chains built with this enriched step.
- [ ] If the approach requires chain modification: rewire `bwd_chain_of_sigma` to use enriched backward step. Verify g_content/h_content properties still hold.
- [ ] Write the formal Lean proof for `dd_bfmcs_restricted_buc`.

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry at line 958, possibly modify `bwd_pred` or add `bwd_pred_enriched`

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `lake build` succeeds
- All existing sorry-free theorems remain sorry-free

---

### Phase 4: Close dd_bfmcs_restricted_fuc (Forward Until/Since Coherence) [NOT STARTED]

**Goal**: Prove forward Until/Since coherence: given phi U psi in mcs(t), find witness s >= t with psi in mcs(s) and guard phi in mcs(r) for r in [t, s).

**Tasks**:
- [ ] Forward Until coherence proof:
  1. By BX10: phi U psi in mcs(t) implies F(psi) in mcs(t).
  2. By restricted_tc (Phase 2): exists s > t with psi in mcs(s).
  3. Guard: for r in [t, s), show phi in mcs(r). At each intermediate step r:
     - If phi U psi in mcs(r) and psi not in mcs(r), then by BX9: phi or psi in mcs(r). Since psi not in mcs(r), phi in mcs(r).
     - Need phi U psi to persist from mcs(t) to mcs(r) while psi is absent.
  4. Until persistence in the scheduling chain: if phi U psi in mcs(t) and psi not in mcs(t), does phi U psi in mcs(t+1)?
     - By g_content: G(phi U psi) in mcs(t) would give phi U psi in mcs(t+1). But G(phi U psi) requires phi U psi to be a G-theorem, which it is not in general.
     - By fwd_succ seed: the seed is `{target} union g_content(M)`. If phi U psi is not the target and not in g_content, it may not be in the successor.
  5. This is the same persistence problem. The oracle chain has `qm_fwd_chain_until_persists` (sorry-free) because the oracle seed includes Until-defects. The scheduling chain does NOT.
- [ ] **Resolution**: Either (a) prove Until-persistence for the scheduling chain via a different argument, or (b) modify the scheduling chain forward step to also carry Until-defects, or (c) use the oracle chain for the forward direction only.
- [ ] Option (a): Show that phi U psi persists in any MCS successor where g_content is preserved and psi is absent. This requires: if phi U psi in M and g_content(M) subset M' and psi not in M', then phi U psi in M'? This is NOT guaranteed -- g_content gives G-formulas, not Until-formulas.
- [ ] Option (b): Modify `fwd_succ` to include Until-defects in its seed: `{target} union g_content(M) union {alpha U beta | alpha U beta in M, beta not in M, alpha U beta in sigma_list}`. This matches Report 41's enriched seed approach. Need to prove this enriched seed is consistent (same argument: subset of M.formulas).
- [ ] Option (c): Rewire dd_countermodel to use the oracle chain (qm_bfmcs) instead of dd_bfmcs. But this would require keeping qm_bfmcs and proving ITS coherence, which was the approach in Plan v40 that hit blockers.
- [ ] **Preferred approach**: Option (b) -- enrich `fwd_succ` seed. This is minimal and targeted.
- [ ] After enrichment: forward Until coherence follows from:
  - phi U psi persists (enriched seed)
  - At the scheduled step for phi U psi, fwd_succ resolves it: psi enters the chain
  - Guard: BX9 gives phi at each intermediate step
- [ ] If base case (s = t): psi in mcs(t) directly gives witness with vacuous guard.
- [ ] Forward Since: symmetric argument using bwd_pred and P(psi).
- [ ] Write the formal Lean proof for `dd_bfmcs_restricted_fuc`.

**Timing**: 2 hours (leverages Phase 2 infrastructure)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry at line 963, possibly modify `fwd_succ` seed or add enriched variant

**Verification**:
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `lake build` succeeds
- `dd_countermodel` compiles without sorry

---

### Phase 5: Integration, Verification, and Cleanup [NOT STARTED]

**Goal**: Verify sorry-free completeness and perform final cleanup.

**Tasks**:
- [ ] Verify `bx_completeness` compiles without sorry
- [ ] Run `#print axioms bx_completeness` and confirm only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Run full `lake build`
- [ ] Grep for remaining sorry in BXCanonical files; verify none reachable from `bx_completeness`
- [ ] Add docstrings to new/modified theorems explaining the mathematical argument
- [ ] Final ROAD_MAP.md update: mark task 93 sorry sites as closed, update sorry count to 0

**Timing**: 1 hour

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- docstrings
- `specs/ROAD_MAP.md` -- final sorry count update

**Verification**:
- `lake build` succeeds
- `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- No reachable sorry from `bx_completeness`

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_verify` on `dd_bfmcs_restricted_tc` after Phase 2 -- no sorry dependency
- [ ] `lean_verify` on `dd_bfmcs_restricted_buc` after Phase 3 -- no sorry dependency
- [ ] `lean_verify` on `dd_bfmcs_restricted_fuc` after Phase 4 -- no sorry dependency
- [ ] `lean_verify` on `dd_countermodel` after Phase 4 -- no sorry dependency
- [ ] `lean_verify` on `bx_completeness` after Phase 5 -- only `propext`, `Classical.choice`, `Quot.sound`

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/41_bxcanonical-embedding.md` -- this plan
- `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/OracleCoherence.lean` -- archived dead code (Phase 1)
- `specs/ROAD_MAP.md` -- updated sorry inventory (Phases 1, 5)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- sorry-free coherence proofs (Phases 2-4)

## Rollback/Contingency

1. **Phase 1 safe**: Boneyard archival is pure code movement. Rollback: move code back.

2. **Phase 2 F-persistence fails**: If `fwd_succ` does not preserve F-obligations and cannot be easily enriched, fall back to the oracle chain approach: keep `qm_bfmcs` and prove its restricted_tc using `defect_fwd_step_choice_spec` (which explicitly provides F-persistence). This would require un-archiving the qm_bfmcs code and rewiring dd_countermodel.

3. **Phase 3 backward step transfer fails**: If no backward enrichment strategy works for `bwd_pred`, try: (a) build a completely new backward chain that embeds Until-formulas into its seed by construction; (b) use the oracle backward chain `qm_bwd_chain` which already has h_content backward propagation and can be extended with enriched backward seed.

4. **Phase 4 Until-persistence fails**: If enriching `fwd_succ` breaks existing proofs, create a separate `fwd_succ_enriched` and `fwd_chain_of_sigma_enriched` that coexist with the original. Use the enriched chain only for restricted_fuc.

5. **Complete failure**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/` restores current state. The Boneyard archival (Phase 1) can be preserved independently.
