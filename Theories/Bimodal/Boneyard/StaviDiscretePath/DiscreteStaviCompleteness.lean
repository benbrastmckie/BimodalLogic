-- ARCHIVED from Metalogic/WeakCanonical/EFGames/DiscreteStaviCompleteness.lean
-- Reason: Dead code — discrete Stavi path with no live downstream consumers
-- Archived: 2026-06-16 (task 302)

import Bimodal.Metalogic.WeakCanonical.EFGames.DiscreteGameTransfer
import Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Discrete Stavi Expressive Completeness

Sorry-free versions of `discrete_nf_characterizable_by_stavi` and
`discrete_stavi_expressive_completeness` that bypass the sorry in
`nf_exist_sf_guarded_backward` by using the game pipeline.

## Architecture

The key change from the old version in `StaviCompleteness.lean`: instead of
calling the sorry'd `nf_characterizable_by_stavi` (via `nf_2var_existence_characterizable`
which uses `Classical.choose` on a sorry-tainted proof), we:

1. Use `nf_exist_sf_guarded` DIRECTLY as the existence formula (sorry-free definition)
2. Prove forward direction (existence → formula) using `discrete_nf_exist_sf_guarded_forward_at_M`
   which only needs the `.mpr` direction of char_k_correct (sorry-free for all M)
3. Prove backward direction (formula → existence) for discrete M using the game pipeline:
   `discrete_nf_to_decomposition_agreement` → `ghr93_decomposition_implies_game` →
   `discrete_ghr93_proposition7` → `nf_fraisse_compression` → NF agreement

This file imports `DiscreteGameTransfer.lean` (which transitively imports
`StaviCompleteness.lean` via `Theorem6 → CaseAnalysis → CharacteristicFormula →
StaviCompleteness`), so it has access to both the game pipeline and the
StaviCompleteness public API.
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Local iff lemmas for public sf_disjList/sf_conjList

StaviCompleteness.lean defines private `sf_disjList`/`sf_conjList` with corresponding
`sf_disjList_iff`/`sf_conjList_iff` theorems. CharacteristicFormula.lean defines public
versions with the same definitions. Since the private `_iff` theorems don't apply to the
public definitions (different declaration IDs), we prove local versions here. -/

private theorem pub_sf_disjList_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier)
    (l : List StaviFormula) :
    stavi_temporal_truth M atomMap t (sf_disjList l) ↔
    (∃ A ∈ l, stavi_temporal_truth M atomMap t A) := by
  induction l with
  | nil =>
    simp only [sf_disjList, stavi_temporal_truth, temporal_truth]
    constructor
    · exact False.elim
    · rintro ⟨A, ⟨⟩, _⟩
  | cons a as ih =>
    cases as with
    | nil =>
      simp only [sf_disjList, List.mem_cons, List.not_mem_nil, or_false]
      exact ⟨fun h => ⟨a, rfl, h⟩, fun ⟨_, rfl, h⟩ => h⟩
    | cons b bs =>
      simp only [sf_disjList, sf_disj, stavi_temporal_truth]
      constructor
      · intro h
        by_contra h_none
        push_neg at h_none
        apply h
        constructor
        · intro ha; exact h_none a (List.Mem.head _) ha
        · intro hrest
          have := ih.mp hrest
          obtain ⟨A, hA, hA_eval⟩ := this
          exact h_none A (List.Mem.tail a hA) hA_eval
      · rintro ⟨A, hA, hA_eval⟩
        intro h_neg
        obtain ⟨h_neg_a, h_neg_rest⟩ := h_neg
        cases hA with
        | head => exact h_neg_a hA_eval
        | tail _ hA => exact h_neg_rest (ih.mpr ⟨A, hA, hA_eval⟩)

