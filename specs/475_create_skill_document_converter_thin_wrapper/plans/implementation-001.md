# Implementation Plan: Task #475

- **Task**: 475 - Create skill-document-converter thin wrapper
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None (agent dependency is external - Task 476)
- **Research Inputs**: specs/475_create_skill_document_converter_thin_wrapper/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a minimal thin wrapper skill for document conversion following the established 5-step delegation pattern. The skill delegates all conversion logic to document-converter-agent (Task 476), handling only input validation and Task tool invocation. Research indicates avoiding the Logos project pitfalls: no external script dependencies, no pip installations, no model specification in frontmatter.

### Research Integration

Key findings from research-001.md:
- All thin wrapper skills follow identical 5-step pattern: validate, prepare context, invoke Task tool, validate return, propagate
- Skill should be ~100 lines, not 370+ like Logos version
- Do NOT include: tool detection, conversion logic, model spec, external scripts
- Use contextual status values: "converted", "extracted", "partial", "failed"
- Support both standalone invocation (source_path, output_path) and optional task-bound mode

## Goals & Non-Goals

**Goals**:
- Create minimal thin wrapper skill following skill-researcher template
- Support standalone invocation with source/output paths
- Include proper YAML frontmatter for Claude Code registration
- Document trigger conditions and expected return format
- Enable future document-converter-agent integration

**Non-Goals**:
- Implement actual conversion logic (agent's responsibility)
- Detect available tools (agent's responsibility)
- Handle pip installations or external dependencies
- Specify model in frontmatter

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Agent not yet created (Task 476) | Skill invocation fails until agent exists | High | Document dependency clearly; skill can be created as placeholder |
| Inconsistent with other thin wrappers | Maintenance burden | Low | Follow skill-researcher template exactly |
| Missing trigger conditions | Skill not invoked when needed | Medium | Document all conversion scenarios explicitly |

## Implementation Phases

### Phase 1: Create Skill Directory and File [NOT STARTED]

**Goal**: Set up skill directory structure and create SKILL.md with proper frontmatter

**Tasks**:
- [ ] Create directory `.claude/skills/skill-document-converter/`
- [ ] Create SKILL.md with YAML frontmatter (name, description, allowed-tools: Task, context: fork, agent: document-converter-agent)
- [ ] Add Context Pointers section referencing validation.md
- [ ] Add Trigger Conditions section for conversion scenarios

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-document-converter/SKILL.md` - create new file

**Verification**:
- Frontmatter matches skill-researcher pattern
- Context fork signal present
- Agent reference correct

---

### Phase 2: Implement 5-Step Execution Flow [NOT STARTED]

**Goal**: Add execution flow sections following thin wrapper pattern

**Tasks**:
- [ ] Add Input Validation section (validate source_path, output_path, optional task_number)
- [ ] Add Context Preparation section with delegation JSON structure
- [ ] Add Invoke Subagent section with explicit Task tool instruction
- [ ] Add Return Validation section referencing subagent-return.md
- [ ] Add Return Propagation section

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-document-converter/SKILL.md` - add execution sections

**Verification**:
- All 5 steps present
- Task tool invocation clearly documented
- Delegation context includes session_id

---

### Phase 3: Add Return Format and Error Handling [NOT STARTED]

**Goal**: Document expected returns and error cases

**Tasks**:
- [ ] Add Return Format section with successful conversion example JSON
- [ ] Use contextual status values: "converted", "extracted", "partial", "failed"
- [ ] Add Error Handling section for input validation errors, subagent errors, timeout
- [ ] Add examples for partial and failed returns

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-document-converter/SKILL.md` - add return/error sections

**Verification**:
- Return format matches subagent-return.md schema
- No use of "completed" status (anti-stop pattern)
- All error scenarios documented

---

## Testing & Validation

- [ ] Skill file exists at `.claude/skills/skill-document-converter/SKILL.md`
- [ ] Frontmatter parses correctly (name, description, allowed-tools, context, agent)
- [ ] All 5 execution steps documented
- [ ] Return format uses contextual status values
- [ ] No external script references
- [ ] No model specification in frontmatter
- [ ] File length under 150 lines (minimal thin wrapper)

## Artifacts & Outputs

- `.claude/skills/skill-document-converter/SKILL.md` - The thin wrapper skill file

## Rollback/Contingency

If implementation introduces issues:
- Delete `.claude/skills/skill-document-converter/` directory
- No state changes to TODO.md or state.json beyond this task
- Skill can be recreated from scratch following this plan
