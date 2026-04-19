# Implementation Plan: Three-Path Strategy for DD-BFMCS Coherence

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: Task 92 (truth lemma sorry-free) -- satisfied
- **Research Inputs**: reports/44_team-research.md, reports/42_team-research.md
- **Artifacts**: plans/44_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan systematically attempts three architecture paths (C, then A, then B) to close the 5 sorry sites in RootScopedChain.lean (`fwd_chain_forward_F` at line 1111, `dd_bfmcs_restricted_tc` forward at line 1138 and backward at line 1145, `dd_bfmcs_restricted_buc` at line 1153, and `dd_bfmcs_restricted_fuc` at line 1160). Each path attempt is followed by an evaluation phase that records definitive success/failure evidence and updates ROAD_MAP.md, accumulating insight for future attempts. The plan begins by documenting rounds 43-44 findings in ROAD_MAP.md. Definition of done: either one path succeeds and all 5 sorries close with `lake build` passing, or all three paths are attempted with detailed failure analysis recorded.

### Research Integration

- **Report 44** (team, 4 teammates): Identified three viable paths. Path C (direct pigeonhole fix, 35% confidence, 100-200 LOC) targets `fwd_chain_forward_F` using the pigeonhole argument on finite sigma_list with F-persistence. Path A (oracle-based chain replacement, 50% confidence, 500-800 LOC) replaces fwd/bwd chains with oracle-based variants. Path B (full quasimodel-derived BFMCS, 55% confidence, 400-600 LOC) replaces dd_bfmcs entirely. All paths hit the same irreducible core: defect-count monotonicity across Lindenbaum extension. Report 44 also revealed 7-8 sorry sites in OracleStep.lean (previously claimed sorry-free), and confirmed the enriched seed approach is definitively dead (counterexample from report 43). Dependency chain: restricted_tc -> restricted_buc -> restricted_fuc.

- **Report 42** (team, 4 teammates): Confirmed F-persistence for all defects via `defect_fwd_step_choice_spec`. Identified that enriched backward seed must target `bwd_pred`/`bwd_chain_of_sigma`, not qm_oracle_seed_bwd. Specified Reynolds induction approach.

### Prior Plan Reference

**Plan v42** (5 phases, 10 hours): Phase 1 (archive oracle code) completed. Phases 2-5 not started. Key lessons: (1) The Reynolds induction approach for restricted_tc (Phase 2) may not work because defects can oscillate -- phi -> F(phi) regenerates defects. The `defect_step_choice_early_spec` resolves one defect per step but cannot prevent re-creation. (2) The enriched backward seed approach (Phase 3) was marked dead by report 43 counterexample. (3) Plan v42 assumed F-persistence through g_content in resolving steps, which is blocked by dead end #23 (G(F(chi)) non-derivability). The key infrastructure that IS validated: `preserving_fwd_step` with `defect_step_choice_early` correctly preserves ALL F-obligations and resolves at least one defect per step when defects exist. `fwd_chain_F_persistent` is proved sorry-free.

### Roadmap Alignment

- **Task 93** (ROAD_MAP.md): Close remaining active-path sorries in RootScopedChain.lean
- **Task 95**: `#print axioms` audit (depends on task 93)
- ROAD_MAP.md needs updating with rounds 43-44 findings, the three-path strategy, and updated dead ends

## Goals & Non-Goals

**Goals**:
- Update ROAD_MAP.md with rounds 43-44 research findings and three-path strategy
- Attempt Path C: close `fwd_chain_forward_F` via pigeonhole on finite sigma_list
- Attempt Path A (if C fails): oracle-based chain replacement for coherence
- Attempt Path B (if A fails): full quasimodel-derived BFMCS replacement
- Record definitive success/failure evidence after each attempt
- Accumulate mathematical insight into ROAD_MAP.md progressively
- Close all 5 sorry sites in RootScopedChain.lean (if any path succeeds)

