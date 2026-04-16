# Implementation Plan: Close BXCanonical Embedding (v27 -- Goldblatt WF-Induction Chain)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 35 hours
- **Dependencies**: None (task 92 completed; truth lemma and quasimodel infrastructure sorry-free)
- **Research Inputs**: reports/27_team-research.md, reports/26_defect-reentry-analysis.md, reports/17_round-robin-chain-history.md
- **Artifacts**: plans/27_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Six sorry sites in `RootScopedChain.lean` (lines 1321, 1352, 1359, 1412, 1417, 1422) block `bx_completeness`. Twenty-seven rounds of research have conclusively established that the existing `rr_fwd_chain` with `enriched_fwd_step` cannot prove `forward_F` due to perpetual deferral being semantically consistent (Report 26). All four Round 27 teammates converge on a **Goldblatt-style well-founded induction chain** using the simple `fwd_succ` step (already sorry-free) with induction on deferral closure depth. This plan replaces the round-robin chain with a depth-stratified construction where F-obligations are resolved by well-founded recursion on `f_nesting_depth` within `deferralClosure(root)`. Definition of done: `lake build` succeeds, `grep -rn sorry RootScopedChain.lean` returns zero, and `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

- **Report 27** (4-teammate consensus): Goldblatt WF-induction chain is primary recommendation. All direct axiom-level approaches are blocked. All 6 sorries form a single cluster (critic confirms sorry-5/6 are NOT independent). Infrastructure for WF induction (`deferralClosure`, `max_F_depth_in_closure`, `forward_temporal_witness_seed_consistent`) is all sorry-free. Main risk: circularity between `forward_F` and `backward_G` at same depth level.
- **Report 26**: Definitive proof that perpetual deferral is semantically consistent in the existing chain. The BX11 ordering can permanently favor one formula over another. G(F(chi)) does not follow from F(chi) -- this is the irreducible obstruction for the enriched seed approach.
- **Report 17**: History of 21 dead ends spanning plans v5-v22. Documents the progression from fuel-based recursion through BX11 acyclicity to the current demand-driven approach.

### Prior Plan Reference

Plan v23 (30 hours, 6 phases, demand-driven chain) was blocked because the demand-driven approach still faces the same G(F(chi)) obstruction as the enriched seed: when multiple F-defects exist, the demand-driven step resolves one target but cannot preserve F-obligations for others without the persistent-carry seed, which is provably inconsistent in general. Key lessons: (1) any approach that tries to preserve f_carry through g_content will fail because G(F(chi)) is not derivable from F(chi); (2) the BX11 fold gives only disjunctive control, not deterministic resolution; (3) the entire cluster of 6 sorries depends on `forward_F`, including sorries 5/6 (Until/Since coherence).

### Roadmap Alignment

- Advances the sole remaining active-path sorry cluster (`RootScopedChain.lean`: 6 sorries)
- Closes `rr_fwd_chain_forward_F` (PRIMARY BLOCKER, ROAD_MAP line 24)
- Would make `dd_countermodel` sorry-free, resolving `Completeness.lean:154`
- Would unblock task 95 (`#print axioms` audit on `bx_completeness`)
- Phase 1 updates ROAD_MAP.md with 5 new dead ends (22-26) and corrected metrics

## Goals & Non-Goals

**Goals**:
- Update ROAD_MAP.md with current state (5 new dead ends, corrected metrics, strategic shift)
- Design a Goldblatt WF-induction chain that resolves F-obligations by induction on `f_nesting_depth`
- Prove `forward_F` and `backward_P` by well-founded induction on deferral closure depth
- Close all 6 sorry sites in `RootScopedChain.lean`
- Achieve `lake build` with zero sorry in active BXCanonical path

