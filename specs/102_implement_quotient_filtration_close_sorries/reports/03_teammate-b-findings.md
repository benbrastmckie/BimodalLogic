# Teammate B Findings: Alternative Approaches -- Literature and Novel Strategies

**Task**: 102 - Implement defect-discharge chain and close Until/Since sorries
**Angle**: Survey how standard completeness proofs handle the canonical ordering and identify novel proof strategies
**Date**: 2026-04-11
**Confidence**: Varies per finding (marked inline)

---

## Executive Summary

The fundamental problem is that `bx_le` (g_content inclusion) yields a preorder, not a total order. Standard temporal logic completeness proofs (Burgess 1982/84, Goldblatt 1992, Venema 1993) all assume or construct total orders. The project's axiom system closely follows the Burgess-Xu axiomatization and has all the necessary axioms. The missing piece is not an axiom gap but a proof-strategy gap: the standard proofs work with **individual Until formulas** and build witnesses using the seed-and-Lindenbaum technique rather than trying to establish global totality. Six viable strategies are identified, ranked by feasibility.

---

## 1. How Standard Proofs Handle the Canonical Ordering

### 1.1 Burgess 1982/84

**Confidence: HIGH**

Burgess's "Axioms for tense logic I: Since and Until" (Notre Dame J. Formal Logic, 1982) provides the axiomatization that this project follows. The Burgess-Xu system uses these axioms (matching the project's BX1-BX12):

| Burgess-Xu Axiom | Project Axiom | Formula |
|---|---|---|
| Reflexivity | BX1 (temp_t_future) | G(phi) -> phi |
| Left congruence | BX2 (left_mono_until) | G(phi -> chi) -> (phi U psi -> chi U psi) |
| Right congruence | BX3 (right_mono_until) | G(phi -> psi) -> (chi U phi -> chi U psi) |
| Interaction | BX4 (connect_future) | phi -> G(P(phi)) |
| Self-accumulation | BX5 (self_accum_until) | (phi U psi) -> ((phi & (phi U psi)) U psi) |
| Absorption | BX6 (absorb_until) | (phi U (phi & (phi U psi))) -> (phi U psi) |
| Linearity | BX7 (linear_until) | (phi U psi) & (chi U theta) -> three-way disjunction |
| Reflexive intro | BX8 (refl_intro_until) | psi -> (phi U psi) |
| Elimination | BX9 (until_elim) | (phi U psi) -> (phi v psi) |
| Eventuality | BX10 (until_F) | (phi U psi) -> F(psi) |

**Key insight**: Burgess does NOT construct a total canonical ordering globally. Instead, his completeness proof works by:
1. Building the canonical model with the g_content-based preorder (exactly as in this project).
2. Proving the truth lemma for Until by constructing **specific witnesses** for each Until formula, using the seed-and-Lindenbaum technique.
3. Using the **linearity axiom (BX7)** to ensure that whenever two Until witnesses exist, they can be related to each other -- but this is used formula-by-formula, not to establish global totality.

The canonical ordering in Burgess is the SAME preorder as `bx_le`. Totality is NOT a property of the canonical model; rather, the BX7 linearity axiom is used to derive the necessary ordering relationships for individual truth lemma cases.

### 1.2 Goldblatt 1992

**Confidence: MEDIUM**

Goldblatt's "Logics of Time and Computation" (CSLI, 1992, 2nd ed.) covers temporal logic with the Until connective. His approach uses a similar canonical model construction based on maximal consistent sets. The key difference from pure modal canonical models is the need for **eventuality resolution**: when phi U psi holds at a world w, a witness world v must be found where psi holds and phi guards all intermediate worlds.

Goldblatt's technique for this involves:
1. Using F(psi) (derived from the Until formula via the eventuality axiom) to find an initial witness v with psi in v.
2. Using the linearity axiom to ensure the guard condition: any world u between w and v must have phi.
3. The "between" relation is handled via the canonical ordering restricted to specific formulas, not via global totality.

### 1.3 Venema 1993 and Blackburn/de Rijke/Venema 2001

**Confidence: MEDIUM**

Venema's "Completeness via Completeness" (1993) and the comprehensive treatment in Blackburn/de Rijke/Venema "Modal Logic" (2001) use a different approach for dense/continuous time: **filtration and quotient models**. The idea is:
1. Start with the canonical model (which has a preorder, not a total order).
2. Quotient by an appropriate equivalence relation to collapse worlds that agree on relevant formulas.
3. Show that the quotient model is a linear order (or close enough for the truth lemma).

