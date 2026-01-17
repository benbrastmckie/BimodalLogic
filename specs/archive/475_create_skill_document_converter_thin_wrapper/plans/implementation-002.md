# Implementation Plan: Task #475 (Revised)

- **Task**: 475 - Create document-converter command-skill-agent chain
- **Version**: 002
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/475_create_skill_document_converter_thin_wrapper/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a complete document converter feature following the command-skill-agent architecture pattern used throughout the .claude/ system. This revised plan extends the original skill-only scope to include all three layers:

1. **Command** (`/convert`) - User interface with 3-checkpoint pattern
2. **Skill** (`skill-document-converter`) - Thin wrapper routing layer
3. **Agent** (`document-converter-agent`) - Execution engine with conversion logic

### Architecture Pattern

```
/convert source.pdf [output.md]
    ↓ CHECKPOINT 1: GATE IN (validate args, generate session_id)
    ↓ STAGE 2: DELEGATE
skill-document-converter (thin wrapper)
    ↓ Task tool invocation
document-converter-agent (execution)
    ↓ Return JSON
    ↓ CHECKPOINT 2: GATE OUT (validate return, verify artifacts)
    ↓ CHECKPOINT 3: COMMIT (non-blocking)
```

### Research Integration

Key findings from research-001.md and command-skill-agent pattern analysis:
- Commands follow 3-checkpoint pattern: GATE IN → DELEGATE → GATE OUT → COMMIT
- Skills are thin wrappers (~100 lines) using `context: fork` pattern
- Agents do actual work and return standardized JSON format
- Session ID flows through entire chain for traceability
- No external script dependencies, pip installations, or model specifications

## Goals & Non-Goals

**Goals**:
- Create `/convert` command with full 3-checkpoint pattern
- Create minimal thin wrapper skill following skill-researcher template
- Create document-converter-agent with proper frontmatter and execution flow
- Support standalone invocation (no task binding required)
- Support multiple input formats (PDF, DOCX, images)
- Follow all naming conventions and return format standards

**Non-Goals**:
- Integrate with task workflow (no status updates)
- Support batch conversions (single file at a time)
- Auto-detect best output format (user specifies or defaults to markdown)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Conversion tools not available | Agent fails at runtime | Medium | Agent detects available tools and reports gracefully |
| Large file handling | Memory/timeout issues | Low | Document file size limits in command |
| Inconsistent return format | Integration issues | Low | Validate against subagent-return.md schema |

## Implementation Phases

### Phase 1: Create Command File [NOT STARTED]

**Goal**: Create `/convert` command with 3-checkpoint pattern

**Tasks**:
- [ ] Create `.claude/commands/convert.md`
- [ ] Implement CHECKPOINT 1: GATE IN
  - Parse arguments (source_path required, output_path optional)
  - Generate session_id
  - Validate source file exists
  - Determine output path (default: same dir, .md extension)
- [ ] Implement STAGE 2: DELEGATE
  - Invoke skill-document-converter via Skill tool
  - Pass source_path, output_path, session_id
- [ ] Implement CHECKPOINT 2: GATE OUT
  - Validate return format
  - Verify output file exists
- [ ] Implement CHECKPOINT 3: COMMIT
  - Non-blocking git commit (optional, only if requested)
- [ ] Document usage examples and error handling

**Files to create**:
- `.claude/commands/convert.md` - Command definition

**Verification**:
- Command follows 3-checkpoint pattern
- Session ID generation matches standard format
- Skill invocation uses correct syntax
- Error handling covers: file not found, conversion failed, timeout

---

### Phase 2: Create Agent File [NOT STARTED]

**Goal**: Create document-converter-agent with execution logic

**Tasks**:
- [ ] Create `.claude/agents/document-converter-agent.md`
- [ ] Add YAML frontmatter (name, description)
- [ ] Add Agent Metadata section (purpose, invoked by, return format)
- [ ] Add Allowed Tools section (Read, Write, Edit, Bash, WebFetch)
- [ ] Add Context References section (subagent-return.md)
- [ ] Add Execution Flow section
  - Step 1: Detect available conversion tools
  - Step 2: Select appropriate conversion method
  - Step 3: Execute conversion
  - Step 4: Validate output
  - Step 5: Return standardized JSON
- [ ] Add supported format matrix (PDF, DOCX, images → markdown)
- [ ] Add Return Format section with examples
- [ ] Add Error Handling section

**Files to create**:
- `.claude/agents/document-converter-agent.md` - Agent definition

**Verification**:
- Frontmatter valid for Claude Code registration
- Return format matches subagent-return.md schema
- Contextual status values used: "converted", "extracted", "partial", "failed"
- No external script dependencies in logic
- No model specification in frontmatter

---

### Phase 3: Create Skill File [NOT STARTED]

**Goal**: Create thin wrapper skill connecting command to agent

**Tasks**:
- [ ] Create directory `.claude/skills/skill-document-converter/`
- [ ] Create `SKILL.md` with YAML frontmatter
  - name: skill-document-converter
  - description: Document conversion routing
  - allowed-tools: Task
  - context: fork
  - agent: document-converter-agent
- [ ] Add Trigger Conditions section
- [ ] Add Input Validation section (source_path, output_path)
- [ ] Add Context Preparation section (build delegation JSON)
- [ ] Add Invoke Subagent section (Task tool syntax)
- [ ] Add Return Validation section
- [ ] Add Return Propagation section

**Files to create**:
- `.claude/skills/skill-document-converter/SKILL.md` - Skill definition

**Verification**:
- Follows skill-researcher template exactly
- `context: fork` present
- Agent reference correct
- Under 100 lines (thin wrapper)

---

### Phase 4: Register and Test Chain [NOT STARTED]

**Goal**: Verify complete command-skill-agent chain works

**Tasks**:
- [ ] Verify agent appears in `subagent_type` list (may need session restart)
- [ ] Test command invocation: `/convert test.pdf`
- [ ] Verify skill routing works
- [ ] Verify agent execution works
- [ ] Verify return format propagates correctly
- [ ] Document any registration issues

**Files to modify**: None (testing only)

**Verification**:
- `/convert` command recognized
- Skill invocation succeeds
- Agent executes and returns JSON
- Output file created for successful conversion
- Errors handled gracefully

---

## Testing & Validation

- [ ] Command file exists at `.claude/commands/convert.md`
- [ ] Command follows 3-checkpoint pattern
- [ ] Agent file exists at `.claude/agents/document-converter-agent.md`
- [ ] Agent frontmatter valid for registration
- [ ] Skill file exists at `.claude/skills/skill-document-converter/SKILL.md`
- [ ] Skill is thin wrapper (under 100 lines)
- [ ] Complete chain executes: command → skill → agent
- [ ] Return format consistent across chain
- [ ] No external dependencies or pip installations

## Artifacts & Outputs

- `.claude/commands/convert.md` - User-facing command
- `.claude/skills/skill-document-converter/SKILL.md` - Thin wrapper skill
- `.claude/agents/document-converter-agent.md` - Execution agent

## Rollback/Contingency

If implementation introduces issues:
- Delete created files:
  - `.claude/commands/convert.md`
  - `.claude/skills/skill-document-converter/`
  - `.claude/agents/document-converter-agent.md`
- No state changes to TODO.md or state.json beyond this task
- Components can be recreated independently following this plan

## Changes from v001

| Aspect | v001 | v002 |
|--------|------|------|
| Scope | Skill only | Command + Skill + Agent |
| Effort | 1.5 hours | 3 hours |
| Phases | 3 | 4 |
| Files created | 1 | 3 |
| Architecture | Partial | Complete command-skill-agent chain |
