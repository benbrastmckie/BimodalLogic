# ProofChecker .opencode System Improvement Plan v2.0

**Created**: 2026-01-03  
**Status**: Draft for Review  
**Purpose**: Systematic improvement of the .opencode system for efficiency, consistency, and robust functionality  
**Target**: Orchestrator-first operation with standardized command patterns

---

## Executive Summary

This plan addresses systematic improvements to the `/home/benjamin/Projects/ProofChecker/.opencode/` system to enhance:

1. **Command Argument Handling** - Standardize `$ARGUMENTS` parsing across all commands
2. **Orchestrator Efficiency** - Reduce complexity while maintaining functionality
3. **Context Organization** - Fix broken references and improve documentation
4. **Developer Experience** - Make standards evident and accessible
5. **Meta Command Integration** - Ensure generated commands follow all standards

**Key Metrics**:
- Reduce orchestrator from 751 → ~500 lines (33% reduction)
- Achieve <10% context window usage during routing
- Eliminate all broken context file references
- 100% command compliance with argument handling standard

---

## Current State Analysis

### System Strengths ✅

1. **Well-Structured Orchestrator** (751 lines)
   - Clear 5-stage workflow: Preflight → Routing → Delegation → Validation → Postflight
   - Language-based routing working correctly (lean vs general)
   - Delegation safety: cycle detection, timeouts, session tracking

2. **Comprehensive Context System**
   - Excellent context index with lazy-loading patterns
   - 72% reduction achieved in Task 246 (3,715 → 1,045 lines)
   - Clear separation: core/common/project/meta contexts

3. **Command Template Standards**
   - Good template at `context/core/templates/command-template.md`
   - Frontmatter delegation pattern established
   - Examples for direct and language-based routing

4. **Strong Documentation Foundation**
   - ARCHITECTURE.md provides system overview
   - Migration docs track evolution
   - ADRs document architectural decisions

### Critical Issues ⚠️

#### Issue 1: Inconsistent $ARGUMENTS Handling

**Problem**: Orchestrator contains detailed `$ARGUMENTS` parsing logic (lines 54-149) but this is NOT documented in a reusable context file.

**Impact**: 
- New commands may not follow the pattern correctly
- Developers lack clear guidance
- Inconsistent error messages across commands

**Example**:
```
User types: /research 176
OpenCode sets: $ARGUMENTS = "176"
Orchestrator must: Parse "176", validate task exists, format as "Task: 176"
```

**Current State**: Logic is inline in orchestrator, not reusable.

#### Issue 2: Missing Command Argument Standards Documentation

