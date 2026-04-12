import Bimodal.Metalogic.BXCanonical.Frame
import Bimodal.Metalogic.BXCanonical.Quasimodel.EnrichedClosure

/-!
# Sigma-Restricted Ordering on BXPoints

Defines Sigma-restricted ordering predicates on BXPoints, where Sigma is a finite
set of formulas (typically `enrichedClosure target`). The key definition is
`sigma_strict`, which replaces `¬bx_le v u` in the modified Frame.lean signatures.

## The Guard Condition Issue

The original Frame.lean sorry signatures use `¬bx_le v u` as the "strict" guard
condition. This is problematic because `bx_le` propagates ALL G-formulas, but the
guard formula φ is just one specific subformula. The `sigma_strict` condition weakens
this to only require a distinguishing G-formula within a finite set Sigma. Since the
guard formula φ is in Sigma, its membership at any BXPoint is determined by the
Sigma-signature.

## Main Definitions

- `sigma_le`: Sigma-restricted preorder on BXPoints
- `sigma_strict`: Strict Sigma-restricted ordering
- `sigma_equiv`: Agreement on all Sigma-formulas

## Main Results

- `bx_le_implies_sigma_le`: `bx_le` refines `sigma_le`
- `sigma_le_refl`: Reflexivity (from BX1)
- `sigma_strict_irrefl`: Irreflexivity
- `not_bx_le_of_sigma_strict`: sigma_strict blocks reverse bx_le
- `not_sigma_le_of_sigma_strict`: sigma_strict blocks reverse sigma_le
- `sigma_formula_determined`: sigma_equiv determines Sigma-formula membership
- `not_sigma_equiv_of_sigma_strict`: sigma_strict prevents sigma_equiv

## References

- Task 101 research report (sections 11.3-11.4)
- Goldblatt 1992, Blackburn et al. 2001 (filtration constructions)
-/

namespace Bimodal.Metalogic.BXCanonical.Filtration

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.BXCanonical

/-! ## Sigma-Restricted Ordering -/

/-- Sigma-restricted preorder on BXPoints: for every G-formula in Sigma that
    holds at w, its content holds at v. This is `bx_le` restricted to Sigma. -/
def sigma_le (Sigma : Finset Formula) (w v : BXPoint) : Prop :=
  ∀ f : Formula, Formula.all_future f ∈ Sigma →
    Formula.all_future f ∈ w.formulas → f ∈ v.formulas

/-- Sigma-strict ordering: sigma_le holds from w to v, but there exists a
    distinguishing G-formula in Sigma present at v but whose content is absent
    from w. This replaces `¬bx_le v u` in the modified Frame.lean signatures. -/
def sigma_strict (Sigma : Finset Formula) (w v : BXPoint) : Prop :=
  sigma_le Sigma w v ∧
  ∃ f : Formula, Formula.all_future f ∈ Sigma ∧
    Formula.all_future f ∈ v.formulas ∧ f ∉ w.formulas

/-- Sigma-equivalence: two BXPoints agree on all Sigma-formulas. -/
def sigma_equiv (Sigma : Finset Formula) (w v : BXPoint) : Prop :=
  ∀ f ∈ Sigma, (f ∈ w.formulas ↔ f ∈ v.formulas)

/-! ## sigma_le Properties -/

/-- `bx_le` implies `sigma_le` for any Sigma. -/
theorem bx_le_implies_sigma_le (Sigma : Finset Formula) {w v : BXPoint}
    (h : bx_le w v) : sigma_le Sigma w v :=
  fun _f _h_sigma h_Gf => h h_Gf

/-- `sigma_le` is reflexive (from BX1: G(φ) → φ). -/
theorem sigma_le_refl (Sigma : Finset Formula) (w : BXPoint) :
    sigma_le Sigma w w := by
  intro f _h_sigma h_Gf
  have h_ax : DerivationTree [] ((Formula.all_future f).imp f) :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future f)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_Gf

/-- When bx_le is available on the left, sigma_le composes:
    bx_le w u and sigma_le u v give sigma_le w v.
    This uses temp_4: G(f) → G(G(f)) to propagate through bx_le. -/
theorem sigma_le_of_bx_le_left {Sigma : Finset Formula} {w u v : BXPoint}
    (hwu : bx_le w u) (huv : sigma_le Sigma u v) : sigma_le Sigma w v := by
  intro f h_sigma h_Gf_w
  have h_GGf := SetMaximalConsistent.all_future_all_future w.is_mcs h_Gf_w
  exact huv f h_sigma (hwu h_GGf)

/-! ## sigma_strict Properties -/

