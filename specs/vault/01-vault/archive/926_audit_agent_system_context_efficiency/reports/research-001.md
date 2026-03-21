# Research Report: Task #926

**Task**: Audit Agent System Context Efficiency
**Date**: 2026-02-25
**Focus**: Review .claude/ directory structure and identify opportunities to reduce context bloat

## Summary

The .claude/ directory contains 4.7MB of content across 251 files, with 217 markdown files averaging 339 lines each. At session startup, Claude loads CLAUDE.md files plus all .claude/rules/*.md files unconditionally (1,929 total lines, ~57KB). This represents approximately 14,000-19,000 tokens loaded at startup before any user interaction, contributing significantly to the observed 20% initial context usage.

## Findings

### Current State Metrics

| Category | Value | Notes |
|----------|-------|-------|
| Total .claude/ size | 4.7 MB | Includes logs (1.6MB), context (1.7MB) |
| Total markdown files | 217 | Average 339 lines each |
| CLAUDE.md (main) | 227 lines / 9.5KB | In .claude/ directory |
| CLAUDE.md (root) | 55 lines / 1.2KB | Worktree metadata only |
| Rules files total | 1,647 lines / 47KB | 7 files, auto-loaded |
| README.md | 1,152 lines / 39KB | Not auto-loaded |

### What Gets Loaded at Startup

Based on official Claude Code documentation and web research:

1. **Always loaded** (high priority):
   - All CLAUDE.md files from cwd up to (but not including) root directory
   - All .claude/rules/*.md files unconditionally
   - User-level rules from ~/.claude/rules/
   - Auto memory (~/.claude/projects/\<project\>/memory/MEMORY.md) - first 200 lines

2. **Loaded on-demand** (when working with matching files):
   - Rules with `paths:` frontmatter - only when working on matching paths
   - CLAUDE.md files in subdirectories - when Claude reads files in those directories
   - Context files via @-reference imports

### Startup Context Budget

| Component | Lines | Est. Tokens | Notes |
|-----------|-------|-------------|-------|
| .claude/CLAUDE.md | 227 | ~3,000 | Tables and code blocks inflate tokens |
| rules/state-management.md | 271 | ~3,600 | Detailed JSON examples |
| rules/artifact-formats.md | 393 | ~5,200 | Many templates |
| rules/error-handling.md | 280 | ~3,700 | Full error patterns |
| rules/workflows.md | 224 | ~3,000 | ASCII flow diagrams |
| rules/git-workflow.md | 163 | ~2,200 | Commit conventions |
| rules/lean4.md | 185 | ~2,500 | MCP tool guidance |
| rules/latex.md | 131 | ~1,700 | LaTeX conventions |
| **Total startup** | **1,874** | **~25,000** | ~12-15% of context window |

### Bloat Sources Identified

#### 1. Rules Files Too Detailed (High Impact)

The rules files contain extensive inline documentation that should be lazy-loaded:

- **artifact-formats.md** (393 lines): Full template examples for every artifact type
- **state-management.md** (271 lines): Complete JSON schemas with examples
- **error-handling.md** (280 lines): Full error recovery procedures

**Recommendation**: Trim to essential rules only (behavior directives), move detailed schemas/examples to context files.

#### 2. CLAUDE.md Contains Reference Tables (Medium Impact)

The main CLAUDE.md has:
- 5 code blocks (10 fence markers)
- 50 table rows
- Complete command reference with examples
- Full skill-to-agent mapping table

**Recommendation**: CLAUDE.md should contain only critical behavioral instructions. Move reference tables to context files that load on-demand.

#### 3. No Path-Scoping on Most Rules (Medium Impact)

Only 4 of 7 rules files use `paths:` frontmatter:
- artifact-formats.md: `paths: specs/**/*`
- state-management.md: `paths: specs/**/*`
- latex.md: `paths: **/*.tex`
- lean4.md: `paths: **/*.lean`

These 4 files should only load when working with matching paths, but the remaining 3 (git-workflow.md, error-handling.md, workflows.md) load unconditionally.

**Current behavior**: Rules with path frontmatter should only receive high priority when working on matching files. However, all rules are still loaded into context.

#### 4. Large Context Directory (Low Impact - Not Auto-Loaded)

The context/ directory (1.7MB) contains detailed documentation:
- Largest file: error-handling.md (1,056 lines)
- Many files exceed 500 lines

This is not loaded at startup (correct lazy loading pattern), but individual files are large when loaded via @-reference.

#### 5. Output and Logs Directories (No Impact)

These directories consume disk but are not loaded into context:
- output/: 252KB (debug transcripts)
- logs/: 1.6MB (session logs, not context-loaded)

### 2026 Best Practices from Web Research

**Key principles discovered**:

1. **CLAUDE.md size**: Official guidance recommends under 100-150 lines. Current .claude/CLAUDE.md is 227 lines (exceeds recommendation).

2. **Context is paramount**: "The most successful Claude Code users obsessively manage context through CLAUDE.md files, aggressive /clear usage, documentation systems, and token-efficient tool design."

3. **Subagents for context isolation**: "Subagents run in separate context windows and report back summaries" - already implemented in this project.

4. **Programmatic tool calling**: Anthropic reports 37% token reduction using programmatic tool calling over traditional approaches.

5. **Path-targeted rules**: "When a rule has paths frontmatter, it only loads (and receives high priority) when Claude is working on matching files."

6. **Memory file best practices**: "Format each individual memory as a bullet point and group related memories under descriptive markdown headings."

### Redundancy Analysis

Pattern searches found significant duplication:

| Pattern | Occurrences | Files |
|---------|-------------|-------|
| `Co-Authored-By:` | 49 | 31 files |
| `state.json` | 751 | 99 files |
| `lean_leansearch` | 39 | 16 files |

This suggests documentation duplication across:
- Skills, agents, and context files documenting the same patterns
- Multiple files explaining state.json structure
- MCP tool references repeated in many places

## Recommendations

### Priority 1: Restructure CLAUDE.md (Est. -8,000 tokens at startup)

Reduce .claude/CLAUDE.md from 227 lines to ~80 lines:

**Keep only**:
- Project structure summary (5 lines)
- Critical behavioral rules (10-15 lines)
- Status markers list (compact)
- Command quick reference (names only, no descriptions)
- Critical warnings (blocked MCP tools)

**Move to context files** (lazy load):
- Full command reference table
- Skill-to-agent mapping table
- Language routing table
- JSON schema examples
- Team skill model defaults

### Priority 2: Trim Rules Files (Est. -10,000 tokens at startup)

Target: Reduce total rules from 1,647 lines to ~500 lines.

**artifact-formats.md**: Keep placeholder conventions, remove full templates
**state-management.md**: Keep status transitions, remove JSON examples
**error-handling.md**: Keep error categories, remove recovery procedures
**workflows.md**: Keep flow summaries, remove ASCII diagrams

### Priority 3: Add Path Scoping to All Rules

All rules should use `paths:` frontmatter:

```yaml
# git-workflow.md
---
paths:
  - ".git/**"
  - "**/*.git*"
