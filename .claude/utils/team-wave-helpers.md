# Team Wave Helpers

Reusable patterns for wave-based team coordination.

## Overview

This file contains reference patterns for implementing team skills. Copy and adapt these patterns rather than importing directly.

## Wave Spawning Pattern

### Spawn Research Wave

Spawn 2-4 teammates for parallel research:

```
# Research Wave Spawning
Wave 1 teammates:
1. Primary Angle (required)
   - Name: "{Task}ResearcherA"
   - Prompt: "Research {task} focusing on implementation approaches.
     Challenge assumptions. Provide specific examples.
     Output to: specs/{N}_{SLUG}/reports/teammate-a-findings.md"

2. Alternative Approaches (required)
   - Name: "{Task}ResearcherB"
   - Prompt: "Research {task} focusing on alternative patterns and prior art.
     Look for existing solutions we could adapt.
     Output to: specs/{N}_{SLUG}/reports/teammate-b-findings.md"

3. Risk Analysis (optional, size >= 3)
   - Name: "{Task}ResearcherC"
   - Prompt: "Research {task} focusing on risks, blockers, and edge cases.
     Identify what could go wrong.
     Output to: specs/{N}_{SLUG}/reports/teammate-c-findings.md"

4. Devil's Advocate (optional, size >= 4)
   - Name: "{Task}ResearcherD"
   - Prompt: "Challenge findings from other teammates.
     Look for gaps, inconsistencies, and missed alternatives.
     Output to: specs/{N}_{SLUG}/reports/teammate-d-findings.md"
```

### Spawn Planning Wave

Spawn teammates for parallel plan generation:

```
# Planning Wave Spawning
Wave 1 teammates:
1. Plan Version A (required)
   - Name: "{Task}PlannerA"
   - Prompt: "Create a phased implementation plan for {task}.
     Focus on incremental delivery with verification at each phase.
     Output to: specs/{N}_{SLUG}/plans/candidate-a.md"

2. Plan Version B (required)
   - Name: "{Task}PlannerB"
   - Prompt: "Create an alternative implementation plan for {task}.
     Consider different phase boundaries or ordering.
     Output to: specs/{N}_{SLUG}/plans/candidate-b.md"

3. Risk/Dependency Analysis (optional, size >= 3)
   - Name: "{Task}PlannerC"
   - Prompt: "Analyze dependencies and risks for implementing {task}.
     Identify which phases can be parallelized vs sequential.
     Output to: specs/{N}_{SLUG}/plans/risk-analysis.md"
```

### Spawn Implementation Wave

Spawn teammates for parallel implementation:

```
# Implementation Wave Spawning
For each independent phase group:
1. Phase Implementer (per independent phase)
   - Name: "{Task}Phase{N}Impl"
   - Prompt: "Implement phase {N} of the plan for {task}.
     Follow the steps in the implementation plan.
     Update phase status markers as you complete."

2. Debugger (spawned on error)
   - Name: "{Task}Debugger"
   - Prompt: "Analyze the error in {task} implementation.
     Error: {error_details}
     Generate hypothesis and create debug report at:
     specs/{N}_{SLUG}/debug/debug-{NNN}-hypothesis.md"
```

## Wait and Collect Pattern

### Wait for Wave Completion

```
# Wait for all teammates in wave
For each teammate in current wave:
  1. Check if teammate has notified completion
  2. If not, wait with timeout (30 min per wave)
  3. On timeout: mark as timed out, continue with available

Collect results:
  1. Read each teammate's output file
  2. Parse status (completed/partial/failed)
  3. Store in teammate_results array
```

### Collect Teammate Results

```bash
# Pattern: Collect results from teammate files
teammate_files=(
  "specs/${N}_${SLUG}/reports/teammate-a-findings.md"
  "specs/${N}_${SLUG}/reports/teammate-b-findings.md"
  # ... add more as needed
)

for file in "${teammate_files[@]}"; do
  if [ -f "$file" ]; then
    # Parse findings from file
    # Add to teammate_results
  else
    # Mark as failed/missing
  fi
done
```

## Synthesis Pattern

### Lead Synthesis Loop

```
# Synthesis procedure
1. Initialize synthesis object
   - conflicts_found: 0
   - conflicts_resolved: 0
   - gaps_identified: 0

2. For each teammate result:
   a. Extract key findings
   b. Compare with other teammates for conflicts
   c. Log any conflicts found

3. Conflict resolution:
   For each conflict:
   a. Evaluate evidence strength
   b. Make judgment call
   c. Document resolution reason
   d. Increment conflicts_resolved

4. Gap analysis:
   a. Check if any expected angle missing
   b. Check for contradictions without resolution
   c. Decide if Wave 2 needed

5. Generate unified output:
   a. Merge non-conflicting findings
   b. Include resolved conflicts with reasoning
   c. Note any remaining gaps
```

### Conflict Detection

```
# Pattern: Detect conflicts between findings
conflicts = []

for each finding_a in teammate_a.findings:
  for each finding_b in teammate_b.findings:
    if contradicts(finding_a, finding_b):
      conflicts.append({
        "teammate_a": "ResearcherA",
        "finding_a": finding_a,
        "teammate_b": "ResearcherB",
        "finding_b": finding_b
      })
```

## Graceful Degradation Pattern

### Fallback to Single Agent

```
# Pattern: Graceful degradation
try:
  spawn_teammates()
except TeamCreationFailed:
  log_warning("Team mode unavailable, falling back to single agent")

  # Execute single-agent version
  result = execute_single_agent_workflow()

  # Mark as degraded in metadata
  result.team_execution = {
    "enabled": true,
    "degraded_to_single": true,
    "degradation_reason": "Teams feature unavailable"
  }

  return result
```

### Partial Teammate Failure

```
# Pattern: Handle partial teammate failure
available_results = []
failed_teammates = []

for teammate in wave:
  if teammate.status == "completed":
    available_results.append(teammate.result)
  else:
    failed_teammates.append(teammate.name)

if len(available_results) >= 1:
  # Synthesize from available
  synthesis = synthesize(available_results)
  synthesis.gaps_identified += len(failed_teammates)
else:
  # All failed, degrade to single
  return fallback_to_single_agent()
```

## Timeout Handling Pattern

```
# Pattern: Wave timeout handling
WAVE_TIMEOUT = 1800  # 30 minutes per wave

start_time = now()
completed = []

while len(completed) < len(wave) and (now() - start_time) < WAVE_TIMEOUT:
  for teammate in wave:
    if teammate.is_complete() and teammate not in completed:
      completed.append(teammate)
  sleep(30)  # Poll every 30 seconds

# After timeout, collect what we have
for teammate in wave:
  if teammate not in completed:
    teammate.status = "timeout"
    log_warning(f"{teammate.name} timed out")
```

## Related Files

- `.claude/context/core/patterns/team-orchestration.md` - Overall coordination
- `.claude/context/core/formats/team-metadata-extension.md` - Result schema
- `.claude/skills/skill-team-*/SKILL.md` - Skill implementations
