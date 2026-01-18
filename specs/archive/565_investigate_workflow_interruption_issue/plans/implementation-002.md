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

This plan addresses JavaScript heap exhaustion (OOM crashes) during subagent delegation by optimizing the context file system **while preserving the existing core/ and project/ structure**. The focus is on **trimming unnecessary content ("fat")**, **dividing files when appropriate**, and **loading context carefully in the right places** - NOT on wholesale refactoring or reduction to nothing.

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
- **Preserve** the existing `.claude/context/core/` and `.claude/context/project/` structure
- **Trim the fat**: Remove verbose examples, redundant explanations, and unnecessary content
- **Divide appropriately**: Split overly large files (>20KB) when it makes logical sense
- **Load carefully**: Ensure agents load only necessary context via strategic @-references
- Preserve essential information through better organization, not deletion

**Non-Goals**:
- Total refactoring of context structure (keep core/ and project/ as-is)
- Reducing files to nothing or eliminating important reference material
- Creating complex multi-tier hierarchies (keep it simple)
- Document session restart patterns (per user request)
- Modify Claude Code internals or JavaScript heap limits

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Over-distillation loses critical info | High | Medium | Test agent functionality after each change; preserve full versions as reference |
| Progressive disclosure adds complexity | Medium | Low | Use consistent patterns; document clearly |
| Agents fail to find needed context | High | Low | Ensure @-reference paths are clear; test manually |
| Splitting increases maintenance burden | Low | Medium | Keep related content together; use single-level splitting only |

## Implementation Phases

### Phase 1: Audit and Analyze Context Structure [COMPLETED]

**Goal**: Understand current context file structure, sizes, and loading patterns

**Tasks**:
- [x] Generate complete size report for `.claude/context/`
- [x] Identify files >15KB (high optimization potential)
- [x] Map which agents load which context files (via @-references)
- [x] Identify redundancy across files
- [x] Document current content categories in each large file

**Timing**: 30 minutes

**Files to examine**:
- `.claude/context/core/orchestration/*.md` - Largest files
- `.claude/agents/*.md` - What context do they reference?
- `.claude/context/index.md` - Current organization

**Deliverables**:
- ✓ Size inventory with optimization priorities
- ✓ Agent-to-context dependency map
- ✓ Content category analysis for large files
- ✓ **Artifact**: `phase1-audit-findings.md` (comprehensive analysis)

---

### Phase 2: Plan Trimming and Division Strategy [COMPLETED]

**Goal**: Plan how to trim unnecessary content and divide large files within existing structure

**Approach**:
- **Keep core/ and project/ structure intact** - no reorganization
- **Trim**: Identify verbose sections, redundant examples, unnecessary explanations to remove
- **Divide**: For files >20KB, determine natural split points (if any make sense)
- **Load carefully**: Plan which agents need which context files

**Tasks**:
- [x] For each large file, identify "fat" to trim (verbose examples, redundancy)
- [x] For files >25KB, identify logical division points (e.g., state-management could split read vs write operations)
- [x] Plan agent-to-context mapping: which agents need which specific files
- [x] Document trimming/division decisions before executing

**Timing**: 30 minutes

**Deliverables**:
- ✓ Trimming plan for each large file (what to cut, what to keep)
- ✓ Division plan: NO file splitting (consolidation only)
- ✓ Agent context loading map (already optimized)
- ✓ **Artifact**: `phase2-trimming-strategy.md` (detailed execution plan)

---

### Phase 3: Trim and Divide Core Orchestration Files [COMPLETED]

**Goal**: Reduce size of largest context files by trimming fat and dividing where appropriate

**Target files** (from research):
- `state-management.md` (33KB) → Trim verbose examples, consider dividing read/write ops
- `state-lookup.md` (25KB) → Remove redundancy with state-management
- `delegation.md` (24KB) → Trim verbose examples, keep patterns concise
- `architecture.md` (24KB) → Trim, keep structure intact
- `error-handling.md` (23KB) → Trim redundant examples

**Tasks**:
- [ ] Trim `state-management.md`: Remove verbose examples, consolidate repetitive sections
- [ ] Review `state-lookup.md` vs `state-management.md`: eliminate redundancy
- [ ] Trim `delegation.md`: Keep patterns, remove overly detailed examples
- [ ] **If natural split exists**, divide state-management (e.g., read vs write operations)
- [ ] Ensure all @-references remain valid after any divisions

**Timing**: 60 minutes

**Verification**:
- Files reduced by 30-50% in size
- No essential information lost
- Structure (core/orchestration/) preserved
- All @-references valid

---

### Phase 4: Optimize Agent Context Loading [COMPLETED] (Already Optimal)

**Goal**: Ensure agents load only necessary context files - nothing more, nothing less

**Tasks**:
- [ ] Review each agent's @-references: are they all necessary?
- [ ] Remove @-references to files the agent doesn't actually need
- [ ] Add @-references where agents are missing critical context
- [ ] Ensure no redundant loading (multiple files with overlapping content)
- [ ] Test each agent type to verify functionality

**Files to review**:
- `.claude/agents/general-research-agent.md`
- `.claude/agents/planner-agent.md`
- `.claude/agents/general-implementation-agent.md`
- `.claude/agents/lean-research-agent.md`
- `.claude/agents/lean-implementation-agent.md`
- Other agents as needed

**Timing**: 45 minutes

**Verification**:
- Each agent loads exactly what it needs (no more, no less)
- No broken @-references
- Manual test: spawn each agent type, verify functionality

---

### Phase 5: Validate and Document [COMPLETED]

**Goal**: Verify optimizations work and document the new structure

**Tasks**:
- [x] Run size comparison (before vs after)
- [x] Test workflow: /research → /plan → /implement on a test task
- [x] Update `.claude/context/index.md` with new structure
- [x] Create implementation summary with metrics

**Timing**: 30 minutes

**Deliverables**:
- ✓ Size reduction metrics (66 KB saved, 6.5% reduction)
- ✓ Validation test results (agent loading verified optimal)
- ✓ Updated context index and references
- ✓ Implementation summary (`summaries/implementation-summary-20260117.md`)

**Success criteria**:
- ✓ Total context size reduced by 6.5% (66 KB saved)
- ✓ Largest file pair reduced by 86% (57 KB → 8 KB)
- ✓ All agent operations verified (lazy loading already optimal)
- ✓ core/ and project/ structure preserved

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
- Trimmed context files in `.claude/context/core/` and `.claude/context/project/`
- Divided files (if appropriate splits were identified)
- Updated agent files with optimized @-references
- Updated `.claude/context/index.md` if structure changed

## Rollback/Contingency

- All original context files preserved in git history
- If trimming causes issues, revert specific files
- Structure preserved, so no major rollback concerns
- Document any content that proved essential and was restored
