# Implementation Plan: Task #689

- **Task**: 689 - update_context_from_constitutive_foundation_notes
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/689_update_context_from_constitutive_foundation_notes/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan addresses the variable naming convention update requested in the NOTE: tag at line 21 of `02-ConstitutiveFoundation.tex`. The convention change reserves `x, y, z` for metalanguage durations and introduces `v_1, v_2, v_3, ...` for object language variables. This requires updating 5 context files, the LaTeX source file, and optionally adding a LaTeX macro.

### Research Integration

The research report (research-001.md) identified:
- 5 context files requiring updates
- Current ambiguity where `x, y, z` is used for both object language variables and metalanguage durations
- Recommendation to add `\objvar{n}` macro to `logos-notation.sty`

## Goals & Non-Goals

**Goals**:
- Establish clear distinction between object language variables (`v_1, v_2, ...`) and metalanguage duration variables (`x, y, z`)
- Update all 5 identified context files consistently
- Update the LaTeX source file to use the new convention
- Remove the NOTE: tag after documentation is complete
- Add optional `\objvar{n}` macro for convenience

**Non-Goals**:
- Modifying Lean source code (convention is documentation-focused)
- Changing existing formulas in proofs (backward compatibility)
- Updating files not identified in research (scope limitation)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inconsistency with existing documentation | Medium | Low | Search for other `x, y, z` usages in documentation |
| Reader confusion during transition | Low | Low | Add explicit notes explaining convention |
| LaTeX macro conflicts | Low | Low | Use unique macro name `\objvar` |

## Implementation Phases

### Phase 1: Update Logic Standards Context Files [COMPLETED]

**Goal**: Update the two primary logic standards files with the new variable naming convention.

**Tasks**:
- [ ] Update `.claude/context/project/logic/standards/naming-conventions.md` - Add object language variables row (`v_1, v_2, v_3`) to Formula Variables table, add clarification that `x, y, z` reserved for metalanguage durations
- [ ] Update `.claude/context/project/logic/standards/notation-standards.md` - Add object language variables row, update Times row to clarify `x, y, z` reserved for durations

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/logic/standards/naming-conventions.md` - Add row to Variable Naming section
- `.claude/context/project/logic/standards/notation-standards.md` - Update Formula Variable Naming table

**Verification**:
- Grep for "object language variable" in updated files
- Verify table formatting is correct

---

### Phase 2: Update LaTeX Context Files [COMPLETED]

**Goal**: Update LaTeX templates and notation conventions to reflect the new variable naming.

**Tasks**:
- [ ] Update `.claude/context/project/latex/templates/subfile-template.md` - Change `$x, y, z, \ldots$` to `$v_1, v_2, v_3, \ldots$` in Variables item
- [ ] Update `.claude/context/project/latex/standards/notation-conventions.md` - Add "Variable Naming" section with object language and metalanguage variable tables

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/project/latex/templates/subfile-template.md` - Line 67 in Filled Example section
- `.claude/context/project/latex/standards/notation-conventions.md` - Add new section after Meta-Variables

**Verification**:
- Verify subfile template shows `v_1, v_2, v_3` for variables
- Verify notation-conventions.md has new Variable Naming section

---

### Phase 3: Update Lean4 Style Guide [COMPLETED]

**Goal**: Update the Lean4 style guide to include object language variable conventions.

**Tasks**:
- [ ] Update `.claude/context/project/lean4/standards/lean4-style-guide.md` - Add object language variables row to Quick Reference Table, clarify times/durations row

**Timing**: 15 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/lean4-style-guide.md` - Lines 61-64 in Quick Reference Table

**Verification**:
- Table includes `v_1`, `v_2`, `v_3` row for object language variables
- Times row clarifies `x, y, z` for durations

---

### Phase 4: Update LaTeX Source and Add Macro [COMPLETED]

**Goal**: Update the original LaTeX source file and optionally add the `\objvar{n}` macro.

**Tasks**:
- [ ] Update `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` line 24 to use `v_1, v_2, v_3, \ldots`
- [ ] Remove NOTE: tag from line 21
- [ ] Add `\objvar{n}` macro to `Theories/Logos/latex/logos-notation.sty`

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Lines 21-24
- `Theories/Logos/latex/logos-notation.sty` - Add new macro

**Verification**:
- NOTE: tag removed
- Variables line shows `v_1, v_2, v_3, \ldots`
- `\objvar{1}` produces `v_1` in LaTeX

---

### Phase 5: Final Verification and Summary [COMPLETED]

**Goal**: Verify all changes are consistent and create implementation summary.

**Tasks**:
- [ ] Grep codebase for remaining incorrect usages of `x, y, z` for object language variables
- [ ] Verify all 5 context files are updated consistently
- [ ] Verify LaTeX compiles without errors
- [ ] Create implementation summary

**Timing**: 10 minutes

**Files to modify**:
- Create implementation summary at `specs/689_update_context_from_constitutive_foundation_notes/summaries/implementation-summary-{DATE}.md`

**Verification**:
- All context files mention object language variables (`v_1, v_2, ...`)
- All context files clarify `x, y, z` reserved for metalanguage durations
- NOTE: tag removed from source file
- LaTeX compiles

## Testing & Validation

- [ ] All 5 context files contain updated variable naming information
- [ ] LaTeX source file updated and NOTE: tag removed
- [ ] `\objvar{n}` macro added and functional
- [ ] No inconsistencies in variable naming across documentation
- [ ] Grep confirms no remaining incorrect usages

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-{DATE}.md` (to be created in Phase 5)
- 5 updated context files
- 2 updated LaTeX files

## Rollback/Contingency

All changes are documentation updates with no code impact. Rollback via git:
```bash
git checkout HEAD~1 -- .claude/context/project/
git checkout HEAD~1 -- Theories/Logos/latex/
```

If individual files need restoration, use git to restore specific files. The changes are additive (clarifications) and should not break existing documentation.
