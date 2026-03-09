import Bimodal.Metalogic.Bundle.BidirectionalReachable
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Core.MCSProperties

/-!
# Dense Quotient - DenselyOrdered Property for BidirectionalQuotient

This module establishes key lemmas toward proving the BidirectionalQuotient
is DenselyOrdered when the density axiom DN is available in the logic.

## Strategy

Given `q₁ < q₂` in the BidirectionalQuotient (with representatives `a ≤ b`
in the fragment, where `a < b` means `CanonicalR a.world b.world` and
`¬CanonicalR b.world a.world`):

1. Since `¬CanonicalR b.world a.world`, there exists `ψ` with
   `G(ψ) ∈ b.world` and `ψ ∉ a.world`
2. By T-axiom: `ψ ∈ b.world`; by MCS completeness: `¬ψ ∈ a.world`
3. Since `CanonicalR a.world b.world` and `ψ ∈ b.world`: `F(ψ) ∈ a.world`
4. By DN (Fψ → FFψ): `F(F(ψ)) ∈ a.world`
5. By `canonical_forward_F`: exists `c` in fragment with
   `CanonicalR a.world c.world` and `F(ψ) ∈ c.world`
6. Need: `c` is strictly between `a` and `b` in the quotient

Step 6 requires a constrained version of `canonical_forward_F` that constructs
the witness between two given MCSes. This is future work.

## Main Results

- `strict_lt_has_distinguishing_formula`: If `a < b` in fragment, exists `ψ` with
  `F(ψ) ∈ a.world`, `ψ ∈ b.world`, `¬ψ ∈ a.world`
- `density_gives_FF`: DN in MCS implies `F(F(ψ)) ∈ a.world` from `F(ψ) ∈ a.world`

## References

- Research-013 Section 3.2: Density path proof sketch
- Research-014: Fragment-first architecture
-/

namespace Bimodal.Metalogic.Bundle.DenseQuotient

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/--
If `a < b` in the BidirectionalFragment (CanonicalR a.world b.world and
¬CanonicalR b.world a.world), then there exists a formula `ψ` such that:
- `F(ψ) ∈ a.world` (existential future witness in a)
- `ψ ∈ b.world` (ψ holds at b)
- `ψ ∉ a.world` (ψ does not hold at a)

This formula witnesses the strict separation between a and b.
-/
theorem strict_lt_has_distinguishing_formula
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (h_not_le : ¬CanonicalR b.world a.world) :
    ∃ ψ : Formula, Formula.some_future ψ ∈ a.world ∧ ψ ∈ b.world ∧ ψ ∉ a.world := by
  -- ¬CanonicalR b.world a.world means ¬(GContent b.world ⊆ a.world)
  -- So ∃ chi ∈ GContent b.world with chi ∉ a.world
  rw [CanonicalR, GContent] at h_not_le
  rw [Set.not_subset] at h_not_le
  obtain ⟨chi, h_G_chi_b, h_chi_not_a⟩ := h_not_le
  -- chi ∈ { phi | all_future phi ∈ b.world }, so all_future chi ∈ b.world
  simp only [Set.mem_setOf_eq] at h_G_chi_b
  -- By T-axiom (temp_t_future): G(chi) → chi, so chi ∈ b.world
  have h_chi_b : chi ∈ b.world := by
    have h_T := theorem_in_mcs b.is_mcs
      (DerivationTree.axiom [] _ (Axiom.temp_t_future chi))
    exact set_mcs_implication_property b.is_mcs h_T h_G_chi_b
  -- F(chi) ∈ a.world: if G(¬chi) ∈ a.world, then ¬chi ∈ b.world by CanonicalR, contradiction
  have h_F_chi : Formula.some_future chi ∈ a.world := by
    by_contra h_not_F
    have h_mcs_a := a.is_mcs
    -- ¬F(chi) means G(¬chi) ∈ a.world (since F(chi) = ¬G(¬chi))
    -- ¬(¬G(¬chi)) ∈ a.world means G(¬chi) ∈ a.world (by double negation in MCS)
    have h_G_neg : Formula.all_future (Formula.neg chi) ∈ a.world := by
      -- some_future chi = neg(all_future(neg chi))
      -- ¬(some_future chi) means all_future(neg chi) ∈ a.world
      simp only [Formula.some_future, Formula.neg] at h_not_F
      rcases set_mcs_negation_complete h_mcs_a (Formula.all_future (chi.imp Formula.bot)) with h | h
      · -- all_future(¬chi) ∈ a.world = all_future(chi → ⊥) ∈ a.world
        exact h
      · -- ¬(all_future(¬chi)) ∈ a.world
        -- But that's some_future(chi) which should not be in a.world
        exfalso
        apply h_not_F
        -- ¬(all_future(neg chi)) is F(chi) = some_future chi
        exact h
    -- From G(¬chi) ∈ a.world and CanonicalR a.world b.world: ¬chi ∈ b.world
    have h_neg_chi_b : Formula.neg chi ∈ b.world :=
      canonical_forward_G a.world b.world h_le (Formula.neg chi) h_G_neg
    -- But chi ∈ b.world, so b.world is inconsistent, contradiction
    exact set_consistent_not_both b.is_mcs.1 chi h_chi_b h_neg_chi_b
  exact ⟨chi, h_F_chi, h_chi_b, h_chi_not_a⟩

/--
The density axiom DN gives `F(F(ψ)) ∈ w` from `F(ψ) ∈ w` for any MCS `w`.

This is because DN = `Fψ → FFψ` is an axiom of TM, and every MCS contains
all theorems and is closed under modus ponens.
-/
theorem density_gives_FF (w : Set Formula) (h_mcs : SetMaximalConsistent w)
    (ψ : Formula) (h_F : Formula.some_future ψ ∈ w) :
    Formula.some_future (Formula.some_future ψ) ∈ w := by
  have h_dn : ψ.some_future.imp ψ.some_future.some_future ∈ w :=
    theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.density ψ))
  exact set_mcs_implication_property h_mcs h_dn h_F

/--
From `F(F(ψ)) ∈ a.world`, there exists a fragment element `c` with
`CanonicalR a.world c.world` and `F(ψ) ∈ c.world`.

This gives an intermediate element between `a` and any future element.
-/
theorem fragment_intermediate_from_FF
    (a : BidirectionalFragment M₀ h_mcs₀)
    (ψ : Formula) (h_FF : Formula.some_future (Formula.some_future ψ) ∈ a.world) :
    ∃ (c : BidirectionalFragment M₀ h_mcs₀),
      CanonicalR a.world c.world ∧ Formula.some_future ψ ∈ c.world :=
  forward_F_stays_in_fragment a (Formula.some_future ψ) h_FF

end Bimodal.Metalogic.Bundle.DenseQuotient
