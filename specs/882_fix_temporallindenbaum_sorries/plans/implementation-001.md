# Implementation Plan: Task #882

- **Task**: 882 - Fix TemporalLindenbaum sorries
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/882_fix_temporallindenbaum_sorries/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task fixes 5 sorries across two files (TemporalLindenbaum.lean and TemporalCoherentConstruction.lean) that block task 881's axiom elimination effort. The sorries fall into three categories: (1) Henkin base cases requiring the Encodable.encodek pattern, (2) temporal maximality cases requiring proof-by-contradiction using witness consistency, and (3) a generic temporal coherent family existence theorem.

### Research Integration

Research report (research-001.md) identified:
- Henkin base case sorries (lines 444, 485) need the Encodable encode/decode pattern to show that temporal packages are eventually added
- Maximality sorries (lines 655, 662) may need proof restructuring or a new witness consistency lemma
- The sorry at line 636 is in TemporalCoherentConstruction.lean, not TemporalLindenbaum.lean

## Goals & Non-Goals

**Goals**:
- Resolve all 5 sorries blocking task 881
- Establish the Encodable.encodek pattern for Henkin base cases
- Prove or restructure the temporal maximality cases
- Complete the temporal_coherent_family_exists theorem

**Non-Goals**:
- Refactoring the Henkin construction beyond what is needed for the proofs
- Generalizing the construction to arbitrary domain types D
- Optimizing proof performance

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Maximality proof requires restructuring | H | M | Try witness consistency lemma first; restructure only if needed |
| temporal_witness_seed_consistent unavailable | M | M | Check existing lemmas; adapt or create if needed |
| Package consistency proof complex | M | L | Use existing consistency lemmas in TemporalCoherentConstruction.lean |
| Sorries interdependent | M | L | Prioritize base case sorries (1-2) before maximality (3-4), family (5) last |

## Sorry Characterization

### Pre-existing Sorries
- 4 sorries in `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`:
  - Line 444: henkinLimit_forward_saturated base case
  - Line 485: henkinLimit_backward_saturated base case
  - Line 655: maximal_tcs_is_mcs F-formula case
  - Line 662: maximal_tcs_is_mcs P-formula case
- 1 sorry in `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`:
  - Line 636: temporal_coherent_family_exists

### Expected Resolution
- Phase 1 resolves lines 444, 485 via Encodable.encodek pattern
- Phase 2 resolves lines 655, 662 via witness consistency proof or restructure
- Phase 3 resolves line 636 via constant family construction

### New Sorries
- None expected. If proof complexity requires temporary sorry, will document with remediation timeline.

### Remaining Debt
After this implementation:
- 0 sorries expected in TemporalLindenbaum.lean
- 0 sorries expected in temporal_coherent_family_exists theorem
- Task 881 (axiom elimination) will be unblocked

## Implementation Phases

### Phase 1: Fix Henkin Base Case Sorries [NOT STARTED]

- **Dependencies:** None
- **Goal:** Resolve sorries at lines 444 and 485 using the Encodable.encodek pattern

**Tasks**:
- [ ] Read TemporalLindenbaum.lean lines 430-500 to understand henkinLimit_forward_saturated and henkinLimit_backward_saturated context
- [ ] Verify Encodable.encodek exists in Mathlib via lean_local_search
- [ ] Identify existing temporal_witness_seed_consistent or similar lemmas
- [ ] Implement proof for line 444 sorry:
  - Use `n := Encodable.encode (Formula.some_future psi)` to get step number
  - Show package consistency with henkinChain base n
  - Show psi in henkinChain base (n+1) via forward_witness_in_package
  - Conclude psi in henkinLimit base
- [ ] Implement proof for line 485 sorry (symmetric with backward variants)
- [ ] Verify no new sorries introduced

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - lines 444, 485

**Verification**:
- `lean_goal` at lines 444, 485 shows "no goals" after fix
- File compiles without errors at those locations

---

### Phase 2: Fix Maximality Temporal Case Sorries [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Resolve sorries at lines 655 and 662 in maximal_tcs_is_mcs theorem

**Tasks**:
- [ ] Read maximal_tcs_is_mcs theorem context (lines 640-670)
- [ ] Analyze the goal state for lines 655 and 662
- [ ] Determine if proof-by-contradiction or restructuring is needed:
  - Option A: Prove that if F(psi) can be consistently added to M, then psi is already in M (witness consistency)
  - Option B: Restructure to extend with temporalPackage instead of single formula
- [ ] Implement chosen approach for line 655 (F-formula case)
- [ ] Implement chosen approach for line 662 (P-formula case - symmetric)
- [ ] Verify maximal_tcs_is_mcs compiles without sorry

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - lines 655, 662

**Verification**:
- `lean_goal` at lines 655, 662 shows "no goals"
- `temporalLindenbaumMCS` theorem compiles without sorry

---

### Phase 3: Fix temporal_coherent_family_exists Sorry [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Resolve sorry at line 636 in TemporalCoherentConstruction.lean

**Tasks**:
- [ ] Read temporal_coherent_family_exists theorem and context (lines 620-650)
- [ ] Verify temporalLindenbaumMCS is now sorry-free after Phases 1-2
- [ ] Implement proof using constant family construction:
  - Use temporalLindenbaumMCS to get a single temporally saturated MCS M
  - Construct family where fam.mcs t = M for all t
  - Prove forward coherence: F(phi) in M at t implies phi in M at s > t (trivially, same set)
  - Prove backward coherence: P(phi) in M at t implies phi in M at s < t (trivially, same set)
- [ ] Alternative: If constant family does not work, use existing approaches (temporal_coherent_family_exists_Int, etc.)
- [ ] Verify theorem compiles without sorry

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - line 636

**Verification**:
- `lean_goal` at line 636 shows "no goals"
- `temporal_coherent_family_exists` compiles without sorry
- Downstream theorem fully_saturated_bmcs_exists is unblocked for task 881

---

## Testing & Validation

- [ ] All 5 sorries resolved (verify with grep -n "sorry" in both files)
- [ ] TemporalLindenbaum.lean compiles without errors
- [ ] TemporalCoherentConstruction.lean compiles without errors
- [ ] `lake build` succeeds for the Bundle module
- [ ] No new axioms introduced (verify with grep for "axiom")

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-20260213.md (upon completion)
- Modified files:
  - `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`
  - `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`

## Rollback/Contingency

If implementation fails:
- Revert changes with `git checkout -- Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`
- Revert changes with `git checkout -- Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
- Keep sorries in place; task 881 remains blocked
- Document blocking issues in error report
