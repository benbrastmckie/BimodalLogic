# Teammate B Findings: Alternative Completeness Proof Approaches from Literature

**Task**: 115 - Phase 2 Blocker Investigation
**Focus**: How do other completeness proofs handle the "splitting" / "point insertion" step?
**Date**: 2026-05-13

---

## Key Findings

### 1. The B-subset property IS maintained in the original Burgess 1982 proof

Burgess 1982 (Lemma 2.6, p. 372) constructs a seed set D0 that explicitly includes Until formulas `U(gamma, beta)` for beta in B and gamma in C, AND Since formulas `S(alpha, beta)` for beta in B and alpha in A. The seed is:

```
D0 = {S(alpha, beta) : alpha in A, beta in B}
   union B
   union {neg-delta}
   union {U(gamma, beta) : gamma in C, beta in B}
```

The consistency of D0 is proved using A4a (separation_until) to extract the crucial formula `U(beta AND NOT delta, beta)` from `U(gamma, beta) AND NOT U(gamma, beta AND delta)`. Once D is an MCS extending D0, the proof gets:
- `B subset D` (since B subset D0 subset D)
- `r(A, B, D)` (since S(alpha, beta) in D for all alpha in A, beta in B)
- `r(D, B, C)` (since U(gamma, beta) in D for all gamma in C, beta in B)

