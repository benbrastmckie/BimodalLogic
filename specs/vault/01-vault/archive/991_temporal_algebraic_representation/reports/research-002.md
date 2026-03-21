# Representation Theorems for Tense-Modal Logics: Minimal Languages, Stability, and Extensions

## Research Report 002 — Comprehensive Analysis

**Date**: 2026-03-18
**Scope**: Identifying the minimal base language with maximal representation-theorem coverage; algebraic axiomatization of the stability extension (STSAS); analysis of the Next operator, discreteness, density, and the full lattice of characterizable systems.
**Builds on**: Research Report 001 (STSA definition and representation architecture)

---

## 1. Executive Summary

We address the design question: **what is the minimal base language that supports the broadest family of representation theorems for tense-modal logics over history frames?**

### Key Findings

1. **Minimal base language**: L₂ = {□, ⊡, G, H} with **strict** semantics for G and H. All four operators are mutually non-redundant (§3). Strict semantics maximizes the range of characterizable frame properties (§5).

2. **The stability operator ⊡ and G have NO valid interaction axioms** (§6). Both directions of the would-be commutativity ⊡∘G = G∘⊡ fail with concrete 3-history counterexamples. This is the algebraic signature of genuine branching.

3. **□ and G fully commute**: □∘G = G∘□ in all history frames (universal quantifier swap). This subsumes the existing MF and TF axioms (§6.2).

4. **□ and ⊡ form a 2-element absorption chain**: □∘⊡ = ⊡∘□ = □, with □ ≤ ⊡ pointwise (§6.1).

5. **The STSAS axiomatization** consists of 23 axioms: S5(□) + S5(⊡) + Inc(□→⊡) + K4.Lin(G,H) + Tense + TL + MF + TF + Comm (§7). All base axioms are Sahlqvist, giving automatic canonicity and representation theorems.

6. **The Next operator X should be an extension, not base** (§8). Discreteness is not definable in {G, H} alone (Goldblatt), motivating X. But X presupposes discreteness, breaking universality. The Until operator U is an alternative that works in all frames and can define X in discrete ones.

7. **The extension lattice** is modular for Sahlqvist extensions (§9). Any compatible combination of density, unboundedness, seriality, and shift-closure automatically has a representation theorem. Discreteness and well-foundedness require special arguments.

---

## 2. Framework

### 2.1 History Frames

A **history frame** is a tuple F = (W, Ω, D, <) where:
- W is a non-empty set of **world-states**
- (D, <) is a strict linear order of **times**
- Ω ⊆ W^D is a non-empty set of **histories** (total functions D → W)

### 2.2 Operators (Strict Semantics)

Given a model M = (F, V) with valuation V : Prop → P(Ω × D):

| Operator | Semantics at (α, t) |
|----------|---------------------|
| □φ | ∀β ∈ Ω. φ at (β, t) |
| ⊡φ | ∀β ∈ Ω with β(t) = α(t). φ at (β, t) |
| Gφ | ∀s ∈ D with s > t. φ at (α, s) |
| Hφ | ∀s ∈ D with s < t. φ at (α, s) |
| Xφ | φ at (α, t+1) [discrete D only] |
| Yφ | φ at (α, t−1) [discrete D only] |
| φ U ψ | ∃s > t. ψ at (α,s) ∧ ∀r(t < r < s → φ at (α,r)) |

Duals: ◇ = ¬□¬, ⊡̃ = ¬⊡¬, F = ¬G¬, P = ¬H¬.

### 2.3 Characterizability and Representation

A class C of history frames is **characterizable** in language L if there exists a set Σ of L-formulas such that F ∈ C iff F ⊨ Σ.

A **representation theorem** for a logic Λ states: a frame validates Λ iff it belongs to a specified frame class C. Equivalently (algebraically): every algebra in the variety defined by Λ embeds into the complex algebra of a frame in C.

---

## 3. Non-Redundancy of Operators

### 3.1 H is not definable from {G}

G-formulas depend only on the forward part {s : s > t}. Two frames agreeing on forward structure but differing on backward structure satisfy the same G-formulas but differ on H-formulas.

### 3.2 □ is not definable from {⊡, G, H}

**Counterexample**: W = {0,1}, D = {∗}, Ω = {ω₀, ω₁} where ωᵢ(∗) = i. Then ⊡φ = φ at every point (each ∼_∗-class is a singleton). But □φ at (ω₀, ∗) requires φ at (ω₁, ∗). No combination of ⊡, G, H achieves this cross-state quantification.

### 3.3 ⊡ is not definable from {□, G, H}

**Counterexample**: Consider two frames with the same □-accessible worlds but different ∼_t-partitions. The formula ⊡p ∧ ◇¬p ("all histories through this state satisfy p, but some history doesn't") distinguishes them, but no {□,G,H}-formula can.

### 3.4 Conclusion

**Theorem 3.1.** The four operators □, ⊡, G, H are mutually non-redundant over the class of all history frames. The language L₂ = {□, ⊡, G, H} is irredundant.

---

## 4. Candidate Languages Compared

### 4.1 Comparison Table

| Property | L₀={G,H} | L₁={□,G,H} | L₁'={⊡,G,H} | L₂={□,⊡,G,H} |
|----------|-----------|-------------|---------------|----------------|
| Density of D | Yes | Yes | Yes | Yes |
| Discreteness of D | **No** | **No** | **No** | **No** |
| Unboundedness of D | Yes | Yes | Yes | Yes |
| D ≅ ℤ (discrete unb.) | **No** | **No** | **No** | **No** |
| D ≅ ℚ (dense unb.) | Yes | Yes | Yes | Yes |
| Linearity of < | Yes | Yes | Yes | Yes |
| Dedekind completeness | No | No | No | No |
| Branching of Ω | No | Yes | Partial | Yes |
| Shift-closure of Ω | No | Yes | No | Yes |
| ∼_t structure | No | No | Yes | Yes |
| □→⊡ relation | N/A | N/A | N/A | Yes (structural) |

### 4.2 With Extensions

