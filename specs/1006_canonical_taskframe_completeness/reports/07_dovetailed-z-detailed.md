# Research Report: Dovetailed Flag + Z Approach (Task 1006)

**Task**: 1006 - canonical_taskframe_completeness
**Date**: 2026-03-20
**Focus**: Detailed analysis of the dovetailed Flag + Z isomorphism approach
**Session**: sess_1774023083_63dd8e

## Executive Summary

The Dovetailed Flag + Z approach resolves both blockers (`convex` and `shifted_truth_lemma`) by:

1. **Using a self-contained dovetailed chain** instead of embedding a discrete chain into Rat
2. **Proving the chain is order-isomorphic to Z** via Mathlib's `orderIsoIntOfLinearSuccPredArch`
3. **Transferring AddCommGroup from Z** via `Equiv.addCommGroup`
4. **Building FMCS on ChainFMCSDomain** with guaranteed F/P witness containment
5. **Applying parametric_to_history** for trivially convex WorldHistory (full domain = always convex)

The key insight is that dovetailed chains are **self-contained**: F/P witnesses are placed inside the chain during construction, eliminating the cross-Flag witness problem that blocks `shifted_truth_lemma` in multi-Flag approaches.

## 1. DovetailedBuild Analysis

### What DovetailedBuild Produces

Location: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean`

DovetailedBuild produces a **countable set of DovetailedPoints** (`dovetailedTimelineUnion`) with proven properties:

| Property | Theorem | Status |
|----------|---------|--------|
| Nonempty | `dovetailedTimeline_nonempty` | Proven |
| Countable | `dovetailedTimeline_countable` | Proven |
| Linearly ordered | `dovetailedTimeline_linearly_ordered` | Proven |
| Has future (NoMaxOrder) | `dovetailedTimeline_has_future` | Proven |
| Has past (NoMinOrder) | `dovetailedTimeline_has_past` | Proven |

### Structure of DovetailedPoint

```lean
structure DovetailedPoint where
  mcs : Set Formula
  is_mcs : SetMaximalConsistent mcs
  entry_stage : Stage
  point_index : Nat
```

### Self-Containment Property

The critical property (proven in `DovetailedCoverage.lean`):

- `dovetailedTimeline_has_future`: Every point p has a witness q IN THE TIMELINE with `CanonicalR p.mcs q.mcs`
- `dovetailedTimeline_has_past`: Every point p has a witness q IN THE TIMELINE with `CanonicalR q.mcs p.mcs`

This is **not** just seriality (witness exists somewhere) but **internal seriality** (witness is in the same timeline). This eliminates the cross-Flag witness problem.

### Gap: DovetailedBuild to Flag Connection

DovetailedBuild produces a chain that is a **subset** of some maximal chain (Flag), but it does NOT directly produce a Flag. The construction is:

1. `dovetailedTimelineUnion` is a countable chain in CanonicalMCS
2. Every CanonicalMCS element is in some Flag (`canonicalMCS_in_some_flag`)
3. The entire dovetailed chain must lie in a single Flag (by comparability)

**Needed**: Formalize that the dovetailed chain lies in a unique minimal containing Flag, or work directly with the chain without Flag machinery.

## 2. Z-Isomorphism Construction

### Requirements for `orderIsoIntOfLinearSuccPredArch`

From Mathlib (`Mathlib.Order.SuccPred.LinearLocallyFinite`):

```lean
def orderIsoIntOfLinearSuccPredArch
    {ι : Type*} [LinearOrder ι] [SuccOrder ι] [PredOrder ι]
    [IsSuccArchimedean ι] [NoMaxOrder ι] [NoMinOrder ι] [Nonempty ι] :
    ι ≃o Z
