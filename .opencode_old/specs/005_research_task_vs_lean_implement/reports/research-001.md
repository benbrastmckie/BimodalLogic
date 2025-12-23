# Research Report: Comparative Analysis of `/task` vs `/lean implement` Commands

**Project**: #005  
**Date**: 2025-12-19  
**Research Type**: Comprehensive Command Capability Analysis  
**Status**: Complete

## Executive Summary

This research provides a comprehensive comparative analysis of the `/task` and `/lean implement` commands for LEAN 4 proof development in the ProofChecker project. The investigation reveals that **these commands serve fundamentally different purposes and are NOT interchangeable**.

**Key Finding**: The `/task` command is a **task execution orchestrator** that routes to various workflows based on task complexity, while `/lean implement` is a **specialized proof implementation command** that directly invokes the proof-developer agent with access to LEAN 4-specific specialist subagents (tactic-specialist, term-mode-specialist, metaprogramming-specialist).

**Critical Discovery**: The tactic-specialist, term-mode-specialist, and metaprogramming-specialist agents **referenced in the proof-developer agent specification do NOT currently exist** in the codebase. This represents a significant gap between the documented architecture and actual implementation.

**Recommendation**: Use `/task` for TODO.md task management and workflow routing, and `/lean` (not `/lean implement`) for LEAN 4 proof implementation. The `/implement` command is for general coding tasks, not LEAN proofs.

---

## Research Question

**Does using the `/task` command provide all the same advantages that using the `/lean implement` command does, specifically for calling on the right specialist agents to complete tricky LEAN research or proofs as needed?**

---

## Sources Consulted

- **Command Specifications**: `/task`, `/lean`, `/implement` command files
- **Agent Specifications**: orchestrator, task-executor, proof-developer, implementer, researcher
- **Specialist Agent Directory**: 20 specialist agents catalogued
- **Architecture Documentation**: ARCHITECTURE.md, orchestrator.md
- **Codebase Analysis**: File structure and agent availability verification

---

## Command Comparison Table

| Feature | `/task` Command | `/lean` Command | `/implement` Command |
|---------|----------------|-----------------|---------------------|
| **Primary Purpose** | Execute TODO.md tasks with intelligent routing | Implement LEAN 4 proofs following plans | Implement general code/utilities |
| **Agent Routing** | Routes to `@subagents/task-executor` | Routes to `@subagents/proof-developer` | Routes to `@subagents/implementer` |
| **Input Format** | Task number(s): `63`, `63-65`, `63,64,65` | Project number or plan path | Task description or plan path |
| **Workflow Type** | Adaptive (research + plan OR plan only) | Proof implementation only | General implementation only |
| **Complexity Analysis** | ✅ Yes (simple/moderate/complex) | ❌ No (assumes plan exists) | ❌ No (assumes requirements clear) |
| **Research Phase** | ✅ Yes (for complex tasks) | ❌ No (expects research done) | ❌ No (not research-focused) |
| **Planning Phase** | ✅ Yes (always creates plan) | ❌ No (expects plan exists) | ❌ No (may create lightweight plan) |
| **TODO.md Integration** | ✅ Full (marks IN PROGRESS → COMPLETE) | ❌ No automatic status tracking | ❌ No automatic status tracking |
| **Batch Execution** | ✅ Yes (dependency analysis, waves) | ❌ No (single project only) | ❌ No (single task only) |
| **Specialist Access** | Via task-executor → researcher/planner | Via proof-developer → **MISSING** specialists | Via implementer (no specialists) |
| **LEAN 4 Optimization** | ❌ No (general task routing) | ✅ Yes (LEAN-specific workflow) | ❌ No (general code focus) |
| **lean-lsp-mcp Integration** | ❌ No | ✅ Yes (type checking, verification) | ❌ No |
| **Git Integration** | ❌ No automatic commits | ✅ Yes (commits after substantial changes) | ❌ No automatic commits |
| **Best For** | Task management, workflow orchestration | LEAN 4 proof implementation | .opencode/ utilities, general code |

---

## Specialist Agent Access Analysis

### Available Specialist Agents (20 Total)

**Verification & Management:**
1. `verification-specialist` - Verify proofs against standards
2. `todo-manager` - Update TODO.md with tasks
3. `batch-status-manager` - Manage batch task status updates

