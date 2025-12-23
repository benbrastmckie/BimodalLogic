# Implementation Plan: Enhance `/task` Command with Intelligent Agent Routing

**Project**: #006  
**Version**: 001  
**Date**: 2025-12-19  
**Complexity**: Complex  
**Estimated Total Effort**: 40-60 hours

---

## Executive Summary

This implementation plan details the enhancement of the `/task` command to provide intelligent, automatic routing to appropriate coordinator agents based on task type analysis. Currently, `/task` routes all tasks through `task-executor`, which creates research reports and implementation plans but does not execute the actual work—requiring manual follow-up with `/lean` or `/implement` commands. This enhancement will enable `/task` to analyze task types and route directly to specialized coordinator agents (proof-developer, documenter, refactorer, researcher, implementer, batch-task-orchestrator) for end-to-end execution.

**Note**: Meta-system tasks (agent/command creation) are excluded from automatic routing and should continue to use the `/meta` command directly.

The plan addresses a critical gap: **14 specialist agents referenced in the architecture are missing from the codebase**, including the three CRITICAL agents for LEAN proof development (tactic-specialist, term-mode-specialist, metaprogramming-specialist). The implementation is structured in 5 phases, prioritizing creation of missing critical specialists, then enhancing task type detection, implementing intelligent routing, creating remaining specialists, and comprehensive testing.

This enhancement will transform `/task` from a planning-only command into a complete task execution system that automatically selects the right workflow based on task characteristics, eliminating the need for users to manually determine whether to use `/lean`, `/implement`, `/document`, or other specialized commands.

---

## Architecture Design

### Task Type Detection Logic

**Location**: Enhanced `task-executor` agent (`.opencode/agent/subagents/task-executor.md`)

**Detection Strategy**: Multi-factor analysis combining keywords, file paths, effort estimates, and task descriptions.

**Task Type Classification System**:

```yaml
task_types:
  lean_proof:
    indicators:
      - files_in: ["Logos/", "LogosTest/"]
      - keywords: ["prove", "theorem", "lemma", "axiom", "proof", "derivation", "tactic"]
      - effort: "> 2 hours" (typically)
      - description_patterns: ["implement.*proof", "prove.*theorem", "show.*holds"]
    coordinator: "@subagents/proof-developer"
    specialists: ["tactic-specialist", "term-mode-specialist", "metaprogramming-specialist"]
    
  documentation:
    indicators:
      - files_in: ["Documentation/", "README.md", "*.md"]
      - keywords: ["document", "update docs", "write documentation", "add README"]
      - effort: "< 2 hours" (typically)
      - description_patterns: ["update.*documentation", "add.*docstring", "improve.*docs"]
    coordinator: "@subagents/documenter"
    specialists: ["doc-analyzer", "doc-writer"]
    
  refactoring:
    indicators:
      - files_in: ["Logos/", ".opencode/", "scripts/"]
      - keywords: ["refactor", "clean up", "simplify", "improve code", "reorganize"]
      - effort: "1-4 hours" (typically)
      - description_patterns: ["refactor.*", "clean.*code", "simplify.*proof"]
    coordinator: "@subagents/refactorer"
    specialists: ["style-checker", "proof-simplifier"]
    
  research:
    indicators:
      - keywords: ["research", "investigate", "explore", "design", "plan"]
      - effort: "variable"
      - description_patterns: ["research.*", "investigate.*", "explore.*options"]
    coordinator: "@subagents/researcher"
    specialists: ["lean-search-specialist", "loogle-specialist", "web-research-specialist"]
    
  general_code:
    indicators:
      - files_in: [".opencode/", "scripts/", "context/"]
      - keywords: ["implement", "create", "build", "fix", "add"]
      - not_lean: true
      - not_meta: true  # Excludes agent/command files
      - description_patterns: ["implement.*utility", "fix.*bug", "add.*feature"]
    coordinator: "@subagents/implementer"
    specialists: [] # No specialists by design
    
  batch_tasks:
    indicators:
      - multiple_tasks: true
      - task_count: "> 1"
    coordinator: "@subagents/batch-task-orchestrator"
    specialists: ["task-dependency-analyzer", "batch-status-manager"]

# NOTE: Meta-system tasks (agent/command creation) are NOT handled by /task
# Use /meta command directly for these tasks
```

**Detection Algorithm**:

```python
def detect_task_type(task_details: TaskDetails) -> TaskType:
    """
    Multi-factor task type detection with priority ordering.
    
    Priority:
    1. Batch tasks (multiple task numbers)
    2. LEAN proof tasks (highest complexity)
    3. Research tasks (explicit research keywords)
    4. Refactoring tasks (code improvement)
    5. Documentation tasks (doc updates)
    6. General code tasks (fallback)
    
    Note: Meta-system tasks are NOT detected - use /meta command directly
    """
    
    # Priority 1: Batch tasks
    if task_details.is_batch:
        return TaskType.BATCH_TASKS
    
    # Priority 2: LEAN proof tasks
    if matches_lean_proof_indicators(task_details):
        return TaskType.LEAN_PROOF
    
    # Priority 3: Research tasks
    if matches_research_indicators(task_details):
        return TaskType.RESEARCH
    
    # Priority 4: Refactoring tasks
    if matches_refactoring_indicators(task_details):
        return TaskType.REFACTORING
    
    # Priority 5: Documentation tasks
    if matches_documentation_indicators(task_details):
        return TaskType.DOCUMENTATION
    
    # Priority 6: General code tasks (fallback)
    return TaskType.GENERAL_CODE

def matches_lean_proof_indicators(task: TaskDetails) -> bool:
    """Check if task matches LEAN proof indicators."""
    score = 0
    
    # File path indicators (strong signal)
    if any(f.startswith("Logos/") for f in task.files_affected):
        score += 3
    
    # Keyword indicators
    lean_keywords = ["prove", "theorem", "lemma", "axiom", "proof", "derivation", "tactic"]
    if any(kw in task.description.lower() for kw in lean_keywords):
        score += 2
    
    # Effort indicator (weak signal)
    if task.effort_hours > 2:
        score += 1
    
    # Description pattern matching
    patterns = [r"implement.*proof", r"prove.*theorem", r"show.*holds"]
    if any(re.search(p, task.description, re.I) for p in patterns):
        score += 2
    
    # Threshold: score >= 3 indicates LEAN proof task
    return score >= 3
```

### Routing Decision Tree

**Enhanced Task Executor Workflow**:

