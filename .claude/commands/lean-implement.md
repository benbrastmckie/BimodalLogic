---
allowed-tools: Task, TodoWrite, Bash, Read, Grep, Glob
argument-hint: [plan-file] [starting-phase] [--mode=auto|lean-only|software-only] [--max-iterations=N]
description: Hybrid implementation command for mixed Lean/software plans with intelligent phase routing
command-type: primary
subcommands:
  - auto: "Automatically detect phase type and route to appropriate coordinator (default)"
  - lean-only: "Execute only Lean phases (theorem proving)"
  - software-only: "Execute only software phases (implementation)"
dependent-agents:
  - lean-coordinator
  - implementer-coordinator
library-requirements:
  - error-handling.sh: ">=1.0.0"
  - state-persistence.sh: ">=1.6.0"
  - workflow-state-machine.sh: ">=2.0.0"
documentation: See .claude/docs/guides/commands/lean-implement-command-guide.md for usage
---

# /lean-implement - Hybrid Lean/Software Implementation Command

YOU ARE EXECUTING a hybrid implementation workflow that intelligently routes plan phases to appropriate coordinators: lean-coordinator for theorem proving (Lean) phases and implementer-coordinator for software implementation phases.

**Workflow Type**: implement-only
**Expected Input**: Plan file with mixed Lean/software phases
**Expected Output**: Completed implementation with proofs and code

## Phase Classification

The command uses a 2-tier detection algorithm to classify each phase:

### Tier 1: Phase-Specific Metadata (Strongest Signal)
```markdown
### Phase 1: Prove Modal Axioms [NOT STARTED]
lean_file: /path/to/Modal.lean

Tasks:
- [ ] Prove theorem_K
```
If `lean_file:` metadata exists, phase is classified as "lean".

### Tier 2: Keyword and Extension Analysis
- **Lean indicators**: `.lean`, `theorem`, `lemma`, `sorry`, `tactic`, `mathlib`, `lean_`
- **Software indicators**: `.ts`, `.js`, `.py`, `.sh`, `.md`, `implement`, `create`, `write tests`

Default: "software" for ambiguous phases (conservative approach).

## Block 1a: Setup & Phase Classification

**EXECUTE NOW**: The user invoked `/lean-implement [plan-file] [starting-phase] [--mode=auto|lean-only|software-only] [--max-iterations=N]`. This block captures arguments, classifies phases, initializes workflow state, and prepares routing map.

In the **bash block below**, replace `YOUR_LEAN_IMPLEMENT_ARGS_HERE` with the actual arguments.

**Examples**:
- If user ran `/lean-implement plan.md`, change to: `echo "plan.md" > "$TEMP_FILE"`
- If user ran `/lean-implement plan.md 3 --mode=lean-only`, change to: `echo "plan.md 3 --mode=lean-only" > "$TEMP_FILE"`

