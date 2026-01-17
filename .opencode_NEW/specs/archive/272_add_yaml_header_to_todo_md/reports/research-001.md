# Research Report: Add Standardized YAML Header to TODO.md with state.json Metadata

**Task**: 272 - Add standardized YAML header to TODO.md with state.json metadata  
**Started**: 2026-01-03  
**Completed**: 2026-01-03  
**Effort**: 4 hours  
**Priority**: Medium  
**Dependencies**: None  
**Sources/Inputs**: 
- specs/TODO.md (current format)
- specs/state.json (metadata source)
- .opencode/context/core/standards/tasks.md
- .opencode/context/core/system/state-management.md
- .opencode/context/core/system/artifact-management.md

**Artifacts**: 
- specs/272_add_yaml_header_to_todo_md/reports/research-001.md

**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

This research analyzes the current TODO.md structure and state.json metadata to design a standardized YAML header that surfaces key project health metrics directly in the user-facing task list. The proposed YAML header will include repository health, task counts, technical debt metrics, and metadata timestamps, synchronized automatically by workflow commands through the status-sync-manager. Implementation requires updating 6 subagents, 1 command, and 3 context files with an estimated effort of 12-16 hours.

---

## Context & Scope

### Current State

**TODO.md Header** (simple text):
```markdown
# TODO

**Last Updated:** 2026-01-03T20:03:00Z

---
```

**state.json Metadata** (rich but hidden from users):
```json
{
  "_schema_version": "1.1.0",
  "_last_updated": "2026-01-03T20:03:00Z",
  "next_project_number": 276,
  "repository_health": {
    "last_assessed": "2025-12-29T00:05:34Z",
    "overall_score": 92,
    "active_tasks": 4,
    "completed_tasks": 50,
    "blocked_tasks": 2,
    "in_progress_tasks": 2,
    "not_started_tasks": 23,
    "high_priority_tasks": 15,
    "medium_priority_tasks": 12,
    "low_priority_tasks": 11,
    "production_readiness": "excellent",
    "technical_debt": {
      "sorry_count": 6,
      "axiom_count": 11,
      "build_errors": 11,
      "status": "well-documented"
    }
  }
}
```

### Problem Statement

Users must manually inspect state.json to understand project health, task distribution, and technical debt. This creates friction and reduces visibility into repository status. A YAML header in TODO.md would surface this metadata in a human-readable format directly in the task list.

### Goals

1. Design YAML header schema based on state.json metadata
2. Identify which state.json fields should be surfaced in TODO.md
3. Define synchronization mechanism for keeping header and state.json in sync
4. Specify which subagents/commands must update the header
5. Document the YAML header format in context files

---

## Key Findings

### 1. YAML Header Schema Design

**Proposed YAML Header Format**:

```yaml
---
last_updated: 2026-01-03T20:03:00Z
next_project_number: 276
repository_health:
  overall_score: 92
  production_readiness: excellent
  last_assessed: 2025-12-29T00:05:34Z
task_counts:
  active: 4
  completed: 50
  blocked: 2
  in_progress: 2
  not_started: 23
  total: 81
priority_distribution:
  high: 15
  medium: 12
  low: 11
technical_debt:
  sorry_count: 6
  axiom_count: 11
  build_errors: 11
  status: well-documented
---
```

**Rationale**:
- **Flat structure for timestamps**: `last_updated` at top level for quick visibility
- **Nested structure for metrics**: Groups related metrics (health, tasks, priorities, debt)
- **Human-readable**: YAML format is more readable than JSON for users
- **Compact**: Fits in ~20 lines, minimal visual overhead
- **Comprehensive**: Surfaces all key metrics without overwhelming detail

### 2. Field Selection Criteria

**Fields to Include** (high value for users):
- `last_updated`: When TODO.md was last modified
- `next_project_number`: Next available task number
- `repository_health.overall_score`: Quick health check
- `repository_health.production_readiness`: Deployment readiness
- `repository_health.last_assessed`: When health was last checked
- Task counts: Active, completed, blocked, in-progress, not-started
- Priority distribution: High, medium, low priority task counts
- Technical debt: Sorry count, axiom count, build errors, status

**Fields to Exclude** (low value or too verbose):
- `_schema_version`: Internal metadata, not user-facing
- `project_numbering.policy`: Implementation detail
- `state_references`: Internal file paths
- `active_projects`: Too verbose for header (belongs in task list body)
- `completed_projects`: Too verbose for header
- `recent_activities`: Too verbose for header
- `pending_tasks`: Too verbose for header

