# Teammate C Research: Algebraic Perspective — Interior/Closure Operators

**Task**: 33 — Expand design-choices section with reflexive vs irreflexive semantics analysis
**Focus**: Algebraic classification of G, H, □ operators on the Lindenbaum algebra

---

## Key Findings

The algebraic classification of the temporal operators G (all_future) and H (all_past) as interior operators is **entirely determined by whether the semantics is reflexive or strict**. The modal operator □ is an interior operator under both semantic regimes because its accessibility relation (over world-histories) is always reflexive. This is a load-bearing design distinction: reflexive semantics for G/H yields a richer algebraic structure (interior algebra = S4-algebra) while strict semantics degrades G/H to mere monotone operators.

---

## Operator Classification (Interior vs Closure)

### Definitions

An **interior operator** I on a partial order satisfies:
1. **Deflationary**: I(a) ≤ a
2. **Monotone**: a ≤ b → I(a) ≤ I(b)
3. **Idempotent**: I(I(a)) = I(a)

A **closure operator** C on a partial order satisfies:
1. **Inflationary**: a ≤ C(a)
2. **Monotone**: a ≤ b → C(a) ≤ C(b)
3. **Idempotent**: C(C(a)) = C(a)

Interior and closure operators are de Morgan duals: if I is an interior operator on a Boolean algebra, then C(a) = ¬I(¬a) is a closure operator.

### The Modal Operator □ (Box)

In the ProofChecker codebase, □ is **provably an interior operator** on the Lindenbaum algebra. This is formalized in `/Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean`:

```lean
def box_interior : InteriorOp LindenbaumAlg where
  toFun := box_quot
  le_self := box_le_self      -- Modal T: □φ → φ  (deflationary)
  monotone := box_monotone    -- Modal K: monotone (via necessitation + K-dist)
  idempotent := box_idempotent -- Modal 4+T: □□φ = □φ
```

The three proofs map directly to axioms:
- **Deflationary**: `modal_t` axiom: `□φ → φ`
- **Monotone**: `modal_k_dist`: `□(φ → ψ) → (□φ → □ψ)` + necessitation
- **Idempotent**: `modal_4` (□φ → □□φ) + `modal_t` (the converse direction □□φ → □φ)

The dual operator ◇ (diamond = ¬□¬) is therefore a **closure operator** on the Lindenbaum algebra.

### G and H Under Reflexive Semantics (Current Codebase)

Under reflexive semantics (≤ for both past and future), G and H **satisfy all three interior operator conditions**:

- **Deflationary**: `temp_t_future` (`Gφ → φ`) and `temp_t_past` (`Hφ → φ`) are both valid axioms, since t ≤ t (reflexivity) means the present is included in the quantification
- **Monotone**: via temporal K distribution (`temp_k_dist`) + temporal necessitation
- **Idempotent**: `temp_4` gives Gφ → GGφ; the converse GGφ → Gφ follows from the T-axiom since G(Gφ) → Gφ is an instance of the T-axiom applied to Gφ

The `InteriorOperators.lean` file documents this in a historical note: "This module previously included `G_interior` and `H_interior` instances under reflexive temporal semantics (Task 967)."

The dual existential operators F (some_future) and P (some_past) are correspondingly **closure operators** under reflexive semantics.

### G and H Under Strict Semantics (Removed in Codebase, Task 991)

Under strict semantics (< for temporal quantification), G and H **fail deflationarity**:
- `Gφ → φ` is NOT valid: "all future times" does not include the present
- `Hφ → φ` is NOT valid: "all past times" does not include the present

Strict G and H are therefore **not interior operators** — they retain only monotonicity (proven as `G_monotone`, `H_monotone` in the current codebase) and the 4-axiom direction (Gφ → GGφ). They are not closure operators either (they fail inflationarity). Algebraically, under strict semantics, G and H are **normal modal operators** (satisfying K-distribution and necessitation) without the additional S4 structure.

---

## Topological Semantics

### McKinsey-Tarski Theorem

The McKinsey-Tarski theorem (1944) is the foundational result connecting modal logic to topology: **S4 is sound and complete for the class of all topological spaces**, under the interpretation where:
- □φ = **interior** of the extension of φ (open nucleus)
- ◇φ = **closure** of the extension of φ

More specifically, S4 is complete with respect to any metrizable dense-in-itself topological space (e.g., ℝ or ℚ with the usual topology).

The axioms of S4 correspond exactly to the topological properties of interior:
- **K** (□(φ→ψ) → (□φ→□ψ)): Interior distributes — Int(A) ∩ Int(B) = Int(A ∩ B)
- **T** (□φ → φ): Interior is deflationary — Int(A) ⊆ A
- **4** (□φ → □□φ): Interior is idempotent — Int(Int(A)) = Int(A)

