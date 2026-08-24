import FormalSystem.Boneyard.Kamp.KampBypassArchive.KampBypass
import FormalSystem.Boneyard.Kamp.KampWeakCanonical.NfComposition

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# GeneralExistPart: Existential Characterization via Classical Satisfiability

Temporal characterization of existentials on non-constant environments via
classical top/bot with full r-var NF precondition. The `GeneralExistPart`
formulation uses `nf_agreement_from_shared_nf` to transfer between structures.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5, Lemma 5.1
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## GeneralExistPart

GeneralExistPart (with full r-var NF precondition) is provable via
classical satisfiability (no zone decomposition needed). Used at call
sites that have the full r-var NF available. -/

/-- GeneralExistPart type with full r-var NF precondition. -/
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

end FormalSystem.Metalogic.WeakCanonical.Kamp
