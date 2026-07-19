import Bimodal.Metalogic.WeakCanonical.Kamp.LiftPair
import Bimodal.Metalogic.WeakCanonical.Kamp.VeeSatNegation

/-!
# δ — structural Proposition 4.3 `translate` (monadic FO → ∨∃∀, PDF p.6)

Rabinovich Proposition 4.3 (p.6): every monadic first-order formula over the E[Σ] alphabet is,
on strictly-increasing environments, equivalent to a `∨∃∀`-formula. This module proves the
correctness statement by **structural induction over the formula**, reusing the landed connective
machinery of the earlier phases:

- **atom** `P(z_i)`: emit, via `hCapture`, the interval `S = {τ | τ ⊨ P}` at the pinned free
  variable `i`, realized as the sub-disjunction of the universally-satisfiable skeleton `skelR`
  keeping exactly the point-type assignments whose `i`-th type lies in `S` (`atomEmit`). This is
  the base case that is **impossible on complete types** and only works because `IntervalType` is a
  *partial* (admissible-completion) set (report 09 §5, "this is where (A) pays off").
- **lt** `z_i < z_j`: index-decided under `StrictMono` (`StrictMono.lt_iff_lt`): emit the
  tautological skeleton `skelR` when `i < j`, and the empty disjunction `[]` when `j ≤ i`.
- **and**: the landed `veeConj_iff` (Phase 9, `VeeConj.lean`).
- **not**: the landed `veeSat_negation` (Phase 11, `VeeSatNegation.lean`), threading `hCapture` /
  `hne` uniformly.
- **ex** / **all**: the order-unconstrained De Bruijn binder prepends a witness at index 0; the
  induction hypothesis is gated on `StrictMono (Fin.cons a env)`, which fails for witnesses that
  are not the least element. Discharging these two cases needs the witness-position split /
  variable-reordering closure (the arity-lift `liftPair` forward direction is landed, but the full
  reordering closure is not) — see the strategic-sorry blocker below. `veeSat_exists` handles the
  `∨∃∀` side but not the environment-ordering mismatch on the `eval` side.

## Model-dependence (why this is a theorem, not a bare function)

The emitted `VeeExistsForall` depends on the model `N` (the atom interval comes from `hCapture`,
the negation formula from `veeSat_negation` via classical choice). So the deliverable is the
existential-by-induction correctness theorem `translate_correct`, in exactly the shape β
(`efSat_negation_general`) and γ (`veeSat_negation`) already take — not a model-independent
`MonadicFormula → VeeExistsForall` function.

## Threaded hypotheses (never discharged — CONDITIONAL orphan until ζ)

`translate_correct` carries the same `N / atomMap / h_surj / h_INF / h_SUP / hCapture / hne`
hypotheses β/γ thread. `hCapture` (interval-level capture) and `hne` are **threaded, never
discharged** — their discharge is the Phase-ζ concern. This module stays OFF the live import path.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 4.3 (p.6), Definition 3.1 (p.4).
  Cited by PDF page; the companion markdown transcription is corrupt.
- `LiftPair.lean`: `skelDisjunct`, `skelR`, `skelR_sat`, `charType`, `unaryHolds_charType`,
  `intervalHolds_top` — the universally-satisfiable arity-`m+1` skeleton.
- `VeeConj.lean`: `veeConj`, `veeConj_iff` (Lemma 3.4, ∧-part).
- `VeeSatNegation.lean`: `veeSat_negation` (Prop 4.3, ¬-case).
- `ExistsForallLemmas.lean`: `veeSat_exists` (Lemma 3.4, ∃-closure).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. The identity-pinned skeleton disjunct, characterized -/