```bash
# === PREPROCESSING SAFETY ===
set +H 2>/dev/null || true
set +o histexpand 2>/dev/null || true
set -e  # Fail-fast

# === PRE-TRAP ERROR BUFFER ===
declare -a _EARLY_ERROR_BUFFER=()

# DEBUG_LOG initialization
DEBUG_LOG="${HOME}/.claude/tmp/workflow_debug.log"
mkdir -p "$(dirname "$DEBUG_LOG")" 2>/dev/null

# === CAPTURE LEAN-IMPLEMENT ARGUMENTS ===
mkdir -p "${HOME}/.claude/tmp" 2>/dev/null || true
TEMP_FILE="${HOME}/.claude/tmp/lean_implement_arg_$(date +%s%N).txt"
# SUBSTITUTE THE LEAN-IMPLEMENT ARGUMENTS IN THE LINE BELOW
echo "YOUR_LEAN_IMPLEMENT_ARGS_HERE" > "$TEMP_FILE"
echo "$TEMP_FILE" > "${HOME}/.claude/tmp/lean_implement_arg_path.txt"

# === READ AND PARSE ARGUMENTS ===
LEAN_IMPLEMENT_ARGS=$(cat "$TEMP_FILE" 2>/dev/null || echo "")

# === DETECT PROJECT DIRECTORY ===
if command -v git &>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
  CLAUDE_PROJECT_DIR="$(git rev-parse --show-toplevel)"
else
  current_dir="$(pwd)"
  while [ "$current_dir" != "/" ]; do
    if [ -d "$current_dir/.claude" ]; then
      CLAUDE_PROJECT_DIR="$current_dir"
      break
    fi
    current_dir="$(dirname "$current_dir")"
  done
fi

if [ -z "$CLAUDE_PROJECT_DIR" ] || [ ! -d "$CLAUDE_PROJECT_DIR/.claude" ]; then
  echo "ERROR: Failed to detect project directory" >&2
  exit 1
fi

export CLAUDE_PROJECT_DIR

# === SOURCE LIBRARIES (Three-Tier Pattern) ===
# Tier 1: Critical Foundation (fail-fast required)
source "${CLAUDE_PROJECT_DIR}/.claude/lib/core/error-handling.sh" 2>/dev/null || {
  echo "ERROR: Failed to source error-handling.sh" >&2
  exit 1
}

_source_with_diagnostics "${CLAUDE_PROJECT_DIR}/.claude/lib/core/state-persistence.sh" || exit 1
_source_with_diagnostics "${CLAUDE_PROJECT_DIR}/.claude/lib/workflow/workflow-state-machine.sh" || exit 1
_source_with_diagnostics "${CLAUDE_PROJECT_DIR}/.claude/lib/core/library-version-check.sh" || exit 1

# === INITIALIZE ERROR LOGGING ===
ensure_error_log_exists

# === SETUP EARLY BASH ERROR TRAP ===
setup_bash_error_trap "/lean-implement" "lean_implement_early_$(date +%s)" "early_init"

# Flush any early errors
_flush_early_errors

# Tier 2: Workflow Support (graceful degradation)
_source_with_diagnostics "${CLAUDE_PROJECT_DIR}/.claude/lib/workflow/checkpoint-utils.sh" || true
source "${CLAUDE_PROJECT_DIR}/.claude/lib/plan/checkbox-utils.sh" 2>/dev/null || true

# Verify library versions
check_library_requirements "$(cat <<'EOF'
workflow-state-machine.sh: ">=2.0.0"
state-persistence.sh: ">=1.5.0"
EOF
)" || exit 1

# === PRE-FLIGHT VALIDATION ===
validate_lean_implement_prerequisites() {
  local validation_errors=0

  if ! declare -F save_completed_states_to_state >/dev/null 2>&1; then
    echo "ERROR: Required function 'save_completed_states_to_state' not found" >&2
    validation_errors=$((validation_errors + 1))
  fi

  if ! declare -F append_workflow_state >/dev/null 2>&1; then
    echo "ERROR: Required function 'append_workflow_state' not found" >&2
    validation_errors=$((validation_errors + 1))
  fi

  if ! declare -F log_command_error >/dev/null 2>&1; then
    echo "ERROR: Required function 'log_command_error' not found" >&2
    validation_errors=$((validation_errors + 1))
  fi

  if [ $validation_errors -gt 0 ]; then
    echo "Pre-flight validation failed: $validation_errors error(s) detected" >&2
    return 1
  fi

  return 0
}

if ! validate_lean_implement_prerequisites; then
  echo "FATAL: Pre-flight validation failed - cannot proceed" >&2
  exit 1
fi

echo "Pre-flight validation passed"
echo ""

# === PARSE ARGUMENTS ===
read -ra ARGS_ARRAY <<< "$LEAN_IMPLEMENT_ARGS"
PLAN_FILE="${ARGS_ARRAY[0]:-}"
STARTING_PHASE="${ARGS_ARRAY[1]:-1}"
EXECUTION_MODE="auto"  # Default mode
MAX_ITERATIONS=5
CONTEXT_THRESHOLD=90
DRY_RUN="false"

for arg in "${ARGS_ARRAY[@]:1}"; do
  case "$arg" in
    --mode=*) EXECUTION_MODE="${arg#*=}" ;;
    --max-iterations=*) MAX_ITERATIONS="${arg#*=}" ;;
    --context-threshold=*) CONTEXT_THRESHOLD="${arg#*=}" ;;
    --dry-run) DRY_RUN="true" ;;
    [0-9]*) STARTING_PHASE="$arg" ;;
  esac
done

# Validate execution mode
case "$EXECUTION_MODE" in
  auto|lean-only|software-only) ;;
  *)
    echo "ERROR: Invalid mode: $EXECUTION_MODE (must be auto, lean-only, or software-only)" >&2
    exit 1
    ;;
esac

# Validate starting phase is numeric
echo "$STARTING_PHASE" | grep -Eq "^[0-9]+$"
PHASE_VALID=$?
if [ $PHASE_VALID -ne 0 ]; then
  echo "ERROR: Invalid starting phase: $STARTING_PHASE (must be numeric)" >&2
  exit 1
fi

echo "=== Hybrid Lean/Software Implementation Workflow ==="
echo ""

# === VALIDATE PLAN FILE ===
if [ -z "$PLAN_FILE" ]; then
  echo "ERROR: No plan file specified" >&2
  echo "  Usage: /lean-implement <plan-file> [starting-phase] [--mode=auto|lean-only|software-only]" >&2
  exit 1
fi

if [ ! -f "$PLAN_FILE" ]; then
  # Try relative to project directory
  if [ -f "$CLAUDE_PROJECT_DIR/$PLAN_FILE" ]; then
    PLAN_FILE="$CLAUDE_PROJECT_DIR/$PLAN_FILE"
  else
    echo "ERROR: Plan file not found: $PLAN_FILE" >&2
    exit 1
  fi
fi

# Convert to absolute path
PLAN_FILE="$(cd "$(dirname "$PLAN_FILE")" && pwd)/$(basename "$PLAN_FILE")"

echo "Plan File: $PLAN_FILE"
echo "Starting Phase: $STARTING_PHASE"
echo "Execution Mode: $EXECUTION_MODE"
echo "Max Iterations: $MAX_ITERATIONS"
echo ""

# === DRY-RUN MODE ===
if [ "$DRY_RUN" = "true" ]; then
  echo "=== DRY-RUN MODE: Preview Only ==="
  echo "Plan: $(basename "$PLAN_FILE")"
  echo "Starting Phase: $STARTING_PHASE"
  echo "Mode: $EXECUTION_MODE"
  echo ""
  echo "Classification preview will be shown in Block 1a-classify"
  exit 0
fi

# === INITIALIZE WORKFLOW STATE ===
WORKFLOW_TYPE="implement-only"
COMMAND_NAME="/lean-implement"
USER_ARGS="$PLAN_FILE"

WORKFLOW_ID="lean_implement_$(date +%s)"
STATE_ID_FILE="${CLAUDE_PROJECT_DIR}/.claude/tmp/lean_implement_state_id.txt"
mkdir -p "$(dirname "$STATE_ID_FILE")"

# Atomic write
TEMP_STATE_ID="${STATE_ID_FILE}.tmp.$$"
echo "$WORKFLOW_ID" > "$TEMP_STATE_ID"
mv "$TEMP_STATE_ID" "$STATE_ID_FILE"

export WORKFLOW_ID COMMAND_NAME USER_ARGS

# Update bash error trap with actual values
setup_bash_error_trap "$COMMAND_NAME" "$WORKFLOW_ID" "$USER_ARGS"

# Initialize workflow state file
STATE_FILE=$(init_workflow_state "$WORKFLOW_ID")
export STATE_FILE

if [ -z "$STATE_FILE" ] || [ ! -f "$STATE_FILE" ]; then
  log_command_error \
    "$COMMAND_NAME" \
    "$WORKFLOW_ID" \
    "$USER_ARGS" \
    "state_error" \
    "Failed to initialize workflow state file" \
    "bash_block_1a" \
    "$(jq -n --arg path "${STATE_FILE:-UNDEFINED}" '{expected_path: $path}')"
  echo "ERROR: Failed to initialize workflow state" >&2
  exit 1
fi

# Initialize state machine
sm_init "$PLAN_FILE" "$COMMAND_NAME" "$WORKFLOW_TYPE" "1" "[]" 2>&1
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  log_command_error \
    "$COMMAND_NAME" \
    "$WORKFLOW_ID" \
    "$USER_ARGS" \
    "state_error" \
    "State machine initialization failed" \
    "bash_block_1a" \
    "$(jq -n --arg type "$WORKFLOW_TYPE" --arg plan "$PLAN_FILE" \
       '{workflow_type: $type, plan_file: $plan}')"
  echo "ERROR: State machine initialization failed" >&2
  exit 1
fi

# Transition to implement state
sm_transition "$STATE_IMPLEMENT" "plan loaded, starting hybrid implementation" 2>&1
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  log_command_error \
    "$COMMAND_NAME" \
    "$WORKFLOW_ID" \
    "$USER_ARGS" \
    "state_error" \
    "State transition to IMPLEMENT failed" \
    "bash_block_1a" \
    "$(jq -n --arg state "IMPLEMENT" '{target_state: $state}')"
  echo "ERROR: State transition to IMPLEMENT failed" >&2
  exit 1
fi

# === SETUP PATHS ===
TOPIC_PATH=$(dirname "$(dirname "$PLAN_FILE")")
SUMMARIES_DIR="${TOPIC_PATH}/summaries"
DEBUG_DIR="${TOPIC_PATH}/debug"

mkdir -p "$SUMMARIES_DIR" "$DEBUG_DIR" 2>/dev/null

# === MARK STARTING PHASE IN PROGRESS ===
if type add_not_started_markers &>/dev/null; then
  if grep -qE "^### Phase [0-9]+:" "$PLAN_FILE" && ! grep -qE "^### Phase [0-9]+:.*\[(NOT STARTED|IN PROGRESS|COMPLETE|BLOCKED|SKIPPED)\]" "$PLAN_FILE"; then
    echo "Legacy plan detected, adding [NOT STARTED] markers..."
    add_not_started_markers "$PLAN_FILE" 2>/dev/null || true
  fi
fi

if type add_in_progress_marker &>/dev/null; then
  if add_in_progress_marker "$PLAN_FILE" "$STARTING_PHASE" 2>/dev/null; then
    echo "Marked Phase $STARTING_PHASE as [IN PROGRESS]"
  fi
fi

if type update_plan_status &>/dev/null; then
  if update_plan_status "$PLAN_FILE" "IN PROGRESS" 2>/dev/null; then
    echo "Plan metadata status updated to [IN PROGRESS]"
  fi
fi
echo ""

# === ITERATION LOOP VARIABLES ===
ITERATION=1
CONTINUATION_CONTEXT=""
LAST_WORK_REMAINING=""
STUCK_COUNT=0
LEAN_ITERATION=1
SOFTWARE_ITERATION=1

# Create workspace directory
LEAN_IMPLEMENT_WORKSPACE="${CLAUDE_PROJECT_DIR}/.claude/tmp/lean_implement_${WORKFLOW_ID}"
mkdir -p "$LEAN_IMPLEMENT_WORKSPACE"

# === PERSIST STATE FOR NEXT BLOCK ===
append_workflow_state "COMMAND_NAME" "$COMMAND_NAME"
append_workflow_state "USER_ARGS" "$USER_ARGS"
append_workflow_state "WORKFLOW_ID" "$WORKFLOW_ID"
append_workflow_state "CLAUDE_PROJECT_DIR" "$CLAUDE_PROJECT_DIR"
append_workflow_state "PLAN_FILE" "$PLAN_FILE"
append_workflow_state "TOPIC_PATH" "$TOPIC_PATH"
append_workflow_state "SUMMARIES_DIR" "$SUMMARIES_DIR"
append_workflow_state "DEBUG_DIR" "$DEBUG_DIR"
append_workflow_state "STARTING_PHASE" "$STARTING_PHASE"
append_workflow_state "EXECUTION_MODE" "$EXECUTION_MODE"
append_workflow_state "MAX_ITERATIONS" "$MAX_ITERATIONS"
append_workflow_state "CONTEXT_THRESHOLD" "$CONTEXT_THRESHOLD"
append_workflow_state "ITERATION" "$ITERATION"
append_workflow_state "LEAN_ITERATION" "$LEAN_ITERATION"
append_workflow_state "SOFTWARE_ITERATION" "$SOFTWARE_ITERATION"
append_workflow_state "CONTINUATION_CONTEXT" "$CONTINUATION_CONTEXT"
append_workflow_state "LAST_WORK_REMAINING" "$LAST_WORK_REMAINING"
append_workflow_state "STUCK_COUNT" "$STUCK_COUNT"
append_workflow_state "LEAN_IMPLEMENT_WORKSPACE" "$LEAN_IMPLEMENT_WORKSPACE"

echo "CHECKPOINT: Setup complete"
echo "- State transition: IMPLEMENT [OK]"
echo "- Plan file: $PLAN_FILE"
echo "- Topic path: $TOPIC_PATH"
echo "- Iteration: ${ITERATION}/${MAX_ITERATIONS}"
echo "- Ready for: Phase classification (Block 1a-classify)"
echo ""
```

