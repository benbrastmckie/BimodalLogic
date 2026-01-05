# Implementation Plan: Add Report Detection to Planner

- **Task**: 300 - Add Report Detection to Planner
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: research-001.md (Report detection strategy, filesystem timestamps, 4-phase approach)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Enhance the planner subagent to detect new research reports created since the last plan version and integrate their findings into plan revisions. Current planner harvests ALL research but cannot distinguish reports already integrated into previous plan versions from newly created reports. This implementation adds temporal awareness using filesystem timestamps (mtime) to detect new reports, extends plan_metadata schema to track integrated reports, and generates integration summaries showing what research informed each plan version. The solution enables incremental research incorporation during plan revisions, improving plan quality and providing clear audit trails of research evolution.

### Research Integration

This plan integrates findings from 1 research report:

**Integrated Reports**:
- **research-001.md** (2026-01-05): Report detection strategy and implementation approach
  - Key Finding: Current planner lacks temporal awareness - treats all research as new during revisions
  - Key Finding: Filesystem timestamps (mtime) provide simple, reliable detection mechanism
  - Key Finding: plan_metadata schema needs reports_integrated array for tracking
  - Recommendation: Implement in 4 phases (schema, detection, harvesting, postflight) - 4 hours total
  - Recommendation: Use filesystem stat command for timestamp comparison
  - Recommendation: Add integration summary to plan Overview section

## Goals & Non-Goals

**Goals**:
- Detect new research reports created after last plan version using filesystem timestamps
- Extend plan_metadata schema with reports_integrated array for tracking
- Generate integration summaries showing new vs previously integrated reports
- Update planner workflow to filter and process only new reports during revisions
- Maintain backward compatibility with existing plans lacking reports_integrated field
- Provide clear audit trail of which reports informed which plan versions

**Non-Goals**:
- Report versioning or revision tracking (research-001-v2.md) - future enhancement
- Report dependency tracking (which reports supersede others) - out of scope
- Automated research summarization from report metadata - future enhancement
- Report quality metrics or confidence levels - out of scope
- Changes to report.md standard or report creation workflow - separate concern

## Risks & Mitigations

**Risk 1: Filesystem Timestamp Reliability**
- **Risk**: Reports manually edited after creation will have updated mtimes, causing false positives (old reports detected as new)
- **Likelihood**: Low (reports typically not edited per artifact-management.md)
- **Impact**: Medium (redundant integration, but not incorrect)
- **Mitigation**: Document in artifact-management.md that reports should not be edited after creation; add validation warning if report mtime is very recent during revision

**Risk 2: State.json and Plan File Inconsistency**
- **Risk**: state.json plan_path points to non-existent plan file, or plan exists but not referenced in state.json
- **Likelihood**: Low (status-sync-manager ensures atomic updates)
- **Impact**: High (planner cannot determine last plan version)
- **Mitigation**: Add validation in planner step_1 to verify plan_path file exists if set; abort with recovery instructions if inconsistent

**Risk 3: Reports Directory Missing or Empty**
- **Risk**: Reports directory doesn't exist or contains no research reports
- **Likelihood**: Medium (valid scenario for tasks without research)
- **Impact**: Low (planner should proceed without research)
- **Mitigation**: Add defensive checks in planner step_2; log info message and proceed if missing/empty

**Risk 4: Clock Skew Between Plan and Report Creation**
- **Risk**: System clock changes between plan and report creation may cause incorrect timestamp comparison
- **Likelihood**: Very Low (modern systems use NTP)
- **Impact**: Medium (missed new reports or false positives)
- **Mitigation**: Use UTC timestamps consistently; add sanity check for future timestamps with warning

## Implementation Phases

### Phase 1: Extend Plan Metadata Schema [NOT STARTED]

- **Goal**: Add reports_integrated field to plan_metadata schema and update documentation
- **Tasks**:
  - [ ] Update .opencode/context/core/standards/plan.md to document reports_integrated field in metadata section
  - [ ] Add reports_integrated schema example: array of objects with path, integrated_in_plan_version, integrated_date
  - [ ] Update .opencode/context/core/system/state-management.md to document reports_integrated in plan_metadata schema
  - [ ] Update .opencode/context/core/system/artifact-management.md to document report editing policy (no edits after creation)
  - [ ] Add backward compatibility note: existing plans without reports_integrated should use empty array default
  - [ ] Validate schema changes are consistent across all documentation files
