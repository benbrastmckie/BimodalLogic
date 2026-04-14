# Implementation Plan: Close BXCanonical Embedding (v16 -- Post-3-Cycle Revision)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 20 hours
- **Dependencies**: None (v14 Phase 1 infrastructure complete; quasimodel/filtration closed all Frame.lean sorries)
- **Research Inputs**: reports/16_team-research.md, reports/15_team-research.md, handoffs/02_forward-F-analysis.md, handoffs/01_phase1-partial.md
- **Artifacts**: plans/16_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Six sorry sites remain in `RootScopedChain.lean`, all downstream of a single primary blocker: `rr_fwd_chain_forward_F` (line 1192). Plan v15 assumed BX11-earliest elements always exist, but Report 16 proved this false -- `bx11_earlier` admits 3-cycles, so no global minimum may exist among F-defects. This plan revises the strategy: instead of finding a BX11-minimum at each step, we investigate whether the existing round-robin chain already guarantees eventual resolution via a contradiction argument (Strategy C from Report 16), with Strategy A (acyclicity proof) as a fast-check gate. Phase 0 updates ROAD_MAP.md with all dead ends discovered. Definition of done: `lake build` succeeds with zero sorry in RootScopedChain.lean (or documented partial progress with the precise mathematical gap), ROAD_MAP.md updated with comprehensive dead-end documentation and current status.

### Research Integration

- **Report 16** (4-teammate consensus): Discovered the 3-cycle counterexample invalidating Plan v15's core assumption. Confirmed the ordered discharge framework is the ONLY viable approach (6 alternatives rejected). Identified Strategy C (direct witness contradiction argument on existing chain) as most promising (60% confidence). Corrected the ψ->F(ψ) derivation: uses BX8+BX10 (not temp_t contrapositive). F-obligation set is exactly constant across chain steps.
- **Report 15**: Original identification of BX11 Case 3 hijacking obstruction and `target_stays_direct_in_fold` solution.
- **Handoff 02**: Detailed analysis of why counting argument fails, why BX11 is non-transitive, and four proposed approaches.
- **Handoff 01**: Documents the proved infrastructure (`target_stays_direct_in_fold`, `bx11_earlier_resolving_seed_strong`) and the remaining blocker.

### Prior Plan Reference

Plan v15 (28 hours, 7 phases) was never fully executed beyond Phase 1 (partial). Key lessons learned: (a) the assumption "find BX11-earliest defect" is unsatisfiable due to 3-cycles; (b) defect count does NOT strictly decrease -- non-defects can become defects when Lindenbaum drops them; (c) the ROAD_MAP.md update was placed last (Phase 7) and should be first to capture dead ends before implementation; (d) effort estimates were too optimistic for novel mathematical arguments. The proved infrastructure from v14 Phase 1 (16 sorry-free lemmas) remains fully valid and is the foundation for this plan.

### Roadmap Alignment

- Advances the sole remaining active-path sorry blocking `bx_completeness` at Completeness.lean (now wired through `dd_countermodel`)
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN toward DONE
- Would unblock task 95 (`#print axioms` audit on `bx_completeness`)
- Phase 0 updates ROAD_MAP.md with comprehensive dead-end documentation (items 13-21)

## Goals & Non-Goals

**Goals**:
- Update ROAD_MAP.md with all dead ends from task 93 (reports 13-16, handoffs 01-15)
- Update ROAD_MAP.md to clarify what has been achieved so far and what remains
- Resolve the 3-cycle question: either prove `bx11_earlier` acyclicity (Strategy A) or establish the direct witness contradiction argument (Strategy C)
- Close `rr_fwd_chain_forward_F` (line 1192) via the successful strategy
- Close `dd_fmcs_forward_F` negative-t case (line 1223) and `dd_fmcs_backward_P` (line 1230)
- Close the three restricted coherence theorems (lines 1283, 1288, 1293)
- Achieve `lake build` with zero sorry in RootScopedChain.lean
- If any sorry remains, document the precise mathematical gap with references

