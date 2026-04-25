# Teammate A Findings: Venema 1993 "Completeness via Completeness" — Full Paper Analysis

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-24
**Source**: Venema, Yde. "Completeness via Completeness: Since and Until." In *Diamonds and Defaults*, Synthese Library 229, Kluwer, 1993.
**Paper length**: 8 pages, 5 sections, ~3 main theorems

---

## 1. Paper Summary

Venema axiomatizes the valid formulas of Since/Until logic over **well-orderings** (system **BW**) and over **the natural numbers** (system **BN**), using only orthodox derivation rules (MP, TG, SUB). The key innovation is that axiomatic completeness is obtained *via* expressive completeness of the SU language, combined with a model-replacement theorem due to Doets. The paper explicitly avoids the irreflexivity rule (IR) that Gabbay-Hodkinson use.

The proof is remarkably short: the entire completeness argument for well-orderings is 4 steps, occupying roughly 2 pages (Sections 3.8, 4.1, 4.2). The proof for omega is an additional 3 lines (Theorem 4.3).

---

## 2. Proof Architecture

### 2.1 Overall Strategy

The proof has three pillars:

| Pillar | Result | Source |
|--------|--------|--------|
| **Burgess completeness** (Theorem 3.5) | B is complete for all linear orders (LO) | Burgess 1982 [B] |
| **Expressive completeness** (Theorem 3.1) | SU is expressively complete over Dedekind-complete orders (DO), hence over WO | Kamp [K] |
| **Model replacement** (Theorem 3.8, Doets) | Definably well-ordered linear models have n-equivalents in WO for all n | Doets [D] |

The completeness proof (Theorem 4.2) then proceeds:

1. Let phi be BW-consistent.
2. By Lindenbaum, extend to a maximal BW-consistent set Phi containing phi.
3. Since BW extends B, Phi is also B-consistent. By Burgess completeness (3.5), there exists a **linear model** M satisfying Phi.
4. Since M satisfies all BW-axioms (including W), M is a BW-model.
5. By **Lemma 4.1**, every BW-model is definably well-ordered.
6. By **Doets's theorem (3.8)**, M has an (n+1)-equivalent well-ordered model M', where n = quantifier depth of phi^c.
7. Since M and M' agree on sentences of quantifier depth <= n+1, and phi^c has quantifier depth n, M' also satisfies phi.
8. M' is the desired well-ordered model.

### 2.2 How Venema Avoids the Chronicle/Omega-Chain Construction

**Venema never constructs a canonical model at all.** Instead, he:

1. Uses Burgess's completeness for LO to get a *linear* model (which may not be well-ordered).
2. Shows this model is *definably* well-ordered (thanks to axiom W).
3. Uses Doets's model-replacement theorem to swap it for a genuinely well-ordered model.

The crucial insight: **no explicit construction of a well-ordered model is needed**. The model is obtained by a non-constructive model-theoretic replacement argument. There is no chronicle, no omega-chain, no step-by-step seed extension, no g_content propagation.

### 2.3 The Role of Dedekind Completeness

Dedekind completeness enters indirectly through Kamp's theorem: SU is expressively complete over Dedekind-complete orders. Since well-orderings are Dedekind-complete, SU is expressively complete over WO. This expressive completeness is used in the proof of Lemma 4.1 (see below).

### 2.4 Doets's Model Replacement (Theorem 3.8)

Doets's result says: if M is a definably well-ordered linear model, then for every n, M has an n-equivalent in WO.

The proof sketch:
- Define Z = {a in T | for all b < a, [b,a) has a well-ordered n-equivalent}.
- Z is definable (hence so is its complement Z-bar).
- If Z-bar is non-empty, its smallest element a leads to contradiction (every [b,a) has a well-ordered n-equivalent, so a should be in Z).
- Therefore Z = T, meaning every interval has a well-ordered n-equivalent.
- Apply the same argument globally to get M itself has a well-ordered n-equivalent.

**This is essentially a first-order compactness/back-and-forth argument.** The n-equivalence means Ehrenfeucht-Fraisse games of depth n can be won.

---

## 3. G-Content Analysis

### 3.1 Does Venema Face the g_content_chain_property Obstacle?

**No.** Venema's proof completely bypasses this problem because:

1. **No canonical model is constructed.** The model comes from Burgess's completeness for LO, which builds a standard Henkin/canonical model for linear orders. This is well-understood and the truth lemma for linear orders is straightforward (Burgess 1982).

2. **No step-by-step extension of MCS along a chain.** The Burgess canonical model for LO gives you a model where all consistent formulas are already satisfied. The challenge of propagating G-formulas through an omega-chain never arises.

