# Meta Command Enhancement Implementation Plan

**Created**: 2026-01-07  
**Status**: DRAFT - Ready for Review  
**Estimated Effort**: 12-16 hours  
**Priority**: High  
**Type**: meta

---

## Executive Summary

This plan addresses critical enhancements to the `/meta` command system to ensure:

1. **Correct routing**: Meta tasks (language='meta') route to meta subagents during `/implement`
2. **Task-based workflow**: `/meta` creates tasks with plans, not direct implementations
3. **Context precision**: Meta subagents receive exactly the context files they need
4. **Context evolution**: Meta subagents know when/how to revise context files without bloat
5. **Standards enforcement**: Context files guide meta agents to enforce and evolve opencode standards

---

## Problem Analysis

### Current Issues

#### Issue 1: Meta Task Routing Not Implemented
**Problem**: The `/implement` command has language-based routing for `lean` and `general`, but `meta` routing is not implemented.

**Evidence**:
- `/implement` command (line 8-9): `routing: { language_based: true, lean: lean-implementation-agent, default: implementer }`
- No `meta: meta` routing specified
- Meta tasks would incorrectly route to `implementer` instead of `meta` agent

**Impact**: Meta tasks cannot be implemented through the standard workflow, breaking the task-based approach.

#### Issue 2: Meta Command Creates Plans, Not Tasks
**Problem**: The `/meta` command's Stage 8 creates plan artifacts but the workflow description suggests it should create tasks with dependencies.

**Evidence**:
- Command description (line 4): "creates complete context-aware AI architectures"
- Stage 8 (line 635-1169): Creates plan artifacts directly
- No task creation with dependencies indicated

**Impact**: User cannot review and revise plans before implementation; no dependency tracking.

#### Issue 3: Context Files Not Specified for Meta Subagents
**Problem**: Meta subagents don't have explicit context_loading sections specifying which context files they need.

**Evidence**:
- `agent-generator.md` (lines 18-27): Generic context loading without specific meta context files
- Missing references to:
  - `project/meta/architecture-principles.md`
  - `project/meta/domain-patterns.md`
  - `project/meta/interview-patterns.md`
  - `core/templates/agent-template.md`
  - `core/templates/command-template.md`
  - `core/standards/frontmatter-delegation.md`

**Impact**: Meta subagents lack guidance on current system shape and standards.

#### Issue 4: No Context Revision Guidance
**Problem**: Meta subagents have no instructions on when/how to revise context files.

**Evidence**:
- No workflow stage for "assess context file changes needed"
- No guidance on:
  - When to update existing context vs. create new files
  - How to avoid context bloat (50-200 line limit)
  - Which context files to update for different types of changes

**Impact**: Context files become stale or bloated; system standards drift.

#### Issue 5: Standards Enforcement Not Integrated
**Problem**: Meta subagents don't explicitly reference standards they should enforce.

**Evidence**:
- Missing references to:
  - `.opencode/context/core/workflows/agent-workflow.md` (8-stage pattern)
  - `.opencode/context/core/standards/frontmatter-delegation.md` (<300 line commands)
  - `.opencode/context/core/formats/plan-format.md`
  - `.opencode/docs/STANDARDS_QUICK_REF.md`

**Impact**: Generated agents/commands may not follow current system standards.

---

## Solution Design

### Solution 1: Implement Meta Task Routing

**Approach**: Add `meta` routing to `/implement` command to route meta tasks to the `meta` agent.

**Changes Required**:

1. **Update `/implement` command frontmatter** (`.opencode/command/implement.md`):
   ```yaml
   routing:
     language_based: true
     lean: lean-implementation-agent
     meta: meta  # NEW
     default: implementer
   ```

2. **Update Stage 1 routing logic** (line 113-117):
   ```xml
   7. Determine target agent based on language
      - lean → lean-implementation-agent
      - meta → meta  # NEW
      - general → implementer
   ```

