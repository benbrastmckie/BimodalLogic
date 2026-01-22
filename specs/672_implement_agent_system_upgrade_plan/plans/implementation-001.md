# Implementation Plan: .opencode System Upgrade

## Metadata

- **Task**: 672 - Implement agent system upgrade plan
- **Status**: [PLANNED]
- **Effort**: 240 hours (6 weeks)
- **Complexity**: High
- **Language**: meta
- **Priority**: High
- **Version**: 001
- **Created**: 2026-01-22
- **Planned**: 2026-01-22

## Overview

### Problem Statement
The .opencode system requires a comprehensive upgrade to integrate proven .claude innovations while maintaining its formal verification specialization. Current limitations include: workflow friction with "continue" prompts, lack of dynamic system extension capabilities, and suboptimal token efficiency.

### Scope
This 6-week upgrade implements 4 phases: (1) Foundation - hook system, metadata exchange, and state management; (2) Workflow Ownership Migration - seamless UX through subagent-owned workflows; (3) Meta System Builder Port - dynamic system extension; (4) Forked Subagent Pattern - token efficiency optimization.

### Constraints
- Maintain backward compatibility during transition
- Preserve formal verification specialization
- Follow gradual migration strategy
- Ensure zero downtime for existing workflows

### Definition of Done
- All 4 phases completed with acceptance criteria met
- Token usage reduced by 15-20%
- "Continue" prompts eliminated from workflows
- Meta system builder functional with formal verification templates
- No regression in existing functionality

## Research Integration

This plan integrates findings from 1 research report:

**Integrated Reports**:
- **research-001.md** (2026-01-22): Comprehensive analysis of .opencode vs .claude architectures with implementation paths for all 4 upgrade phases

**Key Findings Applied**:
- Hook system implementation via direct port from .claude with path updates
- File-based metadata exchange schema for reliable artifact tracking
- Complete workflow ownership transfer to subagents
- Meta System Builder with formal verification domain adaptations
- Forked subagent pattern for 15-20% token efficiency gains

## Goals and Non-Goals

### Goals
1. **Eliminate workflow friction** - Remove "continue" prompts through subagent-owned postflight
2. **Enable dynamic extension** - Meta System Builder for domain-specific agent generation
3. **Achieve token efficiency** - Forked subagent pattern with 15-20% savings
4. **Maintain reliability** - Hook system for automated error recovery
5. **Preserve specialization** - Formal verification focus throughout upgrade

### Non-Goals
- Complete architectural overhaul (gradual migration only)
- Breaking changes to existing workflows
- Removal of .opencode-specific formal verification features
- Integration with non-verification domains

## Risks and Mitigations

### High Risk: Breaking Existing Workflows
**Probability**: Medium | **Impact**: High
**Mitigation**: Feature flags, gradual rollout, preserve old subagents during transition

### Medium Risk: Meta System Complexity
**Probability**: Medium | **Impact**: Medium
**Mitigation**: Start with basic templates, user feedback loops, iterative improvement

### Medium Risk: Token Usage Regression
**Probability**: Low | **Impact**: Medium
**Mitigation**: Benchmarking at each phase, fallback mechanisms, performance monitoring

### Low Risk: Hook System Integration
**Probability**: Low | **Impact**: Low
**Mitigation**: Direct port from proven .claude implementation, comprehensive testing

## Implementation Phases

### Phase 1: Foundation - Workflow Safety (Week 1) - [NOT STARTED]
**Estimated Effort**: 18 hours

**Tasks**:
1. **Implement Hook System (8 hours)**
   - Port 3 hook scripts from .claude with .opencode path updates
   - Create .opencode/hooks/ directory structure
   - Test hook activation with marker file protocol

2. **Add File-Based Metadata Exchange (6 hours)**
   - Add return-metadata-file.md to .opencode context
   - Update researcher subagent to write metadata files
   - Remove JSON console returns in favor of file-based exchange

3. **Update State Management (4 hours)**
   - Adopt atomic two-phase commit patterns
   - Add rollback mechanisms
   - Implement validation hooks

**Acceptance Criteria**:
- Hooks prevent premature workflow termination
- Metadata files created and parsed reliably
- State synchronization passes validation tests
- No "continue" prompts in basic research workflows

### Phase 2: Workflow Ownership Migration (Week 2) - [NOT STARTED]
**Estimated Effort**: 32 hours

**Tasks**:
1. **Update Research Subagent (12 hours)**
   - Implement complete workflow ownership (preflight→postflight)
   - Add status transition logic and git commit integration
   - Ensure artifact linking in TODO.md

