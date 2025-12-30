# Implementation Plan: Adopt OpenAgents Architecture to Fix Stage 7 Failures

- **Task**: 240 - Systematically investigate and fix persistent workflow command Stage 7 (Postflight) failures causing incomplete status updates
- **Status**: [NOT STARTED]
- **Effort**: 56-78 hours
- **Priority**: Critical
- **Dependencies**: None
- **Research Inputs**: 
  - .opencode/specs/240_systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures/reports/research-001.md (Comparative analysis of OpenAgents vs ProofChecker)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**:
  - .opencode/context/common/standards/plan.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/context/common/system/artifact-management.md
  - .opencode/context/common/standards/tasks.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

Comparative analysis of OpenAgents and ProofChecker systems identified the root cause of Stage 7 failures: ProofChecker commands contain workflow stages as XML documentation (narrative) rather than executable code, causing Claude to skip Stage 7 as optional guidance. OpenAgents avoids this through agent-driven architecture where commands define "what" (frontmatter delegation) and agents own "how" (executable workflow stages). This plan adopts OpenAgents architectural patterns through 4 phases: (1) Quick wins with context index and /research frontmatter prototype, (2) Core architecture migration of all commands and orchestrator simplification, (3) Context consolidation and cleanup, (4) Testing and documentation. Success criteria: context window usage under 10% during routing (down from 60-70%), command files under 200 lines (down from 600-800 lines), Stage 7 executes 100% reliably, orchestrator under 100 lines (down from 1,038 lines).

## Goals and Non-Goals

**Goals:**
- Adopt OpenAgents frontmatter-based delegation pattern (commands define "what", agents define "how")
- Implement lazy-loading context index for on-demand context loading
- Create session-based temporary context system (.tmp/sessions/)
- Simplify orchestrator to 15-line router pattern
- Eliminate Stage 7 skip failures by moving workflow ownership to agents
- Reduce context window usage from 60-70% to under 10% during routing
- Reduce command file sizes from 600-800 lines to under 200 lines
- Consolidate context files from 8,093 lines to approximately 2,500 lines (70% reduction)

**Non-Goals:**
- Changing the user-facing command interface or syntax
- Modifying task tracking file formats (TODO.md, state.json)
- Rewriting existing agent logic that already works correctly
- Implementing new features beyond architectural improvements
- Changing artifact output formats or directory structures

## Risks and Mitigations

**Risk 1: Breaking existing workflows during migration**
- Mitigation: Implement Phase 1 as isolated prototype with /research command only. Validate improvements before proceeding to Phase 2 full migration. Keep original command files as backups until validation complete.

**Risk 2: Context index pattern may not work as expected in ProofChecker**
- Mitigation: Create minimal viable index.md in Phase 1 with 3-5 critical context files. Test lazy-loading with /research command. Measure context window usage before and after.

**Risk 3: Agents may not correctly execute Stage 7 when workflow ownership transferred**
- Mitigation: Add explicit Stage 7 validation to agent return format. Test with 20 consecutive /research runs to verify 100% Stage 7 execution rate before migrating other commands.

**Risk 4: Orchestrator simplification may break delegation tracking**
- Mitigation: Preserve delegation registry and cycle detection in simplified orchestrator. Only remove redundant context loading and workflow duplication. Test delegation depth limits and cycle detection after simplification.

**Risk 5: Session-based temporary context may introduce cleanup issues**
- Mitigation: Implement explicit cleanup in agent return handlers. Add .tmp/ to .gitignore. Create cleanup script for orphaned session directories. Test cleanup on successful and failed delegations.

**Risk 6: Large effort estimate (56-78 hours) may lead to incomplete implementation**
- Mitigation: Structure as 4 independent phases with clear validation gates. Each phase delivers value independently. Can pause after Phase 1 or Phase 2 if needed without breaking system.

## Implementation Phases

### Phase 1: Quick Wins - Context Index and /research Frontmatter Prototype [NOT STARTED]

**Goal:** Validate OpenAgents patterns with minimal-risk prototype using /research command only. Achieve measurable context window reduction and Stage 7 reliability improvement.

