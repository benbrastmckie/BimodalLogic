# Research Report: Alternative D Construction Approaches

**Task**: 1006 - canonical_taskframe_completeness
**Date**: 2026-03-20
**Focus**: Alternative approaches to parametric duration domain D construction
**Agent**: Teammate B (research teammate)

## Key Findings

### 1. The Core Blocker is Structural, Not Incidental

The F/P completeness crux (documented in `09_fp-crux-analysis.md`) is a **genuine mathematical obstruction**, not a formalization artifact. The tension is:

1. **CanonicalMCS has sorry-free F/P properties** - `canonicalMCS_forward_F` and `canonicalMCS_backward_P` are fully proven in `CanonicalFMCS.lean:222-251`
2. **CanonicalMCS lacks AddCommGroup** - it only has `Preorder` from reflexive closure of `CanonicalR`
3. **TaskFrame/validity requires AddCommGroup** - the definition quantifies over `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`

The problem is NOT finding F/P witnesses (that's done). The problem is that witnesses exist in `CanonicalMCS` but the validity definition requires a D with algebraic structure.

### 2. Why Omega-Saturation Constructions Fail

The report identifies 12+ failed construction attempts. All share the same failure mode:

**The omega-saturation approach** (Section 5.3 of the analysis):
- Build countable chain C iteratively by adding F/P witnesses
- Try to map C to Int/Rat with AddCommGroup

**Failure mechanism**:
- F-witnesses from `canonical_forward_F` are `CanonicalR`-accessible from their source MCS
- But they are NOT necessarily `CanonicalR`-comparable with OTHER MCSes already in the chain
- `CanonicalR` is NOT total on `CanonicalMCS`, so different F-witnesses may be in different "branches"
- A linear chain can only follow one branch

**Concrete example**: If we have MCS M1, M2 in chain with `CanonicalR M1 M2`, and add F-witness W1 for obligation at M1, we need either `CanonicalR M2 W1` or `CanonicalR W1 M2`. There is NO guarantee of this.

### 3. The Task Relation Uses Only SIGN of d

From `ParametricCanonical.lean:85-89`:
```lean
def parametric_canonical_task_rel (M : ParametricCanonicalWorldState) (d : D)
    (N : ParametricCanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N  -- d = 0
```

**Critical insight**: The task relation is **D-independent in its logical content**:
- All positive durations are equivalent (they all mean `CanonicalR M N`)
- All negative durations are equivalent (they all mean `CanonicalR N M`)
- Only three "duration classes" matter: positive, negative, zero

This means the **magnitude** of d is never used - only its sign. The AddCommGroup structure is used by:
- `nullity_identity`: uses `0 : D`
- `forward_comp`: uses `x + y`
- `converse`: uses `-d`

But these are **frame axioms**, not **semantic evaluation** of temporal operators.

### 4. Relational Validity Approach - Analyzed

**Question**: Could we define a "relational validity" that doesn't require AddCommGroup, prove completeness against that, then show it implies standard validity?

**Analysis**: The report explores this in Section 6.2-6.3:

**Approach**: Define `valid_preorder` requiring only `[Preorder D]` instead of AddCommGroup. Then:
- Prove `valid phi -> valid_preorder phi -> provable phi`

**Problem**: This goes the **wrong direction**. For the contrapositive completeness argument:
- We need: `not provable phi -> not valid phi`
- We construct a countermodel for unprovable phi
- The countermodel must live in a D with AddCommGroup (to witness `not valid`)
- A countermodel in Preorder-D doesn't suffice because Preorder models are a **superset** of AddCommGroup models

**Conclusion**: Relational validity cannot directly bypass the AddCommGroup requirement for the standard validity definition.

### 5. Using CanonicalMCS Directly - Why It Fails

**Question**: Can we use CanonicalMCS as the indexing domain, bypassing AddCommGroup?

**Answer**: No, because validity is **defined** with AddCommGroup quantification:

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] ...
```

The contrapositive (`not valid -> not provable`) requires constructing a **specific** D that:
1. Has `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
2. Admits a TaskFrame with a countermodel for phi

CanonicalMCS fails criterion 1. We **must** use a D like Int or Rat that has the algebraic structure.

### 6. The Flag-Based Approach (Promising but Unproven)