3. **Add meta routing documentation** (line 527-534):
   ```markdown
   | Language | Agent | Tools |
   |----------|-------|-------|
   | lean | lean-implementation-agent | lean-lsp-mcp, lake build |
   | meta | meta | File operations, delegation to meta subagents |  # NEW
   | general | implementer | File operations, git |
   ```

**Validation**:
- Create test meta task with `language: meta`
- Run `/implement {task_number}`
- Verify routes to `meta` agent, not `implementer`

---

### Solution 2: Convert Meta Command to Task-Based Workflow

**Approach**: Modify `/meta` command Stage 8 to create tasks with dependencies instead of direct plan artifacts.

**Current Behavior** (Stage 8, lines 635-1169):
- Creates plan artifacts directly in task directories
- No task entries in TODO.md
- No dependency tracking

**New Behavior**:
- Create task entries in TODO.md with `Type: meta`
- Link plan artifacts to tasks
- Specify dependencies between tasks
- Allow user to review/revise plans before `/implement`

**Changes Required**:

1. **Update Stage 8 process** (`.opencode/agent/subagents/meta.md`, lines 635-1169):

   **Before**:
   ```
   Stage 8: CreateTasksWithArtifacts
   - Generate plan artifacts
   - Write to disk
   - Validate
   ```

   **After**:
   ```
   Stage 8: CreateTasksWithDependencies
   1. Determine task breakdown based on system complexity
   2. For each component group (planning, agents, commands, context):
      a. Create task entry via status-sync-manager
      b. Set Type: meta, Language: meta
      c. Specify dependencies (e.g., agents depend on planning task)
      d. Create plan artifact in task directory
      e. Link plan to task
   3. Return task list with dependency graph
   ```

2. **Add dependency tracking**:
   ```
   Task 1: Planning (no dependencies)
   Task 2: Create Agents (depends on Task 1)
   Task 3: Create Commands (depends on Task 2)
   Task 4: Create Context Files (depends on Task 1)
   Task 5: Integration Testing (depends on Tasks 2, 3, 4)
   ```

3. **Update Stage 9 output** (lines 1172-1319):
   ```
   TASKS CREATED:
   - Task 334: Design {domain} Architecture [NOT STARTED] (no dependencies)
   - Task 335: Create {agent} Agents [NOT STARTED] (depends on 334)
   - Task 336: Create {command} Commands [NOT STARTED] (depends on 335)
   - Task 337: Create Context Files [NOT STARTED] (depends on 334)
   - Task 338: Integration Testing [NOT STARTED] (depends on 335, 336, 337)
   
   NEXT STEPS:
   1. Review plan for Task 334
   2. Run /implement 334 to create architecture design
   3. Review architecture, revise if needed with /revise 334
   4. Run /implement 335 to create agents
   5. Continue with remaining tasks
   ```

**Validation**:
- Run `/meta "Create proof verification system"`
- Verify creates 4-5 tasks with dependencies
- Verify each task has plan artifact
- Verify can `/implement` each task individually
- Verify dependency order is enforced

---

### Solution 3: Specify Context Files for Meta Subagents

**Approach**: Add explicit `context_loading` sections to all meta subagents specifying exactly which context files they need.

**Changes Required**:

1. **Update `agent-generator.md`** (lines 18-27):
   ```yaml
   context_loading:
     strategy: lazy
     index: ".opencode/context/index.md"
     required:
       - "core/orchestration/delegation.md"
       - "core/standards/xml-structure.md"
       - "core/templates/subagent-template.md"
       - "core/formats/subagent-return.md"
       - "core/workflows/agent-workflow.md"           # NEW - 8-stage pattern
       - "core/standards/frontmatter-delegation.md"   # NEW - <300 line commands
       - "project/meta/architecture-principles.md"    # NEW - design principles
     optional:
       - "core/templates/agent-template.md"           # NEW - agent structure
       - "core/templates/orchestrator-template.md"    # NEW - orchestrator structure
       - "project/meta/domain-patterns.md"            # NEW - domain-specific patterns
     max_context_size: 40000
   ```