```
/task {number(s)} → orchestrator → task-executor
                                    ↓
                    [Stage 1: Mark IN PROGRESS in TODO.md]
                                    ↓
                    [Stage 2: Extract Task Details]
                                    ↓
                    [Stage 3: Detect Task Type] ← NEW ENHANCED LOGIC
                                    ↓
                    ┌───────────────┴───────────────┐
                    │                               │
            [Single Task]                    [Batch Tasks]
                    │                               │
                    ↓                               ↓
        [Assess Complexity]              batch-task-orchestrator
                    │                               │
        ┌───────────┼───────────┐                  │
        │           │           │                  │
    [Simple]   [Moderate]  [Complex]              │
        │           │           │                  │
        └───────────┴───────────┘                  │
                    │                               │
        [Determine Coordinator Based on Type]      │
                    │                               │
         ┌───────────┼───────────┬─────────┬────────┼──────────┐
         │           │           │         │        │          │
    lean_proof  documentation refactoring research general  batch
         │           │           │         │        │          │
         ↓           ↓           ↓         ↓        ↓          ↓
proof-developer documenter refactorer researcher implementer batch-orch
         │           │           │         │        │          │
         ↓           ↓           ↓         ↓        ↓          ↓
    [Specialists] [Specialists] [Specialists] [Specialists] [No Spec] [Specialists]
        │           │           │         │        │        │          │
        ↓           ↓           ↓         ↓        ↓        ↓          ↓
   [Execute]    [Execute]   [Execute]  [Execute] [Execute] [Execute] [Execute]
        │           │           │         │        │        │          │
        └───────────┴───────────┴─────────┴────────┴────────┴──────────┘
                                    │
                    [Stage 4: Mark COMPLETE in TODO.md]
                                    │
                    [Stage 5: Return Summary to User]
```

### Coordinator Agent Responsibilities

**Existing Coordinators** (already implemented):
- `proof-developer`: LEAN 4 proof implementation
- `documenter`: Documentation maintenance
- `refactorer`: Code refactoring
- `researcher`: Research coordination
- `implementer`: General code implementation
- `batch-task-orchestrator`: Batch task execution

**Note**: The `meta` coordinator exists but is NOT invoked by `/task`. Meta-system tasks should use `/meta` command directly.

**Coordinator Coordination Pattern**:

Each coordinator follows the same pattern:
1. **Receive task** from task-executor with context
2. **Delegate to specialists** for specific subtasks
3. **Coordinate workflow** through multiple stages
4. **Create artifacts** in `.opencode/specs/NNN_project/`
5. **Return references** and summaries (not full artifacts)

**New Routing in Task Executor**:

```xml
<stage id="4" name="RouteToCoordinator">
  <action>Route to appropriate coordinator based on task type</action>
  <process>
    1. Determine coordinator from task type
    2. Prepare context for coordinator
    3. Route with appropriate context level
    4. Receive results and artifacts
  </process>
  <routing>
    <route to="@subagents/proof-developer" when="lean_proof">
      <context_level>Level 3</context_level>
      <pass_data>
        - Task details
        - Implementation plan (if exists)
        - Domain context (lean4/, logic/)
        - Patterns and templates
      </pass_data>
      <expected_return>
        - Implemented proof files
        - Verification status
        - Summary
      </expected_return>
    </route>
    
    <route to="@subagents/documenter" when="documentation">
      <context_level>Level 2</context_level>
      <pass_data>
        - Task details
        - Documentation scope
        - Documentation standards
      </pass_data>
      <expected_return>
        - Updated documentation
        - Summary
      </expected_return>
    </route>
    
    <!-- Similar routes for other coordinators -->
  </routing>
</stage>
```

### Specialist Agent Coordination Patterns

**Pattern 1: Research Specialists** (lean-search, loogle, web-research)
- **Coordinator**: researcher
- **Pattern**: Parallel search → Synthesize results → Create report
- **Context**: Level 1 (focused search queries)

**Pattern 2: Proof Implementation Specialists** (tactic, term-mode, metaprogramming)
- **Coordinator**: proof-developer
- **Pattern**: Sequential implementation → Verify each step → Commit
- **Context**: Level 2 (proof context + patterns)

**Pattern 3: Refactoring Specialists** (style-checker, proof-simplifier)
- **Coordinator**: refactorer
- **Pattern**: Analyze → Identify improvements → Apply → Verify
- **Context**: Level 2 (code + style guides)

**Pattern 4: Documentation Specialists** (doc-analyzer, doc-writer)
- **Coordinator**: documenter
- **Pattern**: Analyze gaps → Write/update → Verify completeness
- **Context**: Level 2 (code + doc standards)

**Pattern 5: Planning Specialists** (complexity-analyzer, dependency-mapper)
- **Coordinator**: planner
- **Pattern**: Analyze complexity → Map dependencies → Create plan
- **Context**: Level 2 (task + codebase)

**Note**: Meta specialists (agent-generator, command-generator) will NOT be created in this implementation, as meta-system tasks are excluded from `/task` routing. Use `/meta` command directly for agent/command creation.

---

## Implementation Phases

### Phase 1: Create Missing CRITICAL Specialist Agents (Priority: CRITICAL)

**Duration**: 12-16 hours  
**Blocking**: All LEAN proof tasks

**Agents to Create**:

1. **tactic-specialist** (`.opencode/agent/subagents/specialists/tactic-specialist.md`)
   - **Purpose**: Implement tactic-based LEAN 4 proofs
   - **Input**: Proof goal, suggested tactics, tactic patterns
   - **Output**: Implemented tactic proof, verification status
   - **Tools**: read, write, task (lean-lsp-mcp)
   - **Workflow**:
     1. Parse proof goal and context
     2. Select appropriate tactics from patterns
     3. Construct tactic proof step-by-step
     4. Verify with lean-lsp-mcp
     5. Return implemented proof
   - **Dependencies**: lean-lsp-mcp server, tactic patterns

2. **term-mode-specialist** (`.opencode/agent/subagents/specialists/term-mode-specialist.md`)
   - **Purpose**: Implement term-mode LEAN 4 proofs
   - **Input**: Type signature, term construction strategy
   - **Output**: Implemented term-mode proof, verification status
   - **Tools**: read, write, task (lean-lsp-mcp)
   - **Workflow**:
     1. Parse type signature
     2. Construct term using type-guided synthesis
     3. Verify type correctness with lean-lsp-mcp
     4. Return implemented term
   - **Dependencies**: lean-lsp-mcp server, type theory knowledge

3. **metaprogramming-specialist** (`.opencode/agent/subagents/specialists/metaprogramming-specialist.md`)
   - **Purpose**: Implement custom tactics and metaprogramming in LEAN 4
   - **Input**: Metaprogramming requirements, Expr manipulation needs
   - **Output**: Implemented metaprogramming code, verification status
   - **Tools**: read, write, task (lean-lsp-mcp)
   - **Workflow**:
     1. Parse metaprogramming requirements
     2. Design Expr manipulation strategy
     3. Implement using LEAN 4 metaprogramming API
     4. Verify with lean-lsp-mcp
     5. Return implemented code
   - **Dependencies**: lean-lsp-mcp server, LEAN 4 metaprogramming guide

**Deliverables**:
- 3 specialist agent files in `.opencode/agent/subagents/specialists/`
- Unit tests for each specialist (if applicable)
- Documentation in agent files
- Integration with proof-developer coordinator

