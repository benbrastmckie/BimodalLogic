# Teammate A Findings: Burgess A6a IS BX6 — Notation Confusion Resolved

**Task**: 107 - Chronicle representation theorem
**Date**: 2026-04-24
**Focus**: Can Burgess's A6a be derived from BX axioms?
**Confidence**: DEFINITIVE

---

## Executive Summary

**Burgess A6a IS literally BX6 (absorb_until).** The apparent discrepancy was caused by a notation confusion: Burgess uses `U(event, guard)` while the codebase uses `guard U event`. When the argument order is correctly translated, A6a and BX6 are the same axiom schema.

This means the Lemma 2.5 absorption argument works directly with the existing BX6 axiom. No derivation is needed — it is a direct axiom application.

---

## Part I: The Notation Confusion

### Burgess's Convention: U(event, guard)

Burgess 1982, Section 1.2, defines (p. 370):

> V(U(alpha, beta)) = {x : exists y (x < y AND y in V(alpha) AND forall z (x < z < y => z in V(beta)))}

So in `U(alpha, beta)`:
- **alpha** is the EVENT (what holds at the witness y)
- **beta** is the GUARD (what holds at all intermediate z)

This is confirmed by the abbreviation F(alpha) = U(alpha, T): "there exists a future time where alpha holds" — the first argument is the eventuality.

### Codebase Convention: guard U event

The codebase (Truth.lean, line 127-128) defines:

```
Formula.untl phi psi => exists s, t < s AND truth_at ... s psi AND
    forall r, t <= r -> r < s -> truth_at ... r phi
```

So in `phi U psi`:
- **phi** is the GUARD (what holds at all intermediate r in [t,s))
- **psi** is the EVENT (what holds at the witness s)

### The Conventions Are Swapped

| | First argument | Second argument |
|---|---|---|
| Burgess U(a,b) | event a | guard b |
| Codebase a U b | guard a | event b |

Therefore: **Burgess U_B(alpha, beta) = beta U_C alpha** (swapping the arguments).

---

## Part II: A6a = BX6 Under Translation

### Burgess A6a (original)

```
A6a:  U_B(q AND U_B(p,q), q)  ->  U_B(p,q)
```

### Step-by-step translation to codebase convention

1. `U_B(p, q)` = `q U_C p` (guard=q, event=p)
2. `q AND U_B(p,q)` = `q AND (q U_C p)`
3. `U_B(q AND U_B(p,q), q)` = `q U_C (q AND (q U_C p))`
4. So A6a becomes: `q U_C (q AND (q U_C p))  ->  q U_C p`

### BX6 (absorb_until)

```
BX6:  phi U (phi AND (phi U psi))  ->  phi U psi
```

### Comparison

Setting phi = q, psi = p:

```
BX6:   q U (q AND (q U p))  ->  q U p
A6a:   q U (q AND (q U p))  ->  q U p
```

**These are identical.** A6a IS BX6 under the notation translation.

---

## Part III: Cross-Verification of Other Axiom Correspondences

To confirm the translation is correct, let me verify the other axiom pairs:

### A5a vs BX5

**A5a**: `U_B(p, q) -> U_B(p, q AND U_B(p, q))`

Translation:
- `U_B(p, q)` = `q U_C p`
- `q AND U_B(p, q)` = `q AND (q U_C p)`
- `U_B(p, q AND U_B(p,q))` = `(q AND (q U_C p)) U_C p`

So A5a: `q U_C p -> (q AND (q U_C p)) U_C p`

**BX5**: `(phi U psi) -> ((phi AND (phi U psi)) U psi)`

Setting phi=q, psi=p: `q U p -> (q AND (q U p)) U p`

**Match confirmed.**

### A1a vs BX3 (right monotonicity)

**A1a**: `G(p -> q) -> (U_B(p,r) -> U_B(q,r))`

Translation:
- `U_B(p, r)` = `r U_C p`
- `U_B(q, r)` = `r U_C q`

So A1a: `G(p -> q) -> (r U_C p -> r U_C q)`

**BX3**: `G(phi -> psi) -> ((chi U phi) -> (chi U psi))`

Setting phi=p, psi=q, chi=r: `G(p -> q) -> (r U p -> r U q)`

**Match confirmed.** (BX3 is exactly A1a.)

### A2a vs BX2 (left monotonicity)

**A2a**: `G(p -> q) -> (U_B(r,p) -> U_B(r,q))`

Translation:
- `U_B(r, p)` = `p U_C r`
- `U_B(r, q)` = `q U_C r`

So A2a: `G(p -> q) -> (p U_C r -> q U_C r)`

**BX2**: `(phi -> chi) AND G(phi -> chi) -> ((phi U psi) -> (chi U psi))`

Setting phi=p, chi=q, psi=r: `(p -> q) AND G(p -> q) -> (p U r -> q U r)`

