# Implementation Plan: Task #539

- **Task**: 539 - test_validate_model_tiering
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: 535, 536, 537, 538
- **Research Inputs**: specs/539_test_validate_model_tiering/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Fix the skill-to-agent invocation bug identified in research-002.md. All 7 forked skills with `agent:` frontmatter are using ambiguous prose instructions that cause Claude to incorrectly invoke agents via the Skill tool instead of the Task tool. The fix adds explicit, unambiguous Task tool invocation directives with bold warnings to prevent this pattern-matching error.

### Research Integration

Key findings from research-002.md:
- Root cause: Skills say "Invoke X via Task tool" in prose, but Claude pattern-matches the `agent:` frontmatter field to `Skill(agent-name)` instead
- All `/research` failures in crash logs show `Skill(general-research-agent)` when they should show `Task(general-research-agent)`
- Solution: Add explicit "CRITICAL: You MUST use the Task tool" directives with DO NOT warnings

## Goals & Non-Goals

**Goals**:
- Add explicit Task tool invocation instructions to all 7 affected skill files
- Use bold/caps formatting for critical directives to prevent misinterpretation
- Include explicit "DO NOT use Skill()" warnings
- Maintain backward compatibility with existing skill structure

**Non-Goals**:
- Removing the `agent:` frontmatter field (it serves as documentation)
- Changing the overall skill architecture
- Modifying agent files themselves
- Adding automated testing (separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fix is not prominent enough | High | Medium | Use **CRITICAL** and **DO NOT** formatting |
| Miss a skill file | High | Low | Enumerate all 7 files explicitly in checklist |
| Old sessions have cached context | Medium | High | Document: start fresh sessions after fix |
| Prose still ambiguous | Medium | Low | Include explicit tool name and negative example |

## Implementation Phases

### Phase 1: Fix Research Skills [NOT STARTED]

**Goal**: Update skill-researcher and skill-lean-research with explicit Task tool invocation

**Tasks**:
- [ ] Update skill-researcher/SKILL.md Section 3 with explicit Task tool directive
- [ ] Update skill-lean-research/SKILL.md Section 3 with explicit Task tool directive

**Timing**: 20 minutes

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md` - Add explicit Task tool instruction at Section 3
- `.claude/skills/skill-lean-research/SKILL.md` - Add explicit Task tool instruction at Section 3

**Verification**:
- Grep for "CRITICAL" in modified files
- Grep for "DO NOT" in modified files
- Ensure Task tool is explicitly mentioned

---

### Phase 2: Fix Planning Skill [NOT STARTED]

**Goal**: Update skill-planner with explicit Task tool invocation

**Tasks**:
- [ ] Update skill-planner/SKILL.md Section 3 with explicit Task tool directive

**Timing**: 10 minutes

**Files to modify**:
- `.claude/skills/skill-planner/SKILL.md` - Add explicit Task tool instruction at Section 3

**Verification**:
- Grep for "CRITICAL" in modified file
- Grep for "DO NOT" in modified file

---

### Phase 3: Fix Implementation Skills [NOT STARTED]

**Goal**: Update skill-implementer, skill-lean-implementation, and skill-latex-implementation

**Tasks**:
- [ ] Update skill-implementer/SKILL.md Section 3 with explicit Task tool directive
- [ ] Update skill-lean-implementation/SKILL.md Section 3 with explicit Task tool directive
- [ ] Update skill-latex-implementation/SKILL.md Section 3 with explicit Task tool directive

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - Add explicit Task tool instruction at Section 3
- `.claude/skills/skill-lean-implementation/SKILL.md` - Add explicit Task tool instruction at Section 3
- `.claude/skills/skill-latex-implementation/SKILL.md` - Add explicit Task tool instruction at Section 3

**Verification**:
- Grep for "CRITICAL" in all three files
- Grep for "DO NOT" in all three files

---

### Phase 4: Fix Meta Skill [NOT STARTED]

**Goal**: Update skill-meta with explicit Task tool invocation

**Tasks**:
- [ ] Update skill-meta/SKILL.md Section 3 with explicit Task tool directive

**Timing**: 10 minutes

**Files to modify**:
- `.claude/skills/skill-meta/SKILL.md` - Add explicit Task tool instruction at Section 3

**Verification**:
- Grep for "CRITICAL" in modified file
- Grep for "DO NOT" in modified file

---

### Phase 5: Verification and Documentation [NOT STARTED]

**Goal**: Verify all fixes are applied and document the pattern for future skills

**Tasks**:
- [ ] Run grep to verify all 7 skills have CRITICAL directive
- [ ] Run grep to verify all 7 skills have DO NOT warning
- [ ] Verify no skill uses `Skill(agent-name)` pattern in examples

**Timing**: 10 minutes

**Verification**:
- `grep -r "CRITICAL.*Task tool" .claude/skills/*/SKILL.md` returns 7 matches
- `grep -r "DO NOT.*Skill" .claude/skills/*/SKILL.md` returns 7 matches
- All forked skills (context: fork) have explicit Task tool instructions

## Testing & Validation

- [ ] Grep verification: All 7 skills have explicit Task tool directive
- [ ] Grep verification: All 7 skills have DO NOT Skill warning
- [ ] Manual review: Section 3 in each skill is unambiguous
- [ ] Fresh session test: `/research` command should show `Task(general-research-agent)` not `Skill(general-research-agent)` (requires new Claude Code session)

## Artifacts & Outputs

- `.claude/skills/skill-researcher/SKILL.md` - Updated with explicit Task directive
- `.claude/skills/skill-lean-research/SKILL.md` - Updated with explicit Task directive
- `.claude/skills/skill-planner/SKILL.md` - Updated with explicit Task directive
- `.claude/skills/skill-implementer/SKILL.md` - Updated with explicit Task directive
- `.claude/skills/skill-lean-implementation/SKILL.md` - Updated with explicit Task directive
- `.claude/skills/skill-latex-implementation/SKILL.md` - Updated with explicit Task directive
- `.claude/skills/skill-meta/SKILL.md` - Updated with explicit Task directive
- `specs/539_test_validate_model_tiering/summaries/implementation-summary-20260117.md` - Completion summary

## Rollback/Contingency

If the fix causes issues:
1. Git revert the commits for this task
2. Skills will return to their previous (broken) state
3. Alternative approach: Remove `agent:` frontmatter entirely and embed agent name in instruction body only

## Appendix: Fix Template

The following text block should be added to Section 3 of each affected skill, replacing the current vague prose:

```markdown
### 3. Invoke Subagent

**CRITICAL**: You MUST use the **Task** tool (NOT the Skill tool) to spawn the subagent.

The `agent` field in frontmatter specifies the `subagent_type` for the Task tool.

**Invocation**:
```
Task tool with subagent_type: "{agent-name}"
```

**DO NOT** use `Skill({agent-name})` - agents are in `.claude/agents/`, not `.claude/skills/`.

Include in the Task prompt:
- Task context (number, name, description, language)
- Delegation context (session_id, depth, path)
- Focus prompt or plan path (as applicable)

The subagent will:
{existing bullet points about what subagent does}
```
