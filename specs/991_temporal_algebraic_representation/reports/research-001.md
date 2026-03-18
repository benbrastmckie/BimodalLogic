# Temporal Algebraic Representation: Shift-Closed Tense S5 Algebras

## Research Report 001 — Comprehensive Analysis

**Date**: 2026-03-18
**Scope**: Extending the algebraic representation theorem to capture the full bimodal temporal-modal logic TM at the highest level of algebraic abstraction.

---

## 1. Executive Summary

The ProofChecker has two representation theorems at different levels of abstraction:

1. **Algebraic Representation** (`AlgebraicRepresentation.lean`): A pure Boolean algebra construction. The Lindenbaum quotient forms a Boolean algebra; ultrafilters biject with MCSs; consistent formulas are satisfiable in the ultrafilter model. This captures the **propositional/modal skeleton** but ignores temporal structure entirely — G and H are present as interior operators on the quotient but play no role in the representation.

2. **Parametric Representation** (`ParametricRepresentation.lean`): A conditional theorem parametric in duration type D. Given a BFMCS construction, it produces a full TaskFrame countermodel for any non-theorem. This captures the **full temporal-modal structure** but the construction is procedural, not algebraic — it relies on explicit FMCS chains, temporal coherence witnesses, and shift-closed omega sets.

The goal is a **single algebraic structure** whose representation theorem subsumes both, lifting the result to the highest level of abstraction with the most elegant expression. This document presents the design for such a structure: the **Shift-Closed Tense S5 Algebra (STSA)**.

---

## 2. The Algebraic Variety: Shift-Closed Tense S5 Algebra

### 2.1 Definition

An STSA is a tuple **(A, □, G, H, σ)** where:

1. **A** is a Boolean algebra
2. **□, G, H : A → A** are interior operators (deflationary, monotone, idempotent)
3. **□** satisfies S5: `□a ⊔ □(aᶜ) = ⊤` (partition/monadic condition)
4. **σ : A ≃ A** is an involutive Boolean automorphism with:
   - `σ(G(a)) = H(σ(a))` and `σ(H(a)) = G(σ(a))`
   - `σ(□(a)) = □(σ(a))`
   - `σ(σ(a)) = a`
5. **Interaction** (shift-closure equations):
   - `□a ≤ □(G(a))` — (MF: necessity is temporally stable)
   - `□a ≤ G(□(a))` — (TF: necessity persists across time)
6. **Temporal connectedness**: `a ≤ G((H(aᶜ))ᶜ)` — (TA)
7. **Temporal introspection**: `H(a) ⊓ G(a) ≤ G(H(a))` — (TL, simplified via T-axioms)
8. **Linearity**: `F(a) ⊓ F(b) ≤ F(a ⊓ b) ⊔ F(a ⊓ F(b)) ⊔ F(F(a) ⊓ b)` where `F(x) = (G(xᶜ))ᶜ`

### 2.2 Why This Name