This is the "filtration" approach that the project has partially implemented via `SigmaOrdering.lean` and `DefectChain.lean`. However, as the plan v5 notes, this approach encountered structural obstacles (strict seed inconsistency, G-formula non-persistence through Hintikka chains).

---

## 2. Is BX3 (Until Unfolding) Derivable?

### 2.1 The Question

The removed BX3 was: `(phi U psi) -> (psi v (phi & F(phi U psi)))`.

Under reflexive semantics, this says: either psi holds now, or phi holds now AND phi U psi persists somewhere in the future.

### 2.2 Analysis

**Confidence: HIGH (derivable under reflexive G/F)**

The key observation is that under reflexive semantics for G/F:

1. **F(alpha) follows from alpha**: Since G uses reflexive ordering (>=), G(neg alpha) means neg alpha holds at all t' >= t, including t itself. So if alpha holds at t, then G(neg alpha) fails at t, meaning F(alpha) = neg G(neg alpha) holds. In other words: `alpha -> F(alpha)` is derivable from BX1.

2. **Therefore (phi U psi) -> F(phi U psi)** is derivable from BX1 alone.

3. **From BX9**: `(phi U psi) -> (phi v psi)`.

4. **Combining**: `(phi U psi) -> (phi v psi) & F(phi U psi)`.

5. **Distributing**: `(phi U psi) -> (psi & F(phi U psi)) v (phi & F(phi U psi))`.

6. **Weakening the first disjunct**: `psi & F(phi U psi) -> psi`, so we get `(phi U psi) -> psi v (phi & F(phi U psi))`.

**This IS the removed BX3.** It is derivable from BX1 + BX9 alone under reflexive semantics.

Proof sketch in Lean terms:
```
-- Step 1: phi -> F(phi) from BX1 via contrapositive
-- BX1: G(neg phi) -> neg phi
-- Contrapositive: phi -> neg G(neg phi) = F(phi)
-- This is: alpha -> F(alpha) for any alpha

-- Step 2: Apply to alpha := (phi U psi)
-- Get: (phi U psi) -> F(phi U psi)

-- Step 3: BX9 gives (phi U psi) -> (phi v psi)

-- Step 4: Combine steps 2 and 3:
-- (phi U psi) -> (phi v psi) & F(phi U psi)
-- which gives: (phi U psi) -> psi v (phi & F(phi U psi))
```

**However**: while BX3 is derivable, it is NOT directly useful for the proof strategy. The issue is not "does phi U psi unfold?" but rather "how do we construct the witness v and prove the guard condition at intermediate points u in the canonical model?"

---

## 3. The "Step Property" Question

### 3.1 What Can Be Derived

**Confidence: HIGH**

From the current axioms, we can derive several step-like properties at the MCS level:

1. **BX9 step**: `(phi U psi) -> (phi v psi)` -- at the current time, either phi or psi holds.
2. **BX10 eventuality**: `(phi U psi) -> F(psi)` -- psi holds somewhere in the future (or now).
3. **BX5 self-accumulation**: `(phi U psi) -> ((phi & phi U psi) U psi)` -- the guard carries the Until formula along.
4. **BX4 connectedness**: `phi -> G(P(phi))` -- anything true now is remembered by all future points.
5. **Derived BX3**: `(phi U psi) -> psi v (phi & F(phi U psi))` -- the standard unfolding.

### 3.2 What This Means for the Proof

The combination of BX5 + BX9 gives us the crucial property: if `phi U psi` holds at w and `psi` does not hold at w, then BOTH `phi` holds at w AND `phi U psi` persists into the future (via F(phi U psi)). Moreover, BX5 strengthens the guard: at all intermediate points, both `phi` AND `phi U psi` hold.

This is exactly what the defect-discharge chain construction needs: at each step, either psi is reached (defect discharged) or the Until formula persists with a strengthened guard.

---

## 4. Alternative "Strictly Between" Characterizations

### 4.1 The Problem with the Current Guard Condition

**Confidence: HIGH**

The current sorry signature uses:
```lean
forall u, bx_le w u -> bx_le u v & not (bx_le v u) -> phi in u
```

The condition `bx_le u v & not (bx_le v u)` means "u is strictly below v in the bx_le preorder." But as Teammate A showed, bx_le is not total, so many u values are simply incomparable with v -- they are neither <= nor >= v. Such u values satisfy `not (bx_le v u)` vacuously but also satisfy `not (bx_le u v)`, so they don't reach the guard antecedent.