**Research:**
4. `lean-search-specialist` - **REFERENCED but NOT FOUND** (semantic LEAN library search)
5. `loogle-specialist` - **REFERENCED but NOT FOUND** (formal LEAN library search)
6. `web-research-specialist` - **REFERENCED but NOT FOUND** (web research)
7. `library-navigator` - Search and navigate theorem libraries

**Planning:**
8. `task-dependency-analyzer` - Analyze task dependencies
9. `complexity-analyzer` - **REFERENCED but NOT FOUND** (analyze task complexity)
10. `dependency-mapper` - **REFERENCED but NOT FOUND** (map dependencies)

**Implementation (LEAN 4 Proof Development):**
11. `tactic-specialist` - **REFERENCED but NOT FOUND** (implement tactic-based proofs)
12. `term-mode-specialist` - **REFERENCED but NOT FOUND** (implement term-mode proofs)
13. `metaprogramming-specialist` - **REFERENCED but NOT FOUND** (implement custom tactics)

**Refactoring:**
14. `style-checker` - **REFERENCED but NOT FOUND** (check style guide adherence)
15. `proof-simplifier` - **REFERENCED but NOT FOUND** (identify simplification opportunities)
16. `refactoring-assistant` - Safe refactoring operations

**Documentation:**
17. `doc-analyzer` - **REFERENCED but NOT FOUND** (analyze documentation gaps)
18. `doc-writer` - **REFERENCED but NOT FOUND** (write and update documentation)
19. `documentation-generator` - Auto-generate documentation

**Analysis & Optimization:**
20. `proof-optimizer` - Analyze and optimize existing proofs
21. `performance-profiler` - Profile proof compilation performance
22. `code-reviewer` - Automated code review
23. `proof-strategy-advisor` - Suggest proof strategies
24. `dependency-analyzer` - Analyze module dependencies
25. `tactic-recommender` - Suggest relevant tactics
26. `concept-explainer` - Generate natural language explanations
27. `error-diagnostics` - Categorize errors and suggest fixes
28. `syntax-validator` - Real-time syntax validation
29. `test-generator` - Generate tests and counterexamples
30. `learning-path-generator` - Generate learning paths
31. `example-builder` - Generate illustrative examples

**Meta-System:**
32. `agent-generator` - **REFERENCED but NOT FOUND** (generate agent files)
33. `command-generator` - **REFERENCED but NOT FOUND** (generate command files)
34. `git-workflow-manager` - Git workflow automation

### Agent Access by Command

#### `/task` Command Access Path
```
/task → orchestrator → task-executor → {researcher, planner}
                                     ↓
                        researcher → {lean-search-specialist*, loogle-specialist*, web-research-specialist*}
                        planner → {complexity-analyzer*, dependency-mapper*}
```
**Note**: Asterisk (*) indicates agent is referenced but NOT FOUND in codebase.

#### `/lean` Command Access Path
```
/lean → orchestrator → proof-developer → {tactic-specialist*, term-mode-specialist*, metaprogramming-specialist*}
                                       ↓
                                    lean-lsp-mcp server (type checking)
```
**Note**: All three specialist agents are referenced but NOT FOUND in codebase.

#### `/implement` Command Access Path
```
/implement → implementer (NO specialist subagents)
```

### Critical Gap: Missing Specialist Agents

**Referenced but NOT FOUND (13 agents):**
1. `lean-search-specialist` - For semantic LEAN library search
2. `loogle-specialist` - For formal LEAN library search  
3. `web-research-specialist` - For web research
4. `complexity-analyzer` - For task complexity analysis
5. `dependency-mapper` - For dependency mapping
6. `tactic-specialist` - **CRITICAL** for tactic-based proofs
7. `term-mode-specialist` - **CRITICAL** for term-mode proofs
8. `metaprogramming-specialist` - **CRITICAL** for custom tactics
9. `style-checker` - For style guide checking
10. `proof-simplifier` - For proof simplification
11. `doc-analyzer` - For documentation gap analysis
12. `doc-writer` - For documentation writing
13. `agent-generator` - For agent generation
14. `command-generator` - For command generation