**Success Criteria**:
- All 3 specialists can be invoked by proof-developer
- Specialists can implement simple proofs
- lean-lsp-mcp integration works
- Verification status returned correctly

---

### Phase 2: Enhance Task-Executor with Task Type Detection (Priority: HIGH)

**Duration**: 8-12 hours  
**Blocking**: Intelligent routing

**Changes Required**:

1. **Update task-executor.md** (`.opencode/agent/subagents/task-executor.md`)
   - Add new stage: `DetectTaskType` (after `ExtractTask`, before `AssessComplexity`)
   - Implement multi-factor task type detection algorithm
   - Add task type classification system
   - Update routing logic to use detected task type

2. **Add Task Type Detection Logic**:
   ```xml
   <stage id="3" name="DetectTaskType">
     <action>Analyze task to determine type</action>
     <process>
       1. Extract indicators from task details
       2. Apply detection algorithm with priority ordering
       3. Determine task type (lean_proof, documentation, refactoring, etc.)
       4. Select appropriate coordinator agent
       5. Prepare coordinator-specific context
     </process>
     <task_type_indicators>
       <!-- Full classification system from Architecture Design -->
     </task_type_indicators>
     <detection_algorithm>
       <!-- Multi-factor scoring algorithm -->
     </detection_algorithm>
     <checkpoint>Task type detected and coordinator selected</checkpoint>
   </stage>
   ```

3. **Update Routing Logic**:
   - Replace current "DetermineNextStep" stage with "RouteToCoordinator"
   - Add routing patterns for each task type
   - Include context level specifications
   - Define expected returns from each coordinator

4. **Maintain Backward Compatibility**:
   - Keep existing simple task execution path
   - Preserve TODO.md status tracking
   - Maintain artifact organization in `.opencode/specs/`
   - Keep research + planning workflow for complex tasks

**Deliverables**:
- Updated task-executor.md with task type detection
- Routing logic for all 7 task types
- Backward compatibility preserved
- Documentation of detection algorithm

**Success Criteria**:
- Task type detection correctly identifies 90%+ of tasks
- Routing to coordinators works for all task types
- Existing simple task workflow still works
- TODO.md status tracking preserved

---

### Phase 3: Create Task Router and Coordinator Integration (Priority: HIGH)

**Duration**: 10-14 hours  
**Blocking**: End-to-end execution

**Option A: Enhance Task-Executor** (RECOMMENDED)
- Integrate routing logic directly into task-executor
- No new agent needed
- Simpler architecture
- Easier to maintain

**Option B: Create Separate Task-Router Agent**
- New agent: `task-router.md`
- Separates routing logic from execution
- More modular but adds complexity
- Not recommended due to added overhead

**Recommended Approach: Option A**

**Changes Required**:

1. **Update task-executor workflow**:
   - Add `RouteToCoordinator` stage (replaces `DetermineNextStep`)
   - Remove `ExecuteSimpleTask` stage (coordinators handle execution)
   - Update `MarkTaskComplete` to work with coordinator results
   - Enhance `ReturnToOrchestrator` to include coordinator results

2. **Coordinator Integration Pattern**:
   ```xml
   <stage id="4" name="RouteToCoordinator">
     <action>Route to appropriate coordinator for execution</action>
     <process>
       1. Select coordinator based on task type
       2. Prepare coordinator-specific context
       3. Route with appropriate context level
       4. Monitor coordinator execution
       5. Receive results and artifacts
       6. Validate coordinator output
     </process>
     <routing>
       <!-- Routing patterns for each coordinator -->
     </routing>
     <coordinator_results>
       <expected_format>
         {
           "status": "completed|in_progress|failed",
           "artifacts": ["path1", "path2"],
           "summary": "Brief summary",
           "verification_status": "passed|failed",
           "next_steps": "Recommendations"
         }
       </expected_format>
     </coordinator_results>
     <checkpoint>Coordinator execution complete</checkpoint>
   </stage>
   ```

3. **Update TODO.md Status Tracking**:
   - Mark IN PROGRESS at start (existing)
   - Mark COMPLETE after coordinator execution (enhanced)
   - Handle coordinator failures gracefully
   - Preserve timestamps and status history

4. **Error Handling**:
   - Coordinator execution failures
   - Timeout handling (per coordinator)
   - Partial completion handling
   - Rollback strategy if needed

**Deliverables**:
- Enhanced task-executor with coordinator routing
- Integration tests for each coordinator
- Error handling for coordinator failures
- Updated documentation

**Success Criteria**:
- All 7 task types route to correct coordinator
- Coordinators execute and return results
- TODO.md status tracking works end-to-end
- Error handling prevents system failures

---

### Phase 4: Create Remaining Specialist Agents (Priority: MEDIUM)

**Duration**: 12-16 hours  
**Blocking**: Full coordinator functionality

**Agents to Create** (9 total, excluding meta specialists):

**Research Specialists** (3 agents):

1. **lean-search-specialist** (`.opencode/agent/subagents/specialists/lean-search-specialist.md`)
   - **Purpose**: Semantic search of LEAN libraries using LeanSearch
   - **Input**: Search query, keywords
   - **Output**: Relevant definitions/theorems, search results artifact
   - **Tools**: read, write, task (LeanSearch MCP)
   - **Priority**: HIGH (needed for research tasks)

2. **loogle-specialist** (`.opencode/agent/subagents/specialists/loogle-specialist.md`)
   - **Purpose**: Formal search of LEAN libraries using type signatures
   - **Input**: Type signature, search pattern
   - **Output**: Matching functions/theorems, search results artifact
   - **Tools**: read, write, task (Loogle API)
   - **Priority**: HIGH (needed for research tasks)

3. **web-research-specialist** (`.opencode/agent/subagents/specialists/web-research-specialist.md`)
   - **Purpose**: Web research for concepts, papers, documentation
   - **Input**: Research topic, research questions
   - **Output**: Research findings, external resources
   - **Tools**: read, write, webfetch
   - **Priority**: MEDIUM (nice to have for research tasks)

**Planning Specialists** (2 agents):

4. **complexity-analyzer** (`.opencode/agent/subagents/specialists/complexity-analyzer.md`)
   - **Purpose**: Analyze task complexity and estimate effort
   - **Input**: Task description, codebase context
   - **Output**: Complexity level, effort estimate, challenges
   - **Tools**: read, glob
   - **Priority**: MEDIUM (planner can do basic analysis)

5. **dependency-mapper** (`.opencode/agent/subagents/specialists/dependency-mapper.md`)
   - **Purpose**: Map dependencies and required imports
   - **Input**: Task description, codebase structure
   - **Output**: Required imports, prerequisites, library functions
   - **Tools**: read, glob, grep
   - **Priority**: MEDIUM (planner can do basic mapping)

**Refactoring Specialists** (2 agents):

6. **style-checker** (`.opencode/agent/subagents/specialists/style-checker.md`)
   - **Purpose**: Check adherence to LEAN 4 style guide
   - **Input**: LEAN 4 code files
   - **Output**: Style violations, recommendations
   - **Tools**: read, glob
   - **Priority**: MEDIUM (refactorer can do basic checks)

