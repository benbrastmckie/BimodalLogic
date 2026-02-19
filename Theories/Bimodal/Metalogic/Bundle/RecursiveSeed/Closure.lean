import Bimodal.Metalogic.Bundle.RecursiveSeed.Worklist
import Mathlib.Data.Multiset.DershowitzManna

/-!
# RecursiveSeed Closure Properties

Closure proofs: WorklistClosureInvariant, processWorkItem_preserves_closure,
buildSeedComplete_closed, and termination arguments.
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
## Phase 5: Closure Properties

The worklist algorithm guarantees closure properties by construction:
- When Box psi is processed, psi is added to ALL families
- When G psi is processed, psi is added to ALL future times
- When H psi is processed, psi is added to ALL past times

These closure properties are what resolve the sorries in SeedCompletion.lean.
-/

/--
The worklist invariant for closure: formulas being processed will have
their closure properties established when their work items are processed.

Key insight: When `Box psi` enters the seed via processWorkItem, the processing
of that work item IMMEDIATELY adds psi to all families at that time. So the
invariant is: Box psi in seed AT (f,t) implies EITHER the Box psi work item
is still pending OR psi is already at all families.

Similarly for G/H: the processing adds psi to all future/past times that exist.
-/
def WorklistClosureInvariant (state : WorklistState) : Prop :=
  -- For every Box psi in the seed at (f,t), either:
  -- 1. psi is at all families at time t, OR
  -- 2. The Box psi work item is still pending (in worklist and not processed)
  (∀ f t psi, Formula.box psi ∈ state.seed.getFormulas f t →
    (∀ f', state.seed.hasPosition f' t → psi ∈ state.seed.getFormulas f' t) ∨
    (∃ w ∈ state.worklist, w.formula = Formula.box psi ∧ w.famIdx = f ∧ w.timeIdx = t ∧ w ∉ state.processed)) ∧
  -- Similar for G/H
  (∀ f t psi, Formula.all_future psi ∈ state.seed.getFormulas f t →
    (∀ t' > t, state.seed.hasPosition f t' → psi ∈ state.seed.getFormulas f t') ∨
    (∃ w ∈ state.worklist, w.formula = Formula.all_future psi ∧ w.famIdx = f ∧ w.timeIdx = t ∧ w ∉ state.processed)) ∧
  (∀ f t psi, Formula.all_past psi ∈ state.seed.getFormulas f t →
    (∀ t' < t, state.seed.hasPosition f t' → psi ∈ state.seed.getFormulas f t') ∨
    (∃ w ∈ state.worklist, w.formula = Formula.all_past psi ∧ w.famIdx = f ∧ w.timeIdx = t ∧ w ∉ state.processed))

/--
When the worklist is empty, closure invariant implies closure.
-/
theorem empty_worklist_closure (state : WorklistState)
    (h_empty : state.worklist = [])
    (h_inv : WorklistClosureInvariant state) :
    SeedClosed state.seed := by
  constructor
  · -- ModalClosed
    intro f t psi h_box f' h_pos
    have h := h_inv.1 f t psi h_box
    cases h with
    | inl h_closed => exact h_closed f' h_pos
    | inr h_pending =>
      obtain ⟨w, hw, _⟩ := h_pending
      simp only [h_empty, List.not_mem_nil] at hw
  constructor
  · -- GClosed
    intro f t psi h_G t' h_lt h_pos
    have h := h_inv.2.1 f t psi h_G
    cases h with
    | inl h_closed => exact h_closed t' h_lt h_pos
    | inr h_pending =>
      obtain ⟨w, hw, _⟩ := h_pending
      simp only [h_empty, List.not_mem_nil] at hw
  · -- HClosed
    intro f t psi h_H t' h_lt h_pos
    have h := h_inv.2.2 f t psi h_H
    cases h with
    | inl h_closed => exact h_closed t' h_lt h_pos
    | inr h_pending =>
      obtain ⟨w, hw, _⟩ := h_pending
      simp only [h_empty, List.not_mem_nil] at hw

/--
Helper: The initial seed only has phi at (0, 0).
-/
theorem initial_seed_getFormulas_unique (phi : Formula) (f : Nat) (t : Int) (psi : Formula) :
    psi ∈ (ModelSeed.initial phi).getFormulas f t → psi = phi ∧ f = 0 ∧ t = 0 := by
  intro h
  simp only [ModelSeed.initial, ModelSeed.getFormulas, ModelSeed.findEntry] at h
  -- The only entry is at (0, 0) with {phi}
  simp only [List.find?_cons] at h
  split at h
  · -- Entry matches: returned some entry
    rename_i entry heq
    -- Need to split on the match condition
    split at heq
    · -- 0 == f && 0 == t is true
      rename_i h_eq
      simp only [Option.some.injEq] at heq
      subst heq
      simp only [Set.mem_singleton_iff] at h
      have hf : f = 0 := by
        rw [Bool.and_eq_true] at h_eq
        simp only [beq_iff_eq] at h_eq
        exact h_eq.1.symm
      have ht : t = 0 := by
        rw [Bool.and_eq_true] at h_eq
        simp only [beq_iff_eq] at h_eq
        exact h_eq.2.symm
      exact ⟨h, hf, ht⟩
    · -- 0 == f && 0 == t is false, so find? on [] returns none -> contradiction
      simp only [List.find?_nil] at heq
      cases heq
  · -- find? returned none, so h : psi ∈ ∅
    simp only [Set.mem_empty_iff_false] at h

/--
Initial state satisfies closure invariant trivially (base formula only).
-/

theorem initial_closure_invariant (phi : Formula) :
    WorklistClosureInvariant (WorklistState.initial phi) := by
  constructor
  · -- Modal closure for initial state
    intro f t psi h_box
    simp only [WorklistState.initial] at *
    right
    use ⟨phi, 0, 0⟩
    simp only [List.mem_singleton, true_and, Finset.not_mem_empty, not_false_eq_true, and_true]
    -- From h_box, extract that phi = Box psi and f = 0, t = 0
    have h := initial_seed_getFormulas_unique phi f t (Formula.box psi) h_box
    exact ⟨h.1.symm, h.2.1.symm, h.2.2.symm⟩
  constructor
  · -- G closure
    intro f t psi h_G
    simp only [WorklistState.initial] at *
    right
    use ⟨phi, 0, 0⟩
    simp only [List.mem_singleton, true_and, Finset.not_mem_empty, not_false_eq_true, and_true]
    have h := initial_seed_getFormulas_unique phi f t (Formula.all_future psi) h_G
    exact ⟨h.1.symm, h.2.1.symm, h.2.2.symm⟩
  · -- H closure
    intro f t psi h_H
    simp only [WorklistState.initial] at *
    right
    use ⟨phi, 0, 0⟩
    simp only [List.mem_singleton, true_and, Finset.not_mem_empty, not_false_eq_true, and_true]
    have h := initial_seed_getFormulas_unique phi f t (Formula.all_past psi) h_H
    exact ⟨h.1.symm, h.2.1.symm, h.2.2.symm⟩

/--
Helper: If find? on a modified list uses a different predicate than the modification index,
the result is unchanged from the original list.
-/
private lemma find_modify_diff_pred {α : Type*} (l : List α) (idx : ℕ) (h_lt : idx < l.length)
    (f : α → α) (p : α → Bool) (h_p : p (l[idx]) = false)
    (h_pres : p (f (l[idx])) = false) :
    (l.modify idx f).find? p = l.find? p := by
  induction l generalizing idx with
  | nil => simp at h_lt
  | cons a as ih =>
    cases idx with
    | zero =>
      simp [List.modify, List.find?_cons] at h_p h_pres ⊢
      rw [h_p, h_pres]
    | succ n =>
      simp [List.modify] at h_p h_pres ⊢
      simp only [List.find?_cons, List.length_cons] at h_lt ⊢
      have := ih n (by omega) h_p h_pres
      simp [List.modify] at this
      split <;> [rfl; exact this]

private lemma not_eq_true_to_bne (b : Bool) (h : ¬ b = true) : (!b) = true := by
  cases b <;> [rfl; exact absurd rfl h]

/--
Helper: Characterize membership in getFormulas after addFormula.
If phi ∈ (seed.addFormula addF addT psi ty).getFormulas f t, then either:
1. phi ∈ seed.getFormulas f t, or
2. phi = psi and (f, t) = (addF, addT)
-/
private lemma mem_getFormulas_after_addFormula
    (seed : ModelSeed) (addF : Nat) (addT : Int) (psi phi : Formula) (ty : SeedEntryType)
    (f : Nat) (t : Int) (h_mem : phi ∈ (seed.addFormula addF addT psi ty).getFormulas f t) :
    phi ∈ seed.getFormulas f t ∨ (phi = psi ∧ f = addF ∧ t = addT) := by
  unfold ModelSeed.addFormula at h_mem
  simp only at h_mem
  split at h_mem
  · -- some idx case
    rename_i idx h_find
    unfold ModelSeed.getFormulas ModelSeed.findEntry at h_mem ⊢
    have h_spec := List.findIdx?_eq_some_iff_getElem.mp h_find
    obtain ⟨h_idx_lt, h_pred_raw, h_before⟩ := h_spec
    by_cases h_pos : f = addF ∧ t = addT
    · obtain ⟨hf, ht⟩ := h_pos; subst hf ht
      set p := fun e : SeedEntry => e.familyIdx == f && e.timeIdx == t
      have h_pred : p seed.entries[idx] = true := h_pred_raw
      have h_find_mod : (seed.entries.modify idx (fun e => { e with formulas := insert psi e.formulas })).find? p =
          some { seed.entries[idx] with formulas := insert psi seed.entries[idx].formulas } := by
        rw [List.find?_eq_some_iff_getElem]
        refine ⟨h_pred, idx, ?_, ?_, ?_⟩
        · rw [List.length_modify]; exact h_idx_lt
        · simp [List.getElem_modify]
        · intro j hj; rw [List.getElem_modify]; split
          · omega
          · exact not_eq_true_to_bne _ (h_before j hj)
      rw [h_find_mod] at h_mem
      cases Set.mem_insert_iff.mp h_mem with
      | inl h_eq => right; exact ⟨h_eq, rfl, rfl⟩
      | inr h_orig =>
        left
        have h_find_orig : seed.entries.find? p = some seed.entries[idx] := by
          rw [List.find?_eq_some_iff_getElem]
          exact ⟨h_pred, idx, h_idx_lt, rfl, fun j hj => not_eq_true_to_bne _ (h_before j hj)⟩
        rw [h_find_orig]; exact h_orig
    · left; push_neg at h_pos
      set p := fun e : SeedEntry => e.familyIdx == f && e.timeIdx == t
      have h_p_idx_false : p seed.entries[idx] = false := by
        dsimp [p]
        simp only [Bool.and_eq_true, beq_iff_eq] at h_pred_raw
        simp only [Bool.and_eq_false_iff, beq_eq_false_iff_ne]
        by_contra h_all; push_neg at h_all
        exact h_pos (h_all.1.symm.trans h_pred_raw.1) (h_all.2.symm.trans h_pred_raw.2)
      have h_p_mod_false : p ({ seed.entries[idx] with formulas := insert psi seed.entries[idx].formulas } : SeedEntry) = false := by
        dsimp [p] at h_p_idx_false ⊢; exact h_p_idx_false
      rw [find_modify_diff_pred seed.entries idx h_idx_lt
        (fun e : SeedEntry => { e with formulas := insert psi e.formulas }) p h_p_idx_false h_p_mod_false] at h_mem
      exact h_mem
  · -- none case: new entry appended
    rename_i h_find
    unfold ModelSeed.getFormulas ModelSeed.findEntry at h_mem ⊢
    set p := fun e : SeedEntry => e.familyIdx == f && e.timeIdx == t
    rw [List.find?_append] at h_mem
    by_cases h_pos : f = addF ∧ t = addT
    · obtain ⟨hf, ht⟩ := h_pos; subst hf ht
      have h_orig_none : seed.entries.find? p = none := by
        rw [List.find?_eq_none]; intro x hx
        have h := (List.findIdx?_eq_none_iff.mp h_find) x hx
        dsimp [p]; simp [h]
      simp only [h_orig_none, Option.none_or] at h_mem
      have h_new_match : [{ familyIdx := f, timeIdx := t, formulas := ({psi} : Set Formula), entryType := ty }].find? p =
          some { familyIdx := f, timeIdx := t, formulas := ({psi} : Set Formula), entryType := ty } := by
        simp only [List.find?_cons]; dsimp [p]; simp
      rw [h_new_match] at h_mem
      simp only [Set.mem_singleton_iff] at h_mem
      right; exact ⟨h_mem, rfl, rfl⟩
    · left; push_neg at h_pos
      have h_new_no_match : [{ familyIdx := addF, timeIdx := addT, formulas := ({psi} : Set Formula), entryType := ty }].find? p = none := by
        rw [List.find?_eq_none]; intro x hx
        simp only [List.mem_singleton] at hx; subst hx
        dsimp [p]
        simp only [Bool.not_eq_true, Bool.and_eq_false_iff, beq_eq_false_iff_ne]
        by_contra h_all; push_neg at h_all
        exact h_pos h_all.1.symm h_all.2.symm
      rw [h_new_no_match, Option.or_none] at h_mem; exact h_mem

/--
Helper: foldl addFormula over times puts phi at each time.
When t ∈ times, then phi ∈ (foldl addFormula seed times).getFormulas f t.
-/
private lemma foldl_addFormula_times_puts_phi_in_all
    (phi : Formula) (famIdx : Nat) (times : List Int) (seed : ModelSeed)
    (t : Int) (h_in : t ∈ times) :
    phi ∈ (times.foldl (fun s time => s.addFormula famIdx time phi .universal_target) seed).getFormulas famIdx t := by
  induction times generalizing seed with
  | nil => exact absurd h_in (List.not_mem_nil)
  | cons s ss ih =>
    simp only [List.foldl_cons]
    by_cases h_eq : t = s
    · subst h_eq
      have h_added : phi ∈ (seed.addFormula famIdx t phi .universal_target).getFormulas famIdx t := addFormula_formula_in_getFormulas seed famIdx t phi .universal_target
      induction ss generalizing seed with
      | nil => exact h_added
      | cons u us ihs =>
        simp only [List.foldl_cons]
        apply ihs (seed.addFormula famIdx t phi .universal_target).addFormula famIdx u phi .universal_target
        by_cases h_eq' : t = u
        · subst h_eq'; exact addFormula_formula_in_getFormulas _ famIdx t phi .universal_target
        · have h_diff : t ≠ u := h_eq'
          rw [addFormula_preserves_getFormulas_diff_time _ famIdx t u phi .universal_target h_diff]
          exact h_added
    · apply ih
      cases h_in with
      | head => exact absurd rfl h_eq
      | tail _ hss => exact hss

/--
Helper: Backward reasoning for foldl over families.
If phi ∈ getFormulas after foldl, then either:
1. phi was in the original seed, OR
2. phi = psi (the added formula) and f ∈ fams
-/
private lemma mem_getFormulas_after_foldl_fam
    (psi phi : Formula) (t : Int) (fams : List Nat) (seed : ModelSeed)
    (f : Nat) (h_mem : phi ∈ (fams.foldl (fun s fam => s.addFormula fam t psi .universal_target) seed).getFormulas f t) :
    phi ∈ seed.getFormulas f t ∨ (phi = psi ∧ f ∈ fams) := by
  induction fams generalizing seed with
  | nil =>
    simp only [List.foldl_nil] at h_mem
    exact Or.inl h_mem
  | cons g gs ih =>
    simp only [List.foldl_cons] at h_mem
    -- Apply induction hypothesis to the inner result
    have h_or := ih (seed.addFormula g t psi .universal_target) h_mem
    cases h_or with
    | inl h_in_add =>
      -- phi was in seed.addFormula g t psi
      have h_or2 := mem_getFormulas_after_addFormula seed g t psi phi .universal_target f t h_in_add
      cases h_or2 with
      | inl h_old => exact Or.inl h_old
      | inr h_new =>
        obtain ⟨h_eq, h_f, _⟩ := h_new
        subst h_eq h_f; exact Or.inr ⟨rfl, .head _⟩
    | inr h_eq =>
      obtain ⟨h_phi_eq, h_f_in⟩ := h_eq
      exact Or.inr ⟨h_phi_eq, .tail _ h_f_in⟩

/--
Helper: Backward reasoning for foldl over times.
If phi ∈ getFormulas after foldl, then either:
1. phi was in the original seed, OR
2. phi = psi (the added formula) and t ∈ times
-/
private lemma mem_getFormulas_after_foldl_times
    (psi phi : Formula) (famIdx : Nat) (times : List Int) (seed : ModelSeed)
    (t : Int) (h_mem : phi ∈ (times.foldl (fun s time => s.addFormula famIdx time psi .universal_target) seed).getFormulas famIdx t) :
    phi ∈ seed.getFormulas famIdx t ∨ (phi = psi ∧ t ∈ times) := by
  induction times generalizing seed with
  | nil =>
    simp only [List.foldl_nil] at h_mem
    exact Or.inl h_mem
  | cons s ss ih =>
    simp only [List.foldl_cons] at h_mem
    have h_or := ih (seed.addFormula famIdx s psi .universal_target) h_mem
    cases h_or with
    | inl h_in_add =>
      have h_or2 := mem_getFormulas_after_addFormula seed famIdx s psi phi .universal_target famIdx t h_in_add
      cases h_or2 with
      | inl h_old => exact Or.inl h_old
      | inr h_new =>
        obtain ⟨h_eq, _, h_t⟩ := h_new
        subst h_eq h_t; exact Or.inr ⟨rfl, .head _⟩
    | inr h_eq =>
      obtain ⟨h_phi_eq, h_t_in⟩ := h_eq
      exact Or.inr ⟨h_phi_eq, .tail _ h_t_in⟩

/-- foldl addFormula over times creates position (famIdx, t) for each t ∈ times. -/
private lemma foldl_addFormula_times_self_hasPosition
    (phi : Formula) (famIdx : Nat) (times : List Int) (seed : ModelSeed)
    (t : Int) (ht : t ∈ times) :
    (times.foldl (fun s time => s.addFormula famIdx time phi .universal_target) seed).hasPosition famIdx t :=
  ModelSeed.mem_getFormulas_implies_hasPosition _ famIdx t phi
    (foldl_addFormula_times_puts_phi_in_all phi famIdx times seed t ht)

/--
Helper: foldl over addFormula at families in a list doesn't create positions for families outside the list.
If f ∉ fams, then hasPosition f t is unchanged.
-/
private lemma foldl_addFormula_fam_preserves_hasPosition_not_in
    (psi : Formula) (t : Int) (fams : List Nat) (seed : ModelSeed) (f : Nat) (h_not_in : f ∉ fams) :
    (fams.foldl (fun s fam => s.addFormula fam t psi .universal_target) seed).hasPosition f t =
    seed.hasPosition f t := by
  induction fams generalizing seed with
  | nil => rfl
  | cons g gs ih =>
    simp only [List.foldl_cons]
    rw [ih (seed.addFormula g t psi .universal_target)]
    · -- Now show addFormula at g doesn't change hasPosition f t (since f ≠ g)
      have h_neq : f ≠ g := fun h => h_not_in (h ▸ .head _)
      -- addFormula at (g, t) doesn't change hasPosition at (f, t) when f ≠ g
      unfold ModelSeed.addFormula
      cases h_find : seed.entries.findIdx? (fun e => e.familyIdx == g && e.timeIdx == t) with
      | some idx =>
        -- Modifying entry at idx doesn't change hasPosition for different family
        -- The entry at idx has familyIdx = g (from h_find), but we're checking familyIdx = f ≠ g
        simp only
        unfold ModelSeed.hasPosition
        have h_at_idx := List.findIdx?_eq_some_iff_getElem.mp h_find
        obtain ⟨h_idx_lt, h_cond⟩ := h_at_idx
        simp only [Bool.and_eq_true, beq_iff_eq] at h_cond
        -- h_cond: entry at idx has familyIdx = g and timeIdx = t
        -- Show List.any over modified list = List.any over original
        simp only [List.any_eq_true, beq_iff_eq]
        constructor
        · intro ⟨e, h_mem, h_fam, h_time⟩
          -- e is in the modified list
          -- Either e is the modified entry, or e is unchanged
          by_cases h_is_mod : e = (seed.entries.modify idx (fun e => { e with formulas := insert psi e.formulas }))[idx]
          · -- e is the modified entry - but that entry has familyIdx = g ≠ f
            have h_mod_fam : e.familyIdx = g := by
              rw [h_is_mod]
              simp only [List.getElem_modify_self h_idx_lt]
              exact h_cond.1
            rw [h_mod_fam] at h_fam
            exact absurd h_fam h_neq.symm
          · -- e is an unchanged entry
            have h_idx_bound := List.length_modify idx (fun e => { e with formulas := insert psi e.formulas }) seed.entries
            rw [h_idx_bound] at h_mem
            have h_mem_idx := List.mem_iff_getElem.mp h_mem
            obtain ⟨i, h_i_lt, h_e_eq⟩ := h_mem_idx
            rw [h_idx_bound] at h_i_lt
            by_cases h_i_idx : i = idx
            · -- This contradicts h_is_mod
              subst h_i_idx
              exact absurd h_e_eq h_is_mod
            · -- e = original[i] where i ≠ idx
              have h_orig : (seed.entries.modify idx (fun e => { e with formulas := insert psi e.formulas }))[i] = seed.entries[i] :=
                List.getElem_modify_of_ne h_i_idx h_i_lt
              rw [← h_e_eq, h_orig]
              use seed.entries[i]
              constructor
              · exact List.getElem_mem h_i_lt
              · rw [← h_e_eq, h_orig] at h_fam h_time
                exact ⟨h_fam, h_time⟩
        · intro ⟨e, h_mem, h_fam, h_time⟩
          -- e is in the original list with familyIdx = f
          have h_mem_idx := List.mem_iff_getElem.mp h_mem
          obtain ⟨i, h_i_lt, h_e_eq⟩ := h_mem_idx
          by_cases h_i_idx : i = idx
          · -- If i = idx, then e has familyIdx = g (from h_cond), but we said familyIdx = f
            subst h_i_idx
            rw [← h_e_eq] at h_fam
            rw [h_cond.1] at h_fam
            exact absurd h_fam h_neq.symm
          · -- i ≠ idx, so modified[i] = original[i] = e
            have h_mod : (seed.entries.modify idx (fun e => { e with formulas := insert psi e.formulas }))[i] = seed.entries[i] :=
              List.getElem_modify_of_ne h_i_idx h_i_lt
            use seed.entries[i]
            have h_mod_lt : i < (seed.entries.modify idx (fun e => { e with formulas := insert psi e.formulas })).length := by
              rw [List.length_modify]
              exact h_i_lt
            constructor
            · rw [← h_mod]
              exact List.getElem_mem h_mod_lt
            · rw [← h_e_eq]
              exact ⟨h_fam, h_time⟩
      | none =>
        -- Creating new entry at (g, t)
        simp only
        unfold ModelSeed.hasPosition
        simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq]
        constructor
        · intro ⟨e, h_mem, h_fam, h_time⟩
          rw [List.mem_append] at h_mem
          cases h_mem with
          | inl h_old => exact ⟨e, h_old, h_fam, h_time⟩
          | inr h_new =>
            simp only [List.mem_singleton] at h_new
            rw [h_new] at h_fam
            simp only at h_fam
            exact absurd h_fam.symm h_neq
        · intro ⟨e, h_mem, h_fam, h_time⟩
          use e
          constructor
          · exact List.mem_append_left _ h_mem
          · exact ⟨h_fam, h_time⟩
    · exact fun h_in => h_not_in (List.mem_cons_of_mem g h_in)

/--
Helper: membership in eraseDups follows from membership in the original list.
(Local proof needed because List.mem_eraseDups is not available in this Lean version.)
-/
private lemma mem_eraseDups_of_mem {α : Type*} [BEq α] [LawfulBEq α]
    {a : α} {l : List α} (h : a ∈ l) : a ∈ l.eraseDups := by
  have : ∀ n, ∀ l : List α, l.length = n → a ∈ l → a ∈ l.eraseDups := by
    intro n
    induction n using Nat.strongRecOn with
    | _ n ih =>
      intro l hl h
      match l with
      | [] => exact h
      | b :: bs =>
        rw [List.eraseDups_cons]
        rcases List.mem_cons.mp h with rfl | hbs
        · exact .head _
        · by_cases hab : (a == b) = true
          · rw [beq_iff_eq] at hab; subst hab; exact .head _
          · apply List.Mem.tail
            have h_filt : a ∈ bs.filter (fun x => !(x == b)) :=
              List.mem_filter.mpr ⟨hbs, by simp [hab]⟩
            have h_len : (bs.filter (fun x => !(x == b))).length < n := by
              simp only [List.length_cons] at hl
              have := List.length_filter_le (fun x => !(x == b)) bs
              omega
            exact ih _ h_len _ rfl h_filt
  exact this l.length l rfl h

/--
Helper: When hasPosition holds in seed, the family index is in familyIndices.
-/
private lemma hasPosition_implies_in_familyIndices (seed : ModelSeed) (f : Nat) (t : Int)
    (h_pos : seed.hasPosition f t) : f ∈ seed.familyIndices := by
  unfold ModelSeed.hasPosition ModelSeed.familyIndices at *
  simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq] at h_pos
  obtain ⟨e, h_mem, h_fam, _⟩ := h_pos
  exact mem_eraseDups_of_mem (List.mem_map.mpr ⟨e, h_mem, h_fam⟩)

/--
Helper: Backward reasoning for compound foldl (future case).
If phi ∈ getFormulas after the compound foldl, then either:
1. phi was in the original seed, OR
2. phi = psi and t ∈ times and f = famIdx, OR
3. phi = G psi and t ∈ times and f = famIdx
-/
private lemma mem_getFormulas_after_foldl_compound_future
    (psi phi : Formula) (famIdx : Nat) (times : List Int) (seed : ModelSeed)
    (f : Nat) (t : Int)
    (h_mem : phi ∈ (times.foldl (fun s time =>
        let s' := s.addFormula famIdx time psi .universal_target
        s'.addFormula famIdx time (Formula.all_future psi) .universal_target) seed).getFormulas f t) :
    phi ∈ seed.getFormulas f t ∨ (phi = psi ∧ t ∈ times ∧ f = famIdx) ∨ (phi = Formula.all_future psi ∧ t ∈ times ∧ f = famIdx) := by
  induction times generalizing seed with
  | nil =>
    simp only [List.foldl_nil] at h_mem
    exact Or.inl h_mem
  | cons time rest ih =>
    simp only [List.foldl_cons] at h_mem
    have h_or := ih _ h_mem
    cases h_or with
    | inl h_in_intermediate =>
      -- phi was in intermediate seed (after two addFormulas)
      have h_or1 := mem_getFormulas_after_addFormula (seed.addFormula famIdx time psi .universal_target)
                      famIdx time (Formula.all_future psi) phi .universal_target f t h_in_intermediate
      cases h_or1 with
      | inl h_in_after_psi =>
        have h_or2 := mem_getFormulas_after_addFormula seed famIdx time psi phi .universal_target f t h_in_after_psi
        cases h_or2 with
        | inl h_old => exact Or.inl h_old
        | inr h_is_psi =>
          obtain ⟨h_eq, hf, ht⟩ := h_is_psi
          exact Or.inr (Or.inl ⟨h_eq, .tail _ (ht ▸ hf ▸ .head _), hf⟩)
      | inr h_is_gpsi =>
        obtain ⟨h_eq, hf, ht⟩ := h_is_gpsi
        exact Or.inr (Or.inr ⟨h_eq, .tail _ (ht ▸ hf ▸ .head _), hf⟩)
    | inr h_added =>
      cases h_added with
      | inl h_is_psi =>
        obtain ⟨h_eq, h_in, hf⟩ := h_is_psi
        exact Or.inr (Or.inl ⟨h_eq, .tail _ h_in, hf⟩)
      | inr h_is_gpsi =>
        obtain ⟨h_eq, h_in, hf⟩ := h_is_gpsi
        exact Or.inr (Or.inr ⟨h_eq, List.mem_cons_of_mem time h_in, hf⟩)

/--
Helper: Backward reasoning for compound foldl (past case).
If phi ∈ getFormulas after the compound foldl, then either:
1. phi was in the original seed, OR
2. phi = psi and t ∈ times and f = famIdx, OR
3. phi = H psi and t ∈ times and f = famIdx
-/
private lemma mem_getFormulas_after_foldl_compound_past
    (psi phi : Formula) (famIdx : Nat) (times : List Int) (seed : ModelSeed)
    (f : Nat) (t : Int)
    (h_mem : phi ∈ (times.foldl (fun s time =>
        let s' := s.addFormula famIdx time psi .universal_target
        s'.addFormula famIdx time (Formula.all_past psi) .universal_target) seed).getFormulas f t) :
    phi ∈ seed.getFormulas f t ∨ (phi = psi ∧ t ∈ times ∧ f = famIdx) ∨ (phi = Formula.all_past psi ∧ t ∈ times ∧ f = famIdx) := by
  induction times generalizing seed with
  | nil =>
    simp only [List.foldl_nil] at h_mem
    exact Or.inl h_mem
  | cons time rest ih =>
    simp only [List.foldl_cons] at h_mem
    have h_or := ih _ h_mem
    cases h_or with
    | inl h_in_intermediate =>
      have h_or1 := mem_getFormulas_after_addFormula (seed.addFormula famIdx time psi .universal_target)
                      famIdx time (Formula.all_past psi) phi .universal_target f t h_in_intermediate
      cases h_or1 with
      | inl h_in_after_psi =>
        have h_or2 := mem_getFormulas_after_addFormula seed famIdx time psi phi .universal_target f t h_in_after_psi
        cases h_or2 with
        | inl h_old => exact Or.inl h_old
        | inr h_is_psi =>
          obtain ⟨h_eq, hf, ht⟩ := h_is_psi
          exact Or.inr (Or.inl ⟨h_eq, .tail _ (ht ▸ hf ▸ .head _), hf⟩)
      | inr h_is_hpsi =>
        obtain ⟨h_eq, hf, ht⟩ := h_is_hpsi
        exact Or.inr (Or.inr ⟨h_eq, .tail _ (ht ▸ hf ▸ .head _), hf⟩)
    | inr h_added =>
      cases h_added with
      | inl h_is_psi =>
        obtain ⟨h_eq, h_in, hf⟩ := h_is_psi
        exact Or.inr (Or.inl ⟨h_eq, .tail _ h_in, hf⟩)
      | inr h_is_hpsi =>
        obtain ⟨h_eq, h_in, hf⟩ := h_is_hpsi
        exact Or.inr (Or.inr ⟨h_eq, List.mem_cons_of_mem time h_in, hf⟩)

/--
Helper: Compound foldl (future) puts G psi at each time in the list.
-/
private lemma foldl_compound_future_puts_gpsi_in_all
    (psi : Formula) (famIdx : Nat) (times : List Int) (seed : ModelSeed)
    (t : Int) (h_in : t ∈ times) :
    Formula.all_future psi ∈ (times.foldl (fun s time =>
        let s' := s.addFormula famIdx time psi .universal_target
        s'.addFormula famIdx time (Formula.all_future psi) .universal_target) seed).getFormulas famIdx t := by
  induction times generalizing seed with
  | nil => exact absurd h_in (List.not_mem_nil)
  | cons time rest ih =>
    simp only [List.foldl_cons]
    by_cases h_eq : t = time
    · subst h_eq
      have h_added : Formula.all_future psi ∈
          ((seed.addFormula famIdx t psi .universal_target).addFormula famIdx t
            (Formula.all_future psi) .universal_target).getFormulas famIdx t :=
        addFormula_formula_in_getFormulas _ famIdx t (Formula.all_future psi) .universal_target
      exact foldl_compound_future_preserves_mem psi (Formula.all_future psi) famIdx rest _ famIdx t h_added
    · apply ih
      cases h_in with
      | head => exact absurd rfl h_eq
      | tail _ h => exact h

/--
Helper: Compound foldl (past) puts H psi at each time in the list.
-/
private lemma foldl_compound_past_puts_hpsi_in_all
    (psi : Formula) (famIdx : Nat) (times : List Int) (seed : ModelSeed)
    (t : Int) (h_in : t ∈ times) :
    Formula.all_past psi ∈ (times.foldl (fun s time =>
        let s' := s.addFormula famIdx time psi .universal_target
        s'.addFormula famIdx time (Formula.all_past psi) .universal_target) seed).getFormulas famIdx t := by
  induction times generalizing seed with
  | nil => exact absurd h_in (List.not_mem_nil)
  | cons time rest ih =>
    simp only [List.foldl_cons]
    by_cases h_eq : t = time
    · subst h_eq
      have h_added : Formula.all_past psi ∈
          ((seed.addFormula famIdx t psi .universal_target).addFormula famIdx t
            (Formula.all_past psi) .universal_target).getFormulas famIdx t :=
        addFormula_formula_in_getFormulas _ famIdx t (Formula.all_past psi) .universal_target
      exact foldl_compound_past_preserves_mem psi (Formula.all_past psi) famIdx rest _ famIdx t h_added
    · apply ih
      cases h_in with
      | head => exact absurd rfl h_eq
      | tail _ h => exact h

/--
Helper: hasPosition backward reasoning for compound foldl (future).
If hasPosition holds after the compound foldl, it either held before
or we're at a time in the list at the target family.
-/
private lemma foldl_compound_future_hasPosition_backward
    (psi : Formula) (famIdx : Nat) (times : List Int) (seed : ModelSeed)
    (f : Nat) (t : Int)
    (h_pos : (times.foldl (fun s time =>
        let s' := s.addFormula famIdx time psi .universal_target
        s'.addFormula famIdx time (Formula.all_future psi) .universal_target) seed).hasPosition f t) :
    seed.hasPosition f t ∨ (f = famIdx ∧ t ∈ times) := by
  induction times generalizing seed with
  | nil =>
    simp only [List.foldl_nil] at h_pos
    exact Or.inl h_pos
  | cons time rest ih =>
    simp only [List.foldl_cons] at h_pos
    have h_or := ih _ h_pos
    cases h_or with
    | inl h_pos_intermediate =>
      -- hasPosition held in intermediate seed (after two addFormulas)
      have h_or1 := addFormula_hasPosition_backward (seed.addFormula famIdx time psi .universal_target)
                      famIdx time (Formula.all_future psi) .universal_target f t h_pos_intermediate
      cases h_or1 with
      | inl h_pos_after_psi =>
        have h_or2 := addFormula_hasPosition_backward seed famIdx time psi .universal_target f t h_pos_after_psi
        cases h_or2 with
        | inl h_old => exact Or.inl h_old
        | inr h_new =>
          obtain ⟨hf, ht⟩ := h_new
          subst hf ht; exact Or.inr ⟨rfl, List.mem_cons_of_mem time (.head _)⟩
      | inr h_new =>
        obtain ⟨hf, ht⟩ := h_new
        subst hf ht; exact Or.inr ⟨rfl, List.mem_cons_of_mem time (.head _)⟩
    | inr h_added =>
      obtain ⟨hf, h_in⟩ := h_added
      exact Or.inr ⟨hf, .tail _ h_in⟩

/--
Helper: hasPosition backward reasoning for compound foldl (past).
-/
private lemma foldl_compound_past_hasPosition_backward
    (psi : Formula) (famIdx : Nat) (times : List Int) (seed : ModelSeed)
    (f : Nat) (t : Int)
    (h_pos : (times.foldl (fun s time =>
        let s' := s.addFormula famIdx time psi .universal_target
        s'.addFormula famIdx time (Formula.all_past psi) .universal_target) seed).hasPosition f t) :
    seed.hasPosition f t ∨ (f = famIdx ∧ t ∈ times) := by
  induction times generalizing seed with
  | nil =>
    simp only [List.foldl_nil] at h_pos
    exact Or.inl h_pos
  | cons time rest ih =>
    simp only [List.foldl_cons] at h_pos
    have h_or := ih _ h_pos
    cases h_or with
    | inl h_pos_intermediate =>
      have h_or1 := addFormula_hasPosition_backward (seed.addFormula famIdx time psi .universal_target)
                      famIdx time (Formula.all_past psi) .universal_target f t h_pos_intermediate
      cases h_or1 with
      | inl h_pos_after_psi =>
        have h_or2 := addFormula_hasPosition_backward seed famIdx time psi .universal_target f t h_pos_after_psi
        cases h_or2 with
        | inl h_old => exact Or.inl h_old
        | inr h_new =>
          obtain ⟨hf, ht⟩ := h_new
          subst hf ht; exact Or.inr ⟨rfl, List.mem_cons_of_mem time (.head _)⟩
      | inr h_new =>
        obtain ⟨hf, ht⟩ := h_new
        subst hf ht; exact Or.inr ⟨rfl, List.mem_cons_of_mem time (.head _)⟩
    | inr h_added =>
      obtain ⟨hf, h_in⟩ := h_added
      exact Or.inr ⟨hf, .tail _ h_in⟩

/--
processWorkItem preserves the closure invariant.

This is the key lemma: when we process a work item, we either:
1. Complete the closure for that formula (by adding to all positions)
2. Create new work items that will complete it

For Box psi: we add psi to ALL families at current time
For G psi: we add psi to ALL future times that exist
For H psi: we add psi to ALL past times that exist
-/
theorem processWorkItem_preserves_closure (item : WorkItem) (state : WorklistState)
    (h_inv : WorklistClosureInvariant state)
    (h_item_not_proc : item ∉ state.processed)
    (h_item_pos : state.seed.hasPosition item.famIdx item.timeIdx) :
    let (newWork, state') := processWorkItem item state
    WorklistClosureInvariant {
      seed := state'.seed,
      worklist := state.worklist ++ newWork.filter (fun w => w ∉ state'.processed),
      processed := Insert.insert item state'.processed
    } := by
  -- The proof proceeds by case analysis on classifyFormula item.formula
  -- For each case, we show the 3-part closure invariant is preserved:
  -- (1) Box psi in seed → psi at all families OR pending work item
  -- (2) G psi in seed → psi at all future times OR pending work item
  -- (3) H psi in seed → psi at all past times OR pending work item
  --
  -- Key insight for positive cases (boxPositive, futurePositive, pastPositive):
  -- The algorithm adds the inner formula to ALL relevant positions, so
  -- the closure is immediately satisfied (left disjunct).
  --
  -- Key insight for negative cases (boxNegative, futureNegative, pastNegative):
  -- A new work item is created, so the pending condition is satisfied (right disjunct).
  --
  -- Key insight for other cases (atomic, bottom, implication, negation):
  -- These don't introduce new Box/G/H formulas to the seed, so we can
  -- use the existing invariant.
  --
  -- PROOF STRUCTURE (10 cases on classifyFormula):
  --
  -- Simple cases (atomic, bottom, implication, negation):
  --   - Use mem_getFormulas_after_addFormula to show Box/G/H must be from old seed
  --   - Use addFormula_hasPosition_backward to reason about position changes
  --   - Use classifyFormula_eq_atomic (etc.) to derive contradictions when added formula ≠ Box/G/H
  --   - Key issue: when addFormula creates NEW position, closure invariant may need strengthening
  --
  -- Positive cases (boxPositive, futurePositive, pastPositive):
  --   - Use foldl_addFormula_fam_puts_phi_in_all / foldl_addFormula_times_puts_phi_in_all
  --   - Show that psi is added to ALL relevant positions, satisfying left disjunct of invariant
  --
  -- Negative cases (boxNegative, futureNegative, pastNegative):
  --   - Show new work item is created and added to worklist
  --   - Use right disjunct of invariant (pending work item exists)
  --
  -- Helper lemmas available:
  --   - mem_getFormulas_after_addFormula (line 7861)
  --   - addFormula_hasPosition_backward (line 6128)
  --   - classifyFormula_eq_atomic (line 1245)
  --   - foldl_addFormula_fam_puts_phi_in_all (line 7974)
  --   - foldl_addFormula_times_puts_phi_in_all (line 8007)
  --   - addFormula_preserves_mem_getFormulas_same (line 3515)
  --
  -- Destructure the match on processWorkItem
  split
  rename_i newWork state' h_proc
  -- Now case-split on classifyFormula to handle all 10 formula types
  match h_class : classifyFormula item.formula with
  | .atomic a =>
    -- atomic case: just adds item.formula, which is not Box/G/H
    -- So any Box/G/H in new seed must be from old seed
    simp only [processWorkItem, h_class] at h_proc
    simp only [Prod.mk.injEq] at h_proc
    obtain ⟨h_newWork, h_state'⟩ := h_proc
    subst h_newWork h_state'
    simp only [List.filter_nil, List.append_nil]
    constructor
    · -- Box psi closure
      intro f t psi h_box
      have h_or := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx item.formula
                     (Formula.box psi) .universal_target f t h_box
      cases h_or with
      | inl h_old =>
        cases h_inv.1 f t psi h_old with
        | inl h_closed =>
          left
          intro f' h_pos'
          have h_or_pos := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx item.formula .universal_target f' t h_pos'
          cases h_or_pos with
          | inl h_pos_old =>
            exact addFormula_preserves_mem_getFormulas_same state.seed f' t psi item.formula .universal_target (h_closed f' h_pos_old)
          | inr h_new_pos =>
            obtain ⟨hf', ht'⟩ := h_new_pos
            subst hf' ht'
            -- (f', t) = (item.famIdx, item.timeIdx), so t = item.timeIdx
            -- Need to show psi is at (item.famIdx, item.timeIdx) in new seed
            -- Since h_closed says psi is at all old positions at time t = item.timeIdx,
            -- we use that if old seed had position at (item.famIdx, item.timeIdx), psi was there
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · -- Position existed before, so psi was there by h_closed, preserved by addFormula
              exact addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx psi item.formula .universal_target (h_closed item.famIdx h_old_pos)
            · -- Position didn't exist before - this is a new position
              -- In this case, the new position only has item.formula (an atom), not psi
              -- But we need psi there. This case requires the pending branch instead.
              -- Since we're in the inl case (closed), there's no pending work item,
              -- which means Box psi's closure was already satisfied for ALL positions.
              -- But h_old_pos says position didn't exist, while h_item_pos says it did.
              exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        -- Box psi = item.formula, but item.formula is atomic
        have h_atom := classifyFormula_eq_atomic item.formula a h_class
        simp only [h_atom] at h_eq
        exact absurd h_eq.1 Formula.noConfusion
    constructor
    · -- G psi closure
      intro f t psi h_G
      have h_or := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx item.formula
                     (Formula.all_future psi) .universal_target f t h_G
      cases h_or with
      | inl h_old =>
        cases h_inv.2.1 f t psi h_old with
        | inl h_closed =>
          left
          intro t' h_lt h_pos'
          have h_or_pos := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx item.formula .universal_target f t' h_pos'
          cases h_or_pos with
          | inl h_pos_old =>
            exact addFormula_preserves_mem_getFormulas_same state.seed f t' psi item.formula .universal_target (h_closed t' h_lt h_pos_old)
          | inr h_new_pos =>
            obtain ⟨hf, ht'⟩ := h_new_pos
            subst hf ht'
            -- (f, t') = (item.famIdx, item.timeIdx), need psi at (item.famIdx, item.timeIdx)
            -- h_closed applies for t' > t where old has position at f t'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · exact addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx psi item.formula .universal_target (h_closed item.timeIdx h_lt h_old_pos)
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        have h_atom := classifyFormula_eq_atomic item.formula a h_class
        simp only [h_atom] at h_eq
        exact absurd h_eq.1 Formula.noConfusion
    · -- H psi closure
      intro f t psi h_H
      have h_or := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx item.formula
                     (Formula.all_past psi) .universal_target f t h_H
      cases h_or with
      | inl h_old =>
        cases h_inv.2.2 f t psi h_old with
        | inl h_closed =>
          left
          intro t' h_lt h_pos'
          have h_or_pos := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx item.formula .universal_target f t' h_pos'
          cases h_or_pos with
          | inl h_pos_old =>
            exact addFormula_preserves_mem_getFormulas_same state.seed f t' psi item.formula .universal_target (h_closed t' h_lt h_pos_old)
          | inr h_new_pos =>
            obtain ⟨hf, ht'⟩ := h_new_pos
            subst hf ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · exact addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx psi item.formula .universal_target (h_closed item.timeIdx h_lt h_old_pos)
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        have h_atom := classifyFormula_eq_atomic item.formula a h_class
        simp only [h_atom] at h_eq
        exact absurd h_eq.1 Formula.noConfusion
  | .bottom =>
    -- bottom case: just adds Formula.bot, which is not Box/G/H
    simp only [processWorkItem, h_class] at h_proc
    simp only [Prod.mk.injEq] at h_proc
    obtain ⟨h_newWork, h_state'⟩ := h_proc
    subst h_newWork h_state'
    simp only [List.filter_nil, List.append_nil]
    constructor
    · -- Box psi closure
      intro f t psi h_box
      have h_or := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx item.formula
                     (Formula.box psi) .universal_target f t h_box
      cases h_or with
      | inl h_old =>
        cases h_inv.1 f t psi h_old with
        | inl h_closed =>
          left
          intro f' h_pos'
          have h_or_pos := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx item.formula .universal_target f' t h_pos'
          cases h_or_pos with
          | inl h_pos_old =>
            exact addFormula_preserves_mem_getFormulas_same state.seed f' t psi item.formula .universal_target (h_closed f' h_pos_old)
          | inr h_new_pos =>
            obtain ⟨hf', ht'⟩ := h_new_pos
            subst hf' ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · exact addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx psi item.formula .universal_target (h_closed item.famIdx h_old_pos)
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        -- Box psi = item.formula, but item.formula is bot
        have h_bot := classifyFormula_eq_bottom item.formula h_class
        simp only [h_bot] at h_eq
        exact absurd h_eq.1 Formula.noConfusion
    constructor
    · -- G psi closure
      intro f t psi h_G
      have h_or := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx item.formula
                     (Formula.all_future psi) .universal_target f t h_G
      cases h_or with
      | inl h_old =>
        cases h_inv.2.1 f t psi h_old with
        | inl h_closed =>
          left
          intro t' h_lt h_pos'
          have h_or_pos := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx item.formula .universal_target f t' h_pos'
          cases h_or_pos with
          | inl h_pos_old =>
            exact addFormula_preserves_mem_getFormulas_same state.seed f t' psi item.formula .universal_target (h_closed t' h_lt h_pos_old)
          | inr h_new_pos =>
            obtain ⟨hf, ht'⟩ := h_new_pos
            subst hf ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · exact addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx psi item.formula .universal_target (h_closed item.timeIdx h_lt h_old_pos)
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        have h_bot := classifyFormula_eq_bottom item.formula h_class
        simp only [h_bot] at h_eq
        exact absurd h_eq.1 Formula.noConfusion
    · -- H psi closure
      intro f t psi h_H
      have h_or := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx item.formula
                     (Formula.all_past psi) .universal_target f t h_H
      cases h_or with
      | inl h_old =>
        cases h_inv.2.2 f t psi h_old with
        | inl h_closed =>
          left
          intro t' h_lt h_pos'
          have h_or_pos := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx item.formula .universal_target f t' h_pos'
          cases h_or_pos with
          | inl h_pos_old =>
            exact addFormula_preserves_mem_getFormulas_same state.seed f t' psi item.formula .universal_target (h_closed t' h_lt h_pos_old)
          | inr h_new_pos =>
            obtain ⟨hf, ht'⟩ := h_new_pos
            subst hf ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · exact addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx psi item.formula .universal_target (h_closed item.timeIdx h_lt h_old_pos)
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        have h_bot := classifyFormula_eq_bottom item.formula h_class
        simp only [h_bot] at h_eq
        exact absurd h_eq.1 Formula.noConfusion
  | .implication phi1 phi2 =>
    -- implication case: just adds item.formula (an implication), which is not Box/G/H
    simp only [processWorkItem, h_class] at h_proc
    simp only [Prod.mk.injEq] at h_proc
    obtain ⟨h_newWork, h_state'⟩ := h_proc
    subst h_newWork h_state'
    simp only [List.filter_nil, List.append_nil]
    constructor
    · -- Box psi closure
      intro f t psi h_box
      have h_or := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx item.formula
                     (Formula.box psi) .universal_target f t h_box
      cases h_or with
      | inl h_old =>
        cases h_inv.1 f t psi h_old with
        | inl h_closed =>
          left
          intro f' h_pos'
          have h_or_pos := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx item.formula .universal_target f' t h_pos'
          cases h_or_pos with
          | inl h_pos_old =>
            exact addFormula_preserves_mem_getFormulas_same state.seed f' t psi item.formula .universal_target (h_closed f' h_pos_old)
          | inr h_new_pos =>
            obtain ⟨hf', ht'⟩ := h_new_pos
            subst hf' ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · exact addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx psi item.formula .universal_target (h_closed item.famIdx h_old_pos)
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        -- Box psi = item.formula, but item.formula is an implication
        have h_imp := classifyFormula_eq_implication item.formula phi1 phi2 h_class
        simp only [h_imp] at h_eq
        exact absurd h_eq.1 Formula.noConfusion
    constructor
    · -- G psi closure
      intro f t psi h_G
      have h_or := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx item.formula
                     (Formula.all_future psi) .universal_target f t h_G
      cases h_or with
      | inl h_old =>
        cases h_inv.2.1 f t psi h_old with
        | inl h_closed =>
          left
          intro t' h_lt h_pos'
          have h_or_pos := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx item.formula .universal_target f t' h_pos'
          cases h_or_pos with
          | inl h_pos_old =>
            exact addFormula_preserves_mem_getFormulas_same state.seed f t' psi item.formula .universal_target (h_closed t' h_lt h_pos_old)
          | inr h_new_pos =>
            obtain ⟨hf, ht'⟩ := h_new_pos
            subst hf ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · exact addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx psi item.formula .universal_target (h_closed item.timeIdx h_lt h_old_pos)
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        have h_imp := classifyFormula_eq_implication item.formula phi1 phi2 h_class
        simp only [h_imp] at h_eq
        exact absurd h_eq.1 Formula.noConfusion
    · -- H psi closure
      intro f t psi h_H
      have h_or := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx item.formula
                     (Formula.all_past psi) .universal_target f t h_H
      cases h_or with
      | inl h_old =>
        cases h_inv.2.2 f t psi h_old with
        | inl h_closed =>
          left
          intro t' h_lt h_pos'
          have h_or_pos := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx item.formula .universal_target f t' h_pos'
          cases h_or_pos with
          | inl h_pos_old =>
            exact addFormula_preserves_mem_getFormulas_same state.seed f t' psi item.formula .universal_target (h_closed t' h_lt h_pos_old)
          | inr h_new_pos =>
            obtain ⟨hf, ht'⟩ := h_new_pos
            subst hf ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · exact addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx psi item.formula .universal_target (h_closed item.timeIdx h_lt h_old_pos)
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        have h_imp := classifyFormula_eq_implication item.formula phi1 phi2 h_class
        simp only [h_imp] at h_eq
        exact absurd h_eq.1 Formula.noConfusion
  | .negation phi =>
    -- negation case: just adds item.formula (a generic negation), which is not Box/G/H
    simp only [processWorkItem, h_class] at h_proc
    simp only [Prod.mk.injEq] at h_proc
    obtain ⟨h_newWork, h_state'⟩ := h_proc
    subst h_newWork h_state'
    simp only [List.filter_nil, List.append_nil]
    constructor
    · -- Box psi closure
      intro f t psi h_box
      have h_or := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx item.formula
                     (Formula.box psi) .universal_target f t h_box
      cases h_or with
      | inl h_old =>
        cases h_inv.1 f t psi h_old with
        | inl h_closed =>
          left
          intro f' h_pos'
          have h_or_pos := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx item.formula .universal_target f' t h_pos'
          cases h_or_pos with
          | inl h_pos_old =>
            exact addFormula_preserves_mem_getFormulas_same state.seed f' t psi item.formula .universal_target (h_closed f' h_pos_old)
          | inr h_new_pos =>
            obtain ⟨hf', ht'⟩ := h_new_pos
            subst hf' ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · exact addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx psi item.formula .universal_target (h_closed item.famIdx h_old_pos)
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        -- Box psi = item.formula, but item.formula is a negation
        have h_neg := classifyFormula_eq_negation item.formula phi h_class
        simp only [h_neg] at h_eq
        -- Formula.neg = Formula.imp _ Formula.bot ≠ Formula.box
        unfold Formula.neg at h_eq
        exact absurd h_eq.1 Formula.noConfusion
    constructor
    · -- G psi closure
      intro f t psi h_G
      have h_or := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx item.formula
                     (Formula.all_future psi) .universal_target f t h_G
      cases h_or with
      | inl h_old =>
        cases h_inv.2.1 f t psi h_old with
        | inl h_closed =>
          left
          intro t' h_lt h_pos'
          have h_or_pos := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx item.formula .universal_target f t' h_pos'
          cases h_or_pos with
          | inl h_pos_old =>
            exact addFormula_preserves_mem_getFormulas_same state.seed f t' psi item.formula .universal_target (h_closed t' h_lt h_pos_old)
          | inr h_new_pos =>
            obtain ⟨hf, ht'⟩ := h_new_pos
            subst hf ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · exact addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx psi item.formula .universal_target (h_closed item.timeIdx h_lt h_old_pos)
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        have h_neg := classifyFormula_eq_negation item.formula phi h_class
        simp only [h_neg] at h_eq
        unfold Formula.neg at h_eq
        exact absurd h_eq.1 Formula.noConfusion
    · -- H psi closure
      intro f t psi h_H
      have h_or := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx item.formula
                     (Formula.all_past psi) .universal_target f t h_H
      cases h_or with
      | inl h_old =>
        cases h_inv.2.2 f t psi h_old with
        | inl h_closed =>
          left
          intro t' h_lt h_pos'
          have h_or_pos := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx item.formula .universal_target f t' h_pos'
          cases h_or_pos with
          | inl h_pos_old =>
            exact addFormula_preserves_mem_getFormulas_same state.seed f t' psi item.formula .universal_target (h_closed t' h_lt h_pos_old)
          | inr h_new_pos =>
            obtain ⟨hf, ht'⟩ := h_new_pos
            subst hf ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · exact addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx psi item.formula .universal_target (h_closed item.timeIdx h_lt h_old_pos)
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        have h_neg := classifyFormula_eq_negation item.formula phi h_class
        simp only [h_neg] at h_eq
        unfold Formula.neg at h_eq
        exact absurd h_eq.1 Formula.noConfusion
  | .boxPositive psi =>
    -- boxPositive case: adds Box psi to item position, then adds psi to ALL families
    -- processWorkItem for boxPositive:
    --   seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.box psi)
    --   familyIndices := seed1.familyIndices
    --   seed2 := familyIndices.foldl (fun s f => s.addFormula f item.timeIdx psi) seed1
    -- Closure proof: for any Box theta in seed2, show theta at all families at that time
    simp only [processWorkItem, h_class] at h_proc
    simp only [Prod.mk.injEq] at h_proc
    obtain ⟨h_newWork, h_state'⟩ := h_proc
    subst h_newWork h_state'
    -- The new seed is: familyIndices.foldl addFormula (state.seed.addFormula ...)
    -- We call the intermediate seed "seed1"
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.box psi) .universal_target
    constructor
    · -- Box theta closure
      intro f t theta h_box
      -- h_box: Box theta ∈ seed2.getFormulas f t
      -- First determine if Box theta was in seed1 or added by foldl
      -- The foldl only adds psi (not Box formulas), so Box theta must be in seed1
      have h_in_seed1 : Formula.box theta ∈ seed1.getFormulas f t := by
        have h_or := mem_getFormulas_after_foldl_fam psi (Formula.box theta) item.timeIdx
                       seed1.familyIndices seed1 f h_box
        cases h_or with
        | inl h_old => exact h_old
        | inr h_eq =>
          -- psi = Box theta - contradiction since psi has lower complexity
          obtain ⟨h_eq_formula, _⟩ := h_eq
          exact absurd h_eq_formula.symm Formula.noConfusion
      -- Now Box theta is in seed1 = state.seed.addFormula ...
      have h_or2 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.box psi) (Formula.box theta) .universal_target f t h_in_seed1
      cases h_or2 with
      | inl h_old =>
        -- Box theta was in original seed - use existing invariant
        cases h_inv.1 f t theta h_old with
        | inl h_closed =>
          -- Already closed in original seed, show it stays closed
          left
          intro f' h_pos'
          -- h_pos' says f' has position at item.timeIdx in the new seed
          -- Need to show theta ∈ new seed at f' item.timeIdx
          -- Since theta was at all families at t in old seed, we just need to preserve
          -- But wait - h_closed says theta at f' t, not item.timeIdx
          -- Actually theta is at (f, t) in old seed, not (f, item.timeIdx)
          -- We need to be careful about the time coordinate
          -- The closure says: for all f' with position at t, theta ∈ getFormulas f' t
          -- In the new seed, we need same at time t (not item.timeIdx)
          have h_or_pos_old := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                                 (Formula.box psi) .universal_target f' t h_pos'
          cases h_or_pos_old with
          | inl h_pos_old_state =>
            -- f' had position at t in old seed
            have h_theta_old := h_closed f' h_pos_old_state
            -- Now preserve through addFormula and foldl
            have h_theta_seed1 : theta ∈ seed1.getFormulas f' t :=
              addFormula_preserves_mem_getFormulas_same state.seed f' t theta (Formula.box psi) .universal_target h_theta_old
            exact foldl_addFormula_fam_preserves_mem_general theta psi f' item.timeIdx t seed1.familyIndices seed1 h_theta_seed1
          | inr h_new_pos =>
            -- New position created by addFormula
            obtain ⟨hf', ht'⟩ := h_new_pos
            subst hf' ht'
            -- t = item.timeIdx and f' = item.famIdx
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · have h_theta_old := h_closed item.famIdx h_old_pos
              have h_theta_seed1 : theta ∈ seed1.getFormulas item.famIdx item.timeIdx :=
                addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta (Formula.box psi) .universal_target h_theta_old
              exact foldl_addFormula_fam_preserves_mem_general theta psi item.famIdx item.timeIdx item.timeIdx seed1.familyIndices seed1 h_theta_seed1
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          -- Work item still pending
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        -- Box theta = Box psi (newly added formula)
        obtain ⟨h_formula_eq, hf, ht⟩ := h_eq
        have h_theta_eq : theta = psi := Formula.box.inj h_formula_eq
        subst h_theta_eq hf ht
        -- Box psi was just added at (item.famIdx, item.timeIdx)
        -- We need to show psi is at all families at item.timeIdx
        left
        intro f' h_pos'
        -- psi was added to ALL families at item.timeIdx by the foldl
        -- If f' has position, then f' ∈ familyIndices (of seed1)
        -- But wait - h_pos' is position in final seed (seed2), not seed1
        -- We need to show f' ∈ seed1.familyIndices or that psi is there anyway
        -- Actually, foldl adds psi at all seed1.familyIndices
        -- If f' has position in seed2, either:
        --   1. f' had position in seed1 (so f' ∈ seed1.familyIndices)
        --   2. f' is a new position created by foldl (but foldl only adds at existing positions)
        -- Actually, addFormula can create new positions, but let's check hasPosition
        -- The foldl only uses seed1.familyIndices, so it only adds to existing families
        -- If h_pos' says f' has position in seed2, we need to check if it's in familyIndices
        -- Key insight: foldl doesn't create NEW family indices, it only adds to existing ones
        -- So hasPosition in seed2 at item.timeIdx means either:
        --   - Had position in seed1, OR
        --   - Position at a different time that somehow appeared
        -- But foldl only operates at item.timeIdx with existing families
        -- For closure: if f' has position at item.timeIdx in seed2, show psi there
        -- If f' ∈ seed1.familyIndices, then psi was added there
        by_cases h_f'_in : f' ∈ seed1.familyIndices
        · exact foldl_addFormula_fam_puts_phi_in_all psi item.timeIdx seed1.familyIndices seed1 f' h_f'_in
        · -- f' ∉ seed1.familyIndices but has position in seed2 at item.timeIdx
          -- The foldl only iterates over seed1.familyIndices
          -- So foldl cannot create position for f' that wasn't in seed1
          -- This means position must have been in seed1
          -- But if f' not in familyIndices, it can't have position - contradiction
          -- Actually hasPosition and familyIndices are related:
          -- hasPosition f t = true iff f appears in some entry with that time
          -- familyIndices = all family indices that appear in entries
          -- If f' has position at item.timeIdx in seed2, and foldl doesn't create new families,
          -- then f' must have had position in seed1
          -- Let's use that foldl only adds formulas, doesn't create positions at new families
          -- Actually this is getting complex. Let me use a different approach.
          -- If h_pos' says hasPosition f' item.timeIdx in seed2, let's trace back
          -- The foldl uses seed1.familyIndices and adds at item.timeIdx only to those
          -- If f' ∉ seed1.familyIndices, then foldl didn't touch f'
          -- So seed2.getFormulas f' item.timeIdx = seed1.getFormulas f' item.timeIdx
          -- And seed1 = addFormula state.seed item.famIdx item.timeIdx (Box psi)
          -- If f' ≠ item.famIdx, then seed1.getFormulas f' item.timeIdx = state.seed.getFormulas f' item.timeIdx
          -- So if f' has position in seed2, it had position in state.seed
          -- But then f' would be in state.seed.familyIndices ⊆ seed1.familyIndices (modulo new item.famIdx)
          -- Actually addFormula can add item.famIdx to familyIndices if it was new
          -- This is getting complicated. Let me use hasPosition_implies_in_familyIndices
          -- Wait, that lemma says hasPosition f t -> f ∈ familyIndices
          -- But familyIndices doesn't depend on t
          -- So if seed2.hasPosition f' item.timeIdx = true, then f' ∈ seed2.familyIndices
          -- And seed2.familyIndices after foldl... hmm, foldl adds at existing families
          -- Let me check: foldl doesn't change familyIndices if we only add to existing families
          -- Actually addFormula can add new entries, which adds to familyIndices
          -- But in our case, we're iterating over seed1.familyIndices and adding at those families
          -- So we're not creating new family indices in the foldl
          -- Thus seed2.familyIndices = seed1.familyIndices
          -- And if h_pos' : seed2.hasPosition f' item.timeIdx, then f' ∈ seed2.familyIndices = seed1.familyIndices
          -- This contradicts h_f'_in
          -- Let me prove this more carefully
          exfalso
          -- The foldl iterates over seed1.familyIndices and does addFormula at those families
          -- This doesn't create new family indices (it just adds formulas at existing positions)
          -- So seed2.familyIndices ⊆ seed1.familyIndices for families at item.timeIdx
          -- Actually this needs a helper lemma. For now, let's use that if hasPosition holds,
          -- then the family must be in familyIndices
          -- h_pos' says seed2.hasPosition f' item.timeIdx
          -- We need seed2.familyIndices ⊆ seed1.familyIndices
          -- Actually, addFormula CAN create new entries at new families if position didn't exist
          -- But foldl iterates over seed1.familyIndices, so it only adds at families already in seed1
          -- Thus it cannot create position at f' if f' ∉ seed1.familyIndices
          -- So hasPosition f' item.timeIdx in seed2 -> f' ∈ seed1.familyIndices, contradiction
          -- Use foldl_addFormula_fam_preserves_hasPosition_not_in:
          -- Since f' ∉ seed1.familyIndices, foldl doesn't change hasPosition for f'
          have h_unchanged := foldl_addFormula_fam_preserves_hasPosition_not_in
            psi item.timeIdx seed1.familyIndices seed1 f' h_f'_in
          -- h_pos' says hasPosition in seed2 = true
          -- h_unchanged says hasPosition in seed2 = hasPosition in seed1
          rw [h_unchanged] at h_pos'
          -- Now h_pos' : seed1.hasPosition f' item.timeIdx = true
          -- But f' ∉ seed1.familyIndices, so no entry has familyIdx = f'
          -- Therefore hasPosition f' item.timeIdx = false
          -- This contradicts h_pos'
          have h_f'_in_seed1 := hasPosition_implies_in_familyIndices seed1 f' item.timeIdx h_pos'
          exact absurd h_f'_in_seed1 h_f'_in
    constructor
    · -- G theta closure (similar structure, but Box doesn't add G formulas)
      intro f t theta h_G
      -- G theta in seed2 must come from seed1 (foldl only adds psi, not G formulas)
      have h_in_seed1 : Formula.all_future theta ∈ seed1.getFormulas f t := by
        have h_or := mem_getFormulas_after_foldl_fam psi (Formula.all_future theta) item.timeIdx
                       seed1.familyIndices seed1 f h_G
        cases h_or with
        | inl h_old => exact h_old
        | inr h_eq =>
          obtain ⟨h_eq_formula, _⟩ := h_eq
          exact absurd h_eq_formula.symm Formula.noConfusion
      have h_or2 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.box psi) (Formula.all_future theta) .universal_target f t h_in_seed1
      cases h_or2 with
      | inl h_old =>
        cases h_inv.2.1 f t theta h_old with
        | inl h_closed =>
          left
          intro t' h_lt h_pos'
          have h_or_pos_old := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                                 (Formula.box psi) .universal_target f t' h_pos'
          cases h_or_pos_old with
          | inl h_pos_old_state =>
            have h_theta_old := h_closed t' h_lt h_pos_old_state
            have h_theta_seed1 : theta ∈ seed1.getFormulas f t' :=
              addFormula_preserves_mem_getFormulas_same state.seed f t' theta (Formula.box psi) .universal_target h_theta_old
            exact foldl_addFormula_fam_preserves_mem_general theta psi f item.timeIdx t' seed1.familyIndices seed1 h_theta_seed1
          | inr h_new_pos =>
            obtain ⟨hf', ht'⟩ := h_new_pos
            subst hf' ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · have h_theta_old := h_closed item.timeIdx h_lt h_old_pos
              have h_theta_seed1 : theta ∈ seed1.getFormulas item.famIdx item.timeIdx :=
                addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta (Formula.box psi) .universal_target h_theta_old
              exact foldl_addFormula_fam_preserves_mem_general theta psi item.famIdx item.timeIdx item.timeIdx seed1.familyIndices seed1 h_theta_seed1
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        -- G theta = Box psi - impossible
        obtain ⟨h_formula_eq, _, _⟩ := h_eq
        exact absurd h_formula_eq Formula.noConfusion
    · -- H theta closure (similar)
      intro f t theta h_H
      have h_in_seed1 : Formula.all_past theta ∈ seed1.getFormulas f t := by
        have h_or := mem_getFormulas_after_foldl_fam psi (Formula.all_past theta) item.timeIdx
                       seed1.familyIndices seed1 f h_H
        cases h_or with
        | inl h_old => exact h_old
        | inr h_eq =>
          obtain ⟨h_eq_formula, _⟩ := h_eq
          exact absurd h_eq_formula.symm Formula.noConfusion
      have h_or2 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.box psi) (Formula.all_past theta) .universal_target f t h_in_seed1
      cases h_or2 with
      | inl h_old =>
        cases h_inv.2.2 f t theta h_old with
        | inl h_closed =>
          left
          intro t' h_lt h_pos'
          have h_or_pos_old := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                                 (Formula.box psi) .universal_target f t' h_pos'
          cases h_or_pos_old with
          | inl h_pos_old_state =>
            have h_theta_old := h_closed t' h_lt h_pos_old_state
            have h_theta_seed1 : theta ∈ seed1.getFormulas f t' :=
              addFormula_preserves_mem_getFormulas_same state.seed f t' theta (Formula.box psi) .universal_target h_theta_old
            exact foldl_addFormula_fam_preserves_mem_general theta psi f item.timeIdx t' seed1.familyIndices seed1 h_theta_seed1
          | inr h_new_pos =>
            obtain ⟨hf', ht'⟩ := h_new_pos
            subst hf' ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · have h_theta_old := h_closed item.timeIdx h_lt h_old_pos
              have h_theta_seed1 : theta ∈ seed1.getFormulas item.famIdx item.timeIdx :=
                addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta (Formula.box psi) .universal_target h_theta_old
              exact foldl_addFormula_fam_preserves_mem_general theta psi item.famIdx item.timeIdx item.timeIdx seed1.familyIndices seed1 h_theta_seed1
            · exact absurd h_item_pos h_old_pos
        | inr h_pending =>
          right
          obtain ⟨w, hw_in, hw_eq⟩ := h_pending
          use w
          constructor
          · exact List.mem_append_left _ hw_in
          · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
      | inr h_eq =>
        obtain ⟨h_formula_eq, _, _⟩ := h_eq
        exact absurd h_formula_eq Formula.noConfusion
  | .boxNegative psi =>
    -- boxNegative case: adds neg(Box psi) to item position, creates new family with neg psi
    -- processWorkItem for boxNegative:
    --   seed1 := state.seed.addFormula item.famIdx item.timeIdx (neg(Box psi))
    --   (seed2, newFamIdx) := seed1.createNewFamily item.timeIdx (neg psi)
    --   newWork := [⟨neg psi, newFamIdx, item.timeIdx⟩]
    -- Neither neg(Box psi) nor neg psi is a Box/G/H formula
    -- So any Box/G/H in the new seed must come from the old seed
    simp only [processWorkItem, h_class] at h_proc
    simp only [Prod.mk.injEq] at h_proc
    obtain ⟨h_newWork, h_state'⟩ := h_proc
    subst h_newWork h_state'
    -- The new seed goes through: addFormula, then createNewFamily
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.neg (Formula.box psi)) .universal_target
    constructor
    · -- Box theta closure
      intro f t theta h_box
      -- Use backward reasoning to trace Box theta to original seed
      -- Step 1: createNewFamily adds neg psi (not Box theta), so Box theta in seed1
      have h_or1 := mem_getFormulas_after_createNewFamily seed1 item.timeIdx (Formula.neg psi)
                      (Formula.box theta) f t h_box
      have h_in_seed1 : Formula.box theta ∈ seed1.getFormulas f t := by
        cases h_or1 with
        | inl h => exact h
        | inr h => exact absurd h.1 Formula.noConfusion -- neg psi ≠ Box theta
      -- Step 2: addFormula adds neg(Box psi) (not Box theta), so Box theta in original
      have h_or2 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.neg (Formula.box psi)) (Formula.box theta) .universal_target f t h_in_seed1
      have h_in_orig : Formula.box theta ∈ state.seed.getFormulas f t := by
        cases h_or2 with
        | inl h => exact h
        | inr h =>
          -- neg(Box psi) = Box theta - impossible
          unfold Formula.neg at h
          exact absurd h.1 Formula.noConfusion
      cases h_inv.1 f t theta h_in_orig with
      | inl h_closed =>
        left
        intro f' h_pos'
        -- theta was at all families in old seed with position at t
        -- Need to show theta at f' in new seed
        -- First check if f' had position in old seed
        -- If yes, theta was there and gets preserved
        -- If f' is the new family, we need to handle that case
        have h_or_pos := createNewFamily_preserves_hasPosition seed1 item.timeIdx (Formula.neg psi) f' t h_pos'
        have h_or_pos2 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                            (Formula.neg (Formula.box psi)) .universal_target f' t h_or_pos
        cases h_or_pos2 with
        | inl h_pos_orig =>
          -- f' had position in original seed, so theta was there
          have h_theta_orig := h_closed f' h_pos_orig
          -- Preserve through addFormula and createNewFamily
          have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f' t theta
                                  (Formula.neg (Formula.box psi)) .universal_target h_theta_orig
          exact createNewFamily_preserves_mem_getFormulas' seed1 item.timeIdx theta (Formula.neg psi) f' t h_theta_seed1
        | inr h_new_pos =>
          -- f' = item.famIdx and t = item.timeIdx (position created by addFormula)
          obtain ⟨hf', ht'⟩ := h_new_pos
          subst hf' ht'
          by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
          · have h_theta_orig := h_closed item.famIdx h_old_pos
            have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                    (Formula.neg (Formula.box psi)) .universal_target h_theta_orig
            exact createNewFamily_preserves_mem_getFormulas' seed1 item.timeIdx theta (Formula.neg psi) item.famIdx item.timeIdx h_theta_seed1
          · exact absurd h_item_pos h_old_pos
      | inr h_pending =>
        right
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        use w
        constructor
        · exact List.mem_append_left _ hw_in
        · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
    constructor
    · -- G theta closure (similar - neg formulas don't affect G formulas)
      intro f t theta h_G
      -- Same backward reasoning as Box theta
      have h_or1 := mem_getFormulas_after_createNewFamily seed1 item.timeIdx (Formula.neg psi)
                      (Formula.all_future theta) f t h_G
      have h_in_seed1 : Formula.all_future theta ∈ seed1.getFormulas f t := by
        cases h_or1 with
        | inl h => exact h
        | inr h => exact absurd h.1 Formula.noConfusion
      have h_or2 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.neg (Formula.box psi)) (Formula.all_future theta) .universal_target f t h_in_seed1
      have h_in_orig : Formula.all_future theta ∈ state.seed.getFormulas f t := by
        cases h_or2 with
        | inl h => exact h
        | inr h => unfold Formula.neg at h; exact absurd h.1 Formula.noConfusion
      cases h_inv.2.1 f t theta h_in_orig with
      | inl h_closed =>
        left
        intro t' h_lt h_pos'
        have h_or_pos := createNewFamily_preserves_hasPosition seed1 item.timeIdx (Formula.neg psi) f t' h_pos'
        have h_or_pos2 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                            (Formula.neg (Formula.box psi)) .universal_target f t' h_or_pos
        cases h_or_pos2 with
        | inl h_pos_orig =>
          have h_theta_orig := h_closed t' h_lt h_pos_orig
          have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f t' theta
                                  (Formula.neg (Formula.box psi)) .universal_target h_theta_orig
          exact createNewFamily_preserves_mem_getFormulas' seed1 item.timeIdx theta (Formula.neg psi) f t' h_theta_seed1
        | inr h_new_pos =>
          obtain ⟨hf', ht'⟩ := h_new_pos
          subst hf' ht'
          by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
          · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
            have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                    (Formula.neg (Formula.box psi)) .universal_target h_theta_orig
            exact createNewFamily_preserves_mem_getFormulas' seed1 item.timeIdx theta (Formula.neg psi) item.famIdx item.timeIdx h_theta_seed1
          · exact absurd h_item_pos h_old_pos
      | inr h_pending =>
        right
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        use w
        constructor
        · exact List.mem_append_left _ hw_in
        · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
    · -- H theta closure (similar)
      intro f t theta h_H
      have h_or1 := mem_getFormulas_after_createNewFamily seed1 item.timeIdx (Formula.neg psi)
                      (Formula.all_past theta) f t h_H
      have h_in_seed1 : Formula.all_past theta ∈ seed1.getFormulas f t := by
        cases h_or1 with
        | inl h => exact h
        | inr h => exact absurd h.1 Formula.noConfusion
      have h_or2 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.neg (Formula.box psi)) (Formula.all_past theta) .universal_target f t h_in_seed1
      have h_in_orig : Formula.all_past theta ∈ state.seed.getFormulas f t := by
        cases h_or2 with
        | inl h => exact h
        | inr h => unfold Formula.neg at h; exact absurd h.1 Formula.noConfusion
      cases h_inv.2.2 f t theta h_in_orig with
      | inl h_closed =>
        left
        intro t' h_lt h_pos'
        have h_or_pos := createNewFamily_preserves_hasPosition seed1 item.timeIdx (Formula.neg psi) f t' h_pos'
        have h_or_pos2 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                            (Formula.neg (Formula.box psi)) .universal_target f t' h_or_pos
        cases h_or_pos2 with
        | inl h_pos_orig =>
          have h_theta_orig := h_closed t' h_lt h_pos_orig
          have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f t' theta
                                  (Formula.neg (Formula.box psi)) .universal_target h_theta_orig
          exact createNewFamily_preserves_mem_getFormulas' seed1 item.timeIdx theta (Formula.neg psi) f t' h_theta_seed1
        | inr h_new_pos =>
          obtain ⟨hf', ht'⟩ := h_new_pos
          subst hf' ht'
          by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
          · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
            have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                    (Formula.neg (Formula.box psi)) .universal_target h_theta_orig
            exact createNewFamily_preserves_mem_getFormulas' seed1 item.timeIdx theta (Formula.neg psi) item.famIdx item.timeIdx h_theta_seed1
          · exact absurd h_item_pos h_old_pos
      | inr h_pending =>
        right
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        use w
        constructor
        · exact List.mem_append_left _ hw_in
        · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
  | .futurePositive psi =>
    -- futurePositive case: adds G psi, psi to current; adds psi, G psi to ALL future times
    -- processWorkItem for futurePositive:
    --   seed1 := state.seed.addFormula item.famIdx item.timeIdx (G psi)
    --   seed2 := seed1.addFormula item.famIdx item.timeIdx psi
    --   futureTimes := getFutureTimes seed2 item.famIdx item.timeIdx
    --   seed3 := foldl (adds psi and G psi at each future time) seed2
    -- The final seed has G psi at current time AND all future times
    simp only [processWorkItem, h_class] at h_proc
    simp only [Prod.mk.injEq] at h_proc
    obtain ⟨h_newWork, h_state'⟩ := h_proc
    subst h_newWork h_state'
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.all_future psi) .universal_target
    let seed2 := seed1.addFormula item.famIdx item.timeIdx psi .universal_target
    let futureTimes := getFutureTimes seed2 item.famIdx item.timeIdx
    constructor
    · -- Box theta closure
      intro f t theta h_box
      -- Box theta in final seed - trace back through the compound foldl, then two addFormulas
      have h_or := mem_getFormulas_after_foldl_compound_future psi (Formula.box theta) item.famIdx
                     futureTimes seed2 f t h_box
      have h_in_seed2 : Formula.box theta ∈ seed2.getFormulas f t := by
        cases h_or with
        | inl h_old => exact h_old
        | inr h_added =>
          cases h_added with
          | inl h_is_psi =>
            obtain ⟨h_eq, _, _⟩ := h_is_psi
            exact absurd h_eq.symm Formula.noConfusion
          | inr h_is_gpsi =>
            obtain ⟨h_eq, _, _⟩ := h_is_gpsi
            exact absurd h_eq.symm Formula.noConfusion
      -- Now trace back through seed2 = seed1.addFormula ... psi
      have h_or2 := mem_getFormulas_after_addFormula seed1 item.famIdx item.timeIdx psi
                      (Formula.box theta) .universal_target f t h_in_seed2
      have h_in_seed1 : Formula.box theta ∈ seed1.getFormulas f t := by
        cases h_or2 with
        | inl h => exact h
        | inr h => exact absurd h.1.symm Formula.noConfusion
      -- Now trace back through seed1 = state.seed.addFormula ... (G psi)
      have h_or3 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.all_future psi) (Formula.box theta) .universal_target f t h_in_seed1
      have h_in_orig : Formula.box theta ∈ state.seed.getFormulas f t := by
        cases h_or3 with
        | inl h => exact h
        | inr h => exact absurd h.1.symm Formula.noConfusion
      -- Now use original invariant
      cases h_inv.1 f t theta h_in_orig with
      | inl h_closed =>
        left
        intro f' h_pos'
        -- h_pos' : hasPosition f' t in final seed
        -- Trace back hasPosition through compound foldl
        have h_or_pos := foldl_compound_future_hasPosition_backward psi item.famIdx futureTimes seed2 f' t h_pos'
        cases h_or_pos with
        | inl h_pos_seed2 =>
          -- Position was in seed2
          have h_or_pos2 := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target f' t h_pos_seed2
          cases h_or_pos2 with
          | inl h_pos_seed1 =>
            have h_or_pos3 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                                (Formula.all_future psi) .universal_target f' t h_pos_seed1
            cases h_or_pos3 with
            | inl h_pos_orig =>
              have h_theta_orig := h_closed f' h_pos_orig
              have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f' t theta
                                      (Formula.all_future psi) .universal_target h_theta_orig
              have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 f' t theta psi .universal_target h_theta_seed1
              exact foldl_compound_future_preserves_mem psi theta item.famIdx futureTimes seed2 f' t h_theta_seed2
            | inr h_new_pos =>
              obtain ⟨hf', ht'⟩ := h_new_pos
              subst hf' ht'
              by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
              · have h_theta_orig := h_closed item.famIdx h_old_pos
                have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                        (Formula.all_future psi) .universal_target h_theta_orig
                have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx item.timeIdx theta psi .universal_target h_theta_seed1
                exact foldl_compound_future_preserves_mem psi theta item.famIdx futureTimes seed2 item.famIdx item.timeIdx h_theta_seed2
              · exact absurd h_item_pos h_old_pos
          | inr h_new_pos =>
            obtain ⟨hf', ht'⟩ := h_new_pos
            subst hf' ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · have h_theta_orig := h_closed item.famIdx h_old_pos
              have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                      (Formula.all_future psi) .universal_target h_theta_orig
              have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx item.timeIdx theta psi .universal_target h_theta_seed1
              exact foldl_compound_future_preserves_mem psi theta item.famIdx futureTimes seed2 item.famIdx item.timeIdx h_theta_seed2
            · exact absurd h_item_pos h_old_pos
        | inr h_new_pos =>
          -- New position at (item.famIdx, some time in futureTimes)
          obtain ⟨hf', h_t_in⟩ := h_new_pos
          subst hf'
          -- t ∈ futureTimes, which are times > item.timeIdx
          -- For Box theta closure at time t, we need theta at all families at time t
          -- But the position was created at item.famIdx, so we're at that family
          -- The closure for Box theta says theta at all families at time t with position
          -- We're only at item.famIdx here
          -- Actually h_closed says: for all f' with position at t in orig seed, theta there
          -- The new position is at (item.famIdx, t) where t ∈ futureTimes
          -- We need to show theta is at item.famIdx, t in final seed
          -- Since theta was at item.famIdx, t in orig seed (by h_closed if item.famIdx had position)
          -- Let's check if item.famIdx had position at t in orig seed
          -- futureTimes are times in seed2 at item.famIdx with time > item.timeIdx
          -- seed2 has position at item.famIdx, item.timeIdx (from the addFormulas)
          -- But for t > item.timeIdx, it might or might not have position in orig
          -- Actually, getFutureTimes looks at seed2's entries, not orig
          -- If t ∈ futureTimes, then seed2.hasPosition item.famIdx t = true
          -- This means either orig had it, or it was created
          -- The addFormulas only add at item.timeIdx, not at other times
          -- So if t ∈ futureTimes and t > item.timeIdx, then orig had hasPosition item.famIdx t
          -- Then h_closed gives us theta at item.famIdx t
          -- We need to show item.famIdx had position at t in state.seed
          have h_pos_seed2 : seed2.hasPosition item.famIdx t := by
            -- t ∈ futureTimes means t > item.timeIdx and seed2 has entry with famIdx=item.famIdx, timeIdx=t
            unfold getFutureTimes at h_t_in
            simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t_in
            obtain ⟨entry, ⟨h_filt, h_gt⟩, h_teq⟩ := h_t_in
            subst h_teq
            unfold ModelSeed.hasPosition
            simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq]
            use entry
            simp only [List.mem_filter, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h_filt
            exact ⟨h_filt.1, h_filt.2, rfl⟩
          have h_t_gt : t > item.timeIdx := by
            unfold getFutureTimes at h_t_in
            simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t_in
            obtain ⟨entry, ⟨_, h_gt⟩, h_teq⟩ := h_t_in
            omega
          -- seed2 = seed1.addFormula ... psi at item.timeIdx
          -- Since t > item.timeIdx, addFormula at item.timeIdx doesn't affect position at t
          have h_pos_seed1 : seed1.hasPosition item.famIdx t := by
            have h := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target item.famIdx t h_pos_seed2
            cases h with
            | inl h => exact h
            | inr h => omega  -- t ≠ item.timeIdx
          have h_pos_orig : state.seed.hasPosition item.famIdx t := by
            have h := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx (Formula.all_future psi) .universal_target item.famIdx t h_pos_seed1
            cases h with
            | inl h => exact h
            | inr h => omega
          have h_theta_orig := h_closed item.famIdx h_pos_orig
          have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx t theta
                                  (Formula.all_future psi) .universal_target h_theta_orig
          have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx t theta psi .universal_target h_theta_seed1
          exact foldl_compound_future_preserves_mem psi theta item.famIdx futureTimes seed2 item.famIdx t h_theta_seed2
      | inr h_pending =>
        right
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        use w
        constructor
        · exact List.mem_append_left _ hw_in
        · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
    constructor
    · -- G theta closure
      intro f t theta h_G
      -- Trace G theta back to orig
      have h_or := mem_getFormulas_after_foldl_compound_future psi (Formula.all_future theta) item.famIdx
                     futureTimes seed2 f t h_G
      cases h_or with
      | inl h_in_seed2 =>
        have h_or2 := mem_getFormulas_after_addFormula seed1 item.famIdx item.timeIdx psi
                        (Formula.all_future theta) .universal_target f t h_in_seed2
        have h_in_seed1 : Formula.all_future theta ∈ seed1.getFormulas f t := by
          cases h_or2 with
          | inl h => exact h
          | inr h => exact absurd h.1.symm Formula.noConfusion
        have h_or3 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                        (Formula.all_future psi) (Formula.all_future theta) .universal_target f t h_in_seed1
        cases h_or3 with
        | inl h_in_orig =>
          cases h_inv.2.1 f t theta h_in_orig with
          | inl h_closed =>
            left
            intro t' h_lt h_pos'
            have h_or_pos := foldl_compound_future_hasPosition_backward psi item.famIdx futureTimes seed2 f t' h_pos'
            cases h_or_pos with
            | inl h_pos_seed2 =>
              have h_or_pos2 := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target f t' h_pos_seed2
              cases h_or_pos2 with
              | inl h_pos_seed1 =>
                have h_or_pos3 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                                    (Formula.all_future psi) .universal_target f t' h_pos_seed1
                cases h_or_pos3 with
                | inl h_pos_orig =>
                  have h_theta_orig := h_closed t' h_lt h_pos_orig
                  have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f t' theta
                                          (Formula.all_future psi) .universal_target h_theta_orig
                  have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 f t' theta psi .universal_target h_theta_seed1
                  exact foldl_compound_future_preserves_mem psi theta item.famIdx futureTimes seed2 f t' h_theta_seed2
                | inr h_new_pos =>
                  obtain ⟨hf', ht'⟩ := h_new_pos
                  subst hf' ht'
                  by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
                  · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
                    have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                            (Formula.all_future psi) .universal_target h_theta_orig
                    have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx item.timeIdx theta psi .universal_target h_theta_seed1
                    exact foldl_compound_future_preserves_mem psi theta item.famIdx futureTimes seed2 item.famIdx item.timeIdx h_theta_seed2
                  · exact absurd h_item_pos h_old_pos
              | inr h_new_pos =>
                obtain ⟨hf', ht'⟩ := h_new_pos
                subst hf' ht'
                by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
                · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
                  have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                          (Formula.all_future psi) .universal_target h_theta_orig
                  have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx item.timeIdx theta psi .universal_target h_theta_seed1
                  exact foldl_compound_future_preserves_mem psi theta item.famIdx futureTimes seed2 item.famIdx item.timeIdx h_theta_seed2
                · exact absurd h_item_pos h_old_pos
            | inr h_new_pos =>
              obtain ⟨hf', h_t'_in⟩ := h_new_pos
              subst hf'
              have h_t'_gt : t' > item.timeIdx := by
                unfold getFutureTimes at h_t'_in
                simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t'_in
                obtain ⟨entry, ⟨_, h_gt⟩, h_teq⟩ := h_t'_in
                omega
              have h_pos_seed2 : seed2.hasPosition item.famIdx t' := by
                unfold getFutureTimes at h_t'_in
                simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t'_in
                obtain ⟨entry, ⟨h_filt, _⟩, h_teq⟩ := h_t'_in
                subst h_teq
                unfold ModelSeed.hasPosition
                simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq]
                use entry
                simp only [List.mem_filter, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h_filt
                exact ⟨h_filt.1, h_filt.2, rfl⟩
              have h_pos_seed1 : seed1.hasPosition item.famIdx t' := by
                have h := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target item.famIdx t' h_pos_seed2
                cases h with
                | inl h => exact h
                | inr h => omega
              have h_pos_orig : state.seed.hasPosition item.famIdx t' := by
                have h := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx (Formula.all_future psi) .universal_target item.famIdx t' h_pos_seed1
                cases h with
                | inl h => exact h
                | inr h => omega
              have h_theta_orig := h_closed t' h_lt h_pos_orig
              have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx t' theta
                                      (Formula.all_future psi) .universal_target h_theta_orig
              have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx t' theta psi .universal_target h_theta_seed1
              exact foldl_compound_future_preserves_mem psi theta item.famIdx futureTimes seed2 item.famIdx t' h_theta_seed2
          | inr h_pending =>
            right
            obtain ⟨w, hw_in, hw_eq⟩ := h_pending
            use w
            constructor
            · exact List.mem_append_left _ hw_in
            · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
        | inr h_is_gpsi =>
          -- G theta = G psi (newly added)
          obtain ⟨h_formula_eq, hf, ht⟩ := h_is_gpsi
          have h_theta_eq : theta = psi := Formula.all_future.inj h_formula_eq
          subst h_theta_eq hf ht
          -- G psi was just added. We need to show psi is at all future times t' > t
          -- where t = item.timeIdx. This is exactly what futurePositive does!
          left
          intro t' h_lt h_pos'
          -- We need psi at (item.famIdx, t') where t' > item.timeIdx
          have h_or_pos := foldl_compound_future_hasPosition_backward psi item.famIdx futureTimes seed2 item.famIdx t' h_pos'
          cases h_or_pos with
          | inl h_pos_seed2 =>
            -- Position existed in seed2
            -- Check if t' is in futureTimes
            have h_or_pos2 := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target item.famIdx t' h_pos_seed2
            cases h_or_pos2 with
            | inl h_pos_seed1 =>
              have h_or_pos3 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                                  (Formula.all_future psi) .universal_target item.famIdx t' h_pos_seed1
              cases h_or_pos3 with
              | inl h_pos_orig =>
                -- t' had position in orig. t' > item.timeIdx = t.
                -- So t' is a future time that existed in orig.
                -- We need to check if t' ∈ futureTimes (from seed2)
                -- Actually, if t' had position in orig and t' > item.timeIdx,
                -- then after two addFormulas (which don't change position at t'),
                -- t' still has position in seed2, so t' ∈ futureTimes
                have h_t'_in_futureTimes : t' ∈ futureTimes := by
                  unfold getFutureTimes
                  simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq]
                  -- Need to show there's an entry in seed2.entries with famIdx=item.famIdx, timeIdx=t'
                  unfold ModelSeed.hasPosition at h_pos_seed1
                  simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h_pos_seed1
                  obtain ⟨entry, h_mem, h_fam, h_time⟩ := h_pos_seed1
                  use entry
                  -- entry is in seed1.entries with famIdx=item.famIdx, timeIdx=t'
                  -- seed1 = state.seed.addFormula at item.timeIdx
                  -- seed2 = seed1.addFormula at item.timeIdx
                  -- t' ≠ item.timeIdx (since t' > item.timeIdx > t = item.timeIdx is wrong...)
                  -- Wait, we have t' > t and t = item.timeIdx, so t' > item.timeIdx
                  -- Both addFormulas are at item.timeIdx, so entries at t' ≠ item.timeIdx are unchanged
                  -- We need entry ∈ seed2.entries
                  have h_t'_ne : t' ≠ item.timeIdx := by omega
                  -- seed2 = seed1.addFormula item.famIdx item.timeIdx psi
                  -- Since t' ≠ item.timeIdx, entries at (item.famIdx, t') are unchanged
                  -- So if entry ∈ seed1.entries, we need to trace to seed2
                  -- Actually addFormula either modifies an existing entry or adds a new one
                  -- If it modifies at (item.famIdx, item.timeIdx), it doesn't affect entry at t'
                  -- If it adds new entry at (item.famIdx, item.timeIdx), entry at t' is still there
                  -- Let's just show entry ∈ seed2.entries via membership reasoning
                  constructor
                  · constructor
                    · -- entry ∈ seed2.entries with famIdx = item.famIdx
                      unfold ModelSeed.addFormula at h_mem ⊢
                      cases h_find1 : seed1.entries.findIdx? (fun e => e.familyIdx == item.famIdx && e.timeIdx == item.timeIdx) with
                      | some idx1 =>
                        simp only [h_find1]
                        -- seed2.entries = seed1.entries.modify idx1 ...
                        -- entry ∈ seed1.entries with timeIdx = t' ≠ item.timeIdx
                        -- So entry is not at idx1, thus entry ∈ modified list
                        have h_idx1_spec := List.findIdx?_eq_some_iff_getElem.mp h_find1
                        -- entry's timeIdx is t', but idx1's entry has timeIdx = item.timeIdx
                        -- So entry ≠ seed1.entries[idx1]
                        by_cases h_eq_entry : entry = seed1.entries[h_idx1_spec.1]
                        · -- entry = seed1.entries[idx1]
                          simp only [Bool.and_eq_true, beq_iff_eq] at h_idx1_spec
                          rw [← h_time, h_eq_entry] at h_t'_ne
                          exact absurd h_idx1_spec.2.1.2 h_t'_ne
                        · -- entry ≠ seed1.entries[idx1], so it's preserved
                          have h_mem_mod := List.mem_modify_iff h_idx1_spec.1
                          rw [h_mem_mod]
                          exact Or.inr ⟨h_eq_entry, h_mem⟩
                      | none =>
                        simp only [h_find1]
                        -- seed2.entries = seed1.entries ++ [new entry at item.timeIdx]
                        -- entry ∈ seed1.entries, so entry ∈ seed1.entries ++ [...]
                        exact List.mem_append_left _ h_mem
                    · exact h_fam
                  · exact ⟨h_lt, h_time.symm⟩
                -- Now use foldl_compound_future_puts_psi_in_all
                exact foldl_compound_future_puts_psi_in_all psi item.famIdx futureTimes seed2 t' h_t'_in_futureTimes
              | inr h_new_pos =>
                obtain ⟨_, ht'⟩ := h_new_pos
                omega  -- t' = item.timeIdx but t' > item.timeIdx
            | inr h_new_pos =>
              obtain ⟨_, ht'⟩ := h_new_pos
              omega
          | inr h_new_pos =>
            -- New position from foldl at t' ∈ futureTimes
            obtain ⟨_, h_t'_in⟩ := h_new_pos
            exact foldl_compound_future_puts_psi_in_all psi item.famIdx futureTimes seed2 t' h_t'_in
      | inr h_added =>
        -- G theta was added by the foldl (either as psi or G psi at some time)
        cases h_added with
        | inl h_is_psi =>
          -- G theta = psi - contradiction
          obtain ⟨h_eq, _, _⟩ := h_is_psi
          exact absurd h_eq.symm Formula.noConfusion
        | inr h_is_gpsi =>
          -- G theta = G psi at some time t in futureTimes
          obtain ⟨h_eq, h_t_in, hf⟩ := h_is_gpsi
          have h_theta_eq : theta = psi := Formula.all_future.inj h_eq
          subst h_theta_eq hf
          -- G psi at time t, need psi at all t' > t
          -- But wait - the foldl adds G psi at time t, not at item.timeIdx
          -- The closure for G psi at time t is: psi at all t' > t
          -- t ∈ futureTimes means t > item.timeIdx
          left
          intro t' h_lt_t h_pos'
          -- Need psi at (item.famIdx, t') where t' > t and t > item.timeIdx
          have h_t_gt : t > item.timeIdx := by
            unfold getFutureTimes at h_t_in
            simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t_in
            obtain ⟨_, ⟨_, h_gt⟩, _⟩ := h_t_in
            exact h_gt
          have h_t'_gt : t' > item.timeIdx := by omega
          have h_or_pos := foldl_compound_future_hasPosition_backward psi item.famIdx futureTimes seed2 item.famIdx t' h_pos'
          cases h_or_pos with
          | inl h_pos_seed2 =>
            have h_or_pos2 := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target item.famIdx t' h_pos_seed2
            cases h_or_pos2 with
            | inl h_pos_seed1 =>
              have h_or_pos3 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                                  (Formula.all_future psi) .universal_target item.famIdx t' h_pos_seed1
              cases h_or_pos3 with
              | inl h_pos_orig =>
                -- t' had position in orig, t' > item.timeIdx, so t' ∈ futureTimes
                have h_t'_in_futureTimes : t' ∈ futureTimes := by
                  unfold getFutureTimes
                  simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq]
                  unfold ModelSeed.hasPosition at h_pos_seed1
                  simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h_pos_seed1
                  obtain ⟨entry, h_mem, h_fam, h_time⟩ := h_pos_seed1
                  use entry
                  have h_t'_ne : t' ≠ item.timeIdx := by omega
                  unfold ModelSeed.addFormula at h_mem ⊢
                  cases h_find1 : seed1.entries.findIdx? (fun e => e.familyIdx == item.famIdx && e.timeIdx == item.timeIdx) with
                  | some idx1 =>
                    simp only [h_find1]
                    have h_idx1_spec := List.findIdx?_eq_some_iff_getElem.mp h_find1
                    by_cases h_eq_entry : entry = seed1.entries[h_idx1_spec.1]
                    · simp only [Bool.and_eq_true, beq_iff_eq] at h_idx1_spec
                      rw [← h_time, h_eq_entry] at h_t'_ne
                      exact absurd h_idx1_spec.2.1.2 h_t'_ne
                    · have h_mem_mod := List.mem_modify_iff h_idx1_spec.1
                      rw [h_mem_mod]
                      constructor
                      · constructor
                        · exact Or.inr ⟨h_eq_entry, h_mem⟩
                        · exact h_fam
                      · exact ⟨h_t'_gt, h_time.symm⟩
                  | none =>
                    simp only [h_find1]
                    constructor
                    · constructor
                      · exact List.mem_append_left _ h_mem
                      · exact h_fam
                    · exact ⟨h_t'_gt, h_time.symm⟩
                exact foldl_compound_future_puts_psi_in_all psi item.famIdx futureTimes seed2 t' h_t'_in_futureTimes
              | inr h_new_pos =>
                obtain ⟨_, ht'⟩ := h_new_pos
                omega
            | inr h_new_pos =>
              obtain ⟨_, ht'⟩ := h_new_pos
              omega
          | inr h_new_pos =>
            obtain ⟨_, h_t'_in⟩ := h_new_pos
            exact foldl_compound_future_puts_psi_in_all psi item.famIdx futureTimes seed2 t' h_t'_in
    · -- H theta closure
      intro f t theta h_H
      -- Trace H theta back to orig
      have h_or := mem_getFormulas_after_foldl_compound_future psi (Formula.all_past theta) item.famIdx
                     futureTimes seed2 f t h_H
      have h_in_seed2 : Formula.all_past theta ∈ seed2.getFormulas f t := by
        cases h_or with
        | inl h => exact h
        | inr h =>
          cases h with
          | inl h_is_psi =>
            obtain ⟨h_eq, _, _⟩ := h_is_psi
            exact absurd h_eq.symm Formula.noConfusion
          | inr h_is_gpsi =>
            obtain ⟨h_eq, _, _⟩ := h_is_gpsi
            exact absurd h_eq.symm Formula.noConfusion
      have h_or2 := mem_getFormulas_after_addFormula seed1 item.famIdx item.timeIdx psi
                      (Formula.all_past theta) .universal_target f t h_in_seed2
      have h_in_seed1 : Formula.all_past theta ∈ seed1.getFormulas f t := by
        cases h_or2 with
        | inl h => exact h
        | inr h => exact absurd h.1.symm Formula.noConfusion
      have h_or3 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.all_future psi) (Formula.all_past theta) .universal_target f t h_in_seed1
      have h_in_orig : Formula.all_past theta ∈ state.seed.getFormulas f t := by
        cases h_or3 with
        | inl h => exact h
        | inr h => exact absurd h.1.symm Formula.noConfusion
      cases h_inv.2.2 f t theta h_in_orig with
      | inl h_closed =>
        left
        intro t' h_lt h_pos'
        have h_or_pos := foldl_compound_future_hasPosition_backward psi item.famIdx futureTimes seed2 f t' h_pos'
        cases h_or_pos with
        | inl h_pos_seed2 =>
          have h_or_pos2 := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target f t' h_pos_seed2
          cases h_or_pos2 with
          | inl h_pos_seed1 =>
            have h_or_pos3 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                                (Formula.all_future psi) .universal_target f t' h_pos_seed1
            cases h_or_pos3 with
            | inl h_pos_orig =>
              have h_theta_orig := h_closed t' h_lt h_pos_orig
              have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f t' theta
                                      (Formula.all_future psi) .universal_target h_theta_orig
              have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 f t' theta psi .universal_target h_theta_seed1
              exact foldl_compound_future_preserves_mem psi theta item.famIdx futureTimes seed2 f t' h_theta_seed2
            | inr h_new_pos =>
              obtain ⟨hf', ht'⟩ := h_new_pos
              subst hf' ht'
              by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
              · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
                have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                        (Formula.all_future psi) .universal_target h_theta_orig
                have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx item.timeIdx theta psi .universal_target h_theta_seed1
                exact foldl_compound_future_preserves_mem psi theta item.famIdx futureTimes seed2 item.famIdx item.timeIdx h_theta_seed2
              · exact absurd h_item_pos h_old_pos
          | inr h_new_pos =>
            obtain ⟨hf', ht'⟩ := h_new_pos
            subst hf' ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
              have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                      (Formula.all_future psi) .universal_target h_theta_orig
              have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx item.timeIdx theta psi .universal_target h_theta_seed1
              exact foldl_compound_future_preserves_mem psi theta item.famIdx futureTimes seed2 item.famIdx item.timeIdx h_theta_seed2
            · exact absurd h_item_pos h_old_pos
        | inr h_new_pos =>
          obtain ⟨hf', h_t'_in⟩ := h_new_pos
          subst hf'
          -- New position at (item.famIdx, t') where t' ∈ futureTimes, so t' > item.timeIdx
          have h_t'_gt : t' > item.timeIdx := by
            unfold getFutureTimes at h_t'_in
            simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t'_in
            obtain ⟨_, ⟨_, h_gt⟩, _⟩ := h_t'_in
            exact h_gt
          have h_pos_seed2 : seed2.hasPosition item.famIdx t' := by
            unfold getFutureTimes at h_t'_in
            simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t'_in
            obtain ⟨entry, ⟨h_filt, _⟩, h_teq⟩ := h_t'_in
            subst h_teq
            unfold ModelSeed.hasPosition
            simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq]
            use entry
            simp only [List.mem_filter, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h_filt
            exact ⟨h_filt.1, h_filt.2, rfl⟩
          have h_pos_seed1 : seed1.hasPosition item.famIdx t' := by
            have h := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target item.famIdx t' h_pos_seed2
            cases h with
            | inl h => exact h
            | inr h => omega
          have h_pos_orig : state.seed.hasPosition item.famIdx t' := by
            have h := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx (Formula.all_future psi) .universal_target item.famIdx t' h_pos_seed1
            cases h with
            | inl h => exact h
            | inr h => omega
          have h_theta_orig := h_closed t' h_lt h_pos_orig
          have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx t' theta
                                  (Formula.all_future psi) .universal_target h_theta_orig
          have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx t' theta psi .universal_target h_theta_seed1
          exact foldl_compound_future_preserves_mem psi theta item.famIdx futureTimes seed2 item.famIdx t' h_theta_seed2
      | inr h_pending =>
        right
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        use w
        constructor
        · exact List.mem_append_left _ hw_in
        · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
  | .futureNegative psi =>
    -- futureNegative case: adds neg(G psi) to item position, creates new time with neg psi
    -- processWorkItem for futureNegative:
    --   seed1 := state.seed.addFormula item.famIdx item.timeIdx (neg(G psi))
    --   newTime := seed1.freshFutureTime item.famIdx item.timeIdx
    --   seed2 := seed1.createNewTime item.famIdx newTime (neg psi)
    --   newWork := [⟨neg psi, item.famIdx, newTime⟩]
    -- Neither neg(G psi) nor neg psi is a Box/G/H formula
    simp only [processWorkItem, h_class] at h_proc
    simp only [Prod.mk.injEq] at h_proc
    obtain ⟨h_newWork, h_state'⟩ := h_proc
    subst h_newWork h_state'
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.neg (Formula.all_future psi)) .universal_target
    constructor
    · -- Box theta closure
      intro f t theta h_box
      -- Trace back: createNewTime adds neg psi, addFormula adds neg(G psi) - neither is Box
      have h_or1 := mem_getFormulas_after_createNewTime seed1 item.famIdx
                      (seed1.freshFutureTime item.famIdx item.timeIdx) (Formula.neg psi)
                      (Formula.box theta) f t h_box
      have h_in_seed1 : Formula.box theta ∈ seed1.getFormulas f t := by
        cases h_or1 with
        | inl h => exact h
        | inr h => exact absurd h.1 Formula.noConfusion
      have h_or2 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.neg (Formula.all_future psi)) (Formula.box theta) .universal_target f t h_in_seed1
      have h_in_orig : Formula.box theta ∈ state.seed.getFormulas f t := by
        cases h_or2 with
        | inl h => exact h
        | inr h => unfold Formula.neg at h; exact absurd h.1 Formula.noConfusion
      cases h_inv.1 f t theta h_in_orig with
      | inl h_closed =>
        left
        intro f' h_pos'
        have h_or_pos := createNewTime_preserves_hasPosition seed1 item.famIdx
                           (seed1.freshFutureTime item.famIdx item.timeIdx) (Formula.neg psi) f' t h_pos'
        have h_or_pos2 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                            (Formula.neg (Formula.all_future psi)) .universal_target f' t h_or_pos
        cases h_or_pos2 with
        | inl h_pos_orig =>
          have h_theta_orig := h_closed f' h_pos_orig
          have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f' t theta
                                  (Formula.neg (Formula.all_future psi)) .universal_target h_theta_orig
          -- Need to prove f' ≠ item.famIdx ∨ t ≠ freshFutureTime
          have h_diff : f' ≠ item.famIdx ∨ t ≠ seed1.freshFutureTime item.famIdx item.timeIdx := by
            by_cases h_fam : f' = item.famIdx
            · -- f' = item.famIdx, so we prove t ≠ freshFutureTime
              right
              subst h_fam
              -- h_pos_orig : state.seed.hasPosition item.famIdx t
              -- addFormula preserves hasPosition
              have h_pos_seed1 := addFormula_preserves_hasPosition state.seed item.famIdx item.timeIdx
                                    (Formula.neg (Formula.all_future psi)) .universal_target item.famIdx t h_pos_orig
              -- By our helper lemma, t < freshFutureTime
              have h_lt := ModelSeed.hasPosition_time_lt_freshFutureTime seed1 item.famIdx t item.timeIdx h_pos_seed1
              omega
            · -- f' ≠ item.famIdx
              left
              exact h_fam
          exact createNewTime_preserves_mem_getFormulas seed1 item.famIdx
                  (seed1.freshFutureTime item.famIdx item.timeIdx) theta (Formula.neg psi) f' t h_theta_seed1
                  h_diff
        | inr h_new_pos =>
          obtain ⟨hf', ht'⟩ := h_new_pos
          subst hf' ht'
          by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
          · have h_theta_orig := h_closed item.famIdx h_old_pos
            have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                    (Formula.neg (Formula.all_future psi)) .universal_target h_theta_orig
            exact createNewTime_preserves_mem_getFormulas seed1 item.famIdx
                    (seed1.freshFutureTime item.famIdx item.timeIdx) theta (Formula.neg psi) item.famIdx item.timeIdx h_theta_seed1
                    (Or.inr (fun h => by
                      -- item.timeIdx ≠ freshFutureTime because freshFutureTime > item.timeIdx
                      have h_fresh := ModelSeed.freshFutureTime_gt seed1 item.famIdx item.timeIdx
                      omega))
          · exact absurd h_item_pos h_old_pos
      | inr h_pending =>
        right
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        use w
        constructor
        · exact List.mem_append_left _ hw_in
        · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
    constructor
    · -- G theta closure
      intro f t theta h_G
      have h_or1 := mem_getFormulas_after_createNewTime seed1 item.famIdx
                      (seed1.freshFutureTime item.famIdx item.timeIdx) (Formula.neg psi)
                      (Formula.all_future theta) f t h_G
      have h_in_seed1 : Formula.all_future theta ∈ seed1.getFormulas f t := by
        cases h_or1 with
        | inl h => exact h
        | inr h => exact absurd h.1 Formula.noConfusion
      have h_or2 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.neg (Formula.all_future psi)) (Formula.all_future theta) .universal_target f t h_in_seed1
      have h_in_orig : Formula.all_future theta ∈ state.seed.getFormulas f t := by
        cases h_or2 with
        | inl h => exact h
        | inr h => unfold Formula.neg at h; exact absurd h.1 Formula.noConfusion
      cases h_inv.2.1 f t theta h_in_orig with
      | inl h_closed =>
        left
        intro t' h_lt h_pos'
        have h_or_pos := createNewTime_preserves_hasPosition seed1 item.famIdx
                           (seed1.freshFutureTime item.famIdx item.timeIdx) (Formula.neg psi) f t' h_pos'
        have h_or_pos2 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                            (Formula.neg (Formula.all_future psi)) .universal_target f t' h_or_pos
        cases h_or_pos2 with
        | inl h_pos_orig =>
          have h_theta_orig := h_closed t' h_lt h_pos_orig
          have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f t' theta
                                  (Formula.neg (Formula.all_future psi)) .universal_target h_theta_orig
          -- Need to prove f ≠ item.famIdx ∨ t' ≠ freshFutureTime
          have h_diff : f ≠ item.famIdx ∨ t' ≠ seed1.freshFutureTime item.famIdx item.timeIdx := by
            by_cases h_fam : f = item.famIdx
            · right
              subst h_fam
              have h_pos_seed1 := addFormula_preserves_hasPosition state.seed item.famIdx item.timeIdx
                                    (Formula.neg (Formula.all_future psi)) .universal_target item.famIdx t' h_pos_orig
              have h_lt' := ModelSeed.hasPosition_time_lt_freshFutureTime seed1 item.famIdx t' item.timeIdx h_pos_seed1
              omega
            · left; exact h_fam
          exact createNewTime_preserves_mem_getFormulas seed1 item.famIdx
                  (seed1.freshFutureTime item.famIdx item.timeIdx) theta (Formula.neg psi) f t' h_theta_seed1
                  h_diff
        | inr h_new_pos =>
          obtain ⟨hf', ht'⟩ := h_new_pos
          subst hf' ht'
          by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
          · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
            have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                    (Formula.neg (Formula.all_future psi)) .universal_target h_theta_orig
            exact createNewTime_preserves_mem_getFormulas seed1 item.famIdx
                    (seed1.freshFutureTime item.famIdx item.timeIdx) theta (Formula.neg psi) item.famIdx item.timeIdx h_theta_seed1
                    (Or.inr (fun h => by
                      have h_fresh := ModelSeed.freshFutureTime_gt seed1 item.famIdx item.timeIdx
                      omega))
          · exact absurd h_item_pos h_old_pos
      | inr h_pending =>
        right
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        use w
        constructor
        · exact List.mem_append_left _ hw_in
        · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
    · -- H theta closure
      intro f t theta h_H
      have h_or1 := mem_getFormulas_after_createNewTime seed1 item.famIdx
                      (seed1.freshFutureTime item.famIdx item.timeIdx) (Formula.neg psi)
                      (Formula.all_past theta) f t h_H
      have h_in_seed1 : Formula.all_past theta ∈ seed1.getFormulas f t := by
        cases h_or1 with
        | inl h => exact h
        | inr h => exact absurd h.1 Formula.noConfusion
      have h_or2 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.neg (Formula.all_future psi)) (Formula.all_past theta) .universal_target f t h_in_seed1
      have h_in_orig : Formula.all_past theta ∈ state.seed.getFormulas f t := by
        cases h_or2 with
        | inl h => exact h
        | inr h => unfold Formula.neg at h; exact absurd h.1 Formula.noConfusion
      cases h_inv.2.2 f t theta h_in_orig with
      | inl h_closed =>
        left
        intro t' h_lt h_pos'
        have h_or_pos := createNewTime_preserves_hasPosition seed1 item.famIdx
                           (seed1.freshFutureTime item.famIdx item.timeIdx) (Formula.neg psi) f t' h_pos'
        have h_or_pos2 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                            (Formula.neg (Formula.all_future psi)) .universal_target f t' h_or_pos
        cases h_or_pos2 with
        | inl h_pos_orig =>
          have h_theta_orig := h_closed t' h_lt h_pos_orig
          have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f t' theta
                                  (Formula.neg (Formula.all_future psi)) .universal_target h_theta_orig
          -- Need to prove f ≠ item.famIdx ∨ t' ≠ freshFutureTime
          have h_diff : f ≠ item.famIdx ∨ t' ≠ seed1.freshFutureTime item.famIdx item.timeIdx := by
            by_cases h_fam : f = item.famIdx
            · right
              subst h_fam
              have h_pos_seed1 := addFormula_preserves_hasPosition state.seed item.famIdx item.timeIdx
                                    (Formula.neg (Formula.all_future psi)) .universal_target item.famIdx t' h_pos_orig
              have h_lt' := ModelSeed.hasPosition_time_lt_freshFutureTime seed1 item.famIdx t' item.timeIdx h_pos_seed1
              omega
            · left; exact h_fam
          exact createNewTime_preserves_mem_getFormulas seed1 item.famIdx
                  (seed1.freshFutureTime item.famIdx item.timeIdx) theta (Formula.neg psi) f t' h_theta_seed1
                  h_diff
        | inr h_new_pos =>
          obtain ⟨hf', ht'⟩ := h_new_pos
          subst hf' ht'
          by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
          · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
            have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                    (Formula.neg (Formula.all_future psi)) .universal_target h_theta_orig
            exact createNewTime_preserves_mem_getFormulas seed1 item.famIdx
                    (seed1.freshFutureTime item.famIdx item.timeIdx) theta (Formula.neg psi) item.famIdx item.timeIdx h_theta_seed1
                    (Or.inr (fun h => by
                      have h_fresh := ModelSeed.freshFutureTime_gt seed1 item.famIdx item.timeIdx
                      omega))
          · exact absurd h_item_pos h_old_pos
      | inr h_pending =>
        right
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        use w
        constructor
        · exact List.mem_append_left _ hw_in
        · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
  | .pastPositive psi =>
    -- pastPositive case: adds H psi, psi to current; adds psi, H psi to ALL past times
    -- processWorkItem for pastPositive:
    --   seed1 := state.seed.addFormula item.famIdx item.timeIdx (H psi)
    --   seed2 := seed1.addFormula item.famIdx item.timeIdx psi
    --   pastTimes := getPastTimes seed2 item.famIdx item.timeIdx
    --   seed3 := foldl (adds psi and H psi at each past time) seed2
    -- The final seed has H psi at current time AND all past times
    simp only [processWorkItem, h_class] at h_proc
    simp only [Prod.mk.injEq] at h_proc
    obtain ⟨h_newWork, h_state'⟩ := h_proc
    subst h_newWork h_state'
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.all_past psi) .universal_target
    let seed2 := seed1.addFormula item.famIdx item.timeIdx psi .universal_target
    let pastTimes := getPastTimes seed2 item.famIdx item.timeIdx
    constructor
    · -- Box theta closure
      intro f t theta h_box
      have h_or := mem_getFormulas_after_foldl_compound_past psi (Formula.box theta) item.famIdx
                     pastTimes seed2 f t h_box
      have h_in_seed2 : Formula.box theta ∈ seed2.getFormulas f t := by
        cases h_or with
        | inl h_old => exact h_old
        | inr h_added =>
          cases h_added with
          | inl h_is_psi =>
            obtain ⟨h_eq, _, _⟩ := h_is_psi
            exact absurd h_eq.symm Formula.noConfusion
          | inr h_is_hpsi =>
            obtain ⟨h_eq, _, _⟩ := h_is_hpsi
            exact absurd h_eq.symm Formula.noConfusion
      have h_or2 := mem_getFormulas_after_addFormula seed1 item.famIdx item.timeIdx psi
                      (Formula.box theta) .universal_target f t h_in_seed2
      have h_in_seed1 : Formula.box theta ∈ seed1.getFormulas f t := by
        cases h_or2 with
        | inl h => exact h
        | inr h => exact absurd h.1.symm Formula.noConfusion
      have h_or3 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.all_past psi) (Formula.box theta) .universal_target f t h_in_seed1
      have h_in_orig : Formula.box theta ∈ state.seed.getFormulas f t := by
        cases h_or3 with
        | inl h => exact h
        | inr h => exact absurd h.1.symm Formula.noConfusion
      cases h_inv.1 f t theta h_in_orig with
      | inl h_closed =>
        left
        intro f' h_pos'
        have h_or_pos := foldl_compound_past_hasPosition_backward psi item.famIdx pastTimes seed2 f' t h_pos'
        cases h_or_pos with
        | inl h_pos_seed2 =>
          have h_or_pos2 := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target f' t h_pos_seed2
          cases h_or_pos2 with
          | inl h_pos_seed1 =>
            have h_or_pos3 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                                (Formula.all_past psi) .universal_target f' t h_pos_seed1
            cases h_or_pos3 with
            | inl h_pos_orig =>
              have h_theta_orig := h_closed f' h_pos_orig
              have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f' t theta
                                      (Formula.all_past psi) .universal_target h_theta_orig
              have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 f' t theta psi .universal_target h_theta_seed1
              exact foldl_compound_past_preserves_mem psi theta item.famIdx pastTimes seed2 f' t h_theta_seed2
            | inr h_new_pos =>
              obtain ⟨hf', ht'⟩ := h_new_pos
              subst hf' ht'
              by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
              · have h_theta_orig := h_closed item.famIdx h_old_pos
                have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                        (Formula.all_past psi) .universal_target h_theta_orig
                have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx item.timeIdx theta psi .universal_target h_theta_seed1
                exact foldl_compound_past_preserves_mem psi theta item.famIdx pastTimes seed2 item.famIdx item.timeIdx h_theta_seed2
              · exact absurd h_item_pos h_old_pos
          | inr h_new_pos =>
            obtain ⟨hf', ht'⟩ := h_new_pos
            subst hf' ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · have h_theta_orig := h_closed item.famIdx h_old_pos
              have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                      (Formula.all_past psi) .universal_target h_theta_orig
              have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx item.timeIdx theta psi .universal_target h_theta_seed1
              exact foldl_compound_past_preserves_mem psi theta item.famIdx pastTimes seed2 item.famIdx item.timeIdx h_theta_seed2
            · exact absurd h_item_pos h_old_pos
        | inr h_new_pos =>
          obtain ⟨hf', h_t_in⟩ := h_new_pos
          subst hf'
          have h_pos_seed2 : seed2.hasPosition item.famIdx t := by
            unfold getPastTimes at h_t_in
            simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t_in
            obtain ⟨entry, ⟨h_filt, h_lt⟩, h_teq⟩ := h_t_in
            subst h_teq
            unfold ModelSeed.hasPosition
            simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq]
            use entry
            simp only [List.mem_filter, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h_filt
            exact ⟨h_filt.1, h_filt.2, rfl⟩
          have h_t_lt : t < item.timeIdx := by
            unfold getPastTimes at h_t_in
            simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t_in
            obtain ⟨entry, ⟨_, h_lt⟩, h_teq⟩ := h_t_in
            omega
          have h_pos_seed1 : seed1.hasPosition item.famIdx t := by
            have h := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target item.famIdx t h_pos_seed2
            cases h with
            | inl h => exact h
            | inr h => omega
          have h_pos_orig : state.seed.hasPosition item.famIdx t := by
            have h := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx (Formula.all_past psi) .universal_target item.famIdx t h_pos_seed1
            cases h with
            | inl h => exact h
            | inr h => omega
          have h_theta_orig := h_closed item.famIdx h_pos_orig
          have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx t theta
                                  (Formula.all_past psi) .universal_target h_theta_orig
          have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx t theta psi .universal_target h_theta_seed1
          exact foldl_compound_past_preserves_mem psi theta item.famIdx pastTimes seed2 item.famIdx t h_theta_seed2
      | inr h_pending =>
        right
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        use w
        constructor
        · exact List.mem_append_left _ hw_in
        · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
    constructor
    · -- G theta closure
      intro f t theta h_G
      have h_or := mem_getFormulas_after_foldl_compound_past psi (Formula.all_future theta) item.famIdx
                     pastTimes seed2 f t h_G
      have h_in_seed2 : Formula.all_future theta ∈ seed2.getFormulas f t := by
        cases h_or with
        | inl h => exact h
        | inr h =>
          cases h with
          | inl h_is_psi =>
            obtain ⟨h_eq, _, _⟩ := h_is_psi
            exact absurd h_eq.symm Formula.noConfusion
          | inr h_is_hpsi =>
            obtain ⟨h_eq, _, _⟩ := h_is_hpsi
            exact absurd h_eq.symm Formula.noConfusion
      have h_or2 := mem_getFormulas_after_addFormula seed1 item.famIdx item.timeIdx psi
                      (Formula.all_future theta) .universal_target f t h_in_seed2
      have h_in_seed1 : Formula.all_future theta ∈ seed1.getFormulas f t := by
        cases h_or2 with
        | inl h => exact h
        | inr h => exact absurd h.1.symm Formula.noConfusion
      have h_or3 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.all_past psi) (Formula.all_future theta) .universal_target f t h_in_seed1
      have h_in_orig : Formula.all_future theta ∈ state.seed.getFormulas f t := by
        cases h_or3 with
        | inl h => exact h
        | inr h => exact absurd h.1.symm Formula.noConfusion
      cases h_inv.2.1 f t theta h_in_orig with
      | inl h_closed =>
        left
        intro t' h_lt h_pos'
        have h_or_pos := foldl_compound_past_hasPosition_backward psi item.famIdx pastTimes seed2 f t' h_pos'
        cases h_or_pos with
        | inl h_pos_seed2 =>
          have h_or_pos2 := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target f t' h_pos_seed2
          cases h_or_pos2 with
          | inl h_pos_seed1 =>
            have h_or_pos3 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                                (Formula.all_past psi) .universal_target f t' h_pos_seed1
            cases h_or_pos3 with
            | inl h_pos_orig =>
              have h_theta_orig := h_closed t' h_lt h_pos_orig
              have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f t' theta
                                      (Formula.all_past psi) .universal_target h_theta_orig
              have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 f t' theta psi .universal_target h_theta_seed1
              exact foldl_compound_past_preserves_mem psi theta item.famIdx pastTimes seed2 f t' h_theta_seed2
            | inr h_new_pos =>
              obtain ⟨hf', ht'⟩ := h_new_pos
              subst hf' ht'
              by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
              · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
                have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                        (Formula.all_past psi) .universal_target h_theta_orig
                have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx item.timeIdx theta psi .universal_target h_theta_seed1
                exact foldl_compound_past_preserves_mem psi theta item.famIdx pastTimes seed2 item.famIdx item.timeIdx h_theta_seed2
              · exact absurd h_item_pos h_old_pos
          | inr h_new_pos =>
            obtain ⟨hf', ht'⟩ := h_new_pos
            subst hf' ht'
            by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
            · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
              have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                      (Formula.all_past psi) .universal_target h_theta_orig
              have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx item.timeIdx theta psi .universal_target h_theta_seed1
              exact foldl_compound_past_preserves_mem psi theta item.famIdx pastTimes seed2 item.famIdx item.timeIdx h_theta_seed2
            · exact absurd h_item_pos h_old_pos
        | inr h_new_pos =>
          obtain ⟨hf', h_t'_in⟩ := h_new_pos
          subst hf'
          have h_t'_lt : t' < item.timeIdx := by
            unfold getPastTimes at h_t'_in
            simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t'_in
            obtain ⟨_, ⟨_, h_lt⟩, _⟩ := h_t'_in
            exact h_lt
          have h_pos_seed2 : seed2.hasPosition item.famIdx t' := by
            unfold getPastTimes at h_t'_in
            simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t'_in
            obtain ⟨entry, ⟨h_filt, _⟩, h_teq⟩ := h_t'_in
            subst h_teq
            unfold ModelSeed.hasPosition
            simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq]
            use entry
            simp only [List.mem_filter, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h_filt
            exact ⟨h_filt.1, h_filt.2, rfl⟩
          have h_pos_seed1 : seed1.hasPosition item.famIdx t' := by
            have h := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target item.famIdx t' h_pos_seed2
            cases h with
            | inl h => exact h
            | inr h => omega
          have h_pos_orig : state.seed.hasPosition item.famIdx t' := by
            have h := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx (Formula.all_past psi) .universal_target item.famIdx t' h_pos_seed1
            cases h with
            | inl h => exact h
            | inr h => omega
          have h_theta_orig := h_closed t' h_lt h_pos_orig
          have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx t' theta
                                  (Formula.all_past psi) .universal_target h_theta_orig
          have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx t' theta psi .universal_target h_theta_seed1
          exact foldl_compound_past_preserves_mem psi theta item.famIdx pastTimes seed2 item.famIdx t' h_theta_seed2
      | inr h_pending =>
        right
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        use w
        constructor
        · exact List.mem_append_left _ hw_in
        · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
    · -- H theta closure
      intro f t theta h_H
      have h_or := mem_getFormulas_after_foldl_compound_past psi (Formula.all_past theta) item.famIdx
                     pastTimes seed2 f t h_H
      cases h_or with
      | inl h_in_seed2 =>
        have h_or2 := mem_getFormulas_after_addFormula seed1 item.famIdx item.timeIdx psi
                        (Formula.all_past theta) .universal_target f t h_in_seed2
        have h_in_seed1 : Formula.all_past theta ∈ seed1.getFormulas f t := by
          cases h_or2 with
          | inl h => exact h
          | inr h => exact absurd h.1.symm Formula.noConfusion
        have h_or3 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                        (Formula.all_past psi) (Formula.all_past theta) .universal_target f t h_in_seed1
        cases h_or3 with
        | inl h_in_orig =>
          cases h_inv.2.2 f t theta h_in_orig with
          | inl h_closed =>
            left
            intro t' h_lt h_pos'
            have h_or_pos := foldl_compound_past_hasPosition_backward psi item.famIdx pastTimes seed2 f t' h_pos'
            cases h_or_pos with
            | inl h_pos_seed2 =>
              have h_or_pos2 := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target f t' h_pos_seed2
              cases h_or_pos2 with
              | inl h_pos_seed1 =>
                have h_or_pos3 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                                    (Formula.all_past psi) .universal_target f t' h_pos_seed1
                cases h_or_pos3 with
                | inl h_pos_orig =>
                  have h_theta_orig := h_closed t' h_lt h_pos_orig
                  have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f t' theta
                                          (Formula.all_past psi) .universal_target h_theta_orig
                  have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 f t' theta psi .universal_target h_theta_seed1
                  exact foldl_compound_past_preserves_mem psi theta item.famIdx pastTimes seed2 f t' h_theta_seed2
                | inr h_new_pos =>
                  obtain ⟨hf', ht'⟩ := h_new_pos
                  subst hf' ht'
                  by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
                  · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
                    have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                            (Formula.all_past psi) .universal_target h_theta_orig
                    have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx item.timeIdx theta psi .universal_target h_theta_seed1
                    exact foldl_compound_past_preserves_mem psi theta item.famIdx pastTimes seed2 item.famIdx item.timeIdx h_theta_seed2
                  · exact absurd h_item_pos h_old_pos
              | inr h_new_pos =>
                obtain ⟨hf', ht'⟩ := h_new_pos
                subst hf' ht'
                by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
                · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
                  have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                          (Formula.all_past psi) .universal_target h_theta_orig
                  have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx item.timeIdx theta psi .universal_target h_theta_seed1
                  exact foldl_compound_past_preserves_mem psi theta item.famIdx pastTimes seed2 item.famIdx item.timeIdx h_theta_seed2
                · exact absurd h_item_pos h_old_pos
            | inr h_new_pos =>
              obtain ⟨hf', h_t'_in⟩ := h_new_pos
              subst hf'
              have h_t'_lt : t' < item.timeIdx := by
                unfold getPastTimes at h_t'_in
                simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t'_in
                obtain ⟨_, ⟨_, h_lt⟩, _⟩ := h_t'_in
                exact h_lt
              have h_pos_seed2 : seed2.hasPosition item.famIdx t' := by
                unfold getPastTimes at h_t'_in
                simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t'_in
                obtain ⟨entry, ⟨h_filt, _⟩, h_teq⟩ := h_t'_in
                subst h_teq
                unfold ModelSeed.hasPosition
                simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq]
                use entry
                simp only [List.mem_filter, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h_filt
                exact ⟨h_filt.1, h_filt.2, rfl⟩
              have h_pos_seed1 : seed1.hasPosition item.famIdx t' := by
                have h := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target item.famIdx t' h_pos_seed2
                cases h with
                | inl h => exact h
                | inr h => omega
              have h_pos_orig : state.seed.hasPosition item.famIdx t' := by
                have h := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx (Formula.all_past psi) .universal_target item.famIdx t' h_pos_seed1
                cases h with
                | inl h => exact h
                | inr h => omega
              have h_theta_orig := h_closed t' h_lt h_pos_orig
              have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx t' theta
                                      (Formula.all_past psi) .universal_target h_theta_orig
              have h_theta_seed2 := addFormula_preserves_mem_getFormulas_same seed1 item.famIdx t' theta psi .universal_target h_theta_seed1
              exact foldl_compound_past_preserves_mem psi theta item.famIdx pastTimes seed2 item.famIdx t' h_theta_seed2
          | inr h_pending =>
            right
            obtain ⟨w, hw_in, hw_eq⟩ := h_pending
            use w
            constructor
            · exact List.mem_append_left _ hw_in
            · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
        | inr h_is_hpsi =>
          -- H theta = H psi (newly added)
          obtain ⟨h_formula_eq, hf, ht⟩ := h_is_hpsi
          have h_theta_eq : theta = psi := Formula.all_past.inj h_formula_eq
          subst h_theta_eq hf ht
          -- H psi was just added. We need to show psi is at all past times t' < t
          -- where t = item.timeIdx.
          left
          intro t' h_lt h_pos'
          have h_or_pos := foldl_compound_past_hasPosition_backward psi item.famIdx pastTimes seed2 item.famIdx t' h_pos'
          cases h_or_pos with
          | inl h_pos_seed2 =>
            have h_or_pos2 := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target item.famIdx t' h_pos_seed2
            cases h_or_pos2 with
            | inl h_pos_seed1 =>
              have h_or_pos3 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                                  (Formula.all_past psi) .universal_target item.famIdx t' h_pos_seed1
              cases h_or_pos3 with
              | inl h_pos_orig =>
                have h_t'_in_pastTimes : t' ∈ pastTimes := by
                  unfold getPastTimes
                  simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq]
                  unfold ModelSeed.hasPosition at h_pos_seed1
                  simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h_pos_seed1
                  obtain ⟨entry, h_mem, h_fam, h_time⟩ := h_pos_seed1
                  use entry
                  have h_t'_ne : t' ≠ item.timeIdx := by omega
                  unfold ModelSeed.addFormula at h_mem ⊢
                  cases h_find1 : seed1.entries.findIdx? (fun e => e.familyIdx == item.famIdx && e.timeIdx == item.timeIdx) with
                  | some idx1 =>
                    simp only [h_find1]
                    have h_idx1_spec := List.findIdx?_eq_some_iff_getElem.mp h_find1
                    by_cases h_eq_entry : entry = seed1.entries[h_idx1_spec.1]
                    · simp only [Bool.and_eq_true, beq_iff_eq] at h_idx1_spec
                      rw [← h_time, h_eq_entry] at h_t'_ne
                      exact absurd h_idx1_spec.2.1.2 h_t'_ne
                    · have h_mem_mod := List.mem_modify_iff h_idx1_spec.1
                      rw [h_mem_mod]
                      constructor
                      · constructor
                        · exact Or.inr ⟨h_eq_entry, h_mem⟩
                        · exact h_fam
                      · exact ⟨h_lt, h_time.symm⟩
                  | none =>
                    simp only [h_find1]
                    constructor
                    · constructor
                      · exact List.mem_append_left _ h_mem
                      · exact h_fam
                    · exact ⟨h_lt, h_time.symm⟩
                exact foldl_compound_past_puts_psi_in_all psi item.famIdx pastTimes seed2 t' h_t'_in_pastTimes
              | inr h_new_pos =>
                obtain ⟨_, ht'⟩ := h_new_pos
                omega
            | inr h_new_pos =>
              obtain ⟨_, ht'⟩ := h_new_pos
              omega
          | inr h_new_pos =>
            obtain ⟨_, h_t'_in⟩ := h_new_pos
            exact foldl_compound_past_puts_psi_in_all psi item.famIdx pastTimes seed2 t' h_t'_in
      | inr h_added =>
        cases h_added with
        | inl h_is_psi =>
          obtain ⟨h_eq, _, _⟩ := h_is_psi
          exact absurd h_eq.symm Formula.noConfusion
        | inr h_is_hpsi =>
          obtain ⟨h_eq, h_t_in, hf⟩ := h_is_hpsi
          have h_theta_eq : theta = psi := Formula.all_past.inj h_eq
          subst h_theta_eq hf
          left
          intro t' h_lt_t h_pos'
          have h_t_lt : t < item.timeIdx := by
            unfold getPastTimes at h_t_in
            simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq] at h_t_in
            obtain ⟨_, ⟨_, h_lt⟩, _⟩ := h_t_in
            exact h_lt
          have h_t'_lt : t' < item.timeIdx := by omega
          have h_or_pos := foldl_compound_past_hasPosition_backward psi item.famIdx pastTimes seed2 item.famIdx t' h_pos'
          cases h_or_pos with
          | inl h_pos_seed2 =>
            have h_or_pos2 := addFormula_hasPosition_backward seed1 item.famIdx item.timeIdx psi .universal_target item.famIdx t' h_pos_seed2
            cases h_or_pos2 with
            | inl h_pos_seed1 =>
              have h_or_pos3 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                                  (Formula.all_past psi) .universal_target item.famIdx t' h_pos_seed1
              cases h_or_pos3 with
              | inl h_pos_orig =>
                have h_t'_in_pastTimes : t' ∈ pastTimes := by
                  unfold getPastTimes
                  simp only [List.mem_eraseDups, List.mem_map, List.mem_filter, decide_eq_true_eq]
                  unfold ModelSeed.hasPosition at h_pos_seed1
                  simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h_pos_seed1
                  obtain ⟨entry, h_mem, h_fam, h_time⟩ := h_pos_seed1
                  use entry
                  have h_t'_ne : t' ≠ item.timeIdx := by omega
                  unfold ModelSeed.addFormula at h_mem ⊢
                  cases h_find1 : seed1.entries.findIdx? (fun e => e.familyIdx == item.famIdx && e.timeIdx == item.timeIdx) with
                  | some idx1 =>
                    simp only [h_find1]
                    have h_idx1_spec := List.findIdx?_eq_some_iff_getElem.mp h_find1
                    by_cases h_eq_entry : entry = seed1.entries[h_idx1_spec.1]
                    · simp only [Bool.and_eq_true, beq_iff_eq] at h_idx1_spec
                      rw [← h_time, h_eq_entry] at h_t'_ne
                      exact absurd h_idx1_spec.2.1.2 h_t'_ne
                    · have h_mem_mod := List.mem_modify_iff h_idx1_spec.1
                      rw [h_mem_mod]
                      constructor
                      · constructor
                        · exact Or.inr ⟨h_eq_entry, h_mem⟩
                        · exact h_fam
                      · exact ⟨h_t'_lt, h_time.symm⟩
                  | none =>
                    simp only [h_find1]
                    constructor
                    · constructor
                      · exact List.mem_append_left _ h_mem
                      · exact h_fam
                    · exact ⟨h_t'_lt, h_time.symm⟩
                exact foldl_compound_past_puts_psi_in_all psi item.famIdx pastTimes seed2 t' h_t'_in_pastTimes
              | inr h_new_pos =>
                obtain ⟨_, ht'⟩ := h_new_pos
                omega
            | inr h_new_pos =>
              obtain ⟨_, ht'⟩ := h_new_pos
              omega
          | inr h_new_pos =>
            obtain ⟨_, h_t'_in⟩ := h_new_pos
            exact foldl_compound_past_puts_psi_in_all psi item.famIdx pastTimes seed2 t' h_t'_in
  | .pastNegative psi =>
    -- pastNegative case: adds neg(H psi) to item position, creates new past time with neg psi
    -- processWorkItem for pastNegative:
    --   seed1 := state.seed.addFormula item.famIdx item.timeIdx (neg(H psi))
    --   newTime := seed1.freshPastTime item.famIdx item.timeIdx
    --   seed2 := seed1.createNewTime item.famIdx newTime (neg psi)
    --   newWork := [⟨neg psi, item.famIdx, newTime⟩]
    -- Neither neg(H psi) nor neg psi is a Box/G/H formula
    simp only [processWorkItem, h_class] at h_proc
    simp only [Prod.mk.injEq] at h_proc
    obtain ⟨h_newWork, h_state'⟩ := h_proc
    subst h_newWork h_state'
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.neg (Formula.all_past psi)) .universal_target
    constructor
    · -- Box theta closure
      intro f t theta h_box
      -- Trace back: createNewTime adds neg psi, addFormula adds neg(H psi) - neither is Box
      have h_or1 := mem_getFormulas_after_createNewTime seed1 item.famIdx
                      (seed1.freshPastTime item.famIdx item.timeIdx) (Formula.neg psi)
                      (Formula.box theta) f t h_box
      have h_in_seed1 : Formula.box theta ∈ seed1.getFormulas f t := by
        cases h_or1 with
        | inl h => exact h
        | inr h => exact absurd h.1 Formula.noConfusion
      have h_or2 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.neg (Formula.all_past psi)) (Formula.box theta) .universal_target f t h_in_seed1
      have h_in_orig : Formula.box theta ∈ state.seed.getFormulas f t := by
        cases h_or2 with
        | inl h => exact h
        | inr h => unfold Formula.neg at h; exact absurd h.1 Formula.noConfusion
      cases h_inv.1 f t theta h_in_orig with
      | inl h_closed =>
        left
        intro f' h_pos'
        have h_or_pos := createNewTime_preserves_hasPosition seed1 item.famIdx
                           (seed1.freshPastTime item.famIdx item.timeIdx) (Formula.neg psi) f' t h_pos'
        have h_or_pos2 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                            (Formula.neg (Formula.all_past psi)) .universal_target f' t h_or_pos
        cases h_or_pos2 with
        | inl h_pos_orig =>
          have h_theta_orig := h_closed f' h_pos_orig
          have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f' t theta
                                  (Formula.neg (Formula.all_past psi)) .universal_target h_theta_orig
          -- Need to prove f' ≠ item.famIdx ∨ t ≠ freshPastTime
          have h_diff : f' ≠ item.famIdx ∨ t ≠ seed1.freshPastTime item.famIdx item.timeIdx := by
            by_cases h_fam : f' = item.famIdx
            · -- f' = item.famIdx, so we prove t ≠ freshPastTime
              right
              subst h_fam
              -- h_pos_orig : state.seed.hasPosition item.famIdx t
              -- addFormula preserves hasPosition
              have h_pos_seed1 := addFormula_preserves_hasPosition state.seed item.famIdx item.timeIdx
                                    (Formula.neg (Formula.all_past psi)) .universal_target item.famIdx t h_pos_orig
              -- By our helper lemma, t > freshPastTime
              have h_gt := ModelSeed.hasPosition_time_gt_freshPastTime seed1 item.famIdx t item.timeIdx h_pos_seed1
              omega
            · -- f' ≠ item.famIdx
              left
              exact h_fam
          exact createNewTime_preserves_mem_getFormulas seed1 item.famIdx
                  (seed1.freshPastTime item.famIdx item.timeIdx) theta (Formula.neg psi) f' t h_theta_seed1
                  h_diff
        | inr h_new_pos =>
          obtain ⟨hf', ht'⟩ := h_new_pos
          subst hf' ht'
          by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
          · have h_theta_orig := h_closed item.famIdx h_old_pos
            have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                    (Formula.neg (Formula.all_past psi)) .universal_target h_theta_orig
            exact createNewTime_preserves_mem_getFormulas seed1 item.famIdx
                    (seed1.freshPastTime item.famIdx item.timeIdx) theta (Formula.neg psi) item.famIdx item.timeIdx h_theta_seed1
                    (Or.inr (fun h => by
                      -- item.timeIdx ≠ freshPastTime because freshPastTime < item.timeIdx
                      have h_fresh := ModelSeed.freshPastTime_lt_current seed1 item.famIdx item.timeIdx
                      omega))
          · exact absurd h_item_pos h_old_pos
      | inr h_pending =>
        right
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        use w
        constructor
        · exact List.mem_append_left _ hw_in
        · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
    constructor
    · -- G theta closure
      intro f t theta h_G
      have h_or1 := mem_getFormulas_after_createNewTime seed1 item.famIdx
                      (seed1.freshPastTime item.famIdx item.timeIdx) (Formula.neg psi)
                      (Formula.all_future theta) f t h_G
      have h_in_seed1 : Formula.all_future theta ∈ seed1.getFormulas f t := by
        cases h_or1 with
        | inl h => exact h
        | inr h => exact absurd h.1 Formula.noConfusion
      have h_or2 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.neg (Formula.all_past psi)) (Formula.all_future theta) .universal_target f t h_in_seed1
      have h_in_orig : Formula.all_future theta ∈ state.seed.getFormulas f t := by
        cases h_or2 with
        | inl h => exact h
        | inr h => unfold Formula.neg at h; exact absurd h.1 Formula.noConfusion
      cases h_inv.2.1 f t theta h_in_orig with
      | inl h_closed =>
        left
        intro t' h_lt h_pos'
        have h_or_pos := createNewTime_preserves_hasPosition seed1 item.famIdx
                           (seed1.freshPastTime item.famIdx item.timeIdx) (Formula.neg psi) f t' h_pos'
        have h_or_pos2 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                            (Formula.neg (Formula.all_past psi)) .universal_target f t' h_or_pos
        cases h_or_pos2 with
        | inl h_pos_orig =>
          have h_theta_orig := h_closed t' h_lt h_pos_orig
          have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f t' theta
                                  (Formula.neg (Formula.all_past psi)) .universal_target h_theta_orig
          -- Need to prove f ≠ item.famIdx ∨ t' ≠ freshPastTime
          have h_diff : f ≠ item.famIdx ∨ t' ≠ seed1.freshPastTime item.famIdx item.timeIdx := by
            by_cases h_fam : f = item.famIdx
            · right
              subst h_fam
              have h_pos_seed1 := addFormula_preserves_hasPosition state.seed item.famIdx item.timeIdx
                                    (Formula.neg (Formula.all_past psi)) .universal_target item.famIdx t' h_pos_orig
              have h_gt := ModelSeed.hasPosition_time_gt_freshPastTime seed1 item.famIdx t' item.timeIdx h_pos_seed1
              omega
            · left; exact h_fam
          exact createNewTime_preserves_mem_getFormulas seed1 item.famIdx
                  (seed1.freshPastTime item.famIdx item.timeIdx) theta (Formula.neg psi) f t' h_theta_seed1
                  h_diff
        | inr h_new_pos =>
          obtain ⟨hf', ht'⟩ := h_new_pos
          subst hf' ht'
          by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
          · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
            have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                    (Formula.neg (Formula.all_past psi)) .universal_target h_theta_orig
            exact createNewTime_preserves_mem_getFormulas seed1 item.famIdx
                    (seed1.freshPastTime item.famIdx item.timeIdx) theta (Formula.neg psi) item.famIdx item.timeIdx h_theta_seed1
                    (Or.inr (fun h => by
                      have h_fresh := ModelSeed.freshPastTime_lt_current seed1 item.famIdx item.timeIdx
                      omega))
          · exact absurd h_item_pos h_old_pos
      | inr h_pending =>
        right
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        use w
        constructor
        · exact List.mem_append_left _ hw_in
        · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩
    · -- H theta closure
      intro f t theta h_H
      have h_or1 := mem_getFormulas_after_createNewTime seed1 item.famIdx
                      (seed1.freshPastTime item.famIdx item.timeIdx) (Formula.neg psi)
                      (Formula.all_past theta) f t h_H
      have h_in_seed1 : Formula.all_past theta ∈ seed1.getFormulas f t := by
        cases h_or1 with
        | inl h => exact h
        | inr h => exact absurd h.1 Formula.noConfusion
      have h_or2 := mem_getFormulas_after_addFormula state.seed item.famIdx item.timeIdx
                      (Formula.neg (Formula.all_past psi)) (Formula.all_past theta) .universal_target f t h_in_seed1
      have h_in_orig : Formula.all_past theta ∈ state.seed.getFormulas f t := by
        cases h_or2 with
        | inl h => exact h
        | inr h => unfold Formula.neg at h; exact absurd h.1 Formula.noConfusion
      cases h_inv.2.2 f t theta h_in_orig with
      | inl h_closed =>
        left
        intro t' h_lt h_pos'
        have h_or_pos := createNewTime_preserves_hasPosition seed1 item.famIdx
                           (seed1.freshPastTime item.famIdx item.timeIdx) (Formula.neg psi) f t' h_pos'
        have h_or_pos2 := addFormula_hasPosition_backward state.seed item.famIdx item.timeIdx
                            (Formula.neg (Formula.all_past psi)) .universal_target f t' h_or_pos
        cases h_or_pos2 with
        | inl h_pos_orig =>
          have h_theta_orig := h_closed t' h_lt h_pos_orig
          have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed f t' theta
                                  (Formula.neg (Formula.all_past psi)) .universal_target h_theta_orig
          -- Need to prove f ≠ item.famIdx ∨ t' ≠ freshPastTime
          have h_diff : f ≠ item.famIdx ∨ t' ≠ seed1.freshPastTime item.famIdx item.timeIdx := by
            by_cases h_fam : f = item.famIdx
            · right
              subst h_fam
              have h_pos_seed1 := addFormula_preserves_hasPosition state.seed item.famIdx item.timeIdx
                                    (Formula.neg (Formula.all_past psi)) .universal_target item.famIdx t' h_pos_orig
              have h_gt := ModelSeed.hasPosition_time_gt_freshPastTime seed1 item.famIdx t' item.timeIdx h_pos_seed1
              omega
            · left; exact h_fam
          exact createNewTime_preserves_mem_getFormulas seed1 item.famIdx
                  (seed1.freshPastTime item.famIdx item.timeIdx) theta (Formula.neg psi) f t' h_theta_seed1
                  h_diff
        | inr h_new_pos =>
          obtain ⟨hf', ht'⟩ := h_new_pos
          subst hf' ht'
          by_cases h_old_pos : state.seed.hasPosition item.famIdx item.timeIdx
          · have h_theta_orig := h_closed item.timeIdx h_lt h_old_pos
            have h_theta_seed1 := addFormula_preserves_mem_getFormulas_same state.seed item.famIdx item.timeIdx theta
                                    (Formula.neg (Formula.all_past psi)) .universal_target h_theta_orig
            exact createNewTime_preserves_mem_getFormulas seed1 item.famIdx
                    (seed1.freshPastTime item.famIdx item.timeIdx) theta (Formula.neg psi) item.famIdx item.timeIdx h_theta_seed1
                    (Or.inr (fun h => by
                      have h_fresh := ModelSeed.freshPastTime_lt_current seed1 item.famIdx item.timeIdx
                      omega))
          · exact absurd h_item_pos h_old_pos
      | inr h_pending =>
        right
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        use w
        constructor
        · exact List.mem_append_left _ hw_in
        · exact ⟨hw_eq.1, hw_eq.2.1, hw_eq.2.2.1, fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)⟩