## Block 1a-classify: Phase Classification and Routing Map Construction

**EXECUTE NOW**: Classify each phase as "lean" or "software" and build routing map.

```bash
set +H 2>/dev/null || true
set +o histexpand 2>/dev/null || true
set -e

# === DETECT PROJECT DIRECTORY ===
if [ -z "$CLAUDE_PROJECT_DIR" ]; then
  if command -v git &>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
    CLAUDE_PROJECT_DIR="$(git rev-parse --show-toplevel)"
  else
    current_dir="$(pwd)"
    while [ "$current_dir" != "/" ]; do
      [ -d "$current_dir/.claude" ] && { CLAUDE_PROJECT_DIR="$current_dir"; break; }
      current_dir="$(dirname "$current_dir")"
    done
  fi
  export CLAUDE_PROJECT_DIR
fi

# === SOURCE LIBRARIES ===
source "${CLAUDE_PROJECT_DIR}/.claude/lib/core/error-handling.sh" 2>/dev/null || exit 1
source "${CLAUDE_PROJECT_DIR}/.claude/lib/core/state-persistence.sh" 2>/dev/null || exit 1

# === RESTORE STATE ===
STATE_ID_FILE="${CLAUDE_PROJECT_DIR}/.claude/tmp/lean_implement_state_id.txt"
if [ -f "$STATE_ID_FILE" ]; then
  WORKFLOW_ID=$(cat "$STATE_ID_FILE" 2>/dev/null)
else
  echo "ERROR: State ID file not found" >&2
  exit 1
fi

load_workflow_state "$WORKFLOW_ID" false
COMMAND_NAME="${COMMAND_NAME:-/lean-implement}"
USER_ARGS="${USER_ARGS:-}"
export COMMAND_NAME USER_ARGS WORKFLOW_ID

setup_bash_error_trap "$COMMAND_NAME" "$WORKFLOW_ID" "$USER_ARGS"

echo "=== Phase Classification ==="
echo ""

# === PHASE TYPE DETECTION FUNCTION ===
# 2-tier classification algorithm
detect_phase_type() {
  local phase_content="$1"
  local phase_num="$2"

  # Tier 1: Check for lean_file metadata (strongest signal)
  if echo "$phase_content" | grep -qE "^lean_file:"; then
    echo "lean"
    return 0
  fi

  # Tier 2: Keyword and extension analysis
  # Lean indicators
  if echo "$phase_content" | grep -qiE '\.(lean)\b|theorem\b|lemma\b|sorry\b|tactic\b|mathlib\b|lean_(goal|build|leansearch)'; then
    echo "lean"
    return 0
  fi

  # Software indicators
  if echo "$phase_content" | grep -qE '\.(ts|js|py|sh|md|json|yaml|toml)\b'; then
    echo "software"
    return 0
  fi

  if echo "$phase_content" | grep -qiE 'implement\b|create\b|write tests\b|setup\b|configure\b|deploy\b|build\b'; then
    echo "software"
    return 0
  fi

  # Default: software (conservative)
  echo "software"
}

# === EXTRACT PHASES FROM PLAN ===
TOTAL_PHASES=$(grep -c "^### Phase [0-9]" "$PLAN_FILE" 2>/dev/null || echo "0")

if [ "$TOTAL_PHASES" -eq 0 ]; then
  echo "ERROR: No phases found in plan file" >&2
  exit 1
fi

echo "Total phases found: $TOTAL_PHASES"
echo ""

# === CLASSIFY EACH PHASE ===
# Build routing map as newline-separated entries: phase_num:type:lean_file
ROUTING_MAP=""
LEAN_PHASES=""
SOFTWARE_PHASES=""
LEAN_COUNT=0
SOFTWARE_COUNT=0

for phase_num in $(seq 1 "$TOTAL_PHASES"); do
  # Extract phase content (from phase heading to next phase or EOF)
  PHASE_CONTENT=$(awk -v target="$phase_num" '
    BEGIN { in_phase=0; found=0 }
    /^### Phase / {
      if (found) exit
      if (index($0, "Phase " target ":") > 0) {
        in_phase=1
        found=1
        print
        next
      }
    }
    in_phase { print }
  ' "$PLAN_FILE")

  # Check if phase should be skipped based on mode
  if [ -z "$PHASE_CONTENT" ]; then
    echo "  Phase $phase_num: [SKIPPED - no content]"
    continue
  fi

  # Classify phase
  PHASE_TYPE=$(detect_phase_type "$PHASE_CONTENT" "$phase_num")

  # Extract lean_file if present
  LEAN_FILE_PATH=""
  if [ "$PHASE_TYPE" = "lean" ]; then
    LEAN_FILE_PATH=$(echo "$PHASE_CONTENT" | grep -E "^lean_file:" | sed 's/^lean_file:[[:space:]]*//' | head -1)
  fi

  # Apply mode filter
  case "$EXECUTION_MODE" in
    lean-only)
      if [ "$PHASE_TYPE" != "lean" ]; then
        echo "  Phase $phase_num: $PHASE_TYPE [SKIPPED - lean-only mode]"
        continue
      fi
      ;;
    software-only)
      if [ "$PHASE_TYPE" = "lean" ]; then
        echo "  Phase $phase_num: $PHASE_TYPE [SKIPPED - software-only mode]"
        continue
      fi
      ;;
  esac

  # Add to routing map
  if [ -n "$ROUTING_MAP" ]; then
    ROUTING_MAP="${ROUTING_MAP}
"
  fi
  ROUTING_MAP="${ROUTING_MAP}${phase_num}:${PHASE_TYPE}:${LEAN_FILE_PATH:-none}"

  if [ "$PHASE_TYPE" = "lean" ]; then
    LEAN_PHASES="${LEAN_PHASES}${phase_num} "
    LEAN_COUNT=$((LEAN_COUNT + 1))
    echo "  Phase $phase_num: LEAN (file: ${LEAN_FILE_PATH:-auto-detect})"
  else
    SOFTWARE_PHASES="${SOFTWARE_PHASES}${phase_num} "
    SOFTWARE_COUNT=$((SOFTWARE_COUNT + 1))
    echo "  Phase $phase_num: SOFTWARE"
  fi
done

echo ""
echo "Classification Summary:"
echo "  Lean phases ($LEAN_COUNT): ${LEAN_PHASES:-none}"
echo "  Software phases ($SOFTWARE_COUNT): ${SOFTWARE_PHASES:-none}"
echo ""

# Validate at least one phase to execute
if [ "$LEAN_COUNT" -eq 0 ] && [ "$SOFTWARE_COUNT" -eq 0 ]; then
  echo "ERROR: No phases to execute after mode filtering" >&2
  exit 1
fi

# === PERSIST ROUTING MAP ===
# Store routing map in workspace file (newline-separated is safer than shell variables)
echo "$ROUTING_MAP" > "${LEAN_IMPLEMENT_WORKSPACE}/routing_map.txt"

append_workflow_state "TOTAL_PHASES" "$TOTAL_PHASES"
append_workflow_state "LEAN_PHASES" "${LEAN_PHASES% }"
append_workflow_state "SOFTWARE_PHASES" "${SOFTWARE_PHASES% }"
append_workflow_state "LEAN_COUNT" "$LEAN_COUNT"
append_workflow_state "SOFTWARE_COUNT" "$SOFTWARE_COUNT"

echo "CHECKPOINT: Phase classification complete"
echo "- Routing map saved: ${LEAN_IMPLEMENT_WORKSPACE}/routing_map.txt"
echo "- Ready for: Coordinator routing (Block 1b)"
echo ""
```

