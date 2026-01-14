# Research Report: Systematic Comparison of OpenAgents and ProofChecker .opencode Systems

**Project**: 240_systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures  
**Report**: research-001  
**Date**: 2025-12-29  
**Researcher**: researcher  

## Executive Summary

Comparative analysis of OpenAgents and ProofChecker .opencode systems reveals significant architectural differences offering systematic improvement opportunities. OpenAgents demonstrates 4 key strengths: (1) Lightweight commands (average 262 lines vs 712 lines) through frontmatter-based delegation, (2) Minimal context system (2,207 lines vs 8,093 lines) using lazy-loading index patterns, (3) Agent-driven architecture where commands define "what" and agents define "how", and (4) Session-based temporary context (.tmp/sessions/) for delegation. ProofChecker's system shows over-engineering with 1,138-line command-lifecycle.md, duplicate context loading (56KB in orchestrator), and commands containing full workflow implementations. Recommended improvements: Adopt frontmatter delegation pattern, implement lazy-loading context index, extract workflow logic from commands to agents, and establish session-based temporary context system. These changes address both Task 237 (context bloat) and Task 240 (Stage 7 failures) systematically.

## Research Scope

- **Objective**: Compare OpenAgents and ProofChecker .opencode systems to identify systematic improvements
- **Sources**: 
  - /home/benjamin/Projects/OpenAgents/.opencode/ (orchestrator, commands, agents, context)
  - /home/benjamin/Projects/ProofChecker/.opencode/ (orchestrator, commands, agents, context)
- **Methodology**: Directory structure comparison, file size analysis, architectural pattern analysis, workflow comparison

## Key Findings

### Finding 1: Command File Size and Complexity

**OpenAgents Commands** (Lightweight, Delegation-Centric):
- research.md: 167 lines
- plan.md: 244 lines  
- revise.md: 292 lines
- review.md: 346 lines
- **Average**: ~262 lines

**Command Structure** (Frontmatter + Brief Description):
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

**ProofChecker Commands** (Heavy, Self-Contained):
- research.md: 684 lines
- plan.md: 659 lines
- implement.md: 809 lines
- revise.md: 653 lines
- review.md: 754 lines
- **Average**: ~712 lines (2.7x larger)

**Analysis**: OpenAgents commands are 63% smaller because they define "what" rather than "how". ProofChecker commands contain full 8-stage lifecycle implementations duplicated across 4 commands.

**Recommendation**: Adopt OpenAgents frontmatter pattern with `agent:` field. Move workflow logic from commands to subagents.


### Finding 2: Context System Architecture

**OpenAgents Context** (Minimal, Lazy-Loaded):
- **Total**: 2,207 lines across all core context files
- **Index**: 32 lines (context/index.md) provides quick map
- **Average file size**: 150-200 lines
- **Organization**: core/standards/, core/workflows/, core/specs/, core/system/

**Context Index Pattern**:
```markdown
# Context Index

## Quick Map
code        → standards/code.md       [critical] implement, refactor
docs        → standards/docs.md       [critical] write docs
tests       → standards/tests.md      [critical] write tests
delegation  → workflows/delegation.md [high]     delegate, subagent
```

**ProofChecker Context** (Heavy, Pre-Loaded):
- **Total**: 8,093 lines across common context files (3.7x larger)
- **No index**: No lazy-loading quick-reference system
- **Largest files**:
  - command-lifecycle.md: 1,138 lines
  - status-markers.md: 888 lines
  - subagent-delegation-guide.md: 648 lines

**OpenAgents Lazy-Loading Pattern**:
```markdown
<critical_context_requirement>
BEFORE starting research, ALWAYS load:
1. @.opencode/context/core/specs/project-structure.md
2. @.opencode/context/core/specs/todo-management.md
</critical_context_requirement>
```

**ProofChecker Pre-Loading Pattern** (Orchestrator):
- Loads 56KB in orchestrator before routing
- Loads 7 context files in command Stage 4

