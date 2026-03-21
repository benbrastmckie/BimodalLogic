# Implementation Plan: Zero-Sorry Metalogic via Extraction and Archival

- **Task**: 806 - Archive deprecated Representation/ constructions
- **Version**: 002 (Revised)
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/806_archive_deprecated_representation_constructions/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

**v001 → v002**: User requires **zero sorries** with no documentation option. All sorries must be removed via extraction/archival or by moving files out of main build. No "document and justify" fallback.

## Overview

The goal is to achieve a **completely sorry-free Metalogic** by:
1. Moving files with sorries out of the main build path
2. Extracting any required active elements before archival
3. Removing sorry-containing stub functions from files that remain

### Current Sorry Distribution

| File | Sorries | In Main Build? | Action |
|------|---------|----------------|--------|
| **Representation/** (6 files) | 28 | NO (imports commented) | Move to UnderDevelopment/ |
| Completeness.lean | 4 | YES | Remove saturation stubs |
| Decidability/Correctness.lean | 3 | YES | Remove or move file |
| Decidability/Saturation.lean | 1 | YES | Remove or move file |
| **Total** | 36 | 8 in main build | Target: 0 |

### Key Insight

The main build (`Bimodal.Metalogic`) imports:
- SoundnessLemmas ✓ (sorry-free)
- Soundness ✓ (sorry-free)
- Completeness ✗ (4 sorries in saturation stubs)
- Decidability ✗ (4 sorries in Correctness + Saturation)

The Representation/ directory is already isolated (imports commented out in `Metalogic/Metalogic.lean`).

## Goals & Non-Goals

**Goals**:
- **Zero sorries** in main Metalogic build path
- Archive or remove all sorry-containing code
- Extract active dependencies before archival
- Maintain clean build with `lake build`

**Non-Goals**:
- Completing sorried proofs (different task)
- Documenting sorries as acceptable (explicitly forbidden)
- Preserving code that requires sorries

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking main build | H | L | Incremental changes, build verification per phase |
| Removing needed code | H | M | grep for usages before any removal |
| Decidability module breakage | M | M | Can comment out entire module if needed |

## Implementation Phases

### Phase 1: Verify Representation/ Isolation [COMPLETED]

**Goal**: Confirm Representation/ is truly isolated from main build.

**Tasks**:
- [ ] Verify `Metalogic/Metalogic.lean` has Representation imports commented
- [ ] Check `Examples/Demo.lean` - if it imports Representation, modify or exclude it
- [ ] Run `lake build` to confirm no Representation files compile in main build
- [ ] Document which files are in vs out of main build

**Timing**: 15 minutes

**Verification**:
- `lake build` succeeds
- `grep -l "sorry" $(lake env printenv LEAN_FILES_IN_BUILD)` shows only Completeness + Decidability sorries

---

### Phase 2: Move Representation/ to Boneyard [COMPLETED]

**Goal**: Permanently archive the entire Representation/ directory since it's not in main build.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Boneyard/Representation/` directory
- [ ] Move all 7 files from Representation/ to Boneyard/Representation/:
  - IndexedMCSFamily.lean (4 sorries)
  - CanonicalHistory.lean (2 sorries)
  - TaskRelation.lean (5 sorries)
  - CoherentConstruction.lean (11 sorries)
  - TruthLemma.lean (4 sorries)
  - CanonicalWorld.lean (2 sorries)
  - UniversalCanonicalModel.lean (0 sorries but depends on others)
- [ ] Update `Metalogic/Metalogic.lean` module doc to note archival
- [ ] Run `lake build` to verify main build unaffected

**Timing**: 30 minutes

**Note**: Boneyard rather than UnderDevelopment because:
- UnderDevelopment implies active work
- This code has known architectural limitations (T-axiom, omega-rule)
- Boneyard = permanently archived

**Verification**:
- `lake build` succeeds
- Representation/ directory is empty or deleted
- Boneyard/Representation/ contains all moved files

---

### Phase 3: Remove Completeness.lean Saturation Stubs [COMPLETED]

**Goal**: Remove the 4 saturation stubs (sorry-containing) from Completeness.lean.

**Tasks**:
- [ ] Locate the 4 sorries in Completeness.lean:
  - `set_mcs_modal_saturation_backward`
  - `set_mcs_temporal_future_saturation`
  - `set_mcs_temporal_past_saturation`
  - (and one more)
- [ ] Check for any usages of these functions in the codebase
- [ ] If unused: Delete the function definitions entirely
- [ ] If used: Move to Boneyard/Completeness_stubs.lean
- [ ] Update Completeness.lean module documentation
- [ ] Run `lake build` to verify

**Timing**: 45 minutes

**Verification**:
- `grep -c "sorry" Completeness.lean` returns 0
- `lake build` succeeds

---

### Phase 4: Handle Decidability Sorries [COMPLETED]

**Goal**: Remove 4 sorries from Decidability/ (3 in Correctness.lean, 1 in Saturation.lean).

**Analysis needed**:
- The sorries are in completeness-related proofs (tableau completeness)
- If these break the main Decidability module, options:
  1. Comment out the sorry-containing theorems
  2. Move Correctness.lean to Boneyard
  3. Remove Decidability from main build entirely

**Tasks**:
- [ ] Analyze what `Decidability.lean` (root) actually exports
- [ ] Check if Correctness.lean exports are used elsewhere
- [ ] Option A: If Correctness theorems unused → delete the sorry-containing theorems
- [ ] Option B: If Correctness required → move to Boneyard, update Decidability.lean imports
- [ ] Handle Saturation.lean similarly
- [ ] Run `lake build` to verify

**Timing**: 1 hour

**Verification**:
- `grep -c "sorry" Decidability/*.lean` returns 0
- `lake build` succeeds
- Decision procedure still works (if preserved)

---

### Phase 5: Handle Examples/Demo.lean [COMPLETED]

**Goal**: Remove or update Demo.lean if it imports archived code.

**Tasks**:
- [ ] Check if Examples/Demo.lean imports Representation/
- [ ] If yes: Either delete Demo.lean or update imports to not use Representation
- [ ] Run `lake build` to verify

**Timing**: 15 minutes

**Verification**:
- `lake build` succeeds
- No imports reference Representation/ or archived code

---

### Phase 6: Final Verification and Cleanup [COMPLETED]

**Goal**: Verify zero sorries in main build, update documentation.

**Tasks**:
- [ ] Run comprehensive sorry grep (excluding Boneyard):
  ```bash
  grep -rn "sorry" Theories/Bimodal/Metalogic/*.lean Theories/Bimodal/Metalogic/**/*.lean \
    | grep -v Boneyard | grep -v ".md" | grep -v "sorry-free"
  ```
- [ ] Verify `lake build` succeeds cleanly
- [ ] Update Metalogic/README.md:
  - Document sorry-free status
  - Reference Boneyard for archived approaches
  - Update architecture diagram
- [ ] Run `lake clean && lake build` for clean verification
- [ ] Update specs/state.json repository_health metrics

**Timing**: 30 minutes

**Verification**:
- Zero sorries in main build path (grep returns empty)
- Clean build succeeds
- Documentation updated

## Testing & Validation

- [ ] `lake build` succeeds at every phase
- [ ] `grep -r "sorry" Metalogic/ | grep -v Boneyard | grep -v ".md"` returns empty
- [ ] All existing tests pass (if any)
- [ ] Soundness theorem still accessible
- [ ] Decision procedure still works (if preserved in build)

## Artifacts & Outputs

- Modified `Theories/Bimodal/Metalogic/Completeness.lean` (stubs removed)
- Modified `Theories/Bimodal/Metalogic/Decidability.lean` (updated imports if needed)
- Modified `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` (sorries removed or archived)
- Modified `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` (sorry removed or archived)
- New directory `Theories/Bimodal/Metalogic/Boneyard/Representation/` with archived files
- Modified `Theories/Bimodal/Metalogic/README.md`
- `specs/806_archive_deprecated_representation_constructions/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If any phase breaks the build irrecoverably:
1. `git reset --hard HEAD~1` to revert last commit
2. Re-analyze dependencies
3. Take more conservative approach (move entire modules to Boneyard)

**No sorry documentation fallback** - if code cannot be sorry-free, it must be archived.
