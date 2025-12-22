# Plan Artifact Standard

**Scope:** All plan artifacts produced by /plan, /revise, /implement (phase planning), /review (when drafting follow-on work), and related agents.

## Metadata (required)
- **Task**: `{id} - {title}`
- **Status**: `[NOT STARTED]` | `[IN PROGRESS]` | `[BLOCKED]` | `[ABANDONED]` | `[COMPLETED]` (see status-markers.md)
- **Started**: `{ISO8601}` when status first becomes `[IN PROGRESS]`
- **Completed/Blocked/Abandoned**: `{ISO8601}` as applicable
- **Effort**: `{estimate}` (e.g., "3 hours")
- **Priority**: `High | Medium | Low`
- **Dependencies**: `{list or None}` (task numbers or external prerequisites)
- **Research Inputs**: bullet list of linked research artifacts (or `None`)
- **Artifacts**: list of produced/expected artifacts (paths relative to project root)
- **Standards**: reference this file plus status-markers.md, artifact-management.md, tasks.md

## Structure
1. **Overview** – 2-4 sentences: problem, scope, constraints, definition of done.
2. **Goals & Non-Goals** – bullets.
3. **Risks & Mitigations** – bullets.
4. **Implementation Phases** – under `## Implementation Phases` with each phase at level `###` and including a status marker at the end of the heading.
5. **Testing & Validation** – bullets/tests to run.
6. **Artifacts & Outputs** – enumerate expected outputs with paths.
7. **Rollback/Contingency** – brief plan if changes must be reverted.

## Implementation Phases (format)
- Heading: `### Phase N: {name} [STATUS]`
- Under each phase include:
  - **Goal:** short statement
  - **Tasks:** bullet checklist
  - **Timing:** expected duration or window
  - **Owner:** (optional)
  - **Started/Completed/Blocked/Abandoned:** ISO8601 timestamps when status changes

## Status Marker Requirements
- Use markers exactly as defined in status-markers.md.
- Every phase starts as `[NOT STARTED]` and progresses through valid transitions.
- Include timestamps for each transition.
- Do not use emojis in headings or markers.

## Writing Guidance
- Keep phases small (1-2 hours each) per task-breakdown guidelines.
- Be explicit about dependencies and external inputs.
- Include lazy directory creation guardrail: commands/agents create the project root and `plans/` only when writing this artifact; do not pre-create `reports/` or `summaries/`.
- Keep language concise and directive; avoid emojis and informal tone.

## Example Skeleton
```
# Implementation Plan: {title}
- **Task**: {id} - {title}
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-001.md (this file)

## Overview
{summary}

## Goals & Non-Goals
- **Goals**: ...
- **Non-Goals**: ...

## Risks & Mitigations
- Risk: ... Mitigation: ...

## Implementation Phases
### Phase 1: {name} [NOT STARTED]
- **Goal:** ...
- **Tasks:**
  - [ ] ...
- **Timing:** ...

### Phase 2: ... [NOT STARTED]
...

## Testing & Validation
- [ ] ...

## Artifacts & Outputs
- plans/implementation-001.md
- summaries/implementation-summary-YYYYMMDD.md

## Rollback/Contingency
- ...
```
