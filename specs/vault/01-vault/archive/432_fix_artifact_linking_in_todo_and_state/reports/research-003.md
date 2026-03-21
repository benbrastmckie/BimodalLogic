# Research Report: Task #432 - Lazy Context Loading Standardization

**Task**: Fix artifact linking in TODO.md and state.json
**Date**: 2026-01-12
**Focus**: Standardizing lazy context loading throughout the agent system

## Executive Summary

This research builds on research-002.md's checkpoint-based execution model by analyzing context loading patterns across the agent system. The analysis reveals significant inconsistencies in how context is loaded, referenced, and used across components. The goal is to establish a standardized lazy context loading approach that loads exactly the context needed, when needed, and nothing more.

## Findings

### 1. Current Context Loading Analysis

#### 1.1 Context Files Inventory

The current context system has 80+ files organized in:
```
.claude/context/
├── core/                    # 35+ files
│   ├── orchestration/       # 10 files (state-management, delegation, etc.)
│   ├── standards/           # 10 files (status-markers, git-safety, etc.)
│   ├── formats/             # 6 files (subagent-return, plan-format, etc.)
│   ├── workflows/           # 6 files (preflight-postflight, etc.)
│   └── templates/           # 5 files (thin-wrapper-skill, etc.)
├── project/                 # 45+ files
│   ├── lean4/              # 20+ files (tools, standards, domain)
│   ├── logic/              # 10+ files
│   ├── latex/              # 8 files
│   └── repo/               # 2 files
└── index.md                # Context discovery index
```

#### 1.2 Context Loading Patterns Found

**Pattern A: @-reference lists (Documented but not enforced)**
```markdown
## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/core/formats/subagent-return.md`

**Load When Creating Report**:
- `@.claude/context/core/formats/report-format.md`
```

**Pattern B: Inline path strings (Inconsistent)**
```markdown
**See Also**:
- `orchestration/state-management.md` - Detailed state management patterns
- `orchestration/state-lookup.md` - Query patterns and examples
```

**Pattern C: Frontmatter context arrays (Not implemented)**
```yaml
context_loading:
  strategy: lazy
  required:
    - "core/orchestration/delegation.md"
```
Note: This YAML structure appears in docs but is never parsed/executed.

#### 1.3 Context Usage by Component Type

| Component | Documented Context | Actually Loaded | Gap |
|-----------|-------------------|-----------------|-----|
| Commands | 0 files (no context section) | Via CLAUDE.md only | High |
| Skills | @-references listed | Manual by LLM | Medium |
| Agents | @-references listed | Manual by LLM | Medium |
| index.md | N/A | Reference only | N/A |

**Key Finding**: Context loading is entirely advisory. LLMs may or may not load referenced files.

### 2. Identified Issues with Context Loading

#### Issue 1: No Enforcement Mechanism

Context references are documentation only:
```markdown
## Context References
Load these on-demand using @-references:
- `@.claude/context/core/formats/subagent-return.md`
```

**Problem**: There's no mechanism to ensure this file is actually loaded. The LLM may:
- Skip loading entirely
- Load different files
- Load but not use the information

#### Issue 2: Redundant Context in Multiple Files

The same information appears in multiple places:
- Status markers: CLAUDE.md, status-markers.md, state-management.md, preflight-postflight.md
- Artifact paths: CLAUDE.md, artifact-formats.md (rules), report-format.md
- Delegation patterns: delegation.md, architecture.md, preflight-postflight.md

**Impact**: Token waste and potential inconsistency when information diverges.

#### Issue 3: index.md Is Outdated

Current index.md references files that don't exist:
```markdown
- **state-management.md** (535 lines) - at core/system/state-management.md
```
Actual location: `.claude/context/core/orchestration/state-management.md`

The index references `core/system/` but files are at `core/orchestration/`.

#### Issue 4: Context Loading Strategy Not Per-Operation

All commands use the same context loading approach regardless of:
- Task language (lean vs general vs meta)
- Operation type (research vs plan vs implement)
- Component complexity

#### Issue 5: Skills Don't Load Context - They Just Delegate

Skill files document context references but delegate to agents via Task tool:
```markdown
## Context References
Load these on-demand:
- `@.claude/context/core/formats/subagent-return.md`

