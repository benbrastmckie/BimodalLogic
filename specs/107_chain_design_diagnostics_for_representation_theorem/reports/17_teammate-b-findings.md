# Teammate B Findings: How Does Burgess Actually Prove g_content Propagation?

**Task**: 107 - Chain Design Diagnostics
**Focus**: Literature analysis of the g_content chain property across Burgess 1982, Burgess 1984, Verbrugge 2004, and Venema 1993

## Executive Summary

The g_content_chain_property ("for x < y in the limit domain, g_content(limit_f(x)) is a subset of limit_f(y)") is NOT a separate lemma in Burgess. It falls out automatically from condition **C3** combined with **coherence**. The key insight is that Burgess's construction is fundamentally different from the codebase's current approach: Burgess uses a **binary interval function g(x,y)** satisfying the decomposition identity C3, while the codebase tries to derive g_content propagation from a **unary** g_content extraction on point sets. This architectural gap is the root cause of the sorry.

## Detailed Findings

### 1. Burgess 1982: The Definitive Source

**How Burgess defines the r-relation and chronicles:**

Burgess defines chronicles as pairs (f, g) where:
- f maps domain points to MCS (maximal consistent sets)
- g maps pairs (x,y) with x < y to DCS (deductively closed sets)

The critical conditions are:

- **C2**: For x < y in dom, r(f(x), g(x,y), f(y)) holds -- meaning for all beta in g(x,y): for all gamma in f(y), U(gamma, beta) in f(x), AND for all alpha in f(x), S(alpha, beta) in f(y).

- **C2'**: For adjacent x,y: R(f(x), g(x,y), f(y)) -- g(x,y) is MAXIMAL with this property.

- **C3**: For x < y < z in dom: **g(x,z) = g(x,y) INTERSECT f(y) INTERSECT g(y,z)**.

This is the key identity. C3 says the interval content decomposes: the formulas holding throughout [x,z] are exactly those holding in [x,y], at y, and in [y,z]. This is NOT a subset relation -- it is an EQUALITY.

**How g_content propagation follows from C3:**

From C3, for any x < y < z: g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z), which immediately gives:
- g(x,z) ⊆ f(y) for any y between x and z
- g(x,y) ⊇ g(x,z) for y between x and z (larger interval has fewer formulas)

From C2 (the r-relation), g(x,y) encodes the "interval content" that relates f(x) to f(y). The r-relation is defined in terms of Until/Since obligations. Specifically, r(A, beta, C) holds when: for all gamma in C, U(gamma, beta) in A; equivalently, for all alpha in A, S(alpha, beta) in C.

**The relationship to g_content:**

Burgess does NOT directly use g_content(f(x)) = {phi | G(phi) in f(x)}. Instead, the r-relation between f(x) and f(y) mediated by g(x,y) subsumes g_content propagation:

If G(phi) in f(x), then by the r-relation (specifically by the coherence that C2 induces), phi must appear in g(x,y) for any adjacent y > x. And by C3, g(x,y) subset f(y). So phi in f(y).

More precisely: the r-relation r(f(x), g(x,y), f(y)) ensures that g(x,y) contains exactly the formulas that hold "throughout the interval" -- which must include everything under G at x. The maximality condition C2' ensures g(x,y) is as large as possible while maintaining this property.

**Does Burgess have an explicit "g_content(f(x)) subset f(y) for x < y"?**

No, not as a standalone statement. It is implicit in the truth lemma (Claim 2.11). The G-case of the truth lemma says:

> If G(phi) in f(x), then by C5a [this should read: by C3 + g-function] there is... for any y > x with phi in f(y).

Actually, looking at the truth lemma proof (Claim 2.11 at line 240-248 of the source): The relevant case is alpha = U(beta, gamma). The proof says:

> "If alpha in f(x), then by C5a there is a y in X with x < y and gamma in f(y) and beta in g(x,y). If z in X and x < z < y, then **by C3 we have g(x,y) subset f(z)**, whence beta in f(z)."

This is the critical sentence. The subset g(x,y) subset f(z) comes from C3: g(x,y) = g(x,z) ∩ f(z) ∩ g(z,y), so g(x,y) subset f(z).

For the G-case specifically (which is a special case of Until with U(top, phi)):
- G(phi) in f(x) means U(top, phi) in f(x) (using the abbreviation G(phi) = ~F~phi and F(phi) = U(phi, top))
- Actually, in Burgess's notation, G(phi) = ~F~phi, and the truth condition is: x in V(G(phi)) iff for all y > x, y in V(phi). This is proved by the coherence of f:
  - If G(phi) in f(x), take any y > x. By C3 + r-relation, phi must be in f(y).