### 3. Synchronization Mechanism

**Update Triggers**:
- Any command that updates state.json MUST also update TODO.md YAML header
- Commands: /research, /plan, /revise, /implement, /review, /todo, /task
- Subagents: researcher, planner, reviser, implementer, task-executor, status-sync-manager

**Synchronization Strategy**:
- **status-sync-manager** is the authoritative synchronization point
- All commands delegate to status-sync-manager for atomic TODO.md + state.json updates
- status-sync-manager reads state.json, regenerates YAML header, updates TODO.md
- Two-phase commit ensures atomicity (both files updated or neither)

**Header Regeneration Algorithm**:
1. Read current state.json
2. Extract relevant fields (per schema above)
3. Generate YAML header string
4. Read current TODO.md
5. Replace YAML header (between `---` delimiters)
6. Write updated TODO.md
7. Verify write succeeded before committing

### 4. Subagent/Command Modifications

**Subagents to Modify**:
1. **status-sync-manager.md**: Add YAML header regeneration logic
   - New function: `regenerate_yaml_header(state_json_path, todo_md_path)`
   - Called during every TODO.md update
   - Atomic update: header + task entry + state.json

2. **researcher.md**: Ensure status updates trigger header sync
   - Delegates to status-sync-manager (already does this)
   - No direct changes needed

3. **planner.md**: Ensure status updates trigger header sync
   - Delegates to status-sync-manager (already does this)
   - No direct changes needed

4. **reviser.md**: Ensure status updates trigger header sync
   - Delegates to status-sync-manager (already does this)
   - No direct changes needed

5. **implementer.md**: Ensure status updates trigger header sync
   - Delegates to status-sync-manager (already does this)
   - No direct changes needed

6. **task-executor.md**: Ensure status updates trigger header sync
   - Delegates to status-sync-manager (already does this)
   - No direct changes needed

**Commands to Modify**:
1. **/todo command**: Add header regeneration on demand
   - New flag: `--refresh-header` to force header regeneration
   - Always regenerates header during cleanup/archival operations
   - Useful for manual header refresh if state.json manually edited

**Context Files to Update**:
1. **.opencode/context/core/standards/tasks.md**: Document YAML header format
   - Add section: "TODO.md YAML Header Format"
   - Specify required fields and format
   - Explain synchronization mechanism

2. **.opencode/context/core/system/state-management.md**: Document header sync requirements
   - Add section: "TODO.md YAML Header Synchronization"
   - Specify when header must be updated
   - Document regeneration algorithm

3. **.opencode/context/core/system/artifact-management.md**: Document TODO.md structure
   - Add section: "TODO.md Structure"
   - Specify YAML header + task list body format
   - Explain header vs body separation

### 5. Implementation Complexity Analysis

**Low Complexity**:
- YAML header schema design (already complete)
- Field selection (already complete)
- Context file documentation (straightforward)

**Medium Complexity**:
- status-sync-manager header regeneration logic
  - Read state.json
  - Extract fields
  - Generate YAML string
  - Replace header in TODO.md
  - Atomic write with rollback

**High Complexity**:
- Testing header synchronization across all workflow commands
  - Test /research updates header
  - Test /plan updates header
  - Test /revise updates header
  - Test /implement updates header
  - Test /review updates header
  - Test /todo updates header
  - Test /task updates header
  - Verify atomicity (both files updated or neither)

**Edge Cases**:
- TODO.md missing YAML header (first-time initialization)
- state.json missing fields (graceful degradation)
- Concurrent updates (atomic write prevents corruption)
- Manual TODO.md edits (header regeneration overwrites)

---

## Detailed Analysis

### YAML Header Format Specification

**Header Delimiters**:
- Start: `---` (three hyphens on own line)
- End: `---` (three hyphens on own line)
- Content: YAML key-value pairs between delimiters

**Field Formats**:
- **Timestamps**: ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ)
- **Integers**: Plain integers (no quotes)
- **Strings**: Plain strings (no quotes unless special characters)
- **Nested objects**: YAML indentation (2 spaces per level)

**Example Header**:
```yaml
---
last_updated: 2026-01-03T20:03:00Z
next_project_number: 276
repository_health:
  overall_score: 92
  production_readiness: excellent
  last_assessed: 2025-12-29T00:05:34Z
task_counts:
  active: 4
  completed: 50
  blocked: 2
  in_progress: 2
  not_started: 23
  total: 81
priority_distribution:
  high: 15
  medium: 12
  low: 11
technical_debt:
  sorry_count: 6
  axiom_count: 11
  build_errors: 11
  status: well-documented
---
```

