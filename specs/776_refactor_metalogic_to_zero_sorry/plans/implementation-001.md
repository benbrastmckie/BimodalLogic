# Implementation Plan: Task #776

- **Task**: 776 - Refactor Metalogic to zero sorry
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: None (research complete)
- **Research Inputs**: specs/776_refactor_metalogic_to_zero_sorry/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task eliminates 3 sorries in `Theories/Bimodal/Metalogic/FMP/` by archiving deprecated code paths to `Boneyard/Metalogic_v4/FMP/`. The research confirms that all 3 sorries are in deprecated code: (1) compositionality is mathematically false for bounded time domains, (2) truth_at_implies_semantic_truth has an architectural impossibility, and (3) finite_model_property_constructive depends on #2. The main completeness theorem `semantic_weak_completeness` is already sorry-free.

### Research Integration

Key findings from research-001.md:
- All 3 sorries exist in deprecated code paths marked "Task 769"
- `semantic_weak_completeness` is the canonical sorry-free completeness result
- The `valid -> provable` bridge inherently requires the truth lemma gap
- Archival is the recommended approach, preserving code for reference

## Goals & Non-Goals

**Goals**:
- Achieve zero sorry count in `Theories/Bimodal/Metalogic/`
- Archive deprecated code with clear documentation
- Preserve `semantic_weak_completeness` as the primary completeness theorem
- Update `WeakCompleteness.lean` to document the architectural limitation
- Maintain clean imports and compilation

**Non-Goals**:
- Proving the mathematically impossible compositionality property
- Bridging the truth lemma gap (architecturally blocked)
- Changing the fundamental semantics or frame definitions
- Modifying code outside Metalogic/ directory

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import breakage | High | Medium | Test compilation after each archive step |
| Missing dependencies | Medium | Low | Track all uses of deprecated definitions before archiving |
| Documentation gaps | Low | Low | Include comprehensive archive headers with pointers |
| Missed sorry | High | Low | Run grep for sorry in Metalogic/ after completion |

## Implementation Phases

### Phase 1: Prepare Boneyard Structure [COMPLETED]

**Goal**: Create the archive directory structure and header documentation

**Tasks**:
- [ ] Create `Boneyard/Metalogic_v4/FMP/` directory
- [ ] Create `Boneyard/Metalogic_v4/FMP/README.md` explaining the archive
- [ ] Document the 3 sorries and why each is unfixable
- [ ] Document the sorry-free alternative (`semantic_weak_completeness`)

**Timing**: 20 minutes

**Files to create**:
- `Boneyard/Metalogic_v4/FMP/README.md` - Archive documentation

**Verification**:
- Directory structure exists
- README clearly explains context and pointers to sorry-free code

---

### Phase 2: Archive SemanticCanonicalFrame Code [COMPLETED]

**Goal**: Move deprecated frame and model definitions to Boneyard

**Tasks**:
- [ ] Create `Boneyard/Metalogic_v4/FMP/SemanticCanonicalFrame.lean`
- [ ] Move `SemanticCanonicalFrame` definition (lines 226-233) with sorry
- [ ] Move `SemanticCanonicalModel` definition (lines 246-248)
- [ ] Move `finiteHistoryToWorldHistory` (lines 279-302)
- [ ] Move `semantic_world_state_has_world_history` (lines 317-332)
- [ ] Add comprehensive header documentation explaining deprecation
- [ ] Remove definitions from `SemanticCanonicalModel.lean`
- [ ] Verify `SemanticCanonicalModel.lean` still compiles

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Remove deprecated definitions
- `Boneyard/Metalogic_v4/FMP/SemanticCanonicalFrame.lean` - New archive file

**Verification**:
- `lake build Theories.Bimodal.Metalogic.FMP.SemanticCanonicalModel` succeeds
- Sorry count in SemanticCanonicalModel.lean reduced by 1

---

### Phase 3: Archive Truth Lemma Gap Code [COMPLETED]

**Goal**: Move truth lemma related theorems that depend on the architectural gap