**Non-Goals**:
- Closing OracleStep.lean sorry sites (7-8 sorries, not on active path)
- Dense completeness (task 68, independent)
- Modifying Frame.lean or TruthLemma.lean (both sorry-free)
- Creating new BFMCS infrastructure unless Path B is reached

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Path C: F-persistence gap from chain(n) to the next phi-scheduled step | H | H (60%) | The `fwd_chain_F_persistent` theorem already proves F(chi) persists across ALL steps. The gap is only showing phi is eventually the resolved defect, not just any defect. Pigeonhole on the finite defect list should close this. |
| Path C: defect oscillation -- resolving phi creates new F(phi) defect | H | M (40%) | Once phi in chain(m), the defect is phi not being in the set while F(phi) is. If phi IS in chain(m), then phi is no longer a defect. The resolved formula stays resolved because it enters the MCS directly. |
| Path A: 7-8 OracleStep.lean sorries block oracle-based chains | H | H (70%) | These sorries are for the universal oracle, not `hintikka_step_for_sigma_sig` which IS sorry-free. Path A can use the sigma-specific oracle which is sorry-free. |
| Path B: Wraparound problem for periodic extension g_content(v_k) not subset v_0 | M | M (50%) | Use palindromic cycling (period 2k) per teammate D's suggestion, which avoids wraparound entirely. |
| All paths fail due to irreducible Lindenbaum defect-monotonicity | H | M (35%) | Each failure narrows the search space. The accumulative ROAD_MAP.md updates ensure no future attempt repeats a dead end. |
| Time exhaustion before reaching Path B | M | M (40%) | Path C is low-cost (1.5 hours). If it fails quickly, pivot to Path A immediately. Budget 2 hours for Path C total (including evaluation). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 (conditional on Path C failure) |
| 5 | 5 | 4 |
| 6 | 6 | 5 (conditional on Path A failure) |
| 7 | 7 | 6 |

Phases within the same wave can execute in parallel. Phases 4-7 are conditional: if an earlier path succeeds, remaining phases are skipped.

---

### Phase 1: Update ROAD_MAP.md with Rounds 43-44 Findings [NOT STARTED]

**Goal**: Document all research findings from rounds 43-44 in ROAD_MAP.md, establishing the three-path strategy as the current approach and recording newly confirmed dead ends.

**Tasks**:
- [ ] Update "Current Strategy" section (currently "Scheduling Chain Coherence, Plan v42") to describe the three-path strategy (C, A, B) with confidence levels
- [ ] Add dead ends #31-33 from rounds 43-44:
  - #31: Enriched seed approach definitively dead (counterexample from report 43: `G(F(alpha) -> neg psi) in M` with both `F(alpha)` and `F(psi)` in f_carry)
  - #32: "Sorry-free oracle" claim at OracleStep.lean is false (7-8 sorry sites verified by teammate C)
  - #33: Reynolds induction on defects.length fails because defects can oscillate (phi -> F(phi) regeneration)
- [ ] Update sorry inventory: confirm 5 sorry sites at lines 1111, 1138, 1145, 1153, 1160 (the 3 from plan v42 have expanded to 5 as the proof structure was developed)
- [ ] Add a "Three-Path Strategy" subsection documenting Path C (pigeonhole/F-persistence, 35%), Path A (oracle chains, 50%), Path B (quasimodel BFMCS, 55%)
- [ ] Note the irreducible core finding: all paths require defect-count monotonicity across Lindenbaum
- [ ] Note the dependency chain: restricted_tc -> restricted_buc -> restricted_fuc
- [ ] Update "Task Cross-Reference" section with current status and plan v44

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `specs/ROAD_MAP.md` -- comprehensive update with rounds 43-44 findings

**Verification**:
- ROAD_MAP.md contains the three-path strategy description
- Dead ends #31-33 are documented
- Sorry inventory reflects current line numbers

---

### Phase 2: Path C Attempt -- Pigeonhole Fix for fwd_chain_forward_F [NOT STARTED]

**Goal**: Close `fwd_chain_forward_F` (line 1111) using the pigeonhole argument on the finite sigma_list, leveraging the proved `fwd_chain_F_persistent` and `defect_step_choice_early_spec`.

