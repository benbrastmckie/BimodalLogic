# Maintenance Documentation Consolidation Implementation Plan

## Metadata
- **Date**: 2025-12-05
- **Feature**: Integrate KNOWN_LIMITATIONS.md into IMPLEMENTATION_STATUS.md
- **Status**: [COMPLETE]
- **Estimated Hours**: 4-6 hours
- **Complexity Score**: 35.5
- **Structure Level**: 0
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Research Reports**:
  - [Maintenance Consolidation Analysis](../reports/001-integrate-maintenance-consolidation-analysis.md)

## Overview

This plan consolidates KNOWN_LIMITATIONS.md (109 lines) into IMPLEMENTATION_STATUS.md (699 lines) to reduce maintenance burden while preserving all content and ensuring no broken links. Research analysis reveals 16 external documentation references and 84+ historical spec report references that require systematic handling.

**Core Strategy**: Section integration with redirect stub to maintain backward compatibility while reducing the maintenance file count from 4 to 3 core documents (TODO.md, IMPLEMENTATION_STATUS.md with integrated limitations, SORRY_REGISTRY.md).

**Key Insight from Research**: KNOWN_LIMITATIONS.md serves a distinct user-facing "what doesn't work" purpose that must be preserved as a clear section within the consolidated file, not buried in technical implementation details.

## Success Criteria

- [ ] All KNOWN_LIMITATIONS.md content migrated to IMPLEMENTATION_STATUS.md as "Known Limitations" section
- [ ] Redirect stub created at original KNOWN_LIMITATIONS.md location
- [ ] All 16 active documentation references updated with section anchor links
- [ ] MAINTENANCE.md revised to document three-document model (not four)
- [ ] CLAUDE.md updated to consolidate status/limitations pointers
- [ ] All internal anchor links verified functional in Markdown viewers
- [ ] Documentation builds successfully (`lake build :docs`)
- [ ] No broken links in navigation paths
- [ ] Historical spec reports unchanged (preserve immutability)
- [ ] Migration notice added to consolidated section

## Technical Design

### Architecture Overview

**Current State** (four-document model):
```
Documentation/ProjectInfo/
├── TODO.md                     # Active tasks
├── IMPLEMENTATION_STATUS.md    # Module completion tracking
├── KNOWN_LIMITATIONS.md        # Gaps and workarounds (separate file)
└── SORRY_REGISTRY.md           # Technical debt tracking
```

**Target State** (three-document model):
```
Documentation/ProjectInfo/
├── TODO.md                     # Active tasks (unchanged)
├── IMPLEMENTATION_STATUS.md    # Module completion + Known Limitations section
│   └── ## Known Limitations    # Migrated content with anchors
├── KNOWN_LIMITATIONS.md        # Redirect stub (minimal)
└── SORRY_REGISTRY.md           # Technical debt tracking (unchanged)
```

### Integration Strategy

**Content Placement**: Insert "Known Limitations" section in IMPLEMENTATION_STATUS.md after line 666 ("Overall Project Status" section) and before line 669 ("Next Steps" section).

**Section Structure**:
```markdown
## Known Limitations

**Migration Notice**: This section consolidated from KNOWN_LIMITATIONS.md on 2025-12-05 to streamline maintenance documentation.

**Related Documentation**:
- [TODO.md](../../TODO.md) - Active tasks addressing limitations
- [SORRY_REGISTRY.md](SORRY_REGISTRY.md) - Technical debt details
- [MAINTENANCE.md](MAINTENANCE.md) - Documentation workflow

### 1. Completeness Status (Infrastructure Only)
[Full content from KNOWN_LIMITATIONS.md lines 19-45]

### 2. Automation Limitations (4/12 Tactics)
[Full content from KNOWN_LIMITATIONS.md lines 47-78]

### 3. Missing Features
[Full content from KNOWN_LIMITATIONS.md lines 82-97]

### 4. What Works Well
[Full content from KNOWN_LIMITATIONS.md lines 100-107]
```

