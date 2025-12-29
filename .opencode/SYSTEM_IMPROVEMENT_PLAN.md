# ProofChecker .opencode System Improvement Plan

**Created**: 2025-12-29  
**Status**: Ready for Review  
**Scope**: Comprehensive system optimization and standardization  
**Estimated Effort**: 12-16 hours across 7 phases

---

## Executive Summary

This plan systematically improves the ProofChecker/.opencode/ agent system by:
1. **Standardizing XML structure** across all commands and orchestrator
2. **Removing backup files** in favor of git-based safety
3. **Optimizing context loading** for consistency and performance
4. **Refactoring architecture** to move workflows to subagents
5. **Enhancing quality** through testing, error handling, and documentation

**Key Principle**: Maintain all current features while optimizing organization, consistency, performance, and integrity.

---

## Current State Analysis

### ✅ Strengths
- Well-structured command system with clear routing
- Comprehensive workflow documentation
- Good separation of concerns (orchestrator → commands → subagents)
- Atomic state management via status-sync-manager
- Lazy directory creation pattern

### ⚠️ Issues Identified

#### 1. XML Structure Inconsistency
**Commands WITH XML** (3/10):
- ✅ `review.md` - Full XML structure
- ✅ `todo.md` - Full XML structure  
- ✅ `errors.md` - Full XML structure

**Commands WITHOUT XML** (7/10):
- ❌ `implement.md` - Markdown sections only
- ❌ `plan.md` - Markdown sections only
- ❌ `research.md` - Markdown sections only
- ❌ `revise.md` - Markdown sections only
- ❌ `task.md` - Partial XML (has some tags)
- ❌ `meta.md` - Unknown (needs review)
- ❌ `research-routing.md` - Unknown (needs review)

**Orchestrator**:
- ❌ `orchestrator.md` - No XML structure (67 lines, minimal)

**Impact**: Inconsistent prompt engineering reduces LLM performance and maintainability.

#### 2. Backup File Creation
**Current behavior**:
- `todo.md` Stage 5: Creates `.bak` files for TODO.md, state.json, archive/state.json
- Likely other commands create backups too

**User requirement**: "Never create backups, rely on git"

**Impact**: Unnecessary file clutter, inconsistent with git-first philosophy.

#### 3. Context Loading Variations
**Pattern A** - Explicit with @ symbols (review.md, todo.md, errors.md):
```markdown
Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/status-markers.md
```

**Pattern B** - Frontmatter (subagents):
```yaml
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "common/standards/subagent-return-format.md"
```

**Pattern C** - No explicit loading (implement.md, plan.md, research.md)

**Impact**: Unclear what context is loaded, harder to optimize, inconsistent behavior.

#### 4. Frontmatter Schema Variations
**Commands** have 2 different styles:
- Simple (implement, plan, research): name, agent, description, context_level, language, routing
- Complex (review, todo, errors): name, agent, description, context_level, language

**Subagents** have rich frontmatter:
- name, version, description, mode, agent_type, temperature, max_tokens, timeout
- tools, permissions, context_loading, delegation, lifecycle

**Impact**: Harder to parse, inconsistent metadata, unclear standards.

#### 5. Documentation Verbosity
**Long files**:
- `review.md`: 748 lines (excessive for command file)
- `implement.md`: 373 lines (too detailed for routing layer)
- `plan.md`: 269 lines
- `research.md`: 272 lines

**Issue**: Detailed workflows belong in subagent files, not command files.

**Impact**: Harder to maintain, slower to parse, violates separation of concerns.

#### 6. Orchestrator Simplicity
**Current**: 67 lines, minimal structure, no XML
**Comparison**: OpenAgents orchestrator is even simpler (15 lines) but uses clear role/workflow structure

**Impact**: Lacks consistency with rest of system, misses opportunity for XML optimization.

---

## Improvement Strategy

### Design Principles
1. **XML-First**: All agents use XML structure for optimal LLM performance
2. **Git-First**: No backup files, use git commits before risky operations
3. **Context Efficiency**: Frontmatter-based context loading with lazy evaluation
4. **Separation of Concerns**: Commands route, subagents execute workflows
5. **Standards-Driven**: Document patterns in context files, reference from code
6. **Test-Driven**: Create tests for all critical workflows
7. **Performance-Optimized**: Minimize context loading, maximize reuse

### Architecture Vision

```
.opencode/
├── agent/
│   ├── orchestrator.md              # Enhanced with XML structure
│   └── subagents/
│       ├── implementer.md           # Owns implementation workflow
│       ├── planner.md               # Owns planning workflow
│       ├── researcher.md            # Owns research workflow
│       └── ...
├── command/
│   ├── implement.md                 # Lightweight routing with XML
│   ├── plan.md                      # Lightweight routing with XML
│   ├── research.md                  # Lightweight routing with XML
│   └── ...
├── context/
│   ├── core/
│   │   └── standards/
│   │       ├── command-structure.md      # NEW: Command file standards
│   │       ├── subagent-structure.md     # NEW: Subagent file standards
│   │       └── xml-patterns.md           # NEW: XML structure guide
│   └── project/
│       └── processes/
│           ├── implementation-workflow.md # NEW: Detailed workflow docs
│           ├── planning-workflow.md       # NEW
│           └── research-workflow.md       # NEW
└── tests/
    ├── commands/                    # NEW: Command tests
    └── subagents/                   # NEW: Subagent tests
```

---

## Implementation Phases

### Phase 1: Foundation & Standards (2-3 hours)

**Objective**: Create standards and context files to guide all subsequent work.

**Tasks**:

1. **Create XML Pattern Guide** (30 min)
   - File: `.opencode/context/core/standards/xml-patterns.md`
   - Content:
     - Optimal XML component ordering (context → role → task → workflow_execution)
     - Required vs optional tags
     - Examples from review.md, todo.md, errors.md
     - Research-backed patterns from Stanford/Anthropic studies
   - Reference: OpenAgents system for comparison

2. **Create Command Structure Standard** (30 min)
   - File: `.opencode/context/core/standards/command-structure.md`
   - Content:
     - Frontmatter schema for commands
     - XML structure requirements
     - Context loading specification
     - Routing vs execution separation
     - Maximum file size guidelines (target: <200 lines)
   - Examples: review.md as gold standard

3. **Create Subagent Structure Standard** (30 min)
   - File: `.opencode/context/core/standards/subagent-structure.md`
   - Content:
     - Frontmatter schema for subagents
     - XML structure requirements
     - Workflow ownership model
     - Context loading strategy
     - Return format requirements
   - Examples: planner.md, implementer.md as gold standards

4. **Create Workflow Documentation** (1 hour)
   - Files:
     - `.opencode/context/project/processes/implementation-workflow.md`
     - `.opencode/context/project/processes/planning-workflow.md`
     - `.opencode/context/project/processes/research-workflow.md`
   - Content: Extract detailed workflow stages from current command files
   - Purpose: Reference documentation for subagents, remove from commands