3. **The G-case of the truth lemma is handled entirely within Burgess's completeness for LO.** In a standard Henkin model for linear temporal logic, the truth lemma works because maximal consistent sets are constructed to respect the canonical ordering. G(phi) holds at a point iff phi is in all future-accessible MCS — this is the standard canonical model construction for basic tense logic.

### 3.2 How the Truth Lemma's G-Case Works (in Burgess's Part)

Venema does not reprove the truth lemma. He cites Burgess 1982, Theorems 1.4 and 1.5. In Burgess's construction for LO:

- Points are MCS of the logic B.
- The canonical ordering is defined so that u < v iff for all G(phi) in u, phi is in v (and dually for H).
- The truth lemma is proved by induction on formula complexity.
- For G(phi): "G(phi) in u" iff "for all v > u in the canonical ordering, phi in v" — this is definitional from how the canonical ordering is set up.

**The g_content IS the canonical ordering.** There is no separate "g_content propagation" problem because the ordering is defined in terms of G-content from the start.

### 3.3 What Structural Feature Avoids the Problem

The key structural difference: Burgess's completeness for LO produces a model over **all linear orders**, not specifically well-orderings. The well-ordering property is then obtained by model replacement, not by constructing a well-ordered model directly. This two-step approach completely avoids the need to:

- Build an omega-chain of MCS
- Propagate G-content along the chain
- Ensure limit points have the right G-formulas

---

## 4. BX Applicability

### 4.1 What Frame Class Does Venema Target?

Venema targets **well-orderings** (axiom system BW) and **the natural numbers** (axiom system BN). His semantics uses **strict** < throughout — the truth conditions for U(phi, psi) use strict inequalities t < u < v. This matches BX's irreflexive semantics.

### 4.2 Does Venema's Technique Extend to Arbitrary Strict Linear Orders?

**No, not directly.** Here is the critical limitation:

Venema's proof depends on:
1. **Burgess completeness for LO** (Theorem 3.5) — this covers ALL linear orders, including strict ones. This part is fine.
2. **Axiom W: Fp -> U(p, not-p)** — this characterizes well-orderings. It says "if p holds in the future, then p holds at the first future point where p holds, with not-p holding everywhere before." This axiom is NOT valid on arbitrary strict linear orders (e.g., the rationals, the reals).
3. **Doets's model replacement** — this converts definably well-ordered models to genuinely well-ordered ones. It specifically targets WO, not arbitrary LO.

**BX targets all strict linear orders**, not just well-orderings. Venema's proof therefore does NOT directly apply to BX's frame class.

### 4.3 What Would Be Needed for BX's Frame Class?

To adapt Venema's approach for arbitrary strict linear orders, you would need:
- A version of Doets's theorem for arbitrary linear orders (not just well-orderings)
- A replacement for axiom W that characterizes the target frame class
- A proof that the resulting models are "definably X" for the appropriate property X

For arbitrary strict linear orders, no such adaptation exists in Venema's paper. The Gabbay-Hodkinson 1990 paper handles the **reals** (Dedekind-complete dense linear orders) but uses the IR rule.

### 4.4 Axiom Mapping: Venema's B vs BX

| Venema (B) | BX Equivalent | Notes |
|------------|---------------|-------|
| A1a: G(p->q) -> (U(p,r) -> U(q,r)) | BX2 (left_mono_until) | Same |
| A2a: G(p->q) -> (U(r,p) -> U(r,q)) | BX3 (right_mono_until) | Same |
| A3a: p & U(q,r) -> U(q & S(p,r), r) | BX4 (connect_future) | Same — temporal connectedness |
| A4a: U(p,q) & not-U(p,r) -> U(q & not-r, q) | BX7 (linear_until) | Linearity |
| A5a: U(p,q) -> U(p, q & U(p,q)) | BX5 (self_accum_until) | Self-accumulation |
| A6a: U(q & U(p,q), q) -> U(p,q) | BX6 (absorb_until) | Absorption |
| A7a: U(p,q) & U(r,s) -> U(p&r,q&s) v U(p&s,q&s) v U(q&r,q&s) | — | Linearity of witnesses |
| A1b-A7b: mirror images | BX2'-BX7' | Past duals |
| W: Fp -> U(p, not-p) | NOT IN BX | Well-ordering axiom |
| L: H-bot v PH-bot | NOT IN BX | Existence of smallest element |
| D: F-top -> U(top,bot) & P-top -> S(top,bot) | NOT IN BX | Discreteness |

