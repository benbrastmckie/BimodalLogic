# Implementation Plan: Task #413

**Task**: Create implementation-agent subagents (lean/general/latex)
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

Create three implementation agent subagents that execute implementation plans for their respective languages. Each agent follows the established pattern from research agents (lean-research-agent, general-research-agent) but focuses on implementation rather than research:

1. **lean-implementation-agent** - Executes Lean 4 proof development using MCP tools
2. **general-implementation-agent** - Executes general/meta/markdown implementation tasks
3. **latex-implementation-agent** - Executes LaTeX document compilation workflows

All agents share a common structure: load language-specific context, parse implementation plan, execute phases sequentially, handle resume from partial, and return standardized JSON matching `subagent-return.md`.

## Phases

### Phase 1: Create lean-implementation-agent.md

**Status**: [COMPLETED]

**Objectives**:
1. Create agent file with proper metadata and structure
2. Define Lean MCP tool allowlist (lean_goal, lean_diagnostic_messages, etc.)
3. Document execution flow for proof development
4. Include resume logic for partial implementations

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Create new file

**Steps**:
1. Create agent file with metadata header:
   - Name: lean-implementation-agent
   - Purpose: Execute Lean 4 proof implementations
   - Invoked By: skill-lean-implementation
   - Return Format: JSON (subagent-return.md)

2. Define Allowed Tools section:
   - File Operations: Read, Write, Edit, Glob, Grep
   - Build Tools: Bash (lake build, lake exe)
   - Lean MCP Tools (all from lean-research-agent plus):
     - lean_goal (MOST IMPORTANT for proof state)
     - lean_diagnostic_messages (errors/warnings)
     - lean_hover_info (type signatures)
     - lean_completions (IDE autocomplete)
     - lean_multi_attempt (test tactics without editing)
     - lean_local_search (verify lemmas exist)
     - lean_state_search (find closing lemmas)
     - lean_hammer_premise (simp/aesop premises)

3. Define Context References section:
   - Always Load: mcp-tools-guide.md, subagent-return.md
   - Load for Implementation: tactic-patterns.md, lean4-style-guide.md
   - Load for Specific Needs: relevant Logos layer files

4. Document Execution Flow:
   - Stage 1: Parse delegation context (task_number, plan_path, session_id)
   - Stage 2: Load and parse implementation plan
   - Stage 3: Find resume point (first non-completed phase)
   - Stage 4: Execute proof development loop for each phase
   - Stage 5: Run `lake build` to verify
   - Stage 6: Create implementation summary
   - Stage 7: Return structured JSON

5. Document Proof Development Loop:
   - Read target file, locate proof point
   - Use lean_goal to get current proof state
   - Use lean_multi_attempt to try candidate tactics
   - Apply successful tactic via Edit
   - Repeat until goals closed or stuck
   - Handle errors with lean_diagnostic_messages

6. Document Error Handling:
   - Build failures: capture error, return partial
   - Proof stuck: log state, return partial with recommendation
   - Timeout: save progress, return partial with resume info

7. Include Return Format Examples:
   - Completed: all phases done, build succeeds
   - Partial: some phases done, stuck or timeout
   - Failed: critical error, cannot proceed

**Verification**:
- Agent file follows pattern from lean-research-agent.md
- All required sections present (Metadata, Allowed Tools, Context, Execution Flow, etc.)
- Return format examples match subagent-return.md schema

---

### Phase 2: Create general-implementation-agent.md

**Status**: [COMPLETED]

**Objectives**:
1. Create agent file with proper metadata and structure
2. Define tool allowlist for general/meta/markdown tasks
3. Document execution flow for file-based implementation
4. Include resume logic for partial implementations

**Files to modify**:
- `.claude/agents/general-implementation-agent.md` - Create new file

**Steps**:
1. Create agent file with metadata header:
   - Name: general-implementation-agent
   - Purpose: Execute general, meta, and markdown implementations
   - Invoked By: skill-implementer
   - Return Format: JSON (subagent-return.md)

2. Define Allowed Tools section:
   - File Operations: Read, Write, Edit, Glob, Grep
   - Build Tools: Bash (npm, python, make, etc.)
   - No language-specific MCP tools needed

3. Define Context References section:
   - Always Load: subagent-return.md
   - Load When Creating Summary: summary-format.md
   - Load for Meta Tasks: project context files, CLAUDE.md
   - Load for Code Tasks: code-patterns.md if exists

4. Document Execution Flow:
   - Stage 1: Parse delegation context
   - Stage 2: Load and parse implementation plan
   - Stage 3: Find resume point (first non-completed phase)
   - Stage 4: Execute file operations for each phase:
     - Read existing files
     - Write/Edit files as specified in plan
     - Run verification commands (Bash)
   - Stage 5: Create implementation summary
   - Stage 6: Return structured JSON

5. Document Phase Execution Loop:
   - Mark phase [IN PROGRESS] in plan file
   - Execute each step in the phase
   - Verify step completion
   - Mark phase [COMPLETED] in plan file
   - Proceed to next phase

6. Document Error Handling:
   - File operation failure: capture error, return partial
   - Verification failure: log details, return partial with fix recommendation
   - Timeout: save progress, return partial with resume info

