import Bimodal.Metalogic.WeakCanonical.Kamp.Prop43Translate
import Bimodal.Metalogic.WeakCanonical.Kamp.Prop35VeeLift
import Bimodal.Metalogic.WeakCanonical.Kamp.ESigmaCapture
import Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior
import Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF
import Bimodal.Metalogic.WeakCanonical.PriorDefs

/-!
ζ-wire viability probe (OFF-GRAPH: not imported by anything; built with `lake env lean`).
Attempts to compose translate_correct + prop35_vee_lift + esigmaCapture_canonExpand into the
per-M equivalence the ζ rewire needs, to expose which obligations are unlanded.
-/

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Kamp

namespace ZetaProbe

variable {sig : MonadicSignature} {F : Finset Formula}

/-- PROBE 1: The atomMap the canonExpand conservativity forces (`oldPred ∘ g`) cannot satisfy the
    `h_surj` that `translate_correct` / `prop35_vee_lift` require (surjective onto
    `sig.preds ⊕ {A // A ∈ F}`), because `oldPred = Sum.inl` never hits `Sum.inr`. -/
example (g : Formula → sig.preds) (A₀ : Formula) (hA₀ : A₀ ∈ F)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, (fun φ => oldPred (g φ)) (.atom a) = p) :
    False := by
  obtain ⟨a, ha⟩ := h_surj (esigmaPred A₀ hA₀)
  -- ha : oldPred (g (.atom a)) = esigmaPred A₀ hA₀, i.e. Sum.inl _ = Sum.inr _
  simp only [oldPred, esigmaPred] at ha
  exact Sum.inl_ne_inr ha

/-- PROBE 2: attempt the per-M ζ equivalence composition, leaving unlanded obligations as holes. -/
example (M : OrderedMonadicStructure sig) (g : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M g) (h_SZ : semantic_prior_SZ M g)
    (t : M.carrier)
    (psi : MonadicFormula (sigE sig F) 1)          -- NOTE: already over sigE (lift is a separate gap)
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p) :
    True := by
  classical
  set sat : Formula → M.carrier → Prop := fun B x => temporal_truth M g x B with hsat
  set N := canonExpand sig F M sat with hN
  -- OBLIGATION A: HasAttainedINF N atomMap (translate_correct needs it).
  --   prior_hasAttainedINF needs `semantic_prior_UZ N atomMap` which is UNLANDED for canonExpand.
  have hINF : HasAttainedINF N atomMap := by
    apply prior_hasAttainedINF N atomMap
    sorry  -- GAP-A: semantic_prior_UZ (canonExpand …) atomMap
  have hSUP : HasAttainedSUP N atomMap := by
    apply prior_hasAttainedSUP N atomMap
    sorry  -- GAP-A': semantic_prior_SZ (canonExpand …) atomMap
  -- OBLIGATION B: hCapture on N via esigmaCapture (needs atomMap = oldPred ∘ g; CLASHES with h_surj).
  have hne : Nonempty N.carrier := ⟨t⟩
  -- translate + prop35 to get a formula, gated on StrictMono env (free at arity 1).
  obtain ⟨Ψ, _hmono, hΨ⟩ :=
    translate_correct (F := F) N atomMap h_surj hINF hSUP
      (fun A => by
        -- GAP-B: esigmaCapture_canonExpand requires atomMap = oldPred ∘ g, which contradicts h_surj.
        sorry) hne psi
  trivial

end ZetaProbe
