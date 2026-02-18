# Implementation Plan: Task #895 (Version 002)

- **Task**: 895 - Update phase status markers during implementation
- **Status**: [IMPLEMENTING]
- **Version**: 002 (revised based on research-002.md findings)
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/895_update_phase_status_markers_during_implementation/reports/research-001.md (initial)
  - specs/895_update_phase_status_markers_during_implementation/reports/research-002.md (corrective)
- **Type**: meta
- **Lean Intent**: false

## Revision Summary

**What changed from v001 to v002:**

| Aspect | v001 (Incorrect) | v002 (Corrected) |
|--------|------------------|------------------|
| Core assumption | "Agents already mark `[IN PROGRESS]` before work" | "Agents have natural language instructions but NO concrete Edit examples" |
| Gap identified | "Error paths don't explicitly handle `[PARTIAL]/[BLOCKED]`" | "ALL paths lack executable Edit patterns - including happy path" |
| Focus | Enhance existing status updates | Add concrete Edit tool invocation examples |

## Overview

Research-002.md discovered that agent definitions describe phase status updates in natural language prose (e.g., "Edit plan file: Change phase status to `[IN PROGRESS]`") but provide **no executable Edit tool patterns**. This is why phases go directly from `[NOT STARTED]` to `[PARTIAL]` without the intermediate `[IN PROGRESS]` state.

The fix is to add **concrete Edit tool invocation examples** to agent definitions, not just descriptive text.

## Goals & Non-Goals

**Goals**:
- Add explicit Edit tool examples for `[NOT STARTED]` -> `[IN PROGRESS]` transition
- Add explicit Edit tool examples for `[IN PROGRESS]` -> `[COMPLETED]` transition
- Add explicit Edit tool examples for error paths (`[PARTIAL]`, `[BLOCKED]`)
- Document a strategy for matching phase names in Edit operations
- Update artifact-formats.md with status decision criteria

**Non-Goals**:
- Change terminology (`[IN PROGRESS]` remains correct for phases)
- Modify skill sed commands (they correctly update plan HEADER status)
- Add new status markers

## Implementation Phases

### Phase 1: Update general-implementation-agent.md with concrete Edit examples [COMPLETED]

- **Dependencies:** None
- **Goal:** Add executable Edit tool patterns for phase status updates in Stage 4

**Specific Changes:**

1. **Stage 4A "Mark Phase In Progress"** - Replace prose with concrete example:

   Current (prose only):
   ```markdown
   **A. Mark Phase In Progress**
   Edit plan file: Change phase status to `[IN PROGRESS]`
   ```

   New (with concrete Edit pattern):
   ```markdown
   **A. Mark Phase In Progress**

   Before starting work on a phase, update its status marker:

   1. Read the plan file to get exact phase header text
   2. Use Edit tool to update status:

   ```
   Edit:
     file_path: specs/{N}_{SLUG}/plans/implementation-{NNN}.md
     old_string: "### Phase {P}: {exact_phase_name} [NOT STARTED]"
     new_string: "### Phase {P}: {exact_phase_name} [IN PROGRESS]"
   ```

   **Important**: Match the exact phase name from the plan file, including any punctuation.
   ```

2. **Stage 4D "Mark Phase Complete"** - Add concrete Edit pattern:
   ```markdown
   **D. Mark Phase Complete**

   After all steps succeed and verification passes:

   ```
   Edit:
     file_path: specs/{N}_{SLUG}/plans/implementation-{NNN}.md
     old_string: "### Phase {P}: {exact_phase_name} [IN PROGRESS]"
     new_string: "### Phase {P}: {exact_phase_name} [COMPLETED]"
   ```
   ```

3. **Add Stage 4 error handling with status patterns**:
   ```markdown
   **On step failure or verification failure:**

   Determine terminal status:
   - `[PARTIAL]`: Some progress made, work can resume later
   - `[BLOCKED]`: Cannot proceed without external change (dependency, bug in codebase, mathematical obstruction)

   Update phase status:
   ```
   Edit:
     file_path: specs/{N}_{SLUG}/plans/implementation-{NNN}.md
     old_string: "### Phase {P}: {exact_phase_name} [IN PROGRESS]"
     new_string: "### Phase {P}: {exact_phase_name} [PARTIAL]"
   ```

   Then proceed to Stage 4E (Progress Subsection) before returning.
   ```

