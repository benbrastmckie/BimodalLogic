# Implementation Plan: Task #701

**Task**: Fix lean-lsp-mcp hanging issue
**Version**: 002
**Created**: 2026-01-28
**Language**: meta
**Revised From**: implementation-001.md

## Revision Rationale

Hold on the MCP Canary Check to focus first on extracting detailed instructions from the lean research and implementation agents to context files. The aim is to provide robust and high-performance lean subagents that can be depended on.

The core insight: Agent reliability comes from clear, well-organized instructions. By extracting detailed execution flows to dedicated context files, we:
1. Reduce agent token overhead (smaller prompts load faster)
2. Enable independent iteration on execution details
3. Make agents more maintainable and testable
4. Create reusable instruction modules

## Overview

Extract detailed execution instructions from lean-research-agent and lean-implementation-agent into dedicated context files. This creates a cleaner separation between:
- **Agent files**: Core identity, tools, critical requirements (what)
- **Flow files**: Detailed execution stages, examples, patterns (how)

MCP Canary Check is deferred to a later phase after agent simplification proves successful.

## Phases

### Phase 1: Analyze Current Agent Instruction Structure

**Status**: [NOT STARTED]

**Objectives**:
1. Identify all instruction categories in lean-research-agent.md
2. Identify all instruction categories in lean-implementation-agent.md
3. Determine what belongs in agent vs context file
4. Design context file structure

**Files to analyze**:
- `.claude/agents/lean-research-agent.md` (438 lines)
- `.claude/agents/lean-implementation-agent.md` (528 lines)

**Classification Framework**:

| Category | Keep in Agent | Move to Context |
|----------|---------------|-----------------|
| Frontmatter/identity | Yes | No |
| Overview/purpose | Yes | No |
| Allowed tools list | Yes | No |
| Context references | Yes | No |
| Search decision tree | Yes | No (quick reference) |
| Stage 0 (early metadata) | Yes | No (critical for recovery) |
| Stages 1-7/8 (detailed execution) | Reference only | Yes |
| Error handling patterns | Reference only | Yes |
| Return format examples | Reference only | Yes |
| Critical requirements | Yes | No |

**Steps**:
1. Read lean-research-agent.md and categorize each section
2. Read lean-implementation-agent.md and categorize each section
3. Document sections to extract (with line ranges)
4. Design target file structure

**Output**:
- Categorized section list for each agent
- Target context file outline

**Verification**:
- [ ] All sections categorized
- [ ] Clear boundary defined between agent/context content
- [ ] Context file structure designed

---

### Phase 2: Create Lean Research Flow Context File

**Status**: [NOT STARTED]

**Objectives**:
1. Create `.claude/context/project/lean4/agents/lean-research-flow.md`
2. Extract detailed execution stages (1-7) from lean-research-agent.md
3. Include complete JSON examples and error handling patterns
4. Add cross-references to related context files

**Files to create**:
- `.claude/context/project/lean4/agents/lean-research-flow.md`

**Steps**:
1. Create directory `.claude/context/project/lean4/agents/` if not exists
2. Extract and organize content:
   - Stage 1: Parse Delegation Context (with JSON example)
   - Stage 2: Analyze Task and Determine Search Strategy
   - Stage 3: Execute Primary Searches (with rate limit management)
   - Stage 4: Synthesize Findings
   - Stage 5: Create Research Report (with full template)
   - Stage 6: Write Metadata File (with JSON schema)
   - Stage 7: Return Brief Text Summary (with examples)
3. Add comprehensive Error Handling section:
   - MCP Tool Error Recovery (with fallback table)
   - Rate Limit Handling
   - No Results Found
   - Timeout/Interruption
   - Invalid Task
4. Add Search Fallback Chain documentation
5. Add Partial Result Guidelines
6. Include Return Format Examples (successful, partial, failed)

**Content Structure**:
```markdown
# Lean Research Execution Flow

Reference: Load when executing lean-research-agent after Stage 0.

## Prerequisites
- Early metadata initialized (Stage 0 complete)
- Task context parsed from delegation

## Stage 1: Parse Delegation Context
{full content with JSON example}

## Stage 2: Analyze Task and Determine Search Strategy
{full content}

## Stage 3: Execute Primary Searches
{full content with rate limit management}

## Stage 4: Synthesize Findings
{full content}

## Stage 5: Create Research Report
{full content with complete template}

## Stage 6: Write Metadata File
{full content with JSON schema}

## Stage 7: Return Brief Text Summary
{full content with examples}

## Error Handling

### MCP Tool Error Recovery
{fallback table, retry patterns}

### Rate Limit Handling
{strategy and fallbacks}

### No Results Found
{guidance}

### Timeout/Interruption
{partial save pattern}

## Search Fallback Chain
{diagram and explanation}

## Partial Result Guidelines
{when partial, what to include}

## Return Format Examples
{successful, partial, failed}
```

