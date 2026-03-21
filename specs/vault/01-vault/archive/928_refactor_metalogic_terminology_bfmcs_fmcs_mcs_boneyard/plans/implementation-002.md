# Implementation Plan: Refactor metalogic terminology and Boneyard cleanup

- **Task**: 928 - Refactor metalogic terminology (BMCS->BFMCS, FMCS, MCS) and archive to Boneyard
- **Status**: [NOT STARTED]
- **Effort**: 11 hours
- **Version**: 2 (revised from v1 to add BMCS -> BFMCS phase)
- **Dependencies**: None (task 925 completed; this completes its skipped Phase 2 and partial Phase 1)
- **Research Inputs**: specs/928_refactor_metalogic_terminology_bfmcs_fmcs_mcs_boneyard/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Notes (v2)

**User feedback**: "Rename BMCS -> BFMCS only after all renaming of BFMCS -> FMCS occurs, making the name 'BFMCS' available for reassignment without confusion."

**Change**: Added Phase 3 (BMCS -> BFMCS rename) after Phase 2 (BFMCS -> FMCS rename). This accomplishes the original task goal:
- **Step 1**: Rename `BFMCS` -> `FMCS` (freeing up the name "BFMCS")
- **Step 2**: Rename `BMCS` -> `BFMCS` (now clearly "Bundle of FMCSs")

This is superior to v1's approach of keeping BMCS unchanged.

## Overview

This task completes the terminology refactoring and Boneyard cleanup that was partially done in task 925. The key insight is that the rename must happen in the correct **order** to avoid confusion:

1. **First**: Rename `BFMCS` (single family) -> `FMCS` (Family of MCS)
2. **Then**: Rename `BMCS` (bundle) -> `BFMCS` (Bundle of FMCSs)

After this two-step rename, the terminology will be crystal clear:
- **MCS** = Maximal Consistent Set (single set)
- **FMCS** = Family of MCS (time-indexed family of MCSs)
- **BFMCS** = Bundle of FMCSs (set of families with modal coherence)

Additionally, move `CoherentConstruction.lean` and constant-family code to Boneyard, remove the `CanonicalWorldState` duplicate, and update stale documentation throughout.

### Research Integration

From research-001.md (2 teammates, HIGH confidence):
- Task 925 Phase 1 was partial: only created `abbrev FMCS := BFMCS` instead of true rename
- Task 925 Phase 2 was entirely skipped: CoherentConstruction.lean and constant families remain in active code
- 5 sorries and 2 custom axioms exist in the legacy chain (NOT in sorry-free chain)
- Sorry-free chain in ChainBundleBMCS.lean is publication-ready
- Metalogic.lean module table claims 7 sorries (actual: 5), wrong DovetailingChain count (claims 4, actual: 2)
- 264 BFMCS occurrences across 20 files, 360 BMCS occurrences across 20 files

## Goals & Non-Goals

**Goals**:
- Complete the BFMCS -> FMCS rename across all 264 occurrences in 20 files
- Complete the BMCS -> BFMCS rename across all 360 occurrences in 20 files
- Rename BFMCS.lean to FMCSDef.lean, CanonicalBFMCS.lean to CanonicalFMCS.lean
- Rename BMCS.lean to BFMCS.lean, ChainBundleBMCS.lean to ChainBundleBFMCS.lean, BMCSTruth.lean to BFMCSTruth.lean
- Move CoherentConstruction.lean to Boneyard/Bundle/
- Move constant-family definitions to Boneyard
- Fix import chain so sorry-free chain does not transitively import CoherentConstruction.lean
- Remove CanonicalWorldState duplicate between Completeness.lean and Representation.lean
- Update Metalogic.lean sorry table with correct counts
- Update Bundle/README.md and Metalogic/README.md with current architecture
- Ensure `lake build` passes with zero errors after each phase

**Non-Goals**:
- Resolving any sorries or axioms (out of scope; this is terminology/cleanup only)
- Phase 6 timeshift closure corrections (research found inapplicable to any construction)
- Moving DovetailingChain.lean to Boneyard (still contains fundamental infrastructure)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Two-step rename is complex (624 total occurrences) | H | H | Phase 2 completes first rename FULLY before Phase 3 begins |
| Rename breaks references across 20+ files | H | H | Systematic sed replacement with incremental `lake build` verification |
| CoherentConstruction.lean removal breaks imports | H | H | Audit all imports before moving; extract needed definitions |
| Import chain changes create circular dependencies | M | M | Analyze dependency graph before restructuring |
| Boneyard files that import active code break | M | H | Update Boneyard imports or accept that Boneyard files may not build |

## Sorry Characterization