**BX axioms NOT in Venema's B**:
- BX1/BX1' (serial_future/past): seriality — Venema's linear orders may have endpoints
- BX9/BX9' (until_elim/since_elim): current-time elimination
- BX10/BX10' (until_F/since_P): eventuality extraction
- BX11/BX11' (temp_linearity): future linearity
- BX12/BX12' (F_until_equiv/P_since_equiv): F-Until bridge
- temp_k_dist: temporal K distribution
- temp_4: temporal transitivity G(phi) -> G(G(phi))

**Venema's A7a is not directly in BX** as a single axiom. It may be derivable from BX7 + other BX axioms.

### 4.5 Does Venema Use the IRR Rule?

**No.** This is the paper's main selling point. Venema explicitly avoids the irreflexivity rule, using only orthodox rules (MP, TG, SUB). He discusses IR at length in Section 1, noting its disadvantages and arguing that orthodox axiomatizations are preferable.

However, BX's codebase does have IRR infrastructure (ConservativeExtension/). Venema's avoidance of IRR is for well-orderings specifically — he does not claim to avoid IRR for arbitrary linear orders.

---

## 5. Formalization Feasibility

### 5.1 Complexity Assessment

The paper is remarkably compact. The actual new content is:

| Component | Complexity | Lines of math |
|-----------|-----------|---------------|
| Stavi connective semantics (Def 2.3) | Low | ~10 lines |
| Lemma 4.1 (BW-model => definably w.o.) | Medium | ~15 lines |
| Theorem 3.8 (Doets model replacement) | HIGH | ~20 lines, but relies on [D] |
| Theorem 4.2 (completeness for WO) | Low (given above) | ~10 lines |
| Theorem 4.3 (completeness for omega) | Trivial (given 4.2) | 3 lines |

**Total new content**: approximately 50-60 lines of mathematical proof.

### 5.2 What Would Need to Be Formalized from Scratch

To implement Venema's proof in Lean, the following infrastructure is needed:

**Already exists in codebase**:
- Formula syntax with S, U, G, H, F, P (Syntax/)
- BX axiom system (ProofSystem/Axioms.lean)
- MCS construction (Core/MaximalConsistent.lean)
- Lindenbaum lemma (presumably in Core/)
- Soundness (Metalogic/Soundness.lean)

**Does NOT exist — would need to be built**:

1. **Burgess completeness for LO** (~2000-4000 lines)
   - Canonical model construction for basic tense logic B
   - Full truth lemma for B over linear orders
   - This is a MAJOR piece of infrastructure — Burgess 1982 is a substantial paper
   - The codebase currently only has BX canonical model infrastructure, not B

2. **First-order logic translation** (~500-1000 lines)
   - Translation function c from SU formulas to L(x) formulas
   - Quantifier depth function
   - Correctness: M,t |= phi iff M |= phi^c(t)

