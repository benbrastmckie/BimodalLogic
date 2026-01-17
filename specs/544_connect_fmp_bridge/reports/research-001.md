# Research Report: Task #544

**Task**: 544 - Connect FMP Bridge (Phase 3 of 540)
**Started**: 2026-01-17T16:00:00Z
**Completed**: 2026-01-17T16:30:00Z
**Effort**: 1 hour
**Priority**: High
**Dependencies**: 542, 543
**Sources/Inputs**: Mathlib, lean_leansearch, lean_loogle, lean_leanfinder, lean_local_search
**Artifacts**: specs/544_connect_fmp_bridge/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The FiniteModelProperty.lean file exists but has broken imports and several sorry gaps in core theorems
- The SemanticCanonicalModel and FiniteCanonicalModel infrastructure in Completeness/FiniteCanonicalModel.lean is well-developed with proven `semantic_weak_completeness`
- Key bridge theorems are needed to connect `satisfiable_abs` to finite models and to link FMP to the existing decidability infrastructure
- Mathlib provides key decidability theorems (`Fintype.decidableForallFintype`, `Fintype.decidableExistsFintype`) that enable decidability from finite model property

## Context & Scope

### Research Focus
This research addresses the FiniteModelProperty bridge between representation and decidability/compactness for TM bimodal logic, specifically:

1. **FMP statement definition**: How to properly state the Finite Model Property theorem
2. **SemanticCanonicalModel connection**: How FMP relates to the semantic canonical model construction
3. **Decidability module connection**: How FMP enables decidability via finite model enumeration

### Existing Codebase Analysis

The codebase has three key components that need bridging:

#### 1. FiniteModelProperty.lean (Representation Module)
Location: `Theories/Bimodal/Metalogic/Representation/FiniteModelProperty.lean`

Current state:
- **Imports**: References `CanonicalModel`, `CompletenessTheorem`, and `FiniteCanonicalModel` (may have issues)
- **Core Theorem**: `finite_model_property : satisfiable_abs [phi] -> exists M_fin : FiniteCanonicalModel, M_fin |= phi`
- **Status**: Has `sorry` gaps in all main theorems

Key declarations:
```lean
theorem finite_model_property :
    satisfiable_abs [φ] → ∃ (M_fin : FiniteCanonicalModel), M_fin ⊨ φ

theorem filtration_preserves_truth {M : CanonicalModel} {w : CanonicalWorld} {φ : Formula}
    (h_sub : φ.subformula_closure ⊆ subforms) :
    canonicalTruthAt M w φ ↔ filteredTruthAt (filtration M subforms) (quotient w) φ

theorem decidability_via_fmp :
    Decidable (satisfiable_abs [φ])

theorem finite_model_size_bound {φ : Formula} (h_sat : satisfiable_abs [φ]) :
    ∃ (M_fin : FiniteCanonicalModel), M_fin ⊨ φ ∧ M_fin.card ≤ 2 ^ φ.complexity
```

#### 2. FiniteCanonicalModel.lean (Completeness Module)
Location: `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

This is the most developed module with proven core results:

**Proven/Working**:
- `semantic_weak_completeness` (lines ~3317-3386): Core completeness via contrapositive
- `SemanticCanonicalFrame` (line 2837): Frame with compositionality by construction
- `SemanticCanonicalModel` (line 2873): Model for completeness
- `semantic_truth_lemma_v2`: Membership equals truth (proven, no sorries)
- `main_provable_iff_valid`: Soundness-completeness equivalence (proven)

**Key Structures**:
```lean
abbrev FiniteTime (k : Nat) := Fin (2 * k + 1)  -- Time domain [-k, +k]
structure FiniteWorldState (phi : Formula)  -- World states within subformula closure
structure FiniteHistory (phi : Formula)  -- Histories bounded by temporal depth
noncomputable def SemanticCanonicalFrame (phi : Formula) : TaskFrame Int
noncomputable def SemanticCanonicalModel (phi : Formula) : TaskModel (SemanticCanonicalFrame phi)
```

**Bridge Theorems (Partial)**:
- `finite_model_property_v2` (line ~4128): States FMP follows from `semantic_weak_completeness`, has sorry
- `finiteHistoryToWorldHistory`: Converts finite history to general WorldHistory
- `semantic_truth_implies_truth_at`: Bridge between semantic truth and truth_at

#### 3. Decidability Module
Location: `Theories/Bimodal/Metalogic/Decidability/`

**Current Status**:
- **Soundness**: PROVEN (`decide_sound` in Correctness.lean)
- **Completeness**: Partial - `tableau_complete` and `decide_complete` have sorry gaps
- **Key dependency**: Both cite "Requires FMP and tableau completeness proof"

```lean
-- From Correctness.lean
theorem decide_complete (φ : Formula) (hvalid : ⊨ φ) :
    ∃ (fuel : Nat), ∃ proof, decide φ 10 fuel = .valid proof := by
  sorry  -- Requires tableau completeness

