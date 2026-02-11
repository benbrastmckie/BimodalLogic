---
name: skill-team-plan
description: Orchestrate multi-agent planning with candidate plan generation and trade-off analysis. Spawns 2-3 teammates for parallel plan creation, then synthesizes best-of-breed final plan.
allowed-tools: Task, Bash, Edit, Read, Write
# This skill uses TeammateTool for team coordination (available when CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1)
# Context loaded by lead during synthesis:
#   - .claude/context/core/patterns/team-orchestration.md
#   - .claude/context/core/formats/team-metadata-extension.md
#   - .claude/utils/team-wave-helpers.md
---

# Team Planning Skill

Multi-agent planning with parallel candidate generation. Spawns 2-3 teammates to create alternative implementation plans, then synthesizes a best-of-breed final plan with documented trade-offs.

**IMPORTANT**: This skill requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` environment variable. If team creation fails, gracefully degrades to single-agent planning via skill-planner.

## Context References

Reference (load as needed during synthesis):
- Path: `.claude/context/core/patterns/team-orchestration.md` - Wave coordination patterns
- Path: `.claude/context/core/formats/team-metadata-extension.md` - Team result schema
- Path: `.claude/context/core/formats/return-metadata-file.md` - Base metadata schema
- Path: `.claude/context/core/formats/plan-format.md` - Implementation plan format

## Trigger Conditions

This skill activates when:
- `/plan N --team` is invoked
- Task exists and status allows planning (researched or not_started)
- Team mode is requested via --team flag

## Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `task_number` | integer | Yes | Task to plan |
| `team_size` | integer | No | Number of teammates (2-3, default 2) |

---

## Execution Flow

### Stage 1: Input Validation

Validate required inputs:
- `task_number` - Must exist in state.json
- `team_size` - Clamp to range [2, 3], default 2 (planning benefits less from 4 parallel)
- Status must allow planning

```bash
# Lookup task
task_data=$(jq -r --argjson num "$task_number" \
  '.active_projects[] | select(.project_number == $num)' \
  specs/state.json)

if [ -z "$task_data" ]; then
  return error "Task $task_number not found"
fi

# Extract fields
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')

# Check for research report
research_path="specs/${task_number}_${project_name}/reports/research-001.md"

# Validate team_size (max 3 for planning)
team_size=${team_size:-2}
[ "$team_size" -lt 2 ] && team_size=2
[ "$team_size" -gt 3 ] && team_size=3
```

---

### Stage 2: Load Research Context

Load research findings if available:

```bash
if [ -f "$research_path" ]; then
  research_content=$(cat "$research_path")
else
  research_content="No research report available."
fi
```

---

### Stage 3: Preflight Status Update

Update task status to "planning" BEFORE spawning teammates.

**Update state.json and TODO.md** to `[PLANNING]`.

---

### Stage 4: Create Postflight Marker

```bash
mkdir -p "specs/${task_number}_${project_name}/plans"

cat > "specs/${task_number}_${project_name}/.postflight-pending" << EOF
{
  "session_id": "${session_id}",
  "skill": "skill-team-plan",
  "task_number": ${task_number},
  "operation": "team-plan",
  "team_size": ${team_size}
}
EOF
```

---

### Stage 5: Check Team Mode and Fallback

If `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS != "1"`:
- Log warning
- Invoke skill-planner via Task tool
- Add `degraded_to_single: true` to metadata
- Continue with postflight

---

### Stage 6: Spawn Planning Wave

Create teammate prompts and spawn wave:

**Teammate A - Plan Version A (always)**:
```
Create an implementation plan for task {task_number}: {description}

Research findings:
{research_content}

Create a phased implementation plan focusing on:
- Incremental delivery with verification at each phase
- Clear success criteria for each phase
- Realistic effort estimates

Output to: specs/{N}_{SLUG}/plans/candidate-a.md

Use standard plan format with phases, each containing:
- Objectives
- Files to modify
- Steps
- Verification criteria
```

**Teammate B - Plan Version B (always)**:
```
Create an ALTERNATIVE implementation plan for task {task_number}: {description}

Research findings:
{research_content}

Create a plan that differs from a typical phased approach. Consider:
- Different phase boundaries
- Alternative ordering of work
- Different trade-offs (e.g., speed vs safety, simplicity vs completeness)

Output to: specs/{N}_{SLUG}/plans/candidate-b.md

Clearly document what trade-offs this alternative makes.
```

**Teammate C - Risk/Dependency Analysis (if team_size >= 3)**:
```
Analyze dependencies and risks for implementing task {task_number}: {description}

Research findings:
{research_content}

Focus on:
- Which phases can be parallelized vs must be sequential
- External dependencies and their risks
- Points where the implementation could fail
- Fallback strategies for high-risk phases

Output to: specs/{N}_{SLUG}/plans/risk-analysis.md

