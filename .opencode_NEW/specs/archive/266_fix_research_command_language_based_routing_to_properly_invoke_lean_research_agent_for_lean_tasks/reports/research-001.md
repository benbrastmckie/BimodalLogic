# Research Report: Fix /research Command Language-Based Routing

**Task**: 266  
**Date**: 2026-01-03  
**Researcher**: Research Agent  
**Status**: Research Completed

---

## Executive Summary

The `/research` command has `routing.language_based: true` configured in its frontmatter, but when invoked for Lean tasks (e.g., `/research 258` where task 258 has `Language: lean`), it does NOT route to `lean-research-agent` as documented. Instead, it appears to route to the default `researcher` agent, which then marks the task as [RESEARCHED] without creating any artifacts.

**Root Cause**: The orchestrator does NOT implement Stage 2 (DetermineRouting) as documented in `orchestrator.md`. The language extraction and routing logic exists only in documentation, not in actual implementation.

**Impact**: 
- Lean research tasks receive generic web-based research instead of Lean-specific research
- No Lean library exploration (Loogle, LeanSearch, lean-lsp-mcp tools)
- "Phantom research" - status updated without artifacts created
- Violates documented language-based routing contract

**Solution**: Implement Stage 2 (DetermineRouting) in the orchestrator to extract language from TODO.md and route to the correct agent based on command frontmatter routing configuration.

---

## Problem Analysis

### Evidence of Failure

**Task 258 (Lean Language)**:
- Has `Language: lean` in TODO.md ✓
- Shows `[RESEARCHED]` status in TODO.md ✓
- Has NO artifacts ✗
- Has NO state.json entry ✗
- Has NO project directory ✗

**Task 257 (Lean Language)**:
- Has `Language: lean` in TODO.md ✓
- Shows `[RESEARCHED]` status in TODO.md ✓
- Has NO artifacts ✗
- Has NO state.json entry ✗
- Has NO project directory ✗

**Task 256 (Markdown Language) - Working Example**:
- Has `Language: markdown` in TODO.md ✓
- Shows `[RESEARCHED]` status in TODO.md ✓
- Has artifacts in `.opencode/specs/256_*/reports/research-001.md` ✓
- Has state.json entry with artifacts array ✓
- Has project directory ✓

### Comparison: Working vs Broken

| Aspect | Task 256 (markdown) | Task 257/258 (lean) |
|--------|---------------------|---------------------|
| Language in TODO.md | markdown | lean |
| Expected Agent | researcher | lean-research-agent |
| Actual Agent | researcher (correct) | researcher (WRONG) |
| Artifacts Created | YES | NO |
| state.json Entry | YES | NO |
| Status Updated | YES | YES |
| Result | Working | Phantom Research |

**Key Insight**: Both markdown and lean tasks get routed to `researcher`, but only markdown tasks should. Lean tasks should route to `lean-research-agent`.

---

## Root Cause Analysis

### 1. Orchestrator Stage 2 (DetermineRouting) Not Implemented

**Documentation** (`orchestrator.md` lines 87-123):
```xml
<stage id="2" name="DetermineRouting">
  <action>Extract language and determine target agent</action>
  <process>
    1. Check if command uses language-based routing:
       - Read `routing.language_based` from command frontmatter
       - If false: Use `routing.target_agent` directly
       - If true: Extract language and map to agent
    
    2. For language-based routing:
       a. Extract language (priority order):
          - Priority 1: Project state.json (task-specific)
          - Priority 2: TODO.md task entry (**Language** field)
          - Priority 3: Default "general" (fallback)
       
       b. Map language to agent:
          - /research: lean → lean-research-agent, default → researcher
          - /implement: lean → lean-implementation-agent, default → implementer
       
       c. Validate routing:
          - Verify agent file exists at `.opencode/agent/subagents/{agent}.md`
          - Verify language matches agent capabilities
    
    3. Update delegation_path with resolved agent
  </process>
</stage>
```

