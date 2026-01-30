# Implementation Plan: Task #774 (Revised)

- **Task**: 774 - Restore representation theorem as under development
- **Version**: 002
- **Status**: [NOT STARTED]
- **Effort**: 4-5 hours (expanded scope)
- **Priority**: Medium
- **Dependencies**: Task 772 (archival) completed
- **Research Inputs**:
  - research-001.md (RepresentationTheorem analysis)
  - research-002.md (Expanded scope: Decidability, structure recommendations)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

**Changes from v001**:
- Renamed `NEW/` to `UnderDevelopment/` (clearer semantics)
- Added Decidability infrastructure restoration (8 files, 5 sorries)
- Expanded verification to cover both subdirectories
- Added import dependency validation between subdirectories

## Overview

Restore work-in-progress proof infrastructure from Boneyard to a new `Bimodal/Metalogic/UnderDevelopment/` directory structure with two subdirectories:

1. **RepresentationTheorem/** - Universal canonical model approach (17 sorries, ~2000 lines)
2. **Decidability/** - Tableau-based decision procedure (5 sorries, ~2900 lines)

Both subdirectories maintain import isolation from the main codebase while providing valuable alternative approaches for continued research and development.

### Research Integration

Key findings from research-002.md:
- Decidability infrastructure is HIGH PRIORITY for restoration (near-complete, constructive witnesses)
- `UnderDevelopment/` naming better conveys active development status than `NEW/`
- Two-subdirectory structure groups related approaches
- Examples restoration deferred to separate task

## Goals & Non-Goals

**Goals**:
- Create `Bimodal/Metalogic/UnderDevelopment/` directory structure with logical subdirectory organization
- Restore 7 RepresentationTheorem files with updated imports and namespaces
- Restore 8 Decidability files with updated imports and namespaces
- Ensure UnderDevelopment/ subdirectories can import FROM elsewhere in the project
- Ensure NOTHING outside UnderDevelopment/ can import from UnderDevelopment/ subdirectories
- Create clear README documentation explaining sorry status and future development paths
- Enable `lake build` to succeed without compiling UnderDevelopment/ (commented imports in root)

**Non-Goals**:
- Fix or reduce the sorries (22 total: 17 + 5)
- Create new proof approaches (future tasks)
- Modify the existing sorry-free completeness path (FMP/SemanticCanonicalModel.lean)
- Remove files from Boneyard (keep for historical reference)
- Restore Examples/Exercises (separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import cycle introduced | High | Low | Test imports carefully; UnderDevelopment/ only imports outward |
| Build breakage | Medium | Low | Root imports commented; isolated testing |
| Namespace conflicts | Medium | Low | Use unique namespace prefix `Bimodal.Metalogic.UnderDevelopment` |
| Cross-subdirectory dependency | Medium | Medium | Validate Decidability and RepresentationTheorem are independent |
| Documentation confusion | Medium | Medium | Clear README with sorry status and rationale |

## Implementation Phases

### Phase 1: Create UnderDevelopment/ Directory Structure [NOT STARTED]

**Goal**: Establish the directory skeleton with appropriate subdirectory organization

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/UnderDevelopment/` directory
- [ ] Create `Theories/Bimodal/Metalogic/UnderDevelopment/RepresentationTheorem/` subdirectory
- [ ] Create `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/` subdirectory
- [ ] Create placeholder `UnderDevelopment.lean` root module file (imports commented)
- [ ] Create placeholder `RepresentationTheorem/RepresentationTheorem.lean` root module
- [ ] Create placeholder `Decidability/Decidability.lean` root module

**Timing**: 25 minutes

**Files to create**:
- `Theories/Bimodal/Metalogic/UnderDevelopment/` (directory)
- `Theories/Bimodal/Metalogic/UnderDevelopment/RepresentationTheorem/` (directory)
- `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/` (directory)
- `Theories/Bimodal/Metalogic/UnderDevelopment/UnderDevelopment.lean` (root module, commented imports)
- `Theories/Bimodal/Metalogic/UnderDevelopment/RepresentationTheorem/RepresentationTheorem.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/Decidability.lean`

**Verification**:
- Directories exist
- `lake build` succeeds (UnderDevelopment/ not imported)

---

### Phase 2: Restore RepresentationTheorem Core Files [NOT STARTED]

**Goal**: Copy and adapt the foundational RepresentationTheorem files (TaskRelation, CoherentConstruction, CanonicalHistory)

**Tasks**:
- [ ] Copy `TaskRelation.lean` from `Boneyard/Metalogic_v4/` to `UnderDevelopment/RepresentationTheorem/`
- [ ] Update namespace to `Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem`
- [ ] Update internal imports to use `Bimodal.Metalogic.Representation.*` for shared definitions
- [ ] Replace "ARCHIVED" header with "UNDER DEVELOPMENT" status
- [ ] Copy `CoherentConstruction.lean` with same updates
- [ ] Copy `CanonicalHistory.lean` with same updates (0 sorries, depends on TaskRelation)

**Timing**: 45 minutes

**Source files** (from `Theories/Bimodal/Boneyard/Metalogic_v4/`):
- `TaskRelation.lean` (5 sorries)
- `CoherentConstruction.lean` (8 sorries)
- `CanonicalHistory.lean` (0 sorries)

**Files to create**:
- `Theories/Bimodal/Metalogic/UnderDevelopment/RepresentationTheorem/TaskRelation.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/RepresentationTheorem/CoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/RepresentationTheorem/CanonicalHistory.lean`

**Verification**:
- Each file compiles independently (may have expected sorries)
- Namespaces are correct (`Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem.*`)
- No imports from outside UnderDevelopment/ directory point into UnderDevelopment/

---

### Phase 3: Restore RepresentationTheorem Truth Lemma and Model [NOT STARTED]

**Goal**: Copy and adapt the truth lemma, universal model, and top-level theorem files

**Tasks**:
- [ ] Copy `TruthLemma.lean` to `UnderDevelopment/RepresentationTheorem/`
- [ ] Update namespace and imports
- [ ] Replace "ARCHIVED" header with "UNDER DEVELOPMENT" status
- [ ] Copy `UniversalCanonicalModel.lean` with same updates (0 sorries)
- [ ] Copy `InfinitaryStrongCompleteness.lean` with same updates
- [ ] Copy `Compactness.lean` with same updates
- [ ] Update `RepresentationTheorem.lean` root module to import all files (commented for now)

**Timing**: 40 minutes

**Source files** (from `Theories/Bimodal/Boneyard/Metalogic_v4/`):
- `TruthLemma.lean` (4 sorries)
- `UniversalCanonicalModel.lean` (0 sorries)
- `InfinitaryStrongCompleteness.lean` (0 sorries)
- `Compactness.lean` (0 sorries)

**Files to create**:
- `Theories/Bimodal/Metalogic/UnderDevelopment/RepresentationTheorem/TruthLemma.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/RepresentationTheorem/UniversalCanonicalModel.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/RepresentationTheorem/InfinitaryStrongCompleteness.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/RepresentationTheorem/Compactness.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/RepresentationTheorem/RepresentationTheorem.lean` (update)

**Verification**:
- All RepresentationTheorem files compile with expected sorries
- Dependency chain is correct (TruthLemma imports CanonicalHistory)
- Total sorry count: 17 (matches research-001)

---

### Phase 4: Restore Decidability Infrastructure [NOT STARTED]

**Goal**: Copy and adapt the tableau-based decision procedure files

**Tasks**:
- [ ] Copy `SignedFormula.lean` to `UnderDevelopment/Decidability/`
- [ ] Update namespace to `Bimodal.Metalogic.UnderDevelopment.Decidability`
- [ ] Update imports to use shared infrastructure from `Bimodal.Metalogic.*`
- [ ] Replace "ARCHIVED" header with "UNDER DEVELOPMENT" status
- [ ] Copy `Tableau.lean` with same updates
- [ ] Copy `Saturation.lean` with same updates
- [ ] Copy `Closure.lean` with same updates
- [ ] Copy `Correctness.lean` with same updates (2 sorries)
- [ ] Copy `ProofExtraction.lean` with same updates
- [ ] Copy `CountermodelExtraction.lean` with same updates
- [ ] Copy `DecisionProcedure.lean` with same updates (3 sorries)
- [ ] Update `Decidability.lean` root module to import all files (commented for now)

**Timing**: 60 minutes

**Source files** (from `Theories/Bimodal/Boneyard/Metalogic/Decidability/`):
- `SignedFormula.lean` (0 sorries)
- `Tableau.lean` (0 sorries)
- `Saturation.lean` (0 sorries)
- `Closure.lean` (0 sorries)
- `Correctness.lean` (2 sorries)
- `ProofExtraction.lean` (0 sorries)
- `CountermodelExtraction.lean` (0 sorries)
- `DecisionProcedure.lean` (3 sorries)

**Files to create**:
- `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/SignedFormula.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/Tableau.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/Saturation.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/Closure.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/Correctness.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/ProofExtraction.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/CountermodelExtraction.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/DecisionProcedure.lean`
- `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/Decidability.lean` (update)

**Verification**:
- All Decidability files compile with expected sorries
- Total sorry count: 5 (matches research-002)
- No cross-dependencies between Decidability and RepresentationTheorem

---

### Phase 5: Create Documentation and Import Isolation [NOT STARTED]

**Goal**: Document the UnderDevelopment/ structure, enforce import isolation, and update main Metalogic

**Tasks**:
- [ ] Create `UnderDevelopment/README.md` explaining the purpose and import isolation rules
- [ ] Create `UnderDevelopment/RepresentationTheorem/README.md` with sorry table and development notes
- [ ] Create `UnderDevelopment/Decidability/README.md` with sorry table and development notes
- [ ] Update `Metalogic/Metalogic.lean` to document UnderDevelopment/ existence (import remains commented)
- [ ] Update `Metalogic/README.md` to reference UnderDevelopment/ directory
- [ ] Verify no existing files import from UnderDevelopment/

**Timing**: 40 minutes

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/UnderDevelopment/README.md` (NEW)
- `Theories/Bimodal/Metalogic/UnderDevelopment/RepresentationTheorem/README.md` (NEW)
- `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/README.md` (NEW)
- `Theories/Bimodal/Metalogic/Metalogic.lean` (add comment about UnderDevelopment/)
- `Theories/Bimodal/Metalogic/README.md` (update)

**README Content Requirements**:

**UnderDevelopment/README.md**:
- Overview of "under development" concept
- List of subdirectories with sorry counts
- Import isolation rules
- Development guidelines for contributors

**RepresentationTheorem/README.md**:
- Universal canonical model approach explanation
- Sorry table: file, count, nature, status
- Research history references (Task 750, Task 772)
- Future development paths

**Decidability/README.md**:
- Tableau-based decision procedure explanation
- Sorry table: file, count, nature, status
- Integration potential (automation tactics)
- Future development paths

**Verification**:
- `grep -r "import.*UnderDevelopment" Theories/` shows only internal UnderDevelopment/ imports
- Documentation clearly explains sorry status and isolation rules
- Main `lake build` succeeds without touching UnderDevelopment/

---

### Phase 6: Verification and Build Testing [NOT STARTED]

**Goal**: Ensure the complete setup works and is isolated

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem.TaskRelation` (expect sorries)
- [ ] Run `lake build Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem.TruthLemma` (expect sorries)
- [ ] Run `lake build Bimodal.Metalogic.UnderDevelopment.Decidability.DecisionProcedure` (expect sorries)
- [ ] Run `lake build` (full build, UnderDevelopment/ should NOT be compiled)
- [ ] Verify sorry count in RepresentationTheorem/ is 17
- [ ] Verify sorry count in Decidability/ is 5
- [ ] Verify no cross-imports between subdirectories
- [ ] Create implementation summary

**Timing**: 30 minutes

**Files to create**:
- `specs/774_restore_representation_theorem_as_under_development/summaries/implementation-summary-YYYYMMDD.md`

**Verification**:
- Individual UnderDevelopment/ modules compile with expected sorries
- Main build excludes UnderDevelopment/ entirely
- Total sorry count: 22 (17 + 5)
- Subdirectories are mutually independent

## Testing & Validation

- [ ] `lake build` succeeds without compiling UnderDevelopment/
- [ ] Individual UnderDevelopment/ modules compile when built explicitly
- [ ] `grep -r "import.*Metalogic.UnderDevelopment" Theories/` shows only internal imports within UnderDevelopment/
- [ ] Sorry count in RepresentationTheorem/ is exactly 17
- [ ] Sorry count in Decidability/ is exactly 5
- [ ] All README files explain the sorry status and isolation rules
- [ ] Namespace is `Bimodal.Metalogic.UnderDevelopment.{RepresentationTheorem,Decidability}.*`
- [ ] No cross-dependencies between RepresentationTheorem and Decidability

## Artifacts & Outputs

**Directory Structure**:
```
Theories/Bimodal/Metalogic/UnderDevelopment/
├── UnderDevelopment.lean          # Root module (commented imports)
├── README.md                      # Overview of all under-development work
├── RepresentationTheorem/         # From Boneyard/Metalogic_v4/
│   ├── RepresentationTheorem.lean
│   ├── TaskRelation.lean
│   ├── CoherentConstruction.lean
│   ├── CanonicalHistory.lean
│   ├── TruthLemma.lean
│   ├── UniversalCanonicalModel.lean
│   ├── InfinitaryStrongCompleteness.lean
│   ├── Compactness.lean
│   └── README.md
└── Decidability/                  # From Boneyard/Metalogic/Decidability/
    ├── Decidability.lean
    ├── SignedFormula.lean
    ├── Tableau.lean
    ├── Saturation.lean
    ├── Closure.lean
    ├── Correctness.lean
    ├── ProofExtraction.lean
    ├── CountermodelExtraction.lean
    ├── DecisionProcedure.lean
    └── README.md
```

**Files Summary**:
- 15 Lean source files (7 RepresentationTheorem + 8 Decidability)
- 2 root module files (UnderDevelopment.lean, plus 2 subdirectory roots)
- 3 README.md files
- 2 updated existing files (Metalogic.lean, Metalogic/README.md)
- 1 implementation summary

## Rollback/Contingency

If implementation causes unexpected issues:
1. Delete `Theories/Bimodal/Metalogic/UnderDevelopment/` directory entirely
2. Revert changes to `Metalogic.lean` and `README.md`
3. The original files remain in Boneyard for reference:
   - `Boneyard/Metalogic_v4/` (RepresentationTheorem)
   - `Boneyard/Metalogic/Decidability/` (Decidability)
4. No impact on existing sorry-free completeness path

The isolation design (commented imports) means rollback is trivial and has no downstream effects.

## Future Tasks (Out of Scope)

1. **Examples/Exercises restoration** - Separate task to restore pedagogical exercises
2. **Complete Decidability sorries** - Fill in the 5 remaining sorries for full automation
3. **Complete RepresentationTheorem sorries** - Address architectural limitations if possible
4. **Automation integration** - Connect Decidability to tactic framework
