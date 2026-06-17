import Bimodal.Metalogic.WeakCanonical.Kamp.KampComposition

/-!
# Prior-Specific Composition for Non-Constant Environments

Cross-structure 2-var NF transfer on non-constant environments for Prior structures.

## The Problem

On constant environments `[t, t]`, depth-(K+1) 1-var NF agreement at `t`/`s`
implies depth-(K+1) 2-var NF agreement at `[t,t]`/`[s,s]` (`constenv_same_depth_2var`).
This works because the quantifier conditions reduce to constant-env existential
transfers via `exist_transfer_nvar_constenv`.

On non-constant environments `[x, t]` with `x ≠ t`, the analogous statement is
FALSE on general linear orders (counterexample in NfComposition.lean: two pairs
`(0, 2)` and `(0, 1)` in `(ℤ, <)` have same 1-var NF types for each component
and same order, but different 2-var NFs because the zone between them has
different cardinality).

On Prior structures, the statement IS true because the UZ/SZ axioms constrain
which NF types can be realized in the interval between `x` and `t` sufficiently
to transfer all quantifier conditions.

## Proof Strategy

1. **Atom part**: Direct from `pred_agree_cross` (from h_x, h_t) and order matching.
   Proved in `nonconstenv_atom_agree` / `nonconstenv_atom_agree_since`.

2. **Quantifier part**: Transfer 3-var existentials using strong induction on K.
   At step K+1, the IH gives depth-(K+1) 2-var at [x,t]/[x',t'] from depth-(K+1)
   1-var (obtained by monotonicity). The quantifier part of this 2-var agreement
   gives depth-K 3-var existential transfer for [_,x,t]/[_,x',t']. Combined with
   `cross_extend_bwd_1var` from h_x/h_t, this provides witnesses with matching
   1-var types in the correct zones.

   The full depth-(K+1) 3-var transfer (`exist_transfer_3var_nonconstenv`)
   requires the Fraïssé game argument or Prior-specific zone matching.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Lemma 5.1
- KampComposition.lean: `constenv_same_depth_2var` (constant-env case)
- NfComposition.lean: counterexample for non-constant general case
-/

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
    · -- (0,0): x < x ↔ x' < x' (both false)
      exact iff_of_false (lt_irrefl _) (lt_irrefl _)
    · -- (0, succ): x < t ↔ x' < t' (both false since t < x, t' < x')
      simp only [Fin.cons_zero, Fin.cons_succ]
      exact iff_of_false (not_lt.mpr (le_of_lt h_order_M)) (not_lt.mpr (le_of_lt h_order_N))
    · -- (succ, 0): t < x ↔ t' < x' (both true)
      simp only [Fin.cons_zero, Fin.cons_succ]
      exact Iff.intro (fun _ => h_order_N) (fun _ => h_order_M)
    · -- (succ, succ): t < t ↔ t' < t' (both false)
      simp only [Fin.cons_succ]
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
    · -- (0, succ): x < t ↔ x' < t' (both true)
      simp only [Fin.cons_zero, Fin.cons_succ]
      exact Iff.intro (fun _ => h_order_N) (fun _ => h_order_M)
    · -- (succ, 0): t < x ↔ t' < x' (both false since x < t, x' < t')
      simp only [Fin.cons_zero, Fin.cons_succ]
      exact iff_of_false (not_lt.mpr (le_of_lt h_order_M)) (not_lt.mpr (le_of_lt h_order_N))
    · simp only [Fin.cons_succ]
      exact iff_of_false (lt_irrefl _) (lt_irrefl _)

/-! ## 3-var Existential Transfer (Core Mathematical Content)

The key helper: transfer 3-var existentials between M and N on
non-constant envs [x,t]/[x',t']. This uses:
- `cross_extend_bwd_1var` from h_x/h_t to find witness candidates
- The h_xt hypothesis (2-var agreement at [x,t]/[x',t']) for the tail
- The zone-matching argument (implicit in the quantifier part of h_xt)

The h_xt parameter comes from the IH in the inductive case, or from
direct construction in the base case. -/