7. **proof-simplifier** (`.opencode/agent/subagents/specialists/proof-simplifier.md`)
   - **Purpose**: Identify opportunities to simplify proofs
   - **Input**: LEAN 4 proof code
   - **Output**: Simplification opportunities, suggested improvements
   - **Tools**: read, task (proof-optimizer integration)
   - **Priority**: MEDIUM (refactorer can do basic simplification)

**Documentation Specialists** (2 agents):

8. **doc-analyzer** (`.opencode/agent/subagents/specialists/doc-analyzer.md`)
   - **Purpose**: Analyze documentation gaps and bloat
   - **Input**: Code files, existing documentation
   - **Output**: Gap analysis, bloat identification
   - **Tools**: read, glob
   - **Priority**: MEDIUM (documenter can do basic analysis)

9. **doc-writer** (`.opencode/agent/subagents/specialists/doc-writer.md`)
    - **Purpose**: Write and update documentation
    - **Input**: Code to document, documentation standards
    - **Output**: Written/updated documentation
    - **Tools**: read, write
    - **Priority**: MEDIUM (documenter can write directly)

**Note**: Meta specialists (agent-generator, command-generator) are NOT included in this phase as meta-system tasks are excluded from `/task` routing.

**Implementation Order** (by priority):
1. lean-search-specialist, loogle-specialist (HIGH - research tasks)
2. web-research-specialist (MEDIUM - research tasks)
3. complexity-analyzer, dependency-mapper (MEDIUM - planning tasks)
4. style-checker, proof-simplifier (MEDIUM - refactoring tasks)
5. doc-analyzer, doc-writer (MEDIUM - documentation tasks)

**Deliverables**:
- 9 specialist agent files (excluding meta specialists)
- Integration with respective coordinators
- Documentation for each specialist
- Unit tests (where applicable)

**Success Criteria**:
- All specialists can be invoked by coordinators
- Specialists return expected output format
- Integration with coordinators works
- No breaking changes to existing workflows

---

### Phase 5: Testing and Validation (Priority: CRITICAL)

**Duration**: 8-12 hours  
**Blocking**: Production deployment

**Testing Strategy**:

**1. Unit Tests for Task Type Detection**:
```python
test_cases = [
    {
        "task": {
            "number": 9,
            "title": "Begin completeness proofs",
            "files": ["Logos/Core/Metalogic/Completeness.lean"],
            "keywords": ["prove", "completeness"],
            "effort": 80
        },
        "expected_type": "lean_proof",
        "expected_coordinator": "@subagents/proof-developer"
    },
    {
        "task": {
            "number": 61,
            "title": "Add missing directory READMEs",
            "files": ["Documentation/", "Logos/README.md"],
            "keywords": ["add", "README", "documentation"],
            "effort": 1
        },
        "expected_type": "documentation",
        "expected_coordinator": "@subagents/documenter"
    },
    # ... more test cases for each task type
]
```

**2. Integration Tests for Coordinator Routing**:
- Test routing to proof-developer for LEAN proof tasks
- Test routing to documenter for documentation tasks
- Test routing to refactorer for refactoring tasks
- Test routing to researcher for research tasks
- Test routing to implementer for general code tasks
- Test routing to batch-task-orchestrator for batch tasks
- Verify meta-system tasks are NOT routed (should use /meta directly)

**3. End-to-End Tests for Sample TODO.md Tasks**:
- Create test TODO.md with sample tasks
- Execute `/task {number}` for each task type
- Verify correct coordinator invoked
- Verify artifacts created in correct locations
- Verify TODO.md status updated correctly
- Verify summary returned to user

**4. Regression Tests for Existing Functionality**:
- Test existing single-task workflow still works
- Test batch execution still works
- Test TODO.md status tracking preserved
- Test artifact organization unchanged
- Test backward compatibility maintained

**5. Error Handling Tests**:
- Test task type detection failures
- Test coordinator execution failures
- Test timeout handling
- Test partial completion scenarios
- Test TODO.md update failures

**6. Performance Tests**:
- Measure task type detection time (< 1 second)
- Measure coordinator routing overhead (< 2 seconds)
- Measure end-to-end execution time (varies by task)
- Ensure no performance regression

**Test Execution Plan**:
1. Run unit tests for task type detection
2. Run integration tests for each coordinator
3. Run end-to-end tests for sample tasks
4. Run regression tests for existing functionality
5. Run error handling tests
6. Run performance tests
7. Fix any failures
8. Re-run all tests until 100% pass

**Deliverables**:
- Test suite for task type detection
- Integration tests for coordinators
- End-to-end test scenarios
- Regression test suite
- Performance benchmarks
- Test documentation

**Success Criteria**:
- 100% of unit tests pass
- 100% of integration tests pass
- 100% of end-to-end tests pass
- 100% of regression tests pass
- No performance regression
- All error scenarios handled gracefully

---

## Task Type Classification System

**Complete Classification Matrix**:

| Task Type | File Indicators | Keyword Indicators | Effort Range | Coordinator | Specialists |
|-----------|----------------|-------------------|--------------|-------------|-------------|
| **lean_proof** | Logos/, LogosTest/ | prove, theorem, lemma, axiom, proof, derivation, tactic | > 2 hours | proof-developer | tactic-specialist, term-mode-specialist, metaprogramming-specialist |
| **documentation** | Documentation/, *.md, README.md | document, update docs, write documentation, add README | < 2 hours | documenter | doc-analyzer, doc-writer |
| **refactoring** | Logos/, .opencode/, scripts/ | refactor, clean up, simplify, improve code, reorganize | 1-4 hours | refactorer | style-checker, proof-simplifier |
| **research** | Any | research, investigate, explore, design, plan | Variable | researcher | lean-search-specialist, loogle-specialist, web-research-specialist |
| **general_code** | .opencode/, scripts/, context/ | implement, create, build, fix, add (non-LEAN, non-meta) | Variable | implementer | None |
| **batch_tasks** | N/A (multiple tasks) | N/A | N/A | batch-task-orchestrator | task-dependency-analyzer, batch-status-manager |

**Note**: Meta-system tasks (agent/command creation in `.opencode/agent/`, `.opencode/command/`) are NOT handled by `/task`. Use `/meta` command directly.

**Detection Priority Order**:
1. Batch tasks (multiple task numbers) - HIGHEST
2. LEAN proof tasks (highest complexity)
3. Research tasks (explicit research keywords)
4. Refactoring tasks (code improvement)
5. Documentation tasks (doc updates)
6. General code tasks (fallback) - LOWEST

**Ambiguity Resolution**:
- If multiple types match, use priority order
- If score is tied, prefer higher priority type
- If still ambiguous, default to general_code
- Log ambiguity warning for manual review

---

## Specialist Agent Specifications

### CRITICAL Specialists (Phase 1)

