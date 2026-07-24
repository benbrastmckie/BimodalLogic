import Bimodal.Metalogic.WeakCanonical.Kamp.NfComposition
import Bimodal.Metalogic.WeakCanonical.PriorDefs

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Cross-Structure Composition for Normal Forms

Composition theorems that combine 1-var NF agreement at individual
elements into multi-var NF agreement.

## Main Results

- `pred_agree_cross` : predicate agreement from cross-structure 1-var NF agreement
- `cross_1var_from_2var` : extract 1-var from 2-var cross-structure agreement
- `cross_extend_fwd_1var` / `cross_extend_bwd_1var` : extend cross-structure
  1-var agreement to 2-var (with depth drop)
- `exist_transfer_nvar_constenv` : transfer (n+1)-var existentials on constant envs
- `constenv_same_depth_2var` : same-depth 2-var agreement on constant envs

## References

- NfComposition.lean (nf_drop_last_cross, constenv_2var_determines)
- KampBypass.lean (sorry sites at lines 356, 368)
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Metalogic.WeakCanonical

/-! ## Helper Lemmas -/

/-- Extract predicate agreement from depth-(K+1) 1-var NF agreement. -/
theorem pred_agree_cross {sig : MonadicSignature}
    {K : Nat}
    (M : OrderedMonadicStructure sig) (a : M.carrier)
    (N : OrderedMonadicStructure sig) (b : N.carrier)
    (h : ∀ nf : NormalForm sig (K + 1) 1,
      nf_eval_nf M (K + 1) 1 (fun _ => a) nf ↔
      nf_eval_nf N (K + 1) 1 (fun _ => b) nf)
    (p : sig.preds) : M.interp p a ↔ N.interp p b := by
  have ha := atom_agreement_from_nf M (fun _ => a) N (fun _ => b) h (.pred p ⟨0, by omega⟩)
  simp only [atom_eval] at ha; exact ha

/-- Fin.cons on Fin 1 projection. -/
private theorem cons_castSucc_fin1 {α : Type*} (y : α) (f : Fin 1 → α) :
    (Fin.cons y f) ∘ Fin.castSucc = (fun _ : Fin 1 => y) :=
  funext (fun ⟨i, hi⟩ => by have : i = 0 := Nat.lt_one_iff.mp hi; subst this; rfl)

/-- On constant env (fun _ => t), atom_eval reduces to t-based evaluation.
    Specifically, Fin.cases t (fun _ => t) i = t for all i : Fin n. -/
private theorem fin_cases_const {α : Type*} (t : α) {n : Nat} (i : Fin (n + 1)) :
    Fin.cases t (fun _ => t) i = t := by
  refine Fin.cases rfl (fun _ => rfl) i

/-! ## Cross-Structure 1-var from 2-var -/