**Near match.** BX2 has the extra conjunct `(p -> q)` alongside `G(p -> q)` because of the half-open guard: the guard interval is [t, s) in BX, which includes the current time t, so we need the implication at the current time too. Burgess's open guard (x < z < y) does not include the endpoints, so A2a needs only `G(p -> q)`.

This difference is a consequence of the guard convention (half-open vs open), NOT a notation issue.

### A7a vs BX7 (linearity)

**A7a**: `U_B(p,q) AND U_B(r,s) -> U_B(p AND r, q AND s) OR U_B(p AND s, q AND s) OR U_B(q AND r, q AND s)`

Translation (applying guard/event swap):
- `U_B(p,q)` = `q U_C p`
- `U_B(r,s)` = `s U_C r`
- etc.

**BX7**: `(phi U psi) AND (chi U theta) -> ((phi AND chi) U (psi AND theta)) OR ((phi AND chi) U (psi AND chi)) OR ((phi AND chi) U (phi AND theta))`

Setting phi=q, psi=p, chi=s, theta=r (reading off the translation):

BX7 gives: `(q U p) AND (s U r) -> ((q AND s) U (p AND r)) OR ((q AND s) U (p AND s)) OR ((q AND s) U (q AND r))`

A7a gives: `(q U p) AND (s U r) -> ((q AND s) U (p AND r)) OR ((q AND s) U (p AND s)) OR ((q AND s) U (q AND r))`

**Match confirmed.**

---

## Part IV: The Lemma 2.5 Absorption Argument Under BX

Now that we know A6a = BX6, the Lemma 2.5 proof works directly. Here is the proof using BX axiom names:

**Lemma 2.5** (Intersection Identity). Suppose R(A, B, C), r(A, B', D), r(D, B'', C), and B subset B' inter D inter B''. Then B = B' inter D inter B''.

**Proof in BX notation** (using codebase convention: guard U event):

Take delta in B+ = B' inter D inter B'' and gamma in C. We need U_C(delta, gamma) in A (i.e., delta U gamma in A — delta is guard, gamma is event — which means "gamma happens in the future, delta holds throughout").

Wait — we need to be careful about the r-relation translation too.

### The r-relation in both notations

Burgess: r(A, beta, C) iff for all gamma in C, U_B(gamma, beta) in A.

Since U_B(gamma, beta) = beta U_C gamma, this becomes:
r(A, beta, C) iff for all gamma in C, (beta U_C gamma) in A.

In the codebase convention, this means: for all gamma in C, the Until formula with guard=beta and event=gamma is in A. So r(A, beta, C) means: "for every gamma in C, the eventuality of gamma with guard beta is recorded in A."

### Lemma 2.5 proof with BX notation

Take delta in B+, gamma in C.

1. delta in B'' and r(D, B'', C): for all gamma in C, (delta U_C gamma) in D. So **(delta U gamma) in D**.
2. delta in D: so **delta AND (delta U gamma) in D** (conjunction in MCS).
3. delta in B' and r(A, B', D): for all alpha in D, (delta U_C alpha) in A. Taking alpha = delta AND (delta U gamma): **(delta U_C (delta AND (delta U gamma))) in A**, i.e., **delta U (delta AND (delta U gamma)) in A**.
4. By **BX6** (absorb_until, with phi=delta, psi=gamma): `delta U (delta AND (delta U gamma)) -> delta U gamma`. Therefore **(delta U gamma) in A**.

This is exactly BX6 applied directly. No derivation chain needed.

---

## Part V: The Only Real Difference — Guard Convention

The BX axiom system differs from Burgess's system in ONE structural way: the guard interval.

| | Guard interval | Witness |
|---|---|---|
| Burgess | open (x < z < y) | strict (x < y) |
| BX | half-open [t, s) | strict (t < s) |

This means:
- Burgess's A2a needs only `G(p->q)` for left monotonicity
- BX2 needs `(p->q) AND G(p->q)` because the current time is in the guard

The half-open convention is the reason BX2 has the extra conjunct. But for A6a/BX6 specifically, this difference is irrelevant — the absorption axiom has the same form in both systems.

### Impact on Lemma 2.5

The Lemma 2.5 argument above uses only:
1. The r-relation (conjunction in MCS)
2. BX6 (absorption)

Neither step depends on the guard convention. The proof works identically under both open and half-open guard.

### Impact on A3a (Burgess's connectedness axiom)

This is where the guard convention DOES matter. As noted in TemporalDerived.lean (lines 517-540), Burgess A3a `p AND U_B(q,r) -> U_B(q AND S(p,r), r)` is NOT valid under BX's half-open guard. BX4 (connect_future) replaces A3a's role. But this is a separate issue from A6a.

---

## Part VI: Complete BX Axiom ↔ Burgess Axiom Correspondence

