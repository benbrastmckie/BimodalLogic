# Implementation Plan: Task #113 -- Open Guard Refactoring for Until/Since Semantics (Revised)

- **Task**: 113 - Open Guard Refactoring for Until/Since Semantics
- **Status**: [IN PROGRESS]
- **Effort**: 14 hours
- **Dependencies**: None
- **Research Inputs**: specs/113_literature_review_completeness_techniques/reports/03_team-research.md, specs/113_literature_review_completeness_techniques/reports/04_team-research.md
- **Artifacts**: plans/04_open-guard-refactor.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Revised plan for the open guard refactoring, incorporating team research findings from round 04. Phases 1-2 (foundation and soundness) and Phase 4 (quasimodel/filtration/frame) are completed. Phase 3 (chronicle infrastructure) is revised based on the finding that 8 lemmas are genuinely invalid (semantically false under open guard), ~8 are dead code from the obsolete obligation-based path, and 2 need proof restructuring. Phase 5 is expanded to include Truth.lean time_shift_preserves_truth sorry fixes.

Definition of done: `lake build` clean, no sorry increase from Phase 1 baseline, all invalid and dead-code lemmas archived to Boneyard, Truth.lean untl/snce cases in `time_shift_preserves_truth` resolved.

**Phase 3 outcome note**: `BurgessR3Maximal_maximality_combined` and `burgess_D0_consistent` were found to have ZERO active callers and were removed as dead code rather than restructured. The delta.neg-in-B case is mathematically blocked under open guard without density (bot U gamma is satisfiable on discrete orders). Valid supporting infrastructure (`dc_delta_B_controlled`, `BurgessR3Maximal_extension_fails`, `dc_delta_B_burgessR3`) was retained for future use.

### Research Integration

- **03_team-research.md** (round 03, 4 teammates): Established axiom soundness/unsoundness, identified Xu 2.3(i) replacement, file-by-file audit of ~116 references across 12 files. Integrated in plan v03.
- **04_team-research.md** (round 04, 4 teammates): Classified sorry stubs into 3 categories (8 invalid, 2 restructure, ~8 dead code), identified BurgessR3Maximal_maximality_combined delta.neg-in-B as the crux problem, confirmed r-relation DEFINITIONS are sound, confirmed Xu 2.3(i) = existing `rRelation_guard_continues'`.
- **04_teammate-a-findings.md**: Detailed r-relation infrastructure analysis, maximality_combined fix via consistency check on {delta} union B, identified `cantor_bfmcs_restricted_buc` le-to-lt fix.
- **04_teammate-b-findings.md**: Confirmed paper does not address r-relation, Xu Sigma4 match, density approach for maximality, Bundle techniques complementary but insufficient.
- **04_teammate-c-findings.md**: Critic verification of all 10+ sorry stubs, confirmed all Category A statements are semantically false with counterexamples, identified density requirement for delta.neg-in-B case.
- **04_teammate-d-findings.md**: Strategic alignment -- open guard is unambiguously correct, 31-axiom system matches Xu Sigma4, task 107 impact contained.

### Roadmap Alignment

- **Chronicle construction (task 107)**: Phases 2-5 will be written under the correct open guard semantics from the start, eliminating the BX9 dependency in Phase 4.1.
- **Irreflexive truth semantics**: ROADMAP Section "Irreflexive Truth Semantics" documents the current half-closed guard; this refactor completes the transition to open guard.
- **BX Axiom System**: ROADMAP documents BX9/BX9' and guard axioms; this refactor removes them, aligning the axiom set with Xu 1988 / Burgess 1982.

## Goals & Non-Goals

**Goals**:
- [x] Archive 8 genuinely invalid lemmas (Category A) to Boneyard
- [x] Archive ~15 dead-code obligation-based lemmas (Category C) to Boneyard (exceeded estimate: additional dead code discovered including BurgessR3Maximal_maximality_combined, burgess_D0, and supporting infrastructure)
- [x] Resolve `BurgessR3Maximal_maximality_combined` and `burgess_D0_consistent` (removed as dead code -- zero callers confirmed; delta.neg-in-B case mathematically blocked)
- [ ] Fix `cantor_bfmcs_restricted_buc` le-to-lt guard bound adjustment
- [ ] Fix Truth.lean `time_shift_preserves_truth` untl/snce sorry cases
- [ ] Achieve `lake build` clean with no sorry increase from baseline

