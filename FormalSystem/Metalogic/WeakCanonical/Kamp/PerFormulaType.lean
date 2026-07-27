/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.ExistsForallFormula

/-!
# Per-formula-finite point/interval types

**Purpose.** This module promotes the per-formula-finite representation validated by the Phase-1
de-risking gate (`InfAlphabetProbe.lean`) to a production home. It is the additive foundation of
the enumeration/rendering re-encode: the whole
`UnaryType`/`IntervalType` model-enumeration layer, built on `Finset.univ` over the whole alphabet,
is re-encoded onto **per-formula finite atom sets**. Rabinovich never enumerates the whole alphabet:
every formula in the translation mentions only finitely many atoms (Prop 3.5, PDF p.5; Def 3.1,
p.4).

## The per-formula representation

- `UnaryTypeFin sig F M := {a // a ∈ M} → Bool` — a **partial** 1-type: a truth assignment to
  exactly the finite mentioned-atom set `M : Finset (AtomKind (sigE sig F) 1)`, NOT a total
  assignment to the whole (Option-A-infinite) alphabet. Its `Fintype` (used by the disjunctions
  below) depends only on `M` being finite — never on any
  `Fintype (AtomKind (sigE sig F) 1)` / `Fintype (sigE sig F).preds` — so it survives the infinite
  E[Σ] of Def 4.1 (p.5).
- `partialHolds N c y` — a point `y` realizes `c`: atom-wise agreement over the mentioned atoms
  `M`. The per-formula-finite analog of `unaryHolds`.
- `IntervalTypeFin sig F M := Finset (UnaryTypeFin sig F M)` and `intervalHoldsFin N S y` —
  the per-formula-finite analogs of `IntervalType`/`intervalHolds`.

## The (deleted) finite-alphabet `completions` bridge

During the additive migration this module also carried the finite-alphabet `completions`
bridge (`completions` / `mem_completions` / `intervalHolds_completions_iff`), which let each
old total-type statement be reproved as a consequence of its Fin-variant WHILE `sigE` was
still finite. The bridge was DELETED at the switchover (before the summand flip makes `sigE`
infinite): the Fin layer is self-contained and no consumer routes through total 1-types.

## Reference grounding: Rabinovich PDF page → repo construct

| Rabinovich (PDF) | Statement | This module |
|---|---|---|
| Def 3.1, p.4 | unary quantifier-free `αⱼ`/`βⱼ`; each mentions finitely many atoms | `UnaryTypeFin
sig F M` |
| Def 3.1, p.4 | a point realizes a unary type (atom-wise agreement) | `partialHolds` /
`charTypeFin` |
| Prop 3.5, p.5 | the type is a *finite* disjunction of the mentioned atoms | `IntervalTypeFin` /
`intervalHoldsFin` |
| Def 4.1, p.5 | E[Σ] infinite ⇒ no whole-alphabet `Finset.univ` in the Fin layer | enumeration is
over `{a // a ∈ M}`, never over `UnaryType` |

## References
- Rabinovich, *A Proof of Kamp's Theorem* (2014), Def 3.1 (p.4), Prop 3.5 (p.5), Def 4.1 (p.5).
  Cited by PDF page; the companion markdown transcription is corrupt.
- `ExistsForallFormula.lean` (`UnaryType`, `unaryHolds`, `unaryHolds_iff`, `IntervalType`,
  `intervalHolds`); `NormalForm.lean` (`AtomKind`, `atom_eval`, `nf_characteristic`,
  `nf_characteristic_satisfies`); `InfAlphabetProbe.lean` (the Phase-1 gate, which imports this
  module and keeps only the gate equivalence).
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax (Formula Atom)
open FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. The per-formula-finite partial 1-type (promoted from the Phase-1 gate) -/

