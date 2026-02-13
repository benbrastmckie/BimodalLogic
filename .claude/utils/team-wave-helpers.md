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

## Language Routing Pattern

Team skills route teammates to language-appropriate agents based on the task's `language` field. This ensures teammates have access to specialized tools and follow domain-specific patterns.

### Language Routing Lookup

```
# Pattern: Route by task language
language_config = {
  "lean": {
    "research_agent": "lean-research-agent",
    "implementation_agent": "lean-implementation-agent",
    "default_model": "opus",
    "context_references": [
      "@.claude/context/project/lean4/tools/mcp-tools-guide.md",
      "@.claude/context/project/lean4/patterns/tactic-patterns.md",
      "@.claude/context/project/lean4/standards/proof-debt-policy.md"
    ],
    "blocked_tools": [
      "lean_diagnostic_messages (lean-lsp-mcp #115) - use lean_goal or lake build instead",
      "lean_file_outline (unreliable) - use Read + lean_hover_info instead"
    ],
    "research_tools": [
      "lean_leansearch (natural language search, 3 req/30s)",
      "lean_loogle (type pattern search, 3 req/30s)",
      "lean_leanfinder (semantic search, 10 req/30s)",
      "lean_local_search (fast local search, no limit)",
      "lean_hover_info (type signatures)"
    ],
    "implementation_tools": [
      "lean_goal (MOST IMPORTANT - check proof state constantly)",
      "lean_multi_attempt (try tactics without editing)",
      "lean_state_search (find lemmas to close goal)",
      "lean_hover_info (type signatures)",
      "lean_local_search (verify lemma existence)",
      "lake build (verification)"
    ],
    "verification": "lake build (must pass with no errors)"
  },
  "latex": {
    "research_agent": "general-research-agent",
    "implementation_agent": "latex-implementation-agent",
    "default_model": "sonnet",
    "context_references": [],
    "blocked_tools": [],
    "research_tools": ["WebSearch", "WebFetch", "Read"],
    "implementation_tools": ["Read", "Write", "Edit", "Bash (pdflatex)"],
    "verification": "pdflatex compilation"
  },
  "typst": {
    "research_agent": "general-research-agent",
    "implementation_agent": "typst-implementation-agent",
    "default_model": "sonnet",
    "context_references": [],
    "blocked_tools": [],
    "research_tools": ["WebSearch", "WebFetch", "Read"],
    "implementation_tools": ["Read", "Write", "Edit", "Bash (typst compile)"],
    "verification": "typst compile"
  },
  "general": {
    "research_agent": "general-research-agent",
    "implementation_agent": "general-implementation-agent",
    "default_model": "inherit",
    "context_references": [],
    "blocked_tools": [],
    "research_tools": ["WebSearch", "WebFetch", "Read"],
    "implementation_tools": ["Read", "Write", "Edit", "Bash"],
    "verification": "Project-specific build/test commands"
  },
  "meta": {
    "research_agent": "general-research-agent",
    "implementation_agent": "general-implementation-agent",
    "default_model": "sonnet",
    "context_references": [
      "@.claude/CLAUDE.md",
      "@.claude/context/index.md"
    ],
    "blocked_tools": [],
    "research_tools": ["Read", "Grep", "Glob"],
    "implementation_tools": ["Write", "Edit"],
    "verification": "File creation and consistency checks"
  }
}

# Model Selection Rationale
#
# default_model specifies the preferred Claude model for teammates:
# - "opus": Most capable model, recommended for complex theorem proving (Lean)
# - "sonnet": Balanced model, good for document generation and system tasks
# - "inherit": Use the lead agent's model (no override)
#
# Rationale:
# - lean: Opus provides superior mathematical reasoning for theorem proving
# - latex/typst: Sonnet handles document generation well, more cost-effective
# - meta: Sonnet handles system configuration tasks efficiently
# - general: Inherit allows flexibility, lead determines appropriate model
```

### Lean Teammate Prompt Template (Research)

Use this template for Lean research teammates:

```
Research task {task_number}: {description}

You are a Lean 4/Mathlib research specialist. Follow the lean-research-agent pattern.

## Available MCP Tools (via lean-lsp server)
- lean_leansearch: Natural language search (3 req/30s)
- lean_loogle: Type pattern search (3 req/30s)
- lean_leanfinder: Semantic/conceptual search (10 req/30s)
- lean_local_search: Fast local search (no limit) - USE FIRST
- lean_hover_info: Type signatures and documentation

## BLOCKED TOOLS - NEVER CALL
- lean_diagnostic_messages: Bug lean-lsp-mcp #115 - hangs after import edits
- lean_file_outline: Unreliable output

## Search Decision Tree
1. "Does X exist locally?" -> lean_local_search
2. "I need a lemma that says X" -> lean_leansearch
3. "Find lemma with type pattern" -> lean_loogle
4. "What's the Lean name for concept X?" -> lean_leanfinder

## Context References (load as needed)
- @.claude/context/project/lean4/tools/mcp-tools-guide.md
- @.claude/context/project/lean4/standards/proof-debt-policy.md

Focus on: {focus_area}

Output your findings to: specs/{N}_{SLUG}/reports/teammate-{letter}-findings.md

Format: Markdown with sections for Key Findings, Recommended Approach, Evidence (including lemma names verified via lean_local_search), Confidence Level
```

### Lean Teammate Prompt Template (Implementation)

Use this template for Lean implementation teammates:

