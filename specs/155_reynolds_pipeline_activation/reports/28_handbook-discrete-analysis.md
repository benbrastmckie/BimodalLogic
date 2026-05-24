# Comparative Analysis: How Textbook Treatments Handle Discrete Orders in Temporal Expressive Completeness

## Summary

The central blocker (phase-3e-handoff) is that the Lean formalization's K-minus argument assumes cofinal failure **strictly below** c_inf, which fails in discrete orders where c_inf is a carrier point with isolated failure. This report traces how five sources handle the discrete vs. dense distinction to identify the correct approach.

**Key finding**: The discrete case (integer time) uses a completely different proof technique from the dense/Dedekind-complete case. Kamp's theorem and the GHR game argument are irrelevant to integer time. Integer-time expressive completeness is proved by direct syntactic separation (Reynolds eliminations), not by games. The game-based proof in GHR93/GHR94 Ch.12 is for **general linear time with gaps** and inherently assumes gap structure -- which discrete orders lack.

---

## 1. GHR94 Volume 1, Chapter 9: Basic Concepts

**Citation**: Gabbay, Hodkinson & Reynolds (1994), *Temporal Logic: Mathematical Foundations and Computational Aspects*, Vol. 1, Chapter 9.

### Strict vs. non-strict Since/Until

Chapter 9 defines Since and Until with **strict** semantics throughout (pp. 1-2):

> S(p, q) is true at t iff there exists s < t such that p holds at s and q holds at all y with s < y < t.

The open interval (s, t) is used -- this is the standard strict formulation. No non-strict variant is introduced.

### Density assumption

None. Chapter 9 works over arbitrary classes of linear flows of time. The separation-implies-completeness theorem (Theorem 9.3.1) is stated for **any** class of linear flows. The chapter explicitly notes (p. 12, Definition 9.1.7):

> "the language of Since and Until is expressively complete over integer time and real number flow of time but not over rational numbers time."

### K-minus definition

K-minus does not appear in Chapter 9. It is introduced in Chapter 10.

### Approach to discrete orders

Chapter 9 establishes the general framework. It does **not** prove completeness for any specific flow -- it only shows that separation implies completeness and vice versa over linear time. The actual proofs are deferred to Chapter 10 (integers, Dedekind complete) and Chapters 11-12 (general linear time).

---

## 2. GHR94 Volume 1, Chapter 10: Integer and Real Time

**Citation**: Gabbay, Hodkinson & Reynolds (1994), Vol. 1, Chapter 10.

### This is the source for discrete completeness

Chapter 10 proves expressive completeness of {U, S} over **two** classes:
1. Section 10.2: Integer (discrete Dedekind complete) time
2. Section 10.3: General Dedekind complete time

**These use entirely different proof techniques.**

### Section 10.2: Integer time -- direct syntactic elimination

The integer proof uses **direct syntactic rewriting** of formulas to separated form. No games, no K-minus, no cofinal failure arguments. The method is:

1. Identify 8 cases of nested U-inside-S (Lemma 10.2.3, cases 1-8).
2. For each case, provide an equivalent separated formula.
3. Induct on junction depth to show all formulas can be separated.

**Key observation** (p. 6, Section 10.2): The eliminations for integer time are **simpler** than for dense time because K-plus and K-minus are trivial:

> "In integer time, these connectives are not very interesting for K+q = K-q = top."

This is the crucial point: K-minus (= "q holds arbitrarily close from the past") is **always true** in discrete orders because every point has an immediate predecessor. The entire K-minus machinery is introduced in Section 10.3 specifically for the Dedekind-complete case where gaps and limit behavior matter.

### Section 10.3: Dedekind complete time -- K-minus enters

K-minus is defined (p. 10, Definition 10.3.1):

> K-q = not S(top, not q), meaning q is true arbitrarily close to t from the past.

And Gamma-minus is defined as:

> Gamma-(B) = not K-(not B) and K+(not B)