Then Lemma 2.5 gives `B = B' cap D cap B''` where R(A, B', D) and R(D, B'', C), which implies B subset B' and B subset B''.

**Conclusion**: Burgess's original proof DOES maintain `B subset B'` and `B subset B''`. The B-subset property is NOT an artifact of the codebase's formulation -- it is a structural feature of Burgess's proof, derived from including B in the seed D0.

### 2. Xu 1988 (Lemma 2.4) uses a DIFFERENT seed that gives r(A, top, D) instead of r(A, B, D)

Xu's Lemma 2.4 constructs D differently:
1. Extend B to B* with R(A, B*, C) (via Zorn)
2. Show beta not in B* (contradicts neg-U(gamma, beta) in A)
3. B* union {neg-beta} is consistent (DCS with element not in it)
4. D = MCS extending B* union {neg-beta}
5. By Xu Lemma 2.3: S(alpha, top) in B* and U(gamma, top) in B* (NOT S(alpha, beta) or U(gamma, beta))
6. Since B* subset D: r(A, top, D) and r(D, top, C)
7. Apply Zorn to get R(A, B', D) and R(D, B'', C)

The crucial difference: Xu's proof only establishes `r(A, top, D)` (S(alpha, top) in D for all alpha in A), which is WEAKER than Burgess's `r(A, B, D)` (S(alpha, beta) in D for all alpha in A AND beta in B). The Xu proof guarantees `B* subset D` (and hence `B subset D`) but does NOT guarantee `B subset B'` -- the B' obtained from Zorn at step 7 need not contain B, because the r-relation seed is `top`, not B.

### 3. The B-subset requirement is mathematically necessary for C3 (interval monotonicity)

The chronicle condition C3 states: for x < y < z, `g(x,z) = g(x,y) cap f(y) cap g(y,z)`. When a new point w is inserted between x and y (creating g(x,w) = B' and g(w,y) = B''), the existing g(x,y) = B must satisfy:
- B subset B' (since g(x,y) should be contained in g(x,w) for the intersection identity)
- B subset f(w) = D (already guaranteed by both approaches)
- B subset B'' (since g(x,y) should be contained in g(w,y))

Without B subset B', the C3 condition breaks: if some phi is in B = g(x,y) but not in B' = g(x,w), then g(x,y) would not equal g(x,w) cap f(w) cap g(w,y), since the left side contains phi but the right side does not (phi not in g(x,w)).

**This is the core mathematical issue**: C3 requires B subset B', and the Xu approach as stated gives only r(A, top, D), from which Zorn produces B' with B' containing the trivial DCS {top} but not necessarily containing B.

### 4. Venema 1993 and BdRV 2002 Section 7.2 use a COMPLETELY DIFFERENT method

Both Venema 1993 and Blackburn/de Rijke/Venema 2002 (Section 7.2) prove completeness for well-ordered flows of time using the "completeness via completeness" method:
1. Start with Burgess's completeness for linear time (the B system)
2. Show every BW-model is definably well-ordered (using the W axiom to eliminate Stavi connective counterexamples)
3. Apply Doets's theorem to get an n-equivalent well-ordered model

This approach NEVER constructs a chronicle at all. There is no splitting step, no point insertion, no counterexample elimination. The completeness proof transfers from linear time to well-ordered time via model-theoretic arguments (expressive completeness + n-equivalence + lexicographic sums).

**This method is irrelevant to the B-subset question** because it operates at a completely different level of abstraction. The chronicle construction is only needed for the underlying Burgess completeness (Theorem 7.15 / Theorem 3.5), which these texts take as a black box.

### 5. Reynolds 1992 also takes Burgess's construction as a black box

Reynolds 1992 proves completeness of U,S over the real numbers WITHOUT the IRR rule. His approach:
1. Uses the Burgess-Xu completeness result for linear time (Theorem 1, Section 4) to get a rational-flowed model
2. Shows the model is a "Prior structure" (definably Dedekind complete)
3. Applies Doets's theorem to transfer to real time

Reynolds explicitly states (Section 4): "For details of the proof see [2] and comments on it in [18]" -- referring to Burgess 1982 and Xu 1988. His innovation is in the SECOND part of the proof (definable Dedekind completeness and contemporaneous equivalence relations), not in the chronicle construction.

The B-subset question is about the FIRST part (Burgess's chronicle construction), which Reynolds does not modify. He uses exactly the "six Burgess-Xu axioms" (which include A4a) for the first step.

### 6. Hodkinson & Reynolds 2006 -- only introduction available

The Hodkinson & Reynolds 2006 handbook chapter (Chapter 11) in the literature directory contains only the table of contents and Introduction (Section 1). Sections 2-6 (the technical content) are not included in the source PDF. The Section 5.1 on "Hilbert style axiom systems" would be relevant, but is not available for examination.

### 7. Doets 1987 -- uses F/P tense logic, not S/U

Doets's thesis Chapter 7 proves completeness for Z-time using F/P operators (the basic tense logic), not S/U. The chronicle construction for F/P is much simpler than for S/U because F and P are unary operators with straightforward "killing" lemmas. The splitting/point-insertion complexity that arises with S/U does not appear.

### 8. Burgess 1984 handbook chapter -- covers F/P tense logic

The Burgess 1984 "Basic Tense Logic" chapter in the Handbook of Philosophical Logic covers the F/P chronicle construction in detail (Sections 1-2), including density insertion (Section 2.5) and discreteness (Section 2.6). However, the S/U construction with its more complex splitting lemmas is NOT in this chapter -- it is only in Burgess 1982. The chapter does not add information beyond what Burgess 1982 already provides about the B-subset question.

### 9. Xu's Lemma 2.4 for transitive frames (Section 3.2) -- the key insight

In Xu 1988, Section 3.2 (Theorem 3.2), Xu handles transitive frames (not just linear frames). Here, Lemma 3.2.1 proves that for R(A, B, C):
- (i) for every beta in B and every gamma in C, `U(gamma, beta) in B`
- (ii) for every beta in B and every alpha in A, `S(alpha, beta) in B`

This is STRONGER than Xu's Lemma 2.3 (which only gives S(alpha, top) and U(gamma, top)). It uses axiom (7): `U(p,q) -> U(p, q AND U(p,q))`, which corresponds to Burgess's A5a / the codebase's BX5 (self_accum_until).

Then Lemma 3.2.2 uses this to construct D with `B subset B' cap D cap B''`:

> "By 3.2.1 and 2.1 we have r(A, B*, D) and r(D, B*, C). Hence we can complete the proof by applying 2.0."

The key: because S(alpha, beta) in B* for all beta in B* and alpha in A, and B* subset D, we get S(alpha, beta) in D for all beta in B* (hence beta in B), alpha in A. This gives `r(A, B*, D)`, not just `r(A, top, D)`. Similarly U(gamma, beta) in B* subset D gives `r(D, B*, C)`.

**This is the resolution**: Xu's Lemma 3.2.1 (for transitive frames) gives the stronger `S(alpha, beta) in B` and `U(gamma, beta) in B`, which is exactly what's needed to maintain `B subset B'` through the splitting step.

---

## Recommended Approach

### The path forward: use Xu 3.2.1 instead of Xu 2.3

The codebase operates in the transitive setting (linear orders are transitive), so Xu's Lemma 3.2.1 is available. The proof of 3.2.1 uses axiom (7) = BX5 (self_accum_until), which is already in the codebase.

**Xu 3.2.1 proof sketch for (i)**: Suppose U(gamma, beta) not in B for some beta in B, gamma in C. By 2.0(iii), there exist beta' in B and gamma' in C with neg-U(gamma', beta' AND U(gamma, beta)) in A. Let gamma'' = gamma AND gamma', beta'' = beta AND beta'. Then by axiom (7), U(gamma'', beta'' AND U(gamma'', beta'')) -> U(gamma', beta' AND U(gamma, beta)) is derivable. So neg-U(gamma'', beta'') in A. But U(gamma'', beta'') in A (from R-relation), contradiction.

This gives the full `r(A, B*, D)` (not just `r(A, top, D)`), which in turn gives `B subset B'` through Zorn.

### Concrete plan modification

Phase 2 of the implementation plan should be revised to:

1. **Add Xu 3.2.1**: Prove that R(A, B, C) implies U(gamma, beta) in B for all beta in B, gamma in C (and dually for Since). This uses BX5 + BurgessR3Maximal_extension_fails + contradiction.

2. **Revise Xu 2.4 splitting**: In `xu_lemma_2_4_splitting`, after extending B to B* and constructing D = MCS(B* union {neg-beta}):
   - By Xu 3.2.1: U(gamma, phi) in B* for all phi in B*, gamma in C. Since B* subset D: `r(D, B*, C)`.
   - By Xu 3.2.1: S(alpha, phi) in B* for all phi in B*, alpha in A. Since B* subset D: `r(A, B*, D)`.
   - Apply Zorn to get R(A, B', D) with B* subset B', and R(D, B'', C) with B* subset B''.
   - Since B subset B* subset B', we get `B subset B'`. Similarly `B subset B''`.

3. **Output type matches**: The output of `xu_lemma_2_4_splitting` would be:
   ```
   exists B' D B'', BurgessR3Maximal A B' D AND BurgessR3Maximal D B'' C AND
     SetMaximalConsistent D AND beta.neg in D AND B subset D AND B subset B' AND B subset B''
   ```
   This is IDENTICAL to the existing `lemma_2_6_splitting` output type, so no callers need modification.

---

## Evidence / Examples

### Burgess 1982 Lemma 2.6 seed (p. 372)

Direct quote from the paper:
> Let D0 = {S(alpha, beta) : alpha in A, beta in B} union B union {neg-delta} union {U(gamma, beta) : gamma in C, beta in B}. We claim D0 is consistent.

The consistency proof uses A4a to derive `U(beta AND U(gamma, beta) AND neg-delta AND S(alpha, beta), beta) in A`, which shows every finite subset of D0 is consistent. This is the `burgess_D0_seed_consistent` sorry in the codebase.

### Xu 1988 Lemma 2.4 (p. 94, line 92-94)

Direct quote:
> Let B* be such that B subset B* and R(A, B*, C). Clearly, beta not in B*, and hence B* union {neg-beta} is consistent. Let D be a MCS containing B* union {neg-beta}. By 2.3 and 2.1 we have r(A, top, D) and r(D, top, C). Hence we can complete the proof by applying 2.0.

Note: Xu's output is `B union {neg-beta} subset D`, NOT `B subset B'`. The output type for Xu 2.4 in the minimal logic setting does NOT include B subset B'.

### Xu 1988 Lemma 3.2.2 (p. 234, transitive case)

Direct quote:
> Let B* be such that B subset B* and R(A, B*, C). Clearly, beta not in B* and hence B* union {neg-beta} is consistent. Let D be a MCS containing B* union {neg-beta}. By 3.2.1 and 2.1 we have r(A, B*, D) and r(D, B*, C). Hence we can complete the proof by applying 2.0.

Key difference from 2.4: uses `r(A, B*, D)` instead of `r(A, top, D)`. This is possible because Lemma 3.2.1 gives `S(alpha, beta) in B*` for all beta in B* (not just `S(alpha, top) in B*`).

---

## Confidence Level

**HIGH** (9/10)

The analysis is based on direct reading of the primary sources (Burgess 1982, Xu 1988, Venema 1993, BdRV 2002, Reynolds 1992, Doets 1987, Burgess 1984). The key finding -- that Xu 3.2.1 (transitive frame version) gives the stronger `r(A, B*, D)` needed for B-subset preservation -- is directly verified from the mathematical text. The codebase already has BX5 (self_accum_until), which is the axiom that enables Xu 3.2.1.

The one uncertainty is whether the existing codebase infrastructure for `BurgessR3Maximal_extension_fails` + contradiction is sufficient to formalize the Xu 3.2.1 proof without new infrastructure. Based on the proof sketch (standard contradiction via 2.0(iii) + BX5), this should work with existing primitives.

### Summary of literature coverage

| Source | Completeness Method | Splitting Step? | Maintains B subset B'? | Relevant? |
|--------|---------------------|-----------------|------------------------|-----------|
| Burgess 1982 | Chronicle construction | Yes (Lemma 2.6) | YES (via D0 seed with S/U formulas) | Core reference |
| Xu 1988 Lemma 2.4 | Chronicle (minimal logic) | Yes | NO (only r(A, top, D)) | Shows weaker version |
| Xu 1988 Lemma 3.2.2 | Chronicle (transitive) | Yes | YES (via 3.2.1 giving r(A, B*, D)) | **KEY RESOLUTION** |
| Venema 1993 | Model-theoretic transfer | No | N/A | Irrelevant (different method) |
| BdRV 2002 s7.2 | Model-theoretic transfer | No | N/A | Irrelevant (different method) |
| Reynolds 1992 | Takes Burgess as black box | No (delegates) | N/A | Uses A4a axioms |
| Hodkinson-Reynolds 2006 | Only intro available | Unknown | Unknown | Incomplete source |
| Doets 1987 | F/P tense logic | No (different operators) | N/A | Wrong logic |
| Burgess 1984 | F/P chronicle | Yes (simpler) | N/A | Wrong operators |
