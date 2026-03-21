# Implementation Plan: Task #541

- **Task**: 541 - progressive_disclosure_refactor
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/541_progressive_disclosure_refactor/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task fixes the critical Skill/Task invocation confusion in the forked skill architecture. Research identified that skills using the custom `agent:` frontmatter field cause Claude to incorrectly use `Skill()` instead of `Task()` to invoke agents. The fix adds explicit Task tool invocation directives to all 7 forked skills, ensuring agents are properly spawned via the Task tool rather than invoked as skills.

### Research Integration

Key findings from research-001.md:
- The `agent:` field in skill frontmatter is a custom convention, not native Claude Code
- Claude pattern-matches `agent:` to Skill invocation instead of Task invocation
- 7 forked skills need explicit Task tool directives: skill-researcher, skill-lean-research, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation, skill-meta
- The fix requires adding bold warnings with exact Task tool invocation syntax

## Goals & Non-Goals

**Goals**:
- Add explicit Task tool invocation directives to all 7 forked skills
- Prevent Claude from using Skill() to invoke agents
- Document the Skill vs Task tool distinction clearly in each skill
- Maintain backward compatibility with existing skill structure

**Non-Goals**:
- Removing the `agent:` frontmatter field (would require larger refactor)
- Creating validation hooks or pre-commit checks
- Modifying agent files themselves
- Creating new documentation guides (deferred to later task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cached skill context in existing sessions | Medium | High | Document: start fresh sessions after update |
| Inconsistent directive wording across skills | Low | Medium | Use exact same template for all skills |
| Skill files have different structures | Low | Low | Adapt template to each skill's section 3 |

## Implementation Phases

### Phase 1: Research-Related Skills [NOT STARTED]

**Goal**: Update skill-researcher and skill-lean-research with explicit Task tool directives

**Tasks**:
- [ ] Update skill-researcher/SKILL.md section 3 with explicit Task tool directive
- [ ] Update skill-lean-research/SKILL.md section 3 with explicit Task tool directive
- [ ] Verify both skills specify correct agent names (general-research-agent, lean-research-agent)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md` - Add Task tool directive in section 3
- `.claude/skills/skill-lean-research/SKILL.md` - Add Task tool directive in section 3

**Verification**:
- Each skill has bold "CRITICAL" warning about using Task tool
- Agent name matches frontmatter agent field
- Warning includes explicit "DO NOT use Skill()" statement

---

### Phase 2: Planning Skill [NOT STARTED]

**Goal**: Update skill-planner with explicit Task tool directive

**Tasks**:
- [ ] Update skill-planner/SKILL.md section 3 with explicit Task tool directive
- [ ] Verify planner-agent is correctly specified

**Timing**: 15 minutes

**Files to modify**:
- `.claude/skills/skill-planner/SKILL.md` - Add Task tool directive in section 3

**Verification**:
- Skill has bold "CRITICAL" warning about using Task tool
- Agent name is planner-agent
- Warning includes explicit "DO NOT use Skill()" statement

---

### Phase 3: Implementation Skills [NOT STARTED]

**Goal**: Update skill-implementer, skill-lean-implementation, and skill-latex-implementation with explicit Task tool directives

**Tasks**:
- [ ] Update skill-implementer/SKILL.md section 3 with explicit Task tool directive
- [ ] Update skill-lean-implementation/SKILL.md section 3 with explicit Task tool directive
- [ ] Update skill-latex-implementation/SKILL.md section 3 with explicit Task tool directive
- [ ] Verify each skill specifies correct agent name

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - Add Task tool directive (general-implementation-agent)
- `.claude/skills/skill-lean-implementation/SKILL.md` - Add Task tool directive (lean-implementation-agent)
- `.claude/skills/skill-latex-implementation/SKILL.md` - Add Task tool directive (latex-implementation-agent)

**Verification**:
- Each skill has bold "CRITICAL" warning about using Task tool
- Agent names match their respective frontmatter agent fields
- Warning includes explicit "DO NOT use Skill()" statement

---

### Phase 4: Meta Skill and Validation [NOT STARTED]

**Goal**: Update skill-meta and perform final validation across all updated skills

**Tasks**:
- [ ] Update skill-meta/SKILL.md section 3 with explicit Task tool directive
- [ ] Verify meta-builder-agent is correctly specified
- [ ] Review all 7 updated skills for consistency
- [ ] Verify directive template is identical across all skills (except agent name)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-meta/SKILL.md` - Add Task tool directive (meta-builder-agent)

**Verification**:
- All 7 forked skills have identical directive structure
- Only the agent name varies between skills
- No skills reference incorrect agent names
- All use same warning language and format

---

## Testing & Validation

- [ ] Each skill file has the Task tool directive in the appropriate section
- [ ] Agent names in directives match frontmatter agent fields
- [ ] Warning text is bold and includes "CRITICAL" keyword
- [ ] "DO NOT use Skill()" statement is present in each directive
- [ ] Directive includes subagent_type parameter specification

## Artifacts & Outputs

- `specs/541_progressive_disclosure_refactor/plans/implementation-001.md` (this file)
- `specs/541_progressive_disclosure_refactor/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- 7 modified skill files in `.claude/skills/`

## Rollback/Contingency

If the changes cause workflow failures:
1. Revert all 7 skill files using git: `git checkout HEAD~1 -- .claude/skills/*/SKILL.md`
2. Start fresh session to clear cached context
3. Re-analyze the issue with updated research

## Appendix: Directive Template

The following template will be added to section 3 of each forked skill:

```markdown
### 3. Invoke Subagent

**CRITICAL**: You MUST use the Task tool (NOT Skill tool) to invoke the subagent.

The `agent` field in frontmatter specifies the subagent_type for the Task tool.

Call Task tool with:
- subagent_type: "{AGENT_NAME}"
- prompt: Include task context, delegation context, and focus prompt

WARNING: Do NOT use Skill() for agents - agents are in .claude/agents/, not .claude/skills/
```

Where `{AGENT_NAME}` is replaced with the appropriate agent name for each skill.
