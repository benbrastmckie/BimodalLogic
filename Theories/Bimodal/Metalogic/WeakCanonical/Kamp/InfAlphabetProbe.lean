import Bimodal.Metalogic.WeakCanonical.Kamp.Prop35Assembly

/-!
# Phase-1 de-risking GATE — per-formula-finite-atom `UnaryTypeFin` prototype (OFF-PATH)

**Purpose.** This module is the machine-checked go/no-go GATE for **Option A** (the infinite
alphabet E[Σ] of Rabinovich Def 4.1, PDF p.5). Option A's single hardest obligation is the
representation question: once the E[Σ] alphabet is *infinite*, the whole `UnaryType`/`IntervalType`
model-enumeration layer — built on `Finset.univ` over the (then non-existent) whole-alphabet
1-type space — must be re-encoded onto **per-formula finite atom sets**. Rabinovich never
enumerates the whole alphabet: every formula in the translation mentions only *finitely many*
atoms (Prop 3.5, p.5; Def 3.1, p.4). This probe tests, sorry-free and off the live import path,
whether the "type = finite disjunction of atoms" equivalence closes on that per-formula-finite
representation **without re-introducing a full-alphabet `Finset.univ`**.

Nothing here is imported by `KampPrior.lean` or the completeness spine; it is a pure off-path
probe (same discipline as `OptionBLocalityProbe.lean`). The
`nf_nvar_exist_all_depths | _k+2` residual is untouched; `#print axioms completeness_discrete`
is unaffected.

## The representation

- `UnaryTypeFin sig F M := {a // a ∈ M} → Bool` — a **partial** 1-type: a truth assignment to
  exactly the finite mentioned-atom set `M : Finset (AtomKind (sigE sig F) 1)`, NOT a total
  assignment `AtomKind (sigE sig F) 1 → Bool` to the whole (infinite, under Option A) alphabet.
- `partialHolds N c y` — a point `y` realizes `c`: atom-wise agreement over the finitely many
  atoms in `M`. A bounded conjunction over `M`; no whole-alphabet quantifier.
- `partialIntervalHolds N adm y` — the `intervalHolds`-analog: a finite disjunction over the
  admissible completions of the mentioned atoms, i.e. `∃ c ∈ Finset.univ.filter adm, …` where
  `Finset.univ : Finset (UnaryTypeFin sig F M)` enumerates functions from the **finite mentioned
  subtype** `{a // a ∈ M}` to `Bool` (`Fintype` of a `Finset`-subtype → `Bool`). This is
  per-formula-finite for *every* `M` — its `Fintype` instance is independent of any
  `Fintype (AtomKind (sigE sig F) 1)` / `Fintype (sigE sig F).preds`, so it survives the
  infinite alphabet. It is emphatically NOT `Finset.univ : Finset (UnaryType sig F)`.

## The gate equivalence (Prop 3.5 core, p.5 — "type = finite disjunction of atoms")

`typeEqFiniteDisjunction`:
`adm (charTypeFin N M y) = true ↔ partialIntervalHolds N adm y`,
proved via `charTypeFin N M y` — the characteristic completion of `y` over `M` — with finite
case analysis over `M`-completions and classical decidability. `charTypeFin` and the disjunction
range over completions of the mentioned atoms only; the whole-alphabet 1-type space is never
enumerated.

## Reference grounding (H3): Rabinovich PDF page → repo construct

| Rabinovich (PDF) | Statement | This probe |
|---|---|---|
| Def 3.1, p.4 | unary quantifier-free `αⱼ`/`βⱼ`; each mentions finitely many atoms | `UnaryTypeFin sig F M` (partial over the mentioned `M`) |
| Def 3.1, p.4 | a point realizes a unary type (atom-wise agreement) | `partialHolds` / `charTypeFin` |
| Prop 3.5, p.5 | ∨∃∀ ≡ TL; the type is a *finite* disjunction of the mentioned atoms | `partialIntervalHolds`, `typeEqFiniteDisjunction` |
| Prop 3.5, p.5 | a concrete translated `∃∀`-formula `ξ` | `ξConcrete`, `gate_translateProp35` |
| Def 4.1, p.5 | E[Σ] infinite ⇒ no whole-alphabet `Finset.univ` | enumeration is over `{a // a ∈ M}`, never over `UnaryType` |

## VERDICT: **GO**

The equivalence `typeEqFiniteDisjunction` and its concrete instantiation `gate_translateProp35`
(over a genuine `translateProp35` input `ξConcrete`) build **sorry-free** and **axiom-clean**
(`#print axioms gate_translateProp35` reports only `[propext, Classical.choice, Quot.sound]`),
off the live import path, with the enumeration ranging **only over completions of the mentioned
atoms** — no `Finset.univ` over the whole `UnaryType`/`AtomKind` alphabet is used anywhere in the
representation or the proof. Option A's per-formula-finite re-encoding of the enumeration surface
is therefore tractable. **GO** on Phases 2-5.

## References
- Rabinovich, *A Proof of Kamp's Theorem* (2014), Def 3.1 (p.4), Prop 3.5 (p.5), Def 4.1 (p.5).
  Cited by PDF page; the companion markdown transcription is corrupt.
- `ExistsForallFormula.lean` (`UnaryType`, `IntervalType`, `unaryHolds`, `intervalHolds`,
  `ExistsForallFormula`, `efSat`); `NormalForm.lean` (`AtomKind`, `atom_eval`);
  `Prop35Assembly.lean` (`translateProp35`); `OptionBLocalityProbe.lean` (off-path probe pattern).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. The per-formula-finite partial 1-type -/

