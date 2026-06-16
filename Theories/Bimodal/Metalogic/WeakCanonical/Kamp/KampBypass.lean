import Bimodal.Metalogic.WeakCanonical.Kamp.KampBypassCore
import Bimodal.Metalogic.WeakCanonical.Kamp.KampBypassUntil
import Bimodal.Metalogic.WeakCanonical.Kamp.KampBypassSince

/-!
# Enriched Bypass Formula: Main Theorems

Main bypass theorems that dispatch to the three direction-specific proofs.
See KampBypassCore.lean for shared definitions and equality case, and KampBypassUntil/Since.lean
for the direction-specific correctness proofs.

Factored from a single 4488-line file (task 301).

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5
- VecEADecomp.lean (depth-0 3-var zone decomposition)
- NfToVecEA.lean (depth-0 2-var bridge)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (formula_disjList formula_disjList_iff)

/-! ## Main Bypass Theorem (Zone-Aware) -/

/-- Zone-aware enriched bypass for depth 1 (k=0): the 2-var existential at depth 1
    has a temporal formula characterization on Prior structures.

    At depth 1 (k=0 inner), the 3-var quantifier conditions are at depth 0
    (purely atomic), so the zone-aware encoding uses nf_depth0_char_formula
    for y's characteristic. The zone distribution across Until/Since avoids
    the y-t order loss of the v1 formula. -/
theorem existPart_succ_n1_bypass_k0
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
    (sub_nf : NormalForm sig 1 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  match h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)),
        h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) with
  | true, true =>
    exact ⟨Formula.bot, fun M _ _ t h_atoms => by
      simp only [temporal_truth]
      exact ⟨fun h => absurd h id, fun ⟨x, h_eval⟩ =>
        absurd (lt_trans
          ((zone_from_nf_eval M sub_nf t x h_eval).1 h_gt)
          ((zone_from_nf_eval M sub_nf t x h_eval).2.1 h_lt))
          (lt_irrefl _)⟩⟩
  | true, false =>
    exact existPart_succ_n1_bypass_k0_until atomMap h_surj char_1 char_1_correct
      parent_atoms sub_nf h_gt h_lt
  | false, true =>
    exact existPart_succ_n1_bypass_k0_since atomMap h_surj char_1 char_1_correct
      parent_atoms sub_nf h_gt h_lt
  | false, false =>
    exact existPart_succ_n1_bypass_k0_eq atomMap h_surj char_1 char_1_correct
      parent_atoms sub_nf h_gt h_lt

/-- General enriched bypass for ExistPart(k+1) at n=1.
    Delegates to existPart_succ_n1_bypass_k0 for k=0 and uses sorry for k>0. -/
