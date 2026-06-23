import Bimodal.Metalogic.WeakCanonical.Kamp.KampBypassBridge

/-!
# Enriched Bypass Formula: Until Direction (t < x)

Forward and backward proof lemmas for the Until direction, plus the
main Until case theorem. Split from KampBypass.lean (task 301).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

set_option maxHeartbeats 3200000 in
/-- Backward direction: ∃ x, nf_eval → holdsLeft for the enriched Until VVecEA2.
    Given a witness x > t with nf_eval_nf, construct holdsLeft by:
    1. Finding the right disjunct (nf_x = nf_characteristic of x)
    2. Sorting between_tx witnesses to determine the permutation
    3. Showing endpointLeft (pre-conditions at t) holds
    4. Providing x as the Until witness with endpointRight + bracket -/
private theorem backward_holdsLeft_of_nf_eval
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (char_1_correct : ∀ (nf_1 : NormalForm sig 1 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_1 nf_1) ↔
        nf_eval_nf M 1 1 (fun _ => t) nf_1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) :
    (∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) →
    ∃ vea ∈ (List.flatMap
        (fun nf_x => if nf_x_compat_check sub_nf nf_x = true then
          enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms
        else []) Fintype.elems.val.toList),
      VecEA2.holdsLeft M atomMap vea.snd t := by
  intro ⟨x, h_eval⟩
  -- Step 1: Get the characteristic NF of x and show compatibility
  let nf_x := nf_characteristic M 1 1 (fun _ => x)
  have h_nf_x : nf_eval_nf M 1 1 (fun _ => x) nf_x :=
    nf_characteristic_satisfies M 1 1 (fun _ => x)
  have h_compat : nf_x_compat_check sub_nf nf_x = true :=
    nf_x_compat_of_nf_eval M sub_nf t x h_eval nf_x h_nf_x
  -- Step 2: Setup
  let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
    | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h
  have h_t_lt_x : t < x := (zone_from_nf_eval M sub_nf t x h_eval).1 h_gt
  obtain ⟨h_eval_atoms, h_eval_quant⟩ := h_eval
  -- Define pos_between and neg_between matching enriched_vecEA2_until's let bindings
  let neg_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
    (ssn_zone_until ssn == .between_tx) && !sub_nf.2 ssn
  let pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
    (ssn_zone_until ssn == .between_tx) && sub_nf.2 ssn
  let seg_guard : TemporalPred :=
    ⟨formula_conjList (neg_between.map fun ssn =>
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg)⟩
  let k := pos_between.length
  -- Step 3: Get witnesses for each pos_between SSN
  have h_pos_witnesses : ∀ ssn ∈ pos_between, ∃ y, t < y ∧ y < x ∧
      ∀ p, M.interp p y ↔ (nf_y_proj ssn) (.pred p ⟨0, by omega⟩) = true := by
    intro ssn h_mem
    rw [List.mem_filter] at h_mem
    obtain ⟨_, h_filter⟩ := h_mem
    simp only [Bool.and_eq_true, beq_iff_eq] at h_filter
    obtain ⟨⟨h_compat', h_zone⟩, h_pos⟩ := h_filter
    have h_exists := (h_eval_quant ssn).mpr h_pos
    exact (between_tx_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
      h_t_lt_x h_compat' h_zone
      (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                   have := h_atom (.pred p ⟨0, by omega⟩)
                   simp only [atom_eval] at this; exact this)
      (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                   simp only [atom_eval] at this; exact this)).mp h_exists
  let witness_fn : Fin k → M.carrier := fun i =>
    (h_pos_witnesses (pos_between.get i) (List.get_mem pos_between i)).choose
  have h_wit_spec : ∀ i, t < witness_fn i ∧ witness_fn i < x ∧
      ∀ p, M.interp p (witness_fn i) ↔ (nf_y_proj (pos_between.get i)) (.pred p ⟨0, by omega⟩) = true := by
    intro i
    exact (h_pos_witnesses (pos_between.get i) (List.get_mem pos_between i)).choose_spec
  -- Step 4: Prove witnesses are injective (same as before)
  have h_wit_injective : Function.Injective witness_fn := by
    intro i j h_eq
    have h_pred_eq' : ∀ p, nf_y_proj (pos_between.get i) (.pred p ⟨0, by omega⟩) =
        nf_y_proj (pos_between.get j) (.pred p ⟨0, by omega⟩) := by
      intro p
      have hi := (h_wit_spec i).2.2 p
      have hj := (h_wit_spec j).2.2 p
      rw [h_eq] at hi
      exact Bool.eq_iff_iff.mpr (hi.symm.trans hj)
    have hi_mem := List.get_mem pos_between i
    have hj_mem := List.get_mem pos_between j
    rw [List.mem_filter] at hi_mem hj_mem
    obtain ⟨_, hi_filt⟩ := hi_mem
    obtain ⟨_, hj_filt⟩ := hj_mem
    simp only [Bool.and_eq_true, beq_iff_eq] at hi_filt hj_filt
    obtain ⟨⟨hi_compat, hi_zone⟩, _⟩ := hi_filt
    obtain ⟨⟨hj_compat, hj_zone⟩, _⟩ := hj_filt
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at hi_compat hj_compat
    obtain ⟨⟨⟨⟨hi_x, hi_t⟩, hi_ord1⟩, hi_ord2⟩, hi_ocons⟩ := hi_compat
    obtain ⟨⟨⟨⟨hj_x, hj_t⟩, hj_ord1⟩, hj_ord2⟩, hj_ocons⟩ := hj_compat
    have h_ylx_i : (pos_between.get i) (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
      simp only [ssn_zone_until] at hi_zone; revert hi_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_ylx_j : (pos_between.get j) (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
      simp only [ssn_zone_until] at hj_zone; revert hj_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_tly_i : (pos_between.get i) (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true := by
      simp only [ssn_zone_until] at hi_zone; revert hi_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_tly_j : (pos_between.get j) (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true := by
      simp only [ssn_zone_until] at hj_zone; revert hj_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_xly_i : (pos_between.get i) (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
      simp only [ssn_zone_until] at hi_zone; revert hi_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_xly_j : (pos_between.get j) (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
      simp only [ssn_zone_until] at hj_zone; revert hj_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_ylt_i : (pos_between.get i) (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
      simp only [ssn_zone_until] at hi_zone; revert hi_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_ylt_j : (pos_between.get j) (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
      simp only [ssn_zone_until] at hj_zone; revert hj_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_ssn_eq : pos_between.get i = pos_between.get j := by
      funext a
      cases a with
      | pred p k =>
        match k with
        | ⟨0, _⟩ => simp only [nf_y_proj] at h_pred_eq'; exact h_pred_eq' p
        | ⟨1, _⟩ => rw [hi_x p (Multiset.mem_toList.mpr (Fintype.complete p)), hj_x p (Multiset.mem_toList.mpr (Fintype.complete p))]
        | ⟨2, _⟩ => rw [hi_t p (Multiset.mem_toList.mpr (Fintype.complete p)), hj_t p (Multiset.mem_toList.mpr (Fintype.complete p))]
      | order k l h_ne =>
        match k, l, h_ne with
        | ⟨0, _⟩, ⟨1, _⟩, _ => rw [h_ylx_i, h_ylx_j]
        | ⟨1, _⟩, ⟨0, _⟩, _ => rw [h_xly_i, h_xly_j]
        | ⟨0, _⟩, ⟨2, _⟩, _ => rw [h_ylt_i, h_ylt_j]
        | ⟨2, _⟩, ⟨0, _⟩, _ => rw [h_tly_i, h_tly_j]
        | ⟨1, _⟩, ⟨2, _⟩, _ => rw [hi_ord2, hj_ord2]
        | ⟨2, _⟩, ⟨1, _⟩, _ => rw [hi_ord1, hj_ord1]
        | ⟨0, _⟩, ⟨0, _⟩, h => exact absurd rfl h
        | ⟨1, _⟩, ⟨1, _⟩, h => exact absurd rfl h
        | ⟨2, _⟩, ⟨2, _⟩, h => exact absurd rfl h
    have h_nodup : pos_between.Nodup :=
      List.Nodup.filter _
        (Multiset.coe_nodup.mp (by rw [Multiset.coe_toList]; exact Finset.nodup _))
    exact Fin.ext
      ((h_nodup.getElem_inj_iff (hi := i.isLt) (hj := j.isLt)).mp h_ssn_eq)
  -- Step 5: Sort witnesses and determine the permutation
  -- Sort witness values using Finset.orderEmbOfFin
  let wit_set : Finset M.carrier := Finset.image witness_fn Finset.univ
  have h_card : wit_set.card = k := by
    rw [Finset.card_image_of_injective _ h_wit_injective]; simp
  -- sorted maps sorted positions to carrier elements
  let sorted := wit_set.orderEmbOfFin h_card
  -- Each sorted element corresponds to some original witness
  have sorted_is_witness : ∀ i : Fin k, ∃ j : Fin k, witness_fn j = sorted i := by
    intro i
    have h_mem := Finset.orderEmbOfFin_mem wit_set h_card i
    rw [Finset.mem_image] at h_mem
    obtain ⟨j, _, hj⟩ := h_mem
    exact ⟨j, hj⟩
  -- Build the sorting permutation: for each sorted position i, find the original index
  -- Use Classical.choice since we know the function is a bijection
  let sort_to_orig : Fin k → Fin k := fun i => (sorted_is_witness i).choose
  have h_sort_spec : ∀ i, witness_fn (sort_to_orig i) = sorted i := by
    intro i; exact (sorted_is_witness i).choose_spec
  -- sort_to_orig is injective (since witness_fn is injective and sorted is injective)
  have h_sort_inj : Function.Injective sort_to_orig := by
    intro i j h_eq
    have : sorted i = sorted j := by
      rw [← h_sort_spec i, ← h_sort_spec j, h_eq]
    exact sorted.injective this
  -- sort_to_orig is a bijection Fin k → Fin k, hence an Equiv.Perm
  have h_sort_surj : Function.Surjective sort_to_orig := by
    exact Finite.surjective_of_injective h_sort_inj
  let σ : Equiv.Perm (Fin k) := Equiv.ofBijective sort_to_orig ⟨h_sort_inj, h_sort_surj⟩
  -- Step 6: Build the specific VecEA2 for permutation σ and show it's in the list
  let endLeft : TemporalPred :=
    ⟨pre_conditions_at_t_until atomMap h_surj sub_nf nf_x_1var parent_atoms⟩
  let right_conjuncts :=
    (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
      if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then
        let zone := ssn_zone_until ssn
        let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
        match zone with
        | .eq_x =>
          if sub_nf.2 ssn then some char_y
          else some char_y.neg
        | .above_x =>
          if sub_nf.2 ssn then some (Formula.untl char_y Formula.top)
          else some (Formula.untl char_y Formula.top).neg
        | _ => none
      else none
  let endRight : TemporalPred :=
    ⟨Formula.and (char_1 nf_x) (formula_conjList right_conjuncts)⟩
  let the_bracket : BracketFormula k :=
    { pointTypes := fun i =>
        ⟨nf_depth0_char_formula atomMap h_surj (nf_y_proj (pos_between.get (σ i)))⟩
      segmentTypes := fun _ => seg_guard }
  let the_vea : Σ n, VecEA2 n :=
    ⟨k, VecEA2.mk endLeft endRight the_bracket⟩
  -- Show the_vea is in the flatMap list
  have h_mem_elems : nf_x ∈ Fintype.elems.val := Fintype.complete nf_x
  have h_σ_mem : σ ∈ (Fintype.elems (α := Equiv.Perm (Fin k))).val := Fintype.complete σ
  have h_vea_mem : the_vea ∈ List.flatMap
      (fun nf_x' => if nf_x_compat_check sub_nf nf_x' = true then
        enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x'
          (fun a => match a with
            | .pred p _ => nf_x'.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          parent_atoms
      else []) Fintype.elems.val.toList := by
    rw [List.mem_flatMap]
    refine ⟨nf_x, Multiset.mem_toList.mpr h_mem_elems, ?_⟩
    simp only [h_compat, ite_true]
    -- Need: the_vea ∈ enriched_vecEA2_until ... = list of permutation VecEA2s
    simp only [enriched_vecEA2_until]
    rw [List.mem_map]
    exact ⟨σ, Multiset.mem_toList.mpr h_σ_mem, rfl⟩
  -- Step 7: Show holdsLeft for the_vea
  refine ⟨the_vea, h_vea_mem, ?_⟩
  simp only [VecEA2.holdsLeft]
  refine ⟨?endLeft, x, h_t_lt_x, ?endRight, ?bracket⟩
  case endLeft =>
    simp only [TemporalPred.eval_at]
    exact pre_conditions_at_t_until_holds M atomMap h_surj sub_nf nf_x_1var parent_atoms x t
      h_t_lt_x
      (fun p => by
        obtain ⟨h_atom, _⟩ := h_nf_x
        have := h_atom (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at this
        exact this)
      (fun p => by
        have := h_atoms (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at this
        exact this)
      h_eval_quant
  case endRight =>
    simp only [TemporalPred.eval_at]
    show temporal_truth M atomMap x (Formula.and (char_1 nf_x) (formula_conjList _))
    rw [temporal_truth_and]
    constructor
    · exact (char_1_correct nf_x M h_UZ h_SZ x).mpr h_nf_x
    · rw [formula_conjList_iff]
      intro φ h_mem
      rw [List.mem_filterMap] at h_mem
      obtain ⟨ssn, h_ssn_mem, h_some⟩ := h_mem
      split_ifs at h_some with h_compat' h_pos
      · revert h_some
        rcases h_zone : ssn_zone_until ssn with _ | _ | _ | _ | _ | _
        all_goals simp
        all_goals intro h_eq; subst h_eq
        · exact (eq_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_t_lt_x
            h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)).mpr
            ((h_eval_quant ssn).mpr h_pos)
        · exact (above_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_t_lt_x
            h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)).mpr
            ((h_eval_quant ssn).mpr h_pos)
      · revert h_some
        rcases h_zone : ssn_zone_until ssn with _ | _ | _ | _ | _ | _
        all_goals simp
        all_goals intro h_eq; subst h_eq
        · simp only [Formula.neg, temporal_truth]
          intro h_char
          have h_exist := (eq_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)).mp h_char
          exact absurd ((h_eval_quant ssn).mp h_exist) h_pos
        · simp only [Formula.neg, temporal_truth]
          intro h_until
          have h_exist := (above_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)).mp h_until
          exact absurd ((h_eval_quant ssn).mp h_exist) h_pos
  case bracket =>
    -- BracketFormula with per-SSN pointTypes. Provide sorted witnesses.
    -- seg_guard holds everywhere in (t, x)
    have seg_guard_on_interval : ∀ y : M.carrier, t < y → y < x →
        seg_guard.eval_at M atomMap y := by
      intro y h_ty h_yx
      simp only [TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro φ h_φ_mem
      rw [List.mem_map] at h_φ_mem
      obtain ⟨ssn, h_ssn_mem, h_φ_eq⟩ := h_φ_mem
      subst h_φ_eq
      rw [List.mem_filter] at h_ssn_mem
      obtain ⟨_, h_filter⟩ := h_ssn_mem
      simp only [Bool.and_eq_true, beq_iff_eq, Bool.not_eq_eq_eq_not, Bool.not_true] at h_filter
      obtain ⟨⟨h_compat', h_zone⟩, h_neg⟩ := h_filter
      simp only [Formula.neg, temporal_truth]
      intro h_char_y
      have h_bridge := (between_tx_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
        h_t_lt_x h_compat' h_zone
        (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                     have := h_atom (.pred p ⟨0, by omega⟩)
                     simp only [atom_eval] at this; exact this)
        (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                     simp only [atom_eval] at this; exact this)).mpr
      have h_no_witness : ¬ ∃ z, nf_eval_nf M 0 (1 + 1 + 1)
          (Fin.cons z (Fin.cons x fun _ => t)) ssn := by
        rw [h_eval_quant ssn]; simp [h_neg]
      apply h_no_witness; apply h_bridge
      exact ⟨y, h_ty, h_yx, fun p => by
        rw [nf_depth0_char_formula_correct] at h_char_y
        have := h_char_y p; simp only [nf_y_proj] at this; exact this⟩
    -- The bracket has per-SSN pointTypes[i] = char_y(pos_between[σ(i)]).
    -- We provide sorted witnesses: sorted[i] = witness_fn(σ i).
    -- sorted is strictly monotone (from Finset.orderEmbOfFin).
    -- sorted[i] satisfies char_y(pos_between[σ(i)]) because
    -- witness_fn(σ i) satisfies char_y(pos_between.get(σ i)) by h_wit_spec.
    -- Construct the sorted witness function
    let sorted_fn : Fin k → M.carrier := fun i => sorted i
    have h_sorted_eq_wit : ∀ i, sorted_fn i = witness_fn (σ i) := by
      intro i; exact (h_sort_spec i).symm
    have h_sorted_mono : StrictMono sorted_fn := by
      intro i j h_ij; exact sorted.strictMono h_ij
    have h_sorted_in_interval : ∀ i, t < sorted_fn i ∧ sorted_fn i < x := by
      intro i
      rw [h_sorted_eq_wit i]
      exact ⟨(h_wit_spec (σ i)).1, (h_wit_spec (σ i)).2.1⟩
    have h_sorted_ptType : ∀ i, (the_bracket.pointTypes i).eval_at M atomMap (sorted_fn i) := by
      intro i
      simp only [TemporalPred.eval_at]
      rw [h_sorted_eq_wit i]
      rw [nf_depth0_char_formula_correct]
      exact fun p => (h_wit_spec (σ i)).2.2 p
    exact bracket_from_sorted_witnesses M atomMap k t x h_t_lt_x
      the_bracket.pointTypes seg_guard sorted_fn
      h_sorted_mono h_sorted_in_interval h_sorted_ptType seg_guard_on_interval

set_option maxHeartbeats 3200000 in
/-- Forward direction: holdsLeft for the enriched Until VVecEA2 → ∃ x, nf_eval.
    Given holdsLeft (some disjunct is satisfied), extract x and reconstruct nf_eval.
    With per-SSN pointTypes, each bracket witness directly identifies its SSN. -/
private theorem forward_nf_eval_of_holdsLeft
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (char_1_correct : ∀ (nf_1 : NormalForm sig 1 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_1 nf_1) ↔
        nf_eval_nf M 1 1 (fun _ => t) nf_1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_t_compat : ∀ p : sig.preds, sub_nf.1 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩))
    (h_ssn_compat : ∀ ssn : NormalForm sig 0 3, sub_nf.2 ssn = true →
        ssn_xt_compatible ssn (fun a => match a with
          | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h) parent_atoms true false = true) :
    (∃ vea ∈ (List.flatMap
        (fun nf_x => if nf_x_compat_check sub_nf nf_x = true then
          enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms
        else []) Fintype.elems.val.toList),
      VecEA2.holdsLeft M atomMap vea.snd t) →
    ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
  intro ⟨⟨n, vea⟩, h_mem, h_holds⟩
  -- Extract nf_x from the flatMap membership
  rw [List.mem_flatMap] at h_mem
  obtain ⟨nf_x, _, h_in_list⟩ := h_mem
  -- nf_x_compat_check must be true for non-empty list
  split_ifs at h_in_list with h_compat
  · -- Compatible case: ⟨n, vea⟩ ∈ enriched_vecEA2_until ...
    -- Extract the permutation σ from the list membership
    simp only [enriched_vecEA2_until] at h_in_list
    rw [List.mem_map] at h_in_list
    obtain ⟨σ, _, h_vea_eq⟩ := h_in_list
    -- h_vea_eq : ⟨k, { ... bracket with pointTypes = char_y(pos_between[σ(i)]) ... }⟩ = ⟨n, vea⟩
    let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
      | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
      | .order i j h => absurd (Fin.ext (by omega) : i = j) h
    let pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
      ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
      (ssn_zone_until ssn == .between_tx) && sub_nf.2 ssn
    -- From h_vea_eq, n = pos_between.length
    have h_n_eq : n = pos_between.length := by
      have := congrArg Sigma.fst h_vea_eq; simp at this; exact this.symm
    -- Extract holdsLeft components
    rw [show (⟨n, vea⟩ : Σ n, VecEA2 n).snd = vea from rfl] at h_holds
    simp only [VecEA2.holdsLeft] at h_holds
    obtain ⟨h_endLeft, x, h_t_lt_x, h_endRight, h_bracket⟩ := h_holds
    -- x is the witness for the existential
    refine ⟨x, ?_⟩
    -- Extract char_1(nf_x) from endpointRight (shared by atom + quantifier parts)
    have h_vea_right : vea.endpointRight =
          (⟨Formula.and (char_1 nf_x) (formula_conjList
            ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
              if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then
                let zone := ssn_zone_until ssn
                let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
                match zone with
                | .eq_x => if sub_nf.2 ssn then some char_y else some char_y.neg
                | .above_x =>
                  if sub_nf.2 ssn then some (Formula.untl char_y Formula.top)
                  else some (Formula.untl char_y Formula.top).neg
                | _ => none
              else none))⟩ : TemporalPred) := by
        have := congrArg (fun s => s.snd.endpointRight) h_vea_eq
        simp at this; exact this.symm
    simp only [TemporalPred.eval_at] at h_endRight
    rw [h_vea_right] at h_endRight
    simp only [TemporalPred.eval_at] at h_endRight
    have h_endRight_temporal := h_endRight
    rw [temporal_truth_and] at h_endRight_temporal
    have h_nf_x_eval := (char_1_correct nf_x M h_UZ h_SZ x).mp h_endRight_temporal.1
    obtain ⟨h_nf_x_atoms, _⟩ := h_nf_x_eval
    -- Reconstruct nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf
    constructor
    · -- Atom part
      intro a
      cases a with
      | pred p k =>
        match k with
        | ⟨0, _⟩ =>
          -- sub_nf.1 (.pred p 0) = nf_x.1 (.pred p 0) from h_compat
          have h := h_nf_x_atoms (.pred p ⟨0, by omega⟩)
          simp only [atom_eval, Fin.cons] at h ⊢
          simp only [nf_x_compat_check, List.all_eq_true] at h_compat
          have hc := h_compat p (Multiset.mem_toList.mpr (Fintype.complete p))
          rw [beq_iff_eq] at hc
          rw [← hc]; exact h
        | ⟨1, _⟩ =>
          -- sub_nf.1 (.pred p 1) = parent_atoms (.pred p 0)
          -- atom_eval M (fun _ => t) (.pred p 0) ↔ parent_atoms (.pred p 0) = true
          have h := h_atoms (.pred p ⟨0, by omega⟩)
          simp only [atom_eval, Fin.cons] at h ⊢
          rw [h_t_compat p]; exact h
      | order k l h_ne =>
        match k, l, h_ne with
        | ⟨0, _⟩, ⟨0, _⟩, h => exact absurd rfl h
        | ⟨1, _⟩, ⟨1, _⟩, h => exact absurd rfl h
        | ⟨0, _⟩, ⟨1, _⟩, _ =>
          -- sub_nf.1 (.order 0 1 _) is the x < t order
          simp only [atom_eval, Fin.cons]
          constructor
          · intro h_x_lt_t; exact absurd (lt_trans h_t_lt_x h_x_lt_t) (lt_irrefl _)
          · intro h_eq; rw [h_eq] at h_lt; exact absurd h_lt (by simp)
        | ⟨1, _⟩, ⟨0, _⟩, _ =>
          -- sub_nf.1 (.order 1 0 _) = true means t < x
          simp only [atom_eval, Fin.cons]
          constructor
          · intro _; exact h_gt
          · intro _; exact h_t_lt_x
    · -- Quantifier part: ∀ ssn, (∃ y, nf_eval_nf M 0 3 [y,x,t] ssn) ↔ sub_nf.2 ssn = true
      -- Helper: x-predicates and t-predicates from h_nf_x_atoms and h_atoms
      have h_x_pred : ∀ p : sig.preds,
          M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true := by
        intro p; have h := h_nf_x_atoms (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at h; exact h
      have h_t_pred : ∀ p : sig.preds,
          M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true := by
        intro p; have h := h_atoms (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at h; exact h
      -- Extract endpointLeft as pre_conditions_at_t_until
      have h_vea_left : vea.endpointLeft =
          (⟨pre_conditions_at_t_until atomMap h_surj sub_nf nf_x_1var parent_atoms⟩ : TemporalPred) := by
        have := congrArg (fun s => s.snd.endpointLeft) h_vea_eq
        simp at this; exact this.symm
      simp only [TemporalPred.eval_at] at h_endLeft
      rw [h_vea_left] at h_endLeft
      simp only [TemporalPred.eval_at] at h_endLeft
      -- h_endLeft : temporal_truth M atomMap t (pre_conditions_at_t_until ...)
      -- h_endRight_temporal.2 : temporal_truth M atomMap x (formula_conjList right_conjuncts)
      have h_right_conj := h_endRight_temporal.2
      -- Helper: the filterMap function for pre_conditions
      let pre_fn := fun ssn' : NormalForm sig 0 3 =>
        if ssn_xt_compatible ssn' nf_x_1var parent_atoms true false then
          let zone := ssn_zone_until ssn'
          let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn')
          match zone with
          | .below_t =>
            if sub_nf.2 ssn' then some (Formula.snce char_y Formula.top)
            else some (Formula.snce char_y Formula.top).neg
          | .eq_t =>
            if sub_nf.2 ssn' then some char_y
            else some char_y.neg
          | _ => none
        else none
      -- Helper: the filterMap function for right_conjuncts
      let right_fn := fun ssn' : NormalForm sig 0 3 =>
        if ssn_xt_compatible ssn' nf_x_1var parent_atoms true false then
          let zone := ssn_zone_until ssn'
          let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn')
          match zone with
          | .eq_x =>
            if sub_nf.2 ssn' then some char_y
            else some char_y.neg
          | .above_x =>
            if sub_nf.2 ssn' then some (Formula.untl char_y Formula.top)
            else some (Formula.untl char_y Formula.top).neg
          | _ => none
        else none
      -- h_endLeft unfolds to formula_conjList of pre_fn applied to Fintype.elems
      have h_endLeft_conj : ∀ φ ∈ (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn,
          temporal_truth M atomMap t φ := by
        have : pre_conditions_at_t_until atomMap h_surj sub_nf nf_x_1var parent_atoms =
            formula_conjList ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn) := rfl
        rw [this] at h_endLeft
        exact (formula_conjList_iff M atomMap t _).mp h_endLeft
      -- h_right_conj unfolds to formula_conjList of right_fn
      have h_right_conj_all : ∀ φ ∈ (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap right_fn,
          temporal_truth M atomMap x φ := by
        exact (formula_conjList_iff M atomMap x _).mp h_right_conj
      -- Helper: ref_nf_x_1var = nf_x_1var (since nf_x_compat_check says nf_x matches sub_nf)
      have h_ref_eq_nfx : (fun a => match a with
          | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h) = nf_x_1var := by
        funext a; cases a with
        | pred p k =>
          simp only [nf_x_compat_check, List.all_eq_true] at h_compat
          have hc := h_compat p (Multiset.mem_toList.mpr (Fintype.complete p))
          rw [beq_iff_eq] at hc; exact hc.symm
        | order i j h_ne => exact absurd (Fin.ext (by omega) : i = j) h_ne
      -- Helper: membership in filterMap
      have h_ssn_in_elems : ∀ ssn' : NormalForm sig 0 3,
          ssn' ∈ (Fintype.elems (α := NormalForm sig 0 3)).val.toList :=
        fun ssn' => Multiset.mem_toList.mpr (Fintype.complete ssn')
      -- Per-ssn proof
      intro ssn
      by_cases h_ssn_xt : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true
      · -- xt-compatible case
        rcases h_zone : ssn_zone_until ssn with _ | _ | _ | _ | _ | _
        · -- below_t: Since(char_y, ⊤) at t ↔ ∃ y
          have h_bridge := below_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_ssn_xt h_zone h_x_pred h_t_pred
          constructor
          · intro h_exist
            by_contra h_neg
            have h_in : (Formula.snce (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top).neg ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .below_t => _ | .eq_t => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [show sub_nf.2 ssn = false from Bool.eq_false_iff.mpr h_neg]; rfl
            have := h_endLeft_conj _ h_in
            simp only [Formula.neg, temporal_truth] at this
            exact this (h_bridge.mpr h_exist)
          · intro h_pos
            have h_in : (Formula.snce (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .below_t => _ | .eq_t => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [h_pos]; rfl
            exact h_bridge.mp (h_endLeft_conj _ h_in)
        · -- eq_t: char_y at t ↔ ∃ y
          have h_bridge := eq_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_ssn_xt h_zone h_x_pred h_t_pred
          constructor
          · intro h_exist
            by_contra h_neg
            have h_in : (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .below_t => _ | .eq_t => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [show sub_nf.2 ssn = false from Bool.eq_false_iff.mpr h_neg]; rfl
            have := h_endLeft_conj _ h_in
            simp only [Formula.neg, temporal_truth] at this
            exact this (h_bridge.mpr h_exist)
          · intro h_pos
            have h_in : (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .below_t => _ | .eq_t => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [h_pos]; rfl
            exact h_bridge.mp (h_endLeft_conj _ h_in)
        · -- between_tx: bracket handles this via per-SSN pointTypes
          have h_bridge := between_tx_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_ssn_xt h_zone h_x_pred h_t_pred
          -- Extract bracket from h_vea_eq via dependent type cast
          subst h_n_eq
          have h_vea_eq3 := eq_of_heq (Sigma.mk.inj h_vea_eq).2
          have h_bracket_eq := congrArg VecEA2.bracket h_vea_eq3
          rw [← h_bracket_eq] at h_bracket
          -- h_bracket now has the explicit bracket structure with per-SSN pointTypes
          -- Define neg_between and seg_guard for convenience
          let neg_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn' =>
            ssn_xt_compatible ssn' nf_x_1var parent_atoms true false &&
            (ssn_zone_until ssn' == .between_tx) && !sub_nf.2 ssn'
          let seg_guard : TemporalPred :=
            ⟨formula_conjList (neg_between.map fun ssn' =>
              (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn')).neg)⟩
          constructor
          · -- → direction: ∃ y → sub_nf.2 ssn = true
            intro h_exist
            by_contra h_neg
            -- Get y via bridge
            obtain ⟨y, h_ty, h_yx, h_y_pred⟩ := h_bridge.mp h_exist
            -- ssn is in neg_between
            have h_ssn_in_neg : ssn ∈ neg_between := by
              rw [List.mem_filter]
              exact ⟨h_ssn_in_elems ssn, by simp [h_ssn_xt, h_zone, h_neg]⟩
            -- seg_guard includes ¬char_y(nf_y_proj ssn)
            -- From h_bracket, seg_guard holds on every segment of (t, x).
            -- y ∈ (t, x). We need: seg_guard holds at y.
            -- The bracket is: BracketFormula.holds with per-SSN pointTypes and constant seg_guard.
            -- Unfolding: there exist strictly increasing witnesses w_0 < ... < w_{k-1} in (t, x)
            -- with per-SSN pointTypes, and seg_guard on each segment.
            -- y is either a witness or in a segment.
            -- If y is a witness w_i: w_i satisfies char_y(pos_between[σ(i)]), which is a POSITIVE ssn.
            --   Since ssn is NEGATIVE, nf_y_proj ssn ≠ nf_y_proj pos_between[σ(i)].
            --   But char_y is determined by nf_y_proj. If y satisfies both char_y(nf_y_proj ssn) AND
            --   char_y(pos_between[σ(i)]), then nf_y_proj ssn = nf_y_proj pos_between[σ(i)] (by char_y injectivity).
            --   But they differ (positive vs negative) → contradiction... actually they could have
            --   the same y-proj but differ in other atoms. No, between_tx SSNs with same nf_y_proj
            --   and same x/t compatibility are identical. So nf_y_proj ssn ≠ nf_y_proj pos_between[σ(i)]
            --   means char_y(nf_y_proj ssn) can't hold at y if char_y(pos_between[σ(i)]) holds.
            rcases bracket_constant_seg_dichotomy M atomMap
              pos_between.length t x _ seg_guard h_bracket y h_ty h_yx with
              h_seg | ⟨i, h_pt⟩
            · -- Case 1: seg_guard holds at y — contradicts h_y_pred
              simp only [TemporalPred.eval_at] at h_seg
              rw [formula_conjList_iff] at h_seg
              have h_neg_char := h_seg _
                (List.mem_map.mpr ⟨ssn, h_ssn_in_neg, rfl⟩)
              simp only [Formula.neg, temporal_truth] at h_neg_char
              apply h_neg_char
              rw [nf_depth0_char_formula_correct]
              intro p; simp only [nf_y_proj]; exact h_y_pred p
            · -- Case 2: pointType i holds at y — ssn = pos_between.get (σ i)
              simp only [TemporalPred.eval_at] at h_pt
              rw [nf_depth0_char_formula_correct] at h_pt
              -- Extract compat/zone/pos info for pos_between.get (σ i) from membership
              have h_σi_mem : pos_between.get (σ i) ∈ pos_between := List.get_mem pos_between (σ i)
              rw [List.mem_filter] at h_σi_mem
              obtain ⟨_, h_σi_raw⟩ := h_σi_mem
              simp only [Bool.and_eq_true, beq_iff_eq] at h_σi_raw
              obtain ⟨⟨h_σi_compat_raw, h_σi_zone⟩, h_σi_pos⟩ := h_σi_raw
              -- Destructure ssn_xt_compatible for both SSNs
              have h1_compat := h_ssn_xt
              simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq,
                List.all_eq_true] at h1_compat h_σi_compat_raw
              obtain ⟨⟨⟨⟨h1_x, h1_t⟩, h1_ord1⟩, h1_ord2⟩, _⟩ := h1_compat
              obtain ⟨⟨⟨⟨h2_x, h2_t⟩, h2_ord1⟩, h2_ord2⟩, _⟩ := h_σi_compat_raw
              -- Derive y-pred equality from h_y_pred and h_pt
              have h_pred_eq : ∀ p, ssn (.pred p ⟨0, by omega⟩) =
                  (pos_between.get (σ i)) (.pred p ⟨0, by omega⟩) := by
                intro p
                have h1 := h_y_pred p
                have h2 := h_pt p
                simp only [nf_y_proj] at h2
                exact Bool.eq_iff_iff.mpr (h1.symm.trans h2)
              obtain ⟨h1_ylx, h1_xly, h1_ylt, h1_tly⟩ := between_tx_order_atoms ssn h_zone
              obtain ⟨h2_ylx, h2_xly, h2_ylt, h2_tly⟩ := between_tx_order_atoms _ h_σi_zone
              have h_ssn_eq : ssn = pos_between.get (σ i) := by
                funext a; cases a with
                | pred p k =>
                  match k with
                  | ⟨0, _⟩ => exact h_pred_eq p
                  | ⟨1, _⟩ =>
                    exact (h1_x p (Multiset.mem_toList.mpr (Fintype.complete p))).trans
                      (h2_x p (Multiset.mem_toList.mpr (Fintype.complete p))).symm
                  | ⟨2, _⟩ =>
                    exact (h1_t p (Multiset.mem_toList.mpr (Fintype.complete p))).trans
                      (h2_t p (Multiset.mem_toList.mpr (Fintype.complete p))).symm
                | order k l h_ne =>
                  match k, l, h_ne with
                  | ⟨0, _⟩, ⟨1, _⟩, _ => rw [h1_ylx, h2_ylx]
                  | ⟨1, _⟩, ⟨0, _⟩, _ => rw [h1_xly, h2_xly]
                  | ⟨0, _⟩, ⟨2, _⟩, _ => rw [h1_ylt, h2_ylt]
                  | ⟨2, _⟩, ⟨0, _⟩, _ => rw [h1_tly, h2_tly]
                  | ⟨1, _⟩, ⟨2, _⟩, _ => exact h1_ord2.trans h2_ord2.symm
                  | ⟨2, _⟩, ⟨1, _⟩, _ => exact h1_ord1.trans h2_ord1.symm
                  | ⟨0, _⟩, ⟨0, _⟩, h => exact absurd rfl h
                  | ⟨1, _⟩, ⟨1, _⟩, h => exact absurd rfl h
                  | ⟨2, _⟩, ⟨2, _⟩, h => exact absurd rfl h
              rw [h_ssn_eq] at h_neg
              exact absurd h_σi_pos h_neg
          · -- ← direction: sub_nf.2 ssn = true → ∃ y
            intro h_pos
            -- ssn ∈ pos_between
            have h_ssn_in_pos : ssn ∈ pos_between := by
              rw [List.mem_filter]
              exact ⟨h_ssn_in_elems ssn, by simp [h_ssn_xt, h_zone, h_pos]⟩
            -- Find j such that pos_between[j] = ssn
            obtain ⟨j, hj⟩ := List.get_of_mem h_ssn_in_pos
            obtain ⟨w, h_tw, h_wx, h_w_pt⟩ := bracket_extract_witness M atomMap
              pos_between.length t x _ _ h_bracket (σ.symm j)
            simp only [TemporalPred.eval_at] at h_w_pt
            rw [nf_depth0_char_formula_correct] at h_w_pt
            apply h_bridge.mpr
            refine ⟨w, h_tw, h_wx, fun p => ?_⟩
            have := h_w_pt p
            simp only [nf_y_proj, Equiv.apply_symm_apply] at this
            rw [← hj]; exact this
        · -- eq_x: char_y at x ↔ ∃ y
          have h_bridge := eq_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_ssn_xt h_zone h_x_pred h_t_pred
          constructor
          · intro h_exist
            by_contra h_neg
            have h_in : (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap right_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .eq_x => _ | .above_x => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [show sub_nf.2 ssn = false from Bool.eq_false_iff.mpr h_neg]; rfl
            have := h_right_conj_all _ h_in
            simp only [Formula.neg, temporal_truth] at this
            exact this (h_bridge.mpr h_exist)
          · intro h_pos
            have h_in : (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap right_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .eq_x => _ | .above_x => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [h_pos]; rfl
            exact h_bridge.mp (h_right_conj_all _ h_in)
        · -- above_x: Until(char_y, ⊤) at x ↔ ∃ y
          have h_bridge := above_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_ssn_xt h_zone h_x_pred h_t_pred
          constructor
          · intro h_exist
            by_contra h_neg
            have h_in : (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top).neg ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap right_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .eq_x => _ | .above_x => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [show sub_nf.2 ssn = false from Bool.eq_false_iff.mpr h_neg]; rfl
            have := h_right_conj_all _ h_in
            simp only [Formula.neg, temporal_truth] at this
            exact this (h_bridge.mpr h_exist)
          · intro h_pos
            have h_in : (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap right_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .eq_x => _ | .above_x => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [h_pos]; rfl
            exact h_bridge.mp (h_right_conj_all _ h_in)
        · -- inconsistent zone: ssn_xt_compatible = true includes ssn_order_consistent = true,
          -- which is incompatible with ssn_zone_until = .inconsistent.
          exfalso
          simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_ssn_xt
          simp only [ssn_zone_until] at h_zone
          simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
            Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_ssn_xt
          revert h_zone; split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all
      · -- NOT xt-compatible: both sides false via h_ssn_compat
        constructor
        · -- ∃ y → sub_nf.2 ssn = true
          -- If ∃ y with nf_eval, ssn must be xt-compatible (semantic argument).
          intro h_exist; exfalso
          obtain ⟨y, h_ssn_eval⟩ := h_exist
          have h_xt_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true := by
            simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true]
            refine ⟨⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩, ?_⟩
            · intro p _
              have h1 := h_ssn_eval (.pred p ⟨1, by omega⟩); unfold atom_eval at h1
              cases hsub : (nf_x_1var (.pred p ⟨0, by omega⟩) : Bool) <;>
              cases hssn : ssn (.pred p ⟨1, by omega⟩) <;>
              first | rfl | (exfalso; simp_all)
            · intro p _
              have h1 : M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true := by
                have h := h_ssn_eval (.pred p ⟨2, by omega⟩); unfold atom_eval at h; exact h
              cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;>
              cases hssn : ssn (.pred p ⟨2, by omega⟩) <;>
              first | rfl | (exfalso; simp_all [h_t_pred])
            · have h := h_ssn_eval (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by simp [Fin.ext_iff]))
              simp only [atom_eval, Fin.cons] at h; exact h.mp h_t_lt_x
            · have h := h_ssn_eval (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by simp [Fin.ext_iff]))
              simp only [atom_eval, Fin.cons] at h
              cases hssn : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by simp [Fin.ext_iff]))
              · rfl
              · exact absurd (h.mpr hssn) (not_lt_of_gt h_t_lt_x)
            · exact ssn_order_consistent_of_eval ssn h_ssn_eval
          exact absurd h_xt_compat h_ssn_xt
        · intro h_pos
          exfalso
          have := h_ssn_compat ssn h_pos
          rw [h_ref_eq_nfx] at this
          exact absurd this h_ssn_xt
  · -- Incompatible case: empty list, contradiction
    simp at h_in_list
/-! ## Until Case (t < x) -/

set_option maxHeartbeats 1600000 in
/-- Until case of the enriched bypass: when sub_nf says t < x. -/
theorem existPart_succ_n1_bypass_k0_until
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (char_1_correct : ∀ (nf_1 : NormalForm sig 1 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_1 nf_1) ↔
        nf_eval_nf M 1 1 (fun _ => t) nf_1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  -- Syntactic compatibility checks for sub_nf.
  -- 1. t-predicate compatibility: sub_nf.1 (.pred p 1) = parent_atoms (.pred p 0)
  -- 2. ssn compatibility: all positive ssn match the canonical reference nf_x_1var
  -- Use a canonical reference nf_x_1var built from sub_nf.1 (same for all compatible nf_x):
  let ref_nf_x_1var : NormalForm sig 0 1 := fun a => match a with
    | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h
  by_cases h_t_compat : ∀ p : sig.preds,
      sub_nf.1 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩)
  · by_cases h_ssn_compat : ∀ ssn : NormalForm sig 0 3,
        sub_nf.2 ssn = true →
        ssn_xt_compatible ssn ref_nf_x_1var parent_atoms true false = true
    · -- Both checks pass: use enriched_bypass_until with full biconditional
      let vvec := enriched_bypass_until atomMap h_surj char_1 sub_nf parent_atoms
      exact ⟨vvec, fun M h_UZ h_SZ t h_atoms => by
        show temporal_truth M atomMap t (enriched_bypass_until atomMap h_surj char_1 sub_nf parent_atoms) ↔ _
        simp only [enriched_bypass_until]
        rw [VVecEA2.translateLeft_correct]
        simp only [VVecEA2.holdsLeft]
        constructor
        · -- Forward: holdsLeft → ∃ x, nf_eval
          exact forward_nf_eval_of_holdsLeft atomMap h_surj char_1 char_1_correct
            parent_atoms sub_nf h_gt h_lt M h_UZ h_SZ t h_atoms h_t_compat h_ssn_compat
        · -- Backward: ∃ x, nf_eval → holdsLeft
          exact backward_holdsLeft_of_nf_eval atomMap h_surj char_1 char_1_correct
            parent_atoms sub_nf h_gt h_lt M h_UZ h_SZ t h_atoms⟩
    · -- ¬ssn_compat: some positive ssn is xt-incompatible → existential unsatisfiable
      push_neg at h_ssn_compat
      obtain ⟨ssn_bad, h_pos_bad, h_incompat_bad⟩ := h_ssn_compat
      refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
      simp only [temporal_truth]
      constructor
      · exact fun h => absurd h id
      · intro ⟨x, h_eval⟩
        obtain ⟨h_atom, h_quant⟩ := h_eval
        -- sub_nf.2 ssn_bad = true → ∃ y, nf_eval_nf M 0 3 (y,x,t₀) ssn_bad
        have ⟨y, h_ssn_eval⟩ := (h_quant ssn_bad).mpr h_pos_bad
        -- From h_ssn_eval + h_atom + h_atoms, derive ssn_xt_compatible
        -- But h_incompat_bad says it's NOT compatible → contradiction
        -- The key: ref_nf_x_1var (.pred p 0) = sub_nf.1 (.pred p 0)
        -- And h_atom says atom_eval M (Fin.cons x (fun _ => t₀)) (.pred p 0) ↔ sub_nf.1 (.pred p 0) = true
        -- So M.interp p x ↔ ref_nf_x_1var (.pred p 0) = true
        -- Similarly for t's atoms. So ssn_bad must be xt-compatible with ref_nf_x_1var.
        have h_x_pred : ∀ p : sig.preds,
            M.interp p x ↔ ref_nf_x_1var (.pred p ⟨0, by omega⟩) = true := by
          intro p; have h := h_atom (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
        have h_t_pred : ∀ p : sig.preds,
            M.interp p t₀ ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true := by
          intro p; have h := h_atoms (.pred p ⟨0, by omega⟩); simp only [atom_eval] at h; exact h
        have h_t_lt_x : t₀ < x := by
          have h := h_atom (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
          unfold atom_eval at h; exact h.mpr h_gt
        -- From h_ssn_eval, ssn_bad's atoms at indices 1,2 must match x and t₀
        -- and its orders must be consistent. This forces ssn_xt_compatible = true.
        -- Derive contradiction with h_incompat_bad.
        have h_xt_compat : ssn_xt_compatible ssn_bad ref_nf_x_1var parent_atoms true false = true := by
          simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true]
          refine ⟨⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩, ?_⟩
          · -- x-preds: ssn_bad (.pred p 1) = ref_nf_x_1var (.pred p 0) = sub_nf.1 (.pred p 0)
            intro p _
            have h1 := h_ssn_eval (.pred p ⟨1, by omega⟩); unfold atom_eval at h1
            -- h1 : M.interp p x ↔ ssn_bad (.pred p 1) = true
            -- h_x_pred p : M.interp p x ↔ ref_nf_x_1var (.pred p 0) = true
            -- ref_nf_x_1var (.pred p 0) = sub_nf.1 (.pred p 0) by definition
            cases hsub : (ref_nf_x_1var (.pred p ⟨0, by omega⟩) : Bool) <;>
            cases hssn : ssn_bad (.pred p ⟨1, by omega⟩) <;>
            first | rfl | (exfalso; simp_all)
          · -- t-preds: ssn_bad (.pred p 2) = parent_atoms (.pred p 0)
            intro p _
            have h1 : M.interp p t₀ ↔ ssn_bad (.pred p ⟨2, by omega⟩) = true := by
              have h := h_ssn_eval (.pred p ⟨2, by omega⟩); unfold atom_eval at h; exact h
            have h2 := h_atoms (.pred p ⟨0, by omega⟩); simp only [atom_eval] at h2
            -- h2 : M.interp p t₀ ↔ parent_atoms (.pred p 0) = true
            cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;>
            cases hssn : ssn_bad (.pred p ⟨2, by omega⟩) <;>
            first | rfl | (exfalso; simp_all)
          · -- t < x order: ssn_bad (.order ⟨2,_⟩ ⟨1,_⟩ _) = true
            have h := h_ssn_eval (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
            unfold atom_eval at h; exact h.mp h_t_lt_x
          · -- ¬(x < t) order: ssn_bad (.order ⟨1,_⟩ ⟨2,_⟩ _) = false
            have h := h_ssn_eval (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
            unfold atom_eval at h
            cases hssn : ssn_bad (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
            · rfl
            · exact absurd (h.mpr hssn) (not_lt_of_gt h_t_lt_x)
          · exact ssn_order_consistent_of_eval ssn_bad h_ssn_eval
        exact absurd h_xt_compat h_incompat_bad
  · -- ¬t_compat: existential impossible (atom at index 1 can't match)
    refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
    simp only [temporal_truth]
    constructor
    · exact fun h => absurd h id
    · intro ⟨x, h_eval⟩
      push_neg at h_t_compat; obtain ⟨p, hp⟩ := h_t_compat
      obtain ⟨h_atom, _⟩ := h_eval
      have h_sub : M.interp p t₀ ↔ sub_nf.1 (.pred p ⟨1, by omega⟩) = true := by
        have h := h_atom (.pred p ⟨1, by omega⟩); unfold atom_eval at h; exact h
      have h_par := (h_atoms (.pred p ⟨0, by omega⟩))
      simp only [atom_eval] at h_par
      cases hsub : sub_nf.1 (.pred p ⟨1, by omega⟩) <;>
      cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;>
      simp_all


end Bimodal.Metalogic.WeakCanonical.Kamp
