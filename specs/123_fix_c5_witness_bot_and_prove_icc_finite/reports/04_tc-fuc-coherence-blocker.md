# TC/FUC Coherence Blocker Analysis

**Task**: 123 (fix C5 witness bot and prove Icc finite)
**Date**: 2026-05-11
**Focus**: Why TC and FUC have sorries, whether IsSuccArchimedean holds, and viable proof strategies

## Current State

File: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

| Coherence | Theorem | Line | Status |
|-----------|---------|------|--------|
| BUC (backward Until/Since) | `cantor_bfmcs_discrete_restricted_buc` | 2130 | sorry-free |
| TC (temporal) | `cantor_bfmcs_discrete_restricted_tc` | 2207 | **sorry** (line 2212) |
| FUC (forward Until/Since) | `cantor_bfmcs_discrete_restricted_fuc` | 2221 | **sorry** (line 2224) |

## Why BUC Works But TC/FUC Do Not

**BUC** proves the backward direction: given a semantic Until witness `(u, guard)`, derive `U(phi,psi) in fam.mcs(t)`. The proof is by contradiction: assume `neg(U(phi,psi)) in fam.mcs(t)`, use `limit_satisfies_c4` to find a guard-failing point `z` between `succ_embed(t+offset)` and `succ_embed(u+offset)`. Since BOTH endpoints are embedded points, `succ_embed_squeeze_strict` maps `z` back to an integer. Contradiction follows.

**TC and FUC** prove the forward direction: given `F(phi) in fam.mcs(t)` (TC) or `U(phi,psi) in fam.mcs(t)` (FUC), PRODUCE a witness integer `s > t`. The witness comes from `limit_F_resolution` (TC) or `limit_satisfies_c5_strong` (FUC), returning a domain point `y in limit_dom`. The problem: `y` might not be in the image of `succ_embed`, so there may be no integer `s` with `succ_embed(s + offset) = y`.

**Root cause**: BUC has both endpoints as embedded points (the integer hypotheses `t` and `u` provide them). TC/FUC have only the lower endpoint (integer `t`); the upper endpoint comes from the C5/F-resolution witness in `limit_dom`, which is not guaranteed to be an embedded point.

## The Surjectivity Question

### Does `succ_embed` cover all of `LimitDomSubtype`?

If `succ_embed : Z -> LimitDomSubtype` is surjective, then every C5 witness `y` maps back to an integer, and TC/FUC follow the same pattern as the dense case.

**Existing infrastructure**: `succ_embed_squeeze` (line 1880) proves that any domain point between `succ_embed(a)` and `succ_embed(b)` is itself `succ_embed(k)` for some `a <= k <= b`. So surjectivity reduces to COFINALITY: every domain point is bounded above and below by embedded points.

### Is the orbit cofinal?

The orbit `{succ_embed(n) : n >= 0}` is a strictly increasing sequence in `LimitDomSubtype` (a subset of Q). There are two possibilities:

1. **Cofinal** (unbounded above): for any `w in LimitDomSubtype`, there exists `n` with `succ_embed(n) > w`. Combined with the symmetric argument for negative `n`, every domain point is between two embedded points, and `succ_embed_squeeze` gives surjectivity.

2. **Not cofinal** (bounded above): the orbit converges to some real number `L`, and there exist domain points above `L`. These points would not be reachable by succ-iteration from 0.

### Why cofinality is plausible but hard to prove

**For cofinality**: One can show that if `w` is a domain point above the entire orbit, then `pred(w)` must also be above the orbit (otherwise `w = succ(pred(w)) = succ(succ_embed(k)) = succ_embed(k+1)`, contradiction). This gives an infinite descending chain above the orbit. The chain and orbit both converge (in R) and the no-gap property creates tension: for large `n` and `k`, `succ_embed(n)` and `pred^k(w)` are very close, yet no domain points can exist strictly between consecutive embedded points. If the two limits coincide, the chain members would need to sit between consecutive embedded points, violating no-gap. But if the limits differ, there could be a genuine gap in the domain with no domain points in the interval.

**Against easy proof**: The omega chain construction is noncomputable (using `Classical.choose` for fresh rationals). The positions of new domain points depend on the global enumeration of counterexamples. A formal proof of cofinality would require reasoning about the stage-by-stage structure of the omega chain, showing that the succ-orbit grows fast enough to dominate all other additions. This is deep and would likely require 200+ lines of new infrastructure.

### Alternative: IsSuccArchimedean

`IsSuccArchimedean` on `LimitDomSubtype` means: for any `a < b`, there exists `n` with `succ^n(a) >= b`. This is EQUIVALENT to saying there is a single succ-orbit (every pair of points is connected by finitely many succ steps). As discussed, this is exactly the surjectivity/cofinality question. The file comments (lines 1054-1064) explicitly note that this is problematic due to omega-chain convergence.