## Block 1b: Route to Coordinator [HARD BARRIER]

**EXECUTE NOW**: Determine current phase type and invoke appropriate coordinator via Task tool.

This block reads the routing map, determines the next phase to execute, and invokes either lean-coordinator or implementer-coordinator.

**Routing Decision**:
1. Read current phase from routing map
2. If phase type is "lean": Invoke lean-coordinator
3. If phase type is "software": Invoke implementer-coordinator
4. Pass shared context (topic_path, continuation_context, iteration) to coordinator

```bash
set +H 2>/dev/null || true
set +o histexpand 2>/dev/null || true
set -e

# === DETECT PROJECT DIRECTORY ===
if [ -z "$CLAUDE_PROJECT_DIR" ]; then
  if command -v git &>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
    CLAUDE_PROJECT_DIR="$(git rev-parse --show-toplevel)"
  else
    current_dir="$(pwd)"
    while [ "$current_dir" != "/" ]; do
      [ -d "$current_dir/.claude" ] && { CLAUDE_PROJECT_DIR="$current_dir"; break; }
      current_dir="$(dirname "$current_dir")"
    done
  fi
  export CLAUDE_PROJECT_DIR
fi

# === SOURCE LIBRARIES ===
source "${CLAUDE_PROJECT_DIR}/.claude/lib/core/error-handling.sh" 2>/dev/null || exit 1
source "${CLAUDE_PROJECT_DIR}/.claude/lib/core/state-persistence.sh" 2>/dev/null || exit 1

# === RESTORE STATE ===
STATE_ID_FILE="${CLAUDE_PROJECT_DIR}/.claude/tmp/lean_implement_state_id.txt"
if [ -f "$STATE_ID_FILE" ]; then
  WORKFLOW_ID=$(cat "$STATE_ID_FILE" 2>/dev/null)
else
  echo "ERROR: State ID file not found" >&2
  exit 1
fi

load_workflow_state "$WORKFLOW_ID" false
COMMAND_NAME="${COMMAND_NAME:-/lean-implement}"
USER_ARGS="${USER_ARGS:-}"
export COMMAND_NAME USER_ARGS WORKFLOW_ID

setup_bash_error_trap "$COMMAND_NAME" "$WORKFLOW_ID" "$USER_ARGS"

echo "=== Coordinator Routing (Iteration ${ITERATION}/${MAX_ITERATIONS}) ==="
echo ""

# === READ ROUTING MAP ===
ROUTING_MAP_FILE="${LEAN_IMPLEMENT_WORKSPACE}/routing_map.txt"
if [ ! -f "$ROUTING_MAP_FILE" ]; then
  echo "ERROR: Routing map not found: $ROUTING_MAP_FILE" >&2
  exit 1
fi

ROUTING_MAP=$(cat "$ROUTING_MAP_FILE")

# === DETERMINE CURRENT PHASE ===
# Find first phase that is not complete (based on STARTING_PHASE or continuation)
CURRENT_PHASE="$STARTING_PHASE"

# Get phase entry from routing map
PHASE_ENTRY=$(echo "$ROUTING_MAP" | grep "^${CURRENT_PHASE}:" | head -1)

if [ -z "$PHASE_ENTRY" ]; then
  echo "ERROR: Phase $CURRENT_PHASE not found in routing map" >&2
  echo "Available phases:" >&2
  echo "$ROUTING_MAP" | cut -d: -f1 >&2
  exit 1
fi

# Parse phase entry: phase_num:type:lean_file
PHASE_NUM=$(echo "$PHASE_ENTRY" | cut -d: -f1)
PHASE_TYPE=$(echo "$PHASE_ENTRY" | cut -d: -f2)
LEAN_FILE_PATH=$(echo "$PHASE_ENTRY" | cut -d: -f3-)

echo "Current Phase: $PHASE_NUM"
echo "Phase Type: $PHASE_TYPE"
if [ "$PHASE_TYPE" = "lean" ] && [ "$LEAN_FILE_PATH" != "none" ]; then
  echo "Lean File: $LEAN_FILE_PATH"
fi
echo ""

# Persist current phase info
append_workflow_state "CURRENT_PHASE" "$CURRENT_PHASE"
append_workflow_state "CURRENT_PHASE_TYPE" "$PHASE_TYPE"
append_workflow_state "CURRENT_LEAN_FILE" "$LEAN_FILE_PATH"

echo "Routing to ${PHASE_TYPE}-coordinator..."
echo ""
```

