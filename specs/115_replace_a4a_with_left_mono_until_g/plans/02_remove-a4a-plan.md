# Implementation Plan: Remove A4a via Xu 1988 Lemma 2.3/2.4

- **Task**: 115 - Remove A4a (separation_until/separation_since) for axiom minimality
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: Task 107 (chronicle infrastructure), Task 124 (removed temp_future, validated safety-first pattern)
- **Research Inputs**: specs/115_replace_a4a_with_left_mono_until_g/reports/01_a4a-vs-left-mono.md
- **Artifacts**: plans/02_remove-a4a-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Remove the `separation_until` (BX14) and `separation_since` (BX14') axiom constructors from the axiom set to achieve axiom minimality, reducing the constructor count from 61 to 59. The prior plan (v1) was infeasible because it assumed A4a could be derived from existing axioms, but the research report (Section 4.2) established that A4a and `left_mono_until_G` are strictly independent. This revised plan uses the Xu 1988 approach: instead of deriving A4a, we prove Xu Lemma 2.3 (guard strengthening via `left_mono_until_G`) and Xu Lemma 2.4 (splitting via DCS extension), then rewrite the 4 usage sites in PointInsertion.lean to use the Xu splitting path, eliminating the need for A4a entirely.

### Research Integration

The research report (01_a4a-vs-left-mono.md) established:
- `left_mono_until_G` is already in the axiom set (Axioms.lean line 146, added in task 107 Phase 5b)
- A4a is used at exactly 4 sites in PointInsertion.lean, all calling `separation_until_mcs` (line 1066)
- A4a CANNOT be derived from `left_mono_until_G` -- the axioms are independent (Section 4.2)
- The Xu 1988 path (Lemmas 2.3 + 2.4) completely bypasses A4a for the chronicle splitting construction
- Key existing infrastructure: `BurgessR3Maximal_extension_fails`, `dcs_neg_union_consistent`, `burgessR3Maximal_from_g_content_sub`, `enrichment_until_mcs`, `right_mono_until_mcs`

### Prior Plan Reference

Plan v1 (01_remove-a4a-plan.md) assumed A4a could be derived as a theorem from existing axioms (Phase 1). This is mathematically impossible -- A4a and `left_mono_until_G` address orthogonal needs and cannot be inter-derived (research report Section 4.2). The safety-first approach from v1 remains valid in structure: prove the replacement lemmas first, rewrite usage sites, then remove constructors. Effort estimate increased from 6h to 8h to account for the Xu lemma formalization.

### Roadmap Alignment

- ROADMAP Phase 2 explicitly lists "remove A4a (task 115)" as an axiom cleanup item
- Part of the sequence: remove TF (task 124, done) -> remove A4a (task 115) -> redefine G/H/F/P via U/S (task 116)

## Goals & Non-Goals

**Goals**:
- Formalize Xu Lemma 2.3 (guard strengthening): R(A,B,C) implies S(alpha, top) in B for all alpha in A, and U(gamma, top) in B for all gamma in C
- Formalize Xu Lemma 2.4 (splitting via DCS extension): construct splitting point D by extending R-maximal B with neg-beta, avoiding the seed consistency problem
- Rewrite the 4 PointInsertion.lean proof chains (lines 1474, 2125, 2325, 2542) to use Xu 2.4 instead of `separation_until_mcs`
- Remove `separation_until` and `separation_since` constructors from Axioms.lean
- Remove soundness proofs and all match arms referencing these constructors
- Remove substitution cases in Substitution.lean
- Achieve clean `lake build` with 59 axiom constructors

**Non-Goals**:
- Simplifying BX2 (removing pointwise conjunct): separate task with broader blast radius
- Deriving A4a from existing axioms: mathematically impossible (axioms are independent)
- Modifying CanonicalChain.lean's `left_mono_until_mcs` (uses BX2, not A4a)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Xu Lemma 2.3 formalization is harder than expected due to BurgessR3Maximal structure | M | M | The proof is a standard contradiction argument using existing infrastructure (`BurgessR3Maximal_extension_fails` + `enrichment_until_mcs` + `left_mono_until_G`). Each step maps to an existing codebase primitive. |
| Xu Lemma 2.4 DCS extension argument requires new infrastructure | M | L | `dcs_neg_union_consistent` already exists (PointInsertion.lean line 458). Lindenbaum extension to MCS is standard. The g_content/h_content subset properties inherit from B subset D. |
| Rewriting 4 usage sites changes proof structure significantly | M | M | Each site follows the same pattern (BX5 self-accumulation then separation). The replacement pattern (BX5 then Xu 2.4) is structurally similar -- the output type is the same (MCS D with neg-beta and R-relations). |
| Removing constructors causes exhaustiveness errors in unexpected files | L | L | Grep confirms exactly 5 files with match arms: Soundness.lean, SoundnessLemmas.lean, Substitution.lean, PointInsertion.lean, Axioms.lean. No other files reference these constructors. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Implement Xu Lemma 2.3 (Guard Strengthening via left_mono_until_G) [COMPLETED]

**Goal**: Formalize Xu Lemma 2.3 proving that R(A, B, C) implies S(alpha, top) in B for all alpha in A, and U(gamma, top) in B for all gamma in C. This is the key lemma enabling the Xu splitting path.

**Tasks**:
- [ ] Create Xu Lemma 2.3 theorem in PointInsertion.lean (near the BurgessR3Maximal infrastructure, after `BurgessR3Maximal_extension_fails` at line 640). Name: `xu_lemma_2_3_since_top` and `xu_lemma_2_3_until_top`
- [ ] Prove the Since direction: if R(A, B, C), then for all alpha in A, `snce(top, alpha) in B`
  - By contradiction: suppose `snce(top, alpha) not in B`
  - By `BurgessR3Maximal_extension_fails` (2.0(iii)): there exist beta in B and gamma in C with `neg untl(gamma, beta AND snce(top, alpha)) in A`
  - Derive `alpha AND untl(gamma, beta) -> untl(gamma, beta AND snce(top, alpha))` using:
    - BX13 (`enrichment_until`): `alpha AND untl(gamma, beta) -> untl(gamma AND snce(top, alpha), beta)`
    - `left_mono_until_G` (Axioms.lean line 146): for the guard strengthening step
    - BX3 (`right_mono_until`): `untl(gamma AND snce(top, alpha), beta) -> untl(gamma, beta AND snce(top, alpha))`
  - Since `alpha in A` and `untl(gamma, beta) in A` (from R-relation), conclude `untl(gamma, beta AND snce(top, alpha)) in A`, contradicting the negation
- [ ] Prove the Until direction (dual): if R(A, B, C), then for all gamma in C, `untl(top, gamma) in B`
  - Symmetric argument using dual axioms (BX13' enrichment_since, left_mono_since_H, BX3' right_mono_since)
- [ ] Verify with `lake build`

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- add Xu Lemma 2.3 theorems near BurgessR3Maximal infrastructure

**Verification**:
- `lake build` passes with no new errors
- New theorems type-check with correct signatures matching Xu 1988 Lemma 2.3 statement

---

### Phase 2: Implement Xu Lemma 2.4 and Rewrite Usage Sites [NOT STARTED]

**Goal**: Implement Xu Lemma 2.4 splitting lemma and rewrite all 4 usage sites in PointInsertion.lean to use Xu 2.4 instead of `separation_until_mcs`.

**Tasks**:
- [ ] Implement Xu Lemma 2.4 as a theorem in PointInsertion.lean. Name: `xu_lemma_2_4_splitting`. Given r(A, B, C), neg-U(gamma, beta) in A, and gamma in C, produce B', D, B'' with R(A, B', D), R(D, B'', C), and B union {neg-beta} subset D
  - Step 1: Extend B to B* with R(A, B*, C) using Zorn/`burgessR3Maximal_exists_from_seed` (2.0(ii))
  - Step 2: Prove beta not in B* (if beta in B*, then U(gamma, beta) in A by R-relation, contradicting neg-U(gamma, beta) in A)
  - Step 3: Prove B* union {neg-beta} is consistent using `dcs_neg_union_consistent` (line 458)
  - Step 4: Extend to MCS D via Lindenbaum
  - Step 5: By Xu Lemma 2.3 (Phase 1): S(alpha, top) in B* for all alpha in A, and U(gamma', top) in B* for all gamma' in C. Since B* subset D, these hold in D
  - Step 6: Establish r(A, top, D) and r(D, top, C) from the S/U-top memberships (via Burgess Lemma 2.1)
  - Step 7: Apply 2.0(i) / `burgessR3Maximal_from_g_content_sub` to get R(A, B', D) and R(D, B'', C)
- [ ] Rewrite usage site 1 (line ~1474, lemma_2_6_insert_point_future C5 splitting) to use `xu_lemma_2_4_splitting` instead of `separation_until_mcs`
- [ ] Rewrite usage site 2 (line ~2125, first C2' case) to use `xu_lemma_2_4_splitting`
- [ ] Rewrite usage site 3 (line ~2325, second C2' case) to use `xu_lemma_2_4_splitting`
- [ ] Rewrite usage site 4 (line ~2542, lemma_2_6_insert_point_past) to use `xu_lemma_2_4_splitting`
- [ ] Remove the now-unused `separation_until_mcs` helper (line 1066)
- [ ] Verify with `lake build` that all 4 sites compile without `Axiom.separation_until`
- [ ] Run `grep -rn "Axiom.separation_until\|Axiom.separation_since" Theories/` to confirm zero direct axiom constructor references outside Axioms.lean

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- add Xu 2.4 theorem, rewrite 4 usage sites, remove `separation_until_mcs`

**Verification**:
- `lake build` passes clean
- grep returns zero hits for `Axiom.separation_until` and `Axiom.separation_since` outside Axioms.lean
- All 4 former usage sites now call `xu_lemma_2_4_splitting` or equivalent

---

### Phase 3: Remove Axiom Constructors and Downstream References [NOT STARTED]

**Goal**: Remove `separation_until` and `separation_since` from the `Axiom` inductive type and all downstream match arms.

**Tasks**:
- [ ] Remove `separation_until` constructor (Axioms.lean lines 205-210) and `separation_since` constructor (lines 212-218)
- [ ] Update doc comments and constructor count in Axioms.lean header (61 -> 59)
- [ ] Remove `separation_until_valid` and `separation_since_valid` from Soundness.lean (lines 619-664)
- [ ] Remove all match arms referencing `separation_until`/`separation_since` in Soundness.lean (~6 locations across match statements at lines 983-984, 1036-1037, 1089-1090, 1196-1197, 1373-1374)
- [ ] Remove match arms in SoundnessLemmas.lean (~6 locations: lines 621-635, 1248-1261, 1739-1753, 2052-2065, and surrounding pairs)
- [ ] Remove match arms in Substitution.lean (lines 322-327)
- [ ] Run `lake build` and fix any exhaustiveness or missing-case errors

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- remove 2 constructors, update header docs
- `Theories/Bimodal/Metalogic/Soundness.lean` -- remove validity theorems and ~6 match arm pairs
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- remove ~6 match arm pairs
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- remove 2 match arms

**Verification**:
- `lake build` passes clean
- `grep -rn "separation_until\|separation_since" Theories/` returns zero hits
- Axiom type has exactly 59 constructors

---

### Phase 4: Final Verification and Cleanup [NOT STARTED]

**Goal**: Full build verification, documentation updates, and constructor count audit.

**Tasks**:
- [ ] Run `lake clean && lake build` for a clean rebuild
- [ ] Verify the axiom constructor count is 59 by inspecting `Axioms.lean`
- [ ] Update any comments in PointInsertion.lean that reference "BX14" or "separation"
- [ ] Update ROADMAP.md axiom table to remove BX14/BX14' rows and update axiom counts
- [ ] Verify no `sorry` regressions by running `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- [ ] Verify no `sorry` regressions in Soundness.lean and SoundnessLemmas.lean

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- update comments
- `specs/ROADMAP.md` -- update axiom table

**Verification**:
- Clean build from scratch (`lake clean && lake build`)
- Zero grep hits for `separation_until` or `separation_since` in `Theories/`
- No new `sorry` introduced
- ROADMAP axiom table reflects 59 constructors

## Testing & Validation

- [ ] `lake build` passes clean after each phase
- [ ] `lake clean && lake build` passes after final phase
- [ ] `grep -rn "Axiom.separation" Theories/` returns zero results
- [ ] `grep -rn "separation_until\|separation_since" Theories/` returns zero results
- [ ] No new `sorry` introduced (compare before/after)
- [ ] Axiom constructor count reduced from 61 to 59

## Artifacts & Outputs

- `specs/115_replace_a4a_with_left_mono_until_g/plans/02_remove-a4a-plan.md` (this plan)
- Modified files: Axioms.lean, Soundness.lean, SoundnessLemmas.lean, Substitution.lean, PointInsertion.lean

## Rollback/Contingency

All changes are in version control. The safety-first ordering ensures each phase has a clean rollback point:
- Phase 1 failure: revert Xu Lemma 2.3 additions; no downstream impact
- Phase 2 failure: revert Xu Lemma 2.4 and usage site rewrites; original `separation_until_mcs` still works since axiom constructors are still present
- Phase 3 failure: revert constructor removal; Xu lemmas remain as bonus infrastructure
- Phase 4 failure: cosmetic only; revert doc changes

## References

- Xu, Ming (1988). "On some U,S-tense logics." *Journal of Philosophical Logic* 17: 181-202. Lemmas 2.3 and 2.4 (paper lines 89-95).
- Burgess, John P. (1982). "Basic Tense Logic." Section 2 (Lemmas 2.4-2.8).
- Research report: specs/115_replace_a4a_with_left_mono_until_g/reports/01_a4a-vs-left-mono.md
- Prior plan (v1, superseded): specs/115_replace_a4a_with_left_mono_until_g/plans/01_remove-a4a-plan.md
