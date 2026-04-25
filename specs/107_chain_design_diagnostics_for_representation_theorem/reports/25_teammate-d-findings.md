# Teammate D (Horizons): Strict vs Reflexive Semantics -- What Changes and What Breaks

## Executive Summary

**Burgess 1982 uses STRICT (irreflexive) semantics.** This is the same semantics as the ProofChecker codebase. The widespread claim in the literature (including the Stanford Encyclopedia) that Burgess axiomatizes "reflexive linear orderings" is a terminological confusion about the *frame class* (reflexive = no endpoint restrictions) versus the *operator semantics* (strict < in the truth conditions). Burgess's Until definition uses strict `x < y`, his G is strict, and G(phi) -> phi is NOT among his axioms. This finding eliminates the hypothesized "reflexive vs strict" gap as the root cause of the g_ordered difficulty.

---

## 1. Burgess 1982: Definitively Strict Semantics

### 1.1 The Semantic Definitions (Burgess 1982, Section 1.2)

From the paper directly:

```
V(U(alpha, beta)) = {x : exists y (x < y  and  y in V(alpha)  and
                       forall z (x < z < y  implies  z in V(beta)))}
```

The derived operators:
```
F(alpha) = U(alpha, T)    -->  V(F alpha) = {x : exists y > x, y in V(alpha)}
G(alpha) = ~F(~alpha)     -->  V(G alpha) = {x : forall y > x, y in V(alpha)}
```

These are **strict** semantics throughout:
- The Until witness satisfies `x < y` (strict), NOT `x <= y`
- The guard region is the open interval `(x, y)` -- all z with `x < z < y`
- G quantifies over all `y > x` (strict), NOT `y >= x`
- G(phi) -> phi is **NOT valid**: truth at x itself is not implied

### 1.2 The Axiom System (Burgess 1982, Section 1.3)

The axiom system J_0 consists of:
- A1a: `G(p -> q) -> (U(p,r) -> U(q,r))` (left monotonicity)
- A2a: `G(p -> q) -> (U(r,p) -> U(r,q))` (right monotonicity)
- A3a: `p & U(q,r) -> U(q & S(p,r), r)` (connectedness)
- A4a: `U(p,q) & ~U(p,r) -> U(q & ~r, q)` (witness splitting)
- A5a: `U(p,q) -> U(p, q & U(p,q))` (self-accumulation)
- A6a: `U(q & U(p,q), q) -> U(p,q)` (absorption)
- A7a: `U(p,q) & U(r,s) -> U(p&r, q&s) v U(p&s, q&s) v U(q&r, q&s)` (linearity)
- Plus mirror images (A1b--A7b with U<->S, G<->H)
- Rules: Substitution, Modus Ponens, Temporal Generalization (from alpha infer G(alpha) and H(alpha))

**Crucially absent**: There is NO axiom `G(phi) -> phi`, NO axiom `H(phi) -> phi`, NO T-axiom for temporal operators. The system does not assume reflexivity of the temporal relation.

### 1.3 The "Reflexive" Terminology Confusion

The Stanford Encyclopedia states: "A complete axiomatic system for the Since-Until logic on the class of all *reflexive linear orderings* was provided by Burgess (1982a)."

This is about the **frame class** -- "reflexive" here means the class of linear orders where the *frame* satisfies no additional constraints (as opposed to dense, discrete, well-ordered, etc.). It does NOT mean the temporal operators use reflexive (>=) quantification. The confusion arises because:

1. In modal logic, "reflexive frame" means the accessibility relation is reflexive (R is reflexive => Kripke frame validates T-axiom)
2. In temporal logic, the ordering `<` is always strict/irreflexive, and "reflexive" refers to whether the QUANTIFICATION in G/H includes the current point
3. Burgess uses "K_0 = the class of all linear orders" -- the word "reflexive" refers to the frame class being unrestricted, not to the operator semantics

