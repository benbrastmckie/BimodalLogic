# Implementation Plan: Add Explicit Continuation Guards to Command Files

- **Task**: 530 - Add Explicit Continuation Guards to Command Files
- **Status**: [NOT STARTED]
- **Effort**: 2-3 hours
- **Priority**: High
- **Dependencies**: 529 (completed - unified single-execution pattern)
- **Research Inputs**: specs/529_unify_workflow_commands_single_execution/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add explicit "DO NOT STOP" and "CONTINUE EXECUTION" guards at critical transition points in workflow command files. These guards reinforce that skill completion does not mean workflow completion, addressing the persistent halting issue where Claude interprets skill returns as conversation boundaries.

### Research Integration

Task 529 research confirmed that Claude treats ANY Skill tool completion as a potential stop point, regardless of return status values. The current command files (research.md, plan.md, implement.md) have mild continuation language ("IMMEDIATELY CONTINUE") but lack the emphatic guards needed to override Claude's default stop behavior.

## Goals & Non-Goals

**Goals**:
- Add emphatic continuation guards at all checkpoint transitions
- Create a consistent guard pattern across all workflow commands
- Document the guard pattern for future command/skill creation
- Ensure guards are visually prominent (bold, caps, explicit instructions)

**Non-Goals**:
- Refactoring command structure (done in task 529)
- Modifying skill return formats (covered by anti-stop-patterns.md)
- Adding guards to skills (they handle their own continuation internally)
- Modifying agent files (already have anti-stop patterns)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Guards still insufficient to prevent halting | Medium | Low | Use multiple reinforcement patterns (bold, caps, explicit verbs) |
| Guards make commands harder to read | Low | Medium | Keep guards concise, use consistent formatting |
| Inconsistent guard placement | Low | Medium | Define standard locations in pattern documentation |
| Guards get removed during future edits | Medium | Low | Document in CLAUDE.md and pattern files |

## Implementation Phases

### Phase 1: Define Guard Pattern Standard [NOT STARTED]

**Goal**: Create a documented standard for continuation guards

**Tasks**:
- [ ] Create `.claude/context/core/patterns/continuation-guards.md` with:
  - Guard syntax specification
  - Placement rules (before checkpoints, after skill returns)
  - Visual formatting requirements (bold, caps)
  - Example guards for different transition types
- [ ] Define three guard levels:
  - **CHECKPOINT BOUNDARY**: Between major checkpoints
  - **SKILL RETURN**: After Skill tool invocations
  - **CRITICAL TRANSITION**: At points historically prone to halting

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/patterns/continuation-guards.md` (new file)

**Verification**:
- Pattern file exists with complete guard specification
- Three guard levels defined with examples

---

### Phase 2: Update /research Command [NOT STARTED]

**Goal**: Add continuation guards to research.md

**Tasks**:
- [ ] Add CHECKPOINT BOUNDARY guard before CHECKPOINT 2 (DELEGATE)
- [ ] Add SKILL RETURN guard after DELEGATE skill invocation
- [ ] Add CHECKPOINT BOUNDARY guard before CHECKPOINT 3 (COMMIT)
- [ ] Add emphatic "DO NOT STOP" warning at start of CHECKPOINT 2
- [ ] Strengthen existing "IMMEDIATELY CONTINUE" language to "EXECUTE NOW"

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/research.md`

**Verification**:
- Guards present at all three checkpoint transitions
- "DO NOT STOP" warning present in DELEGATE section
- Visual inspection confirms guards are prominent

---

### Phase 3: Update /plan Command [NOT STARTED]

**Goal**: Add continuation guards to plan.md