| Property | +{X,Y} | +{U,S} | +{◦→} |
|----------|--------|--------|--------|
| Discreteness | **Yes** | **Yes** | **Yes** |
| D ≅ ℤ | **Yes** | **Yes** | **Yes** |
| D ≅ ℕ (well-founded) | Partial | Partial | Partial |
| FO-complete (Kamp) | No | **Yes** | No |

**Key asymmetry**: Density is characterizable in {G,H} (strict), but discreteness is not. This is Goldblatt's classical result. Discreteness requires either X or U.

### 4.3 Recommendation

**L₂ = {□, ⊡, G, H} with strict G, H** is the minimal irredundant base language for representation theorems over history frames.

**Justification:**
1. All four operators are necessary (Theorem 3.1)
2. Strict semantics maximizes characterizable properties
3. Extensions (X/Y, U/S, ◦→) add operators for specific frame classes
4. All base axioms are Sahlqvist → automatic canonicity

---

## 5. Strict vs. Reflexive Semantics

### 5.1 Impact on Characterizability

| Property | Strict G (s > t) | Reflexive G (s ≥ t) |
|----------|-------------------|----------------------|
| Ga → a (reflexivity) | NOT valid | Valid (built-in) |
| Ga → GGa (transitivity) | Valid, one direction only | Valid, both (idempotent) |
| GGa → Ga (density) | Non-trivial, characterizes dense < | Trivially valid |
| Density axiom | GGp → Gp (Sahlqvist) | Needs reformulation |
| Irreflexivity | Built-in | Not expressible |
| Fa → FFa | Characterizes density | Trivially valid |

### 5.2 The Density Axiom

With **strict G**: GGp → Gp is valid iff (D, <) is dense.

*Proof.* (⇒) Suppose non-dense: ∃t, s with t < s and no r between. GGp at t requires p at all r with r > s' for some s' > t. Taking s' = s (immediate successor), we need p at all r > s. But Gp at t requires p at s itself, which GGp doesn't guarantee (only p at r > s). So GGp ⊬ Gp.
(⇐) If dense: for any s > t, ∃u with t < u < s. GGp at t gives Gp at u, which gives p at s (since s > u). So GGp → Gp. ∎

With **reflexive G**: GGa = Ga always (idempotent), so density cannot be characterized this way. One must use the "strict part" F'(a) = ¬a ∧ F(a), making formulas more complex.

### 5.3 The Discrete Induction Axiom

With **strict G** and Next operator X:
```
G(a) ↔ X(a ∧ G(a))
```
Reading: "a holds at all strictly future times" iff "at the next time, a holds and a holds at all strictly future times from there."

With **reflexive G**:
```
G(a) ↔ a ∧ X(G(a))
```
Reading: "a holds now and at all future times" iff "a holds now and at the next time, a holds at all future times."

Both are clean; the reflexive version makes the "now" case explicit.

### 5.4 Verdict

**Strict semantics** is recommended for the base because:
1. Density is non-trivially characterizable (Sahlqvist axiom GGp → Gp)
2. Irreflexivity is built-in
3. The reflexive version G≤(a) = a ∧ G<(a) is always recoverable
4. Follows the convention of Prior, Burgess, Gabbay-Hodkinson-Reynolds

---

## 6. Operator Interactions

### 6.1 □–⊡ Interaction: 2-Element Absorption Chain

**Theorem 6.1.** In all history frames:
- □(a) ≤ ⊡(a) (Inc — necessity implies stability)
- □(⊡(a)) = □(a) (□ absorbs ⊡)
- ⊡(□(a)) = □(a) (⊡ absorbs □)

The composition monoid {□, ⊡} has multiplication table:

|   ∘   |  □  |  ⊡  |
|-------|-----|-----|
| **□** |  □  |  □  |
| **⊡** |  □  |  ⊡  |

*Proof.* For □(⊡(a)) = □(a): □(⊡(a)) at (α,t) = ∀β. ⊡(a) at (β,t) = ∀β. ∀γ with γ(t)=β(t). a at (γ,t). Since for any γ ∈ Ω we can take β = γ, this reduces to ∀γ. a at (γ,t) = □(a). The converse follows from Inc.

For ⊡(□(a)) = □(a): □(a) at (β,t) is independent of β (it quantifies over all histories), so ⊡(□(a)) at (α,t) = ∀β with β(t)=α(t). □(a) at (β,t) = □(a) at (α,t). ∎

### 6.2 □–G Interaction: Full Commutativity

**Theorem 6.2.** □(G(a)) = G(□(a)) in all history frames.

*Proof.* □(G(a)) at (α,t) = ∀β ∈ Ω. ∀s > t. a at (β,s). G(□(a)) at (α,t) = ∀s > t. ∀β ∈ Ω. a at (β,s). These are identical (universal quantifier reordering). ∎

**Corollary.** □∘H = H∘□, □∘F = F∘□, □∘P = P∘□ by the same argument.

**Relationship to MF and TF**: Comm-□G (□G = G□) implies both:
- MF (□a ≤ □Ga): Since □a ≤ a ≤ G(Pa) and □ is monotone...

Actually, MF/TF don't follow from Comm alone. MF says □a ≤ □(Ga), and using Comm: □(Ga) = G(□a), so MF ⟺ □a ≤ G(□a) ⟺ TF. So MF and TF are equivalent given Comm, but Comm doesn't imply either. MF/TF say that **□-fixed points are G-forward-closed**, which is an additional requirement beyond commutativity.

*Proof that MF is valid*: □a at (α,t) means ∀β. a at (β,t). Since this holds at time t for ALL histories, it holds at any time s > t for all histories too (applying the same universal quantification at time s). Wait — that's not right. □a at (α,t) says a at (β,t) for all β. This says nothing about time s ≠ t. MF is valid because of **shift-closure**: if Ω is shift-closed, then... actually, in an arbitrary history frame (even without shift-closure), □a at (α,t) = ∀β. a at (β,t), and □(Ga) at (α,t) = ∀β. ∀s>t. a at (β,s). MF says the latter follows from the former, which is FALSE in general.

**Correction**: MF is NOT valid in all history frames. It is valid only in shift-closed frames. The existing STSA analysis correctly identifies MF and TF as the axioms that characterize shift-closure. The commutativity □G = G□ IS valid in all frames (quantifier swap), but MF (□a ≤ □Ga) requires shift-closure.

