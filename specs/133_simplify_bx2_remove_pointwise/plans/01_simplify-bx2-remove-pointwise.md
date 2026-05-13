# Implementation Plan: Simplify BX2 — Remove Pointwise Conjunct

- **Task**: 133 - Simplify BX2: remove pointwise conjunct, derive from BX2G
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Dependencies**: Task 115 (established BX2G subsumes BX2 under open-guard semantics)
- **Research Inputs**: specs/133_simplify_bx2_remove_pointwise/reports/01_simplify-bx2-remove-pointwise.md
- **Artifacts**: plans/01_simplify-bx2-remove-pointwise.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Remove BX2/BX2' (`left_mono_until`/`left_mono_since`) as axiom constructors from the `Axiom` inductive type and derive them as theorems from BX2G/BX2H (`left_mono_until_G`/`left_mono_since_H`). Under the open-guard semantics `(t,s)`, the pointwise conjunct `(phi->chi)` in BX2 is redundant since `G(phi->chi)` already covers the guard interval. This achieves axiom minimality: 2 constructors removed, 2 soundness proofs removed, 22 match arms removed across 3 files, and 8 direct constructor usages rewritten across 2 files. Net deletion of approximately 100 lines across 6 files.

### Research Integration

The research report confirmed:
- All 30 call sites of `untl_left_mono_thm`/`snce_left_mono_thm` pass closed theorems, so BX2G suffices universally.
- 8 direct `Axiom.left_mono_until`/`Axiom.left_mono_since` usages all have the `G(phi->chi)` form available, making conversion to BX2G straightforward.
- 22 match arms across Soundness.lean (10), SoundnessLemmas.lean (8), and Substitution.lean (2) plus 2 validity proof theorems to remove.
- Classification functions (`isDenseCompatible`, `isDiscreteCompatible`, `frameClass`, `isBase`) all use wildcard patterns and will not break.
- No test files reference BX2/BX2' constructors.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the Phase 2 roadmap item: "Frame hierarchy + axiom cleanup" which includes removing redundant axioms (A4a via task 115, TF via task 124). Task 133 is a follow-up from task 115 and directly reduces the axiom count from 43 to 41, contributing to the roadmap goal of reducing primitives to `{S, U, box, imp, bot}`.

## Goals & Non-Goals

**Goals**:
- Remove `left_mono_until` and `left_mono_since` constructors from the `Axiom` inductive type
- Rewrite all 8 direct constructor usages to use BX2G/BX2H instead
- Remove 22 match arms and 2 validity proof theorems
- Achieve a clean `lake build` with no sorries introduced
- Update axiom count documentation (43 -> 41)

**Non-Goals**:
- Deriving BX2/BX2' as explicit theorem lemmas for backward compatibility (no downstream callers need them)
- Changing the signatures of `untl_left_mono_thm`/`snce_left_mono_thm` (only their internals change)
- Modifying any other axiom constructors

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Self-accum BX2 usage (RRelation.lean:1461) is more complex than simple rewrite | M | M | Already analyzed: proof builds conjunction + applies BX2; can switch to temporal_necessitation + BX2G. Follow the same pattern as untl_left_mono_thm rewrite. |
| Removing constructors causes unexpected compilation errors in files not identified by research | M | L | The grep analysis was exhaustive; classification functions use wildcards. Run `lake build` after Phase 1 to catch any missed references before proceeding. |
| PointInsertion.lean `untl_left_mono_deriv`/`snce_left_mono_deriv` rewrite changes derivation tree structure | L | L | These are private definitions used locally; the output type (DerivationTree) is unchanged. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

### Phase 1: Rewrite All Direct BX2/BX2' Usages to BX2G/BX2H [COMPLETED]

**Goal**: Eliminate all runtime references to `Axiom.left_mono_until` and `Axiom.left_mono_since` constructors so they can be safely removed in Phase 2.

