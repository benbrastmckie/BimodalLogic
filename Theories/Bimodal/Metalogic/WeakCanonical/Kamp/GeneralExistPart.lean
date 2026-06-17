import Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass
import Bimodal.Metalogic.WeakCanonical.Kamp.NfComposition

/-!
# GeneralExistPartIndiv: Existential Characterization with Individual 1-var NFs

Third mutual induction conjunct for the Kamp theorem. Redesigned from
the original `GeneralExistPart` which used a full r-var NF precondition
(`env_nf : NormalForm sig (k+1) r`) and produced Formula.top/bot via
classical satisfiability. That approach is provably unusable at the sorry
sites in KampBypass.lean because:
1. The full r-var NF precondition is circular (it IS the goal being proved)
2. Formula.top/bot carries no information when embedded in enriched formulas

## Redesign: Individual 1-var NF Parameters

`GeneralExistPartIndiv(k)` takes individual 1-var NF types for each
environment element (`env_nfs : Fin r → NormalForm sig (k+1) 1`) instead
of a single r-var NF type. The precondition becomes
`∀ i, nf_eval_nf M (k+1) 1 (fun _ => e i) (env_nfs i)`, which IS
satisfiable at the sorry sites (from h_x_eval and h_t_eval).

The formula A must be an ACTUAL temporal formula (not top/bot) built via
zone decomposition per Rabinovich Prop 3.5.

## Architecture

- `GeneralExistPartIndiv(0)`: base case with zone decomposition
- `GeneralExistPartIndiv(k+1)`: from `CharPart(k+1)` + `GeneralExistPartIndiv(k)`
- Added to `kamp_mutual_induction` as third conjunct (Phase 3)
- Used at the sorry site in KampBypass.lean (Phase 4)

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

/-! ## GeneralExistPartIndiv Definition -/

/-- GeneralExistPartIndiv(k): for all arity r >= 1, given depth-k
    characteristic formulas and individual depth-(k+1) 1-var NF types
    for each environment element, every depth-k (r+1)-var sub-NF has a
    temporal formula characterizing its existential on Prior structures.

    Key differences from GeneralExistPart:
    - Uses `env_nfs : Fin r → NormalForm sig (k+1) 1` (individual 1-var NFs)
      instead of `env_nf : NormalForm sig (k+1) r` (full r-var NF)
    - Precondition: `∀ i, nf_eval_nf M (k+1) 1 (fun _ => e i) (env_nfs i)`
      instead of `nf_eval_nf M (k+1) r e env_nf`
    - Formula is evaluated at `e 0` (first environment element)
    - Formula must be an actual temporal formula (zone decomposition),
      not top/bot from classical satisfiability -/
abbrev GeneralExistPartIndiv {sig : MonadicSignature}
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
    (ssn : NormalForm sig k (r + 1)),
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (e : Fin r → M.carrier),
        (∀ i, nf_eval_nf M (k + 1) 1 (fun _ => e i) (env_nfs i)) →
        (temporal_truth M atomMap (e ⟨0, by omega⟩) A ↔
         ∃ y : M.carrier, nf_eval_nf M k (r + 1) (Fin.cons y e) ssn)

/-! ## Backward Compatibility: GeneralExistPart from GeneralExistPartIndiv

The old `GeneralExistPart` (with full r-var NF precondition) is derivable
from `GeneralExistPartIndiv`: a full r-var NF agreement implies individual
1-var NF agreements (by projection). This preserves the existing call sites
in KampMutualInduction.lean while we migrate to the new definition. -/

/-- The old GeneralExistPart type, preserved for backward compatibility.
    Will be removed once all call sites are migrated. -/
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

/-! ## GeneralExistPartIndiv Base Case (k = 0) -/

set_option maxHeartbeats 800000 in
/-- At depth 0, `nf_eval_nf M 0 (r+1) (Fin.cons y e) ssn` is purely atomic.
    The existential `∃ y, nf_eval_nf M 0 (r+1) (Fin.cons y e) ssn` is
    characterized by a temporal formula built via zone decomposition.

    For now, uses classical satisfiability to produce the formula.
    TODO: Replace with actual zone decomposition (Rabinovich Prop 3.5)
    to produce informative formulas instead of top/bot. -/
theorem generalExistPartIndiv_zero {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    GeneralExistPartIndiv atomMap 0 := by
  intro r hr char_0 char_0_correct env_nfs ssn
  -- For the base case, we use a classical satisfiability argument:
  -- If the existential is satisfiable on SOME Prior structure with
  -- matching individual 1-var NFs, we need to determine if it's
  -- satisfiable on ALL such structures. At depth 0, the existential
  -- is purely atomic, so individual 1-var NFs may NOT determine it
  -- (the counterexample shows this). However, the formula must still
  -- exist — it may just need to be a zone decomposition formula
  -- rather than top/bot.
  --
  -- Phase 1 deliverable: sorry for the actual construction.
  -- The type signature is the key deliverable of this phase.
  sorry

/-! ## GeneralExistPartIndiv Inductive Step (k+1) -/

set_option maxHeartbeats 800000 in
/-- At depth k+1, the existential `∃ y, nf_eval_nf M (k+1) (r+1) (Fin.cons y e) ssn`
    decomposes into:
    1. Atom part: predicates and orders at y relative to e
    2. Quantifier part: for each sub : NF(k, r+2), the existential condition

    Uses CharPart(k+1) for the atom part and GeneralExistPartIndiv(k) for
    the quantifier part (at arity r+1). -/
theorem generalExistPartIndiv_succ {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    -- CharPart(k+1) inlined since it's defined in KampMutualInduction.lean
    (ih_char_succ : ∀ (nf : NormalForm sig (k + 1) 1),
        ∃ (A : Formula),
          ∀ (M : OrderedMonadicStructure sig)
            (h_UZ : semantic_prior_UZ M atomMap)
            (h_SZ : semantic_prior_SZ M atomMap)
            (t : M.carrier),
            temporal_truth M atomMap t A ↔ nf_eval_nf M (k + 1) 1 (fun _ => t) nf)
    (ih_gen_exist_k : GeneralExistPartIndiv atomMap k) :
    GeneralExistPartIndiv atomMap (k + 1) := by
  intro r hr char_kp1 char_kp1_correct env_nfs ssn
  -- Phase 2 deliverable: actual zone decomposition + quantifier conjunction.
  sorry

/-! ## Backward Compatibility Theorems -/

set_option maxHeartbeats 800000 in
/-- GeneralExistPart(k) is self-contained: the classical top/bot argument
    works with the full r-var NF precondition (cross-structure transfer via
    nf_agreement_from_shared_nf). This does NOT depend on GeneralExistPartIndiv.
    Preserved for backward compatibility with KampMutualInduction call sites. -/
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
      obtain ⟨_, hMq⟩ := hM
      obtain ⟨_, hNq⟩ := heq ▸ hN
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

/-- GeneralExistPart holds for all depths k.
    Uses the self-contained classical argument (no GeneralExistPartIndiv
    dependency). Preserves existing call sites in KampMutualInduction. -/
theorem generalExistPart_all {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (_h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) :
    GeneralExistPart atomMap k :=
  generalExistPart_from_classical atomMap k

end Bimodal.Metalogic.WeakCanonical.Kamp
