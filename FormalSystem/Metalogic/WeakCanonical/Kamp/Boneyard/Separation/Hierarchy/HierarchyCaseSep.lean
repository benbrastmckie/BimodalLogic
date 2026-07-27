/-
================================================================================
ARCHIVED — BIT-ROTTED DEAD CODE (Kamp Boneyard). MOVE-not-delete; never empty.
================================================================================

This is the abandoned GHR separation / expressive-completeness ALTERNATIVE. It is
EXCLUDED FROM THE BUILD (outside the Bimodal.lean import closure — uncompiled) and does
NOT COMPILE. A `grep -c sorry == 0` on this file is MEANINGLESS: uncompiled code trivially
has no sorry. This is NOT sorry-free, verified, or reusable code.

It is OFF the faithful Rabinovich path (Def 4.1, PDF p.5). Do NOT consume or reuse it for
the k>=2 E[Sigma] re-architecture.

Key declarations: (bit-rotted GHR hierarchy: HierarchyCaseSep)
-/
import FormalSystem.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.Hierarchy.HierarchyDefs

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Case-specific is_separable_with_U_type theorems

Extracted from HierarchyCompletion.lean to break a circular dependency
(HierarchyCompletion imports HierarchyInduction, which needs these theorems).

These theorems do NOT depend on HierarchyInduction.
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-- has_single_U_type for case1_psi when a, q, A, B are U-free. -/
private theorem case1_psi_has_single_U_type (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true) :
    has_single_U_type (case1_psi a q A B) A B := by
  simp only [case1_psi, Formula.or, Formula.and, Formula.neg, has_single_U_type]
  refine ⟨⟨⟨⟨⟨⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩, ?_⟩, ?_⟩, ?_⟩, ?_⟩, ?_⟩
  all_goals (try exact u_free_has_single_U_type ha)
  all_goals (try exact u_free_has_single_U_type hq)
  all_goals (try exact u_free_has_single_U_type hA)
  all_goals (try exact u_free_has_single_U_type hB)
  all_goals (try trivial)
  all_goals (try exact ⟨rfl, rfl⟩)
  all_goals (try exact ⟨trivial, trivial⟩)
  all_goals simp_all [has_single_U_type, is_U_free,
    u_free_has_single_U_type ha, u_free_has_single_U_type hq,
    u_free_has_single_U_type hA, u_free_has_single_U_type hB]

/-- has_single_U_type for case2_psi when a, q, A, B are U-free.
    The only `.untl` in case2_psi is `(.untl A B)` inside `¬U(A,B) = .imp (.untl A B) .bot`
    in disjunct d1. Disjuncts d2 and d3 are completely U-free. -/
private theorem case2_psi_has_single_U_type (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true) :
    has_single_U_type (case2_psi a q A B) A B := by
  delta case2_psi
  simp only [Formula.or, Formula.and, Formula.neg, has_single_U_type]
  refine ⟨⟨⟨⟨⟨⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩, ?_⟩, ?_⟩, ?_⟩, ?_⟩, ?_⟩
  all_goals (try exact u_free_has_single_U_type ha)
  all_goals (try exact u_free_has_single_U_type hq)
  all_goals (try exact u_free_has_single_U_type hA)
  all_goals (try exact u_free_has_single_U_type hB)
  all_goals (try trivial)
  all_goals (try exact ⟨trivial, trivial⟩)
  all_goals (try exact ⟨⟨trivial, trivial⟩, trivial⟩)
  all_goals (try exact ⟨u_free_has_single_U_type hA, trivial⟩)
  all_goals (try exact ⟨u_free_has_single_U_type hq, trivial⟩)
  all_goals (try exact ⟨u_free_has_single_U_type hB, trivial⟩)
  all_goals simp_all [has_single_U_type, is_U_free,
    u_free_has_single_U_type ha, u_free_has_single_U_type hq,
    u_free_has_single_U_type hA, u_free_has_single_U_type hB]

/-! ### Case-specific is_separable_with_U_type -/

