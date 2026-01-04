# Implementation Plan: Improve Context Files Based on Task 240 and Task 243 Research

- **Task**: 243 - Implement Phase 4 from task 237 implementation plan (aggressive command file deduplication)
- **Status**: [NOT STARTED]
- **Effort**: 24-30 hours (expanded from original 12-16 hours to include context file improvements from task 240 research)
- **Priority**: Medium
- **Dependencies**: Task 237 Phase 3 (completed), Task 240 research (completed)
- **Research Inputs**: 
  - .opencode/specs/243_implement_phase_4_aggressive_command_deduplication/reports/research-001.md (Aggressive deduplication strategies)
  - .opencode/specs/240_systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures/plans/implementation-002.md (OpenAgents architectural patterns)
  - .opencode/specs/240_systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures/reports/research-001.md (Comparative analysis)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

This plan synthesizes findings from task 240's OpenAgents comparative analysis and task 243's aggressive deduplication research to create a comprehensive context file improvement strategy. The core insight is that achieving sustainable context window reduction requires both **structural simplification** (fewer, more focused context files) and **architectural alignment** (frontmatter-based delegation pattern). The plan combines task 243's variations-only template pattern with task 240's context index and lazy-loading recommendations to create a unified solution that reduces total context system from 8,093 lines to approximately 2,000-2,500 lines (70% reduction) while achieving 60-70% reduction in command file sizes.

## Goals and Non-Goals

**Goals:**
- Reduce command file sizes by 60-70% through variations-only template pattern (task 243)
- Consolidate redundant context files from 8,093 lines to 2,000-2,500 lines (task 240)
- Create lazy-loading context index for on-demand context access (task 240)
- Implement variation-based command structure with lifecycle references
- Maintain functional equivalence (all commands work identically)
- Improve maintainability through single source of truth pattern
- Reduce context window usage during routing from 60-70% to under 10%

**Non-Goals:**
- Implementing OpenAgents frontmatter delegation pattern (deferred to separate task - requires orchestrator architectural changes)
- Splitting command files into routing/execution files (task 242 abandoned as infeasible)
- Changing user-facing command interface or syntax
- Modifying task tracking file formats (TODO.md, state.json)
- Implementing new features beyond context improvements

## Risks and Mitigations

**Risk 1: Context consolidation breaks existing references**
- Mitigation: Create reference map before consolidation. Update all referencing files atomically. Test all commands after consolidation.

**Risk 2: Variation-only commands harder to understand**
- Mitigation: Add inline documentation, variation justifications, reference links. Create developer guide for variation pattern.

**Risk 3: Lifecycle file becomes single point of failure**
- Mitigation: Implement versioning, validation, and fallback behavior. Track in git with change review requirements.

**Risk 4: Regression introduction during refactoring**
- Mitigation: Incremental refactoring (one command at a time), comprehensive testing (functional equivalence, lifecycle validation, variation override), parallel execution comparison.

**Risk 5: Missing or incomplete variations**
- Mitigation: Define required variation validation, provide default values, create variation completeness checklist, provide command template.

## Implementation Phases

### Phase 1: Analysis and Context Index Creation [COMPLETED]

**Goal:** Analyze current context file redundancies and create lazy-loading index for targeted context access.

**Tasks:**
- [ ] Analyze all context files for duplication (1,139 lines command-lifecycle.md, 888 lines status-markers.md, 648 lines subagent-delegation-guide, 356 lines subagent-return-format.md)
- [ ] Identify consolidation opportunities (delegation guides → delegation.md, state tracking → state-management.md)
- [ ] Create .opencode/context/index.md with lazy-loading quick map pattern (following OpenAgents template, 32 lines)
- [ ] Map 8-10 critical context files to index categories (standards, workflows, specs, system)
- [ ] Document consolidation plan (which files merge, which files remain, which files deprecated)
- [ ] Create Phase 1 analysis report with consolidation matrix

**Timing:** 4-5 hours

**Validation Criteria:**
- All context files analyzed for duplication (target: identify 60-70% redundancy)
- Consolidation plan created with file mapping
- index.md created with 8-10 critical files mapped
- Analysis report documents consolidation opportunities

### Phase 2: Command File Variation Analysis [COMPLETED]

**Goal:** Analyze command files (research.md, plan.md, implement.md, revise.md) to identify variations vs common lifecycle logic.

