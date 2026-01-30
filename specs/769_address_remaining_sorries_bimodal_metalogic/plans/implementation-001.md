# Implementation Plan: Address Remaining Sorries in Bimodal/Metalogic

- **Task**: 769 - Address remaining sorries in Bimodal/Metalogic
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/769_address_remaining_sorries_bimodal_metalogic/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task addresses the 20 remaining sorries in `Theories/Bimodal/Metalogic/` (excluding Examples/ and Boneyard/) to achieve a zero sorry count. Research confirmed that `semantic_weak_completeness` is already sorry-free and provides the canonical completeness theorem. The 20 sorries fall into three categories:

1. **IMPOSSIBLE/ARCHITECTURAL (7 sorries)**: Mathematically false or require infinite derivation rules
2. **NOT REQUIRED for Completeness (13 sorries)**: In code paths unused by the main theorem

Per user guidance, the strategy is to first attempt proofs where feasible, then remove sorried code that is proven impossible or unused.

### Research Integration

Integrated findings from research-001.md:
- `semantic_weak_completeness` provides sorry-free completeness (no changes needed)
- All 20 sorries are either impossible or in unused code paths
- User guidance: remove code with sorries that cannot be resolved

## Goals & Non-Goals

**Goals**:
- Achieve zero sorry count in `Theories/Bimodal/Metalogic/` (excluding Boneyard/ and Examples/)
- Verify that removed code is genuinely unused by completeness
- Maintain a building codebase throughout
- Update documentation to reflect architectural decisions

**Non-Goals**:
- Fixing sorries in Examples/ or Boneyard/
- Changing the completeness proof architecture
- Adding new theorems or features

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing code that IS used | High | Low | Verify usages with grep before removal; lake build after each removal |
| Breaking imports | Medium | Medium | Check all files that import modified modules |
| Incomplete sorry removal | Medium | Low | Use `grep -r sorry` to verify zero count after each phase |

## Implementation Phases

### Phase 1: Verify Completeness Path Independence [IN PROGRESS]

**Goal**: Confirm that `semantic_weak_completeness` does not depend on any sorried theorems, and identify the exact dependency chain.

**Tasks**:
- [ ] Trace `semantic_weak_completeness` dependencies (should NOT use UniversalCanonicalFrame)
- [ ] Verify `UniversalCanonicalFrame.compositionality` (uses `canonical_task_rel_comp`) is NOT on completeness path
- [ ] Verify `construct_coherent_family` (uses `mcs_unified_chain_pairwise_coherent`) is NOT on completeness path
- [ ] Document findings in code comments

**Timing**: 30 minutes

**Files to analyze**:
- `FMP/SemanticCanonicalModel.lean` - trace semantic_weak_completeness
- `Representation/CanonicalHistory.lean` - check if UniversalCanonicalFrame is used
- `Representation/CoherentConstruction.lean` - check if construct_coherent_family is used

**Verification**:
- Create dependency diagram showing semantic_weak_completeness is sorry-free
- Confirm removal candidates are NOT imported by completeness path

---

### Phase 2: Remove TaskRelation Compositionality Sorries (5 sorries) [NOT STARTED]

**Goal**: Remove `canonical_task_rel_comp` and associated code from TaskRelation.lean, as it is not required for completeness.

**Tasks**:
- [ ] Verify `canonical_task_rel_comp` is only used by `UniversalCanonicalFrame`
- [ ] Verify `UniversalCanonicalFrame` is not on `semantic_weak_completeness` dependency path
- [ ] Add deprecation comment to `canonical_task_rel_comp` explaining why removed
- [ ] Mark theorem as `@[deprecated]` or remove entirely
- [ ] Update any imports if needed
- [ ] Run `lake build` to verify no breakage

**Timing**: 45 minutes

**Files to modify**:
- `Representation/TaskRelation.lean` - remove/deprecate `canonical_task_rel_comp`
- `Representation/CanonicalHistory.lean` - may need to update `UniversalCanonicalFrame` definition

**Verification**:
- `lake build` passes
- `grep -r "canonical_task_rel_comp"` shows no active usages (only comments/docs)
- Sorry count reduced by 5

---

### Phase 3: Remove CoherentConstruction Cross-Origin Sorries (8 sorries) [NOT STARTED]

**Goal**: Remove `mcs_unified_chain_pairwise_coherent` and associated code from CoherentConstruction.lean, as it is not required for completeness.

