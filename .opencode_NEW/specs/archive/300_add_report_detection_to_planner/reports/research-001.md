# Research Report: Enhance Planner to Detect and Integrate New Reports

- **Task**: 300 - Add Report Detection to Planner
- **Started**: 2026-01-05
- **Completed**: 2026-01-05
- **Effort**: 4 hours
- **Priority**: High
- **Dependencies**: None
- **Sources/Inputs**:
  - .opencode/agent/subagents/planner.md (current implementation)
  - .opencode/agent/subagents/status-sync-manager.md (artifact linking)
  - .opencode/context/core/system/artifact-management.md (artifact patterns)
  - .opencode/context/core/system/state-management.md (state tracking)
  - .opencode/context/core/standards/plan.md (plan format)
  - specs/TODO.md (task 300 requirements)
  - specs/state.json (task metadata)
- **Artifacts**: reports/research-001.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Executive Summary

Research completed on enhancing the planner subagent to detect new research reports created since the last plan version and integrate their findings into plan revisions. Current planner implementation (planner.md, 615 lines) has basic research harvesting in step_2 but lacks temporal awareness - it cannot distinguish between reports that were already integrated into previous plan versions versus newly created reports. The solution requires adding report timestamp detection, version tracking, and integration metadata to enable incremental research incorporation during plan revisions.

Key findings: (1) Current planner harvests research from TODO.md artifact links but treats all research as new, (2) No mechanism exists to track which reports were integrated into which plan versions, (3) Plan metadata lacks reports_integrated field for tracking, (4) Timestamp comparison logic needed to detect reports created after last plan, (5) Integration requires coordination between planner step_2 (research harvesting) and step_7 (postflight status updates via status-sync-manager).

## Context & Scope

### Current Planner Implementation

The planner subagent (.opencode/agent/subagents/planner.md) implements a 8-step workflow:
- **Step 0 (Preflight)**: Extract inputs, update status to [PLANNING] or [REVISING]
- **Step 1**: Read task from TODO.md
- **Step 2**: Harvest research findings if available
- **Step 3**: Analyze complexity and determine phases
- **Step 4**: Estimate effort per phase
- **Step 5**: Create implementation plan following plan.md template
- **Step 6**: Validate plan artifact created
- **Step 7 (Postflight)**: Update status to [PLANNED], create git commit
- **Step 8**: Return standardized result

**Step 2 Current Behavior** (lines 150-167):
```markdown
<step_2>
  <action>Harvest research findings if available</action>
  <process>
    1. Check extracted task entry for research artifact links
    2. If research links found:
       a. Read research report (research-001.md)
       b. Read research summary if exists
       c. Extract key findings and recommendations
       d. Incorporate into plan context
    3. If no research: Proceed without research inputs
    4. Note research inputs in plan metadata
  </process>
</step_2>
```

**Problem**: Step 2 reads ALL research artifacts linked in TODO.md but has no awareness of:
- Which reports were already integrated into previous plan versions
- Which reports are new since the last plan was created
- Temporal ordering of reports vs plans

### Artifact Management Patterns

Per artifact-management.md:
- Research reports stored in: `specs/{task_number}_{slug}/reports/research-NNN.md`
- Plans stored in: `specs/{task_number}_{slug}/plans/implementation-NNN.md`
- Plan versions increment with each revision (001, 002, 003, etc.)
- Artifact links added to TODO.md via status-sync-manager

### State Tracking

Per state.json schema (lines 283-308 in state.json):
```json
{
  "project_number": 259,
  "artifacts": [
    "specs/259_automation_tactics/reports/research-001.md",
    "specs/259_automation_tactics/plans/implementation-001.md"
  ],
  "plan_path": "specs/259_automation_tactics/plans/implementation-001.md",
  "plan_metadata": {
    "phases": 6,
    "total_effort_hours": 20,
    "complexity": "medium",
    "research_integrated": true
  }
}
```

**Current Limitation**: `plan_metadata.research_integrated` is boolean - doesn't track WHICH reports were integrated.

## Key Findings

### Finding 1: No Temporal Awareness in Research Harvesting

**Current Behavior**: Planner step_2 reads all research artifacts from TODO.md links without distinguishing between:
- Reports already integrated into previous plan versions
- Reports created after the last plan version

