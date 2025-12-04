# README.md Documentation Reorganization Implementation Plan

## Metadata
- **Date**: 2025-12-04
- **Feature**: Systematic remediation of 5 NOTE tags in README.md
- **Status**: [COMPLETE]
- **Estimated Hours**: 2-3 hours
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Research Reports**:
  - [README.md NOTE Tags Analysis](../reports/001-readme-note-tags-analysis.md)
- **Complexity Score**: 28.5
- **Structure Level**: 0

## Overview

This plan addresses 5 NOTE tags in README.md raising documentation organization issues: (1) Implementation Status maintenance burden, (2) Progressive Extension Methodology content repetition, (3) Medical Planning incomplete operator specification, (4) Legal Reasoning incomplete operator specification, and (5) LOGOS_PHILOSOPHY.md document renaming to METHODOLOGY.md. All issues are documentation-only improvements requiring no code changes.

## Research Summary

Research report identified 5 NOTE tags systematically:
- **NOTE 1 (line 79)**: Implementation Status section duplicates IMPLEMENTATION_STATUS.md content, creating maintenance burden
- **NOTE 2 (line 159)**: Progressive Extension Methodology repeats content from Logos overview section
- **NOTE 3 (line 180)**: Medical Planning omits epistemic operators despite medical reasoning requiring uncertainty quantification
- **NOTE 4 (line 189)**: Legal Reasoning omits normative operators despite legal reasoning requiring deontic logic
- **NOTE 5 (line 204)**: LOGOS_PHILOSOPHY.md naming misalignment (80% methodology content, 20% philosophy content)

Recommended approach: Three-phase implementation (content corrections, structural reorganization, file renaming) to minimize edit conflicts.

## Success Criteria

- [ ] All 5 NOTE tags removed from README.md
- [ ] Implementation Status section condensed to ≤10 lines with authoritative document links
- [ ] No duplicate "Core Principle" or "Extension Strategy" content in README.md
- [ ] Medical Planning specifies "Core + Explanatory + Epistemic" with epistemic operators listed
- [ ] Legal Reasoning specifies "Core + Epistemic + Normative" with normative operators listed
- [ ] LOGOS_PHILOSOPHY.md renamed to METHODOLOGY.md with 19 references updated
- [ ] No broken markdown links after file renaming
- [ ] Zero grep results for `grep -n "NOTE:" README.md`
- [ ] Zero grep results for `grep -r "LOGOS_PHILOSOPHY" . --exclude-dir=.git`

## Technical Design

### Architecture Overview

This is a pure documentation reorganization effort with no code changes. The architecture involves:

1. **Content Corrections**: Localized edits to specific sections (medical/legal domain specifications)
2. **Structural Reorganization**: Section consolidation and redundancy removal (Implementation Status, Progressive Extension)
3. **File Renaming**: Systematic find-replace with git history preservation (LOGOS_PHILOSOPHY.md → METHODOLOGY.md)

### Component Interactions

- **README.md**: Primary target for content corrections and structural reorganization
- **Documentation/UserGuide/LOGOS_PHILOSOPHY.md** (→ METHODOLOGY.md): Target for parallel content corrections and renaming
- **19 referencing files**: Targets for systematic reference updates after file renaming

### Standards Alignment

- **Documentation Standards**: All edits follow markdown formatting conventions (backticks for formal symbols, relative links for cross-references)
- **Backtick Standard**: Formal symbols (□, ◇, Pr, B, O, P) in inline prose require backticks per Documentation/Development/LEAN_STYLE_GUIDE.md
- **Git Standards**: Use `git mv` for file renaming to preserve history

## Implementation Phases

### Phase 1: Content Corrections [COMPLETE]
dependencies: []

**Objective**: Correct Medical Planning and Legal Reasoning operator specifications in README.md and LOGOS_PHILOSOPHY.md

**Complexity**: Low

**Tasks**:
- [x] Update Medical Planning specification to "Core + Explanatory + Epistemic" (README.md line 182)
- [x] Add epistemic operators to Medical Planning: Probability (`Pr`), belief (`B`) (README.md lines 183-187)
- [x] Update Legal Reasoning specification to "Core + Epistemic + Normative" (README.md line 191)
- [x] Add normative operators to Legal Reasoning: Obligation (`O`), Permission (`P`) (README.md lines 192-194)
- [x] Apply identical corrections to LOGOS_PHILOSOPHY.md lines 91-97
- [x] Remove NOTE tag at line 180 (Medical Planning)
- [x] Remove NOTE tag at line 189 (Legal Reasoning)

