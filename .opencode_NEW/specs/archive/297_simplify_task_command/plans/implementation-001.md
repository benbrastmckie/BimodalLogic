# Implementation Plan: Simplify /task Command

**Task Number**: 297  
**Task Title**: Simplify /task command to directly create tasks without subagent delegation  
**Status**: [NOT STARTED]  
**Estimated Total Effort**: 6 hours  
**Language**: markdown  
**Priority**: High  
**Created**: 2026-01-05  
**Plan Version**: 001  

---

## Overview

### Problem Statement

The current /task command uses an overcomplicated delegation architecture (description-clarifier → task-creator → status-sync-manager) that adds unnecessary complexity, timeout overhead (420s), and context window bloat (~1100 lines). The main branch implementation (380 lines, 5 stages, NO delegation, <5s) is exactly what we want - simple, fast, and direct file operations.

### Scope

**In Scope**:
- Revert to main branch task.md as base (380 lines, 5 stages)
- Add atomic updates via status-sync-manager (only improvement over main branch)
- Preserve flag support: --priority, --effort, --language
- Preserve keyword-based language detection (fast, simple)
- Remove description-clarifier and task-creator subagents
- Maintain execution time <10s (vs 420s current)

**Out of Scope**:
- --divide flag implementation (deferred to future task)
- AI-based description clarification
- Research-based language detection
- Web search for unfamiliar terms

### Constraints

- Must maintain atomic updates (both TODO.md and state.json or neither)
- Must preserve task creation standards (tasks.md compliance)
- Must support existing flags (--priority, --effort, --language)
- Must execute in <10s (vs 420s current)
- Must follow main branch philosophy: "Direct file operations only. No subagent delegation."

### Definition of Done

- [ ] task.md reverted to main branch approach (5 stages, ~200 lines)
- [ ] Atomic updates via status-sync-manager working correctly
- [ ] Flag support preserved (--priority, --effort, --language)
- [ ] Keyword-based language detection working
- [ ] description-clarifier and task-creator marked deprecated
- [ ] Execution time <10s verified
- [ ] All tests passing
- [ ] Documentation updated

---

## Goals and Non-Goals

### Goals

1. **Simplicity**: Revert to main branch's simple, direct implementation
2. **Speed**: Reduce execution time from 420s to <10s
3. **Atomic Updates**: Add status-sync-manager for atomic TODO.md + state.json updates
4. **Maintainability**: Remove ~1100 lines of unnecessary subagent code
5. **Standards Compliance**: Maintain tasks.md compliance

### Non-Goals

1. **AI-based clarification**: No research-based description enhancement
2. **Task subdivision**: --divide flag deferred to future task
3. **Web search**: No external research for unfamiliar terms
4. **Backward compatibility**: Removing description-clarifier and task-creator is breaking change

---

## Risks and Mitigations

### Risk 1: Description Quality
**Risk**: Inline reformulation may be less sophisticated than research-based approach  
**Likelihood**: Medium  
**Impact**: Low  
**Mitigation**: User can provide complete description; simple transformations (capitalize, add period) are sufficient  
**Contingency**: Add optional --research flag if quality is insufficient

### Risk 2: Language Detection Accuracy
**Risk**: Keyword-based detection may be less accurate than research-based  
**Likelihood**: Low  
**Impact**: Low  
**Mitigation**: User can override with --language flag; keyword patterns cover 90% of cases  
**Contingency**: Expand keyword patterns based on user feedback

### Risk 3: Breaking Changes
**Risk**: Removing subagents may break existing workflows  
**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**: Mark subagents as deprecated with clear migration path  
**Contingency**: Keep subagents as optional fallback for complex cases

---

## Implementation Phases

### Phase 1: Revert to Main Branch Base [NOT STARTED]
**Estimated Effort**: 1.5 hours  
**Dependencies**: None

