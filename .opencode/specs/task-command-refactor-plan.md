# /task Command Refactor Implementation Plan (REVISED v2)

**Created**: 2026-01-04  
**Revised**: 2026-01-04 v2 (add description clarification via research)  
**Purpose**: Enhance /task command to research and clarify task descriptions  
**Issue**: Task 295 created without description field - need description clarification  
**Status**: ✅ COMPLETED - All phases implemented and committed

---

## Executive Summary

**User Requirement**: The /task command should accept a "garbled" or rough task description, research it to create an improved description, and include that description in both TODO.md and state.json.

**Current Behavior**:
- /task creates minimal entries with title only
- No Description field in TODO.md or state.json
- Extended fields added later via /research and /plan

**Desired Behavior**:
- /task accepts rough description
- /task researches and clarifies the description
- /task creates entry with improved Description field in both TODO.md and state.json
- Further research reports, plans, etc. added later via /research and /plan

**Key Change**: /task becomes a **two-step process**:
1. **Clarify**: Research and improve the task description
2. **Create**: Create task entry with clarified description

---

## Current Implementation Review

### task-creator Subagent (Existing)

**File**: `.opencode/agent/subagents/task-creator.md` (593 lines)

**Current Process**:
0. Preflight: Validate inputs
1. AllocateNumber: Read next_project_number
2. CreateEntry: Format TODO.md entry (no Description field)
3. UpdateFiles: Atomic update
4. Return: Task number

**What's Missing**:
- ❌ No description clarification step
- ❌ No Description field in TODO.md
- ❌ No description field in state.json

### /task Command (Existing)

**File**: `.opencode/command/task.md` (254 lines)

**Current Workflow**:
1. ParseAndValidate: Parse description, extract flags
2. Delegate: Delegate to task-creator

**What's Missing**:
- ❌ No description research/clarification
- ❌ No Description field creation

---

## Proposed Solution

### Design: Two-Step Task Creation

**Step 1: Clarify Description** (new)
- Accept rough/garbled description from user
- Research to understand intent
- Generate improved, clear description (2-3 sentences)
- Extract metadata (language, priority hints, effort hints)

**Step 2: Create Task Entry** (existing, enhanced)
- Create TODO.md entry with Description field
- Create state.json entry with description field
- Use clarified description from Step 1

### Architecture: Add description-clarifier Subagent

**New Subagent**: `.opencode/agent/subagents/description-clarifier.md`

**Purpose**: Research and clarify rough task descriptions

**Process**:
1. **Analyze**: Parse rough description, identify key concepts
2. **Research**: Use web search, documentation, codebase context
3. **Clarify**: Generate improved 2-3 sentence description
4. **Extract**: Detect language, priority, effort from context
5. **Return**: Clarified description + metadata

**Example**:

Input (rough):
```
"sync thing for todo and state"
```

Output (clarified):
```
Description: "Create a /sync command that synchronizes TODO.md and state.json bidirectionally, ensuring both files remain consistent. The command should detect discrepancies, resolve conflicts, and update both files atomically."

Metadata:
- Language: meta (command creation)
- Priority: Medium (infrastructure improvement)
- Effort: 4-6 hours (estimated from similar tasks)
```

### Updated Workflow

**New /task Workflow** (3 stages):

```xml
<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse rough description and extract flags</action>
    <process>
      1. Parse rough description from $ARGUMENTS
      2. Extract optional flags (--priority, --effort, --language)
      3. Validate description is non-empty
      4. If --skip-clarification flag: skip to Stage 3
      5. Otherwise: proceed to Stage 2
    </process>
    <checkpoint>Rough description parsed, flags extracted</checkpoint>
  </stage>
  
  <stage id="2" name="ClarifyDescription">
    <action>Research and clarify task description</action>
    <process>
      1. Invoke description-clarifier subagent:
         task(
           subagent_type="description-clarifier",
           prompt="Clarify task description: ${rough_description}",
           description="Clarify task description"
         )
      2. Wait for clarified description and metadata
      3. Override flags with clarified metadata if not explicitly set:
         - If --language not set: use clarified language
         - If --priority not set: use clarified priority
         - If --effort not set: use clarified effort
      4. Store clarified description for task creation
    </process>
    <checkpoint>Description clarified, metadata extracted</checkpoint>
  </stage>
  
  <stage id="3" name="CreateTask">
    <action>Create task entry with clarified description</action>
    <process>
      1. Invoke task-creator subagent:
         task(
           subagent_type="task-creator",
           prompt="Create task: ${title}. Description: ${clarified_description}. Priority: ${priority}. Effort: ${effort}. Language: ${language}.",
           description="Create task entry"
         )
      2. Wait for task-creator to complete
      3. Relay result to user
    </process>
    <checkpoint>Task created with clarified description</checkpoint>
  </stage>
</workflow_execution>
```

