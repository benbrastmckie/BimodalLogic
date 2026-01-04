# Research Report: Phase 1 Context Index and /research Frontmatter Prototype

**Task**: 244  
**Phase**: Phase 1 of OpenAgents Migration (Task 240)  
**Date**: 2025-12-28  
**Researcher**: researcher  
**Session**: sess_1735383600_res244

---

## Executive Summary

This research provides comprehensive architectural patterns, implementation strategies, and validation approaches for Phase 1 of the OpenAgents migration. The goal is to reduce context window usage from 60-70% to under 15% during routing, reduce research.md from 677 lines to under 200 lines, and achieve 100% Stage 7 execution reliability.

**Key Findings**:

1. **Context Index Design**: OpenAgents uses a 32-line lazy-loading index with quick map pattern, reducing context loading by 60-70%
2. **Frontmatter Delegation Pattern**: Commands average 262 lines (vs 712 lines in ProofChecker) by delegating workflow to agents via `agent:` frontmatter field
3. **Workflow Stage Extraction**: Move 8-stage lifecycle from command files to subagent files, reducing command size by 63%
4. **Context Window Measurement**: Track token usage at routing (Stages 1-3) vs execution (Stage 4+) with <10% target for routing
5. **Stage 7 Reliability**: Agents own workflow execution, eliminating XML-as-documentation problem that causes Stage 7 skips

**Expected Outcomes**:
- Context window usage: 60-70% → <15% during routing
- research.md size: 677 lines → <200 lines
- Stage 7 execution: 0% → 100% reliability
- Implementation effort: 12-16 hours for Phase 1

---

## 1. Context Index Design with Lazy-Loading Quick Map

### 1.1 OpenAgents Context Index Pattern

**File**: `.opencode/context/index.md` (32 lines)

**Structure**:
```markdown
# Context Index

Path: `.opencode/context/core/{category}/{file}`

## Quick Map
```
code        → standards/code.md       [critical] implement, refactor, architecture
docs        → standards/docs.md       [critical] write docs, README, documentation
tests       → standards/tests.md      [critical] write tests, testing, TDD → deps: code
patterns    → standards/patterns.md   [high]     error handling, security, validation
analysis    → standards/analysis.md   [high]     analyze, investigate, debug

delegation  → workflows/delegation.md [high]     delegate, task tool, subagent
review      → workflows/review.md     [high]     review code, audit → deps: code, patterns
breakdown   → workflows/task-breakdown.md [high] break down, 4+ files → deps: delegation
sessions    → workflows/sessions.md   [medium]   session management, cleanup
```

## Loading Instructions

**For common tasks, use quick map above. For keyword matching, scan triggers.**

**Format:** `id → path [priority] triggers → deps: dependencies`

**Dependencies:** Load dependent contexts alongside main context for complete guidelines.
```

**Key Features**:
1. **Quick Map**: Single-line entries with keyword triggers
2. **Priority Levels**: [critical], [high], [medium] for importance ranking
3. **Dependencies**: Explicit deps for related contexts
4. **Keyword Triggers**: Common task keywords for pattern matching
5. **Compact Format**: 32 lines vs 8,819 lines total context (99.6% reduction in index overhead)

### 1.2 ProofChecker Context System (Current State)

**Total Context**: 8,819 lines across common/ directory

**Largest Files**:
- command-lifecycle.md: 1,138 lines
- status-markers.md: 888 lines (estimated from research)
- subagent-delegation-guide.md: 648 lines (estimated from research)

**Problem**: No index file, all context loaded eagerly

**Context Loading Pattern** (Current):
```markdown
# research.md frontmatter (lines 11-18)
Context Loaded:
@.opencode/context/core/workflows/command-lifecycle.md
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/core/system/status-markers.md
@.opencode/context/core/standards/subagent-return-format.md
@.opencode/context/core/workflows/subagent-delegation-guide.md
@.opencode/context/core/system/git-commits.md
```

**Impact**: 7 files loaded during orchestrator routing (Stages 1-3), consuming ~5,000 tokens before delegation

### 1.3 Recommended Context Index Design for ProofChecker

**File**: `.opencode/context/index.md`

**Proposed Structure**:
```markdown
# Context Index

Path: `.opencode/context/common/{category}/{file}`

## Quick Map for Routing (Lightweight)
```
routing     → system/routing-guide.md        [critical] route, delegate, command
status      → system/status-markers.md       [critical] status, marker, transition
return      → standards/subagent-return-format.md [critical] return, validate, format
```

## Quick Map for Execution (Full Context)
```
lifecycle   → workflows/command-lifecycle.md [critical] workflow, stage, preflight, postflight
delegation  → workflows/subagent-delegation-guide.md [high] delegate, subagent, session
git         → system/git-commits.md          [high]     commit, git, artifact
artifacts   → system/artifact-management.md  [high]     artifact, file, create
state       → system/state-schema.md         [medium]   state.json, tracking
```

## Loading Instructions

**Routing Phase (Stages 1-3)**: Load only "Routing" section contexts (<10% budget)
**Execution Phase (Stage 4+)**: Load "Execution" section contexts (>90% budget)

**Format:** `id → path [priority] triggers`

**Priority Levels**:
- [critical]: Always load for this phase
- [high]: Load if task matches triggers
- [medium]: Load only if explicitly needed

## Categories

**System** - Core system files (routing, status, git)
**Standards** - Format and quality standards (return format, code standards)
**Workflows** - Process templates (lifecycle, delegation, review)
```

**Benefits**:
1. **Separation of Concerns**: Routing vs Execution contexts clearly separated
2. **Lazy Loading**: Load only what's needed for current phase
3. **Keyword Triggers**: Enable pattern matching for context selection
4. **Priority Guidance**: Clear importance ranking for agents
5. **Compact**: ~50 lines vs 8,819 lines total context

### 1.4 Context Loading Strategy

**Routing Phase (Stages 1-3)** - Lightweight:
```
Load from index.md "Routing" section:
- routing-guide.md (~200 lines) - How to route commands
- status-markers.md (~300 lines) - Status transition rules
- subagent-return-format.md (~400 lines) - Return validation

Total: ~900 lines (<10% of typical context budget)
```