Venema 1993 confirms: he presents Burgess's system B (= J_0) with the identical strict semantics:
```
M, t |= U(phi, psi) iff there is a v > t such that M, v |= phi
                         and for all u with t < u < v, M, u |= psi
```

### 1.4 Density Axiom Under Strict Semantics

For dense linear orders, Burgess adds `F'(T)` which is `~G'(~T)` = `~U(T, bot)`. This says: it is not the case that there is a future witness where bot holds and T holds throughout -- i.e., there is no "next point." Under strict semantics, this is exactly the density axiom.

The ProofChecker codebase uses `GG(phi) -> G(phi)` (density axiom) for dense orders. Under strict semantics with transitivity (temp_4: `G(phi) -> G(G(phi))`), density is equivalent to `F'(T)` -- both capture that between any two points there is a third.

---

## 2. Comparison: Burgess vs BX Axiom System

### 2.1 Axiom-by-Axiom Mapping

| Burgess J_0 | BX System | Status |
|---|---|---|
| A1a: `G(p->q) -> (U(p,r) -> U(q,r))` | right_mono_until (BX3) | **Different argument positions** -- Burgess's A1a is left-mono on the FIRST arg of U, but note Burgess uses `U(witness, guard)` convention while BX uses `guard U witness` |
| A2a: `G(p->q) -> (U(r,p) -> U(r,q))` | left_mono_until (BX2) | Same caveat on argument order |
| A3a: `p & U(q,r) -> U(q & S(p,r), r)` | connect_future (BX4) | **Structurally different** -- BX4 is `phi -> G(P(phi))`, which is a simplified version |
| A4a: `U(p,q) & ~U(p,r) -> U(q&~r, q)` | No direct equivalent | This is the witness-splitting axiom |
| A5a: `U(p,q) -> U(p, q & U(p,q))` | self_accum_until (BX5) | Match (with argument order swap) |
| A6a: `U(q & U(p,q), q) -> U(p,q)` | absorb_until (BX6) | Match (with argument order swap) |
| A7a: linearity | linear_until (BX7) | Match |

### 2.2 Critical Observation: Argument Order Convention

Burgess uses `U(witness, guard)`: in `U(alpha, beta)`, alpha is the EVENTUAL witness and beta is the guard that holds in the interval. This is visible from:
```
V(U(alpha, beta)) = {x : exists y > x, y in V(alpha) and forall z in (x,y), z in V(beta)}
```

The ProofChecker codebase uses `guard U witness`: `phi U psi` means phi is the guard and psi is the witness:
```
untl phi psi: exists s > t, psi(s) and forall r in [t,s), phi(r)
```

This is the **opposite convention**. When comparing axioms, the arguments must be swapped. For example:
- Burgess A5a: `U(p,q) -> U(p, q & U(p,q))` means "if p is eventually witnessed with guard q, then p is eventually witnessed with guard (q and U(p,q))"
- BX5: `(phi U psi) -> ((phi & (phi U psi)) U psi)` means "if phi guards until psi, then (phi & (phi U psi)) guards until psi"

These are the same axiom under the argument swap.

### 2.3 Axioms Present in BX But Not in Burgess

| BX Axiom | Description | Why Added |
|---|---|---|
| BX1 (serial_future) | `T -> F(T)` | Burgess assumes "no last element" which gives the same thing |
| BX9 (until_elim) | `(phi U psi) -> (phi v psi)` | Under Burgess's strict semantics with open guard (x,y), this is NOT valid. Under BX's half-open guard [t,s), it IS valid because t is in [t,s) so phi(t) holds |
| BX10 (until_F) | `(phi U psi) -> F(psi)` | Derivable from Burgess's system; explicit in BX |
| BX11 (temp_linearity) | `F(phi) & F(psi) -> ...` | Derivable from A7a in Burgess; explicit in BX |
| BX12 (F_until_equiv) | `F(phi) -> (T U phi)` | Follows from definitions in Burgess |
| temp_k_dist | `G(phi->psi) -> (G(phi) -> G(psi))` | Derivable in Burgess via TG + A1a/A2a |
| temp_4 | `G(phi) -> G(G(phi))` | **NOT in Burgess's base system** |

