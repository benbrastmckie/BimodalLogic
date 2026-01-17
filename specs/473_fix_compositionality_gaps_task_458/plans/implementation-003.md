# Implementation Plan: Task #473

- **Task**: 473 - Fix compositionality gaps from Task 458
- **Status**: [NOT STARTED]
- **Version**: 003
- **Effort**: 6-8 hours (reduced scope)
- **Priority**: Medium
- **Dependencies**: Task 472 (Lindenbaum extension - COMPLETED)
- **Research Inputs**:
  - specs/473_fix_compositionality_gaps_task_458/reports/research-001.md
  - specs/473_fix_compositionality_gaps_task_458/reports/research-002.md
- **Implementation History**:
  - Phase 1: Time-shift infrastructure (PARTIAL - sorries blocked on compositionality)
  - Phase 2: Semantic task relation (COMPLETED - definitions work)
  - Phase 3: Compositionality proof (DOCUMENTED LIMITATION - unbounded case unprovable)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**Revision 003** incorporates the critical finding from Phase 3 of v002: **unbounded semantic compositionality is provably FALSE in the finite setting**. This plan pivots to a pragmatic hybrid strategy that accepts bounded compositionality while focusing on what's actually needed for completeness.

### Key Insight from Phase 3

The v002 plan assumed compositionality would be "trivial via history composition." Phase 3 proved this false:

**The problem**: `finite_task_rel_semantic phi w d u` requires witnesses `t, t'` in `[-k, k]` where `|d| ≤ 2k`.
- Given `|x| ≤ 2k` and `|y| ≤ 2k`, we have `|x + y| ≤ 4k` which can exceed `2k`
- **Counterexample**: k=1, x=2, y=2 → x+y=4 has no valid witness times in [-1, 1]

### Strategy Change from v002

| Aspect | v002 (Assumed) | v003 (Reality) |
|--------|----------------|----------------|
| Unbounded compositionality | "Trivially satisfied" | **UNPROVABLE** |
| Bounded compositionality | Not considered | Valid with bounds hypothesis |
| Completeness needs | Eliminate all sorries | Accept structural sorries |
| Core approach | Full semantic refactor | Hybrid: use what works |

## Goals & Non-Goals

**Goals**:
- Complete truth lemma using available infrastructure (Task 472 negation-completeness)
- Prove existence theorems using Lindenbaum extension (proven approach)
- Document compositionality limitations clearly with counterexamples
- Reduce sorry count to acceptable minimum (structural gaps only)
- Achieve working completeness theorem even with documented gaps

**Non-Goals**:
- Eliminate ALL compositionality sorries (proven impossible without bounds)
- Full semantic relation refactor (infrastructure built but compositionality blocked)
- Zero-sorry proof (would require different model construction approach)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Truth lemma blocked by compositionality | Medium | Low | Use ClosureMCS for local properties |
| Existence theorems need compositionality | Medium | Low | Use Lindenbaum directly |
| Remaining sorries affect soundness | High | Low | All sorries are in compositional paths |

## Implementation Phases

### Phase 4: Truth Lemma via Closure MCS [NOT STARTED]

**Goal**: Complete truth lemma backward directions using Task 472's `closure_mcs_negation_complete`

**Rationale**: The truth lemma doesn't actually need compositionality! It needs:
1. Negation-completeness (for backward cases) - provided by ClosureMCS
2. Derivation manipulation - provided by Completeness.lean lemmas
3. Canonical property for box - standard argument

**Tasks**:
- [ ] Review existing truth lemma structure in FiniteCanonicalModel.lean
- [ ] Identify which cases use ClosureMCS vs compositionality
- [ ] Fill implication backward case using `closure_mcs_imp_closed`
- [ ] Fill box backward case using canonical accessibility
- [ ] Fill temporal backward cases using existence theorems
- [ ] Document any remaining gaps with clear explanation

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Truth Lemma section

**Verification**:
- Truth lemma has fewer sorries than before
- Each remaining sorry has documented reason

---

### Phase 5: Existence Theorems via Lindenbaum [NOT STARTED]

