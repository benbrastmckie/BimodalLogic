# Implementation Plan: Task #662

- **Task**: 662 - consolidate_update_docs_readme
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Normal
- **Dependencies**: Task 661 (documentation-standards.md)
- **Research Inputs**: specs/662_consolidate_update_docs_readme/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Rewrite `.claude/docs/README.md` to transform it from a content-heavy document into a pure navigation hub. The current file (382 lines) contains approximately 60% duplicated content from `system-overview.md` and includes a "Quick Start" section that violates documentation-standards.md. The rewritten file targets approximately 100-120 lines, retaining only navigation structure and brief directory descriptions while linking to authoritative sources for detailed content.

### Research Integration

Research report (research-001.md) identified:
- Quick Start section (lines 40-83) for removal
- 10 sections duplicating system-overview.md content
- Recommended structure for navigation-focused README
- All current file paths verified accurate

## Goals & Non-Goals

**Goals**:
- Remove Quick Start section entirely
- Remove all content duplicated in system-overview.md
- Restructure README as navigation hub with brief descriptions
- Ensure all links and references remain accurate
- Follow documentation-standards.md requirements

**Non-Goals**:
- Adding new content or features
- Restructuring system-overview.md (content moves there by reference, not by copy)
- Creating new documentation files
- Modifying files outside .claude/docs/README.md

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Users miss important information | Medium | Low | Clear navigation links with descriptive text |
| Broken internal links | High | Low | Verify all links before and after changes |
| Over-aggressive content removal | Medium | Low | Follow research recommendations precisely |

## Implementation Phases

### Phase 1: Remove Duplicated Content [NOT STARTED]

**Goal**: Remove Quick Start section and all content duplicated in system-overview.md

**Tasks**:
- [ ] Remove Quick Start section (lines 40-83)
- [ ] Remove System Overview section (lines 85-107)
- [ ] Remove Commands section (lines 109-128)
- [ ] Remove Skills section (lines 130-165)
- [ ] Remove Agents section (lines 168-182)
- [ ] Remove Task Lifecycle section (lines 185-223)
- [ ] Remove Language-Based Routing section (lines 226-244)
- [ ] Remove Lean 4 Integration section (lines 246-269)
- [ ] Remove Artifacts section (lines 272-305)
- [ ] Remove State Management section (lines 308-328)
- [ ] Remove Git Integration section (lines 330-350)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/docs/README.md` - Remove sections as listed above

**Verification**:
- File contains no Quick Start section
- No duplicated content from system-overview.md remains
- Document Map and Related Documentation sections remain intact

---

### Phase 2: Restructure as Navigation Hub [NOT STARTED]

**Goal**: Rewrite remaining content as concise navigation index with brief descriptions

**Tasks**:
- [ ] Rewrite introduction (2-3 sentences, present tense)
- [ ] Retain Documentation Map tree structure
- [ ] Add brief "System Architecture" section (2 sentences + link to system-overview.md)
- [ ] Add "Guides" section with one-line descriptions for each guide
- [ ] Add "Examples" section with one-line descriptions
- [ ] Add "Templates" section (link to templates/README.md)
- [ ] Add "Troubleshooting" section (link to troubleshooting docs)
- [ ] Reorganize Related Documentation section as primary navigation
- [ ] Ensure present tense throughout
- [ ] Remove any historical references

**Timing**: 40 minutes

**Target structure**:
```markdown
# Claude Agent System Documentation

[Navigation links]

## Documentation Map
[Keep existing directory tree]

## System Architecture
[2 sentences + link to system-overview.md]

## Guides
[List with one-line descriptions]

## Examples
[List with one-line descriptions]

## Templates
[Link to templates/README.md]

## Troubleshooting
[Link to troubleshooting docs]

## Related Documentation
[Organized links section]
```

**Files to modify**:
- `.claude/docs/README.md` - Complete restructure

**Verification**:
- File is approximately 100-120 lines
- All sections use present tense
- No Quick Start content
- No duplicated detailed content

---

### Phase 3: Verify Links and References [NOT STARTED]

**Goal**: Ensure all internal links work and references are accurate

**Tasks**:
- [ ] Verify all relative links in Documentation Map point to existing files
- [ ] Verify all links in Guides section are valid
- [ ] Verify all links in Examples section are valid
- [ ] Verify all links in Related Documentation section are valid
- [ ] Verify navigation links at top and bottom of file
- [ ] Check that links to system-overview.md work correctly
- [ ] Confirm no references to removed/stale documents from Task 663

**Timing**: 20 minutes

**Files to check**:
- `.claude/docs/README.md` - All internal links
- `.claude/docs/guides/*.md` - Verify existence
- `.claude/docs/examples/*.md` - Verify existence
- `.claude/docs/architecture/system-overview.md` - Verify existence
- `.claude/docs/troubleshooting/*.md` - Verify existence

**Verification**:
- All links resolve to existing files
- No 404 references
- Cross-references between README and system-overview.md are consistent

## Testing & Validation

- [ ] README.md contains no Quick Start section
- [ ] README.md contains no content duplicated in system-overview.md
- [ ] README.md uses present tense throughout
- [ ] README.md is approximately 100-120 lines (navigation-focused)
- [ ] All internal links are valid
- [ ] Document follows documentation-standards.md requirements
- [ ] No emojis present in document

## Artifacts & Outputs

- `.claude/docs/README.md` - Rewritten navigation hub
- `specs/662_consolidate_update_docs_readme/summaries/implementation-summary-{DATE}.md` - Completion summary

## Rollback/Contingency

If the rewrite introduces problems:
1. Git history contains the original file
2. Restore with: `git checkout HEAD~1 -- .claude/docs/README.md`
3. Research report documents current state for reference
