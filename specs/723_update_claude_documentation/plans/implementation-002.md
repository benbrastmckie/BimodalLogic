# Implementation Plan: Task #723

- **Task**: 723 - update_claude_documentation
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/723_update_claude_documentation/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file, revision of implementation-001.md)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Restructure CLAUDE.md and ARCHITECTURE.md with clear role separation:

- **CLAUDE.md**: Optimized for loading every session. Contains exactly the essential information agents need to operate. No quick start, no redundancy, no nice-to-have explanations.
- **ARCHITECTURE.md**: User-facing documentation about how the agent system works. Comprehensive, explanatory, for humans who want to understand the system.

### Key Insight from Revision

The original plan (v1) added a "Getting Started" section to CLAUDE.md. This was wrong because:
1. CLAUDE.md is loaded into context every session - clutter costs tokens
2. Quick start guides are for humans, not agents
3. Redundancy between CLAUDE.md and ARCHITECTURE.md wastes context budget

The revised approach optimizes CLAUDE.md as minimal agent context and positions ARCHITECTURE.md as the user-facing documentation.

### Research Integration

Key findings from research-001.md still apply:
- CLAUDE.md is ~500 lines, can be reduced
- ARCHITECTURE.md is ~975 lines, appropriate for user documentation
- 13 commands need documentation (belongs in ARCHITECTURE.md, not CLAUDE.md)
- Some outdated references need fixing

## Goals & Non-Goals

**Goals**:
- Reduce CLAUDE.md to essential agent context (<350 lines)
- Remove verbose explanations, tutorials, and redundant content from CLAUDE.md
- Keep ARCHITECTURE.md as comprehensive user-facing documentation
- Fix outdated references in both files
- Clear role separation: CLAUDE.md = agent context, ARCHITECTURE.md = user docs

