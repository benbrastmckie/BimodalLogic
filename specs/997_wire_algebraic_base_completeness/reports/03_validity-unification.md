# Research Report: Validity Definition Unification Analysis

**Task**: 997 - Wire Algebraic Base Completeness
**Date**: 2026-03-19
**Focus**: Analyzing validity definition proliferation and unification possibilities

## Summary

This report addresses the user's concern about multiple validity definitions being a liability. The analysis reveals that the codebase currently has ONE canonical semantic validity (`valid`) in `Bimodal.Semantics.Validity`, but a SECOND satisfaction relation (`satisfies_at`) has emerged from the FlagBFMCS canonical model construction. The key finding is that `valid_flagbfmcs` does NOT exist as a separate definition - rather, there is a definitional gap between `satisfies_at` (FlagBFMCS) and `truth_at` (TaskFrame), which creates the appearance of competing validity notions.

## Validity Definition Inventory

### 1. Canonical Semantic Validity (THE definition)

**Location**: `Theories/Bimodal/Semantics/Validity.lean:72`

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

**Purpose**: THE semantic validity definition. A formula is valid iff true at ALL positions in ALL models over ALL temporal domains.

**Quantification Structure**:
- Universal over temporal domain type `D : Type`
- Universal over task frame `F : TaskFrame D`
- Universal over model `M : TaskModel F`
- Universal over shift-closed history set `Omega`
- Universal over history `τ ∈ Omega`
- Universal over time `t : D`

### 2. Parameterized Validity Variants (specializations, not duplicates)

**Location**: `Theories/Bimodal/FrameConditions/Validity.lean`

| Definition | Purpose |
|------------|---------|
| `valid_over D φ` | Validity fixed to domain D (e.g., `valid_over Int`) |
| `valid_linear φ` | Validity over LinearTemporalFrame |
| `valid_dense_fc φ` | Validity over DenseTemporalFrame |
| `valid_discrete_fc φ` | Validity over DiscreteTemporalFrame |

**Assessment**: These are NOT competing definitions - they are specializations of `valid` with proven equivalences:
- `valid_over_of_valid`: `valid φ → valid_over D φ`
- `valid_of_forall_valid_over`: `(∀ D, valid_over D φ) → valid φ`
- `valid_dense_fc_iff_valid_dense`: Equivalence established

### 3. FlagBFMCS Satisfaction Relation (internal construction)

**Location**: `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean:135`

```lean
def satisfies_at (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) : Formula → Prop
  | .atom p => Formula.atom p ∈ (chainFMCS F).mcs x
  | .bot => False
  | .imp ψ χ => satisfies_at B F hF x ψ → satisfies_at B F hF x χ
  | .box φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      MCSBoxContent x.val.world ⊆ MCSBoxContent x'.val.world →
      satisfies_at B F' hF' x' φ
  | .all_future φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      x.val < x'.val → satisfies_at B F' hF' x' φ
  | .all_past φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      x'.val < x.val → satisfies_at B F' hF' x' φ
```

**Purpose**: Internal satisfaction relation for the canonical model construction. This is NOT a validity definition - it defines truth at a position in a specific FlagBFMCS model.

**Note**: There is NO `valid_flagbfmcs` definition in the codebase. The previous report (02_post-flagbfmcs-analysis.md) proposed this as a possible future direction, but it was never implemented.

## The Structural Gap

### Why Two Satisfaction Relations Exist

The codebase has TWO satisfaction relations because they operate over fundamentally different structures:

| Relation | Domain Type | World Structure | Temporal Structure |
|----------|-------------|-----------------|-------------------|
| `truth_at` | `D : Type` with `AddCommGroup D` | `WorldHistory F` | Time points `t : D` |
| `satisfies_at` | `CanonicalMCS` (no group structure) | `(Flag, ChainFMCSDomain)` | Preorder `<` on CanonicalMCS |

### The Type-Theoretic Obstacle