**Tasks:**
- [ ] Line-by-line comparison of all 4 command files (research.md 684 lines, plan.md 659 lines, implement.md 809 lines, revise.md 653 lines)
- [ ] Identify common lifecycle patterns (Stages 1-8 structure, error handling, validation)
- [ ] Document command-specific variations (status markers, routing, timeout, artifacts, git commits)
- [ ] Create duplication matrix showing common vs variation percentages (expected 60-70% common)
- [ ] Design variations-only template structure (frontmatter + context + variations block)
- [ ] Define 8 variation categories from command-lifecycle.md variation tables
- [ ] Create Phase 2 variation analysis report with template specification

**Timing:** 2-3 hours

**Validation Criteria:**
- All 4 command files compared line-by-line
- Duplication percentage documented (expected 60-70%)
- Variations-only template designed and reviewed
- 8 variation categories identified and documented
- Variation analysis report created

### Phase 3: Context File Consolidation [IN PROGRESS]

**Goal:** Consolidate redundant context files following OpenAgents organization patterns.

**Tasks:**
- [ ] Merge subagent-return-format.md (356 lines) and subagent-delegation-guide.md (648 lines) into delegation.md (approximately 500 lines, 504 lines saved)
- [ ] Merge status-markers.md (888 lines) and state-schema.md (estimated 200 lines) into state-management.md (approximately 600 lines, 488 lines saved)
- [ ] Review artifact-management.md, tasks.md, documentation.md for consolidation opportunities
- [ ] Create consolidated files with clear section structure
- [ ] Update index.md to reflect consolidated files
- [ ] Create reference mapping document (old file → new file section)
- [ ] Test consolidated files load correctly in context system

**Timing:** 4-5 hours

**Validation Criteria:**
- delegation.md created (approximately 500 lines, consolidates 1,004 lines = 504 lines saved)
- state-management.md created (approximately 600 lines, consolidates 1,088 lines = 488 lines saved)
- Total consolidation: 992 lines saved so far
- index.md updated to reflect consolidation
- Reference mapping created

### Phase 4: Refactor research.md to Variations-Only [NOT STARTED]

**Goal:** Refactor research.md from 684 lines to 150-250 lines using variations-only template.

**Tasks:**
- [ ] Extract research-specific variations (status markers: [RESEARCHING]/[RESEARCHED], routing: lean → lean-research-agent, timeout: 3600s, special context: divide_topics, artifacts: reports/summaries, git: "research completed")
- [ ] Create new research.md with template structure (frontmatter, context, argument_parsing, workflow_execution with variations block)
- [ ] Add lifecycle reference (command-lifecycle.md v1.0)
- [ ] Add 8 variation categories with justifications (status_markers, routing, timeout, special_context, artifacts, git_commit, validation, return_content)
- [ ] Add inline documentation explaining lifecycle stages and variation purposes
- [ ] Remove duplicated lifecycle logic (Stages 1-8 detailed steps)
- [ ] Update all agent and command files referencing consolidated context files (delegation.md, state-management.md)
- [ ] Test refactored /research command (functional equivalence, status updates, artifacts, git commits)
- [ ] Create Phase 4 validation report with before/after metrics

**Timing:** 2-3 hours

**Validation Criteria:**
- research.md reduced to 150-250 lines (from 684 lines, 60-70% reduction, 434-534 lines saved)
- All variations documented with justifications
- Lifecycle reference correct
- References updated to consolidated files
- Command functions identically to original
- No regressions detected

### Phase 5: Refactor plan.md to Variations-Only [NOT STARTED]

**Goal:** Refactor plan.md from 659 lines to 150-250 lines using variations-only template.

**Tasks:**
- [ ] Extract plan-specific variations (status markers: [PLANNING]/[PLANNED], routing: always planner, timeout: 1800s, special context: research_inputs, artifacts: plans/implementation-001.md, git: "plan created")
- [ ] Create new plan.md with template structure
- [ ] Add lifecycle reference
- [ ] Add 8 variation categories with justifications
- [ ] Add inline documentation
- [ ] Add task number extraction (Phase 1 from task 237: extract task number from TODO.md, reduce from 109KB to ~2KB)
- [ ] Remove duplicated lifecycle logic
- [ ] Update references to consolidated context files
- [ ] Test refactored /plan command (functional equivalence, research harvesting, plan creation, status updates, git commits)
- [ ] Create Phase 5 validation report

**Timing:** 2-3 hours