### Header Regeneration Algorithm (Pseudocode)

```python
def regenerate_yaml_header(state_json_path, todo_md_path):
    """Regenerate TODO.md YAML header from state.json."""
    
    # Phase 1: Read state.json
    with open(state_json_path, 'r') as f:
        state = json.load(f)
    
    # Phase 2: Extract fields
    header_data = {
        'last_updated': state['_last_updated'],
        'next_project_number': state['next_project_number'],
        'repository_health': {
            'overall_score': state['repository_health']['overall_score'],
            'production_readiness': state['repository_health']['production_readiness'],
            'last_assessed': state['repository_health']['last_assessed']
        },
        'task_counts': {
            'active': state['repository_health']['active_tasks'],
            'completed': state['repository_health']['completed_tasks'],
            'blocked': state['repository_health']['blocked_tasks'],
            'in_progress': state['repository_health']['in_progress_tasks'],
            'not_started': state['repository_health']['not_started_tasks'],
            'total': sum([...])  # Calculate total
        },
        'priority_distribution': {
            'high': state['repository_health']['high_priority_tasks'],
            'medium': state['repository_health']['medium_priority_tasks'],
            'low': state['repository_health']['low_priority_tasks']
        },
        'technical_debt': state['repository_health']['technical_debt']
    }
    
    # Phase 3: Generate YAML string
    yaml_header = "---\n"
    yaml_header += yaml.dump(header_data, default_flow_style=False)
    yaml_header += "---\n"
    
    # Phase 4: Read current TODO.md
    with open(todo_md_path, 'r') as f:
        todo_content = f.read()
    
    # Phase 5: Replace YAML header
    if todo_content.startswith('---\n'):
        # Find end of existing header
        end_index = todo_content.find('\n---\n', 4) + 5
        todo_body = todo_content[end_index:]
    else:
        # No existing header, prepend to entire content
        todo_body = todo_content
    
    new_todo_content = yaml_header + "\n" + todo_body
    
    # Phase 6: Write updated TODO.md (atomic)
    with open(todo_md_path + '.tmp', 'w') as f:
        f.write(new_todo_content)
    
    # Phase 7: Verify write succeeded
    if os.path.getsize(todo_md_path + '.tmp') > 0:
        os.rename(todo_md_path + '.tmp', todo_md_path)
        return True
    else:
        os.remove(todo_md_path + '.tmp')
        return False
```

### Integration with status-sync-manager

**Current status-sync-manager Workflow**:
1. Validate status transition
2. Update TODO.md task entry
3. Update state.json
4. Update project state.json (if exists)
5. Commit changes (atomic)

**Enhanced Workflow** (with YAML header):
1. Validate status transition
2. Update TODO.md task entry
3. Update state.json
4. **Regenerate TODO.md YAML header** (NEW)
5. Update project state.json (if exists)
6. Commit changes (atomic)

**Key Insight**: Header regeneration happens AFTER state.json update, ensuring header reflects latest state.

### Error Handling

**Missing state.json Fields**:
- Gracefully degrade: Use default values or omit field
- Example: If `overall_score` missing, use `"N/A"` or omit from header
- Log warning but don't fail

**Missing TODO.md YAML Header**:
- First-time initialization: Generate header from state.json
- Prepend header to existing TODO.md content
- No data loss

**Concurrent Updates**:
- Atomic write prevents corruption
- File locking (if supported) prevents race conditions
- Last-write-wins if concurrent updates occur

**Manual TODO.md Edits**:
- Header regeneration overwrites manual edits to header
- Task list body preserved (header vs body separation)
- Users should edit state.json, not TODO.md header

---

## Code Examples

### Example 1: YAML Header Generation (Python)

