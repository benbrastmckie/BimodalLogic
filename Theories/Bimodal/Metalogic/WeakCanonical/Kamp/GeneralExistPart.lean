import Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass
import Bimodal.Metalogic.WeakCanonical.Kamp.NfComposition

/-!
# GeneralExistPart: Existential Characterization with Individual 1-var NFs + Orders

Third mutual induction conjunct for the Kamp theorem. Provides temporal
characterization of existentials on non-constant environments, where individual
1-var NF types and pairwise orders are known.

## Key Design Choice: Including Pairwise Orders

`GeneralExistPartIndiv` (without orders) is FALSE: a temporal formula at e(0)
cannot determine the order of e(1) relative to e(0), but the existential truth
value can depend on this order (Z counterexample: integers with uniform predicate,
[0,2] vs [0,1] have same 1-var NFs but different between-zone existentials).

`GeneralExistPartOrdered` (with orders) IS true: the formula can be specialized
to the known order configuration, using zone decomposition (Rabinovich Prop 3.5).
At the sorry sites, the order IS known (t < x for Until, x < t for Since).

## Architecture

- `GeneralExistPartOrdered(0)`: zone decomposition at depth 0
- `GeneralExistPartOrdered(k+1)`: from CharPart(k+1) + GeneralExistPartOrdered(k)
- Added to `kamp_mutual_induction` as third conjunct
- Used at the sorry site in KampBypass.lean

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5, Lemma 5.1
- Rabinovich 2014, Proposition 3.5 (zone decomposition)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## GeneralExistPartOrdered Definition -/

/-- GeneralExistPartOrdered(k): for all arity r >= 1, given depth-k
    characteristic formulas, individual depth-(k+1) 1-var NF types
    for each environment element, and pairwise order specifications,
    every depth-k (r+1)-var sub-NF has a temporal formula characterizing
    its existential on Prior structures.

    Key parameters:
    - `env_nfs : Fin r → NormalForm sig (k+1) 1` (individual 1-var NFs)
    - `env_atoms : AtomKind sig r → Bool` (atom specification for the env,
      including predicates and pairwise orders)
    - Precondition: individual 1-var NF eval + atom eval match
    - Formula evaluated at `e 0` (first environment element) -/
