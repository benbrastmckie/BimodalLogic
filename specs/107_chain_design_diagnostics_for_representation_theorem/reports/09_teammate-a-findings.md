# Teammate A Findings: Density Axioms in Burgess 1982 and Related Literature

**Artifact**: 09 | **Role**: Teammate A
**Task**: 107 — Chain design diagnostics for representation theorem
**Focus**: Density axioms in Burgess 1982 and tense logic literature

---

## Key Findings

### 1. Burgess 1982 Does NOT Include Density Axioms in the Base System

Burgess 1982 presents axiom system J₀ for the S,U-tense logic of **all** linear orders (K₀ = class of all linear orders). The axioms A1a–A7a (and their mirror images A1b–A7b), plus truth-functional tautologies and inference rules (MP, Substitution, TG), make no reference to density. There is no GGp→Gp or HHp→Hp in J₀. The main theorem is:

> "A formula α is valid (over K₀) iff it is a thesis (of J₀)."

K₀ is explicitly described as "the class of all linear orders", not restricted to dense or discrete orders.

**Evidence**: Burgess 1982, Section 1.1 (axiom system J₀), Section 1.2 (K₀ defined as all linear orders), Section 1.5 (completeness statement).

### 2. Density Is Listed as an Optional Variant (Section 1.6)

Burgess explicitly separates density as an *extra* axiom added on top of J₀:

| Postulate on < | Axiom for S,U |
|----------------|---------------|
| Density | F′⊤ |
| Discreteness | G′⊥ ∧ H′⊥ |

Where F′α = ~G′~α and G′α = U(⊤,α) ("is for some time going to be uninterruptedly"). The density axiom F′⊤ says: between any two points there is another point (a characteristic of dense orders). Burgess explicitly states these variants follow from "adaptation of our work below", meaning the chronicle construction generalizes to these cases.

**Evidence**: Burgess 1982, Section 1.6, explicit tabulation of variant axioms.

### 3. The Chronicle Construction Does NOT Inherently Require Density

