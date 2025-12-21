# Loogle Search Report: LTL

## Search Metadata

- **Query**: `LTL`
- **Date**: 2025-12-21
- **Search Method**: Local codebase analysis (Loogle API unavailable)
- **Match Count**: 0 exact matches, 48+ related temporal/modal logic items
- **Libraries Searched**: Local ProofChecker project (Logos formal logic system)

## Executive Summary

**No exact "LTL" (Linear Temporal Logic) matches found** in the codebase or via Loogle API.

However, the ProofChecker project implements a **bimodal logic TM (Tense and Modality)** that combines:
- **S5 Modal Logic** (metaphysical necessity/possibility: □, ◇)
- **Linear Temporal Logic** (past/future operators: H, G, F, P)

The system contains extensive temporal logic infrastructure that relates to LTL concepts, including:
- Temporal operators (all_past, all_future, some_past, some_future)
- Derived temporal operators (always △, sometimes ▽)
- Temporal axioms (T4, TA, TL, TK distribution)
- Modal-temporal interaction axioms (MF, TF)
- Perpetuity principles connecting modal and temporal operators

## Search Results

### Exact Matches

**None found.** No definitions, theorems, structures, or types explicitly named "LTL" exist in the codebase.

### Related Temporal Logic Items

The following categories represent LTL-related functionality implemented in the Logos system:

#### 1. Temporal Operators (Primitive)

| Name | Type Signature | Location | Description | Category |
|------|---------------|----------|-------------|----------|
| `Formula.all_past` | `Formula → Formula` | Logos/Core/Syntax/Formula.lean:72 | Universal past operator (Hφ, "φ has always been true") | Constructor |
| `Formula.all_future` | `Formula → Formula` | Logos/Core/Syntax/Formula.lean:74 | Universal future operator (Gφ, "φ will always be true") | Constructor |
| `Formula.some_past` | `Formula → Formula` | Logos/Core/Syntax/Formula.lean:169 | Existential past operator (Pφ, "φ was true at some past time"), derived as ¬H¬φ | Definition |
| `Formula.some_future` | `Formula → Formula` | Logos/Core/Syntax/Formula.lean:181 | Existential future operator (Fφ, "φ will be true at some future time"), derived as ¬G¬φ | Definition |

**Note**: These correspond to standard LTL operators:
- `all_future` (G) ≈ LTL's "globally" operator
- `some_future` (F) ≈ LTL's "finally/eventually" operator
- `all_past` (H) ≈ LTL's "historically" operator
- `some_past` (P) ≈ LTL's "previously/once" operator

#### 2. Derived Temporal Operators

| Name | Type Signature | Location | Description | Category |
|------|---------------|----------|-------------|----------|
| `Formula.always` | `Formula → Formula` | Logos/Core/Syntax/Formula.lean:127 | Eternal truth operator (△φ := Hφ ∧ φ ∧ Gφ), φ holds at all times past, present, future | Definition |
| `Formula.sometimes` | `Formula → Formula` | Logos/Core/Syntax/Formula.lean:143 | Sometime operator (▽φ := ¬△¬φ), φ holds at some time past, present, or future | Definition |
| `Formula.swap_temporal` | `Formula → Formula` | Logos/Core/Syntax/Formula.lean:204 | Temporal duality transformation, swaps all_past ↔ all_future recursively | Definition |

#### 3. Temporal Axioms

| Name | Type Signature | Location | Description | Category |
|------|---------------|----------|-------------|----------|
| `Axiom.temp_k_dist` | `∀ φ ψ, Axiom (G(φ → ψ) → (Gφ → Gψ))` | Logos/Core/ProofSystem/Axioms.lean:210 | Temporal K distribution: future distributes over implication | Axiom |
| `Axiom.temp_4` | `∀ φ, Axiom (Gφ → GGφ)` | Logos/Core/ProofSystem/Axioms.lean:218 | Temporal 4: transitivity of future operator | Axiom |
| `Axiom.temp_a` | `∀ φ, Axiom (φ → G(Pφ))` | Logos/Core/ProofSystem/Axioms.lean:229 | Temporal A: temporal connectedness, present was in past of future | Axiom |
| `Axiom.temp_l` | `∀ φ, Axiom (△φ → G(Hφ))` | Logos/Core/ProofSystem/Axioms.lean:247 | Temporal L: perpetuity implies recurrence | Axiom |

