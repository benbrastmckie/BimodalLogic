# Plan Summary: /task Command Context Window Protection

- **Version**: 001
- **Status**: [IN PROGRESS]
- **Complexity**: Complex
- **Estimated Effort**: 6 hours
- **Started**: 2025-12-24

## Key Phases

1. **Phase 1**: Update task-executor return format to artifact-first (references + 3-5 sentence summaries + metrics, <500 tokens)
2. **Phase 2**: Enforce summary artifact creation for all detailed artifacts (research, plans, implementations)
3. **Phase 3**: Implement complexity router in /task command (7-factor scoring: 0-4=simple, 5-9=moderate, 10-14=complex)
4. **Phase 4**: Update batch-task-orchestrator with progressive summarization (<50 lines per 10 tasks)
5. **Phase 5**: Differentiate git commit patterns (simple=single commit, complex=commit per phase)
6. **Phase 6**: Add validation layer for return format compliance and summary requirements
7. **Phase 7**: Integration testing (single simple, single complex, batch mixed, error scenarios, context window measurements)
8. **Phase 8**: Documentation updates (4 files + examples + migration guide)

## Execution Waves

- **Wave 1** (parallel): Phase 1 (return format) + Phase 3 (complexity router)
- **Wave 2** (parallel): Phase 2 (summaries) + Phase 4 (batch returns) + Phase 5 (git commits)
- **Wave 3**: Phase 6 (validation)
- **Wave 4**: Phase 7 (integration testing)
- **Wave 5**: Phase 8 (documentation)

## Dependencies

- **Phase 1** blocks Phase 2, Phase 4
- **Phase 3** blocks Phase 5
- **Phases 1, 2** block Phase 6
- **Phases 1-6** block Phase 7
- **Phase 7** blocks Phase 8

## Success Criteria

- task-executor returns <500 tokens per task (currently 100+ lines)
- batch-task-orchestrator returns <50 lines per 10 tasks (currently 1000+ lines)
- All detailed artifacts have corresponding summary artifacts
- Simple tasks execute with single commit, complex tasks with commit per phase
- All returns pass validation (required fields, token limits, summary existence)
- Integration tests pass for single/batch and simple/complex execution paths
- Backward compatibility maintained or migration guide provided

## Technology Stack

- **Languages**: Markdown (agent/command definitions)
- **Tools**: Git (commit pattern differentiation)
- **Standards**: status-markers.md, artifact-management.md, git-commits.md, plan.md, tasks.md

## Risks & Mitigations

- **Breaking changes**: Implement backward compatibility layer; audit consuming commands
- **Summary quality variance**: Provide templates (research-001.md Appendix C); add validation
- **Complexity misclassification**: Use robust 7-indicator scoring; allow manual overrides (--simple, --complex)
- **Too many commits**: Only commit when phase produces artifacts; allow squashing
- **Integration issues**: Comprehensive test scenarios; incremental rollout; rollback plan ready

## Full Plan

See: .opencode/specs/169_task_command_improvements/plans/implementation-001.md
