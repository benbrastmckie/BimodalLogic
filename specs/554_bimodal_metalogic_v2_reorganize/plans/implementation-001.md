# Implementation Plan: Reorganize Bimodal/Metalogic to Use Representation Theorem as Foundation

- **Task**: 554 - bimodal_metalogic_v2_reorganize
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/554_bimodal_metalogic_v2_reorganize/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Create a new `Metalogic_v2/` directory with a representation-first architecture where the Finite Model Property (FMP) serves as the central bridge theorem. The current Metalogic/ has proven completeness via infinite canonical models but has a disconnected Representation/ layer with 9 sorries. This reorganization establishes a clean layered dependency: Core -> Representation -> FMP -> {Completeness, Decidability, Compactness}. The existing Metalogic/ remains unchanged for safety.

### Research Integration

Key findings from research-001.md:
- Duplicate definitions (SetConsistent, set_lindenbaum) exist in both Completeness.lean and Representation/CanonicalModel.lean
- Current Representation/ imports Completeness.lean (backwards from intended architecture)
- FMP is not connected to Decidability module
- DeductionTheorem.lean is at top level but should be in Core/
- 9 sorries in Representation layer are acceptable for initial structure (can fill later)

## Goals & Non-Goals

**Goals**:
- Create new `Theories/Bimodal/Metalogic_v2/` directory structure
- Establish layered architecture: Core -> Representation -> FMP -> Applications
- Consolidate duplicate MCS definitions into shared Core layer
- Make FMP the central bridge theorem for downstream results
- Preserve working proofs from original Metalogic/
- Enable future completion of Representation layer sorries

**Non-Goals**:
- Fill all 9 sorries in Representation layer (future work)
- Make FMP constructive with finite model bounds (future work)
- Modify existing Metalogic/ directory (preserve for comparison)
- Optimize proof performance

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import cycles break build | High | Medium | Strict layering: never import upward. Verify with lake build after each phase. |
| Broken working proofs | High | Low | Use new Metalogic_v2/ directory, preserve original Metalogic/ unchanged |
| Sorries propagate to applications | Medium | High | Accept sorries in Representation/, document as proof obligations. Applications use axiom-based imports. |
| Time overrun (>8 hours) | Medium | Medium | Phases are independent. Can pause after Phase 2 with partial structure. |
| DeductionTheorem move breaks imports | Medium | Medium | Update all import paths simultaneously. Use lake build for verification. |

## Implementation Phases

### Phase 1: Create Core Foundation Layer [COMPLETED]

**Goal**: Establish Core_v2/ with consolidated definitions extracted from Completeness.lean

**Tasks**:
- [ ] Create directory structure: `Theories/Bimodal/Metalogic_v2/Core/`
- [ ] Create `Core/Basic.lean` - Copy from Metalogic/Core/Basic.lean, update imports
- [ ] Create `Core/Provability.lean` - Copy from Metalogic/Core/Provability.lean
- [ ] Create `Core/DeductionTheorem.lean` - Move from Metalogic/DeductionTheorem.lean
- [ ] Create `Core/MaximalConsistent.lean` (NEW) - Extract from Completeness.lean:
  - SetConsistent definition
  - SetMaximalConsistent definition
  - ConsistentSupersets type
  - Chain consistency lemmas
  - set_lindenbaum theorem (Zorn-based proof)
- [ ] Verify compilation: `lake build Bimodal.Metalogic_v2.Core.MaximalConsistent`

**Timing**: 2-2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Core/Basic.lean` - Create (copy + update imports)
- `Theories/Bimodal/Metalogic_v2/Core/Provability.lean` - Create (copy + update imports)
- `Theories/Bimodal/Metalogic_v2/Core/DeductionTheorem.lean` - Create (move + update imports)
- `Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean` - Create (extract from Completeness.lean)

**Verification**:
- `lake build Bimodal.Metalogic_v2.Core` compiles without errors
- No import cycles detected
- set_lindenbaum theorem available for Representation layer

---

### Phase 2: Create Soundness Layer [COMPLETED]

**Goal**: Copy Soundness proofs to new structure with updated imports

**Tasks**:
- [ ] Create directory: `Theories/Bimodal/Metalogic_v2/Soundness/`
- [ ] Copy `Soundness.lean` with updated imports to Core_v2
- [ ] Copy `SoundnessLemmas.lean` with updated imports
- [ ] Verify compilation: `lake build Bimodal.Metalogic_v2.Soundness`

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Soundness/Soundness.lean` - Create
- `Theories/Bimodal/Metalogic_v2/Soundness/SoundnessLemmas.lean` - Create

**Verification**:
- `lake build Bimodal.Metalogic_v2.Soundness` compiles
- Soundness theorem proven (no sorries)

---

### Phase 3: Build Representation Layer [COMPLETED]

**Goal**: Create Representation_v2/ that depends only on Core_v2/, removing circular dependencies

**Tasks**:
- [ ] Create directory: `Theories/Bimodal/Metalogic_v2/Representation/`
- [ ] Copy `CanonicalModel.lean` with updates:
  - Remove `import Bimodal.Metalogic.Completeness`
  - Add `import Bimodal.Metalogic_v2.Core.MaximalConsistent`
  - Remove duplicate SetConsistent, SetMaximalConsistent definitions (use Core)
  - Remove duplicate set_lindenbaum (use Core)
  - Keep 2 sorries in chain consistency proofs
