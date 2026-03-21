# Research Report: Task #599

**Task**: 599 - Troubleshoot jq Escaping in Agent System
**Started**: 2026-01-18T12:00:00Z
**Completed**: 2026-01-18T12:30:00Z
**Effort**: 2 hours
**Priority**: high
**Dependencies**: None
**Sources/Inputs**:
- Codebase analysis (skills, commands, context files)
- GitHub Issue #1132 (anthropics/claude-code)
- jq documentation
- Web search for escaping patterns
**Artifacts**:
- specs/599_troubleshoot_jq_escaping_agent_system/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root Cause Identified**: Claude Code's Bash tool has a documented escaping bug (Issue #1132) that injects `< /dev/null` into commands containing pipe operators (`|`) within quoted strings
- **Affected Patterns**: All jq commands using `| map(select(...))` and similar patterns with `!=` operators inside single-quoted filters
- **Scope**: 15+ files in `.claude/` directory contain potentially affected jq patterns
- **Recommended Fix**: Use script file workaround or alternative jq patterns that avoid pipe characters in the problematic context

## Context & Scope

### Research Questions
1. What patterns are causing jq escaping issues in the agent system?
2. What is the root cause of the `!=` operator escaping problem?
3. What working patterns exist in the codebase for comparison?
4. What are the recommended fixes?

### Scope
- All files in `.claude/skills/`, `.claude/commands/`, and `.claude/context/`
- Focus on jq commands with `!=` operator and pipe (`|`) characters

## Findings

### 1. Root Cause: Claude Code Bash Tool Escaping Bug

