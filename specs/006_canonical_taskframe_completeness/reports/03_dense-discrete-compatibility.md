# Research Report: Dense and Discrete Completeness Compatibility

**Task**: 1006 - canonical_taskframe_completeness
**Date**: 2026-03-19
**Session**: sess_1773972315_7f6236
**Focus**: Compatibility of proposed approach with dense/discrete completeness extensions

## Summary

**Verdict: The proposed approach HELPS both dense and discrete completeness.**

The task 1006 approach (constructing `BFMCS Int` from FlagBFMCS via global countable enumeration) is well-positioned for extension to both dense and discrete completeness. The parametric infrastructure (`ParametricCanonicalTaskFrame D`, `parametric_canonical_truth_lemma`) is **already D-polymorphic**, requiring only that D have `AddCommGroup`, `LinearOrder`, and `IsOrderedAddMonoid` instances. This means:

- **Dense**: Change `D = Int` to `D = Rat` with essentially no proof changes
- **Discrete**: Keep `D = Int` (already discrete!) with `SuccOrder`/`PredOrder` when needed

The streamlined approach maximizes code reuse because all three completeness theorems share the same underlying parametric pipeline.

## Background: Task 1006's Proposed Approach

From the supplemental research (`02_direct-construction.md`):

1. **Global enumeration**: `enum_mcs : CanonicalMCS -> Int` (countable injection)
2. **Per-Flag FMCS Int**: Convert each `chainFMCS F : FMCS (ChainFMCSDomain F)` to `FMCS Int`
3. **Bundle into BFMCS Int**: Modal coherence from `modally_saturated`
4. **Apply parametric pipeline**: `parametric_canonical_truth_lemma` -> completeness

## Dense Completeness Analysis (Task 988)

### Current Infrastructure Status

From `DenseCompleteness.lean` and `DenseInstantiation.lean`:

| Component | Status | File |
|-----------|--------|------|
| `DenseCanonicalTaskFrame (= ParametricCanonicalTaskFrame Rat)` | Defined, sorry-free | `DenseInstantiation.lean:84` |
| `DenseCanonicalTaskModel` | Defined, sorry-free | `DenseInstantiation.lean:92` |
| `dense_representation_conditional` | Proven | `DenseInstantiation.lean:152-162` |
| `BFMCS Rat` construction | **Missing** | (The gap) |
| `Cantor isomorphism TimelineQuot ≃o Rat` | Exists in `CantorApplication.lean` | |

### The Domain Question: Int vs Rat

**Finding**: The parametric infrastructure makes this choice **trivial**.

```lean
-- DenseInstantiation.lean shows:
abbrev DenseCanonicalTaskFrame : TaskFrame Rat :=
  ParametricCanonicalTaskFrame Rat

-- DiscreteInstantiation.lean shows:
abbrev DiscreteCanonicalTaskFrame : TaskFrame Int :=
  ParametricCanonicalTaskFrame Int
```

The **only difference** is the type parameter. All proofs are reused.

### Dense Requirements Analysis

The density axiom `DN: GGφ → Gφ` requires `DenselyOrdered D`:

| Requirement | Int | Rat | Impact on Task 1006 |
|-------------|-----|-----|---------------------|
| `AddCommGroup D` | Yes | Yes | No change |
| `LinearOrder D` | Yes | Yes | No change |
| `IsOrderedAddMonoid D` | Yes | Yes | No change |
| `DenselyOrdered D` | **No** | **Yes** | Change `Int` to `Rat` |

### How Task 1006 Enables Dense Completeness

The task 1006 approach constructs `BFMCS Int` from FlagBFMCS. For dense completeness:

1. **Change enum codomain**: `enum_mcs : CanonicalMCS -> Rat` (still countable)
2. **Build BFMCS Rat**: Same construction, different target type
3. **Apply parametric pipeline**: `DenseCanonicalTaskFrame = ParametricCanonicalTaskFrame Rat`

