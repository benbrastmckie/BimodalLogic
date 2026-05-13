# Implementation Plan: Remove A4a via Xu 1988 Lemma 3.2.1/3.2.2 (Transitive Frames)

- **Task**: 115 - Remove A4a (separation_until/separation_since) for axiom minimality
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: Task 107 (chronicle infrastructure), Task 124 (removed temp_future, validated safety-first pattern)
- **Research Inputs**: specs/115_replace_a4a_with_left_mono_until_g/reports/01_a4a-vs-left-mono.md, specs/115_replace_a4a_with_left_mono_until_g/reports/03_team-research.md
- **Artifacts**: plans/03_remove-a4a-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Remove the `separation_until` (BX14) and `separation_since` (BX14') axiom constructors from the axiom set to achieve axiom minimality, reducing the constructor count from 61 to 59. Plan v2 used Xu Lemma 2.3 + 2.4 (general frames), but Phase 2 was blocked because Xu 2.4 only produces `r(A, top, D)`, insufficient for the `B subset B'` output required by `lemma_2_6_splitting` callers. This v3 plan uses Xu Lemma 3.2.1 + 3.2.2 (transitive frames), which produce the full `r(A, B*, D)` relation needed for `B subset B' cap D cap B''`. The codebase operates on transitive frames (includes BX5 = self_accum_until, temp_4 = FFp->Fp), so all Section 3 lemmas apply.

### Research Integration

Team research (03_team-research.md, 4 teammates, unanimous convergence at 9/10 confidence) established:
- Xu 3.2.1 strengthens Phase 1's Xu 2.3 from `U(gamma, top) in B` to `U(gamma, beta) in B` for all beta in B, gamma in C, using only BX5 (self_accum_until) via contradiction
- Xu 3.2.2 splitting uses trivial seed `B* union {neg-beta}` (consistency via `dcs_neg_union_consistent`) instead of the rich D0 seed requiring BX14
- Output type of Xu 3.2.2 is identical to existing `lemma_2_6_splitting` -- zero CounterexampleElimination.lean changes needed
- All 4 BX14 usage sites (lines 1629, 2280, 2480, 2697) become dead code simultaneously
- All required infrastructure exists: `self_accum_until_mcs`, `BurgessR3Maximal_extension_fails`, `dcs_neg_union_consistent`, `right_mono_until_mcs`, `untl_left_mono_thm`
- Reports integrated: 01_a4a-vs-left-mono.md, 03_team-research.md, 03_teammate-a-findings.md, 03_teammate-b-findings.md, 03_teammate-c-findings.md, 03_teammate-d-findings.md

### Prior Plan References

- Plan v1 (01_remove-a4a-plan.md): Assumed A4a derivable from existing axioms. Mathematically impossible (research report Section 4.2).
- Plan v2 (02_remove-a4a-plan.md): Used Xu 2.3 + 2.4 for general frames. Phase 1 completed successfully (Xu 2.3 theorems proved). Phase 2 blocked: Xu 2.4 produces only `r(A, top, D)`, insufficient for `B subset B'` requirement. Handoff at `specs/115_.../handoffs/01_phase1-complete-phase2-blocked.md`.

### Roadmap Alignment

- ROADMAP Phase 2 explicitly lists "remove A4a (task 115)" as an axiom cleanup item
- Part of the sequence: remove TF (task 124, done) -> remove A4a (task 115) -> redefine G/H/F/P via U/S (task 116)
- Xu 3.2.1 guard-strengthening infrastructure will also serve task 116 (G/H redefinition via U/S)

## Goals & Non-Goals

**Goals**:
- Formalize Xu Lemma 3.2.1: R(A,B,C) implies U(gamma, beta) in B for ALL beta in B, gamma in C (and dual for Since). This strengthens Phase 1's Xu 2.3 from "top" to "all beta in B"
- Rewrite `lemma_2_6_splitting` internals using Xu 3.2.2 construction: trivial seed `B* union {neg-beta}`, r-relations via 3.2.1, same output type
- Eliminate all 4 BX14 usage sites and remove `separation_until_mcs` and dead code (`burgess_zeta_consistent`, `burgess_D0_seed_consistent`)
- Remove `separation_until` and `separation_since` constructors from Axioms.lean
- Remove soundness proofs, match arms, and substitution cases referencing these constructors
- Achieve clean `lake build` with 59 axiom constructors

**Non-Goals**:
- Simplifying BX2 (removing pointwise conjunct): separate task with broader blast radius
- Deriving A4a from existing axioms: mathematically impossible (axioms are independent)
- Modifying CanonicalChain.lean's `left_mono_until_mcs` (uses BX2, not A4a)
- Restructuring `lemma_2_7` or `lemma_2_8` seeds: may also benefit from 3.2.1 but should be assessed separately

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Xu 3.2.1 proof requires composing BX5+BX2G+BX3 in a multi-step derivation chain | M | M | Each step maps to an existing MCS-level helper (`self_accum_until_mcs`, `right_mono_until_mcs`, `untl_left_mono_thm`). Proof follows same contradiction pattern as existing `xu_lemma_2_3_until_top`. |
| `dc_delta_B_controlled` interface mismatch when extracting maximality witnesses for 3.2.1 | M | L | The existing `xu_lemma_2_3_*` proofs already use `BurgessR3Maximal_extension_fails` with the same interface. The 3.2.1 proof adds one extra step (BX5 application) but uses the same witness extraction. |
| `dcs_neg_union_consistent` requires formulation adjustments for `B* union {neg-beta}` seed | L | L | Already used at PointInsertion.lean line 458 for the same purpose. `B*` is a DCS (from `BurgessR3Maximal` properties), and beta not in B* is proved by contradiction. |
| `lemma_2_7`/`lemma_2_8` seeds also depend on BX14 and break after constructor removal | M | M | Grep for remaining `separation_until_mcs` references after Phase 3 rewrite. If `lemma_2_7`/`lemma_2_8` use BX14, apply same 3.2.1 treatment or defer to a follow-up task. |
| Removing constructors causes exhaustiveness errors in unexpected files | L | L | Grep confirms exactly 5 files with match arms: Soundness.lean, SoundnessLemmas.lean, Substitution.lean, PointInsertion.lean, Axioms.lean. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Xu Lemma 2.3 (Guard Strengthening with Top) [COMPLETED]

**Goal**: Formalize Xu Lemma 2.3 proving that R(A, B, C) implies S(alpha, top) in B for all alpha in A, and U(gamma, top) in B for all gamma in C. This provides the foundation for the stronger Xu 3.2.1 in Phase 2.

**Tasks**:
- [x] Create `xu_lemma_2_3_since_top` in PointInsertion.lean (near BurgessR3Maximal infrastructure)
- [x] Create `xu_lemma_2_3_until_top` in PointInsertion.lean (dual)
- [x] Verify with `lake build`

**Timing**: 3 hours (actual)

**Depends on**: none

**Files modified**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- added Xu Lemma 2.3 theorems (lines ~698-830)

**Verification**:
- `lake build` passed cleanly (1633 jobs, no new sorries)
- Both theorems type-check with correct signatures

---

### Phase 2: Xu Lemma 3.2.1 (Guard Strengthening for Transitive Frames) [NOT STARTED]

**Goal**: Strengthen Phase 1's Xu Lemma 2.3 from `U(gamma, top) in B` to `U(gamma, beta) in B` for ALL beta in B and gamma in C (and dually for Since). This is the key lemma that enables the BX14-free splitting in Phase 3.

**Tasks**:
- [ ] Create `xu_lemma_3_2_1_until` theorem in PointInsertion.lean (near the existing `xu_lemma_2_3_until_top`). Signature: given `BurgessR3Maximal A B C`, `SetMaximalConsistent A`, `SetMaximalConsistent C`, `beta in B`, `gamma in C`, prove `Formula.untl gamma beta in B`
- [ ] Prove by contradiction using BX5 (self_accum_until):
  1. Suppose `untl(gamma, beta) not in B`
  2. By `BurgessR3Maximal_extension_fails` (2.0(iii)): obtain beta' in B, gamma' in C with `neg untl(gamma', beta' AND untl(gamma, beta)) in A`
  3. Let gamma'' = gamma AND gamma', beta'' = beta AND beta'
  4. From R(A,B,C): `untl(gamma'', beta'') in A` (since beta'' in B via conjunction, gamma'' in C via conjunction)
  5. By BX5 (`self_accum_until_mcs`): `untl(gamma'', beta'' AND untl(gamma'', beta'')) in A`
  6. Derive `beta'' AND untl(gamma'', beta'') implies beta' AND untl(gamma, beta)` using:
     - `beta'' = beta AND beta'` so `beta'' implies beta'` (right projection)
     - `gamma'' = gamma AND gamma'` so `gamma'' implies gamma` (left projection)
     - By BX3 (`right_mono_until`): `untl(gamma'', beta'') implies untl(gamma, beta'')` implies `untl(gamma, beta)` by BX2G
     - Actually: `untl(gamma'', beta'') implies untl(gamma, beta)` via left_mono (BX3) then right_mono with `beta'' implies beta`
  7. By BX2G (`right_mono_until_mcs`): `untl(gamma'', beta'' AND untl(gamma'', beta'')) implies untl(gamma'', beta' AND untl(gamma, beta))`
  8. By BX3 (`left_mono`): `untl(gamma'', beta' AND untl(gamma, beta)) implies untl(gamma', beta' AND untl(gamma, beta))`
  9. So `untl(gamma', beta' AND untl(gamma, beta)) in A`, contradicting step 2
- [ ] Create `xu_lemma_3_2_1_since` theorem (dual): given `BurgessR3Maximal A B C`, `beta in B`, `alpha in A`, prove `Formula.snce alpha beta in B`. Uses BX5' (`self_accum_since_mcs`) and dual monotonicity axioms
- [ ] Verify with `lake build`

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- add Xu 3.2.1 theorems near existing Xu 2.3 infrastructure

**Verification**:
- `lake build` passes with no new errors
- New theorems type-check: `xu_lemma_3_2_1_until` produces `untl gamma beta in B` given arbitrary `beta in B` and `gamma in C`
- New theorems type-check: `xu_lemma_3_2_1_since` produces `snce alpha beta in B` given arbitrary `beta in B` and `alpha in A`

---

### Phase 3: Xu 3.2.2 Splitting and BX14 Elimination [NOT STARTED]

**Goal**: Rewrite `lemma_2_6_splitting` internals to use the Xu 3.2.2 construction (trivial seed, r-relations via 3.2.1), eliminating all BX14 usage. Remove dead code. The output type remains identical to the current implementation -- zero caller changes needed.

**Tasks**:
- [ ] Rewrite `lemma_2_6_splitting` internals with Xu 3.2.2 construction:
  1. Get B* with R(A, B*, C) via `burgessR3Maximal_extension_exists` (existing)
  2. Prove beta not in B* (if beta in B*, then untl(gamma, beta) in A from R(A,B*,C), contradicting neg-untl(gamma, beta) in A)
  3. Seed = B* union {neg-beta}. Consistency via `dcs_neg_union_consistent` (line 458) -- trivial, no BX14
  4. D = MCS extending seed via Lindenbaum
  5. By Xu 3.2.1(ii): S(alpha, beta') in B* for all beta' in B*, alpha in A. Since B* subset D: `burgessRSetSince(D, B*, A)`. By `burgessRSince_implies_burgessR`: r(A, B*, D)
  6. By Xu 3.2.1(i): U(gamma', beta') in B* for all beta' in B*, gamma' in C. Since B* subset D: `burgessRSet(D, B*, C)`. By `burgessR_implies_burgessRSince`: burgessR3(D, B*, C)
  7. Apply Zorn to get R(A, B', D) with B* subset B', and R(D, B'', C) with B* subset B''
  8. Since B subset B* subset B', D, B'': output B subset B' cap D cap B''
- [ ] Verify output type is identical: `exists B' D B'', BurgessR3Maximal A B' D AND BurgessR3Maximal D B'' C AND SetMaximalConsistent D AND beta.neg in D AND B subset D AND B subset B' AND B subset B''`
- [ ] Remove `separation_until_mcs` helper (line ~1066) -- now unused
- [ ] Remove `burgess_zeta_consistent` and its call chain -- dead code after rewrite
- [ ] Remove `burgess_D0_seed_consistent` and related helpers -- dead code after rewrite
- [ ] Run `grep -rn "separation_until_mcs\|burgess_zeta_consistent\|burgess_D0_seed" Theories/` to confirm zero remaining references
- [ ] Run `grep -rn "Axiom.separation_until\|Axiom.separation_since" Theories/` to confirm zero direct axiom constructor references outside Axioms.lean
- [ ] Verify with `lake build`

**Timing**: 3.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- rewrite `lemma_2_6_splitting` internals, remove dead code (`separation_until_mcs`, `burgess_zeta_consistent`, `burgess_D0_seed_consistent`, related helpers)

**Verification**:
- `lake build` passes clean
- grep returns zero hits for `Axiom.separation_until` and `Axiom.separation_since` outside Axioms.lean
- grep returns zero hits for `separation_until_mcs`, `burgess_zeta_consistent`, `burgess_D0_seed_consistent`
- `lemma_2_6_splitting` output type unchanged
- All CounterexampleElimination.lean callers compile without modification

---

### Phase 4: Remove Axiom Constructors and Downstream References [NOT STARTED]

**Goal**: Remove `separation_until` and `separation_since` from the `Axiom` inductive type and all downstream match arms.

**Tasks**:
- [ ] Remove `separation_until` constructor (Axioms.lean lines ~205-210) and `separation_since` constructor (lines ~212-218)
- [ ] Update doc comments and constructor count in Axioms.lean header (61 -> 59)
- [ ] Remove `separation_until_valid` and `separation_since_valid` from Soundness.lean (lines ~619-664)
- [ ] Remove all match arms referencing `separation_until`/`separation_since` in Soundness.lean (~6 locations)
- [ ] Remove match arms in SoundnessLemmas.lean (~6 locations)
- [ ] Remove match arms in Substitution.lean (lines ~322-327)
- [ ] Run `lake build` and fix any exhaustiveness or missing-case errors

**Timing**: 1.5 hours

**Depends on**: 3

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

### Phase 5: Final Verification and Cleanup [NOT STARTED]

**Goal**: Full build verification, documentation updates, and constructor count audit.

**Tasks**:
- [ ] Run `lake clean && lake build` for a clean rebuild
- [ ] Verify the axiom constructor count is 59 by inspecting `Axioms.lean`
- [ ] Update any comments in PointInsertion.lean that reference "BX14" or "separation"
- [ ] Update ROADMAP.md axiom table to remove BX14/BX14' rows and update axiom counts
- [ ] Verify no `sorry` regressions by running `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- [ ] Verify no `sorry` regressions in Soundness.lean and SoundnessLemmas.lean

**Timing**: 1 hour

**Depends on**: 4

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
- [ ] `grep -rn "separation_until_mcs\|burgess_zeta_consistent\|burgess_D0_seed" Theories/` returns zero results
- [ ] No new `sorry` introduced (compare before/after)
- [ ] Axiom constructor count reduced from 61 to 59
- [ ] `lemma_2_6_splitting` output type unchanged (no CounterexampleElimination.lean modifications)

## Artifacts & Outputs

- `specs/115_replace_a4a_with_left_mono_until_g/plans/03_remove-a4a-plan.md` (this plan)
- Modified files: Axioms.lean, Soundness.lean, SoundnessLemmas.lean, Substitution.lean, PointInsertion.lean, ROADMAP.md

## Rollback/Contingency

All changes are in version control. The safety-first ordering ensures each phase has a clean rollback point:
- Phase 1 (completed): Xu Lemma 2.3 theorems already in codebase
- Phase 2 failure: revert Xu 3.2.1 additions; no downstream impact, original code intact
- Phase 3 failure: revert `lemma_2_6_splitting` rewrite; original BX14-based implementation still works since axiom constructors are still present
- Phase 4 failure: revert constructor removal; Xu lemmas and rewritten splitting remain as bonus infrastructure
- Phase 5 failure: cosmetic only; revert doc changes

If `lemma_2_7`/`lemma_2_8` are found to also depend on BX14 during Phase 3, create a follow-up task rather than expanding scope. The 3.2.1 approach generalizes to those lemmas but they should be treated separately for risk isolation.

## References

- Xu, Ming (1988). "On some U,S-tense logics." *Journal of Philosophical Logic* 17: 181-202. **Lemmas 3.2.1 and 3.2.2** (pp. 226-227, transitive frame specialization).
- Burgess, John P. (1982). "Axioms for Tense Logic I: Since and Until." Lemma 2.6 (seed consistency using A4a).
- Research reports:
  - specs/115_replace_a4a_with_left_mono_until_g/reports/01_a4a-vs-left-mono.md
  - specs/115_replace_a4a_with_left_mono_until_g/reports/03_team-research.md (synthesis)
  - specs/115_replace_a4a_with_left_mono_until_g/reports/03_teammate-a-findings.md (proof sketch)
  - specs/115_replace_a4a_with_left_mono_until_g/reports/03_teammate-b-findings.md (literature survey)
  - specs/115_replace_a4a_with_left_mono_until_g/reports/03_teammate-c-findings.md (critic)
  - specs/115_replace_a4a_with_left_mono_until_g/reports/03_teammate-d-findings.md (strategic horizons)
- Prior plans (superseded):
  - specs/115_replace_a4a_with_left_mono_until_g/plans/01_remove-a4a-plan.md (v1, A4a derivation -- infeasible)
  - specs/115_replace_a4a_with_left_mono_until_g/plans/02_remove-a4a-plan.md (v2, Xu 2.3+2.4 -- Phase 2 blocked)
- Handoff: specs/115_replace_a4a_with_left_mono_until_g/handoffs/01_phase1-complete-phase2-blocked.md