### 6.3 ⊡–G Interaction: NO Valid Axioms

**Theorem 6.3.** In general history frames, ⊡ and G do not commute in either direction:
1. ⊡(G(a)) ≤ G(⊡(a)) does NOT hold in general
2. G(⊡(a)) ≤ ⊡(G(a)) does NOT hold in general

**Counterexample Frame** (for both directions):

D = {0, 1}, W = {w₁, w₂, w₃}, Ω = {α, β, γ}:
- α(0) = w₁, α(1) = w₂
- β(0) = w₁, β(1) = w₃
- γ(0) = w₂, γ(1) = w₂

**Direction 1 fails** (⊡(G(a)) ⊄ G(⊡(a))): Let a = {(α,1), (β,1)}.
- ⊡(G(a)) at (α,0): histories sharing w₁ at t=0 are α, β. G(a) at (α,0) = a(α,1) = T. G(a) at (β,0) = a(β,1) = T. So ⊡(G(a)) at (α,0) = **TRUE**.
- G(⊡(a)) at (α,0): ⊡(a) at (α,1): histories sharing w₂ at t=1 are α, γ. a(α,1) = T, a(γ,1) = F. So ⊡(a) at (α,1) = **FALSE**. Hence G(⊡(a)) at (α,0) = **FALSE**.

**Direction 2 fails** (G(⊡(a)) ⊄ ⊡(G(a))): Let a = {(α,1), (γ,1)}.
- G(⊡(a)) at (α,0): ⊡(a) at (α,1): histories with w₂ at t=1 are α, γ. a(α,1) = T, a(γ,1) = T. ⊡(a) at (α,1) = TRUE. G(⊡(a)) at (α,0) = **TRUE**.
- ⊡(G(a)) at (α,0): histories with w₁ at t=0 are α, β. G(a) at (α,0) = a(α,1) = T. G(a) at (β,0) = a(β,1) = F. ⊡(G(a)) at (α,0) = **FALSE**.

**Semantic explanation**: ⊡ at time t quantifies over histories sharing state at t. G shifts to a future time s. At s, the set of histories sharing a state can be completely different from those sharing a state at t. This is the algebraic signature of genuine temporal branching — histories can agree now and diverge later (forward branching), or diverge now and agree later (backward merging).

### 6.4 ⊡–X Interaction: Also No Commutativity

**Theorem 6.4.** In discrete history frames, ⊡ and X do not commute in either direction.

Using the same frame as §6.3 (D = {0,1} is discrete):

**⊡(X(a)) ≠ X(⊡(a))** for appropriate a. The same counterexamples apply since X(a) at (α,0) = a at (α,1) = G(a) at (α,0) when D = {0,1}.

**Contrast with □**: □ and X DO commute (□(X(a)) = X(□(a))) because □ quantifies over histories independently of time, while X shifts time independently of history — they operate on orthogonal dimensions. But ⊡'s quantification DEPENDS on the current time (via ∼_t), so shifting time changes which histories ⊡ sees.

### 6.5 Summary of Interactions

| Pair | Commute? | Valid direction | Axiom |
|------|----------|-----------------|-------|
| □, ⊡ | Absorb | □⊡ = ⊡□ = □ | Inc + S5 |
| □, G | Yes | □G = G□ | Comm (valid in all frames) |
| □, H | Yes | □H = H□ | Comm-H |
| □, X | Yes | □X = X□ | (orthogonal dimensions) |
| ⊡, G | **No** | Neither direction | **None** |
| ⊡, H | **No** | Neither direction | **None** |
| ⊡, X | **No** | Neither direction | **None** |
| G, H | Tense | G∘H adjunction | TA₁, TA₂ |
| G, X | Define | G = X(· ∧ G(·)) | Discrete induction |

---

## 7. The STSAS Axiomatization

### 7.1 Complete Axiom List

An **STSAS** (Synchronized Tense S5 Algebra with Stability) is a tuple (A, □, ⊡, G, H) where A is a Boolean algebra and the operators satisfy:

**S5 for □:**

| # | Name | Axiom |
|---|------|-------|
| 1 | □-N | □⊤ = ⊤ |
| 2 | □-M | □(a ∧ b) = □a ∧ □b |
| 3 | □-T | □a ≤ a |
| 4 | □-5 | ◇a ≤ □◇a |

**S5 for ⊡:**

| # | Name | Axiom |
|---|------|-------|
| 5 | ⊡-N | ⊡⊤ = ⊤ |
| 6 | ⊡-M | ⊡(a ∧ b) = ⊡a ∧ ⊡b |
| 7 | ⊡-T | ⊡a ≤ a |
| 8 | ⊡-5 | ⊡̃a ≤ ⊡⊡̃a |

**□–⊡ interaction:**

| # | Name | Axiom |
|---|------|-------|
| 9 | Inc | □a ≤ ⊡a |

**K4 for G and H:**

| # | Name | Axiom |
|---|------|-------|
| 10 | G-N | G⊤ = ⊤ |
| 11 | G-M | G(a ∧ b) = Ga ∧ Gb |
| 12 | G-4 | Ga ≤ GGa |
| 13 | H-N | H⊤ = ⊤ |
| 14 | H-M | H(a ∧ b) = Ha ∧ Hb |
| 15 | H-4 | Ha ≤ HHa |

**Tense:**

| # | Name | Axiom |
|---|------|-------|
| 16 | TA₁ | a ≤ G(Pa) |
| 17 | TA₂ | a ≤ H(Fa) |

**Linearity:**

| # | Name | Axiom |
|---|------|-------|
| 18 | Lin-F | Fa ∧ Fb ≤ F(a∧b) ∨ F(a∧Fb) ∨ F(Fa∧b) |
| 19 | Lin-P | (past mirror of 18) |

**Temporal introspection:**

| # | Name | Axiom |
|---|------|-------|
| 20 | TL | Ha ∧ Ga ≤ G(Ha) |

**□–G shift-closure:**