**COORDINATOR INVOCATION DECISION**:

Based on the CURRENT_PHASE_TYPE from Block 1b state:

**If CURRENT_PHASE_TYPE is "lean"**:

**EXECUTE NOW**: USE the Task tool to invoke the lean-coordinator agent.

Task {
  subagent_type: "general-purpose"
  model: "sonnet"
  description: "Wave-based Lean theorem proving for phase ${CURRENT_PHASE}"
  prompt: "
    Read and follow ALL behavioral guidelines from:
    ${CLAUDE_PROJECT_DIR}/.claude/agents/lean-coordinator.md

    **Input Contract**:
    - lean_file_path: ${CURRENT_LEAN_FILE}
    - topic_path: ${TOPIC_PATH}
    - artifact_paths:
      - plans: ${TOPIC_PATH}/plans/
      - summaries: ${SUMMARIES_DIR}
      - outputs: ${TOPIC_PATH}/outputs/
      - checkpoints: ${HOME}/.claude/data/checkpoints/
    - max_attempts: 3
    - plan_path: ${PLAN_FILE}
    - execution_mode: plan-based
    - starting_phase: ${CURRENT_PHASE}
    - continuation_context: ${CONTINUATION_CONTEXT:-null}
    - max_iterations: ${MAX_ITERATIONS}
    - iteration: ${LEAN_ITERATION}

    Execute theorem proving for Phase ${CURRENT_PHASE}.

    Progress Tracking Instructions:
    - Source checkbox utilities: source ${CLAUDE_PROJECT_DIR}/.claude/lib/plan/checkbox-utils.sh
    - Before starting phase: add_in_progress_marker '${PLAN_FILE}' ${CURRENT_PHASE}
    - After completing phase: mark_phase_complete '${PLAN_FILE}' ${CURRENT_PHASE} && add_complete_marker '${PLAN_FILE}' ${CURRENT_PHASE}

    **CRITICAL**: Create proof summary in ${SUMMARIES_DIR}/
    The orchestrator will validate the summary exists after you return.

    Return: ORCHESTRATION_COMPLETE
    summary_path: /path/to/summary
    phases_completed: [${CURRENT_PHASE}]
    work_remaining: space-separated list of remaining phases OR 0
    context_exhausted: true|false
    context_usage_percent: N%
    requires_continuation: true|false
  "
}

**If CURRENT_PHASE_TYPE is "software"**:

**EXECUTE NOW**: USE the Task tool to invoke the implementer-coordinator agent.

Task {
  subagent_type: "general-purpose"
  model: "sonnet"
  description: "Wave-based software implementation for phase ${CURRENT_PHASE}"
  prompt: "
    Read and follow ALL behavioral guidelines from:
    ${CLAUDE_PROJECT_DIR}/.claude/agents/implementer-coordinator.md

    **Input Contract**:
    - plan_path: ${PLAN_FILE}
    - topic_path: ${TOPIC_PATH}
    - summaries_dir: ${SUMMARIES_DIR}
    - artifact_paths:
      - reports: ${TOPIC_PATH}/reports/
      - plans: ${TOPIC_PATH}/plans/
      - summaries: ${SUMMARIES_DIR}
      - debug: ${DEBUG_DIR}
      - outputs: ${TOPIC_PATH}/outputs/
      - checkpoints: ${HOME}/.claude/data/checkpoints/
    - continuation_context: ${CONTINUATION_CONTEXT:-null}
    - iteration: ${SOFTWARE_ITERATION}
    - max_iterations: ${MAX_ITERATIONS}
    - context_threshold: ${CONTEXT_THRESHOLD}

    Execute implementation for Phase ${CURRENT_PHASE}.

    Progress Tracking Instructions:
    - Source checkbox utilities: source ${CLAUDE_PROJECT_DIR}/.claude/lib/plan/checkbox-utils.sh
    - Before starting phase: add_in_progress_marker '${PLAN_FILE}' ${CURRENT_PHASE}
    - After completing phase: mark_phase_complete '${PLAN_FILE}' ${CURRENT_PHASE} && add_complete_marker '${PLAN_FILE}' ${CURRENT_PHASE}

    **CRITICAL**: Create implementation summary in ${SUMMARIES_DIR}/
    The orchestrator will validate the summary exists after you return.

    Return: IMPLEMENTATION_COMPLETE
    summary_path: /path/to/summary
    plan_path: ${PLAN_FILE}
    topic_path: ${TOPIC_PATH}
    work_remaining: space-separated list of remaining phases OR 0
    context_exhausted: true|false
    context_usage_percent: N%
    requires_continuation: true|false
  "
}

## Block 1c: Verification & Continuation Decision

**EXECUTE NOW**: Verify coordinator created summary, parse output, determine continuation.