- [ ] Copy `TruthLemma.lean` with updated imports (keep 2 sorries)
- [ ] Copy `RepresentationTheorem.lean` with updated imports (keep 4 sorries)
- [ ] Copy `ContextProvability.lean` with updated imports (working, no sorries)
- [ ] Verify compilation: `lake build Bimodal.Metalogic_v2.Representation`

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - Create (major updates)
- `Theories/Bimodal/Metalogic_v2/Representation/TruthLemma.lean` - Create
- `Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean` - Create
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Create

**Verification**:
- `lake build Bimodal.Metalogic_v2.Representation` compiles
- 8 sorries total in Representation layer (expected)
- No imports from Completeness.lean (verify with grep)

---

### Phase 4: Create FMP Bridge Module [COMPLETED]

**Goal**: Make FiniteModelProperty.lean the central hub connecting Representation to Applications

**Tasks**:
- [ ] Copy `FiniteModelProperty.lean` to Representation/ with updated imports:
  - Import only from Representation layer and Core
  - Keep 1 sorry in subformulaList_finite bound proof
- [ ] Create `Metalogic_v2/FMP.lean` hub file that re-exports:
  - finite_model_property theorem
  - Satisfaction decidability (if available)
  - Exports for downstream use by Completeness, Decidability, Compactness
- [ ] Verify compilation: `lake build Bimodal.Metalogic_v2.FMP`

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` - Create
- `Theories/Bimodal/Metalogic_v2/FMP.lean` - Create (hub module)

**Verification**:
- `lake build Bimodal.Metalogic_v2.FMP` compiles
- FMP imports only Representation layer (verify dependency direction)
- Total 9 sorries in Representation layer (expected)

---

### Phase 5: Build Applications Layer [IN PROGRESS]

**Goal**: Create Completeness_v2, Decidability_v2, and Applications_v2 that import FMP

**Tasks**:
- [ ] Create `Metalogic_v2/Completeness/` directory
- [ ] Create `WeakCompleteness.lean`: Import FMP, prove valid -> provable
- [ ] Create `StrongCompleteness.lean`: Import FMP, prove semantic entailment -> provability
- [ ] Copy Decidability/ directory structure:
  - Update all imports to use Core_v2 and FMP
  - `SignedFormula.lean`, `Tableau.lean`, `Closure.lean`, `Saturation.lean`
  - `ProofExtraction.lean`, `CountermodelExtraction.lean`, `DecisionProcedure.lean`
  - Update `Correctness.lean` to import FMP for tableau_complete bound
- [ ] Create `Applications_v2/Compactness.lean`: Import FMP, use for finite satisfiability reduction
- [ ] Verify compilation: `lake build Bimodal.Metalogic_v2.Completeness`
- [ ] Verify compilation: `lake build Bimodal.Metalogic_v2.Decidability`
- [ ] Verify compilation: `lake build Bimodal.Metalogic_v2.Applications`

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean` - Create
- `Theories/Bimodal/Metalogic_v2/Completeness/StrongCompleteness.lean` - Create
- `Theories/Bimodal/Metalogic_v2/Decidability/*.lean` - Create (8 files, copied with import updates)
- `Theories/Bimodal/Metalogic_v2/Applications/Compactness.lean` - Create

**Verification**:
- All Application layer modules compile
- Dependency direction: Applications -> FMP -> Representation -> Core
- No upward imports

---

### Phase 6: Create Hub Module and Documentation [NOT STARTED]

**Goal**: Create top-level Metalogic_v2.lean hub and comprehensive README

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic_v2.lean` hub file importing all layers
- [ ] Write `Theories/Bimodal/Metalogic_v2/README.md` documenting:
  - New architecture with dependency diagram
  - Comparison to original Metalogic/ structure
  - Sorry inventory (9 total, all in Representation layer)
  - Migration notes for future work
  - How to use each layer
- [ ] Verify full compilation: `lake build Bimodal.Metalogic_v2`
- [ ] Run full project build: `lake build` to ensure no breakage

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2.lean` - Create
- `Theories/Bimodal/Metalogic_v2/README.md` - Create

**Verification**:
- `lake build Bimodal.Metalogic_v2` compiles without errors
- `lake build` succeeds (no project-wide breakage)
- README accurately documents structure

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic_v2` compiles successfully
- [ ] No import cycles (verify with `lake build --verbose`)
- [ ] Sorries isolated to Representation layer (grep for `sorry`)
- [ ] Original Metalogic/ unchanged (`git diff Theories/Bimodal/Metalogic/` shows no changes)
- [ ] Dependency direction verified: Core <- Soundness <- Representation <- FMP <- Applications
- [ ] set_lindenbaum available from Core.MaximalConsistent
- [ ] FMP available from top-level FMP.lean

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic_v2/` - New directory structure (~20 files)
- `Theories/Bimodal/Metalogic_v2.lean` - Hub module
- `Theories/Bimodal/Metalogic_v2/README.md` - Architecture documentation
- `specs/554_bimodal_metalogic_v2_reorganize/summaries/implementation-summary-{DATE}.md` - Completion summary

## Rollback/Contingency

If reorganization causes unforeseen issues:
1. The original `Theories/Bimodal/Metalogic/` is preserved unchanged
2. Can delete entire `Metalogic_v2/` directory and revert
3. No other project files are modified
4. Partial progress is still valuable (e.g., Phase 1-2 without Applications)

Phases are designed to be independently useful:
- After Phase 1: Core foundation available
- After Phase 3: Representation layer decoupled from Completeness
- After Phase 4: FMP bridge in place
- After Phase 5: Full architecture complete
