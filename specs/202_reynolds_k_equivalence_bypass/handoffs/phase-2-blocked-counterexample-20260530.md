# Phase 2 Blocked: no_gaps_faithful is FALSE (Z+Z Counterexample)

## Session
- Session ID: sess_1780118957_3a63e0
- Date: 2026-05-30
- Agent: lean-implementation-agent (plan v12)
- Phase: 2 (Reynolds Model Surgery) -- BLOCKED

## Discovery

`no_gaps_faithful : IsEmpty (Gap M.domain)` for arbitrary `PriorModelData` is **mathematically false**.

### Z+Z Counterexample

Consider Z+Z: two copies of Z (integers) glued together, where every element of the first copy is less than every element of the second copy. This is:
- A discrete linear order (SuccOrder, PredOrder)
- Without endpoints (NoMaxOrder, NoMinOrder)
- Has a Dedekind gap (the boundary between the two copies)

Assign a CONSTANT MCS `S` at every domain point. This satisfies all PriorModelData hypotheses:

1. **Prior-UZ(psi) in S for all psi**: If psi in S, then F(psi) in S (take succ(t) as witness). And U(psi, neg psi) in S (take succ(t) as witness with vacuous guard -- no points strictly between t and succ(t)). The implication F(psi) -> U(psi, neg psi) is in S. If psi not in S, then F(psi) not in S (no future point has psi), so the implication is vacuously in S (false antecedent).

2. **Prior-SZ(psi) in S for all psi**: Symmetric argument using pred(t).

3. **C5 forward for Until**: U(phi, psi) in S(t) = S gives s = succ(t) with phi in S and vacuous guard.

4. **C5 forward for Since**: Symmetric.

5. **C4 backward for Until**: neg U(phi, psi) in S and phi in S(s): if phi in S, then U(phi, psi) in S (by C5 reasoning above), so neg U(phi, psi) not in S (MCS consistency). Contradiction with hypothesis. So C4 is vacuously satisfied.

6. **C4 backward for Since**: Symmetric.

Yet Z+Z has a Dedekind gap. The gap is NON-definable: no temporal formula distinguishes the two sides (since the MCS is constant, every formula has the same truth value at every point). This is consistent with Reynolds' Theorem 5: "no definable gaps in Prior structures".

### Why Reynolds' Theorem 14 Doesn't Give IsEmpty (Gap)