/-- Drop last from 2-var cross-structure agreement gives 1-var agreement. -/
theorem cross_1var_from_2var {sig : MonadicSignature}
    {K : Nat}
    (M : OrderedMonadicStructure sig) (y : M.carrier) (t : M.carrier)
    (N : OrderedMonadicStructure sig) (y' : N.carrier) (s : N.carrier)
    (h : ∀ nf : NormalForm sig K 2,
      nf_eval_nf M K 2 (Fin.cons y (fun _ => t)) nf ↔
      nf_eval_nf N K 2 (Fin.cons y' (fun _ => s)) nf) :
    ∀ nf1 : NormalForm sig K 1,
      nf_eval_nf M K 1 (fun _ => y) nf1 ↔
      nf_eval_nf N K 1 (fun _ => y') nf1 := by
  intro nf1
  have h_drop := nf_drop_last_cross M N K 1
    (Fin.cons y (fun _ => t)) (Fin.cons y' (fun _ => s)) h nf1
  rwa [cons_castSucc_fin1, cons_castSucc_fin1] at h_drop

/-! ## Cross-Structure Extend (Depth Drop) -/

/-- From depth-(K+1) 1-var at t/s, for any x' in N there exists x in M
    with depth-K 2-var at [x,t]/[x',s]. -/
theorem cross_extend_fwd_1var {sig : MonadicSignature}
    {K : Nat}
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (N : OrderedMonadicStructure sig) (s : N.carrier)
    (h_t : ∀ nf : NormalForm sig (K + 1) 1,
      nf_eval_nf M (K + 1) 1 (fun _ => t) nf ↔
      nf_eval_nf N (K + 1) 1 (fun _ => s) nf)
    (x' : N.carrier) :
    ∃ x : M.carrier, ∀ nf : NormalForm sig K 2,
      nf_eval_nf M K 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N K 2 (Fin.cons x' (fun _ => s)) nf := by
  have hM := nf_characteristic_satisfies M (K + 1) 1 (fun _ => t)
  have hN := nf_characteristic_satisfies N (K + 1) 1 (fun _ => s)
  have heq := nf_eval_unique N (K + 1) 1 _ _ _ ((h_t _).mp hM) hN
  obtain ⟨_, hMq⟩ := hM; obtain ⟨_, hNq⟩ := heq ▸ hN
  set ch := nf_characteristic N K 2 (Fin.cons x' (fun _ => s))
  obtain ⟨x, hx⟩ := ((hMq ch).trans (hNq ch).symm).mpr
    ⟨x', nf_characteristic_satisfies ..⟩
  exact ⟨x, nf_agreement_from_shared_nf _ _ _ _ ch hx (nf_characteristic_satisfies ..)⟩

/-- Symmetric: for any x in M, find x' in N. -/
theorem cross_extend_bwd_1var {sig : MonadicSignature}
    {K : Nat}
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (N : OrderedMonadicStructure sig) (s : N.carrier)
    (h_t : ∀ nf : NormalForm sig (K + 1) 1,
      nf_eval_nf M (K + 1) 1 (fun _ => t) nf ↔
      nf_eval_nf N (K + 1) 1 (fun _ => s) nf)
    (x : M.carrier) :
    ∃ x' : N.carrier, ∀ nf : NormalForm sig K 2,
      nf_eval_nf M K 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N K 2 (Fin.cons x' (fun _ => s)) nf := by
  have hM := nf_characteristic_satisfies M (K + 1) 1 (fun _ => t)
  have hN := nf_characteristic_satisfies N (K + 1) 1 (fun _ => s)
  have heq := nf_eval_unique N (K + 1) 1 _ _ _ ((h_t _).mp hM) hN
  obtain ⟨_, hMq⟩ := hM; obtain ⟨_, hNq⟩ := heq ▸ hN
  set ch := nf_characteristic M K 2 (Fin.cons x (fun _ => t))
  obtain ⟨x', hx'⟩ := ((hMq ch).trans (hNq ch).symm).mp
    ⟨x, nf_characteristic_satisfies ..⟩
  exact ⟨x', nf_agreement_from_shared_nf _ _ _ _ ch (nf_characteristic_satisfies ..) hx'⟩

/-! ## Existential Transfer on Constant Environments -/

/-- Transfer (n+1)-var existentials on constant environments:
    from depth-(K+1) 1-var agreement at t/s, transfer
    `(∃ y, nf_eval M K (n+1) [y, t, ..., t] ssn)` between M and N. -/
theorem exist_transfer_nvar_constenv {sig : MonadicSignature}
    {K : Nat}
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (N : OrderedMonadicStructure sig) (s : N.carrier)
    (h_agree : ∀ nf : NormalForm sig (K + 1) 1,
      nf_eval_nf M (K + 1) 1 (fun _ => t) nf ↔
      nf_eval_nf N (K + 1) 1 (fun _ => s) nf)
    (n : Nat) (ssn : NormalForm sig K (n + 1)) :
    (∃ y : M.carrier, nf_eval_nf M K (n + 1) (Fin.cons y (fun _ => t)) ssn) ↔
    (∃ y : N.carrier, nf_eval_nf N K (n + 1) (Fin.cons y (fun _ => s)) ssn) := by
  constructor
  · rintro ⟨y, hy⟩
    obtain ⟨y', hy'⟩ := cross_extend_bwd_1var M t N s h_agree y
    exact ⟨y', (constenv_2var_determines M N K n y t y' s hy' ssn).mp hy⟩
  · rintro ⟨y', hy'⟩
    obtain ⟨y, hy⟩ := cross_extend_fwd_1var M t N s h_agree y'
    exact ⟨y, (constenv_2var_determines M N K n y t y' s hy ssn).mpr hy'⟩

/-! ## Same-Depth Composition on Constant Environments

On constant environments [t, t], depth-(K+1) 1-var agreement at t/s
gives depth-(K+1) 2-var agreement at [t,t]/[s,s].

This works because the quantifier conditions reduce to constant-env
existential transfers. -/

/-- Same-depth 2-var NF agreement on constant envs: from depth-(K+1)
    1-var NF agreement at t/s, derive depth-(K+1) 2-var NF agreement
    at [t,t]/[s,s]. -/
theorem constenv_same_depth_2var {sig : MonadicSignature}
    (K : Nat)
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (N : OrderedMonadicStructure sig) (s : N.carrier)
    (h_t : ∀ nf : NormalForm sig (K + 1) 1,
      nf_eval_nf M (K + 1) 1 (fun _ => t) nf ↔
      nf_eval_nf N (K + 1) 1 (fun _ => s) nf)
    (nf : NormalForm sig (K + 1) 2) :
    nf_eval_nf M (K + 1) 2 (Fin.cons t (fun _ => t)) nf ↔
    nf_eval_nf N (K + 1) 2 (Fin.cons s (fun _ => s)) nf := by
  -- Atom agreement on constant envs
  have h_atom_agree : ∀ (a : AtomKind sig 2),
      atom_eval M (Fin.cons t (fun _ => t)) a ↔
      atom_eval N (Fin.cons s (fun _ => s)) a := by
    intro a; cases a with
    | pred p i =>
      simp only [atom_eval, Fin.cons]
      rw [fin_cases_const t i, fin_cases_const s i]
      exact pred_agree_cross M t N s h_t p
    | order i j hne =>
      simp only [atom_eval, Fin.cons]
      rw [fin_cases_const t i, fin_cases_const t j,
          fin_cases_const s i, fin_cases_const s j]
      exact Iff.intro (fun h => absurd h (lt_irrefl _)) (fun h => absurd h (lt_irrefl _))
  -- Env equivalence: Fin.cons y (Fin.cons t (fun _ => t)) = Fin.cons y (fun _ => t)
  have h_env_M : ∀ y : M.carrier,
      (Fin.cons y (Fin.cons t (fun _ => t)) : Fin 3 → M.carrier) =
      Fin.cons y (fun _ => t) := by
    intro y; funext ⟨i, _⟩; match i with | 0 => rfl | 1 => rfl | 2 => rfl
  have h_env_N : ∀ y : N.carrier,
      (Fin.cons y (Fin.cons s (fun _ => s)) : Fin 3 → N.carrier) =
      Fin.cons y (fun _ => s) := by
    intro y; funext ⟨i, _⟩; match i with | 0 => rfl | 1 => rfl | 2 => rfl
  -- Show M,[t,t] satisfies char NF of N,[s,s]
  set target := nf_characteristic N (K + 1) 2 (Fin.cons s (fun _ => s))
  have h_N_sat := nf_characteristic_satisfies N (K + 1) 2 (Fin.cons s (fun _ => s))
  suffices h_M_sat : nf_eval_nf M (K + 1) 2 (Fin.cons t (fun _ => t)) target by
    exact nf_agreement_from_shared_nf M _ N _ target h_M_sat h_N_sat nf
  obtain ⟨h_N_atoms, h_N_quant⟩ := h_N_sat
  constructor
  · intro a; exact (h_atom_agree a).trans (h_N_atoms a)
  · intro sub_nf3
    rw [← h_N_quant sub_nf3]
    simp only [h_env_M, h_env_N]
    exact exist_transfer_nvar_constenv M t N s h_t 2 sub_nf3

/-! ## Same-Depth Composition on Constant Envs (General Arity) -/

/-- Same-depth n-var NF agreement on constant envs from 1-var agreement. -/
theorem constenv_same_depth_nvar {sig : MonadicSignature}
    (K n : Nat)
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (N : OrderedMonadicStructure sig) (s : N.carrier)
    (h_t : ∀ nf : NormalForm sig (K + 1) 1,
      nf_eval_nf M (K + 1) 1 (fun _ => t) nf ↔
      nf_eval_nf N (K + 1) 1 (fun _ => s) nf) :
    ∀ nf : NormalForm sig (K + 1) (n + 1),
      nf_eval_nf M (K + 1) (n + 1) (Fin.cons t (fun _ => t)) nf ↔
      nf_eval_nf N (K + 1) (n + 1) (Fin.cons s (fun _ => s)) nf :=
  constenv_2var_determines M N (K + 1) n t t s s
    (constenv_same_depth_2var K M t N s h_t)

end Bimodal.Metalogic.WeakCanonical.Kamp