/-- sigma_strict is irreflexive: no point is sigma_strict above itself. -/
theorem sigma_strict_irrefl (Sigma : Finset Formula) (w : BXPoint) :
    ¬sigma_strict Sigma w w := by
  intro ⟨_, f, _, h_Gf_w, h_f_not_w⟩
  have h_ax : DerivationTree [] ((Formula.all_future f).imp f) :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future f)
  exact h_f_not_w (SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_Gf_w)

/-- sigma_strict blocks the reverse sigma_le direction. -/
theorem not_sigma_le_of_sigma_strict {Sigma : Finset Formula} {u v : BXPoint}
    (h : sigma_strict Sigma u v) : ¬sigma_le Sigma v u := by
  obtain ⟨_, f, h_Gf_sigma, h_Gf_v, h_f_not_u⟩ := h
  intro h_le_vu
  exact h_f_not_u (h_le_vu f h_Gf_sigma h_Gf_v)

/-- sigma_strict implies bx_le does NOT hold from v to u.
    Since bx_le v u implies sigma_le v u, this follows. -/
theorem not_bx_le_of_sigma_strict {Sigma : Finset Formula} {u v : BXPoint}
    (h : sigma_strict Sigma u v) : ¬bx_le v u :=
  fun h_bx => not_sigma_le_of_sigma_strict h (bx_le_implies_sigma_le Sigma h_bx)

/-! ## sigma_equiv Properties -/

/-- sigma_equiv is reflexive. -/
theorem sigma_equiv_refl (Sigma : Finset Formula) (w : BXPoint) :
    sigma_equiv Sigma w w :=
  fun _ _ => Iff.rfl

/-- sigma_equiv is symmetric. -/
theorem sigma_equiv_symm {Sigma : Finset Formula} {w v : BXPoint}
    (h : sigma_equiv Sigma w v) : sigma_equiv Sigma v w :=
  fun f hf => (h f hf).symm

/-- sigma_equiv is transitive. -/
theorem sigma_equiv_trans {Sigma : Finset Formula} {w u v : BXPoint}
    (hwu : sigma_equiv Sigma w u) (huv : sigma_equiv Sigma u v) :
    sigma_equiv Sigma w v :=
  fun f hf => (hwu f hf).trans (huv f hf)

/-- For Sigma-formulas, sigma_equiv determines membership. -/
theorem sigma_formula_determined {Sigma : Finset Formula} {w v : BXPoint}
    (h_equiv : sigma_equiv Sigma w v) {f : Formula}
    (h_sigma : f ∈ Sigma) :
    f ∈ w.formulas ↔ f ∈ v.formulas :=
  h_equiv f h_sigma

/-- sigma_strict implies the points are NOT sigma_equiv.
    Proof: sigma_strict gives G(f) ∈ v with f ∉ u. If they were sigma_equiv,
    then G(f) ∈ u (since G(f) ∈ Sigma), and BX1 gives f ∈ u. Contradiction. -/
theorem not_sigma_equiv_of_sigma_strict {Sigma : Finset Formula} {u v : BXPoint}
    (h : sigma_strict Sigma u v) : ¬sigma_equiv Sigma u v := by
  obtain ⟨_, f, h_Gf_sigma, h_Gf_v, h_f_not_u⟩ := h
  intro h_equiv
  have h_Gf_u := (h_equiv (Formula.all_future f) h_Gf_sigma).mpr h_Gf_v
  have h_ax : DerivationTree [] ((Formula.all_future f).imp f) :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future f)
  exact h_f_not_u (SetMaximalConsistent.implication_property u.is_mcs
    (theorem_in_mcs u.is_mcs h_ax) h_Gf_u)

/-! ## Constructing sigma_strict -/

/-- Construct sigma_strict from bx_le and a distinguishing witness. -/
theorem sigma_strict_of_bx_le_and_witness {Sigma : Finset Formula}
    {u v : BXPoint} (h_le : bx_le u v) {f : Formula}
    (h_Gf_sigma : Formula.all_future f ∈ Sigma)
    (h_Gf_v : Formula.all_future f ∈ v.formulas)
    (h_f_not_u : f ∉ u.formulas) :
    sigma_strict Sigma u v :=
  ⟨bx_le_implies_sigma_le Sigma h_le, f, h_Gf_sigma, h_Gf_v, h_f_not_u⟩

/-! ## H-content Duality for sigma_le -/

/-- When bx_le u v holds, the H-content of v is accessible from u
    (via the standard g/h duality). If H(f) ∈ Sigma and H(f) ∈ v
    and bx_le u v, then f ∈ u. This is the sigma_le analogue for H-formulas. -/
theorem sigma_H_backward {u v : BXPoint}
    (h_le : bx_le u v) {f : Formula}
    (h_Hf_v : Formula.all_past f ∈ v.formulas) :
    f ∈ u.formulas :=
  bx_H_forward h_le h_Hf_v

end Bimodal.Metalogic.BXCanonical.Filtration
