# Implementation Plan: Create /sync command for bidirectional TODO.md and state.json synchronization (Revised)

- **Task**: 296 - Create /sync command for bidirectional TODO.md and state.json synchronization
- **Status**: [NOT STARTED]
- **Effort**: 8-10 hours (increased from 6-8 due to git blame complexity)
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/state-management.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false
- **Revision**: 2 (replaces implementation-001.md)
- **Revision Date**: 2026-01-05
- **Revision Reason**: Replace file mtime comparison with git blame line-level timestamps for true per-field conflict resolution

## Overview

Create a /sync command that bidirectionally synchronizes .opencode/specs/TODO.md and .opencode/specs/state.json using **git blame line-level timestamps** for intelligent per-field conflict resolution. Unlike the previous plan which used coarse-grained file modification times, this approach examines the git history of each specific field (status, description, priority, etc.) to determine which file has the most recent change to that field. This prevents irrelevant changes to other parts of the file from incorrectly marking the entire file as "newer" and enables true bidirectional synchronization with field-level granularity.

**Key Innovation**: Use `git blame` to get the commit timestamp for each line containing task metadata, then resolve conflicts field-by-field based on which file's line was modified most recently. This provides surgical precision in conflict resolution.

## Goals & Non-Goals

**Goals**:
- Detect discrepancies between TODO.md and state.json task entries at field level
- Use git blame to determine line-level timestamps for each metadata field
- Resolve conflicts field-by-field by preferring most recently modified field
- Perform atomic bidirectional synchronization using status-sync-manager
- Handle edge cases: tasks in one file but not the other, status mismatches, metadata differences
- Provide clear reporting of changes made during synchronization with git timestamps
- Support dry-run mode (--dry-run flag) to preview changes without applying them
- Regenerate TODO.md YAML header from state.json metadata
- Enable true bidirectional sync (not just state.json → TODO.md)

**Non-Goals**:
- Synchronize plan files or other artifacts (only TODO.md and state.json)
- Perform automatic synchronization on every command (manual invocation only)
- Resolve conflicts through user prompts (automated resolution based on git blame timestamps)
- Synchronize archived tasks (only active_projects in state.json)
- Handle files not tracked in git (requires git history for timestamps)

## Risks & Mitigations

- **Risk**: Git blame may fail for newly created files or uncommitted changes. **Mitigation**: Fall back to file mtime for uncommitted changes, warn user to commit changes before sync.
- **Risk**: Complex git blame parsing may have bugs. **Mitigation**: Implement comprehensive validation, test with various git history scenarios, add extensive logging.
- **Risk**: Performance issues with large git history. **Mitigation**: Use `git blame --line-porcelain` for efficient parsing, cache blame results per file.
- **Risk**: Conflicting changes in both files to same field simultaneously. **Mitigation**: Use commit timestamps to determine authoritative source, document conflict resolution strategy clearly.
- **Risk**: Malformed TODO.md or state.json causing sync failures. **Mitigation**: Validate file formats before synchronization, provide clear error messages with recovery steps.

## Implementation Phases

### Phase 1: Design Git Blame-Based Synchronization Algorithm [NOT STARTED]

- **Goal**: Define the git blame-based synchronization algorithm and per-field conflict resolution strategy
- **Tasks**:
  - [ ] Document git blame-based synchronization algorithm (detect, blame, compare, resolve, apply)
  - [ ] Define per-field conflict resolution rules (git blame timestamp-based)
  - [ ] Design data structures for tracking field-level discrepancies with timestamps
  - [ ] Define git blame parsing strategy (--line-porcelain format)
  - [ ] Define edge cases and handling strategies (uncommitted changes, new files, merge commits)
  - [ ] Document dry-run mode behavior
  - [ ] Create algorithm pseudocode with git blame integration
  - [ ] Document fallback strategy for uncommitted changes
- **Timing**: 2 hours

### Phase 2: Implement Git Blame Timestamp Extraction [NOT STARTED]

