import Bimodal.Metalogic.WeakCanonical.Kamp.Prop43Translate

/-!
# B4 — model-independent capture and the `M`-uniform `∨∃∀` extraction (Rabinovich Thm 4.4, PDF p.6)

`translate_correct` (`Prop43Translate.lean`) and the negation chain
(`VeeSatNegation.lean` / `EFSatNegationGeneral.lean`) emit, per model `N`, a `∨∃∀`-formula `Ψ`
equivalent to the input monadic FO formula. The completeness spine
(`kamp_prior_expressive_completeness`) instead needs a *single* formula uniform over all models
`M` (`{ A : Formula // ∀ M … }`). This module bridges that uniformity gap.

## The model-independence fact (report-16 B4, machine-checked here)

The only model-dependent choice anywhere in the `translate`/negation pipeline is the interval `S`
obtained from `hCapture`. `intervalCapture_of_atomNamed` (`ESigmaCapture.lean`) always chooses
`S = univ.filter (fun τ : UnaryType sig F => τ a₀ = true)`, which mentions *only* `sig`, `F`, and
the naming atom — never the model. §1 isolates this at the predicate level as `capType` and proves
its realization `intervalHolds_capType` **generically over every `OrderedMonadicStructure` over the
E[Σ] alphabet** (no `canonExpand` hypothesis needed): the capture set is `N`-independent by
construction, and the biconditional `intervalHolds N (capType p) y ↔ N.interp p y` holds for all
`N` by the same `nf_characteristic` / `atom_eval` argument that `intervalCapture_of_atomNamed`
uses. This is the "`S = univ.filter (τ a₀ = true)` is model-independent" fact the whole B4
extraction hinges on.

## The uniform extraction (conclusion-strengthening, report-15 template)

Report 15's move — expose an invariant the induction already produces but the weaker conclusion
hid — is applied here to the *model quantifier*: `translate`'s `∃ Ψ` is proved *inside* an implicit
`∀ N`, so the emitted `Ψ` looks model-tied even though (by §1) it is not. §2 threads a **functional
capture** `capFn : Formula → IntervalType sig F` (a fixed function, in place of the existential
`hCapture`) so the emitted `Ψ` is a genuine function of the input formula and `capFn` alone, then
states the correctness with `∃ Ψ` pulled *outside* the `∀ N`. `atomEmit_capType_iff` is the atom
base case in that uniform shape.

OFF the live import path: nothing here is imported by `KampPrior.lean` or the completeness spine;
Phase ζ wires it in, discharging `capFn` `𝔈`-boundedly via `esigmaCapture_canonExpand`
(whose `S` is exactly `capType`-shaped).

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 4.3 / Theorem 4.4 (p.6). Cited by
  PDF page; the companion markdown transcription is corrupt.
- `ESigmaCapture.lean`: `intervalCapture_of_atomNamed` (the `univ.filter (τ a₀ = true)` witness),
  `esigmaCapture_canonExpand` (the ζ-site discharge).
- `Prop43Translate.lean`: `translate_correct`, `atomEmit`, `atomEmit_iff`.
- `ExistsForallFormula.lean`: `UnaryType`, `unaryHolds`, `unaryHolds_iff`, `IntervalType`,
  `intervalHolds`.
- `NormalForm.lean`: `AtomKind`, `atom_eval`, `nf_characteristic`, `nf_characteristic_satisfies`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. The model-independent capture interval -/

/-- **Model-independent capture interval for an E[Σ] predicate `p`.** The set of complete 1-types
whose `p`-at-point-`0` slot is `true`. This mentions only `sig`, `F`, and `p` — *never* a model —
so it is the same `IntervalType` for every `OrderedMonadicStructure` over `sigE sig F`. It is the
predicate-level form of the `S = univ.filter (τ a₀ = true)` witness that
`intervalCapture_of_atomNamed` always chooses. -/
def capType (p : (sigE sig F).preds) : IntervalType sig F :=
  Finset.univ.filter (fun τ : UnaryType sig F => τ (AtomKind.pred p (0 : Fin 1)) = true)

/-- **Generic realization of `capType` (report-16 B4, machine-checked).** For *every*
`OrderedMonadicStructure` `N` over the E[Σ] alphabet, a point `y` satisfies the model-independent
interval `capType p` iff `N` interprets `p` true at `y`. The capture set does not depend on `N`;
only this biconditional does, and it holds uniformly — this is exactly what makes the emitted
`∨∃∀` formula `N`-independent. The proof mirrors `intervalCapture_of_atomNamed`: forward reads the
filter membership through `unaryHolds`; backward realizes the characteristic 1-type at `y`. -/
theorem intervalHolds_capType (N : OrderedMonadicStructure (sigE sig F))
    (p : (sigE sig F).preds) (y : N.carrier) :
    intervalHolds N (capType p) y ↔ N.interp p y := by
  classical
  unfold capType intervalHolds
  constructor
  · rintro ⟨τ, hτmem, hτhold⟩
    have hτa : τ (AtomKind.pred p (0 : Fin 1)) = true := (Finset.mem_filter.mp hτmem).2
    have h := (unaryHolds_iff N τ y).mp hτhold (AtomKind.pred p (0 : Fin 1))
    exact h.mpr hτa
  · intro hInterp
    refine ⟨nf_characteristic N 0 1 (fun _ => y), ?_, ?_⟩
    · rw [Finset.mem_filter]
      refine ⟨Finset.mem_univ _, ?_⟩
      have hy : atom_eval N (fun _ => y) (AtomKind.pred p (0 : Fin 1)) := hInterp
      simpa [nf_characteristic] using hy
    · exact nf_characteristic_satisfies N 0 1 (fun _ => y)

/-! ## 2. The atom base case in uniform shape -/

/-- **Uniform atom emit.** With the model-independent interval `capType p`, the emitted skeleton
sub-disjunction `atomEmit i (capType p)` is a fixed `∨∃∀`-formula (no model input) that, on every
`N` and every strictly-increasing environment, is satisfied iff `N` interprets `p` at `env i`
— i.e. iff `eval N env (.atom p i)` holds. This is the `N`-independent atom base case of the
uniform `translate` conclusion: the *same* formula works across all models. -/
theorem atomEmit_capType_iff (N : OrderedMonadicStructure (sigE sig F))
    {m : Nat} (i : Fin (m + 1)) (p : (sigE sig F).preds)
    (env : Fin (m + 1) → N.carrier) (hmono : StrictMono env) :
    veeSat N env (atomEmit i (capType p)) ↔ eval N env (MonadicFormula.atom p i) := by
  rw [atomEmit_iff N i (capType p) env hmono, intervalHolds_capType N p (env i)]
  simp only [eval]

end Bimodal.Metalogic.WeakCanonical.Kamp