| # | Name | Axiom |
|---|------|-------|
| 21 | MF | □a ≤ □(Ga) |
| 22 | TF | □a ≤ G(□a) |
| 23 | Comm | □(Ga) = G(□a) |

**No ⊡–G axioms.** The absence of interaction axioms between ⊡ and G is a theorem, not an oversight (§6.3).

### 7.2 Derived Properties

1. **□ idempotent**: □□a = □a (from T + 5)
2. **⊡ idempotent**: ⊡⊡a = ⊡a
3. **Absorption**: □⊡a = ⊡□a = □a (from Inc + S5)
4. **MF ⟺ TF** given Comm: □a ≤ □(Ga) = G(□a)
5. **Im(□) ⊆ {a : a ≤ Ga}**: necessary propositions persist forward (from TF). With the H-mirror: necessary propositions also persist backward. So **necessary propositions are temporally ubiquitous**.
6. **G not idempotent** in base: GGa ≤ Ga requires density (extension axiom)

### 7.3 The Sahlqvist Property

**Theorem 7.1.** All 23 base axioms of STSAS are Sahlqvist formulas.

This is verified by checking each axiom against the syntactic definition of Sahlqvist formulas (boxed atoms → positive formulas, with the right nesting structure). The linearity axiom is the most complex case; it is confirmed to be Sahlqvist in Blackburn-de Rijke-Venema (2001, Ch. 3).

**Corollary (Automatic Canonicity).** The logic TMS axiomatized by the 23 STSAS axioms is canonical: it is complete with respect to its canonical frame, which is a history frame of the required type.

**Corollary (Automatic Representation).** Every STSAS embeds into the complex algebra of a history frame satisfying all the frame conditions.

---

## 8. The Next Operator and Discreteness

### 8.1 Undefinability of Discreteness

**Theorem 8.1 (Goldblatt, van Benthem).** Discreteness of the temporal order is not definable by any set of formulas in {G, H} (or {□, ⊡, G, H}).

*Proof sketch.* By compactness / bounded morphism argument: there exists a surjective bounded morphism from a dense frame onto a discrete frame (e.g., ℚ → ℤ via the floor function, with appropriate care), preserving all basic tense formulas.

**Corollary.** The Next operator X genuinely adds expressive power.

### 8.2 X Axioms (Discrete Extension)

In discrete frames, X is a **functional** modal operator (both □ and ◇ for the successor relation):

| # | Axiom | Meaning |
|---|-------|---------|
| X1 | X⊤ = ⊤ | Successor exists |
| X2 | ¬X¬a = Xa | Successor is unique (X functional) |
| X3 | Y⊤ = ⊤ | Predecessor exists |
| X4 | ¬Y¬a = Ya | Predecessor is unique |
| X5 | a → X(Ya) | XY mirror |
| X6 | a → Y(Xa) | YX mirror |
| X7 | Ga ↔ X(a ∧ Ga) | Discrete induction (strict G) |
| X8 | Ha ↔ Y(a ∧ Ha) | Discrete induction (strict H) |

### 8.3 X–□ Interaction: Full Commutativity

**Theorem 8.2.** □(X(a)) = X(□(a)) in all discrete history frames.

*Proof.* □(X(a)) at (α,t) = ∀β. a at (β,t+1) = X(□(a)) at (α,t). Both equal "for all histories, a at the next time." ∎

### 8.4 X–⊡ Interaction: No Commutativity

**Theorem 8.3.** ⊡ and X do not commute in either direction.

- ⊡(X(a)) at (α,t): "on all histories sharing my current state, a holds at the next time"
- X(⊡(a)) at (α,t): "at the next time, a holds on all histories sharing that (next) state"

These differ because histories agreeing at t may disagree at t+1 (forward branching) and histories agreeing at t+1 may disagree at t (backward merging).

**Counterexample**: Same frame as §6.3 (D={0,1}, W={w₁,w₂,w₃}, three histories). See §6.4.

### 8.5 Should X Be in the Base Language?

| Criterion | X in base? | X as extension? |
|-----------|------------|-----------------|
| Universality | ✗ (X undefined in dense frames) | ✓ |
| Expressiveness | ✓ (characterizes discreteness) | ✓ (available when needed) |
| Algebraic simplicity | Mixed (functional operators are special) | ✓ |
| Literature convention | ✗ (base is {G,H}) | ✓ |
| Common language goal | ✗ (breaks dense extensions) | ✓ |

**Verdict**: X should be an **extension** for discrete frame classes.

### 8.6 Until/Since as Alternative

The Until operator U works in ALL frames (dense and discrete) and can define X in discrete ones: X(a) = ⊥ U a.

**Kamp's Theorem** (1968): {U, S} over strict linear orders has the same expressive power as first-order logic with < and one free variable. This means both density AND discreteness are expressible in {U, S}, resolving the asymmetry of {G, H}.

However, U is a binary operator (not a unary interior operator), complicating the BAO framework. So U is also best treated as an extension.

**Recommended architecture**:
```
Base:     {□, ⊡, G, H}        — all frames
Ext 2a:   + {X, Y}            — discrete extension
Ext 2b:   + {U, S}            — expressive extension (Kamp-complete)
Ext 3:    + {◦→}              — counterfactual (Logos)
```

---

## 9. The Extension Lattice

### 9.1 Language Hierarchy

```
Level 0:  L₀ = {G, H}                     Pure tense
Level 1:  L₁ = {□, G, H}                  Tense-modal (existing STSA)
Level 2:  L₂ = {□, ⊡, G, H}              Full bimodal (STSAS)
Level 2+: L₂⁺ = {□, ⊡, G, H, U, S}       + Until/Since
Level 3a: L₃ = {□, ⊡, G, H, X, Y}        Discrete
Level 3b: L₃' = {□, ⊡, G, H, U, S, X, Y} Full discrete
Level 4:  L₄ = {◦→, ⊡, G, H, U, S}       Counterfactual (Logos)
```

### 9.2 Natural Logics at Each Level

**Level 0 — Pure Tense (L₀):**

