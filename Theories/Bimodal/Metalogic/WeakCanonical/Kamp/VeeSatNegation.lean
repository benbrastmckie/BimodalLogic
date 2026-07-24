import Bimodal.Metalogic.WeakCanonical.Kamp.EFSatNegationGeneral
import Bimodal.Metalogic.WeakCanonical.Kamp.VeeConj

/-!
# γ — Negation closure of ∨∃∀-formulas (Rabinovich Prop 4.3 ¬-case, PDF p.6)

The **negation** half of Proposition 4.3's disjunction sub-case: the negation of a `∨∃∀`-formula
is again a `∨∃∀`-formula. Faithful to Prop 4.3's disjunction-negation reading (p.6):
`¬ veeSat (⋁ᵢ φᵢ) = ⋀ᵢ ¬φᵢ`, each `¬φᵢ` re-expressed as a `∨∃∀` by the landed β
(`efSat_negation_general`, `EFSatNegationGeneral.lean`), the conjunction reassembled by the landed
`veeConj_iff` (`VeeConj.lean`, Rabinovich Lemma 3.4 ∧-part).

## Structure

`veeSat_negation` is proved by induction on the disjunct list `Φ`:

- **`nil`** (`Φ = []`): `¬ veeSat N env [] = True`, so `Φ'` must be a **tautological** `∨∃∀`.
  It is built as `Gd ++ [d]` for an arbitrary `d : ExistsForallFormula sig F r`, where `Gd` is
  the β-negation of `d`: `veeSat (Gd ++ [d]) ↔ (¬ efSat d) ∨ efSat d ↔ True` (excluded middle).
  This reuses β rather than constructing a bespoke top, so the empty case needs no `Fintype`
  disjunction over point-type assignments.
- **`cons ψ rest`**: `¬ veeSat (ψ :: rest) = (¬ efSat ψ) ∧ (¬ veeSat rest)`; apply β to `ψ`
  (`veeSat Gψ`) and the induction hypothesis to `rest` (`veeSat Φrest`), then reassemble the
  conjunction as `veeConj Gψ Φrest` via `veeConj_iff`.

## Threaded hypotheses (never discharged — CONDITIONAL orphan until ζ)

`veeSat_negation` carries the same `N / atomMap / h_surj / h_INF / h_SUP / hCapture / hne`
hypotheses β threads. `hCapture` (interval-level capture) and `hne : Nonempty N.carrier` are
**threaded, never discharged** — their discharge is the Phase-ζ concern (the E[Σ] output-alphabet
capture/closure of `ESigmaCapture.lean`, applied against a closed-`F` `canonExpand`). This module
stays OFF the live import path.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 4.3 (p.6), Lemma 3.4 (p.5). Cited by
  PDF page; the companion markdown transcription is corrupt.
- `EFSatNegationGeneral.lean`: `efSat_negation_general` (β at the `∨∃∀` type).
- `VeeConj.lean`: `veeConj`, `veeConj_iff` (Lemma 3.4, ∧-part).
- `VeeExistsForall.lean`: `VeeExistsForall`, `veeSat`, `veeSat_append`, `veeSat_nil`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}

/-! ## 1. `veeSat` through a `cons` -/

/-- **`veeSat` through a `cons`.** A `∨∃∀`-formula `ψ :: Ψ` is satisfied iff its head `∃∀`-formula
is satisfied or its tail `∨∃∀`-formula is. The list-bookkeeping lever for the induction on the
disjunct list in `veeSat_negation`. -/
theorem veeSat_cons (N : OrderedMonadicStructure (sigE sig F)) {r : Nat}
    (env : Fin r → N.carrier) (ψ : ExistsForallFormula sig F r) (Ψ : VeeExistsForall sig F r) :
    veeSat N env (ψ :: Ψ) ↔ efSat N env ψ ∨ veeSat N env Ψ := by
  simp only [veeSat, List.mem_cons]
  constructor
  · rintro ⟨φ, (rfl | hmem), hsat⟩
    · exact Or.inl hsat
    · exact Or.inr ⟨φ, hmem, hsat⟩
  · rintro (h | ⟨φ, hmem, hsat⟩)
    · exact ⟨ψ, Or.inl rfl, h⟩
    · exact ⟨φ, Or.inr hmem, hsat⟩

/-! ## 2. An arbitrary inhabitant of `ExistsForallFormula` -/