**Non-Goals**:
- Modifying the truth lemma or quasimodel infrastructure (sorry-free, proven correct)
- Dense completeness (independent task 68)
- Quasimodel-to-Int bridge (fallback only, not primary approach)
- Publishing the partial result (separate effort)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| WF-induction circularity: backward_G requires forward_F for neg(phi), which has same depth as phi | H | M (40%) | The `restricted_temporal_backward_G_strict` takes forward_F as an explicit parameter, enabling mutual induction. Verify termination on paper before Lean formalization. |
| F-obligation disappearance in simple chain: F(psi) may leave the chain before the WF-induction step visits it | H | M (35%) | The WF-induction proof handles this case explicitly: if F(psi) NOT in chain(n), the induction hypothesis at lower depth still applies. The key insight is that F-obligations are in `deferralClosure` which is finite. |
| Modified chain construction invalidates existing dd_fmcs/dd_bfmcs wiring | M | H (70%) | Budget 4 hours for re-wiring. The new chain must expose the same API surface (mcs, g_content propagation, zero-point). |
| Lean4 formalization overhead for well-founded recursion on Finset depth | M | M (40%) | Use `Finset.strongRecOn` or `WellFoundedRelation` instances already in Mathlib. The `max_F_depth_in_closure` infrastructure is sorry-free. |
| backward_P case requires symmetric chain construction | M | M (30%) | The backward chain uses `bwd_pred` (symmetric to `fwd_succ`). The WF-induction argument is structurally identical with `p_nesting_depth` replacing `f_nesting_depth`. |
| Until/Since coherence (sorries 5/6) requires additional step-transfer beyond forward_F | M | M (45%) | Report 27 Finding 12 confirms these depend on forward_F. Once forward_F is available, BX5 self-accumulation + BX10 eventuality extraction provide the guard and witness. Budget 4 hours. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel (though this plan is fully sequential due to mathematical dependencies).

---

### Phase 1: Update ROAD_MAP.md [NOT STARTED]

**Goal**: Bring ROAD_MAP.md up to date with the strategic shift to Goldblatt WF-induction, document 5 new dead ends, correct stale metrics, and record the approach change for task 93.

