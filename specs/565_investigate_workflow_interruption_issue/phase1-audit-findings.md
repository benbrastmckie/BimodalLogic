# Phase 1 Audit Findings: Context Structure Analysis

**Task**: 565 - Investigate Workflow Interruption Issue
**Date**: 2026-01-17
**Session**: sess_1768703225_6dfa45

## Executive Summary

Total context size: **1012 KB (~1 MB)** across 109 markdown files.

**Key Findings**:
- 8 files exceed 20KB (optimization priority: high)
- 10 files between 15-20KB (optimization priority: medium)
- Agents use lazy loading via @-references (good pattern)
- Identified redundancy between state-management.md and state-lookup.md
- Most files have verbose examples that can be condensed

**Memory Impact**:
- Each subagent spawn loads context into V8 JavaScript heap
- Large files (20-33KB) loaded multiple times per session contribute to OOM crashes
- Reducing largest files by 30-50% should significantly reduce memory pressure

---

## Size Inventory

### Critical Files (>20KB) - Priority 1

| File | Size | Lines | Category | Optimization Potential |
|------|------|-------|----------|----------------------|
| `state-management.md` | 33 KB | 916 | Orchestration | HIGH - Redundant with state-lookup |
| `state-lookup.md` | 24 KB | 889 | Orchestration | HIGH - Merge/consolidate with state-management |
| `architecture.md` | 24 KB | - | Orchestration | MEDIUM - Trim verbose examples |
| `delegation.md` | 23 KB | - | Orchestration | MEDIUM - Condense patterns |
| `error-handling.md` | 23 KB | - | Standards | MEDIUM - Remove redundant examples |
| `routing.md` | 21 KB | - | Orchestration | MEDIUM - Simplify examples |
| `command-structure.md` | 21 KB | - | Formats | MEDIUM - Trim verbose sections |
| `orchestrator.md` | 21 KB | - | Orchestration | MEDIUM | Condense |

**Subtotal**: 190 KB (18.7% of total context)

### High-Impact Files (15-20KB) - Priority 2

| File | Size | Category |
|------|------|----------|
| `self-healing-implementation-details.md` | 19 KB | Project/Repo |
| `validation.md` | 18 KB | Orchestration |
| `xml-structure.md` | 17 KB | Standards |
| `preflight-postflight.md` | 16 KB | Workflows |
| `index.md` | 16 KB | Context |
| `research-workflow.md` | 16 KB | Project/Processes |
| `naming-conventions.md` | 16 KB | Project/Logic |
| `frontmatter.md` | 16 KB | Formats |
| `proof-construction.md` | 15 KB | Project/Logic |
| `verification-workflow.md` | 15 KB | Project/Logic |

**Subtotal**: 164 KB (16.2% of total context)

**Combined Priority 1+2**: 354 KB (35% of total context)

---

## Agent-to-Context Dependency Map

### Agent Loading Patterns

All agents follow a consistent pattern:

**Always Load**:
- `@.claude/context/core/formats/subagent-return.md` (10 KB) - Return format schema

**Agent-Specific Context**:

#### general-implementation-agent
- subagent-return.md (always)
- summary-format.md (when creating summary)
- CLAUDE.md + context/index.md (for meta tasks)
- Project-specific style guides (for code tasks)

#### planner-agent
- subagent-return.md (always)
- plan-format.md (when creating plan)
- task-breakdown.md (for decomposition)
- CLAUDE.md + context/index.md (for context)

#### lean-implementation-agent
- mcp-tools-guide.md (always - 9 KB)
- subagent-return.md (always)
- tactic-patterns.md (for implementation)
- proof-conventions-lean.md (when needed)

#### general-research-agent
- subagent-return.md (always)
- report-format.md (when creating report)
- project-overview.md (for codebase research)
- context/index.md (discovery)

### Key Observations

1. **Good**: Agents use lazy loading - context loaded on-demand via @-references
2. **Good**: No frontmatter arrays loading everything eagerly
3. **Problem**: Large reference files (state-management, delegation, etc.) loaded whenever referenced
4. **Opportunity**: Many "always load" files can be trimmed

---

## Content Category Analysis

### state-management.md (33 KB, 916 lines)

**Content Breakdown**:
- Status markers definition: ~150 lines
- State schemas (JSON): ~200 lines
- Synchronization patterns: ~200 lines
- Examples (VERBOSE): ~300 lines
- Validation rules: ~66 lines

**Redundancy with state-lookup.md**:
- Both define status transitions
- Both show jq lookup patterns
- Both explain state.json vs TODO.md

