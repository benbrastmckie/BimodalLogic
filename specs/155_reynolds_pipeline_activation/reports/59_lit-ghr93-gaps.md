# GHR93 Gap Elimination: What It Actually Proves

**Source**: Gabbay, Hodkinson, Reynolds 1993, "Temporal Expressive Completeness in the Presence of Gaps"
**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-06-02
**Focus**: Does GHR93's gap elimination help prove IsSuccArchimedean?

---

## 1. What Is "Gap Elimination" in GHR93?

GHR93 does NOT contain a theorem called "gap elimination." The term is misleading as applied to this paper. GHR93 is about **expressive completeness**: which temporal connectives suffice to express all monadic first-order properties over linear orders.

The paper's central concern is: when a linear order has Dedekind gaps (supremum-less initial segments), do Until and Since suffice for expressive completeness, or do we need additional connectives (Stavi connectives U', S')? The answer depends on what KIND of gaps the order has.

**Key results**:
- **Theorem 3 (Kamp-Stavi)**: {U, S, U', S'} is expressively complete over ALL linear time (Section 8, full proof given).
- **Lemma 2**: Over flows with only ISOLATED gaps, {U, S} alone suffices (U' becomes definable from U, S, and the gap-detector gamma-plus).
- **Lemma 8**: {U, S, gamma-zero-plus, gamma-zero-minus} is expressively complete over ALL linear time (gamma-zero detects isolated definable gaps).

The "gap" in GHR93 is a **Dedekind gap in the linear order** -- a point where the order is not complete. This is an ORDER-THEORETIC concept: a cut with no supremum. It has nothing to do with "gaps between equivalence classes" (which is Reynolds 1994's concern).

---

## 2. Stavi Connectives and Gap Detection

The Stavi connective U'(A, B) is defined (Section 3, p.95) as: B holds from now until a gap, and after the gap A holds for a while. Its first-order table involves existential quantification over points, with conditions that detect a transition across a gap.

GHR93 introduces a hierarchy of gap-detecting connectives:
- **gamma-plus(A)**: detects an A-left-gap (A holds up to a gap but fails arbitrarily soon after).
- **gamma-zero-plus(A)**: detects an ISOLATED A-left-gap (using U' to check no nearby similar gaps).
- **gamma-n-plus(A)**: detects an nth-order A-left-gap (a gap with only lower-order gaps nearby).

These connectives classify the COMPLEXITY of gaps in a flow of time. The key insight: a flow with only isolated gaps (order-0) allows U and S alone; non-isolated gaps require progressively stronger connectives; unranked gaps (as in Q) require the full Stavi connectives.

The relationship between formula-definable gaps and flow-of-time gaps is subtle (Section 3): every A-left-gap sits at a real flow-of-time gap, but not every flow-of-time gap is detected by a given formula. An nth-order A-left-gap sits at a flow-of-time gap of order >= n.

---

## 3. EF Games in the Expressive Completeness Proof

Section 8 proves Theorem 3 (Stavi expressive completeness over all linear time) using Ehrenfeucht-Fraisse games. The structure is:

**Definition 8.7**: A modified game G_{n;r}(M, xy; N, x'y') where:
- Round 1: Forall picks n points in [x,y]_r (including gaps); Exists responds in [x',y']_r.
- Round 2: Forall picks one POINT (non-gap) in [x',y']; Exists responds with a point in [x,y].
- Exists wins if tuples have the same order type and agree on all rank-r temporal formulas.

**Theorem 6 (Main step)**: If Exists has a winning strategy for enough "forward" games G(M -> N), then she has a winning strategy for a "backward" game G(N -> M). The proof splits into four cases based on what alpha_n (the last chosen point) is:

- **Case I**: alpha_0 > d-bar (the infimum of the continuation region). Both intervals have at most n points; use existing strategies.
- **Case II**: All alpha_i in (d-bar, y'), and alpha_n is a POINT (not a gap). Use B = X_{alpha_n} (the rank-r type) and U(B, A) to find a matching point in M.
- **Case III**: All alpha_i in (d-bar, y'), and alpha_n is a gap DEFINED ON THE LEFT by some D. Use left(B, D) and U'(delta, A) to find a matching gap in M.
- **Case IV**: All alpha_i in (d-bar, y'), and alpha_n is a gap NOT definable on the left at rank r. Use right(B, D) for D defining alpha_n on the right.

**Claim 1** (p.116): In any play where Exists uses a winning strategy, her response to c (the infimum of {t in [x,y] : C holds on (t,y)}) is precisely d-bar (the corresponding infimum in N). This is proven by showing d >= d-bar (from formula transfer of C_1 = not-C or K-minus-C) and d <= d-bar (by contradiction: if d < d-bar, Forall can exploit the discrepancy).

The EF game argument is purely about EXPRESSIVE POWER -- showing that temporal formulas can separate any two points distinguishable by first-order logic. It does not prove properties of the order itself.

---

## 4. What the GHR93 Proof Technique Actually Establishes

The GHR93 proof establishes:

**For any linear order (T, <)**, every monadic first-order formula phi(x) is equivalent to a temporal formula built from {U, S, U', S'}. This is a LOGICAL result about definability, not an order-theoretic result about structure.

Concretely, the proof shows: if two points in two structures satisfy the same temporal formulas up to rank g(n+1)+1, then they satisfy the same first-order formulas up to quantifier depth n (Corollary 5, p.115). This is proven by:
1. Constructing winning strategies for modified EF games (Propositions 6, 7).
2. Composing local interval strategies into global strategies (Proposition 7).
3. Applying the fundamental EF theorem (Proposition 5).

The proof does NOT:
- Prove that any order is gap-free.
- Prove that any order has specific structural properties.
- Perform "model surgery" in the sense of Reynolds 1994 (replacing parts of a model).
- Show that equivalence classes end at points rather than gaps.

---

## 5. Reynolds 1994 vs GHR93: The Crucial Distinction

The "gap elimination" that matters for IsSuccArchimedean is in **Reynolds 1994** ("Axiomatising U and S over Integer Time"), NOT in GHR93. The two papers do fundamentally different things:

| Aspect | GHR93 | Reynolds 1994 |
|--------|-------|---------------|
| **Goal** | Expressive completeness of temporal connectives | Axiomatization of U,S over integer time |
| **"Gap" means** | Dedekind gap in a linear order | Gap between equivalence classes |
| **Technique** | EF games for definability | Model surgery on temporal structures |
| **Result** | Logical (definability) | Structural (no gaps between classes) |
| **Theorem 14** | Not present | Classes of ~ don't end at gaps |

Reynolds 1994 Theorem 14 proves: if ~ is a contemporaneous equivalence relation on a Prior structure M, then ~-classes do not end at gaps. The proof uses:
1. Expressive completeness of {U,S} over Prior structures (Reynolds Theorem 5, which USES GHR93/Kamp-style results as input).
2. Model surgery (Lemma 12): replace a "bad interval" (where classes end at gaps) with a single class, preserving all temporal formulas.
3. Contradiction: R (detecting gap-on-right) holds in the surgery model but should not.

---

## 6. Does GHR93 Give a Proof Technique for IsSuccArchimedean?

**No.** GHR93's techniques are about EXPRESSIVE POWER of temporal languages, not about structural properties of orders. The paper shows WHICH connectives are needed for completeness depending on gap complexity. It does not prove orders are gap-free.

The connection to IsSuccArchimedean runs through Reynolds 1994, not GHR93:

1. **GHR93 Theorem 3** -> {U,S,U',S'} expressively complete over all linear time.
2. **Reynolds Theorem 5** -> {U,S} expressively complete over Prior structures (uses GHR93 as input + separation arguments specific to Prior structures).
3. **Reynolds Theorem 14** -> contemporaneous equivalence classes don't end at gaps in Prior structures (uses Theorem 5 + model surgery).
4. **Application to chronicle** -> The k-type equivalence on the chronicle's limit domain doesn't end at gaps -> discrete order with no gaps between classes -> IsSuccArchimedean.

Step 4 is where the logical result must be translated into an order-theoretic property. This translation is non-trivial because:
- IsSuccArchimedean is a SECOND-ORDER property (quantifying over all points).
- Reynolds Theorem 14 gives a FIRST-ORDER consequence (no gaps between equivalence classes for a SPECIFIC equivalence relation).
- The bridge requires: showing that if the chronicle's limit domain had a "gap" (two points not connected by finite successor chains), then some contemporaneous equivalence relation would detect it.

---

## 7. Summary of Findings

1. **GHR93 "gap elimination" is a misnomer** for our purposes. The paper classifies gaps and proves expressive completeness results; it does not eliminate gaps from orders.

2. **The relevant gap elimination is Reynolds 1994 Theorem 14**, which proves equivalence classes don't end at gaps in Prior structures via model surgery.

3. **GHR93's role is foundational**: it provides the expressive completeness of {U,S,U',S'} over all linear time (Theorem 3), which Reynolds 1994 uses as input for the separation theorem specific to Prior structures.

4. **GHR93 does NOT provide a direct proof technique for IsSuccArchimedean.** The path goes: GHR93 (expressive completeness) -> Reynolds (gap elimination for equivalence classes) -> application to chronicle (structural consequence).

5. **The claim that "model surgery can't prove IsSuccArchimedean because it's second-order" is partially correct**: GHR93's model surgery (EF games) proves nothing about IsSuccArchimedean. Reynolds 1994's model surgery proves equivalence classes don't end at gaps, which IS a step toward IsSuccArchimedean but requires additional argument to bridge from "no gaps between classes" to "every two points connected by finite successor chains."

6. **The most direct route to IsSuccArchimedean** remains either (a) the construction-level argument about the omega-chain (report 31, Approach A), or (b) the full Reynolds pipeline (reports 08, 26), which requires formalizing Reynolds Theorem 14 with all its dependencies on expressive completeness.
