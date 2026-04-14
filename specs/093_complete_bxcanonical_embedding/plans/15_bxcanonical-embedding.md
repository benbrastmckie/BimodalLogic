# Implementation Plan: Close BXCanonical Embedding (v15 -- Ordered Discharge with target_stays_direct_in_fold)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 28 hours
- **Dependencies**: None (Phase 1 of v14 completed: 16 sorry-free lemmas including bx11_earlier_total, discharge_single_step, enriched_fwd_fold_with_witness)
- **Research Inputs**: reports/15_team-research.md, reports/14_team-research.md, reports/13_long-term-solution.md
- **Artifacts**: plans/15_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Six sorry sites remain in `RootScopedChain.lean` (lines 1139, 1170, 1177, 1230, 1235, 1240), all downstream of a single primary blocker: `rr_fwd_chain_forward_F` (line 1139). Report 15 (4-teammate consensus) identified the precise obstruction -- BX11 Case 3 can hijack the direct witness slot when another formula has an earlier BX11 witness -- and the exact fix: prove `target_stays_direct_in_fold` to guarantee that the BX11-earliest defect is always directly resolved (never F-wrapped). This plan supersedes v14 with the refined approach, adds a phase for ROAD_MAP.md documentation of failed attempts, and isolates the high-risk `restricted_buc` (45% confidence) into a separate phase with spawn-task fallback. Definition of done: `lake build` succeeds with zero sorry in RootScopedChain.lean, ROAD_MAP.md updated with task 93 dead ends, and `bx_completeness` at Completeness.lean:154 closed.

### Research Integration

- **Report 15** (team-research.md): All 4 teammates converge on `target_stays_direct_in_fold` as the key ~50-80 LOC theorem. The precise obstruction: `enriched_fwd_step_resolves_one` guarantees SOME formula is resolved at each step, but BX11 Case 3 can fire when another formula chi has an earlier witness, hijacking the direct slot from the scheduled target. Fix: use BX11-earliest defect as fold target; when target has earliest witness, only Cases 1 or 2 fire. Eight alternative approaches definitively rejected (G(neg psi) impossibility, f_carry seed enrichment, dovetailing, quasimodel-to-Int bridge, Zorn/Compactness, identity tail, scheduling induction, round-robin disjunction).
- **Report 14** (team-research.md): Original identification of ordered defect-discharge approach. Confirmed by Report 15 as correct but now refined with the precise obstruction analysis.
- **Report 13** (long-term-solution.md): Original OrderedSeedConsistency architecture, all foundational lemmas proved.

### Prior Plan Reference

Plan v14 (22 hours, 6 phases) was partially executed. Phase 1 COMPLETED: 16 sorry-free lemmas including `bx11_earlier_total`, `discharge_single_step`, `discharge_two_step`, `discharge_multi_step`, `activeDefects`, `rr_fwd_chain_F_preserved`, `rr_fwd_chain_F_propagate`. Phase 2 PARTIAL: `rr_fwd_chain_forward_F` still sorry -- the BX11 Case 3 obstruction was not understood until Report 15. Key lessons: (a) the round-robin disjunction problem is the core obstruction; (b) `enriched_fwd_step_resolves_one` is necessary but insufficient -- the resolved formula may not be the target; (c) v14 did not include a ROAD_MAP.md update phase; (d) effort estimates for the chain restructuring were underestimated. This plan builds directly on v14's completed infrastructure.

### Roadmap Alignment

- Closes the sole remaining active-path sorry blocking `bx_completeness` at Completeness.lean:154
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN to DONE
- Unblocks task 95 (`#print axioms` audit on `bx_completeness`)
- Updates ROAD_MAP.md section "Dead Ends" with 8 failed approaches from task 93

## Goals & Non-Goals

**Goals**:
- Prove `target_stays_direct_in_fold`: when fold target has BX11-earliest witness, Case 3 never fires
- Define `ordered_discharge_step` using `target_stays_direct_in_fold` to guarantee direct resolution of earliest defect
- Close `rr_fwd_chain_forward_F` (line 1139) via ordered discharge chain with defect-free terminal
- Close `dd_fmcs_forward_F` negative-t case (line 1170)
- Close `dd_fmcs_backward_P` (line 1177) symmetrically via h_content and P-defects
- Close `dd_bfmcs_restricted_tc` (line 1230) via forward_F + backward_P
- Close `dd_bfmcs_restricted_fuc` (line 1240) via forward_F + BX9/BX10
- Close `dd_bfmcs_restricted_buc` (line 1235) or document precise obstacle and spawn sub-task
- Update ROAD_MAP.md with failed approaches and current status
- Achieve `lake build` with zero sorry in RootScopedChain.lean

