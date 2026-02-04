# Implementation Plan: Agent system upgrade plan

- **Task**: 672 - implement_agent_system_upgrade_plan
- **Status**: [PLANNED]
- **Effort**: 240 hours (6 weeks)
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/672_implement_agent_system_upgrade_plan/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false
- **Version**: 002
- **Previous Plan**: implementation-001.md
- **Created**: 2026-01-22
- **Planned**: 2026-01-22

## Revision Summary

**Why revised**: The workflow contract needs to guarantee status updates before work starts, artifact creation before linking, and artifact linking plus status updates before commits across /task, /research, /plan, /revise, and /implement.

**Key changes from v001**:
1. Added explicit workflow sequencing requirements for status updates, artifact creation, and commits.
2. Expanded Phase 1 to define and validate the workflow contract for all workflow commands.
3. Strengthened Phase 2 acceptance criteria to require cross-command workflow continuity.

## Overview

### Problem Statement
The .opencode system requires a comprehensive upgrade to integrate proven .claude innovations while maintaining its formal verification specialization. Current limitations include workflow friction with "continue" prompts, inconsistent status/artifact updates across commands, lack of dynamic system extension capabilities, and suboptimal token efficiency.

### Scope
This 6-week upgrade implements 4 phases: (1) Foundation - metadata exchange and state management with explicit workflow sequencing; (2) Workflow Ownership Migration - seamless UX through subagent-owned workflows; (3) Meta System Builder Port - dynamic system extension; (4) Forked Subagent Pattern - token efficiency optimization.

### Constraints
- Maintain backward compatibility during transition
- Preserve formal verification specialization
- Follow gradual migration strategy
- Ensure zero downtime for existing workflows

### Definition of Done
- All 4 phases completed with acceptance criteria met
- Token usage reduced by 15-20%
- "Continue" prompts eliminated from workflows
- Workflow contract enforced: status updates before work, artifacts before linking, links and status updates before commits
- Meta system builder functional with formal verification templates
- No regression in existing functionality

## Research Integration

This plan integrates findings from 1 research report:

**Integrated Reports**:
- **research-001.md** (2026-01-22): Comprehensive analysis of .opencode vs .claude architectures with implementation paths for all 4 upgrade phases

**Key Findings Applied**:
- Metadata exchange schema for reliable artifact tracking
- File-based metadata exchange schema for reliable artifact tracking
- Complete workflow ownership transfer to subagents
- Meta System Builder with formal verification domain adaptations
- Forked subagent pattern for 15-20% token efficiency gains

## Goals & Non-Goals

### Goals
1. **Eliminate workflow friction** - Remove "continue" prompts through subagent-owned postflight
2. **Enforce workflow contract** - Status updates before work, artifacts before linking, link/status updates before commits
3. **Enable dynamic extension** - Meta System Builder for domain-specific agent generation
4. **Achieve token efficiency** - Forked subagent pattern with 15-20% savings
5. **Maintain reliability** - Automated error recovery with state validation
6. **Preserve specialization** - Formal verification focus throughout upgrade

### Non-Goals
- Complete architectural overhaul (gradual migration only)
- Breaking changes to existing workflows
- Removal of .opencode-specific formal verification features
- Integration with non-verification domains

## Risks & Mitigations

### High Risk: Breaking Existing Workflows
**Probability**: Medium | **Impact**: High
**Mitigation**: Feature flags, gradual rollout, preserve old subagents during transition

### Medium Risk: Workflow Contract Drift
**Probability**: Medium | **Impact**: Medium
**Mitigation**: Add validation checks to enforce status/artifact sequencing before commits

### Medium Risk: Meta System Complexity
**Probability**: Medium | **Impact**: Medium
**Mitigation**: Start with basic templates, user feedback loops, iterative improvement

### Medium Risk: Token Usage Regression
**Probability**: Low | **Impact**: Medium
**Mitigation**: Benchmarking at each phase, fallback mechanisms, performance monitoring

### Low Risk: State Validation Integration
**Probability**: Low | **Impact**: Low
**Mitigation**: Build on existing workflows and validate with targeted tests

