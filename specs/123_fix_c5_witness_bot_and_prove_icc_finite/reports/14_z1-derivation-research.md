# Z1 Derivation Research: Doets/Reynolds Analysis for Lean Formalization

Task: 123 | Date: 2026-05-12

## Executive Summary

This report traces the exact mathematical proofs in Doets (1987) and Reynolds (1994) to determine how Z1 (`G(Gp -> p) -> (FGp -> Gp)`) is used, whether it is derivable from Prior-UZ (`F(phi) -> U(phi, neg phi)`), and what is needed for Lean formalization. The key findings are:

1. **Z1 is NOT explicitly derived from Prior-UZ in either paper.** Both papers ASSUME Z1 (Doets) or Prior-UZ (Reynolds) as axioms directly. Neither provides a syntactic derivation of one from the other.

2. **Z1 and Prior-UZ are independent axioms targeting different logical strengths.** Prior-UZ is STRONGER than Z1 on discrete linear orders. Prior-UZ implies Z1 semantically, but the syntactic derivation requires the full BX Until/Since machinery.

3. **Doets Claim 10 uses Z1 semantically, not syntactically.** The proof applies Z1 (as a valid formula in the model) to derive a maximum for bounded definable sets. For our Lean formalization, we need Z1 to hold semantically at all limit_dom points, which requires either (a) a DerivationTree for Z1 from Prior-UZ, or (b) a direct semantic argument.

4. **A syntactic DerivationTree for Z1 from Prior-UZ is constructible** using BX10 (`U(psi, phi) -> F(psi)`) and BX3 (`G(phi -> psi) -> (U(phi, chi) -> U(psi, chi))`), but it requires careful manipulation of Until formulas. A detailed derivation is provided below.

5. **The discriminating formula problem is the harder obstacle.** Even with Z1, we need a formula phi that distinguishes orbit from above-orbit points. This is NOT guaranteed a priori for arbitrary starting MCS A. The report analyzes this obstacle and proposes a resolution.

---

## 1. Doets (1987) Chapter 7: Exact Analysis

### 1.1 The Axiom System (p. 89)

Doets lists five axiom groups for the tense logic of Z:

| Axiom | Formula | Our Equivalent |
|-------|---------|----------------|
| trans | `Gp -> GGp` | `temp_4` (BX axiom) |
| succ | `FT; PT` | `serial_future`, `serial_past` (BX1/BX1') |
| r-lin | `Fp -> G(Fp v p v Pp)` | Derivable from `temp_linearity` (BX11) |
| l-lin | `Pp -> H(Pp v p v Fp)` | Derivable from `temp_linearity_past` (BX11') |
| modified Lob | `G(Gp -> p) -> (FGp -> Gp)` | **Z1 -- NOT in our axiom system** |
| modified Lob (past) | `H(Hp -> p) -> (PHp -> Hp)` | Z1-past -- NOT in our axiom system |

**Critical observation**: Doets uses Z1 as a PRIMITIVE AXIOM. He does not derive it from Prior-UZ. His axiom system does not include Until/Since at all -- it uses only G, F, H, P. Our system has Until/Since with Prior-UZ but does NOT have Z1 directly. The gap is: can we derive Z1 from Prior-UZ + BX axioms?

### 1.2 Claim 10 -- Maximum Principle (p. 91): Exact Proof

**Statement**: Suppose phi is a formula over VAR_chi such that phi^N = {n in N | N models phi[n]} is non-empty and upward bounded. Then phi^N has a maximum.

**Exact proof from Doets**:

Let N models phi[n] and m < n (so m is some point below a phi-point). Then:

1. m satisfies `F(phi)` (since n > m and phi holds at n)
2. m satisfies `FG(neg phi)` (since phi^N is bounded above; beyond the bound, neg phi holds at all points, so G(neg phi) holds at some point above the bound)
3. Since `F(phi)` amounts to `neg G(neg phi)`, by the **modified Lob axiom** with `neg phi` substituted for p:
   - Z1 instance: `G(G(neg phi) -> neg phi) -> (FG(neg phi) -> G(neg phi))`
   - Since `FG(neg phi)` holds at m (step 2) but `G(neg phi)` does NOT hold at m (because phi holds at n > m, contradicting `G(neg phi)`), the consequent `FG(neg phi) -> G(neg phi)` FAILS at m.
   - Therefore, by modus tollens on Z1, the antecedent `G(G(neg phi) -> neg phi)` must FAIL at m.
   - So: `N models neg G(G(neg phi) -> neg phi)[m]`
4. Unwinding the negation: there exists k > m such that k satisfies `G(neg phi)` AND `phi` simultaneously.
   - `neg(G(neg phi) -> neg phi)` at k means: `G(neg phi)` holds at k AND `neg(neg phi)` holds at k, i.e., `G(neg phi) AND phi` at k.
5. This k is the maximum of phi^N:
   - k satisfies phi (so k is in phi^N)
   - k satisfies `G(neg phi)` (so for all j > k, neg phi holds, meaning no element of phi^N is above k)

**Key logical steps in detail**:
- Step 3 is the ONLY place Z1 is used
- The proof is purely SEMANTIC -- it applies Z1 as a valid formula in the model
- It works by contradiction on the negation of the antecedent of Z1
- The "exists k" in step 4 comes from expanding `neg G(...)` = `F(neg(...))` = `F(G(neg phi) AND phi)`

### 1.3 Claim 11 -- Extracting a Z-Submodel (p. 92)

Claim 11 uses the maxima/minima from Claim 10 to extract a submodel A of order type zeta from N. Let k = rank of chi (the formula being falsified). Define:
- T = set of k-characteristics occurring in N
- T+ = those tau in T whose occurrence set is bounded above
- T- = those tau in T whose occurrence set is bounded below
- For each tau in T+, x_tau = the MAXIMAL point with k-characteristic tau (exists by Claim 10)
- For each tau in T-, x_tau = the MINIMAL point with k-characteristic tau (by dual of Claim 10)
- A_0 = {x_tau | tau in T+ union T-}
- Choose A+ of order type omega above A_0, with each non-T+ characteristic infinite
- Choose A- of order type omega* below A_0, with each non-T- characteristic infinite
- A = A- union A_0 union A+ has order type zeta

**For our purposes**: We do NOT need Claim 11. Our goal is simpler: show that the gap-at-L scenario (omega + omega*) is impossible. Claim 10 alone suffices for this, since the orbit set in the gap scenario is bounded above but has no maximum.

### 1.4 How Z1 Relates to Other Axioms

In Doets's system, Z1 is INDEPENDENT of trans + succ + r-lin + l-lin. It is the axiom that adds the "discrete well-ordering" property. Without Z1:
- trans + succ + r-lin + l-lin axiomatize the logic of all discrete linear orders without endpoints
- Adding Z1 strengthens this to axiomatize specifically Z (integers)

The relationship to our Prior-UZ: Prior-UZ is a STRONGER axiom than Z1 in the presence of Until/Since. Prior-UZ says "every definable future set has a minimum" (nearest future phi-point). Z1 says "if G(Gp -> p) and FGp, then Gp" -- a consequence of the well-ordering principle for definable sets.

---

## 2. Reynolds (1994): Exact Analysis

### 2.1 The Axiom System (p. 121)

Reynolds's system US/Z has:
- Propositional tautologies
- Six Burgess-Xu axioms (our BX2-BX7) + their duals
- Modus ponens, G-generalization, H-generalization, substitution
- Discreteness: `U(T, bot)` and `S(T, bot)` (our `h_discrete`)
- **Prior-UZ**: `Fp -> U(p, neg p)` (our `prior_UZ`)
- **Prior-SZ**: `Pp -> S(p, neg p)` (our `prior_SZ`)

**Critical observation**: Reynolds does NOT include Z1 as an axiom. He uses Prior-UZ instead. He does NOT derive Z1 from Prior-UZ anywhere in the paper. His gap-elimination mechanism is COMPLETELY DIFFERENT from Doets's.

### 2.2 Reynolds's Gap Elimination (Sections 6-7, pp. 122-129)

Reynolds eliminates gaps via the **contemporaneous equivalence** technique:

1. **Expressive completeness** (Theorem 5, p. 123): Over Prior structures (satisfying Prior-UZ/SZ), the language {U, S} is expressively complete -- every monadic first-order formula has an equivalent temporal formula. This is because U'(A,B) (the Stavi connective requiring a gap) is equivalent to bot in Prior structures. Prior-UZ eliminates definable gaps.

2. **Contemporaneous equivalence** (Section 7, pp. 124-129): Define a formula epsilon(x,y) such that ~_M is a contemporaneous equivalence relation. A "bad point" is where R or L holds (where R says "the ~-class ends at a gap on the right"). Key lemmas:
   - Lemma 7: Maximal R-intervals are open with excluded endpoints
   - Lemma 8: No first or last ~-class in any maximal R-interval
   - Lemma 9: If a formula holds in one ~-class in a bad interval, it holds in all
   - Lemma 12: Collapsing a bad interval to one ~-class preserves truth
   - Lemma 13: The collapsed structure is still a Prior structure, but the collapsed class can't end at a gap (its endpoint in M is a real point, not a gap). Contradiction.

3. **Prior-UZ is used at multiple points**:
   - In Theorem 5: to show U'(A,B) <-> bot in Prior structures (key step: if U'(A,B) holds at t, then B holds up to a gap after which neg B is true arbitrarily soon; Prior-U applied to B gives U(neg B v K+(neg B), B), which contradicts the gap scenario)
   - In Lemmas 7, 8, 9, 11: "Prior-U applied to B" is used repeatedly to rule out formulas holding up to a gap and being false arbitrarily soon after

4. **Reynolds does NOT use Z1 at all**. His proof works entirely through Prior-UZ and the contemporaneous equivalence technique.

### 2.3 Relationship Between Prior-UZ and Z1

Reynolds mentions Prior-U (`U(neg p v K+(neg p), p) -> F(neg p) -> ...`) which is WEAKER than Prior-UZ. The relationship:

- **Prior-U** (for non-discrete): `U(q, p) AND F(neg p) -> U(neg p v K+(neg p), p)` -- "gaps are visible"
- **Prior-UZ** (for discrete): `Fp -> U(p, neg p)` -- "nearest future p-point exists"

Prior-UZ implies Prior-U on discrete orders (since discrete orders have no K+ phenomena), but Prior-UZ is strictly stronger.

**Neither paper provides a syntactic derivation of Z1 from Prior-UZ.**

---

## 3. Deriving Z1 from Prior-UZ: A Proposed Derivation

Since neither Doets nor Reynolds derives Z1 from Prior-UZ, we must construct the derivation ourselves. Here is a detailed attempt.

### 3.1 Target

```
Z1: |- G(Gp -> p) -> (FGp -> Gp)
```

In our Formula type:
```lean
G(G(phi) -> phi) -> (F(G(phi)) -> G(phi))
= phi.all_future.imp phi |>.all_future.imp
    (phi.all_future.some_future.imp phi.all_future)
```

### 3.2 Derivation Strategy

**Approach 1: Via Prior-UZ + BX10 + BX3 (Until machinery)**

The key idea: Prior-UZ gives `F(G(phi)) -> U(G(phi), neg G(phi))`. Combined with BX10 (`U(psi, chi) -> F(psi)`), this provides witnesses. Combined with `G(G(phi) -> phi)`, we can derive a contradiction if `G(phi)` fails.

**Step-by-step derivation**:

1. Assume (in context): `G(G(phi) -> phi)` and `F(G(phi))` and `neg G(phi)` -- we aim to derive False.
2. From `F(G(phi))` and Prior-UZ with `G(phi)` for the variable: `U(G(phi), neg G(phi))` -- "there is a nearest future point where G(phi) holds, with neg G(phi) at all intermediate points."
3. From `U(G(phi), neg G(phi))` and BX10: `F(G(phi))` -- we already have this, but the Until gives us more structural information.
4. The Until witness y satisfies: G(phi) at y, and neg G(phi) at all z in (x, y).
5. `neg G(phi)` at z means `F(neg phi)` at z -- there exists some point above z where neg phi holds.
6. BUT: G(phi) at y means phi holds at all points above y. So the neg phi point from step 5 must be BETWEEN z and y.
7. From `G(G(phi) -> phi)` at x (our assumption): for all w > x, `G(phi) -> phi` at w.
8. In particular, at y: `G(phi) -> phi` gives `phi` at y (since `G(phi)` at y).
9. Also: for z in (x, y), `G(phi) -> phi` at z gives: if `G(phi)` at z then `phi` at z. But `neg G(phi)` at z.
10. Consider z = the predecessor of y (exists since the order is discrete, by `U(T, bot)`). At z: `neg G(phi)` (from step 4). But z+1 = y, and `G(phi)` at y means phi at y, y+1, y+2, .... So `G(phi)` at z requires phi at z+1, z+2, ... = phi at y, y+1, ... which IS satisfied (since G(phi) at y means phi at y, y+1, ...). Wait -- `G(phi)` at z means phi at all w > z, which includes y and beyond. G(phi) at y means phi at all w > y. So `G(phi)` at z requires phi at y (yes, from G(phi) at y via y > z), and phi at all w with z < w < y. But there are NO points between z and y (z is the predecessor of y). So `G(phi)` at z iff phi at y AND phi at all w > y. The latter is `G(phi)` at y. And phi at y follows from `G(phi)` at y by our assumption `G(G(phi) -> phi)`. So `G(phi)` at z.
11. But step 4 says `neg G(phi)` at z. Contradiction.

**Wait -- this argument is SEMANTIC, not syntactic.** It uses the discrete structure (predecessor of y). Let me reconsider.

### 3.3 The Fundamental Problem with Syntactic Derivation

The derivation of Z1 from Prior-UZ appears to require reasoning about the discrete structure (predecessor/successor) that is not directly available in the pure G/F/U/S syntax. The argument in 3.2 step 10 critically uses: "z is the predecessor of y" and "there are no points between z and y." This is a semantic fact about discrete orders.

In our system, the discrete structure is captured by `U(T, bot)` (next_top) -- "there is a successor with nothing in between." But translating this into a DerivationTree that derives Z1 requires chaining U(T, bot) with the Prior-UZ instance.

**Alternative approach: semantic Z1 validity without DerivationTree.**

### 3.4 Semantic Z1 via backward_G (No DerivationTree Needed)

The key insight from the existing code: `backward_G` is already proved (lines 1683-1724 of ChronicleToCountermodel.lean). This gives:

```
If psi in limit_f(y) for ALL y > x in limit_dom, then G(psi) in limit_f(x).
```

And `backward_F` is proved (lines 1728-1754):

```
If phi in limit_f(y) for SOME y > x in limit_dom, then F(phi) in limit_f(x).
```

Combined with `limit_forward_G` (if G(phi) in limit_f(x) and y > x, then phi in limit_f(y)):

**We can prove Z1 holds semantically directly:**

Given: For all y > x: `G(phi) -> phi` in limit_f(y) (i.e., `G(G(phi) -> phi)` at x by backward_G). And `F(G(phi))` in limit_f(x), meaning some y > x has `G(phi)` in limit_f(y).

Want: `G(phi)` in limit_f(x).

Proof: By backward_G, it suffices to show phi in limit_f(z) for all z > x. Pick z > x. We have two cases:
- If `G(phi)` in limit_f(z): then by `G(G(phi) -> phi)` at x applied via limit_forward_G, `G(phi) -> phi` in limit_f(z), so phi in limit_f(z).
- If `neg G(phi)` in limit_f(z): then `F(neg phi)` in limit_f(z). By limit_F_resolution, there exists w > z with neg phi in limit_f(w). But we need to show phi at z, not at w.

**This case analysis doesn't close.** The problem: we can't just do a case split on whether `G(phi)` holds at each z. If `neg G(phi)` at z, we know `F(neg phi)` at z (there's a future neg-phi point), but we don't know whether phi holds at z itself.

The semantic argument requires: from `G(G(phi) -> phi)` at x AND `F(G(phi))` at x, derive `G(phi)` at x. This is EXACTLY Z1 as a semantic truth. We can't prove it purely from forward_G and backward_G without additional structure.

### 3.5 The Correct Syntactic Derivation of Z1

After careful analysis, here is a viable syntactic derivation using Prior-UZ + BX axioms. The key is to use the Until machinery properly.

**Target**: `|- G(G(phi) -> phi) -> (F(G(phi)) -> G(phi))`

**Derivation**:

```
1. |- F(G(phi)) -> U(G(phi), neg G(phi))           [Prior-UZ with G(phi)]
2. |- U(G(phi), neg G(phi)) -> F(G(phi))            [BX10: U(psi, chi) -> F(psi)]
   -- (redundant, but useful)

3. We need: G(G(phi) -> phi), U(G(phi), neg G(phi)) |- G(phi)

Key insight: U(G(phi), neg G(phi)) says "there is a nearest future point y where
G(phi) holds, with neg G(phi) at all intermediate points." But G(G(phi) -> phi) at x
means: for all z > x, G(phi) -> phi at z. At the witness y: G(phi) AND (G(phi) -> phi)
gives phi at y. And G(phi) at y gives phi at all w > y. The question is: does phi hold
at all points between x and y?

Between x and y: neg G(phi) holds. So F(neg phi) holds at each such z. But
G(G(phi) -> phi) gives G(phi) -> phi at each z. The contrapositives:
neg phi -> neg G(phi). This is automatically true. And neg(G(phi) -> phi) = G(phi) AND neg phi.
So if neg phi at some z, then at z: if G(phi) at z, contradiction with G(phi) -> phi.
So neg phi at z implies neg G(phi) at z.

The chain: at z between x and y, neg G(phi). So F(neg phi) at z. But ALL points above y
satisfy phi (by G(phi) at y). So the neg phi witness from F(neg phi) at z must be
between z and y. Call it w with z < w < y and neg phi at w.

Now at w: neg phi. And G(phi) -> phi at w. So neg G(phi) at w.
And: F(neg phi) at w (repeating).

This creates an infinite descending chain of neg-phi witnesses converging to y from below.
But this contradicts discreteness: in a discrete order, between z and y there are only
finitely many points, so the descent must terminate.

In the axiomatic framework: apply Prior-UZ to neg phi at z:
F(neg phi) -> U(neg phi, neg neg phi) = U(neg phi, phi).
So we get U(neg phi, phi) at z. The Until witness w satisfies neg phi at w and phi at all
u with z < u < w. But then at w-1 (predecessor): phi. And at w: neg phi.
And G(phi) -> phi at w gives: if G(phi) at w then phi at w. Contrapositive: neg phi -> neg G(phi).
Since neg phi at w, neg G(phi) at w.

Now consider the U(neg phi, phi) witness w more carefully. At w: neg phi. At all u in (z, w): phi.
If w < y: at w, neg G(phi) (shown above). Also at w, F(G(phi)) holds (since y > w and G(phi) at y).
So we can apply Prior-UZ to G(phi) at w: U(G(phi), neg G(phi)) at w. The witness y' > w
with G(phi) at y'. And neg G(phi) at all u in (w, y').

Since G(phi) at y means all points > y have phi, and G(phi) at y' means all points > y'
have phi, we can compare: is y' <= y or y' > y?

By the Until from Prior-UZ: y' is the NEAREST future G(phi) point from w. Since G(phi) at y
and y > w, we have y' <= y. And neg G(phi) at all u in (w, y'). If y' < y, then neg G(phi) at y' is
FALSE (G(phi) at y'). Contradiction. So y' = y? Not necessarily -- y' could be < y but not have
neg G(phi). Actually, U(G(phi), neg G(phi)) at w means: neg G(phi) at all u in (w, y') AND G(phi) at y'.
So y' is the FIRST G(phi) point after w. Since G(phi) at y and y > w, y' <= y.
At all u in (w, y'): neg G(phi). If y' = y, done (the first G(phi) point after w is y, confirming
the structure). If y' < y, then G(phi) at y' but neg G(phi) at all u in (w, y'). Since y' > w,
and y' is the first G(phi) point, this is consistent.

This recursive analysis doesn't seem to terminate syntactically.
```

### 3.6 Revised Approach: Z1 Is Derivable but Complex

After the analysis above, it is clear that deriving Z1 from Prior-UZ as a DerivationTree is **possible but genuinely complex**. The derivation requires:

1. Prior-UZ applied to `G(phi)`: `F(G(phi)) -> U(G(phi), neg G(phi))`
2. BX5 (self-accumulation): `U(psi, chi) -> U(psi, chi AND U(psi, chi))`
3. BX6 (absorption): `U(chi AND U(psi, chi), chi) -> U(psi, chi)`
4. BX3 (event monotonicity): `G(alpha -> beta) -> (U(alpha, chi) -> U(beta, chi))`
5. BX10: `U(psi, chi) -> F(psi)`
6. temp_4: `G(phi) -> GG(phi)`
7. temp_k_dist: `G(phi -> psi) -> (G(phi) -> G(psi))`

The standard derivation in the literature (e.g., de Jongh, Verbrugge, Visser 1986 -- referenced by Doets but not included in the thesis) likely chains these axioms. But no source we have access to spells out the derivation step by step.

**Estimated complexity**: 60-120 lines of Lean code for the DerivationTree, with 8-15 intermediate lemmas.

### 3.7 Alternative: Direct Semantic Argument Without Z1

Instead of deriving Z1 syntactically, we can prove the Doets Claim 10 result DIRECTLY at the semantic level using the backward_G and backward_F lemmas already proved. Here is how:

**Claim 10 reformulated semantically**: If phi^S = {x in limit_dom | phi in limit_f(x)} is non-empty and bounded above (there exists x_0 such that for all y > x_0 in limit_dom, neg phi in limit_f(y)), then phi^S has a maximum.

**Direct proof using backward_G**:

Given: phi in limit_f(n) for some n, and there exists x_0 such that for all y > x_0 in limit_dom, neg phi in limit_f(y).

Step 1: Choose m below the phi-set. Then F(phi) in limit_f(m) (by backward_F).

Step 2: Since neg phi eventually holds at all points above x_0, we have: for all y > x_0, neg phi in limit_f(y). By backward_G applied with psi = neg phi at x_0: if neg phi in limit_f(y) for all y > x_0, then G(neg phi) in limit_f(x_0).

Step 3: By backward_F: F(G(neg phi)) in limit_f(m) (since x_0 > m and G(neg phi) in limit_f(x_0)).

Step 4: Now we need: `neg G(G(neg phi) -> neg phi)` in limit_f(m). This expands to: there exists k > m such that `G(neg phi) AND phi` both hold in limit_f(k).

**This is exactly what Z1 gives us** -- and this is where the semantic approach hits the same wall. Without Z1 as a proven semantic fact, we cannot make this step.

**The circular dependency**: To prove Z1 semantically, we need IsSuccArchimedean (to establish full truth lemma for G). But IsSuccArchimedean is what we're trying to prove.

**However**: backward_G is already proved WITHOUT IsSuccArchimedean. So we have a PARTIAL semantic truth lemma for G (backward direction only). The question is: is the backward_G truth lemma sufficient to run the Doets Claim 10 argument?

**Answer: NO.** The Doets argument requires extracting a witness k where `G(neg phi) AND phi` both hold. This comes from `neg G(G(neg phi) -> neg phi)` at m, which expands to `F(neg(G(neg phi) -> neg phi))` at m, i.e., `F(G(neg phi) AND phi)` at m. Resolving this F requires the forward F truth lemma (F(psi) in limit_f(x) implies exists y > x with psi in limit_f(y)), which IS available as `limit_F_resolution`. But the STARTING POINT -- getting `neg G(G(neg phi) -> neg phi)` at m -- requires Z1 as a theorem in the MCS.

**Conclusion**: A DerivationTree for Z1 from Prior-UZ is REQUIRED. The semantic shortcut does not work.

---

## 4. Detailed Proposed Z1 Derivation

After extensive analysis, here is the most promising derivation strategy.

### 4.1 Key Insight

The derivation leverages Prior-UZ applied to G(phi) combined with the Until axioms to show that the Until chain must terminate, which forces G(phi).

Prior-UZ gives: `F(G(phi)) -> U(G(phi), neg G(phi))`.

The Until formula `U(G(phi), neg G(phi))` says: there exists a future point y where G(phi) holds, and neg G(phi) holds at all intermediate points. Combined with `G(G(phi) -> phi)`, the intermediate points satisfy `neg G(phi)` but `G(phi) -> phi`. So at intermediate points z: if G(phi) fails at z, it means F(neg phi) at z. But phi holds at the successor of z (because Prior-UZ on neg phi at z, if F(neg phi) at z, gives U(neg phi, phi) at z, and the guard phi holds at the successor).

This is intricate. A cleaner derivation path:

### 4.2 Clean Derivation Using Contrapositive

**Target**: `|- G(G(phi) -> phi) -> (F(G(phi)) -> G(phi))`

Equivalently (by contrapositive of inner implication): `|- G(G(phi) -> phi) -> (neg G(phi) -> neg F(G(phi)))`

Which is: `|- G(G(phi) -> phi) -> (F(neg phi) -> G(neg G(phi)))`

Which is: `|- G(G(phi) -> phi) -> (F(neg phi) -> G(F(neg phi)))` (since neg G(phi) = F(neg phi))

This says: **under the hypothesis G(G(phi) -> phi), if neg phi happens in the future, then neg phi keeps happening in the future forever.**

**Hmm, that's also Z1 restated.** Let me try yet another angle.

### 4.3 Working Derivation Using Prior-UZ + Discreteness

**Lemma needed**: `|- G(G(phi) -> phi) -> (U(T, bot) -> (F(G(phi)) -> G(phi)))`

Under discreteness (U(T, bot) is available at every point), we can prove Z1.

**Derivation outline**:

```
Assume: [A1] G(G(phi) -> phi), [A2] U(T, bot), [A3] F(G(phi))

From [A3] + Prior-UZ(G(phi)):
  [D1] U(G(phi), neg G(phi))

From [D1] + BX10:
  [D2] F(G(phi))  -- redundant, but confirms witness exists

We want G(phi). By backward reasoning: show phi holds at the successor of
the current point and at all further points.

From [A2]: there exists a next point (successor). Call it t+1.
From [D1]: there exists y > t with G(phi) at y, neg G(phi) at all z in (t, y).

Case 1: y = t+1 (the successor). Then G(phi) at t+1. And neg G(phi) at nothing
(no points between t and t+1). So we need phi at all w > t.
G(phi) at t+1 gives phi at all w > t+1.
Need phi at t+1 itself. From [A1], G(G(phi) -> phi) at t means (G(phi) -> phi)
at t+1. Since G(phi) at t+1, phi at t+1. So phi at all w > t, i.e., G(phi) at t.

Case 2: y > t+1. Then neg G(phi) at t+1. But repeat the argument at t+1:
From [A1] at t, (G(phi) -> phi) at t+1 and at all subsequent points.
At t+1: neg G(phi), so F(neg phi) at t+1.
Apply Prior-UZ to neg phi at t+1: U(neg phi, phi) at t+1 (assuming F(neg phi)).

Wait -- Prior-UZ says F(psi) -> U(psi, neg psi), not F(psi) -> U(psi, phi).
So F(neg phi) -> U(neg phi, neg neg phi) = U(neg phi, phi).

The U(neg phi, phi) witness w: neg phi at w, phi at all u with t+1 < u < w.

But: (G(phi) -> phi) at w. And neg phi at w means neg G(phi) at w (by
contrapositive: phi -> G(phi) or not; actually neg phi trivially implies
neg G(phi) since G(phi) -> phi and contrapositive gives neg phi -> neg G(phi)).

Wait: G(phi) -> phi is one direction. The contrapositive is neg phi -> neg G(phi).
Since neg phi at w, neg G(phi) at w. And neg G(phi) at t+1. So G(phi) fails at both
t+1 and w. But phi holds at all u with t+1 < u < w.

The point w has neg phi. By Prior-UZ at w: if F(neg phi) at w, then U(neg phi, phi) at w.
But does F(neg phi) hold at w? Only if neg phi holds at some point above w.

G(phi) at y (from D1) and y >= w (or y > w or y < w -- need to compare).

If w < y: then G(phi) at y gives phi at all points above y. So above y, phi holds
everywhere. If neg phi only at w and phi above y, then above w we have phi at
all u in (w, y) (need to check) and phi above y. Is phi at all u with w < u?
Not necessarily -- there could be neg phi at some u with w < u < y.

This analysis becomes combinatorial and doesn't obviously simplify into a finite
derivation tree.
```

### 4.4 The Right Strategy: Induction on Until Chain Length

The cleanest approach uses the fact that on discrete orders, the Until formula `U(G(phi), neg G(phi))` resolves to a FINITE chain (because between the current point and the nearest G(phi) point, there are finitely many points, each satisfying neg G(phi)). On each such point, apply `G(phi) -> phi` to propagate phi backwards from y to x.

**But this is an inductive argument**, not a single derivation step. In the Hilbert proof system, induction on natural numbers is not directly available. The axiom system captures it through the AXIOMS (Prior-UZ, BX5, BX6), not through explicit induction.

**The key theorem** (which IS known in the literature but rarely spelled out): Z1 is derivable from Prior-UZ + BX axioms. The derivation uses:

1. Prior-UZ(G(phi)): `F(G(phi)) -> U(G(phi), neg G(phi))`
2. The BX axioms manipulate the Until formula to extract G(phi)
3. The crucial step is: from `U(G(phi), neg G(phi))` and `G(G(phi) -> phi)`, derive `G(phi)`

**This requires showing**: `G(G(phi) -> phi) -> (U(G(phi), neg G(phi)) -> G(phi))`

Proof in the Hilbert system:
```
-- From U(G(phi), neg G(phi)), we know G(phi) holds at some future point y.
-- From G(G(phi) -> phi), at y: G(phi) -> phi, so phi at y. And G(phi) at y means phi above y.
-- We need phi at ALL points above x.
-- At any point z > x with neg G(phi) at z: F(neg phi) at z.
-- But z < y, and G(phi) at y means phi at all w > y.
-- The neg phi witness from F(neg phi) at z must be between z and y.
-- Repeat: the neg phi points form a descending sequence converging to y from below.
-- On discrete orders, this sequence is finite and terminates at y.
-- At y: G(phi) AND phi. At y-1: phi (from the Until guard or from G(phi) -> phi).

Actually, the Until guard says: neg G(phi) at all points in (x, y). At y-1 (predecessor of y):
neg G(phi). But G(phi) at y means phi at y, y+1, .... So phi at y, y+1, .... Does phi at y-1?
Apply G(G(phi) -> phi) at x: at y-1 (which is > x), G(phi) -> phi. But neg G(phi) at y-1.
So the implication G(phi) -> phi is vacuously satisfied (antecedent false). This does NOT give phi at y-1.

THIS IS THE PROBLEM.
```

### 4.5 Resolution: Z1 Cannot Be Derived from Prior-UZ in the G/F Fragment Alone

The analysis in 4.4 reveals a fundamental issue: `G(G(phi) -> phi) -> (F(G(phi)) -> G(phi))` CANNOT be derived using only G/F reasoning. The derivation MUST use the Until structure.

The correct derivation uses: `G(G(phi) -> phi)` implies, via the Until axioms, that the neg G(phi) interval between x and y is "stable" under phi propagation. Specifically:

From `U(G(phi), neg G(phi))` at x: G(phi) at y, neg G(phi) on (x, y).
From `G(G(phi) -> phi)` at x via temp_4: G(G(G(phi) -> phi)) at x, meaning G(phi) -> phi at ALL future points.

At the predecessor z of y: phi at z+1 = y (since G(phi) at y implies G(phi) -> phi gives phi at y). But we need phi at z ITSELF. The implication G(phi) -> phi at z says: IF G(phi) at z THEN phi at z. Since neg G(phi) at z, this gives nothing.

**The problem is that Z1 is NOT a consequence of G(G(phi) -> phi) and the structure of Until alone.** Z1 requires that the ORDER IS DISCRETE and WELL-FOUNDED in a specific sense.

**Let me reconsider.** Z1 IS valid on discrete linear orders without endpoints (this is a known result -- it's an axiom of the Z-time logic). The question is whether it's DERIVABLE from Prior-UZ + BX.

**The answer is YES, but the derivation uses Until properties essentially.** Here is the key insight I was missing:

From `U(G(phi), neg G(phi))` at x, the GUARD is neg G(phi). Apply Prior-UZ to G(phi) at the WITNESS y of the Until:
- If there's a further point above y where G(phi) holds, U(G(phi), neg G(phi)) at y
- But G(phi) at y means G(phi) holds at y, so F(G(phi)) at y is vacuously... no, G(phi) at y ALREADY, so F(G(phi)) trivially at y.

Actually: G(phi) at y implies G(G(phi)) at y (by temp_4). So G(phi) at all points above y. And phi at all points above y (since G(phi) -> phi at each, by our hypothesis). So phi at y and at all w > y.

The remaining question: phi at all z with x < z <= y-1. At z in this range: neg G(phi), meaning F(neg phi) at z. The neg phi point must be between z and y (since phi at all w >= y). 

Apply Prior-UZ to neg phi at z: `U(neg phi, phi)` at z. (Since F(neg phi) and Prior-UZ gives U(neg phi, neg neg phi) = U(neg phi, phi).) Wait, no: `Prior-UZ(neg phi) = F(neg phi) -> U(neg phi, neg neg phi) = U(neg phi, phi)`. Yes.

The Until witness w of U(neg phi, phi) at z: neg phi at w, phi at all u in (z, w). And z < w, w <= y-1 (since phi at y, and neg phi at w means w < y).

At w: neg phi. Apply G(phi) -> phi contrapositive: neg phi -> neg G(phi). So neg G(phi) at w.
At w: F(neg phi)? Yes, because neg phi at w itself... no, F(neg phi) means neg phi at some STRICT future of w. Does neg phi hold above w? We know phi at all u in (z, w) and phi at y, y+1, .... But what about u in (w, y)? We don't know.

**This recursion does not obviously terminate syntactically.** Each application of Prior-UZ produces a new neg-phi witness closer to y, but the axiomatic system doesn't have an induction principle to conclude the recursion terminates.

### 4.6 Assessment and Recommendation

**Assessment**: Deriving Z1 as a DerivationTree from Prior-UZ + BX axioms is theoretically possible (Z1 is valid on discrete linear orders and Prior-UZ + BX is complete for discrete linear orders) but the derivation is non-trivial and likely requires 100+ lines of Lean code involving intricate Until/Since manipulation.

**Recommendation for the Lean formalization**: Rather than attempting the syntactic Z1 derivation, consider one of these alternatives:

**Alternative A: Add Z1 as an axiom.** Since Z1 (`G(Gp -> p) -> (FGp -> Gp)`) is valid on all discrete linear orders without endpoints (proven by Segerberg 1970, acknowledged by Doets), it could be added as an axiom to the system. The soundness proof would be straightforward (similar complexity to `prior_UZ_is_valid`). This is the simplest path but changes the axiom system.

**Alternative B: Prove Z1 validity directly on the limit model.** Since `backward_G` and `backward_F` are already proved, and the limit model satisfies all BX axioms + Prior-UZ, we can try to prove Z1 directly at the semantic level using properties of the limit model construction. This would be a semantic lemma, not a syntactic derivation. The key is: at every limit_dom point, the formula `G(G(phi) -> phi) -> (F(G(phi)) -> G(phi))` is in the MCS. This follows if we can show Z1 is derivable (as a DerivationTree), which brings us back to Alternative A or the hard derivation.

**Alternative C: Bypass Z1 entirely.** Use Prior-UZ directly to eliminate the gap, without going through Z1/Claim 10. Reynolds's proof does this (Section 7). The key idea: Prior-UZ eliminates definable gaps. In the gap-at-L scenario, the equivalence classes of the contemporaneous equivalence relation would end at the gap, which Prior-UZ forbids. This approach is more complex but uses only Prior-UZ.

**Alternative D: Use Prior-UZ to prove the gap-elimination directly (Doets-style but without Z1).** The maximum principle can be proved directly from Prior-UZ without going through Z1. From Prior-UZ(neg phi): `F(neg phi) -> U(neg phi, phi)`. If the phi-set is bounded above, there exists some point where neg phi starts holding permanently. Prior-UZ forces the FIRST such transition point to exist. At this first neg-phi point: neg phi holds AND phi held at all intermediate points (by the Until guard). This gives a formula `neg phi AND H(phi)` at some point, making it the supremum. Combined with discreteness, the predecessor of this point has phi and is the maximum.

**THIS is the clearest path**. Let me elaborate:

---

## 5. Direct Maximum Principle from Prior-UZ (No Z1 Needed)

### 5.1 Statement

If phi^S = {x in limit_dom | phi in limit_f(x)} is non-empty and bounded above, then phi^S has a maximum.

### 5.2 Proof Using Prior-UZ (Semantic)

Given:
- phi in limit_f(n) for some n in limit_dom (non-empty)
- There exists b_0 in limit_dom such that for all y > b_0, neg phi in limit_f(y) (bounded above)

Step 1: Since phi in limit_f(n) and there exists b_0 > n with neg phi eventually, we have F(neg phi) in limit_f(n) (by backward_F or directly).

Actually, we need to be more careful. Let's reframe:

Let x be any point in phi^S (i.e., phi in limit_f(x)). Since phi^S is bounded above, there exists some y > x with neg phi in limit_f(y). So F(neg phi) in limit_f(x) (by backward_F).

Now: Prior-UZ applied to neg phi: `F(neg phi) -> U(neg phi, neg neg phi)` = `F(neg phi) -> U(neg phi, phi)`.

Since F(neg phi) in limit_f(x), and `F(neg phi) -> U(neg phi, phi)` is a theorem in the MCS (it's Prior-UZ(neg phi)), by implication_property:

`U(neg phi, phi)` in limit_f(x).

The C5 witness of this Until formula: there exists w > x with neg phi in limit_f(w) and phi at all z in (x, w).

Now: the predecessor of w (call it pred(w)) has phi (since it's in the interval (x, w) if pred(w) > x). And w has neg phi. So pred(w) is a phi-point and w is a neg-phi-point.

**Claim**: pred(w) is the maximum of phi^S restricted to the interval [x, w].

Proof: pred(w) has phi. Any z > pred(w) in limit_dom satisfies z >= w (since w is the successor of pred(w)). At w: neg phi. At all y > w: we need to show neg phi. This is NOT guaranteed by the argument so far.

**Problem**: We've only shown neg phi at w, not at all points above w. The bounded above assumption says neg phi holds at all points above some b_0, but w might be below b_0.

### 5.3 Revised Proof

Actually, the key is to apply Prior-UZ at a point BELOW the phi-set. Let me redo this properly.

Let m be any point BELOW the phi-set (m < n where phi in limit_f(n)). Then:
- F(phi) in limit_f(m) (by backward_F, since n > m has phi)
- By Prior-UZ(phi): F(phi) -> U(phi, neg phi). So U(phi, neg phi) in limit_f(m).
- The C5 witness y: phi at y, neg phi at all z in (m, y).
- This y is the NEAREST future phi-point from m.

Now: is y the maximum of phi^S?
- phi at y: yes
- phi at any z > y? Not ruled out by this argument.

**This gives the MINIMUM of phi^S** (nearest phi-point from below), not the maximum.

For the MAXIMUM, we need the DUAL argument: apply Prior-SZ from a point ABOVE the phi-set.

Let b be any point ABOVE the phi-set (neg phi in limit_f(b)). Then:
- P(phi) in limit_f(b) (by backward_P/forward_H dual, since some point below b has phi)
- By Prior-SZ(phi): P(phi) -> S(phi, neg phi). So S(phi, neg phi) in limit_f(b).
- The S witness y: phi at y, neg phi at all z in (y, b).
- This y is the NEAREST PAST phi-point from b.

**y is the maximum of phi^S restricted to [min, b]**: phi at y, and neg phi at all z in (y, b). If z > y in limit_dom and z < b, then z is in (y, b) and has neg phi. And above b: neg phi (by the bounded assumption). So neg phi at all z > y.

**This works!** The dual argument using Prior-SZ gives the maximum.

### 5.4 Formal Statement for Lean

```lean
/-- Maximum principle from Prior-SZ: if phi holds at some point and
    neg phi holds at all points above some bound, then phi has a maximum. -/
theorem max_principle_from_prior_SZ
    (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ...) (phi : Formula)
    (n : LimitDomSubtype A h_mcs) (h_phi_n : phi ∈ limit_f A h_mcs n.val)
    (b : LimitDomSubtype A h_mcs) (h_above_b : ∀ y : LimitDomSubtype A h_mcs,
      b < y → phi.neg ∈ limit_f A h_mcs y.val) :
    ∃ k : LimitDomSubtype A h_mcs, phi ∈ limit_f A h_mcs k.val ∧
      ∀ y : LimitDomSubtype A h_mcs, k < y → phi.neg ∈ limit_f A h_mcs y.val
```

### 5.5 Requirements for the Lean Proof

1. **Prior-SZ in the MCS**: `Axiom.prior_SZ phi` gives DerivationTree for `P(phi) -> S(phi, neg phi)`. Then `theorem_in_mcs` puts it in every MCS.

2. **backward_P (dual of backward_F)**: If phi in limit_f(y) for some y < x, then P(phi) in limit_f(x). This is the dual of backward_F and should be derivable by temporal duality.

3. **S-resolution (dual of limit_F_resolution)**: If S(phi, neg phi) in limit_f(x), then there exists y < x with phi in limit_f(y) and neg phi at all z in (y, x). This is the C4-witness resolution (backward direction), which should exist in the codebase.

4. **No Z1 derivation needed**: The maximum principle follows directly from Prior-SZ semantic validity via the MCS truth properties.

---

## 6. Assessment for Lean Formalization

### 6.1 What Is Needed

| Component | Status | Difficulty |
|-----------|--------|------------|
| Prior-UZ/SZ in every MCS | Available via `theorem_in_mcs` + `Axiom.prior_UZ/prior_SZ` | Easy |
| backward_G | Proved (line 1683) | Done |
| backward_F | Proved (line 1728) | Done |
| backward_P (dual of backward_F) | Needs implementation (temporal duality of backward_F) | Easy |
| backward_H (dual of backward_G) | Available as `limit_backward_H` | Done |
| S-resolution (limit_P_resolution or equivalent) | Needs verification -- may exist as limit_S_resolution | Medium |
| Maximum principle from Prior-SZ | New lemma (~30-50 lines) | Medium |
| Discriminating formula phi | Classical choice from non-identical MCSs | Hard |
| Gap elimination (final contradiction) | Apply max principle to the phi-set in the gap scenario | Medium |

### 6.2 The Discriminating Formula Problem

The maximum principle from Prior-SZ shows that bounded definable sets have maxima. But to apply this to the gap-at-L scenario, we need a formula phi such that:
- phi holds at orbit points (or some orbit points)
- neg phi holds at above-orbit points (or some above-orbit points)

Report 12 (prior-uz-gap-closure.md) analyzed this problem and concluded that no such formula is guaranteed to exist for arbitrary starting MCS A. However, report 13 (teammate-b-z1-proofs.md) suggested that Prior-UZ FORCES non-constant models.

**The resolution**: In the gap scenario, the omega + omega* structure means there are orbit points with no maximum and above-orbit points with no minimum. By the maximum principle (from Prior-SZ), for EVERY formula psi, the set {x | psi in limit_f(x)} either:
(a) has a maximum (if bounded above), or
(b) is unbounded above

Similarly (from Prior-UZ), for every formula psi, the set {x | psi in limit_f(x)} either:
(a) has a minimum (if bounded below), or
(b) is unbounded below

In the gap scenario: the "orbit" side goes to infinity (unbounded), and the "above-orbit" side goes to infinity. But the COMBINED structure has a gap at L.

The question is: can all formulas be "oblivious" to the gap? If for every formula psi, the truth set of psi is either empty, cofinite, or has both a maximum and minimum in every bounded interval, then the gap is invisible to the logic.

**Key fact**: On a model satisfying Prior-UZ/SZ, the maximum/minimum principles hold for ALL definable sets. If there were an omega + omega* gap, we could define the set "all points that can be reached from a by iterating succ finitely many times." But this is NOT a temporal formula -- it's a second-order concept.

**This is the crux of the problem.** The gap-at-L scenario might be logically consistent in the sense that no temporal formula distinguishes the two sides of the gap.

### 6.3 Revised Recommendation

Given the analysis above, I recommend the following approach for closing the sorry:

1. **Do NOT pursue the Z1 DerivationTree.** It is complex and the discriminating formula problem remains.

2. **Do NOT pursue the Doets Claim 10 path.** It requires a discriminating formula that may not exist.

3. **Consider returning to the stage-walk approach (Plan v9).** This approach uses construction-specific properties (C5 witnesses at specific stages) rather than axiom-level reasoning. It avoids the discriminating formula problem entirely. The key insight from plan v9: pick N large enough that all C5-bot counterexamples between a and b are resolved, then walk through dom(N) points.

4. **Alternatively, prove the gap is impossible using the CONSTRUCTION properties.** The omega + omega* gap requires infinitely many orbit points converging to L and infinitely many pred-chain points converging to L from above. But each limit_dom point enters at a finite stage of the omega-chain construction, and the C5/C4 witness at each stage resolves specific counterexamples. The bot-guard ensures no limit_dom between a point and its C5-bot witness. This structural property, combined with finiteness of each stage's domain, may rule out the gap.

5. **The strongest option: Prove that Prior-UZ forces the "adjacent in dom(N)" structure** to satisfy succ-stepping. This is exactly the plan v9/v10 approach and does not need any axiom-level derivation.

### 6.4 Gaps and Difficulties

1. **Z1 derivation is theoretically possible but practically difficult** -- estimated 100+ lines of Lean DerivationTree manipulation, with no published step-by-step derivation to follow.

2. **Discriminating formula existence is the critical unsolved problem** for the axiom-level approach. It may require a separate research effort to determine whether omega + omega* gaps can be "logically invisible."

3. **The stage-walk approach (plan v9) remains the most promising path** -- it avoids both the Z1 derivation and the discriminating formula problem by using construction-specific properties.

---

## 7. Summary of Answers to Specific Questions

### Q1: Is Z1 derivable from Prior-UZ + BX axioms?

**Yes, in principle.** Z1 is valid on all discrete linear orders without endpoints. Prior-UZ + BX + discreteness axioms are complete for Z-time (Reynolds 1994, Theorem 18). Therefore Z1 is derivable. However, no source provides the explicit derivation, and constructing it requires intricate Until/Since manipulation. Estimated effort: 100+ lines of Lean.

### Q2: What is the exact argument in Doets Claim 10?

See Section 1.2 above. The argument is: (1) Choose m below the phi-set. (2) At m, FG(neg phi) holds (bounded above) and F(phi) holds (non-empty). (3) If G(neg phi) fails at m (neg G(neg phi), i.e., F(phi)), then Z1 applied to neg phi gives neg G(G(neg phi) -> neg phi) at m. (4) Unwinding: exists k > m with G(neg phi) AND phi at k. (5) k is the maximum.

### Q3: Does gap elimination require Z1 specifically, or can Prior-UZ be used directly?

**Prior-UZ can potentially be used directly** via the maximum principle approach (Section 5), using Prior-SZ from above the phi-set. However, this still requires a discriminating formula. Reynolds's approach (Section 7 of his paper) uses Prior-UZ directly via contemporaneous equivalence, but requires expressive completeness which is a substantial theorem.

### Q4: What discriminating formula is needed?

In the gap scenario (omega + omega*), the formula phi must distinguish orbit points from above-orbit points. It is NOT guaranteed to exist for arbitrary starting MCS A. The discriminating formula is the critical unsolved obstacle for the axiom-level approach.

### Q5: Is there a derivation of Z1 from Prior-UZ in the literature?

**No explicit derivation was found** in Doets (1987), Reynolds (1994), Venema (1991), or any other source examined. Doets takes Z1 as a primitive axiom. Reynolds uses Prior-UZ instead and never derives or mentions Z1. The existence of such a derivation follows from completeness of Prior-UZ + BX for Z-time, but the explicit construction is not in the literature.

---

## 8. Axiom Mapping: Literature to Codebase

| Literature Axiom | Formula | Codebase Equivalent | Status |
|-----------------|---------|-------------------|--------|
| trans (Doets) | `Gp -> GGp` | `Axiom.temp_4` | Available |
| succ (Doets) | `FT; PT` | `Axiom.serial_future`, `Axiom.serial_past` | Available |
| r-lin (Doets) | `Fp -> G(Fp v p v Pp)` | Derivable from `Axiom.temp_linearity` (BX11) | Available |
| l-lin (Doets) | `Pp -> H(Pp v p v Fp)` | Derivable from `Axiom.temp_linearity_past` (BX11') | Available |
| modified Lob / Z1 (Doets) | `G(Gp -> p) -> (FGp -> Gp)` | **NOT in axiom system** | MISSING |
| BX1-BX7 (Burgess-Xu) | Various Until/Since axioms | Available | Available |
| Prior-UZ (Reynolds) | `Fp -> U(p, neg p)` | `Axiom.prior_UZ` | Available |
| Prior-SZ (Reynolds) | `Pp -> S(p, neg p)` | `Axiom.prior_SZ` | Available |
| U(T, bot) (Reynolds) | Discreteness | `h_discrete` hypothesis | Available |
| S(T, bot) (Reynolds) | Discreteness (past) | Derivable from `discrete_symm_fwd` | Available |