### Pre-existing Sorries
- 5 sorries in active Metalogic (all in legacy chain, none in sorry-free chain):
  - `Construction.lean` line 197: `singleFamilyBMCS.modal_backward`
  - `TemporalCoherentConstruction.lean` line 613: `temporal_coherent_family_exists`
  - `TemporalCoherentConstruction.lean` line 819: `fully_saturated_bmcs_exists_int`
  - `DovetailingChain.lean` line 1869: `buildDovetailingChainFamily_forward_F`
  - `DovetailingChain.lean` line 1881: `buildDovetailingChainFamily_backward_P`

### Expected Resolution
- This task does NOT resolve any sorries. It is a rename/cleanup/documentation task.
- Pre-existing sorries will remain (with updated identifier names).
- Sorries in CoherentConstruction.lean will move to Boneyard (reducing active sorry count).

### New Sorries
- None. NEVER introduce new sorries.
- If any proof breaks due to renaming, fix the proof rather than adding sorry.
- If a proof fix proves intractable, mark phase [BLOCKED] with requires_user_review: true.

### Remaining Debt
After this implementation:
- 5 sorries remain in active Metalogic (with updated names)
- 1 custom axiom remains in active Metalogic (`saturated_extension_exists` moves to Boneyard)

## Axiom Characterization

### Pre-existing Axioms
- 2 custom axioms in active Metalogic:
  - `TemporalCoherentConstruction.lean` line 755: `fully_saturated_bmcs_exists`
  - `CoherentConstruction.lean` line 871: `saturated_extension_exists`

### Expected Resolution
- `saturated_extension_exists` moves to Boneyard with CoherentConstruction.lean
- `fully_saturated_bmcs_exists` stays (legacy chain, will be renamed)

### New Axioms
- None. NEVER introduce new axioms.

## Implementation Phases

### Phase 1: BFMCS -> FMCS Rename in Core Definition Files [COMPLETED]

- **Dependencies:** None
- **Goal:** Rename the `structure BFMCS` to `structure FMCS` in its definition file and update the core files that define or directly extend BFMCS.

**Tasks:**
- [ ] Rename `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` to `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`
- [ ] In the renamed file: change `structure BFMCS` to `structure FMCS`, update all internal BFMCS references
- [ ] Update `FMCS.lean` to provide `abbrev BFMCS := FMCS` for temporary backward compatibility
- [ ] Rename `CanonicalBFMCS.lean` to `CanonicalFMCS.lean`
- [ ] Update `BMCS.lean` to import the new FMCS definition file and update references (BMCS still uses FMCS in its definition)
- [ ] Update all import statements referencing `Bimodal.Metalogic.Bundle.BFMCS`
- [ ] Run `lake build` to verify compilation

**Timing:** 2 hours

**Files to modify:**
- `BFMCS.lean` -> rename to `FMCSDef.lean`
- `FMCS.lean` - provide backward compat alias `abbrev BFMCS := FMCS`
- `CanonicalBFMCS.lean` -> rename to `CanonicalFMCS.lean`
- `BMCS.lean` - update import, change `BFMCS` to `FMCS` in field type
- All files importing BFMCS: update import paths

**Verification:**
- `lake build` passes with 0 errors
- `grep -rn "import.*\.BFMCS\"" Theories/Bimodal/Metalogic/` returns 0 matches

---

### Phase 2: BFMCS -> FMCS Rename in All Usage Sites [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Complete the terminology rename across all 264 BFMCS occurrences in 20 active Metalogic files.

**Tasks:**
- [ ] Systematically replace `BFMCS` with `FMCS` in each file (type references, function names like `constantBFMCS` -> `constantFMCS`, `toBFMCS` -> `toFMCS`, etc.)
- [ ] Update identifier names: `toBFMCS`, `CanonicalBFMCS`, `chainBFMCS`, etc.
- [ ] Update docstrings and comments mentioning BFMCS
- [ ] Keep `BMCS` references unchanged (will be renamed in Phase 3)
- [ ] Remove backward compat alias from FMCS.lean once all references updated
- [ ] Run `lake build` after each major file group
- [ ] Final `lake build` to verify all 264 occurrences replaced

**Timing:** 2.5 hours