## Execution
### 3. Invoke Subagent
Invoke `general-research-agent` via Task tool with:
- Task context (number, name, description, language)
```

**Reality**: Skills are thin wrappers that don't load context themselves - they pass context to agents.

### 3. Analysis: What Context Is Actually Needed

#### 3.1 Context Needs by Operation

| Operation | Required Context | When Needed |
|-----------|-----------------|-------------|
| Research | subagent-return.md, report-format.md, language-tools | At agent execution |
| Plan | subagent-return.md, plan-format.md, task-breakdown.md | At agent execution |
| Implement | subagent-return.md, summary-format.md, git-commits.md | At agent execution |
| Status Update | state-management.md, status-markers.md | At status-sync |
| Artifact Linking | artifact-formats.md (rules), state-management.md | At postflight |

#### 3.2 Context Needs by Component Layer

**Layer 1: Commands**
- Minimal context: Just enough to route and validate
- Required: Task lookup patterns (from CLAUDE.md)
- Never needed: Format specs (delegated to agents)

**Layer 2: Skills**
- Minimal context: Input validation, delegation patterns
- Required: subagent-return.md (for validating returns)
- Never needed: Language-specific context (loaded by agents)

**Layer 3: Agents**
- Full context: Everything needed to execute work
- Required: Format specs, language tools, domain knowledge
- Loaded: On-demand based on task

### 4. Proposed Context Loading Architecture

#### 4.1 Principle: Single Point of Context Loading

**Current**: Context references scattered across commands, skills, agents
**Proposed**: Context loaded ONLY at agent execution boundary

```
Command → [no context] → Skill → [no context] → Agent → [LOAD CONTEXT HERE]
```

**Benefits**:
- Clear loading point
- No redundant loading
- Agents know what they need

#### 4.2 Principle: Context Manifest per Agent

Each agent has a **context manifest** that defines exactly what to load:

```markdown
## Context Manifest

### Required (Always Load)
- `.claude/context/core/formats/subagent-return.md` - Return format
- `.claude/context/core/formats/report-format.md` - Report structure

### Conditional (Load if Language)
- lean: `.claude/context/project/lean4/tools/mcp-tools-guide.md`
- latex: `.claude/context/project/latex/standards/latex-style-guide.md`

### On-Demand (Load when needed)
- When searching Mathlib: `.claude/context/project/lean4/tools/leansearch-api.md`
```

#### 4.3 Principle: Remove Context from Commands and Skills

Commands and skills should NOT have context loading sections:

**Before (Current)**:
```markdown
# skill-researcher

## Context Loading
Load context on-demand:
- `@.claude/context/core/orchestration/state-management.md`
```

**After (Proposed)**:
```markdown
# skill-researcher

## Execution
This skill is a thin wrapper that delegates to general-research-agent.
Context is loaded by the agent, not the skill.
```

#### 4.4 Principle: Consolidated Context Files

Reduce 80+ context files to essential set:

| Category | Current | Proposed | Reduction |
|----------|---------|----------|-----------|
| Orchestration | 10 | 4 | 60% |
| Standards | 10 | 3 | 70% |
| Formats | 6 | 4 | 33% |
| Workflows | 6 | 2 | 67% |
| Templates | 5 | 3 | 40% |
| Total Core | 37 | 16 | 57% |

**Consolidation Mapping**:
- `state-management.md` + `state-lookup.md` + `status-markers.md` → `state.md`
- `delegation.md` + `architecture.md` + `subagent-validation.md` → `delegation.md`
- `preflight-postflight.md` + `command-lifecycle.md` + `status-transitions.md` → `workflows.md`
- `report-format.md` + `plan-format.md` + `summary-format.md` → `artifact-formats.md`

### 5. Recommendations

#### Recommendation 1: Update index.md with Correct Paths

Fix the index to reflect actual file locations:
- `core/system/` → `core/orchestration/`
- Add missing files, remove non-existent files
- Include line counts for budget estimation

#### Recommendation 2: Create Context Manifests for Each Agent

Each agent file should have a standardized context manifest section:
```markdown
## Context Manifest

