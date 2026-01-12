# Research Report: Task #427

**Task**: 427 - Document command, skill, and subagent framework
**Date**: 2026-01-12
**Focus**: Systematically document the framework for using commands, skills, and subagents in conjunction

## Summary

This research analyzed the existing command, skill, and subagent architecture in ProofChecker's `.claude/` system. The framework implements a three-layer delegation pattern with well-defined responsibilities at each layer. While extensive technical documentation exists in `.claude/context/` and `.claude/ARCHITECTURE.md`, there are gaps in user-facing documentation and clear guidance on when and how to use each component type.

## Findings

### 1. Current Architecture: Three-Layer Delegation Pattern

The ProofChecker system uses a three-layer architecture:

**Layer 1: Commands** (`.claude/commands/*.md`)
- User-invocable via `/command` syntax (e.g., `/research 427`)
- Parse and validate user arguments
- Handle status updates (preflight/postflight)
- Route to appropriate skills based on task language
- Current count: 9 commands

**Layer 2: Skills** (`.claude/skills/skill-*/SKILL.md`)
- Specialized execution agents invoked by commands
- Use "thin wrapper" pattern - validate inputs, delegate to subagents
- Use `context: fork` pattern for token efficiency
- Current count: 9 skills

**Layer 3: Agents** (`.claude/agents/*.md`)
- Full execution agents spawned by skills via Task tool
- Load domain-specific context
- Execute actual work and create artifacts
- Return standardized JSON format
- Current count: 6 agents

### 2. Component Relationships

```
User Command → Command File → Skill → Agent
      ↓               ↓           ↓        ↓
  "/research 427"  research.md  skill-researcher  general-research-agent
                                skill-lean-research  lean-research-agent
```

**Routing Decision Chain**:
1. Command parses task number from `$ARGUMENTS`
2. Command looks up task language from `state.json`
3. Command invokes appropriate skill based on language
4. Skill delegates to corresponding agent via Task tool
5. Agent executes, creates artifacts, returns JSON

### 3. Key Patterns

#### 3.1 Thin Wrapper Skill Pattern

Skills use `context: fork` to avoid loading context in parent conversation:

```yaml
---
name: skill-researcher
allowed-tools: Task
context: fork
agent: general-research-agent
---
```

