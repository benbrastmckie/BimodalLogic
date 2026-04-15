# Implementation Plan: Close BXCanonical Embedding (v17 -- Strategy C Primary, Lessons-Informed)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: None (v14 Phase 1 infrastructure complete; quasimodel/filtration closed all Frame.lean sorries)
- **Research Inputs**: reports/17_round-robin-chain-history.md, reports/16_team-research.md, reports/15_team-research.md, handoffs/02_forward-F-analysis.md, handoffs/01_phase1-partial.md
- **Artifacts**: plans/17_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Six sorry sites remain in `RootScopedChain.lean` (lines 1192, 1223, 1230, 1283, 1288, 1293), all downstream of a single primary blocker: `rr_fwd_chain_forward_F` (line 1192). Plan v16 proposed a two-pronged approach: Strategy A (BX11 acyclicity gate check) then Strategy C (direct witness contradiction on existing chain). Report 17 (round-robin chain history) cataloged 19 failed approaches and confirmed Strategy C as the only remaining viable path. This v17 plan eliminates Strategy A entirely (the 3-cycle semantic counterexample makes it overwhelmingly likely to fail, and 3 hours is better spent on Strategy C), sharpens Strategy C with concrete attack vectors derived from the history analysis, and restructures phases to front-load the single hardest sorry before addressing dependents. Definition of done: `lake build` succeeds with zero sorry in RootScopedChain.lean (or documented partial progress with the precise mathematical gap), ROAD_MAP.md updated.

### Research Integration

- **Report 17** (round-robin-chain-history): Complete catalog of 19 failed approaches with precise failure reasons. Key lessons: (1) avoid replacing the chain (30+ theorem re-proofs), (2) the semantics-syntax gap is real (BX11 is weaker than semantic ordering), (3) time-cap all investigation phases, (4) F-obligation constancy (BX8+BX10) is the key structural fact, (5) backward Until is independent. Confirmed Strategy C at 60% confidence as the most promising remaining approach.
- **Report 16** (4-teammate consensus): 3-cycle counterexample invalidating Strategy A. Strategy C details: reduce forward_F to contradiction via `rr_fwd_chain_F_propagate`, then show permanent BX11 displacement leads to structural contradiction. F-obligation set exactly constant. Corrected psi->F(psi) derivation: BX8+BX10.
- **Report 15**: Original BX11 Case 3 hijacking analysis. `target_stays_direct_in_fold` solution.
- **Handoff 02**: BX11 non-transitivity, counting argument failure.
- **Handoff 01**: Proved infrastructure documentation.

### Prior Plan Reference

Plan v16 (20 hours, 6 phases) was never executed. It included a 3-hour Strategy A gate check (Phase 1) that Report 17 recommends eliminating -- the semantic counterexample (Report 16) makes BX11 acyclicity overwhelmingly unlikely to hold in MCS, and the 3-hour cap would be better invested in Strategy C. Plan v16 also included a 2-hour ROAD_MAP.md update phase (Phase 0) that this plan retains but moves to the end (after implementation) since the dead-end documentation has been captured in reports and the implementation outcome should be reflected. The proved infrastructure from v14 Phase 1 (16 sorry-free lemmas) remains fully valid.

### Roadmap Alignment

- Advances the sole remaining active-path sorry blocking `bx_completeness` at Completeness.lean (now wired through `dd_countermodel`)
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN toward DONE
- Would unblock task 95 (`#print axioms` audit on `bx_completeness`)

## Goals & Non-Goals

**Goals**:
- Close `rr_fwd_chain_forward_F` (line 1192) via Strategy C (direct witness contradiction argument on existing chain)
- Close `dd_fmcs_forward_F` negative-t case (line 1223) and `dd_fmcs_backward_P` (line 1230)
- Close the three restricted coherence theorems (lines 1283, 1288, 1293)
- Achieve `lake build` with zero sorry in RootScopedChain.lean
- Update ROAD_MAP.md with dead ends, sorry inventory, and outcome
- If any sorry remains, document the precise mathematical gap with references