This is exactly the **interior algebra** (also called closure algebra or S4-algebra) structure.

### Temporal Operators on Ordered Topological Spaces

Temporal operators G and H arise naturally in the topology of ordered spaces. Consider a linearly ordered set D with its order topology. Under reflexive semantics:
- Gφ at t means φ holds on the "upper ray" [t, ∞) ∩ D
- Hφ at t means φ holds on the "lower ray" (−∞, t] ∩ D

These correspond to **closed sets** of a natural topology (the Alexandrov topology for the order): in the Alexandrov topology on a preorder, open sets are up-sets (upper-closed sets). Under this interpretation:
- G corresponds to the interior operator restricted to up-sets
- H corresponds to the interior operator restricted to down-sets

**How reflexivity affects the topological interpretation**: Under reflexive semantics, the rays [t, ∞) and (−∞, t] are *closed* in standard topology. The T-axiom (Gφ → φ) corresponds exactly to the statement that the interior of a set does not exceed the set itself. Under strict semantics, the rays (t, ∞) and (−∞, t) are *open*, making the operators more like "open-interior" operations that do not include boundary points—hence no T-axiom.

### The Dense Completeness Connection

The ProofChecker's `density` axiom — `GGφ → Gφ` — has a topological reading: on a *densely ordered* frame, the interior of a set equals the interior of the interior, giving a stronger form of idempotence. Goldblatt's treatment of Kt.4DN (tense logic with density) corresponds algebraically to the density axiom in the ProofChecker's discrete/dense extension architecture.

---

## Algebraic Duality

### Boolean Algebras with Operators (BAOs)

A **Boolean algebra with operators (BAO)** is a Boolean algebra augmented with additional operations that distribute over meets. The ProofChecker's Lindenbaum algebra is precisely a BAO:
- Base: Boolean algebra structure on `LindenbaumAlg` (proven in `BooleanStructure.lean`)
- Operators: box_quot (□), G_quot (G), H_quot (H) with their respective K-distribution axioms

**Interior algebras** are BAOs where the additional operator is an interior operator (satisfying deflationary, monotone, idempotent). S4-algebras are exactly interior algebras.

**Closure algebras** (in the McKinsey-Tarski sense) are BAOs where the operator is a closure operator (inflationary, monotone, idempotent). They are isomorphic to interior algebras by de Morgan duality.

### Tense Algebras

A **tense algebra** extends the interior algebra framework with *two* conjugate operators (G and H for forward and backward modalities). The conjugacy condition captures the "frame reversal" relationship between G and H: G and H are adjoint operators on the Boolean algebra, satisfying:
- Gφ ≤ ψ ↔ φ ≤ Hψ (or a suitable adjunction)

This is reflected in the ProofChecker by the `temp_a` axiom (`φ → G(Pφ)`) and `temp_l` axiom (`△φ → G(Hφ)`), which encode the interaction between G and H.

The critical algebraic property: in a tense algebra with reflexive G and H, both operators are **interior operators** and their duals (F and P) are **closure operators**. This gives a richer algebraic structure than having only monotone operators.

### Canonical Model as Stone Representation

The algebraic representation route in the codebase (`AlgebraicRepresentation.lean`) uses **ultrafilters** of the Lindenbaum algebra as worlds. This is the **Stone representation theorem** specialization: the Stone space of the Boolean algebra `LindenbaumAlg` consists of its ultrafilters, and the modal operators lift to the canonical model. Under the interior operator interpretation, ultrafilters correspond to "points" in the Stone space, and the accessibility relation is given by the relational dual of the operator.

---

## Connection to Frame Semantics

### Algebraic ↔ Kripke Correspondence

The **Jónsson-Tarski representation theorem** (1952) establishes a bijective correspondence between:
- **BAOs** (Boolean algebras with operators)
- **Complex algebras** of Kripke frames

Specifically, for any Kripke frame (W, R), the powerset 2^W with the box operator □_R(X) = {w : R(w) ⊆ X} is a BAO. Conversely, every BAO embeds into a complex algebra.

For frame conditions:
| Frame condition | Algebraic property | Axiom |
|----------------|-------------------|-------|
| R reflexive | □ is deflationary (I(a) ≤ a) | T: □φ → φ |
| R transitive | □ is idempotent (I²=I) | 4: □φ → □□φ |
| R symmetric | □ satisfies B | B: φ → □◇φ |
| R Euclidean | □ satisfies 5 | 5: ◇□φ → □φ |