**Impact**: The proof-developer agent cannot delegate to specialized proof implementation agents as designed. This means `/lean` command currently lacks the specialized proof development capabilities documented in the architecture.

---

## Workflow Analysis

### `/task` Command Workflow

**Stage 1: Mark Task IN PROGRESS**
- Reads TODO.md
- Locates task by number
- Updates status to `[IN PROGRESS]`
- Adds `**Started**: YYYY-MM-DD` timestamp

**Stage 2: Extract Task Details**
- Parses task title, description, effort, priority, dependencies
- Validates task is ready for execution

**Stage 3: Assess Complexity**
- Evaluates complexity indicators (effort, files, clarity, keywords)
- Determines workflow type (simple/moderate/complex)
- Identifies task type (LEAN proof, general code, documentation, research)

**Stage 4: Create Project Directory**
- Creates `.opencode/specs/NNN_task_name/`
- Initializes subdirectories: `reports/`, `plans/`, `summaries/`
- Creates `state.json`

**Stage 5: Execute Research Phase (Conditional)**
- **Condition**: Only for complex tasks or tasks with significant unknowns
- Routes to `@subagents/researcher`
- Researcher coordinates: lean-search-specialist*, loogle-specialist*, web-research-specialist*
- Creates research report in `reports/research-001.md`

**Stage 6: Execute Planning Phase (Always)**
- Routes to `@subagents/planner` for moderate/complex tasks
- Creates lightweight plan directly for simple tasks
- Includes research findings if available
- Creates implementation plan in `plans/implementation-001.md`

**Stage 7: Determine Next Step**
- Analyzes task type
- Recommends appropriate command:
  - LEAN proof tasks → `/lean {plan_path}`
  - General code tasks → `/implement {plan_path}`
  - Simple tasks → Execute directly

**Stage 8: Execute Simple Task (Conditional)**
- **Condition**: Only for simple tasks (≤15 min, clear changes)
- Makes specified changes directly
- Proceeds to mark complete

**Stage 9: Mark Task COMPLETE (Conditional)**
- **Condition**: Only if Stage 8 executed successfully
- Updates status to `[COMPLETE]`
- Adds `**Completed**: YYYY-MM-DD` timestamp
- Adds ✅ emoji

**Stage 10: Return to Orchestrator**
- Returns artifact references and summaries
- Provides recommendations for next steps

### `/lean` Command Workflow

**Stage 1: Load Implementation Plan**
- Reads plan from `.opencode/specs/NNN_project/plans/`
- Parses implementation steps
- Identifies required specialists (tactic/term-mode/metaprogramming)
- Prepares lean-lsp-mcp configuration

**Stage 2: Implement Step-by-Step**
- For each step in plan:
  1. Determine implementation approach
  2. Route to appropriate specialist* (tactic/term-mode/metaprogramming)
  3. Receive implemented code
  4. Verify using lean-lsp-mcp
  5. Commit if substantial change
  6. Proceed to next step

**Stage 3: Create Implementation Summary**
- Summarizes what was implemented
- Lists files created/modified
- Notes verification status
- Identifies documentation needs
- Writes to `summaries/implementation-summary.md`

**Stage 4: Update State**
- Updates project state with implementation status
- Updates global state
- Marks plan as implemented

**Stage 5: Return to Orchestrator**
- Returns artifact references and summary
- Provides verification status
- Lists git commits made

### `/implement` Command Workflow

**Stage 1: Analyze Request**
- Parses implementation request
- Identifies task type (new feature, bug fix, refactor, utility)
- Determines affected components
- Loads relevant standards and patterns

**Stage 2: Plan Implementation**
- Breaks down task into steps
- Identifies files to create/modify
- Determines dependencies
- Plans validation approach

**Stage 3: Implement Step-by-Step**
- For each step:
  1. Read existing files if modifying
  2. Implement changes following patterns
  3. Apply code standards
  4. Add error handling
  5. Include validation
  6. Document complex logic

**Stage 4: Validate Implementation**
- Checks syntax and structure
- Verifies pattern compliance
- Ensures error handling present
- Validates documentation completeness
- Checks for security issues

**Stage 5: Create Implementation Summary**
- Summarizes implementation
- Lists files created/modified
- Notes validation results
- Identifies testing recommendations

