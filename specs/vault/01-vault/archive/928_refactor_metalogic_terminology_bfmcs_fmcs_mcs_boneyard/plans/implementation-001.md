# Implementation Plan: Refactor metalogic terminology and Boneyard cleanup

- **Task**: 928 - Refactor metalogic terminology (BMCS->BFMCS, FMCS, MCS) and archive to Boneyard
- **Status**: [NOT STARTED]
- **Effort**: 9 hours
- **Dependencies**: None (task 925 completed; this completes its skipped Phase 2 and partial Phase 1)
- **Research Inputs**: specs/928_refactor_metalogic_terminology_bfmcs_fmcs_mcs_boneyard/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task completes the terminology refactoring and Boneyard cleanup that was partially done in task 925. Research found that the original task description's proposal to "rename BMCS to BFMCS" would create confusion since BFMCS already has 264 occurrences as the single-family structure name. Instead, the correct approach is to complete the task 925 rename: rename the `BFMCS` structure to `FMCS` (Family of MCS), keep `BMCS` as the bundle name, move `CoherentConstruction.lean` and constant-family code to Boneyard, remove the `CanonicalWorldState` duplicate, and update stale documentation throughout.

### Research Integration

From research-001.md (2 teammates, HIGH confidence):
- Task 925 Phase 1 was partial: only created `abbrev FMCS := BFMCS` instead of true rename
- Task 925 Phase 2 was entirely skipped: CoherentConstruction.lean and constant families remain in active code
- 5 sorries and 2 custom axioms exist in the legacy chain (NOT in sorry-free chain)
- Sorry-free chain in ChainBundleBMCS.lean is publication-ready
- Metalogic.lean module table claims 7 sorries (actual: 5), wrong DovetailingChain count (claims 4, actual: 2)
- Bundle/README.md architecture diagram still references IndexedMCSFamily.lean (renamed to BFMCS.lean in task 914)
- CanonicalBFMCS.lean was never renamed to CanonicalFMCS.lean (planned in task 925 Phase 1)
- Import chain pollution: sorry-free chain transitively imports CoherentConstruction.lean

## Goals & Non-Goals

**Goals**:
- Complete the BFMCS -> FMCS rename across all 264 occurrences in 20 files
- Rename BFMCS.lean to FMCS_Def.lean (or merge into FMCS.lean) and CanonicalBFMCS.lean to CanonicalFMCS.lean
- Move CoherentConstruction.lean to Boneyard/Bundle/
- Move constant-family definitions (constantBFMCS, constantWitnessFamily, constructWitnessFamily, IsConstantFamily) to Boneyard
- Fix import chain so sorry-free chain does not transitively import CoherentConstruction.lean
- Remove CanonicalWorldState duplicate between Completeness.lean and Representation.lean
- Update Metalogic.lean sorry table with correct counts (5 sorries, not 7)
- Update Bundle/README.md and Metalogic/README.md with current architecture
- Ensure `lake build` passes with zero errors after each phase

**Non-Goals**:
- Renaming BMCS to BFMCS (research found this creates naming collision)
- Resolving any sorries or axioms (out of scope; this is terminology/cleanup only)
- Phase 6 timeshift closure corrections (research found inapplicable to any construction)
- Moving DovetailingChain.lean to Boneyard (still contains fundamental infrastructure)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Rename breaks 264 BFMCS references across 20 files | H | H | Systematic sed replacement with incremental `lake build` verification |
| CoherentConstruction.lean removal breaks imports in TemporalCoherentConstruction.lean and TruthLemma.lean | H | H | Audit all imports before moving; extract needed definitions to new locations |
| Import chain changes create circular dependencies | M | M | Analyze dependency graph before restructuring; verify with `lake build` after each change |
| Constant family definitions used by non-Boneyard code | M | M | Grep thoroughly before moving; keep definitions that are actively referenced |
| Boneyard files that import active code break after rename | M | H | Update Boneyard imports or accept that Boneyard files may not build |

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
- Pre-existing sorries will remain in the legacy chain files (renamed from BFMCS to FMCS).
- Sorries in CoherentConstruction.lean will move to Boneyard (reducing active sorry count).

### New Sorries
- None. NEVER introduce new sorries. This is a terminology refactoring task; no proofs are modified.
- If any proof breaks due to renaming, fix the proof rather than adding sorry.
- If a proof fix proves intractable, mark phase [BLOCKED] with requires_user_review: true.

