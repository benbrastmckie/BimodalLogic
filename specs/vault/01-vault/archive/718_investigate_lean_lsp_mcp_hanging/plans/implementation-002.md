# Implementation Plan: Task #718 (Revised)

- **Task**: 718 - Investigate lean-lsp MCP hanging during Lean tasks
- **Version**: 002 (revised from 001)
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/718_investigate_lean_lsp_mcp_hanging/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Type**: meta
- **Lean Intent**: false

## Revision Notes

**Reason for revision**: User feedback - avoid diagnostics MCP operation for now (until upstream bugs fixed), keep Lean research and implementation skills simple without additional complications.

**Changes from v001**:
- Removed: Phases 2-4 updating Lean skill documentation and MCP patterns
- Simplified: Focus only on documenting the issue and creating follow-up task
- Removed: Updates to mcp-tools-guide.md, multi-instance-optimization.md, mcp-tool-recovery.md
- Removed: Updates to CLAUDE.md Lean 4 Integration section
- Retained: Task creation for SoundnessLemmas.lean fixes

**Key decision**: Accept current behavior and wait for upstream fixes rather than adding complexity to existing skills.

## Overview

This revised plan takes a minimal approach: document the root cause analysis (already done in research) and create a separate task for fixing the SoundnessLemmas.lean compilation errors. The core insight is that:

1. The hanging is caused by known upstream bugs (Claude Code #15945, lean-lsp-mcp #118)
2. Adding workarounds would complicate the Lean skills without solving the root issue
3. The best mitigation is to fix compilation errors in problematic files

## Goals & Non-Goals

**Goals**:
- Create task for SoundnessLemmas.lean fixes (addresses the specific file causing hangs)
- Complete task 718 with documented findings
- Accept "wait for upstream fix" as valid resolution

**Non-Goals**:
- Add timeout workarounds to Lean skills (over-complicates them)
- Update MCP documentation with file-state warnings (already in research report)
- Modify Lean research/implementation skill behavior

## Implementation Phases

### Phase 1: Create Dependent Task for SoundnessLemmas.lean [NOT STARTED]

**Goal**: Create a Lean task to fix the compilation errors causing diagnostic delays

**Tasks**:
- [ ] Create new task for SoundnessLemmas.lean compilation error fixes
  - Language: lean
  - Priority: medium (blocking for diagnostics but not critical path)
  - Description: Fix type mismatches and complete sorry'd proofs
  - Reference research-001.md findings about specific errors

**Timing**: 15 minutes

**Files to modify**:
- `specs/state.json` - New task entry
- `specs/TODO.md` - New task entry

**Verification**:
- New task appears in TODO.md with language: lean
- Task description references the specific errors found

---

### Phase 2: Complete Task 718 with Summary [NOT STARTED]

**Goal**: Finalize task 718 with implementation summary documenting the resolution approach

**Tasks**:
- [ ] Create implementation summary documenting:
  - Root cause: Multiple upstream bugs (documented in research-001.md)
  - Resolution approach: Wait for upstream fixes, avoid over-engineering workarounds
  - Mitigation: Fix SoundnessLemmas.lean errors (new task created)
  - Recommendation: If diagnostics hang, fix file errors or use `lean_goal` instead

**Timing**: 15 minutes

**Files to create**:
- `specs/718_investigate_lean_lsp_mcp_hanging/summaries/implementation-summary-{DATE}.md`

**Verification**:
- Summary explains decision to not complicate Lean skills
- Summary references new task for SoundnessLemmas.lean
- Summary references research report for detailed findings

## Testing & Validation

- [ ] Verify new Lean task created for SoundnessLemmas.lean
- [ ] Verify implementation summary documents the "accept and wait" approach
- [ ] Verify no changes made to Lean skill files

## Artifacts & Outputs

- New task in `specs/TODO.md` for SoundnessLemmas.lean fixes
- `specs/718_investigate_lean_lsp_mcp_hanging/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

This plan is minimal and additive:
- If SoundnessLemmas.lean task not needed, abandon it
- No skill modifications to revert