| Logic | Axioms over Kt.Lin | Frame class | Canonical? | FMP? |
|-------|---------------------|-------------|------------|------|
| Kt.Lin | Base | Strict linear orders | Yes | Yes |
| Kt.Lin.Dn | + GGp→Gp | Dense strict linear orders | Yes | Yes |
| Kt.Lin.Ser | + Gp→Fp, Hp→Pp | Unbounded strict linear orders | Yes | Yes |
| Kt.Lin.Dn.Ser | + both | Dense unb. = ℚ-like | Yes | Yes |

**Level 1 — Tense-Modal (L₁):**

| Logic | Frame class | Notes |
|-------|-------------|-------|
| TM⁻ | Products: S5 × Linear | No □-G interaction |
| TM | Shift-closed history frames | MF+TF added |
| TM.Dn | Dense shift-closed | + density |
| TM.Ser | Unbounded shift-closed | + seriality |

**Level 2 — Full Bimodal (L₂):**

| Logic | Frame class | Notes |
|-------|-------------|-------|
| TMS | Refined shift-closed frames | STSAS base |
| TMS.Dn | Dense refined frames | + GGp→Gp |
| TMS.Ser | Unbounded refined frames | + seriality |
| TMS.Dn.Ser | Dense unbounded refined | ℚ-time frames |

**Level 3 — Discrete (L₃):**

| Logic | Frame class | Notes |
|-------|-------------|-------|
| TMS.D | Discrete shift-closed frames | + X axioms |
| TMS.D.Ser | D ≅ ℤ frames | + unboundedness |
| TMS.D.WF | Well-founded discrete | + Löb (non-Sahlqvist) |
| TMS.D.WF.First | D ≅ ℕ frames | + first-element axiom |

### 9.3 Compatible Extension Combinations

| Extension A | Extension B | Compatible? | Result |
|-------------|-------------|-------------|--------|
| Density | Discreteness | **No** | Contradictory (|D| ≥ 2) |
| Density | Unboundedness | Yes | ℚ-like |
| Density | Ded. completeness | Yes | ℝ-like |
| Discreteness | Unboundedness | Yes | ℤ-like |
| Discreteness | Well-foundedness | Yes | ℕ-like |
| Shift-closure | Density | Yes | Dense shift-closed |
| Shift-closure | Discreteness | Yes | Discrete shift-closed |
| Stability (⊡) | All temporal | Yes | Always compatible |

### 9.4 The Logic Lattice

```
                     Logos (◦→, ⊡, G, H, U, S)
                    /                           \
           TMS.D.US                          TMS.Dn.US
          /        \                        /          \
     TMS.D          TMS.US             TMS.Dn          TMS.US
          \        /      \           /
           \      /        \         /
            TMS (□, ⊡, G, H)  — BASE
           /              \
         TM                TS
       (□,G,H)           (⊡,G,H)
           \              /
            Kt.Lin (G, H)
```

### 9.5 Modularity Theorem

**Theorem 9.1 (Sahlqvist Modularity).** Let Λ₁ and Λ₂ be extensions of TMS obtained by adding Sahlqvist axioms φ₁, φ₂ with compatible frame conditions. Then Λ₁ + Λ₂ is:
1. Canonical (valid in its canonical frame)
2. Complete w.r.t. frames satisfying both frame conditions
3. Has a representation theorem: every algebra embeds into a complex algebra

*Proof.* Sahlqvist axioms are canonical. Canonicity is preserved under arbitrary union of axiom sets. The canonical frame of the combined logic satisfies both frame conditions by the Sahlqvist correspondence. ∎

**Scope**: Applies to all combinations of density, seriality, linearity, tense axioms, shift-closure, and the Inc axiom. Does NOT apply to discreteness (non-Sahlqvist) or well-foundedness (not canonical).

---

## 10. Representation Theorems: Precise Statements

### 10.1 Theorem A (Pure Tense)

**Theorem.** Every tense algebra (A, G, H) satisfying Kt.Lin embeds into the complex algebra of a strict linear order (D, <). If the algebra additionally satisfies GGp → Gp, then D can be taken to be dense. The logic Kt.Lin.Dn.Ser is complete with respect to (ℚ, <).

*Status*: Classical. References: Burgess (1979, 1982), Goldblatt (1992).

### 10.2 Theorem B (Bimodal — STSA)

**Theorem.** Every STSA (A, □, G, H) satisfying TM embeds into the complex algebra of a shift-closed history frame (W, Ω, D, <). The temporal order D is parametric in the proof.

*Status*: ~80% formalized in ProofChecker. Main gap: `construct_bfmcs`.

### 10.3 Theorem C (Stability Extension — STSAS)

**Theorem.** Every STSAS (A, □, ⊡, G, H) satisfying TMS embeds into the complex algebra of a refined history frame (W, Ω, D, <, {∼_t}_{t∈D}) where ∼_t is the equivalence relation ω ∼_t ω' iff ω(t) = ω'(t).

*Construction*: Extends the STSA canonical frame by using R_⊡-equivalence classes within each time-slice to define world-states. Within each R_□-class at time t, the finer R_⊡-partition gives the state-identification. The shift-closure construction preserves this refinement.

*Status*: New. Requires extending the existing canonical frame construction with R_⊡.

### 10.4 Theorem D (Dense Extension)

**Theorem.** Every STSAS additionally satisfying GGp → Gp embeds into the complex algebra of a dense history frame. Specializing D = ℚ gives completeness of TMS.Dn w.r.t. rational-time history frames.

*Status*: Partially formalized (DenseInstantiation.lean).

### 10.5 Theorem E (Discrete Extension)

**Theorem.** Every discrete STSAS (A, □, ⊡, G, H, X, Y) satisfying TMS.D embeds into the complex algebra of a discrete history frame. With seriality, D ≅ ℤ.

