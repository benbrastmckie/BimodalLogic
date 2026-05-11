# Implementation Summary: Post-Construction Collapse from LimitDomSubtype to Z

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: Implemented
- **Session**: sess_1778515992_35a6f4

## Changes Made

### File Modified
`Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

### What Was Done

1. **Completed `collapseClass_linearOrder`** (Phase 1): Built a `LinearOrder` on `CollapseClass` (the quotient of `LimitDomSubtype` by succ-reachability). The strict order `[a] < [b]` is defined via `Quotient.lift2` as `a < b AND a is not equivalent to b`, with well-definedness from `collapse_class_sep`. The proof constructs `Preorder`, `PartialOrder`, and `LinearOrder` in sequence, using trichotomy on the underlying `LimitDomSubtype`.

2. **Replaced the quotient order pipeline with a direct embedding** (Phase 1 completion + Phase 2): The original plan required proving `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `NoMaxOrder`, and `NoMinOrder` on `CollapseClass` to obtain `CollapseClass iso Z` via `orderIsoIntOfLinearSuccPredArch`. Analysis revealed that proving `NoMaxOrder` on `CollapseClass` requires showing that succ-orbits are bounded -- a structural property deep in the omega-chain construction that is not directly accessible from the formal interface. Instead, the implementation uses a **direct embedding** `Z -> LimitDomSubtype`:
   - `embed_forward : Nat -> LimitDomSubtype` (strictly increasing, using `NoMaxOrder` on `LimitDomSubtype`)
   - `embed_backward : Nat -> LimitDomSubtype` (strictly decreasing, using `NoMinOrder` on `LimitDomSubtype`)
   - `discrete_embed : Z -> LimitDomSubtype` (combines forward/backward)
   - `discrete_embed_strictMono` (proven via case split on sign)

3. **Defined `discrete_fmcs : FMCS Z`** (Phase 2): Using the direct embedding:
   - `discrete_f(n) = limit_f(embed(n).val)` -- MCS assignment via embedding
   - `discrete_f_at_zero` -- `discrete_f(0) = A` via `limit_f_zero`
   - `discrete_f_is_mcs` -- every integer maps to an MCS via `limit_c0`
   - `forward_G` -- from `limit_forward_G` since embedding is order-preserving
   - `backward_H` -- from `limit_backward_H` since embedding is order-preserving

### What Was Removed

- `collapseClass_succOrder` (sorry) -- replaced by direct embedding
- `collapseClass_predOrder` (sorry) -- replaced by direct embedding
- `collapseClass_isSuccArchimedean` (sorry) -- replaced by direct embedding
- `collapseClass_noMaxOrder` (sorry) -- replaced by direct embedding
- `collapseClass_noMinOrder` (sorry) -- replaced by direct embedding
- `collapseClass_nonempty` -- no longer needed
- `collapse_iso` -- no longer needed
- `collapse_map` -- no longer needed
- Old `discrete_f`, `discrete_zero`, `discrete_fmcs` definitions (which depended on the removed quotient order infrastructure)

### What Was Preserved

All sorry-free collapse equivalence infrastructure is retained:
- `collapse_equiv`, `collapse_setoid`, `CollapseClass`
- `collapse_equiv_refl/symm/trans`, `collapse_equiv_succ_congr`
- `collapse_orbit_convex`, `collapse_orbit_bounded`
- `collapse_not_equiv_of_orbit`, `collapse_class_sep`
- `collapseClass_linearOrder` (newly completed)
- Helper lemmas: succ_lt, succ_iter_lt/mono/strictMono/injective, collapse_lt_trans

This infrastructure may be useful for task 122 (Until/Since coherence on Z).

### Sorry Count

- Before: 10 sorries (1 pre-existing `dd_countermodel_chronicle_nondense_sorry` + 9 new architectural stubs)
- After: 1 sorry (the pre-existing `dd_countermodel_chronicle_nondense_sorry`, out of scope for task 123)
- Net: -9 sorries

### Deviation from Plan

The plan specified proving the full quotient order infrastructure (`SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `NoMaxOrder`, `NoMinOrder`) on `CollapseClass` to obtain `CollapseClass iso Z`. Analysis showed that `NoMaxOrder` on `CollapseClass` requires proving succ-orbits are bounded, which depends on structural properties of the omega-chain construction not accessible from the formal interface. The direct embedding approach achieves the plan's stated goal ("Produce `discrete_fmcs : FMCS Z` that does NOT depend on `limitDomSubtype_Icc_finite`") with a simpler and more robust construction.

### Phases Assessment

- **Phase 1** (Collapse Equivalence + Quotient Map): COMPLETED -- equivalence relation, setoid, quotient, LinearOrder on quotient all proved. Direct embedding replaces the need for SuccOrder/PredOrder/IsSuccArchimedean/NoMaxOrder/NoMinOrder.
- **Phase 2** (FMCS on Z): COMPLETED -- `discrete_fmcs : FMCS Z` defined with all fields proved.
- **Phase 3** (Until/Since Coherence on Z): Out of scope -- overlaps with task 122 per handoff assessment.
- **Phase 4** (BFMCS on Z): Out of scope -- overlaps with task 122.
- **Phase 5** (Cleanup): COMPLETED -- old sorry-dependent pipeline removed, build passes, sorry count reduced.
