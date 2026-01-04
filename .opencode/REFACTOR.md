---
status: [IN PROGRESS]
created: 2026-01-03T19:00:00Z
last_updated: 2026-01-03T19:30:00Z
version: 1.1
project: 001_proofchecker_opencode_rebuild
revision_notes: "Added lean-planner subagent and expanded language-based routing to /plan and /revise commands per DESIGN.md FIX comment"
---

# Implementation Plan: ProofChecker .opencode System Rebuild

**Project**: ProofChecker .opencode System Rebuild
**Plan**: implementation-001
**Status**: [IN PROGRESS]
**Created**: 2026-01-03
**Target System**: /home/benjamin/Projects/ProofChecker/.opencode

## Executive Summary

This plan provides a comprehensive roadmap for rebuilding the ProofChecker .opencode system based on the design specification at `/home/benjamin/Projects/ProofChecker/.opencode/specs/DESIGN.md`. The current system has become bloated and certain changes have prevented it from working correctly. This rebuild will implement the orchestrator-centric design with proper context window protection, language-based routing, atomic state updates, and standardized workflows.

The rebuild is structured in 10 phases spanning approximately 85-110 hours of work. Each phase is designed to be independently testable with clear rollback points. The majority of work will be carried out by subagents to protect the orchestrator's context, with work directed using commands in Orchestrator agent mode.

**Key Objectives**:
1. Consolidate context directories (common/ → core/) per task 265
2. Implement proper 5-stage orchestrator workflow
3. Establish language-based routing for Lean 4 tasks across all workflow commands (/research, /plan, /revise, /implement)
4. Create lean-planner subagent for Lean-specific planning
5. Ensure atomic state updates via status-sync-manager
6. Implement lazy artifact management
7. Create comprehensive testing and validation framework

## Research Inputs

**Primary Design Document**:
- `/home/benjamin/Projects/ProofChecker/.opencode/specs/DESIGN.md` - Comprehensive system design specification (v1.0, 2026-01-03)

**Key Design Principles from DESIGN.md**:
1. **Orchestrator-Centric Design**: All commands route through orchestrator to subagents
2. **Context Window Protection**: Lazy loading, metadata passing, frontmatter delegation (60-70% reduction target)
3. **Standardized Pre/Post-Flight**: 5-stage lifecycle (PreflightValidation, DetermineRouting, RegisterAndDelegate, ValidateReturn, PostflightCleanup)
4. **Language-Based Routing**: Automatic routing based on task language for all workflow commands (/research, /plan, /revise, /implement). Lean tasks route to lean-research-agent, lean-planner, and lean-implementation-agent; general tasks route to researcher, planner, and implementer.
5. **Atomic State Updates**: Two-phase commit via status-sync-manager
6. **Lazy Artifact Management**: No pre-creation of directories or placeholder files

**Current System State**:
- Orchestrator: `.opencode/agent/orchestrator.md` (version 5.0)
- Context split between `core/` and `common/` (needs consolidation)
- Multiple subagents in `.opencode/agent/subagents/`
- Commands in `.opencode/command/`
- State management via `.opencode/specs/state.json` and `TODO.md`
- Next project number: 271

## Scope

**In Scope**:
1. Context directory restructuring (common/ → core/)
2. Orchestrator 5-stage workflow verification and refinement
3. Command system frontmatter delegation verification
4. Subagent compliance with return format and lazy creation
5. Status-sync-manager atomic update verification
6. Language-based routing implementation
7. Artifact management pattern enforcement
8. Testing and validation framework
9. Documentation updates

**Out of Scope**:
1. Lean 4 proof system implementation
2. New feature development beyond DESIGN.md specification
3. Performance optimization beyond context window protection
4. UI/UX improvements
5. Integration with external systems beyond existing MCP tools

## Dependencies

**External Dependencies**:
- OpenCode CLI (for command execution)
- Git (for version control and commits)
- Bash (for testing scripts)
- Python 3.12+ (for validation scripts)

**Internal Dependencies**:
- Existing ProofChecker codebase at `/home/benjamin/Projects/ProofChecker/`
- DESIGN.md specification
- Current state.json and TODO.md files

## Implementation Phases

### Phase 1: Context Directory Restructuring [COMPLETED]

**Objective**: Consolidate `common/` into `core/` and reorganize context files per DESIGN.md structure

**Tasks**:
- [ ] Audit current context directory structure
  - Map all files in `context/common/` to target locations in `context/core/`
  - Identify any files in `context/core/` that need reorganization
  - Document current vs. target structure
- [ ] Create migration mapping document
  - List all files to be moved with source → destination paths
  - Identify files that need merging or splitting
  - Note any files to be deprecated or removed
- [ ] Execute file migrations
  - Move `core/standards/` → `core/standards/`
  - Move `core/system/` → `core/system/`
  - Move `core/workflows/` → `core/workflows/`
  - Move `core/templates/` → `core/templates/`
  - Ensure `project/` structure remains: `lean4/`, `logic/`, `repo/`, `math/`, `physics/`
