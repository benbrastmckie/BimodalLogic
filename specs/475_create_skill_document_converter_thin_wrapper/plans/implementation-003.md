# Implementation Plan: Task #475 (v003)

- **Task**: 475 - Create document-converter command-skill-agent chain
- **Version**: 003
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: research-001.md, research-002.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a complete document converter feature with **dual invocation paths**:

1. **Direct Command**: User invokes `/convert source.pdf [output.md]`
2. **Implicit During Implementation**: Agents invoke `Skill(skill-document-converter)` when task implementation naturally requires conversion

This is achieved through the Skill tool's **trigger conditions mechanism** - documenting when the skill should be invoked allows implementing agents to recognize conversion needs and call the converter.

### Architecture

```
Path 1: Direct Command
/convert source.pdf [output.md]
    → convert.md (GATE IN → DELEGATE → GATE OUT → COMMIT)
    → skill-document-converter (thin wrapper)
    → document-converter-agent (execution)
    → Returns JSON with converted file

Path 2: Implicit During Task Implementation
/implement N
    → general-implementation-agent reads plan
    → Plan step: "Extract content from research.pdf"
    → Agent recognizes trigger condition
    → Agent invokes Skill(skill-document-converter)
    → Conversion happens
    → Implementation continues
```

### Key Design Decisions

1. **Single-file focus**: Each invocation converts one file. Batch conversion deferred to future enhancement.
2. **Trigger conditions**: Skill documents patterns that signal conversion needs (enabling implicit invocation)
3. **Standalone operation**: No task binding required for `/convert` command
4. **Standard return format**: Uses `subagent-return.md` schema with contextual statuses

## Goals & Non-Goals

**Goals**:
- Create `/convert` command with 3-checkpoint pattern
- Create thin wrapper skill with documented trigger conditions
- Create document-converter-agent with conversion logic
- Enable **both** direct invocation and implicit invocation during implementation
- Follow all naming conventions and return format standards

**Non-Goals**:
- Batch/directory conversion (deferred)
- Auto-detect best output format (user specifies or defaults to markdown)
- Status updates to task tracking (converter operates independently)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Conversion tools not available | Agent fails at runtime | Medium | Agent detects available tools and reports gracefully |
| Trigger conditions too narrow | Agents don't recognize conversion needs | Medium | Document comprehensive trigger patterns |
| Trigger conditions too broad | False positive invocations | Low | Be specific about file type patterns |

## Implementation Phases

### Phase 1: Create Agent File [COMPLETED]

**Goal**: Create document-converter-agent with execution logic (create agent first since skill references it)

**Tasks**:
- [ ] Create `.claude/agents/document-converter-agent.md`
- [ ] Add YAML frontmatter:
  ```yaml
  ---
  name: document-converter-agent
  description: Convert documents between formats (PDF/DOCX to Markdown, Markdown to PDF)
  ---
  ```
- [ ] Add Agent Metadata section (purpose, invoked by, return format)
- [ ] Add Allowed Tools section: Read, Write, Edit, Bash
- [ ] Add Context References section: subagent-return.md
- [ ] Add Execution Flow:
  1. Detect available conversion tools (markitdown, pandoc, typst)
  2. Determine conversion direction from file extensions
  3. Execute conversion with appropriate tool
  4. Validate output exists
  5. Return standardized JSON
- [ ] Add Supported Conversions matrix:
  - PDF → Markdown (markitdown preferred, pandoc fallback)
  - DOCX → Markdown (markitdown preferred, pandoc fallback)
  - Markdown → PDF (pandoc or typst)
  - Images → Markdown (markitdown with OCR if available)
- [ ] Add Return Format section with contextual statuses: "converted", "extracted", "failed"
- [ ] Add Error Handling section

**Files to create**:
- `.claude/agents/document-converter-agent.md`

**Verification**:
- Frontmatter valid for Claude Code registration
- Return format matches subagent-return.md schema
- No external script dependencies
- No model specification

---

### Phase 2: Create Skill File with Trigger Conditions [COMPLETED]

**Goal**: Create thin wrapper skill with comprehensive trigger conditions enabling both invocation paths

**Tasks**:
- [ ] Create `.claude/skills/skill-document-converter/SKILL.md`
- [ ] Add YAML frontmatter:
  ```yaml
  ---
  name: skill-document-converter
  description: Document conversion routing with dual invocation support
  allowed-tools: Task
  context: fork
  agent: document-converter-agent
  ---
  ```
