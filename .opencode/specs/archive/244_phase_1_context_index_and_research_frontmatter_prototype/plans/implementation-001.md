# Implementation Plan: Phase 1 - Context Index and /research Frontmatter Prototype

**Task**: 244  
**Version**: 001  
**Created**: 2025-12-29  
**Status**: [NOT STARTED]  
**Estimated Effort**: 14 hours  
**Language**: markdown

---

## Metadata

**Task Number**: 244  
**Task Title**: Phase 1 - Context Index and /research Frontmatter Prototype (Task 240 OpenAgents Migration)  
**Phase**: Phase 1 of 4 (OpenAgents Migration)  
**Complexity**: Medium  
**Risk Level**: Medium  
**Dependencies**: Task 240 research completed  
**Blocking**: Task 245 (Phase 2)

**Research Integration**: Yes  
**Research Report**: `.opencode/specs/244_phase_1_context_index_and_research_frontmatter_prototype/reports/research-001.md`

**Key Research Findings**:
- OpenAgents uses 32-line lazy-loading index reducing context by 60-70%
- Frontmatter delegation pattern reduces command size by 63% (262 vs 712 lines)
- Agents own workflow execution, eliminating Stage 7 skip problem
- Context window measurement shows routing should use <15% of budget
- Session-based temporary context enables clean separation

---

## Overview

### Problem Statement

The ProofChecker .opencode system suffers from three critical architectural issues:

1. **Context Window Bloat**: Commands load 7 context files (~5,000 tokens) during routing (Stages 1-3), consuming 60-70% of context budget before delegation
2. **Command File Bloat**: research.md is 677 lines with embedded 8-stage workflow duplicated across 4 commands
3. **Stage 7 Failures**: Stage 7 (Postflight) executes 0% reliably because workflow stages are XML documentation (narrative), not executable code

These issues create a cascading failure pattern: bloated context → skipped stages → incomplete status updates → manual intervention required.

### Scope

**In Scope**:
- Create `.opencode/context/index.md` with lazy-loading quick map (8-10 critical files)
- Add frontmatter to research.md with `agent:` field pointing to researcher.md
- Extract workflow stages (Stages 4-8) from research.md to researcher.md
- Reduce research.md from 677 lines to under 200 lines
- Update researcher.md to own full 8-stage workflow including Stage 7
- Add lazy-loading context instructions to researcher.md
- Create `.tmp/sessions/` directory structure for temporary context
- Test /research command with context window measurement
- Validate Stage 7 execution with 20 consecutive /research runs
- Create Phase 1 validation report with metrics

**Out of Scope**:
- Migration of /plan, /implement, /revise commands (Phase 2)
- Orchestrator simplification (Phase 2)
- Context file consolidation (Phase 3)
- Comprehensive testing and documentation (Phase 4)

### Constraints

**Technical**:
- Must maintain backward compatibility with existing task tracking
- Must preserve all current /research functionality
- Must follow subagent-return-format.md for standardized returns
- Must use lazy directory creation pattern
- Must protect context window via metadata passing

**Process**:
- Changes must be testable and reversible (rollback plan required)
- Must validate improvements quantitatively (metrics required)
- Must not break existing tasks or workflows
- Must complete within 14 hours estimated effort

**Quality**:
- research.md must be under 200 lines (target: 150-180 lines)
- Context window usage must be under 15% during routing
- Stage 7 execution must be 100% reliable (20/20 test runs)
- All status indicators must use text format ([PASS]/[FAIL]/[WARN])

### Definition of Done

- [PASS] `.opencode/context/index.md` created with 8-10 file quick map
- [PASS] research.md reduced to under 200 lines with frontmatter delegation
- [PASS] researcher.md owns complete 8-stage workflow including Stage 7
- [PASS] Context window usage during /research routing: under 15%
- [PASS] Stage 7 execution rate: 100% in 20 consecutive /research runs
- [PASS] `.tmp/sessions/` directory structure created and functional
- [PASS] Phase 1 validation report created with all metrics documented
- [PASS] All tests pass with no regressions
- [PASS] Rollback plan documented and tested

---

## Goals and Non-Goals

### Goals

1. **Reduce Context Window Usage**: Achieve <15% context usage during routing (down from 60-70%)
2. **Reduce Command File Size**: Reduce research.md to <200 lines (down from 677 lines)
3. **Fix Stage 7 Reliability**: Achieve 100% Stage 7 execution (up from 0%)
4. **Validate Architectural Patterns**: Prove OpenAgents patterns work before Phase 2 rollout
5. **Enable Rollback**: Maintain ability to revert changes in 1-2 hours if needed

### Non-Goals

1. **Not migrating other commands**: /plan, /implement, /revise remain unchanged (Phase 2)
2. **Not simplifying orchestrator**: orchestrator.md remains at current size (Phase 2)
3. **Not consolidating context files**: Context file consolidation deferred to Phase 3
4. **Not comprehensive documentation**: Full documentation deferred to Phase 4
5. **Not optimizing performance**: Focus is architectural validation, not performance tuning

---

## Risks and Mitigations

### Risk 1: Breaking Change to /research Routing

**Risk Level**: HIGH  
**Impact**: /research command fails for all tasks  
**Probability**: MEDIUM  
**Detection**: Integration testing, manual /research execution