**Tasks**:
- [ ] Verify `mcs_unified_chain_pairwise_coherent` is only used by `construct_coherent_family`
- [ ] Verify `construct_coherent_family` is not on `semantic_weak_completeness` dependency path
- [ ] Add deprecation comment explaining why removed
- [ ] Mark theorem as `@[deprecated]` or remove entirely
- [ ] Update any imports if needed
- [ ] Run `lake build` to verify no breakage

**Timing**: 45 minutes

**Files to modify**:
- `Representation/CoherentConstruction.lean` - remove/deprecate cross-origin cases

**Verification**:
- `lake build` passes
- Sorry count reduced by 8 (total: 13 removed)

---

### Phase 4: Handle TruthLemma Architectural Sorries (4 sorries) [NOT STARTED]

**Goal**: Address the 4 sorries in TruthLemma.lean (box cases and temporal backward direction) which are documented as architectural limitations.

**Tasks**:
- [ ] Verify `truth_lemma` is not used by `semantic_weak_completeness`
- [ ] Add detailed documentation explaining why these cases are IMPOSSIBLE:
  - Box cases (lines 373, 396): S5-style universal quantification over ALL histories
  - Temporal backward (lines 423, 445): requires omega-rule
- [ ] Option A: Mark lemma as `@[deprecated]` with documentation pointing to `semantic_weak_completeness`
- [ ] Option B: Remove the lemma entirely if truly unused
- [ ] Run `lake build` to verify

**Timing**: 45 minutes

**Files to modify**:
- `Representation/TruthLemma.lean` - deprecate or remove truth_lemma

**Verification**:
- `lake build` passes
- Sorry count reduced by 4 (total: 17 removed)

---

### Phase 5: Handle FMP Architectural Sorries (3 sorries) [NOT STARTED]

**Goal**: Address the remaining 3 architectural sorries in FMP/ directory.

**Tasks**:
- [ ] SemanticCanonicalModel.lean line 225 (`compositionality`): Add deprecation notice to SemanticCanonicalFrame, noting it's only used for theoretical completeness (not semantic_weak_completeness)
- [ ] SemanticCanonicalModel.lean line 683 (`truth_at_implies_semantic_truth`): Mark as `@[deprecated]` with detailed documentation of architectural limitation
- [ ] FiniteModelProperty.lean line 229 (`finite_model_property_constructive`): Mark as `@[deprecated]` pointing to `semantic_weak_completeness`
- [ ] Run `lake build` to verify

**Timing**: 45 minutes

**Files to modify**:
- `FMP/SemanticCanonicalModel.lean` - deprecate compositionality and truth_at_implies_semantic_truth
- `FMP/FiniteModelProperty.lean` - deprecate finite_model_property_constructive

**Verification**:
- `lake build` passes
- Sorry count reduced by 3 (total: 20 removed)
- Zero sorry count in Metalogic/ (excluding Boneyard/, Examples/)

---

### Phase 6: Documentation and Verification [NOT STARTED]

**Goal**: Update documentation and perform final verification of zero sorry count.

**Tasks**:
- [ ] Run comprehensive sorry count verification: `grep -r "sorry" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Examples | grep -v Boneyard`
- [ ] Update `FMP/README.md` to document removal decisions
- [ ] Update `Representation/README.md` if it exists
- [ ] Update `Metalogic.lean` module documentation
- [ ] Final `lake build` to ensure clean compilation

**Timing**: 30 minutes

**Files to modify**:
- `FMP/README.md` - update status of architectural theorems
- `Metalogic.lean` - update module-level documentation
- Any other README.md files in Metalogic/

**Verification**:
- `grep -r "sorry"` returns zero matches in Metalogic/ (excluding Boneyard/, Examples/)
- `lake build` passes cleanly
- All README files accurately describe current state

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Examples | grep -v Boneyard | wc -l` returns 0
- [ ] `semantic_weak_completeness` still compiles and is sorry-free
- [ ] No regression in any existing proofs

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (upon completion)
- Updated Lean files with deprecation notices
- Updated README documentation

## Rollback/Contingency

If removal of any theorem breaks unexpected dependencies:
1. Restore the theorem with its sorry
2. Mark as `@[deprecated]` instead of removing
3. Add extensive documentation explaining why sorry cannot be removed
4. Update plan to reflect partial completion

Git provides full rollback capability via `git checkout -- <file>` for any phase.
