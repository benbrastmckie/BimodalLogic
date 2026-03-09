import Bimodal.Metalogic.Bundle.BidirectionalReachable
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Core.MCSProperties

/-!
# Dense Quotient - DenselyOrdered Property for BidirectionalQuotient

This module provides infrastructure for proving the BidirectionalQuotient is
DenselyOrdered when the density axiom DN is available in the logic.

## Status

The full DenselyOrdered instance is blocked by a subtle issue in the
constrained Lindenbaum construction for irreflexive semantics. The key lemmas
below are sorry-free; the DenselyOrdered instance itself requires additional
work (see "Open Problem" section).

## Proven Results (Sorry-Free)

- `b_world_not_subset_a`: Strict ordering implies set-theoretic separation
- `exists_in_b_not_a`: Extract formula in b.world \ a.world
- `F_of_mem_b_not_a`: F-introduction from successor (wraps canonical_F_of_mem_successor)
- `density_gives_FF`: DN application
- `combined_formula_F_in_a`: F(G(ψ) ∧ ¬ψ) ∈ a when ψ ∉ b

## Open Problem: Constrained Lindenbaum for Density

With irreflexive semantics, the density proof requires constructing an MCS c
with `a < c < b`. The combined formula approach uses seed
`{G(ψ) ∧ ¬ψ} ∪ GContent(a)` which is consistent. However, the unconstrained
Lindenbaum extension may produce `c.world = b.world` (since the seed ⊆ b.world),
yielding `c = b` instead of a proper intermediate point.

Resolving this requires either:
1. A constrained Lindenbaum lemma that avoids a specific MCS
2. An indirect argument showing adjacency is impossible with DN
3. A fundamentally different construction (e.g., using past density + linearity)

## References

- Research-016: Irreflexive feasibility analysis
- Goldblatt 1992, Ch. 6: Canonical models for tense logics
-/

namespace Bimodal.Metalogic.Bundle.DenseQuotient

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/-! ## Part 1: Basic Separation Lemmas -/

/--
If `a < b` in the fragment (CanonicalR but not reverse), then `b.world ⊄ a.world`.
-/
theorem b_world_not_subset_a
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (h_not_le : ¬CanonicalR b.world a.world) :
    ¬(b.world ⊆ a.world) := by
  intro h_sub
  have h_sub_rev : a.world ⊆ b.world := by
    intro x hx
    by_contra h_not
    have h_neg : Formula.neg x ∈ b.world := by
      rcases set_mcs_negation_complete b.is_mcs x with h | h
      · exact absurd h h_not
      · exact h
    exact set_consistent_not_both a.is_mcs.1 x hx (h_sub h_neg)
  have h_eq : a.world = b.world := Set.Subset.antisymm h_sub_rev h_sub
  exact h_not_le (h_eq ▸ h_le)

/--
If `a < b` in the fragment, there exists `χ ∈ b.world \ a.world`.
-/
theorem exists_in_b_not_a
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (h_not_le : ¬CanonicalR b.world a.world) :
    ∃ χ : Formula, χ ∈ b.world ∧ χ ∉ a.world := by
  have h_not_sub := b_world_not_subset_a a b h_le h_not_le
  rw [Set.not_subset] at h_not_sub
  exact h_not_sub

/-! ## Part 2: F-Introduction from Successor -/

/--
If `CanonicalR a b` and `χ ∈ b.world` and `χ ∉ a.world`, then `F(χ) ∈ a.world`.
This does NOT use the T-axiom.
-/
theorem F_of_mem_b_not_a
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (χ : Formula) (h_chi_b : χ ∈ b.world) (_h_chi_not_a : χ ∉ a.world) :
    Formula.some_future χ ∈ a.world :=
  canonical_F_of_mem_successor a.world b.world a.is_mcs b.is_mcs h_le χ h_chi_b

/-! ## Part 3: Density Axiom Application -/

/--
The density axiom DN gives `F(F(ψ)) ∈ w` from `F(ψ) ∈ w` for any MCS `w`.
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
-/
theorem fragment_intermediate_from_FF
    (a : BidirectionalFragment M₀ h_mcs₀)
    (ψ : Formula) (h_FF : Formula.some_future (Formula.some_future ψ) ∈ a.world) :
    ∃ (c : BidirectionalFragment M₀ h_mcs₀),
      CanonicalR a.world c.world ∧ Formula.some_future ψ ∈ c.world :=
  forward_F_stays_in_fragment a (Formula.some_future ψ) h_FF