### Remaining Debt
After this implementation:
- 5 sorries remain in active Metalogic (same as before, just renamed BFMCS -> FMCS in identifiers)
- 2 custom axioms remain in active Metalogic (1 moves to Boneyard with CoherentConstruction.lean, leaving 1)
- `saturated_extension_exists` axiom in CoherentConstruction.lean moves to Boneyard
- `fully_saturated_bmcs_exists` axiom in TemporalCoherentConstruction.lean stays (legacy chain)

## Axiom Characterization

### Pre-existing Axioms
- 2 custom axioms in active Metalogic:
  - `TemporalCoherentConstruction.lean` line 755: `fully_saturated_bmcs_exists`
  - `CoherentConstruction.lean` line 871: `saturated_extension_exists`

### Expected Resolution
- `saturated_extension_exists` moves to Boneyard with CoherentConstruction.lean (reduces active count by 1)
- `fully_saturated_bmcs_exists` stays in TemporalCoherentConstruction.lean (legacy chain, not in scope)

### New Axioms
- None. NEVER introduce new axioms.

### Remaining Debt
- 1 custom axiom remains in active Metalogic after cleanup
- Publication-ready chain (ChainBundleBMCS.lean) has zero custom axioms

## Implementation Phases

### Phase 1: BFMCS -> FMCS Rename in Core Definition Files [NOT STARTED]

- **Dependencies:** None
- **Goal:** Rename the `structure BFMCS` to `structure FMCS` in its definition file and update the core files that define or directly extend BFMCS, establishing the new naming convention.

**Tasks:**
- [ ] Rename `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` to `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`
- [ ] In the renamed file: change `structure BFMCS` to `structure FMCS`, update all internal BFMCS references
- [ ] Update `FMCS.lean` to either: (a) become the new definition file, or (b) provide `abbrev BFMCS := FMCS` for backward compatibility
- [ ] Rename `CanonicalBFMCS.lean` to `CanonicalFMCS.lean`
- [ ] Update `BMCS.lean` to import the new FMCS definition file and update references
- [ ] Update all import statements referencing `Bimodal.Metalogic.Bundle.BFMCS` across 15 files
- [ ] Update all import statements referencing `Bimodal.Metalogic.Bundle.CanonicalBFMCS` in ChainBundleBMCS.lean and ChainFMCS.lean
- [ ] Run `lake build` to verify compilation

**Timing:** 2 hours

**Files to modify:**
- `BFMCS.lean` -> rename to `FMCSDef.lean` (or merge into `FMCS.lean`)
- `FMCS.lean` - update to either be the definition or provide backward compat alias
- `CanonicalBFMCS.lean` -> rename to `CanonicalFMCS.lean`
- `BMCS.lean` - update import and references
- All 15 files importing BFMCS: update import paths

**Verification:**
- `lake build` passes with 0 errors
- `grep -rn "import.*BFMCS" Theories/` returns only Boneyard files (if any)
- `grep -rn "import.*CanonicalBFMCS" Theories/` returns only Boneyard files (if any)

---

### Phase 2: BFMCS -> FMCS Rename in All Usage Sites [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Complete the terminology rename across all 264 BFMCS occurrences in 20 active Metalogic files, replacing `BFMCS` with `FMCS` in type signatures, identifiers, comments, and docstrings.

**Tasks:**
- [ ] Systematically replace `BFMCS` with `FMCS` in each file (type references, function names like `constantBFMCS` -> `constantFMCS`, `toBFMCS` -> `toFMCS`, etc.)
- [ ] Update identifier names: `toBFMCS`, `CanonicalBFMCS`, `chainBFMCS`, etc.
- [ ] Update docstrings and comments mentioning BFMCS
- [ ] Preserve `BMCS` references (these are correct - bundle name)
- [ ] Run `lake build` after each major file group to catch breakage early
- [ ] Final `lake build` to verify all 264 occurrences replaced cleanly

**Timing:** 2.5 hours

**Files to modify (all 20 files with BFMCS occurrences):**
- `BMCSTruth.lean` (31 occurrences)
- `CanonicalFMCS.lean` (23 occurrences, renamed in Phase 1)
- `WitnessGraph.lean` (20 occurrences)
- `FMCS.lean` / `FMCSDef.lean` (20+7 occurrences)
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
- `CoherentConstruction.lean` (63 occurrences - will move to Boneyard in Phase 3)

