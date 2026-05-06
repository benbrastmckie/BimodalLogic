# Handoff: Forward Until Coherence (FUC) Deep Analysis

Session: sess_1778014444_dca927

## Summary

Performed deep mathematical analysis of the 2 remaining sorries at ChronicleToCountermodel.lean lines 634 and 638. These require "Forward Until Coherence" (FUC): proving that `untl(phi, psi) in limit_f(x)` implies existence of a witness y with `psi in limit_f(y)` AND the guard `phi in limit_f(z)` at all intermediate points z between x and y.

The endpoint witness (`limit_satisfies_c5_weak`) is already proven. Only the GUARD at intermediate points is missing.

## The Exact Sorry Goals

### FUC (line 634):
```
Given: h_until : phi.untl psi in (rooted_cantor_fmcs N h_N h_nubr3 s).mcs t
Goal:  exists s1, t < s1 /\ psi in mcs(s1) /\ forall r, t < r -> r < s1 -> phi in mcs(r)
```

### FSC (line 638):
Mirror for Since.

Both translate to the limit level as:
```
untl(phi, psi) in limit_f(x) ->
  exists y in limit_dom, x < y /\ psi in limit_f(y) /\ phi in limit_g(x, y)
```
where `limit_g(x,y) = {a | forall z in limit_dom, x < z -> z < y -> a in limit_f(z)}`.

## Approaches Analyzed and Why They Fail

### Approach 1: Strengthen EliminationResult (User's Suggested Approach)

**Idea**: Add guard condition to `c5_forward_witness` field of `EliminationResult`.

**Finding**: Does NOT work because the guard `phi in val.f(z)` at intermediate finite-domain points is NOT guaranteed by the C5 elimination.

Specifically, in "Walk Case A" (u_max = max_old, lemma_2_4 used): the interval set B = g(max_old, y) from lemma_2_4 does NOT necessarily contain the guard phi. The BurgessR3Maximal set B satisfies `burgessR(f(x), B, f(y))`, which requires `untl(beta, gamma) in f(x)` for all beta in B, gamma in f(y). For phi to be in B, we'd need `untl(phi, gamma) in f(x)` for ALL gamma in f(y), which is much stronger than just `untl(phi, psi) in f(x)`.

So the guard formula phi is NOT in the finite-stage g-value, and therefore NOT propagated to intermediate limit points.

### Approach 2: Prove at Limit Level from Axioms

**Idea**: Use BX axioms + backward coherence + C5_weak + density to derive forward coherence.

**Finding**: Under OPEN guard (irreflexive) Until semantics, `untl(phi, psi) in f(z)` does NOT imply `phi in f(z)`. The guard is only at points STRICTLY between z and the witness, not at z itself.

Consequence: even if `untl(phi,psi)` propagates to intermediate points (e.g., via g-value propagation), we cannot extract phi from it.

BX5 self-accumulation gives `untl(phi /\ untl(phi,psi), psi) in f(x)`, strengthening the guard to include the Until formula itself. But the same extraction problem remains.

BX7 linearity was explored to constrain witnesses. With `untl(phi,psi) /\ F(psi)`, we get `untl(phi, psi) \/ untl(phi, phi /\ psi)`. The second disjunct gives witnesses with phi at the endpoint, but not at intermediate points.

### Approach 3: Contraposition via C4

**Idea**: Use contrapositive of C4 (limit_satisfies_c4) to derive forward coherence.

**Finding**: C4 contrapositive gives backward coherence (already proven). Forward coherence is the OTHER direction and does not follow from C4.

### Approach 4: Infimum/Closest Witness

**Idea**: Among all witnesses y with psi in limit_f(y), find the closest to x. Between x and this closest y, the guard might hold.

**Finding**: The limit domain is countable dense in Q. There is no guarantee that the set of witnesses has an infimum in limit_dom, or that psi holds at the infimum.

## Root Cause

