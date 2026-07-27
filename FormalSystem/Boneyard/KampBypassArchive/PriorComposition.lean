import FormalSystem.Metalogic.WeakCanonical.Kamp.KampComposition

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Prior-Specific Transfer Stubs and Projection Helpers

Slim replacement for the full PriorComposition.lean (archived in Boneyard/).
Contains only the symbols used by KampBypass.lean:

- Atom agreement helpers for non-constant 2-var environments
- `prior_2var_transfer_until/since` — explicit sorry stubs replacing the
  provably-false K=0 semantic approach (counterexample: ℤ with is_even,
  (x,t)=(4,0) vs (2,0)). To be filled by Rabinovich's formula-level
  EA negation closure (EANegation.lean).
- `skipIdx`-based NF projection infrastructure
- Second-component 1-var extraction from 2-var agreement

See Boneyard/PriorComposition.lean for the full semantic composition
infrastructure (exist_transfer_from_full_agree, zone_compatible_witness,
prior_nonconstenv_2var_agree_until/since, etc.) if restoration is needed.
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Atom Agreement for Non-Constant 2-var Environments -/

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

/-! ## 2-var Transfer Stubs

These are explicit sorry stubs for the non-constant-env 2-var NF transfer.
The original proofs (archived in Boneyard/PriorComposition.lean) used a semantic
composition approach that is provably false at K=0. The Rabinovich formula-level
path (EANegation.lean) will replace these. -/

/-! ### Multi-variable NF agreement from pairwise 1-variable agreement

The key technical lemma: if n variables in two structures have matching
1-variable NF types at depth d+1 and matching pairwise orderings, then
the n-variable NF agrees at depth d. Proved by induction on d.

At depth 0 only atoms matter (orderings + predicates), so the result follows
from pairwise ordering agreement and predicate agreement extracted from
1-var NF types. At depth d+1, the quantifier part introduces a new variable w.
We transfer w using the quantifier component of one of the existing variables'
1-var NF agreement (at depth d+2 → d+1 existential transfer), then apply
the IH at depth d with n+1 variables.
-/

