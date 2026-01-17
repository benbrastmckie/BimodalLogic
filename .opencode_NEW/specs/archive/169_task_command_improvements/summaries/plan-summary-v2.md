# Plan Summary: /task Command Context Window Protection (v2)

**Version**: 2 (Clean Break)
**Complexity**: Complex
**Estimated Effort**: 8-9 hours
**Previous Version**: implementation-001.md (superseded)
**Revision Date**: 2025-12-24

## Revision Changes

**Removed from v1**:
- Backward compatibility layer and transition period support
- Dual-format return handling
- Compatibility shims and legacy support code

**Added in v2**:
- Phase 0: Upfront audit of all consuming commands (.opencode/command/*.md, .opencode/agent/subagents/*.md)
- Phase 1b: Parallel update of all consuming commands before breaking changes
- Coordinated atomic commit strategy for clean-break deployment
- Feature branch workflow with phase-boundary git tags
- Comprehensive rollback plan (all-or-nothing)

**Preserved**:
- 8-phase structure (restructured with new Phase 0 and Phase 1a/1b/1c)
- Artifact-first return format design
- Summary artifact enforcement
- Complexity router implementation
- Progressive summarization for batch execution
- Git commit pattern differentiation
- Validation layer
- Integration testing
- Documentation updates

## Key Steps

1. **Phase 0**: Audit all consuming commands - grep for task-executor/batch-task-orchestrator references, document consumption patterns, identify all dependencies
2. **Phase 1a**: Define new return format schemas - document JSON structures, create summary templates, define validation rules
3. **Phase 1b**: Update all consuming commands - modify to expect new formats, remove dependencies on removed fields, test with mock data
4. **Phase 1c**: Implement new task-executor return format - replace verbose returns with artifact-first format (<500 tokens)
5. **Phase 2**: Enforce summary artifact creation - add summaries for research/plans/implementations
6. **Phase 3**: Implement complexity router - 7-factor scoring, simple/moderate/complex thresholds, routing differentiation
7. **Phase 4**: Update batch-task-orchestrator - progressive summarization, <50 lines per 10 tasks
8. **Phase 5**: Differentiate git commit patterns - single commit for simple tasks, commit per phase for complex tasks
9. **Phase 6**: Add validation layer - enforce return format compliance, summary requirements, token/line limits
10. **Phase 7**: Integration testing - test all scenarios, measure context window usage, verify all consumers work
11. **Phase 8**: Documentation updates - update all affected files, create migration guide, mark task complete

## Dependencies

**Phase Dependencies**:
- Phase 0 → Phase 1a (audit informs schema design)
- Phase 1a → Phase 1b (consumers need schema to update against)
- Phase 1b → Phase 1c (consumers must be ready before producers change)
- Phase 1c → Phase 2 (return format must reference summary artifacts)
- Phase 1c → Phase 4 (batch must consume new task-executor format)
- Phase 3 → Phase 5 (git patterns need complexity flag)
- Phases 1c, 2 → Phase 6 (validation needs return format and summary requirements)
- Phases 1-6 → Phase 7 (all changes must be complete for integration testing)
- Phase 7 → Phase 8 (documentation reflects tested implementation)

**External Dependencies**: None

## Success Criteria

- Single task returns <500 tokens (down from 100+ lines)
- Batch execution returns <50 lines per 10 tasks (down from 1000+ lines)
- All detailed artifacts have corresponding summary artifacts
- Zero backward compatibility code in final implementation
- All consuming commands updated and tested
- Complexity router correctly classifies tasks (simple/moderate/complex)
- Git commit patterns differentiated (single vs per-phase)
- Validation layer enforces all constraints
- All integration tests pass
- Migration guide documents breaking changes
- No runtime failures from missed consumers

## Effort Estimate Change

**v1 Estimate**: 6 hours
**v2 Estimate**: 8-9 hours

**Increase Rationale**:
- Phase 0 (Audit): +1 hour (new phase)
- Phase 1a (Schemas): +0.5 hours (new phase)
- Phase 1b (Update consumers): +1.5 hours (new phase)
- Phase 7 (Testing): +0.5 hours (test all consumers)
- **Total increase**: +3.5 hours
- **Offset**: -0.5 hours (no backward compatibility code to write)
- **Net increase**: +3 hours (6 → 9 hours)
- **Conservative estimate**: 8-9 hours (accounting for coordination overhead)

## Clean-Break Approach

**Rationale**: Eliminates technical debt, cleaner architecture, simpler long-term maintenance, no legacy support burden.

**Trade-offs**: Higher upfront coordination complexity and risk, no gradual migration, all-or-nothing deployment.

**Coordination Strategy**: Feature branch workflow, strict phase sequencing, testing gates at each phase, single atomic merge to main after Phase 7 passes.

**Rollback Plan**: All-or-nothing revert (no partial rollback), git tags at phase boundaries, comprehensive test suite to validate rollback.

## Full Plan

See: specs/169_task_command_improvements/plans/implementation-002.md