**Evidence**: planner.md lines 150-167 show step_2 reads research reports but has no timestamp comparison logic.

**Impact**: When /revise is called, planner re-reads ALL research (including already-integrated reports), causing:
- Redundant processing of old research
- No clear indication in revised plan of what's new
- Difficulty tracking research evolution over time

### Finding 2: Missing Report Version Tracking

**Current State**: Plan metadata tracks `research_integrated: true/false` but not:
- Which specific reports were integrated (by path or version)
- When each report was integrated
- Which plan version integrated which reports

**Evidence**: state.json plan_metadata schema (lines 301-307) shows:
```json
"plan_metadata": {
  "phases": 6,
  "total_effort_hours": 20,
  "complexity": "medium",
  "research_integrated": true  // Boolean only
}
```

**Recommendation**: Extend plan_metadata to include:
```json
"plan_metadata": {
  "phases": 6,
  "total_effort_hours": 20,
  "complexity": "medium",
  "research_integrated": true,
  "reports_integrated": [
    {
      "path": "specs/300_add_report_detection_to_planner/reports/research-001.md",
      "integrated_in_plan_version": 1,
      "integrated_date": "2026-01-05"
    }
  ]
}
```

### Finding 3: Plan Revision Workflow Lacks Report Detection

**Current /revise Workflow**:
1. User runs `/revise {task_number}`
2. Command extracts task metadata from state.json
3. Command invokes planner with `revision_context` parameter
4. Planner step_0 detects revision mode, updates status to [REVISING]
5. Planner step_2 harvests research (but treats all as new)
6. Planner creates new plan version (implementation-002.md, etc.)
7. Planner step_7 updates status to [REVISED]

**Missing Step**: Between step_1 and step_2, planner needs to:
1. Detect existing plan version (from state.json plan_path)
2. Read existing plan metadata to get reports_integrated list
3. Scan reports/ directory for all research reports
4. Compare report modification times with plan creation time
5. Identify NEW reports (created after last plan)
6. Pass new reports to step_2 for integration

### Finding 4: Filesystem Timestamp Detection Required

**Implementation Approach**: Use filesystem modification times (mtime) to detect new reports.

**Algorithm**:
```bash
# 1. Get last plan creation time
last_plan_path=$(jq -r '.active_projects[] | select(.project_number == 300) | .plan_path' state.json)
last_plan_mtime=$(stat -c %Y "$last_plan_path")  # Unix timestamp

# 2. Scan reports directory
reports_dir="specs/300_add_report_detection_to_planner/reports"
for report in "$reports_dir"/research-*.md; do
  report_mtime=$(stat -c %Y "$report")
  
  # 3. Compare timestamps
  if [ "$report_mtime" -gt "$last_plan_mtime" ]; then
    echo "NEW REPORT: $report (created after last plan)"
    new_reports+=("$report")
  else
    echo "OLD REPORT: $report (already integrated)"
  fi
done

# 4. Pass new_reports to step_2 for integration
```

**Edge Cases**:
- First plan (no previous plan): All reports are "new"
- No reports directory: Proceed without research
- Reports directory exists but empty: Proceed without research
- Plan file missing but plan_path in state.json: Error (inconsistent state)

### Finding 5: Integration Points in Planner Workflow

**Required Changes**:

**Step 0 (Preflight)** - Add revision detection:
- Extract plan_version from delegation context (provided by /revise)
- If plan_version > 1: revision_mode = true
- Pass revision_mode to subsequent steps

**Step 1 (Read Task)** - Add plan metadata extraction:
- If revision_mode: Extract plan_path from state.json
- Read existing plan file to get plan_metadata
- Extract reports_integrated list from plan_metadata
- Pass to step_2 for comparison

**Step 2 (Harvest Research)** - Add new report detection:
- If revision_mode:
  * Scan reports/ directory for all research-*.md files
  * Get filesystem mtime for each report
  * Get last plan creation time from plan file or state.json
  * Compare timestamps: report_mtime > plan_mtime = NEW
  * Filter to only NEW reports
- Else (first plan):
  * All reports are "new"
- Read and incorporate NEW reports only
- Update plan_metadata.reports_integrated with new entries