5. **Create Git Safety Guide** (30 min)
   - File: `.opencode/context/core/standards/git-safety.md`
   - Content:
     - When to commit before risky operations
     - Commit message standards for safety commits
     - Rollback procedures
     - No backup files policy
   - Examples: /todo command safety pattern

**Deliverables**:
- 5 new context files documenting standards
- Foundation for all subsequent phases
- Clear reference for maintaining consistency

**Success Criteria**:
- All standards files created and reviewed
- Standards align with OpenAgents best practices
- Standards are actionable and specific

---

### Phase 2: Orchestrator Enhancement (1-2 hours)

**Objective**: Enhance orchestrator with XML structure matching OpenAgents standards.

**Current State**:
```markdown
# Orchestrator Agent

**Version**: 3.0  
**Type**: Router  
**Purpose**: Lightweight command routing with delegation safety

## Role
Route user commands to appropriate subagents...

## Routing Process
1. Load Command
2. Prepare Context
...
```

**Target State**:
```markdown
---
name: orchestrator
version: 4.0
type: router
description: "Lightweight command routing with delegation safety and cycle detection"
mode: orchestrator
temperature: 0.1
max_tokens: 2000
timeout: 60
context_loading:
  strategy: minimal
  index: ".opencode/context/index.md"
  required:
    - "core/standards/command-structure.md"
    - "system/routing-guide.md"
delegation:
  max_depth: 3
  timeout_default: 3600
  cycle_detection: true
---

<context>
  <system_context>
    Lightweight command router with delegation safety, cycle detection, and timeout enforcement.
    Routes user commands to specialized subagents based on command frontmatter.
  </system_context>
  <domain_context>
    ProofChecker project management with Lean 4 integration, task tracking, and workflow orchestration.
  </domain_context>
  <task_context>
    Parse command, load command file, extract target agent, prepare delegation context,
    invoke subagent, validate return, and relay result to user.
  </task_context>
  <execution_context>
    Minimal context loading. No workflow execution. Pure routing with safety checks.
  </execution_context>
</context>

<role>
  Command router coordinating specialized subagents with delegation safety and session tracking
</role>

<task>
  Route user commands to appropriate subagents, manage delegation safety (cycle detection,
  timeout enforcement, session tracking), validate returns, and relay results to user
</task>

<workflow_execution>
  <stage id="1" name="LoadCommand">
    <action>Read command file and extract routing metadata</action>
    <process>
      1. Parse command name from user input
      2. Read `.opencode/command/{command}.md`
      3. Extract `agent:` from frontmatter
      4. Extract `context_level:` from frontmatter
      5. Extract `routing:` rules if present (language-based routing)
      6. Validate command file exists and is well-formed
    </process>
    <checkpoint>Command loaded and routing target identified</checkpoint>
  </stage>

  <stage id="2" name="PrepareContext">
    <action>Generate delegation context with safety metadata</action>
    <process>
      1. Generate session_id: sess_{timestamp}_{random_6char}
      2. Set delegation_depth = 1
      3. Set delegation_path = ["orchestrator", "{command}", "{agent}"]
      4. Extract timeout from command frontmatter or use default
      5. Set deadline = current_time + timeout
      6. Prepare task context from user input
    </process>
    <checkpoint>Delegation context prepared with safety metadata</checkpoint>
  </stage>

  <stage id="3" name="CheckSafety">
    <action>Verify delegation safety constraints</action>
    <process>
      1. Check for cycles: agent not in delegation_path
      2. Check depth: delegation_depth ≤ 3
      3. Check timeout: timeout is configured and reasonable
      4. Validate session_id is unique
    </process>
    <safety_checks>
      - Cycle detection: Prevent infinite delegation loops
      - Depth limit: Max 3 levels (orchestrator → command → agent → utility)
      - Timeout enforcement: All delegations have deadlines
      - Session uniqueness: No duplicate session IDs
    </safety_checks>
    <checkpoint>Safety checks passed</checkpoint>
  </stage>

  <stage id="4" name="RegisterSession">
    <action>Register delegation in session registry</action>
    <process>
      1. Add entry to in-memory registry:
         {
           "session_id": "sess_...",
           "command": "{command}",
           "subagent": "{agent}",
           "start_time": "ISO8601",
           "timeout": seconds,
           "deadline": "ISO8601",
           "status": "running",
           "delegation_depth": 1,
           "delegation_path": ["orchestrator", "{command}", "{agent}"]
         }
      2. Store registry for monitoring
    </process>
    <checkpoint>Session registered</checkpoint>
  </stage>

  <stage id="5" name="Delegate">
    <action>Invoke target subagent with delegation context</action>
    <process>
      1. Route to target agent (from command frontmatter)
      2. Pass delegation context (session_id, depth, path, timeout)
      3. Pass task context (user input, task number if applicable)
      4. Set timeout deadline
      5. Wait for return
    </process>
    <checkpoint>Subagent invoked</checkpoint>
  </stage>

  <stage id="6" name="Monitor">
    <action>Monitor for timeout and handle partial results</action>
    <process>
      1. Check registry every 60s for timeouts
      2. If current_time > deadline:
         - Mark session as "timeout"
         - Request partial results from subagent
         - Log timeout event
      3. If subagent returns before deadline:
         - Mark session as "completed"
         - Proceed to validation
    </process>
    <timeout_handling>
      - Research: 3600s (1 hour)
      - Planning: 1800s (30 minutes)
      - Implementation: 7200s (2 hours)
      - Review: 3600s (1 hour)
      - Default: 1800s (30 minutes)
    </timeout_handling>
    <checkpoint>Return received or timeout handled</checkpoint>
  </stage>

  <stage id="7" name="ValidateReturn">
    <action>Validate subagent return format</action>
    <process>
      1. Check return is valid JSON
      2. Validate against subagent-return-format.md schema
      3. Check session_id matches expected
      4. Validate status is valid enum (completed|partial|failed|blocked)
      5. Validate required fields present (status, summary, artifacts, metadata)
      6. Check token limits (summary <100 tokens)
    </process>
    <validation_schema>
      {
        "status": "completed|partial|failed|blocked",
        "summary": "string (<100 tokens)",
        "artifacts": [{"type": "...", "path": "...", "summary": "..."}],
        "metadata": {...},
        "session_id": "sess_...",
        "errors": [...] (if status != completed)
      }
    </validation_schema>
    <checkpoint>Return validated</checkpoint>
  </stage>

  <stage id="8" name="CompleteSession">
    <action>Mark delegation complete and cleanup</action>
    <process>
      1. Update registry entry:
         - status = "completed" | "timeout" | "failed"
         - end_time = current_time
         - result_summary = return.summary
      2. Remove from active registry (keep in history for debugging)
      3. Log completion event
    </process>
    <checkpoint>Session completed and cleaned up</checkpoint>
  </stage>

  <stage id="9" name="ReturnToUser">
    <action>Relay result to user</action>
    <process>
      1. Extract summary from return (already <100 tokens)
      2. Format for user display
      3. Include artifact paths if applicable
      4. Include error details if status != completed
      5. Return to user
    </process>
    <return_format>
      {subagent_summary}
      
      {if artifacts:}
      Artifacts created:
      {for each artifact:}
      - {artifact.type}: {artifact.path}
      
      {if status != completed:}
      Status: {status}
      {error_details}
    </return_format>
    <checkpoint>Result returned to user</checkpoint>
  </stage>
</workflow_execution>

<routing_intelligence>
  <command_loading>
    Read command file from `.opencode/command/{command}.md`
    Extract `agent:` from frontmatter for routing target
    Extract `routing:` for language-based routing (if applicable)
  </command_loading>
  
  <language_routing>
    If command has `routing:` section:
      - Extract language from task context
      - Route to language-specific agent (e.g., lean → lean-implementation-agent)
      - Fallback to default agent if language not matched
  </language_routing>
  
  <context_allocation>
    Orchestrator uses minimal context (Level 0):
      - Command file frontmatter only
      - No full command content
      - No project state
      - No task details
    
    Subagents load context per their context_loading frontmatter
  </context_allocation>
</routing_intelligence>

<delegation_safety>
  <cycle_detection>
    Block delegation if target agent already in delegation_path
    Example: orchestrator → implement → implementer → implementer (BLOCKED)
    Max depth: 3 levels
  </cycle_detection>
  
  <timeout_enforcement>
    All delegations have configured timeouts
    Timeouts vary by command type (research: 3600s, planning: 1800s, etc.)
    Partial results returned on timeout
    Resume support for long-running operations
  </timeout_enforcement>
  
  <session_tracking>
    Unique session_id for each delegation: sess_{timestamp}_{random_6char}
    Registry tracks: command, subagent, start_time, deadline, status, depth, path
    Session history preserved for debugging
  </session_tracking>
  
  <return_validation>
    Validate against subagent-return-format.md schema
    Check session_id matches expected
    Verify token limits (summary <100 tokens)
    Ensure required fields present
  </return_validation>
</delegation_safety>

<error_handling>
  <timeout>
    If delegation exceeds timeout:
      - Mark session as "timeout"
      - Request partial results from subagent
      - Return partial status to user with resume instructions
      - Log timeout event to errors.json
  </timeout>
  
  <validation_failure>
    If return validation fails:
      - Log validation error with details
      - Return failed status to user
      - Recommend subagent fix
      - Preserve raw return for debugging
  </validation_failure>
  
  <cycle_detected>
    If cycle detected in delegation_path:
      - Block delegation immediately
      - Return error with delegation path
      - Recommend fixing command routing
  </cycle_detected>
  
  <max_depth_exceeded>
    If delegation_depth > 3:
      - Block delegation immediately
      - Return error with depth limit
      - Recommend flattening delegation chain
  </max_depth_exceeded>
</error_handling>

<quality_standards>
  <minimal_context>
    Orchestrator loads only command frontmatter, not full content
    Reduces context overhead by ~90%
    Subagents load their own context per context_loading frontmatter
  </minimal_context>
  
  <fast_routing>
    Target: <1s routing time for simple commands
    No heavy computation in orchestrator
    Pure routing logic only
  </fast_routing>
  
  <safety_first>
    All delegations have cycle detection, depth limits, and timeouts
    No infinite loops or runaway processes
    Graceful degradation on timeout
  </safety_first>
  
  <validation_strict>
    All returns validated against schema
    Token limits enforced
    Session IDs verified
  </validation_strict>
</quality_standards>

<performance_metrics>
  <routing_time>
    Target: <1s for command loading and routing
    Measured: start of LoadCommand to end of Delegate
  </routing_time>
  
  <context_overhead>
    Orchestrator context: <5KB (frontmatter only)
    Reduction: ~90% vs loading full command files
  </context_overhead>
  
  <safety_overhead>
    Cycle detection: O(n) where n = delegation_depth (max 3)
    Session registration: O(1)
    Validation: O(1)
    Total overhead: <100ms
  </safety_overhead>
</performance_metrics>

<documentation>
  <examples>
    See `.opencode/context/system/orchestrator-guide.md` for:
      - Example delegations
      - Troubleshooting guide
      - Common error patterns
      - Performance tuning
  </examples>
  
  <routing>
    See `.opencode/context/system/routing-guide.md` for:
      - Command routing patterns
      - Language-based routing
      - Context allocation strategy
  </routing>
  
  <delegation>
    See `.opencode/context/core/standards/delegation.md` for:
      - Delegation safety rules
      - Session tracking
      - Return format requirements
  </delegation>
</documentation>
```