**Problem**: No context file at `context/common/standards/command-argument-handling.md` (referenced in index.md line 64 but doesn't exist).

**Impact**:
- Developers creating new commands lack clear guidance
- No single source of truth for argument parsing
- Inconsistent validation across commands

**Evidence**:
```bash
$ ls .opencode/context/common/standards/command-argument-handling.md
ls: cannot access '.opencode/context/common/standards/command-argument-handling.md': No such file or directory
```

#### Issue 3: Orchestrator Complexity

**Problem**: Orchestrator contains 751 lines with extensive inline documentation that could be extracted to context files.

**Impact**:
- Harder to maintain
- Context window bloat during routing
- Duplication of logic across commands

**Breakdown**:
- Lines 54-149: Argument handling (95 lines) → Extract to context file
- Lines 162-299: Routing logic (137 lines) → Extract to context file
- Lines 376-463: Validation rules (87 lines) → Extract to context file
- **Total extractable**: ~320 lines (43% of file)

#### Issue 4: Deprecated File References

**Problem**: Commands reference deprecated context files.

**Examples**:
- `research.md` line 16: `core/standards/subagent-return-format.md` (deprecated per index.md line 306)
- Should reference: `core/standards/delegation.md`

**Impact**: Confusion about which files to load, potential loading of wrong context.

**Files Affected**:
```bash
$ grep -r "subagent-return-format.md" .opencode/command/
.opencode/command/research.md:    - "core/standards/subagent-return-format.md"
.opencode/command/implement.md:    - "core/standards/subagent-return-format.md"
.opencode/command/plan.md:    - "core/standards/subagent-return-format.md"
.opencode/command/review.md:    - "core/standards/subagent-return-format.md"
.opencode/command/errors.md:    - "core/standards/subagent-return-format.md"
```

#### Issue 5: Meta Command Integration

**Problem**: `/meta` command generates commands but may not enforce all current standards.

**Opportunity**: Ensure meta-generated commands automatically follow:
- `$ARGUMENTS` handling standard
- Correct context file references
- Validation patterns
- Error handling patterns

---

## Improvement Plan

### Phase 1: Standardize Command Argument Handling

**Priority**: HIGH  
**Effort**: 2-3 days  
**Impact**: Foundation for all other improvements

#### 1.1 Create Command Argument Handling Standard

**File**: `.opencode/context/common/standards/command-argument-handling.md`

**Purpose**: Single source of truth for `$ARGUMENTS` parsing, validation, and error handling.

**Content Structure**:

```markdown
# Command Argument Handling Standard

## Overview

This standard defines how all commands in the .opencode system handle the `$ARGUMENTS` variable provided by OpenCode.

## The $ARGUMENTS Variable

OpenCode automatically provides the `$ARGUMENTS` variable containing everything after the command name.

### How It Works

When a user types a command, OpenCode splits it into:
- **Command name**: Everything before the first space (e.g., `/research`)
- **Arguments**: Everything after the first space → stored in `$ARGUMENTS`

### Examples

| User Input | $ARGUMENTS Value |
|------------|------------------|
| `/research 176` | `"176"` |
| `/implement 267 "focus on error handling"` | `"267 \"focus on error handling\""` |
| `/meta` | `""` (empty string) |
| `/errors --all --type delegation_hang` | `"--all --type delegation_hang"` |

## Command Types

### Task-Based Commands

**Definition**: Commands that operate on tasks from TODO.md.

**Examples**: `/research`, `/implement`, `/plan`

**Pattern**: `/{command} TASK_NUMBER [ADDITIONAL_ARGS]`

**Argument Handling**:

1. **Extract task number** from `$ARGUMENTS` (first token)
   ```bash
   task_number=$(echo "$ARGUMENTS" | awk '{print $1}')
   ```

2. **Validate task number** is a positive integer
   ```bash
   if ! [[ "$task_number" =~ ^[0-9]+$ ]]; then
     error "Task number must be a positive integer. Got: $task_number"
   fi
   ```

3. **Verify task exists** in TODO.md
   ```bash
   if ! grep -q "^### ${task_number}\." .opencode/specs/TODO.md; then
     error "Task ${task_number} not found in TODO.md"
   fi
   ```

4. **Format prompt** for subagent delegation
   ```bash
   prompt="Task: ${task_number}"
   ```

**Critical**: DO NOT pass `$ARGUMENTS` directly to subagent. Always format as `"Task: {number}"`.

**Example Flow**:
```
User: /research 258
$ARGUMENTS = "258"
Orchestrator: Validates task 258 exists
Orchestrator: Formats prompt = "Task: 258"
Orchestrator: Delegates to researcher with prompt="Task: 258"
```

### Direct Commands

**Definition**: Commands that don't require a task number.

**Examples**: `/meta`, `/review`, `/todo`, `/errors`

**Pattern**: `/{command} [OPTIONS]`

**Argument Handling**:

1. **Read $ARGUMENTS** (may be empty or contain user input)
   ```bash
   user_input="$ARGUMENTS"
   ```

2. **NO task validation** required

3. **Pass $ARGUMENTS as-is** to subagent
   ```bash
   prompt="$ARGUMENTS"
   ```

**Example Flow**:
```
User: /meta
$ARGUMENTS = ""
Orchestrator: Delegates to meta with prompt=""

User: /review lean
$ARGUMENTS = "lean"
Orchestrator: Delegates to reviewer with prompt="lean"
```

## Validation Rules

### Task Number Validation

**Required for**: Task-based commands only

**Steps**:

1. **Extract task number**
   ```bash
   task_number=$(echo "$ARGUMENTS" | awk '{print $1}')
   ```

2. **Validate format** (positive integer)
   ```bash
   if ! [[ "$task_number" =~ ^[0-9]+$ ]]; then
     return_error "Task number must be a positive integer. Got: $task_number"
     exit 1
   fi
   ```

3. **Verify existence** in TODO.md
   ```bash
   if ! grep -q "^### ${task_number}\." .opencode/specs/TODO.md; then
     return_error "Task ${task_number} not found in TODO.md"
     exit 1
   fi
   ```

4. **Extract additional arguments** (if needed)
   ```bash
   additional_args=$(echo "$ARGUMENTS" | cut -d' ' -f2-)
   ```

### Prompt Formatting

**For task-based commands**:
```bash
# CORRECT
prompt="Task: ${task_number}"

# INCORRECT - DO NOT DO THIS
prompt="$ARGUMENTS"  # Wrong! Subagent needs "Task: N" format
```

**For direct commands**:
```bash
# CORRECT
prompt="$ARGUMENTS"  # Pass as-is
```

## Error Messages

### Missing Task Number

**When**: Task-based command invoked without arguments

**Message**:
```
Error: Task number required for /{command} command

Usage: /{command} <task_number> [additional_args]

Example: /{command} 258
```

**Implementation**:
```bash
if [ -z "$ARGUMENTS" ]; then
  echo "Error: Task number required for /${command} command"
  echo ""
  echo "Usage: /${command} <task_number> [additional_args]"
  echo ""
  echo "Example: /${command} 258"
  exit 1
fi
```

### Invalid Task Number

**When**: Task number is not a positive integer

**Message**:
```
Error: Task number must be an integer. Got: {input}

Usage: /{command} TASK_NUMBER [PROMPT]

Example: /{command} 258
```

**Implementation**:
```bash
if ! [[ "$task_number" =~ ^[0-9]+$ ]]; then
  echo "Error: Task number must be an integer. Got: $task_number"
  echo ""
  echo "Usage: /${command} TASK_NUMBER [PROMPT]"
  echo ""
  echo "Example: /${command} 258"
  exit 1
fi
```

### Task Not Found

**When**: Task number doesn't exist in TODO.md

**Message**:
```
Error: Task {task_number} not found in TODO.md

Please verify the task number exists in .opencode/specs/TODO.md

You can list all tasks with: grep "^###" .opencode/specs/TODO.md
```

**Implementation**:
```bash
if ! grep -q "^### ${task_number}\." .opencode/specs/TODO.md; then
  echo "Error: Task ${task_number} not found in TODO.md"
  echo ""
  echo "Please verify the task number exists in .opencode/specs/TODO.md"
  echo ""
  echo "You can list all tasks with: grep \"^###\" .opencode/specs/TODO.md"
  exit 1
fi
```

## Implementation Checklist

When creating a new command, ensure:

- [ ] Determine command type (task-based or direct)
- [ ] Add `$ARGUMENTS` documentation to command file header
- [ ] Implement appropriate parsing logic
- [ ] Add validation for task numbers (if task-based)
- [ ] Format prompt correctly for subagent delegation
- [ ] Add error handling for missing/invalid arguments
- [ ] Test with various argument patterns:
  - [ ] Valid task number
  - [ ] Invalid task number (non-integer)
  - [ ] Missing task number
  - [ ] Non-existent task number
  - [ ] Additional arguments after task number
- [ ] Document usage examples in command file
- [ ] Add to command list in README.md

## Common Patterns

### Task-Based Command Template

```markdown
---
name: {command}
agent: orchestrator
routing:
  language_based: {true|false}
  target_agent: {agent_name}
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/{command} 197`)

See: `.opencode/context/common/standards/command-argument-handling.md`

<workflow_setup>
  <stage_1_parse_arguments>
    1. Read task_number from $ARGUMENTS variable
    2. Validate task_number is positive integer
    3. Verify task exists in TODO.md
    4. Store task_number for prompt formatting
  </stage_1_parse_arguments>
  
  <stage_2_format_prompt>
    Format prompt as "Task: {task_number}" for subagent delegation
  </stage_2_format_prompt>
</workflow_setup>
```

### Direct Command Template

```markdown
---
name: {command}
agent: orchestrator
routing:
  language_based: false
  target_agent: {agent_name}
---

**Task Input (optional):** $ARGUMENTS (user input; e.g., `/{command} "options"`)

See: `.opencode/context/common/standards/command-argument-handling.md`

<workflow_setup>
  <stage_1_parse_arguments>
    1. Read $ARGUMENTS (may be empty)
    2. NO task validation required
    3. Store $ARGUMENTS for pass-through
  </stage_1_parse_arguments>
  
  <stage_2_format_prompt>
    Pass $ARGUMENTS as-is to subagent
  </stage_2_format_prompt>
</workflow_setup>
```

## Troubleshooting

### Issue: Subagent doesn't receive task number

**Symptom**: Subagent receives empty prompt or raw `$ARGUMENTS`

**Cause**: Prompt not formatted correctly

**Solution**: Ensure prompt is formatted as `"Task: {task_number}"` for task-based commands

**Check**:
```bash
# CORRECT
prompt="Task: ${task_number}"

# INCORRECT
prompt="$ARGUMENTS"  # Don't pass raw arguments
```

### Issue: Task validation fails for valid task

**Symptom**: "Task not found" error for existing task

**Cause**: Incorrect grep pattern or TODO.md path

**Solution**: Verify grep pattern matches TODO.md format

**Check**:
```bash
# Correct pattern
grep -q "^### ${task_number}\." .opencode/specs/TODO.md

# Verify TODO.md format
head -20 .opencode/specs/TODO.md
# Should show: ### 123. Task title
```

### Issue: Additional arguments not parsed

**Symptom**: Flags or prompts after task number are ignored

**Cause**: Only extracting first token from `$ARGUMENTS`

**Solution**: Extract additional arguments after task number

**Implementation**:
```bash
task_number=$(echo "$ARGUMENTS" | awk '{print $1}')
additional_args=$(echo "$ARGUMENTS" | cut -d' ' -f2-)
```

## See Also

- Command Template: `.opencode/context/core/templates/command-template.md`
- Delegation Standard: `.opencode/context/core/standards/delegation.md`
- Orchestrator Guide: `.opencode/agent/orchestrator.md`
- Creating Commands Guide: `.opencode/docs/guides/creating-commands.md`
```

**Estimated Size**: ~120 lines

**Benefits**:
- Single source of truth for argument handling
- Clear examples for both command types
- Comprehensive error handling patterns
- Troubleshooting guide for common issues

#### 1.2 Update Orchestrator to Reference Standard

**File**: `.opencode/agent/orchestrator.md`

**Changes**:

1. **Update context_loading** (lines 10-16):
   ```yaml
   context_loading:
     strategy: minimal
     index: ".opencode/context/index.md"
     required:
       - "core/system/routing-guide.md"
       - "core/workflows/delegation-guide.md"
       - "common/standards/command-argument-handling.md"  # ADD THIS
     max_context_size: 10000
   ```

2. **Simplify critical_instructions** (lines 54-90):
   
   **Before** (36 lines of inline documentation):
   ```xml
   <critical_instructions>
     COMMAND TYPES:
     
     1. TASK-BASED COMMANDS (require task number argument):
        - /research, /implement, /plan
        - MUST have task number in $ARGUMENTS
        - Format prompt as "Task: {task_number}"
     
     2. DIRECT COMMANDS (no task number required):
        - /meta, /review, /revise
        - May have $ARGUMENTS or be empty
        - Delegate directly to routing.default agent
        - Pass $ARGUMENTS as-is to subagent
     
     [... 22 more lines ...]
   </critical_instructions>
   ```
   
   **After** (8 lines with reference):
   ```xml
   <critical_instructions>
     ARGUMENT HANDLING:
     
     All commands follow the standard defined in:
     @.opencode/context/common/standards/command-argument-handling.md
     
     Key points:
     - OpenCode provides $ARGUMENTS variable automatically
     - Task-based commands: Parse task number, validate, format as "Task: {number}"
     - Direct commands: Pass $ARGUMENTS as-is
     - See standard for validation rules and error messages
   </critical_instructions>
   ```

3. **Update Stage 1 (PreflightValidation)** (lines 93-161):
   
   Replace inline documentation with reference:
   ```xml
   <stage id="1" name="PreflightValidation">
     <action>Load command, validate, parse arguments, and prepare delegation context</action>
     <process>
       See: @.opencode/context/common/standards/command-argument-handling.md
       
       1. Determine command type (task-based or direct)
       2. Parse arguments according to command type:
          - Task-based: Extract and validate task number
          - Direct: Read $ARGUMENTS as-is
       3. Validate command file exists and frontmatter is valid YAML
       4. Extract routing metadata from frontmatter
       5. Validate delegation safety (cycles, depth, session)
       6. Generate delegation context
     </process>
     <checkpoint>Command validated, arguments parsed, delegation context prepared</checkpoint>
   </stage>
   ```

**Line Reduction**: 751 → ~680 lines (71 lines saved, 9.5% reduction)

#### 1.3 Update All Commands to Reference Standard

**Files to Update**:
1. `.opencode/command/research.md`
2. `.opencode/command/implement.md`
3. `.opencode/command/plan.md`
4. `.opencode/command/task.md`
5. `.opencode/command/review.md`
6. `.opencode/command/errors.md`
7. `.opencode/command/todo.md`

**Pattern to Add** (after frontmatter, before main content):

```markdown
**Task Input**: $ARGUMENTS (see `.opencode/context/common/standards/command-argument-handling.md`)

**Usage**: /{command} TASK_NUMBER [OPTIONS]

**Examples**:
```bash
/{command} 197                    # Basic usage
/{command} 197 "custom prompt"    # With additional arguments
```
```

**Specific Changes**:

**research.md** (line 25):
```markdown
# BEFORE
**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 258`)

# AFTER
**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 258`)

