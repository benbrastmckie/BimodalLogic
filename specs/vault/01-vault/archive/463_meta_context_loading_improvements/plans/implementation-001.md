# Implementation Plan: Task #463

- **Task**: 463 - Improve /meta Context Loading
- **Version**: 001
- **Created**: 2026-01-12
- **Language**: meta
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/463_meta_context_loading_improvements/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, artifact-formats.md, subagent-return.md

## Overview

Restructure the context loading patterns in meta-builder-agent.md to match the successful patterns used by planner-agent.md and general-implementation-agent.md. The key improvements are: (1) stage-based context loading with explicit timing, (2) mode-specific context matrices, and (3) progressive disclosure of component guides during the interview workflow. This aligns /meta with the working /research, /plan, /implement commands.

### Research Integration

Key findings from research-001.md:
- planner-agent uses categorized context loading ("Always Load", "Load When Creating Plan", "Load for Context")
- meta-builder-agent has context references but lacks stage-to-context mapping
- index.md already contains detailed meta workflow guidance (lines 389-407) not reflected in agent file
- /meta differs from task-based commands: creates tasks rather than operating on existing ones, requiring mode-based (not language-based) context routing

## Goals & Non-Goals

**Goals**:
- Restructure meta-builder-agent.md Context References section to use stage-based loading
- Add mode-context matrix showing which files to load for each mode
- Add interview stage context triggers for progressive loading
- Mirror the index.md guidance within the agent file itself

**Non-Goals**:
- Modifying functional behavior of /meta command
- Changing the interview workflow stages
- Updating skill-meta or meta.md command files (thin wrappers, no context changes needed)
- Creating new component guide files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Guidance duplication between agent and index.md | Low | High | Make agent authoritative, reference from index.md |
| Over-complex context loading instructions | Medium | Medium | Keep matrix format simple, test readability |
| Breaking existing /meta behavior | Medium | Low | Changes are documentation-only, no functional changes |

## Implementation Phases

### Phase 1: Restructure Context References Section [COMPLETED]

**Goal**: Replace the current Context References section with stage-based loading guidance matching planner-agent pattern

**Tasks**:
- [ ] Read current meta-builder-agent.md Context References (lines 50-66)
- [ ] Create new Context References structure with "Always Load", "Stage-Based Loading", "On-Demand Loading" sections
- [ ] Map each stage (1-8) to required context files
- [ ] Replace lines 50-66 with new structured content

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/agents/meta-builder-agent.md` - lines 50-66

**New Content Structure**:
```markdown
## Context References

Load these on-demand using @-references:

**Always Load (All Modes)**:
- `@.claude/context/core/formats/subagent-return.md` - Return format schema

**Stage 1 (Parse Delegation Context)**:
- No additional context needed

**Stage 2 (Context Loading - Mode-Based)**:
| Mode | Files to Load |
|------|---------------|
| interactive | `@.claude/docs/guides/component-selection.md` (after Stage 0 inventory) |
| prompt | `@.claude/docs/guides/component-selection.md` |
| analyze | `@.claude/CLAUDE.md`, `@.claude/context/index.md` |

**Stages 2-5 (Interview - On-Demand)**:
- When user selects commands: `@.claude/docs/guides/creating-commands.md`
- When user selects skills/agents: `@.claude/docs/guides/creating-skills.md`, `@.claude/docs/guides/creating-agents.md`
- When discussing templates: `@.claude/context/core/templates/thin-wrapper-skill.md`, `@.claude/context/core/templates/agent-template.md`

**Stages 6-7 (Task Creation)**:
- Direct file access: `specs/TODO.md`, `specs/state.json`
- No additional context files needed (formats already loaded)

**Stage 8 (Cleanup)**:
- No additional context needed
```

**Verification**:
- New section follows planner-agent pattern structure
- All 8 stages have explicit context guidance
- Mode-based differentiation is clear

---

### Phase 2: Add Mode-Context Matrix [COMPLETED]

**Goal**: Add explicit matrix showing which context files are needed for each mode and stage

**Tasks**:
- [ ] Create new section after Context References titled "Mode-Context Matrix"
- [ ] Build matrix with columns: Context File, Interactive, Prompt, Analyze
- [ ] Document loading timing for each cell (Stage N, On-demand, No)
- [ ] Insert after line 66 (end of Context References)

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/agents/meta-builder-agent.md` - insert after Context References

