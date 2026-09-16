# Bimodal Implementation Status

Module-by-module implementation status for the Bimodal TM logic library.

## Status Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Complete |
| 🔶 | Partial |
| ⏸️ | On Hold |
| ❌ | Not Started |

## Layer 0: Foundation

### Syntax (✅ Complete)

| Module | Status | Notes |
|--------|--------|-------|
| `Formula.lean` | ✅ | Inductive formula type |
| `Context.lean` | ✅ | Proof context operations |

**Features**:
- Inductive formula type with 6 constructors
- Derived operators (neg, and, or, diamond, etc.)
- Context as List Formula

### ProofSystem (✅ Complete)

| Module | Status | Notes |
|--------|--------|-------|
| `Axioms.lean` | ✅ | 45 axiom constructors (Base 37 / Dense 2 / ZTime 3 / RTime 3) |
| `Derivation.lean` | ✅ | DerivationTree type |

**Features**:
- All 45 axiom constructors organized into base (37), dense (2), ZTime (3), and RTime (3) layers
- 7 inference rule constructors
- Computable height function

## Layer 1: Semantics (✅ Complete)

| Module | Status | Notes |
|--------|--------|-------|
| `TaskFrame.lean` | ✅ | Frame structure |
| `PartialHistory.lean` | ✅ | Temporal traces |
| `TaskModel.lean` | ✅ | Models with valuation |
| `Truth.lean` | ✅ | Truth evaluation |
| `MinusTruth.lean` | ✅ | `MinusTruthAt`, native truth evaluation for the tense-primitive base language |
| `Validity.lean` | ✅ | Semantic consequence |
| `MinusValidity.lean` | ✅ | The four base-language validity predicates plus `MinusSemanticConsequence` |
| `Correspondence/Galois.lean` | ✅ | `Th`/`Mod` Galois connection; `galoisClosed_mod` (axiomatizable = Galois-closed), `galoisClosed_of_indicator` (single-formula closure method) |
| `Correspondence/Indicator.lean` | ✅ | `galoisClosed_sat_dense` and `galoisClosed_isDiscrete` (bare `TaskFrame.IsDiscrete` clause) -- the two positive Galois-closure results, via `validOn_nextTop_iff`/`validOn_nextTop_iff_isDiscrete` |

**Features**:
- Task frame structure (worlds, times, task relation)
- Truth evaluation at model-history-time triples
- Validity and semantic consequence definitions

## Layer 2: Metalogic (✅ Complete)

| Module | Status | Notes |
|--------|--------|-------|
| `Metalogic/SoundnessLemmas.lean` | ✅ | Bridge lemmas |
| `Metalogic/Soundness.lean` | ✅ | Soundness theorem |
| `Metalogic/Core/DeductionTheorem.lean` | ✅ | Deduction theorem |
| `Metalogic/BXCanonical/Completeness.lean` | ✅ | `completeness`, `completeness_dense`, `completeness_ztime` -- all sorryAx-free |
| `Metalogic/StrongCompleteness.lean` | ✅ | `completeness_rtime` and the four `consequence_completeness_*` theorems |
| `Metalogic/Decidability/` | 🔶 | Decision procedure implemented; sound direction proved, completeness direction open |
| `Metalogic/DiscreteNonCompactness.lean` | ✅ | Machine-refutes ZTime strong completeness |
| `Metalogic/SetConsequence.lean` | ✅ | Set-based consequence layer; states `CompactBase`/`CompactDense` and their strong-completeness and model-existence siblings |
| `Metalogic/Compactness.lean` | ✅ | Discharges all six: `modelExistenceBase`/`modelExistenceDense` by ultraproduct, `compactBase`/`compactDense`, `strongCompletenessBase`/`strongCompletenessDense` -- all sorryAx-free |
| `Metalogic/Conservativity.lean` | ✅ | Aggregator: the forward-conservativity prohibition and the CEB/CEF status record; re-exports the five modules below |
| `Metalogic/Conservativity/Backward.lean` | ✅ | TM/TM+ backward bridge |
| `Metalogic/Conservativity/MinusLanguageSoundness.lean` | ✅ | BL soundness at Base/Dense/ZTime/RTime by composition; `truthAt_tr`, the validity forms, and `minus_not_derivable_nil_bot{,_discrete}` |
| `Metalogic/Independence/` | ✅ | Three independence results, including `sat_rtime_ssubset_mod_axiomSet` (`Sat .RTime` not Galois-closed -- definability of the model class, distinct from the open RTime strong-completeness question above) and `sat_ztime_ssubset_mod_axiomSet` (`Sat .ZTime` not Galois-closed) |
| `Metalogic/WeakCanonical/Kamp/` | ✅ | `kampPriorExpressiveCompleteness` -- `{U, S}` expressively complete relative to monadic first-order logic **for Prior structures**, sorry-free (`propext`, `Classical.choice`, `Quot.sound`); load-bearing via `uSExpressivelyCompleteOverPrior` |