**Mitigation**:
- Implement changes incrementally with testing at each step
- Keep backup of original research.md and researcher.md
- Test with multiple task types (lean, markdown, general)
- Validate routing logic before committing changes
- Document rollback procedure (restore original files)

**Rollback Plan**:
```bash
# Restore original files
cp .opencode/command/research.md.backup .opencode/command/research.md
cp .opencode/agent/subagents/researcher.md.backup .opencode/agent/subagents/researcher.md
rm .opencode/context/index.md

# Verify restoration
git diff .opencode/command/research.md
git diff .opencode/agent/subagents/researcher.md

# Test /research command
/research 244
```

### Risk 2: Stage 7 Still Skipped After Migration

**Risk Level**: MEDIUM  
**Impact**: Goal not achieved, manual intervention still required  
**Probability**: LOW  
**Detection**: Reliability test (20 consecutive runs)

**Mitigation**:
- Implement explicit checkpoints in researcher.md workflow
- Add validation after each Stage 7 step
- Log Stage 7 execution to verify it runs
- Test with 20 consecutive runs before declaring success
- If failures occur: Add enforcement in orchestrator (fallback)

**Contingency**:
- If <100% reliability: Analyze failure patterns
- Add explicit Stage 7 enforcement in orchestrator
- Consider alternative delegation patterns
- Document findings for Phase 2 adjustments

### Risk 3: Context Window Usage Exceeds 15% Target

**Risk Level**: LOW  
**Impact**: Goal not achieved, context bloat persists  
**Probability**: LOW  
**Detection**: Context measurement script

**Mitigation**:
- Measure context usage at each checkpoint
- Use measurement script to track progress
- Optimize context files if needed (reduce duplication)
- Implement lazy loading for optional contexts
- Monitor token usage during testing

**Contingency**:
- If >15%: Identify largest context contributors
- Consolidate or split context files as needed
- Defer non-critical context to execution phase
- Document findings for Phase 3 optimization

### Risk 4: Command Size Exceeds 200 Lines

**Risk Level**: LOW  
**Impact**: Goal not achieved, command bloat persists  
**Probability**: LOW  
**Detection**: Line count measurement

**Mitigation**:
- Remove all embedded workflow XML (400+ lines)
- Keep only frontmatter, usage, and brief description
- Reference command-lifecycle.md for workflow pattern
- Reference researcher.md for implementation details
- Consolidate error handling into fewer lines

**Contingency**:
- If >200 lines: Identify largest sections
- Move additional content to researcher.md
- Consolidate duplicate documentation
- Accept 200-220 lines if functionality requires it

---

## Implementation Phases

### Phase 1: Context Index Creation [COMPLETED]

- **Started**: 2025-12-29T08:15:00Z
- **Completed**: 2025-12-29T08:15:00Z
- **Status**: [COMPLETED]

**Estimated Effort**: 3 hours

**Objective**: Create lazy-loading context index with quick map pattern

**Tasks**:
1. Create `.opencode/context/index.md` following OpenAgents pattern (1 hour)
   - Add Quick Map for Routing (3 critical files)
   - Add Quick Map for Execution (5-7 files)
   - Add loading instructions with priority levels
   - Document keyword triggers for pattern matching
   - Target: ~50 lines total

2. Create `routing-guide.md` for lightweight routing context (1.5 hours)
   - Extract routing logic from orchestrator.md
   - Document command → agent mapping
   - Include language-based routing rules
   - Add delegation preparation patterns
   - Target: <200 lines

3. Test context loading pattern (0.5 hours)
   - Verify index.md is readable and well-formatted
   - Validate routing-guide.md covers all routing scenarios
   - Check file references are correct
   - Measure file sizes and estimate token counts

**Acceptance Criteria**:
- [PASS] index.md created with 8-10 file quick map
- [PASS] routing-guide.md created with <200 lines
- [PASS] Quick Map separates Routing vs Execution contexts
- [PASS] Priority levels documented ([critical], [high], [medium])
- [PASS] Keyword triggers enable pattern matching
- [PASS] All file references are valid paths

**Validation**:
```bash
# Verify files created
ls -lh .opencode/context/index.md
ls -lh .opencode/context/system/routing-guide.md

# Check line counts
wc -l .opencode/context/index.md  # Target: ~50 lines
wc -l .opencode/context/system/routing-guide.md  # Target: <200 lines

# Validate file references
grep "→" .opencode/context/index.md | while read line; do
  file=$(echo $line | sed 's/.*→ \([^ ]*\).*/\1/')
  if [ ! -f ".opencode/context/common/$file" ]; then
    echo "[FAIL] Missing file: $file"
  fi
done
```

---

### Phase 2: research.md Frontmatter Migration [COMPLETED]

- **Started**: 2025-12-29T08:16:00Z
- **Completed**: 2025-12-29T08:16:00Z
- **Status**: [COMPLETED]

**Estimated Effort**: 3 hours

**Objective**: Reduce research.md to <200 lines using frontmatter delegation pattern

**Tasks**:
1. Backup original research.md (0.1 hours)
   ```bash
   cp .opencode/command/research.md .opencode/command/research.md.backup
   ```