Benefits:
- Token efficiency (context loaded only in forked subagent)
- Isolation (subagent context doesn't bloat parent)
- Reusability (same agent callable from multiple skills)

#### 3.2 Standardized Return Format

All agents return JSON matching `subagent-return.md`:

```json
{
  "status": "completed|partial|failed|blocked",
  "summary": "Brief summary (<100 tokens)",
  "artifacts": [{"type": "...", "path": "...", "summary": "..."}],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "...",
    "delegation_depth": N,
    "delegation_path": [...]
  },
  "errors": [],
  "next_steps": "..."
}
```

#### 3.3 Language-Based Routing

| Task Language | Research Skill | Implementation Skill |
|--------------|----------------|---------------------|
| lean | skill-lean-research | skill-lean-implementation |
| latex | skill-researcher | skill-latex-implementation |
| general | skill-researcher | skill-implementer |
| meta | skill-researcher | skill-implementer |
| markdown | skill-researcher | skill-implementer |

### 4. Existing Documentation

**Strong Documentation** (in `.claude/context/core/`):
- `orchestration/architecture.md` - Detailed three-layer pattern (746 lines)
- `orchestration/delegation.md` - Delegation safety patterns (851 lines)
- `formats/subagent-return.md` - Return format schema (298 lines)
- `templates/thin-wrapper-skill.md` - Skill template (259 lines)

**User-Facing Documentation** (in `.claude/docs/`):
- `README.md` - Good overview but slightly outdated
- `guides/creating-commands.md` - Command creation guide

**Architecture Documentation**:
- `.claude/ARCHITECTURE.md` - System architecture (975 lines)
- `.claude/CLAUDE.md` - Quick reference with skill mapping

### 5. Documentation Gaps Identified

**Gap 1: Skill Creation Guide**
- No dedicated guide for creating new skills
- Existing command guide doesn't cover skills adequately

**Gap 2: Agent Creation Guide**
- Template exists in `.claude/docs/templates/agent-template.md`
- Missing step-by-step guide for creating agents

**Gap 3: Component Selection Guide**
- No clear guidance on when to create a command vs skill vs agent
- Decision tree needed for new capability development

**Gap 4: Integration Examples**
- Technical docs are comprehensive but abstract
- Need concrete end-to-end examples

**Gap 5: Outdated References**
- Some docs reference old patterns (e.g., `.claude/agent/` path)
- Current paths are `.claude/skills/` and `.claude/agents/`

### 6. Directory Structure Analysis

```
.claude/
├── commands/           # 9 user commands
│   ├── research.md
│   ├── plan.md
│   ├── implement.md
│   └── ... (6 more)
├── skills/             # 9 specialized skills
│   ├── skill-orchestrator/SKILL.md
│   ├── skill-researcher/SKILL.md
│   ├── skill-lean-research/SKILL.md
│   └── ... (6 more)
├── agents/             # 6 execution agents
│   ├── general-research-agent.md
│   ├── lean-research-agent.md
│   ├── planner-agent.md
│   └── ... (3 more)
├── context/            # Domain knowledge and standards
│   ├── core/           # Reusable patterns
│   └── project/        # ProofChecker-specific
├── docs/               # User documentation
├── rules/              # Automatic behaviors
└── specs/              # Task artifacts and state
```

### 7. Command-Skill-Agent Mapping

| Command | Skill(s) Used | Agent(s) Spawned |
|---------|--------------|------------------|
| /research | skill-lean-research, skill-researcher | lean-research-agent, general-research-agent |
| /plan | skill-planner | planner-agent |
| /implement | skill-lean-implementation, skill-implementer, skill-latex-implementation | lean-implementation-agent, general-implementation-agent, latex-implementation-agent |
| /task | skill-status-sync | (direct execution) |
| /revise | skill-planner | planner-agent |
| /review | (direct execution) | - |
| /errors | (direct execution) | - |
| /todo | (direct execution) | - |
| /meta | (direct execution) | - |

## Recommendations

### 1. Create Component Selection Guide

New file: `.claude/docs/guides/component-selection.md`

Decision tree:
- Need user invocation via `/command`? → Create Command
- Need reusable execution logic? → Create Skill + Agent pair
- Need specialized domain handling? → Create new Agent variant

### 2. Create Skill Creation Guide

New file: `.claude/docs/guides/creating-skills.md`

Content:
- Thin wrapper pattern explanation
- Frontmatter format specification
- Context loading via fork pattern
- Return validation requirements
- Complete example

### 3. Update Existing Documentation

- `.claude/docs/README.md`: Add skill and agent counts
- `.claude/docs/guides/creating-commands.md`: Reference skill delegation
- Update path references from `.claude/agent/` to `.claude/agents/`

### 4. Create Integration Examples

Add concrete examples showing:
- How `/research 427` flows through all three layers
- How language routing determines skill/agent selection
- How artifacts are created and returned

### 5. Consolidate Context Index

The `.claude/context/index.md` could benefit from a section specifically about skills and agents.

## Decisions

1. **Documentation location**: New user guides should go in `.claude/docs/guides/`
2. **Context updates**: Technical standards should update `.claude/context/core/` files
3. **Template updates**: Maintain templates in `.claude/docs/templates/`
4. **No CLAUDE.md changes**: Current skill architecture section is adequate

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Documentation drift | Medium | Include version numbers in docs |
| Outdated examples | High | Use real task numbers in examples |
| Incomplete coverage | Medium | Create checklist of required docs |

## Appendix

### A. Files Examined

**Commands**:
- `.claude/commands/research.md` (175 lines)
- `.claude/commands/plan.md`, `/implement.md`, etc.

**Skills**:
- `.claude/skills/skill-researcher/SKILL.md` (107 lines)
- `.claude/skills/skill-orchestrator/SKILL.md` (111 lines)
- All 9 skill directories

**Agents**:
- `.claude/agents/general-research-agent.md` (392 lines)
- `.claude/agents/lean-research-agent.md`, etc.

**Context**:
- `.claude/context/core/orchestration/architecture.md` (746 lines)
- `.claude/context/core/orchestration/delegation.md` (851 lines)
- `.claude/context/core/templates/thin-wrapper-skill.md` (259 lines)
- `.claude/context/core/formats/subagent-return.md` (298 lines)

**Documentation**:
- `.claude/docs/README.md` (342 lines)
- `.claude/docs/guides/creating-commands.md` (322 lines)
- `.claude/ARCHITECTURE.md` (975 lines)

### B. Search Queries Used

1. Glob patterns for skills, agents, commands
2. Content analysis of key files
3. State.json for task 425 dependencies

## Next Steps

1. Run `/plan 427` to create implementation plan
2. Prioritize component selection guide and skill creation guide
3. Update outdated path references
4. Add integration examples
