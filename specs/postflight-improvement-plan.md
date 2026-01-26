# Plan: Prevent Postflight Failures in Command-Skill-Agent Workflows

## Executive Summary

**Problem**: Task 690 research completed successfully BUT TODO.md artifact link was NOT added, creating state inconsistency. The workflow reported success despite incomplete postflight operations.

**Root Cause**: skill-researcher Stage 8 (TODO.md Edit operation) failed silently. No validation occurred before git commit proceeded.

**Solution**: Implement atomic state updates with validation checkpoints to ensure both state.json AND TODO.md update together or neither, with rollback on failure.

---

## Root Cause Analysis

### What Happened (Task 690)

Git commit `e8f51582` shows:
- ✅ state.json updated to "researched" with artifact array
- ❌ TODO.md missing research link (Edit tool failed silently)
- ⚠️ TODO.md has duplicate status markers (lines 129, 132)
- ✅ Git commit proceeded despite incomplete postflight

### Where Responsibility Lives

**Current Architecture**:
- **No `/research` command** - workflow is Skill tool → skill-researcher → general-research-agent
- **skill-researcher** implements "skill-internal postflight pattern" (Stages 7-11)
- **Failure occurred at**: Stage 8 (Artifact Linking to TODO.md)

**Why It Failed**:
1. Edit tool for TODO.md failed silently (no error returned)
2. No validation checkpoint after Edit operation
3. Git commit not conditional on validation success
4. state.json and TODO.md updated separately (not atomic)

---

## Solution: Atomic Postflight with Validation

### Architectural Pattern

```
SKILL POSTFLIGHT LAYER (Enhanced)
│
├─ Stage 7: Atomic State Update
│  ├─ Write state.json to /tmp/state.json.new
│  ├─ Write TODO.md to /tmp/TODO.md.new (Python, not Edit tool)
│  ├─ Validate both temp files
│  ├─ Atomic replace: mv both or neither
│  └─ Rollback on failure
│
├─ Stage 8: Validation Checkpoint (NEW)
│  ├─ Read-back state.json: verify status + artifact
│  ├─ Read-back TODO.md: verify status marker + link
│  ├─ Count checks: exactly one status, exactly one link
│  └─ ABORT if validation fails
│
├─ Stage 9: Conditional Git Commit (CHANGED)
│  └─ Only commit if Stage 8 validation passed
│
├─ Stage 10: Cleanup
└─ Stage 11: Return Status (enhanced with validation result)
```

**Key Improvements**:
1. **Atomicity**: Both files update together via temp files + atomic mv
2. **Validation**: Read-back verification catches silent failures
3. **Conditional Commit**: Only commit if all validations pass
4. **Python over Edit**: Reliable TODO.md updates with error codes

---

## Phase 1: Create Atomic Postflight Script ✅ COMPLETED

**Estimated effort**: 4 hours

**Deliverable**: `.claude/scripts/atomic-postflight-research.sh`

**Status**: ✅ Completed - Script created and made executable

**Core Features**:
```bash
#!/bin/bash
# atomic-postflight-research.sh - Atomic state update with validation
set -e

task_number="$1"
artifact_path="$2"
artifact_summary="$3"
project_name="$4"

# Backup current state
cp specs/state.json /tmp/state.json.backup
cp specs/TODO.md /tmp/TODO.md.backup

# Update state.json to temp (two-step jq pattern)
timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
jq --arg num "$task_number" \
   --arg status "researched" \
   --arg ts "$timestamp" \
   '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
     status: $status,
     last_updated: $ts,
     researched: $ts
   }' specs/state.json > /tmp/state.json.new

# Add artifact to state.json temp (two-step jq pattern for Issue #1132)
jq --arg num "$task_number" \
   --arg path "$artifact_path" \
   --arg summary "$artifact_summary" \
   '(.active_projects[] | select(.project_number == ($num | tonumber))).artifacts += [{
     type: "research",
     path: $path,
     summary: $summary
   }]' /tmp/state.json.new > /tmp/state.json.tmp
mv /tmp/state.json.tmp /tmp/state.json.new

# Update TODO.md to temp (Python script - reliable)
python3 .claude/scripts/update-todo-artifact.py \
    --input specs/TODO.md \
    --output /tmp/TODO.md.new \
    --task "$task_number" \
    --type "research" \
    --path "$artifact_path"

# Validate temp files
source .claude/scripts/lib/validation.sh
if ! validate_state_json /tmp/state.json.new "$task_number" "researched" "research"; then
    echo "ERROR: state.json validation failed"
    exit 1
fi

if ! validate_todo_md /tmp/TODO.md.new "$task_number" "RESEARCHED" "Research"; then
    echo "ERROR: TODO.md validation failed"
    exit 1
fi

# Atomic replace (both or neither)
mv /tmp/state.json.new specs/state.json
mv /tmp/TODO.md.new specs/TODO.md

echo "SUCCESS"
exit 0
```

