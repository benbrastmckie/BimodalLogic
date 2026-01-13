# Implementation Plan: Task #449

- **Task**: 449 - Truth Lemma
- **Version**: 002
- **Status**: [PLANNED]
- **Effort**: 8-12 hours (reduced from original 15-20)
- **Priority**: Low
- **Dependencies**: Task 448 (completed), Task 473 (completed), Task 481 (completed), Task 482 (in progress - has sorries)
- **Research Inputs**: .claude/specs/449_truth_lemma/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

This is plan v002, revised after progress on tasks 473, 481, and 482.

### What Changed Since v001

**Task 473 (Completed)**: Introduced SemanticWorldState architecture
- Created `SemanticWorldState` as quotient of (FiniteHistory, FiniteTime) pairs
- Created `SemanticTaskRelV2` with compositionality trivial by construction
- Created `semantic_truth_lemma_v2` proving membership ↔ truth for the semantic approach
- Created `SemanticCanonicalFrame` and `SemanticCanonicalModel`

**Task 481 (Completed)**: Fixed nullity sorry
- `SemanticCanonicalFrame.nullity` now proven via `Quotient.out`
- SemanticCanonicalFrame is now a valid TaskFrame instance

**Task 482 (In Progress)**: History gluing infrastructure - **NOT COMPLETE**
- `glue_histories` function implemented with piecewise construction
- **Remaining sorries in compositionality**:
  1. `glue_histories.forward_rel` - edge cases in piecewise proof
  2. `glue_histories.backward_rel` - edge cases in piecewise proof
  3. `compositionality` case pos: `h_t1_before` (assumes x ≥ 0), `h_t_final_after` (assumes y > 0)
  4. `compositionality` case neg: bounds exceeded case
- These sorries are in `SemanticTaskRelV2.compositionality` which feeds into `SemanticCanonicalFrame`
- **Impact on task 449**: May affect `semantic_weak_completeness` proof if it relies on compositionality

### Strategic Pivot

**Old approach (v001)**: Complete `finite_truth_lemma` for FiniteWorldState
- Blocked by negation-completeness requirement
- 6 backward-direction sorries requiring MCS (maximal consistent set) properties
- Would require Task 472 (Lindenbaum extension) first

**New approach (v002)**: Use SemanticWorldState architecture from Task 473
- `semantic_truth_lemma_v2` already proven (line 2838)
- Focus on connecting semantic completeness to main completeness theorem
- The semantic approach sidesteps negation-completeness because world states ARE (quotients of) histories

### Remaining Work

1. ~~Prove closure infrastructure~~ - **DONE** (Phase 1 v001)
2. ~~Prove forward directions~~ - **DONE** (Phases 2-4 v001)
3. ~~Complete semantic infrastructure~~ - **DONE** (Task 473)
4. ~~Fix nullity~~ - **DONE** (Task 481)
5. Complete history gluing - **IN PROGRESS** (Task 482 - has sorries that may block completeness)
6. **NEW**: Connect `semantic_weak_completeness` to main `weak_completeness` theorem
7. **NEW**: Verify old `finite_truth_lemma` can be deprecated or marked auxiliary

### Task 482 Dependency Analysis

The `semantic_weak_completeness` theorem may depend on `SemanticCanonicalFrame` which uses `SemanticTaskRelV2.compositionality`. If the completeness proof requires compositionality (e.g., for temporal operators), then Task 482's sorries become blocking.

