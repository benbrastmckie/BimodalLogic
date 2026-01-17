# Implementation Plan: Task #539 (Revision 002)

- **Task**: 539 - test_validate_model_tiering
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: 535, 536, 537, 538
- **Research Inputs**: specs/539_test_validate_model_tiering/reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This revision addresses the command-skill-agent architecture pattern correctly. The root cause identified in research-002.md is that skills with `agent:` frontmatter lack explicit Task tool invocation instructions, causing Claude to incorrectly call `Skill(agent-name)` instead of `Task(agent-name)`.

### Architecture Context

The system follows a three-tier delegation pattern:

```
Command (/.claude/commands/)
    │
    ▼
Skill (/.claude/skills/) ── Preflight → Agent Delegation → Postflight
    │
    ▼
Agent (/.claude/agents/)
```

**Key Distinction**:
- **Skills** are invoked via the `Skill` tool
- **Agents** are invoked via the `Task` tool with `subagent_type`

The `agent:` frontmatter field documents which agent a skill delegates to, but Claude misinterprets it as a target for the Skill tool.

### Research Integration

Key findings from research-002.md:
- Root cause: Skills say "Invoke X via Task tool" in prose, but Claude pattern-matches `agent:` frontmatter
- All crash logs show `Skill(general-research-agent)` when they should show `Task(general-research-agent)`
- Solution: Add explicit, unambiguous Task tool invocation with negative examples

## Goals & Non-Goals

**Goals**:
- Add explicit Task tool invocation block to Section 3 of all 7 forked skills
- Include **CRITICAL** directive with bold formatting
- Include **DO NOT** warning with explicit negative example
- Document the command-skill-agent pattern distinction clearly

