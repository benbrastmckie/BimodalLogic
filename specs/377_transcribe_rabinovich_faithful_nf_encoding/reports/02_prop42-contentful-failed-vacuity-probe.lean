import Bimodal.Metalogic.WeakCanonical.Kamp.Prop42Contentful

/-!
THE MANDATORY FAILED-VACUITY CHECK (Rabinovich Prop 4.2, PDF p.6).

This file is EXPECTED TO FAIL TO COMPILE. It is a probe, not a library.

`prop42_conclusion_is_vacuous` (Kamp/Prop42Vacuity.lean) proves the shape
`∃ v', v'.holds M atomMap z0 z1` from NOTHING, using the all-`⊤` block.
This probe offers that SAME all-`⊤` witness against the CONTENTFUL shape
`Prop42Contentful` and confirms it does NOT discharge it.

If this file ever compiles, `Prop42Contentful` is vacuous and must be rejected.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

-- CONTROL (expected to COMPILE): the vacuous shape, from nothing, via the all-⊤ block.
theorem control_vacuous_shape_from_nothing {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) :
    ∃ v' : VVecEA2, v'.holds M atomMap z0 z1 :=
  ⟨topVVec, topVVec_holds M atomMap z0 z1⟩

-- PROBE (expected to FAIL): same all-⊤ witness, contentful shape, arbitrary `v`,
-- no h_INF, no h_neg, no Dedekind completeness.
theorem probe_contentful_shape_from_nothing {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA2) :
    Prop42Contentful M atomMap v := by
  refine ⟨topVVec, fun z0 z1 _ => ⟨?_, ?_⟩⟩
  · -- goal: topVVec.holds → ¬v.holds. Nothing to derive ¬v.holds from.
    intro _
    aesop
  · intro _
    exact topVVec_holds M atomMap z0 z1

end Bimodal.Metalogic.WeakCanonical.Kamp