```

**Required instances on the quotient**:
1. `LinearOrder` - from `Antisymmetrization`
2. `SuccOrder` - requires LocallyFiniteOrder
3. `PredOrder` - requires LocallyFiniteOrder
4. `IsSuccArchimedean` - follows from LocallyFiniteOrder
5. `NoMaxOrder` - proven from `dovetailedTimeline_has_future`
6. `NoMinOrder` - proven from `dovetailedTimeline_has_past`
7. `Nonempty` - proven from `dovetailedTimeline_nonempty`

### The Discreteness Gap

**Problem**: The dovetailed chain has density witnesses (from density axiom DN). This makes it **dense**, not discrete. The Z-isomorphism approach requires **discreteness** (no elements strictly between).

**Two Options**:

#### Option A: Use Discrete DovetailedBuild (Without Density Axiom)

Build a variant of DovetailedBuild that processes only F/P obligations, not density:
- Remove `processDensityDovetailed` calls
- The result is a discrete chain (base TM axioms)
- This matches `discreteStagedBuild` in `DiscreteTimeline.lean`

The existing `DiscreteTimeline.lean` already has:
- `DiscreteTimelineQuot` - the quotient type
- `NoMaxOrder`, `NoMinOrder` instances
- **Axiomatized** `LocallyFiniteOrder` via `discrete_Icc_finite_axiom`

#### Option B: Use Cantor's Theorem for Dense Case (Rat, not Z)

If we include density, the chain is order-isomorphic to **Rat**, not Z:
- Countable + Dense + NoMax + NoMin => order-isomorphic to Rat
- Use `Order.iso_of_countable_dense` from Mathlib

**Verdict**: For Task 1006 (bimodal completeness), we need to handle the dense case. The correct target is **Rat**, and the convexity issue was the domain being a non-convex subset of Rat. The solution is using **full domain** in `parametric_to_history`.

### Revised Understanding

The original team research's "Z approach" was based on the discrete case. For the dense completeness in Task 1006, we should:

1. Keep using **Rat** as the duration type (not Z)
2. Use **parametric_to_history** with **full domain** (domain = True everywhere)
3. Full domain is trivially convex

The key fix is NOT switching to Z, but ensuring the WorldHistory has full domain.

## 3. Group Structure Transfer

### From Mathlib

```lean
-- Mathlib.Algebra.Group.TransferInstance
def Equiv.addCommGroup {α β : Type*} (e : α ≃ β) [AddCommGroup β] : AddCommGroup α
```

### Transfer via OrderIso

The codebase already has this in `DurationTransfer.lean`:

```lean
noncomputable def transferAddCommGroup
    {T : Type*} {G : Type*} [LinearOrder T] [AddCommGroup G] [LinearOrder G]
    (e : T ≃o G) : AddCommGroup T :=
  Equiv.addCommGroup e.toEquiv

theorem transferIsOrderedAddMonoid
    {T : Type*} {G : Type*} [LinearOrder T] [AddCommGroup G] [LinearOrder G]
    [IsOrderedAddMonoid G]
    (e : T ≃o G) :
    @IsOrderedAddMonoid T (transferAddCommGroup e).toAddCommMonoid (inferInstance : PartialOrder T)