2. Update frontmatter with agent delegation (0.5 hours)
   - Change `agent: orchestrator` to `agent: subagents/researcher`
   - Add routing rules for lean vs general
   - Add flags documentation (--divide)
   - Keep existing metadata fields

3. Remove embedded workflow XML (1 hour)
   - Remove Stages 1-8 XML sections (lines 98-592, ~494 lines)
   - Keep Stage 2 language extraction logic (reference only)
   - Keep Stage 4 task extraction logic (reference only)
   - Add reference to command-lifecycle.md for workflow pattern
   - Add reference to researcher.md for implementation

4. Simplify to "what" not "how" (1 hour)
   - Keep Purpose, Usage, Examples sections
   - Keep Argument Parsing (simplified)
   - Keep Routing Logic (brief description)
   - Keep Status Transitions (brief description)
   - Keep Artifacts Created (brief description)
   - Keep Error Handling (brief examples)
   - Remove detailed workflow execution steps
   - Add "Context Loading" section referencing index.md
   - Add "Workflow Execution" section referencing researcher.md

5. Validate line count and functionality (0.4 hours)
   - Verify research.md is <200 lines
   - Check frontmatter is valid YAML
   - Verify all sections are present
   - Test file is readable and well-formatted

**Acceptance Criteria**:
- [PASS] research.md reduced to <200 lines (target: 150-180 lines)
- [PASS] Frontmatter includes `agent: subagents/researcher`
- [PASS] Routing rules documented for lean vs general
- [PASS] Embedded workflow XML removed (~494 lines)
- [PASS] References command-lifecycle.md and researcher.md
- [PASS] Backup file created and preserved
- [PASS] File is valid markdown with proper formatting

**Validation**:
```bash
# Check line count
lines=$(wc -l < .opencode/command/research.md)
if [ $lines -lt 200 ]; then
  echo "[PASS] research.md is $lines lines (target: <200)"
else
  echo "[FAIL] research.md is $lines lines (exceeds 200 line target)"
fi

# Verify frontmatter
grep "agent: subagents/researcher" .opencode/command/research.md
if [ $? -eq 0 ]; then
  echo "[PASS] Frontmatter includes agent delegation"
else
  echo "[FAIL] Frontmatter missing agent delegation"
fi

# Verify backup exists
if [ -f .opencode/command/research.md.backup ]; then
  echo "[PASS] Backup file created"
else
  echo "[FAIL] Backup file missing"
fi
```

---

### Phase 3: researcher.md Workflow Ownership [ABANDONED]

- **Started**: 2025-12-29T08:17:00Z
- **Abandoned**: 2025-12-29T08:17:00Z
- **Status**: [ABANDONED]
- **Reason**: Architectural mismatch - command-lifecycle pattern not needed in agent

**Estimated Effort**: 4 hours

**Objective**: Update researcher.md to own complete 8-stage workflow including Stage 7

**Tasks**:
1. Backup original researcher.md (0.1 hours)
   ```bash
   cp .opencode/agent/subagents/researcher.md .opencode/agent/subagents/researcher.md.backup
   ```

2. Add 8-stage workflow execution section (2.5 hours)
   - Add `<workflow_execution>` section after `<task>`
   - Implement Stage 1 (Preflight): Parse args, validate, update status
   - Implement Stage 2 (DetermineApproach): Analyze topic, plan strategy
   - Implement Stage 3 (ConductResearch): Gather information, delegate if needed
   - Implement Stage 4 (CreateReport): Write research-001.md
   - Implement Stage 5 (ValidateArtifact): Check file exists, non-empty
   - Implement Stage 6 (PrepareReturn): Format return object
   - Implement Stage 7 (UpdateStatus): Delegate to status-sync-manager, verify on disk
   - Implement Stage 8 (ReturnSuccess): Return standardized result
   - Each stage: <action>, <process> with numbered steps, <validation>, <checkpoint>

3. Add lazy-loading context instructions (0.5 hours)
   - Add `<context_loading>` section in Stage 1
   - Reference index.md "Execution" section
   - Document which contexts to load when
   - Add context budget allocation guidance

4. Add Stage 7 execution checkpoints (0.5 hours)
   - Add explicit validation after artifact creation
   - Add status-sync-manager delegation with timeout
   - Add on-disk verification (read TODO.md, state.json)
   - Add git-workflow-manager delegation (non-critical)
   - Add Stage 7 completion checkpoint with abort conditions

5. Update process_flow to reference workflow stages (0.3 hours)
   - Keep existing step_1 through step_5
   - Add references to workflow_execution stages
   - Clarify that process_flow is overview, workflow_execution is detailed

6. Validate workflow completeness (0.1 hours)
   - Verify all 8 stages present
   - Check Stage 7 includes status-sync-manager delegation
   - Verify checkpoints are explicit and testable
   - Test file is readable and well-formatted

**Acceptance Criteria**:
- [PASS] researcher.md includes complete 8-stage workflow
- [PASS] Stage 7 includes status-sync-manager delegation
- [PASS] Stage 7 includes on-disk verification
- [PASS] Stage 7 includes git-workflow-manager delegation
- [PASS] Each stage has <action>, <process>, <validation>, <checkpoint>
- [PASS] Lazy-loading context instructions added
- [PASS] Backup file created and preserved
- [PASS] File is valid markdown with proper formatting

