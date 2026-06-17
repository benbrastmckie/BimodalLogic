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

## Mathematical Argument (Proof Sketch)

The proof requires showing: for each 3-var sub-NF `ssn` at depth `K+1`,

    (∃ y ∈ M, nf_eval M (K+1) 3 [y, x, t] ssn) ↔ (∃ y₀ ∈ N, nf_eval N (K+1) 3 [y₀, x', t'] ssn)

The y-position falls in one of five zones relative to x and t (for the t < x case):
  1. **y > x > t** (above x): y's relationship to the interval is determined by
     x's depth-(K+2) 1-var NF via `cross_extend_bwd_1var` from x.
  2. **y = x**: atom conditions only; determined by x's 1-var NF.
  3. **t < y < x** (between): This is the HARD zone. On Prior structures,
     the UZ/SZ axioms determine which 1-var types are realized in (t, x):
     if a temporal formula holds somewhere in (t, x), there is a first/last
     occurrence. Since temporal formulas characterize NF types at lower depth
     (by IH), the set of realized types in (t, x) is determined by the temporal
     theories at t and x, which in turn are determined by their 1-var NF types.
  4. **y = t**: determined by t's atom conditions (parent_atoms).
  5. **y < t** (below t): y's relationship is determined by t's depth-(K+2)
     1-var NF via `cross_extend_bwd_1var` from t.

For zones 1, 2, 4, 5 the argument uses existing cross-structure extend
theorems. Zone 3 requires the Prior-specific argument about interval types.

The x < t case is symmetric with roles of UZ/SZ swapped.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Lemma 5.1
- KampComposition.lean: `constenv_same_depth_2var` (constant-env case)
- NfComposition.lean: counterexample for non-constant general case
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Prior-Specific 2-var Transfer

The main theorem has two versions: one for the Until zone (t < x)
and one for the Since zone (x < t). The env convention in both is
`Fin.cons x (fun _ => t)` where x is at index 0 and t at index 1. -/

/-- On Prior structures, cross-structure 2-var NF transfer for the Until zone
    (t < x): if M,x and N,x' have the same depth-(K+2) 1-var NF, and
    M,t / N,t' have the same depth-(K+2) 1-var NF, and both t < x, t' < x',
    then M and N agree on all depth-(K+2) 2-var NFs at [x,t] / [x',t'].

    This is the Prior-specific composition property. FALSE on general linear
    orders (NfComposition.lean counterexample), TRUE on Prior structures
    because UZ/SZ constrain interval types sufficiently.

    Used to close the backward direction of `existPart_succ_n1_bypass` Until. -/
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
  sorry

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
  sorry

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