/-- Extract the quantifier-existential transfer from 1-var NF agreement at depth k+1.
If t in M and t₀ in M₀ agree on all depth-(k+1) 1-var NFs, then for any
depth-k 2-var NF chi2, (∃ w in M) ↔ (∃ w₀ in M₀). -/
private theorem quant_exist_transfer_from_1var {sig : MonadicSignature}
    {k : Nat}
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (N : OrderedMonadicStructure sig) (t' : N.carrier)
    (h : ∀ nf : NormalForm sig (k + 1) 1,
      nf_eval_nf M (k + 1) 1 (fun _ => t) nf ↔
      nf_eval_nf N (k + 1) 1 (fun _ => t') nf) :
    ∀ chi2 : NormalForm sig k 2,
      (∃ w, nf_eval_nf M k 2 (Fin.cons w (fun _ => t)) chi2) ↔
      (∃ w', nf_eval_nf N k 2 (Fin.cons w' (fun _ => t')) chi2) := by
  intro chi2
  -- From h, M and N satisfy the same depth-(k+1) 1-var NFs at t/t'
  -- Their quantifier components therefore agree on existential conditions
  have hex : ∀ sub : NormalForm sig k 2,
      (∃ w, nf_eval_nf M k 2 (Fin.cons w (fun _ => t)) sub) ↔
      (∃ w', nf_eval_nf N k 2 (Fin.cons w' (fun _ => t')) sub) := by
    -- Get the shared characteristic NF
    set nf_M := nf_characteristic M (k + 1) 1 (fun _ => t)
    have h_M_sat := nf_characteristic_satisfies M (k + 1) 1 (fun _ => t)
    have h_N_sat := (h nf_M).mp h_M_sat
    -- Both satisfy nf_M at depth k+1, so their quantifier components agree
    obtain ⟨_, h_Mq⟩ := h_M_sat
    -- N satisfies nf_M, extract its quantifier part
    have h_char_eq := nf_eval_unique N (k + 1) 1 _ _ nf_M h_N_sat
      (nf_characteristic_satisfies N (k + 1) 1 (fun _ => t'))
    obtain ⟨_, h_Nq⟩ := h_char_eq ▸ nf_characteristic_satisfies N (k + 1) 1 (fun _ => t')
    intro sub
    exact (h_Mq sub).symm.trans (h_Nq sub)
  exact hex chi2

/-- Multi-variable NF agreement from pairwise agreement: depth-0 case.
At depth 0, nf_eval_nf is purely atomic (orderings + predicates). -/
private theorem multivar_agree_depth0 {sig : MonadicSignature}
    {n : Nat}
    (M : OrderedMonadicStructure sig) (env_M : Fin n → M.carrier)
    (N : OrderedMonadicStructure sig) (env_N : Fin n → N.carrier)
    (h_pred : ∀ (i : Fin n) (p : sig.preds),
      M.interp p (env_M i) ↔ N.interp p (env_N i))
    (h_ord : ∀ (i j : Fin n), env_M i < env_M j ↔ env_N i < env_N j) :
    ∀ nf : NormalForm sig 0 n,
      nf_eval_nf M 0 n env_M nf ↔ nf_eval_nf N 0 n env_N nf := by
  intro nf
  -- Both sides are: ∀ a, atom_eval _ env a ↔ (nf a = true)
  -- atom_eval for pred is interp, for order is <
  simp only [nf_eval_nf]
  have h_atom_iff : ∀ a : AtomKind sig n,
      atom_eval M env_M a ↔ atom_eval N env_N a := by
    intro a; cases a with
    | pred p i => simp only [atom_eval]; exact h_pred i p
    | order i j hne => simp only [atom_eval]; exact h_ord i j
  constructor <;> intro h a
  · exact (h_atom_iff a).symm.trans (h a)
  · exact (h_atom_iff a).trans (h a)

    (sub_nf : NormalForm sig (K + 2) 2)
    (h_eval₀ : nf_eval_nf M₀ (K + 2) 2 (Fin.cons x₀ (fun _ => t₀)) sub_nf) :
    nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) sub_nf := by
  -- BLOCKED: The quantifier step requires 3-var existential transfer at depth K+1,
  -- which needs 2-var NF agreement at depth K+1 (available from IH on K via
  -- nvar_transfer_from_1var_agree with h_rvar). However, the h_rvar for the
  -- Boneyard's nvar_transfer_from_1var_agree requires full r-var agreement at
  -- depth d+1, creating a circular dependency.
  --
  -- The correct approach (from Boneyard/PriorComposition.lean) uses
  -- nvar_transfer_from_1var_agree which takes h_rvar (depth-(d+1) r-var agreement)
  -- as a hypothesis. For the main theorem at depth K+2, this requires depth-(K+3)
  -- 2-var agreement. The resolution is to:
  -- (a) Restructure as strong induction on K where the IH provides 2-var agreement
  --     at all lower depths, then use nvar_transfer_from_1var_agree with the IH
  --     as h_rvar; OR
  -- (b) Inline the transfer into KampBypass.lean's mutual induction where hex
  --     is available directly from the CharPart/ExistPart decomposition.
  --
  -- Key infrastructure already proved (sorry-free):
  -- - quant_exist_transfer_from_1var: 2-var existential transfer from 1-var agreement
  -- - multivar_agree_depth0: multi-var agreement at depth 0 from orderings + predicates
  -- - nonconstenv_atom_agree_until/since: 2-var atom transfer
  -- - nf_skipIdx_cross: (n+1)-var → n-var projection
  --
  -- The Boneyard archive (Kamp/Boneyard/PriorComposition.lean) contains a sorry-free
  -- nvar_transfer_from_1var_agree that proves this given h_rvar. Restoring and
  -- adapting it requires providing h_rvar, which needs the proof to be restructured
  -- as strong induction on K.
  sorry

theorem prior_2var_transfer_since {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (K : Nat)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (M₀ : OrderedMonadicStructure sig) (x₀ t₀ : M₀.carrier)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (h_UZ₀ : semantic_prior_UZ M₀ atomMap)
    (h_SZ₀ : semantic_prior_SZ M₀ atomMap)
    (h_x : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => x) nf ↔
      nf_eval_nf M₀ (K + 2) 1 (fun _ => x₀) nf)
    (h_t : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => t) nf ↔
      nf_eval_nf M₀ (K + 2) 1 (fun _ => t₀) nf)
    (h_order : x < t)
    (h_order₀ : x₀ < t₀)
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ K + 1) (nf_1 : NormalForm sig d 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_fn d nf_1) ↔
        nf_eval_nf M d 1 (fun _ => t) nf_1)
    (sub_nf : NormalForm sig (K + 2) 2)
    (h_eval₀ : nf_eval_nf M₀ (K + 2) 2 (Fin.cons x₀ (fun _ => t₀)) sub_nf) :
    nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) sub_nf := by
  -- Mirror of prior_2var_transfer_until with reversed ordering (x < t).
  -- Same blocker: needs nvar_transfer_from_1var_agree with h_rvar.
  -- See the detailed blocker analysis in prior_2var_transfer_until above.
  sorry

/-! ## Second Component Projection from 2-var Agreement

Cross-structure projection that extracts second-component (n-var) NF agreement
from (n+1)-var NF agreement. Uses `skipIdx j` to generalize both `Fin.castSucc`
(j=n, drops last) and `Fin.succ` (j=0, drops first). -/

private def skipIdx (j : Nat) {n : Nat} : Fin n → Fin (n + 1) := fun i =>
  if i.val < j then i.castSucc else i.succ

private theorem skipIdx_injective {n : Nat} (j : Nat) (i₁ i₂ : Fin n)
    (h : skipIdx j i₁ = skipIdx j i₂) : i₁ = i₂ := by
  simp only [skipIdx, Fin.ext_iff] at h; ext
  split at h <;> split at h <;> simp [Fin.castSucc, Fin.succ, Fin.castAdd] at h <;> omega

private theorem skipIdx_succ_comm {n : Nat} (j : Nat) (i : Fin n) :
    skipIdx (j + 1) i.succ = (skipIdx j i).succ := by
  ext; simp only [skipIdx, Fin.succ, Fin.castSucc, Fin.castAdd, Fin.val_mk]
  split <;> split <;> rename_i h1 h2 <;> first | rfl | omega

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

private theorem cons_comp_skipIdx_zero {α : Type*} {n : Nat} (x : α) (f : Fin n → α) :
    (Fin.cons x f) ∘ skipIdx 0 = f := by
  ext ⟨i, hi⟩
  simp only [Function.comp, skipIdx, show ¬(i < 0) from not_lt.mpr (Nat.zero_le i), ↓reduceIte]
  rfl

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
      have h_atom := atom_agreement_from_nf M envM N envN h
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

private theorem cross_2nd_1var_from_2var {sig : MonadicSignature}
    {K : Nat}
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h : ∀ nf : NormalForm sig K 2,
      nf_eval_nf M K 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N K 2 (Fin.cons x' (fun _ => t')) nf) :
    ∀ nf1 : NormalForm sig K 1,
      nf_eval_nf M K 1 (fun _ => t) nf1 ↔
      nf_eval_nf N K 1 (fun _ => t') nf1 := by
  intro nf1
  have h_proj := nf_skipIdx_cross M N K 1 0
    (Fin.cons x (fun _ => t)) (Fin.cons x' (fun _ => t')) h nf1
  rwa [cons_comp_skipIdx_zero, cons_comp_skipIdx_zero] at h_proj

theorem prior_second_1var_from_2var_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (K : Nat)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (M₀ : OrderedMonadicStructure sig) (x₀ t₀ : M₀.carrier)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (h_UZ₀ : semantic_prior_UZ M₀ atomMap)
    (h_SZ₀ : semantic_prior_SZ M₀ atomMap)
    (h_2var : ∀ nf : NormalForm sig (K + 2) 2,
      nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf M₀ (K + 2) 2 (Fin.cons x₀ (fun _ => t₀)) nf)
    (h_order_M : t < x) (h_order₀ : t₀ < x₀) :
    ∀ nf1 : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => t) nf1 ↔
      nf_eval_nf M₀ (K + 2) 1 (fun _ => t₀) nf1 :=
  cross_2nd_1var_from_2var M x t M₀ x₀ t₀ h_2var

theorem prior_second_1var_from_2var_since {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (K : Nat)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (M₀ : OrderedMonadicStructure sig) (x₀ t₀ : M₀.carrier)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (h_UZ₀ : semantic_prior_UZ M₀ atomMap)
    (h_SZ₀ : semantic_prior_SZ M₀ atomMap)
    (h_2var : ∀ nf : NormalForm sig (K + 2) 2,
      nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf M₀ (K + 2) 2 (Fin.cons x₀ (fun _ => t₀)) nf)
    (h_order_M : x < t) (h_order₀ : x₀ < t₀) :
    ∀ nf1 : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => t) nf1 ↔
      nf_eval_nf M₀ (K + 2) 1 (fun _ => t₀) nf1 :=
  cross_2nd_1var_from_2var M x t M₀ x₀ t₀ h_2var

end Bimodal.Metalogic.WeakCanonical.Kamp
