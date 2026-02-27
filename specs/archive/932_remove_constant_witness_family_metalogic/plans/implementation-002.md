# Implementation Plan: Remove Constant Witness Family from Metalogic (v2)

- **Task**: 932 - remove_constant_witness_family_metalogic
- **Status**: [COMPLETED]
- **Effort**: 3-4 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/932_remove_constant_witness_family_metalogic/reports/research-001.md (constant witness family definitions)
  - specs/932_remove_constant_witness_family_metalogic/reports/research-002.md (CanonicalBC construction)
  - specs/932_remove_constant_witness_family_metalogic/reports/research-003.md (Option C analysis)
  - specs/932_remove_constant_witness_family_metalogic/reports/research-004.md (comprehensive cleanup scan)
- **Artifacts**: plans/implementation-002.md (this file)
- **Previous Version**: plans/implementation-001.md (superseded)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Notes (v2)

**Changes from v1:**
- Files like WitnessGraph.lean are now ARCHIVED to Boneyard, not deleted
- All removed content goes to `Boneyard/Metalogic_v7/` with warning headers
- Only RecursiveSeed.lean.backup-v004 (a backup file, not original work) is deleted outright
- Every archived file gets a warning header explaining why the approach is flawed

**Rationale:** Preserve mathematical content for reference while clearly marking it as abandoned/flawed approaches.

## Overview

Remove all constant witness family constructions and related dead code from the Metalogic module by ARCHIVING to Boneyard. Research-004 identified ~8,400 lines of removable code across dead files, abandoned approaches, and flawed constructions. The constant witness family approach is fundamentally flawed: constant families cannot satisfy forward_F/backward_P because temporal saturation of a single MCS is impossible (counterexample: {F(psi), neg(psi)} is consistent but violates F(psi)->psi).

### Research Integration

Key findings from research reports:
- **research-001**: Identified `constantWitnessFamily`, `constantBFMCS`, `witnessGraphBFMCS` as flawed constant family definitions
- **research-002**: Documented that ChainBundleBFMCS.lean's `bmcs_truth_at_mcs` uses non-standard semantics (MCS membership instead of recursive truth)
- **research-003**: Analyzed Option C alternatives (fundamental tension irresolvable with constant families)
- **research-004**: Comprehensive scan identified 8,400+ lines removable across 10 distinct code areas

## Goals & Non-Goals

**Goals**:
- ARCHIVE all constant witness family definitions to Boneyard with warning headers
- ARCHIVE entire dead code files (WitnessGraph.lean, ChainBundleBFMCS.lean) to Boneyard
- DELETE only backup files (RecursiveSeed.lean.backup-v004)
- Add comprehensive warning comments banning constant family approaches
- Maintain all sorry-free results (FMP, Soundness, Decidability, Algebraic)
- Preserve active completeness chain (fully_saturated_bfmcs_exists_int remains)

**Non-Goals**:
- Implementing replacement constructions (future task)
- Losing mathematical content that might inform future work
- Modifying the canonical frame infrastructure (CanonicalFrame.lean, CanonicalEmbedding.lean, etc.)
- Removing the active sorry at fully_saturated_bfmcs_exists_int (this is the current work location)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking downstream imports | High | Low | Verify no external imports before archival via grep |
| Losing valuable mathematical content | Low | Very Low | Archive to Boneyard instead of delete |
| Build failure after removal | Medium | Medium | Run `lake build` after each phase, rollback if needed |
| Boneyard warnings not clear enough | Low | Low | Use detailed, explicit warning headers |

## Sorry Characterization

### Pre-existing Sorries (In Scope)
None of the sorries in scope are being resolved. This task archives flawed code, not fixes proofs.

### Expected Resolution
- No sorries being resolved
- No new sorries introduced
- Some sorry-backed code being ARCHIVED (not fixed):
  - `fully_saturated_bfmcs_exists_int` - KEPT in active codebase (active work location)
  - `temporal_coherent_family_exists` (generic D) - ARCHIVED (dead code)
  - `singleFamilyBFMCS.modal_backward` - ARCHIVED (deprecated, unused)

### Remaining Debt
After this implementation:
- `fully_saturated_bfmcs_exists_int` sorry remains (active work location for future tasks)
- `DovetailingChain` 2 sorries remain (forward_F, backward_P)
- All archived sorry-backed code was either deprecated or flawed

## Axiom Characterization

### Pre-existing Axioms (In Scope)
- `fully_saturated_bfmcs_exists` (deprecated polymorphic axiom in TemporalCoherentConstruction.lean)

### Expected Resolution
- The deprecated `fully_saturated_bfmcs_exists` AXIOM is being ARCHIVED (reduces trusted kernel burden)

