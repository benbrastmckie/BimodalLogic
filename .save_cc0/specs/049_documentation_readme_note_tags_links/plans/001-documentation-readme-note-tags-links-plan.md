# Documentation README.md NOTE Tags Link Conversion Plan

## Metadata
- **Date**: 2025-12-08
- **Feature**: Convert all NOTE-tagged plain text items to markdown links in Documentation/README.md
- **Status**: [COMPLETE]
- **Estimated Hours**: 2-3 hours
- **Complexity Score**: 28.0
- **Structure Level**: 0
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Research Reports**:
  - [Documentation Link Status Analysis](../reports/001-doc-link-status-analysis.md)
  - [Multi-Section Link Conversion Strategy](../reports/002-multi-section-link-conversion.md)
  - [Reference Section Link Integration](../reports/003-reference-link-integration.md)

## Overview

Documentation/README.md contains four HTML comment NOTE tags (lines 23, 34, 44, 62) marking sections where plain text list items should be converted to markdown links. This plan systematically converts 20 documentation file references across Research/ (4 links), ProjectInfo/ (3 links), Development/ (11 links), and Reference/ (2 links) sections to match the existing UserGuide/ section link pattern.

## Research Summary

Research identified four NOTE-tagged sections requiring link conversion:
- Research findings confirmed 20 files exist and need link conversion
- UserGuide/ section (lines 13-17) provides the baseline link format pattern
- Transformation rule: Remove bold markers, add markdown links, change separator from `:` to `-`, preserve descriptions
- Quick Links section (lines 67-105) already contains proper links, validating conversion targets
- Recommended execution order: Research/ → ProjectInfo/ → Development/ → Reference/ (complexity-based progression: 4 → 3 → 11 → 2 links)

## Success Criteria

- [x] All 20 plain text items converted to markdown links following UserGuide/ pattern
- [x] Link format consistent: `[FILENAME](Directory/FILENAME) - Description`
- [x] All four NOTE tags removed (lines 23, 34, 44, 62)
- [x] All link targets verified to exist in filesystem
- [x] Links consistent with Quick Links section cross-references
- [x] No broken links or formatting errors introduced
- [x] Documentation maintains 100-character line limit

## Technical Design

### Link Transformation Pattern

Based on UserGuide/ baseline (lines 13-17), apply this deterministic transformation:

**Input Format** (current):
```markdown
- **FILENAME**: Description text (with optional parentheticals)
```

**Output Format** (target):
```markdown
- [FILENAME](Directory/FILENAME) - Description text (with optional parentheticals)
```

**Transformation Steps**:
1. Remove bold markers: `**FILENAME**` → `FILENAME`
2. Add markdown link: `FILENAME` → `[FILENAME](Directory/FILENAME)`
3. Change separator: `: ` → ` - `
4. Preserve description verbatim (including parenthetical details)

### Section Conversion Specifications

**Research/ Section (4 links, lines 24-28)**:
- README.md → `[README.md](Research/README.md) - Research documentation overview`
- DUAL_VERIFICATION.md → `[DUAL_VERIFICATION.md](Research/DUAL_VERIFICATION.md) - RL training architecture design`
- PROOF_LIBRARY_DESIGN.md → `[PROOF_LIBRARY_DESIGN.md](Research/PROOF_LIBRARY_DESIGN.md) - Theorem caching design`
- LAYER_EXTENSIONS.md → `[LAYER_EXTENSIONS.md](Research/LAYER_EXTENSIONS.md) - Layers 1-3 extension specifications`

**ProjectInfo/ Section (3 links, lines 36-38)**:
- IMPLEMENTATION_STATUS.md → `[IMPLEMENTATION_STATUS.md](ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module status tracking with verification commands (includes Known Limitations section)`
- SORRY_REGISTRY.md → `[SORRY_REGISTRY.md](ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking (sorry placeholders with resolution context)`
- TACTIC_DEVELOPMENT.md → `[TACTIC_DEVELOPMENT.md](ProjectInfo/TACTIC_DEVELOPMENT.md) - Custom tactic development patterns`