---

## Implementation Plan

### Phase 1: Create description-clarifier Subagent (3 hours)

**Goal**: Create subagent that researches and clarifies task descriptions

#### Task 1.1: Create Subagent File (1.5 hours)

**File**: `.opencode/agent/subagents/description-clarifier.md`

**Frontmatter**:
```yaml
---
name: "description-clarifier"
version: "1.0.0"
description: "Research and clarify rough task descriptions into clear, actionable descriptions"
mode: subagent
agent_type: utility
temperature: 0.3
max_tokens: 2000
timeout: 300
tools:
  read: true
  bash: true
  webfetch: true
permissions:
  allow:
    - read: [".opencode/specs/TODO.md", ".opencode/specs/state.json", ".opencode/context/**/*", "Documentation/**/*"]
    - bash: ["grep", "find", "jq"]
    - webfetch: ["*"]
  deny:
    - write: ["**/*"]
    - bash: ["rm", "sudo", "su", "mv", "cp", "lake", "python", "lean"]
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/tasks.md"
    - "core/system/state-management.md"
  max_context_size: 30000
delegation:
  max_depth: 3
  can_delegate_to: []
  timeout_default: 300
  timeout_max: 300
lifecycle:
  stage: 2
  command: "/task"
  return_format: "subagent-return-format.md"
---
```

**Process Flow**:
```xml
<process_flow>
  <step_0_preflight>
    <action>Validate rough description and prepare for research</action>
    <process>
      1. Validate rough_description is non-empty
      2. Extract key concepts and keywords
      3. Identify domain (lean, markdown, meta, general, etc.)
      4. Prepare research queries
    </process>
    <checkpoint>Rough description validated, research prepared</checkpoint>
  </step_0_preflight>
  
  <step_1_research>
    <action>Research task context and similar tasks</action>
    <process>
      1. Search TODO.md for similar tasks:
         - Extract keywords from rough description
         - Find tasks with similar keywords
         - Analyze their descriptions for patterns
      
      2. Search codebase context:
         - Check .opencode/context/ for relevant documentation
         - Check Documentation/ for related topics
         - Identify relevant files and modules
      
      3. Web research (if needed):
         - Search for technical concepts mentioned
         - Find best practices and patterns
         - Gather context for unfamiliar terms
      
      4. Compile research findings:
         - Key concepts identified
         - Similar tasks found
         - Relevant documentation
         - Technical context
    </process>
    <checkpoint>Research completed, context gathered</checkpoint>
  </step_1_research>
  
  <step_2_clarify>
    <action>Generate clarified description</action>
    <process>
      1. Analyze rough description with research context:
         - What is the user trying to accomplish?
         - What are the key requirements?
         - What is the scope?
      
      2. Generate clarified description (2-3 sentences):
         - First sentence: What (clear statement of task)
         - Second sentence: Why (purpose/motivation)
         - Third sentence: How (high-level approach, optional)
      
      3. Ensure clarity:
         - No ambiguous terms
         - Specific and actionable
         - Appropriate scope
         - Professional tone
      
      4. Validate description:
         - Length: 50-500 characters
         - Clarity: understandable without context
         - Completeness: captures intent
    </process>
    <checkpoint>Clarified description generated</checkpoint>
  </step_2_clarify>
  
  <step_3_extract_metadata>
    <action>Extract metadata from clarified description</action>
    <process>
      1. Detect language:
         - Keywords: "lean", "proof", "theorem" → lean
         - Keywords: "markdown", "doc", "README" → markdown
         - Keywords: "command", "agent", "context" → meta
         - Keywords: "python", "script" → python
         - Keywords: "shell", "bash" → shell
         - Default: general
      
      2. Estimate priority:
         - Keywords: "critical", "urgent", "blocking" → High
         - Keywords: "bug", "fix", "error" → High
         - Keywords: "feature", "add", "implement" → Medium
         - Keywords: "refactor", "improve", "enhance" → Medium
         - Keywords: "documentation", "cleanup" → Low
         - Default: Medium
      
      3. Estimate effort:
         - Check similar tasks in TODO.md
         - Use research findings
         - Default: TBD if uncertain
      
      4. Extract title (short version):
         - First 5-10 words of clarified description
         - Or: extract from rough description if clear
         - Max 80 characters
    </process>
    <checkpoint>Metadata extracted</checkpoint>
  </step_3_extract_metadata>
  
  <step_4_return>
    <action>Return clarified description and metadata</action>
    <return_format>
      {
        "status": "completed",
        "clarified_description": "{2-3 sentence description}",
        "title": "{short title, max 80 chars}",
        "metadata": {
          "language": "{detected language}",
          "priority": "{estimated priority}",
          "effort": "{estimated effort}",
          "confidence": "{high|medium|low}"
        },
        "research_summary": "{brief summary of research findings}",
        "similar_tasks": ["{task numbers of similar tasks}"]
      }
    </return_format>
    <checkpoint>Result returned</checkpoint>
  </step_4_return>
</process_flow>
```

