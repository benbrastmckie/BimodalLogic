# Lean Library Research: Bimodal Metalogic Restructuring

## Research Scope
- **Topic**: Review existing bimodal metalogic (representation, completeness, decidability, compactness) and propose restructuring.
- **Context**: Bimodal logic (TM), dependent type theory conventions.
- **Goal**: Identify ideal dependency structure where Representation Theorem is foundational.

## Current State Review

### Existing Modules
1.  **Syntax**: `Theories/Bimodal/Syntax/Formula.lean`
    - Inductive type `Formula`.
    - Good use of dependent types (inductive definitions).
    - `Context` defined as `List Formula` (finite).

2.  **Proof System**: `Theories/Bimodal/ProofSystem.lean`
    - Inductive type `DerivationTree`.
    - Dependent on `Context` and `Formula`.

3.  **Semantics**: `Theories/Bimodal/Semantics.lean`
    - `TaskFrame`, `TaskModel`.
    - Standard Kripke semantics.

4.  **Completeness**: `Theories/Bimodal/Metalogic/Completeness.lean`
    - Implements `SetMaximalConsistent` (MCS).
    - Implements `set_lindenbaum` (Zorn's lemma).
    - Defines `weak_completeness` and `strong_completeness` as axioms/theorems.
    - Uses `Set Formula` (Formula -> Prop) for theories.

5.  **Representation**: `Theories/Bimodal/Metalogic/RepresentationTheorems.lean`
    - Imports `Completeness`.
    - Defines `ContextDerivable` (List based) and `SetDerivable` (Set based).
    - Proves `representation_theorem_empty` using `weak_completeness`.
    - **Issue**: Circular dependency conceptualization. Representation depends on Completeness, whereas Completeness should conceptually follow from Representation (Canonical Model).

### Critique of Current Structure
- **Dependency Inversion**: Currently, `RepresentationTheorems.lean` imports `Completeness.lean`. In a foundational approach, the Representation Theorem (constructing the Canonical Model and proving the Truth Lemma) is the core engine that *powers* Completeness.
- **Set vs List**: The tension between `Context` (List) and `Theory` (Set) is handled via `SetDerivable` vs `ContextDerivable`. This is fine, but the bridge needs to be cleaner.
- **Missing Links**: Decidability and Compactness are mentioned but not fully integrated into the dependency chain.

## Proposed Ideal Restructuring

The goal is to make the **Representation Theorem** (Canonical Model Construction & Truth Lemma) the central hub from which other metalogical results radiate.

### 1. Foundation Layer
- **`Bimodal.Syntax`**: Unchanged.
- **`Bimodal.ProofSystem`**: Unchanged.
- **`Bimodal.Semantics`**: Unchanged.

### 2. The Core: Representation Theory
**New Module**: `Bimodal.Metalogic.Representation`
This module should absorb the heavy lifting currently in `Completeness.lean`.

- **Submodule**: `Canonical`
    - **Definition**: `MaximalConsistentSet` (Structure/Type wrapping `Set Formula`).
    - **Lemma**: `Lindenbaum` (Every consistent set extends to MCS).
    - **Construction**: `CanonicalFrame` (Worlds = MCS, Relations = Canonical Relations).
    - **Construction**: `CanonicalModel` (Valuation = Membership).
    - **Theorem**: `TruthLemma` (M, w ⊨ φ ↔ φ ∈ w).
- **Theorem**: `RepresentationTheorem`
    - Every consistent set of formulas is satisfiable in the Canonical Model.
    - (Algebraic view: The Lindenbaum-Tarski algebra embeds into the Complex Algebra of the Canonical Frame).

### 3. Derived Results Layer
These modules should import `Representation`.

- **`Bimodal.Metalogic.Completeness`**
    - **Strong Completeness**: Follows directly from `RepresentationTheorem`.
        - If Γ ⊨ φ, then Γ ∪ {¬φ} is unsatisfiable.
        - By Rep Thm, if Γ ∪ {¬φ} were consistent, it would be satisfiable.
        - Thus Γ ∪ {¬φ} is inconsistent -> Γ ⊢ φ.
    - **Weak Completeness**: Special case for empty Γ.

- **`Bimodal.Metalogic.Compactness`**
    - **Theorem**: `Compactness`
    - Follows from `RepresentationTheorem` (Satisfiability in Canonical Model).
    - Or via standard translation (as hinted in Task 502), but Canonical Model gives a direct modal proof.

- **`Bimodal.Metalogic.Decidability`**
    - **Theorem**: `FiniteModelProperty` (FMP).
    - **Method**: `Filtration` (Quotient of Canonical Model).
    - **Result**: `Decidability` (via Harrop's Theorem / Finite search).
    - Dependency: `Representation` -> `Filtration` -> `Decidability`.

### 4. Dependent Type Theory Conventions
- **Type Classes**: Use `[Consistent Γ]` type class? Maybe overkill.
- **Structures**: Define `CanonicalModel` as a `structure` implementing the `Model` type class.
- **Worlds as Types**: The set of worlds in Canonical Model is `{ s : Set Formula // MaximalConsistent s }`. This is a `Type` (subtype).
- **Constructive Content**: Where possible, keep proofs constructive (e.g., Decidability), but Completeness via Zorn is inherently classical.

## Implementation Plan

1.  **Refactor `Completeness.lean`**:
    - Move MCS, Lindenbaum, Canonical Model, Truth Lemma to `Bimodal.Metalogic.Representation`.
    - Rename `Completeness.lean` to `Bimodal.Metalogic.Completeness` (containing only the derivation of completeness from Rep Thm).

2.  **Update `RepresentationTheorems.lean`**:
    - This file currently seems to be a high-level summary or specific "Context" version.
    - It should be aligned to use the new `Representation` module.

3.  **Integrate `FiniteCanonicalModel`**:
    - Task 502 mentioned `FiniteCanonicalModel`. This is for FMP/Decidability.
    - It should be part of `Bimodal.Metalogic.Decidability` or `Bimodal.Metalogic.Filtration`.

## Dependency Graph

```mermaid
graph TD
    Syntax --> ProofSystem
    Syntax --> Semantics
    ProofSystem --> Soundness
    Semantics --> Soundness
    
    ProofSystem --> Representation[Representation (Canonical Model)]
    Semantics --> Representation
    
    Representation --> Completeness
    Representation --> Compactness
    Representation --> Filtration[Filtration (Finite Model)]
    
    Filtration --> Decidability
```

## Conclusion
The "Ideal Dependency Structure" places the **Canonical Model Construction** (Representation) at the center. Completeness, Compactness, and Decidability are downstream consequences. This aligns with the mathematical reality that the Canonical Model is the "universal" structure for the logic.

## References
- Task 502 Report.
- Codebase: `Completeness.lean`, `RepresentationTheorems.lean`.
- Blackburn, de Rijke, Venema, *Modal Logic*.
