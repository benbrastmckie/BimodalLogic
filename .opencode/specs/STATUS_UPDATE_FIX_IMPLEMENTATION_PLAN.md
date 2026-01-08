# Status Update & Artifact Linking Fix - Implementation Plan

**Project**: ProofChecker .opencode Agent System  
**Issue**: Inconsistent status updates and missing artifact links  
**Created**: 2026-01-07  
**Estimated Duration**: 11-17 hours (2-3 days)

---

## Executive Summary

### Problem Statement

The ProofChecker .opencode system has three critical issues:

1. **Status updates are inconsistent** - Tasks don't reliably transition through workflow states
2. **Artifacts are not linked** - Research reports and plans are created but not linked to TODO.md/state.json
3. **No enforcement of workflow stages** - Preflight and postflight sequences are documented but not executed

### Root Cause

**Command files delegate to subagents expecting them to handle status updates, but LLMs can skip or reorder the preflight/postflight steps in subagent specifications.**

The system relies on LLM instruction-following rather than enforced validation gates.

### Solution Strategy

**Move preflight/postflight responsibility from subagents to command files** where execution can be enforced through validation gates.

**Architecture Change**:
- **Before**: Commands → Subagents (with preflight/postflight in subagent specs)
- **After**: Commands (with preflight/postflight) → Subagents (core work only)

### Success Criteria

- ✅ 100% consistent status updates across all commands
- ✅ 100% artifact linking to TODO.md and state.json
- ✅ Validation gates prevent work without status updates
- ✅ Clear separation: Commands orchestrate, subagents execute
- ✅ Comprehensive test suite validates all workflows

---

## Phase 1: Add Preflight to /research Command

**Duration**: 1.5-2 hours  
**Goal**: Ensure status updates to [RESEARCHING] before research begins  
**File**: `.opencode/command/research.md`

### Current Architecture

```
Stage 1: ParseAndValidate
  ↓
Stage 2: Delegate (to researcher subagent)
  ↓
Stage 3: ValidateReturn
  ↓
Stage 4: RelayResult
```

### New Architecture

```
Stage 1: ParseAndValidate
  ↓
Stage 1.5: Preflight (NEW - update status to RESEARCHING)
  ↓
Stage 2: Delegate (to researcher subagent)
  ↓
Stage 3: ValidateReturn
  ↓
Stage 3.5: Postflight (Phase 2 - update status to RESEARCHED)
  ↓
Stage 4: RelayResult
```

### Implementation Steps

#### Step 1.1: Add Preflight Stage

**Location**: After `</stage>` closing tag of Stage 1 (around line 124)

**Insert this new stage**:

```xml
  <stage id="1.5" name="Preflight">
    <action>Update status to [RESEARCHING] before delegating to researcher</action>
    <process>
      1. Generate session_id for tracking:
         - session_id="sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')"
         - Store for later use: expected_session_id="$session_id"
      
      2. Delegate to status-sync-manager to update status:
         
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
      
      3. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Preflight failed: status-sync-manager returned ${sync_status}"
            - Extract error message: error_msg=$(echo "$sync_return" | jq -r '.errors[0].message')
            - Return error to user: "Failed to update status to RESEARCHING: ${error_msg}"
            - ABORT - do NOT proceed to Stage 2 (Delegate)
         d. Verify files_updated includes TODO.md and state.json:
            - files_updated=$(echo "$sync_return" | jq -r '.files_updated[]')
            - If TODO.md not in files_updated: Log warning
            - If state.json not in files_updated: Log warning
      
      4. Verify status was actually updated (defense in depth):
         
         Read state.json to check current status:
         actual_status=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
           .opencode/specs/state.json)
         
         If actual_status != "researching":
           - Log error: "Preflight verification failed"
           - Log: "Expected status: researching"
           - Log: "Actual status: ${actual_status}"
           - Return error to user: "Status update verification failed. Run /sync to fix state."
           - ABORT - do NOT proceed to Stage 2 (Delegate)
      
      5. Log preflight success:
         - Log: "Preflight completed: Task ${task_number} status updated to RESEARCHING"
         - Log: "Files updated: ${files_updated}"
         - Proceed to Stage 2 (Delegate)
    </process>
    <validation>
      - status-sync-manager returned "completed" status
      - TODO.md and state.json were updated
      - state.json status field verified as "researching"
    </validation>
    <checkpoint>Status verified as [RESEARCHING] before delegation to researcher</checkpoint>
  </stage>
```

#### Step 1.2: Update Stage 2 (Delegate) to Use session_id

**Location**: Stage 2 (around line 126-144)

**Modify the delegation to pass session_id**:

```xml
  <stage id="2" name="Delegate">
    <action>Delegate to researcher with parsed context</action>
    <process>
      1. Use session_id from Stage 1.5 (already generated)
         - session_id is already set from Preflight stage
      
      2. Invoke target agent via task tool:
         task(
           subagent_type="${target_agent}",
           prompt="Research task ${task_number}: ${description}. Focus: ${research_focus}",
           description="Research task ${task_number}",
           session_id="${session_id}"  # ADDED: Pass session_id to subagent
         )
      
      3. Wait for researcher to complete and capture return
         - Subagent returns JSON to stdout
         - Capture in variable: subagent_return
    </process>
    <checkpoint>Delegated to researcher, return captured</checkpoint>
  </stage>
```

#### Step 1.3: Test Preflight

**Test command**:
```bash
# Create a test task
/task "Test preflight status update" --language general --priority Medium

# Note the task number (e.g., 350)

# Run research command
/research 350

# Verify preflight execution:
# 1. Check state.json status changed to "researching" BEFORE research work begins
# 2. Check TODO.md status changed to [RESEARCHING]
# 3. Check for log message: "Preflight completed: Task 350 status updated to RESEARCHING"
```

**Expected behavior**:
- Status updates to [RESEARCHING] immediately
- If status update fails, command aborts with clear error
- Research work does NOT begin until status is verified

**Rollback if issues**:
```bash
# If preflight causes problems, revert the changes:
git checkout .opencode/command/research.md
```

---

## Phase 2: Add Postflight to /research Command

**Duration**: 2-3 hours  
**Goal**: Ensure status updates to [RESEARCHED] and artifacts are linked after research completes  
**File**: `.opencode/command/research.md`

### Implementation Steps

#### Step 2.1: Add Postflight Stage

**Location**: After `</stage>` closing tag of Stage 3 (ValidateReturn) (around line 251)

**Insert this new stage**:

```xml
  <stage id="3.5" name="Postflight">
    <action>Update status to [RESEARCHED], link artifacts, create git commit</action>
    <process>
      1. Extract artifacts from subagent return:
         
         Parse artifacts array from subagent return:
         artifacts_json=$(echo "$subagent_return" | jq -c '.artifacts')
         artifact_count=$(echo "$artifacts_json" | jq 'length')
         
         Log: "Subagent returned ${artifact_count} artifact(s)"
      
      2. Validate artifacts exist on disk (CRITICAL):
         
         For each artifact in artifacts array:
         for artifact_path in $(echo "$artifacts_json" | jq -r '.[].path'); do
           # Check file exists
           if [ ! -f "$artifact_path" ]; then
             echo "ERROR: Artifact not found on disk: $artifact_path"
             echo "Subagent claimed to create artifact but file does not exist"
             echo "This indicates a bug in the subagent"
             exit 1
           fi
           
           # Check file is non-empty
           if [ ! -s "$artifact_path" ]; then
             echo "ERROR: Artifact is empty: $artifact_path"
             echo "Subagent created file but wrote no content"
             exit 1
           fi
           
           # Get file size for logging
           file_size=$(stat -c%s "$artifact_path" 2>/dev/null || stat -f%z "$artifact_path")
           echo "Validated artifact: $artifact_path (${file_size} bytes)"
         done
         
         Log: "All ${artifact_count} artifact(s) validated on disk"
      
      3. Delegate to status-sync-manager to update status and link artifacts:
         
         INVOKE status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"researched\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"research\", \"status-sync-manager\"],
             \"validated_artifacts\": ${artifacts_json}
           }",
           description="Update task ${task_number} status to RESEARCHED and link artifacts"
         )
      
      4. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Postflight failed: status-sync-manager returned ${sync_status}"
            - Extract error message: error_msg=$(echo "$sync_return" | jq -r '.errors[0].message')
            - Log warning: "Research completed but status update failed: ${error_msg}"
            - Log: "Manual fix: /sync ${task_number}"
            - Continue (research work is done, just status update failed)
         d. Verify files_updated includes TODO.md and state.json
      
      5. Verify status and artifact links were actually updated (defense in depth):
         
         Read state.json to check current status:
         actual_status=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
           .opencode/specs/state.json)
         
         If actual_status != "researched":
           - Log warning: "Postflight verification failed - status not updated"
           - Log: "Expected status: researched"
           - Log: "Actual status: ${actual_status}"
           - Log: "Manual fix: /sync ${task_number}"
         
         Verify artifact links in TODO.md:
         for artifact_path in $(echo "$artifacts_json" | jq -r '.[].path'); do
           if ! grep -q "$artifact_path" .opencode/specs/TODO.md; then
             echo "WARNING: Artifact not linked in TODO.md: $artifact_path"
             echo "Manual fix: Edit TODO.md to add artifact link"
           else
             echo "Verified artifact link in TODO.md: $artifact_path"
           fi
         done
      
      6. Delegate to git-workflow-manager to create commit:
         
         Extract artifact paths for git commit:
         artifact_paths=$(echo "$artifacts_json" | jq -r '.[].path' | tr '\n' ' ')
         
         INVOKE git-workflow-manager via task tool:
         task(
           subagent_type="git-workflow-manager",
           prompt="{
             \"scope_files\": [${artifact_paths}, \".opencode/specs/TODO.md\", \".opencode/specs/state.json\"],
             \"message_template\": \"task ${task_number}: research completed\",
             \"task_context\": {
               \"task_number\": ${task_number},
               \"description\": \"research completed\"
             },
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"research\", \"git-workflow-manager\"]
           }",
           description="Create git commit for task ${task_number} research"
         )
      
      7. Validate git-workflow-manager return:
         a. Parse return as JSON
         b. Extract status field: git_status=$(echo "$git_return" | jq -r '.status')
         c. If git_status == "completed":
            - Extract commit hash: commit_hash=$(echo "$git_return" | jq -r '.commit_info.commit_hash')
            - Log: "Git commit created: ${commit_hash}"
         d. If git_status == "failed":
            - Log warning: "Git commit failed (non-critical)"
            - Extract error message: error_msg=$(echo "$git_return" | jq -r '.errors[0].message')
            - Log: "Git error: ${error_msg}"
            - Log: "Manual fix: git add . && git commit -m 'task ${task_number}: research completed'"
            - Continue (git failure doesn't fail the command)
      
      8. Log postflight success:
         - Log: "Postflight completed: Task ${task_number} status updated to RESEARCHED"
         - Log: "Artifacts linked: ${artifact_count}"
         - Log: "Git commit: ${commit_hash}"
         - Proceed to Stage 4 (RelayResult)
    </process>
    <validation>
      - All artifacts validated on disk before status update
      - status-sync-manager returned "completed" status
      - state.json status field verified as "researched"
      - Artifact links verified in TODO.md
      - Git commit created (or warning logged)
    </validation>
    <checkpoint>Status updated to [RESEARCHED], artifacts linked and verified, git commit created</checkpoint>
  </stage>
```