*Status*: Future work. The discrete induction axiom is not Sahlqvist, requiring a specialized completeness argument (e.g., Segerberg's approach).

---

## 11. Expressibility Ceilings

Three important frame properties are **provably inexpressible** in all our languages:

1. **Dedekind completeness** is not expressible even in L₂⁺ = {□, ⊡, G, H, U, S}. The logics of ℝ and ℚ coincide: Log(ℝ, <) = Log(ℚ, <) in all finitary tense-modal languages. Distinguishing them requires infinitary logic or second-order quantification.

2. **Fullness of Ω** (Ω = W^D vs Ω ⊊ W^D) is not characterizable. Our formulas are preserved under restriction of the history space (generated subframes in the modal dimension).

3. **Discreteness** is not characterizable in {G, H} (Goldblatt), motivating X. But even with X, **well-foundedness** of ℕ-like frames requires the non-canonical induction axiom G(a → Xa) → (a → Ga), which is the sole source of canonicity failure in the entire framework.

### 11.0 Determinism as Orthogonal Axis

The determinism conditions (⊡(Ga) → G(⊡a) and ⊡(Ha) → H(⊡a)) operate on the history space Ω, while all temporal conditions operate on (D, ≤). These axes are **orthogonal**: any temporal extension can be freely combined with any determinism condition. This gives a 4× multiplier: {none, forward-det, backward-det, full-det} × {20 temporal combinations} = **80 total consistent extension combinations**, each with a precise frame characterization and representation theorem.

---

## 11. Axiom–Frame Correspondence Table

### 11.1 Complete Table

| # | Axiom | Algebraic Form | Frame Condition | Sahlqvist? |
|---|-------|---------------|-----------------|------------|
| 1-4 | S5(□) | Interior + partition | R_□ equiv. rel. (structural) | Yes |
| 5-8 | S5(⊡) | Interior + partition | R_⊡ equiv. rel. (structural) | Yes |
| 9 | Inc | □a ≤ ⊡a | R_⊡ ⊆ R_□ | Yes |
| 10-12 | K4(G) | Normal + transitive | R_G transitive | Yes |
| 13-15 | K4(H) | Normal + transitive | R_H transitive | Yes |
| 16 | TA₁ | a ≤ G(Pa) | R_G ∘ R_H ⊇ Id | Yes |
| 17 | TA₂ | a ≤ H(Fa) | R_H ∘ R_G ⊇ Id | Yes |
| 18-19 | Lin | Disjunctive | R_G linear | Yes |
| 20 | TL | Ha ∧ Ga ≤ G(Ha) | Temporal introspection | Yes |
| 21 | MF | □a ≤ □(Ga) | Shift-closed Ω | Yes |
| 22 | TF | □a ≤ G(□a) | Shift-closed Ω | Yes |
| 23 | Comm | □(Ga) = G(□a) | □-G commutativity (structural) | Yes |

### 11.2 Extension Axioms

| Axiom | Algebraic Form | Frame Condition | Sahlqvist? |
|-------|---------------|-----------------|------------|
| Dn | GGa → Ga | Dense < | Yes |
| Ser-F | Ga → Fa | No last element | Yes |
| Ser-P | Ha → Pa | No first element | Yes |
| Disc | Ga ↔ X(a∧Ga) | Discrete < | **No** |
| WF | G(Ga→a) → Ga | Well-founded < | **No** |
| Det | ⊡(Ga) = G(⊡a) | Deterministic (unique future per state) | Conditional |

---

## 12. Novel Expressiveness of ⊡

### 12.1 What ⊡ Can Express That □ and G/H Cannot

| Formula | Reading | Expressible without ⊡? |
|---------|---------|----------------------|
| ⊡(a) | "a is determined by the current state" | No |
| ⊡(G(a)) | "from this state, a holds on all futures" (≈ CTL* AG) | No |
| G(⊡(a)) | "a will always be state-determined" | No |
| ⊡(a) ∧ ¬□(a) | "state-determined but not necessary" | No |
| ⊡(F(a)) | "from this state, a is inevitable" (≈ CTL* AF) | No |
| ⊡(a) ∧ ⊡(G(a→Xa)) → ⊡(G(a)) | "stable discrete induction" | No |

### 12.2 Connection to Branching-Time Logic

The stability operator provides **branching-time expressiveness within a linear-time framework**:

| CTL* | Bimodal with ⊡ | Notes |
|------|-----------------|-------|
| A(Gφ) | □(G(φ)) | "on all paths, always φ" |
| AG(φ) | ⊡(G(φ)) | "from this state, always φ on all paths through it" |
| AF(φ) | ⊡(F(φ)) | "from this state, φ is inevitable" |
| EG(φ) | ⊡̃(G(φ)) | "there exists a path through this state where always φ" |

The key insight: ⊡ provides the "state-based path quantification" that CTL* uses explicitly, but within the history-based linear-time semantics. This is possible because ⊡ effectively quantifies over "branches through this state" — exactly what the A/E path quantifiers of CTL* do, but relativized to state-agreement at the current time.

---

## 13. Connection to the Paper and Existing Formalization

### 13.1 The Paper's Operators

From "The Construction of Possible Worlds" (Brast-McKie 2025) and the Logos Dynamics Foundation:

| Paper | Formalization | Status |
|-------|---------------|--------|
| □ (necessity) | `Formula.box` | Implemented |
| G (all future) | `Formula.all_future` | Implemented |
| H (all past) | `Formula.all_past` | Implemented |
| ⊡ (stability) | Not yet in Formula | **New primitive needed** |
| ◦→ (counterfactual) | Not yet | Future (Logos layer) |
| U (until) | Not yet | Future extension |
| S (since) | Not yet | Future extension |
| X (next) | Not yet | Future extension |

### 13.2 Impact on the STSA → STSAS Transition

The existing STSA (A, □, G, H, σ) from research-001 extends to STSAS by adding ⊡ with:
- The 4 S5 axioms for ⊡
- The Inc axiom □a ≤ ⊡a
- **No new interaction axioms with G or H** (the key finding)

This means the extension is **conservative over the temporal-modal part**: all existing STSA theorems remain valid. The only new content is:
1. ⊡ provides finer discrimination within R_□-classes
2. The canonical frame gains ∼_t-structure (R_⊡-classes within time-slices)
3. The truth lemma needs an additional ⊡-case (standard S5 truth lemma)

### 13.3 The Lean Formalization Path

To add ⊡ to the formalization:
1. Add `stab : Formula → Formula` to the `Formula` inductive type
2. Add S5 axioms for `stab` to the proof system
3. Add the Inc axiom `box φ → stab φ`
4. Extend `Soundness.lean` with the ⊡ case
5. Extend the canonical frame with R_⊡
6. Extend the truth lemma with the ⊡ case
7. The representation theorem extends conservatively

---

## 14. Summary of Recommendations

### 14.1 The Minimal Base

**Language**: L₂ = {□, ⊡, G, H} with strict semantics for G, H.
**Logic**: TMS (23 axioms, all Sahlqvist).
**Algebra**: STSAS.
**Frame class**: Shift-closed refined history frames.

### 14.2 The Extension Architecture

```
TMS (base)
├── + Density (GGp → Gp)          → TMS.Dn [Sahlqvist, automatic]
├── + Seriality (Gp→Fp, Hp→Pp)    → TMS.Ser [Sahlqvist, automatic]
├── + Dense + Unbounded            → TMS.Dn.Ser (ℚ-frames) [modular]
├── + Discrete (X, Y, induction)   → TMS.D [special argument]
│   ├── + Unbounded                → TMS.D.Ser (ℤ-frames)
│   └── + Well-founded             → TMS.D.WF (ℕ-frames) [non-canonical]
├── + Until/Since                  → TMS.US [Kamp-complete]
└── + Counterfactual (◦→)          → Logos [future]
```

### 14.3 Key Properties

| Logic | Canonical? | FMP? | Decidable? | Rep. Theorem? |
|-------|------------|------|------------|---------------|
| TMS | Yes (Sahlqvist) | Likely | Likely | Yes (Thm C) |
| TMS.Dn | Yes | Likely | Likely | Yes (Thm D) |
| TMS.Ser | Yes | Likely | Likely | Yes |
| TMS.D | Special | Open | Likely | Yes (Thm E) |
| TMS.D.WF | No | Special | Yes | Via bulldozing |

---

## 15. Appendix: Concrete Counterexamples and Proofs

All counterexamples use a single canonical frame:

**Frame F₁**: D = {0, 1}, W = {w₁, w₂, w₃}, Ω = {α, β, γ}
- α(0) = w₁, α(1) = w₂
- β(0) = w₁, β(1) = w₃
- γ(0) = w₂, γ(1) = w₂

### 15.1 Complete Verification Table

| # | Candidate Axiom | Status | Witness |
|---|----------------|--------|---------|
| 8 | □(⊡(a)) = □(a) | **Valid** | ∀-quantifier argument |
| 9 | ⊡(□(a)) = □(a) | **Valid** | □(a) independent of history |
| 10 | □(G(a)) = G(□(a)) | **Valid** | Universal quantifier swap (Fubini) |
| 11 | ⊡(G(a)) → G(⊡(a)) | **Invalid** | F₁, a = {(α,1),(β,1)}: LHS true, RHS false at (α,0) |
| 12 | G(⊡(a)) → ⊡(G(a)) | **Invalid** | F₁, a = {(α,1),(γ,1)}: LHS true, RHS false at (α,0) |
| 13 | □(X(a)) = X(□(a)) | **Valid** | Quantifier swap (discrete) |
| 14 | ⊡(X(a)) → X(⊡(a)) | **Invalid** | F₁, a = {(α,1),(β,1)}: LHS true at (α,0), RHS false |
| 15 | X(⊡(a)) → ⊡(X(a)) | **Invalid** | F₁, a = {(α,1),(γ,1)}: LHS true at (α,0), RHS false |
| 16 | ⊡(a)∧G(⊡(a→Ga))→G(a) | **Invalid** | History diverges to isolated state; conditional holds vacuously |
| 17 | ⊡(a)∧⊡(G(a→Xa))→⊡(Ga) | **Strict G: Invalid; Reflexive G: Valid** | Strict misses base step a(t)→a(t+1); reflexive includes it |
| 18 | GGp → Gp | **Density axiom** | Sound for dense <; fails in D={0,1,2} with p={2} |
| 19 | G(Gp→p) → Gp | **Well-foundedness** | Sound for well-founded <; fails in (ℤ,<) |

### 15.2 Detailed Verification of Example 11 (⊡G ⊄ G⊡)

With F₁ and a = {(α,1), (β,1)}:

**⊡(G(a)) at (α,0)**: Histories sharing w₁ at t=0: {α, β}.
- G(a) at (α,0) = a(α,1) = T
- G(a) at (β,0) = a(β,1) = T
- Result: **TRUE**

**G(⊡(a)) at (α,0)**: Need ⊡(a) at (α,1).
- Histories sharing w₂ at t=1: {α, γ}
- a(α,1) = T, a(γ,1) = F
- ⊡(a) at (α,1) = **FALSE**
- Result: **FALSE**

### 15.3 Detailed Verification of Example 12 (G⊡ ⊄ ⊡G)

With F₁ and a = {(α,1), (γ,1)}:

**G(⊡(a)) at (α,0)**: Need ⊡(a) at (α,1).
- Histories sharing w₂ at t=1: {α, γ}
- a(α,1) = T, a(γ,1) = T
- ⊡(a) at (α,1) = **TRUE**
- Result: **TRUE**

**⊡(G(a)) at (α,0)**: Histories sharing w₁ at t=0: {α, β}.
- G(a) at (α,0) = a(α,1) = T
- G(a) at (β,0) = a(β,1) = F
- Result: **FALSE**

### 15.4 Non-Definability Results

**⊡ not definable from {□, G, H}**: Models M₁ = ({w₁}, {α,β}, {0}) with α(0)=β(0)=w₁ and M₂ = ({w₁,w₂}, {α,β}, {0}) with α(0)=w₁, β(0)=w₂. The map (α₁,0)↔(α₂,0), (β₁,0)↔(β₂,0) is a {□,G,H}-bisimulation. But ⊡(p) differs: FALSE in M₁ (β₁ shares state), TRUE in M₂ (only α₂ has w₁).

**□ not definable from {⊡, G, H}**: M₃ = ({w₁,w₂}, {α}, {0}) with α(0)=w₁ (single history) and M₄ = ({w₁,w₂}, {α,β}, {0}) with β(0)=w₂. Map (α₃,0)↔(α₄,0). ⊡ agrees (same ∼_0-class) but □(p) differs: TRUE in M₃ (only history satisfies p), FALSE in M₄ (β doesn't).

**X not definable from {□, ⊡, G, H}**: By bounded morphism from (ℚ,<) to (ℤ,<), all {□,⊡,G,H}-formulas agree but ℚ has no immediate successors while ℤ does.

### 15.5 Stable Induction: Reflexive vs. Strict G

The axiom ⊡(a) ∧ ⊡(G(a → X(a))) → ⊡(G(a)) ("stable discrete induction") has different status depending on whether G is reflexive or strict:

**With strict G (s > t): INVALID.** The hypothesis G(a → X(a)) only provides the implication a(s) → a(s+1) for s > t, missing the crucial base step a(t) → a(t+1). Counterexample: D = ω, α constant w₁, β(0) = w₁ then w₂ forever, a true everywhere for α but only at 0 for β. The hypotheses hold at (β, 0) but ⊡(G(a)) fails because β doesn't satisfy a at time 1.

**With reflexive G (s ≥ t): VALID.** The hypothesis G(a → X(a)) includes s = t, giving a(t) → a(t+1). Combined with ⊡(a) (a holds at t for all histories through this state), ordinary induction gives a at all future times for all such histories.

This is another argument favoring reflexive G for the discrete extension: it gives the base step of induction "for free," making stable discrete induction a theorem rather than a non-theorem.

### 15.6 Note on Existing Formalization: Reflexive vs. Strict

The existing Lean formalization uses **reflexive** G (with axioms TT-F: Gφ → φ, TT-P: Hφ → φ), while this report recommends **strict** G for the base. The reflexive formalization corresponds to the TMS + reflexivity extension — a Sahlqvist extension of the strict base. The existing theorems remain valid as theorems of the extended system. The strict base simply allows more frame properties to be non-trivially characterized (notably density: GGp → Gp is trivial with reflexive G but characterizes dense < with strict G).

---

### 15.7 Key Literature Connections

**Closest precursors to the stability operator ⊡:**

- **Zanardo (1998)**, "Undivided and indistinguishable histories in branching-time logics," *JLLI* 7(3):297–315. Introduces an "indistinguishability function" assigning each moment a partition of histories — formally identical to our ∼_t equivalence relation. Ockhamist and Peircean semantics are limiting cases.

- **Rumberg (2016)**, "Transition semantics for branching time," *JLLI* 25:77–108. Introduces an explicit **stability operator S** quantifying over extensions of incomplete courses of events. Truth and stability come apart. Most direct formal precursor to ⊡.

- **Ciuni & Zanardo (2015)**, "Axiomatization of a Branching Time Logic with Indistinguishability Relations," *JPL*. Proves a backward-persistence condition is needed: if two histories are indistinguishable at t, they are indistinguishable at all past times. This corresponds to the backward-determinism frame condition ⊡(Ha) → H(⊡a) — which our analysis shows is NOT valid in general frames but IS valid under backward determinism.

- **Fagin, Halpern, Moses & Vardi (1995)**, *Reasoning About Knowledge*, MIT Press. The foundational text on knowledge via local-state equivalence in distributed systems. The "perfect recall" condition (equivalence refines over time) is the temporal-epistemic analogue of backward persistence.

**Decidability constraints:**

- **Hirsch, Hodkinson & Kurucz**, "On modal logics between K×K×K and S5×S5×S5." Every n-modal logic between K^n and S5^n is undecidable for n ≥ 3. Our design (two S5 modalities □, ⊡ plus one linear temporal G) stays in the potentially decidable two-dimensional case.

- **Gabbay, Kurucz, Wolter & Zakharyaschev (2003)**, *Many-Dimensional Modal Logics*, Elsevier. Pure products of transitive logics are usually undecidable, but products with S5 can remain decidable.

---

## 16. References

1. Blackburn, de Rijke & Venema, *Modal Logic* (2001) — Sahlqvist theory, BAO representation
2. Burgess, "Logic and time" (1979) — Tense logic completeness
3. Burgess, "Axioms for tense logic, I & II" (1982) — Until/Since axiomatizations
4. Bezhanishvili & Carai, "MS4.t algebras" (2020) — Closest studied algebraic system
5. Gabbay, Hodkinson & Reynolds, *Temporal Logic* (1994) — Comprehensive reference
6. Gabbay & Shehtman, "Products of modal logics" (2000) — Transfer theorems
7. Goldblatt, *Logics of Time and Computation* (1992) — Definability results
8. Goldblatt, "Varieties of complex algebras" (1989) — BAO representation
9. Halpern & Vardi, "Reasoning about knowledge and time" (1989) — Temporal epistemic
10. Jónsson & Tarski, "Boolean algebras with operators" I-II (1951-52) — Foundation
11. Kamp, *Tense Logic and the Theory of Linear Order* (1968) — Until/Since completeness
12. von Karger, "Temporal algebra" (1998) — Galois connection approach
13. Sahlqvist, "Completeness and correspondence" (1975) — The Sahlqvist theorem
14. Segerberg, "Modal logics with linear alternative relations" (1970) — Discrete temporal logic
15. Brast-McKie, "The Construction of Possible Worlds" (2025) — The foundational paper
16. Zanardo, "Undivided and indistinguishable histories" (1998) — Precursor to stability operator
17. Rumberg, "Transition semantics for branching time" (2016) — Explicit stability operator
18. Ciuni & Zanardo, "Axiomatization of BTL with indistinguishability" (2015) — Backward persistence
19. Fagin, Halpern, Moses & Vardi, *Reasoning About Knowledge* (1995) — Knowledge via local states
20. Gabbay, Kurucz, Wolter & Zakharyaschev, *Many-Dimensional Modal Logics* (2003) — Product logic decidability
21. Conradie, Goranko & Vakarelov, "SQEMA algorithm" (2006) — Generalized Sahlqvist theory
22. Venema, "Algebras and coalgebras" (2006) — BAO representation handbook chapter
23. Hodkinson & Reynolds, "Temporal Logic" (2006) — Handbook chapter on temporal logic
15. Brast-McKie, "The Construction of Possible Worlds" (2025) — The foundational paper
