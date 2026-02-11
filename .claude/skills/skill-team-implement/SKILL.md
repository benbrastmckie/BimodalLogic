---
name: skill-team-implement
description: Orchestrate multi-agent implementation with parallel phase execution and debugging support. Spawns teammates for independent phases and debugger agents for error resolution.
allowed-tools: Task, Bash, Edit, Read, Write
# This skill uses TeammateTool for team coordination (available when CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1)
# Context loaded by lead:
#   - .claude/context/core/patterns/team-orchestration.md
#   - .claude/context/core/formats/team-metadata-extension.md
#   - .claude/context/core/formats/debug-report-format.md
---

# Team Implementation Skill

Multi-agent implementation with parallel phase execution and debugging support. Analyzes plan for independent phases, spawns teammates to execute them in parallel, and deploys debugger agents when errors occur.

**IMPORTANT**: This skill requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` environment variable. If team creation fails, gracefully degrades to single-agent implementation via skill-implementer.

## Context References

Reference (load as needed):
- Path: `.claude/context/core/patterns/team-orchestration.md` - Wave coordination patterns
- Path: `.claude/context/core/formats/team-metadata-extension.md` - Team result schema
- Path: `.claude/context/core/formats/debug-report-format.md` - Debug report format
- Path: `.claude/context/core/formats/return-metadata-file.md` - Base metadata schema

## Trigger Conditions

This skill activates when:
- `/implement N --team` is invoked
- Task exists and has a plan
- Team mode is requested via --team flag

## Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `task_number` | integer | Yes | Task to implement |
| `team_size` | integer | No | Max parallel implementers (1-3, default 2) |

---

## Execution Flow

### Stage 1: Input Validation and Plan Loading

Validate inputs and load implementation plan:

```bash
# Lookup task
task_data=$(jq -r --argjson num "$task_number" \
  '.active_projects[] | select(.project_number == $num)' \
  specs/state.json)

# Extract fields
project_name=$(echo "$task_data" | jq -r '.project_name')
language=$(echo "$task_data" | jq -r '.language // "general"')

# Load plan
plan_path="specs/${task_number}_${project_name}/plans/implementation-001.md"
if [ ! -f "$plan_path" ]; then
  return error "No implementation plan found for task $task_number"
fi

# Parse phases from plan
# Identify phase status markers: [NOT STARTED], [IN PROGRESS], [COMPLETED]
```

---

### Stage 2: Analyze Phase Dependencies

Parse plan to identify parallelizable phases:

1. **Extract all phases** from plan
2. **Identify dependencies** (phases that reference outputs of other phases)
3. **Group independent phases** that can run in parallel
4. **Create execution waves** respecting dependencies

Example grouping:
```
Wave 1: [Phase 1] - must go first (foundational)
Wave 2: [Phase 2, Phase 3] - independent, can parallelize
Wave 3: [Phase 4] - depends on Phase 2 and 3
Wave 4: [Phase 5, Phase 6] - independent cleanup phases
```

---

### Stage 3: Preflight Status Update

Update task status to "implementing":

**Update state.json and TODO.md** to `[IMPLEMENTING]`.

---

### Stage 4: Create Postflight Marker and Debug Directory

```bash
mkdir -p "specs/${task_number}_${project_name}/debug"

cat > "specs/${task_number}_${project_name}/.postflight-pending" << EOF
{
  "session_id": "${session_id}",
  "skill": "skill-team-implement",
  "task_number": ${task_number},
  "operation": "team-implement"
}
EOF
```

---

### Stage 5: Check Team Mode and Fallback

If team mode unavailable, fall back to skill-implementer.

---

### Stage 6: Execute Implementation Waves

For each wave of phases:

**If wave has single phase**:
- Execute directly (no parallelization benefit)
- Mark phase [IN PROGRESS] then [COMPLETED]

**If wave has multiple independent phases**:
- Spawn teammate per phase (up to team_size)
- Wait for all to complete
- Collect results and update plan statuses

**Teammate Prompt (Phase Implementer)**:
```
Implement phase {P} of task {task_number}: {phase_description}

Plan context:
{phase_details}

Files to modify:
{files_list}

Steps:
{steps_list}

Verification:
{verification_criteria}

When complete:
1. Mark phase as [COMPLETED] in plan file
2. Write results to: specs/{N}_{SLUG}/phases/phase-{P}-results.md
3. Return brief summary of changes made
```

---

### Stage 7: Handle Implementation Errors

When a phase fails (build error, test failure, etc.):

**Spawn Debugger Teammate**:
```
Analyze the error in task {task_number} phase {P}:

Error output:
{error_details}

Context:
{phase_context}

Generate:
1. Hypothesis about the cause
2. Analysis of the error
3. Proposed fix