- **Goal**: Create utility functions to extract line-level timestamps using git blame
- **Tasks**:
  - [ ] Implement `get_line_timestamp()` function using `git blame --line-porcelain`
  - [ ] Parse git blame output to extract commit timestamp for specific line
  - [ ] Implement caching mechanism for git blame results (avoid redundant calls)
  - [ ] Handle edge cases: uncommitted changes (use file mtime), new files (use creation time)
  - [ ] Implement cross-platform timestamp parsing (Unix epoch seconds)
  - [ ] Add error handling for git blame failures (not a git repo, file not tracked)
  - [ ] Create test cases for git blame parsing
  - [ ] Optimize performance with `--line-porcelain` format
- **Timing**: 2 hours

### Phase 3: Implement Field-Level Discrepancy Detection [NOT STARTED]

- **Goal**: Detect differences between TODO.md and state.json at field level with git blame timestamps
- **Tasks**:
  - [ ] Parse TODO.md to extract all task entries with line numbers
  - [ ] Parse state.json active_projects array with field locations
  - [ ] For each task, extract git blame timestamp for each metadata field:
    - [ ] Status field (TODO.md: `**Status**: [...]`, state.json: `"status": "..."`)
    - [ ] Priority field (TODO.md: `**Priority**: ...`, state.json: `"priority": "..."`)
    - [ ] Effort field (TODO.md: `**Effort**: ...`, state.json: `"effort": ...`)
    - [ ] Language field (TODO.md: `**Language**: ...`, state.json: `"language": "..."`)
    - [ ] Description field (TODO.md: `**Description**: ...`, state.json: `"description": "..."`)
  - [ ] Compare field values between files
  - [ ] For each mismatch, record both values and their git blame timestamps
  - [ ] Build field-level discrepancy report data structure
  - [ ] Handle tasks present in only one file (no git blame needed, add to other file)
- **Timing**: 2.5 hours

### Phase 4: Implement Per-Field Conflict Resolution [NOT STARTED]

- **Goal**: Resolve conflicts using git blame timestamp-based strategy at field level
- **Tasks**:
  - [ ] For each field-level discrepancy, compare git blame timestamps
  - [ ] Define resolution rules: field with newer git blame timestamp wins
  - [ ] Handle uncommitted changes: use file mtime as fallback timestamp
  - [ ] Handle tasks present in only one file (add to other file with all fields)
  - [ ] Handle status mismatches (prefer field with newer git blame timestamp)
  - [ ] Handle metadata mismatches (prefer field with newer git blame timestamp)
  - [ ] Generate resolution plan (list of field-level changes to apply)
  - [ ] Validate resolution plan is consistent (no conflicting updates)
  - [ ] Log resolution decisions with timestamps for audit trail
- **Timing**: 2 hours

### Phase 5: Create Command File Structure [NOT STARTED]

- **Goal**: Create /sync command file with argument parsing and validation
- **Tasks**:
  - [ ] Create .opencode/command/sync.md with frontmatter
  - [ ] Implement argument parsing (--dry-run flag support)
  - [ ] Add file existence validation (TODO.md, state.json)
  - [ ] Add git repository validation (ensure files are tracked in git)
  - [ ] Add file format validation (JSON syntax, markdown structure)
  - [ ] Implement backup creation before synchronization
  - [ ] Add session_id generation
  - [ ] Add warning for uncommitted changes (recommend committing first)
- **Timing**: 1 hour

### Phase 6: Implement Synchronization Application [NOT STARTED]

- **Goal**: Apply synchronization changes atomically using status-sync-manager
- **Tasks**:
  - [ ] Implement dry-run mode (display field-level changes with timestamps without applying)
  - [ ] For each field-level discrepancy, prepare status-sync-manager delegation context
  - [ ] Delegate to status-sync-manager for atomic updates
  - [ ] Handle status-sync-manager return (success/failure)
  - [ ] Aggregate results across all synchronization operations
  - [ ] Regenerate TODO.md YAML header from state.json
  - [ ] Verify synchronization succeeded (re-check for discrepancies)
  - [ ] Create git commit with sync changes via git-workflow-manager
- **Timing**: 2 hours

### Phase 7: Testing and Validation [NOT STARTED]

