# Implementation Plan: Fix /todo Command Markdown Formatting

**Task**: 323 - Fix /todo command to run markdown formatter after completion
**Version**: 002
**Created**: 2026-01-10
**Revision of**: implementation-001.md
**Reason**: Verify plan compatibility with Claude Code migration from OpenCode system

---

## Revision Summary

### What Changed and Why

The original plan (v001) was written for the OpenCode system:
- Referenced `.opencode/scripts/format_markdown.py`
- Referenced `.opencode/command/todo.md`
- Referenced `.opencode/specs/TODO.md`

The project has migrated to Claude Code:
- Scripts remain in `.opencode/scripts/` (not yet migrated)
- TODO.md is at `.claude/specs/TODO.md`
- Commands are now skills in `.claude/skills/`

### Previous Plan Status
- Phase 1-5: [NOT STARTED] - No phases executed yet

### Key Changes
1. **Extend existing script** instead of creating new one - add formatting to `todo_cleanup.py`
2. **Update paths** from `.opencode/specs/` to `.claude/specs/`
3. **Simplify phases** since no separate script needed
4. **Note script location** - stays in `.opencode/scripts/` until full migration

---

## Overview

### Problem Statement

The /todo command (via `todo_cleanup.py`) successfully archives completed and abandoned tasks but does not apply comprehensive markdown formatting to TODO.md after archival. This results in:
- Multiple consecutive blank lines
- Inconsistent spacing around dividers and headings
- Trailing whitespace

### Revised Approach

Instead of creating a separate `format_markdown.py` script, extend the existing `todo_cleanup.py` with formatting functionality. This is simpler and keeps all TODO.md maintenance in one place.

The script path is still `.opencode/scripts/todo_cleanup.py` (not yet migrated to `.claude/scripts/`), but it now operates on `.claude/specs/TODO.md`.

### Scope

**In Scope**:
- Add `format_markdown()` function to `todo_cleanup.py`
- Apply formatting after archival operations
- Update path references from `.opencode/specs/` to `.claude/specs/`
- Test with current TODO.md

**Out of Scope**:
- Creating separate format_markdown.py script (simplified approach)
- Migrating todo_cleanup.py to .claude/scripts/ (separate task)
- Formatting other markdown files

### Definition of Done

- [ ] `format_markdown()` function added to todo_cleanup.py
- [ ] Formatting applied after archival operations
- [ ] Path references updated to `.claude/specs/`
- [ ] TODO.md properly formatted after test run
- [ ] No data loss or corruption

---

## Implementation Phases

### Phase 1: Update Paths in todo_cleanup.py [COMPLETED]

**Estimated Effort**: 15 minutes
**Status**: [COMPLETED]

**Objective**: Update script to use `.claude/specs/` instead of `.opencode/specs/`

**Tasks**:
1. Update default path constants in script
2. Update docstring references
3. Test script still finds TODO.md and state.json

**Acceptance Criteria**:
- [ ] Script uses `.claude/specs/TODO.md` by default
- [ ] Script uses `.claude/specs/state.json` by default
- [ ] Archive path updated to `.claude/specs/archive/`
- [ ] Dry-run works with new paths

**Files to Modify**:
- `.opencode/scripts/todo_cleanup.py`

---

### Phase 2: Add format_markdown() Function [COMPLETED]

**Estimated Effort**: 45 minutes
**Status**: [COMPLETED]

**Objective**: Add markdown formatting function to todo_cleanup.py

**Tasks**:
1. Add `format_markdown()` function implementing:
   - Remove trailing whitespace from all lines
   - Normalize blank lines (max 2 consecutive)
   - Ensure blank line before/after headings (## and ###)
   - Ensure blank line before/after dividers (---)
   - Ensure single trailing newline at EOF
   - Preserve frontmatter (YAML between --- markers)
   - Preserve code blocks

2. Add helper functions if needed:
   - `is_frontmatter_delimiter()`
   - `is_code_fence()`
   - `is_heading()`
   - `is_divider()`

**Acceptance Criteria**:
- [ ] format_markdown() applies all formatting rules
- [ ] Frontmatter preserved
- [ ] Code blocks preserved
- [ ] Function well-documented

---

### Phase 3: Integrate Formatting into Cleanup Flow [COMPLETED]

**Estimated Effort**: 15 minutes
**Status**: [COMPLETED]

**Objective**: Call format_markdown() after archival operations

**Tasks**:
1. Locate where cleanup writes TODO.md
2. Add format_markdown() call before final write
3. Add command-line flag `--format-only` for standalone formatting
4. Ensure formatting errors are non-critical

**Acceptance Criteria**:
- [ ] Formatting applied after archival
- [ ] `--format-only` flag works
- [ ] Formatting failure doesn't abort archival

---

### Phase 4: Test and Validate [COMPLETED]

**Estimated Effort**: 30 minutes
**Status**: [COMPLETED]

**Objective**: Verify formatting works correctly

**Tasks**:
1. Run with `--dry-run` to preview changes
2. Test on copy of TODO.md first
3. Run full cleanup with formatting
4. Verify TODO.md properly formatted
5. Verify no content loss

**Acceptance Criteria**:
- [ ] Dry-run shows formatting changes
- [ ] Full run formats correctly
- [ ] No content loss
- [ ] Frontmatter and code blocks preserved

---

## Risks and Mitigations

### Risk 1: Breaking TODO.md Content

**Likelihood**: Low
**Impact**: High
**Mitigation**:
- Test on copy first
- Use --dry-run to preview
- Git rollback available

### Risk 2: Script Path Confusion

**Likelihood**: Low
**Impact**: Medium
**Mitigation**:
- Script stays in `.opencode/scripts/` for now
- Clear documentation of path changes
- TODO.md path updated to `.claude/specs/`

---

## Testing

### Unit Tests
1. format_markdown() normalizes blank lines
2. format_markdown() removes trailing whitespace
3. format_markdown() preserves frontmatter
4. format_markdown() preserves code blocks
5. format_markdown() adds heading spacing

### Integration Tests
1. Full cleanup with formatting works
2. Archival + formatting in one pass
3. --format-only flag works standalone
4. --dry-run shows formatting changes

---

## Phase Summary

| Phase | Effort | Status |
|-------|--------|--------|
| Phase 1: Update Paths | 15 min | [NOT STARTED] |
| Phase 2: Add format_markdown() | 45 min | [NOT STARTED] |
| Phase 3: Integrate into Flow | 15 min | [NOT STARTED] |
| Phase 4: Test and Validate | 30 min | [NOT STARTED] |
| **Total** | **1.75 hours** | |

---

## Notes

### Path Migration Status

| Item | Current Location | Status |
|------|-----------------|--------|
| todo_cleanup.py | `.opencode/scripts/` | Not migrated |
| TODO.md | `.claude/specs/` | Migrated |
| state.json | `.claude/specs/` | Migrated |
| archive/ | `.claude/specs/archive/` | Migrated |

### Comparison to v001

| Aspect | v001 | v002 |
|--------|------|------|
| Approach | Separate format_markdown.py | Extend todo_cleanup.py |
| Effort | 4 hours | 1.75 hours |
| Phases | 5 | 4 |
| Complexity | Medium | Low |

The revised approach is simpler because:
- No new script to create and maintain
- Formatting integrated into existing cleanup flow
- Fewer files to modify

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 001 | 2026-01-07 | Initial plan for OpenCode system |
| 002 | 2026-01-10 | Revised for Claude Code migration, simplified approach |