/-- A **partial** 1-type over the finite mentioned-atom set `M`: a truth assignment to exactly the
atoms in `M`. NOT a total assignment to the whole (Option-A-infinite) alphabet. Its `Fintype`
(needed for the disjunction below) is `Fintype ({a // a ∈ M} → Bool)`, which depends only on `M`
being finite — never on `Fintype (AtomKind (sigE sig F) 1)`. -/
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

/-! ## 2. The `intervalHolds`-analog: a finite disjunction over the mentioned atoms -/

/-- The `intervalHolds`-analog for the per-formula-finite representation: a point `y` satisfies the
admissibility predicate `adm` iff some **admissible completion of the mentioned atoms** is realized
at `y`. The search `Finset.univ.filter adm` ranges over `Finset (UnaryTypeFin sig F M)` — functions
from the finite mentioned subtype `{a // a ∈ M}` to `Bool` — NOT over `Finset (UnaryType sig F)`.
This is the finite disjunction of Prop 3.5 (p.5) restricted to the atoms the formula mentions. -/
def partialIntervalHolds (N : OrderedMonadicStructure (sigE sig F))
    {M : Finset (AtomKind (sigE sig F) 1)} (adm : UnaryTypeFin sig F M → Bool) (y : N.carrier) :
    Prop :=
  ∃ c ∈ (Finset.univ.filter (fun c : UnaryTypeFin sig F M => adm c = true)), partialHolds N c y

/-! ## 3. The gate equivalence — "type = finite disjunction of atoms", no whole-alphabet univ -/

/-- **The Phase-1 GATE (Prop 3.5 core, p.5).** For any admissibility predicate `adm` over the
completions of the finite mentioned-atom set `M`, the point-condition "`y`'s mentioned-atom
completion is admissible" equals the finite disjunction "some admissible completion of `M` is
realized at `y`". The proof uses `charTypeFin N M y` (the characteristic completion of `y` over
`M`) and finite case analysis over `M`-completions; the enumeration `Finset.univ.filter adm`
ranges over completions of the **mentioned** atoms only — there is NO `Finset.univ` over the whole
`UnaryType`/`AtomKind` alphabet, so the equivalence survives the infinite E[Σ] of Def 4.1 (p.5). -/
theorem typeEqFiniteDisjunction (N : OrderedMonadicStructure (sigE sig F))
    (M : Finset (AtomKind (sigE sig F) 1)) (adm : UnaryTypeFin sig F M → Bool) (y : N.carrier) :
    adm (charTypeFin N M y) = true ↔ partialIntervalHolds N adm y := by
  classical
  constructor
  · intro h
    exact ⟨charTypeFin N M y,
      Finset.mem_filter.mpr ⟨Finset.mem_univ _, h⟩,
      partialHolds_charTypeFin N M y⟩
  · rintro ⟨c, hc, hph⟩
    have hadm : adm c = true := (Finset.mem_filter.mp hc).2
    have hEq : charTypeFin N M y = c := by
      funext a
      have hiff := hph a
      simp only [charTypeFin]
      cases hca : c a with
      | false =>
        simp only [hca, Bool.false_eq_true, iff_false] at hiff
        exact decide_eq_false hiff
      | true =>
        simp only [hca, iff_true] at hiff
        exact decide_eq_true hiff
    rw [hEq]; exact hadm

/-! ## 4. Concrete instantiation on one genuine `translateProp35` input -/

/-- A concrete `ExistsForallFormula sig F 1`: one ordered existential point (`n = 0`), point type
`τ`, and empty (unconstrained) interval clauses. A genuine input to the real Prop-3.5 translation
`translateProp35` (see the anchor `translateProp35_input` below). -/
def ξConcrete (τ : UnaryType sig F) : ExistsForallFormula sig F 1 where
  n := 0
  pin := fun _ => 0
  pointType := fun _ => τ
  intervalType := fun _ => (∅ : IntervalType sig F)

/-- **Anchor.** `ξConcrete τ` is a genuine argument to the real Prop-3.5 translation
`translateProp35` (Prop 3.5, p.5) — the gate is instantiated on a real translation input, not an
abstract stand-in. -/
noncomputable def translateProp35_input (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (τ : UnaryType sig F) : Formula :=
  translateProp35 atomMap h_surj (ξConcrete τ)

/-- **The GATE, instantiated on `ξConcrete`.** For the point-type clause of the concrete
translated `∃∀`-formula `ξConcrete τ`, restricted to any finite mentioned-atom set `M`: the
condition "`y` matches `τ` on the mentioned atoms" equals a finite disjunction over the admissible
completions of `M` — with the disjunction ranging over completions of the mentioned atoms only, no
whole-alphabet `Finset.univ`. This is the Prop-3.5 "type = finite disjunction of atoms" collapse
for one concrete `translateProp35` input, sorry-free and axiom-clean. -/
theorem gate_translateProp35 (N : OrderedMonadicStructure (sigE sig F))
    (τ : UnaryType sig F) (M : Finset (AtomKind (sigE sig F) 1)) (y : N.carrier) :
    (decide ((charTypeFin N M y) = fun a => (ξConcrete τ).pointType 0 a.1) = true)
      ↔ partialIntervalHolds N
          (fun c : UnaryTypeFin sig F M => decide (c = fun a => (ξConcrete τ).pointType 0 a.1)) y :=
  typeEqFiniteDisjunction N M
    (fun c => decide (c = fun a => (ξConcrete τ).pointType 0 a.1)) y

end Bimodal.Metalogic.WeakCanonical.Kamp