private theorem pub_sf_conjList_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier)
    (l : List StaviFormula) :
    stavi_temporal_truth M atomMap t (sf_conjList l) ↔
    (∀ A ∈ l, stavi_temporal_truth M atomMap t A) := by
  induction l with
  | nil =>
    simp only [sf_conjList, stavi_temporal_truth, temporal_truth]
    constructor
    · intro _ A hA; simp at hA
    · intro _; simp
  | cons a as ih =>
    cases as with
    | nil =>
      simp only [sf_conjList, List.mem_cons, List.not_mem_nil, or_false]
      exact ⟨fun h A hA => hA ▸ h, fun h => h a rfl⟩
    | cons b bs =>
      simp only [sf_conjList, stavi_temporal_truth]
      constructor
      · rintro ⟨ha, hrest⟩
        intro A hA
        cases hA with
        | head => exact ha
        | tail _ hA => exact ih.mp hrest A hA
      · intro h
        exact ⟨h a (List.Mem.head _), ih.mpr (fun A hA => h A (List.Mem.tail a hA))⟩

/-! ## Discrete-specific forward direction helpers

The forward direction of `nf_exist_sf_guarded` (existence → formula truth) only
uses the `.mpr` direction of `char_k_correct` (NF eval → formula truth). We create
versions that take this weaker hypothesis, avoiding the need for the universally-
quantified `char_k_correct` that would require sorry for general M. -/

/-- The interval guard is always true at model M.
    Only requires the `.mpr` direction of `char_k_correct` at M. -/