**Strategy**: The key proof argument is:
1. `F(phi) in chain(n)` by hypothesis.
2. By `fwd_chain_F_persistent`, `F(phi) in chain(m)` for all `m >= n`.
3. At each step `m >= n`, `phi in active_defects(chain(m), sigma_list)` because `F(phi) in chain(m)` and `phi in sigma_list`.
4. By `defect_step_choice_early_spec`, at each step where defects are non-empty (which is every step since phi is always a defect): there exists `w in defects` such that `w in chain(m+1)`.
5. The question: is `w = phi` at some step? If phi is ever the resolved defect, we are done.
6. **Pigeonhole**: `active_defects(chain(m), sigma_list)` is a sublist of `sigma_list`, which has `k` elements. At each step, one defect is resolved (enters chain(m+1)). A resolved defect `w` satisfies `w in chain(m+1)`. If `w in chain(m+1)`, then `F(w) in chain(m+1)` does NOT necessarily mean `w` is still a defect -- because `w in chain(m+1)` means it was resolved.
7. **The gap**: A resolved defect may still have `F(w) in chain(m+1)` (F-persistence), BUT `w in chain(m+1)` means `w` is no longer a defect at step m+1 (it is in the MCS). The defect condition is `F(w) in M AND w NOT in M`. Once `w in M`, `w` is not in `active_defects`.
8. **Wait**: `active_defects` is computed as `sigma_list.filter (fun chi => F(chi) in M)`. It does NOT check whether `chi` is absent. So `w` can be both in `M` and in `active_defects`. Re-read the definition.

**Re-analysis of active_defects**: `active_defects M sigma_list = sigma_list.filter (fun chi => F(chi) in M)`. This means chi is an "active defect" if `F(chi) in M`, regardless of whether `chi in M`. So even after resolution, if F(chi) persists, chi remains in active_defects.

**Revised argument**: The resolution property says `exists w in defects, w in M'`. If `w in M'` and `F(w) in M'`, then `w` is still in `active_defects` at the next step. BUT `w in M'` is what we want for forward_F. The question is whether `w = phi`.

**Core approach**: We do NOT need `phi` to be resolved by the defect step. We need `phi in chain(m)` for some `m > n`. The `defect_step_choice_early_spec` says some `w in defects` has `w in M'`. If `w = phi`, done. If not, we need another argument.

**Alternative approach**: Since `active_defects` includes `phi` at every step (because F(phi) persists), and `defect_step_choice_early` uses the BX11 fold over all defects, at some step `phi` might be the earliest in the BX11 ordering and get resolved directly. But BX11 ordering is MCS-dependent and non-deterministic.

**Cleanest approach**: Since `preserving_fwd_step` uses `defect_step_choice_early` which calls `defect_step_early` (which uses `resolving_enriched_fwd_exists` with the full defects list), the resolution is via `discharge_multi_step` or `target_stays_direct_in_fold`. We need to check whether there is a way to ensure phi is eventually the resolved formula. Since sigma_list is finite and defects is a sublist, there are at most k = sigma_list.length defects. At each step, one defect w has w in M'. We need to show phi is eventually this w.

