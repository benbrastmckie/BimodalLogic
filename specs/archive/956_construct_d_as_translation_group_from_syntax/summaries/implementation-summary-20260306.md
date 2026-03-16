# Implementation Summary: Construct D as Translation Group from Syntax

**Task**: 956
**Date**: 2026-03-06
**Status**: Partial (blocked on mathematical properties)
**Session**: sess_1772906400_f1a2b3

## What Was Accomplished

Created `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean` (sorry-free, ~280 lines) defining:

### Core Definitions
- `CanonicalTimeline M₀ h_mcs₀` -- alias for `BidirectionalQuotient` (has `LinearOrder`)
- `TranslationGroup M₀ h_mcs₀` -- `Additive (T ≃o T)`, the additive group of order automorphisms
- `TranslationGroup.apply` -- action of D on T via inverse convention: `d.apply w = (toMul d).symm w`
- `torsor_task_rel` -- `task_rel w d w' := d.apply w = w'`
- `CanonicalTimeline.origin` -- root equivalence class
- `TranslationGroup.evalAtOrigin` -- evaluation map D -> T

### Proven Properties (all sorry-free)
- `instAddGroupTranslationGroup`: D has `AddGroup` (from Mathlib)
- `TranslationGroup.apply_zero`: identity action
- `TranslationGroup.apply_add`: `(d₁ + d₂).apply w = d₂.apply(d₁.apply w)`
- `TranslationGroup.apply_neg_cancel_left`: `(-d).apply(d.apply w) = w`
- `TranslationGroup.apply_neg_cancel_right`: `d.apply((-d).apply w) = w`
- `TranslationGroup.apply_injective`: action is injective per duration
- `TranslationGroup.apply_monotone`: action preserves order
- `torsor_task_rel_nullity`: TaskFrame nullity axiom
- `torsor_task_rel_compositionality`: TaskFrame compositionality axiom
- `torsor_task_rel_deterministic`: task relation is functional
- `torsor_task_rel_reversible`: negative duration reverses transition

### Verification
- `lake build` passes (710 jobs, no new errors)
- Zero sorries in TranslationGroup.lean
- Zero new axioms

## What Is Blocked

The following typeclass instances are needed to assemble `TaskFrame (TranslationGroup M₀ h_mcs₀)`:

### 1. AddCommGroup (Holder's Theorem)
**Requirement**: Prove that D is abelian.
**Depends on**: Freeness (rigidity) of the action.
**Mathematical content**: Holder's theorem states that a group acting freely and order-preservingly on a linearly ordered set is abelian. This requires first proving freeness.

### 2. LinearOrder on D (Freeness/Rigidity)
**Requirement**: Prove `evalAtOrigin_injective` to use `LinearOrder.lift`.
**Mathematical content**: If an order automorphism fixes a point on the canonical timeline, it must be the identity. This is NOT true for general linear orders (counterexample: x -> 2x on Q fixes 0 but is not id). It requires specific properties of the MCS construction.
**Research finding**: The research report's claim that "rigidity holds automatically for connected linear orders" is INCORRECT. It requires additional structural properties.

### 3. IsOrderedAddMonoid (Order Compatibility)
**Requirement**: The pulled-back order on D is compatible with addition.
**Depends on**: LinearOrder on D.

### 4. AddTorsor D T (Homogeneity)
**Requirement**: Prove transitivity of the action (for any a, b in T, exists d with d.apply a = b).
**Mathematical content**: This is the hardest open problem. Requires a back-and-forth argument using uniformity of temporal axioms.

## Key Design Decisions

1. **Chose `Additive (T ≃o T)` over formal differences**: The plan suggested `T x T / ~` (Strategy C), but the equivalence relation's well-definedness requires homogeneity -- the same property that blocks the alternative approaches.

2. **Inverse action convention**: `d.apply w = (toMul d).symm w`. This is needed because `RelIso.instGroup` defines `f * g = g.trans f`, so `(toMul(d₁ + d₂))(w) = (toMul d₁)((toMul d₂)(w))`. The inverse convention gives the correct composition order for TaskFrame compositionality without requiring commutativity.

3. **Did NOT archive DovetailingChain.lean**: Despite the plan, DovetailingChain is actively imported by TemporalCoherentConstruction.lean (for `temporal_coherent_family_exists_theorem`). Archiving would break the build.

## Discovery: Mathlib Bug

Found that `SMulCommClass (Equiv.Perm (Fin 3)) (Equiv.Perm (Fin 3)) (Fin 3)` allows deriving `False`. This means the generic `AddTorsor (Additive (alpha ≃o alpha)) alpha` instance in Mathlib is unsound. The implementation avoids using this instance.

## Recommendations

1. **Freeness proof**: Should be attempted as a dedicated task. The key question is: does the canonical timeline (built from MCSes via temporal axioms) have the property that order automorphisms fixing a point are trivial? This likely follows from the "every point is determined by its theory" argument.

2. **Holder's theorem**: Once freeness is proven, commutativity follows by a standard argument (bi-invariant ordered groups are abelian). This could be formalized as a general Mathlib-style lemma.

3. **Homogeneity**: The hardest problem. May require model-theoretic back-and-forth using countability of the formula language.

4. **Alternative**: If the mathematical proofs prove too difficult, consider weakening the construction to use `D = Int` with the non-trivial task_rel (replacing the current trivial `fun _ _ _ => True`). This would give meaningful semantics without the full automorphism group construction.