2. **Update `command-creator.md`**:
   ```yaml
   context_loading:
     strategy: lazy
     index: ".opencode/context/index.md"
     required:
       - "core/formats/command-structure.md"          # NEW - command format
       - "core/standards/frontmatter-delegation.md"   # NEW - delegation pattern
       - "core/templates/command-template.md"         # NEW - command template
     optional:
       - "project/meta/domain-patterns.md"            # NEW - domain patterns
     max_context_size: 30000
   ```

3. **Update `context-organizer.md`**:
   ```yaml
   context_loading:
     strategy: lazy
     index: ".opencode/context/index.md"
     required:
       - "project/meta/architecture-principles.md"    # NEW - modular design (50-200 lines)
       - "core/standards/context-efficiency.md"       # NEW - 80/20 Level 1/Level 2
     optional:
       - "project/meta/domain-patterns.md"            # NEW - domain-specific context
     max_context_size: 30000
   ```

4. **Update `workflow-designer.md`**:
   ```yaml
   context_loading:
     strategy: lazy
     index: ".opencode/context/index.md"
     required:
       - "core/workflows/agent-workflow.md"           # NEW - 8-stage pattern
       - "core/workflows/status-transitions.md"       # NEW - status lifecycle
       - "core/formats/plan-format.md"                # NEW - plan structure
     optional:
       - "project/meta/architecture-principles.md"    # NEW - workflow-driven design
     max_context_size: 30000
   ```

5. **Update `domain-analyzer.md`**:
   ```yaml
   context_loading:
     strategy: lazy
     index: ".opencode/context/index.md"
     required:
       - "project/meta/domain-patterns.md"            # NEW - known domain patterns
       - "project/meta/interview-patterns.md"         # NEW - question patterns
     optional:
       - "project/meta/architecture-principles.md"    # NEW - design principles
     max_context_size: 30000
   ```

**Validation**:
- Review each meta subagent's context_loading section
- Verify all referenced context files exist
- Verify context files contain relevant information
- Test meta subagent invocation loads correct files

---

### Solution 4: Add Context Revision Guidance

**Approach**: Add explicit workflow stages and guidance for when/how to revise context files.

**Changes Required**:

1. **Create new context file**: `.opencode/context/project/meta/context-revision-guide.md`
   ```markdown
   # Context File Revision Guide for Meta Agents
   
   ## When to Revise Context Files
   
   ### Update Existing File (Preferred)
   - Standard evolves (e.g., new frontmatter field required)
   - Pattern improves (e.g., better routing logic discovered)
   - Example needs updating (e.g., outdated syntax)
   - File is under 200 lines and change fits naturally
   
   ### Create New File
   - New domain pattern discovered (e.g., formal verification domain)
   - New standard introduced (e.g., new artifact type)
   - Existing file would exceed 200 lines with addition
   - Concept is orthogonal to existing files
   
   ### Split Existing File
   - File exceeds 200 lines
   - File covers multiple distinct concepts
   - File has low cohesion (unrelated sections)
   
   ## How to Revise Without Bloat
   
   ### File Size Limits
   - Target: 50-200 lines per file
   - Warning: 200-250 lines (consider splitting)
   - Error: >250 lines (must split)
   
   ### Revision Checklist
   1. Read existing file completely
   2. Identify section to update
   3. Check if change fits within 200-line limit
   4. If yes: Update in place
   5. If no: Split file or create new file
   6. Update context index with new/changed files
   7. Update dependent agents' context_loading sections
   
   ## Context File Types and Revision Patterns
   
   ### Core Standards (`.opencode/context/core/standards/`)
   **When to revise**: System-wide standard changes
   **Examples**: frontmatter-delegation.md, xml-structure.md
   **Revision pattern**: Update in place (rarely changes)
   
   ### Core Templates (`.opencode/context/core/templates/`)
   **When to revise**: Template structure changes
   **Examples**: agent-template.md, command-template.md
   **Revision pattern**: Update in place, add version notes
   
   ### Project Meta (`.opencode/context/project/meta/`)
   **When to revise**: Meta-system patterns evolve
   **Examples**: architecture-principles.md, domain-patterns.md
   **Revision pattern**: Update frequently, split if >200 lines
   
   ### Project Domain (`.opencode/context/project/{domain}/`)
   **When to revise**: Domain knowledge expands
   **Examples**: proof-theory-concepts.md, kripke-semantics-overview.md
   **Revision pattern**: Create new files for new concepts
   
   ## Revision Workflow
   
   1. **Assess Impact**:
      - Which context files are affected?
      - How many agents load these files?
      - Is this a breaking change?
   
   2. **Plan Revision**:
      - Update in place or create new file?
      - Need to split existing file?
      - Which agents need context_loading updates?
   
   3. **Execute Revision**:
      - Update/create context files
      - Update context index
      - Update agent context_loading sections
      - Test affected agents
   
   4. **Validate**:
      - All files within size limits?
      - Context index up to date?
      - Agents load correct files?
      - No broken references?
   ```

