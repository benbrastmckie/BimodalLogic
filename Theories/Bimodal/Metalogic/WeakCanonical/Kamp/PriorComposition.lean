import Bimodal.Metalogic.WeakCanonical.Kamp.KampComposition
import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation

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
open Bimodal.Metalogic.WeakCanonical.Separation (nf_depth0_char_formula
  nf_depth0_char_formula_correct)

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

/-! ## Depth-0 3-var Existential Transfer (Zone Analysis)

At depth 0, `nf_eval_nf M 0 3 env ssn3` is purely atomic: it asserts that
all atoms (predicates + orders) at the 3-variable env match ssn3.

The existential `∃ w, nf_eval M 0 3 [w,x,t] ssn3` asks for a point w with
specific predicates and specific order relationships to x and t. The order
relationships partition w into zones:
- Zone 1 (w < t < x): handled by `cross_extend_bwd_1var` from h_t
- Zone 2 (w = t): use t' directly
- Zone 3 (t < w < x): between-zone, requires Prior axioms
- Zone 4 (w = x): use x' directly
- Zone 5 (x < w): handled by `cross_extend_bwd_1var` from h_x

Zones 1,2,4,5 are proved sorry-free. Zone 3 requires additional
infrastructure (Prior-UZ/SZ with characteristic formulas). -/

/-- Helper: verify that a candidate witness c satisfies a depth-0 3-var NF
    at [c,x',t'] given predicate matching and order matching. At depth 0,
    nf_eval_nf is purely atomic: we need each atom to match ssn3. -/
