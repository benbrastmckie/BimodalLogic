import Bimodal.Metalogic.WeakCanonical.PriorExpressiveness
import Bimodal.Metalogic.WeakCanonical.EFGames.Defs
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.BXCanonical.TruthLemma

/-!
# Reynolds Model Surgery: No Gaps in Faithful Prior Structures

This file proves Reynolds' Theorem 14 (Reynolds 1994, pp.124-129) adapted to
faithful Prior structures at the MCS level: if a discrete linear order without
endpoints has an MCS assignment satisfying Prior-UZ/SZ and C4/C5 coherence,
then no Dedekind gaps exist.

## Key Result

`no_gaps_faithful`: For any `PriorModelData` (a Prior structure with MCS
assignment and C4/C5 coherence but WITHOUT `IsSuccArchimedean`), there are
no Dedekind gaps.

`prior_model_is_succ_archimedean`: Corollary -- any `PriorModelData` is
IsSuccArchimedean.

## Import Design

This file deliberately avoids importing ChronicleExtraction, NEquivalence,
Transfer, or ChronicleNoGaps to prevent circular dependencies. The theorem
`chronicle_gap_contradiction` in ChronicleToCountermodel.lean imports THIS
file and constructs a `PriorModelData` from the raw chronicle hypotheses.

The `effectiveFormula` definition is reproduced here (from Transfer.lean)
because Transfer.lean imports ChronicleToCountermodel, creating a circular
dependency if we imported it.

## References

- Reynolds 1994, Theorem 14, pp.124-129
- Reynolds 1994, Theorem 5, pp.123-124 (US expressive completeness)
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core

/-! ## PriorModelData: ChronicleAsPriorModel without IsSuccArchimedean -/

/--
A **PriorModelData** wraps a discrete linear order with an MCS assignment
satisfying Prior-UZ/SZ and C4/C5 coherence. Unlike `ChronicleAsPriorModel`,
it does NOT require `IsSuccArchimedean` as a field. This avoids the circularity
where proving `IsSuccArchimedean` requires the gap-free property, but
`ChronicleAsPriorModel` already requires `IsSuccArchimedean`.
-/
structure PriorModelData (fc : FrameClass := FrameClass.Base) where
  /-- Domain type -/
  domain : Type
  /-- Linear order on domain -/
  domain_lo : LinearOrder domain
  /-- Domain has no maximum -/
  domain_no_max : NoMaxOrder domain
  /-- Domain has no minimum -/
  domain_no_min : NoMinOrder domain
  /-- Domain is discrete (has immediate successors) -/
  domain_succ : SuccOrder domain
  /-- Domain is discrete (has immediate predecessors) -/
  domain_pred : PredOrder domain
  /-- MCS assignment at each domain point -/
  fmcs : domain → Set Formula
  /-- Each domain point maps to an MCS -/
  fmcs_is_mcs : ∀ t : domain, SetMaximalConsistent (fc := fc) (fmcs t)
  /-- Prior-UZ valid: for all ψ, Prior-UZ(ψ) ∈ MCS at every point -/
  prior_UZ_valid : ∀ t : domain, ∀ ψ : Formula,
    Formula.imp (Formula.some_future ψ) (Formula.untl ψ ψ.neg) ∈ fmcs t
  /-- Prior-SZ valid: for all ψ, Prior-SZ(ψ) ∈ MCS at every point -/
  prior_SZ_valid : ∀ t : domain, ∀ ψ : Formula,
    Formula.imp (Formula.some_past ψ) (Formula.snce ψ ψ.neg) ∈ fmcs t
  /-- C5 forward for Until -/
  until_coherent_fwd : ∀ (t : domain) (φ ψ : Formula),
    Formula.untl φ ψ ∈ fmcs t →
    ∃ (s : domain), t < s ∧ φ ∈ fmcs s ∧
      ∀ (r : domain), t < r → r < s → ψ ∈ fmcs r
  /-- C5 forward for Since -/
  since_coherent_fwd : ∀ (t : domain) (φ ψ : Formula),
    Formula.snce φ ψ ∈ fmcs t →
    ∃ (s : domain), s < t ∧ φ ∈ fmcs s ∧
      ∀ (r : domain), s < r → r < t → ψ ∈ fmcs r
  /-- C4 backward for Until -/
  neg_until_coherent : ∀ (t s : domain), t < s → ∀ (φ ψ : Formula),
    (Formula.untl φ ψ).neg ∈ fmcs t → φ ∈ fmcs s →
    ∃ (z : domain), t < z ∧ z < s ∧ ψ.neg ∈ fmcs z
  /-- C4 backward for Since -/
  neg_since_coherent : ∀ (t s : domain), s < t → ∀ (φ ψ : Formula),
    (Formula.snce φ ψ).neg ∈ fmcs t → φ ∈ fmcs s →
    ∃ (z : domain), s < z ∧ z < t ∧ ψ.neg ∈ fmcs z

