# Research Report: Task #429

**Task**: Extend command-skill-agent integration to /meta
**Date**: 2026-01-12
**Focus**: Design optimal /meta command using established framework patterns

## Summary

This research analyzed the current /meta command implementation and the framework documentation created by task 427 to identify how to extend the command-skill-agent integration pattern to /meta. The current /meta command executes directly without delegation to skills/agents, missing the benefits of the three-layer architecture. This report identifies integration patterns, context requirements, and design recommendations for making /meta leverage the established framework.

## Findings

### 1. Current /meta Command Analysis

The current `/meta` command (`.claude/commands/meta.md`) operates in "direct execution" mode:

**Current Structure**:
- **Line count**: ~508 lines
- **Mode**: Direct execution (no skill/agent delegation)
- **Purpose**: Interactive system builder that creates TASKS for agent architecture changes
- **Constraints**: Forbidden from directly implementing - only creates tasks

**Current Features**:
- Interactive interview mode (7 stages)
- With-prompt mode (abbreviated flow)
- Analyze mode (`--analyze`)
- Task creation workflow

**Architecture Gap**: Unlike /research, /plan, and /implement which use the orchestrator -> skill -> agent pattern, /meta executes all logic directly in the command file.

### 2. Framework Documentation Created by Task 427

Task 427 created comprehensive documentation that /meta should leverage:

| Guide | Path | Relevance to /meta |
|-------|------|-------------------|
| Component Selection | `.claude/docs/guides/component-selection.md` | Guides decisions on what components to create |
| Creating Skills | `.claude/docs/guides/creating-skills.md` | Template for new skill creation |
| Creating Agents | `.claude/docs/guides/creating-agents.md` | Template for new agent creation |
| Creating Commands | `.claude/docs/guides/creating-commands.md` | Template for new command creation |
| Research Flow Example | `.claude/docs/examples/research-flow-example.md` | Shows end-to-end integration pattern |

**Key Insight**: /meta is essentially a "system builder" that should USE these guides to help users create components. The guides provide the decision trees, templates, and patterns that /meta should reference.

### 3. Integration Pattern Options

Three architectural approaches for integrating /meta:

**Option A: Full Three-Layer Integration**
```
/meta command -> skill-meta -> meta-builder-agent
```
- Creates new skill-meta that validates inputs
- Creates new meta-builder-agent that handles execution
- Follows same pattern as /research, /implement
- Benefits: Consistency, token efficiency, testability
- Drawbacks: May be overkill for interactive interview workflow

**Option B: Partial Integration (Hybrid)**
```
/meta command -> (direct execution for interview)
                -> skill-meta-analyzer (for --analyze)
                -> skill-meta-generator (for task creation)
```
- Interview stages execute directly in command
- Heavy operations delegate to specialized skills
- Benefits: Interactive flow stays responsive, heavy work delegated
- Drawbacks: Inconsistent with other commands

**Option C: Enhanced Direct with Context Loading**
```
/meta command (enhanced) -> loads component guides on-demand
```
- Keep direct execution but add @-references to framework docs
- Add structured output sections referencing guides
- Benefits: Simplest change, maintains interactivity
- Drawbacks: Misses token efficiency, doesn't match established pattern

**Recommendation**: Option A (Full Three-Layer Integration) for consistency with the established architecture, but with a modified flow that preserves interactivity through the agent.

### 4. Context Requirements for /meta

Based on analysis, /meta should load these context files:

**Always Load** (for any /meta invocation):
- `.claude/docs/guides/component-selection.md` - Decision tree for what to create
- `.claude/context/core/formats/subagent-return.md` - Return format schema

**Load When Creating Components**:
- `.claude/docs/guides/creating-commands.md` - When creating commands
- `.claude/docs/guides/creating-skills.md` - When creating skills
- `.claude/docs/guides/creating-agents.md` - When creating agents
- `.claude/context/core/templates/thin-wrapper-skill.md` - Skill template

**Load for System Analysis**:
- `.claude/context/index.md` - Full context discovery
- `.claude/ARCHITECTURE.md` - System architecture

### 5. Skill and Agent Design for /meta

**skill-meta Structure**:
```yaml
---
name: skill-meta
description: Interactive system builder. Invoke for /meta command.
allowed-tools: Task
context: fork
agent: meta-builder-agent
---
```

The skill would:
1. Validate mode (interactive, prompt, analyze)
2. Prepare delegation context with mode and arguments
3. Invoke meta-builder-agent
4. Validate and propagate return

**meta-builder-agent Structure**:
- **Purpose**: Execute system building workflows
- **Modes**: Interactive interview, prompt analysis, system analysis
- **Tools**: Read, Write, Edit, Glob, Grep, Bash(jq, git, mkdir)
- **Context Loading**: Load guides on-demand based on workflow

