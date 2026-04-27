# Research Report: Burgess Seed Construction Analysis

**Task**: 107 - Chain design diagnostics for representation theorem
**Date**: 2026-04-26
**Focus**: How does Burgess construct the seed for R-maximal interval sets?

## Executive Summary

Burgess NEVER constructs a seed from scratch for the r-relation. Every R-maximal DCS in his proof either (a) arises as part of endpoint construction (Lemma 2.4), where the endpoint C is built first and then B is taken as maximal with r(A,B,C), or (b) arises from splitting an existing interval set (Lemma 2.6). The seed problem is an artifact of the codebase's attempt to separate "construct seed" from "extend to maximal" -- a separation Burgess does not make.

Furthermore, the codebase's strict half-open guard semantics (guard on [t,s)) ALREADY gives `(phi U psi) -> phi` as an axiom (`until_guard`), which is STRONGER than Burgess's open-interval guard. This axiom is the key to resolving the seed construction gap.

## Detailed Findings

### 1. Burgess's Lemma 2.4: Endpoint Construction (C5 Elimination)

**Exact construction**: Given MCS A with U(gamma, beta) in A, Burgess constructs:

```
C_0 = {gamma} union {S(alpha, beta) : alpha in A}
```

He proves C_0 is consistent (using A3a, which says `alpha AND U(gamma, beta) -> U(gamma AND S(alpha, beta), beta)`). Then C is ANY MCS extending C_0.

**Critical point**: Burgess then observes that r(A, beta, C) holds BY CONSTRUCTION -- criterion 2.3(b) is satisfied because `S(alpha, beta) in C` for all `alpha in A`. Then he lets B be maximal with respect to `beta in B` and `r(A, B, C)`.

**The seed is beta itself**. More precisely, B starts from any DCS containing beta that satisfies r(A, -, C), and is extended to maximal. The existence of such a starting DCS is immediate: beta is consistent (by 2.2), so deductiveClosure({beta}) is a DCS, and if r(A, deductiveClosure({beta}), C) holds, we're done. But Burgess doesn't even need to verify this -- he uses Zorn on ALL DCS B with beta in B and r(A, B, C).

**Key insight**: In Burgess's construction, `r(A, beta, C)` means `for all gamma in C, untl(beta, gamma) in A`. This is the BURGESS r-relation (what the codebase calls `burgessR`), NOT the codebase's `rRelation`. Burgess's maximality is with respect to this Burgess-flavored relation.

### 2. Burgess's Lemma 2.6: Interval Splitting (C4 Elimination)

**Exact construction**: Given R(A, B, C) and delta not in B, Burgess constructs:

```
D_0 = {S(alpha, beta) : alpha in A, beta in B}
     union B
     union {neg(delta)}
     union {U(gamma, beta) : gamma in C, beta in B}
```