#### 1. tactic-specialist

**File**: `.opencode/agent/subagents/specialists/tactic-specialist.md`

**Purpose**: Implement tactic-based LEAN 4 proofs using common proof tactics

**Input Format**:
```yaml
proof_goal:
  theorem_name: "example_theorem"
  goal_state: "⊢ P → Q"
  context: ["h1: P", "h2: Q → R"]
  suggested_tactics: ["intro", "apply", "exact"]
  tactic_patterns: "path/to/tactic-patterns.md"
```

**Output Format**:
```yaml
implemented_proof:
  code: |
    theorem example_theorem : P → Q := by
      intro h
      apply some_lemma
      exact h
  verification_status: "passed"
  tactics_used: ["intro", "apply", "exact"]
  proof_length: 3
```

**Coordination Pattern**:
- Invoked by: proof-developer
- Context level: Level 2
- Workflow: Parse goal → Select tactics → Construct proof → Verify → Return

**Dependencies**:
- lean-lsp-mcp server (for verification)
- context/lean4/patterns/tactic-patterns.md
- Existing LEAN 4 codebase for examples

**Priority**: CRITICAL (blocks all LEAN proof tasks)

---

#### 2. term-mode-specialist

**File**: `.opencode/agent/subagents/specialists/term-mode-specialist.md`

**Purpose**: Implement term-mode LEAN 4 proofs using type-guided term construction

**Input Format**:
```yaml
type_signature:
  theorem_name: "example_theorem"
  type: "P → Q"
  context: ["h1: P", "h2: Q → R"]
  construction_strategy: "direct" | "by_cases" | "induction"
```

**Output Format**:
```yaml
implemented_term:
  code: |
    theorem example_theorem : P → Q :=
      fun h => some_lemma h
  verification_status: "passed"
  term_complexity: "simple"
```

**Coordination Pattern**:
- Invoked by: proof-developer
- Context level: Level 2
- Workflow: Parse type → Construct term → Verify type → Return

**Dependencies**:
- lean-lsp-mcp server (for type checking)
- Type theory knowledge
- Existing LEAN 4 codebase for examples

**Priority**: CRITICAL (blocks all term-mode proof tasks)

---

#### 3. metaprogramming-specialist

**File**: `.opencode/agent/subagents/specialists/metaprogramming-specialist.md`

**Purpose**: Implement custom tactics and metaprogramming in LEAN 4

**Input Format**:
```yaml
metaprogramming_task:
  task_type: "custom_tactic" | "syntax_extension" | "elaborator"
  requirements: "Description of what to implement"
  api_usage: ["Expr", "MetaM", "TacticM"]
```

**Output Format**:
```yaml
implemented_metaprogramming:
  code: |
    syntax "my_tactic" : tactic
    elab_rules : tactic
    | `(tactic| my_tactic) => do
        -- implementation
  verification_status: "passed"
  api_used: ["Expr", "MetaM"]
```

**Coordination Pattern**:
- Invoked by: proof-developer
- Context level: Level 2
- Workflow: Parse requirements → Design strategy → Implement → Verify → Return

**Dependencies**:
- lean-lsp-mcp server
- LEAN 4 metaprogramming guide
- Existing metaprogramming examples

**Priority**: CRITICAL (blocks custom tactic development)

---

### HIGH Priority Specialists (Phase 4 - Part 1)

#### 4. lean-search-specialist

**File**: `.opencode/agent/subagents/specialists/lean-search-specialist.md`

**Purpose**: Semantic search of LEAN libraries using LeanSearch MCP

**Input**: Search query, keywords  
**Output**: Relevant definitions/theorems, search results artifact  
**Tools**: read, write, task (LeanSearch MCP)  
**Priority**: HIGH

---

#### 5. loogle-specialist

**File**: `.opencode/agent/subagents/specialists/loogle-specialist.md`

**Purpose**: Formal search of LEAN libraries using type signatures

**Input**: Type signature, search pattern  
**Output**: Matching functions/theorems, search results artifact  
**Tools**: read, write, task (Loogle API)  
**Priority**: HIGH

---

### MEDIUM Priority Specialists (Phase 4 - Part 2)

#### 6-9. Remaining Specialists

See Phase 4 section for detailed specifications of:
- web-research-specialist
- complexity-analyzer
- dependency-mapper
- style-checker
- proof-simplifier
- doc-analyzer
- doc-writer

**Note**: agent-generator and command-generator are NOT included as meta-system tasks are excluded from `/task` routing.

---

## File Modifications Required

### 1. `.opencode/command/task.md`

**Changes**:
- Update description to mention intelligent routing
- Add note about automatic coordinator selection
- Update examples to show end-to-end execution
- Document task type detection

**Diff**:
```diff
  ---
  name: task
  agent: orchestrator
- description: "Complete task(s) from TODO.md with automatic status tracking and batch execution support"
+ description: "Complete task(s) from TODO.md with intelligent routing, automatic coordinator selection, and end-to-end execution"
  ---
  
  You are executing task(s) from the TODO.md task list for the ProofChecker project.
  
+ **Intelligent Routing**: The `/task` command automatically analyzes task type and routes to the appropriate coordinator agent:
+ - LEAN proof tasks → proof-developer (tactic, term-mode, metaprogramming specialists)
+ - Documentation tasks → documenter (doc-analyzer, doc-writer specialists)
+ - Refactoring tasks → refactorer (style-checker, proof-simplifier specialists)
+ - Research tasks → researcher (lean-search, loogle, web-research specialists)
+ - General code tasks → implementer (no specialists)
+ - Batch tasks → batch-task-orchestrator (dependency-analyzer, status-manager specialists)
+ 
+ **Note**: Meta-system tasks (agent/command creation) are NOT routed by `/task`. Use `/meta` command directly for these.
+ 
+ **End-to-End Execution**: Tasks are executed completely within `/task` - no manual follow-up commands needed.
```

---

### 2. `.opencode/agent/subagents/task-executor.md`

**Major Changes**:
- Add `DetectTaskType` stage (new stage 3)
- Replace `DetermineNextStep` with `RouteToCoordinator` (new stage 4)
- Update `ExecuteSimpleTask` to work with coordinators (stage 5)
- Update `MarkTaskComplete` to handle coordinator results (stage 6)
- Add task type classification system
- Add coordinator routing patterns

**New Sections**:
```xml
<task_type_detection>
  <!-- Full classification system -->
</task_type_detection>

<coordinator_routing>
  <!-- Routing patterns for each coordinator -->
</coordinator_routing>

<backward_compatibility>
  <!-- Preserve existing simple task workflow -->
</backward_compatibility>
```

---

### 3. `.opencode/agent/orchestrator.md`

**Changes**:
- Update routing table to include task type detection
- Add note about intelligent task routing
- Update workflow classification to mention task types

**Diff**:
```diff
  <workflow_classification>