**Objectives**:
- Copy main branch task.md as starting point
- Preserve 5-stage structure
- Preserve flag parsing logic
- Preserve validation logic

**Tasks**:
1. Fetch main branch task.md (origin/main:.opencode/command/task.md)
2. Copy to current branch as task.md.main-backup
3. Review main branch implementation:
   - Stage 1: ParseInput (parse description, extract flags, detect language)
   - Stage 2: ReadNextNumber (read next_project_number from state.json)
   - Stage 3: CreateTODOEntry (format TODO.md entry)
   - Stage 4: UpdateStateJson (update state.json)
   - Stage 5: ReturnSuccess (return task number)
4. Identify sections to preserve:
   - Flag parsing (--priority, --effort, --language)
   - Language detection (keyword matching)
   - Validation (description length, required fields)
   - TODO.md entry formatting
   - state.json entry formatting

**Acceptance Criteria**:
- [ ] Main branch task.md fetched and reviewed
- [ ] 5-stage structure documented
- [ ] Flag parsing logic identified
- [ ] Validation logic identified
- [ ] Entry formatting logic identified

**Testing**:
- Manual review of main branch implementation
- Comparison with current branch implementation

---

### Phase 2: Implement Atomic Updates via status-sync-manager [NOT STARTED]
**Estimated Effort**: 2 hours  
**Dependencies**: Phase 1

**Objectives**:
- Replace direct file operations with status-sync-manager delegation
- Maintain atomic updates (both files or neither)
- Preserve rollback on failure

**Tasks**:
1. Replace Stage 3-4 (CreateTODOEntry + UpdateStateJson) with:
   - Stage 3: PrepareEntries (format TODO.md and state.json entries)
   - Stage 4: AtomicUpdate (delegate to status-sync-manager)
2. Implement PrepareEntries stage:
   - Format TODO.md entry following tasks.md standard
   - Format state.json entry with all required fields
   - Validate entries before delegation
3. Implement AtomicUpdate stage:
   - Prepare delegation context for status-sync-manager
   - Include operation="create_task"
   - Include task_number, title, description, priority, effort, language
   - Include timestamp and session_id
4. Handle status-sync-manager return:
   - Parse status field (completed/failed)
   - Extract error details if failed
   - Verify both files updated on success

**Acceptance Criteria**:
- [ ] PrepareEntries stage formats entries correctly
- [ ] AtomicUpdate stage delegates to status-sync-manager
- [ ] Both TODO.md and state.json updated atomically
- [ ] Rollback works on failure
- [ ] Error handling provides clear messages

**Testing**:
- Test successful task creation
- Test rollback on TODO.md write failure
- Test rollback on state.json write failure
- Verify both files updated or neither

---

### Phase 3: Preserve Flag Support and Language Detection [NOT STARTED]
**Estimated Effort**: 1 hour  
**Dependencies**: Phase 2

**Objectives**:
- Preserve --priority, --effort, --language flags
- Implement keyword-based language detection
- Maintain defaults (Medium priority, TBD effort)

**Tasks**:
1. Preserve flag parsing from main branch:
   - Extract --priority flag (default: Medium)
   - Extract --effort flag (default: TBD)
   - Extract --language flag (optional)
2. Implement keyword-based language detection:
   - lean: keywords (lean, proof, theorem, lemma, tactic)
   - markdown: keywords (markdown, doc, readme, documentation)
   - meta: keywords (command, agent, context, workflow, subagent)
   - python: keywords (python, script, .py)
   - shell: keywords (shell, bash, .sh)
   - json: keywords (json, yaml, toml, config)
   - general: default if no keywords match
3. Implement flag override logic:
   - If --language provided, use it (override detection)
   - If --priority provided, use it (override default)
   - If --effort provided, use it (override default)
4. Validate language field is set (MANDATORY per tasks.md)

**Acceptance Criteria**:
- [ ] --priority flag works correctly
- [ ] --effort flag works correctly
- [ ] --language flag works correctly
- [ ] Keyword-based detection works for common cases
- [ ] Language field always set (never null)
- [ ] Defaults applied correctly

