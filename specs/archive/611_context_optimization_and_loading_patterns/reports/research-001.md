# Research Report: Task #611

**Task**: 611 - context_optimization_and_loading_patterns
**Started**: 2026-01-19T09:00:00Z
**Completed**: 2026-01-19T09:45:00Z
**Effort**: 1 hour
**Priority**: Medium
**Dependencies**: Task 609 (Document command-skill-agent architecture)
**Sources/Inputs**: Codebase exploration, context files, CLAUDE.md, commands, skills, agents
**Artifacts**: specs/611_context_optimization_and_loading_patterns/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Context loading is well-structured with lazy loading pattern correctly implemented across the architecture
- Commands load NO context (delegate to skills), skills load minimal context, agents load most context
- Several orchestration files have significant redundancy (5,250 lines total in 10 orchestration files with overlap)
- The index.md file references state-management.md twice in example loading patterns (line duplication)
- Agents correctly use @-reference patterns for on-demand context loading

## Context & Scope

This research analyzed the context file organization, identified where context is loaded throughout the command-skill-agent architecture, and found optimization opportunities. The focus was on ensuring most context is loaded in agents (progressive loading), eliminating redundancy, and improving quality.

## Findings

### 1. Current Context File Inventory

**Total context files**: 110+ markdown files across `.claude/context/`

**Largest files by line count (orchestration/)**:
| File | Lines | Purpose |
|------|-------|---------|
| orchestrator.md | 870 | Orchestrator design + guide (merged) |
| delegation.md | 851 | Delegation standard + guide (merged) |
| routing.md | 769 | Routing guide + routing logic (merged) |
| architecture.md | 758 | Three-layer architecture |
| validation.md | 690 | Validation strategies |

**Observation**: Orchestration files are 5,250 lines total - some content appears duplicated across files (e.g., session tracking, delegation depth limits appear in multiple files).

### 2. Context Loading Architecture Analysis

#### CLAUDE.md (Root)
**Loading Pattern**: Reference-only, no eager loading
- Lists context imports with @-references for "load as needed" pattern
- References index.md for context discovery
- Documents skill architecture but does NOT load context files directly
- **Assessment**: Correct - minimal context in root file

#### Commands (.claude/commands/)
**Loading Pattern**: Zero context loading - pure delegation
- Commands like `/research`, `/plan`, `/implement` contain ONLY:
  - Frontmatter (allowed-tools, description)
  - Checkpoint instructions (GATE IN, DELEGATE, GATE OUT, COMMIT)
  - No @-references to context files
- All context loading deferred to skills/agents
- **Assessment**: Correct - commands are lightweight routers

#### Skills (.claude/skills/)
**Loading Pattern**: Minimal context, reference-only
- Skills document context references but mark them "do not load eagerly"
- Example from skill-researcher:
  ```
  ## Context References
  Reference (do not load eagerly):
  - Path: `.claude/context/core/formats/return-metadata-file.md`
  ```
- Skills handle preflight/postflight inline but delegate main work to agents via Task tool
- **Assessment**: Correct - skills are thin wrappers with internal postflight

#### Agents (.claude/agents/)
**Loading Pattern**: On-demand @-references
- Agents specify context to load with @-references
- Example from general-research-agent:
  ```
  **Always Load**:
  - `@.claude/context/core/formats/return-metadata-file.md`

  **Load When Creating Report**:
  - `@.claude/context/core/formats/report-format.md`
  ```
- Agents document conditional loading based on task type
- **Assessment**: Correct - agents are where context is loaded

### 3. Redundancy Analysis

#### Identified Redundancies

**A. Orchestration files have overlapping content**

The following concepts appear in multiple files:
- Session ID format (`sess_{timestamp}_{random}`) - in delegation.md, orchestrator.md, routing.md
- Delegation depth limits (max 3) - in delegation.md, orchestrator.md
- Timeout configuration table - in delegation.md, orchestrator.md, routing.md
- Cycle detection logic - in delegation.md, orchestrator.md
- Return validation steps - in delegation.md, orchestrator.md, validation.md

**B. Index.md has duplicate references**

Lines 428-429 and 443-444 reference state-management.md twice:
```
- @.claude/context/core/orchestration/state-management.md
- @.claude/context/core/orchestration/state-management.md
```

**C. Multiple files document the same patterns**

| Pattern | Files Documenting It |
|---------|---------------------|
| Status markers | status-markers.md, state-management.md, status-transitions.md |
| Delegation context schema | delegation.md, routing.md, orchestrator.md |
| Preflight/postflight | preflight-postflight.md, preflight-pattern.md, postflight-pattern.md |

#### Non-Issues (Intentional Duplication)

- Agent files have similar structure (this is template consistency, not redundancy)
- Skill files follow same 11-stage pattern (this is pattern consistency)

