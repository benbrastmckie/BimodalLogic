# Research Report: Task 974 - Prove DiscreteTimeline SuccOrder/PredOrder

**Task**: prove_discrete_timeline_succorder_predorder
**Session**: sess_1742169600_r8k3m
**Date**: 2026-03-16

## Executive Summary

This task involves proving 7 sorries in `DiscreteTimeline.lean` that establish `SuccOrder`, `PredOrder`, and `IsSuccArchimedean` instances on the discrete timeline quotient. The proofs are structurally straightforward given the existing infrastructure, but require careful handling of the `Classical.choice`-based `succ` definition.

**Key finding**: The current `succ` definition uses `Classical.choice` on an existence witness but does NOT select the minimal element. This is a **design flaw** that makes `succ_le_of_lt` unprovable as stated. The fix is to redefine `succ` using `SuccOrder.ofLinearWellFoundedLT` or similar well-founded minimum construction.

## Sorry Analysis

### Location and Goal Types

| Line | Field | Goal Type | Difficulty |
|------|-------|-----------|------------|
| 179 | `SuccOrder.le_succ` | `a <= succ(a)` | Easy (after design fix) |
| 187 | `SuccOrder.max_of_succ_le` | `succ(a) <= a -> IsMax a` | Easy (after design fix) |
| 200 | `SuccOrder.succ_le_of_lt` | `a < b -> succ(a) <= b` | **ROOT CAUSE** |
| 212 | `PredOrder.pred_le` | `pred(a) <= a` | Symmetric to 179 |
| 213 | `PredOrder.min_of_le_pred` | `a <= pred(a) -> IsMin a` | Symmetric to 187 |
| 218 | `PredOrder.le_pred_of_lt` | `a < b -> a <= pred(b)` | Symmetric to 200 |
| 231 | `IsSuccArchimedean.exists_succ_iterate_of_le` | `a <= b -> exists n, succ^[n](a) = b` | Medium |

### Root Cause: Flawed `succ` Definition

The current definition at lines 162-169 is:

```lean
succ := fun a =>
  if h : IsMax a then a
  else
    let ⟨b, hb⟩ := not_isMax_iff.mp h
    Classical.choice ⟨b⟩
```

**Problem**: `Classical.choice ⟨b⟩` returns an arbitrary element of type `DiscreteTimelineQuot`, not the **least** element greater than `a`. The `b` witness from `not_isMax_iff.mp h` proves `a < b`, but `Classical.choice` ignores `b` entirely and just picks any inhabitant.

**Consequence**: `succ_le_of_lt` (line 200) requires that `succ(a)` is the least strict upper bound of `a`. With the current definition, we cannot prove this because `Classical.choice` may return an element that is NOT the minimum.

## Recommended Fix

### Option 1: Use `WellFounded.min` (Recommended)

Replace the `succ` definition with:

```lean
noncomputable instance : SuccOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
  succ := fun a =>
    if h : (Set.Ioi a).Nonempty then
      WellFounded.min wellFounded_lt (Set.Ioi a) h
    else a
  le_succ := by
    intro a
    by_cases h : (Set.Ioi a).Nonempty
    · simp only [h, dite_true]
      exact le_of_lt (WellFounded.min_mem wellFounded_lt (Set.Ioi a) h)
    · simp only [h, dite_false]
  max_of_succ_le := by
    intro a ha
    by_cases h : (Set.Ioi a).Nonempty
    · simp only [h, dite_true] at ha
      have h_min := WellFounded.min_mem wellFounded_lt (Set.Ioi a) h
      exact absurd (lt_of_lt_of_le h_min ha) (lt_irrefl a)
    · exact not_nonempty_iff_eq_empty.mp h ▸ fun b hb => le_of_not_lt (by simp_all)
  succ_le_of_lt := by
    intro a b hab
    by_cases h : (Set.Ioi a).Nonempty
    · simp only [h, dite_true]
      exact WellFounded.min_le wellFounded_lt hab h
    · exact absurd ⟨b, hab⟩ h
```

