# Teammate C (Critic): Literature vs. Project Gap Analysis

**Task**: 107 - Chain design diagnostics for representation theorem
**Round**: 5
**Date**: 2026-04-23

---

## Question 1: Does Burgess's Logic Match the BX System?

### Burgess's Axioms (A1-A7, with mirror images A1b-A7b)

Burgess axiomatizes the Since/Until tense logic over arbitrary linear orders with 7 axiom schemas (plus mirrors) and 3 rules (Substitution, Modus Ponens, Temporal Generalization). The logic is PURELY TEMPORAL -- no modal operators at all. The temporal operators are:

- G, H (universal future/past) -- defined as abbreviations via Until/Since: `G(alpha) = ~U(~alpha, T)`, `F(alpha) = U(alpha, T)`
- U, S (Until, Since) -- primitive binary connectives

### The BX System (37 constructors)

The project's BX system has:
- **4 propositional** (prop_k, prop_s, ex_falso, peirce)
- **5 S5 modal** (modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist)
- **26 temporal** (temp_k_dist, temp_4, BX1-BX12 with primes)
- **2 interaction** (modal_future, temp_future)

### Precise Comparison

**Burgess axioms present in BX** (mapped by content, not numbering):

| Burgess | BX Equivalent | Notes |
|---------|---------------|-------|
| A1a: G(p->q) -> (U(p,r) -> U(q,r)) | BX2 (left_mono_until) | Exact match (modulo variable naming) |
| A2a: G(p->q) -> (U(r,p) -> U(r,q)) | BX3 (right_mono_until) | Exact match |
| A3a: p ^ U(q,r) -> U(q ^ S(p,r), r) | **MISSING from BX** | Connectedness via Until-Since interaction |
| A4a: U(p,q) ^ ~U(p,r) -> U(q ^ ~r, q) | **MISSING from BX** | Decomposition under failure |
| A5a: U(p,q) -> U(p, q ^ U(p,q)) | BX5 (self_accum_until) | Exact match |
| A6a: U(q ^ U(p,q), q) -> U(p,q) | BX6 (absorb_until) | Exact match |
| A7a: U(p,q) ^ U(r,s) -> ... three disjuncts | BX7 (linear_until) | Exact match |

**BX axioms NOT in Burgess**:

| BX Axiom | Content | Why Absent from Burgess |
|----------|---------|------------------------|
| BX1/BX1' (temp_t) | G(phi) -> phi | Burgess uses STRICT Until: U(alpha,beta) requires x < y (strict). G is defined as ~F(~alpha) where F = U(alpha, T), so G quantifies strictly. No reflexivity axiom needed. |
| BX4/BX4' (connect) | phi -> G(P(phi)) | Burgess derives this via A3a. The Until-Since interaction axiom A3a provides connectedness directly. |
| BX8/BX8' (refl_intro) | psi -> (phi U psi) | INVALID under strict Until. If U requires a STRICT future witness s > t, then psi at t does not give phi U psi at t. |
| BX9/BX9' (until_elim) | (phi U psi) -> (phi v psi) | Under strict Until: U(phi,psi) at t means exists s > t with psi(s) and phi on (t,s). This does NOT imply phi(t) or psi(t). The formula is INVALID under strict semantics. |
| BX10/BX10' (until_F) | (phi U psi) -> F(psi) | Under strict Until this is valid. But Burgess derives F from U differently. |
| BX11/BX11' (temp_linearity) | F(phi) ^ F(psi) -> ... | Burgess derives this from A7 (linear_until) + the F-Until connection. |
| BX12/BX12' (F_until_equiv) | F(phi) -> (T U phi) | Under strict Until, F(phi) IS T U phi by definition. Under reflexive Until, this needs an axiom. |
| All modal axioms | Box, Diamond | Burgess has no modal operators. |
| Interaction axioms | Box-G interaction | Burgess has no modal operators. |

**Burgess axioms MISSING from BX**:

| Burgess Axiom | Content | Impact |
|---------------|---------|--------|
| **A3a** | p ^ U(q,r) -> U(q ^ S(p,r), r) | This is the CRITICAL connectedness axiom that links Until and Since. It says: if p holds now and q-Until-r holds, then at the Until witness, S(p,r) also holds. This is the key axiom used in Lemma 2.3 to establish the R(A,B,C) relation. |
| **A4a** | U(p,q) ^ ~U(p,r) -> U(q ^ ~r, q) | Decomposition under partial failure. Used in Lemma 2.6 (counterexample repair). |