### 4. Context Loading Map

| Component Type | Context Files Loaded | When |
|----------------|---------------------|------|
| CLAUDE.md | 0 direct loads | - |
| Commands | 0 | Never (delegate to skills) |
| Skills | 0-2 (reference only) | During postflight if needed |
| Agents | 2-8 depending on task | At execution start and on-demand |

**Correct Loading Chain**:
```
User -> Command (0 context)
     -> Skill (0-2 reference context)
     -> Agent (2-8 loaded context)
```

### 5. Optimization Opportunities

#### A. Consolidate Orchestration Files (HIGH IMPACT)

**Problem**: 5,250 lines across 10 orchestration files with significant overlap

**Recommendation**: Consolidate to 3 focused files:
1. `orchestration-core.md` (~600 lines) - Essential patterns: delegation, session tracking, routing
2. `orchestration-validation.md` (~400 lines) - Return validation, artifact validation
3. `orchestration-reference.md` (~300 lines) - Troubleshooting, examples

**Expected reduction**: 5,250 -> ~1,300 lines (75% reduction)

#### B. Fix Index.md Duplicate References (LOW EFFORT)

**Problem**: state-management.md referenced twice in loading examples

**Fix**: Remove duplicate lines 429, 444, 455

#### C. Merge Status-Related Files (MEDIUM IMPACT)

**Problem**: Status information spread across:
- status-markers.md (374 lines)
- status-transitions.md (lines unknown)
- state-management.md (298 lines)

**Recommendation**: Merge into single `status-management.md` with sections for markers, transitions, and state management

#### D. Remove Deprecated Files (LOW EFFORT)

**Problem**: Index.md references deprecated files with 1-month deprecation period ending 2025-01-29:
- subagent-return-format.md (deprecated -> delegation.md)
- subagent-delegation-guide.md (deprecated -> delegation.md)
- state-schema.md (deprecated -> state-management.md)
- command-lifecycle.md (removed)

**Recommendation**: After deprecation period, remove deprecated file references from index.md

### 6. Loading Pattern Guidelines (Best Practices)

#### Lazy Loading Principles (Current Implementation - Correct)

1. **Commands**: Load zero context - pure routing
2. **Skills**: Reference context but don't load - delegate to agents
3. **Agents**: Load context on-demand based on task type
4. **Progressive loading**: Load more specific context as needed during execution

#### Recommended Loading Tiers

| Tier | Context Budget | What to Load |
|------|---------------|--------------|
| Tier 1 (Routing) | <5% | Nothing (commands route only) |
| Tier 2 (Skills) | <10% | Reference paths only, don't load |
| Tier 3 (Agents) | 60-80% | Task-specific context via @-references |

#### Anti-Patterns to Avoid

1. **Eager loading in skills** - Skills should NOT load context files
2. **Duplicate @-references** - Don't reference same file multiple times
3. **Loading context: lines in frontmatter** - Use @-references in body instead
4. **Loading orchestration context in agents** - Agents don't need routing logic

## Decisions

- Current lazy loading pattern is correct and should be maintained
- Orchestration consolidation is the highest-value optimization
- Index.md duplicates should be fixed in implementation phase
- Deprecated files should be removed after deprecation period

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Consolidation breaks references | High | Medium | Grep for all @-references before removal |
| Over-consolidation loses clarity | Medium | Low | Keep distinct sections with clear headers |
| Removing deprecated files too early | Low | Low | Check deprecation dates before removal |

## Appendix

### Search Queries Used

1. `find .claude/context -type f -name "*.md"` - Enumerate all context files
2. `wc -l .claude/context/core/orchestration/*.md` - Line counts for largest directory
3. `grep "context:|@\.claude/context" .claude/` - Find context references
4. File reads of commands, skills, agents to trace loading patterns

### Key File References

- `.claude/context/index.md` - Master context discovery index
- `.claude/context/README.md` - Context organization guide
- `.claude/CLAUDE.md` - Project configuration
- `.claude/agents/*.md` - Agent definitions with context references
- `.claude/skills/*/SKILL.md` - Skill definitions

### Line Count Summary

| Directory | Total Lines | Files |
|-----------|-------------|-------|
| core/orchestration/ | 5,250 | 10 |
| core/standards/ | ~3,500 | 12 |
| core/formats/ | ~2,500 | 8 |
| core/patterns/ | ~1,000 | 8 |
| project/lean4/ | ~4,000 | 17 |
| project/logic/ | ~2,500 | 12 |

### Files Already Consolidated (Task 246)

Prior consolidation efforts reduced:
- Delegation files: 1,003 -> 510 lines (50% reduction)
- State management files: 1,574 -> 535 lines (66% reduction)
- Total savings: 2,670 lines (72% reduction in those files)

Current orchestration directory has grown again and needs similar consolidation.
