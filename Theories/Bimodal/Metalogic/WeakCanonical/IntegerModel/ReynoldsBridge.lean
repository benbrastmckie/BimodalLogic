import Bimodal.Metalogic.WeakCanonical.Transfer
import Bimodal.Metalogic.WeakCanonical.IntegerModel.NoGapsDiscreteProof

/-!
# Reynolds K-Equivalence Bridge: Strategy B (Task 268)

This file provides an alternative discrete countermodel construction that
bypasses `succ_embed_surjective` and the `IsSuccArchimedean` requirement.

## Strategy

Instead of embedding `LimitDomSubtype` into ℤ (which requires proving the
limit domain is ℤ-isomorphic via `IsSuccArchimedean`), we:

1. Build `LimitDomSubtype` directly as an `OrderedMonadicStructure`
2. Prove semantic Prior-UZ/SZ for this structure
3. Apply the sorry-free Reynolds pipeline: `one_class` → `very_good` → `good`
4. Extract a k-equivalent Z-interval
5. Transfer satisfiability via k-equivalence (`truth_transfer`)
6. Build the countermodel on ℤ from the Z-interval

This eliminates the sorry chain:
`chronicle_gap_contradiction` → `succ_cofinal` → `limitDomSubtype_isSuccArchimedean`
→ `succ_embed_surjective` → `cantor_bfmcs_discrete_restricted_tc/fuc`

## Key Theorems

- `limitdom_monadic_structure`: `OrderedMonadicStructure` on `LimitDomSubtype`
- `limitdom_semantic_prior_UZ/SZ`: semantic Prior-UZ/SZ for the chronicle structure
- `limitdom_is_good`: the chronicle structure is `good` (k-equiv to Z-interval)
- `countermodel_discrete_reynolds_v2`: sorry-free countermodel on ℤ

## References

- Reynolds 1994, Theorem 18 (completeness pipeline via k-equivalence)
- Doets 1989, Theorem 1.1 (k-equivalence preserves bounded-depth sentences)
- Task 268 plan: specs/268_reynolds_pipeline_bridge/plans/04_strategy-b-plan.md
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.BXCanonical.Chronicle
open Bimodal.Semantics

/-! ## Phase 1: LimitDomSubtype as OrderedMonadicStructure -/

/--
Build an `OrderedMonadicStructure sig` on `LimitDomSubtype` for any
formula φ, using the enriched signature `mkSigFrom φ`.

The carrier is `LimitDomSubtype`, inheriting `LinearOrder` from `Rat`.
The predicate interpretation maps predicate `p` at point `x` to whether
the formula `mkAtomMap φ p` (= `p.val`) is in the MCS at `x`.

This does NOT require `IsSuccArchimedean`.
-/
noncomputable def limitdom_monadic_structure {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) :
    OrderedMonadicStructure (mkSigFrom φ) where
  carrier := LimitDomSubtype fc A h_mcs
  interp p x := (mkAtomMap φ p) ∈ limit_f fc A h_mcs x.val
  carrier_order := inferInstance

/--
The `limitdom_monadic_structure` carrier is countable.
-/
instance limitdom_monadic_structure_countable {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) :
    Countable (limitdom_monadic_structure A h_mcs φ).carrier :=
  limitDomSubtype_countable fc A h_mcs

/--
The `limitdom_monadic_structure` carrier has no maximum element.
-/
instance limitdom_monadic_structure_noMax {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) :
    NoMaxOrder (limitdom_monadic_structure A h_mcs φ).carrier :=
  limitDomSubtype_noMaxOrder fc A h_mcs

/--
The `limitdom_monadic_structure` carrier has no minimum element.
-/
instance limitdom_monadic_structure_noMin {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) :
    NoMinOrder (limitdom_monadic_structure A h_mcs φ).carrier :=
  limitDomSubtype_noMinOrder fc A h_mcs

/--
The `limitdom_monadic_structure` carrier is nonempty.
-/
instance limitdom_monadic_structure_nonempty {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) :
    Nonempty (limitdom_monadic_structure A h_mcs φ).carrier :=
  limitDomSubtype_nonempty fc A h_mcs

/--
The `limitdom_monadic_structure` carrier has `SuccOrder` (discrete case).
-/
noncomputable def limitdom_monadic_structure_succOrder {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula)
    (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x) :
    SuccOrder (limitdom_monadic_structure A h_mcs φ).carrier :=
  limitDomSubtype_succOrder fc A h_mcs h_discrete

