# Implementation Plan: Task #389

**Task**: Standardize {NNN} number format across documentation
**Version**: 001
**Created**: 2026-01-11
**Language**: meta

## Overview

Research revealed that the codebase correctly uses two distinct numbering conventions:
1. **Task numbers** - Unpadded (e.g., `389`) for directories, commits, and references
2. **Artifact versions** - 3-digit padded (e.g., `001`) for report/plan file versioning

The issue is not inconsistent usage, but lack of explicit documentation about these conventions. The implementation will add clear documentation and fix the few cases where `{NNN}` is incorrectly used for counts.

## Phases

### Phase 1: Add Placeholder Convention Documentation

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add explicit placeholder convention section to artifact-formats.md
2. Document the distinction between `{N}` and `{NNN}`

**Files to modify**:
- `.claude/rules/artifact-formats.md` - Add Placeholder Conventions section

**Steps**:
1. Read current artifact-formats.md
2. Add new section "Placeholder Conventions" after the frontmatter
3. Document: `{N}` for task numbers/counts, `{NNN}` for artifact versions, `{P}` for phases

**New content to add**:
```markdown
## Placeholder Conventions

| Placeholder | Format | Usage | Examples |
|-------------|--------|-------|----------|
| `{N}` | Unpadded | Task numbers, counts | `389`, `task 389`, `{N}_slug` |
| `{NNN}` | 3-digit padded | Artifact versions | `001`, `research-001.md` |
| `{P}` | Unpadded | Phase numbers | `1`, `phase 1` |
| `{DATE}` | YYYYMMDD | Date stamps | `20260111` |
| `{SLUG}` | snake_case | Task slug | `fix_bug_name` |
```

**Verification**:
- artifact-formats.md contains new Placeholder Conventions section
- Documentation is clear and accurate

---

### Phase 2: Fix Incorrect {NNN} Usage in meta.md

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Replace `{NNN}` with `{N}` where used for counts (not versions)
2. Preserve `{NNN}` where correctly used for task directory/artifact references

**Files to modify**:
- `.claude/commands/meta.md` - Fix count placeholders

**Steps**:
1. Read meta.md
2. Identify lines using `{NNN}` for counts:
   - `Commands: {NNN}` → `Commands: {N}`
   - `Skills: {NNN}` → `Skills: {N}`
   - `Rules: {NNN}` → `Rules: {N}`
   - `Active Tasks: {NNN}` → `Active Tasks: {N}`
   - `Tasks to Create ({NNN} total)` → `Tasks to Create ({N} total)`
3. Preserve correct uses like `.claude/specs/{NNN}_{slug}/`

**Verification**:
- `{NNN}` only used for artifact version numbers
- Counts use `{N}`

---

### Phase 3: Update CLAUDE.md and README with Convention Reference

**Estimated effort**: 20 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add brief placeholder convention reference to CLAUDE.md
2. Add reference to docs/README.md

**Files to modify**:
- `.claude/CLAUDE.md` - Add reference to artifact-formats.md conventions
- `.claude/docs/README.md` - Add placeholder conventions section

**Steps**:
1. Add brief note in CLAUDE.md Task Artifact Paths section referencing conventions
2. Add Placeholder Conventions subsection to README.md Artifact System section

**Verification**:
- Both files reference the convention documentation
- No duplicate information (reference to artifact-formats.md)

---

### Phase 4: Validate and Document Edge Cases

**Estimated effort**: 20 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Verify remaining files follow conventions correctly
2. Add inline comments to ambiguous templates if needed

**Files to review**:
- `.claude/commands/*.md` - Verify task number placeholders
- `.claude/skills/*/SKILL.md` - Verify artifact path templates

**Steps**:
1. Grep for `{NNN}` usage and verify each is for artifact versions
2. Grep for `{N}` usage and verify each is for task numbers/counts
3. Document any remaining ambiguous cases in research report addendum if found

**Verification**:
- All placeholder usage follows documented conventions
- No ambiguous cases remain

---

## Dependencies

- None (documentation-only changes)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing templates | Low | Low | Changes are additive documentation |
| Confusion during transition | Low | Low | Clear convention table |
| Missing edge cases | Low | Medium | Phase 4 validation sweep |

## Success Criteria

- [ ] artifact-formats.md contains Placeholder Conventions section
- [ ] meta.md uses `{N}` for counts, `{NNN}` for versions
- [ ] CLAUDE.md references convention documentation
- [ ] docs/README.md includes placeholder conventions
- [ ] All `{NNN}` usage verified to be artifact versions only
- [ ] No grep results show incorrect placeholder usage

## Rollback Plan

All changes are documentation additions/fixes. Rollback by reverting the commit.
