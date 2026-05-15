# Teammate B Solutions Report: Until/Since Guard Condition

**Task**: 141 -- Canonical truth lemma Until/Since
**Date**: 2026-05-14
**Focus**: Find the mathematically correct and elegant long-term solution

## Key Findings

### 1. Burgess 1982 Uses Closed-Guard Semantics; Our System Uses Open-Guard

Burgess's semantics (Section 1.2) defines:

    V(U(alpha, beta)) = {x : exists y(x < y AND y in V(alpha) AND forall z(x < z < y => z in V(beta)))}

This is **open-guard**: the guard interval is the open interval (x, y), excluding both endpoints x and y. The witness y is strict (y > x). This is EXACTLY the same as our `truth_at` definition in Truth.lean (line 127-128):

    | Formula.untl phi psi => exists s : D, t < s AND truth_at ... s phi AND
        forall r : D, t < r -> r < s -> truth_at ... r psi

**Critical observation**: Burgess's semantics and ours are IDENTICAL -- both use open guard (t, s) with strict witness s > t. The claim that "open guard" causes problems is a red herring. Burgess ALSO uses open guard and successfully proves completeness. The issue is not the guard convention; it is the **model construction**.

### 2. Burgess's Proof Succeeds Because of the Chronicle Gap-Content

Burgess's completeness proof (Section 2, Claim 2.11) works because the chronicle has TWO functions:
- `f(x)`: an MCS at time point x
- `g(x,y)`: a DCS describing what holds throughout the interval (x, y)

Property **C3**: `g(x,z) = g(x,y) intersect f(y) intersect g(y,z)` for x < y < z.
Property **C5a**: `U(xi, eta) in f(x)` implies exists y > x with `xi in f(y)` and `eta in g(x,y)`.

The truth lemma (Claim 2.11) for the case alpha = U(beta, gamma):
- If U(beta, gamma) in f(x), then by C5a there exists y with gamma in f(y) and beta in g(x,y).
- For any z with x < z < y, by C3 we have g(x,y) subset f(z), so beta in f(z).
- By induction hypothesis, z in V(gamma) and z in V(beta), giving x in V(U(beta,gamma)).

**The gap-content g is the essential structure.** Without it, the intermediate guard condition cannot be proved.

### 3. The ReflCanDomain Model Fundamentally Lacks Gap-Content

The ReflCanDomain model defines:
- `tempR_fwd x y`: g_content(x) subset y.val, where g_content(x) = {psi | G(psi) in x.val}
- `reflCanTruth` for Until: exists y with tempR_fwd x y AND psi1 in y AND forall z (tempR_fwd x z AND tempR_fwd z y => psi2 in z)

The guard condition requires: for all z between x and y, psi2 in z. But `tempR_fwd x z` only ensures g_content(x) subset z.val. Since U(psi1,psi2) is NOT a G-formula, it does not propagate through g_content. There is no mechanism to ensure psi2 at z.

**This is not a missing lemma. It is a structural inadequacy of the model.**

### 4. BX4 (connect_future) Cannot Bridge the Gap

BX4: `phi -> G(P(phi))`. This says: if phi holds now, then P(phi) holds at all future times. Even if we could extract psi2 at the current point from U(psi1,psi2) (which we cannot under open guard), BX4 would give G(P(psi2)) at x, meaning P(psi2) at intermediate z. But P(psi2) at z says "psi2 held at some past point" -- it does NOT say psi2 holds at z itself. This is useless for the guard condition.

### 5. Reynolds 1992 Does NOT Handle the Guard Differently

Reynolds Section 4 simply USES the Burgess-Xu result (Theorem 1) as a black box to get a linear-order model. Reynolds's innovation is in the SECOND stage: converting from rationals to reals via expressive completeness, Prior axioms, and the Doets theorem. The Until/Since truth lemma in Reynolds's approach comes entirely from the Burgess chronicle construction.

For integer time (Section 10), Reynolds uses Prior-UZ to enforce well-ordering, then the contemporaneous equivalence relation technique. The actual Until/Since semantics is handled by the Burgess-Xu stage.

**Reynolds's approach is NOT an alternative to Burgess for the guard condition; it DEPENDS on Burgess.**

### 6. The Removed Axioms (BX8/BX9) and Why They Cannot Be Reinstated

BX9 (`U(phi, psi) -> phi or psi`): Under Burgess's open guard, this is INVALID. Consider x with U(psi1, psi2) where the witness s is the immediate successor of x in a discrete order. The guard interval (x, s) is EMPTY, so psi2 is vacuously satisfied on the guard. But psi2 need not hold at x itself. Countermodel: let x = 0, s = 1 in Z. U(T, F)(0) is true (witness at 1, vacuous guard on empty (0,1)). But F is not true at 0. So U(T, F) -> T or F fails at 0.

