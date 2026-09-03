/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Transfer
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.NoGapsDiscreteProof
import FormalSystem.Theorems.ModalDerived

/-!
# Reynolds K-Equivalence Bridge: Strategy B

This file provides an alternative discrete countermodel construction that
bypasses `succ_embed_surjective` and the `IsSuccArchimedean` requirement.

## Strategy

Instead of embedding `LimitDomSubtype` into ℤ (which requires proving the
limit domain is ℤ-isomorphic via `IsSuccArchimedean`), we:

1. Build `LimitDomSubtype` directly as an `OrderedMonadicStructure`
2. Prove semantic Prior-UZ/SZ for this structure
3. Apply the sorry-free Reynolds pipeline: `one_class` → `VeryGood` → `good`
4. Extract a k-equivalent Z-interval
5. Transfer satisfiability via k-equivalence (`truth_transfer`)
6. Build the countermodel on ℤ from the Z-interval

This eliminates the sorry chain
(archived — see `Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`):
`chronicle_gap_contradiction` → `succ_cofinal` → `limitDomSubtype_isSuccArchimedean`
→ `succ_embed_surjective` → `cantor_bfmcs_discrete_restricted_tc/fuc`

The bypass is what made that archival possible: because `completeness_discrete` routes through
`countermodel_discrete_reynolds_v2` below rather than through the chain, the whole chain was
dead and could be excised. Note that `countermodel_discrete_reynolds_v2` (this file, sorry-free)
is a different theorem from the archived, `sorryAx`-tainted `countermodel_discrete_reynolds`
that used to live in `WeakCanonical/Transfer.lean`.

## Key Theorems

- `limitdomMonadicStructure`: `OrderedMonadicStructure` on `LimitDomSubtype`
- `limitdom_semantic_prior_UZ/SZ`: semantic Prior-UZ/SZ for the chronicle structure
- `limitdom_is_good`: the chronicle structure is `good` (k-equiv to Z-interval)
- `countermodel_discrete_reynolds_v2`: multi-family Z-interval countermodel on ℤ
- `multiFamTaskFrame`: a `FrameOver intOrder` with WorldState = FamIdx × ℤ
- `toCarrier`: unbounded Z-interval carrier injection
- `predFormulas_operator_depth_le`: operator depth bound for predFormulas elements

## References

- Reynolds 1994, Theorem 18 (completeness pipeline via k-equivalence)
- Doets 1989, Theorem 1.1 (k-equivalence preserves bounded-depth sentences)
- Design provenance: the strategy-B route for the Reynolds pipeline bridge
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.BXCanonical.Chronicle
open FormalSystem.Semantics

/-! ## Phase 1: LimitDomSubtype as OrderedMonadicStructure -/

/--
Build an `OrderedMonadicStructure sig` on `LimitDomSubtype` for any
formula φ, using the enriched signature `mkSigFrom φ`.

The carrier is `LimitDomSubtype`, inheriting `LinearOrder` from `Rat`.
The predicate interpretation maps predicate `p` at point `x` to whether
the formula `mkAtomMap φ p` (= `p.val`) is in the MCS at `x`.

This does NOT require `IsSuccArchimedean`.
-/
noncomputable def limitdomMonadicStructure {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) :
    OrderedMonadicStructure (mkSigFrom φ) where
  carrier := LimitDomSubtype fc A h_mcs
  interp p x := (mkAtomMap φ p) ∈ LimitF fc A h_mcs x.val
  carrierOrder := inferInstance

/--
The `limitdomMonadicStructure` carrier is countable.
-/
instance limitdom_monadic_structure_countable {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) :
    Countable (limitdomMonadicStructure A h_mcs φ).carrier :=
  limitDomSubtype_countable fc A h_mcs

/--
The `limitdomMonadicStructure` carrier has no maximum element.
-/
instance limitdom_monadic_structure_noMax {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) :
    NoMaxOrder (limitdomMonadicStructure A h_mcs φ).carrier :=
  limitDomSubtype_noMaxOrder fc A h_mcs

/--
The `limitdomMonadicStructure` carrier has no minimum element.
-/
instance limitdom_monadic_structure_noMin {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) :
    NoMinOrder (limitdomMonadicStructure A h_mcs φ).carrier :=
  limitDomSubtype_noMinOrder fc A h_mcs

/--
The `limitdomMonadicStructure` carrier is nonempty.
-/
instance limitdom_monadic_structure_nonempty {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) :
    Nonempty (limitdomMonadicStructure A h_mcs φ).carrier :=
  limitDomSubtype_nonempty fc A h_mcs