**Deliverables**:
- `.opencode/agent/subagents/description-clarifier.md` (new file, ~400 lines)

**Validation**:
- [ ] Subagent follows subagent-structure.md standard
- [ ] Permissions prevent file writes (read-only research)
- [ ] Research process is comprehensive
- [ ] Clarified descriptions are clear and actionable
- [ ] Metadata extraction is accurate

**Estimated Effort**: 1.5 hours

#### Task 1.2: Test description-clarifier (1 hour)

**Test Cases**:

1. **Garbled description**:
   ```
   Input: "sync thing for todo and state"
   Expected: "Create a /sync command that synchronizes TODO.md and state.json..."
   ```

2. **Vague description**:
   ```
   Input: "fix the lean stuff"
   Expected: "Fix Lean compilation errors in [specific module]..."
   ```

3. **Technical jargon**:
   ```
   Input: "add leansearch api integration"
   Expected: "Integrate LeanSearch REST API for theorem search functionality..."
   ```

4. **Clear description** (should enhance, not change drastically):
   ```
   Input: "Implement completeness proof for TM logic"
   Expected: "Implement the completeness proof for TM logic using canonical model method..."
   ```

**Validation**:
- [ ] Garbled descriptions become clear
- [ ] Vague descriptions become specific
- [ ] Technical jargon is explained
- [ ] Clear descriptions are enhanced appropriately
- [ ] Language detection is accurate
- [ ] Priority estimation is reasonable
- [ ] Effort estimation is reasonable

**Estimated Effort**: 1 hour

#### Task 1.3: Document description-clarifier (30 minutes)

**Files to Update**:
- `.opencode/context/core/standards/subagent-structure.md` - Add description-clarifier as example
- `.opencode/context/core/system/task-creation-workflow.md` - Document clarification step

**Deliverables**:
- Documentation of description-clarifier subagent
- Examples of clarification process

**Estimated Effort**: 30 minutes

---

### Phase 2: Update task-creator to Support Description Field (2 hours)

**Goal**: Enhance task-creator to include Description field in TODO.md and state.json

#### Task 2.1: Update task-creator Process (1 hour)

**File**: `.opencode/agent/subagents/task-creator.md`

**Changes**:

1. **Update Input Validation** (Step 0):
   ```xml
   <step_0_preflight>
     <process>
       1. Validate required inputs:
          - title (non-empty string, max 200 chars)
          - description (non-empty string, 50-500 chars)  <!-- NEW -->
          - priority (Low|Medium|High)
          - effort (TBD or time estimate)
          - language (lean|markdown|general|python|shell|json|meta)
       2. Validate state.json exists and is readable
       3. Validate TODO.md exists and is readable
       4. If validation fails: abort with clear error message
     </process>
   </step_0_preflight>
   ```