/--
Position invariant for worklist states: all pending work items have valid positions in the seed.
-/
def WorklistPosInvariant (state : WorklistState) : Prop :=
  ∀ w ∈ state.worklist, w ∉ state.processed → state.seed.hasPosition w.famIdx w.timeIdx

/-- Initial worklist state satisfies the position invariant. -/
lemma initial_pos_invariant (phi : Formula) :
    WorklistPosInvariant (WorklistState.initial phi) := by
  intro w hw hproc
  simp only [WorklistState.initial] at hw hproc
  simp only [List.mem_singleton] at hw
  subst hw
  simp only [WorklistState.initial, ModelSeed.hasPosition, ModelSeed.initial]
  simp only [List.any_cons, List.any_nil, Bool.or_false, Bool.and_eq_true, beq_iff_eq]
  exact ⟨rfl, rfl⟩

/-- Dropping a head element that is in processed preserves WorklistClosureInvariant.
    Since the invariant's right disjunct requires pending witnesses to be NOT in processed,
    an item already in processed can never be a valid witness. -/
private lemma WorklistClosureInvariant_drop_head_in_proc
    (seed : ModelSeed) (item : WorkItem) (rest : List WorkItem) (proc : Finset WorkItem)
    (h_in_proc : item ∈ proc)
    (h_inv : WorklistClosureInvariant { seed := seed, worklist := item :: rest, processed := proc }) :
    WorklistClosureInvariant { seed := seed, worklist := rest, processed := proc } := by
  constructor
  · -- Modal case
    intro f t psi h_box
    cases h_inv.1 f t psi h_box with
    | inl h_closed => left; exact h_closed
    | inr h_pending =>
      obtain ⟨w, hw_in, hw_eq⟩ := h_pending
      -- w ∈ item :: rest and w ∉ proc
      simp only [List.mem_cons] at hw_in
      cases hw_in with
      | inl h_eq =>
        -- w = item, but item ∈ proc, contradicting w ∉ proc
        subst h_eq
        exact absurd h_in_proc hw_eq.2.2.2
      | inr h_rest =>
        right; exact ⟨w, h_rest, hw_eq⟩
  constructor
  · -- G case
    intro f t psi h_G
    cases h_inv.2.1 f t psi h_G with
    | inl h_closed => left; exact h_closed
    | inr h_pending =>
      obtain ⟨w, hw_in, hw_eq⟩ := h_pending
      simp only [List.mem_cons] at hw_in
      cases hw_in with
      | inl h_eq =>
        subst h_eq
        exact absurd h_in_proc hw_eq.2.2.2
      | inr h_rest =>
        right; exact ⟨w, h_rest, hw_eq⟩
  · -- H case
    intro f t psi h_H
    cases h_inv.2.2 f t psi h_H with
    | inl h_closed => left; exact h_closed
    | inr h_pending =>
      obtain ⟨w, hw_in, hw_eq⟩ := h_pending
      simp only [List.mem_cons] at hw_in
      cases hw_in with
      | inl h_eq =>
        subst h_eq
        exact absurd h_in_proc hw_eq.2.2.2
      | inr h_rest =>
        right; exact ⟨w, h_rest, hw_eq⟩

