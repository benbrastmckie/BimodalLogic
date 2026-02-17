# Plan Artifact Standard

**Scope:** All plan artifacts produced by /plan, /revise, /implement (phase planning), /review (when drafting follow-on work), and related agents.

## Metadata (Markdown block, required)
- Use a single **Status** field with status markers (`[NOT STARTED]`, `[IN PROGRESS]`, `[BLOCKED]`, `[ABANDONED]`, `[COMPLETED]`) per status-markers.md.
- Do **not** use YAML front matter. Use a Markdown metadata block at the top of the plan.
- Required fields: Task, Status, Effort, Dependencies, Research Inputs, Artifacts, Standards, Type, Lean Intent.
- Status timestamps belong where transitions happen (e.g., in phases or a short Started/Completed line under the status). Avoid null placeholder fields.
- Standards must reference this file plus status-markers.md, artifact-management.md, and tasks.md.

### Example Metadata Block
```
# Implementation Plan: {title}
- **Task**: {id} - {title}
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-001.md
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: markdown
- **Lean Intent**: false
```

## Plan Metadata Schema

Plans may include a `plan_metadata` object in state.json tracking plan characteristics:

```json
{
  "phases": 5,
  "total_effort_hours": 8,
  "complexity": "medium",
  "research_integrated": true,
  "plan_version": 1,
  "reports_integrated": [
    {
      "path": "reports/research-001.md",
      "integrated_in_plan_version": 1,
      "integrated_date": "2026-01-05"
    }
  ]
}
```

**Field Descriptions**:
- `phases`: Number of implementation phases in plan
- `total_effort_hours`: Total estimated effort across all phases
- `complexity`: Plan complexity (simple, medium, complex)
- `research_integrated`: Boolean indicating if research was incorporated
- `plan_version`: Plan version number (1 for initial, increments with revisions)
- `reports_integrated`: Array tracking which research reports were integrated into which plan versions

**reports_integrated Schema**:
- `path`: Relative path to research report (e.g., "reports/research-001.md")
- `integrated_in_plan_version`: Plan version that integrated this report
- `integrated_date`: Date report was integrated (YYYY-MM-DD format)

**Backward Compatibility**: Plans without `reports_integrated` field use empty array default.

## Structure
1. **Overview** – 2-4 sentences: problem, scope, constraints, definition of done. May include "Research Integration" subsection listing integrated reports.
2. **Goals & Non-Goals** – bullets.
3. **Risks & Mitigations** – bullets.
4. **Sorry Characterization (Lean plans only)** – document sorry handling with framing rules (see below).
5. **Implementation Phases** – under `## Implementation Phases` with each phase at level `###` and including a status marker at the end of the heading.
6. **Testing & Validation** – bullets/tests to run.
7. **Artifacts & Outputs** – enumerate expected outputs with paths.
8. **Rollback/Contingency** – brief plan if changes must be reverted.

## Implementation Phases (format)
- Heading: `### Phase N: {name} [STATUS]`
- Under each phase include:
  - **Dependencies:** `None` | `Phase {N}` | `Phase {N}, Phase {M}` (optional, defaults to None if omitted for backward compatibility)
  - **Goal:** short statement
  - **Tasks:** bullet checklist
  - **Timing:** expected duration or window
  - **Owner:** (optional)
  - **Started/Completed/Blocked/Abandoned:** timestamp lines when status changes (ISO8601). Do not leave null placeholders.
  - **Progress:** (optional) session entries tracking work done (see Progress Subsection below)

### Phase Dependencies Notation

The `Dependencies` field declares which phases must complete before this phase can start. This enables explicit DAG representation for parallel execution.

**Syntax**:
- `None` - Phase can start immediately (no blockers)
- `Phase 1` - Phase blocked until Phase 1 completes
- `Phase 1, Phase 3` - Phase blocked until both Phase 1 and Phase 3 complete

**Examples**:
```
### Phase 1: Setup [NOT STARTED]
- **Dependencies:** None
- **Goal:** Initialize project structure

### Phase 2: Core Implementation [NOT STARTED]
- **Dependencies:** Phase 1
- **Goal:** Implement core functionality

### Phase 3: Documentation [NOT STARTED]
- **Dependencies:** Phase 1
- **Goal:** Write user documentation

### Phase 4: Integration [NOT STARTED]
- **Dependencies:** Phase 2, Phase 3
- **Goal:** Integrate and test everything
```

In this example, Phases 2 and 3 can run in parallel after Phase 1 completes. Phase 4 waits for both.

**Backward Compatibility**: The Dependencies field is optional. Plans without this field treat all phases as having `Dependencies: None` (sequential by default, dependency inferred).

### Progress Subsection

Each phase may include a **Progress:** subsection to track work done across implementation sessions. This provides a canonical record of progress directly in the plan file.

**Format**:
```markdown
**Progress:**

**Session: YYYY-MM-DD, sess_NNNNNN_XXXXXX**
- Added: `lemma_name` - description
- Fixed: `function_name` by adding precondition
- Completed: `objective_name` (was N sorries, now 0)
- Sorries: 18 -> 14 (4 eliminated)

**Session: YYYY-MM-DD, sess_NNNNNN_YYYYYY** (no progress)
- Attempted: approach description
- Result: blocked by issue
- No changes committed
```

