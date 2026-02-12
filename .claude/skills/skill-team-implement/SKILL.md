---
name: skill-team-implement
description: Orchestrate multi-agent implementation with parallel phase execution and debugging support. Spawns teammates for independent phases and debugger agents for error resolution. Routes to language-appropriate agents (e.g., Lean tasks use lean-implementation-agent pattern with lean-lsp MCP tools).
allowed-tools: Task, Bash, Edit, Read, Write
# This skill uses TeammateTool for team coordination (available when CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1)
# Context loaded by lead:
#   - .claude/context/core/patterns/team-orchestration.md
#   - .claude/context/core/formats/team-metadata-extension.md
#   - .claude/context/core/formats/debug-report-format.md
# Language routing patterns:
#   - .claude/utils/team-wave-helpers.md#language-routing-pattern
---

# Team Implementation Skill

Multi-agent implementation with parallel phase execution and debugging support. Analyzes plan for independent phases, spawns teammates to execute them in parallel, and deploys debugger agents when errors occur.

**Language-Aware Routing**: Phase implementers and debuggers are spawned with language-appropriate prompts and tools. For Lean tasks, teammates use lean-implementation-agent patterns with access to lean-lsp MCP tools, blocked tool warnings, and `lake build` verification requirements.

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

Parse plan to build execution waves from explicit Dependencies field:

#### Step 1: Parse Dependencies Field

For each phase in the plan:
1. Extract `- **Dependencies**:` line value
2. Parse format: `None` | `Phase N` | `Phase N, Phase M`
3. Convert to list of phase numbers (empty list for `None`)

**Parsing logic**:
```
IF value == "None":
    dependencies = []
ELSE:
    # Extract phase numbers from "Phase N, Phase M" format
    dependencies = regex_findall(value, r'Phase\s+(\d+)')
    dependencies = [int(n) for n in dependencies]
```

If ANY phase is missing the Dependencies field, enter backward compatibility mode (see below).

#### Step 2: Build Dependency Graph

Create adjacency list from parsed dependencies:
- Key: phase number
- Value: list of phase numbers this phase depends on

Example:
```
Phase 1: []           # No dependencies
Phase 2: [1]          # Depends on Phase 1
Phase 3: [1]          # Depends on Phase 1
Phase 4: [2, 3]       # Depends on Phase 2 and 3
```

#### Step 3: Compute Execution Waves

Use topological sort to group phases by execution order:
1. Find phases with all dependencies completed -> Wave N
2. Mark those phases as completed
3. Repeat until all phases assigned to waves

**Algorithm**:
```
waves = []
remaining = all_phases
completed = {}

WHILE remaining not empty:
    ready = [p for p in remaining if all deps in completed]
    IF ready is empty:
        # Circular dependency detected - fall back to sequential
        RETURN fallback_to_sequential()
    waves.append(sorted(ready))
    completed.update(ready)
    remaining -= ready

RETURN waves
```

**Output example** (from graph above):
```
Wave 1: [Phase 1] - no dependencies
Wave 2: [Phase 2, Phase 3] - both depend only on Phase 1 (parallel)
Wave 3: [Phase 4] - depends on Phase 2 and 3 (waits for both)
```

#### Backward Compatibility Mode

If the Dependencies field is missing from ANY phase in the plan:

1. **Log**: "Using sequential execution (backward compat mode)"
2. **Create sequential waves**: Each phase executes in its own wave
   ```
   [[1], [2], [3], [4], ...]  # No parallelization
   ```
3. **Rationale**: Plans created before the Dependencies field was introduced should continue to work correctly with predictable sequential execution

This ensures old plans without the Dependencies field work unchanged.

#### Error Handling

**Circular Dependencies**:
- Detected when topological sort cannot make progress (no phase has all deps completed)
- Recovery: Log error "Circular dependency detected", fall back to sequential execution
- Report in metadata: `circular_dependency_detected: true`

**Invalid Phase References**:
- When `Phase N` references a non-existent phase number
- Recovery: Log warning, skip invalid reference, continue with valid dependencies
- Example: `Dependencies: Phase 1, Phase 99` with only 4 phases -> treat as `Dependencies: Phase 1`

**Malformed Dependencies Field**:
- When field exists but has unparseable format (e.g., `Dependencies: depends on first phase`)
- Recovery: Log warning with malformed value, treat that phase as having no dependencies
- Continue with wave computation

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

### Stage 5a: Language Routing Decision

Determine language-specific configuration for phase implementer and debugger prompts:

```bash
# Route by task language
case "$language" in
  "lean")
    # Lean-specific configuration
    use_lean_prompts=true
    implementation_agent_pattern="lean-implementation-agent"
    default_model="opus"
    context_refs="@.claude/context/project/lean4/tools/mcp-tools-guide.md, @.claude/context/project/lean4/patterns/tactic-patterns.md, @.claude/context/project/lean4/standards/proof-debt-policy.md"
    blocked_tools="lean_diagnostic_messages (lean-lsp-mcp #115), lean_file_outline (unreliable)"
    implementation_tools="lean_goal (MOST IMPORTANT), lean_multi_attempt, lean_state_search, lean_hover_info, lean_local_search"
    verification_command="lake build"
    ;;
  "latex")
    use_lean_prompts=false
    implementation_agent_pattern="latex-implementation-agent"
    default_model="sonnet"
    verification_command="pdflatex"
    ;;
  "typst")
    use_lean_prompts=false
    implementation_agent_pattern="typst-implementation-agent"
    default_model="sonnet"
    verification_command="typst compile"
    ;;
  "meta")
    use_lean_prompts=false
    implementation_agent_pattern="general-implementation-agent"
    default_model="sonnet"
    verification_command="File creation and consistency checks"
    ;;
  *)
    # Generic configuration - inherit lead's model
    use_lean_prompts=false
    implementation_agent_pattern="general-implementation-agent"
    default_model="inherit"
    verification_command="Project-specific build/test"
    ;;
esac

# Prepare model preference line for prompts
if [ "$default_model" = "inherit" ]; then
  model_preference_line=""
else
  model_preference_line="Model preference: Use Claude ${default_model^} for this task."
fi
```

See `.claude/utils/team-wave-helpers.md#language-routing-pattern` for full configuration lookup.

---

### Stage 6: Execute Implementation Waves

Execute waves computed in Stage 2 (from Dependencies field analysis or sequential fallback).

For each wave of phases:

**If wave has single phase**:
- Execute directly (no parallelization benefit)
- Mark phase [IN PROGRESS] then [COMPLETED]

**If wave has multiple independent phases**:
- Spawn teammate per phase (up to team_size)
- Use language-appropriate prompts (see Stage 5a)
- Wait for all to complete
- Collect results and update plan statuses

---

#### For Lean Tasks (language == "lean")

Use the Lean teammate prompt template from `.claude/utils/team-wave-helpers.md#lean-teammate-prompt-template-implementation`.

**Teammate Prompt (Lean Phase Implementer)**:
```
Implement phase {P} of task {task_number}: {phase_description}

{model_preference_line}

You are a Lean 4 proof implementer. Follow the lean-implementation-agent pattern.

## Available MCP Tools (via lean-lsp server)
- lean_goal: Check proof state (MOST IMPORTANT - use constantly!)
- lean_multi_attempt: Try multiple tactics without editing file
- lean_state_search: Find lemmas to close current goal (3 req/30s)
- lean_hammer_premise: Premise suggestions for simp/aesop (3 req/30s)
- lean_hover_info: Type signatures and documentation
- lean_local_search: Verify lemma existence

## BLOCKED TOOLS - NEVER CALL
- lean_diagnostic_messages: Bug lean-lsp-mcp #115 - hangs after import edits
- lean_file_outline: Unreliable output

## Workflow
1. Read plan phase details
2. Use lean_goal before and after each tactic
3. Use lean_multi_attempt to explore tactic options
4. Verify lemmas exist with lean_local_search
5. Run lake build for verification

## Context References (load as needed)
- @.claude/context/project/lean4/tools/mcp-tools-guide.md
- @.claude/context/project/lean4/patterns/tactic-patterns.md
- @.claude/context/project/lean4/standards/proof-debt-policy.md

Plan context:
{phase_details}

Files to modify:
{files_list}

Steps:
{steps_list}

Verification: lake build (must pass with no errors)

When complete:
1. Verify proof state shows "no goals"
2. Run lake build
3. Mark phase [COMPLETED] in plan file
4. Write results to: specs/{N}_{SLUG}/phases/phase-{P}-results.md
5. Return brief summary of changes made
```

---

#### For Non-Lean Tasks (general, meta, latex, typst)

Use generic prompts (existing behavior preserved).

**Teammate Prompt (Generic Phase Implementer)**:
```
Implement phase {P} of task {task_number}: {phase_description}

{model_preference_line}

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

#### For Lean Tasks (language == "lean")

Use the Lean debugger prompt template from `.claude/utils/team-wave-helpers.md#lean-teammate-prompt-template-debugger`.

**Spawn Lean Debugger Teammate**:
```
Analyze the error in task {task_number} phase {P}:

{model_preference_line}

You are a Lean 4 debugging specialist.

## Available MCP Tools
- lean_goal: Check proof state at error location (MOST IMPORTANT)
- lean_hover_info: Get type information for identifiers
- lean_local_search: Verify if expected lemmas exist

## BLOCKED TOOLS - NEVER CALL
- lean_diagnostic_messages: Bug lean-lsp-mcp #115 - hangs after import edits
- lean_file_outline: Unreliable output

Error output:
{error_details}

Context:
{phase_context}

Generate:
1. Hypothesis about the cause (use lean_goal to check state)
2. Analysis of the error
3. Proposed fix with specific tactic suggestions

Output to: specs/{N}_{SLUG}/debug/debug-{NNN}-hypothesis.md
```

---

#### For Non-Lean Tasks (general, meta, latex, typst)

Use generic debugger prompts (existing behavior preserved).

**Spawn Generic Debugger Teammate**:
```
Analyze the error in task {task_number} phase {P}:

{model_preference_line}

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

---

**Debug Report Cycle**:
1. Debugger generates hypothesis
2. Lead evaluates hypothesis
3. If promising, spawn Fixer teammate (with language-appropriate prompt)
4. Fixer attempts fix
5. Re-run verification (lake build for Lean, project-specific for others)
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