- **Goal**: Test synchronization with various scenarios and edge cases
- **Tasks**:
  - [ ] Test with no discrepancies (no-op case)
  - [ ] Test with field-level discrepancy (status changed in TODO.md, priority changed in state.json)
  - [ ] Test with same field changed in both files (git blame determines winner)
  - [ ] Test with uncommitted changes (fallback to file mtime)
  - [ ] Test with task in TODO.md but not state.json
  - [ ] Test with task in state.json but not TODO.md
  - [ ] Test with multiple field mismatches in same task
  - [ ] Test with malformed TODO.md (recovery)
  - [ ] Test with malformed state.json (recovery)
  - [ ] Test dry-run mode (no changes applied, shows timestamps)
  - [ ] Test rollback on failure
  - [ ] Verify YAML header regeneration
  - [ ] Verify git commit created with correct message
  - [ ] Test with files not tracked in git (error handling)
- **Timing**: 2 hours

## Testing & Validation

- [ ] Verify /sync command file created with correct frontmatter
- [ ] Verify argument parsing handles --dry-run flag correctly
- [ ] Verify git blame timestamp extraction works for all metadata fields
- [ ] Verify field-level discrepancy detection identifies all differences with timestamps
- [ ] Verify per-field conflict resolution follows git blame timestamp-based strategy
- [ ] Verify atomic updates via status-sync-manager
- [ ] Verify dry-run mode displays field-level changes with git timestamps without applying
- [ ] Verify rollback mechanism works on failure
- [ ] Verify TODO.md YAML header regenerated correctly
- [ ] Verify synchronization report is clear and accurate with git timestamps
- [ ] Test with real TODO.md and state.json files with complex git history
- [ ] Verify uncommitted changes handled correctly (fallback to file mtime)
- [ ] Verify files not tracked in git produce clear error message

## Artifacts & Outputs

- .opencode/command/sync.md (command file)
- .opencode/specs/296_sync_command/plans/implementation-002.md (this file)
- .opencode/specs/296_sync_command/summaries/implementation-summary-20260105.md (after completion)

## Rollback/Contingency

If synchronization fails or produces incorrect results:
1. Restore TODO.md and state.json from backups created before sync
2. Review error logs to identify root cause (git blame parsing, timestamp comparison, etc.)
3. Fix synchronization logic and re-test with dry-run mode
4. If git blame approach is fundamentally flawed, fall back to file mtime comparison (implementation-001.md approach)
5. Document any data inconsistencies discovered for manual resolution

## Success Metrics

- /sync command successfully detects all field-level discrepancies between TODO.md and state.json
- Git blame timestamp extraction works reliably for all metadata fields
- Per-field conflict resolution correctly prefers field with most recent git blame timestamp
- Irrelevant changes to other parts of file do NOT affect field-level conflict resolution
- Atomic updates via status-sync-manager maintain consistency
- Dry-run mode accurately previews field-level changes with git timestamps without applying them
- Synchronization report clearly communicates field-level changes made with timestamps
- No data loss or corruption during synchronization
- Command handles edge cases gracefully with clear error messages (uncommitted changes, new files, etc.)
- True bidirectional sync achieved (not just state.json → TODO.md)

## Detailed Algorithm: Git Blame-Based Per-Field Conflict Resolution

### Step 1: Extract Field Locations

For each task in TODO.md and state.json, identify the line numbers where each metadata field is defined:

**TODO.md Example**:
```markdown
### 296. Create /sync command for bidirectional TODO.md and state.json synchronization
- **Effort**: 6-8 hours                    # Line 1183
- **Status**: [PLANNED]                    # Line 1184
- **Priority**: Medium                     # Line 1188
- **Language**: meta                       # Line 1189
```

**state.json Example**:
```json
{
  "project_number": 296,
  "status": "planned",                     # Line 5
  "priority": "medium",                    # Line 6
  "language": "meta",                      # Line 7
  "effort": "6-8 hours"                    # Line 8
}
```

### Step 2: Get Git Blame Timestamps for Each Field

For each field, use `git blame --line-porcelain` to get the commit timestamp:

```bash
# Get timestamp for status field in TODO.md (line 1184)
git blame --line-porcelain -L 1184,1184 .opencode/specs/TODO.md | grep '^author-time' | awk '{print $2}'
# Output: 1735992000 (Unix epoch seconds)

# Get timestamp for status field in state.json (line 5)
git blame --line-porcelain -L 5,5 .opencode/specs/state.json | grep '^author-time' | awk '{print $2}'
# Output: 1735995600 (Unix epoch seconds)
```

### Step 3: Compare Field Values and Timestamps

For each field, compare values between files:

**Status Field Example**:
- TODO.md value: `[PLANNED]` (timestamp: 1735992000 = 2026-01-05 08:00:00)
- state.json value: `planned` (timestamp: 1735995600 = 2026-01-05 09:00:00)
- **Discrepancy detected**: Values differ
- **Resolution**: state.json is newer (1735995600 > 1735992000)
- **Action**: Update TODO.md status to match state.json

**Priority Field Example**:
- TODO.md value: `Medium` (timestamp: 1735988400 = 2026-01-05 07:00:00)
- state.json value: `medium` (timestamp: 1735984800 = 2026-01-05 06:00:00)
- **Discrepancy detected**: Values differ (case mismatch)
- **Resolution**: TODO.md is newer (1735988400 > 1735984800)
- **Action**: Update state.json priority to match TODO.md

### Step 4: Generate Field-Level Resolution Plan

Build a resolution plan with field-level granularity:

```json
{
  "task_number": 296,
  "field_resolutions": [
    {
      "field": "status",
      "todo_value": "[PLANNED]",
      "todo_timestamp": 1735992000,
      "todo_commit": "abc123",
      "state_value": "planned",
      "state_timestamp": 1735995600,
      "state_commit": "def456",
      "resolution": "prefer_state",
      "action": "update_todo",
      "reason": "state.json status modified more recently (2026-01-05 09:00:00 vs 08:00:00)"
    },
    {
      "field": "priority",
      "todo_value": "Medium",
      "todo_timestamp": 1735988400,
      "todo_commit": "ghi789",
      "state_value": "medium",
      "state_timestamp": 1735984800,
      "state_commit": "jkl012",
      "resolution": "prefer_todo",
      "action": "update_state",
      "reason": "TODO.md priority modified more recently (2026-01-05 07:00:00 vs 06:00:00)"
    }
  ]
}
```

### Step 5: Apply Field-Level Updates

For each field resolution:
1. Update the target file (TODO.md or state.json) with the newer value
2. Preserve all other fields unchanged
3. Use status-sync-manager for atomic updates
4. Create git commit with detailed message listing field-level changes

### Key Advantages Over File-Level Mtime Comparison

**Problem with File Mtime** (implementation-001.md approach):
- If TODO.md has mtime 2026-01-05 09:00:00 and state.json has mtime 2026-01-05 08:00:00
- File-level comparison would prefer ALL fields from TODO.md
- But the TODO.md mtime might be from an irrelevant change (e.g., fixing a typo in description)
- This would incorrectly overwrite a recent status change in state.json

**Solution with Git Blame** (this approach):
- Status field in TODO.md: last modified 2026-01-05 07:00:00
- Status field in state.json: last modified 2026-01-05 08:30:00
- Per-field comparison correctly prefers state.json status (newer)
- Priority field in TODO.md: last modified 2026-01-05 08:45:00
- Priority field in state.json: last modified 2026-01-05 06:00:00
- Per-field comparison correctly prefers TODO.md priority (newer)
- **Result**: Surgical precision - each field resolved independently based on its own modification history

## Edge Cases Specific to Git Blame Approach

### Edge Case 1: Uncommitted Changes

**Scenario**: User modified TODO.md status but hasn't committed yet

**Detection**: `git blame` will show old commit timestamp, but file mtime is newer

**Handling**:
1. Detect uncommitted changes with `git diff --name-only`
2. For uncommitted files, fall back to file mtime for that field
3. Warn user: "TODO.md has uncommitted changes. Commit before sync for accurate timestamps."
4. Use file mtime as fallback timestamp for uncommitted lines

### Edge Case 2: New Files Not Tracked in Git

