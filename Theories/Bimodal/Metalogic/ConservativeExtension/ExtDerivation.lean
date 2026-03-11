import Bimodal.Metalogic.ConservativeExtension.ExtFormula
import Bimodal.ProofSystem.Derivation

/-!
# Extended Proof System for Conservative Extension

This module defines the extended axiom and derivation types that mirror the base
proof system but use `ExtFormula` (with `ExtAtom := String ⊕ Unit`).

The key construction is `embedDerivation`, which lifts any base derivation
to an extended derivation, preserving the proof structure.

## Main Definitions

- `ExtAxiom`: Axiom schemata for the extended language
- `ExtDerivationTree`: Derivation trees in the extended proof system
- `embedAxiom`: Lifting of base axioms to extended axioms
- `embedDerivation`: Lifting of base derivations to extended derivations

## References

- Task 958 research-005.md: Conservative extension implementation guide
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
  | prop_k (φ ψ χ : ExtFormula) :
      ExtAxiom ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))
  | prop_s (φ ψ : ExtFormula) : ExtAxiom (φ.imp (ψ.imp φ))
  | modal_t (φ : ExtFormula) : ExtAxiom (ExtFormula.box φ |>.imp φ)
  | modal_4 (φ : ExtFormula) :
      ExtAxiom ((ExtFormula.box φ).imp (ExtFormula.box (ExtFormula.box φ)))
  | modal_b (φ : ExtFormula) :
      ExtAxiom (φ.imp (ExtFormula.box φ.diamond))
  | modal_5_collapse (φ : ExtFormula) :
      ExtAxiom (φ.box.diamond.imp φ.box)
  | ex_falso (φ : ExtFormula) : ExtAxiom (ExtFormula.bot.imp φ)
  | peirce (φ ψ : ExtFormula) : ExtAxiom (((φ.imp ψ).imp φ).imp φ)
  | modal_k_dist (φ ψ : ExtFormula) :
      ExtAxiom ((φ.imp ψ).box.imp (φ.box.imp ψ.box))
  | temp_k_dist (φ ψ : ExtFormula) :
      ExtAxiom ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future))
  | temp_4 (φ : ExtFormula) :
      ExtAxiom ((ExtFormula.all_future φ).imp (ExtFormula.all_future (ExtFormula.all_future φ)))
  | temp_a (φ : ExtFormula) :
      ExtAxiom (φ.imp (ExtFormula.all_future φ.some_past))
  | temp_l (φ : ExtFormula) :
      ExtAxiom (φ.always.imp (ExtFormula.all_future (ExtFormula.all_past φ)))
  | modal_future (φ : ExtFormula) :
      ExtAxiom ((ExtFormula.box φ).imp (ExtFormula.box (ExtFormula.all_future φ)))
  | temp_future (φ : ExtFormula) :
      ExtAxiom ((ExtFormula.box φ).imp (ExtFormula.all_future (ExtFormula.box φ)))
  | temp_linearity (φ ψ : ExtFormula) :
      ExtAxiom (ExtFormula.and (ExtFormula.some_future φ) (ExtFormula.some_future ψ) |>.imp
        (ExtFormula.or (ExtFormula.some_future (ExtFormula.and φ ψ))
          (ExtFormula.or (ExtFormula.some_future (ExtFormula.and φ (ExtFormula.some_future ψ)))
            (ExtFormula.some_future (ExtFormula.and (ExtFormula.some_future φ) ψ)))))
  | density (φ : ExtFormula) :
      ExtAxiom (φ.some_future.imp φ.some_future.some_future)
  | discreteness_forward (φ : ExtFormula) :
      ExtAxiom (ExtFormula.and (ExtFormula.bot.neg.some_future)
        (ExtFormula.and φ (ExtFormula.all_past φ)) |>.imp
        (ExtFormula.all_past φ).some_future)
  | seriality_future :
      ExtAxiom (ExtFormula.some_future (ExtFormula.neg ExtFormula.bot))
  | seriality_past :
      ExtAxiom (ExtFormula.some_past (ExtFormula.neg ExtFormula.bot))

/--
Derivation tree for the extended proof system.