**Tasks**:
1. Add comprehensive frontmatter (30 min)
2. Add XML structure (context, role, task, workflow_execution) (1 hour)
3. Enhance routing intelligence section (15 min)
4. Add delegation safety documentation (15 min)
5. Test orchestrator with existing commands (30 min)

**Deliverables**:
- Enhanced orchestrator.md with full XML structure
- Consistent with OpenAgents standards
- Improved delegation safety documentation

**Success Criteria**:
- Orchestrator has complete XML structure
- All routing logic documented
- Safety checks clearly specified
- File size <300 lines (currently 67, target ~250)

---

### Phase 3: Command XML Conversion (3-4 hours)

**Objective**: Convert all commands to XML structure following command-structure.md standard.

**Commands to Convert** (7 files):
1. `implement.md` (373 lines → target <200 lines)
2. `plan.md` (269 lines → target <150 lines)
3. `research.md` (272 lines → target <150 lines)
4. `revise.md` (needs review, estimate 200 lines → target <150 lines)
5. `task.md` (partial XML, needs completion)
6. `meta.md` (needs review)
7. `research-routing.md` (needs review)

**Conversion Template** (based on review.md gold standard):

```markdown
---
name: {command_name}
agent: {target_agent}
description: "{brief description}"
context_level: {1|2|3}
language: {varies|markdown|lean|etc}
routing:  # Optional, for language-based routing
  lean: {lean_agent}
  default: {default_agent}
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/system/status-markers.md"
    - "{command_specific_context}"
  max_context_size: 50000
---

**Task Input**: $ARGUMENTS ({description})

<context>
  <system_context>
    {What this command does in the system}
  </system_context>
  <domain_context>
    {Domain-specific context}
  </domain_context>
  <task_context>
    {Specific task this command handles}
  </task_context>
  <execution_context>
    {How this command executes - delegation, direct, etc}
  </execution_context>
</context>

<role>{Brief role description}</role>

<task>
  {Detailed task description}
</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>{What happens in preflight}</action>
    <process>
      1. {Step 1}
      2. {Step 2}
      ...
    </process>
    <checkpoint>{Completion criteria}</checkpoint>
  </stage>
  
  {... more stages ...}
  
  <stage id="N" name="ReturnSuccess">
    <action>Return result to user</action>
    <return_format>
      {Expected return format}
    </return_format>
    <checkpoint>Result returned</checkpoint>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>
    {Context loading strategy}
  </context_allocation>
  
  <language_routing>  # If applicable
    {Language-based routing rules}
  </language_routing>
</routing_intelligence>

<quality_standards>
  {Quality requirements}
</quality_standards>

<usage_examples>
  - `/{command} {example1}`
  - `/{command} {example2}`
</usage_examples>

<validation>
  <pre_flight>
    {Pre-flight validation checks}
  </pre_flight>
  <mid_flight>
    {Mid-flight validation checks}
  </mid_flight>
  <post_flight>
    {Post-flight validation checks}
  </post_flight>
</validation>

<error_handling>
  <error_type_1>
    {How to handle error type 1}
  </error_type_1>
  {... more error types ...}
</error_handling>
```