```
Implement phase {P} of task {task_number}: {phase_description}

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

Verification: lake build (must pass with no errors)

When complete:
1. Verify proof state shows "no goals"
2. Run lake build
3. Mark phase [COMPLETED] in plan file
4. Write results to: specs/{N}_{SLUG}/phases/phase-{P}-results.md
```

### Lean Teammate Prompt Template (Debugger)

Use this template for Lean debugging teammates:

```
Analyze the error in task {task_number} phase {P}:

You are a Lean 4 debugging specialist.

## Available MCP Tools
- lean_goal: Check proof state at error location
- lean_hover_info: Get type information for identifiers
- lean_local_search: Verify if expected lemmas exist

## BLOCKED TOOLS - NEVER CALL
- lean_diagnostic_messages: Bug lean-lsp-mcp #115
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

### Lean Teammate Prompt Template (Planning)

Use this template for Lean planning teammates:

```
Create an implementation plan for task {task_number}: {description}

This is a Lean 4 theorem proving task.

## Context References (load as needed)
- @.claude/context/project/lean4/patterns/tactic-patterns.md
- @.claude/context/project/lean4/standards/proof-debt-policy.md

Research findings:
{research_content}

## Planning Guidelines for Lean Tasks
- Phases should correspond to proof milestones (e.g., helper lemmas, main theorem)
- Each phase should produce a verifiable result (lake build passes)
- Consider proof structure: auxiliary lemmas before main theorems
- Note which proofs can be parallelized (independent theorems)
- Include tactic strategy hints in phase descriptions

## Verification
Each phase must include: "Run lake build and verify no errors"

Output to: specs/{N}_{SLUG}/plans/candidate-{letter}.md
```

## Successor Teammate Pattern

When a teammate exhausts context and writes a handoff, the lead spawns a successor teammate with minimal context. The successor reads the handoff document, NOT the full history.

### When to Spawn Successor vs New Wave

| Situation | Response |
|-----------|----------|
| Teammate returns `partial` with `handoff_path` | Spawn successor teammate |
| Teammate returns `partial` without handoff (timeout) | Mark phase [PARTIAL], continue |
| Teammate returns `failed` | Evaluate, possibly spawn debugger |
| All teammates in wave complete | Start next wave |

### Successor Prompt Template (Lean)

```
## Successor Teammate for Phase {P} (Task {N})

You are continuing work started by a previous teammate who exhausted context.
{model_preference_line}

### Quick Start (read ONLY this first)

**Immediate Next Action**:
{contents from handoff Immediate Next Action section}

**Current State**:
{contents from handoff Current State section}

### If You Get Stuck
Read the full handoff at: {handoff_path}

### Do NOT
- Re-read files already processed by predecessor (listed in handoff)
- Try approaches listed in "What NOT to Try" (already failed)
- Read full research reports or plans unless stuck

### Progress File
Update: `specs/{N}_{SLUG}/progress/phase-{P}-progress.json`
(Increment handoff_count when you start)

### Tools Available
You are a Lean 4 proof implementer with access to:
- lean_goal (MOST IMPORTANT - check proof state constantly)
- lean_multi_attempt (try tactics without editing)
- lean_state_search (find lemmas to close goal)
- lean_hover_info (type signatures)

## BLOCKED TOOLS - NEVER CALL
- lean_diagnostic_messages (bug lean-lsp-mcp #115)
- lean_file_outline (unreliable)

### Verification
Run `lake build` before returning implemented status.

### Context Management
You also have a finite context. If approaching limit:
1. Write your own handoff document
2. Return partial with handoff_path
3. Another successor will continue
```

### Successor Prompt Template (General)

```
## Successor Teammate for Phase {P} (Task {N})

You are continuing work started by a previous teammate who exhausted context.
{model_preference_line}

### Quick Start (read ONLY this first)

**Immediate Next Action**:
{contents from handoff Immediate Next Action section}

**Current State**:
{contents from handoff Current State section}

### If You Get Stuck
Read the full handoff at: {handoff_path}

### Do NOT
- Re-read files already processed by predecessor (listed in handoff)
- Try approaches listed in "What NOT to Try" (already failed)
- Read full research reports or plans unless stuck

### Progress File
Update: `specs/{N}_{SLUG}/progress/phase-{P}-progress.json`
(Increment handoff_count when you start)

### Context Management
You also have a finite context. If approaching limit:
1. Write your own handoff document
2. Return partial with handoff_path
3. Another successor will continue
```

### Key Principles

1. **Minimal Context Start**: Successor reads only Immediate Next Action + Current State initially
2. **Progressive Disclosure**: Full handoff is escape hatch, not starting point
3. **No History Reading**: Successor does NOT read full conversation history or large files predecessor processed
4. **Chain Allowed**: Successors can spawn their own successors (handoff chains)
5. **Progress Accumulation**: Progress file tracks cumulative work across all successors

### Successor vs Lead Taking Over

**Do NOT** have the lead agent complete teammate work. Always spawn a successor teammate instead.

| Approach | Why Avoid / Why Use |
|----------|---------------------|
| Lead takes over | Loses parallelism, lead becomes bottleneck, lead context also fills |
| Spawn successor | Maintains isolation, fresh context, can continue in parallel |

## Related Files

- `.claude/context/core/patterns/team-orchestration.md` - Overall coordination
- `.claude/context/core/formats/team-metadata-extension.md` - Result schema
- `.claude/context/core/formats/handoff-artifact.md` - Handoff document schema
- `.claude/context/core/formats/progress-file.md` - Progress tracking schema
- `.claude/skills/skill-team-*/SKILL.md` - Skill implementations