#### Step 2.2: Test Postflight

**Test command**:
```bash
# Use the test task from Phase 1
/research 350

# Verify postflight execution:
# 1. Check state.json status changed to "researched" AFTER research completes
# 2. Check TODO.md status changed to [RESEARCHED]
# 3. Check artifact link appears in TODO.md
# 4. Check artifact path in state.json artifacts array
# 5. Check git commit was created
# 6. Check for log message: "Postflight completed: Task 350 status updated to RESEARCHED"
```

**Verification steps**:
```bash
# 1. Check state.json
jq -r '.active_projects[] | select(.project_number == 350) | .status' .opencode/specs/state.json
# Expected: "researched"

# 2. Check TODO.md
grep -A 20 "^### 350\." .opencode/specs/TODO.md | grep -i researched
# Expected: - **Status**: [RESEARCHED]

# 3. Check artifact link in TODO.md
grep -A 20 "^### 350\." .opencode/specs/TODO.md | grep "reports/research"
# Expected: - **Research**: [Research Report](.opencode/specs/350_*/reports/research-001.md)

# 4. Check git log
git log -1 --oneline
# Expected: task 350: research completed
```

**Expected behavior**:
- Status updates to [RESEARCHED] after research completes
- Artifact link appears in TODO.md
- Git commit is created
- If any step fails, clear warning is logged

---

## Phase 3: Simplify Researcher Subagent

**Duration**: 1-2 hours  
**Goal**: Remove preflight/postflight from researcher subagent to avoid duplication  
**File**: `.opencode/agent/subagents/researcher.md`

### Current Architecture

Researcher subagent has:
- `step_0_preflight` (lines 140-210): Updates status to RESEARCHING
- `step_1_research_execution` (lines 212-248): Core research work
- `step_2_artifact_creation` (lines 250-298): Creates research report
- `step_3_validation` (lines 300-334): Validates artifact
- `step_4_postflight` (lines 336-454): Updates status to RESEARCHED, links artifacts, creates git commit
- `step_5_return` (lines 456-482): Returns standardized result

### New Architecture

Researcher subagent should have:
- `step_1_research_execution`: Core research work (KEEP)
- `step_2_artifact_creation`: Creates research report (KEEP)
- `step_3_validation`: Validates artifact (KEEP)
- `step_4_return`: Returns standardized result with artifacts (MODIFIED)

### Implementation Steps

#### Step 3.1: Remove step_0_preflight

**Location**: Lines 140-210

**Action**: Delete the entire `<step_0_preflight>` section

**Before**:
```xml
  <step_0_preflight>
    <action>Preflight: Extract validated inputs and update status to [RESEARCHING]</action>
    ...
  </step_0_preflight>
```

**After**: (section removed entirely)

#### Step 3.2: Remove step_4_postflight

**Location**: Lines 336-454

**Action**: Delete the entire `<step_4_postflight>` section

**Before**:
```xml
  <step_4_postflight>
    <action>Postflight: Update status to [RESEARCHED], link report, create git commit</action>
    ...
  </step_4_postflight>
```

**After**: (section removed entirely)

#### Step 3.3: Rename step_5_return to step_4_return

**Location**: Lines 456-482

**Action**: Rename the step and update references

**Before**:
```xml
  <step_5_return>
    <action>Return: Format and return standardized result</action>
```

**After**:
```xml
  <step_4_return>
    <action>Return: Format and return standardized result</action>
```

#### Step 3.4: Update Process Flow Documentation

**Location**: Lines 139 (start of `<process_flow>`)

**Action**: Update the process flow overview

**Before**:
```xml
<process_flow>
  <step_0_preflight>
  <step_1_research_execution>
  <step_2_artifact_creation>
  <step_3_validation>
  <step_4_postflight>
  <step_5_return>
</process_flow>
```

**After**:
```xml
<process_flow>
  <step_1_research_execution>
  <step_2_artifact_creation>
  <step_3_validation>
  <step_4_return>
  
  <note>
    Preflight and postflight are handled by the /research command file.
    This subagent focuses on core research work and artifact creation only.
  </note>
</process_flow>
```

#### Step 3.5: Update Constraints Section

**Location**: Lines 485-500

**Action**: Remove constraints about status updates

**Remove these constraints**:
```xml
<must>Invoke status-sync-manager for atomic status updates</must>
<must>Invoke git-workflow-manager for standardized commits</must>
<must>Use status transition: [NOT STARTED] → [RESEARCHING] → [RESEARCHED]</must>
```

**Add this constraint**:
```xml
<must>Return artifacts array with validated artifact paths for command file to link</must>
```

#### Step 3.6: Test Simplified Researcher

**Test command**:
```bash
# Create a new test task
/task "Test simplified researcher" --language general --priority Medium

# Run research command (which now handles preflight/postflight)
/research 351

# Verify:
# 1. Research completes successfully
# 2. Status updates correctly (handled by command file)
# 3. Artifacts are linked (handled by command file)
# 4. Git commit is created (handled by command file)
```

**Expected behavior**:
- Researcher focuses on research work only
- Command file handles all status updates and linking
- No duplication of preflight/postflight logic

---

## Phase 4: Add Preflight/Postflight to /plan Command

**Duration**: 2-3 hours  
**Goal**: Ensure status updates to [PLANNING] → [PLANNED] and plan is linked  
**File**: `.opencode/command/plan.md`

### Implementation Steps

#### Step 4.1: Add Preflight Stage

**Location**: After `</stage>` closing tag of Stage 1 (ParseAndValidate) (around line 124)

**Insert this new stage**:

```xml
  <stage id="1.5" name="Preflight">
    <action>Update status to [PLANNING] before delegating to planner</action>
    <process>
      1. Generate session_id for tracking:
         - session_id="sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')"
         - Store for later use: expected_session_id="$session_id"
      
      2. Delegate to status-sync-manager to update status:
         
         INVOKE status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"planning\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"plan\", \"status-sync-manager\"]
           }",
           description="Update task ${task_number} status to PLANNING"
         )
      
      3. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Preflight failed: status-sync-manager returned ${sync_status}"
            - Extract error message: error_msg=$(echo "$sync_return" | jq -r '.errors[0].message')
            - Return error to user: "Failed to update status to PLANNING: ${error_msg}"
            - ABORT - do NOT proceed to Stage 2 (Delegate)
         d. Verify files_updated includes TODO.md and state.json
      
      4. Verify status was actually updated (defense in depth):
         
         Read state.json to check current status:
         actual_status=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
           .opencode/specs/state.json)
         
         If actual_status != "planning":
           - Log error: "Preflight verification failed"
           - Log: "Expected status: planning"
           - Log: "Actual status: ${actual_status}"
           - Return error to user: "Status update verification failed. Run /sync to fix state."
           - ABORT - do NOT proceed to Stage 2 (Delegate)
      
      5. Log preflight success:
         - Log: "Preflight completed: Task ${task_number} status updated to PLANNING"
         - Proceed to Stage 2 (Delegate)
    </process>
    <validation>
      - status-sync-manager returned "completed" status
      - TODO.md and state.json were updated
      - state.json status field verified as "planning"
    </validation>
    <checkpoint>Status verified as [PLANNING] before delegation to planner</checkpoint>
  </stage>
```

#### Step 4.2: Add Postflight Stage

**Location**: After `</stage>` closing tag of Stage 3 (ValidateReturn) (around line 251)

**Insert this new stage**:

```xml
  <stage id="3.5" name="Postflight">
    <action>Update status to [PLANNED], link plan, store plan_metadata, create git commit</action>
    <process>
      1. Extract artifacts and plan_metadata from subagent return:
         
         Parse artifacts array:
         artifacts_json=$(echo "$subagent_return" | jq -c '.artifacts')
         artifact_count=$(echo "$artifacts_json" | jq 'length')
         
         Parse plan_metadata:
         plan_metadata=$(echo "$subagent_return" | jq -c '.plan_metadata // {}')
         
         Extract plan path (should be first artifact):
         plan_path=$(echo "$artifacts_json" | jq -r '.[0].path')
         
         Log: "Subagent returned plan: ${plan_path}"
         Log: "Plan metadata: ${plan_metadata}"
      
      2. Validate plan exists on disk (CRITICAL):
         
         if [ ! -f "$plan_path" ]; then
           echo "ERROR: Plan not found on disk: $plan_path"
           echo "Subagent claimed to create plan but file does not exist"
           exit 1
         fi
         
         if [ ! -s "$plan_path" ]; then
           echo "ERROR: Plan is empty: $plan_path"
           echo "Subagent created file but wrote no content"
           exit 1
         fi
         
         file_size=$(stat -c%s "$plan_path" 2>/dev/null || stat -f%z "$plan_path")
         echo "Validated plan: $plan_path (${file_size} bytes)"
      
      3. Delegate to status-sync-manager to update status, link plan, and store metadata:
         
         INVOKE status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"planned\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"plan\", \"status-sync-manager\"],
             \"validated_artifacts\": ${artifacts_json},
             \"plan_path\": \"${plan_path}\",
             \"plan_metadata\": ${plan_metadata}
           }",
           description="Update task ${task_number} status to PLANNED and link plan"
         )
      
      4. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Postflight failed: status-sync-manager returned ${sync_status}"
            - Extract error message: error_msg=$(echo "$sync_return" | jq -r '.errors[0].message')
            - Log warning: "Planning completed but status update failed: ${error_msg}"
            - Log: "Manual fix: /sync ${task_number}"
            - Continue (planning work is done, just status update failed)
         d. Verify files_updated includes TODO.md and state.json
      
      5. Verify status and plan link were actually updated (defense in depth):
         
         Read state.json to check current status:
         actual_status=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
           .opencode/specs/state.json)
         
         If actual_status != "planned":
           - Log warning: "Postflight verification failed - status not updated"
           - Log: "Expected status: planned"
           - Log: "Actual status: ${actual_status}"
           - Log: "Manual fix: /sync ${task_number}"
         
         Verify plan link in TODO.md:
         if ! grep -q "$plan_path" .opencode/specs/TODO.md; then
           echo "WARNING: Plan not linked in TODO.md: $plan_path"
           echo "Manual fix: Edit TODO.md to add plan link"
         else
           echo "Verified plan link in TODO.md: $plan_path"
         fi
         
         Verify plan_metadata in state.json:
         stored_metadata=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .plan_metadata' \
           .opencode/specs/state.json)
         
         if [ "$stored_metadata" == "null" ] || [ -z "$stored_metadata" ]; then
           echo "WARNING: plan_metadata not stored in state.json"
         else
           echo "Verified plan_metadata in state.json"
         fi
      
      6. Delegate to git-workflow-manager to create commit:
         
         INVOKE git-workflow-manager via task tool:
         task(
           subagent_type="git-workflow-manager",
           prompt="{
             \"scope_files\": [\"${plan_path}\", \".opencode/specs/TODO.md\", \".opencode/specs/state.json\"],
             \"message_template\": \"task ${task_number}: plan created\",
             \"task_context\": {
               \"task_number\": ${task_number},
               \"description\": \"plan created\"
             },
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"plan\", \"git-workflow-manager\"]
           }",
           description="Create git commit for task ${task_number} plan"
         )
      
      7. Validate git-workflow-manager return:
         a. Parse return as JSON
         b. Extract status field: git_status=$(echo "$git_return" | jq -r '.status')
         c. If git_status == "completed":
            - Extract commit hash: commit_hash=$(echo "$git_return" | jq -r '.commit_info.commit_hash')
            - Log: "Git commit created: ${commit_hash}"
         d. If git_status == "failed":
            - Log warning: "Git commit failed (non-critical)"
            - Continue (git failure doesn't fail the command)
      
      8. Log postflight success:
         - Log: "Postflight completed: Task ${task_number} status updated to PLANNED"
         - Log: "Plan linked: ${plan_path}"
         - Log: "Plan metadata stored"
         - Log: "Git commit: ${commit_hash}"
         - Proceed to Stage 4 (RelayResult)
    </process>
    <validation>
      - Plan validated on disk before status update
      - status-sync-manager returned "completed" status
      - state.json status field verified as "planned"
      - Plan link verified in TODO.md
      - plan_metadata verified in state.json
      - Git commit created (or warning logged)
    </validation>
    <checkpoint>Status updated to [PLANNED], plan linked and verified, metadata stored, git commit created</checkpoint>
  </stage>
```

#### Step 4.3: Simplify Planner Subagent

**File**: `.opencode/agent/subagents/planner.md`

**Actions**:
1. Remove `step_0_preflight` (lines 95-168)
2. Remove `step_7` postflight (lines 410-500+)
3. Rename remaining steps to be sequential (step_1 through step_6)
4. Update `step_6` (formerly step_6) to return plan_metadata in return object

**Add to step_6 return**:
```xml
<step_6_return>
  <action>Return: Format and return standardized result with plan_metadata</action>
  <process>
    1. Format return following subagent-return-format.md:
       - status: "completed"
       - summary: "Implementation plan created with {phase_count} phases"
       - artifacts: [{type: "plan", path, summary}]
       - plan_metadata: {
           phase_count: {N},
           estimated_hours: {H},
           complexity: "{simple|medium|complex}",
           research_integrated: {true|false},
           reports_integrated: [{path, integrated_in_plan_version, integrated_date}]
         }
       - metadata: {session_id, duration_seconds, agent_type, delegation_depth, delegation_path}
    2. Return standardized result
  </process>
</step_6_return>
```

#### Step 4.4: Test /plan Command

**Test command**:
```bash
# Use the researched task from Phase 2
/plan 350

# Verify:
# 1. Status changes: RESEARCHED → PLANNING → PLANNED
# 2. Plan created in .opencode/specs/350_*/plans/implementation-001.md
# 3. Plan linked in TODO.md
# 4. plan_path in state.json
# 5. plan_metadata in state.json (phase_count, estimated_hours, etc.)
# 6. Git commit created
```

**Verification steps**:
```bash
# 1. Check state.json status
jq -r '.active_projects[] | select(.project_number == 350) | .status' .opencode/specs/state.json
# Expected: "planned"

# 2. Check plan file exists
find .opencode/specs -name "implementation-001.md" -path "*/350_*/plans/*"
# Expected: .opencode/specs/350_*/plans/implementation-001.md

# 3. Check plan link in TODO.md
grep -A 20 "^### 350\." .opencode/specs/TODO.md | grep "implementation-001.md"
# Expected: - **Plan**: [Implementation Plan](.opencode/specs/350_*/plans/implementation-001.md)

# 4. Check plan_metadata in state.json
jq -r '.active_projects[] | select(.project_number == 350) | .plan_metadata' .opencode/specs/state.json
# Expected: {"phase_count": N, "estimated_hours": H, ...}

# 5. Check git log
git log -1 --oneline
# Expected: task 350: plan created
```

---

## Phase 5: Add Preflight/Postflight to /revise Command

**Duration**: 2-3 hours  
**Goal**: Ensure status updates to [REVISING] → [REVISED] and new plan version is linked  
**File**: `.opencode/command/revise.md`

### Special Considerations

The `/revise` command has **dual-mode routing**:
- **Mode 1**: Task-only revision (no plan exists) → routes to `task-reviser`
- **Mode 2**: Plan revision (plan exists) → routes to `planner` or `lean-planner`

Preflight/postflight must handle both modes.

### Implementation Steps

#### Step 5.1: Add Preflight Stage

**Location**: After `</stage>` closing tag of Stage 1 (ParseAndValidate) (around line 138)

**Insert this new stage**:

```xml
  <stage id="1.5" name="Preflight">
    <action>Update status to [REVISING] before delegating</action>
    <process>
      1. Generate session_id for tracking:
         - session_id="sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')"
         - Store for later use: expected_session_id="$session_id"
      
      2. Delegate to status-sync-manager to update status:
         
         INVOKE status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"revising\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"revise\", \"status-sync-manager\"]
           }",
           description="Update task ${task_number} status to REVISING"
         )
      
      3. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Preflight failed: status-sync-manager returned ${sync_status}"
            - Extract error message: error_msg=$(echo "$sync_return" | jq -r '.errors[0].message')
            - Return error to user: "Failed to update status to REVISING: ${error_msg}"
            - ABORT - do NOT proceed to Stage 2 (Delegate)
         d. Verify files_updated includes TODO.md and state.json
      
      4. Verify status was actually updated (defense in depth):
         
         Read state.json to check current status:
         actual_status=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
           .opencode/specs/state.json)
         
         If actual_status != "revising":
           - Log error: "Preflight verification failed"
           - Log: "Expected status: revising"
           - Log: "Actual status: ${actual_status}"
           - Return error to user: "Status update verification failed. Run /sync to fix state."
           - ABORT - do NOT proceed to Stage 2 (Delegate)
      
      5. Log preflight success:
         - Log: "Preflight completed: Task ${task_number} status updated to REVISING"
         - Proceed to Stage 2 (Delegate)
    </process>
    <validation>
      - status-sync-manager returned "completed" status
      - TODO.md and state.json were updated
      - state.json status field verified as "revising"
    </validation>
    <checkpoint>Status verified as [REVISING] before delegation</checkpoint>
  </stage>
```

#### Step 5.2: Add Postflight Stage (Dual-Mode)

**Location**: After `</stage>` closing tag of Stage 3 (ValidateReturn) (around line 289)

**Insert this new stage**:

```xml
  <stage id="3.5" name="Postflight">
    <action>Update status to [REVISED], link new plan version (if plan revision), create git commit</action>
    <process>
      1. Determine routing mode from Stage 1:
         - routing_mode was set in Stage 1 (task-only or plan-revision)
         - Use routing_mode to determine postflight actions
      
      2. Extract artifacts from subagent return:
         
         Parse artifacts array:
         artifacts_json=$(echo "$subagent_return" | jq -c '.artifacts')
         artifact_count=$(echo "$artifacts_json" | jq 'length')
         
         Log: "Subagent returned ${artifact_count} artifact(s)"
      
      3. Validate artifacts exist on disk:
         
         for artifact_path in $(echo "$artifacts_json" | jq -r '.[].path'); do
           if [ ! -f "$artifact_path" ]; then
             echo "ERROR: Artifact not found on disk: $artifact_path"
             exit 1
           fi
           if [ ! -s "$artifact_path" ]; then
             echo "ERROR: Artifact is empty: $artifact_path"
             exit 1
           fi
           file_size=$(stat -c%s "$artifact_path" 2>/dev/null || stat -f%z "$artifact_path")
           echo "Validated artifact: $artifact_path (${file_size} bytes)"
         done
      
      4. Prepare delegation context based on routing mode:
         
         if [ "$routing_mode" == "plan-revision" ]; then
           # Plan revision mode: extract plan_metadata and plan_version
           plan_metadata=$(echo "$subagent_return" | jq -c '.plan_metadata // {}')
           plan_version=$(echo "$subagent_return" | jq -r '.plan_version // 2')
           revision_reason=$(echo "$custom_prompt" | head -c 200)  # From Stage 1
           
           delegation_context="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"revised\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"revise\", \"status-sync-manager\"],
             \"validated_artifacts\": ${artifacts_json},
             \"plan_path\": \"$(echo "$artifacts_json" | jq -r '.[0].path')\",
             \"plan_metadata\": ${plan_metadata},
             \"plan_version\": ${plan_version},
             \"revision_reason\": \"${revision_reason}\"
           }"
         else
           # Task-only revision mode: just update status
           delegation_context="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"revised\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"revise\", \"status-sync-manager\"]
           }"
         fi
      
      5. Delegate to status-sync-manager:
         
         INVOKE status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="${delegation_context}",
           description="Update task ${task_number} status to REVISED"
         )
      
      6. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Postflight failed: status-sync-manager returned ${sync_status}"
            - Log warning: "Revision completed but status update failed"
            - Log: "Manual fix: /sync ${task_number}"
            - Continue (revision work is done, just status update failed)
         d. Verify files_updated includes TODO.md and state.json
      
      7. Verify status and artifact links were actually updated:
         
         Read state.json to check current status:
         actual_status=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
           .opencode/specs/state.json)
         
         If actual_status != "revised":
           - Log warning: "Postflight verification failed - status not updated"
           - Log: "Expected status: revised"
           - Log: "Actual status: ${actual_status}"
           - Log: "Manual fix: /sync ${task_number}"
         
         if [ "$routing_mode" == "plan-revision" ]; then
           # Verify new plan version linked in TODO.md
           new_plan_path=$(echo "$artifacts_json" | jq -r '.[0].path')
           if ! grep -q "$new_plan_path" .opencode/specs/TODO.md; then
             echo "WARNING: New plan version not linked in TODO.md: $new_plan_path"
           else
             echo "Verified new plan version linked in TODO.md: $new_plan_path"
           fi
           
           # Verify plan_versions array updated in state.json
           plan_versions=$(jq -r --arg num "$task_number" \
             '.active_projects[] | select(.project_number == ($num | tonumber)) | .plan_versions | length' \
             .opencode/specs/state.json)
           echo "Plan versions in state.json: ${plan_versions}"
         fi
      
      8. Delegate to git-workflow-manager:
         
         Extract artifact paths for git commit:
         artifact_paths=$(echo "$artifacts_json" | jq -r '.[].path' | tr '\n' ' ')
         
         INVOKE git-workflow-manager via task tool:
         task(
           subagent_type="git-workflow-manager",
           prompt="{
             \"scope_files\": [${artifact_paths}, \".opencode/specs/TODO.md\", \".opencode/specs/state.json\"],
             \"message_template\": \"task ${task_number}: revision completed\",
             \"task_context\": {
               \"task_number\": ${task_number},
               \"description\": \"revision completed\"
             },
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"revise\", \"git-workflow-manager\"]
           }",
           description="Create git commit for task ${task_number} revision"
         )
      
      9. Validate git-workflow-manager return:
         a. Parse return as JSON
         b. Extract status field: git_status=$(echo "$git_return" | jq -r '.status')
         c. If git_status == "completed":
            - Extract commit hash: commit_hash=$(echo "$git_return" | jq -r '.commit_info.commit_hash')
            - Log: "Git commit created: ${commit_hash}"
         d. If git_status == "failed":
            - Log warning: "Git commit failed (non-critical)"
            - Continue
      
      10. Log postflight success:
          - Log: "Postflight completed: Task ${task_number} status updated to REVISED"
          - if [ "$routing_mode" == "plan-revision" ]; then
              Log: "New plan version linked: ${new_plan_path}"
              Log: "Plan version: ${plan_version}"
            fi
          - Log: "Git commit: ${commit_hash}"
          - Proceed to Stage 4 (RelayResult)
    </process>
    <validation>
      - Artifacts validated on disk before status update
      - status-sync-manager returned "completed" status
      - state.json status field verified as "revised"
      - If plan revision: new plan version linked in TODO.md
      - If plan revision: plan_versions array updated in state.json
      - Git commit created (or warning logged)
    </validation>
    <checkpoint>Status updated to [REVISED], artifacts linked and verified, git commit created</checkpoint>
  </stage>
```

#### Step 5.3: Test /revise Command (Both Modes)

**Test Mode 1: Task-only revision (no plan)**:
```bash
# Create a task without a plan
/task "Test task-only revision" --language general --priority Medium
# Note task number (e.g., 352)

# Revise task metadata
/revise 352

# Verify:
# 1. Status changes: NOT STARTED → REVISING → REVISED
# 2. Routes to task-reviser (not planner)
# 3. Prompts for metadata changes
# 4. Updates TODO.md and state.json
# 5. Git commit created
```

**Test Mode 2: Plan revision (plan exists)**:
```bash
# Use the planned task from Phase 4
/revise 350 "Simplify phase breakdown from 5 phases to 3 phases"

# Verify:
# 1. Status changes: PLANNED → REVISING → REVISED
# 2. Routes to planner (not task-reviser)
# 3. New plan version created: implementation-002.md
# 4. Old plan preserved: implementation-001.md
# 5. Plan link in TODO.md updated to version 002
# 6. plan_versions array in state.json has 2 entries
# 7. Git commit created
```

**Verification steps for plan revision**:
```bash
# 1. Check both plan versions exist
ls -la .opencode/specs/350_*/plans/
# Expected: implementation-001.md and implementation-002.md

# 2. Check plan link in TODO.md points to version 002
grep -A 20 "^### 350\." .opencode/specs/TODO.md | grep "implementation-"
# Expected: - **Plan**: [Implementation Plan](.opencode/specs/350_*/plans/implementation-002.md)

# 3. Check plan_versions array in state.json
jq -r '.active_projects[] | select(.project_number == 350) | .plan_versions' .opencode/specs/state.json
# Expected: [{"version": 1, "path": "...", ...}, {"version": 2, "path": "...", ...}]

# 4. Check git log
git log -1 --oneline
# Expected: task 350: revision completed
```

---

## Phase 6: Add Preflight/Postflight to /implement Command

**Duration**: 3-4 hours  
**Goal**: Ensure status updates to [IMPLEMENTING] → [COMPLETED] and phase statuses are updated  
**File**: `.opencode/command/implement.md`

### Special Considerations

The `/implement` command has additional complexity:
- May update **plan file phase statuses** (if plan exists)
- May create **multiple artifacts** (implementation files)
- Final status is **[COMPLETED]** (terminal state)

### Implementation Steps

#### Step 6.1: Add Preflight Stage

**Location**: After `</stage>` closing tag of Stage 1 (ParseAndValidate) (around line 119)

**Insert this new stage**:

```xml
  <stage id="1.5" name="Preflight">
    <action>Update status to [IMPLEMENTING] before delegating to implementer</action>
    <process>
      1. Generate session_id for tracking:
         - session_id="sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')"
         - Store for later use: expected_session_id="$session_id"
      
      2. Delegate to status-sync-manager to update status:
         
         INVOKE status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"implementing\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"implement\", \"status-sync-manager\"]
           }",
           description="Update task ${task_number} status to IMPLEMENTING"
         )
      
      3. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Preflight failed: status-sync-manager returned ${sync_status}"
            - Extract error message: error_msg=$(echo "$sync_return" | jq -r '.errors[0].message')
            - Return error to user: "Failed to update status to IMPLEMENTING: ${error_msg}"
            - ABORT - do NOT proceed to Stage 2 (Delegate)
         d. Verify files_updated includes TODO.md and state.json
      
      4. Verify status was actually updated (defense in depth):
         
         Read state.json to check current status:
         actual_status=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
           .opencode/specs/state.json)
         
         If actual_status != "implementing":
           - Log error: "Preflight verification failed"
           - Log: "Expected status: implementing"
           - Log: "Actual status: ${actual_status}"
           - Return error to user: "Status update verification failed. Run /sync to fix state."
           - ABORT - do NOT proceed to Stage 2 (Delegate)
      
      5. Log preflight success:
         - Log: "Preflight completed: Task ${task_number} status updated to IMPLEMENTING"
         - Proceed to Stage 2 (Delegate)
    </process>
    <validation>
      - status-sync-manager returned "completed" status
      - TODO.md and state.json were updated
      - state.json status field verified as "implementing"
    </validation>
    <checkpoint>Status verified as [IMPLEMENTING] before delegation to implementer</checkpoint>
  </stage>
```