**Step 5 (Create Plan)** - Add integration notes:
- In plan Overview section, add subsection:
  ```markdown
  ### Research Integration
  - Integrated 2 new reports since last plan version:
    - research-002.md (created 2026-01-05): Key findings on X
    - research-003.md (created 2026-01-06): Analysis of Y
  - Previously integrated reports (from plan v1):
    - research-001.md: Initial research on Z
  ```

**Step 6 (Validate)** - Add metadata validation:
- Verify plan_metadata.reports_integrated array populated
- Verify each entry has path, integrated_in_plan_version, integrated_date

**Step 7 (Postflight)** - Update state.json with new metadata:
- Pass updated plan_metadata to status-sync-manager
- status-sync-manager updates state.json with reports_integrated

### Finding 6: Status-Sync-Manager Integration

**Current Behavior**: status-sync-manager accepts plan_metadata parameter (lines 107-109):
```markdown
<parameter name="plan_metadata" type="object" optional="true">
  Plan metadata extracted by planner (phase_count, estimated_hours, complexity)
</parameter>
```

**Required Change**: Extend plan_metadata schema to include reports_integrated:
```json
{
  "phases": 5,
  "total_effort_hours": 8,
  "complexity": "medium",
  "research_integrated": true,
  "reports_integrated": [
    {
      "path": "reports/research-001.md",
      "integrated_in_plan_version": 1,
      "integrated_date": "2026-01-05"
    }
  ]
}
```

**Impact**: No code changes needed in status-sync-manager - it already passes plan_metadata to state.json as-is. Schema extension is backward compatible (new field, existing fields unchanged).

## Detailed Analysis

### Report Detection Strategy

**Approach 1: Filesystem Timestamps (Recommended)**

**Pros**:
- Simple implementation (stat command)
- No additional metadata files needed
- Works with existing artifact structure
- Reliable (filesystem guarantees mtime updates)

**Cons**:
- Assumes reports not manually edited after creation
- Timezone considerations (use UTC timestamps)
- File copy operations may preserve old mtimes

**Implementation**:
```bash
# Get last plan creation time (Unix timestamp)
last_plan_mtime=$(stat -c %Y "$last_plan_path" 2>/dev/null || echo 0)

# Scan reports directory
for report in specs/${task_number}_*/reports/research-*.md; do
  [ -f "$report" ] || continue
  report_mtime=$(stat -c %Y "$report")
  
  if [ "$report_mtime" -gt "$last_plan_mtime" ]; then
    new_reports+=("$report")
  fi
done
```

**Approach 2: Report Metadata Tracking (Alternative)**

**Pros**:
- Explicit tracking of report creation dates
- Independent of filesystem
- Can track report revisions

**Cons**:
- Requires additional metadata in report files
- More complex implementation
- Requires report.md standard updates

**Not Recommended**: Adds complexity without significant benefit over filesystem timestamps.

### Integration Approach for Report Findings

**Current Step 2 Process**:
1. Check TODO.md for research artifact links
2. Read research-001.md
3. Extract key findings and recommendations
4. Incorporate into plan context

**Enhanced Step 2 Process**:
1. Determine revision mode (first plan vs revision)
2. If revision:
   a. Read existing plan metadata to get reports_integrated list
   b. Scan reports/ directory for all research-*.md files
   c. Compare report mtimes with last plan mtime
   d. Filter to NEW reports only
3. Else (first plan):
   a. All reports are "new"
4. For each NEW report:
   a. Read report file
   b. Extract key findings and recommendations
   c. Add to plan context
   d. Record in reports_integrated metadata
5. Generate integration summary for plan Overview

**Integration Summary Format**:
```markdown
### Research Integration

This plan integrates findings from 2 new research reports created since plan v1:

**New Reports**:
- **research-002.md** (2026-01-05): Analysis of modal logic proof strategies
  - Key Finding: Aesop integration reduces proof search time by 40%
  - Recommendation: Prioritize Aesop rule implementation in Phase 1
  
- **research-003.md** (2026-01-06): Performance benchmarking results
  - Key Finding: Current proof search timeout insufficient for complex goals
  - Recommendation: Increase timeout from 5s to 15s in Phase 3

**Previously Integrated** (from plan v1):
- research-001.md: Initial research on automation tactics
```

