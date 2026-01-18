# Implementation Plan: Task #565

- **Task**: 565 - Investigate Workflow Interruption Issue
- **Version**: 002 (Revised)
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/565_investigate_workflow_interruption_issue/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan addresses JavaScript heap exhaustion (OOM crashes) during subagent delegation by optimizing the context file system. The focus is on **reducing context file sizes to essentials** and implementing **progressive disclosure patterns** so agents load minimal context upfront with clear paths to deeper information when needed.

### Revision Notes

Removed from v001:
- Session restart documentation (user does not want this)

Added/enhanced:
- Progressive disclosure architecture for context loading
- Content distillation to preserve essential information
- Tiered context structure (quick reference → detailed guidance)

### Research Integration

Key findings from research-001.md and research-002.md:
- Root cause: V8 JavaScript heap exhaustion during subagent spawning (95% confidence)
- Memory accumulates over session lifetime; crashes occur during Task tool invocation
- Context files total ~1MB; largest files are 20-33KB each
- Reducing context loaded per subagent spawn directly reduces memory pressure

## Goals & Non-Goals

**Goals**:
- Reduce context file sizes by distilling to essential information
- Implement progressive disclosure: minimal upfront context with links to details
- Preserve important content through better organization, not deletion
- Create tiered context structure (quick-ref → full-detail)

**Non-Goals**:
- Document session restart patterns (per user request)
- Eliminate all subagent spawning (architecture is sound)
- Modify Claude Code internals or JavaScript heap limits
- Delete important reference material

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Over-distillation loses critical info | High | Medium | Test agent functionality after each change; preserve full versions as reference |
| Progressive disclosure adds complexity | Medium | Low | Use consistent patterns; document clearly |
| Agents fail to find needed context | High | Low | Ensure @-reference paths are clear; test manually |
| Splitting increases maintenance burden | Low | Medium | Keep related content together; use single-level splitting only |

## Implementation Phases

### Phase 1: Audit and Analyze Context Structure [NOT STARTED]

**Goal**: Understand current context file structure, sizes, and loading patterns

**Tasks**:
- [ ] Generate complete size report for `.claude/context/`
- [ ] Identify files >15KB (high optimization potential)
- [ ] Map which agents load which context files (via @-references)
- [ ] Identify redundancy across files
- [ ] Document current content categories in each large file

**Timing**: 30 minutes

**Files to examine**:
- `.claude/context/core/orchestration/*.md` - Largest files
- `.claude/agents/*.md` - What context do they reference?
- `.claude/context/index.md` - Current organization

**Deliverables**:
- Size inventory with optimization priorities
- Agent-to-context dependency map
- Content category analysis for large files

---

### Phase 2: Design Progressive Disclosure Structure [NOT STARTED]

**Goal**: Define tiered context architecture for minimal upfront loading

**Architecture Pattern**:
```
Level 0: Quick Reference (loaded by default)
  - Essential rules, patterns, key decisions
  - Target: <5KB per topic area
  - Format: Bullet points, tables, decision trees

Level 1: Working Detail (loaded on-demand via @-reference)
  - How-to instructions, examples, edge cases
  - Target: <15KB per file
  - Format: Step-by-step, code examples

Level 2: Full Reference (rarely loaded, for deep investigation)
  - Complete specifications, historical context
  - Size: Unrestricted
  - Format: Comprehensive documentation
```

**Tasks**:
- [ ] Design file naming convention for tiers (e.g., `-quick.md`, `-guide.md`, `-ref.md`)
- [ ] Identify which content belongs at each tier for top 5 largest files
- [ ] Define @-reference patterns for progressive loading
- [ ] Document the pattern in `.claude/context/index.md`

**Timing**: 30 minutes

**Deliverables**:
- Tier naming convention documented
- Content allocation plan for large files
- Progressive loading pattern examples

---

### Phase 3: Distill Core Orchestration Files [NOT STARTED]

**Goal**: Apply progressive disclosure to the largest orchestration context files

**Target files** (from research):
- `state-management.md` (33KB) → Split to quick + detail
- `state-lookup.md` (25KB) → Merge relevant parts, distill rest
- `delegation.md` (24KB) → Extract essentials, move examples to ref
- `architecture.md` (24KB) → Create quick overview + full ref
- `error-handling.md` (23KB) → Distill patterns, keep examples separate

**Tasks**:
- [ ] Create `state-management-quick.md` with essential rules (<5KB)
- [ ] Create `delegation-quick.md` with core patterns (<5KB)
- [ ] Consolidate redundant content between state-management and state-lookup
- [ ] Move verbose examples to `-ref.md` files
- [ ] Update original files to reference the quick versions

**Timing**: 60 minutes

**Verification**:
- Quick files are <5KB each
- Original files reduced by >40%
- No essential information lost (moved, not deleted)
- @-references point to correct locations

---

### Phase 4: Update Agent Context Loading [NOT STARTED]

**Goal**: Configure agents to load quick-reference by default, full context on-demand

**Tasks**:
- [ ] Update agent files to reference `-quick.md` versions instead of full files
- [ ] Add "For more detail, see @..." notes in agent prompts
- [ ] Ensure critical operations still have necessary context
- [ ] Test each agent type with a simple operation

**Files to modify**:
- `.claude/agents/general-research-agent.md`
- `.claude/agents/planner-agent.md`
- `.claude/agents/general-implementation-agent.md`
- `.claude/agents/lean-research-agent.md`
- `.claude/agents/lean-implementation-agent.md`
- Other agents as needed

**Timing**: 45 minutes

**Verification**:
- Agents reference quick files by default
- Progressive disclosure paths are documented in agents
- Manual test: spawn each agent type, verify functionality

---

### Phase 5: Validate and Document [NOT STARTED]

**Goal**: Verify optimizations work and document the new structure

**Tasks**:
- [ ] Run size comparison (before vs after)
- [ ] Test workflow: /research → /plan → /implement on a test task
- [ ] Update `.claude/context/index.md` with new structure
- [ ] Create implementation summary with metrics

**Timing**: 30 minutes

**Deliverables**:
- Size reduction metrics
- Validation test results
- Updated context index
- Implementation summary

**Success criteria**:
- Total context size reduced by >30%
- Default agent context load reduced by >50%
- All agent operations still function correctly
- Progressive disclosure paths are clear

## Testing & Validation

- [ ] Verify context files load without errors
- [ ] Verify agent files have valid @-references
- [ ] Test: /research on a new task
- [ ] Test: /plan on a researched task
- [ ] Test: /implement on a planned task
- [ ] Confirm no regressions in agent functionality

## Artifacts & Outputs

- `specs/565_investigate_workflow_interruption_issue/plans/implementation-002.md` (this file)
- `specs/565_investigate_workflow_interruption_issue/summaries/implementation-summary-YYYYMMDD.md`
- New quick-reference context files (`*-quick.md`)
- Updated agent files with progressive loading
- Updated `.claude/context/index.md`

## Rollback/Contingency

- All original context files preserved in git history
- If distillation causes issues, revert specific files
- Keep original files alongside quick versions during testing
- Document any content that proved essential despite initial categorization