**Goal**: Complete existence theorems using Task 472 Lindenbaum extension (not time-shift)

**Rationale**: Phase 1's time-shift approach is blocked by compositionality sorries. The Lindenbaum approach from v001 is simpler and proven to work for extending consistent sets.

**Tasks**:
- [ ] Review `forwardTransferRequirements` and `backwardTransferRequirements` definitions
- [ ] Use `lindenbaum_extension_finite` to extend requirement sets to MCS
- [ ] Prove requirements are closure-consistent (precondition for Lindenbaum)
- [ ] Connect resulting MCS to FiniteWorldState via `worldStateFromClosureMCS`
- [ ] Verify task relation satisfied between original and extended states

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Existence section

**Verification**:
- `finite_forward_existence_thm` compiles with minimal sorries
- `finite_backward_existence_thm` compiles with minimal sorries

---

### Phase 6: History Construction and Completeness [NOT STARTED]

**Goal**: Complete history construction to enable completeness theorem

**Tasks**:
- [ ] Use existence theorems to build `finite_history_from_state`
- [ ] Verify history satisfies task relation requirements
- [ ] Connect to completeness theorem statement
- [ ] Document relationship between finite model and semantic validity

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - History and Completeness sections

**Verification**:
- History construction compiles
- Completeness theorem statement uses constructed history

---

### Phase 7: Documentation and Sorry Inventory [NOT STARTED]

**Goal**: Document all remaining sorries and their justification

**Tasks**:
- [ ] Run `lake build` and collect all sorry locations
- [ ] Categorize sorries:
  - **Structural**: Compositionality gaps (provably unprovable without bounds)
  - **Technical**: Derivation manipulation details
  - **Deferred**: Could be filled with more work
- [ ] Add docstrings to each sorry explaining status
- [ ] Create final summary with sorry inventory

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Documentation
- Summary artifact

**Verification**:
- All sorries documented
- Clear path for future work identified

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Completeness.FiniteCanonicalModel` succeeds
- [ ] Truth lemma has both directions for key connectives
- [ ] Existence theorems can be invoked from truth lemma
- [ ] Completeness theorem compiles (may have sorry in composition path)
- [ ] All sorries have clear documentation

## Artifacts & Outputs

- plans/implementation-003.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (completion summary)
- Modified: `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

## Comparison with Previous Versions

| Version | Core Strategy | Compositionality | Outcome |
|---------|---------------|------------------|---------|
| v001 | Pointwise transfer + Lindenbaum | Accept gaps | Valid fallback |
| v002 | Semantic history + time-shift | "Eliminate all" | **Failed** (unbounded case unprovable) |
| v003 | Hybrid: MCS for truth lemma, Lindenbaum for existence | Accept structural gaps | Pragmatic completion |

## Preserved Infrastructure from v002

The following v002 additions remain useful:
- `FiniteTime.shift?`, `shift_toInt`, `shift_zero` - Time arithmetic
- `FiniteHistory.time_shift` - May be useful for future work
- `ConsistentSequence`, `finite_task_rel_semantic` - Alternative formulation
- `compositionality_bounded` - Valid with bounds hypothesis

## Sorry Classification

| Sorry Location | Type | Justification |
|----------------|------|---------------|
| `FiniteTaskRel.compositionality` (mixed-sign) | Structural | Pointwise transfer limitation |
| `SemanticTaskRel.compositionality` | Structural | Finite bounds limitation |
| `time_shift.forward_rel/backward_rel` | Blocked | Depends on compositionality |
| Truth lemma temporal cases | Technical | Existence theorem dependency |

## Success Criteria

1. **Truth lemma**: Both directions for implication, box, and temporal operators
2. **Existence theorems**: Forward and backward witnesses constructable
3. **Completeness**: Theorem statement compiles with documented sorries
4. **Documentation**: All sorries explained and categorized
5. **No regressions**: Existing proofs still work

## Rollback/Contingency

If v003 phases fail:
1. Preserve v002 infrastructure (already committed)
2. Document gaps as "future work requiring different model construction"
3. Consider infinite model approach for full compositionality