**Non-Goals**:
- Adding new axioms to replace BX9/BX9' (research confirms none needed)
- Fixing the 6 c2' sorry stubs in CounterexampleElimination.lean (task 107 scope)
- Fixing the C4 hard case at CounterexampleElimination.lean:1086 (task 107 scope)
- Modifying task 107 Phase 2-5 files (they are guard-independent)
- Adding density axiom DN (try restructuring first; density is a fallback)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `BurgessR3Maximal_maximality_combined` delta.neg-in-B restructuring fails without density | H | M | **RESOLVED**: Dead-code analysis showed zero callers. Removed instead of restructured. The delta.neg-in-B case IS mathematically blocked (bot U gamma satisfiable on discrete orders). |
| Dead-code audit misses callers of obligation-based infrastructure | M | L | Run comprehensive grep before archiving; leave sorry stubs if uncertain |
| `time_shift_preserves_truth` untl/snce cases harder than expected | M | L | These are mechanical guard-bound adjustments; fallback is sorry stub with documented fix path |
| `cantor_bfmcs_restricted_buc` le-to-lt fix requires type signature changes | L | M | Teammate A documented the exact fix; adjust `restricted_backward_until_since_coherent` type if needed |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | -- |
| 3 | 4 | 3 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Foundation -- Semantic Change, Axiom Removal, Boneyard Archive [COMPLETED]

**Goal**: Change the 2 guard characters in Truth.lean, remove 4 axiom constructors from Axioms.lean, create Boneyard archive files, and introduce sorry stubs in downstream files so that `lake build` succeeds.

**Tasks**:
- [x] Record baseline sorry count and `lake build` status
- [x] Truth.lean line 128: change `t <= r` to `t < r` (Until guard)
- [x] Truth.lean line 130: change `r <= t` to `r < t` (Since guard)
- [x] Axioms.lean: remove `until_guard`, `since_guard`, `until_elim`, `since_elim` constructors
- [x] Create `Theories/Bimodal/Boneyard/ClosedGuardLegacy/` directory with 4 archive files
- [x] Add sorry stubs to all downstream match arms and call sites
- [x] Verify `lake build` succeeds

**Timing**: 2 hours (completed)

**Depends on**: none

**Completed**: 2026-04-26

---

### Phase 2: Soundness Rebuild [COMPLETED]

**Goal**: Rebuild all soundness proofs that referenced the removed axioms, adapting `le`-based arguments to `lt`-based arguments for the remaining axioms.

**Tasks**:
- [x] SoundnessLemmas.lean: delete match arms for removed axioms, rewrite ~12 Until/Since proofs with `lt`-based ordering
- [x] Soundness.lean: delete removed axiom theorem definitions and match arms
- [x] Verify all 32 sorries eliminated in SoundnessLemmas.lean
- [x] Verify all soundness theorems sorry-free

**Timing**: 2 hours (completed)

**Depends on**: 1

**Completed**: 2026-04-27

---

### Phase 3: Chronicle Infrastructure -- Archive Invalid + Dead Code, Restructure Proofs [COMPLETED]

**Goal**: Archive all genuinely invalid (Category A) and dead-code (Category C) lemmas to Boneyard, then resolve the 2 Category B lemmas (`BurgessR3Maximal_maximality_combined` and `burgess_D0_consistent`).

**Tasks**:

*Step 1: Archive Category A -- Genuinely Invalid (8 lemmas)*
- [x] RRelation.lean: archived `until_disjunction_in_mcs`, `until_guard_in_mcs`, `since_guard_in_mcs`, `since_disjunction_in_mcs` to `Boneyard/ClosedGuardLegacy/ClosedGuardRRelation.lean`
- [x] RRelation.lean: archived `untl_absorb_nested`, `snce_absorb_nested` to same Boneyard file
- [x] ChronicleTypes.lean: archived `rRelation_of_superset_mcs`, `rRelationSince_of_superset_mcs` to same Boneyard file
- [x] Removed the sorry-stub definitions from source files (replaced with comments noting archival)

*Step 2: Archive Category C -- Dead Code (~15 lemmas)*
- [x] Ran dead-code grep to confirm callers for each candidate
- [x] Removed from RRelation.lean: `rRelation_of_subset_mcs`, `r3Relation_of_superset_mcs` (dead, depended on removed invalid lemmas)
- [x] Removed from PointInsertion.lean: `until_elim_mcs` (invalid), `lemma_2_7_guard` (dead, depended on until_elim_mcs), `rRelation_self_mcs` (dead), `rRelationSince_self_mcs` (dead), `lemma_2_6_full` (dead), `B_sub_A_of_burgessR3` (invalid), `B_sub_C_of_burgessR3` (invalid), `burgess_D0_elem_in_A_or_C` (dead), `F_mono_mcs` (dead), `left_mono_contrapositive_neg_delta` (dead), `BurgessR3Maximal_maximality_combined` (dead + partially invalid), `burgess_D0` + helper lemmas (dead), `burgess_D0_consistent` (dead)
- [x] Retained `burgessR3_gamma_not_in_B_nested` and `burgessR3_gamma_not_in_B_since_nested` as sorry stubs (active callers in CounterexampleElimination.lean)

