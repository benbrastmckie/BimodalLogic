# Implementation Plan: Task #836

- **Task**: 836 - improve_metalogic_readme_documentation
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/836_improve_metalogic_readme_documentation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Improve documentation for `Theories/Bimodal/Metalogic/README.md` and all subdirectory READMEs to accurately reflect the codebase state, include comprehensive dependency flowcharts, and provide exhaustive module summaries. Research identified key inaccuracies including references to non-existent directories, mislocated Soundness files, and outdated sorry counts.

### Research Integration

Key findings from research-001.md:
- Main README references non-existent `UnderDevelopment/` directory
- Soundness.lean and SoundnessLemmas.lean are at top-level, not in Soundness/
- Actual sorry count is 4 (in TruthLemma.lean, Construction.lean, FMP/Closure.lean)
- Soundness/README.md documents files not in its directory (major issue)
- All 8 subdirectories have READMEs but need accuracy updates

## Goals & Non-Goals

**Goals**:
- Fix all inaccuracies in main Metalogic/README.md
- Add comprehensive dependency flowchart showing all modules
- Update subdirectory summaries with links to their READMEs
- Fix Soundness/README.md to accurately describe its role
- Add cross-links between all READMEs
- Verify all documentation against actual code

**Non-Goals**:
- Modifying Lean source code
- Changing file organization (e.g., moving Soundness.lean into Soundness/)
- Creating new directories or modules
- Documenting code that doesn't exist yet

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| README changes outdated by code changes | M | L | Include verification commands in docs |
| Flowchart too complex to maintain | M | M | Use ASCII art with clear layer structure |
| Sorry count becomes stale | M | H | Include grep command for verification |
| Missing cross-links | L | M | Systematic review of all README files |

## Implementation Phases

### Phase 1: Fix Main README Critical Issues [NOT STARTED]

**Goal**: Fix inaccuracies in Metalogic/README.md identified by research

**Tasks**:
- [ ] Remove reference to non-existent `UnderDevelopment/` directory
- [ ] Fix Architecture Overview to show Soundness files at top-level
- [ ] Update sorry status table with accurate count (4 sorries in 3 files)
- [ ] Add list of top-level .lean files (Metalogic.lean, Soundness.lean, SoundnessLemmas.lean, Completeness.lean, Decidability.lean)
- [ ] Verify all directory references exist

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md` - Fix inaccuracies

**Verification**:
- All referenced directories exist
- Sorry count matches grep result
- No reference to UnderDevelopment/

---

### Phase 2: Add Comprehensive Dependency Flowchart [NOT STARTED]

**Goal**: Create detailed ASCII dependency flowchart showing all module relationships

**Tasks**:
- [ ] Create main flowchart showing Metalogic.lean as entry point
- [ ] Add Core/ dependency tree (DeductionTheorem -> MCSProperties -> MaximalConsistent -> Core.lean)
- [ ] Add Bundle/ dependency tree (IndexedMCSFamily -> BMCS -> BMCSTruth -> TruthLemma -> Construction -> Completeness)
- [ ] Add FMP/ dependency tree (Closure, BoundedTime -> FiniteWorldState -> SemanticCanonicalModel)
- [ ] Add Decidability/ dependency tree (SignedFormula -> Tableau -> Closure -> Saturation -> ProofExtraction/CountermodelExtraction -> DecisionProcedure -> Correctness)
- [ ] Add Algebraic/ dependency tree (LindenbaumQuotient -> BooleanStructure -> InteriorOperators -> UltrafilterMCS -> AlgebraicRepresentation)
- [ ] Show cross-module dependencies (Core -> Bundle, FMP, Algebraic)
- [ ] Add section explaining how to read the flowchart

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md` - Add dependency flowchart section

**Verification**:
- Flowchart matches actual import statements
- All modules represented
- Direction of dependencies correct

---

### Phase 3: Update Subdirectory READMEs [NOT STARTED]

**Goal**: Review and update all subdirectory README files for accuracy and exhaustivity

**Tasks**:
- [ ] Core/README.md - Add cross-links to dependent directories (Bundle, FMP, Algebraic)
- [ ] Bundle/README.md - Verify file list, add import path recommendations
- [ ] FMP/README.md - Add detailed dependency flowchart
- [ ] Decidability/README.md - Add dependency flowchart
- [ ] Algebraic/README.md - Minor updates, verify accuracy
- [ ] Soundness/README.md - MAJOR REWRITE: clarify that Soundness.lean is at parent level, document conceptual grouping only
- [ ] Representation/README.md - Verify archived status accurate
- [ ] Compactness/README.md - Verify archived status accurate

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/README.md`
- `Theories/Bimodal/Metalogic/Bundle/README.md`
- `Theories/Bimodal/Metalogic/FMP/README.md`
- `Theories/Bimodal/Metalogic/Decidability/README.md`
- `Theories/Bimodal/Metalogic/Algebraic/README.md`
- `Theories/Bimodal/Metalogic/Soundness/README.md`
- `Theories/Bimodal/Metalogic/Representation/README.md`
- `Theories/Bimodal/Metalogic/Compactness/README.md`

**Verification**:
- Each README accurately describes its directory contents
- Cross-links to main README work
- Soundness/README clarifies file location issue

---

### Phase 4: Final Verification and Cross-linking [NOT STARTED]

**Goal**: Ensure all documentation is consistent, accurate, and properly cross-linked

**Tasks**:
- [ ] Add links from main README to each subdirectory README
- [ ] Add "Back to Metalogic README" link in each subdirectory README
- [ ] Verify representation theorem documentation (bmcs_representation in Bundle/Completeness.lean)
- [ ] Verify algebraic representation theorem location (Algebraic/AlgebraicRepresentation.lean)
- [ ] Run verification commands to confirm all claims match code
- [ ] Add "Last verified" timestamp with verification command

**Timing**: 30 minutes

**Files to modify**:
- All README files (cross-link additions)

**Verification**:
- All internal links work
- Main theorems properly documented
- Verification commands run successfully

---

## Testing & Validation

- [ ] Verify all directory references exist: `ls Theories/Bimodal/Metalogic/*/`
- [ ] Verify sorry count matches: `grep -r "sorry" Theories/Bimodal/Metalogic/ --include="*.lean" | wc -l`
- [ ] Verify representation theorem exists: `grep -n "bmcs_representation" Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
- [ ] Verify Soundness.lean location: `ls Theories/Bimodal/Metalogic/Soundness.lean`
- [ ] Check all README links are valid markdown references

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/README.md` - Updated main README
- `Theories/Bimodal/Metalogic/*/README.md` - Updated subdirectory READMEs (8 files)
- `specs/836_improve_metalogic_readme_documentation/plans/implementation-001.md` - This plan
- `specs/836_improve_metalogic_readme_documentation/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

## Rollback/Contingency

All changes are to markdown documentation files. To rollback:
1. Use `git checkout HEAD~1 -- Theories/Bimodal/Metalogic/README.md` to restore main README
2. Use `git checkout HEAD~1 -- Theories/Bimodal/Metalogic/*/README.md` to restore subdirectory READMEs
3. Alternatively, view git history for previous versions of each file