**Files to modify (all 20 files with BFMCS occurrences):**
- `BMCSTruth.lean` (31 occurrences)
- `CanonicalFMCS.lean` (23 occurrences)
- `WitnessGraph.lean` (20 occurrences)
- `FMCSDef.lean` / `FMCS.lean` (27 occurrences)
- `ChainBundleBMCS.lean` (14 occurrences)
- `BMCS.lean` (13 occurrences)
- `Representation.lean` (12 occurrences)
- `DovetailingChain.lean` (11 occurrences)
- `TemporalCoherentConstruction.lean` (10 occurrences)
- `TruthLemma.lean` (9 occurrences)
- `Construction.lean` (8 occurrences)
- `ModalSaturation.lean` (8 occurrences)
- `CanonicalEmbedding.lean` (5 occurrences)
- `CanonicalReachable.lean` (4 occurrences)
- `Completeness.lean` (2 occurrences)
- `ChainFMCS.lean` (2 occurrences)
- `CanonicalQuotient.lean` (1 occurrence)
- `Metalogic.lean` (1 occurrence)
- `CoherentConstruction.lean` (63 occurrences - will move to Boneyard later)

**Verification:**
- `lake build` passes with 0 errors
- `grep -rn "\bBFMCS\b" Theories/Bimodal/Metalogic/` returns 0 matches (excluding any temp compat alias)
- All proofs still close without sorry

---

### Phase 3: BMCS -> BFMCS Rename (Bundle Terminology) [COMPLETED]

- **Dependencies:** Phase 2 (BFMCS name now free)
- **Goal:** Rename `BMCS` to `BFMCS` across all 360 occurrences in 20 files, completing the terminology refactoring per the original task intent.

**After this phase, terminology will be:**
- `FMCS` = Family of MCS (single family)
- `BFMCS` = Bundle of FMCSs (set of families)

**Tasks:**
- [ ] Rename `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` to `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`
- [ ] In the renamed file: change `structure BMCS` to `structure BFMCS`, update all internal BMCS references
- [ ] Rename `BMCSTruth.lean` to `BFMCSTruth.lean`
- [ ] Rename `ChainBundleBMCS.lean` to `ChainBundleBFMCS.lean`
- [ ] Systematically replace `BMCS` with `BFMCS` in all files:
  - Type references (`BMCS D` -> `BFMCS D`)
  - Function names (`bmcs_truth_lemma` -> `bfmcs_truth_lemma`, `singleFamilyBMCS` -> `singleFamilyBFMCS`)
  - Docstrings and comments
- [ ] Update all import statements referencing `Bimodal.Metalogic.Bundle.BMCS`
- [ ] Run `lake build` after each major file group
- [ ] Final `lake build` to verify all 360 occurrences replaced

**Timing:** 2.5 hours

**Files to modify (all files with BMCS occurrences):**
- `BMCS.lean` -> rename to `BFMCS.lean` (19 occurrences of "BMCS" identifier)
- `Completeness.lean` (45 occurrences)
- `TemporalCoherentConstruction.lean` (40 occurrences)
- `BMCSTruth.lean` -> rename to `BFMCSTruth.lean` (37 occurrences)
- `Representation.lean` (33 occurrences)
- `TruthLemma.lean` (26 occurrences)
- `ModalSaturation.lean` (26 occurrences)
- `ChainBundleBMCS.lean` -> rename to `ChainBundleBFMCS.lean` (26 occurrences)
- `CoherentConstruction.lean` (19 occurrences - will move to Boneyard later)
- `Construction.lean` (17 occurrences)
- `Metalogic.lean` (12 occurrences)
- Other files with BMCS references

**Verification:**
- `lake build` passes with 0 errors
- `grep -rn "\bBMCS\b" Theories/Bimodal/Metalogic/` returns 0 matches
- `grep -rn "import.*\.BMCS\"" Theories/Bimodal/Metalogic/` returns 0 matches
- All proofs still close without sorry

---

### Phase 4: Boneyard Cleanup - Move CoherentConstruction.lean [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Complete the task 925 Phase 2 cleanup by moving CoherentConstruction.lean and its constant-family infrastructure to Boneyard/Bundle/.

**Tasks:**
- [ ] Audit what TemporalCoherentConstruction.lean actually uses from CoherentConstruction.lean
- [ ] Audit what TruthLemma.lean actually uses from CoherentConstruction.lean
- [ ] Extract any definitions still needed by active code to their appropriate locations
- [ ] Move `CoherentConstruction.lean` to `Theories/Bimodal/Boneyard/Bundle/CoherentConstruction.lean`
- [ ] Remove `import Bimodal.Metalogic.Bundle.CoherentConstruction` from active files
- [ ] Verify sorry-free chain no longer transitively imports CoherentConstruction.lean
- [ ] Run `lake build`

**Timing:** 1.5 hours

**Files to modify:**
- `CoherentConstruction.lean` -> move to `Boneyard/Bundle/`
- `TemporalCoherentConstruction.lean` - remove import, fix broken references
- `TruthLemma.lean` - remove import, fix broken references

**Verification:**
- `lake build` passes with 0 errors
- `grep -rn "import.*CoherentConstruction" Theories/Bimodal/Metalogic/` returns 0 matches
- Sorry-free chain does not transitively import CoherentConstruction

