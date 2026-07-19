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

/-! ## 4. The arity-2 negation object in uniform shape (engine + collapse bridge)

The arity-2 pair negation `efSat_negation_pair` (`EFSatNegation.lean`) composes the model-side
engine `prop42_efSat_negation_general` (produces a `VVecEA2` witness `v'`) with the collapse bridge
`vvecea2_collapse_bridge` (lifts `v'` to a `VeeExistsForall`). Both the `VVecEA2` `v'` and the
lifted `Φ` are *model-independent* by construction — `v'` is the disjunctive reassembly
`¬ψ₀ ∨ ¬φ ∨ ¬ψ₁` (a function of `atomMap`/`h_surj`/`ψ` and the `ψ`-only pin comparison), and `Φ` is
`v'.disjuncts.flatMap transL` where `transL` mentions only `capFn`. `h_INF`/`h_SUP` enter *only* the
correctness proof (via `VVecEA2.negFix_iff`), and `hCapFn` only the bridge correctness. §4 hoists the
`∃`-witness *outside* the `∀N`, giving the uniform (`∃Φ`-outside-`∀N`) form of `efSat_negation_pair`.
-/

/-- **Uniform arity-2 model-side engine.** `∃v'`-outside-`∀N` form of `prop42_efSat_negation_general`:
the `VVecEA2` witness `v'` is the `ψ`-determined disjunctive reassembly (its construction never
mentions `N`, `h_INF`, or `h_SUP` — those enter only the `negFix_iff` correctness step), so the same
`v'` realizes `¬ efSat ξ` on strictly-ordered pairs for *every* Dedekind-complete `N`. -/
theorem prop42_efSat_negation_general_uniform
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ψ : ExistsForallFormula sig F 2) :
    ∃ v' : VVecEA2, ∀ (N : OrderedMonadicStructure (sigE sig F)),
      HasAttainedINF N atomMap → HasAttainedSUP N atomMap →
      ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (v'.holds N atomMap (env 0) (env 1) ↔ ¬ efSat N env ψ) := by
  by_cases hlt : (ψ.pin 0).val < (ψ.pin 1).val
  · refine ⟨VVecEA2.disj
      (VVecEA2.disj (negLeftClauseTL atomMap h_surj ψ) (middleBracket atomMap h_surj ψ).negFix)
      (negRightClauseTL atomMap h_surj ψ), ?_⟩
    intro N h_INF h_SUP env henv
    rw [VVecEA2.disj_holds, VVecEA2.disj_holds, negLeftClauseTL_holds,
      VVecEA2.negFix_iff N atomMap h_INF h_SUP _ (env 0) (env 1) henv, negRightClauseTL_holds,
      efSat_decompose_tl N atomMap h_surj env ψ hlt henv]
    tauto
  · refine ⟨VVecEA2.trivialTrue, ?_⟩
    intro N _ _ env henv
    constructor
    · intro _ hsat
      exact hlt (efSat_pin_lt N env ψ hsat henv)
    · intro _
      exact VVecEA2.trivialTrue_holds N atomMap (env 0) (env 1)

/-- **Uniform collapse bridge.** `∃Φ`-outside-`∀N` form of `vvecea2_collapse_bridge`: with the fixed
functional capture `capFn` in place of the existential `hCapture`, the lifted `∨∃∀`-object
`Φ = v'.disjuncts.flatMap transL` is a genuine function of `capFn` and `v'` alone (no model input),
realizing `v'.holds` on strictly-ordered pairs for every `N` for which `capFn` realizes capture. The
per-clause reverse translation is inlined (it is the `?_` obligation of
`vvecea2_collapse_of_perClauseList`, whose 8-line disjunct-bookkeeping body is reproduced after). -/
theorem vvecea2_collapse_bridge_uniform
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (capFn : Formula → IntervalType sig F)
    (v' : VVecEA2) :
    ∃ Φ : VeeExistsForall sig F 2,
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ (A : Formula) (y : N.carrier),
            intervalHolds N (capFn A) y ↔ temporal_truth N atomMap y A) →
        ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
        (veeSat N env Φ ↔ v'.holds N atomMap (env 0) (env 1)) := by
  classical
  refine ⟨v'.disjuncts.flatMap (fun vea =>
      ((capFn vea.2.endpointLeft.formula) ×ˢ (capFn vea.2.endpointRight.formula) ×ˢ
        Fintype.piFinset (fun i => capFn (vea.2.bracket.pointTypes i).formula)).toList.map
        (fun t => collapseEF (fun j => capFn (vea.2.bracket.segmentTypes j).formula)
          t.1 t.2.1 t.2.2)), ?_⟩
  intro N hCapFn env henv
  have htrans : ∀ vea ∈ v'.disjuncts, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      ((∃ ψ ∈ (fun vea =>
          ((capFn vea.2.endpointLeft.formula) ×ˢ (capFn vea.2.endpointRight.formula) ×ˢ
            Fintype.piFinset (fun i => capFn (vea.2.bracket.pointTypes i).formula)).toList.map
            (fun t => collapseEF (fun j => capFn (vea.2.bracket.segmentTypes j).formula)
              t.1 t.2.1 t.2.2)) vea, efSat N env ψ)
        ↔ vea.2.holds N atomMap (env 0) (env 1)) := by
    rintro ⟨m, vc⟩ hvea env henv
    dsimp only
    set S_L := capFn vc.endpointLeft.formula with hSL
    set S_R := capFn vc.endpointRight.formula with hSR
    set Sp := fun i => capFn (vc.bracket.pointTypes i).formula with hSp_def
    set Ss := fun j => capFn (vc.bracket.segmentTypes j).formula with hSs_def
    have hcorrect : ∀ (τ_L τ_R : UnaryType sig F) (g : Fin m → UnaryType sig F),
        efSat N env (collapseEF Ss τ_L τ_R g) ↔
          unaryHolds N τ_L (env 0) ∧ unaryHolds N τ_R (env 1) ∧
          (BracketFormula.mk (fun i => efPointTP atomMap h_surj (g i))
            (fun j => efIntervalSetTP atomMap h_surj (Ss j))).holds N atomMap (env 0) (env 1) := by
      intro τ_L τ_R g
      rw [translateProp42_correct N atomMap h_surj env (collapseEF Ss τ_L τ_R g)
            (collapseEF_cap N Ss τ_L τ_R g) henv,
          collapseEF_translate atomMap h_surj Ss τ_L τ_R g]
      constructor
      · rintro ⟨hL, hR, hbr⟩
        exact ⟨(efPointTP_eval N atomMap h_surj τ_L (env 0)).mp hL,
               (efPointTP_eval N atomMap h_surj τ_R (env 1)).mp hR, hbr⟩
      · rintro ⟨hL, hR, hbr⟩
        exact ⟨(efPointTP_eval N atomMap h_surj τ_L (env 0)).mpr hL,
               (efPointTP_eval N atomMap h_surj τ_R (env 1)).mpr hR, hbr⟩
    have hSpcap : ∀ (i : Fin m) (y : N.carrier),
        intervalHolds N (Sp i) y ↔ (vc.bracket.pointTypes i).eval_at N atomMap y :=
      fun i y => hCapFn (vc.bracket.pointTypes i).formula y
    have hSscap : ∀ (j : Fin (m + 1)) (y : N.carrier),
        intervalHolds N (Ss j) y ↔ (vc.bracket.segmentTypes j).eval_at N atomMap y :=
      fun j y => hCapFn (vc.bracket.segmentTypes j).formula y
    rw [VecEA2.holds]
    constructor
    · rintro ⟨ψ, hψmem, hsat⟩
      rw [List.mem_map] at hψmem
      obtain ⟨t, htmem, rfl⟩ := hψmem
      rw [Finset.mem_toList, Finset.mem_product, Finset.mem_product] at htmem
      obtain ⟨htL, htR, htg⟩ := htmem
      rw [hcorrect] at hsat
      obtain ⟨huL, huR, hbr⟩ := hsat
      refine ⟨?_, ?_, ?_⟩
      · exact (hCapFn vc.endpointLeft.formula (env 0)).mp ⟨t.1, htL, huL⟩
      · exact (hCapFn vc.endpointRight.formula (env 1)).mp ⟨t.2.1, htR, huR⟩
      · exact (bracket_completion_iff N atomMap h_surj vc.bracket Sp Ss hSpcap hSscap
          (env 0) (env 1)).mp ⟨t.2.2, htg, hbr⟩
    · rintro ⟨heL, heR, hbrk⟩
      have hiL : intervalHolds N S_L (env 0) := (hCapFn vc.endpointLeft.formula (env 0)).mpr heL
      have hiR : intervalHolds N S_R (env 1) := (hCapFn vc.endpointRight.formula (env 1)).mpr heR
      obtain ⟨τ_L, hτL, huL⟩ := hiL
      obtain ⟨τ_R, hτR, huR⟩ := hiR
      obtain ⟨g, hg, hbr⟩ := (bracket_completion_iff N atomMap h_surj vc.bracket Sp Ss
        hSpcap hSscap (env 0) (env 1)).mpr hbrk
      refine ⟨collapseEF Ss τ_L τ_R g, ?_, ?_⟩
      · rw [List.mem_map]
        exact ⟨(τ_L, τ_R, g), by
          rw [Finset.mem_toList, Finset.mem_product, Finset.mem_product]
          exact ⟨hτL, hτR, hg⟩, rfl⟩
      · rw [hcorrect]
        exact ⟨huL, huR, hbr⟩
  simp only [veeSat, VVecEA2.holds, List.mem_flatMap]
  constructor
  · rintro ⟨ψ, ⟨vea, hvea, hψ⟩, hsat⟩
    exact ⟨vea, hvea, (htrans vea hvea env henv).mp ⟨ψ, hψ, hsat⟩⟩
  · rintro ⟨vea, hvea, hholds⟩
    obtain ⟨ψ, hψ, hsat⟩ := (htrans vea hvea env henv).mpr hholds
    exact ⟨ψ, ⟨vea, hvea, hψ⟩, hsat⟩