set_option maxHeartbeats 800000 in
/-- Case 1 with U-type preservation: S(a∧U(A,B), q) is separable_with_U_type. -/
theorem case1_sep_with_U_type_gen (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable_with_U_type (.snce (Formula.and a (.untl A B)) q) A B := by
  have ⟨hequiv, hsep⟩ := case1_psi_properties a q A B ha hq hA hB hA' hB'
  exact ⟨case1_psi a q A B, hsep, hequiv,
    case1_psi_has_single_U_type a q A B ha hq hA hB⟩

set_option maxHeartbeats 3200000 in
/-- Case 2 with U-type preservation: S(a∧¬U(A,B), q) is separable_with_U_type. -/
theorem case2_sep_with_U_type_gen (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable_with_U_type (.snce (Formula.and a (Formula.neg (.untl A B))) q) A B := by
  have ⟨hequiv, hsep⟩ := case2_psi_properties a q A B ha hq hA hB hA' hB'
  exact ⟨case2_psi a q A B, hsep, hequiv,
    case2_psi_has_single_U_type a q A B ha hq hA hB⟩

/-! ### Combined Helpers with U-type Preservation

These mirror `snce_combined_U_separable` / `snce_combined_notU_separable`
from DedekindZ.lean, but return `is_separable_with_U_type` by using the
non-existential `case1_psi_properties` / `case2_psi_properties`. -/

set_option maxHeartbeats 800000 in
/-- S(COMBINED ∧ U(A,B), guard) is separable_with_U_type A B when COMBINED
    satisfies untl_under_bool_only and guard is U-free. -/
theorem snce_combined_U_sep_with_U_type
    (combined guard : Formula) (A B : Formula)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true)
    (hg_uf : is_U_free guard = true)
    (h_bool : untl_under_bool_only combined A B) :
    is_separable_with_U_type (.snce (Formula.and combined (.untl A B)) guard) A B := by
  let combined' := replace_untl_with_top combined A B
  have h_uf : is_U_free combined' = true := replace_U_free_of_bool combined A B h_bool
  have h_congr := snce_event_congr_with_U combined combined' guard A B
    (fun M t hU => replace_correct_bool combined A B M t h_bool hU)
  apply is_separable_with_U_type_of_equiv h_congr
  have ⟨hequiv, hsep⟩ := case1_psi_properties combined' guard A B h_uf hg_uf hA hB hA' hB'
  exact ⟨case1_psi combined' guard A B, hsep, hequiv,
    case1_psi_has_single_U_type combined' guard A B h_uf hg_uf hA hB⟩

set_option maxHeartbeats 3200000 in
/-- S(COMBINED ∧ ¬U(A,B), guard) is separable_with_U_type A B when COMBINED
    satisfies untl_under_bool_only and guard is U-free. -/
theorem snce_combined_notU_sep_with_U_type
    (combined guard : Formula) (A B : Formula)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true)
    (hg_uf : is_U_free guard = true)
    (h_bool : untl_under_bool_only combined A B) :
    is_separable_with_U_type (.snce (Formula.and combined (Formula.neg (.untl A B))) guard) A B := by
  let combined' := replace_untl_with_bot combined A B
  have h_uf : is_U_free combined' = true := replace_bot_U_free_of_bool combined A B h_bool
  have h_congr := snce_event_congr_with_notU combined combined' guard A B
    (fun M t hnotU => replace_correct_bot combined A B M t h_bool hnotU)
  apply is_separable_with_U_type_of_equiv h_congr
  have ⟨hequiv, hsep⟩ := case2_psi_properties combined' guard A B h_uf hg_uf hA hB hA' hB'
  exact ⟨case2_psi combined' guard A B, hsep, hequiv,
    case2_psi_has_single_U_type combined' guard A B h_uf hg_uf hA hB⟩

/-! ### Private helpers for Cases 5-8 -/

/-- Helper: and_left_congr for int_equiv. -/
private theorem and_left_congr_hier {φ₁ φ₂ ψ : Formula} (h : int_equiv φ₁ φ₂) :
    int_equiv (Formula.and φ₁ ψ) (Formula.and φ₂ ψ) := by
  intro M t; constructor
  · intro h'; have ⟨hφ, hψ⟩ := int_truth_and_iff.mp h'
    exact int_truth_and_iff.mpr ⟨(h M t).mp hφ, hψ⟩
  · intro h'; have ⟨hφ, hψ⟩ := int_truth_and_iff.mp h'
    exact int_truth_and_iff.mpr ⟨(h M t).mpr hφ, hψ⟩

/-- snce preserves int_equiv (local copy to avoid depending on HierarchyInduction). -/
private theorem snce_congr_local {φ₁ ψ₁ φ₂ ψ₂ : Formula}
    (h1 : int_equiv φ₁ φ₂) (h2 : int_equiv ψ₁ ψ₂) :
    int_equiv (.snce φ₁ ψ₁) (.snce φ₂ ψ₂) := by
  intro M t; constructor
  · rintro ⟨s, hst, hφ, hψ⟩
    exact ⟨s, hst, (h1 M s).mp hφ, fun r hr1 hr2 => (h2 M r).mp (hψ r hr1 hr2)⟩
  · rintro ⟨s, hst, hφ, hψ⟩
    exact ⟨s, hst, (h1 M s).mpr hφ, fun r hr1 hr2 => (h2 M r).mpr (hψ r hr1 hr2)⟩

/-- Helper: snce_event_congr for int_equiv (event only). -/
private theorem snce_event_congr_hier {φ₁ φ₂ ψ : Formula} (h : int_equiv φ₁ φ₂) :
    int_equiv (.snce φ₁ ψ) (.snce φ₂ ψ) :=
  snce_congr_local h (int_equiv_refl ψ)

/-! ### Cases 5-8 with U-type Preservation

These replicate the DedekindZ.lean Case 5-8 separability proofs but
return `is_separable_with_U_type` by using `_with_U_type` combinators. -/

