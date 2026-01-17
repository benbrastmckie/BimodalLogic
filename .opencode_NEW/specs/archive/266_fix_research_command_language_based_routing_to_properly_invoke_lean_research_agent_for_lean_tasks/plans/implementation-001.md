# Implementation Plan: Fix /research Command Language-Based Routing

- **Task**: 266 - Fix /research command language-based routing to properly invoke lean-research-agent for Lean tasks
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/266_fix_research_command_language_based_routing_to_properly_invoke_lean_research_agent_for_lean_tasks/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

The orchestrator does NOT implement Stage 2 (DetermineRouting) as documented, causing Lean research tasks to route to the default `researcher` agent instead of `lean-research-agent`. This results in "phantom research" where task status is updated to [RESEARCHED] but no artifacts are created. The fix requires implementing Stage 2 in the orchestrator to extract language from TODO.md and route based on command frontmatter routing configuration. Success is defined as: (1) Lean tasks route to lean-research-agent, (2) artifact validation prevents phantom research, (3) all existing non-lean workflows continue working, and (4) tasks 258 and 257 can be re-researched successfully with artifacts created.

## Goals & Non-Goals

**Goals:**
- Implement Stage 2 (DetermineRouting) in orchestrator with language extraction logic
- Add routing table lookup and agent selection based on command frontmatter
- Add routing validation to catch language/agent mismatches
- Add artifact validation to prevent phantom research (status without artifacts)
- Fix applies to both `/research` and `/implement` commands
- Maintain backward compatibility with existing non-lean task workflows
- Enable successful re-research of tasks 258 and 257 with artifact creation

**Non-Goals:**
- Refactoring the entire orchestrator architecture
- Adding support for languages beyond lean (extensible but not implemented)
- Changing command frontmatter structure beyond routing configuration
- Modifying agent implementations (lean-research-agent, researcher, etc.)
- Implementing routing for commands beyond /research and /implement

## Risks & Mitigations

- **Risk:** Orchestrator changes break existing commands. **Mitigation:** Comprehensive regression testing with both lean and non-lean tasks; rollback plan ready.
- **Risk:** Language extraction fails for edge cases (missing Language field, malformed TODO.md). **Mitigation:** Robust fallback to "general" default; clear error messages; validation logging.
- **Risk:** Routing validation too strict, blocks valid cases. **Mitigation:** Careful validation logic testing; allow language="general" to route to any agent.
- **Risk:** Artifact validation false positives (agent creates artifacts but validation fails). **Mitigation:** Only validate when status=completed; check file existence AND non-zero size.
- **Risk:** Performance overhead from language extraction. **Mitigation:** Language extraction is fast (grep + sed), measured <1s overhead acceptable.

## Implementation Phases

### Phase 1: Implement Language Extraction Logic [NOT STARTED]

- **Goal:** Add language extraction from TODO.md and state.json to orchestrator Stage 2
- **Tasks:**
  - [ ] Read orchestrator.md Stage 2 documentation (lines 87-123)
  - [ ] Implement `extract_language()` helper function in orchestrator
  - [ ] Priority 1: Extract from project state.json if exists
  - [ ] Priority 2: Extract from TODO.md **Language** field using grep
  - [ ] Priority 3: Default to "general" if not found
  - [ ] Add logging for language extraction: `[INFO] Task {N} language: {lang}`
  - [ ] Test extraction with tasks 258 (lean), 256 (markdown), and edge cases
- **Timing:** 1.5 hours

### Phase 2: Implement Routing Table Lookup and Agent Selection [NOT STARTED]

- **Goal:** Add routing configuration reading and agent mapping to orchestrator Stage 2
- **Tasks:**
  - [ ] Read command frontmatter routing configuration (routing.language_based, routing.lean, routing.default)
  - [ ] Implement routing logic: if language_based=true, map language to agent using routing table
  - [ ] If language="lean": use routing.lean agent (lean-research-agent or lean-implementation-agent)
  - [ ] Else: use routing.default agent (researcher or implementer)
  - [ ] Update delegation_path with resolved agent name
  - [ ] Add logging for routing decision: `[INFO] Routing to {agent} (language={lang})`
  - [ ] Test routing with /research and /implement commands
