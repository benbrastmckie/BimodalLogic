# Research Report: Does the Sorting Invariant Make tau_left Unnecessary?

**Task**: 155
**Date**: 2026-05-28
**Focus**: Whether `Monotone a_bwd` (sorting) trivializes the biconditional ordering and eliminates the need for `tau_left`

## Executive Summary

**The hypothesis is INCORRECT. The sorting invariant does NOT make tau_left unnecessary.**

The hypothesis rests on the claim that if selections are sorted, then `a_init(k) < p_n` is TRUE for all k < n, making the biconditional `(a_init(k) < p_n iff resp_tau(k) < e_n)` reduce to `(TRUE iff TRUE)`. This analysis fails on three independent grounds:

1. **Sorting is WEAK monotone, not strict** -- `Monotone a_bwd` gives `a_init(k) <= p_n`, not `a_init(k) < p_n`. Equality is possible when multiple selections coincide at p_n.

2. **tau_left provides the response function itself** -- `resp_left` IS the actual Duplicator response for positions 0..n-1. Without tau_left, there IS no response function. The biconditional is not an add-on; it comes from the same game that produces the responses.

3. **tau_left provides gap/point and formula data** -- Even if the biconditional were trivially true, tau_left also provides gap/point agreement (`_hgp_left`) and formula agreement (`hform_left`) at inner selection indices, plus ordering data between d/sel and sel/sel pairs. There is no alternative source for this data.

## Detailed Analysis

### 1. Sorting Is Weak Monotone

The sorting invariant in the Lean formalization is:

```lean
-- CaseAnalysis.lean, line 3420
have h_mono : Monotone a_sorted := Tuple.monotone_sort a_bwd
```

Where `Monotone` is defined in Mathlib as:

```
Monotone f : Prop := forall a b, a <= b -> f a <= f b
```

This gives **weak** monotonicity: `a_bwd(k) <= a_bwd(n) = p_n` for all k. The hypothesis claims "strict sorting: a_0 < a_1 < ... < a_n", but the Lean code uses `Monotone`, not `StrictMono`. Multiple selections CAN coincide.

When `a_init(k) = p_n` (which IS allowed by `Monotone`), the biconditional becomes:

```
(FALSE iff ???) and (TRUE iff ???)
```

The `???` depends on whether `resp(k) < e_n` or `resp(k) = e_n`. Without tau_left, there is NO way to determine this -- `resp_tau` from the full `[d,y'] -> [c,y]` game gives `resp_tau(k) in [c, y]`, which could be anywhere relative to `e_n`.

### 2. tau_left Provides the Response Function

The critical structure of `ghr93_case_II` is:

```lean
-- Line 1573: Play tau_left to get resp_left
obtain <resp_left, hresp_left_in, hwin_left> := tau_left a_init ha_init_sub

-- Line 1595-1596: Build Duplicator's response FROM resp_left
let a'_resp : Fin (n + 1) -> ExtendedCarrier M atomMap r := fun i =>
  if h : i.val < n then resp_left <i.val, h> else e_n
```

Duplicator's response for positions 0..n-1 IS `resp_left`. Without tau_left:
- What function would replace `resp_left`?
- `resp_tau` from `tau_r` on `[d, y'] -> [c, y]` gives responses in `[c, y]`, but we need responses in `[c, e_n]`
- There is no mechanism to project or truncate `resp_tau` to `[c, e_n]`

### 3. Seven Categories of tau_left Usage

A comprehensive audit of `ghr93_case_II` (lines 1368-2136, 768 lines) found tau_left data used in **seven** distinct categories:

| Category | What tau_left provides | Lines | Replaceable by sorting? |
|----------|----------------------|-------|------------------------|
| **Response function** | `resp_left(k)` as Duplicator's actual response | 1594-1602 | NO -- sorting provides no response |
| **Biconditional ordering** | `a_init(k) < p_n iff resp_left(k) < e_n` | 1672-1681, 1870-1876, 2041-2047 | NO -- both directions needed |
| **Gap/point agreement** | `IsPoint(a_init(k)) iff IsPoint(resp_left(k))` | 1748, 1931, 2102 | NO -- no alternative source |
| **Formula agreement** | StaviFormula truth at `a_init(k)` iff at `resp_left(k)` | 1774, 1954, 2125 | NO -- no alternative source |
| **d-vs-sel ordering** | `d < a_init(k) iff c < resp_left(k)` | 1654, 1844, 2015 | NO -- pairs response with input |
| **sel-vs-sel ordering** | `a_init(j) < a_init(j') iff resp_left(j) < resp_left(j')` | 1660, 1850, 2021 | NO -- requires game data |
| **Case B1 Round 2** | `hwin_left b_sp hb_sp_ce` when `b_sp <= e_n` | 1797 | NO -- provides b_resp for Round 2 |

### 4. Why resp_tau Cannot Replace resp_left

Even setting aside the biconditional, `resp_tau` from `tau_r` is inadequate:

- **Interval mismatch**: `resp_tau(k) in [c, y]` but we need responses in `[c, e_n]` for the proof structure. The proof uses `hresp_left_in(k).2` (i.e., `resp_left(k) <= e_n`) extensively for interval bounds.

- **No e_n-relative orderings**: `tau_r` on `[d, y'] -> [c, y]` provides orderings relative to d, y', c, y -- but NOT relative to p_n or e_n. These are entirely different positions that are constructed AFTER tau_r is played.

- **Case B2 dependency**: In Case B2 (`b_sp > e_n`), the proof uses `resp_left(k) <= e_n < b_sp` (line 2067-2072) to establish that `b_resp > a_init(k)` on both sides. This requires `resp_left(k) in [c, e_n]`, which `resp_tau` cannot guarantee.

### 5. What GHR93 Actually Says About Sorting

From the plan (46_path-c-supremum-plan.md) and the Lean code:
- Spoiler's selections are sorted WLOG at `ghr93_inductive_step` (line 3416-3420)
- This is valid because `ghr93_winning_condition_perm` shows the winning condition is permutation-invariant
- Sorting gives `Monotone a_sorted`, which is WEAK
- Case II then uses this monotonicity for `h_ainit_le_pn` (line 1565-1570): `a_init(k) <= p_n`

In GHR93 the paper, the authors ALSO construct what corresponds to tau_left (a sub-game restricted to `[d, p_n]`). The sorting makes some inequalities trivial, but the sub-game is still necessary to produce the response function and its associated data.

### 6. The Actual Role of Sorting in Case II

Sorting IS used in `ghr93_case_II`, but only for one thing:

```lean
-- Line 1565-1570
have h_ainit_le_pn : forall (k : Fin n), a_init k <= extendPoint p_n := by
  intro k
  have hk_le : (<k.val, by omega> : Fin (n + 1)) <= <n, by omega> :=
    Fin.mk_le_mk.mpr (by omega)
  have := h_mono hk_le
  rw [hp_n] at this; exact this
```

This establishes `a_init(k) <= p_n`, which is needed to show `a_init` falls within the sub-interval `[d, p_n]` (line 1571-1572: `ha_init_sub`). This is a PREREQUISITE for playing tau_left, not a replacement for it. Without sorting, we'd need a different argument that `a_init(k) in [d, p_n]`.

## Conclusion

The sorting invariant is a necessary INGREDIENT for Case II (it ensures the init sub-sequence falls in `[d, p_n]`), but it cannot REPLACE tau_left. The previous implementation agent's analysis (handoffs/phase-5-task56-analysis-20260528.md) is correct: tau_left is mathematically necessary for the proof.

The biconditional ordering "blocker" is NOT a blocker -- it is a feature. `ghr93_case_II` is already sorry-free and axiom-clean at 733 lines. The tau_left/tau_right structure is the correct GHR93-faithful approach.

## Recommendation

Accept the current `ghr93_case_II` proof as is. The attempt to simplify by removing tau_left was based on a correct intuition (sorting helps) but an incorrect conclusion (sorting replaces tau_left). Proceed to Phase 6 (Cases III/IV) or Phase 7 (Transfer.lean wiring).