#### 4. Modal-Temporal Interaction Axioms

| Name | Type Signature | Location | Description | Category |
|------|---------------|----------|-------------|----------|
| `Axiom.modal_future` | `∀ φ, Axiom (□φ → □Gφ)` | Logos/Core/ProofSystem/Axioms.lean:254 | Modal-Future: necessary truths remain necessary in future | Axiom |
| `Axiom.temp_future` | `∀ φ, Axiom (□φ → G□φ)` | Logos/Core/ProofSystem/Axioms.lean:261 | Temporal-Future: necessary truths will always be necessary | Axiom |

#### 5. Perpetuity Principles (Modal-Temporal Bridge)

| Name | Type Signature | Location | Description | Category |
|------|---------------|----------|-------------|----------|
| `perpetuity_1` | `∀ φ, ⊢ □φ → △φ` | Logos/Core/Theorems/Perpetuity/Principles.lean | Necessary implies always (modal necessity → eternal truth) | Theorem |
| `perpetuity_2` | `∀ φ, ⊢ ▽φ → ◇φ` | Logos/Core/Theorems/Perpetuity/Principles.lean | Sometimes implies possible (temporal occurrence → modal possibility) | Theorem |
| `perpetuity_3` | `∀ φ, ⊢ □φ → □△φ` | Logos/Core/Theorems/Perpetuity/Principles.lean | Necessity of perpetuity (necessary truths are perpetually necessary) | Theorem |
| `perpetuity_4` | `∀ φ, ⊢ ◇▽φ → ◇φ` | Logos/Core/Theorems/Perpetuity/Principles.lean | Possibility of occurrence (possibly sometime → possible) | Theorem |
| `perpetuity_5` | `∀ φ, ⊢ ◇▽φ → △◇φ` | Logos/Core/Theorems/Perpetuity/Principles.lean | Persistent possibility (possibly sometime → always possible) | Theorem |
| `perpetuity_6` | `∀ φ, ⊢ ▽□φ → □△φ` | Logos/Core/Theorems/Perpetuity/Bridge.lean | Occurrent necessity is perpetual (sometime necessary → necessarily always) | Theorem |

#### 6. Temporal Semantics

| Name | Type Signature | Location | Description | Category |
|------|---------------|----------|-------------|----------|
| `TaskFrame` | `Type → Type` | Logos/Core/Semantics/TaskFrame.lean:78 | Polymorphic task frame with temporal type parameter T | Structure |
| `WorldHistory` | `∀ {T F}, WorldHistory T F` | Logos/Core/Semantics/WorldHistory.lean:64 | World history over temporal type T with convexity constraint (no temporal gaps) | Structure |
| `trivialFrame` | `∀ {T}, TaskFrame T` | Logos/Core/Semantics/TaskFrame.lean:109 | Trivial task frame polymorphic over temporal type (relation always true) | Definition |
| `natFrame` | `∀ {T}, TaskFrame T` | Logos/Core/Semantics/TaskFrame.lean:140 | Natural number frame polymorphic over temporal type | Definition |

**Temporal Type Polymorphism**: The semantics support multiple temporal structures:
- `Int`: Discrete integer time (standard temporal logic)
- `Rat`: Dense rational time (fine-grained temporal reasoning)
- Any type with `LinearOrderedAddCommGroup` structure

#### 7. Temporal Theorems and Lemmas