**Anchor Tags** (for link targets):
- `#known-limitations` - Main section
- `#completeness-status` - Subsection 1
- `#automation-limitations` - Subsection 2
- `#missing-features` - Subsection 3

### Reference Update Pattern

**Before** (file-based link):
```markdown
[Known Limitations](Documentation/ProjectInfo/KNOWN_LIMITATIONS.md)
```

**After** (section-based link):
```markdown
[Implementation Status - Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations)
```

**Internal References** (within IMPLEMENTATION_STATUS.md):
```markdown
See [Known Limitations](#known-limitations) section below.
```

### Redirect Stub Content

Replace KNOWN_LIMITATIONS.md with minimal redirect:
```markdown
# Known Limitations

**Consolidation Notice**: This file was consolidated into [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md#known-limitations) on 2025-12-05.

## Redirect

For current gaps, workarounds, and missing features, see:
- [IMPLEMENTATION_STATUS.md - Known Limitations](IMPLEMENTATION_STATUS.md#known-limitations)

**Historical Context**: This consolidation reduces maintenance documentation from 4 to 3 core files (TODO.md, IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md) while preserving all content and maintaining backward compatibility for historical spec reports.

**Last Updated**: 2025-12-05
```

### Files Requiring Updates (16 Active References)

**Critical Documentation** (6 files):
1. `/CLAUDE.md:19` - Implementation Status section
2. `/CLAUDE.md:95` - Project structure table
3. `/CLAUDE.md:127` - Documentation Index
4. `/CLAUDE.md:286` - Working with partial implementation
5. `/README.md:295` - Documentation links
6. `/TODO.md:20` - Related Documentation
7. `/TODO.md:259` - Gap Documentation

**Documentation Hub** (5 files):
8. `/Documentation/README.md:32` - Project Info files
9. `/Documentation/README.md:70` - User Guide links
10. `/Documentation/README.md:109` - New limitations workflow
11. `/Documentation/README.md:169` - Known issues
12. `/Documentation/README.md:170` - Planned features

**Maintenance System** (3 files):
13. `/Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md:14` - Related Documentation
14. `/Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md:302` - Soundness workarounds
15. `/Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md:696` - References
16. `/Documentation/ProjectInfo/SORRY_REGISTRY.md:13` - Blockers reference

**Maintenance Workflow** (6 lines in MAINTENANCE.md):
17. `/Documentation/ProjectInfo/MAINTENANCE.md:11` - Related Documentation
18. `/Documentation/ProjectInfo/MAINTENANCE.md:87` - Update trigger
19. `/Documentation/ProjectInfo/MAINTENANCE.md:130` - Sync table
20. `/Documentation/ProjectInfo/MAINTENANCE.md:142` - Decision tree
21. `/Documentation/ProjectInfo/MAINTENANCE.md:164` - Validation command
22. `/Documentation/ProjectInfo/MAINTENANCE.md:257` - Blocker check

**Development Standards** (6 files):
23. `/Documentation/Development/PHASED_IMPLEMENTATION.md:541` - References
24. `/Documentation/Development/DOC_QUALITY_CHECKLIST.md:186` - Limitation check
25. `/Documentation/Development/DOC_QUALITY_CHECKLIST.md:190` - Validation grep
26. `/Documentation/Development/DOC_QUALITY_CHECKLIST.md:201` - Action guidance
27. `/Documentation/Development/DIRECTORY_README_STANDARD.md:299` - ProjectInfo files
28. `/Documentation/Development/DIRECTORY_README_STANDARD.md:335` - New limitations workflow
29. `/Documentation/Research/README.md:54` - References

### Historical Spec Reports (84+ files - NO UPDATE)

**Rationale for No Update**:
1. Spec reports are immutable historical records
2. Redirect stub ensures links still resolve
3. Low value (rarely consulted after completion)
4. High effort (5-10 hours to update 84+ files)

