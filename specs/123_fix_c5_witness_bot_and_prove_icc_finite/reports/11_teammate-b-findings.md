# Teammate B Findings: Discrete Completeness Without IsSuccArchimedean

## Key Findings

### 1. Frame Class Definitions and Their Requirements

The codebase has three validity notions in `Theories/Bimodal/Semantics/Validity.lean`:

| Definition | Quantifies Over | Key Constraints |
|------------|-----------------|-----------------|
| `valid` | All `D : Type` | `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`, `Nontrivial D` |
| `valid_dense` | Dense `D` | Above + `DenselyOrdered D` |
| `valid_discrete` | Discrete `D` | Above + `SuccOrder D`, `PredOrder D`, **`IsSuccArchimedean D`**, **`IsPredArchimedean D`** |

**Critical observation**: `valid_discrete` currently requires `IsSuccArchimedean D` and `IsPredArchimedean D`. There is NO intermediate validity notion for "discrete without IsSuccArchimedean" (i.e., a notion that requires `SuccOrder` and `PredOrder` but NOT IsSuccArchimedean). There is no `DiscreteTemporalFrame` structure -- the frame class distinction is handled entirely through validity definitions and axiom classification.

### 2. Axiom Classification

From `Theories/Bimodal/ProofSystem/Axioms.lean`, the axiom classification is:

| Axiom | `frameClass` | `isBase` | Notes |
|-------|-------------|----------|-------|
| BX1-BX7, BX10-BX14, uniformity (35 axioms) | `Base` | True | Valid on ALL linear orders |
| Prior-UZ, Prior-SZ | `Discrete` | False | Valid on IsSuccArchimedean discrete orders |
| Z1 | `Discrete` | False | Valid on IsSuccArchimedean discrete orders |