**Reality**: This stage is NOT implemented. The orchestrator documentation describes the INTENDED behavior, but the actual orchestrator does not execute this logic.

### 2. Command Frontmatter Routing Configuration Present

**`/research` command** (`.opencode/command/research.md` lines 7-10):
```yaml
routing:
  language_based: true
  lean: lean-research-agent
  default: researcher
```

**`/implement` command** (`.opencode/command/implement.md` lines 7-10):
```yaml
routing:
  language_based: true
  lean: lean-implementation-agent
  default: implementer
```

**Analysis**: The routing configuration is correctly specified in command frontmatter, but the orchestrator doesn't read or use it.

### 3. Language Extraction Logic Missing

**Documented Extraction** (`orchestrator.md` lines 111-121):
```bash
# Extract from project state.json (if exists)
task_dir=".opencode/specs/${task_number}_*"
if [ -f "${task_dir}/state.json" ]; then
  language=$(jq -r '.language // "general"' "${task_dir}/state.json")
else
  # Extract from TODO.md
  language=$(grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //' | tr -d ' ')
  language=${language:-general}
fi
```

**Reality**: This extraction logic is documented but not implemented in the orchestrator.

### 4. Routing Validation Missing

**Documented Validation** (`routing-guide.md` lines 73-89):
```bash
# Validate lean routing
if [ "$language" == "lean" ] && [ "$agent" != "lean-research-agent" ] && [ "$agent" != "lean-implementation-agent" ]; then
  echo "[FAIL] Routing validation failed: language=lean but agent=${agent}"
  exit 1
fi

# Validate non-lean routing
if [ "$language" != "lean" ] && [[ "$agent" == "lean-"* ]]; then
  echo "[FAIL] Routing validation failed: language=${language} but agent=${agent}"
  exit 1
fi
```

**Reality**: No validation occurs. Incorrect routing is silently accepted.

---

## Why Phantom Research Occurs

### Sequence of Events (Current Broken Behavior)

1. User invokes `/research 258` (task 258 has `Language: lean`)
2. Orchestrator Stage 1 (PreflightValidation):
   - Reads `.opencode/command/research.md`
   - Extracts `agent: orchestrator` from frontmatter
   - Validates command file exists ✓
3. **Orchestrator Stage 2 (DetermineRouting): SKIPPED** ❌
   - Language NOT extracted
   - Routing configuration NOT read
   - Agent NOT determined based on language
4. Orchestrator Stage 3 (RegisterAndDelegate):
   - Uses default agent from frontmatter: `researcher` (WRONG for lean)
   - Delegates to `researcher` instead of `lean-research-agent`
5. `researcher` agent executes:
   - Receives task 258 context
   - Attempts web-based research (not Lean-specific)
   - May fail to create artifacts (no Lean tools available)
   - Updates status to [RESEARCHED] anyway (incomplete workflow)
6. Result: Status updated, NO artifacts created

### Why Markdown Tasks Work

1. User invokes `/research 256` (task 256 has `Language: markdown`)
2. Orchestrator delegates to `researcher` (default agent)
3. `researcher` is the CORRECT agent for markdown
4. `researcher` executes successfully:
   - Web-based research appropriate for markdown
   - Creates research report
   - Updates state.json
   - Updates status to [RESEARCHED]
5. Result: Status updated, artifacts created ✓

**Key Insight**: Markdown tasks work by ACCIDENT (default agent happens to be correct), not by design. Lean tasks fail because default agent is WRONG.

---

## Comparison with /implement Command

The `/implement` command has identical routing configuration:

```yaml
routing:
  language_based: true
  lean: lean-implementation-agent
  default: implementer
```

**Question**: Does `/implement` have the same routing failure?

**Hypothesis**: YES. If `/implement 258` were invoked, it would route to `implementer` instead of `lean-implementation-agent`, causing similar failures.

**Evidence Needed**: Test `/implement` with a lean task to confirm.

---

## Documented vs Actual Behavior

