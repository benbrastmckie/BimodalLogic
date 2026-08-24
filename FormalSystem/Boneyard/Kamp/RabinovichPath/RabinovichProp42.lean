-- ARCHIVED from Metalogic/WeakCanonical/Kamp/RabinovichProp42.lean
-- Reason: Dead code — Rabinovich approach path with no live downstream consumers
-- Archived: 2026-06-16

import FormalSystem.Boneyard.Kamp.KampNegationClosure.NegationClosure

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Rabinovich Proposition 4.2: Wiring Negation Closure to NF Existentials

This file documents the sole remaining sorry on the Kamp theorem critical path
and provides wiring from the existing infrastructure.

## Sorry Chain Summary

The Kamp theorem (`kamp_prior_expressive_completeness`) depends on:
1. `nf_characterizable_temporal_prior` (KampPrior.lean) -- sorry-free given:
2. `nf_2var_exist_formula_prior` (NfCharFormula.lean:572) -- SORRY
3. → Used by `nf_characterizable_temporal_prior_classical`
4. → Used by `charPart_succ` (RabinovichGeneralized.lean)
5. → Used by `kamp_mutual_induction`

## The Sole Blocker

The sorry at NfCharFormula.lean:572 can be filled by `nf_2var_exist_formula_prior_fill`
(NegationClosure.lean:1816), which uses `master_induction`. The sole sorry in
`master_induction` is at `nf_exist_formula_nested_backward` (NegationClosure.lean:1712).

`nf_exist_formula_nested_backward` requires proving: given the temporal formula for
`nf_exist_formula_nested` holds at t, then `∃ x, nf_eval_nf M (k+1) 2 (x, t) sub_nf`.

The formula correctly encodes interval-zone quantifier conditions via nested
Since/Until. Non-interval zones (y > x, y = x, y = t, y < t) are filtered by
`nf_full_compat_right` which checks atom compatibility but NOT full quantifier
conditions. This makes the backward direction unprovable without a composition
argument showing non-interval 3-var existentials are determined by the 1-var NFs.

## Existing Sorry-Free Infrastructure

The following are ALL sorry-free:
- `neg_interval_formula` (Lemma 5.1): NegationClosure5.lean
- `neg_2var_vec_ea` (Prop 4.2): NegationClosureProp42.lean
- `VVecEA2.translateLeft_correct`: VecEATranslation.lean
- `VVecEA2.conj_holds_vvecEA2`: VecEAClosure.lean
- `nf_exist_formula_nested_forward`: NegationClosure.lean
- `backward_2var_nf_agreement`: NegationClosure.lean

## What Is Needed

Fill `nf_exist_formula_nested_backward` (NegationClosure.lean:1712). This requires
either:

(A) A composition lemma: for fixed order between x and t, and fixed depth-(k+1)
    1-var NFs of x and t, the 3-var existential `∃ y, nf_eval_nf M k 3 (y,x,t) ssn`
    with y in a non-interval zone is determined by the 1-var NFs.

(B) A different formula construction that encodes ALL quantifier conditions
    (including non-interval zones) directly, making the backward direction trivial.

(C) A different proof strategy that avoids the backward direction entirely
    (e.g., direct classical existence proof using VecEA2 infrastructure).

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5
- Doets 1989, Lemma 1.4/1.5 (composition for linear orders)
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Wiring: master_induction → ExistPart

The `master_induction` from NegationClosure.lean provides P1(k) ∧ P2(k) for all k.
P2(k) gives temporal characterization of 2-var existentials at depth k.
The sole sorry is in `nf_exist_formula_nested_backward`.

`nf_2var_exist_formula_prior_fill` extracts P2(k) for direct use.
`existPart_succ_n1_via_master` wires it into the ExistPart framework. -/

/-- ExistPart at depth k+1, arity 2 (n=1), using the master induction.
    Fills the n=1 case of `existPart_succ`. Sorry status matches
    `master_induction` (sorry-free at k=0, sorry at k>=1 through
    `nf_exist_formula_nested_backward`). -/
theorem existPart_succ_n1_via_master
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (_char_kp1 : NormalForm sig (k + 1) 1 → Formula)
    (_char_kp1_correct : ∀ (nf_k : NormalForm sig (k + 1) 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (_char_kp1 nf_k) ↔
        nf_eval_nf M (k + 1) 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k + 1) 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M (k + 1) (1 + 1)
           (Fin.cons x (fun _ => t)) sub_nf) :=
  nf_2var_exist_formula_prior_fill atomMap h_surj (k + 1) parent_atoms sub_nf

end FormalSystem.Metalogic.WeakCanonical.Kamp