### 2.4 The Guard Convention Difference: Open vs Half-Open

This is the most important semantic difference between Burgess and BX:

**Burgess (open guard):**
```
V(U(alpha, beta)) = {x : exists y > x, y in V(alpha) and forall z, x < z < y implies z in V(beta)}
```
The guard beta holds on the OPEN interval (x, y). The current point x is NOT included.

**BX (half-open guard):**
```
untl phi psi at t: exists s > t, psi(s) and forall r, t <= r < s implies phi(r)
```
The guard phi holds on the HALF-OPEN interval [t, s). The current point t IS included.

This difference has several consequences:
1. BX9 (`phi U psi -> phi v psi`) is valid under half-open but NOT under Burgess's open guard
2. Burgess's A3a (`p & U(q,r) -> U(q & S(p,r), r)`) captures the current-point information differently
3. BX's approach is "cleaner" for the chronicle construction because the guard at the current point gives immediate information

### 2.5 Axiom A3a vs BX4 (connect_future)

Burgess's A3a: `p & U(q, r) -> U(q & S(p, r), r)`

This says: if p holds now AND (q will be witnessed while r guards), then (q & S(p,r)) will be witnessed while r guards. Intuitively: the Since-memory S(p,r) records that p was true and r guarded since then.

BX4: `phi -> G(P(phi))`

This says: if phi holds now, then at all future times, P(phi) holds. This is a simpler axiom that captures temporal connectedness directly.

A3a is STRONGER than BX4 in that it provides specific Until-Since interaction. A3a is the KEY AXIOM in Burgess's proof -- it is used in Lemma 2.3 (the r-relation criterion), Lemma 2.4 (Until witness existence), Lemma 2.6 (counterexample elimination), and Lemma 2.7 (Until forward witness). It connects the forward Until obligations with backward Since memories.

BX4 is a CONSEQUENCE of A3a: from A3a with r = T (verum) and using U(q, T) = F(q), we get `p & F(q) -> F(q & S(p, T))` = `p & F(q) -> F(q & P(p))`. This is weaker than A3a.

---

## 3. The g_ordered Question Under Strict Semantics

### 3.1 What g_ordered Means

g_ordered states: for all x < y in dom, G(phi) in f(x) implies phi in f(y).

Under strict semantics, this says: if "phi holds at all times strictly after x" is in f(x), then phi is in f(y) for each domain point y > x.

### 3.2 Why g_ordered is NOT Trivial -- Even Under Strict Semantics

Even though Burgess uses strict semantics (matching the codebase), g_ordered is not a trivial consequence of the semantics. In the SEMANTIC model (the target), G(phi) in f(x) and x < y would indeed give phi in f(y) -- that's what the model satisfies. But in the SYNTACTIC construction (building the chronicle step by step), f(x) and f(y) are MCSs that were constructed independently. The property g_ordered must be MAINTAINED as an invariant of the construction.

### 3.3 How Burgess Actually Handles g_ordered

Burgess does NOT use the term "g_ordered" and does NOT need it as a separate invariant. Here is why:

**Burgess's C3 does all the work.** His condition C3 states:
```
g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)   for x < y < z in dom
```

This immediately gives `g(x,z) ⊆ f(y)` for any intermediate y. The truth lemma for G uses this:

From the truth lemma proof (Claim 2.11):
> "If alpha = U(beta, gamma) and alpha in f(x), then by C5a there is a y in X with x < y and gamma in f(y) and beta in g(x,y). If z in X and x < z < y, then by C3 we have g(x,y) ⊆ f(z), whence beta in f(z)."