**Non-Goals**:
- Removing the `agent:` frontmatter field (it serves as documentation)
- Changing the overall architecture
- Modifying agent files themselves
- Automated testing (separate future task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fix is not prominent enough | High | Medium | Use **CRITICAL** and **DO NOT** with bold/caps |
| Miss a skill file | High | Low | Enumerate all 7 files explicitly in checklist |
| Old sessions have cached context | Medium | High | Document: start fresh sessions after fix |
| Prose still ambiguous | Medium | Low | Include explicit tool name AND negative example |

## Implementation Phases

### Phase 1: Create Task Invocation Directive Block [COMPLETED]

**Goal**: Define the standard directive block that will be added to all skills

**Tasks**:
- [ ] Create standard directive block for Section 3 "Invoke Subagent"
- [ ] Include explicit Task tool syntax with subagent_type parameter
- [ ] Include DO NOT use Skill() warning with explanation
- [ ] Test readability and clarity

**Timing**: 15 minutes

**Directive Template**:
```markdown
### 3. Invoke Subagent

**CRITICAL**: You MUST use the **Task** tool (NOT the Skill tool) to invoke the subagent.

**Tool Selection**:
| Directory | Tool | Invocation |
|-----------|------|------------|
| `.claude/skills/` | Skill tool | `Skill("skill-name")` |
| `.claude/agents/` | **Task tool** | `Task(subagent_type="{agent-name}")` |

The `agent` field in frontmatter specifies which agent to invoke via the Task tool.

**Invoke the Task tool NOW** with:
- `subagent_type`: "{agent-name-from-frontmatter}"
- `description`: "Execute {operation} for task {N}"
- `prompt`: Include task context, delegation context, and focus/plan path

**DO NOT** use `Skill("{agent-name}")` - agents are in `.claude/agents/`, NOT `.claude/skills/`.

The subagent will:
{existing bullet points}
```

**Verification**:
- Template is clear and unambiguous
- Includes both positive (what to do) and negative (what not to do) instructions
- Uses formatting (bold, caps) to emphasize critical points

---

### Phase 2: Update Research Skills [COMPLETED]

**Goal**: Apply directive block to skill-researcher and skill-lean-research

**Tasks**:
- [ ] Update `.claude/skills/skill-researcher/SKILL.md` Section 3
- [ ] Update `.claude/skills/skill-lean-research/SKILL.md` Section 3

**Timing**: 20 minutes

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md` - Replace Section 3 with directive block (agent: general-research-agent)
- `.claude/skills/skill-lean-research/SKILL.md` - Replace Section 3 with directive block (agent: lean-research-agent)

**Verification**:
- `grep -l "CRITICAL.*Task tool" .claude/skills/skill-researcher/SKILL.md` returns match
- `grep -l "DO NOT.*Skill" .claude/skills/skill-researcher/SKILL.md` returns match
- Same for skill-lean-research

---

### Phase 3: Update Planning Skill [COMPLETED]

**Goal**: Apply directive block to skill-planner

**Tasks**:
- [ ] Update `.claude/skills/skill-planner/SKILL.md` Section 3

**Timing**: 10 minutes

**Files to modify**:
- `.claude/skills/skill-planner/SKILL.md` - Replace Section 3 with directive block (agent: planner-agent)

**Verification**:
- `grep -l "CRITICAL.*Task tool" .claude/skills/skill-planner/SKILL.md` returns match
- `grep -l "DO NOT.*Skill" .claude/skills/skill-planner/SKILL.md` returns match

---

### Phase 4: Update Implementation Skills [COMPLETED]

**Goal**: Apply directive block to skill-implementer, skill-lean-implementation, skill-latex-implementation

**Tasks**:
- [ ] Update `.claude/skills/skill-implementer/SKILL.md` Section 3
- [ ] Update `.claude/skills/skill-lean-implementation/SKILL.md` Section 3
- [ ] Update `.claude/skills/skill-latex-implementation/SKILL.md` Section 3

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - agent: general-implementation-agent
- `.claude/skills/skill-lean-implementation/SKILL.md` - agent: lean-implementation-agent
- `.claude/skills/skill-latex-implementation/SKILL.md` - agent: latex-implementation-agent

**Verification**:
- All three files have CRITICAL directive
- All three files have DO NOT warning

---

### Phase 5: Update Meta Skill [IN PROGRESS]

**Goal**: Apply directive block to skill-meta

**Tasks**:
- [ ] Update `.claude/skills/skill-meta/SKILL.md` Section 3

**Timing**: 10 minutes

**Files to modify**:
- `.claude/skills/skill-meta/SKILL.md` - agent: meta-builder-agent

**Verification**:
- `grep -l "CRITICAL.*Task tool" .claude/skills/skill-meta/SKILL.md` returns match
- `grep -l "DO NOT.*Skill" .claude/skills/skill-meta/SKILL.md` returns match

---

### Phase 6: Verification and Documentation [NOT STARTED]

**Goal**: Verify all fixes are applied and update architecture documentation

**Tasks**:
- [ ] Run grep to verify all 7 skills have CRITICAL directive
- [ ] Run grep to verify all 7 skills have DO NOT warning
- [ ] Verify no skill uses `Skill(agent-name)` pattern in examples
- [ ] Update CLAUDE.md "Skill Architecture" section with tool selection table
- [ ] Create implementation summary

**Timing**: 15 minutes

**Verification Commands**:
```bash
# All 7 forked skills should match
grep -l "CRITICAL.*Task tool" .claude/skills/*/SKILL.md | wc -l
# Expected: 7

grep -l "DO NOT.*Skill" .claude/skills/*/SKILL.md | wc -l
# Expected: 7

# Verify tool selection table is present
grep -l "Tool Selection" .claude/skills/*/SKILL.md | wc -l
# Expected: 7
```

**Documentation Update**:
Add to CLAUDE.md under "Skill Architecture":
```markdown
### Tool Selection for Delegation

| Target Type | Directory | Tool | Example |
|-------------|-----------|------|---------|
| Skill | `.claude/skills/` | Skill | `Skill("skill-researcher")` |
| Agent | `.claude/agents/` | Task | `Task(subagent_type="general-research-agent")` |

**CRITICAL**: Skills delegate to agents via the **Task** tool, not the Skill tool.
```

## Testing & Validation

- [ ] Grep: All 7 forked skills have explicit Task tool directive
- [ ] Grep: All 7 forked skills have DO NOT Skill warning
- [ ] Grep: All 7 forked skills have Tool Selection table
- [ ] Manual: Section 3 in each skill is unambiguous
- [ ] Fresh session: `/research` shows `Task(general-research-agent)` not `Skill()`

## Artifacts & Outputs

- `.claude/skills/skill-researcher/SKILL.md` - Updated Section 3
- `.claude/skills/skill-lean-research/SKILL.md` - Updated Section 3
- `.claude/skills/skill-planner/SKILL.md` - Updated Section 3
- `.claude/skills/skill-implementer/SKILL.md` - Updated Section 3
- `.claude/skills/skill-lean-implementation/SKILL.md` - Updated Section 3
- `.claude/skills/skill-latex-implementation/SKILL.md` - Updated Section 3
- `.claude/skills/skill-meta/SKILL.md` - Updated Section 3
- `.claude/CLAUDE.md` - Updated skill architecture section
- `specs/539_test_validate_model_tiering/summaries/implementation-summary-20260117.md`

## Rollback/Contingency

If the fix causes issues:
1. Git revert the commits for this task
2. Skills will return to their previous state
3. Alternative approach: Remove `agent:` frontmatter entirely and embed agent name only in directive body

## Appendix: Affected Skills Reference

| Skill | Agent (frontmatter) | Section 3 Status |
|-------|---------------------|------------------|
| skill-researcher | general-research-agent | Needs update |
| skill-lean-research | lean-research-agent | Needs update |
| skill-planner | planner-agent | Needs update |
| skill-implementer | general-implementation-agent | Needs update |
| skill-lean-implementation | lean-implementation-agent | Needs update |
| skill-latex-implementation | latex-implementation-agent | Needs update |
| skill-meta | meta-builder-agent | Needs update |

## Appendix: Command-Skill-Agent Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│ USER: /research 541                                                     │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ COMMAND: .claude/commands/research.md                                   │
│                                                                         │
│ CHECKPOINT 1: VALIDATE                                                  │
│   - Generate session_id                                                 │
│   - Lookup task in state.json                                           │
│   - Validate status allows research                                     │
│                                                                         │
│ CHECKPOINT 2: DELEGATE                                                  │
│   - Route by language (lean → skill-lean-research, else → skill-researcher) │
│   - Invoke: Skill("skill-researcher", args)                             │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                        Skill tool invocation
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ SKILL: .claude/skills/skill-researcher/SKILL.md                         │
│                                                                         │
│ Section 0: PREFLIGHT                                                    │
│   - Update state.json status → "researching"                            │
│   - Update TODO.md marker → [RESEARCHING]                               │
│                                                                         │
│ Section 3: INVOKE SUBAGENT                                              │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │ **CRITICAL**: Use Task tool (NOT Skill tool)                    │   │
│   │ Invoke: Task(subagent_type="general-research-agent", prompt)    │   │
│   │ DO NOT use Skill("general-research-agent")                      │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│ Section 5: POSTFLIGHT                                                   │
│   - Update state.json status → "researched"                             │
│   - Update TODO.md marker → [RESEARCHED]                                │
│   - Link artifact                                                       │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                        Task tool invocation
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ AGENT: .claude/agents/general-research-agent.md                         │
│                                                                         │
│ - Load context files                                                    │
│ - Perform research using tools                                          │
│ - Create research report artifact                                       │
│ - Return standardized JSON result                                       │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ COMMAND: .claude/commands/research.md                                   │
│                                                                         │
│ CHECKPOINT 3: COMMIT                                                    │
│   - git add -A && git commit                                            │
│   - Output success message                                              │
└─────────────────────────────────────────────────────────────────────────┘
```

**Key Insight**: The Skill tool invokes code from `.claude/skills/`. The Task tool spawns subagents from `.claude/agents/`. These are different directories and different tools.