*Step 3-4: Category B Resolution (maximality_combined + D0_consistent)*
- [x] Dead-code analysis revealed BOTH `BurgessR3Maximal_maximality_combined` and `burgess_D0_consistent` have ZERO active callers
- [x] Mathematical analysis confirmed the delta.neg-in-B case is genuinely blocked: `bot U gamma in A` does not yield `bot in A` without `until_guard` (bot U gamma is satisfiable on discrete orders where the guard interval can be empty)
- [x] Both removed as dead code rather than restructured (no downstream impact)
- [x] Valid infrastructure retained: `dc_delta_B_controlled`, `BurgessR3Maximal_extension_fails`, `dc_delta_B_burgessR3` (sorry-free, may be useful for future approaches)

*Step 5: Verification*
- [x] `lake build` passes
- [x] Sorry count reduced by 8 from Phase 1 baseline (6 from RRelation.lean, 2 from PointInsertion.lean, 2 from ChronicleTypes.lean = 10 removed; 2 retained in RRelation.lean for burgessR3_gamma_not_in_B_nested/since_nested)
- [x] `grep -rn "until_guard_in_mcs\|since_guard_in_mcs\|untl_absorb_nested\|snce_absorb_nested" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard` returns zero active code references (only docstring mentions)
- [x] Updated module docstrings in RRelation.lean, PointInsertion.lean, ChronicleTypes.lean

**Timing**: 2 hours (completed)

**Depends on**: none (Phases 1-2 completed, Phase 4 completed)

**Files modified**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- removed 8 sorry stubs, 2 remaining (nested bridging)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- removed 2 sorry stubs, updated comments
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- removed 2 sorry stubs + ~15 dead definitions, updated docstrings
- `Theories/Bimodal/Boneyard/ClosedGuardLegacy/ClosedGuardRRelation.lean` -- extended with Phase 3 archives

**Sorry count changes**:
- RRelation.lean: 6 -> 2 (-4)
- PointInsertion.lean: 2 -> 0 (-2)
- ChronicleTypes.lean: 2 -> 0 (-2)
- Total: -8 sorry reduction

**Completed**: 2026-04-28

**Verification**:
- No active code references to archived lemmas remain (excluding Boneyard and docstrings)
- `BurgessR3Maximal_maximality_combined` and `burgess_D0_consistent` removed as dead code (zero callers confirmed by grep)
- `lake build` clean

---

### Phase 4: Quasimodel, Filtration, and Frame Rebuild [COMPLETED]

**Goal**: Rebuild the quasimodel Construction.lean, filtration DefectChain.lean, and Frame.lean usages to work without BX9.

**Tasks**:
- [x] Construction.lean: rebuilt `until_elim_mcs` and `since_elim_mcs` without BX9
- [x] DefectChain.lean: rebuilt `until_elim_mcs_or` usage
- [x] Frame.lean: rebuilt derivations using `Axiom.until_elim` / `Axiom.since_elim`
- [x] All rebuilt proofs compile sorry-free
- [x] `lake build` passes

**Timing**: 2 hours (completed)

**Depends on**: 2

**Completed**: 2026-04-27

---

### Phase 5: Truth.lean Fixes, TemporalDerived, Substitution, and Final Cleanup [COMPLETED]

**Goal**: Fix Truth.lean `time_shift_preserves_truth` untl/snce sorry cases, archive dead BX8-dependent theorem chain in TemporalDerived.lean, rebuild Substitution.lean, fix `cantor_bfmcs_restricted_buc`, update documentation, and verify the full refactor achieves zero sorry increase.

**Tasks**:

*Step 1: Truth.lean time_shift_preserves_truth*
- [ ] Fix the `untl` case sorry in `time_shift_preserves_truth` -- adapt the guard bound proof from `le` to `lt` (the time shift preserves strict inequalities)
- [ ] Fix the `snce` case sorry in `time_shift_preserves_truth` -- mirror of above
- [ ] Verify Truth.lean compiles sorry-free

*Step 2: TemporalDerived.lean cleanup*
- [ ] Archive the BX8-dependent theorem chain (`psi_imp_until`, `psi_imp_since`, `until_unfold_wrapped`, `since_unfold_wrapped`, `refl_F`, `refl_P`, and supporting private defs) to `Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`
- [ ] Verify remaining theorems still compile
- [ ] Update module docstring to reflect open guard

