# Research Report: Update /review Command to Create Summary Artifacts

- **Task**: 206 - Update /review command to create summaries in new project directories
- **Status**: [COMPLETED]
- **Started**: 2025-12-28
- **Completed**: 2025-12-28
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - .opencode/command/review.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/subagent-return-format.md
  - .opencode/context/core/standards/summary.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/command/research.md (reference implementation)
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
  - .opencode/specs/170_maintenance_report_improvements/reports/research-001.md
- **Artifacts**:
  - reports/research-001.md (this file)
  - summaries/research-summary.md
- **Standards**: status-markers.md, artifact-management.md, summary.md, subagent-return-format.md

---

## Executive Summary

The /review command currently updates project registries (IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md, FEATURE_REGISTRY.md) and creates tasks but does not create persistent review summary artifacts. The command invokes a reviewer subagent (which does not exist as a documented agent), returns verbose findings directly to the orchestrator, and lacks artifact management. To implement summary artifact creation, the system needs: (1) a documented reviewer subagent specification, (2) project directory creation following lazy creation principles, (3) review summary artifact generation in summaries/ subdirectory, (4) return format standardization per subagent-return-format.md, and (5) TODO.md/state.json updates with artifact references. Implementation is estimated at 4-5 hours with moderate complexity due to missing reviewer agent specification.

---

## Context & Scope

This research investigates how to update the /review command to create summary artifacts in new project directories following the artifact-management.md structure. The scope includes:

1. Analysis of current /review command implementation and workflow
2. Investigation of reviewer agent (currently undocumented)
3. Review of artifact management standards and lazy directory creation
4. Examination of summary format standards and requirements
5. Analysis of return format standards for context window protection
6. Review of similar command implementations (/research as reference)
7. State management requirements (TODO.md, state.json updates)
8. Implementation approach recommendations and effort estimation

**Constraints**:
- Must follow lazy directory creation (create project root only when writing first artifact)
- Must create only summaries/ subdirectory (not reports/ or plans/)
- Must follow summary.md standard (3-5 sentences, <100 tokens)
- Must return only brief summary and artifact path (not full content)
- Must update TODO.md and state.json with artifact references
- No emojis in output or artifacts

---

## Findings

### 1. Current /review Command Implementation

#### 1.1 Command Structure

The /review command is defined in `.opencode/command/review.md` with the following characteristics:

**Current Workflow** (8 stages):
1. **Preflight**: Parse review scope, load current registries
2. **PrepareDelegation**: Generate session_id, set delegation context
3. **InvokeReviewer**: Route to reviewer subagent
4. **ReceiveResults**: Wait for and validate reviewer return
5. **ProcessResults**: Extract registry updates and identified tasks
6. **CreateTasks**: Create TODO.md tasks for identified work
7. **Postflight**: Update registries and commit
8. **ReturnSuccess**: Return summary to user

**Current Artifacts Created**:
- Updates to existing registries (IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md, FEATURE_REGISTRY.md)
- New tasks in TODO.md
- Git commit with registry updates

**Current Return Format** (Stage 8):
```
Review completed
- Registries updated: {list}
- Tasks created: {count}
- Summary: {brief summary of findings}
- Key findings:
  - Sorry count: {count}
  - Undocumented tactics: {count}
  - Missing features: {count}
  - Implementation gaps: {count}
```

**Observations**:
- No project directory creation
- No review summary artifact generation
- Verbose return format (key findings listed directly)
- No artifact path returned to user
- Registry updates are in-place modifications, not new artifacts

#### 1.2 Reviewer Subagent Status

**Critical Finding**: The reviewer subagent referenced in review.md does not exist as a documented agent.

**Evidence**:
- File `.opencode/agent/subagents/reviewer.md` does not exist
- Search for reviewer-related files found no agent specification
- The /review command references "reviewer subagent" but provides no implementation details

**Implications**:
- Reviewer agent behavior is undefined
- Return format from reviewer is unknown
- Cannot determine current artifact creation behavior
- Implementation will require creating or documenting reviewer agent specification

**Likely Current Behavior** (inferred from command workflow):
- Reviewer analyzes codebase (Lean files, documentation)
- Counts sorry statements, axioms, undocumented tactics
- Identifies missing features and implementation gaps
- Returns findings directly to /review command
- Command processes findings and updates registries

### 2. Artifact Management Standards

#### 2.1 Lazy Directory Creation

From `artifact-management.md` (lines 155-164):