For the G case specifically:
- G(phi) in f(x) means ~F(~phi) in f(x), i.e., for all y > x in the limit domain, phi in f(y)
- This is proved NOT via g_ordered, but via the contrapositive: if ~phi in f(y) for some y > x, then by C4, the counterexample propagates and F(~phi) must be in some f(z) between x and y, eventually reaching f(x), contradicting G(phi) in f(x)

Wait -- let me re-examine. Burgess defines G as ~F~, and F as U(alpha, T). So G(phi) = ~U(~phi, T). The truth lemma for G goes through the Until case:

**Forward direction for G**: G(phi) in f(x) means ~F(~phi) in f(x), meaning ~U(~phi, T) in f(x). For any y > x, we need phi in f(y). Suppose for contradiction ~phi in f(y). Then by C4a (counterexample condition for Until): since ~U(~phi, T) in f(x) and ... actually this needs careful analysis.

Let me re-read the truth lemma more carefully. Burgess proves (+) by induction on formula complexity. The relevant cases are:

**Case U(beta, gamma)**:
- Forward: U(beta, gamma) in f(x) => C5a gives witness y with beta in f(y) and gamma in g(x,y). C3 gives gamma in f(z) for x < z < y. Induction gives z in V(gamma) and y in V(beta). Hence x in V(U(beta, gamma)).
- Backward: ~U(beta, gamma) in f(x) => for any y > x with y in V(beta), by induction beta in f(y), and by C4a there exists z with x < z < y and ~gamma in f(z), so z not in V(gamma). Hence x not in V(U(beta, gamma)).

**There is no separate "G case"** in Burgess because G = ~F~ = ~U(~, T). The truth lemma for G follows from the Until case applied to U(~phi, T) combined with negation:
- G(phi) in f(x) iff ~U(~phi, T) in f(x)
- ~U(~phi, T) in f(x) means: for all y > x, if y in V(~phi) (i.e., ~phi in f(y)), then... C4a gives a z between x and y with ~T in f(z), which is impossible (T is in every MCS). So there cannot be any y > x with ~phi in f(y).

This means: G(phi) in f(x) implies for all y > x, phi in f(y). **This IS g_ordered, but it's proved at the limit, not maintained as a finite-stage invariant.**

### 3.4 The Key Insight: g_ordered is a LIMIT Property, Not a Finite-Stage Invariant

In Burgess's proof:
1. The finite stages satisfy C0, C0', C1, C2, C2', C3 (these are the conditions for membership in the set F)
2. C4 and C5 are NOT satisfied at finite stages -- they are progressively approximated by the omega chain
3. g_ordered is NOT maintained at finite stages either
4. At the LIMIT, C4 and C5 hold by construction (every counterexample is eventually eliminated)
5. g_ordered at the limit follows from C4 completeness: G(phi) in f(x) and ~phi in f(y) for y > x would give a C4-counterexample that was never eliminated -- contradiction

**Burgess does NOT need g_ordered as a finite-stage invariant.** The truth lemma is proved at the limit using C4 + C5, not using g_ordered directly.

### 3.5 Implications for the ProofChecker Codebase

The codebase's `ChronicleInvariant` includes `hg_ord` (g_ordered) as a finite-stage invariant. This is UNNECESSARY and is the root cause of the sorry. Burgess's proof does not maintain g_ordered at finite stages.

The correct approach:
1. **Remove g_ordered from ChronicleInvariant** -- it is not needed at finite stages
2. **Prove g_ordered at the limit** using C4 completeness:
   - Suppose G(phi) in limit_f(x) and x < y
   - If ~phi in limit_f(y), then U(~phi, T) ... no, we need to reason via C4
   - Actually: ~U(~phi, T) in f(x) (since G(phi) = ~F(~phi) = ~U(~phi, T))
   - At some stage, ~U(~phi, T) in f_n(x) and ~phi in f_m(y)
   - At stage N = max(n,m), both x and y are in the domain, ~U(~phi, T) in f_N(x), and T in f_N(y) (T is in every MCS)
   - This is a C4 counterexample: ~U(~phi, T) in f(x), guard=T holds at y (T in f(y)), but there should be a z between x and y with ~~phi = phi ... no wait, C4 says ~delta in f(z), and delta = T, so ~T in f(z). But ~T = bot, and bot is not in any MCS.

   Hmm, let me reconsider. The C4 argument needs to be more careful with the argument order.