Reynolds' Theorem 14 says "contemporaneous equivalence classes don't end at gaps". In Z+Z with constant MCS:
- The contemporaneous equivalence ~M (based on k-type agreement on subintervals) is trivial: all points are equivalent (every subinterval satisfies the same monadic sentences because the MCS is constant).
- The single equivalence class is the entire domain. It doesn't "end" at the gap -- it spans across it.
- Theorem 14 is trivially satisfied (the class doesn't end at any gap).

The gap still exists; Theorem 14 just says the equivalence classes don't end at gaps, not that gaps don't exist.

### Reynolds' Theorem 15

Reynolds' actual result (Theorem 15, p.130) is:
> If M is countable, discrete, without endpoints, and Prior-UZ/SZ valid, then for all k, there exists a Z-structure satisfying the same monadic sentences of quantifier depth <= k.

This is about **monadic FO equivalence** to Z, not about the domain being isomorphic to Z. Z+Z IS k-equivalent to Z for all k (both satisfy the same monadic sentences with constant predicates).

To get actual isomorphism (which would imply no gaps), one would need the Scott isomorphism theorem: countable structures that agree on all infinitary sentences are isomorphic. But this requires omega_1-saturated types, not finite k-types.

## What Was Accomplished This Session

### 1. h_fc Propagation (COMPLETED, sorry-free)

Added `h_fc : FrameClass.Discrete <= fc` parameter to:
- `chronicle_gap_contradiction` -- filled in Prior-UZ/SZ fields using theorem_in_mcs
- `succ_cofinal` -- passes h_fc through
- `limitDomSubtype_isSuccArchimedean` -- passes h_fc through
- `succ_embed_surjective` -- passes h_fc through
- `cantor_bfmcs_discrete_restricted_tc` -- passes h_fc through
- `cantor_bfmcs_discrete_restricted_fuc` -- passes h_fc through
- `dd_countermodel_chronicle_discrete` -- passes h_fc through
- `countermodel_discrete_enriched` (Completeness.lean) -- passes h_fc through
- `extract_chronicle_as_prior` (ChronicleExtraction.lean) -- already had h_fc, passed through
- `completeness_discrete` provides `le_refl _`

The `countermodel_discrete` in Transfer.lean uses `sorry` for h_fc (fc = FrameClass.Base, where Discrete <= Base is false). This preserves the existing sorry status of the Base completeness path.

**Result**: Prior-UZ/SZ sorry in chronicle_gap_contradiction is resolved. The sole remaining sorry on the critical path is `no_gaps_faithful` in ReynoldsModelSurgery.lean.

### 2. Blocker Discovery

Discovered and documented that `no_gaps_faithful` as stated is false (Z+Z counterexample).

## Remaining Sorries on Critical Path

1. **no_gaps_faithful** (ReynoldsModelSurgery.lean:315) -- FALSE as stated, needs restructuring
2. **succ_reaches_dom_N** (ChronicleToCountermodel.lean:1287, 1443) -- pre-existing, not on critical path

## Correct Path Forward

### Option A: Strengthen PriorModelData (Medium Difficulty)

Add hypotheses to PriorModelData that exclude Z+Z:
- **Countability** of the domain
- **k-type variation**: for some k, not all k-types are the same (rules out constant MCS)
- Or: the MCS assignment is "faithful" to some monadic structure in a strong sense

This would make `no_gaps_faithful` provable but requires determining the exact minimal hypotheses and verifying the chronicle satisfies them.

### Option B: Direct Chronicle Proof (Highest Confidence)

Prove `chronicle_gap_contradiction` directly using omega-chain properties:
- The limit domain is a union of finite stages
- Each stage resolves defects by adding new points
- A gap in the limit domain would mean some defect is never resolved
- Show that the omega-chain construction eventually resolves all defects that create gaps

This bypasses `no_gaps_faithful` entirely and works with the specific structure of the chronicle. Estimated 400-800 lines depending on omega-chain machinery.

### Option C: Reynolds Theorem 15 + EF Games (Most Elegant)

Formalize Reynolds' full Theorem 15 at the abstract level:
1. Define "very good" equivalence on countable discrete Prior structures
2. Prove it is contemporaneous (Lemma 17)
3. Apply Theorem 14 (no classes end at gaps)
4. Derive that all countable discrete Prior structures are "very good"
5. "Very good" implies order-isomorphic to an interval of Z (for countable structures)
6. Z-intervals have no gaps

This is the most mathematically elegant approach but requires 500-800 lines of new EF-game machinery (lexicographic sums, k-equivalence preservation, Scott-type isomorphism for countable structures).

### Recommended: Option B

Option B is the most direct and doesn't require any new abstract machinery. The key insight: the omega-chain construction at each stage n resolves all defects visible at stage n. A Dedekind gap in the limit domain would create an unresolved defect that should be caught at some finite stage.

## Build Status
- `lake build` passes with zero errors
- ReynoldsModelSurgery.lean: 1 sorry warning (no_gaps_faithful -- known false)
- ChronicleToCountermodel.lean: 2 sorry warnings (succ_reaches_dom_N pre-existing)
- Transfer.lean: 1 sorry warning (countermodel_discrete h_fc -- intentional)

## Files Modified This Session
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- h_fc propagation
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- h_fc propagation
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- sorry for h_fc in Base path
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- h_fc pass-through
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` -- blocker documentation
- `specs/202_reynolds_k_equivalence_bypass/plans/11_reynolds-model-surgery-plan.md` -- Phase 2 BLOCKED