+   <task_execution_workflow>
+     Triggers: "/task {number(s)}"
+     Agent: @subagents/task-executor
+     Features: Intelligent task type detection, automatic coordinator routing
+     Context: lean4/, logic/, project/
+     Complexity: Variable (depends on task type)
+   </task_execution_workflow>
+   
    <review_workflow>
      Triggers: "analyze", "review", "verify", "check", "audit", "assess repo"
      Agent: @subagents/reviewer
```

---

### 4. New Specialist Agent Files

**Create 12 new files** in `.opencode/agent/subagents/specialists/`:
1. tactic-specialist.md (CRITICAL)
2. term-mode-specialist.md (CRITICAL)
3. metaprogramming-specialist.md (CRITICAL)
4. lean-search-specialist.md (HIGH)
5. loogle-specialist.md (HIGH)
6. web-research-specialist.md (MEDIUM)
7. complexity-analyzer.md (MEDIUM)
8. dependency-mapper.md (MEDIUM)
9. style-checker.md (MEDIUM)
10. proof-simplifier.md (MEDIUM)
11. doc-analyzer.md (MEDIUM)
12. doc-writer.md (MEDIUM)

**Note**: agent-generator.md and command-generator.md are NOT created as meta tasks are excluded from `/task` routing.

**Template Structure** (for each specialist):
```markdown
---
description: "{Purpose of specialist}"
mode: specialist
temperature: 0.2
tools:
  read: true
  write: true
  # ... other tools
---

# {Specialist Name}

<context>
  <system_context>{System context}</system_context>
  <domain_context>{Domain context}</domain_context>
  <task_context>{Task context}</task_context>
</context>

<role>{Role description}</role>

<task>{Task description}</task>

<workflow_execution>
  <!-- Workflow stages -->
</workflow_execution>

<input_format>
  <!-- Expected input format -->
</input_format>

<output_format>
  <!-- Expected output format -->
</output_format>

<coordination_pattern>
  <!-- How coordinator invokes this specialist -->
</coordination_pattern>

<principles>
  <!-- Guiding principles -->
</principles>
```

---

## Backward Compatibility

### Maintaining Existing `/task` Behavior

**Preserved Functionality**:
1. ✅ Single-task execution: `/task 63`
2. ✅ Batch execution: `/task 63-65` or `/task 63,64,65`
3. ✅ TODO.md status tracking (IN PROGRESS → COMPLETE)
4. ✅ Artifact organization in `.opencode/specs/NNN_task_name/`
5. ✅ Research + planning workflow for complex tasks
6. ✅ Simple task direct execution
7. ✅ Dependency analysis for batch tasks
8. ✅ Wave-based parallel execution

**Enhanced Functionality**:
1. ✨ Automatic task type detection
2. ✨ Intelligent coordinator routing
3. ✨ End-to-end execution (no manual follow-up)
4. ✨ Specialist agent delegation
5. ✨ Improved error handling
6. ✨ Better progress reporting

**Migration Path**:
- **No migration needed** - existing `/task` usage continues to work
- **Gradual adoption** - users can rely on automatic routing
- **Fallback behavior** - if task type detection fails, default to general_code
- **Manual override** - users can still use `/lean`, `/implement`, etc. directly

**Deprecation Strategy**:
- **No deprecation** - `/lean`, `/implement`, `/document`, etc. remain available
- **Recommendation** - suggest using `/task` for TODO.md tasks
- **Direct use cases** - specialized commands still useful for non-TODO.md work
- **Documentation** - update docs to recommend `/task` as primary interface

---

## Success Criteria

### Phase 1 Success Criteria (CRITICAL Specialists)
- ✅ tactic-specialist can implement simple tactic proofs
- ✅ term-mode-specialist can implement simple term-mode proofs
- ✅ metaprogramming-specialist can implement basic custom tactics
- ✅ All 3 specialists integrate with proof-developer
- ✅ lean-lsp-mcp verification works for all specialists
- ✅ Specialists return expected output format

### Phase 2 Success Criteria (Task Type Detection)
- ✅ Task type detection correctly identifies 90%+ of tasks
- ✅ Detection algorithm handles ambiguous cases gracefully
- ✅ All 7 task types have detection logic
- ✅ Priority ordering resolves conflicts correctly
- ✅ Backward compatibility preserved
- ✅ TODO.md status tracking still works

### Phase 3 Success Criteria (Coordinator Integration)
- ✅ All 7 task types route to correct coordinator
- ✅ Coordinators execute and return results
- ✅ TODO.md status updated correctly (IN PROGRESS → COMPLETE)
- ✅ Artifacts created in correct locations
- ✅ Error handling prevents system failures
- ✅ End-to-end execution works for all task types

### Phase 4 Success Criteria (Remaining Specialists)
- ✅ All 9 remaining specialists created (excluding meta specialists)
- ✅ Specialists integrate with respective coordinators
- ✅ Research specialists work with researcher coordinator
- ✅ Planning specialists work with planner coordinator
- ✅ Refactoring specialists work with refactorer coordinator
- ✅ Documentation specialists work with documenter coordinator

### Phase 5 Success Criteria (Testing)
- ✅ 100% of unit tests pass
- ✅ 100% of integration tests pass
- ✅ 100% of end-to-end tests pass
- ✅ 100% of regression tests pass
- ✅ No performance regression (< 5% overhead)
- ✅ All error scenarios handled gracefully

### Overall Success Criteria
- ✅ `/task` can execute LEAN proof tasks end-to-end
- ✅ `/task` can execute documentation tasks end-to-end
- ✅ `/task` can execute refactoring tasks end-to-end
- ✅ `/task` can execute research tasks end-to-end
- ✅ `/task` can execute general code tasks end-to-end
- ✅ All task types (except meta-system) route to appropriate coordinator
- ✅ Meta-system tasks are correctly excluded from `/task` routing
- ✅ TODO.md status tracking works correctly
- ✅ No manual follow-up commands needed
- ✅ Backward compatibility maintained
- ✅ No breaking changes to existing workflows

---

## Testing Strategy

### Unit Tests

**Task Type Detection Tests** (20+ test cases):
```python
# Test LEAN proof detection
test_lean_proof_detection_by_file_path()
test_lean_proof_detection_by_keywords()
test_lean_proof_detection_by_effort()
test_lean_proof_detection_ambiguous()

# Test documentation detection
test_documentation_detection_by_file_path()
test_documentation_detection_by_keywords()
test_documentation_detection_simple()

# Test refactoring detection
test_refactoring_detection_by_keywords()
test_refactoring_detection_by_file_path()

# Test research detection
test_research_detection_by_keywords()
test_research_detection_explicit()

# Test general code detection
test_general_code_detection_fallback()
test_general_code_detection_by_file_path()

# Test batch detection
test_batch_detection_multiple_tasks()

# Test priority ordering
test_priority_ordering_lean_over_general()
test_priority_ordering_meta_over_lean()
test_priority_ordering_batch_highest()

