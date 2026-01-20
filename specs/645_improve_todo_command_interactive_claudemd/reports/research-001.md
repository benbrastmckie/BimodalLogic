# Research Report: Task #645

- **Task**: 645 - Improve /todo command with interactive CLAUDE.md suggestions
- **Started**: 2026-01-20T12:30:00Z
- **Completed**: 2026-01-20T13:00:00Z
- **Effort**: 2-4 hours
- **Priority**: High
- **Dependencies**: None
- **Sources/Inputs**:
  - `.claude/output/todo.md` - Execution log showing jq errors and CLAUDE.md suggestions display
  - `.claude/commands/todo.md` - Current /todo command specification
  - `.claude/context/core/patterns/jq-escaping-workarounds.md` - Two-step jq patterns
  - `.claude/skills/skill-refresh/SKILL.md` - AskUserQuestion interactive selection pattern
  - `specs/644_redesign_learn_interactive_task_selection/reports/research-001.md` - AskUserQuestion multiSelect research
- **Artifacts**:
  - `specs/645_improve_todo_command_interactive_claudemd/reports/research-001.md` (this file)
- **Standards**: report-format.md, artifact-formats.md

## Executive Summary

- The /todo command has two issues: (1) jq syntax errors from `!=` operators due to Claude Code Issue #1132, and (2) CLAUDE.md suggestions displayed for manual review but no interactive selection
- The todo.md output shows jq parse error at line 114-120 where `select(.claudemd_suggestions != null)` triggers INVALID_CHARACTER error
- Two-step jq patterns from jq-escaping-workarounds.md should be applied to all jq commands using `!=` comparisons
- AskUserQuestion with multiSelect should be added to let users select which CLAUDE.md suggestions to auto-apply
- The /todo command already has AskUserQuestion in allowed-tools (used for orphan/misplaced directory handling)

## Context & Scope

**Problem Statement**: Two issues observed in recent /todo execution:

1. **jq Syntax Errors**: Commands like `select(.claudemd_suggestions != null)` fail with:
   ```
   jq: error: syntax error, unexpected INVALID_CHARACTER, expecting ';' or ')' at <top-level>
   ```
   This is Claude Code Issue #1132 - the Bash tool corrupts jq filters containing `!=` in certain contexts.

2. **Manual CLAUDE.md Suggestions**: The command displays suggestions with "apply manually" instructions instead of offering interactive selection and auto-application.

**Scope**: Update todo.md to:
- Convert all problematic jq patterns to two-step approach
- Add AskUserQuestion for CLAUDE.md suggestion selection
- Auto-apply selected suggestions via Edit tool

## Findings

### 1. jq Syntax Errors in /todo Execution

From the todo.md output log (lines 108-121):

```
● Bash(# Get claudemd_suggestions for meta tasks
      jq -r '.active_projects[] | select(.status == "completed") |
      select(.language == "meta") | select(.claudemd_suggestions \!= null) |
      ...
  ⎿  Error: Exit code 3
     jq: error: syntax error, unexpected INVALID_CHARACTER, expecting ';' or
     ')' at <top-level>, line 1, column 114:
```

The workaround in the log used `has()` instead of `!= null`:
```bash
jq -r '.active_projects[] | select(.status == "completed") | select(.language == "meta") | select(has("claudemd_suggestions"))'
```

A later error at lines 183-188 shows another `!=` failure:
```
jq '.active_projects |= map(select(.status != "completed"))'
```

The workaround used a filter file approach (two-step pattern).

### 2. All Problematic jq Patterns in todo.md

Analyzing the current `/todo` command specification, these patterns need updating:

| Location | Current Pattern | Issue |
|----------|----------------|-------|
| Step 3.5.2 | `select(.status == "completed")` followed by `select(.language != "meta")` | `!=` triggers Issue #1132 |
| Step 3.5.3 | `select(.type != "research")` in roadmap matching | `!=` triggers Issue #1132 |
| Step 3.6.1 | `select(.claudemd_suggestions != null)` | `!=` triggers Issue #1132 |
| Step 5 | `.active_projects |= map(select(.status != "completed"))` | `!=` triggers Issue #1132 |

### 3. Two-Step jq Workaround Patterns

From `.claude/context/core/patterns/jq-escaping-workarounds.md`:

**Recommended pattern** (file-based filter):
```bash
# Step 1: Write filter to file
cat > /tmp/filter.jq << 'EOF'
.active_projects |= map(select(.status != "completed"))
EOF

# Step 2: Apply filter
jq -f /tmp/filter.jq specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Alternative pattern** (del() instead of select-not):
```bash
# Use del() to remove instead of select(!= )
jq 'del(.active_projects[] | select(.status == "completed"))' specs/state.json
```

**has() for null checks**:
```bash
# Instead of: select(.field != null)
# Use: select(has("field")) or select(.field != null | not)
jq '.active_projects[] | select(has("claudemd_suggestions"))' specs/state.json
```

### 4. Current CLAUDE.md Suggestions Flow

From todo.md Step 5.6:

```
CLAUDE.md Suggestions (Meta Tasks):
══════════════════════════════════════════════════════════════════════════════

Task #{N} ({project_name}):
  Action: ADD
  Section: Command Workflows
  Rationale: New /learn command needs user documentation

  Suggested content to add:
  ┌────────────────────────────────────────────────────────────────────────────
  │ ### /learn - Scan for tags...
  └────────────────────────────────────────────────────────────────────────────

══════════════════════════════════════════════════════════════════════════════

Note: Review the suggestion above and apply manually to .claude/CLAUDE.md
```

**Current behavior**:
- Suggestions are displayed with formatted boxes
- User is told to "apply manually"
- No interactive selection
- No auto-application

### 5. AskUserQuestion Pattern for Interactive Selection

From `/todo` command spec (orphan handling at Step 4.5):

```
AskUserQuestion:
  question: "Found {N} orphaned project directories not tracked in state files. What would you like to do?"
  header: "Orphans"
  options:
    - label: "Track all orphans"
      description: "Move specs/ orphans to archive/ and add state entries for all orphans"
    - label: "Skip orphans"
      description: "Only archive tracked completed/abandoned tasks"
    - label: "Review list first"
      description: "Show the full list of orphaned directories"
  multiSelect: false
```

From skill-refresh (Step 4 - age threshold selection):

```json
{
  "question": "Select cleanup age threshold:",
  "header": "Age Threshold",
  "multiSelect": false,
  "options": [
    {"label": "8 hours (default)", "description": "Remove files older than 8 hours"},
    {"label": "2 days", "description": "Remove files older than 2 days"},
    {"label": "Clean slate", "description": "Remove everything except safety margin (1 hour)"}
  ]
}
```

### 6. Proposed Interactive CLAUDE.md Flow

**New Step 5.6: Interactive CLAUDE.md Suggestions**

```
Step 5.6.1: Collect actionable suggestions (existing logic)

Step 5.6.2: If any actionable suggestions (action != "none"):

  AskUserQuestion:
    question: "Found {N} CLAUDE.md suggestions from meta tasks. Which should be applied?"
    header: "CLAUDE.md Updates"
    multiSelect: true
    options:
      - label: "Task #643: ADD to Command Workflows"
        description: "Add /learn command documentation"
      - label: "Task #642: UPDATE in Session Maintenance"
        description: "Update default threshold text"
      - label: "Skip all"
        description: "Don't apply any suggestions (display only)"

Step 5.6.3: For each selected suggestion:
  - Read current .claude/CLAUDE.md
  - Apply Edit based on action type:
    - ADD: Append content to target section
    - UPDATE: Edit old_string=removes, new_string=content
    - REMOVE: Edit old_string=removes, new_string=""

Step 5.6.4: Display results:
  "Applied {N} CLAUDE.md suggestions:
   - Task #643: Added /learn documentation to Command Workflows
   - Task #642: Updated Session Maintenance threshold text"

Step 5.6.5: For "none" suggestions and skipped items, display acknowledgment only
```

### 7. Edit Tool for Auto-Application

The Edit tool can be used to apply suggestions:

**For ADD actions**:
```
Edit:
  file_path: .claude/CLAUDE.md
  old_string: "## {target_section}\n\n"
  new_string: "## {target_section}\n\n{content}\n\n"
```

**For UPDATE actions**:
```
Edit:
  file_path: .claude/CLAUDE.md
  old_string: "{removes}"
  new_string: "{content}"
```

**For REMOVE actions**:
```
Edit:
  file_path: .claude/CLAUDE.md
  old_string: "{removes}"
  new_string: ""