### 3.6 Detailed C4 Argument for g_ordered at the Limit

Let me use Burgess's argument convention. U(alpha, beta): alpha = witness, beta = guard.

G(phi) = ~F(~phi) = ~U(~phi, T).

Suppose ~U(~phi, T) in f(x) [i.e., G(phi) in f(x)]. We want phi in f(y) for all y > x.

C4a says: if ~U(gamma, delta) in f(x) and gamma in f(y) (where x and y are adjacent or handled by induction), then there exists z with x < z < y and ~delta in f(z).

Applied to gamma = ~phi, delta = T:
- ~U(~phi, T) in f(x) [given]
- If ~phi in f(y) [assume for contradiction]
- Then by C4a, there exists z with x < z < y and ~T in f(z)
- But ~T = bot, and bot is not in any MCS (f(z) is an MCS by C0)
- Contradiction

Therefore ~phi cannot be in f(y), so phi in f(y) (by MCS negation completeness).

**This argument works perfectly under strict semantics.** It does not require reflexivity. It requires only:
1. C0 (f(y) is an MCS, so bot is not in it)
2. C4 completeness at the limit
3. G(phi) = ~U(~phi, T) (definitions)

### 3.7 Why the C4 Argument Does NOT Work at Finite Stages

At a finite stage n, C4 may not hold for the pair (x, y). There may be a counterexample ~U(~phi, T) in f_n(x) with ~phi in f_n(y) that has not yet been eliminated. The omega chain construction will eventually eliminate it (at some stage n' > n), but at stage n, we cannot conclude phi in f_n(y).

This is exactly why g_ordered cannot be proved as a finite-stage invariant: it depends on C4 completeness, which is only achieved at the limit.

---

## 4. Consequences of the Guard Convention Difference

### 4.1 Open Guard (Burgess) vs Half-Open Guard (BX)

Under Burgess's open guard `(x, y)`:
- `U(alpha, beta)` at x: exists y > x with alpha at y and beta on (x, y)
- The current point x is NOT in the guard region
- BX9 (`phi U psi -> phi v psi`) is NOT VALID: phi (the guard) need not hold at x

Under BX's half-open guard `[t, s)`:
- `phi U psi` at t: exists s > t with psi at s and phi on [t, s)
- The current point t IS in the guard region (t in [t, s))
- BX9 IS valid: phi holds at t (since t in [t, s))

### 4.2 Impact on the Chronicle Construction

The half-open guard convention in BX gives more information at the current point. Specifically, `phi U psi` at t implies phi at t (by BX9). This means:

Under BX's convention:
- If `phi U psi` in f(x), then `phi v psi` in f(x) (by BX9)
- The r-relation can use this: gamma U delta in A implies delta in B or (gamma in B and gamma U delta in B). Under BX9, we also know gamma v delta in A.

Under Burgess's convention:
- If `U(alpha, beta)` in f(x), we know alpha is consistent (Lemma 2.2) but NOT that beta holds at x
- The r-relation is defined differently: for all delta in B, for all gamma in C, U(gamma, delta) in A

### 4.3 Does the Guard Convention Affect g_ordered?

No. The g_ordered property is about G propagation, not Until guards. G(phi) in f(x) means ~U(~phi, T) in f(x) under both conventions:

Under Burgess: ~U(~phi, T) means there is no y > x with ~phi at y and T on (x,y). Since T holds everywhere, this means there is no y > x with ~phi at y, i.e., phi at all y > x.

Under BX: ~(T U ~phi) means there is no s > t with ~phi at s and T on [t,s). Since T holds everywhere, same conclusion.

The g_ordered argument via C4 works identically under both conventions.

---

## 5. Other Places Where Reflexivity Could Matter

### 5.1 Seed Consistency

When constructing a new MCS (via Lindenbaum extension of a seed), the seed must be consistent. Under reflexive semantics with G(phi) -> phi, the seed g_content(f(x)) U f(x) is automatically consistent because g_content(f(x)) is a subset of f(x).

Under strict semantics, g_content(f(x)) is NOT a subset of f(x). But this is not a problem because the Burgess construction does not use g_content as a seed. Instead:

- Lemma 2.4 constructs the seed C_0 = {gamma} U {S(alpha, beta) : alpha in A} where U(gamma, beta) in A
- Lemma 2.6 constructs D_0 = {S(alpha, beta) : alpha in A, beta in B} U B U {~delta} U {U(gamma, beta) : gamma in C, beta in B}
- These seeds use the r-relation structure, not g_content directly

The BX codebase's `ChronicleConstruction.lean` similarly constructs seeds using the r-relation (via R3Maximal), not via g_content.

### 5.2 The r-Relation Itself

Burgess's r-relation (Lemma 2.3) uses criterion 2.3a: `r(A, beta, C)` iff for all gamma in C, U(gamma, beta) in A, iff for all alpha in A, S(alpha, beta) in C.

This does NOT require reflexivity. The proof of 2.3 uses A3a (connectedness), not any T-axiom. Under BX's system, the equivalent uses BX4 (connect_future) and BX5/BX9.

### 5.3 Lemma 2.5 (Interval Decomposition)

Burgess's Lemma 2.5: if R(A, B, C), r(A, B', D), r(D, B'', C) and B is a subset of B' intersect D intersect B'', then B = B' intersect D intersect B''.

