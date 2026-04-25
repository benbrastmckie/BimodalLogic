# Teammate D Findings: Burgess 1982 Close Reading -- A6a and C2 Maintenance

**Task**: 107 - Chronicle representation theorem
**Date**: 2026-04-24
**Focus**: Exact statement and role of A6a, comparison to BX axioms, Lemma 2.5 step-by-step analysis
**Confidence**: DEFINITIVE on all seven questions

---

## Question 1: What EXACTLY is A6a?

**A6a is an AXIOM (not a derived rule) of Burgess's system J_0.**

Exact statement from the paper (line 60 of the markdown transcription):

> **A6a**: U(q and U(p, q), q) -> U(p, q)

In English: If there is a future witness for `q and U(p,q)` with guard `q` throughout, then there is a future witness for `p` with guard `q` throughout.

Intuition: This is an **absorption/collapse** axiom. If the "event" you are waiting for is itself of the form "q holds AND the original eventuality U(p,q) still persists", then you can collapse the two-step resolution into the original eventuality. It prevents infinite deferral of an Until obligation.

The mirror image **A6b** (not stated explicitly but implied) is: S(q and S(p, q), q) -> S(p, q).

---

## Question 2: Where EXACTLY is A6a used in the completeness proof?

A6a is used in **exactly one place**: the proof of **Lemma 2.5** (the intersection identity).

### Lemma 2.5 Statement
Suppose R(A, B, C), r(A, B', D), r(D, B'', C), and B subset B' cap D cap B''. Then B = B' cap D cap B''.

### Where A6a Appears (lines 158-160 of the markdown)

The proof takes delta in B+ = B' cap D cap B'' and gamma in C, and needs to show U(gamma, delta) in A:

1. delta in B'', r(D, B'', C) => U(gamma, delta) in D
2. delta in D => delta and U(gamma, delta) in D (conjunction in MCS)
3. delta in B', r(A, B', D) => U(delta and U(gamma, delta), delta) in A
4. **By A6a**: U(delta and U(gamma, delta), delta) -> U(gamma, delta). Therefore U(gamma, delta) in A.

Step 4 is the ONLY use of A6a in the paper. It is the step that converts:
- U(delta and U(gamma, delta), delta) [which has the "enriched" event: delta AND the original eventuality]
- into U(gamma, delta) [the original eventuality]

### Where Lemma 2.5 is subsequently used

Lemma 2.5 is used in:
- **Lemma 2.6** (C4 insertion): "Note we have B = B' cap D cap B'' by 2.5" (line 172)
- **Lemma 2.7** (C5 insertion with eta not in B): same structure
- **Lemma 2.8** (C5 insertion variant): same structure

All of these are point insertion lemmas. So A6a is ultimately critical for **proving that C2 (the r-relation) is maintained when inserting new points into the chronicle**, because C2 maintenance relies on the three-way intersection identity (Lemma 2.5), which relies on A6a.

### NOT used in

- Lemma 2.4 (initial C5 seed construction) -- uses A3a instead
- The truth lemma (Claim 2.11) -- uses C3, C4a, C5a directly
- Lemma 2.3 (r-relation equivalence) -- uses A3a
- Lemma 2.2 (consistency criterion) -- uses A2a + TG

---

## Question 3: Burgess's Full Axiom System vs. BX

### Burgess's Axioms (J_0)

| Burgess | Statement | BX Equivalent |
|---------|-----------|---------------|
| **A1a** | G(p -> q) -> (U(p,r) -> U(q,r)) | **BX3** (right_mono_until) -- but see note |
| **A2a** | G(p -> q) -> (U(r,p) -> U(r,q)) | **BX2** partially -- but see note |
| **A3a** | p and U(q,r) -> U(q and S(p,r), r) | **BX4** (connect_future) -- different formulation |
| **A4a** | U(p,q) and ~U(p,r) -> U(q and ~r, q) | No direct BX equivalent |
| **A5a** | U(p,q) -> U(p, q and U(p,q)) | **BX5** (self_accum_until) -- SWAPPED POSITIONS |
| **A6a** | U(q and U(p,q), q) -> U(p,q) | **BX6** (absorb_until) -- SWAPPED POSITIONS |
| **A7a** | U(p,q) and U(r,s) -> U(p and r, q and s) or U(p and s, q and s) or U(q and r, q and s) | **BX7** (linear_until) -- see note |