2. **Update TODO.md Format** (Step 2):
   ```xml
   <step_2_create_entry>
     <process>
       1. Format task entry:
          ```
          ### {number}. {title}
          - **Effort**: {effort}
          - **Status**: [NOT STARTED]
          - **Priority**: {priority}
          - **Language**: {language}
          - **Blocking**: None
          - **Dependencies**: None
          
          **Description**: {description}  <!-- NEW -->
          
          ---
          ```
       2. Validate format follows tasks.md standard
       3. Determine correct section based on priority
       4. Prepare entry for atomic update
     </process>
   </step_2_create_entry>
   ```

3. **Update state.json Format** (Step 3):
   ```xml
   <step_3_update_files>
     <process>
       1. Create backup of TODO.md and state.json
       
       2. Update TODO.md:
          - Append formatted entry to priority section
       
       3. Update state.json:
          - Add to active_projects array:
            {
              "project_number": {number},
              "project_name": "{slug}",
              "type": "feature",
              "phase": "not_started",
              "status": "not_started",
              "priority": "{priority}",
              "language": "{language}",
              "description": "{description}",  <!-- NEW -->
              "effort": "{effort}",
              "blocking": [],
              "dependencies": [],
              "created": "{timestamp}",
              "last_updated": "{timestamp}"
            }
          - Increment next_project_number
       
       4. Verify both updates succeeded
       5. If failure: rollback to backups
     </process>
   </step_3_update_files>
   ```

**Deliverables**:
- Updated `.opencode/agent/subagents/task-creator.md`

**Validation**:
- [ ] Description field required in input
- [ ] Description field in TODO.md format
- [ ] description field in state.json format
- [ ] Atomic updates still work
- [ ] Rollback works on failure

**Estimated Effort**: 1 hour

#### Task 2.2: Test task-creator with Description (1 hour)

**Test Cases**:

1. **Create task with description**:
   ```
   Input:
     title: "Create /sync command"
     description: "Create a /sync command that synchronizes TODO.md and state.json bidirectionally."
     priority: High
     effort: 4 hours
     language: meta
   
   Expected TODO.md:
     ### 296. Create /sync command
     - **Effort**: 4 hours
     - **Status**: [NOT STARTED]
     - **Priority**: High
     - **Language**: meta
     - **Blocking**: None
     - **Dependencies**: None
     
     **Description**: Create a /sync command that synchronizes TODO.md and state.json bidirectionally.
     
     ---
   
   Expected state.json:
     {
       "project_number": 296,
       "project_name": "create_sync_command",
       "description": "Create a /sync command that synchronizes TODO.md and state.json bidirectionally.",
       "priority": "high",
       "language": "meta",
       "effort": "4 hours",
       ...
     }
   ```

2. **Create task with multi-line description**:
   ```
   Input:
     description: "Create a /sync command that synchronizes TODO.md and state.json bidirectionally. The command should detect discrepancies, resolve conflicts, and update both files atomically."
   
   Expected: Description preserved with newlines/formatting
   ```

3. **Verify atomic updates**:
   ```
   Test: Simulate failure during state.json update
   Expected: Both files rolled back, no partial update
   ```

**Validation**:
- [ ] Description field appears in TODO.md
- [ ] description field appears in state.json
- [ ] Multi-line descriptions work
- [ ] Atomic updates work
- [ ] Rollback works on failure

**Estimated Effort**: 1 hour

---

### Phase 3: Update /task Command Workflow (1.5 hours)

**Goal**: Add description clarification stage to /task command

#### Task 3.1: Update /task Command (1 hour)

**File**: `.opencode/command/task.md`

**Changes**:

1. **Add --skip-clarification Flag**:
   ```xml
   <stage id="1" name="ParseAndValidate">
     <process>
       1. Parse description from $ARGUMENTS
       2. Extract flags:
          - --priority (Low|Medium|High)
          - --effort (TBD or time estimate)
          - --language (lean|markdown|general|python|shell|json|meta)
          - --skip-clarification (boolean, default: false)  <!-- NEW -->
       3. Validate description is non-empty
       4. Determine if clarification needed:
          - If --skip-clarification: skip to Stage 3
          - If --language, --priority, --effort all set: skip to Stage 3
          - Otherwise: proceed to Stage 2
     </process>
   </stage>
   ```