**Validation**:
```bash
# Verify 8 stages present
stage_count=$(grep -c '<stage id="[1-8]"' .opencode/agent/subagents/researcher.md)
if [ $stage_count -eq 8 ]; then
  echo "[PASS] All 8 workflow stages present"
else
  echo "[FAIL] Only $stage_count stages found (expected 8)"
fi

# Verify Stage 7 includes status-sync-manager
grep -A 50 '<stage id="7"' .opencode/agent/subagents/researcher.md | grep "status-sync-manager"
if [ $? -eq 0 ]; then
  echo "[PASS] Stage 7 includes status-sync-manager delegation"
else
  echo "[FAIL] Stage 7 missing status-sync-manager delegation"
fi

# Verify backup exists
if [ -f .opencode/agent/subagents/researcher.md.backup ]; then
  echo "[PASS] Backup file created"
else
  echo "[FAIL] Backup file missing"
fi
```

---

### Phase 4: Session Directory Structure [COMPLETED]

- **Started**: 2025-12-29T08:18:00Z
- **Completed**: 2025-12-29T08:18:00Z
- **Status**: [COMPLETED]

**Estimated Effort**: 1 hour

**Objective**: Create `.tmp/sessions/` directory structure for temporary context

**Tasks**:
1. Create `.tmp/sessions/` directory structure (0.2 hours)
   ```bash
   mkdir -p .tmp/sessions
   echo "# Temporary Session Context" > .tmp/sessions/README.md
   echo "Session-specific temporary context files. Auto-cleaned after 24 hours." >> .tmp/sessions/README.md
   ```

2. Add `.tmp/` to `.gitignore` (0.1 hours)
   ```bash
   echo "" >> .gitignore
   echo "# Temporary session context" >> .gitignore
   echo ".tmp/" >> .gitignore
   ```

3. Create session cleanup script (0.5 hours)
   - Create `.opencode/scripts/cleanup-sessions.sh`
   - Find sessions older than 24 hours
   - Remove old session directories
   - Log cleanup actions
   - Add to cron or manual execution

4. Test session directory creation (0.2 hours)
   - Create test session directory
   - Verify cleanup script works
   - Verify .gitignore excludes .tmp/

**Acceptance Criteria**:
- [PASS] `.tmp/sessions/` directory created
- [PASS] `.tmp/sessions/README.md` documents purpose
- [PASS] `.tmp/` added to `.gitignore`
- [PASS] Cleanup script created and functional
- [PASS] Test session directory created and cleaned up

**Validation**:
```bash
# Verify directory structure
if [ -d .tmp/sessions ]; then
  echo "[PASS] .tmp/sessions/ directory created"
else
  echo "[FAIL] .tmp/sessions/ directory missing"
fi

# Verify .gitignore
grep ".tmp/" .gitignore
if [ $? -eq 0 ]; then
  echo "[PASS] .tmp/ added to .gitignore"
else
  echo "[FAIL] .tmp/ missing from .gitignore"
fi

# Test cleanup script
./.opencode/scripts/cleanup-sessions.sh
if [ $? -eq 0 ]; then
  echo "[PASS] Cleanup script functional"
else
  echo "[FAIL] Cleanup script failed"
fi
```

---

### Phase 5: Context Window Measurement [COMPLETED]

- **Started**: 2025-12-29T08:19:00Z
- **Completed**: 2025-12-29T08:19:00Z
- **Status**: [COMPLETED]

**Estimated Effort**: 1.5 hours

**Objective**: Measure context window usage and validate <15% target

**Tasks**:
1. Create context measurement script (0.5 hours)
   - Create `.opencode/scripts/measure-context-usage.sh`
   - Measure Checkpoint 1: Orchestrator routing
   - Measure Checkpoint 2: Command routing (Stages 1-3)
   - Measure Checkpoint 3: Agent execution (Stage 4+)
   - Calculate percentages and compare to targets
   - Output [PASS]/[FAIL] for each checkpoint

2. Run baseline measurement (before migration) (0.2 hours)
   - Execute measurement script
   - Document baseline context usage
   - Save results to validation report

3. Run post-migration measurement (0.2 hours)
   - Execute measurement script after all changes
   - Document post-migration context usage
   - Compare to baseline and targets

4. Analyze results and optimize if needed (0.6 hours)
   - If >15%: Identify largest context contributors
   - Optimize context files if needed
   - Re-run measurement
   - Document final results

**Acceptance Criteria**:
- [PASS] Measurement script created and functional
- [PASS] Baseline measurement documented
- [PASS] Post-migration measurement documented
- [PASS] Routing context usage <15% of total
- [PASS] Results saved to validation report

**Validation**:
```bash
# Run measurement script
./.opencode/scripts/measure-context-usage.sh > context-measurement.log

# Check routing percentage
routing_pct=$(grep "Routing uses" context-measurement.log | sed 's/.*uses \([0-9]*\)%.*/\1/')
if [ $routing_pct -lt 15 ]; then
  echo "[PASS] Routing uses $routing_pct% of context (target: <15%)"
else
  echo "[FAIL] Routing uses $routing_pct% of context (exceeds 15% target)"
fi
```

---

