# Phase 2: Trimming and Division Strategy

**Task**: 565 - Investigate Workflow Interruption Issue
**Date**: 2026-01-17
**Session**: sess_1768703225_6dfa45
**Input**: phase1-audit-findings.md

## Executive Summary

**Goal**: Reduce context file size by 20-40% through strategic trimming and consolidation, NOT deletion of essential content.

**Approach**:
1. Consolidate state-management + state-lookup → single 25-28KB file (saves ~30KB)
2. Trim verbose examples from 6 additional large files (save ~80-100KB total)
3. No file splitting (keep structure simple)
4. Total expected savings: **110-130 KB (11-13% reduction)**

**Key Principle**: Preserve all essential information; remove only verbosity, redundancy, and excessive examples.

---

## File-by-File Trimming Plan

### 1. state-management.md + state-lookup.md → state-management.md

**Current**:
- state-management.md: 33 KB, 916 lines
- state-lookup.md: 24 KB, 889 lines
- **Total**: 57 KB, 1805 lines

**Target**: Single consolidated file: 25-28 KB, ~700-750 lines

**Consolidation Strategy**:

#### Keep from state-management.md:
- ✓ Status marker definitions (essential)
- ✓ State schemas (JSON structure)
- ✓ Status transition diagram
- ✓ Timestamp formats
- ✓ Synchronization patterns (core concepts)
- ✓ Best practices section
- ✗ Remove: 200+ lines of verbose examples
- ✗ Remove: Redundant status explanations (keep concise version)

#### Keep from state-lookup.md:
- ✓ Fast lookup patterns (jq commands) - ESSENTIAL for command files
- ✓ Common patterns section (validate-and-extract, etc.)
- ✓ Performance notes (helpful context)
- ✗ Remove: 400+ lines of verbose examples
- ✗ Remove: Redundant status marker explanations (already in state-management)
- ✗ Remove: Duplicate validation examples

#### Integration Approach:
1. Start with state-management.md structure
2. Add new section: "## Fast Lookup Patterns" (from state-lookup)
3. Add new section: "## Common Command Patterns" (from state-lookup)
4. Consolidate examples: Show 1-2 concise examples instead of 10+ verbose ones
5. Delete state-lookup.md after successful merge

**Expected Result**:
- Single source of truth for state management
- **Savings**: ~30 KB (from 57 KB → 27 KB)
- All essential information preserved

---

### 2. delegation.md (23 KB)

**Current Content**:
- Delegation concepts and patterns
- Multi-step delegation examples (VERBOSE)
- Error handling during delegation
- Return format expectations

**Trimming Strategy**:
- ✓ Keep: Core delegation concepts
- ✓ Keep: Essential patterns (forked vs direct, context passing)
- ✓ Keep: Return validation requirements
- ✗ Remove: Verbose step-by-step examples (reduce from ~15 examples to 3-4 concise ones)
- ✗ Remove: Redundant error handling (reference error-handling.md instead)
- ✗ Remove: Overly detailed edge case discussions

**Specific Sections to Trim**:
- Multi-step delegation examples: 400 lines → 150 lines
- Error scenarios: 200 lines → 100 lines (keep patterns, remove verbose narratives)

**Target**: 15-16 KB (~30% reduction)

---

### 3. error-handling.md (23 KB)

**Current Content**:
- Error categories
- Response patterns
- Verbose scenario examples
- Recovery strategies

**Trimming Strategy**:
- ✓ Keep: Error category definitions
- ✓ Keep: Error response pattern (the key structure)
- ✓ Keep: Recovery strategies (essential)
- ✗ Remove: 10+ verbose scenario examples (keep 2-3 representative ones)
- ✗ Remove: Redundant explanations of error logging
- ✗ Remove: Overly detailed edge cases

**Specific Sections to Trim**:
- Scenario examples: 350 lines → 100 lines
- Severity level explanations: Condense verbose descriptions

**Target**: 15-16 KB (~30% reduction)

---

### 4. routing.md (21 KB)

**Current Content**:
- Language-based routing logic
- Skill/agent mappings
- Routing decision trees

**Trimming Strategy**:
- ✓ Keep: Routing tables (essential)
- ✓ Keep: Decision tree logic
- ✓ Keep: Language → skill/agent mappings
- ✗ Remove: Verbose examples of routing decisions
- ✗ Remove: Redundant explanations (show table once, not 5 times)

**Specific Sections to Trim**:
- Routing examples: Reduce from verbose narratives to concise tables
- Redundant mapping explanations

**Target**: 14-15 KB (~30% reduction)

---

### 5. command-structure.md (21 KB)

**Current Content**:
- Command file structure
- Checkpoint patterns
- XML/YAML examples

**Trimming Strategy**:
- ✓ Keep: Command structure template
- ✓ Keep: Checkpoint definitions
- ✓ Keep: Essential format specifications
- ✗ Remove: Verbose multi-page examples (keep 1-2 concise ones)
- ✗ Remove: Redundant explanations of same concept