**Testing**:
- Test with --priority High
- Test with --effort "4 hours"
- Test with --language lean
- Test language detection for "Fix proof in Foo.lean"
- Test language detection for "Update README documentation"
- Test language detection for "Create /sync command"

---

### Phase 4: Remove Subagent Dependencies [NOT STARTED]
**Estimated Effort**: 1 hour  
**Dependencies**: Phase 3

**Objectives**:
- Remove description-clarifier delegation
- Remove task-creator delegation
- Mark subagents as deprecated
- Update documentation

**Tasks**:
1. Remove description-clarifier delegation:
   - Delete Stage 2 (ClarifyDescription) from task.md
   - Remove description-clarifier invocation
   - Remove clarification result parsing
2. Remove task-creator delegation:
   - Delete Stage 3 (CreateTask) delegation
   - Inline task creation logic into task.md
3. Mark subagents as deprecated:
   - Add deprecation notice to description-clarifier.md
   - Add deprecation notice to task-creator.md
   - Document replacement: "/task command with inline implementation"
4. Update documentation:
   - Update task.md usage examples
   - Remove references to description-clarifier
   - Remove references to task-creator
   - Document new 5-stage workflow

**Acceptance Criteria**:
- [ ] description-clarifier delegation removed
- [ ] task-creator delegation removed
- [ ] Subagents marked deprecated
- [ ] Documentation updated
- [ ] No references to removed subagents

**Testing**:
- Verify task.md has no subagent invocations
- Verify deprecation notices in subagent files
- Review documentation for accuracy

---

### Phase 5: Testing and Validation [NOT STARTED]
**Estimated Effort**: 1.5 hours  
**Dependencies**: Phase 4

**Objectives**:
- Verify all functionality works correctly
- Measure execution time (<10s)
- Validate atomic updates
- Test edge cases

**Tasks**:
1. Test basic task creation:
   - `/task "Fix bug in Foo.lean"`
   - Verify task created in TODO.md
   - Verify task created in state.json
   - Verify next_project_number incremented
2. Test with flags:
   - `/task "Add feature X" --priority High --effort "4 hours"`
   - Verify priority set to High
   - Verify effort set to "4 hours"
3. Test language detection:
   - `/task "Implement completeness proof"` → lean
   - `/task "Update README documentation"` → markdown
   - `/task "Create /sync command"` → meta
4. Test atomic updates:
   - Simulate TODO.md write failure
   - Verify state.json not updated (rollback)
   - Simulate state.json write failure
   - Verify TODO.md not updated (rollback)
5. Measure execution time:
   - Run `/task` 10 times
   - Measure average execution time
   - Verify <10s (target: <5s)
6. Test edge cases:
   - Empty description (should fail)
   - Description too short (<50 chars, should fail)
   - Description too long (>500 chars, should fail)
   - Invalid priority (should fail)
   - Missing language (should detect or fail)

**Acceptance Criteria**:
- [ ] Basic task creation works
- [ ] Flag support works
- [ ] Language detection works
- [ ] Atomic updates work
- [ ] Execution time <10s
- [ ] Edge cases handled correctly
- [ ] Error messages clear and actionable

**Testing**:
- Manual testing of all scenarios
- Automated testing if possible
- Performance measurement
- Edge case validation

---

## Testing and Validation

### Unit Tests
- Flag parsing (--priority, --effort, --language)
- Language detection (keyword matching)
- Description validation (length, required fields)
- Entry formatting (TODO.md, state.json)

### Integration Tests
- Atomic updates (both files or neither)
- Rollback on failure
- status-sync-manager delegation
- next_project_number increment

### Performance Tests
- Execution time <10s (target: <5s)
- Context window usage (minimal)
- Timeout overhead (minimal)

