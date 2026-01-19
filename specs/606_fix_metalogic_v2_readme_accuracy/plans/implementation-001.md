# Implementation Plan: Task #606

- **Task**: 606 - fix_metalogic_v2_readme_accuracy
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/606_fix_metalogic_v2_readme_accuracy/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Update Metalogic_v2/README.md to accurately document the 5 active sorries found by research. The current README incorrectly claims all theorems are fully proven with no sorry statements. This is a straightforward documentation update requiring: (1) updating the "Proven (no sorry)" section header, (2) adding a new section documenting theorems with sorries, and (3) replacing the false claim at line 93.

### Research Integration

Research report (research-001.md) identified:
- 5 active sorries in Representation/ subdirectory
- Specific locations: Closure.lean:484, SemanticCanonicalModel.lean:207/419/569, FiniteWorldState.lean:321
- Several "proven" theorems have transitive dependencies on sorried lemmas
- Recommended Conservative Documentation approach with table format

## Goals & Non-Goals

**Goals**:
- Accurately document the 5 active sorries in Metalogic_v2
- Distinguish between theorems with direct sorries vs transitive dependencies
- Preserve README structure while adding accuracy
- Provide actionable information about sorry locations

**Non-Goals**:
- Fixing the actual sorries (that's a separate task)
- Complete dependency graph documentation
- Restructuring the entire README

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Users think entire module is broken | Medium | Low | Clarify that soundness and many core theorems ARE fully proven |
| Sorry count becomes outdated | Low | Medium | Add date stamp and note to verify with grep |
| Overly pessimistic framing | Medium | Low | Highlight proof structure is correct, only bridges need completion |

## Implementation Phases

### Phase 1: Review and Verify README Structure [COMPLETED]

**Goal**: Confirm current README structure and verify sorry locations are still accurate.

**Tasks**:
- [ ] Read current README.md to confirm line numbers for edits
- [ ] Run grep to verify 5 sorries still exist at documented locations
- [ ] Note exact text that needs replacement

**Timing**: 5 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic_v2/README.md` - confirm lines 73 and 93

**Verification**:
- Line 73 contains "### Proven (no sorry)"
- Line 93 contains false claim about no sorries

---

### Phase 2: Update "Proven" Section Header [COMPLETED]

**Goal**: Change section header from "### Proven (no sorry)" to "### Core Theorems" to remove false claim.

**Tasks**:
- [ ] Edit line 73 to change "### Proven (no sorry)" to "### Core Theorems"

**Timing**: 2 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/README.md` - line 73

**Verification**:
- Section heading no longer claims "no sorry"

---

### Phase 3: Add "Theorems with Sorries" Section [COMPLETED]

**Goal**: Add new section documenting the 5 sorried theorems with locations and impact.

**Tasks**:
- [ ] Add new section after the Core Theorems table (after line 91)
- [ ] Include table with Location, Theorem, Issue columns
- [ ] Add impact statement about transitive dependencies

**Timing**: 5 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/README.md` - insert after line 91

**New content**:
```markdown
### Theorems with Sorries (5 total)

| Location | Theorem | Issue |
|----------|---------|-------|
| Closure.lean:484 | `closure_mcs_neg_complete` | Double-negation escape |
| SemanticCanonicalModel.lean:207 | `semantic_task_rel_compositionality` | History gluing |
| SemanticCanonicalModel.lean:419 | `semantic_truth_implies_truth_at` | Formula induction |
| SemanticCanonicalModel.lean:569 | `main_weak_completeness_v2` | Truth bridge |
| FiniteWorldState.lean:321 | `closure_mcs_implies_locally_consistent` | Temporal axioms |

**Impact**: The completeness theorems (`weak_completeness`, `strong_completeness`) and FMP-related theorems transitively depend on these sorries through `main_provable_iff_valid_v2`.
```

**Verification**:
- New section appears with 5 sorries documented

---

### Phase 4: Update False Claim at Line 93 [COMPLETED]

**Goal**: Replace the false claim about no sorry statements with accurate status.

**Tasks**:
- [ ] Replace line 93 text with accurate status statement
- [ ] Clarify what IS fully proven vs what depends on sorries

**Timing**: 3 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/README.md` - line 93 (now shifted due to Phase 3 insertion)

**New content**:
```markdown
The Metalogic_v2 infrastructure has **5 active sorries** in the semantic bridge layer. Core theorems like soundness, deduction theorem, and MCS properties are fully proven. Completeness theorems are structurally correct but rely on the semantic bridge sorries.
```

**Verification**:
- No longer claims all theorems have no sorry statements

---

### Phase 5: Verification [COMPLETED]

**Goal**: Verify README accurately reflects codebase state.

**Tasks**:
- [ ] Run grep to confirm sorry count matches documentation
- [ ] Read updated README to verify formatting and accuracy
- [ ] Confirm all changes are coherent

**Timing**: 5 minutes

**Verification command**:
```bash
grep -rn "sorry" Theories/Bimodal/Metalogic_v2/ | grep -v "no sorry" | wc -l
```

**Verification**:
- Grep shows 5 active sorries (matching documentation)
- README is well-formatted with no broken tables

---

## Testing & Validation

- [ ] Grep shows exactly 5 sorries in Metalogic_v2 (excluding "no sorry" text)
- [ ] README renders correctly with proper markdown formatting
- [ ] Section header no longer claims "no sorry"
- [ ] New section lists all 5 sorries with locations
- [ ] Impact statement accurately describes transitive dependencies

## Artifacts & Outputs

- `plans/implementation-001.md` - This plan file
- `summaries/implementation-summary-{DATE}.md` - Completion summary (after implementation)
- Modified: `Theories/Bimodal/Metalogic_v2/README.md`

## Rollback/Contingency

If changes introduce formatting issues or are incorrect:
- Git revert the commit modifying README.md
- Re-verify sorry locations with fresh grep
- Adjust documentation accordingly