| Burgess | BX | Relationship | Guard difference? |
|---------|-----|--------------|-------------------|
| A1a | BX3 (right_mono_until) | Exact match | No |
| A2a | BX2 (left_mono_until) | BX2 has extra conjunct | Yes (half-open) |
| A3a | NOT IN BX | Not valid under half-open | Yes (replaced by BX4) |
| A4a | NOT IN BX | Not valid under half-open | Yes |
| A5a | BX5 (self_accum_until) | Exact match | No |
| **A6a** | **BX6 (absorb_until)** | **Exact match** | **No** |
| A7a | BX7 (linear_until) | Exact match | No |

BX has additional axioms not in Burgess: BX1 (seriality), BX4 (connectedness), BX9 (elimination), BX10 (eventuality extraction), BX11 (F-linearity), BX12 (F-Until bridge).

---

## Part VII: Semantic Verification

To be thorough, let me verify A6a/BX6 is sound under both semantics.

**BX6**: phi U (phi AND (phi U psi)) -> phi U psi

**Under BX half-open semantics**: Suppose phi U_C (phi AND (phi U_C psi)) holds at t. Then exists s1 > t with (phi AND (phi U_C psi))(s1) and phi(r) for all r in [t, s1). Since (phi U_C psi)(s1) holds, exists s2 > s1 with psi(s2) and phi(r) for all r in [s1, s2). Combining guards: phi(r) for all r in [t, s1) union [s1, s2) = [t, s2). And psi(s2). So phi U_C psi at t. Sound.

**Under Burgess open semantics**: Suppose U_B(q AND U_B(p,q), q) holds at x. Then exists y > x with (q AND U_B(p,q))(y) and q(z) for all x < z < y. Since U_B(p,q)(y) holds, exists y' > y with p(y') and q(z) for all y < z < y'. Combining: q(z) for all x < z < y AND q(z) for all y < z < y'. Together with q(y) (from the conjunction), we get q(z) for all x < z < y'. And p(y'). So U_B(p,q) at x. Sound.

Both check out. The soundness arguments are structurally identical.

---

## Part VIII: Implications for Task 107

### Immediate Consequences

1. **The Lemma 2.5 absorption argument works directly with `Axiom.absorb_until`** — no derivation, no new theorem needed.

2. **The implementation plan (22) risk item "A6a/BX6 absorption argument fails under BX strict semantics" is resolved.** Confidence: DEFINITIVE.

3. **The implementation summary (22) finding "Burgess A6a is NOT a direct instance of BX6" is WRONG.** It IS a direct instance, but the previous analysis failed to account for the argument-order swap between Burgess's and the codebase's Until conventions.

### Concrete Implementation Path

When verifying C2 for non-adjacent pairs after point insertion, the proof step is:

```lean
-- Have: U(delta_and_U_gamma_delta, delta) in f(w)
-- This is: delta U (delta AND (delta U gamma)) in f(w)
-- BX6: delta U (delta AND (delta U gamma)) -> delta U gamma
-- Therefore: (delta U gamma) in f(w)
```

In codebase terms, the axiom application is:
```lean
Axiom.absorb_until delta gamma
-- Type: (delta.untl (delta.and (delta.untl gamma))).imp (delta.untl gamma)
```

### What About Lemma 2.6?

Lemma 2.6 (C4 insertion) also depends on Lemma 2.5, which depends on A6a = BX6. The same analysis applies. The argument is:

1. Given R(f(x), g(x,y), f(y)) and delta not in g(x,y)
2. Construct D_0 (consistent set for the inserted point)
3. Verify C2 after insertion via Lemma 2.5 pattern
4. Lemma 2.5 uses A6a = BX6 directly

No additional axiom derivation is needed for any part of the chronicle construction.

### What About A3a and A4a?

A3a and A4a are NOT equivalent to any BX axiom (they are not valid under half-open guard). These are used in Lemma 2.4 (C5 seed construction) and Lemma 2.6 (C4 insertion consistency proof). The BX analogs need to use BX4 (connect_future) and BX5+BX7 respectively. This is a SEPARATE issue from the A6a question and is already acknowledged in the codebase (TemporalDerived.lean lines 517-540).

---

## Conclusion

**A6a IS BX6.** The confusion arose from Burgess using U(event, guard) while the codebase uses guard U event. Under the correct notation translation, the axioms are identical. The Lemma 2.5 absorption argument works directly with `Axiom.absorb_until`. No derivation from other BX axioms is needed.

### Remaining Open Questions (NOT addressed by this finding)

1. How to adapt Lemma 2.4 (C5 seed) without A3a (replaced by BX4)
2. How to adapt Lemma 2.6 consistency argument without A4a (replaced by BX5+BX7)
3. The non-domain extension issue (extended_limit_f = A requires T-axiom)

These are independent of the A6a question and require separate analysis.