### Edge Case Tests
- Empty description
- Description too short/long
- Invalid priority/effort
- Missing language
- File write failures

---

## Artifacts and Outputs

### Primary Artifacts
1. **task.md** (.opencode/command/task.md)
   - Refactored command file (~200 lines)
   - 5-stage workflow
   - Inline implementation
   - status-sync-manager delegation

### Deprecated Artifacts
1. **description-clarifier.md** (.opencode/agent/subagents/description-clarifier.md)
   - Marked deprecated
   - Deprecation notice added
2. **task-creator.md** (.opencode/agent/subagents/task-creator.md)
   - Marked deprecated
   - Deprecation notice added

### Documentation Updates
1. **task.md** - Usage examples updated
2. **tasks.md** - Command integration updated
3. **Architecture documentation** - Workflow diagrams updated

---

## Rollback/Contingency

### Rollback Plan
If refactored implementation fails:
1. Restore current task.md from backup
2. Restore description-clarifier.md
3. Restore task-creator.md
4. Revert documentation changes
5. Document issues encountered

### Contingency Options
1. **Keep subagents as optional**: Add --research flag to invoke description-clarifier
2. **Gradual migration**: Support both old and new workflows during transition
3. **Expand keyword patterns**: Improve language detection accuracy
4. **Add validation**: Enhance description validation to catch issues early

---

## Success Metrics

### Performance Metrics
- Execution time: <10s (vs 420s current) - **Target: <5s**
- Context window usage: ~200 lines (vs ~1100 lines current)
- Lines of code: ~200 (vs 1570 current)

### Quality Metrics
- Task creation success rate: >95%
- Language detection accuracy: >90%
- Atomic update reliability: 100%
- Rollback success rate: 100%

### User Experience Metrics
- Clear error messages: 100% of failures
- Flag support: 100% preserved
- Standards compliance: 100% (tasks.md)

---

## Research Integration

This plan integrates findings from two research reports:

### Research Report 001 (research-001.md)
- Current delegation chain analysis
- description-clarifier functionality (300s timeout, 473 lines)
- task-creator functionality (120s timeout, 642 lines)
- Atomic update requirements
- Flag parsing requirements
- Language detection approaches

### Research Report 002 (research-002-main-branch-comparison.md)
- **Main branch implementation**: 380 lines, 5 stages, NO delegation, <5s
- **Current branch implementation**: 454 lines, 3 stages, 2 delegations, 420s
- **Key insight**: Main branch got it right - simple, fast, direct file operations
- **Recommendation**: Revert to main branch approach with ONE improvement (atomic updates)
- **Philosophy**: "Direct file operations only. No subagent delegation."

### Key Research Findings Applied
1. Main branch implementation is the model to follow
2. Only improvement needed: atomic updates via status-sync-manager
3. Keyword-based language detection is sufficient (fast, accurate)
4. Inline description reformulation is sufficient (simple transformations)
5. Remove description-clarifier and task-creator (unnecessary complexity)

---

## Notes

### Design Philosophy
Following main branch philosophy:
- **Direct file operations only**
- **No subagent delegation** (except status-sync-manager for atomic updates)
- **Fast execution** (<10s, target <5s)
- **Minimal context** (no subagent loading)
- **Inline operations** (parse, validate, format in command)
- **Clear errors** (actionable error messages)

### Anti-Patterns to Avoid
1. ❌ Research-based language detection (use keyword matching)
2. ❌ Description clarification via research (use simple transformations)
3. ❌ Metadata extraction via research (use flags + defaults)
4. ❌ Multiple subagent delegations (minimize delegation)
5. ❌ Long timeouts (keep fast)

### Future Enhancements (Out of Scope)
1. --divide flag for task subdivision (deferred to future task)
2. --research flag for optional description clarification
3. AI-based subdivision for complex tasks
4. Web search for unfamiliar terms

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 001 | 2026-01-05 | Planner | Initial implementation plan created |

