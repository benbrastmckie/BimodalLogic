# Implementation Plan: Remove Constant Witness Family from Metalogic

- **Task**: 932 - remove_constant_witness_family_metalogic
- **Status**: [NOT STARTED]
- **Effort**: 3-4 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/932_remove_constant_witness_family_metalogic/reports/research-001.md (constant witness family definitions)
  - specs/932_remove_constant_witness_family_metalogic/reports/research-002.md (CanonicalBC construction)
  - specs/932_remove_constant_witness_family_metalogic/reports/research-003.md (Option C analysis)
  - specs/932_remove_constant_witness_family_metalogic/reports/research-004.md (comprehensive cleanup scan)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Remove all constant witness family constructions and related dead code from the Metalogic module. Research-004 identified ~8,400 lines of removable code across dead files, abandoned approaches, and flawed constructions. The constant witness family approach is fundamentally flawed: constant families cannot satisfy forward_F/backward_P because temporal saturation of a single MCS is impossible (counterexample: {F(psi), neg(psi)} is consistent but violates F(psi)->psi).

### Research Integration

Key findings from research reports:
- **research-001**: Identified `constantWitnessFamily`, `constantBFMCS`, `witnessGraphBFMCS` as flawed constant family definitions
- **research-002**: Documented that ChainBundleBFMCS.lean's `bmcs_truth_at_mcs` uses non-standard semantics (MCS membership instead of recursive truth)
- **research-003**: Analyzed Option C alternatives (not implemented in this task)
- **research-004**: Comprehensive scan identified 8,400+ lines removable across 10 distinct code areas

## Goals & Non-Goals

**Goals**:
- Remove all constant witness family definitions from active Metalogic module
- Delete entire dead code files (WitnessGraph.lean, ChainBundleBFMCS.lean, backup file)
- Clean deprecated axiom and sorry-backed constructions from TemporalCoherentConstruction.lean
- Add Boneyard warning comments banning constant family approaches
- Maintain all sorry-free results (FMP, Soundness, Decidability, Algebraic)
- Preserve active completeness chain (fully_saturated_bfmcs_exists_int remains)

**Non-Goals**:
- Implementing replacement constructions (future task)
- Moving files to physical Boneyard directory (delete instead, per cleanup approach)
- Modifying the canonical frame infrastructure (CanonicalFrame.lean, CanonicalEmbedding.lean, etc.)
- Removing the active sorry at fully_saturated_bfmcs_exists_int (this is the current work location)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking downstream imports | High | Low | Verify no external imports before deletion via grep |
| Removing still-used definitions | High | Low | Research-004 verified zero external consumers for each target |
| Build failure after removal | Medium | Medium | Run `lake build` after each phase, rollback if needed |
| Losing valuable mathematical content | Low | Low | All targets are either dead code or flawed approaches |

## Sorry Characterization

### Pre-existing Sorries (In Scope)
None of the sorries in scope are being resolved. This task removes flawed code, not fixes proofs.

### Expected Resolution
- No sorries being resolved
- No new sorries introduced
- Some sorry-backed code being REMOVED (not fixed):
  - `fully_saturated_bfmcs_exists_int` - KEPT (active work location)
  - `temporal_coherent_family_exists` (generic D) - REMOVED (dead code)
  - `singleFamilyBFMCS.modal_backward` - REMOVED (deprecated, unused)

### New Sorries
None. This is a cleanup task that removes code, not adds it.

### Remaining Debt
After this implementation:
- `fully_saturated_bfmcs_exists_int` sorry remains (active work location for future tasks)
- `DovetailingChain` 2 sorries remain (forward_F, backward_P)
- All removed sorry-backed code was either deprecated or flawed

## Axiom Characterization

### Pre-existing Axioms (In Scope)
- `fully_saturated_bfmcs_exists` (deprecated polymorphic axiom in TemporalCoherentConstruction.lean)

### Expected Resolution
- The deprecated `fully_saturated_bfmcs_exists` AXIOM is being REMOVED
- This reduces the trusted kernel burden

### New Axioms
None.

### Remaining Debt
After this implementation:
- Zero axioms in the targets
- The Int-specialized `fully_saturated_bfmcs_exists_int` is a sorry-backed THEOREM, not an axiom

