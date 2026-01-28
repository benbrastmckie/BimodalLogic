# Implementation Plan: Task #724

- **Task**: 724 - Investigate /revise command errors and design solution
- **Status**: [IMPLEMENTING]
- **Effort**: 3-4 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/724_investigate_revise_command_errors_design_solution/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Fix jq `!=` operator escaping issues caused by Claude Code's Bash tool (Issue #1132 variant). The root cause is confirmed: Claude Code transforms `!=` to `\!=` when executing jq commands inline, causing `INVALID_CHARACTER` parse errors. The solution uses shell script encapsulation - moving jq patterns with `!=` into shell scripts that execute directly, bypassing Claude Code's escaping.

### Research Integration

Key findings from research-001.md:
- 1 command file affected (revise.md - Priority 1, blocking)
- 7 skill files affected with identical patterns
- 2 context/pattern files contain vulnerable examples
- Existing postflight-*.sh scripts demonstrate the working pattern
- Shell scripts work because they execute directly, not through Claude Code's Bash tool

## Goals & Non-Goals

**Goals**:
- Fix the immediate `/revise` command jq errors
- Fix all affected skill files to prevent similar failures
- Update documentation to explain the `!=` escaping issue (distinct from pipe injection)
- Establish clear design pattern for future commands/skills

**Non-Goals**:
- Fix Claude Code Issue #1132 upstream (marked NOT_PLANNED)
- Modify shell scripts (they already work correctly)
- Change the two-step jq pattern (it works when in shell scripts)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Script delegation adds complexity | Low | Low | Use existing postflight-*.sh pattern; minimal change |
| New escaping issues discovered | Medium | Low | Comprehensive testing before rollout |
| Documentation drift | Low | Medium | Centralize pattern docs, reference from affected files |

## Implementation Phases

### Phase 1: Fix /revise Command [NOT STARTED]

**Goal**: Make /revise command work by delegating to postflight-plan.sh

**Tasks**:
- [ ] Read current revise.md STAGE 2A artifact update logic (lines 67-84)
- [ ] Replace inline jq with call to `.claude/scripts/postflight-plan.sh`
- [ ] Update the jq escaping comment to reference the `!=` variant specifically
- [ ] Test with a sample task revision

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/revise.md` - Replace inline jq artifact update with script call

**Verification**:
- Run `/revise` on a test task and confirm no jq errors
- Verify state.json artifact is updated correctly
- Verify plan file is linked in state.json

---

### Phase 2: Fix Skill Files [NOT STARTED]

**Goal**: Update all 7 affected skill files to use postflight scripts instead of inline jq

**Tasks**:
- [ ] Fix skill-planner/SKILL.md (line 212) - already has postflight-plan.sh available
- [ ] Fix skill-researcher/SKILL.md (line 205) - use postflight-research.sh
- [ ] Fix skill-lean-research/SKILL.md (line 296) - use postflight-research.sh
- [ ] Fix skill-implementer/SKILL.md (line 306) - use postflight-implement.sh
- [ ] Fix skill-lean-implementation/SKILL.md (line 390) - use postflight-implement.sh
- [ ] Fix skill-latex-implementation/SKILL.md (line 251) - use postflight-implement.sh
- [ ] Fix skill-typst-implementation/SKILL.md (line 250) - use postflight-implement.sh

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/skills/skill-planner/SKILL.md`
- `.claude/skills/skill-researcher/SKILL.md`
- `.claude/skills/skill-lean-research/SKILL.md`
- `.claude/skills/skill-implementer/SKILL.md`
- `.claude/skills/skill-lean-implementation/SKILL.md`
- `.claude/skills/skill-latex-implementation/SKILL.md`
- `.claude/skills/skill-typst-implementation/SKILL.md`

**Verification**:
- Grep for `select(.type !=` in skill files returns zero matches
- Each skill postflight section references appropriate postflight script
- No inline jq with `!=` operator remains

---

### Phase 3: Update Documentation [NOT STARTED]

**Goal**: Document the `!=` escaping issue explicitly and update pattern examples

**Tasks**:
- [ ] Update jq-escaping-workarounds.md to add `!=` escaping to Bug Description
- [ ] Add explicit section explaining `!=` vs pipe injection difference
- [ ] Update inline-status-update.md to remove vulnerable examples or add warnings
- [ ] Add shell script encapsulation as PRIMARY recommendation (not just alternative)
- [ ] Update error-handling.md jq_parse_failure section to mention `!=`

**Timing**: 45 minutes

**Files to modify**:
- `.claude/context/core/patterns/jq-escaping-workarounds.md`
- `.claude/context/core/patterns/inline-status-update.md`
- `.claude/rules/error-handling.md`

**Verification**:
- jq-escaping-workarounds.md explicitly mentions `!=` escaping
- Shell script encapsulation is listed as primary solution
- inline-status-update.md examples use safe patterns or reference scripts

---

### Phase 4: Add Design Pattern Reference [NOT STARTED]

**Goal**: Establish clear guidance in CLAUDE.md for future commands/skills

**Tasks**:
- [ ] Add a "jq Command Safety" section to CLAUDE.md or reference existing docs
- [ ] Create a quick-reference table of safe vs unsafe patterns
- [ ] Add reference in Skill Architecture section about postflight script usage
- [ ] Update Command Reference section with note about jq patterns

**Timing**: 30 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Add jq safety guidance or reference

**Verification**:
- CLAUDE.md contains clear guidance on avoiding inline jq with `!=`
- Reference to jq-escaping-workarounds.md is present
- Postflight script pattern is documented as standard practice

---

### Phase 5: Final Testing and Cleanup [NOT STARTED]

**Goal**: Comprehensive verification that all fixes work correctly

**Tasks**:
- [ ] Grep entire .claude/ directory for remaining `select(.type !=` patterns
- [ ] Test /revise command end-to-end
- [ ] Test at least one skill from each category (research, plan, implement)
- [ ] Verify git commits are clean
- [ ] Create implementation summary

**Timing**: 30 minutes

**Verification**:
- No vulnerable patterns remain in command/skill files
- /revise command completes without jq errors
- Sample skill operations complete without jq errors
- All documentation is consistent

## Testing & Validation

- [ ] Run `/revise` on task with existing plan - no jq errors
- [ ] Grep `.claude/` for `select(.type !=` - only in shell scripts
- [ ] Verify postflight-*.sh scripts still work (no regression)
- [ ] Review documentation for completeness

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (on completion)
- Modified files:
  - 1 command file (.claude/commands/revise.md)
  - 7 skill files (.claude/skills/**/SKILL.md)
  - 3 documentation files (.claude/context/core/patterns/*, .claude/rules/error-handling.md)
  - 1 main doc file (.claude/CLAUDE.md)

## Rollback/Contingency

If implementation causes unexpected issues:
1. Revert changes with `git checkout HEAD~N -- .claude/`
2. Document the new issue in errors.json
3. Create follow-up task for alternative approach

Since all changes are to .claude/ configuration files (not production code), rollback is straightforward via git.