**Verification:**
- `lake build` passes with 0 errors
- `grep -rn "\bBFMCS\b" Theories/Bimodal/Metalogic/` returns 0 matches (excluding Boneyard)
- All proofs still close without sorry

---

### Phase 3: Boneyard Cleanup - Move CoherentConstruction.lean [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Complete the task 925 Phase 2 cleanup by moving CoherentConstruction.lean and its constant-family infrastructure to Boneyard/Bundle/, fixing imports in files that currently depend on it.

**Tasks:**
- [ ] Audit what TemporalCoherentConstruction.lean actually uses from CoherentConstruction.lean
- [ ] Audit what TruthLemma.lean actually uses from CoherentConstruction.lean
- [ ] Extract any definitions still needed by active code to their appropriate locations
- [ ] Move `CoherentConstruction.lean` to `Theories/Bimodal/Boneyard/Bundle/CoherentConstruction.lean`
- [ ] Remove `import Bimodal.Metalogic.Bundle.CoherentConstruction` from TemporalCoherentConstruction.lean
- [ ] Remove `import Bimodal.Metalogic.Bundle.CoherentConstruction` from TruthLemma.lean
- [ ] Update Boneyard/Bundle/WeakCoherentBundle.lean import if needed
- [ ] Verify sorry-free chain no longer transitively imports CoherentConstruction.lean
- [ ] Run `lake build`

**Timing:** 1.5 hours

**Files to modify:**
- `CoherentConstruction.lean` -> move to `Boneyard/Bundle/`
- `TemporalCoherentConstruction.lean` - remove CoherentConstruction import, fix any broken references
- `TruthLemma.lean` - remove CoherentConstruction import, fix any broken references
- `Boneyard/Bundle/WeakCoherentBundle.lean` - update import path

**Verification:**
- `lake build` passes with 0 errors
- `grep -rn "import.*CoherentConstruction" Theories/Bimodal/Metalogic/` returns 0 matches
- Sorry-free chain (ChainBundleBMCS.lean) does not transitively import CoherentConstruction
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/` count does not increase

---

### Phase 4: Boneyard Cleanup - Constant Family Definitions [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Move constant-family definitions from active code to Boneyard, since the sorry-free chain uses chain-based families instead.

**Tasks:**
- [ ] Audit usage of `constantBFMCS` (now `constantFMCS`) in Construction.lean - check if anything outside Boneyard/legacy depends on it
- [ ] Audit usage of `constantWitnessFamily` and `constructWitnessFamily` in ModalSaturation.lean
- [ ] If constant family definitions are only used by legacy/Boneyard code, move to Boneyard
- [ ] If constant family definitions are used by active code, add TODO comments noting they are legacy
- [ ] Clean up `singleFamilyBMCS` in Construction.lean (legacy, has sorry) - move to Boneyard if safe
- [ ] Run `lake build`

**Timing:** 1 hour

**Files to modify:**
- `Construction.lean` - potentially extract/move constantBFMCS, singleFamilyBMCS
- `ModalSaturation.lean` - potentially extract/move constantWitnessFamily, constructWitnessFamily

**Verification:**
- `lake build` passes with 0 errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/` count does not increase
- No new imports added to sorry-free chain files

---

### Phase 5: Code Cleanup and Import Hygiene [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Remove the CanonicalWorldState duplicate, clean up import chains, and remove stale TODO comments.

**Tasks:**
- [ ] Identify which definition of `CanonicalWorldState` is canonical (Completeness.lean line 647 vs Representation.lean line 95)
- [ ] Remove the duplicate, update references to use the surviving definition
- [ ] Audit imports in sorry-free chain files (ChainBundleBMCS.lean, ChainFMCS.lean, CanonicalFMCS.lean) for unnecessary transitive imports
- [ ] Remove any import that is not directly needed
- [ ] Scan for and remove stale TODO comments that reference completed work
- [ ] Run `lake build`

**Timing:** 1 hour

**Files to modify:**
- `Completeness.lean` or `Representation.lean` - remove duplicate CanonicalWorldState
- Various files - import cleanup
- Various files - stale TODO removal