### Documented Behavior (orchestrator.md)

**Stage 1: PreflightValidation**
- Load command file ✓
- Validate frontmatter ✓
- Extract routing metadata ❌ (NOT implemented)
- Validate delegation safety ✓

**Stage 2: DetermineRouting**
- Check language_based flag ❌ (NOT implemented)
- Extract language from TODO.md ❌ (NOT implemented)
- Map language to agent ❌ (NOT implemented)
- Validate routing ❌ (NOT implemented)

**Stage 3: RegisterAndDelegate**
- Register session ✓
- Invoke target agent ✓ (but WRONG agent)
- Monitor timeout ✓

### Actual Behavior

**Stage 1: PreflightValidation**
- Load command file ✓
- Validate frontmatter ✓
- Use default agent from frontmatter ✓

**Stage 2: SKIPPED ENTIRELY** ❌

**Stage 3: RegisterAndDelegate**
- Delegate to default agent (ignoring language) ✓

---

## Fix Strategy

### Option 1: Implement Stage 2 in Orchestrator (Recommended)

**Approach**: Implement the documented Stage 2 (DetermineRouting) logic in the orchestrator.

**Changes Required**:

1. **Orchestrator Stage 2 Implementation**:
   - Read `routing.language_based` from command frontmatter
   - If true: Extract language from TODO.md (or state.json)
   - Map language to agent using routing configuration
   - Validate routing (language matches agent)
   - Update delegation_path with resolved agent

2. **Language Extraction**:
   ```bash
   # Priority 1: Project state.json
   task_dir=$(find .opencode/specs -maxdepth 1 -type d -name "${task_number}_*" | head -1)
   if [ -f "${task_dir}/state.json" ]; then
     language=$(jq -r '.language // "general"' "${task_dir}/state.json")
   else
     # Priority 2: TODO.md
     language=$(grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //' | tr -d ' ')
     language=${language:-general}
   fi
   ```

3. **Agent Mapping**:
   ```bash
   # Read routing config from command frontmatter
   routing_config=$(yq eval '.routing' .opencode/command/${command}.md)
   language_based=$(echo "$routing_config" | yq eval '.language_based')
   
   if [ "$language_based" == "true" ]; then
     # Map language to agent
     agent=$(echo "$routing_config" | yq eval ".${language} // .default")
   else
     # Use direct routing
     agent=$(echo "$routing_config" | yq eval '.target_agent')
   fi
   ```

4. **Routing Validation**:
   ```bash
   # Validate agent file exists
   if [ ! -f ".opencode/agent/subagents/${agent}.md" ]; then
     echo "[FAIL] Agent file not found: ${agent}.md"
     exit 1
   fi
   
   # Validate language matches agent
   if [ "$language" == "lean" ] && [[ "$agent" != "lean-"* ]]; then
     echo "[FAIL] Routing mismatch: language=lean but agent=${agent}"
     exit 1
   fi
   ```

**Pros**:
- Implements documented behavior
- Maintains uniformity with orchestrator architecture
- Fixes routing for ALL commands (research, implement, etc.)
- Enables future language-based routing extensions

**Cons**:
- Requires orchestrator modification
- Adds complexity to orchestrator Stage 2

**Estimated Effort**: 4-6 hours

### Option 2: Move Routing Logic to Command Files

**Approach**: Remove language-based routing from orchestrator, implement in each command file.

**Changes Required**:

1. **Command File Stage 2 Implementation**:
   - Each command implements its own language extraction
   - Each command determines target agent
   - Each command validates routing

2. **Example** (research.md):
   ```xml
   <stage id="2" name="DetermineAgent">
     <action>Extract language and determine target agent</action>
     <process>
       1. Extract language from TODO.md
       2. If language == "lean": agent = "lean-research-agent"
       3. Else: agent = "researcher"
       4. Validate agent file exists
     </process>
   </stage>
   ```

**Pros**:
- No orchestrator changes required
- Command-specific routing logic