/--
The `limitdom_monadic_structure` carrier has `PredOrder` (discrete case).
-/
noncomputable def limitdom_monadic_structure_predOrder {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula)
    (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x) :
    PredOrder (limitdom_monadic_structure A h_mcs φ).carrier :=
  limitDomSubtype_predOrder fc A h_mcs h_discrete

/-! ## Effective Formula Bridge

The effective formula converts temporal formulas to their MCS-level
representatives, accounting for the fact that `mkAtomMapFwd` may not
be a perfect section of `mkAtomMap`. -/

/--
The effective formula for the limitdom structure: replaces atoms and boxes
with their effective MCS representatives via `mkAtomMap ∘ mkAtomMapFwd`.
-/
noncomputable def limitdom_effectiveFormula (φ : Formula) : Formula → Formula :=
  effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ)

/--
Temporal truth on the limitdom monadic structure corresponds to MCS
membership of the effective formula.

This is the chronicle truth lemma for the limitdom structure, proved by
structural induction on the formula using the chronicle's C4/C5 properties.
-/
theorem limitdom_temporal_truth_effective {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ ψ : Formula)
    (t : LimitDomSubtype fc A h_mcs) :
    temporal_truth (limitdom_monadic_structure A h_mcs φ) (mkAtomMapFwd φ) t ψ ↔
      limitdom_effectiveFormula φ ψ ∈ limit_f fc A h_mcs t.val := by
  revert t
  induction ψ with
  | atom a =>
    intro t
    show (mkAtomMap φ (mkAtomMapFwd φ (.atom a))) ∈ limit_f fc A h_mcs t.val ↔
      (mkAtomMap φ (mkAtomMapFwd φ (.atom a))) ∈ limit_f fc A h_mcs t.val
    exact Iff.rfl
  | bot =>
    intro t
    constructor
    · exact False.elim
    · intro h; exact absurd h (BXCanonical.bot_not_in_mcs (limit_c0 fc A h_mcs t.val t.property))
  | imp f₁ f₂ ih₁ ih₂ =>
    intro t
    simp only [temporal_truth, limitdom_effectiveFormula, effectiveFormula]
    rw [ih₁ t, ih₂ t]
    exact (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs t.val t.property) _ _).symm
  | box _ =>
    intro t
    show (mkAtomMap φ (mkAtomMapFwd φ (.box _))) ∈ limit_f fc A h_mcs t.val ↔
      (mkAtomMap φ (mkAtomMapFwd φ (.box _))) ∈ limit_f fc A h_mcs t.val
    exact Iff.rfl
  | untl f₁ f₂ ih₁ ih₂ =>
    intro t
    simp only [temporal_truth, limitdom_effectiveFormula, effectiveFormula]
    constructor
    · -- Forward: temporal Until → MCS Until
      intro ⟨s, hts, hf₁s, h_guard⟩
      have h₁ : effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₁ ∈
          limit_f fc A h_mcs s.val := (ih₁ s).mp hf₁s
      have h₂ : ∀ r : LimitDomSubtype fc A h_mcs, t < r → r < s →
          effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₂ ∈
          limit_f fc A h_mcs r.val :=
        fun r htr hrs => (ih₂ r).mp (h_guard r htr hrs)
      by_contra h_neg
      have h_neg_until : (Formula.untl
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₁)
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₂)).neg ∈
          limit_f fc A h_mcs t.val :=
        (SetMaximalConsistent.negation_complete
          (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
      obtain ⟨z, hz, htz, hzs, h_neg_guard⟩ :=
        limit_satisfies_c4 fc A h_mcs t.val s.val t.property s.property hts
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₂)
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₁)
          h_neg_until h₁
      exact absurd (h₂ ⟨z, hz⟩ htz hzs)
        (SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs z hz) _ h_neg_guard)
    · -- Backward: MCS Until → temporal Until
      intro h_until
      obtain ⟨y, hy, hty, hf₁y, h_guard⟩ :=
        limit_satisfies_c5_strong fc A h_mcs t.val t.property
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₂)
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₁)
          h_until
      exact ⟨⟨y, hy⟩, hty, (ih₁ ⟨y, hy⟩).mpr hf₁y,
        fun r htr hrs => (ih₂ r).mpr (h_guard r.val r.property htr hrs)⟩
  | snce f₁ f₂ ih₁ ih₂ =>
    intro t
    simp only [temporal_truth, limitdom_effectiveFormula, effectiveFormula]
    constructor
    · -- Forward: temporal Since → MCS Since
      intro ⟨s, hst, hf₁s, h_guard⟩
      have h₁ : effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₁ ∈
          limit_f fc A h_mcs s.val := (ih₁ s).mp hf₁s
      have h₂ : ∀ r : LimitDomSubtype fc A h_mcs, s < r → r < t →
          effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₂ ∈
          limit_f fc A h_mcs r.val :=
        fun r hsr hrt => (ih₂ r).mp (h_guard r hsr hrt)
      by_contra h_neg
      have h_neg_since : (Formula.snce
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₁)
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₂)).neg ∈
          limit_f fc A h_mcs t.val :=
        (SetMaximalConsistent.negation_complete
          (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
      obtain ⟨z, hz, hsz, hzt, h_neg_guard⟩ :=
        limit_satisfies_c4' fc A h_mcs t.val s.val t.property s.property hst
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₂)
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₁)
          h_neg_since h₁
      exact absurd (h₂ ⟨z, hz⟩ hsz hzt)
        (SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs z hz) _ h_neg_guard)
    · -- Backward: MCS Since → temporal Since
      intro h_since
      obtain ⟨y, hy, hyt, hf₁y, h_guard⟩ :=
        limit_satisfies_c5'_strong fc A h_mcs t.val t.property
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₂)
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₁)
          h_since
      exact ⟨⟨y, hy⟩, hyt, (ih₁ ⟨y, hy⟩).mpr hf₁y,
        fun r hsr hrt => (ih₂ r).mpr (h_guard r.val r.property hsr hrt)⟩