See: `.opencode/context/common/standards/command-argument-handling.md` for argument handling standard.
```

**implement.md** (line 24):
```markdown
# BEFORE
**Usage:** `/implement TASK_NUMBER [PROMPT]` or `/implement START-END [PROMPT]`

# AFTER
**Usage:** `/implement TASK_NUMBER [PROMPT]` or `/implement START-END [PROMPT]`

See: `.opencode/context/common/standards/command-argument-handling.md` for argument handling standard.
```

**plan.md** (line 23):
```markdown
# BEFORE
**Usage:** `/plan TASK_NUMBER [PROMPT]`

# AFTER
**Usage:** `/plan TASK_NUMBER [PROMPT]`

See: `.opencode/context/common/standards/command-argument-handling.md` for argument handling standard.
```

**task.md** (line 14):
```markdown
# BEFORE
**Task Input (required):** $ARGUMENTS (task description; e.g., `/task "Implement feature X"`)

# AFTER
**Task Input (required):** $ARGUMENTS (task description; e.g., `/task "Implement feature X"`)

See: `.opencode/context/common/standards/command-argument-handling.md` for argument handling standard.

Note: /task is a direct command (no task number required).
```

**review.md** (line 28):
```markdown
# BEFORE
**Usage:** `/review [SCOPE]`

# AFTER
**Usage:** `/review [SCOPE]`

See: `.opencode/context/common/standards/command-argument-handling.md` for argument handling standard.

Note: /review is a direct command (no task number required).
```

**errors.md** (line 24):
```markdown
# BEFORE
**Usage:** `/errors [--all] [--type TYPE]`

# AFTER
**Usage:** `/errors [--all] [--type TYPE]`

See: `.opencode/context/common/standards/command-argument-handling.md` for argument handling standard.

Note: /errors is a direct command (no task number required).
```

**todo.md** (line 11):
```markdown
# BEFORE
(No usage documentation)

# AFTER
**Usage:** `/todo`

See: `.opencode/context/common/standards/command-argument-handling.md` for argument handling standard.

Note: /todo is a direct command with no arguments.
```

#### 1.4 Update Command Template

**File**: `.opencode/context/core/templates/command-template.md`

**Changes**:

1. **Update frontmatter section** (line 23-30):
   ```yaml
   context_loading:
     strategy: lazy
     index: ".opencode/context/index.md"
     required:
       - "core/standards/delegation.md"
       - "core/system/state-management.md"
       - "common/standards/command-argument-handling.md"  # ADD THIS
     optional:
       - "{domain-specific context files}"
     max_context_size: 50000
   ```

2. **Add argument handling section** (after line 36):
   ```markdown
   ## Argument Handling
   
   All commands MUST follow the standard defined in:
   `.opencode/context/common/standards/command-argument-handling.md`
   
   ### Task-Based Command Pattern
   
   Use for commands that operate on tasks from TODO.md (e.g., /research, /plan, /implement).
   
   ```markdown
   **Task Input (required):** $ARGUMENTS (task number; e.g., `/{command} 197`)
   
   See: `.opencode/context/common/standards/command-argument-handling.md`
   
   <workflow_setup>
     <stage_1_parse_arguments>
       1. Read task_number from $ARGUMENTS variable
       2. Validate task_number is positive integer
       3. Verify task exists in TODO.md
       4. Store task_number for prompt formatting
     </stage_1_parse_arguments>
     
     <stage_2_format_prompt>
       Format prompt as "Task: {task_number}" for subagent delegation
     </stage_2_format_prompt>
   </workflow_setup>
   ```
   
   ### Direct Command Pattern
   
   Use for commands that don't require task numbers (e.g., /meta, /review, /todo).
   
   ```markdown
   **Task Input (optional):** $ARGUMENTS (user input; e.g., `/{command} "options"`)
   
   See: `.opencode/context/common/standards/command-argument-handling.md`
   
   <workflow_setup>
     <stage_1_parse_arguments>
       1. Read $ARGUMENTS (may be empty)
       2. NO task validation required
       3. Store $ARGUMENTS for pass-through
     </stage_1_parse_arguments>
     
     <stage_2_format_prompt>
       Pass $ARGUMENTS as-is to subagent
     </stage_2_format_prompt>
   </workflow_setup>
   ```
   ```

**Deliverables**:
- [ ] New context file: `command-argument-handling.md` (~120 lines)
- [ ] Updated orchestrator: 751 → ~680 lines
- [ ] Updated 7 command files with standard references
- [ ] Updated command template with argument handling patterns

**Testing**:
- [ ] Test each command with valid task numbers
- [ ] Test each command with invalid task numbers
- [ ] Test each command with missing arguments
- [ ] Verify error messages match standard

---

### Phase 2: Optimize Orchestrator for Efficiency

**Priority**: MEDIUM  
**Effort**: 3-4 days  
**Impact**: Significant reduction in orchestrator complexity

#### 2.1 Extract Routing Logic to Context File

**File**: `.opencode/context/core/system/routing-logic.md`

**Purpose**: Extract language extraction and agent mapping logic from orchestrator.

**Content to Extract**: Orchestrator lines 162-299 (137 lines)

**Structure**:

```markdown
# Routing Logic Standard

## Overview

This standard defines how the orchestrator determines which agent to route commands to, including language-based routing for Lean-specific tasks.

## Language Extraction

For commands with `routing.language_based: true`, extract language from task metadata.

### Priority Order

1. **Priority 1**: Project state.json (task-specific)
2. **Priority 2**: TODO.md task entry (**Language** field)
3. **Priority 3**: Default "general" (fallback)

### Implementation

#### Priority 1: Project state.json

```bash
# Find task directory
task_dir=$(find .opencode/specs -maxdepth 1 -type d -name "${task_number}_*" | head -n 1)

# Extract language from state.json
if [ -n "$task_dir" ] && [ -f "${task_dir}/state.json" ]; then
  language=$(jq -r '.language // empty' "${task_dir}/state.json")
  
  if [ -n "$language" ]; then
    echo "[INFO] Language extracted from state.json: ${language}"
    # Use this language, skip to agent mapping
  fi
fi
```

#### Priority 2: TODO.md task entry

```bash
# Extract task entry (20 lines after task header)
task_entry=$(grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md)

# Extract Language field
language=$(echo "$task_entry" | grep "Language" | sed 's/\*\*Language\*\*: //' | tr -d ' ')

if [ -n "$language" ]; then
  echo "[INFO] Language extracted from TODO.md: ${language}"
  # Use this language, skip to agent mapping
fi
```

#### Priority 3: Default fallback

```bash
# If language still not found, default to "general"
language=${language:-general}

echo "[WARN] Language not found for task ${task_number}, defaulting to 'general'"
```

## Agent Mapping

Map extracted language to appropriate agent using routing table from command frontmatter.

### Routing Tables

Commands define routing in frontmatter:

```yaml
routing:
  language_based: true
  lean: lean-research-agent      # Agent for Lean tasks
  default: researcher             # Agent for all other tasks
```

### Mapping Logic

