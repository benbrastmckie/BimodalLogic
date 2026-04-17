# Teammate C: Critic - Mathematical Soundness Analysis

## Executive Summary

The quasimodel bridge approach has **fundamental structural gaps** that make the estimated 800-1200 LOC figure optimistic by at least 2x. The existing quasimodel infrastructure handles Until/Since defect discharge but does NOT handle F-defect discharge. The bridge between quasimodel chains (finite Hintikka point sequences) and the FMCS/BFMCS infrastructure (infinite Z-indexed MCS chains) requires a non-trivial translation layer. Several claims in Report 34 are either unverified or incorrect.

## Key Findings

### Finding 1: The Quasimodel Does NOT Handle F-Defects

**Critical gap.** The existing quasimodel infrastructure (Construction.lean, 887 LOC) is entirely built around Until/Since defect discharge:

- `defect_count` (line 75): Counts Until-defects only (`Formula.untl _phi psi` where `psi not in formulas`)
- `hintikka_step` (line 45): Propagates G-formulas and Until-defects, but has NO clause for F-formulas
- `HintikkaStepOracle` (line 477): Takes a target Until formula `phi U psi` and finds a chain ending with `psi`
- `hintikka_chain_exists` (line 594): Builds a finite chain discharging a SINGLE Until-defect

**There is no F-formula tracking anywhere in the quasimodel.** The claim in Report 34 that the quasimodel "handles eventuality discharge at the graph level" is misleading — it handles Until/Since eventuality discharge, which is structurally different from F-eventuality discharge.

The difference:
- **Until defect**: `phi U psi` in point, `psi` not in point. Discharged by reaching a point where `psi` appears. The guard `phi` holds at all intermediate points. This is a FINITE chain property.
- **F-defect**: `F(psi)` in MCS, `psi` not in MCS. Discharged by reaching a future MCS where `psi` appears. No guard condition. This requires an INFINITE chain property (the chain must eventually visit `psi`).

The quasimodel builds finite chains. F-defect discharge requires infinite chains with fairness. These are fundamentally different structures.

### Finding 2: Quasimodel-to-FMCS Bridge Is Non-Trivial

The sorry sites need `dd_fmcs : FMCS Int` — an infinite Z-indexed family of MCS with:
- `mcs : Int -> Set Formula` (each element is a maximal consistent set)
- `forward_G`: G-propagation between consecutive elements
- `backward_H`: H-propagation between consecutive elements

The quasimodel produces `HintikkaRawChain Sigma` — a finite list of `HintikkaPoint Sigma` where:
- `formulas : Finset Formula` (finite subsets of Sigma)
- `hintikka_step` between consecutive points (G-propagation within Sigma only)

**Type incompatibility**: HintikkaPoints are finite subsets of a Finset Sigma. MCS are infinite sets closed under all derivations. You cannot directly use a HintikkaPoint as an MCS element. You need Lindenbaum extension to lift each HintikkaPoint to a full MCS — but Lindenbaum extension produces OPAQUE sets via `Classical.choice`, making it impossible to guarantee F-formula preservation across extensions.

This is precisely the obstacle documented in Realization.lean lines 371-400: "G-formulas do NOT persist through the Hintikka chain" because `w_{i+1}` backing `h_{i+1}` may have `not G(chi) in w_{i+1}` even when `G(chi) in h_i`.

### Finding 3: The 8 Sorry Sites Have a Dependency Structure

The 8 sorry sites are NOT independent. Here is the dependency chain:

1. **Core sorry** (line 1413): `rr_fwd_chain_forward_F` base case (depth-0 F-defect for rr_fwd_chain)
2. **Lift to dd_fmcs** (line 1457): `dd_fmcs_forward_F` for t >= 0 case — directly calls `rr_fwd_chain_forward_F`
3. **Backward case** (line 1457 second branch): `dd_fmcs_forward_F` for t < 0 — needs to propagate F(psi) from backward chain to forward chain, then use `rr_fwd_chain_forward_F`
4. **P-dual** (line 1464): `dd_fmcs_backward_P` — symmetric sorry for P-formulas, needs `rr_bwd_chain_backward_P` (not yet written)
5. **Restricted temporal coherence** (line 1517): `dd_bfmcs_restricted_tc` — needs dd_fmcs_forward_F AND dd_fmcs_backward_P for all families
6. **Restricted backward U/S coherence** (line 1522): `dd_bfmcs_restricted_buc` — needs Until/Since backward coherence
7. **Restricted forward U/S coherence** (line 1527): `dd_bfmcs_restricted_fuc` — needs Until/Since forward coherence
8. **defect_fwd_chain_forward_F** (line 2196): The "new" defect-driven chain forward_F (multi-defect)
9. **defect_bwd_chain_backward_P** (line 2289): The "new" defect-driven chain backward_P

