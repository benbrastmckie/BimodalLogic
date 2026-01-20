# Research Report: Task #642

**Task**: 642 - meta_tasks_update_claudemd_not_roadmap
**Title**: Meta tasks should suggest CLAUDE.md updates instead of ROAD_MAP.md
**Started**: 2026-01-20T19:16:00Z
**Completed**: 2026-01-20T19:45:00Z
**Effort**: 30 minutes
**Priority**: medium
**Dependencies**: Task 641 (roadmap improvement) - completed
**Sources/Inputs**: Codebase analysis, /todo command spec, /implement command spec, CLAUDE.md structure
**Artifacts**: specs/642_meta_tasks_update_claudemd_not_roadmap/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- The /todo command currently updates ROAD_MAP.md for ALL completed tasks regardless of language
- Meta tasks (system/agent improvements) should update CLAUDE.md instead of ROAD_MAP.md
- Implementation requires language-based filtering in /todo command (Step 3.5 and Step 5.5)
- CLAUDE.md should have a "Recent System Changes" section to track meta task completions without bloating

## Context & Scope

### Problem Statement

When meta tasks (language: "meta") are completed and /todo runs, the command:
1. Extracts `completion_summary` and `roadmap_items` from state.json
2. Searches ROAD_MAP.md for matching items
3. Annotates them with completion dates

This is incorrect for meta tasks because:
- Meta tasks improve the Claude Code system itself (.claude/ directory)
- ROAD_MAP.md tracks project deliverables (Lean proofs, LaTeX docs)
- System improvements should be tracked in CLAUDE.md (project configuration)

### Research Questions

1. Where does /todo handle ROAD_MAP.md updates?
2. Is there existing language-based filtering for task handling?
3. How should meta task summaries be added to CLAUDE.md without bloating?
4. What fields need to support this new behavior?

## Findings

### 1. /todo Command ROAD_MAP.md Update Logic

**Location**: `.claude/commands/todo.md` at Step 3.5 and Step 5.5

**Step 3.5** (lines 135-220) - Scans for task references:
- Extracts completed tasks with `completion_summary` and `roadmap_items`
- Uses three-priority matching: explicit roadmap_items, exact (Task N) references, summary-based
- **No language filtering exists** - all completed tasks are checked against ROAD_MAP.md

**Step 5.5** (lines 482-556) - Updates ROAD_MAP.md:
- For each match from Step 3.5, applies annotations
- Converts `- [ ]` to `- [x]` with completion date
- **No language filtering exists** - all matches get annotated

### 2. No Existing Language-Based Filtering

Searched the entire .claude/ directory for language-based filtering patterns:
- Language is used for **routing** (which skill handles the task)
- Language is **not** used for post-completion handling differences
- The /todo command does not reference the `language` field at all

### 3. CLAUDE.md Structure Analysis

**Current Structure** (415 lines):
- Quick Reference
- System Overview
- Task Management
- Checkpoint-Based Execution Model
- Command Workflows
- State Synchronization
- Git Commit Conventions
- Lean 4 Integration
- Rules References
- Project Context Imports
- Error Handling
- Session Patterns
- Skill Architecture
- Session Maintenance
- Important Notes

**Observation**: CLAUDE.md is comprehensive but lacks a section for tracking system changes over time.

**Recommendation**: Add a "Recent System Changes" section at the end (before "Important Notes") with:
- Rolling log of recent meta task completions (last 5-10)
- One-line summaries with task number and date
- Automated pruning of old entries to prevent bloating

### 4. State Schema - claudemd_items Field

Following the pattern from Task 641 which added `roadmap_items`, we should add:

| Field | Type | Description |
|-------|------|-------------|
| `claudemd_items` | array of strings | Optional explicit CLAUDE.md items this meta task addresses |

This parallels `roadmap_items` for ROAD_MAP.md and enables explicit matching.

### 5. Modification Points Identified

**File: `.claude/commands/todo.md`**