### Recommended Implementation Approach

**Phase 1: Extend Plan Metadata Schema** (1 hour)
1. Update plan.md standard to include reports_integrated field
2. Update planner.md step_6 validation to check reports_integrated
3. Document schema in state-management.md

**Phase 2: Implement Report Detection in Planner** (1.5 hours)
1. Add report scanning logic to planner step_1
2. Add timestamp comparison logic
3. Add new report filtering
4. Pass new reports to step_2

**Phase 3: Enhance Research Harvesting** (1 hour)
1. Update planner step_2 to accept new_reports parameter
2. Add integration summary generation
3. Update plan_metadata with reports_integrated entries
4. Add integration notes to plan Overview section

**Phase 4: Update Postflight Integration** (0.5 hours)
1. Update planner step_7 to pass reports_integrated to status-sync-manager
2. Verify status-sync-manager writes reports_integrated to state.json
3. Test end-to-end flow

**Total Estimated Effort**: 4 hours (matches task estimate)

## Decisions

### Decision 1: Use Filesystem Timestamps for Report Detection

**Rationale**: Simplest approach that works with existing artifact structure. Filesystem mtimes are reliable and require no additional metadata files.

**Alternative Considered**: Report metadata tracking in report files. Rejected due to added complexity without significant benefit.

### Decision 2: Track Reports at Plan Version Granularity

**Rationale**: Each plan version should track which reports it integrated. This enables:
- Clear audit trail of research evolution
- Ability to see what changed between plan versions
- Rollback capability (revert to previous plan with its research context)

**Schema Design**:
```json
"reports_integrated": [
  {
    "path": "reports/research-001.md",
    "integrated_in_plan_version": 1,
    "integrated_date": "2026-01-05"
  },
  {
    "path": "reports/research-002.md",
    "integrated_in_plan_version": 2,
    "integrated_date": "2026-01-06"
  }
]
```

### Decision 3: Add Integration Summary to Plan Overview

**Rationale**: Plan readers need to quickly understand what research informed the plan and what's new in revisions. Integration summary provides this context.

**Location**: Add "Research Integration" subsection to plan Overview section (after problem/scope/constraints).

### Decision 4: Backward Compatibility

**Rationale**: Existing plans without reports_integrated field should continue to work. Planner should gracefully handle missing field.

**Implementation**: Use default empty array if reports_integrated missing:
```bash
reports_integrated=$(echo "$plan_metadata" | jq -r '.reports_integrated // []')
```

## Risks & Mitigations

### Risk 1: Filesystem Timestamp Reliability

**Risk**: Report files manually edited after creation will have updated mtimes, causing false positives (old reports detected as new).

**Likelihood**: Low (reports typically not edited after creation per artifact-management.md)

**Impact**: Medium (redundant research integration, but not incorrect)

**Mitigation**: 
- Document in artifact-management.md: "Do not edit research reports after creation. Create new report versions instead."
- Add validation in planner: Warn if report mtime is very recent (within last hour) during revision

### Risk 2: Clock Skew Between Plan and Report Creation

**Risk**: If system clock changes between plan creation and report creation, timestamp comparison may be incorrect.

**Likelihood**: Very Low (modern systems use NTP)

**Impact**: Medium (missed new reports or false positives)

**Mitigation**:
- Use UTC timestamps consistently
- Add sanity check: If report mtime is in the future relative to current time, log warning

### Risk 3: State.json and Plan File Inconsistency

**Risk**: state.json plan_path points to non-existent plan file, or plan file exists but not referenced in state.json.

**Likelihood**: Low (status-sync-manager ensures atomic updates)

**Impact**: High (planner cannot determine last plan version)

**Mitigation**:
- Add validation in planner step_1: Verify plan_path file exists if plan_path set in state.json
- If inconsistent: Log error and abort with recovery instructions

### Risk 4: Reports Directory Missing or Empty

**Risk**: Reports directory doesn't exist or contains no research reports.

**Likelihood**: Medium (valid scenario for tasks without research)

**Impact**: Low (planner should proceed without research)