set_option maxHeartbeats 1600000 in
/-- Case 5 with U-type: S(a∧U(A,B), q∨U(A,B)) is separable_with_U_type A B. -/
theorem case5_sep_with_U_type_Z_gen (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable_with_U_type (.snce (Formula.and a (.untl A B)) (Formula.or q (.untl A B))) A B := by
  -- Follow case5_separable_Z_gen structure with _with_U_type combinators
  apply is_separable_with_U_type_of_equiv (case3_equiv_Z_general (Formula.and a (.untl A B)) q A B)
  simp only [case3_rhs]
  apply or_separable_with_U_type
  · apply or_separable_with_U_type
    · -- Case 1 with U-type
      exact case1_sep_with_U_type_gen a q A B ha hq hA hB hA' hB'
    · apply and_separable_with_U_type
      · -- S(alpha(a∧U, q), Q_Z(...)) part
        apply is_separable_with_U_type_of_equiv
          (snce_event_congr_hier (case3_alpha_aU_factor a q A B))
        apply is_separable_with_U_type_of_equiv (int_equiv_trans
          (snce_event_congr_hier (and_or_distrib a
            (Formula.and (Formula.neg q) (.snce (Formula.and a (.untl A B)) q))
            (.untl A B)))
          (since_distrib_or_left _ _ (Q_Z A B (Formula.neg q))))
        apply or_separable_with_U_type
        · exact snce_combined_U_sep_with_U_type a (Q_Z A B (Formula.neg q)) A B
            hA hB hA' hB' (Q_Z_neg_q_U_free A B q hA hB hq)
            (u_free_untl_under_bool a A B ha)
        · let σ := case1_psi a q A B
          have hσ_equiv : int_equiv (.snce (Formula.and a (.untl A B)) q) σ :=
            (case1_psi_properties a q A B ha hq hA hB hA' hB').1
          have hY_congr : int_equiv
            (Formula.and (Formula.neg q) (.snce (Formula.and a (.untl A B)) q))
            (Formula.and (Formula.neg q) σ) := by
            intro M t; constructor
            · intro h; have ⟨hnq, hS⟩ := int_truth_and_iff.mp h
              exact int_truth_and_iff.mpr ⟨hnq, (hσ_equiv M t).mp hS⟩
            · intro h; have ⟨hnq, hσ'⟩ := int_truth_and_iff.mp h
              exact int_truth_and_iff.mpr ⟨hnq, (hσ_equiv M t).mpr hσ'⟩
          apply is_separable_with_U_type_of_equiv (snce_event_congr_hier (and_left_congr_hier hY_congr))
          have h_nqσ_bool : untl_under_bool_only (Formula.and (Formula.neg q) σ) A B := by
            show untl_under_bool_only (.imp (.imp (Formula.neg q) (.imp σ .bot)) .bot) A B
            refine ⟨⟨?_, case1_psi_bool_only a q A B ha hq hA hB, trivial⟩, trivial⟩
            exact ⟨u_free_untl_under_bool q A B hq, trivial⟩
          exact snce_combined_U_sep_with_U_type (Formula.and (Formula.neg q) σ)
            (Q_Z A B (Formula.neg q)) A B hA hB hA' hB'
            (Q_Z_neg_q_U_free A B q hA hB hq) h_nqσ_bool
      · apply or_separable_with_U_type
        · exact u_free_separable_with_type hA
        · exact and_separable_with_U_type
            (u_free_separable_with_type hB)
            (untl_s_free_separable_with_type hA' hB')
  · have h_d21 := d21_sep_equiv a q A B ha hq hA hB hA' hB'
    have h_event_congr : int_equiv
      (Formula.and (Formula.and A (Formula.or q (.untl A B)))
        (.snce (case3_alpha (Formula.and a (.untl A B)) q A B) (Q_Z A B (Formula.neg q))))
      (Formula.and (Formula.and A (Formula.or q (.untl A B))) (d21_sep a q A B)) := by
      intro M t; constructor
      · intro h; have ⟨hAqU, hS⟩ := int_truth_and_iff.mp h
        exact int_truth_and_iff.mpr ⟨hAqU, (h_d21 M t).mp hS⟩
      · intro h; have ⟨hAqU, hd⟩ := int_truth_and_iff.mp h
        exact int_truth_and_iff.mpr ⟨hAqU, (h_d21 M t).mpr hd⟩
    apply is_separable_with_U_type_of_equiv (snce_event_congr_hier h_event_congr)
    apply is_separable_with_U_type_of_equiv (since_event_split _ (.untl A B) q)
    apply or_separable_with_U_type
    · have h_event_bool : untl_under_bool_only
          (Formula.and (Formula.and A (Formula.or q (.untl A B))) (d21_sep a q A B)) A B := by
        show untl_under_bool_only (.imp (.imp (Formula.and A (Formula.or q (.untl A B)))
          (.imp (d21_sep a q A B) .bot)) .bot) A B
        refine ⟨⟨?_, d21_sep_bool_only a q A B ha hq hA hB, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp A (.imp (Formula.or q (.untl A B)) .bot)) .bot) A B
        refine ⟨⟨u_free_untl_under_bool A A B hA, ?_, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp q .bot) (.untl A B)) A B
        exact ⟨⟨u_free_untl_under_bool q A B hq, trivial⟩, Or.inl ⟨rfl, rfl⟩⟩
      exact snce_combined_U_sep_with_U_type
        (Formula.and (Formula.and A (Formula.or q (.untl A B))) (d21_sep a q A B))
        q A B hA hB hA' hB' hq h_event_bool
    · have h_event_bool : untl_under_bool_only
          (Formula.and (Formula.and A (Formula.or q (.untl A B))) (d21_sep a q A B)) A B := by
        show untl_under_bool_only (.imp (.imp (Formula.and A (Formula.or q (.untl A B)))
          (.imp (d21_sep a q A B) .bot)) .bot) A B
        refine ⟨⟨?_, d21_sep_bool_only a q A B ha hq hA hB, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp A (.imp (Formula.or q (.untl A B)) .bot)) .bot) A B
        refine ⟨⟨u_free_untl_under_bool A A B hA, ?_, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp q .bot) (.untl A B)) A B
        exact ⟨⟨u_free_untl_under_bool q A B hq, trivial⟩, Or.inl ⟨rfl, rfl⟩⟩
      exact snce_combined_notU_sep_with_U_type
        (Formula.and (Formula.and A (Formula.or q (.untl A B))) (d21_sep a q A B))
        q A B hA hB hA' hB' hq h_event_bool

