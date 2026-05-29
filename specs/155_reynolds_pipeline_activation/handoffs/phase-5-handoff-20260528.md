# Phase 5 Handoff: Case II Simplification

## What Was Done

Eliminated the `resp_mod` indirection layer from `ghr93_case_II` in CaseAnalysis.lean. This removed ~338 lines of boilerplate case splits (`heq_k`/`hne_k` on `a_init k = extendPoint p_n`) throughout the Round 2 dispatch.

### Key Insight

`hord_left_sel_pn` proves `(a_init k = p_n iff resp_left k = e_n)`, which means `resp_mod k = resp_left k` for ALL k. The `resp_mod` definition (which checked whether `a_init k = p_n` and substituted `e_n`) was therefore completely redundant. Using `resp_left` directly eliminates all four-way case splits that propagated through every ordering proof.

### What Changed

1. **Deleted**: `resp_mod`, `hresp_mod_eq`, `hresp_mod_ne`, `hresp_mod_in`, `sel_pn_ord` (replaced by `hord_left_sel_pn`)
2. **Simplified**: `a'_resp` now uses `resp_left` directly
3. **Cases A, B1, B2**: All `full_sel_sel`, `full_x_sel`, `full_b_sel`, `full_y_sel`, `sel_y_ord`, gap/point agreement, and formula agreement sections simplified by removing `heq_k`/`hne_k` case analysis

### What Was NOT Done (and Why)

Tasks 5.1-5.4 (the full GHR93 U(B,A) rewrite) were skipped because:
- **Until witness containment**: `untl_extract_witness` returns a witness `z > ref_M` in the FULL `ExtendedCarrier`, not guaranteed to be in `[x, y]`. This is a fundamental blocker for the pure GHR93 approach.
- **No bridge between tau and forward game**: Without U(B,A), `sel_pn_ord` cannot be derived from tau_r alone (p_n/e_n are not in tau's game tuple). The forward game + tau_left bridge remains necessary.
- The plan's Rollback/Contingency section anticipated this: "use forward game h_fwd_n1 for EXISTENCE and interval containment, U(B,A) only for FORMULA PROPERTIES"

### Architecture After This Change

```
ghr93_case_II (lines 1196-1866):
  Step 1: Extract p_n, define a_init (lines 1239-1247) -- UNCHANGED
  Step 2: Project sigma/tau to rank r (lines 1248-1255) -- UNCHANGED
  Step 3: Forward game for e_n (lines 1257-1288) -- UNCHANGED
  Step 4: Extract formula/ordering from forward game (lines 1289-1345) -- UNCHANGED
  Step 5: Hoist p_cy, tau formula data (lines 1346-1357) -- UNCHANGED
  Step 6: tau_left and tau_right via IH (lines 1358-1378) -- UNCHANGED
  Step 7: Play tau_left for resp_left, extract sel_pn_ord (lines 1392-1414) -- UNCHANGED
  [DELETED: resp_mod definition and helpers -- was lines 1415-1439]
  Step 8: a'_resp = resp_left + e_n, Round 2 dispatch (lines 1415-1866) -- SIMPLIFIED
```

## Next Actions

Phase 6 (Cases III/IV) is the next target. The sorry at line 3146 is in `ghr93_cases_III_IV`.

## Verification

- `lake build` passes with zero errors
- Only sorry in CaseAnalysis.lean is line 3146 (Cases III/IV)
- ghr93_case_II remains sorry-free
- Net reduction: 338 lines (3633 -> 3295)