**Tasks:**
- [ ] Create .opencode/context/index.md with lazy-loading quick map pattern (32 lines, following OpenAgents template)
- [ ] Map 8-10 critical context files to index categories (standards, workflows, specs, system)
- [ ] Add frontmatter to /research command with agent field pointing to researcher.md
- [ ] Extract workflow stages (Stages 4-8) from research.md to researcher.md
- [ ] Reduce research.md to 150-200 lines (frontmatter + description + usage only)
- [ ] Update researcher.md to own full workflow including Stage 7 status updates
- [ ] Add lazy-loading context instructions to researcher.md (load from index.md on-demand)
- [ ] Create .tmp/sessions/ directory structure and template
- [ ] Implement session-based temporary context creation in researcher.md
- [ ] Test /research command with context window measurement (before: 60-70%, target: under 15%)
- [ ] Validate Stage 7 execution with 20 consecutive /research runs (target: 100% success rate)
- [ ] Document context window savings and Stage 7 reliability improvements
- [ ] Create Phase 1 validation report with metrics

**Timing:** 12-16 hours

**Validation Criteria:**
- Context window usage during /research routing: under 15% (down from 60-70%)
- research.md file size: under 200 lines (down from 684 lines)
- Stage 7 execution rate: 100% in 20 consecutive runs
- researcher.md owns complete workflow including status updates
- index.md provides quick map to 8-10 critical context files
- .tmp/sessions/ temporary context created and cleaned up correctly

### Phase 2: Core Architecture - Migrate All Commands and Simplify Orchestrator [NOT STARTED]

**Goal:** Apply validated OpenAgents patterns to all workflow commands (/plan, /implement, /revise) and simplify orchestrator to router pattern.

**Tasks:**
- [ ] Add frontmatter to plan.md with agent field pointing to planner.md
- [ ] Extract workflow stages from plan.md to planner.md (reduce plan.md to under 200 lines)
- [ ] Update planner.md to own full workflow including Stage 7
- [ ] Add lazy-loading context instructions to planner.md
- [ ] Test /plan command with context window measurement and Stage 7 validation
- [ ] Add frontmatter to implement.md with agent field pointing to implementer.md
- [ ] Extract workflow stages from implement.md to implementer.md (reduce implement.md to under 200 lines)
- [ ] Update implementer.md to own full workflow including Stage 7
- [ ] Add lazy-loading context instructions to implementer.md
- [ ] Test /implement command with context window measurement and Stage 7 validation
- [ ] Add frontmatter to revise.md with agent field pointing to task-executor.md
- [ ] Extract workflow stages from revise.md to task-executor.md (reduce revise.md to under 200 lines)
- [ ] Update task-executor.md to own full workflow including Stage 7
- [ ] Add lazy-loading context instructions to task-executor.md
- [ ] Test /revise command with context window measurement and Stage 7 validation
- [ ] Simplify orchestrator.md to router pattern (analyze request, detect keywords/language, delegate, return)
- [ ] Remove redundant context loading from orchestrator (keep only routing essentials)
- [ ] Reduce orchestrator.md from 1,038 lines to under 100 lines
- [ ] Preserve delegation registry, cycle detection, and timeout enforcement in simplified orchestrator
- [ ] Add YAML frontmatter with tools/permissions to all 6 subagents (researcher, planner, implementer, task-executor, lean-research-agent, lean-implementation-agent)
- [ ] Test all 4 workflow commands with full delegation cycle
- [ ] Validate context window usage under 10% during routing for all commands
- [ ] Validate Stage 7 execution 100% reliable for all commands (20 runs each)
- [ ] Create Phase 2 validation report with metrics

**Timing:** 20-30 hours

**Validation Criteria:**
- All 4 command files under 200 lines each (total reduction from 2,848 lines to under 800 lines)
- All 4 agents own complete workflows including Stage 7
- Orchestrator under 100 lines (reduction from 1,038 lines)
- Context window usage during routing: under 10% for all commands
- Stage 7 execution rate: 100% for all commands in 80 total test runs (20 per command)
- Delegation registry, cycle detection, and timeout enforcement still functional
- All agents have YAML frontmatter with tools and permissions

### Phase 3: Consolidation - Merge Context Files and Remove Obsolete [NOT STARTED]

**Goal:** Consolidate redundant context files following OpenAgents organization patterns. Reduce total context system from 8,093 lines to approximately 2,500 lines (70% reduction).