### Remaining Debt
- Zero axioms in the active codebase for these constructions
- The Int-specialized `fully_saturated_bfmcs_exists_int` is a sorry-backed THEOREM, not an axiom

## Implementation Phases

### Phase 1: Create Boneyard Directory and Archive Entire Files [COMPLETED]

- **Dependencies:** None
- **Goal:** Create versioned Boneyard directory and move entire dead files with warning headers

**Tasks:**
- [ ] Create directory `Theories/Bimodal/Boneyard/Metalogic_v7/Bundle/`
- [ ] Verify WitnessGraph.lean has no external importers: `grep -r "import.*WitnessGraph" Theories/`
- [ ] Move `WitnessGraph.lean` to Boneyard with warning header prepended
- [ ] Verify ChainBundleBFMCS.lean has no external importers: `grep -r "import.*ChainBundleBFMCS" Theories/`
- [ ] Move `ChainBundleBFMCS.lean` to Boneyard with warning header prepended
- [ ] DELETE `RecursiveSeed.lean.backup-v004` (backup file, not original work - no archive needed)
- [ ] Run `lake build` to verify no breakage

**Timing:** 45 minutes

**Warning Header Template for Archived Files:**
```lean
/-!
# BONEYARD: Archived from active Metalogic module (Task 932, 2026-02-25)

## WHY THIS IS HERE
This file was moved to Boneyard because it implements a fundamentally flawed approach.

## THE FLAWED APPROACH
The constant witness family pattern (mapping all time points to the SAME MCS) cannot satisfy
temporal coherence requirements (forward_F, backward_P). Counterexample: {F(psi), neg(psi)}
is consistent but violates F(psi)->psi required for temporal saturation.

## DO NOT RESURRECT
- Do NOT copy code from this file back into active Metalogic
- Do NOT use constant witness families for Int-indexed BFMCS constructions
- Do NOT use MCS-membership box semantics (bmcs_truth_at_mcs pattern)

## WHAT WENT WRONG
[File-specific explanation]

## SEE ALSO
- specs/930_verify_mcs_membership_box_semantics_correctness/reports/research-007.md
- specs/932_remove_constant_witness_family_metalogic/reports/ (research-001 through research-004)
-/

-- Original file contents below (compile errors expected due to broken imports)
```

**Files to archive:**
- `WitnessGraph.lean` (3,403 lines) -> `Boneyard/Metalogic_v7/Bundle/WitnessGraph.lean`
- `ChainBundleBFMCS.lean` (338 lines) -> `Boneyard/Metalogic_v7/Bundle/ChainBundleBFMCS.lean`

**Files to delete:**
- `RecursiveSeed.lean.backup-v004` (~4,300 lines) - backup file only, not archived

**Verification:**
- `lake build` passes with no errors
- Archived files exist in Boneyard with warning headers
- No grep matches for deleted file imports in active Theories/

---

### Phase 2: Archive Constant Witness Family Code from ModalSaturation.lean [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Extract constant witness family definitions to Boneyard, leave warning comment in place

**Tasks:**
- [ ] Read ModalSaturation.lean to identify exact line ranges for removal
- [ ] Create `Boneyard/Metalogic_v7/Bundle/ConstantWitnessFamily_ModalSaturation.lean`
- [ ] Copy `constantWitnessFamily`, `constantWitnessFamily_mcs_eq`, `constructWitnessFamily`, `constructWitnessFamily_contains` (~40 lines) to Boneyard file with warning header
- [ ] Remove these definitions from active ModalSaturation.lean
- [ ] Add in-place Boneyard warning comment at removal site
- [ ] Run `lake build` to verify no breakage

**Timing:** 30 minutes

**In-Place Warning Comment:**
```lean
/-!
## REMOVED: Constant Witness Family Definitions (Task 932)

The following definitions were archived to Boneyard/Metalogic_v7/:
- constantWitnessFamily
- constantWitnessFamily_mcs_eq
- constructWitnessFamily
- constructWitnessFamily_contains

WHY: The constant witness family approach (mapping all times to the same MCS)
is fundamentally flawed. Constant families cannot satisfy forward_F/backward_P
because temporal saturation (F(psi)->psi within a single MCS) is impossible.
Counterexample: {F(psi), neg(psi)} is consistent but violates F(psi)->psi.

DO NOT reintroduce constant witness families for modal saturation.
See specs/932_*/reports/ for detailed analysis.
-/
```

**Verification:**
- `lake build` passes with no errors
- Archived code exists in Boneyard
- `grep -n "constantWitnessFamily" ModalSaturation.lean` returns only the warning comment

---

### Phase 3: Archive singleFamilyBFMCS from Construction.lean [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Archive singleFamilyBFMCS (deprecated, sorry-backed, unused) to Boneyard