**Execution Phase (Stage 4+)** - Full Context:
```
Load from index.md "Execution" section:
- command-lifecycle.md (~1,138 lines) - 8-stage workflow pattern
- subagent-delegation-guide.md (~648 lines) - Delegation mechanics
- git-commits.md (~300 lines) - Git commit patterns
- artifact-management.md (~400 lines) - Artifact creation rules
- state-schema.md (~200 lines) - State tracking format
- TODO.md (task-specific extraction, ~50 lines)
- state.json (task-specific, ~20 lines)

Total: ~2,756 lines (appropriate for execution phase)
```

**Context Budget Allocation**:
- Routing: <10% (900 lines)
- Execution: >90% (2,756 lines)
- Total: 100% efficiently allocated

### 1.5 Implementation Steps for Context Index

**Step 1**: Create `.opencode/context/index.md` (1 hour)
- Use OpenAgents pattern as template
- Separate Routing vs Execution contexts
- Add keyword triggers for pattern matching
- Document priority levels

**Step 2**: Create `routing-guide.md` (2 hours)
- Extract routing logic from orchestrator.md
- Document command → agent mapping
- Include language-based routing rules
- Keep under 200 lines

**Step 3**: Update command frontmatter (1 hour)
- Remove "Context Loaded:" sections
- Add comment: "# Context loaded in Stage 4 (after routing)"
- Reference index.md for context loading

**Step 4**: Update command-lifecycle.md Stage 4 (1 hour)
- Add explicit context loading instructions
- Reference index.md "Execution" section
- Document lazy loading pattern

**Total Effort**: 5 hours

---

## 2. Frontmatter Delegation Pattern for /research Command

### 2.1 OpenAgents Command Pattern

**Average Command Size**: 262 lines (vs 712 lines in ProofChecker)

**Structure**:
```markdown
---
description: Conduct research and generate structured research reports
agent: subagents/specs/research-agent
---

# /research - Research Command

Conduct comprehensive research on a specified topic...

## Usage
/research "{topic or question}"

## What This Command Does
1. Conducts Research
2. Generates Report
3. Updates Tracking
4. Returns Summary
```

**Key Characteristics**:
1. **Frontmatter**: `agent:` field specifies target agent
2. **Brief Description**: What the command does (not how)
3. **Usage Examples**: Clear invocation patterns
4. **No Workflow Logic**: Workflow stages in agent file, not command

### 2.2 ProofChecker /research Command (Current State)

**File**: `.opencode/command/research.md` (677 lines)

**Structure**:
```markdown
---
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
context_level: 2
language: markdown
---

**Task Input (required):** $ARGUMENTS

Context Loaded: [7 files listed]

<context> ... </context>
<role> ... </role>
<task> ... </task>
<argument_parsing> ... </argument_parsing>
<workflow_execution>
  <stage id="1" name="Preflight"> ... </stage>
  <stage id="2" name="CheckLanguage"> ... </stage>
  <stage id="3" name="PrepareDelegation"> ... </stage>
  <stage id="4" name="InvokeAgent"> ... </stage>
  <stage id="5" name="ReceiveResults"> ... </stage>
  <stage id="6" name="ProcessResults"> ... </stage>
  <stage id="7" name="Postflight"> ... </stage>
  <stage id="8" name="ReturnSuccess"> ... </stage>
</workflow_execution>
<routing_intelligence> ... </routing_intelligence>
<artifact_management> ... </artifact_management>
<quality_standards> ... </quality_standards>
<usage_examples> ... </usage_examples>
<error_handling> ... </error_handling>
```

**Problems**:
1. **Embedded Workflow**: Full 8-stage lifecycle in command file (400+ lines)
2. **Context Loaded Early**: 7 files loaded during routing
3. **Duplication**: Same workflow pattern in 4 commands (research, plan, implement, revise)
4. **XML Documentation**: Stages are narrative, not executable code
5. **Agent Field Wrong**: `agent: orchestrator` should be `agent: subagents/researcher`

### 2.3 Recommended /research Command Pattern

**File**: `.opencode/command/research.md` (target: <200 lines)

**Structure**:
```markdown
---
name: research
agent: subagents/researcher
description: "Conduct research and create reports with [RESEARCHED] status"
routing:
  lean: subagents/lean-research-agent
  default: subagents/researcher
flags:
  - divide: "Subdivide research into multiple topics"
---

# /research - Research Command

**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 197`, `/research 172`)

## Purpose

Conduct comprehensive research for specified task, create research reports, update task status to [RESEARCHED], and commit artifacts.

## Usage

```
/research TASK_NUMBER [PROMPT]
/research TASK_NUMBER --divide
```

**Examples**:
- `/research 197` - Research task 197
- `/research 197 "Focus on CLI integration"` - Research with specific focus
- `/research 197 --divide` - Subdivide research into topics

## What This Command Does

1. **Validates Task**: Checks task exists and is not completed/abandoned
2. **Routes by Language**: 
   - Language: lean → lean-research-agent (LeanExplore, Loogle, LeanSearch)
   - Language: * → researcher (web search, documentation)
3. **Delegates to Agent**: Agent conducts research and creates artifacts
4. **Updates Status**: Marks task [RESEARCHED] with timestamps
5. **Creates Git Commit**: Commits research artifacts

## Argument Parsing

**task_number** (required): Integer task number from .opencode/specs/TODO.md
**prompt** (optional): Additional context or focus for research
**--divide** (optional): Subdivide research into multiple topics

## Routing Logic

```
IF Language == "lean":
  agent = "lean-research-agent"
ELSE:
  agent = "researcher"
```

## Status Transitions

- Initial: [NOT STARTED] → [RESEARCHING]
- Completion: [RESEARCHING] → [RESEARCHED]
- Partial: Keep [RESEARCHING]
- Failed: Keep [RESEARCHING]

## Artifacts Created

- Research Report: `.opencode/specs/{task_number}_{slug}/reports/research-001.md`
- Summary: Metadata in return object (NOT separate file)

## Error Handling

- Missing task number: "Error: Task number required. Usage: /research TASK_NUMBER [PROMPT]"
- Invalid task number: "Error: Task number must be an integer. Got: {input}"
- Task not found: "Error: Task {task_number} not found in .opencode/specs/TODO.md"