2. **Add context revision stage to meta subagents**:

   For `agent-generator.md`, add new stage after Step 5:
   ```xml
   <step_5_5>
     <name>Stage 5.5: Assess Context File Changes</name>
     <action>Determine if context files need updating</action>
     <process>
       1. Review generated agents for new patterns/standards
       2. Check if patterns exist in current context files
       3. If new pattern:
          a. Determine which context file to update
          b. Check file size (must stay under 200 lines)
          c. If fits: Update in place
          d. If doesn't fit: Create new file or split existing
       4. Update context index if files added/changed
       5. Update agent context_loading sections if needed
     </process>
     <guidance>
       Reference: .opencode/context/project/meta/context-revision-guide.md
     </guidance>
     <output>
       context_changes: {
         files_updated: [paths],
         files_created: [paths],
         files_split: [{old_path, new_paths[]}],
         index_updated: boolean,
         agents_updated: [agent_names]
       }
     </output>
   </step_5_5>
   ```

3. **Add context revision to other meta subagents**:
   - `command-creator.md`: Check if command patterns need context updates
   - `context-organizer.md`: Check if domain knowledge needs new context files
   - `workflow-designer.md`: Check if workflow patterns need context updates

**Validation**:
- Create test meta task that introduces new pattern
- Verify meta subagent assesses context file changes
- Verify updates existing file if under 200 lines
- Verify creates new file if would exceed 200 lines
- Verify updates context index
- Verify updates agent context_loading sections

---

### Solution 5: Integrate Standards Enforcement

**Approach**: Add explicit standards validation stages to meta subagents.

**Changes Required**:

1. **Create standards checklist**: `.opencode/context/project/meta/standards-checklist.md`
   ```markdown
   # Standards Checklist for Meta-Generated Artifacts
   
   ## Agent Standards
   
   ### Frontmatter
   - [ ] All required fields present (name, version, description, mode, agent_type)
   - [ ] context_loading section with strategy, index, required, optional
   - [ ] delegation section with max_depth, can_delegate_to
   - [ ] lifecycle section with stage, return_format
   - [ ] permissions section with allow/deny lists
   
   ### Structure
   - [ ] XML structure with optimal component ordering
   - [ ] <context> section (15-25% of prompt)
   - [ ] <role> section (5-10% of prompt)
   - [ ] <task> section (clear objective)
   - [ ] <workflow_execution> with 8 stages
   - [ ] <constraints> with must/must_not
   - [ ] <validation_checks> with pre/post execution
   
   ### Workflow
   - [ ] 8-stage workflow pattern followed
   - [ ] Stage 7 (Postflight) includes status updates and git commit
   - [ ] Each stage has action, process, validation, checkpoint
   - [ ] Delegation uses @ symbol pattern
   - [ ] Context levels specified for all routes
   
   ### File Size
   - [ ] Commands: <300 lines (frontmatter delegation)
   - [ ] Agents: 200-600 lines (target 400)
   - [ ] Context files: 50-200 lines (target 150)
   
   ## Command Standards
   
   ### Frontmatter
   - [ ] name, agent, description fields
   - [ ] context_level specified
   - [ ] routing section with default agent
   - [ ] context_loading section
   - [ ] timeout specified
   
   ### Structure
   - [ ] <300 lines total (frontmatter delegation)
   - [ ] High-level workflow description
   - [ ] Delegates to agent for execution
   - [ ] Usage examples
   - [ ] Artifact documentation
   
   ## Context File Standards
   
   ### Size
   - [ ] 50-200 lines (target 150)
   - [ ] Split if exceeds 200 lines
   
   ### Organization
   - [ ] Single responsibility per file
   - [ ] Clear naming (descriptive, not generic)
   - [ ] No duplication across files
   - [ ] Dependencies documented
   
   ### Content
   - [ ] Examples for every concept
   - [ ] Clear section headers
   - [ ] Markdown formatting
   - [ ] Version and last updated date
   
   ## Workflow Standards
   
   ### Structure
   - [ ] 100-300 lines (target 200)
   - [ ] Clear stages with prerequisites
   - [ ] Success criteria defined
   - [ ] Context dependencies listed
   - [ ] Checkpoints included
   
   ## Validation Process
   
   1. **Pre-Generation**: Review standards before generating
   2. **Post-Generation**: Validate each artifact against checklist
   3. **Scoring**: Must score 8+/10 to pass
   4. **Remediation**: Fix issues before returning artifacts
   ```

2. **Add standards validation stage to `agent-generator.md`**:
   ```xml
   <step_5>
     <name>Stage 5: Validate Against Standards</name>
     <action>Validate all agents against standards checklist</action>
     <process>
       1. Load standards checklist from context
       2. For each agent (orchestrator + subagents):
          a. Validate frontmatter completeness
          b. Validate XML structure and component ordering
          c. Validate 8-stage workflow pattern
          d. Validate file size within limits
          e. Validate delegation patterns (@ symbol, context levels)
          f. Score against 10-point criteria
       3. If any agent scores <8/10:
          a. Log issues and recommendations
          b. Remediate issues
          c. Re-validate
       4. Generate validation report
     </process>
     <standards_reference>
       - .opencode/context/project/meta/standards-checklist.md
       - .opencode/context/core/workflows/agent-workflow.md
       - .opencode/context/core/standards/frontmatter-delegation.md
       - .opencode/docs/STANDARDS_QUICK_REF.md
     </standards_reference>
     <output>
       validation_report: {
         orchestrator: {score, issues[], remediated[]},
         subagents: [{name, score, issues[], remediated[]}],
         overall_score: number,
         passed: boolean
       }
     </output>
   </step_5>
   ```

3. **Add standards validation to other meta subagents**:
   - `command-creator.md`: Validate commands against command standards
   - `context-organizer.md`: Validate context files against context standards
   - `workflow-designer.md`: Validate workflows against workflow standards

4. **Update meta agent to reference standards**:
   Add to `context_loading` section:
   ```yaml
   optional:
     - "project/meta/standards-checklist.md"
     - "docs/STANDARDS_QUICK_REF.md"
   ```

**Validation**:
- Generate test agent with intentional standards violations
- Verify meta subagent detects violations
- Verify meta subagent remediates issues
- Verify final artifacts pass standards validation
- Verify validation report includes scores and issues

---

## Implementation Phases

### Phase 1: Meta Task Routing (2-3 hours)

**Goal**: Enable meta tasks to route correctly during `/implement`

**Tasks**:
1. Update `/implement` command frontmatter with `meta: meta` routing
2. Update Stage 1 routing logic documentation
3. Update routing table in command documentation
4. Test meta task routing

**Validation**:
- Create test meta task
- Run `/implement {task_number}`
- Verify routes to `meta` agent
- Verify meta subagents are invoked

**Artifacts**:
- Updated `.opencode/command/implement.md`
- Test results