```bash
set +H 2>/dev/null || true
set +o histexpand 2>/dev/null || true
set -e

# === DETECT PROJECT DIRECTORY ===
if [ -z "$CLAUDE_PROJECT_DIR" ]; then
  if command -v git &>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
    CLAUDE_PROJECT_DIR="$(git rev-parse --show-toplevel)"
  else
    current_dir="$(pwd)"
    while [ "$current_dir" != "/" ]; do
      [ -d "$current_dir/.claude" ] && { CLAUDE_PROJECT_DIR="$current_dir"; break; }
      current_dir="$(dirname "$current_dir")"
    done
  fi
  export CLAUDE_PROJECT_DIR
fi

# === SOURCE LIBRARIES ===
source "${CLAUDE_PROJECT_DIR}/.claude/lib/core/error-handling.sh" 2>/dev/null || exit 1
source "${CLAUDE_PROJECT_DIR}/.claude/lib/core/state-persistence.sh" 2>/dev/null || exit 1

ensure_error_log_exists

# === RESTORE STATE ===
STATE_ID_FILE="${CLAUDE_PROJECT_DIR}/.claude/tmp/lean_implement_state_id.txt"
if [ -f "$STATE_ID_FILE" ]; then
  WORKFLOW_ID=$(cat "$STATE_ID_FILE" 2>/dev/null)
else
  echo "ERROR: State ID file not found" >&2
  exit 1
fi

load_workflow_state "$WORKFLOW_ID" false
COMMAND_NAME="${COMMAND_NAME:-/lean-implement}"
USER_ARGS="${USER_ARGS:-}"
export COMMAND_NAME USER_ARGS WORKFLOW_ID

setup_bash_error_trap "$COMMAND_NAME" "$WORKFLOW_ID" "$USER_ARGS"

echo ""
echo "=== Hard Barrier Verification ==="
echo ""

# === VALIDATE SUMMARY EXISTENCE ===
LATEST_SUMMARY=$(find "$SUMMARIES_DIR" -name "*.md" -type f -mmin -10 2>/dev/null | sort | tail -1)

if [ -z "$LATEST_SUMMARY" ] || [ ! -f "$LATEST_SUMMARY" ]; then
  log_command_error \
    "$COMMAND_NAME" \
    "$WORKFLOW_ID" \
    "$USER_ARGS" \
    "agent_error" \
    "Coordinator did not create summary file" \
    "bash_block_1c" \
    "$(jq -n --arg dir "$SUMMARIES_DIR" '{summaries_dir: $dir}')"

  echo "ERROR: HARD BARRIER FAILED - Summary not created" >&2
  echo "Expected: Summary file in $SUMMARIES_DIR" >&2
  exit 1
fi

SUMMARY_SIZE=$(wc -c < "$LATEST_SUMMARY" 2>/dev/null || echo "0")
if [ "$SUMMARY_SIZE" -lt 100 ]; then
  log_command_error \
    "$COMMAND_NAME" \
    "$WORKFLOW_ID" \
    "$USER_ARGS" \
    "validation_error" \
    "Summary file too small" \
    "bash_block_1c" \
    "$(jq -n --arg path "$LATEST_SUMMARY" --argjson size "$SUMMARY_SIZE" \
       '{summary_path: $path, size_bytes: $size}')"

  echo "ERROR: Summary file too small ($SUMMARY_SIZE bytes)" >&2
  exit 1
fi

echo "[OK] Summary validated: $LATEST_SUMMARY ($SUMMARY_SIZE bytes)"
echo ""

# === PARSE COORDINATOR OUTPUT ===
WORK_REMAINING_NEW=""
CONTEXT_EXHAUSTED="false"
REQUIRES_CONTINUATION="false"
CONTEXT_USAGE_PERCENT=0

if [ -f "$LATEST_SUMMARY" ]; then
  # Parse work_remaining
  WORK_REMAINING_LINE=$(grep -E "^work_remaining:" "$LATEST_SUMMARY" | head -1)
  if [ -n "$WORK_REMAINING_LINE" ]; then
    WORK_REMAINING_NEW=$(echo "$WORK_REMAINING_LINE" | sed 's/^work_remaining:[[:space:]]*//')
    # Convert JSON array to space-separated if needed
    if [[ "$WORK_REMAINING_NEW" =~ ^\[ ]]; then
      WORK_REMAINING_NEW=$(echo "$WORK_REMAINING_NEW" | tr -d '[],"' | tr -s ' ')
    fi
    if [ "$WORK_REMAINING_NEW" = "0" ] || [ -z "$WORK_REMAINING_NEW" ]; then
      WORK_REMAINING_NEW=""
    fi
  fi

  # Parse context_exhausted
  CONTEXT_EXHAUSTED_LINE=$(grep -E "^context_exhausted:" "$LATEST_SUMMARY" | head -1)
  if [ -n "$CONTEXT_EXHAUSTED_LINE" ]; then
    CONTEXT_EXHAUSTED=$(echo "$CONTEXT_EXHAUSTED_LINE" | sed 's/^context_exhausted:[[:space:]]*//')
  fi

  # Parse requires_continuation
  REQUIRES_CONTINUATION_LINE=$(grep -E "^requires_continuation:" "$LATEST_SUMMARY" | head -1)
  if [ -n "$REQUIRES_CONTINUATION_LINE" ]; then
    REQUIRES_CONTINUATION=$(echo "$REQUIRES_CONTINUATION_LINE" | sed 's/^requires_continuation:[[:space:]]*//')
  fi

  # Parse context_usage_percent
  CONTEXT_USAGE_LINE=$(grep -E "^context_usage_percent:" "$LATEST_SUMMARY" | head -1)
  if [ -n "$CONTEXT_USAGE_LINE" ]; then
    CONTEXT_USAGE_PERCENT=$(echo "$CONTEXT_USAGE_LINE" | sed 's/^context_usage_percent:[[:space:]]*//' | sed 's/%//')
  fi
fi

echo "Context usage: ${CONTEXT_USAGE_PERCENT}%"
echo "Work remaining: ${WORK_REMAINING_NEW:-none}"
echo "Requires continuation: $REQUIRES_CONTINUATION"
echo ""

# === STUCK DETECTION ===
if [ -n "$WORK_REMAINING_NEW" ] && [ "$WORK_REMAINING_NEW" = "$LAST_WORK_REMAINING" ]; then
  STUCK_COUNT=$((STUCK_COUNT + 1))
  echo "WARNING: Work remaining unchanged (stuck count: $STUCK_COUNT)" >&2

  if [ "$STUCK_COUNT" -ge 2 ]; then
    echo "ERROR: Stuck detected (no progress for 2 iterations)" >&2
    append_workflow_state "IMPLEMENTATION_STATUS" "stuck"
    append_workflow_state "HALT_REASON" "stuck"
    append_workflow_state "SUMMARY_PATH" "$LATEST_SUMMARY"
    # Continue to Block 1d for phase marker recovery
  fi
else
  STUCK_COUNT=0
fi

# === ITERATION DECISION ===
echo "=== Iteration Decision (${ITERATION}/${MAX_ITERATIONS}) ==="

if [ "$REQUIRES_CONTINUATION" = "true" ] && [ -n "$WORK_REMAINING_NEW" ] && [ "$ITERATION" -lt "$MAX_ITERATIONS" ] && [ "$STUCK_COUNT" -lt 2 ]; then
  NEXT_ITERATION=$((ITERATION + 1))
  CONTINUATION_CONTEXT="${LEAN_IMPLEMENT_WORKSPACE}/iteration_${ITERATION}_summary.md"

  echo "Continuing to iteration $NEXT_ITERATION..."
  echo "  Work remaining: $WORK_REMAINING_NEW"
  echo "  Context usage: ${CONTEXT_USAGE_PERCENT}%"

  # Update per-coordinator iteration if applicable
  if [ "$CURRENT_PHASE_TYPE" = "lean" ]; then
    LEAN_ITERATION=$((LEAN_ITERATION + 1))
    append_workflow_state "LEAN_ITERATION" "$LEAN_ITERATION"
  else
    SOFTWARE_ITERATION=$((SOFTWARE_ITERATION + 1))
    append_workflow_state "SOFTWARE_ITERATION" "$SOFTWARE_ITERATION"
  fi

  # Update state for next iteration
  append_workflow_state "ITERATION" "$NEXT_ITERATION"
  append_workflow_state "WORK_REMAINING" "$WORK_REMAINING_NEW"
  append_workflow_state "CONTINUATION_CONTEXT" "$CONTINUATION_CONTEXT"
  append_workflow_state "STUCK_COUNT" "$STUCK_COUNT"
  append_workflow_state "LAST_WORK_REMAINING" "$WORK_REMAINING_NEW"
  append_workflow_state "IMPLEMENTATION_STATUS" "continuing"

  # Save summary for continuation context
  cp "$LATEST_SUMMARY" "$CONTINUATION_CONTEXT" 2>/dev/null || true

  echo ""
  echo "**ITERATION LOOP**: Return to Block 1b with updated state"
else
  # Work complete or max iterations/stuck
  if [ -z "$WORK_REMAINING_NEW" ] || [ "$WORK_REMAINING_NEW" = "0" ]; then
    echo "All work complete!"
    append_workflow_state "IMPLEMENTATION_STATUS" "complete"
  elif [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
    echo "Max iterations ($MAX_ITERATIONS) reached"
    append_workflow_state "IMPLEMENTATION_STATUS" "max_iterations"
    append_workflow_state "HALT_REASON" "max_iterations"
  fi

  append_workflow_state "WORK_REMAINING" "$WORK_REMAINING_NEW"
  append_workflow_state "SUMMARY_PATH" "$LATEST_SUMMARY"

  echo "Proceeding to Block 1d (phase marker recovery)..."
fi
echo ""
```

