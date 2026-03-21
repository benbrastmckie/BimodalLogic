# Implementation Plan: Task #883 (Version 2)

- **Task**: 883 - Phase Progress Tracking in Plan Files
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: research-001.md (gap analysis), research-002.md (context loading analysis)
- **Artifacts**: plans/implementation-002.md (this file)
- **Previous Version**: plans/implementation-001.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task adds structured Progress subsections to implementation plan phases. The research identified that progress is tracked through disconnected mechanisms (progress files, handoffs), but the canonical plan files lack formal progress documentation. Task 881 demonstrated valuable ad-hoc "Infrastructure Added" sections which this task standardizes.

**Version 2 Changes** (from research-002.md):
- Phase 1 now updates BOTH artifact-formats.md AND plan-format.md (formats must stay in sync)
- Phases 2-3 remove redundant context references and add tiered loading pattern
- Context consolidation opportunities (510 lines) tracked as separate future work

### Research Integration

Key findings from research-001.md:
- Three disconnected progress tracking mechanisms exist
- No formal mechanism copies progress back to plan files
- Recommended format: Progress subsection with session entries, action verbs, and outcome tracking

Key findings from research-002.md:
- return-metadata-file.md referenced 3x redundantly (skill + both agents)
- plan-format.md lacks Progress subsection that artifact-formats.md will get
- Agents should use tiered loading pattern (Always/After Stage 0/For Implementation)

## Goals & Non-Goals

**Goals**:
- Define Progress subsection format in artifact-formats.md AND plan-format.md
- Update lean-implementation-agent.md with progress requirement and tiered loading
- Update general-implementation-agent.md with progress requirement and tiered loading
- Update lean-implementation-flow.md with Stage 4E for progress updates

**Non-Goals**:
- Retrofitting existing plans with Progress subsections
- Automatic migration of progress.json content to plan files
- Context file consolidation (separate task: ~510 lines opportunity)
- Removing handoff-artifact.md or progress-file.md (complementary purposes)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Agent context overhead | Medium | Low | Progress section is append-only, minimal read overhead |
| Format inconsistency | Medium | Medium | Update both artifact-formats.md AND plan-format.md |
| Progress bloat in long-running tasks | Low | Medium | Keep session entries concise (2-5 bullets max) |
| Tiered loading complexity | Low | Low | Simple conditional pattern, already used in lean-impl-agent |

## Implementation Phases

### Phase 1: Define Progress Subsection Format [COMPLETED]

- **Dependencies:** None
- **Goal:** Add Progress subsection specification to BOTH artifact-formats.md AND plan-format.md

**Tasks**:
- [ ] Add Progress Subsection section to `.claude/rules/artifact-formats.md` under Phase Status Markers
- [ ] Add Progress Subsection section to `.claude/context/core/formats/plan-format.md` in Phase Content section
- [ ] Define format: session header with date and session_id
- [ ] Define action verbs: Added, Fixed, Completed, Removed
- [ ] Define outcome tracking: sorry/axiom delta format (N -> M) for Lean tasks
- [ ] Document no-progress sessions recording pattern
- [ ] Include example from task 881 "Infrastructure Added" pattern

**Progress Subsection Format** (to add):
```markdown
**Progress:**

**Session: YYYY-MM-DD, sess_NNNNNN_XXXXXX**
- Added: `lemma_name` - description
- Fixed: `function_name` by adding precondition
- Completed: `objective_name` (was N sorries, now 0)
- Sorries: 18 -> 14 (4 eliminated)

**Session: YYYY-MM-DD, sess_NNNNNN_YYYYYY** (no progress)
- Attempted: approach description
- Result: blocked by issue
- No changes committed
```

**Timing**: 30 minutes

**Files to modify**:
- `.claude/rules/artifact-formats.md` - Add Progress Subsection section
- `.claude/context/core/formats/plan-format.md` - Add Progress Subsection to phase structure

**Verification**:
- Progress subsection format documented in both files
- Format includes session_id, date, action items, and outcome tracking
- No-progress sessions pattern documented

---

### Phase 2: Update lean-implementation-agent.md [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Add Progress subsection writing to phase checkpoint protocol with tiered loading

**Tasks**:
- [ ] Update Context References to use tiered loading pattern:
  ```markdown
  **Always Load**:
  - (none - return-metadata-file.md loaded by skill)

  **Load After Stage 0**:
  - @.claude/context/project/lean4/agents/lean-implementation-flow.md

  **Load for Progress Updates**:
  - @.claude/rules/artifact-formats.md (Progress Subsection section)
  ```
