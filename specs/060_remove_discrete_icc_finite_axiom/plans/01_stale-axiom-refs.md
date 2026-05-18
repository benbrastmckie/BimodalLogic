# Implementation Plan: Clean Up Stale Axiom References

- **Task**: 60 - remove_discrete_icc_finite_axiom
- **Status**: [NOT STARTED]
- **Effort**: 0.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/060_remove_discrete_icc_finite_axiom/reports/01_stale-axiom-refs.md
- **Artifacts**: plans/01_stale-axiom-refs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Three Lean docstrings still reference `discrete_Icc_finite_axiom`, which no longer exists. Two are in active code (FrameClass.lean, SuccExistence.lean) and one is in archived Boneyard code. This plan edits all three docstrings to accurately describe the current state of the code, then verifies the build. Total effort is under 15 minutes.

### Research Integration

Research report (01_stale-axiom-refs.md) confirmed zero `axiom` declarations remain and pinpointed the exact lines in each file. All three edits are purely in Lean doc-comments and cannot affect compilation.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Remove all stale `discrete_Icc_finite_axiom` references from Lean docstrings
- Ensure every edited docstring accurately describes the current code without historical commentary

**Non-Goals**:
- Modifying any Lean declarations or proof terms
- Editing specs/markdown files that reference the axiom (those are historical records)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Docstring edit introduces syntax error in Lean comment block | L | L | Verify with `lake build` in Phase 2 |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Edit Stale Docstrings [COMPLETED]

**Goal**: Remove or reword all three docstrings that reference the deleted axiom.

**Tasks**:
- [x] Edit FrameClass.lean: delete the "Technical Debt" paragraph (lines 142-144)
- [x] Edit SuccExistence.lean: reword the `successor_exists` docstring (lines 995-996)
- [x] Edit Boneyard Completeness.lean: reword the `discrete_soundness_proven` docstring (lines 141-147)

**Timing**: 5 minutes

**Depends on**: none

**Files to modify**:

1. `Theories/Bimodal/FrameConditions/FrameClass.lean` -- Remove the three-line "Technical Debt" paragraph from the `DiscreteTemporalFrame` docstring.

   **old_string**:
   ```
   **Technical Debt**: The completeness proof for discrete frames relies on
   `discrete_Icc_finite_axiom`, which asserts finiteness of
   closed intervals. This axiom is documented technical debt.
   ```
   **new_string**: (delete entirely -- remove these three lines plus the preceding blank line so the docstring ends cleanly after the Frame Conditions list)

2. `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` -- Reword the `successor_exists` docstring to describe current functionality.

   **old_string**:
   ```
   This is the key theorem that bypasses the covering lemma and replaces
   discrete_Icc_finite_axiom for the discrete track.
   ```
   **new_string**:
   ```
   This is the key theorem that establishes successor existence for the discrete
   track without requiring the covering lemma.
   ```

3. `Theories/Bimodal/Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean` -- Reword the `discrete_soundness_proven` docstring to describe current state.

   **old_string**:
   ```
   Discrete completeness infrastructure status.

   This theorem documents the current state of discrete completeness:
   - **Proven**: Discrete soundness via axiom_valid_discrete_fc
   - **Blocked**: Full completeness requires `discrete_Icc_finite_axiom`
   ```
   **new_string**:
   ```
   Discrete soundness for the strict-semantics legacy formulation.

   Proves that every discrete-compatible axiom is valid over discrete temporal frames
   using `axiom_valid_discrete_fc`.
   ```

**Verification**:
- Each file parses correctly (no unclosed comment blocks)

---

### Phase 2: Build Verification [IN PROGRESS]

**Goal**: Confirm the project builds cleanly after docstring edits.

**Tasks**:
- [ ] Run `lake build` and verify zero errors

**Timing**: 5-10 minutes (build time)

**Depends on**: 1

**Files to modify**: None

**Verification**:
- `lake build` exits with code 0

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] `grep -r "discrete_Icc_finite_axiom" Theories/` returns zero matches in Lean source files

## Artifacts & Outputs

- plans/01_stale-axiom-refs.md (this plan)
- Three edited Lean files (FrameClass.lean, SuccExistence.lean, Boneyard Completeness.lean)

## Rollback/Contingency

All edits are in doc-comments only. If any issue arises, revert via `git checkout` on the three affected files.