```bash
# Read routing table from command frontmatter
lean_agent=$(yq '.routing.lean' .opencode/command/${command}.md)
default_agent=$(yq '.routing.default' .opencode/command/${command}.md)

# Map language to agent
if [ "$language" == "lean" ]; then
  target_agent="$lean_agent"
  echo "[INFO] Routing to ${target_agent} (language=lean)"
else
  target_agent="$default_agent"
  echo "[INFO] Routing to ${target_agent} (language=${language})"
fi
```

### Common Routing Tables

| Command | Language | Agent |
|---------|----------|-------|
| /research | lean | lean-research-agent |
| /research | general | researcher |
| /implement | lean | lean-implementation-agent |
| /implement | general | implementer |
| /plan | any | planner (no language-based routing) |
| /review | any | reviewer (no language-based routing) |

## Routing Validation

Validate routing decision before delegation.

### Validation Steps

1. **Verify agent file exists**
   ```bash
   agent_file=".opencode/agent/subagents/${target_agent}.md"
   
   if [ ! -f "$agent_file" ]; then
     echo "[FAIL] Agent file not found: ${target_agent}"
     exit 1
   fi
   
   echo "[PASS] Agent file exists: ${agent_file}"
   ```

2. **Verify language matches agent capabilities**
   ```bash
   # Lean tasks must route to lean-* agents
   if [ "$language" == "lean" ] && [[ ! "$target_agent" =~ ^lean- ]]; then
     echo "[FAIL] Routing validation failed: language=lean but agent=${target_agent}"
     echo "Error: Lean task must route to lean-* agent"
     exit 1
   fi
   
   # Non-lean tasks must NOT route to lean-* agents
   if [ "$language" != "lean" ] && [[ "$target_agent" =~ ^lean- ]]; then
     echo "[FAIL] Routing validation failed: language=${language} but agent=${target_agent}"
     echo "Error: Non-lean task cannot route to lean-* agent"
     exit 1
   fi
   
   echo "[PASS] Routing validation succeeded"
   ```

3. **Update delegation path**
   ```bash
   delegation_path=["orchestrator", "${command}", "${target_agent}"]
   ```

## Direct Routing

For commands with `routing.language_based: false`, use direct routing.

### Implementation

```bash
# Read target_agent from command frontmatter
target_agent=$(yq '.routing.target_agent' .opencode/command/${command}.md)

# Verify agent file exists
agent_file=".opencode/agent/subagents/${target_agent}.md"

if [ ! -f "$agent_file" ]; then
  echo "[FAIL] Agent file not found: ${target_agent}"
  exit 1
fi

echo "[INFO] Routing to ${target_agent} (direct command)"
```

### Commands Using Direct Routing

| Command | Target Agent | Reason |
|---------|--------------|--------|
| /plan | planner | Planning is language-agnostic |
| /review | reviewer | Review is language-agnostic |
| /todo | (orchestrator) | No delegation |
| /task | (orchestrator) | No delegation |
| /errors | error-diagnostics-agent | Error analysis is language-agnostic |

## Error Handling

### Language Extraction Failed

**Symptom**: Cannot extract language from state.json or TODO.md

**Action**: Default to "general" and log warning

```bash
language=${language:-general}
echo "[WARN] Language not found for task ${task_number}, defaulting to 'general'"
```

**Impact**: Task routes to general agent instead of Lean-specific agent

**Resolution**: Add **Language** field to task entry in TODO.md

### Agent File Not Found

**Symptom**: Routing validation fails because agent file doesn't exist

**Action**: Abort with error

```bash
echo "[FAIL] Agent file not found: ${target_agent}"
echo "Error: Cannot route to ${target_agent} - agent file missing"
echo "Expected path: .opencode/agent/subagents/${target_agent}.md"
exit 1
```

**Resolution**: Create missing agent file or fix routing configuration

### Routing Mismatch

**Symptom**: Language doesn't match agent capabilities

**Action**: Abort with error

```bash
echo "[FAIL] Routing validation failed: language=${language} but agent=${target_agent}"
echo "Error: Lean task must route to lean-* agent"
exit 1
```

**Resolution**: Fix routing table in command frontmatter or correct task language

## Logging

All routing decisions are logged for debugging.

### Log Format

```
[INFO] Task {N} language: {language}
[INFO] Routing to {agent} (language={language})
[PASS] Routing validation succeeded
```

### Example Log

```
[INFO] Task 258 language: lean
[INFO] Routing to lean-research-agent (language=lean)
[PASS] Agent file exists: .opencode/agent/subagents/lean-research-agent.md
[PASS] Routing validation succeeded
```

## See Also

- Orchestrator: `.opencode/agent/orchestrator.md`
- Command Template: `.opencode/context/core/templates/command-template.md`
- Delegation Standard: `.opencode/context/core/standards/delegation.md`
```

**Estimated Size**: ~150 lines

**Benefits**:
- Routing logic is reusable and testable
- Orchestrator becomes simpler
- Clear documentation of routing patterns

#### 2.2 Extract Validation Rules to Context File

**File**: `.opencode/context/core/system/validation-rules.md`

**Purpose**: Extract return format and artifact validation logic from orchestrator.

**Content to Extract**: Orchestrator lines 376-463 (87 lines)

**Structure**:

```markdown
# Validation Rules Standard

## Overview

This standard defines validation rules for subagent returns, including return format validation and artifact verification.

## Return Format Validation

All subagents must return a standard JSON format (see `core/standards/delegation.md`).

### Required Fields

```json
{
  "status": "completed|partial|failed|blocked",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [...],
  "metadata": {
    "session_id": "...",
    "duration_seconds": 123,
    "agent_type": "...",
    "delegation_depth": 1,
    "delegation_path": [...]
  },
  "errors": [...],
  "next_steps": "..."
}
```

### Validation Steps

#### Step 1: Validate JSON Structure

```bash
# Parse return as JSON
if ! echo "$return" | jq . > /dev/null 2>&1; then
  echo "[FAIL] Invalid JSON return from ${agent}"
  exit 1
fi

echo "[PASS] Return is valid JSON"
```

#### Step 2: Validate Required Fields

```bash
# Check required fields exist
required_fields=("status" "summary" "artifacts" "metadata" "session_id")

for field in "${required_fields[@]}"; do
  if ! echo "$return" | jq -e ".${field}" > /dev/null 2>&1; then
    echo "[FAIL] Missing required field: ${field}"
    exit 1
  fi
done

echo "[PASS] All required fields present"
```

#### Step 3: Validate Status Field

```bash
# Check status is valid enum
status=$(echo "$return" | jq -r '.status')
valid_statuses=("completed" "partial" "failed" "blocked")

if [[ ! " ${valid_statuses[@]} " =~ " ${status} " ]]; then
  echo "[FAIL] Invalid status: ${status}"
  echo "Valid statuses: completed, partial, failed, blocked"
  exit 1
fi

echo "[PASS] Status is valid: ${status}"
```

#### Step 4: Validate Session ID

```bash
# Check session_id matches expected
returned_session_id=$(echo "$return" | jq -r '.session_id')

if [ "$returned_session_id" != "$expected_session_id" ]; then
  echo "[FAIL] Session ID mismatch"
  echo "Expected: ${expected_session_id}"
  echo "Got: ${returned_session_id}"
  exit 1
fi

echo "[PASS] Session ID matches"
```

#### Step 5: Validate Summary Token Limit

```bash
# Check summary is <100 tokens (~400 characters)
summary=$(echo "$return" | jq -r '.summary')
summary_length=${#summary}

if [ $summary_length -gt 400 ]; then
  echo "[WARN] Summary exceeds recommended length: ${summary_length} characters"
  # Non-critical warning, continue
fi
```

## Artifact Validation (CRITICAL)

Prevents "phantom research" - status=completed but no artifacts created.

### When to Validate

**Only validate artifacts if status == "completed"**

For partial/failed/blocked status, artifacts may be empty or incomplete.

### Validation Steps

#### Step 1: Check Artifacts Array is Non-Empty

```bash
if [ "$status" == "completed" ]; then
  artifact_count=$(echo "$return" | jq '.artifacts | length')
  
  if [ $artifact_count -eq 0 ]; then
    echo "[FAIL] Agent returned 'completed' status but created no artifacts"
    echo "Error: Phantom research detected - status=completed but no artifacts"
    exit 1
  fi
  
  echo "[INFO] Artifact count: ${artifact_count}"
fi
```

