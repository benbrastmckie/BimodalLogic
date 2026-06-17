import Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass
import Bimodal.Metalogic.WeakCanonical.Kamp.NfComposition

/-!
# GeneralExistPart: Existential Characterization at Arbitrary Arity

Third mutual induction conjunct for the Kamp theorem. `GeneralExistPart(k)`
states that for any arity r >= 1, given depth-k characteristic formulas and
environment atom assignments, every depth-k (r+1)-var existential is
temporally characterizable on Prior structures.

## Key Property

The existential `∃ y, nf_eval_nf M k (r+1) (Fin.cons y e) ssn` is
determined by the depth-(k+1) r-var NF type of the environment `e`.
When two environments agree on their depth-(k+1) r-var NF, the
depth-k (r+1)-var existentials agree (by `nf_extend_fwd`/`nf_extend_bwd`).

## Architecture

- `GeneralExistPart(0)`: base case, depth-0 existentials are purely atomic
- `GeneralExistPart(k+1)`: from `CharPart(k+1)` + `GeneralExistPart(k)`
- Added to `kamp_mutual_induction` as third conjunct (Phase 3)
- Used at the sorry site in KampBypass.lean (Phase 4)

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5, Lemma 5.1
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## GeneralExistPart Definition -/

/-- GeneralExistPart(k): for all arity r >= 1, given depth-k characteristic
    formulas and a depth-(k+1) r-var NF type for the environment, every
    depth-k (r+1)-var sub-NF has a temporal formula characterizing its
    existential on Prior structures.

    The formula is evaluated at `e 0` (the first element of the environment).
    The environment must match the given NF type at depth k+1. -/
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

/-! ## GeneralExistPart Base Case (k = 0) -/

set_option maxHeartbeats 800000 in
/-- At depth 0, the existential `∃ y, nf_eval_nf M 0 (r+1) (Fin.cons y e) ssn`
    is purely atomic. The truth value is determined by the depth-1 r-var NF
    of the environment.

    For r = 1, delegates to `nf_2var_exist_formula_prior`.
    For r >= 2, uses cross-structure transfer: any two environments with the
    same depth-1 r-var NF have the same depth-0 (r+1)-var existentials
    (by nf_extend_fwd/nf_extend_bwd). The formula is chosen via a
    classical witness. -/
