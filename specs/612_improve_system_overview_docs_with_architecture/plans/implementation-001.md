# Implementation Plan: Task #612

- **Task**: 612 - improve_system_overview_docs_with_architecture
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: Task 609 (Document command-skill-agent architecture), Task 611 (Context optimization)
- **Research Inputs**: specs/612_improve_system_overview_docs_with_architecture/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task corrects inaccurate documentation in `.claude/context/core/architecture/system-overview.md` that claims skills use `context: fork` and `agent:` frontmatter fields (they do not). The implementation documents the three actual architecture patterns discovered during research: (A) delegating skills with internal postflight, (B) direct execution skills, and (C) orchestrator/routing skills. Diagrams will be updated to use Unicode box-drawing characters for improved rendering.

### Research Integration

Key findings from research-001.md integrated into this plan:
- Skills use `allowed-tools: Task, Bash, Edit, Read, Write` NOT `context: fork` or `agent:`
- 8 skills use Pattern A (delegating with internal postflight)
- 3 skills use Pattern B (direct execution)
- 1 skill uses Pattern C (orchestrator/routing)
- Metadata file exchange pattern is the standard (not JSON to console)
- Context loaded via @-references in agent bodies (not frontmatter)

## Goals & Non-Goals

**Goals**:
- Remove incorrect `context: fork` and `agent:` claims from system-overview.md
- Document all three architecture patterns with motivations
- Update all diagrams to use Unicode box-drawing characters
- Add comprehensive command-skill-agent mapping matrix
- Ensure agent-facing and user-facing documentation are consistent

**Non-Goals**:
- Changing actual skill/agent implementations
- Creating new skills or agents
- Modifying the workflow execution patterns
- Updating CLAUDE.md (already accurate)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Unicode characters render incorrectly | Low | Low | Test in common terminals (VSCode, iTerm, basic terminal) |
| Documentation drift after changes | Medium | Medium | Add "Last Verified" date to document header |
| Breaking cross-references | Medium | Low | Verify all @-references still resolve |
| Missing pattern documentation | High | Low | Cross-check against actual skill files |

## Implementation Phases

### Phase 1: Fix Inaccurate Frontmatter Documentation [NOT STARTED]

**Goal**: Remove incorrect `context: fork` and `agent:` claims from Layer 2 section

**Tasks**:
- [ ] Update Layer 2 (Skills) section to remove `context: fork` from example
- [ ] Remove `agent: {agent-name}` from thin wrapper pattern example
- [ ] Update description to say "thin wrappers with internal postflight" not just "validation"
- [ ] Change `allowed-tools: Task` to `allowed-tools: Task, Bash, Edit, Read, Write` to match reality
- [ ] Add note that skills handle lifecycle operations internally

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/architecture/system-overview.md` - Lines 91-117

**Verification**:
- No references to `context: fork` or `agent:` in skill frontmatter
- Example matches actual skill frontmatter structure

---

### Phase 2: Document Three Architecture Patterns [NOT STARTED]

**Goal**: Add new section documenting Pattern A, B, and C with motivations

**Tasks**:
- [ ] Add new section "## Skill Architecture Patterns" after Layer Details
- [ ] Document Pattern A: Delegating Skills with Internal Postflight (8 skills)
  - List skills: skill-researcher, skill-lean-research, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation, skill-meta, skill-document-converter
  - Include 11-stage execution flow
  - Explain motivation (eliminates continue prompt)
- [ ] Document Pattern B: Direct Execution Skills (3 skills)
  - List skills: skill-status-sync, skill-cleanup, skill-git-workflow
  - Show simpler frontmatter (no Task tool)
  - Explain motivation (atomic operations, no subagent overhead)
- [ ] Document Pattern C: Orchestrator/Routing Skills (1 skill)
  - Describe skill-orchestrator
  - Show routing intelligence characteristics
  - Explain motivation (centralized routing decisions)
- [ ] Add pattern selection decision tree for new skill creation

**Timing**: 45 minutes

**Files to modify**:
- `.claude/context/core/architecture/system-overview.md` - New section after line 118

**Verification**:
- All 12 skills categorized into one of the three patterns
- Each pattern has motivation explanation
- Pattern selection guidance provided

---

### Phase 3: Update Diagrams to Unicode [NOT STARTED]

**Goal**: Convert all ASCII box-drawing to Unicode characters for better rendering

**Tasks**:
- [ ] Update main architecture diagram (lines 14-41)
  - Replace `+` corners with `┌`, `┐`, `└`, `┘`
  - Replace `-` with `─`
  - Replace `|` with `│`
  - Replace `v` arrows with `▼`
- [ ] Update delegation flow diagram (lines 165-230)
  - Apply same character replacements
  - Improve alignment with Unicode characters
- [ ] Update checkpoint-based execution diagram (lines 239-246)
  - Convert to Unicode box-drawing
  - Replace `-->` with `─▶` or `→`
- [ ] Update error handling diagram (lines 300-314)
  - Apply same character replacements

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/architecture/system-overview.md` - Multiple diagram sections

**Verification**:
- All diagrams render correctly in VSCode preview
- No mixed ASCII/Unicode in same diagram
- Consistent character usage across all diagrams

---

### Phase 4: Add Command-Skill-Agent Mapping Matrix [NOT STARTED]

**Goal**: Add comprehensive matrix showing all command routing paths

**Tasks**:
- [ ] Add new section "## Command-Skill-Agent Mapping" after Language-Based Routing
- [ ] Create detailed table with columns: Command, Routing Type, Skill(s), Agent(s), Pattern
- [ ] Include all commands: /research, /plan, /implement, /revise, /meta, /convert, /review, /errors, /todo, /task, /cleanup, /refresh
- [ ] Note which commands use language-based routing vs single routing
- [ ] Indicate which pattern each skill uses (A, B, or C)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/architecture/system-overview.md` - New section after line 293

**Verification**:
- All commands documented
- Mapping matches actual implementation
- Pattern column correctly identifies A, B, or C

---

### Phase 5: Reconcile Agent and User Documentation [NOT STARTED]

**Goal**: Ensure consistency between agent-facing and user-facing docs

**Tasks**:
- [ ] Review `.claude/docs/architecture/system-overview.md` for inconsistencies
- [ ] Update user-facing doc if it contains `context: fork` claims
- [ ] Add "Last Verified" metadata to both files
- [ ] Cross-reference the two documents appropriately
- [ ] Update Related Documentation section in both files

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/architecture/system-overview.md` - Header and Related Documentation
- `.claude/docs/architecture/system-overview.md` - If inconsistencies found

**Verification**:
- No conflicting information between the two files
- Both files have "Last Verified" dates
- Cross-references are bidirectional

## Testing & Validation

- [ ] All diagrams render correctly in markdown preview
- [ ] No broken @-references in document
- [ ] All 12 skills categorized into patterns
- [ ] All commands mapped in matrix
- [ ] No references to `context: fork` or `agent:` frontmatter fields
- [ ] User-facing and agent-facing docs are consistent

## Artifacts & Outputs

- `specs/612_improve_system_overview_docs_with_architecture/plans/implementation-001.md` (this file)
- `.claude/context/core/architecture/system-overview.md` (updated)
- `.claude/docs/architecture/system-overview.md` (updated if needed)
- `specs/612_improve_system_overview_docs_with_architecture/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If changes cause issues:
1. Git revert the commit for this task
2. The original system-overview.md is preserved in git history
3. Research findings remain valid for future attempt
