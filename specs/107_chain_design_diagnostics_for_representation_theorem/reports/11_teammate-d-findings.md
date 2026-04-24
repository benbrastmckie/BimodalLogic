# Teammate D Findings: Domain Construction in Until/Since Completeness Proofs

**Task**: #107 -- Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-24
**Focus**: How do existing completeness proofs construct the domain? Dense vs. discrete models, density axiom, reflexive vs. strict semantics.

---

## 1. What Domain Does Burgess 1982 Construct?

### 1.1 The Construction Produces a Subset of Q

Burgess 1982 (Part I, Section 2) constructs a model over a **subset of the rationals**, not over all of Q. The key passage (after Lemma 2.10):

> "We now let X be the union of the sets dom f_n, and f and g the unions of the f_n and g_n respectively. Then (f, g) satisfies C0--C5. We define a valuation V in (X, <) -- the order being the usual order on the rationals -- by letting x in V(alpha) iff alpha in f(x)."

The domain X = union of dom(f_n) is a countable subset of Q. Crucially:

- **X is NOT necessarily dense.** The construction only inserts points when needed to eliminate C4/C5 counterexamples. There is no density step.
- **X could be finite or countably infinite.** It depends on the formula being falsified.
- **The model is (X, <) where < is the inherited rational ordering.** X inherits whatever order-theoretic properties it has from Q, but X itself may lack density, may have endpoints, etc.

### 1.2 The Model Is NOT Dense Unless the Formula Requires It

This is the critical point. Burgess's construction produces a model over (X, <) where X is whatever set of rationals the counterexample elimination produces. The model is:

- **Always a linear order** (inherited from Q).
- **Always without first or last element** if the logic includes F(T) and P(T) axioms.
- **NOT necessarily dense.** There may be adjacent points in X with no points between them.

The completeness theorem (Section 1.5) states: "Every formula consistent with J_0 is satisfiable over K_0" where K_0 is the class of **all linear orders**. The model (X, <) is indeed a linear order, so this is correct. Burgess does NOT claim completeness with respect to Q or any specific frame -- only with respect to the class of all linear orders.

### 1.3 Comparison with Verbrugge's Construction

Verbrugge 2004 presents completeness proofs for **specific** frame classes:

| Logic | Frame Class | Domain Structure |
|-------|-------------|-----------------|
| Lin   | All strict linear orders | Countable subset of some order |
| P     | Successive strict linear orders | Successive (no endpoints) |
| **Q** | **Dense successive = Q** | **Explicitly made dense** |
| R     | Reals | Extended from Q to R |
| D     | Discrete successive | Discrete |
| Z     | Integers | Isomorphic to Z |

For logic **Q** (Theorem 3), Verbrugge explicitly interleaves density steps:

> "At the odd stages density is taken care of as follows: Let t, u be any two successive points of T_n. A new point v between each such t and u is added. By Lemma 5 there exists a Delta such that Gamma_t prec Delta prec Gamma_u."

This uses the **density axiom** GGp -> Gp (axiom Q in Verbrugge's notation) to guarantee that a point can always be inserted between any two existing points. The density of the prec relation (Lemma 5) is a direct consequence of this axiom.

**The result is a countable dense linear order without endpoints, which is isomorphic to Q by Cantor's theorem.**

---

## 2. The GGp -> Gp Issue Under Strict Semantics

### 2.1 The Core Question Restated

The user's question asks: If we construct a countermodel over Q (dense strict order), and GGp -> Gp is valid on Q under strict semantics, doesn't this mean we can't falsify GGp -> Gp even though it may not be derivable in BX?

### 2.2 Semantic Analysis: GGp -> Gp Under Strict G

Under **strict** G semantics (Gp means: for all t' > t, p(t')):

- **GGp at t** means: for all t' > t, for all t'' > t', p(t'').
- **Gp at t** means: for all t' > t, p(t').

Does GGp -> Gp hold on all dense strict linear orders?

**Yes.** On a dense order, if GGp holds at t, then for any t' > t, we need p(t'). By density, there exists t'' with t < t'' < t'. Then GGp at t gives GGp at t'' (since t'' > t implies Gp at t'', but actually we need the full argument):