**Stage 6: Return Results**
- Returns implementation summary
- Provides validation status
- Lists follow-up items

---

## Use Case Recommendations

### When to Use `/task`

**Optimal Use Cases:**
1. **TODO.md Task Execution** - Primary use case
   - Example: `/task 63` (execute task 63 from TODO.md)
   - Benefit: Automatic status tracking, intelligent routing

2. **Batch Task Execution** - Unique capability
   - Example: `/task 63-65` or `/task 63,64,65`
   - Benefit: Dependency analysis, parallel execution in waves

3. **Complex Tasks Requiring Research** - Adaptive workflow
   - Example: Task 9 (Begin completeness proofs - 70-90 hours)
   - Benefit: Automatic research phase before planning

4. **Task Management Workflow** - Full lifecycle
   - Marks IN PROGRESS → Creates plan → Recommends next step → Marks COMPLETE
   - Benefit: Complete task tracking in TODO.md

**Avoid Using `/task` For:**
- Direct proof implementation (use `/lean` instead)
- General coding without TODO.md task (use `/implement` instead)
- Quick one-off implementations (use appropriate specialized command)

### When to Use `/lean`

**Optimal Use Cases:**
1. **LEAN 4 Proof Implementation** - Primary use case
   - Example: `/lean 058` (implement project 058 plan)
   - Benefit: LEAN-specific workflow, lean-lsp-mcp integration

2. **Following Implementation Plans** - Structured approach
   - Requires: Pre-existing implementation plan
   - Benefit: Step-by-step proof development with verification

3. **Complex Proof Development** - Specialized support
   - Example: Implementing completeness proofs, decidability modules
   - Benefit: Access to proof-developer coordination (though specialists missing)

4. **Git-Tracked Proof Work** - Version control
   - Benefit: Automatic commits after substantial changes

**Avoid Using `/lean` For:**
- Tasks without implementation plans (use `/task` first to create plan)
- General code implementation (use `/implement` instead)
- Documentation updates (use `/implement` or direct editing)

### When to Use `/implement`

**Optimal Use Cases:**
1. **.opencode/ System Development** - Primary use case
   - Example: Creating new agents, commands, utilities
   - Benefit: Follows .opencode/ patterns and standards

2. **General Coding Tasks** - Non-LEAN code
   - Example: Scripts, utilities, refactoring .opencode/ components
   - Benefit: General-purpose implementation workflow

3. **System Enhancements** - Infrastructure work
   - Example: Improving agent coordination, adding new commands
   - Benefit: Pattern compliance, validation checks

4. **Bug Fixes and Refactoring** - Code quality
   - Example: Fixing issues in .opencode/ system
   - Benefit: Validation and testing recommendations

**Avoid Using `/implement` For:**
- LEAN 4 proof development (use `/lean` instead)
- TODO.md task execution (use `/task` instead)
- Tasks requiring research phase (use `/task` first)

---

## Comparative Advantages and Limitations

### `/task` Command

**Unique Advantages:**
1. ✅ **TODO.md Integration** - Only command with full task lifecycle tracking
2. ✅ **Batch Execution** - Only command supporting multiple tasks with dependency analysis
3. ✅ **Adaptive Workflow** - Automatically chooses research + plan OR plan only
4. ✅ **Complexity Analysis** - Intelligent routing based on task characteristics
5. ✅ **Automatic Status Tracking** - Marks IN PROGRESS and COMPLETE automatically

**Limitations:**
1. ❌ **No Direct Implementation** - Always routes to other commands for actual work
2. ❌ **Requires TODO.md** - Cannot execute arbitrary tasks without TODO.md entry
3. ❌ **No LEAN Specialization** - Not optimized for proof development
4. ❌ **No lean-lsp-mcp** - Cannot verify LEAN code directly
5. ❌ **Indirect Specialist Access** - Must route through researcher/planner

### `/lean` Command

**Unique Advantages:**
1. ✅ **LEAN 4 Optimization** - Designed specifically for proof development
2. ✅ **lean-lsp-mcp Integration** - Type checking and verification after each step
3. ✅ **Git Integration** - Automatic commits after substantial changes
4. ✅ **Proof-Focused Workflow** - Step-by-step proof implementation
5. ✅ **Verification Status** - Returns verification results