**All base axioms are universally valid** (no frame conditions needed). The discrete-only axioms (Prior-UZ, Prior-SZ, Z1) require `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, and `IsPredArchimedean` for their soundness proofs.

The uniformity axioms (discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd) are classified as `Base` -- they encode properties of ordered abelian groups that hold universally, not discrete-specific properties.

### 3. What the Chronicle Construction Currently Requires

The discrete countermodel function `dd_countermodel_chronicle_discrete` at line 3270:
- **Input**: MCS A with `neg(phi) in A` and `box(U(T,bot)) in A`
- **Output**: Countermodel on `Int` where phi is false
- **The output type is `Int`** (line 3278: `refine ⟨Int, ...⟩`)
- **Int IS IsSuccArchimedean** (Mathlib provides this instance)

The pipeline is: MCS -> chronicle on Rat -> LimitDomSubtype (subtype of Rat) -> IsSuccArchimedean for LimitDomSubtype -> Z-isomorphism to Int -> countermodel on Int.

**The sorry chain**: `dd_countermodel_chronicle_discrete` -> `succ_embed_surjective` -> `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` -> **sorry** (line 1869).

There is also a secondary sorry chain through `succ_reaches_dom_N` (lines 1295, 1448) and `limit_dom_points_are_succ_iterates` (line 1512), but these are dead code -- no longer on the critical path since `limitDomSubtype_isSuccArchimedean` uses `succ_cofinal` instead.

### 4. Could We Avoid IsSuccArchimedean Entirely?

**No, not for the current architecture.** Here is the precise dependency analysis:

The `succ_embed_surjective` theorem (line 2802) uses `IsSuccArchimedean` to prove that every point in LimitDomSubtype is reachable from the root via finitely many succ/pred steps. This surjectivity is essential for building the `rooted_succ_discrete_fmcs` that assigns MCS labels to integers. Without surjectivity, some LimitDomSubtype points would not correspond to any integer, breaking the FMCS construction.

The Z-isomorphism approach (LimitDomSubtype ≃o Int) fundamentally requires `IsSuccArchimedean` because Mathlib's `orderIsoIntOfLinearSuccPredArch` has this as a hypothesis. Without it, LimitDomSubtype could be Z+Z or Z+Z+Z, which is not order-isomorphic to Z.

### 5. Could We Define a Weaker Frame Class and Prove Completeness for It?

**In principle yes, but it would be a different logic with a different completeness theorem.**

**Option A: "Discrete Logic" (without Prior-UZ, Prior-SZ, Z1)**

We could define:
```lean
def valid_weak_discrete (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [SuccOrder D] [PredOrder D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F) ..., truth_at M Omega τ t φ
```

This would quantify over ALL discrete linear orders (Z, Z+Z, Z*Q, etc.), not just Z-like ones. The axiom system for this logic would exclude Prior-UZ, Prior-SZ, and Z1 (since they are NOT sound on Z+Z: Prior-UZ fails on Z+Z because the first Z-copy has no future points in the second copy visible to the "nearest phi-point" mechanism).

However, the BX axiom system was NOT designed for this. The completeness proof currently depends on all axioms being available in each MCS. The chronicle construction uses the full axiom system (including Prior-UZ/Z1 via `theorem_in_mcs`) to build and validate the limit model.

**Option B: "Integer Logic" (the current system, with Z1)**

This is what the codebase currently implements: `valid_discrete` quantifies over IsSuccArchimedean discrete orders, and the axiom system includes Prior-UZ, Prior-SZ, and Z1.

### 6. Elementary Equivalence / Circular Argument Analysis

The question was: if we prove completeness for all discrete orders (without IsSuccArchimedean), can we derive Z-completeness?

**The argument would go**: If phi is not derivable, then (by completeness for all discrete orders) phi fails on some discrete order D. Since Z1 is derivable, Z1 holds on D (by soundness for all discrete orders -- but WAIT, Z1 is only sound on IsSuccArchimedean orders!).

**This is indeed circular.** Z1 is sound ONLY on IsSuccArchimedean orders (`z1_is_valid` at SoundnessLemmas.lean:2426 requires `[IsSuccArchimedean D]`). If we had a discrete order D that is NOT IsSuccArchimedean, Z1 could fail on it. So we cannot use soundness to conclude Z1 holds on an arbitrary discrete countermodel.

More precisely:
- `axiom_valid_discrete` at Soundness.lean:1065 proves `Axiom φ → isDiscreteCompatible → valid_discrete φ`
- `valid_discrete` already has `[IsSuccArchimedean D]` in its quantifier
- So the soundness theorem for discrete orders is only about IsSuccArchimedean orders
- There is no soundness theorem for "all discrete orders" -- and Z1/Prior-UZ would be unsound for such a theorem

**Conclusion**: The elementary equivalence approach does not work. You cannot escape the IsSuccArchimedean requirement.

### 7. What Sorry Sites Remain if We Skip IsSuccArchimedean

If we hypothetically removed IsSuccArchimedean from the pipeline, the sorry sites would be:

1. `succ_cofinal` (line 1869) -- the core sorry, currently blocking IsSuccArchimedean
2. `succ_embed_surjective` (line 2802) -- uses `exists_succ_iterate_of_le` from IsSuccArchimedean
3. The entire discrete countermodel theorem would need restructuring -- you cannot map to Int without IsSuccArchimedean

### 8. The Real Question: Is the Construction Z-Like?

The limit domain is constructed by starting from {0} and iteratively adding points to resolve counterexamples. Each new point enters between existing points or beyond the current max/min. The key question is: does this process produce a Z-like order (IsSuccArchimedean) or could it produce Z+Z?

**Mathematically, the answer is YES -- it must be Z-like.** The argument (which is what `succ_cofinal` tries to prove):
- Every pair of points a, b in limit_dom entered at some finite stage N of the omega-chain
- The construction resolves counterexamples between a and b at subsequent stages
- After enough stages, all counterexamples between a and b are resolved
- This creates a finite chain of succ-steps from a to b

The difficulty is formalizing this in Lean because the construction dynamics are complex.

## Recommended Approach

**There is no useful factoring that avoids IsSuccArchimedean.** The recommended approach is to continue closing the sorry in `succ_cofinal` via the existing plan (plan v11: Doets/Z1 gap elimination). Here is why:

1. **A weaker frame class is not useful**: Defining `valid_weak_discrete` (without IsSuccArchimedean) would require a different axiom system (without Prior-UZ, Prior-SZ, Z1) and a different completeness proof. This is a completely different research direction, not a simplification of the current one.

2. **The current architecture is correct**: The construction DOES produce a Z-like order. The formal gap is in proving this fact, not in the mathematical setup.

3. **The sorry is localized**: Only `succ_cofinal` needs fixing. Everything else (SuccOrder, PredOrder, orbit convexity, surjectivity, FMCS construction, truth lemma) is already proven.

4. **Prior-UZ and Z1 are integral**: The axiom system includes these axioms because the target logic is the logic of integers (Z), not the logic of arbitrary discrete orders. Removing them would weaken the logic.

## Evidence/Examples

**Z+Z counterexample for Prior-UZ**: Consider Z+Z = {..., -2, -1, 0, 1, 2, ...} ∪ {..., -2', -1', 0', 1', 2', ...} where every element of the first copy is below every element of the second copy. Set phi = "is in the second copy". At point 0 in the first copy, F(phi) holds (phi holds at 0'), but U(phi, neg phi) fails because between 0 and 0' there are infinitely many points in the first copy (where phi fails), so there is no "nearest future phi-point". Prior-UZ requires the order to be Z-like.

**Z1 counterexample on Z+Z**: Set phi = "is in the first copy". At point 0: G(Gphi -> phi) holds vacuously in the first copy (Gphi is false at every first-copy point because the second copy has no phi). FG(phi) fails. But if we instead let phi = "true at all future first-copy points" (i.e., Gphi restricted to first copy), the Z1 axiom's backward induction breaks because the succ-chain from a first-copy point never reaches a second-copy point.

## Confidence Level

**High confidence** (95%) in the conclusion that IsSuccArchimedean cannot be avoided for the current logic and architecture.

**Medium confidence** (70%) that closing the succ_cofinal sorry via Z1/Doets is the correct next step (vs. stage-walk or other approaches). The mathematical argument is sound, but the Lean formalization complexity is the main risk.

## ROADMAP Implications

### Current Task Hierarchy (No Change Recommended)

The cleanest factoring of completeness results is exactly what the codebase already has:

1. **Dense completeness** (`dd_countermodel_chronicle_dense`): Countermodel on Rat, using Cantor isomorphism. Status: 1 sorry remaining (CE:3570 density g-value consistency).

2. **Discrete/Integer completeness** (`dd_countermodel_chronicle_discrete`): Countermodel on Int, using Z-isomorphism via IsSuccArchimedean. Status: sorry chain through `succ_cofinal`.

3. **Mixed case** (`dd_countermodel_chronicle_mixed_sorry`): Countermodel when neither box(dense) nor box(discrete) holds. Status: full sorry.

### Why NOT to Split Discrete from Integer

Splitting into "discrete without Z1" and "integer with Z1" would require:
- A new validity definition (`valid_weak_discrete`)
- New soundness theorems for base+uniformity axioms on weak-discrete frames
- A separate completeness proof for the weak-discrete case
- The weak-discrete completeness would NOT help with the integer completeness (since Z1 is needed for the latter)
- This is a pure increase in work with no benefit to the current sorry closure

### Priority Order for Sorry Closure

1. **Task 123**: Close `succ_cofinal` sorry (IsSuccArchimedean for LimitDomSubtype) -- removes sorry from discrete countermodel
2. **Task 117 (or similar)**: Close CE:3570 sorry (density g-value consistency) -- removes sorry from dense countermodel
3. **Future task**: Close mixed case sorry -- requires novel techniques (ultraproducts, enriched frames)