/-- **Satisfaction of a single skeleton disjunct.** On a strictly increasing environment, the
identity-pinned ⊤-interval object `skelDisjunct m σ` holds exactly when the environment realizes
`σ`'s point type at every point: the witness chain is forced to be `env` (identity pins), the
interval caps are ⊤ (`intervalHolds_top`), so only the point-type clauses remain. -/
theorem skelDisjunct_efSat {m : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (σ : Fin (m + 1) → UnaryType sig F) (env : Fin (m + 1) → N.carrier)
    (hmono : StrictMono env) :
    efSat N env (skelDisjunct m σ) ↔ ∀ j : Fin (m + 1), unaryHolds N (σ j) (env j) := by
  constructor
  · rintro ⟨x, _, hxpin, hxpt, _, _, _⟩
    have hxeq : x = env := by
      funext k
      have h := hxpin k
      simp only [skelDisjunct, id_eq] at h
      exact h.symm
    intro j
    have h := hxpt j
    simp only [skelDisjunct] at h
    rw [hxeq] at h
    exact h
  · intro hpt
    refine ⟨env, hmono, ?_, ?_, ?_, ?_, ?_⟩
    · intro k; simp [skelDisjunct]
    · intro j; simpa [skelDisjunct] using hpt j
    · intro y _; exact intervalHolds_top N y
    · intro i y _ _; simpa [skelDisjunct] using intervalHolds_top N y
    · intro y _; simpa [skelDisjunct] using intervalHolds_top N y

/-! ## 2. The atom base case: a captured interval at a pinned free variable -/

/-- **Atom emit.** The sub-disjunction of the skeleton `skelR` keeping exactly the point-type
assignments whose type at the pinned variable `i` is admissible for the captured interval `S`.
Realizes "the interval `S` holds at `z_i`" as a `∨∃∀`-formula. -/
noncomputable def atomEmit {m : Nat} (i : Fin (m + 1)) (S : IntervalType sig F) :
    VeeExistsForall sig F (m + 1) :=
  ((Finset.univ : Finset (Fin (m + 1) → UnaryType sig F)).filter (fun σ => σ i ∈ S)).toList.map
    (skelDisjunct m)

/-- **Correctness of `atomEmit`.** On a strictly increasing environment, `atomEmit i S` is
satisfied exactly when the interval `S` holds at `env i`. Forward: any satisfied disjunct pins `σ`
with `σ i ∈ S` and realizes it at `env i`. Backward: given `τ ∈ S` realized at `env i`, take the
characteristic-type assignment updated to `τ` at position `i`. -/
theorem atomEmit_iff {m : Nat} (N : OrderedMonadicStructure (sigE sig F)) (i : Fin (m + 1))
    (S : IntervalType sig F) (env : Fin (m + 1) → N.carrier) (hmono : StrictMono env) :
    veeSat N env (atomEmit i S) ↔ intervalHolds N S (env i) := by
  classical
  unfold atomEmit veeSat
  simp only [List.mem_map, Finset.mem_toList, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨ψ, ⟨σ, hσS, rfl⟩, hsat⟩
    have hpt := (skelDisjunct_efSat N σ env hmono).mp hsat
    exact ⟨σ i, hσS, hpt i⟩
  · rintro ⟨τ, hτS, hτ⟩
    refine ⟨skelDisjunct m (Function.update (fun v => charType N (env v)) i τ),
      ⟨Function.update (fun v => charType N (env v)) i τ, ?_, rfl⟩, ?_⟩
    · rw [Function.update_self]; exact hτS
    · rw [skelDisjunct_efSat N _ env hmono]
      intro j
      by_cases hj : j = i
      · subst hj; rw [Function.update_self]; exact hτ
      · rw [Function.update_of_ne hj]; exact unaryHolds_charType N (env j)

/-! ## 3. Proposition 4.3 (structural, per-model, conditional on `hCapture`) -/

/-- **Proposition 4.3 (structural, PDF p.6).** Every monadic FO formula over the E[Σ] alphabet is,
on strictly increasing environments, equivalent to a `∨∃∀`-formula. Proved by induction on the
formula; the emitted `∨∃∀`-formula is model-dependent (atoms via `hCapture`, negation via
`veeSat_negation`). `hCapture` / `hne` are threaded, never discharged (CONDITIONAL orphan until ζ).

The `ex` / `all` cases carry a tracked strategic `sorry`: the De Bruijn binder prepends an
order-unconstrained witness at index 0, so the induction hypothesis (gated on
`StrictMono (Fin.cons a env)`) does not apply to non-least witnesses. Discharging them needs the
witness-position split / variable-reordering closure (report / BLOCKED `Prop43.lean` notes). -/
theorem translate_correct
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
        ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (hne : Nonempty N.carrier)
    {m : Nat} (φ : MonadicFormula (sigE sig F) m) :
    ∃ Ψ : VeeExistsForall sig F m, ∀ env : Fin m → N.carrier, StrictMono env →
      (veeSat N env Ψ ↔ eval N env φ) := by
  classical
  induction φ with
  | @atom n p i =>
    rcases n with _ | m'
    · exact i.elim0
    · obtain ⟨a, ha⟩ := h_surj p
      obtain ⟨S, hS⟩ := hCapture (.atom a)
      refine ⟨atomEmit i S, fun env hmono => ?_⟩
      rw [atomEmit_iff N i S env hmono, hS (env i)]
      show temporal_truth N atomMap (env i) (Formula.atom a) ↔ eval N env (MonadicFormula.atom p i)
      simp only [temporal_truth, ha, eval]
  | @lt n i j =>
    rcases n with _ | m'
    · exact i.elim0
    · by_cases hij : i < j
      · refine ⟨skelR m', fun env hmono => ?_⟩
        show veeSat N env (skelR m') ↔ env i < env j
        constructor
        · intro _; exact hmono.lt_iff_lt.mpr hij
        · intro _; exact skelR_sat N env hmono
      · refine ⟨[], fun env hmono => ?_⟩
        show veeSat N env ([] : VeeExistsForall sig F (m' + 1)) ↔ env i < env j
        constructor
        · intro h; exact absurd h (veeSat_nil N env)
        · intro h; exact absurd (hmono.lt_iff_lt.mp h) hij
  | @not n α ih =>
    obtain ⟨Ψα, hα⟩ := ih
    obtain ⟨Ψ', hΨ'⟩ := veeSat_negation N atomMap h_surj h_INF h_SUP hCapture hne Ψα
    refine ⟨Ψ', fun env hmono => ?_⟩
    show veeSat N env Ψ' ↔ ¬ eval N env α
    rw [← hΨ' env hmono, hα env hmono]
  | @and n α β ihα ihβ =>
    obtain ⟨Ψα, hα⟩ := ihα
    obtain ⟨Ψβ, hβ⟩ := ihβ
    refine ⟨veeConj Ψα Ψβ, fun env hmono => ?_⟩
    show veeSat N env (veeConj Ψα Ψβ) ↔ eval N env α ∧ eval N env β
    rw [veeConj_iff N env Ψα Ψβ, hα env hmono, hβ env hmono]
  | @all n α ih =>
    -- STRATEGIC SORRY (ex/all reordering closure — Phase 12 follow-up). See module docstring.
    sorry
  | @ex n α ih =>
    -- STRATEGIC SORRY (ex/all reordering closure — Phase 12 follow-up). See module docstring.
    sorry

end Bimodal.Metalogic.WeakCanonical.Kamp