theorem tableau_complete (φ : Formula) :
    (⊨ φ) → ∃ (fuel : Nat), (buildTableau φ fuel).isSome ∧
             ∀ t, buildTableau φ fuel = some t → t.isValid := by
  sorry  -- Requires FMP and tableau completeness proof
```

#### 4. Compactness Module
Location: `Theories/Bimodal/Metalogic/Applications/Compactness.lean`

Has `compactness` and `finite_model_via_compactness` theorems with sorry gaps that depend on FMP.

## Findings

### Relevant Theorems from Mathlib

#### Decidability from Finite Types
```lean
-- Fintype.decidableForallFintype
instance {α : Type u_1} {p : α → Prop} [DecidablePred p] [Fintype α] : Decidable (∀ a, p a)

-- Fintype.decidableExistsFintype
instance {α : Type u_1} {p : α → Prop} [DecidablePred p] [Fintype α] : Decidable (∃ a, p a)
```

These enable: If we can show `FiniteCanonicalModel` is a Fintype and satisfiability is decidable in each model, then satisfiability is decidable overall.

#### Powerset Cardinality
```lean
-- Finset.card_powerset
theorem (s : Finset α) : s.powerset.card = 2 ^ s.card

-- Fintype.card_set
theorem [Fintype α] : Fintype.card (Set α) = 2 ^ Fintype.card α
```

Supports the model size bound theorem: `|worlds| ≤ 2^|closure φ|`

#### First-Order Logic Compactness (Model-Theoretic)
```lean
-- FirstOrder.Language.Theory.isSatisfiable_iff_isFinitelySatisfiable
theorem {T : L.Theory} : T.IsSatisfiable ↔ T.IsFinitelySatisfiable
```

Pattern for compactness: satisfiability iff finite satisfiability.

### Key Local Declarations

| Name | File | Type |
|------|------|------|
| `satisfiable_abs` | Semantics/Validity.lean | `def : Context → Prop` |
| `formula_satisfiable` | Semantics/Validity.lean | `def : Formula → Prop` |
| `subformulaClosure` | Decidability/SignedFormula.lean | `def` |
| `closure` | Completeness/FiniteCanonicalModel.lean | `def : Formula → Finset (closure phi)` |
| `filtration_preserves_truth` | Representation/FiniteModelProperty.lean | `theorem` |
| `weak_completeness` | Completeness/CompletenessTheorem.lean | `theorem` |
| `semantic_weak_completeness` | Completeness/FiniteCanonicalModel.lean | `noncomputable def` |

### Dependencies and Import Structure

```
FiniteModelProperty.lean
├── imports CanonicalModel (Representation)
├── imports CompletenessTheorem (Completeness)
└── imports FiniteCanonicalModel (Completeness)
    ├── SemanticCanonicalFrame
    ├── SemanticCanonicalModel
    └── semantic_weak_completeness (PROVEN)
```

The issue: FiniteModelProperty.lean tries to use `FiniteCanonicalModel` type but references may be misaligned with the actual definitions.

### Proof Strategies

#### Strategy 1: Connect via Semantic Model (Recommended)
Use the already-proven `semantic_weak_completeness` as the foundation:

1. Show `SemanticCanonicalFrame phi` with D = Int is finite
2. Connect `satisfiable_abs` to existence of satisfying `SemanticWorldState`
3. Use `Fintype.decidableExistsFintype` for decidability

**Rationale**: The semantic approach has fewer sorry gaps and the core theorems are proven.

#### Strategy 2: Direct Filtration Construction
Follow the classical filtration approach sketched in FiniteModelProperty.lean:

1. Start with satisfiability in canonical model
2. Apply filtration using subformula closure
3. Show filtration produces finite model

**Challenge**: Requires proving `filtration_preserves_truth` which has sorry.

### Proposed FMP Statement

Based on the codebase patterns:

```lean
/-- Main Finite Model Property theorem -/
theorem finite_model_property (φ : Formula) :
    formula_satisfiable φ →
    ∃ (k : Nat) (M : TaskModel (SemanticCanonicalFrame φ))
      (h : FiniteHistory φ) (t : FiniteTime k),
      semantic_truth_at_v2 φ (h.toSemanticWorldState t) t φ := by
  -- Use contrapositive of semantic_weak_completeness
  sorry