- **Shift-Closed**: The MF+TF interaction axioms are the precise algebraic encoding of the semantic property that the set of admissible histories Ω is closed under time-shifts. This is the axiomatization's distinctive feature.
- **Tense**: The pair (G, H) with duality σ is a tense algebra structure (Goldblatt's terminology).
- **S5**: The □ operator satisfies the full S5 partition condition, making it a monadic Boolean algebra operator.

### 2.3 The Combined Interaction Inequality

The two interaction axioms combine into a single fundamental inequality:

```
□a ≤ □(G(a)) ⊓ G(□(a))
```

This says: **the □-fixed points form a G-invariant subalgebra**. In frame terms: the equivalence classes under modal accessibility are time-invariant — which is precisely shift-closure.

---

## 3. Complete Axiom-to-Equation Translation

Every TM axiom becomes an algebraic inequality on the Lindenbaum algebra:

### 3.1 Propositional (absorbed into Boolean algebra structure)

No additional equations. The K, S, EFQ, and Peirce axioms are exactly what makes the quotient a Boolean algebra.

### 3.2 S5 Modal

| Axiom | Schema | Algebraic Form |
|-------|--------|----------------|
| MT | □φ → φ | □a ≤ a (deflationary) |
| M4 | □φ → □□φ | □a ≤ □(□a), combined with MT: □(□a) = □a (idempotent) |
| MB | φ → □◇φ | a ≤ □((□(aᶜ))ᶜ) |
| M5 | ◇□φ → □φ | (□((□a)ᶜ))ᶜ ≤ □a, i.e., ◇(□a) ≤ □a |
| MK | □(φ→ψ) → □φ → □ψ | □(aᶜ ⊔ b) ⊓ □a ≤ □b (from monotonicity) |

**Compact S5 characterization**: All five reduce to the single equation:
```
□a ⊔ □(aᶜ) = ⊤
```
together with □ being an interior operator (deflationary + monotone + idempotent).

### 3.3 Temporal

| Axiom | Schema | Algebraic Form |
|-------|--------|----------------|
| TT-F | Gφ → φ | G(a) ≤ a |
| TT-P | Hφ → φ | H(a) ≤ a |
| T4 | Gφ → GGφ | G(a) ≤ G(G(a)), with TT-F: G(G(a)) = G(a) |
| TK | G(φ→ψ) → Gφ→Gψ | Monotonicity of G |
| TA | φ → GPφ | a ≤ G((H(aᶜ))ᶜ) |
| TL | △φ → GHφ | H(a) ⊓ a ⊓ G(a) ≤ G(H(a)), simplified: H(a) ⊓ G(a) ≤ G(H(a)) |

### 3.4 Interaction (Shift-Closure)

| Axiom | Schema | Algebraic Form |
|-------|--------|----------------|
| MF | □φ → □Gφ | □a ≤ □(G(a)) |
| TF | □φ → G□φ | □a ≤ G(□a) |

### 3.5 Linearity

| Axiom | Schema | Algebraic Form |
|-------|--------|----------------|
| Linearity | Fφ ∧ Fψ → F(φ∧ψ) ∨ F(φ∧Fψ) ∨ F(Fφ∧ψ) | F(a) ⊓ F(b) ≤ F(a⊓b) ⊔ F(a⊓F(b)) ⊔ F(F(a)⊓b) |

---

## 4. Representation Theorem Architecture

### 4.1 The Four Stages

The representation proceeds in four stages, each building on the previous:

**Stage 1: Stone Space (Boolean layer)**
- Spec(A) = ultrafilters of A = MCSs (via UltrafilterMCS bijection, fully proven)
- This is the Stone space: a compact totally disconnected space
- The existing `AlgebraicRepresentation` lives here

**Stage 2: Relational Frame (Jónsson-Tarski layer)**
- Each interior operator i induces a canonical relation R_i on Spec(A):
  ```
  R_i(U, V)  iff  {a : i(a) ∈ U} ⊆ V
  ```
- For □: R_□ is an equivalence relation (S5 ⟹ partition)
- For G: R_G is a preorder (S4 ⟹ reflexive + transitive)
- For H: R_H = (R_G)⁻¹ (temporal duality via σ)
- This is exactly `CanonicalR` in the existing codebase

**Stage 3: Temporal Structuring (FMCS layer)**
- R_G restricted within each R_□ class gives a linear preorder (from linearity axiom)
- TA ensures temporal connectedness: every point has future and past
- An **FMCS** is a maximal R_G-chain: a function D → Spec(A) respecting R_G
- A **BFMCS** is the R_□-saturation: all FMCSs through a given R_□-class
- The MF+TF interaction conditions guarantee shift-closure of the BFMCS

**Stage 4: Full Representation (TaskFrame layer)**
- The algebra A embeds into the complex algebra of TaskFrame(W, D, task_rel) where:
  - W = Spec(A) = ultrafilters = MCSs
  - D = parametric ordered abelian group
  - task_rel = parametric_canonical_task_rel (CanonicalR for d>0, converse for d<0, identity for d=0)
  - Ω = ShiftClosedParametricCanonicalOmega
- The embedding: a ↦ {U ∈ Spec(A) : a ∈ U}
- The truth lemma proves this embedding respects □, G, H

### 4.2 How This Subsumes the Existing Theorems

```
STSA Representation (Stage 4)
    │
    ├── contains AlgebraicRepresentation (Stage 1)
    │   "consistent formulas have ultrafilter witnesses"
    │
    └── contains ParametricRepresentation (Stages 2-4)
        "non-theorems have TaskFrame countermodels"
```

The algebraic representation is the **fiber at a single time point** of the full temporal representation. At any fixed time t, the set of worlds satisfying φ is exactly the set of ultrafilters containing [φ].

### 4.3 The Complex Algebra of a TM-Frame

Given a TaskFrame F with shift-closed Ω, the complex algebra is:
- Universe: propositions = subsets of evaluation contexts {(τ,t) : τ ∈ Ω, t ∈ D}
- □S = {(τ,t) | ∀σ ∈ Ω, (σ,t) ∈ S} — universal over histories at same time
- G(S) = {(τ,t) | ∀s ≥ t, (τ,s) ∈ S} — universal over future times
- H(S) = {(τ,t) | ∀s ≤ t, (τ,s) ∈ S} — universal over past times

This complex algebra is itself an STSA (soundness), and the Lindenbaum algebra embeds into it (completeness).

---

## 5. The Role of Temporal Duality

### 5.1 Algebraic Automorphism

The `swap_temporal` involution on Formula descends to σ : LindenbaumAlg ≃ LindenbaumAlg:
```
σ([φ]) = [swap_temporal(φ)]
```

Properties:
- σ² = id (from swap_temporal_involution)
- σ(G(a)) = H(σ(a)) (G ↔ H swap)
- σ(□(a)) = □(σ(a)) (□ is self-dual)
- σ preserves ⊓, ⊔, ᶜ, ⊤, ⊥ (Boolean automorphism)

### 5.2 Frame Dual

On Spec(A), σ induces a homeomorphism that:
- Reverses temporal order: R_G(U,V) iff R_H(σU, σV)
- Preserves modal structure: R_□(U,V) iff R_□(σU, σV)
- Reverses histories: if h : D → Spec(A) is an FMCS, then t ↦ σ(h(-t)) is also an FMCS

This is **time-reversal symmetry** — the algebraic incarnation of the temporal duality inference rule.

### 5.3 Eliminative Power

Temporal duality means H is determined by G and σ. The STSA can be presented with signature (A, □, G, σ) where H is defined as H(a) := σ(G(σ(a))). This reduces the independent operator count from three to two plus an involution.

---

## 6. Critical Analysis: Obstacles and Resolutions

### 6.1 "Where Do Times Come From?"

**Problem**: Ultrafilters give world-states. Times are NOT ultrafilters. The algebra doesn't "know" D.

**Resolution**: D remains an external parameter, exactly as in the parametric theorem. The STSA representation theorem is:

> For any STSA A and any ordered abelian group D satisfying the appropriate density/discreteness conditions, A embeds into the complex algebra of a D-parametric TM-frame.

This is not a deficiency — it's a feature. The same algebra A can be represented over different time domains (Int, Rat, etc.), corresponding to different extensions (discrete, dense).

### 6.2 Linearity is Not Equational (But It's Quasi-Equational)

**Problem**: The linearity axiom `F(a) ⊓ F(b) ≤ F(a⊓b) ⊔ F(a⊓F(b)) ⊔ F(F(a)⊓b)` is disjunctive. In BAO theory, disjunctive conditions sometimes fail to define a variety.

**Resolution**: This particular formula IS a Sahlqvist formula (it's built from boxed atoms and positive formulas). By the Sahlqvist correspondence theorem, it defines a first-order frame condition (linearity of the temporal order) and the class of algebras satisfying it IS a variety. No obstacle here.

### 6.3 Shift-Closure is Second-Order, But Axiomatized First-Order

**Problem**: Shift-closure is a condition on SETS of histories (second-order), yet MF+TF are first-order algebraic laws.

**Resolution**: This is the central insight of the whole architecture. MF+TF are sound iff Ω is shift-closed (proven in Soundness.lean — they're the ONLY axioms that use `h_sc`). And the canonical construction automatically produces shift-closed Ω (proven in ParametricHistory.lean). So the first-order algebraic laws are COMPLETE for the second-order semantic property when restricted to canonical frames. This is analogous to how the S5 axioms (first-order in the algebra) capture the equivalence-relation property (second-order in general, but first-order on canonical frames).

### 6.4 G Preserves Only Finite Meets

**Problem**: The Jónsson-Tarski representation requires completely additive operators for full embedding. G only preserves finite meets (from TK).

**Resolution**: The Lindenbaum algebra is countable and atomic — canonical extensions are not needed. The standard canonical model construction (ultrafilter frame) suffices because:
- The algebra embeds into P(Spec(A)) via a ↦ {U : a ∈ U}
- This embedding preserves finite meets/joins (Stone representation)
- G's finite meet preservation is enough for the truth lemma proof by formula induction

For the general abstract case (arbitrary STSA, not just the Lindenbaum algebra), the Gehrke-Jónsson canonical extension theory applies, but this is future work beyond the current scope.

---

## 7. Axiom–Frame Condition Correspondence

### 7.1 Complete Table

| Axiom | Algebraic Form | Frame Condition | Semantic Requirement |
|-------|---------------|-----------------|---------------------|
| K, S, EFQ, Peirce | (Boolean algebra) | None | Classical propositional |
| MT | □a ≤ a | R_□ reflexive | S5 accessibility |
| M4 | □(□a) = □a | R_□ transitive | S5 accessibility |
| MB | a ≤ □◇a | R_□ symmetric | S5 accessibility |
| M5 | ◇□a ≤ □a | R_□ Euclidean | S5 accessibility |
| MK | □ monotone | R_□ normal | Universal quantification |
| TK | G monotone | R_G normal | Universal quantification |
| T4 | G(Ga) = Ga | R_G transitive | Reflexive temporal order |
| TT-F | Ga ≤ a | R_G reflexive | t ≤ t |
| TT-P | Ha ≤ a | R_H reflexive | t ≤ t |
| TA | a ≤ G(Pa) | R_G-connected | Temporal connectedness |
| TL | Ha ⊓ Ga ≤ G(Ha) | R_G, R_H compatible | Temporal introspection |
| Linearity | F(a)⊓F(b) ≤ ... | R_G linear | Linear temporal order |
| **MF** | **□a ≤ □(Ga)** | **ShiftClosed(Ω)** | **Time-shift invariance** |
| **TF** | **□a ≤ G(□a)** | **ShiftClosed(Ω)** | **Time-shift invariance** |
| DN | Fa ≤ FFa | DenselyOrdered D | Dense temporal order |
| DF | ... | SuccOrder D | Discrete temporal order |
| Seriality | F⊤, P⊤ | NoMax/NoMinOrder | Unbounded time |

### 7.2 The MF/TF Anomaly

MF and TF are unique among the base axioms: they are the ONLY ones whose soundness requires a **model-level** property (ShiftClosed Ω) rather than a **frame-level** property. Every other axiom's validity proof uses only frame structure (reflexivity, transitivity, linearity, etc.) or is unconditional.

This is visible in `Soundness.lean`:
```lean
-- MF: explicitly uses h_sc and time_shift
theorem modal_future_valid (φ : Formula) : ⊨ ((φ.box).imp ((φ.all_future).box)) := by
  intro T _ _ _ F M Omega h_sc τ _h_mem t  -- h_sc : ShiftClosed Omega
  ...
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t)) (h_sc σ h_σ_mem (s - t))
```

All other base axiom proofs either don't mention `h_sc` or use it trivially.

---

## 8. Dropping MF/TF: The Decoupled Base Logic

### 8.1 What Remains

If MF and TF are dropped, we get a **16-axiom base** (call it TM⁻):
- Full S5 modal logic (MT, M4, MB, M5, MK)
- Full reflexive temporal logic (TK, T4, TT-F, TT-P, TA, TL, Linearity)
- Classical propositional logic (K, S, EFQ, Peirce)

### 8.2 What Is Lost

**Perpetuity principles**: P1 (□φ→△φ), P2 (▽φ→◇φ), P3 (□φ→□△φ), P4 (◇▽φ→◇φ), P5 (◇▽φ→△◇φ) — ALL require MF or TF in their derivations.

**Time-shift invariance**: The semantic guarantee that truth is preserved under temporal translation of histories.

**Modal-temporal coupling**: Without MF/TF, □ and G are algebraically independent — knowing something is necessary tells you nothing about its temporal persistence.

### 8.3 The Algebraic Structure of TM⁻

TM⁻ algebras are:
```
(A, □, G, H, σ) where:
- A is a Boolean algebra
- □ is an S5 interior operator
- G, H are S4 interior operators with duality σ
- TA, TL, Linearity hold
- BUT: no interaction between □ and G/H
```

This is a **product-like** structure: the modal dimension (□) and temporal dimension (G, H) are orthogonal. The representation would decompose into:
- A set of possible worlds W with S5 equivalence relation (from □)
- A linearly ordered time domain D with reflexive ≤ (from G, H)
- BUT: no constraint linking worlds across times (no shift-closure)

### 8.4 Correspondence Theorem for Sublogics

Dropping different axioms yields different logics with corresponding frame relaxations:

| Dropped Axiom(s) | Resulting Logic | Frame Relaxation |
|-------------------|----------------|------------------|
| None (full TM) | S5 + Tense + ShiftClosed | Full TM-frame |
| MF, TF | TM⁻ (decoupled) | No shift-closure: modal and temporal independent |
| MF only | TM without MF | □a ≤ □Ga fails: necessity not temporally stable |
| TF only | TM without TF | □a ≤ G□a fails: necessity not temporally persistent |
| Linearity | TM-branch | Branching time (not linear) |
| TA | TM without TA | Temporal gaps allowed |
| TL | TM without TL | Weakened temporal introspection |
| MB, M5 (keep MT,M4) | S4-Tense | Modal accessibility is preorder, not equivalence |
| TT-F, TT-P | Irreflexive TM | Strict temporal order (< instead of ≤) |

### 8.5 The Lattice of Sublogics

```
         TM (full, 18 base axioms)
        /    \
   TM-MF     TM-TF    (drop one interaction axiom)
        \    /
         TM⁻           (drop both: decoupled modal+temporal)
        /    \
    S5+Lin   Tense+Lin  (drop one dimension entirely)
        \    /
         CPC            (classical propositional calculus)
```

Each level corresponds to relaxing frame conditions: full TM-frames → non-shift-closed frames → product frames → pure modal/temporal frames → trivial frames.

---

## 9. The Elegant Expression

### 9.1 The One-Sentence Theorem

**Theorem (STSA Representation).** *The Lindenbaum algebra of TM is the free Shift-Closed Tense S5 Algebra on countably many generators, and every STSA embeds into the complex algebra of a shift-closed TaskFrame.*

### 9.2 The Lean Formalization Path

The formalization would involve:

1. **Define STSA as a Lean structure** extending `BooleanAlgebra` with `□`, `G`, `H`, `σ` and the interaction axioms.

2. **Prove LindenbaumAlg is an STSA**: All the pieces exist — `BooleanStructure.lean` gives the Boolean algebra, `InteriorOperators.lean` gives the three interior operators, and the axiom congruences give the interaction laws. The temporal duality `σ` needs to be lifted from `swap_temporal` to the quotient.

3. **Prove the representation theorem**: This is essentially the parametric representation, restructured as:
   - Given STSA A, construct Spec(A) (= ultrafilters = MCSs)
   - Define R_□, R_G on Spec(A) from the operators
   - Build FMCS chains and BFMCS bundles from R_G chains
   - Build ShiftClosedOmega from BFMCS
   - Prove truth lemma by structural induction using operator properties

4. **Prove soundness**: Every STSA axiom is valid in the complex algebra of any TM-frame. This is the existing `Soundness.lean` restructured algebraically.

### 9.3 What's New vs. What Already Exists

| Component | Status | File |
|-----------|--------|------|
| Boolean algebra on LindenbaumAlg | ✓ Complete | BooleanStructure.lean |
| □, G, H as interior operators | ✓ Complete | InteriorOperators.lean |
| Ultrafilter ↔ MCS bijection | ✓ Complete | UltrafilterMCS.lean |
| CanonicalR (R_G on MCSs) | ✓ Complete | Bundle/CanonicalFrame.lean |
| FMCS, BFMCS structures | ✓ Complete | Bundle/FMCSDef.lean, BFMCS.lean |
| Parametric truth lemma | ✓ Complete | ParametricTruthLemma.lean |
| Shift-closed omega | ✓ Complete | ParametricHistory.lean |
| **σ (temporal duality on quotient)** | **NEW** | Needs LindenbaumQuotient extension |
| **STSA structure definition** | **NEW** | New file: TenseS5Algebra.lean |
| **STSA instance for LindenbaumAlg** | **NEW** | Wire existing pieces |
| **Unified representation theorem** | **NEW** | Restructure ParametricRepresentation.lean |

The key insight: **~80% of the formalization already exists**. The temporal algebraic representation is not a new construction — it's a reorganization of existing pieces into a cleaner algebraic framework.

---

## 10. Connection to the Paper

The paper's perpetuity principles P1-P6 are the **characteristic theorems** of STSA:

- P1 (□φ→△φ): Derived from MF+TF+MT — the fundamental consequence of shift-closure
- P3 (□φ→□△φ): The boxed version — necessity of perpetuity
- P5 (◇▽φ→△◇φ): The deepest consequence — uses modal_5 (derived S5 theorem) + temporal K distribution + shift-closure

The paper says (§2, semantics chapter):
> "Time-shift enables proofs of the bimodal axioms MF (□φ → □Gφ) and TF (□φ → G□φ) which together imply the perpetuity principles."

The STSA representation theorem makes this precise: **MF and TF are the algebraic equations that axiomatize the semantic property of shift-closure, and the perpetuity principles are their algebraic consequences in the STSA variety.**

---

## 11. Future Directions

### 11.1 Canonical Extensions
For the abstract representation (arbitrary STSA, not just Lindenbaum), the Gehrke-Jónsson canonical extension theory provides the proper framework. The canonical extension Aσ of an STSA A is a complete STSA, and the σ-extensions of □, G, H are completely additive operators. This gives a full Jónsson-Tarski representation for arbitrary STSAs.

### 11.2 Categorical Duality
The proper categorical statement: there is a dual equivalence between the category of STSAs (with STSA homomorphisms) and the category of descriptive TM-frames (with bounded morphisms). This extends the Goldblatt-Thomason theorem to the bimodal setting.

### 11.3 Extension Classification
The STSA framework naturally accommodates the dense and discrete extensions:
- Dense STSA: Add `F(a) ≤ F(F(a))` (density equation)
- Discrete STSA: Add discreteness + seriality equations
- These define subvarieties of STSA with corresponding frame subclasses

### 11.4 Decidability
The finite model property for TM (if it holds) corresponds to the STSA being generated by its finite members — every equation true in all finite STSAs is true in all STSAs. This connects to the tableau-based decidability in the codebase.
