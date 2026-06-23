import Bimodal.Metalogic.WeakCanonical.Kamp.KampBypassEqCase
import Bimodal.Metalogic.WeakCanonical.Kamp.KampBypassUntil
import Bimodal.Metalogic.WeakCanonical.Kamp.KampBypassSince
import Bimodal.Metalogic.WeakCanonical.Kamp.KampComposition
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEATranslation
import Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition

/-!
# Enriched Bypass Formula: Main Theorems

Main bypass theorems that dispatch to the three direction-specific proofs.
See KampBypassCore.lean for shared definitions and equality case, and KampBypassUntil/Since.lean
for the direction-specific correctness proofs.

Factored from a single 4488-line file for modularity.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5
- VecEADecomp.lean (depth-0 3-var zone decomposition)
- NfToVecEA.lean (depth-0 2-var bridge)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (formula_disjList formula_disjList_iff
  formula_conjList formula_conjList_iff)

/-! ## Cross-Structure NF Transfer -/

/-- Given depth-(K+1) NF agreement between two structures at arity r,
    and an element c' in N, find an element c in M such that all
    depth-K arity-(r+1) NFs agree on the extended environments. -/
private theorem nf_extend_fwd {sig : MonadicSignature}
    {K r : Nat}
    (M : OrderedMonadicStructure sig) (eM : Fin r → M.carrier)
    (N : OrderedMonadicStructure sig) (eN : Fin r → N.carrier)
    (h : ∀ nf : NormalForm sig (K + 1) r,
      nf_eval_nf M (K + 1) r eM nf ↔ nf_eval_nf N (K + 1) r eN nf)
    (c' : N.carrier) :
    ∃ c : M.carrier, ∀ nf : NormalForm sig K (r + 1),
      nf_eval_nf M K (r + 1) (Fin.cons c eM) nf ↔
      nf_eval_nf N K (r + 1) (Fin.cons c' eN) nf := by
  have hM := nf_characteristic_satisfies M (K + 1) r eM
  have hN := nf_characteristic_satisfies N (K + 1) r eN
  have heq := nf_eval_unique N (K + 1) r eN _ _ ((h _).mp hM) hN
  obtain ⟨_, hMq⟩ := hM; obtain ⟨_, hNq⟩ := heq ▸ hN
  set ch := nf_characteristic N K (r + 1) (Fin.cons c' eN)
  obtain ⟨c, hc⟩ := ((hMq ch).trans (hNq ch).symm).mpr
    ⟨c', nf_characteristic_satisfies ..⟩
  exact ⟨c, nf_agreement_from_shared_nf _ _ _ _ ch hc
    (nf_characteristic_satisfies ..)⟩

/-- Symmetric version: find c' given c. -/
private theorem nf_extend_bwd {sig : MonadicSignature}
    {K r : Nat}
    (M : OrderedMonadicStructure sig) (eM : Fin r → M.carrier)
    (N : OrderedMonadicStructure sig) (eN : Fin r → N.carrier)
    (h : ∀ nf : NormalForm sig (K + 1) r,
      nf_eval_nf M (K + 1) r eM nf ↔ nf_eval_nf N (K + 1) r eN nf)
    (c : M.carrier) :
    ∃ c' : N.carrier, ∀ nf : NormalForm sig K (r + 1),
      nf_eval_nf M K (r + 1) (Fin.cons c eM) nf ↔
      nf_eval_nf N K (r + 1) (Fin.cons c' eN) nf := by
  have hM := nf_characteristic_satisfies M (K + 1) r eM
  have hN := nf_characteristic_satisfies N (K + 1) r eN
  have heq := nf_eval_unique N (K + 1) r eN _ _ ((h _).mp hM) hN
  obtain ⟨_, hMq⟩ := hM; obtain ⟨_, hNq⟩ := heq ▸ hN
  set ch := nf_characteristic M K (r + 1) (Fin.cons c eM)
  obtain ⟨c', hc'⟩ := ((hMq ch).trans (hNq ch).symm).mp
    ⟨c, nf_characteristic_satisfies ..⟩
  exact ⟨c', nf_agreement_from_shared_nf _ _ _ _ ch
    (nf_characteristic_satisfies ..) hc'⟩

/-- From depth-(K+1) arity-1 NF agreement on constant environments,
    transfer existential conditions: if ∃ y in N, then ∃ y in M
    with the same depth-K arity-2 NF type. -/
private theorem exist_transfer_const_env {sig : MonadicSignature}
    {K : Nat}
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (N : OrderedMonadicStructure sig) (s : N.carrier)
    (h_agree : ∀ nf : NormalForm sig (K + 1) 1,
      nf_eval_nf M (K + 1) 1 (fun _ => t) nf ↔ nf_eval_nf N (K + 1) 1 (fun _ => s) nf)
    (ssn : NormalForm sig K 2) :
    (∃ y : M.carrier, nf_eval_nf M K 2 (Fin.cons y (fun _ => t)) ssn) ↔
    (∃ y : N.carrier, nf_eval_nf N K 2 (Fin.cons y (fun _ => s)) ssn) := by
  constructor
  · rintro ⟨y, hy⟩
    obtain ⟨y', hy'⟩ := nf_extend_bwd M (fun _ => t) N (fun _ => s) h_agree y
    exact ⟨y', (hy' ssn).mp hy⟩
  · rintro ⟨y', hy'⟩
    obtain ⟨y, hy⟩ := nf_extend_fwd M (fun _ => t) N (fun _ => s) h_agree y'
    exact ⟨y, (hy ssn).mpr hy'⟩

/-! ## Index-Skipping Projection for Cross-Structure NF Transfer -/

/-- Index-skipping injection: maps `Fin n` into `Fin (n + 1)` by skipping index `j`.
    For `i < j`, sends `i` to itself (via `castSucc`); for `i ≥ j`, sends `i` to `i + 1`
    (via `succ`). When `j = 0`, this is `Fin.succ`. When `j = n`, this is `Fin.castSucc`. -/
private def skipIdx (j : Nat) {n : Nat} : Fin n → Fin (n + 1) := fun i =>
  if i.val < j then i.castSucc else i.succ

/-- `skipIdx` commutes with `Fin.succ`: `skipIdx (j+1) (succ i) = succ (skipIdx j i)`. -/
private theorem skipIdx_succ_comm {n : Nat} (j : Nat) (i : Fin n) :
    skipIdx (j + 1) i.succ = (skipIdx j i).succ := by
  ext; simp only [skipIdx, Fin.succ, Fin.castSucc, Fin.castAdd, Fin.val_mk]
  split <;> split <;> rename_i h1 h2 <;> first | rfl | omega

/-- `skipIdx j` is injective. -/
private theorem skipIdx_injective {n : Nat} (j : Nat) (i₁ i₂ : Fin n)
    (h : skipIdx j i₁ = skipIdx j i₂) : i₁ = i₂ := by
  simp only [skipIdx, Fin.ext_iff] at h; ext
  split at h <;> split at h <;> simp [Fin.castSucc, Fin.succ, Fin.castAdd] at h <;> omega

/-- Key commutation: `Fin.cons y (env ∘ skipIdx j) = (Fin.cons y env) ∘ skipIdx (j + 1)`.
    This is what makes the induction on k work for the quantifier step of
    `nf_skipIdx_cross`. -/
private theorem cons_comp_skipIdx {α : Type*} {n : Nat} (j : Nat)
    (y : α) (env : Fin (n + 1) → α) :
    Fin.cons y (env ∘ skipIdx j) = (Fin.cons y env) ∘ skipIdx (j + 1) := by
  funext ⟨i, hi⟩; cases i with
  | zero => rfl
  | succ i =>
    change env (skipIdx j ⟨i, by omega⟩) =
      (Fin.cons y env : Fin (n + 2) → α) (skipIdx (j + 1) ⟨i + 1, hi⟩)
    have : (⟨i + 1, hi⟩ : Fin (n + 1)) = (⟨i, (by omega : i < n)⟩ : Fin n).succ := by
      ext; simp [Fin.succ]
    rw [this, skipIdx_succ_comm, Fin.cons_succ]

/-- Cross-structure projection along `skipIdx j`: if two environments in different
    structures agree on all depth-k (n+1)-var NFs, then the projected environments
    (via `skipIdx j`) agree on all depth-k n-var NFs.

    Generalizes `nf_drop_last_cross` (which is the `j = n` case via `castSucc`). -/
private theorem nf_skipIdx_cross {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (N : OrderedMonadicStructure sig) :
    ∀ (k n : Nat) (j : Nat)
    (envM : Fin (n + 1) → M.carrier) (envN : Fin (n + 1) → N.carrier)
    (h : ∀ nf, nf_eval_nf M k (n + 1) envM nf ↔ nf_eval_nf N k (n + 1) envN nf),
    ∀ nf, nf_eval_nf M k n (envM ∘ skipIdx j) nf ↔
          nf_eval_nf N k n (envN ∘ skipIdx j) nf := by
  intro k; induction k with
  | zero =>
    intro n j envM envN h nf
    have h_atom := atom_agreement_from_nf M envM N envN h
    simp only [nf_eval_nf]
    constructor <;> intro hDir a
    · cases a with
      | pred p i =>
        simp only [atom_eval, Function.comp] at hDir ⊢
        exact (h_atom (.pred p (skipIdx j i))).symm.trans (hDir (.pred p i))
      | order i₁ i₂ hne =>
        simp only [atom_eval, Function.comp] at hDir ⊢
        exact (h_atom (.order _ _ (fun heq => hne (skipIdx_injective j i₁ i₂ heq)))).symm.trans
          (hDir (.order i₁ i₂ hne))
    · cases a with
      | pred p i =>
        simp only [atom_eval, Function.comp] at hDir ⊢
        exact (h_atom (.pred p (skipIdx j i))).trans (hDir (.pred p i))
      | order i₁ i₂ hne =>
        simp only [atom_eval, Function.comp] at hDir ⊢
        exact (h_atom (.order _ _ (fun heq => hne (skipIdx_injective j i₁ i₂ heq)))).trans
          (hDir (.order i₁ i₂ hne))
  | succ k ih =>
    intro n j envM envN h nf
    have h_atom := atom_agreement_from_nf M envM N envN h
    obtain ⟨_, hMq⟩ := nf_characteristic_satisfies M (k + 1) (n + 1) envM
    have h_char_eq := nf_eval_unique N (k + 1) (n + 1) _ _ _
      ((h _).mp (nf_characteristic_satisfies M (k + 1) (n + 1) _))
      (nf_characteristic_satisfies N (k + 1) (n + 1) _)
    obtain ⟨_, hNq⟩ := h_char_eq ▸ nf_characteristic_satisfies N (k + 1) (n + 1) envN
    have hex : ∀ chi : NormalForm sig k (n + 2),
        (∃ z, nf_eval_nf M k (n + 2) (Fin.cons z envM) chi) ↔
        (∃ z, nf_eval_nf N k (n + 2) (Fin.cons z envN) chi) :=
      fun chi => (hMq chi).trans (hNq chi).symm
    set tgt := nf_characteristic N (k + 1) n (envN ∘ skipIdx j)
    have h_N_sat := nf_characteristic_satisfies N (k + 1) n (envN ∘ skipIdx j)
    suffices nf_eval_nf M (k + 1) n (envM ∘ skipIdx j) tgt by
      exact nf_agreement_from_shared_nf M _ N _ tgt this h_N_sat nf
    obtain ⟨h_N_atoms, h_N_quant⟩ := h_N_sat
    refine ⟨fun a => ?_, fun sub_nf => ?_⟩
    · -- Atoms
      cases a with
      | pred p i =>
        simp only [atom_eval, Function.comp] at h_atom ⊢
        exact (h_atom (.pred p (skipIdx j i))).trans (h_N_atoms (.pred p i))
      | order i₁ i₂ hne =>
        simp only [atom_eval, Function.comp] at h_atom ⊢
        exact (h_atom (.order _ _ (fun heq => hne (skipIdx_injective j i₁ i₂ heq)))).trans
          (h_N_atoms (.order i₁ i₂ hne))
    · -- Quantifiers
      rw [← h_N_quant sub_nf]; constructor
      · rintro ⟨z, hz⟩
        rw [cons_comp_skipIdx] at hz
        obtain ⟨z', hz'⟩ := (hex _).mp ⟨z, nf_characteristic_satisfies M k (n + 2) (Fin.cons z envM)⟩
        have := ih (n + 1) (j + 1) (Fin.cons z envM) (Fin.cons z' envN)
          (nf_agreement_from_shared_nf M _ N _ _ (nf_characteristic_satisfies ..) hz') sub_nf
        rw [← cons_comp_skipIdx, ← cons_comp_skipIdx] at this
        exact ⟨z', this.mp (by rwa [← cons_comp_skipIdx] at hz)⟩
      · rintro ⟨z', hz'⟩
        rw [cons_comp_skipIdx] at hz'
        obtain ⟨z, hz⟩ := (hex _).mpr ⟨z', nf_characteristic_satisfies N k (n + 2) (Fin.cons z' envN)⟩
        have := ih (n + 1) (j + 1) (Fin.cons z envM) (Fin.cons z' envN)
          (nf_agreement_from_shared_nf M _ N _ _ hz (nf_characteristic_satisfies ..)) sub_nf
        rw [← cons_comp_skipIdx, ← cons_comp_skipIdx] at this
        exact ⟨z, this.mpr (by rwa [← cons_comp_skipIdx] at hz')⟩

/-- On `Fin.cons x (fun _ => t)` envs, composing with `skipIdx 0` gives `(fun _ => t)`.
    This is because `skipIdx 0` sends every `i` to `i.succ` (since `i.val ≥ 0` always),
    and `Fin.cons x f ∘ Fin.succ = f`. -/
private theorem cons_comp_skipIdx_zero {α : Type*} {n : Nat} (x : α) (f : Fin n → α) :
    (Fin.cons x f) ∘ skipIdx 0 = f := by
  ext ⟨i, hi⟩
  simp only [Function.comp, skipIdx, show ¬(i < 0) from not_lt.mpr (Nat.zero_le i), ↓reduceIte]
  rfl

/-- Cross-structure second-component 1-var NF extraction from 2-var NF sharing.
    If M,[x,t] and N,[x',t'] both satisfy sub_nf, then t and t' have the
    same depth-k 1-var NF. Proved via `nf_skipIdx_cross` at j=0. -/
private theorem cross_2nd_1var_from_shared_nf {sig : MonadicSignature}
    {K : Nat}
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (sub_nf : NormalForm sig K 2)
    (hM : nf_eval_nf M K 2 (Fin.cons x (fun _ => t)) sub_nf)
    (hN : nf_eval_nf N K 2 (Fin.cons x' (fun _ => t')) sub_nf) :
    ∀ nf1 : NormalForm sig K 1,
      nf_eval_nf M K 1 (fun _ => t) nf1 ↔
      nf_eval_nf N K 1 (fun _ => t') nf1 := by
  have h_agree := nf_agreement_from_shared_nf M _ N _ sub_nf hM hN
  intro nf1
  have h_proj := nf_skipIdx_cross M N K 1 0
    (Fin.cons x (fun _ => t)) (Fin.cons x' (fun _ => t')) h_agree nf1
  rwa [cons_comp_skipIdx_zero, cons_comp_skipIdx_zero] at h_proj

/-! ## Non-Constant Environment Atom Agreement

These helpers transfer atom agreement on 2-var non-constant environments from
cross-structure 1-var NF agreement plus matching orders. Moved from PriorComposition.lean
(whose theorems are FALSE) — the atom agreement lemmas are still correct. -/

/-- Atom agreement on non-constant 2-var envs from 1-var agreement + order (Until zone: t < x). -/
private theorem nonconstenv_atom_agree_until {sig : MonadicSignature}
    {K : Nat}
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_x : ∀ nf : NormalForm sig (K + 1) 1,
      nf_eval_nf M (K + 1) 1 (fun _ => x) nf ↔
      nf_eval_nf N (K + 1) 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig (K + 1) 1,
      nf_eval_nf M (K + 1) 1 (fun _ => t) nf ↔
      nf_eval_nf N (K + 1) 1 (fun _ => t') nf)
    (h_order_M : t < x)
    (h_order_N : t' < x') :
    ∀ (a : AtomKind sig 2),
      atom_eval M (Fin.cons x (fun _ => t)) a ↔
      atom_eval N (Fin.cons x' (fun _ => t')) a := by
  intro a; cases a with
  | pred p i =>
    simp only [atom_eval]
    refine Fin.cases ?_ (fun j => ?_) i
    · simp only [Fin.cons_zero]; exact pred_agree_cross M x N x' h_x p
    · simp only [Fin.cons_succ]; exact pred_agree_cross M t N t' h_t p
  | order i j hne =>
    simp only [atom_eval]
    refine Fin.cases ?_ (fun i' => ?_) i <;> refine Fin.cases ?_ (fun j' => ?_) j
    · exact iff_of_false (lt_irrefl _) (lt_irrefl _)
    · simp only [Fin.cons_zero, Fin.cons_succ]
      exact iff_of_false (not_lt.mpr (le_of_lt h_order_M)) (not_lt.mpr (le_of_lt h_order_N))
    · simp only [Fin.cons_zero, Fin.cons_succ]
      exact Iff.intro (fun _ => h_order_N) (fun _ => h_order_M)
    · simp only [Fin.cons_succ]
      exact iff_of_false (lt_irrefl _) (lt_irrefl _)

/-- Atom agreement for the Since zone (x < t). -/
private theorem nonconstenv_atom_agree_since {sig : MonadicSignature}
    {K : Nat}
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_x : ∀ nf : NormalForm sig (K + 1) 1,
      nf_eval_nf M (K + 1) 1 (fun _ => x) nf ↔
      nf_eval_nf N (K + 1) 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig (K + 1) 1,
      nf_eval_nf M (K + 1) 1 (fun _ => t) nf ↔
      nf_eval_nf N (K + 1) 1 (fun _ => t') nf)
    (h_order_M : x < t)
    (h_order_N : x' < t') :
    ∀ (a : AtomKind sig 2),
      atom_eval M (Fin.cons x (fun _ => t)) a ↔
      atom_eval N (Fin.cons x' (fun _ => t')) a := by
  intro a; cases a with
  | pred p i =>
    simp only [atom_eval]
    refine Fin.cases ?_ (fun j => ?_) i
    · simp only [Fin.cons_zero]; exact pred_agree_cross M x N x' h_x p
    · simp only [Fin.cons_succ]; exact pred_agree_cross M t N t' h_t p
  | order i j hne =>
    simp only [atom_eval]
    refine Fin.cases ?_ (fun i' => ?_) i <;> refine Fin.cases ?_ (fun j' => ?_) j
    · exact iff_of_false (lt_irrefl _) (lt_irrefl _)
    · simp only [Fin.cons_zero, Fin.cons_succ]
      exact Iff.intro (fun _ => h_order_N) (fun _ => h_order_M)
    · simp only [Fin.cons_zero, Fin.cons_succ]
      exact iff_of_false (not_lt.mpr (le_of_lt h_order_M)) (not_lt.mpr (le_of_lt h_order_N))
    · simp only [Fin.cons_succ]
      exact iff_of_false (lt_irrefl _) (lt_irrefl _)

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

private theorem const_env_atom_agree {sig : MonadicSignature}
    {k' : Nat}
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (M₀ : OrderedMonadicStructure sig) (t₀ : M₀.carrier)
    (sub_nf : NormalForm sig (k' + 1 + 1) 2)
    (h_eval₀ : nf_eval_nf M₀ (k' + 1 + 1) (1 + 1) (Fin.cons t₀ (fun _ => t₀)) sub_nf)
    (nf_x : NormalForm sig (k' + 1 + 1) 1)
    (h_nf_x_eval : nf_eval_nf M (k' + 1 + 1) 1 (fun _ => t) nf_x)
    (h_nf_x_compat : ∀ p, nf_x.1 (.pred p ⟨0, by omega⟩) = sub_nf.1 (.pred p ⟨0, by omega⟩)) :
    ∀ (a : AtomKind sig (1 + 1)),
      atom_eval M (Fin.cons t (fun _ => t)) a ↔ sub_nf.1 a = true := by
  obtain ⟨h_atom₀, _⟩ := h_eval₀
  obtain ⟨h_nf_x_atom, _⟩ := h_nf_x_eval
  intro a
  match a with
  | .pred p i =>
    simp only [atom_eval, Fin.cons]
    have h_i_eq : Fin.cases t (fun _ => t) i = t := by refine Fin.cases rfl (fun _ => rfl) i
    rw [h_i_eq]
    have h_pred_x := h_nf_x_atom (.pred p ⟨0, by omega⟩)
    simp only [atom_eval] at h_pred_x
    have h_const : sub_nf.1 (.pred p i) = sub_nf.1 (.pred p ⟨0, by omega⟩) := by
      have h0 := h_atom₀ (.pred p ⟨0, by omega⟩)
      have hi := h_atom₀ (.pred p i)
      simp only [atom_eval, Fin.cons] at h0 hi
      have : Fin.cases t₀ (fun _ => t₀) i = t₀ := by refine Fin.cases rfl (fun _ => rfl) i
      rw [this] at hi
      have h0' : Fin.cases t₀ (fun _ => t₀) (⟨0, by omega⟩ : Fin (1 + 1)) = t₀ := rfl
      rw [h0'] at h0
      cases h_v : sub_nf.1 (.pred p i) <;> cases h_v0 : sub_nf.1 (.pred p ⟨0, by omega⟩)
      · rfl
      · rw [h_v] at hi; rw [h_v0] at h0; simp at hi; simp at h0; exact absurd h0 hi
      · rw [h_v] at hi; rw [h_v0] at h0; simp at hi; simp at h0; exact absurd hi h0
      · rfl
    rw [h_const, ← h_nf_x_compat p]; exact h_pred_x
  | .order i j h_ne =>
    have h_order₀ := h_atom₀ (.order i j h_ne)
    simp only [atom_eval, Fin.cons] at h_order₀
    have h_i_eq : Fin.cases t₀ (fun _ => t₀) i = t₀ := by refine Fin.cases rfl (fun _ => rfl) i
    have h_j_eq : Fin.cases t₀ (fun _ => t₀) j = t₀ := by refine Fin.cases rfl (fun _ => rfl) j
    rw [h_i_eq, h_j_eq] at h_order₀
    have h_false : sub_nf.1 (.order i j h_ne) = false := by
      by_contra h_eq
      push_neg at h_eq
      have h_true : sub_nf.1 (.order i j h_ne) = true := by
        cases sub_nf.1 (.order i j h_ne) <;> simp_all
      exact lt_irrefl _ (h_order₀.mpr h_true)
    simp only [atom_eval, h_false, Fin.cons]
    constructor
    · intro h_lt
      have h_i_eq' : Fin.cases t (fun _ => t) i = t := by refine Fin.cases rfl (fun _ => rfl) i
      have h_j_eq' : Fin.cases t (fun _ => t) j = t := by refine Fin.cases rfl (fun _ => rfl) j
      rw [h_i_eq', h_j_eq'] at h_lt
      exact absurd h_lt (lt_irrefl _)
    · intro h; exact Bool.noConfusion h

set_option maxHeartbeats 1600000 in
/-- General enriched bypass for ExistPart(k+1) at n=1.
    Delegates to existPart_succ_n1_bypass_k0 for k=0 and uses Prior composition
    transfer (prior_2var_transfer_until/since from PriorComposition.lean) for k>0. -/
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
    (ih_char : ∀ (nf_k : NormalForm sig k 1),
        ∃ (A : Formula),
          ∀ (M : OrderedMonadicStructure sig)
            (h_UZ : semantic_prior_UZ M atomMap)
            (h_SZ : semantic_prior_SZ M atomMap)
            (t : M.carrier),
            temporal_truth M atomMap t A ↔ nf_eval_nf M k 1 (fun _ => t) nf_k)
    (ih_exist : ∀ (n : Nat) (_ : n ≥ 1)
        (char_k : NormalForm sig k 1 → Formula)
        (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
            (M : OrderedMonadicStructure sig)
            (h_UZ : semantic_prior_UZ M atomMap)
            (h_SZ : semantic_prior_SZ M atomMap)
            (t : M.carrier),
            temporal_truth M atomMap t (char_k nf_k) ↔
            nf_eval_nf M k 1 (fun _ => t) nf_k)
        (parent_atoms' : AtomKind sig 1 → Bool)
        (sub_nf' : NormalForm sig k (n + 1)),
        ∃ (A : Formula),
          ∀ (M : OrderedMonadicStructure sig)
            (h_UZ : semantic_prior_UZ M atomMap)
            (h_SZ : semantic_prior_SZ M atomMap)
            (t : M.carrier),
            (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms' a = true) →
            (temporal_truth M atomMap t A ↔
             ∃ x : M.carrier, nf_eval_nf M k (n + 1) (Fin.cons x (fun _ => t)) sub_nf'))
    (ih_all_char : ∀ (d : Nat), d ≤ k →
        ∀ (nf_d : NormalForm sig d 1),
          ∃ (A : Formula),
            ∀ (M : OrderedMonadicStructure sig)
              (h_UZ : semantic_prior_UZ M atomMap)
              (h_SZ : semantic_prior_SZ M atomMap)
              (t : M.carrier),
              temporal_truth M atomMap t A ↔ nf_eval_nf M d 1 (fun _ => t) nf_d)
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
    · -- Satisfiable case: use M₀'s 2-var NF type to build formula
      -- M₀ witness NF types
      let nf_2₀ := nf_characteristic M₀ (k' + 1 + 1) 2 (Fin.cons x₀ (fun _ => t₀))
      have h_nf_2₀ := nf_characteristic_satisfies M₀ (k' + 1 + 1) 2
        (Fin.cons x₀ (fun _ => t₀))
      -- Key fact: nf_2₀ = sub_nf (M₀ witnesses unique NF)
      have h_nf_2₀_eq : nf_2₀ = sub_nf :=
        nf_eval_unique M₀ (k' + 1 + 1) 2 (Fin.cons x₀ (fun _ => t₀)) nf_2₀ sub_nf
          h_nf_2₀ h_eval₀
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
      -- BLOCKER: backward direction requires 2-var NF reconstruction from 1-var NF.
      -- 1-var NF agreement does NOT determine 2-var NF on constant environments.
      -- Closing requires enriched formula encoding quantifier conditions via ih_exist,
      -- or a Prior compositionality theorem (Rabinovich Lemma 5.1).
      -- Construct depth-(k'+1) CharPart from ih_char for Prior composition transfer
      let char_k := fun nf_k : NormalForm sig (k' + 1) 1 => (ih_char nf_k).choose
      have char_k_correct : ∀ (nf_k : NormalForm sig (k' + 1) 1)
          (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t (char_k nf_k) ↔
          nf_eval_nf M (k' + 1) 1 (fun _ => t) nf_k :=
        fun nf_k => (ih_char nf_k).choose_spec
      -- Construct multi-depth char from ih_all_char for Prior composition transfer
      -- ih_all_char gives char at d ≤ k = k'+1; use default for d > k'+1
      let char_all_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula :=
        fun d nf_d =>
          if h : d ≤ k' + 1 then (ih_all_char d h nf_d).choose
          else Formula.bot  -- never used (char_correct has bound d ≤ k'+1)
      have char_all_correct : ∀ (d : Nat) (_ : d ≤ k' + 1) (nf_d : NormalForm sig d 1)
          (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t (char_all_fn d nf_d) ↔
          nf_eval_nf M d 1 (fun _ => t) nf_d := by
        intro d hd nf_d M h_UZ h_SZ t
        show temporal_truth M atomMap t (char_all_fn d nf_d) ↔ _
        simp only [char_all_fn, dif_pos hd]
        exact (ih_all_char d hd nf_d).choose_spec M h_UZ h_SZ t
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
        -- Until zone (t < x): Prior composition transfer.
        -- Formula: (char_kp1 nf_t₀) ∧ ((char_kp1 nf_x₀) U top)
        -- Backward: extract x/t NF types → prior_2var_transfer_until
        -- Forward: project 2-var agreement to 1-var → char_kp1_correct
        -- Witness NF types from M₀
        let nf_x₀ := nf_characteristic M₀ (k' + 1 + 1) 1 (fun _ => x₀)
        let nf_t₀ := nf_characteristic M₀ (k' + 1 + 1) 1 (fun _ => t₀)
        -- Order on M₀ from zone_order + h_gt_val
        have h_t₀_lt_x₀ : t₀ < x₀ := (zone_order M₀ t₀ x₀ h_eval₀).1 h_gt_val
        -- Until formula: t must match nf_t₀, and some x > t must match nf_x₀
        let until_formula := Formula.and (char_kp1 nf_t₀) (Formula.untl (char_kp1 nf_x₀) Formula.top)
        refine ⟨until_formula, fun M h_UZ h_SZ t h_atoms => ?_⟩
        constructor
        · -- mp: temporal_truth M t until_formula → ∃ x, nf_eval_nf ...
          intro h_until
          rw [temporal_truth_and] at h_until
          obtain ⟨h_t_nf, h_untl⟩ := h_until
          -- Extract: t satisfies nf_t₀
          have h_t_eval : nf_eval_nf M (k' + 1 + 1) 1 (fun _ => t) nf_t₀ :=
            (char_kp1_correct nf_t₀ M h_UZ h_SZ t).mp h_t_nf
          -- Extract x from Until: ∃ x > t, temporal_truth M x (char_kp1 nf_x₀)
          change ∃ s, t < s ∧ temporal_truth M atomMap s (char_kp1 nf_x₀) ∧
            ∀ r, t < r → r < s → temporal_truth M atomMap r Formula.top at h_untl
          obtain ⟨x, h_t_lt_x, h_x_char, _⟩ := h_untl
          -- x satisfies nf_x₀
          have h_x_eval : nf_eval_nf M (k' + 1 + 1) 1 (fun _ => x) nf_x₀ :=
            (char_kp1_correct nf_x₀ M h_UZ h_SZ x).mp h_x_char
          -- Full 1-var NF agreement at x/x₀
          have h_x_agree : ∀ nf : NormalForm sig (k' + 1 + 1) 1,
              nf_eval_nf M (k' + 1 + 1) 1 (fun _ => x) nf ↔
              nf_eval_nf M₀ (k' + 1 + 1) 1 (fun _ => x₀) nf :=
            nf_agreement_from_shared_nf M _ M₀ _ nf_x₀ h_x_eval
              (nf_characteristic_satisfies M₀ (k' + 1 + 1) 1 (fun _ => x₀))
          -- Full 1-var NF agreement at t/t₀
          have h_t_agree : ∀ nf : NormalForm sig (k' + 1 + 1) 1,
              nf_eval_nf M (k' + 1 + 1) 1 (fun _ => t) nf ↔
              nf_eval_nf M₀ (k' + 1 + 1) 1 (fun _ => t₀) nf :=
            nf_agreement_from_shared_nf M _ M₀ _ nf_t₀ h_t_eval
              (nf_characteristic_satisfies M₀ (k' + 1 + 1) 1 (fun _ => t₀))
          -- Apply prior_2var_transfer_until to transfer h_eval₀ from M₀ to M
          exact ⟨x, prior_2var_transfer_until atomMap h_surj k' M x t M₀ x₀ t₀
            h_UZ h_SZ h_UZ₀ h_SZ₀ h_x_agree h_t_agree h_t_lt_x h_t₀_lt_x₀
            char_all_fn char_all_correct sub_nf h_eval₀⟩
        · -- mpr: ∃ x, nf_eval_nf ... → temporal_truth M t until_formula
          intro ⟨x, h_eval⟩
          have h_t_lt_x : t < x := (zone_order M t x h_eval).1 h_gt_val
          rw [temporal_truth_and]
          -- Get cross-structure 2-var agreement from shared NF
          have h_2var_agree := nf_agreement_from_shared_nf M _ M₀ _
            sub_nf h_eval h_eval₀
          -- Project first component: x agrees with x₀ on 1-var NFs
          have h_x_agree := cross_1var_from_2var M x t M₀ x₀ t₀ h_2var_agree
          -- Project second component (Prior-specific): t agrees with t₀
          have h_t_agree := prior_second_1var_from_2var_until atomMap k'
            M x t M₀ x₀ t₀ h_UZ h_SZ h_UZ₀ h_SZ₀ h_2var_agree h_t_lt_x h_t₀_lt_x₀
          constructor
          · -- char_kp1 nf_t₀ at t: t satisfies nf_t₀
            exact (char_kp1_correct nf_t₀ M h_UZ h_SZ t).mpr
              ((h_t_agree nf_t₀).mpr
                (nf_characteristic_satisfies M₀ (k' + 1 + 1) 1 (fun _ => t₀)))
          · -- (char_kp1 nf_x₀) U top at t: witness is x
            show ∃ s, t < s ∧ temporal_truth M atomMap s (char_kp1 nf_x₀) ∧
              ∀ r, t < r → r < s → temporal_truth M atomMap r Formula.top
            exact ⟨x, h_t_lt_x,
              (char_kp1_correct nf_x₀ M h_UZ h_SZ x).mpr
                ((h_x_agree nf_x₀).mpr
                  (nf_characteristic_satisfies M₀ (k' + 1 + 1) 1 (fun _ => x₀))),
              fun r _ _ => temporal_truth_top M atomMap r⟩
      | false, true =>
        -- Since zone (x < t): Mirror of Until zone using Prior composition.
        -- Formula: (char_kp1 nf_t₀) ∧ ((char_kp1 nf_x₀) S top)
        -- Witness NF types from M₀
        let nf_x₀ := nf_characteristic M₀ (k' + 1 + 1) 1 (fun _ => x₀)
        let nf_t₀ := nf_characteristic M₀ (k' + 1 + 1) 1 (fun _ => t₀)
        -- Order on M₀ from zone_order + h_lt_val
        have h_x₀_lt_t₀ : x₀ < t₀ := (zone_order M₀ t₀ x₀ h_eval₀).2 h_lt_val
        -- Since formula: t must match nf_t₀, and some x < t must match nf_x₀
        let since_formula := Formula.and (char_kp1 nf_t₀) (Formula.snce (char_kp1 nf_x₀) Formula.top)
        refine ⟨since_formula, fun M h_UZ h_SZ t h_atoms => ?_⟩
        constructor
        · -- mp: temporal_truth M t since_formula → ∃ x, nf_eval_nf ...
          intro h_since
          rw [temporal_truth_and] at h_since
          obtain ⟨h_t_nf, h_snce⟩ := h_since
          -- Extract: t satisfies nf_t₀
          have h_t_eval : nf_eval_nf M (k' + 1 + 1) 1 (fun _ => t) nf_t₀ :=
            (char_kp1_correct nf_t₀ M h_UZ h_SZ t).mp h_t_nf
          -- Extract x from Since: ∃ x < t, temporal_truth M x (char_kp1 nf_x₀)
          change ∃ s, s < t ∧ temporal_truth M atomMap s (char_kp1 nf_x₀) ∧
            ∀ r, s < r → r < t → temporal_truth M atomMap r Formula.top at h_snce
          obtain ⟨x, h_x_lt_t, h_x_char, _⟩ := h_snce
          -- x satisfies nf_x₀
          have h_x_eval : nf_eval_nf M (k' + 1 + 1) 1 (fun _ => x) nf_x₀ :=
            (char_kp1_correct nf_x₀ M h_UZ h_SZ x).mp h_x_char
          -- Full 1-var NF agreement at x/x₀
          have h_x_agree : ∀ nf : NormalForm sig (k' + 1 + 1) 1,
              nf_eval_nf M (k' + 1 + 1) 1 (fun _ => x) nf ↔
              nf_eval_nf M₀ (k' + 1 + 1) 1 (fun _ => x₀) nf :=
            nf_agreement_from_shared_nf M _ M₀ _ nf_x₀ h_x_eval
              (nf_characteristic_satisfies M₀ (k' + 1 + 1) 1 (fun _ => x₀))
          -- Full 1-var NF agreement at t/t₀
          have h_t_agree : ∀ nf : NormalForm sig (k' + 1 + 1) 1,
              nf_eval_nf M (k' + 1 + 1) 1 (fun _ => t) nf ↔
              nf_eval_nf M₀ (k' + 1 + 1) 1 (fun _ => t₀) nf :=
            nf_agreement_from_shared_nf M _ M₀ _ nf_t₀ h_t_eval
              (nf_characteristic_satisfies M₀ (k' + 1 + 1) 1 (fun _ => t₀))
          -- Apply prior_2var_transfer_since to transfer h_eval₀ from M₀ to M
          exact ⟨x, prior_2var_transfer_since atomMap h_surj k' M x t M₀ x₀ t₀
            h_UZ h_SZ h_UZ₀ h_SZ₀ h_x_agree h_t_agree h_x_lt_t h_x₀_lt_t₀
            char_all_fn char_all_correct sub_nf h_eval₀⟩
        · -- mpr: ∃ x, nf_eval_nf ... → temporal_truth M t since_formula
          intro ⟨x, h_eval⟩
          have h_x_lt_t : x < t := (zone_order M t x h_eval).2 h_lt_val
          rw [temporal_truth_and]
          -- Get cross-structure 2-var agreement from shared NF
          have h_2var_agree := nf_agreement_from_shared_nf M _ M₀ _
            sub_nf h_eval h_eval₀
          -- Project first component: x agrees with x₀ on 1-var NFs
          have h_x_agree := cross_1var_from_2var M x t M₀ x₀ t₀ h_2var_agree
          -- Project second component (Prior-specific): t agrees with t₀
          have h_t_agree := prior_second_1var_from_2var_since atomMap k'
            M x t M₀ x₀ t₀ h_UZ h_SZ h_UZ₀ h_SZ₀ h_2var_agree h_x_lt_t h_x₀_lt_t₀
          constructor
          · -- char_kp1 nf_t₀ at t: t satisfies nf_t₀
            exact (char_kp1_correct nf_t₀ M h_UZ h_SZ t).mpr
              ((h_t_agree nf_t₀).mpr
                (nf_characteristic_satisfies M₀ (k' + 1 + 1) 1 (fun _ => t₀)))
          · -- (char_kp1 nf_x₀) S top at t: witness is x
            show ∃ s, s < t ∧ temporal_truth M atomMap s (char_kp1 nf_x₀) ∧
              ∀ r, s < r → r < t → temporal_truth M atomMap r Formula.top
            exact ⟨x, h_x_lt_t,
              (char_kp1_correct nf_x₀ M h_UZ h_SZ x).mpr
                ((h_x_agree nf_x₀).mpr
                  (nf_characteristic_satisfies M₀ (k' + 1 + 1) 1 (fun _ => x₀))),
              fun r _ _ => temporal_truth_top M atomMap r⟩
      | false, false =>
        -- Eq zone: x = t, so env is constant [t, t].
        -- Enriched formula: compat_disj ∧ conjunction encoding quantifier conditions
        -- via ih_exist at depth k'+1, arity 3.
        -- Build char_k from ih_char for use with ih_exist
        let char_k : NormalForm sig (k' + 1) 1 → Formula := fun nf_k => (ih_char nf_k).choose
        have char_k_correct : ∀ (nf_k : NormalForm sig (k' + 1) 1)
            (M' : OrderedMonadicStructure sig)
            (h_UZ' : semantic_prior_UZ M' atomMap)
            (h_SZ' : semantic_prior_SZ M' atomMap)
            (t' : M'.carrier),
            temporal_truth M' atomMap t' (char_k nf_k) ↔
            nf_eval_nf M' (k' + 1) 1 (fun _ => t') nf_k :=
          fun nf_k => (ih_char nf_k).choose_spec
        -- Build ih_exist formulas for each 3-var NF
        let ih_exist_formula : NormalForm sig (k' + 1) 3 → Formula := fun ssn =>
          (ih_exist 2 (by omega) char_k char_k_correct parent_atoms ssn).choose
        have ih_exist_correct : ∀ (ssn : NormalForm sig (k' + 1) 3)
            (M' : OrderedMonadicStructure sig)
            (h_UZ' : semantic_prior_UZ M' atomMap)
            (h_SZ' : semantic_prior_SZ M' atomMap)
            (t' : M'.carrier),
            (∀ (a : AtomKind sig 1), atom_eval M' (fun _ => t') a ↔ parent_atoms a = true) →
            (temporal_truth M' atomMap t' (ih_exist_formula ssn) ↔
             ∃ x, nf_eval_nf M' (k' + 1) (2 + 1) (Fin.cons x (fun _ => t')) ssn) :=
          fun ssn => (ih_exist 2 (by omega) char_k char_k_correct parent_atoms ssn).choose_spec
        -- Build the quantifier conjunction
        let quant_conj := formula_conjList
          ((Fintype.elems (α := NormalForm sig (k' + 1) 3)).val.toList.map fun ssn =>
            if sub_nf.2 ssn then ih_exist_formula ssn
            else (ih_exist_formula ssn).neg)
        -- Eq zone formula: compat_disj ∧ quant_conj
        let eq_formula := Formula.and compat_disj quant_conj
        -- Key: M₀ witness with x₀ = t₀ in the eq zone
        have h_x₀_eq := wit_eq M₀ t₀ x₀ h_gt_val h_lt_val h_eval₀
        -- Env equality: on const envs, Fin.cons y [t, t] = Fin.cons y [t, t]
        -- The nf_eval_nf goals use (1+1)+1 and 2+1 which are both 3
        -- We prove transfer between the two env forms
        have h_env_transfer : ∀ (M' : OrderedMonadicStructure sig) (t' : M'.carrier)
            (y : M'.carrier) (ssn : NormalForm sig (k' + 1) 3),
            nf_eval_nf M' (k' + 1) ((1+1)+1)
              (Fin.cons y (Fin.cons t' (fun _ => t'))) ssn ↔
            nf_eval_nf M' (k' + 1) (2+1) (Fin.cons y (fun _ => t')) ssn := by
          intro M' t' y ssn
          -- Both arities reduce to 3 and envs are extensionally equal
          show nf_eval_nf M' (k' + 1) 3 (Fin.cons y (Fin.cons t' (fun _ => t'))) ssn ↔
               nf_eval_nf M' (k' + 1) 3 (Fin.cons y (fun _ => t')) ssn
          have h_eq : (Fin.cons y (Fin.cons t' (fun _ => t')) : Fin 3 → M'.carrier) =
              Fin.cons y (fun _ => t') := by
            funext i
            match i with
            | ⟨0, _⟩ => rfl
            | ⟨1, _⟩ => rfl
            | ⟨2, _⟩ => rfl
          rw [h_eq]
        refine ⟨eq_formula, fun M h_UZ h_SZ t h_atoms => ?_⟩
        rw [temporal_truth_and]
        constructor
        · -- Backward: temporal → ∃ x
          intro ⟨h_compat, h_quant⟩
          -- Witness is x = t (forced by no-order condition)
          refine ⟨t, ?_⟩
          -- Need: nf_eval_nf M (k'+1+1) (1+1) (Fin.cons t (fun _ => t)) sub_nf
          -- M₀ satisfies sub_nf at [t₀, t₀] (since x₀ = t₀)
          have h_eval₀_const := h_x₀_eq ▸ h_eval₀
          -- Extract from compat_disj: M has some compatible 1-var type at t
          have h_compat_data : ∃ nf_x, compat_check nf_x = true ∧
              nf_eval_nf M (k' + 1 + 1) 1 (fun _ => t) nf_x := by
            rw [formula_disjList_iff] at h_compat
            obtain ⟨φ, h_φ_mem, h_φ_true⟩ := h_compat
            rw [List.mem_filterMap] at h_φ_mem
            obtain ⟨nf_x, _, h_nf_x_some⟩ := h_φ_mem
            split_ifs at h_nf_x_some with h_compat_nfx
            exact ⟨nf_x, h_compat_nfx,
              (char_kp1_correct nf_x M h_UZ h_SZ t).mp
                (Option.some_injective _ h_nf_x_some ▸ h_φ_true)⟩
          obtain ⟨nf_x, h_nf_x_compat, h_nf_x_eval⟩ := h_compat_data
          -- Build nf_eval_nf via constructor
          constructor
          · -- Atom part via extracted helper
            simp only [compat_check, List.all_eq_true, beq_iff_eq] at h_nf_x_compat
            exact const_env_atom_agree M t M₀ t₀ sub_nf h_eval₀_const
              nf_x h_nf_x_eval (fun p => h_nf_x_compat p
                (Multiset.mem_toList.mpr (Fintype.complete p)))
          · -- Quant part
            intro ssn
            rw [formula_conjList_iff] at h_quant
            have h_ssn_mem : (if sub_nf.2 ssn then ih_exist_formula ssn
                else (ih_exist_formula ssn).neg) ∈
                (Fintype.elems (α := NormalForm sig (k' + 1) 3)).val.toList.map fun ssn =>
                  if sub_nf.2 ssn then ih_exist_formula ssn
                  else (ih_exist_formula ssn).neg :=
              List.mem_map.mpr ⟨ssn, Multiset.mem_toList.mpr (Fintype.complete ssn), rfl⟩
            have h_φ_true := h_quant _ h_ssn_mem
            cases h_ssn_val : sub_nf.2 ssn with
            | true =>
              simp only [h_ssn_val, ite_true] at h_φ_true
              have ⟨y, hy⟩ := (ih_exist_correct ssn M h_UZ h_SZ t h_atoms).mp h_φ_true
              exact Iff.intro (fun _ => rfl)
                (fun _ => ⟨y, (h_env_transfer M t y ssn).mpr hy⟩)
            | false =>
              simp only [h_ssn_val, Bool.false_eq_true, ite_false] at h_φ_true
              have h_not := (temporal_truth_neg M atomMap t _).mp h_φ_true
              exact Iff.intro
                (fun ⟨y, hy⟩ => absurd
                  ((ih_exist_correct ssn M h_UZ h_SZ t h_atoms).mpr
                    ⟨y, (h_env_transfer M t y ssn).mp hy⟩)
                  h_not)
                (fun h_eq => absurd h_eq (by simp))
        · -- Forward: ∃ x → temporal
          intro ⟨x, h_eval⟩
          have h_x_eq_t := wit_eq M t x h_gt_val h_lt_val h_eval
          rw [h_x_eq_t] at h_eval
          constructor
          · -- compat_disj
            exact fwd_disj M h_UZ h_SZ t
              (nf_characteristic_satisfies M (k' + 1 + 1) 1 (fun _ => t))
              (compat_of_eval M t t h_eval)
          · -- quant_conj
            rw [formula_conjList_iff]
            intro φ h_φ_mem
            rw [List.mem_map] at h_φ_mem
            obtain ⟨ssn, _, h_ssn_eq⟩ := h_φ_mem
            obtain ⟨_, h_quant_eval⟩ := h_eval
            cases h_ssn_val : sub_nf.2 ssn with
            | true =>
              subst h_ssn_eq
              simp only [h_ssn_val, reduceIte]
              obtain ⟨y, hy⟩ := (h_quant_eval ssn).mpr h_ssn_val
              have hy' := (h_env_transfer M t y ssn).mp hy
              exact (ih_exist_correct ssn M h_UZ h_SZ t h_atoms).mpr ⟨y, hy'⟩
            | false =>
              subst h_ssn_eq
              simp only [h_ssn_val, Bool.false_eq_true, ite_false]
              rw [temporal_truth_neg]
              intro h_contra
              obtain ⟨y, hy⟩ := (ih_exist_correct ssn M h_UZ h_SZ t h_atoms).mp h_contra
              have hy' := (h_env_transfer M t y ssn).mpr hy
              have := (h_quant_eval ssn).mp ⟨y, hy'⟩
              exact absurd (h_ssn_val ▸ this) (by simp)
    · -- Unsatisfiable: use ⊥
      exact ⟨Formula.bot, fun M _ _ t h_atoms => by
        simp only [temporal_truth]
        constructor
        · intro h; exact absurd h id
        · rintro ⟨x, hx⟩
          exact absurd ⟨M, ‹_›, ‹_›, t, x, hx, h_atoms⟩ h_unsat⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
