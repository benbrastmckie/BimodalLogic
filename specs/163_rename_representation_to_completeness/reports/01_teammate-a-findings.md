# Teammate A Findings: Primary Approach — Jónsson-Tarski Representation for TM Logic

**Task**: 163 — Rename representation theorems to completeness in Algebraic module
**Angle**: Primary implementation approach and mathematical architecture
**Date**: 2026-05-18

---

## Key Findings

### 1. The Current Code Is Completeness, Not Representation

After reading all 12 files in `Algebraic/`, the diagnosis is unambiguous: everything currently named "representation" is actually **completeness** (or soundness-completeness). The key theorems:

- `algebraic_representation_theorem`: `AlgSatisfiable φ ↔ AlgConsistent φ` — this is a syntactic-semantic bridge between provability and satisfiability. It is not structural.
- `parametric_algebraic_representation_conditional`: Given non-provability, produce a countermodel — this is the standard Henkin completeness theorem in algebraic clothing.

A genuine Jónsson-Tarski representation would take an **abstract** STSA (no mention of `Formula`, `DerivationTree`, or provability) and embed it into the complex algebra of a relational structure.

### 2. What a Genuine Jónsson-Tarski Representation Requires

The standard J-T representation theorem for BAOs proceeds in three steps:

**(a) Complex Algebra Construction (`S⁺`)**: Given a relational structure `S = (W, R₁, R₂, ...)`, form the powerset algebra `𝒫(W)` equipped with operators derived from the relations:
- For unary `R`: `f_R(X) = {w | ∃v ∈ X. R(w,v)}` (diamond) or `{w | ∀v. R(w,v) → v ∈ X}` (box)
- For binary `R` (like Since/Until): `f_R(X,Y) = {w | ∃v. R(w,v) ∧ v ∈ X ∧ ∀u. (w < u < v → u ∈ Y)}` 

In TM logic, the frame is a `TaskFrame D`, so the complex algebra is:
- `𝒫(WorldState)` as a complete atomic Boolean algebra
- `box_S⁺(X) = {w | ∀d, ∀u. task_rel w d u → u ∈ X}` (or via S5 equivalence classes)
- `G_S⁺(X) = {w | ∀d > 0, ∀u. task_rel w d u → u ∈ X}` (strict future universal)
- `H_S⁺(X) = {w | ∀d < 0, ∀u. task_rel w d u → u ∈ X}` (strict past universal)
- `σ_S⁺(X)` = temporal duality involution on `𝒫(WorldState)`, swapping future/past perspectives

**(b) Ultrafilter Frame Construction (`A₊`)**: Given an abstract STSA `A`, form the canonical structure whose points are the ultrafilters of `A`:
- `Uf(A)` = set of ultrafilters of the Boolean reduct of `A`
- `R_G(U, V)` iff `∀a. G(a) ∈ U → a ∈ V` (already defined in `Boneyard/UltrafilterChain.lean`)
- `R_H(U, V)` iff `∀a. H(a) ∈ U → a ∈ V`
- `R_Box(U, V)` iff `∀a. □(a) ∈ U → a ∈ V` (already defined)

**(c) Representation Embedding**: The map `η : A → (A₊)⁺` defined by `η(a) = {U ∈ Uf(A) | a ∈ U}` is an injective STSA homomorphism. This embeds `A` into the complex algebra of its ultrafilter frame.

### 3. The Since/Until Complication

Since and Until are **binary** temporal operators, which makes the complex algebra construction more involved than for basic G/H. In the BAO framework:

- `Until(X,Y) = {w | ∃v > w. v ∈ X ∧ ∀u. (w < u < v → u ∈ Y)}` — binary additive operator
- `Since(X,Y) = {w | ∃v < w. v ∈ X ∧ ∀u. (v < u < w → u ∈ Y)}` — binary additive operator

These are **normal additive operators in each argument** (when the other is fixed), making them BAO operators. The STSA typeclass currently doesn't include Since/Until algebraically — this is a gap.

Key references already in `literature/`:
- **Venema 1993 "Since and Until"**: Orthodox axiomatization of SU for well-orders and ω. Shows expressive completeness is key.
- **Burgess 1982**: Axioms for tense logic with S and U — foundational reference.
- **Venema 1991 Ch. 2**: Non-ξ rules for frames with non-first-order-definable properties (irreflexivity). The STSA approach via complex algebras avoids these issues because representation is algebraic.

### 4. Existing Code Reuse Analysis

