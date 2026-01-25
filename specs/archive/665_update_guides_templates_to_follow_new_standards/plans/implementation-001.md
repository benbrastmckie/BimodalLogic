# Implementation Plan: Update guides and templates to follow new standards

## Metadata

- **Task**: 665 - update_guides_templates_to_follow_new_standards
- **Status**: [COMPLETED]
- **Effort**: 2-3 hours
- **Complexity**: Medium
- **Language**: meta
- **Dependencies**: 661, 662 (both completed)
- **Research Integrated**: research-001.md
- **Created**: 2026-01-21
- **Plan Version**: 001

## Overview

This task updates documentation files in `docs/guides/` and `docs/templates/` to comply with the new documentation standards established in Task 661. The research identified 12 distinct violations across 6 files requiring updates to remove "Quick Start" references, version numbers, historical content, and fix invalid path references.

### Research Integration

This plan integrates findings from 1 research report:

**research-001.md** (2026-01-21): Analysis of 11 files in guides/ and templates/ directories
- Key Finding: 6 files with 12 distinct standards violations
- Key Finding: Quick Start references in user-installation.md and copy-claude-directory.md  
- Key Finding: Version metadata footers in all template files and several guides
- Key Finding: Invalid path references in permission-configuration.md and other guides
- Recommendation: Prioritize Quick Start removal, version cleanup, then path fixes

## Problem

Documentation files in `docs/guides/` and `docs/templates/` contain violations of the new documentation standards:
- "Quick Start" sections and references that encourage skipping context
- Version numbers, "Last Updated" dates, and revision history sections
- Invalid path references pointing to non-existent files
- Metadata footers that don't belong in documentation files

## Scope

**In Scope**:
1. Remove "Quick Start" references from user-installation.md and copy-claude-directory.md
2. Remove version numbers, dates, and metadata footers from all template files
3. Remove version headers and revision history from guides with these violations
4. Fix invalid path references in permission-configuration.md and other affected files
5. Ensure all files comply with documentation-standards.md

**Out of Scope**:
- Content rewrites beyond standards compliance
- Adding new documentation sections
- Changes to file structure or organization

## Constraints

- Must preserve all functional content and information
- Must maintain readability and document structure
- Must not break existing valid links
- Must follow kebab-case naming (already compliant)
- Must use present tense throughout (already compliant)

## Definition of Done

- [ ] No "Quick Start" or "quick-start" text in any guide/template file
- [ ] No version numbers, "Last Updated" dates, or "Maintained By" in any file
- [ ] No "Revision History" or "Migration History" sections
- [ ] All path references point to existing files
- [ ] Present tense used throughout (verify)
- [ ] All changes reviewed and validated

## Goals and Non-Goals

### Goals
1. Achieve full compliance with documentation-standards.md
2. Remove all Quick Start references and sections
3. Clean up version metadata and historical content
4. Fix all invalid path references
5. Maintain document readability and structure

### Non-Goals
1. Restructuring document organization
2. Adding new content or sections
3. Creating new documentation files
4. Changing the documentation standards themselves

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Broken links after path updates | Users cannot navigate | Verify all new paths exist before committing |
| Removing version info loses traceability | Difficult to track document evolution | Git history provides complete traceability |
| Quick Start removal may confuse new users | Longer onboarding process | Structure remaining content progressively for clarity |
| Accidentally removing functional content | Loss of important information | Review changes carefully, preserve all non-violation content |

## Implementation Phases

### Phase 1: Quick Start Removal (Priority 1)
**Status**: [COMPLETED]
**Effort**: 0.5 hours

**Description**: Remove Quick Start references and rename section headers

**Tasks**:
1. Update user-installation.md:
   - Line 5: Change "A quick-start guide" to "Instructions for installing Claude Code"
   - Line 25: Rename "### Quick Installation" to "### Installation"
2. Update copy-claude-directory.md:
   - Line 313: Rename "### Quick Start with Commands" to "### Using Commands"

