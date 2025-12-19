# Plan Summary: Enhance `/task` Command with Intelligent Agent Routing

**Version**: 001  
**Complexity**: Complex  
**Estimated Effort**: 65-70 hours

## Key Steps

1. **Phase 1: Create CRITICAL Specialist Agents** (12-16 hours)
   - Create tactic-specialist for tactic-based LEAN proofs
   - Create term-mode-specialist for term-mode LEAN proofs
   - Create metaprogramming-specialist for custom tactics
   - Integrate all 3 with proof-developer coordinator

2. **Phase 2: Enhance Task Type Detection** (8-12 hours)
   - Implement multi-factor task type detection algorithm
   - Add classification system for 7 task types
   - Update task-executor with detection logic
   - Preserve backward compatibility

3. **Phase 3: Coordinator Integration** (10-14 hours)
   - Add RouteToCoordinator stage to task-executor
   - Integrate routing for all 7 coordinators
   - Update TODO.md status tracking for end-to-end execution
   - Implement error handling

4. **Phase 4: Create Remaining Specialists** (18-24 hours)
   - Create 11 remaining specialist agents (research, planning, refactoring, documentation, meta)
   - Prioritize HIGH priority specialists first (lean-search, loogle)
   - Integrate with respective coordinators

5. **Phase 5: Comprehensive Testing** (9-13 hours)
   - Unit tests for task type detection
   - Integration tests for coordinator routing
   - End-to-end tests for all task types
   - Regression tests for backward compatibility
   - Performance benchmarks

## Dependencies

- **Phase 1 blocks**: All LEAN proof task execution
- **Phase 2 depends on**: Phase 1 (can start in parallel)
- **Phase 3 depends on**: Phase 1 and Phase 2
- **Phase 4 depends on**: Phase 3 (can be incremental)
- **Phase 5 runs**: Continuously throughout all phases

## Success Criteria

- `/task` can execute LEAN proof tasks end-to-end (no manual `/lean` needed)
- `/task` can execute documentation tasks end-to-end (no manual `/implement` needed)
- `/task` can execute refactoring tasks end-to-end
- All 7 task types route to appropriate coordinator
- TODO.md status tracking works correctly (IN PROGRESS → COMPLETE)
- Backward compatibility maintained (no breaking changes)
- Task type detection accuracy > 90%
- All tests pass (unit, integration, end-to-end, regression)

## Full Plan

See: `.opencode/specs/006_enhance_task_routing/plans/implementation-001.md`