## Implementation Phases

### Phase 1: Foundation - Workflow Safety [NOT STARTED]
- **Goal:** Establish workflow sequencing rules and metadata exchange.
- **Tasks:**
  - [ ] Define the workflow contract for /task, /research, /plan, /revise, /implement (status -> artifacts -> link -> status -> commit).
  - [ ] Add return-metadata-file.md to .opencode context and align subagent outputs.
  - [ ] Update state management validation to assert ordering and consistency checks.
  - [ ] Add workflow contract tests for preflight/postflight ordering.
- **Timing:** 10 hours

**Acceptance Criteria**:
- Workflow contract documented and referenced by commands and subagents.
- Metadata files created and parsed reliably.
- State synchronization passes validation tests.
- Workflow tests confirm ordering for status, artifacts, links, and commits.

### Phase 2: Workflow Ownership Migration [NOT STARTED]
- **Goal:** Ensure subagents fully own workflows with consistent status and artifact handling.
- **Tasks:**
  - [ ] Update research subagent for full ownership with workflow contract enforcement.
  - [ ] Update planner, implementer, lean-research, lean-implementation for the same sequencing rules.
  - [ ] Remove postflight stages from /research, /plan, /revise, /implement, and align /task creation flow.
  - [ ] Ensure git commit integration happens after artifact linking and status update.
- **Timing:** 32 hours

**Acceptance Criteria**:
- All workflows complete without "continue" prompts.
- Status updates happen before work begins in every command.
- Artifacts are created before linking and linking occurs before commits.
- /task, /research, /plan, /revise, /implement follow the same workflow contract.

### Phase 3: Meta System Builder Port [NOT STARTED]
- **Goal:** Port Meta System Builder with formal verification adaptations.
- **Tasks:**
  - [ ] Port domain-analyzer, agent-generator, context-organizer, workflow-designer, command-creator.
  - [ ] Create .opencode/command/meta.md with 8-stage interview workflow.
  - [ ] Add formal verification templates and documentation.
- **Timing:** 40 hours

**Acceptance Criteria**:
- `/meta` command launches interactive interview.
- System generates complete agent architecture.
- Formal verification templates included and functional.
- Generated systems pass validation tests.

### Phase 4: Forked Subagent Pattern [NOT STARTED]
- **Goal:** Implement forked subagent pattern for token efficiency.
- **Tasks:**
  - [ ] Create skill wrappers with fork context and mapping documentation.
  - [ ] Update agent files to full context loading pattern.
  - [ ] Update command routing to invoke skills instead of direct agents.
- **Timing:** 32 hours

**Acceptance Criteria**:
- Token usage reduced by 15-20% measured in benchmarks.
- Context isolation working correctly.
- Skill wrappers transparent to users.
- No performance regression in workflow completion times.

## Testing & Validation

- [ ] .test/test_metadata_exchange.sh
- [ ] .test/test_state_validation.sh
- [ ] .test/test_workflow_ownership.sh
- [ ] .test/test_workflow_contract_ordering.sh
- [ ] .test/integration/test_research_workflow.sh
- [ ] .test/integration/test_planning_workflow.sh
- [ ] .test/integration/test_implementation_workflow.sh
- [ ] .test/integration/test_task_workflow.sh
- [ ] .test/integration/test_meta_builder.sh
- [ ] .test/performance/measure_tokens.sh
- [ ] .test/performance/context_loading.sh
- [ ] .test/performance/workflow_completion.sh

## Artifacts & Outputs

- .opencode/context/core/formats/return-metadata-file.md
- Updated workflow commands: .opencode/command/task.md, plan.md, revise.md, research.md, implement.md
- Updated subagents: researcher, planner, implementer, lean-research, lean-implementation
- Workflow contract validation tests
- Documentation updates for workflow contract

## Rollback/Contingency

- Disable feature flags for metadata exchange or ownership migration.
- Revert updated command files and subagent definitions.
- Restore previous workflow ordering and validate state sync.