**Cons**:
- Duplicates routing logic across commands
- Violates orchestrator responsibility (routing)
- Inconsistent with agent system standards
- Harder to maintain (4+ command files)

**Estimated Effort**: 6-8 hours

**Recommendation**: DO NOT USE. Violates orchestrator architecture.

### Option 3: Hybrid Approach (Command Frontmatter + Orchestrator Execution)

**Approach**: Keep routing configuration in command frontmatter, implement execution in orchestrator.

**Changes Required**:

1. **Orchestrator reads routing config from command frontmatter** ✓ (already documented)
2. **Orchestrator extracts language from TODO.md** (implement)
3. **Orchestrator maps language to agent using config** (implement)
4. **Orchestrator validates routing** (implement)

**Pros**:
- Maintains separation of concerns
- Configuration in command files (declarative)
- Execution in orchestrator (centralized)
- Follows existing patterns

**Cons**:
- Same as Option 1 (requires orchestrator changes)

**Estimated Effort**: 4-6 hours

**Recommendation**: PREFERRED. This is essentially Option 1 with emphasis on frontmatter configuration.

---

## Recommended Solution: Option 3 (Hybrid Approach)

### Implementation Plan

#### Phase 1: Orchestrator Stage 2 Implementation (2-3 hours)

**File**: `.opencode/agent/orchestrator.md`

**Changes**:

1. Add Stage 2 implementation after Stage 1:
   ```xml
   <stage id="2" name="DetermineRouting">
     <action>Extract language and determine target agent</action>
     <implementation>
       1. Read routing configuration from command frontmatter:
          - routing.language_based (boolean)
          - routing.lean (agent name for lean language)
          - routing.default (default agent name)
       
       2. If routing.language_based == true:
          a. Extract language from TODO.md:
             - grep -A 20 "^### ${task_number}\." TODO.md
             - grep "Language" | sed 's/\*\*Language\*\*: //'
             - Default to "general" if not found
          
          b. Map language to agent:
             - If language == "lean": agent = routing.lean
             - Else: agent = routing.default
       
       3. Else (direct routing):
          - agent = routing.target_agent
       
       4. Validate routing:
          - Verify agent file exists
          - Verify language matches agent capabilities
       
       5. Update delegation_path with resolved agent
     </implementation>
   </stage>
   ```

2. Add language extraction helper:
   ```bash
   extract_language() {
     local task_number=$1
     local language
     
     # Priority 1: Project state.json
     local task_dir=$(find .opencode/specs -maxdepth 1 -type d -name "${task_number}_*" | head -1)
     if [ -n "$task_dir" ] && [ -f "${task_dir}/state.json" ]; then
       language=$(jq -r '.language // ""' "${task_dir}/state.json")
     fi
     
     # Priority 2: TODO.md
     if [ -z "$language" ]; then
       language=$(grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md | \
                  grep "Language" | \
                  sed 's/\*\*Language\*\*: //' | \
                  tr -d ' ')
     fi
     
     # Priority 3: Default
     language=${language:-general}
     
     echo "$language"
   }
   ```

3. Add routing validation helper:
   ```bash
   validate_routing() {
     local language=$1
     local agent=$2
     
     # Validate agent file exists
     if [ ! -f ".opencode/agent/subagents/${agent}.md" ]; then
       echo "[FAIL] Agent file not found: ${agent}.md"
       return 1
     fi
     
     # Validate lean routing
     if [ "$language" == "lean" ] && [[ "$agent" != "lean-"* ]]; then
       echo "[FAIL] Routing mismatch: language=lean but agent=${agent}"
       return 1
     fi
     
     # Validate non-lean routing
     if [ "$language" != "lean" ] && [[ "$agent" == "lean-"* ]]; then
       echo "[FAIL] Routing mismatch: language=${language} but agent=${agent}"
       return 1
     fi
     
     return 0
   }
   ```

#### Phase 2: Validation Improvements (1-2 hours)

**File**: `.opencode/agent/orchestrator.md`

