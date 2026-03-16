# Research Report: Task #974 - LocallyFiniteOrder Proof Strategy

**Task**: 974 - prove_discrete_timeline_succorder_predorder
**Date**: 2026-03-16
**Mode**: Team Research (3 teammates)
**Domain Override**: logic (mathematical elegance focus)
**Session**: sess_1773691459_r4t9w

---

## Summary

Three teammates investigated the LocallyFiniteOrder proof strategy for `DiscreteTimelineQuot`. The research identifies a clear, mathematically elegant path that avoids the main technical obstacle (no generic `Antisymmetrization.locallyFiniteOrder` in Mathlib) by constructing the instance directly via stage-bounded quotient images.

**Core recommendation**: Prove `(Set.Icc a b).Finite` by showing `Icc [a] [b]` in the quotient is a subset of the finite image of a stage-bounded `discreteStagedBuild N`, then use `LocallyFiniteOrder.ofFiniteIcc` to instantiate `LocallyFiniteOrder`.

---

## Key Findings

### Primary Approach (Teammate A: Mathlib Patterns)

**Two paths to IsSuccArchimedean**:

1. **Path A** (recommended): `LocallyFiniteOrder` → automatic `IsSuccArchimedean`
   ```lean
   instance (priority := 100) [LocallyFiniteOrder ι] [SuccOrder ι] : IsSuccArchimedean ι
   ```

2. **Path B** (alternative): Direct `IsSuccArchimedean` via `orderIsoIntOfLinearSuccPredArch`
   ```lean
   noncomputable def orderIsoIntOfLinearSuccPredArch [NoMaxOrder ι] [NoMinOrder ι] : ι ≃o ℤ
   ```

**Key constructor verified**:
```lean
noncomputable def LocallyFiniteOrder.ofFiniteIcc
    (h : ∀ a b : α, (Set.Icc a b).Finite) : LocallyFiniteOrder α
```

All necessary Mathlib lemmas confirmed via `lean_local_search`:
- `LocallyFiniteOrder.ofFiniteIcc` in `Mathlib.Order.Interval.Finset.Defs`
- `LinearLocallyFiniteOrder.succFn_le_of_lt` (requires LocallyFiniteOrder)
- `IsSuccArchimedean` automatic from LocallyFiniteOrder + SuccOrder

### Alternative Approaches (Teammate B: Codebase Analysis)

**Existing infrastructure ready to use**:
- `discreteStagedBuild : Nat → Finset StagedPoint` (finite per stage by construction)
- `discreteStagedBuild_monotone_le` (monotonicity, key for stage bounding)
- `discrete_staged_timeline_countable` (sanity check)
- Per-stage finiteness already established via `Finset.finite_toSet`

**Stage bounding approach**:
For `[a] < [b]` in the quotient, all elements in `Icc [a] [b]` come from the image of `discreteStagedBuild (max n_a n_b)` in the quotient. Each `evenStage` adds at most 2 witnesses per point per formula — bounded.

**Dense vs. Discrete contrast** (confirms approach is valid):
The dense construction adds `densityWitnessesForSet` (unbounded), making LocallyFiniteOrder impossible. The discrete construction's omission of this step is precisely what enables LocallyFiniteOrder.

### Risks and Edge Cases (Teammate C: Risk Analysis)

**Critical gap confirmed**: Mathlib has **no** `Antisymmetrization.locallyFiniteOrder` instance. This is the core obstacle to a naive approach.

**Key risks**:
1. Generic quotient lift requires: lifting Finset.Icc from base type, proving quotient map preserves finiteness, handling equivalence classes
2. Multiple `StagedPoint`s may have the same underlying MCS (multiple stages may contain the same MCS)
3. DF coverness not formally extracted (not needed for our recommended approach)

**What is NOT a risk**:
- Quotient collapse: prevented by `canonicalR_irreflexive`
- Non-terminating construction: expected (countable infinite timeline)
- Infinite encoding values: intervals still finite

---

## Synthesis

### Conflicts Resolved

