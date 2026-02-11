# Debug Report Format

Schema for debug reports generated during team implementation debugging cycles.

## Overview

Debug reports are created when implementation errors occur and debugger teammates analyze them. Reports track the hypothesis-analysis-resolution cycle.

## Directory Structure

```
specs/{N}_{SLUG}/debug/
├── debug-001-hypothesis.md   # First debug cycle hypothesis
├── debug-001-analysis.md     # Detailed analysis
├── debug-001-resolution.md   # Resolution outcome
├── debug-002-hypothesis.md   # Second attempt (if needed)
├── debug-002-analysis.md
├── debug-002-resolution.md
└── ...
```

## Naming Convention

| File Pattern | Purpose |
|--------------|---------|
| `debug-{NNN}-hypothesis.md` | Initial hypothesis about error cause |
| `debug-{NNN}-analysis.md` | Detailed investigation and evidence |
| `debug-{NNN}-resolution.md` | Outcome and what was changed |

Where `{NNN}` is a 3-digit padded cycle number (001, 002, etc.).

## Hypothesis Report Format

```markdown
# Debug Hypothesis: Task #{N} - Cycle {C}

**Phase**: {phase_number}
**Error Type**: {build_error|test_failure|type_error|...}
**Timestamp**: {ISO_DATE}
**Debugger**: {teammate_name}

## Error Output

```
{verbatim error output}
```

## Context

{Relevant code snippets and state}

## Hypothesis

{What the debugger believes is wrong}

### Evidence

1. {Supporting evidence point 1}
2. {Supporting evidence point 2}

### Confidence

{high|medium|low} - {reason for confidence level}

## Proposed Fix

### Location
- File: {file_path}
- Line(s): {line_numbers}

### Change
```
{proposed code change}
```

### Rationale
{Why this fix should work}

## Alternative Hypotheses

{If low confidence, list other possibilities}
```

## Analysis Report Format

```markdown
# Debug Analysis: Task #{N} - Cycle {C}

**Phase**: {phase_number}
**Hypothesis**: {brief hypothesis summary}
**Timestamp**: {ISO_DATE}

## Investigation

### Code Inspection

{What was examined in the code}

### State Analysis

{Runtime state, type information, etc.}

### Dependency Check

{External factors that could contribute}

## Findings

### Root Cause
{Determined root cause}

### Contributing Factors
{Other issues discovered}

## Recommendations

1. {Primary recommendation}
2. {Secondary recommendation if applicable}

## Test Strategy

{How to verify the fix works}
```

## Resolution Report Format

```markdown
# Debug Resolution: Task #{N} - Cycle {C}

**Phase**: {phase_number}
**Outcome**: {fixed|partial|needs_retry|unresolved}
**Timestamp**: {ISO_DATE}
**Fixer**: {teammate_name if applicable}

## Applied Fix

### Files Modified
- `{file_path}`: {change summary}

### Changes Made
```diff
{diff of changes}
```

## Verification

### Tests Run
{What tests/checks were performed}

### Results
{Test outcomes}

## Outcome

### Status
{fixed|partial|needs_retry|unresolved}

### Notes
{Any caveats or follow-up needed}

## Lessons Learned

{What this debugging cycle revealed for future reference}
```

## Cycle Tracking

Each debug cycle increments the cycle number:

| Cycle | Files Created |
|-------|---------------|
| 1 | debug-001-hypothesis.md, debug-001-analysis.md, debug-001-resolution.md |
| 2 | debug-002-hypothesis.md, debug-002-analysis.md, debug-002-resolution.md |
| 3 | debug-003-hypothesis.md, debug-003-analysis.md, debug-003-resolution.md |

**Maximum cycles**: 3 per phase (to prevent infinite loops)

## Resolution Outcomes

| Outcome | Description | Next Action |
|---------|-------------|-------------|
| `fixed` | Error resolved, verification passed | Continue to next phase |
| `partial` | Error reduced but not fully resolved | May retry or proceed with caution |
| `needs_retry` | Fix didn't work, need new hypothesis | Start new cycle |
| `unresolved` | Unable to fix after max cycles | Mark phase [PARTIAL], report to user |

## Usage in Team Implementation

The skill-team-implement spawns:

1. **Debugger teammate**: Creates hypothesis.md
2. **Lead evaluates**: Approves or requests alternative
3. **Fixer teammate**: Attempts fix, creates analysis.md
4. **Lead verifies**: Creates resolution.md with outcome

## Related Files

- `.claude/skills/skill-team-implement/SKILL.md` - Team implementation skill
- `.claude/context/core/patterns/team-orchestration.md` - Wave coordination
- `.claude/context/core/formats/team-metadata-extension.md` - Team metadata