**Analysis**: ProofChecker context is 3.7x larger with no lazy-loading. Context loaded upfront rather than on-demand.

**Recommendation**: Implement OpenAgents lazy-loading index pattern. Create compact context/index.md. Load context files on-demand in agents.


### Finding 3: Agent vs Command Responsibility

**OpenAgents Architecture** (Agent-Driven):
- **Commands**: Define "what" (objective, usage, examples) in ~200 lines
- **Agents**: Define "how" (workflow stages, validation, artifact creation) in ~300-500 lines
- **Pattern**: command.md → frontmatter.agent → subagents/{agent}.md

**Example** (/research command):
```markdown
---
agent: subagents/specs/research-agent
---

## Usage
/research "{topic}"
```

**Agent** (research-agent.md contains full workflow with stages 0-8)

**ProofChecker Architecture** (Command-Driven):
- **Commands**: Define both "what" and "how" (full 8-stage workflow) in ~700 lines
- **Pattern**: command.md contains full workflow → routes to agent after validation

**Analysis**: OpenAgents has clean separation. ProofChecker commands contain both description AND implementation, duplicating routing/validation logic across 4 workflow commands.

**Root Cause of Stage 7 Failures**: ProofChecker commands contain Stage 7 logic as XML documentation (narrative), not executable code. Claude skips it because XML stages are guidelines, not requirements. OpenAgents avoids this because **agents own the entire workflow**.

**Recommendation**: Extract workflow stages from commands to agents. Commands should only define frontmatter and brief usage. Agents should own all workflow logic including Stage 7.


### Finding 4: Session-Based Temporary Context

**OpenAgents Pattern**:
- **Location**: `.tmp/sessions/{timestamp}-{task-slug}/context.md`
- **Purpose**: Create focused context file for delegation, then cleanup
- **Benefits**: Avoids loading full context upfront; context scoped to specific delegation

**Template**:
```markdown
# Task Context: {Task Name}

## Current Request
{What user asked for}

## Requirements
- {requirement 1}

## Static Context Available
- .opencode/context/core/standards/code.md
```

**ProofChecker Pattern**:
- **No temporary context system**
- **Commands load full context in Stage 4**: ~150KB before delegation
- **No cleanup mechanism**

**Analysis**: OpenAgents creates focused, temporary context for each delegation. ProofChecker loads all context upfront leading to 60-70% context window usage before work begins.

**Recommendation**: Implement `.tmp/sessions/` temporary context system. Commands create focused context.md for each delegation.

### Finding 5: Frontmatter-Based Configuration

**OpenAgents Agent Frontmatter**:
```yaml
---
description: "Research specialist..."
mode: subagent
temperature: 0.3
tools:
  read: true
  write: true
permissions:
  bash:
    "rm -rf *": "deny"
    "sudo *": "deny"
---
```

**Benefits**: Runtime-enforceable tool permissions, temperature control, security patterns.

**ProofChecker**: No frontmatter configuration, no security enforcement.

**Recommendation**: Add YAML frontmatter to ProofChecker agents with tools, permissions, and mode fields.


### Finding 6: Orchestrator Simplicity

**OpenAgents Orchestrator** (15 lines):
```markdown
# OpenAgents Orchestrator

## Workflow
1. Analyze Request: Detect keywords
2. Delegate: Route to subsystem orchestrator
3. Return: Return result to user
```

**ProofChecker Orchestrator** (1,038 lines):
- Contains 13-stage workflow
- Delegation registry tracking
- Cycle detection, timeout enforcement
- Full coordination logic

**Analysis**: OpenAgents orchestrator is 69x smaller. Simple delegation pattern avoids delegation hang problems entirely.

**Recommendation**: Simplify orchestrator to OpenAgents pattern: analyze request, detect keywords/language, delegate, return result.

## Comparative Analysis Summary

