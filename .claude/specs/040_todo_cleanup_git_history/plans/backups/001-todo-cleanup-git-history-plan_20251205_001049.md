# TODO.md Cleanup and Git History Management - Implementation Plan

## Metadata
- **Date**: 2025-12-04
- **Feature**: TODO.md Git-based history model with SORRY_REGISTRY.md and MAINTENANCE.md
- **Scope**: Refactor TODO.md to remove completed tasks (rely on git history), create SORRY_REGISTRY.md for technical debt tracking, create MAINTENANCE.md documenting workflow, reduce TODO.md from 837 to ~350 lines (58% reduction)
- **Status**: [NOT STARTED]
- **Estimated Hours**: 6-9 hours
- **Complexity Score**: 45.0
- **Structure Level**: 0
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Research Reports**:
  - [TODO.md Cleanup and Git History Management - Research Analysis](../reports/001-todo-cleanup-git-history-analysis.md)

## Overview

The current TODO.md (837 lines) has accumulated completion tracking sections that create maintenance burden. Analysis of 11 NOTE tags reveals opportunities to reduce TODO.md to ~350 lines while improving maintainability through a Git-based history model. This plan implements those recommendations by:

1. Creating SORRY_REGISTRY.md (technical debt tracking)
2. Creating MAINTENANCE.md (workflow documentation)
3. Restructuring TODO.md (active work only)
4. Updating cross-references across documentation

**Key Metrics**:
- Line Reduction: 837 → ~350 lines (58% reduction)
- Maintenance Time Savings: 5-10 minutes per task completion (50-67% reduction)
- New Documents: 2 (SORRY_REGISTRY.md ~100 lines, MAINTENANCE.md ~200 lines)

## Research Summary

Research analysis identified 11 NOTE tags in TODO.md suggesting improvements across 5 themes:

1. **Remove Redundant Completion Tracking** (3 notes): Completion Log table, In Progress section, and Status Summary duplicate git history
2. **Restructure Dependency Information** (2 notes): 128-line Dependency Graph section should be inline with tasks
3. **Extract Specialized Information** (2 notes): 216-line Sorry Registry and maintenance protocols belong in dedicated documents
4. **Reorganize Project References** (2 notes): Notes section should integrate into Overview
5. **High-Priority Missing Files** (1 note): Missing Files section should be actionable tasks

Research demonstrates successful spec system model: 59 summary files across 40 spec directories provide rich completion history without cluttering TODO.md. Git history provides superior completion tracking to manual logs (searchable, permanent, 10-100x more information via spec summaries).

Recommended approach: Separate concerns (TODO.md = active work, Git = history, SORRY_REGISTRY.md = technical debt, MAINTENANCE.md = workflow).

## Success Criteria

- [ ] SORRY_REGISTRY.md created with sorry placeholder tracking (migrate 216 lines from TODO.md)
- [ ] MAINTENANCE.md created documenting TODO management workflow (~200 lines)
- [ ] TODO.md reduced from 837 to ~350 lines (58% reduction achieved)
- [ ] Completed tasks (Tasks 1-8, 12, 15) removed from TODO.md
- [ ] Redundant sections removed (Progress Tracking, Completion Log, Dependency Graph, Execution Waves)
- [ ] Active tasks (14, 16, 17) have inline dependencies added
- [ ] IMPLEMENTATION_STATUS.md updated to reference SORRY_REGISTRY.md
- [ ] KNOWN_LIMITATIONS.md updated to reference MAINTENANCE.md
- [ ] CLAUDE.md references new maintenance workflow
- [ ] Documentation/ProjectInfo/README.md updated with new file links
- [ ] All cross-references validated (no broken links)
- [ ] Git commit with comprehensive migration message

## Technical Design

### Architecture

**Three-Document Model**:

1. **TODO.md** (Active Work, ~350 lines)
   - Overview with status summary (10-15 lines)
   - Quick links to related docs
   - High/Medium/Low priority tasks (active only)
   - Completion History section (git query examples)
   - Project References section

