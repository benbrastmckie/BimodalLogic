# Implementation Plan: Improve /todo Command with Interactive CLAUDE.md Suggestions

- **Task**: 645 - improve_todo_command_interactive_claudemd
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/645_improve_todo_command_interactive_claudemd/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan addresses two issues in the /todo command: (1) jq syntax errors from `!=` operators due to Claude Code Issue #1132, and (2) manual CLAUDE.md suggestion handling. The solution applies two-step jq patterns for all problematic filters and adds interactive AskUserQuestion selection for CLAUDE.md modifications with auto-application via Edit tool.

### Research Integration

- Integrated research-001.md findings on jq two-step patterns and AskUserQuestion multiSelect usage
- Specific jq pattern replacements identified for Steps 3.5.2, 3.5.3, 3.6.1, and 5

## Goals & Non-Goals

**Goals**:
- Fix all jq syntax errors by applying two-step patterns or has()/del() alternatives
- Add interactive selection for CLAUDE.md suggestions using AskUserQuestion with multiSelect
- Auto-apply selected suggestions via Edit tool
- Preserve manual fallback option for users who prefer review

**Non-Goals**:
- Changing the overall /todo workflow structure
- Adding new features beyond jq fixes and interactive selection
- Modifying ROAD_MAP.md handling (already working correctly)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Edit tool fails for CLAUDE.md updates | Medium | Low | Preserve manual fallback; display suggestions even if edit fails |
| Section matching fails for ADD action | Medium | Low | Use unique anchor text; validate section exists before edit |
| Two-step jq patterns create temp file conflicts | Low | Low | Use unique filenames with PID or timestamp |
| User selects conflicting suggestions | Low | Low | Apply in order; later edits may fail if content changed |

## Implementation Phases

### Phase 1: Fix jq Syntax Errors [COMPLETED]

**Goal**: Replace all problematic jq patterns with Issue #1132-safe alternatives

**Tasks**:
- [ ] Update Step 3.5.2 (non-meta task filter) to use file-based jq filter for `language != "meta"`
- [ ] Update Step 3.5.3 (roadmap matching) if any `!=` patterns exist
- [ ] Update Step 3.6.1 (claudemd_suggestions check) to use `has("claudemd_suggestions")` instead of `!= null`
- [ ] Update Step 5B (archive removal) to use `del()` pattern instead of `map(select(.status != "completed"))`
- [ ] Test each pattern replacement individually

**Timing**: 45 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Steps 3.5.2, 3.5.3, 3.6.1, 5B

**Verification**:
- All jq commands use safe patterns (no bare `!=` operators)
- Commands use either: file-based filters, `has()` for null checks, or `del()` for exclusion

**Pattern Replacements**:

1. Step 3.5.2 - Non-meta filter:
```bash
# Before:
jq -r '.active_projects[] | select(.status == "completed") | select(.language != "meta")'

# After (file filter):
cat > /tmp/todo_filter_$$.jq << 'EOF'
.active_projects[] | select(.status == "completed") | select(.language != "meta")
EOF
jq -f /tmp/todo_filter_$$.jq specs/state.json && rm -f /tmp/todo_filter_$$.jq
```

2. Step 3.6.1 - Claudemd suggestions check:
```bash
# Before:
select(.claudemd_suggestions != null)

# After:
select(has("claudemd_suggestions"))
```

3. Step 5B - Remove completed from active:
```bash
# Before:
jq '.active_projects |= map(select(.status != "completed"))'

# After (del approach):
jq 'del(.active_projects[] | select(.status == "completed"))'
```

---

### Phase 2: Add Interactive CLAUDE.md Selection [COMPLETED]

**Goal**: Add AskUserQuestion for interactive suggestion selection with auto-apply via Edit

**Tasks**:
- [ ] Add Step 5.6.2: Build AskUserQuestion options from claudemd_suggestions array
- [ ] Add Step 5.6.3: Process user selection and apply via Edit tool
- [ ] Add Step 5.6.4: Display results of applied changes
- [ ] Handle edge cases: no suggestions, all skipped, edit failures

**Timing**: 45 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Steps 5.6.2, 5.6.3, 5.6.4

**Verification**:
- AskUserQuestion prompts user with suggestion list
- Selected suggestions are applied via Edit tool
- "Skip all" option preserves manual fallback behavior
- Results are displayed showing what was applied

**New Step Structure**:

Step 5.6.2 - Interactive Selection:
```
If claudemd_suggestions array has any with action != "none":

  AskUserQuestion:
    question: "Found {N} CLAUDE.md suggestions from meta tasks. Which should be applied?"
    header: "CLAUDE.md Updates"
    multiSelect: true
    options:
      - label: "Task #{N1}: {ACTION} to {section}"
        description: "{rationale}"
      - label: "Task #{N2}: {ACTION} to {section}"
        description: "{rationale}"
      - label: "Skip all"
        description: "Don't apply any suggestions (display only)"
```

Step 5.6.3 - Apply Selected:
```
For each selected suggestion (excluding "Skip all"):
  1. Read current .claude/CLAUDE.md
  2. Apply Edit based on action:
     - ADD: Edit section header, append content after it
     - UPDATE: Edit old_string=removes, new_string=content
     - REMOVE: Edit old_string=removes, new_string=""
  3. Track success/failure for each edit
```

Step 5.6.4 - Display Results:
```
Applied {N} CLAUDE.md suggestions:
- Task #{N1}: Added {section}
- Task #{N2}: Updated {section}

{If any failed:}
Failed to apply {N} suggestions:
- Task #{N3}: Section not found for {section}
```

---

### Phase 3: Update Documentation and Output [COMPLETED]

**Goal**: Update dry-run output, final output, and Notes section for new behavior

**Tasks**:
- [ ] Update Step 4 (dry-run output) to show interactive mode will be used
- [ ] Update Step 7 (final output) to show applied vs skipped suggestions
- [ ] Update Notes section to document interactive CLAUDE.md application
- [ ] Add note about jq two-step pattern usage

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Steps 4, 7, Notes section

**Verification**:
- Dry-run output mentions interactive selection will occur
- Final output shows which suggestions were applied/skipped
- Notes section documents the interactive behavior

**Output Updates**:

Dry-run addition:
```
CLAUDE.md suggestions (from meta tasks):
{existing content}

Note: Interactive selection will prompt for which suggestions to apply.
```

Final output update:
```
CLAUDE.md suggestions applied: {N}
- Task #{N1}: Added {section}
- Task #{N2}: Updated {section}

CLAUDE.md suggestions skipped: {N}
- Task #{N3}: Skipped by user
- Task #{N4}: No changes needed

{Remove "apply manually" note when suggestions were applied}
```

## Testing & Validation

- [ ] Run `/todo --dry-run` with meta tasks having claudemd_suggestions
- [ ] Verify no jq syntax errors occur during execution
- [ ] Verify AskUserQuestion prompts appear for actionable suggestions
- [ ] Verify selected suggestions are applied via Edit
- [ ] Verify "Skip all" option works correctly
- [ ] Verify output reflects applied vs skipped suggestions

## Artifacts & Outputs

- `.claude/commands/todo.md` - Updated command specification
- `specs/645_improve_todo_command_interactive_claudemd/plans/implementation-001.md` (this file)
- `specs/645_improve_todo_command_interactive_claudemd/summaries/implementation-summary-{DATE}.md` (on completion)

## Rollback/Contingency

If implementation causes issues:
1. Revert todo.md to previous version via git: `git checkout HEAD~1 .claude/commands/todo.md`
2. Fallback to manual CLAUDE.md editing (original behavior)
3. Report jq issues to errors.json with specific filter that failed
