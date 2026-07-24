-- ARCHIVED from Metalogic/WeakCanonical/Kamp/FoToVecEA.lean
-- Reason: Dead code — negation closure chain with no live downstream consumers
-- Archived: 2026-06-16

import Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosureProp42
import Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# FO-to-VecEA Bridge (Rabinovich 2014, Prop 4.3 + NF correspondence)

Establishes the bridge between NormalForm evaluation and the vec-EA framework.
This is the critical link enabling Phase 6 to replace P2(k+1) backward
direction with the VecEA approach.

## Mathematical Content

The key bridge theorem states: given temporal characterizations of 1-var NFs
(P1(k+1)), the 2-variable NF existence predicate
  `∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`
is expressible as a VVecEA2 formula.

Combined with VVecEA2.translateLeft_correct (Prop 3.5), this gives a temporal
formula for each 2-var NF existential, which is P2(k+1).

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Proposition 4.3 (p. 6)
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## TemporalPred construction from NF characterizations

Build TemporalPred values from NF characterization formulas. These encode
point-type and interval conditions needed for the VecEA construction. -/

/-- Construct a TemporalPred from a characterization formula. -/
def nfCharPred (char_f : Formula) : TemporalPred := ⟨char_f⟩

/-- The nfCharPred evaluates correctly. -/
theorem nfCharPred_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (char_f : Formula) (t : M.carrier) :
    (nfCharPred char_f).eval_at M atomMap t ↔ temporal_truth M atomMap t char_f :=
  Iff.rfl

/-! ## Endpoint TemporalPred from atom assignments

For the 2-var NF existence, the endpoint predicates at the free variable t
are determined by `parent_atoms`. We construct a TemporalPred that tests
whether t satisfies the parent atom assignment. -/

/-- Construct a TemporalPred that tests a conjunction of atom conditions at
    a point. Encodes `∀ p, M.interp p t ↔ pa(.pred p 0) = true` as a single
    TemporalPred using the conjunction of atom literals. -/