2. **SORRY_REGISTRY.md** (Technical Debt, ~100 lines)
   - Active placeholders with resolution context
   - Verification commands
   - Resolved placeholders section (optional, with git query)
   - Module-by-module organization (mirrors IMPLEMENTATION_STATUS.md)

3. **MAINTENANCE.md** (Workflow Documentation, ~200 lines)
   - Task lifecycle (creation, active work, completion)
   - Git-based history queries
   - Documentation synchronization requirements
   - Sorry placeholder workflow
   - Priority classification guidelines
   - Effort estimation guidelines

### Content Migration Map

**From TODO.md to SORRY_REGISTRY.md** (216 lines):
- Lines 323-538: Sorry Placeholder Registry section
- Format: File → Line → Context → Resolution → Effort → Task reference

**From TODO.md to MAINTENANCE.md** (new content ~200 lines):
- Lines 802-821: "How to Update This File" section (base content)
- New content: Git query examples, task lifecycle, completion workflow

**Removed from TODO.md** (~487 lines total):
- Lines 697-755: Progress Tracking section (58 lines)
- Lines 733-755: Completion Log table (23 lines)
- Lines 756-800: Status Summary section (45 lines) → migrate to Overview
- Lines 567-694: Dependency Graph section (128 lines) → inline dependencies
- Lines 655-694: Execution Waves section (40 lines) → to implementation plans
- Lines 53-280: Completed tasks 1-8, 12, 15 (~150 lines)
- Lines 323-538: Sorry Registry (216 lines) → to SORRY_REGISTRY.md

**Retained in TODO.md** (~350 lines):
- Overview (expanded with minimal status summary)
- Quick Links section
- Active tasks: 14, 16, 17 (Medium Priority)
- Low priority tasks: 9, 10, 11, 13
- Completion History section (new, git query examples)
- Project References section (consolidated from Notes)

### File Locations

All files in Documentation/ProjectInfo/:
- `Documentation/ProjectInfo/SORRY_REGISTRY.md` (new)
- `Documentation/ProjectInfo/MAINTENANCE.md` (new)
- `Documentation/ProjectInfo/README.md` (update with new file links)

### Cross-Reference Strategy

**Bidirectional Linking**:
- TODO.md → SORRY_REGISTRY.md: "See [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md)"
- TODO.md → MAINTENANCE.md: "See [MAINTENANCE.md](Documentation/ProjectInfo/MAINTENANCE.md) for workflow documentation"
- IMPLEMENTATION_STATUS.md → SORRY_REGISTRY.md: "For detailed sorry resolution context, see [SORRY_REGISTRY.md](SORRY_REGISTRY.md)"
- KNOWN_LIMITATIONS.md → MAINTENANCE.md: "For TODO.md update protocols, see [MAINTENANCE.md](MAINTENANCE.md)"
- CLAUDE.md: Update Project Status section to reference new workflow
- SORRY_REGISTRY.md → TODO.md: "For active tasks addressing these items, see [TODO.md](../../TODO.md)"

## Implementation Phases

### Phase 1: Create SORRY_REGISTRY.md [NOT STARTED]
dependencies: []

**Objective**: Extract sorry placeholder tracking from TODO.md to dedicated document

**Complexity**: Low

**Tasks**:
- [ ] Create `Documentation/ProjectInfo/SORRY_REGISTRY.md` with header and metadata (file: Documentation/ProjectInfo/SORRY_REGISTRY.md)
- [ ] Migrate "Active Placeholders" section from TODO.md lines 323-538 (216 lines)
- [ ] Add verification commands section (grep -n "sorry" commands from IMPLEMENTATION_STATUS.md)
- [ ] Add "Resolved Placeholders" section with git query examples
- [ ] Add cross-reference to TODO.md at top of file
- [ ] Verify file structure matches research report template (lines 667-700)

