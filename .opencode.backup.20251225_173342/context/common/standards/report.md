# Report Artifact Standard

**Scope:** Research, analysis, verification, and review reports produced by /research, /review, /analyze, and related agents.

## Metadata (required)
- **Task**: `{id} - {title}`
- **Status**: `[NOT STARTED]` | `[IN PROGRESS]` | `[BLOCKED]` | `[ABANDONED]` | `[COMPLETED]` (see status-markers.md)
- **Started**: `{ISO8601}` when work begins
- **Completed/Blocked/Abandoned**: `{ISO8601}` as applicable
- **Effort**: `{estimate}`
- **Priority**: `High | Medium | Low`
- **Dependencies**: `{list or None}`
- **Sources/Inputs**: bullet list of inputs consulted
- **Artifacts**: list of produced artifacts (paths)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, this file

## Structure
1. **Executive Summary** – 4-6 bullets.
2. **Context & Scope** – what is being evaluated, constraints.
3. **Findings** – ordered or bulleted list with evidence; include status markers for subsections if phases are tracked.
4. **Decisions** – explicit decisions made.
5. **Recommendations** – prioritized list with owners/next steps.
6. **Risks & Mitigations** – optional but recommended.
7. **Appendix** – references, data, links.

## Status Marker Usage
- Use status markers for overall report status; subsections may omit markers unless phased execution is tracked.
- Include timestamps for each transition.
- Do not use emojis.

## Writing Guidance
- Be objective, cite sources/paths.
- Keep headings at most level 3 inside the report.
- Prefer bullet lists over prose for findings/recommendations.
- Ensure lazy directory creation: create `reports/` only when writing the first report file.

## Example Skeleton
```
# Research Report: {title}
- **Task**: {id} - {title}
- **Status**: [IN PROGRESS]
- **Started**: 2025-12-22T10:00:00Z
- **Effort**: 3 hours
- **Sources/Inputs**: ...

## Executive Summary
- ...

## Context & Scope
...

## Findings
- ...

## Decisions
- ...

## Recommendations
- ...

## Risks & Mitigations
- ...

## Appendix
- References: ...
```