**Validation Criteria:**
- plan.md reduced to 150-250 lines (from 659 lines, 60-70% reduction, 409-509 lines saved)
- Task extraction reduces context from 109KB to ~2KB (107KB savings, 98% reduction)
- All variations documented with justifications
- Lifecycle reference correct
- References updated to consolidated files
- Command functions identically to original
- No regressions detected

### Phase 6: Refactor implement.md to Variations-Only [NOT STARTED]

**Goal:** Refactor implement.md from 809 lines to 200-300 lines using variations-only template.

**Tasks:**
- [ ] Extract implement-specific variations (status markers: [IMPLEMENTING]/[COMPLETED]/[PARTIAL], routing: language + plan based, timeout: 7200s, special context: plan_path/resume_from_phase, artifacts: implementation files + summary, git: "implementation completed")
- [ ] Create new implement.md with template structure (longer than others due to complex routing)
- [ ] Add lifecycle reference
- [ ] Add 8+ variation categories with justifications (more complex than other commands)
- [ ] Add inline documentation
- [ ] Remove duplicated lifecycle logic
- [ ] Update references to consolidated context files
- [ ] Test refactored /implement command (functional equivalence, language extraction, plan detection, phase resume, artifacts, git commits)
- [ ] Create Phase 6 validation report

**Timing:** 2-3 hours

**Validation Criteria:**
- implement.md reduced to 200-300 lines (from 809 lines, 60-70% reduction, 509-609 lines saved)
- All variations documented with justifications
- Complex routing logic preserved correctly
- Lifecycle reference correct
- References updated to consolidated files
- Command functions identically to original
- No regressions detected

### Phase 7: Refactor revise.md to Variations-Only [NOT STARTED]

**Goal:** Refactor revise.md from 653 lines to 150-250 lines using variations-only template.

**Tasks:**
- [ ] Extract revise-specific variations (status markers: [REVISING]/[REVISED], routing: always planner, timeout: 1800s, special context: existing_plan_path/new_version, artifacts: plans/implementation-{version}.md, git: "plan revised to v{version}")
- [ ] Create new revise.md with template structure
- [ ] Add lifecycle reference
- [ ] Add 8 variation categories with justifications
- [ ] Add inline documentation
- [ ] Remove duplicated lifecycle logic
- [ ] Update references to consolidated context files
- [ ] Test refactored /revise command (functional equivalence, existing plan loading, new version creation, plan version history, status updates, git commits)
- [ ] Create Phase 7 validation report

**Timing:** 2-3 hours

**Validation Criteria:**
- revise.md reduced to 150-250 lines (from 653 lines, 60-70% reduction, 403-503 lines saved)
- All variations documented with justifications
- Lifecycle reference correct
- References updated to consolidated files
- Command functions identically to original
- No regressions detected

### Phase 8: Update command-lifecycle.md with Variation Interpretation [NOT STARTED]

**Goal:** Enhance command-lifecycle.md with variation interpretation logic and usage examples.

**Tasks:**
- [ ] Add variation interpretation section (how variations override defaults, resolution algorithm, precedence rules)
- [ ] Add variation examples for each of 8 categories (status markers, routing, timeout, special context, artifacts, git commits, validation, return content)
- [ ] Document variation resolution algorithm (load lifecycle, load variations, apply overrides)
- [ ] Add variation validation schema (required fields, valid values, conflict detection)
- [ ] Add troubleshooting guide (common variation errors, resolution failures, debugging tips)
- [ ] Update integration documentation (references to command files, variations-only pattern, usage examples)
- [ ] Add migration guide from inline to variations-only pattern
- [ ] Create Phase 8 enhancement report

**Timing:** 2-3 hours

**Validation Criteria:**
- Variation interpretation logic documented
- Examples provided for all 8 variation categories
- Validation schema defined
- Troubleshooting guide created
- Integration documentation updated
- Migration guide created

### Phase 9: Remove Obsolete Context Files [NOT STARTED]

**Goal:** Remove or deprecate obsolete context files after consolidation.

**Tasks:**
- [ ] Verify no references remain to old context files (subagent-return-format.md, subagent-delegation-guide.md, status-markers.md, state-schema.md if created)
- [ ] Create deprecation notices in old files (redirect to new files)
- [ ] Update all agent files to reference consolidated files (delegation.md, state-management.md)
- [ ] Update all command files to reference consolidated files
- [ ] Test all commands after reference updates
- [ ] Archive old context files (move to .opencode/context/archive/ or remove if fully superseded)
- [ ] Update documentation references to point to new files
- [ ] Create Phase 9 cleanup report

