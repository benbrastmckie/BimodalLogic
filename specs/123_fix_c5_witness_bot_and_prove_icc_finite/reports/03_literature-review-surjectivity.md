# Literature Review: Surjectivity of succ_embed in Omega-Chain Constructions

Task: 123 | Date: 2026-05-11

## Executive Summary

This report reviews the temporal logic completeness literature to determine:
1. Whether `succ_embed_surjective` (single-orbit / IsSuccArchimedean) is a theorem about the specific omega-chain construction or an independent property.
2. How published proofs handle the analogous step.
3. What proof strategy should be adopted.

**Verdict**: Single-orbit is a THEOREM about the construction, not an abstract order-theoretic fact. The published proofs handle it in one of two fundamentally different ways:

- **Burgess (1982) / Xu (1988)**: The construction builds a linear order on Q by adding rational-valued points. The limit is a countable subset of Q. Single-orbit is never explicitly stated because the construction works directly with chronicles (f, g) and the truth lemma, bypassing the need for a Z-isomorphism. The verification is implicit in condition C3 (interval coherence).

- **Reynolds (1994)**: Uses a two-stage approach. First build a model on a "vaguely integer-like" countable discrete structure (via Burgess-Xu), then transfer to Z via expressive completeness and Ehrenfeucht-Fraisse games. The single-orbit problem is dissolved: the final model is on Z by construction.

- **Venema (1993)**: Uses a three-stage approach. Build a model on an arbitrary linear order (via Burgess), verify it is "definably well-ordered" (via the W axiom killing gaps), then transfer to the target frame (omega, Z) via quantifier-depth equivalence. Again, single-orbit is bypassed.

- **Verbrugge et al. (2004)**: The "step-by-step" construction for Z builds the integer model DIRECTLY, never passing through an intermediate countable subset of Q. The construction ensures at each stage that successors and predecessors are assigned, and the limit IS Z. No surjectivity question arises.

**The key insight**: Our formalization's architecture creates the surjectivity question because it builds a countable subset of Q (LimitDomSubtype) and then needs to show it is isomorphic to Z. The published proofs avoid this by either (a) building Z directly (Verbrugge), (b) using expressive completeness to transfer from a "vaguely Z-like" structure to Z (Reynolds, Venema), or (c) never needing the isomorphism at all (Burgess). Our best path forward is to prove the surjectivity directly using `Icc` finiteness, which is the formalization of the fact that the discrete construction cannot accumulate.

---

## 1. Burgess (1982): The Original Omega-Chain Construction

### 1.1 Construction Overview

Burgess's completeness proof for the US-logic of all linear orders (Burgess 1982, "Axioms for Tense Logic I") constructs a countermodel as follows:

1. Start with a single MCS containing the consistent formula at rational 0.
2. Define "chronicles" (f, g) where f maps a finite subset of Q to MCSs, and g maps pairs to interval DCSs (deductively closed sets).
3. Conditions C0-C3 ensure coherence: C2 requires R(f(x), g(x,y), f(y)) for adjacent pairs; C3 requires g(x,z) = g(x,y) cap f(y) cap g(y,z) for intermediate points.
4. C4 and C5 are the counterexample elimination conditions: C4 eliminates counterexamples to negated-Until formulas (by inserting midpoints), and C5 creates witnesses for Until formulas (by adding endpoints).
5. The omega-chain alternately eliminates C4 and C5 counterexamples, producing limit chronicle (f_omega, g_omega) on a countable subset of Q.

### 1.2 How Burgess Handles Discreteness

