---
name: skill-team-research
description: Orchestrate multi-agent research with wave-based parallel execution. Spawns 2-4 teammates for diverse investigation angles and synthesizes findings. Routes to language-appropriate agents (e.g., Lean tasks use lean-research-agent pattern with lean-lsp MCP tools).
allowed-tools: Task, Bash, Edit, Read, Write
# This skill uses TeammateTool for team coordination (available when CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1)
# Context loaded by lead during synthesis:
#   - .claude/context/core/patterns/team-orchestration.md
#   - .claude/context/core/formats/team-metadata-extension.md
#   - .claude/utils/team-wave-helpers.md
# Language routing patterns:
#   - .claude/utils/team-wave-helpers.md#language-routing-pattern
---

# Team Research Skill

Multi-agent research with wave-based parallelization. Spawns 2-4 teammates to investigate complementary angles, then synthesizes findings into a unified report.

**Language-Aware Routing**: Teammates are spawned with language-appropriate prompts and tools. For Lean tasks, teammates use lean-research-agent patterns with access to lean-lsp MCP tools and blocked tool warnings.

**IMPORTANT**: This skill requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` environment variable. If team creation fails, gracefully degrades to single-agent research via skill-researcher.

## Context References

Reference (load as needed during synthesis):
- Path: `.claude/context/core/patterns/team-orchestration.md` - Wave coordination patterns
- Path: `.claude/context/core/formats/team-metadata-extension.md` - Team result schema
- Path: `.claude/context/core/formats/return-metadata-file.md` - Base metadata schema
- Path: `.claude/utils/team-wave-helpers.md` - Reusable wave patterns

## Trigger Conditions

This skill activates when:
- `/research N --team` is invoked
- Task exists and status allows research
- Team mode is requested via --team flag

## Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `task_number` | integer | Yes | Task to research |
| `focus_prompt` | string | No | Optional focus for research |
| `team_size` | integer | No | Number of teammates (2-4, default 2) |

---

## Execution Flow

### Stage 1: Input Validation

Validate required inputs:
- `task_number` - Must exist in state.json
- `team_size` - Clamp to range [2, 4], default 2

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

# Validate team_size
team_size=${team_size:-2}
[ "$team_size" -lt 2 ] && team_size=2
[ "$team_size" -gt 4 ] && team_size=4
```

---

### Stage 2: Preflight Status Update

Update task status to "researching" BEFORE spawning teammates.

**Update state.json**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researching" \
   --arg sid "$session_id" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    session_id: $sid
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Update TODO.md**: Change status marker to `[RESEARCHING]`.

---

### Stage 3: Create Postflight Marker

Create marker file to prevent premature termination:

```bash
mkdir -p "specs/${task_number}_${project_name}"

cat > "specs/${task_number}_${project_name}/.postflight-pending" << EOF
{
  "session_id": "${session_id}",
  "skill": "skill-team-research",
  "task_number": ${task_number},
  "operation": "team-research",
  "team_size": ${team_size},
  "reason": "Team research in progress: synthesis, status update, git commit pending"
}
EOF
```

---

### Stage 4: Check Team Mode Availability

Verify Agent Teams feature is available:

```bash
# Check environment variable
if [ "$CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" != "1" ]; then
  echo "Warning: Team mode unavailable, falling back to single agent"
  # Fall back to skill-researcher
  # ... (see Stage 4a)
fi
```

---

### Stage 4a: Fallback to Single Agent

If team mode is unavailable:

1. Log warning about degradation
2. Invoke `skill-researcher` via Task tool
3. Pass original parameters
4. Add `degraded_to_single: true` to metadata
5. Continue with postflight

---

### Stage 5a: Language Routing Decision

Determine language-specific configuration for teammate prompts:

```bash
# Route by task language
case "$language" in
  "lean")
    # Lean-specific configuration
    use_lean_prompts=true
    research_agent_pattern="lean-research-agent"
    default_model="opus"
    context_refs="@.claude/context/project/lean4/tools/mcp-tools-guide.md, @.claude/context/project/lean4/standards/proof-debt-policy.md"
    blocked_tools="lean_diagnostic_messages (lean-lsp-mcp #115), lean_file_outline (unreliable)"
    available_tools="lean_leansearch, lean_loogle, lean_leanfinder, lean_local_search, lean_hover_info"
    ;;
  "latex"|"typst"|"meta")
    # Document/system tasks - Sonnet is cost-effective
    use_lean_prompts=false
    research_agent_pattern="general-research-agent"
    default_model="sonnet"
    context_refs=""
    blocked_tools=""
    available_tools="WebSearch, WebFetch, Read, Grep, Glob"
    ;;
  *)
    # Generic configuration - inherit lead's model
    use_lean_prompts=false
    research_agent_pattern="general-research-agent"
    default_model="inherit"
    context_refs=""
    blocked_tools=""
    available_tools="WebSearch, WebFetch, Read, Grep, Glob"
    ;;
esac

# Prepare model preference line for prompts
if [ "$default_model" = "inherit" ]; then
  model_preference_line=""
else
  model_preference_line="Model preference: Use Claude ${default_model^} for this analysis."
fi
```

