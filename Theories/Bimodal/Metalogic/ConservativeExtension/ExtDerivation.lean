import Bimodal.Metalogic.ConservativeExtension.ExtFormula
import Bimodal.ProofSystem.Derivation

/-!
# Extended Proof System for Conservative Extension

This module defines the extended axiom and derivation types that mirror the base
proof system but use `ExtFormula` (with `ExtAtom := Atom ⊕ Unit`).

The key construction is `embedDerivation`, which lifts any base derivation
to an extended derivation, preserving the proof structure.

## Main Definitions

- `ExtAxiom`: Axiom schemata for the extended language (mirrors `Axiom` exactly)
- `ExtAxiom.minFrameClass`: Frame class assignment mirroring `Axiom.minFrameClass`
- `ExtDerivationTree`: Derivation trees parameterized by `FrameClass`
- `embedAxiom`: Lifting of base axioms to extended axioms
- `embedDerivation`: Lifting of base derivations to extended derivations

## References

-/

namespace Bimodal.Metalogic.ConservativeExtension

open Bimodal.Syntax
open Bimodal.ProofSystem

/-- Context in the extended language. -/
abbrev ExtContext := List ExtFormula

/--
Axiom schemata for the extended proof system.
Mirrors all axiom schemas from `Bimodal.ProofSystem.Axiom` but over `ExtFormula`.
-/
inductive ExtAxiom : ExtFormula → Type where
  -- Layer 1: Propositional (4)
  | prop_k (φ ψ χ : ExtFormula) :
      ExtAxiom ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))
  | prop_s (φ ψ : ExtFormula) : ExtAxiom (φ.imp (ψ.imp φ))
  | ex_falso (φ : ExtFormula) : ExtAxiom (ExtFormula.bot.imp φ)
  | peirce (φ ψ : ExtFormula) : ExtAxiom (((φ.imp ψ).imp φ).imp φ)

  -- Layer 2: S5 Modal (5)
  | modal_t (φ : ExtFormula) : ExtAxiom (ExtFormula.box φ |>.imp φ)
  | modal_4 (φ : ExtFormula) :
      ExtAxiom ((ExtFormula.box φ).imp (ExtFormula.box (ExtFormula.box φ)))
  | modal_b (φ : ExtFormula) :
      ExtAxiom (φ.imp (ExtFormula.box φ.diamond))
  | modal_5_collapse (φ : ExtFormula) :
      ExtAxiom (φ.box.diamond.imp φ.box)
  | modal_k_dist (φ ψ : ExtFormula) :
      ExtAxiom ((φ.imp ψ).box.imp (φ.box.imp ψ.box))

  -- Layer 3: BX Temporal
  | serial_future :
      ExtAxiom (ExtFormula.top.imp (ExtFormula.some_future ExtFormula.top))
  | serial_past :
      ExtAxiom (ExtFormula.top.imp (ExtFormula.some_past ExtFormula.top))
  | left_mono_until_G (φ χ ψ : ExtFormula) :
      ExtAxiom ((φ.imp χ).all_future.imp ((ExtFormula.untl ψ φ).imp (ExtFormula.untl ψ χ)))
  | left_mono_since_H (φ χ ψ : ExtFormula) :
      ExtAxiom ((φ.imp χ).all_past.imp ((ExtFormula.snce ψ φ).imp (ExtFormula.snce ψ χ)))
  | right_mono_until (φ ψ χ : ExtFormula) :
      ExtAxiom ((φ.imp ψ).all_future.imp ((ExtFormula.untl φ χ).imp (ExtFormula.untl ψ χ)))
  | right_mono_since (φ ψ χ : ExtFormula) :
      ExtAxiom ((φ.imp ψ).all_past.imp ((ExtFormula.snce φ χ).imp (ExtFormula.snce ψ χ)))
  | connect_future (φ : ExtFormula) :
      ExtAxiom (φ.imp (φ.some_past.all_future))
  | connect_past (φ : ExtFormula) :
      ExtAxiom (φ.imp (φ.some_future.all_past))
  | enrichment_until (φ ψ p : ExtFormula) :
      ExtAxiom (ExtFormula.and p (ExtFormula.untl ψ φ) |>.imp
        (ExtFormula.untl (ExtFormula.and ψ (ExtFormula.snce p φ)) φ))
  | enrichment_since (φ ψ p : ExtFormula) :
      ExtAxiom (ExtFormula.and p (ExtFormula.snce ψ φ) |>.imp
        (ExtFormula.snce (ExtFormula.and ψ (ExtFormula.untl p φ)) φ))
  | self_accum_until (φ ψ : ExtFormula) :
      ExtAxiom ((ExtFormula.untl ψ φ).imp
        (ExtFormula.untl ψ (ExtFormula.and φ (ExtFormula.untl ψ φ))))
  | self_accum_since (φ ψ : ExtFormula) :
      ExtAxiom ((ExtFormula.snce ψ φ).imp
        (ExtFormula.snce ψ (ExtFormula.and φ (ExtFormula.snce ψ φ))))
  | absorb_until (φ ψ : ExtFormula) :
      ExtAxiom ((ExtFormula.untl (ExtFormula.and φ (ExtFormula.untl ψ φ)) φ).imp (ExtFormula.untl ψ φ))
  | absorb_since (φ ψ : ExtFormula) :
      ExtAxiom ((ExtFormula.snce (ExtFormula.and φ (ExtFormula.snce ψ φ)) φ).imp (ExtFormula.snce ψ φ))
  | linear_until (φ ψ χ θ : ExtFormula) :
      ExtAxiom (ExtFormula.and (ExtFormula.untl ψ φ) (ExtFormula.untl θ χ)
        |>.imp (ExtFormula.or
          (ExtFormula.or
            (ExtFormula.untl (ExtFormula.and ψ θ) (ExtFormula.and φ χ))
            (ExtFormula.untl (ExtFormula.and ψ χ) (ExtFormula.and φ χ)))
          (ExtFormula.untl (ExtFormula.and φ θ) (ExtFormula.and φ χ))))
  | linear_since (φ ψ χ θ : ExtFormula) :
      ExtAxiom (ExtFormula.and (ExtFormula.snce ψ φ) (ExtFormula.snce θ χ)
        |>.imp (ExtFormula.or
          (ExtFormula.or
            (ExtFormula.snce (ExtFormula.and ψ θ) (ExtFormula.and φ χ))
            (ExtFormula.snce (ExtFormula.and ψ χ) (ExtFormula.and φ χ)))
          (ExtFormula.snce (ExtFormula.and φ θ) (ExtFormula.and φ χ))))
  | until_F (φ ψ : ExtFormula) :
      ExtAxiom ((ExtFormula.untl ψ φ).imp (ExtFormula.some_future ψ))
  | since_P (φ ψ : ExtFormula) :
      ExtAxiom ((ExtFormula.snce ψ φ).imp (ExtFormula.some_past ψ))
  | temp_linearity (φ ψ : ExtFormula) :
      ExtAxiom (ExtFormula.and (ExtFormula.some_future φ) (ExtFormula.some_future ψ) |>.imp
        (ExtFormula.or (ExtFormula.some_future (ExtFormula.and φ ψ))
          (ExtFormula.or (ExtFormula.some_future (ExtFormula.and φ (ExtFormula.some_future ψ)))
            (ExtFormula.some_future (ExtFormula.and (ExtFormula.some_future φ) ψ)))))
  | temp_linearity_past (φ ψ : ExtFormula) :
      ExtAxiom (ExtFormula.and (ExtFormula.some_past φ) (ExtFormula.some_past ψ) |>.imp
        (ExtFormula.or (ExtFormula.some_past (ExtFormula.and φ ψ))
          (ExtFormula.or (ExtFormula.some_past (ExtFormula.and φ (ExtFormula.some_past ψ)))
            (ExtFormula.some_past (ExtFormula.and (ExtFormula.some_past φ) ψ)))))
  | F_until_equiv (φ : ExtFormula) :
      ExtAxiom ((ExtFormula.some_future φ).imp (ExtFormula.untl φ ExtFormula.top))
  | P_since_equiv (φ : ExtFormula) :
      ExtAxiom ((ExtFormula.some_past φ).imp (ExtFormula.snce φ ExtFormula.top))

  -- Layer 4: Modal-Temporal Interaction (1)
  | modal_future (φ : ExtFormula) :
      ExtAxiom ((ExtFormula.box φ).imp (ExtFormula.box (ExtFormula.all_future φ)))

  -- Layer 5: Uniformity Axioms (5)
  | discrete_symm_fwd :
      ExtAxiom ((ExtFormula.untl ExtFormula.top ExtFormula.bot).imp
        (ExtFormula.snce ExtFormula.top ExtFormula.bot))
  | discrete_symm_bwd :
      ExtAxiom ((ExtFormula.snce ExtFormula.top ExtFormula.bot).imp
        (ExtFormula.untl ExtFormula.top ExtFormula.bot))
  | discrete_propagate_fwd :
      ExtAxiom ((ExtFormula.untl ExtFormula.top ExtFormula.bot).imp
        (ExtFormula.all_future (ExtFormula.untl ExtFormula.top ExtFormula.bot)))
  | discrete_propagate_bwd :
      ExtAxiom ((ExtFormula.untl ExtFormula.top ExtFormula.bot).imp
        (ExtFormula.all_past (ExtFormula.untl ExtFormula.top ExtFormula.bot)))
  | discrete_box_necessity :
      ExtAxiom ((ExtFormula.untl ExtFormula.top ExtFormula.bot).imp
        (ExtFormula.box (ExtFormula.untl ExtFormula.top ExtFormula.bot)))

  -- Layer 6: Prior Axioms (2)
  | prior_UZ (φ : ExtFormula) :
      ExtAxiom (φ.some_future.imp (ExtFormula.untl φ φ.neg))
  | prior_SZ (φ : ExtFormula) :
      ExtAxiom (φ.some_past.imp (ExtFormula.snce φ φ.neg))

  -- Layer 7: Z1 (1)
  | z1 (φ : ExtFormula) :
      ExtAxiom ((φ.all_future.imp φ).all_future.imp (φ.all_future.some_future.imp φ.all_future))

  -- Layer 8: Density (1)
  | density (φ : ExtFormula) :
      ExtAxiom ((φ.all_future.all_future).imp φ.all_future)