**Trimming Strategy**:
- Remove ~200 lines of verbose examples
- Consolidate redundant sections with state-lookup
- Keep essential schemas and patterns
- **Target**: Reduce to 20-22 KB (30% reduction)

### state-lookup.md (24 KB, 889 lines)

**Content Breakdown**:
- Lookup patterns: ~300 lines
- Examples (VERBOSE): ~400 lines
- Best practices: ~100 lines
- Related docs: ~89 lines

**Redundancy with state-management.md**:
- Duplicate status marker explanations
- Overlapping jq patterns
- Redundant validation examples

**Trimming Strategy**:
- **Merge essential lookup patterns into state-management.md**
- Delete state-lookup.md entirely OR reduce to minimal reference
- **Target**: Eliminate file OR reduce to <10 KB (60% reduction)

### delegation.md (23 KB)

**Content Breakdown** (estimated):
- Delegation concepts: ~200 lines
- Verbose multi-step examples: ~400 lines
- Error handling: ~200 lines
- Return formats: ~100 lines

**Trimming Strategy**:
- Condense verbose examples to essential patterns
- Remove redundant error handling (covered in error-handling.md)
- **Target**: Reduce to 15-16 KB (30% reduction)

### error-handling.md (23 KB)

**Content Breakdown** (estimated):
- Error categories: ~150 lines
- Response patterns: ~200 lines
- Verbose examples: ~350 lines
- Recovery strategies: ~200 lines

**Trimming Strategy**:
- Condense examples (many are repetitive)
- Remove overly detailed scenarios
- **Target**: Reduce to 15-16 KB (30% reduction)

---

## Redundancy Analysis

### Identified Redundancies

1. **state-management.md ↔ state-lookup.md** (HIGH)
   - Both explain status markers
   - Both show jq lookup patterns
   - Combined 57 KB → Can be ~30 KB with consolidation

2. **delegation.md ↔ error-handling.md** (MEDIUM)
   - Overlapping error response patterns
   - Duplicate recovery examples

3. **Multiple workflow files** (LOW-MEDIUM)
   - research-workflow.md, planning-workflow.md, implementation-workflow.md
   - Some duplication in status transition explanations
   - Opportunity to reference shared patterns instead of repeating

4. **Lean proof files** (LOW)
   - proof-construction.md, modal-proof-strategies.md, temporal-proof-strategies.md
   - Some tactical overlap but domain-specific enough to keep separate

---

## Agent Context Usage Patterns

### Most Frequently Referenced Files

Based on agent "Always Load" and "Load When" sections:

1. **subagent-return.md** (10 KB) - Loaded by ALL agents
   - Used 8+ times per typical workflow
   - Already reasonably sized

2. **CLAUDE.md** (project root) - Loaded frequently
   - Not in context/ directory, but important
   - Already optimized

3. **mcp-tools-guide.md** (9 KB) - Loaded by lean agents
   - Already well-sized

4. **plan-format.md** (4 KB) - Loaded by planner
   - Small, no optimization needed

5. **state-management.md** (33 KB) - Loaded by command files
   - **CRITICAL**: Largest file, frequently referenced
   - **Priority 1 optimization target**

---

## Recommendations Summary

### Quick Wins (High Impact, Low Effort)

1. **Consolidate state-management + state-lookup**
   - Merge into single ~30 KB file
   - **Saves**: ~25 KB (2.5% of total)

2. **Trim verbose examples from top 8 files**
   - Remove redundant examples, keep essential patterns
   - **Target**: 30-50% size reduction per file
   - **Saves**: ~100-150 KB (10-15% of total)

### Medium Effort

3. **Split very large files if natural divisions exist**
   - state-management could split into state-markers + state-schemas
   - Only if it makes logical sense

4. **Optimize agent context loading**
   - Ensure agents only reference what they need
   - Remove unnecessary @-references

### Low Priority

5. **Create quick reference files**
   - For frequently-used patterns (jq commands, status markers)
   - Agents load quick ref instead of full file

---

## Phase 2 Input

For Phase 2 (Planning Trimming and Division Strategy), focus on:

1. **state-management.md + state-lookup.md consolidation plan**
2. **Top 8 files trimming strategy** (identify specific sections to remove)
3. **Agent context audit** (verify all @-references are necessary)
4. **Potential file splits** (only if natural and beneficial)

**Next Steps**:
- Create detailed trimming plan for each file
- Define merge strategy for state files
- Plan agent context optimization