---

### Phase 2: Task-Based Workflow (4-5 hours)

**Goal**: Convert `/meta` to create tasks with dependencies instead of direct implementations

**Tasks**:
1. Update Stage 8 to create task entries via status-sync-manager
2. Add dependency tracking logic
3. Update Stage 9 output format
4. Update command documentation
5. Test task creation with dependencies

**Validation**:
- Run `/meta "Create test system"`
- Verify creates 4-5 tasks with dependencies
- Verify each task has plan artifact
- Verify can `/implement` each task individually
- Verify TODO.md and state.json updated correctly

**Artifacts**:
- Updated `.opencode/agent/subagents/meta.md` (Stage 8, Stage 9)
- Updated `.opencode/command/meta.md` (documentation)
- Test results

---

### Phase 3: Context File Specification (2-3 hours)

**Goal**: Specify exact context files for each meta subagent

**Tasks**:
1. Update `agent-generator.md` context_loading
2. Update `command-creator.md` context_loading
3. Update `context-organizer.md` context_loading
4. Update `workflow-designer.md` context_loading
5. Update `domain-analyzer.md` context_loading
6. Verify all referenced context files exist
7. Test context loading

**Validation**:
- Review each meta subagent's context_loading section
- Verify all referenced files exist
- Run meta subagent and verify correct files loaded
- Measure context usage (should be <40KB per subagent)

**Artifacts**:
- Updated `.opencode/agent/subagents/meta/*.md` (all 5 subagents)
- Context loading test results

---

### Phase 4: Context Revision Guidance (3-4 hours)

**Goal**: Add guidance for when/how to revise context files

**Tasks**:
1. Create `context-revision-guide.md`
2. Add context revision stage to `agent-generator.md`
3. Add context revision stage to `command-creator.md`
4. Add context revision stage to `context-organizer.md`
5. Add context revision stage to `workflow-designer.md`
6. Test context revision workflow

**Validation**:
- Create test meta task with new pattern
- Verify meta subagent assesses context changes
- Verify updates existing file if under 200 lines
- Verify creates new file if would exceed 200 lines
- Verify updates context index and agent context_loading

**Artifacts**:
- New `.opencode/context/project/meta/context-revision-guide.md`
- Updated `.opencode/agent/subagents/meta/*.md` (4 subagents)
- Test results

---

### Phase 5: Standards Enforcement (3-4 hours)

**Goal**: Integrate standards validation into meta subagents

**Tasks**:
1. Create `standards-checklist.md`
2. Add standards validation stage to `agent-generator.md`
3. Add standards validation to `command-creator.md`
4. Add standards validation to `context-organizer.md`
5. Add standards validation to `workflow-designer.md`
6. Update meta agent context_loading to include standards
7. Test standards validation

**Validation**:
- Generate test agent with intentional violations
- Verify meta subagent detects violations
- Verify meta subagent remediates issues
- Verify final artifacts pass validation
- Verify validation report is comprehensive

**Artifacts**:
- New `.opencode/context/project/meta/standards-checklist.md`
- Updated `.opencode/agent/subagents/meta/*.md` (4 subagents)
- Updated `.opencode/agent/subagents/meta.md` (context_loading)
- Test results

---

## Testing Strategy

### Unit Tests

1. **Meta Task Routing**:
   - Create meta task with `language: meta`
   - Run `/implement {task_number}`
   - Verify routes to `meta` agent

2. **Task Creation**:
   - Run `/meta "Create test system"`
   - Verify creates tasks with dependencies
   - Verify plan artifacts linked

3. **Context Loading**:
   - Invoke each meta subagent
   - Verify loads correct context files
   - Measure context usage

4. **Context Revision**:
   - Create meta task with new pattern
   - Verify assesses context changes
   - Verify updates/creates files correctly

5. **Standards Validation**:
   - Generate agent with violations
   - Verify detects and remediates
   - Verify final artifacts pass

### Integration Tests