/--
Fuel is sufficient if fuel is at least the total pending complexity.
The pending complexity uses multiset sum of complexities of unprocessed items.

This ensures termination because:
1. Each processing step removes an item with complexity c
2. New items have complexity < c (by processWorkItem_newWork_complexity_lt)
3. Total complexity strictly decreases under Dershowitz-Manna multiset ordering

For a simpler count-based argument, we would need that each step adds at most 1 item,
which is not true (e.g., boxPositive adds items to all families).
-/
def FuelSufficient (fuel : Nat) (state : WorklistState) : Prop :=
  fuel ≥ totalPendingComplexity state.worklist state.processed

/--
processWorklistAux preserves closure invariant, given sufficient fuel.
-/
theorem processWorklistAux_preserves_closure (fuel : Nat) (state : WorklistState)
    (h_inv : WorklistClosureInvariant state)
    (h_pos_inv : WorklistPosInvariant state)
    (h_fuel : FuelSufficient fuel state) :
    SeedClosed (processWorklistAux fuel state) := by
  induction fuel generalizing state with
  | zero =>
    -- fuel = 0, so by h_fuel: totalPendingComplexity ... ≤ 0
    -- This means the sum of complexities is 0, so the filter is empty
    simp only [processWorklistAux]
    -- Need to show state.seed is closed
    -- Since fuel sufficient with 0 fuel, pending complexity = 0
    unfold FuelSufficient at h_fuel
    have h_tpc_zero : totalPendingComplexity state.worklist state.processed = 0 := by omega
    -- totalPendingComplexity is a sum of complexities, which are all ≥ 1
    -- So sum = 0 means the filter list is empty
    unfold totalPendingComplexity at h_tpc_zero
    have h_filter_empty : (state.worklist.filter (· ∉ state.processed)) = [] := by
      by_contra h_ne
      -- If non-empty, there's at least one element with complexity ≥ 1
      cases h_cases : state.worklist.filter (· ∉ state.processed) with
      | nil => exact h_ne rfl
      | cons w ws =>
        -- Sum includes w.complexity ≥ 1
        have h_sum_pos : (List.map WorkItem.complexity (w :: ws)).sum ≥ 1 := by
          simp only [List.map_cons, List.sum_cons]
          have h_pos := Formula.complexity_pos w.formula
          unfold WorkItem.complexity
          omega
        rw [h_cases] at h_tpc_zero
        omega
    have h_all_processed : ∀ w ∈ state.worklist, w ∈ state.processed := by
      intro w hw
      by_contra h_not
      have h_in_filter : w ∈ state.worklist.filter (· ∉ state.processed) := by
        simp only [List.mem_filter]
        exact ⟨hw, h_not⟩
      rw [h_filter_empty] at h_in_filter
      exact absurd h_in_filter List.not_mem_nil
    -- With all items processed, the "pending" disjuncts in h_inv become vacuously false
    -- So the "closed" disjuncts must all be true
    constructor
    · -- ModalClosed
      intro f t psi h_box
      cases h_inv.1 f t psi h_box with
      | inl h_closed => exact h_closed
      | inr h_pending =>
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        -- w ∈ state.worklist but w ∉ state.processed - contradiction
        have h_w_proc := h_all_processed w hw_in
        exact absurd h_w_proc hw_eq.2.2.2
    constructor
    · -- GClosed
      intro f t psi h_G
      cases h_inv.2.1 f t psi h_G with
      | inl h_closed => exact h_closed
      | inr h_pending =>
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        have h_w_proc := h_all_processed w hw_in
        exact absurd h_w_proc hw_eq.2.2.2
    · -- HClosed
      intro f t psi h_H
      cases h_inv.2.2 f t psi h_H with
      | inl h_closed => exact h_closed
      | inr h_pending =>
        obtain ⟨w, hw_in, hw_eq⟩ := h_pending
        have h_w_proc := h_all_processed w hw_in
        exact absurd h_w_proc hw_eq.2.2.2
  | succ fuel' ih =>
    simp only [processWorklistAux]
    match h_wl : state.worklist with
    | [] =>
      -- Worklist empty - use empty_worklist_closure
      simp only [h_wl]
      exact empty_worklist_closure state h_wl h_inv
    | item :: rest =>
      simp only [h_wl]
      by_cases h_proc : item ∈ state.processed
      · -- Already processed, just continue with rest
        simp only [h_proc, ↓reduceIte]
        apply ih
        · -- case pos.h_inv: WorklistClosureInvariant for {state with worklist := rest}
          constructor
          · intro f t psi h_box
            cases h_inv.1 f t psi h_box with
            | inl h_closed => left; exact h_closed
            | inr h_pending =>
              obtain ⟨w, hw, h_eq⟩ := h_pending
              rw [h_wl] at hw
              cases hw with
              | head h => exact absurd h_proc (h ▸ h_eq.2.2.2)
              | tail _ hw' => right; exact ⟨w, hw', h_eq⟩
          constructor
          · -- G case (all_future)
            intro f t psi h_formula
            cases h_inv.2.1 f t psi h_formula with
            | inl h_closed => left; exact h_closed
            | inr h_pending =>
              obtain ⟨w, hw, h_eq⟩ := h_pending
              rw [h_wl] at hw
              cases hw with
              | head h => exact absurd h_proc (h ▸ h_eq.2.2.2)
              | tail _ hw' => right; exact ⟨w, hw', h_eq⟩
          · -- H case (all_past)
            intro f t psi h_formula
            cases h_inv.2.2 f t psi h_formula with
            | inl h_closed => left; exact h_closed
            | inr h_pending =>
              obtain ⟨w, hw, h_eq⟩ := h_pending
              rw [h_wl] at hw
              cases hw with
              | head h => exact absurd h_proc (h ▸ h_eq.2.2.2)
              | tail _ hw' => right; exact ⟨w, hw', h_eq⟩
        · -- case pos.h_pos_inv: WorklistPosInvariant for {state with worklist := rest}
          -- rest ⊆ item :: rest = state.worklist, so derive from h_pos_inv
          intro w hw hnot
          apply h_pos_inv
          · rw [h_wl]; exact List.mem_cons_of_mem item hw
          · exact hnot
        · -- case pos.h_fuel: FuelSufficient fuel' {state with worklist := rest}
          -- item ∈ processed, so totalPendingComplexity is same for rest as for item::rest
          unfold FuelSufficient at h_fuel ⊢
          simp only [WorklistState.worklist, WorklistState.processed]
          rw [h_wl] at h_fuel
          simp only [WorklistState.worklist, WorklistState.processed] at h_fuel
          -- Since item ∈ processed, totalPendingComplexity(item :: rest) = totalPendingComplexity(rest)
          rw [totalPendingComplexity_of_in_processed item rest state.processed h_proc] at h_fuel
          omega
      · -- Process the item
        simp only [h_proc, ↓reduceIte]
        apply ih
        · -- case neg.h_inv: WorklistClosureInvariant for new state
          -- Strategy: use processWorkItem_preserves_closure on state (with item :: rest),
          -- then use indep lemma and drop-processed-head lemma
          -- Step 1: Get h_item_pos from h_pos_inv
          have h_item_pos : state.seed.hasPosition item.famIdx item.timeIdx := by
            apply h_pos_inv
            · rw [h_wl]; exact List.mem_cons.mpr (Or.inl rfl)
            · exact h_proc
          -- Step 2: Apply processWorkItem_preserves_closure with full state (worklist = item :: rest)
          have h_closure_big := processWorkItem_preserves_closure item state h_inv h_proc h_item_pos
          -- Step 3: Simplify h_closure_big using h_wl
          -- h_closure_big unfolds the match to give the invariant directly
          simp only [h_wl] at h_closure_big
          -- Step 4: Get independence from worklist - key: same seed, newWork, processed
          obtain ⟨h_seed_eq, h_newwork_eq, h_proc_eq⟩ := processWorkItem_indep_worklist item state rest
          -- Step 5: Apply drop-processed-head using independence equations
          -- The goal uses processWorkItem item { state with worklist := rest }
          -- h_closure_big uses processWorkItem item state
          -- But they're equal componentwise by h_seed_eq, h_newwork_eq, h_proc_eq
          have h_item_in_new_proc : item ∈ insert item state.processed :=
            Finset.mem_insert_self _ _
          -- Use drop_head_in_proc on a converted version
          apply WorklistClosureInvariant_drop_head_in_proc
            (processWorkItem item { state with worklist := rest }).2.seed
            item _
            (insert item (processWorkItem item { state with worklist := rest }).2.processed)
          · -- item ∈ insert item ...
            rw [← h_proc_eq] at h_item_in_new_proc
            exact h_item_in_new_proc
          · -- WorklistClosureInvariant with item :: rest ++ ...
            convert h_closure_big using 1
            simp only [h_seed_eq, h_newwork_eq, h_proc_eq, List.cons_append]
        · -- case neg.h_pos_inv: WorklistPosInvariant for new state
          -- Strategy:
          -- (a) For w ∈ rest: old seed had position (by h_pos_inv), new seed preserves it
          --     (by processWorkItem_preserves_hasPosition)
          -- (b) For w ∈ filteredNew: new work items have positions in new seed
          --     (by processWorkItem_newWork_hasPosition)
          -- Abbreviate the processWorkItem application
          set st' := { state with worklist := rest } with hst'_def
          set result := processWorkItem item st' with hresult_def
          -- Key facts about processed set
          have h_proc_eq : result.2.processed = state.processed :=
            processWorkItem_processed_eq item st'
          -- Get item's position (needed for newWork positions)
          have h_item_pos : st'.seed.hasPosition item.famIdx item.timeIdx := by
            simp only [hst'_def, WorklistState.seed]
            apply h_pos_inv
            · rw [h_wl]; exact List.mem_cons.mpr (Or.inl rfl)
            · exact h_proc
          -- Prove WorklistPosInvariant
          intro w hw hnot_in_proc
          simp only [List.mem_append, List.mem_filter, decide_eq_true_eq] at hw
          rcases hw with hw_rest | ⟨hw_newwork, hw_not_in_proc⟩
          · -- w ∈ rest
            -- Step 1: w ∉ insert item state.processed
            have h_w_not_proc : w ∉ state.processed := by
              intro h_in_proc
              apply hnot_in_proc
              simp only [Finset.mem_insert]
              right
              rw [← h_proc_eq]
              exact h_in_proc
            -- Step 2: state.seed has position for w (since w ∈ rest ⊆ state.worklist)
            have h_old_pos : state.seed.hasPosition w.famIdx w.timeIdx := by
              apply h_pos_inv
              · rw [h_wl]; exact List.mem_cons_of_mem item hw_rest
              · exact h_w_not_proc
            -- Step 3: New seed preserves this position
            exact processWorkItem_preserves_hasPosition item st' _ _ h_old_pos
          · -- w ∈ filteredNew ⊆ result.1 (new work items)
            -- result.2.seed has position for all w ∈ result.1
            exact processWorkItem_newWork_hasPosition item st' h_item_pos w hw_newwork
        · -- case neg.h_fuel: FuelSufficient fuel' for new state
          -- Dershowitz-Manna termination argument:
          -- Before: totalPendingComplexity(item :: rest, proc) = item.complexity + tpc(rest)
          -- After: totalPendingComplexity(rest ++ newWork, insert item proc)
          --       = tpc(rest, insert item proc) + sum(newWork complexities)
          -- Key facts:
          -- (1) tpc(rest, insert item proc) ≤ tpc(rest, proc) (larger processed = smaller pending)
          -- (2) Each newWork item has complexity < item.complexity
          -- (3) But sum of newWork complexities might exceed item.complexity!
          -- This is exactly the Dershowitz-Manna multiset ordering situation:
          --   We can't prove count decreases, but multiset ordering decreases.
          --
          -- For fuel-based termination, we need a different approach:
          -- The fuel bound in processWorklist is O(n²) where n = initial complexity.
          -- Each item can generate at most n new items, but each has lower complexity.
          -- Total work is bounded by the multiset termination order.
          --
          -- Full proof requires: proving that totalPendingComplexity strictly decreases
          -- when we process an item. This is non-trivial because:
          -- - We remove item.complexity
          -- - We add sum of new item complexities
          -- - Need: sum of new ≤ item.complexity
          -- But this is NOT generally true! Counter: Box p has complexity 2,
          -- processing it at n families creates n items each with complexity 1.
          -- If n > 2, sum > item.complexity.
          --
          -- The proper termination requires multiset ordering, not sum.
          -- TERMINATION SORRY: Requires Dershowitz-Manna multiset ordering proof
          sorry

/--
buildSeedComplete produces a closed seed.
-/
theorem buildSeedComplete_closed (phi : Formula) :
    SeedClosed (buildSeedComplete phi) := by
  unfold buildSeedComplete
  apply processWorklistAux_preserves_closure
  · exact initial_closure_invariant phi
  · exact initial_pos_invariant phi
  · -- FuelSufficient: fuel ≥ totalPendingComplexity
    -- processWorklist sets fuel = (maxComplexity² + 1) * (worklist.length + 1)
    -- Initial worklist = [⟨phi, 0, 0⟩], so:
    --   - maxComplexity = phi.complexity
    --   - length = 1
    --   - fuel = (c² + 1) * 2 where c = phi.complexity
    -- totalPendingComplexity([⟨phi, 0, 0⟩], ∅) = phi.complexity = c
    -- Need: (c² + 1) * 2 ≥ c, which holds for all c ≥ 0
    unfold FuelSufficient processWorklist WorklistState.initial
    simp only [List.map_singleton, List.foldl_singleton, WorklistState.worklist, WorklistState.processed]
    -- The worklist has one item with complexity phi.complexity
    -- processed = ∅, so filter keeps it
    unfold totalPendingComplexity
    simp only [List.filter_singleton, Finset.not_mem_empty, decide_true, ↓reduceIte,
               List.map_singleton, List.sum_singleton]
    -- Need: (max 0 (phi.complexity) * max 0 (phi.complexity) + 1) * (1 + 1) ≥ phi.complexity
    simp only [max_self, Nat.add_one_mul]
    -- Simplifies to: phi.complexity² + phi.complexity² + 2 ≥ phi.complexity
    have h_pos := Formula.complexity_pos phi
    omega

/-- SeedClosed implies ModalClosed (projection). -/
theorem SeedClosed_implies_ModalClosed (seed : ModelSeed) (h : SeedClosed seed) :
    ModalClosed seed := h.1

/-- SeedClosed implies GClosed (projection). -/
theorem SeedClosed_implies_GClosed (seed : ModelSeed) (h : SeedClosed seed) :
    GClosed seed := h.2.1

/-- SeedClosed implies HClosed (projection). -/
theorem SeedClosed_implies_HClosed (seed : ModelSeed) (h : SeedClosed seed) :
    HClosed seed := h.2.2

/-- buildSeedComplete produces a modally closed seed. -/
theorem buildSeedComplete_modalClosed (phi : Formula) :
    ModalClosed (buildSeedComplete phi) :=
  SeedClosed_implies_ModalClosed _ (buildSeedComplete_closed phi)

/-- buildSeedComplete produces a G-closed seed. -/
theorem buildSeedComplete_gClosed (phi : Formula) :
    GClosed (buildSeedComplete phi) :=
  SeedClosed_implies_GClosed _ (buildSeedComplete_closed phi)

/-- buildSeedComplete produces an H-closed seed. -/
theorem buildSeedComplete_hClosed (phi : Formula) :
    HClosed (buildSeedComplete phi) :=
  SeedClosed_implies_HClosed _ (buildSeedComplete_closed phi)

end Bimodal.Metalogic.Bundle