```python
import yaml
import json

def generate_yaml_header(state_json_path):
    """Generate YAML header from state.json."""
    with open(state_json_path, 'r') as f:
        state = json.load(f)
    
    # Extract fields
    header_data = {
        'last_updated': state['_last_updated'],
        'next_project_number': state['next_project_number'],
        'repository_health': {
            'overall_score': state['repository_health']['overall_score'],
            'production_readiness': state['repository_health']['production_readiness'],
            'last_assessed': state['repository_health']['last_assessed']
        },
        'task_counts': {
            'active': state['repository_health']['active_tasks'],
            'completed': state['repository_health']['completed_tasks'],
            'blocked': state['repository_health']['blocked_tasks'],
            'in_progress': state['repository_health']['in_progress_tasks'],
            'not_started': state['repository_health']['not_started_tasks'],
            'total': (
                state['repository_health']['active_tasks'] +
                state['repository_health']['completed_tasks'] +
                state['repository_health']['blocked_tasks'] +
                state['repository_health']['in_progress_tasks'] +
                state['repository_health']['not_started_tasks']
            )
        },
        'priority_distribution': {
            'high': state['repository_health']['high_priority_tasks'],
            'medium': state['repository_health']['medium_priority_tasks'],
            'low': state['repository_health']['low_priority_tasks']
        },
        'technical_debt': state['repository_health']['technical_debt']
    }
    
    # Generate YAML string
    yaml_str = yaml.dump(header_data, default_flow_style=False, sort_keys=False)
    return f"---\n{yaml_str}---\n"
```

### Example 2: TODO.md Header Replacement (Bash)

```bash
#!/bin/bash
# Replace TODO.md YAML header with regenerated header

STATE_JSON="specs/state.json"
TODO_MD="specs/TODO.md"
TEMP_HEADER="/tmp/todo_header.yaml"
TEMP_TODO="/tmp/TODO.md.tmp"

# Generate new header
python3 generate_yaml_header.py "$STATE_JSON" > "$TEMP_HEADER"

# Extract TODO.md body (after existing header)
if grep -q "^---$" "$TODO_MD"; then
    # Find second occurrence of "---" (end of header)
    sed -n '/^---$/,/^---$/!p;//!p' "$TODO_MD" | tail -n +2 > "$TEMP_TODO"
else
    # No existing header, use entire file as body
    cp "$TODO_MD" "$TEMP_TODO"
fi

# Combine new header + body
cat "$TEMP_HEADER" "$TEMP_TODO" > "$TODO_MD.new"

# Atomic replace
mv "$TODO_MD.new" "$TODO_MD"

# Cleanup
rm -f "$TEMP_HEADER" "$TEMP_TODO"
```

---

## Decisions

### Decision 1: YAML vs JSON for Header Format

**Options**:
1. YAML format (human-readable, compact)
2. JSON format (machine-readable, consistent with state.json)

**Decision**: YAML format

**Rationale**:
- More human-readable (no quotes, cleaner syntax)
- More compact (less visual overhead)
- Standard for frontmatter in markdown files
- Easy to parse (YAML parsers widely available)
- Consistent with industry standards (Jekyll, Hugo, etc.)

### Decision 2: Header Regeneration Timing

**Options**:
1. Regenerate on every state.json update (automatic)
2. Regenerate on demand via /todo --refresh-header (manual)
3. Hybrid: Automatic + manual option

**Decision**: Hybrid approach

**Rationale**:
- Automatic regeneration ensures header always in sync
- Manual option useful for troubleshooting or manual state.json edits
- Best of both worlds: convenience + control

### Decision 3: Field Selection Strategy

**Options**:
1. Include all state.json fields (comprehensive but verbose)
2. Include only high-value fields (compact but incomplete)
3. Configurable field selection (flexible but complex)

**Decision**: Include only high-value fields

**Rationale**:
- Header should be compact (fits in one screen)
- Most users care about health score, task counts, technical debt
- Verbose fields (active_projects, recent_activities) belong in body
- Simplicity over flexibility (avoid configuration complexity)

### Decision 4: Synchronization Mechanism

**Options**:
1. Each subagent regenerates header independently (distributed)
2. status-sync-manager regenerates header centrally (centralized)
3. Separate header-sync-manager subagent (specialized)

**Decision**: status-sync-manager regenerates header centrally

**Rationale**:
- status-sync-manager already handles atomic TODO.md + state.json updates
- Centralized logic easier to maintain and test
- Avoids code duplication across subagents
- Atomic guarantee: header + task entry + state.json all updated together

---

## Recommendations

### Recommendation 1: Implement Header Regeneration in status-sync-manager

**Priority**: High

**Rationale**: status-sync-manager is the authoritative synchronization point for TODO.md and state.json. Adding header regeneration here ensures atomicity and avoids code duplication.

**Implementation**:
1. Add `regenerate_yaml_header()` function to status-sync-manager
2. Call function after state.json update, before TODO.md write
3. Test atomic update: header + task entry + state.json