## Viable Proof Strategies

### Strategy A: Prove succ_embed surjectivity via no-gap + cofinality

**Approach**: Prove `succ_embed_cofinal_above` and `succ_embed_cofinal_below`, then derive surjectivity from `succ_embed_squeeze`.

**Cofinality proof sketch**: For any domain point `w`, suppose `w > succ_embed(n)` for all `n >= 0`. Then `pred(w)` satisfies: if `succ_embed(n_0) >= pred(w)` for any `n_0`, then `pred(w) <= succ_embed(n_0) < w`, and by discreteness (no points between pred(w) and w), `succ_embed(n_0) = pred(w)`, hence `w = succ_embed(n_0 + 1)`, contradiction. So `pred(w)` is also above all orbit members. Infinite descent gives a decreasing chain, all above the orbit, converging to the same limit as the orbit. The no-gap property then forces a contradiction: for large enough indices, chain members fall between consecutive embedded points, which is impossible.

**Gap in the sketch**: The final step ("chain members fall between consecutive embedded points") requires that the orbit gaps `succ_embed(n+1).val - succ_embed(n).val` eventually become small enough that the chain members cannot avoid them. This is plausible when both sequences converge to the same limit, but formalizing it requires careful analysis of the interaction between the two convergent sequences in a discrete suborder of Q. It may also require showing the two limits coincide.

**Estimated effort**: 150-300 lines, HIGH difficulty, risk of getting stuck on the convergence argument.

### Strategy B: Enriched C5 guard stepping (avoid surjectivity)

**Approach**: For TC, instead of mapping a single C5 witness back to Z, use BX5 self-accumulation to step through embedded points one at a time.

1. `F(phi) in limit_f(succ_embed(t+offset))` gives `U(phi, T) in limit_f(succ_embed(t+offset))` by BX12.
2. BX5 self-accumulation: `U(phi, T) -> U(phi, T /\ U(phi, T))`.
3. `limit_satisfies_c5_strong` for the enriched formula gives witness `y` with guard: `T /\ U(phi, T) in limit_f(w)` for all domain points `w` between `succ_embed(t+offset)` and `y`.
4. At `succ_embed(t+offset+1)` (the immediate successor, which is between the source and `y`): either `phi` holds (done) or `U(phi, T)` holds (advance to next integer).

**Termination problem**: This produces `phi in fam.mcs(t+1)` or `F(phi) in fam.mcs(t+1)`. Repeating gives `phi in fam.mcs(t+k)` or `F(phi) in fam.mcs(t+k)` for all `k`. But proving termination (that `phi` eventually appears) requires showing the embedded points eventually reach or pass `y` -- which is the cofinality question again.

**Verdict**: This strategy does NOT avoid surjectivity. It just reformulates the same problem as a termination argument.

### Strategy C: Direct construction of integer witnesses

**Approach**: Instead of using `limit_F_resolution` / `limit_satisfies_c5_strong` and mapping back, construct integer witnesses directly using the BX axiom system within MCS theory.

For TC: show that `F(phi) in MCS` implies `phi in succ(MCS)` or `F(phi) in succ(MCS)`, using only MCS properties and BX derivability. This would be the discrete analog of BX8 (until_step).

**Problem**: BX8 was REMOVED (not sound under open guard semantics, line 15 of `TemporalDerived.lean`). The step-by-step unrolling `U(phi, psi) -> psi \/ (phi /\ F(U(phi, psi)))` is NOT derivable in the current axiom system. Without BX8, there is no way to unfold Until formulas one step at a time using pure BX derivability.

**Verdict**: NOT viable without re-introducing BX8 or finding an alternative derivation.

### Strategy D: Build BFMCS on LimitDomSubtype directly

**Approach**: Instead of embedding into Z, define the BFMCS with domain `LimitDomSubtype` and use the Cantor theorem for countable discrete linear orders.

**Problem**: The semantics requires `AddCommGroup D` for the domain (needed for `time_shift` in MF/TF soundness). `LimitDomSubtype` (a countable subset of Q) is not closed under addition, so it cannot carry `AddCommGroup`. The countermodel MUST live on Z (per report `03_alternative-architecture.md`).

**Verdict**: NOT viable due to AddCommGroup requirement.

### Strategy E: Prove cofinality from a bounded witness (RECOMMENDED)

**Approach**: Instead of proving global cofinality, prove a LOCAL version: when `limit_satisfies_c5_strong` produces witness `y` starting from `succ_embed(t+offset)`, there exists an embedded point above `y`.