1. **End-to-End Meta Workflow**:
   - Run `/meta "Create proof verification system"`
   - Verify creates 4-5 tasks with dependencies
   - Run `/implement` on each task in order
   - Verify all artifacts created correctly
   - Verify context files updated appropriately
   - Verify standards enforced throughout

2. **Context Evolution**:
   - Run meta workflow that introduces new pattern
   - Verify context files updated
   - Run second meta workflow using new pattern
   - Verify pattern is reused correctly

3. **Standards Enforcement**:
   - Generate multiple agents/commands
   - Verify all follow current standards
   - Verify validation reports are accurate

### Regression Tests

1. **Existing Meta Functionality**:
   - Run `/meta` in interactive mode
   - Verify interview process works
   - Verify can create simple system

2. **Lean Task Routing**:
   - Create lean task
   - Run `/implement {task_number}`
   - Verify still routes to `lean-implementation-agent`

3. **General Task Routing**:
   - Create general task
   - Run `/implement {task_number}`
   - Verify still routes to `implementer`

---

## Rollback Plan

### If Phase 1 Fails (Meta Task Routing)
- Revert `/implement` command changes
- Meta tasks will route to `implementer` (current behavior)
- No data loss

### If Phase 2 Fails (Task-Based Workflow)
- Revert `meta.md` Stage 8 and Stage 9 changes
- `/meta` will create plan artifacts directly (current behavior)
- No data loss

### If Phase 3 Fails (Context File Specification)
- Revert meta subagent context_loading changes
- Subagents will load generic context (current behavior)
- No data loss

### If Phase 4 Fails (Context Revision Guidance)
- Remove `context-revision-guide.md`
- Remove context revision stages from subagents
- Context files remain static (current behavior)
- No data loss

### If Phase 5 Fails (Standards Enforcement)
- Remove `standards-checklist.md`
- Remove standards validation stages from subagents
- No automatic standards enforcement (current behavior)
- No data loss

---

## Success Criteria

### Functional Requirements

1. **Meta Task Routing**:
   - [ ] Meta tasks route to `meta` agent during `/implement`
   - [ ] Lean tasks still route to `lean-implementation-agent`
   - [ ] General tasks still route to `implementer`

2. **Task-Based Workflow**:
   - [ ] `/meta` creates 4-5 tasks with dependencies
   - [ ] Each task has plan artifact
   - [ ] Can `/implement` each task individually
   - [ ] Dependencies are enforced

3. **Context Precision**:
   - [ ] Each meta subagent specifies exact context files needed
   - [ ] All referenced context files exist
   - [ ] Context usage <40KB per subagent

4. **Context Evolution**:
   - [ ] Meta subagents assess context file changes
   - [ ] Update existing files if under 200 lines
   - [ ] Create new files if would exceed 200 lines
   - [ ] Update context index and agent context_loading

5. **Standards Enforcement**:
   - [ ] Meta subagents validate against standards checklist
   - [ ] Detect violations and remediate
   - [ ] Final artifacts score 8+/10
   - [ ] Validation reports are comprehensive

### Non-Functional Requirements

1. **Performance**:
   - [ ] Meta task routing adds <1s overhead
   - [ ] Task creation completes in <30s
   - [ ] Context loading adds <2s overhead
   - [ ] Standards validation adds <5s overhead

2. **Maintainability**:
   - [ ] All changes documented
   - [ ] Test coverage >80%
   - [ ] Code follows existing patterns
   - [ ] No breaking changes to existing functionality

3. **Usability**:
   - [ ] Clear error messages
   - [ ] Helpful validation reports
   - [ ] Good documentation
   - [ ] Examples provided

---

## Risks and Mitigations

### Risk 1: Breaking Existing Meta Functionality
**Likelihood**: Medium  
**Impact**: High  
**Mitigation**:
- Comprehensive regression testing
- Rollback plan for each phase
- Test existing meta workflows before and after changes

### Risk 2: Context File Bloat
**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation**:
- Enforce 200-line limit in context revision guide
- Add validation for file sizes
- Regular context file audits

