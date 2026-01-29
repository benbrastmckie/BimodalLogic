# Research Report: Task #738

**Task**: Port FMP to parametric architecture with explicit cardinality bounds
**Date**: 2026-01-29
**Focus**: Porting Finite Model Property from hardcoded Int to parametric duration type D
**Session**: sess_1738179892_7bc375

## Summary

The Finite Model Property (FMP) implementation in `Boneyard/Metalogic_v2/` is hardcoded to use `Int` as the duration type. The task is to port this to the parametric architecture in `Theories/Bimodal/Metalogic/` which uses a generic duration type `D` with `AddCommGroup D`, `LinearOrder D`, and `IsOrderedAddMonoid D` constraints. This research identifies the key components, required changes, and proof strategy.

## Context

### Current Architecture

The codebase has two metalogic implementations:

| Location | Architecture | Status |
|----------|--------------|--------|
| `Theories/Bimodal/Metalogic/` | Parametric universal canonical model | Active, used for completeness |
| `Theories/Bimodal/Boneyard/Metalogic_v2/` | Hardcoded Int, finite model construction | Deprecated but FMP not yet ported |

The parametric `Metalogic/` has:
- Completeness (weak and strong)
- Compactness
- No FMP module

The deprecated `Boneyard/Metalogic_v2/` has:
- FMP with explicit cardinality bounds
- Constructive finite model construction
- All hardcoded to `Int` duration

### What FMP Provides

The FMP bridges representation to decidability:

```
FMP: satisfiable φ → ∃ finite model M with |worlds| ≤ 2^|closure(φ)|
```

Key theorems in `Boneyard/Metalogic_v2/Representation/FiniteModelProperty.lean`:

1. **`finite_model_property`**: Structural statement (satisfiable → finite model exists)
2. **`finite_model_property_constructive`**: Provides explicit `Fintype` witness and cardinality bound
3. **`semanticWorldState_card_bound`**: `Fintype.card (SemanticWorldState φ) ≤ 2 ^ closureSize φ`
4. **`consistent_implies_satisfiable`**: Connects consistency to satisfiability

## Findings

### Components to Port

#### 1. Closure Infrastructure (`Closure.lean`)
**Status**: Already parametric-compatible (no duration type used)

Key definitions that work unchanged:
- `closure : Formula → Finset Formula` - subformula closure
- `closureSize : Formula → Nat` - cardinality bound
- `closureWithNeg` - closure with negations
- `ClosureMaximalConsistent` - closure-restricted MCS
- `mcs_projection_is_closure_mcs` - projection theorem

**Port effort**: Minimal (just move files, update imports)

#### 2. Finite World State (`FiniteWorldState.lean`)
**Status**: Needs parametric duration for temporal bounds

Key definitions to parametrize:
- `FiniteTime (k : Nat) := Fin (2 * k + 1)` - bounded time domain
- `FiniteHistory` - sequence of world states over time
- `finite_history_from_state` - history construction

**Issue**: `FiniteTime` maps to `Int` via `toInt`. For parametric D, need abstract bounded subtype.

**Approach Options**:
1. Keep `Int` for FiniteTime but make the frame parametric over D
2. Define `BoundedTime D (k : Nat)` as subtype of D with bounds ±k
3. Use Finset-based time domain instead of Fin

**Recommendation**: Option 1 - keep `Int` for finite construction, rely on `Int ↪ D` for any ordered group

#### 3. Semantic Canonical Frame/Model (`SemanticCanonicalModel.lean`)
**Status**: Hardcoded to Int, needs full parametrization

Definitions to port:
```lean
-- Current (hardcoded)
def SemanticCanonicalFrame (φ : Formula) : TaskFrame Int

-- Target (parametric)
def SemanticCanonicalFrame (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (φ : Formula) : TaskFrame D
```

**Key Challenge**: The compositionality axiom proof has a `sorry`:
```lean
compositionality := fun w u v x y h1 h2 => by
  -- TODO: Prove compositionality holds for semantic canonical task relation
  sorry  -- Task #616 removed named theorem, sorry now inlined
```

This is documented in `Metalogic/README.md` as a known gap.

#### 4. FMP Theorems (`FiniteModelProperty.lean`)
**Status**: Uses `TaskFrame Int`, needs parametric statements