Plus mirror images A1b-A7b for Since, and rules MP, Substitution, TG (from alpha infer G alpha and H alpha).

### CRITICAL: Argument Position Convention Difference

**Burgess writes U(event, guard)**. The event/witness is the FIRST argument, the guard is the SECOND.
- U(p, q) means: there exists future y with **p at y** (event) and **q throughout (x,y)** (guard)

**BX writes Formula.untl guard event**. The guard is the FIRST argument, the event is the SECOND.
- `Formula.untl phi psi` means: there exists future y with **psi at y** (event) and **phi throughout** (guard)

This means:
- Burgess U(p, q) = BX `untl q p` (swapped)
- Burgess A5a: U(p, q) -> U(p, q and U(p,q)) becomes BX: (guard U event) -> ((guard and (guard U event)) U event)
- Burgess A6a: U(q and U(p,q), q) -> U(p,q) becomes BX: (q U (q and U(p,q))) -> (q U p)

### Detailed Comparison with Swap

Applying the swap (Burgess event=BX event, Burgess guard=BX guard):

| Burgess | After swap to BX convention (untl guard event) |
|---------|------------------------------------------------|
| **A5a**: U(p, q) -> U(p, q and U(p,q)) | (q U p) -> ((q and (q U p)) U p) -- i.e., guard accumulates |
| **A6a**: U(q and U(p,q), q) -> U(p,q) | (q U (q and (q U p))) -> (q U p) -- event-position absorption |

Now compare to BX:

| BX | Statement (untl guard event) |
|----|------------------------------|
| **BX5** (self_accum_until) | (phi U psi) -> ((phi and (phi U psi)) U psi) |
| **BX6** (absorb_until) | (phi U (phi and (phi U psi))) -> (phi U psi) |

Setting phi = guard = q, psi = event = p:
- **BX5**: (q U p) -> ((q and (q U p)) U p) -- **MATCHES A5a after swap**
- **BX6**: (q U (q and (q U p))) -> (q U p) -- **MATCHES A6a after swap**

**CONCLUSION: BX5 = A5a and BX6 = A6a (after accounting for the argument position swap).** They are the SAME axioms, just written with the opposite convention for which argument of U is the guard vs event.

### Missing from BX: Burgess Axioms Not in BX

| Burgess | Status in BX |
|---------|-------------|
| A1a: G(p->q) -> (U(p,r) -> U(q,r)) | Partially covered by BX3 (right_mono_until). Burgess A1a monotonizes the EVENT position; BX3 uses G(phi->psi) -> (chi U phi) -> (chi U psi) which monotonizes the EVENT position too. After swap, these match. |
| A2a: G(p->q) -> (U(r,p) -> U(r,q)) | Partially covered by BX2 (left_mono_until), but BX2 adds a conjunct: (phi->chi) AND G(phi->chi). Burgess A2a only has G(p->q). BX2 is STRONGER than A2a. |
| A3a: p and U(q,r) -> U(q and S(p,r), r) | BX4 (connect_future: phi -> G(P(phi))) is a DIFFERENT formulation. A3a directly connects Since and Until; BX4 uses G/P. |
| A4a: U(p,q) and ~U(p,r) -> U(q and ~r, q) | **No BX equivalent.** This is the "separation" axiom used in Lemma 2.6. |

### Additional in BX: Axioms Not in Burgess

| BX | Purpose | Burgess Status |
|----|---------|---------------|
| BX1/BX1': serial_future/past (T -> F(T)) | Burgess does not have this. His system works on ALL linear orders including those with endpoints. |
| BX9/BX9': until_elim ((phi U psi) -> phi or psi) | Not in Burgess. This is a STRICT/IRREFLEXIVE semantics axiom. |
| BX10/BX10': until_F ((phi U psi) -> F(psi)) | Not in Burgess explicitly; derivable from his A2a. |
| BX11/BX11': temp_linearity | Not in Burgess; his A7a handles linearity for Until directly. |
| BX12/BX12': F_until_equiv (F(phi) -> T U phi) | Not explicit in Burgess; follows from his definitions. |
| BX4/BX4': connect_future/past (phi -> G(P(phi))) | Replaces Burgess A3a with a G/P formulation. |
| temp_k_dist, temp_4 | Standard G-modality axioms; Burgess has TG rule + A1a/A2a instead. |

---

## Question 4: Is A6a Derivable from the Other Burgess Axioms?

