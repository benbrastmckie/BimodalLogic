# Research Report: Rat vs Int Compatibility for Base and Discrete Completeness

**Task**: 1006 - canonical_taskframe_completeness
**Date**: 2026-03-19
**Session**: sess_1773988180_ef4478
**Focus**: Analyzing whether D=Rat for base completeness creates conflicts with D=Int for discrete extension

## Executive Summary

**Verdict: COMPATIBLE with conditional architecture.**

Using D=Rat for base TM completeness (task 1006) does NOT create conflicts with D=Int for discrete extension (task 989). The two completeness theorems operate in **separate domains** with **separate parametric instantiations**. The key insight is that:

1. **Base completeness** (task 1006): Uses `ParametricCanonicalTaskFrame Rat` and `BFMCS Rat`
2. **Discrete completeness** (task 989): Uses `ParametricCanonicalTaskFrame Int` with additional SuccOrder constraints

These are **independent theorem statements**, not dependent constructions. The parametric pipeline is D-polymorphic by design.

## Background: The Question

Task 1006's v3 plan proposes using `FMCSTransfer` with `D = Rat` for base TM completeness. The concern is whether this choice creates architectural conflicts when task 989 needs `D = Int` with `SuccOrder` for discrete completeness.

### Key Structures Under Analysis

| Component | Location | D Parameter |
|-----------|----------|-------------|
| `ParametricCanonicalTaskFrame D` | `ParametricCanonical.lean:199-206` | Polymorphic |
| `FMCSTransfer D` | `FMCSTransfer.lean:80-93` | Polymorphic |
| `BFMCS D` | `BFMCS.lean` | Polymorphic |
| `DiscreteCanonicalTaskFrame` | `DiscreteInstantiation.lean:81` | `= ParametricCanonicalTaskFrame Int` |
| `DenseCanonicalTaskFrame` | `DenseInstantiation.lean:84` | `= ParametricCanonicalTaskFrame Rat` |

## Mathematical Analysis

### Order-Theoretic Independence

The core mathematical insight is that **order-embeddings into Rat and order-embeddings into Int serve different purposes**:

#### For Base TM (D=Rat)

- **Goal**: Embed any countable linear order (Flag chain) order-preservingly
- **Mathlib theorem**: `Order.embedding_from_countable_to_dense`
  ```lean
  theorem Order.embedding_from_countable_to_dense [Countable α] [DenselyOrdered β] [Nontrivial β] :
      Nonempty (α ↪o β)
  ```
- **Application**: `FlagChain F ↪o Rat` exists because:
  - `FlagChain F` is countable (inherited from `CanonicalMCS`)
  - `Rat` is densely ordered and nontrivial
- **No SuccOrder needed**: Base TM doesn't have the DF axiom, so no discrete structure required

#### For Discrete TM (D=Int)

- **Goal**: Embed a discrete linear order (with SuccOrder) into Int
- **Mathlib theorem**: `orderIsoIntOfLinearSuccPredArch`
  ```lean
  theorem orderIsoIntOfLinearSuccPredArch [LinearOrder D] [SuccOrder D] [PredOrder D]
      [NoMaxOrder D] [NoMinOrder D] [IsSuccArchimedean D] : D ≃o Int
  ```
- **Application**: `DiscreteTimelineQuot ≃o Int` (order-isomorphism, not just embedding)
- **Requires**: The DF axiom induces `SuccOrder` structure on the canonical construction

### Why They Don't Conflict

The two completeness theorems have **completely different theorem statements**:

**Base completeness (task 1006)**:
```lean
theorem base_completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree [] φ)
```
where `valid` quantifies over ALL TaskFrames D.

**Discrete completeness (task 989)**:
```lean
theorem discrete_completeness (φ : Formula) :
    valid_discrete φ → Nonempty (DerivationTree_discrete [] φ)
```
where `valid_discrete` quantifies over discrete TaskFrames (with SuccOrder).

These are **separate proof goals**. Using Rat in one proof and Int in another is not a conflict -- it's exactly how the parametric infrastructure is designed to work.

