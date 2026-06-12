import Bimodal.Metalogic.WeakCanonical.NormalForm

/-!
# Feferman-Vaught Composition for Normal Forms

**QUARANTINED (Task 273, Plan v23)**: This file contains the witness merging
(Feferman-Vaught composition) problem with 2 sorries and 5 failed attempts.
The NF-specific Prop 4.3 path eliminates the need for this composition at
depth 0; the general composition at depth >= 1 remains open and is the root
blocker for the full Kamp chain (see NegationClosure.lean:1371 blocker comment).
File retained for reference.

The depth-k n-var characteristic NF is determined by the depth-(k+1)
1-var NFs plus pairwise order relations. Doets 1989 Lemma 1.4/1.5.

## Main Result

`nf_3var_from_1var_nfs`: Same 1-var NFs + matching orders implies
same 3-var NF.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Metalogic.WeakCanonical

/-- If two points have the same depth-(k+1) 1-var NF, they agree on predicates. -/
theorem pred_agree_of_1var_nf_eq {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat) (a b : M.carrier)
    (h : nf_characteristic M (k + 1) 1 (fun _ => a) =
         nf_characteristic M (k + 1) 1 (fun _ => b))
    (p : sig.preds) : M.interp p a ↔ M.interp p b := by
  have h1 : (nf_characteristic M (k + 1) 1 (fun _ => a)).1 =
             (nf_characteristic M (k + 1) 1 (fun _ => b)).1 := by rw [h]
  have ha := congr_fun h1 (.pred p ⟨0, by omega⟩)
  simp only [nf_characteristic, atom_eval] at ha
  by_cases h1 : M.interp p a <;> by_cases h2 : M.interp p b <;>
    simp_all [decide_eq_true_eq, decide_eq_false_iff_not]

/-- Helper: convert iff to Classical.decide equality. -/
private theorem classical_decide_eq_of_iff {p q : Prop}
    (h : p ↔ q) : @decide p (Classical.dec p) = @decide q (Classical.dec q) := by
  by_cases hp : p <;> by_cases hq : q <;>
    simp_all [decide_eq_true_eq, decide_eq_false_iff_not]

/-- Feferman-Vaught composition for arity 3. -/
theorem nf_3var_from_1var_nfs {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) :
    ∀ (k : Nat)
    (y1 x1 t1 y2 x2 t2 : M.carrier)
    (h_y : nf_characteristic M (k + 1) 1 (fun _ => y1) =
           nf_characteristic M (k + 1) 1 (fun _ => y2))
    (h_x : nf_characteristic M (k + 1) 1 (fun _ => x1) =
           nf_characteristic M (k + 1) 1 (fun _ => x2))
    (h_t : nf_characteristic M (k + 1) 1 (fun _ => t1) =
           nf_characteristic M (k + 1) 1 (fun _ => t2))
    (h_ord : ∀ (i j : Fin 3) (h : i ≠ j),
      ((Fin.cons y1 (Fin.cons x1 (fun _ => t1)) : Fin 3 → M.carrier) i <
       (Fin.cons y1 (Fin.cons x1 (fun _ => t1)) : Fin 3 → M.carrier) j) ↔
      ((Fin.cons y2 (Fin.cons x2 (fun _ => t2)) : Fin 3 → M.carrier) i <
       (Fin.cons y2 (Fin.cons x2 (fun _ => t2)) : Fin 3 → M.carrier) j)),
    nf_characteristic M k 3 (Fin.cons y1 (Fin.cons x1 (fun _ => t1))) =
    nf_characteristic M k 3 (Fin.cons y2 (Fin.cons x2 (fun _ => t2))) := by
  intro k
  induction k with
  | zero =>
    intro y1 x1 t1 y2 x2 t2 h_y h_x h_t h_ord
    simp only [nf_characteristic]
    funext a
    match a with
    | .pred p ⟨0, _⟩ =>
      exact classical_decide_eq_of_iff (by
        show M.interp p y1 ↔ M.interp p y2
        exact pred_agree_of_1var_nf_eq M 0 y1 y2 h_y p)
    | .pred p ⟨1, _⟩ =>
      exact classical_decide_eq_of_iff (by
        show M.interp p x1 ↔ M.interp p x2
        exact pred_agree_of_1var_nf_eq M 0 x1 x2 h_x p)
    | .pred p ⟨2, _⟩ =>
      exact classical_decide_eq_of_iff (by
        show M.interp p t1 ↔ M.interp p t2
        exact pred_agree_of_1var_nf_eq M 0 t1 t2 h_t p)
    | .order i j h_ne =>
      exact classical_decide_eq_of_iff (h_ord i j h_ne)
  | succ k ih =>
    intro y1 x1 t1 y2 x2 t2 h_y h_x h_t h_ord
    simp only [nf_characteristic]
    apply Prod.ext
    · -- Atom part
      funext a
      match a with
      | .pred p ⟨0, _⟩ =>
        exact classical_decide_eq_of_iff (by
          show M.interp p y1 ↔ M.interp p y2
          exact pred_agree_of_1var_nf_eq M (k + 1) y1 y2 h_y p)
      | .pred p ⟨1, _⟩ =>
        exact classical_decide_eq_of_iff (by
          show M.interp p x1 ↔ M.interp p x2
          exact pred_agree_of_1var_nf_eq M (k + 1) x1 x2 h_x p)
      | .pred p ⟨2, _⟩ =>
        exact classical_decide_eq_of_iff (by
          show M.interp p t1 ↔ M.interp p t2
          exact pred_agree_of_1var_nf_eq M (k + 1) t1 t2 h_t p)
      | .order i j h_ne =>
        exact classical_decide_eq_of_iff (h_ord i j h_ne)
    · -- Quantifier part: ∃ z in context 1 ↔ ∃ z in context 2
      funext sub4
      exact classical_decide_eq_of_iff ⟨
        fun ⟨z, hz⟩ => by
          -- z witnesses sub4 in context 1; find witness in context 2
          -- By IH, the (k+1)-level 3-var NF at (z,y,x,t) is determined by
          -- pairwise 2-var NFs. The witness transfer on linear orders gives
          -- z' with the same pairwise structure in context 2.
          sorry,
        fun ⟨z, hz⟩ => by
          sorry⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