**Mitigation**:
- Add defensive checks in planner step_2: Check if reports/ directory exists before scanning
- If missing or empty: Log info message and proceed without research integration

## Recommendations

### Recommendation 1: Implement in 4 Phases

Follow the phased approach outlined in "Recommended Implementation Approach" section:
1. Phase 1: Extend plan metadata schema (1 hour)
2. Phase 2: Implement report detection (1.5 hours)
3. Phase 3: Enhance research harvesting (1 hour)
4. Phase 4: Update postflight integration (0.5 hours)

**Total Effort**: 4 hours (matches task estimate)

### Recommendation 2: Add Integration Testing

Create test scenarios:
1. **First plan with research**: Verify all reports integrated, reports_integrated populated
2. **Plan revision with new reports**: Verify only new reports integrated, integration summary correct
3. **Plan revision with no new reports**: Verify no redundant integration, summary indicates no new research
4. **Plan revision with missing reports directory**: Verify graceful handling, no errors

### Recommendation 3: Update Documentation

Update the following documentation files:
1. **plan.md**: Add reports_integrated field to metadata schema
2. **artifact-management.md**: Document report editing policy (no edits after creation)
3. **state-management.md**: Document reports_integrated schema in plan_metadata
4. **planner.md**: Update step_2 process flow with report detection logic

### Recommendation 4: Consider Future Enhancements

**Not in scope for task 300, but worth noting**:
1. **Report versioning**: Track report revisions (research-001-v2.md) separately from new reports
2. **Report dependencies**: Track which reports depend on or supersede other reports
3. **Research quality metrics**: Track research completeness, confidence levels
4. **Automated research summarization**: Generate integration summaries automatically from report metadata

## Appendix: Sources and Citations

### Primary Sources

1. **.opencode/agent/subagents/planner.md** (615 lines)
   - Current planner implementation
   - Step 2 research harvesting logic (lines 150-167)
   - Step 7 postflight status updates (lines 240-349)

2. **.opencode/agent/subagents/status-sync-manager.md** (300+ lines)
   - Artifact linking logic (lines 98-120, 359-461)
   - Plan metadata handling (lines 107-109)

3. **.opencode/context/core/system/artifact-management.md** (271 lines)
   - Artifact directory structure (lines 8-34)
   - Plan versioning rules (lines 58-76)
   - Context window protection patterns (lines 166-258)

4. **.opencode/context/core/system/state-management.md** (613 lines)
   - State.json schema (lines 162-196)
   - Plan metadata schema (lines 301-307)
   - Status synchronization patterns (lines 441-492)

5. **.opencode/context/core/standards/plan.md** (105 lines)
   - Plan metadata format (lines 6-29)
   - Plan structure requirements (lines 31-48)

6. **specs/TODO.md** (task 300, lines 136-163)
   - Task requirements and acceptance criteria

7. **specs/state.json** (task 300 metadata, lines 612-623)
   - Task metadata and current status

### Secondary Sources

1. **Task 299** (Create Task Reviser Subagent) - Related task for /revise command enhancement
2. **Task 301** (Enhance Revise Command with Dual-Mode Routing) - Depends on task 300
3. **Task 302** (Test Dual-Mode Revision Workflow) - Testing task for task 300+301

### Research Methodology

1. **Code Analysis**: Read and analyzed 5 key implementation files (planner.md, status-sync-manager.md, etc.)
2. **Standards Review**: Reviewed 3 standards documents (plan.md, artifact-management.md, state-management.md)
3. **Requirement Analysis**: Extracted requirements from TODO.md task 300 description and acceptance criteria
4. **Architecture Analysis**: Traced data flow through planner workflow (steps 0-8)
5. **Integration Analysis**: Identified integration points with status-sync-manager and state.json

### Key Insights

1. **Temporal Awareness Gap**: Current planner lacks ability to distinguish old vs new research reports
2. **Metadata Extension Needed**: plan_metadata schema needs reports_integrated field for tracking
3. **Filesystem Timestamps Sufficient**: No need for complex metadata tracking, filesystem mtimes work
4. **Backward Compatible**: Schema extension can be backward compatible with existing plans
5. **4-Phase Implementation**: Clear phased approach with 4 hours total effort (matches estimate)
