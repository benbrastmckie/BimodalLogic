# Implementation Plan: Task #698

- **Task**: 698 - Fix ROAD_MAP.md content and style issues
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/698_fix_roadmap_content_and_style_issues/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Update ROAD_MAP.md to fix 9 content accuracy and style issues identified via FIX: and NOTE: tags. The research report documents that architecture tables reference deprecated Metalogic_v2 paths in Boneyard while actual code is in `Theories/Bimodal/Metalogic/`. Changes include updating architecture tables, removing historical language and emojis, reversing diagram order, removing unnecessary links, and adding an initial phase for completing proofs.

### Research Integration

- Integrated: `specs/698_fix_roadmap_content_and_style_issues/reports/research-001.md` (2026-01-28)
- Key findings: Active code at `Theories/Bimodal/Metalogic/` differs from documented paths; 20+ sorries in active code; Boneyard contains potentially reusable elements

## Goals & Non-Goals

**Goals**:
- Update architecture tables to reflect actual Lean source code structure
- Remove checkmark emojis throughout the document
- Remove historical/promotional language ("Key Achievement", "Key Innovation", "Problem Solved")
- Reverse dependency diagram to show foundations at top
- Remove internal development artifact links
- Add Phase 0 for completing proofs and porting Boneyard elements

**Non-Goals**:
- Verify actual proof status in Lean files (beyond scope of this task)
- Rewrite entire roadmap structure
- Update TODO items or task checklist items

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Incorrect table updates | Medium | Low | Research report provides verified file structure |
| Missing FIX/NOTE tags | Low | Low | Research report catalogs all 9 tags |
| Breaking markdown formatting | Low | Medium | Verify each phase independently |

## Implementation Phases

### Phase 1: Remove Emojis and Historical Language [NOT STARTED]

**Goal**: Clean up style issues throughout the document - remove all checkmark emojis and replace promotional headings with neutral alternatives.

**Tasks**:
- [ ] Line 18: Change `### ✅ Metalogic_v2:` to `### Metalogic_v2:`
- [ ] Line 54: Change `#### Key Architectural Achievement` to `#### Architecture`
- [ ] Line 56: Remove "significant improvement" language, state factually
- [ ] Line 74: Change `### ✅ Bimodal/Metalogic:` to `### Bimodal/Metalogic:`
- [ ] Line 82: Change `#### Key Innovation: Indexed MCS Family Approach` to `#### Indexed MCS Family Approach`
- [ ] Line 84: Remove "**Problem Solved**:" prefix, state directly
- [ ] Line 168: Change `### ✅ Syntax and Semantics` to `### Syntax and Semantics`
- [ ] Line 176: Change `### ✅ Decidability Infrastructure` to `### Decidability Infrastructure`
- [ ] Remove FIX/NOTE comments at lines 52, 72, 80

**Timing**: 20 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Lines 18, 54, 56, 74, 82, 84, 168, 176

**Verification**:
- No checkmark emojis remain in document
- No "Key Achievement" or "Key Innovation" headings
- grep for remaining FIX/NOTE tags related to style

---

### Phase 2: Remove Unnecessary Sections [NOT STARTED]

**Goal**: Remove the Design Comparison table and Research Documentation links that contain historical comparisons and internal artifact references.

**Tasks**:
- [ ] Lines 131-143: Remove entire "Design Comparison" table section (including the NOTE comment at line 131)
- [ ] Lines 156-162: Remove entire "Research Documentation" section (including the NOTE comment at line 156)

**Timing**: 10 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Remove sections at lines 131-143 and 156-162

**Verification**:
- No "Design Comparison" section exists
- No links to specs/archive/ directories
- grep for remaining NOTE tags related to these sections

---

### Phase 3: Reverse Architecture Diagram [NOT STARTED]

**Goal**: Reverse the dependency diagram so foundations appear at top and derived results at bottom.

**Tasks**:
- [ ] Lines 60-70: Reverse order of diagram from:
  ```
  Applications (Compactness)
      ↓
  Completeness (Strong, Weak)
      ↓
  FMP (Central Bridge)
      ↓
  Representation (Canonical Model, Truth Lemma)
      ↓
  Core (Soundness, Deduction, MCS)
  ```
  to:
  ```
  Core (Soundness, Deduction, MCS)
      ↓
  Representation (Canonical Model, Truth Lemma)
      ↓
  FMP (Central Bridge)
      ↓
  Completeness (Strong, Weak)
      ↓
  Applications (Compactness)
  ```
- [ ] Remove FIX comment at line 58

**Timing**: 10 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Lines 58-70

**Verification**:
- Diagram reads top-to-bottom from foundations to applications
- Arrows point downward (→) from simpler to more complex

---