### Critical Assessment

**The BX system and Burgess's system axiomatize DIFFERENT semantics.** Burgess uses STRICT Until (witness s > t), while BX uses REFLEXIVE Until (witness s >= t). This is not merely a cosmetic difference:

1. BX8 (psi -> phi U psi) is VALID under reflexive semantics but INVALID under strict semantics.
2. BX9 ((phi U psi) -> phi v psi) is VALID under reflexive semantics but INVALID under strict semantics.
3. Burgess's A3a (the connectedness axiom linking U and S) is likely derivable under reflexive semantics using BX4 + BX8, but this has not been verified.

The reflexive/strict distinction is the SINGLE MOST IMPORTANT difference between the two systems. It affects the entire proof strategy.

**Confidence**: HIGH. The semantic definitions in Truth.lean (line 128: `t <= s`) and Burgess's paper (Section 1.2: `x < y`) are unambiguous.

---

## Question 2: Does the Project's Chain Architecture Match Burgess's Construction?

### Burgess's Construction

Burgess builds a "chronicle" -- a pair (f, g) where:
- f maps rational numbers to MCS (f(x) = the MCS at time x)
- g maps pairs (x,y) with x < y to DCS (deductively closed sets) -- g(x,y) = the "interval content" between x and y

The key conditions are:
- **C2**: r(f(x), g(x,y), f(y)) -- the interval relation holds
- **C2'**: R(f(x), g(x,y), f(y)) -- the interval relation is MAXIMAL for adjacent points
- **C3**: g(x,z) = g(x,y) intersection f(y) intersection g(y,z) -- interval decomposition
- **C4a/C5a**: Counterexample elimination for ~U and U formulas

The construction is ITERATIVE: start with a single point, extend by adding one point at a time (Lemmas 2.9, 2.10), and take the union of an omega-chain of finite chronicles.

### The Project's Construction

The project builds an INT-indexed chain:
- Forward: `fwd_chain_of_sigma` iterates `preserving_fwd_step` from M_0
- Backward: `bwd_chain_of_sigma` iterates `bwd_pred` from M_0
- Assembly: `dd_chain` splices forward (t >= 0) and backward (t < 0) at the origin

There is NO interval content g(x,y). The chain is a function from Int to MCS, period.

### Structural Mismatch Analysis

| Feature | Burgess | Project | Gap |
|---------|---------|---------|-----|
| Time domain | Rationals Q | Int (Z) | Different density class |
| Interval content | g(x,y) tracks what holds between x and y | g_content(M) extracts G-content from a single MCS | g_content is a UNARY function, not binary |
| Construction strategy | Add points to repair counterexamples | Build chain by iterating successor construction | Fundamentally different |
| Until resolution | C5a: exists future point with xi in f(y), eta in g(x,y) | fwd_chain_forward_F: exists future step with phi in chain(m) | Only the F-part; NO interval guard |
| Since/Until interaction | A3a + Lemma 2.3 establishes R(A,B,C) linking U and S | No analogous mechanism | The project has BX4 (connect_future/past) but NOT A3a |
| Linearity | A7 used in Lemma 2.7 to handle Until conflicts | BX7 (linear_until) present but not used in chain construction | Axiom present, usage absent |
| Counterexample repair | Lemmas 2.6 (delta not in B), 2.7 (U(xi,eta) with eta not in B) | No counterexample repair mechanism | Entire Burgess proof strategy is absent |

### The Fundamental Architectural Mismatch

Burgess's g(x,y) is NOT the same as the project's g_content(M). The critical difference:

- **Burgess g(x,y)**: A DCS that tracks what is TRUE throughout the entire interval (x,y). It is a BINARY function of the two endpoints, and satisfies C3 (intersection property). It is constructed to be MAXIMAL (condition R).
- **Project g_content(M)**: The set {phi | G(phi) in M}. It is a UNARY function of M alone. It tells you what M "demands" of its successors, but says nothing about what holds between M and any specific future MCS.

This difference means Burgess's key lemma (2.5: R(A,B,C) intersection property) and the repair lemmas (2.6, 2.7, 2.8) have no analogue in the project.

**Can the project's architecture be adapted?** Not without fundamental restructuring. The project would need to:
1. Introduce a binary interval function between chain points
2. Ensure the maximality condition R
3. Implement counterexample repair (adding intermediate points)