**Key Principles**:
1. Create project root (NNN_project_name) **only when writing first artifact**
2. Create subdirectories (reports/, plans/, summaries/) **only when writing artifact into them**
3. Never pre-create unused subdirs
4. Never add placeholder files (e.g., .gitkeep)

**Command-Specific Rules** (lines 73-81):
- `/task`: MUST NOT create project directories
- `/plan`: May create project root + plans/ when writing plan
- `/research`: Create project root + reports/ when writing research
- `/review`: Create project root only when writing first report/summary, only create subdir needed for artifact being written
- `/implement`: Create project root + summaries/ when writing implementation summary

**For /review Command**:
- Create project root (206_review_YYYYMMDD or similar) lazily when writing summary
- Create only summaries/ subdirectory (not reports/ or plans/)
- Write review summary to summaries/review-summary.md

#### 2.2 Project Numbering

From `artifact-management.md` (lines 36-46):

**Format**: NNN_project_name where NNN is zero-padded 3-digit number

**Numbering Rules**:
1. Start at 000
2. Increment sequentially up to 999
3. Wrap around to 000 after 999 (ensure old project is archived)
4. Zero-pad to 3 digits

**Current State** (from state.json):
- `next_project_number`: 207
- Project numbers wrap around to 000 after 999

**For /review Command**:
- Use next_project_number from state.json
- Increment after creating project
- Project name format: `{number}_review_{YYYYMMDD}` or `{number}_codebase_review`

#### 2.3 Subdirectory Structure

From `artifact-management.md` (lines 49-82):

**Subdirectories**:
- `reports/`: Research and analysis reports (research-NNN.md, analysis-NNN.md, verification-NNN.md, refactoring-NNN.md)
- `plans/`: Implementation plans with version control (implementation-NNN.md)
- `summaries/`: Brief summaries for quick reference (research-summary.md, plan-summary.md, implementation-summary-YYYYMMDD.md, project-summary.md)

**For /review Command**:
- Create only `summaries/` subdirectory
- Write `summaries/review-summary.md`
- Do not create `reports/` or `plans/`

### 3. Summary Format Standards

#### 3.1 Summary Requirements

From `artifact-management.md` (lines 84-107):

**All Summaries Must**:
- Format: 3-5 sentences for individual summaries, 2-3 sentences for batch summaries
- Token Limit: <100 tokens for individual summaries, <75 tokens for batch summaries
- Creation: Lazy directory creation - create summaries/ only when writing first summary
- Validation: Summary artifact must exist before task completion when detailed artifact created

**Summary Types**:
- `research-summary.md`: Key research findings (3-5 sentences, <100 tokens)
- `plan-summary.md`: Implementation plan overview (3-5 sentences, <100 tokens)
- `implementation-summary-YYYYMMDD.md`: What was implemented (3-5 sentences, <100 tokens)
- `batch-summary-YYYYMMDD.md`: Batch execution summary (2-3 sentences, <75 tokens)
- `project-summary.md`: Overall project summary (3-5 sentences, <100 tokens)

**For /review Command**:
- Create `review-summary.md` (not review-summary-YYYYMMDD.md)
- 3-5 sentences, <100 tokens
- Focus on key findings (sorry count, tactic documentation, feature gaps, implementation status)

#### 3.2 Summary Structure

From `summary.md` (lines 14-60):

**Required Metadata**:
- Task: {id} - {title}
- Status: [NOT STARTED] | [IN PROGRESS] | [BLOCKED] | [ABANDONED] | [COMPLETED]
- Started: {ISO8601}
- Completed: {ISO8601}
- Effort: {estimate}
- Priority: High | Medium | Low
- Dependencies: {list or None}
- Artifacts: list of linked artifacts summarized
- Standards: status-markers.md, artifact-management.md, tasks.md, summary.md

**Required Sections**:
1. Overview (2-3 sentences on scope and context)
2. What Changed (bullets of key changes/deltas)
3. Decisions (bullets of decisions made)
4. Impacts (bullets on downstream effects)
5. Follow-ups (bullets with owners/due dates if applicable)
6. References (paths to artifacts informing the summary)

**Writing Guidance**:
- Keep concise (<= 1 page)
- Use bullet lists for clarity
- Reflect status of underlying work accurately
- Lazy directory creation: create summaries/ only when writing this file
- No emojis

**For /review Command**:
- Adapt structure for review findings
- Overview: Scope of review (full codebase, Lean only, docs only)
- What Changed: Registry updates, tasks created
- Decisions: N/A for review (no implementation decisions)
- Impacts: Identified technical debt, blockers, priorities
- Follow-ups: Created tasks with priorities
- References: Updated registry paths