attribute [instance] PriorModelData.domain_lo
attribute [instance] PriorModelData.domain_no_max
attribute [instance] PriorModelData.domain_no_min
attribute [instance] PriorModelData.domain_succ
attribute [instance] PriorModelData.domain_pred

/-! ## Monadic Structure from PriorModelData -/

/-- Convert a `PriorModelData` to an `OrderedMonadicStructure`.
    Predicate `p` holds at `x` iff `atomMap p ∈ M.fmcs x`. -/
def priorModelAsMonadicStructure {fc : FrameClass}
    (M : PriorModelData fc) (sig : MonadicSignature)
    (atomMap : sig.preds → Formula) : OrderedMonadicStructure sig where
  carrier := M.domain
  interp p x := (atomMap p) ∈ M.fmcs x
  carrier_order := M.domain_lo

/-! ## Effective Formula (Local Copy)

The effective formula maps temporal formulas through atomMap round-trip.
This is a local copy of `effectiveFormula` from Transfer.lean, reproduced
here to avoid circular imports (Transfer -> ChronicleToCountermodel).
-/

/--
The effective formula: the formula whose MCS membership corresponds to
temporal_truth of ψ under atomMap_fwd on the faithful monadic structure.
Local copy to avoid circular import with Transfer.lean.
-/
def effectiveFormula_raw {sig : MonadicSignature} (atomMap_rev : sig.preds → Formula)
    (atomMap_fwd : Formula → sig.preds) : Formula → Formula
  | .atom a => atomMap_rev (atomMap_fwd (.atom a))
  | .bot => .bot
  | .imp φ ψ => .imp (effectiveFormula_raw atomMap_rev atomMap_fwd φ)
      (effectiveFormula_raw atomMap_rev atomMap_fwd ψ)
  | .box φ => atomMap_rev (atomMap_fwd (.box φ))
  | .untl φ ψ => .untl (effectiveFormula_raw atomMap_rev atomMap_fwd φ)
      (effectiveFormula_raw atomMap_rev atomMap_fwd ψ)
  | .snce φ ψ => .snce (effectiveFormula_raw atomMap_rev atomMap_fwd φ)
      (effectiveFormula_raw atomMap_rev atomMap_fwd ψ)

/-! ## Temporal Truth ↔ MCS Membership (Faithfulness) -/