/-- Minimum frame class required by an extended axiom, mirroring `Axiom.minFrameClass`. -/
def ExtAxiom.minFrameClass {φ : ExtFormula} : ExtAxiom φ → FrameClass
  | density _ => .Dense
  | prior_UZ _ => .Discrete
  | prior_SZ _ => .Discrete
  | z1 _ => .Discrete
  | _ => .Base

/--
Derivation tree for the extended proof system, parameterized by `FrameClass`.

The `h_fc` constraint on the `axiom` constructor ensures that only axioms compatible
with the frame class `fc` can appear in derivations, mirroring `DerivationTree`.
-/
inductive ExtDerivationTree (fc : FrameClass) : ExtContext → ExtFormula → Type where
  | axiom (Γ : ExtContext) (φ : ExtFormula) (h : ExtAxiom φ) (h_fc : h.minFrameClass ≤ fc) :
      ExtDerivationTree fc Γ φ
  | assumption (Γ : ExtContext) (φ : ExtFormula) (h : φ ∈ Γ) :
      ExtDerivationTree fc Γ φ
  | modus_ponens (Γ : ExtContext) (φ ψ : ExtFormula)
      (d1 : ExtDerivationTree fc Γ (φ.imp ψ))
      (d2 : ExtDerivationTree fc Γ φ) : ExtDerivationTree fc Γ ψ
  | necessitation (φ : ExtFormula)
      (d : ExtDerivationTree fc [] φ) : ExtDerivationTree fc [] (ExtFormula.box φ)
  | temporal_necessitation (φ : ExtFormula)
      (d : ExtDerivationTree fc [] φ) : ExtDerivationTree fc [] (ExtFormula.all_future φ)
  | temporal_duality (φ : ExtFormula)
      (d : ExtDerivationTree fc [] φ) : ExtDerivationTree fc [] φ.swap_temporal
  | weakening (Γ Δ : ExtContext) (φ : ExtFormula)
      (d : ExtDerivationTree fc Γ φ)
      (h : Γ ⊆ Δ) : ExtDerivationTree fc Δ φ