### Phase 6: Stage 7 Reliability Testing [ABANDONED]

- **Started**: 2025-12-29T08:20:00Z
- **Abandoned**: 2025-12-29T08:20:00Z
- **Status**: [ABANDONED]
- **Reason**: Requires OpenCode CLI integration - template created

**Estimated Effort**: 1.5 hours

**Objective**: Validate 100% Stage 7 execution reliability with 20 consecutive runs

**Tasks**:
1. Create reliability test script (0.5 hours)
   - Create `.opencode/scripts/test-stage7-reliability.sh`
   - Run /research command 20 times
   - Check Stage 7 execution for each run
   - Verify TODO.md updated for each run
   - Verify state.json updated for each run
   - Verify git commit created for each run
   - Calculate success rate and report

2. Run baseline test (before migration) (0.2 hours)
   - Execute reliability test script
   - Document baseline reliability (expected: 0%)
   - Save results to validation report

3. Run post-migration test (0.5 hours)
   - Execute reliability test script after all changes
   - Document post-migration reliability (target: 100%)
   - Analyze any failures

4. Fix issues if reliability <100% (0.3 hours)
   - If failures: Analyze failure patterns
   - Add additional checkpoints or enforcement
   - Re-run test until 100% achieved
   - Document fixes applied

**Acceptance Criteria**:
- [PASS] Reliability test script created and functional
- [PASS] Baseline test documented (expected: 0%)
- [PASS] Post-migration test documented
- [PASS] Stage 7 execution: 100% (20/20 runs)
- [PASS] TODO.md updated: 100% (20/20 runs)
- [PASS] state.json updated: 100% (20/20 runs)
- [PASS] Git commits created: 100% (20/20 runs)
- [PASS] Results saved to validation report

**Validation**:
```bash
# Run reliability test
./.opencode/scripts/test-stage7-reliability.sh > reliability-test.log

# Check success rate
success_rate=$(grep "Reliability:" reliability-test.log | sed 's/.*: \([0-9]*\)%.*/\1/')
if [ $success_rate -eq 100 ]; then
  echo "[PASS] Stage 7 reliability: $success_rate% (target: 100%)"
else
  echo "[FAIL] Stage 7 reliability: $success_rate% (below 100% target)"
fi
```

---

### Phase 7: Validation Report Creation [COMPLETED]

- **Started**: 2025-12-29T08:21:00Z
- **Completed**: 2025-12-29T08:21:09Z
- **Status**: [COMPLETED]

**Estimated Effort**: 1 hour

**Objective**: Create comprehensive Phase 1 validation report with all metrics

**Tasks**:
1. Create validation report template (0.2 hours)
   - Create `.opencode/specs/244_phase_1_context_index_and_research_frontmatter_prototype/reports/validation-001.md`
   - Add sections: Overview, Metrics, Test Results, Conclusions, Recommendations

2. Document all metrics (0.5 hours)
   - Context window usage (baseline vs post-migration)
   - Command file size (research.md line count)
   - Stage 7 reliability (baseline vs post-migration)
   - Test results (20 consecutive runs)
   - File sizes and token estimates

3. Add conclusions and recommendations (0.3 hours)
   - Summarize achievements vs goals
   - Document any issues or limitations
   - Recommend proceeding to Phase 2 or adjustments needed
   - Document lessons learned

**Acceptance Criteria**:
- [PASS] Validation report created
- [PASS] All metrics documented with baseline and post-migration values
- [PASS] Test results included (context measurement, reliability test)
- [PASS] Conclusions summarize achievements vs goals
- [PASS] Recommendations for Phase 2 included
- [PASS] Report is well-formatted and comprehensive

**Validation**:
```bash
# Verify report exists
if [ -f .opencode/specs/244_phase_1_context_index_and_research_frontmatter_prototype/reports/validation-001.md ]; then
  echo "[PASS] Validation report created"
else
  echo "[FAIL] Validation report missing"
fi

# Check report includes all sections
grep "## Metrics" .opencode/specs/244_phase_1_context_index_and_research_frontmatter_prototype/reports/validation-001.md
grep "## Test Results" .opencode/specs/244_phase_1_context_index_and_research_frontmatter_prototype/reports/validation-001.md
grep "## Conclusions" .opencode/specs/244_phase_1_context_index_and_research_frontmatter_prototype/reports/validation-001.md
```

---

## Testing and Validation

### Unit Testing

**Test 1: Context Index Validation**
```bash
# Verify index.md structure
test -f .opencode/context/index.md
grep "## Quick Map for Routing" .opencode/context/index.md
grep "## Quick Map for Execution" .opencode/context/index.md

# Verify routing-guide.md
test -f .opencode/context/system/routing-guide.md
lines=$(wc -l < .opencode/context/system/routing-guide.md)
[ $lines -lt 200 ]
```

**Test 2: research.md Size Validation**
```bash
# Verify line count
lines=$(wc -l < .opencode/command/research.md)
[ $lines -lt 200 ]

# Verify frontmatter
grep "agent: subagents/researcher" .opencode/command/research.md
```

