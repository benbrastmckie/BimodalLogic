# Handoff: g_sub_g_new Implementation and Limit Guard Closure

## Status: 8 new g_sub_g_new sorries added, infrastructure in place

## What Was Done

### 1. Enriched splitting lemma return types (PointInsertion.lean)
All 5 splitting lemmas now return `B ⊆ B'` and `B ⊆ B''`:
- `lemma_2_6_splitting`: Added `B ⊆ B' ∧ B ⊆ B''` (was only `B ⊆ D`)
- `lemma_2_7`: Added `B ⊆ B''` (already had `B ⊆ B'`)
- `lemma_2_8`: Added `B ⊆ B' ∧ B ⊆ B''` (was only `B ⊆ D`)
- `lemma_2_7_since`: Added `B ⊆ B''` (already had `B ⊆ B'`)
- `lemma_2_8_since`: Added `B ⊆ B' ∧ B ⊆ B''` (was only `B ⊆ D`)

### 2. Updated all callers in CounterexampleElimination.lean
Every `obtain` destructuring of splitting lemma results updated to handle new fields.
`.choose_spec` projections updated where `.2.2.2.2` became `.2.2.2.2.1`.

### 3. Added `g_sub_g_new` field to EliminationResult
```lean
g_sub_g_new : ∀ a b, Adjacent χ.dom a b → ∀ w ∈ val.dom, w ∉ χ.dom →
    a < w → w < b → χ.g a b ⊆ val.g a w ∧ χ.g a b ⊆ val.g w b
```

### 4. Proved g_sub_g_new for 10 cases
- 7 trivial cases (no new point): `fun _ _ _ w hw hw_not _ _ => absurd hw hw_not`
- 2 "beyond all" cases (n=0, Walk Case A): same vacuous proof as g_sub_f_insert
- 1 splitting case (Walk Case B, c5_forward): fully proved using `h_g_sub_B'` and `h_g_sub_B''`

### 5. Enriched h_split_result_u intermediate existential
Added `χ.g u_max u_next ⊆ B'` and `χ.g u_max u_next ⊆ B''` to the 7-field type.
All 7 sub-cases updated to pass through B ⊆ B' and B ⊆ B'' from enriched splitting lemmas.

## Remaining Work

### 8 g_sub_g_new := sorry sites in CounterexampleElimination.lean

All follow the SAME pattern as the proved case (ChronicleConstruction.lean line 1189).

| Line | Case | Notes |
|------|------|-------|
| 1409 | c5_forward, not-cond-i split at (pc.x, x') | Need to enrich h_split_result (analogous to h_split_result_u) |
| 1543 | c5_backward, n=0 case | New point y placed before all — same vacuous pattern as c5_forward n=0 |
| 1683 | c5_backward, Walk Case A | New point y before all — same vacuous pattern |
| 1877 | c5_backward, Walk Case B split | Need to enrich intermediate existential |
| 2062 | c5_backward, not-cond-i split | Need to enrich intermediate existential |
| 2340 | c4_forward split at (w, w_next) | Simple split: g'(w,z)=B', g'(z,w_next)=B'' |
| 2603 | c4_backward split at (w_prev, w) | Mirror of c4_forward |
| 2792 | density split at (pc.x, pc.y) | Simple split: g'(x,z)=B', g'(z,y)=B'' |

### Pattern for each sorry

For each splitting case:
1. The intermediate existential (h_split_result, h_split_pw, etc.) needs enrichment with B ⊆ B' and B ⊆ B''
2. Each sub-case must capture and pass through these fields from the enriched splitting lemma
3. The proof extracts `h_g_sub_B'` and `h_g_sub_B''` from the enriched existential
4. Shows `a = left_endpoint` and `b = right_endpoint` by adjacency (same proof as g_sub_f_insert)
5. Uses `h_g_sub_B'` for `g(a,b) ⊆ g'(a,z)` and `h_g_sub_B''` for `g(a,b) ⊆ g'(z,b)`

### For lines 1543, 1683 (c5_backward n=0 and Walk Case A)

These are simpler. The new point y is placed BEFORE all existing domain points.
For any old adjacent pair (a,b), since `y < min_old ≤ a`, we have `¬(a < y)`,
so the precondition `a < w` (where w = y) fails. The proof is vacuous:
```lean
g_sub_g_new := by
  intro a b h_adj w hw hw_not haw hwb
  simp only [χ', Finset.mem_insert] at hw
  rcases hw with rfl | hw
  · exact absurd haw (not_lt.mpr (le_of_lt (hy_lt a h_adj.1)))
  · exact absurd hw hw_not
```

### After g_sub_g_new is sorry-free

1. Add `omega_chain_g_sub_g_new` to ChronicleConstruction.lean (lift to omega chain level)
2. Prove omega_chain_guard_invariant by induction
3. Close the 2 sorry sites in limit_satisfies_c5_strong and limit_satisfies_c5'_strong
4. Run `lake build` and verify 0 sorry sites in Chronicle/

## Build Status

`lake build` passes (1097 jobs). 10 sorry sites total:
- 2 original in ChronicleConstruction.lean:1301,1313
- 8 new in CounterexampleElimination.lean (g_sub_g_new fields)

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`: Enriched 5 splitting lemma returns
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`: Updated callers, added g_sub_g_new field, proved 10 cases, 8 sorry
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`: Unchanged (2 original sorries remain)