**Changes**:

1. Add artifact validation in Stage 4 (ValidateReturn):
   ```xml
   <validation>
     - Return is valid JSON ✓
     - Required fields present ✓
     - Status is valid enum ✓
     - session_id matches ✓
     - Summary <100 tokens ✓
     - Artifacts exist (if status=completed) ← ADD THIS
   </validation>
   ```

2. Add artifact existence check:
   ```bash
   validate_artifacts() {
     local status=$1
     local artifacts_json=$2
     
     if [ "$status" == "completed" ]; then
       # Parse artifacts array
       local artifact_count=$(echo "$artifacts_json" | jq 'length')
       
       if [ "$artifact_count" -eq 0 ]; then
         echo "[FAIL] Status is 'completed' but no artifacts created"
         return 1
       fi
       
       # Verify each artifact exists
       for i in $(seq 0 $((artifact_count - 1))); do
         local artifact_path=$(echo "$artifacts_json" | jq -r ".[$i].path")
         if [ ! -f "$artifact_path" ]; then
           echo "[FAIL] Artifact does not exist: ${artifact_path}"
           return 1
         fi
         
         if [ ! -s "$artifact_path" ]; then
           echo "[FAIL] Artifact is empty: ${artifact_path}"
           return 1
         fi
       done
     fi
     
     return 0
   }
   ```

3. Prevent phantom research:
   - If artifacts validation fails, return status "failed"
   - Include error in response
   - Recommend manual investigation

#### Phase 3: Testing and Validation (1 hour)

**Test Cases**:

1. **Test Lean Research Routing**:
   ```bash
   # Create test task with Language: lean
   # Invoke /research {task_number}
   # Verify lean-research-agent is invoked
   # Verify artifacts created
   # Verify state.json updated
   ```

2. **Test Markdown Research Routing**:
   ```bash
   # Create test task with Language: markdown
   # Invoke /research {task_number}
   # Verify researcher is invoked
   # Verify artifacts created
   # Verify state.json updated
   ```

3. **Test Lean Implementation Routing**:
   ```bash
   # Create test task with Language: lean
   # Invoke /implement {task_number}
   # Verify lean-implementation-agent is invoked
   # Verify artifacts created
   # Verify state.json updated
   ```

4. **Test Routing Validation**:
   ```bash
   # Manually force incorrect routing
   # Verify validation catches mismatch
   # Verify error message is clear
   ```

5. **Test Artifact Validation**:
   ```bash
   # Mock agent return with status=completed but no artifacts
   # Verify orchestrator rejects return
   # Verify error message is clear
   ```

**Validation Criteria**:
- [ ] Lean tasks route to lean-research-agent
- [ ] Markdown tasks route to researcher
- [ ] Routing validation catches mismatches
- [ ] Artifact validation prevents phantom research
- [ ] All tests pass

---

## Testing Plan

### Test Case 1: Lean Research Task (Currently Broken)

**Setup**:
1. Find or create a task with `Language: lean` and status `[NOT STARTED]`
2. Example: Task 258 (Resolve Truth.lean Sorries)

**Test**:
```bash
/research 258
```

**Expected Behavior (After Fix)**:
1. Orchestrator extracts language: "lean"
2. Orchestrator reads routing config: `lean: lean-research-agent`
3. Orchestrator routes to `lean-research-agent`
4. `lean-research-agent` executes:
   - Uses Loogle CLI for type-based search
   - Uses lean-lsp-mcp tools for library search
   - Creates research report with Lean-specific findings
   - Creates summary artifact
   - Updates status to [RESEARCHED]
   - Updates state.json
5. Artifacts created:
   - `.opencode/specs/258_resolve_truth_lean_sorries/reports/research-001.md`
   - `.opencode/specs/258_resolve_truth_lean_sorries/summaries/research-summary.md`
6. state.json entry created with artifacts

