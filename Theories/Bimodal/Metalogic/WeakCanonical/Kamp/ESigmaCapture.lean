import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF

/-!
# E[Σ] Output-Alphabet Capture / Closure (discharges `hCapture` at the ζ `canonExpand`)

This module supplies the **prerequisite** capture/closure lemma that discharges the threaded
`hCapture` hypothesis of the β/γ/δ negation stack at the concrete canonical expansion used by the
final spine rewire (Rabinovich, *A Proof of Kamp's Theorem*, 2014, Definition 4.1, PDF p.5, and the
p.6 collapse-to-atom note). It is the **literal reverse** of the forward atomic-layer lemma
`unaryToFormula_correct` (`Prop35ExistsForall.lean`), lifted from a single `UnaryType` to an
`IntervalType` (a `Finset UnaryType`, i.e. a *union* of complete-type cells).

## The threaded hypothesis this discharges

The negation engine (see `EFSatNegation.lean`) carries, as an explicit hypothesis on a structure
`N` over the E[Σ] alphabet `sigE sig F`:

```
hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
    ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A
```

It is *threaded* through Phases β/γ/δ and never discharged there; the discharge lives here and is
consumed at the ζ rewire.

## Shape (P-a: output-alphabet closure)

Rabinovich's E[Σ] alphabet `F` is **closed by construction** — it *is* the set of `TL` formulas
processed at the stage, so every engine-output formula is already a named unary predicate and the
collapse is definitional (Def 4.1, p.5; p.6 collapse note). The Lean `F : Finset Formula` is an
opaque parameter, so we make that closure explicit as the membership witness `A ∈ F`: once a formula
`A` is a member of `F`, the fresh atom `esigmaPred A` names it, and `atom_eval_new`
(`ESigmaExpansion.lean`) reads it back exactly as `sat A`.

- `intervalCapture_of_atomNamed`: the **core reverse-capture lemma**. Given the atom-naming
  biconditional (`hName`, the finite `hCanon` form of Def 4.1) for a single `A ∈ F`, the truth set
  `{ y | temporal_truth N atomMap y A }` equals `intervalHolds N S` for the `IntervalType`
  `S := { τ | τ names A as true }`. Reverse of `unaryToFormula_correct` at the interval level.
- `intervalCapture_forall_mem`: packages the core lemma over a finite engine-output set `𝔈 ⊆ F`,
  yielding the `𝔈`-bounded capture (the form ζ discharges).
- `canonExpand_atom_named`: on the concrete `canonExpand`, the atom-naming biconditional holds by
  `atom_eval_new` whenever `sat` interprets the fresh atom as the temporal truth carried by `N`
  (the ζ-site choice `sat A := temporal_truth N atomMap · A`).
- `esigmaCapture_canonExpand`: the assembled discharge on the `canonExpand` over `𝔈 ⊆ F`.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Definition 4.1 (p.5), collapse-to-atom note
  (p.6). Cited by PDF page; the companion markdown transcription is corrupt.
- `ESigmaExpansion.lean`: `sigE`, `esigmaPred`, `canonExpand`, `atom_eval_new`.
- `ExistsForallFormula.lean`: `UnaryType`, `unaryHolds`, `IntervalType`, `intervalHolds`.
- `Prop35ExistsForall.lean`: the FORWARD `unaryToFormula_correct` this reverses.
- `NormalForm.lean`: `nf_characteristic`, `nf_characteristic_satisfies`, `atom_eval`, `AtomKind`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula)
open Bimodal.Metalogic.WeakCanonical

/-! ## 1. The core reverse-capture lemma (reverse of `unaryToFormula_correct`, interval level) -/

/--
**Interval-level reverse capture.** For a formula `A ∈ F` that is *named* by its fresh E[Σ] atom
`esigmaPred A hA` (the atom-naming biconditional `hName`, the finite `hCanon` form of Def 4.1, p.5),
the truth set of `A` in `N` is captured by the `IntervalType`

```
S := { τ : UnaryType sig F | τ (esigmaPred A) = true }
```

i.e. `intervalHolds N S y ↔ temporal_truth N atomMap y A` for every point `y`. This is the literal
reverse of `unaryToFormula_correct` (`UnaryType → Formula`, forward) lifted to a *set* of complete
1-types — a `TL` truth set is a union of complete-type cells, exactly what `intervalHolds`
(`∃ τ ∈ S, unaryHolds N τ y`) expresses (report: interval-level, not single-`UnaryType`).