theorem generalExistPart_zero {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (_h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    GeneralExistPart atomMap 0 := by
  intro r hr char_0 char_0_correct env_nf ssn
  -- Classical case split: is the existential satisfiable on SOME Prior structure
  -- with an environment matching env_nf?
  rcases Classical.em (∃ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (e : Fin r → M.carrier),
      nf_eval_nf M 1 r e env_nf ∧
      ∃ y : M.carrier, nf_eval_nf M 0 (r + 1) (Fin.cons y e) ssn)
      with ⟨M₀, h_UZ₀, h_SZ₀, e₀, h_env₀, y₀, h_eval₀⟩ | h_unsat
  · -- Satisfiable: the existential is true on ALL matching environments.
    -- Use Formula.top as the temporal formula.
    -- Proof: transfer the existential via depth-1 r-var NF agreement.
    refine ⟨Formula.top, fun M h_UZ h_SZ e h_env => ?_⟩
    simp only [Formula.top, temporal_truth]
    constructor
    · -- Forward: ⊤ → ∃ y (transfer from M₀)
      intro _
      -- M and M₀ have envs with same depth-1 r-var NF
      have h_nf_agree : ∀ nf : NormalForm sig 1 r,
          nf_eval_nf M 1 r e nf ↔ nf_eval_nf M₀ 1 r e₀ nf :=
        nf_agreement_from_shared_nf M e M₀ e₀ env_nf h_env h_env₀
      -- Transfer existential: from depth-1 r-var NF agreement, find
      -- a matching witness in M (inline proof of nf_extend_fwd pattern)
      have hM := nf_characteristic_satisfies M 1 r e
      have hN := nf_characteristic_satisfies M₀ 1 r e₀
      have heq := nf_eval_unique M₀ 1 r e₀ _ _ ((h_nf_agree _).mp hM) hN
      obtain ⟨_, hMq⟩ := hM
      obtain ⟨_, hNq⟩ := heq ▸ hN
      set ch := nf_characteristic M₀ 0 (r + 1) (Fin.cons y₀ e₀)
      obtain ⟨y, hy⟩ := ((hMq ch).trans (hNq ch).symm).mpr
        ⟨y₀, nf_characteristic_satisfies M₀ 0 (r + 1) (Fin.cons y₀ e₀)⟩
      exact ⟨y, (nf_agreement_from_shared_nf M _ M₀ _ ch hy
        (nf_characteristic_satisfies M₀ 0 (r + 1) (Fin.cons y₀ e₀)) ssn).mpr h_eval₀⟩
    · -- Backward: ∃ y → ⊤ (trivial)
      intro _; trivial
  · -- Unsatisfiable: use Formula.bot
    refine ⟨Formula.bot, fun M h_UZ h_SZ e h_env => ?_⟩
    simp only [temporal_truth]
    constructor
    · intro h; exact absurd h id
    · intro ⟨y, hy⟩
      exact absurd ⟨M, h_UZ, h_SZ, e, h_env, y, hy⟩ h_unsat

/-! ## GeneralExistPart Inductive Step (k+1) -/

set_option maxHeartbeats 800000 in
/-- At depth k+1, the existential `∃ y, nf_eval_nf M (k+1) (r+1) (Fin.cons y e) ssn`
    is determined by the depth-(k+2) r-var NF of the environment, exactly as at
    depth 0. The same classical satisfiability split + cross-structure transfer
    applies: if satisfiable on any matching environment, use ⊤; otherwise ⊥.

    Neither `CharPart(k+1)` nor `GeneralExistPart(k)` is needed in the proof
    itself -- the transfer works purely at the NF level via
    `nf_agreement_from_shared_nf`. The characteristic formulas `char_k` and
    `char_k_correct` are already universally quantified inside the
    `GeneralExistPart` definition, so they arrive via `intro`.

    This means `generalExistPart_succ` has no dependencies beyond the base
    infrastructure, making the mutual induction in Phase 3 straightforward:
    `GeneralExistPart(k+1)` does not actually require `GeneralExistPart(k)`
    as an input. -/
theorem generalExistPart_succ {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) :
    GeneralExistPart atomMap (k + 1) := by
  intro r hr char_kp1 char_kp1_correct env_nf ssn
  -- Classical case split: is the existential satisfiable on SOME Prior structure
  -- with an environment matching env_nf?
  rcases Classical.em (∃ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (e : Fin r → M.carrier),
      nf_eval_nf M ((k + 1) + 1) r e env_nf ∧
      ∃ y : M.carrier, nf_eval_nf M (k + 1) (r + 1) (Fin.cons y e) ssn)
      with ⟨M₀, h_UZ₀, h_SZ₀, e₀, h_env₀, y₀, h_eval₀⟩ | h_unsat
  · -- Satisfiable: the existential is true on ALL matching environments.
    refine ⟨Formula.top, fun M h_UZ h_SZ e h_env => ?_⟩
    simp only [Formula.top, temporal_truth]
    constructor
    · -- Forward: ⊤ → ∃ y (transfer from M₀)
      intro _
      have h_nf_agree : ∀ nf : NormalForm sig ((k + 1) + 1) r,
          nf_eval_nf M ((k + 1) + 1) r e nf ↔ nf_eval_nf M₀ ((k + 1) + 1) r e₀ nf :=
        nf_agreement_from_shared_nf M e M₀ e₀ env_nf h_env h_env₀
      have hM := nf_characteristic_satisfies M ((k + 1) + 1) r e
      have hN := nf_characteristic_satisfies M₀ ((k + 1) + 1) r e₀
      have heq := nf_eval_unique M₀ ((k + 1) + 1) r e₀ _ _ ((h_nf_agree _).mp hM) hN
      obtain ⟨_, hMq⟩ := hM
      obtain ⟨_, hNq⟩ := heq ▸ hN
      set ch := nf_characteristic M₀ (k + 1) (r + 1) (Fin.cons y₀ e₀)
      obtain ⟨y, hy⟩ := ((hMq ch).trans (hNq ch).symm).mpr
        ⟨y₀, nf_characteristic_satisfies M₀ (k + 1) (r + 1) (Fin.cons y₀ e₀)⟩
      exact ⟨y, (nf_agreement_from_shared_nf M _ M₀ _ ch hy
        (nf_characteristic_satisfies M₀ (k + 1) (r + 1) (Fin.cons y₀ e₀)) ssn).mpr h_eval₀⟩
    · -- Backward: ∃ y → ⊤ (trivial)
      intro _; trivial
  · -- Unsatisfiable: use Formula.bot
    refine ⟨Formula.bot, fun M h_UZ h_SZ e h_env => ?_⟩
    simp only [temporal_truth]
    constructor
    · intro h; exact absurd h id
    · intro ⟨y, hy⟩
      exact absurd ⟨M, h_UZ, h_SZ, e, h_env, y, hy⟩ h_unsat

/-- GeneralExistPart holds for all depths k.
    Base case (k=0) by `generalExistPart_zero`.
    Inductive step (k+1) by `generalExistPart_succ`, which has no dependency
    on `GeneralExistPart(k)` -- the proof is self-contained at each depth.
    This means no mutual induction is needed for GeneralExistPart. -/
theorem generalExistPart_all {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) :
    GeneralExistPart atomMap k := by
  cases k with
  | zero => exact generalExistPart_zero atomMap h_surj
  | succ k' => exact generalExistPart_succ atomMap h_surj k'

end Bimodal.Metalogic.WeakCanonical.Kamp