**Conflict**: Teammate A claims high confidence; Teammate C rates formalization difficulty as low.

**Resolution**: The confidence gap reflects different levels of analysis. Teammate A found the right Mathlib pattern; Teammate C identified the key obstacle (no generic Antisymmetrization.locallyFiniteOrder). The resolution is to bypass the generic instance entirely and construct LocallyFiniteOrder directly for this type using the stage structure.

### The Mathematically Elegant Solution

**Core insight from synthesis**: Since `DiscreteTimelineQuot` is defined as `Antisymmetrization (DiscreteTimelineElem ...) (·≤·)`, and elements of `DiscreteTimelineElem` are drawn from the countable union of `discreteStagedBuild n` (each a `Finset`), we can prove interval finiteness directly without needing a generic Antisymmetrization instance.

**The elegant proof structure**:

```lean
-- Step 1: For any quotient element [a], define its "minimum stage" as the
-- smallest n where a representative appears in discreteStagedBuild n
-- (well-defined because the construction is monotone)

-- Step 2: Key lemma
theorem discrete_Icc_stage_bounded
    (a b : DiscreteTimelineQuot) :
    Set.Icc a b ⊆
    (discreteStagedBuild (max (minStage a) (minStage b))).image
      (toAntisymmetrization (· ≤ ·) ∘ Subtype.val) := by
  -- Any c in [a, b] has a representative that is ≤-related to representatives of a and b
  -- By monotonicity, that representative is in discreteStagedBuild (max n_a n_b)
  -- So [c] is in the image
  ...

-- Step 3: The image of a Finset is a finite set
theorem discrete_Icc_finite (a b : DiscreteTimelineQuot) :
    (Set.Icc a b).Finite :=
  Set.Finite.subset (Finset.finite_toSet _).image _ (discrete_Icc_stage_bounded a b)

-- Step 4: Instantiate LocallyFiniteOrder
noncomputable instance : LocallyFiniteOrder DiscreteTimelineQuot :=
  LocallyFiniteOrder.ofFiniteIcc discrete_Icc_finite
```

**Why this is elegant**:
1. Bypasses the need for generic `Antisymmetrization.locallyFiniteOrder`
2. Uses the natural structure of the construction directly
3. All three sorries then follow automatically from the instance
4. No new axioms needed

### The Critical Lemma to Prove

The entire proof reduces to:

```
discrete_Icc_stage_bounded : Icc [a] [b] ⊆ image (toAntisymmetrization ∘ repr) (discreteStagedBuild N)
```

where `N = max (minStage a) (minStage b)`.

**Proof strategy**:
1. Take any `[c] ∈ Icc [a] [b]`, i.e., `[a] ≤ [c] ≤ [b]`
2. Pick representative `c' ∈ DiscreteTimelineElem` with `[c'] = [c]`
3. Since `[a] ≤ [c]`, there exist representatives showing `a' ≤ c'` in the preorder
4. Since `[c] ≤ [b]`, similarly `c' ≤ b'`
5. Representatives `a', b'` appear in `discreteStagedBuild n_a` and `discreteStagedBuild n_b`
6. By monotonicity, both are in `discreteStagedBuild N`
7. **Key step**: The F/P witness construction is "locally bounded" — a point between a' and b' in the preorder cannot have been introduced at a stage after N, because it would need to be a witness for some obligation already present in stage N, and all such witnesses are introduced by stage N+1... **This requires careful analysis**

**Alternative key step** (simpler, may suffice):
The preorder `≤` on `DiscreteTimelineElem` is determined by CanonicalR reachability. If `a' ≤ c' ≤ b'` in the preorder, then since `a', b' ∈ discreteStagedBuild N`, the point `c'` must also appear in the construction by stage N (all witnesses for CanonicalR chains between a' and b' are present). This is the "completeness" of the staged construction.

### Remaining Gap: Stage Bounding Proof

The main outstanding question is whether the F/P witness construction has the "locally complete" property: if `a' ≤ c' ≤ b'` and both `a', b'` are in stage N, then `c'` is also in stage N.