Output to: specs/{N}_{SLUG}/debug/debug-{NNN}-hypothesis.md
```

**Debug Report Cycle**:
1. Debugger generates hypothesis
2. Lead evaluates hypothesis
3. If promising, spawn Fixer teammate
4. Fixer attempts fix
5. Re-run verification
6. If fixed, continue; else, repeat cycle (max 3 attempts)

---

### Stage 8: Write Debug Reports

For each debug cycle, create reports:

```
specs/{N}_{SLUG}/debug/
├── debug-001-hypothesis.md   # Initial hypothesis
├── debug-001-analysis.md     # Detailed analysis
├── debug-001-resolution.md   # How resolved (or not)
├── debug-002-hypothesis.md   # Second attempt (if needed)
└── ...
```

**Debug Report Format**:
```markdown
# Debug Report: Task #{N} Phase {P} - Attempt {A}

**Error**: {brief error description}
**Timestamp**: {ISO_DATE}

## Hypothesis

{What we think is wrong}

## Analysis

{Detailed investigation}

## Proposed Fix

{What to change}

## Resolution

{Outcome: fixed, partial, needs_retry, unresolved}
```

---

### Stage 9: Collect Phase Results

After each wave:
- Read phase result files
- Update plan with completion status
- Track any partial completions
- Decide if subsequent waves can proceed

---

### Stage 10: Create Implementation Summary

Write summary after all phases:

```markdown
# Implementation Summary: Task #{N}

**Completed**: {ISO_DATE}
**Mode**: Team Implementation ({team_size} parallel teammates)

## Execution Summary

| Wave | Phases | Status |
|------|--------|--------|
| 1 | Phase 1 | completed |
| 2 | Phase 2, 3 | completed |
| ... | ... | ... |

## Debug Cycles

{Number of debug cycles required, if any}
{Summary of issues resolved}

## Changes Made

{List of files created/modified}

## Verification

{Verification results}
```

---

### Stage 11: Update Status (Postflight)

Update task status to "completed" (or "partial" if incomplete):

**Update state.json and TODO.md**.

**Link summary artifact**.

---

### Stage 12: Write Metadata File

```json
{
  "status": "implemented",
  "summary": "Team implementation completed",
  "artifacts": [...],
  "team_execution": {
    "enabled": true,
    "wave_count": {N},
    "teammates_spawned": {total},
    "teammates_completed": {completed}
  },
  "teammate_results": [...],
  "debug_cycles": {
    "total_cycles": 2,
    "phases_debugged": ["Phase 3"],
    "resolutions": ["Type error in line 42 fixed"]
  },
  "completion_data": {
    "completion_summary": "...",
    "roadmap_items": []
  }
}
```

---

### Stage 13: Git Commit

Commit using targeted staging (prevents race conditions with concurrent agents):

```bash
# Stage task-specific files plus implementation files based on language
git add \
  "specs/${task_number}_${project_name}/summaries/" \
  "specs/${task_number}_${project_name}/plans/" \
  "specs/${task_number}_${project_name}/phases/" \
  "specs/${task_number}_${project_name}/debug/" \
  "specs/${task_number}_${project_name}/.return-meta.json" \
  "specs/TODO.md" \
  "specs/state.json"
# Also add implementation files (Theories/ for lean, docs/ for latex/typst, .claude/ for meta)
git add "${implementation_files[@]}"

git commit -m "task ${task_number}: complete team implementation

${phases_completed} phases across ${wave_count} waves
${debug_cycles} debug cycles

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

**Note**: Use targeted staging, NOT `git add -A`. See `.claude/context/core/standards/git-staging-scope.md`.

---

### Stage 14: Cleanup and Return

Remove markers and return summary:

```
Team implementation completed for task {N}:
- Executed {phases} phases across {waves} waves
- Parallelized waves 2 and 4 ({parallel_phases} phases each)
- {debug_cycles} debug cycles for error resolution
- All verification criteria passed
- Summary at specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md
- Status updated to [COMPLETED]
```

---

## Error Handling

### Team Creation Failure
- Fall back to skill-implementer (single agent)
- Mark `degraded_to_single: true`

### Phase Execution Failure
- Spawn debugger teammate
- Max 3 debug cycles per phase
- If unresolved after 3 cycles, mark phase [PARTIAL]

### Teammate Timeout
- Mark phase as [PARTIAL]
- Log timeout in debug directory
- Continue with available phases

### Verification Failure
- Treat as phase failure
- Trigger debug cycle
- Mark verification result

---

## Return Format

Brief text summary:

```
Team implementation completed for task 412:
- Executed 6 phases across 4 waves
- Wave 2: Parallelized phases 2-3 (both completed)
- Wave 4: Parallelized phases 5-6 (both completed)
- 1 debug cycle for Phase 3 type error (resolved)
- All verification passed
- Summary at specs/412_task_name/summaries/implementation-summary-20260211.md
- Status updated to [COMPLETED]
```

---

## Debug Wave Details

The debug wave is a special wave that spawns when implementation fails:

### Debugger Role
- Receives error output and context
- Generates hypothesis about cause
- Proposes specific fix
- Does NOT attempt fix directly

### Fixer Role (spawned if hypothesis approved)
- Receives hypothesis and proposed fix
- Implements the fix
- Re-runs verification
- Reports outcome

### Cycle Control
- Max 3 debug cycles per phase
- Each cycle generates numbered debug reports
- Cycles track hypothesis evolution
- Final resolution documented