**This is actually fine!** The guard condition only demands phi at points that are BOTH reachable from w (bx_le w u) AND below v (bx_le u v). Points incomparable with v are not covered.

### 4.2 Alternative: Psi-Absence Characterization

**Confidence: MEDIUM-HIGH**

Instead of using `bx_le u v & not (bx_le v u)`, we could characterize "strictly between" as:

```
bx_le w u & psi not-in u.formulas
```

This says: u is reachable from w and psi hasn't been reached yet. This avoids needing any comparison with v at all. Under reflexive Until semantics, the truth condition is:

> phi U psi holds at w iff there exists v >= w with psi in v, and for all u with w <= u and psi not-in u, phi in u.

This is semantically equivalent to the standard definition on linear orders, BUT on preorders it is STRONGER: it requires phi at ALL reachable points where psi hasn't been witnessed, not just those below v.

**Problem**: This stronger condition may not be provable from the axioms. The BX axioms are complete for linear orders, so they prove exactly what holds on linear orders. On a preorder, there may be reachable points u where psi is absent but phi U psi doesn't guarantee phi in u (because on the linear orders that validate the axioms, such u wouldn't exist).

### 4.3 Alternative: Sigma-Restricted Ordering

**Confidence: MEDIUM**

The project has already built infrastructure for this in `SigmaOrdering.lean`:

```lean
def sigma_strict (Sigma : Finset Formula) (w v : BXPoint) : Prop :=
  sigma_le Sigma w v &
  exists f, Formula.all_future f in Sigma &
    Formula.all_future f in v.formulas & f not-in w.formulas
```

This is a promising middle ground: it restricts the ordering to formulas in a finite set Sigma (typically the enriched closure of the target formula). The key properties already proved include:
- `bx_le_implies_sigma_le`: bx_le refines sigma_le
- `sigma_strict_irrefl`: irreflexivity
- `not_bx_le_of_sigma_strict`: sigma_strict blocks reverse bx_le

The idea: reformulate the guard condition using `sigma_strict` instead of `not (bx_le v u)`. Since sigma_strict implies `not (bx_le v u)`, any proof using sigma_strict would also prove the original sorry signature. But sigma_strict is potentially easier to work with because it is determined by finitely many formulas.

---

## 5. The Finite Model / Hintikka Chain Approach

### 5.1 What This Would Look Like

**Confidence: MEDIUM**

The idea: instead of proving the Frame.lean sorries directly in the full canonical model (with its infinite, non-total preorder), build a **finite linear model** and prove the Until truth lemma there.

Concretely:
1. Fix a target formula phi U psi and a BXPoint w with phi U psi in w.
2. Take Sigma = enrichedClosure(phi U psi) (finite).
3. Project w to its Sigma-signature (a HintikkaPoint).
4. Build a finite chain of HintikkaPoints h0, h1, ..., hk using defect discharge:
   - h0 = Sigma-signature of w
   - At each step, either psi enters (chain ends) or a defect is discharged
   - Chain terminates in at most |Sigma| steps
5. The chain gives a finite linear model with a total ordering (by position).
6. Lift back to BXPoints using Lindenbaum to get the witness v.

### 5.2 The Obstacle (from Plan v5 Analysis)