**Conversion Process** (per command):

1. **Extract Frontmatter** (10 min)
   - Add context_loading section
   - Ensure all required fields present
   - Validate routing configuration

2. **Add XML Context Tags** (15 min)
   - <context> with 4 sub-contexts
   - <role> brief description
   - <task> detailed description

3. **Convert Workflow to XML** (30 min)
   - Wrap workflow in <workflow_execution>
   - Convert stages to <stage> tags with id, name
   - Add <action>, <process>, <checkpoint> to each stage
   - Move detailed implementation notes to subagent files

4. **Add Supporting Sections** (15 min)
   - <routing_intelligence>
   - <quality_standards>
   - <usage_examples>
   - <validation>
   - <error_handling>

5. **Reduce File Size** (20 min)
   - Move detailed workflows to context/project/processes/
   - Move detailed error handling to subagent files
   - Keep only routing-relevant information
   - Reference detailed docs instead of duplicating

6. **Test Command** (10 min)
   - Verify command still works
   - Check routing is correct
   - Validate return format

**Per-Command Breakdown**:

#### 3.1 implement.md (1 hour)
- Current: 373 lines, no XML
- Target: <200 lines, full XML
- Key changes:
  - Add XML structure
  - Move detailed implementation workflow to implementer.md
  - Move language routing details to context file
  - Simplify to routing + validation only

#### 3.2 plan.md (45 min)
- Current: 269 lines, no XML
- Target: <150 lines, full XML
- Key changes:
  - Add XML structure
  - Move detailed planning workflow to planner.md
  - Move plan template details to context file
  - Simplify to routing + validation only

#### 3.3 research.md (45 min)
- Current: 272 lines, no XML
- Target: <150 lines, full XML
- Key changes:
  - Add XML structure
  - Move detailed research workflow to researcher.md
  - Move language routing details to context file
  - Simplify to routing + validation only

#### 3.4 revise.md (45 min)
- Current: Unknown (needs review)
- Target: <150 lines, full XML
- Key changes:
  - Add XML structure
  - Align with plan.md pattern
  - Move detailed revision workflow to planner.md

#### 3.5 task.md (30 min)
- Current: Partial XML
- Target: Complete XML structure
- Key changes:
  - Complete XML tags
  - Ensure consistency with other commands
  - Validate task creation workflow

#### 3.6 meta.md (30 min)
- Current: Unknown (needs review)
- Target: Full XML structure
- Key changes: TBD after review

#### 3.7 research-routing.md (30 min)
- Current: Unknown (needs review)
- Target: Full XML structure
- Key changes: TBD after review

**Deliverables**:
- 7 commands converted to XML structure
- All commands <200 lines
- Detailed workflows moved to subagents or context files
- Consistent structure across all commands

**Success Criteria**:
- All commands have complete XML structure
- All commands follow command-structure.md standard
- All commands <200 lines
- All commands tested and working
- Detailed workflows moved to appropriate locations

---

### Phase 4: Backup Removal & Git Safety (1-2 hours)

**Objective**: Remove all .bak file creation, replace with git commits before risky operations.

**Current Backup Locations**:
1. `todo.md` Stage 5 (AtomicUpdate):
   - Creates TODO.md.bak, state.json.bak, archive/state.json.bak
   - Uses two-phase commit with rollback

2. Likely others (need to search):
   - Search for `.bak` in all command and subagent files
   - Search for `backup` in all files

**Replacement Strategy**:

**Before** (todo.md example):
```markdown
<stage id="5" name="AtomicUpdate">
  <process>
    **Phase 1 (Prepare)**:
    1. Backup current state:
       - Backup TODO.md → TODO.md.bak
       - Backup state.json → state.json.bak
       - Backup archive/state.json → archive/state.json.bak
    2. Validate all updates
    
    **Phase 2 (Commit)**:
    1. Write updated files
    2. If any operation fails:
       - Execute rollback_archival()
       - Restore from .bak files
  </process>
</stage>
```

**After**:
```markdown
<stage id="5" name="AtomicUpdate">
  <process>
    **Phase 1 (Prepare)**:
    1. Create git safety commit:
       - git add TODO.md state.json archive/state.json
       - git commit -m "safety: pre-todo archival snapshot"
       - Store commit SHA for rollback
    2. Validate all updates in memory
    
    **Phase 2 (Commit)**:
    1. Write updated files
    2. If any operation fails:
       - Execute git_rollback()
       - git reset --hard {safety_commit_sha}
       - git clean -fd (remove untracked files)
  </process>
  
  <git_safety>
    <safety_commit>
      Create commit before risky operations:
      - Message format: "safety: pre-{operation} snapshot"
      - Include all files that will be modified
      - Store commit SHA for rollback
    </safety_commit>
    
    <rollback>
      If operation fails:
      - git reset --hard {safety_commit_sha}
      - git clean -fd
      - Log rollback event to errors.json
      - Return error to user with rollback confirmation
    </rollback>
    
    <cleanup>
      On success:
      - Keep safety commit (part of history)
      - Create final commit with actual changes
      - Message format: "todo: archive {N} tasks"
    </cleanup>
  </git_safety>
</stage>
```

**Tasks**:

1. **Search for Backup Patterns** (15 min)
   ```bash
   grep -r "\.bak" .opencode/
   grep -r "backup" .opencode/
   grep -r "Backup" .opencode/
   ```

2. **Update todo.md** (30 min)
   - Replace backup creation with git safety commit
   - Update rollback mechanism to use git reset
   - Test archival with git rollback

3. **Update Other Commands** (30 min per command)
   - Apply same pattern to any other commands with backups
   - Ensure git safety commits before risky operations

4. **Create Git Safety Guide** (30 min)
   - Document git safety pattern in context file
   - Include examples from todo.md
   - Specify when to use safety commits

5. **Test Git Safety** (30 min)
   - Test successful operations (safety commit + final commit)
   - Test failed operations (rollback to safety commit)
   - Verify no .bak files created