**Non-Goals**:
- Modifying CanonicalModel.lean (dead code, not on active path)
- Modifying OrderedSeedConsistency.lean (sorry-free, complete)
- Modifying lines 1-1100 of RootScopedChain.lean (proved infrastructure)
- Proving unrestricted coherence properties (restricted suffices)
- Dense time completeness (task 68, independent)
- Closing CanonicalModel.lean's 8 sorry sites (dead code, separate from active path)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Strategy A fails (bx11_earlier has genuine 3-cycles in MCS) | M | H (50%) | Gate check capped at 3 hours. If fails, immediately pivot to Strategy C. The semantic counterexample from Report 16 makes failure likely. |
| Strategy C direct witness argument has a gap | H | M (40%) | The argument that "permanent displacement leads to contradiction" is novel and unproven. If gap found, document precisely and spawn research task. |
| Backward chain lacks enriched step infrastructure | H | M (35%) | `dd_fmcs_backward_P` requires symmetric infrastructure to forward. May need to build `enriched_bwd_step` or find asymmetric approach via h_content propagation to M_0 then forward chain. |
| `restricted_buc` (backward Until/Since coherence) has no known approach | H | H (55%) | Independent of other 5 sorries. Capped at 2 hours. If blocked, close 5 of 6 (substantial result) and spawn dedicated task. |
| Chain replacement requires re-proving ~30 downstream theorems | H | M (30%) | Strategy C avoids chain replacement by working with existing `rr_fwd_chain`. Only needed if Strategy A succeeds and we build `ordered_fwd_chain`. |
| Lean formalization overhead exceeds estimates | M | M (25%) | Extensive sorry-free infrastructure already exists. Use `lean_goal` + `lean_multi_attempt` for rapid iteration. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2 | 1 |
| 4 | 3, 4 | 2 |
| 5 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 0: ROAD_MAP.md Comprehensive Update [NOT STARTED]

**Goal**: Document all dead ends discovered during task 93 (rounds 13-16), clarify what has been achieved, what remains, and the current mathematical understanding of the obstruction. This captures institutional knowledge before any further implementation attempts.

**Tasks**:
- [ ] Add dead ends 13-21 to the "Dead Ends (Archived)" section of `specs/ROAD_MAP.md`:
  - 13. **G(neg psi) impossibility**: `G(neg psi) in M` does NOT imply `F(psi) not in M` in the forward chain. No backward G-propagation mechanism. (Report 15, all 4 teammates)
  - 14. **f_carry seed enrichment**: Seed `{target} union g_content(M) union f_carry(M)` is provably inconsistent -- `G(F(chi))` not derivable from `F(chi)`, and Boneyard Task 69 has a concrete counterexample. (Report 14, confirmed Report 16 Teammate B)
  - 15. **Dovetailing (Goldblatt omega^2 indexing)**: Same F-preservation problem as round-robin; `omega^2` indexing adds complexity without solving the BX11 Case 3 hijacking. (Report 15, Teammate B)
  - 16. **Quasimodel-to-Int bridge**: `sigma_le` incompatible with `g_content`; finite Hintikka chains cannot form global FMCS over `Int`. (Report 15, Teammate B)
  - 17. **Zorn/Compactness**: `forward_F` is `Sigma_1` (existential), not preserved by directed limits. (Report 15, Teammate B)
  - 18. **Identity tail for F**: F is strict future (`s > t`), so `F(psi) in terminal` with `psi in terminal` does not discharge `F(psi)` obligation (needs strict future witness). (Report 14, Teammate C)
  - 19. **Scheduling induction / defect counting**: Defect count is non-monotonic across steps -- resolved formulas can be lost at subsequent Lindenbaum steps, creating new defects from former non-defects. F-obligation set is constant but defect/non-defect status oscillates. (Reports 14-16)
  - 20. **Round-robin disjunction**: `enriched_fwd_step_resolves_one` guarantees SOME formula resolved but BX11 Case 3 can hijack the scheduled target's direct witness slot when another formula has an earlier BX11 witness. (Report 15, precise obstruction)
  - 21. **BX11-earliest assumption**: `bx11_earlier` is total but NOT transitive; admits 3-cycles. Finding a global BX11-minimum over 3+ defects is impossible when cycles exist. Semantic counterexample: `a` at `{1,4}`, `b` at `{2}`, `c` at `{3}` produces `a > b > c > a` cycle. Plan v15 Phase 2 was invalidated by this discovery. (Report 16, Teammate A)