### Parametric Pipeline Architecture

```
                    ParametricCanonicalTaskFrame D
                               ↓
         +--------------------+-----------------+
         |                    |                 |
    D = Int              D = Rat           D = ...
         |                    |                 |
  Discrete Frame        Dense Frame        Future extensions
         |                    |
    Task 989             Task 1006
```

The pipeline components (`parametric_canonical_task_rel`, `parametric_to_history`, `parametric_shifted_truth_lemma`) are all D-polymorphic. Each instantiation is independent.

## FMCSTransfer Compatibility

### FMCSTransfer Requirements

From `FMCSTransfer.lean:80-93`:
```lean
structure FMCSTransfer (D : Type*) [Preorder D] where
  embed : CanonicalMCS →o D
  retract : D → CanonicalMCS
  retract_left_inverse : ∀ w, retract (embed w) = w
  embed_retract_eq : ∀ d, embed (retract d) = d  -- surjectivity
  retract_lt : ∀ d₁ d₂, d₁ < d₂ → retract d₁ < retract d₂
  embed_lt : ∀ w₁ w₂, w₁ < w₂ → embed w₁ < embed w₂
```

**Key observation**: `FMCSTransfer` only requires `[Preorder D]`. It does NOT require:
- `SuccOrder D`
- `PredOrder D`
- `DenselyOrdered D`

The transfer infrastructure is maximally polymorphic.

### Per-Task FMCSTransfer Instantiation

| Task | D | FMCSTransfer Source | Additional D Constraints |
|------|---|---------------------|--------------------------|
| 1006 (base) | Rat | `Order.embedding_from_countable_to_dense` | None |
| 988 (dense) | Rat | Same as 1006 + DenselyOrdered proof | `DenselyOrdered Rat` |
| 989 (discrete) | Int | `orderIsoIntOfLinearSuccPredArch` | `SuccOrder Int`, `PredOrder Int` |

Each task builds its own `FMCSTransfer D` using different mathematical machinery. There's no shared state or inheritance conflict.

## Discrete Extension Analysis

### Task 989 Requirements

From `DiscreteCompleteness.lean:56-66`:
```
Domain D ≃o ℤ requires:
- LinearOrder D
- SuccOrder D
- PredOrder D
- NoMaxOrder D and NoMinOrder D
- IsSuccArchimedean D
```

### Why Int, Not Rat, for Discrete

The discrete axiom DF (`(F⊤ ∧ φ ∧ Hφ) → F(Hφ)`) enforces that between any world and its immediate successor, there are no intermediate worlds. This is the **covering property** that induces `SuccOrder`.

Rat **cannot** have this structure because Rat is densely ordered -- between any two rationals there's always another.

**Critical point**: The discrete completeness proof **must** use a discrete domain like Int. It cannot use Rat. This is not a conflict with task 1006 -- it's the correct mathematical separation of concerns.

### Discrete Extension is Independent

Task 989's approach:
1. The DF axiom induces `SuccOrder` on the canonical model's timeline
2. By Mathlib's characterization, `DiscreteTimelineQuot ≃o Int`
3. Transfer temporal properties along the isomorphism
4. Apply parametric pipeline with D=Int

This is **completely independent** of whether task 1006 uses D=Rat. The discrete proof doesn't depend on base completeness -- it proves a **stronger** result (completeness over a restricted class of frames).

## Potential Concerns and Resolutions

### Concern 1: "Will future code assume D=Rat everywhere?"

**Resolution**: No. The parametric infrastructure explicitly uses type parameter D. Code like:
```lean
abbrev DiscreteCanonicalTaskFrame : TaskFrame Int := ParametricCanonicalTaskFrame Int
abbrev DenseCanonicalTaskFrame : TaskFrame Rat := ParametricCanonicalTaskFrame Rat
```
shows that instantiation is intentionally separate.

### Concern 2: "Does FlagBFMCS construction couple to specific D?"

**Resolution**: No. `FlagBFMCS` in `FlagBFMCS.lean` is D-independent -- it operates on the abstract `CanonicalMCS` structure. The conversion to `BFMCS D` happens via `bfmcs_from_flagbfmcs` which takes D as a parameter.