**Prerequisite**: Prove `WellFoundedLT (DiscreteTimelineQuot root_mcs root_mcs_proof)`.

### Why WellFoundedLT Holds for Discrete Timeline

The discrete timeline quotient has:
1. `NoMinOrder` (proven at line 269)
2. `NoMaxOrder` (proven at line 247)
3. `LinearOrder` (inherited from `Antisymmetrization`)
4. **Discreteness** (no dense intermediate points)

For a discrete linear order with no min/max, the `<` relation is NOT globally well-founded (infinite descending chains exist). However, `WellFoundedLT` in Mathlib means "every non-empty set has a minimum" which is equivalent to "no infinite strictly descending chains" for linear orders.

**Alternative**: Use `LinearLocallyFiniteOrder.succOrder` which constructs `SuccOrder` from `LocallyFiniteOrder`. The discrete timeline is locally finite (intervals are finite due to discreteness + countability).

### Option 2: Use Mathlib's `SuccOrder.ofCore`

```lean
noncomputable instance : SuccOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) :=
  SuccOrder.ofCore
    (fun a => if h : (Set.Ioi a).Nonempty then WellFounded.min wellFounded_lt _ h else a)
    (fun {a} hna b => ⟨
      fun hab => WellFounded.min_le wellFounded_lt hab ⟨b, hab⟩,
      fun hsa => lt_of_lt_of_le (WellFounded.min_mem _ _ _) hsa⟩)
    (fun a ha => by simp [Set.not_nonempty_iff_eq_empty.mpr (Set.Ioi_eq_empty_of_isMax ha)])
```

### Option 3: Prove LocallyFiniteOrder and Use Instance

If we can prove `LocallyFiniteOrder (DiscreteTimelineQuot root_mcs root_mcs_proof)`, then:
- `LinearLocallyFiniteOrder.succOrder` provides `SuccOrder` automatically
- `LinearLocallyFiniteOrder.isSuccArchimedean` provides `IsSuccArchimedean` automatically

This requires proving that `Finset.Icc a b` is well-defined and finite for any `a <= b`.

## Proof Strategies by Sorry

### Line 179: `le_succ` (after fix)
With the fixed definition using `WellFounded.min`:
- If `(Set.Ioi a).Nonempty`: `a < WellFounded.min ...` by `min_mem`, so `a <= succ(a)`
- If empty: `succ(a) = a`, so `a <= a` by reflexivity

### Line 187: `max_of_succ_le` (after fix)
- If `(Set.Ioi a).Nonempty` and `succ(a) <= a`:
  - `WellFounded.min_mem` gives `a < succ(a)`
  - Combined with `succ(a) <= a` gives `a < a`, contradiction
- If `(Set.Ioi a)` empty: `a` is maximal by definition

### Line 200: `succ_le_of_lt` (after fix)
- Given `a < b`, we have `b in Set.Ioi a`, so `(Set.Ioi a).Nonempty`
- `WellFounded.min_le` gives `succ(a) <= b`

### Lines 212-218: PredOrder (symmetric)
Define `pred` symmetrically using `WellFounded.min` on `Set.Iio a` with `WellFoundedGT`.

### Line 231: IsSuccArchimedean
With the correct `SuccOrder` instance, this follows from local finiteness. The key insight:
- For `a <= b` in a discrete linear order, the interval `[a, b]` is finite
- By induction on `|Finset.Icc a b|`, we can show `exists n, succ^[n](a) = b`

Alternatively, if we establish `LocallyFiniteOrder`, the instance is automatic from `LinearLocallyFiniteOrder.instIsSuccArchimedeanOfLocallyFiniteOrder`.

## Dependencies

### Required New Lemmas

1. **`DiscreteTimelineQuot.wellFoundedLT`**: Prove `WellFoundedLT` on the quotient
   - Approach: Show every non-empty subset has a minimum
   - Uses: Discreteness of the timeline (no dense intermediate points)

2. **`DiscreteTimelineQuot.locallyFinite`** (alternative): Prove `LocallyFiniteOrder`
   - Approach: Define `Finset.Icc a b` explicitly using the quotient structure
   - Uses: Countability + discreteness implies intervals are finite