Key theorems to parametrize:
```lean
-- Current signature
theorem finite_model_property_constructive (φ : Formula) (h_sat : formula_satisfiable φ) :
    ∃ (F : TaskFrame Int) (M : TaskModel F) ...

-- Target signature
theorem finite_model_property_constructive (D : Type) [AddCommGroup D] ...
    (φ : Formula) (h_sat : formula_satisfiable φ) :
    ∃ (F : TaskFrame D) (M : TaskModel F) ...
```

### Proof Dependencies

The FMP proof relies on:

1. **Lindenbaum's Lemma**: `set_lindenbaum` - extend consistent sets to MCS
2. **MCS Projection**: `mcs_projection_is_closure_mcs` - project to closure
3. **World State Construction**: `worldStateFromClosureMCS` - build finite world
4. **Semantic History**: `semantic_world_state_has_world_history` - build history
5. **Truth Bridge**: Connect finite model truth to general `truth_at`

The truth bridge has a `sorry` at line 481:
```lean
-- truth_at (SemanticCanonicalModel φ) tau 0 φ
-- This requires a "truth bridge" connecting finite model truth to general truth_at.
-- The bridge requires formula induction with problematic modal/temporal cases.
sorry
```

### Cardinality Bound Infrastructure

The bound `2^closureSize φ` comes from:

```
SemanticWorldState φ ↪ FiniteWorldState φ ↪ FiniteTruthAssignment φ
|SemanticWorldState| ≤ |FiniteWorldState| ≤ |FiniteTruthAssignment| = 2^|closure φ|
```

This chain is established in `semanticWorldState_card_bound` and is purely combinatorial (no duration type involved), so it ports directly.

### Integration Points

The FMP connects to:

1. **Decidability** (`Decidability/Correctness.lean`): Uses FMP for `validity_decidable_via_fmp`
2. **Compactness** (`Applications/Compactness.lean`): Uses FMP for finite approximation
3. **Representation**: Needs `representation_theorem` from parametric layer

### Known Sorries to Address

| Location | Sorry | Blocking? |
|----------|-------|-----------|
| `SemanticCanonicalModel.compositionality` | Task relation composition | Yes - frame validity |
| `FiniteModelProperty.lean:481` | Truth bridge | Yes - theorem statement |
| `UniversalCanonicalModel.lean:83-86` | G⊥/H⊥ not in MCS | No - parallel issue in parametric |

## Recommendations

### Phase 1: Move Closure Infrastructure
1. Copy `Closure.lean` to `Metalogic/Representation/Closure.lean`
2. Update imports to use `Bimodal.Metalogic.Core`
3. Verify closure definitions work with parametric MCS from `CoherentConstruction.lean`

### Phase 2: Port FiniteWorldState with Parametric Time
1. Create `Metalogic/Representation/FiniteWorldState.lean`
2. Keep `FiniteTime` using Fin but make it generic via type parameter
3. Define `FiniteFrame D` that wraps `TaskFrame D` with Fintype constraint

### Phase 3: Port SemanticCanonicalModel
1. Create `Metalogic/Representation/SemanticCanonicalModel.lean`
2. Make frame parametric over D
3. Address compositionality sorry (may need filtration argument)

### Phase 4: Port FMP Theorems
1. Create `Metalogic/FMP.lean` as hub module
2. Port `finite_model_property` with parametric statement
3. Port cardinality bound theorem
4. Document truth bridge gap (same as existing `sorry`)

### Alternative: Minimal Port

For faster progress, a minimal port could:
1. State FMP parametrically but prove only for `D = Int`
2. Use `Int` coercion lemmas to extend to other D
3. Focus on cardinality bounds (the actual novel content)

This matches the approach in `UniversalCanonicalModel.lean` which uses `ℤ` despite parametric definitions.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Compositionality sorry blocks frame validity | High | Use same approach as Boneyard (leave sorry) |
| Truth bridge complexity | Medium | Leave sorry, document as known gap |
| Time parametrization complicates proofs | Medium | Keep Int for finite construction |
| Integration with existing parametric layer | Low | Follow established patterns |

## References

- `Theories/Bimodal/Metalogic/README.md` - Architecture documentation
- `Theories/Bimodal/Boneyard/Metalogic_v2/Representation/FiniteModelProperty.lean` - Source FMP
- `Theories/Bimodal/Semantics/TaskFrame.lean` - Parametric frame definition
- Modal Logic, Blackburn et al., Chapter 4 (Finite Model Property)
- Wu, M., Verified Decision Procedures for Modal Logics

## Next Steps

1. Run `/plan 738` to create implementation plan
2. Decide between full parametric port vs minimal Int-based port
3. Prioritize closure infrastructure (no sorries, direct port)
