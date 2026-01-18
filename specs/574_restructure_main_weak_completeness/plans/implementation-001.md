# Implementation Plan: Task #574

- **Task**: 574 - Restructure main_weak_completeness with semantic_truth_at_v2
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Priority**: Medium
- **Dependencies**: None (follows task 570 analysis)
- **Research Inputs**: specs/574_restructure_main_weak_completeness/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/formats/plan-format.md
  - .claude/context/core/formats/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Task 574 restructures `main_weak_completeness` to eliminate the unprovable bridge lemma `truth_at_implies_semantic_truth`. The research (task 570) identified that this bridge is architecturally unprovable because `IsLocallyConsistent` provides soundness (compound true => parts true) but the bridge requires completeness (parts true => compound true). The restructuring will use MCS-derivation constraints to prove the bridge for canonical model histories, or alternatively document the architectural limitation while preserving the proven core completeness result.

### Research Integration

The research report identifies four approaches:
1. **Semantic validity definition** - Reorganizes problem without solving it
2. **MCS-derived history restriction** - Provable but requires substantial refactoring (4-6 hours)
3. **Documentation only** - Accept bridge sorries, document clearly (1 hour)
4. **Contrapositive restructuring** - Alternative proof direction (6-8 hours)

Research recommends **MCS-derived history approach** (Priority 2) as most direct path to sorry-free completeness.

## Goals & Non-Goals

**Goals**:
- Eliminate the 4 compound formula sorries in `truth_at_implies_semantic_truth`
- Preserve the signature of `main_weak_completeness: valid phi -> |- phi`
- Maintain compatibility with existing imports and usage
- Ensure all completeness theorems remain proven

**Non-Goals**:
- Changing the core `semantic_weak_completeness` theorem (already proven)
- Modifying the `valid` definition in Semantics/Validity.lean
- Restructuring the entire canonical model architecture
- Addressing completeness theorems outside the finite canonical model

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MCS derivation proof more complex than estimated | High | Medium | Start with proof sketches, verify approach before full implementation |
| Breaking existing imports of `main_weak_completeness` | Medium | Low | Keep signature unchanged, only modify proof body |
| Contrapositive direction also requires unprovable bridge | High | Medium | Research phase identified this; verify MCS approach first |
| Circular dependency between MCS properties | High | Low | Check dependency graph before starting implementation |

## Implementation Phases

### Phase 1: Analysis and Proof Sketch [NOT STARTED]

**Goal**: Verify MCS-derived history approach is viable and sketch core lemmas.

**Tasks**:
- [ ] Read FiniteCanonicalModel.lean sections on `truth_at_implies_semantic_truth`
- [ ] Identify all `SemanticWorldState` and `WorldHistory` construction points in canonical model
- [ ] Verify that all histories in `SemanticCanonicalModel` are constructed from MCS via `finiteHistoryToWorldHistory`
- [ ] Sketch `mcs_derived_history` predicate definition
- [ ] Sketch proof that `truth_at_implies_semantic_truth` holds for MCS-derived histories
- [ ] Verify no circular dependencies in MCS infrastructure (closure_mcs_negation_complete, etc.)

**Timing**: 1.5 hours

**Files to read**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Main completeness proofs
- `Theories/Bimodal/Semantics/Kripke.lean` - WorldHistory and SemanticWorldState definitions
- `Theories/Bimodal/Metalogic/Completeness/MaximalConsistentSet.lean` - MCS properties

**Verification**:
- Proof sketch compiles or has clear gaps identified
- No circular dependencies found
- All `SemanticWorldState` constructions traced to MCS origin

---

### Phase 2: Define MCS-Derived History Predicate [NOT STARTED]

**Goal**: Formalize the `mcs_derived_history` predicate and prove all canonical model histories satisfy it.

**Tasks**:
- [ ] Define `mcs_derived_history` predicate in FiniteCanonicalModel.lean
- [ ] Prove `semantic_world_state_mcs_derived`: All `SemanticWorldState`s come from MCS
- [ ] Prove `world_history_mcs_derived`: All histories in `SemanticCanonicalModel` are MCS-derived
- [ ] Add documentation explaining the predicate's purpose

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add predicate and proofs

