# Research Report: Task #351

**Task**: Review and fix skill context loading
**Date**: 2026-01-10
**Focus**: Analyze current skill context patterns and recommend appropriate context files

## Summary

All 9 skills currently use `context: fork` which forks the entire conversation context. This is inefficient and doesn't load task-specific domain knowledge. Each skill should instead load only the context files relevant to its domain and purpose, following the three-tier loading strategy documented in the context README.

## Findings

### Current State: All Skills Use `context: fork`

| Skill | Current Context | Issue |
|-------|-----------------|-------|
| skill-lean-implementation | `fork` | Missing Lean tools/patterns context |
| skill-lean-research | `fork` | Missing Lean search tools context |
| skill-latex-implementation | `fork` | Missing standards context |
| skill-implementer | `fork` | Missing core formats context |
| skill-researcher | `fork` | Missing core formats context |
| skill-planner | `fork` | Missing plan format context |
| skill-status-sync | `fork` | Missing state-management context |
| skill-git-workflow | `fork` | Missing git-safety context |
| skill-orchestrator | `fork` | Missing routing/delegation context |

### Available Context Files

The context directory has a well-organized structure:

**Core Context** (`core/`):
- `orchestration/` - routing, delegation, state-management, state-lookup
- `formats/` - plan-format, report-format, summary-format, command-structure
- `standards/` - code-patterns, error-handling, git-safety, documentation
- `workflows/` - command-lifecycle, status-transitions, preflight-postflight

**Lean4 Context** (`project/lean4/`):
- `tools/` - mcp-tools-guide, leansearch-api, loogle-api, lsp-integration, aesop-integration
- `patterns/` - tactic-patterns
- `standards/` - lean4-style-guide, proof-conventions-lean, proof-readability-criteria
- `processes/` - end-to-end-proof-workflow

**Logic Context** (`project/logic/`):
- `domain/` - kripke-semantics-overview, metalogic-concepts, proof-theory-concepts
- `standards/` - proof-conventions, notation-standards

**Meta Context** (`project/meta/`):
- architecture-principles, domain-patterns, meta-guide

### Context Loading Strategy (from README)

The documented three-tier loading strategy:

**Tier 1: Orchestrator (Minimal)** - <5% context window (~10KB)
- Files: routing.md, delegation.md
- Purpose: Routing and delegation safety

**Tier 2: Commands (Targeted)** - 10-20% context window (~20-40KB)
- Files: subagent-return.md, status-transitions.md, command-specific
- Purpose: Command validation and formatting

**Tier 3: Agents (Domain-Specific)** - 60-80% context window (~120-160KB)
- Files: project/lean4/*, project/logic/*, etc.
- Purpose: Domain-specific work with full context

## Recommendations

### Skill-Specific Context Assignments

#### skill-lean-implementation
**Purpose**: Execute Lean 4 theorem proving
**Recommended context**:
```yaml
context:
  - .claude/context/project/lean4/tools/mcp-tools-guide.md
  - .claude/context/project/lean4/patterns/tactic-patterns.md
  - .claude/context/project/lean4/standards/lean4-style-guide.md
```
**Rationale**: Needs MCP tools reference for lean_goal, lean_diagnostic_messages, etc. Tactic patterns help with proof development. Style guide ensures code quality.

#### skill-lean-research
**Purpose**: Research Lean 4 and Mathlib
**Recommended context**:
```yaml
context:
  - .claude/context/project/lean4/tools/mcp-tools-guide.md
  - .claude/context/project/lean4/tools/leansearch-api.md
  - .claude/context/project/lean4/tools/loogle-api.md
```
**Rationale**: Needs search tool documentation for leansearch, loogle, leanfinder rate limits and query patterns.

#### skill-latex-implementation
**Purpose**: Implement LaTeX documents
**Recommended context**:
```yaml
context:
  - .claude/context/core/formats/summary-format.md
```
**Rationale**: Minimal context needed. LaTeX knowledge is general. Only needs output format standards.

#### skill-implementer
**Purpose**: General implementation tasks
**Recommended context**:
```yaml
context:
  - .claude/context/core/formats/summary-format.md
  - .claude/context/core/standards/code-patterns.md
```
**Rationale**: Needs summary format for creating implementation summaries. Code patterns for quality standards.

#### skill-researcher
**Purpose**: General research tasks
**Recommended context**:
```yaml
context:
  - .claude/context/core/formats/report-format.md
```
**Rationale**: Only needs report format for creating research reports.

#### skill-planner
**Purpose**: Create implementation plans
**Recommended context**:
```yaml
context:
  - .claude/context/core/formats/plan-format.md
  - .claude/context/core/workflows/task-breakdown.md
```
**Rationale**: Needs plan format for structuring plans. Task breakdown helps with phase decomposition.

#### skill-status-sync
**Purpose**: Atomic status updates
**Recommended context**:
```yaml
context:
  - .claude/context/core/orchestration/state-management.md
  - .claude/context/core/orchestration/state-lookup.md
```
**Rationale**: Needs state management patterns and lookup patterns for jq/grep operations.

#### skill-git-workflow
**Purpose**: Create git commits
**Recommended context**:
```yaml
context:
  - .claude/context/core/standards/git-safety.md
```
**Rationale**: Needs git safety patterns to avoid destructive operations.

#### skill-orchestrator
**Purpose**: Route commands to skills
**Recommended context**:
```yaml
context:
  - .claude/context/core/orchestration/routing.md
  - .claude/context/core/orchestration/delegation.md
```
**Rationale**: Needs routing logic for language-based skill selection. Delegation patterns for invoking skills.

### Context Format Options

The skill frontmatter supports these context formats:

1. **`context: fork`** - Fork current conversation context (current approach, inefficient)
2. **`context: ["path1", "path2"]`** - Load specific files
3. **`context: inherit`** - Inherit context from parent (useful for nested skills)

### Implementation Approach

1. Replace `context: fork` with specific file lists
2. Keep context minimal (2-4 files per skill)
3. Test each skill after changes to verify no regressions
4. Document context loading rationale in each skill file

## Potential Challenges

1. **Context format validation**: Ensure the skill system supports array context format
2. **Path resolution**: Verify relative vs absolute path handling
3. **Context size**: Monitor total context size doesn't exceed tier limits

## References

- `.claude/context/README.md` - Context organization documentation
- `.claude/context/index.md` - Context loading examples
- `.claude/context/project/lean4/README.md` - Lean4 context guidance

## Next Steps

1. Update each SKILL.md file with appropriate context arrays
2. Verify skill system parses array context format correctly
3. Test each skill to ensure domain knowledge is available
4. Monitor context window usage to stay within tier limits