BX8 (`psi -> U(phi, psi)`): Under open guard, this is ALSO invalid. It says: if psi holds now, then "phi until psi" holds. But the witness for U must be STRICTLY future, and there is no guarantee any future point satisfies phi. The reflexive witness (present point) is excluded.

These axioms are genuinely unsound. They cannot be reinstated.

## Solution Analysis

### Solution A: Add Gap-Content to ReflCanDomain (Chronicle Hybrid)

**Idea**: Extend ReflCanDomain with a gap-content function `g : ReflCanDomain -> ReflCanDomain -> Set Formula` satisfying C3 and C5 analogs. The Until truth lemma would use g(x,y) for the guard instead of tempR_fwd.

**Modified reflCanTruth for Until**:
```
| Formula.untl psi1 psi2 =>
    exists (y : ReflCanDomain), tempR_fwd x y AND reflCanTruth y psi1 AND
      psi2 in gap_content x y
```

where `gap_content x y` is the Burgess g(x,y) DCS.

**Problem**: This amounts to reimplementing the entire Burgess chronicle inside the ReflCanDomain. The ReflCanDomain would become a chronicle with extra structure, providing no benefit over the existing chronicle construction in `BXCanonical/Chronicle/`.

**Effort**: 30-50 hours (essentially rebuilding the chronicle).
**Benefit**: None over existing chronicle approach.
**Verdict**: Not recommended.

### Solution B: Redefine reflCanTruth Using the Burgess r-Relation

**Idea**: The codebase already has the Burgess `rRelation` and `burgessR` defined in `ChronicleTypes.lean`. Instead of using `tempR_fwd` for the guard, define the Until truth clause using the r-relation:

```
| Formula.untl psi1 psi2 =>
    exists (y : ReflCanDomain), burgessR x.val psi2 y.val AND
      reflCanTruth y psi1 AND
      (forall z : ReflCanDomain, rRelation x.val z.val ->
        rRelation z.val y.val -> reflCanTruth z psi2)
```

where `burgessR A beta C` means: for all gamma in C, `U(gamma, beta) in A`.

**Problem**: The r-relation is between formula SETS, not between MCS points. The guard condition via rRelation would say: for all Until formulas in x, they are either resolved or continuing in z. This is obligation propagation, not formula truth. We would need a separate truth lemma for the r-relation itself, creating circularity.

**Effort**: Very high, unclear feasibility.
**Verdict**: Not recommended.

### Solution C: Abandon ReflCanDomain Truth Lemma; Use Chronicle Pipeline

**Idea**: The existing chronicle pipeline (`BXCanonical/Chronicle/`) already handles Until/Since through C3/C5 properties. The `limit_satisfies_c5_weak` theorem (ChronicleConstruction.lean:636) proves the weak C5 for the limit. The chronicle-to-countermodel construction (`ChronicleToCountermodel.lean`) builds a TaskModel from the chronicle where the truth lemma holds by construction.

The ReflCanDomain would remain as infrastructure for frame properties (reflexivity, transitivity, S5 structure) but would NOT have its own truth lemma for Until/Since. The completeness theorem would go through the chronicle pipeline.

**Key observation from report 02**: None of the 7 WeakCanonical sorries are on the `bx_completeness` critical path. The completeness theorem already uses `dd_countermodel_chronicle_discrete` which goes through the chronicle, not through `WeakCanonical.truth_lemma`.

**Effort**: Zero implementation work needed. This is the current architecture.
**Benefit**: Already working. No new code needed.
**Verdict**: Strongly recommended as the primary path.

### Solution D: Coinductive / Game-Semantic Truth Lemma

**Idea**: Replace the inductive truth definition with a coinductive one. In a coinductive setting, the Until truth can be defined as a greatest fixed point: `U(psi1, psi2)` is true if either psi1 is true now (event), or psi2 is true now and U(psi1, psi2) remains true at the next step.

**Problem**: (1) This requires a successor relation, which the ReflCanDomain does not have; (2) coinductive proofs in Lean 4 are significantly more complex; (3) the soundness direction becomes harder; (4) this is only applicable to discrete time, not general linear orders.

**Effort**: 40+ hours with uncertain outcome.
**Verdict**: Not recommended.

### Solution E: Discrete Step-Propagation (Prior-UZ + BX5)

**Idea**: Under discrete time (Prior-UZ available), use the following argument:

Given U(psi1, psi2) in x.val, by BX5 (self-accumulation): U(psi1, psi2 AND U(psi1, psi2)) in x.val. By BX10 (until_F): F(psi1) in x.val. By Prior-UZ: U(psi1, neg(psi1)) in x.val.

Now the key insight for discrete time: if x has an immediate successor succ(x) (guaranteed by U(T, bot) = next_top), then either psi1 in succ(x) (event found) or neg(psi1) in succ(x) AND U(psi1, neg(psi1)) continues. In the latter case, the guard psi2 must hold at succ(x) because...

**The problem resurfaces**: we still need psi2 at succ(x), and U(psi1, psi2) in x.val does NOT imply psi2 at succ(x) under open guard. The guard interval (x, witness) does not include x, so the successor of x IS in the guard interval only if succ(x) < witness. But we have no way to force this.

However, there IS a viable variant: construct the witness y to be the NEAREST future psi1-point (using Prior-UZ), and show that the guard psi2 holds at all points STRICTLY between x and y. For the discrete case, this means showing psi2 at succ(x), succ(succ(x)), ..., pred(y).

**Using BX5**: U(psi1, psi2) -> U(psi1, psi2 AND U(psi1, psi2)). This says: not only psi2 holds on the guard, but U(psi1, psi2) ALSO holds on the guard. So at succ(x) (if succ(x) is in the guard interval, i.e., succ(x) < y):
- psi2 AND U(psi1, psi2) holds at succ(x)

This means U(psi1, psi2) in f(succ(x)). Iterate: at succ(succ(x)), psi2 AND U(psi1, psi2) holds. By induction up to pred(y), psi2 holds at all guard points.

**But this is exactly the chronicle argument, done point-by-point.** It requires constructing a CHAIN of MCS points from x to y, each the successor of the previous, with U(psi1, psi2) propagating via BX5 and the guard psi2 extracted at each step.

**Effort**: 15-25 hours. This requires formalizing a discrete chain construction in ReflCanDomain.
**Feasibility**: HIGH for discrete time. Requires: (1) successor/predecessor existence from next_top; (2) BX5 for Until propagation; (3) extraction of guard formula at each step.
**Verdict**: This is the most promising approach IF the ReflCanDomain truth lemma is actually needed.

### Solution F: Modify reflCanTruth to Use Chain-Based Guard

**Idea**: Instead of the current guard definition using tempR_fwd for intermediacy, define the Until clause to use a discrete chain:

```
| Formula.untl psi1 psi2 =>
    exists (y : ReflCanDomain) (chain : List ReflCanDomain),
      chain.head = some x AND chain.getLast = some y AND
      chain_adjacent chain AND  -- each pair is immediate successor
      reflCanTruth y psi1 AND
      forall z in chain.tail.dropLast, reflCanTruth z psi2
```

**Problem**: This ties the truth definition to discrete time, making the model non-general. Also, the equivalence between this chain-based semantics and the standard open-guard semantics needs to be proved separately.

**Verdict**: Not recommended (ties model to specific time structure).

## Recommended Approach

The mathematically correct and elegant solution has two components:

### Primary: Solution C (Chronicle Pipeline)

For the completeness theorem (`bx_completeness`), the chronicle pipeline is the correct approach. The Burgess chronicle construction with its gap-content function g is the mathematically natural structure for handling Until/Since. This is already implemented and working (modulo some sorries in the chronicle pipeline itself, which are separate from the ReflCanDomain sorries).

The ReflCanDomain truth lemma for Until/Since should be marked as **architecturally unnecessary** for the completeness theorem. The 6 TruthLemma.lean sorries and the 1 ReflCanR_linear sorry should be documented as non-critical dead code.

### Secondary: Solution E (Discrete Step-Propagation) if ReflCanDomain Truth Lemma Is Needed

If for architectural reasons the ReflCanDomain truth lemma must be closed (e.g., for a future Reynolds pipeline that requires it), the discrete step-propagation approach is the only viable path:

1. **Define successor/predecessor for discrete MCS**: Using next_top (U(T, bot)) in MCS, construct `succ_mcs : ReflCanDomain -> ReflCanDomain` giving the immediate temporal successor.

2. **Prove Until chain propagation**: From U(psi1, psi2) in x.val, use BX5 to get U(psi1, psi2 AND U(psi1, psi2)) in x.val. At succ(x), either psi1 holds (event found) or psi2 AND U(psi1, psi2) holds (guard + obligation continue).

3. **Prove guard by discrete induction**: Using Prior-UZ to know psi1 is reached in finitely many steps, induct on the distance to the witness to show psi2 holds at every intermediate point.