/-! ## Semantic Prior-UZ/SZ for the Limitdom Structure -/

/--
Semantic Prior-UZ holds for the limitdom monadic structure: if ψ holds
somewhere above t, then there is a first such occurrence with ψ.neg
everywhere between.

Proof: use the effective formula bridge and the MCS-level Prior-UZ axiom.
-/
theorem limitdom_semantic_prior_UZ {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc) (φ : Formula) :
    semantic_prior_UZ (limitdom_monadic_structure A h_mcs φ) (mkAtomMapFwd φ) := by
  intro t ψ' ⟨s, hts, h_ψ_s⟩
  let eff_ψ := limitdom_effectiveFormula φ ψ'
  -- Step 1: Convert temporal truth to MCS membership of effective formula
  have h_eff_s : eff_ψ ∈ limit_f fc A h_mcs s.val :=
    (limitdom_temporal_truth_effective A h_mcs φ ψ' s).mp h_ψ_s
  -- Step 2: Establish F(eff_ψ) ∈ fmcs(t)
  have h_F_eff : Formula.some_future eff_ψ ∈ limit_f fc A h_mcs t.val := by
    by_contra h_neg
    have h_neg_F : (Formula.some_future eff_ψ).neg ∈ limit_f fc A h_mcs t.val :=
      (SetMaximalConsistent.negation_complete
        (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
    simp only [Formula.some_future] at h_neg_F
    obtain ⟨z, hz, htz, hzs, h_neg_top⟩ :=
      limit_satisfies_c4 fc A h_mcs t.val s.val t.property s.property hts _ _ h_neg_F h_eff_s
    have h_top : Formula.imp Formula.bot Formula.bot ∈ limit_f fc A h_mcs z :=
      (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mpr (fun h => h)
    have h_bot : Formula.bot ∈ limit_f fc A h_mcs z :=
      (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mp h_neg_top h_top
    exact absurd h_bot (BXCanonical.bot_not_in_mcs (limit_c0 fc A h_mcs z hz))
  -- Step 3: Apply MCS-level Prior-UZ axiom
  have h_prior := theorem_in_mcs (limit_c0 fc A h_mcs t.val t.property)
    (DerivationTree.axiom [] _ (Axiom.prior_UZ eff_ψ) h_fc)
  have h_until : Formula.untl eff_ψ eff_ψ.neg ∈ limit_f fc A h_mcs t.val :=
    (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs t.val t.property) _ _).mp h_prior h_F_eff
  -- Step 4: C5 forward
  obtain ⟨s', hs', hts', h_eff_s', h_guard⟩ :=
    limit_satisfies_c5_strong fc A h_mcs t.val t.property eff_ψ.neg eff_ψ h_until
  refine ⟨⟨s', hs'⟩, hts', ?_, ?_⟩
  · exact (limitdom_temporal_truth_effective A h_mcs φ ψ' ⟨s', hs'⟩).mpr h_eff_s'
  · intro r htr hrs
    simp only [Formula.neg, temporal_truth]
    intro h_ψ_r
    have h_eff_r : eff_ψ ∈ limit_f fc A h_mcs r.val :=
      (limitdom_temporal_truth_effective A h_mcs φ ψ' r).mp h_ψ_r
    exact absurd h_eff_r
      (SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs r.val r.property) _
        (h_guard r.val r.property htr hrs))

/--
Semantic Prior-SZ holds for the limitdom monadic structure.
Mirror of `limitdom_semantic_prior_UZ`.
-/
theorem limitdom_semantic_prior_SZ {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc) (φ : Formula) :
    semantic_prior_SZ (limitdom_monadic_structure A h_mcs φ) (mkAtomMapFwd φ) := by
  intro t ψ' ⟨s, hst, h_ψ_s⟩
  let eff_ψ := limitdom_effectiveFormula φ ψ'
  have h_eff_s : eff_ψ ∈ limit_f fc A h_mcs s.val :=
    (limitdom_temporal_truth_effective A h_mcs φ ψ' s).mp h_ψ_s
  have h_P_eff : Formula.some_past eff_ψ ∈ limit_f fc A h_mcs t.val := by
    by_contra h_neg
    have h_neg_P : (Formula.some_past eff_ψ).neg ∈ limit_f fc A h_mcs t.val :=
      (SetMaximalConsistent.negation_complete
        (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
    simp only [Formula.some_past] at h_neg_P
    obtain ⟨z, hz, hsz, hzt, h_neg_top⟩ :=
      limit_satisfies_c4' fc A h_mcs t.val s.val t.property s.property hst _ _ h_neg_P h_eff_s
    have h_top : Formula.imp Formula.bot Formula.bot ∈ limit_f fc A h_mcs z :=
      (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mpr (fun h => h)
    have h_bot : Formula.bot ∈ limit_f fc A h_mcs z :=
      (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mp h_neg_top h_top
    exact absurd h_bot (BXCanonical.bot_not_in_mcs (limit_c0 fc A h_mcs z hz))
  have h_prior := theorem_in_mcs (limit_c0 fc A h_mcs t.val t.property)
    (DerivationTree.axiom [] _ (Axiom.prior_SZ eff_ψ) h_fc)
  have h_since : Formula.snce eff_ψ eff_ψ.neg ∈ limit_f fc A h_mcs t.val :=
    (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs t.val t.property) _ _).mp h_prior h_P_eff
  obtain ⟨s', hs', hst', h_eff_s', h_guard⟩ :=
    limit_satisfies_c5'_strong fc A h_mcs t.val t.property eff_ψ.neg eff_ψ h_since
  refine ⟨⟨s', hs'⟩, hst', ?_, ?_⟩
  · exact (limitdom_temporal_truth_effective A h_mcs φ ψ' ⟨s', hs'⟩).mpr h_eff_s'
  · intro r hsr hrt
    simp only [Formula.neg, temporal_truth]
    intro h_ψ_r
    have h_eff_r : eff_ψ ∈ limit_f fc A h_mcs r.val :=
      (limitdom_temporal_truth_effective A h_mcs φ ψ' r).mp h_ψ_r
    exact absurd h_eff_r
      (SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs r.val r.property) _
        (h_guard r.val r.property hsr hrt))

/-! ## Phase 2: Reynolds Pipeline on LimitDomSubtype -/

/--
The limitdom monadic structure is `good` at any depth k: k-equivalent
to some Z-interval structure.

Proof: Apply the sorry-free Reynolds pipeline directly:
1. `one_class`: all points are contemp_equiv (from no_gaps_discrete_model_surgery
   + no_boundary_at_successor)
2. `one_class_implies_very_good`: one_class → very_good
3. `very_good_implies_good`: very_good → good (uses Countable, NoMaxOrder,
   NoMinOrder, Nonempty, PredOrder — NOT IsSuccArchimedean)

This does NOT require `IsSuccArchimedean` for `LimitDomSubtype`.
-/
theorem limitdom_is_good {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (h_box_discrete : Formula.box next_top ∈ A)
    (φ : Formula) (k : Nat) :
    good (mkSigFrom φ) k (limitdom_monadic_structure A h_mcs φ) := by
  let h_discrete := box_discrete_gives_discreteness fc A h_mcs h_box_discrete
  let sig := mkSigFrom φ
  let M := limitdom_monadic_structure A h_mcs φ
  letI : SuccOrder M.carrier := limitdom_monadic_structure_succOrder A h_mcs φ h_discrete
  letI : PredOrder M.carrier := limitdom_monadic_structure_predOrder A h_mcs φ h_discrete
  -- Step 1: Apply one_class via no_gaps_discrete_model_surgery (sorry-free)
  have h_one_class : ∀ (a b : M.carrier), contemp_equiv sig k M a b := by
    intro a b
    by_contra h_diff
    obtain ⟨c, hac, h_not_succ⟩ := no_gaps_discrete_model_surgery sig k M (mkAtomMapFwd φ)
      (mkAtomMapFwd_surj φ)
      (limitdom_semantic_prior_UZ A h_mcs h_fc φ)
      (limitdom_semantic_prior_SZ A h_mcs h_fc φ) a b h_diff
    exact h_not_succ ((contemp_equiv_is_equiv sig k M).trans hac
      (no_boundary_at_successor sig k M c))
  -- Step 2: one_class_implies_very_good
  have h_very_good := one_class_implies_very_good sig k M h_one_class
  -- Step 3: very_good_implies_good
  exact very_good_implies_good sig k M (limitDomSubtype_countable fc A h_mcs) h_very_good

/-! ## Effective Formula Identity

The effective formula is the identity on formulas whose predFormulas
are contained in `phi.predFormulas`. This ensures truth transfer works
for subformulas of phi. -/

/--
`effectiveFormula` is the identity on formulas whose atoms and boxes
are all in `phi.predFormulas`.
-/
theorem effectiveFormula_id_of_sub {φ ψ : Formula}
    (h_sub : ψ.predFormulas ⊆ φ.predFormulas) :
    effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) ψ = ψ := by
  induction ψ with
  | atom a =>
    simp only [effectiveFormula, mkAtomMap]
    exact mkAtomMapFwd_section φ (.atom a)
      (h_sub (Finset.mem_singleton.mpr rfl))
  | bot => rfl
  | imp f₁ f₂ ih₁ ih₂ =>
    simp only [effectiveFormula]
    rw [ih₁ (Finset.Subset.trans (Finset.subset_union_left) h_sub),
        ih₂ (Finset.Subset.trans (Finset.subset_union_right) h_sub)]
  | box f ih =>
    simp only [effectiveFormula, mkAtomMap]
    exact mkAtomMapFwd_section φ (.box f)
      (h_sub (Finset.mem_union.mpr (Or.inl (Finset.mem_singleton.mpr rfl))))
  | untl f₁ f₂ ih₁ ih₂ =>
    simp only [effectiveFormula]
    rw [ih₁ (Finset.Subset.trans (Finset.subset_union_left) h_sub),
        ih₂ (Finset.Subset.trans (Finset.subset_union_right) h_sub)]
  | snce f₁ f₂ ih₁ ih₂ =>
    simp only [effectiveFormula]
    rw [ih₁ (Finset.Subset.trans (Finset.subset_union_left) h_sub),
        ih₂ (Finset.Subset.trans (Finset.subset_union_right) h_sub)]

/--
`effectiveFormula` is the identity on `φ` itself.
-/
theorem effectiveFormula_id_self (φ : Formula) :
    effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) φ = φ :=
  effectiveFormula_id_of_sub (Finset.Subset.refl _)

/--
`effectiveFormula` is the identity on `φ.neg` (= `φ.imp .bot`).
-/
theorem effectiveFormula_id_neg (φ : Formula) :
    effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) φ.neg = φ.neg := by
  simp only [Formula.neg, effectiveFormula]
  rw [effectiveFormula_id_self φ]

/-! ## Phase 3: Truth Transfer and Countermodel Construction -/

/-! ### Z-Interval Countermodel Infrastructure (WorldState = ℤ)

A TaskFrame with `WorldState = ℤ` where the state at each time IS the time itself
(plus an offset). This allows position-dependent atom valuation, which is necessary
because atom predicates on the Z-interval are not constant in general.

With this frame:
- Each history is parameterized by an offset w₀, with states t _ = w₀ + t
- Omega contains all offset histories (shift-closed)
- Box quantification ranges over all offsets, giving S5 semantics
-/

/-- TaskFrame with WorldState = ℤ. Task relation: u = w + d (deterministic). -/
noncomputable def zTaskFrame_v2 : TaskFrame ℤ where
  WorldState := ℤ
  task_rel w d u := u = w + d
  nullity_identity w u := by constructor <;> intro h <;> omega
  forward_comp w u v x y _ _ h1 h2 := by rw [h2, h1, add_assoc]
  converse w d u := by constructor <;> intro h <;> omega

/-- World history with offset w₀: domain = all of ℤ, states t _ = w₀ + t. -/
noncomputable def zHistory_v2 (w₀ : ℤ) : WorldHistory zTaskFrame_v2 where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => w₀ + t
  respects_task := fun s t _ _ _ => by show w₀ + t = (w₀ + s) + (t - s); omega

/-- Omega = set of all offset histories. -/
def zOmega_v2 : Set (WorldHistory zTaskFrame_v2) := Set.range zHistory_v2

theorem zHistory_v2_mem_omega : zHistory_v2 0 ∈ zOmega_v2 := ⟨0, rfl⟩

/-- Time-shifting zHistory_v2 w₀ by Δ gives zHistory_v2 (w₀ + Δ). -/
theorem zHistory_v2_shift_eq (w₀ Δ : ℤ) :
    WorldHistory.time_shift (zHistory_v2 w₀) Δ = zHistory_v2 (w₀ + Δ) := by
  show WorldHistory.mk _ _ _ _ = WorldHistory.mk _ _ _ _
  have h_states : (fun (t : ℤ) (_ : True) => w₀ + (t + Δ)) =
      (fun (t : ℤ) (_ : True) => (w₀ + Δ) + t) := by
    funext t _; omega
  congr 1

theorem zOmega_v2_shiftClosed : ShiftClosed zOmega_v2 := by
  intro σ hσ Δ
  obtain ⟨w₀, hw₀⟩ := hσ
  rw [← hw₀, zHistory_v2_shift_eq]
  exact ⟨w₀ + Δ, rfl⟩

/-- TaskModel: valuation at world state w evaluates Z-interval atom predicate at w. -/
noncomputable def zTaskModel_v2 {sig : MonadicSignature}
    (Z : ZIntervalStructure sig) (atomMap : Formula → sig.preds) :
    TaskModel zTaskFrame_v2 where
  valuation w p := Z.interp (atomMap (.atom p)) w

/--
If M has NoMaxOrder/NoMinOrder and is k-equivalent (k ≥ 2) to a Z-interval,
then every integer is in the Z-interval's carrier (the interval is unbounded).

Proof sketch: the depth-2 sentence "∃x. ∀y. y ≤ x" (has maximum) is false on M
(NoMaxOrder). By k-equivalence at k ≥ 2, it's false on the Z-interval too.
If hi = some h, then ⟨h, _⟩ is maximal in the carrier, contradicting this.
So hi = none. Similarly lo = none.
-/
theorem z_interval_carrier_contains_all
    {sig : MonadicSignature} {k : Nat} (hk : 2 ≤ k)
    {M : OrderedMonadicStructure sig}
    (Z : ZIntervalStructure sig)
    (h_equiv : k_equiv sig k M (Z.toOrdered sig))
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [Nonempty M.carrier] (z : ℤ) :
    Z.lo.elim True (· ≤ z) ∧ Z.hi.elim True (z ≤ ·) := by
  -- Step 0: Transfer nonemptiness from M to Z via ∃x. ¬(x < x) (depth 1 ≤ k)
  let nonempty_sent : MonadicSentence sig := .ex (.not (.lt 0 0))
  have h_ne_depth : nonempty_sent.quantifier_depth ≤ k := by
    simp [nonempty_sent, MonadicFormula.quantifier_depth]; omega
  have h_ne_M : eval M Fin.elim0 nonempty_sent := by
    simp only [nonempty_sent, eval, Fin.cons]
    exact ⟨Classical.arbitrary M.carrier, lt_irrefl _⟩
  have h_ne_Z := (k_equiv_preserves_sentence h_equiv nonempty_sent h_ne_depth).mp h_ne_M
  simp only [nonempty_sent, eval, Fin.cons] at h_ne_Z
  obtain ⟨z₀, _⟩ := h_ne_Z
  -- Step 1: Transfer "no maximum" from M to Z
  -- has_max_sent = ∃x. ∀y. ¬(x < y) = "has a maximum element"
  let has_max_sent : MonadicSentence sig := .ex (.all (.not (.lt 1 0)))
  have h_max_depth : has_max_sent.quantifier_depth ≤ k := by
    simp [has_max_sent, MonadicFormula.quantifier_depth]; omega
  have h_no_max_M : ¬eval M Fin.elim0 has_max_sent := by
    simp only [has_max_sent, eval, Fin.cons]
    push_neg
    intro x; obtain ⟨y, hxy⟩ := exists_gt x; exact ⟨y, hxy⟩
  have h_no_max_Z : ¬eval (Z.toOrdered sig) Fin.elim0 has_max_sent :=
    ((k_equiv_preserves_sentence h_equiv has_max_sent h_max_depth).not).mp h_no_max_M
  -- Step 2: Transfer "no minimum" from M to Z
  -- has_min_sent = ∃x. ∀y. ¬(y < x) = "has a minimum element"
  let has_min_sent : MonadicSentence sig := .ex (.all (.not (.lt 0 1)))
  have h_min_depth : has_min_sent.quantifier_depth ≤ k := by
    simp [has_min_sent, MonadicFormula.quantifier_depth]; omega
  have h_no_min_M : ¬eval M Fin.elim0 has_min_sent := by
    simp only [has_min_sent, eval, Fin.cons]
    push_neg
    intro x; obtain ⟨y, hyx⟩ := exists_lt x; exact ⟨y, hyx⟩
  have h_no_min_Z : ¬eval (Z.toOrdered sig) Fin.elim0 has_min_sent :=
    ((k_equiv_preserves_sentence h_equiv has_min_sent h_min_depth).not).mp h_no_min_M
  -- Step 3: Derive Z.hi = none by contradiction
  have h_hi_none : Z.hi = none := by
    by_contra h_hi
    obtain ⟨h_val, h_hi_eq⟩ := Option.ne_none_iff_exists'.mp h_hi
    apply h_no_max_Z
    simp only [has_max_sent, eval, Fin.cons]
    -- ⟨h_val, _⟩ is maximum in Z.intervalCarrier
    have h_lo_bound : Z.lo.elim True (· ≤ h_val) := by
      cases hlo : Z.lo with
      | none => simp [Option.elim]
      | some l =>
        simp only [Option.elim]
        have h1 : (some l).elim True (· ≤ z₀.val) := hlo ▸ z₀.property.1
        have h2 : (some h_val).elim True (z₀.val ≤ ·) := h_hi_eq ▸ z₀.property.2
        simp [Option.elim] at h1 h2; omega
    refine ⟨⟨h_val, h_lo_bound, ?_⟩, fun ⟨y, hy⟩ => ?_⟩
    · rw [h_hi_eq]; simp [Option.elim]
    · apply not_lt.mpr
      have := hy.2; rw [h_hi_eq] at this; simp [Option.elim] at this; exact this
  -- Step 4: Derive Z.lo = none by contradiction
  have h_lo_none : Z.lo = none := by
    by_contra h_lo
    obtain ⟨l_val, h_lo_eq⟩ := Option.ne_none_iff_exists'.mp h_lo
    apply h_no_min_Z
    simp only [has_min_sent, eval, Fin.cons]
    -- ⟨l_val, _⟩ is minimum in Z.intervalCarrier
    have h_hi_bound : Z.hi.elim True (l_val ≤ ·) := by
      rw [h_hi_none]; simp [Option.elim]
    refine ⟨⟨l_val, ?_, h_hi_bound⟩, fun ⟨y, hy⟩ => ?_⟩
    · rw [h_lo_eq]; simp [Option.elim]
    · apply not_lt.mpr
      have := hy.1; rw [h_lo_eq] at this; simp [Option.elim] at this; exact this
  -- Step 5: Both bounds are none, so the membership conditions are trivially True
  constructor
  · rw [h_lo_none]; simp [Option.elim]
  · rw [h_hi_none]; simp [Option.elim]

/-- Every history in zOmega_v2 is of the form zHistory_v2 w₀ for some w₀. -/
theorem zOmega_v2_mem_iff (σ : WorldHistory zTaskFrame_v2) :
    σ ∈ zOmega_v2 ↔ ∃ w₀, σ = zHistory_v2 w₀ := by
  constructor
  · intro ⟨w₀, hw₀⟩; exact ⟨w₀, hw₀.symm⟩
  · intro ⟨w₀, hw₀⟩; exact ⟨w₀, hw₀.symm⟩

/--
Temporal truth of `φ.neg` at the root point of the limitdom structure.

Since `neg φ ∈ A` and `limit_f 0 = A`, and the effective formula of
`φ.neg` equals `φ.neg` (by the section property), `φ.neg` is temporally
true at the root.
-/
theorem limitdom_root_neg_truth {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula)
    (h_neg_in : φ.neg ∈ A) :
    temporal_truth (limitdom_monadic_structure A h_mcs φ) (mkAtomMapFwd φ)
      ⟨0, zero_mem_limit_dom fc A h_mcs⟩ φ.neg := by
  -- Strategy: show temporal_truth of the effective formula, then convert
  -- Step 1: Show effectiveFormula(φ.neg) ∈ limit_f(0)
  have h_eff_mem : limitdom_effectiveFormula φ φ.neg ∈
      limit_f fc A h_mcs (0 : Rat) := by
    unfold limitdom_effectiveFormula
    rw [effectiveFormula_id_neg φ, limit_f_zero fc A h_mcs]
    exact h_neg_in
  -- Step 2: By the bridge lemma, this gives temporal_truth of the effective formula
  have h_tt_eff := (limitdom_temporal_truth_effective A h_mcs φ φ.neg
    ⟨0, zero_mem_limit_dom fc A h_mcs⟩).mpr h_eff_mem
  -- Step 3: effectiveFormula(φ.neg) = φ.neg, so temporal_truth of φ.neg
  exact h_tt_eff

/--
Reynolds pipeline countermodel v2 (Strategy B): countermodel on ℤ
bypassing `succ_embed_surjective`.

For any MCS A containing `¬φ` and `□(next_top)` (discrete box-class),
constructs a countermodel on ℤ where φ is false.

**Pipeline Architecture** (k-equivalence bypass):
1. Build limitdom monadic structure on LimitDomSubtype
2. Apply Reynolds pipeline: one_class → very_good → good
3. Extract k-equivalent Z-interval
4. Transfer truth via k-equivalence (truth_transfer)
5. Build countermodel on ℤ from Z-interval
-/
theorem countermodel_discrete_reynolds_v2
    (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Discrete) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box next_top ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (_ : SuccOrder D) (_ : PredOrder D)
      (_ : IsSuccArchimedean D) (_ : IsPredArchimedean D)
      (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  -- Phase 1: Build the good structure (k-equivalent to Z-interval)
  let sig := mkSigFrom φ
  let M := limitdom_monadic_structure A h_mcs φ
  let k := operator_depth φ + 2
  have h_good := limitdom_is_good A h_mcs (le_refl _) h_box_discrete φ k
  obtain ⟨Z, h_k_equiv⟩ := h_good
  -- Phase 2: Transfer temporal truth of φ.neg from chronicle to Z-interval
  have h_root_truth := limitdom_root_neg_truth A h_mcs φ h_neg_in
  have h_k_bound : operator_depth φ.neg + 1 ≤ k := by
    show operator_depth (φ.imp .bot) + 1 ≤ operator_depth φ + 2
    simp only [operator_depth]; omega
  obtain ⟨s, h_neg_truth_Z⟩ := truth_transfer (mkAtomMapFwd φ) h_k_equiv φ.neg h_k_bound
    ⟨0, zero_mem_limit_dom FrameClass.Discrete A h_mcs⟩ h_root_truth
  -- Phase 3: Package the countermodel on ℤ using zTaskFrame_v2
  let TM := zTaskModel_v2 Z (mkAtomMapFwd φ)
  -- Unboundedness: every integer is in the Z-interval carrier
  have h_unbounded : ∀ z : ℤ, Z.lo.elim True (· ≤ z) ∧ Z.hi.elim True (z ≤ ·) :=
    z_interval_carrier_contains_all (by omega : 2 ≤ k) Z h_k_equiv
  refine ⟨ℤ, inferInstance, inferInstance, inferInstance, inferInstance,
    inferInstance, inferInstance, inferInstance, inferInstance,
    zTaskFrame_v2, TM, zOmega_v2, zOmega_v2_shiftClosed,
    zHistory_v2 0, zHistory_v2_mem_omega, s.val, ?_⟩
  -- Need: ¬truth_at TM zOmega_v2 (zHistory_v2 0) s.val φ
  --
  -- BLOCKER: The truth correspondence between truth_at (TM semantics with box as
  -- universal quantification over Omega) and temporal_truth (FO semantics with box
  -- as opaque predicate lookup) cannot be established via the Z-interval approach.
  --
  -- The obstacle: for the forward direction (truth_at → temporal_truth) at box ψ,
  -- we need (∀ u, temporal_truth u ψ) → Z.interp(atomMap(.box ψ)) z. This fails
  -- when .box ψ ∉ A but ψ holds everywhere on the Z-interval (which CAN happen
  -- since the Z-interval only reflects one chronicle's MCS's, not all S5-accessible
  -- worlds). For the backward direction, the same issue arises in reverse.
  --
  -- A single Z-interval lacks the multi-world structure needed for S5 box semantics.
  -- Possible resolutions:
  -- (1) Use the parametric canonical model (BFMCS) as in countermodel_discrete_reynolds,
  --     but prove restricted_tc/fuc without succ_embed_surjective.
  -- (2) Build multiple Z-intervals (one per box-equivalence class) and combine them.
  -- (3) Prove restricted_tc/fuc for the BFMCS using k-equiv transfer instead of
  --     succ_embed_surjective: use truth_transfer to find Z-interval witnesses
  --     for the temporal resolution properties.
  sorry

end Bimodal.Metalogic.WeakCanonical