**Non-Goals**:
- Modifying CanonicalModel.lean (dead code, not on active path)
- Modifying OrderedSeedConsistency.lean (sorry-free, complete)
- Modifying lines 1-1100 of RootScopedChain.lean (proved infrastructure)
- Attempting Strategy A (BX11 acyclicity) -- Report 17 recommends against this
- Replacing `rr_fwd_chain` with a new chain (Report 17 Lesson 2: avoid chain replacement)
- Proving unrestricted coherence properties (restricted suffices)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Strategy C direct witness argument has an unfillable mathematical gap | H | M (40%) | Cap investigation at 5 hours. The argument is novel -- no prior formalization addresses this specific syntactic obstruction. If gap found, document precisely and spawn research task. |
| Backward chain lacks enriched step infrastructure for backward_P | H | M (35%) | Report 16 flagged this. Approach: propagate to M_0 then use forward chain. If propagation path unclear, attempt `enriched_bwd_step` construction. Cap at 2 hours. |
| `restricted_buc` (backward Until/Since coherence) has no known approach | H | H (55%) | Independent of other 5 sorries. Cap at 2 hours. If blocked, close 5 of 6 (substantial publishable result) and spawn dedicated task. |
| Lean formalization overhead exceeds estimates | M | M (25%) | Extensive sorry-free infrastructure exists. Use `lean_goal` + `lean_multi_attempt` for rapid iteration. |
| Strategy C produces a valid proof but requires helper lemmas exceeding 200 LOC | M | M (30%) | The existing infrastructure (16 lemmas) handles most structural work. Focus on the minimal argument needed. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Close rr_fwd_chain_forward_F via Strategy C [IN PROGRESS]

**Goal**: Prove `rr_fwd_chain_forward_F` (line 1192): `F(psi) in chain(n)` implies `psi in chain(s)` for some `s > n`. Use the direct witness contradiction argument (Strategy C) on the existing round-robin chain.

