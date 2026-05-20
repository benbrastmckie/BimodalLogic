# Implementation Summary: Task #21

- **Task**: 21 - Clean up technical debt from tasks 9-20
- **Status**: Implemented
- **Plan**: plans/02_tech-debt-cleanup.md
- **Session**: sess_1779293683_4e43b6
- **Date**: 2026-05-20

## Changes Made

### Phase 1: Archive Algebraic Dead Code to Boneyard
- Moved `Algebraic/TenseS5Algebra.lean` (365 lines, 3 sorries) and `Algebraic/UltrafilterFrame.lean` (1,182 lines, 2 sorries) to `Boneyard/UltrafilterFrame/`
- Removed TenseS5Algebra import from `Algebraic/Algebraic.lean` and its `open` statement
- Replaced commented-out UltrafilterFrame import with archival note
- Updated `Algebraic/Algebraic.lean` module tree docstring
- Added tombstone comments to each archived file
- Added Boneyard README entry with inventory, detail section, and task cross-reference
- Updated `Algebraic/README.md`: fixed TenseS5Algebra sorry status (was falsely "Sorry-free"), fixed AlgebraicRepresentation -> AlgebraicCompleteness rename, fixed ParametricRepresentation -> ParametricCompleteness, added UltrafilterFrame archival section
- **Net result**: 5 sorries removed from live build path (1647 -> 1644 build jobs)

### Phase 2: Fix Stale Docstrings in Bundle/ Files
- `FMCSDef.lean`: Replaced TimelineQuot/SuccChainFMCS references with current BXCanonical and Chronicle implementations
- `TemporalContent.lean`: Removed references to TemporalCoherentConstruction.lean, DovetailingChain.lean, and DenseTask; updated f_content/p_content/u_content/s_content usage comments
- `TemporalCoherence.lean`: Replaced SuccChainFMCS comparison and extraction provenance with BXCanonical references
- `Construction.lean`: Replaced 2 TemporalCoherentConstruction.lean references with BXCanonical paths
- `WitnessSeed.lean`: Removed DovetailingChain.lean extraction provenance
- `SuccRelation.lean`: Removed stale task number references (tasks 10-15); described role in current architecture

### Phase 3: Fix Ghost File References in Algebraic/
- `ParametricCanonical.lean`: Replaced 2 CanonicalConstruction.lean references with Bundle/CanonicalFrame.lean and Bundle/CanonicalTaskRelation.lean
- `ParametricTruthLemma.lean`: Replaced 2 CanonicalConstruction.lean references with Bundle/FMCS.lean and Bundle/CanonicalFrame.lean
- `ParametricHistory.lean`: Replaced 1 CanonicalConstruction.lean reference with Bundle/CanonicalFrame.lean

### Phase 4: Update README Files
- `Metalogic/README.md`: Updated module tree with actual Bundle/ files (15 files), added BXCanonical/WeakCanonical/Algebraic parametric modules, replaced phantom subdirectory entries (Soundness/, Canonical/, Domain/, StagedConstruction/, Representation/, Compactness/) with actual directories (Core, Bundle, BXCanonical, WeakCanonical, Decidability, Algebraic, ConservativeExtension, Relational), fixed AlgebraicRepresentation -> AlgebraicCompleteness in dependency diagrams
- `Bundle/README.md`: Replaced architecture tree with actual 15-file inventory, updated theorem table (CanonicalFrame/CanonicalTaskRelation instead of CanonicalConstruction/CanonicalFMCS), fixed import snippet

## Plan Deviations

- Phase 1 Task 1.4: Altered -- used file-specific tombstone comments for TenseS5Algebra and UltrafilterFrame instead of identical text, since the two files have different sorry profiles and provenance
- Phase 1 Task 1.8: Extended -- also fixed AlgebraicRepresentation -> AlgebraicCompleteness rename and ParametricRepresentation -> ParametricCompleteness in Algebraic/README.md (additional stale names found during implementation)

## Verification

- `lake build` passes (1644 jobs)
- No active imports of TenseS5Algebra or UltrafilterFrame in Metalogic/
- No CanonicalConstruction.lean references in active code
- Boneyard/UltrafilterFrame/ contains both archived files with tombstone comments
- Boneyard/README.md has entry for UltrafilterFrame archival

## Files Modified

### Moved to Boneyard
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` -> `Theories/Bimodal/Boneyard/UltrafilterFrame/TenseS5Algebra.lean`
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterFrame.lean` -> `Theories/Bimodal/Boneyard/UltrafilterFrame/UltrafilterFrame.lean`

### Modified
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean`
- `Theories/Bimodal/Metalogic/Algebraic/README.md`
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean`
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
- `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean`
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`
- `Theories/Bimodal/Metalogic/README.md`
- `Theories/Bimodal/Metalogic/Bundle/README.md`
- `Theories/Bimodal/Boneyard/README.md`
