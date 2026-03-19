# Implementation Plan: Task #1001

- **Task**: 1001 - irrSoundness_type_errors
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: Task #1000 (blocked by dense_ordered_add_group typeclass completeness)
- **Research Inputs**: specs/1001_irrSoundness_type_errors/reports/01_irr-soundness-type-errors.md
- **Artifacts**: plans/01_fix-irr-type-errors.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Fix two classes of pre-existing build errors in `IRRSoundness.lean` that block compilation. The errors are mechanical in nature: (1) type mismatches where `String` should be `Atom` due to a prior refactoring, and (2) `omega` tactic failures on generic ordered groups where algebraic lemmas must be used instead.

### Research Integration

The research report identified 5 locations requiring String->Atom fixes and 5 locations requiring omega replacements. All required Mathlib lemmas (`add_eq_zero_iff_of_nonneg`, `add_pos_of_pos_of_nonneg`, `neg_eq_zero`, `sub_eq_zero`) are available via existing imports.

## Goals & Non-Goals

**Goals**:
- Fix all `String` vs `Atom` type mismatches in IRRSoundness.lean
- Replace all `omega` tactic usages with appropriate algebraic lemmas
- Achieve clean `lake build Bimodal.Metalogic.IRRSoundness`

**Non-Goals**:
- Refactor proof structure or simplify existing proofs
- Add new theorems or capabilities
- Modify files outside IRRSoundness.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lemma signatures differ from expected | M | L | Use lean_hover_info to verify signatures before applying |
| Cascading type errors after Atom fix | M | L | Fix all String->Atom locations atomically before testing |
| omega replacement proof structure differs | L | L | Research provides exact proof patterns to follow |

## Implementation Phases

### Phase 1: Fix String to Atom Type Mismatches [COMPLETED]

**Goal**: Replace all `String` type annotations with `Atom` where required by the Atom refactoring.

**Tasks**:
- [ ] Change `q : String` to `q : Atom` at line 55 in `truth_independent_of_valuation_change`
- [ ] Change `p : String` to `p : Atom` at line 179 in `prod_model` definition
- [ ] Change `p : String` to `p : Atom` at line 215 in `truth_prod_iff` hypothesis
- [ ] Change `p : String` to `p : Atom` at line 285 in `irr_sound_dense_at_domain` hypothesis
- [ ] Verify no additional String/Atom mismatches via diagnostic check

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/IRRSoundness.lean` - 4-5 type annotation changes

**Verification**:
- Run `lean_diagnostic_messages` on IRRSoundness.lean
- Type mismatch errors for Atom should be eliminated
- Only omega-related errors should remain

---

### Phase 2: Replace Omega with Algebraic Lemmas [COMPLETED]

**Goal**: Replace `omega` tactic calls with appropriate algebraic lemmas for generic ordered groups.

**Tasks**:
- [ ] Lines 128-130: Replace omega proof for `hx_eq` and `hy_eq` using `add_pos_of_pos_of_nonneg` and `add_eq_zero_iff_of_nonneg`
- [ ] Line 140: Replace omega with `neg_eq_zero.mp` for `-d = 0 -> d = 0`
- [ ] Line 146: Replace omega with `neg_eq_zero.mp` (similar to line 140)
- [ ] Line 162: Replace omega with `sub_eq_zero.mp` for `t - s = 0 -> s = t`
- [ ] Run full build to verify all errors resolved

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/IRRSoundness.lean` - 5 proof term modifications

**Verification**:
- `lake build Bimodal.Metalogic.IRRSoundness` succeeds
- No new sorry markers introduced
- All theorem statements unchanged

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.IRRSoundness` compiles without errors
- [ ] `lean_diagnostic_messages` shows no errors in the file
- [ ] Verify via `lean_verify` that key theorems have no sorry or axiom dependencies
- [ ] No new compilation warnings introduced

## Artifacts & Outputs

- plans/01_fix-irr-type-errors.md (this plan)
- summaries/02_fix-irr-type-errors-summary.md (upon completion)
- Modified: `Theories/Bimodal/Metalogic/IRRSoundness.lean`

## Rollback/Contingency

If fixes introduce unexpected issues:
1. Revert IRRSoundness.lean via `git checkout HEAD -- Theories/Bimodal/Metalogic/IRRSoundness.lean`
2. Re-examine error messages and adjust lemma applications
3. Consider consulting Mathlib documentation for alternative lemma formulations