**Affected Directories**:
- `.claude/specs/019_research_todo_implementation_plan/`
- `.claude/specs/020_tm_perpetuity_paper_research/`
- `.claude/specs/025_soundness_automation_implementation/`
- `.claude/specs/027_temporal_duality_sorry_resolution/`
- `.claude/specs/028_temporal_symmetry_phase2_plan/`
- `.claude/specs/029_logos_documentation_integration/`
- `.claude/specs/030_high_priority_tasks_systematic_plan/`
- `.claude/specs/032_research_priority_tasks_analysis/`
- `.claude/specs/033_worldhistory_universal_tactic_tests/`
- `.claude/specs/034_always_operator_cleanup_alignment/`
- `.claude/specs/035_semantics_temporal_order_generalization/`
- `.claude/specs/036_readme_documentation_reorganization/`
- `.claude/specs/037_logos_layer_architecture_refactor/`
- `.claude/specs/038_temporal_conventions_refactor/`
- `.claude/specs/039_readme_narrative_revision_plan/`
- `.claude/specs/040_todo_cleanup_git_history/`
- `.claude/specs/041_core_automation_tactics/`
- `.claude/specs/043_readme_merge_accessibility/`

**Exception Handling**: If future work requires updating a historical spec, update the reference at that time (not preemptively).

## Implementation Phases

### Phase 1: Content Migration [COMPLETE]
dependencies: []

**Objective**: Migrate all KNOWN_LIMITATIONS.md content into IMPLEMENTATION_STATUS.md as new section.

**Complexity**: Low

**Tasks**:
- [x] Read full KNOWN_LIMITATIONS.md content (lines 1-116)
- [x] Identify insertion point in IMPLEMENTATION_STATUS.md (after line 666, before line 669)
- [x] Add "## Known Limitations" heading with migration notice
- [x] Add "Related Documentation" subsection with cross-references
- [x] Migrate Section 1: Completeness Status (lines 19-45) with `#completeness-status` anchor
- [x] Migrate Section 2: Automation Limitations (lines 47-78) with `#automation-limitations` anchor
- [x] Migrate Section 3: Missing Features (lines 82-97) with `#missing-features` anchor
- [x] Migrate Section 4: What Works Well (lines 100-107)
- [x] Preserve all formatting, code blocks, and emphasis

**Testing**:
```bash
# Verify content migrated completely
wc -l Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
# Expected: ~820 lines (699 + 121 from KNOWN_LIMITATIONS.md)

# Verify section headings present
grep "## Known Limitations" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
grep "### 1. Completeness Status" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
grep "### 2. Automation Limitations" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
grep "### 3. Missing Features" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
grep "### 4. What Works Well" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md

# Verify anchor tags present (for link targets)
grep -E "(#completeness-status|#automation-limitations|#missing-features)" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
```

**Expected Duration**: 45-60 minutes

---

### Phase 2: Create Redirect Stub [COMPLETE]
dependencies: [1]

**Objective**: Replace KNOWN_LIMITATIONS.md with minimal redirect stub for backward compatibility.

**Complexity**: Low

**Tasks**:
- [x] Read current KNOWN_LIMITATIONS.md to preserve metadata
- [x] Replace content with redirect stub template (see Technical Design)
- [x] Include consolidation notice with date (2025-12-05)
- [x] Add link to IMPLEMENTATION_STATUS.md#known-limitations
- [x] Add historical context explaining three-document model
- [x] Update "Last Updated" metadata to 2025-12-05
- [x] Verify file size reduced to ~25 lines (from 116 lines)

**Testing**:
```bash
# Verify redirect stub created
wc -l Documentation/ProjectInfo/KNOWN_LIMITATIONS.md
# Expected: ~25 lines (minimal redirect)

# Verify redirect link present
grep "IMPLEMENTATION_STATUS.md#known-limitations" Documentation/ProjectInfo/KNOWN_LIMITATIONS.md

# Verify consolidation notice present
grep "2025-12-05" Documentation/ProjectInfo/KNOWN_LIMITATIONS.md
```

**Expected Duration**: 15 minutes

---

### Phase 3: Update CLAUDE.md References [COMPLETE]
dependencies: [1, 2]