2. **Update Other Subagents (16 hours)**
   - Migrate planner, implementer, lean-research-agent, lean-implementation-agent
   - Add complete workflow ownership to all subagents
   - Standardize return patterns

3. **Remove Postflight from Commands (4 hours)**
   - Clean /research.md, /plan.md, /implement.md
   - Simplified command templates with delegation only
   - Remove redundant postflight stages

**Acceptance Criteria**:
- All workflows complete without "continue" prompts
- Status updates happen immediately on start
- Git commits created automatically by subagents
- Artifacts linked correctly in TODO.md

### Phase 3: Meta System Builder Port (Weeks 3-4) - [NOT STARTED]
**Estimated Effort**: 40 hours

**Tasks**:
1. **Port Core Subagents (24 hours)**
   - Migrate domain-analyzer, agent-generator, context-organizer, workflow-designer, command-creator
   - Adapt for formal verification context
   - Add theorem prover integration options (Coq, Isabelle/HOL, Lean 4)

2. **Create Meta Command (8 hours)**
   - Implement .opencode/command/meta.md with 8-stage interview workflow
   - Add system generation orchestration
   - Test interactive interview process

3. **Add Documentation (8 hours)**
   - Meta system builder guide
   - Domain extension examples
   - Troubleshooting documentation

**Acceptance Criteria**:
- `/meta` command launches interactive interview
- System generates complete agent architecture
- Formal verification templates included and functional
- Generated systems pass validation tests

### Phase 4: Forked Subagent Pattern (Weeks 5-6) - [NOT STARTED]
**Estimated Effort**: 32 hours

**Tasks**:
1. **Create Skill Wrappers (16 hours)**
   - Implement skill-researcher, skill-planner, skill-lean-research
   - Add skill-to-agent mapping documentation
   - Create skill wrapper templates with fork context

2. **Update Agent Files (12 hours)**
   - Migrate key agents to full context loading pattern
   - Implement isolated execution environment
   - Ensure file-based returns work correctly

3. **Update Command Routing (4 hours)**
   - Modify commands to invoke skills instead of direct agents
   - Add routing table for skill-to-agent mapping
   - Implement fallback mechanisms

**Acceptance Criteria**:
- Token usage reduced by 15-20% measured in benchmarks
- Context isolation working correctly
- Skill wrappers transparent to users
- No performance regression in workflow completion times

## Testing and Validation

### Unit Testing Strategy
```bash
.test/test_hooks.sh                    # Hook system validation
.test/test_metadata_exchange.sh         # Metadata file reliability
.test/test_workflow_ownership.sh        # Subagent workflow ownership
.test/test_meta_builder.sh              # Meta system generation
.test/test_forked_pattern.sh            # Context isolation
```

### Integration Testing
```bash
.test/integration/test_research_workflow.sh     # End-to-end research
.test/integration/test_planning_workflow.sh     # End-to-end planning
.test/integration/test_implementation_workflow.sh # End-to-end implementation
.test/integration/test_meta_builder.sh          # Meta system functionality
```

### Performance Testing
```bash
.test/performance/measure_tokens.sh            # Token usage before/after
.test/performance/context_loading.sh           # Context loading benchmarks
.test/performance/workflow_completion.sh       # Workflow completion times
```

### Validation Gates
Each phase must pass:
- All unit tests (100% pass rate)
- Integration tests for affected workflows
- Performance benchmarks (no regression)
- User acceptance testing (workflow completion)

## Artifacts and Outputs

### Phase 1 Deliverables
- .opencode/hooks/ (3 scripts)
- .opencode/context/core/formats/return-metadata-file.md
- Updated researcher subagent with metadata support
- Hook integration documentation

### Phase 2 Deliverables
- Updated all subagents with complete workflow ownership
- Cleaned command files without postflight stages
- Postflight control marker implementation
- Workflow continuity validation

### Phase 3 Deliverables
- 5 ported meta system subagents
- .opencode/command/meta.md with interview workflow
- Formal verification domain templates
- Meta system builder documentation

### Phase 4 Deliverables
- 3+ skill wrappers with fork context
- Updated agents with full context loading
- Skill-to-agent mapping documentation
- Performance optimization validation

### Final Deliverables
- Complete upgrade documentation
- Migration guide for existing workflows
- Performance comparison report
- Troubleshooting and rollback procedures

## Rollback/Contingency