```

**Note**: The todo.md command already has Edit in allowed-tools.

## Decisions

1. **Use two-step jq pattern**: Write filters to /tmp/*.jq files, then apply with `jq -f`
2. **Use has() for null checks**: Replace `!= null` with `has("field")`
3. **Use del() for exclusion**: Replace `map(select(.status != "X"))` with `del(.[] | select(.status == "X"))`
4. **Add interactive CLAUDE.md selection**: Use AskUserQuestion with multiSelect: true
5. **Auto-apply selected suggestions**: Use Edit tool after user selection
6. **Preserve manual fallback**: Include "Skip all" option for users who prefer manual review

## Recommendations

### Implementation Phases

**Phase 1: Fix jq Syntax Errors** (30 min)
1. Update Step 3.5.2 to use two-step pattern or has()
2. Update Step 3.5.3 to use two-step pattern
3. Update Step 3.6.1 to use has() for null check
4. Update Step 5 (archive removal) to use del() or two-step pattern
5. Test each pattern in isolation

**Phase 2: Add Interactive CLAUDE.md Selection** (45 min)
1. Add Step 5.6.2 with AskUserQuestion for suggestion selection
2. Add Step 5.6.3 for applying selected suggestions via Edit
3. Update Step 5.6.4 for displaying results
4. Handle edge cases (no suggestions, all skipped)

**Phase 3: Update Documentation** (15 min)
1. Update output examples in Step 4 (dry-run) and Step 7 (final output)
2. Add notes about interactive mode
3. Update Notes section to document CLAUDE.md auto-application

### Files to Modify

| File | Changes |
|------|---------|
| `.claude/commands/todo.md` | Fix jq patterns, add interactive CLAUDE.md selection |

### Specific jq Pattern Updates

**Step 3.5.2 - Non-meta tasks filter**:
```bash
# Before:
jq -r '.active_projects[] | select(.status == "completed") | select(.language != "meta")'

# After (use file filter):
cat > /tmp/filter.jq << 'EOF'
.active_projects[] | select(.status == "completed") | select(.language != "meta")
EOF
jq -f /tmp/filter.jq specs/state.json
```

**Step 3.6.1 - Claudemd suggestions check**:
```bash
# Before:
select(.claudemd_suggestions != null)

# After:
select(has("claudemd_suggestions"))
```

**Step 5 - Remove completed from active**:
```bash
# Before:
jq '.active_projects |= map(select(.status != "completed"))'

# After (del approach):
jq 'del(.active_projects[] | select(.status == "completed"))'

# Or (file filter approach):
cat > /tmp/filter.jq << 'EOF'
.active_projects |= map(select(.status != "completed"))
EOF
jq -f /tmp/filter.jq specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Edit tool fails for CLAUDE.md updates | Medium | Preserve manual fallback; display suggestions even if edit fails |
| Section matching fails for ADD | Medium | Use unique anchor text; validate section exists before edit |
| User selects conflicting suggestions | Low | Apply in order; later edits may fail if content changed |
| Large number of suggestions | Low | Limit to 10 options; offer "Apply all" for >10 |

## Appendix

### jq Error Pattern Reference

From Claude Code Issue #1132, these patterns trigger the bug:
- `!=` comparisons in certain contexts
- Pipe `|` after array accessor in certain positions
- `!= null` for null checks

Workarounds:
- Use `has()` for null checks
- Use `del()` instead of `select(!= )`
- Use file-based filters (`jq -f /tmp/filter.jq`)
- Use two-step approach (write filter, then apply)

### AskUserQuestion Reference

```typescript
AskUserQuestion({
  question: string,      // Main question text
  header?: string,       // Optional header/title
  multiSelect?: boolean, // true for checkbox, false for radio (default)
  options: Array<{
    label: string,       // Option text
    description?: string // Optional description
  }>
})
```

Returns: string (single-select) or string[] (multi-select)

### References

- Claude Code Issue #1132: https://github.com/anthropics/claude-code/issues/1132
- `.claude/context/core/patterns/jq-escaping-workarounds.md` - Full workaround documentation
- `.claude/skills/skill-refresh/SKILL.md` - AskUserQuestion usage example
- `specs/644_redesign_learn_interactive_task_selection/reports/research-001.md` - multiSelect patterns
