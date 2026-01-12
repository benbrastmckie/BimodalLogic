# Implementation Plan: Task #409

**Task**: Convert workflow skills to forked subagent pattern
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

Convert six workflow skills (skill-lean-research, skill-researcher, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation) from inline execution to thin wrappers that spawn forked subagents. This improves token efficiency by loading context only in isolated subagent conversations rather than the parent context.

The implementation follows the principle that skills should handle routing/validation while subagents handle execution. The existing return format standard (`subagent-return.md`) and delegation infrastructure (`delegation.md`) are leveraged rather than reinvented.

## Phases

### Phase 1: Update Skill Frontmatter Format

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Add `context: fork` field to indicate subagent delegation
2. Add `agent:` field to specify target subagent
3. Update `allowed-tools:` to minimal set (Task for delegation)
4. Preserve original context paths as comments for reference

**Files to modify**:
- `.claude/skills/skill-lean-research/SKILL.md` - Update frontmatter
- `.claude/skills/skill-researcher/SKILL.md` - Update frontmatter
- `.claude/skills/skill-planner/SKILL.md` - Update frontmatter
- `.claude/skills/skill-implementer/SKILL.md` - Update frontmatter
- `.claude/skills/skill-lean-implementation/SKILL.md` - Update frontmatter
- `.claude/skills/skill-latex-implementation/SKILL.md` - Update frontmatter

**Steps**:
1. Read each skill file to understand current frontmatter structure
2. For each skill, update frontmatter to new format:
   ```yaml
   ---
   name: skill-{name}
   description: {existing description}
   allowed-tools: Task
   context: fork
   agent: {corresponding-agent-name}
   # Original context preserved as reference:
   # - {original context file 1}
   # - {original context file 2}
   ---
   ```
3. Map skills to agents:
   - skill-lean-research → lean-research-agent
   - skill-researcher → general-research-agent
   - skill-planner → planner-agent
   - skill-implementer → general-implementation-agent
   - skill-lean-implementation → lean-implementation-agent
   - skill-latex-implementation → latex-implementation-agent
4. Verify frontmatter YAML is valid

**Verification**:
- All 6 skill files have updated frontmatter
- Each has `context: fork` and `agent:` fields
- Original context paths preserved as comments
- No YAML syntax errors

---

### Phase 2: Create Thin Wrapper Template

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Define standard thin wrapper structure for all skills
2. Document the delegation pattern clearly
3. Create reusable template that can be applied to all skills

**Files to create**:
- `.claude/context/core/templates/thin-wrapper-skill.md` - Template for converted skills

**Steps**:
1. Create template file with:
   - Input validation section (task number, focus prompt)
   - Context preparation (read from state.json)
   - Subagent invocation pattern (Task tool call)
   - Return validation (JSON structure check)
   - Return propagation (pass through to caller)
2. Include example invocation showing:
   - How to generate session_id
   - How to prepare delegation context
   - How to call Task tool with correct parameters
3. Document expected return format reference

**Verification**:
- Template file created with complete structure
- Clear examples for each section
- References existing standards (subagent-return.md, delegation.md)

---

### Phase 3: Convert Research Skills to Thin Wrappers

**Estimated effort**: 1.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Replace skill-lean-research body with thin wrapper
2. Replace skill-researcher body with thin wrapper
3. Preserve trigger conditions and integration notes

**Files to modify**:
- `.claude/skills/skill-lean-research/SKILL.md` - Replace body with thin wrapper
- `.claude/skills/skill-researcher/SKILL.md` - Replace body with thin wrapper

**Steps**:
1. For skill-lean-research:
   - Remove detailed search workflow (moved to subagent)
   - Remove rate limit management section (moved to subagent)
   - Remove tool reference section (moved to subagent)
   - Add thin wrapper with:
     ```markdown
     ## Execution

     ### 1. Input Validation
     Validate task_number is provided and exists in state.json.
     Extract optional focus_prompt from arguments.

     ### 2. Context Preparation
     Read task from state.json using jq patterns from skill-status-sync.
     Prepare delegation context with session_id, depth, path.

     ### 3. Invoke Subagent
     Invoke lean-research-agent via Task tool with:
     - task_number, task_name, description, language
     - delegation context
     - focus_prompt (if provided)

     ### 4. Return Validation
     Validate return matches subagent-return.md schema.
     Check status, artifacts, metadata fields present.

     ### 5. Return Propagation
     Return validated result to caller.
     ```
   - Keep trigger conditions section
   - Keep return format section (reference to standard)

2. For skill-researcher:
   - Apply same pattern as skill-lean-research
   - Reference general-research-agent instead

3. Verify both skills are minimal (validation + delegation only)

**Verification**:
- Both research skills are thin wrappers (<100 lines each)
- Detailed execution logic removed (now in subagents)
- Trigger conditions preserved
- Return format references standard

