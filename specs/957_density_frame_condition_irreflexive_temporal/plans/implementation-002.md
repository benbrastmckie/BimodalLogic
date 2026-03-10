# Implementation Plan: Task #957 - Density Frame Condition Under Irreflexive Temporal Semantics (v2)

- **Task**: 957 - density_frame_condition_irreflexive_temporal
- **Status**: [PLANNED]
- **Effort**: 3 hours
- **Dependencies**: Task 956 Phase 5 (BLOCKED, this task unblocks it)
- **Research Inputs**: research-001.md (original), research-002.md (Case B analysis)
- **Artifacts**: plans/implementation-002.md (this file), implementation-001.md (prior, superseded)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**Revised strategy based on research-002 findings:**

Research-002 proved definitively that:
1. **Case A formulas do NOT always exist** under irreflexive semantics
2. **The seed {neg(delta)} ∪ GContent(M) is INCONSISTENT in Case B** because delta ∈ GContent(M) (from G(delta) ∈ M)
3. No formula transformation produces the required neg(delta) witness for temporal linearity

**New approach: Option C (Staged Construction Case A Guarantee)**

Instead of proving the general density frame condition for arbitrary MCS pairs, we prove:
1. The staged construction only produces MCS pairs where Case A holds
2. Use the existing `density_frame_condition_caseA` (proven in implementation-001) for these pairs
3. The sorry in `density_frame_condition` remains, but task 956 uses the staged construction path which bypasses it

This is the most efficient resolution (100-200 lines estimated) vs selective Lindenbaum (400-600 lines).

### Prior Work (From implementation-001)

- **Phase 1-2 COMPLETED**: `density_frame_condition_caseA` handles Case A with double-density trick
- **Phase 3 BLOCKED**: `density_frame_condition` has sorry in Case B (research-002 proved this is not resolvable via Case A reduction)
- **File**: `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`

## Goals & Non-Goals

**Goals**:
- Prove `staged_density_always_caseA`: In the staged construction, between any two adjacent MCS, a Case A distinguishing formula exists
- Integrate with StagedExecution.lean to use `density_frame_condition_caseA` for staged density
- Unblock task 956 Phase 5 (`staged_timeline_densely_ordered`)
- Zero sorries in the staged construction path

**Non-Goals**:
- Resolving the sorry in general `density_frame_condition` (Case B is mathematically genuine)
- Proving selective Lindenbaum infrastructure (Option A - too heavy)
- Using lexicographic product (forbidden per task description)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Staged construction can produce Case B pairs | HIGH | LOW | Analyze odd-stage insertion strategy; the construction explicitly controls distinguishing formulas |
| Integration with StagedExecution.lean is complex | MEDIUM | MEDIUM | Read existing density_witness_exists and staged patterns first |
| Proof structure differs from expected | MEDIUM | MEDIUM | May need to add intermediate lemmas about staged construction invariants |

## Sorry Characterization

### Pre-existing Sorries
- `density_frame_condition` (Case B branch) - 1 sorry in DensityFrameCondition.lean

### Expected Resolution
- **NOT resolving**: The `density_frame_condition` sorry remains (Case B is mathematically irreducible)
- **NEW APPROACH**: Staged construction bypass - prove density via Case A guarantee

### New Sorries
- None. The staged path will be sorry-free. If staged Case A guarantee cannot be proven:
  - Mark phase [BLOCKED] with requires_user_review: true
  - Fall back to Option B (constructive density during staged construction)

### Remaining Debt
After this implementation:
- 1 sorry in general `density_frame_condition` (acceptable - not used by staged path)
- 0 sorries in staged construction density path
- Task 956 Phase 5 unblocked

## Implementation Phases

### Phase 1: Analyze Staged Construction [NOT STARTED]

- **Dependencies:** None
- **Goal:** Understand how the staged construction creates MCS pairs and identify Case A guarantee