7. Include Return Format Examples:
   - Completed: all phases executed successfully
   - Partial: some phases done, interrupted
   - Failed: critical error (invalid plan, missing files)

**Verification**:
- Agent file follows pattern from general-research-agent.md
- All required sections present
- Return format examples match subagent-return.md schema
- Handles general, meta, and markdown task types

---

### Phase 3: Create latex-implementation-agent.md

**Status**: [COMPLETED]

**Objectives**:
1. Create agent file with proper metadata and structure
2. Define tool allowlist with LaTeX compilation commands
3. Document execution flow for document creation
4. Include resume logic and compilation error handling

**Files to modify**:
- `.claude/agents/latex-implementation-agent.md` - Create new file

**Steps**:
1. Create agent file with metadata header:
   - Name: latex-implementation-agent
   - Purpose: Execute LaTeX document implementations
   - Invoked By: skill-latex-implementation
   - Return Format: JSON (subagent-return.md)

2. Define Allowed Tools section:
   - File Operations: Read, Write, Edit, Glob, Grep
   - Build Tools: Bash with LaTeX commands:
     - pdflatex (single pass compilation)
     - latexmk -pdf (full build with bibliography)
     - bibtex/biber (bibliography processing)
     - latexmk -c (cleanup auxiliary files)

3. Define Context References section:
   - Always Load: subagent-return.md
   - Load for LaTeX Work:
     - latex-style-guide.md (formatting conventions)
     - notation-conventions.md (symbol definitions)
     - document-structure.md (chapter/section patterns)
     - theorem-environments.md (theorem/lemma formatting)
     - cross-references.md (label/ref patterns)
     - subfile-template.md (modular document structure)
     - compilation-guide.md (build process)
   - Load for Logic Content: notation-standards.md

4. Document Execution Flow:
   - Stage 1: Parse delegation context
   - Stage 2: Load and parse implementation plan
   - Stage 3: Find resume point
   - Stage 4: For each phase:
     - Create/modify .tex files per plan
     - Run compilation (latexmk or pdflatex cycle)
     - Check for compilation errors
     - Fix errors if possible, or return partial
   - Stage 5: Verify final PDF output
   - Stage 6: Create implementation summary
   - Stage 7: Return structured JSON with PDF artifact

5. Document Compilation Loop:
   - Run pdflatex (may need 2-3 passes for references)
   - If bibliography: run bibtex/biber, then pdflatex twice
   - Check for errors in .log file
   - If errors: attempt fix or return partial with error details

6. Document Error Handling:
   - Compilation error: parse .log, identify issue, attempt fix or return partial
   - Missing package: log dependency, return failed with recommendation
   - Cross-reference undefined: suggest fix, return partial
   - Timeout: clean up, return partial with resume info

7. Include Return Format Examples:
   - Completed: all sections written, PDF compiles clean
   - Partial: some sections done, compilation issue
   - Failed: critical error (missing template, invalid structure)

**Verification**:
- Agent file follows established pattern
- All required sections present
- LaTeX-specific tools and context properly documented
- Compilation workflow clearly defined
- Return format examples include PDF artifact

---

### Phase 4: Validate and Test Integration

**Status**: [COMPLETED]

**Objectives**:
1. Verify all three agents follow consistent patterns
2. Confirm skill→agent mappings are correct
3. Validate agent files are well-formed

**Files to modify**:
- None (validation only)

**Steps**:
1. Cross-check agent structure consistency:
   - All have: Overview, Agent Metadata, Allowed Tools, Context References
   - All have: Execution Flow, Error Handling, Return Format Examples
   - All have: Critical Requirements (MUST DO / MUST NOT)

2. Verify skill→agent mappings match:
   - skill-lean-implementation.md → lean-implementation-agent
   - skill-implementer.md → general-implementation-agent
   - skill-latex-implementation.md → latex-implementation-agent

3. Validate return format compliance:
   - All examples match subagent-return.md schema exactly
   - All include required fields (status, summary, artifacts, metadata)
   - All session_id references match delegation pattern

4. Review tool allowlists:
   - Lean agent: Has all necessary MCP tools
   - General agent: Has file ops and Bash
   - LaTeX agent: Has LaTeX compilation commands

**Verification**:
- All three agents created successfully
- Consistent structure across all agents
- Skills reference correct agent names
- No missing required sections

---

## Dependencies

- Task 410 (research agents) - Provides pattern for agent structure
- subagent-return.md - Return format specification
- Existing skill files - Define agent invocation patterns

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inconsistent agent structure | Medium | Low | Use lean-research-agent as template |
| Missing tool in allowlist | Medium | Medium | Review skill files for original tool lists |
| Return format mismatch | High | Low | Validate against subagent-return.md examples |
| Context loading not specified | Medium | Medium | Document all context references explicitly |

## Success Criteria

- [ ] lean-implementation-agent.md created with all sections
- [ ] general-implementation-agent.md created with all sections
- [ ] latex-implementation-agent.md created with all sections
- [ ] All agents follow consistent structure pattern
- [ ] All return format examples match subagent-return.md
- [ ] All agents document resume logic for partial implementations
- [ ] Skill→agent mappings verified correct

## Rollback Plan

If implementation fails or agents don't work correctly:
1. The skills already exist and function independently
2. Agents can be deleted and recreated
3. No production systems depend on these agents yet
