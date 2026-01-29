# Research Report: Task #749

**Task**: Establish sorry-free completeness using semantic_weak_completeness
**Date**: 2026-01-29
**Focus**: Analyze semantic_weak_completeness and related theorems for sorry-free completeness proof path

## Summary

The codebase has two completeness proof paths: (1) the standard `weak_completeness` in `Metalogic/Completeness/WeakCompleteness.lean` which uses the universal canonical model but has upstream sorries, and (2) the sorry-free `semantic_weak_completeness` in `Metalogic/FMP/SemanticCanonicalModel.lean` which works directly with finite model truth. The key finding is that `semantic_weak_completeness` is fully proven with no sorries, but it operates on a **different type signature** than `valid`. Establishing sorry-free completeness requires bridging from `valid` (universal quantification over all models) to `semantic_truth_at_v2` (quantification over SemanticWorldStates for a specific formula).

## Findings

### 1. Current State of Completeness Theorems

#### Standard `weak_completeness` (with upstream sorries)

**Location**: `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean:183`

```lean
theorem weak_completeness (φ : Formula) : valid φ → ContextDerivable [] φ
```

**Status**: The theorem itself compiles, but has upstream dependencies with sorries:
- **Soundness** (`soundness`): axiomatized with sorry at line 92
- **Representation theorem**: has sorries for `h_no_G_bot` and `h_no_H_bot` boundary conditions
- **Truth lemma**: has sorries in box cases (lines 366, 389) and backward temporal cases (lines 416, 438)

#### Sorry-Free `semantic_weak_completeness`

**Location**: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean:448`

```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (∀ (w : SemanticWorldState phi), semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) →
    ⊢ phi
```

**Status**: Fully proven. The proof (lines 448-505) is complete with no sorries.

**Proof technique**: Contrapositive construction
1. Assume φ is not provable
2. Then {φ.neg} is consistent (via `neg_set_consistent_of_not_provable`)
3. Extend to MCS via Lindenbaum
4. Project to closure MCS
5. Build `FiniteWorldState` where φ is false
6. Build `SemanticWorldState` containing this world state
7. Contradiction with universal truth hypothesis

### 2. Type Signature Gap

The core challenge is the **type mismatch** between:

| Concept | `valid` | `semantic_truth_at_v2` |
|---------|---------|------------------------|
| Models | All TaskModel F over any TaskFrame D | SemanticCanonicalModel for specific φ |
| Worlds | All WorldHistory τ | SemanticWorldState φ (quotient of history-time pairs) |
| Time | All t : D | BoundedTime (temporalBound φ) |
| Quantification | ∀ D ∀ F ∀ M ∀ τ ∀ t | ∀ w : SemanticWorldState φ |

The `valid` definition (from `Semantics/Validity.lean:61`) is:
```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
    truth_at M τ t φ
```

The `semantic_truth_at_v2` definition is:
```lean
def semantic_truth_at_v2 (phi : Formula) (w : SemanticWorldState phi)
    (_t : BoundedTime (temporalBound phi)) (psi : Formula) : Prop :=
  ∃ h_mem : psi ∈ closure phi, (SemanticWorldState.toFiniteWorldState w).models psi h_mem
```

### 3. The Missing Bridge: `valid φ → ∀ w, semantic_truth_at_v2 φ w t φ`

To use `semantic_weak_completeness` for proving `valid φ → ⊢ φ`, we need:
```lean
theorem valid_implies_semantic_truth (φ : Formula) :
    valid φ → ∀ (w : SemanticWorldState φ), semantic_truth_at_v2 φ w (BoundedTime.origin (temporalBound φ)) φ
```

**Why this is the "truth bridge"**: The forward direction of this bridge requires showing that:
- Every SemanticWorldState can be viewed as part of some model-history-time triple
- Validity (truth in all such triples) implies truth in SemanticWorldStates

The existing `semantic_world_state_has_world_history` theorem (line 310) provides:
```lean
theorem semantic_world_state_has_world_history (phi : Formula) (w : SemanticWorldState phi) :
    ∃ (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0),
    tau.states 0 ht = w
