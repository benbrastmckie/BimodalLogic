# Implementation Plan: Close BXCanonical Embedding (v21 -- Two-Tier Closure)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [BLOCKED]
- **Effort**: 12 hours
- **Dependencies**: None (Phase 1 of Plan v18 completed; quasimodel infrastructure sorry-free)
- **Research Inputs**: reports/21_team-research.md, reports/18_team-research.md, summaries/18_bxcanonical-embedding-summary.md
- **Artifacts**: plans/21_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Six sorry sites remain in `RootScopedChain.lean` (lines 1295, 1326, 1333, 1386, 1391, 1396), all blocking `dd_countermodel` and hence `bx_completeness`. Report 21 identifies that these 6 sorries decompose into two independent problems: Problem A (4 sorries downstream of `rr_fwd_chain_forward_F`, the primary blocker) and Problem B (2 sorries for `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc`, the Until/Since coherence obligations). This plan attacks them in priority order: first close the buc/fuc sorries (Problem B) using existing quasimodel infrastructure, then test the fold-order trick for forward_F, then if needed implement the ordered-discharge chain replacement (Problem A). Definition of done: `lake build` succeeds with zero sorry in RootScopedChain.lean, and `lean_verify` on `dd_countermodel` shows no sorry-dependent axioms.

### Research Integration

