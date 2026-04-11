import Bimodal.Syntax.BigConj
import Bimodal.Metalogic.BXCanonical.Quasimodel.SubformulaClosure
import Mathlib.Data.Finset.Powerset

/-!
# Enriched (Fisher-Ladner) Closure

Defines the Fisher-Ladner style enriched Sigma-closure that adds, for every
subset `T` of the base `SubformulaClosure`, the formulas
`G(¬ (bigconj T.toList))` and `H(¬ (bigconj T.toList))`. This closes the
chain-step seed consistency gap from task 98 plan v2 by ensuring that the
`G(¬ (∧ L_h))` formulas produced by `g_content_closed_derivation` for finite
`L_h ⊆ h_{i+1}` land inside Sigma.

This file provides the Phase 1 scaffolding:
- `enrichedClosure : Formula → Finset Formula`
- `enriched_target_mem`, `enriched_subformula_mem`
- `enriched_g_neg_bigconj_mem`, `enriched_h_neg_bigconj_mem`
- `enriched_neg_pairing`

It builds as a standalone definition alongside `SubformulaClosure` so that
Phase 2 (the migration) can be executed surgically without file rewrites.

## References

- Teammate A findings (specs/098/reports/03_teammate-a-findings.md §3.2)
- Fisher-Ladner 1979: "Propositional modal logic of programs"
-/

namespace Bimodal.Metalogic.BXCanonical.Quasimodel

open Bimodal.Syntax

/-- The set of `G(¬ (bigconj T.toList))` for every subset `T` of the base. -/
noncomputable def enrichedGNegBigconj (base : Finset Formula) : Finset Formula :=
  base.powerset.image (fun T => Formula.all_future (neg_bigconj T.toList))

/-- The set of `H(¬ (bigconj T.toList))` for every subset `T` of the base. -/
noncomputable def enrichedHNegBigconj (base : Finset Formula) : Finset Formula :=
  base.powerset.image (fun T => Formula.all_past (neg_bigconj T.toList))

/-- The enriched (Fisher-Ladner) Sigma-closure for a target formula.

    Construction:
    1. Start with the base `SubformulaClosure target`.
    2. Add `G(¬ (bigconj T))` and `H(¬ (bigconj T))` for every finite subset
       `T` of the base.
    3. Close under negation once (the "core" layer).

    The result is a `Finset` (hence finite) by construction.

    Note on negation pairing: `∀ f ∈ enrichedClosure target, ¬ f ∈ enrichedClosure target`
    is NOT automatic for double-negated elements. Use `enriched_neg_pairing_core`
    which guarantees the property for elements of `enrichedCore target`. For
    the `HintikkaPoint` construction, when instantiating `Sigma := enrichedClosure target`,
    the `sigma_signature_maximal` hypothesis must be discharged from the
    MCS-negation-complete property directly (see Phase 2.5 design notes). -/
noncomputable def enrichedClosure (target : Formula) : Finset Formula :=
  let base := SubformulaClosure target
  let gAdd := enrichedGNegBigconj base
  let hAdd := enrichedHNegBigconj base
  let withMods := base ∪ gAdd ∪ hAdd
  withMods ∪ withMods.image Formula.neg

/-- The "core" layer of the enriched closure: base ∪ G-mods ∪ H-mods. -/
noncomputable def enrichedCore (target : Formula) : Finset Formula :=
  (SubformulaClosure target ∪ enrichedGNegBigconj (SubformulaClosure target))
    ∪ enrichedHNegBigconj (SubformulaClosure target)

theorem enrichedClosure_eq (target : Formula) :
    enrichedClosure target = enrichedCore target ∪ (enrichedCore target).image Formula.neg := by
  unfold enrichedClosure enrichedCore
  rfl

/-- Every element of the core is in `enrichedClosure`. -/
theorem enrichedClosure_of_core {target f : Formula}
    (h : f ∈ enrichedCore target) : f ∈ enrichedClosure target := by
  rw [enrichedClosure_eq]; exact Finset.mem_union_left _ h