The g_content propagation is thus a consequence of the r-relation + C3, not a separately maintained invariant.

### 2. Burgess 1984: The Textbook Treatment

Burgess 1984 uses a simpler chronicle structure for basic G/H tense logic (without Until/Since):
- A chronicle T assigns each point x an MCS T(x)
- T is **coherent** if T(x) ≺ T(y) whenever xRy, where ≺ means: G(phi) in T(x) implies phi in T(y)
- T is **perfect** if it is both prophetic (F witnesses exist) and historic (P witnesses exist)

The Chronicle Lemma (1.9) proves: for a perfect chronicle T on (X,R), V(gamma) = {x : gamma in T(x)} for all formulas.

The G-case of the proof (page 100, lines 1202-1208): "If G(gamma) in T(x), then by Definition 1.8c, whenever xRy we have gamma in T(y)."

Definition 1.8c is exactly the coherence condition: G(gamma) in T(x) and xRy implies gamma in T(y).

**Key observation**: In the basic G/H case, coherence IS g_content propagation. The coherence condition T(x) ≺ T(y) directly states g_content(T(x)) subset T(y) whenever xRy. The Killing Lemma (1.11) maintains this by construction: when adding a new point y after x, we choose B with T(x) ≺ B.

For the S,U extension (Section 2.8+), Burgess uses the full chronicle structure from the 1982 paper with the binary g-function and C3.

### 3. Verbrugge 2004: Step-by-Step Method

Verbrugge's completeness proofs for Lin, P, Q, R, D, Z use a different architecture entirely. Key differences:

**No binary interval function.** Verbrugge works with the relation ≺ between maximal consistent sets:
- Gamma ≺ Delta iff for each G(phi) in Gamma, phi in Delta

This is exactly the g_content subset relation! Verbrugge's ≺ IS g_content(Gamma) subset Delta.

**How temporal coherence is maintained:**