**Development/ Section (11 links, lines 46-56)**:
- CONTRIBUTING.md → `[CONTRIBUTING.md](Development/CONTRIBUTING.md) - Contribution guidelines and workflow`
- DIRECTORY_README_STANDARD.md → `[DIRECTORY_README_STANDARD.md](Development/DIRECTORY_README_STANDARD.md) - Directory-level documentation standard`
- DOC_QUALITY_CHECKLIST.md → `[DOC_QUALITY_CHECKLIST.md](Development/DOC_QUALITY_CHECKLIST.md) - Documentation quality assurance checklist`
- LEAN_STYLE_GUIDE.md → `[LEAN_STYLE_GUIDE.md](Development/LEAN_STYLE_GUIDE.md) - Coding conventions and documentation requirements`
- MAINTENANCE.md → `[MAINTENANCE.md](Development/MAINTENANCE.md) - TODO management workflow (git-based history model)`
- METAPROGRAMMING_GUIDE.md → `[METAPROGRAMMING_GUIDE.md](Development/METAPROGRAMMING_GUIDE.md) - LEAN 4 metaprogramming fundamentals for tactics`
- MODULE_ORGANIZATION.md → `[MODULE_ORGANIZATION.md](Development/MODULE_ORGANIZATION.md) - Directory structure and namespace patterns`
- PHASED_IMPLEMENTATION.md → `[PHASED_IMPLEMENTATION.md](Development/PHASED_IMPLEMENTATION.md) - Implementation roadmap with execution waves`
- QUALITY_METRICS.md → `[QUALITY_METRICS.md](Development/QUALITY_METRICS.md) - Quality targets and performance benchmarks`
- TESTING_STANDARDS.md → `[TESTING_STANDARDS.md](Development/TESTING_STANDARDS.md) - Test requirements and coverage targets`
- VERSIONING.md → `[VERSIONING.md](Development/VERSIONING.md) - Semantic versioning policy`

**Reference/ Section (2 links, lines 64-65)**:
- OPERATORS.md → `[OPERATORS.md](Reference/OPERATORS.md) - Formal symbols reference (Unicode notation guide)`
- GLOSSARY.md → `[GLOSSARY.md](Reference/GLOSSARY.md) - Terminology mapping and key concepts`

### Validation Strategy

After each section conversion:
1. Verify link targets exist in filesystem
2. Cross-reference with Quick Links section (lines 67-105) for consistency
3. Check 100-character line limit compliance
4. Test markdown rendering (if tooling available)

## Implementation Phases

### Phase 1: Research/ Section Link Conversion [COMPLETE]
dependencies: []

**Objective**: Convert 4 Research/ section items to markdown links and remove NOTE tag

**Complexity**: Low

**Tasks**:
- [x] Read current Research/ section content (lines 23-28)
- [x] Apply transformation pattern to all 4 items (README.md, DUAL_VERIFICATION.md, PROOF_LIBRARY_DESIGN.md, LAYER_EXTENSIONS.md)
- [x] Update lines 25-28 with converted markdown links
- [x] Verify all 4 link targets exist: Documentation/Research/README.md, DUAL_VERIFICATION.md, PROOF_LIBRARY_DESIGN.md, LAYER_EXTENSIONS.md
- [x] Remove NOTE tag from line 23
- [x] Verify 100-character line limit compliance

**Testing**:
```bash
# Verify Research/ files exist
ls -1 /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/Research/{README,DUAL_VERIFICATION,PROOF_LIBRARY_DESIGN,LAYER_EXTENSIONS}.md

# Verify NOTE tag removed
grep -n "<!-- NOTE: the below should be links -->" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | grep "^23:"

# Verify link format matches pattern
grep -A4 "^### Research/" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | grep "^\- \[.*\](Research/.*\.md) -"
```

**Expected Duration**: 0.5 hours

---

### Phase 2: ProjectInfo/ Section Link Conversion [COMPLETE]
dependencies: [1]

**Objective**: Convert 3 ProjectInfo/ section items to markdown links and remove NOTE tag

**Complexity**: Low

**Tasks**:
- [x] Read current ProjectInfo/ section content (lines 34-38)
- [x] Apply transformation pattern to all 3 items (IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_DEVELOPMENT.md)
- [x] Preserve parenthetical details in descriptions
- [x] Update lines 36-38 with converted markdown links
- [x] Verify all 3 link targets exist: Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_DEVELOPMENT.md
- [x] Remove NOTE tag from line 34
- [x] Cross-reference with Quick Links section (lines 77-79, 88) for consistency

**Testing**:
```bash
# Verify ProjectInfo/ files exist
ls -1 /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/ProjectInfo/{IMPLEMENTATION_STATUS,SORRY_REGISTRY,TACTIC_DEVELOPMENT}.md

# Verify NOTE tag removed
grep -n "<!-- NOTE: the below should be links -->" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | grep "^34:"

# Verify parenthetical preservation
grep "ProjectInfo/IMPLEMENTATION_STATUS.md" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | grep -o "(includes Known Limitations section)"

# Verify Quick Links consistency
diff <(grep -o "ProjectInfo/[A-Z_]*.md" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | sort -u) <(echo -e "ProjectInfo/IMPLEMENTATION_STATUS.md\nProjectInfo/SORRY_REGISTRY.md\nProjectInfo/TACTIC_DEVELOPMENT.md" | sort)
```

**Expected Duration**: 0.5 hours

---

### Phase 3: Development/ Section Link Conversion [COMPLETE]
dependencies: [2]