**Deliverables**:
- All .bak file creation removed
- Git safety commits implemented for risky operations
- Git rollback mechanism tested
- Git safety guide created

**Success Criteria**:
- No .bak files created anywhere in system
- Git safety commits work correctly
- Rollback mechanism tested and verified
- Documentation complete

---

### Phase 5: Context Loading Standardization (2-3 hours)

**Objective**: Standardize context loading using frontmatter approach across all files.

**Decision**: Use **frontmatter-based context loading** (Pattern B) everywhere.

**Rationale**:
- ✅ Easier to find and read (in frontmatter)
- ✅ Machine-parseable (YAML)
- ✅ Consistent with subagent pattern
- ✅ Supports lazy loading strategy
- ✅ Clear max_context_size limits
- ✅ Explicit required vs optional context

**Standard Pattern**:

```yaml
---
name: {agent_name}
# ... other frontmatter ...
context_loading:
  strategy: lazy  # lazy | eager | minimal
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/system/status-markers.md"
    - "{domain_specific_context}"
  optional:
    - "{optional_context_1}"
    - "{optional_context_2}"
  max_context_size: 50000  # bytes
  cache_strategy: session  # session | none | persistent
---
```

**Context Loading Strategies**:

1. **Minimal** (Orchestrator):
   - Load only command frontmatter
   - No full command content
   - No project state
   - Target: <5KB

2. **Lazy** (Most commands and subagents):
   - Load required context on-demand
   - Load optional context if needed
   - Cache for session duration
   - Target: <50KB

3. **Eager** (Complex operations like review):
   - Load all required context upfront
   - Load most optional context
   - Cache for operation duration
   - Target: <100KB

**Tasks**:

1. **Create Context Index** (1 hour)
   - File: `.opencode/context/index.md`
   - Content:
     - Map of all context files with descriptions
     - Size estimates for each file
     - Loading recommendations (required vs optional)
     - Dependency graph (which contexts depend on others)
   - Example:
     ```markdown
     # Context Index
     
     ## Core Standards
     - `core/standards/subagent-return-format.md` (2KB) - REQUIRED for all subagents
     - `core/standards/command-structure.md` (3KB) - REQUIRED for all commands
     - `core/system/status-markers.md` (1KB) - REQUIRED for status updates
     
     ## Project Processes
     - `project/processes/implementation-workflow.md` (5KB) - OPTIONAL for implementer
     - `project/processes/planning-workflow.md` (4KB) - OPTIONAL for planner
     
     ## Domain Knowledge
     - `project/lean4/domain/lean4-syntax.md` (8KB) - REQUIRED for lean agents
     - `project/lean4/tools/leansearch-api.md` (3KB) - OPTIONAL for lean-research
     ```

2. **Add context_loading to All Commands** (1 hour, ~10 min per command)
   - Add frontmatter section to each command
   - Specify strategy (minimal for routing, lazy for execution)
   - List required context files
   - List optional context files
   - Set max_context_size

3. **Add context_loading to All Subagents** (30 min)
   - Review existing context_loading sections
   - Ensure consistency with index.md
   - Update required/optional lists
   - Verify max_context_size is appropriate

4. **Remove Explicit Context Loading** (30 min)
   - Remove `Context Loaded:` sections from commands
   - Remove `@` symbol references
   - Keep frontmatter as single source of truth

5. **Test Context Loading** (30 min)
   - Verify required context is loaded
   - Verify optional context is loaded when needed
   - Verify max_context_size is respected
   - Measure actual context sizes

**Deliverables**:
- Context index created
- All commands have context_loading frontmatter
- All subagents have consistent context_loading
- Explicit context loading removed
- Context loading tested

**Success Criteria**:
- All files use frontmatter context_loading
- Context index is comprehensive
- No explicit `Context Loaded:` sections remain
- Context sizes are within limits
- Loading is consistent across all files

---

### Phase 6: Architecture Refactoring (2-3 hours)

**Objective**: Move detailed workflows from commands to subagent files, improving separation of concerns.

**Current Issue**:
- Commands contain detailed workflow documentation (100s of lines)
- Violates separation of concerns (commands should route, subagents should execute)
- Makes commands hard to maintain
- Duplicates information between command and subagent

**Target Architecture**:

```
Command File (Routing Layer):
- Frontmatter with routing metadata
- XML context tags (brief)
- Lightweight workflow (routing stages only)
- Delegation to subagent
- Return validation
- Target: <200 lines

Subagent File (Execution Layer):
- Frontmatter with execution metadata
- XML context tags (detailed)
- Complete workflow (all execution stages)
- Business logic
- Artifact creation
- Status updates
- Git commits
- Return formatting
- Target: 200-400 lines
```

**Refactoring Strategy**:

**Example: implement.md → implementer.md**

**Before** (implement.md has 373 lines):
```markdown
## Workflow

1. **Preflight**: Parse arguments, validate task exists, update status to [IMPLEMENTING]
2. **CheckLanguage**: Extract language from task entry, determine routing
3. **PrepareDelegation**: Check for plan, determine resume point, generate session ID
4. **InvokeAgent**: Delegate to implementer agent with task context
5. **ValidateReturn**: Verify implementation artifacts created
6. **PrepareReturn**: Format return object
7. **Postflight**: Update status to [COMPLETED], create git commit
8. **ReturnSuccess**: Return standardized result

## Plan-Based vs Direct Implementation
{100 lines of detailed logic}

## Language-Based Routing
{50 lines of routing details}

## Context Loading
{50 lines of context details}

## Resume Support
{40 lines of resume logic}

## Artifacts Created
{30 lines of artifact specs}

## Status Transitions
{20 lines of status logic}

## Error Handling
{50 lines of error cases}
```

**After** (implement.md has <200 lines):
```markdown
<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Parse arguments and validate task</action>
    <process>
      1. Parse task number from $ARGUMENTS
      2. Validate task exists in TODO.md
      3. Update status to [IMPLEMENTING]
    </process>
    <checkpoint>Task validated and status updated</checkpoint>
  </stage>
  
  <stage id="2" name="CheckLanguage">
    <action>Extract language for routing</action>
    <process>
      1. Extract language from task entry
      2. Determine target agent (lean → lean-implementation-agent, else → implementer)
    </process>
    <checkpoint>Routing target determined</checkpoint>
  </stage>
  
  <stage id="3" name="Delegate">
    <action>Delegate to implementer subagent</action>
    <process>
      1. Prepare delegation context
      2. Invoke target agent
      3. Wait for return
    </process>
    <checkpoint>Subagent invoked</checkpoint>
  </stage>
  
  <stage id="4" name="ValidateReturn">
    <action>Validate subagent return</action>
    <process>
      1. Validate against subagent-return-format.md
      2. Check artifacts created
    </process>
    <checkpoint>Return validated</checkpoint>
  </stage>
  
  <stage id="5" name="ReturnSuccess">
    <action>Return result to user</action>
    <return_format>
      Implementation completed for task {number}.
      {brief_summary}
      Files: {file_count} modified/created.
    </return_format>
    <checkpoint>Result returned</checkpoint>
  </stage>
</workflow_execution>

<routing_intelligence>
  <language_routing>
    See `.opencode/context/project/processes/implementation-workflow.md` for:
    - Language detection logic
    - Routing rules
    - Agent capabilities
  </language_routing>
</routing_intelligence>

<delegation>
  Detailed implementation workflow in `.opencode/agent/subagents/implementer.md`
  
  Implementer handles:
  - Plan-based vs direct implementation
  - Resume support
  - Artifact creation
  - Status updates
  - Git commits
</delegation>
```