#### Step 2: Verify Each Artifact Exists

```bash
if [ "$status" == "completed" ]; then
  # Extract artifact paths
  artifact_paths=$(echo "$return" | jq -r '.artifacts[].path')
  
  for path in $artifact_paths; do
    # Check file exists
    if [ ! -f "$path" ]; then
      echo "[FAIL] Artifact does not exist: ${path}"
      exit 1
    fi
    
    echo "[PASS] Artifact exists: ${path}"
  done
fi
```

#### Step 3: Verify Each Artifact is Non-Empty

```bash
if [ "$status" == "completed" ]; then
  for path in $artifact_paths; do
    # Check file is non-empty (size > 0)
    if [ ! -s "$path" ]; then
      echo "[FAIL] Artifact is empty: ${path}"
      exit 1
    fi
    
    file_size=$(stat -f%z "$path" 2>/dev/null || stat -c%s "$path")
    echo "[PASS] Artifact is non-empty: ${path} (${file_size} bytes)"
  done
  
  echo "[PASS] ${artifact_count} artifacts validated"
fi
```

### Why This Matters

**Problem**: Agents may update status to "completed" without actually creating artifacts.

**Example**:
```json
{
  "status": "completed",
  "summary": "Research completed successfully",
  "artifacts": [],  // Empty! No research was actually done
  "metadata": {...}
}
```

**Impact**: User thinks research is done, but no research report exists.

**Solution**: Validate artifacts array is non-empty and all files exist.

## Error Handling

### Invalid JSON Return

**Error**:
```
[FAIL] Invalid JSON return from {agent}
Error: Cannot parse return as JSON
```

**Recommendation**: Fix {agent} subagent return format

### Missing Required Field

**Error**:
```
[FAIL] Missing required field: {field}
Error: Subagent return is incomplete
```

**Recommendation**: Fix {agent} subagent to include all required fields

### Invalid Status

**Error**:
```
[FAIL] Invalid status: {status}
Valid statuses: completed, partial, failed, blocked
```

**Recommendation**: Fix {agent} subagent to use valid status enum

### Session ID Mismatch

**Error**:
```
[FAIL] Session ID mismatch
Expected: {expected}
Got: {actual}
```

**Recommendation**: Fix {agent} subagent to return correct session_id

### Phantom Research Detected

**Error**:
```
[FAIL] Agent returned 'completed' status but created no artifacts
Error: Phantom research detected - status=completed but no artifacts
```

**Recommendation**: Verify {agent} creates artifacts before updating status

### Artifact Not Found

**Error**:
```
[FAIL] Artifact does not exist: {path}
Error: Artifact validation failed
```

**Recommendation**: Verify {agent} writes artifacts to correct paths

### Empty Artifact

**Error**:
```
[FAIL] Artifact is empty: {path}
Error: Artifact validation failed
```

**Recommendation**: Verify {agent} writes content to artifacts

## Validation Summary

After all validations pass, log summary:

```
[PASS] Return validation succeeded
[PASS] {N} artifacts validated
```

## See Also

- Delegation Standard: `.opencode/context/core/standards/delegation.md`
- Orchestrator: `.opencode/agent/orchestrator.md`
- State Management: `.opencode/context/core/system/state-management.md`
```

**Estimated Size**: ~100 lines

**Benefits**:
- Validation logic is reusable and testable
- Clear documentation of validation rules
- Prevents phantom research and other issues

#### 2.3 Simplify Orchestrator Structure

**File**: `.opencode/agent/orchestrator.md`

**Target**: Reduce from 751 → ~500 lines (33% reduction)

**Changes**:

1. **Replace inline routing logic** with reference to `routing-logic.md`
   - Lines 162-299 (137 lines) → 10 lines with reference
   - Savings: 127 lines

2. **Replace inline validation** with reference to `validation-rules.md`
   - Lines 376-463 (87 lines) → 10 lines with reference
   - Savings: 77 lines

3. **Replace inline argument handling** with reference to `command-argument-handling.md`
   - Lines 54-90 (36 lines) → 8 lines with reference (already done in Phase 1)
   - Savings: 28 lines

**Total Savings**: 232 lines (31% reduction)

**New Structure**:

```xml
<workflow_execution>
  <stage id="1" name="PreflightValidation">
    <action>Load command, validate, parse arguments, and prepare delegation context</action>
    <process>
      See: @.opencode/context/common/standards/command-argument-handling.md
      
      1. Determine command type (task-based or direct)
      2. Parse arguments according to command type
      3. Validate command file and frontmatter
      4. Generate delegation context
    </process>
    <checkpoint>Command validated, arguments parsed, delegation context prepared</checkpoint>
  </stage>

  <stage id="2" name="DetermineRouting">
    <action>Extract language and determine target agent</action>
    <process>
      See: @.opencode/context/core/system/routing-logic.md
      
      1. Check if language-based routing enabled
      2. Extract language (if needed)
      3. Map language to agent
      4. Validate routing decision
    </process>
    <checkpoint>Target agent determined and validated</checkpoint>
  </stage>

  <stage id="3" name="RegisterAndDelegate">
    <action>Register session and invoke target agent</action>
    <process>
      1. Register delegation in session registry
      2. Format prompt based on command type:
         - Task-based: "Task: {task_number}"
         - Direct: $ARGUMENTS as-is
      3. Invoke target agent using task tool
      4. Monitor for timeout
    </process>
    <checkpoint>Session registered and agent invoked</checkpoint>
  </stage>

  <stage id="4" name="ValidateReturn">
    <action>Validate agent return format and content</action>
    <process>
      See: @.opencode/context/core/system/validation-rules.md
      
      1. Validate JSON structure
      2. Validate required fields
      3. Validate status enum
      4. Validate session_id
      5. Validate artifacts (if status=completed)
    </process>
    <checkpoint>Return validated and artifacts verified</checkpoint>
  </stage>

  <stage id="5" name="PostflightCleanup">
    <action>Update session registry and format user response</action>
    <process>
      1. Update registry entry
      2. Remove from active registry
      3. Format response for user
      4. Return to user
    </process>
    <checkpoint>Session cleaned up and result returned to user</checkpoint>
  </stage>
</workflow_execution>
```

**Deliverables**:
- [ ] New context file: `routing-logic.md` (~150 lines)
- [ ] New context file: `validation-rules.md` (~100 lines)
- [ ] Updated orchestrator: 751 → ~500 lines (33% reduction)

**Testing**:
- [ ] Test language extraction (state.json → TODO.md → default)
- [ ] Test agent mapping (lean → lean-*, default → general)
- [ ] Test routing validation
- [ ] Test return format validation
- [ ] Test artifact validation (prevents phantom research)

---

### Phase 3: Improve Context File Organization

**Priority**: MEDIUM  
**Effort**: 2 days  
**Impact**: Eliminate confusion, ensure accuracy

#### 3.1 Fix Deprecated File References

**Problem**: Commands reference deprecated context files.

**Files to Update**:
1. `.opencode/command/research.md`
2. `.opencode/command/implement.md`
3. `.opencode/command/plan.md`
4. `.opencode/command/review.md`
5. `.opencode/command/errors.md`

**Changes**:

**Pattern to Find**:
```bash
grep -r "subagent-return-format.md" .opencode/command/
grep -r "status-transitions.md" .opencode/command/
```

**Pattern to Replace**:

```yaml
# BEFORE
context_loading:
  required:
    - "core/standards/subagent-return-format.md"
    - "core/workflows/status-transitions.md"
    - "core/system/routing-guide.md"

# AFTER
context_loading:
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"
    - "common/standards/command-argument-handling.md"
```

**Rationale**: Per `context/index.md` lines 306-310:
- `subagent-return-format.md` → deprecated, use `delegation.md`
- `status-transitions.md` → deprecated, use `state-management.md`

**Script to Apply Changes**:

```bash
#!/bin/bash

