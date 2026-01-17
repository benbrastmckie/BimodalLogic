# Implementation Plan - Restructure and Refine Bimodal Metalogic

## Metadata
- **Task**: 505
- **Description**: Review the existing bimodal metalogic, including representation theory, completeness, decidability, and compactness, following the completion of task 502. Propose and implement an ideal restructuring to improve the quality, organization, and clarity of the theory.
- **Language**: lean
- **Proof Strategy**: Context-based representation theory as foundation, deriving completeness and decidability
- **Complexity**: complex
- **Total Estimated Effort**: 100 hours
- **Mathlib Dependencies**: Mathlib.Data.List.Basic, Mathlib.Data.Set.Basic, Mathlib.Order.Zorn, Mathlib.Logic.Basic

## Overview
The goal of this task is to restructure the Bimodal Metalogic library to follow a "Representation First" architecture. Currently, the library suffers from fragmented responsibilities, inconsistent provability notions (Set vs List), and circular conceptual dependencies. The new architecture will establish the Representation Theorem (Canonical Model Construction) as the central hub from which Completeness, Compactness, and Decidability are derived. This aligns with the mathematical reality that the Canonical Model is the "universal" structure for the logic and leverages recent research (Task 502) on context-based provability.

### Scope
- **Restructure**: Create a new directory structure `Theories/Bimodal/Metalogic/{Core, Soundness, Completeness, Decidability, Representation, Applications}`.
- **Refactor**: Move and split existing code into these modules.
- **Implement**:
    - Unified provability hierarchy (Context-based).
    - Canonical Model construction using Context-based MCS.
    - Truth Lemma for Canonical Model.
    - Derivation of Completeness and Compactness from Representation.
    - Integration of Decidability via Finite Model Property (FMP).
- **Documentation**: Update LaTeX documentation and READMEs.

### Definition of Done
- All existing theorems remain provable.
- `Representation` module is the foundational dependency for `Completeness`.
- `Completeness.lean` is refactored to depend on `Representation`.
- `Decidability` is integrated via FMP.
- Documentation (LaTeX and Markdown) reflects the new structure.
- Build passes without errors.

## Proof Strategy
The core strategy is to invert the current dependency between Completeness and Representation.
1.  **Context-Based Provability**: We will use `ContextDerivable` (List Formula) as the primary provability notion, as it is constructive and matches Lean's inductive types.
2.  **Canonical Model Construction**: We will construct the Canonical Model where worlds are Maximal Consistent Sets (MCS). We will bridge the "List vs Set" gap by defining MCS as sets of formulas but proving properties using context-based derivability.
3.  **Representation Theorem**: We will prove that every consistent context is satisfiable in the Canonical Model. This is the "Representation Theorem".
4.  **Derived Completeness**: Strong Completeness will be derived as a corollary: if Γ ⊨ φ, then Γ ∪ {¬φ} is unsatisfiable, hence inconsistent (by Rep Thm), so Γ ⊢ φ.
5.  **Filtration for Decidability**: We will use the Finite Model Property (FMP), derived via filtration of the Canonical Model, to connect to the tableau-based decision procedure.

## Implementation Phases

### Phase 1: Core Infrastructure and Soundness Migration
**Objective**: Establish the new directory structure and migrate core definitions and soundness proofs.
- [NOT STARTED] Create directory structure: `Theories/Bimodal/Metalogic/{Core, Soundness, Completeness, Decidability, Representation, Applications}`.
- [NOT STARTED] Move `Basic.lean` (definitions of Consistent, Valid) to `Core/`.
- [NOT STARTED] Implement `Core/Provability.lean` with unified hierarchy (ContextDerivable as primary).
- [NOT STARTED] Move `Soundness.lean` and `SoundnessLemmas.lean` to `Soundness/` and update imports.
- [NOT STARTED] Verify build passes for Core and Soundness.
- **Effort**: 25 hours

### Phase 2: Representation Theory Foundation
**Objective**: Implement the Canonical Model and Representation Theorem as the core engine.
- [NOT STARTED] Create `Representation/ContextProvability.lean` (refining Task 502 work).
- [NOT STARTED] Implement `Representation/CanonicalModel.lean`:
    - Define `MaximalConsistentSet` (MCS).
    - Prove `Lindenbaum` lemma (using Zorn's lemma) for context-based consistency.
    - Construct `CanonicalFrame` and `CanonicalModel`.
- [NOT STARTED] Implement `Representation/TruthLemma.lean`:
    - Prove the Truth Lemma: `M_can, w ⊨ φ ↔ φ ∈ w`.
- [NOT STARTED] Prove `Representation/RepresentationTheorem.lean`:
    - "Every consistent context is satisfiable in the Canonical Model".
- **Effort**: 35 hours

### Phase 3: Completeness and Compactness Derivation
**Objective**: Refactor Completeness to depend on Representation and implement Compactness.
- [NOT STARTED] Refactor `Completeness.lean` into `Completeness/CompletenessTheorem.lean`.
- [NOT STARTED] Prove Strong Completeness as a corollary of Representation Theorem.
- [NOT STARTED] Implement `Applications/Compactness.lean`:
    - Derive Compactness from Representation Theorem (satisfiability in Canonical Model).
- [NOT STARTED] Verify all original completeness theorems are still provable (or replaced by better versions).
- **Effort**: 20 hours

### Phase 4: Decidability Integration and Documentation
**Objective**: Connect Decidability via FMP and update documentation.
- [NOT STARTED] Move `Decidability.lean` and submodules to `Decidability/`.
- [NOT STARTED] Implement `Representation/FiniteModelProperty.lean`:
    - Define Filtration of Canonical Model.
    - Prove FMP: "If satisfiable, then satisfiable in finite model".
- [NOT STARTED] Connect `Decidability/DecisionProcedure.lean` to FMP (using FMP to bound search/termination).
- [NOT STARTED] Update LaTeX documentation (`04-Metalogic.tex`) to reflect the new structure.
- [NOT STARTED] Update `README.md` files.
- **Effort**: 20 hours

## Mathlib Integration
- **Sets and Lists**: We will use `Mathlib.Data.Set.Basic` for MCS and `Mathlib.Data.List.Basic` for contexts. The bridge between them (List.toSet) will be central.
- **Zorn's Lemma**: `Mathlib.Order.Zorn` is required for Lindenbaum's Lemma.
- **Logic**: `Mathlib.Logic.Basic` for standard logical connectives.
- **Finiteness**: `Mathlib.Data.Fintype.Basic` or `Mathlib.Data.Finset.Basic` for filtration and FMP.

## Testing and Validation
- **Build Verification**: `lake build` must pass at each phase.
- **Theorem Check**: Verify that `weak_completeness` and `strong_completeness` are proven without `sorry`.
- **Refactoring Check**: Ensure no cyclic dependencies between modules.
- **Documentation Check**: Verify LaTeX compiles and accurately describes the code.

## Artifacts
- `Theories/Bimodal/Metalogic/Core/`
- `Theories/Bimodal/Metalogic/Soundness/`
- `Theories/Bimodal/Metalogic/Representation/`
- `Theories/Bimodal/Metalogic/Completeness/`
- `Theories/Bimodal/Metalogic/Decidability/`
- `Theories/Bimodal/Metalogic/Applications/`
- Updated `04-Metalogic.tex`

## Rollback Strategy
- The restructuring involves moving many files. We will use git to track moves (`git mv`) to preserve history.
- If a phase fails (e.g., circular dependency), we can revert to the previous phase's commit.
- The existing `Completeness.lean` will be kept until Phase 3 is complete, then replaced.
