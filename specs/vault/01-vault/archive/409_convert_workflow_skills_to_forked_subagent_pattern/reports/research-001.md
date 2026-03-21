# Research Report: Task #409

**Task**: Convert workflow skills to forked subagent pattern
**Date**: 2026-01-12
**Focus**: Understanding current skill patterns and designing forked subagent architecture

## Summary

Researched the current skill system architecture and identified the changes needed to convert skills to thin wrappers that spawn forked subagents. The current skills contain significant execution logic inline, which consumes parent context. The solution is to add `context: fork` and `agent:` fields to skill frontmatter, enabling skills to delegate token-heavy work to subagents that return structured JSON.

## Current Architecture Findings

### Skill File Structure

Current skills are located at `.claude/skills/skill-{name}/SKILL.md` with this frontmatter pattern:

```yaml
---
name: skill-{name}
description: {description}
allowed-tools: {tool list}
context:
  - {context file paths loaded eagerly}
---
```

### Skills in Scope for Conversion

1. **skill-lean-research** - Lean 4/Mathlib research using MCP tools
2. **skill-researcher** - General research using web/codebase search
3. **skill-planner** - Implementation plan creation
4. **skill-implementer** - General implementation execution
5. **skill-lean-implementation** - Lean proof implementation
6. **skill-latex-implementation** - LaTeX document implementation

### Current Context Loading Pattern

Skills currently load context **eagerly** via the `context:` array:

```yaml
context:
  - .claude/context/project/lean4/tools/mcp-tools-guide.md
  - .claude/context/project/lean4/tools/leansearch-api.md
  - .claude/context/project/lean4/tools/loogle-api.md
```

This means all listed context files are loaded into the parent conversation context when the skill is invoked, consuming tokens even if not all content is needed.

### Existing Return Format Standard

A comprehensive return format already exists in `.claude/context/core/formats/subagent-return.md`:

```json
{
  "status": "completed|partial|failed|blocked",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [
    {
      "type": "plan|report|summary|implementation|documentation",
      "path": "relative/path/to/artifact.md",
      "summary": "Brief description of artifact"
    }
  ],
  "metadata": {
    "session_id": "sess_1735460684_a1b2c3",
    "duration_seconds": 123,
    "agent_type": "planner|researcher|implementer|...",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "plan", "planner"]
  },
  "errors": [...],
  "next_steps": "What user should do next"
}
```

### Delegation Infrastructure

Existing delegation infrastructure in `.claude/context/core/orchestration/delegation.md` includes:
- Session ID tracking (`sess_{timestamp}_{random}`)
- Delegation depth limits (max 3 levels)
- Cycle detection via delegation path
- Timeout enforcement (research: 3600s, implementation: 7200s)
- Return validation

## Proposed Architecture

### New Skill Frontmatter Format

Convert skills to thin wrappers with new fields:

```yaml
---
name: skill-lean-research
description: Research Lean 4 and Mathlib for theorem proving tasks.
allowed-tools: Task  # Only Task tool needed (for delegation)
context: fork  # Signals to NOT load context - delegate instead
agent: lean-research-agent  # Subagent to spawn
---

# Thin wrapper content follows...
```

### Forked Subagent Pattern

1. **Skill receives invocation** from orchestrator/command
2. **Skill validates inputs** (task number, focus prompt)
3. **Skill invokes subagent** via Task tool with:
   - Task context (number, description, language)
   - Delegation context (session_id, depth, path)
   - Focus prompt if provided
4. **Subagent executes** (loads its own context lazily)
5. **Subagent returns** standardized JSON
6. **Skill validates return** and propagates to caller

### Subagent Files

New subagent files would be created at `.claude/agents/{name}.md` with:
- Full frontmatter per `frontmatter.md` standard
- Tool permissions specific to agent type
- Lazy context loading via `@-references`
- Execution workflow
- Return format specification

### Lazy Context Loading

Subagents load context on-demand using `@-references`:

```markdown
Load the following context as needed:
- @.claude/context/project/lean4/tools/mcp-tools-guide.md
- @.claude/context/project/lean4/tools/leansearch-api.md

Use @.claude/context/index.md to discover additional context files.
```

## Standardized Return Format

Based on existing `subagent-return.md`, the artifact return format should be:

### For Research Operations