**implementer.md gains detailed workflow** (already has some, enhance):
```markdown
<workflow_execution>
  <stage id="1" name="LoadTask">
    <action>Load task details and determine implementation mode</action>
    <process>
      1. Read task from TODO.md
      2. Check for existing plan
      3. If plan exists:
         - Load plan file
         - Parse phases
         - Determine resume point (first [NOT STARTED] or [IN PROGRESS] phase)
         - Set mode = "phased"
      4. If no plan:
         - Set mode = "direct"
      5. Extract language, description, acceptance criteria
    </process>
    <plan_detection>
      Check TODO.md task entry for plan link:
      - **Plan**: .opencode/specs/{number}_{slug}/plans/implementation-001.md
      
      If link present:
        - Load plan file
        - Parse phase status markers
        - mode = "phased"
      Else:
        - mode = "direct"
    </plan_detection>
    <checkpoint>Task loaded and implementation mode determined</checkpoint>
  </stage>
  
  <stage id="2" name="ExecuteImplementation">
    <action>Execute implementation based on mode</action>
    <process>
      If mode == "phased":
        1. For each phase (starting from resume point):
           a. Read phase description and tasks
           b. Execute phase implementation
           c. Create phase artifacts
           d. Update phase status to [COMPLETED]
           e. Create git commit for phase
           f. If timeout: Return partial with resume point
        2. Continue until all phases complete or timeout
      
      If mode == "direct":
        1. Read task description and acceptance criteria
        2. Determine files to modify/create
        3. Execute implementation
        4. Create all artifacts
        5. Create single git commit
    </process>
    <phased_execution>
      For each phase:
        1. Update phase status: [NOT STARTED] → [IN PROGRESS]
        2. Execute phase tasks
        3. Create phase artifacts
        4. Validate phase completion
        5. Update phase status: [IN PROGRESS] → [COMPLETED]
        6. Git commit: "task {number} phase {N}: {phase_name}"
        7. If timeout: Save progress, return partial
    </phased_execution>
    <direct_execution>
      Single-pass implementation:
        1. Analyze task requirements
        2. Determine files to modify/create
        3. Execute all changes
        4. Create all artifacts
        5. Git commit: "task {number}: {description}"
    </direct_execution>
    <checkpoint>Implementation executed</checkpoint>
  </stage>
  
  <stage id="3" name="CreateArtifacts">
    <action>Create implementation artifacts</action>
    <process>
      1. Create implementation files (code, docs, configs)
      2. If multi-file output:
         - Create implementation summary artifact
         - Path: .opencode/specs/{number}_{slug}/summaries/implementation-summary-{YYYYMMDD}.md
         - Content: What was implemented, files modified, key decisions
         - Token limit: <100 tokens
      3. Verify all artifacts created successfully
    </process>
    <artifact_types>
      - Implementation files: Actual code/docs/configs
      - Summary artifact: Overview for multi-file outputs (protects orchestrator context)
    </artifact_types>
    <checkpoint>Artifacts created</checkpoint>
  </stage>
  
  <stage id="4" name="UpdateStatus">
    <action>Update task status to [COMPLETED]</action>
    <process>
      1. Delegate to status-sync-manager for atomic update:
         - TODO.md: Status [IMPLEMENTING] → [COMPLETED]
         - TODO.md: Add **Completed**: {date}
         - state.json: Update status and timestamps
         - Plan file: Update phase statuses (if phased)
      2. Wait for status-sync-manager return
      3. Verify atomic update succeeded
    </process>
    <atomic_update>
      status-sync-manager ensures:
      - TODO.md and state.json updated atomically
      - Plan file updated if exists
      - Two-phase commit (all or nothing)
      - Rollback on failure
    </atomic_update>
    <checkpoint>Status updated atomically</checkpoint>
  </stage>
  
  <stage id="5" name="CreateGitCommit">
    <action>Create git commit for implementation</action>
    <process>
      1. Delegate to git-workflow-manager:
         - Scope: All implementation artifacts + TODO.md + state.json
         - Message: "task {number}: {description}" (or phase-specific)
      2. Wait for git-workflow-manager return
      3. If commit fails: Log error (non-critical)
    </process>
    <commit_strategy>
      - Phased: One commit per completed phase
      - Direct: One commit for entire task
      - Message format: "task {number}: {description}"
    </commit_strategy>
    <checkpoint>Git commit created</checkpoint>
  </stage>
  
  <stage id="6" name="PrepareReturn">
    <action>Format return object per subagent-return-format.md</action>
    <process>
      1. Build return object:
         {
           "status": "completed" | "partial",
           "summary": "{brief_1_sentence_overview} (<100 tokens)",
           "artifacts": [
             {
               "type": "implementation",
               "path": "{file_path}",
               "summary": "{brief_description}"
             },
             {
               "type": "summary",
               "path": "{summary_path}",
               "summary": "Implementation summary"
             }
           ],
           "metadata": {
             "task_number": {number},
             "mode": "phased" | "direct",
             "phases_completed": {count} (if phased),
             "files_modified": {count},
             "language": "{language}"
           },
           "session_id": "{session_id}"
         }
      2. Validate return format
      3. Check token limits (summary <100 tokens)
    </process>
    <checkpoint>Return object prepared</checkpoint>
  </stage>
  
  <stage id="7" name="Return">
    <action>Return to command</action>
    <process>
      1. Return formatted object
      2. Command validates and relays to user
    </process>
    <checkpoint>Return sent</checkpoint>
  </stage>
</workflow_execution>

<resume_support>
  <detection>
    If plan exists:
      1. Parse phase status markers
      2. Find first [NOT STARTED] or [IN PROGRESS] phase
      3. Resume from that phase
      4. Skip all [COMPLETED] phases
  </detection>
  
  <invocation>
    Same command works for initial and resume:
    /implement {task_number}
    
    Implementer automatically detects incomplete phases and resumes
  </invocation>
  
  <partial_return>
    On timeout:
      1. Save current phase progress
      2. Update phase status to [IN PROGRESS]
      3. Return partial status with resume instructions
      4. User can resume with same command
  </partial_return>
</resume_support>

{... more detailed sections ...}
```

**Tasks**:

1. **Identify Workflow Sections to Move** (30 min)
   - Review all commands
   - Identify detailed workflow sections (>50 lines)
   - Mark for migration to subagents

