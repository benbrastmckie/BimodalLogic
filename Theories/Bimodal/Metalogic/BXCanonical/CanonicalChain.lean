import Bimodal.Metalogic.BXCanonical.Frame
import Bimodal.Metalogic.BXCanonical.Quasimodel.Construction
import Bimodal.Metalogic.BXCanonical.Filtration.DefectChain

/-!
# Canonical Chain Infrastructure

Provides MCS-level lemmas for BX axioms used in eventuality resolution,
and documents the mathematical analysis of the Until/Since sorry gap.

## Key BX Axiom Lemmas

- `psi_imp_until_mcs`: BX8 at MCS level (ψ → φ U ψ)
- `psi_imp_since_mcs`: BX8' at MCS level (ψ → φ S ψ)
- `F_imp_top_until_mcs`: BX12 at MCS level (F(ψ) → ⊤ U ψ)
- `left_mono_until_mcs`: BX2 at MCS level (G(φ → χ) → (φ U ψ → χ U ψ))

## Mathematical Analysis: Why the Guard Property is Unprovable

The 4 Frame.lean sorries and 6 Realization.lean sorries all require proving
a "guard" property: for arbitrary BXPoint `u` with `bx_le w u` and
`bx_lt u v`, show `φ ∈ u.formulas`.

This is unprovable from BX1-BX12 because:

1. `bx_le` (defined as `g_content ⊆`) is a non-total preorder
2. The proof obtains `φ ∈ u'` for some `u'` with `bx_le u' u` (via
   backward witness + BX9), but `φ ∈ u'` cannot be lifted to `φ ∈ u`
   through `bx_le` because `bx_le` only propagates G-content
3. BX11 (temporal linearity) constrains F-witnesses but not arbitrary
   BXPoints in a bx_le interval

### What Would Close Them

One of:
- **Until induction axiom**: `G(ψ → χ) ∧ G((φ ∧ χ) → G(χ)) → ((φ U ψ) → χ)`
  (removed from BX during the BX5/BX6 refactor; was in the original Burgess system)
- **bx_le totality on F-witness intervals**: Would follow from a stronger
  version of BX11 that constrains all future-reachable points, not just
  F-witnesses
- **Chain-based completeness proof**: Build the canonical model directly
  from a chain of BXPoints (Burgess dovetail construction), proving truth
  on the chain where the guard is trivially satisfied

### Resolution Path

The recommended resolution is the chain-based completeness proof (Option 3
from the research report). This bypasses the Frame.lean/Realization.lean
sorries entirely by proving the completeness theorem through a different
route that does not require universal guard properties.

## References

- Burgess 1984: "Basic tense logic" (until induction in original axiom system)
- Xu 1988: "Completeness for Until-Since on linear orders"
- Task 102 research report (specs/102_*/reports/04_task-semantics-research.md)
-/

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.BXCanonical.Filtration

/-! ## BX8 at MCS level: ψ → φ U ψ -/

/-- BX8 at MCS level: if ψ ∈ w then (φ U ψ) ∈ w. -/
theorem psi_imp_until_mcs {w : BXPoint} {φ ψ : Formula}
    (h : ψ ∈ w.formulas) : Formula.untl φ ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] (ψ.imp (Formula.untl φ ψ)) :=
    DerivationTree.axiom [] _ (Axiom.refl_intro_until φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- BX8' at MCS level: if ψ ∈ w then (φ S ψ) ∈ w. -/
theorem psi_imp_since_mcs {w : BXPoint} {φ ψ : Formula}
    (h : ψ ∈ w.formulas) : Formula.snce φ ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] (ψ.imp (Formula.snce φ ψ)) :=
    DerivationTree.axiom [] _ (Axiom.refl_intro_since φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-! ## BX12 at MCS level: F(ψ) → ⊤ U ψ -/

/-- BX12 at MCS level: if F(ψ) ∈ w then (⊤ U ψ) ∈ w.
    Here ⊤ is encoded as ⊥ → ⊥ (i.e., Formula.bot.imp Formula.bot). -/
theorem F_imp_top_until_mcs {w : BXPoint} {ψ : Formula}
    (h : Formula.some_future ψ ∈ w.formulas) :
    Formula.untl (Formula.bot.imp Formula.bot) ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] ((Formula.some_future ψ).imp
    (Formula.untl (Formula.bot.imp Formula.bot) ψ)) :=
    DerivationTree.axiom [] _ (Axiom.F_until_equiv ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- BX12' at MCS level: if P(ψ) ∈ w then (⊤ S ψ) ∈ w. -/
theorem P_imp_top_since_mcs {w : BXPoint} {ψ : Formula}
    (h : Formula.some_past ψ ∈ w.formulas) :
    Formula.snce (Formula.bot.imp Formula.bot) ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] ((Formula.some_past ψ).imp
    (Formula.snce (Formula.bot.imp Formula.bot) ψ)) :=
    DerivationTree.axiom [] _ (Axiom.P_since_equiv ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-! ## BX2 at MCS level: left monotonicity of Until -/

/-- BX2 at MCS level: left monotonicity of Until.
    If G(φ → χ) ∈ w and (φ U ψ) ∈ w, then (χ U ψ) ∈ w. -/
theorem left_mono_until_mcs {w : BXPoint} {φ ψ χ : Formula}
    (h_G : Formula.all_future (φ.imp χ) ∈ w.formulas)
    (h_until : Formula.untl φ ψ ∈ w.formulas) :
    Formula.untl χ ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] ((Formula.all_future (φ.imp χ)).imp
    ((Formula.untl φ ψ).imp (Formula.untl χ ψ))) :=
    DerivationTree.axiom [] _ (Axiom.left_mono_until φ ψ χ)
  have h1 := SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_G
  exact SetMaximalConsistent.implication_property w.is_mcs h1 h_until

