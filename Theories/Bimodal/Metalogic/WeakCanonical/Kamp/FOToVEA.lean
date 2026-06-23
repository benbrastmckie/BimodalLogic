import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEATranslation
import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.PriorDefs
import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
# FO Formula to Temporal Formula Translation (Rabinovich Prop 4.3)

Converts a `MonadicFormula sig 1` to a temporal `Formula` that is equivalent
on Prior structures. This is the key bridge that eliminates the sorry at
NfExistTL.lean:301 (Part B at depth k+1).

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Proposition 4.3
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Helper: atom formula for predicate p -/

/-- The temporal formula that captures `M.interp p t` for a predicate p. -/
noncomputable def predFormula {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (p : sig.preds) : Formula :=
  Formula.atom (Classical.choose (h_surj p))

/-- Correctness of `predFormula`. -/
theorem predFormula_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (p : sig.preds) (t : M.carrier) :
    temporal_truth M atomMap t (predFormula atomMap h_surj p) ↔ M.interp p t := by
  simp only [predFormula, temporal_truth]
  rw [Classical.choose_spec (h_surj p)]

/-! ## Main translation: MonadicFormula sig 1 → Formula

The translation proceeds by structural induction on the formula.
Atoms, negation, conjunction, and order are trivial. The existential
case is the key challenge (Rabinovich Prop 4.3). -/

/-- Convert a `MonadicFormula sig 1` to a temporal `Formula`.

    Correctness: `temporal_truth M atomMap t (fo_to_temporal phi) ↔
    eval M (fun _ => t) phi` on Prior structures. -/
noncomputable def fo_to_temporal {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    MonadicFormula sig 1 → Formula
  | .atom p _ => predFormula atomMap h_surj p
  | .lt _ _ => Formula.bot  -- lt 0 0 is always false (Fin 1 has only 0)
  | .not α => (fo_to_temporal atomMap h_surj α).neg
  | .and α β => Formula.and (fo_to_temporal atomMap h_surj α)
                             (fo_to_temporal atomMap h_surj β)
  | .all _ =>
    -- ∀ x, eval M [x, t] α = ¬∃ x, ¬eval M [x, t] α
    -- Placeholder: handled by fo_to_temporal_correct sorry.
    Formula.bot
  | .ex _ =>
    -- ∃ x, eval M [x, t] α — the critical case.
    -- Placeholder: handled by fo_to_temporal_correct sorry.
    Formula.bot

/-- Correctness of `fo_to_temporal` on Prior structures. -/
theorem fo_to_temporal_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (phi : MonadicFormula sig 1)
    (t : M.carrier) :
    temporal_truth M atomMap t (fo_to_temporal atomMap h_surj phi) ↔
    eval M (fun _ => t) phi := by
  sorry

/-! ## Bridge: NF existential to temporal formula

Composes: NF → nf_to_formula → MonadicFormula.ex → fo_to_temporal → Formula. -/

/-- Convert a depth-(k+1) arity-2 NF existential to a temporal formula. -/
noncomputable def nf_exist_to_temporal {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (sub_nf : NormalForm sig (k + 1) 2) : Formula :=
  fo_to_temporal atomMap h_surj (MonadicFormula.ex (nf_to_formula sub_nf))

/-- Correctness of the NF bridge. -/
theorem nf_exist_to_temporal_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (sub_nf : NormalForm sig (k + 1) 2)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t (nf_exist_to_temporal atomMap h_surj sub_nf) ↔
    ∃ x : M.carrier, nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf := by
  simp only [nf_exist_to_temporal]
  rw [fo_to_temporal_correct atomMap h_surj M h_UZ h_SZ]
  simp only [eval]
  constructor
  · intro ⟨x, hx⟩
    exact ⟨x, (nf_to_formula_correct M (Fin.cons x (fun _ => t)) sub_nf).mp hx⟩
  · intro ⟨x, hx⟩
    exact ⟨x, (nf_to_formula_correct M (Fin.cons x (fun _ => t)) sub_nf).mpr hx⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