/-- Case 8 with U-type: S(a∧¬U, q∨¬U) is separable_with_U_type A B. -/
theorem case8_sep_with_U_type_Z_gen (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable_with_U_type (.snce (Formula.and a (Formula.neg (.untl A B)))
      (Formula.or q (Formula.neg (.untl A B)))) A B := by
  apply is_separable_with_U_type_of_equiv (case8_equiv_Z a q A B)
  apply and_separable_with_U_type
  · -- S(a∧¬U, ⊤): Case 2 with guard = neg bot (U-free)
    have hg : is_U_free (Formula.neg .bot) = true := by simp [Formula.neg, is_U_free]
    exact case2_sep_with_U_type_gen a (Formula.neg .bot) A B ha hg hA hB hA' hB'
  · -- ¬S(¬q∧U, ¬a∨U): neg of Case 5
    apply neg_separable_with_U_type
    have hnq_uf : is_U_free (Formula.neg q) = true := by simp [Formula.neg, is_U_free, hq]
    have hna_uf : is_U_free (Formula.neg a) = true := by simp [Formula.neg, is_U_free, ha]
    exact case5_sep_with_U_type_Z_gen (Formula.neg q) (Formula.neg a) A B hnq_uf hna_uf hA hB hA' hB'

set_option maxHeartbeats 3200000 in
/-- S(ev, q∨U(A,B)) is separable_with_U_type A B when ev is U-free.
    Follows the case3 decomposition from case5, but simplified for U-free events:
    - D1: S(ev, q) — U-free → u_free_separable_with_type
    - D2: S(alpha, Q_Z) ∧ (A ∨ B∧U) — uses snce_combined_U_sep_with_U_type
    - D3: S(A ∧ (q∨U) ∧ S(alpha, Q_Z), q) — uses snce_combined_{U,notU}_sep_with_U_type -/
private theorem snce_Ufree_event_qU_guard_sep_with_U_type (ev q A B : Formula)
    (hev_uf : is_U_free ev = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable_with_U_type (.snce ev (Formula.or q (.untl A B))) A B := by
  -- Apply case3 decomposition
  apply is_separable_with_U_type_of_equiv (case3_equiv_Z_general ev q A B)
  simp only [case3_rhs]
  apply or_separable_with_U_type
  · apply or_separable_with_U_type
    · -- D1: S(ev, q) — entirely U-free
      have hev_snce_sep : is_syntactically_separated (.snce ev q) = true := by
        simp [is_syntactically_separated, hev_uf, hq]
      exact ⟨.snce ev q, hev_snce_sep, int_equiv_refl _,
        ⟨u_free_has_single_U_type hev_uf, u_free_has_single_U_type hq⟩⟩
    · -- D2: S(alpha, Q_Z) ∧ (A ∨ B∧U)
      apply and_separable_with_U_type
      · -- S(alpha(ev, q), Q_Z(A,B,¬q))
        have h_nqSev_uf : is_U_free (Formula.and (Formula.neg q) (.snce ev q)) = true := by
          simp [Formula.and, Formula.neg, is_U_free, hq, hev_uf]
        apply is_separable_with_U_type_of_equiv (since_distrib_or_left _ _ (Q_Z A B (Formula.neg q)))
        apply or_separable_with_U_type
        · -- S(ev, Q_Z) — both U-free
          have hQ_uf : is_U_free (Q_Z A B (Formula.neg q)) = true :=
            Q_Z_neg_q_U_free A B q hA hB hq
          exact ⟨.snce ev (Q_Z A B (Formula.neg q)),
            by simp [is_syntactically_separated, hev_uf, hQ_uf], int_equiv_refl _,
            ⟨u_free_has_single_U_type hev_uf, u_free_has_single_U_type hQ_uf⟩⟩
        · -- S((¬q ∧ S(ev,q)) ∧ (q ∨ U), Q_Z) — event split on U
          apply is_separable_with_U_type_of_equiv
            (since_event_split _ (.untl A B) (Q_Z A B (Formula.neg q)))
          apply or_separable_with_U_type
          · apply is_separable_with_U_type_of_equiv (snce_event_congr_with_U _ _ _ A B
              (fun M t hU => ⟨fun h => (int_truth_and_iff.mp h).1,
                fun h => int_truth_and_iff.mpr ⟨h, int_truth_or_iff.mpr (Or.inr hU)⟩⟩))
            exact snce_combined_U_sep_with_U_type (Formula.and (Formula.neg q) (.snce ev q))
              (Q_Z A B (Formula.neg q)) A B hA hB hA' hB' (Q_Z_neg_q_U_free A B q hA hB hq)
              (u_free_untl_under_bool _ A B h_nqSev_uf)
          · apply is_separable_with_U_type_of_equiv (by
              intro M t; constructor
              · rintro ⟨s, _, h_event, _⟩
                have ⟨h_left, h_notU⟩ := int_truth_and_iff.mp h_event
                have ⟨h_nqS, h_qU⟩ := int_truth_and_iff.mp h_left
                have h_nq := (int_truth_and_iff.mp h_nqS).1
                rcases int_truth_or_iff.mp h_qU with hq' | hU
                · exact h_nq hq'
                · exact h_notU hU
              · intro h; exact h.elim : int_equiv _ .bot)
            exact ⟨.bot, by simp [is_syntactically_separated], int_equiv_refl _, trivial⟩
      · -- A ∨ B∧U
        apply or_separable_with_U_type
        · exact u_free_separable_with_type hA
        · exact and_separable_with_U_type
            (u_free_separable_with_type hB)
            (untl_s_free_separable_with_type hA' hB')
  · -- D3: S(A ∧ (q ∨ U) ∧ S(alpha, Q_Z), q) where alpha = case3_alpha ev q A B
    -- Build local d21 analog for U-free event case:
    -- S(alpha, Q_Z) ↔ S(ev, Q_Z) ∨ case1_psi(¬q∧S(ev,q), Q_Z, A, B)
    have h_nqSev_uf_D3 : is_U_free (Formula.and (Formula.neg q) (.snce ev q)) = true := by
      simp [Formula.and, Formula.neg, is_U_free, hq, hev_uf]
    have hQ_uf_D3 : is_U_free (Q_Z A B (Formula.neg q)) = true :=
      Q_Z_neg_q_U_free A B q hA hB hq
    let d21_local := Formula.or (.snce ev (Q_Z A B (Formula.neg q)))
      (case1_psi (Formula.and (Formula.neg q) (.snce ev q)) (Q_Z A B (Formula.neg q)) A B)
    -- Show d21_local has untl_under_bool_only
    have h_d21_bool : untl_under_bool_only d21_local A B := by
      have h_or_bool : ∀ p q, untl_under_bool_only p A B → untl_under_bool_only q A B →
          untl_under_bool_only (Formula.or p q) A B := by
        intro p q hp hq; exact ⟨⟨hp, trivial⟩, hq⟩
      apply h_or_bool
      · exact ⟨hev_uf, hQ_uf_D3⟩
      · exact case1_psi_bool_only _ _ A B h_nqSev_uf_D3 hQ_uf_D3 hA hB
    -- Show d21_local equiv to S(alpha, Q_Z) (same proof as DedekindZ/Cases.lean)
    have h_d21_equiv : int_equiv (.snce (case3_alpha ev q A B) (Q_Z A B (Formula.neg q))) d21_local := by
      have h_step1 := since_distrib_or_left ev
        (Formula.and (Formula.and (Formula.neg q) (.snce ev q)) (Formula.or q (.untl A B)))
        (Q_Z A B (Formula.neg q))
      have h_step2 := since_event_split
        (Formula.and (Formula.and (Formula.neg q) (.snce ev q)) (Formula.or q (.untl A B)))
        (.untl A B) (Q_Z A B (Formula.neg q))
      have h_congr_U := snce_event_congr_with_U
        (Formula.and (Formula.and (Formula.neg q) (.snce ev q)) (Formula.or q (.untl A B)))
        (Formula.and (Formula.neg q) (.snce ev q))
        (Q_Z A B (Formula.neg q)) A B
        (fun M t hU => ⟨fun h => (int_truth_and_iff.mp h).1,
          fun h => int_truth_and_iff.mpr ⟨h, int_truth_or_iff.mpr (Or.inr hU)⟩⟩)
      have h_psi := (case1_psi_properties (Formula.and (Formula.neg q) (.snce ev q))
        (Q_Z A B (Formula.neg q)) A B h_nqSev_uf_D3 hQ_uf_D3 hA hB hA' hB').1
      intro M t; constructor
      · intro h
        have h12 := (h_step1 M t).mp h
        rcases int_truth_or_iff.mp h12 with h1 | h2
        · exact int_truth_or_iff.mpr (Or.inl h1)
        · have h_split := (h_step2 M t).mp h2
          rcases int_truth_or_iff.mp h_split with hU_br | hnotU_br
          · exact int_truth_or_iff.mpr (Or.inr ((h_psi M t).mp ((h_congr_U M t).mp hU_br)))
          · exfalso
            obtain ⟨s, _, h_event, _⟩ := hnotU_br
            have ⟨h_left, h_notU⟩ := int_truth_and_iff.mp h_event
            have ⟨h_nqS, h_qU⟩ := int_truth_and_iff.mp h_left
            rcases int_truth_or_iff.mp h_qU with hq' | hU
            · exact (int_truth_and_iff.mp h_nqS).1 hq'
            · exact h_notU hU
      · intro h
        rcases int_truth_or_iff.mp h with h1 | h2
        · exact (h_step1 M t).mpr (int_truth_or_iff.mpr (Or.inl h1))
        · have h_combined := (h_congr_U M t).mpr ((h_psi M t).mpr h2)
          have h_unsplit := (h_step2 M t).mpr (int_truth_or_iff.mpr (Or.inl h_combined))
          exact (h_step1 M t).mpr (int_truth_or_iff.mpr (Or.inr h_unsplit))
    -- Substitute d21_local into the event of D3
    have h_event_congr : int_equiv
      (Formula.and (Formula.and A (Formula.or q (.untl A B)))
        (.snce (case3_alpha ev q A B) (Q_Z A B (Formula.neg q))))
      (Formula.and (Formula.and A (Formula.or q (.untl A B))) d21_local) := by
      intro M t; constructor
      · intro h; have ⟨hAqU, hS⟩ := int_truth_and_iff.mp h
        exact int_truth_and_iff.mpr ⟨hAqU, (h_d21_equiv M t).mp hS⟩
      · intro h; have ⟨hAqU, hd⟩ := int_truth_and_iff.mp h
        exact int_truth_and_iff.mpr ⟨hAqU, (h_d21_equiv M t).mpr hd⟩
    apply is_separable_with_U_type_of_equiv (snce_event_congr_hier h_event_congr)
    apply is_separable_with_U_type_of_equiv (since_event_split _ (.untl A B) q)
    apply or_separable_with_U_type
    · have h_event_bool : untl_under_bool_only
          (Formula.and (Formula.and A (Formula.or q (.untl A B))) d21_local) A B := by
        show untl_under_bool_only (.imp (.imp (Formula.and A (Formula.or q (.untl A B)))
          (.imp d21_local .bot)) .bot) A B
        refine ⟨⟨?_, h_d21_bool, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp A (.imp (Formula.or q (.untl A B)) .bot)) .bot) A B
        refine ⟨⟨u_free_untl_under_bool A A B hA, ?_, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp q .bot) (.untl A B)) A B
        exact ⟨⟨u_free_untl_under_bool q A B hq, trivial⟩, Or.inl ⟨rfl, rfl⟩⟩
      exact snce_combined_U_sep_with_U_type
        (Formula.and (Formula.and A (Formula.or q (.untl A B))) d21_local)
        q A B hA hB hA' hB' hq h_event_bool
    · have h_event_bool : untl_under_bool_only
          (Formula.and (Formula.and A (Formula.or q (.untl A B))) d21_local) A B := by
        show untl_under_bool_only (.imp (.imp (Formula.and A (Formula.or q (.untl A B)))
          (.imp d21_local .bot)) .bot) A B
        refine ⟨⟨?_, h_d21_bool, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp A (.imp (Formula.or q (.untl A B)) .bot)) .bot) A B
        refine ⟨⟨u_free_untl_under_bool A A B hA, ?_, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp q .bot) (.untl A B)) A B
        exact ⟨⟨u_free_untl_under_bool q A B hq, trivial⟩, Or.inl ⟨rfl, rfl⟩⟩
      exact snce_combined_notU_sep_with_U_type
        (Formula.and (Formula.and A (Formula.or q (.untl A B))) d21_local)
        q A B hA hB hA' hB' hq h_event_bool