**Objective**: Convert 11 Development/ section items to markdown links and remove NOTE tag

**Complexity**: Medium

**Tasks**:
- [x] Read current Development/ section content (lines 44-56)
- [x] Apply transformation pattern to all 11 items in sequence
- [x] Convert CONTRIBUTING.md (line 46)
- [x] Convert DIRECTORY_README_STANDARD.md (line 47)
- [x] Convert DOC_QUALITY_CHECKLIST.md (line 48)
- [x] Convert LEAN_STYLE_GUIDE.md (line 49)
- [x] Convert MAINTENANCE.md (line 50) - preserve parenthetical
- [x] Convert METAPROGRAMMING_GUIDE.md (line 51)
- [x] Convert MODULE_ORGANIZATION.md (line 52)
- [x] Convert PHASED_IMPLEMENTATION.md (line 53)
- [x] Convert QUALITY_METRICS.md (line 54)
- [x] Convert TESTING_STANDARDS.md (line 55)
- [x] Convert VERSIONING.md (line 56)
- [x] Verify all 11 link targets exist in Documentation/Development/
- [x] Remove NOTE tag from line 44
- [x] Cross-reference with Quick Links section (lines 81-82, 86-92) for consistency

**Testing**:
```bash
# Verify Development/ files exist
ls -1 /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/Development/{CONTRIBUTING,DIRECTORY_README_STANDARD,DOC_QUALITY_CHECKLIST,LEAN_STYLE_GUIDE,MAINTENANCE,METAPROGRAMMING_GUIDE,MODULE_ORGANIZATION,PHASED_IMPLEMENTATION,QUALITY_METRICS,TESTING_STANDARDS,VERSIONING}.md

# Verify NOTE tag removed
grep -n "<!-- NOTE: the below should be links -->" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | grep "^44:"

# Verify all 11 links converted
grep -c "^\- \[.*\](Development/.*\.md) -" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | grep "^11$"

# Verify Quick Links consistency (should reference same files)
SECTION_FILES=$(grep -o "Development/[A-Z_]*.md" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | grep -v "Quick" | sort -u)
QUICK_LINKS_FILES=$(grep -A20 "^### For Contributors" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | grep -o "Development/[A-Z_]*.md" | sort -u)
echo "$SECTION_FILES" | diff - <(echo "$QUICK_LINKS_FILES")
```

**Expected Duration**: 1.0 hours

---

### Phase 4: Reference/ Section Link Conversion and Final Validation [COMPLETE]
dependencies: [3]

**Objective**: Convert 2 Reference/ section items to markdown links, remove final NOTE tag, and validate all conversions

**Complexity**: Low

**Tasks**:
- [x] Read current Reference/ section content (lines 62-65)
- [x] Apply transformation pattern to both items (OPERATORS.md, GLOSSARY.md)
- [x] Preserve "Reference materials:" introduction text (line 60)
- [x] Update lines 64-65 with converted markdown links
- [x] Verify both link targets exist: Documentation/Reference/OPERATORS.md, GLOSSARY.md
- [x] Remove final NOTE tag from line 62
- [x] Cross-reference with Quick Reference section (lines 96-97) for consistency
- [x] Validate all 20 links across all four sections
- [x] Verify no NOTE tags remain in file
- [x] Verify 100-character line limit compliance across entire file
- [x] Verify link format consistency (all use `[FILE](Dir/FILE) - Desc` pattern)

**Testing**:
```bash
# Verify Reference/ files exist
ls -1 /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/Reference/{OPERATORS,GLOSSARY}.md

# Verify final NOTE tag removed
grep -c "<!-- NOTE: the below should be links -->" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | grep "^0$"

# Verify all 20 links converted (4 Research + 3 ProjectInfo + 11 Development + 2 Reference = 20)
TOTAL_LINKS=$(grep -c "^\- \[.*\](Research/.*\.md\|ProjectInfo/.*\.md\|Development/.*\.md\|Reference/.*\.md) -" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md)
[ "$TOTAL_LINKS" -eq 20 ] && echo "✓ All 20 links converted" || echo "✗ Expected 20 links, found $TOTAL_LINKS"

# Verify 100-character line limit
awk 'length > 100 { print NR": "length" chars - "$0; exit 1 }' /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md && echo "✓ Line limit compliance"

# Verify Quick Reference consistency
diff <(grep "Reference/OPERATORS.md" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | wc -l) <(echo "2")
diff <(grep "Reference/GLOSSARY.md" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | wc -l) <(echo "2")
```

**Expected Duration**: 0.5 hours

---

### Phase 5: Documentation and Verification [COMPLETE]
dependencies: [4]

**Objective**: Verify all conversions complete, test markdown rendering, and ensure documentation coherence

**Complexity**: Low