Actually, let's be precise. GGp at t means: for all s > t, Gp(s). Gp(s) means: for all s' > s, p(s'). So GGp at t means: for all s > t, for all s' > s, p(s').

Now consider Gp at t: for all t' > t, p(t'). Take any t' > t. By density, there exists s with t < s < t'. Then GGp at t gives: for all s' > s, p(s'). Since t' > s, we get p(t').

**So GGp -> Gp IS valid on every dense strict linear order.**

### 2.3 Does GGp -> Gp Fail on Non-Dense Orders?

**Yes.** On Z (integers) with strict G:
- Let p hold at all even integers >= 4.
- At t = 0: G(Gp) asks whether for all n > 0, Gp(n). Gp(1) asks whether for all m > 1, p(m). p(2) = false (2 is even but we said >= 4... let me redo).

Simpler: Let p hold at all t >= 2 in Z.
- Gp at 0: for all t > 0, p(t). We need p(1). p(1) is true (1 < 2 is false... wait, 1 >= 2 is false).

Let me be more careful. In Z with strict <:
- Let p be true at all t in {0, 2, 4, 6, ...} (even non-negative integers) and false at odd integers and negative integers.
- GGp at -1: for all s > -1, Gp(s). Gp(0) means for all s' > 0, p(s'). But p(1) = false. So Gp(0) = false. So GGp at -1 = false. Not useful.

The standard counterexample: Let p be true at all t != 1 in Z.
- Gp at 0: for all t > 0, p(t). p(1) = false. So Gp(0) = false.
- GGp at 0: for all s > 0, Gp(s). Gp(1) = for all t > 1, p(t) = true (all t >= 2 have p). Gp(2) = true. Etc. So GGp(0) = true.
- But Gp(0) = false. So GGp -> Gp fails at 0.

**Confirmed: GGp -> Gp fails on Z under strict G, but holds on Q under strict G.**

### 2.4 The Reasoning IS Correct -- But It's Not a Problem for Burgess

The user's reasoning is **logically correct**: if we construct a countermodel over Q, then GGp -> Gp would be valid in that model (under strict G), so we could never falsify it. If GGp -> Gp is not derivable in BX, the construction would fail to produce a countermodel for it.

**However, Burgess's construction does NOT produce models over Q.** It produces models over a subset X of Q, which may not be dense. The formula GGp -> Gp is NOT valid on all subsets of Q -- it fails on any subset isomorphic to Z, for instance.

So the resolution is:

1. **Burgess's J_0 does NOT include GGp -> Gp as an axiom.** It is not derivable in J_0.
2. **Burgess's construction produces a model over (X, <) where X is some linear order** -- not necessarily dense.
3. **GGp -> Gp can be falsified on (X, <)** because X might not be dense.
4. **There is no density axiom issue** because no density is imposed on the model.

### 2.5 What About BX?

BX is an extension of Burgess's J_0 with modal operators. The question is: does BX include GGp -> Gp?

Looking at the project's axioms:

```
BX includes: G(phi -> psi) -> (Gphi -> Gpsi)  [K for G]
             Gphi -> GGphi                      [4 for G]
             phi -> GPphi                        [connect_future]
```

**BX does NOT include GGp -> Gp.** The 4 axiom (Gphi -> GGphi) gives transitivity, not density. Under strict semantics, 4 is sound for transitive frames, and GGp -> Gp characterizes density. These are different properties.

**Therefore, the BX construction should produce models that are NOT necessarily dense, and GGp -> Gp can be falsified.**

---

## 3. Reflexive vs. Strict Semantics in the Literature

### 3.1 Burgess 1982 (Part I) -- STRICT Semantics

Burgess uses **strict** semantics throughout Part I. The formal semantics (Section 1.2):

> V(G alpha) = {x : for all y (x < y implies y in V(alpha))}

This is strict: x < y, not x <= y. The G operator quantifies over strictly future instants. The Until semantics is also strict:

> V(U(alpha, beta)) = {x : exists y (x < y and y in V(alpha) and for all z (x < z < y implies z in V(beta)))}

The open interval (x, y) excludes both endpoints.

### 3.2 Burgess 1982b (Part II) -- Period-Based, But Strict Underlying Order

Part II works with **period-based** tense logic over open intervals. The underlying instant-based order is still strict (< is a dense linear order without endpoints). The period-based G semantics (Section 3.1) is:

> W(G alpha) = {a : for all b, c (b included in a and b <_1 c implies c in W(alpha))}

This quantifies over ALL periods strictly after any sub-period of a. The additional axiom A5 (Gp -> p) is added because in period semantics, a period's sub-periods overlap with its future -- this is a **reflexivity axiom specific to period semantics**, not to the underlying temporal order.

Part II does NOT shed significant light on the domain construction question. It's about a different semantic framework (periods rather than instants) and proves completeness by reduction to the instant-based case (Section 4.3).

### 3.3 Verbrugge 2004 -- STRICT Semantics

Verbrugge explicitly works with **strict linear orders** (Definition 3(iv): "transitive, irreflexive and connected"). The completeness theorems are all with respect to strict linear orderings. Theorem 1 states: "Lin is strongly complete with respect to all strict linear orderings."

### 3.4 The BX Codebase -- STRICT Semantics

The ProofChecker codebase uses strict semantics. From `Semantics.lean`:

> | Gphi | for all s > t, s in tau.domain implies truth_at M tau s hs phi |

This is strict (s > t, not s >= t). The branch is called `irr_until` -- "irr" standing for irreflexive, confirming strict semantics.

### 3.5 Summary of Semantics

| Source | Semantics | Notes |
|--------|-----------|-------|
| Burgess 1982 Part I | **Strict** (x < y) | Explicit in Section 1.2 |
| Burgess 1982b Part II | **Strict** underlying order | Period semantics adds Gp -> p separately |
| Verbrugge 2004 | **Strict** (irreflexive) | Explicit in Definition 3(iv) |
| BX/ProofChecker | **Strict** (s > t) | Explicit in Semantics.lean |

**All sources agree on strict semantics.** There is no reflexive/strict mismatch.

---

## 4. Answering the Theoretical Question

### 4.1 The Question

> If GGp -> Gp is valid on Q (dense strict order), and we construct our countermodel over Q, then GGp -> Gp cannot be falsified. If GGp -> Gp is not derivable in BX, the construction fails. Is this reasoning correct?

### 4.2 The Answer

**The reasoning is correct as a hypothetical, but the premise is wrong for Burgess's construction.**

The key factual error is: "we construct our countermodel over Q." **Burgess does NOT construct countermodels over Q.** He constructs them over a subset X of Q, which is the union of finitely-extending domains dom(f_n). This subset:

1. Is countable (countable union of finite sets).
2. Is linearly ordered (inherits from Q).
3. Has no first or last element (if the logic includes successiveness axioms).
4. **May or may not be dense** -- density is NOT enforced by the construction.

Since X may not be dense, GGp -> Gp is NOT valid on (X, <), and CAN be falsified.

### 4.3 When WOULD the Issue Arise?

The issue would arise **only if** we explicitly added a density step to the construction (as Verbrugge does for logic Q). If we interleaved density insertions at every stage, forcing X to be dense, then:

1. X would be isomorphic to Q.
2. GGp -> Gp would be valid on (X, <).
3. The construction could not falsify GGp -> Gp.
4. We would need GGp -> Gp to be an axiom of our logic.

This is exactly what happens in Verbrugge's Theorem 3 for logic Q: the logic Q includes the density axiom GGp -> Gp, the construction produces a dense model, and completeness holds because the axiom matches the frame class.

### 4.4 Implications for BX

BX does NOT include GGp -> Gp. Therefore:

- **Do NOT add density steps to the chronicle construction.** The domain should be whatever the counterexample elimination naturally produces.
- **The model (X, <) may not be dense.** This is fine -- BX is meant to be complete with respect to a class of frames that includes non-dense ones.
- **The current `extended_limit_f` approach (extending to all of Q) IS problematic** for exactly the reason identified: it forces the model onto Q, making GGp -> Gp valid. The fix is to work over X = limit_dom only, not over all of Q.

### 4.5 The extended_limit_f Problem Restated

The current code extends the chronicle's domain function to ALL rationals:

```lean
noncomputable def extended_limit_f (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    Rat -> Set Formula :=
  fun x =>
    if h : exists n, x in (omega_chain_val A h_mcs n).dom
    then (omega_chain_val A h_mcs h.choose).f x
    else A  -- assigns root MCS to non-domain rationals
```