**Objective**: Update all CLAUDE.md references to point to consolidated section.

**Complexity**: Low

**Tasks**:
- [x] Update line 19: Change pointer from separate file to section link
- [x] Update line 95: Change project structure table entry
- [x] Update line 127: Change Documentation Index link
- [x] Update line 286: Change "Working with partial implementation" reference
- [x] Use descriptive anchor link format: `[Implementation Status - Known Limitations](path#known-limitations)`
- [x] Verify all 4 updates use consistent format

**Testing**:
```bash
# Verify no broken references to KNOWN_LIMITATIONS.md
grep "KNOWN_LIMITATIONS\.md" CLAUDE.md | grep -v "IMPLEMENTATION_STATUS.md#known-limitations"
# Expected: No output (all references updated)

# Verify new anchor links present
grep "IMPLEMENTATION_STATUS.md#known-limitations" CLAUDE.md | wc -l
# Expected: 4 references
```

**Expected Duration**: 20 minutes

---

### Phase 4: Update README.md and TODO.md [COMPLETE]
dependencies: [1, 2]

**Objective**: Update main project documentation references.

**Complexity**: Low

**Tasks**:
- [x] Update README.md line 295: Change Documentation links section
- [x] Update TODO.md line 20: Change Related Documentation section
- [x] Update TODO.md line 259: Change Gap Documentation reference
- [x] Use descriptive anchor link format for all updates
- [x] Verify links use relative paths from file locations

**Testing**:
```bash
# Verify README.md updated
grep "KNOWN_LIMITATIONS\.md" README.md
# Expected: No output (reference updated)

grep "IMPLEMENTATION_STATUS.md#known-limitations" README.md
# Expected: 1 match

# Verify TODO.md updated
grep "KNOWN_LIMITATIONS\.md" TODO.md
# Expected: No output (both references updated)

grep "IMPLEMENTATION_STATUS.md#known-limitations" TODO.md
# Expected: 2 matches (lines 20, 259)
```

**Expected Duration**: 15 minutes

---

### Phase 5: Update Documentation Hub (Documentation/README.md) [COMPLETE]
dependencies: [1, 2]

**Objective**: Update documentation hub references and workflow instructions.

**Complexity**: Low

**Tasks**:
- [x] Update line 32: Change Project Info files description
- [x] Update line 70: Change User Guide links section
- [x] Update line 109: Change "New limitations" workflow instruction
- [x] Update line 169: Change "Known issues" reference
- [x] Update line 170: Change "Planned features" reference
- [x] Use consistent anchor link format across all 5 updates

**Testing**:
```bash
# Verify all references updated
grep "KNOWN_LIMITATIONS\.md" Documentation/README.md | grep -v "IMPLEMENTATION_STATUS.md#known-limitations"
# Expected: No output (all 5 references updated)

# Verify new section references
grep "IMPLEMENTATION_STATUS.md#known-limitations" Documentation/README.md | wc -l
# Expected: 5 matches
```

**Expected Duration**: 25 minutes

---

### Phase 6: Update IMPLEMENTATION_STATUS.md Self-References [COMPLETE]
dependencies: [1, 2]

**Objective**: Update internal references within IMPLEMENTATION_STATUS.md to use section anchors.

**Complexity**: Low

**Tasks**:
- [x] Update line 14: Change Related Documentation to internal anchor
- [x] Update line 302: Change Soundness workarounds reference to internal anchor
- [x] Update line 696: Change References section to internal anchor
- [x] Use format: `[Known Limitations](#known-limitations)` for internal references
- [x] Verify anchor links work when viewed in Markdown previewer

**Testing**:
```bash
# Verify internal references use anchors (not file paths)
grep "KNOWN_LIMITATIONS\.md" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
# Expected: No output (all converted to internal anchors)

# Verify internal anchor format
grep "\[Known Limitations\](#known-limitations)" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md | wc -l
# Expected: 3 matches (lines 14, 302, 696)
```

**Expected Duration**: 15 minutes