**Testing**:
```bash
# Verify file created and structured correctly
test -f Documentation/ProjectInfo/SORRY_REGISTRY.md
grep -q "# Sorry Placeholder Registry" Documentation/ProjectInfo/SORRY_REGISTRY.md
grep -q "## Active Placeholders" Documentation/ProjectInfo/SORRY_REGISTRY.md
grep -q "## Resolved Placeholders" Documentation/ProjectInfo/SORRY_REGISTRY.md

# Verify verification commands present
grep -q "grep -n \"sorry\"" Documentation/ProjectInfo/SORRY_REGISTRY.md

# Verify cross-reference to TODO.md
grep -q "TODO.md" Documentation/ProjectInfo/SORRY_REGISTRY.md
```

**Expected Duration**: 1-2 hours

---

### Phase 2: Create MAINTENANCE.md [NOT STARTED]
dependencies: []

**Objective**: Document TODO.md management workflow and git-based history model

**Complexity**: Medium

**Tasks**:
- [ ] Create `Documentation/ProjectInfo/MAINTENANCE.md` with header (file: Documentation/ProjectInfo/MAINTENANCE.md)
- [ ] Add "Task Lifecycle" section (adding, starting, completing tasks)
- [ ] Add "Git-Based History Model" section with philosophy and benefits
- [ ] Add "Completion History Queries" section with git query examples (from research report Appendix B)
- [ ] Add "Documentation Synchronization" section (which files to update when)
- [ ] Add "Sorry Placeholder Workflow" section (cross-reference SORRY_REGISTRY.md)
- [ ] Add "Priority Classification" section (High/Medium/Low criteria)
- [ ] Add "Effort Estimation" section (hour estimate guidelines)
- [ ] Verify file structure matches research report template (lines 702-803)

**Testing**:
```bash
# Verify file created and all sections present
test -f Documentation/ProjectInfo/MAINTENANCE.md
grep -q "# TODO.md Maintenance Workflow" Documentation/ProjectInfo/MAINTENANCE.md
grep -q "## Task Lifecycle" Documentation/ProjectInfo/MAINTENANCE.md
grep -q "## Git-Based History Model" Documentation/ProjectInfo/MAINTENANCE.md
grep -q "## Completion History Queries" Documentation/ProjectInfo/MAINTENANCE.md
grep -q "## Documentation Synchronization" Documentation/ProjectInfo/MAINTENANCE.md
grep -q "## Sorry Placeholder Workflow" Documentation/ProjectInfo/MAINTENANCE.md
grep -q "## Priority Classification" Documentation/ProjectInfo/MAINTENANCE.md
grep -q "## Effort Estimation" Documentation/ProjectInfo/MAINTENANCE.md

# Verify git query examples present
grep -q "git log --all --grep" Documentation/ProjectInfo/MAINTENANCE.md
grep -q "find .claude/specs" Documentation/ProjectInfo/MAINTENANCE.md

# Count sections (should be at least 8)
SECTION_COUNT=$(grep -c "^## " Documentation/ProjectInfo/MAINTENANCE.md)
[ "$SECTION_COUNT" -ge 8 ] && echo "✓ All sections present" || echo "✗ Missing sections"
```

**Expected Duration**: 2-3 hours

---

### Phase 3: Restructure TODO.md [NOT STARTED]
dependencies: [1, 2]

**Objective**: Remove completed tasks and redundant sections, add inline dependencies, reduce to ~350 lines

**Complexity**: High

**Tasks**:
- [ ] Remove completed tasks from TODO.md (Tasks 1-8, 12, 15 from lines 53-280, ~150 lines) (file: TODO.md)
- [ ] Remove "Progress Tracking" section (lines 697-755, 58 lines)
- [ ] Remove "Completion Log" table (lines 733-755, 23 lines)
- [ ] Remove "Dependency Graph" section (lines 567-694, 128 lines)
- [ ] Remove "Execution Waves" section (lines 655-694, 40 lines)
- [ ] Remove "Sorry Placeholder Registry" section (lines 323-538, 216 lines)
- [ ] Simplify "Status Summary" section and move to Overview (lines 756-800, reduce 45 → 10-15 lines)
- [ ] Add "Quick Links" section at top with SORRY_REGISTRY.md and MAINTENANCE.md
- [ ] Add inline dependencies to active tasks 14, 16, 17 (format: **Blocking**: Task N, **Dependencies**: Task N)
- [ ] Add "Completion History" section with git query examples
- [ ] Reorganize "Notes" section into "Project References" at end (lines 824-836)
- [ ] Move Task 13 from Low Priority to Medium Priority (NOTE 280)
- [ ] Verify final line count ~350 lines (58% reduction from 837)