```json
{
  "status": "completed",
  "summary": "Found N relevant theorems for proof approach",
  "artifacts": [
    {
      "type": "research",
      "path": "specs/{N}_{SLUG}/reports/research-{NNN}.md",
      "summary": "Lean research report with theorem findings"
    }
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "lean-research-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "lean-research-agent"]
  },
  "next_steps": "Run /plan {N} to create implementation plan"
}
```

### For Planning Operations

```json
{
  "status": "completed",
  "summary": "Created {N}-phase implementation plan",
  "artifacts": [
    {
      "type": "plan",
      "path": "specs/{N}_{SLUG}/plans/implementation-{NNN}.md",
      "summary": "Implementation plan with phases and steps"
    }
  ],
  "metadata": {...},
  "next_steps": "Run /implement {N} to execute the plan"
}
```

### For Implementation Operations

```json
{
  "status": "completed|partial",
  "summary": "Implemented phases 1-N of plan",
  "artifacts": [
    {
      "type": "implementation",
      "path": "path/to/modified/file.lean",
      "summary": "Implemented theorem X"
    },
    {
      "type": "summary",
      "path": "specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md",
      "summary": "Implementation completion summary"
    }
  ],
  "metadata": {...},
  "next_steps": "Task complete" | "Run /implement {N} to resume from phase M"
}
```

## Conversion Steps

### Phase 1: Add Subagent Files

Create `.claude/agents/` directory with:
1. `lean-research-agent.md` - Lean research with MCP tools
2. `general-research-agent.md` - General web/codebase research
3. `planner-agent.md` - Implementation plan creation
4. `lean-implementation-agent.md` - Lean proof implementation
5. `general-implementation-agent.md` - General file implementation
6. `latex-implementation-agent.md` - LaTeX document implementation

### Phase 2: Convert Skill Frontmatter

Update each skill's frontmatter:
1. Change `context:` array to `context: fork`
2. Add `agent:` field with target subagent name
3. Change `allowed-tools:` to just `Task` (for delegation)

### Phase 3: Convert Skill Body

Replace detailed execution logic with thin wrapper:
1. Input validation (task number, focus)
2. Context preparation (from state.json lookup)
3. Subagent invocation via Task tool
4. Return validation and propagation

### Phase 4: Update Orchestration

Ensure orchestrator/commands properly handle:
1. Skill invocation with fork context
2. Subagent return parsing
3. Status updates based on return
4. Artifact linking in TODO.md

## Benefits

1. **Token Efficiency**: Context loaded only in subagent, not parent
2. **Isolation**: Subagent context doesn't bloat main conversation
3. **Reusability**: Same subagent usable by multiple skills
4. **Testability**: Subagents can be tested independently
5. **Maintainability**: Separation of concerns (skill = routing, agent = execution)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Subagent return validation failures | High | Enforce JSON format instruction per delegation.md |
| Context loading failures in subagent | Medium | Fallback to inline context if @-reference fails |
| Increased delegation depth | Low | Max depth of 3 allows skill→subagent chain |
| Session tracking complexity | Medium | Use existing session_id tracking infrastructure |

## Recommendations

1. **Start with research skills** - They have clearest input/output boundaries
2. **Use existing return format** - Don't reinvent the wheel
3. **Create agents directory first** - Task 411-414 are dependencies
4. **Keep skills minimal** - Validation + delegation only
5. **Update CLAUDE.md** - Document new pattern for future reference

## Dependencies

- Task 410: Remove eager context loading from skill frontmatter (prerequisite)
- Task 411: Create lean-research-agent subagent
- Task 412: Create general-research-agent subagent
- Task 413: Create implementation-agent subagents
- Task 414: Create planner-agent subagent

## Next Steps

1. Create implementation plan for task 409
2. Proceed with task 410 to remove eager context loading first
3. Create subagent files (tasks 411-414)
4. Convert skills to thin wrappers

## References

- `.claude/context/core/formats/subagent-return.md` - Return format standard
- `.claude/context/core/formats/frontmatter.md` - Frontmatter standard
- `.claude/context/core/orchestration/delegation.md` - Delegation patterns
- `.claude/context/core/templates/subagent-template.md` - Subagent template
- `.claude/skills/skill-*/SKILL.md` - Current skill implementations
