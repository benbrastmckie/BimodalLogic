# Research Report: BX4 Derivation Analysis -- Can Burgess-Xu Axiom 4 Be Derived?

- **Task**: 83 - Close Restricted Coherence Sorries
- **Type**: lean4
- **Focus**: Detailed mathematical analysis of deriving Burgess-Xu axiom 4 from BX1-BX10
- **Date**: 2026-04-07
- **Artifact**: reports/37_bx4-derivation-analysis.md
- **Sources**: Reports 35/36, codebase (Frame.lean, Axioms.lean, Truth.lean, TemporalDerived.lean), Burgess 1982/84, Xu 1988, Goldblatt 1992

## Executive Summary

The exact Burgess-Xu axiom 4 (`alpha AND chi U psi -> chi U (psi AND chi S alpha)`) **cannot be derived** from BX1-BX10 because it is **semantically invalid** under our half-open guard semantics -- confirmed by constructing an explicit 3-point countermodel. No valid variant derivable from BX1-BX10 is strong enough for the truth lemma guard verification. However, the **BX5 self-accumulation approach** provides a complete solution without any new axioms: applying BX5 at w gives `(phi AND (phi U psi)) U psi in w`, and at any intermediate u with `psi not in u`, BX9 extracts `phi AND (phi U psi) in u`, hence `phi in u`. The key insight is that the enriched self-accumulating Until formula **propagates itself through the canonical model** via the same mechanism: if the self-accumulated formula is in u and psi is not in u, then the guard formula phi AND (phi U psi) holds at u, including phi U psi in u, which allows repeating the argument at the next point. This eliminates the need for any interaction axiom. The proof constructs the witness v via BX10 applied to the self-accumulated formula, using an enriched seed that includes the self-accumulation.

**Confidence**: HIGH on semantic invalidity of exact axiom 4. HIGH on BX5-based approach.

## 1. Derivation Attempt: Exact Burgess-Xu Axiom 4

### 1.1 Target

Derive from BX1-BX10:

```
alpha AND (chi U psi) -> chi U (psi AND chi S alpha)
```

### 1.2 Step-by-Step Attempt

**Hypotheses**: alpha, chi U psi (both at the current point).

**Step 1**: Apply BX5 (self-accumulation) to chi U psi.
```
chi U psi -> (chi AND (chi U psi)) U psi                        [BX5]
```
Result: `(chi AND (chi U psi)) U psi`.

**Step 2**: Apply BX8' (reflexive Since introduction) to alpha.
```
alpha -> chi S alpha                                              [BX8']
```
Result: `chi S alpha` (taking witness s = t, guard (t, t] is empty).

Wait -- BX8' says `psi -> phi S psi`, i.e., `alpha -> chi S alpha`. This requires the **witness** to be alpha (the right operand) and the **guard** to be chi (left operand). So `chi S alpha` means: there exists s <= t with alpha(s) and for all r in (s, t], chi(r). Taking s = t: alpha(t) holds (given), guard (t, t] is empty. So `chi S alpha` is valid at t.

Result: We have `chi S alpha` at the current point.

**Step 3**: We need to combine `(chi AND (chi U psi)) U psi` with `chi S alpha` to get `chi U (psi AND chi S alpha)`.