**Tasks:**
- [ ] Merge subagent-return-format.md and subagent-delegation-guide.md into delegation.md (consolidate 648 + 400 = 1,048 lines to approximately 500 lines)
- [ ] Remove command-lifecycle.md (1,138 lines) - workflow now owned by agents, not commands
- [ ] Merge status-markers.md and state-schema.md into state-management.md (consolidate 888 + 200 = 1,088 lines to approximately 600 lines)
- [ ] Review and consolidate artifact-management.md, tasks.md, and documentation.md for redundancy
- [ ] Reorganize context directory structure to match OpenAgents pattern (core/standards/, core/workflows/, core/specs/, core/system/)
- [ ] Update index.md to reflect consolidated context files
- [ ] Update all agent files to reference consolidated context files
- [ ] Update all command files to reference consolidated context files
- [ ] Remove obsolete context files (command-lifecycle.md, duplicated delegation guides)
- [ ] Test all 4 workflow commands after context consolidation
- [ ] Validate context window usage still under 10% with consolidated files
- [ ] Measure total context system size (target: 2,000-2,500 lines, down from 8,093 lines)
- [ ] Create Phase 3 validation report with context size metrics

**Timing:** 16-20 hours

**Validation Criteria:**
- Total context system size: 2,000-2,500 lines (70% reduction from 8,093 lines)
- command-lifecycle.md removed (1,138 lines eliminated)
- Delegation guides consolidated to single delegation.md (approximately 500 lines)
- State management consolidated to single state-management.md (approximately 600 lines)
- Context directory reorganized to core/standards/, core/workflows/, core/specs/, core/system/
- index.md updated to reflect consolidated structure
- All commands and agents reference correct consolidated files
- Context window usage still under 10% during routing
- All 4 workflow commands still functional after consolidation

### Phase 4: Testing and Documentation [NOT STARTED]

**Goal:** Comprehensive testing of all architectural changes and documentation of new OpenAgents-based patterns.

**Tasks:**
- [ ] Run comprehensive test suite: 20 runs each of /research, /plan, /implement, /revise (80 total runs)
- [ ] Measure and document context window usage for each command (routing and execution stages)
- [ ] Validate Stage 7 execution rate: 100% across all 80 test runs
- [ ] Test delegation depth limits (3 levels) and cycle detection
- [ ] Test session-based temporary context creation and cleanup
- [ ] Test lazy-loading context index with various agent combinations
- [ ] Validate orchestrator routing with all command types
- [ ] Test error handling and rollback scenarios
- [ ] Create architectural documentation explaining OpenAgents patterns adopted
- [ ] Update .opencode/README.md with new architecture overview
- [ ] Document frontmatter delegation pattern in command development guide
- [ ] Document lazy-loading context index pattern in context development guide
- [ ] Document session-based temporary context pattern in delegation guide
- [ ] Create migration guide for future command/agent development
- [ ] Update CONTRIBUTING.md with new architectural patterns
- [ ] Create before/after metrics summary (context size, command size, Stage 7 reliability)
- [ ] Create Phase 4 validation report and final implementation summary

**Timing:** 8-12 hours

**Validation Criteria:**
- 80 test runs completed (20 per command) with 100% Stage 7 execution rate
- Context window usage documented: under 10% during routing for all commands
- Command file sizes documented: all under 200 lines
- Orchestrator size documented: under 100 lines
- Context system size documented: 2,000-2,500 lines (70% reduction)
- Architectural documentation complete and reviewed
- Migration guide created for future development
- Before/after metrics summary created
- Final implementation summary created

## Testing and Validation

**Phase 1 Validation:**
- [ ] Context window usage during /research routing: under 15%
- [ ] research.md file size: under 200 lines
- [ ] Stage 7 execution: 100% in 20 consecutive /research runs
- [ ] index.md created with 8-10 critical context files mapped
- [ ] .tmp/sessions/ temporary context working correctly

**Phase 2 Validation:**
- [ ] All 4 command files under 200 lines each
- [ ] Orchestrator under 100 lines
- [ ] Context window usage during routing: under 10% for all commands
- [ ] Stage 7 execution: 100% in 80 total test runs (20 per command)
- [ ] Delegation registry, cycle detection, timeout enforcement functional

**Phase 3 Validation:**
- [ ] Total context system: 2,000-2,500 lines (70% reduction)
- [ ] command-lifecycle.md removed (1,138 lines eliminated)
- [ ] Context files consolidated and reorganized
- [ ] All commands functional after consolidation

**Phase 4 Validation:**
- [ ] 80 comprehensive test runs with 100% Stage 7 success
- [ ] Documentation complete and reviewed
- [ ] Before/after metrics documented
- [ ] Migration guide created