#### Step 6.2: Add Postflight Stage (with Phase Updates)

**Location**: After `</stage>` closing tag of Stage 3 (ValidateReturn) (around line 246)

**Insert this new stage**:

```xml
  <stage id="3.5" name="Postflight">
    <action>Update status to [COMPLETED], link artifacts, update plan phases, create git commit</action>
    <process>
      1. Extract artifacts and phase_statuses from subagent return:
         
         Parse artifacts array:
         artifacts_json=$(echo "$subagent_return" | jq -c '.artifacts')
         artifact_count=$(echo "$artifacts_json" | jq 'length')
         
         Parse phase_statuses (if plan-based implementation):
         phase_statuses=$(echo "$subagent_return" | jq -c '.phase_statuses // []')
         phase_count=$(echo "$phase_statuses" | jq 'length')
         
         Log: "Subagent returned ${artifact_count} artifact(s)"
         if [ "$phase_count" -gt 0 ]; then
           Log: "Subagent returned ${phase_count} phase status update(s)"
         fi
      
      2. Validate artifacts exist on disk (CRITICAL):
         
         for artifact_path in $(echo "$artifacts_json" | jq -r '.[].path'); do
           if [ ! -f "$artifact_path" ]; then
             echo "ERROR: Artifact not found on disk: $artifact_path"
             echo "Subagent claimed to create artifact but file does not exist"
             exit 1
           fi
           if [ ! -s "$artifact_path" ]; then
             echo "ERROR: Artifact is empty: $artifact_path"
             echo "Subagent created file but wrote no content"
             exit 1
           fi
           file_size=$(stat -c%s "$artifact_path" 2>/dev/null || stat -f%z "$artifact_path")
           echo "Validated artifact: $artifact_path (${file_size} bytes)"
         done
      
      3. Extract plan_path from state.json (if plan exists):
         
         plan_path=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .plan_path // ""' \
           .opencode/specs/state.json)
         
         if [ -n "$plan_path" ] && [ "$plan_path" != "null" ]; then
           has_plan=true
           Log: "Task has plan: ${plan_path}"
         else
           has_plan=false
           Log: "Task has no plan (direct implementation)"
         fi
      
      4. Prepare delegation context with phase updates (if applicable):
         
         if [ "$has_plan" == "true" ] && [ "$phase_count" -gt 0 ]; then
           # Plan-based implementation with phase updates
           delegation_context="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"completed\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"implement\", \"status-sync-manager\"],
             \"validated_artifacts\": ${artifacts_json},
             \"plan_path\": \"${plan_path}\",
             \"phase_statuses\": ${phase_statuses}
           }"
         else
           # Direct implementation (no plan) or no phase updates
           delegation_context="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"completed\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"implement\", \"status-sync-manager\"],
             \"validated_artifacts\": ${artifacts_json}
           }"
         fi
      
      5. Delegate to status-sync-manager:
         
         INVOKE status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="${delegation_context}",
           description="Update task ${task_number} status to COMPLETED and link artifacts"
         )
      
      6. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Postflight failed: status-sync-manager returned ${sync_status}"
            - Extract error message: error_msg=$(echo "$sync_return" | jq -r '.errors[0].message')
            - Log warning: "Implementation completed but status update failed: ${error_msg}"
            - Log: "Manual fix: /sync ${task_number}"
            - Continue (implementation work is done, just status update failed)
         d. Verify files_updated includes TODO.md and state.json
         e. If has_plan and phase_count > 0:
            - Verify files_updated includes plan_path
      
      7. Verify status and artifact links were actually updated (defense in depth):
         
         Read state.json to check current status:
         actual_status=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
           .opencode/specs/state.json)
         
         If actual_status != "completed":
           - Log warning: "Postflight verification failed - status not updated"
           - Log: "Expected status: completed"
           - Log: "Actual status: ${actual_status}"
           - Log: "Manual fix: /sync ${task_number}"
         
         Verify artifact links in TODO.md:
         for artifact_path in $(echo "$artifacts_json" | jq -r '.[].path'); do
           if ! grep -q "$artifact_path" .opencode/specs/TODO.md; then
             echo "WARNING: Artifact not linked in TODO.md: $artifact_path"
           else
             echo "Verified artifact link in TODO.md: $artifact_path"
           fi
         done
         
         If has_plan and phase_count > 0:
           # Verify phase statuses were updated in plan file
           for phase_update in $(echo "$phase_statuses" | jq -c '.[]'); do
             phase_number=$(echo "$phase_update" | jq -r '.phase_number')
             phase_status=$(echo "$phase_update" | jq -r '.status')
             
             # Check plan file for updated phase marker
             if grep -q "### Phase ${phase_number}:.*\[${phase_status^^}\]" "$plan_path"; then
               echo "Verified phase ${phase_number} status updated to ${phase_status} in plan"
             else
               echo "WARNING: Phase ${phase_number} status not updated in plan file"
             fi
           done
      
      8. Delegate to git-workflow-manager to create commit:
         
         Extract artifact paths for git commit:
         artifact_paths=$(echo "$artifacts_json" | jq -r '.[].path' | tr '\n' ' ')
         
         # Include plan file in commit if it was updated
         if [ "$has_plan" == "true" ] && [ "$phase_count" -gt 0 ]; then
           scope_files="${artifact_paths} ${plan_path} .opencode/specs/TODO.md .opencode/specs/state.json"
         else
           scope_files="${artifact_paths} .opencode/specs/TODO.md .opencode/specs/state.json"
         fi
         
         INVOKE git-workflow-manager via task tool:
         task(
           subagent_type="git-workflow-manager",
           prompt="{
             \"scope_files\": [${scope_files}],
             \"message_template\": \"task ${task_number}: implementation completed\",
             \"task_context\": {
               \"task_number\": ${task_number},
               \"description\": \"implementation completed\"
             },
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"implement\", \"git-workflow-manager\"]
           }",
           description="Create git commit for task ${task_number} implementation"
         )
      
      9. Validate git-workflow-manager return:
         a. Parse return as JSON
         b. Extract status field: git_status=$(echo "$git_return" | jq -r '.status')
         c. If git_status == "completed":
            - Extract commit hash: commit_hash=$(echo "$git_return" | jq -r '.commit_info.commit_hash')
            - Log: "Git commit created: ${commit_hash}"
         d. If git_status == "failed":
            - Log warning: "Git commit failed (non-critical)"
            - Continue (git failure doesn't fail the command)
      
      10. Log postflight success:
          - Log: "Postflight completed: Task ${task_number} status updated to COMPLETED"
          - Log: "Artifacts linked: ${artifact_count}"
          - if [ "$has_plan" == "true" ] && [ "$phase_count" -gt 0 ]; then
              Log: "Plan phases updated: ${phase_count}"
            fi
          - Log: "Git commit: ${commit_hash}"
          - Proceed to Stage 4 (RelayResult)
    </process>
    <validation>
      - All artifacts validated on disk before status update
      - status-sync-manager returned "completed" status
      - state.json status field verified as "completed"
      - Artifact links verified in TODO.md
      - If plan exists: phase statuses verified in plan file
      - Git commit created (or warning logged)
    </validation>
    <checkpoint>Status updated to [COMPLETED], artifacts linked and verified, plan phases updated (if applicable), git commit created</checkpoint>
  </stage>
```

#### Step 6.3: Simplify Implementer Subagents

**Files**:
- `.opencode/agent/subagents/implementer.md`
- `.opencode/agent/subagents/lean-implementation-agent.md`

**Actions**:
1. Remove preflight stages (status update to IMPLEMENTING)
2. Remove postflight stages (status update to COMPLETED, git commits)
3. Keep core implementation logic
4. Update return to include `phase_statuses` array (if plan-based)

**Add to return object**:
```xml
<return>
  <process>
    1. Format return following subagent-return-format.md:
       - status: "completed"
       - summary: "Implementation completed"
       - artifacts: [{type, path, summary}]
       - phase_statuses: [
           {phase_number: 1, status: "completed", timestamp: "YYYY-MM-DD"},
           {phase_number: 2, status: "completed", timestamp: "YYYY-MM-DD"}
         ]  # Only if plan-based implementation
       - metadata: {session_id, duration_seconds, agent_type, delegation_depth, delegation_path}
    2. Return standardized result
  </process>
</return>
```

#### Step 6.4: Test /implement Command

**Test plan-based implementation**:
```bash
# Use the planned task from Phase 4
/implement 350

# Verify:
# 1. Status changes: PLANNED → IMPLEMENTING → COMPLETED
# 2. Implementation artifacts created
# 3. Artifacts linked in TODO.md
# 4. Plan file phase statuses updated to [COMPLETED]
# 5. Git commit created
```

**Verification steps**:
```bash
# 1. Check state.json status
jq -r '.active_projects[] | select(.project_number == 350) | .status' .opencode/specs/state.json
# Expected: "completed"

# 2. Check TODO.md status
grep -A 20 "^### 350\." .opencode/specs/TODO.md | grep -i status
# Expected: - **Status**: [COMPLETED]

# 3. Check implementation artifacts linked
grep -A 30 "^### 350\." .opencode/specs/TODO.md | grep -i implementation
# Expected: artifact links

# 4. Check plan file phase statuses
cat .opencode/specs/350_*/plans/implementation-*.md | grep "### Phase"
# Expected: All phases marked [COMPLETED]

# 5. Check git log
git log -1 --oneline
# Expected: task 350: implementation completed
```

