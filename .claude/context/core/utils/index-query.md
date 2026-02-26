# Index Query Utility

How to programmatically query the context index using jq.

## Quick Reference

| Use Case | Pattern |
|----------|---------|
| Find by topic | `jq -r '.entries[] \| select(.topics[] == "TOPIC") \| .path'` |
| Search keywords | `jq -r '.entries[] \| select(.keywords[]? \| contains("TERM")) \| .path'` |
| Filter by domain | `jq -r '.entries[] \| select(.domain == "core") \| .path'` |
| Filter by language | `jq -r '.entries[] \| select(.load_when.languages[]? == "lean") \| .path'` |
| Filter by operation | `jq -r '.entries[] \| select(.load_when.operations[]? == "research") \| .path'` |
| Files under budget | `jq -r '.entries[] \| select(.line_count < 200) \| .path'` |
| Exclude deprecated | `jq -r '.entries[] \| select(.deprecated == false or .deprecated == null) \| .path'` |

**Index location**: `.claude/context/index.json`

---

## Field Reference

The index.json contains an `entries` array where each entry has these fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `path` | string | Yes | Relative path from `.claude/context/` |
| `domain` | "core" or "project" | Yes | Top-level domain |
| `subdomain` | string | Yes | Category (orchestration, lean4, patterns, etc.) |
| `category` | string | No | Third-level category |
| `topics` | array[1-5] | Yes | Primary topics for semantic matching |
| `keywords` | array[0-10] | No | Search keywords for discovery |
| `summary` | string | Yes | 20-200 char description |
| `load_when` | object | Yes | Conditional loading rules |
| `line_count` | integer | Yes | Context budget estimation |
| `deprecated` | boolean | No | Whether file is deprecated |

### load_when Object

The `load_when` object enables multi-dimensional filtering:

```json
{
  "languages": ["lean", "logic", "math", "latex", "typst", "meta", "general", "any"],
  "operations": ["research", "planning", "implementation", "review", "any"],
  "tiers": ["orchestrator", "command", "agent", "any"],
  "agents": ["lean-research-agent", "..."],
  "conditions": ["when proof stuck", "when creating new agents", "..."]
}
```

---

## Query Patterns

All patterns assume execution from the project root directory.

### Pattern 1: Topic Matching (Exact)

Find files that cover a specific topic.

```bash
jq -r '.entries[] | select(.topics[] == "delegation") | .path' \
  .claude/context/index.json
```

**Use when**: You need files on a specific topic like "kripke", "tactics", or "error handling".

**Example output**:
```
core/patterns/delegation.md
core/orchestration/workflow-delegation.md
```

### Pattern 2: Topic Matching (Partial)

Find files with topics containing a substring.

```bash
jq -r '.entries[] | select(.topics[] | contains("proof")) | .path' \
  .claude/context/index.json
```

**Use when**: Topic might be phrased differently ("proof", "proofs", "proving").

### Pattern 3: Keyword Search

Search by keywords (broader than topics).

```bash
jq -r '.entries[] | select(.keywords[]? | contains("mcp")) | .path' \
  .claude/context/index.json
```

**Use when**: Looking for related content that might not be in primary topics.

**Note**: Use `[]?` suffix for optional fields like `keywords` to handle entries without keywords.

### Pattern 4: Domain Filtering

Get all files in a domain.

```bash
jq -r '.entries[] | select(.domain == "project") | .path' \
  .claude/context/index.json
```

Combined with subdomain:

```bash
jq -r '.entries[] | select(.domain == "project" and .subdomain == "lean4") | .path' \
  .claude/context/index.json
```

**Use when**: You need domain-specific context (e.g., all Lean 4 files, all core patterns).

### Pattern 5: Language-Based Loading

Find files appropriate for a task language.

```bash
jq -r '.entries[] | select(.load_when.languages[]? == "lean" or .load_when.languages[]? == "any") | .path' \
  .claude/context/index.json
```

**Use when**: Loading context for language-specific tasks. "any" matches all languages.

### Pattern 6: Operation-Based Loading

Find files for a specific operation type.

```bash
jq -r '.entries[] | select(.load_when.operations[]? == "research" or .load_when.operations[]? == "any") | .path' \
  .claude/context/index.json
```

**Use when**: Loading context for a specific operation (research, planning, implementation, review). "any" matches all operations.

### Pattern 7: Agent-Specific Loading

Find files designated for a specific agent.

```bash
jq -r '.entries[] | select(.load_when.agents[]? == "lean-research-agent") | .path' \
  .claude/context/index.json
```

**Use when**: An agent needs to find files explicitly tagged for its use.

### Pattern 8: Context Budget-Aware Queries

Find files under a line count threshold, sorted by size.

```bash
jq -r '.entries[] | select(.line_count < 200) | "\(.line_count)\t\(.path)"' \
  .claude/context/index.json | sort -n
```

Sum total lines for a subdomain:

```bash
jq '[.entries[] | select(.subdomain == "patterns") | .line_count] | add' \
  .claude/context/index.json
```

**Use when**: Staying within context budget. Load smaller files first.

### Pattern 9: Cross-Domain Discovery

Find files sharing topics with a known file.

```bash
jq -r '
  .entries[] |
  select(.topics | any(. == "delegation" or . == "routing")) |
  .path
' .claude/context/index.json
```

Multi-topic intersection using a shell loop:

```bash
TOPICS=$(jq -r '.entries[] | select(.path == "core/patterns/delegation.md") | .topics[]' \
  .claude/context/index.json)
for topic in $TOPICS; do
  jq -r --arg t "$topic" '.entries[] | select(.topics[] == $t) | .path' \
    .claude/context/index.json
done | sort -u
```

**Use when**: Researching a topic and need related files across domains.

### Pattern 10: Exclude Deprecated Files

Filter out deprecated content from any query.

```bash
jq -r '.entries[] | select(.deprecated == false or .deprecated == null) | .path' \
  .claude/context/index.json
```

Combine with other patterns:

```bash
jq -r '.entries[] |
  select(.domain == "project") |
  select(.deprecated == false or .deprecated == null) |
  .path' .claude/context/index.json
```

**Use when**: Always include in production queries to avoid loading stale files.

### Pattern 11: Condition-Based Discovery

Find files with specific situational conditions.

```bash
jq -r '.entries[] | select(.load_when.conditions[]? | contains("proof stuck")) | .path' \
  .claude/context/index.json
```

**Use when**: Looking for help with a specific situation.

---

## Compound Queries

Combine conditions with `and` for precise filtering.

### Language + Operation

```bash
jq -r '.entries[] |
  select(
    (.load_when.languages[]? == "lean" or .load_when.languages[]? == "any") and
    (.load_when.operations[]? == "research" or .load_when.operations[]? == "any")
  ) | .path' .claude/context/index.json
```

### Domain + Topic + Budget

```bash
jq -r '.entries[] |
  select(.domain == "project") |
  select(.topics[] == "tactics") |
  select(.line_count < 300) |
  .path' .claude/context/index.json
```

### Summary Preview (for selection)

Show path and summary for informed decisions:

```bash
jq -r '.entries[] |
  select(.subdomain == "lean4") |
  "\(.path)\n  \(.summary)\n"' .claude/context/index.json
```

---

## Anti-patterns

### Anti-pattern 1: Using `!=` in jq (Issue #1132)

Claude Code escapes `!=` as `\!=`, causing parse errors.

```bash
# WRONG - causes INVALID_CHARACTER error
jq '.entries[] | select(.domain != "core") | .path' .claude/context/index.json

# CORRECT - use "| not" pattern
jq -r '.entries[] | select(.domain == "core" | not) | .path' .claude/context/index.json
```

### Anti-pattern 2: Missing `?` on Optional Fields

`keywords`, `conditions`, and `agents` may be absent. Without `?`, jq errors on missing fields.

```bash
# WRONG - fails if entry has no keywords field
jq -r '.entries[] | select(.keywords[] | contains("mcp")) | .path' .claude/context/index.json

# CORRECT - use []? for optional array fields
jq -r '.entries[] | select(.keywords[]? | contains("mcp")) | .path' .claude/context/index.json
```

### Anti-pattern 3: Loading All Domain Files

Fetching all files in a domain without budget filtering risks context bloat.

```bash
# RISKY - may load hundreds of large files
jq -r '.entries[] | select(.domain == "project") | .path' .claude/context/index.json

# BETTER - add line_count filter
jq -r '.entries[] | select(.domain == "project") | select(.line_count < 150) | .path' \
  .claude/context/index.json
```

### Anti-pattern 4: Querying Stale Index

The index.json must be regenerated after adding or moving context files. Stale entries return wrong paths.

**Check**: If a path returned by a query does not exist on disk, the index needs regeneration.

**Fix**: Run `.claude/scripts/generate-context-index.sh`

---

## Usage Examples

### Example 1: lean-research-agent startup

```bash
# Load all files tagged for lean research
jq -r '.entries[] |
  select(.load_when.agents[]? == "lean-research-agent") |
  select(.deprecated == false or .deprecated == null) |
  .path' .claude/context/index.json
```

### Example 2: Find context for a stuck proof

```bash
# Find files related to proof strategies and tactics
jq -r '.entries[] |
  select(.topics | any(. == "tactics" or . == "proof" or . == "strategies")) |
  select(.line_count < 250) |
  .path' .claude/context/index.json
```

### Example 3: Implementation agent context

```bash
# Load files for implementation operations, meta language, under budget
jq -r '.entries[] |
  select(.load_when.operations[]? == "implementation" or .load_when.operations[]? == "any") |
  select(.load_when.languages[]? == "meta" or .load_when.languages[]? == "any") |
  select(.line_count < 200) |
  select(.deprecated == false or .deprecated == null) |
  .path' .claude/context/index.json
```

### Example 4: List all entries with conditions

```bash
# Show entries that have situational loading conditions
jq -r '.entries[] |
  select((.load_when.conditions == null) | not) |
  "\(.path): \(.load_when.conditions)"' .claude/context/index.json
```

---

## Maintenance

### Regenerating the Index

After adding, moving, or removing context files:

```bash
.claude/scripts/generate-context-index.sh
```

### Validating the Index

Check for issues (missing files, duplicates, etc.):

```bash
.claude/scripts/validate-context-index.sh
```

### Auto-fix Validation Issues

Regenerate if validation fails:

```bash
.claude/scripts/validate-context-index.sh --fix
```

---

## Notes

- **Index location**: `.claude/context/index.json` (relative to project root)
- **Regeneration**: Run the generation script after adding/moving context files
- **Line counts**: Approximate; use for budgeting, not exact limits
- **`any` value**: In `languages`, `operations`, and `tiers` fields, `"any"` matches all values