**Verification**:
- `mcs_derived_history` defined with clear type signature
- `semantic_world_state_mcs_derived` proven (no sorries)
- `world_history_mcs_derived` proven (no sorries)
- `lake build` succeeds with no new errors

---

### Phase 3: Prove Bridge for MCS-Derived Histories [NOT STARTED]

**Goal**: Prove `truth_at_implies_semantic_truth` restricted to MCS-derived histories.

**Tasks**:
- [ ] Create `truth_at_implies_semantic_truth_mcs` lemma with MCS-derivation hypothesis
- [ ] Prove atom case (already works, copy from existing)
- [ ] Prove neg case (already works, copy from existing)
- [ ] Prove and case (already works, copy from existing)
- [ ] Prove or case (already works, copy from existing)
- [ ] Prove imp case using MCS negation-completeness property
- [ ] Prove box case using MCS closure properties
- [ ] Prove all_past case using history construction properties
- [ ] Prove all_future case using history construction properties

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - New lemma and proofs

**Verification**:
- `truth_at_implies_semantic_truth_mcs` proven for all 8 formula cases
- No sorries in any case
- Lemma type signature matches original except for added MCS hypothesis
- `lake build` succeeds

---

### Phase 4: Restructure main_weak_completeness [NOT STARTED]

**Goal**: Update `main_weak_completeness` to use the MCS-restricted bridge lemma.

**Tasks**:
- [ ] Modify `main_weak_completeness` proof to use `truth_at_implies_semantic_truth_mcs`
- [ ] Add proof that the specific history used satisfies `mcs_derived_history`
- [ ] Verify the proof connects `valid phi` to `|- phi` through MCS bridge
- [ ] Remove or mark deprecated the old `truth_at_implies_semantic_truth` with sorries
- [ ] Update documentation explaining the MCS restriction

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Update main theorem

**Verification**:
- `main_weak_completeness` proven (no sorries)
- `main_provable_iff_valid` still proven (wraps main_weak_completeness)
- Signature of `main_weak_completeness` unchanged
- All existing imports of the theorem still compile
- `lake build` succeeds

---

### Phase 5: Testing and Documentation [NOT STARTED]

**Goal**: Verify all completeness theorems compile, test imports, and document changes.

**Tasks**:
- [ ] Run `lake build` on Theories/Bimodal/Metalogic/
- [ ] Check for regressions in dependent files using `grep -r "main_weak_completeness"`
- [ ] Update comments in FiniteCanonicalModel.lean explaining MCS derivation approach
- [ ] Verify `main_provable_iff_valid` and all wrapper theorems still proven
- [ ] Check that no new sorries were introduced anywhere
- [ ] Document the MCS-restriction approach in implementation summary

**Timing**: 1.5 hours

**Files to check**:
- All files importing `FiniteCanonicalModel.lean`
- `Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean` - Verify unaffected

**Verification**:
- `lake build` succeeds on entire Theories/Bimodal directory
- No new sorries in any file
- All dependent files compile without errors
- Implementation summary created with clear documentation of approach

## Testing & Validation

- [ ] `lake build` succeeds on Theories/Bimodal/Metalogic/Completeness/
- [ ] Zero sorries in `truth_at_implies_semantic_truth_mcs`
- [ ] Zero sorries in `main_weak_completeness`
- [ ] `main_provable_iff_valid` still proven
- [ ] No regressions in files importing FiniteCanonicalModel.lean
- [ ] `lean_diagnostic_messages` shows no new errors
- [ ] All 8 formula cases proven in bridge lemma

## Artifacts & Outputs

- `specs/574_restructure_main_weak_completeness/plans/implementation-001.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
- `specs/574_restructure_main_weak_completeness/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If MCS-derived history approach fails:

1. **Fallback to documentation approach** (Priority 3 from research):
   - Keep existing sorries in `truth_at_implies_semantic_truth`
   - Add comprehensive documentation explaining architectural limitation
   - Document that `semantic_weak_completeness` is the proven core result
   - Effort: 1 hour

2. **Rollback procedure**:
   - `git restore Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
   - Remove plan and partial summary artifacts
   - Mark task as BLOCKED with reason: "MCS approach has circular dependencies"

3. **Alternative: Contrapositive approach** (Priority 3 alternative from research):
   - Only pursue if MCS approach fundamentally blocked
   - Requires 6-8 hours additional effort
   - May encounter same bridge issue in opposite direction