Burgess does NOT construct a discrete model in this paper. His construction produces a model on a countable subset of Q, which is necessarily dense (by Cantor's theorem, any countable dense linear order without endpoints is isomorphic to Q). The discrete case is handled separately by adding discreteness axioms:

> "For the reader familiar with ordinary G,H-tense logic, the adaptation of our work below to prove these variants is a routine exercise." (Section 1.6)

This means Burgess does not confront the single-orbit question because his construction targets Q (or arbitrary linear orders), not Z. When discreteness axioms are added (U(T,bot) and S(T,bot)), the omega-chain construction still builds a subset of Q, but the axioms ensure that between consecutive MCS-assigned points, the interval DCS contains bot. The "routine adaptation" was never published in detail for the discrete/Z case.

### 1.3 The Truth Lemma and Orbit

Burgess's truth lemma (Claim 2.11) shows that formula membership in f(x) coincides with truth at x in the valuation. This works for ANY limit chronicle satisfying C0-C5, regardless of whether the domain has one orbit or many. The truth lemma does NOT require single-orbit. It requires only:
- C4: every negated-Until has a counterexample witness
- C5: every Until has a satisfaction witness
- C3: interval coherence

This is a critical observation: **the truth lemma does not depend on single-orbit**. The single-orbit question arises only when trying to transfer from the limit domain to Z (for the discrete case) or when proving coherence conditions that reference the successor structure.

---

## 2. Reynolds (1994): Axiomatising U and S over Integer Time

### 2.1 Two-Stage Architecture

Reynolds's completeness proof for US/Z (the US-logic of the integers) uses a sophisticated two-stage approach:

**Stage 1 (Section 5)**: Use the Burgess-Xu theorem (Theorem 2 / Corollary 3) to obtain a temporal structure M and point t such that:
1. The flow of time of M is countable, discrete, and without endpoints.
2. M satisfies A0 at t.
3. All substitution instances of Prior-UZ and Prior-SZ are valid in M.

This structure is obtained from the Burgess-Xu strong completeness for all linear frames. The axioms for discreteness (U(T,bot), S(T,bot)) and the Prior axioms (Fp -> U(p, ~p)) are propagated via G/H throughout the model.

**Stage 2 (Sections 6-8)**: Transfer to Z using expressive completeness and Ehrenfeucht-Fraisse games.

### 2.2 The Key Transfer: Contemporaneous Equivalence Relations

Reynolds's central technical innovation is the notion of a "contemporaneous equivalence relation" (Section 7). He defines an equivalence relation ~_M on M by:

> a ~_M b iff M|[min(a,b), max(a,b)] is "very good" (i.e., every subinterval is k-equivalent to an interval of Z).

**Theorem 14** (the main technical result): If ~ is a contemporaneous equivalence relation on a Prior structure M, then the ~-classes do not end at gaps.

This is used to show that the structure M from Stage 1 is "good" (k-equivalent to an interval of Z), and hence M itself has a k-equivalent on Z for any fixed quantifier depth k.

### 2.3 How Reynolds Avoids Single-Orbit

Reynolds NEVER constructs a succ_embed or proves single-orbit. His argument is:

1. Build countable discrete M satisfying all axioms (via Burgess-Xu).
2. Show M is "very good" using the contemporaneous equivalence relation theorem.
3. Conclude M is k-equivalent to Z (for appropriate k).
4. The k-equivalent Z-model satisfies the same sentences of quantifier depth <= k, hence satisfies the formula A0 at some point.

The transfer works because US-formulas have first-order "tables" (translations), and k-equivalence preserves truth of sentences up to quantifier depth k. Choosing k to exceed the quantifier depth of A0's table guarantees the transfer.

**This completely bypasses the orbit question.** Reynolds never needs to show that M is isomorphic to Z -- only that it is k-equivalent for a sufficiently large k. The "vaguely Z-like" structure M may have multiple orbits, accumulation points, or any other pathology, as long as it validates the right sentences up to depth k.

### 2.4 Implications for Our Formalization

Reynolds's approach suggests a fundamentally different architecture: instead of building Z directly (which requires proving single-orbit), build a "close enough" structure and transfer. However, this would require:
- Formalizing first-order translations of US-formulas
- Formalizing Ehrenfeucht-Fraisse games (or k-equivalence)
- Formalizing the contemporaneous equivalence relation theory
- Proving Theorem 14 (no gaps in equivalence classes)

This is estimated at 2000-5000 lines of formalization -- far more than proving `succ_embed_surjective` directly.

---

## 3. Venema (1993): Completeness via Completeness

### 3.1 Three-Stage Architecture

Venema's completeness proof for the US-logic of well-orderings (and omega) uses a three-stage approach:

**Stage 1**: Start with a consistent formula phi. Build a maximal BW-consistent set Phi containing phi. Since BW extends B (Burgess's system), Phi is B-consistent. By Burgess's completeness theorem (Theorem 3.5), there is a linear model M satisfying Phi.

**Stage 2**: Show M is "definably well-ordered" (Lemma 4.1). The key insight: the W axiom (Fp -> U(p, ~p)) kills all gaps. Specifically, if U'(psi, chi) held at some point in M (where U' is the Stavi connective, which detects gaps), then chi would hold "for a while" up to a gap, with ~chi arbitrarily soon after -- but the W axiom applied to chi gives U(~chi, chi) at t, contradicting the gap. Therefore, the Stavi connectives are all equivalent to bot in any BW-model, making SU expressively complete over the model M.

**Stage 3**: Apply Doets's theorem (Theorem 3.8): any definably well-ordered linear model has n-equivalents in WO for all n. Choose n to exceed the quantifier depth of phi's first-order table, and the n-equivalent well-ordered model satisfies phi.

For the case of omega (Theorem 4.3): if phi is BN-consistent (BN = BW + D, where D is the discreteness axiom), then phi AND box(D) is BW-consistent. The resulting well-ordered model M satisfies box(D), making it isomorphic to omega by Lemma 3.3(iii).

### 3.2 How Venema Avoids Single-Orbit

Like Reynolds, Venema never constructs a successor embedding or proves single-orbit. The orbit question is dissolved by the expressive completeness argument: the W axiom ensures that the Stavi connectives (which detect non-well-ordering phenomena like gaps) are trivially false, giving SU full first-order expressive power over the model. The Doets theorem then provides the transfer to well-orderings.

For the Z case specifically: Venema does not explicitly address the Z-completeness in this paper (which focuses on well-orderings and omega). However, the Reynolds paper handles Z using similar ideas.

### 3.3 The "Gap-Killing" Principle

Venema's Lemma 4.1 gives the most elegant explanation of why gaps cannot arise in our discrete construction:

> The axiom W (which is Fp -> U(p, ~p), the "Prior axiom" in Reynolds's terminology) ensures that after any true proposition, it remains true "until" it becomes false -- with no gap in between. This means the Stavi connective U'(phi, psi), which requires a gap, is always equivalent to bot in a W-model.

In our construction, the analogous principle is: the Prior-UZ axiom (Fp -> U(p, ~p)) is valid throughout the limit model. This axiom, combined with discreteness, prevents the kind of accumulation that would create multiple orbits. The orbit question is really about whether the limit construction can create "gaps" in the successor structure -- and the Prior axiom says it cannot.

---

## 4. Verbrugge et al. (2004): Step-by-Step Construction for Z

### 4.1 Direct Construction of Z

The Verbrugge-de Jongh-Veltman paper gives the most relevant construction for our purposes. Their completeness proof for D (the logic of discrete time) builds the model DIRECTLY as a linear order, without passing through Q:

**Stage 0**: Create root point t* with MCS Gamma_0 extending Sigma union {~phi}.

**Odd stages**: Assign immediate successor u and immediate predecessor v to each point t that doesn't already have them. The associate Gamma_u is a maximal D-consistent extension of:
```
{phi | G(phi) in Gamma_t} union {~psi or ~G(psi) | ~G(psi) in Gamma_t}
```
(The second component ensures that Gamma_u is the "immediate successor" MCS: it either contains ~psi (falsifying G(psi) at u) or ~G(psi) (meaning G(psi) holds at u but the counterexample is further ahead).)

**Even stages**: Eliminate counterexamples (as in the standard construction for Lin).

**Key property**: After the odd-stage successor assignment, "it will never be necessary to introduce at an even stage a successor of t which is not a successor of u." This is because:
- If ~G(psi) in Gamma_t, either ~G(psi) in Gamma_u (counterexample elimination handles it beyond u), or ~psi in Gamma_u (counterexample already at u).

### 4.2 How This Avoids Orbit Issues

The Verbrugge construction builds Z directly because:
1. Each point gets exactly one immediate successor and one immediate predecessor (assigned at odd stages).
2. The successor assignment is permanent: once u is assigned as the immediate successor of t, no later stage inserts a point between t and u.
3. The limit order is therefore a union of finite chains, and since it is successive and discrete by construction, it is isomorphic to Z (for the Z-case) or Z * Z (for the D-case, which is complete for arbitrary discrete structures Z * A).

**The critical difference from our construction**: Verbrugge assigns successors FIRST (at odd stages) and then eliminates counterexamples (at even stages). Our construction eliminates counterexamples (C4 and C5) at each stage, which can insert new points between existing ones, potentially disrupting the successor structure.

### 4.3 Verbrugge's Z Completeness (Theorem 6)

For Z specifically, Verbrugge uses "adequate sets" (finite approximations to maximal consistent sets) and a more delicate construction:

1. Create root t_0 with Gamma_0.
2. Create "maximal" right endpoint t_r (with Gamma_r containing a maximal number of G-formulas) and "minimal" left endpoint t_l.
3. Treat counterexamples between t_l and t_r, creating a finite middle stretch.
4. Extend both ends infinitely: since Gamma_r is "maximal," all successors of t_r have the same G/H-formulas. The ~G-formulas are treated cyclically, producing an infinite extension isomorphic to N (and dually for the left end).

The result is a model isomorphic to Z (or n + Z * n' + N* for the middle part, extended to Z on both sides).

### 4.4 Implications for Our Formalization

The Verbrugge approach suggests that the "right" construction for Z would assign successors at dedicated stages, preventing later counterexample elimination from disrupting the successor structure. Our construction interleaves counterexample elimination with point insertion, which is why the orbit question arises. However, refactoring the construction is far more expensive than proving surjectivity directly.

---

## 5. Goldblatt-Hodkinson-Venema (2003): BAOs and Modal Logic

The GHV 2003 paper works in the algebraic setting (Boolean algebras with operators) and does not directly address step-by-step constructions for discrete temporal logics. However, the Sahlqvist-style correspondence theory and canonicity results it develops are relevant background for understanding why the canonical frame approach has limitations (the canonical frame for the discrete temporal logic is not irreflexive, requiring model surgery to extract a strict linear order).

---

## 6. IsSuccArchimedean in Lean/Mathlib

### 6.1 The Mathlib Pipeline

Mathlib provides `orderIsoIntOfLinearSuccPredArch`, which constructs an order isomorphism from a type to Z, given:
- `LinearOrder`
- `SuccOrder`
- `PredOrder`
- `IsSuccArchimedean`
- `NoMaxOrder`
- `NoMinOrder`
- `Nonempty`

`IsSuccArchimedean` is the statement that for any a <= b, there exists n such that succ^[n](a) = b. Equivalently, every element is reachable from every other by finitely many successor/predecessor steps.

### 6.2 How IsSuccArchimedean Relates to Single-Orbit

`IsSuccArchimedean` is EQUIVALENT to "single succ-orbit" for a linear order with no max/min. If there were two orbits, elements in different orbits would be comparable (by linearity) but not succ-reachable from each other, violating IsSuccArchimedean.

### 6.3 Existing Formalization Approaches

No existing Lean/Mathlib/Isabelle/Coq formalization of temporal logic completeness proofs was found that addresses the single-orbit question directly. The published Lean formalizations of modal logics (e.g., Obendrauf 2024 for coalition logic) do not involve discrete temporal constructions.

---

## 7. Analysis: Why the Orbit Question Arises in Our Construction

### 7.1 The Gap Between Literature and Formalization

The published proofs avoid the orbit question by one of three strategies:
1. **Build Z directly** (Verbrugge): assign successors at dedicated stages, preventing disruption.
2. **Transfer via k-equivalence** (Reynolds, Venema): build a "close enough" structure and transfer using expressive completeness.
3. **Never need the isomorphism** (Burgess): work with chronicles on Q and prove the truth lemma directly.

Our formalization takes a fourth path:
4. **Build a countable subset of Q, then show it is isomorphic to Z**: the omega-chain construction builds LimitDomSubtype (a countable discrete subset of Q with no max/min), and we need to show it has IsSuccArchimedean to apply the Mathlib pipeline to Z.

This fourth path creates the orbit question because it requires proving a structural property (single-orbit) of the limit that is not needed by the other approaches.

### 7.2 Is Single-Orbit TRUE for Our Construction?

YES. The previous research reports (06_surjectivity-false-verification.md) establish this. The argument is:

1. `succ_embed_no_gap`: Between succ_embed(n) and succ_embed(n+1), there are NO LimitDomSubtype points. This is proved.
2. `succ_embed_squeeze`: Any point between succ_embed(a) and succ_embed(b) (inclusive) equals succ_embed(k) for some a <= k <= b. This is proved.
3. **Cofinality**: The succ-orbit is cofinal (unbounded above and below) in LimitDomSubtype.

Property (3) is the only unproved part. It follows from:
- Every LimitDomSubtype point enters at a finite omega-chain stage K.
- At stage K, the domain has finitely many points.
- The succ-orbit from root visits points at arbitrarily late stages (because each stage can produce at most one new point, and the successor of a point above all stage-K points is determined by the limit-domain successor, which exists by the discrete hypothesis).

The difficulty is formalizing (3), not its truth.

### 7.3 Why Cofinality is Hard to Formalize

The obstacle is that `limitDomSubtype_succ` is defined as the Classical.choose of a limit-domain existence proof. When a new point q is added at stage K+1 above all stage-K points, `succ(max_K)` in the FULL limit domain may be a point inserted by a LATER stage (K+2, K+3, ...) between max_K and q. So `succ_embed(j+1) = succ(max_K)` might be strictly less than q.

However, the squeeze lemma then applies: q is between succ_embed(j+1) and some succ_embed(j+m) for sufficiently large m. The question reduces to: does succ_embed reach above q eventually? The answer is yes: since the orbit is strictly increasing and unbounded (it visits points at arbitrarily late stages), it must pass q.

The formal argument needs either:
- **Icc finiteness**: Show that the set of LimitDomSubtype points in any bounded interval is finite. Then the succ-orbit in that interval terminates, reaching the upper bound.
- **Well-founded induction on stages**: Use the stage structure of the omega chain to show that every point is eventually reached.

---

## 8. Recommendations

### 8.1 Recommended Proof Strategy: Icc Finiteness

The cleanest approach is to prove that `Set.Icc a b` is finite for any `a b : LimitDomSubtype` in the discrete case. The argument:

1. Between any two consecutive LimitDomSubtype points (succ pairs), there are NO other LimitDomSubtype points (by the discrete hypothesis / no-gap property).
2. If Icc(a, b) were infinite, there would be an infinite strictly increasing sequence a = x_0 < x_1 < x_2 < ... <= b, with each x_{i+1} = succ(x_i).
3. The rational values x_i.val form a bounded monotone sequence in Q.
4. If this sequence converges to L in R: either L is in limit_dom (impossible by the no-gap property between pred(L) and L) or L is not in limit_dom (but then some limit_dom point z > L has pred(z) < L, and the x_i between pred(z) and z violate the no-gap property).

Once Icc finiteness is established, `IsSuccArchimedean` follows from Mathlib's existing infrastructure for locally finite orders, or by a direct argument (the succ-orbit in a finite Icc must reach b).

### 8.2 Alternative Strategy: Reynolds-Style Transfer

If Icc finiteness proves too difficult, consider the Reynolds approach:
1. Ignore the Z-isomorphism question entirely.
2. Show the limit model validates all axioms (already done for most).
3. Use expressive completeness + k-equivalence to transfer to Z.

This avoids surjectivity but requires formalizing substantial model theory infrastructure. Estimated: 2000-5000 new lines. NOT recommended for the current task.

### 8.3 Alternative Strategy: Verbrugge-Style Refactoring

Restructure the omega-chain construction to assign successors at dedicated stages (odd stages), preventing later counterexample elimination from disrupting the successor structure. This would make single-orbit trivially true but requires refactoring the entire construction. Estimated: 1000-2000 new lines. NOT recommended.

### 8.4 Summary of Estimated Effort

| Strategy | New Lines | Difficulty | Risk |
|----------|-----------|------------|------|
| Icc finiteness (recommended) | 100-200 | High | Low (mathematically sound) |
| Reynolds transfer | 2000-5000 | Very High | Medium (new infrastructure) |
| Verbrugge refactoring | 1000-2000 | High | High (breaks existing code) |
| Direct stage induction | 80-150 | High | Medium (tricky case analysis) |

---

## 9. The "Between Old Points" Case is PROVED

It is worth emphasizing that the existing proof handles the "between old points" case (when a newly added point q falls between two existing stage-K points that are already in the image of succ_embed). The squeeze lemma (`succ_embed_squeeze_strict`) handles this case completely.

The only remaining sorry sites are:
1. `q > max_K` (new point above all stage-K points)
2. `q < min_K` (new point below all stage-K points, symmetric)

These are the cofinality cases. Proving Icc finiteness resolves both simultaneously: if Icc(root, w) is finite for any w >= root, then the succ-orbit from root reaches w, establishing `succ_embed(n) >= w` for some n. The squeeze lemma then gives `succ_embed(k) = w`.

---

## 10. Conclusion

The surjectivity of `succ_embed` (equivalently, single-orbit / IsSuccArchimedean for LimitDomSubtype) is a TRUE property of the specific omega-chain construction in the discrete case. It is NOT a consequence of abstract order-theoretic properties (the Z + Z counterexample confirms this). The published literature avoids the question by using different proof architectures, but our formalization's architecture requires it.

The recommended approach is to prove `Icc` finiteness for LimitDomSubtype, which is the formal expression of the intuitive fact that a discrete order with the no-gap property cannot accumulate points in a bounded interval. This is mathematically sound, consistent with the existing proof infrastructure, and requires the least new code.

---

## References

### Primary Sources (in project literature/ directory)

1. **Burgess 1982**: "Axioms for Tense Logic I: Since and Until". The original omega-chain construction.
2. **Reynolds 1994**: "Axiomatising U and S over Integer Time". Two-stage proof with contemporaneous equivalence relations.
3. **Venema 1993**: "Completeness via Completeness: Since and Until". Three-stage proof via expressive completeness and Doets's theorem.
4. **Venema 2001**: "Temporal Logic" (survey chapter). Overview of the field.
5. **Verbrugge et al. 2004**: "Completeness by Construction for Tense Logics of Linear Time". Direct step-by-step construction for Z.
6. **Xu 1988**: "On Some U,S-Tense Logics". Simplification of Burgess's axiom system.
7. **Venema 1991**: "Many-Dimensional Modal Logics" (Chapter 2). Non-xi rules and negative definability.
8. **Venema 1993**: "Derivation Rules as Anti-Axioms in Modal Logic". Generalization of Gabbay's irreflexivity rule.

### Web Sources

- [Mathlib.Order.SuccPred.Relation](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Order/SuccPred/Relation.html) - IsSuccArchimedean in Mathlib
- [Mathlib.Order.SuccPred.LinearLocallyFinite](http://florisvandoorn.com/carleson/docs/Mathlib/Order/SuccPred/LinearLocallyFinite.html) - orderIsoIntOfLinearSuccPredArch
- [Verbrugge PDF](https://festschriften.illc.uva.nl/D65/verbrugge.pdf) - Full text of the step-by-step completeness paper
- [Temporal Logic (SEP)](https://plato.stanford.edu/entries/logic-temporal/) - Stanford Encyclopedia overview