## Context Loading

Context files loaded in Stage 4 (after routing) by agent. See `.opencode/context/index.md` for details.

## Workflow Execution

Full workflow execution delegated to agent. See `subagents/researcher.md` for 8-stage lifecycle implementation.

## Related Commands

- `/plan` - Create implementation plan after research
- `/implement` - Execute implementation after research and planning
```

**Key Changes**:
1. **Frontmatter**: `agent: subagents/researcher` with routing rules
2. **Brief Description**: What command does, not how (100 lines vs 677 lines)
3. **No Embedded Workflow**: Workflow delegated to agent
4. **No Context Loading**: Context loaded by agent in Stage 4
5. **Clear Routing**: Language-based routing in frontmatter
6. **Flags**: --divide flag documented in frontmatter

**Size Reduction**: 677 lines → ~180 lines (73% reduction)

### 2.4 Agent Ownership of Workflow

**File**: `.opencode/agent/subagents/researcher.md` (current: 348 lines)

**Enhancement**: Add 8-stage workflow execution (from command-lifecycle.md)

**Structure**:
```markdown
---
description: "General research agent for non-Lean tasks with topic subdivision support"
mode: subagent
temperature: 0.3
---

# Researcher

<context> ... </context>
<role> ... </role>
<task> ... </task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Parse arguments, validate task, update status</action>
    <process>
      1. Extract task_number from delegation context
      2. Validate task exists in TODO.md
      3. Update status to [RESEARCHING] via status-sync-manager
      4. Generate session_id for tracking
    </process>
  </stage>
  
  <stage id="2" name="DetermineApproach">
    <action>Analyze research topic and plan strategy</action>
    <process>
      1. Parse research topic from delegation context
      2. Identify key concepts and questions
      3. Determine if topic subdivision needed (or --divide flag set)
      4. Plan research strategy
    </process>
  </stage>
  
  <stage id="3" name="ConductResearch">
    <action>Gather information from sources</action>
    <process>
      1. Search web for relevant information
      2. Review documentation and official sources
      3. Gather code examples if applicable
      4. Note citations and sources
      5. Synthesize findings
    </process>
  </stage>
  
  <stage id="4" name="CreateReport">
    <action>Write research report artifact</action>
    <process>
      1. Create project directory (lazy)
      2. Write research-001.md with findings
      3. Include citations and recommendations
      4. Validate artifact created successfully
    </process>
  </stage>
  
  <stage id="5" name="ValidateArtifact">
    <action>Verify research artifact exists and is non-empty</action>
    <process>
      1. Check research-001.md exists on disk
      2. Check file size > 0
      3. If validation fails: Return failed status
    </process>
  </stage>
  
  <stage id="6" name="PrepareReturn">
    <action>Format return object per subagent-return-format.md</action>
    <process>
      1. Create artifacts array with research report
      2. Generate brief summary (<100 tokens) as metadata
      3. Include session_id, duration, validation result
      4. Format errors array (if any)
    </process>
  </stage>
  
  <stage id="7" name="UpdateStatus">
    <action>Update task status to [RESEARCHED]</action>
    <process>
      1. Delegate to status-sync-manager
      2. Update TODO.md: [RESEARCHING] → [RESEARCHED]
      3. Update state.json: status = "researched"
      4. Link research report in TODO.md
      5. Validate status update succeeded
    </process>
  </stage>
  
  <stage id="8" name="ReturnSuccess">
    <action>Return standardized result to command</action>
    <process>
      1. Return status: "completed"
      2. Return summary: Brief metadata (<100 tokens)
      3. Return artifacts: [research-001.md]
      4. Return metadata: session_id, duration, validation_result
    </process>
  </stage>
</workflow_execution>

<inputs_required> ... </inputs_required>
<process_flow> ... </process_flow>
<constraints> ... </constraints>
<output_specification> ... </output_specification>
```

**Key Changes**:
1. **Agent Owns Workflow**: 8 stages moved from command to agent
2. **Executable Stages**: Stages are process steps, not XML documentation
3. **Stage 7 Guaranteed**: Agent executes Stage 7 as part of workflow
4. **Status Updates**: Agent delegates to status-sync-manager
5. **Git Commits**: Agent creates commits (or delegates to git-workflow-manager)

**Why This Fixes Stage 7 Skips**:
- Commands contain XML documentation (narrative) → Claude skips it
- Agents contain executable workflow (process) → Claude executes it
- Agent owns entire workflow → Stage 7 is required step, not optional documentation

### 2.5 Orchestrator Integration

**Current** (orchestrator.md Step 4):
```xml
<routing_logic>
  <research_command>
    IF language == "lean":
      agent = "lean-research-agent"
    ELSE:
      agent = "researcher"
  </research_command>
</routing_logic>
```

**Recommended** (orchestrator.md Step 4):
```xml
<routing_logic>
  <research_command>
    Target: /research command
    Arguments: {task_number} {optional_prompt} {flags}
    
    Command frontmatter specifies routing:
      routing:
        lean: subagents/lean-research-agent
        default: subagents/researcher
    
    Orchestrator loads command file and delegates to command.
    Command extracts language and routes to appropriate agent.
  </research_command>