# Test ambiguity resolution
test_ambiguity_resolution_tied_scores()
test_ambiguity_resolution_fallback()
```

**Specialist Agent Tests** (12 specialists × 3 tests = 36 tests):
```python
# For each specialist (excluding meta specialists):
test_{specialist}_input_parsing()
test_{specialist}_execution()
test_{specialist}_output_format()
```

### Integration Tests

**Coordinator Routing Tests** (6 coordinators):
```python
test_route_to_proof_developer()
test_route_to_documenter()
test_route_to_refactorer()
test_route_to_researcher()
test_route_to_implementer()
test_route_to_batch_orchestrator()
test_meta_tasks_not_routed()  # Verify meta tasks excluded
```

**Coordinator Execution Tests** (6 coordinators):
```python
test_proof_developer_execution()
test_documenter_execution()
test_refactorer_execution()
test_researcher_execution()
test_implementer_execution()
test_batch_orchestrator_execution()
```

### End-to-End Tests

**Sample Task Execution** (6 task types):
```python
test_e2e_lean_proof_task()        # Task 9: Begin completeness proofs
test_e2e_documentation_task()     # Task 61: Add missing READMEs
test_e2e_refactoring_task()       # Task 52: Fix AesopRules duplicate
test_e2e_research_task()          # Task 11: Plan Layer extensions
test_e2e_general_code_task()      # General utility creation
test_e2e_batch_tasks()            # Tasks 63-65 batch execution
test_e2e_meta_task_excluded()     # Verify meta tasks not routed
```

**TODO.md Status Tracking** (3 tests):
```python
test_todo_status_in_progress_marking()
test_todo_status_complete_marking()
test_todo_status_failure_handling()
```

### Regression Tests

**Existing Functionality** (10 tests):
```python
test_single_task_workflow_preserved()
test_batch_execution_preserved()
test_todo_status_tracking_preserved()
test_artifact_organization_preserved()
test_research_planning_workflow_preserved()
test_simple_task_execution_preserved()
test_dependency_analysis_preserved()
test_wave_execution_preserved()
test_error_handling_preserved()
test_backward_compatibility_preserved()
```

### Error Handling Tests

**Failure Scenarios** (8 tests):
```python
test_task_type_detection_failure()
test_coordinator_execution_failure()
test_specialist_execution_failure()
test_timeout_handling()
test_partial_completion()
test_todo_update_failure()
test_artifact_creation_failure()
test_invalid_task_number()
```

### Performance Tests

**Benchmarks** (5 tests):
```python
test_task_type_detection_performance()  # < 1 second
test_coordinator_routing_overhead()     # < 2 seconds
test_e2e_execution_time()               # Varies by task
test_batch_execution_performance()      # Parallel speedup
test_no_performance_regression()        # < 5% overhead
```

---

## Implementation Estimates

### Phase 1: Create Missing CRITICAL Specialist Agents
- **tactic-specialist**: 4-5 hours
- **term-mode-specialist**: 4-5 hours
- **metaprogramming-specialist**: 4-6 hours
- **Total**: 12-16 hours

### Phase 2: Enhance Task-Executor with Task Type Detection
- **Detection algorithm**: 3-4 hours
- **Classification system**: 2-3 hours
- **Routing logic**: 2-3 hours
- **Testing**: 1-2 hours
- **Total**: 8-12 hours

### Phase 3: Create Task Router and Coordinator Integration
- **Routing stage**: 3-4 hours
- **Coordinator integration**: 4-5 hours
- **TODO.md status tracking**: 2-3 hours
- **Error handling**: 1-2 hours
- **Total**: 10-14 hours

### Phase 4: Create Remaining Specialist Agents
- **Research specialists** (3): 6-8 hours
- **Planning specialists** (2): 4-5 hours
- **Refactoring specialists** (2): 3-4 hours
- **Documentation specialists** (2): 3-4 hours
- **Total**: 16-21 hours (meta specialists excluded)

### Phase 5: Testing and Validation
- **Unit tests**: 3-4 hours
- **Integration tests**: 2-3 hours
- **End-to-end tests**: 2-3 hours
- **Regression tests**: 1-2 hours
- **Performance tests**: 1 hour
- **Total**: 9-13 hours

### Total Project Estimate
- **Minimum**: 53 hours
- **Maximum**: 75 hours
- **Expected**: 61-66 hours (reduced due to meta specialists exclusion)

### Dependencies Between Phases
```
Phase 1 (CRITICAL Specialists)
    ↓
Phase 2 (Task Type Detection) ← Can start in parallel
    ↓
Phase 3 (Coordinator Integration)
    ↓
Phase 4 (Remaining Specialists) ← Can be done incrementally
    ↓