### Phase-Level Rollback
Each phase includes rollback procedures:
- **Phase 1**: Disable hooks, revert to console JSON
- **Phase 2**: Restore postflight to commands, revert subagent ownership
- **Phase 3**: Disable /meta command, remove ported subagents
- **Phase 4**: Revert to direct agent calls, disable skill wrappers

### Feature Flags
All major changes include feature flags for gradual rollout:
- `OPENCODE_HOOKS_ENABLED` (Phase 1)
- `OPENCODE_SUBAGENT_OWNERSHIP` (Phase 2)
- `OPENCODE_META_ENABLED` (Phase 3)
- `OPENCODE_FORKED_PATTERN` (Phase 4)

### Recovery Procedures
1. **Immediate rollback**: Disable problematic feature flag
2. **File restoration**: Git checkout of affected files
3. **State validation**: Run consistency checks
4. **User notification**: Clear communication of changes

## Success Metrics

### Quantitative Metrics
- **Token Usage**: 15-20% reduction in average workflow tokens
- **Workflow Completion**: 25% improvement in completion time
- **Error Recovery**: 90% automated error recovery rate
- **System Extension**: 50% faster domain addition with /meta

### Qualitative Metrics
- **User Satisfaction**: Eliminate "continue" prompts
- **Maintainability**: Clear separation of concerns (skills= routing, agents=execution)
- **Extensibility**: Easy domain addition via /meta command
- **Reliability**: Self-healing workflows with hooks

### Validation Criteria
Each phase validated by:
- Automated test suite (100% pass)
- Performance benchmarks (no regression)
- User acceptance testing (workflow completion)
- Code review (architecture compliance)

## Dependencies and Prerequisites

### Technical Dependencies
- Existing .claude system (reference implementations)
- Current .opencode subagents and commands
- Git workflow for commit tracking
- Hooks support in execution environment

### Skill Dependencies
- Understanding of .claude architecture patterns
- Familiarity with formal verification workflows
- System integration and testing experience
- Performance optimization knowledge

### External Dependencies
- Hook system support in execution environment
- Git repository access for commit operations
- Sufficient test environments for validation

## Timeline and Milestones

### Week 1: Foundation
- Day 1-2: Hook system implementation
- Day 3-4: Metadata exchange integration
- Day 5: State management updates and testing

### Week 2: Workflow Ownership
- Day 1-2: Research subagent complete ownership
- Day 3-4: Other subagents ownership migration
- Day 5: Command cleanup and validation

### Week 3: Meta Builder - Part 1
- Day 1-3: Core subagents port (domain-analyzer, agent-generator)
- Day 4-5: Context organizer and workflow designer

### Week 4: Meta Builder - Part 2
- Day 1-2: Command creator and meta command
- Day 3-4: Formal verification templates
- Day 5: Documentation and testing

### Week 5: Forked Pattern - Part 1
- Day 1-3: Skill wrappers creation
- Day 4-5: Agent file updates

### Week 6: Forked Pattern - Part 2
- Day 1-2: Command routing updates
- Day 3-4: Performance optimization and testing
- Day 5: Final validation and documentation

## Resource Allocation

### Personnel Requirements
- **System Architect**: Phase 1 and Phase 3 leadership
- **Agent Developer**: Phase 2 and Phase 4 implementation
- **Command Developer**: Phase 2 and Phase 4 command updates
- **Testing Engineer**: All phases validation
- **Documentation**: Phase 3 and final documentation

### Tool and Infrastructure Requirements
- Development environment with hook support
- Test environments for each phase
- Performance monitoring tools
- Documentation generation tools

## Quality Assurance

### Code Quality Standards
- Follow .opencode coding standards
- Maintain documentation coverage > 80%
- Ensure test coverage > 90%
- Perform code reviews for all changes

### Testing Standards
- Unit tests for all new components
- Integration tests for workflow continuity
- Performance tests for optimization validation
- User acceptance tests for UX improvements

### Documentation Standards
- Update all relevant documentation
- Provide migration guides
- Include troubleshooting procedures
- Maintain API documentation

## Communication Plan

### Stakeholder Updates
- **Weekly Progress**: Status reports and milestone updates
- **Phase Completion**: Detailed completion reports
- **Issues/Breakdowns**: Immediate notification with mitigation plans
- **Final Delivery**: Comprehensive completion report

### User Communication
- **Feature Changes**: Clear documentation of new capabilities
- **Migration Guides**: Step-by-step upgrade procedures
- **Downtime Notifications**: Advance notice of any disruptions
- **Training Materials**: Guides for new features and workflows