| File | Reusable for J-T? | Notes |
|------|-------------------|-------|
| `TenseS5Algebra.lean` | **YES — core** | STSA typeclass is exactly the abstract algebra to represent. Needs extension for S/U. |
| `LindenbaumQuotient.lean` | **YES — example** | Provides the canonical STSA instance (Lindenbaum algebra). |
| `BooleanStructure.lean` | **YES — example** | Boolean algebra instance for Lindenbaum. Used to build the STSA instance. |
| `InteriorOperators.lean` | **YES — shared** | Interior operator structure for Box. Used in both completeness and representation. |
| `UltrafilterMCS.lean` | **PARTIAL** | The `Ultrafilter` type and MCS-correspondence are dual-purpose. The ultrafilter type can serve the ultrafilter frame. But the MCS↔ultrafilter bijection is completeness-specific (depends on syntax). |
| `AlgebraicRepresentation.lean` | **RENAME** | Pure completeness. Rename to `AlgebraicCompleteness.lean`. |
| `ParametricCanonical.lean` | **RENAME** | Completeness infrastructure. Rename to `ParametricCanonicalCompleteness.lean` or keep in `Completeness/`. |
| `ParametricHistory.lean` | **RENAME** | Same — completeness specific. |
| `ParametricTruthLemma.lean` | **KEEP** | Truth lemmas are used in both settings (they bridge algebra and semantics). |
| `ParametricRepresentation.lean` | **RENAME** | Rename to `ParametricCompleteness.lean`. |
| `RestrictedParametricTruthLemma.lean` | **KEEP** | Shared infrastructure. |

### 5. What's Already Available in the Boneyard

`Boneyard/StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean` already defines:
- `R_G` on ultrafilters: `∀ a, STSA.G a ∈ U → a ∈ V`
- `R_Box` on ultrafilters: `∀ a, STSA.box a ∈ U → a ∈ V`

These are exactly the relations needed for the ultrafilter frame `A₊`. This code should be **recovered from the Boneyard** and generalized for arbitrary STSAs (not just `LindenbaumAlg`).

---

## Recommended Approach

### Architecture: Two Subdirectories

```
Algebraic/
├── Core/                              # Shared algebraic infrastructure
│   ├── TenseS5Algebra.lean            # STSA typeclass (extended with S/U operators)
│   ├── LindenbaumQuotient.lean        # Lindenbaum-Tarski construction
│   ├── BooleanStructure.lean          # Boolean algebra on Lindenbaum
│   ├── InteriorOperators.lean         # Interior operators (Box)
│   ├── UltrafilterMCS.lean            # Ultrafilter type + MCS correspondence
│   └── TruthLemmas.lean               # Shared truth lemma infrastructure
│
├── Completeness/                      # Renamed completeness theorems
│   ├── AlgebraicCompleteness.lean     # was AlgebraicRepresentation.lean
│   ├── ParametricCompleteness.lean    # was ParametricRepresentation.lean
│   ├── ParametricCanonical.lean       # D-parametric canonical model
│   ├── ParametricHistory.lean         # History construction
│   └── ParametricTruthLemma.lean      # D-parametric truth lemma
│
├── Representation/                    # NEW: Genuine J-T representation
│   ├── ComplexAlgebra.lean            # S⁺: Frame → STSA (powerset algebra)
│   ├── UltrafilterFrame.lean          # A₊: STSA → Frame (ultrafilter frame)
│   ├── RepresentationEmbedding.lean   # η: A ↪ (A₊)⁺ is injective STSA hom
│   ├── FrameProperties.lean           # Properties A₊ inherits from STSA axioms
│   └── Canonical.lean                 # Canonical extension A^σ ≅ (A₊)⁺
│
└── Algebraic.lean                     # Module root (re-exports all)
```

### Dependency Order for New Files

1. **ComplexAlgebra.lean**: Depends only on Semantics (TaskFrame) and Mathlib. Defines the powerset STSA for any TaskFrame. No syntax dependence.

2. **UltrafilterFrame.lean**: Depends on TenseS5Algebra.lean (STSA typeclass) and the Ultrafilter type. Recovers and generalizes the `R_G`, `R_H`, `R_Box` from the Boneyard. Must prove the ultrafilter frame satisfies TaskFrame axioms (nullity, forward_comp, converse).

3. **RepresentationEmbedding.lean**: Depends on both ComplexAlgebra and UltrafilterFrame. Defines `η(a) = {U | a ∈ U}` and proves it's an injective STSA homomorphism. The core of the J-T theorem.

4. **FrameProperties.lean**: Shows which STSA axioms are reflected as frame properties. For example, linearity in the STSA translates to linearity of the temporal order on the ultrafilter frame.

5. **Canonical.lean** (optional/advanced): Shows `(A₊)⁺` is the canonical extension `A^σ`. This is the deep Jónsson-Tarski result. May be deferred.

### STSA Extension for Since/Until

The current STSA typeclass has `box`, `G`, `H`, and `sigma`, but no algebraic Since/Until. For a complete J-T representation, the typeclass needs extension:

```lean
class STSA_SU (α : Type*) extends STSA α where
  /-- Algebraic Until operator (binary) -/
  untl : α → α → α
  /-- Algebraic Since operator (binary) -/
  snce : α → α → α
  /-- Until is normal: untl ⊥ a = ⊥ -/
  untl_normal_left : ∀ a, untl ⊥ a = ⊥
  /-- Until is additive in first argument -/
  untl_additive_left : ∀ a b c, untl (a ⊔ b) c = untl a c ⊔ untl b c
  /-- G definable from Until: Ga = untl(⊥, a) ... or as a residual -/
  ...
  /-- Sigma swaps Until and Since -/
  sigma_untl : ∀ a b, sigma (untl a b) = snce (sigma a) (sigma b)
```