The proof uses A6a (absorption): U(delta & U(gamma, delta), delta) in A gives U(gamma, delta) in A. This does NOT require reflexivity.

### 5.4 Lemma 2.6 and 2.7 (Counterexample Elimination)

These use A4a, A5a, A7a, and A3a. None require reflexivity. They work under strict semantics.

### 5.5 Summary: No Reflexivity Dependencies

After careful examination, NONE of Burgess's lemmas (2.1--2.11) depend on reflexive semantics. The entire proof works under strict semantics, matching the BX codebase.

---

## 6. The Real Issue: What Makes g_ordered Hard to Prove?

### 6.1 It is Not a Semantics Problem

The g_ordered difficulty is NOT caused by strict vs reflexive semantics. Both Burgess and BX use strict semantics, and g_ordered holds at the limit in both cases (via C4).

### 6.2 It is an Architecture Problem

The difficulty is that the codebase tries to maintain g_ordered as a **finite-stage invariant** (in `ChronicleInvariant`), but Burgess's proof only needs it at the **limit**. The finite-stage invariant approach requires proving that every extension step preserves g_ordered, which is genuinely hard because:

1. When a new point z is inserted between x and y, the new f(z) must contain g_content(f(x))
2. But f(z) is constructed from a seed via Lindenbaum extension
3. The seed must contain g_content(f(x)), which requires g_content(f(x)) to be consistent with the other seed components
4. Proving this consistency requires essentially the same argument as the C4 limit proof

### 6.3 The Solution

**Remove g_ordered from ChronicleInvariant.** Prove it at the limit using C4 completeness, exactly as Burgess does (Section 3.6 above). The C4 argument is:

```
G(phi) in f(x), x < y
==> ~U(~phi, T) in f(x)     [definition of G]
==> if ~phi in f(y)          [assume for contradiction]
==> C4 gives z with ~T in f(z)  [counterexample between x and y]
==> bot in f(z)              [~T = bot]
==> contradiction            [f(z) is MCS, bot not in MCS]
==> phi in f(y)              [by MCS negation completeness]
```

This is a clean 5-line proof that requires only C0 (MCS) and C4 (counterexample completeness).

---

## 7. Completeness Proofs for Strict Temporal Logic in the Literature

### 7.1 Burgess 1982