2. **Enhance Subagent Files** (1 hour per subagent)
   - implementer.md: Add detailed implementation workflow
   - planner.md: Add detailed planning workflow
   - researcher.md: Add detailed research workflow
   - Move content from commands to subagents

3. **Simplify Command Files** (30 min per command)
   - Remove detailed workflow sections
   - Keep only routing stages
   - Add references to subagent files
   - Add references to context files

4. **Create Process Context Files** (1 hour)
   - implementation-workflow.md: Detailed implementation process
   - planning-workflow.md: Detailed planning process
   - research-workflow.md: Detailed research process
   - Extract from current command files

5. **Test Refactored Architecture** (30 min)
   - Test each command end-to-end
   - Verify workflows still work
   - Check file sizes reduced
   - Validate separation of concerns

**Deliverables**:
- Commands simplified to <200 lines
- Subagents enhanced with detailed workflows
- Process context files created
- Architecture tested and validated

**Success Criteria**:
- All commands <200 lines
- All detailed workflows in subagents or context files
- Clear separation: commands route, subagents execute
- All workflows tested and working

---

### Phase 7: Quality Enhancements (3-4 hours)

**Objective**: Improve error handling, create testing infrastructure, and enhance documentation.

#### 7.1 Error Handling Improvements (1 hour)

**Current State**:
- Error handling exists but inconsistent
- Some commands have detailed error sections, others don't
- Error messages vary in quality

**Improvements**:

1. **Standardize Error Format** (20 min)
   - Create error format standard in context file
   - Define error categories (validation, timeout, delegation, git, etc.)
   - Specify error message format
   - Include recovery instructions

2. **Enhance Command Error Handling** (30 min)
   - Add comprehensive error handling to all commands
   - Use standard error format
   - Include recovery instructions
   - Log errors to errors.json

3. **Enhance Subagent Error Handling** (10 min)
   - Review subagent error handling
   - Ensure consistency with command error handling
   - Add recovery instructions

**Deliverables**:
- Error format standard created
- All commands have comprehensive error handling
- Error messages are clear and actionable

#### 7.2 Testing Infrastructure (1.5 hours)

**Current State**:
- No automated tests for commands or subagents
- Manual testing only

**Testing Strategy**:

1. **Create Test Framework** (30 min)
   - Directory: `.opencode/tests/`
   - Structure:
     ```
     tests/
     ├── commands/
     │   ├── implement.test.md
     │   ├── plan.test.md
     │   └── research.test.md
     ├── subagents/
     │   ├── implementer.test.md
     │   ├── planner.test.md
     │   └── researcher.test.md
     └── README.md
     ```
   - Test format: Markdown with test cases

2. **Create Command Tests** (30 min)
   - Test routing logic
   - Test argument parsing
   - Test delegation
   - Test return validation
   - Test error handling

3. **Create Subagent Tests** (30 min)
   - Test workflow execution
   - Test artifact creation
   - Test status updates
   - Test git commits
   - Test error handling

**Test Case Format**:
```markdown
# {Command/Subagent} Tests

## Test Case 1: {Test Name}

**Setup**:
- {Preconditions}

**Input**:
```bash
/{command} {arguments}
```

**Expected Output**:
- Status: {expected_status}
- Artifacts: {expected_artifacts}
- Return: {expected_return}

**Validation**:
- [ ] {Check 1}
- [ ] {Check 2}

## Test Case 2: {Error Case}

**Setup**:
- {Preconditions for error}

**Input**:
```bash
/{command} {invalid_arguments}
```

**Expected Error**:
- Error type: {error_type}
- Error message: {expected_message}
- Recovery: {recovery_instructions}

**Validation**:
- [ ] Error message is clear
- [ ] Recovery instructions provided
- [ ] No partial state created
```

**Deliverables**:
- Test framework created
- Tests for all commands
- Tests for all subagents
- Test documentation

#### 7.3 Performance Optimization (1 hour)

**Current State**:
- Context loading not optimized
- Some commands load unnecessary context
- No performance metrics

**Optimizations**:

1. **Measure Current Performance** (20 min)
   - Measure context loading time
   - Measure routing time
   - Measure end-to-end time
   - Identify bottlenecks

2. **Optimize Context Loading** (30 min)
   - Review context_loading frontmatter
   - Remove unnecessary required context
   - Move to optional where appropriate
   - Reduce max_context_size where possible

3. **Optimize Routing** (10 min)
   - Ensure orchestrator loads minimal context
   - Ensure commands load only routing-relevant context
   - Defer heavy context to subagents

**Performance Targets**:
- Orchestrator routing: <1s
- Command routing: <2s
- Subagent execution: Varies by operation
- Context loading: <5KB for orchestrator, <50KB for commands, <100KB for subagents

**Deliverables**:
- Performance measurements documented
- Context loading optimized
- Performance targets met

#### 7.4 Documentation Enhancement (30 min)

**Current State**:
- Documentation exists but scattered
- Some commands well-documented, others not
- No central documentation index

**Improvements**:

1. **Create Documentation Index** (15 min)
   - File: `.opencode/README.md`
   - Content:
     - System overview
     - Architecture diagram
     - Command reference
     - Subagent reference
     - Context file reference
     - Testing guide
     - Troubleshooting guide

2. **Enhance Command Documentation** (15 min)
   - Ensure all commands have usage examples
   - Ensure all commands have error handling docs
   - Ensure all commands reference relevant context files

**Deliverables**:
- Documentation index created
- All commands well-documented
- Clear navigation to all documentation

---

## Implementation Order

### Recommended Sequence

1. **Phase 1: Foundation & Standards** (2-3 hours)
   - Creates foundation for all other work
   - Must be done first

2. **Phase 2: Orchestrator Enhancement** (1-2 hours)
   - Sets standard for XML structure
   - Reference for command conversions

3. **Phase 3: Command XML Conversion** (3-4 hours)
   - Largest phase, most files to convert
   - Can be done incrementally (one command at a time)

4. **Phase 4: Backup Removal & Git Safety** (1-2 hours)
   - Can be done in parallel with Phase 3
   - Independent of XML conversion

5. **Phase 5: Context Loading Standardization** (2-3 hours)
   - Depends on Phase 1 (context index)
   - Should be done after Phase 3 (commands have frontmatter)

6. **Phase 6: Architecture Refactoring** (2-3 hours)
   - Depends on Phase 3 (commands converted)
   - Moves workflows to subagents

7. **Phase 7: Quality Enhancements** (3-4 hours)
   - Can be done incrementally
   - Testing can start after Phase 3
   - Performance optimization after Phase 5
   - Documentation throughout

### Parallel Work Opportunities

**Can be done in parallel**:
- Phase 3 (Command XML) + Phase 4 (Backup Removal)
- Phase 7.2 (Testing) can start after Phase 3
- Phase 7.4 (Documentation) can be done throughout

