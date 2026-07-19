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

/-! ## 3. The negation leaves, in uniform shape (functional capture)

The negation chain's only model-dependent choice is the interval `S` obtained from `hCapture` on
`(translateProp35 …).neg`. Threading a fixed functional capture `capFn` in place of the existential
`hCapture` exposes the emitted formula as `N`-independent: the same `∨∃∀`-formula
`(capFn …).toList.map pointEF1` (resp. `univSentence`) realizes the negation on *every* `N` for
which `capFn` realizes capture. These are the uniform (`∃Φ`-outside-`∀N`) forms of the two landed
low-arity negation objects `efSat_negation_diagonal` / `efSat_negation_existence`
(`EFSatNegationGeneral.lean`); the emitted formula is fixed before any `N` is introduced. -/

/-- **Uniform arity-1 negation object.** `∃Φ`-outside-`∀N` form of `efSat_negation_diagonal`: the
negation formula is `(capFn (translateProp35 atomMap h_surj ξ).neg).toList.map pointEF1`, a fixed
`∨∃∀`-formula (no model input) realizing `¬ efSat N env ξ` on every `N` for which `capFn` realizes
capture. `h_INF`/`h_SUP` are proof-irrelevant here (unused by the landed diagonal object), so the
uniform form drops them. -/
theorem efSat_negation_diagonal_uniform
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (capFn : Formula → IntervalType sig F)
    (ξ : ExistsForallFormula sig F 1) :
    ∃ Φ : VeeExistsForall sig F 1,
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ (A : Formula) (y : N.carrier),
            intervalHolds N (capFn A) y ↔ temporal_truth N atomMap y A) →
        ∀ env : Fin 1 → N.carrier, (veeSat N env Φ ↔ ¬ efSat N env ξ) := by
  classical
  refine ⟨(capFn (translateProp35 atomMap h_surj ξ).neg).toList.map (fun τ => pointEF1 τ), ?_⟩
  intro N hCapFn env
  set S := capFn (translateProp35 atomMap h_surj ξ).neg with hSdef
  have hS := hCapFn (translateProp35 atomMap h_surj ξ).neg
  have hveeLHS : veeSat N env (S.toList.map (fun τ => pointEF1 τ)) ↔
      intervalHolds N S (env 0) := by
    simp only [veeSat, List.mem_map, Finset.mem_toList, intervalHolds]
    constructor
    · rintro ⟨ψ, ⟨τ, hτ, rfl⟩, hsat⟩
      exact ⟨τ, hτ, (pointEF1_efSat N τ env).mp hsat⟩
    · rintro ⟨τ, hτ, hu⟩
      exact ⟨pointEF1 τ, ⟨τ, hτ, rfl⟩, (pointEF1_efSat N τ env).mpr hu⟩
  rw [hveeLHS, hS (env 0), temporal_truth_neg,
    translateProp35_correct N atomMap h_surj env ξ]

/-- **Uniform arity-0 negation object.** `∃Φ`-outside-`∀N` form of `efSat_negation_existence`: the
negation formula is `(capFn (translateProp35 atomMap h_surj (pinFirst ξ)).neg).toList.map
(univSentence · S)`, a fixed `∨∃∀`-formula realizing `¬ efSat N ![] ξ` on every `N` for which
`capFn` realizes capture and whose carrier is nonempty. `hne` is threaded per-`N` (mandatory:
report 13 H4 — the arity-0 negation is false on an empty carrier). -/
theorem efSat_negation_existence_uniform
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (capFn : Formula → IntervalType sig F)
    (ξ : ExistsForallFormula sig F 0) :
    ∃ Φ : VeeExistsForall sig F 0,
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ (A : Formula) (y : N.carrier),
            intervalHolds N (capFn A) y ↔ temporal_truth N atomMap y A) →
        Nonempty N.carrier →
        (veeSat N ![] Φ ↔ ¬ efSat N ![] ξ) := by
  classical
  refine ⟨(capFn (translateProp35 atomMap h_surj (pinFirst ξ)).neg).toList.map
            (fun τ => univSentence τ (capFn (translateProp35 atomMap h_surj (pinFirst ξ)).neg)), ?_⟩
  intro N hCapFn hne
  set S := capFn (translateProp35 atomMap h_surj (pinFirst ξ)).neg with hSdef
  have hS := hCapFn (translateProp35 atomMap h_surj (pinFirst ξ)).neg
  rw [← hSdef] at hS
  have hRHS : (¬ efSat N ![] ξ) ↔ (∀ z : N.carrier, intervalHolds N S z) := by
    rw [pinFirst_efSat N ξ, not_exists]
    apply forall_congr'
    intro z
    rw [translateProp35_correct N atomMap h_surj ![z] (pinFirst ξ), ← temporal_truth_neg,
      ← hS (![z] 0)]
    simp
  have hLHS : veeSat N ![] (S.toList.map (fun τ => univSentence τ S)) ↔
      (∀ z : N.carrier, intervalHolds N S z) := by
    rw [← order_point_forall_iff N hne (intervalHolds N S)]
    have step : veeSat N ![] (S.toList.map (fun τ => univSentence τ S)) ↔
        ∃ τ ∈ S, efSat N ![] (univSentence τ S) := by
      simp only [veeSat, List.mem_map, Finset.mem_toList]
      constructor
      · rintro ⟨ψ, ⟨τ, hτ, rfl⟩, hsat⟩; exact ⟨τ, hτ, hsat⟩
      · rintro ⟨τ, hτ, hsat⟩; exact ⟨univSentence τ S, ⟨τ, hτ, rfl⟩, hsat⟩
    rw [step]
    simp only [univSentence_efSat]
    constructor
    · rintro ⟨τ, hτ, x0, hτx0, hb, ha⟩
      exact ⟨x0, ⟨τ, hτ, hτx0⟩, hb, ha⟩
    · rintro ⟨x0, hx0, hb, ha⟩
      obtain ⟨τ, hτ, hτx0⟩ := hx0
      exact ⟨τ, hτ, x0, hτx0, hb, ha⟩
  rw [hLHS, hRHS]

end Bimodal.Metalogic.WeakCanonical.Kamp