**New Content**:
```markdown
## Mode-Context Matrix

Quick reference for context loading by mode:

| Context File | Interactive | Prompt | Analyze |
|--------------|-------------|--------|---------|
| subagent-return.md | Always | Always | Always |
| component-selection.md | Stage 2 | Stage 2 | No |
| creating-commands.md | On-demand* | On-demand* | No |
| creating-skills.md | On-demand* | On-demand* | No |
| creating-agents.md | On-demand* | On-demand* | No |
| thin-wrapper-skill.md | On-demand* | On-demand* | No |
| agent-template.md | On-demand* | On-demand* | No |
| CLAUDE.md | No | No | Stage 2 |
| index.md | No | No | Stage 2 |
| TODO.md | Stage 6 | Stage 5 | Stage 1** |
| state.json | Stage 6 | Stage 5 | Stage 1** |

*On-demand: Load when user discussion involves that component type
**Analyze mode reads but does not modify
```

**Verification**:
- Matrix covers all context files mentioned in research
- Each mode has distinct loading pattern visible
- Timing is explicit and matches stage definitions

---

### Phase 3: Add Interview Stage Context Triggers [COMPLETED]

**Goal**: Add context loading trigger documentation within each interview stage

**Tasks**:
- [ ] Add "Context Loading Trigger" subsection to Interview Stage 2 (GatherDomainInfo)
- [ ] Add "Context Loading Trigger" subsection to Interview Stage 3 (IdentifyUseCases)
- [ ] Add brief trigger notes to other stages where context loading occurs

**Timing**: 0.75 hours

**Files to modify**:
- `.claude/agents/meta-builder-agent.md` - Interview stages in Stage 3A section

**Content Additions**:

At Interview Stage 2 (GatherDomainInfo), after "Capture: purpose, change_type":
```markdown
**Context Loading Trigger**:
- If user selects "Add a new command" -> Load `creating-commands.md`
- If user selects "Add a new skill or agent" -> Load `creating-skills.md` AND `creating-agents.md`
- If user selects "Fix or enhance existing" -> Load relevant existing component file
```

At Interview Stage 3 (IdentifyUseCases), after options:
```markdown
**Context Loading Trigger**:
- If "Help me break it down" selected -> Load `component-selection.md` decision tree
- If discussing template-based components -> Load relevant template file
```

**Verification**:
- Each stage with context loading has explicit trigger conditions
- Triggers match the on-demand pattern from the matrix
- Progressive disclosure is documented

---

### Phase 4: Update index.md Cross-Reference [COMPLETED]

**Goal**: Update index.md to reference meta-builder-agent.md as authoritative source

**Tasks**:
- [ ] Read current index.md meta workflow section (lines 389-407)
- [ ] Replace detailed guidance with reference to meta-builder-agent.md
- [ ] Keep brief summary for quick navigation

**Timing**: 0.25 hours

**Files to modify**:
- `.claude/context/index.md` - lines 389-407

**New Content**:
```markdown
**Meta Workflow (meta-builder-agent)**:
```
See `.claude/agents/meta-builder-agent.md` for complete stage-by-stage context loading guidance.

Quick reference:
- Interactive/Prompt modes: component-selection.md + on-demand component guides
- Analyze mode: CLAUDE.md + index.md (read-only analysis)
- All modes: subagent-return.md (always)
```
```

**Verification**:
- index.md no longer duplicates agent-level detail
- Cross-reference is clear
- Quick reference remains for navigation

---

### Phase 5: Verification and Testing [COMPLETED]

**Goal**: Verify all changes are consistent and complete

**Tasks**:
- [ ] Read through updated meta-builder-agent.md for consistency
- [ ] Verify all stage numbers match between Context References, Matrix, and Interview sections
- [ ] Check that all @-references use correct file paths
- [ ] Ensure no broken references in index.md
- [ ] Test readability of new matrix format

**Timing**: 0.5 hours

**Files to review**:
- `.claude/agents/meta-builder-agent.md` - complete file
- `.claude/context/index.md` - meta workflow section

**Verification**:
- All stage numbers consistent (1-8 in agent, matching interview stages)
- All file paths valid (glob to verify)
- No circular references or duplication
- Matrix readable at a glance

---

## Testing & Validation

- [ ] meta-builder-agent.md has Context References section matching planner-agent pattern
- [ ] Mode-Context Matrix is present and complete
- [ ] Interview stages have context loading triggers
- [ ] index.md references agent file without duplication
- [ ] All @-references point to existing files
- [ ] Stage numbering is consistent throughout document

## Artifacts & Outputs

- `.claude/agents/meta-builder-agent.md` - Updated with improved context loading
- `.claude/context/index.md` - Updated meta workflow section with cross-reference

## Rollback/Contingency

If changes cause issues:
1. Revert meta-builder-agent.md using git: `git checkout HEAD -- .claude/agents/meta-builder-agent.md`
2. Revert index.md using git: `git checkout HEAD -- .claude/context/index.md`
3. Original content preserved in git history