/--
The `limitdomMonadicStructure` carrier has `SuccOrder` (discrete case).
-/
@[instance_reducible]
noncomputable def limitdomMonadicStructureSuccOrder {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :
    SuccOrder (limitdomMonadicStructure A h_mcs φ).carrier :=
  limitDomSubtypeSuccOrder fc A h_mcs h_discrete

/--
The `limitdomMonadicStructure` carrier has `PredOrder` (discrete case).
-/
@[instance_reducible]
noncomputable def limitdomMonadicStructurePredOrder {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :
    PredOrder (limitdomMonadicStructure A h_mcs φ).carrier :=
  limitDomSubtypePredOrder fc A h_mcs h_discrete

/-! ## Effective Formula Bridge

The effective formula converts temporal formulas to their MCS-level
representatives, accounting for the fact that `mkAtomMapFwd` may not
be a perfect section of `mkAtomMap`. -/

/--
The effective formula for the limitdom structure: replaces atoms and boxes
with their effective MCS representatives via `mkAtomMap ∘ mkAtomMapFwd`.
-/
noncomputable def limitdomEffectiveFormula (φ : Formula) : Formula → Formula :=
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
    TemporalTruth (limitdomMonadicStructure A h_mcs φ) (mkAtomMapFwd φ) t ψ ↔
      limitdomEffectiveFormula φ ψ ∈ LimitF fc A h_mcs t.val := by
  revert t
  induction ψ with
  | atom a =>
    intro t
    change (mkAtomMap φ (mkAtomMapFwd φ (.atom a))) ∈ LimitF fc A h_mcs t.val ↔
      (mkAtomMap φ (mkAtomMapFwd φ (.atom a))) ∈ LimitF fc A h_mcs t.val
    exact Iff.rfl
  | bot =>
    intro t
    constructor
    · exact False.elim
    · intro h; exact absurd h (SetMaximalConsistent.bot_not_mem (limit_c0 fc A h_mcs t.val t.property))
  | imp f₁ f₂ ih₁ ih₂ =>
    intro t
    simp only [TemporalTruth, limitdomEffectiveFormula, effectiveFormula]
    rw [ih₁ t, ih₂ t]
    exact (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs t.val t.property) _ _).symm
  | box _ =>
    intro t
    change (mkAtomMap φ (mkAtomMapFwd φ (.box _))) ∈ LimitF fc A h_mcs t.val ↔
      (mkAtomMap φ (mkAtomMapFwd φ (.box _))) ∈ LimitF fc A h_mcs t.val
    exact Iff.rfl
  | untl f₂ f₁ ih₂ ih₁ =>
    intro t
    simp only [TemporalTruth, limitdomEffectiveFormula, effectiveFormula]
    constructor
    · -- Forward: temporal Until → MCS Until
      intro ⟨s, hts, hf₁s, h_guard⟩
      have h₁ : effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₁ ∈
          LimitF fc A h_mcs s.val := (ih₁ s).mp hf₁s
      have h₂ : ∀ r : LimitDomSubtype fc A h_mcs, t < r → r < s →
          effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₂ ∈
          LimitF fc A h_mcs r.val :=
        fun r htr hrs => (ih₂ r).mp (h_guard r htr hrs)
      by_contra h_neg
      have h_neg_until : (Formula.untl
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₂)
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₁)).neg ∈
          LimitF fc A h_mcs t.val :=
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
  | snce f₂ f₁ ih₂ ih₁ =>
    intro t
    simp only [TemporalTruth, limitdomEffectiveFormula, effectiveFormula]
    constructor
    · -- Forward: temporal Since → MCS Since
      intro ⟨s, hst, hf₁s, h_guard⟩
      have h₁ : effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₁ ∈
          LimitF fc A h_mcs s.val := (ih₁ s).mp hf₁s
      have h₂ : ∀ r : LimitDomSubtype fc A h_mcs, s < r → r < t →
          effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₂ ∈
          LimitF fc A h_mcs r.val :=
        fun r hsr hrt => (ih₂ r).mp (h_guard r hsr hrt)
      by_contra h_neg
      have h_neg_since : (Formula.snce
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₂)
          (effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) f₁)).neg ∈
          LimitF fc A h_mcs t.val :=
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
    SemanticPriorUZ (limitdomMonadicStructure A h_mcs φ) (mkAtomMapFwd φ) := by
  intro t ψ' ⟨s, hts, h_ψ_s⟩
  let eff_ψ := limitdomEffectiveFormula φ ψ'
  -- Step 1: Convert temporal truth to MCS membership of effective formula
  have h_eff_s : eff_ψ ∈ LimitF fc A h_mcs s.val :=
    (limitdom_temporal_truth_effective A h_mcs φ ψ' s).mp h_ψ_s
  -- Step 2: Establish F(eff_ψ) ∈ fmcs(t)
  have h_F_eff : Formula.someFuture eff_ψ ∈ LimitF fc A h_mcs t.val := by
    by_contra h_neg
    have h_neg_F : (Formula.someFuture eff_ψ).neg ∈ LimitF fc A h_mcs t.val :=
      (SetMaximalConsistent.negation_complete
        (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
    simp only [Formula.someFuture] at h_neg_F
    obtain ⟨z, hz, htz, hzs, h_neg_top⟩ :=
      limit_satisfies_c4 fc A h_mcs t.val s.val t.property s.property hts _ _ h_neg_F h_eff_s
    have h_top : Formula.imp Formula.bot Formula.bot ∈ LimitF fc A h_mcs z :=
      (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mpr (fun h => h)
    have h_bot : Formula.bot ∈ LimitF fc A h_mcs z :=
      (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mp h_neg_top h_top
    exact absurd h_bot (SetMaximalConsistent.bot_not_mem (limit_c0 fc A h_mcs z hz))
  -- Step 3: Apply MCS-level Prior-UZ axiom
  have h_prior := theorem_in_mcs (limit_c0 fc A h_mcs t.val t.property)
    (DerivationTree.axiom [] _ (Axiom.prior_UZ eff_ψ) h_fc)
  have h_until : Formula.untl eff_ψ.neg eff_ψ ∈ LimitF fc A h_mcs t.val :=
    (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs t.val t.property) _ _).mp h_prior h_F_eff
  -- Step 4: C5 forward
  obtain ⟨s', hs', hts', h_eff_s', h_guard⟩ :=
    limit_satisfies_c5_strong fc A h_mcs t.val t.property eff_ψ.neg eff_ψ h_until
  refine ⟨⟨s', hs'⟩, hts', ?_, ?_⟩
  · exact (limitdom_temporal_truth_effective A h_mcs φ ψ' ⟨s', hs'⟩).mpr h_eff_s'
  · intro r htr hrs
    simp only [Formula.neg, TemporalTruth]
    intro h_ψ_r
    have h_eff_r : eff_ψ ∈ LimitF fc A h_mcs r.val :=
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
    SemanticPriorSZ (limitdomMonadicStructure A h_mcs φ) (mkAtomMapFwd φ) := by
  intro t ψ' ⟨s, hst, h_ψ_s⟩
  let eff_ψ := limitdomEffectiveFormula φ ψ'
  have h_eff_s : eff_ψ ∈ LimitF fc A h_mcs s.val :=
    (limitdom_temporal_truth_effective A h_mcs φ ψ' s).mp h_ψ_s
  have h_P_eff : Formula.somePast eff_ψ ∈ LimitF fc A h_mcs t.val := by
    by_contra h_neg
    have h_neg_P : (Formula.somePast eff_ψ).neg ∈ LimitF fc A h_mcs t.val :=
      (SetMaximalConsistent.negation_complete
        (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
    simp only [Formula.somePast] at h_neg_P
    obtain ⟨z, hz, hsz, hzt, h_neg_top⟩ :=
      limit_satisfies_c4' fc A h_mcs t.val s.val t.property s.property hst _ _ h_neg_P h_eff_s
    have h_top : Formula.imp Formula.bot Formula.bot ∈ LimitF fc A h_mcs z :=
      (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mpr (fun h => h)
    have h_bot : Formula.bot ∈ LimitF fc A h_mcs z :=
      (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mp h_neg_top h_top
    exact absurd h_bot (SetMaximalConsistent.bot_not_mem (limit_c0 fc A h_mcs z hz))
  have h_prior := theorem_in_mcs (limit_c0 fc A h_mcs t.val t.property)
    (DerivationTree.axiom [] _ (Axiom.prior_SZ eff_ψ) h_fc)
  have h_since : Formula.snce eff_ψ.neg eff_ψ ∈ LimitF fc A h_mcs t.val :=
    (BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs t.val t.property) _ _).mp h_prior h_P_eff
  obtain ⟨s', hs', hst', h_eff_s', h_guard⟩ :=
    limit_satisfies_c5'_strong fc A h_mcs t.val t.property eff_ψ.neg eff_ψ h_since
  refine ⟨⟨s', hs'⟩, hst', ?_, ?_⟩
  · exact (limitdom_temporal_truth_effective A h_mcs φ ψ' ⟨s', hs'⟩).mpr h_eff_s'
  · intro r hsr hrt
    simp only [Formula.neg, TemporalTruth]
    intro h_ψ_r
    have h_eff_r : eff_ψ ∈ LimitF fc A h_mcs r.val :=
      (limitdom_temporal_truth_effective A h_mcs φ ψ' r).mp h_ψ_r
    exact absurd h_eff_r
      (SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs r.val r.property) _
        (h_guard r.val r.property hsr hrt))

/-! ## Phase 2: Reynolds Pipeline on LimitDomSubtype -/

/--
The limitdom monadic structure is `good` at any depth k: k-equivalent
to some Z-interval structure.

Proof: Apply the sorry-free Reynolds pipeline directly:
1. `one_class`: all points are ContempEquiv (from no_gaps_discrete_model_surgery
   + no_boundary_at_successor)
2. `one_class_implies_very_good`: one_class → VeryGood
3. `very_good_implies_good`: VeryGood → good (uses Countable, NoMaxOrder,
   NoMinOrder, Nonempty, PredOrder — NOT IsSuccArchimedean)

This does NOT require `IsSuccArchimedean` for `LimitDomSubtype`.
-/
theorem limitdom_is_good {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (h_box_discrete : Formula.box nextTop ∈ A)
    (φ : Formula) (k : Nat) :
    good (mkSigFrom φ) k (limitdomMonadicStructure A h_mcs φ) := by
  let h_discrete := box_discrete_gives_discreteness fc A h_mcs h_box_discrete
  let sig := mkSigFrom φ
  let M := limitdomMonadicStructure A h_mcs φ
  letI : SuccOrder M.carrier := limitdomMonadicStructureSuccOrder A h_mcs φ h_discrete
  letI : PredOrder M.carrier := limitdomMonadicStructurePredOrder A h_mcs φ h_discrete
  -- Step 1: Apply one_class via no_gaps_discrete_model_surgery (sorry-free)
  have h_one_class : ∀ (a b : M.carrier), ContempEquiv sig k M a b := by
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
  | untl f₂ f₁ ih₂ ih₁ =>
    simp only [effectiveFormula]
    rw [ih₁ (Finset.Subset.trans (Finset.subset_union_left) h_sub),
        ih₂ (Finset.Subset.trans (Finset.subset_union_right) h_sub)]
  | snce f₂ f₁ ih₂ ih₁ =>
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

A `FrameOver intOrder` with `WorldState = ℤ` where the state at each time IS the time itself
(plus an offset). This allows position-dependent atom valuation, which is necessary
because atom predicates on the Z-interval are not constant in general.

With this frame:
- Each history is parameterized by an offset w₀, with states t _ = w₀ + t
- The frame's total-history set `H_F` is exactly the offset histories (`zHistoryV2_total_eq`)
- Box quantification ranges over all offsets, giving S5 semantics
-/

/-- Every fibre (`def:task-relation`, *Fiber* clause) of the deterministic `ℤ`-shift relation is
a subsingleton: `Fib R w x ⊆ {w + x}`. Stated on the bare relation, and **above** `zTaskFrameV2`,
so that the frame's own *Saturation* field is a citation of Helper D
(`TaskFrame.saturation_of_fib_subsingleton`) rather than an inline re-proof. -/
theorem zShiftRel_fib_subsingleton (w x : ℤ) :
    (TaskFrame.Fib (fun (w : ℤ) (d : ℤ) (u : ℤ) => u = w + d) w x).Subsingleton := by
  intro u hu u' hu'
  exact (hu : u = w + x).trans (hu' : u' = w + x).symm

/-- A `FrameOver intOrder` with WorldState = ℤ. Task relation: u = w + d (deterministic). -/
noncomputable def zTaskFrameV2 : FrameOver intOrder where
  WorldState := ℤ
  worldNonempty := inferInstanceAs (Nonempty ℤ)
  TaskRel w d u := u = w + d
  nullity_identity w u := by constructor <;> intro h <;> omega
  comp := TaskFrame.comp_of
    (fun w v x y _ _ h => ⟨w + x, rfl, by omega⟩)
    (fun w u v x y _ _ h1 h2 => by rw [h2, h1, add_assoc])
  converse w d u := by constructor <;> intro h <;> omega
  serial := fun w x _ => ⟨⟨w + x, rfl⟩, ⟨w - x, by omega⟩⟩
  limit := TaskFrame.limit_of_shift id (fun _ _ _ h => h) (fun _ _ h => by omega)
  saturation := TaskFrame.saturation_of_fib_subsingleton zShiftRel_fib_subsingleton

/-! ### `zTaskFrameV2` discharges `def:frame`'s four axioms (deterministic shift at `ℤ`)

The relation `u = w + d` is a deterministic shift whose position function is the identity, so
*Limit* is `TaskFrame.limit_of_shift` with `pos := id` and every fiber is the singleton
`{w + x}`. Unlike `multiFamTaskFrame` below, this frame's carrier is `ℤ` itself rather than a
product, so it is **not** an instance of `multiFamTaskFrameGen` and its four facts are proved
directly rather than derived. -/

/-- Every fiber (`def:task-relation`, *Fiber* clause) of `zTaskFrameV2` is a subsingleton: the
shift is deterministic, so `Fib R w x ⊆ {w + x}`. -/
theorem zTaskFrameV2_fib_subsingleton (w x : ℤ) :
    (TaskFrame.Fib zTaskFrameV2.TaskRel w x).Subsingleton :=
  zShiftRel_fib_subsingleton w x

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for `zTaskFrameV2`: the shift supplies both `w + x` and `w - x`. -/
theorem zTaskFrameV2_serial : TaskFrame.Serial zTaskFrameV2.TaskRel := by
  show ∀ (w : ℤ) (x : ℤ), 0 ≤ x → (∃ u : ℤ, u = w + x) ∧ (∃ v : ℤ, w = v + x)
  intro w x _
  exact ⟨⟨w + x, rfl⟩, ⟨w - x, by omega⟩⟩

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `zTaskFrameV2`: interpolate at the unique intermediate `w + x`. -/
theorem zTaskFrameV2_interpolates : TaskFrame.Interpolates zTaskFrameV2.TaskRel := by
  show ∀ (w v : ℤ) (x y : ℤ), 0 ≤ x → 0 ≤ y → v = w + (x + y) →
    ∃ u : ℤ, u = w + x ∧ v = u + y
  intro w v x y _ _ h
  exact ⟨w + x, rfl, by omega⟩

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for
`zTaskFrameV2`, in the literal transcribed shape, via `TaskFrame.limit_of_shift` with the
identity position function. -/
theorem zTaskFrameV2_limit :
    ∀ w u : ℤ, (∀ x, 0 < x → ∃ y, |y| < x ∧ zTaskFrameV2.TaskRel w y u) → u = w := by
  refine TaskFrame.limit_of_shift id (fun _ _ _ h => h) ?_
  show ∀ (w u : ℤ), u = w + 0 → u = w
  intro w u h
  omega

/-- *Saturation* (`def:frame#Saturation`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
$\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments") for `zTaskFrameV2`,
as the top-level predicate of record: a one-line citation of the frame's own field, which is
Helper D applied to `zShiftRel_fib_subsingleton`. -/
theorem zTaskFrameV2_saturation : TaskFrame.Saturation zTaskFrameV2.TaskRel :=
  zTaskFrameV2.saturation

/-- World history with offset w₀: domain = all of ℤ, states t _ = w₀ + t. -/
noncomputable def zHistoryV2 (w₀ : ℤ) : WorldHistory zTaskFrameV2 where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => w₀ + t
  respects_task := fun s t _ _ => by change w₀ + t = (w₀ + s) + (t - s); omega

/-- Time-shifting zHistoryV2 w₀ by Δ gives zHistoryV2 (w₀ + Δ). -/
theorem zHistory_v2_shift_eq (w₀ Δ : ℤ) :
    WorldHistory.timeShift (zHistoryV2 w₀) Δ = zHistoryV2 (w₀ + Δ) := by
  change WorldHistory.mk (PartialHistory.mk _ _ _ _) _ =
    WorldHistory.mk (PartialHistory.mk _ _ _ _) _
  have h_states : (fun (t : ℤ) (_ : True) => w₀ + (t + Δ)) =
      (fun (t : ℤ) (_ : True) => (w₀ + Δ) + t) := by
    funext t _; omega
  congr 2

/-- TaskModel: valuation at world state w evaluates Z-interval atom predicate at w. -/
noncomputable def zTaskModelV2 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (Z : ZIntervalStructure sig) (atomMap : Formula → sig.preds) :
    TaskModel zTaskFrameV2 where
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
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat} (hk : 2 ≤ k)
    {M : OrderedMonadicStructure sig}
    (Z : ZIntervalStructure sig)
    (h_equiv : KEquiv sig k M (Z.toOrdered sig))
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [Nonempty M.carrier] (z : ℤ) :
    Z.lo.elim True (· ≤ z) ∧ Z.hi.elim True (z ≤ ·) := by
  -- Step 0: Transfer nonemptiness from M to Z via ∃x. ¬(x < x) (depth 1 ≤ k)
  let nonempty_sent : MonadicSentence sig := .ex (.not (.lt 0 0))
  have h_ne_depth : nonempty_sent.quantifierDepth ≤ k := by
    simp [nonempty_sent, MonadicFormula.quantifierDepth]; omega
  have h_ne_M : eval M Fin.elim0 nonempty_sent := by
    simp only [nonempty_sent, eval, Fin.cons]
    exact ⟨Classical.arbitrary M.carrier, lt_irrefl _⟩
  have h_ne_Z := (k_equiv_preserves_sentence h_equiv nonempty_sent h_ne_depth).mp h_ne_M
  simp only [nonempty_sent, eval, Fin.cons] at h_ne_Z
  obtain ⟨z₀, _⟩ := h_ne_Z
  -- Step 1: Transfer "no maximum" from M to Z
  -- has_max_sent = ∃x. ∀y. ¬(x < y) = "has a maximum element"
  let has_max_sent : MonadicSentence sig := .ex (.all (.not (.lt 1 0)))
  have h_max_depth : has_max_sent.quantifierDepth ≤ k := by
    simp [has_max_sent, MonadicFormula.quantifierDepth]; omega
  have h_no_max_M : ¬eval M Fin.elim0 has_max_sent := by
    simp only [has_max_sent, eval, Fin.cons]
    push Not
    intro x; obtain ⟨y, hxy⟩ := exists_gt x; exact ⟨y, hxy⟩
  have h_no_max_Z : ¬eval (Z.toOrdered sig) Fin.elim0 has_max_sent :=
    ((k_equiv_preserves_sentence h_equiv has_max_sent h_max_depth).not).mp h_no_max_M
  -- Step 2: Transfer "no minimum" from M to Z
  -- has_min_sent = ∃x. ∀y. ¬(y < x) = "has a minimum element"
  let has_min_sent : MonadicSentence sig := .ex (.all (.not (.lt 0 1)))
  have h_min_depth : has_min_sent.quantifierDepth ≤ k := by
    simp [has_min_sent, MonadicFormula.quantifierDepth]; omega
  have h_no_min_M : ¬eval M Fin.elim0 has_min_sent := by
    simp only [has_min_sent, eval, Fin.cons]
    push Not
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
      have := hy.2; rw [h_hi_eq] at this; simp only [Option.elim] at this; exact this
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
      have := hy.1; rw [h_lo_eq] at this; simp only [Option.elim] at this; exact this
  -- Step 5: Both bounds are none, so the membership conditions are trivially True
  constructor
  · rw [h_lo_none]; simp [Option.elim]
  · rw [h_hi_none]; simp [Option.elim]

/-- Every total history of `zTaskFrameV2` is an offset history. Totality here is
`def:world-history`'s cut `X = D`, spelled `∀ t, σ.domain t`.

`zTaskFrameV2`'s task relation `u = w + d` is deterministic, so the state at time `0` fixes the
offset and `respects_task` propagates it to every other time. -/
theorem zHistoryV2_total_eq (σ : WorldHistory zTaskFrameV2) (htot : ∀ t, σ.domain t) :
    ∃ w₀, σ = zHistoryV2 w₀ := by
  -- `zTaskFrameV2.WorldState` is `ℤ` but not syntactically so; `show ℤ from` forces the
  -- arithmetic to elaborate in `ℤ` where `omega` can see it.
  have key : ∀ (t : ℤ) (ht : σ.domain t),
      (show ℤ from σ.states t ht) = (show ℤ from σ.states 0 (htot 0)) + t := by
    intro t ht
    have h : (show ℤ from σ.states t ht) =
        (show ℤ from σ.states 0 (htot 0)) + (t - 0) :=
      σ.respects_task 0 t (htot 0) ht
    omega
  refine ⟨σ.states 0 (htot 0), ?_⟩
  obtain ⟨⟨dom, nedom, sts, resp⟩, conv⟩ := σ
  have hdom : dom = fun _ => True :=
    funext fun t => propext ⟨fun _ => trivial, fun _ => htot t⟩
  subst hdom
  have h_states : sts = fun t (_ : True) => (show ℤ from sts 0 (htot 0)) + t :=
    funext fun t => funext fun ht => key t ht
  change WorldHistory.mk (PartialHistory.mk _ _ _ _) _ =
    WorldHistory.mk (PartialHistory.mk _ _ _ _) _
  congr 2

/-- `zTaskFrameV2`'s total-history set `H_F` (`def:world-history`: "The set of all total world
histories over $\F$ is denoted $H_{\F}$") **is** its set of offset histories.

`⊇` is definitional — `zHistoryV2` carries `domain := fun _ => True`; `⊆` is
`zHistoryV2_total_eq`. -/
theorem zHistoryV2_total_eq_range :
    {σ : WorldHistory zTaskFrameV2 | ∀ t, σ.domain t} = Set.range zHistoryV2 := by
  ext σ
  constructor
  · intro htot
    obtain ⟨w₀, rfl⟩ := zHistoryV2_total_eq σ htot
    exact ⟨w₀, rfl⟩
  · rintro ⟨w₀, rfl⟩ t
    trivial

/--
Temporal truth of `φ.neg` at the root point of the limitdom structure.

Since `neg φ ∈ A` and `LimitF 0 = A`, and the effective formula of
`φ.neg` equals `φ.neg` (by the section property), `φ.neg` is temporally
true at the root.
-/
theorem limitdom_root_neg_truth {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula)
    (h_neg_in : φ.neg ∈ A) :
    TemporalTruth (limitdomMonadicStructure A h_mcs φ) (mkAtomMapFwd φ)
      ⟨0, zero_mem_limit_dom fc A h_mcs⟩ φ.neg := by
  -- Strategy: show TemporalTruth of the effective formula, then convert
  -- Step 1: Show effectiveFormula(φ.neg) ∈ LimitF(0)
  have h_eff_mem : limitdomEffectiveFormula φ φ.neg ∈
      LimitF fc A h_mcs (0 : Rat) := by
    unfold limitdomEffectiveFormula
    rw [effectiveFormula_id_neg φ, limit_f_zero fc A h_mcs]
    exact h_neg_in
  -- Step 2: By the bridge lemma, this gives TemporalTruth of the effective formula
  have h_tt_eff := (limitdom_temporal_truth_effective A h_mcs φ φ.neg
    ⟨0, zero_mem_limit_dom fc A h_mcs⟩).mpr h_eff_mem
  -- Step 3: effectiveFormula(φ.neg) = φ.neg, so TemporalTruth of φ.neg
  exact h_tt_eff

/-- Elements of `predFormulas` have operatorDepth bounded by the root formula's
operatorDepth. This follows from the structure of predFormulas: atoms have depth 0,
box subformulas appear at strictly lower depth, and union preserves the bound. -/
theorem predFormulas_operator_depth_le (φ : Formula) :
    ∀ f ∈ φ.predFormulas, operatorDepth f ≤ operatorDepth φ := by
  induction φ with
  | atom a =>
    intro f hf
    simp only [Formula.predFormulas, Finset.mem_singleton] at hf
    subst hf; rfl
  | bot =>
    intro f hf; simp [Formula.predFormulas] at hf
  | imp ψ₁ ψ₂ ih₁ ih₂ =>
    intro f hf
    simp only [Formula.predFormulas, Finset.mem_union] at hf
    rcases hf with hf₁ | hf₂
    · exact le_trans (ih₁ f hf₁) (le_max_left _ _)
    · exact le_trans (ih₂ f hf₂) (le_max_right _ _)
  | box ψ ih =>
    intro f hf
    simp only [Formula.predFormulas, Finset.mem_union, Finset.mem_singleton] at hf
    rcases hf with rfl | hf
    · exact le_rfl
    · exact Nat.le_succ_of_le (ih f hf)
  | untl ψ₂ ψ₁ ih₂ ih₁ =>
    intro f hf
    simp only [Formula.predFormulas, Finset.mem_union] at hf
    rcases hf with hf₁ | hf₂
    · have := ih₁ f hf₁; simp only [operatorDepth]; omega
    · have := ih₂ f hf₂; simp only [operatorDepth]; omega
  | snce ψ₂ ψ₁ ih₂ ih₁ =>
    intro f hf
    simp only [Formula.predFormulas, Finset.mem_union] at hf
    rcases hf with hf₁ | hf₂
    · have := ih₁ f hf₁; simp only [operatorDepth]; omega
    · have := ih₂ f hf₂; simp only [operatorDepth]; omega

/-! ## Multi-Family Z-Interval Infrastructure

The multi-family approach resolves the box semantics mismatch:
- `TemporalTruth(.box ψ)` = opaque predicate lookup on each Z-interval
- `TruthAt(.box ψ)` = universal quantification over the frame's total histories `H_F`

By using one Z-interval per box-equivalent MCS family, `H_F` comprises
histories for all families × all offsets (`multiFam_total_eq_range`), so the universal
quantification ranges over all families and offsets. The truth correspondence then
relates `TruthAt(.box ψ)` to whether `.box ψ ∈ A`, which equals
`Z.interp(atomMap(.box ψ)) z` by the constancy of box predicates on Z-intervals.
-/

/-- Convert a raw integer to a Z-interval carrier element when the interval is
unbounded (lo = none, hi = none). -/
noncomputable def toCarrier {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {Z : ZIntervalStructure sig}
    (h_lo : Z.lo = none) (h_hi : Z.hi = none) (z : ℤ) : Z.intervalCarrier :=
  ⟨z, by rw [h_lo, h_hi]; exact ⟨trivial, trivial⟩⟩

/-- Every fibre of the deterministic family-indexed `ℤ`-shift relation is a subsingleton.
Stated on the bare relation, and **above** `multiFamTaskFrame`, so that the frame's own
*Saturation* field is a citation of Helper D. -/
theorem famShiftRel_fib_subsingleton (FamIdx : Type) (w : FamIdx × ℤ) (x : ℤ) :
    (TaskFrame.Fib (fun (p : FamIdx × ℤ) (d : ℤ) (q : FamIdx × ℤ) =>
      p.1 = q.1 ∧ q.2 = p.2 + d) w x).Subsingleton := by
  rintro u ⟨hu₁, hu₂⟩ u' ⟨hu'₁, hu'₂⟩
  exact Prod.ext (hu₁.symm.trans hu'₁) (hu₂.trans hu'₂.symm)

/-- A `FrameOver intOrder` with `WorldState = FamIdx × ℤ`. Each world state is a family index
paired with a position. The task relation is deterministic: stepping by `d` from
`(f, z)` reaches `(f, z + d)` (same family, shifted position). -/
noncomputable def multiFamTaskFrame (FamIdx : Type) [Nonempty FamIdx] : FrameOver intOrder where
  WorldState := FamIdx × ℤ
  worldNonempty := inferInstance
  TaskRel := fun p d q => p.1 = q.1 ∧ q.2 = p.2 + d
  nullity_identity := fun p q => by
    constructor
    · rintro ⟨h1, h2⟩; ext <;> [exact h1; omega]
    · rintro h; subst h; exact ⟨rfl, by omega⟩
  comp := TaskFrame.comp_of
    (fun w v x y _ _ h => ⟨(w.1, w.2 + x), ⟨rfl, rfl⟩, h.1, by omega⟩)
    (fun _ _ _ _ _ _ _ ⟨h1, h2⟩ ⟨h3, h4⟩ => ⟨h1.trans h3, by omega⟩)
  converse := fun _ _ _ => by constructor <;> (rintro ⟨h1, h2⟩; exact ⟨h1.symm, by omega⟩)
  serial := fun w x _ =>
    ⟨⟨(w.1, w.2 + x), rfl, rfl⟩, ⟨(w.1, w.2 - x), rfl, by omega⟩⟩
  limit :=
    TaskFrame.limit_of_shift Prod.snd (fun _ _ _ h => h.2)
      (fun w u h => Prod.ext h.1.symm (by omega))
  saturation := TaskFrame.saturation_of_fib_subsingleton (famShiftRel_fib_subsingleton FamIdx)

/-! ### `multiFamTaskFrame` discharges `def:frame`'s four axioms (by specialization)

`multiFamTaskFrame FamIdx` and `multiFamTaskFrameGen ℤ FamIdx` (`FlowFrame.lean`) have the same
carrier `FamIdx × ℤ` and the same task relation, and their remaining fields are `Prop`s, so the
two frames are **definitionally equal** — `multiFamTaskFrame FamIdx = multiFamTaskFrameGen
intOrder FamIdx` holds by `rfl`, both being values of the fibre `FrameOver intOrder`. The four axiom facts are therefore *derived* from the generic frame's,
not re-proved: `multiFamTaskFrameGen_serial` and its siblings apply directly. -/

/-- The `ℤ` multi-family frame is definitionally the generic flow frame at the `ℤ` fibre. -/
theorem multiFamTaskFrame_eq_gen (FamIdx : Type) [Nonempty FamIdx] :
    multiFamTaskFrame FamIdx = Algebraic.multiFamTaskFrameGen intOrder FamIdx := rfl

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for `multiFamTaskFrame`, by specialization of
`multiFamTaskFrameGen_serial`. -/
theorem multiFamTaskFrame_serial (FamIdx : Type) [Nonempty FamIdx] :
    TaskFrame.Serial (multiFamTaskFrame FamIdx).TaskRel :=
  Algebraic.multiFamTaskFrameGen_serial

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `multiFamTaskFrame`, by specialization of
`multiFamTaskFrameGen_interpolates`. -/
theorem multiFamTaskFrame_interpolates (FamIdx : Type) [Nonempty FamIdx] :
    TaskFrame.Interpolates (multiFamTaskFrame FamIdx).TaskRel :=
  Algebraic.multiFamTaskFrameGen_interpolates

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for
`multiFamTaskFrame`, in the literal transcribed shape, by specialization of
`multiFamTaskFrameGen_limit` at `D := intOrder`. Nontriviality is `intOrder`'s own field, so
nothing has to be synthesized for it. -/
theorem multiFamTaskFrame_limit (FamIdx : Type) [Nonempty FamIdx] :
    ∀ w u : FamIdx × ℤ,
      (∀ x, 0 < x → ∃ y, |y| < x ∧ (multiFamTaskFrame FamIdx).TaskRel w y u) → u = w :=
  Algebraic.multiFamTaskFrameGen_limit (D := intOrder)

/-- *Saturation* (`def:frame#Saturation`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
$\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments") for
`multiFamTaskFrame`, by specialization of `multiFamTaskFrameGen_saturation`. -/
theorem multiFamTaskFrame_saturation (FamIdx : Type) [Nonempty FamIdx] :
    TaskFrame.Saturation (multiFamTaskFrame FamIdx).TaskRel :=
  Algebraic.multiFamTaskFrameGen_saturation

/-- World history for the multi-family frame, parameterized by a family index
and a base offset. The history visits states `(f, w₀ + t)` at each time `t`. -/
noncomputable def multiFamHistory {FamIdx : Type} [Nonempty FamIdx] (f : FamIdx) (w₀ : ℤ) :
    WorldHistory (multiFamTaskFrame FamIdx) where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => (f, w₀ + t)
  respects_task := fun s t _ _ => by
    change (f, w₀ + s).1 = (f, w₀ + t).1 ∧ (f, w₀ + t).2 = (f, w₀ + s).2 + (t - s)
    exact ⟨rfl, by omega⟩

/-- Time-shifting `multiFamHistory f w₀` by `Δ` gives `multiFamHistory f (w₀ + Δ)`. -/
theorem multiFamHistory_shift_eq {FamIdx : Type} [Nonempty FamIdx] (f : FamIdx) (w₀ Δ : ℤ) :
    WorldHistory.timeShift (multiFamHistory f w₀ : WorldHistory (multiFamTaskFrame FamIdx)) Δ =
      multiFamHistory f (w₀ + Δ) := by
  change WorldHistory.mk (PartialHistory.mk _ _ _ _) _ =
    WorldHistory.mk (PartialHistory.mk _ _ _ _) _
  have h_states : (fun (t : ℤ) (_ : True) => (f, w₀ + (t + Δ))) =
      (fun (t : ℤ) (_ : True) => (f, (w₀ + Δ) + t)) := by
    funext t _; congr 1; omega
  congr 2

/-- Every family line is total (`def:world-history`'s cut `X = D`, spelled `∀ t, σ.domain t`).
Definitional: `multiFamHistory` carries `domain := fun _ => True`. This is the `ℤ` counterpart
of `bundleFlowHistory_total` (`FlowFrame.lean`), and is what the totality-targeted box clause
(`def:BL-semantics`, "for all $\sigma \in H_{\F}$") consumes. -/
theorem multiFamHistory_total {FamIdx : Type} [Nonempty FamIdx] (f : FamIdx) (w₀ : ℤ) :
    (multiFamHistory f w₀ : WorldHistory (multiFamTaskFrame FamIdx)).IsTotal :=
  fun _ => trivial

/-- Every total history of the multi-family frame is a family line. Totality is
`def:world-history`'s cut `X = D`, spelled `∀ t, σ.domain t`.

`multiFamTaskFrame`'s task relation is deterministic (same family, position shifted by `d`), so
the state at time `0` fixes both the family index and the offset, and `respects_task` propagates
them to every other time. This is the `ℤ` specialization of `multiFamGen_total_eq`
(`FlowFrame.lean`), reproved here because the two frames are separate definitions. -/
theorem multiFam_total_eq {FamIdx : Type} [Nonempty FamIdx]
    (σ : WorldHistory (multiFamTaskFrame FamIdx)) (htot : ∀ t, σ.domain t) :
    ∃ f w₀, σ = multiFamHistory f w₀ := by
  have key : ∀ (t : ℤ) (ht : σ.domain t),
      σ.states t ht = ((σ.states 0 (htot 0)).1, (σ.states 0 (htot 0)).2 + t) := by
    intro t ht
    obtain ⟨h₁, h₂⟩ : (σ.states 0 (htot 0)).1 = (σ.states t ht).1 ∧
        (σ.states t ht).2 = (σ.states 0 (htot 0)).2 + (t - 0) :=
      σ.respects_task 0 t (htot 0) ht
    refine Prod.ext h₁.symm ?_
    show (σ.states t ht).2 = (σ.states 0 (htot 0)).2 + t
    omega
  refine ⟨(σ.states 0 (htot 0)).1, (σ.states 0 (htot 0)).2, ?_⟩
  obtain ⟨⟨dom, nedom, sts, resp⟩, conv⟩ := σ
  have hdom : dom = fun _ => True :=
    funext fun t => propext ⟨fun _ => trivial, fun _ => htot t⟩
  subst hdom
  have h_states : sts = fun t (_ : True) =>
      ((sts 0 (htot 0)).1, (sts 0 (htot 0)).2 + t) :=
    funext fun t => funext fun ht => key t ht
  change WorldHistory.mk (PartialHistory.mk _ _ _ _) _ =
    WorldHistory.mk (PartialHistory.mk _ _ _ _) _
  congr 2

/-- The multi-family frame's total-history set `H_F` (`def:world-history`: "The set of all total
world histories over $\F$ is denoted $H_{\F}$") **is** its set of family lines.

`⊇` is definitional — `multiFamHistory` carries `domain := fun _ => True`; `⊆` is
`multiFam_total_eq`. This is the `ℤ` case of the generic `multiFamGen_total_eq_range`
(`FlowFrame.lean`). -/
theorem multiFam_total_eq_range (FamIdx : Type) [Nonempty FamIdx] :
    {σ : WorldHistory (multiFamTaskFrame FamIdx) | ∀ t, σ.domain t} =
      Set.range (fun (p : FamIdx × ℤ) => multiFamHistory p.1 p.2) := by
  ext σ
  constructor
  · intro htot
    obtain ⟨f, w₀, rfl⟩ := multiFam_total_eq σ htot
    exact ⟨⟨f, w₀⟩, rfl⟩
  · rintro ⟨⟨f, w₀⟩, rfl⟩ t
    trivial

/--
Reynolds pipeline countermodel v2 (Strategy B): countermodel on ℤ
bypassing `succ_embed_surjective`.

For any MCS A containing `¬φ` and `□(nextTop)` (discrete box-class),
constructs a countermodel on ℤ where φ is false.

Uses the multi-family Z-interval approach: one Z-interval per box-equivalent
MCS family, with `WorldState = FamIdx × ℤ`. Box quantification ranges over
all families (via `H_F` comprising all family×offset histories), resolving
the single-Z-interval box semantics mismatch.

The key insight: `TruthAt(.box ψ)` quantifies over all total histories,
which includes all families. By the S5 box-equivalence structure, `.box ψ ∈ A`
iff `.box ψ ∈ N` for every box-equivalent MCS N. The box predicate on each
Z-interval is constant (inherited from the chronicle's S5 structure via
k-equivalence). So the universal quantification over families matches the
box predicate lookup.
-/
theorem countermodel_discrete_reynolds_v2
    (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Discrete) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box nextTop ∈ A) :
    ∃ (F : TaskFrame) (_ : SuccOrder ↑F.Duration) (_ : PredOrder ↑F.Duration)
      (_ : IsSuccArchimedean ↑F.Duration) (_ : IsPredArchimedean ↑F.Duration)
      (TM : TaskModel F) (τ : WorldHistory F) (_ : τ.IsTotal) (t : ↑F.Duration),
      ¬TruthAt TM τ t φ := by
  -- === Multi-Family Z-Interval Approach (bypasses chronicle_gap_contradiction) ===
  --
  -- FamIdx: type of box-equivalent MCSes (one per S5 accessibility class)
  let FamIdx := {N : Set Formula // SetMaximalConsistent (fc := FrameClass.Discrete) N ∧
    Formula.box nextTop ∈ N ∧ (∀ ψ, Formula.box ψ ∈ A ↔ Formula.box ψ ∈ N)}
  -- Root family: A itself
  let f₀ : FamIdx := ⟨A, h_mcs, h_box_discrete, fun _ => Iff.rfl⟩
  -- The root family inhabits the index, discharging `multiFamTaskFrame`'s carrier nonemptiness.
  haveI : Nonempty FamIdx := ⟨f₀⟩
  -- Signature and depth
  let sig := mkSigFrom φ
  let k := operatorDepth φ + 2
  -- For each family f, build a limitdom and extract a Z-interval via limitdom_is_good
  have h_fam_good : ∀ (f : FamIdx), good sig k
      (limitdomMonadicStructure f.val f.property.1 φ) := by
    intro ⟨N, hN_mcs, hN_box, _⟩
    exact limitdom_is_good N hN_mcs (le_refl _) hN_box φ k
  -- Extract Z-intervals via Classical.choice
  let getZ : FamIdx → ZIntervalStructure sig := fun f =>
    (h_fam_good f).choose
  have h_k_equiv : ∀ f, KEquiv sig k (limitdomMonadicStructure f.val f.property.1 φ)
      ((getZ f).toOrdered sig) :=
    fun f => (h_fam_good f).choose_spec
  -- Z-intervals are unbounded (lo = none, hi = none)
  have h_bounds : ∀ f (z : ℤ), (getZ f).lo.elim True (· ≤ z) ∧
      (getZ f).hi.elim True (z ≤ ·) := by
    intro f z
    exact z_interval_carrier_contains_all (by omega : 2 ≤ k) (getZ f) (h_k_equiv f) z
  have h_lo : ∀ f, (getZ f).lo = none := by
    intro f
    by_contra h
    obtain ⟨l, hl⟩ := Option.ne_none_iff_exists'.mp h
    have h1 := (h_bounds f (l - 1)).1
    rw [hl] at h1; simp only [Option.elim] at h1; omega
  have h_hi : ∀ f, (getZ f).hi = none := by
    intro f
    by_contra h
    obtain ⟨u, hu⟩ := Option.ne_none_iff_exists'.mp h
    have h1 := (h_bounds f (u + 1)).2
    rw [hu] at h1; simp only [Option.elim] at h1; omega
  -- Build TaskModel: valuation at (f, z) evaluates Z_f's atom predicate at z
  let TM : TaskModel (multiFamTaskFrame FamIdx) :=
    { valuation := fun w atom =>
        (getZ w.1).interp (mkAtomMapFwd φ (.atom atom)) w.2 }
  -- Get TemporalTruth(φ.neg) at root on limitdom, then transfer to Z-interval
  have h_root_neg : TemporalTruth (limitdomMonadicStructure A h_mcs φ) (mkAtomMapFwd φ)
      ⟨0, zero_mem_limit_dom FrameClass.Discrete A h_mcs⟩ φ.neg :=
    limitdom_root_neg_truth A h_mcs φ h_neg_in
  have h_k_bound : operatorDepth φ.neg + 1 ≤ k := by
    simp only [k, Formula.neg, operatorDepth]; omega
  obtain ⟨s₀, h_neg_s₀⟩ := truth_transfer (mkAtomMapFwd φ) (h_k_equiv f₀) φ.neg
    h_k_bound ⟨0, zero_mem_limit_dom FrameClass.Discrete A h_mcs⟩ h_root_neg
  -- Truth correspondence: TruthAt on multi-family ↔ TemporalTruth on Z_f
  -- Proved by structural induction on formula, restricted to formulas whose
  -- predFormulas are contained in φ.predFormulas (needed for the box case)
  suffices h_truth_corr : ∀ (ψ : Formula) (h_sub : ψ.predFormulas ⊆ φ.predFormulas)
      (f : FamIdx) (w₀ : ℤ) (t : ℤ),
      TruthAt TM (multiFamHistory f w₀) t ψ ↔
        TemporalTruth ((getZ f).toOrdered sig) (mkAtomMapFwd φ)
          (toCarrier (h_lo f) (h_hi f) (w₀ + t)) ψ by
    -- Package the existential
    refine ⟨(multiFamTaskFrame FamIdx).toTaskFrame,
      inferInstance, inferInstance, inferInstance, inferInstance, TM,
      multiFamHistory f₀ 0, multiFamHistory_total f₀ 0,
      s₀.val, ?_⟩
    intro h_truth_phi
    have h_corr := (h_truth_corr φ (Finset.Subset.refl _) f₀ 0 s₀.val).mp h_truth_phi
    -- toCarrier (0 + s₀.val) = toCarrier s₀.val; and s₀ = toCarrier s₀.val
    have h_eq : toCarrier (h_lo f₀) (h_hi f₀) (0 + s₀.val) = s₀ :=
      Subtype.ext (by simp only [toCarrier]; omega)
    rw [h_eq] at h_corr
    exact h_neg_s₀ h_corr
  -- Prove truth correspondence by structural induction
  intro ψ h_sub f w₀ t
  induction ψ generalizing f w₀ t with
  | atom a =>
    -- TruthAt(.atom a) = ∃ ht, TM.valuation (states t ht) a
    -- Both sides reduce to Z_f.interp(atomMap(.atom a))(toCarrier(w₀+t))
    -- LHS: ∃ ht, (getZ f).interp ... (toCarrier (w₀+t)) [via TM def + multiFamHistory.states]
    -- RHS: (getZ f).interp ... (toCarrier (w₀+t)) [via TemporalTruth def]
    simp only [TruthAt, TemporalTruth, multiFamHistory, TM]
    exact ⟨fun ⟨_, h⟩ => h, fun h => ⟨trivial, h⟩⟩
  | bot =>
    simp only [TruthAt, TemporalTruth]
  | imp ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [TruthAt, TemporalTruth]
    exact Iff.imp
      (ih₁ (Finset.Subset.trans Finset.subset_union_left h_sub) f w₀ t)
      (ih₂ (Finset.Subset.trans Finset.subset_union_right h_sub) f w₀ t)
  | box ψ ih =>
    -- Box case: TruthAt(.box ψ) = ∀ σ, σ.IsTotal → TruthAt σ t ψ
    -- h_sub : (.box ψ).predFormulas ⊆ φ.predFormulas
    -- This gives: ψ.predFormulas ⊆ φ.predFormulas and .box ψ ∈ φ.predFormulas
    have h_sub_ψ : ψ.predFormulas ⊆ φ.predFormulas :=
      Finset.Subset.trans Finset.subset_union_right h_sub
    simp only [TruthAt]
    constructor
    · -- Forward: (∀ σ, σ.IsTotal → TruthAt σ t ψ) → TemporalTruth (.box ψ)
      intro h_all
      -- Convert to: ∀ f' z, TemporalTruth Z_{f'} atomMap (toCarrier z) ψ
      have h_univ : ∀ (f' : FamIdx) (z : ℤ),
          TemporalTruth ((getZ f').toOrdered sig) (mkAtomMapFwd φ)
            (toCarrier (h_lo f') (h_hi f') z) ψ := by
        intro f' z
        have h_tot : (multiFamHistory f' (z - t)).IsTotal :=
          multiFamHistory_total f' (z - t)
        have h_ta := h_all (multiFamHistory f' (z - t)) h_tot
        rw [ih h_sub_ψ f' (z - t) t] at h_ta
        have h_eq : z - t + t = z := by omega
        rw [h_eq] at h_ta
        exact h_ta
      -- Need: h_univ → box pred True on Z_f
      -- Step A: Transfer TemporalTruth on each Z_{f'} back to MCS membership
      have h_ψ_in_all : ∀ (f' : FamIdx), ψ ∈ f'.val := by
        intro f'
        -- h_univ f' gives: ∀ z, TemporalTruth Z_{f'} atomMap (toCarrier z) ψ
        -- Transfer to limitdom via k-equiv reverse
        -- Step A1: ∀x.table(ψ)(x) on Z_{f'}
        have h_all_table_Z : eval ((getZ f').toOrdered sig) Fin.elim0
            (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)) := by
          simp only [eval]
          intro x
          have h_env : Fin.cons x Fin.elim0 = (fun (_ : Fin 1) => x) := by
            funext i; fin_cases i; rfl
          rw [h_env]
          exact (table_correctness ((getZ f').toOrdered sig) (mkAtomMapFwd φ) x ψ).mpr
            (h_univ f' x.val)
        -- Step A2: k-equiv reverse transfer to limitdom_{f'}
        have h_box_depth : operatorDepth (.box ψ) ≤ operatorDepth φ :=
          predFormulas_operator_depth_le φ (.box ψ)
            (h_sub (Finset.mem_union.mpr (Or.inl (Finset.mem_singleton.mpr rfl))))
        have h_depth_all : (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)).quantifierDepth ≤
            k := by
          simp only [MonadicFormula.quantifierDepth, k, operatorDepth] at h_box_depth ⊢
          exact Nat.succ_le_of_lt (Nat.lt_of_le_of_lt (table_depth_bound sig (mkAtomMapFwd φ) ψ)
            (by omega))
        have h_all_table_lim : eval (limitdomMonadicStructure f'.val f'.property.1 φ) Fin.elim0
            (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)) :=
          ((k_equiv_preserves_sentence (h_k_equiv f') _ h_depth_all).symm).mp h_all_table_Z
        -- Step A3: Unpack → ∀ x, TemporalTruth on limitdom
        simp only [eval] at h_all_table_lim
        -- Step A4: At the root point 0, get ψ ∈ LimitF(0) = N_{f'}
        have h_tt_root : TemporalTruth (limitdomMonadicStructure f'.val f'.property.1 φ)
            (mkAtomMapFwd φ) ⟨0, zero_mem_limit_dom FrameClass.Discrete f'.val f'.property.1⟩
                ψ := by
          have h_eval := h_all_table_lim ⟨0, zero_mem_limit_dom FrameClass.Discrete f'.val
              f'.property.1⟩
          have h_env : Fin.cons ⟨0, zero_mem_limit_dom FrameClass.Discrete f'.val f'.property.1⟩
              Fin.elim0 =
              (fun (_ : Fin 1) => (⟨0, zero_mem_limit_dom FrameClass.Discrete f'.val
                  f'.property.1⟩ :
                (limitdomMonadicStructure f'.val f'.property.1 φ).carrier)) := by
            funext i; fin_cases i; rfl
          -- `rw … at` no longer matches the `Fin.cons` application: its implicit motive
          -- in `h_env` (inferred from the `fun _ => x` right-hand side) differs from the
          -- one `eval` produced, and the two are only definitionally equal. `▸` transports
          -- at `default` transparency and is unaffected. (Lean 4.31.)
          replace h_eval := h_env ▸ h_eval
          exact (table_correctness (limitdomMonadicStructure f'.val f'.property.1 φ)
            (mkAtomMapFwd φ) _ ψ).mp h_eval
        -- Step A5: By limitdom_temporal_truth_effective + effectiveFormula_id
        have h_eff_mem : limitdomEffectiveFormula φ ψ ∈
            LimitF FrameClass.Discrete f'.val f'.property.1 0 :=
          (limitdom_temporal_truth_effective f'.val f'.property.1 φ ψ _).mp h_tt_root
        simp only [limitdomEffectiveFormula] at h_eff_mem
        rw [effectiveFormula_id_of_sub h_sub_ψ, limit_f_zero] at h_eff_mem
        exact h_eff_mem
      -- Step B: ψ ∈ all N_{f'} → .box ψ ∈ A (contrapositive via bx_modal_witness_fc)
      have h_box_in_A : Formula.box ψ ∈ A := by
        by_contra h_not_box
        have h_neg_box : (Formula.box ψ).neg ∈ A :=
          (SetMaximalConsistent.negation_complete h_mcs (Formula.box ψ)).resolve_left h_not_box
        have h_diamond_neg : (Formula.neg ψ).diamond ∈ A :=
          FormalSystem.Metalogic.Core.SetMaximalConsistent.contrapositive h_mcs
            (liftBase FrameClass.Discrete (FormalSystem.Theorems.ModalDerived.boxDneTheorem ψ)) h_neg_box
        obtain ⟨v, h_v_mcs, h_v_equiv, h_neg_ψ_v⟩ :=
          bx_modal_witness_fc h_mcs (Formula.neg ψ) h_diamond_neg
        -- v is box-equiv to A, so □(nextTop) ∈ v
        have h_box_disc_v : Formula.box nextTop ∈ v :=
          (h_v_equiv nextTop).mp h_box_discrete
        -- v is a FamIdx element
        let fv : FamIdx := ⟨v, h_v_mcs, h_box_disc_v, h_v_equiv⟩
        -- h_ψ_in_all gives ψ ∈ v
        have h_ψ_v : ψ ∈ v := h_ψ_in_all fv
        -- Contradiction: ψ and ψ.neg both in v
        exact set_consistent_not_both h_v_mcs.1 ψ h_ψ_v h_neg_ψ_v
      -- Step C: .box ψ ∈ A → box pred True on Z_f
      -- Box-equiv: .box ψ ∈ A → .box ψ ∈ N_f
      have h_box_in_N : Formula.box ψ ∈ f.val := (f.property.2.2 ψ).mp h_box_in_A
      -- Box stability: .box ψ ∈ limit_f_f(x) for all x
      -- → limitdom interp of mkAtomMapFwd(.box ψ) is True everywhere on limitdom_f
      -- → FO sentence ∀x.P_{.box ψ}(x) true on limitdom_f
      -- → k-equiv → true on Z_f → (getZ f).interp(atomMap(.box ψ)) z for all z
      change TemporalTruth ((getZ f).toOrdered sig) (mkAtomMapFwd φ)
          (toCarrier (h_lo f) (h_hi f) (w₀ + t)) (.box ψ)
      simp only [TemporalTruth]
      -- Goal: (getZ f).toOrdered sig).interp (mkAtomMapFwd φ (.box ψ)) (toCarrier ...)
      -- = (getZ f).interp (mkAtomMapFwd φ (.box ψ)) (w₀ + t)
      -- Need to show this from h_box_in_N via box_stable + k-equiv transfer
      have h_all_pred_lim : ∀ (x : (limitdomMonadicStructure f.val f.property.1 φ).carrier),
          (limitdomMonadicStructure f.val f.property.1 φ).interp
            (mkAtomMapFwd φ (.box ψ)) x := by
        intro ⟨q, hq⟩
        -- limitdomMonadicStructure.interp p x = mkAtomMap φ p ∈ LimitF fc N_f h_mcs x
        -- mkAtomMap φ (mkAtomMapFwd φ (.box ψ)) = .box ψ (if .box ψ ∈ φ.predFormulas)
        -- Actually, mkAtomMap maps predicates to formulas, and mkAtomMapFwd maps
        -- formulas to predicates
        -- (limitdomMonadicStructure f.val f.property.1 φ).interp (mkAtomMapFwd φ (.box ψ)) ⟨q,
        -- hq⟩
        -- = (mkAtomMap φ (mkAtomMapFwd φ (.box ψ))) ∈ LimitF fc f.val f.property.1 q
        -- = effectiveFormula (mkAtomMap φ) (mkAtomMapFwd φ) (.box ψ) ∈ LimitF ...
        -- By effectiveFormula at box: this is mkAtomMap φ (mkAtomMapFwd φ (.box ψ))
        -- By mkAtomMapFwd_section (if .box ψ ∈ φ.predFormulas): = .box ψ
        -- So goal is: .box ψ ∈ LimitF fc f.val f.property.1 q
        -- Which follows from box_stable_in_limit_f + h_box_in_N
        change (mkAtomMap φ (mkAtomMapFwd φ (.box ψ))) ∈ LimitF FrameClass.Discrete f.val
            f.property.1 q
        have h_box_pred_mem : Formula.box ψ ∈ φ.predFormulas :=
          h_sub (Finset.mem_union.mpr (Or.inl (Finset.mem_singleton.mpr rfl)))
        rw [mkAtomMapFwd_section φ (.box ψ) h_box_pred_mem]
        exact (box_stable_in_limit_f FrameClass.Discrete f.val f.property.1 ψ q hq).mpr h_box_in_N
      -- Transfer ∀x.P_{.box ψ}(x) from limitdom to Z via k-equiv
      have h_all_pred_Z : ∀ (x : ((getZ f).toOrdered sig).carrier),
          ((getZ f).toOrdered sig).interp (mkAtomMapFwd φ (.box ψ)) x := by
        -- Build the FO sentence ∀x. atom_{p}(x) where p = mkAtomMapFwd φ (.box ψ)
        let p := mkAtomMapFwd φ (.box ψ)
        let sent : MonadicSentence sig := .all (.atom p ⟨0, by omega⟩)
        have h_depth : sent.quantifierDepth ≤ k := by
          simp only [sent, MonadicFormula.quantifierDepth, k]; omega
        have h_eval_lim : eval (limitdomMonadicStructure f.val f.property.1 φ) Fin.elim0
            sent := by
          simp only [sent, eval]
          intro x
          exact h_all_pred_lim x
        have h_eval_Z : eval ((getZ f).toOrdered sig) Fin.elim0 sent :=
          (k_equiv_preserves_sentence (h_k_equiv f) sent h_depth).mp h_eval_lim
        simp only [sent, eval] at h_eval_Z
        exact fun x => h_eval_Z x
      exact h_all_pred_Z (toCarrier (h_lo f) (h_hi f) (w₀ + t))
    · -- Backward: TemporalTruth (.box ψ) → (∀ σ, σ.IsTotal → TruthAt σ t ψ)
      intro h_box σ h_mem
      obtain ⟨f', w₀', h_eq⟩ := multiFam_total_eq σ h_mem
      rw [h_eq, ih h_sub_ψ f' w₀' t]
      -- h_box : TemporalTruth (.box ψ) at (f, w₀+t) on Z_f
      -- = (getZ f).interp (mkAtomMapFwd φ (.box ψ)) (w₀+t)
      -- = ((getZ f).toOrdered sig).interp (mkAtomMapFwd φ (.box ψ)) (toCarrier(w₀+t))
      -- Goal: TemporalTruth ψ at (f', w₀'+t) on Z_{f'}
      --
      -- Strategy: h_box at one point → existential on Z_f → k-equiv → existential on limitdom_f
      -- → .box ψ ∈ some LimitF point → box_stable → .box ψ ∈ N_f → box-equiv → .box ψ ∈ A
      -- → .box ψ ∈ N_{f'} → box stability on limitdom_{f'} → Modal T → ψ everywhere
      -- → table transfer → Z_{f'}
      --
      -- Step 1: h_box gives the predicate at one point → ∃x. P(x) on Z_f
      have h_box_pred_mem : Formula.box ψ ∈ φ.predFormulas :=
        h_sub (Finset.mem_union.mpr (Or.inl (Finset.mem_singleton.mpr rfl)))
      let p := mkAtomMapFwd φ (.box ψ)
      -- Step 2: existential transfer to limitdom_f → .box ψ ∈ some LimitF point
      have h_ex_Z : eval ((getZ f).toOrdered sig) Fin.elim0
          (MonadicFormula.ex (.atom p ⟨0, by omega⟩)) := by
        simp only [eval]
        exact ⟨toCarrier (h_lo f) (h_hi f) (w₀ + t), h_box⟩
      have h_ex_depth : (MonadicFormula.ex (.atom p ⟨0, by omega⟩) : MonadicSentence
          sig).quantifierDepth ≤ k := by
        simp only [MonadicFormula.quantifierDepth, k]; omega
      have h_ex_lim : eval (limitdomMonadicStructure f.val f.property.1 φ) Fin.elim0
          (MonadicFormula.ex (.atom p ⟨0, by omega⟩)) :=
        ((k_equiv_preserves_sentence (h_k_equiv f) _ h_ex_depth).symm).mp h_ex_Z
      simp only [eval] at h_ex_lim
      obtain ⟨⟨q, hq⟩, h_pred_q⟩ := h_ex_lim
      -- h_pred_q : (limitdomMonadicStructure ...).interp p ⟨q, hq⟩
      -- = mkAtomMap φ (mkAtomMapFwd φ (.box ψ)) ∈ LimitF fc f.val f.property.1 q
      -- By mkAtomMapFwd_section: = .box ψ ∈ LimitF(q)
      have h_box_q : Formula.box ψ ∈ LimitF FrameClass.Discrete f.val f.property.1 q := by
        have : (mkAtomMap φ (mkAtomMapFwd φ (.box ψ))) ∈
            LimitF FrameClass.Discrete f.val f.property.1 q := h_pred_q
        rwa [mkAtomMapFwd_section φ (.box ψ) h_box_pred_mem] at this
      -- Step 3: box_stable → .box ψ ∈ N_f
      have h_box_N : Formula.box ψ ∈ f.val :=
        (box_stable_in_limit_f FrameClass.Discrete f.val f.property.1 ψ q hq).mp h_box_q
      -- Step 4: Box-equiv → .box ψ ∈ A → .box ψ ∈ N_{f'}
      have h_box_A : Formula.box ψ ∈ A := (f.property.2.2 ψ).mpr h_box_N
      have h_box_N' : Formula.box ψ ∈ f'.val := (f'.property.2.2 ψ).mp h_box_A
      -- Step 5: Box stability → .box ψ ∈ limit_f_{f'}(x) for all x
      -- Step 6: Modal T → ψ ∈ limit_f_{f'}(x) for all x
      have h_ψ_all_lim : ∀ (x : (limitdomMonadicStructure f'.val f'.property.1 φ).carrier),
          TemporalTruth (limitdomMonadicStructure f'.val f'.property.1 φ)
            (mkAtomMapFwd φ) x ψ := by
        intro ⟨q, hq⟩
        -- .box ψ ∈ LimitF(q) by box stability
        have h_box_q : Formula.box ψ ∈ LimitF FrameClass.Discrete f'.val f'.property.1 q :=
          (box_stable_in_limit_f FrameClass.Discrete f'.val f'.property.1 ψ q hq).mpr h_box_N'
        -- Modal T: □ψ → ψ
        have h_ψ_q : ψ ∈ LimitF FrameClass.Discrete f'.val f'.property.1 q :=
          SetMaximalConsistent.mp_of_theorem (limit_c0 FrameClass.Discrete f'.val f'.property.1 q hq)
            (DerivationTree.axiom [] _ (Axiom.modal_t ψ) trivial) h_box_q
        -- Convert to TemporalTruth via effectiveFormula bridge
        rw [← effectiveFormula_id_of_sub h_sub_ψ] at h_ψ_q
        exact (limitdom_temporal_truth_effective f'.val f'.property.1 φ ψ ⟨q, hq⟩).mpr h_ψ_q
      -- Step 7: Transfer TemporalTruth from limitdom_{f'} to Z_{f'}
      have h_all_table_lim : eval (limitdomMonadicStructure f'.val f'.property.1 φ) Fin.elim0
          (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)) := by
        simp only [eval]
        intro x
        have h_env : Fin.cons x Fin.elim0 = (fun (_ : Fin 1) => x) := by
          funext i; fin_cases i; rfl
        rw [h_env]
        exact (table_correctness (limitdomMonadicStructure f'.val f'.property.1 φ)
          (mkAtomMapFwd φ) x ψ).mpr (h_ψ_all_lim x)
      have h_box_depth : operatorDepth (.box ψ) ≤ operatorDepth φ :=
        predFormulas_operator_depth_le φ (.box ψ)
          (h_sub (Finset.mem_union.mpr (Or.inl (Finset.mem_singleton.mpr rfl))))
      have h_depth_all : (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)).quantifierDepth ≤
          k := by
        simp only [MonadicFormula.quantifierDepth, k, operatorDepth] at h_box_depth ⊢
        exact Nat.succ_le_of_lt (Nat.lt_of_le_of_lt (table_depth_bound sig (mkAtomMapFwd φ) ψ)
          (by omega))
      have h_all_table_Z : eval ((getZ f').toOrdered sig) Fin.elim0
          (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)) :=
        (k_equiv_preserves_sentence (h_k_equiv f') _ h_depth_all).mp h_all_table_lim
      simp only [eval] at h_all_table_Z
      have h_eval := h_all_table_Z (toCarrier (h_lo f') (h_hi f') (w₀' + t))
      have h_env : Fin.cons (toCarrier (h_lo f') (h_hi f') (w₀' + t)) Fin.elim0 =
          (fun (_ : Fin 1) => toCarrier (h_lo f') (h_hi f') (w₀' + t)) := by
        funext i; fin_cases i; rfl
      -- Same `Fin.cons` motive mismatch as the `box` case above.
      replace h_eval := h_env ▸ h_eval
      exact (table_correctness ((getZ f').toOrdered sig) (mkAtomMapFwd φ) _ ψ).mp h_eval
  | untl ψ₂ ψ₁ ih₂ ih₁ =>
    have h_sub₁ : ψ₁.predFormulas ⊆ φ.predFormulas :=
      Finset.Subset.trans Finset.subset_union_left h_sub
    have h_sub₂ : ψ₂.predFormulas ⊆ φ.predFormulas :=
      Finset.Subset.trans Finset.subset_union_right h_sub
    simp only [TruthAt, TemporalTruth]
    constructor
    · -- Forward: ∃ integer witness → ∃ carrier witness
      rintro ⟨s, hts, hψ₁, hguard⟩
      refine ⟨toCarrier (h_lo f) (h_hi f) (w₀ + s), ?_, ?_, ?_⟩
      · change (w₀ + t : ℤ) < w₀ + s; omega
      · exact (ih₁ h_sub₁ f w₀ s).mp hψ₁
      · intro rc h_lt_rc h_rc_lt
        have h_r_exists : ∃ r : ℤ, toCarrier (h_lo f) (h_hi f) (w₀ + r) = rc ∧ t < r ∧ r < s :=
          ⟨rc.val - w₀, Subtype.ext (by simp only [toCarrier]; omega),
           by (have : (w₀ + t : ℤ) < rc.val := h_lt_rc; omega),
           by (have : (rc.val : ℤ) < w₀ + s := h_rc_lt; omega)⟩
        obtain ⟨r, h_eq, htr, hrs⟩ := h_r_exists
        rw [← h_eq]
        exact (ih₂ h_sub₂ f w₀ r).mp (hguard r htr hrs)
    · -- Backward: ∃ carrier witness → ∃ integer witness
      rintro ⟨sc, h_lt_sc, hψ₁, hguard⟩
      have h_eq_sc : toCarrier (h_lo f) (h_hi f) (w₀ + (sc.val - w₀)) = sc :=
        Subtype.ext (by simp only [toCarrier]; omega)
      refine ⟨sc.val - w₀, ?_, ?_, ?_⟩
      · have : (w₀ + t : ℤ) < sc.val := h_lt_sc; omega
      · rw [ih₁ h_sub₁ f w₀ (sc.val - w₀), h_eq_sc]; exact hψ₁
      · intro r htr hrs
        rw [ih₂ h_sub₂ f w₀ r]
        have h_lt : (toCarrier (h_lo f) (h_hi f) (w₀ + t) : (getZ f).intervalCarrier) <
            toCarrier (h_lo f) (h_hi f) (w₀ + r) := by
          change (w₀ + t : ℤ) < w₀ + r; omega
        have h_lt2 : (toCarrier (h_lo f) (h_hi f) (w₀ + r) : (getZ f).intervalCarrier) < sc := by
          change (w₀ + r : ℤ) < sc.val; omega
        exact hguard _ h_lt h_lt2
  | snce ψ₂ ψ₁ ih₂ ih₁ =>
    -- Symmetric to Until case
    have h_sub₁ : ψ₁.predFormulas ⊆ φ.predFormulas :=
      Finset.Subset.trans Finset.subset_union_left h_sub
    have h_sub₂ : ψ₂.predFormulas ⊆ φ.predFormulas :=
      Finset.Subset.trans Finset.subset_union_right h_sub
    simp only [TruthAt, TemporalTruth]
    constructor
    · -- Forward: ∃ integer witness → ∃ carrier witness
      rintro ⟨s, hst, hψ₁, hguard⟩
      refine ⟨toCarrier (h_lo f) (h_hi f) (w₀ + s), ?_, ?_, ?_⟩
      · change (w₀ + s : ℤ) < w₀ + t; omega
      · exact (ih₁ h_sub₁ f w₀ s).mp hψ₁
      · intro rc h_lt_rc h_rc_lt
        have h_r_exists : ∃ r : ℤ, toCarrier (h_lo f) (h_hi f) (w₀ + r) = rc ∧ s < r ∧ r < t :=
          ⟨rc.val - w₀, Subtype.ext (by simp only [toCarrier]; omega),
           by (have : (w₀ + s : ℤ) < rc.val := h_lt_rc; omega),
           by (have : (rc.val : ℤ) < w₀ + t := h_rc_lt; omega)⟩
        obtain ⟨r, h_eq, hsr, hrt⟩ := h_r_exists
        rw [← h_eq]
        exact (ih₂ h_sub₂ f w₀ r).mp (hguard r hsr hrt)
    · -- Backward: ∃ carrier witness → ∃ integer witness
      rintro ⟨sc, h_sc_lt, hψ₁, hguard⟩
      have h_eq_sc : toCarrier (h_lo f) (h_hi f) (w₀ + (sc.val - w₀)) = sc :=
        Subtype.ext (by simp only [toCarrier]; omega)
      refine ⟨sc.val - w₀, ?_, ?_, ?_⟩
      · have : (sc.val : ℤ) < w₀ + t := h_sc_lt; omega
      · rw [ih₁ h_sub₁ f w₀ (sc.val - w₀), h_eq_sc]; exact hψ₁
      · intro r hsr hrt
        rw [ih₂ h_sub₂ f w₀ r]
        have h_lt : sc < toCarrier (h_lo f) (h_hi f) (w₀ + r) := by
          change (sc.val : ℤ) < w₀ + r
          have : (sc.val : ℤ) < w₀ + t := h_sc_lt; omega
        have h_lt2 : (toCarrier (h_lo f) (h_hi f) (w₀ + r) : (getZ f).intervalCarrier) <
            toCarrier (h_lo f) (h_hi f) (w₀ + t) := by
          change (w₀ + r : ℤ) < w₀ + t; omega
        exact hguard _ h_lt h_lt2

end FormalSystem.Metalogic.WeakCanonical