These connectives are introduced specifically to handle the Dedekind complete case, where suprema of sets may not be in the flow but are limits. The 8 integer eliminations are supplemented by 4 additional K-plus/K-minus eliminations (Lemma 10.3.8) and 4 Gamma-plus/Gamma-minus eliminations (Lemma 10.3.10), for a total of 16 elimination cases.

The chapter introduces a special atom `c` interpreted "relatively densely" (true somewhere in every half-open interval) to relate K-plus to U. This is unnecessary for integer time.

### Strict vs. non-strict Since/Until

Only strict semantics throughout. The open interval (s, t) in S(A, B) is the standard strict form.

### Density assumption

Section 10.2 makes **no** density assumption -- it works exactly on discrete (integer) time. Section 10.3 assumes **Dedekind completeness** (every bounded set has a supremum), which is a completeness property orthogonal to density. The integers are Dedekind complete but not dense.

### Does it define K-minus differently for discrete vs. dense?

Yes, implicitly. For integer time, K-minus is identically true (p. 9):

> "In integer time, these connectives [K+, K-] are not very interesting for K+q = K-q = top."

So K-minus plays no role in the integer proof. It only matters for the Dedekind complete case where limit points exist.

---

## 3. GHR94 Volume 1, Chapter 12: Games-Based Proof

**Citation**: Gabbay, Hodkinson & Reynolds (1994), Vol. 1, Chapter 12.

### Scope

Chapter 12 proves expressive completeness of {U, S, U', S'} (Stavi connectives) over **arbitrary linear time**. This is the game-based proof corresponding to GHR93 Theorem 3. It also discusses gaps in detail (Section 12.2), gap-talking connectives (Section 12.3), and when U, S alone suffice (Section 12.4).

### Key result for discrete orders

Lemma 12.4.1 (p. 5):

> "Over flows of time with only isolated gaps, {U, S} is expressively complete."

This is because over such flows, U'(A, B) can be defined using gamma-0-plus (the isolated gap detector), which is already expressible in {U, S}.

**For Dedekind complete flows (including integers), there are NO gaps at all**, so U' and S' are trivially equivalent to bottom. This is confirmed by Venema (Section 5 below).

### The game argument

Section 12.8 presents the game-based proof of Theorem 11.5.4 (= Theorem 3 of GHR93). The game G_{n,r}(M, xy; N, x'y') is defined on **general linear temporal structures** (Definition 12.8.11). The proof's structure:

1. Define rank-r "r-definable gaps" (Definition 12.8.3).
2. Define relativized connectives U-sharp, S-sharp etc. that evaluate at gaps.
3. Define left(A, D) and right(A, D) formulas to express gap properties.
4. Prove the main theorem (12.8.15): forward game strategies imply backward game strategies.

### Where gaps are essential

In Cases III and IV of Theorem 12.8.15 (pp. 30-32), the proof handles the situation where a_n is a gap. The K-minus formula appears indirectly through the formula delta = A and left(B, D), which encodes "B-sharp holds at the gap defined by D on the left." The proof constructs a gap e_n matching a_n using the U' connective (via the left function).

