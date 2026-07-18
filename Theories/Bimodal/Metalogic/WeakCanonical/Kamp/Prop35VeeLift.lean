import Bimodal.Metalogic.WeakCanonical.Kamp.Prop35Assembly

/-!
# Proposition 3.5 ∨-lift ε-interface (Rabinovich 2014, Prop 3.5 + Def 3.3, PDF p.4-5)

The core one-free-variable Prop 3.5 ∨-lift is already landed sorry-free in the sibling module
`Bimodal.Metalogic.WeakCanonical.Kamp.Prop35Assembly` as `translateVeeProp35` /
`translateVeeProp35_correct`: a `∨∃∀`-formula with one free variable is satisfied iff its Prop 3.5
translation holds as temporal truth. This module provides the ε-interface the spine rewire (Phase
ζ) consumes, and makes the "disjunct-wise via `translateProp35`" structure of the lift explicit:

* `prop35_vee_lift` — the stable ε-interface biconditional (`veeSat ↔ temporal_truth of the
  ∨-lift translation`), a durable-named handle onto the landed `translateVeeProp35_correct`.
* `prop35_vee_lift_disjunctwise` — the lift stated disjunct-wise: a `∨∃∀`-formula is satisfied iff
  some disjunct's own single-`∃∀` Prop 3.5 translation (`translateProp35`) holds as temporal truth.
  This is the p.5 "each disjunct handled by Prop 3.5" reading, discharged per-disjunct via the
  landed `translateProp35_correct`.
* `prop35_vee_lift_append` — the lift distributes over list append at the temporal-truth level
  (via the landed `veeSat_append`, Def 3.3 disjunction closure): the ∨-lift translation of `Ψ ++ Φ`
  holds iff that of `Ψ` or that of `Φ` does. The reassembly step the ∨∃∀ negation case (Phase γ)
  and the spine rewire reuse.

OFF the live import path: nothing here is imported by `KampPrior.lean` or the completeness spine;
Phase ζ wires these into the live spine.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 3.5 (p.5), Definition 3.3 (p.4).
  Cited by PDF page only; the companion markdown transcription is corrupt.
- `Bimodal.Metalogic.WeakCanonical.Kamp.Prop35Assembly`: `translateProp35`, `translateProp35_correct`,
  `translateVeeProp35`, `translateVeeProp35_correct`.
- `Bimodal.Metalogic.WeakCanonical.Kamp.VeeExistsForall`: `veeSat`, `veeSat_append`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

/-- **Prop 3.5 ∨-lift, ε-interface (PDF p.5).** Durable-named handle onto the landed
`translateVeeProp35_correct`: a `∨∃∀`-formula with one free variable is satisfied iff its Prop 3.5
∨-lift translation holds as temporal truth at the pinned point. This is the interface the spine
rewire consumes for the Prop 3.5 half of Thm 4.4. -/
theorem prop35_vee_lift {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 1 → N.carrier) (Ψ : VeeExistsForall sig F 1) :
    veeSat N env Ψ ↔ temporal_truth N atomMap (env 0) (translateVeeProp35 atomMap h_surj Ψ) :=
  translateVeeProp35_correct N atomMap h_surj env Ψ

/-- **Prop 3.5 ∨-lift, disjunct-wise (PDF p.5).** A `∨∃∀`-formula with one free variable is
satisfied iff some disjunct's own single-`∃∀` Prop 3.5 translation (`translateProp35`) holds as
temporal truth — the "each disjunct handled by Prop 3.5" reading, discharged per-disjunct via the
landed `translateProp35_correct`. -/
theorem prop35_vee_lift_disjunctwise {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 1 → N.carrier) (Ψ : VeeExistsForall sig F 1) :
    veeSat N env Ψ ↔
      ∃ ψ ∈ Ψ, temporal_truth N atomMap (env 0) (translateProp35 atomMap h_surj ψ) := by
  unfold veeSat
  constructor
  · rintro ⟨ψ, hmem, hsat⟩
    exact ⟨ψ, hmem, (translateProp35_correct N atomMap h_surj env ψ).mp hsat⟩
  · rintro ⟨ψ, hmem, htt⟩
    exact ⟨ψ, hmem, (translateProp35_correct N atomMap h_surj env ψ).mpr htt⟩

/-- **Prop 3.5 ∨-lift distributes over append (Def 3.3 disjunction closure, PDF p.4).** The ∨-lift
translation of `Ψ ++ Φ` holds as temporal truth iff that of `Ψ` or that of `Φ` does, via the
landed `veeSat_append`. The reassembly step reused by the ∨∃∀ negation case and the spine rewire. -/
theorem prop35_vee_lift_append {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 1 → N.carrier) (Ψ Φ : VeeExistsForall sig F 1) :
    temporal_truth N atomMap (env 0) (translateVeeProp35 atomMap h_surj (Ψ ++ Φ)) ↔
      temporal_truth N atomMap (env 0) (translateVeeProp35 atomMap h_surj Ψ) ∨
      temporal_truth N atomMap (env 0) (translateVeeProp35 atomMap h_surj Φ) := by
  rw [← translateVeeProp35_correct N atomMap h_surj env (Ψ ++ Φ),
      ← translateVeeProp35_correct N atomMap h_surj env Ψ,
      ← translateVeeProp35_correct N atomMap h_surj env Φ]
  exact veeSat_append N env Ψ Φ

end Bimodal.Metalogic.WeakCanonical.Kamp