/-- Case 6 with U-type: S(a∧¬U, q∨U) is separable_with_U_type A B. -/
theorem case6_sep_with_U_type_Z_gen (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable_with_U_type (.snce (Formula.and a (Formula.neg (.untl A B)))
      (Formula.or q (.untl A B))) A B := by
  -- Case 6 follows the pattern of case6_separable_Z_gen
  -- S(a∧¬U, q∨U) ↔ D1 ∨ D2 via case6_equiv_Z
  apply is_separable_with_U_type_of_equiv (case6_equiv_Z a q A B)
  -- D1 ∨ D2: D1 is U-free, D2 uses case5_sep_with_U_type_Z_gen
  -- From the DedekindZ proof, we need the separability of both parts.
  -- However, case6 has a complex structure. Use the existing is_separable
  -- and promote it.
  -- Case 6 is: S(a∧¬U, q∨U) ↔ S(a∧¬U,⊤)∧¬S(¬q∧U, ¬a∨U) (similar to case8 but dual)
  -- Wait, case6_equiv_Z is different from case8_equiv_Z. Let me check the actual equivalence.
  -- Actually, case6_equiv_Z is more complex than case8. Let me use a direct proof.
  -- For now, use the fact that the result of case6_equiv_Z is separable via case5/case8.
  -- From DedekindZ.lean, case6_separable_Z_gen uses case5_separable_Z_gen internally.
  -- The proof structure involves D1 (U-free) and D2 (which uses case5).
  -- Let me just use separable_with_type promotion:
  -- case6 output = (U-free parts) ∨ (case5 result)
  -- Since both have has_single_U_type, the whole result does.
  -- Follow case6_separable_Z_gen structure
  apply or_separable_with_U_type
  · -- D1: S(a,q∧¬A) ∧ ¬A ∧ ¬(B∧U)
    apply and_separable_with_U_type
    · apply and_separable_with_U_type
      · have hg_uf : is_U_free (Formula.and q (Formula.neg A)) = true := by
          simp [Formula.and, Formula.neg, is_U_free, hq, hA]
        exact ⟨.snce a (Formula.and q (Formula.neg A)),
          by simp [is_syntactically_separated, ha, hg_uf], int_equiv_refl _,
          ⟨u_free_has_single_U_type ha, u_free_has_single_U_type hg_uf⟩⟩
      · exact u_free_separable_with_type (by simp [Formula.neg, is_U_free, hA])
    · apply neg_separable_with_U_type
      exact and_separable_with_U_type
        (u_free_separable_with_type hB)
        (untl_s_free_separable_with_type hA' hB')
  · -- D2: S(¬B∧¬A∧(q∨U)∧S(a,q∧¬A), q∨U)
    -- Rearrange and distribute
    have h_rearrange : int_equiv
      (Formula.and (Formula.and (Formula.and (Formula.neg B) (Formula.neg A))
        (Formula.or q (.untl A B)))
        (.snce a (Formula.and q (Formula.neg A))))
      (Formula.and (Formula.and (Formula.and (Formula.neg B) (Formula.neg A))
        (.snce a (Formula.and q (Formula.neg A))))
        (Formula.or q (.untl A B))) := by
      intro M t; constructor
      · intro h
        have ⟨h1, h2⟩ := int_truth_and_iff.mp h
        have ⟨h3, h4⟩ := int_truth_and_iff.mp h1
        exact int_truth_and_iff.mpr ⟨int_truth_and_iff.mpr ⟨h3, h2⟩, h4⟩
      · intro h
        have ⟨h1, h2⟩ := int_truth_and_iff.mp h
        have ⟨h3, h4⟩ := int_truth_and_iff.mp h1
        exact int_truth_and_iff.mpr ⟨int_truth_and_iff.mpr ⟨h3, h2⟩, h4⟩
    apply is_separable_with_U_type_of_equiv (snce_event_congr_hier h_rearrange)
    have h_distrib : int_equiv
      (Formula.and (Formula.and (Formula.and (Formula.neg B) (Formula.neg A))
        (.snce a (Formula.and q (Formula.neg A))))
        (Formula.or q (.untl A B)))
      (Formula.or
        (Formula.and (Formula.and (Formula.and (Formula.neg B) (Formula.neg A))
          (.snce a (Formula.and q (Formula.neg A)))) q)
        (Formula.and (Formula.and (Formula.and (Formula.neg B) (Formula.neg A))
          (.snce a (Formula.and q (Formula.neg A)))) (.untl A B))) := by
      intro M t; constructor
      · intro h
        have ⟨hc, hab⟩ := int_truth_and_iff.mp h
        rcases int_truth_or_iff.mp hab with ha | hb
        · exact int_truth_or_iff.mpr (Or.inl (int_truth_and_iff.mpr ⟨hc, ha⟩))
        · exact int_truth_or_iff.mpr (Or.inr (int_truth_and_iff.mpr ⟨hc, hb⟩))
      · intro h
        rcases int_truth_or_iff.mp h with h1 | h2
        · have ⟨hc, ha⟩ := int_truth_and_iff.mp h1
          exact int_truth_and_iff.mpr ⟨hc, int_truth_or_iff.mpr (Or.inl ha)⟩
        · have ⟨hc, hb⟩ := int_truth_and_iff.mp h2
          exact int_truth_and_iff.mpr ⟨hc, int_truth_or_iff.mpr (Or.inr hb)⟩
    apply is_separable_with_U_type_of_equiv (snce_event_congr_hier h_distrib)
    apply is_separable_with_U_type_of_equiv (since_distrib_or_left _ _ (Formula.or q (.untl A B)))
    have hSTUFF_uf : is_U_free (Formula.and (Formula.and (Formula.neg B) (Formula.neg A))
        (.snce a (Formula.and q (Formula.neg A)))) = true := by
      simp [Formula.and, Formula.neg, is_U_free, ha, hq, hA, hB]
    apply or_separable_with_U_type
    · -- U-free event with q∨U guard: use snce_Ufree_event_qU_guard_sep_with_U_type
      have hev_uf : is_U_free (((B.neg.and A.neg).and (a.snce (q.and A.neg))).and q) = true := by
        simp [Formula.and, Formula.neg, is_U_free, ha, hq, hA, hB]
      exact snce_Ufree_event_qU_guard_sep_with_U_type _ q A B hev_uf hq hA hB hA' hB'
    · -- STUFF ∧ U(A,B) branch
      exact case5_sep_with_U_type_Z_gen _ q A B hSTUFF_uf hq hA hB hA' hB'

/-- S(ev, q∨¬U) is separable_with_U_type when ev is U-free.
    Case 4 pattern: S(ev, q∨¬U) ↔ ¬H(¬ev) ∧ ¬case1_psi((¬ev∧¬q), ¬ev, A, B).
    The witness has has_single_U_type because ¬H(¬ev) is U-free and
    case1_psi has single U-type. -/
private theorem snce_Ufree_event_qNotU_guard_sep_with_U_type (ev q A B : Formula)
    (hev_uf : is_U_free ev = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable_with_U_type (.snce ev (Formula.or q (Formula.neg (.untl A B)))) A B := by
  have hna_uf : is_U_free (Formula.neg ev) = true := by simp [Formula.neg, is_U_free, hev_uf]
  have hnq_uf : is_U_free (Formula.neg q) = true := by simp [Formula.neg, is_U_free, hq]
  have hanq_uf : is_U_free (Formula.and (Formula.neg ev) (Formula.neg q)) = true := by
    simp [Formula.and, Formula.neg, is_U_free, hev_uf, hq]
  -- Get non-existential Case 1 properties
  have ⟨hequiv1, hsep1⟩ := case1_psi_properties
    (Formula.and (Formula.neg ev) (Formula.neg q)) (Formula.neg ev) A B
    hanq_uf hna_uf hA hB hA' hB'
  have hsingle1 := case1_psi_has_single_U_type
    (Formula.and (Formula.neg ev) (Formula.neg q)) (Formula.neg ev) A B
    hanq_uf hna_uf hA hB
  let psi1 := case1_psi (Formula.and (Formula.neg ev) (Formula.neg q)) (Formula.neg ev) A B
  -- The witness: ¬H(¬ev) ∧ ¬psi1
  have hsep_H : is_syntactically_separated (.all_past (Formula.neg ev)) = true := by
    simp [is_syntactically_separated, Formula.neg, is_U_free, hev_uf]
  -- Build the is_separable_with_U_type result
  have h_allpast_uf : is_U_free (.all_past (Formula.neg ev)) = true := by
    simp only [Formula.all_past, Formula.some_past]
    simp only [Formula.neg, is_U_free]
    simp only [hev_uf]
    decide
  refine is_separable_with_U_type_of_equiv ?equiv_
    (and_separable_with_U_type
      (neg_separable_with_U_type ⟨.all_past (Formula.neg ev), hsep_H, int_equiv_refl _,
        u_free_has_single_U_type h_allpast_uf⟩)
      (neg_separable_with_U_type ⟨psi1, hsep1, hequiv1, hsingle1⟩))
  -- Equivalence: S(ev, q∨¬U) ↔ ¬H(¬ev) ∧ ¬S((¬ev∧¬q)∧U, ¬ev)
  -- Same semantic proof as in DedekindZ.lean snce_Ufree_event_qNotU_guard_separable
  intro M t; constructor
  · intro hS
    apply int_truth_and_iff.mpr; constructor
    · simp only [int_truth_all_past, Formula.neg, int_truth]
      intro hall; obtain ⟨s, hst, hev_s, _⟩ := hS; exact hall s hst hev_s
    · intro hpsi1
      obtain ⟨s1, hs1t, hevent1, hguard1⟩ := hpsi1
      have ⟨hanq1, hU1⟩ := int_truth_and_iff.mp hevent1
      have hna1 := (int_truth_and_iff.mp hanq1).1
      have hnq1 := (int_truth_and_iff.mp hanq1).2
      obtain ⟨s, hst, hev_s, hguard_S⟩ := hS
      rcases lt_trichotomy s s1 with hss1 | hss1 | hss1
      · rcases int_truth_or_iff.mp (hguard_S s1 hss1 hs1t) with hq1 | hnotU1
        · exact hnq1 hq1
        · exact hnotU1 hU1
      · exact hna1 (hss1 ▸ hev_s)
      · exact (hguard1 s hss1 hst) hev_s
  · intro hand
    have ⟨hnotH, hnotPsi1⟩ := int_truth_and_iff.mp hand
    have hnotS1 : ¬ int_truth M t (.snce (Formula.and (Formula.and (Formula.neg ev) (Formula.neg q))
        (.untl A B)) (Formula.neg ev)) :=
      fun hS1 => hnotPsi1 hS1
    by_contra hnotS
    rcases int_truth_or_iff.mp ((neg_since_equiv ev (Formula.or q (Formula.neg (.untl A B))) M t).mp hnotS) with hH | hS_neg
    · exact hnotH hH
    · obtain ⟨s, hst, hevent, hguard⟩ := hS_neg
      have ⟨hna_s, hnotQnU_s⟩ := int_truth_and_iff.mp hevent
      have hnotQ_s : ¬ int_truth M s q :=
        fun h => (int_truth_neg_iff.mp hnotQnU_s) (int_truth_or_iff.mpr (Or.inl h))
      have hnotNotU_s : ¬ (¬ int_truth M s (.untl A B)) :=
        fun h => (int_truth_neg_iff.mp hnotQnU_s) (int_truth_or_iff.mpr (Or.inr h))
      push_neg at hnotNotU_s
      exact hnotS1 ⟨s, hst, int_truth_and_iff.mpr
        ⟨int_truth_and_iff.mpr ⟨hna_s, hnotQ_s⟩, hnotNotU_s⟩, hguard⟩

set_option maxHeartbeats 1600000 in
/-- Case 7 with U-type: S(a∧U, q∨¬U) is separable_with_U_type A B. -/
theorem case7_sep_with_U_type_Z_gen (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable_with_U_type (.snce (Formula.and a (.untl A B))
      (Formula.or q (Formula.neg (.untl A B)))) A B := by
  apply is_separable_with_U_type_of_equiv (case7_equiv_Z a q A B)
  have hBq_uf : is_U_free (Formula.and B q) = true := by
    simp only [Formula.and, Formula.neg, is_U_free, hB, hq, Bool.true_and, Bool.and_self]
  apply or_separable_with_U_type
  · apply or_separable_with_U_type
    · -- D1 part 1: rearrange + distrib + since_distrib_or_left + cases
      have h_rearrange : int_equiv
        (Formula.and (Formula.and A (Formula.or q (Formula.neg (.untl A B))))
          (.snce a (Formula.and B q)))
        (Formula.and (Formula.and A (.snce a (Formula.and B q)))
          (Formula.or q (Formula.neg (.untl A B)))) := by
        intro M t; constructor
        · intro h
          have ⟨h1, h2⟩ := int_truth_and_iff.mp h
          have ⟨h3, h4⟩ := int_truth_and_iff.mp h1
          exact int_truth_and_iff.mpr ⟨int_truth_and_iff.mpr ⟨h3, h2⟩, h4⟩
        · intro h
          have ⟨h1, h2⟩ := int_truth_and_iff.mp h
          have ⟨h3, h4⟩ := int_truth_and_iff.mp h1
          exact int_truth_and_iff.mpr ⟨int_truth_and_iff.mpr ⟨h3, h2⟩, h4⟩
      apply is_separable_with_U_type_of_equiv (snce_event_congr_hier h_rearrange)
      have h_distrib : int_equiv
        (Formula.and (Formula.and A (.snce a (Formula.and B q)))
          (Formula.or q (Formula.neg (.untl A B))))
        (Formula.or
          (Formula.and (Formula.and A (.snce a (Formula.and B q))) q)
          (Formula.and (Formula.and A (.snce a (Formula.and B q)))
            (Formula.neg (.untl A B)))) := by
        intro M t; constructor
        · intro h
          have ⟨hc, hab⟩ := int_truth_and_iff.mp h
          rcases int_truth_or_iff.mp hab with ha | hb
          · exact int_truth_or_iff.mpr (Or.inl (int_truth_and_iff.mpr ⟨hc, ha⟩))
          · exact int_truth_or_iff.mpr (Or.inr (int_truth_and_iff.mpr ⟨hc, hb⟩))
        · intro h
          rcases int_truth_or_iff.mp h with h1 | h2
          · have ⟨hc, ha⟩ := int_truth_and_iff.mp h1
            exact int_truth_and_iff.mpr ⟨hc, int_truth_or_iff.mpr (Or.inl ha)⟩
          · have ⟨hc, hb⟩ := int_truth_and_iff.mp h2
            exact int_truth_and_iff.mpr ⟨hc, int_truth_or_iff.mpr (Or.inr hb)⟩
      apply is_separable_with_U_type_of_equiv (snce_event_congr_hier h_distrib)
      apply is_separable_with_U_type_of_equiv (since_distrib_or_left _ _
        (Formula.or q (Formula.neg (.untl A B))))
      have hSTUFF_uf : is_U_free (Formula.and A (.snce a (Formula.and B q))) = true := by
        simp only [Formula.and, Formula.neg, is_U_free, hA, ha, hB, hq, Bool.and_self]
      apply or_separable_with_U_type
      · have hev_uf : is_U_free (Formula.and (Formula.and A
            (.snce a (Formula.and B q))) q) = true := by
          simp only [Formula.and, Formula.neg, is_U_free, hA, ha, hB, hq, Bool.and_self]
        exact snce_Ufree_event_qNotU_guard_sep_with_U_type _ q A B hev_uf hq hA hB hA' hB'
      · exact case8_sep_with_U_type_Z_gen
          (Formula.and A (.snce a (Formula.and B q)))
          q A B hSTUFF_uf hq hA hB hA' hB'
    · apply and_separable_with_U_type
      · have hg_uf : is_U_free (Formula.and B q) = true := hBq_uf
        exact ⟨.snce a (Formula.and B q),
          by simp [is_syntactically_separated, ha, hg_uf], int_equiv_refl _,
          ⟨u_free_has_single_U_type ha, u_free_has_single_U_type hBq_uf⟩⟩
      · exact u_free_separable_with_type hA
  · apply and_separable_with_U_type
    · exact and_separable_with_U_type
        ⟨.snce a (Formula.and B q),
          by simp [is_syntactically_separated, ha, hBq_uf], int_equiv_refl _,
          ⟨u_free_has_single_U_type ha, u_free_has_single_U_type hBq_uf⟩⟩
        (u_free_separable_with_type hB)
    · exact untl_s_free_separable_with_type hA' hB'

end Bimodal.Metalogic.WeakCanonical.Separation