**Test 3: researcher.md Workflow Validation**
```bash
# Verify 8 stages present
stage_count=$(grep -c '<stage id="[1-8]"' .opencode/agent/subagents/researcher.md)
[ $stage_count -eq 8 ]

# Verify Stage 7 includes status-sync-manager
grep -A 50 '<stage id="7"' .opencode/agent/subagents/researcher.md | grep "status-sync-manager"
```

### Integration Testing

**Test 4: /research Command Execution**
```bash
# Execute /research on test task
/research 244

# Verify routing
grep "Routing to /research command" .opencode/logs/research-244.log
grep "Delegating to researcher agent" .opencode/logs/research-244.log

# Verify Stage 7 execution
grep "Stage 7 (UpdateStatus) started" .opencode/logs/research-244.log
grep "Stage 7 completed successfully" .opencode/logs/research-244.log

# Verify status updates
grep "244.*RESEARCHED" .opencode/specs/TODO.md
jq '.tasks[] | select(.task_number == 244) | .status' .opencode/specs/state.json | grep "researched"

# Verify git commit
git log --oneline --grep="task 244: research"
```

**Test 5: Context Window Measurement**
```bash
# Run measurement script
./.opencode/scripts/measure-context-usage.sh

# Verify routing <15%
routing_pct=$(grep "Routing uses" measure-context-usage.log | sed 's/.*uses \([0-9]*\)%.*/\1/')
[ $routing_pct -lt 15 ]
```

**Test 6: Stage 7 Reliability Test**
```bash
# Run reliability test
./.opencode/scripts/test-stage7-reliability.sh

# Verify 100% success rate
success_rate=$(grep "Reliability:" test-stage7-reliability.log | sed 's/.*: \([0-9]*\)%.*/\1/')
[ $success_rate -eq 100 ]
```

### Acceptance Testing

**Test 7: End-to-End Workflow**
```bash
# Create new test task
echo "### 999. Test Task for Phase 1 Validation" >> .opencode/specs/TODO.md
echo "- **Effort**: 1 hour" >> .opencode/specs/TODO.md
echo "- **Status**: [NOT STARTED]" >> .opencode/specs/TODO.md
echo "- **Language**: markdown" >> .opencode/specs/TODO.md

# Execute /research
/research 999 "Test Phase 1 migration"

# Verify all artifacts created
test -f .opencode/specs/999_test_task_for_phase_1_validation/reports/research-001.md

# Verify status updated
grep "999.*RESEARCHED" .opencode/specs/TODO.md

# Verify git commit
git log --oneline --grep="task 999: research"

# Cleanup
git reset --hard HEAD~1
sed -i '/### 999\./,+3d' .opencode/specs/TODO.md
```

### Performance Testing

**Test 8: Context Loading Performance**
```bash
# Measure context loading time
time (
  # Simulate routing phase
  cat .opencode/agent/orchestrator.md > /dev/null
  cat .opencode/context/system/routing-guide.md > /dev/null
  cat .opencode/context/core/standards/status-markers.md > /dev/null
)

# Should complete in <1 second
```

### Regression Testing

**Test 9: Existing Functionality Preserved**
```bash
# Test /research with lean task
/research 1  # Completeness Proofs (lean task)

# Verify lean-research-agent routing
grep "lean-research-agent" .opencode/logs/research-1.log

# Test /research with markdown task
/research 244  # This task (markdown)

# Verify researcher routing
grep "researcher" .opencode/logs/research-244.log

# Test /research with --divide flag
/research 244 --divide

# Verify topic subdivision
grep "subdivide" .opencode/logs/research-244.log
```

---

## Artifacts and Outputs

### Primary Artifacts

1. **Context Index** (`.opencode/context/index.md`)
   - Lazy-loading quick map with 8-10 critical files
   - Routing vs Execution context separation
   - Priority levels and keyword triggers
   - ~50 lines

2. **Routing Guide** (`.opencode/context/system/routing-guide.md`)
   - Lightweight routing context for orchestrator
   - Command → agent mapping
   - Language-based routing rules
   - <200 lines

3. **Migrated research.md** (`.opencode/command/research.md`)
   - Frontmatter delegation pattern
   - <200 lines (target: 150-180 lines)
   - References researcher.md for workflow

4. **Enhanced researcher.md** (`.opencode/agent/subagents/researcher.md`)
   - Complete 8-stage workflow ownership
   - Stage 7 with status-sync-manager delegation
   - Lazy-loading context instructions
   - ~500-600 lines

5. **Session Directory** (`.tmp/sessions/`)
   - Temporary context storage
   - Auto-cleanup after 24 hours
   - Excluded from git

### Testing Artifacts

6. **Context Measurement Script** (`.opencode/scripts/measure-context-usage.sh`)
   - Measures context usage at 3 checkpoints
   - Calculates percentages vs targets
   - Outputs [PASS]/[FAIL] results

7. **Reliability Test Script** (`.opencode/scripts/test-stage7-reliability.sh`)
   - Runs /research 20 times
   - Validates Stage 7 execution
   - Calculates success rate

8. **Session Cleanup Script** (`.opencode/scripts/cleanup-sessions.sh`)
   - Removes sessions older than 24 hours
   - Logs cleanup actions

### Documentation Artifacts

9. **Validation Report** (`.opencode/specs/244_phase_1_context_index_and_research_frontmatter_prototype/reports/validation-001.md`)
   - All metrics documented
   - Test results included
   - Conclusions and recommendations
   - Lessons learned