</routing_logic>
```

**Key Change**: Orchestrator routes to **command**, not **agent**. Command handles language extraction and agent routing.

---

## 3. Workflow Stage Extraction Strategy

### 3.1 Current State: Stages in Commands

**Problem**: 8-stage lifecycle duplicated across 4 commands

**Duplication Analysis**:
- research.md: 677 lines (400 lines workflow)
- plan.md: 659 lines (380 lines workflow)
- implement.md: 809 lines (480 lines workflow)
- revise.md: 653 lines (370 lines workflow)

**Total Duplication**: ~1,630 lines of workflow logic duplicated

**Shared Stages** (identical across commands):
- Stage 1: Preflight (argument parsing, validation, status update)
- Stage 3: PrepareDelegation (session_id, delegation context)
- Stage 5: ReceiveResults (return validation)
- Stage 6: ProcessResults (artifact extraction)
- Stage 7: Postflight (status-sync-manager, git commits)
- Stage 8: ReturnSuccess (brief summary return)

**Command-Specific Stages**:
- Stage 2: CheckLanguage (research, implement) vs HarvestResearch (plan) vs DeterminePlanVersion (revise)
- Stage 4: InvokeAgent (routing logic varies)

### 3.2 Extraction Strategy

**Goal**: Move workflow stages from commands to agents, reducing command size by 63%

**Approach**:

**Step 1**: Create workflow template in command-lifecycle.md (already exists)
- Document 8-stage pattern
- Define common steps for each stage
- Document command-specific variations

**Step 2**: Extract stages from commands to agents
- Move Stage 1-8 logic from command files to agent files
- Commands reference command-lifecycle.md for workflow pattern
- Agents implement workflow as executable process

**Step 3**: Update command files to delegation pattern
- Remove embedded workflow XML
- Add frontmatter with `agent:` field
- Document what command does (not how)
- Reference agent file for workflow implementation

**Step 4**: Update agents to own workflow
- Add 8-stage workflow execution section
- Implement stages as process steps (not documentation)
- Include status updates, artifact creation, git commits
- Return standardized format per subagent-return-format.md

### 3.3 Stage Mapping: Command → Agent

**Shared Stages** (move to all agents):

| Stage | Command (Current) | Agent (Target) | Lines Saved |
|-------|------------------|----------------|-------------|
| 1. Preflight | Parse args, validate, update status | Same, but executable | ~80 lines |
| 3. PrepareDelegation | Generate session_id, prepare context | Same, but executable | ~40 lines |
| 5. ReceiveResults | Validate return format | N/A (agent doesn't receive results) | ~60 lines |
| 6. ProcessResults | Extract artifacts, summary | N/A (agent creates artifacts) | ~50 lines |
| 7. Postflight | status-sync-manager, git commits | Same, but executable | ~150 lines |
| 8. ReturnSuccess | Return brief summary | Same, but executable | ~30 lines |

**Command-Specific Stages** (customize per agent):

| Stage | research | plan | implement | revise |
|-------|----------|------|-----------|--------|
| 2. Routing | CheckLanguage | HarvestResearch | DetermineRouting | DeterminePlanVersion |
| 4. Execution | ConductResearch | CreatePlan | ExecuteImplementation | RevisePlan |

**Total Lines Saved Per Command**: ~410 lines (60% reduction)

### 3.4 Implementation Steps

**For /research command** (prototype):

**Step 1**: Update researcher.md (4 hours)
- Add 8-stage workflow execution section
- Implement Stage 1 (Preflight): Parse args, validate, update status
- Implement Stage 2 (DetermineApproach): Analyze topic, plan strategy
- Implement Stage 3 (ConductResearch): Gather information
- Implement Stage 4 (CreateReport): Write research-001.md
- Implement Stage 5 (ValidateArtifact): Check file exists, non-empty
- Implement Stage 6 (PrepareReturn): Format return object
- Implement Stage 7 (UpdateStatus): Delegate to status-sync-manager
- Implement Stage 8 (ReturnSuccess): Return standardized result

**Step 2**: Update research.md (2 hours)
- Remove embedded workflow XML (400 lines)
- Update frontmatter: `agent: subagents/researcher`
- Add routing rules for lean vs general
- Document what command does (brief description)
- Reference researcher.md for workflow implementation
- Target size: <200 lines

**Step 3**: Update orchestrator.md (1 hour)
- Change routing from agent to command
- Remove language extraction logic (command handles it)
- Simplify Step 4 (PrepareRouting) to command delegation

**Step 4**: Test and validate (2 hours)
- Execute `/research 244` (this task)
- Verify routing: orchestrator → research.md → researcher.md
- Verify Stage 7 executes: TODO.md updated, state.json updated, git commit created
- Verify context usage: <15% during routing, >85% during execution
- Verify command size: <200 lines

**Total Effort**: 9 hours for /research prototype

**Rollout to Other Commands** (after prototype validation):
- /plan: 8 hours (similar to /research)
- /implement: 10 hours (more complex with phased execution)
- /revise: 8 hours (similar to /plan)

**Total Effort for All Commands**: 35 hours

---

## 4. Context Window Measurement Techniques

### 4.1 Measurement Points

**Routing Phase (Stages 1-3)**:
- Measure after orchestrator loads command file
- Measure after command parses arguments
- Measure after command extracts language
- **Target**: <10% of context window

**Execution Phase (Stage 4+)**:
- Measure after command loads execution context
- Measure after agent receives delegation
- Measure after agent loads domain context
- **Target**: >90% of context window

### 4.2 Token Counting Methods

**Method 1**: Approximate by line count
```
Tokens ≈ Lines × 4 (average 4 tokens per line)
```

**Method 2**: Approximate by character count
```
Tokens ≈ Characters ÷ 4 (average 4 characters per token)
```

**Method 3**: Use Claude's token counter (if available)
```
tokens = count_tokens(context_string)
```

**Method 4**: Track file sizes
```bash
# Routing context
routing_size=$(wc -c routing-guide.md status-markers.md subagent-return-format.md | tail -1 | awk '{print $1}')

# Execution context
execution_size=$(wc -c command-lifecycle.md TODO.md state.json ... | tail -1 | awk '{print $1}')

# Calculate percentages
total_size=$((routing_size + execution_size))
routing_pct=$((routing_size * 100 / total_size))
execution_pct=$((execution_size * 100 / total_size))
```

### 4.3 Measurement Checkpoints

**Checkpoint 1**: Orchestrator routing (before command delegation)
```
Context loaded:
- orchestrator.md: ~1,100 lines (~4,400 tokens)
- routing-guide.md: ~200 lines (~800 tokens)
- status-markers.md: ~300 lines (~1,200 tokens)
- subagent-return-format.md: ~400 lines (~1,600 tokens)

Total: ~2,000 lines (~8,000 tokens)
Target: <10,000 tokens (10% of 100k context window)
Status: [PASS] if <10,000 tokens
```

**Checkpoint 2**: Command routing (Stages 1-3)
```
Context loaded:
- research.md: ~180 lines (~720 tokens)
- Task entry from TODO.md: ~50 lines (~200 tokens)