**Non-Goals**:
- Modifying OrderedSeedConsistency.lean (completed, 0 sorry)
- Modifying lines 1-884 of RootScopedChain.lean (fully proved infrastructure from v14 Phase 1)
- Removing old `rr_fwd_chain` definitions (keep as infrastructure; they are used by discharge_fwd_chain)
- Proving unrestricted coherence properties (restricted suffices for completeness)
- Dense time completeness (separate task 68)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `target_stays_direct_in_fold` formalization harder than expected: induction over fold requires tracking BX11-earliest property through each step | H | M (20%) | Sound semantic argument from Report 15. Build on existing `enriched_fwd_fold_with_witness` which already tracks witness through fold. Start with 2-element base case (`discharge_two_step` already proved), then generalize. |
| Defect-free terminal proof: counting argument (each step resolves earliest, defect count strictly decreases by 1) may need careful formalization of "target eventually becomes earliest" | M | M (25%) | Use `no_new_f_defects` (proved) to bound defect set. Fixed-length chain with `sigma_list.length` steps via `Nat.rec` avoids well-founded recursion. Pigeonhole: after |sigma| steps, every formula targeted at least once. |
| Backward Until coherence (`restricted_buc`, sorry #5) has no known syntactic proof | H | H (55%) | Independent of other 5 sorries. Primary: extend seed consistency to include Until formulas (Path C). Fallback: prove with sorry and spawn task 96. Closing 5 of 6 sorries is substantial. |
| t < 0 case of `dd_fmcs_forward_F` (sorry #2): backward chain does NOT preserve F-formulas, and G(F(psi)) not guaranteed | M | M (30%) | Approach: F(psi) in dd_chain(t) for t < 0 means F(psi) in rr_bwd_chain. Show F(psi) in M_0 via bwd_chain properties (bwd_chain at step 0 = M_0), then use forward chain forward_F from M_0. Alternative: check if `rr_bwd_chain_F_content` lemma exists. |
| Lean formalization overhead: compound extraction, MCS membership shuffling, subtype coercions | M | L (15%) | Extensive sorry-free infrastructure already exists. `enriched_resolving_seed_consistent`, `discharge_single_step`, `discharge_two_step` provide patterns to follow. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5, 6 | 2, 3 |
| 5 | 7 | 4, 5, 6 |

Phases within the same wave can execute in parallel.

### Phase 1: Prove target_stays_direct_in_fold and ordered_discharge_step [NOT STARTED]

**Goal**: Prove the key new theorem `target_stays_direct_in_fold` establishing that when the fold target has the BX11-earliest witness among all F-defects, BX11 Cases 1 or 2 always fire (never Case 3). Then define `ordered_discharge_step` that uses this to guarantee direct resolution of the earliest defect.

**Tasks**:
- [ ] Prove `target_stays_direct_in_fold`: by induction on the `others` list in the BX11 fold. At each fold step with accumulated compound `acc`, BX11 between `F(target and acc)` and `F(chi)` gives Cases 1-3. Since `h_earliest` says target's witness is at or before chi's witness, only Cases 1 or 2 fire. The result: `exists compound, F(target and compound) in M` where `target` appears as a direct conjunct (not under F). Build on `enriched_fwd_fold_with_witness` (line 280, proved) which already tracks witnesses through the fold. Estimated ~50-80 LOC.
- [ ] Define `ordered_discharge_step`: given MCS M with F-defects, find the BX11-earliest defect using `bx11_earlier_total` (line 912, proved), apply `target_stays_direct_in_fold` to get `F(target and compound) in M`, use `enriched_resolving_seed_consistent` to get consistent seed `{target, compound} union g_content(M)`, Lindenbaum-extend to M' with `target in M'` guaranteed (not disjunctive).
- [ ] Prove `ordered_discharge_step_target_in`: the BX11-earliest defect is directly in M' (from seed inclusion)
- [ ] Prove `ordered_discharge_step_g_content`: `g_content(M) subset M'`
- [ ] Prove `ordered_discharge_step_f_carry`: for each chi in sigma_list with F(chi) in M, either chi in M' or F(chi) in M' (from compound extraction via `bx11_earlier_resolving_seed`, line 928, proved)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add new definitions and lemmas after the existing `discharge_multi_step` (line 992), before `activeDefects` (line 994)

**Verification**:
- `lake build` succeeds (existing sorry sites unchanged)
- `target_stays_direct_in_fold` has no sorry
- `ordered_discharge_step_target_in` has no sorry

---

### Phase 2: Close rr_fwd_chain_forward_F (Line 1139) [NOT STARTED]

**Goal**: Prove `rr_fwd_chain_forward_F`: F(psi) in chain(n) implies psi in chain(s) for some s > n.

**Tasks**:
- [ ] Define `ordered_fwd_chain`: iterate `ordered_discharge_step` for `sigma_list.length` steps using `Nat.rec`, then identity tail (repeat terminal MCS for all indices beyond chain length). Each step resolves the BX11-earliest defect directly.
- [ ] Prove `ordered_fwd_chain_g_content`: g_content propagation at each step (follows from `ordered_discharge_step_g_content`)
- [ ] Prove terminal is defect-free: after `|sigma_list|` steps, all F-defects resolved. Counting argument: each step strictly decreases defect count by 1 (earliest defect is directly resolved, so it becomes non-defect; `no_new_f_defects` ensures no new defects appear). After `|sigma_list|` steps, defect count = 0.
- [ ] Prove `ordered_fwd_chain_forward_F`: F(psi) in chain(n) implies psi in chain(s) for some s > n. Two sub-cases: (a) n < |sigma_list|: psi is a defect, eventually becomes BX11-earliest at some step m >= n, `ordered_discharge_step` at m gives psi in chain(m+1). (b) n >= |sigma_list| (identity tail): chain(n) is defect-free terminal, F(psi) in terminal implies psi in terminal (by defect-free property + MCS closure via BX1 `temp_t_future`).
- [ ] Wire `ordered_fwd_chain_forward_F` into `rr_fwd_chain_forward_F` at line 1139. May require showing the two chains are equivalent for this purpose, or replacing the chain used in downstream theorems.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- define ordered_fwd_chain, prove forward_F, replace sorry at line 1139

**Verification**:
- `rr_fwd_chain_forward_F` has no sorry
- `lake build` succeeds
- Downstream theorems still compile (dd_fmcs_forward_F t >= 0 case, line 1155)

---

### Phase 3: Close dd_fmcs_backward_P (Line 1177) [NOT STARTED]

**Goal**: Prove `dd_fmcs_backward_P`: P(psi) in dd_fmcs at time t implies psi in dd_fmcs at some s < t. Symmetric to forward_F using h_content, P-formulas, and BX11' (past linearity).

**Tasks**:
- [ ] Define `ordered_bwd_step` and `ordered_bwd_chain`: symmetric to ordered_fwd using h_content instead of g_content, P-formulas instead of F-formulas, BX11' (`temp_linearity_past`) instead of BX11. Use existing `enriched_resolving_seed_consistent` past variant if available, or prove the symmetric version.
- [ ] Prove `ordered_bwd_chain_backward_P`: P(psi) in chain(n) implies psi in chain(s) for some s > n (in the backward Nat index, which corresponds to s < t in Int).
- [ ] Close `dd_fmcs_backward_P` sorry (line 1177): for t <= 0 (backward chain domain), delegate to `ordered_bwd_chain_backward_P`. For t > 0 (forward chain domain), propagate P(psi) via h_content to M_0, then use backward chain.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add backward chain definitions, replace sorry at line 1177

**Verification**:
- `dd_fmcs_backward_P` has no sorry
- `lake build` succeeds

---

### Phase 4: Close dd_fmcs_forward_F t < 0 case (Line 1170) [NOT STARTED]

**Goal**: Close the negative-t case of `dd_fmcs_forward_F`: when F(psi) is in the backward chain segment (t < 0).

**Tasks**:
- [ ] Analyze the backward chain (`rr_bwd_chain`) structure at t < 0. The backward chain uses h_content propagation. F(psi) in rr_bwd_chain at step k means F(psi) is in the backward MCS.
- [ ] Approach A: Show F(psi) in dd_chain(t) for t < 0 implies F(psi) in M_0 (dd_chain(0)). This requires either: (i) g_content propagation from bwd to fwd chain at the junction point, or (ii) showing F(psi) survives through the backward chain to M_0 via MCS properties.
- [ ] Approach B: If F(psi) does NOT propagate to M_0 directly, show that backward chain temporal coherence provides psi at some earlier backward step, then propagate via h_content to a later time.
- [ ] Close sorry at line 1170 with the chosen approach.

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at line 1170

**Verification**:
- `dd_fmcs_forward_F` has no sorry (both t >= 0 and t < 0 cases closed)
- `lake build` succeeds

---

### Phase 5: Close dd_bfmcs_restricted_tc and dd_bfmcs_restricted_fuc (Lines 1230, 1240) [NOT STARTED]

**Goal**: Prove restricted temporal coherence and forward Until coherence using the proved forward_F and backward_P.

**Tasks**:
- [ ] Prove `dd_bfmcs_restricted_tc` (line 1230): restricted temporal coherence for formulas in `deferralClosure(root)`. For each family in dd_bfmcs and formula phi in deferralClosure(root):
  - G(phi) in fam.mcs(t) implies phi in fam.mcs(t+1): by g_content propagation (already proved via `dd_chain_g_content`)
  - H(phi) in fam.mcs(t) implies phi in fam.mcs(t-1): by h_content propagation (already proved via `dd_chain_h_content`)
  - F(phi) in fam.mcs(t) implies phi in fam.mcs(s) for s > t: by `dd_fmcs_forward_F` (Phase 2/4)
  - P(phi) in fam.mcs(t) implies phi in fam.mcs(s) for s < t: by `dd_fmcs_backward_P` (Phase 3)
- [ ] Prove `dd_bfmcs_restricted_fuc` (line 1240): forward Until coherence. Given (phi U psi) in fam.mcs(t) with phi, psi in subformulaClosure(root):
  - (a) F(psi) in fam.mcs(t) by BX10 (`until_F`)
  - (b) psi in fam.mcs(s) for some s > t by `dd_fmcs_forward_F`
  - (c) (phi U psi) persists through [t, s) by BX5 (`self_accum_until`) + BX9 (`until_elim`)
  - (d) phi holds on [t, s) by BX9 extraction from the persisted (phi U psi)

**Timing**: 2 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at lines 1230 and 1240

**Verification**:
- `dd_bfmcs_restricted_tc` has no sorry
- `dd_bfmcs_restricted_fuc` has no sorry
- `lake build` succeeds

---

### Phase 6: Close dd_bfmcs_restricted_buc (Line 1235) [NOT STARTED]

**Goal**: Prove backward Until/Since coherence or document the precise remaining obstacle.

**Tasks**:
- [ ] Attempt primary approach (seed enrichment, Path C from Report 14): extend the resolving seed to include Until formulas from M. Prove the enriched seed `{target, compound, phi U psi for relevant Until formulas} union g_content(M)` is consistent using BX10 (`(phi U psi) -> F(psi)`) to subsume Until-witnesses under the F-ordering argument.
- [ ] If seed enrichment succeeds: prove backward Until step transfer -- `(phi S psi) in fam.mcs(t)` implies the Since witness exists at some s < t. This mirrors the forward Until coherence proof but in the backward direction with h_content propagation.
- [ ] If seed enrichment fails: attempt Path B (inductive descent) -- derive (phi S psi) backward preservation from h_content propagation + BX axioms for Since (BX5', BX6', BX9', BX10').
- [ ] If both fail: mark with sorry and detailed obstacle description. The other 5 sorry sites are independent and fully closed. Spawn task 96 for architectural investigation of backward Until coherence.

**Timing**: 2 hours (capped; spawn if blocked)

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at line 1235

**Verification**:
- `dd_bfmcs_restricted_buc` has no sorry (or documented sorry with obstacle analysis)
- `lake build` succeeds

---

### Phase 7: ROAD_MAP.md Update and Verification [NOT STARTED]

**Goal**: Update ROAD_MAP.md with task 93 failed approaches, current status, and clean verification of all sorry closures.

**Tasks**:
- [ ] Add new entries to ROAD_MAP.md "Dead Ends (Archived)" section documenting the 8 failed approaches from task 93:
  - 13. G(neg psi) impossibility: no backward G-propagation in forward chain (Report 15, all 4 teammates)
  - 14. f_carry seed enrichment: seed `{target} union g_content(M) union f_carry(M)` inconsistent -- G does not distribute over F-disjunction (Report 14)
  - 15. Dovetailing (Goldblatt omega^2): same F-preservation problem as round-robin; omega^2 indexing adds complexity without solving BX11 Case 3 hijacking (Report 15, Teammate B)
  - 16. Quasimodel-to-Int bridge: sigma_le incompatible with g_content; finite Hintikka chains cannot form global FMCS over Int (Report 15, Teammate B)
  - 17. Zorn/Compactness: forward_F is Sigma_1 (existential), not preserved by directed limits (Report 15, Teammate B)
  - 18. Identity tail for F: F is strict future, so F(psi) in terminal with psi in terminal does not discharge F(psi) obligation for strict-future witness (Report 14, Teammate C)
  - 19. Scheduling induction: defect count is non-monotonic across steps; resolved formulas can be lost at subsequent steps (Report 14)
  - 20. Round-robin disjunction: `enriched_fwd_step_resolves_one` guarantees SOME formula resolved but BX11 Case 3 hijacks the scheduled target's direct witness slot (Report 15, precise obstruction)
- [ ] Update ROAD_MAP.md task 93 entry in "Task Cross-Reference" section: status from `[NOT STARTED]` to `[COMPLETED]` (or `[PARTIAL]` if restricted_buc remains sorry)
- [ ] Update "Active-Path Sorry Inventory" section: sorry count and table
- [ ] Run `lake build` from clean state and verify zero errors
- [ ] Run `grep -n sorry RootScopedChain.lean` and verify zero matches (or only the documented backward Until sorry if Phase 6 used fallback)
- [ ] Run `#print axioms dd_countermodel` via lean_goal or lean_run_code and verify no sorry-dependent axioms
- [ ] If all 6 sorries closed: run `#print axioms bx_completeness` and verify only `propext`, `Classical.choice`, `Quot.sound`

**Timing**: 1 hour

**Depends on**: 4, 5, 6

**Files to modify**:
- `specs/ROAD_MAP.md` -- add dead ends 13-20, update task cross-reference and sorry inventory
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add docstrings to new definitions referencing Burgess 1984 / Goldblatt 1992 (if not already added in earlier phases)

**Verification**:
- `lake build` succeeds with zero errors
- Sorry count is 0 (or 1 if backward Until fallback)
- ROAD_MAP.md dead ends 13-20 present
- Axiom audit clean

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero matches (or only the documented backward Until sorry)
- [ ] `#print axioms dd_countermodel` shows no sorry-dependent axioms
- [ ] `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound` (if all 6 closed)
- [ ] No new sorry introduced in any file
- [ ] `dd_countermodel` theorem compiles end-to-end
- [ ] ROAD_MAP.md dead ends section updated with task 93 entries (13-20)
- [ ] ROAD_MAP.md task cross-reference section reflects current status

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- modified (sorry sites replaced with proofs)
- `specs/ROAD_MAP.md` -- updated (dead ends 13-20 added, task cross-reference updated)
- `specs/093_complete_bxcanonical_embedding/plans/15_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

The changes are confined to `RootScopedChain.lean` (lines 885+) and `specs/ROAD_MAP.md`. Lines 1-884 of RootScopedChain.lean are untouched.

1. **Partial success (5 of 6 sorries closed)**: Keep all proved theorems. The backward Until sorry (line 1235) is independent of the other 5. Document the obstacle in ROAD_MAP.md and spawn task 96 for focused architectural investigation. This is a substantial and publishable result.

2. **Forward_F approach fails**: If `target_stays_direct_in_fold` cannot be proved in Lean despite the sound semantic argument, revert to the existing `discharge_multi_step` + `rr_fwd_chain_F_propagate` infrastructure and document the specific Lean formalization obstacle for future investigation.

3. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` restores the 6-sorry state. ROAD_MAP.md changes can be reverted independently.