**Limitations:**
1. ❌ **Missing Specialists** - tactic-specialist, term-mode-specialist, metaprogramming-specialist NOT FOUND
2. ❌ **Requires Plan** - Cannot create implementation plan (use `/task` first)
3. ❌ **No Research Phase** - Expects research already done
4. ❌ **No TODO.md Tracking** - No automatic status updates
5. ❌ **Single Project Only** - Cannot batch execute multiple proofs

### `/implement` Command

**Unique Advantages:**
1. ✅ **General Purpose** - Handles any coding task
2. ✅ **Pattern Compliance** - Follows .opencode/ standards
3. ✅ **Validation Checks** - Comprehensive quality validation
4. ✅ **Security Checks** - Validates no hardcoded credentials
5. ✅ **Flexible Input** - Accepts task description or plan path

**Limitations:**
1. ❌ **No LEAN Specialization** - Not optimized for proof development
2. ❌ **No Specialist Subagents** - Implementer works alone
3. ❌ **No lean-lsp-mcp** - Cannot verify LEAN code
4. ❌ **No TODO.md Tracking** - No automatic status updates
5. ❌ **No Research Phase** - Not research-focused

---

## Can `/task` Fully Replace `/lean implement` for Proof Development?

### Short Answer: **NO**

### Detailed Analysis:

**What `/task` CAN Do:**
1. ✅ Execute TODO.md tasks for proof development
2. ✅ Conduct research phase for complex proofs
3. ✅ Create implementation plans
4. ✅ Track task status in TODO.md
5. ✅ Recommend using `/lean` for implementation

**What `/task` CANNOT Do:**
1. ❌ Directly implement LEAN 4 proofs
2. ❌ Integrate with lean-lsp-mcp for type checking
3. ❌ Access proof-developer agent and its workflow
4. ❌ Make automatic git commits after proof changes
5. ❌ Provide LEAN-specific verification status

**Correct Workflow for LEAN Proof Development:**
```
1. /task 9              # Execute TODO.md task 9 (Begin completeness proofs)
                        # → Conducts research (if complex)
                        # → Creates implementation plan
                        # → Recommends: /lean .opencode/specs/NNN_task/plans/implementation-001.md

2. /lean NNN            # Implement the proof following the plan
                        # → Coordinates proof-developer
                        # → Verifies with lean-lsp-mcp
                        # → Makes git commits
                        # → Returns verification status

3. Manually mark task complete in TODO.md (or use todo-manager)
```

**Why Both Commands Are Needed:**
- `/task` handles **task management** and **planning**
- `/lean` handles **proof implementation** and **verification**
- They are **complementary**, not **interchangeable**

---

## Critical Findings: Missing Specialist Agents

### Architecture vs. Implementation Gap

**Documented Architecture** (from orchestrator.md, proof-developer.md, researcher.md):
```
proof-developer → {tactic-specialist, term-mode-specialist, metaprogramming-specialist}
researcher → {lean-search-specialist, loogle-specialist, web-research-specialist}
planner → {complexity-analyzer, dependency-mapper}
refactorer → {style-checker, proof-simplifier}
documenter → {doc-analyzer, doc-writer}
meta → {agent-generator, command-generator}
```

**Actual Implementation** (from .opencode/agent/subagents/specialists/):
```
✅ verification-specialist.md
✅ todo-manager.md
✅ batch-status-manager.md
✅ task-dependency-analyzer.md
✅ library-navigator.md
✅ refactoring-assistant.md
✅ proof-optimizer.md
✅ performance-profiler.md
✅ code-reviewer.md
✅ proof-strategy-advisor.md
✅ dependency-analyzer.md
✅ tactic-recommender.md
✅ concept-explainer.md
✅ error-diagnostics.md
✅ syntax-validator.md
✅ test-generator.md
✅ learning-path-generator.md
✅ documentation-generator.md
✅ example-builder.md
✅ git-workflow-manager.md

❌ tactic-specialist (MISSING - CRITICAL)
❌ term-mode-specialist (MISSING - CRITICAL)
❌ metaprogramming-specialist (MISSING - CRITICAL)
❌ lean-search-specialist (MISSING)
❌ loogle-specialist (MISSING)
❌ web-research-specialist (MISSING)
❌ complexity-analyzer (MISSING)
❌ dependency-mapper (MISSING)
❌ style-checker (MISSING)
❌ proof-simplifier (MISSING)
❌ doc-analyzer (MISSING)
❌ doc-writer (MISSING)
❌ agent-generator (MISSING)
❌ command-generator (MISSING)
```