**Test direct implementation (no plan)**:
```bash
# Create a simple task without planning
/task "Simple direct implementation test" --language general --priority Low
# Note task number (e.g., 353)

# Implement directly without planning
/implement 353

# Verify:
# 1. Status changes: NOT STARTED → IMPLEMENTING → COMPLETED
# 2. Implementation artifacts created
# 3. Artifacts linked in TODO.md
# 4. No plan file updates (no plan exists)
# 5. Git commit created
```

---

## Phase 7: Comprehensive Testing

**Duration**: 2-3 hours  
**Goal**: Verify all commands work correctly with new validation gates

### Test Suite

#### Test 7.1: End-to-End Workflow

**Test the complete workflow from task creation to completion**:

```bash
# Step 1: Create task
/task "End-to-end workflow test" --language lean --priority High
# Note task number (e.g., 354)

# Verify task creation:
jq -r '.active_projects[] | select(.project_number == 354)' .opencode/specs/state.json
# Expected: status: "not_started", language: "lean", priority: "high"

# Step 2: Research
/research 354

# Verify research:
jq -r '.active_projects[] | select(.project_number == 354) | .status' .opencode/specs/state.json
# Expected: "researched"
grep -A 30 "^### 354\." .opencode/specs/TODO.md | grep "research-001.md"
# Expected: Research report link

# Step 3: Plan
/plan 354

# Verify planning:
jq -r '.active_projects[] | select(.project_number == 354) | .status' .opencode/specs/state.json
# Expected: "planned"
grep -A 30 "^### 354\." .opencode/specs/TODO.md | grep "implementation-001.md"
# Expected: Plan link

# Step 4: Revise plan
/revise 354 "Adjust phase breakdown"

# Verify revision:
jq -r '.active_projects[] | select(.project_number == 354) | .status' .opencode/specs/state.json
# Expected: "revised"
grep -A 30 "^### 354\." .opencode/specs/TODO.md | grep "implementation-002.md"
# Expected: New plan version link

# Step 5: Implement
/implement 354

# Verify implementation:
jq -r '.active_projects[] | select(.project_number == 354) | .status' .opencode/specs/state.json
# Expected: "completed"
grep -A 30 "^### 354\." .opencode/specs/TODO.md | grep -i completed
# Expected: [COMPLETED] status
```

#### Test 7.2: Error Handling

**Test preflight failure (invalid status transition)**:

```bash
# Create a completed task
/task "Test error handling" --language general --priority Medium
# Note task number (e.g., 355)

# Complete the task
/implement 355

# Try to research a completed task (should fail)
/research 355

# Expected error:
# "Error: Task 355 already completed"
# "Recommendation: Task is done, no research needed"
# "To override: /research 355 --force"

# Verify status unchanged:
jq -r '.active_projects[] | select(.project_number == 355) | .status' .opencode/specs/state.json
# Expected: "completed" (unchanged)
```

**Test postflight failure (artifact not created)**:

This test requires manually modifying a subagent to NOT create an artifact, which is not practical. Instead, document the expected behavior:

```
If a subagent claims to create an artifact but the file doesn't exist:
1. Postflight validation detects missing artifact
2. Command aborts with error: "Artifact not found on disk: {path}"
3. Status is NOT updated (preflight succeeded, postflight failed)
4. User must fix subagent and retry
```

#### Test 7.3: Concurrent Operations

**Test that last writer wins (no file locking)**:

```bash
# Create two tasks
/task "Concurrent test 1" --language general --priority Medium
/task "Concurrent test 2" --language general --priority Medium
# Note task numbers (e.g., 356, 357)

# In terminal 1:
/research 356 &

# In terminal 2 (immediately):
/research 357 &

# Wait for both to complete
wait

# Verify both succeeded:
jq -r '.active_projects[] | select(.project_number == 356) | .status' .opencode/specs/state.json
# Expected: "researched"
jq -r '.active_projects[] | select(.project_number == 357) | .status' .opencode/specs/state.json
# Expected: "researched"

# Check git log shows both commits:
git log --oneline -5
# Expected: Both "task 356: research completed" and "task 357: research completed"
```

#### Test 7.4: Force Flag Override

**Test --force flag bypasses validation**:

```bash
# Use completed task from Test 7.2
/research 355 --force

# Expected:
# "WARNING: Using --force flag to override status validation"
# "Current status: completed"
# "Proceeding with research despite status"

# Verify research completes:
# (Status may stay "completed" or change to "researched" depending on implementation)
```

#### Test 7.5: Validation Gate Enforcement

**Test that work doesn't proceed without status update**:

This test requires manually breaking status-sync-manager, which is not practical. Instead, document the expected behavior:

```
If status-sync-manager fails during preflight:
1. Preflight validation detects failure
2. Command aborts with error: "Failed to update status to {STATUS}: {error}"
3. Work does NOT begin (delegation to subagent never happens)
4. User must fix status-sync-manager and retry
```

### Test Results Documentation

Create a test results file: `.opencode/specs/TEST_RESULTS.md`

```markdown
# Status Update Fix - Test Results

**Date**: YYYY-MM-DD  
**Tester**: [Your Name]

## Test 7.1: End-to-End Workflow
- [ ] Task creation: PASS/FAIL
- [ ] Research: PASS/FAIL
- [ ] Planning: PASS/FAIL
- [ ] Revision: PASS/FAIL
- [ ] Implementation: PASS/FAIL
- [ ] All status transitions correct: PASS/FAIL
- [ ] All artifacts linked: PASS/FAIL
- [ ] All git commits created: PASS/FAIL

## Test 7.2: Error Handling
- [ ] Invalid status transition blocked: PASS/FAIL
- [ ] Clear error messages: PASS/FAIL
- [ ] Status unchanged after error: PASS/FAIL

## Test 7.3: Concurrent Operations
- [ ] Both operations succeeded: PASS/FAIL
- [ ] No file corruption: PASS/FAIL
- [ ] Both git commits created: PASS/FAIL

## Test 7.4: Force Flag Override
- [ ] Force flag bypasses validation: PASS/FAIL
- [ ] Warning message displayed: PASS/FAIL

## Test 7.5: Validation Gate Enforcement
- [ ] Preflight failure blocks work: PASS/FAIL
- [ ] Postflight failure logged: PASS/FAIL

## Overall Result
- [ ] All tests passed
- [ ] Some tests failed (see notes below)

## Notes
[Add any observations, issues, or recommendations here]
```

---

## Phase 8: Documentation Updates

**Duration**: 1-2 hours  
**Goal**: Document the new architecture and troubleshooting guide

### Documentation Files to Create/Update

#### Doc 8.1: Create ARCHITECTURE.md

**File**: `.opencode/specs/ARCHITECTURE.md`