noncomputable def atomsPred {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (pa : AtomKind sig 1 → Bool) : TemporalPred :=
  let preds := (Fintype.elems (α := sig.preds)).val.toList
  let conjuncts := preds.map fun p =>
    let atom := Classical.choose (h_surj p)
    if pa (.pred p ⟨0, by omega⟩) then
      Formula.atom atom
    else
      (Formula.atom atom).neg
  ⟨formula_conjList conjuncts⟩

/-! ## Semantic Bridge: NF Existence ↔ Characteristic Quantifier Assignment

The key semantic fact connecting NF existence predicates to the NF
characteristic at one depth higher. This does NOT depend on any formula
construction and holds for all structures (not just Prior). -/

/-- The 2-var NF existence predicate at depth k is equivalent to the
    quantifier assignment of the depth-(k+1) 1-var characteristic NF.

    That is: `∃ x, nf_eval_nf M k 2 (x,t) sub_nf` holds iff the
    depth-(k+1) characteristic NF of t assigns `true` to `sub_nf`.

    This is a pure semantic consequence of the NF definition and does
    not require any formula construction or Prior structure properties. -/
theorem nf_exist_iff_char_quant {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (k : Nat) (t : M.carrier)
    (sub_nf : NormalForm sig k 2) :
    (∃ x : M.carrier, nf_eval_nf M k (1 + 1)
      (Fin.cons x (fun _ : Fin 1 => t)) sub_nf) ↔
    (nf_characteristic M (k + 1) 1 (fun _ => t)).2 sub_nf = true := by
  constructor
  · -- Forward: existence implies characteristic NF encodes it
    intro ⟨x, hx⟩
    have h_char := nf_characteristic_satisfies M (k + 1) 1 (fun _ => t)
    simp only [nf_characteristic, nf_eval_nf] at h_char
    simp only [nf_characteristic] at *
    exact (h_char.2 sub_nf).mp ⟨x, hx⟩
  · -- Backward: characteristic NF encoding implies existence
    intro h
    have h_char := nf_characteristic_satisfies M (k + 1) 1 (fun _ => t)
    simp only [nf_characteristic, nf_eval_nf] at h_char
    simp only [nf_characteristic] at h
    exact (h_char.2 sub_nf).mpr h

/-- The 2-var NF existence predicate can be expressed as a disjunction
    over depth-(k+1) 1-var NFs whose quantifier assignment includes sub_nf.

    This is the semantic foundation for the disjunction formula approach:
    `∃ x, nf_eval_nf M k 2 (x,t) sub_nf` iff there exists a depth-(k+1)
    1-var NF `nf_1` with `nf_1.2(sub_nf) = true` that is realized at t. -/
theorem nf_exist_iff_nf1_disjunction {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (k : Nat) (t : M.carrier)
    (sub_nf : NormalForm sig k 2) :
    (∃ x : M.carrier, nf_eval_nf M k (1 + 1)
      (Fin.cons x (fun _ : Fin 1 => t)) sub_nf) ↔
    (∃ nf_1 : NormalForm sig (k + 1) 1,
      nf_1.2 sub_nf = true ∧
      nf_eval_nf M (k + 1) 1 (fun _ => t) nf_1) := by
  rw [nf_exist_iff_char_quant]
  constructor
  · intro h
    let nf_t := nf_characteristic M (k + 1) 1 (fun _ => t)
    exact ⟨nf_t, h, nf_characteristic_satisfies M (k + 1) 1 (fun _ => t)⟩
  · intro ⟨nf_1, h_sub, h_eval⟩
    -- By NF uniqueness, nf_1 = characteristic NF of t at depth k+1
    obtain ⟨nf_c, h_eval_c, h_unique⟩ := nf_exists_unique M (k + 1) 1 (fun _ => t)
    have h_nf_t := nf_characteristic_satisfies M (k + 1) 1 (fun _ => t)
    have h_eq1 : nf_1 = nf_c := h_unique nf_1 h_eval
    have h_eq2 : nf_characteristic M (k + 1) 1 (fun _ => t) = nf_c :=
      h_unique _ h_nf_t
    -- nf_1 = nf_c = nf_characteristic, so .2 sub_nf matches
    have : nf_1.2 sub_nf = (nf_characteristic M (k + 1) 1 (fun _ => t)).2 sub_nf := by
      rw [h_eq1, h_eq2]
    rw [← this]
    exact h_sub

/-! ## P2 from P1: Deriving temporal formulas for NF existence from
    temporal characterizations at one depth higher.

    Given P1(k+1) (temporal formulas for all depth-(k+1) 1-var NFs),
    P2(k) follows: the existential `∃ x, nf_eval_nf M k 2 (x,t) sub_nf`
    is the disjunction of those P1(k+1) formulas whose NF includes sub_nf
    in its quantifier assignment. -/

/-- **P2 from P1+1**: Given temporal characterizations of all depth-(k+1)
    1-var NFs (P1(k+1)), produce a temporal formula for the depth-k 2-var
    NF existence predicate (P2(k)).

    The formula is: `disjList [char_{k+1}(nf_1) | nf_1.2(sub_nf) = true
    ∧ nf_1.1 compatible with parent_atoms]`.

    Both directions follow immediately from `nf_exist_iff_nf1_disjunction`
    and `nf_eval_nf` semantics at depth k+1. No composition lemma needed. -/
noncomputable def p2_from_p1_succ
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
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
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  -- Build the disjunction formula: disjList of char_{k+1}(nf_1) for compatible nf_1
  let all_nfs := (Fintype.elems (α := NormalForm sig (k + 1) 1)).val.toList
  let compat_nf1s := all_nfs.filter fun nf_1 =>
    nf_1.2 sub_nf &&
    -- atom compatibility: nf_1's atoms at var 0 match parent_atoms
    (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
      nf_1.atom_assgn (.pred p ⟨0, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)
  let formula := formula_disjList (compat_nf1s.map fun nf_1 => char_kp1 nf_1)
  refine ⟨formula, fun M h_UZ h_SZ t h_atoms => ?_⟩
  rw [nf_exist_iff_nf1_disjunction]
  constructor
  · -- Backward (formula → existence): extract nf_1 from disjunction
    intro h_formula
    rw [formula_disjList_iff] at h_formula
    obtain ⟨A, hA_mem, hA_eval⟩ := h_formula
    rw [List.mem_map] at hA_mem
    obtain ⟨nf_1, h_nf1_mem, rfl⟩ := hA_mem
    have h_nf1_compat := (List.mem_filter.mp h_nf1_mem).2
    simp only [Bool.and_eq_true, List.all_eq_true, beq_iff_eq] at h_nf1_compat
    exact ⟨nf_1, h_nf1_compat.1, (char_kp1_correct nf_1 M h_UZ h_SZ t).mp hA_eval⟩
  · -- Forward (existence → formula): find the right nf_1 in disjunction
    intro ⟨nf_1, h_sub, h_eval⟩
    rw [formula_disjList_iff]
    refine ⟨char_kp1 nf_1, ?_, (char_kp1_correct nf_1 M h_UZ h_SZ t).mpr h_eval⟩
    rw [List.mem_map]
    refine ⟨nf_1, List.mem_filter.mpr ⟨?_, ?_⟩, rfl⟩
    · exact Multiset.mem_toList.mpr (Fintype.complete nf_1)
    · simp only [Bool.and_eq_true, List.all_eq_true, beq_iff_eq]
      refine ⟨h_sub, fun p _ => ?_⟩
      -- nf_1's atoms match parent_atoms because nf_eval_nf at depth k+1 implies
      -- the atom assignment at var 0 matches the parent atom assignment
      have h_nf1_atoms := h_eval.1
      have h_nf1_p := h_nf1_atoms (.pred p ⟨0, by omega⟩)
      simp only [atom_eval] at h_nf1_p
      have h_p := h_atoms (.pred p ⟨0, by omega⟩)
      simp only [atom_eval] at h_p
      simp only [NormalForm.atom_assgn]
      by_cases hp : M.interp p t
      · rw [h_nf1_p.mp hp, h_p.mp hp]
      · have h1 := mt h_p.mpr hp
        have h2 := mt h_nf1_p.mpr hp
        simp only [Bool.not_eq_true] at h1 h2
        rw [h1, h2]

end Bimodal.Metalogic.WeakCanonical.Kamp