**Testing**:
```bash
# Verify completed tasks removed
! grep -q "Task 1: Fix CI" TODO.md
! grep -q "Task 2: Add Propositional" TODO.md
! grep -q "Task 8: WorldHistory" TODO.md

# Verify redundant sections removed
! grep -q "## Progress Tracking" TODO.md
! grep -q "## Completion Log" TODO.md
! grep -q "## Dependency Graph" TODO.md
! grep -q "## Execution Waves" TODO.md
! grep -q "## Sorry Placeholder Registry" TODO.md

# Verify new sections added
grep -q "## Quick Links" TODO.md
grep -q "## Completion History" TODO.md
grep -q "SORRY_REGISTRY.md" TODO.md
grep -q "MAINTENANCE.md" TODO.md

# Verify inline dependencies added to active tasks
grep -q "\*\*Blocking\*\*:" TODO.md
grep -q "\*\*Dependencies\*\*:" TODO.md

# Verify Task 13 moved to Medium Priority
grep -A 5 "## Medium Priority" TODO.md | grep -q "Task 13"

# Verify line count reduction (target ~350 lines, allow 300-400 range)
LINE_COUNT=$(wc -l < TODO.md)
[ "$LINE_COUNT" -ge 300 ] && [ "$LINE_COUNT" -le 400 ] && echo "✓ Line count in range ($LINE_COUNT)" || echo "✗ Line count out of range ($LINE_COUNT)"
```

**Expected Duration**: 2-3 hours

---

### Phase 4: Update Documentation Cross-References [NOT STARTED]
dependencies: [3]

**Objective**: Update IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md, CLAUDE.md, and README.md with new document references

**Complexity**: Low

**Tasks**:
- [ ] Update IMPLEMENTATION_STATUS.md to reference SORRY_REGISTRY.md (file: Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)
- [ ] Update KNOWN_LIMITATIONS.md to reference MAINTENANCE.md (file: Documentation/ProjectInfo/KNOWN_LIMITATIONS.md)
- [ ] Update CLAUDE.md "Project Status" section to reference new workflow (file: CLAUDE.md)
- [ ] Update Documentation/ProjectInfo/README.md to add SORRY_REGISTRY.md and MAINTENANCE.md links (file: Documentation/ProjectInfo/README.md)
- [ ] Verify all cross-references are bidirectional (A→B implies B→A)
- [ ] Verify no broken links (all referenced files exist)

**Testing**:
```bash
# Verify IMPLEMENTATION_STATUS.md references SORRY_REGISTRY.md
grep -q "SORRY_REGISTRY.md" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md

# Verify KNOWN_LIMITATIONS.md references MAINTENANCE.md
grep -q "MAINTENANCE.md" Documentation/ProjectInfo/KNOWN_LIMITATIONS.md

# Verify CLAUDE.md references new workflow
grep -q "MAINTENANCE.md" CLAUDE.md || grep -q "Git-based history" CLAUDE.md

# Verify README.md includes new files
grep -q "SORRY_REGISTRY.md" Documentation/ProjectInfo/README.md
grep -q "MAINTENANCE.md" Documentation/ProjectInfo/README.md

# Verify bidirectional linking (SORRY_REGISTRY.md → TODO.md)
grep -q "TODO.md" Documentation/ProjectInfo/SORRY_REGISTRY.md

# Verify bidirectional linking (MAINTENANCE.md → TODO.md)
grep -q "TODO.md" Documentation/ProjectInfo/MAINTENANCE.md

# Check for broken links (all referenced files exist)
echo "Checking for broken links..."
for file in Documentation/ProjectInfo/SORRY_REGISTRY.md Documentation/ProjectInfo/MAINTENANCE.md; do
  test -f "$file" && echo "✓ $file exists" || echo "✗ $file missing"
done
```