/-- The target is in its own enriched closure. -/
theorem enriched_target_mem (target : Formula) :
    target ∈ enrichedClosure target :=
  enrichedClosure_of_core <| by
    unfold enrichedCore
    exact Finset.mem_union_left _ (Finset.mem_union_left _ (target_mem target))

/-- Every element of `SubformulaClosure target` is in `enrichedClosure target`. -/
theorem enriched_base_mem {target f : Formula}
    (h : f ∈ SubformulaClosure target) : f ∈ enrichedClosure target :=
  enrichedClosure_of_core <| by
    unfold enrichedCore
    exact Finset.mem_union_left _ (Finset.mem_union_left _ h)

/-- Every subformula of the target is in the enriched closure. -/
theorem enriched_subformula_mem {target f : Formula}
    (h : f ∈ subformulas target) : f ∈ enrichedClosure target :=
  enriched_base_mem (subformula_mem h)

/-- For every subset `T` of `SubformulaClosure target`,
    `G (¬ (bigconj T.toList)) ∈ enrichedClosure target`. -/
theorem enriched_g_neg_bigconj_mem {target : Formula}
    {T : Finset Formula} (hT : T ⊆ SubformulaClosure target) :
    Formula.all_future (neg_bigconj T.toList) ∈ enrichedClosure target :=
  enrichedClosure_of_core <| by
    unfold enrichedCore
    apply Finset.mem_union_left
    apply Finset.mem_union_right
    unfold enrichedGNegBigconj
    exact Finset.mem_image.mpr ⟨T, Finset.mem_powerset.mpr hT, rfl⟩

/-- Dual: `H (¬ (bigconj T.toList)) ∈ enrichedClosure target`. -/
theorem enriched_h_neg_bigconj_mem {target : Formula}
    {T : Finset Formula} (hT : T ⊆ SubformulaClosure target) :
    Formula.all_past (neg_bigconj T.toList) ∈ enrichedClosure target :=
  enrichedClosure_of_core <| by
    unfold enrichedCore
    apply Finset.mem_union_right
    unfold enrichedHNegBigconj
    exact Finset.mem_image.mpr ⟨T, Finset.mem_powerset.mpr hT, rfl⟩

/-- **Negation pairing (core)**: for every `f ∈ enrichedCore target`,
    `¬ f ∈ enrichedClosure target`.

    This is the primary property consumed by the Phase 4 chain-step seed
    consistency reduction: all formulas there are of the form
    `G(¬(∧ L_h))`, which live in the core. -/
theorem enriched_neg_of_core_mem {target f : Formula}
    (h : f ∈ enrichedCore target) :
    Formula.neg f ∈ enrichedClosure target := by
  rw [enrichedClosure_eq]
  exact Finset.mem_union_right _ (Finset.mem_image.mpr ⟨f, h, rfl⟩)

/-! ### Negation pairing (full) and HintikkaPoint adapter

The full property `∀ f ∈ enrichedClosure target, ¬f ∈ enrichedClosure target`
is NOT automatically satisfied for elements of the form `¬g` with `g ∈ core`,
because `¬¬g` is not in the closure. For `HintikkaPoint` construction at
`Sigma := enrichedClosure target`, we instead provide a specialized
`sigma_signature` variant that discharges the `locally_maximal` obligation
directly from MCS negation-completeness without needing Sigma to be closed
under double negation.

See `enrichedClosure_neg_closed_on_core` and the Phase 2.5 adapter in
`HintikkaPoint`. -/

/-- The negation-closure property holds on the core layer. This is the version
    the Phase 4 reduction actually needs. -/
theorem enrichedClosure_neg_closed_on_core (target : Formula) :
    ∀ f ∈ enrichedCore target, Formula.neg f ∈ enrichedClosure target :=
  fun _ hf => enriched_neg_of_core_mem hf

/-- The enriched closure is nonempty (contains the target). -/
theorem enriched_nonempty (target : Formula) :
    (enrichedClosure target).Nonempty :=
  ⟨target, enriched_target_mem target⟩

end Bimodal.Metalogic.BXCanonical.Quasimodel