### 4. Return Format Standards

#### 4.1 Subagent Return Format

From `subagent-return-format.md` (lines 26-54):

**Standard Return Format**:
```json
{
  "status": "completed|failed|partial|blocked",
  "summary": "Brief 2-5 sentence summary (max 100 tokens)",
  "artifacts": [
    {
      "type": "research|plan|implementation|summary|documentation",
      "path": "relative/path/from/project/root",
      "summary": "Optional one-sentence description"
    }
  ],
  "metadata": {
    "session_id": "unique_session_identifier",
    "duration_seconds": 123,
    "agent_type": "agent_name",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "command", "agent"]
  },
  "errors": [],
  "next_steps": "Optional recommended next actions"
}
```

**Field Specifications**:
- `status` (required): completed | failed | partial | blocked
- `summary` (required): 2-5 sentences, max 100 tokens (approximately 400 characters)
- `artifacts` (required, can be empty array): Array of artifact objects with type, path, summary
- `metadata` (required): session_id, duration_seconds, agent_type, delegation_depth, delegation_path
- `errors` (optional, empty array if no errors): Array of error objects
- `next_steps` (optional): 1-2 sentences

**For /review Command**:
- Reviewer subagent must return this format
- Status: "completed" (or "partial" if timeout)
- Summary: Brief review findings (2-5 sentences, <100 tokens)
- Artifacts: Array with review summary artifact
- Metadata: session_id, duration, agent_type="reviewer", delegation info
- Errors: Empty array if successful
- Next_steps: "Review findings and address high-priority tasks"

#### 4.2 Context Window Protection

From `artifact-management.md` (lines 167-173):

**Context Protection Principle**:
All agents create artifacts in project directories and return only:
- File path (reference)
- Brief summary (3-5 sentences)
- Key findings (bullet points)

This protects the orchestrator's context window from artifact content bloat.

