# Implementation Plan: Dense Representation Theorem Completion (v2)

- **Task**: 18 - dense_representation_theorem_completion
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: Task 16 (DenseTask), Task 17 (TimelineQuotBFMCS)
- **Research Inputs**: reports/01_dense-representation-research.md, reports/02_team-research.md (primary)
- **Artifacts**: plans/02_dense-representation-v2.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This revised plan addresses the dense representation theorem completion using the corrected approach from team research. The previous plan (v1) was blocked by fundamental issues: singleton BFMCS is provably impossible for `modal_backward`, and the CanonicalMCS domain was being incorrectly used as BFMCS indexing type. This plan implements a fresh multi-family BFMCS construction over TimelineQuot with closure-based F-witness saturation, directly addressing the m > 2k gap in the staged construction.

### Research Integration

From `reports/02_team-research.md` (supersedes v1 research):

- **Singleton BFMCS Impossibility**: Confirmed mathematically impossible - `modal_backward` cannot be satisfied
- **CanonicalMCS Domain Confusion**: CanonicalMCS is the world state domain (W), not the duration domain (D)
- **m > 2k Problem**: Staged construction gap where F-witnesses for late-arriving points are not retroactively added
- **Resolution**: Fresh multi-family BFMCS construction indexed by TimelineQuot with closure-based saturation
- **Dead-End Code**: SingletonBFMCS, singletonCanonicalBFMCS, timelineQuotSingletonBFMCS must be archived

## Goals & Non-Goals

**Goals**:
- Archive dead-end singleton BFMCS constructions
- Build fresh multi-family BFMCS indexed by TimelineQuot (not CanonicalMCS)
- Implement closure-based F-witness saturation to resolve m > 2k gap
- Prove `timelineQuotFMCS_forward_F` and `timelineQuotFMCS_backward_P` with corrected approach
- Complete `timelineQuot_not_valid_of_neg_consistent` (remove blocking sorry)
- Wire `dense_completeness_theorem`

**Non-Goals**:
- Preserving singleton BFMCS approach (proven impossible)
- Using CanonicalMCS as BFMCS indexing type (domain confusion)
- Transfer theorems from Int-based infrastructure (perpetuates confusion)
- Full bidirectional truth lemma (forward direction suffices)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Closure saturation may not terminate | H | L | Use ordinal-indexed stages with well-founded recursion |
| embed/retract pair complexity | M | M | Define explicit TimelineQuot positioning lemmas for new witnesses |
| Density points need F-coherence recursively | H | M | Include density points in closure iteration, not as separate case |
| Modal saturation still needed for modal_backward | H | M | Build multi-family with closedFlags pattern, not singleton |
| Interaction between closure families | M | M | Keep families independent, share only temporal backbone |

## Implementation Phases

### Phase 1: Archive Dead-End Code [NOT STARTED]

**Goal**: Remove singleton BFMCS constructions that are mathematically impossible, clean up domain confusion.

**Tasks**:
- [ ] Archive `SingletonBFMCS` definition (SuccChainBFMCS.lean:67-125)
- [ ] Archive `singletonCanonicalBFMCS` (MultiFamilyBFMCS.lean:175-289)
- [ ] Archive `timelineQuotSingletonBFMCS` (ClosureSaturation.lean:693-727)
- [ ] Add architectural note documenting why singleton approach fails
- [ ] Verify `lake build` succeeds after archival

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/SuccChainBFMCS.lean` - Comment out SingletonBFMCS with explanation
- `Theories/Bimodal/Metalogic/MultiFamilyBFMCS.lean` - Comment out singletonCanonicalBFMCS
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - Archive singleton code

**Verification**:
- `lake build` succeeds
- No downstream dependencies on archived code
- Architectural decision documented in comments

---

### Phase 2: Closure-Based F-Witness Infrastructure [NOT STARTED]

**Goal**: Build the core closure operator for F-witness saturation over TimelineQuot.

**Tasks**:
- [ ] Define `FWitnessClosure`: Set of (t, phi) pairs where F(phi) at t lacks witness
- [ ] Define `addFWitness`: Given (t, phi) pair, add Lindenbaum witness at position > t
- [ ] Prove `addFWitness_preserves_density`: Adding witness doesn't break density structure
- [ ] Define `closureStep`: Single iteration adding witnesses for all pending F-obligations
- [ ] Prove `closureStep_monotone`: Each step adds points but doesn't remove any
- [ ] Define termination metric using formula encoding ordinal

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - Add closure infrastructure

**Verification**:
- All new definitions compile without sorry
- `closureStep_monotone` proven
- `lake build` succeeds

---

### Phase 3: Multi-Family BFMCS Construction [NOT STARTED]

**Goal**: Build fresh multi-family BFMCS properly indexed by TimelineQuot.

**Tasks**:
- [ ] Define `TimelineQuotBFMCS`: Multi-family BFMCS indexed by TimelineQuot
- [ ] Use `closedFlags` pattern for modal saturation (not singleton)
- [ ] Define families: primary family + modal witness families from closedFlags
- [ ] Prove `timelineQuotBFMCS_modal_forward`: Box phi implies phi via T-axiom
- [ ] Prove `timelineQuotBFMCS_modal_backward`: All-family membership implies Box
- [ ] Verify families correctly indexed by TimelineQuot positions

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean` - Rebuild BFMCS
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - Wire closure families