---

### Phase 5: Boneyard Cleanup - Constant Family Definitions [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Move constant-family definitions from active code to Boneyard.

**Tasks:**
- [ ] Audit usage of `constantFMCS` (was `constantBFMCS`) in Construction.lean
- [ ] Audit usage of `constantWitnessFamily` and `constructWitnessFamily` in ModalSaturation.lean
- [ ] If constant family definitions are only used by legacy/Boneyard code, move to Boneyard
- [ ] Clean up `singleFamilyBFMCS` (was `singleFamilyBMCS`) in Construction.lean - move to Boneyard if safe
- [ ] Run `lake build`

**Timing:** 1 hour

**Files to modify:**
- `Construction.lean` - potentially move constantFMCS, singleFamilyBFMCS
- `ModalSaturation.lean` - potentially move constantWitnessFamily, constructWitnessFamily

**Verification:**
- `lake build` passes with 0 errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/` count does not increase

---

### Phase 6: Code Cleanup and Import Hygiene [COMPLETED]

- **Dependencies:** Phase 5
- **Goal:** Remove the CanonicalWorldState duplicate, clean up import chains, remove stale TODOs.

**Tasks:**
- [ ] Identify canonical definition of `CanonicalWorldState` (Completeness.lean vs Representation.lean)
- [ ] Remove the duplicate, update references
- [ ] Audit imports in sorry-free chain files for unnecessary transitive imports
- [ ] Remove stale TODO comments
- [ ] Run `lake build`

**Timing:** 0.5 hours

**Files to modify:**
- `Completeness.lean` or `Representation.lean` - remove duplicate
- Various files - import cleanup

**Verification:**
- `lake build` passes with 0 errors
- `grep -rn "CanonicalWorldState" Theories/Bimodal/Metalogic/` shows definition in exactly one file

---

### Phase 7: Documentation Update [COMPLETED]

- **Dependencies:** Phase 6
- **Goal:** Update all stale documentation to reflect the new terminology and correct sorry counts.

**Tasks:**
- [ ] Update `Metalogic.lean` docstring:
  - Fix sorry count
  - Fix DovetailingChain sorry count (4 -> 2)
  - Add missing module entries
  - Update BMCS -> BFMCS, BFMCS -> FMCS terminology
- [ ] Update `Bundle/README.md`:
  - Update architecture diagram
  - Update sorry status table
  - Replace BMCS/BFMCS references with new terminology
- [ ] Update `Metalogic/README.md`:
  - Update architecture diagram
  - Update file listing
- [ ] Update module docstrings in FMCS.lean, BFMCS.lean (was BMCS.lean)
- [ ] Run `lake build` (final verification)

**Timing:** 1 hour

**Files to modify:**
- `Metalogic/Metalogic.lean` - docstring update
- `Bundle/README.md` - full rewrite
- `Metalogic/README.md` - architecture update
- `FMCS.lean`, `BFMCS.lean` - docstring updates

**Verification:**
- `lake build` passes with 0 errors
- `grep -rn "IndexedMCSFamily" Theories/Bimodal/Metalogic/` returns 0 matches
- All terminology is consistent: FMCS = family, BFMCS = bundle
- Sorry counts in documentation match actual `grep` results

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors after every phase
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/` count does not increase
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/*.lean` shows no new axioms
- [ ] Sorry-free chain verification: `lean_verify` on completeness theorems shows only standard Lean axioms

### Rename Completeness
- [ ] `grep -rn "\bBMCS\b" Theories/Bimodal/Metalogic/` returns 0 matches (after Phase 3)
- [ ] Old BFMCS is now FMCS everywhere
- [ ] Old BMCS is now BFMCS everywhere
- [ ] `grep -rn "IndexedMCSFamily" Theories/Bimodal/Metalogic/` returns 0 matches

### Terminology Verification
After all phases:
- **MCS** = Maximal Consistent Set (unchanged)
- **FMCS** = Family of MCS (was BFMCS)
- **BFMCS** = Bundle of FMCSs (was BMCS)

## Artifacts & Outputs

- `specs/928_refactor_metalogic_terminology_bfmcs_fmcs_mcs_boneyard/plans/implementation-002.md` (this file)
- `specs/928_refactor_metalogic_terminology_bfmcs_fmcs_mcs_boneyard/summaries/implementation-summary-20260225.md` (upon completion)

## Rollback/Contingency

- All changes are tracked in git with per-phase commits
- If rename causes widespread breakage: `git revert` the rename commits
- If any proof breaks and cannot be fixed without sorry: mark phase [BLOCKED] with requires_user_review: true