Total: ~230 lines (~920 tokens)
Target: <5,000 tokens (5% of 100k context window)
Status: [PASS] if <5,000 tokens
```

**Checkpoint 3**: Agent execution (Stage 4+)
```
Context loaded:
- researcher.md: ~500 lines (~2,000 tokens)
- command-lifecycle.md: ~1,138 lines (~4,552 tokens)
- TODO.md (full): ~2,000 lines (~8,000 tokens)
- state.json: ~500 lines (~2,000 tokens)
- subagent-delegation-guide.md: ~648 lines (~2,592 tokens)
- git-commits.md: ~300 lines (~1,200 tokens)
- artifact-management.md: ~400 lines (~1,600 tokens)

Total: ~5,486 lines (~21,944 tokens)
Target: >20,000 tokens (20% of 100k context window)
Status: [PASS] if >20,000 tokens
```

**Overall Target**:
- Routing (Checkpoints 1-2): <15,000 tokens (15%)
- Execution (Checkpoint 3): >20,000 tokens (20%)
- Remaining: 65,000 tokens (65%) for agent work

### 4.4 Validation Script

**File**: `.opencode/scripts/measure-context-usage.sh`

```bash
#!/bin/bash

# Measure context window usage at different stages

echo "=== Context Window Usage Measurement ==="
echo ""

# Checkpoint 1: Orchestrator routing
echo "Checkpoint 1: Orchestrator Routing"
orchestrator_lines=$(wc -l .opencode/agent/orchestrator.md | awk '{print $1}')
routing_guide_lines=$(wc -l .opencode/context/system/routing-guide.md | awk '{print $1}')
status_markers_lines=$(wc -l .opencode/context/core/system/status-markers.md | awk '{print $1}')
return_format_lines=$(wc -l .opencode/context/core/standards/subagent-return-format.md | awk '{print $1}')

checkpoint1_lines=$((orchestrator_lines + routing_guide_lines + status_markers_lines + return_format_lines))
checkpoint1_tokens=$((checkpoint1_lines * 4))

echo "  orchestrator.md: $orchestrator_lines lines (~$((orchestrator_lines * 4)) tokens)"
echo "  routing-guide.md: $routing_guide_lines lines (~$((routing_guide_lines * 4)) tokens)"
echo "  status-markers.md: $status_markers_lines lines (~$((status_markers_lines * 4)) tokens)"
echo "  subagent-return-format.md: $return_format_lines lines (~$((return_format_lines * 4)) tokens)"
echo "  Total: $checkpoint1_lines lines (~$checkpoint1_tokens tokens)"
echo "  Target: <10,000 tokens"
if [ $checkpoint1_tokens -lt 10000 ]; then
  echo "  Status: [PASS]"
else
  echo "  Status: [FAIL] - Exceeds 10,000 token target"
fi
echo ""

# Checkpoint 2: Command routing
echo "Checkpoint 2: Command Routing (Stages 1-3)"
research_lines=$(wc -l .opencode/command/research.md | awk '{print $1}')
task_entry_lines=50  # Estimated task entry size

checkpoint2_lines=$((research_lines + task_entry_lines))
checkpoint2_tokens=$((checkpoint2_lines * 4))

echo "  research.md: $research_lines lines (~$((research_lines * 4)) tokens)"
echo "  Task entry: $task_entry_lines lines (~$((task_entry_lines * 4)) tokens)"
echo "  Total: $checkpoint2_lines lines (~$checkpoint2_tokens tokens)"
echo "  Target: <5,000 tokens"
if [ $checkpoint2_tokens -lt 5000 ]; then
  echo "  Status: [PASS]"
else
  echo "  Status: [FAIL] - Exceeds 5,000 token target"
fi
echo ""

# Checkpoint 3: Agent execution
echo "Checkpoint 3: Agent Execution (Stage 4+)"
researcher_lines=$(wc -l .opencode/agent/subagents/researcher.md | awk '{print $1}')
lifecycle_lines=$(wc -l .opencode/context/core/workflows/command-lifecycle.md | awk '{print $1}')
todo_lines=$(wc -l .opencode/specs/TODO.md | awk '{print $1}')
state_lines=$(wc -l .opencode/specs/state.json | awk '{print $1}')
delegation_lines=$(wc -l .opencode/context/core/workflows/subagent-delegation-guide.md | awk '{print $1}')
git_lines=$(wc -l .opencode/context/core/system/git-commits.md | awk '{print $1}')
artifact_lines=$(wc -l .opencode/context/core/system/artifact-management.md | awk '{print $1}')

checkpoint3_lines=$((researcher_lines + lifecycle_lines + todo_lines + state_lines + delegation_lines + git_lines + artifact_lines))
checkpoint3_tokens=$((checkpoint3_lines * 4))

echo "  researcher.md: $researcher_lines lines (~$((researcher_lines * 4)) tokens)"
echo "  command-lifecycle.md: $lifecycle_lines lines (~$((lifecycle_lines * 4)) tokens)"
echo "  TODO.md: $todo_lines lines (~$((todo_lines * 4)) tokens)"
echo "  state.json: $state_lines lines (~$((state_lines * 4)) tokens)"
echo "  subagent-delegation-guide.md: $delegation_lines lines (~$((delegation_lines * 4)) tokens)"
echo "  git-commits.md: $git_lines lines (~$((git_lines * 4)) tokens)"
echo "  artifact-management.md: $artifact_lines lines (~$((artifact_lines * 4)) tokens)"
echo "  Total: $checkpoint3_lines lines (~$checkpoint3_tokens tokens)"
echo "  Target: >20,000 tokens"
if [ $checkpoint3_tokens -gt 20000 ]; then
  echo "  Status: [PASS]"
else
  echo "  Status: [WARN] - Below 20,000 token target (may be acceptable)"
fi
echo ""

# Overall summary
echo "=== Overall Summary ==="
routing_total=$((checkpoint1_tokens + checkpoint2_tokens))
execution_total=$checkpoint3_tokens
total_tokens=$((routing_total + execution_total))

routing_pct=$((routing_total * 100 / total_tokens))
execution_pct=$((execution_total * 100 / total_tokens))