- [ ] Update all references to moved files
  - Update agent frontmatter `context_loading.required` paths
  - Update command frontmatter `context_loading.required` paths
  - Update `@` references in agent/command bodies
  - Update `context/index.md` with new structure
- [ ] Remove empty `common/` directory
- [ ] Validate no broken references
  - Run grep validation for old paths
  - Test loading each context file via orchestrator
- [ ] Create git commit for context restructuring

**Deliverables**:
- Consolidated `context/core/` directory with subdirectories: `standards/`, `system/`, `templates/`, `workflows/`
- Updated `context/project/` with: `lean4/`, `logic/`, `repo/`, `math/`, `physics/`
- Updated `context/index.md` reflecting new structure
- Migration mapping document in specs/001_*/reports/
- Git commit with all changes

**Success Criteria**:
- No `context/common/` directory exists
- All context files accessible via new paths
- No broken references (grep validation passes)
- Context index accurately reflects structure
- All agents/commands load context successfully

**Estimated Effort**: 8-10 hours

**Rollback Strategy**: Git revert commit if validation fails

---

### Phase 2: Orchestrator 5-Stage Workflow Verification [COMPLETED]

**Objective**: Verify and refine orchestrator implementation of 5-stage workflow per DESIGN.md

**Tasks**:
- [ ] Audit current orchestrator.md against DESIGN.md specification
  - Verify Stage 1 (PreflightValidation) implementation
  - Verify Stage 2 (DetermineRouting) implementation
  - Verify Stage 3 (RegisterAndDelegate) implementation
  - Verify Stage 4 (ValidateReturn) implementation
  - Verify Stage 5 (PostflightCleanup) implementation
- [ ] Implement missing Stage 2 (DetermineRouting) logic
  - Add language extraction from state.json → TODO.md → default
  - Implement routing table lookup based on command frontmatter
  - Add routing validation before delegation
  - Document routing decisions in session context
- [ ] Verify minimal context loading
  - Ensure only routing-guide.md, validation-rules.md, command frontmatter loaded
  - Measure context window usage (<10% target during routing)
  - Remove any unnecessary context loading
- [ ] Verify argument parsing per command-argument-handling.md
  - Task-based commands: Parse task number, format as "Task: NNN"
  - Direct commands: Pass $ARGUMENTS as-is
  - Validate task existence before delegation
- [ ] Verify delegation safety mechanisms
  - Cycle detection implementation
  - Timeout enforcement
  - Session tracking with unique IDs
  - Depth limit enforcement (max 3)
- [ ] Add comprehensive logging for each stage
  - Log stage entry/exit
  - Log routing decisions
  - Log validation results
  - Log delegation context

**Deliverables**:
- Updated `orchestrator.md` with complete 5-stage workflow
- Implemented Stage 2 (DetermineRouting) with language-based routing
- Context loading reduced to <10% during routing
- Comprehensive stage logging
- Validation report in specs/001_*/reports/

**Success Criteria**:
- All 5 stages implemented and documented
- Stage 2 extracts language and routes correctly
- Context window usage <10% during routing stages
- Argument parsing follows standard for all command types
- Delegation safety mechanisms functional
- All stages log entry/exit and key decisions

**Estimated Effort**: 10-12 hours

**Rollback Strategy**: Revert to orchestrator.md backup if routing fails

---

### Phase 3: Command System Frontmatter Verification [COMPLETED]

**Objective**: Verify all commands use frontmatter delegation pattern and specify correct routing

**Tasks**:
- [ ] Audit all command files for frontmatter compliance
  - `/research.md` - Verify language_based routing
  - `/plan.md` - Verify language_based routing
  - `/revise.md` - Verify language_based routing (same as /plan)
  - `/implement.md` - Verify language_based routing
  - `/review.md` - Verify routing to reviewer
  - `/task.md` - Verify routing to task-executor
  - `/todo.md` - Verify routing to todo-manager
  - `/meta.md` - Verify routing to meta agent
- [ ] Verify frontmatter structure for each command
  - `name` field present
  - `agent: orchestrator` specified
  - `routing` section with language_based flag or direct agent
  - `context_loading.strategy: lazy` specified
  - `context_loading.required` lists minimal context files
- [ ] Verify routing tables in language-based commands
  - `/research`: lean → lean-research-agent, markdown/python/default → researcher
  - `/plan`: lean → lean-planner, markdown/python/default → planner
  - `/revise`: lean → lean-planner, markdown/python/default → planner (same as /plan)
  - `/implement`: lean → lean-implementation-agent, markdown/python/default → implementer
  - Validate routing table completeness for all language variants
- [ ] Update any non-compliant commands
  - Add missing frontmatter fields
  - Fix routing specifications
  - Update context loading to lazy strategy
