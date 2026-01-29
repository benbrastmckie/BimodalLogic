# Research Report: Task #731

**Task**: 731 - Clean Bimodal documentation - remove historical comments
**Date**: 2026-01-29
**Focus**: Identify historical comments to remove, provenance comments to preserve, and Boneyard isolation status

## Summary

The Bimodal codebase contains several categories of comments that need attention:
1. **Provenance comments** (`-- Origin: Boneyard/...`) that must be PRESERVED
2. **SUPERSEDED markers** in active code documenting deprecated approaches
3. **TODO/FIXME markers** indicating incomplete work
4. **Historical narrative comments** explaining past approaches
5. **Remaining Boneyard imports** outside the Boneyard directory

Task 726 successfully moved MCS lemmas to Core with provenance comments. The focus now is cleaning narrative history while preserving code lineage.

## Findings

### 1. Provenance Comments (PRESERVE)

Task 726 added provenance comments to track code origins. These are valuable metadata and should be **preserved**.

**Location**: `Theories/Bimodal/Metalogic/Core/`
- `DeductionTheorem.lean`: 12 provenance comments (`-- Origin: Boneyard/Metalogic_v2/Core/DeductionTheorem.lean`)
- `MCSProperties.lean`: 8 provenance comments (`-- Origin: Boneyard/Metalogic/Completeness.lean (line ~NNN)`)

**Rationale for preservation**: These comments enable future developers to trace code lineage when debugging or extending functionality.

### 2. SUPERSEDED/DEPRECATED Markers (EVALUATE)

Active (non-Boneyard) files with superseded/deprecated markers:

| File | Marker | Action |
|------|--------|--------|
| `Metalogic/Representation/IndexedMCSFamily.lean:583-599` | SUPERSEDED CONSTRUCTION docblock | Keep - documents API migration |
| `Metalogic/Representation/IndexedMCSFamily.lean:634-655` | `-- SUPERSEDED by CoherentConstruction.lean` | Keep - explains sorry rationale |
| `Automation/AesopRules.lean:39` | `-- DEPRECATED: tm_auto no longer uses Aesop` | Keep - user-facing migration guide |
| `Theorems/Propositional.lean:377` | `@[deprecated efq_neg (since := "2025-12-14")]` | Keep - Lean 4 deprecation attribute |
| `Metalogic.lean:12` | `# DEPRECATED: Bimodal.Metalogic` | **MOVE** - re-export file belongs in Boneyard |
| `Metalogic_v2.lean:12` | `# DEPRECATED: Bimodal.Metalogic_v2` | **MOVE** - re-export file belongs in Boneyard |

**Key finding**: `Metalogic.lean` and `Metalogic_v2.lean` are compatibility shims that re-export from Boneyard. These files should be moved INTO `Boneyard/` as they serve only historical compatibility purposes.

### 3. Remaining Boneyard Imports (ISOLATE)

Files outside `Boneyard/` with Boneyard imports:

| File | Import | Status |
|------|--------|--------|
| `Metalogic/Core/MaximalConsistent.lean` | `Bimodal.Boneyard.Metalogic_v2.Core.MaximalConsistent` | **Re-export** - intentional design |
| `Theorems/GeneralizedNecessitation.lean` | `Bimodal.Boneyard.Metalogic_v2.Core.DeductionTheorem` | **Should use Core** |
| `Theorems/Propositional.lean` | `Bimodal.Boneyard.Metalogic_v2.Core.DeductionTheorem` | **Should use Core** |
| `Examples/Demo.lean` | Multiple Boneyard imports | **Demo file** - acceptable |

**Action required**: Update `GeneralizedNecessitation.lean` and `Propositional.lean` to import from `Bimodal.Metalogic.Core.DeductionTheorem` instead of Boneyard.

### 4. Historical Narrative Comments (REVIEW)

Comments explaining "why we did X instead of Y" found in active files:

| Location | Comment Type | Recommendation |
|----------|--------------|----------------|
| `CoherentConstruction.lean:16-22` | Design philosophy explaining flawed approach | Keep - architectural documentation |
| `IndexedMCSFamily.lean:589-595` | Why approach fails | Keep - critical for understanding |
| `Metalogic/README.md:124-129` | Why deprecated | Keep in README |

**Finding**: Most "historical" comments in active code serve as **architectural documentation** explaining why certain design decisions were made. These should be preserved as they prevent repeating past mistakes.

### 5. TODO/FIXME Markers (TRACK)

Active TODO items found in non-Boneyard code:

| File | Line | Content |
|------|------|---------|
| `Examples/BimodalProofs.lean:3,43` | TODO: Re-enable when Task 260 is unblocked |
| `Examples/ModalProofs.lean:5,60` | TODO: Re-enable when Task 260 is unblocked |
| `Examples/TemporalProofs.lean:4,70` | TODO: Re-enable when Task 260 is unblocked |
| `Metalogic/Representation/CanonicalWorld.lean:116,163` | TODO: Complete proof |

**Action**: These are legitimate TODOs for future work, not historical artifacts to remove.

### 6. Comment Categories Summary

| Category | Count | Action |
|----------|-------|--------|
| Provenance (`-- Origin:`) | ~20 | PRESERVE |
| SUPERSEDED (active code) | ~8 | PRESERVE (most are API guidance) |
| Compatibility shims | 2 files | MOVE to Boneyard |
| Boneyard imports (fixable) | 2 files | UPDATE to Core |
| Historical narrative | ~10 | PRESERVE (architectural docs) |
| Active TODOs | ~6 | TRACK (not historical) |

## Recommendations

### Phase 1: Update Boneyard Imports (High Priority)
1. Change `Theorems/GeneralizedNecessitation.lean` to import `Bimodal.Metalogic.Core.DeductionTheorem`
2. Change `Theorems/Propositional.lean` to import `Bimodal.Metalogic.Core.DeductionTheorem`
3. Verify `lake build` passes

### Phase 2: Move Compatibility Shims (Medium Priority)
1. Move `Metalogic.lean` to `Boneyard/Compat/Metalogic.lean`
2. Move `Metalogic_v2.lean` to `Boneyard/Compat/Metalogic_v2.lean`
3. Update any external references (if any)

### Phase 3: Documentation Cleanup (Low Priority)
1. Review README files in `Metalogic/` directories
2. Consolidate deprecation notices into `Boneyard/README.md`
3. Remove redundant "DEPRECATED" notices from moved shim files

### Phase 4: Verify Isolation (Validation)
1. Run `grep -r "Boneyard" Theories/Bimodal --include="*.lean" | grep -v "Boneyard/"` and verify only acceptable imports remain
2. Verify no historical comments about "old approach" or "previous attempt" exist in active documentation

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking import changes | High | Run `lake build` after each change |
| Removing useful documentation | Medium | Preserve all architectural rationale |
| Incomplete Boneyard isolation | Low | Grep verification in Phase 4 |

## Dependencies

- **Completed**: Task 726 (MCS lemmas moved to Core)
- **Related**: Task 681 (referenced in CoherentConstruction.lean)
- **Related**: Task 260 (ProofSearch, blocked - TODO comments reference this)

## Appendix: File Inventory

### Files Requiring Changes
1. `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` - import update
2. `Theories/Bimodal/Theorems/Propositional.lean` - import update
3. `Theories/Bimodal/Metalogic.lean` - move to Boneyard
4. `Theories/Bimodal/Metalogic_v2.lean` - move to Boneyard

### Files With Preserved Historical Context
- `Metalogic/Core/DeductionTheorem.lean` - provenance comments
- `Metalogic/Core/MCSProperties.lean` - provenance comments
- `Metalogic/Representation/CoherentConstruction.lean` - design rationale
- `Metalogic/Representation/IndexedMCSFamily.lean` - SUPERSEDED documentation

### Acceptable Boneyard References
- `Metalogic/Core/MaximalConsistent.lean` - intentional re-export
- `Examples/Demo.lean` - demonstration file