| Aspect | OpenAgents | ProofChecker | Impact |
|--------|------------|--------------|--------|
| **Command Size** | 262 lines avg | 712 lines avg | ProofChecker 2.7x larger |
| **Context Size** | 2,207 lines | 8,093 lines | ProofChecker 3.7x larger |
| **Command Pattern** | Frontmatter + delegation | Full workflow embedded | OpenAgents cleaner |
| **Context Loading** | Lazy (on-demand) | Eager (upfront) | OpenAgents 60-70% savings |
| **Responsibility** | Agents own workflows | Commands own workflows | OpenAgents avoids duplication |
| **Temporary Context** | .tmp/sessions/ | None | OpenAgents better isolation |
| **Orchestrator** | 15 lines | 1,038 lines | OpenAgents 69x simpler |


## Root Cause Analysis: Stage 7 Failures

### Problem Pattern (ProofChecker):
1. Commands contain Stage 7 logic (XML documentation)
2. XML stages are narrative, not executable
3. Claude interprets XML as guidelines, not requirements
4. No enforcement mechanism in orchestrator or command
5. **Result**: Stage 7 skipped, status updates incomplete

### Why OpenAgents Avoids This:
1. Agents own workflow stages, not commands
2. Agents execute stages as code, not documentation
3. Commands delegate immediately without embedded workflow
4. Agents return validated results with artifacts
5. **Result**: Stage 7 always executes because agent owns it

### Fix Path:

**Option 1 - Architectural Alignment** (Recommended):
- Extract Stage 7 logic from commands to agents
- Commands define only frontmatter and description
- Agents own full workflow including status updates
- Eliminates XML-as-documentation problem

**Option 2 - Enforcement Layer** (Task 240 original plan):
- Add orchestrator validation of command stage completion
- Track command_stages in delegation registry
- Reject returns if Stage 7 not completed
- Band-aid over architectural mismatch

**Recommendation**: Option 1 aligns with OpenAgents proven pattern and eliminates root cause.


## Recommendations

### Immediate Improvements (High Impact, Low Effort)

#### 1. Adopt Lazy-Loading Context Index
**Problem**: ProofChecker loads 60-70% context upfront  
**Solution**: Create context/index.md with OpenAgents quick map pattern  
**Effort**: 4-6 hours  
**Impact**: 60-70% reduction in routing context window usage

#### 2. Implement Frontmatter Agent Delegation Pattern
**Problem**: Commands contain full workflows (600-800 lines)  
**Solution**: Add `agent:` field to command frontmatter, extract workflow to agents  
**Effort**: 12-16 hours (4 commands × 3-4 hours each)  
**Impact**: 60% command file size reduction, eliminates Stage 7 skip problem

#### 3. Create .tmp/sessions/ Temporary Context System
**Problem**: Context bloat from loading everything upfront  
**Solution**: Implement OpenAgents session-based temporary context  
**Effort**: 6-8 hours  
**Impact**: Better delegation isolation, explicit cleanup, reduced context bloat

#### 4. Simplify Orchestrator to Router Pattern
**Problem**: Over-engineered 1,038-line orchestrator  
**Solution**: Adopt OpenAgents 15-line router pattern  
**Effort**: 8-10 hours  
**Impact**: 69x size reduction, simpler mental model

### Medium-Term Improvements

#### 5. Consolidate Context Files
**Effort**: 16-20 hours  
**Impact**: 40-50% context system size reduction

Merge related files:
- subagent-return-format.md + subagent-delegation-guide.md → delegation.md
- command-lifecycle.md into agent workflow templates
- status-markers.md + state-schema.md → state-management.md

#### 6. Implement Agent Frontmatter Security
**Effort**: 8-10 hours  
**Impact**: Prevent dangerous operations (rm -rf, sudo, env edits)

Add YAML frontmatter with tools/permissions to all agents.


## Implementation Priority

### Phase 1: Quick Wins (12-16 hours)
1. Create context/index.md lazy-loading system (4-6 hours)
2. Add frontmatter to /research command and extract workflow to agent (4-6 hours)
3. Create .tmp/sessions/ temporary context template (2-4 hours)
4. Validate improvements in /research command (2 hours)