**Timing:** 2-3 hours

**Validation Criteria:**
- No active references to old context files
- All agents updated to reference consolidated files
- All commands updated to reference consolidated files
- Old files archived or removed
- Documentation updated
- All commands still functional

### Phase 10: Comprehensive Integration Testing [NOT STARTED]

**Goal:** Comprehensive testing of all refactored commands and consolidated context files.

**Tasks:**
- [ ] Functional equivalence testing (run all 4 commands, compare outputs to originals, verify status updates/artifacts/git commits identical)
- [ ] Lifecycle stage validation (instrument lifecycle stages with logging, run all 4 commands, compare stage execution, verify variations applied correctly)
- [ ] Variation override testing (test all variation types, verify status/routing/timeout/artifact/git overrides work correctly)
- [ ] Edge case testing (task at end of TODO.md, task with long description, non-existent task, missing variations, invalid variations, conflicting variations)
- [ ] Performance testing (measure file size reduction, measure context window usage reduction, measure line count reduction)
- [ ] Test with 20 consecutive runs of each command (verify 100% success rate, no regressions)
- [ ] Create comprehensive integration test report with metrics

**Timing:** 4-5 hours

**Validation Criteria:**
- All 4 commands function identically to originals (80 test runs total, 20 per command)
- All lifecycle stages execute consistently across commands
- All variations override correctly
- All edge cases handled correctly
- No regressions detected
- Performance metrics meet targets (60-70% file size reduction, under 10% context window during routing)

### Phase 11: Measurement and Documentation [NOT STARTED]

**Goal:** Measure context savings and document implementation with before/after metrics.

**Tasks:**
- [ ] Measure command file size reduction (before: 103,337 bytes / 2,805 lines, after: 32,000-40,000 bytes / 650-1,050 lines, target: 60-70% reduction / 1,755-2,155 lines saved)
- [ ] Measure context file consolidation (before: 8,093 lines, after: 2,000-2,500 lines, target: 5,593-6,093 lines saved / 70% reduction)
- [ ] Measure context window savings (routing: before 78-86KB / 39-43%, after <20KB / <10%, target: 58-66KB saved)
- [ ] Measure total context system reduction (command files + context files: before 10,898 lines, after 2,650-3,550 lines, target: 7,348-8,248 lines saved / 67-76% reduction)
- [ ] Create before/after metrics summary with charts
- [ ] Update command file documentation (variations-only pattern, lifecycle references, variation categories)
- [ ] Update context loading best practices (lazy-loading index, on-demand context access, consolidated files)
- [ ] Create migration guide for future command development (template, required variations, validation, testing)
- [ ] Update task 243 status to [COMPLETED]
- [ ] Create final implementation summary with metrics and lessons learned

**Timing:** 2-3 hours

**Validation Criteria:**
- Command files reduced by 60-70% (target: 1,755-2,155 lines / 63,337-71,337 bytes saved)
- Context files reduced by 70% (target: 5,593-6,093 lines saved)
- Total reduction: 7,348-8,248 lines (67-76%)
- Context window during routing: <10% (down from 39-43%)
- Documentation updated and complete
- Migration guide created
- Implementation summary created
- Task 243 marked [COMPLETED]

## Testing and Validation

**Phase-by-Phase Validation:**

- Phase 1: Analysis and context index verified
- Phase 2: Variation analysis and template design reviewed
- Phase 3: Consolidated files load correctly, references valid
- Phase 4: research.md functions identically, no regressions
- Phase 5: plan.md functions identically, no regressions, task extraction works
- Phase 6: implement.md functions identically, no regressions
- Phase 7: revise.md functions identically, no regressions
- Phase 8: command-lifecycle.md enhanced, variation interpretation documented
- Phase 9: Old files removed, no broken references
- Phase 10: All integration tests pass, 80 runs with 100% success
- Phase 11: Metrics documented, targets achieved

**Overall Success Metrics:**

- Command files: 60-70% reduction (1,755-2,155 lines / 63,337-71,337 bytes saved)
- Context files: 70% reduction (5,593-6,093 lines saved)
- Total reduction: 7,348-8,248 lines (67-76%)
- Context window during routing: under 10% (down from 39-43%)
- Functional equivalence: 100% (all commands work identically)
- Integration test success: 100% (80 runs across 4 commands)
- No regressions detected