**Critical observation**: The `FlagBFMCS.modally_saturated` condition encodes the modal coherence structure **independent of D**. The embedding from ChainFMCSDomain to D is purely order-preserving; it doesn't depend on density properties.

### Gap from Dense Completeness

From `specs/988_dense_algebraic_completeness/reports/15_blocker-resolution.md`:

> The theorems `flag_forward_F_witness_exists` and `flag_backward_P_witness_exists` prove witnesses exist in CanonicalMCS, but NOT necessarily in the same Flag.

This is **resolved by the multi-family BFMCS bundle approach** that task 1006 adopts. Each Flag becomes a family in the BFMCS, and cross-Flag witnesses are handled by modal coherence conditions.

### Recommendation for Dense Completeness

**The task 1006 approach directly supports dense completeness.**

Steps after task 1006 completion:
1. Create `bfmcs_from_flagbfmcs_Rat : FlagBFMCS -> BFMCS Rat` (parallel to Int version)
2. Apply `dense_representation_conditional` (already exists)
3. Wire to `valid_dense` using the Cantor isomorphism for additional semantic properties

**Estimated additional effort**: 2-3 hours (mostly type parameter changes)

## Discrete Completeness Analysis (Task 989)

### Current Infrastructure Status

From `DiscreteCompleteness.lean` and `DiscreteInstantiation.lean`:

| Component | Status | File |
|-----------|--------|------|
| `DiscreteCanonicalTaskFrame (= ParametricCanonicalTaskFrame Int)` | Defined, sorry-free | `DiscreteInstantiation.lean:81` |
| `DiscreteCanonicalTaskModel` | Defined, sorry-free | `DiscreteInstantiation.lean:89` |
| `discrete_representation_conditional` | Proven | `DiscreteInstantiation.lean:149-159` |
| `SuccOrder DiscreteTimelineQuot` | **Blocked** (sorry) | `DiscreteTimeline.lean` |
| `PredOrder DiscreteTimelineQuot` | **Blocked** (sorry) | `DiscreteTimeline.lean` |
| `IsSuccArchimedean DiscreteTimelineQuot` | **Blocked** (sorry) | `DiscreteTimeline.lean` |

### The Domain Question: Int is Perfect

**Finding**: `D = Int` is exactly what discrete completeness needs.

The discrete axiom `DF: (F⊤ ∧ φ ∧ Hφ) → F(Hφ)` requires successor structure. `Int` has:

| Requirement | Int | Needed for |
|-------------|-----|------------|
| `SuccOrder Int` | Not in Mathlib | Discrete DF soundness |
| `PredOrder Int` | Not in Mathlib | Discrete DB soundness |
| Natural discrete structure | Yes (inherent) | All discrete reasoning |

**Key insight**: For completeness, we don't need `SuccOrder Int` -- we need the canonical model to have successor structure. The task 1006 embedding from ChainFMCSDomain to Int preserves whatever order structure the Flags have.

### How Task 1006 Enables Discrete Completeness

The task 1006 approach is **already using D = Int**, which is the right choice for discrete logic.

The discrete completeness gap (`DiscreteTimeline.lean` sorries) is **orthogonal** to task 1006:

1. **Task 1006**: Constructs BFMCS Int, proves truth lemma, establishes completeness for base TM
2. **Task 989**: Must additionally prove that under DF axiom, the canonical model has successor structure

**Critical observation**: The discrete axiom DF affects the **structure of Flags**, not the BFMCS construction itself. When DF is in the axiom system:
- Flags have no density intermediates (no x such that M < x < N for "adjacent" M, N)
- This gives `SuccOrder` structure on `ChainFMCSDomain F`
- This structure transfers through the order-embedding to Int

### Gap from Discrete Completeness

From `DiscreteCompleteness.lean:41-53`:

> The discrete completeness requires SuccOrder/PredOrder instances for the canonical discrete timeline. These are proven in DiscreteTimeline.lean but currently have sorries awaiting Task 974.

**Root issue**: The `succ_le_of_lt` coverness lemma requires showing that the DF axiom implies no strict intermediate elements between adjacent points.