**Must be sequential**:
- Phase 1 → Phase 2 → Phase 3
- Phase 3 → Phase 5 → Phase 6
- Phase 6 → Phase 7.3 (Performance)

---

## Success Metrics

### Quantitative Metrics

1. **XML Structure Coverage**
   - Target: 100% of commands and orchestrator have XML structure
   - Current: 30% (3/10 commands)
   - Measurement: Count files with complete XML tags

2. **File Size Reduction**
   - Target: All commands <200 lines
   - Current: 3/10 commands >200 lines (implement: 373, review: 748, plan: 269)
   - Measurement: Line count per file

3. **Backup File Elimination**
   - Target: 0 .bak files created
   - Current: Unknown (need to search)
   - Measurement: Search for .bak creation in code

4. **Context Loading Consistency**
   - Target: 100% of files use frontmatter context_loading
   - Current: ~50% (subagents yes, commands mixed)
   - Measurement: Count files with context_loading frontmatter

5. **Test Coverage**
   - Target: 100% of commands and subagents have tests
   - Current: 0%
   - Measurement: Count test files vs agent files

6. **Performance**
   - Target: Orchestrator routing <1s, Command routing <2s
   - Current: Unknown
   - Measurement: Time measurements

### Qualitative Metrics

1. **Consistency**
   - All files follow same XML structure
   - All files use same context loading pattern
   - All files follow same error handling pattern

2. **Maintainability**
   - Commands are lightweight and easy to understand
   - Workflows are in appropriate locations (subagents, not commands)
   - Documentation is clear and comprehensive

3. **Performance**
   - Context loading is optimized
   - Routing is fast
   - No unnecessary overhead

4. **Quality**
   - Error handling is comprehensive
   - Tests exist for all critical paths
   - Documentation is complete

---

## Risk Mitigation

### Risks

1. **Breaking Changes**
   - Risk: XML conversion breaks existing functionality
   - Mitigation: Test each command after conversion, git commit after each file

2. **Git Safety Issues**
   - Risk: Git rollback doesn't work as expected
   - Mitigation: Test git safety pattern thoroughly before removing backups

3. **Context Loading Errors**
   - Risk: Frontmatter context loading breaks existing behavior
   - Mitigation: Test context loading after each change, verify context is loaded

4. **Performance Regression**
   - Risk: Changes slow down system
   - Mitigation: Measure performance before and after, optimize if needed

5. **Time Overrun**
   - Risk: 12-16 hour estimate is too low
   - Mitigation: Work incrementally, prioritize high-impact changes, defer low-priority items

### Rollback Plan

**If major issues occur**:
1. Git revert to last known good state
2. Identify specific issue
3. Fix issue in isolation
4. Test thoroughly
5. Re-apply changes incrementally

**Git Strategy**:
- Commit after each file conversion
- Commit after each phase
- Tag major milestones
- Keep detailed commit messages

---

## Validation Checklist

### Phase 1 Validation
- [ ] All standards files created
- [ ] Standards are clear and actionable
- [ ] Standards align with OpenAgents best practices
- [ ] Workflow documentation extracted from commands

### Phase 2 Validation
- [ ] Orchestrator has complete XML structure
- [ ] Orchestrator follows command-structure.md standard
- [ ] Orchestrator tested with existing commands
- [ ] File size <300 lines

### Phase 3 Validation
- [ ] All 7 commands converted to XML
- [ ] All commands follow command-structure.md standard
- [ ] All commands <200 lines
- [ ] All commands tested and working
- [ ] Detailed workflows moved to subagents/context

### Phase 4 Validation
- [ ] No .bak files created anywhere
- [ ] Git safety commits implemented
- [ ] Git rollback tested and working
- [ ] Git safety guide created

### Phase 5 Validation
- [ ] Context index created
- [ ] All files have context_loading frontmatter
- [ ] No explicit `Context Loaded:` sections remain
- [ ] Context sizes within limits
- [ ] Context loading tested

### Phase 6 Validation
- [ ] All commands <200 lines
- [ ] All detailed workflows in subagents
- [ ] Process context files created
- [ ] Architecture tested end-to-end

### Phase 7 Validation
- [ ] Error handling standardized
- [ ] Tests created for all commands and subagents
- [ ] Performance targets met
- [ ] Documentation complete

### Final Validation
- [ ] All quantitative metrics met
- [ ] All qualitative metrics met
- [ ] System tested end-to-end
- [ ] Documentation reviewed
- [ ] Git history clean and well-documented

---

## Next Steps

1. **Review this plan** - Confirm approach and priorities
2. **Create git branch** - `feature/system-improvement`
3. **Start Phase 1** - Create standards and context files
4. **Work incrementally** - One phase at a time, test thoroughly
5. **Document progress** - Update this plan with actual times and issues
6. **Celebrate completion** - System will be significantly improved!

---

## Appendix: File Inventory

### Commands (10 files)
1. ✅ `review.md` (748 lines) - HAS XML
2. ✅ `todo.md` (539 lines) - HAS XML
3. ✅ `errors.md` (397 lines) - HAS XML
4. ❌ `implement.md` (373 lines) - NO XML
5. ❌ `plan.md` (269 lines) - NO XML
6. ❌ `research.md` (272 lines) - NO XML
7. ❌ `revise.md` (unknown) - NO XML
8. ❌ `task.md` (unknown) - PARTIAL XML
9. ❌ `meta.md` (unknown) - UNKNOWN
10. ❌ `research-routing.md` (unknown) - UNKNOWN

### Subagents (14 files)
1. ✅ `planner.md` - HAS XML
2. ✅ `implementer.md` - HAS XML
3. `researcher.md` - NEEDS REVIEW
4. `reviewer.md` - NEEDS REVIEW
5. `task-executor.md` - NEEDS REVIEW
6. `status-sync-manager.md` - NEEDS REVIEW
7. `git-workflow-manager.md` - NEEDS REVIEW
8. `error-diagnostics-agent.md` - NEEDS REVIEW
9. `lean-implementation-agent.md` - NEEDS REVIEW
10. `lean-research-agent.md` - NEEDS REVIEW
11. `atomic-task-numberer.md` - NEEDS REVIEW
12. System builder subagents (5 files) - NEEDS REVIEW

### Orchestrator (1 file)
1. ❌ `orchestrator.md` (67 lines) - NO XML

### Context Files (many)
- Core standards: delegation.md, state-management.md
- Project domain: lean4/, logic/, math/, physics/, repo/
- Project processes: end-to-end-proof-workflow.md, etc.
- Project standards: lean4-style-guide.md, proof-conventions.md, etc.
- Project tools: aesop-integration.md, leansearch-api.md, etc.
- System: orchestrator-guide.md, routing-guide.md

---

**Total Estimated Effort**: 12-16 hours
**Recommended Timeline**: 2-3 days of focused work
**Priority**: High - Improves consistency, performance, and maintainability