**Tasks**:
- [ ] Formalize the contradiction assumption: assume `psi` is NEVER resolved (for all `s > n`, `psi not in chain(s)`)
- [ ] Use `rr_fwd_chain_F_propagate` (proved, line 1124) to establish: under the contradiction assumption, `F(psi) in chain(m)` for ALL `m >= n`
- [ ] Analyze psi's round-robin visit steps. At step `j + k * |sigma_list|` (where `j` is psi's index), psi IS the scheduled target and `F(psi) in chain(step)`. The enriched fold processes psi as the target.
- [ ] At the visit step, `enriched_fwd_step_resolves_one` (proved, line 622) guarantees some `w in M'`. Under our assumption `psi not in M'`, we know `w != psi`. Since `F(psi) in chain(step)` and psi is the target, the fold's BX11 structure determines which formula gets the direct slot.
- [ ] Key attack vector A (visit-step analysis): At psi's visit step, psi is the target of `enriched_fwd_step`. The fold processes `sigma_list.filter(...)`. Since psi is the target and `F(psi) in M`, the resolving step fires. The fold's direct witness is some `w`. If `w = psi`, we have our contradiction (psi in M'). So `w != psi`, meaning BX11 Case 3 fired: some chi in the fold had `bx11_earlier M_step chi psi`. Extract this chi and its BX11 witness structure.
- [ ] Key attack vector B (pigeonhole on sigma_list): The F-obligation set is exactly constant (Report 16 Part 2.1). There are `|O|` formulas with persistent F-obligations (where O = {chi | F(chi) in chain(0)}). At each step, `enriched_fwd_step_resolves_one` resolves at least one. Over `|O| * |sigma_list|` steps, at least `|O| * |sigma_list|` resolutions occur. By pigeonhole, some formula must be resolved at least `|sigma_list|` times. But there are only `|O|` distinct formulas. If psi is never resolved, the other `|O| - 1` formulas account for all resolutions. Over enough steps, the resolved formulas must cycle -- each resolved formula becomes a non-defect, but may become a defect again. The question is whether this cycling is compatible with psi being permanently displaced.
- [ ] Key attack vector C (discharge_single_step at visit): At psi's visit step, use `discharge_single_step` (proved, line 955) directly: this gives M' with `psi in M'` and `g_content(M) subset M'` but does NOT preserve other F-obligations. If we can show that losing other F-obligations at this ONE step is recoverable (because they will reappear via BX8+BX10 at subsequent steps), this might close the sorry. The key question: does `psi in chain(step+1)` suffice even if some F-obligations are temporarily lost? Yes -- `rr_fwd_chain_forward_F` only requires `psi in chain(s)` for SOME `s > n`. We only need ONE step where psi appears.
- [ ] If attack vector C works: the proof structure is by contradiction. Assume psi never appears. F(psi) persists to psi's next visit step (by F_propagate). At that step, use discharge_single_step to get M' with psi in M'. But wait -- `rr_fwd_chain` uses `enriched_fwd_step`, not `discharge_single_step`. The chain is already defined. We cannot choose a different step function at a specific index. We need to prove the property about the EXISTING chain, which uses `enriched_fwd_step` at every step.
- [ ] Refined approach: prove that `enriched_fwd_step` at psi's visit step, when `F(psi) in M` and psi is the target, MUST put psi in M'. This would mean: either psi is directly resolved (psi in M') or F(psi) in M' (and psi is NOT in M'). In the latter case, BX11 Case 3 fired. Investigate whether Case 3 firing when psi is the target leads to a provable contradiction or whether we can extract additional structural information.
- [ ] If Strategy C has a gap after 5 hours: document the precise gap, save all helper lemmas proved, and spawn a dedicated research task. Record the exact point where the argument breaks down.

**Timing**: 6 hours (HARD CAP at 5 hours for Strategy C proper, 1 hour for documentation if blocked)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at line 1192 with proof (or add helper lemmas and partial proof)

**Verification**:
- `rr_fwd_chain_forward_F` has no sorry (or gap documented with precise obstruction)
- `lake build` succeeds
- If proved: downstream theorems (`dd_fmcs_forward_F` t >= 0 case) still compile

---

### Phase 2: Close dd_fmcs_forward_F (t < 0) and dd_fmcs_backward_P [NOT STARTED]

**Goal**: Close the two remaining temporal propagation sorries: the negative-t case of `dd_fmcs_forward_F` (line 1223) and `dd_fmcs_backward_P` (line 1230).

**Tasks**:
- [ ] **dd_fmcs_forward_F t < 0 case** (line 1223): `F(psi) in dd_chain(t)` for `t < 0` means `F(psi)` is in the backward chain at index `(-t).toNat`. Approach: the backward chain is built from `bwd_pred` which preserves `h_content` (H-formulas). If `H(F(psi))` can be shown to be in `dd_chain(t)`, then h_content propagation carries `F(psi)` to `M_0` (junction point). Once `F(psi) in M_0`, use `rr_fwd_chain_forward_F` (Phase 1) to find `s > 0` with `psi in chain(s)`, giving `s > t` since `t < 0`.
- [ ] Investigate whether `H(F(psi)) in M` follows from `F(psi) in M` in an MCS. Check if `F(psi) -> H(F(psi))` is derivable. If not, look for alternative propagation: (a) `F(psi)` might be in the seed of intermediate backward steps; (b) `bwd_pred` might preserve `F(psi)` via `f_carry` (check the backward chain construction).
- [ ] Alternative approach: if `F(psi)` does not propagate to `M_0` directly, use the backward chain's temporal structure. The backward chain satisfies `h_content(chain(n)) subset chain(n-1)` for the backward direction. If `G(F(psi))` can be established (unlikely per Report 16), this gives propagation. Otherwise, investigate whether `F(psi) in bwd_chain(k)` implies `F(psi) in bwd_chain(0) = M_0` via the bwd_pred seed structure.
- [ ] **dd_fmcs_backward_P** (line 1230): Symmetric to forward_F. `P(psi) in dd_fmcs(t)` implies `psi in dd_fmcs(s)` for some `s < t`. Split by cases:
  - `t <= 0`: P(psi) in backward chain. The backward chain resolves P-obligations analogously to how the forward chain resolves F-obligations. Check if `rr_bwd_chain` has a `backward_P` property or if one needs to be built.
  - `t > 0`: P(psi) in forward chain. Need to find `s < t` with `psi in dd_chain(s)`. If `H(P(psi))` propagates backward via h_content to `M_0`, then use backward chain for witness. Otherwise, `P(psi) in M_0` (if propagated) gives backward chain witness.
- [ ] Check whether `bwd_pred` uses an enriched seed that preserves P-formulas (analogous to how `enriched_fwd_step` preserves F-formulas). If not, the backward chain may need `enriched_bwd_step` -- estimate construction cost.

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at lines 1223 and 1230

**Verification**:
- `dd_fmcs_forward_F` has no sorry (both t >= 0 and t < 0 cases closed)
- `dd_fmcs_backward_P` has no sorry
- `lake build` succeeds

---

### Phase 3: Close restricted coherence theorems [NOT STARTED]

**Goal**: Close the three restricted coherence sorry sites: `dd_bfmcs_restricted_tc` (line 1283), `dd_bfmcs_restricted_buc` (line 1288), and `dd_bfmcs_restricted_fuc` (line 1293).

**Tasks**:
- [ ] **dd_bfmcs_restricted_tc** (line 1283): Restricted temporal coherence for formulas in `deferralClosure(root)`. This delegates to four sub-cases:
  - G(phi) in fam.mcs(t) implies phi in fam.mcs(t+1): by `dd_chain_g_content` (proved)
  - H(phi) in fam.mcs(t) implies phi in fam.mcs(t-1): by `dd_chain_h_content` (proved)
  - F(phi) in fam.mcs(t) implies phi in fam.mcs(s) for s > t: by `dd_fmcs_forward_F` (Phase 1+2)
  - P(phi) in fam.mcs(t) implies phi in fam.mcs(s) for s < t: by `dd_fmcs_backward_P` (Phase 2)
- [ ] **dd_bfmcs_restricted_fuc** (line 1293): Forward Until/Since coherence. For `(phi U psi) in fam.mcs(t)`:
  - `F(psi) in fam.mcs(t)` by BX10 (`until_F` / `until_implies_some_future`)
  - `psi in fam.mcs(s)` for some `s > t` by `dd_fmcs_forward_F`
  - Persistence of `(phi U psi)` through `[t, s)` by BX5 (`self_accum_until`) + BX9 (`until_elim`)
  - `phi` holds on `[t, s)` by BX9 extraction
  - For Since direction: symmetric using `dd_fmcs_backward_P`
- [ ] **dd_bfmcs_restricted_buc** (line 1288): Backward Until/Since coherence. This is the HARDEST sorry (Report 17 Lesson 6: independent obstacle, 55% failure likelihood). Attempt:
  - Primary: derive backward Until step transfer from h_content propagation + BX5'/BX9'/BX10' axioms (the past-directed analogues)
  - Secondary: extend resolving seed to include Until formulas via BX10
  - Fallback: if blocked after 2 hours, mark with sorry and detailed documentation. Spawn task for focused investigation. Closing 5 of 6 sorries is a substantial publishable result.

**Timing**: 4 hours (2 hours for tc + fuc, 2 hours capped for buc)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at lines 1283, 1288, 1293

**Verification**:
- `dd_bfmcs_restricted_tc` has no sorry
- `dd_bfmcs_restricted_fuc` has no sorry
- `dd_bfmcs_restricted_buc` has no sorry (or documented sorry with obstacle analysis)
- `lake build` succeeds

---

### Phase 4: Final Verification and ROAD_MAP.md Update [NOT STARTED]

**Goal**: Verify all sorry closures, update ROAD_MAP.md with dead ends and final status, run axiom audit.

**Tasks**:
- [ ] Run `lake build` from clean state and verify zero errors
- [ ] Run `grep -n sorry RootScopedChain.lean` and verify zero matches (or only documented backward Until sorry)
- [ ] Run `#print axioms dd_countermodel` via `lean_verify` and verify no sorry-dependent axioms
- [ ] If all 6 sorries closed: run `#print axioms bx_completeness` and verify only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Update ROAD_MAP.md:
  - Add dead ends 13-21 to "Dead Ends (Archived)" section (from Report 17 catalog)
  - Update "Active-Path Sorry Inventory": 6 sorry sites in RootScopedChain.lean status
  - Update task 93 cross-reference to final status
  - Add "Task 93: Mathematical Obstruction Analysis" section documenting the 3-cycle problem, F-obligation constancy, corrected BX8+BX10 derivation, and the approach that succeeded
  - Update line counts and sorry count in module import graph
- [ ] Add summary comment at top of RootScopedChain.lean documenting the approach that succeeded
- [ ] Add docstrings to new definitions referencing Burgess 1984 / Goldblatt 1992

**Timing**: 2 hours

**Depends on**: 3, 4

**Files to modify**:
- `specs/ROAD_MAP.md` -- add dead ends 13-21, update sorry inventory, task cross-reference, obstruction analysis
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add docstrings and summary comment

**Verification**:
- `lake build` succeeds with zero errors
- Sorry count is 0 (or 1 if backward Until fallback)
- ROAD_MAP.md accurately reflects current state
- Axiom audit clean

---

### Phase 5: Contingency -- Spawn Tasks for Remaining Gaps [NOT STARTED]

**Goal**: If any sorry remains after Phases 1-4, create focused research/implementation tasks for each gap.

**Tasks**:
- [ ] If `rr_fwd_chain_forward_F` sorry remains: spawn task "Research novel syntactic argument for forward_F in BX temporal completeness" with detailed gap description from Phase 1 documentation
- [ ] If `dd_fmcs_backward_P` sorry remains: spawn task "Build enriched_bwd_step for backward P-obligation discharge" with Phase 2 analysis
- [ ] If `dd_bfmcs_restricted_buc` sorry remains: spawn task "Close backward Until/Since coherence for BX canonical model" with Phase 3 analysis
- [ ] Update ROAD_MAP.md with spawned task references
- [ ] Commit partial progress (any sorry-free lemmas proved in Phases 1-3 have permanent value)

**Timing**: 1 hour

**Depends on**: 3, 4

**Files to modify**:
- `specs/TODO.md` -- new tasks (if needed)
- `specs/state.json` -- new tasks (if needed)
- `specs/ROAD_MAP.md` -- spawned task references

**Verification**:
- Each remaining sorry has a corresponding spawned task
- All sorry-free lemmas from this round are committed
- ROAD_MAP.md reflects current state accurately

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero matches (or only documented sorry with obstacle analysis)
- [ ] `#print axioms dd_countermodel` shows no sorry-dependent axioms
- [ ] `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound` (if all 6 closed)
- [ ] No new sorry introduced in any file
- [ ] `dd_countermodel` theorem compiles end-to-end
- [ ] ROAD_MAP.md dead ends section updated with task 93 entries (13-21)
- [ ] ROAD_MAP.md task cross-reference section reflects current status

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- modified (sorry sites replaced with proofs)
- `specs/ROAD_MAP.md` -- updated (dead ends 13-21, sorry inventory, task cross-reference, obstruction analysis)
- `specs/093_complete_bxcanonical_embedding/plans/17_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

Changes are confined to `RootScopedChain.lean` (lines 1100+) and `specs/ROAD_MAP.md`.

1. **Strategy C succeeds**: No rollback needed. The proof works with the existing round-robin chain -- no chain replacement, no downstream theorem re-proofs.

2. **Strategy C has a gap**: Document the precise mathematical gap. The proved infrastructure (16 sorry-free lemmas including `target_stays_direct_in_fold`) remains valid. Spawn a dedicated research task for novel mathematical investigation. The gap would be a genuine open problem in temporal logic formalization -- the literature handles this implicitly via semantic arguments.

3. **Partial success (5 of 6 sorries closed)**: Keep all proved theorems. The `restricted_buc` sorry (line 1288) is independent of the other 5. Document obstacle and spawn task. This is a substantial publishable result -- the first Lean 4 formalization of temporal logic completeness up to the backward Until coherence gap.

4. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` restores the 6-sorry state. ROAD_MAP.md changes are committed independently.

### Key Differences from Plan v16

| Aspect | Plan v16 | Plan v17 |
|--------|----------|----------|
| Strategy A gate check | 3-hour Phase 1 | Eliminated (Report 17 recommends against) |
| ROAD_MAP.md update | Phase 0 (first) | Phase 4 (after implementation) |
| Strategy C detail | High-level description | Three concrete attack vectors (A, B, C) |
| Phase count | 6 | 5 |
| Total effort | 20 hours | 16 hours |
| Strategy C time budget | 4 hours | 6 hours (reallocated from Strategy A) |
| Contingency spawning | Implicit | Explicit Phase 5 |