**Dependency graph**:
```
Line 1413 (rr_fwd_chain_forward_F base) -----> Line 1457 (dd_fmcs_forward_F)
                                                           |
Line 2196 (defect_fwd_chain_forward_F) ---X               |
                                                           v
Line 2289 (defect_bwd_chain_backward_P) ---> Line 1464 (dd_fmcs_backward_P)
                                                           |
                                                           v
                                               Line 1517 (restricted_tc)
                                                           |
Lines 1522, 1527 are INDEPENDENT of forward_F/backward_P
(they need Until/Since coherence, a different property)
```

**Key insight**: Lines 1522 and 1527 (Until/Since coherence) are the ones the quasimodel CAN help with, because the quasimodel is designed for Until/Since discharge. Lines 1413, 1457, 1464 (F/P temporal coherence) are what the quasimodel CANNOT directly help with.

### Finding 4: Until/Since Coherence (Lines 1522, 1527) vs F/P Coherence (Line 1517) Are Distinct Problems

The restricted temporal coherence (line 1517) requires:
```
forall phi in deferralClosure(root),
  F(phi) in fam.mcs(t) -> exists s > t, phi in fam.mcs(s)
```

The restricted forward Until/Since coherence (line 1527) requires:
```
forall (phi U psi) in subformulaClosure(root),
  (phi U psi) in fam.mcs(t) ->
  exists s >= t, psi in fam.mcs(s) AND forall r in [t,s), phi in fam.mcs(r)
```

These are structurally different:
- **F/P coherence**: About eventual membership of a SINGLE formula. No guard condition. The quasimodel has no mechanism for this.
- **Until/Since coherence**: About reaching a witness with a guard holding at all intermediate points. The quasimodel's `hintikka_chain_exists` is designed exactly for this — it builds a finite chain where the guard holds at interior points and the witness appears at the endpoint.

**The quasimodel bridge can likely close lines 1522 and 1527 (Until/Since coherence) but NOT line 1517 (F/P temporal coherence).** This means the hardest sorry (line 1413 / line 1517) remains open even after the bridge is built.

### Finding 5: Fairness Is Not Provable from the Quasimodel

Report 34 claims the quasimodel unfolding "visits each atom infinitely often (by the fairness property)." This is incorrect for the existing infrastructure:

- `hintikka_chain_exists` (Construction.lean:594) produces a FINITE chain
- There is no "unfolding" operation that produces an infinite chain
- There is no fairness lemma anywhere in the codebase
- The quasimodel is not a graph with cycles — it's a finite linear sequence with a termination measure (defect_count decreases)

To get fairness (every atom visited infinitely often), you would need:
1. A finite GRAPH (not chain) of Hintikka points
2. A proof that the graph is strongly connected (or at least that every node is reachable from every other node)
3. An unfolding of the graph into an infinite sequence
4. A scheduling algorithm with a fairness proof

None of this infrastructure exists. Building it from scratch is a substantial undertaking well beyond 200 LOC.

### Finding 6: Root-Scoped Constraint Compatibility

The chain must satisfy properties "restricted to root" — temporal coherence for formulas in `deferralClosure(root)`, and Until/Since coherence for formulas in `subformulaClosure(root)`.

The quasimodel uses `Sigma : Finset Formula` as its formula universe. If `Sigma = extendedDeferralClosure(phi)` (as used in `dd_countermodel`), then:
- `subformulaClosure(phi) subseteq Sigma` — Until/Since formulas are covered
- `deferralClosure(phi) subseteq Sigma` — F/P formulas are covered