---

### Phase 7: Update Maintenance System Files [COMPLETE]
dependencies: [1, 2]

**Objective**: Update SORRY_REGISTRY.md and MAINTENANCE.md to reflect consolidation.

**Complexity**: Medium

**Tasks**:
- [x] Update SORRY_REGISTRY.md line 13: Change blockers reference
- [x] Update MAINTENANCE.md line 11: Remove KNOWN_LIMITATIONS.md from Related Documentation list
- [x] Update MAINTENANCE.md line 87: Change update trigger to reference section
- [x] Update MAINTENANCE.md line 130: Remove row from synchronization table
- [x] Update MAINTENANCE.md line 142: Update decision tree ("Is this about a gap?" → "IMPLEMENTATION_STATUS.md Known Limitations section")
- [x] Update MAINTENANCE.md line 164: Remove from validation command
- [x] Update MAINTENANCE.md line 257: Change blocker check reference
- [x] Add note to MAINTENANCE.md documenting three-document model (not four)

**Testing**:
```bash
# Verify SORRY_REGISTRY.md updated
grep "KNOWN_LIMITATIONS\.md" Documentation/ProjectInfo/SORRY_REGISTRY.md
# Expected: No output

# Verify MAINTENANCE.md references consolidated
grep "KNOWN_LIMITATIONS\.md" Documentation/ProjectInfo/MAINTENANCE.md
# Expected: No output (all 6 references updated)

# Verify three-document model documented
grep "three-document model" Documentation/ProjectInfo/MAINTENANCE.md
# Expected: At least 1 match
```

**Expected Duration**: 45 minutes

---

### Phase 8: Update Development Standards [COMPLETE]
dependencies: [1, 2]

**Objective**: Update development documentation references.

**Complexity**: Low

**Tasks**:
- [x] Update PHASED_IMPLEMENTATION.md line 541: Change reference
- [x] Update DOC_QUALITY_CHECKLIST.md lines 186, 190, 201: Change validation checks and references
- [x] Update DIRECTORY_README_STANDARD.md lines 299, 335: Change ProjectInfo files and workflow
- [x] Update Research/README.md line 54: Change reference
- [x] Use consistent anchor link format across all files

**Testing**:
```bash
# Verify all development standards updated
grep -r "KNOWN_LIMITATIONS\.md" Documentation/Development/ Documentation/Research/ | grep -v "IMPLEMENTATION_STATUS.md#known-limitations"
# Expected: No output (all references updated)

# Count total updates
grep -r "IMPLEMENTATION_STATUS.md#known-limitations" Documentation/Development/ Documentation/Research/ | wc -l
# Expected: 6 matches
```

**Expected Duration**: 30 minutes

---

### Phase 9: Verification and Testing [COMPLETE]
dependencies: [1, 2, 3, 4, 5, 6, 7, 8]

**Objective**: Verify all links functional and documentation builds successfully.

**Complexity**: Low

**Tasks**:
- [x] Build documentation: `lake build :docs`
- [x] Verify no build errors or warnings
- [x] Test anchor links in VS Code Markdown preview
- [x] Test anchor links in GitHub-flavored Markdown viewer
- [x] Verify redirect stub resolves correctly
- [x] Verify all 16+ active file updates successful
- [x] Verify historical spec reports unchanged (84+ files)
- [x] Check for any remaining KNOWN_LIMITATIONS.md references in active docs
- [x] Verify IMPLEMENTATION_STATUS.md file size ~820 lines (699 + 121)
- [x] Verify KNOWN_LIMITATIONS.md file size ~25 lines (redirect stub)