### Required
- `core/formats/subagent-return.md` (100 lines)
- `core/formats/report-format.md` (66 lines)

### Language-Conditional
- lean: `project/lean4/tools/mcp-tools-guide.md` (150 lines)

### Budget
- Required: ~170 lines
- Conditional: ~150 lines per language
- Total max: ~320 lines
```

#### Recommendation 3: Remove Context Sections from Skills

Skills are thin wrappers - they should not load context. Remove:
```markdown
## Context Loading
Load context on-demand when needed:
- `@.claude/context/...`
```

Replace with:
```markdown
## Context Note
This skill delegates to {agent-name}. Context is loaded by the agent.
```

#### Recommendation 4: Add Context Budget Tracking

Each component should track context budget:
```yaml
context_budget:
  routing_stage: 500 tokens  # Stages 1-3
  execution_stage: 3000 tokens  # Stage 4+
  total_max: 5000 tokens
```

#### Recommendation 5: Consolidate Overlapping Context Files

Phase 1 (Immediate):
- Fix broken references in index.md
- Update skills to remove context loading sections

Phase 2 (Systematic):
- Merge state-management.md + state-lookup.md
- Merge preflight-postflight.md + command-lifecycle.md
- Remove deprecated files after 30-day period

Phase 3 (Validation):
- Add context budget assertions
- Warn on over-budget loading
- Track context usage metrics

### 6. Integration with Checkpoint Model

The context loading standardization integrates with research-002's checkpoint model:

```
CHECKPOINT 1 (GATE IN):
- Context budget: 0 (commands don't load context)
- Only: Task lookup via jq (from CLAUDE.md)

DELEGATION TO AGENT:
- Agent loads its context manifest
- Context budget: ~500-3000 tokens based on language

CHECKPOINT 2 (GATE OUT):
- Context budget: 0 (validation uses inline patterns)
- Only: subagent-return.md validation rules (embedded in skill)

CHECKPOINT 3 (COMMIT):
- Context budget: 0 (git patterns from CLAUDE.md rules)
```

### 7. File-Level Recommendations

#### 7.1 Files to Update

| File | Action | Reason |
|------|--------|--------|
| `.claude/context/index.md` | Fix paths, add budgets | Broken references |
| `.claude/skills/*/SKILL.md` | Remove context sections | Skills don't load context |
| `.claude/agents/*.md` | Add context manifest | Standardize loading |
| `.claude/CLAUDE.md` | Simplify context references | Too verbose |

#### 7.2 Files to Consolidate

| Source Files | Target | Rationale |
|--------------|--------|-----------|
| orchestration/state-management.md + state-lookup.md | state.md | Same topic |
| workflows/preflight-postflight.md + command-lifecycle.md | workflows.md | Same topic |
| formats/report-format.md + plan-format.md + summary-format.md | artifact-formats.md | All artifacts |

#### 7.3 Files to Deprecate

| File | Replacement | Deprecation Date |
|------|-------------|------------------|
| `core/system/state-management.md` | `core/orchestration/state-management.md` | Already deprecated |
| `core/standards/delegation.md` | `core/orchestration/delegation.md` | Consolidated |

### 8. Implementation Priority

**High Priority (Critical for checkpoint model)**:
1. Fix index.md paths - Enables accurate context discovery
2. Add context manifests to agents - Standardizes loading
3. Remove context from skills - Clarifies responsibility

**Medium Priority (Efficiency)**:
4. Consolidate overlapping files - Reduces tokens
5. Add context budget tracking - Enables optimization

**Low Priority (Polish)**:
6. Update all @-references - Consistency
7. Document context loading best practices - Maintenance

## References

- `.claude/context/index.md` - Context discovery index (needs update)
- `.claude/docs/guides/context-loading-best-practices.md` - Loading patterns
- `.claude/context/core/orchestration/architecture.md` - Three-layer pattern
- `specs/432_fix_artifact_linking_in_todo_and_state/reports/research-002.md` - Checkpoint model

## Next Steps

1. Approve context loading standardization approach
2. Create implementation plan integrating with checkpoint model
3. Begin with index.md fixes (immediate impact)
4. Add context manifests to agents (standardization)
5. Remove context from skills (clarification)