/-!
## Embedding Axioms
-/

/-- Embed a base axiom into an extended axiom. -/
def embedAxiom {φ : Formula} : Axiom φ → ExtAxiom (embedFormula φ)
  | Axiom.prop_k a b c => ExtAxiom.prop_k (embedFormula a) (embedFormula b) (embedFormula c)
  | Axiom.prop_s a b => ExtAxiom.prop_s (embedFormula a) (embedFormula b)
  | Axiom.ex_falso a => ExtAxiom.ex_falso (embedFormula a)
  | Axiom.peirce a b => ExtAxiom.peirce (embedFormula a) (embedFormula b)
  | Axiom.modal_t a => ExtAxiom.modal_t (embedFormula a)
  | Axiom.modal_4 a => ExtAxiom.modal_4 (embedFormula a)
  | Axiom.modal_b a => ExtAxiom.modal_b (embedFormula a)
  | Axiom.modal_5_collapse a => ExtAxiom.modal_5_collapse (embedFormula a)
  | Axiom.modal_k_dist a b => ExtAxiom.modal_k_dist (embedFormula a) (embedFormula b)
  | Axiom.serial_future => ExtAxiom.serial_future
  | Axiom.serial_past => ExtAxiom.serial_past
  | Axiom.left_mono_until_G a b c => ExtAxiom.left_mono_until_G (embedFormula a) (embedFormula b) (embedFormula c)
  | Axiom.left_mono_since_H a b c => ExtAxiom.left_mono_since_H (embedFormula a) (embedFormula b) (embedFormula c)
  | Axiom.right_mono_until a b c => ExtAxiom.right_mono_until (embedFormula a) (embedFormula b) (embedFormula c)
  | Axiom.right_mono_since a b c => ExtAxiom.right_mono_since (embedFormula a) (embedFormula b) (embedFormula c)
  | Axiom.connect_future a => ExtAxiom.connect_future (embedFormula a)
  | Axiom.connect_past a => ExtAxiom.connect_past (embedFormula a)
  | Axiom.enrichment_until a b c => ExtAxiom.enrichment_until (embedFormula a) (embedFormula b) (embedFormula c)
  | Axiom.enrichment_since a b c => ExtAxiom.enrichment_since (embedFormula a) (embedFormula b) (embedFormula c)
  | Axiom.self_accum_until a b => ExtAxiom.self_accum_until (embedFormula a) (embedFormula b)
  | Axiom.self_accum_since a b => ExtAxiom.self_accum_since (embedFormula a) (embedFormula b)
  | Axiom.absorb_until a b => ExtAxiom.absorb_until (embedFormula a) (embedFormula b)
  | Axiom.absorb_since a b => ExtAxiom.absorb_since (embedFormula a) (embedFormula b)
  | Axiom.linear_until a b c d => ExtAxiom.linear_until (embedFormula a) (embedFormula b) (embedFormula c) (embedFormula d)
  | Axiom.linear_since a b c d => ExtAxiom.linear_since (embedFormula a) (embedFormula b) (embedFormula c) (embedFormula d)
  | Axiom.until_F a b => ExtAxiom.until_F (embedFormula a) (embedFormula b)
  | Axiom.since_P a b => ExtAxiom.since_P (embedFormula a) (embedFormula b)
  | Axiom.temp_linearity a b => ExtAxiom.temp_linearity (embedFormula a) (embedFormula b)
  | Axiom.temp_linearity_past a b => ExtAxiom.temp_linearity_past (embedFormula a) (embedFormula b)
  | Axiom.F_until_equiv a => ExtAxiom.F_until_equiv (embedFormula a)
  | Axiom.P_since_equiv a => ExtAxiom.P_since_equiv (embedFormula a)
  | Axiom.modal_future a => ExtAxiom.modal_future (embedFormula a)
  | Axiom.discrete_symm_fwd => ExtAxiom.discrete_symm_fwd
  | Axiom.discrete_symm_bwd => ExtAxiom.discrete_symm_bwd
  | Axiom.discrete_propagate_fwd => ExtAxiom.discrete_propagate_fwd
  | Axiom.discrete_propagate_bwd => ExtAxiom.discrete_propagate_bwd
  | Axiom.discrete_box_necessity => ExtAxiom.discrete_box_necessity
  | Axiom.prior_UZ a => ExtAxiom.prior_UZ (embedFormula a)
  | Axiom.prior_SZ a => ExtAxiom.prior_SZ (embedFormula a)
  | Axiom.z1 a => ExtAxiom.z1 (embedFormula a)
  | Axiom.density a => ExtAxiom.density (embedFormula a)