- [ ] Update Critical Requirements MUST DO list to include:
  - "Write Progress subsection to plan file before committing phase"
- [ ] Add instruction to write Progress subsection after phase status update, before git commit

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Update Context References and Critical Requirements

**Verification**:
- Agent uses tiered loading pattern
- Critical Requirements includes progress update requirement
- No duplicate return-metadata-file.md reference

---

### Phase 3: Update general-implementation-agent.md [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Add Progress subsection writing with tiered loading pattern

**Tasks**:
- [ ] Update Context References to use tiered loading pattern:
  ```markdown
  **Always Load**:
  - (none - return-metadata-file.md loaded by skill)

  **Load for Meta Tasks**:
  - @.claude/CLAUDE.md
  - @.claude/context/index.md

  **Load for Progress Updates**:
  - @.claude/rules/artifact-formats.md (Progress Subsection section)
  ```
- [ ] Update Phase Checkpoint Protocol to include progress update step
- [ ] Update Critical Requirements MUST DO list to include progress update

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/general-implementation-agent.md` - Update Context References and checkpoint protocol

**Verification**:
- Agent uses tiered loading pattern
- Checkpoint protocol includes progress update step
- No duplicate return-metadata-file.md reference

---

### Phase 4: Update lean-implementation-flow.md [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Add Stage 4E for Progress Subsection updates

**Tasks**:
- [ ] Add Stage 4E: Update Progress Subsection after Stage 4D (Mark Phase Complete)
- [ ] Document exact content to capture:
  - session_id from delegation context
  - date in YYYY-MM-DD format
  - items added/fixed/completed with lemma names
  - outcome delta (sorries: N -> M, if applicable)
- [ ] Update Phase Checkpoint Protocol summary to include Stage 4E
- [ ] Add example Progress entry for clarity

**Stage 4E Content** (to add):
```markdown
### Stage 4E: Update Progress Subsection

After marking phase status, append session entry to plan file:

1. Read current plan file
2. Find the current phase section
3. Locate or create **Progress:** subsection
4. Append session entry with:
   - Session header: `**Session: {date}, {session_id}**`
   - Action items: Added/Fixed/Completed with names
   - Outcome delta: sorries/axioms change if applicable
5. Write updated plan file

**Example**:
```markdown
**Progress:**

**Session: 2026-02-16, sess_1771302929_655861**
- Added: `buildSeedAux_preserves_mem_general` (key monotonicity lemma)
- Completed: `buildSeed_contains_formula` (was 6 sorries, now 0)
- Sorries: 18 -> 11 (7 eliminated)
```

If no changes were made:
```markdown
**Session: 2026-02-16, sess_1771302929_655861** (no progress)
- Attempted: induction approach for consistency
- Result: blocked by mutual consistency requirement
- No changes committed
```
```

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/lean4/agents/lean-implementation-flow.md` - Add Stage 4E

**Verification**:
- Stage 4E documented between status update and git commit
- Phase Checkpoint Protocol updated
- Examples included for both progress and no-progress cases

---

## Testing & Validation

- [ ] All files modified exist and are non-empty
- [ ] artifact-formats.md contains Progress Subsection section
- [ ] plan-format.md contains Progress Subsection in phase structure
- [ ] lean-implementation-agent.md has tiered loading and progress requirement
- [ ] general-implementation-agent.md has tiered loading and progress requirement
- [ ] lean-implementation-flow.md contains Stage 4E with examples

## Artifacts & Outputs

- `.claude/rules/artifact-formats.md` - Updated with Progress Subsection format
- `.claude/context/core/formats/plan-format.md` - Updated with Progress Subsection
- `.claude/agents/lean-implementation-agent.md` - Updated with tiered loading and progress instructions
- `.claude/agents/general-implementation-agent.md` - Updated with tiered loading and progress instructions
- `.claude/context/project/lean4/agents/lean-implementation-flow.md` - Updated with Stage 4E
- `specs/883_phase_progress_tracking_in_plan_files/summaries/implementation-summary-{DATE}.md` - Summary

## Future Work (Out of Scope)

Context consolidation opportunities identified in research-002.md (~510 lines):
- Merge summary-format.md into artifact-formats.md (~60 lines)
- Remove file-metadata-exchange.md if unused (~100 lines)
- Simplify postflight-control.md (~150 lines)
- Unify agent base patterns (~200 lines shared sections)

These should be tracked as a separate task.

## Rollback/Contingency

All changes are additive to existing documentation. Rollback by reverting the git commit. No runtime behavior changes - agents will adopt new behavior on next invocation after documentation update.
