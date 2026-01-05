# Task Command Fix Plan

**Date**: 2026-01-04  
**Issue**: /task command implements tasks instead of creating task entries  
**Root Cause**: Command delegates to task-creator subagent specification, but delegation pattern doesn't work for task creation

---

## Problem Analysis

### Current Architecture

```
/task "Create /sync command"
  ↓
orchestrator loads task.md
  ↓
task.md Stage 1: ParseAndValidate
  - Parse description from $ARGUMENTS
  - Extract flags (--priority, --effort, --language)
  ↓
task.md Stage 2: Delegate
  - Invoke task-creator subagent
  ↓
task-creator.md (593 lines of specification)
  - Step 0: Preflight validation
  - Step 1: Allocate number from state.json
  - Step 2: Format TODO.md entry
  - Step 3: Update TODO.md and state.json
  - Step 4: Return result
```

### Why It Fails

1. **Delegation pattern mismatch**: /research and /implement delegate to subagents that have actual implementation code (researcher.md, implementer.md). But task-creator.md is just a specification.

2. **No executable code**: task-creator.md describes WHAT to do but doesn't have executable bash/jq commands like /research and /implement have in their Stage 1.

3. **Claude interprets task description**: When I see "Create /sync command", I interpret it as an instruction to create the command, not as a description to store.

### How /research and /implement Work

Both commands have **executable pseudocode** in Stage 1:

```bash
# /research Stage 1
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .opencode/specs/state.json)
language=$(echo "$task_data" | jq -r '.language // "general"')
```

This is **executable** - I can directly run these commands.

But /task delegates to task-creator which has **descriptive pseudocode**:

```
1. Append task entry to TODO.md:
   a. Read current TODO.md content
   b. Find correct priority section
   c. Append formatted task entry
```

This is **descriptive** - I need to interpret and implement it.

---

## Solution Options

### Option 1: Inline Implementation (Recommended)

**Approach**: Move task creation logic directly into /task command Stage 1, similar to how /research and /implement have inline logic.

**Pros**:
- ✅ Consistent with /research and /implement pattern
- ✅ Executable pseudocode that I can directly follow
- ✅ No delegation to specification files
- ✅ Simpler, more direct

**Cons**:
- ❌ Larger command file (but still <200 lines)
- ❌ Loses separation of concerns

**Estimated Effort**: 1-2 hours

### Option 2: Fix task-creator with Executable Code

**Approach**: Rewrite task-creator.md to have executable bash/jq commands instead of descriptive pseudocode.

**Pros**:
- ✅ Maintains separation of concerns
- ✅ Follows original architecture plan

**Cons**:
- ❌ Delegation to subagent specification still problematic
- ❌ More complex
- ❌ Doesn't match /research and /implement pattern

**Estimated Effort**: 2-3 hours

### Option 3: Hybrid Approach

**Approach**: Keep Stage 1 (ParseAndValidate) in command file, but add Stage 2 (CreateTask) with inline implementation instead of delegation.

**Pros**:
- ✅ Consistent with /research and /implement structure
- ✅ Executable pseudocode
- ✅ Clear separation of parsing and creation

**Cons**:
- ❌ Abandons task-creator subagent

**Estimated Effort**: 1-2 hours

---

## Recommended Solution: Option 1 (Inline Implementation)

Rewrite /task command to have 2 stages with inline implementation:

### Stage 1: ParseAndValidate
- Parse description from $ARGUMENTS
- Extract --priority, --effort, --language flags
- Detect language from keywords if not provided
- Validate all inputs

### Stage 2: CreateTask
- Read next_project_number from state.json using jq
- Format TODO.md entry with proper metadata
- Append to correct priority section in TODO.md
- Update state.json (increment next_project_number, add to active_projects)
- Return task number to user

This matches the pattern of /research and /implement where Stage 1 has all the executable logic.

---

## Implementation Plan

### Step 1: Backup Current Files
- Backup .opencode/command/task.md
- Backup .opencode/agent/subagents/task-creator.md

### Step 2: Rewrite /task Command
- Keep frontmatter (agent: orchestrator, routing, etc.)
- Rewrite Stage 1: ParseAndValidate with executable pseudocode
- Add Stage 2: CreateTask with executable pseudocode for file operations
- Remove delegation to task-creator
- Add explicit bash/jq commands for:
  - Reading state.json
  - Extracting next_project_number
  - Formatting TODO.md entry
  - Appending to TODO.md
  - Updating state.json
  - Verifying updates

### Step 3: Test
- Test basic task creation: `/task "Fix bug in Foo.lean"`
- Test with flags: `/task "Add feature" --priority High --effort "2 hours"`
- Test language detection
- Verify TODO.md and state.json updated correctly
- Verify no implementation occurs

### Step 4: Update Documentation
- Update command-lifecycle.md to reflect inline implementation
- Note that /task doesn't delegate to subagent (different from /research and /implement)
- Update task-command-implementation-summary.md

---

## Detailed Implementation

### New /task Command Structure