This extension is optional for Phase 1 (which can work with just G/H/Box/sigma), but needed for the full representation.

### Key Mathematical Steps

**Step 1 — Complex Algebra**: For a `TaskFrame D`, define `ComplexSTSA` on `Set WorldState`:
- Boolean ops: set union, intersection, complement
- `box_complex(X) = {w | ∀d ∀u. task_rel w d u → u ∈ X}` (all-worlds-in-equivalence-class)
- `G_complex(X) = {w | ∀d > 0. ∀u. task_rel w d u → u ∈ X}`
- Prove this satisfies all STSA axioms. Uses frame properties (nullity, forward_comp, converse, linearity).

**Step 2 — Ultrafilter Frame**: For an abstract `STSA A`, define `UfFrame`:
- Points: `Ultrafilter A` (the type already exists in UltrafilterMCS.lean)
- `R_G(U,V) = ∀a. G(a) ∈ U → a ∈ V`
- Temporal ordering: `U <_t V` iff `R_G(U,V)` and `U ≠ V`
- Prove this forms a TaskFrame (with appropriate D — likely needs parametric treatment similar to existing completeness)

**Step 3 — Embedding**: Define `η : A → Set (Ultrafilter A)` by `η(a) = {U | a ∈ U}` and prove:
- `η` is injective (ultrafilter separation — standard Stone duality argument)
- `η` preserves Boolean ops (standard)
- `η` preserves `G`: `η(G(a)) = G_complex(η(a))` — this is the key step
- `η` preserves `Box`: similarly
- `η` preserves `sigma`: needs involution to lift to frame level

---

## Evidence/Examples

### The Existing UltrafilterChain Code Validates the Approach

The Boneyard file `UltrafilterChain.lean` already has:
```lean
def R_G (U V : Ultrafilter LindenbaumAlg) : Prop :=
  ∀ a : LindenbaumAlg, STSA.G a ∈ U → a ∈ V

def R_Box (U V : Ultrafilter LindenbaumAlg) : Prop :=
  ∀ a : LindenbaumAlg, STSA.box a ∈ U → a ∈ V
```

These definitions are **already the ultrafilter frame relations** for the J-T representation, just specialized to `LindenbaumAlg`. Generalizing to an arbitrary `STSA α` is straightforward.

### Literature Support

The approach is well-attested in:
1. **Goldblatt-Hodkinson-Venema 2003** (in `literature/`): Detailed treatment of BAO canonical structures, complex algebras, and the relationship between varieties and frame classes. Section 2.1 gives the exact definitions needed.
2. **de Rijke-Venema 1995** (in `literature/`): Sahlqvist theorem for BAOs — all STSA axioms are Sahlqvist, hence the variety is canonical.
3. **Venema 1991 Ch. 2** (in `literature/`): Non-ξ rules and their algebraic meaning — relevant because TM uses irreflexivity.

### Missing Literature

For Since/Until in the BAO/algebraic setting:
- **Venema 1991 Appendices A&B** (in `literature/` as `Venema_1991_Many_Dimensional_Modal_Logics_app_A_B.md`): Contains the algebraic treatment of binary operators in BAOs.
- **Jónsson & Tarski 1951-52** ("Boolean algebras with operators, Parts I & II"): The original papers. Not in `literature/` — should be added as reference (widely available).

### What's NOT Needed

The following literature is about completeness/axiomatization and NOT about representation:
- Burgess 1982 (axioms for S/U — completeness focused)
- Venema 1993 "Since and Until" (orthodox axiomatization — completeness)
- Reynolds 1992, 1994 (axiomatization — completeness)
- Gabbay-Hodkinson-Reynolds 1994 Ch. 9-12 (temporal logic completeness)

These are already well-served by the existing completeness infrastructure.

---

## Confidence Level

**High** for the overall architecture and the renaming/refactoring recommendations. The mathematical structure of J-T representation for BAOs is well-established, and the existing codebase already contains ~60% of the needed infrastructure.

**Medium** for the Since/Until extension. The algebraic treatment of binary temporal operators is less standard than unary operators, and the STSA typeclass extension needs careful design to ensure the interaction axioms are captured correctly. The main risk is that Since/Until may require additional axioms beyond what's in the current STSA.

**Medium** for the ultrafilter frame as a TaskFrame. The standard ultrafilter frame gives a relational structure with the right accessibility relations, but constructing a `TaskFrame D` (with a specific duration group D) from an abstract STSA requires careful work. The duration type D may need to be constructed from the algebra (e.g., as the group of automorphisms of the temporal order), or the representation theorem may need to be stated for a universal D.
