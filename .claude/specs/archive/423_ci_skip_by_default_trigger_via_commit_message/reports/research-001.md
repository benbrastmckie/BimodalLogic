# Research Report: Task #423

**Task**: CI skip by default, trigger via commit message
**Date**: 2026-01-12
**Focus**: CI workflow design and git skill integration

## Summary

This research analyzes approaches for making CI skip by default and only run when triggered via commit message markers. The goal is to enable frequent pushes without triggering expensive CI runs, while maintaining explicit control over when CI executes.

## Current State

### Existing CI Workflow (`.github/workflows/ci.yml`)

The current workflow triggers on:
- Push to main branch
- Pull requests to main branch
- Manual workflow dispatch

```yaml
on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]
  workflow_dispatch:
```

It runs build, test, and lint via `leanprover/lean-action@v1` with `--wfail` flag for warnings-as-errors.

### Existing Git Infrastructure

The project has:
1. **skill-git-workflow** (`.claude/skills/skill-git-workflow/SKILL.md`) - Creates scoped git commits for task operations
2. **Git integration standards** (`.claude/context/core/standards/git-integration.md`) - Commit message formats and patterns
3. **Git safety standards** (`.claude/context/core/standards/git-safety.md`) - Safety commit patterns

## Findings

### GitHub Actions Native Skip Support

GitHub Actions natively supports skipping workflows via commit message markers since February 2021:

**Recognized markers** (any of these in commit message):
- `[skip ci]`
- `[ci skip]`
- `[no ci]`
- `[skip actions]`
- `[actions skip]`

**Limitations**:
- Only works for `push` and `pull_request` events
- Skips based on commit message containing the skip string
- Cannot do the inverse (skip by default, run with marker)

### Inverse Pattern: Run-CI Trigger

Since GitHub doesn't natively support "skip by default, run with marker", we need a conditional approach:

**Option A: Job-level conditional**
```yaml
jobs:
  build:
    if: contains(github.event.head_commit.message, '[ci]') ||
        contains(github.event.head_commit.message, '[run-ci]')
```

**Option B: Path-based filtering**
```yaml
on:
  push:
    branches: ["main"]
    paths:
      - '**.lean'
      - 'lakefile.lean'
      - 'lake-manifest.json'
```

**Option C: Workflow dispatch only**
```yaml
on:
  workflow_dispatch:
  push:
    branches: ["main"]

jobs:
  build:
    if: github.event_name == 'workflow_dispatch' ||
        contains(github.event.head_commit.message, '[ci]')
```

### Recommended Approach: Option C

Option C provides the best balance:
1. Always available via manual dispatch (workflow_dispatch)
2. Can be triggered by `[ci]` marker in commit message
3. Otherwise skips automatically
4. Pull requests can use separate conditional logic if desired

### Git Skill Integration

The existing `skill-git-workflow` handles commit message formatting. To add CI trigger intelligence:

1. **Extend skill-git-workflow** to detect when CI should run
2. **Add CI marker logic** based on:
   - File types modified (`.lean` files, `lakefile.lean`)
   - Status changes that warrant CI (implementation complete, major changes)
   - User explicit request

### CI Trigger Decision Criteria

Intelligent CI triggering should consider:

**Run CI when**:
- Implementation phase completes
- Lean source files modified
- Lake configuration changes
- User explicitly requests via `[ci]` marker

**Skip CI when**:
- Only documentation/spec changes
- Research/planning artifacts only
- State file updates only (TODO.md, state.json)
- Minor metadata updates

### Commit Message Enhancement

Current format:
```
task {N}: {action}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

Proposed format with CI marker:
```
task {N}: {action} [ci]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

Or without CI marker (default):
```
task {N}: {action}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Architecture Design

### Option 1: Extend skill-git-workflow

Modify existing skill to:
1. Accept `trigger_ci: bool` parameter
2. Append `[ci]` to commit message when `trigger_ci: true`
3. Default to `trigger_ci: false`

**Pros**: Minimal changes, leverages existing infrastructure
**Cons**: Requires all callers to explicitly set trigger_ci

### Option 2: Create new skill-ci-decision

New skill that:
1. Analyzes staged files
2. Determines if CI should run
3. Returns decision to caller

**Pros**: Separation of concerns, reusable logic
**Cons**: Additional complexity, another skill to maintain

### Option 3: Context documentation only

Document CI conventions in `.claude/context/` and let operators decide:
1. Add CI decision guide to context
2. Update workflow prompts to include CI decision
3. Keep skill-git-workflow simple

**Pros**: Simplest approach, flexible
**Cons**: Inconsistent application, relies on operator judgment

### Recommended: Option 1 + Context Documentation

1. Extend skill-git-workflow with `trigger_ci` parameter
2. Add decision criteria documentation to context
3. Update callers (task lifecycle operations) to pass `trigger_ci` appropriately

## Implementation Considerations

### CI Workflow Changes

```yaml
name: CI

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]
  workflow_dispatch:

jobs:
  build:
    name: Build, Test, and Lint
    runs-on: ubuntu-latest
    # Only run if [ci] marker present OR manual dispatch OR PR
    if: |
      github.event_name == 'workflow_dispatch' ||
      github.event_name == 'pull_request' ||
      contains(github.event.head_commit.message, '[ci]')
```

### Skill Extension

Add to skill-git-workflow:
- `trigger_ci` input parameter (default: false)
- Logic to append `[ci]` when `trigger_ci: true`

### Context Documentation

Create `.claude/context/core/standards/ci-workflow.md`:
- When to trigger CI
- Marker conventions
- Decision criteria

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| CI never runs | High | Keep workflow_dispatch for manual trigger |
| Too many CI runs | Medium | Default to skip, require explicit marker |
| Marker forgotten for important changes | Medium | Document criteria, consider file-based triggers |
| Complexity increase | Low | Keep changes minimal, document well |

## Recommendations

1. **Modify CI workflow** to skip by default, run with `[ci]` marker
2. **Keep workflow_dispatch** for manual CI runs
3. **Extend skill-git-workflow** with `trigger_ci` parameter
4. **Document CI decision criteria** in context files
5. **Update task lifecycle** to trigger CI after implementation phases

## References

- [GitHub Actions Skip CI Documentation](https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-workflow-runs/skipping-workflow-runs)
- [GitHub Changelog: Skip workflows with skip ci](https://github.blog/changelog/2021-02-08-github-actions-skip-pull-request-and-push-workflows-with-skip-ci/)
- [GitHub Actions Runner Issue #774](https://github.com/actions/runner/issues/774)
- [Skip Workflow Marketplace Action](https://github.com/marketplace/actions/skip-workflow)

## Next Steps

1. Create implementation plan with phases
2. Implement CI workflow changes
3. Extend skill-git-workflow
4. Add context documentation
5. Update task lifecycle operations to use trigger_ci