/-- A **partial** 1-type over the finite mentioned-atom set `M`: a truth assignment to exactly the
atoms in `M`. NOT a total assignment to the whole (Option-A-infinite) alphabet. Its `Fintype`
(needed for the disjunctions below) is `Fintype ({a // a ∈ M} → Bool)`, which
depends only on `M` being finite — never on `Fintype (AtomKind (sigE sig F) 1)`. -/
abbrev UnaryTypeFin (sig : MonadicSignature) (F : Finset Formula)
    (M : Finset (AtomKind (sigE sig F) 1)) : Type :=
  {a : AtomKind (sigE sig F) 1 // a ∈ M} → Bool

/-- A point `y` **realizes** the partial type `c`: atom-wise agreement over the mentioned atoms
`M`. A bounded conjunction over the finite `M` — the per-formula-finite analog of `unaryHolds`. -/
def partialHolds (N : OrderedMonadicStructure (sigE sig F))
    {M : Finset (AtomKind (sigE sig F) 1)} (c : UnaryTypeFin sig F M) (y : N.carrier) : Prop :=
  ∀ a : {a : AtomKind (sigE sig F) 1 // a ∈ M}, (atom_eval N (fun _ => y) a.1 ↔ c a = true)

open Classical in
/-- The **characteristic completion** of `y` over `M` (the per-formula-finite analog of
`charType`): the partial type recording `y`'s actual truth value on each mentioned atom. Ranges
over `M` only. -/
noncomputable def charTypeFin (N : OrderedMonadicStructure (sigE sig F))
    (M : Finset (AtomKind (sigE sig F) 1)) (y : N.carrier) : UnaryTypeFin sig F M :=
  fun a => decide (atom_eval N (fun _ => y) a.1)

/-- **Leaf fact.** A point realizes its own characteristic completion over `M`. -/
theorem partialHolds_charTypeFin (N : OrderedMonadicStructure (sigE sig F))
    (M : Finset (AtomKind (sigE sig F) 1)) (y : N.carrier) :
    partialHolds N (charTypeFin N M y) y := by
  classical
  intro a
  simp only [charTypeFin, decide_eq_true_eq]

/-! ## 2. Per-formula-finite interval types and their satisfaction -/

/-- A **partial** interval type over the per-formula-finite representation: a finite set of partial
1-types over the mentioned-atom set `M`. The per-formula-finite analog of `IntervalType`. Its
`Fintype`/`Finset` structure depends only on `M`, so it survives the infinite alphabet. -/
abbrev IntervalTypeFin (sig : MonadicSignature) (F : Finset Formula)
    (M : Finset (AtomKind (sigE sig F) 1)) : Type :=
  Finset (UnaryTypeFin sig F M)

/-- A point `y` **satisfies** the per-formula-finite interval type `S`: some admissible partial
completion `c ∈ S` is realized at `y`. The per-formula-finite analog of `intervalHolds`; the search
`∃ c ∈ S` is a bounded (finite) existential over the `Finset` `S`. -/
def intervalHoldsFin (N : OrderedMonadicStructure (sigE sig F))
    {M : Finset (AtomKind (sigE sig F) 1)} (S : IntervalTypeFin sig F M) (y : N.carrier) : Prop :=
  ∃ c ∈ S, partialHolds N c y

/-! ## 3. Restriction / weakening maps -/

/-- **Restriction** of a total complete 1-type to the mentioned-atom set `M`: forget the values on
atoms outside `M`. This is the total→partial direction used to feed complete types into the
per-formula layer. -/
def restrict {M : Finset (AtomKind (sigE sig F) 1)} (τ : UnaryType sig F) : UnaryTypeFin sig F M :=
  fun a => τ a.1

/-- **Weakening** a partial 1-type from a larger mentioned set `M'` to a smaller `M ⊆ M'`: restrict
the assignment to the atoms of `M`. -/
def weaken {M M' : Finset (AtomKind (sigE sig F) 1)} (h : M ⊆ M')
    (c : UnaryTypeFin sig F M') : UnaryTypeFin sig F M :=
  fun a => c ⟨a.1, h a.2⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