### Recommendation 2: Add --refresh-header Flag to /todo Command

**Priority**: Medium

**Rationale**: Provides manual header refresh option for troubleshooting or manual state.json edits.

**Implementation**:
1. Add `--refresh-header` flag to /todo command argument parsing
2. Call status-sync-manager.regenerate_yaml_header() when flag set
3. Document flag in /todo command help text

### Recommendation 3: Document YAML Header Format in Context Files

**Priority**: High

**Rationale**: Context files are the authoritative source for standards. Documenting the YAML header format ensures consistency across commands and subagents.

**Implementation**:
1. Update tasks.md: Add "TODO.md YAML Header Format" section
2. Update state-management.md: Add "TODO.md YAML Header Synchronization" section
3. Update artifact-management.md: Add "TODO.md Structure" section

### Recommendation 4: Test Header Synchronization Across All Workflow Commands

**Priority**: High

**Rationale**: Header synchronization must work reliably across all commands to maintain consistency.

**Implementation**:
1. Test /research: Verify header updated when task marked [RESEARCHED]
2. Test /plan: Verify header updated when task marked [PLANNED]
3. Test /revise: Verify header updated when plan revised
4. Test /implement: Verify header updated when task marked [COMPLETED]
5. Test /review: Verify header updated when review completed
6. Test /todo: Verify header updated when tasks archived
7. Test /task: Verify header updated when task created

---

## Risks & Mitigations

### Risk 1: Header Regeneration Overwrites Manual Edits

**Severity**: Medium

**Likelihood**: Low

**Impact**: Users manually edit TODO.md header, changes lost on next update

**Mitigation**:
- Document in context files: "Do not manually edit YAML header"
- Header regeneration is automatic, manual edits will be overwritten
- Users should edit state.json, not TODO.md header
- Add warning comment in header: `# Auto-generated from state.json - do not edit manually`

### Risk 2: Missing state.json Fields Cause Header Generation Failure

**Severity**: Medium

**Likelihood**: Low

**Impact**: Header regeneration fails if state.json missing expected fields

**Mitigation**:
- Graceful degradation: Use default values or omit field if missing
- Log warning but don't fail
- Example: If `overall_score` missing, use `"N/A"` or omit from header
- Test with incomplete state.json to verify graceful handling

### Risk 3: Concurrent Updates Cause Header Corruption

**Severity**: High

**Likelihood**: Very Low

**Impact**: Concurrent TODO.md updates could corrupt header

**Mitigation**:
- Atomic write: Use temp file + rename pattern
- File locking (if supported by OS)
- status-sync-manager two-phase commit prevents partial updates
- Test concurrent updates to verify atomicity

### Risk 4: YAML Parsing Errors in Downstream Tools

**Severity**: Low

**Likelihood**: Very Low

**Impact**: Downstream tools (editors, parsers) fail to parse YAML header

**Mitigation**:
- Use standard YAML format (no custom extensions)
- Test YAML parsing with common tools (PyYAML, ruamel.yaml)
- Validate generated YAML before writing to TODO.md
- Add YAML validation to status-sync-manager

---

## Appendix: Sources and Citations

### Primary Sources

1. **specs/TODO.md**: Current TODO.md format (simple text header)
2. **specs/state.json**: Metadata source for YAML header
3. **.opencode/context/core/standards/tasks.md**: Task standards and formatting
4. **.opencode/context/core/system/state-management.md**: State synchronization standards
5. **.opencode/context/core/system/artifact-management.md**: Artifact structure standards

### Secondary Sources

1. **YAML Specification**: https://yaml.org/spec/1.2/spec.html
2. **Jekyll Frontmatter**: https://jekyllrb.com/docs/front-matter/
3. **Hugo Frontmatter**: https://gohugo.io/content-management/front-matter/

### Related Tasks

1. **Task 275**: Fix workflow commands to update status at beginning and end
2. **Task 274**: Remove status metadata from research reports
3. **Task 273**: Fix /research command to link research artifacts in TODO.md

---

## Conclusion

The proposed YAML header design surfaces key state.json metadata (repository health, task counts, technical debt) directly in TODO.md, improving user visibility without requiring manual state.json inspection. Implementation requires updating status-sync-manager with header regeneration logic, adding --refresh-header flag to /todo command, and documenting the format in 3 context files. Estimated effort: 12-16 hours. Risks are low and mitigated through atomic writes, graceful degradation, and comprehensive testing.