## Implementation Phases

### Phase 1: Delete Entire Dead Files [NOT STARTED]

- **Dependencies:** None
- **Goal:** Remove entire files that have zero external imports and are entirely dead code

**Tasks:**
- [ ] Verify WitnessGraph.lean has no external importers: `grep -r "import.*WitnessGraph" Theories/`
- [ ] Delete `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` (3,403 lines)
- [ ] Verify ChainBundleBFMCS.lean has no external importers: `grep -r "import.*ChainBundleBFMCS" Theories/`
- [ ] Delete `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` (338 lines)
- [ ] Delete `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean.backup-v004` (~4,300 lines, backup file)
- [ ] Run `lake build` to verify no breakage

**Timing:** 30 minutes

**Files to delete:**
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` - 3,403 lines, dead code, constant-family approach
- `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` - 338 lines, dead code, MCS-membership semantics
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean.backup-v004` - ~4,300 lines, backup file

**Verification:**
- `lake build` passes with no errors
- Files no longer exist
- No grep matches for deleted file imports

---

### Phase 2: Clean ModalSaturation.lean [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Remove constant witness family definitions and related lemmas from ModalSaturation.lean

**Tasks:**
- [ ] Read ModalSaturation.lean to identify exact line ranges
- [ ] Remove `constantWitnessFamily` definition (~lines 249-262)
- [ ] Remove `constantWitnessFamily_mcs_eq` lemma (~line 267-268)
- [ ] Remove `constructWitnessFamily` definition (~lines 276-280)
- [ ] Remove `constructWitnessFamily_contains` lemma (~lines 285-288)
- [ ] Add Boneyard warning comment at removal site
- [ ] Run `lake build` to verify no breakage

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Remove ~40 lines of constant family code

**Boneyard Warning to Add:**
```lean
-- BONEYARD: constantWitnessFamily removed (Task 932).
-- The constant witness family approach (mapping all times to the same MCS)
-- is fundamentally flawed: constant families cannot satisfy forward_F/backward_P
-- because temporal saturation (F(psi)->psi within a single MCS) is impossible.
-- Counterexample: {F(psi), neg(psi)} is consistent but violates F(psi)->psi.
-- See research reports 930-007, 932-001, 932-002 for detailed analysis.
-- DO NOT reintroduce constant witness families for Int-indexed constructions.
```

**Verification:**
- `lake build` passes with no errors
- `grep -n "constantWitnessFamily" Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` returns only the Boneyard comment

---

### Phase 3: Clean Construction.lean [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Remove singleFamilyBFMCS (deprecated, sorry-backed, unused) from Construction.lean

**Tasks:**
- [ ] Read Construction.lean to identify exact line ranges
- [ ] Remove `singleFamilyBFMCS` definition and all related lemmas (~lines 115-204, ~90 lines)
- [ ] Update module docstring to remove singleFamilyBFMCS from the list of provided definitions
- [ ] Add brief Boneyard comment at removal site
- [ ] Run `lake build` to verify no breakage

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Remove ~90 lines

**Note:** `constantBFMCS` was listed in research-001 but research-004 indicates it IS used by downstream code. Verify usage before removal. If used, keep it.

**Verification:**
- `lake build` passes with no errors
- `grep -n "singleFamilyBFMCS" Theories/Bimodal/Metalogic/Bundle/Construction.lean` returns only comment

---

### Phase 4: Clean TemporalCoherentConstruction.lean [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Remove deprecated axiom, dead generic-D theorem, and abandoned temporal saturation infrastructure