### Concern 3: "Will the completeness theorems compose poorly?"

**Resolution**: They don't need to compose. The relationships are:
- Base completeness: `valid φ → provable φ`
- Discrete completeness: `valid_discrete φ → provable_discrete φ`
- Dense completeness: `valid_dense φ → provable_dense φ`

These are three separate theorems about three different validity notions. The only relationships are:
- `provable_discrete φ → provable φ` (axiom inclusion)
- `valid φ → valid_discrete φ` (frame class inclusion)

Neither requires the proofs to share the same D.

### Concern 4: "What about shared infrastructure like `canonicalMCS_in_some_flag`?"

**Resolution**: This lemma is D-independent. It states that every CanonicalMCS is in some Flag, without mentioning D at all. The D-parameterized constructions (FMCS, BFMCS) use this lemma but don't modify it.

## Architecture Recommendation

The v3 plan's approach is architecturally sound. To maximize clarity:

### 1. Keep D-polymorphism explicit

In new code, always write `BFMCS D` rather than `BFMCS Rat` where possible. Let the type inference specialize.

### 2. Document the D choice rationale

In `FlagBFMCSRatBundle.lean` header:
```
-- D = Rat is chosen because:
-- 1. Any countable linear order embeds into Rat (Order.embedding_from_countable_to_dense)
-- 2. Base TM doesn't require discrete or dense structure
-- 3. This matches future dense completeness (task 988)
```

### 3. Avoid hardcoding Rat in shared utilities

If a lemma can work for any D, keep it polymorphic:
```lean
-- Good: polymorphic
theorem some_lemma (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] ...

-- Avoid: unnecessarily specialized
theorem some_lemma_rat : ... -- only use if truly Rat-specific
```

### 4. Separate completeness theorem files

- `FlagBFMCSCanonicalCompleteness.lean` -- base completeness using D=Rat
- `DiscreteCompleteness.lean` -- discrete completeness using D=Int (task 989)
- `DenseCompleteness.lean` -- dense completeness using D=Rat (task 988)

## Conclusion

**The D=Rat approach for task 1006 is fully compatible with D=Int for task 989.**

The compatibility arises from:
1. **Parametric design**: The infrastructure is intentionally D-polymorphic
2. **Mathematical independence**: Base and discrete completeness are about different frame classes
3. **No shared D-dependent state**: Each completeness proof instantiates D independently
4. **Mathlib support**: `Order.embedding_from_countable_to_dense` handles the Rat embedding

**Recommendation**: Proceed with the v3 plan. The architectural choice of D=Rat for base completeness is mathematically correct and does not create technical debt for the discrete extension.

## Evidence Summary

| Finding | Source | Confidence |
|---------|--------|------------|
| Parametric pipeline is D-polymorphic | `ParametricCanonical.lean:199-206` | High |
| FMCSTransfer requires only Preorder | `FMCSTransfer.lean:80-93` | High |
| Countable linear order embeds into Rat | `Order.embedding_from_countable_to_dense` (Mathlib) | High |
| Discrete completeness requires Int | `DiscreteCompleteness.lean:56-66` | High |
| DiscreteInstantiation uses Int | `DiscreteInstantiation.lean:81` | High |
| DenseInstantiation uses Rat | `DenseInstantiation.lean:84` | High |

## References

| File | Relevance |
|------|-----------|
| `FMCSTransfer.lean` | FMCSTransfer structure, transfer theorems |
| `ParametricCanonical.lean` | D-polymorphic TaskFrame |
| `DiscreteInstantiation.lean` | D=Int instantiation |
| `DenseInstantiation.lean` | D=Rat instantiation |
| `DiscreteCompleteness.lean` | Discrete completeness requirements |
| `Order.embedding_from_countable_to_dense` | Mathlib theorem for Rat embedding |
| `03_dense-discrete-compatibility.md` | Prior research on D-polymorphism |
| `04_team-research.md` | FMCSTransfer Rat recommendation |