**Testing**:
```bash
# Verify Medical Planning includes epistemic operators
grep -A 5 "Medical Planning" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md | grep -q "Epistemic"

# Verify Legal Reasoning includes normative operators
grep -A 5 "Legal Reasoning" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md | grep -q "Normative"

# Verify LOGOS_PHILOSOPHY.md corrections applied
grep -A 5 "Medical Planning" /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/LOGOS_PHILOSOPHY.md | grep -q "Epistemic"
grep -A 5 "Legal Reasoning" /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/LOGOS_PHILOSOPHY.md | grep -q "Normative"

# Verify NOTE tags removed
! grep -n "NOTE.*medical needs epistemic" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md
! grep -n "NOTE.*legal needs normative" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md
```

**Expected Duration**: 30 minutes

---

### Phase 2: Structural Reorganization [COMPLETE]
dependencies: [1]

**Objective**: Redesign Implementation Status section and remove repetitive Progressive Extension content

**Complexity**: Medium

**Tasks**:
- [x] Replace Implementation Status section (lines 77-122) with concise "Quick Status" section (≤10 lines)
- [x] Include prominent links to IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md, TODO.md
- [x] Move Quick Status section after "Core Capabilities" section, before "Dual Verification Architecture"
- [x] Remove NOTE tag at line 79 (Implementation Status)
- [x] Remove "Core Principle" subsection (lines 163-165) from Progressive Extension Methodology
- [x] Remove "Extension Strategy" subsection (lines 169-176) from Progressive Extension Methodology
- [x] Rename section to "Application Domains" (focus on domain-specific examples only)
- [x] Remove NOTE tag at line 159 (Progressive Extension repetition)
- [x] Merge "Extensibility References" (lines 202-210) into section footer with cross-references

**Testing**:
```bash
# Verify Implementation Status section ≤10 lines
SECTION_START=$(grep -n "^## Implementation Status" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md | cut -d: -f1)
SECTION_END=$(tail -n +$SECTION_START /home/benjamin/Documents/Philosophy/Projects/Logos/README.md | grep -n "^##" | head -2 | tail -1 | cut -d: -f1)
LINE_COUNT=$((SECTION_END - 1))
[ "$LINE_COUNT" -le 10 ] || echo "ERROR: Implementation Status section exceeds 10 lines ($LINE_COUNT)"

# Verify no duplicate "Core Principle" content
CORE_PRINCIPLE_COUNT=$(grep -c "^### Core Principle" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md)
[ "$CORE_PRINCIPLE_COUNT" -eq 0 ] || echo "ERROR: Duplicate Core Principle sections found ($CORE_PRINCIPLE_COUNT)"

# Verify no duplicate "Extension Strategy" content
EXTENSION_STRATEGY_COUNT=$(grep -c "^### Extension Strategy" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md)
[ "$EXTENSION_STRATEGY_COUNT" -eq 0 ] || echo "ERROR: Duplicate Extension Strategy sections found ($EXTENSION_STRATEGY_COUNT)"

# Verify NOTE tags removed
! grep -n "NOTE.*maintenance burden" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md
! grep -n "NOTE.*repetitive" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md

# Verify section renamed
grep -q "^## Application Domains" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md
```

**Expected Duration**: 45 minutes

---

### Phase 3: File Renaming and Reference Updates [COMPLETE]
dependencies: [1, 2]

**Objective**: Rename LOGOS_PHILOSOPHY.md to METHODOLOGY.md and update 19 references across codebase

**Complexity**: Medium

**Tasks**:
- [x] Rename file with git history preservation: `git mv Documentation/UserGuide/LOGOS_PHILOSOPHY.md Documentation/UserGuide/METHODOLOGY.md`
- [x] Update 19 markdown link references: `LOGOS_PHILOSOPHY.md` → `METHODOLOGY.md`
- [x] Update 19 prose references: "Logos Philosophy" → "Logos Methodology"
- [x] Update document title in METHODOLOGY.md line 1
- [x] Remove NOTE tag at line 204 (LOGOS_PHILOSOPHY.md renaming)
- [x] Verify completeness with grep: `grep -r "LOGOS_PHILOSOPHY" . --exclude-dir=.git` (should return zero results)