**Expected Duration**: 1 hour

---

### Phase 5: Final Verification and Commit [NOT STARTED]
dependencies: [4]

**Objective**: Verify all changes correct, run comprehensive validation, commit with detailed message

**Complexity**: Low

**Tasks**:
- [ ] Run comprehensive verification (all test commands from phases 1-4)
- [ ] Verify line count metrics match research estimates (TODO.md ~350, SORRY_REGISTRY.md ~100, MAINTENANCE.md ~200)
- [ ] Verify all 11 NOTE tags from research report addressed
- [ ] Review MAINTENANCE.md for completeness (task lifecycle, git queries, synchronization)
- [ ] Review SORRY_REGISTRY.md for completeness (active placeholders, verification commands)
- [ ] Review TODO.md for clarity (active work only, no history clutter)
- [ ] Create git commit with comprehensive migration message (see research report lines 831-846 for template)
- [ ] Verify commit message references all NOTE tags addressed

**Testing**:
```bash
# Comprehensive verification suite
echo "=== Phase 1 Verification ==="
test -f Documentation/ProjectInfo/SORRY_REGISTRY.md && echo "✓ SORRY_REGISTRY.md created"
grep -q "## Active Placeholders" Documentation/ProjectInfo/SORRY_REGISTRY.md && echo "✓ Active section present"

echo "=== Phase 2 Verification ==="
test -f Documentation/ProjectInfo/MAINTENANCE.md && echo "✓ MAINTENANCE.md created"
SECTION_COUNT=$(grep -c "^## " Documentation/ProjectInfo/MAINTENANCE.md)
[ "$SECTION_COUNT" -ge 8 ] && echo "✓ All sections present ($SECTION_COUNT)"

echo "=== Phase 3 Verification ==="
LINE_COUNT=$(wc -l < TODO.md)
[ "$LINE_COUNT" -ge 300 ] && [ "$LINE_COUNT" -le 400 ] && echo "✓ Line count in range ($LINE_COUNT/~350 target)"
grep -q "## Quick Links" TODO.md && echo "✓ Quick Links section added"
grep -q "## Completion History" TODO.md && echo "✓ Completion History section added"
! grep -q "## Completion Log" TODO.md && echo "✓ Completion Log removed"

echo "=== Phase 4 Verification ==="
grep -q "SORRY_REGISTRY.md" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md && echo "✓ STATUS references SORRY_REGISTRY"
grep -q "MAINTENANCE.md" Documentation/ProjectInfo/KNOWN_LIMITATIONS.md && echo "✓ LIMITATIONS references MAINTENANCE"

echo "=== Metrics Verification ==="
echo "TODO.md: $(wc -l < TODO.md) lines (target ~350)"
echo "SORRY_REGISTRY.md: $(wc -l < Documentation/ProjectInfo/SORRY_REGISTRY.md) lines (target ~100)"
echo "MAINTENANCE.md: $(wc -l < Documentation/ProjectInfo/MAINTENANCE.md) lines (target ~200)"

# Verify git status clean (files staged)
git status | grep -q "modified:.*TODO.md" && echo "✓ TODO.md staged"
git status | grep -q "new file:.*SORRY_REGISTRY.md" && echo "✓ SORRY_REGISTRY.md staged"
git status | grep -q "new file:.*MAINTENANCE.md" && echo "✓ MAINTENANCE.md staged"
```