**Current Behavior (Broken)**:
1. Orchestrator skips language extraction
2. Orchestrator routes to default `researcher`
3. `researcher` executes (wrong agent for lean)
4. Status updated to [RESEARCHED]
5. NO artifacts created ❌
6. NO state.json entry ❌

### Test Case 2: Markdown Research Task (Currently Working)

**Setup**:
1. Find or create a task with `Language: markdown` and status `[NOT STARTED]`
2. Example: Task 266 (this task)

**Test**:
```bash
/research 266
```

**Expected Behavior**:
1. Orchestrator extracts language: "markdown"
2. Orchestrator reads routing config: `default: researcher`
3. Orchestrator routes to `researcher`
4. `researcher` executes:
   - Uses web search for documentation
   - Creates research report
   - Updates status to [RESEARCHED]
   - Updates state.json
5. Artifacts created ✓
6. state.json entry created ✓

**Current Behavior**:
- Works correctly (by accident - default agent happens to be correct)

### Test Case 3: Lean Implementation Task

**Setup**:
1. Find or create a task with `Language: lean` and status `[PLANNED]`
2. Example: Task 173 (Implement integration tests)

**Test**:
```bash
/implement 173
```

**Expected Behavior (After Fix)**:
1. Orchestrator extracts language: "lean"
2. Orchestrator reads routing config: `lean: lean-implementation-agent`
3. Orchestrator routes to `lean-implementation-agent`
4. `lean-implementation-agent` executes:
   - Uses lean-lsp-mcp for compilation checking
   - Creates Lean code
   - Updates status to [IMPLEMENTED]
   - Updates state.json
5. Artifacts created ✓
6. state.json entry created ✓

**Current Behavior (Likely Broken)**:
- Hypothesis: Routes to `implementer` instead of `lean-implementation-agent`
- Needs testing to confirm

### Test Case 4: Routing Validation

**Setup**:
1. Manually modify orchestrator to force incorrect routing
2. Example: Route lean task to `researcher`

**Test**:
```bash
# Force incorrect routing
language="lean"
agent="researcher"
validate_routing "$language" "$agent"
```

**Expected Behavior**:
```
[FAIL] Routing mismatch: language=lean but agent=researcher
```

**Current Behavior**:
- No validation occurs
- Incorrect routing silently accepted

### Test Case 5: Artifact Validation

**Setup**:
1. Mock agent return with `status: "completed"` but empty `artifacts: []`

**Test**:
```json
{
  "status": "completed",
  "summary": "Research completed",
  "artifacts": [],
  "metadata": {...}
}
```

**Expected Behavior**:
```
[FAIL] Status is 'completed' but no artifacts created
```

**Current Behavior**:
- No validation occurs
- Phantom research accepted

---

## Regression Testing

### Commands to Test

1. `/research` - Language-based routing
2. `/implement` - Language-based routing
3. `/plan` - Direct routing (no language-based)
4. `/revise` - Direct routing (no language-based)

### Test Matrix

| Command | Language | Expected Agent | Test Status |
|---------|----------|----------------|-------------|
| /research | lean | lean-research-agent | ❌ BROKEN |
| /research | markdown | researcher | ✓ WORKS |
| /research | python | researcher | ✓ WORKS |
| /research | general | researcher | ✓ WORKS |
| /implement | lean | lean-implementation-agent | ❓ UNTESTED |
| /implement | markdown | implementer | ✓ WORKS |
| /implement | python | implementer | ✓ WORKS |
| /implement | general | implementer | ✓ WORKS |
| /plan | any | planner | ✓ WORKS |
| /revise | any | reviser | ✓ WORKS |

---

## Implementation Recommendations

### 1. Maintain Uniformity with Agent System Standards

**Principle**: Orchestrator owns routing, commands own workflows, agents own execution.

**Recommendation**:
- Implement Stage 2 (DetermineRouting) in orchestrator
- Keep routing configuration in command frontmatter
- Agents remain unaware of routing logic

**Rationale**:
- Follows documented architecture
- Maintains separation of concerns
- Enables future routing extensions