**Verification**:
- `timelineQuotBFMCS_modal_forward` compiles without sorry
- `timelineQuotBFMCS_modal_backward` compiles without sorry
- `lake build` succeeds

---

### Phase 4: Temporal Coherence with Closure [NOT STARTED]

**Goal**: Prove forward_F and backward_P using the closure-saturated construction.

**Tasks**:
- [ ] Prove `timelineQuotFMCS_forward_F_closed`: F(phi) at t implies witness exists in closure
  - Use closure saturation: if (t, phi) was a gap, closure step added witness
  - The witness is at position s > t in TimelineQuot
- [ ] Prove `timelineQuotFMCS_backward_P_closed`: P(phi) at t implies witness exists
  - Symmetric argument using backward witness addition
- [ ] Remove sorries from ClosureSaturation.lean:659, 664, 679
- [ ] Bundle into `TimelineQuotTemporalCoherentFMCS` structure

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - Complete temporal coherence

**Verification**:
- `timelineQuotFMCS_forward_F_closed` compiles without sorry
- `timelineQuotFMCS_backward_P_closed` compiles without sorry
- No sorries remain at lines 659, 664, 679
- `lake build` succeeds

---

### Phase 5: Truth Lemma and Final Wiring [NOT STARTED]

**Goal**: Complete the truth lemma and wire the dense completeness theorem.

**Tasks**:
- [ ] Define `timelineQuotCanonicalTaskModel`: TaskModel over closure-saturated BFMCS
- [ ] Define `timelineQuotCanonicalOmega`: Shift-closed history set
- [ ] Prove `timelineQuot_truth_lemma`: MCS membership iff semantic truth
  - Base cases: atom, bot (standard)
  - Propositional: imp, neg (follows canonical pattern)
  - Modal: box (uses multi-family modal_backward, not singleton)
  - Temporal: G, H (uses forward_G, backward_H)
  - Temporal: F, P (uses closure-proven forward_F, backward_P)
- [ ] Complete `timelineQuot_not_valid_of_neg_consistent` (remove sorry at line 127)
- [ ] Verify `dense_completeness_theorem` compiles without sorry

**Timing**: 3.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - Complete main theorems

**Verification**:
- `timelineQuot_truth_lemma` handles all formula constructors without sorry
- `timelineQuot_not_valid_of_neg_consistent` has no sorry
- `dense_completeness_theorem` compiles without sorry
- `grep -n "sorry" TimelineQuotCompleteness.lean` returns no results (excluding comments)
- Full `lake build` succeeds

---

## Testing & Validation

- [ ] All archived code has explanatory comments documenting impossibility
- [ ] No downstream dependencies on archived singleton code
- [ ] `lake build` succeeds on full project
- [ ] `timelineQuot_truth_lemma` handles all formula constructors
- [ ] `dense_completeness_theorem` provides completeness for dense temporal frames
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/StagedConstruction/ | grep -v "//"` shows only acceptable sorries
- [ ] No regression in existing proofs (Task 16, Task 17 components)

## Artifacts & Outputs

- `plans/02_dense-representation-v2.md` (this file)
- `summaries/02_implementation-summary.md` (after completion)
- Modified: `Theories/Bimodal/Metalogic/SuccChainBFMCS.lean` (archive)
- Modified: `Theories/Bimodal/Metalogic/MultiFamilyBFMCS.lean` (archive)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` (closure + temporal coherence)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean` (rebuild)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` (main theorems)

## Rollback/Contingency

If closure-based approach encounters issues:

1. **Staged Construction Extension**
   - Instead of closure, extend staged construction to process F-obligations retroactively
   - When point enters at stage m, check ALL F-formulas not just encoding <= m
   - More complex but avoids new abstraction layer

2. **Two-Pass Construction**
   - Pass 1: Build temporal backbone (all points via density/CanonicalR)
   - Pass 2: For each point, ensure all F-obligations have witnesses
   - Less elegant but more explicit

3. **Partial Delivery**
   - If only phases 1-3 complete, deliver multi-family BFMCS without full coherence
   - Document remaining gaps for follow-up task
   - Mark task as [PARTIAL]

4. **Git Rollback**
   - All changes atomic per phase
   - `git revert` can undo individual phase commits
   - Archived code can be restored from git history if approach changes