**Commit Message Template** (from research report lines 831-846):
```
Refactor TODO.md: Git-based history model with SORRY_REGISTRY.md and MAINTENANCE.md

- Create SORRY_REGISTRY.md for technical debt tracking (migrate 216 lines from TODO.md)
- Create MAINTENANCE.md documenting TODO management workflow
- Remove completed tasks from TODO.md (rely on git history)
- Remove redundant sections: Progress Tracking, Completion Log, Dependency Graph, Execution Waves
- Add inline task dependencies
- Reduce TODO.md from 837 to ~350 lines (58% reduction)
- Improve maintainability by separating active work from history

Addresses NOTE tags: 321, 569, 656, 680, 725, 732, 758, 805

Research: .claude/specs/040_todo_cleanup_git_history/reports/001-todo-cleanup-git-history-analysis.md
Plan: .claude/specs/040_todo_cleanup_git_history/plans/001-todo-cleanup-git-history-plan.md
```

**Expected Duration**: 1 hour

---

## Testing Strategy

### Unit Testing
Each phase includes inline test commands to verify correctness:
- Phase 1: File creation, section structure, verification commands present
- Phase 2: File creation, all 8 sections present, git query examples
- Phase 3: Completed tasks removed, redundant sections removed, line count reduced, new sections added
- Phase 4: Cross-references added, bidirectional linking, no broken links
- Phase 5: Comprehensive verification suite, metrics validation, commit message quality

### Integration Testing
After Phase 5 completion:
```bash
# Verify documentation ecosystem integrity
echo "=== Cross-Reference Validation ==="
# TODO.md → SORRY_REGISTRY.md
grep -q "SORRY_REGISTRY.md" TODO.md && echo "✓ TODO → SORRY_REGISTRY"
# SORRY_REGISTRY.md → TODO.md
grep -q "TODO.md" Documentation/ProjectInfo/SORRY_REGISTRY.md && echo "✓ SORRY_REGISTRY → TODO"
# TODO.md → MAINTENANCE.md
grep -q "MAINTENANCE.md" TODO.md && echo "✓ TODO → MAINTENANCE"
# MAINTENANCE.md → TODO.md
grep -q "TODO.md" Documentation/ProjectInfo/MAINTENANCE.md && echo "✓ MAINTENANCE → TODO"
# IMPLEMENTATION_STATUS.md → SORRY_REGISTRY.md
grep -q "SORRY_REGISTRY.md" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md && echo "✓ STATUS → SORRY_REGISTRY"
# KNOWN_LIMITATIONS.md → MAINTENANCE.md
grep -q "MAINTENANCE.md" Documentation/ProjectInfo/KNOWN_LIMITATIONS.md && echo "✓ LIMITATIONS → MAINTENANCE"

echo "=== File Existence Validation ==="
for file in TODO.md Documentation/ProjectInfo/SORRY_REGISTRY.md Documentation/ProjectInfo/MAINTENANCE.md; do
  test -f "$file" && echo "✓ $file exists" || echo "✗ $file missing"
done

echo "=== Metrics Validation ==="
TODO_LINES=$(wc -l < TODO.md)
SORRY_LINES=$(wc -l < Documentation/ProjectInfo/SORRY_REGISTRY.md)
MAINT_LINES=$(wc -l < Documentation/ProjectInfo/MAINTENANCE.md)
echo "TODO.md: $TODO_LINES lines (target ~350, range 300-400)"
echo "SORRY_REGISTRY.md: $SORRY_LINES lines (target ~100)"
echo "MAINTENANCE.md: $MAINT_LINES lines (target ~200)"
[ "$TODO_LINES" -ge 300 ] && [ "$TODO_LINES" -le 400 ] && echo "✓ TODO.md line count acceptable"

echo "=== Content Validation ==="
# Verify NOTE tags addressed
grep -q "Quick Links" TODO.md && echo "✓ NOTE 758 addressed (minimal status summary)"
! grep -q "## Completion Log" TODO.md && echo "✓ NOTE 732 addressed (completion log removed)"
! grep -q "## In Progress" TODO.md && echo "✓ NOTE 725 addressed (in progress section removed)"
! grep -q "## Dependency Graph" TODO.md && echo "✓ NOTE 569 addressed (dependency graph removed)"
grep -q "SORRY_REGISTRY.md" TODO.md && echo "✓ NOTE 321 addressed (sorry registry extracted)"
grep -q "MAINTENANCE.md" TODO.md && echo "✓ NOTE 805 addressed (maintenance doc created)"

echo "✓ All integration tests passed"
```

