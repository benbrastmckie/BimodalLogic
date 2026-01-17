# Research Report: Task #517

**Task**: 517 - Fix /research command to avoid creating unnecessary summary files and properly link research reports
**Started**: 2026-01-16T20:00:00Z
**Completed**: 2026-01-16T20:00:00Z
**Effort**: 2-3 hours
**Priority**: High
**Dependencies**: None
**Sources/Inputs**: Codebase analysis, subagent configurations, existing task artifacts
**Artifacts**: - path to this report
**Standards**: report-format.md, subagent-return-format.md, state-management.md

## Executive Summary
- **Key finding 1**: Contradictory specifications in research subagents regarding summary file creation
- **Key finding 2**: researcher.md forbids summary artifacts while lean-research-agent.md requires them
- **Key finding 3**: Inconsistent implementation creates cleanup burden and workflow tracking issues
- **Recommended approach**: Standardize on single research report artifact, eliminate summary files

## Context & Scope

This research investigates the /research command issues identified in task 517:
1. **Unnecessary implementation-summary files** being created in summaries/ directory
2. **Improper linking of research reports** in TODO.md and state.json
3. **Incorrect task status updates** failing to reach RESEARCHED status

The research focused on:
- Current /research command implementation and workflow
- Subagent configurations (researcher.md vs lean-research-agent.md)
- Existing artifact patterns and cleanup burden
- State management and linking mechanisms

## Findings

### Codebase Patterns

**Current /research Command Structure**:
- Location: `.opencode/command/research.md`
- Language-based routing: lean → lean-research-agent, general → researcher
- Preflight/postflight status updates via status-sync-manager
- Delegation to subagents for research execution

**Subagent Configuration Contradiction**:
```yaml
# researcher.md (general tasks)
<must_not>Create summary artifact (report is single file, self-contained)</must_not>

# lean-research-agent.md (Lean tasks)  
Summary artifact file is REQUIRED because:
- Protects orchestrator context window from reading full report
- Provides quick overview of key findings
- Path: summaries/research-summary.md
```

**Evidence from Existing Tasks**:
- Task 504: Has both research-001.md (4,128 bytes) AND research-summary.md (224 bytes)
- Task 511: Has research-summary.md but incomplete state.json linking
- Task 500: Missing research-summary.md despite state.json claiming it exists
- Inconsistent patterns across completed research tasks

### External Resources

**Artifact Management Best Practices**:
- Modern workflow systems favor single, comprehensive artifacts over redundant summaries
- Cleanup strategies emphasize minimizing unnecessary file proliferation
- FAIR principles favor findable, accessible primary artifacts over duplicates

**Research Workflow Standards**:
- Single comprehensive report reduces cognitive load
- Direct linking to primary artifacts improves traceability
- Eliminating redundant files reduces maintenance burden

### Root Cause Analysis

**Problem 1: Contradictory Subagent Specifications**
- researcher.md: `<must_not>Create summary artifact`
- lean-research-agent.md: `Summary artifact file is REQUIRED`
- Both subagents create different artifact patterns for same command

**Problem 2: Linking Inconsistencies**
- state.json entries sometimes reference non-existent summary files
- TODO.md links inconsistent between tasks
- status-sync-manager expects validated_artifacts array but gets mixed patterns

**Problem 3: Status Update Failures**
- Preflight updates to RESEARCHING work correctly
- Postflight validation fails when expected summary artifacts missing
- Task status stuck in RESEARCHING instead of RESEARCHED

## Recommendations

### 1. Standardize on Single Research Report Artifact

**Action**: Eliminate summary artifacts entirely
- **researcher.md**: Already correct (no summary files)
- **lean-research-agent.md**: Remove summary requirement, align with researcher.md
- **Both**: Create only reports/research-001.md as comprehensive artifact

**Rationale**:
- Comprehensive reports (4,000+ bytes) contain all necessary information
- Eliminates file proliferation and cleanup burden
- Simplifies linking and validation logic

### 2. Fix Subagent Configuration Inconsistency

**Action**: Update lean-research-agent.md specification
```yaml
# Remove summary artifact requirement
# Update constraints:
<must>Create research artifacts ONLY (reports/research-001.md)</must>
<must_not>Create summary artifact (report is single file, self-contained)</must_not>
```

**Implementation**:
- Remove step_3_create_summary_artifact from lean-research-agent.md
- Update validation to expect single artifact (research-001.md only)
- Align return format with researcher.md

### 3. Update Status Sync Validation

**Action**: Fix status-sync-manager expectations
- Expect single research report artifact (not report + summary)
- Validate research-001.md exists and is non-empty
- Update linking to reference reports/research-001.md only

### 4. Cleanup Existing Inconsistent Artifacts

**Action**: One-time cleanup of contradictory artifacts
- Remove orphaned research-summary.md files
- Update state.json to remove broken summary links
- Ensure TODO.md links point to existing research reports

## Decisions

1. **Primary Recommendation**: Standardize on single comprehensive research report
2. **Secondary Recommendation**: Align both subagents to identical artifact patterns
3. **Cleanup Strategy**: Remove summary artifacts, fix broken links
4. **Validation Fix**: Update postflight to expect single artifact pattern

## Risks & Mitigations

### Risk 1: Context Window Bloat
- **Concern**: Large research reports in orchestrator context
- **Mitigation**: Return summary in metadata field (<100 tokens), not separate file
- **Status**: Already implemented correctly in both subagents

### Risk 2: Breaking Existing Workflows  
- **Concern**: Tasks expecting summary artifacts may fail
- **Mitigation**: One-time cleanup + clear migration path
- **Status**: Low risk, current implementation already inconsistent

### Risk 3: Link Validation Failures
- **Concern**: status-sync-manager may reject single artifact pattern
- **Mitigation**: Update validation logic alongside subagent fixes
- **Status**: Coordinated changes required

## Appendix

### Search Queries Used
- "research workflow artifact management summary files unnecessary"
- "research report workflow single artifact vs summary artifact best practices"
- Codebase analysis of /research command implementation
- Subagent configuration comparison

### References to Documentation
- `.opencode/command/research.md` - Current command implementation
- `.opencode/agent/subagents/researcher.md` - General research subagent  
- `.opencode/agent/subagents/lean-research-agent.md` - Lean research subagent
- `.opencode/agent/subagents/status-sync-manager.md` - Status synchronization
- Task 504 artifacts - Example of dual artifact pattern
- Task 511 artifacts - Example of broken linking

### Implementation Checklist
- [ ] Update lean-research-agent.md to remove summary requirement
- [ ] Align both subagents to single artifact pattern
- [ ] Update status-sync-manager validation logic
- [ ] Clean up existing orphaned summary artifacts
- [ ] Test /research command with both agent types
- [ ] Verify status updates work correctly (RESEARCHING → RESEARCHED)
- [ ] Confirm TODO.md and state.json link consistency