3. **Expressive completeness (Kamp's theorem)** (~5000-10000+ lines)
   - This is one of the deepest results in temporal logic
   - Every first-order formula with one free variable over DO has an SU equivalent
   - The proof involves separation and composition arguments
   - **This alone would be a multi-month formalization project**

4. **Stavi connectives and S'U' expressive completeness** (~2000-4000 lines)
   - S'U' is expressively complete over all LO (Stavi's theorem)
   - Gap semantics formalization
   - Translation from S'U' to L(x)

5. **Doets's model replacement theorem** (~1500-3000 lines)
   - Definition of "definably well-ordered"
   - n-equivalence (Ehrenfeucht-Fraisse games)
   - The Z-set argument
   - Construction of the well-ordered n-equivalent

6. **Lemma 4.1: BW-model => definably w.o.** (~500-1000 lines)
   - Induction through S'U' formulas
   - U'(psi,chi) equivalent to bot via axiom W
   - Uses expressive completeness of S'U' over LO

### 5.3 Estimated Lean Code Volume

| Component | Lines (estimate) |
|-----------|-----------------|
| Burgess completeness for B/LO | 3000 |
| First-order translation + correspondence | 800 |
| Kamp's theorem (expressive completeness) | 8000+ |
| Stavi connectives + S'U' completeness | 3000 |
| Doets's model replacement | 2000 |
| Lemma 4.1 + Theorems 4.2, 4.3 | 500 |
| **Total** | **~17,000+** |

### 5.4 Does Existing Infrastructure Help?

**Mostly no.** The existing sorry-free infrastructure (PointInsertion, RRelation, OrderedSeedConsistency, g/h duality) is all designed for the Burgess chronicle construction, which Venema's approach completely bypasses. Specifically:

| Existing Module | Useful for Venema? |
|-----------------|-------------------|
| PointInsertion | No — chronicle-specific |
| RRelation | No — chronicle-specific |
| OrderedSeedConsistency | No — seed extension for chronicles |
| g/h duality | Partially — conceptual, not directly |
| ChronicleTypes | No — chronicle-specific |
| CounterexampleElimination | No — chronicle-specific |
| MCS infrastructure (Core/) | YES — Lindenbaum, MCS properties |
| Axiom definitions | YES — BX axioms are a superset of B |
| Soundness | YES — reusable |
| FMP infrastructure | No — different approach |

**Bottom line**: Only the foundational MCS machinery and axiom/soundness infrastructure would carry over. The chronicle-specific code (~20 files, ~5000+ lines) would be entirely bypassed.

---

## 6. Key Theorems and Definitions

### 6.1 Main Theorems (with Statements)

| # | Theorem | Statement | Exists in Codebase? |
|---|---------|-----------|-------------------|
| 3.1 | Expressive Completeness | SU is expressively complete over DO; S'U' over LO | NO |
| 3.5 | Burgess Completeness | Sigma |-_B phi iff Sigma |=_LO phi | NO (only BX completeness attempted) |
| 3.8 | Doets Model Replacement | Definably w.o. linear model has n-equivalents in WO | NO |
| 4.1 | BW-model => definably w.o. | Every BW-model is definably well-ordered | NO |
| 4.2 | BW Completeness | |-_BW phi iff WO |= phi | NO |
| 4.3 | BN Completeness | |-_BN phi iff (omega,<) |= phi | NO |

### 6.2 Key Definitions

| Definition | Description | Exists? |
|------------|-------------|---------|
| Stavi connectives U', S' | Binary operators using "gaps" | NO |
| Gap of a frame | Downward-closed set without supremum | NO |
| Definably well-ordered | Every L(x)-definable subset has a minimum | NO |
| n-equivalence | Agreement on sentences of quantifier depth <= n | NO |
| Axiom W: Fp -> U(p, not-p) | Well-ordering axiom | NO |
| Axiom L: H-bot v PH-bot | Smallest element axiom | NO |
| Axiom D: discreteness | F-top -> U(top,bot) & P-top -> S(top,bot) | NO |

### 6.3 Constructions NOT in the Codebase

Every major construction in Venema's proof is absent from the codebase:
- First-order translation c
- Stavi connective semantics
- Gap notion
- Definable well-ordering
- n-equivalence / EF games
- Doets's Z-set construction
- Burgess canonical model for B (only BX canonical model exists)

---

## 7. Confidence Level

**HIGH confidence** in all findings. The paper is short, self-contained, and the mathematical content is unambiguous.

### 7.1 Key Conclusions

1. **Venema's proof is elegant but NOT applicable to BX.** BX targets all strict linear orders; Venema targets well-orderings. The axiom W is essential to Venema's proof and is not valid on arbitrary linear orders.

2. **The proof completely avoids the g_content_chain_property obstacle** by never constructing a canonical model for well-orderings directly. Instead, it uses model replacement (Doets) on top of Burgess's completeness for all linear orders.

3. **Formalization would be enormous** (~17,000+ lines) due to deep prerequisites: Kamp's expressive completeness theorem alone is a major formalization effort. The paper's brevity is deceptive — it cites heavyweight results from [B], [D], [G], and [K].

4. **Existing chronicle infrastructure is entirely wasted** under Venema's approach. Only basic MCS machinery carries over.

5. **The paper does NOT use the IRR rule**, but this is specifically for well-orderings where axiom W substitutes. For arbitrary strict linear orders (BX's target), the question of whether IRR is avoidable remains open.

### 7.2 Implications for Task 107

Venema 1993 is **not a viable alternative** to the Burgess chronicle construction for BX, because:

- BX needs completeness over ALL strict linear orders, not just well-orderings
- The prerequisites (Kamp's theorem, Doets's theorem) are far larger than the chronicle construction
- The existing codebase infrastructure is tailored to chronicles, not model replacement

The paper IS valuable as **mathematical context**: it shows that the g_content problem is specific to directly constructing well-ordered (or general linear order) models, and that indirect approaches via model replacement can avoid it — but only for restricted frame classes where a characterizing axiom (like W) exists.

For BX's frame class (all strict linear orders), Burgess's own completeness result (Theorem 3.5, cited as [B]) is the relevant baseline. BX extends B with additional axioms (seriality, etc.), and the completeness proof for BX over strict linear orders must handle these extensions directly — which is what the chronicle construction attempts to do.