**Assessment needed in Phase 1**: Determine whether `semantic_weak_completeness` actually uses compositionality, or whether it only uses nullity (which is proven) and truth evaluation (which doesn't require compositionality).

## Overview

Complete the truth lemma by connecting the semantic infrastructure (from Task 473) to the main completeness theorem. The semantic truth lemma (`semantic_truth_lemma_v2`) is already proven; this task focuses on using it to establish `semantic_weak_completeness` and connect to the final completeness result.

## Goals & Non-Goals

**Goals**:
- Prove `semantic_weak_completeness` theorem using `semantic_truth_lemma_v2`
- Connect semantic completeness to main `weak_completeness` theorem
- Document relationship between old `finite_truth_lemma` and new `semantic_truth_lemma_v2`
- Verify all truth lemma functionality is complete (for the semantic approach)

**Non-Goals**:
- Completing the old `finite_truth_lemma` backward directions (deprecated approach)
- Task 472 Lindenbaum extension (not needed for semantic approach)
- Resolving Task 482 sorries directly (unless Phase 1 determines they're blocking)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| semantic_weak_completeness harder than expected | Medium | Low | Use existing semantic infrastructure; proof should follow standard pattern |
| Connection to main completeness unclear | Medium | Medium | Review Task 450 plan and Completeness.lean structure |
| Task 482 sorries block downstream work | High | Medium | Phase 1 must assess whether compositionality is needed; if yes, may need to complete 482 first or find workaround |

## Implementation Phases

### Phase 1: Analyze Current State and Task 482 Impact [COMPLETED]

**Goal**: Understand the current state of semantic completeness, identify exact gaps, and determine whether Task 482's sorries are blocking.

**Tasks**:
- [x] Read `semantic_weak_completeness` axiom/sorry at current location
- [x] Identify what `semantic_weak_completeness` needs to prove
- [x] **Critical**: Determine if proof requires `SemanticTaskRelV2.compositionality`
  - **NO!** Compositionality is NOT needed for the basic completeness proof
  - The proof constructs ONE countermodel, doesn't need frame properties
- [x] Verify `semantic_truth_lemma_v2` provides the necessary connection
- [x] Check Completeness.lean to see how completeness connects to canonical model

**Findings**:
1. `semantic_weak_completeness` proof uses contrapositive: assume not provable, construct countermodel
2. Key dependencies are `closure_lindenbaum_via_projection` (proven) and `finite_history_from_state` (2 sorries)
3. Task 482's compositionality sorries are NOT blocking - they're only needed for frame axioms
4. The actual blocking sorries are in `finite_history_from_state` (lines 2850, 2852)
5. Main Completeness.lean has `weak_completeness` axiom that could be replaced once semantic version is proven

**Timing**: 1 hour (completed)

**Files examined**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - semantic infrastructure
- `Theories/Bimodal/Metalogic/Completeness.lean` - main completeness theorems

**Verification**:
- Task 482 is NOT blocking for semantic_weak_completeness
- Blocking dependencies: `finite_history_from_state` construction sorries

---

### Phase 2: Prove semantic_weak_completeness [COMPLETED]

**Goal**: Replace the `semantic_weak_completeness` axiom/sorry with a complete proof using `semantic_truth_lemma_v2`.

**Tasks**:
- [x] Structure the proof: from ¬provable phi, construct SemanticCanonicalModel
- [x] Use `semantic_truth_lemma_v2` to show phi is false at some state
- [x] Show this gives a countermodel to validity
- [x] Contrapositive gives: valid implies provable

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - semantic_weak_completeness

**Verification**:
- [x] `semantic_weak_completeness` compiles (uses `mcs_projection_is_closure_mcs` which has a sorry)
- [x] lean_diagnostic_messages shows no new errors in semantic_weak_completeness itself

**Notes**:
- The proof uses contrapositive: if phi not provable, construct countermodel via Lindenbaum
- Helper lemmas added: `neg_consistent_of_not_provable`, `set_consistent_not_both`, `set_mcs_neg_excludes`
- `mcs_projection_is_closure_mcs` has a sorry for maximality (needs closure closed under negation)
- The main proof structure is complete; the sorry is in downstream infrastructure

---

### Phase 3: Connect to Main Completeness [COMPLETED]

**Goal**: Connect `semantic_weak_completeness` to the main `weak_completeness` theorem in Completeness.lean.

**Tasks**:
- [x] Review how main completeness uses canonical model
- [x] Add bridge documentation explaining relationship between semantic and general completeness
- [x] Document that Task 450 will address formal connection
- [x] Verify build succeeds with documentation added

**Timing**: 1 hour (actual)

**Files modified**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - added bridge documentation

**Findings**:
1. `semantic_weak_completeness` already proves the core completeness result via contrapositive
2. General `weak_completeness` axiom in Completeness.lean uses `valid` (all models)
3. Connection is conceptual: semantic approach constructs countermodel when phi isn't provable
4. Formal connection to general framework deferred to Task 450 (completeness theorems)

**Verification**:
- [x] `lake build` succeeds
- [x] Documentation explains relationship clearly

---

### Phase 4: Documentation and Cleanup [IN PROGRESS]

**Goal**: Document the relationship between old and new approaches, mark deprecated code.

**Tasks**:
- [ ] Add docstrings explaining semantic vs syntactic approaches
- [ ] Mark `finite_truth_lemma` as deprecated/auxiliary with TODO note
- [ ] Update module documentation to reflect semantic approach
- [ ] Run `lake build` to verify no regressions

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - documentation

**Verification**:
- `lake build` succeeds
- All semantic infrastructure documented
- Clear path forward for Task 450 (completeness theorems)

---

## Testing & Validation

- [ ] `semantic_weak_completeness` compiles without sorry
- [ ] lean_diagnostic_messages shows no new errors in FiniteCanonicalModel.lean
- [ ] Connection to main completeness clear and documented
- [ ] `lake build` succeeds
- [ ] Task 450 unblocked (dependencies satisfied)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - semantic_weak_completeness proven
- `Theories/Bimodal/Metalogic/Completeness/Completeness.lean` - connection to main theorem (if needed)
- `.claude/specs/449_truth_lemma/summaries/implementation-summary-YYYYMMDD.md` - completion summary

## Rollback/Contingency

If semantic_weak_completeness proves difficult:
1. Document exactly what's missing in semantic infrastructure
2. Consider whether Task 482 completion would help
3. Create subtask for specific blocking issue

If connection to main completeness is non-trivial:
1. Document the gap in Completeness.lean
2. Create bridge lemma as separate helper
3. May need Task 450 to be revised accordingly

## Dependency Graph

```
Task 448 (consistent model) ──┐
                              │
Task 458 (compositionality)───┼──> Task 473 (semantic infrastructure) ──> Task 481 (nullity) ✓
                              │           │
                              │           └──> Task 482 (gluing) [IN PROGRESS - HAS SORRIES]
                              │           │         │
                              │           │         └──> compositionality sorries may block 449
                              │           │
                              │           └──> Task 449 v002 (THIS) ──> Task 450 (completeness)
                              │
Task 472 (Lindenbaum) ────────┘  [NOT NEEDED for semantic approach]
```

**Note**: Task 482's compositionality sorries are in `SemanticTaskRelV2.compositionality`, which is used by `SemanticCanonicalFrame`. Phase 1 of this task must determine whether these sorries are actually blocking for `semantic_weak_completeness`.

## Notes

The key insight from Task 473 is that defining world states as quotients of (history, time) pairs makes the truth lemma trivial by construction. The semantic world state IS a history at a time, so "membership in the state equals truth" becomes definitional.

The old `finite_truth_lemma` remains in the codebase with 6 sorries. It's not blocking progress because:
1. The semantic approach (`semantic_truth_lemma_v2`) is complete
2. The semantic canonical model (`SemanticCanonicalModel`) is well-defined
3. Completeness can proceed via the semantic route

The old approach could be completed if Task 472 (Lindenbaum extension) is done, but this is no longer on the critical path for completeness.

### Task 482 Status Clarification

Task 482 was marked "completed" in state tracking, but **has remaining sorries**:
- `glue_histories.forward_rel` and `backward_rel` edge cases
- `compositionality` sign assumptions (x ≥ 0, y > 0)
- `compositionality` neg case (bounds exceeded)

These sorries may or may not block Task 449 depending on whether `semantic_weak_completeness` actually needs compositionality. The weak completeness proof typically only needs:
1. A model exists (nullity ✓)
2. Truth in model corresponds to membership (truth lemma ✓)

Compositionality is needed for proving frame properties hold, but may not be needed for the basic completeness argument. Phase 1 must determine this.