- [ ] Update the "Active-Path Sorry Inventory" section: 6 sorry sites in RootScopedChain.lean (lines 1192, 1223, 1230, 1283, 1288, 1293), all downstream of `rr_fwd_chain_forward_F`
- [ ] Update the Task Cross-Reference section: task 93 status to `[PLANNING]`, add note about 3-cycle discovery and strategy revision
- [ ] Add a new section "Task 93: Mathematical Obstruction Analysis" documenting:
  - The proved infrastructure (16 sorry-free lemmas from v14 Phase 1)
  - The 3-cycle counterexample and its consequences
  - The F-obligation constancy proof (BX8+BX10, not temp_t)
  - The corrected derivation of `psi -> F(psi)`: BX8 (`psi -> (top U psi)`) + BX10 (`(top U psi) -> F(psi)`)
  - Why this would be the first Lean 4 formalization of temporal logic completeness (publishable at ITP/CPP)
  - The two remaining viable strategies (A: acyclicity, C: direct witness contradiction)
- [ ] Update line counts and sorry count in the module import graph section

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `specs/ROAD_MAP.md` -- add dead ends 13-21, update sorry inventory, update task cross-reference, add obstruction analysis section

**Verification**:
- Dead ends 13-21 present in ROAD_MAP.md
- Sorry inventory correctly lists 6 sorry sites in RootScopedChain.lean
- Task 93 cross-reference updated
- Mathematical obstruction section documents the 3-cycle problem

---

### Phase 1: Strategy A Gate Check -- BX11 Acyclicity [NOT STARTED]

**Goal**: Determine definitively whether `bx11_earlier` (strict part) is acyclic on finite sets within an MCS. If acyclic, the rest of Plan v15's approach works with topological sort giving a minimum. If cyclic (as the semantic counterexample suggests), close this strategy and proceed to Strategy C.

**Tasks**:
- [ ] Formalize the strict part of `bx11_earlier`: define `bx11_strict M a b := bx11_earlier M a b AND NOT bx11_earlier M b a`
- [ ] Attempt to prove `bx11_strict` is acyclic: for any finite list `[a1, ..., an]` of formulas in sigma_list with `F(ai) in M`, there is no cycle `bx11_strict M a1 a2, bx11_strict M a2 a3, ..., bx11_strict M an a1`
- [ ] If acyclicity proof succeeds: prove existence of a minimum element via topological sort on finite sets. This enables `target_stays_direct_in_fold` to be applied at every step.
- [ ] If acyclicity proof fails (expected): attempt to construct a concrete 3-cycle in Lean (3 formulas in an MCS exhibiting the cycle). If construction succeeds, Strategy A is definitively dead. If neither proof nor counterexample is achievable within the time cap, document the gap and proceed to Strategy C.
- [ ] Record findings in a brief analysis comment in RootScopedChain.lean (whether acyclic or cyclic)

**Timing**: 3 hours (HARD CAP -- pivot to Phase 2 regardless of outcome)

**Depends on**: 0

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add acyclicity investigation (definitions and attempted proof or counterexample)

**Verification**:
- Clear determination: acyclic (proceed with ordered discharge) OR cyclic/unknown (proceed to Strategy C)
- `lake build` succeeds (no new sorry introduced)
- If acyclic: minimum-existence theorem proved
- If cyclic: counterexample or documentation of why proof fails

---

### Phase 2: Close rr_fwd_chain_forward_F [NOT STARTED]

**Goal**: Prove `rr_fwd_chain_forward_F`: `F(psi) in chain(n)` implies `psi in chain(s)` for some `s > n`. The approach depends on Phase 1 outcome.

**Tasks (if Phase 1 succeeds -- Strategy A path)**:
- [ ] Define `ordered_fwd_chain` using `target_stays_direct_in_fold` with topological-sort minimum at each step
- [ ] Prove each step resolves the minimum defect directly (never F-wrapped)
- [ ] Prove defect count strictly decreases by 1 per step (minimum removed, no new defects via `no_new_f_defects`)
- [ ] Prove terminal is defect-free after `|sigma_list|` steps
- [ ] Wire into `rr_fwd_chain_forward_F` or replace the chain and re-prove downstream

**Tasks (if Phase 1 fails -- Strategy C path, primary)**:
- [ ] Formalize the contradiction argument: assume `psi` is NEVER resolved (for all `s > n`, `psi not in chain(s)`)
- [ ] Show this implies `F(psi) in chain(m)` for ALL `m >= n` (F-obligation persistence, proved via `rr_fwd_chain_F_propagate`)
- [ ] Analyze what happens at each step where `psi` participates in the BX11 fold: some other formula `w` is resolved instead of `psi` (by Case 3 displacement)
- [ ] Investigate the structural constraint: if `psi` is permanently displaced, then at every step containing `F(psi)`, there exists `chi` with `bx11_earlier M_step chi psi`. By `bx11_earlier_total`, this means `NOT bx11_earlier M_step psi chi`. Analyze whether the set of displacing formulas exhausts sigma_list.
- [ ] Alternative sub-strategy: use `enriched_fwd_step_preserves` (proved) which gives `psi in M' OR F(psi) in M'` at EVERY step. At psi's round-robin visit step, psi IS the scheduled formula. Show that at the visit step, the enriched fold structure forces resolution.
- [ ] If Strategy C succeeds: close the sorry at line 1192
- [ ] If Strategy C has a gap: document the precise gap, spawn research task for novel mathematical investigation

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at line 1192 with proof (or add new chain definitions + proof)