### Compatibility Assessment

Task 1006's approach is **compatible** with discrete completeness:

| Task 1006 Component | Discrete Impact |
|---------------------|-----------------|
| Global `enum_mcs` | Keep as-is (Int is correct) |
| Per-Flag FMCS Int | Keep as-is |
| BFMCS Int bundle | Keep as-is |
| Parametric pipeline | Keep as-is |

The only additional work for discrete completeness is proving the SuccOrder/PredOrder structure on Flags (which is independent of the BFMCS construction).

### Recommendation for Discrete Completeness

**The task 1006 approach is neutral-to-helpful for discrete completeness.**

Task 1006 does not block task 989. After task 1006:
1. The base BFMCS Int infrastructure is available
2. Discrete completeness needs to additionally prove:
   - Flags under DF have `SuccOrder` structure
   - Transfer this structure through embedding (automatic)
   - Connect to `valid_discrete` definition

## Shared Infrastructure Analysis

### What Can Be Reused Across Base/Dense/Discrete

| Component | Base | Dense | Discrete |
|-----------|------|-------|----------|
| `ParametricCanonicalTaskFrame D` | D=Int | D=Rat | D=Int |
| `parametric_canonical_task_rel` | Same | Same | Same |
| `ParametricCanonicalTaskModel D` | D=Int | D=Rat | D=Int |
| `parametric_to_history` | Same | Same | Same |
| `parametric_canonical_truth_lemma` | Same | Same | Same |
| `ShiftClosedParametricCanonicalOmega` | Same | Same | Same |
| `parametric_representation_from_neg_membership` | Same | Same | Same |
| `bfmcs_from_flagbfmcs` | D=Int | D=Rat | D=Int |
| `enum_mcs` | -> Int | -> Rat | -> Int |

**Code reuse estimate**: 90%+ of the proof infrastructure is shared.

### Conflicts Between Base/Dense/Discrete

**No conflicts.** The three extensions are compatible at the infrastructure level:

1. **Base**: Uses Int, no additional axioms
2. **Dense**: Uses Rat, adds DN axiom (DenselyOrdered constraint on validity)
3. **Discrete**: Uses Int, adds DF/SF/SP axioms (SuccOrder constraint on validity)

The parametric construction is **uniform in D**. The axiom extensions affect only:
- Which formulas are valid (domain constraints)
- Which derivations are allowed (axiom system extensions)

### Factoring Recommendation

**Keep task 1006 focused on base completeness (D = Int).** Then:

1. **Dense completeness** (future task): Copy `bfmcs_from_flagbfmcs` with D=Rat, apply existing dense pipeline
2. **Discrete completeness** (task 989): Reuse task 1006's BFMCS Int construction, add SuccOrder proofs

This factoring minimizes risk:
- Task 1006 doesn't need to handle density or discreteness concerns
- Dense/discrete extensions build on a proven base infrastructure

## Evaluation of Streamlined Approach

### Strengths

1. **Maximum reuse**: The parametric pipeline handles all three cases
2. **D-polymorphism**: Same proofs work for Int, Rat, or any ordered abelian group
3. **Modular**: FlagBFMCS -> BFMCS is the only new construction; rest is reuse
4. **No SuccOrder/DenselyOrdered dependencies**: Task 1006 doesn't need these typeclasses

### Potential Concerns

1. **Countable enumeration**: The `enum_mcs` construction needs careful handling
   - **Mitigation**: Both Int and Rat are countable; same enumeration technique works

2. **Modal coherence transfer**: Must prove `modally_saturated -> modal_forward/backward`
   - **Mitigation**: This is D-independent; same proof for all three completeness theorems

3. **Temporal coherence transfer**: Must preserve F/P witness properties
   - **Mitigation**: ChainFMCS already has this; embedding preserves order

### No Adjustments Needed to Task 1006 Approach

The proposed streamlined approach in `02_direct-construction.md` is well-designed for extension:

1. **Global enumeration** generalizes to any countable target (Int or Rat)
2. **Per-Flag FMCS construction** is D-polymorphic
3. **Modal coherence transfer** is order-structure-independent
4. **Parametric pipeline application** handles both dense and discrete via type parameter

## Recommendations

### For Task 1006 Implementation

1. **Proceed with the proposed approach** - it is compatible with dense/discrete extensions
2. **Keep D = Int** for base completeness
3. **Design `bfmcs_from_flagbfmcs` with D-polymorphism in mind** (use type parameter even if fixed to Int initially)
4. **Do NOT add DenselyOrdered or SuccOrder constraints** - they're not needed for base completeness

### For Dense Completeness (Post-1006)

1. **Instantiate with D = Rat** - the parametric infrastructure supports this
2. **Reuse `bfmcs_from_flagbfmcs` construction** with different embedding codomain
3. **Wire to Cantor isomorphism** if additional semantic properties are needed

### For Discrete Completeness (Task 989)

1. **Reuse task 1006's BFMCS Int construction** directly
2. **Focus on SuccOrder/PredOrder proofs** for Flags under DF axiom
3. **Do not rewrite the BFMCS infrastructure** - it's already correct for discrete

### Architecture Diagram

```
                 FlagBFMCS
                     |
        bfmcs_from_flagbfmcs (D-polymorphic)
                     |
         +-----------+-----------+
         |           |           |
    BFMCS Int    BFMCS Rat    BFMCS Int
    (base)       (dense)     (discrete)
         |           |           |
         +-----+-----+-----+-----+
               |
    parametric_canonical_truth_lemma
               |
    parametric_representation_from_neg_membership
               |
         +-----------+-----------+
         |           |           |
       valid    valid_dense   valid_discrete
```

## Evidence

### ParametricCanonical.lean:199-206 (D-polymorphic TaskFrame)

```lean
def ParametricCanonicalTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := ParametricCanonicalWorldState
  task_rel := parametric_canonical_task_rel
  nullity_identity := parametric_task_rel_nullity_identity
  forward_comp := fun M U V x y hx hy h1 h2 =>
    parametric_task_rel_forward_comp M U V x y hx hy h1 h2
  converse := parametric_task_rel_converse
```

### DenseInstantiation.lean:84-85 (D = Rat instantiation)

```lean
abbrev DenseCanonicalTaskFrame : TaskFrame Rat :=
  ParametricCanonicalTaskFrame Rat
```

### DiscreteInstantiation.lean:81-82 (D = Int instantiation)

```lean
abbrev DiscreteCanonicalTaskFrame : TaskFrame Int :=
  ParametricCanonicalTaskFrame Int
```

### ParametricTruthLemma.lean:174-180 (D-polymorphic truth lemma)

```lean
theorem parametric_canonical_truth_lemma
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (phi : Formula) :
    phi ∈ fam.mcs t ↔
      truth_at (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B)
        (parametric_to_history fam) t phi := by
```

## Conclusion

The task 1006 streamlined approach (global enumeration + BFMCS construction + parametric pipeline) is **well-positioned for dense and discrete completeness**:

- **Dense**: Change D = Int to D = Rat; rest is unchanged
- **Discrete**: Keep D = Int; add SuccOrder proofs separately

No adjustments to the proposed task 1006 approach are needed. The D-polymorphic parametric infrastructure already supports both extensions.

## References

| File | Relevance |
|------|-----------|
| `DenseCompleteness.lean` | Dense completeness gap documentation |
| `DiscreteCompleteness.lean` | Discrete completeness gap documentation |
| `DenseInstantiation.lean` | D = Rat instantiation |
| `DiscreteInstantiation.lean` | D = Int instantiation |
| `ParametricCanonical.lean` | D-polymorphic TaskFrame |
| `ParametricTruthLemma.lean` | D-polymorphic truth lemma |
| `specs/988_*/reports/15_blocker-resolution.md` | Dense completeness blockers |
| `DiscreteTimeline.lean` | Discrete timeline (SuccOrder sorries) |
| `02_direct-construction.md` | Task 1006 proposed approach |