**Agent Stages**:
1. Parse delegation context (mode, arguments)
2. Load appropriate context (guides based on mode)
3. Execute workflow (interview/analyze/generate)
4. Create task entries (TODO.md, state.json, task directories)
5. Return structured JSON result

### 6. Interview Flow Considerations

The current /meta has a 7-stage interview flow that benefits from interactivity:

**Challenge**: Standard skill->agent delegation assumes single invocation with result. Interactive interviews need multiple user prompts.

**Solutions**:
1. **Single-pass agent**: Agent asks all questions in one prompt, user responds comprehensively
2. **AskUserQuestion tool**: Agent uses AskUserQuestion between stages (supported by Claude Code)
3. **State preservation**: Agent saves state between interactions

**Recommended**: Use AskUserQuestion tool within the agent - this is already used in the current /meta command and is the standard way to handle multi-turn interactions in Claude Code.

### 7. Current Component Inventory

From component-selection.md analysis:

| Type | Count | Examples |
|------|-------|----------|
| Commands | 9 | /task, /research, /plan, /implement, /meta, /review, /errors, /todo, /revise |
| Skills | 9 | skill-orchestrator, skill-researcher, skill-lean-research, skill-planner, etc. |
| Agents | 6 | general-research-agent, lean-research-agent, planner-agent, etc. |

**Note**: /meta is currently the only major command without skill/agent delegation.

### 8. Anti-Patterns to Avoid

Based on creating-skills.md and creating-agents.md:

1. **Don't load context eagerly in skill** - Use `context: fork`
2. **Don't execute logic in skill** - Delegate to agent
3. **Don't return plain text from agent** - Must return valid JSON
4. **Don't skip Stage 7 (status updates)** - Agent must update TODO.md/state.json
5. **Don't miss session_id in metadata** - Required for tracking

## Recommendations

### Primary Recommendation: Full Integration with Interactive Agent

1. **Create skill-meta** at `.claude/skills/skill-meta/SKILL.md`
   - Thin wrapper following established pattern
   - Validates mode and arguments
   - Delegates to meta-builder-agent

2. **Create meta-builder-agent** at `.claude/agents/meta-builder-agent.md`
   - Handles all three modes (interactive, prompt, analyze)
   - Uses AskUserQuestion for interactive stages
   - Loads component guides on-demand
   - Returns structured JSON with created tasks

3. **Update /meta command** to use Skill tool
   - Remove 400+ lines of direct execution logic
   - Add routing to skill-meta via Skill tool
   - Keep argument parsing and mode detection

4. **Add context loading references**
   - Update context index with /meta-specific loading patterns
   - Document which guides to load for each mode

### Secondary Recommendations

1. **Create /meta flow example** similar to research-flow-example.md
   - Document complete /meta execution path
   - Show interactive interview flow
   - Include task creation workflow

2. **Update component-selection.md** with /meta references
   - Add /meta as entry point for component creation
   - Link to creating-* guides

3. **Consider specialized sub-agents** for complex modes
   - meta-analyzer-agent for --analyze mode
   - meta-interview-agent for interactive mode
   - This allows focused optimization per mode

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Interactive flow may be disrupted | High | Use AskUserQuestion tool, test thoroughly |
| Agent may be too large | Medium | Consider splitting into specialized agents per mode |
| Context loading overhead | Low | Use lazy loading, load only needed guides |
| Breaking existing /meta users | Medium | Keep command interface identical, only change internals |

## References

- `.claude/commands/meta.md` - Current /meta implementation
- `.claude/docs/guides/component-selection.md` - Component decision guide
- `.claude/docs/guides/creating-skills.md` - Skill creation guide
- `.claude/docs/guides/creating-agents.md` - Agent creation guide
- `.claude/docs/examples/research-flow-example.md` - Integration example
- `specs/427_document_command_skill_subagent_framework/summaries/implementation-summary-20260112.md` - Task 427 summary

## Next Steps

1. Run /plan 429 to create implementation plan based on these findings
2. Plan should include:
   - Phase 1: Create skill-meta
   - Phase 2: Create meta-builder-agent
   - Phase 3: Update /meta command
   - Phase 4: Update context index
   - Phase 5: Create flow example documentation
   - Phase 6: Test all three modes

## Appendix: File Locations

**New Files to Create**:
- `.claude/skills/skill-meta/SKILL.md`
- `.claude/agents/meta-builder-agent.md`
- `.claude/docs/examples/meta-flow-example.md` (optional)

**Files to Modify**:
- `.claude/commands/meta.md` - Refactor to use Skill tool
- `.claude/context/index.md` - Add /meta context loading patterns
- `.claude/docs/guides/component-selection.md` - Add /meta references