theorem existPart_succ_n1_bypass
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_kp1 : NormalForm sig (k + 1) 1 → Formula)
    (char_kp1_correct : ∀ (nf_1 : NormalForm sig (k + 1) 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_kp1 nf_1) ↔
        nf_eval_nf M (k + 1) 1 (fun _ => t) nf_1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k + 1) 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  cases k with
  | zero =>
    exact existPart_succ_n1_bypass_k0 atomMap h_surj char_kp1 char_kp1_correct parent_atoms sub_nf
  | succ k' =>
    -- Classical case split: is sub_nf satisfiable on any Prior structure?
    rcases Classical.em (∃ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier) (x : M.carrier),
        nf_eval_nf M (k' + 1 + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf ∧
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true))
        with ⟨M₀, h_UZ₀, h_SZ₀, t₀, x₀, h_eval₀, h_atoms₀⟩ | h_unsat
    · -- Satisfiable case: zone dispatch with char_kp1 disjunction
      -- Predicate compatibility check
      let compat_check : NormalForm sig (k' + 1 + 1) 1 → Bool := fun nf_x =>
        (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
          nf_x.1 (.pred p ⟨0, by omega⟩) == sub_nf.1 (.pred p ⟨0, by omega⟩)
      let compat_disj := formula_disjList
        ((Fintype.elems (α := NormalForm sig (k' + 1 + 1) 1)).val.toList.filterMap fun nf_x =>
          if compat_check nf_x then some (char_kp1 nf_x) else none)
      -- Zone extraction from atom part of nf_eval_nf
      have zone_order : ∀ (M : OrderedMonadicStructure sig) (t x : M.carrier)
          (h_eval : nf_eval_nf M (k' + 1 + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf),
          (sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true → t < x) ∧
          (sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true → x < t) := by
        intro M t x h_eval
        exact ⟨fun h => by
          have := (h_eval.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mpr h
          simp only [atom_eval, Fin.cons] at this; exact this,
        fun h => by
          have := (h_eval.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))).mpr h
          simp only [atom_eval, Fin.cons] at this; exact this⟩
      -- Witness equality from no-order case
      have wit_eq : ∀ (M : OrderedMonadicStructure sig) (t x : M.carrier)
          (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
          (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
          (h_eval : nf_eval_nf M (k' + 1 + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf),
          x = t := by
        intro M t x h_gt h_lt h_eval
        by_contra h_ne
        rcases lt_or_gt_of_ne h_ne with h' | h'
        · have := (h_eval.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))).mp
          simp only [atom_eval, Fin.cons] at this
          exact Bool.noConfusion (h_lt ▸ this h')
        · have := (h_eval.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mp
          simp only [atom_eval, Fin.cons] at this
          exact Bool.noConfusion (h_gt ▸ this h')
      -- Forward: x satisfies sub_nf → compat_disj holds at x
      have fwd_disj : ∀ (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
          (x : M.carrier),
          nf_eval_nf M (k' + 1 + 1) 1 (fun _ => x)
            (nf_characteristic M (k' + 1 + 1) 1 (fun _ => x)) →
          compat_check (nf_characteristic M (k' + 1 + 1) 1 (fun _ => x)) = true →
          temporal_truth M atomMap x compat_disj := by
        intro M h_UZ h_SZ x h_nf_x h_compat
        rw [formula_disjList_iff]
        refine ⟨char_kp1 (nf_characteristic M (k' + 1 + 1) 1 (fun _ => x)), ?_, ?_⟩
        · simp only [List.mem_filterMap, Multiset.mem_toList]
          exact ⟨nf_characteristic M (k' + 1 + 1) 1 (fun _ => x),
            Fintype.complete _, by simp [h_compat]⟩
        · exact (char_kp1_correct _ M h_UZ h_SZ x).mpr h_nf_x
      -- Compat of characteristic NF
      have compat_of_eval : ∀ (M : OrderedMonadicStructure sig) (t x : M.carrier)
          (h_eval : nf_eval_nf M (k' + 1 + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf),
          compat_check (nf_characteristic M (k' + 1 + 1) 1 (fun _ => x)) = true := by
        intro M t x ⟨h_atom, _⟩
        simp only [compat_check, List.all_eq_true, beq_iff_eq]
        intro p _
        have h_sub_p := h_atom (.pred p ⟨0, by omega⟩)
        have h_char_p := (nf_characteristic_satisfies M (k' + 1 + 1) 1 (fun _ => x)).1
          (.pred p ⟨0, by omega⟩)
        have key := h_atom (.pred p ⟨0, by omega⟩)
        simp only [atom_eval, Fin.cons] at key
        change M.interp p x ↔ _ at key
        unfold nf_characteristic
        simp only [atom_eval]
        cases h : sub_nf.1 (AtomKind.pred p ⟨0, by omega⟩)
        · rw [h] at key; simp only [Bool.false_eq_true, iff_false] at key
          exact @decide_eq_false _ (Classical.dec _) key
        · rw [h] at key; simp only [iff_true] at key
          exact @decide_eq_true _ (Classical.dec _) key
      -- Zone dispatch
      match h_gt_val : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)),
            h_lt_val : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) with
      | true, true =>
        exact ⟨Formula.bot, fun M _ _ t _ => by
          simp only [temporal_truth]
          exact ⟨fun h => absurd h id, fun ⟨x, h_eval⟩ =>
            absurd (lt_trans
              ((zone_order M t x h_eval).1 h_gt_val)
              ((zone_order M t x h_eval).2 h_lt_val))
              (lt_irrefl _)⟩⟩
      | true, false =>
        refine ⟨Formula.untl compat_disj Formula.top, fun M h_UZ h_SZ t h_atoms => ?_⟩
        constructor
        · -- Backward: temporal → ∃ x
          sorry
        · -- Forward: ∃ x → temporal
          intro ⟨x, h_eval⟩
          exact ⟨x, (zone_order M t x h_eval).1 h_gt_val,
            fwd_disj M h_UZ h_SZ x
              (nf_characteristic_satisfies M (k' + 1 + 1) 1 (fun _ => x))
              (compat_of_eval M t x h_eval),
            fun _ _ _ => id⟩
      | false, true =>
        refine ⟨Formula.snce compat_disj Formula.top, fun M h_UZ h_SZ t h_atoms => ?_⟩
        constructor
        · -- Backward: temporal → ∃ x
          sorry
        · -- Forward: ∃ x → temporal
          intro ⟨x, h_eval⟩
          exact ⟨x, (zone_order M t x h_eval).2 h_lt_val,
            fwd_disj M h_UZ h_SZ x
              (nf_characteristic_satisfies M (k' + 1 + 1) 1 (fun _ => x))
              (compat_of_eval M t x h_eval),
            fun _ _ _ => id⟩
      | false, false =>
        refine ⟨compat_disj, fun M h_UZ h_SZ t h_atoms => ?_⟩
        constructor
        · -- Backward: temporal → ∃ x
          sorry
        · -- Forward: ∃ x → temporal
          intro ⟨x, h_eval⟩
          have h_x_eq := wit_eq M t x h_gt_val h_lt_val h_eval
          rw [h_x_eq] at h_eval
          exact fwd_disj M h_UZ h_SZ t
            (nf_characteristic_satisfies M (k' + 1 + 1) 1 (fun _ => t))
            (compat_of_eval M t t h_eval)
    · -- Unsatisfiable: use ⊥
      exact ⟨Formula.bot, fun M _ _ t h_atoms => by
        simp only [temporal_truth]
        constructor
        · intro h; exact absurd h id
        · rintro ⟨x, hx⟩
          exact absurd ⟨M, ‹_›, ‹_›, t, x, hx, h_atoms⟩ h_unsat⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
