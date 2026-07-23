import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallFormula

/-!
# Per-formula-finite point/interval types + the finite-alphabet `completions` bridge

**Purpose.** This module promotes the per-formula-finite representation validated by the Phase-1
de-risking gate (`InfAlphabetProbe.lean`) to a production home, and adds the finite-alphabet
`completions` bridge that lets every old total-type lemma be consumed while the per-formula
Fin-variants land. It is the additive foundation of the enumeration/rendering re-encode: the whole
`UnaryType`/`IntervalType` model-enumeration layer, built on `Finset.univ` over the whole alphabet,
is re-encoded onto **per-formula finite atom sets**. Rabinovich never enumerates the whole alphabet:
every formula in the translation mentions only finitely many atoms (Prop 3.5, PDF p.5; Def 3.1,
p.4).

## The per-formula representation

- `UnaryTypeFin sig F M := {a // a ∈ M} → Bool` — a **partial** 1-type: a truth assignment to
  exactly the finite mentioned-atom set `M : Finset (AtomKind (sigE sig F) 1)`, NOT a total
  assignment to the whole (Option-A-infinite) alphabet. Its `Fintype` (used by the disjunctions
  below and by `completions`' filter) depends only on `M` being finite — never on any
  `Fintype (AtomKind (sigE sig F) 1)` / `Fintype (sigE sig F).preds` — so it survives the infinite
  E[Σ] of Def 4.1 (p.5).
- `partialHolds N c y` — a point `y` realizes `c`: atom-wise agreement over the mentioned atoms
  `M`. The per-formula-finite analog of `unaryHolds`.
- `IntervalTypeFin sig F M := Finset (UnaryTypeFin sig F M)` and `intervalHoldsFin N S y` —
  the per-formula-finite analogs of `IntervalType`/`intervalHolds`.

## The finite-alphabet `completions` bridge (deleted at the switchover, before the summand flip)

For `c : UnaryTypeFin sig F M`,
`completions c : Finset (UnaryType sig F) := Finset.univ.filter (fun τ => ∀ a ∈ M, τ a = c a)` —
the set of total 1-types whose restriction to `M` equals `c`. It exists precisely WHILE `sigE` is
finite (the flip-last device's payoff), and the bridge lemma
`intervalHolds N (completions c) y ↔ partialHolds N c y` lets each old total-type statement be
reproved as a consequence of its Fin-variant. Both the total types and this bridge are deleted at
the switchover; only then is `sigE` made infinite. NO correctness statement is weakened.

## Reference grounding: Rabinovich PDF page → repo construct

| Rabinovich (PDF) | Statement | This module |
|---|---|---|
| Def 3.1, p.4 | unary quantifier-free `αⱼ`/`βⱼ`; each mentions finitely many atoms | `UnaryTypeFin sig F M` |
| Def 3.1, p.4 | a point realizes a unary type (atom-wise agreement) | `partialHolds` / `charTypeFin` |
| Prop 3.5, p.5 | the type is a *finite* disjunction of the mentioned atoms | `IntervalTypeFin` / `intervalHoldsFin` |
| Def 4.1, p.5 | E[Σ] infinite ⇒ no whole-alphabet `Finset.univ` in the Fin layer | enumeration is over `{a // a ∈ M}`, never over `UnaryType` (that is confined to `completions`, deleted before the flip) |

## References
- Rabinovich, *A Proof of Kamp's Theorem* (2014), Def 3.1 (p.4), Prop 3.5 (p.5), Def 4.1 (p.5).
  Cited by PDF page; the companion markdown transcription is corrupt.
- `ExistsForallFormula.lean` (`UnaryType`, `unaryHolds`, `unaryHolds_iff`, `IntervalType`,
  `intervalHolds`); `NormalForm.lean` (`AtomKind`, `atom_eval`, `nf_characteristic`,
  `nf_characteristic_satisfies`); `InfAlphabetProbe.lean` (the Phase-1 gate, which imports this
  module and keeps only the gate equivalence).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. The per-formula-finite partial 1-type (promoted from the Phase-1 gate) -/

/-- A **partial** 1-type over the finite mentioned-atom set `M`: a truth assignment to exactly the
atoms in `M`. NOT a total assignment to the whole (Option-A-infinite) alphabet. Its `Fintype`
(needed for the disjunctions below and by `completions`) is `Fintype ({a // a ∈ M} → Bool)`, which
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

/-! ## 4. The finite-alphabet `completions` bridge (deleted at the switchover) -/

open Classical in
/-- The **completions** of a partial 1-type `c`: the finite set of total complete 1-types whose
restriction to `M` equals `c`. Ranges over `Finset.univ : Finset (UnaryType sig F)`, which exists
precisely WHILE `sigE` is finite — this bridge is deleted at the switchover, BEFORE the summand
flip makes `sigE` infinite. It is the device that lets every old total-type lemma be consumed while
the Fin-variant lands. -/
noncomputable def completions [Fintype sig.preds] [DecidableEq sig.preds]
    {M : Finset (AtomKind (sigE sig F) 1)}
    (c : UnaryTypeFin sig F M) : Finset (UnaryType sig F) :=
  Finset.univ.filter (fun τ : UnaryType sig F => ∀ a : {a : AtomKind (sigE sig F) 1 // a ∈ M}, τ a.1 = c a)

/-- **Membership in `completions`.** `τ` completes `c` iff it agrees with `c` on every mentioned
atom. -/
theorem mem_completions [Fintype sig.preds] [DecidableEq sig.preds]
    {M : Finset (AtomKind (sigE sig F) 1)}
    (c : UnaryTypeFin sig F M) (τ : UnaryType sig F) :
    τ ∈ completions c ↔ ∀ a : {a : AtomKind (sigE sig F) 1 // a ∈ M}, τ a.1 = c a := by
  classical
  simp only [completions, Finset.mem_filter, Finset.mem_univ, true_and]

/-- **The bridge lemma.** A point `y` satisfies the total interval type `completions c` iff it
realizes the partial type `c`. This connects the old total satisfaction relation `intervalHolds`
to the per-formula-finite `partialHolds`, so no correctness statement is weakened during the
migration: the forward direction restricts a realized completion to `M`; the reverse uses `y`'s
characteristic total type (`nf_characteristic`), whose restriction to `M` is exactly `c` under
`partialHolds`. -/
theorem intervalHolds_completions_iff [Fintype sig.preds] [DecidableEq sig.preds]
    (N : OrderedMonadicStructure (sigE sig F))
    {M : Finset (AtomKind (sigE sig F) 1)} (c : UnaryTypeFin sig F M) (y : N.carrier) :
    intervalHolds N (completions c) y ↔ partialHolds N c y := by
  classical
  constructor
  · rintro ⟨τ, hτmem, hτholds⟩
    have hmem : ∀ a : {a : AtomKind (sigE sig F) 1 // a ∈ M}, τ a.1 = c a :=
      (mem_completions c τ).mp hτmem
    intro a
    have hcoin := (unaryHolds_iff N τ y).mp hτholds a.1
    rw [hmem a] at hcoin
    exact hcoin
  · intro h
    refine ⟨nf_characteristic N 0 1 (fun _ => y), ?_, ?_⟩
    · rw [mem_completions]
      intro a
      have hpc := h a
      cases hca : c a with
      | false =>
        simp only [hca, Bool.false_eq_true, iff_false] at hpc
        simp only [nf_characteristic]
        exact decide_eq_false hpc
      | true =>
        simp only [hca, iff_true] at hpc
        simp only [nf_characteristic]
        exact decide_eq_true hpc
    · exact nf_characteristic_satisfies N 0 1 (fun _ => y)

end Bimodal.Metalogic.WeakCanonical.Kamp