**Verification**:
- [ ] File created with complete Stage 1-7 content
- [ ] All JSON examples preserved and accurate
- [ ] Error handling section complete
- [ ] Cross-references to related context files added

---

### Phase 3: Create Lean Implementation Flow Context File

**Status**: [NOT STARTED]

**Objectives**:
1. Create `.claude/context/project/lean4/agents/lean-implementation-flow.md`
2. Extract detailed execution stages (1-8) from lean-implementation-agent.md
3. Include proof development loop, tactic patterns, and error handling
4. Add phase checkpoint protocol documentation

**Files to create**:
- `.claude/context/project/lean4/agents/lean-implementation-flow.md`

**Steps**:
1. Extract and organize content:
   - Stage 1: Parse Delegation Context
   - Stage 2: Load and Parse Implementation Plan
   - Stage 3: Find Resume Point
   - Stage 4: Execute Proof Development Loop (detailed subsections)
   - Stage 5: Run Final Build Verification
   - Stage 6: Create Implementation Summary
   - Stage 6a: Generate Completion Data
   - Stage 7: Write Metadata File
   - Stage 8: Return Brief Text Summary
2. Include Phase Checkpoint Protocol (full detail)
3. Include Proof Development Loop Details:
   - Tactic Selection Strategy
   - When Stuck guidance
4. Add Error Handling section:
   - MCP Tool Error Recovery (with fallback table)
   - Build Failure
   - Proof Stuck
   - Timeout/Interruption
   - Invalid Task or Plan
5. Include Return Format Examples

**Content Structure**:
```markdown
# Lean Implementation Execution Flow

Reference: Load when executing lean-implementation-agent after Stage 0.

## Prerequisites
- Early metadata initialized (Stage 0 complete)
- Implementation plan available

## Stage 1: Parse Delegation Context
{full content}

## Stage 2: Load and Parse Implementation Plan
{full content}

## Stage 3: Find Resume Point
{full content with status markers}

## Stage 4: Execute Proof Development Loop
{full content with subsections A-D}

### 4A. Mark Phase In Progress
### 4B. Execute Proof Development
### 4C. Verify Phase Completion
### 4D. Mark Phase Complete

## Stage 5: Run Final Build Verification
{full content}

## Stage 6: Create Implementation Summary
{full content with template}

## Stage 6a: Generate Completion Data
{full content with examples}

## Stage 7: Write Metadata File
{full content with JSON schema}

## Stage 8: Return Brief Text Summary
{full content with examples}

## Phase Checkpoint Protocol
{full documentation}

## Proof Development Loop Details

### Tactic Selection Strategy
{1. Start Simple, 2. Structural, 3. Application, 4. Automation}

### When Stuck
{5-10 attempt strategy, search tools, different approach}

## Error Handling
{Build Failure, Proof Stuck, Timeout, Invalid Task}

## Return Format Examples
{successful, partial, failed}
```

**Verification**:
- [ ] File created with complete Stage 1-8 content
- [ ] Proof development loop fully documented
- [ ] Phase checkpoint protocol complete
- [ ] Error handling patterns included
- [ ] Return format examples accurate

---

### Phase 4: Simplify lean-research-agent.md

**Status**: [NOT STARTED]

**Objectives**:
1. Reduce lean-research-agent.md to ~100-150 lines
2. Replace detailed execution stages with @-reference to flow file
3. Preserve Stage 0, critical requirements, and quick references
4. Verify agent still functions correctly

**Files to modify**:
- `.claude/agents/lean-research-agent.md`

**Steps**:
1. Create backup: `cp lean-research-agent.md lean-research-agent.md.backup`
2. Rewrite agent file with structure:

```markdown
---
name: lean-research-agent
description: Research Lean 4 and Mathlib for theorem proving tasks
---

# Lean Research Agent

## Overview
{2-3 lines: purpose, invocation, return format}

## Agent Metadata
{name, purpose, invoked by, return format - condensed}

## Allowed Tools

### File Operations
{compact list}

### Lean MCP Tools
{compact list with MCP scope note}

## Context References
{@-references to flow file and formats}

## Search Decision Tree
{keep as quick reference - 6 items}

## Stage 0: Initialize Early Metadata
{keep full content - critical for recovery}

## Execution
After Stage 0, load and follow @.claude/context/project/lean4/agents/lean-research-flow.md

## Critical Requirements

**MUST DO**:
{condensed list of 9 items}

**MUST NOT**:
{condensed list of 10 items}
```

3. Remove all detailed stages (1-7), error handling details, return format examples
4. Update Context References to point to flow file

**Target line count**: 100-150 lines

**Verification**:
- [ ] Agent file reduced to <150 lines
- [ ] Stage 0 preserved in full
- [ ] Critical requirements preserved
- [ ] @-reference to flow file present
- [ ] Search decision tree preserved (quick reference)