/-- **Uniform arity-2 negation object (engine ∘ bridge).** `∃Φ`-outside-`∀N` form of
`efSat_negation_pair`: compose the uniform engine (model-independent `v'`) with the uniform collapse
bridge (model-independent `Φ`). The emitted `Φ` is fixed before any `N`; `hCapFn` and `h_INF`/`h_SUP`
are threaded per-`N`. -/
theorem efSat_negation_pair_uniform
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (capFn : Formula → IntervalType sig F)
    (ξ : ExistsForallFormula sig F 2) :
    ∃ Φ : VeeExistsForall sig F 2,
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ (A : Formula) (y : N.carrier),
            intervalHolds N (capFn A) y ↔ temporal_truth N atomMap y A) →
        HasAttainedINF N atomMap → HasAttainedSUP N atomMap →
        ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
        (veeSat N env Φ ↔ ¬ efSat N env ξ) := by
  obtain ⟨v', hv'⟩ := prop42_efSat_negation_general_uniform atomMap h_surj ξ
  obtain ⟨Φ, hΦ⟩ := vvecea2_collapse_bridge_uniform atomMap h_surj capFn v'
  refine ⟨Φ, fun N hCapFn h_INF h_SUP env henv => ?_⟩
  exact (hΦ N hCapFn env henv).trans (hv' N h_INF h_SUP env henv)

/-! ## 5. The general negation object (β) in uniform shape

`efSat_negation_general` (`EFSatNegationGeneral.lean`) assembles the arity-`r` negation from the
three low-arity leaves (`efSat_negation_pair`, `efSat_negation_diagonal`, `efSat_negation_existence`)
via the De Morgan trichotomy. §5 copies that assembly verbatim, `choose`-ing over the three uniform
leaves (`efSat_negation_pair_uniform`, and the landed `efSat_negation_diagonal_uniform` /
`efSat_negation_existence_uniform`), which pulls the emitted `∨∃∀`-disjuncts `P`/`D`/`E` *outside*
the `∀N`. The disjunct list `Φ` and its pin-monotonicity are then model-independent; only the final
De Morgan biconditional is per-`N` (threading `hCapFn`/`h_INF`/`h_SUP`/`hne`). -/

/-- **Uniform `efSat_negation_general` (β at the `∨∃∀` type).** `∃Φ`-outside-`∀N` form of
`efSat_negation_general`: the disjunct list `Φ` is assembled from the three model-independent leaves
`P`/`D`/`E`, so it is a fixed `∨∃∀`-formula, and its pin-monotonicity holds before any `N`. The De
Morgan trichotomy correctness is proved per-`N`, threading `hCapFn` (pair/diagonal/existence),
`h_INF`/`h_SUP` (pair), and `hne` (existence). -/
theorem efSat_negation_general_uniform
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (capFn : Formula → IntervalType sig F)
    {r : Nat} (ψ : ExistsForallFormula sig F r) :
    ∃ Φ : VeeExistsForall sig F r, (∀ φ ∈ Φ, StrictMono φ.pin) ∧
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ (A : Formula) (y : N.carrier),
            intervalHolds N (capFn A) y ↔ temporal_truth N atomMap y A) →
        HasAttainedINF N atomMap → HasAttainedSUP N atomMap → Nonempty N.carrier →
        ∀ env : Fin r → N.carrier, StrictMono env →
        (¬ efSat N env ψ ↔ veeSat N env Φ) := by
  classical
  have hpair := fun (k l : Fin r) =>
    efSat_negation_pair_uniform atomMap h_surj capFn (pairProject ψ k l)
  choose P hPspec using hpair
  have hdiag := fun (k : Fin r) =>
    efSat_negation_diagonal_uniform atomMap h_surj capFn (diagProject ψ k)
  choose D hDspec using hdiag
  obtain ⟨E, hEspec⟩ :=
    efSat_negation_existence_uniform atomMap h_surj capFn (existenceSentence ψ)
  refine ⟨((List.finRange r).flatMap fun k => (List.finRange r).flatMap fun l =>
            if k < l then liftPairV (P k l) k l else [])
          ++ ((List.finRange r).flatMap fun k => liftSingleV (D k) k)
          ++ liftSentenceV E, ?_, ?_⟩
  · -- Pin-monotonicity of every disjunct (model-independent).
    intro φ hφ
    rw [List.mem_append, List.mem_append] at hφ
    rcases hφ with (hφ | hφ) | hφ
    · rw [List.mem_flatMap] at hφ
      obtain ⟨k, _, hφ⟩ := hφ
      rw [List.mem_flatMap] at hφ
      obtain ⟨l, _, hφ⟩ := hφ
      by_cases hkl : k < l
      · rw [if_pos hkl] at hφ
        exact liftPairV_pin_strictMono (P k l) k l φ hφ
      · rw [if_neg hkl] at hφ
        exact absurd hφ List.not_mem_nil
    · rw [List.mem_flatMap] at hφ
      obtain ⟨k, _, hφ⟩ := hφ
      exact liftSingleV_pin_strictMono (D k) k φ hφ
    · exact liftSentenceV_pin_strictMono E φ hφ
  · intro N hCapFn h_INF h_SUP hne env h
    set A := (List.finRange r).flatMap (fun k => (List.finRange r).flatMap fun l =>
              if k < l then liftPairV (P k l) k l else []) with hAdef
    set B := (List.finRange r).flatMap (fun k => liftSingleV (D k) k) with hBdef
    set C := liftSentenceV E with hCdef
    have hA : veeSat N env A ↔
        ∃ k l : Fin r, k < l ∧ ¬ efSat N ![env k, env l] (pairProject ψ k l) := by
      rw [hAdef, veeSat_flatMap]
      constructor
      · rintro ⟨k, -, hk⟩
        rw [veeSat_flatMap] at hk
        obtain ⟨l, -, hl⟩ := hk
        by_cases hkl : k < l
        · rw [if_pos hkl, liftPairV_iff N env h (P k l) k l hkl,
            hPspec k l N hCapFn h_INF h_SUP ![env k, env l] (by simpa using h hkl)] at hl
          exact ⟨k, l, hkl, hl⟩
        · rw [if_neg hkl] at hl
          simp [veeSat] at hl
      · rintro ⟨k, l, hkl, hnp⟩
        refine ⟨k, List.mem_finRange k, ?_⟩
        rw [veeSat_flatMap]
        refine ⟨l, List.mem_finRange l, ?_⟩
        rw [if_pos hkl, liftPairV_iff N env h (P k l) k l hkl,
          hPspec k l N hCapFn h_INF h_SUP ![env k, env l] (by simpa using h hkl)]
        exact hnp
    have hB : veeSat N env B ↔
        ∃ k : Fin r, ¬ efSat N ![env k, env k] (pairProject ψ k k) := by
      rw [hBdef, veeSat_flatMap]
      constructor
      · rintro ⟨k, -, hk⟩
        rw [liftSingleV_iff N env h (D k) k, hDspec k N hCapFn ![env k],
          ← diagProject_efSat_iff N env ψ k] at hk
        exact ⟨k, hk⟩
      · rintro ⟨k, hk⟩
        refine ⟨k, List.mem_finRange k, ?_⟩
        rw [liftSingleV_iff N env h (D k) k, hDspec k N hCapFn ![env k],
          ← diagProject_efSat_iff N env ψ k]
        exact hk
    have hC : veeSat N env C ↔ ¬ efSat N ![] (existenceSentence ψ) := by
      rw [hCdef, liftSentenceV_iff N env h E, hEspec N hCapFn hne]
    have hDemPairs : (∃ p ∈ pairwiseProjections ψ, ¬ efSat N ![env p.1, env p.2.1] p.2.2)
        ↔ ∃ k l : Fin r, ¬ efSat N ![env k, env l] (pairProject ψ k l) := by
      constructor
      · rintro ⟨p, hp, hnp⟩
        unfold pairwiseProjections at hp
        rw [List.mem_flatMap] at hp
        obtain ⟨k, -, hp⟩ := hp
        rw [List.mem_map] at hp
        obtain ⟨l, -, rfl⟩ := hp
        exact ⟨k, l, hnp⟩
      · rintro ⟨k, l, hnp⟩
        refine ⟨(k, l, pairProject ψ k l), ?_, hnp⟩
        unfold pairwiseProjections
        rw [List.mem_flatMap]
        exact ⟨k, List.mem_finRange k, by rw [List.mem_map]; exact ⟨l, List.mem_finRange l, rfl⟩⟩
    have hTri : (∃ k l : Fin r, ¬ efSat N ![env k, env l] (pairProject ψ k l))
        ↔ (∃ k l : Fin r, k < l ∧ ¬ efSat N ![env k, env l] (pairProject ψ k l))
          ∨ (∃ k : Fin r, ¬ efSat N ![env k, env k] (pairProject ψ k k)) := by
      constructor
      · rintro ⟨k, l, hnp⟩
        rcases lt_trichotomy k l with hkl | hkl | hkl
        · exact Or.inl ⟨k, l, hkl, hnp⟩
        · subst hkl; exact Or.inr ⟨_, hnp⟩
        · refine Or.inl ⟨l, k, hkl, ?_⟩
          rw [← pairProject_swap_efSat N env ψ k l]
          exact hnp
      · rintro (⟨k, l, -, hnp⟩ | ⟨k, hnp⟩)
        · exact ⟨k, l, hnp⟩
        · exact ⟨k, k, hnp⟩
    rw [efSat_negation_demorgan N env ψ, hDemPairs, veeSat_append, veeSat_append,
      hA, hB, hC, hTri]

