# Implementation Plan: Task #957 - Density Frame Condition Under Irreflexive Temporal Semantics

- **Task**: 957 - density_frame_condition_irreflexive_temporal
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: Task 956 Phase 5 (BLOCKED, this task unblocks it)
- **Research Inputs**: specs/957_density_frame_condition_irreflexive_temporal/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Prove the canonical model density frame condition under irreflexive semantics using temporal axioms alone, without importing any external dense linear order. The core strategy is Case A + temporal linearity: given M < M' (CanonicalR(M, M') and NOT CanonicalR(M', M)), find distinguishing formula delta with G(delta) in M' and delta not in M, then use the Lindenbaum seed {neg(delta)} union GContent(M) to construct intermediate W. Temporal linearity eliminates CanonicalR(M', W) and W = M' possibilities, leaving CanonicalR(W, M').

### Research Integration

Integrated from research-001.md:
- **Finding 3**: Case A backward direction uses temporal linearity (canonical_forward_reachable_linear) to get three-way case split
- **Finding 11**: CanonicalR(M', W) ruled out because delta in GContent(M') subset W contradicts neg(delta) in W
- **Finding 12**: W = M' ruled out via selective Lindenbaum argument when delta in M', or via density seed when delta not in M'
- **Finding 14**: Full proof strategy combining Case A with density seed fallback

## Goals & Non-Goals

**Goals**:
- Prove `density_frame_condition`: forall M M', CanonicalR(M, M') -> NOT CanonicalR(M', M) -> exists W, CanonicalR(M, W) AND CanonicalR(W, M')
- Use only temporal axioms (temp_linearity, density, temp_4, etc.) - no external Q import
- Zero sorries, zero new axioms
- Integrate with SeparationLemma.lean existing infrastructure

**Non-Goals**:
- Proving strictness of intermediate (M < W < M') - not required for DenselyOrdered instance
- Implementing the lex product fallback (Path D alternative)
- Generalizing to reflexive semantics

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| W = M' edge case in sub-case 2 (delta not in M') | HIGH | MEDIUM | Use density seed {F(neg(delta))} union GContent(M); W != M' since F(neg(delta)) not in M' |
| Temporal linearity argument has hidden gap | LOW | LOW | Already proven in ConstructiveFragment.lean as canonical_forward_reachable_linear |
| Case B (G(delta) in M for all delta) occurs | MEDIUM | LOW | Finding 5 shows F(beta_0) in M always exists; use as alternative seed |
| Proof complexity exceeds estimate | MEDIUM | MEDIUM | Mark [BLOCKED] with review_reason if stuck; user decides approach |

## Sorry Characterization

### Pre-existing Sorries
- None in scope (SeparationLemma.lean, CanonicalTimeline.lean are sorry-free)

### Expected Resolution
- All phases produce complete proofs with no sorries
- If proof cannot be completed, mark phase [BLOCKED] with requires_user_review: true

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in density frame condition
- Task 956 Phase 5 unblocked (staged_timeline_densely_ordered)

## Implementation Phases

### Phase 1: Case A Backward Direction Lemma [NOT STARTED]

- **Dependencies:** None
- **Goal:** Prove that in Case A, temporal linearity gives CanonicalR(W, M')

**Tasks**:
- [ ] Add lemma `caseA_backward_via_linearity`: Given CanonicalR(M, M'), NOT CanonicalR(M', M), G(delta) in M', delta not in M, G(delta) not in M (Case A), the Lindenbaum extension W of {neg(delta)} union GContent(M) satisfies CanonicalR(W, M')
- [ ] Prove elimination of CanonicalR(M', W): delta in GContent(M') subset W contradicts neg(delta) in W
- [ ] Prove elimination of W = M' when delta in M': neg(delta) not in M' so W cannot equal M'
- [ ] Verify with lean_goal at each step

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean` - add new lemma after caseA_forward_witness_not_contains_beta

**Verification**:
- `lean_goal` shows "no goals" at end of proof
- `lake build` passes

---

### Phase 2: Sub-case 2 Handling (delta not in M') [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Handle the edge case where delta not in M' using density seed

**Tasks**:
- [ ] Add lemma `density_seed_distinct_from_target`: If F(neg(delta)) not in M' (which holds when G(delta) in M'), then Lindenbaum({F(neg(delta))} union GContent(M)) produces W != M'
- [ ] Add lemma `caseA_subcase2_backward`: When delta not in M', use density seed to get W with CanonicalR(M, W), W != M', then apply temporal linearity
- [ ] Handle the CanonicalR(M', W) elimination for density seed (requires delta not automatically in W)
- [ ] If elimination fails, use the consistency argument from Finding 7 that Case A formula ALWAYS exists

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean` - add sub-case handling lemmas

**Verification**:
- `lean_goal` shows "no goals" at end of each proof
- `lake build` passes

---

### Phase 3: Main Density Frame Condition Theorem [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Prove the main density frame condition theorem

**Tasks**:
- [ ] Add theorem `density_frame_condition`: forall M M', SetMaximalConsistent M -> SetMaximalConsistent M' -> CanonicalR M M' -> NOT CanonicalR M' M -> exists W, SetMaximalConsistent W AND CanonicalR M W AND CanonicalR W M'
- [ ] Use `distinguishing_formula_exists` to get delta
- [ ] Case split on G(delta) in M using `case_analysis_G_beta`
- [ ] Case A: Use Phase 1 lemma (with Phase 2 for sub-case 2)
- [ ] Case B: Use Finding 5 argument (F(beta_0) in M) to get alternative forward witness, or show Case A formula always exists

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean` - add main theorem

**Verification**:
- `lean_goal` shows "no goals" at end of proof
- `lake build` passes
- `grep -n "\bsorry\b" SeparationLemma.lean` returns empty

---

### Phase 4: Integration and Verification [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Verify zero-debt completion and prepare for task 956 integration

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Verify no sorries in SeparationLemma.lean: `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean`
- [ ] Verify no new axioms: `grep -n "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean`
- [ ] Verify theorem signature matches task 956 Phase 5 requirements
- [ ] Add docstring explaining the proof strategy for future reference

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean` - add docstring

**Verification**:
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean` returns empty (zero-debt gate)
- `grep -n "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean` shows no new axioms
- All proofs verified with `lean_goal` showing "no goals"

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Theorem `density_frame_condition` has correct signature for task 956 Phase 5
- [ ] Proof uses only temporal axioms (no external Q or dense order imports)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean` - updated with density frame condition theorem
- `specs/957_density_frame_condition_irreflexive_temporal/plans/implementation-001.md` - this plan
- `specs/957_density_frame_condition_irreflexive_temporal/summaries/implementation-summary-YYYYMMDD.md` - to be created on completion

## Rollback/Contingency

If the direct proof via Case A + temporal linearity fails:
1. Document the specific obstacle in the plan with [BLOCKED] status
2. Consider research-035's lexicographic product fallback (T_dense = StagedTimeline x_lex Q)
3. Create separate task for lex product approach if needed
4. Preserve any partial lemmas that are useful for future attempts

If proof is mathematically blocked (counterexample found):
1. Mark [BLOCKED] with requires_user_review: true
2. Document the counterexample in the plan
3. User decides whether to revise theorem statement or abandon approach