**Testing**:
```bash
# Build documentation
lake build :docs
# Expected: Build completed successfully (no errors)

# Verify no lingering references in active documentation
grep -r "KNOWN_LIMITATIONS\.md" \
  CLAUDE.md README.md TODO.md \
  Documentation/README.md \
  Documentation/ProjectInfo/ \
  Documentation/Development/ \
  Documentation/Research/ \
  | grep -v "IMPLEMENTATION_STATUS.md#known-limitations" \
  | grep -v ".backup" \
  | grep -v "redirect stub"
# Expected: No output (all active references updated or accounted for)

# Verify file sizes
wc -l Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md Documentation/ProjectInfo/KNOWN_LIMITATIONS.md
# Expected: ~820 lines (STATUS), ~25 lines (redirect stub)

# Verify anchor tags present
grep -E "^## Known Limitations|^### [1-4]\." Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
# Expected: 5 matches (section + 4 subsections)

# Test link resolution (manual verification in Markdown viewer)
# Open Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
# Click anchor links in Related Documentation section
# Verify navigation works to #known-limitations
```

**Expected Duration**: 30 minutes

---

## Testing Strategy

### Overall Approach

**Test Levels**:
1. **Unit Tests**: Individual file updates verified independently
2. **Integration Tests**: Cross-file link resolution verified
3. **System Tests**: Full documentation build and navigation verified

**Coverage Requirements**:
- All 16+ active documentation files updated
- All internal anchor links functional
- Redirect stub resolves correctly
- No broken links in navigation paths

### Phase-Specific Testing

Each phase includes inline testing commands to verify:
- Content migrated correctly
- References updated successfully
- Anchor links resolve properly
- File sizes match expectations

### Final Validation

**Documentation Build Test**:
```bash
lake build :docs
```
**Expected**: Zero errors, zero warnings

**Link Resolution Test** (manual):
1. Open KNOWN_LIMITATIONS.md → verify redirects to IMPLEMENTATION_STATUS.md#known-limitations
2. Open IMPLEMENTATION_STATUS.md → verify "Known Limitations" section present
3. Click internal anchor links → verify navigation works
4. Check external references (CLAUDE.md, README.md, TODO.md) → verify links resolve

**Reference Audit**:
```bash
# Comprehensive grep for any missed references
grep -r "KNOWN_LIMITATIONS\.md" \
  --exclude-dir=.claude/specs \
  --exclude-dir=.backups \
  --exclude-dir=.git \
  CLAUDE.md README.md TODO.md Documentation/ \
  | grep -v "IMPLEMENTATION_STATUS.md#known-limitations" \
  | grep -v "redirect stub"
```
**Expected**: Zero matches (all active references updated)

## Documentation Requirements

### Files Requiring Updates (Summary)

**Total Active Files**: 16+ files (29 line-level references)
**Historical Files**: 84+ spec reports (NO UPDATE - immutable)

**Update Categories**:
1. Critical Documentation (7 references): CLAUDE.md, README.md, TODO.md
2. Documentation Hub (5 references): Documentation/README.md
3. Maintenance System (9 references): IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, MAINTENANCE.md
4. Development Standards (6 references): PHASED_IMPLEMENTATION.md, DOC_QUALITY_CHECKLIST.md, DIRECTORY_README_STANDARD.md, Research/README.md

### New Documentation Created

**Redirect Stub**: KNOWN_LIMITATIONS.md (minimal, ~25 lines)
- Purpose: Backward compatibility for historical references
- Content: Consolidation notice + redirect link
- Maintenance: Update "Last Updated" when queried

**Consolidated Section**: IMPLEMENTATION_STATUS.md (new section, ~121 lines)
- Location: After "Overall Project Status", before "Next Steps"
- Anchors: `#known-limitations`, `#completeness-status`, `#automation-limitations`, `#missing-features`
- Maintenance: Update when gaps resolved or new limitations discovered

### Documentation Standards Compliance

**Markdown Anchor Format**:
- Section headings: `## Known Limitations`
- Subsection headings: `### 1. Completeness Status`
- Anchor links: `[text](#known-limitations)` (internal), `[text](path#known-limitations)` (external)

**Link Format Consistency**:
- Descriptive format: `[Implementation Status - Known Limitations](path#section)`
- Internal format: `[Known Limitations](#known-limitations)`
- Relative paths: Use relative paths from file location

