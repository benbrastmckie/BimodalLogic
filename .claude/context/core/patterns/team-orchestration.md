# Team Orchestration Patterns

Wave-based multi-agent coordination for Claude Teams integration.

## Overview

Team mode enables parallel execution through Claude Code's Agent Teams feature, spawning multiple teammates to work concurrently on complementary angles of a task.

## Feature Configuration

### Environment Variable

Enable Agent Teams (experimental feature):
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Teammate Display Mode

- **in-process** (default): Works in all terminals, teammates run in background
- **tmux**: Split panes for visual monitoring (requires tmux)

## Wave Architecture

```
Wave 1: Parallel Execution (1-4 teammates)
    ├── Teammate A: Primary angle
    ├── Teammate B: Alternative approach
    ├── Teammate C: Risk analysis
    └── Teammate D: Devil's advocate
         │
         ▼
    Synthesis: Lead aggregates findings
         │
         ▼
Wave 2: Resolution/Deep-dive (1-4 teammates) [optional]
    ├── Teammate E: Investigate gap 1
    └── Teammate F: Investigate gap 2
         │
         ▼
    Final Synthesis
```

## Core Principles

### 1. Lead-as-Synthesizer

The team lead orchestrates work and synthesizes results:
- Spawns teammates with specific prompts
- Waits for all wave results
- Aggregates and resolves conflicts
- Produces unified output

### 2. Wave Sizing

Optimal teammates per wave:
- **Minimum**: 2 (parallel value)
- **Maximum**: 4 (diminishing returns beyond)
- **Default**: 2-3 for most tasks

Configurable via `--team-size N` flag.

### 3. Early Synthesis

Start aggregation as results arrive:
- Reduces total latency 15-24%
- Process completed results while waiting for others
- Final synthesis when all complete

### 4. Claim-Based Task Assignment

Teammates claim tasks from shared list:
- Prevents duplicate work
- Enables dynamic load balancing
- Handles uneven completion times

## TeammateTool Integration

### Spawning Teammates

```
Use TeammateTool to spawn teammates:
- name: "ResearcherA" or "PlannerA"
- prompt: Task-specific instructions
- model: Same as lead (default)
- task_list: Optional shared task list
```

### Teammate Prompts

Prompts should include:
1. Clear objective for this angle
2. What NOT to cover (other teammates handle)
3. Output format expected
4. Deadline/timeout guidance

### Waiting for Results

Wait for teammate completion:
- Teammates notify lead when idle
- Poll task list for completion
- Set reasonable timeouts (30-60 min per wave)

### Result Collection

Collect teammate outputs:
- Read teammate result files
- Parse status (completed, partial, failed)
- Note any conflicts between findings

## Synthesis Protocol

### Conflict Resolution

When teammates disagree:
1. Log the conflict in synthesis
2. Present both perspectives
3. Make judgment call based on evidence
4. Note uncertainty if unresolved

### Gap Identification

During synthesis:
1. Check for missing coverage
2. Identify contradictions
3. Spawn Wave 2 if gaps are significant
4. Document remaining gaps in output

### Distillation Format

```json
{
  "teammate_results": [
    {
      "name": "ResearcherA",
      "angle": "Primary approach",
      "findings": ["..."],
      "confidence": "high",
      "conflicts_with": []
    }
  ],
  "synthesized_result": {
    "key_findings": ["..."],
    "conflicts_resolved": ["..."],
    "gaps_identified": ["..."],
    "recommendation": "..."
  }
}
```

## Graceful Degradation

### Team Creation Failure

If teammate spawning fails:
1. Log warning: "Team mode unavailable, using single agent"
2. Execute standard single-agent workflow
3. Note in output: "Executed in single-agent mode"
4. Return success (degraded gracefully)

### Teammate Failure

If individual teammate fails:
1. Continue with remaining teammates
2. Note gap in synthesis
3. Consider spawning replacement (Wave 2)
4. Mark result as partial if critical gap

### Timeout Handling

If teammate times out:
1. Collect partial results if available
2. Continue synthesis with available data
3. Note timeout in metadata
4. Mark overall result appropriately

## Token Usage

Team mode uses approximately 5x tokens vs single agent:
- Each teammate is a separate Claude instance
- Synthesis adds additional processing
- Use sparingly for complex tasks

## When to Use Team Mode

**Good candidates**:
- Complex research requiring multiple perspectives
- Trade-off analysis needing parallel exploration
- Debugging with hypothesis generation
- Tasks where diverse approaches add value

**Poor candidates**:
- Simple, linear tasks
- Well-defined single-path implementations
- Token-sensitive operations
- Time-critical fast operations

## Related Files

- `.claude/context/core/formats/team-metadata-extension.md` - Result schema
- `.claude/utils/team-wave-helpers.md` - Reusable patterns
- `.claude/skills/skill-team-*/SKILL.md` - Team skill implementations