**Tasks**:
- [ ] Rewrite `untl_left_mono_thm` (RRelation.lean:1073-1085): Remove h1 (pointwise), remove h3 (conjunction). Keep h2 (temporal necessitation -> G form). Replace `Axiom.left_mono_until` with `Axiom.left_mono_until_G`. Simplify from 7 lines to 3 lines, matching the pattern of `untl_left_mono_G` (lines 1110-1119).
- [ ] Rewrite `snce_left_mono_thm` (RRelation.lean:1091-1103): Mirror of above. Replace `Axiom.left_mono_since` with `Axiom.left_mono_since_H`. Use `past_necessitation` instead of `temporal_necessitation`.
- [ ] Rewrite `c4_hard_case_G_neg_delta` (RRelation.lean:640-670): Replace `Axiom.left_mono_until` (line 658) with `Axiom.left_mono_until_G`. The proof already has `h_G_top_gamma : G(top.imp gamma) in A`. Remove the pointwise derivation (h_top_gamma) and conjunction (h_conj). Apply BX2G directly with h_G_top_gamma.
- [ ] Rewrite `c4'_hard_case_H_neg_delta` (RRelation.lean:678-706): Mirror of above. Replace `Axiom.left_mono_since` (line 697) with `Axiom.left_mono_since_H`. Remove pointwise + conjunction steps.
- [ ] Rewrite self-accumulation BX2 usage (RRelation.lean:1458-1465): Replace `Axiom.left_mono_until` (line 1461) with `Axiom.left_mono_until_G`. The proof already computes `h_G_gw1 = temporal_necessitation(h_guard_weak1)`. Replace the conjunction premise with just the G form, and update the modus ponens chain accordingly.
- [ ] Rewrite `untl_left_mono_deriv` (PointInsertion.lean:1335-1351): Replace `Axiom.left_mono_until` (line 1343) with `Axiom.left_mono_until_G`. Remove the conjunction construction (h_conj). Apply BX2G with just `h_G` (temporal necessitation).
- [ ] Rewrite `snce_left_mono_deriv` (PointInsertion.lean:1354-1363): Replace `Axiom.left_mono_since` (line 1362) with `Axiom.left_mono_since_H`. Remove conjunction, apply BX2H with just `h_H`.
- [ ] Update docstrings on rewritten functions to reference BX2G/BX2H instead of BX2/BX2'
- [ ] Run `lake build` to verify all rewrites compile correctly

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` — Rewrite 5 functions (untl_left_mono_thm, snce_left_mono_thm, c4_hard_case_G_neg_delta, c4'_hard_case_H_neg_delta, self-accum block at line 1458)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — Rewrite 2 functions (untl_left_mono_deriv, snce_left_mono_deriv)

**Verification**:
- `lake build` passes with zero new errors
- No references to `Axiom.left_mono_until` or `Axiom.left_mono_since` remain in RRelation.lean or PointInsertion.lean
- `grep -rn "Axiom\.left_mono_until\b\|Axiom\.left_mono_since\b" --include="*.lean" Theories/` shows only Axioms.lean definition and Substitution.lean match arms

---

### Phase 2: Remove Constructors, Soundness Proofs, and Match Arms [COMPLETED]

**Goal**: Delete the `left_mono_until` and `left_mono_since` constructors from the `Axiom` inductive and remove all associated match arms and validity proofs.

**Tasks**:
- [ ] Remove `left_mono_until` constructor (Axioms.lean:128-133) and `left_mono_since` constructor (Axioms.lean:135-140) from the `Axiom` inductive type
- [ ] Remove `left_mono_until_valid` theorem (Soundness.lean:491-501) and `left_mono_since_valid` theorem (Soundness.lean:503-513)
- [ ] Remove 10 match arms in Soundness.lean: lines 921-922 (axiom_valid), 972-973 (axiom_valid_dense), 1024-1025 (axiom_valid_discrete), 1130-1131 (axiom_valid_at first), 1306-1307 (axiom_valid_at second)
- [ ] Remove 8 match arms in SoundnessLemmas.lean: lines 543-550 + 551-558 (axiom_swap_valid first), 1146-1153 + 1154-1161 (axiom_swap_valid second), 1609-1616 + 1617-1624 (axiom_swap_valid third), 1898-1905 + 1906-1913 (axiom_swap_valid fourth)
- [ ] Remove 2 match arms in Substitution.lean: lines 292-294 (left_mono_until) and 295-297 (left_mono_since)
- [ ] Run `lake build` to verify clean compilation

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` — Remove 2 constructor declarations (~14 lines)
- `Theories/Bimodal/Metalogic/Soundness.lean` — Remove 2 validity proofs (~22 lines) and 10 match arms (~10 lines)
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` — Remove 8 match arms (~64 lines)
- `Theories/Bimodal/ProofSystem/Substitution.lean` — Remove 2 match arms (~6 lines)

**Verification**:
- `lake build` passes with zero errors
- `grep -rn "left_mono_until\b\|left_mono_since\b" --include="*.lean" Theories/` shows only BX2G/BX2H references (left_mono_until_G, left_mono_since_H) plus comments
- No `left_mono_until_valid` or `left_mono_since_valid` references remain

---

### Phase 3: Documentation Update and Final Verification [COMPLETED]

**Goal**: Update axiom count documentation, verify full build, and confirm no regressions.

**Tasks**:
- [ ] Update Axioms.lean header: change axiom count from 43 to 41 (line 36) and update BX2/BX2' entry in layer listing (lines 22-23) to note they are now derived from BX2G/BX2H
- [ ] Update comments referencing "BX2" in RRelation.lean (line 942 mentions "BX2 (left_mono_until)" in a docstring; line 1441 mentions "BX2 + BX3")
- [ ] Update comments in PointInsertion.lean (line 1114 mentions "left_mono_until"; lines 1334, 1353, 1679 reference BX2/BX2')
- [ ] Run full `lake build` to confirm clean compilation
- [ ] Verify soundness and completeness proofs still compile by checking key theorems have no sorry

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` — Update header comments (axiom count, layer listing)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` — Update docstring comments
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — Update docstring comments

**Verification**:
- `lake build` passes with zero errors and zero warnings related to BX2
- `grep -rn "Axiom\.left_mono_until\b\|Axiom\.left_mono_since\b" --include="*.lean" Theories/` returns zero results
- Axiom count in header matches actual constructor count (41)

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] No new sorries introduced (verify via `grep -rn "sorry" --include="*.lean" Theories/`)
- [ ] All 30 call sites of `untl_left_mono_thm`/`snce_left_mono_thm` continue to compile unchanged
- [ ] Soundness theorems (`axiom_valid`, `axiom_valid_dense`, `axiom_valid_discrete`) compile without the removed match arms
- [ ] `axiom_swap_valid` variants in SoundnessLemmas.lean compile without the removed match arms

## Artifacts & Outputs

- Modified `Theories/Bimodal/ProofSystem/Axioms.lean` — 2 constructors removed, comments updated
- Modified `Theories/Bimodal/Metalogic/Soundness.lean` — 2 theorems + 10 match arms removed
- Modified `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` — 8 match arms removed
- Modified `Theories/Bimodal/ProofSystem/Substitution.lean` — 2 match arms removed
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` — 5 functions simplified
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — 2 functions simplified

## Rollback/Contingency

All changes are deletions or simplifications of existing code. If any phase fails:
- Phase 1 failure: Revert RRelation.lean and PointInsertion.lean via `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- Phase 2 failure: Revert all 4 files (Axioms.lean, Soundness.lean, SoundnessLemmas.lean, Substitution.lean) via git checkout
- Phase 3 failure: Comment-only changes; revert individual files as needed

Since Phase 1 rewrites are independent of Phase 2 deletions, the project remains in a valid state after Phase 1 even if Phase 2 is deferred.