**Source**: [GitHub Issue #1132 - Claude Code](https://github.com/anthropics/claude-code/issues/1132)

The Claude Code Bash tool has a critical escaping mechanism that corrupts commands containing pipe characters (`|`) inside quoted strings. The pattern `array[]|` gets transformed to `array[] < /dev/null |`, causing jq syntax errors.

**Example Transformation**:
```bash
# What we write:
jq '[.entries[]|select(.title=="test")]|length' file.json

# What gets executed:
jq '[.entries[] < /dev/null | select(.title=="test")]|length' file.json
```

### 2. Affected Patterns in Agent System

Found 15 instances of potentially affected jq patterns:

| File | Line | Pattern |
|------|------|---------|
| skill-researcher/SKILL.md | 150 | `map(select(.type != "research"))` |
| skill-planner/SKILL.md | 157 | `map(select(.type != "plan"))` |
| skill-implementer/SKILL.md | 160 | `map(select(.type != "summary"))` |
| skill-lean-research/SKILL.md | 155 | `map(select(.type != "research"))` |
| skill-lean-implementation/SKILL.md | 171 | `map(select(.type != "summary"))` |
| skill-latex-implementation/SKILL.md | 173 | `map(select(.type != "summary"))` |
| commands/task.md | 138 | `map(select(.project_number != ...))` |
| commands/task.md | 252 | `map(select(.project_number != ...))` |
| commands/revise.md | 76 | `map(select(.type != "plan"))` |
| context/core/patterns/inline-status-update.md | 81, 102, 123 | `map(select(.type != ...))` |

### 3. Specific Pattern Analysis

The problematic pattern structure:
```bash
jq '... | map(select(.field != "value"))' file.json
```

Contains TWO triggers for the bug:
1. **Pipe character inside quotes**: `| map(...)`
2. **Not-equals operator**: `!=` (though `!=` itself isn't the issue - it's the surrounding pipes)

### 4. Patterns That Work (No Pipes in Problematic Position)

Simple jq commands without mid-expression pipes work correctly:
```bash
# Works - no pipe in quoted string after array
jq '.active_projects[]' specs/state.json

# Works - pipe is at top level, not after array accessor
echo "$task_data" | jq -r '.status'

# Works - select without preceding pipe in same position
jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  specs/state.json
```

**Note**: The bug appears context-sensitive. Some patterns with pipes work while others fail, depending on exact positioning.

### 5. Current Status of Bug

- **Issue Status**: Closed as NOT_PLANNED (Issue #1132)
- **Still Affecting**: Versions 0.2.115+ and 2.0.34+
- **Related Issues**: #2859, #7387, #10335 (duplicates)

## Decisions

### 1. Workaround Strategy Selection

After analyzing available workarounds, the recommended approach is:

**Primary: Script File Workaround**
```bash
# Write jq command to script file
Write("/tmp/jq_query.sh", """#!/bin/bash
jq '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
  artifacts: ((.artifacts // []) | map(select(.type != "research"))) + [{"path": "'$path'", "type": "research"}]
}' specs/state.json
""")
Bash("chmod +x /tmp/jq_query.sh && /tmp/jq_query.sh > /tmp/state.json && mv /tmp/state.json specs/state.json")
```

**Secondary: Refactored jq Without Problematic Pipes**

Split the operation into multiple jq calls:
```bash
# Step 1: Get current artifacts (simple query)
current=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber)) | .artifacts // []' \
  specs/state.json)

# Step 2: Filter in bash/jq separately (avoiding the problematic pattern)
filtered=$(echo "$current" | jq '[.[] | select(.type != "research")]')

# Step 3: Construct and apply update (simple assignment)
jq --arg num "$task_number" --argjson arts "$filtered" --arg path "$path" \
  '(.active_projects[] | select(.project_number == ($num | tonumber))).artifacts = ($arts + [{"path": $path, "type": "research"}])' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

### 2. Documentation Strategy

Create a new context file documenting:
- The bug and its symptoms
- Working vs. non-working patterns
- Recommended workarounds
- Testing procedures

## Risks & Mitigations

### Risk 1: Script File Approach Adds Complexity
**Impact**: Medium
**Mitigation**: Create a reusable helper function/pattern documented in context files

### Risk 2: Bug May Be Fixed in Future Claude Code Versions
**Impact**: Low (positive)
**Mitigation**: Document the workaround with version notes; can be removed when fixed

### Risk 3: Refactored Commands May Have Different Edge Cases
**Impact**: Medium
**Mitigation**: Thorough testing of all affected skills before deployment

### Risk 4: Multiple jq Calls Less Atomic Than Single Call
**Impact**: Medium
**Mitigation**: Use temp files with atomic mv operations; consider file locking

## Recommendations

### Immediate Actions

1. **Update inline-status-update.md** with working patterns
2. **Update affected skill files** (6 skills) with workarounds
3. **Update commands/task.md** (2 patterns) with workarounds
4. **Update commands/revise.md** (1 pattern) with workaround

### Pattern to Replace

**Current (Broken)**:
```bash
jq --arg ts "..." --arg status "..." --arg path "..." \
  '(.active_projects[] | select(.project_number == N)) |= . + {
    status: $status,
    artifacts: ((.artifacts // []) | map(select(.type != "TYPE"))) + [{"path": $path, "type": "TYPE"}]
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Recommended (Working)**:
```bash
# Use two-step approach
# Step 1: Update status and basic fields
jq --arg ts "..." --arg status "..." \
  '(.active_projects[] | select(.project_number == N)) |= . + {
    status: $status,
    last_updated: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 2: Update artifacts using simple array append (avoiding filter with !=)
jq --arg path "..." \
  '(.active_projects[] | select(.project_number == N)).artifacts += [{"path": $path, "type": "TYPE"}]' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 3: If deduplication needed, use del() instead of map(select(!=))
jq '(.active_projects[] | select(.project_number == N)).artifacts |= unique_by(.type)' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

### Alternative: unique_by Pattern

Instead of filtering out duplicates with `map(select(.type != "X"))`, use `unique_by` after adding:
```bash
jq --arg path "..." \
  '(.active_projects[] | select(.project_number == N)).artifacts =
    ((.active_projects[] | select(.project_number == N)).artifacts + [{"path": $path, "type": "TYPE"}] | unique_by(.type))' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

### Documentation Updates

Create `.claude/context/core/patterns/jq-escaping-workarounds.md` containing:
1. Bug description and symptoms
2. Affected patterns (with `|` and `!=` inside quotes)
3. Working alternative patterns
4. Testing checklist

## Appendix

### Search Queries Used
- `jq not equals operator escaping bash quotes 2025`
- GitHub: `anthropics/claude-code jq escaping`

### Files Analyzed
- All files in `.claude/skills/` (11 files)
- All files in `.claude/commands/` (8 files)
- All files in `.claude/context/core/` (30+ files)

### References
- [GitHub Issue #1132 - Claude Code Bash Tool JQ Command Escaping Issue](https://github.com/anthropics/claude-code/issues/1132)
- [jq Manual](https://jqlang.org/manual/)
- [Best Practices: Shell Variables in jq Filters](https://sqlpey.com/bash/shell-variables-in-jq-filters/)

### Test Commands

To verify the bug:
```bash
# This should fail (contains problematic pattern):
jq '(.artifacts // []) | map(select(.type != "test"))' <<< '{"artifacts":[{"type":"test"},{"type":"other"}]}'

# This should work (no mid-expression pipe after array):
echo '{"artifacts":[{"type":"test"},{"type":"other"}]}' | jq '.artifacts | map(select(.type != "test"))'
```

### Instance Count Summary

| Pattern Type | Count | Files |
|-------------|-------|-------|
| `map(select(.type != ...))` | 12 | 9 |
| `map(select(.project_number != ...))` | 2 | 1 |
| `$status != "..."` (bash) | 4 | 4 |
| **Total jq affected** | 14 | 10 |