However, `HintikkaPoint.locally_maximal` requires that for every formula in Sigma, either it or its negation is in the point. This means the quasimodel operates at the FULL Sigma level, not just at the subformula level. The root-scoped restriction should be compatible with the quasimodel Sigma parameter, provided `Sigma` is chosen correctly.

### Finding 7: Backward_P Symmetry

The construction is NOT trivially symmetric. The forward chain (`rr_fwd_chain`) uses `enriched_fwd_step` with `g_content` propagation. The backward chain (`rr_bwd_chain`) uses `bwd_pred` with `h_content` propagation.

The quasimodel has:
- `hintikka_chain_exists` for Until (forward direction)
- `hintikka_chain_exists_since` for Since (backward direction)

These ARE symmetric. However, the F/P problem is NOT addressed by either.

### Finding 8: Counterexample Scenario

Consider a formula universe with `F(p)`, `F(q)`, where both `p` and `q` need to eventually hold. The quasimodel can discharge `p U true` and `q U true` (trivially — since Until with `true` on the right is immediately satisfied). But `F(p)` and `F(q)` are NOT Until formulas. There is no mechanism in the quasimodel to ensure that `p` and `q` each appear at some point in an infinite chain.

More concretely: the chain `M_0, M_1, M_2, ...` where each `M_i` has `F(p) in M_i` and `not p in M_i` for all `i` is consistent — it just says "p will eventually hold" at every step without ever delivering. The quasimodel has no way to prevent this because F-defects are not part of its defect tracking.

## Recommended Approach

### What the Quasimodel Bridge CAN Do (Lines 1522, 1527)

The quasimodel CAN close the Until/Since coherence sorries (lines 1522, 1527). The approach:

1. For each Until formula `phi U psi` in `subformulaClosure(root)` and each family `fam` in the BFMCS, if `(phi U psi) in fam.mcs(t)`:
   - Use `until_elim_mcs` to get `phi in fam.mcs(t) OR psi in fam.mcs(t)`
   - If `psi in fam.mcs(t)`: witness is `s = t`
   - If `psi not in fam.mcs(t)`: need to find `s > t` with `psi in fam.mcs(s)` and guard
   - The guard + witness requires the quasimodel chain, lifted to MCS

2. The lift from HintikkaPoint to MCS is already partially built (Realization.lean has `chain_step_seed_consistent_enriched`), but the G-persistence obstacle (Realization.lean:381-390) means the lift does not produce a valid chain of BXPoints.

**Estimated effort for lines 1522/1527 only**: 400-600 LOC, with the G-persistence obstacle as the main risk.

### What the Quasimodel Bridge CANNOT Do (Lines 1413, 1457, 1464, 1517)

The F/P temporal coherence requires a fundamentally different approach. The quasimodel was not designed for F-defect discharge. Options:

1. **Extend the chain construction with F-defect tracking**: Add an F-defect count to the chain step, and prove that F-defects eventually resolve. This requires proving that the round-robin schedule visits each defect — which IS the original obstruction (Report 34, approach #7).

2. **Use the defect_fwd_chain (line 2196)**: The defect-driven chain was specifically designed for F-defect discharge. If `defect_fwd_chain_forward_F` (line 2196) can be proved, then `rr_fwd_chain_forward_F` (line 1413) can be derived from it. The single-defect case IS proved (line 2155). The multi-defect case is the remaining challenge.

3. **Restructure to avoid F/P coherence entirely**: If the truth lemma could be modified to not require `restricted_temporally_coherent` directly but instead derive F-satisfaction from Until satisfaction (since `F(psi) <-> true U psi` in standard temporal logic), then lines 1413/1457/1464/1517 could be eliminated entirely.

**Option 3 is the most promising escape hatch.** In standard temporal logic, `F(psi)` is definable as `true U psi`. If the BX axioms ensure `F(psi) <-> (neg bot) U psi`, then F-coherence follows from Until-coherence. This would reduce ALL 8 sorry sites to Until/Since coherence, which the quasimodel CAN handle.

**Critical question**: Does the BX axiom set include `F(psi) <-> (neg bot) U psi`? If so, restricted temporal coherence (line 1517) follows from restricted forward Until/Since coherence (line 1527). This would be the shortest path to closing all sorries.

### Specific Mitigations

| Gap | Mitigation | Effort |
|-----|-----------|--------|
| No F-defect in quasimodel | Check if F(psi) <-> true U psi is derivable in BX | 2-4 hours research |
| HintikkaPoint-to-MCS lift | Use existing `ChainWitnessed` + Lindenbaum | Already partially built |
| G-persistence obstacle | Accept weaker chain (no full G-propagation, only Sigma-restricted) | May require reworking dd_chain |
| Fairness for infinite chains | Not needed if Until/Since coherence suffices | N/A if F = true U psi works |
| Backward_P symmetry | Mirror of forward construction (already exists in quasimodel) | 1:1 effort ratio |

## Evidence/Examples

### Evidence 1: F(psi) <-> true U psi in BX

BX10: `(phi U psi) -> F(psi)` (proved at Construction.lean:139)
BX8: `psi -> (phi U psi)` (proved at Construction.lean:157, reflexive introduction)

So: `psi -> (neg bot U psi)` (by BX8)
And: `(neg bot U psi) -> F(psi)` (by BX10)

The reverse: `F(psi) -> (neg bot U psi)`. Is this derivable?

BX11 (temp_linearity_future): `F(phi AND F(psi)) OR F(psi AND F(phi)) OR F(phi AND psi)` when `F(phi) in M` and `F(psi) in M`.

With `phi = neg bot` (which is a theorem, so `F(neg bot)` holds): The disjunction gives us that `F(neg_bot AND psi)` holds in some case, and `neg_bot AND psi -> psi`, so `F(psi)` holds. But we already knew that.

Actually, the standard translation is:
- `F(psi) = neg(G(neg psi)) = neg(neg psi U neg psi)` ... no, that's not right either.

In LTL: `F(psi) = true U psi`. But in the BX axiom system, `Until` may have different semantics (reflexive vs irreflexive, strict vs non-strict). The BX system uses REFLEXIVE Until (BX8: `psi -> phi U psi`), so `true U psi` means "psi holds now or at some future point", which is exactly `psi OR F(psi)`.

So `true U psi <-> psi OR F(psi)`, NOT `true U psi <-> F(psi)`.

For the forward Until coherence: if `(neg bot) U psi in fam.mcs(t)`, then by Until coherence there exists `s >= t` (reflexive!) with `psi in fam.mcs(s)`. This gives us F-coherence with `<=` instead of `<`.

But `restricted_temporally_coherent` requires STRICT: `F(psi) in fam.mcs(t) -> exists s > t, psi in fam.mcs(s)`.

The reflexive Until only gives `s >= t`, which includes `s = t`. When `psi not in fam.mcs(t)` (which is consistent with `F(psi) in fam.mcs(t)`), we get `s > t` from Until coherence plus the guard property. When `psi in fam.mcs(t)`, we already have the witness.

**So the reduction F -> Until DOES work for strict forward_F, provided Until uses the reflexive semantics with the guard property.** The guard for `(neg bot) U psi` is `neg bot` (i.e., `true`), which holds trivially at all intermediate points.

### Evidence 2: The Guard Property Is Trivial for F-Reduction

For `(neg bot) U psi`:
- Guard = `neg bot` (always true in any MCS — `bot not in MCS` is proved as `P_bot_not_mem_mcs` at line 2237)
- Witness = `psi`
- Until coherence gives: exists `s >= t` with `psi in fam.mcs(s)` and `neg bot in fam.mcs(r)` for all `r in [t, s)`
- If `psi in fam.mcs(t)`: done (s = t)
- If `psi not in fam.mcs(t)`: s > t, and we have `psi in fam.mcs(s)` with s > t

**This IS the forward_F property.** So if `F(psi) -> (neg bot) U psi` is derivable in BX, then line 1517 follows from line 1527.

### Evidence 3: F(psi) -> (neg bot) U psi IS Derivable -- BX12 Exists!

**CONFIRMED**: The BX axiom set includes BX12 (`F_until_equiv`, Axioms.lean:258):

```lean
| F_until_equiv (phi : Formula) :
    Axiom ((Formula.some_future phi).imp (Formula.untl (Formula.bot.imp Formula.bot) phi))
```

This is exactly `F(phi) -> top U phi` where `top = bot -> bot = neg bot`.

And BX12' (`P_since_equiv`, Axioms.lean:263):

```lean
| P_since_equiv (phi : Formula) :
    Axiom ((Formula.some_past phi).imp (Formula.snce (Formula.bot.imp Formula.bot) phi))
```

This is exactly `P(phi) -> top S phi`.

**This means the F-to-Until reduction WORKS.** Given F(psi) in fam.mcs(t):
1. By BX12: `(top U psi) in fam.mcs(t)`
2. By Until coherence (line 1527): exists `s >= t` with `psi in fam.mcs(s)` and `top in fam.mcs(r)` for all `r in [t,s)`
3. If `psi in fam.mcs(t)`: witness s = t, done
4. If `psi not in fam.mcs(t)`: s > t, giving strict forward_F

**Conditions for this reduction**:
- `top U psi` must be in `subformulaClosure(root)` for the restricted coherence to apply
- OR the restricted coherence must be extended to cover `top U psi` for arbitrary `psi in deferralClosure(root)`

The second condition is the likely blocker: `deferralClosure(root)` contains F-formulas, but `subformulaClosure(root)` may not contain the corresponding `top U psi` formulas. The `extendedDeferralClosure` includes `untilDeferralSet` — this needs to be checked to see if it contains the necessary `top U psi` terms.

**Bottom line**: BX12/BX12' exist in the axiom set, making the F-to-Until reduction mathematically valid. The remaining question is whether the closure sets are aligned correctly for the restricted coherence lemma to apply.

## Confidence Level

**Medium-High** (65-75% success probability for closing all 8 sorries via quasimodel bridge + BX12 reduction).

**Justification**:
- The quasimodel CAN handle Until/Since coherence (lines 1522, 1527) — **HIGH confidence** (75-85%)
- BX12 (`F_until_equiv`) EXISTS in the axiom set — **CONFIRMED**
- F/P coherence reduces to Until/Since coherence via BX12/BX12' — **HIGH confidence** mathematically
- The closure set alignment (deferralClosure vs subformulaClosure) needs verification — **MEDIUM confidence** (60-70%) that alignment works out
- If closure alignment fails, the restricted coherence needs to be widened — **MEDIUM confidence** (50-60%) that this is a modest change

**Revised bottom line**: BX12/BX12' are confirmed axioms. The F-to-Until reduction is mathematically valid. The primary remaining risk is closure set alignment: does `restricted_forward_until_since_coherent` cover the `(top U psi)` formulas generated by BX12 for all `psi in deferralClosure(root)`? If `extendedDeferralClosure` includes these Until-deferral formulas (check `untilDeferralSet`), then the reduction works directly. If not, a small extension to the closure or a minor widening of the restricted coherence predicate would be needed.

**Closure alignment status (VERIFIED)**: `untilDeferralSet(phi)` only includes Until formulas from `closureWithNeg(phi)` — i.e., Until formulas that are subformulas of phi. The `top U psi` formula generated by BX12 is NOT a subformula of phi (it's a derived formula), so it is NOT in `subformulaClosure(root)`, `extendedDeferralClosure(root)`, or `untilDeferralSet(root)`.

**Consequence**: The existing `restricted_forward_until_since_coherent` (quantified over `subformulaClosure(root)`) does NOT cover `top U psi`. To make the BX12 reduction work, one of these changes is needed:

1. **Widen the restricted coherence** to cover `{top U psi : F(psi) in deferralClosure(root)}` in addition to `subformulaClosure(root)`. This is a modest change to `TemporalCoherence.lean` (~20 LOC for the definition change + ~50 LOC for re-proving the truth lemma compatibility).

2. **Extend the closure set** to include `top U psi` whenever `F(psi)` is present. This would modify `extendedDeferralClosure` to include these translated formulas (~30 LOC).

3. **Prove Until coherence for ALL Until formulas**, not just those in `subformulaClosure(root)`. If the quasimodel chain discharge works for arbitrary Until formulas (which it should, since the construction is parametric in the target formula), then the restricted coherence can be replaced with full coherence for the Until/Since component.

**Option 3 is cleanest**: prove full `forward_until_since_coherent` (not restricted) using the quasimodel, then derive restricted as a corollary. Then use BX12 to derive restricted temporal coherence from the full Until/Since coherence. This avoids modifying any existing definitions.