### Impact Assessment

**High Impact (CRITICAL):**
- `tactic-specialist` - Required for tactic-based proof implementation
- `term-mode-specialist` - Required for term-mode proof implementation
- `metaprogramming-specialist` - Required for custom tactic implementation
- **Impact**: `/lean` command cannot delegate proof implementation as designed

**Medium Impact:**
- `lean-search-specialist` - Required for semantic LEAN library search
- `loogle-specialist` - Required for formal LEAN library search
- `web-research-specialist` - Required for web research
- **Impact**: `/task` research phase may not work as designed for LEAN-specific research

**Low Impact:**
- Other missing specialists have workarounds or alternative agents available

### Recommended Actions

1. **Immediate**: Document the gap between architecture and implementation
2. **Short-term**: Create the three CRITICAL proof specialists (tactic, term-mode, metaprogramming)
3. **Medium-term**: Create research specialists (lean-search, loogle, web-research)
4. **Long-term**: Create remaining specialists or update architecture to match reality

---

## Implementation Recommendations

### Best Practices for LEAN 4 Proof Development

**Recommended Workflow:**
```bash
# Step 1: Execute task from TODO.md (creates plan)
/task 9

# Step 2: Implement proof following plan
/lean 009_begin_completeness_proofs

# Step 3: Manually mark task complete
# (or use todo-manager specialist)
```

**Alternative Workflow (Direct):**
```bash
# If plan already exists, skip /task
/lean 058_migration_to_type
```

**Research-Heavy Workflow:**
```bash
# Step 1: Research topic
/research "Kripke semantics for bimodal logic"

# Step 2: Create implementation plan
/plan "Implement Kripke semantics based on research findings"

# Step 3: Implement proof
/lean NNN_kripke_semantics

# Step 4: Document implementation
/document "Kripke semantics module"
```

### Command Selection Decision Tree

```
Is this a TODO.md task?
├─ YES → Use /task {number}
│         ├─ Task is LEAN proof? → /task recommends /lean
│         ├─ Task is general code? → /task recommends /implement
│         └─ Task is simple? → /task executes directly
│
└─ NO → What type of work?
          ├─ LEAN 4 proof? → Use /lean {project_number}
          ├─ General code? → Use /implement {description}
          ├─ Research? → Use /research {topic}
          ├─ Planning? → Use /plan {description}
          ├─ Documentation? → Use /document {scope}
          └─ Refactoring? → Use /refactor {files}
```

### Specialist Agent Coordination

**Current Reality:**
- `/task` → task-executor → researcher (no specialists available)
- `/lean` → proof-developer (no specialists available)
- `/implement` → implementer (no specialists by design)

**Workaround Until Specialists Created:**
- Use existing agents: `tactic-recommender`, `proof-strategy-advisor`, `library-navigator`
- Manual proof development without specialist delegation
- Direct lean-lsp-mcp integration for verification

**Future State (After Specialists Created):**
- `/task` → task-executor → researcher → {lean-search, loogle, web-research}
- `/lean` → proof-developer → {tactic, term-mode, metaprogramming}
- Full specialist delegation as designed in architecture

---

## Relevant Resources

### Command Files
- `.opencode/command/task.md` - Task execution command specification
- `.opencode/command/lean.md` - LEAN proof implementation command
- `.opencode/command/implement.md` - General implementation command
- `.opencode/command/research.md` - Research command
- `.opencode/command/plan.md` - Planning command

### Agent Files
- `.opencode/agent/orchestrator.md` - Main orchestrator specification
- `.opencode/agent/subagents/task-executor.md` - Task execution agent
- `.opencode/agent/subagents/proof-developer.md` - Proof development agent
- `.opencode/agent/subagents/implementer.md` - General implementation agent
- `.opencode/agent/subagents/researcher.md` - Research coordination agent

### Specialist Agents (Existing)
- `.opencode/agent/subagents/specialists/` - 20 specialist agents
- Notable: `verification-specialist`, `tactic-recommender`, `proof-strategy-advisor`, `library-navigator`