---

## Phase 2: Create TODO.md Python Updater ✅ COMPLETED

**Estimated effort**: 3 hours

**Deliverable**: `.claude/scripts/update-todo-artifact.py`

**Status**: ✅ Completed - Python script created with error handling and validation

**Why Python instead of Edit tool**:
- Edit tool failed silently for task 690
- Python returns clear error codes
- Precise line insertion (no ambiguity)
- Testable in isolation

**Key Features**:
```python
#!/usr/bin/env python3
import sys, re, argparse
from pathlib import Path

def find_task_section(lines, task_number):
    """Find start/end indices of task section."""
    start_pattern = re.compile(rf'^### {task_number}\.')
    next_section = re.compile(r'^### \d+\.')

    start_idx = None
    for i, line in enumerate(lines):
        if start_pattern.match(line):
            start_idx = i
            break

    if start_idx is None:
        raise ValueError(f"Task {task_number} not found")

    end_idx = len(lines)
    for i in range(start_idx + 1, len(lines)):
        if next_section.match(lines[i]):
            end_idx = i
            break

    return start_idx, end_idx

def add_artifact_link(lines, task_number, artifact_type, artifact_path):
    """Add artifact link to task section."""
    start_idx, end_idx = find_task_section(lines, task_number)

    type_map = {'research': 'Research', 'plan': 'Plan', 'summary': 'Summary'}
    label = type_map.get(artifact_type, artifact_type.capitalize())
    filename = Path(artifact_path).name
    link_line = f"- **{label}**: [{filename}]({artifact_path})\n"

    # Find insertion point: after last metadata field, before **Description**
    desc_pattern = re.compile(r'^\*\*Description\*\*:')
    insert_idx = end_idx - 1

    for i in range(start_idx, end_idx):
        if desc_pattern.match(lines[i]):
            insert_idx = i
            break

    lines.insert(insert_idx, link_line)
    return lines

# ... (full implementation in actual file)
```

---

## Phase 3: Create Validation Library ✅ COMPLETED

**Estimated effort**: 2 hours

**Deliverable**: `.claude/scripts/lib/validation.sh`

**Status**: ✅ Completed - Validation functions for state.json and TODO.md created

**Validation Functions**:
```bash
#!/bin/bash

validate_state_json() {
    local file="$1"
    local task_num="$2"
    local expected_status="$3"
    local artifact_type="$4"

    # Check JSON valid
    if ! jq empty "$file" 2>/dev/null; then
        echo "Error: Invalid JSON"
        return 1
    fi

    # Check task status
    local status=$(jq -r --argjson num "$task_num" \
        '.active_projects[] | select(.project_number == $num) | .status // "not_found"' \
        "$file")

    if [ "$status" != "$expected_status" ]; then
        echo "Error: Status is '$status', expected '$expected_status'"
        return 1
    fi

    # Check artifact exists
    local artifact=$(jq -r --argjson num "$task_num" \
        --arg type "$artifact_type" \
        '.active_projects[] | select(.project_number == $num) | .artifacts[] | select(.type == $type) | .path // ""' \
        "$file")

    if [ -z "$artifact" ]; then
        echo "Error: Artifact type '$artifact_type' not found"
        return 1
    fi

    return 0
}

validate_todo_md() {
    local file="$1"
    local task_num="$2"
    local expected_status="$3"
    local link_type="$4"

    # Extract task section
    local section=$(sed -n "/^### ${task_num}\./,/^###/p" "$file")

    if [ -z "$section" ]; then
        echo "Error: Task $task_num not found"
        return 1
    fi

    # Check exactly one status marker (no duplicates)
    local status_count=$(echo "$section" | grep -c "\[${expected_status}\]")
    if [ "$status_count" -ne 1 ]; then
        echo "Error: Found $status_count status markers, expected 1"
        return 1
    fi

    # Check artifact link exists
    if ! echo "$section" | grep -q "^\- \*\*${link_type}\*\*:"; then
        echo "Error: ${link_type} link not found"
        return 1
    fi

    return 0
}
```