2. **Add Stage 2: ClarifyDescription**:
   ```xml
   <stage id="2" name="ClarifyDescription">
     <action>Research and clarify task description</action>
     <process>
       1. Invoke description-clarifier subagent:
          task(
            subagent_type="description-clarifier",
            prompt="Clarify task description: ${rough_description}",
            description="Clarify task description"
          )
       
       2. Wait for clarified description and metadata
       
       3. Override flags with clarified metadata if not explicitly set:
          - If --language not set: use clarified language
          - If --priority not set: use clarified priority
          - If --effort not set: use clarified effort
       
       4. Store clarified description and title for task creation
       
       5. Show clarification to user:
          "Clarified description: {clarified_description}"
          "Detected: Language={language}, Priority={priority}, Effort={effort}"
     </process>
     <checkpoint>Description clarified, metadata extracted</checkpoint>
   </stage>
   ```

3. **Update Stage 3: CreateTask** (formerly Stage 2):
   ```xml
   <stage id="3" name="CreateTask">
     <action>Create task entry with clarified description</action>
     <process>
       1. Prepare task creation input:
          - title: from clarified title or rough description
          - description: from clarified description or rough description
          - priority: from flag or clarified metadata
          - effort: from flag or clarified metadata
          - language: from flag or clarified metadata
       
       2. Invoke task-creator subagent:
          task(
            subagent_type="task-creator",
            prompt="Create task: ${title}. Description: ${description}. Priority: ${priority}. Effort: ${effort}. Language: ${language}.",
            description="Create task entry"
          )
       
       3. Wait for task-creator to complete
       
       4. Relay result to user:
          "Task {number} created: {title}"
          "Description: {description}"
          "Priority: {priority}, Effort: {effort}, Language: {language}"
          "Next steps: /research {number}, /plan {number}, /implement {number}"
     </process>
     <checkpoint>Task created with clarified description</checkpoint>
   </stage>
   ```

**Deliverables**:
- Updated `.opencode/command/task.md` (3-stage workflow)

**Validation**:
- [ ] Stage 1 parses flags correctly
- [ ] Stage 2 clarifies description (when needed)
- [ ] Stage 3 creates task with description
- [ ] --skip-clarification flag works
- [ ] Explicit flags skip clarification

**Estimated Effort**: 1 hour

#### Task 3.2: Update Documentation (30 minutes)

**Files to Update**:

1. **`.opencode/command/task.md`** - Update usage section
2. **`.opencode/context/core/standards/tasks.md`** - Update task entry format

**Estimated Effort**: 30 minutes

---

### Phase 4: Testing and Validation (2 hours)

**Goal**: Comprehensive testing of enhanced /task command

**Test Cases**: See detailed test cases in plan above

**Estimated Effort**: 2 hours

---

### Phase 5: Documentation and Rollout (1 hour)

**Goal**: Complete documentation and prepare for rollout

**Estimated Effort**: 1 hour

---

## Timeline

**Total Estimated Time**: 9.5 hours

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| 1. Create description-clarifier | 3 hours | New subagent, tests, docs |
| 2. Update task-creator | 2 hours | Enhanced subagent, tests |
| 3. Update /task command | 1.5 hours | 3-stage workflow, docs |
| 4. Testing and validation | 2 hours | Test results, verification |
| 5. Documentation and rollout | 1 hour | User docs, migration guide |

---

## Success Criteria

- ✅ Garbled descriptions become clear (>90% improvement)
- ✅ Language detection accuracy >95%
- ✅ Priority estimation accuracy >80%
- ✅ Effort estimation accuracy >70%
- ✅ Description field in 100% of new tasks
- ✅ Atomic updates work 100% of the time

---

## Conclusion

This plan enhances the /task command to accept rough descriptions, research and clarify them, and create task entries with improved descriptions in both TODO.md and state.json.

**Key Benefits**:
1. ✅ Users can provide garbled/rough descriptions
2. ✅ Automatic clarification via research
3. ✅ Description field in all new tasks
4. ✅ Better metadata detection
5. ✅ Faster task creation workflow
6. ✅ Backward compatible

**Total Effort**: 9.5 hours

**Next Steps**: Review and approve this plan, then begin Phase 1 implementation.

---

**End of Plan**