/-- BX2' at MCS level: left monotonicity of Since. -/
theorem left_mono_since_mcs {w : BXPoint} {φ ψ χ : Formula}
    (h_H : Formula.all_past (φ.imp χ) ∈ w.formulas)
    (h_since : Formula.snce φ ψ ∈ w.formulas) :
    Formula.snce χ ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] ((Formula.all_past (φ.imp χ)).imp
    ((Formula.snce φ ψ).imp (Formula.snce χ ψ))) :=
    DerivationTree.axiom [] _ (Axiom.left_mono_since φ ψ χ)
  have h1 := SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_H
  exact SetMaximalConsistent.implication_property w.is_mcs h1 h_since

/-! ## BX6 at MCS level: absorption -/

/-- BX6 at MCS level: absorption of Until.
    If φ U (φ ∧ (φ U ψ)) ∈ w then φ U ψ ∈ w. -/
theorem absorb_until_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.untl φ (Formula.and φ (Formula.untl φ ψ)) ∈ w.formulas) :
    Formula.untl φ ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] ((Formula.untl φ (Formula.and φ (Formula.untl φ ψ))).imp
    (Formula.untl φ ψ)) :=
    DerivationTree.axiom [] _ (Axiom.absorb_until φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- BX6' at MCS level: absorption of Since. -/
theorem absorb_since_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.snce φ (Formula.and φ (Formula.snce φ ψ)) ∈ w.formulas) :
    Formula.snce φ ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] ((Formula.snce φ (Formula.and φ (Formula.snce φ ψ))).imp
    (Formula.snce φ ψ)) :=
    DerivationTree.axiom [] _ (Axiom.absorb_since φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-! ## Delegation: Realization.lean sorry closure

The 6 Realization.lean sorries have identical signatures to the 4 Frame.lean
sorries. Rather than maintaining duplicate code, Realization.lean should
delegate to Frame.lean.

The following lemmas provide the delegation bridge. -/

/-- Delegation bridge: Realization.until_eventuality_resolution can call
    Frame.bx_until_eventuality_resolution. Same signature, same sorry status. -/
theorem delegation_until_eventuality
    (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
      ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas :=
  bx_until_eventuality_resolution w φ ψ h_until h_not_psi

/-- Delegation bridge for backward Until. -/
theorem delegation_until_backward
    (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_wv : bx_le w v) (h_ψv : ψ ∈ v.formulas)
    (h_guard : ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.untl φ ψ ∈ w.formulas :=
  bx_until_backward w φ ψ v h_wv h_ψv h_guard h_not_psi

/-- Delegation bridge for Since eventuality. -/
theorem delegation_since_eventuality
    (w : BXPoint) (φ ψ : Formula)
    (h_since : Formula.snce φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le v w ∧ ψ ∈ v.formulas ∧
      ∀ u : BXPoint, bx_le v u ∧ ¬bx_le u v → bx_le u w → φ ∈ u.formulas :=
  bx_since_eventuality_resolution w φ ψ h_since h_not_psi

/-- Delegation bridge for backward Since. -/
theorem delegation_since_backward
    (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_vw : bx_le v w) (h_ψv : ψ ∈ v.formulas)
    (h_guard : ∀ u : BXPoint, bx_le v u ∧ ¬bx_le u v → bx_le u w → φ ∈ u.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.snce φ ψ ∈ w.formulas :=
  bx_since_backward w φ ψ v h_vw h_ψv h_guard h_not_psi

end Bimodal.Metalogic.BXCanonical
