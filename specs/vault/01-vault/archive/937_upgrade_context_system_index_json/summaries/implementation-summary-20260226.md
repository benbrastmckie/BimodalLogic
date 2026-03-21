# Implementation Summary: Task #937

**Task**: Upgrade context system with index.json
**Status**: [COMPLETED]
**Started**: 2026-02-26
**Completed**: 2026-02-26
**Language**: meta

## Overview

Created a machine-readable context index system (index.json) with load_when conditions for dynamic context discovery. This enables agents to query context files programmatically using jq, replacing static @-reference lists with intelligent context loading based on language, operation, tier, and agent type.

## Phase Log

### Phase 1: Create index.json Schema and Structure [COMPLETED]

- Created `.claude/context/index.json` with embedded JSON Schema
- Schema includes definitions for entry and load_conditions
- Set version 1.0.0, generated_at timestamp, empty entries array
- Verified JSON syntax correctness

### Phase 2: Create Generation Script [COMPLETED]

- Created `.claude/scripts/generate-context-index.sh`
- Implemented file scanning for `.claude/context/**/*.md`
- Extracts domain, subdomain, category from path
- Generates topics from filename and directory
- Generates summary from first heading
- Counts lines for line_count field
- Assigns load_when based on subdomain patterns
- Generated 149 entries successfully

### Phase 3: Curate load_when Conditions [COMPLETED]

- Ran generation script to create initial index
- Added conditions field to 9 specialized files:
  - `blocked-mcp-tools.md`: "when using Lean MCP tools"
  - `tactic-patterns.md`: "when developing proofs", "when proof stuck"
  - `anti-stop-patterns.md`: "when building agents", "when creating skills"
  - `team-orchestration.md`: "when using teams", "when spawning teammates"
  - `modal-proof-strategies.md`: "when proving modal theorems"
  - `temporal-proof-strategies.md`: "when proving temporal theorems"
  - `workflow-interruptions.md`: "when workflow fails", "when agent hangs"
  - `early-metadata-pattern.md`: "when building agents"
  - `index-query.md`: "when querying context index"
- Marked `status-transitions.md` as deprecated
- Verified sample queries execute correctly

### Phase 4: Create Validation Script and Documentation [COMPLETED]

- Created `.claude/scripts/validate-context-index.sh`
- Validates JSON syntax, required fields, path existence
- Checks for duplicate paths and orphaned files
- Reports deprecated entries
- Verifies entry count matches declared count
- Created `.claude/context/core/utils/index-query.md` with:
  - Quick reference table (7 common queries)
  - Field reference with types and constraints
  - 11 named query patterns with examples
  - Anti-patterns section (jq escaping, optional fields, budget)
  - 4 usage examples
  - Maintenance section

### Phase 5: Update Agent Files [COMPLETED]

- Added "Dynamic Context Discovery" section to:
  - `lean-research-agent.md`
  - `lean-implementation-agent.md`
  - `general-research-agent.md`
  - `general-implementation-agent.md`
  - `planner-agent.md`
- Each section includes 3 jq query examples tailored to agent use case
- Updated `.claude/CLAUDE.md` with "Context Discovery" section
- Updated `.claude/context/index.md` with machine-readable index section

## Artifacts Created

| Artifact | Path | Description |
|----------|------|-------------|
| index.json | `.claude/context/index.json` | Machine-readable context index (149 entries) |
| generate-context-index.sh | `.claude/scripts/generate-context-index.sh` | Index generation script |
| validate-context-index.sh | `.claude/scripts/validate-context-index.sh` | Index validation script |
| index-query.md | `.claude/context/core/utils/index-query.md` | jq query patterns documentation |

## Files Modified

- `.claude/agents/lean-research-agent.md` - Added Dynamic Context Discovery section
- `.claude/agents/lean-implementation-agent.md` - Added Dynamic Context Discovery section
- `.claude/agents/general-research-agent.md` - Added Dynamic Context Discovery section
- `.claude/agents/general-implementation-agent.md` - Added Dynamic Context Discovery section
- `.claude/agents/planner-agent.md` - Added Dynamic Context Discovery section
- `.claude/CLAUDE.md` - Added Context Discovery section with query examples
- `.claude/context/index.md` - Added machine-readable index reference

## Verification Results

```
Validating context index: .claude/context/index.json
========================================
1. JSON syntax: OK
2. Required fields: OK
3. Path existence: OK
4. Duplicate paths: OK
5. Orphaned files: OK
6. Deprecated entries:
   Deprecated: core/workflows/status-transitions.md
7. Entry count match: OK (149 entries)
8. load_when validation: OK

========================================
Validation PASSED
```

## Sample Query Results

```bash
# Lean research agent context files
jq -r '.entries[] | select(.load_when.agents[]? == "lean-research-agent") | .path' \
  .claude/context/index.json | head -5
# core/patterns/blocked-mcp-tools.md
# project/lean4/domain/dependent-types.md
# project/lean4/domain/key-mathematical-concepts.md
# project/lean4/domain/lean4-syntax.md
# project/lean4/domain/mathlib-overview.md

# Files under 200 lines
jq '.entries[] | select(.line_count < 200) | .path' .claude/context/index.json | wc -l
# 48
```

## Cumulative Statistics

| Metric | Value |
|--------|-------|
| Phases completed | 5/5 |
| Files created | 4 |
| Files modified | 7 |
| Index entries | 149 |
| Deprecated entries | 1 |
| Entries with conditions | 9 |

## Notes

- The index.json regeneration overwrites curations; consider a separate curations file for future enhancement
- jq escaping issue (#1132) documented in index-query.md anti-patterns section
- Validation script includes --fix option to regenerate on failure