- [ ] Test each command's routing behavior
  - Test with lean language tasks
  - Test with markdown/general tasks
  - Verify correct agent invocation

**Deliverables**:
- All 8 commands with compliant frontmatter
- Verified routing tables for language-based commands
- Command compliance report in specs/001_*/reports/
- Updated commands (if needed)

**Success Criteria**:
- All commands have complete YAML frontmatter
- All commands specify `agent: orchestrator`
- Language-based commands have routing tables
- All commands use `context_loading.strategy: lazy`
- Routing tests pass for all commands

**Estimated Effort**: 6-8 hours

**Rollback Strategy**: Revert individual command files if routing breaks

---

### Phase 4: Subagent Compliance Verification [COMPLETED]

**Objective**: Ensure all subagents comply with DESIGN.md standards for frontmatter, workflow, and return format

**Tasks**:
- [ ] Create lean-planner.md subagent if it doesn't exist
  - Based on planner.md template
  - Add Lean 4-specific planning knowledge
  - Include Lean proof strategy patterns
  - Add mathlib integration considerations
  - Add tactic pattern recommendations
- [ ] Audit all subagent files for YAML frontmatter
  - researcher.md
  - lean-research-agent.md
  - planner.md
  - lean-planner.md (newly created)
  - implementer.md
  - lean-implementation-agent.md
  - reviewer.md
  - status-sync-manager.md
  - git-workflow-manager.md
  - task-executor.md
  - meta.md (and meta/* subagents)
- [ ] Verify XML workflow structure in each subagent
  - `<workflow_execution>` wrapper
  - `<stage>` elements with id, name attributes
  - `<action>`, `<process>`, `<checkpoint>` elements
  - Clear stage progression
- [ ] Verify return format compliance
  - Returns JSON with required fields: status, task_number, artifacts, summary
  - Artifacts array contains metadata (type, path, summary)
  - Summary is brief (3-5 sentences)
  - Does NOT return full artifact content
- [ ] Verify lazy directory creation pattern
  - No pre-creation of project directories
  - No pre-creation of subdirectories (reports/, plans/, summaries/)
  - Directories created only when writing first artifact
  - No placeholder files created
- [ ] Verify status-sync-manager integration
  - All status updates use status-sync-manager
  - Atomic updates across TODO.md, state.json, project state.json
  - Two-phase commit pattern implemented
- [ ] Verify git-workflow-manager integration
  - All artifact creation triggers git commits
  - Commit messages follow standard format
  - Commits include relevant files only
- [ ] Add missing compliance elements to non-compliant subagents

**Deliverables**:
- All subagents with YAML frontmatter
- All subagents with XML workflow structure
- All subagents returning compliant JSON format
- All subagents using lazy directory creation
- All subagents integrated with status-sync-manager and git-workflow-manager
- Subagent compliance report in specs/001_*/reports/

**Success Criteria**:
- All subagents have complete YAML frontmatter
- All subagents use XML workflow structure
- All subagents return JSON with metadata only (not full content)
- No subagent pre-creates directories or placeholder files
- All status updates are atomic via status-sync-manager
- All artifact creation triggers git commits

**Estimated Effort**: 14-18 hours (includes 2-3 hours for lean-planner creation)

**Rollback Strategy**: Revert individual subagent files if functionality breaks

---

### Phase 5: Status Sync Manager Verification [COMPLETED]

**Objective**: Verify status-sync-manager implements two-phase commit for atomic updates

**Tasks**:
- [ ] Audit status-sync-manager.md implementation
  - Verify two-phase commit structure (Prepare, Commit)
  - Verify Phase 1 (Prepare) reads all files, validates transitions, prepares updates
  - Verify Phase 2 (Commit) writes files in order, verifies writes, rolls back on failure
- [ ] Verify atomic update methods
  - `mark_researched(task_number, timestamp, artifact_path)`
  - `mark_planned(task_number, timestamp, plan_path)`
  - `mark_completed(task_number, timestamp)`
  - `mark_blocked(task_number, timestamp, reason)`
- [ ] Verify rollback mechanism
  - Backup creation before updates
  - Rollback triggered on any write failure
  - Guarantee: all files updated or none updated
- [ ] Verify consistency guarantees
  - TODO.md status matches state.json status
  - Timestamps synchronized across files
  - Artifact links consistent
- [ ] Test atomic update scenarios
  - Successful update (all files updated)
  - Failed update (rollback triggered, no files changed)
  - Concurrent update handling
- [ ] Add comprehensive error handling
  - File read errors
  - File write errors
  - Validation errors
  - Rollback errors

**Deliverables**:
- Verified status-sync-manager.md with two-phase commit
- Tested atomic update methods
- Verified rollback mechanism
- Status sync verification report in specs/001_*/reports/

**Success Criteria**:
- Two-phase commit correctly implemented
- All atomic update methods functional
- Rollback mechanism prevents partial updates
- Consistency guaranteed across TODO.md, state.json, project state.json
- Error handling comprehensive and tested

**Estimated Effort**: 8-10 hours

**Rollback Strategy**: Revert status-sync-manager.md if atomic updates fail

---

### Phase 6: Artifact Management Pattern Enforcement [COMPLETED]

**Objective**: Ensure all agents follow lazy directory creation and proper artifact patterns

**Tasks**:
- [ ] Verify lazy directory creation in all agents
  - No `mkdir -p` commands before artifact creation
  - Directories created only when writing first file
  - No placeholder file creation
- [ ] Verify artifact patterns by agent type
  - Research agents: 1 report (no summary needed)
  - Planner: 1 plan (self-documenting, no summary needed)
  - Implementation agents: N files + 1 summary (required for multi-file)
- [ ] Verify summary artifact standards
  - Created ONLY for multi-file outputs
  - Kept under 100 tokens (~400 characters)
  - Does NOT duplicate content from detailed artifacts
  - Stored in `summaries/` subdirectory
- [ ] Verify artifact naming conventions
  - Research reports: `reports/research-NNN.md`
  - Plans: `plans/implementation-NNN.md`
  - Summaries: `summaries/{type}-summary-YYYYMMDD.md`
  - Implementation files: actual file paths in codebase
- [ ] Test artifact creation workflows
  - Test research workflow (single report)
  - Test planning workflow (single plan)
  - Test implementation workflow (multiple files + summary)
- [ ] Update non-compliant agents
  - Remove pre-creation logic
  - Add lazy creation logic
  - Fix artifact patterns
  - Update summary creation logic

**Deliverables**:
- All agents using lazy directory creation
- Correct artifact patterns for each agent type
- Summary artifacts meeting size and content standards
- Artifact management verification report in specs/001_*/reports/

**Success Criteria**:
- No agent pre-creates directories
- No placeholder files created
- Research agents create 1 report only
- Planner creates 1 plan only
- Implementation agents create N files + 1 summary
- Summary artifacts <100 tokens
- All artifact naming follows conventions

**Estimated Effort**: 6-8 hours

**Rollback Strategy**: Revert individual agent files if artifact creation breaks

---

### Phase 7: Language-Based Routing Implementation [COMPLETED]

**Objective**: Implement and verify language-based routing for Lean 4 and general tasks

**Tasks**:
- [ ] Implement language extraction in orchestrator Stage 2
  - Priority 1: Extract from project state.json `language` field
  - Priority 2: Extract from TODO.md task entry `**Language**` field
  - Priority 3: Default to "general" if not found
  - Log language extraction source and result
- [ ] Implement routing table lookup
  - Load routing table from command frontmatter
  - Map extracted language to target agent
  - Validate agent exists before delegation
  - Log routing decision
- [ ] Verify routing for Lean tasks
  - `/research` with lean task → lean-research-agent
  - `/plan` with lean task → lean-planner
  - `/revise` with lean task → lean-planner
  - `/implement` with lean task → lean-implementation-agent
  - Verify Lean-specific tool integration (LeanExplore, Loogle, LeanSearch)
- [ ] Verify routing for general tasks
  - `/research` with markdown task → researcher
  - `/plan` with markdown task → planner
  - `/revise` with markdown task → planner
  - `/implement` with markdown task → implementer
  - Verify general tool integration (webfetch, bash, etc.)
- [ ] Test routing edge cases
  - Task with no language specified (defaults to general)
  - Task with unsupported language (error handling)
  - Task with language in state.json but not TODO.md
  - Task with language in TODO.md but not state.json
- [ ] Add routing validation and error handling
  - Validate language value is supported
  - Validate target agent exists
  - Provide clear error messages for routing failures

**Deliverables**:
- Implemented language extraction in orchestrator Stage 2
- Implemented routing table lookup and agent mapping
- Verified routing for lean and general tasks
- Routing verification report in specs/001_*/reports/

**Success Criteria**:
- Language extracted from state.json → TODO.md → default
- Routing table correctly maps language to agent
- Lean tasks route to lean-research-agent, lean-planner, and lean-implementation-agent
- General tasks route to researcher, planner, and implementer
- All four language-based commands (/research, /plan, /revise, /implement) route correctly
- Edge cases handled gracefully
- Routing decisions logged for debugging

**Estimated Effort**: 8-10 hours

**Rollback Strategy**: Revert orchestrator.md Stage 2 if routing fails

---

### Phase 8: Testing and Validation Framework [NOT STARTED]

**Objective**: Create comprehensive testing framework to validate system behavior

**Tasks**:
- [ ] Create test cases for each command
  - `/research` test cases (lean and general)
  - `/plan` test cases (lean and general)
  - `/revise` test cases (lean and general)
  - `/implement` test cases (lean and general)
  - `/review` test cases
  - `/task` test cases
  - `/todo` test cases
  - `/meta` test cases
- [ ] Create context window usage measurement script
  - Measure orchestrator context during routing (<10% target)
  - Measure subagent context during execution
  - Compare before/after rebuild
  - Generate usage report
- [ ] Create language-based routing test script
  - Test lean task routing
  - Test general task routing
  - Test edge cases
  - Validate routing decisions
- [ ] Create atomic status update test script
  - Test successful atomic update
  - Test failed update with rollback
  - Test consistency across files
  - Validate two-phase commit
- [ ] Create artifact creation pattern test script
  - Test lazy directory creation
  - Test artifact patterns (research, plan, implementation)
  - Test summary artifact creation
  - Validate no pre-creation or placeholders
- [ ] Create git commit verification script
  - Test commit creation for each artifact type
  - Validate commit messages
  - Verify commit contents
- [ ] Run full test suite and document results
  - Execute all test scripts
  - Document pass/fail for each test
  - Identify and fix any failures
  - Generate comprehensive test report

**Deliverables**:
- Test cases for all 8 commands
- Context window usage measurement script
- Language-based routing test script
- Atomic status update test script
- Artifact creation pattern test script
- Git commit verification script
- Comprehensive test report in specs/001_*/reports/

**Success Criteria**:
- All command test cases pass
- Context window usage <10% during routing
- Language-based routing tests pass 100%
- Atomic status update tests pass 100%
- Artifact creation pattern tests pass 100%
- Git commit verification tests pass 100%
- Test report documents all results

**Estimated Effort**: 12-15 hours

**Rollback Strategy**: Fix identified issues or revert to previous phase

---

### Phase 9: Documentation Updates [NOT STARTED]

**Objective**: Update all documentation to reflect rebuilt system architecture

**Tasks**:
- [ ] Update README.md
  - Add system overview section
  - Document 5-stage orchestrator workflow
  - Document language-based routing
  - Document command usage with examples
  - Add troubleshooting section
- [ ] Update or create ARCHITECTURE.md
  - Document orchestrator-centric design
  - Document context window protection strategies
  - Document atomic state update mechanism
  - Document artifact management patterns
  - Include architecture diagrams
- [ ] Create QUICK-START.md
  - Installation and setup instructions
  - Basic command usage examples
  - Common workflows (research → plan → implement)
  - Troubleshooting common issues
- [ ] Update context/README.md
  - Document core/ vs project/ organization
  - Document context loading strategy
  - Document context index usage
  - Provide context file organization guide
- [ ] Update DESIGN.md
  - Mark implementation status for each component
  - Add "Implementation Notes" section
  - Document any deviations from original design
  - Add lessons learned
- [ ] Create migration guide
  - Document changes from old to new system
  - Provide migration checklist
  - Document breaking changes
  - Provide rollback instructions
- [ ] Update agent and command inline documentation
  - Ensure all frontmatter is documented
  - Ensure all stages are documented
  - Add usage examples where helpful

**Deliverables**:
- Updated README.md with system overview
- Updated or created ARCHITECTURE.md
- Created QUICK-START.md
- Updated context/README.md
- Updated DESIGN.md with implementation status
- Created migration guide
- Updated inline documentation

**Success Criteria**:
- README.md provides clear system overview
- ARCHITECTURE.md documents all design decisions
- QUICK-START.md enables new users to get started
- context/README.md explains organization
- DESIGN.md reflects implementation status
- Migration guide provides clear upgrade path
- All documentation is accurate and up-to-date

**Estimated Effort**: 10-12 hours

**Rollback Strategy**: Revert documentation files if inaccuracies found

---

### Phase 10: Integration Testing and Validation [NOT STARTED]

**Objective**: Perform end-to-end integration testing and validate complete system

**Tasks**:
- [ ] Execute complete workflow tests
  - Test full research → plan → implement workflow for lean task
  - Test full research → plan → implement workflow for general task
  - Test review workflow
  - Test task creation and management workflow
  - Test meta workflow
- [ ] Validate context window protection
  - Measure orchestrator context usage across all commands
  - Verify <10% usage during routing
  - Verify 60-70% reduction vs. old system
  - Document measurements
- [ ] Validate atomic state updates
  - Test status transitions across all workflows
  - Verify TODO.md, state.json, project state.json consistency
  - Test rollback scenarios
  - Document results
- [ ] Validate artifact management
  - Verify lazy directory creation across all workflows
  - Verify correct artifact patterns
  - Verify no pre-creation or placeholders
  - Document results
- [ ] Validate language-based routing
  - Test routing for multiple lean tasks
  - Test routing for multiple general tasks
  - Verify correct agent invocation
  - Document results
- [ ] Validate git commit creation
  - Verify commits created for all artifact types
  - Verify commit messages follow standard
  - Verify commit contents are correct
  - Document results
- [ ] Perform stress testing
  - Test with multiple concurrent tasks
  - Test with large artifacts
  - Test with complex workflows
  - Document performance
- [ ] Create final validation report
  - Summarize all test results
  - Document any issues found and resolutions
  - Provide system health assessment
  - Include recommendations for future improvements

**Deliverables**:
- Complete workflow test results
- Context window usage measurements
- Atomic state update validation results
- Artifact management validation results
- Language-based routing validation results
- Git commit validation results
- Stress test results
- Final validation report in specs/001_*/reports/

**Success Criteria**:
- All workflow tests pass
- Context window usage <10% during routing
- 60-70% reduction vs. old system achieved
- Atomic state updates 100% consistent
- Artifact management 100% compliant
- Language-based routing 100% accurate
- Git commits created correctly
- Stress tests show acceptable performance
- Final validation report shows system health

**Estimated Effort**: 15-18 hours

**Rollback Strategy**: Address critical issues or revert to last stable phase

---

## Complexity Assessment

**Overall Complexity**: High

**Complexity Factors**:
1. **Scope**: 10 phases spanning entire .opencode system
2. **Interdependencies**: Many components depend on each other (orchestrator → commands → subagents)
3. **State Management**: Complex atomic update requirements
4. **Testing**: Comprehensive testing across all components
5. **Documentation**: Extensive documentation updates required

**Complexity by Phase**:
- Phase 1 (Context Restructuring): Medium - File moves with reference updates
- Phase 2 (Orchestrator Workflow): High - Core routing logic implementation
- Phase 3 (Command Verification): Low - Mostly verification with minor updates
- Phase 4 (Subagent Compliance): High - Multiple agents with complex requirements
- Phase 5 (Status Sync Manager): Medium - Verification of existing implementation
- Phase 6 (Artifact Management): Medium - Pattern enforcement across agents
- Phase 7 (Language Routing): High - New routing logic implementation
- Phase 8 (Testing Framework): High - Comprehensive test creation
- Phase 9 (Documentation): Medium - Extensive but straightforward
- Phase 10 (Integration Testing): High - End-to-end validation

**Mitigation Strategies**:
1. **Phased Approach**: Each phase is independently testable with rollback points
2. **Incremental Testing**: Test after each phase before proceeding
3. **Comprehensive Logging**: Add logging at all critical points for debugging
4. **Backup Strategy**: Git commits after each phase for easy rollback
5. **Validation Scripts**: Automated validation to catch issues early

## Risk Analysis

### High-Risk Areas

**Risk 1: Context Directory Restructuring Breaking References**
- **Impact**: High - Could break all agents and commands
- **Probability**: Medium
- **Mitigation**: 
  - Create comprehensive mapping document before migration
  - Use grep validation to find all references
  - Test context loading after migration
  - Keep backup of old structure
- **Rollback**: Git revert to pre-migration state

**Risk 2: Orchestrator Stage 2 Implementation Breaking Routing**
- **Impact**: High - Could prevent all commands from executing
- **Probability**: Medium
- **Mitigation**:
  - Implement Stage 2 incrementally
  - Test with simple cases first
  - Add comprehensive logging
  - Keep fallback to default routing
- **Rollback**: Revert orchestrator.md to previous version

**Risk 3: Atomic State Updates Causing Data Loss**
- **Impact**: Critical - Could corrupt TODO.md and state.json
- **Probability**: Low
- **Mitigation**:
  - Verify two-phase commit implementation thoroughly
  - Test rollback mechanism extensively
  - Create backups before all updates
  - Add validation before commit phase
- **Rollback**: Restore from backup files

**Risk 4: Language-Based Routing Sending Tasks to Wrong Agents**
- **Impact**: Medium - Tasks executed by wrong agent
- **Probability**: Medium
- **Mitigation**:
  - Test routing with known lean and general tasks
  - Add routing validation before delegation
  - Log all routing decisions
  - Provide manual override mechanism
- **Rollback**: Revert to default routing

### Medium-Risk Areas

**Risk 5: Subagent Return Format Changes Breaking Orchestrator**
- **Impact**: Medium - Could prevent orchestrator from processing results
- **Probability**: Low
- **Mitigation**:
  - Verify return format compliance before changes
  - Test orchestrator validation with new formats
  - Add backward compatibility if needed
- **Rollback**: Revert subagent changes

**Risk 6: Lazy Directory Creation Failing**
- **Impact**: Low - Artifacts not created
- **Probability**: Low
- **Mitigation**:
  - Test directory creation in isolation
  - Add error handling for mkdir failures
  - Validate directory exists after creation
- **Rollback**: Revert to pre-creation pattern temporarily

**Risk 7: Testing Framework Incomplete**
- **Impact**: Medium - Issues not caught before deployment
- **Probability**: Medium
- **Mitigation**:
  - Create comprehensive test plan
  - Review test coverage
  - Add tests for edge cases
  - Perform manual testing in addition to automated
- **Rollback**: N/A - Add missing tests

### Low-Risk Areas

**Risk 8: Documentation Inaccuracies**
- **Impact**: Low - User confusion
- **Probability**: Medium
- **Mitigation**:
  - Review documentation against implementation
  - Test examples in documentation
  - Get peer review of documentation
- **Rollback**: Update documentation

**Risk 9: Git Commit Creation Failures**
- **Impact**: Low - Missing commit history
- **Probability**: Low
- **Mitigation**:
  - Test git-workflow-manager thoroughly
  - Add error handling for git failures
  - Validate commits created
- **Rollback**: Manual commit creation

## Success Criteria

### Phase-Level Success Criteria

Each phase has specific success criteria documented in the phase description above.

### Overall Success Criteria

**Functional Requirements**:
1. All 8 commands execute successfully via orchestrator
2. Language-based routing correctly routes lean tasks to lean-specific agents
3. Atomic state updates maintain consistency across TODO.md, state.json, project state.json
4. Lazy artifact management creates directories only when needed
5. Git commits created for all artifact types
6. Context window usage <10% during orchestrator routing stages

**Performance Requirements**:
1. 60-70% context window reduction vs. old system
2. No performance degradation in command execution time
3. Atomic state updates complete in <1 second

**Quality Requirements**:
1. All test cases pass (100% pass rate)
2. No broken references after context restructuring
3. All documentation accurate and up-to-date
4. Code follows DESIGN.md standards

**Validation Requirements**:
1. Final validation report shows system health
2. Integration tests pass for all workflows
3. Stress tests show acceptable performance
4. No critical issues in final validation

## Testing Strategy

### Unit Testing

**Orchestrator Testing**:
- Test each stage independently
- Test argument parsing for all command types
- Test language extraction from various sources
- Test routing table lookup
- Test delegation safety mechanisms

**Command Testing**:
- Test frontmatter parsing
- Test routing specification
- Test context loading
- Test argument handling

**Subagent Testing**:
- Test workflow execution
- Test return format
- Test lazy directory creation
- Test status-sync-manager integration
- Test git-workflow-manager integration

### Integration Testing

**Workflow Testing**:
- Test research → plan → implement workflow
- Test review workflow
- Test task creation workflow
- Test meta workflow

**State Management Testing**:
- Test atomic state updates
- Test rollback mechanism
- Test consistency across files

**Routing Testing**:
- Test language-based routing
- Test direct routing
- Test routing edge cases

### System Testing

**End-to-End Testing**:
- Execute complete workflows from user command to artifact creation
- Verify all components work together
- Test with real-world scenarios

**Performance Testing**:
- Measure context window usage
- Measure command execution time
- Measure state update time
- Compare with old system

**Stress Testing**:
- Test with multiple concurrent tasks
- Test with large artifacts
- Test with complex workflows

### Validation Testing

**Compliance Testing**:
- Verify all components follow DESIGN.md standards
- Verify all agents use correct patterns
- Verify all artifacts follow naming conventions

**Regression Testing**:
- Verify no existing functionality broken
- Verify backward compatibility where needed
- Test previously working workflows

## Rollback Strategy

### Phase-Level Rollback

Each phase includes a specific rollback strategy:
- Git revert to pre-phase commit
- Restore backup files if needed
- Revert individual files if only partial changes

### System-Level Rollback

If critical issues found during integration testing:

**Option 1: Rollback to Last Stable Phase**
1. Identify last stable phase
2. Git revert to that phase's commit
3. Document issues found
4. Plan fixes for next iteration

**Option 2: Rollback to Pre-Rebuild State**
1. Git revert all rebuild commits
2. Restore from full system backup
3. Document all issues found
4. Revise implementation plan
5. Schedule new rebuild attempt

**Option 3: Partial Rollback**
1. Identify specific component causing issues
2. Revert only that component
3. Keep other improvements
4. Fix component in isolation
5. Re-integrate when fixed

### Backup Strategy

**Before Each Phase**:
1. Create git commit with current state
2. Tag commit with phase number
3. Create backup of critical files (state.json, TODO.md)

**Before Integration Testing**:
1. Create full system backup
2. Tag git commit as "pre-integration"
3. Document system state

## Estimated Timeline

**Total Estimated Effort**: 87-113 hours

**Phase Breakdown**:
- Phase 1: 8-10 hours
- Phase 2: 10-12 hours
- Phase 3: 6-8 hours
- Phase 4: 14-18 hours (includes lean-planner creation)
- Phase 5: 8-10 hours
- Phase 6: 6-8 hours
- Phase 7: 8-10 hours
- Phase 8: 12-15 hours
- Phase 9: 10-12 hours
- Phase 10: 15-18 hours

**Recommended Schedule** (assuming 10 hours/week):
- Week 1: Phase 1 (Context Restructuring)
- Week 2: Phase 2 (Orchestrator Workflow)
- Week 3: Phase 3 (Command Verification) + Phase 4 start
- Week 4: Phase 4 (Subagent Compliance) completion
- Week 5: Phase 5 (Status Sync) + Phase 6 (Artifact Management)
- Week 6: Phase 7 (Language Routing)
- Week 7: Phase 8 (Testing Framework)
- Week 8: Phase 9 (Documentation)
- Week 9-10: Phase 10 (Integration Testing)

**Critical Path**:
1. Phase 1 (Context Restructuring) - Blocks all other phases
2. Phase 2 (Orchestrator Workflow) - Blocks routing and delegation
3. Phase 7 (Language Routing) - Blocks lean task execution
4. Phase 8 (Testing Framework) - Blocks validation
5. Phase 10 (Integration Testing) - Final validation

## Dependencies and Prerequisites

**Before Starting**:
1. Full backup of ProofChecker repository
2. Git repository in clean state (no uncommitted changes)
3. OpenCode CLI installed and functional
4. Python 3.12+ installed for validation scripts
5. Bash available for test scripts
6. Review and approval of this implementation plan

**Phase Dependencies**:
- Phase 2 depends on Phase 1 (context paths must be correct)
- Phase 3 depends on Phase 2 (orchestrator must route correctly)
- Phase 4 depends on Phase 2 (subagents must be invoked correctly)
- Phase 5 depends on Phase 4 (subagents must use status-sync-manager)
- Phase 6 depends on Phase 4 (subagents must create artifacts)
- Phase 7 depends on Phase 2 (orchestrator Stage 2 must exist)
- Phase 8 depends on Phases 1-7 (all components must be implemented)
- Phase 9 depends on Phases 1-8 (implementation must be complete)
- Phase 10 depends on Phases 1-9 (all components and docs must be ready)

## Notes and Considerations

### Design Decisions

**Context Organization**:
- Chose to consolidate common/ into core/ rather than keeping separate to reduce confusion
- Organized core/ into standards/, system/, templates/, workflows/ for clarity
- Kept project/ separate for repository-specific context

**Orchestrator Workflow**:
- Implemented full 5-stage workflow for consistency and debugging
- Added comprehensive logging for troubleshooting
- Kept minimal context loading for performance

**Language-Based Routing**:
- Chose to extract language from state.json first for consistency
- Fall back to TODO.md for backward compatibility
- Default to "general" for safety

**Atomic State Updates**:
- Chose two-phase commit for reliability
- Added rollback mechanism for safety
- Prioritized consistency over performance

### Future Enhancements

**Not Included in This Rebuild**:
1. Session-based temporary context (mentioned in DESIGN.md as future enhancement)
2. Enhanced /meta command with direct prompt support (separate task 269)
3. Improved argument parsing with flags (separate task 268)
4. Proof-specific workflows for Lean development
5. Performance optimization beyond context window protection

**Recommended Follow-Up Tasks**:
1. Implement session-based temporary context
2. Add performance monitoring and optimization
3. Create user training materials
4. Develop advanced testing scenarios
5. Implement continuous integration for .opencode system

### Lessons Learned from OpenAgents

**Applied to This Rebuild**:
1. Minimal orchestrator context loading (60-70% reduction)
2. Frontmatter-based routing (eliminates complex routing logic)
3. Lazy context loading via index (fast lookups)
4. Metadata passing instead of full content (context protection)
5. XML workflow structure (clear stage progression)

**Adapted for ProofChecker**:
1. Language-based routing (Lean 4 specialization)
2. Atomic state updates (consistency guarantee)
3. Lazy artifact management (no pre-creation)
4. Git workflow integration (commit tracking)
5. Two-phase commit (reliability)

## Validation

### Pre-Flight Validation

Before starting implementation:
- [ ] DESIGN.md reviewed and understood
- [ ] Current system state documented
- [ ] Backup created
- [ ] Git repository clean
- [ ] Prerequisites installed
- [ ] Implementation plan approved

### Mid-Flight Validation

After each phase:
- [ ] Phase success criteria met
- [ ] Tests pass for phase
- [ ] Git commit created
- [ ] Documentation updated
- [ ] No regressions introduced

### Post-Flight Validation

After all phases complete:
- [ ] All success criteria met
- [ ] All tests pass
- [ ] Documentation complete and accurate
- [ ] Integration tests pass
- [ ] Final validation report created
- [ ] System ready for production use

## Conclusion

This implementation plan provides a comprehensive roadmap for rebuilding the ProofChecker .opencode system based on the DESIGN.md specification. The phased approach with clear success criteria, rollback strategies, and comprehensive testing ensures a reliable rebuild with minimal risk.

The rebuild will achieve:
- 60-70% context window reduction
- Proper orchestrator-centric design
- Language-based routing for Lean 4 tasks
- Atomic state updates for consistency
- Lazy artifact management
- Comprehensive testing and validation

Upon completion, the ProofChecker .opencode system will be a production-ready, well-documented, and maintainable agent system that follows best practices from the OpenAgents architecture while maintaining ProofChecker-specific enhancements.