**Tasks**:
- [ ] Read `StagedExecution.lean` to understand odd/even stage structure
- [ ] Read `density_witness_exists` and related lemmas
- [ ] Identify where distinguishing formulas are chosen in the construction
- [ ] Document the invariant: why staged pairs always have Case A formulas

**Timing**: 0.5 hours

**Files to read**:
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/WitnessSeedWrapper.lean`
- `Theories/Bimodal/Metalogic/ConstructiveFragment.lean`

**Verification**:
- Document findings in Progress section
- Identify exact location where Case A guarantee proof will hook in

---

### Phase 2: Prove Staged Case A Lemma [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove that staged construction pairs always have Case A distinguishing formulas

**Tasks**:
- [ ] Add lemma `staged_pair_has_caseA_formula`: For MCS pairs (M, M') produced by staged construction, exists delta with G(delta) ∈ M', delta ∉ M, G(delta) ∉ M
- [ ] Key insight: The staged construction uses explicit F-obligations to create forward witnesses; these F-obligations come from formulas with G(phi) NOT in the source MCS
- [ ] Alternative formulation: Show that odd-stage insertion uses a seed derived from Case A conditions

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - add staged Case A lemma

**Verification**:
- `lean_goal` shows "no goals" at end of proof
- `lake build` passes

---

### Phase 3: Integrate with density_frame_condition_caseA [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Wire staged Case A guarantee to existing caseA theorem

**Tasks**:
- [ ] Add `staged_density_intermediate`: For staged pairs, use `staged_pair_has_caseA_formula` + `density_frame_condition_caseA` to produce intermediate W
- [ ] Verify the theorem signature matches what StagedExecution.lean needs for `staged_timeline_densely_ordered`
- [ ] Add any adapter lemmas if signatures differ slightly

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - add integration theorem

**Verification**:
- `lean_goal` shows "no goals"
- `lake build` passes
- Theorem usable for task 956 Phase 5

---

### Phase 4: Verification and Unblock Task 956 [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Verify zero-debt staged path and prepare for task 956

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Verify staged path has no sorries: check `density_frame_condition_caseA` and `staged_density_intermediate`
- [ ] Document that general `density_frame_condition` sorry remains (Case B is mathematically genuine)
- [ ] Verify theorem signature enables task 956 Phase 5 to proceed
- [ ] Update task 956 blocked_reason if needed

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - add docstrings
- `specs/state.json` - update task 956 blocked_reason if resolved

**Verification**:
- `lake build` passes with only the expected `density_frame_condition` Case B sorry warning
- Staged density path is sorry-free
- Task 956 Phase 5 requirements satisfied

## Progress

**Prior session (implementation-001):**
- Completed: Phases 1-2 (Case A double-density trick, `density_frame_condition_caseA`)
- Blocked: Phases 3-4 (Case B sorry, research-002 proved Case A reduction impossible)

**This revision:**
- New approach: Option C (staged construction Case A guarantee)
- Abandons attempt to resolve general Case B
- Uses existing `density_frame_condition_caseA` via staged path

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes
- [ ] Staged density path is sorry-free (grep specific theorems)
- [ ] General `density_frame_condition` sorry acknowledged in docstring
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Staged density theorem signature matches task 956 Phase 5 requirements
- [ ] Proof uses only temporal axioms (no external Q or dense order imports)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - staged Case A theorems
- `specs/957_density_frame_condition_irreflexive_temporal/plans/implementation-002.md` - this revised plan
- `specs/957_density_frame_condition_irreflexive_temporal/summaries/implementation-summary-YYYYMMDD.md` - on completion

## Rollback/Contingency

If staged Case A guarantee cannot be proven:
1. **Option B**: Constructive density during staged construction (200-400 lines)
   - Build W explicitly during the staged process rather than via Lindenbaum
   - More control over GContent(W)
2. **Option A**: Full selective Lindenbaum (400-600 lines)
   - Last resort, heavy infrastructure

If mathematically blocked:
1. Mark [BLOCKED] with requires_user_review: true
2. Document the specific obstruction
3. User decides next steps