---

### Phase 4: Convert Planning Skill to Thin Wrapper

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Replace skill-planner body with thin wrapper
2. Preserve planning strategy notes as comments

**Files to modify**:
- `.claude/skills/skill-planner/SKILL.md` - Replace body with thin wrapper

**Steps**:
1. Remove detailed planning sections:
   - Context Gathering (moved to subagent)
   - Scope Analysis (moved to subagent)
   - Phase Decomposition (moved to subagent)
   - Risk Assessment (moved to subagent)
2. Add thin wrapper following template from Phase 2
3. Reference planner-agent as target subagent
4. Keep trigger conditions section
5. Keep return format section

**Verification**:
- skill-planner is thin wrapper (<100 lines)
- Planning logic removed (now in planner-agent)
- Trigger conditions preserved

---

### Phase 5: Convert Implementation Skills to Thin Wrappers

**Estimated effort**: 1.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Replace skill-implementer body with thin wrapper
2. Replace skill-lean-implementation body with thin wrapper
3. Replace skill-latex-implementation body with thin wrapper
4. Preserve language-specific notes as comments

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - Replace body with thin wrapper
- `.claude/skills/skill-lean-implementation/SKILL.md` - Replace body with thin wrapper
- `.claude/skills/skill-latex-implementation/SKILL.md` - Replace body with thin wrapper

**Steps**:
1. For skill-implementer:
   - Remove plan loading logic (moved to subagent)
   - Remove phase execution logic (moved to subagent)
   - Remove step execution patterns (moved to subagent)
   - Add thin wrapper referencing general-implementation-agent

2. For skill-lean-implementation:
   - Remove Lean tool usage sections (moved to subagent)
   - Remove proof development loop (moved to subagent)
   - Remove tactic patterns (moved to subagent)
   - Add thin wrapper referencing lean-implementation-agent
   - Note: MCP tool permissions stay with subagent

3. For skill-latex-implementation:
   - Remove compilation loop (moved to subagent)
   - Remove package selection (moved to subagent)
   - Remove error handling details (moved to subagent)
   - Add thin wrapper referencing latex-implementation-agent

4. Verify all three skills follow same thin wrapper pattern

**Verification**:
- All 3 implementation skills are thin wrappers (<100 lines each)
- Execution logic moved to subagents
- Trigger conditions preserved
- Language-specific tool permissions documented

---

### Phase 6: Update Documentation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document new skill pattern in CLAUDE.md
2. Update ARCHITECTURE.md with forked subagent pattern
3. Add skill-to-agent mapping table

**Files to modify**:
- `.claude/CLAUDE.md` - Add skill pattern documentation
- `.claude/ARCHITECTURE.md` - Add forked subagent section

**Steps**:
1. Add section to CLAUDE.md explaining:
   - `context: fork` meaning (delegate to subagent)
   - `agent:` field usage
   - Thin wrapper pattern
   - When to use skills vs subagents

2. Add section to ARCHITECTURE.md:
   - Forked subagent pattern diagram
   - Skill-to-agent mapping table
   - Token efficiency explanation

3. Review existing documentation for consistency

**Verification**:
- CLAUDE.md has new skill pattern section
- ARCHITECTURE.md has forked subagent pattern
- Documentation is consistent with implementation

---

## Dependencies

- **Task 410 (prerequisite)**: Remove eager context loading from skill frontmatter
  - This task converts `context:` array to `context: fork`
  - Without subagents existing, skills would break
  - **Resolution**: Phase 1 of this task addresses frontmatter, Tasks 411-414 create subagents

- **Tasks 411-414 (parallel work)**: Create subagent files
  - Skills need corresponding subagents to delegate to
  - **Resolution**: Skills reference agents by name; agents created in separate tasks

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Subagents not ready when skills converted | High | Medium | Skills reference agents by name; create agents first (tasks 411-414) before /implement 409 |
| Return format validation failures | Medium | Low | Use existing subagent-return.md standard; test with sample returns |
| Breaking existing workflows | High | Low | Changes are additive (new fields); old patterns still work |
| Context loading regressions | Medium | Medium | Preserve original context paths as comments for debugging |

## Success Criteria

- [ ] All 6 skills have `context: fork` and `agent:` fields in frontmatter
- [ ] All 6 skills are thin wrappers (<100 lines of body content)
- [ ] Thin wrapper template created and documented
- [ ] CLAUDE.md documents new skill pattern
- [ ] ARCHITECTURE.md documents forked subagent pattern
- [ ] No breaking changes to existing command invocations

## Rollback Plan

If implementation fails:
1. Restore original SKILL.md files from git
2. Remove thin-wrapper-skill.md template
3. Revert CLAUDE.md and ARCHITECTURE.md changes
4. Skills continue working with eager context loading

Git command: `git checkout HEAD~N -- .claude/skills/`
