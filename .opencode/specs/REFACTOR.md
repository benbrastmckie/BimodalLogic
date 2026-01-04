---
status: [NOT STARTED]
created: 2026-01-03T19:00:00Z
last_updated: 2026-01-03T19:30:00Z
version: 1.1
project: proofchecker_opencode_rebuild
revision_notes: "Added lean-planner subagent and expanded language-based routing to /plan and /revise commands per DESIGN.md FIX comment"
---

# Implementation Plan: ProofChecker .opencode System Rebuild

**Project**: ProofChecker .opencode System Rebuild
**Plan**: REFACTOR.md
**Status**: [NOT STARTED]
**Created**: 2026-01-03
**Target System**: /home/benjamin/Projects/ProofChecker/.opencode

## Executive Summary

This plan provides a comprehensive roadmap for rebuilding the ProofChecker .opencode system based on the design specification at `/home/benjamin/Projects/ProofChecker/.opencode/specs/DESIGN.md`. The current system has become bloated and certain changes have prevented it from working correctly. This rebuild will implement the orchestrator-centric design with proper context window protection, language-based routing, atomic state updates, and standardized workflows.

The rebuild is structured in 10 phases spanning approximately 87-113 hours of work. Each phase is designed to be independently testable with clear rollback points. The majority of work will be carried out by subagents to protect the orchestrator's context, with work directed using commands in Orchestrator agent mode.

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

### Phase 1: Context Directory Restructuring [NOT STARTED]

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
  - Move `common/standards/` → `core/standards/`
  - Move `common/system/` → `core/system/`
  - Move `common/workflows/` → `core/workflows/`
  - Move `common/templates/` → `core/templates/`
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

### Phase 2: Orchestrator 5-Stage Workflow Verification [NOT STARTED]

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

### Phase 3: Command System Frontmatter Verification [NOT STARTED]

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

### Phase 4: Subagent Compliance Verification [NOT STARTED]

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

### Phase 5: Status Sync Manager Verification [NOT STARTED]

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

### Phase 6: Artifact Management Pattern Enforcement [NOT STARTED]

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

### Phase 7: Language-Based Routing Implementation [NOT STARTED]

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