**Timing**: 45 minutes

**Files to modify**:
- `.claude/agents/general-implementation-agent.md`

**Verification**:
- Stage 4A has explicit Edit tool example
- Stage 4D has explicit Edit tool example
- Error paths have explicit Edit tool examples with status decision criteria

---

### Phase 2: Update lean-implementation-flow.md with same patterns [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Apply identical concrete Edit patterns to Lean implementation flow

**Specific Changes:**

Mirror the patterns from Phase 1:
1. Stage 4A - Add Edit example for `[NOT STARTED]` -> `[IN PROGRESS]`
2. Stage 4D - Add Edit example for `[IN PROGRESS]` -> `[COMPLETED]`
3. Error paths - Add Edit examples for `[PARTIAL]` and `[BLOCKED]`

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/lean4/agents/lean-implementation-flow.md`

**Verification**:
- All phase status transitions have explicit Edit tool examples
- Patterns match general-implementation-agent.md

---

### Phase 3: Update other implementation agents [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Apply same patterns to latex and typst implementation agents

**Files to modify**:
- `.claude/agents/latex-implementation-agent.md` (if Stage 4 exists)
- `.claude/agents/typst-implementation-agent.md` (if Stage 4 exists)

**Timing**: 15 minutes

**Verification**:
- All implementation agents have consistent phase status patterns

---

### Phase 4: Update artifact-formats.md with status decision tree [COMPLETED]

- **Dependencies:** None (can run in parallel)
- **Goal:** Document when each terminal phase status should be used

**Specific Changes:**

Add after "Phase Status Markers" section:

```markdown
## Phase Status Decision Tree

When transitioning a phase to a terminal status, use these criteria:

### [COMPLETED]
Use when:
- All steps in the phase executed successfully
- Verification criteria passed
- No sorries/axioms introduced (Lean tasks)
- Changes committed

### [PARTIAL]
Use when:
- Some steps completed but not all
- Work can be resumed by another agent
- Progress was made but interrupted (timeout, context limit)
- Verification failed but changes are salvageable

### [BLOCKED]
Use when:
- Cannot proceed without external change
- Dependency on another task not yet complete
- Bug discovered in upstream code
- Mathematical obstruction (theorem unprovable as stated)
- Requires user input or decision

**Decision Flow:**
1. Did all steps succeed? → Yes → [COMPLETED]
2. Was any progress made? → Yes → [PARTIAL]
3. Is there an external blocker? → Yes → [BLOCKED]
4. Otherwise → [PARTIAL]
```

**Timing**: 15 minutes

**Files to modify**:
- `.claude/rules/artifact-formats.md`

**Verification**:
- Decision tree is clear and actionable
- Each status has documented criteria

---

### Phase 5: Verification and testing [COMPLETED]

- **Dependencies:** Phases 1-4
- **Goal:** Verify all changes are consistent

**Tasks**:
- [ ] Read all modified files and verify consistent Edit patterns
- [ ] Verify terminology is `[IN PROGRESS]` throughout (not `[IMPLEMENTING]`)
- [ ] Check cross-references are accurate
- [ ] Run a test implementation to verify phase status updates work

**Timing**: 15 minutes

**Verification**:
- All agents use identical Edit patterns
- Status decision tree matches agent documentation

## Key Insight from Research-002

The skills already correctly update the plan **header** status via sed:
```bash
sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [PARTIAL]/" "$plan_file"
```

This matches `- **Status**: [...]` (the header line).

Agents need to update **phase markers** which have a different format:
```markdown
### Phase 1: Phase Name [STATUS]
```

The Edit tool old_string must match this exact format including the phase number, name, and current status.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Edit pattern doesn't match exact text | H | Document need to read plan file first to get exact phase name |
| Breaking existing implementations | L | Changes are additive instructions; no code execution changes |
| Agents ignore new patterns | M | Make patterns prominent and provide concrete examples |

## Artifacts & Outputs

- `.claude/agents/general-implementation-agent.md` (modified)
- `.claude/context/project/lean4/agents/lean-implementation-flow.md` (modified)
- `.claude/agents/latex-implementation-agent.md` (modified if applicable)
- `.claude/agents/typst-implementation-agent.md` (modified if applicable)
- `.claude/rules/artifact-formats.md` (modified)
- `specs/895_update_phase_status_markers_during_implementation/summaries/implementation-summary-{DATE}.md` (created)