He proves D_0 is consistent using A5a and A4a. Then D is any MCS extending D_0. Then B' and B'' are maximal with `B subset B'`, `r(A, B', D)` and `B subset B''`, `r(D, B'', C)`.

**No seed construction from scratch needed**: D_0 already contains B, and the maximality of B', B'' is relative to existing sets. The key equation B = B' cap D cap B'' follows from Lemma 2.5.

### 3. The Initial Chronicle and First g-Value

Burgess starts with dom f = {0}, f(0) = A_0, g = empty function. There are NO adjacent pairs, so NO g-values needed.

When he adds the first point y (via Lemma 2.10, which calls Lemma 2.4), the construction produces:
- f(y) = C (an MCS with the witness formula)
- g(0, y) = B where B is maximal with r(A_0, B, C)

**How B is seeded**: Per Lemma 2.4, B is maximal over all DCS containing beta with r(A_0, -, C). The starting point for the Zorn argument is ANY DCS containing beta that satisfies r(A_0, -, C). Since C was specifically constructed so that r(A_0, beta, C) holds (via criterion 2.3(b)), the singleton {beta} satisfies `burgessR(A_0, beta, C)`, and its deductive closure is a valid starting DCS.

### 4. Does Burgess Ever Need a Seed from Scratch?

**No.** Every R-maximal construction in Burgess falls into one of two patterns:

**(a) Lemma 2.4 pattern**: Construct endpoint C from {gamma} union {S(alpha, beta) : alpha in A}. The r-relation r(A, beta, C) holds by construction. Then B is maximal containing beta with r(A, B, C). The seed is trivially available because C was purpose-built.

**(b) Lemma 2.6 pattern**: Split existing B into B', D, B''. The starting sets for B' and B'' include the existing B as a subset. No from-scratch construction.

### 5. The Reflexive vs Strict Difference

**Burgess's semantics** (from Section 1.2):
```
V(U(alpha, beta)) = {x : exists y (x < y AND y in V(alpha) AND
                      forall z (x < z < y -> z in V(beta)))}
```

The guard covers the OPEN interval (x, y) -- neither endpoint. So `U(beta, gamma)` at x does NOT require beta at x. In particular, `gamma in A` does NOT imply `U(beta, gamma) in A` in general.

**The codebase's semantics** (from Truth.lean line 127-128):
```
untl phi psi at t = exists s, t < s AND psi(s) AND
                    forall r, t <= r -> r < s -> phi(r)
```

The guard covers `[t, s)` -- a HALF-OPEN interval including the left endpoint t. So `U(phi, psi)` at t DOES require phi at t. This gives the axiom `until_guard: (phi U psi) -> phi`.

**Key consequence for the seed problem**: Under the codebase's semantics:
- `(beta U gamma)` at t implies beta at t (by `until_guard`)
- So `burgessR(A, beta, C)` implies `beta in A` (pick any gamma in C, get `untl(beta, gamma) in A`, then `until_guard` gives `beta in A`)
- This means K = {beta | burgessR(A, beta, C) AND burgessRSince(C, beta, A)} is a subset of A (already proved in the codebase at line 1126-1130)

**Does `gamma in A` imply `U(beta, gamma) in A`?** NO -- not under either semantics. Under the codebase semantics, `U(beta, gamma)` at t requires a FUTURE witness s > t with gamma(s), not gamma at t. The reflexivity only affects the guard, not the witness.

**Wait -- what about s = t?** Under the codebase semantics, the witness s must satisfy `t < s` (STRICT), so s = t is impossible. The guard `[t, s)` is always non-empty. Under Burgess, also `x < y` (strict). So in BOTH systems, Until requires a strictly future witness.

So the key question (5 from the task) is answered: `gamma in A` does NOT imply `untl(beta, gamma) in A`, even under the codebase's reflexive-guard semantics. The strict future witness requirement prevents this.

### 6. The Actual Resolution Path

The handoff file (phase3-implementation-handoff.md) identified the right approach. Let me refine it:

**The core issue**: `burgessR3Maximal_exists` tries to prove existence for ARBITRARY MCS pairs (A, C). This requires finding a DCS S with `burgessR3(A, S, C)`. The kernel K satisfies burgessR3 but may be empty, and the empty deductive closure (= set of theorems) does not satisfy burgessR3 in general.

**Why Burgess doesn't have this problem**: Burgess never needs a burgessR3Maximal DCS for arbitrary (A, C). He only needs it when constructing g-values for newly-inserted points, where the endpoints are PURPOSE-BUILT to make the r-relation hold.

**Proposed resolution**: Instead of proving `burgessR3Maximal_exists` in full generality, prove it for the specific cases the chronicle construction needs:

**(a) C5 elimination (Lemma 2.10, case n=0)**: After `lemma_2_4` constructs C from A with U(xi, eta) in A, we need BurgessR3Maximal(A, B, C) with eta in B. The construction guarantees `burgessR(A, eta, C)` (from 2.3(b)). We also need `burgessRSince(C, eta, A)`. This follows from `P(U(xi, eta)) in C` (proved by `lemma_2_4` via BX4) combined with the Since mirror of the construction.

Actually, let me be more precise. Burgess's Lemma 2.4 gives r(A, beta, C) meaning FOR ALL gamma in C, untl(beta, gamma) in A. Under the codebase's Burgess r-relation, this is exactly `burgessR A beta C`. The Since direction: we need `burgessRSince C beta A`, meaning for all alpha in A, snce(beta, alpha) in C. Criterion 2.3(b) says S(alpha, beta) in C for all alpha in A. So `burgessRSince C beta A` holds by construction.

Therefore eta is a valid seed element: `burgessR(A, eta, C) AND burgessRSince(C, eta, A)`. The deductive closure of {eta} is a DCS, and if we can show it satisfies `burgessR3(A, deductiveClosure({eta}), C)`, we can pass it to `burgessR3Maximal_extension_exists`.

The BX7+BX2 guard algebra (already proved in the codebase as `untl_conj_guard` and `untl_left_mono_thm`) shows that burgessR3 is preserved under deductive closure of a non-empty seed. This is because:
- If beta1, beta2 satisfy burgessR(A, -, C), then beta1 AND beta2 does (by `untl_conj_guard`)
- If beta satisfies burgessR(A, -, C) and L |- phi from beta, then phi does (by `untl_left_mono_thm`)

So `deductiveClosure({eta})` satisfies `burgessR3(A, -, C)` since eta does and the set is non-empty.

**(b) C4 elimination (Lemma 2.9, case n=0)**: After Lemma 2.6 constructs D with neg(delta) in D, we need BurgessR3Maximal(A, B', D) and BurgessR3Maximal(D, B'', C). The construction of D_0 includes all the elements needed: `{S(alpha, beta) : alpha in A, beta in B}` ensures the Since direction, and `{U(gamma, beta) : gamma in C, beta in B}` ensures the Until direction. The existing B serves as a seed for both B' and B''.

**(c) C5 case n=m+1** (Lemma 2.10): This either reduces to n=m or inserts between using 2.7/2.8, which are analogous to 2.6.

### 7. What Exactly to Implement

The `burgessR3Maximal_exists` sorry can be resolved by proving a SPECIALIZED version:

```lean
theorem burgessR3Maximal_exists_from_lemma_2_4
    (A C : Set Formula)
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (eta : Formula)
    (h_burgessR : burgessR A eta C)
    (h_burgessRSince : burgessRSince C eta A) :
    exists B, eta in B AND BurgessR3Maximal A B C
```

This is provable because:
1. {eta} is consistent (since burgessR(A, eta, C) and A is MCS, we get untl(eta, gamma) in A for some gamma in C, hence by until_guard, eta in A, hence {eta} is consistent)
2. deductiveClosure({eta}) is a DCS
3. deductiveClosure({eta}) satisfies burgessR3(A, -, C) by the BX7+BX2 algebra
4. Apply `burgessR3Maximal_extension_exists`

The general `burgessR3Maximal_exists` (for arbitrary A, C with no seed element) may be FALSE under these semantics, and that's fine -- Burgess never needs it.

## Risks and Mitigations

1. **Risk**: The BX7+BX2 algebra for deductive closure preservation has been proved for individual elements but not for the full deductive closure argument. **Mitigation**: The proof structure is: for any L |- phi where L subset deductiveClosure({eta}), we can extract a single conjunction of L-elements, apply untl_conj_guard, then untl_left_mono_thm. This needs an inductive argument on list length.

2. **Risk**: The Since direction mirror of the BX7+BX2 algebra may need additional work. **Mitigation**: The codebase already has `snce_conj_guard` and `snce_left_mono_thm` (mentioned in the handoff as sorry-free).

3. **Risk**: The C4 elimination (Lemma 2.9) may need its own specialized BurgessR3Maximal theorem. **Mitigation**: In the C4 case, the existing B is already a DCS with burgessR3(A, B, C), so B itself is a valid seed for the Zorn extension.

## Summary of Answers to the Five Questions

**Q1 (Lemma 2.4 starting set)**: C_0 = {gamma} union {S(alpha, beta) : alpha in A}. He proves C_0 consistent, extends to MCS C, then takes B maximal with beta in B and r(A, B, C). The r-relation r(A, beta, C) holds by construction from criterion 2.3(b).

**Q2 (Lemma 2.6 starting sets)**: D_0 = {S(alpha,beta) : alpha in A, beta in B} union B union {neg(delta)} union {U(gamma,beta) : gamma in C, beta in B}. B', B'' are maximal extensions of B. No from-scratch seed needed.

**Q3 (Initial chronicle first g-value)**: The first point added via Lemma 2.4 produces an endpoint C purpose-built so r(A, beta, C) holds. B is maximal with beta in B. The seed is the single element beta.

**Q4 (Does Burgess ever need a seed from scratch?)**: NO. Every construction either (a) purpose-builds the endpoint to make r hold (2.4), or (b) uses existing interval sets (2.6). The codebase's `burgessR3Maximal_exists` for arbitrary (A, C) is asking for something Burgess never needs.

**Q5 (Reflexive vs strict)**: Under the codebase's half-open guard [t,s), `(phi U psi) -> phi` is valid (until_guard axiom). This does NOT give `gamma in A implies untl(beta, gamma) in A` because Until still requires a strictly future witness. The key benefit of the half-open guard is that the seed element eta satisfies `eta in A` (via until_guard applied to untl(eta, gamma) in A), guaranteeing the kernel K is a subset of A and consistent.