**Tasks**:
- [ ] Add CHECKPOINT BOUNDARY guard before CHECKPOINT 2 (DELEGATE)
- [ ] Add SKILL RETURN guard after DELEGATE skill invocation
- [ ] Add CHECKPOINT BOUNDARY guard before CHECKPOINT 3 (COMMIT)
- [ ] Add emphatic "DO NOT STOP" warning at start of CHECKPOINT 2
- [ ] Ensure consistent formatting with research.md

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/plan.md`

**Verification**:
- Guards match pattern established in Phase 2
- Consistent formatting with research.md
- All checkpoint transitions covered

---

### Phase 4: Update /implement Command [NOT STARTED]

**Goal**: Add continuation guards to implement.md

**Tasks**:
- [ ] Add CHECKPOINT BOUNDARY guard before CHECKPOINT 2 (DELEGATE)
- [ ] Add SKILL RETURN guard after DELEGATE skill invocation
- [ ] Add CHECKPOINT BOUNDARY guard before CHECKPOINT 3 (COMMIT)
- [ ] Add emphatic "DO NOT STOP" warning at start of CHECKPOINT 2
- [ ] Add guard for both completion and partial completion paths
- [ ] Ensure consistent formatting with other commands

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/implement.md`

**Verification**:
- Guards match pattern established in Phases 2-3
- Both completion and partial paths have guards
- Consistent formatting across all command files

---

### Phase 5: Update Documentation [NOT STARTED]

**Goal**: Ensure continuation guards are documented for maintenance

**Tasks**:
- [ ] Add reference to continuation-guards.md in CLAUDE.md (Rules References section)
- [ ] Update .claude/context/core/patterns/anti-stop-patterns.md to reference continuation guards
- [ ] Update .claude/context/index.md to include new pattern file

**Timing**: 20 minutes

**Files to modify**:
- `.claude/CLAUDE.md`
- `.claude/context/core/patterns/anti-stop-patterns.md`
- `.claude/context/index.md`

**Verification**:
- CLAUDE.md references continuation guards
- anti-stop-patterns.md links to continuation-guards.md
- index.md includes new pattern file

---

## Testing & Validation

- [ ] Run `/research` on a test task and verify no halt between checkpoints
- [ ] Run `/plan` on a test task and verify no halt between checkpoints
- [ ] Run `/implement` on a test task and verify no halt between checkpoints
- [ ] Visual inspection: all guard text is visually prominent (bold, caps)
- [ ] Consistency check: guard formatting identical across all three commands

## Artifacts & Outputs

- `.claude/context/core/patterns/continuation-guards.md` (new pattern file)
- `.claude/commands/research.md` (updated with guards)
- `.claude/commands/plan.md` (updated with guards)
- `.claude/commands/implement.md` (updated with guards)
- `.claude/CLAUDE.md` (documentation reference added)
- `specs/530_add_continuation_guards_to_commands/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If guards prove ineffective or cause other issues:
1. Guards are additive text - can be removed without structural changes
2. Original command files preserved in git history
3. Each phase can be reverted independently

## Guard Design Specification

### Standard Guard Formats

**CHECKPOINT BOUNDARY Guard** (use between major checkpoints):
```markdown
---

**CRITICAL: DO NOT STOP HERE**

The workflow is NOT complete. You MUST continue to the next checkpoint.

---
```

**SKILL RETURN Guard** (use immediately after Skill tool invocation):
```markdown
**EXECUTION CONTINUES**: The skill has returned. This is NOT a stopping point.
Proceed IMMEDIATELY to the next section without pausing.
```

**VALIDATE-TO-DELEGATE Guard** (specific to CHECKPOINT 1 → 2 transition):
```markdown
**On VALIDATE success**: Task validated. **DO NOT STOP. EXECUTE CHECKPOINT 2 NOW.**
```

### Placement Rules

1. **Before CHECKPOINT 2 (DELEGATE)**: Add horizontal rule + CHECKPOINT BOUNDARY guard
2. **Inside CHECKPOINT 2**: Begin with emphatic "EXECUTE NOW" instruction
3. **After skill invocation**: Add SKILL RETURN guard
4. **Before CHECKPOINT 3 (COMMIT)**: Add horizontal rule + CHECKPOINT BOUNDARY guard
5. **At end of each checkpoint section**: Add transition instruction with DO NOT STOP