**Migration Notice Format**:
```markdown
**Migration Notice**: This section consolidated from KNOWN_LIMITATIONS.md on 2025-12-05 to streamline maintenance documentation.
```

## Dependencies

### External Dependencies
- None (pure documentation refactoring)

### Internal Dependencies
- Phases 3-8 depend on Phases 1-2 (content must be migrated before updating references)
- Phase 9 depends on all prior phases (verification requires all updates complete)

### Prerequisite Knowledge
- Markdown anchor link syntax
- Git file tracking (preserve history during content migration)
- Relative path calculation for cross-document links

## Risk Mitigation

### Risk 1: Broken Links in Historical Specs

**Likelihood**: High (84+ files reference KNOWN_LIMITATIONS.md)
**Impact**: Low (spec reports rarely consulted after completion)
**Mitigation**: Create redirect stub for backward compatibility
**Contingency**: If redirect fails, accept broken links in historical docs (document in migration notice)

### Risk 2: Anchor Links Not Working

**Likelihood**: Medium (Markdown viewers vary in anchor support)
**Impact**: Medium (navigation breaks if anchors fail)
**Mitigation**: Test anchor links in VS Code and GitHub Markdown preview before finalizing
**Contingency**: Use file-based links with line number references if anchors fail

### Risk 3: Content Loss During Migration

**Likelihood**: Low (careful copy-paste with verification)
**Impact**: High (user-facing documentation incomplete)
**Mitigation**: Use Edit tool (not manual copy-paste), verify content line-by-line
**Contingency**: Restore from git history if content missing

### Risk 4: Maintenance Workflow Confusion

**Likelihood**: Medium (developers accustomed to four-document model)
**Impact**: Medium (updates go to wrong files)
**Mitigation**: Update MAINTENANCE.md decision tree, add migration notice to consolidated section
**Contingency**: Add temporary reminder to MAINTENANCE.md about consolidation

## Rollback Plan

**If consolidation fails or causes issues**:

1. **Restore original files**:
   ```bash
   git checkout HEAD -- Documentation/ProjectInfo/KNOWN_LIMITATIONS.md
   git checkout HEAD -- Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
   ```

2. **Revert reference updates**:
   ```bash
   git checkout HEAD -- CLAUDE.md README.md TODO.md
   git checkout HEAD -- Documentation/README.md
   git checkout HEAD -- Documentation/ProjectInfo/MAINTENANCE.md
   git checkout HEAD -- Documentation/ProjectInfo/SORRY_REGISTRY.md
   git checkout HEAD -- Documentation/Development/
   git checkout HEAD -- Documentation/Research/
   ```

3. **Document rollback reason** in TODO.md

**Rollback Trigger Criteria**:
- Anchor links fail in multiple Markdown viewers
- Documentation build fails with errors
- Critical navigation paths broken
- User confusion about new structure

## Completion Checklist

Before considering this plan complete:
- [ ] All 121 lines of KNOWN_LIMITATIONS.md content migrated to IMPLEMENTATION_STATUS.md
- [ ] Redirect stub created and tested (resolves to correct section)
- [ ] All 16+ active documentation files updated with anchor links
- [ ] MAINTENANCE.md revised to three-document model
- [ ] CLAUDE.md consolidated status/limitations pointers
- [ ] All internal anchor links functional in VS Code Markdown preview
- [ ] `lake build :docs` completes successfully with zero errors
- [ ] No broken links in critical navigation paths (CLAUDE.md, README.md, TODO.md)
- [ ] Historical spec reports unchanged (84+ files preserved)
- [ ] Migration notice present in consolidated section
- [ ] File sizes verified: IMPLEMENTATION_STATUS.md ~820 lines, KNOWN_LIMITATIONS.md ~25 lines
- [ ] Comprehensive reference audit completed (no missed updates)

---

**Plan Created**: 2025-12-05
**Estimated Total Effort**: 4-6 hours
**Complexity**: Medium (systematic refactoring across 16+ files)
**Benefit**: Reduces maintenance burden, consolidates related documentation, preserves backward compatibility