**For discrete (integer) time, Cases III and IV never arise** because there are no gaps. Only Cases I and II are needed, and these use standard U (not U') and do not involve K-minus or cofinal failure arguments.

### Density assumption

The game proof makes **no** density assumption. It works for arbitrary linear orders. But the complexity of the proof arises from handling gaps -- which are absent in discrete orders.

---

## 4. Hodkinson & Reynolds 2006, Handbook Chapter 11

**Citation**: Hodkinson, I. & Reynolds, M. (2006), "Temporal Logic", in *Handbook of Modal Logic*, Chapter 11.

### Available content

The digitized version contains only the Table of Contents and Section 1 (Introduction). Sections 2-6 (pp. 658-712), which would contain the technical treatment, are not included in the source PDF.

### What can be inferred from the Table of Contents

- Section 4.4: "Linear flows -- Kamp's theorem" (p. 685) -- likely discusses Kamp's result for Dedekind complete time.
- Section 4.6: "Separation" (p. 687) -- likely covers the separation approach.
- No section title specifically mentions "discrete" or "integer" time.

### From the Introduction

The introduction notes (p. 2):

> "The natural numbers are the dominant model of linear time, though dense and continuous and indeed arbitrary linear orders have found their way in."

This suggests the chapter may discuss natural number time, but without access to the technical sections, specific handling of discrete orders cannot be determined from this source.

---

## 5. Venema 1993: Completeness via Completeness

**Citation**: Venema, Y. (1993), "Completeness via Completeness: Since and Until", in *Diamonds and Defaults*, Synthese Library 229.

### Strict vs. non-strict Since/Until

Standard strict semantics (Section 2.2, p. 3):

> U(phi, psi) holds at t if there is v > t such that phi holds at v and for all u with t < u < v, psi holds at u.

### Density assumption

**None explicitly.** Venema works over well-ordered frames and the natural numbers (omega). These are **discrete** structures.

### Crucial insight: Stavi connectives are trivially bottom on well-orders

Lemma 4.1 (p. 7):

> "Every BW-model is definably well-ordered."

The proof shows that in any model satisfying BW (Burgess axioms + well-ordering axiom W), the Stavi connective U'(psi, chi) is equivalent to **bottom**. This is because axiom W forces Fp -> U(p, not p), which means there can be no gap where chi holds up to the gap but fails arbitrarily soon after -- the well-ordering axiom prevents exactly this behavior.

This confirms: **on well-ordered (and in particular discrete) flows, U' and S' are vacuously false, and K-minus is trivially true.** The game argument with its gap machinery is entirely irrelevant.

### Approach to integer/omega completeness

Venema's completeness proof for omega proceeds through a chain:

1. Start with a BW-consistent formula.
2. Build a linear model (Burgess completeness, Theorem 3.5).
3. Show the model is definably well-ordered (Lemma 4.1, using W to kill U').
4. Apply Doets' theorem (3.8): definably well-ordered models have n-equivalents in WO.
5. Transfer satisfiability to a well-ordered model.

For omega specifically (Theorem 4.3): add the discreteness axiom D = (F top -> U(top, bot)) and (P top -> S(top, bot)), which forces the flow to be isomorphic to omega.

### Does it handle discrete orders in the game argument?

There is no game argument in Venema. The proof is entirely algebraic/model-theoretic, using Doets' theorem about definably well-ordered structures. The key technique is the Stavi-connective-killing argument: axiom W makes all Stavi formulas trivially false, which means S'U' expressive completeness reduces to SU expressive completeness on well-orders.

---

## 6. Comparative Summary

| Source | Discrete proof technique | Game argument? | K-minus role | Density needed? |
|--------|------------------------|----------------|-------------|-----------------|
| GHR94 Ch. 9 | Framework only | No | Not defined | No |
| GHR94 Ch. 10 | Syntactic elimination (Sec 10.2) | No | Trivially true on integers | No |
| GHR94 Ch. 12 | Game (Sec 12.8) | Yes, for general linear time | Via left(A,D), gaps only | No, but gaps needed |
| HR06 Ch. 11 | (Unavailable sections) | Unknown | Unknown | Unknown |
| Venema 1993 | Doets + BW axioms | No | U'/S' killed by axiom W | No |

---

## 7. Implications for the Lean Formalization Blocker

### The blocker is a category error

The phase-3e-handoff identifies a blocker where the K-minus argument fails because `cont_holds_cross` can fail **at** c_inf (not strictly below) in discrete orders. This is not a bug that needs patching -- it reveals that the K-minus / cofinal-failure / pigeonhole pattern is **the wrong proof technique for discrete orders**.

The GHR game argument (Chapter 12, Section 12.8) is designed for **general linear time with gaps**. Its Cases III and IV (the gap cases) use the Stavi connectives and the left/right formulas -- machinery that is vacuous on discrete time. The K-minus formula K-q = not S(top, not q) means "q holds arbitrarily close from the past," which is trivially true for all q on integer time (every point has an immediate predecessor).

### What the textbooks actually do for discrete time

Two approaches exist:

**Approach A (GHR94 Ch. 10, Sec 10.2)**: Direct syntactic separation via Reynolds eliminations. This is a purely syntactic rewriting procedure that takes any formula and produces a separated (= boolean combination of pure past, pure present, pure future) equivalent. The 8 elimination cases handle all combinations of U-nested-under-S and vice versa. No games, no K-minus, no cofinal arguments.

**Approach B (Venema 1993)**: Model-theoretic transfer. Build a BW-model, show it is definably well-ordered (killing Stavi connectives with axiom W), use Doets' theorem to find an n-equivalent well-ordered model. Again, no games or K-minus.

### What this means for the formalization

The formalization should NOT try to fix the K-minus argument for discrete orders. Instead:

1. **If the goal is expressive completeness over integer/omega time**: Implement the Reynolds syntactic elimination approach from Ch. 10 Sec 10.2. This is a direct rewriting algorithm that is entirely constructive and does not involve games.

2. **If the goal is expressive completeness over Dedekind complete time**: The K-minus machinery from Ch. 10 Sec 10.3 is correct, but it assumes Dedekind completeness (bounded sets have suprema). The formalization's `LinearOrder carrier` without additional assumptions falls between discrete and Dedekind complete -- it has neither gaps (discrete) nor suprema (Dedekind complete), which is why the proof breaks.

3. **If the goal is general linear time**: The full game argument from Ch. 12 / GHR93 with Stavi connectives is needed, and the K-minus / cofinal failure pattern is part of the gap-handling cases (III and IV). But it only activates when there actually are gaps.

### Specific resolution for the h_strict_failure sorry

The handoff notes that `h_strict_failure` is unprovable when c_inf is a carrier point with isolated failure and no carrier points in (s, c_inf). This is correct. In integer time, this can happen because the interval (s, c_inf) might be empty (when c_inf is the immediate successor of s).

**The fix is not to add density or patch the pigeonhole**: it is to recognize that the K-minus argument is only needed in the gap cases, and for discrete orders, the proof should take an entirely different path (syntactic elimination).

If the formalization wants to remain agnostic about discrete vs. dense, it should:
- Add a density hypothesis to the game argument (matching the implicit assumption in GHR93)
- OR bifurcate: handle the discrete case via elimination, the dense/complete case via the game

---

## 8. Specific Citations for Key Claims

1. **K-minus is trivially true on integers**: GHR94 Ch. 10, p. 9: "In integer time, these connectives are not very interesting for K+q = K-q = top."

2. **8 elimination cases suffice for integer separation**: GHR94 Ch. 10, Lemma 10.2.3 (pp. 3-6), 8 cases with explicit equivalences.

3. **16 elimination cases needed for Dedekind complete**: GHR94 Ch. 10, Lemmas 10.3.8 (K-plus/K-minus, 4 cases), 10.3.10 (Gamma, 4 cases), 10.3.11 (S-eliminations, 8 cases).

4. **Stavi connectives are trivially false on well-orders**: Venema 1993, Lemma 4.1 proof: axiom W implies U'(psi, chi) = bottom.

5. **Game Cases III/IV handle gaps only**: GHR94 Ch. 12, Theorem 12.8.15, Cases III and IV (pp. 30-32) begin with "a_n is a gap defined on the left by some formula D."

6. **Integer completeness is a special case of isolated-gap completeness**: GHR94 Ch. 12, Lemma 12.4.1: "Over flows of time with only isolated gaps, {U, S} is expressively complete." Integers have no gaps at all, so this applies a fortiori.

7. **Expressive completeness of {U,S} over integers**: GHR94 Ch. 10, Theorem 10.2.10 (p. 8): "The language {U, S} is expressively complete over integer time." Proved via syntactic separation (Theorem 10.2.9).