### Phase 4: Update Architecture Tables [NOT STARTED]

**Goal**: Update the two architecture tables (lines 26-50 and lines 170-185) to reflect actual Lean source code structure per research findings.

**Tasks**:
- [ ] Lines 26-35 (Core Infrastructure table): Update paths to reflect `Theories/Bimodal/Metalogic/` structure:
  - Note that most items reference deprecated Boneyard paths
  - Update to show actual current structure from research:
    - Core/Core.lean, Core/MaximalConsistent.lean
    - Representation/CanonicalWorld.lean, CanonicalHistory.lean, etc.
- [ ] Lines 38-50 (Metalogical Results table): Update to reflect actual file locations and sorry status
- [ ] Lines 170-185 (Syntax/Semantics and Decidability tables): Note these reference Boneyard/Metalogic_v2 locations
- [ ] Remove FIX comments at lines 22 and 166
- [ ] Add clarifying note that some paths refer to Boneyard (deprecated) code

**Timing**: 30 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Lines 22-50, 166-185

**Verification**:
- File paths match actual `Theories/Bimodal/Metalogic/` structure
- Deprecated paths are clearly marked or updated
- No FIX tags remain about architecture tables

---

### Phase 5: Add Initial Phase for Proofs [NOT STARTED]

**Goal**: Add a "Phase 0: Complete Core Proofs" section before Phase 1 to address the FIX tag at line 188.

**Tasks**:
- [ ] Insert new section after line 188 (before Phase 1):
  ```markdown
  ## Phase 0: Complete Core Proofs (High Priority)

  **Goal**: Finish the main proof by eliminating sorries and porting proven elements from the Boneyard.

  ### 0.1 Audit Current Sorries

  **Tasks**:
  - [ ] Audit `Theories/Bimodal/Metalogic/` for sorries (research found 20+)
  - [ ] Categorize by difficulty and dependency
  - [ ] Prioritize which sorries block main theorem path

  ### 0.2 Port from Boneyard

  **Tasks**:
  - [ ] Review `Boneyard/Metalogic_v2/Core/` for reusable elements
  - [ ] Evaluate DeductionTheorem.lean compatibility
  - [ ] Evaluate MaximalConsistent.lean compatibility
  - [ ] Port applicable proofs to active Metalogic directory

  ### 0.3 Decidability Decision

  **Tasks**:
  - [ ] Decide: deprecate or resurrect `Decidability/` infrastructure
  - [ ] If resurrecting: create migration plan
  - [ ] If deprecating: update roadmap to reflect this

  ### 0.4 Document Inventory

  **Tasks**:
  - [ ] Create sorry-free theorem inventory
  - [ ] Update ROAD_MAP tables with verified status
  - [ ] Document proof dependencies clearly

  ---
  ```
- [ ] Remove FIX comment at line 188

**Timing**: 20 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Insert after line 188

**Verification**:
- Phase 0 section exists before Phase 1
- Section addresses proof completion and Boneyard porting
- FIX tag at line 188 removed

---

### Phase 6: Final Cleanup and Verification [NOT STARTED]

**Goal**: Remove all remaining FIX/NOTE tags, verify no style issues remain, and ensure document consistency.

**Tasks**:
- [ ] grep for any remaining `<!-- FIX:` or `<!-- NOTE:` comments
- [ ] Verify no checkmark emojis (✅) remain
- [ ] Verify document renders correctly (no broken markdown)
- [ ] Update "Last Updated" date at line 3

**Timing**: 10 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Final cleanup

**Verification**:
- `grep -c "<!-- FIX:" specs/ROAD_MAP.md` returns 0
- `grep -c "<!-- NOTE:" specs/ROAD_MAP.md` returns 0
- `grep -c "✅" specs/ROAD_MAP.md` returns 0
- Document parses as valid markdown

## Testing & Validation

- [ ] All 9 identified issues from research report are addressed
- [ ] No FIX or NOTE comment tags remain in document
- [ ] No checkmark emojis remain
- [ ] Architecture tables reflect actual code structure
- [ ] Dependency diagram shows foundations at top
- [ ] Phase 0 added before Phase 1
- [ ] Design Comparison and Research Documentation sections removed
- [ ] Historical/promotional language replaced with neutral alternatives

## Artifacts & Outputs

- `specs/698_fix_roadmap_content_and_style_issues/plans/implementation-001.md` (this file)
- `specs/ROAD_MAP.md` (modified)
- `specs/698_fix_roadmap_content_and_style_issues/summaries/implementation-summary-YYYYMMDD.md` (upon completion)

## Rollback/Contingency

- Git provides easy rollback: `git checkout HEAD -- specs/ROAD_MAP.md`
- Each phase is atomic and can be reverted independently if needed
- Original content preserved in git history