**Tasks:**
- [ ] Read Construction.lean to identify exact line ranges
- [ ] Create `Boneyard/Metalogic_v7/Bundle/SingleFamilyBFMCS.lean`
- [ ] Copy `singleFamilyBFMCS` and all related lemmas (~90 lines) to Boneyard with warning header
- [ ] Remove from active Construction.lean
- [ ] Update module docstring to remove singleFamilyBFMCS from the list
- [ ] Add in-place Boneyard warning comment at removal site
- [ ] Run `lake build` to verify no breakage

**Timing:** 30 minutes

**Note:** `constantBFMCS` - verify usage before removal. If used by active code, KEEP it.

**Verification:**
- `lake build` passes with no errors
- Archived code exists in Boneyard
- `grep -n "singleFamilyBFMCS" Construction.lean` returns only the warning comment

---

### Phase 4: Archive Deprecated Code from TemporalCoherentConstruction.lean [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Archive deprecated axiom, dead generic-D theorem, and abandoned temporal saturation infrastructure

**Tasks:**
- [ ] Read TemporalCoherentConstruction.lean to identify exact line ranges
- [ ] Create `Boneyard/Metalogic_v7/Bundle/TemporalSaturationBundle.lean`
- [ ] Archive the following to Boneyard file:
  - `TemporalForwardSaturated` predicate
  - `TemporalBackwardSaturated` predicate
  - `TemporallySaturated` predicate
  - `TemporalEvalSaturatedBundle` structure and all methods (~48 lines)
  - `fully_saturated_bfmcs_exists` AXIOM (deprecated polymorphic)
  - `temporal_coherent_family_exists` generic D theorem (dead code with sorry)
  - `construct_saturated_bfmcs` polymorphic version and wrappers
- [ ] Remove these from active TemporalCoherentConstruction.lean
- [ ] KEEP the following (verify they remain):
  - `fully_saturated_bfmcs_exists_int` (active sorry location)
  - `construct_saturated_bfmcs_int` and wrappers
  - `temporal_coherent_family_exists_Int`
  - `TemporalCoherentFamily` structure
  - `temporal_backward_G`, `temporal_backward_H`
- [ ] Add in-place Boneyard warning comment documenting archived constructions
- [ ] Run `lake build` to verify no breakage

**Timing:** 1 hour

**Critical Preservation (DO NOT ARCHIVE):**
- `TemporalCoherentFamily` structure (used by truth lemma)
- `temporal_backward_G`, `temporal_backward_H` theorems (proven, used)
- `temporal_witness_seed_consistent` theorem (proven, used)
- `fully_saturated_bfmcs_exists_int` theorem (active sorry location - THIS IS WHERE FUTURE WORK GOES)
- `construct_saturated_bfmcs_int` and wrappers (used by Bundle/Completeness.lean)

**Verification:**
- `lake build` passes with no errors
- `grep -n "fully_saturated_bfmcs_exists[^_]" ...` returns no matches in active code
- `grep -n "TemporalEvalSaturatedBundle" ...` returns no matches in active code
- `grep -n "fully_saturated_bfmcs_exists_int" ...` still returns the active sorry location

---

### Phase 5: Archive ModalWitnessSeed from ChainFMCS.lean (Conditional) [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Archive ModalWitnessSeed infrastructure if no longer needed after ChainBundleBFMCS archival

**Tasks:**
- [ ] Check if ModalWitnessSeed, psi_mem_ModalWitnessSeed, MCSBoxContent_subset_ModalWitnessSeed have remaining consumers in active code
- [ ] If no consumers remain:
  - Create `Boneyard/Metalogic_v7/Bundle/ModalWitnessSeed.lean`
  - Archive these definitions with warning header
  - Remove from active ChainFMCS.lean
  - Add in-place warning comment
- [ ] If consumers exist: KEEP definitions and skip this phase
- [ ] Run `lake build` to verify no breakage

**Timing:** 30 minutes

**Decision Rule:** Only archive if `grep -r "ModalWitnessSeed\|psi_mem_ModalWitnessSeed\|MCSBoxContent_subset_ModalWitnessSeed" Theories/Bimodal/Metalogic/` returns no matches outside of ChainFMCS.lean itself and Boneyard.

**Verification:**
- `lake build` passes with no errors

---

### Phase 6: Final Verification and Documentation [COMPLETED]

- **Dependencies:** Phase 4 (Phase 5 is conditional)
- **Goal:** Verify all changes, document archived constructions, ensure sorry-free code unchanged

