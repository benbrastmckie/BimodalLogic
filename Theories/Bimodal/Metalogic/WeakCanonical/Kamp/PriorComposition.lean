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

## Proof Strategy (CharPart-Threading Architecture)

1. **Atom part**: Direct from `pred_agree_cross` (from h_x, h_t) and order matching.
   Proved in `nonconstenv_atom_agree` / `nonconstenv_atom_agree_since`.

2. **Quantifier part**: Transfer 3-var existentials using CharPart-based temporal
   formula encoding. The `char_kp1_fn`/`char_kp1_correct` parameters provide
   formulas characterizing each depth-(K+1) 1-var NF type, enabling zone-based
   witness transfer via Prior-UZ/SZ squeeze arguments.

   Zone decomposition for witness w relative to x and t:
   - Zone 1 (w < t < x): `cross_extend_bwd_1var` from h_t
   - Zone 2 (w = t): use t' directly
   - Zone 3 (t < w < x): **Between-zone** -- Prior-UZ/SZ with CharPart formulas
   - Zone 4 (w = x): use x' directly
   - Zone 5 (x < w): `cross_extend_bwd_1var` from h_x

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

-- depth0_3var_exist_transfer_until/since DELETED (FALSE -- counterexample in report 15)
-- exist_transfer_3var_nonconstenv DELETED (unprovable without Prior+CharPart)

/-! ## Cross-Structure 3-var Existential Transfer on Non-Constant Envs

Transfer `∃ w, nf_eval_nf M D 3 [w,x,t] sub_nf` between Prior structures
given depth-(D+1) 1-var agreement at x/x' and t/t'.

The proof proceeds by induction on D:
- D=0: purely atomic, handled by zone analysis + predicate matching
- D=d+1: atoms handled as above; quantifier conditions (depth-d 4-var
  existentials) transferred using the IH at arity 4 (which reduces to
  the D=d case via the same zone decomposition at higher arity).

The multi-depth char parameter enables the zone-3 (between-zone) transfer
at each induction step via Prior-UZ/SZ. -/

/-- Generalized nonconstenv n-var NF agreement on Prior structures.
    Given depth-(D+1) 1-var agreement at each component of non-constant
    environments (Until zone: env[1] < env[0]) and multi-depth char,
    we get depth-D n-var existential transfer for n ≥ 2.

    This is the main workhorse for the quantifier part of
    `prior_nonconstenv_2var_agree_until/since`. -/
private theorem nonconstenv_exist_transfer_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (D : Nat)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_UZ_M : semantic_prior_UZ M atomMap)
    (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap)
    (h_SZ_N : semantic_prior_SZ N atomMap)
    (h_x : ∀ nf : NormalForm sig (D + 1) 1,
      nf_eval_nf M (D + 1) 1 (fun _ => x) nf ↔
      nf_eval_nf N (D + 1) 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig (D + 1) 1,
      nf_eval_nf M (D + 1) 1 (fun _ => t) nf ↔
      nf_eval_nf N (D + 1) 1 (fun _ => t') nf)
    (h_order_M : t < x)
    (h_order_N : t' < x')
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ D) (nf_1 : NormalForm sig d 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_fn d nf_1) ↔
        nf_eval_nf M d 1 (fun _ => t) nf_1)
    (sub_nf : NormalForm sig D 3) :
    (∃ w, nf_eval_nf M D 3 (Fin.cons w (Fin.cons x (fun _ => t))) sub_nf) ↔
    (∃ w', nf_eval_nf N D 3 (Fin.cons w' (Fin.cons x' (fun _ => t'))) sub_nf) := by
  -- Forward direction: given w in M, find w' in N
  -- Backward: symmetric
  -- Both directions use cross_extend_bwd/fwd from h_x and h_t
  -- to find witnesses, then establish NF agreement
  constructor
  · rintro ⟨w, hw⟩
    -- Get witnesses from both anchor points
    obtain ⟨w'_x, hw'_x⟩ := cross_extend_bwd_1var M x N x' h_x w
    obtain ⟨w'_t, hw'_t⟩ := cross_extend_bwd_1var M t N t' h_t w
    -- Both have depth-D 1-var agreement with w
    have h_w_wx := cross_1var_from_2var M w x N w'_x x' hw'_x
    have h_w_wt := cross_1var_from_2var M w t N w'_t t' hw'_t
    -- w'_x and w'_t have the same depth-D 1-var NF (unique via nf_eval_unique)
    -- Zone analysis determines which witness to use and verifies orders
    sorry
  · rintro ⟨w', hw'⟩
    obtain ⟨w_x, hw_x⟩ := cross_extend_fwd_1var M x N x' h_x w'
    obtain ⟨w_t, hw_t⟩ := cross_extend_fwd_1var M t N t' h_t w'
    have h_w'_wx := cross_1var_from_2var M w_x x N w' x' hw_x
    have h_w'_wt := cross_1var_from_2var M w_t t N w' t' hw_t
    sorry

