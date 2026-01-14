# Research Report: Task #414

**Task**: 414 - Create planner-agent subagent with lazy context
**Date**: 2026-01-11
**Focus**: Planner agent patterns, requirements, and integration with skill-planner

## Summary

Researched existing agent patterns and the skill-planner integration requirements. The planner-agent must load plan-format.md and task-breakdown.md on-demand, create phased implementation plans in the standard format, and return structured JSON matching subagent-return.md schema.

## Findings

### Existing Agent Pattern

Five agents exist with consistent structure in `.claude/agents/`:

| Agent | Purpose | Invoked By |
|-------|---------|------------|
| lean-research-agent | Lean 4/Mathlib research | skill-lean-research |
| general-research-agent | General/meta/markdown research | skill-researcher |
| lean-implementation-agent | Lean proof implementation | skill-lean-implementation |
| general-implementation-agent | General file implementation | skill-implementer |
| latex-implementation-agent | LaTeX document implementation | skill-latex-implementation |

**Standard Agent Structure**:
1. Overview section with purpose and invocation context
2. Agent Metadata (name, purpose, invoked by, return format)
3. Allowed Tools section listing available tools
4. Context References with @-references for lazy loading
5. Execution Flow with numbered stages
6. Error Handling section
7. Return Format Examples (completed/partial/failed cases)
8. Critical Requirements (MUST DO / MUST NOT)

### skill-planner Already Exists

Located at `.claude/skills/skill-planner/SKILL.md`:
- Uses `context: fork` pattern
- References `agent: planner-agent` (which doesn't exist yet)
- Documents context files: plan-format.md, task-breakdown.md
- Has full thin-wrapper execution flow

**Key skill-planner expectations**:
- Validates task exists and status allows planning
- Prepares delegation context with task_number, task_name, description, language
- Includes research_path if research report exists
- Expects return matching subagent-return.md

### Context Files to Load On-Demand

**plan-format.md** (`.claude/context/core/formats/plan-format.md`):
- Metadata block: Task, Status, Effort, Priority, Dependencies, Standards, Type, Lean Intent
- Structure: Overview, Goals & Non-Goals, Risks & Mitigations, Implementation Phases, Testing & Validation, Artifacts & Outputs, Rollback/Contingency
- Phase format: `### Phase N: {name} [STATUS]` with Goal, Tasks, Timing
- Status markers from status-markers.md
- Plan metadata schema for state.json integration

**task-breakdown.md** (`.claude/context/core/workflows/task-breakdown.md`):
- When to use: 4+ files, >60 min effort, complex dependencies
- Breakdown process: Scope → Phases → Small Tasks (1-2h) → Dependencies → Estimates
- Best practices: Keep tasks small, make dependencies clear, include verification

### Return Format Requirements

From subagent-return.md, planner-agent must return:

```json
{
  "status": "completed|partial|failed|blocked",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [
    {
      "type": "plan",
      "path": ".claude/specs/{N}_{SLUG}/plans/implementation-{NNN}.md",
      "summary": "Phased implementation plan"
    }
  ],
  "metadata": {
    "session_id": "{from delegation context}",
    "duration_seconds": 123,
    "agent_type": "planner-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "plan", "planner-agent"],
    "phase_count": 3,
    "estimated_hours": 8
  },
  "next_steps": "Run /implement {N} to execute the plan"
}
```

### Allowed Tools for Planner

Based on skill-planner and existing agent patterns:
- **Read** - Read research reports, task descriptions, context files
- **Write** - Create plan artifacts
- **Edit** - Modify existing files if needed
- **Glob** - Find files by pattern (research reports, existing plans)
- **Grep** - Search file contents

No web search tools needed (planning is local operation).

### Integration Points

1. **Input**: Delegation context from skill-planner with:
   - task_context (task_number, task_name, description, language)
   - metadata (session_id, delegation_depth, delegation_path)
   - research_path (optional)

2. **Output**: Structured JSON + plan file in `.claude/specs/{N}_{SLUG}/plans/`

3. **Dependencies**: Depends on task 410 (remove eager context loading) per state.json

## Recommendations

### Agent Structure

Create `.claude/agents/planner-agent.md` following the established pattern:

1. **Overview**: Planning agent for creating implementation plans from task descriptions and research
2. **Metadata**: name, purpose, invoked by skill-planner, return format reference
3. **Allowed Tools**: Read, Write, Edit, Glob, Grep (no Bash needed for planning)
4. **Context References**:
   - Always load: subagent-return.md
   - Load for planning: plan-format.md, task-breakdown.md
5. **Execution Flow**:
   - Stage 1: Parse delegation context
   - Stage 2: Load research report (if exists)
   - Stage 3: Analyze task scope and complexity
   - Stage 4: Decompose into phases using task-breakdown guidelines
   - Stage 5: Create plan file following plan-format.md
   - Stage 6: Return structured JSON
6. **Error Handling**: Invalid task, missing research, timeout scenarios
7. **Return Format Examples**: Completed, partial, failed cases

### Key Execution Logic

The planner should:
1. Read task description and any research report
2. Determine complexity (simple/medium/complex)
3. Apply task-breakdown.md guidelines for >60 min tasks
4. Create phases with:
   - Clear goals
   - Task checklists
   - Time estimates (1-2 hours per phase max)
   - Dependencies between phases
   - Verification criteria
5. Include risks and mitigations based on task nature
6. Write plan file with proper metadata and structure

### Testing Strategy

After implementation, verify:
1. Agent creates valid plan files matching plan-format.md
2. Returns valid JSON matching subagent-return.md
3. Integrates correctly with skill-planner
4. Handles missing research gracefully
5. Creates appropriate phase granularity

## References

- `.claude/agents/general-research-agent.md` - Reference agent pattern
- `.claude/agents/general-implementation-agent.md` - Reference implementation agent
- `.claude/skills/skill-planner/SKILL.md` - Integration target
- `.claude/context/core/formats/plan-format.md` - Plan artifact standard
- `.claude/context/core/formats/subagent-return.md` - Return format schema
- `.claude/context/core/workflows/task-breakdown.md` - Task decomposition guide
- `.claude/context/core/templates/thin-wrapper-skill.md` - Skill-agent pattern

## Next Steps

1. Run `/plan 414` to create implementation plan
2. Implementation should create `.claude/agents/planner-agent.md`
3. Test integration with skill-planner via `/plan {some_task}`