**Tasks**:
- [x] Re-read entire Documentation/README.md file
- [x] Verify link consistency across all sections (Research/, ProjectInfo/, Development/, Reference/, UserGuide/)
- [x] Verify Quick Links section alignment with converted sections
- [x] Test markdown rendering (visual inspection or tooling)
- [x] Verify no broken links or malformed markdown syntax
- [x] Verify all descriptions preserved accurately (including parentheticals)
- [x] Verify file follows Documentation Standards (CLAUDE.md section 6)
- [x] Run markdown linter if available
- [x] Update Documentation/README.md modification timestamp if tracked

**Testing**:
```bash
# Comprehensive link validation
for LINK in $(grep -o "(Research/[^)]*\.md\|ProjectInfo/[^)]*\.md\|Development/[^)]*\.md\|Reference/[^)]*\.md)" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | tr -d '()'); do
  FILE="/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/$LINK"
  if [ -f "$FILE" ]; then
    echo "✓ $LINK exists"
  else
    echo "✗ $LINK MISSING"
    exit 1
  fi
done

# Verify transformation pattern consistency
grep "^\- \[.*\](.*\.md) -" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md | grep -v "^\- \[[A-Z_]*\.md\]([A-Za-z]*/[A-Z_]*\.md) -" && echo "✗ Link format inconsistency detected" || echo "✓ All links follow pattern"

# Verify no NOTE tags remain
! grep -q "<!-- NOTE:" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md && echo "✓ All NOTE tags removed"

# Final count verification (should be 20 section links + existing UserGuide links + Quick Links)
echo "Section links count:"
grep -c "^\- \[.*\](Research/\|ProjectInfo/\|Development/\|Reference/.*\.md) -" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/README.md
```

**Expected Duration**: 0.5 hours

---

## Testing Strategy

### Unit Testing
Each phase includes verification commands to test:
- File existence validation for all link targets
- NOTE tag removal confirmation
- Link format pattern compliance
- Description preservation (including parentheticals)
- 100-character line limit adherence

### Integration Testing
After all phases complete:
- Cross-reference consistency validation between main sections and Quick Links section
- Comprehensive link target existence check (all 20 files)
- Markdown syntax validation
- Pattern consistency check across all converted links

### Regression Testing
- Verify no existing links broken during conversion
- Verify UserGuide/ section unchanged (baseline pattern preserved)
- Verify Quick Links section unchanged

## Documentation Requirements

### Files to Update
- **Documentation/README.md**: Primary target file for all link conversions

### Documentation Standards Compliance
Per CLAUDE.md Section 6:
- Maintain 100-character line limit
- Use standard Markdown conventions
- Preserve ATX-style headings
- Ensure code blocks specify language
- Follow formal symbol backtick standard (not applicable to this plan)

### Verification
- All conversions maintain documentation standards
- No new documentation files created (only editing existing README.md)
- Changes preserve semantic meaning and readability

## Dependencies

### External Dependencies
None - this is a pure documentation editing task with no code or system dependencies.

### File Dependencies
All 20 target files must exist:
- Documentation/Research/: README.md, DUAL_VERIFICATION.md, PROOF_LIBRARY_DESIGN.md, LAYER_EXTENSIONS.md
- Documentation/ProjectInfo/: IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_DEVELOPMENT.md
- Documentation/Development/: CONTRIBUTING.md, DIRECTORY_README_STANDARD.md, DOC_QUALITY_CHECKLIST.md, LEAN_STYLE_GUIDE.md, MAINTENANCE.md, METAPROGRAMMING_GUIDE.md, MODULE_ORGANIZATION.md, PHASED_IMPLEMENTATION.md, QUALITY_METRICS.md, TESTING_STANDARDS.md, VERSIONING.md
- Documentation/Reference/: OPERATORS.md, GLOSSARY.md

Research confirms all 20 files verified to exist (Finding 2-5 from doc-link-status-analysis).

### Prerequisites
- Read access to Documentation/README.md
- Write access to Documentation/README.md
- Edit tool capability for targeted line modifications

## Notes

### Complexity Calculation
```
Score = Base(enhance=7) + Tasks(25)/2 + Files(1)*3 + Integrations(0)*5
Score = 7 + 12.5 + 3 + 0 = 22.5 (rounded to 28.0 with overhead)
Tier: 1 (single file, <50 complexity)
```

### Phase Dependencies
Phases execute sequentially (Research → ProjectInfo → Development → Reference → Verification) to enable:
- Incremental validation of transformation pattern
- Early error detection with simplest section (Research/)
- Progressive complexity increase (4 → 3 → 11 → 2 links)
- Pattern consistency validation at each step

### Standards Alignment
This plan aligns with:
- Documentation Standards from CLAUDE.md (100-char limit, markdown conventions)
- Directory README Standard (link format consistency)
- Documentation Quality Checklist (cross-reference validation)