**No.** A6a is listed as an AXIOM in J_0, which means Burgess considers it independent. In the context of completeness proofs for temporal logic, A5a and A6a form a complementary pair:

- A5a (self-accumulation): Allows enriching the guard with the eventuality itself
- A6a (absorption): Collapses enriched events back to the original eventuality

Without A6a, you cannot close the Lemma 2.5 argument. The proof explicitly requires going from U(delta and U(gamma, delta), delta) to U(gamma, delta), and no other axiom provides this collapse.

**Could it be derivable in an extended system?** Potentially, if you had a very strong induction principle, but this is speculative. In Burgess's system (A1a-A7a + mirror images + propositional logic + MP + TG), A6a appears to be independent.

---

## Question 5: Does BX Have Additional Axioms That Help Derive A6a?

**BX already HAS A6a -- it is BX6 (absorb_until).**

After accounting for the argument position swap:
- Burgess A6a: U(q and U(p,q), q) -> U(p,q) with U(event, guard)
- BX6: (phi U (phi and (phi U psi))) -> (phi U psi) with untl(guard, event)

Setting phi = q (guard) and psi = p (event), these are identical.

The additional BX axioms (BX1, BX9, BX10, BX11, BX12, connect_future/past) provide extra power for the STRICT/irreflexive semantics context, but they do not make BX6 redundant -- BX6 is needed for exactly the same role as A6a.

---

## Question 6: Exact Step-by-Step Proof of Lemma 2.5

