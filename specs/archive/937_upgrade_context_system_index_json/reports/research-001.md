# Research Report: Task #937

**Task**: 937 - Upgrade context system with index.json
**Started**: 2026-02-26T12:00:00Z
**Completed**: 2026-02-26T12:30:00Z
**Effort**: M (medium)
**Dependencies**: None
**Sources/Inputs**: Theory repository .claude/context/index.json, index-query.md, agent files
**Artifacts**: - specs/937_upgrade_context_system_index_json/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- Theory repository has a comprehensive 149-file index.json with embedded JSON Schema for self-documentation
- index.json uses multi-dimensional `load_when` conditions (languages, operations, tiers, agents, conditions)
- Agents use jq queries for dynamic context discovery instead of static @-reference lists
- ProofChecker has 147 context files ready to index; index.json creation is the main work item
- Implementation requires: (1) schema definition, (2) entry generation for all files, (3) validation script, (4) agent file updates

---

## Context & Scope

### What Was Researched
- Theory repository's `.claude/context/index.json` schema and structure
- index-query.md utility documentation for jq-based queries
- Agent files showing dynamic context discovery patterns
- ProofChecker's current context organization (147 files in .claude/context/)
- Differences between static @-reference lists and dynamic discovery

### Constraints
- Must maintain backward compatibility with existing agents
- Must support ProofChecker's language types: lean, logic, math, latex, meta, general
- Should enable context budgeting via line_count filtering

---

## Findings

### 1. index.json Complete Schema

The Theory index.json embeds a full JSON Schema at the top level:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://proofchecker.org/schemas/context-index.json",
  "title": "Context Index Schema",
  "description": "Machine-readable catalog of .claude/context files...",
  "type": "object",
  "required": ["version", "generated_at", "file_count", "entries"],
  "properties": {
    "version": { "type": "string", "pattern": "^\\d+\\.\\d+\\.\\d+$" },
    "generated_at": { "type": "string", "format": "date-time" },
    "file_count": { "type": "integer", "minimum": 0 },
    "entries": { "type": "array", "items": { "$ref": "#/definitions/entry" } }
  },
  "definitions": {
    "entry": { ... },
    "load_conditions": { ... }
  },
  "version": "1.0.0",
  "generated_at": "2026-02-23T15:30:00Z",
  "file_count": 149,
  "entries": [ ... ]
}
```

### 2. Entry Schema (Required and Optional Fields)

**Required Fields**:
| Field | Type | Description |
|-------|------|-------------|
| `path` | string | Relative path from .claude/context/ (e.g., "core/patterns/anti-stop-patterns.md") |
| `domain` | "core" or "project" | Top-level domain |
| `subdomain` | string | Second-level category (e.g., "orchestration", "lean4", "logic") |
| `topics` | array[1-5] | Primary topics for semantic matching |
| `summary` | string (20-200 chars) | Brief description for discovery |
| `load_when` | object | Conditional loading rules |

**Optional Fields**:
| Field | Type | Description |
|-------|------|-------------|
| `category` | string | Third-level category (e.g., "tools", "domain", "patterns") |
| `keywords` | array[0-10] | Search keywords for discovery |
| `line_count` | integer | Context budget estimation (recommended) |
| `deprecated` | boolean | Whether file is deprecated |
| `replaces` | array | Paths of files this entry replaces |

### 3. load_when Conditions Schema

Multi-dimensional filtering with these fields:

```json
{
  "languages": ["lean", "logic", "math", "latex", "typst", "meta", "general", "any"],
  "operations": ["research", "planning", "implementation", "review", "any"],
  "tiers": ["orchestrator", "command", "agent", "any"],
  "agents": ["lean-research-agent", "planner-agent", ...],
  "conditions": ["when proof stuck", "when creating new agents", ...]
}
```

**Matching Rules**:
- `"any"` value matches all languages/operations/tiers
- Arrays use OR logic (any match = load)
- Missing fields default to match-all
- Multiple fields use AND logic (all must match)

### 4. Example Entries by Pattern

**Agent-specific loading** (blocked-mcp-tools.md):
```json
{
  "path": "core/patterns/blocked-mcp-tools.md",
  "domain": "core",
  "subdomain": "patterns",
  "topics": ["MCP", "tools", "blocked"],
  "keywords": ["blocked", "mcp", "lean-lsp", "diagnostic"],
  "summary": "Reference for blocked MCP tools that must not be called due to known bugs",
  "load_when": {
    "languages": ["lean"],
    "operations": ["any"],
    "tiers": ["agent"],
    "agents": ["lean-research-agent", "lean-implementation-agent"]
  },
  "line_count": 65
}
```

**Language + operation filtering** (tactic-patterns.md):
```json
{
  "path": "project/lean4/patterns/tactic-patterns.md",
  "domain": "project",
  "subdomain": "lean4",
  "category": "patterns",
  "topics": ["Lean 4", "tactics", "proof patterns"],
  "keywords": ["tactics", "patterns", "proof", "strategy"],
  "summary": "Common tactic patterns and proof strategies for Lean 4",
  "load_when": {
    "languages": ["lean"],
    "operations": ["implementation"],
    "tiers": ["agent"],
    "agents": ["lean-implementation-agent"],
    "conditions": ["when developing proofs"]
  },
  "line_count": 517
}
```

**Cross-domain loading** (bilateral-semantics.md):
```json
{
  "path": "project/logic/domain/bilateral-semantics.md",
  "domain": "project",
  "subdomain": "logic",
  "category": "domain",
  "topics": ["logic", "bilateral", "semantics"],
  "keywords": ["bilateral", "semantics", "truth", "falsity"],
  "summary": "Bilateral semantics with independent truth and falsity conditions",
  "load_when": {
    "languages": ["logic", "lean"],
    "operations": ["any"],
    "tiers": ["agent"],
    "agents": ["logic-research-agent", "lean-implementation-agent"]
  },
  "line_count": 297
}
```

### 5. Dynamic Context Discovery in Agents

Theory agents use jq queries instead of static @-reference lists:

**Pattern 1: Agent-specific discovery**
```bash
jq -r '.entries[] |
  select(.load_when.agents[]? == "lean-research-agent") |
  select(.deprecated == false or .deprecated == null) |
  "\(.path): \(.summary)"' .claude/context/index.json