Phase 5 (Testing) ← Continuous throughout
```

**Critical Path**: Phase 1 → Phase 3 → Phase 5 (minimum 29-41 hours)

**Parallel Work Opportunities**:
- Phase 2 can start while Phase 1 is in progress
- Phase 4 specialists can be created incrementally
- Phase 5 testing can be done continuously

**Recommended Timeline**:
- **Week 1**: Phase 1 (CRITICAL specialists) + Start Phase 2
- **Week 2**: Complete Phase 2 + Phase 3 (coordinator integration)
- **Week 3**: Phase 4 (remaining specialists, prioritize HIGH first)
- **Week 4**: Complete Phase 4 + Phase 5 (comprehensive testing)

---

## Key Design Decisions

### Decision 1: Enhance Task-Executor vs. Create Task-Router

**Decision**: Enhance task-executor directly (no separate task-router agent)

**Rationale**:
- Simpler architecture (one less agent)
- Easier to maintain (all logic in one place)
- Better performance (no extra routing hop)
- Preserves backward compatibility
- Follows existing pattern (task-executor already does routing)

**Alternative Considered**: Create separate task-router agent
- **Pros**: More modular, clearer separation of concerns
- **Cons**: Added complexity, extra routing hop, harder to maintain
- **Verdict**: Not worth the added complexity

---

### Decision 2: Task Type Detection Algorithm

**Decision**: Multi-factor scoring with priority ordering

**Rationale**:
- Handles ambiguous cases gracefully
- Extensible (easy to add new task types)
- Transparent (scores can be logged for debugging)
- Robust (multiple indicators reduce false positives)
- Priority ordering resolves conflicts deterministically

**Alternative Considered**: Simple keyword matching
- **Pros**: Simpler implementation
- **Cons**: Less accurate, brittle, hard to extend
- **Verdict**: Not robust enough for production

---

### Decision 3: Specialist Agent Priority

**Decision**: Create CRITICAL specialists first (tactic, term-mode, metaprogramming)

**Rationale**:
- Blocks all LEAN proof tasks (highest impact)
- Referenced by proof-developer (architectural gap)
- Most complex to implement (need early feedback)
- Enables end-to-end LEAN proof workflow

**Alternative Considered**: Create all specialists at once
- **Pros**: Complete implementation in one phase
- **Cons**: Too much work, delays LEAN proof capability
- **Verdict**: Phased approach is more pragmatic

---

### Decision 4: Backward Compatibility Strategy

**Decision**: Preserve all existing functionality, add new features

**Rationale**:
- No breaking changes for existing users
- Gradual adoption possible
- Fallback behavior if detection fails
- Specialized commands still available for direct use

**Alternative Considered**: Deprecate `/lean`, `/implement`, etc.
- **Pros**: Simpler mental model (one command to rule them all)
- **Cons**: Breaking change, removes flexibility
- **Verdict**: Too disruptive, not worth it

---

### Decision 5: Coordinator Selection Logic

**Decision**: Task-executor selects coordinator based on task type

**Rationale**:
- Centralized decision point
- Easy to debug and modify
- Consistent with existing architecture
- Allows for override if needed

**Alternative Considered**: Orchestrator selects coordinator
- **Pros**: Higher-level decision making
- **Cons**: Orchestrator doesn't have task details
- **Verdict**: Task-executor has better context

---

## Recommended Implementation Order

### Week 1: Foundation (Phase 1 + Start Phase 2)
1. **Day 1-2**: Create tactic-specialist
   - Implement basic tactic proof construction
   - Integrate with lean-lsp-mcp
   - Test with simple proofs
2. **Day 3-4**: Create term-mode-specialist
   - Implement term construction
   - Integrate with lean-lsp-mcp
   - Test with simple terms
3. **Day 5**: Create metaprogramming-specialist
   - Implement basic metaprogramming
   - Test with simple custom tactics
4. **Day 6-7**: Start Phase 2 (task type detection)
   - Design detection algorithm
   - Implement classification system

### Week 2: Core Enhancement (Complete Phase 2 + Phase 3)
1. **Day 8-9**: Complete Phase 2
   - Implement detection algorithm in task-executor
   - Add routing logic
   - Test detection accuracy
2. **Day 10-12**: Phase 3 (coordinator integration)
   - Add RouteToCoordinator stage
   - Integrate with all coordinators
   - Update TODO.md status tracking
3. **Day 13-14**: Testing and refinement
   - Integration tests for coordinators
   - End-to-end tests for LEAN proofs
   - Fix any issues

### Week 3: Expansion (Phase 4 - HIGH Priority)
1. **Day 15-16**: Create research specialists
   - lean-search-specialist
   - loogle-specialist
2. **Day 17-18**: Create web-research-specialist
   - Implement web research
   - Integrate with researcher
3. **Day 19-21**: Create planning specialists
   - complexity-analyzer
   - dependency-mapper
   - Test with planner

### Week 4: Completion (Phase 4 - MEDIUM/LOW + Phase 5)
1. **Day 22-24**: Create remaining specialists
   - Refactoring specialists (style-checker, proof-simplifier)
   - Documentation specialists (doc-analyzer, doc-writer)
   - Meta specialists (agent-generator, command-generator)
2. **Day 25-28**: Phase 5 (comprehensive testing)
   - Unit tests for all components
   - Integration tests for all coordinators
   - End-to-end tests for all task types
   - Regression tests
   - Performance tests
   - Fix all failures

---

## Risk Mitigation

### Risk 1: Specialist Agent Complexity

**Risk**: CRITICAL specialists (tactic, term-mode, metaprogramming) may be too complex to implement correctly

**Mitigation**:
- Start with simple proof cases
- Iterate based on feedback
- Use existing LEAN 4 examples as templates
- Leverage lean-lsp-mcp for verification
- Allow for incremental improvement

**Contingency**: If specialists too complex, fall back to proof-developer doing work directly (current state)

---

### Risk 2: Task Type Detection Accuracy

**Risk**: Detection algorithm may misclassify tasks, routing to wrong coordinator

**Mitigation**:
- Multi-factor scoring reduces false positives
- Priority ordering resolves ambiguity
- Extensive testing with real TODO.md tasks
- Logging for debugging misclassifications
- Fallback to general_code if uncertain

**Contingency**: Users can still use specialized commands directly (`/lean`, `/implement`, etc.)

---

### Risk 3: Performance Regression

**Risk**: Added routing logic may slow down task execution

**Mitigation**:
- Keep detection algorithm simple (< 1 second)
- Minimize coordinator routing overhead (< 2 seconds)
- Parallel execution for batch tasks
- Performance benchmarks in testing

**Contingency**: Optimize detection algorithm if performance issues arise

---

### Risk 4: Breaking Changes

**Risk**: Enhancements may break existing workflows

**Mitigation**:
- Preserve all existing functionality
- Comprehensive regression testing
- Backward compatibility as design principle
- Gradual rollout with testing

**Contingency**: Rollback to previous version if breaking changes discovered

---

### Risk 5: Incomplete Specialist Coverage

**Risk**: Not all specialists may be implemented in time

**Mitigation**:
- Phased approach (CRITICAL first)
- Coordinators can work without specialists (degraded mode)
- Incremental specialist addition
- Clear priority ordering

**Contingency**: Ship with CRITICAL specialists only, add others incrementally

---

## Success Metrics

### Quantitative Metrics
- **Task Type Detection Accuracy**: > 90%
- **Coordinator Routing Success**: > 95%
- **End-to-End Execution Success**: > 90%
- **Performance Overhead**: < 5%
- **Test Coverage**: > 90%
- **Regression Test Pass Rate**: 100%

### Qualitative Metrics
- **User Experience**: No manual follow-up commands needed
- **Error Messages**: Clear and actionable
- **Documentation**: Complete and accurate
- **Code Quality**: Follows established patterns
- **Maintainability**: Easy to extend and modify

### Adoption Metrics
- **Usage of `/task`**: Increase over time
- **Usage of specialized commands**: Decrease over time (for TODO.md tasks)
- **User feedback**: Positive sentiment
- **Bug reports**: Low volume

---

## Conclusion

This implementation plan provides a comprehensive roadmap for enhancing the `/task` command with intelligent agent routing. The phased approach prioritizes critical functionality (LEAN proof specialists) while maintaining backward compatibility and allowing for incremental delivery.

**Key Highlights**:
1. **Addresses critical gap**: Creates 12 missing specialist agents (excluding meta specialists)
2. **Intelligent routing**: Automatic task type detection and coordinator selection
3. **End-to-end execution**: No manual follow-up commands needed (except meta tasks)
4. **Backward compatible**: Preserves all existing functionality
5. **Phased delivery**: CRITICAL specialists first, others incrementally
6. **Comprehensive testing**: Unit, integration, end-to-end, regression tests
7. **Clear success criteria**: Measurable goals for each phase
8. **Meta tasks excluded**: Meta-system tasks (agent/command creation) use `/meta` directly

**Expected Outcome**: A fully functional `/task` command that automatically routes to the right coordinator based on task type, enabling end-to-end task execution without manual intervention (except for meta-system tasks which continue to use `/meta` command).

**Total Effort**: 61-66 hours over 4 weeks

**Next Steps**: Begin Phase 1 implementation (CRITICAL specialists)