The chronicle construction in Burgess 1982 uses rational numbers (Q) as the *index set* for domain points of finite chronicles — specifically, (f,g) ∈ F requires dom(f) to be a finite subset of Q (condition C0'). However, this is an implementation convenience for inserting points between existing points (e.g., z = (x+y)/2 in Lemma 2.9, y = x+1 in Lemma 2.10), not a requirement that the final model be dense.

**Critical observation**: The final model X is a countable subset of Q with the induced order from Q (Section 2.11: "the order being the usual order on the rationals"). This model need not be dense as a subset. Points are only inserted when required by the completeness argument (handling C4a, C4b, C5a, C5b), so the construction inserts no more points than necessary. The use of Q is for *arithmetic convenience* (computing midpoints and successor integers), not to guarantee density of the output.

**Evidence**: Burgess 1982, Section 2 (C0–C0'), Lemma 2.9 (z = (x+y)/2 for inserting between existing points), Lemma 2.10 (y = x+1 for appending beyond existing points), Section 2.11 (final model defined as ⋃dom(fₙ) ⊆ Q).

### 4. Verbrugge 2004 Treats Density as a Separate Case with a Distinct Proof

Verbrugge 2004 (de Jongh, Veltman, Verbrugge) is explicit about the separation:

- **Lin**: complete for all strict linear orders (no density, no density axiom)
- **P**: complete for all successive strict linear orders (adds P1=¬H⊥, P2=¬G⊥)
- **Q**: complete for all dense, successive strict linear orders — adds the **density axiom (Q): GGϕ→Gϕ**
- **D**: complete for discrete, successive strict linear orders — adds (D1) and (D2)

The density axiom (Q) is listed explicitly as what distinguishes Q from P. The step-by-step proof for Q (Theorem 3) inserts density witnesses at odd stages:

> "At the odd stages density is taken care of as follows: Let t, u be any two successive points of Tₙ. A new point v between each such t and u is added. By Lemma 5 there exists a Δ such that Γ_t ≺ Δ ≺ Γ_u."

This point insertion at odd stages is **exactly** the density-specific step. For Lin and P (Theorems 1 and 2), this odd-stage insertion is absent — no density witnesses are needed.

**Evidence**: Verbrugge 2004, Section 2 (axiom list for Lin, P, Q, D), Lemma 5 (density of ≺ follows from axiom (Q)), Theorem 3 (Q completeness proof), p. 3-4.

### 5. Standard Axiom Systems for Linear Orders Without S/U (G/H only)

From Verbrugge 2004, the standard systems in the G,H language are:

**TM over all strict linear orders** (Lin):
- All tautologies
- G(ϕ→ψ)→(Gϕ→Gψ) and H(ϕ→ψ)→(Hϕ→Hψ)
- PGϕ→ϕ and FHϕ→ϕ
- Gϕ→GGϕ (transitivity/4)
- Fϕ→G(ϕ∨Pϕ∨Fϕ) and mirror (linearity/L1, L2)

**TM over dense strict linear orders** (Q over Lin): adds
- **(Q)** GGϕ→Gϕ (equivalently, Fϕ→FFϕ or the Verbrugge density axiom)

**TM over discrete strict linear orders** (D over P): adds
- **(D1)** (ϕ∧Gϕ)→PGϕ  (every point has an immediate successor)
- **(D2)** (ϕ∧Hϕ)→FHϕ  (every point has an immediate predecessor)

**What axiom characterizes density** (from Verbrugge, Burgess):
- In G,H language: GGϕ→Gϕ (Q-axiom in Verbrugge's notation)
- In S,U language: F′⊤ (Burgess's density axiom), where F′α=¬G′¬α and G′α=U(⊤,α)

**What axioms characterize discreteness** (from Burgess, Verbrugge):
- In S,U language: G′⊥∧H′⊥ (no two points exist such that the first is immediately before the second)
- In G,H language: D1 and D2 above

### 6. Relationship: Density Axiom vs. Use of Q in Construction

There is a subtle distinction that matters for the ProofChecker formalization:

- **Using Q as an index set** in the construction is a *proof technique* (rationals are dense, so midpoints exist for insertion purposes). This does not mean the target logic assumes density.
- **Adding the density axiom F′⊤** changes the *logic* and restricts the *class of models* to dense orders.

Burgess proves completeness for ALL linear orders (K₀) without density axioms in J₀. The chronicle construction uses Q only for its arithmetic properties, producing a countable model that need not itself be dense. When the density axiom is added to get the variant logic (Section 1.6), the construction additionally requires inserting density witnesses between every pair of existing points — a step not present in the base proof.

---

## Confidence Level

**HIGH** for all conclusions above. The Burgess 1982 and Verbrugge 2004 texts are both available in full and are unambiguous on these points. Key claims are confirmed by:
- Explicit theorem statements (completeness for K₀ = all linear orders)
- Explicit axiom tables (density is a variant, not part of J₀)
- Proof mechanics (chronicle construction does not insert density witnesses in base case)
- Verbrugge's explicit statement that odd stages handle density for Q but not Lin/P

---

## Implications for ProofChecker Task 107

1. **The target for the BX completeness proof should be all linear orders** (no density), matching Burgess's J₀ / K₀.

2. **The chronicle construction is appropriate for the general linear order case** — it uses Q for index arithmetic but does not force the semantics to be dense.

3. **If TM includes a density axiom**, the frame class changes to dense linear orders and additional point-insertion steps (Verbrugge's odd stages) are needed in the proof.

4. **GGp→Gp is the density axiom** — if this formula is present in BX, then BX targets dense orders. If absent, BX targets all linear orders.

5. **Discreteness axioms** (G′⊥∧H′⊥ in Burgess or D1,D2 in Verbrugge) are similarly optional and change the frame class to discrete orders.
