# Implementation Plan: Task #718

- **Task**: 718 - Investigate lean-lsp MCP hanging during Lean tasks
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/718_investigate_lean_lsp_mcp_hanging/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Address lean-lsp MCP hanging issues by updating documentation with timeout awareness guidance, improving Lean workflow patterns for safer tool usage, and establishing upstream issue monitoring. The research identified multiple contributing factors: Claude Code platform lacks MCP timeout/watchdog (#15945), lean-lsp-mcp has known diagnostic hang issues (#115, fixed in v4.26+), and files with compilation errors cause extended processing times.

### Research Integration

Key findings integrated from research-001.md:
- Project uses Lean v4.27.0-rc1 (safe from issue #115)
- Direct execution already in place for Lean skills
- SoundnessLemmas.lean has compilation errors causing slow diagnostics
- Early metadata and MCP recovery patterns already documented

## Goals & Non-Goals

**Goals**:
- Add timeout awareness guidance to Lean tool documentation
- Update MCP tools guide with file-state recommendations
- Document the `lean_goal` vs `lean_diagnostic_messages` trade-off
- Add upstream issue tracking section to relevant documentation
- Create separate task for SoundnessLemmas.lean fixes (out of scope for meta task)

**Non-Goals**:
- Fix SoundnessLemmas.lean compilation errors (Lean task, not meta)
- Implement timeout mechanisms (Claude Code platform responsibility)
- Migrate to SSE/HTTP transport (upstream dependency)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Documentation becomes stale as upstream fixes land | Medium | Medium | Add version/date stamps, reference issue numbers |
| Users miss new guidance | Low | Medium | Add cross-references to CLAUDE.md |
| Separate task creation forgotten | Medium | Low | Create in Phase 1, verify in Phase 4 |

## Implementation Phases

### Phase 1: Create Dependent Task and Update MCP Tools Guide [NOT STARTED]

**Goal**: Create task for SoundnessLemmas.lean fixes and add timeout awareness to MCP tools documentation

**Tasks**:
- [ ] Create new task for SoundnessLemmas.lean compilation error fixes (Language: lean)
- [ ] Update `.claude/context/project/lean4/tools/mcp-tools-guide.md`:
  - Add "File State Considerations" section after "Error Handling"
  - Document that files with compilation errors cause slow diagnostics
  - Add recommendation to pre-build or fix errors before diagnostic calls
  - Add note about `lean_diagnostic_messages` processing entire file vs `lean_goal` being point-specific

**Timing**: 45 minutes

**Files to modify**:
- `.claude/context/project/lean4/tools/mcp-tools-guide.md` - Add timeout awareness section
- `specs/state.json` - New task entry
- `specs/TODO.md` - New task entry

**Verification**:
- New task appears in TODO.md
- MCP tools guide contains "File State Considerations" section

---

### Phase 2: Update Multi-Instance Optimization Guide [NOT STARTED]

**Goal**: Add specific guidance for files with compilation errors and diagnostic tool selection

**Tasks**:
- [ ] Update `.claude/context/project/lean4/operations/multi-instance-optimization.md`:
  - Add "File-Specific Considerations" subsection under "Workflow Recommendations"
  - Document that files with errors (like SoundnessLemmas.lean) cause extended diagnostic times
  - Add recommendation: fix compilation errors before running diagnostics
  - Add recommendation: use `lean_goal` for specific positions, `lean_diagnostic_messages` for full file

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/lean4/operations/multi-instance-optimization.md` - Add file-specific guidance

**Verification**:
- Guide contains "File-Specific Considerations" section
- References SoundnessLemmas.lean as example

---

### Phase 3: Update MCP Recovery Patterns [NOT STARTED]

**Goal**: Add upstream issue monitoring section and tool selection guidance

**Tasks**:
- [ ] Update `.claude/context/core/patterns/mcp-tool-recovery.md`:
  - Add "Upstream Issue Tracking" section at end
  - List active issues to monitor: Claude Code #15945 (MCP timeout), lean-lsp-mcp #118 (build concurrency)
  - Add "Tool Selection for Diagnostics" guidance:
    - Prefer `lean_goal` for point-specific queries (faster)
    - Use `lean_diagnostic_messages` only when full file diagnostics needed
    - Avoid `lean_file_outline` on files with compilation errors

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/patterns/mcp-tool-recovery.md` - Add upstream tracking and tool selection

**Verification**:
- Document contains "Upstream Issue Tracking" section
- Document contains "Tool Selection for Diagnostics" guidance

---

### Phase 4: Update CLAUDE.md Cross-References [NOT STARTED]

**Goal**: Add cross-reference in CLAUDE.md Lean 4 Integration section for timeout awareness

**Tasks**:
- [ ] Update `.claude/CLAUDE.md` Lean 4 Integration section:
  - Add note under "MCP Tools" about timeout awareness for files with errors
  - Reference mcp-tools-guide.md "File State Considerations" section
- [ ] Verify SoundnessLemmas.lean task was created in Phase 1

**Timing**: 20 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Add timeout awareness note

**Verification**:
- CLAUDE.md references "File State Considerations" in mcp-tools-guide.md
- New Lean task for SoundnessLemmas.lean exists in TODO.md

---

### Phase 5: Verification and Summary [NOT STARTED]

**Goal**: Verify all documentation updates are consistent and complete

**Tasks**:
- [ ] Review all modified files for consistency
- [ ] Verify cross-references work
- [ ] Create implementation summary

**Timing**: 15 minutes

**Files to create**:
- `specs/718_investigate_lean_lsp_mcp_hanging/summaries/implementation-summary-{DATE}.md`

**Verification**:
- All 4 documentation files updated consistently
- Cross-references valid
- Summary created

## Testing & Validation

- [ ] Verify MCP tools guide has "File State Considerations" section
- [ ] Verify multi-instance guide has "File-Specific Considerations" section
- [ ] Verify MCP recovery patterns has "Upstream Issue Tracking" section
- [ ] Verify CLAUDE.md references new guidance
- [ ] Verify SoundnessLemmas.lean task created with language: lean

## Artifacts & Outputs

- Updated `.claude/context/project/lean4/tools/mcp-tools-guide.md`
- Updated `.claude/context/project/lean4/operations/multi-instance-optimization.md`
- Updated `.claude/context/core/patterns/mcp-tool-recovery.md`
- Updated `.claude/CLAUDE.md`
- New task in `specs/TODO.md` for SoundnessLemmas.lean fixes
- `specs/718_investigate_lean_lsp_mcp_hanging/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

Documentation updates are additive and non-breaking. If issues arise:
- Revert individual file changes via git
- Remove cross-references if target sections not created
- SoundnessLemmas.lean task can be abandoned if not needed