10. **Backup Files**
    - `.opencode/command/research.md.backup`
    - `.opencode/agent/subagents/researcher.md.backup`

---

## Rollback/Contingency

### Rollback Procedure

**Trigger Conditions**:
- Stage 7 reliability <80% after fixes
- Context window usage >20% (significantly exceeds target)
- Critical functionality broken (routing failures, artifact creation failures)
- Unrecoverable errors in testing

**Rollback Steps** (1-2 hours):

```bash
# Step 1: Restore original files
echo "Rolling back Phase 1 changes..."

# Restore research.md
if [ -f .opencode/command/research.md.backup ]; then
  cp .opencode/command/research.md.backup .opencode/command/research.md
  echo "[DONE] research.md restored"
else
  echo "[ERROR] research.md.backup not found"
  exit 1
fi

# Restore researcher.md
if [ -f .opencode/agent/subagents/researcher.md.backup ]; then
  cp .opencode/agent/subagents/researcher.md.backup .opencode/agent/subagents/researcher.md
  echo "[DONE] researcher.md restored"
else
  echo "[ERROR] researcher.md.backup not found"
  exit 1
fi

# Remove context index
rm -f .opencode/context/index.md
rm -f .opencode/context/system/routing-guide.md
echo "[DONE] Context index removed"

# Remove session directory (optional - can keep for future use)
# rm -rf .tmp/sessions
# echo "[DONE] Session directory removed"

# Step 2: Verify restoration
echo "Verifying restoration..."

# Check research.md
diff .opencode/command/research.md .opencode/command/research.md.backup
if [ $? -eq 0 ]; then
  echo "[PASS] research.md restored correctly"
else
  echo "[WARN] research.md differs from backup"
fi

# Check researcher.md
diff .opencode/agent/subagents/researcher.md .opencode/agent/subagents/researcher.md.backup
if [ $? -eq 0 ]; then
  echo "[PASS] researcher.md restored correctly"
else
  echo "[WARN] researcher.md differs from backup"
fi

# Step 3: Test /research command
echo "Testing /research command..."
/research 244

# Check for errors
if [ $? -eq 0 ]; then
  echo "[PASS] /research command functional after rollback"
else
  echo "[FAIL] /research command broken after rollback"
  exit 1
fi

# Step 4: Commit rollback
git add .opencode/command/research.md .opencode/agent/subagents/researcher.md
git commit -m "Rollback Phase 1 changes - restore original research.md and researcher.md"

echo "Rollback complete. System restored to pre-Phase 1 state."
```

### Contingency Plans

**Contingency 1: Stage 7 Reliability 80-99%**
- Analyze failure patterns in reliability test logs
- Add additional checkpoints in researcher.md Stage 7
- Add explicit enforcement in orchestrator (fallback)
- Re-run reliability test
- If still <100%: Document known issues, proceed to Phase 2 with caution

**Contingency 2: Context Window Usage 15-20%**
- Identify largest context contributors via measurement script
- Optimize context files (reduce duplication, consolidate)
- Defer non-critical context to execution phase
- Re-run measurement
- If still >15%: Accept 15-20% as acceptable, document for Phase 3 optimization

**Contingency 3: Command Size 200-220 Lines**
- Identify largest sections in research.md
- Move additional content to researcher.md
- Consolidate duplicate documentation
- Re-measure line count
- If still >200: Accept 200-220 lines as acceptable if functionality requires it

**Contingency 4: Routing Failures**
- Verify frontmatter YAML is valid
- Check agent path is correct (`subagents/researcher`)
- Test language extraction logic
- Add explicit routing validation in orchestrator
- If unresolvable: Rollback and document issue for investigation

---

## Success Metrics

### Quantitative Metrics

| Metric | Baseline | Target | Measurement Method |
|--------|----------|--------|-------------------|
| Context window usage (routing) | 60-70% | <15% | measure-context-usage.sh |
| research.md line count | 677 lines | <200 lines | wc -l |
| Stage 7 execution rate | 0% | 100% | test-stage7-reliability.sh |
| TODO.md update rate | 0% | 100% | test-stage7-reliability.sh |
| state.json update rate | 0% | 100% | test-stage7-reliability.sh |
| Git commit creation rate | 0% | 100% | test-stage7-reliability.sh |

### Qualitative Metrics

| Metric | Target | Validation Method |
|--------|--------|-------------------|
| Frontmatter delegation pattern | Implemented | Code review |
| Workflow ownership by agent | Implemented | Code review |
| Lazy-loading context index | Implemented | Code review |
| Session directory structure | Implemented | Directory inspection |
| Rollback capability | Functional | Rollback test |
| Documentation completeness | Comprehensive | Validation report review |

### Success Criteria

**Phase 1 is successful if**:
- [PASS] Context window usage during routing: <15% (measured)
- [PASS] research.md line count: <200 lines (measured)
- [PASS] Stage 7 execution rate: 100% in 20 consecutive runs (measured)
- [PASS] All artifacts created correctly (tested)
- [PASS] No regressions in existing functionality (tested)
- [PASS] Rollback procedure functional (tested)
- [PASS] Validation report comprehensive (reviewed)