`TaskFrame D` requires `D` to have `AddCommGroup D`, `LinearOrder D`, and `IsOrderedAddMonoid D`.

`CanonicalMCS` has:
- `Preorder CanonicalMCS` (via g_content inclusion)
- NO `Zero` (no distinguished MCS)
- NO `Add` (MCS + MCS is meaningless)
- NO `Neg` (MCS negation is meaningless)

**Consequence**: `TaskFrame CanonicalMCS` is impossible to instantiate directly.

### The Definitional Divergence

| Aspect | `truth_at` | `satisfies_at` |
|--------|------------|----------------|
| Box quantifies over | `σ ∈ Omega` (world histories) | `(F', x')` with BoxContent subset |
| Temporal quantifies over | `s : D` with `s < t` or `t < s` | `x'.val < x.val` (MCS ordering) |
| Atom truth | `τ.domain t` + valuation | MCS membership |
| History structure | `WorldHistory F` with domain | Flag structure (maximal chain) |

## Analysis: Is This Proliferation?

### No - These Serve Different Purposes

1. **`valid`**: The semantic specification (what validity means mathematically)
2. **`satisfies_at`**: The canonical model construction (how we prove completeness)

The situation is analogous to having:
- `List.length : List α → Nat` (specification)
- `Array.size : Array α → Nat` (implementation)

Both compute "length" but for different representations. They should be equivalent, and proving that equivalence is meaningful.

### Yes - There is a Missing Bridge

The codebase proves:
```lean
theorem FlagBFMCS_completeness_set (S : Set Formula) (h_cons : SetConsistent S) :
    ∃ (B : FlagBFMCS),
      ∀ φ ∈ S, satisfies_at B B.eval_flag B.eval_flag_mem B.eval_element φ
```

But this does NOT directly imply:
```lean
-- NOT PROVEN:
theorem completeness (φ : Formula) (h_cons : SetConsistent {φ}) : ¬valid φ.neg → ...
```

Because `satisfies_at` is not connected to `truth_at` / `valid`.

## Options for Unification

### Option A: Prove Structural Equivalence

Prove that `FlagBFMCS.World B` can be viewed as a TaskFrame model.

**Approach**:
1. Define `FlagBFMCS_as_TaskFrame : FlagBFMCS → TaskFrame (FlagBFMCS.World B)`
2. Prove `satisfies_at_iff_truth_at`: Bridge lemma connecting the two

**Obstacle**: FlagBFMCS.World is `Σ F, ChainFMCSDomain F` which has `Preorder` but not `AddCommGroup`.

**Solution Path**: Use `Int` as the temporal domain and embed FlagBFMCS positions into `Int`-indexed structures (this is what the existing algebraic approach does via `IntFMCSTransfer`).

### Option B: Generalize Validity Definition

Modify `valid` to not require `AddCommGroup D`:

```lean
def valid_general (φ : Formula) : Prop :=
  ∀ (D : Type) [Preorder D] ... (other weaker constraints)
    (F : TaskFrame_General D) ...
```

**Problem**: This changes the mathematical content. The `AddCommGroup` structure is essential for time-shift invariance properties used in soundness proofs.

### Option C: Accept Two Completeness Theorems (Current State)

Keep:
1. `FlagBFMCS_completeness` - completeness relative to `satisfies_at`
2. `algebraic_base_completeness` (with sorries) - completeness relative to `valid`

Document that:
- Both express the same mathematical theorem
- The first is sorry-free, the second connects to the standard `valid` definition
- Equivalence is "morally clear" but not formally proven

### Option D: Prove Semantic Equivalence (Mathematical Level)

Prove that any FlagBFMCS model is semantically equivalent to some TaskFrame model:

```lean
theorem FlagBFMCS_embeds_in_TaskFrame (B : FlagBFMCS) :
    ∃ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
      (TF : TaskFrame D) (TM : TaskModel TF)
      (Omega : Set (WorldHistory TF)) (h_sc : ShiftClosed Omega)
      (τ : WorldHistory TF) (h_mem : τ ∈ Omega) (t : D),
      ∀ φ, satisfies_at B B.eval_flag B.eval_flag_mem B.eval_element φ ↔
           truth_at TM Omega τ t φ
```

This would establish that `valid` captures exactly the same formulas as `satisfies_at`-validity.

## Justification for Current State

### Mathematical Correctness

The `satisfies_at` relation IS a valid Kripke semantics:
- Propositional connectives are standard
- Modal operator (Box) uses accessibility (BoxContent subset)
- Temporal operators (G, H) use temporal ordering (CanonicalMCS order)

This satisfies all the mathematical requirements for a bimodal Kripke model.

### Why Two Relations are Acceptable

1. **Different abstraction levels**: `truth_at` is the semantic specification; `satisfies_at` is the canonical model construction

2. **Standard practice**: Most modal logic texts define validity via arbitrary Kripke models, then prove completeness via canonical models. The two use different structures by design.

3. **Type-theoretic necessity**: Lean's type system cannot directly unify `AddCommGroup` models with `Preorder`-only models. The separation is forced.

### Why Unification Would Be Valuable

1. **Single source of truth**: One `valid` definition means one place to verify correctness

2. **Cleaner theorem statements**: `FlagBFMCS_completeness` could state `¬Derivable Γ φ → ¬(Γ ⊨ φ)` directly

3. **Composability**: Other theorems about `valid` would automatically apply to FlagBFMCS results

## Recommendations

### Immediate (Preserve Current State)

The current architecture is mathematically sound. No action is required for correctness.

### Short-Term (Documentation)

Add documentation explaining:
1. `valid` is THE canonical validity definition
2. `satisfies_at` is an internal construction for completeness proofs
3. The two are mathematically equivalent (morally, not formally proven)

### Medium-Term (Bridge Lemma - Recommended)

Prove the semantic bridge via `Int`-embedding:

```lean
-- In a new file: FlagBFMCSValidityBridge.lean
theorem satisfies_at_iff_valid_at_embedding (B : FlagBFMCS) :
    ∀ φ, satisfies_at B B.eval_flag B.eval_flag_mem B.eval_element φ →
         ∃ (M : TaskModel (B.toTaskFrame_Int))
           (τ : WorldHistory (B.toTaskFrame_Int)),
           truth_at M Set.univ τ 0 φ
```

This would require:
1. Defining `FlagBFMCS.toTaskFrame_Int : FlagBFMCS → TaskFrame Int`
2. Proving the embedding preserves satisfaction

### Long-Term (NOT Recommended: Eliminate satisfies_at)

Attempting to eliminate `satisfies_at` entirely would require either:
- Generalizing `TaskFrame` to not require `AddCommGroup` (breaks soundness proofs)
- Proving FlagBFMCS embeds into `TaskFrame Int` as the primary construction (complex)

The current separation is a reasonable engineering choice given Lean's type system.

## Conclusion

**There is only ONE validity definition** (`valid` in `Bimodal.Semantics.Validity`).

The `satisfies_at` relation is NOT a competing validity definition - it is the satisfaction relation for a specific model construction (FlagBFMCS). The "proliferation" concern is actually a gap in connecting the canonical model to the semantic specification.

The cleanest resolution is proving a bridge lemma showing FlagBFMCS models embed into TaskFrame models, thereby connecting `satisfies_at` satisfaction to `valid` validity. This is a one-time proof that would unify the architecture.

## References

- `Theories/Bimodal/Semantics/Validity.lean` - Canonical validity definition
- `Theories/Bimodal/FrameConditions/Validity.lean` - Parameterized validity variants
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` - satisfies_at definition
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCompleteness.lean` - FlagBFMCS completeness
- `Theories/Bimodal/Semantics/TaskFrame.lean` - TaskFrame structure

## Context Extension Recommendations

none (architectural analysis of existing definitions)