**Tasks**:
- [ ] Create `Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean`
- [ ] Move `truth_at_atom_iff_semantic` (lines 561-575)
- [ ] Move `truth_at_bot_iff_semantic` (lines 580-595)
- [ ] Move `truth_at_implies_semantic_truth` (lines 664-695) with sorry
- [ ] Move `valid_implies_semantic_truth` (lines 702-715)
- [ ] Move `valid_implies_neg_unsatisfiable` (lines 744-753)
- [ ] Move `set_mcs_neg_excludes_helper` (lines 758-760)
- [ ] Move `sorry_free_weak_completeness` (lines 797-801)
- [ ] Add header explaining the architectural limitation
- [ ] Remove definitions from `SemanticCanonicalModel.lean`
- [ ] Verify compilation

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Remove deprecated theorems
- `Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean` - New archive file

**Verification**:
- `lake build Theories.Bimodal.Metalogic.FMP.SemanticCanonicalModel` succeeds
- Sorry count in SemanticCanonicalModel.lean reduced by 1
- All moved theorems are self-contained in archive

---

### Phase 4: Archive FiniteModelProperty Code [COMPLETED]

**Goal**: Move the constructive FMP theorem with sorry to Boneyard

**Tasks**:
- [ ] Create `Boneyard/Metalogic_v4/FMP/FiniteModelPropertyConstructive.lean`
- [ ] Move `finite_model_property_constructive` (lines 161-235) with sorry
- [ ] Add header explaining dependency on truth bridge
- [ ] Remove definition from `FiniteModelProperty.lean`
- [ ] Verify compilation

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean` - Remove deprecated theorem
- `Boneyard/Metalogic_v4/FMP/FiniteModelPropertyConstructive.lean` - New archive file

**Verification**:
- `lake build Theories.Bimodal.Metalogic.FMP.FiniteModelProperty` succeeds
- Sorry count in FiniteModelProperty.lean reduced to 0

---

### Phase 5: Update WeakCompleteness and Documentation [COMPLETED]

**Goal**: Update public-facing completeness theorem documentation

**Tasks**:
- [ ] Update `WeakCompleteness.lean` `weak_completeness` theorem:
  - Remove dependency on `sorry_free_weak_completeness` (now archived)
  - Either remove theorem or add architectural note
- [ ] Add module docstring pointing to `semantic_weak_completeness`
- [ ] Update any imports that referenced archived code
- [ ] Update Metalogic directory README if present

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Update or remove
- Any files importing archived definitions

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Completeness.WeakCompleteness` succeeds (or file removed)
- No broken imports

---

### Phase 6: Verify Zero Sorry Count [COMPLETED]

**Goal**: Confirm all sorries eliminated from Metalogic/

**Tasks**:
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/`
- [ ] Verify count is 0
- [ ] Run `lake build Theories.Bimodal.Metalogic`
- [ ] Verify build succeeds without errors
- [ ] Document final state in implementation summary

**Timing**: 10 minutes

**Files to verify**:
- All files in `Theories/Bimodal/Metalogic/`

**Verification**:
- `grep -r "sorry" Theories/Bimodal/Metalogic/` returns no results
- Full Metalogic build succeeds

## Testing & Validation

- [ ] Each phase compiles after changes (`lake build` on affected files)
- [ ] No broken imports across Metalogic/
- [ ] Zero sorry count in `Theories/Bimodal/Metalogic/` (grep verification)
- [ ] `semantic_weak_completeness` remains accessible and unchanged
- [ ] Boneyard files have comprehensive documentation

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `Boneyard/Metalogic_v4/FMP/README.md` - Archive documentation
- `Boneyard/Metalogic_v4/FMP/SemanticCanonicalFrame.lean` - Archived frame with sorry #1
- `Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean` - Archived theorems with sorry #2
- `Boneyard/Metalogic_v4/FMP/FiniteModelPropertyConstructive.lean` - Archived theorem with sorry #3
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If archival breaks critical functionality:
1. Restore archived definitions from `Boneyard/` back to original files
2. Re-add imports
3. Run `lake build` to verify restoration
4. Document the issue blocking archival

Git provides full rollback capability via `git checkout HEAD~N -- <files>`.