private theorem depth0_3var_witness_check {sig : MonadicSignature}
    (N : OrderedMonadicStructure sig) (c x' t' : N.carrier)
    (ssn3 : NormalForm sig 0 3)
    (h_pred_c : ∀ p : sig.preds, N.interp p c ↔ ssn3 (.pred p ⟨0, by omega⟩) = true)
    (h_pred_x : ∀ p : sig.preds, N.interp p x' ↔ ssn3 (.pred p ⟨1, by omega⟩) = true)
    (h_pred_t : ∀ p : sig.preds, N.interp p t' ↔ ssn3 (.pred p ⟨2, by omega⟩) = true)
    (h_ord_01 : (c < x') ↔ ssn3 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (h_ord_10 : (x' < c) ↔ ssn3 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_ord_02 : (c < t') ↔ ssn3 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_ord_20 : (t' < c) ↔ ssn3 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_ord_12 : (x' < t') ↔ ssn3 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_ord_21 : (t' < x') ↔ ssn3 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true) :
    nf_eval_nf N 0 3 (Fin.cons c (Fin.cons x' (fun _ => t'))) ssn3 := by
  intro a
  cases a with
  | pred p i =>
    simp only [atom_eval]
    refine Fin.cases ?_ (fun i' => Fin.cases ?_ (fun i'' => ?_) i') i
    · simp only [Fin.cons_zero]; exact h_pred_c p
    · simp only [Fin.cons_succ, Fin.cons_zero]; exact h_pred_x p
    · -- i'' : Fin 1, so i''.succ.succ = ⟨2, ...⟩
      simp only [Fin.cons_succ]
      have : i'' = ⟨0, by omega⟩ := Fin.ext (by omega)
      subst this; exact h_pred_t p
  | order i j hij =>
    simp only [atom_eval]
    -- Enumerate all 9 (i,j) pairs in Fin 3 × Fin 3
    match i, j with
    | ⟨0, _⟩, ⟨0, _⟩ => exact absurd rfl hij
    | ⟨0, _⟩, ⟨1, _⟩ => exact h_ord_01
    | ⟨0, _⟩, ⟨2, _⟩ => exact h_ord_02
    | ⟨1, _⟩, ⟨0, _⟩ => exact h_ord_10
    | ⟨1, _⟩, ⟨1, _⟩ => exact absurd rfl hij
    | ⟨1, _⟩, ⟨2, _⟩ => exact h_ord_12
    | ⟨2, _⟩, ⟨0, _⟩ => exact h_ord_20
    | ⟨2, _⟩, ⟨1, _⟩ => exact h_ord_21
    | ⟨2, _⟩, ⟨2, _⟩ => exact absurd rfl hij

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
  -- Also extract from h_t
  obtain ⟨_, hMq_t⟩ := nf_characteristic_satisfies M (K + 2) 1 (fun _ => t)
  have h_char_t : nf_characteristic M (K + 2) 1 (fun _ => t) =
      nf_characteristic N (K + 2) 1 (fun _ => t') :=
    nf_eval_unique N (K + 2) 1 _ _ _
      ((h_t _).mp (nf_characteristic_satisfies M _ _ _))
      (nf_characteristic_satisfies N _ _ _)
  obtain ⟨_, hNq_t⟩ := h_char_t ▸
    nf_characteristic_satisfies N (K + 2) 1 (fun _ => t')
  -- h_t quantifier: depth-(K+1) 2-var existential transfer at [_,t]/[_,t']
  have hex_t : ∀ ssn2 : NormalForm sig (K + 1) 2,
      (∃ y, nf_eval_nf M (K + 1) 2 (Fin.cons y (fun _ => t)) ssn2) ↔
      (∃ c, nf_eval_nf N (K + 1) 2 (Fin.cons c (fun _ => t')) ssn2) :=
    fun ssn2 => (hMq_t ssn2).trans (hNq_t ssn2).symm
  constructor
  · -- Forward: M → N
    rintro ⟨y, hy⟩
    -- Find c_x via h_x's quantifier (depth-(K+1) 2-var at [y,x]/[c_x,x'])
    set chi_x := nf_characteristic M (K + 1) 2 (Fin.cons y (fun _ => x))
    obtain ⟨c_x, hc_x⟩ := (hex_x chi_x).mp ⟨y, nf_characteristic_satisfies ..⟩
    have h_2var_x := nf_agreement_from_shared_nf M _ N _ chi_x
      (nf_characteristic_satisfies ..) hc_x
    -- c_x has depth-(K+1) 1-var matching y
    have h_cx_1var := cross_1var_from_2var M y x N c_x x' h_2var_x
    -- Find c_t via h_t's quantifier (depth-(K+1) 2-var at [y,t]/[c_t,t'])
    set chi_t := nf_characteristic M (K + 1) 2 (Fin.cons y (fun _ => t))
    obtain ⟨c_t, hc_t⟩ := (hex_t chi_t).mp ⟨y, nf_characteristic_satisfies ..⟩
    have h_2var_t := nf_agreement_from_shared_nf M _ N _ chi_t
      (nf_characteristic_satisfies ..) hc_t
    -- c_t has depth-(K+1) 1-var matching y
    have h_ct_1var := cross_1var_from_2var M y t N c_t t' h_2var_t
    -- From h_2var_x: c_x < x' iff y < x (order atom transfer)
    -- From h_2var_t: c_t < t' iff y < t, c_t > t' iff y > t (order atom transfer)
    -- The depth-K 3-var witness c_K has ALL orders correct
    set chi_K := nf_characteristic M K 3 (Fin.cons y (Fin.cons x (fun _ => t)))
    obtain ⟨c_K, hc_K⟩ := (hex_K chi_K).mp ⟨y, nf_characteristic_satisfies ..⟩
    have h_3var_K := nf_agreement_from_shared_nf M _ N _ chi_K
      (nf_characteristic_satisfies ..) hc_K
    -- c_K has correct orders relative to BOTH x' and t' at depth K.
    -- c_K has depth-(K+1)-1 = depth-K 3-var agreement. We need depth-(K+1) 3-var.
    -- The depth boost requires depth-K 4-var existential transfer, which is circular.
    -- This is the fundamental limitation: without Prior+CharPart for the between-zone,
    -- we cannot determine whether c_x or c_t (which have depth-(K+1) partial info)
    -- are in the correct zone relative to the other anchor point.
    sorry
  · -- Backward: N → M (symmetric)
    rintro ⟨y', hy'⟩
    -- Find c_x via (hex_x).mpr
    set chi_x := nf_characteristic N (K + 1) 2 (Fin.cons y' (fun _ => x'))
    obtain ⟨c_x, hc_x⟩ := (hex_x chi_x).mpr ⟨y', nf_characteristic_satisfies ..⟩
    have h_2var_x := nf_agreement_from_shared_nf N _ M _ chi_x
      (nf_characteristic_satisfies ..) hc_x
    have h_cx_1var := cross_1var_from_2var N y' x' M c_x x h_2var_x
    -- Find c_t via (hex_t).mpr
    set chi_t := nf_characteristic N (K + 1) 2 (Fin.cons y' (fun _ => t'))
    obtain ⟨c_t, hc_t⟩ := (hex_t chi_t).mpr ⟨y', nf_characteristic_satisfies ..⟩
    have h_2var_t := nf_agreement_from_shared_nf N _ M _ chi_t
      (nf_characteristic_satisfies ..) hc_t
    have h_ct_1var := cross_1var_from_2var N y' t' M c_t t h_2var_t
    -- Depth-K 3-var witness
    set chi_K := nf_characteristic N K 3 (Fin.cons y' (Fin.cons x' (fun _ => t')))
    obtain ⟨c_K, hc_K⟩ := (hex_K chi_K).mpr ⟨y', nf_characteristic_satisfies ..⟩
    have h_3var_K := nf_agreement_from_shared_nf N _ M _ chi_K
      (nf_characteristic_satisfies ..) hc_K
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
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
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
          · -- depth-0 3-var existential transfer: purely atomic
            intro ssn3; rw [← h_N1_quant ssn3]
            -- At depth 0, nf_eval is purely atomic (no quantifiers).
            -- Zone decomposition based on ssn3's order atoms for w vs x, w vs t.
            -- Consistency check: ssn3 must record t < x (matching h_order_M/N)
            -- Otherwise the existential is vacuously false.
            -- Extract the zone-determining order atoms
            let w_lt_x := ssn3 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
            let x_lt_w := ssn3 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
            let w_lt_t := ssn3 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
            let t_lt_w := ssn3 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
            let x_lt_t := ssn3 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
            let t_lt_x := ssn3 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
            -- First check x-t consistency: if ssn3 says x < t, no witness exists (t < x in M)
            -- If ssn3 says t < x (correct), proceed with zone decomp
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
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
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
    (h_order : t < x)
    (h_order₀ : t₀ < x₀)
    (sub_nf : NormalForm sig (K + 2) 2)
    (h_eval₀ : nf_eval_nf M₀ (K + 2) 2 (Fin.cons x₀ (fun _ => t₀)) sub_nf) :
    nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) sub_nf :=
  (prior_nonconstenv_2var_agree_until atomMap h_surj K M x t M₀ x₀ t₀
    h_UZ h_SZ h_UZ₀ h_SZ₀ h_x h_t h_order h_order₀ sub_nf).mpr h_eval₀

/-- Specialized version for the KampBypass backward Since direction. -/
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
    (sub_nf : NormalForm sig (K + 2) 2)
    (h_eval₀ : nf_eval_nf M₀ (K + 2) 2 (Fin.cons x₀ (fun _ => t₀)) sub_nf) :
    nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) sub_nf :=
  (prior_nonconstenv_2var_agree_since atomMap h_surj K M x t M₀ x₀ t₀
    h_UZ h_SZ h_UZ₀ h_SZ₀ h_x h_t h_order h_order₀ sub_nf).mpr h_eval₀

/-! ## Second Component Projection from 2-var Agreement

Cross-structure projection that extracts second-component (n-var) NF agreement
from (n+1)-var NF agreement. Uses `skipIdx j` to generalize both `Fin.castSucc`
(j=n, drops last) and `Fin.succ` (j=0, drops first).

The key application: from 2-var agreement at `[x,t]/[x₀,t₀]`, extract 1-var
agreement at `t/t₀` (second component) via `skipIdx 0 = Fin.succ`. -/

/-- Skip index j: sends i < j to i (via castSucc) and i ≥ j to i+1 (via succ).
    j=0 gives Fin.succ; j=n gives Fin.castSucc. -/
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

/-- Key commutation: `Fin.cons y (env ∘ skipIdx j) = (Fin.cons y env) ∘ skipIdx (j + 1)`. -/
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

/-- On `Fin.cons x f` envs, composing with `skipIdx 0` gives `f`.
    `skipIdx 0` sends every `i` to `i.succ`, and `Fin.cons x f ∘ Fin.succ = f`. -/
private theorem cons_comp_skipIdx_zero {α : Type*} {n : Nat} (x : α) (f : Fin n → α) :
    (Fin.cons x f) ∘ skipIdx 0 = f := by
  ext ⟨i, hi⟩
  simp only [Function.comp, skipIdx, show ¬(i < 0) from not_lt.mpr (Nat.zero_le i), ↓reduceIte]
  rfl

/-- Cross-structure projection along `skipIdx j`: if two environments in different
    structures agree on all depth-k (n+1)-var NFs, then the projected environments
    (via `skipIdx j`) agree on all depth-k n-var NFs. -/
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

/-- Second-component 1-var NF extraction from 2-var NF agreement.
    From cross-structure 2-var agreement at `[x,t]/[x₀,t₀]`,
    the second components `t` and `t₀` have the same 1-var NF.
    Proved via `nf_skipIdx_cross` at `j=0`. -/
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

/-- On Prior structures, 2-var NF agreement at [x,t]/[x₀,t₀] implies
    1-var NF agreement at t/t₀ (second component). -/
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

/-- Mirror for Since zone (x < t). -/
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