---

### Phase 5: Simplify lean-implementation-agent.md

**Status**: [NOT STARTED]

**Objectives**:
1. Reduce lean-implementation-agent.md to ~100-150 lines
2. Replace detailed execution stages with @-reference to flow file
3. Preserve Stage 0, critical requirements, and tool references
4. Verify agent still functions correctly

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md`

**Steps**:
1. Create backup: `cp lean-implementation-agent.md lean-implementation-agent.md.backup`
2. Rewrite agent file with structure:

```markdown
---
name: lean-implementation-agent
description: Implement Lean 4 proofs following implementation plans
---

# Lean Implementation Agent

## Overview
{2-3 lines: purpose, invocation, return format}

## Agent Metadata
{condensed}

## Allowed Tools
{compact lists for File Operations and Lean MCP Tools}

## Context References
{@-references to flow file and formats}

## Stage 0: Initialize Early Metadata
{keep full content - critical for recovery}

## Execution
After Stage 0, load and follow @.claude/context/project/lean4/agents/lean-implementation-flow.md

## Critical Requirements

**MUST DO**:
{condensed list of 12 items}

**MUST NOT**:
{condensed list of 12 items}
```

3. Remove detailed stages (1-8), proof loop details, checkpoint protocol, return examples
4. Update Context References to point to flow file

**Target line count**: 100-150 lines

**Verification**:
- [ ] Agent file reduced to <150 lines
- [ ] Stage 0 preserved in full
- [ ] Critical requirements preserved
- [ ] @-reference to flow file present

---

### Phase 6: Validation Testing

**Status**: [NOT STARTED]

**Objectives**:
1. Test simplified lean-research-agent with actual task
2. Test simplified lean-implementation-agent with actual task
3. Verify context loading works correctly
4. Document any issues and iterate

**Steps**:
1. Select a simple Lean task for testing (or create test task)
2. Run `/research` on test task
3. Verify:
   - Agent loads successfully
   - Flow file is referenced/used
   - Research completes without hanging
   - Report artifact created correctly
   - Metadata written correctly
4. Run `/implement` on test task (if researched and planned)
5. Verify:
   - Agent loads successfully
   - Flow file is referenced/used
   - Phase execution works
   - Build verification runs
   - Summary and metadata created
6. Document results
7. If issues found, iterate on Phases 4-5

**Test Cases**:
1. Research: Agent initializes, references flow file, completes research
2. Implementation: Agent initializes, references flow file, executes phases

**Verification**:
- [ ] /research completes successfully
- [ ] /implement completes successfully (if testable)
- [ ] No hanging observed
- [ ] All artifacts created correctly
- [ ] Performance acceptable (no significant regression)

---

### Phase 7: (Deferred) MCP Canary Check

**Status**: [NOT STARTED]
**Priority**: Deferred

**Note**: This phase is intentionally deferred. After Phase 6 validation proves the simplified agents work reliably, we can assess whether MCP Canary Check is still needed.

**If implemented later**:
1. Add Stage 0.5 (MCP Availability Check) after Stage 0 in both agents
2. Use `lean_local_search` with query "Nat" as canary
3. Fail fast with clear guidance if MCP unavailable

**Rationale for deferral**: The primary benefit of agent simplification may reduce hanging issues by:
- Reducing prompt complexity
- Faster agent initialization
- Clearer execution paths

If hanging persists after simplification, this phase provides an additional mitigation.

---

## Dependencies

- None (self-contained meta task)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Simplified agents lose critical instructions | High | Medium | Comprehensive categorization in Phase 1, keep MUST DO/MUST NOT |
| @-reference loading fails | High | Low | Test thoroughly in Phase 6, backup files available |
| Context file too large | Medium | Low | Focus on essential content, remove duplication |
| Agent performance degradation | Medium | Medium | Measure before/after in Phase 6 |

## Rollback Plan

If changes cause issues:
1. Restore from backup files (*.backup)
2. Git revert to pre-implementation state
3. Flow context files can be deleted without affecting other components

## Success Criteria

- [ ] Detailed execution stages extracted to context files
- [ ] lean-research-agent.md reduced to <150 lines
- [ ] lean-implementation-agent.md reduced to <150 lines
- [ ] All critical instructions preserved
- [ ] Context file @-references work correctly
- [ ] /research and /implement function correctly
- [ ] No hanging observed during testing
- [ ] Agents feel "robust and dependable"

## Notes

The focus is on creating high-quality, maintainable lean subagents. By separating "what the agent is" (identity, tools, requirements) from "how the agent executes" (detailed stages, examples, patterns), we gain:

1. **Clarity**: Agent files are scannable overviews
2. **Maintainability**: Execution details can be updated independently
3. **Performance**: Smaller agent prompts may load faster
4. **Reusability**: Flow patterns can inform other agent designs