- **Timing:** 1.5 hours

### Phase 3: Add Routing Validation and Error Handling [NOT STARTED]

- **Goal:** Add validation to catch language/agent mismatches and prevent incorrect routing
- **Tasks:**
  - [ ] Implement `validate_routing()` helper function in orchestrator
  - [ ] Validate agent file exists at `.opencode/agent/subagents/{agent}.md`
  - [ ] Validate lean routing: if language="lean", agent must start with "lean-"
  - [ ] Validate non-lean routing: if language!="lean", agent must NOT start with "lean-"
  - [ ] Return clear error messages for validation failures
  - [ ] Add logging for validation: `[PASS] Routing validation succeeded` or `[FAIL] Routing mismatch: language={lang} but agent={agent}`
  - [ ] Test validation with forced incorrect routing scenarios
- **Timing:** 1 hour

### Phase 4: Add Artifact Validation to Prevent Phantom Research [NOT STARTED]

- **Goal:** Add validation in orchestrator Stage 4 to ensure completed status has artifacts
- **Tasks:**
  - [ ] Implement `validate_artifacts()` helper function in orchestrator Stage 4 (ValidateReturn)
  - [ ] If agent returns status="completed", verify artifacts array is non-empty
  - [ ] For each artifact in array, verify file exists and is non-empty (size > 0)
  - [ ] If validation fails, reject agent return with status="failed"
  - [ ] Return clear error: "Agent returned 'completed' status but created no artifacts"
  - [ ] Add logging for artifact validation: `[PASS] {N} artifacts validated` or `[FAIL] Artifact does not exist: {path}`
  - [ ] Test with mock agent returns (completed with no artifacts, completed with empty files)
- **Timing:** 1 hour

### Phase 5: Update Documentation and Add Examples [NOT STARTED]

- **Goal:** Update documentation to reflect implementation and provide troubleshooting guidance
- **Tasks:**
  - [ ] Update `.opencode/agent/orchestrator.md` Stage 2 with implementation details
  - [ ] Update `.opencode/context/core/system/routing-guide.md` with troubleshooting section
  - [ ] Update `.opencode/command/research.md` to clarify language-based routing behavior
  - [ ] Update `.opencode/command/implement.md` to clarify language-based routing behavior
  - [ ] Add examples for lean vs markdown routing in documentation
  - [ ] Add logging examples to routing-guide.md
  - [ ] Document rollback procedure if routing fails
- **Timing:** 0.5 hours

### Phase 6: Test with Lean Tasks and Verify Artifacts [NOT STARTED]

- **Goal:** Validate fix works for lean tasks (258, 257) and creates artifacts
- **Tasks:**
  - [ ] Reset task 258 status to [NOT STARTED] (clear phantom research)
  - [ ] Reset task 257 status to [NOT STARTED] (clear phantom research)
  - [ ] Invoke `/research 258` and verify lean-research-agent is called
  - [ ] Verify task 258 artifacts created: reports/research-001.md exists and non-empty
  - [ ] Verify task 258 state.json updated with artifacts array
  - [ ] Invoke `/research 257` and verify lean-research-agent is called
  - [ ] Verify task 257 artifacts created: reports/research-001.md exists and non-empty
  - [ ] Verify task 257 state.json updated with artifacts array
  - [ ] Check orchestrator logs for correct routing decisions
- **Timing:** 0.5 hours

### Phase 7: Validate Non-Lean Tasks Still Work Correctly [NOT STARTED]

- **Goal:** Ensure backward compatibility with existing markdown/python/general task workflows
- **Tasks:**
  - [ ] Test `/research` with markdown task (e.g., task 256 or new test task)
  - [ ] Verify researcher agent is called (not lean-research-agent)
  - [ ] Verify artifacts created successfully
  - [ ] Test `/implement` with markdown task (if available)
  - [ ] Verify implementer agent is called (not lean-implementation-agent)
  - [ ] Test routing validation does NOT block valid non-lean routing
  - [ ] Test artifact validation does NOT block valid non-lean artifacts
  - [ ] Run regression tests for /plan and /revise commands (no language-based routing)
  - [ ] Verify all existing workflows continue working
