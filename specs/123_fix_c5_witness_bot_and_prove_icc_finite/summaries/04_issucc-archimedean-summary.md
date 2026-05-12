# Implementation Summary: IsSuccArchimedean for LimitDomSubtype

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Plan**: plans/04_issucc-archimedean.md
- **Status**: Partial (1 sorry remains in IsSuccArchimedean cofinality argument)
- **Session**: sess_1778546993_adfab7

## What Was Done

### Phase 1: Add Imports and Prove Order.succ Equality [COMPLETED]

- Added three new Mathlib imports: `Mathlib.Topology.Instances.Real.Lemmas`, `Mathlib.Topology.Instances.NNReal.Lemmas`, `Mathlib.Data.Rat.Cast.Order`
- Proved `order_succ_eq_limitDomSubtype_succ`: `Order.succ = limitDomSubtype_succ` is definitional (`rfl`) under the `SuccOrder.ofSuccLeIff` construction
- Proved `order_pred_eq_limitDomSubtype_pred`: symmetric result for `PredOrder.ofLePredIff`

### Phase 2: Prove IsSuccArchimedean [PARTIAL]

- Defined `limitDomSubtype_isSuccArchimedean` as an `IsSuccArchimedean` instance
- Proved the reduction to orbit cofinality: if `exists n, b <= succ^[n] a`, then `exists k, succ^[k] a = b` (via `succ_orbit_convex`, a new lemma)
- **Sorry remains**: the orbit cofinality argument (showing `succ^[n] a` eventually reaches or exceeds `b`) requires a monotone convergence argument in R or a structural argument from the omega-chain construction. This is a well-defined mathematical challenge with no known simple proof.
- Added helper lemma `succ_orbit_convex`: if `a <= b <= succ^[n] a`, then `b = succ^[k] a` for some `k <= n` (proved sorry-free)

### Phase 3: Bridge to succ_embed_surjective [COMPLETED]

- Completely rewrote the proof body of `succ_embed_surjective` (from ~80 lines of stage induction with 2 sorry sites to ~50 lines using `IsSuccArchimedean`)
- The new proof splits on `root <= w` vs `w < root`:
  - For `root <= w`: uses `exists_succ_iterate_of_le` directly, giving `n` with `succ^[n](root) = w`, hence `succ_embed(n) = w`
  - For `w < root`: uses `exists_succ_iterate_of_le` on `w <= root` to get `n` with `succ^[n](w) = root`, then shows `w = pred^[n](root) = succ_embed(-n)` via iterated `pred_succ` cancellation
- Proved a helper `h_cancel`: `pred^[m](succ^[m](x)) = x` by induction using `limitDomSubtype_pred_succ`
- Updated docstrings and section comments

## Sorry Status

### Before this work
- `succ_embed_surjective`: 2 sorry sites (lines 2053, 2056 - above/below max/min cases)
- `dd_countermodel_chronicle_nondense_sorry`: 1 sorry (pre-existing)
- `dd_countermodel_chronicle_mixed_sorry`: 1 sorry (pre-existing)

### After this work
- `limitDomSubtype_isSuccArchimedean`: 1 sorry (orbit cofinality - new, well-documented)
- `dd_countermodel_chronicle_nondense_sorry`: 1 sorry (pre-existing, unchanged)
- `dd_countermodel_chronicle_mixed_sorry`: 1 sorry (pre-existing, unchanged)

The 2 scattered sorry sites in `succ_embed_surjective` have been consolidated into 1 sorry in `limitDomSubtype_isSuccArchimedean` with a clear mathematical description of what remains to prove.

## What Remains

The single sorry in `limitDomSubtype_isSuccArchimedean` requires proving: given `a <= b` in `LimitDomSubtype`, the succ-orbit from `a` eventually reaches or exceeds `b`. Equivalently, the succ-orbit is cofinal above any element.

Known approaches:
1. **Monotone convergence in R**: Show the succ-orbit values converge in R to a limit L, then show L must be a domain point, deriving contradiction via `pred(L) >= L` but `pred(L) < L`
2. **Omega-chain structure**: Use properties of the specific C5 counterexample construction to show the orbit cannot be bounded
3. **Pred-orbit crossing**: Show the pred-orbit of `b` must cross through the succ-orbit of `a` (using NoMinOrder + gap-free properties)

All approaches require either real analysis or structural arguments beyond pure order theory, as a "gap-at-L" configuration (two orbits converging from opposite sides with no domain point at the limit) is order-theoretically consistent.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
  - Added imports (lines 10-12)
  - Added `order_succ_eq_limitDomSubtype_succ` and `order_pred_eq_limitDomSubtype_pred` (after line 998)
  - Added `succ_orbit_convex` helper (before IsSuccArchimedean section)
  - Added `limitDomSubtype_isSuccArchimedean` with sorry (IsSuccArchimedean section)
  - Rewrote `succ_embed_surjective` proof body (replaced stage induction with IsSuccArchimedean bridge)
  - Updated section comments
