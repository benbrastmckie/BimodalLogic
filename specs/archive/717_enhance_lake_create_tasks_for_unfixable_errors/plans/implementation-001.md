# Implementation Plan: Task #717

**Task**: Enhance /lake to create tasks for unfixable errors
**Version**: 001
**Created**: 2026-01-28
**Language**: meta

## Overview

Add automatic task creation capability to the `/lake` command. When the build repair loop completes with unfixable errors remaining, the command will group errors by file, prompt the user for confirmation, and create one task per affected file with a linked error report artifact.

## Phases

### Phase 1: Add STEP 5 to lake.md

**Estimated effort**: 45 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add new STEP 5 section to handle task creation workflow
2. Implement error grouping by file
3. Add user confirmation via AskUserQuestion
4. Integrate with existing STEP 4 flow

**Files to modify**:
- `.claude/commands/lake.md` - Add STEP 5 after STEP 4

**Steps**:

1. **Modify STEP 4 ending** to check for unfixable errors:
   - Change "**Execution complete.**" to conditional continue
   - Add: "**If unfixable_errors exist and dry_run=false**: **IMMEDIATELY CONTINUE** to STEP 5."

2. **Add STEP 5 section** with three substeps:
   - 5A: Group Errors by File
   - 5B: Confirm with User (using AskUserQuestion)
   - 5C: Create Tasks and Reports

3. **Implement 5A: Group Errors by File**:
   ```
   file_groups = {}
   for each error in unfixable_errors:
       file = error.file
       if file not in file_groups:
           file_groups[file] = []
       file_groups[file].append(error)
   ```

4. **Implement 5B: Confirm with User**:
   - Display summary of proposed tasks
   - Use AskUserQuestion with options: "Yes, create tasks", "No, skip task creation"
   - If user declines, output message and stop

5. **Implement 5C: Create Tasks and Reports**:
   - For each file group, create task via jq pattern
   - Create error report artifact
   - Link artifact to task in state.json
   - Update TODO.md with task entry

**Verification**:
- Read modified lake.md and verify STEP 5 structure
- Verify conditional flow from STEP 4 to STEP 5

---

### Phase 2: Add detailed task creation logic to skill-lake-repair/SKILL.md

**Estimated effort**: 45 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add Step 13 for task creation workflow
2. Define error report artifact format
3. Add jq commands for state.json updates
4. Add Edit instructions for TODO.md updates

**Files to modify**:
- `.claude/skills/skill-lake-repair/SKILL.md` - Add Step 13

**Steps**:

1. **Add Step 13: Create Tasks for Unfixable Errors**:
   - Reference the STEP 5 in lake.md for high-level flow
   - Provide detailed implementation guidance

2. **Define error report format**:
   ```markdown
   # Build Error Report: Task #{N}

   **Generated**: {ISO_DATE}
   **Source file**: {file_path}
   **Error count**: {N} errors

   ## Errors

   ### Error 1: Line {line}
   **Type**: {error_type}
   **Column**: {column}
   **Message**:
   ```
   {full error message}
   ```

   ## Suggested Approach

   {Brief analysis based on error patterns}
   ```

3. **Add task creation jq pattern**:
   ```bash
   next_num=$(jq -r '.next_project_number' specs/state.json)
   slug="fix_build_errors_$(basename "$file" .lean | tr '[:upper:]' '[:lower:]')"

   jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     --arg desc "Fix $error_count build errors in $file" \
     --arg slug "$slug" \
     --arg source "$file" \
     '.next_project_number = ($next_num + 1) |
      .active_projects = [{
        "project_number": '$next_num',
        "project_name": $slug,
        "status": "not_started",
        "language": "lean",
        "priority": "high",
        "source": $source,
        "created": $ts,
        "last_updated": $ts,
        "artifacts": [{
          "type": "error_report",
          "path": "specs/'$next_num'_" + $slug + "/reports/error-report-{DATE}.md",
          "summary": "Build error report with " + ($error_count | tostring) + " errors"
        }]
      }] + .active_projects' \
     specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   ```

4. **Add TODO.md update pattern**:
   - Find "## High Priority" section
   - Insert new task entry after header
   - Include Source field and error summary in description

**Verification**:
- Verify jq commands are syntactically correct
- Verify TODO.md format matches existing entries

---

### Phase 3: Add error report artifact format to artifact-formats.md

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Document the new error report artifact type
2. Add to the Artifact Format Rules file

**Files to modify**:
- `.claude/rules/artifact-formats.md` - Add Error Reports section

**Steps**:

1. **Add new section after Implementation Summaries**:
   ```markdown
   ## Error Reports

   **Location**: `specs/{N}_{SLUG}/reports/error-report-{DATE}.md`

   ```markdown
   # Build Error Report: Task #{N}

   **Generated**: {ISO_DATE}
   **Source file**: {file_path}
   **Error count**: {N} errors

   ## Errors

   ### Error 1: Line {line}
   **Type**: {error_type}
   **Column**: {column}
   **Message**:
   ```
   {full error message}
   ```

   ## Suggested Approach

   {Brief analysis of error pattern and potential fix approach}
   ```
   ```

**Verification**:
- Verify section is added in correct location
- Verify format matches other artifact sections

---

### Phase 4: Verification and testing

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Review all changes for consistency
2. Test with a simulated build error scenario
3. Verify task creation and artifact linking work correctly

**Steps**:

1. **Review consistency**:
   - Verify lake.md STEP 5 references skill correctly
   - Verify skill has all required details
   - Verify artifact format is documented

2. **Manual testing** (if build errors exist):
   - Run `/lake` with actual build errors
   - Verify confirmation prompt appears
   - Verify tasks are created with correct format
   - Verify error reports are generated
   - Verify artifacts are linked in state.json

3. **Edge case verification**:
   - Verify behavior when no unfixable errors (should skip STEP 5)
   - Verify behavior when user declines (should stop gracefully)
   - Verify dry-run mode skips task creation

**Verification**:
- All files modified are internally consistent
- Integration between lake.md and SKILL.md is correct

---

## Dependencies

- Task 715 (completed): /lake command now has execution directives that this builds upon

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| jq command complexity | Medium | Use proven patterns from /task command |
| TODO.md format inconsistency | Low | Match exact format of existing entries |
| AskUserQuestion integration | Low | Follow existing /meta pattern |
| Multiple concurrent tasks | Medium | Create sequentially with proper state updates |

## Success Criteria

- [ ] STEP 5 added to lake.md with clear execution directives
- [ ] Error grouping by file works correctly
- [ ] User confirmation prompt appears before task creation
- [ ] Tasks created with proper format (state.json + TODO.md)
- [ ] Error report artifacts generated and linked
- [ ] Graceful handling when user declines
- [ ] Dry-run mode skips task creation
