# Research Report: Task #885 (Supplementary)

**Task**: 885 - Blocker Detection and User Review Triggers
**Date**: 2026-02-16
**Focus**: Context file optimization for /implement workflow
**Session**: sess_1771308500_3db6bd
**Related Research**: research-001.md (blocker taxonomy)

## Summary

This supplementary research maps context file dependencies in the /implement command-skill-agent workflow. Analysis reveals significant optimization opportunities: 4 files can be consolidated, 2 are redundant, and 3 loading patterns are inefficient. Key recommendations include creating a quick-reference for return-metadata-file.md and consolidating agent flow files to reduce duplicate content.

## Findings

### 1. Context File Dependency Map

#### /implement Command Flow

```
/implement N
    |
    v
[Orchestrator]
    - Loads: CLAUDE.md (rules auto-applied)
    - Queries: state.json (task lookup)
    |
    v
[skill-implementer OR skill-lean-implementation]
    - References (lazy): return-metadata-file.md, postflight-control.md, jq-escaping-workarounds.md
    - Note: These are NOT loaded by skill - passed to agent
    |
    v
[general-implementation-agent OR lean-implementation-agent]
    - Always Load: (none - return-metadata-file.md loaded by skill, per comment)
    - Load for Summary: summary-format.md
    - Load for Progress: artifact-formats.md (Progress Subsection section)
    - Load for Meta Tasks: CLAUDE.md, context/index.md
    - Load for Lean Tasks: mcp-tools-guide.md, proof-debt-policy.md, lean-implementation-flow.md
```

#### Files Referenced by Each Component

| Component | Files Referenced | Actual Loading |
|-----------|-----------------|----------------|
| skill-implementer | return-metadata-file.md, postflight-control.md, jq-escaping-workarounds.md | Lazy (comment: "do not load eagerly") |
| skill-lean-implementation | Same as above | Lazy |
| general-implementation-agent | summary-format.md, artifact-formats.md, index.md | On-demand via @-reference |
| lean-implementation-agent | mcp-tools-guide.md, proof-debt-policy.md, lean-implementation-flow.md, tactic-patterns.md, summary-format.md, artifact-formats.md | On-demand via @-reference |

### 2. Loading Efficiency Analysis

#### Files Loaded Multiple Times

