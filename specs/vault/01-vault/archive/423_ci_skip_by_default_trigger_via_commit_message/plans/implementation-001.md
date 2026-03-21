# Implementation Plan: Task #423

**Task**: CI skip by default, trigger via commit message
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

This plan implements a CI workflow that skips by default and only runs when explicitly triggered via a `[ci]` marker in the commit message. The implementation extends the existing `skill-git-workflow` with a `trigger_ci` parameter, modifies the GitHub Actions workflow, and documents CI decision criteria.

## Phases

### Phase 1: Update GitHub Actions CI Workflow

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add conditional logic to skip CI by default
2. Enable CI triggering via `[ci]` marker in commit message
3. Preserve manual dispatch and pull request CI runs

**Files to modify**:
- `.github/workflows/ci.yml` - Add job-level conditional

**Steps**:
1. Add `if` conditional to the `build` job that checks for:
   - `workflow_dispatch` event (manual trigger)
   - `pull_request` event (PRs should always run CI)
   - `[ci]` marker in commit message for push events
2. Test the conditional logic by reviewing the YAML structure

**Verification**:
- CI workflow file has valid YAML syntax
- Conditional covers all three trigger scenarios

---

### Phase 2: Extend skill-git-workflow with trigger_ci Parameter

**Estimated effort**: 45 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add `trigger_ci` parameter documentation to skill
2. Document commit message format with `[ci]` marker
3. Update return format to indicate CI trigger status

**Files to modify**:
- `.claude/skills/skill-git-workflow/SKILL.md` - Add trigger_ci parameter and CI marker logic

**Steps**:
1. Add "CI Triggering" section documenting the `trigger_ci` parameter
2. Update "Commit Message Formats" table to show `[ci]` marker option
3. Add "CI Decision Criteria" subsection listing when to trigger CI
4. Update execution flow to include CI marker appending logic
5. Update return format to include `ci_triggered` field

**Verification**:
- Skill documentation clearly explains trigger_ci usage
- Commit message formats show both with and without `[ci]` marker

---

### Phase 3: Create CI Workflow Standards Documentation

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Document CI trigger decision criteria
2. Create reusable reference for operators and skills
3. Establish conventions for when CI should run

**Files to create**:
- `.claude/context/core/standards/ci-workflow.md` - CI workflow standards and decision criteria

**Steps**:
1. Create new standards document with sections:
   - Overview of skip-by-default behavior
   - CI trigger markers (`[ci]`, `[run-ci]`)
   - Decision criteria (when to trigger CI)
   - File types that warrant CI
   - Task lifecycle CI triggers
2. Document the commit message format with marker
3. Add examples of commits with and without CI marker

**Verification**:
- Document follows existing standards format in `.claude/context/core/standards/`
- Decision criteria is clear and actionable

---

### Phase 4: Update Context Index

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Register new CI workflow documentation in context index
2. Ensure discoverability of CI standards

**Files to modify**:
- `.claude/context/index.md` - Add entry for ci-workflow.md

**Steps**:
1. Add ci-workflow.md entry to the standards section of the index
2. Ensure proper categorization and description

**Verification**:
- Entry appears in index.md
- Path is correct and file exists

---

## Dependencies

- Phase 2 depends on Phase 1 (CI workflow must be configured before skill references it)
- Phase 3 can run in parallel with Phase 2
- Phase 4 depends on Phase 3 (index references the document)

## Execution Order

```
Phase 1 ──┬──> Phase 2 ──> Phase 4
          │
          └──> Phase 3 ──┘
```

Recommended sequential order: 1 -> 2 -> 3 -> 4

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| CI never runs accidentally | High | Keep workflow_dispatch for manual trigger; PRs always run CI |
| Invalid YAML syntax | Medium | Validate workflow file syntax before committing |
| Marker forgotten for important changes | Medium | Document criteria clearly; rely on PRs for safety net |
| Inconsistent marker usage | Low | Standardize on `[ci]` marker only |

## Success Criteria

- [ ] CI workflow skips on push unless `[ci]` marker present
- [ ] CI workflow runs on manual dispatch
- [ ] CI workflow runs on pull requests
- [ ] skill-git-workflow documents trigger_ci parameter
- [ ] CI workflow standards documented in context
- [ ] Context index updated with new documentation

## Testing Strategy

1. **Manual verification**: Review workflow YAML for correct conditional logic
2. **Documentation review**: Ensure all new documentation is consistent and complete
3. **Integration check**: Verify skill documentation aligns with workflow behavior

## Rollback Plan

If issues arise:
1. Remove the `if` conditional from ci.yml to restore default behavior
2. Revert skill-git-workflow changes
3. Remove ci-workflow.md documentation