- [ ] Add **Trigger Conditions** section (critical for implicit invocation):
  ```markdown
  ## Trigger Conditions

  This skill activates when:

  ### Direct Invocation
  - User explicitly runs `/convert` command

  ### Implicit Invocation (during task implementation)
  When an implementing agent encounters:
  - Plan step mentioning "extract", "convert", or "generate PDF"
  - Need to read content from PDF or DOCX files
  - Need to produce PDF output from Markdown
  - Task description involving document format transformation

  **Detection patterns in plans**:
  - "Extract text from [file].pdf"
  - "Convert [file] to markdown"
  - "Generate PDF from documentation"
  - "Read content from [file].docx"
  - "Create PDF version of [file]"
  ```
- [ ] Add Input Validation section (source_path required, output_path optional)
- [ ] Add Context Preparation section with delegation JSON
- [ ] Add Invoke Subagent section with Task tool syntax
- [ ] Add Return Validation and Propagation sections

**Files to create**:
- `.claude/skills/skill-document-converter/SKILL.md`

**Verification**:
- Follows thin wrapper pattern (under 150 lines)
- `context: fork` present
- Trigger conditions comprehensive but specific
- Agent reference correct

---

### Phase 3: Create Command File [IN PROGRESS]

**Goal**: Create `/convert` command with 3-checkpoint pattern

**Tasks**:
- [ ] Create `.claude/commands/convert.md`
- [ ] Add command header with usage: `/convert source_path [output_path]`
- [ ] Implement CHECKPOINT 1: GATE IN
  - Parse arguments (source_path required, output_path optional)
  - Generate session_id
  - Validate source file exists
  - Determine output path (default: same dir, appropriate extension)
- [ ] Implement STAGE 2: DELEGATE
  - Invoke Skill tool: `Skill(skill-document-converter)`
  - Pass source_path, output_path, session_id
- [ ] Implement CHECKPOINT 2: GATE OUT
  - Validate return format
  - Verify output file exists
- [ ] Implement CHECKPOINT 3: COMMIT
  - Non-blocking (only commit if explicitly requested)
- [ ] Document usage examples:
  ```
  /convert document.pdf                    # → document.md
  /convert report.docx notes.md            # → notes.md
  /convert README.md README.pdf            # → README.pdf
  ```
- [ ] Add Error Handling section

**Files to create**:
- `.claude/commands/convert.md`

**Verification**:
- Command follows 3-checkpoint pattern
- Session ID generation correct
- Skill invocation uses correct syntax
- Error handling covers: file not found, conversion failed, unsupported format

---

### Phase 4: Update Skill List and Test [NOT STARTED]

**Goal**: Register skill and verify both invocation paths work

**Tasks**:
- [ ] Add skill-document-converter to `.claude/CLAUDE.md` skill listing if needed
- [ ] Verify agent appears in valid `subagent_type` values (session restart may be needed)
- [ ] Test Path 1 (direct): `/convert test.pdf`
- [ ] Test Path 2 (implicit): Create test task requiring conversion, run `/implement`
- [ ] Document registration notes

**Files to modify**:
- `.claude/CLAUDE.md` (if skill listing exists and needs update)

**Verification**:
- `/convert` command recognized
- Skill invocation succeeds from command
- Agent executes and returns proper JSON
- Implementing agents can invoke skill (verified by manual test)

---

## Testing & Validation

- [ ] Agent file exists at `.claude/agents/document-converter-agent.md`
- [ ] Agent frontmatter valid for Claude Code registration
- [ ] Skill file exists at `.claude/skills/skill-document-converter/SKILL.md`
- [ ] Skill is thin wrapper (under 150 lines)
- [ ] Skill trigger conditions are comprehensive
- [ ] Command file exists at `.claude/commands/convert.md`
- [ ] Command follows 3-checkpoint pattern
- [ ] Direct invocation path works: `/convert file.pdf`
- [ ] Return format consistent with subagent-return.md schema

## Artifacts & Outputs

- `.claude/agents/document-converter-agent.md` - Execution agent
- `.claude/skills/skill-document-converter/SKILL.md` - Thin wrapper skill with trigger conditions
- `.claude/commands/convert.md` - User-facing command

## Rollback/Contingency

If implementation introduces issues:
- Delete created files:
  - `.claude/commands/convert.md`
  - `.claude/skills/skill-document-converter/`
  - `.claude/agents/document-converter-agent.md`
- No state changes to TODO.md or state.json beyond this task
- Components can be recreated independently

## Changes from v002

| Aspect | v002 | v003 |
|--------|------|------|
| Focus | Complete chain creation | Dual invocation paths |
| Trigger conditions | Minimal | Comprehensive for implicit invocation |
| Batch support | Listed as non-goal | Explicitly deferred |
| Phase order | Command first | Agent first (skill references it) |
| Research input | research-001.md only | research-001.md + research-002.md |