The plan v5 documents identify two structural obstacles with this approach:
1. **Strict seed inconsistency**: When constructing the Lindenbaum extension of the chain step, adding "strict separation" markers (to ensure bx_le doesn't hold backward) can make the seed inconsistent if the G-formulas needed fall outside Sigma.
2. **G-formula non-persistence**: Hintikka steps propagate G-formulas within Sigma, but the full bx_le ordering depends on ALL G-formulas. A chain step that is valid at the Hintikka level may not lift to a valid bx_le step at the MCS level.

### 5.3 Potential Resolution

**Confidence: LOW-MEDIUM**

The obstacles in 5.2 arise from trying to lift the Hintikka chain to establish `not (bx_le v u)` (the full reverse-ordering negation). If we instead:
- Use `sigma_strict` (Section 4.3) as the "between" condition in the sorry signatures
- Show that `sigma_strict` suffices for the truth lemma

Then the Hintikka chain approach becomes viable again because `sigma_strict` IS determined by Sigma alone and DOES persist through Hintikka steps.

**However**: changing the sorry signatures would require re-verifying that the TruthLemma.lean code still works with the modified guard condition. This is a non-trivial refactoring.

---

## 6. Reformulating the Truth Lemma

### 6.1 Equivalent Semantic Definitions of Until

**Confidence: HIGH (mathematical), MEDIUM (implementation feasibility)**

There are several equivalent characterizations of `phi U psi` on linear orders:

**(A) Standard (strict guard)**: exists s >= t such that psi(s), and for all u with t <= u < s, phi(u).

**(B) Fixed-point**: `phi U psi <-> psi v (phi & F(phi U psi))` (the standard unfolding, which is derivable as BX3 -- see Section 2).

**(C) Inductive/least fixed-point**: `phi U psi` is the least predicate X such that `psi v (phi & FX) -> X`. Equivalently: for all X, if `psi -> X` and `phi & FX -> X`, then `phi U psi -> X`.

**(D) Eventuality-with-guard**: `F(psi) & G(neg psi -> phi)` -- psi will happen, and phi holds whenever psi hasn't happened yet. This is equivalent to (A) on linear orders but NOT on preorders.

**(E) Algebraic (BX5+BX6)**: `phi U psi` is the unique fixed point of the self-accumulation/absorption pair. BX5 says `phi U psi -> (phi & phi U psi) U psi` and BX6 says `phi U (phi & phi U psi) -> phi U psi`. These two together characterize Until as a fixed point of a specific operator.

### 6.2 The "G(neg psi -> phi)" Approach

**Confidence: MEDIUM-HIGH**

The most promising reformulation for the canonical model proof is variant (D):

> phi U psi in w  iff  F(psi) in w  AND  G(neg psi -> phi) in w

On linear orders, this is equivalent to the standard definition. The forward direction is:
- F(psi): from BX10
- G(neg psi -> phi): from BX5 + BX9 + generalized temporal necessitation

If this equivalence is provable from the BX axioms (which I believe it is -- see below), then the truth lemma becomes much simpler:

- **Forward (eventuality resolution)**: We need to show exists v >= w with psi in v and phi at all u strictly between w and v. We have F(psi) in w (giving witness v) and G(neg psi -> phi) in w (giving: for all u >= w, if neg psi in u then phi in u). For u strictly between w and v: since bx_le w u, G(neg psi -> phi) in w propagates to (neg psi -> phi) in u. Since psi not-in u (it's strictly before v where psi holds -- but WAIT, we can't conclude psi not-in u from u being strictly before v on a non-total order).

**The snag**: Even with the G(neg psi -> phi) reformulation, we still need to know that psi is absent at intermediate points. On a total order, u < v and psi(v) means we can use the "first time" argument. On a preorder, we don't have this luxury.

### 6.3 The Direct BX7 Approach (Plan v5, Phase 5)

**Confidence: MEDIUM**

This is the approach recommended by plan v5. The core idea:

Given phi U psi in w with psi not-in w:
1. Get F(psi) in w (BX10), then witness v >= w with psi in v (bx_forward_witness).
2. For any u with bx_le w u, bx_le u v, not bx_le v u:
   a. BX4: phi U psi in w gives G(P(phi U psi)) in w, so P(phi U psi) in u.
   b. Get u' <= u with phi U psi in u' (from P(phi U psi) via bx_backward_witness).
   c. At u': phi U psi in u' and F(psi) in u' (need to establish F(psi) in u' -- from bx_le u' u, bx_le u v, and psi in v).
   d. Apply BX7 at u' to (phi U psi) and (top U psi):
      - top U psi in u' because F(psi) in u' plus BX12.
      - BX7 gives three-way disjunction.
   e. In each case, extract phi in u.

The challenge is step (e): showing that all three BX7 cases yield phi in u. This requires careful analysis of what the linearity axiom gives us about the relationship between the witnesses of (phi U psi) and (top U psi).

### 6.4 Novel Strategy: Proof by Contradiction with Enriched Seeds

**Confidence: MEDIUM-HIGH**

A strategy not explored in plan v5:

For `bx_until_eventuality_resolution`, instead of constructing v explicitly and then proving the guard:

1. Assume for contradiction that the conclusion fails: there is NO v >= w with psi in v where the guard holds.
2. This means: for every v >= w with psi in v, there exists some u between w and v with phi not-in u.
3. Take one such v (exists by F(psi) in w) and its "bad" u.
4. At this u: bx_le w u, bx_le u v, not bx_le v u, phi not-in u, so neg phi in u.
5. Also: P(phi U psi) in u (from BX4 + connectedness), so there exists u' <= u with phi U psi in u'.
6. BX5 self-accumulation: (phi & phi U psi) U psi in u'.
7. BX10: F(psi) in u'. BX12: top U psi in u'.
8. Apply BX7 at u' to ((phi & phi U psi) U psi) and (top U psi).
9. Analyze the three cases. In each case, the "enriched guard" (phi & phi U psi) should give us phi at u -- contradicting neg phi in u.

This approach might work because BX5's self-accumulation gives us the crucial property: at intermediate points, not only phi holds but ALSO phi U psi, which propagates the Until formula forward.

### 6.5 Novel Strategy: Backward Proof via Seed Construction

**Confidence: HIGH (for bx_until_backward)**

For `bx_until_backward`, the existing plan v5 Phase 6 sketch is sound. The key idea:

1. Assume neg(phi U psi) in w (for contradiction).
2. Build seed: {neg(phi U psi)} union g_content(w).
3. Show consistency (the negation of phi U psi is consistent with everything propagated from w into the future).
4. Extend to MCS u via Lindenbaum.
5. u satisfies: bx_le w u (from g_content(w) in seed), neg(phi U psi) in u.
6. But we also know: bx_le w v (hypothesis), psi in v (hypothesis).
7. From the guard hypothesis: if bx_le w u and bx_le u v and not bx_le v u, then phi in u.
8. The question: what is the relationship between u and v?

The challenge here is establishing the bx_le relationship between u and v. This requires the seed to include enough information to force u into the [w, v] interval. Adding h_content(v) to the seed would give bx_le u v, but then we need to show the enriched seed is consistent.

The enriched seed approach from Realization.lean (`enriched_seed_consistent_until`) has already been proven consistent. This is promising for the backward direction.

---

## 7. Strategy Rankings

| # | Strategy | Feasibility | Effort | Notes |
|---|----------|-------------|--------|-------|
| 1 | Direct BX7 at MCS level (Plan v5 Phase 5) | MEDIUM | 12-20h | Current plan. Main risk: BX7 case analysis may not close. |
| 2 | Proof by contradiction with enriched seeds (6.4) | MEDIUM-HIGH | 10-15h | Novel. Self-accumulation + BX7 may simplify case analysis. |
| 3 | Sigma-strict guard reformulation (4.3) | MEDIUM | 8-12h + refactor | Changes sorry signatures. Simplifies both forward and backward. Needs TruthLemma.lean update. |
| 4 | G(neg psi -> phi) equivalence (6.2) | MEDIUM | 15-20h | Elegant but needs same totality workaround for strict intermediates. |
| 5 | Finite chain with sigma_strict lifting (5.3) | LOW-MEDIUM | 20-30h | Combines Hintikka chains with sigma_strict. Complex but avoids the MCS gap. |
| 6 | Psi-absence characterization (4.2) | LOW | Unknown | May not be provable from BX axioms on preorders. |

**Recommended approach**: Start with Strategy 1 (plan v5, already in progress) but use the BX5 self-accumulation strengthening from Strategy 2 to simplify the BX7 case analysis. If Strategy 1 stalls at Gate D (15h), fall back to Strategy 3 (sigma-strict reformulation).

---

## 8. Key Observation: The Missing Piece is NOT Totality

**Confidence: HIGH**

The most important finding from this research is a negative result: **the proof does NOT need bx_le to be total**. Standard temporal logic completeness proofs work on preorder canonical models and use the linearity axiom (BX7) to derive ordering relationships formula-by-formula. The BX7 axiom is precisely designed to compensate for non-totality of the canonical ordering.

The sorry signatures in Frame.lean are correctly formulated for a preorder. The guard condition `bx_le w u -> bx_le u v & not (bx_le v u) -> phi in u` only requires phi at points that are both reachable from w AND strictly below v. On a non-total preorder, "strictly below v" (`bx_le u v & not (bx_le v u)`) is a narrower condition than on a total order (where it would be all u != v with bx_le u v), making the guard easier to prove.

The proof strategy should therefore focus on:
1. **Witness construction**: Use BX10 + bx_forward_witness to get v >= w with psi in v. (Already done.)
2. **Guard at specific u**: For a specific u in the interval, use BX7 + BX5 + BX4 to derive phi in u. (The hard part.)
3. **Universality**: Show the BX7 argument works for ALL such u, not just specific ones. (Requires careful axiom application.)

---

## 9. The Burgess-Xu "Interaction" Axiom (BX4)

**Confidence: HIGH**

A potentially under-utilized axiom is BX4 (connect_future): `phi -> G(P(phi))`.

This axiom says: if phi holds now, then at all future times t', P(phi) holds -- meaning there exists some past time (relative to t') where phi held. Combined with the temporal ordering being reflexive, this gives:

- If phi U psi in w, then G(P(phi U psi)) in w.
- So at any u >= w: P(phi U psi) in u.
- So there exists u' <= u with phi U psi in u'.

This is crucial because it "remembers" the Until formula at all future points reachable from w. The standard proof uses this to transfer the Until formula along the temporal ordering, enabling the BX7 linearity argument at any intermediate point.

The project already has `defect_step_connect` and `connect_future_mcs` proving this at the MCS level. The infrastructure is in place.

---

## 10. BX7 Case Analysis: Detailed Sketch

**Confidence: MEDIUM**

For the critical guard proof in `bx_until_eventuality_resolution`, here is a detailed sketch of how BX7 should be used.

**Setup**: w with phi U psi in w, psi not-in w. v >= w with psi in v. u with bx_le w u, bx_le u v, not bx_le v u. Need: phi in u.

**Step 1**: From BX4, P(phi U psi) in u. Get u' <= u with phi U psi in u'.

**Step 2**: From BX5, (phi & (phi U psi)) U psi in u'.

**Step 3**: From BX10 on phi U psi at u': F(psi) in u'. From BX12: top U psi in u'.

**Step 4**: Apply BX7 at u' to (phi & (phi U psi)) U psi and top U psi:

```
((phi & (phi U psi)) U psi) & (top U psi) ->
  ((phi & (phi U psi)) & top) U (psi & psi)     -- case (a): witnesses coincide
  v ((phi & (phi U psi)) & top) U (psi & top)    -- case (b): first witness first
  v ((phi & (phi U psi)) & top) U ((phi & (phi U psi)) & psi)  -- case (c): second witness first
```