**Affected Files** (19 files requiring updates):
- README.md (lines 20, 206, 258)
- CLAUDE.md
- .claude/specs/031_readme_logos_proof_checker_reframe/plans/*.md
- .claude/specs/031_readme_logos_proof_checker_reframe/reports/*.md
- .claude/specs/029_logos_documentation_integration/plans/*.md
- .claude/specs/029_logos_documentation_integration/reports/*.md
- Archive/logos-original/README-ARCHIVE.md
- Documentation/README.md
- Documentation/UserGuide/ARCHITECTURE.md
- Documentation/Reference/GLOSSARY.md
- Documentation/Research/*.md

**Testing**:
```bash
# Verify file renamed
test -f /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/METHODOLOGY.md || echo "ERROR: METHODOLOGY.md not found"
! test -f /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/LOGOS_PHILOSOPHY.md || echo "ERROR: LOGOS_PHILOSOPHY.md still exists"

# Verify no remaining references to LOGOS_PHILOSOPHY
REMAINING_REFS=$(grep -r "LOGOS_PHILOSOPHY" /home/benjamin/Documents/Philosophy/Projects/Logos --exclude-dir=.git | wc -l)
[ "$REMAINING_REFS" -eq 0 ] || echo "ERROR: $REMAINING_REFS references to LOGOS_PHILOSOPHY remain"

# Verify markdown links resolve
cd /home/benjamin/Documents/Philosophy/Projects/Logos
grep -h "METHODOLOGY\.md" README.md Documentation/**/*.md | while read -r line; do
  FILE_PATH=$(echo "$line" | sed -n 's/.*(\(.*METHODOLOGY\.md\)).*/\1/p')
  [ -f "$FILE_PATH" ] || echo "ERROR: Broken link to $FILE_PATH"
done

# Verify NOTE tag removed
! grep -n "NOTE.*LOGOS_PHILOSOPHY\.md.*METHODOLOGY\.md" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md
```

**Expected Duration**: 20 minutes

---

## Testing Strategy

### Unit Testing (Per Phase)

Each phase includes verification commands testing specific success criteria:
- **Phase 1**: Grep-based verification of operator specification updates and NOTE tag removal
- **Phase 2**: Line count verification, duplicate content detection, section renaming validation
- **Phase 3**: File existence checks, reference completeness verification, broken link detection

### Integration Testing (Final Verification)

After all phases complete, run comprehensive verification:

```bash
cd /home/benjamin/Documents/Philosophy/Projects/Logos

# 1. Verify all NOTE tags removed (zero results expected)
NOTE_COUNT=$(grep -c "NOTE:" README.md)
echo "NOTE tags remaining: $NOTE_COUNT (expected: 0)"

# 2. Verify Implementation Status section condensed
IMPL_STATUS_START=$(grep -n "^## Implementation Status" README.md | cut -d: -f1)
IMPL_STATUS_END=$(tail -n +$IMPL_STATUS_START README.md | grep -n "^##" | head -2 | tail -1 | cut -d: -f1)
IMPL_STATUS_LINES=$((IMPL_STATUS_END - 1))
echo "Implementation Status lines: $IMPL_STATUS_LINES (expected: ≤10)"

# 3. Verify domain operator specifications
grep -A 5 "Medical Planning" README.md | grep -q "Epistemic" && echo "✓ Medical includes Epistemic"
grep -A 5 "Legal Reasoning" README.md | grep -q "Normative" && echo "✓ Legal includes Normative"

# 4. Verify file renaming complete
test -f Documentation/UserGuide/METHODOLOGY.md && echo "✓ METHODOLOGY.md exists"
! test -f Documentation/UserGuide/LOGOS_PHILOSOPHY.md && echo "✓ LOGOS_PHILOSOPHY.md removed"

# 5. Verify no remaining LOGOS_PHILOSOPHY references
LOGOS_REFS=$(grep -r "LOGOS_PHILOSOPHY" . --exclude-dir=.git | wc -l)
echo "LOGOS_PHILOSOPHY references: $LOGOS_REFS (expected: 0)"

# 6. Verify no broken links
echo "Checking markdown links..."
grep -h "METHODOLOGY\.md" README.md Documentation/**/*.md | while read -r line; do
  FILE_PATH=$(echo "$line" | sed -n 's/.*(\(.*METHODOLOGY\.md\)).*/\1/p')
  [ -n "$FILE_PATH" ] && { [ -f "$FILE_PATH" ] && echo "✓ $FILE_PATH" || echo "✗ BROKEN: $FILE_PATH"; }