**Acceptance Criteria**:
- [ ] No "quick-start" or "Quick Start" text in any file
- [ ] Section headers renamed appropriately
- [ ] All functional content preserved

### Phase 2: Version Metadata Removal (Priority 2)
**Status**: [COMPLETED]
**Effort**: 1 hour

**Description**: Remove version numbers, dates, and metadata footers from all affected files

**Tasks**:
1. Template files:
   - templates/README.md: Remove lines 358-360 and Migration History (339-344)
   - agent-template.md: Remove lines 389-391
   - command-template.md: Remove lines 121-123
2. Guide files:
   - permission-configuration.md: Remove version header (1-6) and Revision History (761-765)
   - context-loading-best-practices.md: Remove version header (1-6)
   - creating-agents.md: Remove version footer (687-690)
   - creating-skills.md: Remove version footer (535-537)
   - component-selection.md: Remove version footer (401-403)

**Acceptance Criteria**:
- [ ] No version numbers in any file
- [ ] No "Last Updated" dates
- [ ] No "Maintained By" footers
- [ ] No historical sections removed

### Phase 3: Path Reference Fixes (Priority 3)
**Status**: [COMPLETED]
**Effort**: 0.5 hours

**Description**: Fix invalid path references identified in research

**Tasks**:
1. permission-configuration.md:
   - Fix `.claude/context/core/system/state-management.md` to `.claude/context/core/orchestration/state-management.md`
   - Remove or fix reference to `git-safety.md` (verify if exists)
2. user-installation.md:
   - Fix references to `../commands/README.md` (commands directory doesn't exist)
3. copy-claude-directory.md:
   - Fix `.claude/specs/` to `specs/` (specs is at project root)

**Acceptance Criteria**:
- [ ] All path references point to existing files
- [ ] No broken internal links
- [ ] Verified with file existence checks

### Phase 4: Validation and Review
**Status**: [COMPLETED]
**Effort**: 0.5 hours

**Description**: Final validation that all standards are met

**Tasks**:
1. Verify present tense usage throughout all files
2. Confirm no remaining Quick Start references
3. Confirm no version metadata remains
4. Validate all path references with existence checks
5. Review document structure and readability

**Acceptance Criteria**:
- [ ] All validation checks pass
- [ ] Documents maintain good structure and flow
- [ ] No functional content accidentally removed

## Testing and Validation

### Pre-commit Validation
1. Search for remaining violations:
   ```bash
   grep -r "Quick Start\|quick-start" .claude/docs/guides/ .claude/docs/templates/
   grep -r "Version\|Last Updated\|Maintained By" .claude/docs/templates/
   grep -r "Revision History\|Migration History" .claude/docs/
   ```
2. Verify path references exist
3. Check present tense usage

### Manual Review
1. Read through each updated file
2. Verify document flow is intact
3. Confirm functional content preserved
4. Check formatting consistency

## Artifacts and Outputs

1. **Updated Files**:
   - `.claude/docs/guides/user-installation.md`
   - `.claude/docs/guides/copy-claude-directory.md`
   - `.claude/docs/guides/permission-configuration.md`
   - `.claude/docs/guides/context-loading-best-practices.md`
   - `.claude/docs/guides/creating-agents.md`
   - `.claude/docs/guides/creating-skills.md`
   - `.claude/docs/guides/component-selection.md`
   - `.claude/docs/templates/README.md`
   - `.claude/docs/templates/agent-template.md`
   - `.claude/docs/templates/command-template.md`

2. **Validation Report**:
   - All standards compliance checks documented
   - List of changes made per file
   - Verification of path references

## Rollback/Contingency

If issues arise:
1. Git revert to restore original files
2. Review research findings to ensure complete understanding
3. Reapply changes more carefully
4. Additional validation pass

## Success Metrics

- 100% compliance with documentation-standards.md
- Zero Quick Start references remaining
- Zero version metadata items remaining
- All path references valid
- No functional content lost
- Documents maintain readability and structure

## Next Steps

After completion:
1. Run final compliance validation
2. Update any dependent documentation if needed
3. Consider similar standards review for other documentation areas