For the temporal operators:
| Frame condition | Algebraic property | Axiom |
|----------------|-------------------|-------|
| ≤ reflexive (R ⊇ Id) | G deflationary | temp_t_future: Gφ → φ |
| ≤ transitive | G idempotent | temp_4: Gφ → GGφ |
| ≤ dense | density idempotence | density: GGφ → Gφ (plus T gives GGφ = Gφ) |

### Why Reflexive Semantics Gives a Richer Algebraic Structure

Under **reflexive** semantics (G quantifies over s ≥ t), the Lindenbaum algebra for the temporal fragment becomes:
- A **bimodal interior algebra** (two conjugate interior operators G and H)
- This corresponds to a **tense algebra** in the sense of modal algebra literature
- Completeness proofs via canonical models are cleaner: the canonical frame is definitionally reflexive

Under **strict** semantics (G quantifies over s > t):
- The Lindenbaum algebra only has **normal modal operators** (not full interior operators) for G and H
- The additional axiom `CanonicalR_irreflexivity` was needed in Task 991 to force the canonical model to be strict
- This breaks the clean algebraic structure: G and H cannot be treated as interior operators

### ProofChecker Design Choice: Reflexive G/H

The current codebase (post-Task 29) uses **reflexive semantics** for G and H:
```lean
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
| Formula.all_past φ   => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
```

This ensures:
1. G and H are interior operators on the Lindenbaum algebra
2. The Lindenbaum algebra is a proper bimodal interior algebra
3. No special irreflexivity axioms are needed in the canonical model
4. The algebraic and Kripke semantics align cleanly via Jónsson-Tarski

---

## Evidence/References

### Codebase Evidence

1. **`InteriorOperators.lean`** (`/Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean`):
   - Proves `box_interior : InteriorOp LindenbaumAlg` — box is an interior operator
   - Documents that `G_interior` and `H_interior` existed under reflexive semantics (Task 967)
   - Shows G and H have only monotonicity under strict semantics

2. **`BooleanStructure.lean`** (`/Theories/Bimodal/Metalogic/Algebraic/BooleanStructure.lean`):
   - Lindenbaum algebra is a BooleanAlgebra (complete algebraic foundation for BAO)

3. **`Axioms.lean`** (`/Theories/Bimodal/ProofSystem/Axioms.lean`):
   - `temp_t_future`: `Gφ → φ` (deflationary — the key interior property for G)
   - `temp_t_past`: `Hφ → φ` (deflationary — the key interior property for H)
   - These axioms are only present under reflexive semantics (added in Task 29)
   - `modal_t`: `□φ → φ` (deflationary for □, always present)

4. **`Truth.lean`** (`/Theories/Bimodal/Semantics/Truth.lean`):
   - Reflexive semantics: `∀ (s : D), t ≤ s` (includes t itself)
   - This is the semantic grounding for the deflationary property

### Theoretical References

5. **McKinsey-Tarski (1944)**: S4 = logic of topological interior. □ = topological interior, ◇ = topological closure. Interior algebras (= S4-algebras) are the algebraic models.

6. **Jónsson-Tarski (1952)**: Representation theorem for BAOs. Every BAO embeds into a complex algebra of a Kripke frame. Frame reflexivity ↔ operator deflationarity.

7. **Goldblatt, "Logics of Time and Computation" (1987)**: Tense logics as BAOs with two conjugate operators (G/H). The Kt.4T system (tense logic with reflexivity and transitivity) corresponds to bimodal interior algebras.

8. **Blackburn, de Rijke, Venema, "Modal Logic" (2001)**: Chapter on algebraic semantics. The Sahlqvist correspondence for temporal axioms (density, discreteness) is the algebraic mechanism used in the ProofChecker's `FrameClass` architecture.

---

## Confidence Level

**High confidence** for the following:
- □ is an interior operator under current (reflexive) semantics — directly formalized in codebase
- G and H are interior operators under reflexive semantics — documented in codebase history (Task 967), consistent with axioms temp_t_future and temp_t_past
- G and H are NOT interior operators under strict semantics — directly documented in InteriorOperators.lean
- McKinsey-Tarski theorem connection to S4 and topological interior — well-established classical result
- Jónsson-Tarski representation theorem — well-established correspondence

**Medium confidence** for the following:
- Precise topological interpretation of G and H as Alexandrov topology interior operators — plausible from the semantics but not directly verified in a topological completeness theorem for this specific system
- The tense algebra characterization including bimodal conjugacy — standard theory for tense logics but the exact formulation for TM bimodal logic would require checking against Goldblatt/Venema directly

**Low confidence** for:
- Whether the ProofChecker's full TM bimodal logic (with S5 modal □ plus reflexive G/H) has been treated as a tense interior algebra in the existing literature — this specific combination may be novel