### 2. Follow Existing Patterns

**Pattern**: Frontmatter delegation (from Task 240 migration)

**Recommendation**:
- Use YAML frontmatter for routing configuration
- Orchestrator reads frontmatter and executes routing
- No code duplication across commands

**Example**:
```yaml
routing:
  language_based: true
  lean: lean-research-agent
  python: python-researcher  # Future extension
  default: researcher
```

### 3. Ensure Orchestrator Properly Implements Documented Behavior

**Current Gap**: Orchestrator documentation describes Stage 2, but implementation is missing.

**Recommendation**:
- Implement Stage 2 as documented
- Add language extraction logic
- Add routing validation logic
- Add artifact validation logic

**Rationale**:
- Closes documentation-implementation gap
- Prevents future confusion
- Enables debugging and monitoring

### 4. Add Comprehensive Logging

**Recommendation**:
- Log language extraction: `[INFO] Task 258 language: lean`
- Log routing decision: `[INFO] Routing to lean-research-agent (language=lean)`
- Log validation results: `[PASS] Routing validation succeeded`
- Log artifact validation: `[PASS] 2 artifacts validated`

**Rationale**:
- Enables debugging
- Provides audit trail
- Helps identify routing failures

### 5. Prevent Phantom Research

**Recommendation**:
- Validate artifacts exist before accepting "completed" status
- Reject agent returns with status=completed but no artifacts
- Return clear error messages

**Example Error**:
```json
{
  "status": "failed",
  "summary": "Agent returned 'completed' status but created no artifacts",
  "errors": [{
    "type": "validation_failed",
    "message": "No artifacts found for completed research",
    "recommendation": "Investigate agent execution logs"
  }]
}
```

---

## Acceptance Criteria

### Functional Requirements

- [ ] Lean research tasks route to `lean-research-agent`
- [ ] Markdown research tasks route to `researcher`
- [ ] Lean implementation tasks route to `lean-implementation-agent`
- [ ] Markdown implementation tasks route to `implementer`
- [ ] Language extraction works from TODO.md
- [ ] Language extraction works from state.json (priority 1)
- [ ] Routing validation catches mismatches
- [ ] Artifact validation prevents phantom research
- [ ] Error messages are clear and actionable

### Non-Functional Requirements

- [ ] No regression in existing commands
- [ ] Orchestrator context window usage remains <15%
- [ ] Routing adds <1s overhead
- [ ] Logging provides clear audit trail
- [ ] Documentation matches implementation

### Testing Requirements

- [ ] All test cases pass
- [ ] Regression tests pass
- [ ] Manual testing confirms fix
- [ ] Task 258 research creates artifacts
- [ ] Task 257 research creates artifacts

---

## Files to Modify

### Primary Changes

1. **`.opencode/agent/orchestrator.md`** (orchestrator implementation)
   - Add Stage 2 (DetermineRouting) implementation
   - Add language extraction logic
   - Add routing validation logic
   - Add artifact validation logic
   - Add comprehensive logging

### Secondary Changes

2. **`.opencode/context/core/system/routing-guide.md`** (routing documentation)
   - Update with implementation details
   - Add troubleshooting section
   - Add logging examples

3. **`.opencode/command/research.md`** (command documentation)
   - Clarify language-based routing behavior
   - Add troubleshooting section
   - Add examples for lean vs markdown

4. **`.opencode/command/implement.md`** (command documentation)
   - Clarify language-based routing behavior
   - Add troubleshooting section
   - Add examples for lean vs markdown

### Testing Files

5. **`.opencode/specs/266_*/tests/routing-tests.sh`** (test script)
   - Test lean research routing
   - Test markdown research routing
   - Test lean implementation routing
   - Test routing validation
   - Test artifact validation

---

## Risk Assessment

### High Risk

**Risk**: Orchestrator changes break existing commands  
**Mitigation**: Comprehensive regression testing, rollback plan