/-! ## 6. Negation closure of `∨∃∀`-formulas (γ) in uniform shape

`veeSat_negation` (`VeeSatNegation.lean`) closes `∨∃∀` under negation by induction on the disjunct
list, re-expressing each `¬φᵢ` via β and reassembling with `veeConj_iff`. §6 copies that induction,
swapping β (`efSat_negation_general`) for the uniform `efSat_negation_general_uniform`, so the output
list `Φ'` is model-independent. -/

/-- **Uniform `veeSat_negation` (γ).** `∃Φ'`-outside-`∀N` form: each `¬φᵢ` is the uniform β-negation,
the conjunction reassembled by `veeConj_iff`. The emitted `Φ'` and its pin-monotonicity are fixed
before any `N`; correctness threads `hCapFn`/`h_INF`/`h_SUP`/`hne`. -/
theorem veeSat_negation_uniform
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (capFn : Formula → IntervalType sig F)
    {r : Nat} (Φ : VeeExistsForall sig F r) :
    ∃ Φ' : VeeExistsForall sig F r, (∀ ψ ∈ Φ', StrictMono ψ.pin) ∧
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ (A : Formula) (y : N.carrier),
            intervalHolds N (capFn A) y ↔ temporal_truth N atomMap y A) →
        HasAttainedINF N atomMap → HasAttainedSUP N atomMap → Nonempty N.carrier →
        ∀ env : Fin r → N.carrier, StrictMono env →
        (¬ veeSat N env Φ ↔ veeSat N env Φ') := by
  classical
  induction Φ with
  | nil =>
    obtain ⟨Gd, hGdmono, hGd⟩ :=
      efSat_negation_general_uniform atomMap h_surj capFn (efArb sig F r)
    refine ⟨Gd ++ [efArb sig F r], ?_, ?_⟩
    · intro φ hφ
      rw [List.mem_append] at hφ
      rcases hφ with hφ | hφ
      · exact hGdmono φ hφ
      · rw [List.mem_singleton] at hφ
        subst hφ
        exact efArb_pin_strictMono sig F r
    · intro N hCapFn h_INF h_SUP hne env hmono
      constructor
      · intro _
        rw [veeSat_append]
        by_cases hd : efSat N env (efArb sig F r)
        · exact Or.inr ⟨efArb sig F r, by simp, hd⟩
        · exact Or.inl ((hGd N hCapFn h_INF h_SUP hne env hmono).mp hd)
      · intro _
        exact veeSat_nil N env
  | cons ψ rest ih =>
    obtain ⟨Gψ, hGψmono, hGψ⟩ :=
      efSat_negation_general_uniform atomMap h_surj capFn ψ
    obtain ⟨Φrest, hrestmono, hrest⟩ := ih
    refine ⟨veeConj Gψ Φrest, ?_, ?_⟩
    · exact fun χ hχ => veeConj_pin_strictMono Gψ Φrest hGψmono χ hχ
    · intro N hCapFn h_INF h_SUP hne env hmono
      rw [veeSat_cons, not_or, hGψ N hCapFn h_INF h_SUP hne env hmono,
        hrest N hCapFn h_INF h_SUP hne env hmono, veeConj_iff N env Gψ Φrest]

/-! ## 7. The `∃`-closure assembly in uniform shape

`ex_closure_translate` (`Prop43Translate.lean`) assembles a `∨∃∀`-formula equivalent to
`∃ x, eval (Fin.cons x env) α` from `∨∃∀`-translations of the gap reindexings and tie substitutions.
Its emitted `Ψ = gap-flatMap ++ tie-flatMap` and its pin-monotonicity mention only `Ψg`/`Ψt` (no
model), so §7 hoists the `∃Ψ` outside `∀N`, moving the per-`N` gap/tie correctness hypotheses
(`hΨg`/`hΨt`) inside. The assembly and both proof halves are copied verbatim. -/

/-- **Uniform `ex_closure_translate`.** `∃Ψ`-outside-`∀N` form: the emitted `∨∃∀`-formula and its
pin-monotonicity are functions of `Ψg`/`Ψt` alone; the per-`N` gap/tie translation correctness is
threaded as hypotheses inside `∀N`. Proof body copied verbatim from `ex_closure_translate`. -/
theorem ex_closure_translate_uniform {m : Nat}
    (α : MonadicFormula (sigE sig F) (m + 1))
    (Ψg : Fin (m + 1) → VeeExistsForall sig F (m + 1))
    (hΨgmono : ∀ p, ∀ ψ ∈ Ψg p, StrictMono ψ.pin)
    (Ψt : Fin m → VeeExistsForall sig F m)
    (hΨtmono : ∀ i, ∀ ψ ∈ Ψt i, StrictMono ψ.pin) :
    ∃ Ψ : VeeExistsForall sig F m, (∀ ψ ∈ Ψ, StrictMono ψ.pin) ∧
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ (p : Fin (m + 1)) (env : Fin (m + 1) → N.carrier), StrictMono env →
            (veeSat N env (Ψg p) ↔
              eval N env (α.rename (insertPerm p : Fin (m + 1) → Fin (m + 1))))) →
        (∀ (i : Fin m) (env : Fin m → N.carrier), StrictMono env →
            (veeSat N env (Ψt i) ↔ eval N env (α.subst0 i))) →
        ∀ env : Fin m → N.carrier, StrictMono env →
        (veeSat N env Ψ ↔ ∃ x : N.carrier, eval N (Fin.cons x env) α) := by
  classical
  refine ⟨((List.finRange (m + 1)).flatMap fun p =>
             ((Ψg p).map (ExistsForallFormula.renamePin
               (insertPerm p : Fin (m + 1) → Fin (m + 1)))).map dropPin)
          ++ ((List.finRange m).flatMap fun i => Ψt i), ?_, ?_⟩
  · intro φ hφ
    rw [List.mem_append] at hφ
    rcases hφ with hφ | hφ
    · rw [List.mem_flatMap] at hφ
      obtain ⟨p, _, hφ⟩ := hφ
      rw [List.mem_map] at hφ
      obtain ⟨χ, hχmem, rfl⟩ := hφ
      rw [List.mem_map] at hχmem
      obtain ⟨ψ, hψmem, rfl⟩ := hχmem
      have hcomp : (dropPin (ExistsForallFormula.renamePin
          (insertPerm p : Fin (m + 1) → Fin (m + 1)) ψ)).pin
          = ψ.pin ∘ (fun k : Fin m => (insertPerm p : Fin (m + 1) → Fin (m + 1)) k.succ) := rfl
      rw [hcomp]
      have hsucc : (fun k : Fin m => (insertPerm p : Fin (m + 1) → Fin (m + 1)) k.succ)
          = p.succAbove := by funext k; exact insertPerm_succ p k
      rw [hsucc]
      exact (hΨgmono p ψ hψmem).comp (Fin.strictMono_succAbove p)
    · rw [List.mem_flatMap] at hφ
      obtain ⟨i, _, hφ⟩ := hφ
      exact hΨtmono i φ hφ
  · intro N hΨg hΨt env hmono
    rw [veeSat_append]
    constructor
    · rintro (hgapv | htiev)
      · rw [veeSat_flatMap] at hgapv
        obtain ⟨p, _, hpv⟩ := hgapv
        rw [← veeSat_exists] at hpv
        obtain ⟨a, hav⟩ := hpv
        rw [veeSat_renamePin, cons_comp_insertPerm_symm] at hav
        have hsm : StrictMono (Fin.insertNth p a env) :=
          strictMono_of_veeSat_pin_mono N _ (Ψg p) (hΨgmono p) hav
        have heval := (hΨg p (Fin.insertNth p a env) hsm).mp hav
        rw [eval_insertNth_rename] at heval
        exact ⟨a, heval⟩
      · rw [veeSat_flatMap] at htiev
        obtain ⟨i, _, hiv⟩ := htiev
        have heval := (hΨt i env hmono).mp hiv
        rw [eval_subst0] at heval
        exact ⟨env i, heval⟩
    · rintro ⟨x, hx⟩
      rcases witness_classification env hmono x with ⟨i, rfl⟩ | ⟨p, hsm⟩
      · rw [← eval_subst0] at hx
        have hiv := (hΨt i env hmono).mpr hx
        refine Or.inr ?_
        rw [veeSat_flatMap]
        exact ⟨i, List.mem_finRange i, hiv⟩
      · rw [← eval_insertNth_rename N p x env α] at hx
        have hpv := (hΨg p (Fin.insertNth p x env) hsm).mpr hx
        rw [← cons_comp_insertPerm_symm p x env, ← veeSat_renamePin] at hpv
        refine Or.inl ?_
        rw [veeSat_flatMap]
        refine ⟨p, List.mem_finRange p, ?_⟩
        rw [← veeSat_exists]
        exact ⟨x, hpv⟩