This creates a model over all of Q. Under strict semantics:

1. GGp -> Gp becomes valid in this model (Q is dense).
2. If GGp -> Gp is not in the root MCS A, the truth lemma fails.
3. The construction cannot serve as a countermodel for formulas involving the density property.

**The fix**: Define the BFMCS over `{ x : Rat // x in limit_dom A h_mcs }` rather than `Rat`. This was already identified in report 08, and this analysis confirms the diagnosis is correct.

---

## 5. What the Prior Analysis (Report 08) Got Right and Wrong

### 5.1 Correct Conclusions

Report 08 correctly identified:
- Verbrugge uses strict semantics (Section 5.1).
- Burgess uses strict semantics for Until/Since (Section 5.2).
- The `extended_limit_f` extending to all of Q is wrong (Section 3.3).
- The "insert between" strategy is essential (Section 1.4).
- C4 is structurally necessary (Section 2).

### 5.2 Omission: The Density/GGp Issue

Report 08 did NOT explicitly address the density axiom question. It identified the `extended_limit_f` problem in terms of the T-axiom (Gp -> p being needed at non-domain points), but did not note the deeper issue: that extending to Q makes GGp -> Gp valid, which is a completeness-breaking problem if GGp -> Gp is not derivable.

The T-axiom analysis is correct but partial:
- At non-domain rationals, `extended_limit_f` returns A (the root MCS).
- If Gphi in A and t' is non-domain with t < t', the forward_G condition requires phi in A.
- This requires Gphi -> phi (T-axiom), which is NOT valid under strict semantics.

The GGp -> Gp issue is the **second** reason the extension to Q is wrong, independent of the T-axiom issue. Even if we solved the T-axiom problem (e.g., by using a different default MCS at non-domain points), the density validity problem would remain.

---

## 6. Summary of Key Findings

1. **Burgess constructs models over subsets of Q, not over Q itself.** The domain is whatever the counterexample elimination produces. It may not be dense.

2. **GGp -> Gp IS valid on Q under strict semantics.** The user's semantic analysis is correct.

3. **The issue does NOT arise in Burgess's construction** because the model domain is not forced to be dense.

4. **All relevant sources use strict semantics.** Burgess, Verbrugge, and BX all use strict < (irreflexive). There is no reflexive/strict mismatch.

5. **The extended_limit_f problem is real and has TWO independent causes:**
   - (a) T-axiom: Gphi -> phi needed at non-domain points, not valid under strict semantics.
   - (b) Density: GGp -> Gp valid on Q, not necessarily derivable in BX.

6. **The fix is to work over the chronicle domain X, not over all of Q.** Either use a subtype `{ x : Rat // x in limit_dom }` or (per report 08's Option B) make the domain dense by adding density steps -- but Option B should ONLY be done if BX includes the density axiom GGp -> Gp.

7. **For BX (which does NOT include GGp -> Gp): use the subtype approach (Option A), not the density approach (Option B).** Report 08's recommendation of Option B is INCORRECT for BX. Option B would make GGp -> Gp valid in the model, breaking completeness.

---

## 7. Correction to Report 08's Recommendation

Report 08 recommended Option B (make the domain dense) as the "cleanest approach." This recommendation is **wrong for BX**:

> "Option B (dense chronicle domain) is the cleanest approach because: 1. It requires no algebraic structure on a subtype. 2. It produces a model over Q directly."

Making the domain dense would make GGp -> Gp valid in the model. Since BX does not include GGp -> Gp, the truth lemma would fail for formulas involving this principle. Specifically:

- If neg(GGp -> Gp) is consistent with BX, we should be able to falsify GGp -> Gp.
- But on a dense model, GGp -> Gp is valid, so we cannot falsify it.
- Therefore the construction fails to produce a countermodel for neg(GGp -> Gp).

**The correct approach is Option A (subtype-indexed model) or Option C (quotient).** The domain must be exactly what the counterexample elimination produces -- no more, no less.

The algebraic structure concern for Option A (that the subtype may not form an AddCommGroup) is a real engineering challenge, but it is the mathematically correct approach. The BFMCS type may need to be generalized to work over arbitrary countable linear orders rather than requiring an AddCommGroup structure.