**Verification**:
- `rr_fwd_chain_forward_F` has no sorry (or gap documented)
- `lake build` succeeds
- Downstream theorems (`dd_fmcs_forward_F` t >= 0 case) still compile

---

### Phase 3: Close dd_fmcs_forward_F (t < 0) and dd_fmcs_backward_P [NOT STARTED]

**Goal**: Close the two remaining temporal propagation sorries: the negative-t case of `dd_fmcs_forward_F` (line 1223) and `dd_fmcs_backward_P` (line 1230).

**Tasks**:
- [ ] **dd_fmcs_forward_F t < 0 case** (line 1223): `F(psi) in dd_chain(t)` for `t < 0` means `F(psi)` is in the backward chain. Approach: show `F(psi)` propagates to `M_0` (the junction point at `t = 0`). The backward chain preserves `h_content` (H-formulas). If `H(F(psi)) in dd_chain(t)`, then `F(psi)` propagates to `M_0` via h_content. If `H(F(psi))` is not guaranteed, investigate: (a) whether `F(psi) in M_t` implies `F(psi) in M_0` via backward chain properties; (b) whether `F(psi)` as an MCS member survives backward propagation via `bx_le` transitivity to `M_0`.
- [ ] Once `F(psi) in M_0` is established, use `rr_fwd_chain_forward_F` (Phase 2) on the forward chain to find `s > 0` with `psi in chain(s)`, giving `s > t` (since `t < 0`).
- [ ] **dd_fmcs_backward_P** (line 1230): Symmetric structure. P(psi) in dd_fmcs at time t implies psi at some s < t. For `t <= 0` (backward chain domain): define or use backward enriched step with h_content propagation and P-defect discharge. The backward chain uses `bwd_pred` (not enriched); investigate whether existing `rr_bwd_chain` properties suffice or whether `enriched_bwd_step` must be built.
- [ ] For `t > 0` (forward chain domain): P(psi) in forward chain. Show P(psi) propagates to M_0 via h_content (the forward chain preserves g_content, not h_content directly). Investigate whether `H(P(psi)) = H(P(psi))` can be used, or whether the backward chain from M_0 provides the witness.

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at lines 1223 and 1230

**Verification**:
- `dd_fmcs_forward_F` has no sorry (both t >= 0 and t < 0 cases closed)
- `dd_fmcs_backward_P` has no sorry
- `lake build` succeeds

---

### Phase 4: Close restricted coherence theorems [NOT STARTED]

**Goal**: Close the three restricted coherence sorry sites: `dd_bfmcs_restricted_tc` (line 1283), `dd_bfmcs_restricted_buc` (line 1288), and `dd_bfmcs_restricted_fuc` (line 1293).

**Tasks**:
- [ ] **dd_bfmcs_restricted_tc** (line 1283): Restricted temporal coherence for formulas in `deferralClosure(root)`. Delegate to:
  - G(phi) in fam.mcs(t) implies phi in fam.mcs(t+1): by `dd_chain_g_content` (proved)
  - H(phi) in fam.mcs(t) implies phi in fam.mcs(t-1): by `dd_chain_h_content` (proved)
  - F(phi) in fam.mcs(t) implies phi in fam.mcs(s) for s > t: by `dd_fmcs_forward_F` (Phase 2+3)
  - P(phi) in fam.mcs(t) implies phi in fam.mcs(s) for s < t: by `dd_fmcs_backward_P` (Phase 3)
- [ ] **dd_bfmcs_restricted_fuc** (line 1293): Forward Until/Since coherence. For `(phi U psi) in fam.mcs(t)`:
  - `F(psi) in fam.mcs(t)` by BX10 (`until_F`)
  - `psi in fam.mcs(s)` for some `s > t` by `dd_fmcs_forward_F`
  - Persistence of `(phi U psi)` through `[t, s)` by BX5 (`self_accum_until`) + BX9 (`until_elim`)
  - `phi` holds on `[t, s)` by BX9 extraction
  - For Since direction: symmetric using `dd_fmcs_backward_P`
