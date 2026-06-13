import Bimodal.Metalogic.WeakCanonical.NormalForm

/-!
# Feferman-Vaught Composition for Normal Forms

The depth-k n-var characteristic NF is determined by the depth-(k+1)
1-var NFs plus pairwise order relations. Doets 1989 Lemma 1.4/1.5.

## Main Results

- `nf_drop_last`: projection lemma -- depth-k (n+1)-var NF agreement implies
  depth-k n-var NF agreement for the first n components
- `nf_1var_from_2var_agree`: 2-var NF agreement implies 1-var NF agreement
- `generalized_composition`: same depth-(k+1) 1-var NFs + matching orders
  implies same depth-k n-var NF
- `nf_3var_from_1var_nfs`: specialization to arity 3
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

/-! ## Monotonicity for 1-var NFs (intra-structure) -/

/-- Depth-d 1-var NF agreement implies depth-k agreement for k ≤ d. -/
theorem nf_1var_monotone_le {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {k d : Nat} (hkd : k ≤ d)
    (a b : M.carrier)
    (h : nf_characteristic M d 1 (fun _ => a) =
         nf_characteristic M d 1 (fun _ => b)) :
    nf_characteristic M k 1 (fun _ => a) =
    nf_characteristic M k 1 (fun _ => b) := by
  have ha := nf_characteristic_satisfies M d 1 (fun _ => a)
  have hb' : nf_eval_nf M d 1 (fun _ => b)
      (nf_characteristic M d 1 (fun _ => a)) := h ▸
    nf_characteristic_satisfies M d 1 (fun _ => b)
  have h_agree := nf_agreement_from_shared_nf M (fun _ => a) M (fun _ => b)
      _ ha hb'
  exact nf_eval_unique M k 1 _ _ _
    ((nf_agreement_monotone k d 1 hkd M (fun _ => a) M (fun _ => b) h_agree _).mp
      (nf_characteristic_satisfies M k 1 (fun _ => a)))
    (nf_characteristic_satisfies M k 1 (fun _ => b))

/-! ## Helper: Fin.cons commutes with Fin.castSucc composition -/

private theorem fin_cons_castSucc_comm {α : Type*} {n : Nat}
    (x : α) (env : Fin (n + 1) → α) :
    (Fin.cons x env) ∘ Fin.castSucc = Fin.cons x (env ∘ Fin.castSucc) := by
  funext ⟨i, hi⟩
  cases i with
  | zero => rfl
  | succ i => rfl

/-! ## Projection / Drop-Last Lemma -/

/-- **Projection lemma**: If two (n+1)-var environments in the same structure
    have the same depth-k (n+1)-var NF, then the first n components have the
    same depth-k n-var NF.

    Proved by induction on k with n universally quantified. -/
theorem nf_drop_last {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) :
    ∀ (k n : Nat) (env env' : Fin (n + 1) → M.carrier)
    (h : nf_characteristic M k (n + 1) env =
         nf_characteristic M k (n + 1) env'),
    nf_characteristic M k n (env ∘ Fin.castSucc) =
    nf_characteristic M k n (env' ∘ Fin.castSucc) := by
  intro k
  induction k with
  | zero =>
    intro n env env' h
    simp only [nf_characteristic] at h ⊢
    funext a
    cases a with
    | pred p i =>
      exact congr_fun h (.pred p (Fin.castSucc i))
    | order i j h_ne =>
      exact congr_fun h (.order (Fin.castSucc i) (Fin.castSucc j)
        (fun heq => h_ne (Fin.castSucc_injective _ heq)))
  | succ k ih =>
    intro n env env' h
    have h_sat_env := nf_characteristic_satisfies M (k + 1) (n + 1) env
    have h_sat_env' := nf_characteristic_satisfies M (k + 1) (n + 1) env'
    have h_env'_sat : nf_eval_nf M (k + 1) (n + 1) env'
        (nf_characteristic M (k + 1) (n + 1) env) := h ▸ h_sat_env'
    have h_agree := nf_agreement_from_shared_nf M env M env' _ h_sat_env h_env'_sat
    -- Extract quantifier transfer from h_agree
    obtain ⟨_, h_quant_env⟩ := h_sat_env
    obtain ⟨_, h_quant_env'⟩ := h_env'_sat
    have hex_transfer : ∀ chi : NormalForm sig k (n + 2),
        (∃ x, nf_eval_nf M k (n + 2) (Fin.cons x env) chi) ↔
        (∃ x, nf_eval_nf M k (n + 2) (Fin.cons x env') chi) :=
      fun chi => (h_quant_env chi).trans (h_quant_env' chi).symm
    apply nf_eval_unique M (k + 1) n (env' ∘ Fin.castSucc)
    · -- env' ∘ castSucc satisfies the char NF of env ∘ castSucc at depth k+1
      constructor
      · -- Atom part: extract from h_agree
        intro a
        have h_atom := atom_agreement_from_nf M env M env' h_agree
        have h_sat_proj := nf_characteristic_satisfies M (k + 1) n (env ∘ Fin.castSucc)
        obtain ⟨h_proj_atoms, _⟩ := h_sat_proj
        cases a with
        | pred p i =>
          exact (h_atom (.pred p (Fin.castSucc i))).symm.trans (h_proj_atoms (.pred p i))
        | order i j h_ne =>
          exact (h_atom (.order (Fin.castSucc i) (Fin.castSucc j)
            (fun heq => h_ne (Fin.castSucc_injective _ heq)))).symm.trans
            (h_proj_atoms (.order i j h_ne))
      · -- Quantifier part: transfer witnesses using IH
        intro sub_nf
        have h_sat_proj := nf_characteristic_satisfies M (k + 1) n (env ∘ Fin.castSucc)
        obtain ⟨_, h_proj_quant⟩ := h_sat_proj
        -- Suffices to show the two ∃ are equivalent
        suffices h_eq : (∃ x, nf_eval_nf M k (n + 1) (Fin.cons x (env' ∘ Fin.castSucc)) sub_nf) ↔
            (∃ x, nf_eval_nf M k (n + 1) (Fin.cons x (env ∘ Fin.castSucc)) sub_nf) by
          exact h_eq.trans (h_proj_quant sub_nf)
        constructor
        · -- env' → env direction
          rintro ⟨x, hx⟩
          rw [← fin_cons_castSucc_comm] at hx
          have h_full_sat := nf_characteristic_satisfies M k (n + 2) (Fin.cons x env')
          obtain ⟨x', hx'⟩ := (hex_transfer (nf_characteristic M k (n + 2)
            (Fin.cons x env'))).mpr ⟨x, h_full_sat⟩
          have h_proj_eq := ih (n + 1) (Fin.cons x env') (Fin.cons x' env)
            (nf_eval_unique M k (n + 2) (Fin.cons x' env)
              (nf_characteristic M k (n + 2) (Fin.cons x env'))
              (nf_characteristic M k (n + 2) (Fin.cons x' env))
              hx' (nf_characteristic_satisfies M k (n + 2) (Fin.cons x' env)))
          rw [fin_cons_castSucc_comm, fin_cons_castSucc_comm] at h_proj_eq
          rw [fin_cons_castSucc_comm] at hx
          have h_sub := nf_eval_unique M k (n + 1) (Fin.cons x (env' ∘ Fin.castSucc))
            sub_nf (nf_characteristic M k (n + 1) (Fin.cons x (env' ∘ Fin.castSucc)))
            hx (nf_characteristic_satisfies M k (n + 1) (Fin.cons x (env' ∘ Fin.castSucc)))
          rw [h_sub, h_proj_eq]
          exact ⟨x', nf_characteristic_satisfies M k (n + 1) (Fin.cons x' (env ∘ Fin.castSucc))⟩
        · -- env → env' direction (symmetric)
          rintro ⟨x, hx⟩
          rw [← fin_cons_castSucc_comm] at hx
          have h_full_sat := nf_characteristic_satisfies M k (n + 2) (Fin.cons x env)
          obtain ⟨x', hx'⟩ := (hex_transfer (nf_characteristic M k (n + 2)
            (Fin.cons x env))).mp ⟨x, h_full_sat⟩
          have h_proj_eq := ih (n + 1) (Fin.cons x env) (Fin.cons x' env')
            (nf_eval_unique M k (n + 2) (Fin.cons x' env')
              (nf_characteristic M k (n + 2) (Fin.cons x env))
              (nf_characteristic M k (n + 2) (Fin.cons x' env'))
              hx' (nf_characteristic_satisfies M k (n + 2) (Fin.cons x' env')))
          rw [fin_cons_castSucc_comm, fin_cons_castSucc_comm] at h_proj_eq
          rw [fin_cons_castSucc_comm] at hx
          have h_sub := nf_eval_unique M k (n + 1) (Fin.cons x (env ∘ Fin.castSucc))
            sub_nf (nf_characteristic M k (n + 1) (Fin.cons x (env ∘ Fin.castSucc)))
            hx (nf_characteristic_satisfies M k (n + 1) (Fin.cons x (env ∘ Fin.castSucc)))
          rw [h_sub, h_proj_eq]
          exact ⟨x', nf_characteristic_satisfies M k (n + 1) (Fin.cons x' (env' ∘ Fin.castSucc))⟩
    · exact nf_characteristic_satisfies M (k + 1) n (env' ∘ Fin.castSucc)

/-! ## 1-var NF Extraction from 2-var NF Agreement -/

/-- If (a, c) and (b, d) have the same depth-k 2-var NF, then a and b have
    the same depth-k 1-var NF. Corollary of nf_drop_last. -/
theorem nf_1var_from_2var_agree {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat) (a b c d : M.carrier)
    (h : nf_characteristic M k 2 (Fin.cons a (fun _ => c)) =
         nf_characteristic M k 2 (Fin.cons b (fun _ => d))) :
    nf_characteristic M k 1 (fun _ => a) =
    nf_characteristic M k 1 (fun _ => b) := by
  -- nf_drop_last gives us the result for projected envs
  -- We just need to show the projected envs equal the constant envs
  have h_proj := nf_drop_last M k 1 (Fin.cons a (fun _ => c)) (Fin.cons b (fun _ => d)) h
  -- Key: (Fin.cons x f) ∘ Fin.castSucc = (fun _ => x) on Fin 1, definitionally
  -- because castSucc sends the unique element of Fin 1 to ⟨0, _⟩ and Fin.cons x f 0 = x
  have h_eq_a : (Fin.cons a (fun _ => c)) ∘ Fin.castSucc = (fun _ : Fin 1 => a) :=
    funext (fun ⟨i, hi⟩ => by have : i = 0 := Nat.lt_one_iff.mp hi; subst this; rfl)
  have h_eq_b : (Fin.cons b (fun _ => d)) ∘ Fin.castSucc = (fun _ : Fin 1 => b) :=
    funext (fun ⟨i, hi⟩ => by have : i = 0 := Nat.lt_one_iff.mp hi; subst this; rfl)
  rw [h_eq_a, h_eq_b] at h_proj
  exact h_proj

/-! ## Generalized Composition -/

/-- The generalized Feferman-Vaught composition for arbitrary arity.
    If two n-tuples in the same ordered monadic structure have:
    1. Matching depth-(k+1) 1-var NFs for each component
    2. Matching pairwise order relations
    Then they have the same depth-k n-var NF.

    Proved by induction on k with n universally quantified. -/
theorem generalized_composition {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) :
    ∀ (k n : Nat) (env1 env2 : Fin n → M.carrier)
    (h_nf : ∀ i : Fin n, nf_characteristic M (k + 1) 1 (fun _ => env1 i) =
                          nf_characteristic M (k + 1) 1 (fun _ => env2 i))
    (h_ord : ∀ (i j : Fin n), i ≠ j →
             (env1 i < env1 j ↔ env2 i < env2 j)),
    nf_characteristic M k n env1 = nf_characteristic M k n env2 := by
  intro k
  induction k with
  | zero =>
    intro n env1 env2 h_nf h_ord
    simp only [nf_characteristic]
    funext a
    cases a with
    | pred p i =>
      exact classical_decide_eq_of_iff (pred_agree_of_1var_nf_eq M 0 _ _ (h_nf i) p)
    | order i j h_ne =>
      exact classical_decide_eq_of_iff (h_ord i j h_ne)
  | succ k ih =>
    intro n env1 env2 h_nf h_ord
    simp only [nf_characteristic]
    apply Prod.ext
    · -- Atom part
      funext a
      cases a with
      | pred p i =>
        exact classical_decide_eq_of_iff (pred_agree_of_1var_nf_eq M (k + 1) _ _ (h_nf i) p)
      | order i j h_ne =>
        exact classical_decide_eq_of_iff (h_ord i j h_ne)
    · -- Quantifier part
      funext sub_nf
      apply classical_decide_eq_of_iff
      -- By IH at depth k with arity n+1: suffices to find z' with
      -- (a) nf_char M (k+1) 1 z' = nf_char M (k+1) 1 z (matching 1-var NFs)
      -- (b) z' < env2[i] ↔ z < env1[i] for all i (matching orders)
      -- Then ih (n+1) (Fin.cons z env1) (Fin.cons z' env2) ... gives the result.
      --
      -- For each env1[i], the depth-(k+2) 1-var NF encodes which depth-(k+1)
      -- 2-var NF types are realized around env1[i]. Since env2[i] has the same
      -- NF, the same types are realized around env2[i]. This gives z'_i per i
      -- with the right NF and order to env2[i], but a single z' for ALL i
      -- requires multi-point zone matching on the linear order.
      --
      -- BLOCKER: The multi-point zone matching argument requires showing that
      -- on a linear order, the "zone" of z relative to ALL env1 points has a
      -- corresponding zone in env2 containing a point with the right 1-var NF.
      -- The individual-point transfer (from depth-(k+2) NFs) gives z'_i per
      -- point i, but unifying them into a single z' requires reasoning about
      -- the intersection of zones, which is not straightforward without a
      -- density assumption or an inner induction on the number of reference
      -- points with a more complex argument.
      sorry

/-- Feferman-Vaught composition for arity 3.
    Corollary of generalized_composition. -/
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
  intro k y1 x1 t1 y2 x2 t2 h_y h_x h_t h_ord
  apply generalized_composition M k 3
  · intro ⟨i, hi⟩
    match i, hi with
    | 0, _ => simp [Fin.cons]; exact h_y
    | 1, _ => simp [Fin.cons]; exact h_x
    | 2, _ => simp [Fin.cons]; exact h_t
  · intro i j h_ne
    exact h_ord i j h_ne

end Bimodal.Metalogic.WeakCanonical.Kamp