In Theorem 1 (Lin completeness), the construction maintains:
- (b) If t < t', then Gamma_t ≺ Gamma_{t'} -- i.e., g_content(Gamma_t) subset Gamma_{t'}

When inserting a new point u between t and its immediate successor t':
- By Lemma 3, ≺ is "not branching towards the future" (from axiom L1 = Lin axiom 5a)
- For any new Delta with Gamma_t ≺ Delta, either Delta ≺ Gamma_{t'} or Delta = Gamma_{t'} or Gamma_{t'} ≺ Delta
- The proof shows Delta ≺ Gamma_{t'} must hold (the other cases are ruled out)

So the g_content chain property is maintained by the non-branching property of ≺ over linear orders.

**Important**: Verbrugge does NOT handle Until/Since. The paper only addresses G/H tense logic. The ≺ relation suffices for G/H because coherence (≺) is exactly what's needed. For Until/Since, you need the full Burgess-style binary interval function.

**Invariant maintained at each step**: Simply that the ordering is linear and (b) holds: all pairs satisfy ≺. This is the g_content chain property stated directly as a construction invariant.

### 4. Venema 1993: A Completely Different Technique

Venema proves completeness for well-orderings and omega via expressive completeness, NOT via the chronicle/step-by-step method. The approach is:

1. Start with Burgess's completeness for arbitrary linear orders (Theorem 3.5)
2. Show that any BW-model (satisfying the well-ordering axiom W) is "definably well-ordered"
3. Use Doets's theorem: any definably well-ordered model has n-equivalents in WO for all n
4. Conclude: any BW-consistent formula has a well-ordered model

Venema's approach completely avoids the g_content chain property issue. There is no chronicle construction, no step-by-step insertion, and no interval function. The expressive completeness of S,U over well-orderings is used as a black box to transfer satisfiability from arbitrary linear models to well-ordered ones.

This approach does NOT help with the current codebase's problem, since the codebase is formalizing the chronicle/step-by-step approach from Burgess 1982.

### 5. The Key Mathematical Question: How Does Burgess Prove Claim 2.11 for G?

Answer: **technique (a) -- direct g_content propagation via C3**.

The proof goes:
1. G(phi) in f(x)
2. Take any y > x in the domain
3. By C5a, there exists some z > x with phi U ... But actually for G, we don't use C5a.
4. For G(phi) = ~F~phi in f(x), the semantics says: for all y > x, phi in f(y).
5. The forward direction uses coherence/C3: g_content(f(x)) subset f(y).

More precisely, C2 (r-relation) combined with C3 (interval decomposition) gives:
- r(f(x), g(x,y), f(y)) and g(x,y) being a DCS containing g_content(f(x))
- C3 tells us g(x,z) subset f(y) for x < y < z (interval decomposition)
- For adjacent x,y: C2' gives R-maximality which ensures g(x,y) contains at least g_content(f(x))

The answer to the question "does Burgess use (a), (b), (c), or (d)" is:

**(a) Direct g_content propagation** -- but mediated through the binary interval function g(x,y) and condition C3. The propagation is NOT maintained as a separate invariant; it is a consequence of the structural conditions C2, C2', C3 that the chronicle satisfies by construction.

## The Root Cause of the Sorry

The codebase's architecture differs from Burgess in a critical way:

| Aspect | Burgess 1982 | Current Codebase |
|--------|-------------|-----------------|
| Interval function | Binary g(x,y) for ALL pairs x < y | Defined as deductiveClosure(g_content(limit_f(x))) -- depends only on LEFT endpoint |
| Decomposition (C3) | g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z) -- EQUALITY | Not formalized (subset only via limit_c3) |
| g_content propagation | Falls from C2 + C3 | Must be proved as separate `g_content_chain_property` -- sorry |
| Point insertion | Lemma 2.6 gives B', D, B'' with g(x,z) = B' ∩ D ∩ B'' | Omega-chain inserts with g_content of triggering point only |

The sorry exists because the codebase defines `limit_g(x, y) = deductiveClosure(g_content(limit_f(x)))` -- a UNARY function of x alone -- rather than maintaining a proper binary interval function that satisfies C3.

In Burgess, when a new point z is inserted between x and y (Lemma 2.6), the construction explicitly produces:
- B' = g(x,z) -- the new left interval
- D = f(z) -- the new point assignment
- B'' = g(z,y) -- the new right interval
- WITH the identity: g(x,y) = B' ∩ D ∩ B''

This decomposition is what makes everything work. The codebase's omega-chain does not maintain this structural identity.

## Recommendations

### Option A: Faithful Burgess Implementation (Recommended)

Modify the chronicle construction to maintain a proper binary interval function g(x,y) satisfying C3 at every finite stage. This means:
1. Each elimination step (C5 forward/backward, C4 forward/backward) must use Lemmas 2.4-2.8 to produce both the new point MCS AND the new interval DCS values.
2. The limit g-function is then the union of the finite-stage g-functions (well-defined by the extension property).
3. g_content propagation follows from C2 + C3 in the limit.

This is the mathematically correct approach and matches what Burgess actually does.

### Option B: Prove g_content Chain Property Directly

Keep the current unary g-function and prove g_content_chain_property as a standalone theorem about the omega-chain limit. This requires showing:
- At each omega-chain step, newly inserted points have g_content of all predecessors in their MCS
- The enlarged-seed approach (plan v6): include g_content of all predecessors in the Lindenbaum seed

The analysis in the current sorry documentation (lines 710-742 of ChronicleConstruction.lean) correctly identifies that this is blocked: the seed enlargement requires F(eta) in f(max_point), which fails when the triggering point is not the maximum.

### Option C: Verbrugge-Style Direct Coherence

For the G/H portion only, follow Verbrugge and maintain ≺ (g_content subset) as a direct construction invariant. This works for G/H but does NOT solve the Until/Since truth lemma, which requires the full binary interval function.

### Assessment

Option A is the only approach that solves the problem completely. The current architecture's use of a unary g-function is a fundamental design error relative to the Burgess construction. The binary g-function and C3 decomposition identity are load-bearing structures, not optional.

## Appendix: Key Quotes from Sources

**Burgess 1982, Claim 2.11 proof** (the G-propagation sentence):
> "If z in X and x < z < y, then by C3 we have g(x,y) subset f(z), whence beta in f(z)."

**Burgess 1982, C3 condition**:
> "Whenever x, y, z in dom f and x < y < z, then g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)."

**Burgess 1982, Lemma 2.5** (the C3 preservation lemma):
> "Suppose we have R(A,B,C), r(A,B',D), r(D,B'',C) and B subset B' ∩ D ∩ B''. Then in fact B = B' ∩ D ∩ B''."

**Burgess 1984, Chronicle Lemma 1.9** (basic case):
> "If G(gamma) in T(x), then by Definition 1.8c, whenever xRy we have gamma in T(y)"

**Verbrugge 2004, Definition 2**:
> "Gamma ≺ Delta iff for each G(phi) in Gamma, phi in Delta"
