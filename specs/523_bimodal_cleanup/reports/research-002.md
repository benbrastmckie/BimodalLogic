# Research Report: Task #523 (Revision 2)

**Task**: 523 - Clean Up Bimodal Lean Source Files After Task 505
**Date**: 2026-01-17
**Focus**: Investigate the extent to which task 505 was completed and identify cleanup opportunities
**Session ID**: sess_1768656756_fec1d9

## Summary

Task 505's "Representation First" restructuring was successfully implemented. The new modular directory structure exists with Core/, Soundness/, Representation/, Completeness/, and Applications/ directories. However, significant cleanup opportunities remain: historical commentary should be removed, deprecated code in the main files should be moved to Boneyard, documentation should be updated to reflect the current state, and the Metalogic/README.md is empty.

## Findings

### 1. Task 505 Implementation Status: COMPLETED

**Contrary to research-001.md**, task 505 was fully implemented. Evidence:

#### New Directory Structure Created
```
Theories/Bimodal/Metalogic/
├── Core/
│   ├── Basic.lean (78 lines) - Consistency, validity definitions
│   └── Provability.lean - Context-based provability
├── Soundness/
│   ├── Soundness.lean (670 lines) - Main soundness theorem
│   └── SoundnessLemmas.lean (932 lines) - Supporting lemmas
├── Representation/
│   ├── CanonicalModel.lean (231 lines) - MCS, canonical frame/model
│   ├── TruthLemma.lean (134 lines) - Truth lemma details
│   ├── RepresentationTheorem.lean (135 lines) - Main representation theorem
│   ├── FiniteModelProperty.lean - FMP bridge
│   └── ContextProvability.lean - Context provability infrastructure
├── Completeness/
│   ├── CompletenessTheorem.lean - Derives completeness from representation
│   └── FiniteCanonicalModel.lean (4288 lines) - Finite model construction
├── Applications/
│   └── Compactness.lean - Compactness theorem
└── Decidability/ (existing)
    └── [6 submodules]
```

#### Implementation Summary Confirms Completion
From `specs/505_bimodal_metalogic_restructuring/summaries/implementation-summary-20260116.md`:
> "Implemented core infrastructure for Representation First architecture... Created Core/Basic.lean with consistency, validity, and maximal consistent set definitions... Established Representation/ directory..."

### 2. Current Sorry Gap Analysis

Total sorry gaps by file in Metalogic:

| File | Sorry Count | Classification |
|------|-------------|----------------|
| Completeness.lean | 39 | Legacy/deprecated infrastructure |
| FiniteCanonicalModel.lean | 69 | Mixed: semantic (proven) + syntactic (deprecated) |
| Compactness.lean | 8 | Scaffolding |
| CompletenessTheorem.lean | 4 | Bridge gaps |
| CanonicalModel.lean | 13 | Scaffolding |
| TruthLemma.lean | 7 | Scaffolding |
| RepresentationTheorem.lean | 6 | Scaffolding |
| FiniteModelProperty.lean | 6 | Scaffolding |
| Decidability/* | 6 | Known limitations |
| Core/Basic.lean | 1 | Minor |
| Core/Provability.lean | 1 | Minor |
| SoundnessLemmas.lean | 1 | Minor |
| **Total** | ~161 | |

**Key Finding**: The semantic approach in FiniteCanonicalModel.lean (`semantic_truth_lemma_v2`, `semantic_weak_completeness`) is PROVEN with no sorries. The sorries are in deprecated/scaffolding code.

### 3. Historical Commentary to Clean Up

FiniteCanonicalModel.lean contains extensive historical commentary that should be cleaned up:

#### Task References (Should be removed or minimized)
- Line 39: "Introduced in Task 473"
- Line 60: "Task 450 will formally connect these"
- Line 95: "* Task 473: SemanticWorldState architecture"
- Line 3424: "Task 450 will address the formal connection"
- Line 3748: "Task 472 (Lindenbaum extension)"
- Line 3754: "before Task 473 introduced"
- Line 4198: "Task 450, Phase 5"

#### Deprecated Approach Documentation (Should be moved to Boneyard)
- Lines 25-35: "Syntactic Approach (Original, DEPRECATED)"
- Lines 79-83: "Phase 2-4" syntactic approach documentation
- Lines 1303-1306: "Compositionality Status" with sorries
- Lines 3742-3748: "AUXILIARY / DEPRECATED" truth lemma
- Lines 4213-4260: "Category 1: Syntactic Approach (DEPRECATED)"

#### Phase Commentary (Excessive detail)
The file has extensive phase-by-phase documentation that reads like development log rather than clean documentation. Phases 1-7 are documented with status markers and historical notes.

### 4. Files Requiring Cleanup

#### 4.1 FiniteCanonicalModel.lean (4288 lines)
**Issues**:
- Contains both deprecated syntactic approach AND proven semantic approach
- Extensive historical commentary and task references
- Status markers throughout ("**Status**: DEPRECATED", "**Status**: PROVEN")
- Phase-by-phase structure with development history

**Recommendation**:
- Extract deprecated syntactic approach (roughly lines 800-1900 covering `FiniteWorldState`, `finite_task_rel`, `finite_truth_lemma`) to Boneyard
- Clean up documentation to present only the semantic approach
- Remove historical commentary and task references
- Keep mathematical documentation but remove development history

#### 4.2 Completeness.lean (3719 lines)
**Issues**:
- Contains Duration-based approach (15+ sorries) that is deprecated
- Overlaps with FiniteCanonicalModel.lean functionality
- Historical commentary about approach decisions

**Recommendation**:
- Move Duration-based construction to Boneyard/DurationConstruction.lean (partially done)
- Consolidate remaining useful definitions with Representation/
- Consider significant reduction in file size

#### 4.3 Metalogic/README.md (0 lines - EMPTY)
**Issue**: README is completely empty
**Recommendation**: Create comprehensive documentation describing:
- The Representation First architecture
- Module hierarchy (Core -> Soundness -> Representation -> Completeness/Decidability)
- Key theorems in each submodule
- Current implementation status

#### 4.4 Main README.md (329 lines)
**Issue**: Describes "clean" architecture but doesn't reflect new Representation/ structure
**Recommendation**: Update Submodules section to include:
- Core/ with Basic.lean and Provability.lean
- Representation/ with CanonicalModel, TruthLemma, RepresentationTheorem
- Applications/ with Compactness

#### 4.5 Boneyard/README.md
**Status**: Well-documented but may need updates for newly deprecated code

### 5. Documentation Update Needs

#### Bimodal/README.md Updates Needed
The README lists metalogic components but doesn't mention:
- Core/Basic.lean, Core/Provability.lean
- Representation/*.lean (CanonicalModel, TruthLemma, RepresentationTheorem, FMP)
- Applications/Compactness.lean

#### LaTeX Documentation
BimodalReference.tex may need updates to reflect the Representation First architecture.

### 6. Specific Cleanup Tasks

#### Phase 1: File Restructuring (3-4 hours)
1. Move syntactic approach from FiniteCanonicalModel.lean to Boneyard
2. Evaluate Completeness.lean for consolidation/deprecation
3. Create Metalogic/README.md

#### Phase 2: Commentary Cleanup (2-3 hours)
1. Remove task references from all Lean files
2. Remove "**Status**:" markers throughout
3. Remove phase-by-phase development history
4. Convert historical documentation to clean mathematical presentation

#### Phase 3: Documentation Updates (2-3 hours)
1. Update Bimodal/README.md with new architecture
2. Create Metalogic/README.md
3. Update Boneyard/README.md if needed
4. Review BimodalReference.tex for consistency

#### Phase 4: Verification (1-2 hours)
1. Run `lake build` to verify all changes compile
2. Verify imports work correctly
3. Update any broken references

## Recommendations

### 1. Immediate Priority: FiniteCanonicalModel.lean Cleanup

The largest cleanup opportunity is in FiniteCanonicalModel.lean (4288 lines):

**Actions**:
1. Extract lines ~800-1900 (syntactic approach) to `Boneyard/SyntacticFiniteCanonicalModel.lean`
2. Remove extensive historical commentary (reduce ~200 lines of comments)
3. Keep only semantic approach documentation
4. Estimated reduction: 1500-2000 lines

### 2. Second Priority: Documentation

**Actions**:
1. Create comprehensive Metalogic/README.md (50-100 lines)
2. Update Bimodal/README.md Submodules section
3. Ensure documentation presents current state, not development history

### 3. Third Priority: Completeness.lean Consolidation

**Actions**:
1. Evaluate what from Completeness.lean is still needed vs what's in Representation/
2. Move remaining deprecated code to Boneyard
3. Consider if Completeness.lean can be significantly reduced or eliminated

### 4. Long-term: Fill Remaining Sorries

The scaffolding sorries in Representation/*.lean and Applications/Compactness.lean are legitimate gaps that could be addressed in future tasks. These are not cleanup issues but implementation gaps.

## Code Quality Observations

### Strengths
1. Modular architecture correctly implemented
2. Semantic approach (the working code) is well-structured
3. Boneyard organization is good
4. Clear separation of concerns in new directories

### Weaknesses
1. Historical commentary mixed with code documentation
2. Development history embedded in source files
3. Empty README for key directory
4. Main README outdated

## Estimated Cleanup Effort

| Phase | Effort | Priority |
|-------|--------|----------|
| File restructuring | 3-4 hours | High |
| Commentary cleanup | 2-3 hours | High |
| Documentation updates | 2-3 hours | Medium |
| Verification | 1-2 hours | High |
| **Total** | **8-12 hours** | |

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking imports | Medium | Careful grep for all import statements |
| Losing useful code | Low | Move to Boneyard, don't delete |
| Documentation drift | Low | Update all docs in same phase |

## Conclusion

Task 505 was successfully implemented, creating the new modular architecture. Task 523's cleanup work is now appropriate and focuses on:

1. **Extracting deprecated code** from FiniteCanonicalModel.lean to Boneyard
2. **Removing historical commentary** and task references from source files
3. **Updating documentation** to accurately reflect the cleaned-up state

The primary cleanup target is FiniteCanonicalModel.lean, which contains both the working semantic approach and the deprecated syntactic approach. Separating these and cleaning up the documentation will significantly improve code clarity.

## References

- `specs/505_bimodal_metalogic_restructuring/summaries/implementation-summary-20260116.md`
- `Theories/Bimodal/Boneyard/README.md`
- `specs/523_bimodal_cleanup_research/reports/research-001.md` (superseded by this report)

## Next Steps

Run `/plan 523` to create implementation plan for cleanup activities.
