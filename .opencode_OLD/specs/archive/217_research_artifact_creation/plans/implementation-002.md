# Implementation Plan: Systematic Context Window Protection via Metadata Passing

**Task**: 217  
**Status**: [NOT STARTED]  
**Estimated Effort**: 12 hours  
**Language**: markdown  
**Priority**: Medium  
**Created**: 2025-12-28  
**Version**: 002  
**Supersedes**: implementation-001.md

---

## Overview

### Problem Statement

The OpenCode agent system requires systematic documentation and implementation of the context window protection pattern across all commands and subagents. Research (task 217, research-001.md) identified 95% compliance with artifact-management.md standards, but the fundamental pattern needs clearer documentation:

**Core Pattern**: Subagents return artifact links + brief summaries (metadata) to calling agents, NOT full artifact content. This protects the orchestrator's context window from bloat while maintaining traceability.

**Key Issue**: /research command currently creates 2 artifacts (report + summary), but the summary artifact is redundant. The subagent should return only the research report artifact link + brief summary as metadata in the return object (per subagent-return-format.md).

**Broader Issue**: This metadata passing pattern must be documented systematically across all context files, commands, and subagents to ensure consistency and avoid documentation bloat/redundancy.

### Scope

**In Scope**:
- Update /research command and researcher.md to create 1 artifact (report only), return brief summary as metadata
- Document context window protection pattern systematically in artifact-management.md
- Update command-lifecycle.md to clarify metadata passing in Stages 5-6
- Update all command files (/research, /plan, /revise, /implement) to reference the pattern
- Update all subagent files to reference the pattern and validate compliance
- Ensure no redundancy or inconsistency across documentation

**Out of Scope**:
- Functional code changes to artifact creation logic (documentation only)
- Changes to subagent-return-format.md (already correct)
- Changes to /plan or /revise artifact creation (already compliant: 1 artifact, no summary)
- Changes to /implement artifact creation (already compliant: N+1 artifacts with summary)

### Constraints

- Must maintain backward compatibility with existing workflows
- Must preserve all existing functionality
- Focus on documentation updates (agent files, context files, command files)
- No functional code changes to artifact creation logic
- Must align with existing subagent-return-format.md standard
- Must avoid documentation bloat, redundancy, and inconsistency

### Definition of Done

- [ ] /research creates 1 artifact (report only), returns brief summary as metadata
- [ ] researcher.md updated to match /research pattern
- [ ] artifact-management.md documents context window protection pattern clearly
- [ ] command-lifecycle.md Stages 5-6 clarify metadata passing pattern
- [ ] All 4 command files reference the pattern with command-specific variations
- [ ] All 6 subagent files reference the pattern and validate compliance
- [ ] No documentation redundancy or inconsistency introduced
- [ ] All changes reviewed for accuracy and completeness

---

## Goals and Non-Goals

### Goals

1. Systematically document context window protection pattern across all commands and subagents
2. Eliminate redundant summary artifact creation in /research (2 artifacts → 1 artifact)
3. Clarify metadata passing pattern in command-lifecycle.md and artifact-management.md
4. Ensure all commands and subagents reference the pattern consistently
5. Avoid documentation bloat by revising existing files, not creating new ones

### Non-Goals

1. Change artifact creation logic or timing (documentation only)
2. Modify subagent-return-format.md (already correct)
3. Change /plan or /implement artifact patterns (already compliant)
4. Create new context files or standards documents
5. Add validation tooling or scripts

---

## Risks and Mitigations

### Risk 1: Breaking Existing Workflows
**Likelihood**: Low  
**Impact**: High  
**Mitigation**: Changes are documentation-only; no functional changes to artifact creation logic. /research change (2→1 artifacts) is backward compatible (summary was redundant).

### Risk 2: Documentation Inconsistency
**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation**: Update all files in single task to ensure consistency. Cross-reference all updates against subagent-return-format.md as single source of truth.

### Risk 3: Missing Command/Subagent Files
**Likelihood**: Low  
**Impact**: Low  
**Mitigation**: Research identified all 4 commands and 6 subagents. Verify list before implementation.

---

## Implementation Phases

### Phase 1: Update Core Context Files [COMPLETED]
**Estimated Effort**: 3 hours  
**Dependencies**: None
**Started**: 2025-12-28
**Completed**: 2025-12-28