## Artifacts and Outputs

**Phase 1:**
- .opencode/context/index.md (new, 32 lines)
- Phase 1 analysis report

**Phase 2:**
- Variation analysis report
- Variations-only template specification

**Phase 3:**
- .opencode/context/core/workflows/delegation.md (new, ~500 lines)
- .opencode/context/core/system/state-management.md (new, ~600 lines)
- Reference mapping document

**Phases 4-7:**
- .opencode/command/research.md (modified, 150-250 lines)
- .opencode/command/plan.md (modified, 150-250 lines)
- .opencode/command/implement.md (modified, 200-300 lines)
- .opencode/command/revise.md (modified, 150-250 lines)

**Phase 8:**
- .opencode/context/core/workflows/command-lifecycle.md (modified, enhanced with variation interpretation)

**Phase 9:**
- .opencode/context/core/workflows/subagent-delegation-guide.md (archived or removed)
- .opencode/context/core/standards/subagent-return-format.md (archived or removed)
- .opencode/context/core/system/status-markers.md (archived or removed)

**Phase 10:**
- Comprehensive integration test report

**Phase 11:**
- Before/after metrics summary
- Migration guide
- Final implementation summary

## Rollback and Contingency

**Incremental Rollback Strategy:**

Each phase has independent rollback:
- Phase 1-2: Analysis only, no changes to rollback
- Phase 3: Restore original context files from git, revert index.md
- Phases 4-7: Restore individual command files from git (one at a time)
- Phase 8: Revert command-lifecycle.md from git
- Phase 9: Restore archived files if needed
- Phases 10-11: Documentation only, no rollback needed

**Contingency Plan:**

- If consolidation breaks workflows: Restore original context files, update references back
- If variation-only pattern fails: Keep refactored commands but revert to inline lifecycle logic
- If testing reveals regressions: Identify regression, fix variation specification, re-test
- If context window savings insufficient: Re-evaluate consolidation targets, identify additional opportunities
- If file size targets not met: Review variation specifications for unnecessary verbosity

**Success Gates:**

- Each command refactoring (Phases 4-7) validated independently before proceeding
- Context consolidation (Phase 3) validated before command refactoring begins
- Integration testing (Phase 10) must pass 100% before finalizing
- Can pause after any phase without breaking existing system

## Integration with Task 240 Recommendations

This plan deliberately excludes task 240's most aggressive recommendations (frontmatter delegation, session-based temporary context, orchestrator simplification) while incorporating compatible elements:

**Included from Task 240:**
- Context index for lazy-loading (Phase 1)
- Context file consolidation (Phase 3, 9)
- Variations-only pattern aligns with "command defines what, agent defines how" philosophy

**Excluded from Task 240 (requires separate architectural task):**
- Frontmatter-based delegation pattern (requires orchestrator changes)
- Session-based temporary context (.tmp/sessions/)
- Orchestrator simplification to router pattern
- Workflow ownership transfer from commands to agents

**Rationale:** This plan focuses on achievable improvements with minimal architectural risk. Task 240's more aggressive recommendations should be pursued in a separate task after validating this plan's improvements.

## Context Window Savings Analysis

**Current State:**
- Command files: 103,337 bytes / 2,805 lines
- Context files: ~8,093 lines
- Total: ~10,898 lines
- Routing context: 78-86KB (39-43% of 200KB window)

**Target State:**
- Command files: 32,000-40,000 bytes / 650-1,050 lines (60-70% reduction, 1,755-2,155 lines saved)
- Context files: 2,000-2,500 lines (70% reduction, 5,593-6,093 lines saved)
- Total: 2,650-3,550 lines (67-76% reduction, 7,348-8,248 lines saved)
- Routing context: <20KB (<10% of 200KB window, 58-66KB saved)

**Breakdown by Phase:**
- Phase 3 (Consolidation): 992 lines saved (delegation.md + state-management.md)
- Phase 4 (research.md): 434-534 lines saved
- Phase 5 (plan.md): 409-509 lines saved + 107KB task extraction savings
- Phase 6 (implement.md): 509-609 lines saved
- Phase 7 (revise.md): 403-503 lines saved
- Phase 9 (Obsolete removal): Additional consolidation savings
- Total command savings: 1,755-2,155 lines
- Total context savings: 5,593-6,093 lines

**Validation:** Measurements in Phase 11 will verify actual savings meet or exceed targets.