```markdown
# ProofChecker .opencode System Architecture

**Version**: 2.0 (Post Status Update Fix)  
**Last Updated**: YYYY-MM-DD

## Overview

The ProofChecker .opencode system uses a **three-layer architecture** with **validation gates** to ensure consistent status updates and artifact linking.

## Three-Layer Architecture

### Layer 1: Command Files (Orchestration)

**Location**: `.opencode/command/*.md`

**Responsibilities**:
- Parse and validate user input
- **Preflight**: Update status BEFORE delegating to subagents
- Delegate to appropriate subagent based on task language
- Validate subagent return
- **Postflight**: Update status and link artifacts AFTER subagent completes
- Delegate to git-workflow-manager for commits
- Relay result to user

**Commands**:
- `/task`: Create task entries (delegates to status-sync-manager)
- `/research`: Research workflow (delegates to researcher)
- `/plan`: Planning workflow (delegates to planner)
- `/revise`: Revision workflow (dual-mode: task-reviser or planner)
- `/implement`: Implementation workflow (delegates to implementer)

**Key Pattern**: Commands own the workflow orchestration and validation gates.

### Layer 2: Subagent Files (Core Work)

**Location**: `.opencode/agent/subagents/*.md`

**Responsibilities**:
- Execute core work (research, planning, implementation)
- Create artifacts (reports, plans, code)
- Validate artifacts before returning
- Return standardized result with artifact metadata

**Subagents**:
- `researcher`: General research and information gathering
- `lean-research-agent`: Lean-specific research with proof strategies
- `planner`: Implementation planning with phase breakdown
- `lean-planner`: Lean-specific planning with proof strategies
- `implementer`: General implementation
- `lean-implementation-agent`: Lean-specific implementation
- `task-reviser`: Task metadata revision

**Key Pattern**: Subagents focus on core work only, no status updates.

### Layer 3: Utility Subagents (Atomic Operations)

**Location**: `.opencode/agent/subagents/*.md`

**Responsibilities**:
- Atomic multi-file updates (status-sync-manager)
- Standardized git commits (git-workflow-manager)
- Specialized utilities (error-diagnostics-agent, etc.)

**Utilities**:
- `status-sync-manager`: Atomic updates to TODO.md, state.json, plan files
- `git-workflow-manager`: Standardized git commits with task context

**Key Pattern**: Utilities provide atomic operations with rollback on failure.

## Validation Gates

### Preflight Gate (Before Work)

**Purpose**: Ensure status is updated BEFORE work begins

**Process**:
1. Command file delegates to status-sync-manager
2. status-sync-manager updates TODO.md and state.json atomically
3. Command file verifies status was actually updated
4. If verification fails: ABORT, do NOT delegate to subagent
5. If verification succeeds: Proceed to delegation

**Enforcement**: Work does NOT begin until status is verified.

### Postflight Gate (After Work)

**Purpose**: Ensure status is updated and artifacts are linked AFTER work completes

**Process**:
1. Subagent completes work and returns artifacts
2. Command file validates artifacts exist on disk
3. Command file delegates to status-sync-manager with validated artifacts
4. status-sync-manager updates status and links artifacts atomically
5. Command file verifies status and artifact links were actually updated
6. Command file delegates to git-workflow-manager for commit
7. If verification fails: Log warning (work is done, just status update failed)

**Enforcement**: Artifacts are validated before linking, status is verified after update.

## Status Transitions

### Valid Transitions

```
not_started → researching → researched
researched → planning → planned
planned → implementing → completed
planned → revising → revised
revised → implementing → completed
```

### Invalid Transitions

```
completed → * (completed is terminal)
not_started → completed (must go through workflow)
```

### Transition Enforcement

- Preflight validates current status allows transition
- status-sync-manager validates transition is valid
- Postflight verifies transition actually occurred

## Artifact Linking

### Artifact Validation Protocol

1. **Subagent creates artifact** (e.g., research-001.md)
2. **Subagent validates artifact** (exists, non-empty)
3. **Subagent returns artifact metadata** in standardized format
4. **Command file validates artifact** (exists on disk, non-empty)
5. **Command file passes validated artifact** to status-sync-manager
6. **status-sync-manager links artifact** to TODO.md and state.json
7. **Command file verifies artifact link** in TODO.md

### Artifact Types

- **Research reports**: `.opencode/specs/{task}_*/reports/research-NNN.md`
- **Plans**: `.opencode/specs/{task}_*/plans/implementation-NNN.md`
- **Implementations**: Project-specific paths (e.g., `ProofChecker/*.lean`)

## Error Handling

### Preflight Failure

If status update fails before work:
1. Command aborts with clear error message
2. Work does NOT begin
3. User must fix issue and retry

### Postflight Failure

If status update fails after work:
1. Command logs warning (work is done)
2. Manual fix instructions provided
3. User can run `/sync` to fix status

### Git Failure

If git commit fails:
1. Command logs warning (non-critical)
2. Manual git instructions provided
3. Command still succeeds (git failure doesn't fail workflow)

## Performance Characteristics

### Atomic Operations

- **TODO.md and state.json**: Updated atomically via temp files + atomic rename
- **Rollback**: If any write fails, all changes are rolled back
- **No file locking**: Last writer wins (acceptable for single-user workflows)

### Concurrency

- Multiple commands can run concurrently
- status-sync-manager uses atomic writes (no file locking)
- Last writer wins if concurrent updates to same task
- Git commits are serialized by git itself

## Design Principles

1. **Separation of Concerns**: Commands orchestrate, subagents execute, utilities provide atomic operations
2. **Validation Gates**: Enforce workflow stages through validation, not just instructions
3. **Defense in Depth**: Validate at multiple levels (subagent, command, utility)
4. **Fail Fast**: Abort early if validation fails, don't proceed with invalid state
5. **Clear Errors**: Provide actionable error messages with manual fix instructions
6. **Graceful Degradation**: Non-critical failures (git) don't fail the workflow

## Migration from v1.0

### What Changed

**Before (v1.0)**:
- Subagents handled preflight/postflight (unreliable)
- No validation gates
- Status updates were inconsistent
- Artifacts were not linked reliably

**After (v2.0)**:
- Commands handle preflight/postflight (enforced)
- Validation gates at every stage
- Status updates are 100% consistent
- Artifacts are validated and linked reliably

### Backward Compatibility

- Subagents simplified (preflight/postflight removed)
- Commands enhanced (validation gates added)
- status-sync-manager unchanged (already robust)
- Existing tasks and artifacts are compatible

## Troubleshooting

See `.opencode/specs/TROUBLESHOOTING.md` for common issues and fixes.
```

#### Doc 8.2: Create TROUBLESHOOTING.md

**File**: `.opencode/specs/TROUBLESHOOTING.md`

```markdown
# ProofChecker .opencode System - Troubleshooting Guide

**Version**: 2.0  
**Last Updated**: YYYY-MM-DD

## Common Issues and Fixes

### Issue 1: Status Not Updating

**Symptoms**:
- Command completes but status unchanged in TODO.md or state.json
- Status shows [NOT STARTED] after running /research

**Root Cause**:
- Preflight or postflight validation failed
- status-sync-manager returned error

**Diagnosis**:
```bash
# Check state.json for current status
jq -r '.active_projects[] | select(.project_number == TASK_NUMBER) | .status' .opencode/specs/state.json

# Check TODO.md for current status
grep -A 20 "^### TASK_NUMBER\." .opencode/specs/TODO.md | grep -i status
```

**Fix**:
```bash
# Option 1: Retry the command
/research TASK_NUMBER

# Option 2: Use /sync to fix status manually
/sync TASK_NUMBER

# Option 3: Manually edit TODO.md and state.json (last resort)
# Edit .opencode/specs/TODO.md: Change status marker
# Edit .opencode/specs/state.json: Change status field
```

**Prevention**:
- Check command output for preflight/postflight errors
- Ensure status-sync-manager is working correctly

---

### Issue 2: Artifacts Not Linked

**Symptoms**:
- Artifact created (e.g., research-001.md exists)
- Artifact not linked in TODO.md
- Artifact path not in state.json artifacts array

**Root Cause**:
- Postflight validation failed
- status-sync-manager didn't link artifact

**Diagnosis**:
```bash
# Check if artifact exists
find .opencode/specs -name "research-001.md" -path "*/TASK_NUMBER_*/*"

# Check if artifact is linked in TODO.md
grep -A 30 "^### TASK_NUMBER\." .opencode/specs/TODO.md | grep "research-001.md"

# Check if artifact is in state.json
jq -r '.active_projects[] | select(.project_number == TASK_NUMBER) | .artifacts' .opencode/specs/state.json
```

**Fix**:
```bash
# Option 1: Retry the command (will re-link artifact)
/research TASK_NUMBER --force

# Option 2: Manually add artifact link to TODO.md
# Edit .opencode/specs/TODO.md:
# Add line: - **Research**: [Research Report](.opencode/specs/TASK_NUMBER_*/reports/research-001.md)

# Option 3: Manually add artifact to state.json
# Edit .opencode/specs/state.json:
# Add to artifacts array: {"type": "research", "path": "...", "summary": "..."}
```

**Prevention**:
- Check postflight logs for artifact validation errors
- Ensure artifacts are created before postflight runs

---

### Issue 3: Git Commits Not Created

**Symptoms**:
- Command completes successfully
- Status updated correctly
- No git commit in git log

**Root Cause**:
- git-workflow-manager failed (non-critical)
- Git repository in invalid state

**Diagnosis**:
```bash
# Check git status
git status

# Check git log for recent commits
git log --oneline -10

# Check for uncommitted changes
git diff --name-only
```

**Fix**:
```bash
# Option 1: Manually create git commit
git add .opencode/specs/TODO.md .opencode/specs/state.json .opencode/specs/TASK_NUMBER_*
git commit -m "task TASK_NUMBER: [research|plan|implement] completed"

# Option 2: Retry the command (will create new commit)
/research TASK_NUMBER --force

# Option 3: Fix git repository state
git status  # Check for conflicts or issues
git add .   # Stage all changes
git commit -m "Fix: manual commit for task TASK_NUMBER"
```

**Prevention**:
- Ensure git repository is in clean state before running commands
- Check git-workflow-manager logs for errors

---

### Issue 4: Preflight Validation Failed

**Symptoms**:
- Command aborts with error: "Preflight failed"
- Status not updated
- Work does not begin

**Root Cause**:
- status-sync-manager returned error
- Invalid status transition
- TODO.md or state.json corrupted

**Diagnosis**:
```bash
# Check current status
jq -r '.active_projects[] | select(.project_number == TASK_NUMBER) | .status' .opencode/specs/state.json

# Check if status transition is valid
# Example: completed → researching is INVALID

# Check TODO.md and state.json for corruption
jq . .opencode/specs/state.json  # Should parse without errors
```

**Fix**:
```bash
# Option 1: Use --force flag to override validation
/research TASK_NUMBER --force

# Option 2: Fix status manually
# Edit state.json: Change status to valid value (e.g., "not_started")
# Edit TODO.md: Change status marker to [NOT STARTED]

# Option 3: Run /sync to reset status
/sync TASK_NUMBER
```

**Prevention**:
- Follow workflow order: research → plan → implement
- Don't manually edit status without understanding transitions

---

### Issue 5: Postflight Validation Failed

**Symptoms**:
- Command completes work (artifact created)
- Warning: "Postflight verification failed"
- Status not updated to final state

**Root Cause**:
- status-sync-manager succeeded but verification failed
- Race condition (rare)
- File system delay

**Diagnosis**:
```bash
# Check if status was actually updated
jq -r '.active_projects[] | select(.project_number == TASK_NUMBER) | .status' .opencode/specs/state.json

# Check if artifact was actually linked
grep -A 30 "^### TASK_NUMBER\." .opencode/specs/TODO.md | grep "research-001.md"

# If both are correct, this is a false positive (verification timing issue)
```

**Fix**:
```bash
# Option 1: Ignore warning if status and artifacts are correct
# Verification failed but update actually succeeded

# Option 2: Retry command to re-update status
/research TASK_NUMBER --force

# Option 3: Run /sync to fix status
/sync TASK_NUMBER
```

**Prevention**:
- Add delay between status update and verification (rare issue)
- Check logs for timing issues

---

### Issue 6: Plan Link Not Replaced (Multiple Plan Links)

**Symptoms**:
- Multiple plan links in TODO.md
- Old plan link not replaced by new plan link
- Plan link shows implementation-001.md instead of implementation-002.md

**Root Cause**:
- Plan link replacement logic failed
- status-sync-manager appended instead of replacing

**Diagnosis**:
```bash
# Check TODO.md for multiple plan links
grep -A 30 "^### TASK_NUMBER\." .opencode/specs/TODO.md | grep "implementation-"

# Expected: Single plan link to latest version
# Actual: Multiple plan links
```

**Fix**:
```bash
# Option 1: Manually edit TODO.md
# Remove old plan links, keep only latest version