/-! ## Part 4: Combined Formula Approach -/

/--
If `G(ψ) ∈ b.world`, `ψ ∉ b.world`, and `CanonicalR a b`, then
`F(G(ψ) ∧ ¬ψ) ∈ a.world`.

Proof: By contradiction. If `¬F(G(ψ) ∧ ¬ψ) ∈ a`, then `G(¬(G(ψ) ∧ ¬ψ)) ∈ a`
by double negation. Propagating via CanonicalR: `¬(G(ψ) ∧ ¬ψ) ∈ b`. Combined
with `G(ψ) ∈ b`, this forces `ψ ∈ b`, contradicting `ψ ∉ b`.
-/
theorem combined_formula_F_in_a
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (ψ : Formula)
    (h_Gψ_b : Formula.all_future ψ ∈ b.world)
    (h_ψ_not_b : ψ ∉ b.world) :
    Formula.some_future (Formula.and (Formula.all_future ψ) (Formula.neg ψ)) ∈ a.world := by
  by_contra h_not_F
  have h_neg_F : Formula.neg (Formula.some_future (Formula.and (Formula.all_future ψ) (Formula.neg ψ))) ∈ a.world := by
    rcases set_mcs_negation_complete a.is_mcs
      (Formula.some_future (Formula.and (Formula.all_future ψ) (Formula.neg ψ))) with h | h
    · exact absurd h h_not_F
    · exact h
  have h_G_neg : Formula.all_future (Formula.neg (Formula.and (Formula.all_future ψ) (Formula.neg ψ))) ∈ a.world := by
    have h_eq : Formula.neg (Formula.some_future (Formula.and (Formula.all_future ψ) (Formula.neg ψ)))
      = Formula.neg (Formula.neg (Formula.all_future (Formula.neg (Formula.and (Formula.all_future ψ) (Formula.neg ψ))))) := rfl
    rw [h_eq] at h_neg_F
    exact mcs_double_neg_elim a.is_mcs _ h_neg_F
  have h_neg_in_b : Formula.neg (Formula.and (Formula.all_future ψ) (Formula.neg ψ)) ∈ b.world :=
    h_le h_G_neg
  -- ¬(G(ψ) ∧ ¬ψ) ∈ b and G(ψ) ∈ b. If ψ ∉ b: ¬ψ ∈ b, so G(ψ) ∧ ¬ψ ∈ b,
  -- contradicting ¬(G(ψ) ∧ ¬ψ) ∈ b. Therefore ψ ∈ b.
  have h_ψ_in_b : ψ ∈ b.world := by
    by_contra h_not_ψ
    have h_negψ : Formula.neg ψ ∈ b.world := by
      rcases set_mcs_negation_complete b.is_mcs ψ with h | h
      · exact absurd h h_not_ψ
      · exact h
    have h_conj2 : Formula.and (Formula.all_future ψ) (Formula.neg ψ) ∈ b.world :=
      set_mcs_conjunction_intro b.is_mcs h_Gψ_b h_negψ
    exact set_consistent_not_both b.is_mcs.1
      (Formula.and (Formula.all_future ψ) (Formula.neg ψ))
      h_conj2 h_neg_in_b
  exact h_ψ_not_b h_ψ_in_b

/-! ## Part 5: Distinguishing Formula (Sorry-Free)

The `strict_lt_has_distinguishing_formula` from the previous version,
adapted for irreflexive semantics.
-/

/--
If `a < b` in the BidirectionalFragment, there exists `ψ` such that:
- `F(ψ) ∈ a.world` (existential future witness)
- `ψ ∈ b.world` (holds at b)
- `ψ ∉ a.world` (does not hold at a)
-/
theorem strict_lt_has_distinguishing_formula
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (h_not_le : ¬CanonicalR b.world a.world) :
    ∃ ψ : Formula, Formula.some_future ψ ∈ a.world ∧ ψ ∈ b.world ∧ ψ ∉ a.world := by
  obtain ⟨chi, h_chi_b, h_chi_not_a⟩ := exists_in_b_not_a a b h_le h_not_le
  have h_F_chi := F_of_mem_b_not_a a b h_le chi h_chi_b h_chi_not_a
  exact ⟨chi, h_F_chi, h_chi_b, h_chi_not_a⟩

end Bimodal.Metalogic.Bundle.DenseQuotient
