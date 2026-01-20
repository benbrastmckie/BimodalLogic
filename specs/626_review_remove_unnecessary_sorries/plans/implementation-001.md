# Implementation Plan: Task #626

- **Task**: 626 - Review and remove unnecessary theorems/lemmas with sorries
- **Status**: [IMPLEMENTING]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/626_review_remove_unnecessary_sorries/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Systematically clean up Metalogic_v2 by removing 4 unnecessary theorems with sorries and relocating 3 useful but deprecated theorems to the Boneyard. The research identified 8 sorries total, with the main completeness chain (`semantic_weak_completeness`) already sorry-free. This cleanup reduces technical debt while preserving valuable historical context in the Boneyard.

### Research Integration

Integrated from research-001.md:
- Identified 4 DELETE candidates: `tableau_complete`, `decide_complete`, `closed_extend_closed`, `add_neg_causes_closure`
- Identified 3 RELOCATE candidates: `semantic_task_rel_compositionality`, `semantic_truth_implies_truth_at`, `main_weak_completeness_v2`
- Confirmed main proof chain is sorry-free via `semantic_weak_completeness`
- Boneyard pattern established in `Theories/Bimodal/Boneyard/`

## Goals & Non-Goals

**Goals**:
- Remove all unnecessary sorries from Metalogic_v2
- Relocate useful deprecated code to Boneyard with documentation
- Maintain working build after each change
- Update dependent code where necessary

**Non-Goals**:
- Proving the optional `decide_axiom_valid` theorem (deferred, not critical)
- Modifying the main completeness chain (already sorry-free)
- Restructuring file organization beyond sorry cleanup

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden dependencies on deleted theorems | High | Low | Grep for all theorem names before deletion; research confirmed none |
| Build breakage after changes | Medium | Medium | Run `lake build` after each phase; atomic changes |
| Losing useful documentation | Medium | Low | Relocate to Boneyard with full context, follow existing pattern |

## Implementation Phases

### Phase 1: Delete unused BranchClosure theorems [COMPLETED]

**Goal**: Remove two unused theorems with sorries from BranchClosure.lean

**Tasks**:
- [ ] Delete `closed_extend_closed` (lines 174-201)
- [ ] Delete `add_neg_causes_closure` (lines 203-226)
- [ ] Run `lake build` to verify no dependencies

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/BranchClosure.lean` - remove two theorems

**Verification**:
- `lake build` succeeds
- `grep -r "closed_extend_closed\|add_neg_causes_closure" Theories/` returns no matches (except comments)

---

### Phase 2: Delete decision procedure completeness theorems [IN PROGRESS]

**Goal**: Remove tableau completeness and decision procedure completeness theorems (alternative decidability path not taken)

**Tasks**:
- [ ] Delete `tableau_complete` from Correctness.lean
- [ ] Delete `decide_complete` from Correctness.lean
- [ ] Run `lake build` to verify no dependencies

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` - remove two theorems

**Verification**:
- `lake build` succeeds
- `grep -r "tableau_complete\|decide_complete" Theories/` returns no matches (except comments)

---

### Phase 3: Create Boneyard file for deprecated SemanticCanonicalModel code [NOT STARTED]

**Goal**: Create a new Boneyard file to hold deprecated theorems from SemanticCanonicalModel.lean

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/DeprecatedCompleteness.lean` with header documentation
- [ ] Copy `semantic_task_rel_compositionality` with context explaining the mathematical limitation
- [ ] Copy `semantic_truth_implies_truth_at` with context explaining the deprecated bridge approach
- [ ] Copy `main_weak_completeness_v2` with context explaining the alternative approach
- [ ] Add imports and necessary scaffolding for the file to compile (may require `sorry` or `axiom` placeholders)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/DeprecatedCompleteness.lean` - create new file
- `Theories/Bimodal/Boneyard/README.md` - add section documenting new file

**Verification**:
- New Boneyard file exists with proper documentation
- README updated with new entry

---

### Phase 4: Remove relocated theorems from SemanticCanonicalModel [NOT STARTED]

**Goal**: Delete the deprecated theorems that were relocated to Boneyard

**Tasks**:
- [ ] Delete `semantic_task_rel_compositionality` (lines 191-236)
- [ ] Delete `semantic_truth_implies_truth_at` (lines 457-523)
- [ ] Delete `main_weak_completeness_v2` (lines 685-768)
- [ ] Update `SemanticCanonicalFrame` to use `sorry` for compositionality axiom (frame definition requires it)
- [ ] Run `lake build` to check for downstream breakage

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - remove three theorems

**Verification**:
- `lake build` succeeds (or documents expected failures)
- Grep confirms theorems removed

---

### Phase 5: Update dependent code and finalize [NOT STARTED]

**Goal**: Fix any downstream dependencies and finalize the cleanup

**Tasks**:
- [ ] Check if `main_provable_iff_valid_v2` needs updating (may depend on `main_weak_completeness_v2`)
- [ ] If needed, route `main_provable_iff_valid_v2` through `semantic_weak_completeness` instead
- [ ] Check `FiniteModelProperty.lean` for any dependencies on removed theorems
- [ ] Run full `lake build` verification
- [ ] Update Metalogic_v2 README.md with new sorry count (should be reduced)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - update dependent code if needed
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` - update if needed
- `Theories/Bimodal/Metalogic_v2/README.md` - update sorry count

**Verification**:
- `lake build` succeeds for entire project
- `grep -rn "sorry" Theories/Bimodal/Metalogic_v2/` shows reduced count
- README reflects accurate sorry count

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No regressions in main completeness chain (semantic_weak_completeness still works)
- [ ] Boneyard file compiles (with expected sorries/axioms)
- [ ] All grep searches confirm no orphaned references to deleted theorems
- [ ] Final sorry count in Metalogic_v2 is reduced from 8 to ~1-2 (compositionality in frame, decide_axiom_valid if kept)

## Artifacts & Outputs

- `specs/626_review_remove_unnecessary_sorries/plans/implementation-001.md` (this file)
- `Theories/Bimodal/Boneyard/DeprecatedCompleteness.lean` (new file)
- `specs/626_review_remove_unnecessary_sorries/summaries/implementation-summary-YYYYMMDD.md` (completion summary)

## Rollback/Contingency

If cleanup causes unexpected build failures:
1. Use `git diff` to identify the problematic deletion
2. Restore the specific theorem with `git checkout -- <file>`
3. Add comment explaining why theorem cannot be removed
4. Continue with remaining phases

Git provides full rollback capability via:
```bash
git checkout -- Theories/Bimodal/Metalogic_v2/
git checkout -- Theories/Bimodal/Boneyard/
```
