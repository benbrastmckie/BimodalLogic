# Implementation Plan - Restructure and Refine Bimodal Metalogic

## Metadata
- **Task**: 505 - Restructure and Refine Bimodal Metalogic
- **Status**: [PLANNED]
- **Effort**: 100 hours
- **Priority**: High
- **Dependencies**: Task 502 (Completed)
- **Research Inputs**: 
  - reports/research-001.md
  - reports/research-002.md
  - ../502_complete_representation_theorem/summaries/implementation-summary-20260114.md
- **Artifacts**: plans/implementation-002.md
- **Standards**: 
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
- **Type**: markdown
- **Lean Intent**: true

## Overview
This plan outlines the restructuring of the Bimodal Metalogic library to follow a "Representation First" architecture. Building on the context-based provability established in Task 502, we will invert the current dependency structure. The Canonical Model construction will become the central hub (in `Representation/`), from which Completeness, Compactness, and Decidability are derived. This eliminates circular conceptual dependencies and aligns the codebase with the mathematical reality that the Canonical Model is the universal structure for the logic.

## Goals & Non-Goals
- **Goals**:
  - Establish a unified directory structure: `Core`, `Soundness`, `Representation`, `Completeness`, `Decidability`.
  - Consolidate provability notions around `ContextDerivable` (List-based).
  - Implement the Canonical Model and Truth Lemma within `Representation/`.
  - Derive Strong Completeness and Compactness from the Representation Theorem.
  - Integrate the existing `FiniteCanonicalModel` and `Decidability` modules via the Finite Model Property (FMP).
- **Non-Goals**:
  - Changing the underlying logic (TM) or axioms.
  - Rewriting the `Soundness` proofs (only moving/refactoring).
  - Implementing new decision procedures (only integrating existing ones).

## Risks & Mitigations
- **Risk**: Circular dependencies during refactoring (e.g., between Completeness and Representation).
  - **Mitigation**: Strictly follow the layer order: Core -> Soundness -> Representation -> Completeness/Decidability.
- **Risk**: `FiniteCanonicalModel` integration complexity.
  - **Mitigation**: Treat FMP as a bridge between the infinite Canonical Model (Representation) and the finite decision procedure.
- **Risk**: Breaking existing proofs during file moves.
  - **Mitigation**: Use `lake build` validation at each step; keep legacy files until replacements are verified.

## Implementation Phases

### Phase 1: Core Infrastructure and Soundness Migration [NOT STARTED]
- **Goal**: Establish the new directory structure and migrate foundational definitions and soundness proofs.
- **Tasks**:
  - [ ] Create directory structure: `Theories/Bimodal/Metalogic/{Core, Soundness, Representation, Completeness, Decidability, Applications}`.
  - [ ] Move `Basic.lean` (Consistency, Validity) to `Core/`.
  - [ ] Consolidate provability definitions (from Task 502) into `Core/Provability.lean`.
  - [ ] Move `Soundness.lean` and `SoundnessLemmas.lean` to `Soundness/` and update imports.
  - [ ] Verify build passes for Core and Soundness.
- **Timing**: 20 hours

### Phase 2: Representation Theory Foundation [NOT STARTED]
- **Goal**: Implement the Canonical Model and Representation Theorem as the central engine.
- **Tasks**:
  - [ ] Create `Representation/ContextProvability.lean` (refining Task 502 work).
  - [ ] Implement `Representation/CanonicalModel.lean`:
    - Define `MaximalConsistentSet` (MCS) using `ContextDerivable`.
    - Prove `Lindenbaum` lemma (using Zorn's lemma).
    - Construct `CanonicalFrame` and `CanonicalModel`.
  - [ ] Implement `Representation/TruthLemma.lean`:
    - Prove `M_can, w ⊨ φ ↔ φ ∈ w`.
  - [ ] Prove `Representation/RepresentationTheorem.lean`:
    - "Every consistent context is satisfiable in the Canonical Model".
- **Timing**: 40 hours

### Phase 3: Completeness and Compactness Derivation [NOT STARTED]
- **Goal**: Derive standard metalogical results from the Representation Theorem.
- **Tasks**:
  - [ ] Implement `Completeness/CompletenessTheorem.lean`:
    - Derive Strong Completeness: `Γ ⊨ φ → Γ ⊢ φ` (via contrapositive and Rep Thm).
  - [ ] Implement `Applications/Compactness.lean`:
    - Derive Compactness from Satisfiability in Canonical Model.
  - [ ] Verify all original completeness theorems are provable.
  - [ ] Remove legacy `Completeness.lean` once fully superseded.
- **Timing**: 20 hours

### Phase 4: Decidability Integration and Documentation [NOT STARTED]
- **Goal**: Connect Decidability via FMP and finalize documentation.
- **Tasks**:
  - [ ] Move `Decidability.lean` and submodules to `Decidability/`.
  - [ ] Integrate `FiniteCanonicalModel.lean` into `Representation/FiniteModelProperty.lean` (or similar bridge).
  - [ ] Prove FMP: "If satisfiable, then satisfiable in finite model" (via filtration of Canonical Model).
  - [ ] Connect `Decidability/DecisionProcedure.lean` to FMP.
  - [ ] Update `04-Metalogic.tex` and `README.md` to reflect the new structure.
- **Timing**: 20 hours

## Testing & Validation
- [ ] **Build Verification**: `lake build` must pass after each phase.
- [ ] **Theorem Check**: Ensure `strong_completeness` and `decidability` are free of `sorry`.
- [ ] **Documentation Check**: Verify LaTeX documentation compiles and matches the code structure.

## Artifacts & Outputs
- `Theories/Bimodal/Metalogic/Core/`
- `Theories/Bimodal/Metalogic/Soundness/`
- `Theories/Bimodal/Metalogic/Representation/`
- `Theories/Bimodal/Metalogic/Completeness/`
- `Theories/Bimodal/Metalogic/Decidability/`
- `Theories/Bimodal/Metalogic/Applications/`
- Updated `Theories/Bimodal/latex/subfiles/04-Metalogic.tex`

## Rollback/Contingency
- Use git to track file moves.
- If refactoring hits a blocker, revert to the legacy `Completeness.lean` structure and implement a shim.