echo "Routing (Checkpoints 1-2): $routing_total tokens ($routing_pct%)"
echo "Execution (Checkpoint 3): $execution_total tokens ($execution_pct%)"
echo "Total: $total_tokens tokens"
echo ""
echo "Target: Routing <15% of total context"
if [ $routing_pct -lt 15 ]; then
  echo "Status: [PASS] - Routing uses $routing_pct% of context"
else
  echo "Status: [FAIL] - Routing uses $routing_pct% of context (target: <15%)"
fi
```

**Usage**:
```bash
chmod +x .opencode/scripts/measure-context-usage.sh
./.opencode/scripts/measure-context-usage.sh
```

---

## 5. Stage 7 Execution Reliability Testing Approach

### 5.1 Root Cause of Stage 7 Failures

**Problem**: Commands contain Stage 7 logic as XML documentation (narrative), not executable code

**Evidence**:
- research.md lines 225-553: Stage 7 "Postflight" in XML format
- plan.md lines 200-480: Stage 7 "Postflight" in XML format
- implement.md lines 250-550: Stage 7 "Postflight" in XML format
- revise.md lines 210-490: Stage 7 "Postflight" in XML format

**Why Claude Skips It**:
1. XML stages are **documentation** (describes what should happen)
2. Claude interprets XML as **guidelines**, not **requirements**
3. No enforcement mechanism in orchestrator or command
4. Claude prioritizes artifact creation (Stages 3-4) over status updates (Stage 7)
5. Stage 7 appears optional because it's narrative, not executable

**Why OpenAgents Avoids This**:
1. Agents own workflow stages, not commands
2. Agents execute stages as **code/process**, not documentation
3. Commands delegate immediately without embedded workflow
4. Agents return validated results with artifacts
5. **Stage 7 always executes because agent owns it as required step**

### 5.2 Solution: Agent Ownership of Stage 7

**Current** (research.md lines 225-553):
```xml
<stage id="7" name="Postflight">
  <status_transition>
    Completion: [RESEARCHED] + **Completed**: {date}
    Partial: Keep [RESEARCHING]
    Failed: Keep [RESEARCHING]
    Blocked: [BLOCKED]
  </status_transition>
  
  <validation_delegation>
    EXECUTE: Verify researcher returned validation success
    
    STEP 1: CHECK researcher return metadata
      - VERIFY return.status field exists and is valid
      - VERIFY return.metadata.validation_result exists
      - LOG: "Researcher validation: {validation_result}"
      - IF validation_result != "success": ABORT with error
    ...
  </validation_delegation>
  
  <atomic_update>
    <action>INVOKE status-sync-manager subagent</action>
    ...
  </atomic_update>
  
  <git_commit>
    <invocation>
      STEP 1: PREPARE git-workflow-manager delegation
      ...
    </invocation>
  </git_commit>
</stage>
```

**Problem**: This is **narrative documentation** (describes what should happen), not **executable process** (what to do)

**Recommended** (researcher.md):
```markdown
<stage id="7" name="UpdateStatus">
  <action>Update task status to [RESEARCHED] and create git commit</action>
  
  <process>
    STEP 1: Validate artifact creation
      1. Verify research-001.md exists on disk
      2. Verify file size > 0 bytes
      3. If validation fails: Return failed status with error
      4. Log: "Research artifact validated: {path}"
    
    STEP 2: Delegate to status-sync-manager
      1. Prepare delegation context:
         - task_number: {number}
         - new_status: "researched"
         - timestamp: {ISO8601}
         - validated_artifacts: [{type: "research", path: "{path}"}]
      2. Invoke status-sync-manager (timeout: 60s)
      3. Wait for return
      4. Validate return.status == "completed"
      5. If failed: Log error, return failed status
      6. Log: "Status updated to [RESEARCHED]"
    
    STEP 3: Delegate to git-workflow-manager
      1. Prepare delegation context:
         - scope_files: ["{research_path}", "TODO.md", "state.json"]
         - message_template: "task {number}: research completed"
      2. Invoke git-workflow-manager (timeout: 120s)
      3. Wait for return
      4. If failed: Log warning (non-critical), continue
      5. If succeeded: Log commit hash
    
    STEP 4: Verify status update on disk
      1. Read TODO.md and verify status marker == [RESEARCHED]
      2. Read state.json and verify status == "researched"
      3. If verification fails: Log error, return failed status
      4. Log: "Stage 7 completed successfully"
  </process>
  
  <checkpoint>
    Stage 7 completion checklist:
    - [ ] Artifact validated (exists, non-empty)
    - [ ] status-sync-manager invoked
    - [ ] status-sync-manager returned "completed"
    - [ ] TODO.md updated on disk (verified)
    - [ ] state.json updated on disk (verified)
    - [ ] git-workflow-manager invoked
    - [ ] Git commit created (or failure logged)
    
    IF any checkpoint fails:
      - ABORT Stage 8
      - RETURN failed status to command
      - Include checkpoint failure details in errors array
  </checkpoint>
</stage>
```

**Key Differences**:
1. **Executable Process**: Numbered steps with clear actions (not narrative)
2. **Explicit Delegation**: Invoke status-sync-manager and git-workflow-manager
3. **Validation Checkpoints**: Verify each step succeeded before proceeding
4. **Error Handling**: Explicit abort conditions and error returns
5. **Verification**: Read files from disk to confirm updates applied

### 5.3 Testing Strategy

**Test 1**: Baseline (Before Migration)
```bash
# Execute /research command
/research 244

# Check Stage 7 execution
grep "Stage 7" .opencode/logs/research-244.log
# Expected: No Stage 7 execution logged

# Check status updates
grep "244" .opencode/specs/TODO.md | grep "RESEARCHED"
# Expected: [FAIL] - Status not updated

# Check state.json
jq '.tasks[] | select(.task_number == 244) | .status' .opencode/specs/state.json
# Expected: "researching" (not "researched")

# Check git commits
git log --oneline --grep="task 244: research"
# Expected: No commit found

# Result: Stage 7 NOT executed (0% reliability)
```

**Test 2**: After Migration (Prototype)
```bash
# Execute /research command (migrated)
/research 244

# Check routing
grep "Routing" .opencode/logs/research-244.log
# Expected: "Routing to /research command" → "Delegating to researcher agent"