/-- The minFrameClass of an embedded axiom equals the original's minFrameClass. -/
theorem embedAxiom_preserves_minFrameClass {φ : Formula} (ax : Axiom φ) :
    (embedAxiom ax).minFrameClass = ax.minFrameClass := by
  cases ax <;> rfl

/-!
## Embedding Derivations
-/

/-- Helper: mapping a list under embedFormula preserves membership. -/
theorem mem_map_embedFormula {Γ : List Formula} {φ : Formula} (h : φ ∈ Γ) :
    embedFormula φ ∈ Γ.map embedFormula :=
  List.mem_map_of_mem (f := embedFormula) h

/-- Helper: mapping preserves list subset. -/
theorem map_embedFormula_subset {Γ Δ : List Formula} (h : Γ ⊆ Δ) :
    Γ.map embedFormula ⊆ Δ.map embedFormula := by
  intro x hx
  rw [List.mem_map] at hx ⊢
  obtain ⟨a, ha, rfl⟩ := hx
  exact ⟨a, h ha, rfl⟩

/-- Embed a base derivation into an extended derivation.

This is the key structural lemma: every proof in the base system
can be replayed in the extended system. The frame class is preserved.
-/
noncomputable def embedDerivation {fc : FrameClass} : {Γ : List Formula} → {φ : Formula} →
    DerivationTree fc Γ φ → ExtDerivationTree fc (Γ.map embedFormula) (embedFormula φ)
  | _, _, DerivationTree.axiom _Γ _φ h h_fc =>
    ExtDerivationTree.axiom _ _ (embedAxiom h) (embedAxiom_preserves_minFrameClass h ▸ h_fc)
  | _, _, DerivationTree.assumption _Γ _φ h =>
    ExtDerivationTree.assumption _ _ (mem_map_embedFormula h)
  | _, _, DerivationTree.modus_ponens _Γ a b d1 d2 =>
    ExtDerivationTree.modus_ponens _ (embedFormula a) (embedFormula b)
      (embedDerivation d1) (embedDerivation d2)
  | _, _, DerivationTree.necessitation _φ d =>
    ExtDerivationTree.necessitation _ (embedDerivation d)
  | _, _, DerivationTree.temporal_necessitation _φ d =>
    ExtDerivationTree.temporal_necessitation _ (embedDerivation d)
  | _, _, DerivationTree.temporal_duality φ' d =>
    embedFormula_swap_temporal φ' ▸
      ExtDerivationTree.temporal_duality _ (embedDerivation d)
  | _, _, DerivationTree.weakening _Γ _Δ _φ d h =>
    ExtDerivationTree.weakening _ _ _ (embedDerivation d) (map_embedFormula_subset h)

end Bimodal.Metalogic.ConservativeExtension