**Expected Results**: 60-70% context reduction, Stage 7 100% reliable for /research

### Phase 2: Core Architecture (20-30 hours)
1. Migrate remaining commands to frontmatter pattern (12-18 hours)
2. Simplify orchestrator to router pattern (8-10 hours)
3. Add security frontmatter to all agents (2-4 hours)

**Expected Results**: All commands <200 lines, orchestrator <100 lines, Stage 7 100% reliable

### Phase 3: Consolidation (16-20 hours)
1. Consolidate context files (12-16 hours)
2. Remove obsolete files (command-lifecycle.md, duplicated workflows) (4 hours)

**Expected Results**: 40-50% context system size reduction

### Phase 4: Testing & Documentation (8-12 hours)
1. Comprehensive testing of all commands (4-6 hours)
2. Update documentation to reflect new patterns (4-6 hours)

**Total Estimated Effort**: 56-78 hours

## Next Steps

### Immediate Actions
1. Create context/index.md following OpenAgents quick map pattern
2. Prototype frontmatter delegation with /research command
3. Implement .tmp/sessions/ temporary context system
4. Validate context window improvements

### Validation Criteria
- Context window usage <10% during routing (down from 60-70%)
- Command files <200 lines (down from 600-800 lines)
- Stage 7 executes 100% reliably (agents own it)
- Orchestrator <100 lines (down from 1,038 lines)

### Success Metrics
- **Context Efficiency**: Routing uses <10% context window
- **Code Size**: Commands average <200 lines
- **Reliability**: Zero Stage 7 skip failures in 20 consecutive runs
- **Maintainability**: Workflow changes require updating only agent files


## References

### OpenAgents System
- Orchestrator: /home/benjamin/Projects/OpenAgents/.opencode/agent/orchestrators/openagents-orchestrator.md (15 lines)
- Commands: /home/benjamin/Projects/OpenAgents/.opencode/command/ (average 262 lines)
- Agents: /home/benjamin/Projects/OpenAgents/.opencode/agent/subagents/specs/ (300-500 lines)
- Context: /home/benjamin/Projects/OpenAgents/.opencode/context/core/ (2,207 lines total)
- Context Index: /home/benjamin/Projects/OpenAgents/.opencode/context/index.md (32 lines)

### ProofChecker System
- Orchestrator: /home/benjamin/Projects/ProofChecker/.opencode/agent/orchestrator.md (1,038 lines)
- Commands: /home/benjamin/Projects/ProofChecker/.opencode/command/ (average 712 lines)
- Context: /home/benjamin/Projects/ProofChecker/.opencode/context/common/ (8,093 lines total)
- Command Lifecycle: /home/benjamin/Projects/ProofChecker/.opencode/context/core/workflows/command-lifecycle.md (1,138 lines)

### Related Tasks
- Task 237: Context window bloat (found 60-70% usage before work begins)
- Task 240: Stage 7 systematic failures
- Task 191: Delegation hang fixes (created comprehensive orchestrator tracking)

## Conclusion

OpenAgents demonstrates a **lean, agent-driven architecture** that ProofChecker should systematically adopt. The core improvements are:

1. **Frontmatter-based delegation**: Commands define "what", agents define "how"
2. **Lazy-loading context**: Index-based on-demand loading vs eager pre-loading
3. **Session-based temporary context**: Focused .tmp/sessions/ vs loading all upfront
4. **Simple orchestrator router**: 15-line keyword detector vs 1,038-line coordinator

These changes address both **Task 237** (context bloat) and **Task 240** (Stage 7 failures) systematically. The frontmatter delegation pattern eliminates Stage 7 skip problem because agents own workflow execution. The lazy-loading index pattern eliminates 60-70% routing context bloat. The session-based temporary context improves delegation isolation.

**Recommended Action**: Implement Phase 1 (Quick Wins) with /research command prototype to validate improvements before full migration. If successful (context <10% during routing, Stage 7 executes reliably), proceed with Phase 2-4 migration.
