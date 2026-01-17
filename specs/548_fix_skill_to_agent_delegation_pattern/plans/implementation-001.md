# Implementation Plan: Task #548

- **Task**: 548 - fix_skill_to_agent_delegation_pattern
- **Status**: [NOT STARTED]
- **Effort**: 2-3 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/548_fix_skill_to_agent_delegation_pattern/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task fixes the root cause of skill-to-agent delegation failures by adding explicit Task tool invocation directives to all 7 forked skills. Currently, skills use ambiguous prose instructions like "Invoke `agent-name` via Task tool with...", which causes Claude to call `Skill()` instead of `Task()`. The fix adds CRITICAL directives with explicit tool parameters, DO NOT warnings, and clear explanations of why agents require the Task tool (not Skill tool).

### Research Integration

Key findings from research-001.md integrated:
- Root cause: Ambiguous prose instructions cause Claude to pattern-match to Skill() instead of Task()
- 7 skills affected: skill-researcher, skill-lean-research, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation, skill-meta
- Fix approach: Replace "Invoke `agent-name` via Task tool" with explicit CRITICAL directive specifying Tool, Parameters, and DO NOT warning
- All skills follow identical thin-wrapper pattern, enabling consistent fix application

## Goals & Non-Goals

**Goals**:
- Add explicit Task tool invocation directives to all 7 forked skills
- Use CRITICAL formatting to ensure directive prominence
- Include DO NOT warning about Skill tool misuse
- Explain why agents require Task tool (directory mapping)
- Update thin-wrapper-skill.md template to prevent future issues

**Non-Goals**:
- Model tiering optimization (separate tasks 549-553)
- Removing the `agent:` frontmatter field (considered but deferred)
- Modifying agent files (only skills need fixes)
- Adding verification loops (future improvement)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fix doesn't reach all 7 skills | High | Low | Create checklist, verify each file exists after edit |
| Old sessions have cached bad context | Medium | High | Document in summary: start fresh sessions after fix |
| Prose instructions still ambiguous | Medium | Low | Use CRITICAL formatting, bold, caps, explicit parameters |
| Inconsistent fix application | Medium | Low | Use identical template for each skill, only agent name varies |

## Implementation Phases

### Phase 1: Create Fix Template [NOT STARTED]

**Goal**: Create the standardized fix template that will be applied to all 7 skills

**Tasks**:
- [ ] Draft the CRITICAL directive block with placeholder for agent name
- [ ] Include Tool specification (Task, NOT Skill)
- [ ] Include parameter specifications (subagent_type, prompt, description)
- [ ] Include DO NOT warning with explanation
- [ ] Verify template matches research recommendations

**Timing**: 15 minutes

**Files to modify**:
- None (template in memory)

**Verification**:
- Template includes all elements from research: CRITICAL heading, Tool specification, Parameters, DO NOT warning, directory explanation

---

### Phase 2: Fix Core Workflow Skills [NOT STARTED]

**Goal**: Apply fix to the 4 core workflow skills (researcher, planner, implementer, meta)

**Tasks**:
- [ ] Update `.claude/skills/skill-researcher/SKILL.md` - agent: general-research-agent
- [ ] Update `.claude/skills/skill-planner/SKILL.md` - agent: planner-agent
- [ ] Update `.claude/skills/skill-implementer/SKILL.md` - agent: general-implementation-agent
- [ ] Update `.claude/skills/skill-meta/SKILL.md` - agent: meta-builder-agent

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md` - Replace "Invoke Subagent" section
- `.claude/skills/skill-planner/SKILL.md` - Replace "Invoke Subagent" section
- `.claude/skills/skill-implementer/SKILL.md` - Replace "Invoke Subagent" section
- `.claude/skills/skill-meta/SKILL.md` - Replace "Invoke Subagent" section

**Verification**:
- Each file contains CRITICAL directive with correct agent name
- Each file contains DO NOT warning
- No remaining ambiguous "via Task tool" prose without explicit directive

---

### Phase 3: Fix Lean-Specific Skills [NOT STARTED]

**Goal**: Apply fix to the 2 Lean-specific skills

**Tasks**:
- [ ] Update `.claude/skills/skill-lean-research/SKILL.md` - agent: lean-research-agent
- [ ] Update `.claude/skills/skill-lean-implementation/SKILL.md` - agent: lean-implementation-agent

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-lean-research/SKILL.md` - Replace "Invoke Subagent" section
- `.claude/skills/skill-lean-implementation/SKILL.md` - Replace "Invoke Subagent" section

**Verification**:
- Each file contains CRITICAL directive with correct agent name
- Each file contains DO NOT warning
- Lean-specific context (MCP tools, goal checking) preserved

---

### Phase 4: Fix LaTeX Skill [NOT STARTED]

**Goal**: Apply fix to the LaTeX implementation skill

**Tasks**:
- [ ] Update `.claude/skills/skill-latex-implementation/SKILL.md` - agent: latex-implementation-agent

**Timing**: 15 minutes

**Files to modify**:
- `.claude/skills/skill-latex-implementation/SKILL.md` - Replace "Invoke Subagent" section

**Verification**:
- File contains CRITICAL directive with latex-implementation-agent
- File contains DO NOT warning
- LaTeX-specific context (pdflatex, latexmk) preserved

---

### Phase 5: Update Template Documentation [NOT STARTED]

**Goal**: Update the thin-wrapper-skill.md template to prevent future regressions

**Tasks**:
- [ ] Locate `.claude/context/core/templates/thin-wrapper-skill.md`
- [ ] Add the CRITICAL directive pattern to the template
- [ ] Add explicit note about Task vs Skill tool distinction
- [ ] Add warning about directory mapping (agents/ vs skills/)

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/core/templates/thin-wrapper-skill.md` - Add directive pattern and warnings

**Verification**:
- Template includes CRITICAL directive pattern
- Template explains Task vs Skill distinction
- New skills created from template will have correct directives

---

### Phase 6: Verification and Documentation [NOT STARTED]

**Goal**: Verify all fixes applied correctly and document completion

**Tasks**:
- [ ] Grep all 7 skill files for "CRITICAL" to verify fix presence
- [ ] Grep all 7 skill files for "DO NOT" warning presence
- [ ] Verify no skill files contain ambiguous "via Task tool" without CRITICAL block
- [ ] Document that fresh Claude Code sessions are required after fix

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- All 7 skills contain CRITICAL directive
- All 7 skills contain DO NOT warning
- Zero skills contain ambiguous prose without explicit directive

## Testing & Validation

- [ ] All 7 skill files updated with CRITICAL directive
- [ ] Grep verification: `grep -l "CRITICAL.*Task tool" .claude/skills/*/SKILL.md` returns 7 files
- [ ] Grep verification: `grep -l "DO NOT.*Skill" .claude/skills/*/SKILL.md` returns 7 files
- [ ] Template updated to prevent future regressions
- [ ] No breaking changes to skill frontmatter or execution flow

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- 7 modified SKILL.md files in `.claude/skills/`
- 1 modified template file in `.claude/context/core/templates/`
- summaries/implementation-summary-YYYYMMDD.md (on completion)

## Rollback/Contingency

If fixes cause unexpected issues:
1. Git revert the commit containing skill modifications
2. Skills will return to previous (working but ambiguous) state
3. Investigate which specific change caused the issue
4. Apply targeted fix rather than bulk template application

Since this is a documentation/instruction change (not code), rollback is straightforward via git revert.