**Scenario**: state.json is newly created and not yet committed

**Detection**: `git blame` fails with "file not tracked" error

**Handling**:
1. Detect with `git ls-files --error-unmatch`
2. Abort sync with error: "state.json not tracked in git. Commit file before sync."
3. Provide recovery steps: `git add .opencode/specs/state.json && git commit`

### Edge Case 3: Merge Commits

**Scenario**: Field was modified in a merge commit, git blame shows merge commit timestamp

**Detection**: `git blame` shows merge commit hash

**Handling**:
1. Use merge commit timestamp (accurate for when change was integrated)
2. No special handling needed - merge commit timestamp is valid

### Edge Case 4: Line Moved or Refactored

**Scenario**: Field line was moved to different location in file

**Detection**: `git blame -M` (detect moved lines) shows original commit

**Handling**:
1. Use `git blame -M` to follow moved lines
2. Use original commit timestamp (when content was last modified)

### Edge Case 5: Field Deleted and Re-added

**Scenario**: Field was deleted in one commit and re-added in later commit

**Detection**: `git blame` shows re-add commit timestamp

**Handling**:
1. Use re-add commit timestamp (most recent modification)
2. No special handling needed - re-add is a valid modification

## Performance Optimizations

### Optimization 1: Batch Git Blame Calls

Instead of calling `git blame` once per field per file:
```bash
# Inefficient: 10 git blame calls for 5 fields in 2 files
git blame -L 1183,1183 TODO.md
git blame -L 1184,1184 TODO.md
# ... 8 more calls
```

Use single git blame call per file:
```bash
# Efficient: 2 git blame calls total
git blame --line-porcelain TODO.md > /tmp/todo_blame.txt
git blame --line-porcelain state.json > /tmp/state_blame.txt
# Parse cached blame output for all fields
```

### Optimization 2: Cache Blame Results

Cache git blame output per file to avoid redundant calls:
```bash
# Cache blame results
if [ ! -f /tmp/todo_blame_cache_$session_id.txt ]; then
  git blame --line-porcelain TODO.md > /tmp/todo_blame_cache_$session_id.txt
fi

# Reuse cached results for all field lookups
blame_cache="/tmp/todo_blame_cache_$session_id.txt"
```

### Optimization 3: Use --line-porcelain Format

The `--line-porcelain` format is optimized for parsing:
```bash
git blame --line-porcelain -L 1184,1184 TODO.md
# Output:
# abc123def456... 1184 1184 1
# author John Doe
# author-mail <john@example.com>
# author-time 1735992000
# author-tz +0000
# committer John Doe
# committer-mail <john@example.com>
# committer-time 1735992000
# committer-tz +0000
# summary Update task status to PLANNED
# filename .opencode/specs/TODO.md
#         - **Status**: [PLANNED]
```

Extract timestamp efficiently:
```bash
timestamp=$(grep '^author-time' /tmp/blame_output.txt | awk '{print $2}')
```

## Comparison: Implementation-001 vs Implementation-002

| Aspect | Implementation-001 (File Mtime) | Implementation-002 (Git Blame) |
|--------|----------------------------------|--------------------------------|
| **Granularity** | File-level (all fields together) | Field-level (per field) |
| **Timestamp Source** | File modification time (stat) | Git commit timestamp (git blame) |
| **Accuracy** | Coarse (irrelevant changes affect all fields) | Precise (each field independent) |
| **Complexity** | Low (simple stat command) | High (git blame parsing) |
| **Performance** | Fast (~10ms per file) | Slower (~50-100ms per file with caching) |
| **Edge Cases** | Fewer (just file mtime) | More (uncommitted changes, new files, etc.) |
| **Bidirectional Sync** | Limited (file-level only) | True (field-level) |
| **Conflict Resolution** | File-level (all or nothing) | Field-level (surgical precision) |
| **Git Dependency** | None (works without git) | Required (needs git history) |
| **Recommended For** | Simple sync, no git history | Complex sync, accurate conflict resolution |

**Conclusion**: Implementation-002 provides superior conflict resolution at the cost of increased complexity. Use this approach when accurate per-field synchronization is critical.