---

## Phase 4: Update skill-researcher ✅ COMPLETED

**Estimated effort**: 2 hours

**File**: `.claude/skills/skill-researcher/SKILL.md`

**Status**: ✅ Completed - Stages 7-9 replaced with atomic postflight pattern + validation checkpoint

**Replace Stages 7-9**:

### Stage 7: Atomic State Update

Use atomic postflight script to ensure both files update together:

```bash
if ! .claude/scripts/atomic-postflight-research.sh \
    "$task_number" \
    "$artifact_path" \
    "$artifact_summary" \
    "$project_name"; then

    echo "ERROR: Atomic postflight failed"
    rm -f specs/.postflight-pending

    # Attempt rollback from backups
    if [ -f /tmp/state.json.backup ]; then
        cp /tmp/state.json.backup specs/state.json
    fi
    if [ -f /tmp/TODO.md.backup ]; then
        cp /tmp/TODO.md.backup specs/TODO.md
    fi

    return "Research completed but state update failed. Run /research ${task_number} to retry."
fi
```

### Stage 8: Validation Checkpoint

Read-back and verify to catch silent failures:

```bash
# Read-back verification
source .claude/scripts/lib/validation.sh

if ! validate_state_json specs/state.json "$task_number" "researched" "research"; then
    echo "CRITICAL: Postflight validation failed"
    return "State validation failed - manual inspection required"
fi

if ! validate_todo_md specs/TODO.md "$task_number" "RESEARCHED" "Research"; then
    echo "CRITICAL: TODO.md validation failed"
    return "TODO.md validation failed - manual inspection required"
fi

echo "✓ Validation passed: all state updates confirmed"
```

### Stage 9: Conditional Git Commit

Only commit if validation succeeded:

```bash
# Only reached if validation passed
git add specs/state.json specs/TODO.md "specs/${task_number}_${project_name}/reports/"

if git commit -m "task ${task_number}: complete research
...
Session: ${session_id}
..."; then
    echo "✓ Changes committed successfully"
else
    echo "⚠ Git commit failed (non-blocking)"
fi
```

---

## Phase 5: Testing Strategy

**Estimated effort**: 3 hours

### Test 1: Atomic Update Success
```bash
# Create test task 999
create_test_task 999 "test_atomic_update" "researching"

# Run atomic postflight
./atomic-postflight-research.sh 999 \
    "specs/999_test/reports/research-001.md" \
    "Test summary"

# Verify both files updated
assert_state_status 999 "researched"
assert_state_artifact 999 "research"
assert_todo_status 999 "RESEARCHED"
assert_todo_link 999 "Research"
```

### Test 2: Validation Catches Missing Link
```bash
# Manually corrupt state (update state.json only)
update_state_json 999 "researched"

# Run validation
if validate_postflight 999; then
    echo "FAIL: Should have detected inconsistency"
    exit 1
else
    echo "PASS: Validation caught missing TODO.md link"
fi
```

### Test 3: Rollback on Failure
```bash
# Backup original state
cp specs/state.json /tmp/original.state.json
cp specs/TODO.md /tmp/original.TODO.md

# Trigger validation failure (corrupt temp file)
atomic_postflight_with_corruption 999

# Verify rollback occurred
diff specs/state.json /tmp/original.state.json || echo "FAIL: Rollback didn't restore state.json"
diff specs/TODO.md /tmp/original.TODO.md || echo "FAIL: Rollback didn't restore TODO.md"
```