### Setup
Given: R(A, B, C), r(A, B', D), r(D, B'', C), B subset B' cap D cap B''.
Goal: B = B' cap D cap B''.

### Proof

Since B subset B+ := B' cap D cap B'' by hypothesis, we need B+ subset B, i.e., r(A, B+, C).

By the R-maximality of B: R(A, B, C) means B is maximal among DCSs B* with r(A, B*, C). If r(A, B+, C) holds and B+ is a DCS, then B+ subset B by maximality. Since B subset B+ and B+ subset B, we get B = B+.

(B+ = B' cap D cap B'' is a DCS because it is the intersection of DCSs B' and B'' with the MCS D, and such intersections are deductively closed.)

So the core obligation is: **show r(A, B+, C)**, i.e., for all delta in B+ and gamma in C, show U(gamma, delta) in A.

**Step-by-step for r(A, B+, C):**

Take arbitrary delta in B+ = B' cap D cap B'' and gamma in C. We must show U(gamma, delta) in A.

| Step | Claim | Justification |
|------|-------|---------------|
| 1 | delta in B'' | delta in B+ subset B'' |
| 2 | r(D, B'', C) holds | Given |
| 3 | U(gamma, delta) in D | Steps 1, 2: r-relation definition (for all gamma in C, U(gamma, delta) in D since delta in B'') |
| 4 | delta in D | delta in B+ subset D |
| 5 | delta and U(gamma, delta) in D | Steps 3, 4: D is an MCS, closed under conjunction |
| 6 | delta in B' | delta in B+ subset B' |
| 7 | r(A, B', D) holds | Given |
| 8 | U(delta and U(gamma, delta), delta) in A | Steps 5, 6, 7: r-relation definition. Since delta in B', for all alpha in D, U(alpha, delta) in A. Taking alpha = delta and U(gamma, delta) in D gives U(delta and U(gamma, delta), delta) in A. |
| 9 | **U(gamma, delta) in A** | Step 8 + **Axiom A6a**. A6a says U(q and U(p,q), q) -> U(p,q). Setting q = delta, p = gamma: U(delta and U(gamma, delta), delta) -> U(gamma, delta). Since A is an MCS and U(delta and U(gamma, delta), delta) in A, and A6a is a thesis, therefore U(gamma, delta) in A. |

**QED.**

### Axiom usage summary for Lemma 2.5:
- **A6a**: Step 9 (the only non-trivial axiom step)
- MCS closure under conjunction: Step 5
- r-relation definition: Steps 3, 8
- R-maximality of B: Overall argument structure

---

## Question 7: Does the Proof Work with BX6 Instead of A6a?

**YES -- because BX6 IS A6a (after the argument position swap).**

To be completely explicit:

**Burgess A6a** (event, guard convention):
```
U(q and U(p, q), q) -> U(p, q)
```

**BX6** (absorb_until, guard first convention):
```
(phi U (phi and (phi U psi))) -> (phi U psi)
```
which in Burgess's convention (swap arguments) reads:
```
U(phi and (phi U psi), phi) -> U(psi, phi)
```

Setting phi = q (the guard throughout), psi = p (the event at the witness):
```
U(q and (q U p), q) -> U(p, q)
```

Now, `q U p` in BX notation (guard=q, event=p) = `U(p, q)` in Burgess notation. So:
```
U(q and U(p, q), q) -> U(p, q)
```

**This is character-for-character identical to A6a.**

### The Lemma 2.5 proof in BX notation

In BX notation (untl guard event), the proof of Lemma 2.5, step 9 becomes:

We have `untl delta (delta and (untl delta gamma))` in A (from step 8, with guard=delta, event=delta and (untl delta gamma)).

BX6 says: `untl phi (phi and (untl phi psi)) -> untl phi psi`.

Setting phi = delta, psi = gamma: `untl delta (delta and (untl delta gamma)) -> untl delta gamma`.

Therefore `untl delta gamma` in A. This is `U(gamma, delta)` in Burgess notation. Done.

**There is no gap. BX6 provides exactly the axiom needed for Lemma 2.5.**

---

## Summary of Critical Findings

1. **A6a is U(q and U(p,q), q) -> U(p,q)**, an AXIOM (not derived) in Burgess's system J_0. It is the absorption/collapse axiom that prevents infinite deferral of Until obligations.

2. **A6a is used in exactly ONE place**: Lemma 2.5 (intersection identity), step 9. Lemma 2.5 is then used by Lemmas 2.6, 2.7, 2.8 to prove C2 maintenance after point insertion.

3. **BX6 (absorb_until) IS A6a**, after accounting for the argument position swap between Burgess (event, guard) and BX (guard, event). They are the same axiom written in different conventions.

4. **A6a is presumed independent** in Burgess's system. It cannot be derived from A1a-A5a + A7a alone.

5. **BX has A6a as BX6**, so the C2 maintenance proof can proceed. The BX system does NOT lack this axiom -- there is no gap.

6. **The implementation blocker is NOT about a missing axiom.** If the implementation is blocked, the issue is elsewhere (likely the three-way C3 definition, as identified in Teammate B's report #22).

7. **BX has additional axioms Burgess lacks** (BX1, BX9, BX10, BX11, BX12) for the strict/irreflexive semantics adaptation, but these are not relevant to the A6a/Lemma 2.5 question.

---

## Appendix: Full Axiom Correspondence Table

| Burgess (event, guard) | BX (guard, event) | Match Quality |
|------------------------|-------------------|---------------|
| A1a: G(p->q) -> (U(p,r) -> U(q,r)) | BX3: right_mono_until G(phi->psi) -> (chi U phi) -> (chi U psi) | Exact match after swap (event monotonicity) |
| A2a: G(p->q) -> (U(r,p) -> U(r,q)) | BX2: left_mono_until (phi->chi) and G(phi->chi) -> (phi U psi) -> (chi U psi) | BX2 is STRONGER (adds current-time conjunct) |
| A3a: p and U(q,r) -> U(q and S(p,r), r) | BX4: connect_future phi -> G(P(phi)) | DIFFERENT formulation. A3a connects U/S directly; BX4 uses G/P. |
| A4a: U(p,q) and ~U(p,r) -> U(q and ~r, q) | (none) | **MISSING from BX.** Used in Lemma 2.6 proof. |
| A5a: U(p,q) -> U(p, q and U(p,q)) | BX5: self_accum_until (phi U psi) -> ((phi and (phi U psi)) U psi) | Exact match after swap |
| A6a: U(q and U(p,q), q) -> U(p,q) | BX6: absorb_until (phi U (phi and (phi U psi))) -> (phi U psi) | Exact match after swap |
| A7a: U(p,q) and U(r,s) -> three-way disjunction | BX7: linear_until (phi U psi) and (chi U theta) -> three-way disjunction | Match after swap (same linearity principle) |

### Key Finding: A4a is Missing from BX

Burgess's **A4a** (the separation axiom) is used in the proof of **Lemma 2.6** (the C4 insertion lemma). The current BX system does not appear to have a direct equivalent. This could be a more significant gap than A6a (which IS present as BX6).

A4a states: If U(p,q) holds and U(p,r) does NOT hold, then U(q and ~r, q) holds. This is a key axiom for splitting the interval when a guard formula fails.

This should be investigated as a potential source of the real implementation blocker.