- **Report 21** (4-teammate consensus): 6 sorries reduce to 2 independent problems. buc/fuc (Problem B) are closeable at 85% confidence using quasimodel infrastructure. Fold-order trick was never actually tested (dead end #21 incorrectly listed). Plan v18 ordered-discharge chain confirmed as correct long-term path for forward_F at 55-65% confidence, estimated 25-35 hours.
- **Summary 18** (Plan v18 Phase 1 outcome): ROAD_MAP.md updated with dead ends 13-21. Chain replacement has a fatal F-propagation gap -- `discharge_single_step` gives target in M' and g_content(M) in M', but F(chi) may be permanently killed. The fundamental tension: BX11 temporal linearity means resolving any formula can permanently destroy F-obligations for "later" formulas.
- **Report 18**: Strategy C dead (85-90%). Architecture sound (95%). No published proof addresses forward_F syntactically.

### Prior Plan Reference

Plan v18 (24 hours, 7 phases) was partially executed. Phase 1 (ROAD_MAP.md update) completed. Phases 2-7 BLOCKED because the chain replacement approach has a fatal F-propagation gap identified during implementation: `target_resolving_fwd_step` via `discharge_single_step` cannot simultaneously guarantee target in M' AND preserve F-obligations, because the Lindenbaum extension can add G(neg chi) which permanently kills F(chi). Key lessons: (1) the F-propagation gap is the deepest obstruction, not just a proof difficulty, (2) buc/fuc sorries are independent and may be closeable without solving forward_F, (3) effort estimates for chain replacement should be 25-35 hours not 24, (4) the fold-order trick was never actually tested despite being listed as dead end #21.

### Roadmap Alignment

- Advances `rr_fwd_chain_forward_F` (PRIMARY BLOCKER) from OPEN toward DONE
- Advances `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` from OPEN toward DONE
- Closes sorry sites blocking `dd_countermodel` and `bx_completeness`
- Would unblock task 95 (`#print axioms` audit)

## Goals & Non-Goals

**Goals**:
- Close `dd_bfmcs_restricted_buc` (line 1391) and `dd_bfmcs_restricted_fuc` (line 1396) using quasimodel infrastructure
- Test the fold-order trick (processing target LAST in `enriched_fwd_fold_with_witness`) concretely
- If fold-order trick succeeds: close `rr_fwd_chain_forward_F` and all downstream sorries
- If fold-order trick fails: document precisely where Case 2 fires and update ROAD_MAP.md
- Close `dd_bfmcs_restricted_tc` (line 1386) which depends on forward_F + backward_P
- Achieve `lake build` with zero sorry in RootScopedChain.lean

**Non-Goals**:
- Modifying CanonicalModel.lean (dead code, not on active path)
- Implementing the full ordered-discharge chain replacement (25-35 hours, deferred to later plan if needed)
- Attempting Strategy C (dead, confirmed by Report 18)
- Proving unrestricted coherence properties (restricted suffices)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| buc/fuc closure requires forward_F (not truly independent) | H | L (15%) | Research report 21 Teammate D identifies the dependency chain; buc/fuc depend on Until/Since eventuality not forward_F. The quasimodel infrastructure (sorry-free, 2289 lines) handles exactly this. If blocked, document the missing bridge. |
| Fold-order trick fails at Case 2 (F(beta and F(target)) case) | M | H (65%) | This is expected per research analysis. Testing it (2h) still provides concrete data for the ordered-discharge approach. Even if fold-order fails, buc/fuc closure (Phase 1) is independent value. |
| Bridging quasimodel lemmas to dd_fmcs chain requires non-trivial adapter code | M | M (30%) | The dd_fmcs chain has `dd_chain_g_content` (proved sorry-free) which provides the key structural property. If adapter code is complex, scope Phase 1 to just the proof sketch and defer formalization. |
| backward_P has the same obstruction as forward_F (symmetric blocker) | H | H (60%) | If forward_F is closed by fold-order, backward_P follows by symmetric argument. If forward_F remains open, backward_P also remains open. Budget explicit time for backward chain in Phase 3. |
| dd_bfmcs_restricted_tc assembly fails due to missing forward_F/backward_P | H | M (40%) | Phase 4 is gated on Phases 2-3. If forward_F remains open, restricted_tc remains open, but buc/fuc closure (Phase 1) is still valuable. Mark as PARTIAL. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Close buc/fuc Sorries via Quasimodel Infrastructure [BLOCKED]

**Goal**: Close `dd_bfmcs_restricted_buc` (line 1391) and `dd_bfmcs_restricted_fuc` (line 1396) independently of forward_F, using the sorry-free Until/Since eventuality resolution from the quasimodel infrastructure.

**Tasks**:
- [ ] Analyze the definitions of `restricted_backward_until_since_coherent` and `restricted_forward_until_since_coherent` in `Bundle/TemporalCoherence.lean` to understand exactly what must be proved
- [ ] For `dd_bfmcs_restricted_fuc` (forward Until/Since coherence):
  - For Until: given `(phi U psi) in fam.mcs(t)`, find `s >= t` with `psi in fam.mcs(s)` and `phi in fam.mcs(r)` for all `t <= r < s`
  - Approach: `(phi U psi) in MCS` implies `psi in MCS` (trivial witness at s=t via reflexive Until semantics with half-open guard) OR requires forward witness via BX9/BX10
  - Check whether reflexive Until (s=t is allowed by `t <= s`) gives the trivial case: `psi in fam.mcs(t)` with empty guard interval
  - If Until is strict (needs s > t case): use `bx_until_eventuality_resolution` from Frame.lean (sorry-free) which gives a BXPoint witness, then translate to chain index via dd_fmcs structure
  - For Since: symmetric using backward chain and P-obligations
- [ ] For `dd_bfmcs_restricted_buc` (backward Until/Since coherence):
  - This is the CONVERSE direction: given a witness (s with psi at s, phi on [t,s)), prove `(phi U psi) in fam.mcs(t)`
  - Approach: use BX5 (`self_accum_until`) + BX9 (`until_elim`) or direct Until introduction from MCS properties
  - This direction typically follows from the Until introduction rule in the proof system
- [ ] Verify each proof compiles and `lake build` succeeds
- [ ] If the reflexive-Until trivial case works for fuc, document this as a key insight (much simpler than the F-witness approach)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at lines 1391 and 1396

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `lake build` succeeds
- No new sorry introduced

---

### Phase 2: Test Fold-Order Trick for forward_F [BLOCKED]

**Goal**: Concretely test whether processing target LAST in the BX11 fold (`enriched_fwd_fold_with_witness`) closes `rr_fwd_chain_forward_F`. Even if it fails, the result precisely characterizes the remaining obstruction.

**Tasks**:
- [ ] Locate `enriched_fwd_fold_with_witness` and `resolving_enriched_fwd_exists` in RootScopedChain.lean
- [ ] Understand the current fold order and where BX11 cases 1, 2, 3 arise
- [ ] Create a variant `target_last_enriched_fwd_exists` that processes target as the LAST formula in the fold (not subject to BX11 reordering by other formulas)
- [ ] Attempt to prove `target_last_enriched_fwd_step_target_in`: when F(target) in M, target in M' (deterministic, not disjunctive)
- [ ] If Case 2 fires (F(beta and F(target)) case): document the exact proof state where the obstruction occurs, capture it with `lean_goal`, and determine whether BX11 Case 2 can be ruled out at visit steps
- [ ] If proof succeeds: proceed to prove the full `rr_fwd_chain_forward_F` by showing that at each visit step, the scheduled formula is deterministically resolved
- [ ] Correct dead end #21 in ROAD_MAP.md based on actual test results (whether fold-order trick works or fails, and why)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add variant definitions and attempt proof
- `specs/ROAD_MAP.md` -- update dead end #21 with actual test results

**Verification**:
- If fold-order succeeds: `rr_fwd_chain_forward_F` compiles without sorry
- If fold-order fails: concrete `lean_goal` output showing where Case 2 blocks
- Dead end #21 in ROAD_MAP.md reflects actual test results
- `lake build` succeeds (no regressions)

---

### Phase 3: Close forward_F, backward_P, and dd_fmcs Sorries [BLOCKED]

**Goal**: If Phase 2 succeeded with the fold-order trick, use it to close the remaining forward/backward chain sorries. If Phase 2 failed, this phase documents the gap and marks remaining sorries for the ordered-discharge approach.

**Tasks**:
- [ ] **If fold-order succeeded in Phase 2**:
  - Replace `enriched_fwd_step` with the new `target_last_enriched_fwd_step` (or prove it has the same API plus the target_in guarantee)
  - Close `rr_fwd_chain_forward_F` (line 1295): at psi's visit step, F(psi) in chain(m) and target=psi gives psi in chain(m+1) deterministically. Use `enriched_fwd_step_preserves` for F-obligation persistence between steps to show F(psi) reaches the visit step.
  - Close `dd_fmcs_forward_F` t >= 0 case (already handled at line 1308-1317, flows from `rr_fwd_chain_forward_F`)
  - Close `dd_fmcs_forward_F` t < 0 case (line 1326): F(psi) in backward chain. Strategy: propagate F(psi) to M0 via h_content if G(F(psi)) is available, or apply symmetric backward chain argument
  - Close `dd_fmcs_backward_P` (line 1333): symmetric to forward_F using backward chain with P-obligations and H-content propagation
- [ ] **If fold-order failed in Phase 2**:
  - Document the precise obstruction in ROAD_MAP.md
  - Mark this phase as BLOCKED
  - The remaining 4 sorries (forward_F + 3 dependents) require the ordered-discharge chain replacement (25-35 hours, separate plan)
  - Proceed to Phase 4 with whatever was closed

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry sites at lines 1295, 1326, 1333
- `specs/ROAD_MAP.md` -- update sorry inventory

**Verification**:
- If successful: `rr_fwd_chain_forward_F`, `dd_fmcs_forward_F`, `dd_fmcs_backward_P` compile without sorry
- `lake build` succeeds
- ROAD_MAP.md sorry inventory updated

---

### Phase 4: Close restricted_tc and Final Assembly [BLOCKED]

**Goal**: Close `dd_bfmcs_restricted_tc` (line 1386) by assembling the four sub-proofs (G-forward, H-backward, F-forward, P-backward), then verify the complete sorry-free state.

**Tasks**:
- [ ] Close `dd_bfmcs_restricted_tc` (line 1386): restricted temporal coherence assembles four sub-cases:
  - G(phi) forward: by `dd_chain_g_content` (already proved, unaffected)
  - H(phi) backward: by `dd_chain_h_content` (already proved, unaffected)
  - F(phi) forward: by `dd_fmcs_forward_F` (from Phase 3)
  - P(phi) backward: by `dd_fmcs_backward_P` (from Phase 3)
  - If forward_F or backward_P are still sorry, this remains sorry (mark BLOCKED)
- [ ] Run `grep -n sorry RootScopedChain.lean` to verify zero matches
- [ ] Run `lake build` from clean state
- [ ] Use `lean_verify` on `dd_countermodel` to check axiom set
- [ ] Use `lean_verify` on `bx_completeness` to verify axiom set is `{propext, Classical.choice, Quot.sound}`

**Timing**: 2 hours

**Depends on**: 1, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry at line 1386

**Verification**:
- `dd_bfmcs_restricted_tc` compiles without sorry
- `grep -n sorry RootScopedChain.lean` returns zero matches
- `lake build` succeeds with zero errors
- `lean_verify` on `dd_countermodel` shows clean axiom set

---

### Phase 5: ROAD_MAP.md Final Update and Documentation [BLOCKED]

**Goal**: Update ROAD_MAP.md with the outcome (full success or partial progress), add docstrings to new definitions, and correct dead end #21.

**Tasks**:
- [ ] Update ROAD_MAP.md active-path sorry inventory:
  - If all 6 closed: change count from 6 to 0, mark all as DONE
  - If partial (buc/fuc only): change count from 6 to 4, mark buc/fuc as DONE
- [ ] Update task 93 cross-reference with current status
- [ ] If fold-order trick was tested (Phase 2): update dead end #21 with actual results
- [ ] Add docstrings to any new definitions or proof variants added
- [ ] If all sorries closed: add a "How the Sorries Were Closed" section documenting:
  - The buc/fuc independent closure via quasimodel infrastructure
  - The fold-order trick (if it worked) or the ordered-discharge approach (if that was used)
  - Key infrastructure that enabled the proofs

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `specs/ROAD_MAP.md` -- update sorry inventory, task cross-reference, add documentation
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add docstrings

**Verification**:
- ROAD_MAP.md accurately reflects current sorry state
- All new definitions have docstrings
- `lake build` still succeeds

## Testing & Validation

- [ ] `lake build` succeeds with zero errors at each phase boundary
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero matches (if all phases succeed)
- [ ] `lean_verify` on `dd_countermodel` shows no sorry-dependent axioms
- [ ] `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No new sorry introduced in any file
- [ ] `dd_countermodel` theorem compiles end-to-end
- [ ] ROAD_MAP.md sorry inventory accurately reflects current state

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- modified (sorry sites replaced, new proof variants, docstrings)
- `specs/ROAD_MAP.md` -- updated (sorry inventory, dead end #21 correction, task cross-reference)
- `specs/093_complete_bxcanonical_embedding/plans/21_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

Changes are confined to `RootScopedChain.lean` and `specs/ROAD_MAP.md`.

1. **Full success (all 6 sorries closed)**: No rollback needed. This is the target outcome at ~25% overall probability (35% fold-order * 85% buc/fuc * downstream assembly).

2. **Partial success -- buc/fuc closed, forward_F remains (most likely outcome, ~55%)**: Keep buc/fuc proofs (permanent value, reduces sorry count from 6 to 4). Document fold-order trick results. Spawn or update task for the ordered-discharge chain replacement (25-35 hours in a separate plan).

3. **Partial success -- fold-order works, buc/fuc blocked (~10%)**: Keep forward_F proof. Investigate the buc/fuc bridge to quasimodel infrastructure in a focused follow-up.

4. **Both blocked (~10%)**: Preserve all infrastructure added. The concrete fold-order test results inform future approaches. Consider alternative architectures (semantic/tree-based) per Summary 18 recommendations.

5. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` restores the 6-sorry state. ROAD_MAP.md changes should be committed independently and preserved regardless.