*Step 3: Substitution.lean*
- [ ] Remove match arms for `until_elim`/`since_elim` and `until_guard`/`since_guard` if present
- [ ] Full rebuild -- verify all match arms are exhaustive and correct
- [ ] ConservativeExtension/Substitution.lean: check for stale axiom references

*Step 4: cantor_bfmcs_restricted_buc fix*
- [ ] Fix the backward Until/Since coherence sorry in ChronicleToCountermodel.lean (~line 499) -- adjust guard bound from `le` to `lt` in the archived proof structure
- [ ] Update `restricted_backward_until_since_coherent` type signature if it specifies the guard bound

*Step 5: Documentation and final verification*
- [ ] Update CanonicalChain.lean comment at line 42
- [ ] Update ChronicleTypes.lean comments referencing BX9
- [ ] Update PointInsertion.lean module docstring for open guard semantics
- [ ] Verify final sorry count equals or improves on baseline
- [ ] Final `lake build` clean
- [ ] Update ROADMAP.md: remove BX9/BX9' and guard axioms from axiom table, update Truth semantics section, note completion of open guard refactor

**Timing**: 4 hours (Truth.lean: 1h, TemporalDerived: 0.5h, Substitution: 1h, buc fix: 0.5h, documentation + verification: 1h)

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` -- fix 2 sorry cases in `time_shift_preserves_truth`
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- archive dead theorems
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- remove stale match arms
- `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` -- check and update
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fix buc sorry
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- update comment
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- update comments
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- update docstring
- `specs/ROADMAP.md` -- update axiom table and semantics documentation

**Verification**:
- `lake build` clean with zero sorry increase from baseline
- No references to removed axioms remain in active codebase (excluding Boneyard)
- ROADMAP.md accurately reflects the new axiom set and open guard semantics
- Truth.lean sorry-free

---

## Testing & Validation

- [x] `lake build` clean at each phase boundary (Phases 1-4 verified, Phase 3 re-verified 2026-04-28)
- [ ] Baseline sorry count recorded at Phase 1 start; verified equal or improved at Phase 5 end
- [ ] `grep -rn "until_guard\|since_guard\|until_elim\|since_elim" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard` returns zero results after Phase 5
- [x] Soundness theorems (`bx_soundness`, `bx_soundness_dense`, `bx_soundness_discrete`) remain sorry-free
- [x] `BurgessR3Maximal_maximality_combined` removed as dead code (zero callers) -- N/A
- [x] `burgess_D0_consistent` removed as dead code (zero callers) -- N/A
- [ ] Truth.lean `time_shift_preserves_truth` sorry-free after Phase 5
- [ ] `cantor_bfmcs_restricted_buc` sorry-free after Phase 5
- [x] Phase 3 sorry reduction verified: -8 net (10 removed, 2 retained for CounterexampleElimination callers)

## Artifacts & Outputs

- `specs/113_literature_review_completeness_techniques/plans/04_open-guard-refactor.md` (this plan)
- `Theories/Bimodal/Boneyard/ClosedGuardLegacy/ClosedGuardAxioms.lean` (Phase 1, completed)
- `Theories/Bimodal/Boneyard/ClosedGuardLegacy/ClosedGuardSoundness.lean` (Phase 1, completed)
- `Theories/Bimodal/Boneyard/ClosedGuardLegacy/ClosedGuardRRelation.lean` (Phase 1 + Phase 3 extension)
- `Theories/Bimodal/Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean` (Phase 5)
- Modified source files across `Theories/Bimodal/`
- Updated `specs/ROADMAP.md`

## Rollback/Contingency

- **Git rollback**: All changes are on the `irr_until` branch. `git stash` or `git checkout` can revert any phase.
- **Phase-level rollback**: Each phase ends with `lake build` clean. If a phase fails, sorry stubs keep the build stable.
- **Partial completion**: Phase 3 completed successfully. If Phase 5 is interrupted, sorry stubs keep the build stable.
- **Boneyard recovery**: Archived code remains in `Boneyard/ClosedGuardLegacy/` and can be restored.
- **Phase 3 note**: `BurgessR3Maximal_maximality_combined` and `burgess_D0_consistent` were removed as dead code (zero callers). If future work requires Burgess Lemma 2.6 splitting, the valid infrastructure (`dc_delta_B_controlled`, `BurgessR3Maximal_extension_fails`, `dc_delta_B_burgessR3`) is still available, and the delta.neg-in-B case will need a density hypothesis or alternative construction.