/-- An arbitrary `∃∀`-formula, used only as a witness in the `nil` case of `veeSat_negation`
(its semantics are never inspected — only excluded middle on `efSat N env efArb` is used). It has
`r+1` ordered existential points with the everywhere-false point type and trivial (`intervalTop`)
caps, and the **identity-style strictly monotone pin** `Fin.castSucc` (`z_k` pinned to point `k`),
so the monotone-pin invariant of `translate_correct` holds for this nil-case witness too (T2:
`efArb_pin_strictMono`). Its semantics are never inspected, so any inhabitant with a `StrictMono`
pin is a drop-in; the earlier `n := 0`, `pin := fun _ => 0` inhabitant had a non-monotone pin at
arity `r ≥ 2`. `UnaryType sig F = NormalForm (sigE sig F) 0 1`, so `fun _ => false` is a concrete
inhabitant of the point type. -/
def efArb (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (F : Finset Formula) (r : Nat) :
    ExistsForallFormula sig F r where
  n := r
  pin := Fin.castSucc
  pointType := fun _ => (fun _ => false : NormalForm (sigE sig F) 0 1)
  intervalType := fun _ => intervalTop sig F

/-- The nil-case witness `efArb` has a strictly monotone pin (`Fin.castSucc`). This is the T2 swap
that makes the pin-monotonicity invariant of `veeSat_negation`/`translate_correct` exception-free. -/
theorem efArb_pin_strictMono (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (F : Finset Formula) (r : Nat) :
    StrictMono (efArb sig F r).pin := by
  intro a b hab
  exact Fin.castSucc_lt_castSucc_iff.mpr hab

/-! ## 3. Negation closure (Prop 4.3 ¬-case, ∨∃∀ part) -/

/-- **Negation closure of `∨∃∀`-formulas (Rabinovich Prop 4.3 ¬-case, p.6).** The negation of a
`∨∃∀`-formula `Φ` is again a `∨∃∀`-formula `Φ'`, uniformly in the (strictly monotone) environment.
Faithful to `¬ (⋁ᵢ φᵢ) = ⋀ᵢ ¬φᵢ`: each `¬φᵢ` is the β-negation `efSat_negation_general`, and the
conjunction is reassembled by `veeConj_iff`. Threads `hCapture` and `hne` exactly as β exposes
them; both are **threaded, never discharged** (CONDITIONAL orphan gated on `hCapture` until ζ). -/
theorem veeSat_negation
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
        ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (hne : Nonempty N.carrier)
    {r : Nat} (Φ : VeeExistsForall sig F r) :
    ∃ Φ' : VeeExistsForall sig F r, (∀ ψ ∈ Φ', StrictMono ψ.pin) ∧
      ∀ env : Fin r → N.carrier, StrictMono env →
      (¬ veeSat N env Φ ↔ veeSat N env Φ') := by
  classical
  induction Φ with
  | nil =>
    -- `¬ veeSat [] = True`; the tautological `Φ'` is `Gd ++ [d]` (β-negation of `d`, then `d`).
    obtain ⟨Gd, hGdmono, hGd⟩ :=
      efSat_negation_general N atomMap h_surj h_INF h_SUP hCapture hne (efArb sig F r)
    refine ⟨Gd ++ [efArb sig F r], ?_, fun env hmono => ?_⟩
    · -- Pin-mono: `Gd` disjuncts from β (`hGdmono`); `efArb` from the T2 swap.
      intro φ hφ
      rw [List.mem_append] at hφ
      rcases hφ with hφ | hφ
      · exact hGdmono φ hφ
      · rw [List.mem_singleton] at hφ
        subst hφ
        exact efArb_pin_strictMono sig F r
    · constructor
      · intro _
        rw [veeSat_append]
        by_cases hd : efSat N env (efArb sig F r)
        · exact Or.inr ⟨efArb sig F r, by simp, hd⟩
        · exact Or.inl ((hGd env hmono).mp hd)
      · intro _
        exact veeSat_nil N env
  | cons ψ rest ih =>
    -- `¬ veeSat (ψ :: rest) = (¬ efSat ψ) ∧ (¬ veeSat rest)`; β on `ψ`, IH on `rest`, reassemble.
    obtain ⟨Gψ, hGψmono, hGψ⟩ :=
      efSat_negation_general N atomMap h_surj h_INF h_SUP hCapture hne ψ
    obtain ⟨Φrest, hrestmono, hrest⟩ := ih
    refine ⟨veeConj Gψ Φrest, ?_, fun env hmono => ?_⟩
    · -- Pin-mono: `veeConj Gψ Φrest` pins are `m.e₁ ∘ (Gψ-pin)`, monotone since `Gψ` pins are.
      exact fun χ hχ => veeConj_pin_strictMono Gψ Φrest hGψmono χ hχ
    · rw [veeSat_cons, not_or, hGψ env hmono, hrest env hmono,
        veeConj_iff N env Gψ Φrest]

end Bimodal.Metalogic.WeakCanonical.Kamp
