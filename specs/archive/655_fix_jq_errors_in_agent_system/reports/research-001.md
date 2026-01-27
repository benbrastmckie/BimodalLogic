# Research Report: Fix jq Errors in Agent System

- **Task**: 655 - fix_jq_errors_in_agent_system
- **Started**: 2026-01-25T05:00:00Z
- **Completed**: 2026-01-25T05:30:00Z
- **Effort**: 3-4 hours estimated
- **Priority**: High
- **Dependencies**: None
- **Sources/Inputs**:
  - `.claude/output/todo.md` - /todo command execution log
  - `.claude/context/core/patterns/jq-escaping-workarounds.md` - Known workarounds
  - `.opencode/command/*.md` - Command definitions (12 files)
  - `.claude/skills/*/SKILL.md` - Skill definitions (13 files)
  - `.claude/scripts/postflight-*.sh` - Postflight scripts (3 files)
  - `.claude/rules/error-handling.md` - Error handling patterns
- **Artifacts**:
  - `specs/655_fix_jq_errors_in_agent_system/reports/research-001.md`
- **Standards**: report-format.md, artifact-formats.md, return-metadata-file.md

## Executive Summary

- The agent system has ONE known jq error pattern (Issue #1132) which is ALREADY MITIGATED via two-step jq pattern and reusable postflight scripts
- Analysis of /todo command execution log shows NO jq syntax errors - only one structural error (indexing array with string) due to incorrect jq command
- The todo.md output reveals command execution is HIGHLY EFFICIENT with proper orphan detection, status sync validation, and comprehensive error handling
- All command files (.opencode/command/*.md) already use status delegation to skill-status-sync and DO NOT contain vulnerable jq patterns
- Three postflight scripts (.claude/scripts/postflight-*.sh) provide correct jq patterns for research, plan, and implement operations
- Key improvement opportunities: add completion_data field handling in postflight scripts, document the two-step pattern more prominently in commands

## Context & Scope

This research evaluates the .claude/ agent system for jq command errors and execution efficiency issues. The scope includes:

1. Analysis of actual command execution (via todo.md output)
2. Review of documented jq escaping workarounds
3. Systematic examination of command and skill definitions
4. Identification of error patterns vs. one-off issues
5. Assessment of command execution performance and patterns

The research was conducted to prepare for a comprehensive plan to improve system robustness and efficiency.

## Findings

### 1. Known jq Error Pattern: Issue #1132

**Source**: `.claude/context/core/patterns/jq-escaping-workarounds.md`

**Bug Description**: Claude Code's Bash tool injects `< /dev/null` into commands containing pipe operators inside quoted strings in certain positions. This corrupts jq filter expressions like `map(select(.type != "X"))`.

**Symptoms**:
```
jq: error: syntax error, unexpected INVALID_CHARACTER, expecting $end
```

**Affected Pattern** (now avoided):
```bash
# BROKEN - triggers < /dev/null injection
artifacts: ((.artifacts // []) | map(select(.type != "research"))) + [...]
```

**Current Mitigation**: Two-step approach documented in jq-escaping-workarounds.md:

```bash
# Step 1: Update status and timestamps (no artifact manipulation)
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researched" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    researched: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 2: Update artifacts - filter out old type, add new
jq --arg path "$artifact_path" \
  '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
    ([(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type != "research")] + [{"path": $path, "type": "research"}])' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Alternative**: `del()` approach instead of `map(select(!=))`.

**Status**: MITIGATED - Pattern is documented, postflight scripts use correct pattern, and upstream bug is marked NOT_PLANNED (as of January 2026).

### 2. Analysis of /todo Command Execution Log

**Source**: `.claude/output/todo.md` (706 lines of execution trace)

**Key Observations**:

#### 2.1 jq Errors Found: ONE

**Line 226**:
```
jq: error (at specs/state.json:861): Cannot index array with string "active_projects"
```

**Root Cause**: Incorrect use of `-s` (slurp) flag causing jq to treat input as array instead of object.

**Context**:
```bash
# INCORRECT (line 223-226)
jq -s '.active_projects[] | select(.status == "completed" or .status == "abandoned")'
```

The `-s` flag wraps the input in an array, so `.active_projects` becomes invalid. Should be:
```bash
# CORRECT
jq '.active_projects[] | select(.status == "completed" or .status == "abandoned")'
```

**Impact**: This is NOT an Issue #1132 escaping error - it's a one-off jq flag misuse that was immediately corrected in the execution (line 237-242 shows successful retry without `-s` flag).

**Recovery**: Command self-corrected and continued successfully.

#### 2.2 Command Execution Performance: EXCELLENT

The /todo command execution demonstrates highly efficient patterns:

1. **Fast State Access** (line 10-14): Direct jq queries to state.json
2. **Orphan Detection** (line 61-103): Comprehensive directory scanning with dual-location checks (specs/ and archive/)
3. **Status Sync Validation** (line 67-72): Cross-reference between TODO.md markers and state.json fields
4. **Two-Phase Updates** (lines 206-285):
   - Phase 1: Fix status sync for task 671 (ABANDONED in TODO.md, "planned" in state.json)
   - Phase 2: Extract and archive 7 tasks atomically
5. **Idempotent Operations** (line 254-285): Archive state updates use atomic jq operations
6. **Comprehensive Validation** (lines 289-450): Multiple verification steps for TODO.md and state.json updates

**Performance Metrics from Log**:
- Session ID generation: instant (line 201-204)
- Status sync fix: 1 operation (line 206-209)
- Extract archivable tasks: 1 jq query (line 211-216)
- Archive update: atomic multi-step (lines 223-285)
- TODO.md updates: 4 Edit operations for 7 tasks (lines 289-533)
- Git commit: successful with 36 files changed (line 647-653)
- Final active task count: 30 (line 657-659)

**Bottlenecks Identified**: NONE - Command execution is streamlined and efficient.

#### 2.3 State Synchronization Patterns: ROBUST

The /todo command demonstrates exemplary state management:

1. **Status Mismatch Detection** (lines 78-103): Detected task 671 ABANDONED in TODO.md but "planned" in state.json
2. **Automatic Correction** (line 206-209): Fixed mismatch before archival
3. **Orphan Tracking** (lines 571-576): Moved 2 orphaned directories to archive with state entries
4. **Atomic Updates**: All state.json and TODO.md changes committed together (line 647-653)

**State File Interaction**:
- state.json reads: ~15 queries
- state.json writes: 3 atomic updates
- TODO.md reads: 4 operations
- TODO.md writes: 4 Edit operations
- archive/state.json: 1 append operation

**Error Handling**: Comprehensive with fallback patterns (e.g., line 258-261 shows cat failure with non-blocking recovery).

### 3. Command File Analysis

**Examined**: 12 command files in `.opencode/command/`

**Files with jq usage**:
1. research.md
2. implement.md
3. revise.md
4. errors.md
5. todo.md
6. task.md
7. plan.md

**Key Finding**: NO command files contain vulnerable `map(select(.type != "X"))` patterns in their documented workflows.

**Pattern Used**: All commands delegate status updates to `status-sync-manager` skill via Task tool:

```yaml
# From research.md (lines 133-148)
INVOKE status-sync-manager via task tool:
task(
  subagent_type="status-sync-manager",
  prompt="{
    \"operation\": \"update_status\",
    \"task_number\": ${task_number},
    \"new_status\": \"researching\",
    \"timestamp\": \"$(date -I)\",
    \"session_id\": \"${session_id}\",
    \"delegation_depth\": 1,
    \"delegation_path\": [\"orchestrator\", \"research\", \"status-sync-manager\"]
  }",
  description="Update task ${task_number} status to RESEARCHING"
)
```

**Validation**: Commands use comprehensive validation steps (e.g., research.md lines 197-301 show 5-step validation process).

**Artifact Verification**: All commands verify artifacts exist on disk before updating status (e.g., research.md lines 322-348).

### 4. Skill File Analysis

**Examined**: 13 skill files in `.claude/skills/*/SKILL.md`

**File with jq patterns**: `skill-status-sync/SKILL.md`

**Key Finding**: skill-status-sync explicitly documents Issue #1132 workaround:

```markdown
# From skill-status-sync/SKILL.md (lines 137-151)
**IMPORTANT**: Use two-step jq pattern to avoid Issue #1132 escaping bug.
See `jq-escaping-workarounds.md`.

# Step 1: Update timestamp
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '(.active_projects[] | select(.project_number == {task_number})) |= . + {
    last_updated: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 2: Add artifact (append to array)
jq --arg path "{artifact_path}" \
   --arg type "{artifact_type}" \
  '(.active_projects[] | select(.project_number == {task_number})).artifacts += [{"path": $path, "type": $type}]' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Other Skills**: Delegating skills (skill-researcher, skill-planner, etc.) use Task tool to invoke agents and do not execute jq commands directly.

**Separation of Concerns**:
- Workflow skills: Delegation only
- status-sync skill: Direct jq execution with documented patterns
- Agents: No jq execution (use Write/Edit tools for metadata files)

### 5. Postflight Scripts Analysis

**Examined**: 3 postflight scripts in `.claude/scripts/`

1. `postflight-research.sh` (70 lines)
2. `postflight-plan.sh` (similar structure)
3. `postflight-implement.sh` (similar structure)

**Pattern Used** (from postflight-research.sh):

```bash
# Step 1: Update status and timestamps
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researched" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    researched: $ts
  }' "$state_file" > /tmp/state.json && mv /tmp/state.json "$state_file"

# Step 2: Filter out existing research artifacts (two-step pattern for Issue #1132)
jq '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
    [(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type != "research")]' \
  "$state_file" > /tmp/state.json && mv /tmp/state.json "$state_file"

# Step 3: Add new research artifact
jq --arg path "$artifact_path" \
   --arg summary "$artifact_summary" \
  '(.active_projects[] | select(.project_number == '$task_number')).artifacts += [{"path": $path, "type": "research", "summary": $summary}]' \
  "$state_file" > /tmp/state.json && mv /tmp/state.json "$state_file"
```

**Status**: CORRECT - Uses three-step pattern with separate filter and append operations.

**Validation**: Scripts include task existence checks and error messages (lines 34-42).

**Gap Identified**: Scripts do not handle `completion_data` field (completion_summary, roadmap_items, claudemd_suggestions) from return-metadata-file.md schema (lines 102-119).

### 6. Error Handling Documentation

**Source**: `.claude/rules/error-handling.md`

**jq Error Category**: `jq_parse_failure` - External error type

**Recovery Pattern**:
```
1. Capture jq error output (INVALID_CHARACTER, syntax error)
2. Log to errors.json with original command
3. Retry using two-step pattern from jq-escaping-workarounds.md
4. If retry succeeds, log recovery
```

**Reference**: Error handling rules explicitly mention Issue #1132 and reference jq-escaping-workarounds.md (lines 52-59).

**Session Tracking**: Error logs include session_id for traceability (error-handling.md lines 5-26).

### 7. Search for Problematic Patterns

**Patterns Searched**:
1. `map(select(` - Found 0 instances in command/skill files
2. `| map(` followed by select - Found 0 instances
3. `$(jq.*|` - Found 0 instances (no jq piping in command interpolation)

**Conclusion**: The vulnerable pattern has been systematically eliminated from the codebase.

### 8. Documentation Coverage

**Files Documenting jq Patterns**:
1. `.claude/context/core/patterns/jq-escaping-workarounds.md` - Comprehensive workaround guide (230 lines)
2. `.claude/skills/skill-status-sync/SKILL.md` - References workarounds (lines 13-14, 137)
3. `.claude/scripts/postflight-research.sh` - Implementation with comments (lines 1-10)
4. `.claude/rules/error-handling.md` - Recovery patterns (lines 52-59)

**Coverage Assessment**: EXCELLENT - The workaround is documented at multiple levels:
- Pattern library (jq-escaping-workarounds.md)
- Skill implementation (skill-status-sync)
- Reusable scripts (postflight-*.sh)
- Error recovery (error-handling.md)

**Templates Available**:
- Research postflight (jq-escaping-workarounds.md lines 74-91)
- Planning postflight (lines 93-110)
- Implementation postflight (lines 112-129)
- Task recovery (lines 131-144)
- Task abandon (lines 146-159)

## Decisions

### 1. Issue #1132 is NOT a Blocker

**Rationale**: The upstream bug is documented as NOT_PLANNED, but the system has comprehensive mitigations in place:
- Two-step jq pattern documented
- Reusable postflight scripts implement correct pattern
- All command files delegate to status-sync-manager
- No instances of vulnerable pattern found in codebase

**Decision**: Focus improvement efforts on enhancing existing patterns rather than finding workarounds for eliminated vulnerabilities.

### 2. /todo Command Execution is Reference Implementation

**Rationale**: The todo.md output shows exemplary patterns:
- Atomic state updates
- Comprehensive validation
- Self-correction on errors
- Orphan detection and tracking
- Status sync verification

**Decision**: Use /todo patterns as reference for other command improvements.

### 3. Postflight Scripts Need completion_data Support

**Rationale**: return-metadata-file.md schema (lines 102-119) defines completion_data field with:
- completion_summary (required for implemented status)
- roadmap_items (optional, non-meta tasks)
- claudemd_suggestions (required for meta tasks)

Current postflight scripts only handle artifacts array, not completion_data.

**Decision**: Add completion_data field extraction and state.json updates to postflight-implement.sh.

## Recommendations

### Priority 1: Enhance Postflight Scripts

**Action**: Update postflight-implement.sh to extract and store completion_data

**Rationale**: The /todo command uses completion_summary and claudemd_suggestions fields (todo.md lines 149-177), but postflight-implement.sh doesn't populate these fields.

**Implementation**:
1. Add completion_summary field extraction from metadata file
2. Add roadmap_items array extraction (if present)
3. Add claudemd_suggestions extraction for meta tasks
4. Update state.json with new fields
5. Validate fields exist before /todo archival

**Estimated Effort**: 1 hour

**Files to Modify**:
- `.claude/scripts/postflight-implement.sh`

### Priority 2: Add Comprehensive Testing Script

**Action**: Create `.claude/scripts/test-jq-patterns.sh` for regression testing

**Rationale**: The jq-escaping-workarounds.md includes a test script (lines 161-207) but it's not a standalone file. Having a reusable test script ensures patterns don't regress.

**Implementation**:
1. Extract test script from jq-escaping-workarounds.md
2. Add tests for all three postflight scripts
3. Add tests for status-sync operations
4. Include validation of output JSON structure
5. Add to CI/testing workflow

**Estimated Effort**: 2 hours

**Files to Create**:
- `.claude/scripts/test-jq-patterns.sh`

### Priority 3: Document Command Execution Flow

**Action**: Create `.claude/docs/architecture/command-execution-flow.md`

**Rationale**: The /todo output reveals complex but well-designed execution flow. Documenting this helps maintain quality across all commands.

**Implementation**:
1. Extract flow patterns from todo.md analysis
2. Document checkpoint execution with timing
3. Include validation steps and error recovery
4. Reference from command template
5. Add diagrams for visual clarity

**Estimated Effort**: 2-3 hours

**Files to Create**:
- `.claude/docs/architecture/command-execution-flow.md`

### Priority 4: Add jq Pattern Linter

**Action**: Create pre-commit hook to detect vulnerable jq patterns

**Rationale**: Prevent reintroduction of `map(select(.type != "X"))` pattern in future edits.

**Implementation**:
1. Create `.claude/scripts/lint-jq-patterns.sh`
2. Scan for map(select patterns
3. Check for pipe operators in jq command substitution
4. Suggest two-step alternative
5. Add to git pre-commit hook

**Estimated Effort**: 1-2 hours

**Files to Create**:
- `.claude/scripts/lint-jq-patterns.sh`
- `.git/hooks/pre-commit` (or add to existing)

### Priority 5: Centralize jq Error Recovery

**Action**: Create `.claude/scripts/jq-safe-wrapper.sh` for automatic retry

**Rationale**: Error handling rules (error-handling.md lines 52-59) describe manual retry process. Automating this reduces error recovery time.

**Implementation**:
1. Create wrapper script that executes jq command
2. Detect INVALID_CHARACTER errors
3. Automatically retry with two-step pattern
4. Log recovery to errors.json with session_id
5. Update documentation to reference wrapper

**Estimated Effort**: 2 hours

**Files to Create**:
- `.claude/scripts/jq-safe-wrapper.sh`

**Files to Update**:
- `.claude/rules/error-handling.md` (add wrapper reference)

## Risks & Mitigations

### Risk 1: Regression to Vulnerable Pattern

**Probability**: Low
**Impact**: Medium (command failure, not data corruption)

**Mitigation**:
- Implement jq pattern linter (Recommendation #4)
- Add test suite (Recommendation #2)
- Reference jq-escaping-workarounds.md in all command templates

### Risk 2: New jq Edge Cases

**Probability**: Low
**Impact**: Medium

**Mitigation**:
- Test all postflight scripts with edge cases (empty arrays, null fields)
- Add error recovery wrapper (Recommendation #5)
- Document new patterns as discovered

### Risk 3: completion_data Field Mismatch

**Probability**: Medium (currently happening)
**Impact**: Medium (/todo command expects fields not populated)

**Mitigation**:
- Implement Priority 1 recommendation immediately
- Add validation in /todo to handle missing fields gracefully
- Update return-metadata-file.md examples to show field propagation

### Risk 4: Upstream Bug Changes

**Probability**: Very Low (bug marked NOT_PLANNED)
**Impact**: High (if bug fixed, two-step pattern may be unnecessary overhead)

**Mitigation**:
- Monitor Claude Code release notes
- Keep two-step pattern as optional optimization
- Add feature flag to enable/disable workaround

## Appendix

### A. jq Error Types Observed

| Error Type | Count | Location | Status |
|------------|-------|----------|--------|
| Cannot index array with string | 1 | todo.md line 226 | Fixed (removed -s flag) |
| INVALID_CHARACTER (Issue #1132) | 0 | N/A | Prevented by two-step pattern |

### B. Command Execution Metrics (from todo.md)

- Total execution time: ~5 seconds (estimated from log timestamps)
- jq operations: ~20 queries, 3 updates
- File operations: 8 reads, 7 writes
- Git operations: 1 commit (36 files changed)
- Tasks archived: 7 (6 completed, 1 abandoned)
- Orphans tracked: 2 directories
- Status syncs fixed: 1 (task 671)

### C. Documentation References

1. `.claude/context/core/patterns/jq-escaping-workarounds.md` - Primary workaround guide
2. `.claude/context/core/patterns/checkpoint-execution.md` - Command lifecycle
3. `.claude/context/core/formats/return-metadata-file.md` - Metadata schema
4. `.claude/rules/error-handling.md` - Error recovery patterns
5. `.claude/rules/workflows.md` - Workflow lifecycle rules

### D. Search Queries Used

```bash
# Search for vulnerable patterns
grep -r "map(select(" .opencode/command/ .claude/skills/
grep -r '| map(' .opencode/command/
grep -r '\$(jq.*|' .opencode/command/

# Search for jq usage
grep -r 'jq ' .opencode/command/ | wc -l  # ~150 instances
grep -r 'jq ' .claude/skills/ | wc -l     # ~30 instances

# Analyze error patterns
grep -n "jq: error\|INVALID_CHARACTER" .claude/output/todo.md
```

### E. File Statistics

**Command Files**: 12 total, 7 with jq usage
**Skill Files**: 13 total, 1 with direct jq execution (skill-status-sync)
**Postflight Scripts**: 3 files implementing correct pattern
**Context Documentation**: 30 files reference jq patterns
**Total Lines with jq Commands**: ~180 across all files

### F. Improvement Plan Summary

| Priority | Recommendation | Effort | Files | Impact |
|----------|---------------|--------|-------|--------|
| 1 | completion_data support | 1h | 1 modified | High - fixes /todo gap |
| 2 | Testing script | 2h | 1 created | Medium - regression prevention |
| 3 | Execution flow docs | 3h | 1 created | Medium - maintainability |
| 4 | Pattern linter | 2h | 2 created | Medium - prevention |
| 5 | Error recovery wrapper | 2h | 2 modified | Low - nice-to-have |

**Total Estimated Effort**: 10 hours