**Soundness** (✅):
- Full soundness proof: `derivable Γ φ → SemanticConsequence Γ φ`, over all 45 axiom
  constructors (Base 37 / Dense 2 / ZTime 3 / RTime 3, per `Axiom.minFrameClass` in
  `FormalSystem/ProofSystem/Axioms.lean`)
- Base-language soundness (`minus_soundness` and its dense / ZTime / RTime siblings,
  `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean`), stated against the native `MinusTruthAt` of
  `FormalSystem/Semantics/MinusLanguage/MinusTruth.lean` and obtained by composing
  `Conservativity.translate` with the four theorems above across the truth-transfer bridge
  `truthAt_tr`

**Completeness** (✅ Complete for the weak/finite-context forms):
- Type definitions complete
- Lindenbaum's lemma proved (`set_lindenbaum`, `FormalSystem/Metalogic/Core/MaximalConsistent.lean`)
- Canonical model structure complete
- Truth lemma proved
- All four weak completeness theorems -- `completeness`, `completeness_dense`,
  `completeness_ztime`, `completeness_rtime` -- are fully proven and sorryAx-free at
  exactly `[propext, Classical.choice, Quot.sound]` (check C2).
- `countermodel_discrete` is **proved**, not dead code, at
  `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean`.
- **Strong** completeness (arbitrary infinite `Γ : Set Formula`) is a separate question with
  three distinct statuses across the frame classes -- see
  [Known Limitations](known-limitations.md).

## Layer 3: Theorems (✅ Complete)

### Perpetuity (✅ 100%)

| Theorem | Status | Notes |
|---------|--------|-------|
| P1 | ✅ | `□φ ↔ □◇□φ` |
| P2 | ✅ | `◇□φ → □◇φ` |
| P3 | ✅ | `□φ ↔ △◇□φ` |
| P4 | ✅ | Complete |
| P5 | ✅ | Complete |
| P6 | ✅ | Complete (`Bridge.lean`) |

### Modal S4/S5 (✅ Complete)

| Module | Status | Notes |
|--------|--------|-------|
| `ModalS4.lean` | ✅ | All 4 theorems proven, sorry-free |
| `ModalS5.lean` | ✅ | Modal 5 proven |

### Propositional (✅ Complete)

- All core propositional theorems proven
- Combinators (identity, composition, flip, etc.)

## Layer 4: Automation (🔶 Partial)

| Module | Status | Notes |
|--------|--------|-------|
| `Tactics.lean` | ✅ | Core tactics working |
| `Automation/ProofSearch/Core.lean` | ✅ | Builds cleanly |
| `Automation/ProofSearch/Strategies.lean` | ✅ | Builds cleanly |

**Working**:
- `modal_t` tactic
- `apply_axiom` tactic
- Aesop integration

**Issues**:
- Bounded search timeout issues

## Examples (✅ Complete)

| Module | Status | Sorries |
|--------|--------|---------|
| `BimodalProofs.lean` | ✅ | 0 |
| `TemporalStructures.lean` | ✅ | 0 |

## Overall Statistics

| Metric | Value |
|--------|-------|
| Total Lean files | 539 |
| Lines of code | 170,898 |
| Comment lines | 96,290 |
| Known sorries | 0 |
| Build status | ✅ Passes |

Do not hardcode these figures elsewhere. Reproduce them:

```bash
cloc --include-lang=Lean --exclude-dir=.lake,lake-packages,Boneyard .
```

The sorry count is asserted, not documented: check C3 of
`scripts/check-module-invariants.sh` requires a hard zero across `FormalSystem/`
(`Boneyard/` excluded).

## Verification

```bash
# Build the library (default target)
lake build

# Build tests
lake build BimodalTest

# Assert the sorry inventory is zero, plus the other structural invariants
bash scripts/check-module-invariants.sh --no-build
```

`FormalSystem` (the default) and `BimodalTest` are the library targets; there is no `Bimodal`
target.

## Related

- [Known Limitations](known-limitations.md) - Current limitations
- [Feature Registry](FEATURE_REGISTRY.md) - Feature tracking and capabilities
- [API Reference](../reference/API_REFERENCE.md) - Declaration-level reference