```

This shows every SemanticWorldState has a corresponding WorldHistory, but the bridge still needs:
1. The WorldHistory respects the SemanticCanonicalModel valuation
2. Truth at the semantic world state equals `truth_at` in the canonical model

### 4. Known Sorries and Their Impact

| File | Line | Description | Impact on Completeness |
|------|------|-------------|----------------------|
| `SemanticCanonicalModel.lean` | 226 | `compositionality` axiom | **Benign** - not used by semantic_weak_completeness |
| `FiniteModelProperty.lean` | 221 | Truth bridge in constructive FMP | **This is the gap** |
| `WeakCompleteness.lean` | 92 | Soundness | Blocks full `provable_iff_valid` |
| `TruthLemma.lean` | 366, 389, 416, 438 | Box and temporal backward cases | Blocks universal canonical model approach |
| `UniversalCanonicalModel.lean` | 84-86, 164, 182 | G⊥/H⊥ conditions, consistency | Blocks representation theorem |

### 5. Alternative Approaches Analyzed

#### Approach A: Fix the Truth Bridge (Direct)
**Difficulty**: High
**Location**: `FiniteModelProperty.lean:221`

This would require proving that for formula φ and arbitrary w:
- `semantic_truth_at_v2 φ w t φ` is equivalent to `truth_at (SemanticCanonicalModel φ) tau 0 φ`
  where tau is a WorldHistory containing w

The challenge is that `truth_at` for compound formulas (especially temporal operators G and H) requires reasoning about arbitrary world histories, while `semantic_truth_at_v2` only checks finite world state membership.

#### Approach B: Prove valid → semantic hypothesis directly
**Difficulty**: Medium-High
**Advantage**: Doesn't require fixing constructive FMP

The strategy would be:
1. Given `valid φ`, specialize to the SemanticCanonicalModel and canonical history
2. Show that for each SemanticWorldState w, there exists a WorldHistory where w appears at time 0
3. Apply validity to get truth at that configuration
4. Extract the corresponding `semantic_truth_at_v2` claim

The key lemma needed:
```lean
theorem valid_at_semantic_model (φ : Formula) (h_valid : valid φ) (w : SemanticWorldState φ) :
    let tau := (semantic_world_state_has_world_history φ w).choose
    truth_at (SemanticCanonicalModel φ) tau 0 φ
```

#### Approach C: Decidability Route
**Difficulty**: Medium
**Path**: Use the tableau decision procedure

If `decide` is proven complete (currently has sorry at `Decidability/Correctness.lean:194`), then:
- `valid φ` → tableau closes → proof exists → `⊢ φ`

This would give completeness but requires filling the `decide_complete` sorry.

#### Approach D: Accept Partial Result
**Difficulty**: Low
**Status**: Already available

The codebase already provides sorry-free completeness **for the restricted notion**:
- `semantic_weak_completeness` is fully proven
- It provides `⊢ φ` given semantic model truth

This is usable for any formula where we can establish the semantic truth hypothesis through other means (e.g., direct construction for specific formulas).

## Recommendations

### Primary Recommendation: Approach B (Prove valid → semantic hypothesis)

1. **Create a new theorem** in `SemanticCanonicalModel.lean`:
   ```lean
   theorem valid_implies_all_semantic_truth (φ : Formula) :
       valid φ → ∀ (w : SemanticWorldState φ),
         semantic_truth_at_v2 φ w (BoundedTime.origin (temporalBound φ)) φ
   ```

2. **Proof strategy**:
   - Use `semantic_world_state_has_world_history` to get a WorldHistory tau for w
   - Validity gives `truth_at (SemanticCanonicalModel φ) tau 0 φ`
   - Need to show this implies `semantic_truth_at_v2 φ w t φ`
   - This requires proving that truth_at in the semantic model equals semantic_truth_at_v2

3. **Key sub-lemma** (the truth correspondence):
   ```lean
   theorem truth_at_semantic_model_iff (φ : Formula) (w : SemanticWorldState φ)
       (tau : WorldHistory (SemanticCanonicalFrame φ)) (h_dom : tau.domain 0)
       (h_eq : tau.states 0 h_dom = w) :
       truth_at (SemanticCanonicalModel φ) tau 0 φ ↔
         semantic_truth_at_v2 φ w (BoundedTime.origin (temporalBound φ)) φ
   ```

4. **Chain the results**:
   ```lean
   theorem sorry_free_weak_completeness (φ : Formula) : valid φ → ⊢ φ := by
     intro h_valid
     apply semantic_weak_completeness φ
     intro w
     exact valid_implies_all_semantic_truth φ h_valid w
   ```

### Secondary Recommendation: Document Current Capability

Until the bridge is proven, document that the codebase provides:
- **Restricted completeness**: `semantic_weak_completeness` (sorry-free, finite model truth → provability)
- **Full completeness**: `weak_completeness` (with upstream sorries, validity → provability)

The gap is exactly the truth bridge between these two notions.

## References

- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - semantic_weak_completeness
- `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean` - FMP theorems
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - standard completeness
- `Theories/Bimodal/Semantics/Validity.lean` - validity definition
- Task #738 summary - recent FMP port

## Next Steps

1. **Phase 1**: Implement `truth_at_semantic_model_iff` lemma proving that truth_at in the semantic canonical model corresponds to semantic_truth_at_v2
2. **Phase 2**: Use this to prove `valid_implies_all_semantic_truth`
3. **Phase 3**: Chain with `semantic_weak_completeness` to get `sorry_free_weak_completeness`
4. **Verification**: Run `lake build` and confirm no sorries in the chain from `valid` to `⊢`