- **Timing**: 1 hour
- **Acceptance Criteria**:
  - [ ] plan.md includes reports_integrated field documentation with schema
  - [ ] state-management.md documents reports_integrated in plan_metadata section
  - [ ] artifact-management.md includes report editing policy
  - [ ] Backward compatibility documented (graceful handling of missing field)

### Phase 2: Implement Report Detection in Planner [NOT STARTED]

- **Goal**: Add report scanning and timestamp comparison logic to planner step_1
- **Tasks**:
  - [ ] Update .opencode/agent/subagents/planner.md step_1 to add plan metadata extraction for revisions
  - [ ] Add logic to extract plan_path from state.json when revision_mode is true
  - [ ] Add logic to read existing plan file and extract reports_integrated array from plan_metadata
  - [ ] Add report directory scanning logic: find all .opencode/specs/{task_number}_*/reports/research-*.md files
  - [ ] Add filesystem timestamp comparison: stat -c %Y for report mtime vs plan mtime
  - [ ] Add filtering logic to identify NEW reports (report_mtime > plan_mtime)
  - [ ] Add defensive checks: handle missing reports directory, empty directory, non-existent plan file
  - [ ] Add validation: verify plan_path file exists if plan_path set in state.json
  - [ ] Pass new_reports list to step_2 for integration
- **Timing**: 1.5 hours
- **Acceptance Criteria**:
  - [ ] Planner step_1 extracts plan_path from state.json during revisions
  - [ ] Planner reads existing plan metadata and extracts reports_integrated array
  - [ ] Report scanning logic finds all research-*.md files in reports/ directory
  - [ ] Timestamp comparison correctly identifies reports created after last plan
  - [ ] Defensive checks handle missing/empty reports directory gracefully
  - [ ] Validation aborts with error if plan_path inconsistent with filesystem
  - [ ] new_reports list passed to step_2 contains only reports with mtime > plan_mtime

### Phase 3: Enhance Research Harvesting [NOT STARTED]

- **Goal**: Update planner step_2 to process only new reports and generate integration summary
- **Tasks**:
  - [ ] Update .opencode/agent/subagents/planner.md step_2 to accept new_reports parameter from step_1
  - [ ] Add logic to distinguish first plan (all reports new) vs revision (only new_reports)
  - [ ] Update research reading logic to process only NEW reports (not all reports from TODO.md)
  - [ ] Add integration summary generation with two sections: "New Reports" and "Previously Integrated"
  - [ ] For each new report: extract key findings, recommendations, and creation date
  - [ ] Build reports_integrated metadata entries: path, integrated_in_plan_version, integrated_date
  - [ ] Add integration summary to plan Overview section as "Research Integration" subsection
  - [ ] Update step_5 plan creation to include integration summary in Overview
  - [ ] Update step_6 validation to verify reports_integrated array populated correctly
- **Timing**: 1 hour
- **Acceptance Criteria**:
  - [ ] Step_2 processes only new reports (not all reports from TODO.md)
  - [ ] Integration summary generated with "New Reports" and "Previously Integrated" sections
  - [ ] Each new report entry includes key findings and recommendations
  - [ ] reports_integrated metadata array populated with path, version, date for each new report
  - [ ] Integration summary added to plan Overview section
  - [ ] Step_6 validation checks reports_integrated array structure

### Phase 4: Update Postflight Integration [NOT STARTED]

- **Goal**: Update planner step_7 to pass reports_integrated to status-sync-manager and verify state.json update
- **Tasks**:
  - [ ] Update .opencode/agent/subagents/planner.md step_7 postflight to include reports_integrated in plan_metadata
  - [ ] Verify status-sync-manager delegation context includes updated plan_metadata with reports_integrated
  - [ ] Add validation to verify status-sync-manager writes reports_integrated to state.json
  - [ ] Test end-to-end flow: create plan with research, verify reports_integrated in state.json
  - [ ] Test revision flow: add new report, revise plan, verify only new report integrated
  - [ ] Test backward compatibility: revise old plan without reports_integrated, verify graceful handling
  - [ ] Test edge cases: missing reports directory, empty directory, no new reports
  - [ ] Document testing results and any issues found
- **Timing**: 0.5 hours
- **Acceptance Criteria**:
  - [ ] Step_7 passes reports_integrated in plan_metadata to status-sync-manager
  - [ ] status-sync-manager writes reports_integrated to state.json correctly
  - [ ] End-to-end test: first plan with research populates reports_integrated
  - [ ] Revision test: only new reports integrated, integration summary correct
  - [ ] Backward compatibility test: old plans without reports_integrated handled gracefully
  - [ ] Edge case tests pass: missing/empty reports directory, no new reports