1. **Step 3.5** - Add language filtering to exclude meta tasks from roadmap scanning:
   ```bash
   # Skip meta tasks - they update CLAUDE.md, not ROAD_MAP.md
   task_language=$(echo "$task" | jq -r '.language // "general"')
   if [ "$task_language" = "meta" ]; then
     meta_tasks+=("$task")
     continue
   fi
   ```

2. **New Step 3.6** - Scan for CLAUDE.md updates from meta tasks:
   - Extract meta tasks from Step 3.5
   - Use `claudemd_items` field for explicit matching
   - Build list of CLAUDE.md updates

3. **Step 5.5** - After roadmap updates, handle CLAUDE.md updates

4. **New Step 5.6** - Update CLAUDE.md "Recent System Changes" section:
   - Add new entries at top of section
   - Prune old entries (keep last 10)
   - Format: `- [{DATE}] Task #{N}: {completion_summary}`

**File: `.claude/commands/implement.md`**

5. **Step 4** (GATE OUT) - Add `claudemd_items` population for meta tasks:
   - Check if task language is "meta"
   - If so, prompt for or auto-generate `claudemd_items`
   - Store in state.json alongside `completion_summary`

**File: `.claude/CLAUDE.md`**

6. **Add "Recent System Changes" section**:
   ```markdown
   ## Recent System Changes

   Recent improvements to the Claude Code system:

   - [2026-01-20] Task #641: Implemented structured synchronization for roadmap updates
   - [2026-01-20] Task #640: Added /refresh command for session cleanup
   ```

**File: `.claude/rules/state-management.md`**

7. **Document claudemd_items field**:
   - Add to Completion Fields Schema table
   - Add usage notes

## Decisions

1. **Use parallel structure to roadmap_items**: The `claudemd_items` field mirrors `roadmap_items` for consistency
2. **Add "Recent System Changes" section**: Keeps meta task history visible without bloating main sections
3. **Rolling log with pruning**: Last 10 entries prevents unbounded growth
4. **One-line format**: `- [{DATE}] Task #{N}: {summary}` is concise yet informative

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| CLAUDE.md bloat | Medium | Rolling log with max 10 entries, automatic pruning |
| Missing meta tasks | Low | Explicit filtering ensures no meta tasks slip through to ROAD_MAP.md |
| Complex implementation | Medium | Parallel structure to existing roadmap logic minimizes new patterns |
| Backward compatibility | Low | New fields are optional; existing tasks unaffected |

## Implementation Recommendations

### Phase 1: Add claudemd_items Schema
1. Update state-management.md with `claudemd_items` field
2. Update state.json schema documentation

### Phase 2: Add CLAUDE.md Section
1. Add "Recent System Changes" section to CLAUDE.md template
2. Define format: `- [{DATE}] Task #{N}: {summary}`

### Phase 3: Update /todo Command
1. Add language filtering in Step 3.5 to exclude meta tasks
2. Add new Step 3.6 for CLAUDE.md scanning from meta tasks
3. Add new Step 5.6 for CLAUDE.md updates with rolling log logic
4. Update dry-run output to show CLAUDE.md updates separately

### Phase 4: Update /implement Command
1. Add conditional population of `claudemd_items` for meta tasks in GATE OUT
2. Add TODO.md "Summary" line handling for meta tasks

### Phase 5: Documentation
1. Update CLAUDE.md "Completion Summary Workflow" section
2. Add meta task handling notes to relevant sections

## Appendix

### Search Queries Used

1. `Glob **/*todo*` - Found /todo command location
2. `Grep ROAD_MAP .claude` - Found all ROAD_MAP.md references
3. `Grep language.*meta .claude` - Found language-based routing patterns
4. `Grep completion_summary .claude` - Found schema and usage patterns

### Key Files Referenced

- `.claude/commands/todo.md` - Main /todo command (756 lines)
- `.claude/commands/implement.md` - /implement command with completion_summary
- `.claude/CLAUDE.md` - Project configuration (415 lines)
- `.claude/rules/state-management.md` - State schema definitions
- `.claude/context/core/patterns/roadmap-update.md` - Roadmap update patterns

### Related Tasks

- Task 641: Improved /todo roadmap updates with structured synchronization (completed)
- Task 639: Improve /review roadmap matching (not started)