/--
temporal_truth on the PriorModelData monadic structure corresponds
to MCS membership of the effective formula.
(Analogue of `chronicle_temporal_truth_effective` for `PriorModelData`.)
-/
theorem temporal_truth_effective_raw {fc : FrameClass}
    (M : PriorModelData fc) (sig : MonadicSignature)
    (atomMap_rev : sig.preds → Formula) (atomMap_fwd : Formula → sig.preds)
    (ψ : Formula) (t : M.domain) :
    temporal_truth (priorModelAsMonadicStructure M sig atomMap_rev) atomMap_fwd t ψ ↔
      effectiveFormula_raw atomMap_rev atomMap_fwd ψ ∈ M.fmcs t := by
  revert t
  induction ψ with
  | atom a =>
    intro t
    show (priorModelAsMonadicStructure M sig atomMap_rev).interp (atomMap_fwd (.atom a)) t ↔
        atomMap_rev (atomMap_fwd (.atom a)) ∈ M.fmcs t
    simp only [priorModelAsMonadicStructure]
  | bot =>
    intro t
    constructor
    · exact False.elim
    · intro h; exact absurd h
        (Bimodal.Metalogic.BXCanonical.bot_not_in_mcs (M.fmcs_is_mcs t))
  | imp φ₁ φ₂ ih₁ ih₂ =>
    intro t
    simp only [temporal_truth, effectiveFormula_raw]
    rw [ih₁ t, ih₂ t]
    exact (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs t) _ _).symm
  | box φ =>
    intro t
    show (priorModelAsMonadicStructure M sig atomMap_rev).interp (atomMap_fwd (.box φ)) t ↔
        atomMap_rev (atomMap_fwd (.box φ)) ∈ M.fmcs t
    simp only [priorModelAsMonadicStructure]
  | untl φ₁ φ₂ ih₁ ih₂ =>
    intro t
    simp only [temporal_truth, effectiveFormula_raw]
    constructor
    · intro ⟨s, hts, h_phi1, h_guard⟩
      have h₁ := (ih₁ s).mp h_phi1
      have h₂ : ∀ r, t < r → r < s →
          effectiveFormula_raw atomMap_rev atomMap_fwd φ₂ ∈ M.fmcs r :=
        fun r htr hrs => (ih₂ r).mp (h_guard r htr hrs)
      by_contra h_neg
      have h_neg_until : (Formula.untl (effectiveFormula_raw atomMap_rev atomMap_fwd φ₁)
          (effectiveFormula_raw atomMap_rev atomMap_fwd φ₂)).neg ∈ M.fmcs t :=
        (SetMaximalConsistent.negation_complete (M.fmcs_is_mcs t) _).resolve_left h_neg
      obtain ⟨z, htz, hzs, h_neg_guard⟩ := M.neg_until_coherent t s hts _ _ h_neg_until h₁
      exact absurd (h₂ z htz hzs)
        (SetMaximalConsistent.neg_excludes (M.fmcs_is_mcs z) _ h_neg_guard)
    · intro h_until
      obtain ⟨s, hts, h_phi1, h_guard⟩ := M.until_coherent_fwd t _ _ h_until
      exact ⟨s, hts, (ih₁ s).mpr h_phi1, fun r htr hrs => (ih₂ r).mpr (h_guard r htr hrs)⟩
  | snce φ₁ φ₂ ih₁ ih₂ =>
    intro t
    simp only [temporal_truth, effectiveFormula_raw]
    constructor
    · intro ⟨s, hst, h_phi1, h_guard⟩
      have h₁ := (ih₁ s).mp h_phi1
      have h₂ : ∀ r, s < r → r < t →
          effectiveFormula_raw atomMap_rev atomMap_fwd φ₂ ∈ M.fmcs r :=
        fun r hsr hrt => (ih₂ r).mp (h_guard r hsr hrt)
      by_contra h_neg
      have h_neg_since : (Formula.snce (effectiveFormula_raw atomMap_rev atomMap_fwd φ₁)
          (effectiveFormula_raw atomMap_rev atomMap_fwd φ₂)).neg ∈ M.fmcs t :=
        (SetMaximalConsistent.negation_complete (M.fmcs_is_mcs t) _).resolve_left h_neg
      obtain ⟨z, hsz, hzt, h_neg_guard⟩ := M.neg_since_coherent t s hst _ _ h_neg_since h₁
      exact absurd (h₂ z hsz hzt)
        (SetMaximalConsistent.neg_excludes (M.fmcs_is_mcs z) _ h_neg_guard)
    · intro h_since
      obtain ⟨s, hst, h_phi1, h_guard⟩ := M.since_coherent_fwd t _ _ h_since
      exact ⟨s, hst, (ih₁ s).mpr h_phi1, fun r hsr hrt => (ih₂ r).mpr (h_guard r hsr hrt)⟩