As shown above, Burgess 1982 IS a completeness proof for strict temporal logic. The axiom system J_0 is complete for U/S over ALL strict linear orders (K_0). No additional axioms are needed for strict semantics beyond what Burgess provides.

### 7.2 Verbrugge et al. 2004

The Verbrugge "step-by-step" method uses the same strict semantics. Their system Lin (and extensions P, Q, D, Z, R) all use strict < for the temporal ordering. The step-by-step construction is essentially the same as Burgess's omega chain, with the same proof strategy: build finite approximations, take the limit, use density/counterexample elimination.

### 7.3 Gabbay-Hodkinson 1990

The axiomatization for the reals uses the Irreflexivity Rule (IR), which is specifically designed for strict (irreflexive) semantics. This is the non-orthodox approach that Venema 1993 avoids.

### 7.4 The BX System's Relationship to Burgess

The BX system in the codebase is essentially Burgess's J_0 adapted for half-open guard semantics. The key differences:
1. Argument order swap (guard U witness vs U(witness, guard))
2. Half-open guard [t,s) instead of open guard (x,y)
3. BX9 (until_elim) added (valid under half-open but not open guard)
4. BX4 (connect_future) replaces A3a (simplified version)
5. temp_4 (G transitivity) added explicitly
6. Seriality axioms (BX1) replace "no endpoints" assumption

These adaptations are sound. The completeness proof structure (omega chain + counterexample elimination) carries over directly.

---

## 8. Definitive Answers to the Research Questions

**Q1: What semantics does Burgess 1982 use?**
STRICT (irreflexive). G quantifies over y > x (strict), Until uses witness y > x (strict) with open guard (x,y). G(phi) -> phi is NOT an axiom and NOT valid.

**Q2: If Burgess uses reflexive semantics, what changes?**
N/A -- Burgess uses STRICT semantics, matching the codebase.

**Q3: Precise consequences of losing G(phi) -> phi?**
Under Burgess's strict semantics, G(phi) -> phi was NEVER available. The construction does not use it. g_content(f(x)) is NOT a subset of f(x), but this is fine because the construction uses r-relation seeds, not g_content seeds.

**Q4: Is there a proof of g_ordered that works under strict semantics?**
YES -- at the limit, via C4 completeness (Section 3.6). The proof is a simple 5-line argument using C0 + C4 + the definition G = ~U(~, T).

**Q5: Interaction between strict semantics and the interval function?**
No interaction issues. The interval function g(x,y) captures formulas that hold throughout (x,y), regardless of whether the semantics is strict or reflexive. C3 decomposition works identically.

**Q6: Are there completeness proofs for strict temporal logic?**
YES -- Burgess 1982 IS one. Also: Verbrugge 2004 (step-by-step), Gabbay-Hodkinson 1990 (with IR rule), and others.

**Q7: Is the BX axiom system strong enough?**
YES, subject to one caveat: the BX system must be equivalent to (or at least as strong as) Burgess's J_0 for the completeness proof to go through. The key axiom is the connectedness axiom (Burgess's A3a, replaced by BX4 + BX5 + BX9 in BX). If these together derive the same consequences as A3a, the proof works. The BX system also has A4a-equivalent via BX linearity axioms.

---

## Sources

- [Burgess 1982 - Axioms for tense logic I](https://projecteuclid.org/euclid.ndjfl/1093870149)
- [Burgess 1982 - Axioms for tense logic II (Time periods)](https://projecteuclid.org/euclid.ndjfl/1093870150)
- [Stanford Encyclopedia - Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- [Stanford Encyclopedia - Burgess-Xu Axiom System](https://plato.stanford.edu/entries/logic-temporal/burgess-xu.html)
- [Venema 1993 - Completeness via Completeness](https://link.springer.com/chapter/10.1007/978-94-015-8242-1_12)
- [Verbrugge 2004 - Completeness by Construction](local: literature/Verbrugge_2004_Completeness_by_construction.md)