**Tasks**:
1. Update artifact-management.md to document context window protection pattern:
   - Add section: "Context Window Protection via Metadata Passing"
   - Explain: Subagents return artifact links + brief summaries, not full content
   - Document: /research creates 1 artifact (report only), summary returned as metadata
   - Document: /plan creates 1 artifact (plan only, self-documenting)
   - Document: /implement creates N+1 artifacts (files + summary)
   - Clarify: Summary artifacts are for multi-file outputs, not single reports
   - Reference: subagent-return-format.md for return pattern

2. Update command-lifecycle.md Stages 5-6:
   - Stage 5 (ReceiveResults): Clarify that summary field in return object is metadata, not artifact
   - Stage 6 (ProcessResults): Document that summary is extracted from return object, not read from file
   - Add note: Summary artifacts only required for multi-file outputs (e.g., /implement)
   - Reference: artifact-management.md for context window protection pattern

3. Verify no redundancy introduced across context files

**Acceptance Criteria**:
- artifact-management.md includes context window protection section
- command-lifecycle.md Stages 5-6 clarify metadata passing
- No redundancy between artifact-management.md and command-lifecycle.md
- All references to subagent-return-format.md are correct

**Validation**:
- Read updated artifact-management.md and verify pattern documented
- Read updated command-lifecycle.md and verify Stages 5-6 clarified
- Cross-check against subagent-return-format.md for consistency

---

### Phase 2: Update /research Command and researcher.md [COMPLETED]
**Estimated Effort**: 2 hours  
**Dependencies**: Phase 1
**Started**: 2025-12-28
**Completed**: 2025-12-28

**Tasks**:
1. Update /research command file:
   - Stage 7 (Postflight): Update artifact linking to expect 1 artifact (report only)
   - Remove references to research-summary.md artifact
   - Document: Summary is returned as metadata in subagent return, not as artifact
   - Reference: artifact-management.md context window protection pattern

2. Update researcher.md subagent file:
   - Step 5: Remove "Create research summary" step (summary artifact creation)
   - Step 6: Update return format to include brief summary in summary field (metadata)
   - Update constraints: Remove "Create summary artifact" requirement
   - Update output_specification: Show 1 artifact (report only) in return example
   - Add note: Summary field in return object protects orchestrator context window

3. Verify consistency between /research and researcher.md

**Acceptance Criteria**:
- /research expects 1 artifact (report only)
- researcher.md creates 1 artifact (report only)
- researcher.md returns brief summary as metadata in return object
- No references to research-summary.md artifact remain
- Consistency between command and subagent files

**Validation**:
- Read updated /research and verify artifact linking expects 1 artifact
- Read updated researcher.md and verify Step 5 removed, Step 6 updated
- Verify return format example shows 1 artifact with summary as metadata

---

### Phase 3: Update /plan and /revise Commands [COMPLETED]
**Estimated Effort**: 1.5 hours  
**Dependencies**: Phase 1
**Started**: 2025-12-28
**Completed**: 2025-12-28

**Tasks**:
1. Update /plan command file:
   - Add note: Plan is self-documenting (1 artifact, no summary artifact)
   - Reference: artifact-management.md context window protection pattern
   - Document: planner.md returns brief summary as metadata, not artifact

2. Update /revise command file:
   - Add note: Revised plan is self-documenting (1 artifact, no summary artifact)
   - Reference: artifact-management.md context window protection pattern
   - Document: planner.md returns brief summary as metadata, not artifact

3. Verify consistency with planner.md (already compliant)

**Acceptance Criteria**:
- /plan documents that plan is self-documenting
- /revise documents that revised plan is self-documenting
- Both commands reference artifact-management.md pattern
- Consistency with planner.md maintained

**Validation**:
- Read updated /plan and verify self-documenting note added
- Read updated /revise and verify self-documenting note added
- Verify planner.md already compliant (no changes needed)

---

### Phase 4: Update /implement Command [COMPLETED]
**Estimated Effort**: 1.5 hours  
**Dependencies**: Phase 1
**Started**: 2025-12-28
**Completed**: 2025-12-28

**Tasks**:
1. Update /implement command file:
   - Add note: Implementation creates N+1 artifacts (files + summary)
   - Document: Summary artifact required for multi-file outputs
   - Reference: artifact-management.md context window protection pattern
   - Clarify: Subagents return brief summary as metadata + summary artifact link

2. Verify consistency with implementation subagents (task-executor, lean-implementation-agent, implementer)