done
```

### Success Criteria Verification

All 9 success criteria must pass:
1. ✓ All 5 NOTE tags removed
2. ✓ Implementation Status ≤10 lines
3. ✓ No duplicate content
4. ✓ Medical Planning specifies Epistemic
5. ✓ Legal Reasoning specifies Normative
6. ✓ LOGOS_PHILOSOPHY.md renamed
7. ✓ 19 references updated
8. ✓ No broken links
9. ✓ Zero grep results for NOTE and LOGOS_PHILOSOPHY

## Documentation Requirements

### Documentation Updates

**Files to Update**:
- README.md (primary target for Phases 1-3)
- Documentation/UserGuide/METHODOLOGY.md (formerly LOGOS_PHILOSOPHY.md - Phases 1 and 3)
- 19 files referencing LOGOS_PHILOSOPHY.md (Phase 3)

**Update Types**:
- **Content Corrections**: Add missing operator specifications (epistemic, normative) with inline examples
- **Structural Reorganization**: Condense redundant sections, add cross-references to authoritative documents
- **Reference Updates**: Systematic find-replace for file renaming

### Documentation Standards

**Backtick Standard** (from LEAN_STYLE_GUIDE.md):
- All formal symbols in inline prose require backticks: `□`, `◇`, `Pr`, `B`, `O`, `P`
- Operator names in headings do NOT require backticks (markdown heading convention)
- Examples: "Medical Planning includes epistemic operators: Probability (`Pr`), belief (`B`)"

**Cross-Reference Standard**:
- Use relative paths for internal documentation links: `[METHODOLOGY.md](Documentation/UserGuide/METHODOLOGY.md)`
- Verify link targets exist before committing

**Git History Preservation**:
- Use `git mv` for file renaming (preserves blame history)
- Never `rm` + `touch` for renaming

## Dependencies

### External Dependencies
- None (pure documentation changes)

### Internal Dependencies
- Phase 2 depends on Phase 1 completion (avoid edit conflicts in README.md)
- Phase 3 depends on Phases 1-2 completion (avoid reference update conflicts during file renaming)

### Prerequisites
- None (no build, test, or runtime dependencies)

## Risk Assessment

### Risk 1: Broken Links After File Renaming
- **Probability**: Medium
- **Impact**: High (documentation navigation fails)
- **Mitigation**: Systematic find-replace with verification grep, test markdown link resolution
- **Rollback**: `git mv METHODOLOGY.md LOGOS_PHILOSOPHY.md` + `git revert` reference updates

### Risk 2: Lost Information During Content Removal
- **Probability**: Low
- **Impact**: Medium (essential information removed)
- **Mitigation**: Review removed content, ensure cross-references to authoritative documents, git history preserves original
- **Rollback**: `git revert` specific commits

### Risk 3: Inconsistent Updates Across Files
- **Probability**: Low
- **Impact**: Medium (some files retain old references)
- **Mitigation**: Batch updates with `find` + `sed`, verify with grep, checklist of 19 affected files
- **Rollback**: `git revert` batch update commits

## Notes

### Complexity Calculation
```
Score = Base(10) + Tasks(21)/2 + Files(21)*0.1 + Integrations(0)*5
     = 10 + 10.5 + 2.1 + 0
     = 22.6 (rounds to 23)
```
- **Base**: 10 (enhancement to existing documentation)
- **Tasks**: 21 tasks across 3 phases
- **Files**: 21 files modified (README.md, LOGOS_PHILOSOPHY.md, 19 reference files)
- **Integrations**: 0 (no external system integration)

**Tier Selection**: Score 22.6 < 50 → Tier 1 (single file plan)

### Estimated Effort Breakdown
- Phase 1 (Content Corrections): 30 minutes
- Phase 2 (Structural Reorganization): 45 minutes
- Phase 3 (File Renaming): 20 minutes
- Integration Testing: 10 minutes
- Buffer for edge cases: 20 minutes
- **Total**: 2.08 hours (2-3 hour range)

### Key Insights from Research
- All 5 NOTEs are documentation-only issues (no code changes required)
- Content corrections (Phases 1) have zero dependencies and can be parallelized if needed
- File renaming (Phase 3) has highest breakage risk but systematic approach mitigates
- Research report provides complete affected file list (19 files), enabling batch updates
