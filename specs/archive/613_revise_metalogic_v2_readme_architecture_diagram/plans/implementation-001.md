# Implementation Plan: Task #613

- **Task**: 613 - revise_metalogic_v2_readme_architecture_diagram
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/613_revise_metalogic_v2_readme_architecture_diagram/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Revise the Metalogic_v2/README.md architecture diagram to accurately reflect the module dependency structure. The current diagram has several issues: inverted hierarchy (applications at top, foundations at bottom with downward arrows), missing modules (SoundnessLemmas, Closure, FiniteWorldState, SemanticCanonicalModel), and FMP.lean misrepresented as the main module rather than a thin re-export layer. The new diagram will use bottom-up orientation with foundations first, include all 18 modules, and show accurate dependency relationships.

### Research Integration

Research report `research-001.md` provides:
- Complete import analysis of all 18 Lean files in Metalogic_v2/
- Identified 4 missing modules in current diagram
- Proposed 6-layer architecture: Foundations (Core/Soundness) -> Representation -> FMP Hub -> Completeness -> Applications
- ASCII diagram best practices from GitHub documentation

## Goals & Non-Goals

**Goals**:
- Replace the Architecture Overview diagram with an accurate bottom-up dependency graph
- Include all 18 Lean modules with their key theorems
- Show correct dependency flow (arrows pointing up = "is used by")
- Maintain compatibility with GitHub/GitLab markdown rendering

**Non-Goals**:
- Rewriting other sections of the README (Directory Structure, Key Theorems, etc.)
- Changing the actual Lean code structure
- Adding Mermaid diagrams (staying with ASCII for portability)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Diagram too complex | Reduced readability | Medium | Use layered boxes to group related modules; limit to key theorems |
| Rendering issues in some viewers | Display corruption | Low | Test in GitHub preview; use only standard box-drawing characters |
| Missing subtle dependencies | Inaccurate diagram | Low | Cross-reference research report import analysis |

## Implementation Phases

### Phase 1: Create New Architecture Diagram [COMPLETED]

**Goal**: Design and implement the new bottom-up architecture diagram following research recommendations.

**Tasks**:
- [ ] Create new ASCII diagram with 6 layers (Foundations at bottom, Applications at top)
- [ ] Include all 18 modules organized by layer
- [ ] Add key theorem names to each module box
- [ ] Use Unicode box-drawing characters for clean rendering
- [ ] Add legend explaining arrow direction ("depends on" vs "is used by")

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/README.md` - Replace lines 7-42 (Architecture Overview section)

**Verification**:
- All 18 modules from research report are included
- Dependency arrows match import analysis in research report
- Diagram renders correctly in plain text preview

---

### Phase 2: Update Surrounding Documentation [COMPLETED]

**Goal**: Ensure consistency between the new diagram and other README sections.

**Tasks**:
- [ ] Review Directory Structure section for consistency with diagram
- [ ] Update the Description section if it references the old diagram structure
- [ ] Add "Last Updated" note or version indicator if appropriate
- [ ] Verify Key Theorems table aligns with modules shown in diagram

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/README.md` - Minor updates to adjacent sections

**Verification**:
- Directory Structure matches modules in diagram
- No references to "FMP as central hub" remain in prose (it's a re-export layer)
- All sections are internally consistent

---

### Phase 3: Verification and Testing [COMPLETED]

**Goal**: Validate the updated README renders correctly and is accurate.

**Tasks**:
- [ ] Render README in GitHub-flavored markdown preview
- [ ] Cross-check each module in diagram against research import analysis
- [ ] Verify all theorem names in diagram boxes exist in the codebase
- [ ] Check for any typos or alignment issues in ASCII art

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- Diagram renders without corruption
- All module names match actual filenames
- All theorem names are spelled correctly

## Testing & Validation

- [ ] Diagram displays correctly in VS Code markdown preview
- [ ] All 18 modules from research are represented
- [ ] Dependency relationships match import statements in Lean files
- [ ] No orphaned or disconnected modules in diagram
- [ ] Key theorems listed match actual declarations

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic_v2/README.md` (modified) - Updated architecture diagram
- `specs/613_revise_metalogic_v2_readme_architecture_diagram/summaries/implementation-summary-{DATE}.md` - Completion summary

## Rollback/Contingency

The original README content is preserved in git history. If the new diagram causes issues:
1. `git checkout HEAD~1 -- Theories/Bimodal/Metalogic_v2/README.md`
2. Review and fix issues
3. Re-apply changes incrementally