Includes all inference rules from the base system plus the IRR rule
with `ExtAtom` (allowing `Sum.inr ()` as the fresh atom).
-/
inductive ExtDerivationTree : ExtContext → ExtFormula → Type where
  | axiom (Γ : ExtContext) (φ : ExtFormula) (h : ExtAxiom φ) :
      ExtDerivationTree Γ φ
  | assumption (Γ : ExtContext) (φ : ExtFormula) (h : φ ∈ Γ) :
      ExtDerivationTree Γ φ
  | modus_ponens (Γ : ExtContext) (φ ψ : ExtFormula)
      (d1 : ExtDerivationTree Γ (φ.imp ψ))
      (d2 : ExtDerivationTree Γ φ) : ExtDerivationTree Γ ψ
  | necessitation (φ : ExtFormula)
      (d : ExtDerivationTree [] φ) : ExtDerivationTree [] (ExtFormula.box φ)
  | temporal_necessitation (φ : ExtFormula)
      (d : ExtDerivationTree [] φ) : ExtDerivationTree [] (ExtFormula.all_future φ)
  | temporal_duality (φ : ExtFormula)
      (d : ExtDerivationTree [] φ) : ExtDerivationTree [] φ.swap_temporal
  | irr (p : ExtAtom) (φ : ExtFormula)
      (h_fresh : p ∉ φ.atoms)
      (d : ExtDerivationTree []
        ((ExtFormula.and (ExtFormula.atom p)
          (ExtFormula.all_past (ExtFormula.neg (ExtFormula.atom p)))).imp φ)) :
      ExtDerivationTree [] φ
  | weakening (Γ Δ : ExtContext) (φ : ExtFormula)
      (d : ExtDerivationTree Γ φ)
      (h : Γ ⊆ Δ) : ExtDerivationTree Δ φ

/-!
## Embedding Axioms
-/

/-- Embed a base axiom into an extended axiom. -/
def embedAxiom {φ : Formula} : Axiom φ → ExtAxiom (embedFormula φ)
  | Axiom.prop_k a b c => ExtAxiom.prop_k (embedFormula a) (embedFormula b) (embedFormula c)
  | Axiom.prop_s a b => ExtAxiom.prop_s (embedFormula a) (embedFormula b)
  | Axiom.modal_t a => ExtAxiom.modal_t (embedFormula a)
  | Axiom.modal_4 a => ExtAxiom.modal_4 (embedFormula a)
  | Axiom.modal_b a => ExtAxiom.modal_b (embedFormula a)
  | Axiom.modal_5_collapse a => ExtAxiom.modal_5_collapse (embedFormula a)
  | Axiom.ex_falso a => ExtAxiom.ex_falso (embedFormula a)
  | Axiom.peirce a b => ExtAxiom.peirce (embedFormula a) (embedFormula b)
  | Axiom.modal_k_dist a b => ExtAxiom.modal_k_dist (embedFormula a) (embedFormula b)
  | Axiom.temp_k_dist a b => ExtAxiom.temp_k_dist (embedFormula a) (embedFormula b)
  | Axiom.temp_4 a => ExtAxiom.temp_4 (embedFormula a)
  | Axiom.temp_a a => ExtAxiom.temp_a (embedFormula a)
  | Axiom.temp_l a => ExtAxiom.temp_l (embedFormula a)
  | Axiom.modal_future a => ExtAxiom.modal_future (embedFormula a)
  | Axiom.temp_future a => ExtAxiom.temp_future (embedFormula a)
  | Axiom.temp_linearity a b => ExtAxiom.temp_linearity (embedFormula a) (embedFormula b)
  | Axiom.density a => ExtAxiom.density (embedFormula a)
  | Axiom.discreteness_forward a => ExtAxiom.discreteness_forward (embedFormula a)
  | Axiom.seriality_future => ExtAxiom.seriality_future
  | Axiom.seriality_past => ExtAxiom.seriality_past

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
can be replayed in the extended system.
-/
noncomputable def embedDerivation : {Γ : List Formula} → {φ : Formula} →
    DerivationTree Γ φ → ExtDerivationTree (Γ.map embedFormula) (embedFormula φ)
  | _, _, DerivationTree.axiom _Γ _φ h =>
    ExtDerivationTree.axiom _ _ (embedAxiom h)
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
  | _, _, DerivationTree.irr p φ' h_fresh d =>
    ExtDerivationTree.irr (embedAtom p) (embedFormula φ')
      ((embedAtom_mem_embedFormula_atoms_iff p φ').not.mpr h_fresh)
      (embedDerivation d)
  | _, _, DerivationTree.weakening _Γ _Δ _φ d h =>
    ExtDerivationTree.weakening _ _ _ (embedDerivation d) (map_embedFormula_subset h)

end Bimodal.Metalogic.ConservativeExtension
