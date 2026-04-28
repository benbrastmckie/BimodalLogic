# Implementation Plan: Task #113 -- Open Guard Refactoring for Until/Since Semantics

- **Task**: 113 - Open Guard Refactoring for Until/Since Semantics
- **Status**: [NOT STARTED]
- **Effort**: 32 hours
- **Dependencies**: None
- **Research Inputs**: specs/113_literature_review_completeness_techniques/reports/03_team-research.md
- **Artifacts**: plans/03_open-guard-refactor.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Refactor Until/Since semantics from half-closed guard `[t,s)` / `(s,t]` to open guard `(t,s)` / `(s,t)`, removing 4 unsound axioms (`until_guard`, `since_guard`, `until_elim`/BX9, `since_elim`/BX9'), archiving dead code to `Boneyard/ClosedGuardLegacy/`, and rebuilding affected infrastructure. The semantic change requires modifying 2 characters in Truth.lean (`t <= r` to `t < r`, `r <= t` to `r < t`) and propagating the consequences through ~12 files. Dead elements are archived to the Boneyard rather than patched, ensuring a high-quality long-term solution.

### Research Integration

The team research report (03_team-research.md, 4 teammates) established:
- All 4 axioms are confirmed unsound under open guard (evaluation point t is not in guard interval (t,s))
- The remaining 33 axioms are confirmed sound under open guard; no replacement axioms needed
- Xu 1988 Lemma 2.3(i) provides the replacement infrastructure for `until_guard_in_mcs` in RRelation.lean
- BX5 soundness proof requires mechanical `le_trans` to `lt_trans` adjustment
- PointInsertion.lean:673 contradiction (`bot U gamma in A -> bot in A`) must be reworked via BX10 (F extraction)
- Substitution.lean is already broken (stale axiom references from a prior refactor) and needs full rebuild
- File-by-file audit identified ~116 references across 12 files

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This plan advances the following ROADMAP items:
- **Chronicle construction (task 107)**: Phases 2-5 will be written under the correct open guard semantics from the start, eliminating the BX9 dependency in Phase 4.1
- **Irreflexive truth semantics**: ROADMAP Section "Irreflexive Truth Semantics" documents the current half-closed guard; this refactor completes the transition to open guard
- **BX Axiom System**: ROADMAP documents BX9/BX9' and guard axioms; this refactor removes them, aligning the axiom set with Xu 1988 / Burgess 1982

## Goals & Non-Goals

**Goals**:
- Change Until guard from `t <= r` to `t < r` and Since guard from `r <= t` to `r < t` in Truth.lean
- Remove 4 unsound axiom constructors from Axioms.lean
- Archive all dead code to `Boneyard/ClosedGuardLegacy/` with full docstrings
- Rebuild all downstream infrastructure (soundness, r-relation, quasimodel, filtration) to work without the removed axioms
- Achieve `lake build` clean with no increase in sorry count from baseline

**Non-Goals**:
- Adding new axioms to replace BX9/BX9' (research confirms none needed)
- Patching or bridging dead code (archive and rebuild from scratch)
- Modifying task 107 Phase 2-5 files (they are guard-independent)
- Changing G/H semantics (already irreflexive with `<`)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BX5 soundness proof harder than expected (`le_trans` to `lt_trans`) | M | L | Research confirms mechanical fix; flag for careful line-by-line verification |
| BX6 junction point gap (absorb_until) under open guard | H | L | Teammate B verified sound; MCS argument handles junction; careful proof during Phase 2 |
| PointInsertion.lean:673 contradiction rework fails | H | M | Two viable replacement paths identified (BX10 + F extraction, or BX2 monotonicity); implementation-time decision |
| RRelation.lean rebuild via Xu 2.3(i) more complex than estimated | M | M | Proof strategy documented in research report; core idea is using r-relation structure instead of guard extraction |
| Downstream sorry count increases unexpectedly | H | L | Baseline sorry count recorded in Phase 1; verified at each phase boundary |
| Substitution.lean full rebuild takes longer than 3 hours | M | M | File is only 417 lines; if it exceeds estimate, mark partial and continue |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 2 |
| 5 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Foundation -- Semantic Change, Axiom Removal, Boneyard Archive [COMPLETED]

**Goal**: Change the 2 guard characters in Truth.lean, remove 4 axiom constructors from Axioms.lean, create Boneyard archive files, and introduce sorry stubs in downstream files so that `lake build` succeeds.

**Tasks**:
- [ ] Record baseline sorry count and `lake build` status
- [ ] Truth.lean line 128: change `t ≤ r` to `t < r` (Until guard)
- [ ] Truth.lean line 130: change `r ≤ t` to `r < t` (Since guard)
- [ ] Axioms.lean: remove `until_guard` constructor (lines 267-268)
- [ ] Axioms.lean: remove `since_guard` constructor (lines 271-273)
- [ ] Axioms.lean: remove `until_elim` constructor (lines 207-208)
- [ ] Axioms.lean: remove `since_elim` constructor (lines 213-214)
- [ ] Axioms.lean: update Layer 3c comment block and BX9 note at line 202
- [ ] Create `Theories/Bimodal/Boneyard/ClosedGuardLegacy/` directory
- [ ] Create `ClosedGuardAxioms.lean`: archive `until_guard` + `since_guard` constructors with historical docstrings
- [ ] Create `ClosedGuardSoundness.lean`: archive `until_guard_valid` + `since_guard_valid` + `until_elim_valid` + `since_elim_valid` theorems from Soundness.lean
- [ ] Create `ClosedGuardRRelation.lean`: archive `until_guard_in_mcs` + `since_guard_in_mcs` lemmas from RRelation.lean
- [ ] Create `ClosedGuardTemporalDerived.lean`: archive dead BX8-dependent theorem chain from TemporalDerived.lean (`psi_imp_until`, `psi_imp_since`, `until_unfold_wrapped`, `since_unfold_wrapped`, and related)
- [ ] Add sorry stubs to all downstream match arms and call sites that reference the removed constructors
- [ ] Verify `lake build` succeeds (with increased sorry count from stubs)
- [ ] Record new sorry count; document delta from baseline

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` -- 2 character changes
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- remove 4 constructors, update comments
- `Theories/Bimodal/Boneyard/ClosedGuardLegacy/` -- create 4 archive files
- Multiple downstream files -- sorry stubs for broken match arms

**Verification**:
- `lake build` succeeds
- All 4 axiom constructors removed from Axioms.lean
- Truth.lean guard now uses strict `<` for both Until and Since
- Boneyard archive files exist with docstrings explaining the archival reason

---

### Phase 2: Soundness Rebuild [COMPLETED]

**Goal**: Rebuild all soundness proofs that referenced the removed axioms, adapting `le`-based arguments to `lt`-based arguments for the remaining 33 axioms.

**Tasks**:
- [ ] SoundnessLemmas.lean: delete 8 match arms for `until_guard`/`since_guard`/`until_elim`/`since_elim` across `axiom_swap_valid`, `axiom_negation_valid`, `axiom_box_valid`, and `axiom_combined_valid`
- [ ] SoundnessLemmas.lean: rewrite ~12 Until/Since soundness proofs that used `le_refl` or `le_trans` to use `lt_trans` or `lt_of_lt_of_le` / `lt_of_le_of_lt`
- [ ] SoundnessLemmas.lean: verify BX5 (`self_accum_until`) soundness proof compiles with `le_trans` replaced by `lt_trans`
- [ ] SoundnessLemmas.lean: verify BX6 (`absorb_until`) soundness proof handles open guard junction point
- [ ] Soundness.lean: delete match arms for `until_guard`/`since_guard`/`until_elim`/`since_elim` in `axiom_valid`, `axiom_valid_dense`, `axiom_valid_discrete`, `axiom_soundness_main`, and `axiom_valid_for_discrete`
- [ ] Soundness.lean: delete `until_guard_valid`, `since_guard_valid`, `until_elim_valid`, `since_elim_valid` theorem definitions
- [ ] Soundness.lean: update routing in the main soundness theorem match expressions
- [ ] Verify all soundness theorems are sorry-free
- [ ] `lake build` passes

**Timing**: 2 hours (research estimated 12 hours but most work is mechanical match-arm deletion; soundness proofs for remaining axioms need only `le`-to-`lt` adjustments)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- delete 16 match arms, adjust ~12 proofs
- `Theories/Bimodal/Metalogic/Soundness.lean` -- delete 4 theorem definitions, delete ~24 match arms

**Verification**:
- All soundness theorems sorry-free
- `lake build` clean
- No references to removed axioms remain in Soundness*.lean

---

### Phase 3: Chronicle Infrastructure Rebuild (RRelation + PointInsertion) [COMPLETED]

**Goal**: Rebuild the chronicle r-relation infrastructure and point insertion lemmas to work without `until_guard_in_mcs`, `since_guard_in_mcs`, and `until_elim_mcs`, using Xu 2.3(i) and BX10 as replacements.

**Tasks**:
- [ ] RRelation.lean: remove `until_guard_in_mcs` definition (line 86) and `since_guard_in_mcs` definition (line 99) -- already archived in Phase 1
- [ ] RRelation.lean: remove `until_elim_in_mcs` (line 71-78) and `since_elim_in_mcs` (line 136-143) definitions
- [ ] RRelation.lean: rebuild `burgessR3Maximal_exists_from_seed` (line ~1193) -- replace `until_guard_in_mcs` usage with direct eta extraction from r-relation structure (eta appears as the beta parameter in R(A, eta, C))
- [ ] RRelation.lean: rebuild `untl_absorb_nested` and `snce_absorb_nested` proofs using Xu 2.3(i) pattern
- [ ] RRelation.lean: rebuild `burgessR_guard_in_mcs_future` (line ~1236) and `burgessR_guard_in_mcs_past` (line ~1260) -- replace `until_guard` axiom with r-relation-based argument
- [ ] PointInsertion.lean: remove or rebuild `until_elim_mcs` (line 167) -- this used `Axiom.until_elim`
- [ ] PointInsertion.lean: rebuild call site at line 277 (`rcases until_elim_mcs ...`) -- replace with BX10 eventuality extraction or direct Until analysis
- [ ] PointInsertion.lean: rework contradiction at line 673 (`bot U gamma in A -> bot in A`) -- replace `until_guard_in_mcs` with BX10 to extract F(gamma), then derive contradiction through proof context
- [ ] PointInsertion.lean: update module docstring (lines 17, 29) to reflect open guard semantics
- [ ] ChronicleTypes.lean: update comments at lines 42, 132 referencing BX9
- [ ] ChronicleTypes.lean: rebuild `burgessR_until_elim_or` (line ~554) and `burgessR_since_elim_or` (line ~573) -- replace `Axiom.until_elim`/`Axiom.since_elim` with BX10 + or-introduction or with direct r-relation reasoning
- [ ] Verify all chronicle infrastructure sorry-free (or no worse than baseline)
- [ ] `lake build` passes

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- archive 4 lemmas, rebuild 5 proofs
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- rebuild 3 call sites, update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- update comments, rebuild 2 lemmas

**Verification**:
- No references to `until_guard`, `since_guard`, `until_elim`, `since_elim` remain in Chronicle/
- RRelation.lean sorry count same or lower than baseline
- PointInsertion.lean remains sorry-free
- `lake build` clean

---

### Phase 4: Quasimodel, Filtration, and Frame Rebuild [COMPLETED]

**Goal**: Rebuild the quasimodel Construction.lean `until_elim_mcs`/`since_elim_mcs`, the filtration DefectChain.lean `until_elim_mcs_or`, and Frame.lean `until_elim`/`since_elim` usages to work without BX9.

**Tasks**:
- [ ] Construction.lean (Quasimodel): rebuild `until_elim_mcs` (line 114) -- replace `Axiom.until_elim` with BX10 eventuality extraction or direct Until analysis of the MCS formula
- [ ] Construction.lean (Quasimodel): rebuild `since_elim_mcs` (line 166) -- mirror of above
- [ ] DefectChain.lean: rebuild `until_elim_mcs_or` usage (line 65) -- replace `Axiom.until_elim` with alternative derivation
- [ ] Frame.lean: rebuild the derivation at line 690 that uses `Axiom.until_elim` -- replace with defect-discharge or r-relation-based reasoning
- [ ] Frame.lean: rebuild the derivation at line 717 that uses `Axiom.since_elim` -- mirror
- [ ] Construction.lean: update comment at line 20 referencing `until_elim_mcs_or`
- [ ] Verify all rebuilt proofs compile sorry-free
- [ ] `lake build` passes

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` -- rebuild 2 MCS lemmas
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean` -- rebuild 1 usage
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- rebuild 2 derivations

**Verification**:
- No references to `until_elim`, `since_elim` remain in Quasimodel/ or Filtration/
- Frame.lean sorry count same or lower than baseline
- `lake build` clean

---

### Phase 5: TemporalDerived, Substitution, and Final Cleanup [COMPLETED]

**Goal**: Archive the dead BX8-dependent theorem chain in TemporalDerived.lean, rebuild Substitution.lean, update all ROADMAP documentation, and verify the full refactor achieves zero sorry increase.

**Tasks**:
- [ ] TemporalDerived.lean: identify and archive the BX8-dependent theorem chain (`psi_imp_until`, `psi_imp_since`, `until_unfold_wrapped`, `since_unfold_wrapped`, `refl_F`, `refl_P`, and supporting private defs) to `Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`
- [ ] TemporalDerived.lean: verify remaining theorems (BX10-based: `until_imp_F`, `since_imp_P`, `bot_until_equiv`, `bot_since_equiv`, `until_imp_or_via_BX10`, etc.) still compile
- [ ] TemporalDerived.lean: update module docstring and section comments to reflect open guard
- [ ] Substitution.lean (ProofSystem): remove match arms for `until_elim`/`since_elim` (lines 334-339) and add arms for any new axiom constructors if none were removed
- [ ] Substitution.lean: remove match arms for `until_guard`/`since_guard` if present
- [ ] Substitution.lean: full rebuild -- verify all match arms are exhaustive and correct
- [ ] ConservativeExtension/Substitution.lean: check for stale axiom references and update
- [ ] Update CanonicalChain.lean comment at line 42 (psi_imp_until_mcs/since_mcs removed note)
- [ ] Verify final sorry count equals baseline sorry count (no increase)
- [ ] Final `lake build` clean
- [ ] Update ROADMAP.md: remove BX9/BX9' and guard axioms from axiom table, update Truth semantics section to show open guard, note completion of open guard refactor

**Timing**: 2 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- archive dead theorems, update docstrings
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- remove/update match arms
- `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` -- check and update
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- update comment
- `specs/ROADMAP.md` -- update axiom table and truth semantics documentation

**Verification**:
- `lake build` clean with zero sorry increase from baseline
- No references to `until_guard`, `since_guard`, `until_elim`, `since_elim` remain in active codebase (excluding Boneyard)
- ROADMAP.md accurately reflects the new axiom set and open guard semantics
- All Boneyard archive files have clear docstrings explaining why the code was archived

---

## Testing & Validation

- [ ] `lake build` clean at each phase boundary
- [ ] Baseline sorry count recorded at Phase 1 start; verified equal at Phase 5 end
- [ ] `grep -rn "until_guard\|since_guard\|until_elim\|since_elim" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard` returns zero results after Phase 5
- [ ] Soundness theorems (`bx_soundness`, `bx_soundness_dense`, `bx_soundness_discrete`) remain sorry-free
- [ ] Existing sorry-free files (PointInsertion.lean, CanonicalChain.lean, etc.) remain sorry-free
- [ ] BX5 (`self_accum_until`) soundness proof specifically verified (the `le_trans` to `lt_trans` fix)
- [ ] Truth.lean Until/Since semantics use strictly `t < r` and `r < t` for guards

## Artifacts & Outputs

- `specs/113_literature_review_completeness_techniques/plans/03_open-guard-refactor.md` (this plan)
- `Theories/Bimodal/Boneyard/ClosedGuardLegacy/ClosedGuardAxioms.lean`
- `Theories/Bimodal/Boneyard/ClosedGuardLegacy/ClosedGuardSoundness.lean`
- `Theories/Bimodal/Boneyard/ClosedGuardLegacy/ClosedGuardRRelation.lean`
- `Theories/Bimodal/Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`
- Modified source files across `Theories/Bimodal/` (Truth.lean, Axioms.lean, SoundnessLemmas.lean, Soundness.lean, RRelation.lean, PointInsertion.lean, ChronicleTypes.lean, Frame.lean, Construction.lean, DefectChain.lean, TemporalDerived.lean, Substitution.lean)
- Updated `specs/ROADMAP.md`

## Rollback/Contingency

- **Git rollback**: All changes are on the `irr_until` branch. `git stash` or `git checkout` can revert any phase.
- **Phase-level rollback**: Each phase ends with `lake build` clean. If a phase fails, sorry stubs from Phase 1 allow the build to pass while the problematic phase is reworked.
- **Partial completion**: If the refactor is interrupted, the sorry stubs from Phase 1 keep the build stable. The plan can be resumed from the last completed phase.
- **Boneyard recovery**: If any archived code is needed, it remains in `Boneyard/ClosedGuardLegacy/` and can be restored by re-importing the archive files.