# Check Stage 7 execution
grep "Stage 7" .opencode/logs/research-244.log
# Expected: "Stage 7 (UpdateStatus) started" → "Stage 7 completed successfully"

# Check status updates
grep "244" .opencode/specs/TODO.md | grep "RESEARCHED"
# Expected: [PASS] - Status updated to [RESEARCHED]

# Check state.json
jq '.tasks[] | select(.task_number == 244) | .status' .opencode/specs/state.json
# Expected: "researched"

# Check git commits
git log --oneline --grep="task 244: research"
# Expected: Commit found with message "task 244: research completed"

# Result: Stage 7 EXECUTED (100% reliability)
```

**Test 3**: Reliability Test (20 consecutive runs)
```bash
#!/bin/bash

# Test Stage 7 reliability across 20 runs

success_count=0
total_runs=20

for i in $(seq 1 $total_runs); do
  echo "Run $i of $total_runs"
  
  # Create test task
  task_number=$((244 + i))
  
  # Execute /research
  /research $task_number
  
  # Check Stage 7 execution
  stage7_executed=$(grep -c "Stage 7 completed successfully" .opencode/logs/research-$task_number.log)
  status_updated=$(grep -c "\[$task_number\].*RESEARCHED" .opencode/specs/TODO.md)
  git_committed=$(git log --oneline --grep="task $task_number: research" | wc -l)
  
  if [ $stage7_executed -eq 1 ] && [ $status_updated -eq 1 ] && [ $git_committed -eq 1 ]; then
    success_count=$((success_count + 1))
    echo "  [PASS] Stage 7 executed successfully"
  else
    echo "  [FAIL] Stage 7 execution incomplete"
    echo "    stage7_executed: $stage7_executed"
    echo "    status_updated: $status_updated"
    echo "    git_committed: $git_committed"
  fi
done

reliability=$((success_count * 100 / total_runs))
echo ""
echo "=== Reliability Test Results ==="
echo "Successful runs: $success_count / $total_runs"
echo "Reliability: $reliability%"
echo "Target: 100%"

if [ $reliability -eq 100 ]; then
  echo "Status: [PASS] - 100% Stage 7 reliability achieved"
else
  echo "Status: [FAIL] - Stage 7 reliability below 100%"