---
```

```yaml
# error-handling.md
---
paths:
  - ".claude/**"
  - "specs/**"
---
```

### Priority 4: Create Quick Reference Card

Create a new minimal CLAUDE.md (~50 lines) containing only:
1. Project name and purpose (2 lines)
2. Key directories (5 lines)
3. Active commands (list of names, 10 lines)
4. Critical rules (10 lines)
5. @-references for details (10 lines)

### Estimated Savings

| Change | Lines Removed | Token Savings |
|--------|---------------|---------------|
| Trim CLAUDE.md | 147 lines | ~5,000 tokens |
| Trim rules files | 1,147 lines | ~15,000 tokens |
| Path-scope remaining rules | N/A | Variable (file-dependent) |
| **Total** | **~1,300 lines** | **~20,000 tokens** |

This would reduce startup context from ~25,000 tokens to ~5,000 tokens, lowering initial context usage from 20% to approximately 4-5%.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking agent workflows | Test each agent type after changes |
| Missing critical context | Ensure @-references work for lazy loading |
| Regression in task management | Keep state.json structure docs accessible |
| Team coordination issues | Update context/index.md with new locations |

## References

- [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)
- [Manage Claude's Memory](https://code.claude.com/docs/en/memory) - Official documentation on CLAUDE.md and rules loading
- [Claude Code Rules Directory Guide](https://claudefa.st/blog/guide/mechanics/rules-directory)
- [Context Management Optimization](https://institute.sfeir.com/en/claude-code/claude-code-context-management/optimization/)
- [Claude's Context Engineering Secrets](https://01.me/en/2025/12/context-engineering-from-claude/)
- [Writing a Good CLAUDE.md](https://www.builder.io/blog/claude-md-guide)

## Next Steps

Run `/plan 926` to create an implementation plan for restructuring CLAUDE.md and rules files with specific file changes and verification steps.
