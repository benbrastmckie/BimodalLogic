# Phase 5B Blocker Analysis: restricted_fuc Requires Non-Empty g-Values

## Summary

Phase 5B (close restricted_fuc sorry sites at ChronicleToCountermodel.lean lines 615, 619)
is **blocked** because the FUC guard proof requires non-empty g-values, which Phase 3
has not yet populated. The omega chain's g-values are all empty
(`omega_chain_g_empty`), making the C3 interval containment approach vacuous.

## Detailed Analysis

### Goal

The FUC requires: given `untl(phi, psi) in fam.mcs(t)`, find `s > t` with
`psi in fam.mcs(s)` and `phi in fam.mcs(r)` for all `r in [t, s)`.

### Endpoint Witness (Available)

`limit_satisfies_c5_weak` provides `s > t` with `psi in limit_f(s)`. This is sorry-free.

### Guard at Intermediate Points (Unavailable)

The guard `phi in fam.mcs(r)` for `t < r < s` cannot be proved with current infrastructure.

#### Approaches Tried and Why They Fail

1. **C3 interval containment (`c3_interval_subset_point`)**: Gives `limit_g(t,s) subset limit_f(r)`.
   Since `limit_g(t,s) = empty` (all g-values empty), this gives `empty subset limit_f(r)`,
   which is vacuously true but doesn't prove `phi in limit_f(r)`.

2. **C4 contrapositive**: C4 says `neg(untl(xi,eta)) in f(x)` and `eta in f(y)` implies
   exists `z` with `xi.neg in f(z)`. This is about neg-Until, not Until. Taking the
   contrapositive gives BUC (already proved), not FUC.

3. **forward_G propagation**: `G(phi) in f(t)` implies `phi in f(r)` for `r > t`.
   But `untl(phi,psi) in f(t)` does NOT give `G(phi) in f(t)`.

4. **BX4 + forward_G**: `untl(phi,psi) in f(t)` gives `G(P(untl(phi,psi))) in f(t)`,
   so `P(untl(phi,psi)) in f(r)` for `r > t`. This says "Until held at some past point"
   but does not give `phi in f(r)` at the current point.

5. **BX5 self-accumulation**: `untl(phi,psi) -> untl(phi and untl(phi,psi), psi)`.
   The guard becomes `phi and untl(phi,psi)`, which carries Until itself. But proving
   the guard for this self-accumulated formula requires FUC for it -- circular.

6. **BX9 + contradiction**: If `phi.neg in f(r)` and `untl(phi,psi) in f(r)`, then
   BX9 gives `phi or psi in f(r)`, so `psi in f(r)`. But we don't know if
   `untl(phi,psi) in f(r)` -- Until doesn't propagate forward.

7. **until_F_expansion**: `untl(phi,psi) -> psi or (phi and F(untl(phi,psi)))`.
   Gives `F(untl(phi,psi)) in f(t)`, so `untl(phi,psi) in f(r1)` for some `r1 > t`.
   But then for guard between `t` and `r1`, same problem.

8. **Direct tracking through stages**: At the C5 elimination stage, `y` is placed
   beyond all domain points, so the guard is vacuously satisfied. At later stages,
   new points can be inserted between `t` and `y`. For density insertions, `f(z) = f(left)`,
   and `phi in f(left)` by until_guard transitively. But for C4 insertions
   (hard case uses Lindenbaum extension of `{gamma.neg} union g(w,w_next)`), the
   resulting MCS has no guarantee of containing `phi`. Similarly g_prop insertions
   use `{alpha} union g_content(f(left))`, which doesn't include `phi` unless
   `G(phi) in f(left)`.

### Root Cause

The Burgess construction uses g-values to carry guard formulas across stages.
When the C5 elimination creates a witness `y`, it sets `g(t,y)` to contain
`phi` (via burgessR3Maximal with seed from Lemma 2.4). Then C3 ensures
`g(t,y) subset f(r)` for intermediate `r`, giving `phi in f(r)`.

The current construction has `g = empty` at all stages, so this mechanism is inoperative.

### Why Phase 3 is the Prerequisite

Phase 3 ("Populate g-values via Context-Specific Seeds") is designed to:
- Make `eliminate_C5_counterexample` set `g(t,y)` to a burgessR3Maximal set containing `phi`
- Make C4 insertions include g-content in their seeds (preserving guard formulas)
- Make g_prop insertions include g-content (preserving guard formulas)
- Thread c2' (BurgessR3Maximal) through the omega chain

Without Phase 3, the g-values remain empty and the FUC guard is unprovable.

### Additional Notes

- The c2' sorries in ChronicleConstruction.lean (10 instances) are independent of this blocker.
  At the limit, c2' is vacuously true (`limit_c2'_vacuous`) because the limit domain is dense.
- `psi_imp_until` (TemporalDerived.lean line 232) has a sorry -- this is correct because
  `psi -> (phi U psi)` is NOT valid under irreflexive Until semantics.
- BX8 (until_step) was removed as unsound under half-open guard.

## Recommendation

1. Complete Phase 3 remaining tasks (g-value population through the omega chain)
2. Then revisit Phase 5B -- with non-empty g-values, the C3 approach will work as planned
3. Alternative: redesign the omega chain construction to incorporate guard formulas
   directly into Lindenbaum seeds for all elimination types (equivalent to Phase 3)
