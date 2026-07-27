import FormalSystem.Metalogic.WeakCanonical.Kamp.Prop35Assembly
import FormalSystem.Metalogic.WeakCanonical.Kamp.PerFormulaType

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

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

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. The per-formula-finite partial 1-type

`UnaryTypeFin`/`partialHolds`/`charTypeFin`/`partialHolds_charTypeFin` are now the promoted
production definitions in `PerFormulaType.lean` (imported above); this gate consumes them directly
rather than duplicating them. -/

/-! ## 2. The `intervalHolds`-analog: a finite disjunction over the mentioned atoms -/

open Classical in
/-- The `intervalHolds`-analog for the per-formula-finite representation: a point `y` satisfies the
admissibility predicate `adm` iff some **admissible completion of the mentioned atoms** is realized
at `y`. The search `Finset.univ.filter adm` ranges over `Finset (UnaryTypeFin sig F M)` — functions
from the finite mentioned subtype `{a // a ∈ M}` to `Bool` — NOT over `Finset (UnaryType sig F)`.
Its `Fintype` needs only `M` finite plus classical decidability of the mentioned subtype — no
alphabet instance. This is the finite disjunction of Prop 3.5 (p.5) restricted to the atoms the
formula mentions. -/
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

end Bimodal.Metalogic.WeakCanonical.Kamp