**Session Header**: Each session entry includes the date (YYYY-MM-DD) and session_id from delegation context.

**Action Verbs**: Use `Added`, `Fixed`, `Completed`, `Removed`, `Refactored`, `Attempted` for consistency.

**Outcome Tracking**: For Lean tasks, track sorry/axiom delta: `Sorries: N -> M (K eliminated)`.

**No-Progress Sessions**: Document failed attempts to prevent successor retries. Mark with `(no progress)` and include what was attempted and why it failed.

**Placement**: After **Verification:** section (if present), before the horizontal rule separating phases.

**Backward Compatibility**: The Progress subsection is optional. Plans without it remain valid.

See `artifact-formats.md` for full Progress Subsection documentation.

## Sorry Characterization (Lean plans only)

**Applicability**: Include this section only for Lean implementation plans. For non-Lean plans (general, meta, latex, typst), this section should be omitted.

**Purpose**: Documents how the implementation will handle sorries - both pre-existing ones being resolved and any new ones being introduced. Sorries are technical debt that block publication and propagate to dependents.

**Required Elements**:
- **Pre-existing Sorries**: Sorries in scope that this implementation addresses
- **Expected Resolution**: Which sorries will be resolved and how
- **New Sorries**: Any sorries introduced (should be rare and justified)
- **Remaining Debt**: Sorries that will remain after implementation, with remediation timeline

**Framing Rules**:

NEVER use these phrases (they imply sorries can be permanently acceptable):
- "acceptable sorry"
- "acceptable limitation"
- "sorry is fine"
- "okay to have sorry"
- "N acceptable sorries"

ALWAYS use these phrases (they acknowledge temporary technical debt):
- "tolerated during development"
- "technical debt requiring remediation"
- "blocks publication"
- "inherited by dependents"
- "remediation priority: high/medium/low"

**Example**:
```markdown
## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `Completeness.lean` at lines 42, 78 (inherited from prior work)

### Expected Resolution
- Phase 2 resolves line 42 sorry via canonical model construction
- Phase 3 resolves line 78 sorry via truth preservation lemma

### New Sorries
- None expected. If proof complexity requires temporary sorry, will document with remediation timeline.

### Remaining Debt
After this implementation:
- 0 sorries expected in `Completeness.lean`
- Downstream theorems will no longer inherit sorry status
- Publication no longer blocked by these specific sorries
```

## Axiom Characterization (Lean plans only)

**Applicability**: Include this section only for Lean implementation plans that involve axiom dependencies. For non-Lean plans (general, meta, latex, typst), this section should be omitted.

**Purpose**: Documents how the implementation handles axioms - both pre-existing ones being addressed and any impact on axiom dependencies. Axioms are technical debt that require structural proofs for elimination.

**Required Elements**:
- **Pre-existing Axioms**: Axioms in scope that this implementation addresses
- **Expected Resolution**: Which axioms will be eliminated and how (structural proof approach)
- **New Axioms**: NEVER introduce new axioms (if unavoidable, justify with remediation timeline)
- **Remaining Debt**: Axioms that will remain after implementation, with downstream impact

**Framing Rules**:

NEVER use these phrases (they imply axioms can be permanently acceptable):
- "acceptable axiom"
- "axiom-based solution"
- "add axiom to solve"
- "N acceptable axioms"

ALWAYS use these phrases (they acknowledge technical debt requiring structural proof):
- "axiom as technical debt"
- "structural proof eliminates axiom"
- "inherits axiom dependency"
- "zero-axiom target"
- "axiom to be removed via [specific approach]"
- "publication requires axiom disclosure or elimination"

**Example**:
```markdown
## Axiom Characterization

### Pre-existing Axioms
- 1 axiom in `SaturatedConstruction.lean`: `singleFamily_modal_backward_axiom` (construction assumption)

### Expected Resolution
- Phase 3 eliminates axiom via completed saturation construction
- Structural proof approach: extend world state family to include backward-reachable worlds

### New Axioms
- None. NEVER introduce new axioms. If proof complexity requires temporary gap, use sorry with remediation timeline.

### Remaining Debt
After this implementation:
- 0 axioms expected in saturation module
- Downstream theorems will no longer inherit axiom dependency
- Completeness theorem becomes axiom-free (publication-ready without disclosure)
```

## Status Marker Requirements
- Use markers exactly as defined in status-markers.md.
- Every phase starts as `[NOT STARTED]` and progresses through valid transitions.
- Include timestamps when transitions occur; avoid null/empty metadata fields.
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
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview
{summary}

## Goals & Non-Goals
- **Goals**: ...
- **Non-Goals**: ...

## Risks & Mitigations
- Risk: ... Mitigation: ...

## Implementation Phases
### Phase 1: {name} [NOT STARTED]
- **Dependencies:** None
- **Goal:** ...
- **Tasks:**
  - [ ] ...
- **Timing:** ...

### Phase 2: ... [NOT STARTED]
- **Dependencies:** Phase 1
...

## Testing & Validation
- [ ] ...

## Artifacts & Outputs
- plans/implementation-001.md
- summaries/implementation-summary-YYYYMMDD.md

## Rollback/Contingency
- ...
```