private theorem discrete_interval_guard_sf_true
    {sig : MonadicSignature} (atomMap : Formula → sig.preds) (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    {M : OrderedMonadicStructure sig}
    (char_k_mpr : ∀ (nf_k : NormalForm sig k 1) (u : M.carrier),
        nf_eval_nf M k 1 (fun _ => u) nf_k →
        stavi_temporal_truth M atomMap u (char_k nf_k))
    (u : M.carrier) :
    stavi_temporal_truth M atomMap u (interval_guard_sf char_k) := by
  simp only [interval_guard_sf]
  rw [sf_disjList_iff]
  set nf_u := nf_characteristic M k 1 (fun _ => u)
  refine ⟨char_k nf_u, ?_, ?_⟩
  · simp only [List.mem_map]
    exact ⟨nf_u, Multiset.mem_toList.mpr (Fintype.complete nf_u), rfl⟩
  · exact char_k_mpr nf_u u (nf_characteristic_satisfies M k 1 (fun _ => u))

/-- Forward direction for the guarded formula at a specific model M.
    Only requires `.mpr` of `char_k_correct` at M. -/
private theorem discrete_nf_exist_sf_guarded_forward_at_M
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2)
    {M : OrderedMonadicStructure sig} {t : M.carrier}
    (char_k_mpr : ∀ (nf_k : NormalForm sig k 1) (u : M.carrier),
        nf_eval_nf M k 1 (fun _ => u) nf_k →
        stavi_temporal_truth M atomMap u (char_k nf_k))
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
      parent_atoms a = true)
    (h_ex : ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :
    stavi_temporal_truth M atomMap t
      (nf_exist_sf_guarded atomMap h_surj k char_k parent_atoms sub_nf) := by
  obtain ⟨x, h_x⟩ := h_ex
  have h_x_atoms : ∀ (a : AtomKind sig (1 + 1)),
      atom_eval M (Fin.cons x (fun _ => t)) a ↔ sub_nf.atom_assgn a = true := by
    cases k with
    | zero => exact h_x
    | succ k' => exact h_x.1
  have h_t_cons : nf_t_consistent parent_atoms sub_nf = true := by
    simp only [nf_t_consistent]
    rw [List.all_eq_true]
    intro p _
    simp only [beq_iff_eq]
    have h_sub_t := h_x_atoms (.pred p ⟨1, by omega⟩)
    have h_par := h_atoms (.pred p ⟨0, by omega⟩)
    simp only [atom_eval] at h_sub_t h_par
    have h_env_1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [h_env_1] at h_sub_t
    cases h1 : sub_nf.atom_assgn (.pred p ⟨1, by omega⟩) <;>
    cases h2 : parent_atoms (.pred p ⟨0, by omega⟩) <;>
    simp_all
  simp only [nf_exist_sf_guarded, h_t_cons, not_true, ↓reduceIte, ite_not]
  have h_x_lt_t := h_x_atoms (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  have h_t_lt_x := h_x_atoms (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  simp only [atom_eval, Fin.cons] at h_x_lt_t h_t_lt_x
  have h_order_compat : ¬ (sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) &&
      sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))) = true := by
    intro h_both
    rw [Bool.and_eq_true] at h_both
    have hxt : x < t := h_x_lt_t.mpr h_both.1
    have htx : t < x := h_t_lt_x.mpr h_both.2
    exact absurd (lt_trans hxt htx) (lt_irrefl _)
  simp only [h_order_compat, ite_false]
  set nf_x := nf_characteristic M k 1 (fun _ => x) with nf_x_def
  have h_nf_x : nf_eval_nf M k 1 (fun _ => x) nf_x :=
    nf_characteristic_satisfies M k 1 (fun _ => x)
  have h_char_at_x : stavi_temporal_truth M atomMap x (char_k nf_x) :=
    char_k_mpr nf_x x h_nf_x
  have h_fc0 : Fin.cases x (fun _ : Fin 1 => t) (⟨0, by omega⟩ : Fin 2) = x := by
    simp [Fin.cases]
  have h_fc1 : Fin.cases x (fun _ : Fin 1 => t) (⟨1, by omega⟩ : Fin 2) = t := by
    simp [Fin.cases]; rfl
  rw [h_fc0, h_fc1] at h_x_lt_t
  rw [h_fc1, h_fc0] at h_t_lt_x
  have h_compat : ∀ p : sig.preds,
      nf_x.atom_assgn (.pred p ⟨0, by omega⟩) =
      sub_nf.atom_assgn (.pred p ⟨0, by omega⟩) := by
    intro p
    have h_nf_x_p : atom_eval M (fun _ => x) (.pred p (0 : Fin 1)) ↔
        (nf_x.atom_assgn (.pred p (0 : Fin 1)) = true) := by
      cases k with
      | zero => exact h_nf_x (.pred p 0)
      | succ k' => exact h_nf_x.1 (.pred p 0)
    have h_sub_p := h_x_atoms (.pred p (0 : Fin 2))
    simp only [atom_eval] at h_nf_x_p h_sub_p
    have h_fc0' : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) (0 : Fin 2) = x := by
      simp [Fin.cons]
    rw [h_fc0'] at h_sub_p
    cases h1 : nf_x.atom_assgn (.pred p (0 : Fin 1)) <;>
    cases h2 : sub_nf.atom_assgn (.pred p (0 : Fin 2)) <;>
    simp_all
  norm_num
  have h_in_list' : char_k nf_x ∈ List.filterMap
      (fun nf_x' => if (∀ x ∈ Fintype.elems, nf_x'.atom_assgn (AtomKind.pred x 0) =
        sub_nf.atom_assgn (AtomKind.pred x 0)) then some (char_k nf_x') else none)
      Fintype.elems.val.toList := by
    rw [List.mem_filterMap]
    exact ⟨nf_x, Multiset.mem_toList.mpr (Fintype.complete nf_x), by
      rw [if_pos]; intro p hp; exact h_compat p⟩
  have h_disj_at_x : stavi_temporal_truth M atomMap x (sf_disjList (List.filterMap
      (fun nf_x' => if (∀ x ∈ Fintype.elems, nf_x'.atom_assgn (AtomKind.pred x 0) =
        sub_nf.atom_assgn (AtomKind.pred x 0)) then some (char_k nf_x') else none)
      Fintype.elems.val.toList)) := by
    rw [pub_sf_disjList_iff]
    exact ⟨char_k nf_x, h_in_list', h_char_at_x⟩
  match h_b1 : sub_nf.atom_assgn (AtomKind.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)),
        h_b2 : sub_nf.atom_assgn (AtomKind.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) with
  | true, false =>
    simp only [nf_order_0_1, h_b1, h_b2, stavi_temporal_truth]
    exact ⟨x, h_t_lt_x.mpr h_b1, h_disj_at_x,
      fun u _ _ => discrete_interval_guard_sf_true atomMap k char_k char_k_mpr u⟩
  | false, true =>
    simp only [nf_order_0_1, h_b1, h_b2, stavi_temporal_truth]
    exact ⟨x, h_x_lt_t.mpr h_b2, h_disj_at_x,
      fun u _ _ => discrete_interval_guard_sf_true atomMap k char_k char_k_mpr u⟩
  | false, false =>
    simp only [nf_order_0_1, h_b1, h_b2, and_self, ↓reduceIte]
    have h_eq : x = t := by
      by_contra h_ne
      rcases lt_or_gt_of_ne h_ne with h | h
      · exact absurd (h_x_lt_t.mp h) (by simp_all)
      · exact absurd (h_t_lt_x.mp h) (by simp_all)
    rw [← h_eq]; exact h_disj_at_x
  | true, true =>
    exfalso
    exact h_order_compat (by rw [Bool.and_eq_true]; exact ⟨h_b2, h_b1⟩)

/-! ## Discrete backward direction (game pipeline)

The backward direction of `nf_exist_sf_guarded` for discrete models:
formula truth → existence of witness with correct 2-var NF.

This requires the game pipeline:
1. Extract witness x from the temporal formula
2. Compute nf_actual := nf_characteristic M k 2 (x::t)
3. Show nf_actual = sub_nf via:
   a. Atom agreement (from formula data)
   b. Quantifier agreement via game pipeline:
      - discrete_nf_to_decomposition_agreement → decomposition at (x,t)/(x_ref,t_ref)
      - ghr93_decomposition_implies_game → game wins
      - discrete_ghr93_proposition7 → iterated game wins
      - nf_fraisse_compression → NF equality
4. Reference model existence from Classical.choice on sub_nf realizability -/

-- TODO: discrete_nf_exist_sf_guarded_backward
-- This is the main remaining sorry in the chain.
-- The proof requires connecting:
-- (a) The formula gives witness x with compatible 1-var NF and ordering
-- (b) Use zone_match_witness to find matching x' in a reference model
-- (c) Apply nf_fraisse_compression on the 2-var environments (x,t) and (x',t')
-- (d) The Fraisse compression needs existential transfer at each depth j < k
-- (e) Existential transfer follows from game wins via discrete_ghr93_proposition7

/-! ## Self-contained discrete NF characterization -/

/-- **Discrete version of nf_characterizable_by_stavi** (sorry-free once
    `discrete_nf_exist_sf_guarded_backward` is proved).

    Uses `nf_exist_sf_guarded` directly with the discrete IH's char_k. -/
theorem discrete_nf_characterizable_by_stavi
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) (nf : NormalForm sig k 1) :
    ∃ A : StaviFormula, ∀ (M : OrderedMonadicStructure sig)
      [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
      [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
      (t : M.carrier),
      stavi_temporal_truth M atomMap t A ↔
      nf_eval_nf M k 1 (fun _ => t) nf := by
  induction k with
  | zero =>
    exact ⟨nf_base_sf atomMap h_surj nf, fun M _ _ _ _ _ t =>
      nf_base_sf_correct atomMap h_surj nf M t⟩
  | succ k ih =>
    let char_k : NormalForm sig k 1 → StaviFormula :=
      fun nf_k => Classical.choose (ih nf_k)
    have char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (N : OrderedMonadicStructure sig)
        [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
        [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
        (t : N.carrier),
        stavi_temporal_truth N atomMap t (char_k nf_k) ↔
        nf_eval_nf N k 1 (fun _ => t) nf_k :=
      fun nf_k => Classical.choose_spec (ih nf_k)
    -- Use nf_exist_sf_guarded DIRECTLY (sorry-free definition)
    let exist_sf : NormalForm sig k 2 → StaviFormula :=
      fun sub_nf => nf_exist_sf_guarded atomMap h_surj k char_k nf.1 sub_nf
    -- Prove iff for each sub_nf at discrete M
    have exist_sf_correct : ∀ (sub_nf : NormalForm sig k 2)
        (N : OrderedMonadicStructure sig)
        [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
        [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
        (t : N.carrier),
        (∀ (a : AtomKind sig 1), atom_eval N (fun _ => t) a ↔ nf.1 a = true) →
        (stavi_temporal_truth N atomMap t (exist_sf sub_nf) ↔
         ∃ x : N.carrier, nf_eval_nf N k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
      intro sub_nf N _ _ _ _ _ t h_atoms
      constructor
      · -- Backward: formula truth → existence (game pipeline)
        intro h_sf
        -- The backward direction requires showing that for discrete N:
        -- stavi_temporal_truth N atomMap t (nf_exist_sf_guarded ... sub_nf) implies
        -- ∃ x, nf_eval_nf N k 2 (Fin.cons x (fun _ => t)) sub_nf.
        --
        -- From h_sf, we can extract a witness x with:
        -- (a) correct 1-var depth-k NF type (atom-compatible with sub_nf)
        -- (b) correct ordering relative to t
        -- (c) interval guard data (all intermediate points have some NF type)
        --
        -- For k = 0: only atoms + ordering matter, which the formula directly encodes.
        -- For k ≥ 1: need quantifier transfer at depth k-1.
        --
        -- The proof requires nf_fraisse_compression with existential transfer,
        -- which for discrete models follows from:
        -- discrete_nf_to_decomposition_agreement → ghr93_decomposition_implies_game
        -- → discrete_ghr93_proposition7 → game wins → NF agreement.
        --
        -- The obstacle is nf_2var_existential_transfer (StaviCompleteness.lean:2353)
        -- which is sorry'd for the j ≥ 1 case (4-var sub-interval matching).
        -- For discrete models, this should follow from the game pipeline but
        -- requires connecting the game iteration to the specific 2-var NF.
        sorry
      · -- Forward: existence → formula truth (sorry-free)
        intro h_ex
        exact discrete_nf_exist_sf_guarded_forward_at_M atomMap h_surj k char_k
          nf.1 sub_nf (fun nf_k u => (char_k_correct nf_k N u).mpr) h_atoms h_ex
    -- Build the formula
    let atom_lits := (Fintype.elems (α := AtomKind sig 1)).val.toList.map fun ak =>
      atomKind_to_sf_literal atomMap h_surj ak (nf.1 ak)
    let quant_formulas := (Fintype.elems (α := NormalForm sig k 2)).val.toList.map fun sub_nf =>
      if nf.2 sub_nf then exist_sf sub_nf else .neg (exist_sf sub_nf)
    let full_formula := StaviFormula.conj (sf_conjList atom_lits) (sf_conjList quant_formulas)
    refine ⟨full_formula, fun M _ _ _ _ _ t => ?_⟩
    constructor
    · -- Forward: formula truth → nf_eval_nf
      intro h_formula
      simp only [full_formula, stavi_temporal_truth] at h_formula
      obtain ⟨h_f_atoms, h_f_quant⟩ := h_formula
      have h_atom_list := (pub_sf_conjList_iff M atomMap t _).mp h_f_atoms
      have h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ nf.1 a = true := by
        intro a
        have h_mem : atomKind_to_sf_literal atomMap h_surj a (nf.1 a) ∈ atom_lits := by
          simp only [atom_lits, List.mem_map]
          exact ⟨a, Multiset.mem_toList.mpr (Fintype.complete a), rfl⟩
        exact (atomKind_to_sf_literal_correct atomMap h_surj M t a (nf.1 a)).mp
          (h_atom_list _ h_mem)
      have h_quant_list := (pub_sf_conjList_iff M atomMap t _).mp h_f_quant
      show nf_eval_nf M (k + 1) 1 (fun _ => t) nf
      obtain ⟨atom_part, quant_part⟩ := nf
      refine ⟨h_atoms, fun sub_nf => ?_⟩
      have h_sub_in : (if quant_part sub_nf then exist_sf sub_nf
          else (exist_sf sub_nf).neg) ∈ quant_formulas := by
        simp only [quant_formulas, List.mem_map]
        exact ⟨sub_nf, Multiset.mem_toList.mpr (Fintype.complete sub_nf), rfl⟩
      have h_sub_truth := h_quant_list _ h_sub_in
      have h_iff := exist_sf_correct sub_nf M t h_atoms
      cases h_q_val : quant_part sub_nf
      · simp only [h_q_val, Bool.false_eq_true, ↓reduceIte, stavi_temporal_truth] at h_sub_truth
        constructor
        · intro h_ex; exact absurd (h_iff.mpr h_ex) h_sub_truth
        · intro h_abs; simp at h_abs
      · simp only [h_q_val, ↓reduceIte] at h_sub_truth
        constructor
        · intro _; rfl
        · intro _; exact h_iff.mp h_sub_truth
    · -- Backward: nf_eval_nf → formula truth (sorry-free)
      intro h_nf
      simp only [nf_eval_nf] at h_nf
      obtain ⟨h_atoms, h_quant⟩ := h_nf
      simp only [full_formula, stavi_temporal_truth]
      constructor
      · rw [pub_sf_conjList_iff]
        intro A hA
        simp only [atom_lits, List.mem_map] at hA
        obtain ⟨ak, _, rfl⟩ := hA
        exact (atomKind_to_sf_literal_correct atomMap h_surj M t ak (nf.1 ak)).mpr
          (h_atoms ak)
      · rw [pub_sf_conjList_iff]
        intro A hA
        simp only [quant_formulas, List.mem_map] at hA
        obtain ⟨sub_nf, _, rfl⟩ := hA
        have h_iff := exist_sf_correct sub_nf M t h_atoms
        by_cases h_q : nf.2 sub_nf = true
        · simp only [h_q, ite_true]
          exact h_iff.mpr ((h_quant sub_nf).mpr h_q)
        · have h_q_false : nf.2 sub_nf = false := by
            cases h_val : nf.2 sub_nf <;> simp_all
          rw [show (nf.2 sub_nf) = false from h_q_false]
          simp only [Bool.false_eq_true, ↓reduceIte, stavi_temporal_truth]
          have h_no_ex : ¬ ∃ x, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
            rw [h_quant sub_nf, h_q_false]; simp
          exact fun h => h_no_ex (h_iff.mp h)

/-- **Discrete Stavi expressive completeness** (sorry-free once
    `discrete_nf_characterizable_by_stavi` is sorry-free). -/
noncomputable def discrete_stavi_expressive_completeness
    (sig : MonadicSignature) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (psi : MonadicFormula sig 1) :
    { A : StaviFormula //
      ∀ (M : OrderedMonadicStructure sig)
        [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
        [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
        (t : M.carrier),
        stavi_temporal_truth M atomMap t A ↔
        eval M (fun _ => t) psi } := by
  set k := psi.quantifier_depth with hk_def
  have nf_char := fun nf => discrete_nf_characterizable_by_stavi atomMap h_surj k nf
  let char_sf : NormalForm sig k 1 → StaviFormula :=
    fun nf => Classical.choose (nf_char nf)
  have char_correct : ∀ (nf : NormalForm sig k 1)
      (M : OrderedMonadicStructure sig)
      [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
      [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
      (t : M.carrier),
      stavi_temporal_truth M atomMap t (char_sf nf) ↔
      nf_eval_nf M k 1 (fun _ => t) nf :=
    fun nf => Classical.choose_spec (nf_char nf)
  let good_prop : NormalForm sig k 1 → Prop :=
    fun nf => ∃ (M : OrderedMonadicStructure sig)
      (_ : SuccOrder M.carrier) (_ : PredOrder M.carrier)
      (_ : NoMaxOrder M.carrier) (_ : NoMinOrder M.carrier)
      (_ : IsSuccArchimedean M.carrier)
      (t : M.carrier),
      nf_eval_nf M k 1 (fun _ => t) nf ∧ eval M (fun _ => t) psi
  let all_nfs := (Fintype.elems (α := NormalForm sig k 1)).val.toList
  let good_formulas := all_nfs.filterMap (fun nf =>
    if @decide (good_prop nf) (Classical.dec _) then some (char_sf nf) else none)
  have mem_good_iff : ∀ (sf : StaviFormula), sf ∈ good_formulas ↔
      ∃ nf ∈ all_nfs, good_prop nf ∧ sf = char_sf nf := by
    intro sf
    simp only [good_formulas, List.mem_filterMap]
    constructor
    · rintro ⟨nf, hnf_mem, h_ite⟩
      by_cases hg : good_prop nf
      · rw [if_pos (@decide_eq_true _ (Classical.dec _) hg)] at h_ite
        exact ⟨nf, hnf_mem, hg, (Option.some.inj h_ite).symm⟩
      · rw [if_neg (mt (@decide_eq_true_eq _ (Classical.dec _)).mp hg)] at h_ite
        exact absurd h_ite (by simp)
    · rintro ⟨nf, hnf_mem, hg, rfl⟩
      exact ⟨nf, hnf_mem, by rw [if_pos (@decide_eq_true _ (Classical.dec _) hg)]⟩
  have nf_determines_psi : ∀ (nf : NormalForm sig k 1)
      (M₁ M₂ : OrderedMonadicStructure sig) (t₁ : M₁.carrier) (t₂ : M₂.carrier),
      nf_eval_nf M₁ k 1 (fun _ => t₁) nf →
      nf_eval_nf M₂ k 1 (fun _ => t₂) nf →
      (eval M₁ (fun _ => t₁) psi ↔ eval M₂ (fun _ => t₂) psi) := by
    intro nf M₁ M₂ t₁ t₂ h₁ h₂
    apply doets_lemma_1_1 k 1 psi (hk_def ▸ le_refl _) M₁ M₂ (fun _ => t₁) (fun _ => t₂)
    intro nf'
    obtain ⟨c₁, hc₁, hu₁⟩ := nf_exists_unique M₁ k 1 (fun _ => t₁)
    obtain ⟨c₂, hc₂, hu₂⟩ := nf_exists_unique M₂ k 1 (fun _ => t₂)
    simp only at hu₁ hu₂
    have h_eq₁ : c₁ = nf := (hu₁ nf h₁).symm
    have h_eq₂ : c₂ = nf := (hu₂ nf h₂).symm
    subst h_eq₁; subst h_eq₂
    constructor
    · intro h'; have := hu₁ nf' h'; subst this; exact hc₂
    · intro h'; have := hu₂ nf' h'; subst this; exact hc₁
  refine ⟨sf_disjList good_formulas, fun M _ _ _ _ _ t => ?_⟩
  rw [pub_sf_disjList_iff]
  constructor
  · rintro ⟨A, hA_mem, hA_eval⟩
    rw [mem_good_iff] at hA_mem
    obtain ⟨nf, _, h_good, rfl⟩ := hA_mem
    have h_nf_eval := (char_correct nf M t).mp hA_eval
    obtain ⟨M', h1, h2, h3, h4, h5, t', hM'_nf, hM'_psi⟩ := h_good
    exact (nf_determines_psi nf M' M t' t hM'_nf h_nf_eval).mp hM'_psi
  · intro h_psi
    set nf_M := nf_characteristic M k 1 (fun _ => t)
    have h_nf_M := nf_characteristic_satisfies M k 1 (fun _ => t)
    have h_char_eval := (char_correct nf_M M t).mpr h_nf_M
    have h_good : good_prop nf_M :=
      ⟨M, inferInstance, inferInstance, inferInstance, inferInstance, inferInstance,
       t, h_nf_M, h_psi⟩
    have h_in : char_sf nf_M ∈ good_formulas := by
      rw [mem_good_iff]
      exact ⟨nf_M, Multiset.mem_toList.mpr (Fintype.complete nf_M), h_good, rfl⟩
    exact ⟨char_sf nf_M, h_in, h_char_eval⟩

end Bimodal.Metalogic.WeakCanonical