4. **Convert chain to tempR_fwd guard**: Show that the chain points z satisfy tempR_fwd x z and tempR_fwd z y, connecting the chain argument to the existing reflCanTruth definition.

Step 4 is the trickiest: the current reflCanTruth guard uses `tempR_fwd x z AND tempR_fwd z y`, which is g_content inclusion. The chain argument gives you psi2 in z.val directly (not via tempR_fwd). You would need to show that the universal quantifier over ALL z with tempR_fwd x z AND tempR_fwd z y is satisfied, which requires showing that any such z must lie on the chain.

This reduces to proving that the forward cone from x is well-ordered under discrete time -- i.e., that `reflCanR_linear` holds (which it does, from BX11).

## Implementation Feasibility

| Solution | Effort | Feasibility | Impact on bx_completeness |
|----------|--------|-------------|---------------------------|
| A (Gap-Content Hybrid) | 30-50h | High | None (redundant with chronicle) |
| B (r-Relation Truth) | Unknown | Low | None |
| C (Chronicle Pipeline) | 0h | Already done | Direct (existing architecture) |
| D (Coinductive) | 40+h | Low | None |
| E (Discrete Step) | 15-25h | High (discrete only) | None (unless Reynolds needs it) |
| F (Chain Guard) | 20-30h | Medium | None |

## Confidence Level

- **Finding that the guard condition is structurally impossible in ReflCanDomain**: HIGH (95%). Confirmed by analysis of g_content semantics, BX4/BX5/BX13 axioms, and comparison with Burgess's chronicle.

- **Finding that the 7 sorries are not on bx_completeness critical path**: HIGH (95%). Verified by tracing the dependency chain from `bx_completeness` through `doets_countermodel_discrete` to `dd_countermodel_chronicle_discrete`.

- **Recommendation for Solution C**: HIGH (90%). This is architecturally sound and already working.

- **Feasibility of Solution E if needed**: MEDIUM (70%). The discrete step-propagation is mathematically correct but the formalization details (especially step 4, connecting chain to tempR_fwd) could reveal unexpected complications.

## Literature Proof Structure

**Source**: Burgess 1982, Section 2 (Completeness Proof)
**Strategy**: Chronicle construction with iterative counterexample elimination

### Step Map

1. Define chronicle (f, g) satisfying C0-C3 -- Section 2 (conditions C0-C3)
2. Lemma 2.4: Existence of witnesses for Until obligations -- builds C, B from enriched seed
3. Lemma 2.5: Interval intersection (C3 conservation) -- R-maximality
4. Lemma 2.6: Point splitting for C4 counterexample elimination
5. Lemma 2.7: Until obligation splitting using BX5+BX7 (A5a+A7a)
6. Lemma 2.8: Variant of 2.7 for continuing obligations
7. Lemma 2.9: C4 counterexample elimination (one point insertion)
8. Lemma 2.10: C5 counterexample elimination (one point insertion)
9. Omega-chain construction: iterate 2.9/2.10 to eliminate all counterexamples
10. Claim 2.11: Truth lemma for the limit chronicle

### Dependencies
- Step 2 depends on BX13 (A3a, enrichment_until)
- Steps 5-6 depend on BX5 (A5a), BX7 (A7a), BX4 (A4a optional)
- Steps 7-8 depend on Steps 2-6
- Step 9 depends on Step 7 (also Step 4 for base case)
- Step 10 depends on Steps 2, 7, 8
- Step 11 depends on Steps 9, 10 (existence of witnesses + absence of counterexamples)

### Potential Formalization Challenges

- **Step 2 (Lemma 2.4)**: Proving the enriched seed C0 = {gamma} union {S(alpha, beta) : alpha in A} is consistent. ALREADY DONE in `ChronicleTypes.lean` and `RRelation.lean` using BX13 (enrichment_until).

- **Steps 7-8 (Lemmas 2.7-2.8)**: The BX7 (linearity) three-way case split. ALREADY DONE in `RRelation.lean`.

- **Step 9 (Lemma 2.9)**: Induction on the number of domain points between x and y. ALREADY DONE in `ChronicleConstruction.lean` (omega_chain construction).

- **Step 10 (Claim 2.11)**: The gap between `limit_satisfies_c5_weak` (weak C5: eta in f(y)) and full C5 (eta in g(x,y)). The full guard condition through g(x,y) is the SAME structural issue we face in ReflCanDomain -- but in the chronicle, it is resolved by the C3 property of g. Currently the chronicle has `limit_satisfies_c5_weak` but the full version with g-content is handled during the countermodel conversion.