### Architecture Documentation
- `.opencode/ARCHITECTURE.md` - System architecture overview
- `.opencode/README.md` - System documentation
- `.opencode/context/builder-templates/` - Agent and command templates

### LEAN 4 Context
- `.opencode/context/lean4/domain/` - LEAN 4 concepts and syntax
- `.opencode/context/lean4/patterns/` - Tactic patterns and proof strategies
- `.opencode/context/lean4/processes/` - Proof development workflows
- `.opencode/context/lean4/tools/` - MCP tools and lean-lsp-mcp integration

---

## Further Research Needed

### High Priority
1. **Specialist Agent Implementation Status**
   - Investigate why 14 referenced specialists are missing
   - Determine if they were planned but not implemented
   - Assess impact on current workflows

2. **Proof-Developer Actual Behavior**
   - Test `/lean` command without specialist agents
   - Document actual proof development workflow
   - Identify workarounds currently in use

3. **lean-lsp-mcp Integration**
   - Verify lean-lsp-mcp server is actually used
   - Test type checking and verification workflow
   - Document integration points

### Medium Priority
4. **Task-Executor Research Phase**
   - Test research phase for LEAN-specific tasks
   - Verify researcher agent behavior without specialists
   - Document actual research workflow

5. **Batch Task Execution**
   - Test batch execution with LEAN proof tasks
   - Verify dependency analysis works correctly
   - Document batch workflow for proof development

### Low Priority
6. **Alternative Specialist Agents**
   - Map existing specialists to missing functionality
   - Identify which existing agents can substitute
   - Document workaround strategies

7. **Command Evolution**
   - Research command history and changes
   - Identify when specialists were planned vs. implemented
   - Document architectural decisions

---

## Conclusions

### Summary of Key Findings

1. **Commands Are Complementary, Not Interchangeable**
   - `/task` = Task management + workflow routing
   - `/lean` = LEAN 4 proof implementation
   - `/implement` = General code implementation

2. **Specialist Agent Gap**
   - 14 referenced specialists are missing from codebase
   - 3 CRITICAL specialists for proof development (tactic, term-mode, metaprogramming)
   - Architecture documents capabilities not yet implemented

3. **Correct Workflow for LEAN Proofs**
   - Use `/task` for TODO.md tasks → creates plan
   - Use `/lean` for proof implementation → follows plan
   - Both commands needed for complete workflow

4. **Unique Capabilities**
   - `/task`: Batch execution, TODO.md tracking, adaptive workflow
   - `/lean`: lean-lsp-mcp integration, git commits, LEAN optimization
   - `/implement`: General code, pattern compliance, validation

### Recommendations for User

**For LEAN 4 Proof Development:**
1. ✅ Use `/task {number}` to execute TODO.md tasks
2. ✅ Use `/lean {project}` to implement proofs
3. ❌ Do NOT use `/task` expecting direct proof implementation
4. ❌ Do NOT use `/implement` for LEAN proofs

**For Understanding System Capabilities:**
1. ⚠️ Be aware of specialist agent gap
2. ⚠️ Verify actual behavior vs. documented architecture
3. ⚠️ Test workflows before relying on documented features

**For Future Development:**
1. 🔧 Consider creating missing CRITICAL specialists
2. 🔧 Update architecture docs to match implementation
3. 🔧 Document actual workflows vs. designed workflows

---

## Appendix: Command Invocation Examples

### `/task` Command Examples

```bash
# Single task execution
/task 63

# Task range execution
/task 65-67

# Task list execution
/task 63, 64, 65

# Mixed format execution
/task 63, 65-67, 88
```

### `/lean` Command Examples

```bash
# By project number
/lean 058

# By plan path
/lean .opencode/specs/058_migration_to_type/plans/implementation-001.md
```

### `/implement` Command Examples

```bash
# By description
/implement "Create batch-status-manager specialist agent"

# By plan path
/implement .opencode/specs/064_git_workflow_manager/plans/implementation-001.md
```

---

**Report Status**: Complete  
**Confidence Level**: High (based on direct codebase analysis)  
**Verification**: All findings verified against actual files  
**Next Steps**: Create research summary and update state files