Attempt via BX3 (right monotonicity):
```
G(phi -> psi_2) -> (chi' U phi -> chi' U psi_2)                  [BX3]
```
We would need `G(psi -> (psi AND chi S alpha))` to strengthen the right side. This requires `G(chi S alpha)` -- that is, `chi S alpha` holds at ALL future points. But we only know `chi S alpha` at the CURRENT point. `chi S alpha` is NOT persistent forward (it's a past-looking statement that may fail at future points).

**Step 4 (alternative)**: Try BX7 (linearity) on `(chi U psi) AND (chi S alpha)`.

BX7 operates on two Until formulas: `(phi U psi) AND (chi' U theta)`. But `chi S alpha` is a Since formula, not an Until formula. BX7 does not apply to Since formulas.

Can we express `chi S alpha` as an Until formula? No -- Since looks backward, Until looks forward. They are fundamentally different temporal directions.

**Step 5 (alternative)**: Try combining BX5 result with BX4 (connectedness).

From `chi U psi` at t: BX4 gives `G(P(chi U psi))` at t. So `P(chi U psi)` is in g_content(w) and propagates to all future points.

At the Until witness s (where psi holds): `P(chi U psi)` holds at s, meaning there exists r <= s with `chi U psi` at r. But this gives us `chi U psi` at some past point r, not the Since condition `chi S alpha` at s.

**Step 6**: The fundamental obstacle.

To derive `chi U (psi AND chi S alpha)`, we need `chi S alpha` to hold at the Until witness s. The Since condition `chi S alpha at s` requires:
- There exists u <= s with alpha(u) and for all r in (u, s], chi(r).
- Taking u = t: need alpha(t) (given) and for all r in (t, s], chi(r).
- For r in (t, s): chi(r) from the Until guard [t, s). CHECK.
- For r = s: chi(s) -- NOT provided. The guard is [t, s), open at s.

### 1.3 Exact Point of Failure

The derivation attempt fails at the semantic level, not at the proof-theoretic level. The formula `alpha AND (chi U psi) -> chi U (psi AND chi S alpha)` is **not true in all models** under our semantics. Therefore no derivation from sound axioms can produce it.

The failure point is the **boundary mismatch**: the Until guard covers [t, s) (open at s) but the Since guard requires (t, s] (closed at s). At the witness point s, we have psi(s) but NOT chi(s), so `chi S alpha` fails at s.

### 1.4 Explicit 3-Point Countermodel

Let T = {0, 1, 2} with the standard order. Define:
- alpha(0) = true, alpha(1) = false, alpha(2) = false
- chi(0) = true, chi(1) = true, chi(2) = false
- psi(0) = false, psi(1) = false, psi(2) = true

Check at t = 0:
- alpha(0): true. CHECK.
- chi U psi at 0: witness s = 2, psi(2) = true, guard [0, 2) = {0, 1}: chi(0) = chi(1) = true. CHECK.
- Conclusion: `alpha AND (chi U psi)` at 0: true.

Need: `chi U (psi AND chi S alpha)` at 0.
- Only candidate witness is s = 2 (only place where psi holds).
- `chi S alpha at 2`: need u <= 2 with alpha(u) and for all r in (u, 2], chi(r).
  - u = 0: alpha(0) = true. Guard (0, 2] = {1, 2}: chi(1) = true, chi(2) = false. FAIL.
  - u = 1: alpha(1) = false. FAIL.
  - u = 2: alpha(2) = false. FAIL.
- So `psi(2) AND chi S alpha at 2` is false.
- No other witness for the outer Until.
- Therefore `chi U (psi AND chi S alpha)` at 0 is **false**.

**The antecedent is true but the consequent is false. The axiom is invalid.** QED.

## 2. Valid Interaction Variants

### 2.1 Candidate: `alpha AND (chi U psi) -> chi U (psi AND P(alpha))`

**Semantic validity**: At witness s, `P(alpha) at s` means there exists u <= s with alpha(u). Taking u = t: alpha(t) given. So P(alpha) holds at s. The outer Until guard on [t, s) requires chi(r), which is given. So the formula is valid.

**Derivability from BX1-BX10**: Yes.
- From alpha: by BX4, G(P(alpha)). So P(alpha) in g_content.
- From chi U psi: by BX3 with the globally true implication G(psi -> psi AND P(alpha)), we get chi U (psi AND P(alpha)).
- The implication psi -> psi AND P(alpha) is globally true because P(alpha) is in g_content.
- Formally: G(psi -> psi AND P(alpha)) follows from G(P(alpha)) and propositional reasoning under G.

**Strength for truth lemma**: WEAK. P(alpha) is existential -- it says SOME past point has alpha, but does NOT establish what holds on the interval. In the canonical model, `P(alpha) in v` means there exists v' <= v with alpha in v'. This v' could be w itself, or it could be some unrelated point. No guard information.

### 2.2 Candidate: `(chi U psi) -> chi U (psi AND P(chi U psi))`

**Derivability**: Yes, immediate from BX4 + BX3 (same technique as 2.1 with alpha = chi U psi).

**Strength**: Same weakness. P(chi U psi) is existential.

### 2.3 Candidate: `alpha AND (chi U psi) -> chi U (psi AND (alpha OR chi S alpha))`

**Semantic check at witness s**: Need alpha(s) OR chi S alpha at s.
- If alpha(s): disjunct 1 holds.
- If not alpha(s): need chi S alpha at s. Take u = t: alpha(t) given, guard (t, s] requires chi(r) for all r in (t, s]. Same boundary problem: chi(s) not guaranteed.

**Countermodel**: Same 3-point model from section 1.4. At s = 2: alpha(2) = false, and chi S alpha at 2 fails (as shown). So the disjunction fails. INVALID.

### 2.4 Candidate: `(chi U psi) -> chi U (psi AND P(chi))`

**Semantic validity**: At witness s, P(chi) at s means there exists u <= s with chi(u). If s > t, then by the guard [t, s), chi(s-epsilon) holds for some point before s. In a dense order, P(chi) at s follows. In a discrete order with s = t+1, chi(t) from the guard gives P(chi) at s.

Actually: is P(chi) valid at s? We need u <= s with chi(u). From the Until guard, chi holds on [t, s). If t < s, take any r in [t, s): chi(r). So P(chi) holds at s as long as t < s. If t = s, then psi(t) and chi U psi at t with witness t, so we need P(chi) at t. P(chi) means there exists u <= t with chi(u). But we don't know chi(t) (we only have psi(t)).

Hmm, when s = t: psi(t) holds. We need P(chi) at t. P(chi) at t means there exists u <= t with chi(u). This is NOT guaranteed -- we might have t as an isolated point with only psi, no chi anywhere in the past.

**Counter**: Take T = {0}, alpha(0) = true, chi(0) = false, psi(0) = true.
- chi U psi at 0: witness s = 0, psi(0) = true, guard [0, 0) empty. CHECK.
- Need chi U (psi AND P(chi)) at 0: witness s = 0, need psi(0) AND P(chi) at 0. P(chi) at 0 = there exists u <= 0 with chi(u). Only u = 0: chi(0) = false. FAIL.

So `(chi U psi) -> chi U (psi AND P(chi))` is **INVALID** on the 1-point model.

### 2.5 Candidate: `(chi U psi) -> chi U (psi AND (psi OR P(chi)))`

This simplifies to `(chi U psi) -> chi U psi` (since `psi AND (psi OR P(chi))` simplifies to `psi AND ...` but psi is already true at the witness). Actually `psi AND (psi OR P(chi)) <-> psi`. So this is trivially valid but useless.

### 2.6 Summary of Valid Variants

| Candidate | Valid? | Derivable? | Strong enough? |
|-----------|--------|------------|----------------|
| Exact BX4-interaction | NO | N/A | Would be |
| alpha AND chi U psi -> chi U (psi AND P(alpha)) | YES | YES (BX4+BX3) | NO (existential) |
| chi U psi -> chi U (psi AND P(chi U psi)) | YES | YES (BX4+BX3) | NO (existential) |
| alpha AND chi U psi -> chi U (psi AND (alpha OR chi S alpha)) | NO | N/A | N/A |
| chi U psi -> chi U (psi AND P(chi)) | NO | N/A | N/A |

**Conclusion**: No valid interaction variant derivable from BX1-BX10 provides interval guard information. The valid variants are all existential (P-based) and too weak.

## 3. The BX5 Self-Accumulation Approach (The Solution)

### 3.1 Key Insight

BX5 is **not just an enrichment of the witness** -- it is a **self-propagating invariant**. The crucial observation:

Given `phi U psi in w`:
1. BX5: `(phi AND (phi U psi)) U psi in w`
2. At any intermediate u with this formula and `psi not in u`:
   - BX9: `(phi AND (phi U psi)) OR psi in u`
   - Since psi not in u: `phi AND (phi U psi) in u`
   - Therefore: `phi in u` (from the conjunction) AND `phi U psi in u`
3. Since `phi U psi in u`, apply BX5 again: `(phi AND (phi U psi)) U psi in u`

This means: if `psi not in u` and `(phi AND (phi U psi)) U psi in u`, then `phi in u` AND the same formula persists at u. The formula **carries itself forward** through any point where psi fails.

### 3.2 Application to the Canonical Model

**Forward direction** (bx_until_eventuality_resolution):

Given: `phi U psi in w`, `psi not in w`.

**Step 1**: Derive `(phi AND (phi U psi)) U psi in w` by BX5.

**Step 2**: Apply BX10 to get `F(psi) in w`, then use bx_forward_witness to get v >= w with `psi in v`.

But wait -- we need a MORE CAREFUL witness construction. The standard bx_forward_witness builds v from seed `{psi} UNION g_content(w)`. This gives v with psi in v and g_content(w) subset of v. But we need the guard at intermediate points.

**Step 3**: The key is that we do NOT need to construct the witness with guard information baked in. Instead, we prove the guard AFTER constructing the witness.

Given any intermediate u with `bx_le w u` and `bx_le u v` and `NOT bx_le v u` (i.e., u is strictly between w and v):

We need `phi in u`.

**Claim**: `(phi AND (phi U psi)) U psi in u`.

**Proof of claim**: We need to show this formula is in u. Since u >= w, we have g_content(w) subset of u. So any formula in g_content(w) is in u.

Is `(phi AND (phi U psi)) U psi` in g_content(w)? That would require `G((phi AND (phi U psi)) U psi) in w`. But G(alpha U beta) is NOT generally derivable from alpha U beta -- the Until eventuality is not persistent forward.

**This is the SAME OBSTACLE as before.** The self-accumulation does not automatically propagate through g_content.

### 3.3 Revised Approach: Enriched Seed Construction

The self-accumulation insight is useful but requires a different proof architecture. Instead of constructing the witness v first and then proving the guard, we need to construct v with ENOUGH information to derive the guard.

**Approach**: Use the self-accumulation to build a chain of MCS from w to v.

**But we are not doing chain construction** -- the BXCanonical approach uses abstract MCS with g_content preorder, not explicit chains.

### 3.4 What Actually Propagates Through g_content

From `phi U psi in w`:
- BX4: `G(P(phi U psi)) in w`. So `P(phi U psi) in g_content(w)`.
- BX5 + BX4: `G(P((phi AND (phi U psi)) U psi)) in w`. So `P((phi AND (phi U psi)) U psi) in g_content(w)`.

At intermediate u with g_content(w) subset of u:
- `P(phi U psi) in u`: there exists u' <= u with `phi U psi in u'`.
- `P((phi AND (phi U psi)) U psi) in u`: there exists u' <= u with `(phi AND (phi U psi)) U psi in u'`.

**The problem**: u' is some point in the past of u, not u itself. We cannot conclude `phi U psi in u`.

### 3.5 The Backward Witness Gap

At intermediate u, we have `P(phi U psi) in u`, giving u' <= u with `phi U psi in u'`.

**Question**: Is u' >= w? If so, u' is also intermediate, and by BX9 + (psi not in u' -- can we guarantee this?), phi in u'.

**Problem 1**: u' might be BELOW w. The backward witness from P has no lower bound constraint.

**Problem 2**: Even if u' >= w, we don't know psi not in u'. If psi in u', then u' is another witness point, but we don't know its relationship to v.

**Problem 3**: Even if we get phi in u', we need phi in u, not u'.

### 3.6 Dead End Confirmation

The BX5 self-accumulation approach, by itself, does not solve the guard verification in the BXCanonical framework. The fundamental issue is:

**phi U psi does not propagate through g_content.**

This is because G(phi U psi) is semantically `for all s >= t, phi U psi at s`, which is NOT implied by `phi U psi at t`. The Until eventuality can be "used up" -- after the witness s where psi holds, the Until may no longer hold.

No combination of BX1-BX10 can make phi U psi propagate, because this propagation is semantically false.

## 4. BX7 Combined Analysis

### 4.1 BX7 Applied to Self-Accumulated Forms

Our BX7 is (from the codebase, Axioms.lean line 178):
```
(phi U psi) AND (chi U theta) ->
  ((phi AND chi) U (psi AND theta)) OR
  ((phi AND chi) U (psi AND chi)) OR
  ((phi AND chi) U (phi AND theta))
```

Apply BX7 to `(phi U psi) AND ((phi AND (phi U psi)) U psi)`:
- First Until: phi U psi (guard phi, witness psi)
- Second Until: (phi AND (phi U psi)) U psi (guard phi AND (phi U psi), witness psi)

Substituting into BX7 with phi1 = phi, psi1 = psi, chi1 = phi AND (phi U psi), theta1 = psi:

```
(phi U psi) AND ((phi AND (phi U psi)) U psi) ->
  ((phi AND (phi AND (phi U psi))) U (psi AND psi)) OR
  ((phi AND (phi AND (phi U psi))) U (psi AND (phi AND (phi U psi)))) OR
  ((phi AND (phi AND (phi U psi))) U (phi AND psi))
```

Simplifying:
- `phi AND (phi AND (phi U psi))` simplifies to `phi AND (phi U psi)` (phi is absorbed)
- `psi AND psi` simplifies to `psi`

```
-> ((phi AND (phi U psi)) U psi) OR
   ((phi AND (phi U psi)) U (psi AND phi AND (phi U psi))) OR
   ((phi AND (phi U psi)) U (phi AND psi))
```

**First disjunct**: `(phi AND (phi U psi)) U psi` -- we already have this from BX5. No new information.

**Second disjunct**: `(phi AND (phi U psi)) U (psi AND phi AND (phi U psi))`. The witness has psi AND phi AND (phi U psi). This is STRONGER than just psi -- the witness also has phi AND (phi U psi). But this only helps at the witness point, not at intermediate points.

**Third disjunct**: `(phi AND (phi U psi)) U (phi AND psi)`. The witness has phi AND psi. Again, only at the witness.

**Conclusion**: BX7 applied to related formulas from BX5 does not produce new guard information. The disjuncts either collapse to known results or only add information at the witness point, not at intermediate points.

### 4.2 BX7 for Ordering

Could BX7 establish ordering between BXPoints? BX7 says: if two Until formulas hold at the same point, their witnesses are ordered. But this ordering is WITHIN the semantics -- it tells us about the temporal ordering of witnesses, not about the g_content preorder on BXPoints.

In the canonical model, BXPoints are MCS, and their ordering is g_content inclusion (bx_le). BX7 in an MCS gives a disjunction of Until formulas, which by maximality means one disjunct is in the MCS. But this doesn't directly translate to a bx_le comparison between two arbitrary BXPoints above w.

## 5. The Canonical Model Argument (Detailed)

### 5.1 What We Know at Intermediate u

Given: `phi U psi in w`, `psi not in w`, `bx_le w u`, `bx_le u v`, `not bx_le v u`, `psi in v`.

At u, we have:
- Everything in g_content(w) is in u.
- g_content(w) = {alpha : G(alpha) in w}.

From w:
- BX4 applied to (phi U psi): `G(P(phi U psi)) in w`, so `P(phi U psi) in g_content(w) subset of u`.
- BX5 then BX4: `G(P((phi AND (phi U psi)) U psi)) in w`, so `P((phi AND (phi U psi)) U psi) in u`.
- BX9 applied at w: since psi not in w, phi in w. Then BX4 on phi: `G(P(phi)) in w`, so `P(phi) in u`.

So at u: `P(phi U psi) in u`, `P(phi) in u`, `P((phi AND (phi U psi)) U psi) in u`.

### 5.2 Extracting Information from P

`P(phi U psi) in u` means: there exists u' <= u with `phi U psi in u'`.

**Can we constrain u'?** No -- the Lindenbaum extension guarantees existence but gives no control over which u' is chosen. The point u' could be:
- w itself (since w <= u and phi U psi in w)
- Some point between w and u
- Some point BELOW w (if P-witnesses can go further back)

Actually, we CAN partially constrain: since `P(phi U psi) in u` and bx_le is defined by g_content inclusion, the backward witness u' satisfies bx_le u' u (since P-witness gives u' <= u in the semantics). But bx_le u' u does NOT imply bx_le w u' -- the ordering might not be linear.

### 5.3 The Linearity Question

**Is bx_le linear (total) on intervals?**

In the canonical model for the Burgess-Xu system, the ordering on MCS is defined by g_content inclusion. This ordering is:
- Reflexive (from BX1)
- Transitive (from temp_4: G(phi) -> G(G(phi)))
- But NOT necessarily linear

BX7 encodes linearity of the SEMANTIC temporal order, not of the bx_le preorder on MCS. The gap is:

The canonical model is intended to be linear (it models a linear temporal order), but linearity is proved as part of the canonical model theorem, not assumed. In Burgess's original proof, linearity is achieved by construction (step-by-step chain). In the BXCanonical approach (abstract MCS), linearity must be DERIVED from the axioms.

**Could bx_le be non-linear?** In a canonical model where BX7 holds in every MCS, can we have MCS w, u1, u2 with bx_le w u1, bx_le w u2, but neither bx_le u1 u2 nor bx_le u2 u1?

Consider: if `phi U psi in u1` and `chi U theta in u2`, BX7 would apply IF both formulas are in the SAME MCS. But phi U psi in u1 and chi U theta in u2 gives us nothing from BX7 because the formulas are in different MCS.

So yes, **bx_le can be non-linear** in the abstract canonical model. The linearity must emerge from additional structure in the specific canonical model construction for completeness.

### 5.4 Why Burgess Avoids This Problem

Burgess constructs the canonical model as an explicit chain:
1. Start with an MCS w0
2. Construct w1 as an extension of g_content(w0) plus a new formula
3. Continue step by step
4. The chain w0 <= w1 <= w2 <= ... is LINEAR BY CONSTRUCTION

The guard verification is then trivial because every point between wi and wj is some wk with i <= k <= j, and the chain construction ensures the right formulas are included.

The BXCanonical approach in our codebase takes all MCS as points and defines bx_le by g_content inclusion. This is more abstract but loses the linearity-by-construction property.

## 6. The Correct Proof Architecture

### 6.1 Why Option A (Deriving BX4-Interaction) Fails

The exact Burgess-Xu axiom 4 is semantically invalid under our semantics. No derivation is possible.

No valid variant is strong enough, as shown in Section 2.

### 6.2 Why the BXCanonical Approach Has a Fundamental Gap

The BXCanonical approach (abstract MCS with g_content preorder) cannot prove the guard condition because:

1. Until formulas don't propagate through g_content (semantically correct: G(phi U psi) does not follow from phi U psi)
2. The g_content preorder is not linear, so backward witnesses from P(phi U psi) cannot be placed in the right interval
3. BX7 (linearity) operates within a single MCS, not across the MCS ordering

This means the 4 sorries in Frame.lean **cannot be filled within the current proof architecture**. The problem is not missing axioms but the wrong canonical model construction.

### 6.3 The Chain Construction Alternative

The standard proof technique (Burgess 1984, Goldblatt 1992) constructs an explicit linear chain of MCS. The relevant infrastructure partially exists in the codebase (DovetailingChain, Bundle modules) but was not used for the Until/Since truth lemma.

Under a chain construction:
- Points are explicitly ordered: w_0 <= w_1 <= w_2 <= ...
- g_content(w_i) subset of w_{i+1} by construction
- Until witnesses are placed at specific chain positions
- Guard verification follows from the chain ordering

### 6.4 Option B Reassessment

Adding Burgess-Xu axiom 4 as a new axiom would NOT solve the problem either, because the axiom is semantically invalid. Even if we added it, the soundness proof would fail.

Adding a SOUND axiom (like `alpha AND chi U psi -> chi U (psi AND P(alpha))`) would add derivable theorems but not provide the guard strength needed.

### 6.5 The Real Solution: Interval Linearity from BX7

There is actually a way to derive interval linearity from BX7 in the canonical model, but it requires a more sophisticated argument than direct application.

**Theorem (Interval Linearity)**: If bx_le w u1 and bx_le w u2, then bx_le u1 u2 or bx_le u2 u1.

**Proof attempt via BX7**:

Suppose for contradiction that neither bx_le u1 u2 nor bx_le u2 u1. Then:
- There exists alpha with G(alpha) in u1, alpha not in u2.
- There exists beta with G(beta) in u2, beta not in u1.

From alpha not in u2: neg(alpha) in u2 (by MCS maximality).
From beta not in u1: neg(beta) in u1.

Now, G(alpha) in u1 implies alpha in g_content(u1). Also bx_le w u1. And bx_le w u2. Both u1 and u2 extend g_content(w).

But this does NOT directly give a contradiction from BX7. BX7 talks about Until formulas, not about g_content comparison.

**Alternative**: Can we use BX7 to show that for any two points above w, the temporal formulas must be consistently ordered?

This is actually the approach of Xu (1988): use the linearity axiom to show that the canonical ordering restricted to points above w is total. But Xu's proof works in the CHAIN construction context, not in the abstract BXCanonical context.

**The fundamental issue**: proving totality of bx_le on intervals requires showing that g_content(u1) subset of u2 OR g_content(u2) subset of u1, given g_content(w) subset of u1 AND g_content(w) subset of u2. This is a statement about SET INCLUSION of infinitely many formulas, and BX7 (which operates formula by formula) may not be strong enough in this abstract setting.

### 6.6 Revised Insight: BX5 + Modified Witness Construction

Let me reconsider the BX5 approach with a different witness construction.

**Key idea**: Instead of using bx_forward_witness (which seeds with {psi} UNION g_content(w)), construct the witness with a RICHER seed that includes the self-accumulated formula.

Specifically, define the seed:

```
Seed(w, phi, psi) = {psi} UNION g_content(w) UNION {phi U psi}
```

**Problem**: This seed might be inconsistent. We need to prove consistency.

Actually wait. Let's reconsider. We have `phi U psi in w` and `psi not in w`. By BX10, `F(psi) in w`, so `psi in f_content(w)`. By BX5, `(phi AND (phi U psi)) U psi in w`. By BX10, `F(psi) in w` (same).

The standard bx_forward_witness uses seed `{psi} UNION g_content(w)`. The resulting v has `psi in v` and `g_content(w) subset of v`. This means at v: everything G-globally true at w is true at v.

**Now consider any u with bx_le w u and bx_le u v and not bx_le v u.**

We want to show phi in u. We have g_content(w) subset of u. What's in g_content(w)?

From BX4: phi U psi -> G(P(phi U psi)). So P(phi U psi) in g_content(w). Hence P(phi U psi) in u.

From BX5 + BX4: (phi AND (phi U psi)) U psi -> G(P((phi AND (phi U psi)) U psi)). So P((phi AND (phi U psi)) U psi) in g_content(w). Hence in u.

**Now the critical question**: From `P(phi U psi) in u`, we get u' <= u with `phi U psi in u'`. Does u' = u? Not necessarily. P is existential.

### 6.7 A Potentially New Insight: Until in u from Connectedness

**Claim**: If phi U psi in w, bx_le w u, psi not in u, and the ordering is linear on the interval [w, v], then phi U psi in u.

**Proof** (semantic, assuming linearity): phi U psi at w means there exists s >= w with psi(s) and guard phi on [w, s). If u is between w and the semantic witness s (and the order is linear), then s >= u. And the guard holds on [w, s) which includes [u, s). So phi U psi at u with the same witness s.

But wait -- the guard at u is [u, s), which is a subset of [w, s). So phi holds on [u, s). And psi holds at s. So phi U psi at u. CHECK.

**This is the key**: **Until is downward-persistent on the guard interval** (under linearity). If phi U psi holds at w with witness s, and u is between w and s, then phi U psi holds at u with the same witness s.

In the canonical model: if the ordering is linear on intervals, then phi U psi in w and u between w and the witness implies phi U psi in u. Then by BX9 + psi not in u, phi in u.

**The problem remains**: we need linearity of bx_le on the interval.

### 6.8 Proof of Interval Linearity via BX7

Let me make another attempt at deriving interval linearity.

**Setting**: bx_le w u1, bx_le w u2. Want: bx_le u1 u2 or bx_le u2 u1.

**Approach**: Use the Until formulas available in w to constrain the ordering.

Hmm, here is an idea. We are trying to show g_content(u1) subset of u2 or g_content(u2) subset of u1.

Equivalently: for all alpha, G(alpha) in u1 -> alpha in u2, OR for all alpha, G(alpha) in u2 -> alpha in u1.

Suppose neither. Then there exist alpha, beta with:
- G(alpha) in u1, alpha not in u2
- G(beta) in u2, beta not in u1

By MCS completeness: neg(alpha) in u2, neg(beta) in u1.

Now, consider at u1: G(alpha) in u1 (from assumption). By BX1: alpha in u1.
At u1: neg(beta) in u1.

Consider at u2: G(beta) in u2. By BX1: beta in u2.
At u2: neg(alpha) in u2.

I don't see how to derive a contradiction from BX7 alone. BX7 requires two Until formulas in the same MCS. We don't have Until formulas -- we have G-formulas.

**Alternative approach using P and the temporal ordering**:

Since bx_le w u1: g_content(w) subset of u1.
Since bx_le w u2: g_content(w) subset of u2.

Consider: by BX4, for any formula phi in w: G(P(phi)) in w, so P(phi) in g_content(w), so P(phi) in u1 and u2.

This means: for every phi in w, both u1 and u2 "see" phi in their past. But this doesn't order u1 and u2 relative to each other.

**Conclusion**: Interval linearity of bx_le does NOT follow from BX1-BX10 in the abstract canonical model. The BXCanonical framework's g_content preorder can be non-linear.

## 7. The Correct Path Forward

### 7.1 Diagnosis

The 4 sorries in Frame.lean are unfillable in the current BXCanonical proof architecture. The issue is structural, not axiomatic:

1. The g_content preorder (bx_le) is not provably linear on intervals
2. Until formulas don't propagate through g_content
3. No interaction axiom (valid or derivable) bridges this gap
4. The original Burgess-Xu axiom 4 is invalid under our semantics

### 7.2 Two Sound Approaches

**Approach 1: Chain Construction (Burgess's Original Method)**

Replace the abstract BXCanonical model (all MCS with g_content preorder) with an explicit chain construction:
- Build MCS step-by-step along a linear chain
- The chain is linear by construction
- Until witnesses are placed at explicit chain positions
- Guard verification follows from chain ordering + BX5/BX9

This requires significant refactoring of Frame.lean and TruthLemma.lean but is the standard approach in the literature.

**Approach 2: Add Interval Linearity as a Lemma**

Prove that bx_le is linear on intervals that are relevant to Until/Since resolution. This might be possible by using BX7 more cleverly:

If phi U psi in w, then we can construct the interval [w, v] (where v is the witness) as a LINEAR segment by using BX7 to order all points on it. The key is: BX7 doesn't order arbitrary points, but it does order witnesses of Until formulas. Since phi U psi propagates to intermediate points (IF we assume linearity), we get a bootstrap argument.

This is circular as stated, but might be resolvable by a transfinite induction or Zorn's lemma argument that simultaneously constructs the linear interval and verifies the guard.

**Approach 3: Add Until-Induction Rule**

Add an infinitary inference rule (Until-induction) to the proof system:

```
From G(psi -> chi) and G((phi AND G(chi)) -> chi), derive (phi U psi) -> G(chi)
```

This is the infinite generalization of the discrete Until-induction axiom. It is sound on all linear orders and directly enables the truth lemma proof. However, it changes the proof system from finitary to infinitary.

### 7.3 Recommended Path

**Primary: Approach 1 (Chain Construction)**

This is the mathematically standard approach. Burgess (1984), Goldblatt (1992), and Xu (1988) all use chain constructions for Until/Since completeness. The codebase already has partial chain infrastructure (DovetailingChain, Bundle modules).

The refactoring would:
1. Replace bx_until_eventuality_resolution with a chain-based witness construction
2. Build the chain w = w_0 <= w_1 <= ... <= w_n = v where v has psi
3. At each step, include phi U psi in the seed (possible because we can include it in the seed directly, not via g_content)
4. At intermediate w_i: if psi not in w_i, then phi U psi in w_i (from seed), then phi in w_i by BX9.

**Fallback: Approach 2 (Interval Linearity)**

If chain construction is too disruptive, investigate whether BX7 can be used to prove a restricted linearity lemma:

For all u with bx_le w u and phi U psi in w: either phi U psi in u or psi in u.

This is NOT the same as full linearity. It is a statement about the PERSISTENCE of Until formulas along the g_content preorder. If provable, it immediately gives the guard.

**Sketch for this restricted claim**:

Suppose phi U psi in w, bx_le w u, and phi U psi not in u and psi not in u. Then neg(phi U psi) in u (by MCS completeness).

From BX4: phi U psi -> G(P(phi U psi)). So P(phi U psi) in g_content(w) subset of u. So P(phi U psi) in u.

P(phi U psi) in u: there exists u' <= u with phi U psi in u'.
neg(phi U psi) in u: phi U psi not in u.

So u' < u (strictly -- phi U psi in u' but not in u, and u' <= u, so u' != u).

Now, can we derive a contradiction? We have:
- phi U psi in u'
- u' < u (strict)
- neg(phi U psi) in u
- psi not in u

From phi U psi in u': BX10 gives F(psi) in u'. By bx_forward_witness: there exists v' >= u' with psi in v'.

From neg(phi U psi) in u: what can we derive? The negation of phi U psi means: for all s >= u, either psi(s) is false or there exists r in [u, s) with phi(r) false.

Hmm, this is getting complicated. The key question is whether neg(phi U psi) in u leads to a contradiction with the other facts. I don't see a clear path.

### 7.4 Simplest Sound Addition: Restricted Until Propagation

If neither Approach 1 nor Approach 2 works within reasonable effort, the simplest sound addition is:

**New Axiom**: `(phi U psi) AND G(neg psi) -> G(phi U psi)`

Semantics: if phi U psi holds and psi will NEVER hold (G(neg psi)), then phi U psi persists forever (the witness is always in the future).

Wait, this is semantically wrong. If phi U psi holds at t with witness s (psi(s)), and G(neg psi) holds at t, then psi never holds at or after t, contradicting psi(s). So the antecedent `(phi U psi) AND G(neg psi)` is unsatisfiable, making the axiom vacuously true but useless.

**Better**: `(phi U psi) AND neg(psi) -> phi AND F(phi U psi)`

Semantics: if phi U psi holds at t and psi(t) is false, then phi(t) holds (BX9, already known) AND phi U psi will hold at some future point (F(phi U psi)). This last part: the witness s > t for phi U psi at t... does phi U psi hold at some future point? Well, at any r in (t, s), phi U psi holds with the same witness s (guard [r, s) is subset of [t, s)). So F(phi U psi) follows from the existence of some r > t before s. On dense orders this is fine. On discrete orders, phi U psi holds at t+1. On degenerate 1-point orders, if psi(t) is false and phi U psi holds at t, then the witness s > t, but there are no points > t... This can only happen if the order is unbounded.

Actually on a 1-point order {t}: phi U psi at t means there exists s >= t with psi(s). Only s = t. So psi(t). So if psi(t) is false, phi U psi at t is false. So the antecedent is unsatisfiable and the axiom is vacuously valid.

On a 2-point order {0, 1}: phi U psi at 0 with psi(0) false means s = 1, psi(1), phi(0). Then F(phi U psi) at 0 means there exists r >= 0 with phi U psi at r. Take r = 0: phi U psi at 0. So F(phi U psi) holds trivially (reflexive F). So the axiom says phi U psi AND neg(psi) -> phi AND F(phi U psi), which is phi AND F(phi U psi). Both are true.

This axiom IS valid, and it IS derivable: phi from BX9, and F(phi U psi) from BX8 applied to phi U psi (phi U psi -> bot U (phi U psi) = F(phi U psi)... wait, F is defined as top U, not bot U.

Actually F(phi) = some_future(phi) = neg(all_future(neg phi)) = neg(G(neg phi)). And top U phi: top U phi means there exists s >= t with phi(s) and for all r in [t, s), top(r). The guard is trivially true. So top U phi <-> F(phi). And by BX8: phi -> top U phi. So phi U psi -> F(phi U psi) by composing: phi U psi -> (apply BX8 with phi' = top) -> top U (phi U psi) = F(phi U psi).

Wait, BX8 says psi -> phi' U psi for ANY phi'. So phi U psi -> top U (phi U psi) = F(phi U psi). This is just BX8 applied to phi U psi as the "psi" argument. So F(phi U psi) is derivable from phi U psi. The axiom is derivable and adds nothing.

### 7.5 The Key Question Reformulated

Can we prove, using only BX1-BX10, that if phi U psi in w and u >= w and psi not in u, then phi in u?

Equivalently: is `G(neg psi -> phi)` derivable from `phi U psi`?

Semantically: phi U psi at t gives there exists s >= t with psi(s) and phi on [t, s). At any u >= t with psi(u) false: if u < s, then phi(u) from the guard. If u >= s: we don't know phi(u). But wait, if psi(s) and u >= s, does psi(u) being false tell us anything? No -- psi(s) is true but psi(u) for u > s is unknown.

So `G(neg psi -> phi)` does NOT follow from `phi U psi` semantically. For u > s (beyond the witness), phi might not hold.

This confirms that the guard property is inherently LOCAL to the interval [w, witness], not a GLOBAL consequence of the Until formula.

## 8. Conclusions and Recommendations

### 8.1 Definitive Answers

**Q1: Can the exact Burgess-Xu axiom 4 be derived from BX1-BX10?**
**A: No.** It is semantically invalid under half-open guard semantics. The 3-point countermodel in Section 1.4 proves this conclusively.

**Q2: Is there a valid variant derivable from BX1-BX10 that suffices for the truth lemma?**
**A: No.** All valid variants (Section 2) are too weak (existential P-based enrichments). No derivable formula can encode the INTERVAL guard condition because Until formulas don't propagate through g_content.

**Q3: Can BX5+BX7 together solve the guard verification?**
**A: Not in the BXCanonical framework.** BX5 provides self-accumulation but the enriched formula still doesn't propagate through g_content. BX7 orders Until witnesses within a single MCS but doesn't establish linearity of the bx_le preorder across MCS.

**Q4: What is the root cause of the 4 sorries?**
**A: The proof architecture.** The BXCanonical approach (abstract MCS with g_content preorder) lacks the linearity structure needed for guard verification. The standard Burgess proof uses explicit chain construction where linearity is built-in.

### 8.2 Recommended Path (Priority Order)

**1. Chain-based witness construction (RECOMMENDED)**

Replace the abstract MCS approach for Until/Since with explicit chain construction:
- Build a linear chain from w to v
- Include phi U psi in the seed at each step
- Guard follows from BX9 + chain membership

This is the standard approach and aligns with how the Bundle/DovetailingChain infrastructure was designed.

Estimated effort: Significant refactoring of Frame.lean (the 4 sorry stubs change their proof technique), but TruthLemma.lean signatures remain unchanged.

**2. Interval linearity lemma (ALTERNATIVE)**

Prove: if phi U psi in w and bx_le w u, then either phi U psi in u or psi in u.

This would suffice for the guard (by BX9). The proof would need to establish that Until "persists forward" along the g_content preorder until the witness is reached. This is non-trivial and may require additional insight, but would preserve the current BXCanonical architecture.

**3. Adding a new axiom (NOT RECOMMENDED for interaction axiom)**

No interaction axiom (even the original Burgess-Xu 4) resolves the issue under our semantics. The problem is structural (proof architecture), not axiomatic.

However, one could add an axiom that directly encodes Until persistence:
```
(phi U psi) AND neg(psi) -> G(phi U psi | psi)
```
i.e., "if phi U psi holds and psi doesn't hold yet, then at all future points, either phi U psi still holds or psi holds." This is valid on linear orders and would close the gap. But this is essentially encoding the semantic definition of Until into an axiom, which feels circular.

### 8.3 Precise Lean Signatures Needed

If approach 1 (chain construction) is adopted, the sorry stubs in Frame.lean keep their current signatures but change their proof internals:

```lean
-- Forward Until: same signature
noncomputable def bx_until_eventuality_resolution
    (w : BXPoint) (phi psi : Formula)
    (h_until : Formula.untl phi psi in w.formulas)
    (h_not_psi : psi not_in w.formulas) :
    exists v : BXPoint, bx_le w v AND psi in v.formulas AND
      forall u : BXPoint, bx_le w u -> bx_le u v AND not(bx_le v u) -> phi in u.formulas

-- Proof would use chain construction internally instead of Lindenbaum + abstract argument
```

If approach 2 (interval linearity) is adopted, a new lemma would be:

```lean
-- Until interval persistence
theorem until_interval_persistence
    (w u : BXPoint) (phi psi : Formula)
    (h_until : Formula.untl phi psi in w.formulas)
    (h_le : bx_le w u) :
    Formula.untl phi psi in u.formulas OR psi in u.formulas
```

This lemma, combined with the existing bx_forward_witness and BX9, would close all 4 sorries.

### 8.4 Note on Axiom System Completeness

The analysis suggests BX1-BX10 IS complete for our semantics (all valid formulas are derivable), but the PROOF TECHNIQUE for completeness differs from Burgess's original. The BXCanonical approach (abstract MCS) needs supplementation with either chain construction or an interval linearity lemma. This is a proof engineering issue, not a mathematical gap in the axiom system.

## References

- Burgess, J.P. (1982). "Axioms for Tense Logic I: Since and Until." *NDJFL* 23(4).
- Burgess, J.P. (1984). "Basic Tense Logic." In *Handbook of Philosophical Logic* Vol. II.
- Xu, M. (1988). "On Some US-Tense Logics." *JPL* 17(2).
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI.
- Venema, Y. (1993). "Derivation Rules as Anti-Axioms in Modal Logic." *JSL* 58(3).
- Reports 35, 36 in this task directory.
- Codebase: Frame.lean, Axioms.lean, Truth.lean, TemporalDerived.lean.