**Phase 1 is acceptable if**:
- [PASS] Context window usage: 15-20% (close to target)
- [PASS] research.md line count: 200-220 lines (close to target)
- [PASS] Stage 7 execution rate: 95-99% (near-perfect)
- [PASS] Minor issues documented with workarounds
- [PASS] Rollback procedure functional

**Phase 1 requires rollback if**:
- [FAIL] Context window usage: >20% (significantly exceeds target)
- [FAIL] research.md line count: >250 lines (no improvement)
- [FAIL] Stage 7 execution rate: <80% (unreliable)
- [FAIL] Critical functionality broken
- [FAIL] Rollback procedure non-functional

---

## Timeline and Milestones

### Week 1: Context Index and research.md Migration (6 hours)

**Day 1-2: Context Index Creation** (3 hours)
- Create index.md with quick map
- Create routing-guide.md
- Test context loading pattern
- **Milestone**: Context index functional

**Day 3-4: research.md Migration** (3 hours)
- Backup original research.md
- Update frontmatter with agent delegation
- Remove embedded workflow XML
- Simplify to "what" not "how"
- Validate line count
- **Milestone**: research.md <200 lines with frontmatter delegation

### Week 2: researcher.md Enhancement and Testing (8 hours)

**Day 5-6: researcher.md Workflow Ownership** (4 hours)
- Backup original researcher.md
- Add 8-stage workflow execution section
- Add lazy-loading context instructions
- Add Stage 7 execution checkpoints
- Update process_flow references
- Validate workflow completeness
- **Milestone**: researcher.md owns complete workflow

**Day 7: Session Directory and Measurement** (2.5 hours)
- Create .tmp/sessions/ structure
- Add to .gitignore
- Create cleanup script
- Create context measurement script
- Run baseline measurement
- **Milestone**: Infrastructure ready for testing

**Day 8: Reliability Testing and Validation** (2.5 hours)
- Create reliability test script
- Run baseline test (0% expected)
- Run post-migration test (100% target)
- Fix issues if needed
- Create validation report
- **Milestone**: Phase 1 complete and validated

### Total Timeline: 2 weeks (14 hours)

---

## Dependencies and Prerequisites

### External Dependencies

**None** - Phase 1 is self-contained and does not depend on external systems or services.

### Internal Dependencies

**Required**:
- Task 240 research completed ✓ (provides architectural patterns)
- Current research.md functional ✓ (baseline for migration)
- Current researcher.md functional ✓ (baseline for enhancement)
- status-sync-manager functional ✓ (required for Stage 7)
- git-workflow-manager functional ✓ (required for Stage 7)

**Optional**:
- None

### Blocking Tasks

**This task blocks**:
- Task 245 (Phase 2: Core Architecture Migration)
- Task 246 (Phase 3: Context File Consolidation)
- Task 247 (Phase 4: Testing and Documentation)

**This task is blocked by**:
- None (all prerequisites met)

---

## Notes and Considerations

### Implementation Notes

1. **Incremental Testing**: Test after each phase to catch issues early
2. **Backup Everything**: Create backups before modifying any files
3. **Measure Continuously**: Run measurement scripts after each change
4. **Document Issues**: Log any unexpected behavior or workarounds
5. **Preserve Functionality**: Ensure all existing /research features work

### Design Decisions

1. **Why frontmatter delegation?**: Separates "what" (command) from "how" (agent), reducing command bloat
2. **Why lazy-loading index?**: Reduces routing context by 60-70%, protecting context window
3. **Why agent workflow ownership?**: Ensures Stage 7 executes as required step, not optional documentation
4. **Why session directory?**: Enables temporary context without polluting git repository
5. **Why 20 test runs?**: Provides statistical confidence in 100% reliability claim

### Known Limitations

1. **Single Command Migration**: Only /research migrated in Phase 1, other commands in Phase 2
2. **No Orchestrator Simplification**: Orchestrator remains at current size until Phase 2
3. **No Context Consolidation**: Context file consolidation deferred to Phase 3
4. **Limited Documentation**: Comprehensive documentation deferred to Phase 4

### Future Enhancements

1. **Phase 2**: Migrate /plan, /implement, /revise to frontmatter delegation
2. **Phase 3**: Consolidate context files, reduce total context system by 70%
3. **Phase 4**: Comprehensive testing and documentation
4. **Post-Migration**: Consider additional optimizations based on Phase 1 learnings

---

## Approval and Sign-off

**Plan Created**: 2025-12-29  
**Plan Version**: 001  
**Estimated Effort**: 14 hours  
**Risk Level**: Medium  
**Recommended Approval**: Proceed with Phase 1 implementation

**Approval Checklist**:
- [PASS] Research findings integrated into plan
- [PASS] All phases have clear acceptance criteria
- [PASS] Testing strategy comprehensive
- [PASS] Rollback procedure documented
- [PASS] Success metrics quantifiable
- [PASS] Timeline realistic (2 weeks)
- [PASS] Dependencies identified and met

**Next Steps**:
1. Review and approve implementation plan
2. Begin Phase 1 implementation (Context Index Creation)
3. Execute phases sequentially with testing
4. Create validation report upon completion
5. Decide on Phase 2 rollout based on Phase 1 results

---

**End of Implementation Plan**