**Non-Goals**:
- Adding getting started sections or tutorials to CLAUDE.md
- Making CLAUDE.md beginner-friendly (it's for agents)
- Reducing ARCHITECTURE.md (it should be comprehensive)
- Changes to individual command files (.claude/commands/)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing essential agent information | High | Medium | Review each removed section carefully, verify agents don't need it |
| Users confused where to find docs | Medium | Low | Add clear reference at top of CLAUDE.md pointing to ARCHITECTURE.md |
| Breaking existing Claude behavior | High | Low | Test key workflows after changes |

## Implementation Phases

### Phase 1: Analyze CLAUDE.md Content [COMPLETED]

**Goal**: Identify what's essential agent context vs what belongs in ARCHITECTURE.md or nowhere.

**Tasks**:
- [ ] Read CLAUDE.md and categorize each section:
  - **Essential**: Status markers, artifact paths, routing tables, state.json structure, blocked tools, rules references
  - **Move to ARCHITECTURE.md**: Detailed explanations, patterns, execution flows
  - **Remove**: Redundant content already in ARCHITECTURE.md, verbose explanations
- [ ] Create a mapping of what stays, what moves, what's removed

**Timing**: 30 minutes

**Categorization Criteria**:
- Essential = Agent needs this to execute commands correctly
- Move = User might want to know this, but agent doesn't need it in context
- Remove = Already exists elsewhere or adds no value

---

### Phase 2: Streamline CLAUDE.md [COMPLETED]

**Goal**: Reduce CLAUDE.md to essential agent context.

**Tasks**:
- [ ] Remove verbose sections that duplicate ARCHITECTURE.md:
  - Detailed "Checkpoint-Based Execution Model" explanation (keep only the diagram)
  - Verbose "Session Tracking" details
  - Entire "Skill Architecture" section (detailed patterns belong in ARCHITECTURE.md)
  - "Thin Wrapper Skill Pattern" details
  - "Custom Agent Registration" details
  - "Thin Wrapper Execution Flow" details
  - "Benefits" section
  - "Related Documentation" extensive list
  - Most of "Session Maintenance" (keep just the command reference)
- [ ] Consolidate command documentation to single-line references
- [ ] Add header note: "For comprehensive documentation, see ARCHITECTURE.md"
- [ ] Keep only: Quick Reference, Status Markers, Artifact Paths, Language Routing table, Command quick refs, Blocked MCP tools, Rules References, Error handling essentials

**Timing**: 45 minutes

**Target Structure for CLAUDE.md**:
```
# ProofChecker Development System
[1-line description + pointer to ARCHITECTURE.md]

## Quick Reference
[5 lines - pointers to key files]

## Task Management
### Status Markers [10 lines]
### Artifact Paths [10 lines]
### Language Routing [table, 10 lines]

## Commands [50 lines total]
[Single-line per command with example]

## State Synchronization [15 lines]
[state.json structure only]

## Lean 4 Integration [25 lines]
[Blocked tools + search decision tree only]

## Rules & Context References [15 lines]
[File references only]

## Error Handling [10 lines]
[Recovery patterns summary]

## Important Notes [5 lines]
```

**Verification**:
- CLAUDE.md is under 350 lines
- All essential agent context preserved
- No redundant explanations

---

### Phase 3: Enhance ARCHITECTURE.md [COMPLETED]

**Goal**: Ensure ARCHITECTURE.md serves as comprehensive user documentation.

**Tasks**:
- [ ] Verify ARCHITECTURE.md has all content that was removed from CLAUDE.md
- [ ] Add any missing detailed explanations
- [ ] Update header to clarify it's user-facing documentation
- [ ] Ensure command workflows are fully documented
- [ ] Add cross-references for navigation

**Timing**: 30 minutes

**Files to modify**:
- `.claude/ARCHITECTURE.md` - Enhance as user documentation

**Verification**:
- ARCHITECTURE.md is comprehensive and standalone
- All patterns and workflows are explained for users
- Clear navigation structure

---

### Phase 4: Fix Outdated References [COMPLETED]

**Goal**: Update incorrect file paths and references in both files.

**Tasks**:
- [ ] Fix project structure section (add `Theories/` alongside `Logos/`)
- [ ] Fix line 159 of ARCHITECTURE.md references `.claude/agent/orchestrator.md` - update or remove
- [ ] Verify all file path references exist
- [ ] Update any deprecated pattern mentions

**Timing**: 20 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Fix references
- `.claude/ARCHITECTURE.md` - Fix references

**Known Issues to Fix**:
1. ARCHITECTURE.md references `.claude/agent/orchestrator.md` - doesn't exist
2. Project structure shows only `Logos/` but `Theories/` also exists

**Verification**:
- All referenced files exist
- Project structure matches actual directory layout

---

### Phase 5: Final Validation [COMPLETED]

**Goal**: Verify the restructured documentation meets all requirements.

**Tasks**:
- [ ] Count CLAUDE.md lines - must be <350
- [ ] Verify all essential agent context is present in CLAUDE.md
- [ ] Verify ARCHITECTURE.md is comprehensive for users
- [ ] Test that a sample workflow still works
- [ ] Check cross-references are accurate

**Timing**: 15 minutes

**Verification Checklist**:
- [ ] CLAUDE.md under 350 lines
- [ ] No quick start or tutorials in CLAUDE.md
- [ ] ARCHITECTURE.md comprehensive for users
- [ ] All file paths valid
- [ ] Cross-references work
- [ ] Role separation is clear

## Testing & Validation

- [ ] Run `/research 9999` on non-existent task to verify CLAUDE.md context loads correctly
- [ ] Check that key command patterns still work
- [ ] Verify ARCHITECTURE.md answers user questions comprehensively

## Artifacts & Outputs

- `plans/implementation-002.md` - This revised plan
- `.claude/CLAUDE.md` - Streamlined agent context (primary deliverable)
- `.claude/ARCHITECTURE.md` - User documentation with minor fixes
- `summaries/implementation-summary-20260128.md` - Completion summary

## Rollback/Contingency

If changes cause issues:
1. Git revert the CLAUDE.md changes
2. Original content preserved in git history
3. Can incrementally re-apply changes one phase at a time