**Tasks:**
- [ ] Run full `lake build` to verify project compiles
- [ ] Verify FMP completeness still sorry-free: check `FMP/SemanticCanonicalModel.lean`
- [ ] Verify Soundness still sorry-free: check `Soundness.lean`, `SoundnessLemmas.lean`
- [ ] Verify Decidability still sorry-free: check `Decidability/` directory
- [ ] Verify active completeness chain still functions: check `Bundle/Completeness.lean`
- [ ] Count total lines archived/removed and document
- [ ] Create Boneyard index file listing all archived content with rationale
- [ ] Create git commit with summary of archival

**Timing:** 30 minutes

**Boneyard Index File (`Boneyard/Metalogic_v7/README.md`):**
```markdown
# Metalogic v7 Boneyard

Archived: 2026-02-25 (Task 932)

## Contents

| File | Lines | Original Location | Why Archived |
|------|-------|-------------------|--------------|
| WitnessGraph.lean | 3,403 | Bundle/ | Dead code, constant-family approach |
| ChainBundleBFMCS.lean | 338 | Bundle/ | Dead code, MCS-membership semantics |
| ConstantWitnessFamily_ModalSaturation.lean | ~40 | Bundle/ModalSaturation.lean | Flawed constant family pattern |
| SingleFamilyBFMCS.lean | ~90 | Bundle/Construction.lean | Deprecated, sorry-backed |
| TemporalSaturationBundle.lean | ~150 | Bundle/TemporalCoherentConstruction.lean | Abandoned approach |
| ModalWitnessSeed.lean (if archived) | ~100 | Bundle/ChainFMCS.lean | Only if no consumers |

## Banned Patterns

1. **Constant Witness Families**: Mapping all time points to the same MCS
2. **MCS-Membership Box Semantics**: Using `phi in fam'.mcs t` instead of recursive truth
3. **Temporal Saturation of Single MCS**: Requiring F(psi)->psi within one MCS

## References

- specs/930_*/reports/research-007.md - Fundamental tension analysis
- specs/932_*/reports/research-001 through research-004 - Full documentation
```

**Verification:**
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/FMP/` returns empty (FMP sorry-free)
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Soundness*.lean` returns empty
- Active completeness chain (`fully_saturated_bfmcs_exists_int`) still present
- Boneyard directory structured with README and all archived files

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors after each phase
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/FMP/` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Soundness*.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Decidability/` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/` shows no axioms (deprecated axiom archived)
- [ ] Active sorry location `fully_saturated_bfmcs_exists_int` still present and used

### General
- [ ] All archived files have proper warning headers
- [ ] In-place Boneyard warning comments added at each removal site in active code
- [ ] Boneyard/Metalogic_v7/README.md documents all archived content
- [ ] No regressions in existing proofs

## Artifacts & Outputs

- `specs/932_remove_constant_witness_family_metalogic/plans/implementation-002.md` (this file)
- `Theories/Bimodal/Boneyard/Metalogic_v7/` (archived files)
- `Theories/Bimodal/Boneyard/Metalogic_v7/README.md` (index)
- `specs/932_remove_constant_witness_family_metalogic/summaries/implementation-summary-YYYYMMDD.md` (upon completion)

## Rollback/Contingency

If any phase causes build failure:
1. Use `git checkout` to restore modified files
2. Move archived files back from Boneyard if needed
3. Identify the specific definition causing breakage
4. Verify grep analysis was correct (may have missed an importer)
5. If a definition is still used, keep it in active code

The entire task operates on code with zero external consumers (verified by research-004). Archiving to Boneyard preserves all content for reference while removing it from the active build.

## Progress

**Session: 2026-02-25, sess_1772088857_e3a080f2**
- Removed: `WitnessGraph.lean` (3,403 lines) archived to Boneyard
- Removed: `ChainBundleBFMCS.lean` (338 lines) archived to Boneyard
- Removed: `RecursiveSeed.lean.backup-v004` (~4,300 lines) deleted
- Removed: `constantWitnessFamily` and related defs from ModalSaturation.lean
- Removed: `singleFamilyBFMCS` from Construction.lean (sorry eliminated)
- Removed: `TemporalEvalSaturatedBundle`, temporal saturation predicates from TemporalCoherentConstruction.lean
- Removed: `fully_saturated_bfmcs_exists` AXIOM (polymorphic, deprecated) from trusted kernel
- Removed: `construct_temporal_bfmcs`, `construct_saturated_bfmcs` (polymorphic dead code)
- Removed: `temporal_coherent_family_exists` (generic D, sorry)
- Added: Boneyard/Metalogic_v7/README.md with banned patterns and archive index
- Sorries: 5 -> 3 (2 archived: singleFamilyBFMCS.modal_backward, temporal_coherent_family_exists)
- Axioms: 1 -> 0 (fully_saturated_bfmcs_exists polymorphic axiom archived)