- **Timing:** 0.5 hours

## Testing & Validation

**Functional Tests:**
- [ ] Lean research task routes to lean-research-agent (test with task 258)
- [ ] Lean research task creates artifacts (reports/research-001.md exists)
- [ ] Markdown research task routes to researcher (test with task 256)
- [ ] Markdown research task creates artifacts (backward compatibility)
- [ ] Language extraction works from TODO.md **Language** field
- [ ] Language extraction falls back to "general" if field missing
- [ ] Routing validation catches lean task routed to non-lean agent
- [ ] Routing validation catches non-lean task routed to lean agent
- [ ] Artifact validation prevents status=completed with no artifacts
- [ ] Artifact validation prevents status=completed with empty artifacts

**Non-Functional Tests:**
- [ ] No regression in existing /plan, /revise, /task commands
- [ ] Orchestrator context window usage remains <15%
- [ ] Routing adds <1s overhead (measured)
- [ ] Logging provides clear audit trail for debugging
- [ ] Error messages are clear and actionable

**Success Metrics:**
- [ ] 0 phantom research occurrences after fix
- [ ] 100% correct routing for lean tasks (tasks 258, 257)
- [ ] 100% correct routing for non-lean tasks (task 256, others)
- [ ] All language-based routing commands work correctly

## Artifacts & Outputs

**Primary Artifacts:**
- `specs/266_fix_research_command_language_based_routing_to_properly_invoke_lean_research_agent_for_lean_tasks/plans/implementation-001.md` (this file)
- `specs/266_fix_research_command_language_based_routing_to_properly_invoke_lean_research_agent_for_lean_tasks/summaries/implementation-summary-20260103.md` (created on completion)

**Modified Files:**
- `.opencode/agent/orchestrator.md` (Stage 2 implementation, Stage 4 artifact validation)
- `.opencode/context/core/system/routing-guide.md` (implementation details, troubleshooting)
- `.opencode/command/research.md` (clarify language-based routing)
- `.opencode/command/implement.md` (clarify language-based routing)

**Validation Artifacts:**
- `specs/258_resolve_truth_lean_sorries/reports/research-001.md` (created after fix)
- `specs/257_completeness_proofs/reports/research-001.md` (created after fix)

## Rollback/Contingency

**If orchestrator changes break existing commands:**
1. Revert `.opencode/agent/orchestrator.md` to previous version using git
2. Run `git revert {commit_hash}` for the routing implementation commit
3. Document failure in task 266 notes
4. Create new task to investigate alternative routing approach

**If routing validation too strict:**
1. Add override flag to routing validation: `routing.skip_validation: true`
2. Log warning instead of failing for validation mismatches
3. Document override usage in routing-guide.md

**If artifact validation causes false positives:**
1. Adjust validation to only check file existence (not size)
2. Add grace period for artifact creation (retry after 5s)
3. Log warning instead of failing for missing artifacts

**Rollback Steps:**
```bash
# Identify commit hash for routing implementation
git log --oneline -10

# Revert the commit
git revert {commit_hash}

# Verify rollback
git diff HEAD~1

# Test existing commands still work
/research {test_task_number}
/implement {test_task_number}
```

## Success Criteria

**Implementation Complete When:**
- [ ] All 7 phases marked [COMPLETED]
- [ ] All functional tests pass
- [ ] All non-functional tests pass
- [ ] Task 258 can be researched successfully with artifacts
- [ ] Task 257 can be researched successfully with artifacts
- [ ] No regression in existing commands
- [ ] Documentation updated and accurate
- [ ] Git commit created with changes

**Definition of Done:**
- Lean research tasks route to lean-research-agent
- Artifact validation prevents phantom research
- All existing non-lean workflows continue working
- Tasks 258 and 257 can be re-researched with artifacts created
- 0 phantom research occurrences after fix
- Documentation matches implementation