See `.claude/utils/team-wave-helpers.md#language-routing-pattern` for full configuration lookup.

---

### Stage 5: Spawn Research Wave

Create teammate prompts and spawn wave.

**For Lean tasks** (`language == "lean"`), use Lean-specific prompts with MCP tools and blocked tool warnings.

**For non-Lean tasks**, use generic prompts (existing behavior preserved).

#### For Lean Tasks (language == "lean")

Use the Lean teammate prompt template from `.claude/utils/team-wave-helpers.md#lean-teammate-prompt-template-research`.

**Teammate A - Primary Angle (Lean)**:
```
Research task {task_number}: {description}

{model_preference_line}

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

Focus on: Implementation approaches and Mathlib patterns for this task.
Challenge assumptions. Verify lemma existence with lean_local_search.
Consider {focus_prompt} if provided.

Output your findings to: specs/{N}_{SLUG}/reports/teammate-a-findings.md

Format: Markdown with sections for Key Findings, Recommended Approach,
Evidence (including lemma names verified via lean_local_search), Confidence Level
```

**Teammate B - Alternative Approaches (Lean)**:
```
[Same header as Teammate A with tools, blocked tools, etc.]

Focus on: Alternative Mathlib patterns and prior art.
Look for existing lemmas/theorems we could adapt.
Do NOT duplicate Teammate A's primary focus.
Verify all lemma names with lean_local_search.

Output your findings to: specs/{N}_{SLUG}/reports/teammate-b-findings.md
```

**Teammate C - Risk Analysis (Lean, if team_size >= 3)**:
```
[Same header as Teammate A with tools, blocked tools, etc.]

Focus on: Proof risks, missing lemmas, and edge cases.
Identify where proof strategies could fail.
Note any suspicious axioms or sorry placeholders in related code.
Check for Mathlib version compatibility issues.

Output your findings to: specs/{N}_{SLUG}/reports/teammate-c-findings.md
```

**Teammate D - Devil's Advocate (Lean, if team_size >= 4)**:
```
[Same header as Teammate A with tools, blocked tools, etc.]

Focus on: Challenging findings from other teammates.
Verify their claimed lemmas actually exist (use lean_local_search).
Look for gaps in proof strategy.
Question complexity assumptions.

Wait for other teammates to complete, then analyze their outputs.

Output your findings to: specs/{N}_{SLUG}/reports/teammate-d-findings.md
```

---

#### For Non-Lean Tasks (general, meta, latex, typst)

Use generic prompts (existing behavior preserved).

**Teammate A - Primary Angle (Generic)**:
```
Research task {task_number}: {description}

{model_preference_line}

Focus on implementation approaches and patterns.
Challenge assumptions and provide specific examples.
Consider {focus_prompt} if provided.

Output your findings to:
specs/{N}_{SLUG}/reports/teammate-a-findings.md

Format: Markdown with clear sections for:
- Key Findings
- Recommended Approach
- Evidence/Examples
- Confidence Level (high/medium/low)
```

**Teammate B - Alternative Approaches (Generic)**:
```
Research task {task_number}: {description}

Focus on alternative patterns and prior art.
Look for existing solutions we could adapt.
Do NOT duplicate Teammate A's focus on primary approaches.

Output your findings to:
specs/{N}_{SLUG}/reports/teammate-b-findings.md

Format: Same as Teammate A
```

**Teammate C - Risk Analysis (Generic, if team_size >= 3)**:
```
Research task {task_number}: {description}

Focus on risks, blockers, and edge cases.
Identify what could go wrong with proposed approaches.
Consider integration challenges and dependencies.

Output your findings to:
specs/{N}_{SLUG}/reports/teammate-c-findings.md

Format: Same as Teammate A
```

**Teammate D - Devil's Advocate (Generic, if team_size >= 4)**:
```
Research task {task_number}: {description}

Challenge findings from other teammates once available.
Look for gaps, inconsistencies, and missed alternatives.
Question assumptions and identify blind spots.

Wait for other teammates to complete, then analyze their outputs.

Output your findings to:
specs/{N}_{SLUG}/reports/teammate-d-findings.md

Format: Same as Teammate A
```

---

**Spawn teammates using TeammateTool**.

---

### Stage 6: Wait for Wave Completion

Wait for all teammates to complete or timeout:

```
Timeout: 30 minutes for Wave 1

While not all complete and not timed out:
  - Check teammate completion status
  - Collect completed results
  - Wait 30 seconds between checks

On timeout:
  - Mark remaining as "timeout"
  - Continue with available results
```

---

### Stage 7: Collect Teammate Results

Read each teammate's output file:

```bash
teammate_results=[]

for teammate in A B C D; do
  file="specs/${task_number}_${project_name}/reports/teammate-${teammate,,}-findings.md"
  if [ -f "$file" ]; then
    # Parse findings
    # Extract confidence level
    # Check for conflicts with other teammates
    teammate_results+=("...")
  fi
done
```