# Option 2: Run /revise again (will replace all links with new one)
/revise TASK_NUMBER "Force plan link replacement"

# Option 3: Run /sync to fix links
/sync TASK_NUMBER
```

**Prevention**:
- Ensure status-sync-manager uses REPLACEMENT mode for plan links
- Check plan link replacement algorithm in status-sync-manager.md

---

### Issue 7: Phase Statuses Not Updated in Plan File

**Symptoms**:
- Implementation completes
- Plan file still shows [NOT STARTED] for all phases
- Phase statuses not updated to [COMPLETED]

**Root Cause**:
- Implementer didn't return phase_statuses array
- status-sync-manager didn't update plan file
- Plan file path incorrect

**Diagnosis**:
```bash
# Check plan file for phase statuses
cat .opencode/specs/TASK_NUMBER_*/plans/implementation-*.md | grep "### Phase"

# Expected: [COMPLETED] markers
# Actual: [NOT STARTED] markers

# Check state.json for plan_path
jq -r '.active_projects[] | select(.project_number == TASK_NUMBER) | .plan_path' .opencode/specs/state.json
```

**Fix**:
```bash
# Option 1: Manually edit plan file
# Change phase markers from [NOT STARTED] to [COMPLETED]
# Add completion timestamps

# Option 2: Retry implementation (will update phases)
/implement TASK_NUMBER --force

# Option 3: Run /sync to fix plan file
/sync TASK_NUMBER
```

**Prevention**:
- Ensure implementer returns phase_statuses array
- Check postflight logs for plan file update errors

---

## Diagnostic Commands

### Check System Health

```bash
# Validate state.json is valid JSON
jq . .opencode/specs/state.json

# Count active tasks
jq '.active_projects | length' .opencode/specs/state.json

# List tasks by status
jq -r '.active_projects[] | "\(.project_number): \(.status)"' .opencode/specs/state.json

# Check for tasks with missing language field
jq -r '.active_projects[] | select(.language == null or .language == "") | .project_number' .opencode/specs/state.json
```

### Check Specific Task

```bash
# Get full task details from state.json
jq -r '.active_projects[] | select(.project_number == TASK_NUMBER)' .opencode/specs/state.json

# Get task entry from TODO.md
grep -A 30 "^### TASK_NUMBER\." .opencode/specs/TODO.md

# Check task artifacts
find .opencode/specs -path "*/TASK_NUMBER_*/*" -type f
```

### Check Git State

```bash
# Check for uncommitted changes
git status

# Check recent commits
git log --oneline -10

# Check for task-related commits
git log --oneline --grep="task TASK_NUMBER"
```

## Emergency Recovery

### Restore from Git

```bash
# If TODO.md or state.json corrupted, restore from git
git checkout .opencode/specs/TODO.md
git checkout .opencode/specs/state.json

# If specific task corrupted, restore task directory
git checkout .opencode/specs/TASK_NUMBER_*
```

### Rebuild state.json from TODO.md

```bash
# If state.json is corrupted beyond repair
# Use /meta command to regenerate state.json from TODO.md
/meta
```

### Manual Status Fix

```bash
# If all else fails, manually fix status
# 1. Edit state.json: Change status field
# 2. Edit TODO.md: Change status marker
# 3. Commit changes: git add . && git commit -m "Manual status fix"
```

## Getting Help

If issues persist:
1. Check `.opencode/specs/ARCHITECTURE.md` for system design
2. Check command file logs for detailed error messages
3. Check status-sync-manager logs for atomic update errors
4. Review this troubleshooting guide for similar issues
5. Create a backup before attempting manual fixes

## Reporting Bugs

When reporting bugs, include:
1. Command that failed (e.g., `/research 350`)
2. Error message (full output)
3. Task number and current status
4. state.json entry for task
5. TODO.md entry for task
6. Git log (last 10 commits)
```

#### Doc 8.3: Update README.md

**File**: `.opencode/README.md`

Add a section about the status update fix:

```markdown
## Recent Updates

### v2.0: Status Update & Artifact Linking Fix (2026-01-07)

**Problem**: Status updates were inconsistent and artifacts were not reliably linked.

**Solution**: Added validation gates to command files to enforce preflight/postflight sequences.

**Changes**:
- Commands now handle status updates (preflight/postflight)
- Subagents simplified to focus on core work only
- Validation gates ensure status is updated before and after work
- Artifacts are validated before linking
- 100% consistent status updates and artifact linking

**Documentation**:
- Architecture: `.opencode/specs/ARCHITECTURE.md`
- Troubleshooting: `.opencode/specs/TROUBLESHOOTING.md`
- Implementation Plan: `.opencode/specs/STATUS_UPDATE_FIX_IMPLEMENTATION_PLAN.md`

**Testing**: See `.opencode/specs/TEST_RESULTS.md` for test results.
```

---

## Phase 9: Final Validation and Cleanup

**Duration**: 1 hour  
**Goal**: Ensure all changes are complete and system is production-ready

### Validation Checklist

#### 9.1: Code Review

- [ ] All command files have preflight stages
- [ ] All command files have postflight stages
- [ ] All subagents have preflight/postflight removed
- [ ] All subagents return standardized format with artifacts
- [ ] status-sync-manager unchanged (already robust)
- [ ] git-workflow-manager unchanged

#### 9.2: Documentation Review

- [ ] ARCHITECTURE.md created and comprehensive
- [ ] TROUBLESHOOTING.md created with common issues
- [ ] README.md updated with v2.0 changes
- [ ] TEST_RESULTS.md created with test results
- [ ] All documentation is clear and actionable

#### 9.3: Testing Review

- [ ] All tests in Phase 7 passed
- [ ] End-to-end workflow tested
- [ ] Error handling tested
- [ ] Concurrent operations tested
- [ ] Force flag tested
- [ ] Validation gates tested

#### 9.4: Git Cleanup

```bash
# Review all changes
git status
git diff

# Stage all changes
git add .opencode/command/
git add .opencode/agent/subagents/
git add .opencode/specs/

# Create comprehensive commit
git commit -m "Fix: Add validation gates for consistent status updates and artifact linking

- Add preflight/postflight to all command files
- Simplify subagents to focus on core work only
- Add validation gates to enforce workflow stages
- Add comprehensive documentation (ARCHITECTURE.md, TROUBLESHOOTING.md)
- Add test suite and test results

Fixes:
- Status updates now 100% consistent
- Artifacts reliably linked to TODO.md and state.json
- Clear error messages with manual fix instructions
- Validation gates prevent work without status updates

See .opencode/specs/STATUS_UPDATE_FIX_IMPLEMENTATION_PLAN.md for details."

# Push changes
git push
```

#### 9.5: Backup

```bash
# Create backup of working system
tar -czf proofchecker-opencode-v2.0-backup-$(date +%Y%m%d).tar.gz .opencode/

# Store backup in safe location
mv proofchecker-opencode-v2.0-backup-*.tar.gz ~/backups/
```

---

## Success Metrics

After completing all phases, verify these success metrics:

### Metric 1: Status Update Consistency

**Target**: 100% of commands update status correctly

**Measurement**:
```bash
# Run 10 research commands on different tasks
# Check that all 10 tasks have status "researched" in state.json
# Expected: 10/10 (100%)
```

### Metric 2: Artifact Linking Consistency

**Target**: 100% of artifacts are linked to TODO.md and state.json

**Measurement**:
```bash
# Run 10 research commands on different tasks
# Check that all 10 research reports are linked in TODO.md
# Check that all 10 research reports are in state.json artifacts array
# Expected: 10/10 (100%)
```

### Metric 3: Git Commit Consistency

**Target**: 95%+ of commands create git commits (allowing for rare git failures)

**Measurement**:
```bash
# Run 10 research commands on different tasks
# Check git log for 10 commits
# Expected: 9-10/10 (90-100%)
```

### Metric 4: Error Handling

**Target**: 100% of validation failures abort with clear error messages

**Measurement**:
```bash
# Try 5 invalid operations (e.g., research completed task)
# Check that all 5 abort with clear error messages
# Expected: 5/5 (100%)
```

### Metric 5: Validation Gate Enforcement

**Target**: 100% of commands execute preflight before work and postflight after work

**Measurement**:
```bash
# Run 10 commands with logging enabled
# Check logs for preflight and postflight execution
# Expected: 10/10 (100%)
```

---

## Rollback Plan

If issues arise during implementation, rollback to previous version:

```bash
# Restore from git
git checkout HEAD~1 .opencode/command/
git checkout HEAD~1 .opencode/agent/subagents/

# Or restore from backup
tar -xzf ~/backups/proofchecker-opencode-v1.0-backup-*.tar.gz

# Test that system works
/research TASK_NUMBER
```

---

## Conclusion

This implementation plan provides a comprehensive, phase-by-phase approach to fixing the status update and artifact linking issues in the ProofChecker .opencode system.

**Key Takeaways**:
1. **Move responsibility up**: Commands handle orchestration, subagents handle work
2. **Add validation gates**: Enforce workflow stages through validation, not instructions
3. **Validate at every stage**: Preflight, postflight, and verification
4. **Clear error messages**: Provide actionable instructions for manual fixes
5. **Comprehensive testing**: Verify all workflows work correctly

**Estimated Timeline**: 11-17 hours (2-3 days of focused work)

**Success Criteria**: 100% consistent status updates and artifact linking

**Next Steps**: Begin with Phase 1 (Add Preflight to /research Command)

---

**Questions or Issues?**

Refer to:
- `.opencode/specs/ARCHITECTURE.md` for system design
- `.opencode/specs/TROUBLESHOOTING.md` for common issues
- This implementation plan for detailed steps

Good luck with the implementation! 🚀