/-! ## 8. The uniform Proposition 4.3 `translate` (δ, `∃Ψ`-outside-`∀N`)

`translate_correct` (`Prop43Translate.lean`) proves — by well-founded recursion on
`MonadicFormula.size` — that every monadic FO formula is `∨∃∀`-equivalent, per model `N`. §8 copies
that recursion with `atomMap`/`h_surj`/`capFn` fixed as parameters and the model quantifier pulled to
the *inside*, so the emitted `Ψ` is a genuine function of `φ` (and the fixed params) alone. Atoms use
the model-independent `capType` base case `atomEmit_capType_iff` (no `hCapFn`/`h_surj` naming needed
at atoms, since `capType` is predicate-level); `lt`/`and` are index/`veeConj` decided as before; `not`
uses `veeSat_negation_uniform`; `ex`/`all` use `ex_closure_translate_uniform` with the uniform gap/tie
sub-pieces. All model-dependence (`hCapFn`/`h_INF`/`h_SUP`/`hne`) is threaded inside `∀N`. -/

/-- **Uniform Proposition 4.3 `translate` (δ).** `∃Ψ`-outside-`∀N` form of `translate_correct`: for a
fixed `atomMap`/`h_surj`/`capFn`, every monadic FO formula `φ` has a *single* `∨∃∀`-formula `Ψ` (a
function of `φ` and the params alone — no model input) that, on every `N` for which `capFn` realizes
capture (with `h_INF`/`h_SUP`/`hne`), is equivalent to `φ` on strictly increasing environments. This
is the uniform `translate` the completeness spine needs; Phase ζ discharges `capFn` `𝔈`-boundedly. -/
theorem translate_uniform
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (capFn : Formula → IntervalType sig F)
    {m : Nat} (φ : MonadicFormula (sigE sig F) m) :
    ∃ Ψ : VeeExistsForall sig F m, (∀ ψ ∈ Ψ, StrictMono ψ.pin) ∧
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ (A : Formula) (y : N.carrier),
            intervalHolds N (capFn A) y ↔ temporal_truth N atomMap y A) →
        HasAttainedINF N atomMap → HasAttainedSUP N atomMap → Nonempty N.carrier →
        ∀ env : Fin m → N.carrier, StrictMono env →
        (veeSat N env Ψ ↔ eval N env φ) := by
  classical
  match m, φ with
  | 0, .atom _ i => exact i.elim0
  | (m' + 1), .atom p i =>
      refine ⟨atomEmit i (capType p), ?_, ?_⟩
      · intro φ' hφ'
        unfold atomEmit at hφ'
        rw [List.mem_map] at hφ'
        obtain ⟨σ, _, rfl⟩ := hφ'
        exact skelDisjunct_pin_strictMono σ
      · intro N _ _ _ _ env hmono
        exact atomEmit_capType_iff N i p env hmono
  | 0, .lt i _ => exact i.elim0
  | (m' + 1), .lt i j =>
      by_cases hij : i < j
      · refine ⟨skelR m', ?_, ?_⟩
        · exact fun φ' hφ' => skelR_pin_strictMono φ' hφ'
        · intro N _ _ _ _ env hmono
          show veeSat N env (skelR m') ↔ env i < env j
          constructor
          · intro _; exact hmono.lt_iff_lt.mpr hij
          · intro _; exact skelR_sat N env hmono
      · refine ⟨[], ?_, ?_⟩
        · intro φ' hφ'; exact absurd hφ' List.not_mem_nil
        · intro N _ _ _ _ env hmono
          show veeSat N env ([] : VeeExistsForall sig F (m' + 1)) ↔ env i < env j
          constructor
          · intro h; exact absurd h (veeSat_nil N env)
          · intro h; exact absurd (hmono.lt_iff_lt.mp h) hij
  | _, .not α =>
      obtain ⟨Ψα, _, hα⟩ := translate_uniform atomMap h_surj capFn α
      obtain ⟨Ψ', hΨ'mono, hΨ'⟩ := veeSat_negation_uniform atomMap h_surj capFn Ψα
      refine ⟨Ψ', hΨ'mono, ?_⟩
      intro N hCapFn h_INF h_SUP hne env hmono
      show veeSat N env Ψ' ↔ ¬ eval N env α
      rw [← hΨ' N hCapFn h_INF h_SUP hne env hmono, hα N hCapFn h_INF h_SUP hne env hmono]
  | _, .and α β =>
      obtain ⟨Ψα, hαmono, hα⟩ := translate_uniform atomMap h_surj capFn α
      obtain ⟨Ψβ, _, hβ⟩ := translate_uniform atomMap h_surj capFn β
      refine ⟨veeConj Ψα Ψβ, ?_, ?_⟩
      · exact fun χ hχ => veeConj_pin_strictMono Ψα Ψβ hαmono χ hχ
      · intro N hCapFn h_INF h_SUP hne env hmono
        show veeSat N env (veeConj Ψα Ψβ) ↔ eval N env α ∧ eval N env β
        rw [veeConj_iff N env Ψα Ψβ, hα N hCapFn h_INF h_SUP hne env hmono,
          hβ N hCapFn h_INF h_SUP hne env hmono]
  | m, .all α =>
      have hgap := fun p : Fin (m + 1) =>
        translate_uniform atomMap h_surj capFn
          (α.rename (insertPerm p : Fin (m + 1) → Fin (m + 1)))
      choose Ψg hΨgmono hΨg using hgap
      have htie := fun i : Fin m =>
        translate_uniform atomMap h_surj capFn (α.subst0 i)
      choose Ψt hΨtmono hΨt using htie
      have hgapN := fun p : Fin (m + 1) =>
        veeSat_negation_uniform atomMap h_surj capFn (Ψg p)
      choose Ψg' hΨg'mono hΨg'neg using hgapN
      have htieN := fun i : Fin m =>
        veeSat_negation_uniform atomMap h_surj capFn (Ψt i)
      choose Ψt' hΨt'mono hΨt'neg using htieN
      obtain ⟨Ψex, hΨexmono, hΨexcorr⟩ :=
        ex_closure_translate_uniform (.not α) Ψg' hΨg'mono Ψt' hΨt'mono
      obtain ⟨Ψall, hΨallmono, hΨallneg⟩ :=
        veeSat_negation_uniform atomMap h_surj capFn Ψex
      refine ⟨Ψall, hΨallmono, ?_⟩
      intro N hCapFn h_INF h_SUP hne env hmono
      have hΨex := hΨexcorr N
        (fun p env' h => (hΨg'neg p N hCapFn h_INF h_SUP hne env' h).symm.trans
          (not_congr (hΨg p N hCapFn h_INF h_SUP hne env' h)))
        (fun i env' h => (hΨt'neg i N hCapFn h_INF h_SUP hne env' h).symm.trans
          (not_congr (hΨt i N hCapFn h_INF h_SUP hne env' h)))
        env hmono
      rw [← hΨallneg N hCapFn h_INF h_SUP hne env hmono, hΨex]
      exact not_exists_not
  | m, .ex α =>
      have hgap := fun p : Fin (m + 1) =>
        translate_uniform atomMap h_surj capFn
          (α.rename (insertPerm p : Fin (m + 1) → Fin (m + 1)))
      choose Ψg hΨgmono hΨg using hgap
      have htie := fun i : Fin m =>
        translate_uniform atomMap h_surj capFn (α.subst0 i)
      choose Ψt hΨtmono hΨt using htie
      obtain ⟨Ψex, hΨexmono, hΨexcorr⟩ :=
        ex_closure_translate_uniform α Ψg hΨgmono Ψt hΨtmono
      refine ⟨Ψex, hΨexmono, ?_⟩
      intro N hCapFn h_INF h_SUP hne env hmono
      exact hΨexcorr N
        (fun p env' h => hΨg p N hCapFn h_INF h_SUP hne env' h)
        (fun i env' h => hΨt i N hCapFn h_INF h_SUP hne env' h)
        env hmono
termination_by φ.size
decreasing_by
  all_goals simp only [MonadicFormula.size, size_rename, size_subst0]
  all_goals omega

end Bimodal.Metalogic.WeakCanonical.Kamp