# Update all command files
for file in .opencode/command/*.md; do
  # Replace deprecated references
  sed -i 's|core/standards/subagent-return-format.md|core/standards/delegation.md|g' "$file"
  sed -i 's|core/workflows/status-transitions.md|core/system/state-management.md|g' "$file"
  
  # Add command-argument-handling.md if not present
  if ! grep -q "command-argument-handling.md" "$file"; then
    # Add after delegation.md line
    sed -i '/delegation.md/a\    - "common/standards/command-argument-handling.md"' "$file"
  fi
done

echo "Updated all command files"
```

#### 3.2 Update Context Index

**File**: `.opencode/context/index.md`

**Changes**:

1. **Add new files to Core System section** (after line 47):
   ```markdown
   - **routing-logic.md** (150 lines) - Language extraction and agent mapping
     - Language extraction priority (state.json → TODO.md → default)
     - Agent mapping tables (lean → lean-*, default → general)
     - Routing validation rules
     - Direct routing patterns
   
   - **validation-rules.md** (100 lines) - Return format and artifact validation
     - Required field validation
     - Artifact existence checks (prevents phantom research)
     - Error handling patterns
     - Validation summary logging
   ```

2. **Add to Common Standards section** (after line 64):
   ```markdown
   - **command-argument-handling.md** (120 lines) - $ARGUMENTS parsing and validation
     - Task-based vs direct command patterns
     - Task number extraction and validation
     - Prompt formatting for subagent delegation
     - Error messages and troubleshooting
   ```

3. **Update line counts** for modified files:
   ```markdown
   ## Core System (core/system/)
   
   **Consolidated files** - Load for state management, artifacts, git, routing, validation
   
   - **state-management.md** (535 lines) - Unified state management standard
     [... existing content ...]
   
   - **routing-logic.md** (150 lines) - Language extraction and agent mapping
     [NEW - see above]
   
   - **validation-rules.md** (100 lines) - Return format and artifact validation
     [NEW - see above]
   ```

4. **Update Quick Navigation section** (bottom of file):
   ```markdown
   ## Quick Navigation
   
   **For Delegation**: → `core/standards/delegation.md`  
   **For State Management**: → `core/system/state-management.md`  
   **For Routing**: → `core/system/routing-logic.md`  
   **For Validation**: → `core/system/validation-rules.md`  
   **For Command Arguments**: → `common/standards/command-argument-handling.md`  
   **For Artifacts**: → `common/system/artifact-management.md`  
   **For Git Commits**: → `common/system/git-commits.md`  
   **For Task Format**: → `common/standards/tasks.md`  
   **For Plan Format**: → `common/standards/plan.md`  
   **For Lean Style**: → `project/lean4/standards/lean4-style-guide.md`  
   **For Proof Conventions**: → `project/logic/standards/proof-conventions.md`
   ```

5. **Update Context Loading Examples** (lines 243-286):
   ```markdown
   **Research Workflow (researcher.md)**:
   ```
   Stage 4 loads:
   - @.opencode/context/core/standards/delegation.md
   - @.opencode/context/core/system/state-management.md
   - @.opencode/context/common/system/artifact-management.md
   - @.opencode/context/common/standards/command-argument-handling.md
   - grep -A 50 "^### {task_number}\." .opencode/specs/TODO.md
   - @.opencode/specs/state.json
   
   Language-specific:
   - If lean: @.opencode/context/project/lean4/tools/leansearch-api.md
   - If markdown: (no additional context)
   ```
   ```

**Deliverables**:
- [ ] All deprecated references fixed in command files
- [ ] Context index updated with new files
- [ ] Line counts accurate
- [ ] Quick navigation updated
- [ ] Loading examples updated

**Testing**:
- [ ] Verify no broken references: `grep -r "subagent-return-format.md" .opencode/`
- [ ] Verify all new files listed in index
- [ ] Verify line counts match actual files

---

### Phase 4: Enhance Documentation

**Priority**: HIGH  
**Effort**: 3 days  
**Impact**: Improved developer experience

#### 4.1 Create Command Development Guide

**File**: `.opencode/docs/guides/creating-commands.md`

**Purpose**: Comprehensive guide for creating new commands that work with orchestrator.

**Content**: See detailed structure in main plan above (too long to repeat here).

**Estimated Size**: ~400 lines

**Sections**:
1. Overview
2. Prerequisites
3. Step-by-Step Process
4. Common Patterns
5. Troubleshooting
6. See Also

#### 4.2 Update README.md

**File**: `.opencode/README.md`

**Changes**:

1. **Add "Command Argument Patterns" section** (after command list):
   ```markdown
   ## Command Argument Patterns
   
   All commands follow standardized argument handling (see `context/common/standards/command-argument-handling.md`).
   
   ### Task-Based Commands
   
   Commands that operate on tasks from TODO.md:
   
   | Command | Usage | Description |
   |---------|-------|-------------|
   | /research | `/research TASK_NUMBER [PROMPT]` | Conduct research for task |
   | /plan | `/plan TASK_NUMBER [PROMPT]` | Create implementation plan |
   | /implement | `/implement TASK_NUMBER [PROMPT]` | Execute implementation |
   
   **Pattern**: Task number is parsed from `$ARGUMENTS`, validated, and formatted as `"Task: {number}"` for subagent.
   
   **Example**:
   ```bash
   /research 176                    # Research task 176
   /research 176 "focus on API"     # Research with custom focus
   ```
   
   ### Direct Commands
   
   Commands that don't require task numbers:
   
   | Command | Usage | Description |
   |---------|-------|-------------|
   | /meta | `/meta [PROMPT]` | Interactive system builder |
   | /review | `/review [SCOPE]` | Analyze codebase and update registries |
   | /todo | `/todo` | Archive completed/abandoned tasks |
   | /errors | `/errors [--all] [--type TYPE]` | Analyze errors.json |
   
   **Pattern**: `$ARGUMENTS` passed as-is to subagent (may be empty).
   
   **Example**:
   ```bash
   /meta                            # Start meta builder
   /review lean                     # Review Lean code only
   /errors --all                    # Analyze all errors
   ```
   
   ### Creating New Commands
   
   See: `.opencode/docs/guides/creating-commands.md`
   
   Key requirements:
   - Follow command template (`.opencode/context/core/templates/command-template.md`)
   - Implement standard argument handling
   - Document usage with examples
   - Test with orchestrator
   ```

2. **Add "Standards Quick Reference" section**:
   ```markdown
   ## Standards Quick Reference
   
   Quick links to common standards:
   
   | Standard | File | Purpose |
   |----------|------|---------|
   | Command Arguments | `common/standards/command-argument-handling.md` | $ARGUMENTS parsing and validation |
   | Delegation | `core/standards/delegation.md` | Subagent return format and delegation patterns |
   | State Management | `core/system/state-management.md` | Status markers and state schemas |
   | Routing Logic | `core/system/routing-logic.md` | Language extraction and agent mapping |
   | Validation Rules | `core/system/validation-rules.md` | Return format and artifact validation |
   | Task Format | `common/standards/tasks.md` | Task entry format and required fields |
   
   See `.opencode/docs/STANDARDS_QUICK_REF.md` for detailed quick reference.
   ```

#### 4.3 Create Standards Quick Reference

**File**: `.opencode/docs/STANDARDS_QUICK_REF.md`

**Purpose**: One-page quick reference for common standards.

**Content**: See detailed structure in main plan above.

**Estimated Size**: ~150 lines

**Sections**:
1. Command Argument Handling
2. Delegation Standard
3. State Management
4. Task Format
5. Context Loading
6. Git Commits
7. Artifact Management
8. Quick Navigation

**Deliverables**:
- [ ] New guide: `creating-commands.md` (~400 lines)
- [ ] Updated README.md with argument patterns and standards
- [ ] New quick reference: `STANDARDS_QUICK_REF.md` (~150 lines)

**Testing**:
- [ ] Verify all links work
- [ ] Verify examples are accurate
- [ ] Get feedback from developers

---

### Phase 5: Meta Command Optimization

**Priority**: MEDIUM  
**Effort**: 2 days  
**Impact**: Ensure generated commands follow all standards

#### 5.1 Update Meta Command Templates

**File**: `.opencode/agent/subagents/meta/command-creator.md`

**Changes**:

1. **Add argument handling to generation logic**:
   ```xml
   <command_generation>
     <argument_handling>
       1. Determine if command is task-based or direct
       2. Add appropriate $ARGUMENTS documentation
       3. Include reference to command-argument-handling.md
       4. Add validation logic for task numbers (if task-based)
       5. Add error handling for missing/invalid arguments
       6. Add usage examples showing $ARGUMENTS
     </argument_handling>
     
     <frontmatter>
       Include in context_loading.required:
       - "core/standards/delegation.md"
       - "core/system/state-management.md"
       - "common/standards/command-argument-handling.md"
     </frontmatter>
     
     <validation>
       Ensure generated command includes:
       - [ ] $ARGUMENTS documentation
       - [ ] Reference to command-argument-handling.md
       - [ ] Appropriate parsing logic (task-based or direct)
       - [ ] Error handling for invalid arguments
       - [ ] Usage examples
     </validation>
   </command_generation>
   ```

2. **Update command template used by meta**:
   ```markdown
   ## Generated Command Template
   
   When generating commands, use this template:
   
   ```markdown
   ---
   name: {command_name}
   agent: orchestrator
   description: "{description}"
   context_level: 2
   language: {language}
   routing:
     language_based: {true|false}
     {routing_config}
   context_loading:
     strategy: lazy
     index: ".opencode/context/index.md"
     required:
       - "core/standards/delegation.md"
       - "core/system/state-management.md"
       - "common/standards/command-argument-handling.md"
     max_context_size: 50000
   ---
   
   **Task Input**: $ARGUMENTS ({description})
   
   See: `.opencode/context/common/standards/command-argument-handling.md` for argument handling standard.
   
   **Usage**: /{command_name} {usage_pattern}
   
   **Examples**:
   ```bash
   {examples}
   ```
   
   <workflow_setup>
     {workflow_stages}
   </workflow_setup>
   ```
   ```

#### 5.2 Update Meta Context Files

**File**: `.opencode/context/meta/agent-templates.md`

**Changes**:

1. **Add command argument handling template section**:
   ```markdown
   ## Command Argument Handling Template
   
   All generated commands MUST follow the argument handling standard.
   
   ### Task-Based Command Template
   
   Use for commands that operate on tasks from TODO.md.
   
   ```markdown
   **Task Input (required):** $ARGUMENTS (task number; e.g., `/{command} 197`)
   
   See: `.opencode/context/common/standards/command-argument-handling.md`
   
   <workflow_setup>
     <stage_1_parse_arguments>
       1. Read task_number from $ARGUMENTS variable
       2. Validate task_number is positive integer
       3. Verify task exists in TODO.md
       4. Store task_number for prompt formatting
     </stage_1_parse_arguments>
     
     <stage_2_format_prompt>
       Format prompt as "Task: {task_number}" for subagent delegation
     </stage_2_format_prompt>
   </workflow_setup>
   ```
   
   ### Direct Command Template
   
   Use for commands that don't require task numbers.
   
   ```markdown
   **Task Input (optional):** $ARGUMENTS (user input; e.g., `/{command} "options"`)
   
   See: `.opencode/context/common/standards/command-argument-handling.md`
   
   <workflow_setup>
     <stage_1_parse_arguments>
       1. Read $ARGUMENTS (may be empty)
       2. NO task validation required
       3. Store $ARGUMENTS for pass-through
     </stage_1_parse_arguments>
     
     <stage_2_format_prompt>
       Pass $ARGUMENTS as-is to subagent
     </stage_2_format_prompt>
   </workflow_setup>
   ```
   ```

2. **Update validation checklist**:
   ```markdown
   ## Generated Command Validation
   
   Before delivering generated command, verify:
   
   - [ ] Frontmatter includes all required fields
   - [ ] Context loading includes command-argument-handling.md
   - [ ] $ARGUMENTS documentation is present
   - [ ] Reference to command-argument-handling.md is included
   - [ ] Appropriate parsing logic (task-based or direct)
   - [ ] Error handling for invalid arguments
   - [ ] Usage examples show $ARGUMENTS usage
   - [ ] Command follows template structure
   - [ ] All context file references are valid (not deprecated)
   ```

**Deliverables**:
- [ ] Updated command-creator.md with argument handling
- [ ] Updated agent-templates.md with command templates
- [ ] Validation checklist for generated commands

**Testing**:
- [ ] Generate test command with /meta
- [ ] Verify generated command follows standards
- [ ] Verify generated command works with orchestrator
- [ ] Verify argument handling is correct

---

## Implementation Roadmap

### Week 1: Foundation (Phase 1)

**Days 1-2**: Create command-argument-handling.md
- [ ] Write standard document (~120 lines)
- [ ] Include examples for both command types
- [ ] Add validation rules and error messages
- [ ] Add troubleshooting section

**Day 3**: Update orchestrator
- [ ] Add command-argument-handling.md to context_loading
- [ ] Simplify critical_instructions section
- [ ] Update Stage 1 (PreflightValidation)
- [ ] Test orchestrator still works

**Day 4**: Update all commands
- [ ] Update research.md
- [ ] Update implement.md
- [ ] Update plan.md
- [ ] Update task.md
- [ ] Update review.md
- [ ] Update errors.md
- [ ] Update todo.md

**Day 5**: Update command template
- [ ] Add argument handling section
- [ ] Add examples for both patterns
- [ ] Update frontmatter template
- [ ] Test template with new command

**Deliverables**:
- ✅ New context file: command-argument-handling.md
- ✅ Updated orchestrator (751 → ~680 lines)
- ✅ All 7 commands reference standard
- ✅ Updated command template

### Week 2: Optimization (Phase 2)

**Days 1-2**: Extract routing logic
- [ ] Create routing-logic.md (~150 lines)
- [ ] Extract language extraction logic
- [ ] Extract agent mapping logic
- [ ] Extract routing validation
- [ ] Update orchestrator to reference file

**Day 3**: Extract validation rules
- [ ] Create validation-rules.md (~100 lines)
- [ ] Extract return format validation
- [ ] Extract artifact validation
- [ ] Extract error handling
- [ ] Update orchestrator to reference file

**Days 4-5**: Simplify orchestrator
- [ ] Replace inline routing with reference
- [ ] Replace inline validation with reference
- [ ] Test all stages still work
- [ ] Verify line count reduction (751 → ~500)

**Deliverables**:
- ✅ New context file: routing-logic.md
- ✅ New context file: validation-rules.md
- ✅ Simplified orchestrator (~500 lines)

### Week 3: Organization (Phase 3)

**Day 1**: Fix deprecated references
- [ ] Run grep to find all deprecated references
- [ ] Update all command files
- [ ] Test commands still load correct context
- [ ] Verify no broken references

**Day 2**: Update context index
- [ ] Add new files to index
- [ ] Update line counts
- [ ] Update quick navigation
- [ ] Update loading examples

**Days 3-5**: Verify accuracy
- [ ] Check all context files exist
- [ ] Verify all references are valid
- [ ] Test context loading in workflows
- [ ] Fix any issues found

**Deliverables**:
- ✅ All deprecated references fixed
- ✅ Updated context index
- ✅ No broken references

### Week 4: Documentation (Phase 4)

**Days 1-2**: Create command development guide
- [ ] Write overview and prerequisites
- [ ] Write step-by-step process
- [ ] Add common patterns
- [ ] Add troubleshooting section
- [ ] Add examples

**Day 3**: Update README.md
- [ ] Add command argument patterns section
- [ ] Add standards quick reference section
- [ ] Update command list
- [ ] Add links to new guides

**Day 4**: Create standards quick reference
- [ ] Write quick reference for each standard
- [ ] Add quick navigation table
- [ ] Add examples
- [ ] Test all links

**Day 5**: Review and polish
- [ ] Review all documentation
- [ ] Fix any issues
- [ ] Get feedback
- [ ] Make final updates

**Deliverables**:
- ✅ New guide: creating-commands.md
- ✅ Updated README.md
- ✅ New quick reference: STANDARDS_QUICK_REF.md

### Week 5: Meta Integration (Phase 5)

**Days 1-2**: Update meta command templates
- [ ] Update command-creator.md
- [ ] Add argument handling to generation logic
- [ ] Update command template
- [ ] Add validation checklist

**Day 3**: Update meta context files
- [ ] Update agent-templates.md
- [ ] Add command argument templates
- [ ] Update validation checklist

**Days 4-5**: Test meta-generated commands
- [ ] Generate test command with /meta
- [ ] Verify it follows all standards
- [ ] Test with orchestrator
- [ ] Fix any issues

**Deliverables**:
- ✅ Updated command-creator.md
- ✅ Updated agent-templates.md
- ✅ Meta generates standards-compliant commands

---

## Success Metrics

### Efficiency Improvements

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Orchestrator Size | 751 lines | ~500 lines | 33% reduction |
| Context Window (Routing) | ~15% | <10% | 33% reduction |
| Command Creation Time | ~2 hours | ~1 hour | 50% reduction |

### Consistency Improvements

| Metric | Target | Status |
|--------|--------|--------|
| Commands Following Argument Standard | 100% | To be achieved |
| Broken Context References | 0 | To be achieved |
| Documentation Coverage | 100% | To be achieved |

### Functionality Improvements

| Feature | Status |
|---------|--------|
| Standardized Error Messages | To be implemented |
| Consistent Task Validation | To be implemented |
| Meta-Generated Commands Compliant | To be implemented |

---

## Testing Plan

### Unit Tests

#### Argument Parsing Tests
- [ ] Test task number extraction from $ARGUMENTS
- [ ] Test validation of positive integers
- [ ] Test task existence verification
- [ ] Test error handling for invalid inputs
- [ ] Test prompt formatting (task-based vs direct)

#### Routing Logic Tests
- [ ] Test language extraction from state.json
- [ ] Test language extraction from TODO.md
- [ ] Test default fallback to "general"
- [ ] Test agent mapping (lean → lean-*, default → general)
- [ ] Test routing validation (file exists, language matches)

#### Validation Rules Tests
- [ ] Test JSON structure validation
- [ ] Test required field validation
- [ ] Test status enum validation
- [ ] Test session_id validation
- [ ] Test artifact existence checks
- [ ] Test artifact non-empty checks

### Integration Tests

#### Command Execution Tests
- [ ] Test /research with valid task number
- [ ] Test /research with invalid task number
- [ ] Test /research with missing task number
- [ ] Test /implement with valid task number
- [ ] Test /plan with valid task number
- [ ] Test /meta with no arguments
- [ ] Test /review with scope argument
- [ ] Test /errors with flags

#### Orchestrator Flow Tests
- [ ] Test full workflow (Preflight → Routing → Delegation → Validation → Postflight)
- [ ] Test timeout handling
- [ ] Test cycle detection
- [ ] Test delegation depth limits
- [ ] Test session tracking

#### Meta Generation Tests
- [ ] Test meta-generated task-based command
- [ ] Test meta-generated direct command
- [ ] Verify generated commands follow argument standard
- [ ] Verify generated commands work with orchestrator
- [ ] Verify generated commands have correct context loading

### End-to-End Tests

#### Complete Workflow Tests
- [ ] /task → /research → /plan → /implement → /review
- [ ] Verify argument handling at each step
- [ ] Verify status transitions
- [ ] Verify artifact creation
- [ ] Verify git commits

#### Error Scenario Tests
- [ ] Missing task number
- [ ] Invalid task number (non-integer)
- [ ] Non-existent task
- [ ] Delegation timeout
- [ ] Phantom research (status=completed but no artifacts)
- [ ] Invalid return format

---

## Maintenance Plan

### Monthly Reviews

**First Monday of Each Month**:
- [ ] Review context file sizes (target: <300 lines each)
- [ ] Check for deprecated file references
- [ ] Update documentation for new patterns
- [ ] Review orchestrator efficiency metrics

### Quarterly Audits

**First Week of Each Quarter**:
- [ ] Audit all commands for standard compliance
- [ ] Review orchestrator efficiency (context window usage)
- [ ] Update templates based on learnings
- [ ] Collect feedback from developers
- [ ] Update improvement plan based on findings

### Continuous Improvement

**Ongoing**:
- Track command creation time
- Monitor context window usage during routing
- Collect feedback from developers
- Document new patterns and anti-patterns
- Update standards as needed

---

## Risk Assessment

### High Risk

**Risk**: Breaking existing commands during orchestrator refactoring  
**Mitigation**: 
- Test each command after changes
- Keep backup of orchestrator before changes
- Implement changes incrementally
- Test full workflows end-to-end

**Risk**: Deprecated file references cause context loading failures  
**Mitigation**:
- Run grep to find all references before changes
- Update all references atomically
- Test context loading after changes
- Verify no broken references

### Medium Risk

**Risk**: Meta-generated commands don't follow new standards  
**Mitigation**:
- Update meta templates before Phase 5
- Add validation checklist to meta
- Test generated commands thoroughly
- Document meta generation patterns

**Risk**: Documentation becomes outdated  
**Mitigation**:
- Update documentation with each change
- Review documentation monthly
- Keep documentation close to code
- Use examples from actual commands

### Low Risk

**Risk**: Context file sizes exceed targets  
**Mitigation**:
- Monitor file sizes during creation
- Split large files if needed
- Review file sizes monthly
- Consolidate duplicated content

---

## Rollback Plan

If issues arise during implementation:

### Phase 1 Rollback
- Restore orchestrator.md from backup
- Remove command-argument-handling.md
- Revert command file changes
- Revert command template changes

### Phase 2 Rollback
- Restore orchestrator.md from backup
- Remove routing-logic.md and validation-rules.md
- Revert context index changes

### Phase 3 Rollback
- Restore command files from backup
- Restore context index from backup

### Phase 4 Rollback
- Remove new documentation files
- Restore README.md from backup

### Phase 5 Rollback
- Restore meta command files from backup
- Restore meta context files from backup

**Backup Strategy**:
- Create git branch before each phase
- Tag each phase completion
- Keep backups of modified files
- Document rollback procedures

---

## Appendix: File Changes Summary

### New Files (8)

1. `.opencode/context/common/standards/command-argument-handling.md` (~120 lines)
2. `.opencode/context/core/system/routing-logic.md` (~150 lines)
3. `.opencode/context/core/system/validation-rules.md` (~100 lines)
4. `.opencode/docs/guides/creating-commands.md` (~400 lines)
5. `.opencode/docs/STANDARDS_QUICK_REF.md` (~150 lines)

**Total New Lines**: ~920 lines

### Modified Files (17)

1. `.opencode/agent/orchestrator.md` (751 → ~500 lines, -251 lines)
2. `.opencode/command/research.md` (+5 lines)
3. `.opencode/command/implement.md` (+5 lines)
4. `.opencode/command/plan.md` (+5 lines)
5. `.opencode/command/task.md` (+5 lines)
6. `.opencode/command/review.md` (+5 lines)
7. `.opencode/command/errors.md` (+5 lines)
8. `.opencode/command/todo.md` (+5 lines)
9. `.opencode/context/index.md` (+30 lines)
10. `.opencode/context/core/templates/command-template.md` (+50 lines)
11. `.opencode/agent/subagents/meta/command-creator.md` (+40 lines)
12. `.opencode/context/meta/agent-templates.md` (+60 lines)
13. `.opencode/README.md` (+80 lines)
14. `.opencode/ARCHITECTURE.md` (+20 lines)
15. `.opencode/QUICK-START.md` (+30 lines)

**Total Modified Lines**: +94 lines (after orchestrator reduction)

### Net Impact

- **New Lines**: +920 lines
- **Removed Lines**: -251 lines (orchestrator consolidation)
- **Modified Lines**: +94 lines
- **Net Change**: +763 lines
- **Efficiency Gain**: 33% reduction in orchestrator, <10% routing context

---

## Next Steps

### Immediate Actions

1. **Review this plan** with stakeholders
2. **Prioritize phases** based on immediate needs
3. **Create git branch** for implementation
4. **Set up testing environment**

### Phase 1 Kickoff

1. **Create command-argument-handling.md** (Day 1)
2. **Update orchestrator** (Day 2)
3. **Update commands** (Day 3)
4. **Update template** (Day 4)
5. **Test and validate** (Day 5)

### Questions to Address

1. Should we implement all phases or prioritize specific ones?
2. Do we need additional testing beyond what's outlined?
3. Are there other commands or agents that need updating?
4. Should we create additional documentation or guides?

---

## Conclusion

This improvement plan provides a systematic approach to enhancing the ProofChecker .opencode system for:

- **Efficiency**: 33% reduction in orchestrator size, <10% routing context
- **Consistency**: 100% command compliance with argument handling standard
- **Functionality**: Robust validation, clear error messages, meta integration
- **Maintainability**: Clear documentation, reusable context files, testable logic

The plan is structured in 5 phases over 5 weeks, with clear deliverables, testing requirements, and success metrics. Each phase builds on the previous one, ensuring a smooth transition and minimal disruption to existing workflows.

**Ready to proceed with Phase 1?**