**Key insight**: The C5 witness `y` was added at some finite stage `K` of the omega chain. At stage `K`, `y in omega_chain_val(K).dom`, which is FINITE. The succ-orbit from 0, restricted to `omega_chain_val(K).dom`, covers the entire finite domain at stage `K` (since the finite domain is a discrete finite linear order starting from 0). Therefore `y` is reachable from 0 within `omega_chain_val(K).dom`. And any point reachable in the finite stage is also reachable in the limit (the succ function in the limit refines the adjacency at finite stages).

**Gap**: The succ function in the limit may differ from the adjacency in the finite stage. At stage K, `y` might be adjacent to `x`. In the limit, points inserted between `x` and `y` by later stages change the adjacency structure. So being "reachable at stage K" does not directly imply "reachable in the limit."

**Refinement**: Instead of stage-based reasoning, use the predecessor chain argument:
1. `y in LimitDomSubtype` with `y > succ_embed(t+offset)`.
2. `pred(y)` exists. If `pred(y) >= succ_embed(t+offset)`: either `pred(y) = succ_embed(k)` for some `k` (then `y = succ_embed(k+1)`, done) or `pred(y)` is also not embedded. Recurse.
3. If `pred(y) < succ_embed(t+offset)`: impossible, since `succ_embed(t+offset) < y` and `pred(y) < succ_embed(t+offset)` means there's a domain point (`succ_embed(t+offset)`) strictly between `pred(y)` and `y`, contradicting the immediate predecessor property.

Wait -- step 3 actually RESOLVES the problem! If `pred(y) < succ_embed(t+offset)`, that means `succ_embed(t+offset)` is between `pred(y)` and `y`, contradicting `pred(y)` being the immediate predecessor (no domain points between pred and y). So `pred(y) >= succ_embed(t+offset)`.

Continuing: `pred(y) >= succ_embed(t+offset)`. By no-gap, if `pred(y)` is between `succ_embed(m)` and `succ_embed(m+1)` for some `m >= t+offset`, then `pred(y) = succ_embed(j)` for some `j` by squeeze (if we can establish both bounds). We know `pred(y) >= succ_embed(t+offset)`, so we have the lower bound. For the upper bound: we need `pred(y) <= succ_embed(K)` for some `K`. But this is the cofinality question again for `pred(y)`.