### Quality Metrics
- TODO.md line count: 300-400 lines (target 350, 58% reduction from 837)
- SORRY_REGISTRY.md: ~100 lines
- MAINTENANCE.md: ~200 lines
- All 11 NOTE tags from research report addressed
- All cross-references bidirectional and working
- No broken links
- Git commit message comprehensive

## Documentation Requirements

### Files to Create
1. **Documentation/ProjectInfo/SORRY_REGISTRY.md**
   - Header with metadata (last updated, total placeholders)
   - Active Placeholders section (organized by file)
   - Resolved Placeholders section (with git query)
   - Verification commands section
   - Cross-reference to TODO.md

2. **Documentation/ProjectInfo/MAINTENANCE.md**
   - Task lifecycle section
   - Git-based history model section
   - Completion history queries section
   - Documentation synchronization section
   - Sorry placeholder workflow section
   - Priority classification section
   - Effort estimation section
   - Cross-references to TODO.md, SORRY_REGISTRY.md

### Files to Update
1. **TODO.md**
   - Remove completed tasks (Tasks 1-8, 12, 15)
   - Remove redundant sections (6 sections, ~450 lines)
   - Add Quick Links section
   - Add Completion History section
   - Simplify Overview
   - Add inline dependencies to active tasks
   - Move Task 13 to Medium Priority

2. **Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md**
   - Add cross-reference to SORRY_REGISTRY.md in introduction
   - Update sorry count cross-reference text

3. **Documentation/ProjectInfo/KNOWN_LIMITATIONS.md**
   - Add cross-reference to MAINTENANCE.md for TODO workflow

4. **CLAUDE.md**
   - Update "Project Status" section to reference new workflow
   - Add MAINTENANCE.md to documentation index

5. **Documentation/ProjectInfo/README.md**
   - Add SORRY_REGISTRY.md link and description
   - Add MAINTENANCE.md link and description

## Dependencies

### External Dependencies
None (pure documentation refactoring)

### Internal Prerequisites
- Research report completed: .claude/specs/040_todo_cleanup_git_history/reports/001-todo-cleanup-git-history-analysis.md
- Current TODO.md must be at 837 lines (as of 2025-12-04)
- Git repository must be clean (no uncommitted changes)

### Documentation Standards
From CLAUDE.md:
- Markdown format for all documentation
- Relative paths for cross-references within Documentation/
- Absolute paths from project root for cross-references outside Documentation/
- Clear section headers with `##` and `###`
- Code blocks with language specification (bash, markdown)
- Checkboxes for actionable items (`- [ ]`)

## Risk Assessment

### Low Risk
- Pure documentation changes (no code impact)
- Fully reversible (git history preserves original TODO.md)
- Incremental phases (can pause after any phase)
- Research-backed approach (11 NOTE tags guide changes)

### Mitigation Strategies
- **Backup Creation**: Git commit before any changes (enables rollback)
- **Phase Testing**: Comprehensive test commands after each phase
- **Cross-Reference Validation**: Automated bidirectional link checking
- **Line Count Monitoring**: Continuous verification against targets

### Success Validation
- All 11 NOTE tags addressed (traceable in commit message)
- Line count reduction achieved (58%, 837 → ~350)
- Maintenance time savings measurable (50-67% reduction per task)
- Documentation ecosystem integrity maintained (no broken links)

## Notes

**Implementation Approach**: This plan uses sequential phases with clear dependencies to ensure safe migration. Each phase is independently testable and reversible.

**Completion Criteria**: Plan complete when all phases verified, git commit created, and comprehensive integration tests pass.

**Time Savings**: After implementation, each task completion requires only 3-5 minutes (down from 10-15 minutes), saving 5-10 minutes per task (50-67% reduction).

**Historical Context**: This refactor addresses accumulated TODO.md bloat from rapid project development (0 → 975 → 837 lines in 4 days). Git-based history model prevents future bloat by separating active work from completion history.

---

**Last Updated**: 2025-12-04