**Risk**: Language extraction fails for edge cases  
**Mitigation**: Robust fallback to "general", clear error messages

### Medium Risk

**Risk**: Routing validation too strict, blocks valid cases  
**Mitigation**: Careful validation logic, allow override flag

**Risk**: Artifact validation false positives  
**Mitigation**: Only validate when status=completed, check file existence and size

### Low Risk

**Risk**: Performance overhead from language extraction  
**Mitigation**: Language extraction is fast (grep + sed), <1s overhead

**Risk**: Documentation drift  
**Mitigation**: Update documentation alongside implementation

---

## Timeline Estimate

| Phase | Task | Estimated Time |
|-------|------|----------------|
| 1 | Orchestrator Stage 2 Implementation | 2-3 hours |
| 2 | Validation Improvements | 1-2 hours |
| 3 | Testing and Validation | 1 hour |
| 4 | Documentation Updates | 0.5 hours |
| 5 | Regression Testing | 0.5 hours |
| **Total** | | **5-7 hours** |

**Recommended**: Allocate 6 hours for implementation and testing.

---

## Next Steps

1. **Create Implementation Plan** (Task 266)
   - Use this research report as input
   - Create phased implementation plan
   - Estimate effort per phase

2. **Implement Fix** (Task 266)
   - Phase 1: Orchestrator Stage 2
   - Phase 2: Validation improvements
   - Phase 3: Testing and validation

3. **Validate Fix** (Task 266)
   - Test with Task 258 (lean research)
   - Test with Task 257 (lean research)
   - Verify artifacts created
   - Verify state.json updated

4. **Document Fix** (Task 266)
   - Update orchestrator.md
   - Update routing-guide.md
   - Update command documentation

5. **Close Related Issues**
   - Mark Task 258 as [NOT STARTED] (reset phantom research)
   - Mark Task 257 as [NOT STARTED] (reset phantom research)
   - Document fix in task 266 summary

---

## References

### Documentation Files

- `.opencode/agent/orchestrator.md` - Orchestrator implementation
- `.opencode/command/research.md` - Research command specification
- `.opencode/command/implement.md` - Implementation command specification
- `.opencode/context/core/system/routing-guide.md` - Routing guide
- `.opencode/context/core/workflows/delegation-guide.md` - Delegation guide
- `.opencode/agent/subagents/researcher.md` - General researcher agent
- `.opencode/agent/subagents/lean-research-agent.md` - Lean research agent

### Related Tasks

- Task 240: OpenAgents migration (frontmatter delegation pattern)
- Task 244: Phase 1 context index and research frontmatter prototype
- Task 245: Phase 2 core architecture migration
- Task 254: Refactor /research command (related but different issue)
- Task 258: Resolve Truth.lean Sorries (phantom research victim)
- Task 257: Completeness Proofs (phantom research victim)

### Evidence Files

- `.opencode/specs/TODO.md` - Task 258 and 257 entries
- `.opencode/specs/state.json` - Missing entries for 258 and 257
- `.opencode/specs/256_*/reports/research-001.md` - Working example (markdown)

---

## Conclusion

The `/research` command language-based routing failure is caused by the orchestrator NOT implementing Stage 2 (DetermineRouting) as documented. The routing configuration exists in command frontmatter, but the orchestrator doesn't read or use it. This causes Lean tasks to route to the default `researcher` agent instead of `lean-research-agent`, resulting in "phantom research" where status is updated but no artifacts are created.

The fix is straightforward: implement Stage 2 (DetermineRouting) in the orchestrator to extract language from TODO.md and route to the correct agent based on command frontmatter routing configuration. This will enable proper language-based routing for both `/research` and `/implement` commands, ensuring Lean tasks receive Lean-specific research and implementation.

**Estimated Effort**: 5-7 hours  
**Priority**: High (blocks Lean research tasks)  
**Impact**: Enables proper Lean research with specialized tools (Loogle, LeanSearch, lean-lsp-mcp)

---

**End of Research Report**