### Existing Infrastructure (Verified Present)

| Lemma | File | Purpose |
|-------|------|---------|
| `canonicalR_irreflexive` | CanonicalIrreflexivityAxiom.lean | Strictness of CanonicalR |
| `canonicalR_strict` | CanonicalIrreflexivityAxiom.lean | `CanonicalR M N -> not CanonicalR N M` |
| `staged_timeline_has_future` | CantorPrereqs.lean | Seriality forward |
| `staged_timeline_has_past` | CantorPrereqs.lean | Seriality backward |
| `NoMaxOrder` instance | DiscreteTimeline.lean:247 | Already proven |
| `NoMinOrder` instance | DiscreteTimeline.lean:269 | Already proven |
| `LinearOrder` instance | DiscreteTimeline.lean:107 | Already proven |

### Mathlib Tools

| Lemma | File | Use Case |
|-------|------|----------|
| `WellFounded.min` | Order.WellFounded | Minimum of non-empty set |
| `WellFounded.min_mem` | Order.WellFounded | min is in the set |
| `WellFounded.min_le` | Order.WellFounded | min <= any element |
| `SuccOrder.ofCore` | Order.SuccPred.Basic | Alternative constructor |
| `LinearLocallyFiniteOrder.succOrder` | Order.SuccPred.LinearLocallyFinite | Auto SuccOrder |
| `LinearLocallyFiniteOrder.isSuccArchimedean` | Order.SuccPred.LinearLocallyFinite | Auto IsSuccArchimedean |

## Implementation Plan

### Phase 1: Fix succ/pred definitions (estimated: 30 min)

1. Add helper lemma for `WellFoundedLT` or `LocallyFiniteOrder`
2. Redefine `succ` using `WellFounded.min` pattern
3. Redefine `pred` symmetrically

### Phase 2: Prove SuccOrder fields (estimated: 20 min)

1. `le_succ`: Direct from `WellFounded.min_mem`
2. `max_of_succ_le`: Contradiction with `min_mem` + `min_le`
3. `succ_le_of_lt`: Direct from `WellFounded.min_le`

### Phase 3: Prove PredOrder fields (estimated: 15 min)

4. `pred_le`: Symmetric to `le_succ`
5. `min_of_le_pred`: Symmetric to `max_of_succ_le`
6. `le_pred_of_lt`: Symmetric to `succ_le_of_lt`

### Phase 4: Prove IsSuccArchimedean (estimated: 25 min)

7. `exists_succ_iterate_of_le`: Induction on interval size or use `LocallyFiniteOrder` instance

### Total Estimated Time: 1.5-2 hours

## Risks and Mitigations

### Risk 1: WellFoundedLT may be hard to prove directly

**Mitigation**: Use the `LocallyFiniteOrder` approach instead, which is more natural for a countable discrete order.

### Risk 2: Upstream build errors in DurationTransfer.lean

**Mitigation**: The errors in DurationTransfer.lean are independent type-class issues. DiscreteTimeline.lean should compile once fixed, but the full pipeline may need DurationTransfer fixes too.

### Risk 3: Discreteness axiom may not be sufficient

The DF axiom guarantees coverness at the semantic level, but we need it at the syntactic (MCS) level. The current `NoMaxOrder`/`NoMinOrder` proofs already bridge this gap using `canonicalR_irreflexive`, so the pattern is established.

## Conclusion

The 7 sorries in DiscreteTimeline.lean are resolvable, but require **redefining the `succ` function** to use a proper minimum selection rather than `Classical.choice`. Once fixed, all proofs follow from standard Mathlib patterns for well-founded orders.

The recommended approach is:
1. Prove `WellFoundedLT` or `LocallyFiniteOrder` on the quotient
2. Use `WellFounded.min` to define `succ`/`pred`
3. Apply standard Mathlib lemmas for the remaining proofs

This is a well-scoped implementation task with clear dependencies and no fundamental blockers.