**Tasks:**
- [ ] Read TemporalCoherentConstruction.lean to identify exact line ranges
- [ ] Remove `TemporalForwardSaturated` predicate (~lines 315-320)
- [ ] Remove `TemporalBackwardSaturated` predicate (~lines 321-324)
- [ ] Remove `TemporallySaturated` predicate (~lines 325-328)
- [ ] Remove `TemporalEvalSaturatedBundle` structure and all methods (~lines 338-386, ~48 lines)
- [ ] Remove `fully_saturated_bfmcs_exists` AXIOM (~lines 753-758, deprecated)
- [ ] Remove `temporal_coherent_family_exists` generic D theorem (~lines 605-611, dead code with sorry)
- [ ] Remove `construct_saturated_bfmcs` polymorphic version and wrappers (~lines 844-868, deprecated)
- [ ] KEEP `fully_saturated_bfmcs_exists_int` (this is the active sorry location)
- [ ] KEEP `construct_saturated_bfmcs_int` and wrappers (used by Completeness.lean)
- [ ] KEEP `temporal_coherent_family_exists_Int` (used by DovetailingChain)
- [ ] Add Boneyard warning comment documenting removed constructions
- [ ] Run `lake build` to verify no breakage

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Remove ~150-200 lines

**Critical Preservation:**
- `TemporalCoherentFamily` structure (used by truth lemma)
- `temporal_backward_G`, `temporal_backward_H` theorems (proven, used)
- `temporal_witness_seed_consistent` theorem (proven, used)
- `fully_saturated_bfmcs_exists_int` theorem (active sorry location)
- `construct_saturated_bfmcs_int` and wrappers (used by Completeness.lean)

**Verification:**
- `lake build` passes with no errors
- `grep -n "fully_saturated_bfmcs_exists[^_]" ...` returns no matches (polymorphic axiom gone)
- `grep -n "TemporalEvalSaturatedBundle" ...` returns no matches
- `grep -n "fully_saturated_bfmcs_exists_int" ...` still returns the active sorry location

---

### Phase 5: Clean ChainFMCS.lean (Optional) [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Remove ModalWitnessSeed infrastructure if no longer needed after ChainBundleBFMCS removal

**Tasks:**
- [ ] Check if ModalWitnessSeed, psi_mem_ModalWitnessSeed, MCSBoxContent_subset_ModalWitnessSeed have remaining consumers
- [ ] If no consumers remain, remove these definitions (~100 lines)
- [ ] If consumers exist, keep definitions and skip this phase
- [ ] Run `lake build` to verify no breakage

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` - Potentially remove ~100 lines

**Verification:**
- `lake build` passes with no errors

---

### Phase 6: Final Verification and Documentation [NOT STARTED]

- **Dependencies:** Phase 4 (Phase 5 is optional)
- **Goal:** Verify all changes, document removed constructions, ensure sorry-free code unchanged

**Tasks:**
- [ ] Run full `lake build` to verify project compiles
- [ ] Verify FMP completeness still sorry-free: check `FMP/SemanticCanonicalModel.lean`
- [ ] Verify Soundness still sorry-free: check `Soundness.lean`, `SoundnessLemmas.lean`
- [ ] Verify Decidability still sorry-free: check `Decidability/` directory
- [ ] Verify active completeness chain still functions: check `Bundle/Completeness.lean`
- [ ] Count total lines removed and document
- [ ] Create git commit with summary of removals

**Timing:** 30 minutes

**Verification:**
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/FMP/` returns empty (FMP sorry-free)
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Soundness*.lean` returns empty
- Active completeness chain (`fully_saturated_bfmcs_exists_int`) still present

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors after each phase
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/FMP/` returns empty (FMP remains sorry-free)
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Soundness*.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Decidability/` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/` shows no axioms (deprecated axiom removed)
- [ ] Active sorry location `fully_saturated_bfmcs_exists_int` still present and used

### General
- [ ] All deleted files have zero external importers (verified before deletion)
- [ ] Boneyard warning comments added at each removal site
- [ ] No regressions in existing proofs

## Artifacts & Outputs

- `specs/932_remove_constant_witness_family_metalogic/plans/implementation-001.md` (this file)
- `specs/932_remove_constant_witness_family_metalogic/summaries/implementation-summary-YYYYMMDD.md` (upon completion)

## Rollback/Contingency

If any phase causes build failure:
1. Use `git checkout` to restore deleted/modified files
2. Identify the specific definition causing breakage
3. Verify grep analysis was correct (may have missed an importer)
4. If a definition is still used, keep it and update the plan

The entire task operates on code with zero external consumers (verified by research-004), so rollback should not be needed. If it is, the git history provides full recovery.