- [ ] **dd_bfmcs_restricted_buc** (line 1288): Backward Until/Since coherence. This is the HARDEST sorry and may not have a known approach. Attempt:
  - Primary: extend resolving seed to include Until formulas, using BX10 to subsume Under F-ordering
  - Secondary: derive backward Until step transfer from h_content propagation + BX5'/BX9'/BX10' axioms
  - Fallback: if blocked after 2 hours, mark with sorry and detailed documentation. Spawn task for focused investigation. Closing 5 of 6 sorries is a substantial result.

**Timing**: 4 hours (2 hours for tc + fuc, 2 hours capped for buc)

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at lines 1283, 1288, 1293

**Verification**:
- `dd_bfmcs_restricted_tc` has no sorry
- `dd_bfmcs_restricted_fuc` has no sorry
- `dd_bfmcs_restricted_buc` has no sorry (or documented sorry with obstacle analysis)
- `lake build` succeeds

---

### Phase 5: Final Verification and ROAD_MAP.md Completion [NOT STARTED]

**Goal**: Verify all sorry closures, update ROAD_MAP.md with final status, and run axiom audit.

**Tasks**:
- [ ] Run `lake build` from clean state and verify zero errors
- [ ] Run `grep -n sorry RootScopedChain.lean` and verify zero matches (or only documented backward Until sorry)
- [ ] Run `#print axioms dd_countermodel` via `lean_verify` and verify no sorry-dependent axioms
- [ ] If all 6 sorries closed: run `#print axioms bx_completeness` and verify only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Update ROAD_MAP.md:
  - Update sorry inventory to reflect closed sorries
  - Update task 93 status in cross-reference to `[COMPLETED]` or `[PARTIAL]`
  - If all 6 closed: update "Active-path sorry summary" to 0 sorry
  - Add docstrings to new definitions referencing Burgess 1984 / Goldblatt 1992
- [ ] Add summary comment at top of RootScopedChain.lean documenting the approach that succeeded

**Timing**: 1 hour

**Depends on**: 3, 4

**Files to modify**:
- `specs/ROAD_MAP.md` -- update sorry inventory, task cross-reference, active-path summary
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add docstrings and summary comment

**Verification**:
- `lake build` succeeds with zero errors
- Sorry count is 0 (or 1 if backward Until fallback)
- ROAD_MAP.md accurately reflects current state
- Axiom audit clean

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero matches (or only the documented backward Until sorry)
- [ ] `#print axioms dd_countermodel` shows no sorry-dependent axioms
- [ ] `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound` (if all 6 closed)
- [ ] No new sorry introduced in any file
- [ ] `dd_countermodel` theorem compiles end-to-end
- [ ] ROAD_MAP.md dead ends section updated with task 93 entries (13-21)
- [ ] ROAD_MAP.md task cross-reference section reflects current status
- [ ] ROAD_MAP.md obstruction analysis section documents the 3-cycle problem and corrected derivations

## Artifacts & Outputs

- `specs/ROAD_MAP.md` -- updated (dead ends 13-21, sorry inventory, task cross-reference, obstruction analysis)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- modified (sorry sites replaced with proofs)
- `specs/093_complete_bxcanonical_embedding/plans/16_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

Changes are confined to `RootScopedChain.lean` (lines 1100+) and `specs/ROAD_MAP.md`.

1. **Phase 0 (ROAD_MAP.md) is independent**: Can be committed separately regardless of implementation outcome. Dead-end documentation has permanent value.

2. **Strategy A fails, Strategy C succeeds**: This is the expected path. No rollback needed -- Strategy C works with the existing chain.

3. **Both Strategy A and C fail**: Document the precise mathematical gap. The proved infrastructure (16 sorry-free lemmas including `target_stays_direct_in_fold`) remains valid. Spawn a dedicated research task for novel mathematical investigation of the BX11 ordering obstruction. This gap would be a genuine open problem in the formalization of temporal logic completeness.

4. **Partial success (5 of 6 sorries closed)**: Keep all proved theorems. The `restricted_buc` sorry (line 1288) is independent of the other 5. Document obstacle and spawn task. This is a substantial and publishable result -- the first Lean 4 formalization of temporal logic completeness up to the backward Until coherence gap.

5. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` restores the 6-sorry state. ROAD_MAP.md changes are committed independently.