The fundamental issue is that the Burgess construction, as formalized, does NOT ensure that the guard formula phi ends up in the interval g-value g(x, y) at the finite stage when the C5 counterexample is eliminated. The existing `lemma_2_4` creates a BurgessR3Maximal interval that contains `g_content(f(x)) = {a | G(a) in f(x)}`, but NOT phi (unless `G(phi) in f(x)`, which is not guaranteed by `untl(phi, psi) in f(x)`).

Under CLOSED guard (reflexive Until), `U(phi,psi)` at z implies phi at z, so the guard automatically holds at intermediate points that inherit the Until formula. But under OPEN guard (our system), this fails.

## Promising Direction

The correct approach requires modifying the C5 elimination procedure so that the GUARD formula phi (or something implying phi) is placed in the interval g-value. This requires changing lemma_2_4 or creating a new lemma that produces:

```
exists B C, MCS(C) /\ psi in C /\ phi in B /\ BurgessR3Maximal(A, B, C)
```

where phi is the guard and psi is the event, given `untl(phi, psi) in A`.

The key question: is `{psi} union {phi} union g_content(A)` consistent when `untl(phi, psi) in A`?

If so, we can extend the seed to include phi, getting phi in the Lindenbaum extension C, and then phi might end up in B via BurgessR3Maximal construction.

Alternatively, one could try to prove `burgessR(A, phi, C)` (i.e., for all gamma in C: `untl(phi, gamma) in A`) holds when C extends {psi} union g_content(A). This requires `untl(phi, gamma) in A` for all gamma in C, which is a very strong condition.

A third option: use a completely different witness construction that ensures phi is in the interval. For example, construct a witness y such that f(y) contains BOTH psi AND phi (event and guard). Then the interval g(x, y) might contain phi due to the BurgessR3Maximal maximality. The formula `untl(phi, phi /\ psi)` gives witnesses with both, but this formula is NOT deducible from `untl(phi, psi)` under open guard semantics.

## Concrete Next Steps

1. **Investigate seed enrichment**: Check if `{psi, phi} union g_content(A)` is consistent when `untl(phi, psi) in A`. If so, create a `lemma_2_4_with_guard` that uses this enriched seed.

2. **Investigate burgessR(A, phi, C)**: Try to prove that for the specific C from lemma_2_4, `burgessR(A, phi, C)` holds. This would imply phi in B by BurgessR3Maximal maximality.

3. **Alternative: Modify h_actual check**: The `h_actual` condition in `eliminate_potential_counterexample` checks for the full guard in the CURRENT domain. When h_actual is false, the guard (including `untl(phi,psi)`) holds at intermediate points. If `untl(phi,psi)` can be shown to propagate through g-values to new points, and if the open-guard extraction can be handled at the LIMIT level via density, this might close the gap.

4. **Alternative: BX axiom approach with density**: In a dense order, between x and ANY y > x, there exists z with x < z < y. If we can show `untl(phi, psi) in limit_f(z)` for z close to x (via g-value propagation), and then use C5_weak at z to find y' with psi in limit_f(y') and y' < y, we might iteratively narrow the interval. But this risks infinite descent.

## Key Files

- `ChronicleToCountermodel.lean` lines 622-638: the sorry sites
- `CounterexampleElimination.lean` lines 602-617: EliminationResult type
- `CounterexampleElimination.lean` lines 640-1314: C5 forward elimination
- `PointInsertion.lean` line 158: lemma_2_4
- `PointInsertion.lean` line 3616: lemma_2_7 (DOES put xi in B')
- `ChronicleConstruction.lean` lines 590-608: limit_satisfies_c5_weak
- `ChronicleConstruction.lean` lines 845-849: limit_g definition
- `Axioms.lean`: BX axiom system (BX5, BX6, BX7 most relevant)
- `Bundle/WitnessSeed.lean` line 50: forward_temporal_witness_seed definition