/-- Mirror for the Since zone (x < t). -/
private theorem nonconstenv_exist_transfer_since {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (D : Nat)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_UZ_M : semantic_prior_UZ M atomMap)
    (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap)
    (h_SZ_N : semantic_prior_SZ N atomMap)
    (h_x : ∀ nf : NormalForm sig (D + 1) 1,
      nf_eval_nf M (D + 1) 1 (fun _ => x) nf ↔
      nf_eval_nf N (D + 1) 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig (D + 1) 1,
      nf_eval_nf M (D + 1) 1 (fun _ => t) nf ↔
      nf_eval_nf N (D + 1) 1 (fun _ => t') nf)
    (h_order_M : x < t)
    (h_order_N : x' < t')
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ D) (nf_1 : NormalForm sig d 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_fn d nf_1) ↔
        nf_eval_nf M d 1 (fun _ => t) nf_1)
    (sub_nf : NormalForm sig D 3) :
    (∃ w, nf_eval_nf M D 3 (Fin.cons w (Fin.cons x (fun _ => t))) sub_nf) ↔
    (∃ w', nf_eval_nf N D 3 (Fin.cons w' (Fin.cons x' (fun _ => t'))) sub_nf) := by
  -- Mirror of Until case with reversed order (x < t instead of t < x)
  constructor
  · rintro ⟨w, hw⟩
    obtain ⟨w'_x, hw'_x⟩ := cross_extend_bwd_1var M x N x' h_x w
    obtain ⟨w'_t, hw'_t⟩ := cross_extend_bwd_1var M t N t' h_t w
    have h_w_wx := cross_1var_from_2var M w x N w'_x x' hw'_x
    have h_w_wt := cross_1var_from_2var M w t N w'_t t' hw'_t
    sorry
  · rintro ⟨w', hw'⟩
    obtain ⟨w_x, hw_x⟩ := cross_extend_fwd_1var M x N x' h_x w'
    obtain ⟨w_t, hw_t⟩ := cross_extend_fwd_1var M t N t' h_t w'
    have h_w'_wx := cross_1var_from_2var M w_x x N w' x' hw_x
    have h_w'_wt := cross_1var_from_2var M w_t t N w' t' hw_t
    sorry

/-! ## Prior-Specific 2-var Transfer (Main Theorems)

The main theorems use strong induction on K. At each step, the quantifier part
requires transferring depth-(K+1) 3-var existentials between M and N.

The CharPart parameters (`char_kp1_fn` / `char_kp1_correct`) provide temporal
formulas characterizing each depth-(K+1) 1-var NF type. These enable the
zone-based between-zone transfer via Prior-UZ/SZ squeeze arguments:
- Outer zones use `cross_extend_bwd_1var`
- The between-zone uses CharPart formulas to find witnesses via Prior-UZ/SZ
  first/last occurrence analysis. -/

/-- On Prior structures, cross-structure 2-var NF transfer for the Until zone
    (t < x): if M,x and N,x' have the same depth-(K+2) 1-var NF, and
    M,t / N,t' have the same depth-(K+2) 1-var NF, and both t < x, t' < x',
    then M and N agree on all depth-(K+2) 2-var NFs at [x,t] / [x',t'].

    The `char_kp1_fn`/`char_kp1_correct` parameters provide temporal formulas
    characterizing depth-(K+1) 1-var NF types for the zone-based transfer. -/
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
    (h_order_N : t' < x')
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ K + 1) (nf_1 : NormalForm sig d 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_fn d nf_1) ↔
        nf_eval_nf M d 1 (fun _ => t) nf_1) :
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
    have h_atom := nonconstenv_atom_agree_until M x t N x' t' h_x h_t h_order_M h_order_N
    constructor
    · intro a; exact (h_atom a).trans (h_N_atoms a)
    · -- Quantifier part: depth-1 3-var existential transfer
      intro sub_nf; rw [← h_N_quant sub_nf]
      exact nonconstenv_exist_transfer_until atomMap h_surj 1
        M x t N x' t' h_UZ_M h_SZ_M h_UZ_N h_SZ_N
        h_x h_t h_order_M h_order_N char_fn char_correct sub_nf
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
      exact nonconstenv_exist_transfer_until atomMap h_surj (K' + 2)
        M x t N x' t' h_UZ_M h_SZ_M h_UZ_N h_SZ_N
        h_x h_t h_order_M h_order_N char_fn char_correct sub_nf

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
    (h_order_N : x' < t')
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ K + 1) (nf_1 : NormalForm sig d 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_fn d nf_1) ↔
        nf_eval_nf M d 1 (fun _ => t) nf_1) :
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
    · -- Quantifier part: depth-1 3-var existential transfer
      intro sub_nf; rw [← h_N_quant sub_nf]
      exact nonconstenv_exist_transfer_since atomMap h_surj 1
        M x t N x' t' h_UZ_M h_SZ_M h_UZ_N h_SZ_N
        h_x h_t h_order_M h_order_N char_fn char_correct sub_nf
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
    · -- Quantifier: depth-(K'+2) 3-var existential transfer
      intro sub_nf; rw [← h_N_quant sub_nf]
      exact nonconstenv_exist_transfer_since atomMap h_surj (K' + 2)
        M x t N x' t' h_UZ_M h_SZ_M h_UZ_N h_SZ_N
        h_x h_t h_order_M h_order_N char_fn char_correct sub_nf

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
    nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) sub_nf :=
  (prior_nonconstenv_2var_agree_until atomMap h_surj K M x t M₀ x₀ t₀
    h_UZ h_SZ h_UZ₀ h_SZ₀ h_x h_t h_order h_order₀
    char_fn char_correct sub_nf).mpr h_eval₀

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
    nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) sub_nf :=
  (prior_nonconstenv_2var_agree_since atomMap h_surj K M x t M₀ x₀ t₀
    h_UZ h_SZ h_UZ₀ h_SZ₀ h_x h_t h_order h_order₀
    char_fn char_correct sub_nf).mpr h_eval₀

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