**Acceptance Criteria**:
- /implement documents N+1 artifact pattern
- /implement clarifies summary artifact requirement for multi-file outputs
- /implement references artifact-management.md pattern
- Consistency with implementation subagents maintained

**Validation**:
- Read updated /implement and verify N+1 pattern documented
- Verify consistency with task-executor.md, lean-implementation-agent.md, implementer.md

---

### Phase 5: Update All Subagent Files [COMPLETED]
**Estimated Effort**: 3 hours  
**Dependencies**: Phase 2, Phase 3, Phase 4
**Started**: 2025-12-28
**Completed**: 2025-12-28

**Tasks**:
1. Update planner.md:
   - Add note: Plan is self-documenting, no summary artifact created
   - Reference: artifact-management.md context window protection pattern
   - Verify Step 6 returns brief summary as metadata (already compliant)

2. Update lean-implementation-agent.md:
   - Add note: Creates N+1 artifacts (Lean files + summary)
   - Reference: artifact-management.md context window protection pattern
   - Verify Step 6 validates summary artifact and returns metadata (already compliant)

3. Update task-executor.md:
   - Add note: Creates N+1 artifacts (implementation files + summary)
   - Reference: artifact-management.md context window protection pattern
   - Verify Step 6 validates summary artifact and returns metadata (already compliant)

4. Update implementer.md:
   - Add note: Creates N+1 artifacts (implementation files + summary)
   - Reference: artifact-management.md context window protection pattern
   - Add validation block to Step 6 (from research gap 4.1)
   - Verify summary artifact validated before return

5. Update lean-research-agent.md:
   - Update to match researcher.md pattern (1 artifact: report only)
   - Remove summary artifact creation
   - Return brief summary as metadata in return object
   - Reference: artifact-management.md context window protection pattern

6. Verify all subagents reference the pattern consistently

**Acceptance Criteria**:
- All 6 subagent files reference artifact-management.md pattern
- researcher.md and lean-research-agent.md create 1 artifact (report only)
- planner.md creates 1 artifact (plan only, self-documenting)
- lean-implementation-agent.md, task-executor.md, implementer.md create N+1 artifacts
- implementer.md includes summary validation block (gap 4.1 fix)
- All subagents return brief summary as metadata in return object

**Validation**:
- Read all 6 subagent files and verify pattern references
- Verify artifact counts: researcher/lean-research-agent (1), planner (1), implementers (N+1)
- Verify implementer.md validation block added
- Verify all return format examples show summary as metadata

---

### Phase 6: Fix Remaining Compliance Gaps [COMPLETED]
**Estimated Effort**: 0.5 hours  
**Dependencies**: Phase 5
**Started**: 2025-12-28
**Completed**: 2025-12-28

**Tasks**:
1. Update researcher.md line 141 (from research gap 4.2):
   - Change: "Keep summary under 500 words"
   - To: "Keep summary under 100 tokens (~400 characters)"
   - Note: This is the summary field in return object, not a summary artifact

2. Verify no other "500 words" references exist in subagent files

**Acceptance Criteria**:
- researcher.md line 141 updated to "<100 tokens (~400 characters)"
- No other "500 words" references in any subagent file
- Consistency with artifact-management.md and subagent-return-format.md

**Validation**:
- Grep all subagent files for "500 words" (should return 0 results)
- Grep all subagent files for "100 tokens" (should return consistent results)
- Read updated researcher.md line 141 to verify exact text

---

### Phase 7: Validation and Testing [COMPLETED]
**Estimated Effort**: 0.5 hours  
**Dependencies**: Phase 1, Phase 2, Phase 3, Phase 4, Phase 5, Phase 6
**Started**: 2025-12-28
**Completed**: 2025-12-28

**Tasks**:
1. Verify all context files updated consistently:
   - artifact-management.md
   - command-lifecycle.md

2. Verify all command files updated consistently:
   - /research
   - /plan
   - /revise
   - /implement

3. Verify all subagent files updated consistently:
   - researcher.md
   - lean-research-agent.md
   - planner.md
   - lean-implementation-agent.md
   - task-executor.md
   - implementer.md

4. Cross-check all references to subagent-return-format.md

5. Verify no documentation redundancy or inconsistency

**Acceptance Criteria**:
- All 2 context files updated and consistent
- All 4 command files updated and consistent
- All 6 subagent files updated and consistent
- All references to subagent-return-format.md correct
- No redundancy or inconsistency across documentation

**Validation**:
- Read all updated files and verify consistency
- Cross-check against subagent-return-format.md
- Verify no redundant content across files

