# Implementation Plan: Task #902

- **Task**: 902 - ensure_opus_4_6_for_lean_subagents
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/902_ensure_opus_4_6_for_lean_subagents/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add `model: opus` to the YAML frontmatter of both Lean agent definition files to guarantee Opus 4.6 is used for theorem proving tasks. This is a minimal change (1 line per file) that enforces existing project conventions documented in CLAUDE.md.

### Research Integration

Key findings from research-001.md:
- Claude Code subagents support `model` frontmatter field with values: `opus`, `sonnet`, `haiku`, `inherit`
- Both Lean agents currently have no `model` field (defaulting to `inherit`)
- Adding `model: opus` provides guaranteed model selection, unlike advisory text in prompts
- Aligns with Team Skill Model Defaults table in CLAUDE.md

## Goals & Non-Goals

**Goals**:
- Add `model: opus` to lean-implementation-agent.md frontmatter
- Add `model: opus` to lean-research-agent.md frontmatter
- Ensure Opus 4.6 is used for all direct invocations of these agents

**Non-Goals**:
- Modifying team skill prompt text (frontmatter handles this)
- Updating other agent files (only Lean agents need Opus)
- Changing any agent behavior beyond model selection

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Higher API costs from Opus usage | Low | Expected | This is intended behavior; Opus is needed for theorem proving |
| Model alias changes in future | Low | Low | Claude Code aliases are stable; update if needed |
| Frontmatter syntax error | Low | Low | Simple YAML addition; verify file still parses |

## Implementation Phases

### Phase 1: Update Agent Frontmatter [COMPLETED]

- **Dependencies:** None
- **Goal:** Add `model: opus` to both Lean agent definition files

**Tasks:**
- [ ] Read lean-implementation-agent.md to verify current frontmatter
- [ ] Add `model: opus` after description field in lean-implementation-agent.md
- [ ] Read lean-research-agent.md to verify current frontmatter
- [ ] Add `model: opus` after description field in lean-research-agent.md

**Timing:** 15 minutes

**Files to modify:**
- `.claude/agents/lean-implementation-agent.md` - Add `model: opus` to frontmatter
- `.claude/agents/lean-research-agent.md` - Add `model: opus` to frontmatter

**Verification:**
- Both files parse correctly (no YAML errors)
- Both files contain `model: opus` in frontmatter section

**Progress:**

**Session: 2026-02-18, sess_1771469689_12592d**
- Added: `model: opus` to lean-implementation-agent.md frontmatter
- Added: `model: opus` to lean-research-agent.md frontmatter
- Completed: Phase 1 - both agent files now specify Opus model

---

### Phase 2: Verify and Document [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Confirm changes are correct and complete

**Tasks:**
- [x] Verify both agent files have valid YAML frontmatter
- [x] Confirm `model: opus` appears between `---` delimiters
- [x] Create implementation summary

**Timing:** 15 minutes

**Verification:**
- grep confirms `model: opus` in both files
- No YAML syntax errors

**Progress:**

**Session: 2026-02-18, sess_1771469689_12592d**
- Completed: Verification via grep - both files have `model: opus` on line 4
- Added: Implementation summary at summaries/implementation-summary-20260218.md

---

## Testing & Validation

- [ ] Both agent files have `model: opus` in frontmatter
- [ ] YAML frontmatter is valid (no syntax errors)
- [ ] Files are otherwise unchanged (only frontmatter modified)

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-20260218.md (after completion)

## Rollback/Contingency

Remove the `model: opus` line from both agent files to restore default `inherit` behavior. This is a trivial 1-line revert per file.