/-- Corollary: Decidability of satisfiability -/
theorem satisfiability_decidable (φ : Formula) : Decidable (formula_satisfiable φ) := by
  -- SemanticWorldState φ is finite (bounded by 2^|closure φ|)
  -- FiniteTime (temporalBound φ) is finite
  -- Use Fintype.decidableExistsFintype
  sorry
```

## Decisions

1. **Use semantic approach**: The semantic canonical model approach in FiniteCanonicalModel.lean has proven core results; use these rather than starting fresh.

2. **Focus on bridge theorems**: The main work is connecting `satisfiable_abs`/`formula_satisfiable` to the existing `SemanticWorldState` infrastructure.

3. **Fix imports first**: The FiniteModelProperty.lean may need import cleanup before proving new theorems.

4. **Decidability via Fintype**: Use Mathlib's `Fintype.decidableExistsFintype` pattern once we establish finite model.

## Recommendations

1. **Fix FiniteModelProperty.lean imports**: Ensure the file correctly imports from Completeness/FiniteCanonicalModel.lean and uses proper type references.

2. **Define FiniteCanonicalModel properly**: Currently the file uses `FiniteCanonicalModel` but this type may not be properly defined. Consider:
   - Using `SemanticCanonicalModel` directly, or
   - Creating a proper wrapper structure

3. **Prove FMP via semantic approach**: Implement:
   ```lean
   theorem finite_model_property (φ : Formula) :
       formula_satisfiable φ →
       ∃ (w : SemanticWorldState φ), semantic_truth_at_v2 φ w (origin) φ
   ```

4. **Connect to Decidability**: Add to Correctness.lean:
   ```lean
   theorem decide_complete_via_fmp (φ : Formula) :
       (⊨ φ) → ∃ (fuel : Nat), ∃ proof, decide φ 10 fuel = .valid proof
   ```

5. **Model size bound**: Prove using `Finset.card_powerset`:
   ```lean
   theorem semantic_world_state_finite (φ : Formula) :
       Fintype (SemanticWorldState φ)

   theorem finite_model_size_bound (φ : Formula) :
       Fintype.card (SemanticWorldState φ) ≤ 2 ^ (closure φ).card
   ```

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Import cycles between modules | Build failure | Carefully order imports; may need to refactor some definitions |
| Mismatched type definitions | Type errors | Audit existing types; use consistent definitions |
| Complex filtration proof | Extended timeline | Use semantic approach which has proven infrastructure |
| Fintype instance complexity | Compilation issues | Start with Classical.dec; optimize later |

## Appendix

### Search Queries Used
- `lean_local_search`: satisfiable, filtration, weak_completeness, SemanticCanonical, subformula
- `lean_leansearch`: "finite model property modal logic decidability", "finite set powerset cardinality"
- `lean_loogle`: "Decidable Fintype"
- `lean_leanfinder`: "compactness theorem finite satisfiability", "decidability theorem from finite model property"

### Key Files Examined
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Representation/FiniteModelProperty.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Representation/CanonicalModel.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Representation/RepresentationTheorem.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Decidability/Correctness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Applications/Compactness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean`

### References
- Mathlib `FirstOrder.Language.Theory.isSatisfiable_iff_isFinitelySatisfiable` for compactness pattern
- Mathlib `Fintype.decidableForallFintype` and `Fintype.decidableExistsFintype` for decidability
- Mathlib `Finset.card_powerset` for size bounds
- Modal Logic, Blackburn et al., Chapter 4 (Finite Model Property)
- Research report: specs/458_extend_canonical_history_full_domain/reports/research-004.md

## Next Steps

Run `/plan 544` to create implementation plan for:
1. Fix imports in FiniteModelProperty.lean
2. Define proper FMP statement using SemanticCanonicalModel
3. Prove FMP via semantic_weak_completeness
4. Connect to Decidability module
5. Prove decidability_via_fmp