/-! ## Semantic Prior-UZ/SZ for PriorModelData -/

/--
Semantic Prior-UZ holds for temporal_truth on the PriorModelData monadic structure.
(Analogue of `chronicle_semantic_prior_UZ` for `PriorModelData`.)
-/
theorem semantic_prior_UZ_raw {fc : FrameClass}
    (M : PriorModelData fc) (sig : MonadicSignature)
    (atomMap_rev : sig.preds → Formula) (atomMap_fwd : Formula → sig.preds) :
    semantic_prior_UZ (priorModelAsMonadicStructure M sig atomMap_rev) atomMap_fwd := by
  intro t ψ ⟨s, hts, h_ψ_s⟩
  let eff_ψ := effectiveFormula_raw atomMap_rev atomMap_fwd ψ
  have h_eff_s : eff_ψ ∈ M.fmcs s :=
    (temporal_truth_effective_raw M sig atomMap_rev atomMap_fwd ψ s).mp h_ψ_s
  have h_F_eff : Formula.some_future eff_ψ ∈ M.fmcs t := by
    by_contra h_neg
    have h_neg_F : (Formula.some_future eff_ψ).neg ∈ M.fmcs t :=
      (SetMaximalConsistent.negation_complete (M.fmcs_is_mcs t) _).resolve_left h_neg
    simp only [Formula.some_future] at h_neg_F
    obtain ⟨z, htz, hzs, h_neg_top⟩ := M.neg_until_coherent t s hts _ _ h_neg_F h_eff_s
    have h_top : Formula.imp Formula.bot Formula.bot ∈ M.fmcs z :=
      (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs z) _ _).mpr (fun h => h)
    have h_bot : Formula.bot ∈ M.fmcs z :=
      (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs z) _ _).mp h_neg_top h_top
    exact absurd h_bot (Bimodal.Metalogic.BXCanonical.bot_not_in_mcs (M.fmcs_is_mcs z))
  have h_prior := M.prior_UZ_valid t eff_ψ
  have h_until : Formula.untl eff_ψ eff_ψ.neg ∈ M.fmcs t :=
    (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs t) _ _).mp h_prior h_F_eff
  obtain ⟨s', hts', h_eff_s', h_guard⟩ := M.until_coherent_fwd t eff_ψ eff_ψ.neg h_until
  refine ⟨s', hts', ?_, ?_⟩
  · exact (temporal_truth_effective_raw M sig atomMap_rev atomMap_fwd ψ s').mpr h_eff_s'
  · intro r htr hrs
    simp only [Formula.neg, temporal_truth]
    intro h_ψ_r
    have h_eff_r : eff_ψ ∈ M.fmcs r :=
      (temporal_truth_effective_raw M sig atomMap_rev atomMap_fwd ψ r).mp h_ψ_r
    exact absurd h_eff_r
      (SetMaximalConsistent.neg_excludes (M.fmcs_is_mcs r) _ (h_guard r htr hrs))

/--
Semantic Prior-SZ holds for temporal_truth on the PriorModelData monadic structure.
(Analogue of `chronicle_semantic_prior_SZ` for `PriorModelData`.)
-/
theorem semantic_prior_SZ_raw {fc : FrameClass}
    (M : PriorModelData fc) (sig : MonadicSignature)
    (atomMap_rev : sig.preds → Formula) (atomMap_fwd : Formula → sig.preds) :
    semantic_prior_SZ (priorModelAsMonadicStructure M sig atomMap_rev) atomMap_fwd := by
  intro t ψ ⟨s, hst, h_ψ_s⟩
  let eff_ψ := effectiveFormula_raw atomMap_rev atomMap_fwd ψ
  have h_eff_s : eff_ψ ∈ M.fmcs s :=
    (temporal_truth_effective_raw M sig atomMap_rev atomMap_fwd ψ s).mp h_ψ_s
  have h_P_eff : Formula.some_past eff_ψ ∈ M.fmcs t := by
    by_contra h_neg
    have h_neg_P : (Formula.some_past eff_ψ).neg ∈ M.fmcs t :=
      (SetMaximalConsistent.negation_complete (M.fmcs_is_mcs t) _).resolve_left h_neg
    simp only [Formula.some_past] at h_neg_P
    obtain ⟨z, hsz, hzt, h_neg_top⟩ := M.neg_since_coherent t s hst _ _ h_neg_P h_eff_s
    have h_top : Formula.imp Formula.bot Formula.bot ∈ M.fmcs z :=
      (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs z) _ _).mpr (fun h => h)
    have h_bot : Formula.bot ∈ M.fmcs z :=
      (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs z) _ _).mp h_neg_top h_top
    exact absurd h_bot (Bimodal.Metalogic.BXCanonical.bot_not_in_mcs (M.fmcs_is_mcs z))
  have h_prior := M.prior_SZ_valid t eff_ψ
  have h_since : Formula.snce eff_ψ eff_ψ.neg ∈ M.fmcs t :=
    (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs t) _ _).mp h_prior h_P_eff
  obtain ⟨s', hst', h_eff_s', h_guard⟩ := M.since_coherent_fwd t eff_ψ eff_ψ.neg h_since
  refine ⟨s', hst', ?_, ?_⟩
  · exact (temporal_truth_effective_raw M sig atomMap_rev atomMap_fwd ψ s').mpr h_eff_s'
  · intro r hsr hrt
    simp only [Formula.neg, temporal_truth]
    intro h_ψ_r
    have h_eff_r : eff_ψ ∈ M.fmcs r :=
      (temporal_truth_effective_raw M sig atomMap_rev atomMap_fwd ψ r).mp h_ψ_r
    exact absurd h_eff_r
      (SetMaximalConsistent.neg_excludes (M.fmcs_is_mcs r) _ (h_guard r hsr hrt))

/-! ## DEPRECATED: BX Pipeline Dead Code (task 225)

The definitions `no_gaps_faithful` and `prior_model_is_succ_archimedean` below are
**dead code from the BX pipeline**. `no_gaps_faithful` is provably FALSE as stated
(Z+Z counterexample: two copies of Z with constant MCS satisfy all `PriorModelData`
hypotheses yet have a Dedekind gap). The entire downstream chain

    no_gaps_faithful → prior_model_is_succ_archimedean
      → (ChronicleToCountermodel) succ_cofinal → limitDomSubtype_isSuccArchimedean
      → succ_embed_surjective → dd_countermodel_chronicle_discrete → bx_completeness

is permanently dead. The correct path to sorry-free `completeness_discrete` is
the **Reynolds pipeline** via `no_gaps_discrete` (task 202).

**Do NOT attempt to prove these definitions.** They are retained only for
downstream compilation of the general `completeness` theorem (not
`completeness_discrete`) which already carries a sorry.
-/

/-! ## No Gaps in Faithful Prior Structures (Reynolds Theorem 14) -/

/--
**No Gaps in Faithful Prior Structures** (Reynolds Theorem 14, adapted).

**WARNING**: This theorem as stated is FALSE. The Z+Z counterexample (two copies
of Z with constant MCS at every point) satisfies all `PriorModelData` hypotheses
yet has a Dedekind gap. The gap is non-definable (no temporal formula detects it),
consistent with Reynolds Theorem 5 ("no definable gaps in Prior structures").

The correct approach requires either:
(a) Strengthening `PriorModelData` with additional hypotheses (countability +
    non-trivial MCS variation), or
(b) Proving gap elimination directly inside `chronicle_gap_contradiction` using
    omega-chain properties, bypassing this abstract theorem entirely.

See task 202 plan v12 Phase 2 BLOCKER documentation for full analysis.

**sorry**: Known to be unprovable as stated. Retained for downstream compilation
while the approach is restructured.
-/
noncomputable def no_gaps_faithful {fc : FrameClass}
    (M : PriorModelData fc) : IsEmpty (Gap M.domain) := by
  sorry

/--
**Prior implies succ-archimedean** (for PriorModelData): In any `PriorModelData`,
the domain is IsSuccArchimedean. By contrapositive: NOT archimedean implies
gap exists (gap_of_not_succ_archimedean), but no_gaps_faithful says
no gaps exist. Contradiction.

Uses `gap_of_not_succ_archimedean_local` from ChronicleNoGaps.lean's
local copy, but we reproduce the key lemma inline to avoid circular imports.
-/
noncomputable def prior_model_is_succ_archimedean {fc : FrameClass}
    (M : PriorModelData fc) :
    @IsSuccArchimedean M.domain inferInstance M.domain_succ := by
  by_contra h_not_arch
  -- Set up instances so Order.succ / Order.pred resolve to M's instances
  letI : SuccOrder M.domain := M.domain_succ
  letI : PredOrder M.domain := M.domain_pred
  -- If NOT IsSuccArchimedean, then there exist a, b with a <= b and
  -- succ^[n](a) /= b for all n.
  have h_exists : ∃ a b : M.domain, a ≤ b ∧ ∀ n : Nat,
      Order.succ^[n] a ≠ b := by
    by_contra h_all
    push_neg at h_all
    exact h_not_arch ⟨fun {a b} hab => h_all a b hab⟩
  obtain ⟨a, b, hab, h_unreach⟩ := h_exists
  have h_lt : ∀ n : Nat, Order.succ^[n] a < b := by
    intro n
    induction n with
    | zero => simp; exact lt_of_le_of_ne hab (h_unreach 0)
    | succ n ih =>
      have h_le : Order.succ^[n + 1] a ≤ b := by
        rw [Function.iterate_succ']
        exact Order.succ_le_of_lt ih
      exact lt_of_le_of_ne h_le (h_unreach (n + 1))
  let cut : Set M.domain := {x | ∃ n : Nat, x ≤ Order.succ^[n] a}
  have h_gap : Nonempty (Gap M.domain) := by
    refine ⟨⟨cut, ?_, ?_, ?_, ?_, ?_⟩⟩
    · exact ⟨a, 0, le_refl a⟩
    · intro h_all
      have hb : b ∈ cut := h_all ▸ Set.mem_univ b
      obtain ⟨n, hn⟩ := hb
      exact not_le.mpr (h_lt n) hn
    · intro x y ⟨n, hx⟩ hyx
      exact ⟨n, le_trans hyx hx⟩
    · intro ⟨s, h_lub, hs⟩
      obtain ⟨n, hsn⟩ := hs
      have h_succ_in : Order.succ s ∈ cut :=
        ⟨n + 1, by rw [Function.iterate_succ']; exact Order.succ_le_succ hsn⟩
      have h_succ_gt : s < Order.succ s :=
        Order.lt_succ_of_not_isMax (not_isMax s)
      exact not_le.mpr h_succ_gt (h_lub.1 h_succ_in)
    · intro ⟨m, hm_not, hm_min⟩
      have hm_above : ∀ n : Nat, Order.succ^[n] a < m := by
        intro n
        by_contra h
        push_neg at h
        exact hm_not ⟨n, h⟩
      have h_not_min : ¬ IsMin m := by
        intro h_min
        exact not_isMin_of_lt (hm_above 0) h_min
      have h_succ_pred : Order.succ (Order.pred m) = m :=
        Order.succ_pred_of_not_isMin h_not_min
      have h_pred_in : Order.pred m ∈ cut := by
        by_contra h_pred_not
        exact not_le.mpr (Order.pred_lt_of_not_isMin h_not_min)
          (hm_min (Order.pred m) h_pred_not)
      obtain ⟨n, hn⟩ := h_pred_in
      have : m ≤ Order.succ^[n + 1] a := by
        rw [← h_succ_pred, Function.iterate_succ']
        exact Order.succ_le_succ hn
      exact not_le.mpr (hm_above (n + 1)) this
  obtain ⟨γ⟩ := h_gap
  exact (no_gaps_faithful M).elim γ

end Bimodal.Metalogic.WeakCanonical