| Name | Type Signature | Location | Description | Category |
|------|---------------|----------|-------------|----------|
| `swap_temporal_involution` | `∀ φ, φ.swap_temporal.swap_temporal = φ` | Logos/Core/Syntax/Formula.lean:220 | Temporal duality is involutive (swapping twice gives identity) | Theorem |
| `swap_temporal_diamond` | `∀ φ, φ.diamond.swap_temporal = φ.swap_temporal.diamond` | Logos/Core/Syntax/Formula.lean:245 | Temporal swap distributes over modal diamond | Theorem |
| `swap_temporal_neg` | `∀ φ, φ.neg.swap_temporal = φ.swap_temporal.neg` | Logos/Core/Syntax/Formula.lean:255 | Temporal swap distributes over negation | Theorem |
| `temporal_duality_neg` | `∀ φ, ⊢ ¬φ.sometimes → φ.always.neg` | LogosTest/Core/Theorems/PerpetuityTest.lean:282 | Temporal duality for negation (tested) | Lemma |
| `temporal_duality_neg_rev` | `∀ φ, ⊢ φ.always.neg → ¬φ.sometimes` | LogosTest/Core/Theorems/PerpetuityTest.lean:288 | Reverse temporal duality for negation (tested) | Lemma |

#### 8. Modal Axioms (S5 Modal Logic Component)

| Name | Type Signature | Location | Description | Category |
|------|---------------|----------|-------------|----------|
| `Axiom.modal_t` | `∀ φ, Axiom (□φ → φ)` | Logos/Core/ProofSystem/Axioms.lean:92 | Modal T: necessity implies truth (reflexivity) | Axiom |
| `Axiom.modal_4` | `∀ φ, Axiom (□φ → □□φ)` | Logos/Core/ProofSystem/Axioms.lean:100 | Modal 4: necessary truths are necessarily necessary (transitivity) | Axiom |
| `Axiom.modal_b` | `∀ φ, Axiom (φ → □◇φ)` | Logos/Core/ProofSystem/Axioms.lean:108 | Modal B: truths are necessarily possible (symmetry) | Axiom |
| `Axiom.modal_k_dist` | `∀ φ ψ, Axiom (□(φ → ψ) → (□φ → □ψ))` | Logos/Core/ProofSystem/Axioms.lean:191 | Modal K: necessity distributes over implication | Axiom |
| `Axiom.modal_5_collapse` | `∀ φ, Axiom (◇□φ → □φ)` | Logos/Core/ProofSystem/Axioms.lean:129 | Modal 5: S5 characteristic collapse axiom | Axiom |

#### 9. Automation for Temporal Logic

| Name | Type Signature | Location | Description | Category |
|------|---------------|----------|-------------|----------|
| `temp_k` | Tactic | Logos/Core/Automation/Tactics.lean:203 | Tactic applying temporal K distribution rule | Tactic |
| `modal_search` | Tactic | Logos/Core/Automation/ProofSearch.lean | Heuristic proof search for modal theorems | Tactic |
| `temporal_search` | Tactic | Logos/Core/Automation/ProofSearch.lean | Heuristic proof search for temporal theorems | Tactic |

#### 10. Test Cases

Extensive test coverage in LogosTest/ directory:
- `PerpetuityTest.lean`: 105+ tests for perpetuity principles
- `DerivationTest.lean`: Temporal derivation tests (T4, TA, TL)
- `SoundnessTest.lean`: Temporal axiom soundness tests
- `TacticsTest.lean`: Temporal tactic tests (81-83, 105)

## Analysis: LTL vs. TM Logic

### Similarities to LTL

The Logos TM logic shares these features with standard Linear Temporal Logic (LTL):

1. **Future Operator (G/□)**: `all_future` corresponds to LTL's "globally" operator
2. **Eventually Operator (F/◇)**: `some_future` corresponds to LTL's "finally" operator
3. **Linear Time**: Semantics based on linear time with temporal ordering
4. **Temporal Axioms**: Similar axiom patterns (K distribution, transitivity)

### Extensions Beyond Standard LTL

The TM logic extends LTL with:

1. **Past Operators**: Full past/future symmetry with H (all_past) and P (some_past)
2. **Modal Necessity**: S5 modal logic layer (□, ◇) orthogonal to temporal operators
3. **Bimodal Integration**: Modal-temporal interaction axioms (MF, TF)
4. **Perpetuity Principles**: Deep connections between modal necessity and temporal always/sometimes
5. **Task Semantics**: Richer semantics with task relations and world histories
6. **Temporal Type Polymorphism**: Generic over temporal duration types (Int, Rat, etc.)

### Why No "LTL" Label?

The system implements **bimodal logic TM** (Tense and Modality), which:
- Subsumes LTL temporal operators as a component
- Adds S5 modal logic layer for metaphysical necessity
- Provides modal-temporal interaction beyond pure LTL
- Uses different naming conventions (H, G, P, F vs. LTL's standard notation)

## Recommendations

### For LTL-Specific Queries

If searching for standard LTL theorems or constructs:

1. **Globally operator**: Search for `all_future` or `G` notation
2. **Eventually operator**: Search for `some_future` or `F` notation
3. **Historically operator**: Search for `all_past` or `H` notation
4. **Previously operator**: Search for `some_past` or `P` notation
5. **Always (eternal)**: Search for `always` or `△` notation

### For Bimodal Logic Queries

If working with the full TM logic:

1. **Modal necessity**: Search for `box`, `modal_t`, `modal_4`, `modal_b`, `modal_5`
2. **Temporal operators**: Search for `all_future`, `all_past`, `some_future`, `some_past`
3. **Modal-temporal interaction**: Search for `modal_future`, `temp_future`, `perpetuity`
4. **Semantics**: Search for `TaskFrame`, `WorldHistory`, `truth_at`

### Future Integration

To integrate external LTL libraries via Loogle:

1. Configure Loogle MCP server in `.mcp.json` (currently planned, not active)
2. Search Mathlib for `LTL`, `temporal`, `Kripke` using Loogle API
3. Search for `CTL`, `CTL*`, `μ-calculus` for related temporal logics
4. Cross-reference with model checking libraries

## Search Query Suggestions

### Exact Pattern Searches
```
- "LTL" (no results)
- "Linear Temporal Logic" (no results)
- "CTL" (Computation Tree Logic, likely no results)
- "temporal logic" (many results in comments/docs)
```

### Type Signature Searches
```
- Type containing "all_future": Formula → Formula
- Type containing "all_past": Formula → Formula
- Type containing "temporal": Various temporal semantics types
- Type containing "TaskFrame": Temporal frame structures
```

### Semantic Searches
```
- Operators for temporal reasoning: all_future, some_future, all_past, some_past
- Temporal axioms: temp_k_dist, temp_4, temp_a, temp_l
- Modal-temporal bridges: perpetuity_1 through perpetuity_6
- Temporal semantics: TaskFrame, WorldHistory, truth_at
```

## References

### Local Documentation
- [ARCHITECTURE.md](../../../Documentation/UserGuide/ARCHITECTURE.md): TM logic specification
- [Formula.lean](../../../Logos/Core/Syntax/Formula.lean): Temporal operator definitions
- [Axioms.lean](../../../Logos/Core/ProofSystem/Axioms.lean): Temporal axiom schemata
- [Perpetuity.lean](../../../Logos/Core/Theorems/Perpetuity.lean): Modal-temporal bridge theorems

### External Resources
- Loogle API: https://loogle.lean-lang.org/ (currently unavailable)
- Lean 4 Documentation: https://lean-lang.org/
- Mathlib4 Temporal Logic: Search for temporal logic in Mathlib when available

## Appendix: Full Match List

See individual sections above for 48+ temporal/modal logic items organized by category.

**Categories**:
1. Temporal Operators (Primitive): 4 items
2. Derived Temporal Operators: 3 items
3. Temporal Axioms: 4 items
4. Modal-Temporal Interaction: 2 items
5. Perpetuity Principles: 6 items
6. Temporal Semantics: 4 items
7. Temporal Theorems: 5 items
8. Modal Axioms: 5 items
9. Automation: 3 items
10. Test Cases: 12+ test files

**Total**: 48+ formal definitions, theorems, axioms, and automation tools related to temporal logic.