This is essentially rebuilding the chain construction from scratch following Burgess's pattern.

**Confidence**: HIGH. The code is explicit about dd_chain being Int -> Set Formula, with g_content being M -> Set Formula.

---

## Question 3: What Does the Project Need That the Literature Does NOT Provide?

### What the project needs (from the 5 sorries)

1. **restricted_temporally_coherent** (sorry #1-3): F(phi) in fam.mcs(t) implies exists s > t with phi in fam.mcs(s), restricted to phi in deferralClosure(root)

2. **restricted_backward_until_since_coherent** (sorry #4): Given witnesses (psi at s, phi on guard [t,s)), derive (phi U psi) in fam.mcs(t). This requires a "step transfer" property: (phi U psi) in chain(r+1) and phi in chain(r) implies (phi U psi) in chain(r).

3. **restricted_forward_until_since_coherent** (sorry #5): Given (phi U psi) in fam.mcs(t), produce a witness s >= t with psi in fam.mcs(s) and phi in fam.mcs(r) for all r in [t,s).

4. **All within BFMCS structure**: The bundled family of MCS must satisfy these properties for ALL families simultaneously.

5. **Over a totally ordered abelian group**: The project uses a generic D with AddCommGroup + LinearOrder + IsOrderedAddMonoid. But the chain is actually built over Int.

### What Burgess provides

Burgess provides (in his completeness proof):
- C5a: Given U(xi, eta) in f(x), produce y with xi in f(y) and eta in g(x,y). This is the FORWARD Until coherence.
- C4a: Given ~U(gamma, delta) in f(x) and gamma in f(y), produce z between with ~delta in f(z). This is the COUNTEREXAMPLE condition (not the same as backward Until).
- The interval property C3 provides the guard condition implicitly: g(x,y) subset f(z) for all z between x and y.

### Gap Analysis

| Need | Burgess Provides? | Notes |
|------|-------------------|-------|
| F-resolution (sorry #1) | YES, via C5a (Until with T as guard) | F(phi) = T U phi under strict semantics, so C5a directly gives a witness |
| P-resolution (sorry #2-3) | YES, via C5b (mirror) | Symmetric |
| Step transfer for Until (sorry #4) | INDIRECTLY | Burgess doesn't need step transfer because his interval function g(x,y) provides the guard condition directly. The step transfer problem arises from the project's LINEAR chain architecture which lacks interval content. |
| Forward Until coherence (sorry #5) | YES, via C5a + C3 | C5a gives the witness, C3 ensures the guard via g(x,y) subset f(z) |
| BFMCS structure | NO | Burgess has no modal operators and no need for multiple families |
| Generic D | NO | Burgess works over Q specifically. The project needs D = Int (for the chain), not Q. |
| Restricted to deferralClosure | NO | Burgess quantifies over all formulas. The project's restriction is an optimization for finite closure. |
| Modal saturation | NO | Burgess has no Box/Diamond |

### Critical Finding

**Burgess's proof does NOT face the step transfer problem** because his architecture is fundamentally different. The step transfer problem is an ARTIFACT of the project's linear chain design, not an inherent obstacle of the mathematical problem. In Burgess's proof, the interval content g(x,y) directly encodes what holds on the guard interval. The project's chain construction lacks this mechanism entirely.

Similarly, Burgess does NOT face the "backward chain P-resolution" problem because his construction builds the model DENSELY (over Q), adding points wherever needed, rather than building a fixed-step chain from a root.

**Confidence**: HIGH.

---

## Question 4: Is the "Lindenbaum Non-Determinism" Problem Present in Burgess/Verbrugge?

### The Project's Problem

The project's key obstacle: Lindenbaum's lemma produces an opaque MCS that may or may not contain specific F-formulas. When building `fwd_chain_of_sigma`, each step uses `preserving_fwd_step` which extends a consistent seed to an MCS. The resulting MCS may not contain the desired formula phi even though F(phi) was in the predecessor.

### Burgess's Treatment

YES, Burgess faces the same Lindenbaum non-determinism, but his proof CONTROLS it through a different mechanism:

1. In Lemma 2.4, given U(gamma, beta) in A, Burgess constructs a SPECIFIC consistent seed C_0 = {gamma} union {S(alpha, beta) : alpha in A} and then extends it to any MCS C. The key is that C_0 is DESIGNED to ensure the desired properties (gamma in C, and r(A, beta, C) holds).

2. The MAXIMALITY condition R(A, B, C) is critical. B is chosen to be MAXIMAL with respect to the r(A, --, C) relation. This means that for any delta NOT in B, there exists a specific counterexample (a gamma in C such that U(gamma, beta ^ delta) not in A). This maximality eliminates much of the non-determinism.

3. In the repair lemmas (2.6, 2.7, 2.8), Burgess constructs a D_0 seed that is PROVEN consistent (using the axioms A4a, A5a, A7a crucially) before extending to an MCS D. The construction is:
   ```
   D_0 = {S(alpha, beta) : alpha in A, beta in B}
         union B
         union {~delta}  (or {xi})
         union {U(gamma, beta) : gamma in C, beta in B}
   ```
   The consistency proof uses A4a (decomposition under failure) and A5a (self-accumulation) to show this specific seed is consistent.

### How Burgess Overcomes Non-Determinism

The answer: **by controlling the seed**. Rather than relying on g_content propagation (which loses F-formulas), Burgess puts EVERYTHING he needs into the seed before calling Lindenbaum. The seed includes:
- All S(alpha, beta) formulas needed for the r relation (backward link)
- All U(gamma, beta) formulas needed for the r relation (forward link)
- The specific formula ~delta or xi that is being resolved
- The interval content B (everything that persists)

After Lindenbaum extends this to an MCS D, ALL the needed properties are guaranteed because they were in the seed.

### Contrast with the Project

The project's chain construction puts only g_content(M) into the seed (the "what G demands" part). It does NOT put U-formulas, S-formulas, or F-formulas into the seed. This is why F-obligations are lost.

**The fix is NOT to prove F-propagation on the chain. The fix is to ENRICH THE SEED to include the formulas that must persist.**

But here is the catch: Burgess's seed D_0 includes formulas from BOTH the predecessor A and the successor C. This requires knowing C in advance. In the project's linear chain, the successor is not known when constructing the seed -- it IS the result of the construction. This is a chicken-and-egg problem that Burgess avoids by building the model as a FINITE chronicle that is extended point by point, with full knowledge of both endpoints when inserting an intermediate point.

**Confidence**: HIGH.

---

## Question 5: What Is the Exact Mismatch That Has Prevented Application of the Standard Technique?

After analyzing the full picture, the mismatch has THREE layers:

### Layer 1: Semantic Mismatch (Reflexive vs Strict Until)

Burgess uses STRICT Until (s > t). The project uses REFLEXIVE Until (s >= t). This changes which axioms are valid and which proof steps work. For example:

- BX8 (psi -> phi U psi) enables trivial backward Until via the reflexive base case (s = t). Burgess cannot use this.
- Burgess's A3a (the connectedness axiom linking U and S) relies on strict semantics. Under reflexive semantics, U(gamma, delta) at t could have witness s = t, making the S(alpha, delta) at s = t trivially satisfiable (since alpha is at t = s). This may make A3a derivable from BX4 + BX8, but the derivation has not been attempted.

The BX system has axioms (BX8, BX9, BX12) that are NOT in Burgess because they are INVALID under strict semantics. Conversely, Burgess has A3a and A4a which are NOT in BX (possibly derivable, but unverified).

### Layer 2: Architectural Mismatch (Chronicle vs Linear Chain)

Burgess builds a finite chronicle (f, g) over Q with an INTERVAL FUNCTION g(x,y). The project builds a LINEAR CHAIN over Z with NO interval function. The interval function is the key mechanism for tracking "what holds between" two points, and its absence forces the project to try to derive interval properties from single-point MCS properties, which does not work.

### Layer 3: Construction Strategy Mismatch (Counterexample Repair vs Forward/Backward Extension)

Burgess builds the model by repeatedly repairing counterexamples: start with a finite chronicle, find a violation of C4a or C5a, insert a point to fix it. The project builds the model by extending a chain in both directions from a root point, using g_content propagation forward and h_content propagation backward.

The counterexample repair strategy naturally handles ALL obligations (F, P, Until, Since) uniformly. The forward/backward extension strategy handles G/H propagation well but LOSES existential obligations (F, P, Until witness, Since witness).

### Why 76+ Rounds Didn't Apply the Standard Technique

1. **Rounds 1-3 (early research)**: Did not consult the literature at all.
2. **Round 4 (task 107 team research)**: Identified the literature gap but did not study the actual proofs.
3. **This round**: First actual comparison of axiom systems and proof strategies.

The fundamental reason is that the project was built with a LINEAR CHAIN architecture before the mathematical literature was consulted. The chain architecture (iterate fwd_succ from a root, sew forward and backward halves at the origin) was chosen based on analogy with standard modal completeness proofs (canonical model + generated submodel), not based on the temporal logic literature. The temporal logic completeness proof requires a fundamentally different architecture (chronicle with interval content, or Verbrugge-style step-by-step construction), and retrofitting the existing ~5,200 lines of sorry-free infrastructure to use a different architecture is extremely costly.

**Confidence**: HIGH.

---

## Question 6: Are There Hidden Assumptions in the Literature Proofs?

### Strict Until Assumption

**YES, this is critical.** Burgess assumes STRICT Until:
```
V(U(alpha,beta)) = {x : exists y (x < y and y in V(alpha) and forall z (x < z < y -> z in V(beta)))}
```

The project uses REFLEXIVE Until:
```
truth_at(untl phi psi, t) = exists s : D, t <= s and truth_at(psi, s) and forall r, t <= r -> r < s -> truth_at(phi, r)
```

Key differences:
- **Guard interval**: Burgess uses open interval (x, y) = {z : x < z < y}. Project uses half-open interval [t, s) = {r : t <= r, r < s}.
- **Witness**: Burgess requires y > x (strict future). Project allows s = t (present).
- **Consequence**: Under reflexive Until, U(phi, psi) at t with witness s = t gives psi at t with empty guard. Under strict Until, there MUST be a strictly future witness.

### Full Closure Assumption

Burgess works with ALL formulas -- his MCS are maximally consistent sets of the FULL formula language. There is no restriction to a finite closure.

The project restricts to `deferralClosure(root)` -- a finite set. This is the "adequate set" approach from Verbrugge (Definition 4-8), NOT from Burgess. Burgess's proof does not use adequate sets; Verbrugge's does (for Z, Z circle Z, etc.).

### No Modal Operators

Burgess handles ONLY temporal operators (G, H, U, S). The project's BX system additionally has S5 modal operators (Box, Diamond) with interaction axioms (modal_future, temp_future). The completeness proof must handle:
- Modal saturation of the BFMCS (families for each possible world)
- The interaction axioms modal_future (Box(phi) -> Box(G(phi))) and temp_future (Box(phi) -> G(Box(phi)))

Burgess's proof provides NO guidance for the modal layer. The project's modal saturation infrastructure appears to be sorry-free, so this may not be a blocking issue, but it means the literature proof cannot be applied "as is."

### Linear Order Assumption

Burgess assumes a GENERIC linear order. Verbrugge's proofs for Z, Z circle Z, etc., use specific structural properties of those orders. The project's semantics uses a "totally ordered abelian group" (AddCommGroup + LinearOrder + IsOrderedAddMonoid), which is more structured than Burgess's arbitrary linear order. The chain is built over Int specifically.

### Density vs Discreteness

Burgess's proof produces a model over Q (the rationals) -- a DENSE linear order. Verbrugge's proof for Z uses FINITE adequate sets and constructs a DISCRETE model.

The project targets Int (a discrete order) but uses the axiom system for arbitrary linear orders (no discreteness axioms). This means:
- The project CANNOT use Burgess's dense-order technique (inserting points between any two existing points)
- The project CAN potentially use Verbrugge's discrete technique (finite adequate sets, step-by-step construction over Z)

But Verbrugge's proofs are for G/H tense logic only -- no Until/Since! The adequate set technique for Until/Since over Z would need to combine Burgess's Until/Since handling with Verbrugge's discrete construction, which is exactly the combination that nobody has published.

**Confidence**: HIGH for all items.

---

## Critical Gap Summary

The precise mismatch between literature and project is a TRIPLE gap:

1. **Semantic gap**: Reflexive vs strict Until. The project's axioms (BX8, BX9) are invalid under strict semantics; Burgess's axioms (A3a, A4a) may be derivable under reflexive semantics but this is unverified.

2. **Architectural gap**: Chronicle with interval function g(x,y) vs linear chain with g_content(M). The interval function is the KEY mechanism in Burgess's proof; the project lacks it entirely.

3. **Domain gap**: Burgess proves completeness over Q (dense); the project needs a model over Z (discrete). Verbrugge handles Z but only for G/H (no Until/Since).

---

## Obstacles to Direct Application

1. **Cannot copy Burgess's axiom system**: BX has axioms (BX8, BX9, BX12) that Burgess does not have, and lacks axioms (A3a, A4a) that Burgess needs. The proof steps that use A3a (Lemma 2.3) and A4a (Lemma 2.6) must be re-derived using BX axioms if they are derivable at all.

2. **Cannot copy Burgess's chronicle architecture**: The project has ~5,200 lines of sorry-free infrastructure built on the linear chain architecture. Switching to chronicles with interval content would orphan this infrastructure.

3. **Cannot copy Burgess's dense construction for a discrete model**: Burgess builds over Q; the project needs Z. The counterexample repair strategy (insert midpoints) relies on density.

4. **Cannot copy Verbrugge's discrete construction for Until/Since**: Verbrugge only handles G/H. Her technique for Z uses "maximal/minimal" immediate successors and cyclic treatment of defects, which is promising but has never been extended to Until/Since in the published literature.

5. **The step transfer problem is an artifact of the chain architecture**: Burgess does not have this problem because his interval function g(x,y) directly provides the guard. The project created this problem by choosing a chain without interval content.

---

## Recommended Adaptations

### Option A: Derive A3a and A4a in BX (5-15 hours estimated)

Attempt to derive Burgess's A3a and A4a as BX theorems using BX4 (connectedness) + BX8 (reflexive intro) + BX5/BX6 (accumulation/absorption). If successful, Burgess's Lemma 2.3 (the R relation) and repair lemmas (2.6, 2.7, 2.8) can be adapted to BX.

**Risk**: A3a or A4a may NOT be derivable in BX. If not, the entire Burgess strategy fails for this axiom system, and a new proof is needed.

### Option B: Enrich the chain seed (10-20 hours estimated)

Keep the linear chain architecture but enrich the seed at each step to include Until/Since formulas, not just g_content. Specifically, for each step from chain(n) to chain(n+1), include in the seed:
- g_content(chain(n)) (what G demands) -- already present
- {phi U psi : phi U psi in chain(n)} (Until persistence)
- {phi : phi U psi in chain(n) and psi not in chain(n)} (guard preservation)

**Risk**: The enriched seed may be inconsistent. The consistency proof requires the equivalents of A3a and A4a, leading back to Option A.

### Option C: Hybrid approach with interval tracking (20-40 hours estimated)

Add an interval content function to the chain construction, maintaining g_content(chain(n), chain(m)) for all n < m as a tracked invariant. This would provide the guard condition needed for Until coherence without changing the chain iteration.

**Risk**: Major infrastructure change. The intersection property (C3 in Burgess) requires careful maintenance.

### Option D: Verbrugge-style adequate set construction for BX (30-50 hours estimated)

Build a new chain construction following Verbrugge's method for Z (Theorem 6), extended with Until/Since handling. Use adequate sets (finite closure of root formula) and the "maximal/minimal successor" strategy. This would be a new proof technique, not a copy of either Burgess or Verbrugge.

**Risk**: Novel proof, no literature guide for the Until/Since extension. May require significant proof engineering.

### Recommended Priority

1. **First**: Attempt to derive A3a in BX (2-5 hours). This is the single highest-value action because it determines whether the Burgess strategy is available at all.
2. **If A3a derivable**: Adapt Burgess's Lemma 2.3 and repair lemmas to BX, then implement Option B or C.
3. **If A3a not derivable**: Pursue Option D (Verbrugge-style adequate set for BX with Until/Since).

---

## Confidence Levels

| Finding | Confidence | Basis |
|---------|------------|-------|
| Burgess uses strict Until, BX uses reflexive | HIGH | Explicit in definitions |
| A3a and A4a are missing from BX | HIGH | Exhaustive axiom comparison |
| Chronicle architecture differs from linear chain | HIGH | Code inspection vs paper |
| Step transfer is an architecture artifact | HIGH | Structural analysis |
| A3a may be derivable in BX | MEDIUM | BX4 + BX8 cover similar ground, but no derivation attempted |
| Verbrugge extension to Until/Since possible | MEDIUM | Structural similarity of techniques, but unpublished |
| ~5,200 LOC infrastructure is sound | HIGH | Per prior research (sorry-free above chain layer) |
| FMP/filtration ruled out | HIGH | Technical and policy grounds (from Round 4) |