**Target**: 14-15 KB (~30% reduction)

---

### 6. orchestrator.md (21 KB)

**Current Content**:
- Orchestrator responsibilities
- Command routing
- Session management

**Trimming Strategy**:
- ✓ Keep: Core orchestrator concepts
- ✓ Keep: Routing logic
- ✓ Keep: Session tracking patterns
- ✗ Remove: Verbose examples
- ✗ Remove: Redundant explanations (may overlap with routing.md)

**Target**: 14-15 KB (~30% reduction)

---

### 7. architecture.md (24 KB)

**Current Content**:
- System architecture overview
- Component relationships
- Design principles

**Trimming Strategy**:
- ✓ Keep: Architecture diagrams and descriptions
- ✓ Keep: Component definitions
- ✓ Keep: Design principles
- ✗ Remove: Verbose explanations
- ✗ Remove: Redundant component descriptions

**Target**: 16-17 KB (~30% reduction)

---

## Files NOT to Trim (Already Optimized or Small)

### Keep As-Is:
- `subagent-return.md` (10 KB) - Frequently loaded, already concise
- `mcp-tools-guide.md` (9 KB) - Essential reference, well-organized
- `plan-format.md` (4 KB) - Small, essential
- `report-format.md` (2 KB) - Small, essential
- `summary-format.md` (1 KB) - Minimal
- All files <10 KB - Low ROI for trimming effort

---

## Agent Context Optimization Plan

### Current Agent Loading Patterns (from audit)

All agents currently load:
1. `subagent-return.md` (always) - ✓ Necessary
2. Task-specific context (on-demand) - ✓ Good pattern
3. Format files (plan, report, summary) - ✓ Necessary when creating artifacts

### Optimization Actions:

#### 1. Verify Necessity
For each agent, verify all @-references are actually used:
- general-implementation-agent: ✓ All references necessary
- planner-agent: ✓ All references necessary
- lean-implementation-agent: ✓ All references necessary
- general-research-agent: ✓ All references necessary

**Conclusion**: Current agent loading is already optimized (lazy loading pattern). No changes needed.

#### 2. Reduce Reference File Sizes
Instead of changing WHAT agents load, reduce SIZE of what they load:
- state-management consolidation will help command files
- Trimming large files will help all agents that reference them

---

## Division Strategy

### Decision: NO FILE SPLITTING

**Rationale**:
1. **Complexity**: Splitting adds maintenance burden and cognitive load
2. **ROI**: Trimming verbose content achieves same size reduction without complexity
3. **Usage**: Agents typically need entire concept (e.g., all status markers), not partial files
4. **Consolidation > Division**: We're already merging (state files), splitting would be contradictory

**Alternative Approach**:
- Keep files focused and complete
- Trim excess verbosity
- Use cross-references instead of duplication

---

## Implementation Order

Execute in this sequence to minimize risk:

### Batch 1: Consolidation (Highest Impact)
1. **Merge state-management + state-lookup** → state-management.md
2. Verify command files still function
3. Delete state-lookup.md
4. Update any @-references to state-lookup

**Risk**: Medium (structural change)
**Impact**: High (saves 30 KB)
**Verification**: Test /research, /plan, /implement commands

### Batch 2: Trim Large Files (High Impact)
5. Trim delegation.md (23 KB → 15 KB)
6. Trim error-handling.md (23 KB → 15 KB)
7. Trim architecture.md (24 KB → 17 KB)

**Risk**: Low (content changes only)
**Impact**: High (saves 40 KB total)
**Verification**: Read trimmed files, verify coherence

### Batch 3: Trim Medium Files (Medium Impact)
8. Trim routing.md (21 KB → 15 KB)
9. Trim command-structure.md (21 KB → 15 KB)
10. Trim orchestrator.md (21 KB → 15 KB)

**Risk**: Low
**Impact**: Medium (saves 30 KB total)
**Verification**: Spot-check examples still make sense

---

## Rollback Plan

All changes are in git:
1. If trimming causes issues, `git revert` specific commit
2. Original content available in git history
3. Preserve structure (no major refactoring), so rollback is easy

---

## Success Metrics

### Quantitative
- **Total context size**: 1012 KB → 880-900 KB (11-13% reduction)
- **Largest file size**: 33 KB → 27 KB (state-management after merge)
- **Files >20KB**: 8 → 1 (state-management only)

### Qualitative
- All essential information preserved
- Agents continue to function correctly
- Documentation remains clear and useful
- Reduced memory pressure during subagent spawning

---

## Phase 3 Input

For Phase 3 (execution), use this document to:
1. Follow implementation order (Batch 1 → 2 → 3)
2. Apply specific trimming strategies per file
3. Verify after each batch
4. Track actual size reductions vs targets

**Next Step**: Begin Phase 3 execution with state file consolidation.