**Tasks**:
- [ ] Update the "Active-path sorry summary" table: correct sorry line numbers to current values (1321, 1352, 1359, 1412, 1417, 1422 per grep output -- these have shifted from the ROAD_MAP's current 1275, 1306, 1313, 1366, 1371, 1376)
- [ ] Update the module import graph: add missing files `CanonicalModel.lean`, `OrderedSeedConsistency.lean`, `RootScopedChain.lean` to the graph with correct line counts
- [ ] Update total BXCanonical line count (currently claims "3,473 lines across 13 files"; needs recount)
- [ ] Add 5 new dead ends (22-26) to the "Dead Ends (Archived)" section:
  - (22) Defect re-entry in enriched chain -- perpetual deferral scenario (Report 26)
  - (23) G(F(chi)) non-derivability blocking persistent-carry seed (Reports 22, 26)
  - (24) Non-enriched chain F-obligation loss -- `fwd_succ` doesn't preserve f_carry (Report 26 Section 7.2)
  - (25) Quasimodel BXPoint-to-Int bridging gap (Report 25)
  - (26) Semantic coherence circularity -- truth lemma requires forward_F which requires truth lemma (Report 26 Section 6.6)
- [ ] Update task 93 description in cross-reference table from "chain replacement approach" to "Goldblatt WF-induction chain approach"
- [ ] Update task 94 status to [COMPLETED] and task 103 to [COMPLETED] in cross-reference table
- [ ] Add brief "Current Strategy" subsection under "Task 93: Progress and Infrastructure" describing the Goldblatt WF-induction approach
- [ ] Update "Last updated" timestamp

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `specs/ROAD_MAP.md` -- comprehensive update with dead ends, metrics, strategy

**Verification**:
- ROAD_MAP.md is internally consistent (sorry line numbers match grep output)
- All 5 new dead ends are documented with cross-references to source reports
- Task cross-reference table reflects current task statuses

---

### Phase 2: Pen-and-Paper Verification of WF Measure [NOT STARTED]

**Goal**: Verify on paper that the Goldblatt WF-induction argument terminates, resolving the circularity between `forward_F` and `backward_G`. Produce a written proof sketch in a Lean comment block documenting the exact mathematical argument.

**Tasks**:
- [ ] Define the well-founded measure precisely. The measure is `f_nesting_depth(psi)` for the formula being resolved. For `psi` with `F(psi) in chain(n)`:
  - If `f_nesting_depth(psi) = 0`: psi contains no F-operators. The simple `fwd_succ` step resolves psi at its visit step (by `fwd_succ_resolves`). F(psi) in chain(n) and target = psi gives psi in chain(n+1). Done.
  - If `f_nesting_depth(psi) = k+1`: psi may contain F-subformulas. After resolving psi via `fwd_succ`, the new chain state chain(n+1) has psi in it but F-obligations for OTHER formulas may have disappeared. The induction hypothesis applies to all formulas of depth <= k.
- [ ] Verify the mutual induction between `forward_F` and `backward_G`:
  - `forward_F(depth k)`: For all psi with `f_nesting_depth(psi) <= k`, if `F(psi) in chain(n)`, then exists s > n with psi in chain(s).
  - `backward_G(depth k)`: For all phi, if `phi in chain(s) for all s > n` AND `f_nesting_depth(neg phi) <= k`, then `G(phi) in chain(n)`.
  - `backward_G(depth k)` uses `restricted_temporal_backward_G_strict` which takes `forward_F` as a parameter. It needs `forward_F` for `neg(phi)`, and `f_nesting_depth(neg(phi)) <= k`. Since `neg(phi)` has the SAME depth as `phi`, this appears circular.
  - **Resolution**: The induction is on the PAIR (depth, forward/backward). At depth k: first prove `forward_F(k)` using `backward_G(k-1)` (which uses `forward_F(k-1)`). Then prove `backward_G(k)` using `forward_F(k)`.
  - **Alternative resolution**: The `fwd_succ` chain does NOT need backward_G to prove forward_F. The forward_F proof only needs the chain's g_content propagation and `fwd_succ_resolves`. The backward_G proof then follows from forward_F via `restricted_temporal_backward_G_strict`. There is NO mutual induction -- the dependency is one-directional: forward_F is proved independently, then backward_G follows.
- [ ] Handle the F-obligation disappearance case:
  - Scenario: F(psi) in chain(n), but at psi's visit step m > n, F(psi) is NOT in chain(m) (because intervening non-resolving steps lost the F-obligation).
  - With simple `fwd_succ`: at non-resolving steps, the seed includes `g_content(M) union f_carry(M)` (by `fwd_succ` definition). So F(psi) in chain(k) AND psi in sigma_list implies F(psi) in chain(k+1) at non-resolving steps for psi (since F(psi) is in f_carry).
  - At RESOLVING steps for OTHER targets: the seed is `{target} union g_content(M)`, which does NOT include f_carry. F(psi) may be lost.
  - **Key insight**: With the SIMPLE `fwd_succ` chain (not enriched), the resolving branch seed is `{target} union g_content(M)`. F-obligations for non-targets are NOT preserved. This means F(psi) CAN disappear.
  - **But wait**: The existing `rr_fwd_chain` uses `enriched_fwd_step`, not `fwd_succ`. The Goldblatt approach uses `fwd_succ` ONLY. Without enriched steps, F-obligations are NOT constant (they can disappear at resolving steps for other targets).
  - **This is actually fine for the WF-induction**: We do NOT need F-obligation constancy. We need: if F(psi) is in chain(n), then psi appears at some future step. With the simple chain: at psi's NEXT visit step after n, either F(psi) is still in chain (and psi is resolved), or F(psi) disappeared at some intermediate step. If F(psi) disappeared, then at that step, psi was NOT resolved (it was a resolving step for another target), and F(psi) was simply not in the Lindenbaum extension. But then psi is not required to appear -- the hypothesis `F(psi) in chain(n)` only requires psi at some s > n, and the MCS at step n+1 (the visit step for psi after n) has psi in it if F(psi) was still present.
  - **CRITICAL REALIZATION**: With simple `fwd_succ`, at psi's visit step, if F(psi) is in the MCS, psi is resolved (placed in the successor). But if F(psi) was lost at an earlier resolving step for another target, psi's visit step won't resolve it. The WF argument must handle this.
  - **Modified chain construction**: Instead of round-robin scheduling, use a construction where each F-defect is resolved in ORDER of f_nesting_depth. At depth 0: all depth-0 F-defects are resolved first. At depth 1: use the depth-0 resolution as a sub-chain, then resolve depth-1 defects. This is the Goldblatt "step-by-step" construction.
- [ ] Write the complete proof sketch as a block comment to be placed in `RootScopedChain.lean`

**Timing**: 6 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add proof sketch comment block (no executable code yet)

**Verification**:
- Proof sketch is mathematically complete (no gaps or "should work" hand-waving)
- Each case of the induction is addressed
- The F-obligation disappearance case is resolved
- The measure is explicitly defined and shown to be well-founded
- `lake build` still succeeds (comment-only changes)

---

### Phase 3: Build WF-Induction Chain Construction [NOT STARTED]

**Goal**: Define a new chain construction based on well-founded induction on `f_nesting_depth` within `deferralClosure(root)`. The chain resolves F-defects by depth-stratified processing: all depth-0 defects first, then depth-1 defects using depth-0 resolution as infrastructure, and so on.

**Tasks**:
- [ ] Define `depth_stratified_fwd_chain`: a chain construction parameterized by the root formula, where:
  - **Base layer (depth 0)**: For each depth-0 F-defect psi (i.e., `f_nesting_depth(psi) = 0` and `F(psi) in M0`), use `fwd_succ` to build a step resolving psi. Since psi has no F-subformulas, the resolution is unconditional.
  - **Inductive layer (depth k+1)**: Assuming all depth-<=k defects can be resolved (induction hypothesis), resolve depth-(k+1) defects. At each resolving step, the `fwd_succ` step places psi in the successor. Psi may contain `F(chi)` for depth-<=k formulas chi; these are resolved by the induction hypothesis applied to the sub-chain.
  - **Identity tail**: After all defects in `deferralClosure(root)` are processed (finitely many, since `deferralClosure` is a `Finset`), extend with identity steps (repeated last MCS via g_content self-inclusion).
- [ ] Define the chain scheduling function `wf_schedule`: assigns each step to a specific F-defect, processing in non-decreasing order of `f_nesting_depth`. Within each depth level, use round-robin among defects of that depth.
- [ ] Prove `depth_stratified_fwd_chain_mcs`: each chain state is an MCS
- [ ] Prove `depth_stratified_fwd_chain_g_content`: g_content propagation between consecutive steps
- [ ] Prove `depth_stratified_fwd_chain_resolves`: at defect psi's dedicated step, psi is in the successor MCS (uses `fwd_succ_resolves`)
- [ ] Define `wf_fwd_chain_forward_F`: the key theorem. For any psi in `deferralClosure(root)` with `F(psi) in chain(n)`, there exists s > n with `psi in chain(s)`.
  - **Proof by well-founded induction on `f_nesting_depth(psi)`**:
  - Base case (`f_nesting_depth(psi) = 0`): psi has a dedicated resolving step m in the depth-0 layer. At step m, `fwd_succ` resolves psi if `F(psi) in chain(m)`. Need: F(psi) persists from chain(n) to chain(m). At non-resolving steps, f_carry preserves F(psi). At resolving steps for other depth-0 targets, f_carry may lose F(psi). **Key**: if F(psi) is lost at some step k between n and m, then the MCS at k decided `neg(F(psi))` i.e. `G(neg(psi))`. But psi has depth 0 (no F-operators), so neg(psi) has depth 0, and `G(neg(psi)) in chain(k)` combined with g_content propagation gives `neg(psi) in chain(k+1), chain(k+2), ...`. But F(psi) was in chain(n) and chain(n) is an MCS, so... This needs careful analysis.
  - **ALTERNATIVE SIMPLER CONSTRUCTION**: Use `fwd_succ` at EVERY step with the same target psi until psi is resolved. Since `fwd_succ` resolves psi at the first step where `F(psi) in M`, this gives psi in chain(n+1) immediately.
  - **SIMPLEST CONSTRUCTION**: Replace the round-robin chain entirely. For each F-defect, build a SEPARATE one-step resolution, then concatenate. The concatenated chain resolves all defects.
- [ ] Alternatively, prove forward_F directly for the EXISTING `rr_fwd_chain` using a new argument based on the Goldblatt insight: if F(psi) persists forever, build a sub-model where psi is never true, contradicting the MCS axiom structure. This requires the depth-stratified backward_G argument.
- [ ] Build symmetric `wf_bwd_chain` for backward direction using `bwd_pred` and `p_nesting_depth`
- [ ] Define `wf_dd_chain` assembling forward and backward into Int-indexed chain matching `dd_chain` API

**Timing**: 12 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- new chain definitions and API lemmas

**Verification**:
- All new definitions compile without sorry
- `wf_fwd_chain_forward_F` compiles without sorry (the key theorem)
- `lake build` succeeds
- The new chain exposes the same API as `dd_chain` (mcs, g_content, zero-point)

---

### Phase 4: Close forward_F, backward_P, and restricted_tc [NOT STARTED]

**Goal**: Wire the WF-induction chain into `dd_fmcs`/`dd_bfmcs` and close the first 4 sorry sites: `rr_fwd_chain_forward_F` (line 1321), `dd_fmcs_forward_F` (line 1352), `dd_fmcs_backward_P` (line 1359), and `dd_bfmcs_restricted_tc` (line 1412).

**Tasks**:
- [ ] Close `rr_fwd_chain_forward_F` (line 1321): Either replace `rr_fwd_chain` with the WF chain entirely, or prove the existing theorem by delegating to the WF chain's forward_F property.
- [ ] Close `dd_fmcs_forward_F` t >= 0 case (line 1332-1343): Flows from `rr_fwd_chain_forward_F` (already wired).
- [ ] Close `dd_fmcs_forward_F` t < 0 case (line 1352): The backward chain has F(psi) at time t < 0. Strategy: the backward chain's h_content does not directly preserve F-formulas, but the WF-induction chain for the backward direction (using `bwd_pred` + `p_nesting_depth`) resolves P-obligations, while F-obligations in the backward chain propagate to M0 via a bridge argument (F(psi) in bwd_chain at t < 0 means F(psi) was in the seed extending g_content, which connects through M0 to the forward chain).
- [ ] Close `dd_fmcs_backward_P` (line 1359): Symmetric to forward_F using the WF backward chain.
- [ ] Close `dd_bfmcs_restricted_tc` (line 1412): Assemble from forward_F + backward_P + `restricted_temporal_backward_G_strict` + `restricted_temporal_backward_H_strict`. The restricted temporally coherent property requires: for all phi in deferralClosure(root), if F(phi) in fam.mcs(t) then exists s > t with phi in fam.mcs(s), AND if P(phi) in fam.mcs(t) then exists s < t with phi in fam.mcs(s).
- [ ] Fix any downstream lemmas broken by chain replacement
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry sites at lines 1321, 1352, 1359, 1412

**Verification**:
- `rr_fwd_chain_forward_F` compiles without sorry
- `dd_fmcs_forward_F` compiles without sorry (both t >= 0 and t < 0 cases)
- `dd_fmcs_backward_P` compiles without sorry
- `dd_bfmcs_restricted_tc` compiles without sorry
- `lake build` succeeds

---

### Phase 5: Close restricted_buc and restricted_fuc [NOT STARTED]

**Goal**: Close the final 2 sorry sites (`dd_bfmcs_restricted_buc` at line 1417, `dd_bfmcs_restricted_fuc` at line 1422) using the now-proved forward_F/backward_P.

**Tasks**:
- [ ] Close `dd_bfmcs_restricted_fuc` (line 1422) -- forward Until/Since coherence:
  - For Until `(phi U psi) in fam.mcs(t)`: By BX10 (`until_F`), `F(psi) in fam.mcs(t)`. By `forward_F`, exists s > t with `psi in fam.mcs(s)`. Guard: need `phi in fam.mcs(r)` for all r in [t, s). By BX5 (`self_accum_until`): `(phi U psi) -> ((phi AND (phi U psi)) U psi)`, so at intermediate points both phi and `(phi U psi)` hold. The chain's g_content propagation carries formulas forward. Since `phi U psi` holds at each intermediate point (by g_content of the chain), phi holds at each intermediate point (by BX9 `until_elim`: `(phi U psi) -> (phi OR psi)`, and if not psi then phi).
  - For Since: symmetric via backward_P
- [ ] Close `dd_bfmcs_restricted_buc` (line 1417) -- backward Until/Since coherence:
  - Given witness pattern (psi at s, phi on guard for r in [t,s)), derive `(phi U psi) in fam.mcs(t)`
  - By `restricted_temporal_backward_G_strict`: if `(phi U psi) in fam.mcs(r)` for all r in (t, s), then derive `G(phi U psi) in fam.mcs(t)`. Then from the truth of psi at s and the guard, obtain `(phi U psi) at t` via BX axioms.
  - Alternative: use BX8 at s (`psi -> (phi U psi)`) giving `(phi U psi) in fam.mcs(s)`. Then backward-induct: if `(phi U psi) in fam.mcs(r+1)` and `phi in fam.mcs(r)`, derive `(phi U psi) in fam.mcs(r)`. This step requires: `phi AND (phi U psi) -> G(phi U psi)`? No. Use BX6 (`absorb_until`): `(phi U (phi AND (phi U psi))) -> (phi U psi)`. At time r: if phi at r and (phi U psi) at r+1, need `(phi U (phi AND (phi U psi)))` at r. This has witness r+1 with guard phi on [r, r+1) = {r}, which holds. So `(phi U (phi AND (phi U psi))) at r`, hence `(phi U psi) at r` by BX6. This is the BACKWARD UNTIL INDUCTION. Formalize using g_content propagation from chain steps.
- [ ] Run `grep -n sorry RootScopedChain.lean` to verify zero matches
- [ ] Run `lake build`

**Timing**: 5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry sites at lines 1417, 1422

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `grep -n sorry RootScopedChain.lean` returns zero sorry statements (only sorry in comments)
- `lake build` succeeds

---

### Phase 6: Final Verification and Axiom Audit [NOT STARTED]

**Goal**: Verify that `bx_completeness` is sorry-free and depends only on the expected axioms. Update ROAD_MAP.md with completion status.

**Tasks**:
- [ ] Run `lake build` from clean state to verify full project builds
- [ ] Use `lean_verify` on `Bimodal.Metalogic.BXCanonical.Completeness.bx_completeness` to verify axiom set is `{propext, Classical.choice, Quot.sound}`
- [ ] Use `lean_verify` on `Bimodal.Metalogic.BXCanonical.RootScopedChain.dd_countermodel` to check axiom set
- [ ] Run `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/` to verify no sorries remain in active BXCanonical path (only comments mentioning sorry)
- [ ] Update ROAD_MAP.md to reflect all 6 sorries are closed
- [ ] Add docstrings to new WF-induction chain definitions
- [ ] Update task 93 status in ROAD_MAP cross-reference to [COMPLETED]

**Timing**: 2 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add docstrings
- `specs/ROAD_MAP.md` -- update sorry inventory and task status

**Verification**:
- `lean_verify bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- Zero sorry in `Theories/Bimodal/Metalogic/BXCanonical/` active path
- `lake build` succeeds
- ROAD_MAP.md reflects the completed state

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero (after Phase 5)
- [ ] `lean_verify` on `dd_countermodel` shows no sorry-dependent axioms
- [ ] `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No new sorry introduced in any file
- [ ] `dd_countermodel` theorem compiles end-to-end without sorry
- [ ] WF-induction chain's `forward_F` is proved by well-founded recursion on `f_nesting_depth`
- [ ] Proof sketch from Phase 2 matches the formal proof structure in Phases 3-5

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- WF-induction chain construction, 6 sorry sites closed
- `specs/ROAD_MAP.md` -- updated with dead ends 22-26, corrected metrics, completion status
- `specs/093_complete_bxcanonical_embedding/plans/27_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

Changes span `RootScopedChain.lean` and `ROAD_MAP.md`.

1. **Full success (all 6 sorries closed)**: Target outcome. No rollback needed.

2. **WF-induction works for forward_F but buc/fuc blocked (~20%)**: Keep forward_F/backward_P/restricted_tc proofs (reduces sorry count from 6 to 2). Spawn a focused follow-up task for Until/Since coherence closure.

3. **WF-induction circularity unresolvable (~15%)**: The pen-and-paper verification (Phase 2) would catch this before significant Lean investment. Fall back to quasimodel bridge (800-1200 new LOC, Report 27 Finding 8).

4. **Pen-and-paper succeeds but Lean formalization too complex (~20%)**: Commit the proof sketch and partial chain construction. Resume in follow-up with more time budget. The Phase 2 comment block has permanent value as documentation.

5. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean specs/ROAD_MAP.md` restores the current state. All code changes are confined to one file.

6. **Fallback approach**: If WF-induction fails entirely, the Reynolds quasimodel bridge (Report 27 Finding 8) can concatenate the 1,816 lines of sorry-free quasimodel code into Int-indexed FMCS families. Estimated 800-1200 new LOC, MEDIUM confidence.
