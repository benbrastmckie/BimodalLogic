# Metalogic_v2 Tests

Comprehensive test suite for the Metalogic_v2 directory, covering the complete metalogic development from Core through Completeness.

## Test Organization

The test suite follows the layered architecture of Metalogic_v2:

```
Tests/BimodalTest/Metalogic_v2/
├── CoreTest.lean           # Core layer example-based tests
├── CorePropertyTest.lean   # Core layer property-based tests
├── SoundnessTest.lean      # Soundness layer example tests
├── SoundnessPropertyTest.lean  # Soundness property tests
├── RepresentationTest.lean # Representation layer tests
├── CompletenessTest.lean   # Completeness layer tests
└── README.md               # This file

Tests/BimodalTest/Integration/
└── Metalogic_v2IntegrationTest.lean  # End-to-end integration tests
```

## Layer Coverage

### Core Layer (CoreTest.lean, CorePropertyTest.lean)

Tests the foundational components:
- **Consistency**: `Consistent`, `SetConsistent` definitions and properties
- **Provability**: `ContextDerivable`, `DerivationTree` type verification
- **Deduction Theorem**: `deduction_theorem`, `deduction_theorem_converse`
- **Maximal Consistent Sets**: `set_lindenbaum`, `mcs_contains_or_neg`, `mcs_modus_ponens`

### Soundness Layer (SoundnessTest.lean, SoundnessPropertyTest.lean)

Tests all 15 axiom validity lemmas:

| Axiom | Lemma | Description |
|-------|-------|-------------|
| Prop K | `prop_k_valid` | `(phi -> psi -> chi) -> (phi -> psi) -> (phi -> chi)` |
| Prop S | `prop_s_valid` | `(phi -> psi -> chi) -> (psi -> phi -> chi)` |
| Modal T | `modal_t_valid` | `[]phi -> phi` |
| Modal 4 | `modal_4_valid` | `[]phi -> [][]phi` |
| Modal B | `modal_b_valid` | `phi -> []<>phi` |
| Modal 5 | `modal_5_collapse_valid` | `<>phi -> []<>phi` |
| Modal K | `modal_k_dist_valid` | `[](phi -> psi) -> []phi -> []psi` |
| Ex Falso | `ex_falso_valid` | `bot -> phi` |
| Peirce | `peirce_valid` | `((phi -> psi) -> phi) -> phi` |
| Temp K | `temp_k_dist_valid` | `F(phi -> psi) -> Fphi -> Fpsi` |
| Temp 4 | `temp_4_valid` | `Fphi -> FFphi` |
| Temp A | `temp_a_valid` | `Pphi -> Fphi` |
| Temp L | `temp_l_valid` | `Fphi -> FPphi` |
| Modal Future | `modal_future_valid` | `[]phi -> Fphi` |
| Temp Future | `temp_future_valid` | `FFphi -> Fphi` |

Also tests:
- Soundness theorem application (`soundness : Gamma |- phi -> Gamma |= phi`)
- Inference rule soundness (modus ponens, necessitation)

### Representation Layer (RepresentationTest.lean)

Tests canonical model construction:
- **Canonical World State**: `CanonicalWorldState`, carrier properties
- **Canonical Model**: `canonicalFrame`, `canonicalModel`
- **Truth Lemma Variants**: For all formula constructors
  - `truthLemma_atom`
  - `truthLemma_bot`
  - `truthLemma_imp`
  - `truthLemma_box`
  - `truthLemma_all_past`
  - `truthLemma_all_future`
- **Representation Theorem**: `representation_theorem`, `strong_representation_theorem`
- **MCS Properties**: `canonical_modus_ponens`, `necessitation_lemma`

### Completeness Layer (CompletenessTest.lean)

Tests completeness theorems:
- **Weak Completeness**: `weak_completeness : valid phi -> [] |- phi`
- **Strong Completeness**: `strong_completeness : Gamma |= phi -> Gamma |- phi`
- **Equivalences**:
  - `provable_iff_valid : [] |- phi <-> valid phi`
  - `context_provable_iff_entails : Gamma |- phi <-> Gamma |= phi`
- **Helper Functions**: `impChain` and `imp_chain_unfold`

### Integration Tests (Metalogic_v2IntegrationTest.lean)

End-to-end workflow tests:
- Core -> Soundness integration
- Soundness <-> Completeness round-trips
- Core -> Representation flow
- Full metalogic workflow (derive -> soundness -> completeness)
- FMP hub export verification

## Running Tests

```bash
# Build all Metalogic_v2 tests
lake build BimodalTest.Metalogic_v2.CoreTest
lake build BimodalTest.Metalogic_v2.CorePropertyTest
lake build BimodalTest.Metalogic_v2.SoundnessTest
lake build BimodalTest.Metalogic_v2.SoundnessPropertyTest
lake build BimodalTest.Metalogic_v2.RepresentationTest
lake build BimodalTest.Metalogic_v2.CompletenessTest

# Build integration test
lake build BimodalTest.Integration.Metalogic_v2IntegrationTest

# Build all BimodalTest (includes Metalogic_v2)
lake build BimodalTest
```

## Known Limitations

### Axiom Dependency

The completeness theorems rely on the axiom `representation_theorem_backward_empty`:
```lean
axiom representation_theorem_backward_empty :
  ∀ phi : Formula, valid phi → Inconsistent [Formula.neg phi]
```

This axiom asserts that if phi is valid (true in all models), then `[neg phi]` is inconsistent (derives bottom). This makes all completeness results `noncomputable`.

### Sorries in Core

There is a known sorry in `Core/Basic.lean` for `empty_context_consistent`. The CorePropertyTest includes a TODO placeholder for this.

### Property Testing

The property tests use proof-based assertions rather than Plausible runtime checks due to pre-existing generator infrastructure issues. The tests verify universal properties as theorems:

```lean
-- Example from SoundnessPropertyTest.lean
theorem prop_k_valid_forall :
    ∀ phi psi chi : Formula, valid (Formula.k phi psi chi) :=
  fun phi psi chi => prop_k_valid phi psi chi
```

## Generator Usage

The existing `Tests/BimodalTest/Property/Generators.lean` provides formula generators for property-based testing. However, the current tests use proof-based verification due to complexity in the Plausible integration.

## Architecture Overview

The tests mirror the Metalogic_v2 layered architecture:

```
                    ┌─────────────────┐
                    │      FMP.lean   │  (central hub)
                    │    (exports)    │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  Completeness   │ │  Decidability   │ │   Compactness   │
│  (valid→⊢)      │ │  (finite search)│ │  (fin→∞)        │
└─────────────────┘ └─────────────────┘ └─────────────────┘
         ▲                   ▲                   ▲
         │                   │                   │
         └───────────────────┼───────────────────┘
                             │
                    ┌────────┴────────┐
                    │ Representation  │
                    │ (canonical mdl) │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │   Soundness     │
                    │ (⊢→valid)       │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │      Core       │
                    │ (MCS, deduct)   │
                    └─────────────────┘
```

## References

- `Bimodal/Metalogic_v2/FMP.lean` - Central hub with all exports
- `Bimodal/Metalogic_v2/Core/` - Foundation layer
- `Bimodal/Metalogic_v2/Soundness/` - Soundness theorem
- `Bimodal/Metalogic_v2/Representation/` - Canonical model
- `Bimodal/Metalogic_v2/Completeness/` - Completeness theorems