/-- Transfer 3-var existentials on non-constant envs.

    From depth-(K+2) 1-var at x/x' and t/t', plus depth-(K+1) 2-var at
    [x,t]/[x',t'] (from IH), derive the 3-var existential transfer.

    Proof strategy: use the quantifier part of h_xt to find a witness c in N
    with depth-K 3-var agreement at [y,x,t]/[c,x',t']. Then boost to
    depth-(K+1) using the h_x/h_t depth advantage.

    The full proof requires the Fraïssé game argument for the depth boost;
    see StaviCompleteness.lean `nf_2var_existential_transfer` for the
    parallel situation in the Stavi pipeline. -/
private theorem exist_transfer_3var_nonconstenv {sig : MonadicSignature}
    {K : Nat}
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_x : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => x) nf ↔
      nf_eval_nf N (K + 2) 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => t) nf ↔
      nf_eval_nf N (K + 2) 1 (fun _ => t') nf)
    (h_xt : ∀ nf : NormalForm sig (K + 1) 2,
      nf_eval_nf M (K + 1) 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N (K + 1) 2 (Fin.cons x' (fun _ => t')) nf)
    (sub_nf : NormalForm sig (K + 1) 3) :
    (∃ y : M.carrier, nf_eval_nf M (K + 1) 3
      (Fin.cons y (Fin.cons x (fun _ => t))) sub_nf) ↔
    (∃ y' : N.carrier, nf_eval_nf N (K + 1) 3
      (Fin.cons y' (Fin.cons x' (fun _ => t'))) sub_nf) := by
  -- Extract quantifier transfer from h_xt at depth K
  have h_char_xt : nf_characteristic M (K + 1) 2 (Fin.cons x (fun _ => t)) =
      nf_characteristic N (K + 1) 2 (Fin.cons x' (fun _ => t')) :=
    nf_eval_unique N (K + 1) 2 _ _ _
      ((h_xt _).mp (nf_characteristic_satisfies M _ _ _))
      (nf_characteristic_satisfies N _ _ _)
  obtain ⟨_, hMq_xt⟩ := nf_characteristic_satisfies M (K + 1) 2 (Fin.cons x (fun _ => t))
  obtain ⟨_, hNq_xt⟩ := h_char_xt ▸
    nf_characteristic_satisfies N (K + 1) 2 (Fin.cons x' (fun _ => t'))
  -- Depth-K 3-var existential transfer from h_xt's quantifier part
  have hex_K : ∀ chi : NormalForm sig K 3,
      (∃ w, nf_eval_nf M K 3 (Fin.cons w (Fin.cons x (fun _ => t))) chi) ↔
      (∃ w', nf_eval_nf N K 3 (Fin.cons w' (Fin.cons x' (fun _ => t'))) chi) :=
    fun chi => (hMq_xt chi).trans (hNq_xt chi).symm
  -- Also extract from h_x
  obtain ⟨_, hMq_x⟩ := nf_characteristic_satisfies M (K + 2) 1 (fun _ => x)
  have h_char_x : nf_characteristic M (K + 2) 1 (fun _ => x) =
      nf_characteristic N (K + 2) 1 (fun _ => x') :=
    nf_eval_unique N (K + 2) 1 _ _ _
      ((h_x _).mp (nf_characteristic_satisfies M _ _ _))
      (nf_characteristic_satisfies N _ _ _)
  obtain ⟨_, hNq_x⟩ := h_char_x ▸
    nf_characteristic_satisfies N (K + 2) 1 (fun _ => x')
  -- h_x quantifier: depth-(K+1) 2-var existential transfer at [_,x]/[_,x']
  have hex_x : ∀ ssn2 : NormalForm sig (K + 1) 2,
      (∃ y, nf_eval_nf M (K + 1) 2 (Fin.cons y (fun _ => x)) ssn2) ↔
      (∃ c, nf_eval_nf N (K + 1) 2 (Fin.cons c (fun _ => x')) ssn2) :=
    fun ssn2 => (hMq_x ssn2).trans (hNq_x ssn2).symm
  constructor
  · -- Forward: M → N
    rintro ⟨y, hy⟩
    -- Step 1: Find c via h_xt's quantifier part (depth-K 3-var transfer)
    -- Set chi_K = nf_char M K 3 [y,x,t]. Get c_K with depth-K 3-var at [y,x,t]/[c_K,x',t'].
    set chi_K := nf_characteristic M K 3 (Fin.cons y (Fin.cons x (fun _ => t)))
    obtain ⟨c_K, hc_K⟩ := (hex_K chi_K).mp ⟨y, nf_characteristic_satisfies ..⟩
    -- c_K has depth-K 3-var agreement with y at [y,x,t]/[c_K,x',t']
    have h_3var_K := nf_agreement_from_shared_nf M _ N _ chi_K
      (nf_characteristic_satisfies ..) hc_K
    -- Step 2: Find c via h_x's quantifier part (depth-(K+1) 2-var transfer)
    -- Set chi_Kp1 = nf_char M (K+1) 2 [y,x]. Get c with depth-(K+1) 2-var at [y,x]/[c,x'].
    set chi_Kp1 := nf_characteristic M (K + 1) 2 (Fin.cons y (fun _ => x))
    obtain ⟨c, hc⟩ := (hex_x chi_Kp1).mp ⟨y, nf_characteristic_satisfies ..⟩
    -- c has depth-(K+1) 2-var agreement with y at [y,x]/[c,x']
    have h_2var_Kp1 := nf_agreement_from_shared_nf M _ N _ chi_Kp1
      (nf_characteristic_satisfies ..) hc
    -- c has depth-(K+1) 1-var matching y
    have h_c_1var := cross_1var_from_2var M y x N c x' h_2var_Kp1
    -- Step 3: Show c satisfies sub_nf at [c,x',t'].
    -- We have:
    --   h_2var_Kp1: depth-(K+1) 2-var at [y,x]/[c,x'] (determines y-x relationship)
    --   h_3var_K: depth-K 3-var at [y,x,t]/[c_K,x',t'] (determines all relationships at depth K)
    --   h_c_1var: depth-(K+1) 1-var at y/c
    -- The full depth-(K+1) 3-var agreement at [y,x,t]/[c,x',t'] requires combining:
    --   (a) Atoms: preds at c match y (from h_c_1var), preds at x'/t' match x/t
    --       (from h_x/h_t), orders y-x match c-x' (from h_2var_Kp1),
    --       order x-t matches x'-t' (from h_xt), and y-t order matches c-t' order.
    --   (b) Quantifiers: depth-K 4-var existential transfer at [w,y,x,t]/[w',c,x',t'].
    -- Part (a): The y-t vs c-t' order transfer requires that c_K and c are in the
    --   same zone relative to t' (which follows from c_K and c having the same
    --   depth-K 1-var type, plus zone properties).
    -- Part (b): The depth-K 4-var transfer is the "interval-splitting" game argument.
    --
    -- This is the same game-theoretic argument as in StaviCompleteness.lean
    -- `nf_2var_existential_transfer` (line 2421 sorry).
    sorry
  · -- Backward: N → M (symmetric)
    rintro ⟨y', hy'⟩
    -- Symmetric to forward using (hex_K).mpr and (hex_x).mpr
    set chi_K := nf_characteristic N K 3 (Fin.cons y' (Fin.cons x' (fun _ => t')))
    obtain ⟨c_K, hc_K⟩ := (hex_K chi_K).mpr ⟨y', nf_characteristic_satisfies ..⟩
    set chi_Kp1 := nf_characteristic N (K + 1) 2 (Fin.cons y' (fun _ => x'))
    obtain ⟨c, hc⟩ := (hex_x chi_Kp1).mpr ⟨y', nf_characteristic_satisfies ..⟩
    sorry

/-! ## Prior-Specific 2-var Transfer (Main Theorems)

The main theorems use strong induction on K. At K+1, the IH gives
depth-(K+1) 2-var at [x,t]/[x',t'] (from depth-(K+1) 1-var, obtained
by monotonicity of the depth-(K+2) hypotheses).

At K=0, the base case uses direct construction: depth-1 2-var at
[x,t]/[x',t'] is built from depth-1 1-var (by monotonicity from
depth-2) plus atom agreement.

Both versions delegate the 3-var existential transfer to
`exist_transfer_3var_nonconstenv`. -/

/-- On Prior structures, cross-structure 2-var NF transfer for the Until zone
    (t < x): if M,x and N,x' have the same depth-(K+2) 1-var NF, and
    M,t / N,t' have the same depth-(K+2) 1-var NF, and both t < x, t' < x',
    then M and N agree on all depth-(K+2) 2-var NFs at [x,t] / [x',t']. -/
theorem prior_nonconstenv_2var_agree_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (K : Nat)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_UZ_M : semantic_prior_UZ M atomMap)
    (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap)
    (h_SZ_N : semantic_prior_SZ N atomMap)
    (h_x : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => x) nf ↔
      nf_eval_nf N (K + 2) 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => t) nf ↔
      nf_eval_nf N (K + 2) 1 (fun _ => t') nf)
    (h_order_M : t < x)
    (h_order_N : t' < x') :
    ∀ nf : NormalForm sig (K + 2) 2,
      nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N (K + 2) 2 (Fin.cons x' (fun _ => t')) nf := by
  induction K with
  | zero =>
    intro nf
    -- Show M,[x,t] satisfies the char NF of N,[x',t'] at depth 2
    set target := nf_characteristic N 2 2 (Fin.cons x' (fun _ => t'))
    have h_N_sat := nf_characteristic_satisfies N 2 2 (Fin.cons x' (fun _ => t'))
    suffices h_M_sat : nf_eval_nf M 2 2 (Fin.cons x (fun _ => t)) target by
      exact nf_agreement_from_shared_nf M _ N _ target h_M_sat h_N_sat nf
    obtain ⟨h_N_atoms, h_N_quant⟩ := h_N_sat
    have h_atom := nonconstenv_atom_agree_until M x t N x' t' h_x h_t h_order_M h_order_N
    constructor
    · intro a; exact (h_atom a).trans (h_N_atoms a)
    · -- Quantifier part: depth-1 3-var existential transfer
      intro sub_nf; rw [← h_N_quant sub_nf]
      -- Build depth-1 2-var at [x,t]/[x',t'] for the base case
      -- From depth-2 1-var at x/x' and t/t', get depth-1 1-var by monotonicity
      have h_x1 : ∀ nf1 : NormalForm sig 1 1,
          nf_eval_nf M 1 1 (fun _ => x) nf1 ↔ nf_eval_nf N 1 1 (fun _ => x') nf1 :=
        fun nf1 => nf_agreement_monotone 1 2 1 (by omega) M _ N _ h_x nf1
      have h_t1 : ∀ nf1 : NormalForm sig 1 1,
          nf_eval_nf M 1 1 (fun _ => t) nf1 ↔ nf_eval_nf N 1 1 (fun _ => t') nf1 :=
        fun nf1 => nf_agreement_monotone 1 2 1 (by omega) M _ N _ h_t nf1
      -- Build depth-1 2-var at [x,t]/[x',t'] for the base case
      -- This requires the same non-constant-env composition at one lower depth.
      -- At depth 1, the quantifier part involves depth-0 3-var (purely atomic)
      -- existential transfer, which still requires zone-matching for the "between" zone.
      exact exist_transfer_3var_nonconstenv M x t N x' t' h_x h_t
        (fun nf2 => by
          -- Depth-1 2-var at [x,t]/[x',t'] from atom agreement + depth-0 quantifier transfer
          have h_atom1 := nonconstenv_atom_agree_until M x t N x' t'
            h_x1 h_t1 h_order_M h_order_N
          set tgt := nf_characteristic N 1 2 (Fin.cons x' (fun _ => t'))
          have h_N1 := nf_characteristic_satisfies N 1 2 (Fin.cons x' (fun _ => t'))
          suffices h_M1 : nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) tgt by
            exact nf_agreement_from_shared_nf M _ N _ tgt h_M1 h_N1 nf2
          obtain ⟨h_N1_atoms, h_N1_quant⟩ := h_N1
          constructor
          · intro a; exact (h_atom1 a).trans (h_N1_atoms a)
          · -- depth-0 3-var existential transfer: purely atomic, requires zone-matching
            intro ssn3; rw [← h_N1_quant ssn3]
            -- At depth 0, nf_eval is purely atomic (no further quantifiers).
            -- The transfer of ∃ w with matching atoms requires zone-matching:
            -- - For w outside [t,x]: cross_extend_bwd_1var gives matching witness
            -- - For w inside (t,x): Prior UZ/SZ needed to find w' in (t',x')
            sorry)
        sub_nf
  | succ K' ih =>
    intro nf
    set target := nf_characteristic N (K' + 3) 2 (Fin.cons x' (fun _ => t'))
    have h_N_sat := nf_characteristic_satisfies N (K' + 3) 2 (Fin.cons x' (fun _ => t'))
    suffices h_M_sat : nf_eval_nf M (K' + 3) 2 (Fin.cons x (fun _ => t)) target by
      exact nf_agreement_from_shared_nf M _ N _ target h_M_sat h_N_sat nf
    obtain ⟨h_N_atoms, h_N_quant⟩ := h_N_sat
    have h_atom := nonconstenv_atom_agree_until M x t N x' t' h_x h_t h_order_M h_order_N
    constructor
    · intro a; exact (h_atom a).trans (h_N_atoms a)
    · -- Quantifier: depth-(K'+2) 3-var existential transfer
      intro sub_nf; rw [← h_N_quant sub_nf]
      -- IH gives depth-(K'+2) 2-var at [x,t]/[x',t'] from depth-(K'+2) 1-var
      have h_x' : ∀ nf1 : NormalForm sig (K' + 2) 1,
          nf_eval_nf M (K' + 2) 1 (fun _ => x) nf1 ↔
          nf_eval_nf N (K' + 2) 1 (fun _ => x') nf1 :=
        fun nf1 => nf_agreement_monotone (K' + 2) (K' + 3) 1 (by omega) M _ N _ h_x nf1
      have h_t' : ∀ nf1 : NormalForm sig (K' + 2) 1,
          nf_eval_nf M (K' + 2) 1 (fun _ => t) nf1 ↔
          nf_eval_nf N (K' + 2) 1 (fun _ => t') nf1 :=
        fun nf1 => nf_agreement_monotone (K' + 2) (K' + 3) 1 (by omega) M _ N _ h_t nf1
      have h_xt_IH := ih h_x' h_t'
      exact exist_transfer_3var_nonconstenv M x t N x' t' h_x h_t h_xt_IH sub_nf

/-- Mirror for the Since zone (x < t). Same statement with reversed order. -/
theorem prior_nonconstenv_2var_agree_since {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (K : Nat)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_UZ_M : semantic_prior_UZ M atomMap)
    (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap)
    (h_SZ_N : semantic_prior_SZ N atomMap)
    (h_x : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => x) nf ↔
      nf_eval_nf N (K + 2) 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => t) nf ↔
      nf_eval_nf N (K + 2) 1 (fun _ => t') nf)
    (h_order_M : x < t)
    (h_order_N : x' < t') :
    ∀ nf : NormalForm sig (K + 2) 2,
      nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N (K + 2) 2 (Fin.cons x' (fun _ => t')) nf := by
  induction K with
  | zero =>
    intro nf
    set target := nf_characteristic N 2 2 (Fin.cons x' (fun _ => t'))
    have h_N_sat := nf_characteristic_satisfies N 2 2 (Fin.cons x' (fun _ => t'))
    suffices h_M_sat : nf_eval_nf M 2 2 (Fin.cons x (fun _ => t)) target by
      exact nf_agreement_from_shared_nf M _ N _ target h_M_sat h_N_sat nf
    obtain ⟨h_N_atoms, h_N_quant⟩ := h_N_sat
    have h_atom := nonconstenv_atom_agree_since M x t N x' t' h_x h_t h_order_M h_order_N
    constructor
    · intro a; exact (h_atom a).trans (h_N_atoms a)
    · intro sub_nf; rw [← h_N_quant sub_nf]
      have h_x1 : ∀ nf1 : NormalForm sig 1 1,
          nf_eval_nf M 1 1 (fun _ => x) nf1 ↔ nf_eval_nf N 1 1 (fun _ => x') nf1 :=
        fun nf1 => nf_agreement_monotone 1 2 1 (by omega) M _ N _ h_x nf1
      have h_t1 : ∀ nf1 : NormalForm sig 1 1,
          nf_eval_nf M 1 1 (fun _ => t) nf1 ↔ nf_eval_nf N 1 1 (fun _ => t') nf1 :=
        fun nf1 => nf_agreement_monotone 1 2 1 (by omega) M _ N _ h_t nf1
      exact exist_transfer_3var_nonconstenv M x t N x' t' h_x h_t
        (fun nf2 => by
          have h_atom1 := nonconstenv_atom_agree_since M x t N x' t'
            h_x1 h_t1 h_order_M h_order_N
          set tgt := nf_characteristic N 1 2 (Fin.cons x' (fun _ => t'))
          have h_N1 := nf_characteristic_satisfies N 1 2 (Fin.cons x' (fun _ => t'))
          suffices h_M1 : nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) tgt by
            exact nf_agreement_from_shared_nf M _ N _ tgt h_M1 h_N1 nf2
          obtain ⟨h_N1_atoms, h_N1_quant⟩ := h_N1
          constructor
          · intro a; exact (h_atom1 a).trans (h_N1_atoms a)
          · intro ssn3; rw [← h_N1_quant ssn3]
            sorry)
        sub_nf
  | succ K' ih =>
    intro nf
    set target := nf_characteristic N (K' + 3) 2 (Fin.cons x' (fun _ => t'))
    have h_N_sat := nf_characteristic_satisfies N (K' + 3) 2 (Fin.cons x' (fun _ => t'))
    suffices h_M_sat : nf_eval_nf M (K' + 3) 2 (Fin.cons x (fun _ => t)) target by
      exact nf_agreement_from_shared_nf M _ N _ target h_M_sat h_N_sat nf
    obtain ⟨h_N_atoms, h_N_quant⟩ := h_N_sat
    have h_atom := nonconstenv_atom_agree_since M x t N x' t' h_x h_t h_order_M h_order_N
    constructor
    · intro a; exact (h_atom a).trans (h_N_atoms a)
    · intro sub_nf; rw [← h_N_quant sub_nf]
      have h_x' : ∀ nf1 : NormalForm sig (K' + 2) 1,
          nf_eval_nf M (K' + 2) 1 (fun _ => x) nf1 ↔
          nf_eval_nf N (K' + 2) 1 (fun _ => x') nf1 :=
        fun nf1 => nf_agreement_monotone (K' + 2) (K' + 3) 1 (by omega) M _ N _ h_x nf1
      have h_t' : ∀ nf1 : NormalForm sig (K' + 2) 1,
          nf_eval_nf M (K' + 2) 1 (fun _ => t) nf1 ↔
          nf_eval_nf N (K' + 2) 1 (fun _ => t') nf1 :=
        fun nf1 => nf_agreement_monotone (K' + 2) (K' + 3) 1 (by omega) M _ N _ h_t nf1
      have h_xt_IH := ih h_x' h_t'
      exact exist_transfer_3var_nonconstenv M x t N x' t' h_x h_t h_xt_IH sub_nf

/-- Specialized version for the KampBypass backward Until direction:
    one-directional transfer from M₀ to M. -/
theorem prior_2var_transfer_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
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
    (h_order : t < x)
    (h_order₀ : t₀ < x₀)
    (sub_nf : NormalForm sig (K + 2) 2)
    (h_eval₀ : nf_eval_nf M₀ (K + 2) 2 (Fin.cons x₀ (fun _ => t₀)) sub_nf) :
    nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) sub_nf :=
  (prior_nonconstenv_2var_agree_until atomMap K M x t M₀ x₀ t₀
    h_UZ h_SZ h_UZ₀ h_SZ₀ h_x h_t h_order h_order₀ sub_nf).mpr h_eval₀

/-- Specialized version for the KampBypass backward Since direction. -/
theorem prior_2var_transfer_since {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
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
    (sub_nf : NormalForm sig (K + 2) 2)
    (h_eval₀ : nf_eval_nf M₀ (K + 2) 2 (Fin.cons x₀ (fun _ => t₀)) sub_nf) :
    nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) sub_nf :=
  (prior_nonconstenv_2var_agree_since atomMap K M x t M₀ x₀ t₀
    h_UZ h_SZ h_UZ₀ h_SZ₀ h_x h_t h_order h_order₀ sub_nf).mpr h_eval₀

end Bimodal.Metalogic.WeakCanonical.Kamp