| File | Loaded By | Issue |
|------|-----------|-------|
| `artifact-formats.md` | general-implementation-agent, lean-implementation-agent, via rules auto-apply | Redundant auto-apply for specs/** |
| `state-management.md` | Rules auto-apply, potentially re-read during postflight | 2x potential load |
| `summary-format.md` | Both implementation agents | Expected duplication (different invocations) |

#### Files Rarely Used After Loading

| File | Load Context | Usage Rate | Issue |
|------|--------------|------------|-------|
| `lean-research-flow.md` | lean-research-agent Stage 0 | Always loaded, rarely consulted fully | ~340 lines loaded but only sections used |
| `lean-implementation-flow.md` | lean-implementation-agent Stage 0 | Same pattern | ~340 lines |
| `mcp-tools-guide.md` | Lean agents | Reference material | ~380 lines but usually only Search Decision Tree needed |

#### Files Too Large for Their Purpose

| File | Lines | Purpose | Issue |
|------|-------|---------|-------|
| `return-metadata-file.md` | ~550 | Schema + examples | Examples redundant once schema learned |
| `index.md` | ~600 | Context discovery | Only ~20% needed per workflow |
| `error-handling.md` | ~280 | Error types + recovery | Mixed reference/operational content |

### 3. Gap Analysis

#### Information Agents Frequently Need But Is Missing or Hard to Find

1. **Quick Metadata Schema Reference**: Agents must read ~550 lines of return-metadata-file.md when they only need the ~50 line schema core
2. **Blocker Detection Guidance**: The new requires_user_review field (from research-001) needs clear examples accessible without full file read
3. **Progress Update Format**: Currently in artifact-formats.md but not easily discoverable; agents must search for "Progress Subsection"
4. **Summary Create-or-Append Logic**: Buried in summary-format.md, hard to find quickly

#### Patterns That Exist But Are Not Documented

1. **Early Metadata at Stage 0**: Well-documented in early-metadata-pattern.md, but agents don't reference it consistently
2. **Phase Entry Append Pattern**: Implemented in lean-implementation-flow.md Stage 4F but not consolidated
3. **Git Staging Scope**: Referenced but not defined in a centralized location

### 4. Task 883 Context Review

The task 883 implementation plan (implementation-001.md) referenced:
- artifact-formats.md (for Progress Subsection format)
- lean-implementation-agent.md (for checkpoint protocol)
- general-implementation-agent.md (for same)
- lean-implementation-flow.md (for Stage 4E)

**What would have helped**:
- Quick-reference card for agent modification patterns
- Consolidated "agent update checklist" for meta tasks that modify agents
- Clearer separation of "schema" vs "examples" in format files

## Recommendations

### 1. Create Metadata Quick Reference

**Action**: Create `metadata-quick-ref.md` (~100 lines) with:
- Core schema fields
- Status value table
- Common status patterns
- Link to full return-metadata-file.md for examples

**Benefit**: Agents load 100 lines instead of 550 when they only need schema

**Path**: `.claude/context/core/formats/metadata-quick-ref.md`

### 2. Consolidate Agent Flow Files

**Action**: Extract common patterns from lean-implementation-flow.md and general-implementation-agent.md into shared reference

**Current State**:
- `lean-implementation-flow.md`: ~340 lines
- Phase Checkpoint Protocol duplicated in both agent files

**Proposed**:
- Create `implementation-checkpoints.md` (~150 lines) with:
  - Phase Checkpoint Protocol
  - Summary Create-or-Append Logic
  - Progress Subsection Format
  - Git Commit Pattern
- Reference this from both agent flow files

**Benefit**: Single source of truth for checkpoint protocol, easier updates

### 3. Split return-metadata-file.md

**Current**: 550 lines mixing schema, examples, and usage instructions

**Proposed Split**:
| File | Content | Lines |
|------|---------|-------|
| `metadata-quick-ref.md` | Schema core, status values, required fields | ~100 |
| `return-metadata-file.md` | Full reference with all examples (rename to return-metadata-reference.md) | ~450 |

**Agent Loading Pattern**:
- Quick schema check: Load metadata-quick-ref.md only
- Need full examples: Load return-metadata-reference.md

### 4. Create Agent Update Checklist

**Action**: Create `.claude/context/project/meta/agent-update-checklist.md`

**Content**:
- Checklist for modifying agent definitions
- Common update locations (Context References, Critical Requirements, Execution Flow)
- Verification steps for agent updates
- Cross-reference to other files that may need updates (skills, flow files)

**Benefit**: Meta tasks that modify agents have clearer guidance

### 5. Add Progress Format Quick Reference

**Action**: Add direct link from artifact-formats.md header to Progress Subsection section

**Current Issue**: Progress Subsection is ~80 lines deep in artifact-formats.md

**Proposed**: Add to artifact-formats.md header:
```markdown
**Quick Links**:
- [Progress Subsection](#progress-subsection) - For phase progress tracking
- [Phase Status Markers](#phase-status-markers) - For plan file markers
```

### 6. Deprecate/Remove Redundant Files

**Analysis of context/core/patterns/**:

| File | Lines | Status | Recommendation |
|------|-------|--------|----------------|
| `anti-stop-patterns.md` | ~150 | Active | Keep (critical for agent behavior) |
| `skill-lifecycle.md` | ~100 | Active | Keep |
| `metadata-file-return.md` | ~100 | Overlaps with return-metadata-file.md | Consolidate into metadata-quick-ref.md |
| `thin-wrapper-skill.md` | ~120 | Duplicated in templates/ | Remove, keep templates/thin-wrapper-skill.md |
| `checkpoint-execution.md` | ~180 | Reference only | Keep |
| `early-metadata-pattern.md` | ~100 | Active | Keep |

### 7. Loading Pattern Changes

**Current Pattern (Eager Reference)**:
```markdown
## Context References

**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md`
```

**Proposed Pattern (Section-Specific)**:
```markdown
## Context References

**Load On-Demand**:
- For MCP tool selection: `@.claude/context/project/lean4/tools/mcp-tools-guide.md#search-decision-tree`
- For full tool reference: `@.claude/context/project/lean4/tools/mcp-tools-guide.md`
```

**Benefit**: Section references signal which part is needed, enabling future Claude Code optimization

## Implementation Priority

| Priority | Recommendation | Effort | Impact |
|----------|---------------|--------|--------|
| P1 | Create metadata-quick-ref.md | 30 min | High - immediate load reduction |
| P1 | Add blocker detection to agents (task 885 core) | 2 hr | High - core task objective |
| P2 | Add Progress Format quick links | 15 min | Medium - discoverability |
| P2 | Create agent-update-checklist.md | 45 min | Medium - meta task efficiency |
| P3 | Consolidate agent flow files | 1 hr | Medium - maintenance reduction |
| P3 | Remove thin-wrapper-skill.md duplicate | 5 min | Low - cleanup |

## Context File Inventory Summary

### Files to Create

1. `.claude/context/core/formats/metadata-quick-ref.md` (~100 lines)
2. `.claude/context/project/meta/agent-update-checklist.md` (~150 lines)

### Files to Modify

1. `.claude/rules/artifact-formats.md` - Add quick links header
2. `.claude/context/core/formats/return-metadata-file.md` - Add quick-ref link at top

### Files to Consider Removing

1. `.claude/context/core/patterns/thin-wrapper-skill.md` (duplicate of templates version)
2. `.claude/context/core/patterns/metadata-file-return.md` (will be replaced by metadata-quick-ref.md)

### Files That Are Well-Optimized (No Changes Needed)

1. `anti-stop-patterns.md` - Critical and appropriately sized
2. `skill-lifecycle.md` - Focused and necessary
3. `early-metadata-pattern.md` - Focused and necessary
4. `handoff-artifact.md` - Complete and well-structured
5. `summary-format.md` - Clear progressive structure
6. `jq-escaping-workarounds.md` - Essential reference

## Relation to Task 885 Implementation

This research supports task 885 implementation by:

1. **Schema Addition Location**: Identified return-metadata-file.md structure for adding `requires_user_review` field
2. **Agent Update Pattern**: Mapped exactly where in lean-implementation-agent.md and general-implementation-agent.md to add Blocker Detection section
3. **Skill Postflight Update**: Located exact position in skill-implementer/SKILL.md Stage 7 for adding review check
4. **Recommended Quick Reference**: The new metadata-quick-ref.md should include the `requires_user_review` field from day one

## Next Steps

1. Proceed with `/plan 885` using research-001.md (blocker taxonomy) as primary input
2. Consider incorporating metadata-quick-ref.md creation as Phase 0 or separate task
3. Add agent-update-checklist.md as follow-up task after 885 completes

## References

- `.claude/skills/skill-implementer/SKILL.md` - General implementation skill
- `.claude/skills/skill-lean-implementation/SKILL.md` - Lean implementation skill
- `.claude/agents/general-implementation-agent.md` - General agent definition
- `.claude/agents/lean-implementation-agent.md` - Lean agent definition
- `.claude/context/core/formats/return-metadata-file.md` - Metadata schema (550 lines)
- `.claude/context/core/formats/summary-format.md` - Summary format (230 lines)
- `.claude/context/project/lean4/agents/lean-implementation-flow.md` - Lean flow (340 lines)
- `.claude/rules/artifact-formats.md` - Artifact formats including Progress Subsection
- `.claude/context/index.md` - Context discovery index (600 lines)
- `specs/883_phase_progress_tracking_in_plan_files/plans/implementation-001.md` - Task 883 plan