```

**Existing infrastructure** for both:
- `intOrderIso`, `intAddCommGroup`, `intIsOrderedAddMonoid` - for Z (discrete case)
- `ratOrderIso`, `ratAddCommGroup`, `ratIsOrderedAddMonoid` - for Rat (dense case)

## 4. FMCS Construction on the Dovetailed Chain

### ChainFMCSDomain Pattern

The `ChainFMCS.lean` module already provides:

```lean
abbrev ChainFMCSDomain (flag : Flag CanonicalMCS) :=
  { w : CanonicalMCS // w ∈ flag }

noncomputable def chainFMCS (flag : Flag CanonicalMCS) : FMCS (ChainFMCSDomain flag)
```

With proven properties:
- `chainFMCS_forward_G` - G-formulas propagate forward
- `chainFMCS_backward_H` - H-formulas propagate backward
- `chainFMCS_pairwise_comparable` - total order within flag

### Self-Contained Forward F and Backward P

The key issue is that `chainFMCS` does NOT have built-in `forward_F` and `backward_P` that stay within the chain. The existing theorems:

```lean
theorem chainFMCS_forward_F_in_CanonicalMCS (flag : Flag CanonicalMCS)
    (w : ChainFMCSDomain flag) (phi : Formula)
    (h_F : Formula.some_future phi ∈ chainFMCS_mcs flag w) :
    ∃ s : CanonicalMCS, w.val ≤ s ∧ phi ∈ s.world
```

This gives a witness **somewhere in CanonicalMCS**, not necessarily in the flag!

### DovetailedBuild Advantage

DovetailedBuild's coverage theorems (`DovetailedCoverage.lean`) guarantee:

```lean
theorem dovetailedTimeline_has_future
    (p : DovetailedPoint) (hp : p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof) :
    ∃ q : DovetailedPoint,
      q ∈ dovetailedTimelineUnion root_mcs root_mcs_proof ∧
      CanonicalR p.mcs q.mcs
```

The witness q is **in the same timeline**, not just somewhere.

### Construction Strategy

1. Define `DovetailedTimelineQuotFMCS` directly on the quotient
2. MCS assignment: `mcs [p] := p.mcs` (well-defined since equiv-related points have same MCS)
3. `forward_G` and `backward_H`: from canonical MCS properties
4. `forward_F` and `backward_P`: from `dovetailedTimeline_has_future/past`

## 5. WorldHistory via parametric_to_history

### The Key Fix: Full Domain

From `ParametricHistory.lean`:

```lean
def parametric_to_history (fam : FMCS D) : WorldHistory (ParametricCanonicalTaskFrame D) where
  domain := fun _ => True     -- FULL DOMAIN
  convex := fun _ _ _ _ _ _ _ => True.intro  -- TRIVIALLY CONVEX
  states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩
  respects_task := ...
```

**Crucial observation**: When `domain = True` for all times:
- Convexity condition is **trivially satisfied** (between any two domain points, all intermediate points are in domain = True)
- No "gaps" in the domain to worry about
- The `convex` sorry in the current implementation becomes `True.intro`

### Why Current Implementation Fails

The current `shiftedFlagWorldHistory` in `FlagBFMCSRatBundle.lean` uses:

```lean
domain := fun r => r ∈ Set.range (embed ∘ Subtype.val)
```

This restricts domain to the **image** of the discrete chain under embedding, which is:
- Countable
- Non-convex (gaps between consecutive embedded points)

The fix is to use `parametric_to_history` which has full domain.

## 6. Complete Definition/Theorem Sequence

### Phase 1: Dovetailed FMCS on Quotient

| # | Item | Type | Status | Dependency |
|---|------|------|--------|------------|
| 1.1 | `DovetailedTimelineQuot` | def | Exists (Boneyard) | Antisymmetrization of dovetailed timeline |
| 1.2 | `instLinearOrderDovetailedTimelineQuot` | instance | Exists | From Antisymmetrization |
| 1.3 | `instNoMaxOrderDovetailedTimelineQuot` | instance | Exists | From `dovetailedTimeline_has_future` |
| 1.4 | `instNoMinOrderDovetailedTimelineQuot` | instance | Exists | From `dovetailedTimeline_has_past` |
| 1.5 | `dovetailedTimelineQuotMCS` | def | Exists | MCS assignment on quotient |
| 1.6 | `dovetailedTimelineQuotFMCS` | def | Needs work | FMCS structure on quotient |

### Phase 2: Group Structure (Dense Case)

| # | Item | Type | Status | Dependency |
|---|------|------|--------|------------|
| 2.1 | `DenselyOrdered DovetailedTimelineQuot` | instance | Needs proof | From density axiom DN |
| 2.2 | `Countable DovetailedTimelineQuot` | instance | Needs proof | From countable union |
| 2.3 | `dovetailedRatOrderIso` | def | Needs construction | Via `Order.iso_of_countable_dense` |
| 2.4 | `dovetailedAddCommGroup` | def | Easy | Via `transferAddCommGroup` |
| 2.5 | `dovetailedIsOrderedAddMonoid` | theorem | Easy | Via `transferIsOrderedAddMonoid` |

### Phase 3: Parametric Pipeline

| # | Item | Type | Status | Dependency |
|---|------|------|--------|------------|
| 3.1 | `dovetailedFMCS_as_parametric` | def | Needs work | Convert dovetailedTimelineQuotFMCS to FMCS D |
| 3.2 | `dovetailedWorldHistory` | def | Easy | Via `parametric_to_history` |
| 3.3 | `dovetailedWorldHistory_convex` | theorem | Trivial | Full domain is trivially convex |

### Phase 4: Truth Lemma and Completeness

| # | Item | Type | Status | Dependency |
|---|------|------|--------|------------|
| 4.1 | Apply `parametric_shifted_truth_lemma` | theorem | Should work | Requires temporally coherent BFMCS |
| 4.2 | Wire final completeness | theorem | Should work | Standard pattern |

## 7. Gaps and Risks

### Critical Gaps

1. **Dovetailed FMCS forward_F/backward_P in quotient**: The Boneyard code has `dovetailedTimelineQuotFMCS_forward_F` with sorry. Need to verify this is provable from coverage theorems.

2. **DenselyOrdered instance**: Need to prove the dovetailed quotient is densely ordered (from DN axiom). This may require extracting the density frame condition at MCS level.

3. **Domain type alignment**: The FMCS is on `DovetailedTimelineQuot`, but parametric pipeline expects FMCS on generic D. Need type alignment lemma or direct construction.

### Medium Risks

1. **Quotient MCS well-definedness**: If two DovetailedPoints have the same MCS, they should be in the same equivalence class. This needs verification.

2. **Temporal coherence for BFMCS**: The parametric truth lemma requires `B.temporally_coherent`. Need to verify this holds for dovetailed construction.

### Low Risks

1. **Group structure transfer**: Well-understood, existing infrastructure in `DurationTransfer.lean`.

2. **Parametric history construction**: `parametric_to_history` is already proven correct with full domain.

## 8. Recommendations

### Primary Path: Fix Current Approach

Rather than implementing full Z-approach, the quickest fix is:

1. **Replace `shiftedFlagWorldHistory`** with `parametric_to_history`
2. **Use full domain** (domain = True) instead of range-restricted domain
3. **Wire through FMCSTransfer** or construct BFMCS directly on FlagBFMCS

This avoids the complexity of Dovetailed quotient construction while achieving the same goal.

### Alternative: Full Dovetailed Approach

If FlagBFMCS continues to have issues:

1. Extract `DovetailedTimelineQuot.lean` from Boneyard
2. Prove remaining sorries for forward_F/backward_P
3. Prove DenselyOrdered instance
4. Wire into parametric pipeline

### What NOT to Do

- Do NOT try to make the discrete chain convex in Rat (mathematically impossible)
- Do NOT modify `WorldHistory.convex` requirement (changes core semantics)
- Do NOT use domain restriction on continuous domain type

## References

| File | Relevance |
|------|-----------|
| `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean` | Dovetailed construction |
| `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCoverage.lean` | Coverage theorems |
| `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` | Chain FMCS infrastructure |
| `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean` | Group transfer |
| `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean` | `parametric_to_history` |
| `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` | Shifted truth lemma |
| `Theories/Bimodal/Boneyard/Task994_DovetailedQuot/DovetailedTimelineQuot.lean` | Quotient attempt |
| `Mathlib.Order.SuccPred.LinearLocallyFinite` | `orderIsoIntOfLinearSuccPredArch` |
| `Mathlib.Algebra.Group.TransferInstance` | `Equiv.addCommGroup` |

## Next Steps

1. **Verify**: Can `parametric_to_history` be applied directly to existing FlagBFMCS infrastructure?
2. **If yes**: Modify Phase 3-4 of current implementation to use parametric pipeline with full domain
3. **If no**: Evaluate whether DovetailedTimelineQuot extraction from Boneyard is viable