```

**Pattern 2: Category filtering**
```bash
# Tools documentation
jq -r '.entries[] |
  select(.load_when.agents[]? == "lean-research-agent") |
  select(.path | contains("/tools/")) |
  .path' .claude/context/index.json
```

**Pattern 3: Language + operation filtering**
```bash
jq -r '.entries[] |
  select(.load_when.languages[]? == "lean" or .load_when.languages[]? == "any") |
  select(.load_when.operations[]? == "research" or .load_when.operations[]? == "any") |
  .path' .claude/context/index.json
```

**Pattern 4: Context budget filtering**
```bash
jq -r '.entries[] | select(.line_count < 200) | "\(.line_count)\t\(.path)"' \
  .claude/context/index.json | sort -n
```

### 6. index-query.md Utility Documentation

Theory provides a comprehensive query utility document covering:
- Quick reference table of common queries
- Field reference with types and constraints
- 10 named query patterns with examples
- Anti-patterns (jq escaping issues, optional field handling)
- Compound query examples

Key anti-patterns documented:
1. Using `!=` in jq (Claude Code escapes it as `\!=`)
2. Missing `?` on optional array fields (keywords, agents, conditions)
3. Loading all domain files without budget filtering

### 7. ProofChecker Current State

**Context file count**: 147 files in `.claude/context/`

**Current organization**:
- `core/` - System orchestration (patterns, workflows, orchestration, etc.)
- `project/` - Domain-specific (lean4, logic, math, latex, etc.)

**Current discovery**: Static @-reference lists in agent files (e.g., lean-research-agent.md)

**index.md exists**: Human-readable markdown index (22,641 bytes) but no machine-readable JSON

### 8. Generation/Validation Scripts

**Finding**: No dedicated generation script found in Theory repository. The index.json appears to have been manually curated or generated through a process not checked into the repository.

**Recommendation**: Create a generation script that:
1. Scans `.claude/context/` for all .md, .json, .yaml files
2. Extracts frontmatter or metadata for auto-population
3. Validates against the embedded JSON Schema
4. Reports line counts via `wc -l`
5. Validates all paths exist on disk

---

## Recommendations

### Implementation Approach

**Phase 1: Create index.json schema** (estimated: 30 min)
1. Copy schema definitions from Theory index.json
2. Adapt $id URL for ProofChecker
3. Add to `.claude/context/index.json`

**Phase 2: Generate entries** (estimated: 2-3 hours)
1. Create generation script `.claude/scripts/generate-context-index.sh`
2. For each context file:
   - Extract path relative to `.claude/context/`
   - Parse domain from path (core/project)
   - Parse subdomain and category from path
   - Generate topics from filename and directory
   - Generate summary from first paragraph or heading
   - Count lines for line_count
   - Assign load_when based on file location patterns
3. Output initial index.json with all 147 entries

**Phase 3: Curate load_when conditions** (estimated: 1-2 hours)
1. Review each entry's load_when for correctness
2. Add specific agent assignments for specialized files
3. Add conditions for situational loading
4. Mark any deprecated files

**Phase 4: Create validation script** (estimated: 30 min)
1. Create `.claude/scripts/validate-context-index.sh`
2. Validate JSON against embedded schema
3. Verify all paths exist on disk
4. Report any orphaned files not in index
5. Check for duplicate paths

**Phase 5: Update agent files** (estimated: 1-2 hours)
1. Replace static @-reference lists with jq query patterns
2. Add "Critical Files" section for always-needed files
3. Add "Dynamic Context Discovery" section with query examples
4. Create index-query.md utility documentation

### Load_when Mapping for ProofChecker

Based on existing agent files and context structure:

| Language | Agents | Subdomains |
|----------|--------|------------|
| lean | lean-research-agent, lean-implementation-agent | lean4, logic (cross-domain) |
| logic | logic-research-agent, lean-implementation-agent | logic |
| math | math-research-agent | logic (cross-domain) |
| latex | latex-research-agent, latex-implementation-agent | latex |
| meta | meta-builder-agent, general-implementation-agent | architecture, orchestration |
| general | general-research-agent, general-implementation-agent | (all core) |

---

## Decisions

1. **Embed schema in index.json**: Self-documenting format that enables validation
2. **Use semantic versioning**: Start with version "1.0.0"
3. **Include line_count**: Essential for context budgeting
4. **Support conditions field**: Free-form situational loading
5. **Create generation script**: Automate initial population and updates
6. **Port index-query.md**: Provide jq query patterns documentation

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Manual entry curation is time-consuming | High | Medium | Create generation script with sensible defaults |
| load_when conditions incorrectly assigned | Medium | Medium | Review phase after generation; test with sample queries |
| jq escaping issues (Claude Code bug #1132) | High | Low | Document workarounds in index-query.md |
| Orphaned files not in index | Medium | Low | Validation script checks for unindexed files |
| Agents don't adopt new pattern | Low | Medium | Update all agent files in implementation phase |

---

## Appendix

### Search Queries Used
1. `find .claude/context -name "*.md"` - Count context files
2. `grep -r "index.json"` - Find references to index
3. `grep '"agents":'` - Find agent-specific load_when entries

### References
- `/home/benjamin/Projects/Logos/Theory/.claude/context/index.json` (109KB, 149 entries)
- `/home/benjamin/Projects/Logos/Theory/.claude/context/core/utils/index-query.md` (340 lines)
- `/home/benjamin/Projects/Logos/Theory/.claude/agents/lean-research-agent.md` (dynamic discovery pattern)
- `/home/benjamin/Projects/ProofChecker/.claude/context/index.md` (current human-readable index)
- `/home/benjamin/Projects/ProofChecker/.claude/agents/lean-research-agent.md` (current static @-references)

### ProofChecker Context Subdomain Structure

```
core/
  architecture/
  checkpoints/
  formats/
  orchestration/
  patterns/
  reference/
  routing.md
  standards/
  troubleshooting/
  utils/
  validation.md
  workflows/

project/
  lean4/
    agents/
    domain/
    operations/
    patterns/
    processes/
    standards/
    templates/
    tools/
  logic/
    domain/
  math/
  latex/
  repo/
```