## Block 1d: Phase Marker Validation and Recovery

**EXECUTE NOW**: Validate phase markers and recover any missing [COMPLETE] markers.

```bash
set +H 2>/dev/null || true
set +o histexpand 2>/dev/null || true
set -e

# === DETECT PROJECT DIRECTORY ===
if [ -z "$CLAUDE_PROJECT_DIR" ]; then
  if command -v git &>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
    CLAUDE_PROJECT_DIR="$(git rev-parse --show-toplevel)"
  else
    current_dir="$(pwd)"
    while [ "$current_dir" != "/" ]; do
      [ -d "$current_dir/.claude" ] && { CLAUDE_PROJECT_DIR="$current_dir"; break; }
      current_dir="$(dirname "$current_dir")"
    done
  fi
  export CLAUDE_PROJECT_DIR
fi

# === SOURCE LIBRARIES ===
source "${CLAUDE_PROJECT_DIR}/.claude/lib/core/error-handling.sh" 2>/dev/null || exit 1
source "${CLAUDE_PROJECT_DIR}/.claude/lib/core/state-persistence.sh" 2>/dev/null || exit 1
source "${CLAUDE_PROJECT_DIR}/.claude/lib/workflow/workflow-state-machine.sh" 2>/dev/null || exit 1
source "${CLAUDE_PROJECT_DIR}/.claude/lib/plan/checkbox-utils.sh" 2>/dev/null || true

ensure_error_log_exists

# === RESTORE STATE ===
STATE_ID_FILE="${CLAUDE_PROJECT_DIR}/.claude/tmp/lean_implement_state_id.txt"
if [ -f "$STATE_ID_FILE" ]; then
  WORKFLOW_ID=$(cat "$STATE_ID_FILE" 2>/dev/null)
else
  echo "ERROR: State ID file not found" >&2
  exit 1
fi

load_workflow_state "$WORKFLOW_ID" false
COMMAND_NAME="${COMMAND_NAME:-/lean-implement}"
USER_ARGS="${USER_ARGS:-}"
export COMMAND_NAME USER_ARGS WORKFLOW_ID

setup_bash_error_trap "$COMMAND_NAME" "$WORKFLOW_ID" "$USER_ARGS"

echo ""
echo "=== Phase Marker Validation and Recovery ==="
echo ""

# Count total phases and phases with [COMPLETE] marker
TOTAL_PHASES=$(grep -c "^### Phase" "$PLAN_FILE" 2>/dev/null || echo "0")
PHASES_WITH_MARKER=$(grep -c "^### Phase.*\[COMPLETE\]" "$PLAN_FILE" 2>/dev/null || echo "0")

echo "Total phases: $TOTAL_PHASES"
echo "Phases with [COMPLETE] marker: $PHASES_WITH_MARKER"
echo ""

if [ "$TOTAL_PHASES" -eq 0 ]; then
  echo "No phases found in plan"
elif [ "$PHASES_WITH_MARKER" -eq "$TOTAL_PHASES" ]; then
  echo "[OK] All phases marked complete"
else
  echo "Detecting phases missing [COMPLETE] marker..."
  echo ""

  RECOVERED_COUNT=0
  for phase_num in $(seq 1 "$TOTAL_PHASES"); do
    if grep -q "^### Phase ${phase_num}:.*\[COMPLETE\]" "$PLAN_FILE"; then
      continue
    fi

    if type verify_phase_complete &>/dev/null && verify_phase_complete "$PLAN_FILE" "$phase_num" 2>/dev/null; then
      echo "Recovering Phase $phase_num..."

      if type mark_phase_complete &>/dev/null; then
        mark_phase_complete "$PLAN_FILE" "$phase_num" 2>/dev/null || true
      fi

      if type add_complete_marker &>/dev/null; then
        if add_complete_marker "$PLAN_FILE" "$phase_num" 2>/dev/null; then
          echo "  [OK] [COMPLETE] marker added"
          RECOVERED_COUNT=$((RECOVERED_COUNT + 1))
        fi
      fi
    fi
  done

  if [ "$RECOVERED_COUNT" -gt 0 ]; then
    echo ""
    echo "[OK] Recovered $RECOVERED_COUNT phase marker(s)"
  fi
fi

# Verify checkbox consistency
if type verify_checkbox_consistency &>/dev/null; then
  if verify_checkbox_consistency "$PLAN_FILE" 1 2>/dev/null; then
    echo ""
    echo "[OK] Checkbox hierarchy synchronized"
  fi
fi

# Update plan status if all phases complete
if type check_all_phases_complete &>/dev/null && type update_plan_status &>/dev/null; then
  if check_all_phases_complete "$PLAN_FILE"; then
    update_plan_status "$PLAN_FILE" "COMPLETE" 2>/dev/null
    echo "[OK] Plan metadata updated to COMPLETE"
  fi
fi

# Persist validation results
append_workflow_state "PHASES_WITH_MARKER" "$PHASES_WITH_MARKER"

save_completed_states_to_state 2>/dev/null || true

echo ""
echo "Phase marker recovery complete"
echo ""
```

## Block 2: Completion & Summary

**EXECUTE NOW**: Display completion summary with aggregated metrics from both coordinator types.