---

## Testing and Validation

### Pre-Implementation Validation
- [ ] Read research report (research-001.md) to understand compliance gaps
- [ ] Read research summary to understand key findings
- [ ] Verify subagent-return-format.md is authoritative for return pattern
- [ ] Verify artifact-management.md is authoritative for artifact requirements

### Post-Implementation Validation
- [ ] artifact-management.md documents context window protection pattern
- [ ] command-lifecycle.md Stages 5-6 clarify metadata passing
- [ ] /research creates 1 artifact (report only)
- [ ] researcher.md creates 1 artifact (report only)
- [ ] lean-research-agent.md creates 1 artifact (report only)
- [ ] planner.md creates 1 artifact (plan only, self-documenting)
- [ ] /implement creates N+1 artifacts (files + summary)
- [ ] All subagents return brief summary as metadata
- [ ] implementer.md includes summary validation block
- [ ] researcher.md line 141 updated to "<100 tokens"
- [ ] No "500 words" references in any subagent file
- [ ] All files reference artifact-management.md pattern consistently
- [ ] No documentation redundancy or inconsistency

### Regression Testing
- [ ] Verify no changes to artifact creation timing
- [ ] Verify no changes to directory structure
- [ ] Verify no changes to return format (subagent-return-format.md unchanged)
- [ ] Verify no functional changes to command-level specifications

---

## Artifacts and Outputs

### Modified Files

**Context Files** (2):
1. `.opencode/context/core/system/artifact-management.md`
   - Add context window protection section (~50 lines)
   
2. `.opencode/context/core/workflows/command-lifecycle.md`
   - Update Stages 5-6 to clarify metadata passing (~20 lines)

**Command Files** (4):
3. `.opencode/command/research.md`
   - Update Stage 7 artifact linking (1 artifact only) (~10 lines)
   
4. `.opencode/command/plan.md`
   - Add self-documenting note (~5 lines)
   
5. `.opencode/command/revise.md`
   - Add self-documenting note (~5 lines)
   
6. `.opencode/command/implement.md`
   - Add N+1 artifact pattern note (~10 lines)

**Subagent Files** (6):
7. `.opencode/agent/subagents/researcher.md`
   - Remove Step 5 (summary artifact creation) (~20 lines removed)
   - Update Step 6 return format (~10 lines changed)
   - Update line 141 summary limit (~1 line changed)
   
8. `.opencode/agent/subagents/lean-research-agent.md`
   - Remove summary artifact creation (~20 lines removed)
   - Update return format (~10 lines changed)
   
9. `.opencode/agent/subagents/planner.md`
   - Add self-documenting note (~5 lines)
   
10. `.opencode/agent/subagents/lean-implementation-agent.md`
    - Add N+1 artifact pattern note (~5 lines)
    
11. `.opencode/agent/subagents/task-executor.md`
    - Add N+1 artifact pattern note (~5 lines)
    
12. `.opencode/agent/subagents/implementer.md`
    - Add validation block to Step 6 (~15 lines)
    - Add N+1 artifact pattern note (~5 lines)

### Total Changes
- **Files Modified**: 12
- **Lines Added**: ~100
- **Lines Removed**: ~40
- **Net Change**: ~60 lines

### No New Files Created
- This is a documentation update only
- No new artifacts, scripts, or tools

---

## Rollback/Contingency

### Rollback Plan
If issues discovered after implementation:
1. Revert changes via git: `git checkout HEAD~1 -- .opencode/context/ .opencode/command/ .opencode/agent/`
2. Verify rollback successful
3. Investigate issue before re-attempting

### Contingency for Documentation Inconsistency
If inconsistencies found during validation:
1. Identify all inconsistent references
2. Cross-check against subagent-return-format.md (single source of truth)
3. Update all inconsistent files to match
4. Re-run validation

### Contingency for Breaking Changes
If documentation changes break existing workflows:
1. Identify breaking change
2. Assess if change is necessary for pattern clarity
3. If yes: Document migration path for affected workflows
4. If no: Revert breaking change and find alternative approach

---

## Dependencies

### Required Context Files
- `.opencode/context/core/standards/subagent-return-format.md` (authoritative return format)
- `.opencode/context/core/system/artifact-management.md` (authoritative artifact requirements)
- `.opencode/context/core/workflows/command-lifecycle.md` (command pattern)
- `.opencode/specs/217_research_artifact_creation/reports/research-001.md` (gap analysis)
- `.opencode/specs/217_research_artifact_creation/summaries/research-summary.md` (key findings)

