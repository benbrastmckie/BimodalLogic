# Implementation Plan: Task #415

**Task**: Fix LaTeX sentence line breaks
**Version**: 001
**Created**: 2026-01-12
**Language**: latex

## Overview

The task 406 refactor incorrectly broke sentences at comma/clause boundaries instead of keeping complete sentences on single lines. This plan addresses the identified broken sentences in Bimodal and Logos LaTeX files by joining split lines back into complete sentences.

## Phases

### Phase 1: Fix Bimodal/00-Introduction.tex

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Join lines 9-10 into a single sentence
2. Join lines 12-13 into a single sentence

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/00-Introduction.tex` - Fix 2 broken sentences

**Steps**:
1. Read current file content
2. Join line 9 ("The semantics is based on \emph{task frames},") with line 10 ("which extend Kripke frames with temporal structure.")
3. Join line 12 ("World histories are temporal slices through a task frame,") with line 13 ("representing the unfolding of a world over time.")
4. Verify no other broken sentences exist in file

**Verification**:
- Each sentence ends with a period and is on its own line
- No sentence spans multiple lines (unless exceptionally long)

---

### Phase 2: Fix Logos/00-Introduction.tex

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Join lines 11-12 into a single sentence

**Files to modify**:
- `Theories/Logos/latex/subfiles/00-Introduction.tex` - Fix 1 broken sentence

**Steps**:
1. Read current file content
2. Join line 11 ("Extending the expressive power of a language requires strategic extensions to the primitive semantic resources provided by the frame,") with line 12 ("including precisely the resources needed and nothing more.")
3. Verify no other broken sentences exist in file

**Verification**:
- Each sentence ends with a period and is on its own line
- File structure preserved

---

### Phase 3: Fix Logos/01-ConstitutiveFoundation.tex

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Join lines 11-12 into a single sentence

**Files to modify**:
- `Theories/Logos/latex/subfiles/01-ConstitutiveFoundation.tex` - Fix 1 broken sentence

**Steps**:
1. Read current file content
2. Join line 11 ("Evaluation is hyperintensional,") with line 12 ("distinguishing propositions that agree on truth-value across all possible worlds but differ in their exact verification and falsification conditions.")
3. Verify no other broken sentences exist in file

**Verification**:
- Each sentence ends with a period and is on its own line
- File structure preserved

---

### Phase 4: Scan and fix remaining files

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Scan all .tex files for additional broken sentences
2. Fix any additional occurrences found

**Files to modify**:
- Any additional .tex files with broken sentences (to be determined by scan)

**Steps**:
1. Use grep to find lines ending with comma followed by lowercase continuation
2. Review each match to determine if it's a broken sentence
3. Fix any additional broken sentences found
4. Document findings

**Verification**:
- Grep search returns no unexpected results
- All identified issues fixed

---

## Dependencies

- Tasks 405, 406 completed (they are - created the issue being fixed)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Miss some broken sentences | Low | Medium | Systematic grep scan in Phase 4 |
| Accidentally join intentional breaks | Low | Low | Review each change in context |

## Success Criteria

- [ ] Bimodal/00-Introduction.tex has no broken sentences
- [ ] Logos/00-Introduction.tex has no broken sentences
- [ ] Logos/01-ConstitutiveFoundation.tex has no broken sentences
- [ ] Grep scan confirms no additional broken sentences
- [ ] LaTeX files compile without errors

## Rollback Plan

Git revert to pre-implementation commit if issues arise. Changes are purely cosmetic (line breaks) and don't affect LaTeX compilation or output.