The atom-naming premise is discharged on the concrete `canonExpand` by `atom_eval_new`
(`canonExpand_atom_named` below); here it is a hypothesis, never a `sorry`.
-/
theorem intervalCapture_of_atomNamed {sig : MonadicSignature} {F : Finset Formula}
    [Fintype sig.preds] [DecidableEq sig.preds]
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (A : Formula) (hA : A ∈ F)
    (hName : ∀ y : N.carrier,
        N.interp (esigmaPred A hA) y ↔ temporal_truth N atomMap y A) :
    ∃ S : IntervalType sig F, ∀ y : N.carrier,
        intervalHolds N S y ↔ temporal_truth N atomMap y A := by
  classical
  -- The naming atom: the fresh E[Σ] predicate for `A`, evaluated at the single point `Fin 1`.
  set a₀ : AtomKind (sigE sig F) 1 := AtomKind.pred (esigmaPred A hA) (0 : Fin 1) with ha₀
  refine ⟨Finset.univ.filter (fun τ : UnaryType sig F => τ a₀ = true), ?_⟩
  intro y
  -- It suffices to match `intervalHolds` with the atom's value, then apply `hName`.
  have hkey : intervalHolds N (Finset.univ.filter (fun τ : UnaryType sig F => τ a₀ = true)) y
      ↔ N.interp (esigmaPred A hA) y := by
    constructor
    · rintro ⟨τ, hτmem, hτhold⟩
      -- `hτhold : unaryHolds N τ y`, i.e. atom-wise agreement with `τ`.
      have hτa : τ a₀ = true := (Finset.mem_filter.mp hτmem).2
      have := (hτhold a₀).mpr hτa
      -- `atom_eval N (fun _ => y) a₀` is defeq `N.interp (esigmaPred A hA) y`.
      simpa [ha₀, atom_eval] using this
    · intro hInterp
      -- Take the complete type realized at `y`.
      refine ⟨nf_characteristic N 0 1 (fun _ => y), ?_, ?_⟩
      · -- It names `A` as true because `atom_eval` at `a₀` holds.
        rw [Finset.mem_filter]
        refine ⟨Finset.mem_univ _, ?_⟩
        have : atom_eval N (fun _ => y) a₀ := by simpa [ha₀, atom_eval] using hInterp
        simpa [nf_characteristic] using this
      · -- It is realized at `y` by `nf_characteristic_satisfies`.
        exact nf_characteristic_satisfies N 0 1 (fun _ => y)
  exact hkey.trans (hName y)

/-! ## 2. Packaging over the finite engine-output set `𝔈 ⊆ F` -/

/--
**`𝔈`-bounded capture.** Given the atom-naming biconditional for every member of a finite
engine-output set `𝔈 ⊆ F`, every `A ∈ 𝔈` is captured by some `IntervalType`. This is the
`𝔈`-bounded form the ζ rewire discharges (the `∀ A` threaded form specializes to `𝔈` at each
engine application; see report Q1/Q5). Bounds the obligation to `𝔈`, not all formulas.
-/
theorem intervalCapture_forall_mem {sig : MonadicSignature} {F : Finset Formula}
    [Fintype sig.preds] [DecidableEq sig.preds]
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (𝔈 : Finset Formula) (h𝔈 : 𝔈 ⊆ F)
    (hName : ∀ (A : Formula) (hA : A ∈ F), A ∈ 𝔈 →
        ∀ y : N.carrier,
          N.interp (esigmaPred A hA) y ↔ temporal_truth N atomMap y A) :
    ∀ A ∈ 𝔈, ∃ S : IntervalType sig F, ∀ y : N.carrier,
        intervalHolds N S y ↔ temporal_truth N atomMap y A := by
  intro A hA𝔈
  exact intervalCapture_of_atomNamed N atomMap A (h𝔈 hA𝔈) (hName A (h𝔈 hA𝔈) hA𝔈)

/-! ## 3. Discharging the atom-naming premise on the concrete `canonExpand`

The atom-naming premise `hName` of `intervalCapture_of_atomNamed` is not an axiom: on the concrete
canonical expansion built with the fresh atoms interpreted as the temporal truth carried by `M`
(the ζ-site choice `sat A := temporal_truth M g · A`), it holds by `atom_eval_new` composed with a
**conservativity** fact — `temporal_truth` is preserved from `M` to its expansion, because the
object-language `atomMap` factors through the *old* predicates (`oldPred`) and the carrier + order
are inherited verbatim. This is the faithful "E[Σ] is closed at the stage" content of Def 4.1 (p.5):
the fresh atom reads back exactly as the truth of the formula it names. -/