**Key insight for pigeonhole**: At each step, `defect_step_choice_early_spec` resolves some w (w in M'). The w that gets resolved depends on the BX11 fold, which is deterministic given M. If the SAME w keeps getting resolved at every step, we need phi = w or the situation to change. The situation DOES change because at step m+1, `w in M'` but the chain moves to M' for the next step. The BX11 fold on M' may produce a different resolution.

**Tasks**:
- [ ] Read `defect_step_early` and `resolving_enriched_fwd_exists` to understand which defect gets resolved and why
- [ ] Determine whether the resolved defect `w` at step m satisfies: `w in chain(m+1)` but `w` may or may not be in `chain(m+2)` (since chain(m+2) is built from chain(m+1))
- [ ] If `w in chain(m+1)`: does `w` persist in subsequent chain elements? If not, `w` drops out and the defect set changes.
- [ ] Attempt the proof: since `active_defects` always contains phi (F-persistence), and at each step some defect w is placed in the next MCS, try induction on `(active_defects chain(m) sigma_list).length` or on the number of defects that have NOT been resolved since step n
- [ ] Alternative: if the resolved `w` at each step is `phi`, then `phi in chain(n+1)` and we are done immediately. Try to show this by examining the BX11 fold structure.
- [ ] If none of the above work: attempt to build a direct proof that at step `n+1`, the resolving case fires for phi because `F(phi) in chain(n)`. Read `preserving_fwd_step` more carefully: when defects are non-empty, it uses `defect_step_choice_early` which resolves via BX11 fold. The fold takes ALL defects. Check if there is a simpler argument: since phi is in defects, the BX11 fold places phi directly OR F-protects it. If phi is F-protected (F(phi) in M'), that is just F-persistence (already known). If phi is placed directly (phi in M'), that is resolution. The BX11 fold ALWAYS gives one of these two outcomes for each defect. The question: does phi get the direct outcome at some step?
- [ ] Write the Lean proof for `fwd_chain_forward_F`
- [ ] If `fwd_chain_forward_F` closes, attempt to close the remaining 4 sorries using restricted_tc -> restricted_buc -> restricted_fuc dependency chain
- [ ] For restricted_tc forward (line 1138): uses `fwd_chain_forward_F` directly for the backward chain case. Check if the backward chain has an analogous `bwd_chain_backward_P` theorem or needs one.
- [ ] For restricted_tc backward (line 1145): symmetric argument using backward chain P-resolution
- [ ] For restricted_buc (line 1153): requires restricted_tc as prerequisite, then uses BX12/BX8 axioms at MCS level
- [ ] For restricted_fuc (line 1160): requires restricted_tc (for F-witness via BX10), then BX9 for guard

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry at line 1111, attempt lines 1138, 1145, 1153, 1160

**Verification**:
- `fwd_chain_forward_F` compiles without sorry (primary target)
- If successful: `lake build` succeeds, remaining sorries close
- If unsuccessful: record specific Lean error messages and mathematical obstruction

---

### Phase 3: Path C Evaluation [NOT STARTED]

**Goal**: Assess Path C results, document findings in ROAD_MAP.md, and provide clear go/no-go decision for Path A.

**Tasks**:
- [ ] If Path C succeeded:
  - Verify all 5 sorry sites are closed
  - Run `lake build` to confirm
  - Run `#print axioms` on `dd_countermodel` to check no sorry dependency
  - Update ROAD_MAP.md: mark Path C as successful, update sorry count to 0
  - Skip phases 4-7
- [ ] If Path C failed:
  - Record the specific mathematical obstruction with Lean error messages
  - Document which sub-step of the pigeonhole argument broke down
  - Classify the failure: (a) pigeonhole argument flawed, (b) BX11 fold non-determinism blocks, (c) defect oscillation, (d) other
  - Update ROAD_MAP.md with dead end #34 (Path C failure specifics)
  - Provide go signal for Phase 4 (Path A)

**Timing**: 0.5 hours

**Depends on**: 2

**Files to modify**:
- `specs/ROAD_MAP.md` -- record Path C outcome

**Verification**:
- ROAD_MAP.md contains definitive Path C assessment
- If failed: clear go/no-go signal for Path A documented

---

### Phase 4: Path A Attempt -- Oracle-Based Chain Replacement [NOT STARTED]

**Goal**: Replace `fwd_chain_of_sigma` / `bwd_chain_of_sigma` with oracle-based chain construction using the sorry-free `hintikka_step_for_sigma_sig` infrastructure.

**Strategy**: The sorry-free infrastructure for Path A includes:
- `hintikka_step_for_sigma_sig` (OracleStep.lean:188-222): proves `hintikka_step` between sigma-signatures of consecutive oracle steps. This is the sigma-specific oracle (sorry-free), NOT the universal oracle (7 sorries).
- `hintikka_chain_exists` (Construction.lean:594-659): constructs a chain given an oracle parameter.
- `qm_oracle_step_bx_le` (OracleStep.lean:98): G-content propagation.
- `qm_oracle_step_h_content` (OracleStep.lean:103): H-content backward.

The approach:
1. Build `oracle_fwd_chain` using `qm_oracle_step` at each step (sigma-specific variant)
2. Build `oracle_bwd_chain` using `qm_oracle_step_bwd` at each step
3. Wire into `dd_bfmcs` by replacing the chain construction
4. Prove restricted_tc on the oracle chain (defect resolution is built into the oracle step)
5. Prove restricted_buc using BX12 at MCS level (requires restricted_tc as prerequisite)
6. Prove restricted_fuc using restricted_tc + BX9

**Key risk**: The sigma-specific oracle resolves sigma-signature defects, but `restricted_tc` needs resolution at the MCS level (phi in the full MCS, not just the sigma-restriction). Need to verify this lifts.

**Tasks**:
- [ ] Read `qm_oracle_step` and `hintikka_step_for_sigma_sig` to understand the sigma-specific oracle's exact guarantees
- [ ] Determine whether the oracle step's defect resolution lifts from sigma-restricted level to full MCS level
- [ ] Build `oracle_fwd_chain` using the sigma-specific oracle
- [ ] Prove F-persistence and defect resolution on the oracle chain
- [ ] Build `oracle_bwd_chain` for the backward direction
- [ ] Wire the oracle chains into dd_bfmcs (replace `fwd_chain_of_sigma` / `bwd_chain_of_sigma`)
- [ ] Close restricted_tc using oracle chain properties
- [ ] Close restricted_buc using restricted_tc + BX12/BX8 at MCS level
- [ ] Close restricted_fuc using restricted_tc + BX9 guard

**Timing**: 3 hours

**Depends on**: 3 (conditional on Path C failure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace chain construction, close sorries
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- if new step functions needed

**Verification**:
- If successful: all 5 sorry sites closed, `lake build` succeeds
- If unsuccessful: record specific obstruction

---

### Phase 5: Path A Evaluation [NOT STARTED]

**Goal**: Assess Path A results, document findings in ROAD_MAP.md, and provide clear go/no-go decision for Path B.

**Tasks**:
- [ ] If Path A succeeded:
  - Verify all 5 sorry sites are closed
  - Run `lake build` and `#print axioms` verification
  - Update ROAD_MAP.md: mark Path A as successful
  - Skip phases 6-7
- [ ] If Path A failed:
  - Record the specific mathematical obstruction with Lean error messages
  - Classify the failure: (a) sigma-to-MCS lift fails, (b) backward oracle missing, (c) defect-count monotonicity still blocks, (d) other
  - Update ROAD_MAP.md with dead end #35 (Path A failure specifics)
  - Provide go signal for Phase 6 (Path B)

**Timing**: 0.5 hours

**Depends on**: 4

**Files to modify**:
- `specs/ROAD_MAP.md` -- record Path A outcome

**Verification**:
- ROAD_MAP.md contains definitive Path A assessment
- If failed: clear go/no-go signal for Path B documented

---

### Phase 6: Path B Attempt -- Full Quasimodel-Derived BFMCS [NOT STARTED]

**Goal**: Replace `dd_bfmcs` entirely with a new BFMCS built from palindromic cycling of the quasimodel HintikkaPoint chain.

**Strategy**: Since `dd_countermodel` (RootScopedChain.lean:1164-1190) is fully parametric over BFMCS, any BFMCS satisfying `restricted_temporally_coherent`, `restricted_backward_until_since_coherent`, and `restricted_forward_until_since_coherent` can be substituted. The approach:

1. Build a finite HintikkaPoint chain from the quasimodel construction (sorry-free: `hintikka_chain_exists`)
2. Use palindromic cycling (period 2k): `v_0, v_1, ..., v_k, v_{k-1}, ..., v_1, v_0, v_1, ...` to avoid wraparound
3. Lift to BXPoint chain using the Realization module
4. Define `qm_fmcs` and `qm_bfmcs` from the palindromic BXPoint chain
5. Prove restricted_tc: defect resolution is built into the quasimodel construction (well-founded recursion on defect_count)
6. Prove restricted_buc: use BX12 at MCS level (requires restricted_tc -> restricted_temporal_backward_G)
7. Prove restricted_fuc: use restricted_tc + BX9 guard
8. Wire `qm_bfmcs` into `dd_countermodel` in place of `dd_bfmcs`

**Key risk**: The palindromic cycling solves G-forward and H-backward but creates a non-monotone temporal ordering at the reversal point (step k). The `bx_le` relation may not hold at the reversal. Mitigation: the BFMCS only needs `restricted_temporally_coherent` (F/P resolution), not `bx_le` monotonicity at every step.

**Tasks**:
- [ ] Build palindromic extension function: `palindrome_chain(chain, k, t) = chain[t mod (2k)]` with appropriate reversal
- [ ] Verify g_content propagation at the reversal point: at the reversal, we go from `v_k` to `v_{k-1}`. Since `hintikka_step v_{k-1} v_k` holds, H-backward gives `h_content(v_k) subset v_{k-1}`. And `hintikka_step v_{k-1} v_k` also gives `g_content(v_{k-1}) subset v_k`. So the reversal IS compatible: it is the backward step.
- [ ] Define `qm_fmcs` from the palindromic chain
- [ ] Define `qm_bfmcs` with modal families (one family per modally equivalent MCS)
- [ ] Prove restricted_tc on the palindromic chain
- [ ] Prove restricted_buc using restricted_tc as prerequisite
- [ ] Prove restricted_fuc using restricted_tc + BX9
- [ ] Wire into dd_countermodel

**Timing**: 3 hours

**Depends on**: 5 (conditional on Path A failure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add qm_bfmcs construction, close sorries
- Possibly new helper file for palindromic chain utilities

**Verification**:
- If successful: all sorry sites closed, `lake build` succeeds
- If unsuccessful: record specific obstruction

---

### Phase 7: Path B Evaluation and Final Assessment [NOT STARTED]

**Goal**: Assess Path B results and provide comprehensive assessment of all three paths.

**Tasks**:
- [ ] If Path B succeeded:
  - Verify all sorry sites closed
  - Run `lake build` and `#print axioms` verification
  - Update ROAD_MAP.md: mark Path B as successful
- [ ] If Path B failed:
  - Record the specific mathematical obstruction
  - Update ROAD_MAP.md with dead end #36 (Path B failure specifics)
  - Write comprehensive assessment: all three paths attempted and failed, the irreducible core (Lindenbaum defect-monotonicity) blocks all known approaches
  - Recommend next steps: fundamental rethinking of the chain construction, or investigating an entirely different completeness proof strategy
- [ ] Final ROAD_MAP.md update: comprehensive summary of all three attempts with confidence-adjusted assessments

**Timing**: 1 hour

**Depends on**: 6

**Files to modify**:
- `specs/ROAD_MAP.md` -- final comprehensive update

**Verification**:
- ROAD_MAP.md contains complete assessment of all attempted paths
- Each path has a definitive success/failure classification with evidence
- Clear recommendation for next steps

---

## Testing & Validation

- [ ] `lake build` succeeds after Phase 1 (ROAD_MAP.md only, no code changes)
- [ ] After each path attempt: `lake build` to verify no regressions
- [ ] If any path succeeds: `lean_verify` on `dd_countermodel` -- no sorry dependency
- [ ] If any path succeeds: `lean_verify` on `bx_completeness` -- only `propext`, `Classical.choice`, `Quot.sound`
- [ ] ROAD_MAP.md updated after each evaluation phase with definitive findings

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/44_bxcanonical-embedding.md` -- this plan
- `specs/ROAD_MAP.md` -- progressively updated with findings from each path attempt
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- sorry-free coherence proofs (if any path succeeds)

## Rollback/Contingency

1. **Phase 1 safe**: ROAD_MAP.md updates only, no code changes.

2. **Path C rollback**: If the pigeonhole proof attempt leaves partial sorry-free code that breaks other things, `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` restores current state. Partial proofs that compile but don't close the sorry can be preserved.

3. **Path A rollback**: Oracle chain replacement modifies chain construction. If it breaks, revert RootScopedChain.lean. The oracle infrastructure in OracleStep.lean is read-only for this path.

4. **Path B rollback**: Quasimodel BFMCS is additive (new definitions). If it fails, remove the new definitions. The existing dd_bfmcs remains untouched until the new one is proved correct.

5. **Complete failure**: All ROAD_MAP.md updates are preserved regardless. The comprehensive failure analysis is the primary deliverable in this case, narrowing the search space for future attempts.
