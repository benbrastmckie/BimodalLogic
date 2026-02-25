# Artifact Templates

Full templates for research reports, implementation plans, and summaries.

## Placeholder Conventions

| Placeholder | Format | Usage | Examples |
|-------------|--------|-------|----------|
| `{N}` | Unpadded integer | Task numbers | `389`, `task 389:` |
| `{NNN}` | 3-digit padded | Artifact versions | `001`, `research-001.md` |
| `{P}` | Unpadded integer | Phase numbers | `1`, `phase 1:` |
| `{DATE}` | YYYYMMDD | Date stamps in filenames | `20260111` |
| `{ISO_DATE}` | YYYY-MM-DD | ISO dates in content | `2026-01-11` |
| `{SLUG}` | snake_case | Task slug from title | `fix_bug_name` |

## Research Report Template

**Location**: `specs/{N}_{SLUG}/reports/research-{NNN}.md`

```markdown
# Research Report: Task #{N}

**Task**: {title}
**Date**: {ISO_DATE}
**Focus**: {optional focus}

## Summary

{2-3 sentence overview}

## Findings

### {Topic}

{Details with evidence}

## Recommendations

1. {Actionable recommendation}

## References

- {Source with link if applicable}

## Next Steps

{What to do next}
```

## Implementation Plan Template

**Location**: `specs/{N}_{SLUG}/plans/implementation-{NNN}.md`

```markdown
# Implementation Plan: Task #{N}

**Task**: {title}
**Version**: {NNN}
**Created**: {ISO_DATE}
**Language**: {language}

## Overview

{Approach summary}

## Phases

### Phase 1: {Name}

**Dependencies**: None
**Estimated effort**: {hours}
**Status**: [NOT STARTED]

**Objectives**:
1. {Objective}

**Files to modify**:
- `path/to/file` - {changes}

**Steps**:
1. {Step}

**Verification**:
- {How to verify}

---

## Dependencies

- {Dependency}

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|

## Success Criteria

- [ ] {Criterion}
```

## Implementation Summary Template

**Location**: `specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md`

```markdown
# Implementation Summary: Task #{N}

**Completed**: {ISO_DATE}
**Duration**: {time}

## Changes Made

{Overview}

## Files Modified

- `path/to/file` - {change}

## Verification

- {What was verified}

## Notes

{Additional notes}
```

## Team Artifact Naming

### Team Research Artifacts

| Artifact | Path Pattern |
|----------|--------------|
| Teammate findings | `specs/{N}_{SLUG}/reports/research-{RRR}-teammate-{letter}-findings.md` |
| Synthesized report | `specs/{N}_{SLUG}/reports/research-{RRR}.md` |

### Team Planning Artifacts

| Artifact | Path Pattern |
|----------|--------------|
| Candidate plan | `specs/{N}_{SLUG}/plans/plan-{RRR}-candidate-{letter}.md` |
| Risk analysis | `specs/{N}_{SLUG}/plans/plan-{RRR}-risk-analysis.md` |
| Synthesized plan | `specs/{N}_{SLUG}/plans/implementation-{RRR}.md` |

### Team Implementation Artifacts

| Artifact | Path Pattern |
|----------|--------------|
| Phase results | `specs/{N}_{SLUG}/phases/impl-{RRR}-phase-{P}-results.md` |
| Debug hypothesis | `specs/{N}_{SLUG}/debug/impl-{RRR}-debug-{DDD}-hypothesis.md` |
| Synthesized summary | `specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md` |

### Team Placeholder Legend

| Placeholder | Format | Description |
|-------------|--------|-------------|
| `{RRR}` | 3-digit padded | Run number (001, 002, ...) |
| `{letter}` | lowercase | Teammate identifier (a, b, c, d) |
| `{DDD}` | 3-digit padded | Debug cycle number (001, 002, ...) |