Do NOT create a full plan - focus on analysis that informs plan selection.
```

**Spawn teammates using TeammateTool**.

---

### Stage 7: Wait for Wave Completion

Wait with 30-minute timeout for planning wave.

---

### Stage 8: Collect Candidate Plans

Read each teammate's output:

```bash
candidate_a="specs/${task_number}_${project_name}/plans/candidate-a.md"
candidate_b="specs/${task_number}_${project_name}/plans/candidate-b.md"
risk_analysis="specs/${task_number}_${project_name}/plans/risk-analysis.md"

# Parse and store each candidate
```

---

### Stage 9: Trade-off Analysis

Compare candidate plans:

1. **Phase Structure**: Compare number and scope of phases
2. **Effort Estimates**: Compare total effort
3. **Risk Profile**: Which has safer checkpoints?
4. **Parallelization**: Which enables more parallel work?
5. **Dependencies**: Which has fewer blocking dependencies?

Document trade-offs for each approach.

---

### Stage 10: Synthesize Final Plan

Create best-of-breed plan by:

1. Select base structure (usually simpler of the two)
2. Incorporate beneficial elements from alternative
3. Apply risk insights from Teammate C (if present)
4. Add trade-off documentation section
5. Document why this synthesis was chosen

Write to: `specs/{N}_{SLUG}/plans/implementation-001.md`

```markdown
# Implementation Plan: Task #{N}

**Task**: {title}
**Version**: 001
**Mode**: Team Planning ({team_size} teammates)

## Overview

{Synthesized approach description}

## Trade-off Analysis

### Candidate A Summary
{Brief description of approach A}
- Pros: ...
- Cons: ...

### Candidate B Summary
{Brief description of approach B}
- Pros: ...
- Cons: ...

### Synthesis Decision
{Why this synthesis was chosen}

## Phases

[Standard phase format from best-of-breed synthesis]

...
```

---

### Stage 11: Update Status (Postflight)

Update task status to "planned":

**Update state.json and TODO.md** to `[PLANNED]`.

**Link artifact** with summary of synthesis.

---

### Stage 12: Write Metadata File

```json
{
  "status": "planned",
  "summary": "Team planning completed with {N} candidate plans synthesized",
  "artifacts": [
    {
      "type": "plan",
      "path": "specs/{N}_{SLUG}/plans/implementation-001.md",
      "summary": "Best-of-breed plan from {team_size} candidates"
    }
  ],
  "team_execution": {
    "enabled": true,
    "wave_count": 1,
    "teammates_spawned": {team_size},
    "teammates_completed": {completed_count}
  },
  "teammate_results": [
    {
      "name": "PlannerA",
      "angle": "Phased incremental approach",
      "status": "completed",
      "artifact_path": "specs/{N}_{SLUG}/plans/candidate-a.md"
    },
    {
      "name": "PlannerB",
      "angle": "Alternative structure",
      "status": "completed",
      "artifact_path": "specs/{N}_{SLUG}/plans/candidate-b.md"
    }
  ],
  "synthesis": {
    "candidates_compared": {team_size},
    "trade_offs_documented": true,
    "base_plan_source": "PlannerA"
  }
}
```

---

### Stage 13: Git Commit

Commit using targeted staging (prevents race conditions with concurrent agents):

```bash
git add \
  "specs/${task_number}_${project_name}/plans/" \
  "specs/${task_number}_${project_name}/.return-meta.json" \
  "specs/TODO.md" \
  "specs/state.json"
git commit -m "task ${task_number}: create team implementation plan (${team_size} candidates)

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

**Note**: Use targeted staging, NOT `git add -A`. See `.claude/context/core/standards/git-staging-scope.md`.

---

### Stage 14: Cleanup and Return

Remove marker files and return summary:

```
Team planning completed for task {N}:
- Generated {team_size} candidate plans
- Candidate A: Phased incremental (6 phases)
- Candidate B: Alternative ordering (4 phases)
- Trade-off analysis completed
- Synthesized best-of-breed plan at specs/{N}_{SLUG}/plans/implementation-001.md
- Status updated to [PLANNED]
```

---

## Error Handling

### Team Creation Failure
- Fall back to skill-planner
- Mark `degraded_to_single: true`

### Single Candidate Available
- Use available candidate as base
- Note missing comparison in plan
- Mark result as partial

### Synthesis Conflict
- Preserve both candidates
- Document conflict
- Let user choose

---

## Return Format

Brief text summary:

```
Team planning completed for task 412:
- Generated 3 candidate plans
- Candidate A: Phased incremental approach (7 phases, 12 hours)
- Candidate B: Parallel-first approach (5 phases, 10 hours)
- Risk analysis identified 2 high-risk phases
- Synthesized plan uses Candidate A structure with B's parallelization
- Plan at specs/412_task_name/plans/implementation-001.md
- Status updated to [PLANNED]
```