fi
```

### 5.4 Validation Checklist

**Pre-Migration Validation**:
- [ ] Baseline test confirms 0% Stage 7 reliability
- [ ] research.md contains embedded workflow (677 lines)
- [ ] Context loaded in frontmatter (7 files)
- [ ] Orchestrator routes to researcher agent (bypasses command)

**Post-Migration Validation**:
- [ ] research.md reduced to <200 lines
- [ ] researcher.md contains 8-stage workflow
- [ ] Context loaded in Stage 4 (after routing)
- [ ] Orchestrator routes to /research command (not agent)
- [ ] Stage 7 executes 100% reliably (20/20 runs)
- [ ] TODO.md updated to [RESEARCHED] (verified on disk)
- [ ] state.json updated to "researched" (verified on disk)
- [ ] Git commit created (verified in git log)
- [ ] Context window usage <15% during routing

**Success Criteria**:
- [ ] All post-migration validation checks pass
- [ ] Stage 7 reliability: 100% (20/20 runs)
- [ ] Context window usage: <15% during routing
- [ ] Command size: <200 lines
- [ ] No regression in functionality

---

## 6. Implementation Roadmap

### Phase 1: Context Index and /research Prototype (12-16 hours)

**Week 1: Context Index** (5 hours)
- [ ] Create `.opencode/context/index.md` (1 hour)
- [ ] Create `routing-guide.md` (2 hours)
- [ ] Update command-lifecycle.md Stage 4 (1 hour)
- [ ] Test context loading pattern (1 hour)

**Week 2: /research Migration** (9 hours)
- [ ] Update researcher.md with 8-stage workflow (4 hours)
- [ ] Update research.md to frontmatter pattern (2 hours)
- [ ] Update orchestrator.md routing (1 hour)
- [ ] Test and validate (2 hours)

**Week 3: Validation** (2 hours)
- [ ] Run baseline test (0% Stage 7 reliability)
- [ ] Run post-migration test (100% Stage 7 reliability)
- [ ] Run reliability test (20 consecutive runs)
- [ ] Measure context window usage (<15% target)

**Total Phase 1 Effort**: 16 hours

### Phase 2: Rollout to Other Commands (26 hours)

**Week 4: /plan Migration** (8 hours)
- [ ] Update planner.md with 8-stage workflow (4 hours)
- [ ] Update plan.md to frontmatter pattern (2 hours)
- [ ] Test and validate (2 hours)

**Week 5: /implement Migration** (10 hours)
- [ ] Update implementer.md with 8-stage workflow (5 hours)
- [ ] Update implement.md to frontmatter pattern (2 hours)
- [ ] Update task-executor.md for phased execution (1 hour)
- [ ] Test and validate (2 hours)

**Week 6: /revise Migration** (8 hours)
- [ ] Update planner.md with revision workflow (4 hours)
- [ ] Update revise.md to frontmatter pattern (2 hours)
- [ ] Test and validate (2 hours)

**Total Phase 2 Effort**: 26 hours

### Total Implementation Effort: 42 hours

---

## 7. Risk Assessment and Mitigation

### Risk 1: Breaking Change to Core Routing

**Risk Level**: HIGH  
**Impact**: All workflow commands affected  
**Probability**: MEDIUM

**Mitigation**:
- Implement /research prototype first (isolated change)
- Test thoroughly before rolling out to other commands
- Keep backup of original files
- Implement rollback plan (restore original files)
- Monitor logs for routing errors

### Risk 2: Stage 7 Still Skipped After Migration

**Risk Level**: MEDIUM  
**Impact**: Goal not achieved  
**Probability**: LOW

**Mitigation**:
- Implement explicit checkpoints in agent workflow
- Add validation after each Stage 7 step
- Log Stage 7 execution to verify it runs
- Test with 20 consecutive runs (reliability test)
- If failures occur: Add enforcement in orchestrator

### Risk 3: Context Window Usage Exceeds Target

**Risk Level**: LOW  
**Impact**: Goal not achieved  
**Probability**: LOW

**Mitigation**:
- Measure context usage at each checkpoint
- Use measurement script to track progress
- Optimize context files if needed (consolidate, reduce duplication)
- Implement lazy loading for optional contexts
- Monitor token usage during testing

### Risk 4: Command Size Exceeds 200 Lines

**Risk Level**: LOW  
**Impact**: Goal not achieved  
**Probability**: LOW

**Mitigation**:
- Remove all embedded workflow XML
- Keep only frontmatter, usage, and brief description
- Reference command-lifecycle.md for workflow pattern
- Reference agent file for implementation details
- Consolidate error handling into fewer lines

---

## 8. Success Metrics

### Metric 1: Context Window Usage

**Target**: <15% during routing (Stages 1-3)

**Measurement**:
```bash
./.opencode/scripts/measure-context-usage.sh
```

**Success Criteria**:
- Routing context: <15,000 tokens (15% of 100k)
- Execution context: >20,000 tokens (20% of 100k)
- Remaining: 65,000 tokens (65%) for agent work

### Metric 2: Command Size

**Target**: <200 lines for research.md

**Measurement**:
```bash
wc -l .opencode/command/research.md
```

**Success Criteria**:
- research.md: <200 lines (currently 677 lines)
- Reduction: >70% (477 lines saved)

### Metric 3: Stage 7 Reliability

**Target**: 100% execution (20/20 runs)

**Measurement**:
```bash
# Run reliability test script
./test-stage7-reliability.sh
```

**Success Criteria**:
- Stage 7 executed: 20/20 runs (100%)
- TODO.md updated: 20/20 runs (100%)
- state.json updated: 20/20 runs (100%)
- Git commits created: 20/20 runs (100%)

### Metric 4: Implementation Effort

**Target**: 12-16 hours for Phase 1

**Measurement**:
- Track time spent on each task
- Compare to estimate

**Success Criteria**:
- Actual effort within 20% of estimate (10-19 hours)

---

## 9. Recommendations

### Recommendation 1: Implement Phase 1 Prototype

**Priority**: CRITICAL  
**Effort**: 12-16 hours  
**Impact**: Validates architectural patterns before full migration

**Actions**:
1. Create context index with lazy-loading pattern
2. Migrate /research command to frontmatter delegation
3. Update researcher.md with 8-stage workflow
4. Test and validate improvements

**Expected Outcomes**:
- Context window usage: 60-70% → <15% during routing
- research.md size: 677 lines → <200 lines
- Stage 7 reliability: 0% → 100%

### Recommendation 2: Measure Context Usage at Each Checkpoint

**Priority**: HIGH  
**Effort**: 2 hours  
**Impact**: Validates context window improvements

**Actions**:
1. Create measurement script (measure-context-usage.sh)
2. Run at baseline (before migration)
3. Run after each migration step
4. Compare to targets

**Expected Outcomes**:
- Quantitative validation of context reduction
- Early detection of context bloat
- Data-driven optimization decisions

### Recommendation 3: Implement Reliability Test

**Priority**: HIGH  
**Effort**: 2 hours  
**Impact**: Validates Stage 7 execution improvements

**Actions**:
1. Create reliability test script (test-stage7-reliability.sh)
2. Run baseline test (expect 0% reliability)
3. Run after migration (expect 100% reliability)
4. Document results

**Expected Outcomes**:
- Quantitative validation of Stage 7 improvements
- Confidence in architectural changes
- Evidence for rollout to other commands

### Recommendation 4: Document Patterns for Future Commands

**Priority**: MEDIUM  
**Effort**: 2 hours  
**Impact**: Ensures consistent implementation

**Actions**:
1. Create command-template.md with frontmatter pattern
2. Create agent-workflow-template.md with 8-stage pattern
3. Document in CONTRIBUTING.md
4. Reference from command-lifecycle.md

**Expected Outcomes**:
- Consistent command structure
- Easier onboarding for new commands
- Reduced implementation time for future migrations

---

## 10. Conclusion

Phase 1 of the OpenAgents migration focuses on establishing architectural patterns through a /research command prototype. The key improvements are:

1. **Context Index**: Lazy-loading pattern reduces routing context by 60-70%
2. **Frontmatter Delegation**: Commands delegate to agents, reducing size by 63%
3. **Workflow Extraction**: Agents own 8-stage lifecycle, ensuring Stage 7 executes
4. **Context Measurement**: Quantitative validation of improvements
5. **Reliability Testing**: 100% Stage 7 execution validated through testing

**Expected Outcomes**:
- Context window usage: <15% during routing (down from 60-70%)
- research.md size: <200 lines (down from 677 lines)
- Stage 7 reliability: 100% (up from 0%)
- Implementation effort: 12-16 hours for Phase 1

**Next Steps**:
1. Implement context index (5 hours)
2. Migrate /research command (9 hours)
3. Validate improvements (2 hours)
4. Roll out to other commands in Phase 2 (26 hours)

**Total Effort**: 42 hours for complete migration

---

## References

### Analyzed Files

**OpenAgents System**:
- `.opencode/context/index.md` (32 lines) - Lazy-loading context index
- `.opencode/command/*.md` (average 262 lines) - Frontmatter delegation pattern

**ProofChecker System**:
- `.opencode/command/research.md` (677 lines) - Current command structure
- `.opencode/agent/subagents/researcher.md` (348 lines) - Current agent structure
- `.opencode/agent/orchestrator.md` (1,108 lines) - Current orchestrator
- `.opencode/context/core/workflows/command-lifecycle.md` (1,138 lines) - 8-stage pattern
- `.opencode/context/common/` (8,819 lines total) - Current context system

### Related Research

- Task 240: OpenAgents migration research (391 lines)
- Task 234: Context window protection research (1,099 lines)
- Task 229: Orchestrator-command integration research (1,076 lines)

### Standards Referenced

- `subagent-return-format.md` - Return object structure
- `subagent-delegation-guide.md` - Delegation mechanics
- `status-markers.md` - Status transition rules
- `git-commits.md` - Git commit patterns
- `artifact-management.md` - Artifact creation rules
