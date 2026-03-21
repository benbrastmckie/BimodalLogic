# Implementation Plan: Task #633

- **Task**: 633 - fix_agent_return_format_consistency
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/633_fix_agent_return_format_consistency/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Fix contradictory return format instructions in latex-implementation-agent.md and general-implementation-agent.md that cause agents to dump JSON to console instead of writing to .return-meta.json file. Both agents have correct v2 file-based metadata instructions in their execution flow stages, but contradictory v1 legacy JSON console output patterns in their "Return Format Examples" and "Critical Requirements" sections. Additionally, add postflight validation to detect accidental JSON console output.

### Research Integration

Research report (research-001.md) identified:
- latex-implementation-agent.md has v2 pattern in Stages 7-8 (lines 210-267) but v1 pattern in Return Format Examples (lines 384-497) and Critical Requirements (lines 500-522)
- general-implementation-agent.md has v1 pattern throughout Stage 7 (lines 170-200), Return Format Examples (lines 328-426), and Critical Requirements (lines 428-449)
- lean-implementation-agent.md provides the reference implementation for correct v2 pattern

## Goals & Non-Goals

**Goals**:
- Update latex-implementation-agent.md to consistently use v2 file-based metadata pattern
- Update general-implementation-agent.md to consistently use v2 file-based metadata pattern
- Add postflight validation to detect accidental JSON console output

**Non-Goals**:
- Modifying the v2 metadata file schema itself
- Changing other agents that are already correctly implemented
- Modifying the core skill execution logic

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing agent behavior | Medium | Low | Both agents already have correct Stage 7-8 instructions; fix removes contradictions only |
| Validation false positives | Low | Low | Only check if return parses as valid JSON (text summaries won't) |
| Missing edge cases | Low | Medium | Text summaries starting with bullets won't trigger false positive |

## Implementation Phases

### Phase 1: Fix latex-implementation-agent.md [COMPLETED]

**Goal**: Update Return Format Examples and Critical Requirements sections to match v2 file-based metadata pattern

**Tasks**:
- [ ] Replace "Return Format Examples" section (lines 384-498) with text summary examples matching lean-implementation-agent.md pattern
- [ ] Update "Critical Requirements" section (lines 500-522) to specify file-based metadata pattern:
  - Change "Always return valid JSON" to "Always write metadata to `specs/{N}_{SLUG}/.return-meta.json`"
  - Change "MUST NOT return plain text instead of JSON" to "MUST NOT return JSON to the console"

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/latex-implementation-agent.md` - Replace Return Format Examples and update Critical Requirements

**Verification**:
- Return Format Examples section shows text summary examples (not JSON)
- Critical Requirements explicitly states to write metadata to file and return text summary
- No contradictions between stages 7-8 and later sections

---

### Phase 2: Fix general-implementation-agent.md [COMPLETED]

**Goal**: Update Stage 7, Return Format Examples, and Critical Requirements sections to match v2 file-based metadata pattern

**Tasks**:
- [ ] Change Stage 7 heading from "Return Structured JSON" to "Write Metadata File" + add "Stage 8: Return Brief Text Summary"
- [ ] Update Stage 7 content to describe writing metadata file (not returning JSON)
- [ ] Replace "Return Format Examples" section (lines 328-426) with text summary examples
- [ ] Update "Critical Requirements" section (lines 428-449) to specify v2 pattern:
  - Change "Always return valid JSON" to "Always write metadata to `specs/{N}_{SLUG}/.return-meta.json`"
  - Change "MUST NOT return plain text instead of JSON" to "MUST NOT return JSON to the console"
- [ ] Update Agent Metadata section (line 17) from "Return Format: JSON" to "Return Format: Brief text summary + metadata file"

**Timing**: 45 minutes

**Files to modify**:
- `.claude/agents/general-implementation-agent.md` - Comprehensive update to v2 pattern

**Verification**:
- Stage 7 describes writing metadata file, Stage 8 describes returning text summary
- Return Format Examples section shows text summary examples (not JSON)
- Critical Requirements explicitly states to write metadata to file and return text summary
- Agent Metadata reflects file-based return format

---

### Phase 3: Add Postflight Validation [COMPLETED]

**Goal**: Add validation in skill postflight to detect if subagent accidentally returned JSON to console

**Tasks**:
- [ ] Add Stage 5a "Validate Subagent Return Format" to skill-implementer/SKILL.md after Stage 5
- [ ] Add equivalent validation to skill-latex-implementation/SKILL.md after Stage 3 (Invoke Subagent)
- [ ] Validation logic: check if subagent text return parses as valid JSON (it shouldn't)

**Timing**: 15 minutes

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - Add Stage 5a validation
- `.claude/skills/skill-latex-implementation/SKILL.md` - Add validation after Stage 3

**Verification**:
- Skills detect JSON console output and log a warning
- Skills continue processing (read metadata file) even if warning triggered
- Warning message indicates agent may have outdated instructions

---

## Testing & Validation

- [ ] Verify latex-implementation-agent.md has no JSON examples in Return Format section
- [ ] Verify general-implementation-agent.md has no JSON examples in Return Format section
- [ ] Verify both agents have consistent v2 pattern in Critical Requirements
- [ ] Verify skill postflight validation logic is present in both skill files
- [ ] Cross-check with lean-implementation-agent.md to confirm pattern consistency

## Artifacts & Outputs

- `.claude/agents/latex-implementation-agent.md` - Updated to v2 pattern
- `.claude/agents/general-implementation-agent.md` - Updated to v2 pattern
- `.claude/skills/skill-implementer/SKILL.md` - Added postflight validation
- `.claude/skills/skill-latex-implementation/SKILL.md` - Added postflight validation
- `specs/633_fix_agent_return_format_consistency/summaries/implementation-summary-{DATE}.md` - Implementation summary

## Rollback/Contingency

All changes are to markdown documentation files with no runtime dependencies. If issues arise:
1. Revert individual file changes via git
2. Files can be restored from git history
3. No build or compilation steps required