**For /review Command**:
- Reviewer returns only artifact path and brief summary
- Full review findings in summaries/review-summary.md
- Command returns to user: brief summary + artifact path
- No verbose key findings in return (they're in the artifact)

### 5. Similar Command Implementations

#### 5.1 /research Command as Reference

From `research.md` (lines 1-422):

**Workflow Stages**:
1. **Preflight**: Parse task number, validate, mark [RESEARCHING]
2. **CheckLanguage**: Determine routing (lean vs general)
3. **PrepareDelegation**: Generate session_id, set delegation context
4. **InvokeResearcher**: Route to researcher or lean-research-agent
5. **ReceiveResults**: Wait for and validate return
6. **ProcessResults**: Extract artifacts and summary
7. **Postflight**: Update status to [RESEARCHED], link artifacts, commit
8. **ReturnSuccess**: Return summary to user

**Artifact Management** (lines 334-348):
- Lazy creation: Do not create specs/NNN_*/ until writing research artifacts
- Create only reports/ subdirectory when writing research-001.md
- Create summaries/ only if summary file needed
- Artifact naming: specs/NNN_{task_slug}/reports/research-001.md, specs/NNN_{task_slug}/summaries/research-summary.md
- State sync: Update state.json with artifact paths when research completes

**Return Format** (lines 300-313):
```
Research completed for task {number}
- Status: [RESEARCHED]
- Artifacts: {list of research report paths}
- Summary: {brief summary from research agent}

Or if partial:
Research partially completed for task {number}
- Status: [IN PROGRESS]
- Partial artifacts: {list}
- Resume with: /research {number}
```

**Key Differences from /review**:
- /research is task-specific (takes task number), /review is repository-wide
- /research creates reports/, /review should create summaries/
- /research marks task [RESEARCHED], /review doesn't change task status (creates new tasks)
- /research has documented researcher subagent, /review lacks documented reviewer subagent

#### 5.2 Patterns to Follow

**From /research Command**:
1. Lazy directory creation (create project root only when writing artifact)
2. Subdirectory creation (create only needed subdir)
3. Subagent delegation with session tracking
4. Return validation against subagent-return-format.md
5. Artifact linking in TODO.md (for /review: link in created tasks or separate entry)
6. State.json updates with artifact paths
7. Git commit with artifacts + state updates
8. Brief return to user (artifact path + summary, not full content)

**Adaptations for /review**:
1. No task number (repository-wide operation)
2. Create summaries/ only (not reports/)
3. Reviewer subagent needs documentation
4. Link review summary in TODO.md or state.json
5. Return format: brief summary + artifact path

### 6. State Management

#### 6.1 TODO.md Updates

**Current Behavior** (from review.md stage 6):
- /review creates tasks for identified work
- Tasks added to TODO.md with priorities
- Example: "Fix 12 sorry statements in Logos/Core/Theorems/"

**Proposed Behavior**:
- Create tasks as before
- Add review summary artifact reference to TODO.md
- Options:
  - Option A: Add review summary link to each created task
  - Option B: Create a dedicated "Review" section in TODO.md with artifact links
  - Option C: Link review summary in state.json only (not TODO.md)

**Recommendation**: Option C (link in state.json only)
- Rationale: Review is a repository-wide operation, not a task
- TODO.md is for tasks, not repository operations
- state.json has repository_health section for review tracking
- Keeps TODO.md focused on actionable tasks

#### 6.2 state.json Updates

From `state.json` (lines 100-119):

**Current Structure**:
```json
{
  "repository_health": {
    "last_assessed": "2025-12-28T18:00:00Z",
    "overall_score": 91,
    "active_tasks": 25,
    "completed_tasks": 28,
    "blocked_tasks": 2,
    "technical_debt": {
      "sorry_count": 10,
      "axiom_count": 11,
      "build_errors": 3,
      "status": "well-documented"
    }
  }
}
```

**Proposed Updates**:
- Add `review_artifacts` array to `repository_health`
- Track review summary paths with timestamps
- Example:
```json
{
  "repository_health": {
    "last_assessed": "2025-12-28T18:00:00Z",
    "review_artifacts": [
      {
        "timestamp": "2025-12-28T18:00:00Z",
        "path": ".opencode/specs/207_codebase_review/summaries/review-summary.md",
        "scope": "full"
      }
    ]
  }
}
```

#### 6.3 Status Markers

From `status-markers.md`:

**Review Command Status**:
- /review does not change task status (it's not task-specific)
- /review creates new tasks with [NOT STARTED] status
- No command-specific status marker for /review (unlike [RESEARCHING], [PLANNING], [IMPLEMENTING])

**For Review Summary Artifact**:
- Review summary metadata should include Status: [COMPLETED]
- Started/Completed timestamps for review operation
- No task status update needed

### 7. Implementation Approach

#### 7.1 Required Changes

**1. Create Reviewer Subagent Specification** (new file: `.opencode/agent/subagents/reviewer.md`)
- Define reviewer agent role and responsibilities
- Specify codebase analysis process (sorry counting, tactic documentation, feature gaps)
- Define return format per subagent-return-format.md
- Specify artifact creation (summaries/review-summary.md)
- Include lazy directory creation logic
- Define timeout (3600s for comprehensive review)

**2. Update /review Command** (modify: `.opencode/command/review.md`)
- Add project directory creation logic (stage 2 or new stage)
- Update InvokeReviewer stage to pass project directory path
- Update ReceiveResults stage to extract review summary artifact
- Update Postflight stage to update state.json with review artifact
- Update ReturnSuccess stage to return artifact path + brief summary (not verbose findings)

**3. Update state.json Schema** (modify: `.opencode/specs/state.json`)
- Add `review_artifacts` array to `repository_health` section
- Document schema change in state-schema.md

**4. Create Review Summary Template** (optional: `.opencode/context/core/standards/review-summary-template.md`)
- Define standard structure for review summaries
- Provide example review summary
- Document required sections and format

#### 7.2 Detailed Implementation Steps

**Phase 1: Create Reviewer Subagent Specification** (1.5 hours)

1. Create `.opencode/agent/subagents/reviewer.md`
2. Define agent metadata (name, role, context_level)
3. Specify inputs (session_id, delegation_depth, delegation_path, review_scope)
4. Define process flow:
   - Analyze codebase (Lean files, docs, tests)
   - Count sorry statements, axioms, build errors
   - Identify undocumented tactics
   - Identify missing features
   - Identify implementation gaps
5. Specify artifact creation:
   - Create project directory (NNN_codebase_review) lazily
   - Create summaries/ subdirectory
   - Write summaries/review-summary.md
6. Define return format per subagent-return-format.md:
   - status: "completed"
   - summary: Brief findings (2-5 sentences, <100 tokens)
   - artifacts: [review summary artifact]
   - metadata: session_id, duration, agent_type="reviewer", delegation info
7. Add validation checks (pre-execution, post-execution)
8. Add error handling (timeout, validation failure)

**Phase 2: Update /review Command** (1.5 hours)

1. Modify `.opencode/command/review.md`
2. Add project directory creation logic:
   - Read next_project_number from state.json
   - Generate project name: `{number}_codebase_review`
   - Pass project path to reviewer subagent
   - Increment next_project_number after creation
3. Update PrepareDelegation stage:
   - Add project_path to delegation context
4. Update InvokeReviewer stage:
   - Pass project_path to reviewer
5. Update ReceiveResults stage:
   - Validate return against subagent-return-format.md
   - Extract review summary artifact path
6. Update ProcessResults stage:
   - Extract brief summary from return
   - Extract artifact path from return
7. Update Postflight stage:
   - Update state.json with review artifact reference
   - Git commit: artifacts + state.json + registries + TODO.md
8. Update ReturnSuccess stage:
   - Return brief summary + artifact path
   - Remove verbose key findings (they're in artifact)

**Phase 3: Update state.json Schema** (0.5 hours)

1. Modify `.opencode/specs/state.json`
2. Add `review_artifacts` array to `repository_health`:
   ```json
   "review_artifacts": [
     {
       "timestamp": "2025-12-28T18:00:00Z",
       "path": ".opencode/specs/207_codebase_review/summaries/review-summary.md",
       "scope": "full"
     }
   ]
   ```
3. Document schema change in state-schema.md

**Phase 4: Testing and Validation** (0.5 hours)

1. Test /review command with new artifact creation
2. Verify lazy directory creation (project root + summaries/ only)
3. Verify review summary artifact created correctly
4. Verify return format (brief summary + artifact path, no verbose output)
5. Verify state.json updated with review artifact
6. Verify git commit includes all changes
7. Verify no emojis in output or artifacts

**Phase 5: Documentation Updates** (1 hour)

1. Update artifact-management.md with /review example
2. Update status-markers.md if needed (no new status markers)
3. Create review-summary-template.md (optional)
4. Update NAVIGATION.md if needed

#### 7.3 Effort Estimation

**Total Estimated Effort**: 4-5 hours

**Breakdown**:
- Phase 1 (Reviewer subagent spec): 1.5 hours
- Phase 2 (/review command updates): 1.5 hours
- Phase 3 (state.json schema): 0.5 hours
- Phase 4 (Testing): 0.5 hours
- Phase 5 (Documentation): 1 hour

**Complexity**: Moderate
- Requires creating new subagent specification (reviewer.md doesn't exist)
- Requires understanding lazy directory creation
- Requires return format standardization
- Requires state.json schema updates
- Relatively straightforward once patterns understood

**Risks**:
1. **Reviewer subagent behavior undefined**: Current reviewer behavior is unknown, may require reverse-engineering from command workflow
2. **State.json schema changes**: Must maintain backward compatibility
3. **Git commit scope**: Must include all changes atomically (artifacts + state + registries + TODO)
4. **Return format validation**: Must ensure reviewer returns standard format

**Mitigation**:
1. Define reviewer behavior based on /review command workflow and existing patterns
2. Add review_artifacts as optional field (backward compatible)
3. Use git-workflow-manager for scoped commits
4. Add return format validation in ReceiveResults stage

### 8. Alternative Approaches

#### 8.1 Option A: Create reports/ Instead of summaries/

**Approach**: Create reports/review-001.md instead of summaries/review-summary.md

**Pros**:
- Aligns with /research pattern (creates reports/)
- Allows for detailed review reports
- Supports multiple review reports (review-001.md, review-002.md, etc.)

**Cons**:
- Violates task requirement (create only summaries/)
- Creates verbose artifacts (defeats context window protection)
- Inconsistent with /implement pattern (creates summaries/)

**Recommendation**: Reject - violates task requirement

#### 8.2 Option B: No Project Directory (Update Existing Files)

**Approach**: Update existing maintenance/maintenance-report-YYYYMMDD.md instead of creating new project directory

**Pros**:
- Reuses existing maintenance report infrastructure
- No new project numbering needed
- Aligns with current /review behavior (updates existing files)

**Cons**:
- Violates task requirement (create new project directory)
- Maintenance reports are for /todo command, not /review
- Doesn't follow artifact-management.md structure
- No lazy directory creation demonstration

**Recommendation**: Reject - violates task requirement

#### 8.3 Option C: Hybrid Approach (Summary + Report)

**Approach**: Create both summaries/review-summary.md and reports/review-001.md

**Pros**:
- Provides both brief summary and detailed report
- Maximum information preservation
- Supports future detailed analysis

**Cons**:
- Violates task requirement (create only summaries/)
- Creates unnecessary artifacts
- Increases storage and complexity

**Recommendation**: Reject - violates task requirement

### 9. Recommendations

#### 9.1 Recommended Implementation Approach

**Approach**: Follow task requirements exactly
1. Create project directory (NNN_codebase_review) lazily when writing first artifact
2. Create only summaries/ subdirectory
3. Write summaries/review-summary.md following summary.md standard
4. Return brief summary + artifact path (not full content)
5. Update state.json with review artifact reference
6. No TODO.md update (review is repository-wide, not task-specific)

**Rationale**:
- Aligns with task requirements
- Follows artifact-management.md standards
- Protects context window
- Maintains consistency with /implement pattern
- Simple and focused

#### 9.2 Reviewer Subagent Specification

**Recommended Behavior**:
1. Analyze codebase (Lean files, docs, tests)
2. Count sorry statements, axioms, build errors
3. Identify undocumented tactics
4. Identify missing features and implementation gaps
5. Create project directory lazily
6. Write summaries/review-summary.md
7. Return standardized format per subagent-return-format.md

**Return Format**:
```json
{
  "status": "completed",
  "summary": "Codebase review completed. Found 10 sorry statements, 11 axioms, 3 build errors. Identified 8 undocumented tactics and 3 missing features. Created 5 high-priority tasks.",
  "artifacts": [
    {
      "type": "summary",
      "path": ".opencode/specs/207_codebase_review/summaries/review-summary.md",
      "summary": "Review findings and recommendations"
    }
  ],
  "metadata": {
    "session_id": "sess_20251228_abc123",
    "duration_seconds": 1800,
    "agent_type": "reviewer",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "review", "reviewer"]
  },
  "errors": [],
  "next_steps": "Review findings and address high-priority tasks"
}
```

#### 9.3 State Management

**state.json Updates**:
- Add `review_artifacts` array to `repository_health` section
- Track review summary paths with timestamps and scope
- Maintain backward compatibility (optional field)

**TODO.md Updates**:
- No direct update (review is repository-wide)
- Created tasks reference review findings in descriptions
- Review artifact path in state.json only

#### 9.4 Documentation Updates

**Required Documentation**:
1. Create `.opencode/agent/subagents/reviewer.md` (new)
2. Update `.opencode/command/review.md` (modify stages 2, 4, 5, 7, 8)
3. Update `.opencode/specs/state.json` (add review_artifacts)
4. Update `.opencode/context/core/system/state-schema.md` (document review_artifacts)

**Optional Documentation**:
1. Create `.opencode/context/core/standards/review-summary-template.md` (template)
2. Update `.opencode/context/core/system/artifact-management.md` (add /review example)

---

## Conclusions

### Key Findings

1. **Current State**: /review command lacks artifact management, has no documented reviewer subagent, returns verbose output
2. **Required Changes**: Create reviewer subagent spec, add project directory creation, implement summary artifact generation, standardize return format
3. **Effort Estimate**: 4-5 hours (moderate complexity)
4. **Main Risk**: Reviewer subagent behavior undefined, requires specification from scratch
5. **Recommended Approach**: Follow task requirements exactly - create summaries/ only, return brief summary + path

### Implementation Priority

**High Priority**:
1. Create reviewer subagent specification (blocks all other work)
2. Update /review command with artifact creation logic
3. Update state.json schema with review_artifacts

**Medium Priority**:
4. Testing and validation
5. Documentation updates

**Low Priority**:
6. Optional review summary template

### Success Criteria

Implementation is successful when:
1. /review command creates project directory (NNN_codebase_review) lazily
2. Only summaries/ subdirectory is created
3. Review summary artifact (summaries/review-summary.md) follows summary.md standard
4. Command returns brief summary + artifact path (not full content)
5. state.json updated with review artifact reference
6. No emojis in output or artifacts
7. All tests pass
8. Documentation updated

---

## References

- .opencode/command/review.md (current /review command implementation)
- .opencode/context/core/system/artifact-management.md (lazy directory creation, project numbering)
- .opencode/context/core/standards/subagent-return-format.md (return format standard)
- .opencode/context/core/standards/summary.md (summary format standard)
- .opencode/context/core/standards/status-markers.md (status markers)
- .opencode/command/research.md (reference implementation)
- .opencode/specs/TODO.md (task tracking)
- .opencode/specs/state.json (state management)
- .opencode/specs/170_maintenance_report_improvements/reports/research-001.md (maintenance report analysis)