### Risk 3: Standards Drift
**Likelihood**: Low  
**Impact**: High  
**Mitigation**:
- Standards checklist as single source of truth
- Automated validation in meta subagents
- Regular standards review process

### Risk 4: Performance Degradation
**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**:
- Lazy context loading
- Context usage monitoring
- Performance benchmarks before/after

### Risk 5: Complexity Increase
**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation**:
- Clear documentation
- Examples for each feature
- Gradual rollout (phase by phase)

---

## Dependencies

### Internal Dependencies
- `status-sync-manager`: For atomic task creation
- `git-workflow-manager`: For git commits
- Context index: Must be up to date
- Standards documentation: Must be current

### External Dependencies
- None

---

## Timeline

### Week 1
- **Day 1-2**: Phase 1 (Meta Task Routing)
- **Day 3-5**: Phase 2 (Task-Based Workflow)

### Week 2
- **Day 1-2**: Phase 3 (Context File Specification)
- **Day 3-4**: Phase 4 (Context Revision Guidance)
- **Day 5**: Phase 5 (Standards Enforcement)

### Week 3
- **Day 1-2**: Integration testing
- **Day 3**: Regression testing
- **Day 4**: Documentation updates
- **Day 5**: Final review and deployment

**Total**: 12-16 hours over 3 weeks

---

## Documentation Updates

### Files to Update

1. **`.opencode/command/meta.md`**:
   - Update workflow description
   - Add task-based workflow documentation
   - Add dependency tracking examples

2. **`.opencode/command/implement.md`**:
   - Add meta routing documentation
   - Update routing table

3. **`.opencode/context/project/meta/meta-guide.md`**:
   - Add task-based workflow section
   - Add context revision section
   - Add standards enforcement section

4. **`.opencode/docs/STANDARDS_QUICK_REF.md`**:
   - Add meta task standards
   - Add context file standards

### New Files to Create

1. **`.opencode/context/project/meta/context-revision-guide.md`**:
   - When to revise context files
   - How to avoid bloat
   - Revision workflow

2. **`.opencode/context/project/meta/standards-checklist.md`**:
   - Agent standards
   - Command standards
   - Context file standards
   - Workflow standards

---

## Monitoring and Metrics

### Metrics to Track

1. **Meta Task Success Rate**:
   - % of meta tasks that complete successfully
   - Target: >90%

2. **Context File Size**:
   - Average context file size
   - % of files >200 lines
   - Target: <10% over 200 lines

3. **Standards Compliance**:
   - Average validation score
   - % of artifacts scoring 8+/10
   - Target: >95% score 8+/10

4. **Task Dependency Accuracy**:
   - % of tasks with correct dependencies
   - Target: 100%

5. **Context Loading Efficiency**:
   - Average context usage per subagent
   - Target: <40KB per subagent

### Monitoring Tools

1. **Validation Reports**: Track scores and issues
2. **Context Usage Logs**: Track context file loading
3. **Task Dependency Graph**: Visualize dependencies
4. **Standards Compliance Dashboard**: Track compliance over time

---

## Conclusion

This implementation plan addresses all five critical issues with the `/meta` command system:

1. **Meta task routing**: Enables meta tasks to route correctly during `/implement`
2. **Task-based workflow**: Allows user to review/revise plans before implementation
3. **Context precision**: Ensures meta subagents have exactly the context they need
4. **Context evolution**: Provides guidance for maintaining context files without bloat
5. **Standards enforcement**: Integrates standards validation into meta subagents

The plan is structured in 5 phases with clear validation criteria, rollback plans, and success metrics. Total estimated effort is 12-16 hours over 3 weeks.

**Next Steps**:
1. Review this plan
2. Revise if needed
3. Create tasks for each phase
4. Begin implementation with Phase 1

---

**Plan Version**: 1.0  
**Author**: Claude (OpenAgents Meta Builder)  
**Review Status**: DRAFT - Awaiting User Review