The analysis proposes using **maximal chains (flags)** in `(CanonicalMCS, CanonicalR)`:

**Definition**: A flag is a maximal chain - a maximal subset totally ordered under CanonicalR.

**Proposed lemma** (Section 5.3):
> If F is a flag containing M and F(phi) in M, then there exists W in F with M < W and phi in W.

**Status**: The analysis attempts to prove this but reaches a **circular dependency**:
- To show phi witnesses exist in the flag, we'd use backward G reasoning
- Backward G reasoning requires forward_F to prove
- This is circular

The flag approach **might work** but requires a non-trivial saturation lemma that hasn't been proven.

### 7. Current Best Paths Forward

The analysis recommends three approaches (Section 11):

**Path A: Controlled Lindenbaum Construction**
- Modify Lindenbaum extension to never introduce G(~phi) when F(phi) is active
- This prevents the G-blocker that makes later witnesses inconsistent
- **Status**: Theoretically sound but implementation-complex

**Path B: Single-Flag Omega-Chain**
- Build chain within a single flag using Zorn's lemma
- Ensure chain is F/P-saturated by construction
- Map to Int/Rat via countability + order isomorphism
- **Status**: Requires proving flag saturation lemma

**Path C: Process Obligations Immediately**
- At each step n, if F(phi) in c(n), witness it at c(n+1)
- No gap between obligation and witness means G(~phi) can't appear
- **Status**: Only handles obligations that appear at specific enumeration steps

## Recommended Approach

**Primary Recommendation: Use the D-polymorphic parametric infrastructure with full-domain histories**

Based on plan v4 (`04_three-completeness-plan.md`):

1. **Don't try to fix the CanonicalMCS -> AddCommGroup gap directly**
2. **Use `parametric_to_history` which has full domain (`domain = True`)**
3. **Build dovetailed chains that are already indexed by a type with AddCommGroup**

The key insight: Instead of trying to transfer properties from CanonicalMCS to Int/Rat, build the FMCS construction **natively** over Int/Rat from the start, ensuring F/P saturation during construction.

**Specifically**:
- For base completeness: Use dovetailed chain over Int (or reuse dense over Rat)
- For dense completeness: DovetailedBuild + Cantor isomorphism to Rat
- For discrete completeness: discreteStagedBuild + characterization theorem to Int

The `parametric_to_history` construction avoids the convexity blocker by using full domain, making all WorldHistory requirements trivially satisfied.

## Evidence/Examples

### Evidence for structural blocker:
- `IntBFMCS.lean:19-32`: Documents the Lindenbaum-introduces-G(~phi) problem
- `09_fp-crux-analysis.md` Section 7.1: "This is NOT an artifact of the formalization"
- 12+ failed constructions across tasks 922, 956, 970, 977, 978, 982, 985

### Evidence for sign-only semantics:
- `ParametricCanonical.lean:85-89`: Task relation definition
- `ParametricCanonical.lean:29-31`: Documentation of sign-based case analysis

### Evidence for Preorder sufficiency in FMCS:
- `CanonicalFMCS.lean:43-45`: "FMCS and TemporalCoherentFamily only require [Preorder D], not totality"
- `FMCSDef.lean`: FMCS is parametric over `[Preorder D]`

## Confidence Level

**Medium-High**

- **High confidence**: The structural blocker is real and well-characterized
- **High confidence**: CanonicalMCS cannot directly serve as D for validity
- **Medium confidence**: The dovetailed/parametric approach can succeed where direct transfer fails
- **Medium confidence**: No hidden blockers in the dovetailed construction for F/P

The remaining uncertainty is whether the dovetailed constructions (`DovetailedBuild`, `discreteStagedBuild`) provide F/P witnesses that are **in the same timeline** rather than just somewhere in CanonicalMCS. The plan's Phase 1 needs to verify this.

## Summary

The F/P completeness crux arises because:
1. CanonicalMCS has sorry-free F/P properties
2. CanonicalMCS lacks AddCommGroup required by validity definition
3. Transferring F/P to Int/Rat-indexed structures fails due to CanonicalR non-totality

The solution is NOT to fix the transfer, but to use constructions that build F/P-saturated structures natively over AddCommGroup types (Int/Rat), bypassing the problematic transfer entirely. The `parametric_to_history` with full domain provides the cleanest path forward.
