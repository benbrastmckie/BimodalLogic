# Implementation Plan: Task #832

- **Task**: 832 - update_artifact_formats_agent_sorry_guidance
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: Task 831 (provides updated sorry-debt-policy.md with framing rules)
- **Research Inputs**: specs/832_update_artifact_formats_agent_sorry_guidance/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Propagate consistent sorry characterization guidance from sorry-debt-policy.md into artifact formats (report-format.md, plan-format.md) and Lean agent definitions (lean-research-agent.md, lean-implementation-agent.md). The key constraint is that format files serve ALL task types, so sorry sections must be clearly marked as "Lean only" with conditional applicability.

### Research Integration

Research report research-001.md identified 6 specific updates with exact insertion points:
1. report-format.md - Add "Sorry Characterization (Lean only)" section
2. plan-format.md - Add "Sorry Characterization (Lean only)" section
3. lean-research-agent.md - Move sorry-debt-policy.md to Always Load
4. lean-research-agent.md - Add MUST NOT prohibition
5. lean-implementation-agent.md - Move sorry-debt-policy.md to Always Load
6. lean-implementation-agent.md - Add MUST NOT prohibition

## Goals & Non-Goals

**Goals**:
- Add conditional "Sorry Characterization (Lean only)" section to report-format.md
- Add conditional "Sorry Characterization (Lean only)" section to plan-format.md
- Make sorry-debt-policy.md mandatory context for both Lean agents
- Add explicit prohibition against "acceptable sorry" framing in agent critical requirements
- Ensure non-Lean tasks are unaffected by these changes

**Non-Goals**:
- Updating sorry-debt-policy.md content (handled by task 831)
- Retroactively fixing existing reports/plans that use "acceptable" language
- Modifying non-Lean agents

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Format files become verbose | M | L | Keep sorry section clearly optional, with explicit "Lean only" marker |
| Agents ignore new mandatory context | M | L | Redundant enforcement via Critical Requirements prohibition |
| Merge conflict with task 831 | L | M | Task 832 only references sorry-debt-policy.md, doesn't modify it |
| Non-Lean tasks confused by sorry sections | M | L | Clear "Applicability" statement at start of each section |

## Implementation Phases

### Phase 1: Update report-format.md [COMPLETED]

**Goal**: Add conditional Sorry Characterization section for Lean reports

**Tasks**:
- [ ] Add "Sorry Characterization (Lean reports only)" section after "Project Context (Lean only)" section
- [ ] Include applicability statement, purpose, required elements, framing rules, and example
- [ ] Verify section clearly indicates Lean-only applicability

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/core/formats/report-format.md` - Add new section after line 37

**Verification**:
- File contains "Sorry Characterization (Lean reports only)" heading
- Section includes "Applicability: Include this section only for Lean research reports"
- Section includes prohibited phrases list (NEVER use: "acceptable sorry", etc.)
- Section includes required framing alternatives (ALWAYS use: "tolerated during development", etc.)

---

### Phase 2: Update plan-format.md [COMPLETED]

**Goal**: Add conditional Sorry Characterization section for Lean plans

**Tasks**:
- [ ] Add "Sorry Characterization (Lean plans only)" section after "Risks & Mitigations" in structure list
- [ ] Add detailed section content with applicability, required elements, framing rules, and example
- [ ] Verify section clearly indicates Lean-only applicability

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/core/formats/plan-format.md` - Add entry to Structure list (around line 70) and detailed section content

**Verification**:
- Structure list includes "Sorry Characterization (Lean plans only)"
- Detailed section includes applicability conditions
- Section includes prohibited/required framing patterns
- Example demonstrates proper characterization

---

### Phase 3: Update lean-research-agent.md [COMPLETED]

**Goal**: Make sorry-debt-policy.md mandatory and add framing prohibition

**Tasks**:
- [ ] Move sorry-debt-policy.md from "Load for Sorry Handling" to "Always Load" section
- [ ] Remove empty "Load for Sorry Handling" section
- [ ] Add item 12 to MUST NOT section: "Use 'acceptable sorry' framing"

**Timing**: 15 minutes

**Files to modify**:
- `.claude/agents/lean-research-agent.md` - Lines 76-88 (Context References) and line 200 (MUST NOT)

**Verification**:
- "Always Load" section includes sorry-debt-policy.md with annotation "(REQUIRED for correct characterization)"
- "Load for Sorry Handling" section is removed
- MUST NOT section includes prohibition against "acceptable" framing
- MUST NOT item number is correct (12)

---

### Phase 4: Update lean-implementation-agent.md [COMPLETED]

**Goal**: Make sorry-debt-policy.md mandatory and add framing prohibition

**Tasks**:
- [ ] Move sorry-debt-policy.md from "Load for Sorry Handling" to "Always Load" section
- [ ] Remove "Load for Sorry Handling" section
- [ ] Add item 14 to MUST NOT section: "Use 'acceptable sorry' framing"

**Timing**: 15 minutes

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Lines 73-86 (Context References) and line 218 (MUST NOT)

**Verification**:
- "Always Load" section includes sorry-debt-policy.md with annotation "(REQUIRED for correct characterization)"
- "Load for Sorry Handling" section is removed
- MUST NOT section includes prohibition against "acceptable" framing
- MUST NOT item number is correct (14)

---

### Phase 5: Verification [COMPLETED]

**Goal**: Ensure all changes are correct and consistent

**Tasks**:
- [ ] Verify report-format.md sorry section is properly conditional on Lean
- [ ] Verify plan-format.md sorry section is properly conditional on Lean
- [ ] Verify both agents have sorry-debt-policy.md in Always Load
- [ ] Verify both agents have MUST NOT prohibition
- [ ] Check for any formatting/consistency issues across files

**Timing**: 10 minutes

**Verification**:
- All 4 files have been modified
- Sorry sections in formats use identical framing rules (prohibited/required phrases match)
- Agent prohibition text is consistent between both agents
- No broken markdown formatting

## Testing & Validation

- [ ] report-format.md contains "Sorry Characterization (Lean reports only)" section with applicability statement
- [ ] plan-format.md contains "Sorry Characterization (Lean plans only)" section with applicability conditions
- [ ] lean-research-agent.md has sorry-debt-policy.md in Always Load section
- [ ] lean-research-agent.md MUST NOT section includes "acceptable sorry" prohibition
- [ ] lean-implementation-agent.md has sorry-debt-policy.md in Always Load section
- [ ] lean-implementation-agent.md MUST NOT section includes "acceptable sorry" prohibition
- [ ] All prohibited phrases listed: "acceptable sorry", "acceptable limitation", "sorry is fine", "okay to have sorry", "<N acceptable"
- [ ] All required phrases listed: "tolerated during development", "technical debt", "blocks publication", "inherited by dependents"

## Artifacts & Outputs

- `.claude/context/core/formats/report-format.md` - Updated with Sorry Characterization section
- `.claude/context/core/formats/plan-format.md` - Updated with Sorry Characterization section
- `.claude/agents/lean-research-agent.md` - Updated context references and critical requirements
- `.claude/agents/lean-implementation-agent.md` - Updated context references and critical requirements
- `specs/832_update_artifact_formats_agent_sorry_guidance/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

All changes are to markdown documentation files. If issues arise:
1. Use git to revert individual file changes: `git checkout HEAD~1 -- <file>`
2. Format files and agent definitions have no runtime dependencies
3. No code changes involved, so no build risks

If task 831 is not completed when this task runs:
- The sorry-debt-policy.md reference will still be valid (file exists)
- Framing rules in this task mirror what task 831 adds, providing redundancy