```bash
set +H 2>/dev/null || true
set +o histexpand 2>/dev/null || true
set -e

# === DETECT PROJECT DIRECTORY ===
if [ -z "$CLAUDE_PROJECT_DIR" ]; then
  if command -v git &>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
    CLAUDE_PROJECT_DIR="$(git rev-parse --show-toplevel)"
  else
    current_dir="$(pwd)"
    while [ "$current_dir" != "/" ]; do
      [ -d "$current_dir/.claude" ] && { CLAUDE_PROJECT_DIR="$current_dir"; break; }
      current_dir="$(dirname "$current_dir")"
    done
  fi
  export CLAUDE_PROJECT_DIR
fi

# === SOURCE LIBRARIES ===
source "${CLAUDE_PROJECT_DIR}/.claude/lib/core/error-handling.sh" 2>/dev/null || exit 1
source "${CLAUDE_PROJECT_DIR}/.claude/lib/core/state-persistence.sh" 2>/dev/null || exit 1
source "${CLAUDE_PROJECT_DIR}/.claude/lib/workflow/workflow-state-machine.sh" 2>/dev/null || exit 1
source "${CLAUDE_PROJECT_DIR}/.claude/lib/workflow/checkpoint-utils.sh" 2>/dev/null || true

ensure_error_log_exists

# === RESTORE STATE ===
STATE_ID_FILE="${CLAUDE_PROJECT_DIR}/.claude/tmp/lean_implement_state_id.txt"
if [ -f "$STATE_ID_FILE" ]; then
  WORKFLOW_ID=$(cat "$STATE_ID_FILE" 2>/dev/null)
else
  echo "ERROR: State ID file not found" >&2
  exit 1
fi

load_workflow_state "$WORKFLOW_ID" false
COMMAND_NAME="${COMMAND_NAME:-/lean-implement}"
USER_ARGS="${USER_ARGS:-}"
export COMMAND_NAME USER_ARGS WORKFLOW_ID

setup_bash_error_trap "$COMMAND_NAME" "$WORKFLOW_ID" "$USER_ARGS"

# === COMPLETE WORKFLOW ===
sm_transition "$STATE_COMPLETE" "hybrid implementation complete" 2>&1
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  echo "WARNING: State transition to COMPLETE failed" >&2
fi

save_completed_states_to_state 2>/dev/null || true

# === AGGREGATE METRICS ===
LEAN_PHASES_COMPLETED=0
SOFTWARE_PHASES_COMPLETED=0
THEOREMS_PROVEN=0

# Count completed phases by type
if [ -f "${LEAN_IMPLEMENT_WORKSPACE}/routing_map.txt" ]; then
  while IFS=: read -r phase_num phase_type lean_file; do
    if grep -q "^### Phase ${phase_num}:.*\[COMPLETE\]" "$PLAN_FILE" 2>/dev/null; then
      if [ "$phase_type" = "lean" ]; then
        LEAN_PHASES_COMPLETED=$((LEAN_PHASES_COMPLETED + 1))
      else
        SOFTWARE_PHASES_COMPLETED=$((SOFTWARE_PHASES_COMPLETED + 1))
      fi
    fi
  done < "${LEAN_IMPLEMENT_WORKSPACE}/routing_map.txt"
fi

TOTAL_COMPLETED=$((LEAN_PHASES_COMPLETED + SOFTWARE_PHASES_COMPLETED))

# Extract metrics from summaries if available
if [ -d "$SUMMARIES_DIR" ]; then
  THEOREMS_PROVEN=$(grep -l "PROOF_COMPLETE\|theorem.*proven" "$SUMMARIES_DIR"/*.md 2>/dev/null | wc -l || echo "0")
fi

# === CONSOLE SUMMARY ===
source "${CLAUDE_PROJECT_DIR}/.claude/lib/core/summary-formatting.sh" 2>/dev/null || {
  echo "WARNING: Could not load summary formatting library" >&2
}

echo ""
echo "=== Hybrid Implementation Complete ==="
echo ""

# Summary text
SUMMARY_TEXT="Completed $TOTAL_COMPLETED phases: $LEAN_PHASES_COMPLETED Lean (theorem proving), $SOFTWARE_PHASES_COMPLETED software (implementation). Mode: $EXECUTION_MODE."

# Build phases section
PHASES=""
if [ -n "${LEAN_PHASES:-}" ]; then
  PHASES="${PHASES}  Lean phases: ${LEAN_PHASES:-none} ($LEAN_PHASES_COMPLETED completed)
"
fi
if [ -n "${SOFTWARE_PHASES:-}" ]; then
  PHASES="${PHASES}  Software phases: ${SOFTWARE_PHASES:-none} ($SOFTWARE_PHASES_COMPLETED completed)
"
fi

# Build artifacts section
ARTIFACTS="  Plan: $PLAN_FILE"
if [ -n "${SUMMARY_PATH:-}" ] && [ -f "${SUMMARY_PATH:-}" ]; then
  ARTIFACTS="${ARTIFACTS}
  Latest Summary: $SUMMARY_PATH"
fi

# Build next steps
NEXT_STEPS="  Review plan: cat $PLAN_FILE
  Run tests: /test $PLAN_FILE
  Run /todo to update TODO.md"

# Print summary
if type print_artifact_summary &>/dev/null; then
  print_artifact_summary "Hybrid Implementation" "$SUMMARY_TEXT" "$PHASES" "$ARTIFACTS" "$NEXT_STEPS"
else
  echo "Summary: $SUMMARY_TEXT"
  echo ""
  echo "Phases:"
  echo "$PHASES"
  echo ""
  echo "Artifacts:"
  echo "$ARTIFACTS"
  echo ""
  echo "Next Steps:"
  echo "$NEXT_STEPS"
fi

echo ""
echo "Next Step: Run /todo to update TODO.md with this implementation"
echo ""

# === EMIT COMPLETION SIGNAL ===
echo "IMPLEMENTATION_COMPLETE:"
echo "  plan_file: $PLAN_FILE"
echo "  topic_path: $TOPIC_PATH"
echo "  summary_path: ${SUMMARY_PATH:-}"
echo "  total_phases: $TOTAL_PHASES"
echo "  lean_phases_completed: $LEAN_PHASES_COMPLETED"
echo "  software_phases_completed: $SOFTWARE_PHASES_COMPLETED"
echo "  theorems_proven: $THEOREMS_PROVEN"
echo "  execution_mode: $EXECUTION_MODE"
echo "  iterations_used: $ITERATION"
echo "  work_remaining: ${WORK_REMAINING:-0}"

# Cleanup
delete_checkpoint "lean_implement" 2>/dev/null || true
rm -f "$STATE_ID_FILE" 2>/dev/null || true

exit 0
```

---

## Troubleshooting

### Phase Classification Issues
- **Ambiguous phases**: Default to "software" - add `lean_file:` metadata for explicit Lean classification
- **Wrong classification**: Check Tier 1 (lean_file metadata) and Tier 2 (keywords/extensions)
- **Use DEBUG_LOG**: Check `~/.claude/tmp/workflow_debug.log` for classification decisions

### Coordinator Routing Issues
- **Lean coordinator fails**: Verify lean-lsp-mcp is available, Lean file exists
- **Software coordinator fails**: Check implementer-coordinator agent is accessible
- **Both fail**: Review routing map in workspace directory

### Iteration Issues
- **Stuck detection**: Work remaining unchanged for 2 iterations triggers halt
- **Max iterations**: Increase with `--max-iterations=N`
- **Continuation context**: Check workspace directory for iteration summaries

### Mode Filtering
- `--mode=lean-only`: Skips all software phases
- `--mode=software-only`: Skips all Lean phases
- `--mode=auto`: Executes all phases with automatic routing (default)

## Success Criteria

Workflow is successful if:
- Phase classification correctly identifies Lean vs software phases
- Appropriate coordinator invoked for each phase type
- Summary created in summaries directory (>100 bytes)
- Phase markers updated ([NOT STARTED] -> [IN PROGRESS] -> [COMPLETE])
- Aggregated metrics from both coordinator types
- IMPLEMENTATION_COMPLETE signal emitted with all metrics