**Verification:**
- `lake build` passes with 0 errors
- `grep -rn "CanonicalWorldState" Theories/Bimodal/Metalogic/` shows definition in exactly one file
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/` count does not increase

---

### Phase 6: Documentation Update [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Update all stale documentation to reflect the new terminology, correct sorry counts, and current architecture.

**Tasks:**
- [ ] Update `Metalogic.lean` docstring:
  - Fix sorry count from 7 to 5 (or updated count after Phase 3-4 cleanup)
  - Fix DovetailingChain sorry count from 4 to 2
  - Add missing module entries: FMCS.lean, ChainFMCS.lean, ChainBundleBMCS.lean, CanonicalEmbedding.lean, CanonicalQuotient.lean, CanonicalReachable.lean, WitnessGraph.lean, CanonicalFrame.lean, CanonicalFMCS.lean, TemporalContent.lean
  - Update BFMCS references to FMCS
- [ ] Update `Bundle/README.md`:
  - Replace architecture diagram (remove IndexedMCSFamily.lean reference, add new files)
  - Update sorry status table with correct counts
  - Replace BFMCS references with FMCS
  - Update code examples
  - Remove references to SaturatedConstruction.lean (in Boneyard)
- [ ] Update `Metalogic/README.md`:
  - Replace architecture diagram with current file structure
  - Update Bundle/ file listing (remove IndexedMCSFamily.lean, add all new files)
  - Replace BFMCS references with FMCS
- [ ] Update BFMCS.lean (now FMCSDef.lean or FMCS.lean) module docstring
- [ ] Run `lake build` (final verification)

**Timing:** 1 hour

**Files to modify:**
- `Metalogic/Metalogic.lean` - docstring update
- `Bundle/README.md` - full rewrite of architecture and status sections
- `Metalogic/README.md` - architecture diagram and file listing update
- `FMCS.lean` / `FMCSDef.lean` - docstring update

**Verification:**
- `lake build` passes with 0 errors
- `grep -rn "IndexedMCSFamily" Theories/Bimodal/Metalogic/` returns 0 matches (only Boneyard)
- `grep -rn "\bBFMCS\b" Theories/Bimodal/Metalogic/` returns 0 matches (only Boneyard)
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/` count verified against documentation
- All sorry counts in documentation match actual `grep` results
- No new axioms: `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/*.lean` shows no new axioms

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors after every phase
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/` count does not increase (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/*.lean` shows no new axioms
- [ ] Sorry-free chain verification: `lean_verify` on `bmcs_weak_completeness_mcs` and `bmcs_strong_completeness_mcs` in ChainBundleBMCS.lean shows only standard Lean axioms

### Rename Completeness
- [ ] `grep -rn "\bBFMCS\b" Theories/Bimodal/Metalogic/` returns 0 matches
- [ ] `grep -rn "import.*BFMCS" Theories/Bimodal/Metalogic/` returns 0 matches
- [ ] `grep -rn "import.*CanonicalBFMCS" Theories/Bimodal/Metalogic/` returns 0 matches
- [ ] `grep -rn "IndexedMCSFamily" Theories/Bimodal/Metalogic/` returns 0 matches

### Boneyard Cleanup
- [ ] `CoherentConstruction.lean` exists in `Boneyard/Bundle/`, not in `Metalogic/Bundle/`
- [ ] No active Metalogic file imports CoherentConstruction
- [ ] Sorry-free chain does not transitively import CoherentConstruction

### Documentation Accuracy
- [ ] Sorry counts in Metalogic.lean match `grep` results
- [ ] Bundle/README.md architecture diagram matches actual file listing
- [ ] Metalogic/README.md file structure matches actual directory

## Artifacts & Outputs

- `specs/928_refactor_metalogic_terminology_bfmcs_fmcs_mcs_boneyard/plans/implementation-001.md` (this file)
- `specs/928_refactor_metalogic_terminology_bfmcs_fmcs_mcs_boneyard/summaries/implementation-summary-20260225.md` (upon completion)

## Rollback/Contingency

- All changes are tracked in git with per-phase commits
- If rename causes widespread breakage that cannot be resolved: `git revert` the rename commits and reassess approach
- If CoherentConstruction.lean removal breaks too many imports: keep it in active code but add deprecation comments
- If any proof breaks due to rename and cannot be fixed without sorry: mark phase [BLOCKED] with requires_user_review: true rather than introducing sorry