Simplifying (since top & X = X, psi & psi = psi):
- Case (a): (phi & (phi U psi)) U psi  in u'
- Case (b): (phi & (phi U psi)) U psi  in u'
- Case (c): (phi & (phi U psi)) U ((phi & (phi U psi)) & psi)  in u'

Cases (a) and (b) give: (phi & (phi U psi)) U psi in u'. The guard of this Until is (phi & (phi U psi)), which includes phi.

Case (c): the guard is still (phi & (phi U psi)), and the witness is (phi & (phi U psi)) & psi -- which also includes phi (and psi).

**Step 5**: In all cases, we have an Until formula at u' whose guard includes phi. Since u' <= u, we need to show that u is in the guard interval of this Until formula. This requires: bx_le u' u (which we have) and u is before the psi-witness of the Until formula at u'.

**The remaining gap**: We need to show that u is NOT at or past the psi-witness of the Until formula at u'. This is where the condition `not (bx_le v u)` is needed -- if the psi-witness is at v (or beyond), and u is strictly before v, then u is in the guard interval.

This analysis suggests the proof IS feasible but requires careful tracking of which witnesses are being used and their ordering relationships.

---

## Sources

- [Burgess 1982 - Axioms for tense logic I](https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/volume-23/issue-4/Axioms-for-tense-logic-I-Since-and-until/10.1305/ndjfl/1093870149.pdf)
- [Burgess 1984 - Basic Tense Logic (Handbook)](https://link.springer.com/chapter/10.1007/978-94-009-6259-0_2)
- [Goldblatt 1992 - Logics of Time and Computation](https://web.stanford.edu/group/cslipublications/cslipublications/site/0937073946.shtml)
- [Venema 1993 - Completeness via Completeness](https://link.springer.com/chapter/10.1007/978-94-015-8242-1_12)
- [Blackburn/de Rijke/Venema 2001 - Modal Logic](https://www.cambridge.org/core/books/modal-logic/F7CDB0A265026BF05EAD1091A47FCF5B)
- [Venema - Temporal Logic (survey chapter)](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- [Gabbay/Hodkinson/Reynolds 1994 - Temporal Logic](https://global.oup.com/academic/product/temporal-logic-9780198537694)
- [Stanford Encyclopedia - Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- [Stanford Encyclopedia - Burgess-Xu System](https://plato.stanford.edu/entries/logic-temporal/burgess-xu.html)
- [Verbrugge - Completeness by construction for tense logics](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- [Xu 1988 via Stanford Encyclopedia - Axiomatic LTL variations](https://plato.stanford.edu/entries/logic-temporal/axiomatic-ltl.html)