## Testing & Validation

**Unit Tests**:
- [ ] Test report scanning logic with various directory structures (empty, missing, multiple reports)
- [ ] Test timestamp comparison with various scenarios (new reports, old reports, equal timestamps)
- [ ] Test reports_integrated metadata generation with correct schema
- [ ] Test integration summary generation with new and previously integrated reports
- [ ] Test backward compatibility with plans lacking reports_integrated field

**Integration Tests**:
- [ ] Test first plan creation with research: verify all reports integrated, reports_integrated populated
- [ ] Test plan revision with new reports: verify only new reports integrated, summary correct
- [ ] Test plan revision with no new reports: verify no redundant integration, summary indicates no new research
- [ ] Test plan revision with missing reports directory: verify graceful handling, no errors
- [ ] Test state.json update: verify reports_integrated written correctly by status-sync-manager

**Edge Case Tests**:
- [ ] Test with report mtime equal to plan mtime (boundary condition)
- [ ] Test with report mtime in future (clock skew detection)
- [ ] Test with plan_path in state.json but file missing (inconsistent state)
- [ ] Test with multiple new reports created at different times
- [ ] Test with reports directory containing non-research files (should be ignored)

**Validation Checks**:
- [ ] Verify planner.md step_1, step_2, step_5, step_6, step_7 updated correctly
- [ ] Verify plan.md, state-management.md, artifact-management.md documentation updated
- [ ] Verify all status markers use text format ([NOT STARTED], [IN PROGRESS], [COMPLETED])
- [ ] Verify no emojis in plan headings or markers
- [ ] Verify integration summary format matches research recommendation

## Artifacts & Outputs

**Primary Artifacts**:
- .opencode/specs/300_add_report_detection_to_planner/plans/implementation-001.md (this file)
- .opencode/specs/300_add_report_detection_to_planner/summaries/implementation-summary-20260105.md (created after implementation)

**Modified Files**:
- .opencode/agent/subagents/planner.md (step_1, step_2, step_5, step_6, step_7 updates)
- .opencode/context/core/standards/plan.md (reports_integrated schema documentation)
- .opencode/context/core/system/state-management.md (plan_metadata schema update)
- .opencode/context/core/system/artifact-management.md (report editing policy)

**State Updates**:
- .opencode/specs/TODO.md (status updated to [PLANNED], plan link added)
- .opencode/specs/state.json (task 300 plan_path and plan_metadata updated)

## Rollback/Contingency

**If Implementation Fails**:
1. Revert planner.md changes to restore original step_1, step_2, step_5, step_6, step_7 logic
2. Revert documentation changes to plan.md, state-management.md, artifact-management.md
3. Remove reports_integrated field from any test state.json entries
4. Document failure reason and blockers in task 300 notes
5. Consider alternative approaches: report metadata tracking instead of filesystem timestamps

**If Partial Implementation**:
1. Complete phases can remain (e.g., Phase 1 schema extension is standalone)
2. Incomplete phases should be rolled back to avoid inconsistent state
3. Update task 300 status to [BLOCKED] with clear description of what's incomplete
4. Create follow-on task for remaining phases if needed

**Backward Compatibility Guarantee**:
- Existing plans without reports_integrated field will continue to work
- Planner uses empty array default if reports_integrated missing
- No breaking changes to existing workflows or commands
- If rollback needed, existing plans remain functional

## Success Metrics

**Functional Metrics**:
- [ ] Planner correctly detects new reports using filesystem timestamps
- [ ] Plan revisions integrate only new reports (not all reports)
- [ ] Integration summary clearly shows new vs previously integrated reports
- [ ] reports_integrated metadata accurately tracks report integration history
- [ ] Backward compatibility maintained with existing plans

**Quality Metrics**:
- [ ] All unit tests pass (report scanning, timestamp comparison, metadata generation)
- [ ] All integration tests pass (first plan, revision, edge cases)
- [ ] Documentation updated and consistent across all files
- [ ] No regressions in existing planner functionality
- [ ] Code follows planner.md structure and conventions

**Performance Metrics**:
- [ ] Report detection adds minimal overhead (<1 second for typical cases)
- [ ] Filesystem stat operations complete quickly (<100ms per report)
- [ ] No performance degradation in plan creation or revision workflows

**User Experience Metrics**:
- [ ] Integration summary provides clear, actionable information
- [ ] Error messages for edge cases are helpful and actionable
- [ ] Plan revisions clearly show what research informed the update
- [ ] Audit trail enables understanding of research evolution over time