abbrev GeneralExistPartOrdered {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (k : Nat) : Prop :=
  ∀ (r : Nat) (_ : r ≥ 1)
    (char_k : NormalForm sig k 1 → Formula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (env_nfs : Fin r → NormalForm sig (k + 1) 1)
    (env_atoms : AtomKind sig r → Bool)
    (ssn : NormalForm sig k (r + 1)),
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (e : Fin r → M.carrier),
        (∀ i, nf_eval_nf M (k + 1) 1 (fun _ => e i) (env_nfs i)) →
        (∀ a : AtomKind sig r, atom_eval M e a ↔ env_atoms a = true) →
        (temporal_truth M atomMap (e ⟨0, by omega⟩) A ↔
         ∃ y : M.carrier, nf_eval_nf M k (r + 1) (Fin.cons y e) ssn)

/-! ## Backward Compatibility: GeneralExistPart

The old `GeneralExistPart` (with full r-var NF precondition) is still provable
via classical satisfiability (no zone decomposition needed). Preserved for
call sites that have the full r-var NF available. -/

/-- The old GeneralExistPart type with full r-var NF precondition. -/
abbrev GeneralExistPart {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (k : Nat) : Prop :=
  ∀ (r : Nat) (_ : r ≥ 1)
    (char_k : NormalForm sig k 1 → Formula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (env_nf : NormalForm sig (k + 1) r)
    (ssn : NormalForm sig k (r + 1)),
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (e : Fin r → M.carrier),
        nf_eval_nf M (k + 1) r e env_nf →
        (temporal_truth M atomMap (e ⟨0, by omega⟩) A ↔
         ∃ y : M.carrier, nf_eval_nf M k (r + 1) (Fin.cons y e) ssn)

/-! ## GeneralExistPartOrdered Base Case (k = 0) -/

set_option maxHeartbeats 800000 in
/-- At depth 0, `nf_eval_nf M 0 (r+1) (Fin.cons y e) ssn` is purely atomic.
    The existential decomposes by zone: y's position relative to e(0), ..., e(r-1).
    For each zone, the existential reduces to "exists point with matching predicates
    in that zone", which is characterizable by temporal formulas on Prior structures.

    The formula is a disjunction over compatible zones and 1-var NF types for y. -/
theorem generalExistPartOrdered_zero {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    GeneralExistPartOrdered atomMap 0 := by
  intro r hr char_0 char_0_correct env_nfs env_atoms ssn
  -- At depth 0, the existential is purely atomic.
  -- Use classical satisfiability: the truth value of the existential
  -- depends on whether the atomic constraints in ssn are compatible
  -- with env_atoms. Since env_atoms fully determines the atom part
  -- of the environment, and the existential only involves atoms,
  -- the truth value is DETERMINED by env_atoms (not structure-dependent).
  --
  -- Key insight: at depth 0, the env_atoms precondition (which includes
  -- pairwise orders) plus the ssn's atom constraints on y determine
  -- whether a compatible y exists. On Prior structures, y exists iff
  -- the zone is non-empty and the predicate constraints are consistent.
  --
  -- Since this is a Boolean property of ssn and env_atoms (not depending
  -- on which specific Prior structure M is), classical top/bot DOES work
  -- at depth 0 with the env_atoms precondition.
  rcases Classical.em (∃ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (e : Fin r → M.carrier),
      (∀ i, nf_eval_nf M 1 1 (fun _ => e i) (env_nfs i)) ∧
      (∀ a : AtomKind sig r, atom_eval M e a ↔ env_atoms a = true) ∧
      ∃ y : M.carrier, nf_eval_nf M 0 (r + 1) (Fin.cons y e) ssn)
      with ⟨M₀, h_UZ₀, h_SZ₀, e₀, h_nfs₀, h_atoms₀, y₀, h_eval₀⟩ | h_unsat
  · -- Satisfiable on some Prior structure: use Formula.top
    -- Need to show it's satisfiable on ALL Prior structures with matching env
    refine ⟨Formula.top, fun M h_UZ h_SZ e h_nfs h_atoms => ?_⟩
    simp only [Formula.top, temporal_truth]
    constructor
    · -- top → ∃ y
      intro _
      -- At depth 0, nf_eval_nf is purely atomic.
      -- The env atoms match between M and M₀ (both satisfy env_atoms).
      -- The y₀ conditions from ssn involve:
      --   1. Predicates at y₀ (independent of env)
      --   2. Orders between y₀ and env elements (zone-dependent)
      -- Since both M and M₀ satisfy the same env_atoms, the zone
      -- structure is the same. On Prior structures, the same zone
      -- has elements with the same predicates.
      --
      -- Extract y₀'s properties from h_eval₀
      -- ssn is at depth 0, so nf_eval_nf M₀ 0 (r+1) [y₀, e₀] ssn
      -- means: ∀ a : AtomKind sig (r+1), atom_eval M₀ [y₀, e₀] a ↔ ssn a = true
      --
      -- We need to find y in M with the same atomic profile.
      -- y₀ has specific predicates and orders relative to e₀.
      -- The orders of y₀ relative to e₀ determine a zone.
      -- By Prior density (UZ/SZ), y exists in M in the same zone
      -- with the same predicates.
      sorry -- TODO: Zone decomposition at depth 0
    · intro _; trivial
  · -- Unsatisfiable: use Formula.bot
    refine ⟨Formula.bot, fun M h_UZ h_SZ e h_nfs h_atoms => ?_⟩
    simp only [temporal_truth]
    constructor
    · intro h; exact absurd h id
    · intro ⟨y, hy⟩
      exact absurd ⟨M, h_UZ, h_SZ, e, h_nfs, h_atoms, y, hy⟩ h_unsat

/-! ## GeneralExistPartOrdered Inductive Step (k+1) -/

set_option maxHeartbeats 800000 in
/-- At depth k+1, decompose into atom part + quantifier part.
    Atom part: same zone decomposition as depth 0.
    Quantifier part: for each sub : NF(k, r+2), use GeneralExistPartOrdered(k)
    at arity r+1 to characterize the sub-existential. -/
theorem generalExistPartOrdered_succ {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (ih_char_succ : ∀ (nf : NormalForm sig (k + 1) 1),
        ∃ (A : Formula),
          ∀ (M : OrderedMonadicStructure sig)
            (h_UZ : semantic_prior_UZ M atomMap)
            (h_SZ : semantic_prior_SZ M atomMap)
            (t : M.carrier),
            temporal_truth M atomMap t A ↔ nf_eval_nf M (k + 1) 1 (fun _ => t) nf)
    (ih_gen_exist_k : GeneralExistPartOrdered atomMap k) :
    GeneralExistPartOrdered atomMap (k + 1) := by
  intro r hr char_kp1 char_kp1_correct env_nfs env_atoms ssn
  -- Same classical satisfiability approach as the base case,
  -- but now the quantifier part uses ih_gen_exist_k.
  sorry

/-! ## Backward Compatibility Theorems -/

set_option maxHeartbeats 800000 in
/-- GeneralExistPart(k) via classical top/bot with full r-var NF precondition. -/
theorem generalExistPart_from_classical {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (k : Nat) :
    GeneralExistPart atomMap k := by
  intro r hr char_k char_k_correct env_nf ssn
  rcases Classical.em (∃ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (e : Fin r → M.carrier),
      nf_eval_nf M (k + 1) r e env_nf ∧
      ∃ y : M.carrier, nf_eval_nf M k (r + 1) (Fin.cons y e) ssn)
      with ⟨M₀, h_UZ₀, h_SZ₀, e₀, h_env₀, y₀, h_eval₀⟩ | h_unsat
  · -- Satisfiable: use Formula.top
    refine ⟨Formula.top, fun M h_UZ h_SZ e h_env => ?_⟩
    simp only [Formula.top, temporal_truth]
    constructor
    · intro _
      have h_nf_agree : ∀ nf : NormalForm sig (k + 1) r,
          nf_eval_nf M (k + 1) r e nf ↔ nf_eval_nf M₀ (k + 1) r e₀ nf :=
        nf_agreement_from_shared_nf M e M₀ e₀ env_nf h_env h_env₀
      have hM := nf_characteristic_satisfies M (k + 1) r e
      have hN := nf_characteristic_satisfies M₀ (k + 1) r e₀
      have heq := nf_eval_unique M₀ (k + 1) r e₀ _ _ ((h_nf_agree _).mp hM) hN
      obtain ⟨_, hMq⟩ := hM; obtain ⟨_, hNq⟩ := heq ▸ hN
      set ch := nf_characteristic M₀ k (r + 1) (Fin.cons y₀ e₀)
      obtain ⟨y, hy⟩ := ((hMq ch).trans (hNq ch).symm).mpr
        ⟨y₀, nf_characteristic_satisfies M₀ k (r + 1) (Fin.cons y₀ e₀)⟩
      exact ⟨y, (nf_agreement_from_shared_nf M _ M₀ _ ch hy
        (nf_characteristic_satisfies M₀ k (r + 1) (Fin.cons y₀ e₀)) ssn).mpr h_eval₀⟩
    · intro _; trivial
  · -- Unsatisfiable: use Formula.bot
    refine ⟨Formula.bot, fun M h_UZ h_SZ e h_env => ?_⟩
    simp only [temporal_truth]
    constructor
    · intro h; exact absurd h id
    · intro ⟨y, hy⟩
      exact absurd ⟨M, h_UZ, h_SZ, e, h_env, y, hy⟩ h_unsat

/-- GeneralExistPart holds for all depths k. -/
theorem generalExistPart_all {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (_h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) :
    GeneralExistPart atomMap k :=
  generalExistPart_from_classical atomMap k

end Bimodal.Metalogic.WeakCanonical.Kamp