**Overall Success Metrics:**
- Context window usage: under 10% during routing (down from 60-70%)
- Command files: under 200 lines average (down from 712 lines average)
- Orchestrator: under 100 lines (down from 1,038 lines)
- Context system: 2,000-2,500 lines (down from 8,093 lines, 70% reduction)
- Stage 7 execution: 100% reliable (up from approximately 60-70% reliable)

## Artifacts and Outputs

**Phase 1:**
- .opencode/context/index.md (new, 32 lines)
- .opencode/command/research.md (modified, reduced to under 200 lines)
- .opencode/agent/subagents/researcher.md (modified, owns full workflow)
- .tmp/sessions/ directory structure (new)
- Phase 1 validation report

**Phase 2:**
- .opencode/command/plan.md (modified, reduced to under 200 lines)
- .opencode/command/implement.md (modified, reduced to under 200 lines)
- .opencode/command/revise.md (modified, reduced to under 200 lines)
- .opencode/agent/orchestrator.md (modified, reduced to under 100 lines)
- .opencode/agent/subagents/planner.md (modified, owns full workflow)
- .opencode/agent/subagents/implementer.md (modified, owns full workflow)
- .opencode/agent/subagents/task-executor.md (modified, owns full workflow)
- .opencode/agent/subagents/lean-research-agent.md (modified, YAML frontmatter added)
- .opencode/agent/subagents/lean-implementation-agent.md (modified, YAML frontmatter added)
- Phase 2 validation report

**Phase 3:**
- .opencode/context/core/workflows/delegation.md (new, consolidated)
- .opencode/context/core/system/state-management.md (new, consolidated)
- .opencode/context/common/workflows/command-lifecycle.md (removed)
- .opencode/context/common/system/status-markers.md (merged into state-management.md)
- .opencode/context/common/system/state-schema.md (merged into state-management.md)
- .opencode/context/common/workflows/subagent-delegation-guide.md (merged into delegation.md)
- .opencode/context/common/system/subagent-return-format.md (merged into delegation.md)
- .opencode/context/index.md (updated to reflect consolidation)
- Phase 3 validation report

**Phase 4:**
- .opencode/README.md (updated with architecture overview)
- .opencode/docs/ARCHITECTURE.md (new, OpenAgents patterns documentation)
- .opencode/docs/MIGRATION_GUIDE.md (new, guide for future development)
- .opencode/context/common/standards/CONTRIBUTING.md (updated with new patterns)
- Final implementation summary with before/after metrics
- Phase 4 validation report

## Rollback and Contingency

**Phase 1 Rollback:**
- If context index pattern fails: Remove index.md, revert researcher.md to original workflow
- If /research frontmatter delegation fails: Revert research.md to original 684-line version
- If Stage 7 still fails: Abandon OpenAgents pattern, pursue orchestrator validation enforcement (Task 240 original plan Option 2)
- Rollback time: 1-2 hours

**Phase 2 Rollback:**
- If command migrations fail: Revert individual command files to original versions (plan.md, implement.md, revise.md)
- If orchestrator simplification breaks delegation: Revert orchestrator.md to original 1,038-line version
- If Stage 7 failures return: Revert all Phase 2 changes, keep only Phase 1 improvements
- Rollback time: 2-4 hours

**Phase 3 Rollback:**
- If context consolidation breaks workflows: Restore original context files from git history
- If context reorganization causes reference errors: Revert to original directory structure
- Rollback time: 2-3 hours

**Phase 4 Rollback:**
- Documentation changes are non-breaking and do not require rollback
- If testing reveals issues: Address issues or rollback to previous phase

**Contingency Plan:**
- Each phase has independent validation gates
- Can pause implementation after any phase without breaking system
- Phase 1 delivers value independently (context reduction, /research Stage 7 fix)
- Phase 2 delivers value independently (all commands fixed, orchestrator simplified)
- Phase 3 delivers value independently (context consolidation)
- Phase 4 is documentation only (non-breaking)

**Alternative Approach if OpenAgents Pattern Fails:**
- Pursue Task 240 original plan Option 2: Add orchestrator validation layer
- Implement command_stages tracking in delegation registry
- Add Stage 7 completion validation before accepting command returns
- Estimated effort: 12-16 hours (significantly less than OpenAgents migration)
- Trade-off: Band-aid solution vs architectural alignment