/--
**Conservativity of `temporal_truth` under `canonExpand`.** When the object-language atom map
factors through the old predicates (`atomMap φ = oldPred (g φ)`), evaluating a `TL` formula in the
canonical expansion `canonExpand sig F M sat` agrees with evaluating it in `M` under `g`. The fresh
E[Σ] atoms never participate, and the carrier and linear order are inherited verbatim, so the
`Until`/`Since` quantifiers range over the identical ordered carrier. Proved by induction on the
formula.
-/
theorem temporal_truth_canonExpand {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ)) (A : Formula) (y : M.carrier) :
    temporal_truth (canonExpand sig F M sat) atomMap y A ↔ temporal_truth M g y A := by
  induction A generalizing y with
  | atom a => simp only [temporal_truth, hMap, oldPred, canonExpand]
  | bot => simp only [temporal_truth]
  | imp φ ψ ihφ ihψ => simp only [temporal_truth, ihφ, ihψ]
  | box φ _ => simp only [temporal_truth, hMap, oldPred, canonExpand]
  | untl φ ψ ihφ ihψ =>
    simp only [temporal_truth]
    constructor
    · rintro ⟨s, hs, hsφ, hr⟩
      exact ⟨s, hs, (ihφ s).mp hsφ, fun r h1 h2 => (ihψ r).mp (hr r h1 h2)⟩
    · rintro ⟨s, hs, hsφ, hr⟩
      exact ⟨s, hs, (ihφ s).mpr hsφ, fun r h1 h2 => (ihψ r).mpr (hr r h1 h2)⟩
  | snce φ ψ ihφ ihψ =>
    simp only [temporal_truth]
    constructor
    · rintro ⟨s, hs, hsφ, hr⟩
      exact ⟨s, hs, (ihφ s).mp hsφ, fun r h1 h2 => (ihψ r).mp (hr r h1 h2)⟩
    · rintro ⟨s, hs, hsφ, hr⟩
      exact ⟨s, hs, (ihφ s).mpr hsφ, fun r h1 h2 => (ihψ r).mpr (hr r h1 h2)⟩

/--
**Atom-naming on the concrete `canonExpand` (the finite `hCanon`, Def 4.1 p.5 / p.6 collapse).**
Build the canonical expansion with the fresh atoms interpreted as `M`'s temporal truth,
`sat B := temporal_truth M g · B`. Then for any `A ∈ F`, the fresh atom `esigmaPred A` reads back
exactly as `temporal_truth N atomMap · A` — the atom-naming premise consumed by
`intervalCapture_of_atomNamed`. The left side collapses to `sat A y = temporal_truth M g y A` by
`atom_eval_new`; the right side agrees with it by `temporal_truth_canonExpand`.
-/
theorem canonExpand_atom_named {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ)) (A : Formula) (hA : A ∈ F) (y : M.carrier) :
    (canonExpand sig F M (fun B x => temporal_truth M g x B)).interp (esigmaPred A hA) y
      ↔ temporal_truth (canonExpand sig F M (fun B x => temporal_truth M g x B)) atomMap y A := by
  -- LHS is `sat A y = temporal_truth M g y A` definitionally (canonExpand on a fresh atom).
  show temporal_truth M g y A
      ↔ temporal_truth (canonExpand sig F M (fun B x => temporal_truth M g x B)) atomMap y A
  exact (temporal_truth_canonExpand M (fun B x => temporal_truth M g x B) atomMap g hMap A y).symm

/--
**Assembled `𝔈`-bounded capture discharge on the `canonExpand`.** Combining `canonExpand_atom_named`
(the finite `hCanon`) with `intervalCapture_forall_mem` (the reverse capture) yields, on the concrete
canonical expansion, the `𝔈`-bounded `hCapture`: every engine-output formula `A ∈ 𝔈 ⊆ F` has its
truth set captured by an `IntervalType`. This is the discharge the ζ rewire consumes for the finite
engine-output set `𝔈` (Def 4.1, p.5). The obligation is bounded to `𝔈`; the full `∀ A : Formula`
threaded form is discharged only on `𝔈`, since a `TL` formula with genuine temporal reach outside
`F` is not a union of complete-1-type cells (report R1) — Phase 13 threads the `𝔈`-bounded form.
-/
theorem esigmaCapture_canonExpand {sig : MonadicSignature} {F : Finset Formula}
    [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ))
    (𝔈 : Finset Formula) (h𝔈 : 𝔈 ⊆ F) :
    ∀ A ∈ 𝔈, ∃ S : IntervalType sig F,
        ∀ y : (canonExpand sig F M (fun B x => temporal_truth M g x B)).carrier,
          intervalHolds (canonExpand sig F M (fun B x => temporal_truth M g x B)) S y
            ↔ temporal_truth (canonExpand sig F M (fun B x => temporal_truth M g x B)) atomMap y A := by
  refine intervalCapture_forall_mem
    (canonExpand sig F M (fun B x => temporal_truth M g x B)) atomMap 𝔈 h𝔈 ?_
  intro A hA _ y
  exact canonExpand_atom_named M atomMap g hMap A hA y

end Bimodal.Metalogic.WeakCanonical.Kamp