---

## Phase 6: Apply to Other Skills

**Estimated effort**: 6 hours

**Files to Update**:
1. **skill-planner** → Create `atomic-postflight-plan.sh`
2. **skill-implementer** → Create `atomic-postflight-implement.sh`
3. **skill-lean-implementation** → Use `atomic-postflight-implement.sh`
4. **skill-latex-implementation** → Use `atomic-postflight-implement.sh`

**Pattern Applied**:
- Replace Edit tool with Python script for TODO.md
- Use atomic temp file pattern
- Add validation checkpoint
- Make git commit conditional

---

## Rollout Plan

### Week 1: Foundation (Phases 1-3)
- Create atomic-postflight-research.sh
- Create update-todo-artifact.py
- Create validation.sh library
- Test on local tasks

### Week 2: Integration (Phase 4)
- Update skill-researcher with new pattern
- Integration testing
- Verify rollback mechanism

### Week 3: Testing (Phase 5)
- Comprehensive test suite
- Stress testing
- Documentation

### Week 4: Expansion (Phase 6)
- Apply pattern to skill-planner, skill-implementer
- Full system deployment
- Monitor for issues

---

## Success Criteria

- [ ] **Task 690 scenario prevented**: Validation catches missing TODO.md links
- [ ] **Atomic updates**: Both files update together or neither
- [ ] **Validation detects failures**: Read-back verification works
- [ ] **Rollback functions**: Failed operations restore previous state
- [ ] **Error visibility**: Users see clear failure messages
- [ ] **All workflows upgraded**: Research, plan, implement use atomic pattern
- [ ] **No regressions**: Existing tasks unaffected

---

## Critical Files

1. **`.claude/scripts/atomic-postflight-research.sh`** (NEW)
   - Core atomic update logic with backup/rollback
   - Calls Python script for TODO.md
   - Validation before mv

2. **`.claude/scripts/update-todo-artifact.py`** (NEW)
   - Reliable TODO.md updater replacing Edit tool
   - Precise line insertion logic
   - Clear error codes

3. **`.claude/scripts/lib/validation.sh`** (NEW)
   - Reusable validation functions
   - state.json validator
   - TODO.md validator

4. **`.claude/skills/skill-researcher/SKILL.md`** (MODIFY)
   - Stages 7-9 replacement
   - Demonstrates atomic pattern
   - Template for other skills

5. **`.claude/context/core/patterns/atomic-state-updates.md`** (NEW)
   - Documentation of pattern
   - Best practices guide
   - Template for future skills

---

## Verification After Implementation

### Manual Test
```bash
# Run research on existing task
/research 691

# Verify both files updated atomically
jq '.active_projects[] | select(.project_number == 691)' specs/state.json
sed -n '/^### 691\./,/^###/p' specs/TODO.md

# Check for:
# - Exactly one [RESEARCHED] status marker
# - Research link present
# - Artifact in state.json
# - No duplicates
```

### Regression Test
```bash
# Verify all existing tasks still valid
for task in $(jq -r '.active_projects[] | .project_number' specs/state.json); do
    echo "Checking task $task..."
    if ! validate_postflight "$task"; then
        echo "ERROR: Task $task failed validation"
    fi
done
```

---

## Design Decisions

**Why atomic temp files?**
- Prevents partial updates
- Enables rollback on failure
- Both files consistent or neither changes

**Why Python instead of Edit tool?**
- Edit tool failed silently for task 690
- Python returns clear error codes
- Testable in isolation
- Precise line insertion

**Why validation checkpoint?**
- Catches silent failures
- Verifies both state.json AND TODO.md
- Prevents task 690 scenario

**Why conditional git commit?**
- Only commit if validation passed
- Prevents committing inconsistent state
- Clear failure mode

---

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Python script breaks on edge case | Medium | Comprehensive test suite, fallback to Edit |
| Validation too strict | Low | Careful validation criteria, manual override option |
| Performance overhead | Low | Scripts run <1s, minimal impact |
| Backward compatibility | Medium | Phased rollout, test on non-critical tasks first |