**Evidence this holds** (from Teammate B):
- `evenStage` adds witnesses that are "local" to existing points
- The discreteness property (no density) prevents unbounded chain insertions
- The construction already acknowledges this in comments (DiscreteTimeline.lean:337-348)

**If the key step cannot be proven directly**: Escape valve available per plan v3 (axiomatize `discrete_staged_finite_intervals` temporarily, clearly documented as technical debt).

---

## Recommendations

### Phase 7 Implementation Plan (Revised)

**Phase 7a: Prove `minStage` function and properties**

```lean
-- Define: minimum stage where a representative appears
noncomputable def minStage (a : DiscreteTimelineQuot) : ℕ :=
  Nat.find (exists_stage_of_quotient_elem a)
```

**Phase 7b: Prove `discrete_Icc_stage_bounded`**

```lean
theorem discrete_Icc_stage_bounded (a b : DiscreteTimelineQuot) :
    Set.Icc a b ⊆
    (discreteStagedBuild (max (minStage a) (minStage b))).image
      (Quotient.mk (antisymmRel (· ≤ ·)) ∘ Subtype.val)
```

**Phase 7c: Instantiate LocallyFiniteOrder**

```lean
theorem discrete_Icc_finite (a b : DiscreteTimelineQuot) :
    (Set.Icc a b).Finite

noncomputable instance : LocallyFiniteOrder DiscreteTimelineQuot :=
  LocallyFiniteOrder.ofFiniteIcc discrete_Icc_finite
```

**Phase 7d: Remove 3 sorries**

With `LocallyFiniteOrder` instantiated:
- `discrete_timeline_lt_succFn`: Use `LinearLocallyFiniteOrder.succFn_lt` (derived from LocallyFiniteOrder + NoMaxOrder)
- `discrete_timeline_predFn_lt`: Symmetric
- `IsSuccArchimedean`: Automatic from `instance [LocallyFiniteOrder] [SuccOrder] : IsSuccArchimedean`

### Mathlib Lemmas to Use

| Goal | Mathlib Lemma |
|------|--------------|
| Construct LocallyFiniteOrder | `LocallyFiniteOrder.ofFiniteIcc` |
| Finset image is finite | `Set.Finite.image` |
| Image ⊆ source finiteness | `Set.Finite.subset` |
| SuccOrder from succFn | `LinearLocallyFiniteOrder.succOrder` |
| IsSuccArchimedean auto | `instance [LocallyFiniteOrder] [SuccOrder]` |

### Effort Estimate

| Phase | Description | Effort |
|-------|-------------|--------|
| 7a | `minStage` function | 30 min |
| 7b | Stage bounding lemma | 1-1.5 hrs |
| 7c | LocallyFiniteOrder instance | 30 min |
| 7d | 3 sorry resolution | 30 min |
| **Total** | | **2.5-3 hrs** |

Escape valve: Axiomatize step 7b if stuck > 2 hours (clearly documented debt).

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Mathlib LocallyFiniteOrder patterns | Completed | High (patterns) / Medium (finiteness) |
| B | Codebase finiteness infrastructure | Completed | High (existing infra) / Medium (stage bounding) |
| C | Risk analysis: Antisymmetrization gap | Completed | Critical risk identified |

## Key Conflict Resolution

Teammates A and C disagreed on confidence. The synthesis resolves this: Teammate A correctly identified the Mathlib patterns; Teammate C correctly identified that no generic `Antisymmetrization.locallyFiniteOrder` exists. The resolution is to construct the instance directly via the staged construction, avoiding the generic path entirely.

---

## References

- `Mathlib.Order.Interval.Finset.Defs` - LocallyFiniteOrder.ofFiniteIcc
- `Mathlib.Order.SuccPred.LinearLocallyFinite` - succFn, IsSuccArchimedean auto-instance
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` - discreteStagedBuild, monotonicity
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - 3 sorries at lines 248, 306, 351