---

### Stage 8: Synthesize Findings

Lead synthesizes all teammate results:

1. **Extract key findings** from each teammate
2. **Detect conflicts** between findings
3. **Resolve conflicts** with evidence-based judgment
4. **Identify gaps** in coverage
5. **Decide on Wave 2** if significant gaps exist

**Conflict Resolution**:
- Compare findings across teammates
- Log conflicts found
- Make judgment call based on evidence strength
- Document resolution reasoning

---

### Stage 9: Create Unified Report

Write synthesized report:

```markdown
# Research Report: Task #{N}

**Task**: {title}
**Date**: {ISO_DATE}
**Mode**: Team Research ({team_size} teammates)

## Summary

{Synthesized summary of findings}

## Key Findings

### Primary Approach (from Teammate A)
{Findings}

### Alternative Approaches (from Teammate B)
{Findings}

### Risks and Blockers (from Teammate C, if present)
{Findings}

### Critical Analysis (from Teammate D, if present)
{Findings}

## Synthesis

### Conflicts Resolved
{List of conflicts and how they were resolved}

### Gaps Identified
{List of any remaining gaps}

### Recommendations
{Synthesized recommendations}

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary | completed | high |
| B | Alternatives | completed | medium |

## References

{Sources cited by teammates}
```

Output to: `specs/{N}_{SLUG}/reports/research-001.md`

---

### Stage 10: Update Status (Postflight)

Update task status to "researched":

**Update state.json**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researched" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    researched: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Update TODO.md**: Change status marker to `[RESEARCHED]`.

**Link artifact**:
```bash
jq --arg path "specs/${task_number}_${project_name}/reports/research-001.md" \
   --arg type "research" \
   --arg summary "Team research with ${team_size} teammates" \
  '(.active_projects[] | select(.project_number == '$task_number')).artifacts += [{"path": $path, "type": $type, "summary": $summary}]' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

---

### Stage 11: Write Metadata File

Write team execution metadata:

```json
{
  "status": "researched",
  "summary": "Team research completed with {N} teammates",
  "artifacts": [
    {
      "type": "research",
      "path": "specs/{N}_{SLUG}/reports/research-001.md",
      "summary": "Synthesized research from {team_size} teammates"
    }
  ],
  "team_execution": {
    "enabled": true,
    "wave_count": 1,
    "teammates_spawned": {team_size},
    "teammates_completed": {completed_count},
    "teammates_failed": {failed_count},
    "token_usage_multiplier": 5.0,
    "degraded_to_single": false
  },
  "teammate_results": [...],
  "synthesis": {
    "conflicts_found": {N},
    "conflicts_resolved": {N},
    "gaps_identified": {N},
    "wave_2_triggered": false
  },
  "metadata": {
    "session_id": "{session_id}",
    "agent_type": "skill-team-research"
  }
}
```

---

### Stage 12: Git Commit

Commit using targeted staging (prevents race conditions with concurrent agents):

```bash
git add \
  "specs/${task_number}_${project_name}/reports/" \
  "specs/${task_number}_${project_name}/.return-meta.json" \
  "specs/TODO.md" \
  "specs/state.json"
git commit -m "task ${task_number}: complete team research (${team_size} teammates)

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

**Note**: Use targeted staging, NOT `git add -A`. See `.claude/context/core/standards/git-staging-scope.md`.

---

### Stage 13: Cleanup

Remove marker and temporary files:

```bash
rm -f "specs/${task_number}_${project_name}/.postflight-pending"
rm -f "specs/${task_number}_${project_name}/.return-meta.json"
# Keep teammate findings files for reference
```

---

### Stage 14: Return Summary

Return brief text summary:

```
Team research completed for task {N}:
- Spawned {team_size} teammates for parallel investigation
- Teammate A: Primary approach findings (high confidence)
- Teammate B: Alternative patterns identified (medium confidence)
- {N} conflicts found and resolved
- Synthesized report at specs/{N}_{SLUG}/reports/research-001.md
- Status updated to [RESEARCHED]
```

---

## Error Handling

### Team Creation Failure
- Fall back to skill-researcher
- Mark `degraded_to_single: true`
- Continue with single-agent research

### Teammate Timeout
- Continue with available results
- Note timeout in synthesis
- Mark result as partial if critical teammate missing

### Synthesis Failure
- Preserve raw teammate findings
- Mark status as partial
- Provide raw findings to user

### Git Commit Failure
- Non-blocking: log and continue
- Return success with warning

---

## Return Format

Brief text summary (NOT JSON):

```
Team research completed for task 412:
- Spawned 3 teammates for parallel investigation
- Teammate A: Implementation patterns (high confidence)
- Teammate B: Prior art from Mathlib (medium confidence)
- Teammate C: Risk analysis for modal logic (high confidence)
- 1 conflict resolved (approach preference)
- Synthesized report at specs/412_task_name/reports/research-001.md
- Status updated to [RESEARCHED]
- Changes committed with session sess_...
```
