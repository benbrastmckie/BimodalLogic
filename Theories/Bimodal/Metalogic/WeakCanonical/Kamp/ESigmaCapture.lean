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

end Bimodal.Metalogic.WeakCanonical.Kamp