**However, the predecessor chain `y, pred(y), pred^2(y), ...` is FINITE in the number of steps down to `succ_embed(t+offset)`**: at step 3, I showed `pred(y) >= succ_embed(t+offset)`. So `pred(y)` is between `succ_embed(t+offset)` and `y`. Continuing: `pred^2(y) >= succ_embed(t+offset)` (by the same argument: if `pred^2(y) < succ_embed(t+offset)`, then `succ_embed(t+offset)` is between `pred^2(y)` and `pred(y)`, contradicting pred's immediacy for `pred(y)`). So the chain `y > pred(y) > pred^2(y) > ... >= succ_embed(t+offset)` is strictly decreasing and bounded below. In `LimitDomSubtype` (a discrete order), a strictly decreasing sequence bounded below must terminate.

**THIS IS THE KEY**: In a discrete linear order, there is no infinite strictly decreasing sequence bounded below. Every element has an immediate predecessor, and stepping down by pred gives a strictly decreasing sequence. If bounded below by `L`, the sequence must eventually reach `L` or terminate.

Wait -- is this actually true? In Z (the integers), yes: a decreasing sequence bounded below terminates. In Z x Z (lexicographic), NO: the sequence `(1, 0), (1, -1), (1, -2), ...` is strictly decreasing and bounded below by `(0, 0)` but infinite.

But Z x Z is NOT a discrete order with SuccOrder satisfying `succ_le_iff`. Actually, Z x Z with lexicographic order IS discrete: `(a, b)` has immediate successor `(a, b+1)` and immediate predecessor `(a, b-1)`. The sequence `(1, 0), (1, -1), (1, -2), ...` is infinite, decreasing, and bounded below by any `(0, k)`.

So in a general discrete linear order, strictly decreasing sequences CAN be infinite even when bounded below. The well-ordering principle does NOT apply.

**Therefore, the predecessor chain argument does not immediately give finiteness.**

## Revised Recommendation

### The Core Difficulty

The TC/FUC blocker reduces to a single mathematical question: **Is the succ-orbit of 0 cofinal in `LimitDomSubtype` when `U(T,bot)` holds everywhere?**

This is equivalent to `IsSuccArchimedean` on `LimitDomSubtype`, and equivalent to surjectivity of `succ_embed`.

None of the analyzed strategies avoid this question. Strategies B and C fail for independent reasons (BX8 removed; AddCommGroup requirement). Strategy A attacks it directly but faces a difficult convergence argument. Strategy E attempts a local version but encounters the same obstacle.

### Recommended Path Forward

**Option 1 (STRONGEST): Prove succ_embed surjectivity via a construction-level argument.**

Rather than using order-theoretic reasoning on the limit domain, analyze the omega chain construction directly. The key insight to exploit: when `U(T,bot)` holds at every domain point, the C5 walk for `U(T,bot)` at point `x` adds the immediate successor of `x` in the CURRENT finite domain (with bot guard, meaning no splits). In the limit, this immediate successor relationship is preserved or refined (later insertions can only insert between `x` and the successor, but the no-gap property in the limit prevents this for the `U(T,bot)` case).

Specifically, prove: for each point `x` in `omega_chain_val(K).dom`, there exists a stage `K'` where the C5 counterexample for `U(T,bot)` at `x` is processed, adding point `y` adjacent to `x`. In the limit, the no-gap property for `U(T,bot)` ensures `y = succ(x)` or there are finitely many intermediate points (all of which are themselves reachable by succ-iteration).

This requires formalizing the interaction between the counterexample enumeration and the succ structure, which is substantial (estimated 200-400 lines) but mathematically sound.

**Option 2 (PRAGMATIC): Add `succ_embed_surjective` as a focused sorry and prove TC/FUC modulo it.**

State and sorry `succ_embed_surjective`, then complete TC and FUC proofs using it. This isolates the one remaining mathematical question and makes the three coherence conditions structurally complete. The sorry can be resolved in a follow-up task focused specifically on omega-chain analysis.

This violates the zero-debt policy but clearly delineates the mathematical blocker.

**Option 3 (ALTERNATIVE ARCHITECTURE): Abandon succ_embed, use collapse quotient.**

Build a surjection `pi : LimitDomSubtype -> Z` via the collapse quotient (equivalence classes of the collapse_equiv relation, lines 1072-1076). The quotient is already partially built. Define the FMCS on Z via representatives. Coherence then follows from the quotient structure.

This is a significant refactor (~300-500 lines, as estimated in report 03) but avoids the surjectivity question entirely: the quotient by construction collapses each orbit to a single integer, and the FMCS is well-defined on equivalence classes (all orbit members share the same formulas by forward_G/backward_H propagation within the orbit... actually, they DON'T: forward_G propagates G-formulas, not arbitrary formulas. Different orbit members can have different formulas.).

**Problem with Option 3**: The FMCS on Z via the quotient needs `f_Z(n) = limit_f(representative(n))`. But different representatives of the same equivalence class have DIFFERENT MCS values. Choosing a canonical representative is the same as choosing an embedding -- which is what `succ_embed` already does.

### Final Assessment

**The blocker is real and mathematical, not merely technical.** The question of whether `succ_embed` is surjective (equivalently, whether `LimitDomSubtype` is `IsSuccArchimedean` in the discrete case) depends on the global structure of the omega chain construction. The most promising approach is Option 1: a construction-level proof that analyzes how the omega chain adds points and shows the succ-orbit dominates.

If Option 1 proves too difficult, consider whether the countermodel construction can be restructured to avoid the issue entirely -- perhaps by building the integer FMCS directly from the MCS theory without going through the chronicle construction's limit domain.

## Key Definitions and Locations

| Item | File | Line |
|------|------|------|
| `succ_embed` | ChronicleToCountermodel.lean | 1749 |
| `succ_embed_no_gap` | ChronicleToCountermodel.lean | 1843 |
| `succ_embed_squeeze` | ChronicleToCountermodel.lean | 1880 |
| `succ_embed_squeeze_strict` | ChronicleToCountermodel.lean | 1917 |
| `cantor_bfmcs_discrete_restricted_buc` | ChronicleToCountermodel.lean | 2130 |
| `cantor_bfmcs_discrete_restricted_tc` (sorry) | ChronicleToCountermodel.lean | 2207 |
| `cantor_bfmcs_discrete_restricted_fuc` (sorry) | ChronicleToCountermodel.lean | 2221 |
| `limitDomSubtype_succ` | ChronicleToCountermodel.lean | 898 |
| `limitDomSubtype_succ_pred` | ChronicleToCountermodel.lean | 1004 |
| `limit_F_resolution` | ChronicleConstruction.lean | 689 |
| `limit_satisfies_c5_strong` | ChronicleConstruction.lean | 1440 |
| `limit_satisfies_c4` | ChronicleConstruction.lean | ~750 |
| `collapse_equiv` | ChronicleToCountermodel.lean | 1072 |
| `restricted_temporally_coherent` | TemporalCoherence.lean | 295 |
| `restricted_forward_until_since_coherent` | TemporalCoherence.lean | 535 |
| `restricted_backward_until_since_coherent` | TemporalCoherence.lean | 565 |
| BX5 (self_accum_until) | Axioms.lean | 220 |
| BX8 removal note | TemporalDerived.lean | 15 |
| BX12 (F_until_equiv) | Axioms.lean | ~270 |
