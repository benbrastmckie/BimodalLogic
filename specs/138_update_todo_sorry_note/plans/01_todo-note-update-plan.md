# Implementation Plan: Update TODO.md sorry_count_note

- **Task**: 138 - Update TODO.md sorry_count_note for axiom cleanup sprint
- **Status**: [NOT STARTED]
- **Effort**: 0.17 hours (~10 minutes)
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/01_todo-note-update-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Update the `sorry_count_note` field in the `specs/TODO.md` YAML frontmatter to reflect the axiom cleanup sprint completed on 2026-05-13. The sprint reduced the axiom count from 61 to 41 (tasks 115, 124, 133) and removed 778 lines from PointInsertion.lean (task 134). The critical-path sorry and dead-code sorry counts remain accurate and should be preserved verbatim.

### Research Integration

No research report. Task requirements are fully specified in the delegation context: update the audit date, add the axiom count reduction note, and add the PointInsertion.lean line reduction note.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation needed for this documentation-only task.

## Goals & Non-Goals

**Goals**:
- Update audit date in `sorry_count_note` from 2026-05-11 to 2026-05-13
- Add note that axiom count was reduced from 61 to 41 via tasks 115, 124, and 133
- Add note that PointInsertion.lean was reduced by 778 lines via task 134
- Preserve all existing content (critical-path sorry, dead-code sorry counts, sorry-free modules)

**Non-Goals**:
- Changing `sorry_count` (still 1 critical-path sorry)
- Changing `publication_path_sorries` (still 1)
- Changing `axiom_count` or `axiom_count_note` (axiom_count is already 0 for custom axioms)
- Modifying any other part of TODO.md

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| YAML string escaping issue with double quotes | L | L | Use existing quote style; verify no unescaped quotes introduced |
| Accidentally overwriting other frontmatter fields | M | L | Make a targeted edit to only the `sorry_count_note` line |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

Phases within the same wave can execute in parallel.

### Phase 1: Update sorry_count_note in TODO.md frontmatter [NOT STARTED]

- **Goal:** Replace the `sorry_count_note` value in `specs/TODO.md` with updated text reflecting the axiom cleanup sprint results.

- **Tasks:**
  - [ ] Read `specs/TODO.md` to confirm current frontmatter content
  - [ ] Edit `sorry_count_note` to update audit date (2026-05-11 -> 2026-05-13), add axiom count reduction note (61->41, tasks 115/124/133), add PointInsertion.lean line reduction note (778 lines, task 134), and preserve all other content

- **Timing:** ~10 minutes

- **Depends on:** none

- **Files to modify:**
  - `specs/TODO.md` - Update `sorry_count_note` in YAML frontmatter (lines 1-22)

- **Target value for sorry_count_note:**
  ```
  "Audited 2026-05-13: Axiom cleanup sprint complete — axiom count reduced from 61 to 41 (tasks 115, 124, 133); PointInsertion.lean reduced by 778 lines (task 134). 1 critical-path sorry in ChronicleToCountermodel.lean (dd_countermodel_chronicle_nondense_sorry). limitDomSubtype_Icc_finite removed by task 123 collapse approach. ~17 dead-code sorries in BXCanonical pipeline (mathematically false under irreflexive semantics, bypassed by Chronicle). ~19 TemporalDerived re-derivations (low priority). Soundness, SoundnessLemmas, and Decidability are sorry-free."
  ```

- **Verification:**
  - Confirm `sorry_count_note` contains the new audit date (2026-05-13)
  - Confirm axiom count reduction note (61->41) is present
  - Confirm PointInsertion.lean note (778 lines, task 134) is present
  - Confirm critical-path sorry reference is preserved
  - Confirm dead-code sorry counts are preserved
  - Confirm YAML frontmatter remains valid (no unclosed quotes, no syntax errors)

---

## Testing & Validation

- [ ] `sorry_count_note` contains "2026-05-13" (updated audit date)
- [ ] `sorry_count_note` contains "61 to 41" (axiom count reduction)
- [ ] `sorry_count_note` contains "tasks 115, 124, 133" (responsible tasks)
- [ ] `sorry_count_note` contains "778 lines" and "task 134" (PointInsertion reduction)
- [ ] `sorry_count_note` contains "dd_countermodel_chronicle_nondense_sorry" (critical path sorry preserved)
- [ ] `sorry_count_note` contains "~17 dead-code sorries" (dead-code count preserved)
- [ ] `sorry_count_note` contains "~19 TemporalDerived" (re-derivation count preserved)
- [ ] YAML frontmatter parses without errors (no unescaped quotes, valid syntax)

## Artifacts & Outputs

- `specs/138_update_todo_sorry_note/plans/01_todo-note-update-plan.md` (this file)
- `specs/TODO.md` (modified: updated `sorry_count_note` in frontmatter)

## Rollback/Contingency

This is a single-file documentation edit. To revert: restore the original `sorry_count_note` value via `git checkout -- specs/TODO.md`. No downstream code depends on this field.
