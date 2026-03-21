# Implementation Plan: Dense Representation Theorem Completion (v3)

- **Task**: 18 - dense_representation_theorem_completion
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (builds on existing infrastructure)
- **Research Inputs**: reports/12_team-research.md (primary), reports/08_team-research.md, reports/05_team-research.md
- **Artifacts**: plans/03_dense-representation-v3.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan completes the dense representation theorem using the insights from three rounds of team research. The key insight from report-12 is that CanonicalR is the "existential shadow" of CanonicalTask (losing duration information), and DenseTask is the correct dense analogue. The plan uses the dovetailed construction (eager processing) to eliminate the m > 2k gap, avoiding closure operators entirely. The singleton BFMCS approach is confirmed impossible; multi-family BFMCS with closedFlags pattern is required.

### Research Integration

From `reports/12_team-research.md`:
- CanonicalR = ExistsTask (existential projection loses duration info)
- DenseTask is deterministic via Cantor isomorphism, already implemented
- Eager processing (dovetailed construction) eliminates m > 2k gap
- derive_F_to_FF requires 8-10 step derivation chain (mechanical)

From `reports/08_team-research.md`:
- Closure fixpoint = CanonicalMCS (rebuilding canonical model with extra steps)
- Direct bridge strategy has unresolvable gap (phi membership not guaranteed)
- TaskFrame requires world/time separation (CanonicalMCS cannot be D)

From `reports/05_team-research.md`:
- 7 real sorries (not 28): CantorPrereqs:111, ClosureSaturation:696,701,716,778, TimelineQuotCompleteness:127, CanonicalRecovery:160
- Critical path: derive_F_to_FF -> forward_F/backward_P -> BFMCS -> truth lemma

## Goals & Non-Goals

**Goals**:
- Complete `derive_F_to_FF` derivation (blocks everything else)
- Complete dovetailed coverage reach for eager F-witness processing
- Fix `timelineQuotFMCS_forward_F` sorries at lines 696, 701 in ClosureSaturation.lean
- Fix `timelineQuotFMCS_backward_P` sorry at line 716
- Complete `timelineQuot_not_valid_of_neg_consistent` (line 127)
- Wire `dense_completeness_theorem`
- Add ExistsTask alias for documentation clarity

**Non-Goals**:
- Full CanonicalR -> ExistsTask rename (separate task, 4-8 hours)
- Eliminating `timelineQuotSingletonBFMCS.modal_backward` sorry (provably impossible)
- Building closure operators (research confirms these rebuild CanonicalMCS)
- Fixing `canonicalR_implies_canonicalTask_forward` (secondary, does not block)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| derive_F_to_FF derivation chain is longer than expected | M | M | Use proof system automation (simp, tactics); accept longer derivation |
| DovetailedCoverageReach termination is complex | H | M | Accept localized sorry at recursion bottleneck if needed; document |
| Multi-family BFMCS closedFlags pattern requires new infrastructure | M | L | Reuse existing canonicalMCSBFMCS infrastructure from CanonicalFMCS.lean |
| Temporal coherence bridge requires additional lemmas | M | M | canonicalR_implies_timelineQuot_le is already proven; strict inequality follows from irreflexivity |

## Implementation Phases

### Phase 1: derive_F_to_FF Derivation [NOT STARTED]

**Goal**: Complete the density axiom derivation that blocks all downstream work.

**Tasks**:
- [ ] Implement derivation chain in CantorPrereqs.lean:106-111
  - Step 1: Apply density axiom GG(neg phi) -> G(neg phi)
  - Step 2: Contrapositive: neg G(neg phi) -> neg GG(neg phi)
  - Step 3: F(phi) = neg G(neg phi), so F(phi) -> neg GG(neg phi)
  - Step 4: DNE + temporal necessitation: G(neg neg G(neg phi)) -> GG(neg phi)
  - Step 5: Contrapositive + composition: F(phi) -> neg G(neg neg G(neg phi))
  - Step 6: Simplify via DNE to get F(phi) -> F(F(phi))
- [ ] Verify `density_F_to_FF` compiles without sorry
- [ ] Run `lake build` to confirm no regressions

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` - Complete derive_F_to_FF

**Verification**:
- `grep -n "sorry" CantorPrereqs.lean` returns only lines outside derive_F_to_FF
- `lake build Bimodal.Metalogic.StagedConstruction.CantorPrereqs` succeeds

---

### Phase 2: Complete Dovetailed Coverage Reach [NOT STARTED]

**Goal**: Complete the eager processing infrastructure for F-witness coverage.

**Tasks**:
- [ ] Analyze DovetailedCoverageReach.lean termination requirements
- [ ] Implement coverage theorem for F-witnesses via dovetailed construction
  - When point p enters at stage m, all F-formulas in p.mcs have encoding < m
  - Use witness_at_large_step from DovetailedCoverage.lean
- [ ] Prove `forward_F_via_coverage`: F(phi) in p.mcs implies phi-witness in timeline
  - Use density iteration: F(phi) -> F^j(phi) where j = density index
  - Chain back to phi via forward witnesses at each step
- [ ] Accept localized sorry for termination if recursion is non-trivial
- [ ] Run `lake build` to confirm compilation

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCoverageReach.lean` - Add coverage theorems