### No External Dependencies
- No tool installations required
- No API access required
- No build steps required

---

## Notes

### Research Integration
This plan directly addresses the user's clarification on task 217:
- /research creates 1 artifact (report only), returns brief summary as metadata
- All commands use subagents that return artifact links + brief summaries (not full content)
- Metadata passing pattern documented systematically across all context files
- Documentation revised to avoid bloat, redundancy, and inconsistency

Research (research-001.md) identified 95% compliance with 2 high-priority gaps:
- Gap 4.1: Missing summary validation in implementer (addressed in Phase 5)
- Gap 4.2: Inconsistent summary token limits (addressed in Phase 6)

This plan expands scope to systematically document the context window protection pattern.

### Context Window Protection Pattern
From user clarification:
> "It is important that the /research command only return a research report artifact link and a brief summary to the primary agent. There is no need to create a summary artifact in addition to the research report artifact. It is important that all commands that create artifacts use subagents where those subagents return the link to the artifact created along with a brief summary to the primary agent to protect the context window of the primary agent. This metadata passing method should be implemented systematically throughout the opencode agent system and clearly documented in the context files, revising existing context files accordingly to avoid bloat, redundancy, and inconsistency."

**Core Pattern**:
- Subagents return artifact links + brief summaries (metadata)
- Subagents do NOT return full artifact content
- Summary field in return object is metadata, not an artifact
- Summary artifacts only for multi-file outputs (e.g., /implement)
- Single-file outputs (e.g., /research report, /plan) do not need summary artifacts

### Artifact Patterns by Command
- **/research**: 1 artifact (report only), summary as metadata
- **/plan**: 1 artifact (plan only, self-documenting), summary as metadata
- **/revise**: 1 artifact (revised plan, self-documenting), summary as metadata
- **/implement**: N+1 artifacts (implementation files + summary artifact), summary as metadata

### Why Summary Artifacts for /implement
/implement creates multiple implementation files (N files). The summary artifact provides a single-file overview of all changes, protecting the orchestrator's context window from reading N files. The summary field in the return object is still metadata (brief), but the summary artifact provides detailed documentation.

### Why No Summary Artifacts for /research and /plan
/research creates 1 file (research report). /plan creates 1 file (implementation plan). These are already single files that can be referenced by link. Creating a second summary artifact is redundant. The summary field in the return object provides the brief metadata needed for the orchestrator.

---

## Timeline

**Total Estimated Effort**: 12 hours

| Phase | Effort | Cumulative |
|-------|--------|------------|
| Phase 1: Update core context files | 3.0h | 3.0h |
| Phase 2: Update /research and researcher.md | 2.0h | 5.0h |
| Phase 3: Update /plan and /revise | 1.5h | 6.5h |
| Phase 4: Update /implement | 1.5h | 8.0h |
| Phase 5: Update all subagent files | 3.0h | 11.0h |
| Phase 6: Fix remaining compliance gaps | 0.5h | 11.5h |
| Phase 7: Validation and testing | 0.5h | 12.0h |

**Expected Completion**: 1-2 days (12 hours of focused work)

---

## Success Metrics

### Compliance Metrics
- Before: 95% compliance (40/42 checks passing), 2 artifacts for /research
- After: 100% compliance (42/42 checks passing), 1 artifact for /research

### Specific Improvements
- /research: 2 artifacts → 1 artifact (50% reduction)
- researcher.md: Summary artifact removed, summary as metadata
- lean-research-agent.md: Summary artifact removed, summary as metadata
- implementer.md: Validation coverage 0% → 100%
- researcher.md: Summary limit accuracy 50% → 100%

### Documentation Quality
- Context window protection pattern documented in artifact-management.md
- Metadata passing pattern clarified in command-lifecycle.md
- All 4 commands reference the pattern consistently
- All 6 subagents reference the pattern consistently
- Zero documentation redundancy or inconsistency

### Quality Metrics
- Zero functional regressions
- Zero breaking changes
- 100% pattern consistency across all commands and subagents

---

## Approval and Sign-off

**Plan Created**: 2025-12-28  
**Plan Version**: 002  
**Supersedes**: implementation-001.md  
**Research Integrated**: Yes (research-001.md)  
**User Clarification Integrated**: Yes (task 217 revision request)  
**Ready for Implementation**: Yes