```markdown
---
name: task
agent: orchestrator
description: "Create new task in .opencode/specs/TODO.md (NO implementation)"
timeout: 120
---

**Task Input (required):** $ARGUMENTS (task description)

**CRITICAL**: This command ONLY creates task entries. It NEVER implements tasks.

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task description and extract flags</action>
    <process>
      1. Parse description from $ARGUMENTS
         description="${ARGUMENTS%% --*}"  # Everything before first --
         
      2. Extract priority flag (default: Medium)
         if [[ "$ARGUMENTS" =~ --priority[[:space:]]+([A-Za-z]+) ]]; then
           priority="${BASH_REMATCH[1]}"
         else
           priority="Medium"
         fi
         # Validate: Low|Medium|High
         
      3. Extract effort flag (default: TBD)
         if [[ "$ARGUMENTS" =~ --effort[[:space:]]+\"([^\"]+)\" ]]; then
           effort="${BASH_REMATCH[1]}"
         else
           effort="TBD"
         fi
         
      4. Detect language (default: general)
         if [[ "$ARGUMENTS" =~ --language[[:space:]]+([a-z]+) ]]; then
           language="${BASH_REMATCH[1]}"
         elif [[ "$description" =~ (lean|proof|theorem|lemma|tactic) ]]; then
           language="lean"
         elif [[ "$description" =~ (markdown|doc|README|documentation) ]]; then
           language="markdown"
         elif [[ "$description" =~ (agent|command|context|meta) ]]; then
           language="meta"
         else
           language="general"
         fi
    </process>
    <checkpoint>Description parsed, flags extracted, language detected</checkpoint>
  </stage>
  
  <stage id="2" name="CreateTask">
    <action>Create task entry in TODO.md and state.json</action>
    <process>
      1. Read next_project_number from state.json
         next_number=$(jq -r '.next_project_number' .opencode/specs/state.json)
         
      2. Format TODO.md entry
         entry="### ${next_number}. ${description}
- **Effort**: ${effort}
- **Status**: [NOT STARTED]
- **Priority**: ${priority}
- **Language**: ${language}
- **Blocking**: None
- **Dependencies**: None

---

"
         
      3. Determine priority section
         case "$priority" in
           High) section="## High Priority" ;;
           Medium) section="## Medium Priority" ;;
           Low) section="## Low Priority" ;;
         esac
         
      4. Append to TODO.md
         # Find section, append entry
         # Use awk or sed to insert after section heading
         
      5. Update state.json
         timestamp=$(date -Iseconds)
         jq --arg num "$next_number" \
            --arg desc "$description" \
            --arg lang "$language" \
            --arg prio "${priority,,}" \
            --arg ts "$timestamp" \
            '.next_project_number = (.next_project_number + 1) |
             .active_projects += [{
               project_number: ($num | tonumber),
               project_name: $desc,
               type: "feature",
               phase: "not_started",
               status: "not_started",
               priority: $prio,
               language: $lang,
               created: $ts,
               last_updated: $ts
             }]' .opencode/specs/state.json > /tmp/state.json.tmp
         mv /tmp/state.json.tmp .opencode/specs/state.json
         
      6. Return result
         echo "Task ${next_number} created: ${description}"
         echo "Priority: ${priority}, Effort: ${effort}, Language: ${language}"
         echo ""
         echo "Next steps:"
         echo "  /research ${next_number} - Research this task"
         echo "  /plan ${next_number} - Create implementation plan"
         echo "  /implement ${next_number} - Implement the task"
    </process>
    <checkpoint>Task created in TODO.md and state.json</checkpoint>
  </stage>
</workflow_execution>
```

---

## Key Differences from Current Implementation

### Current (Broken)
- Stage 1: Parse arguments
- Stage 2: Delegate to task-creator subagent (specification file)
- task-creator has descriptive pseudocode
- I interpret task description as instruction to implement

### New (Fixed)
- Stage 1: Parse arguments
- Stage 2: Create task with executable bash/jq commands
- No delegation to subagent
- Executable pseudocode I can directly follow
- Matches /research and /implement pattern

---

## Acceptance Criteria

- [ ] /task creates task entry in TODO.md
- [ ] /task updates state.json (increments next_project_number, adds to active_projects)
- [ ] /task does NOT implement the task
- [ ] /task does NOT create any files except TODO.md and state.json updates
- [ ] /task returns task number and next steps
- [ ] Language field is always set (MANDATORY)
- [ ] Metadata format uses `- **Field**:` pattern
- [ ] All required fields present (Language, Effort, Priority, Status)
- [ ] Works with flags: --priority, --effort, --language
- [ ] Language detection works for keywords (lean, markdown, meta, etc.)

---

## Estimated Effort

- Step 1 (Backup): 5 minutes
- Step 2 (Rewrite): 45-60 minutes
- Step 3 (Test): 15-30 minutes
- Step 4 (Documentation): 15-30 minutes

**Total**: 1.5-2.5 hours

---

## Risk Assessment

### Low Risk
- Inline implementation is simpler than delegation
- Matches proven /research and /implement pattern
- Executable pseudocode is clearer than descriptive

### Medium Risk
- Abandons task-creator subagent (but it wasn't working anyway)
- Larger command file (but still reasonable size)

### Mitigation
- Keep task-creator.md as reference documentation
- Can always revert to delegation pattern if needed
- Thorough testing before committing

---

## Recommendation

**Proceed with Option 1 (Inline Implementation)**

This is the simplest, most direct fix that matches the proven pattern from /research and /implement. The task-creator subagent was a good idea architecturally, but in practice, the delegation pattern doesn't work well for task creation because:

1. Task creation is fundamentally different from task modification
2. /research and /implement work on existing tasks (lookup in state.json)
3. /task creates new tasks (no lookup, just file operations)
4. Inline implementation is clearer and more maintainable

The inline approach will make /task work correctly and consistently.