**Verification**:
- `forward_F_via_coverage` compiles (possibly with one localized sorry for termination)
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedCoverageReach` succeeds

---

### Phase 3: Fix Forward_F and Backward_P Sorries [NOT STARTED]

**Goal**: Complete temporal coherence proofs in ClosureSaturation.lean.

**Tasks**:
- [ ] Fix sorry at line 696 (m > 2k case):
  - Use forward_F_via_coverage from Phase 2 to get witness in timeline
  - Bridge to TimelineQuot via canonicalR_implies_timelineQuot_le
  - Strict inequality via CanonicalR_irreflexive
- [ ] Fix sorry at line 701 (density case):
  - Unify with m > 2k case using same coverage approach
  - The density intermediate q has CanonicalR(p.mcs, q.mcs) but may not have phi
  - Use coverage theorem to find actual phi-witness
- [ ] Fix sorry at line 716 (backward_P):
  - Symmetric argument using backward witnesses
  - Use backward_witness_at_stage from StagedExecution.lean
- [ ] Run `lake build` to confirm all temporal coherence sorries resolved

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - Fix lines 696, 701, 716

**Verification**:
- `grep -n "sorry" ClosureSaturation.lean` returns only line 778 (deprecated singleton)
- `timelineQuotFMCS_forward_F` and `timelineQuotFMCS_backward_P` compile without sorry
- `lake build Bimodal.Metalogic.StagedConstruction.ClosureSaturation` succeeds

---

### Phase 4: Build Multi-Family BFMCS [NOT STARTED]

**Goal**: Construct properly saturated BFMCS for TimelineQuot.

**Tasks**:
- [ ] Create `timelineQuotMultiFamilyBFMCS` using closedFlags pattern
  - Primary family: timelineQuotFMCS
  - Modal witness families: from closedFlags (finite set of diamond witnesses)
- [ ] Prove `modal_forward`: Box phi in mcs(t) of any family implies phi in mcs(t) of all families
  - All families share BoxContent from root MCS
- [ ] Prove `modal_backward`: phi in all families at t implies Box phi in any family at t
  - Use saturated_modal_backward from ModalSaturation.lean
- [ ] Bundle temporal coherence from Phase 3 into BFMCS structure
- [ ] Run `lake build` to confirm BFMCS compiles

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean` - Rebuild with multi-family
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - Wire to BFMCS

**Verification**:
- `timelineQuotMultiFamilyBFMCS` has no sorry in modal_forward or modal_backward
- `temporally_coherent` uses Phase 3 results without sorry
- `lake build` succeeds

---

### Phase 5: Wire Dense Completeness [NOT STARTED]

**Goal**: Complete the main theorem using parametric truth lemma instantiation.

**Tasks**:
- [ ] Complete `timelineQuot_not_valid_of_neg_consistent` (line 127):
  - Instantiate `parametric_canonical_truth_lemma` at D = TimelineQuot
  - Use Phase 4 BFMCS with proper temporal coherence
  - Connect phi.neg in root MCS to semantic evaluation via truth lemma
- [ ] Verify `dense_completeness_theorem` compiles without sorry:
  - Uses timelineQuot_not_valid_of_neg_consistent
  - Instance resolution for TimelineQuot constraints
- [ ] Add ExistsTask alias in CanonicalFrame.lean:
  - `abbrev ExistsTask := CanonicalR`
  - Update docstring to document derivation from CanonicalTask
- [ ] Final `lake build` to confirm full compilation

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - Complete main theorem
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - Add ExistsTask alias

**Verification**:
- `grep -n "sorry" TimelineQuotCompleteness.lean` returns no results
- `dense_completeness_theorem` compiles without sorry
- `lake build` succeeds on full project
- `grep "ExistsTask" CanonicalFrame.lean` shows alias definition

---

## Testing & Validation

- [ ] All Phase 1-5 `lake build` checks pass
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/StagedConstruction/ | grep -v "//"` shows only acceptable sorries:
  - Line 778: timelineQuotSingletonBFMCS.modal_backward (deprecated, provably impossible)
  - DovetailedCoverageReach termination sorry (if needed, localized)
- [ ] `dense_completeness_theorem` is invocable from other modules
- [ ] No regression in existing proofs (verified by full `lake build`)

## Artifacts & Outputs

- `plans/03_dense-representation-v3.md` (this file)
- `summaries/03_implementation-summary.md` (after completion)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean`
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCoverageReach.lean`
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean`
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`
- Modified: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`

## Rollback/Contingency

If eager processing approach encounters fundamental issues:

1. **Localized Sorry Acceptance**
   - Accept localized sorry in DovetailedCoverageReach for termination
   - Document as "termination proven mathematically, Lean mechanization deferred"
   - This is acceptable as the mathematical argument is sound

2. **Closure Operator Fallback**
   - If eager processing cannot be made to work, implement minimal closure
   - Target only specific (point, formula) obligations, not full closure
   - Estimated additional 3-4 hours

3. **Partial Delivery**
   - If only phases 1-3 complete, deliver temporal coherence without full BFMCS
   - Mark task as [PARTIAL] with clear documentation of remaining work
   - Phases 4-5 can be completed in follow-up

4. **Git Rollback**
   - Each phase committed atomically
   - `git revert` can undo individual phase commits
   - No destructive changes to existing working code
