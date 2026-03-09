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

Step 6 requires showing BOTH `¬CanonicalR c.world a.world` AND
`¬CanonicalR b.world c.world` simultaneously. This is the key open problem.

## Partial Results (One-Sided Strictness)

Using the seed `{G(ψ)} ∪ GContent(a.world) ∪ HContent(b.world)` (⊆ b.world, consistent):
- `constrained_forward_above`: Gives `c` with `a < c ≤ b` (strict below, via ψ ∈ GContent(c) \ a)

Using the seed `{¬ψ} ∪ GContent(a.world) ∪ HContent(b.world)` (⊆ a.world, consistent):
- `constrained_forward_below`: Gives `c` with `a ≤ c < b` (strict above, via ψ ∈ GContent(b) and ¬ψ ∈ c)

Each seed achieves ONE strictness condition but not both. The full DenselyOrdered
instance requires both simultaneously.

## Mathematical Obstacle

The `Antisymmetrization` quotient identifies MCSes with identical GContent (mutual
CanonicalR). Two MCSes can differ on propositional content (ψ ∈ c, ψ ∉ a) while
having the same GContent (same quotient class). The only way to enter GContent
is via `temp_a` (φ → G(P(φ))), which places `P(φ)` into GContent. So the question
reduces to: is `P(ψ) ∉ a.world` provable from the hypotheses? This is open.

Potential approaches:
1. Find two DISTINCT formulas in GContent(b) \ a.world and use one for each direction
2. Prove P(ψ) ∉ a.world from the specific structure of ψ as extracted from GContent(b)
3. Use a counting/compactness argument to show adjacency is impossible with DN
4. Work in an irreflexive setting where the quotient issue doesn't arise

## Proven Results

- `strict_lt_has_distinguishing_formula`: If `a < b` in fragment, exists `ψ` with
  `F(ψ) ∈ a.world`, `ψ ∈ b.world`, `ψ ∉ a.world`
- `density_gives_FF`: DN in MCS implies `F(F(ψ)) ∈ a.world` from `F(ψ) ∈ a.world`
- `fragment_intermediate_from_FF`: FF(ψ) ∈ a gives fragment element c with a ≤ c and F(ψ) ∈ c
- `constrained_forward_above`: Seed {G(ψ)} ∪ GContent(a) ∪ HContent(b) gives a < c ≤ b
- `constrained_forward_below`: Seed {¬ψ} ∪ GContent(a) ∪ HContent(b) gives a ≤ c < b

## References

- Research-013 Section 3.2: Density path proof sketch (optimistic, gap at step 6)
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

/-!
## Constrained Lindenbaum: One-Sided Strictness

These lemmas construct intermediate MCSes with one strict inequality.
The full DenselyOrdered instance requires both, which is an open problem.
-/

/--
Constrained seed consistency: `{G(ψ)} ∪ GContent(a.world) ∪ HContent(b.world) ⊆ b.world`.

When `a ≤ b` in the fragment and `G(ψ) ∈ b.world`, the seed is a subset of
`b.world` (which is an MCS and thus consistent).
-/
theorem constrained_seed_above_subset_b
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (ψ : Formula) (h_Gψ_b : Formula.all_future ψ ∈ b.world) :
    {Formula.all_future ψ} ∪ GContent a.world ∪ HContent b.world ⊆ b.world := by
  intro φ h_mem
  -- ({G(ψ)} ∪ GContent(a)) ∪ HContent(b): left-associated union
  rcases h_mem with h_left | h_H
  · -- φ ∈ {G(ψ)} ∪ GContent(a.world)
    rcases h_left with h_sing | h_G
    · -- φ ∈ {G(ψ)}: G(ψ) ∈ b.world
      exact h_sing ▸ h_Gψ_b
    · -- φ ∈ GContent(a.world): a ≤ b gives GContent(a) ⊆ b
      exact h_le h_G
  · -- φ ∈ HContent(b.world): H(φ) ∈ b → φ ∈ b by T-axiom (past reflexivity)
    exact canonicalR_past_reflexive b.world b.is_mcs h_H

/--
Constrained seed consistency: `{¬ψ} ∪ GContent(a.world) ∪ HContent(b.world) ⊆ a.world`.

When `a ≤ b` and `ψ ∉ a.world` (so `¬ψ ∈ a.world`), the seed is a subset of
`a.world` (which is an MCS and thus consistent).
-/
theorem constrained_seed_below_subset_a
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (ψ : Formula) (h_ψ_not_a : ψ ∉ a.world) :
    {Formula.neg ψ} ∪ GContent a.world ∪ HContent b.world ⊆ a.world := by
  intro φ h_mem
  -- ({¬ψ} ∪ GContent(a)) ∪ HContent(b): left-associated union
  rcases h_mem with h_left | h_H
  · rcases h_left with h_sing | h_G
    · -- φ ∈ {¬ψ}: ¬ψ ∈ a.world (since ψ ∉ a and a is MCS)
      rcases set_mcs_negation_complete a.is_mcs ψ with h | h
      · exact absurd h h_ψ_not_a
      · exact h_sing ▸ h
    · -- φ ∈ GContent(a.world): by reflexivity, GContent(a) ⊆ a
      exact canonicalR_reflexive a.world a.is_mcs h_G
  · -- φ ∈ HContent(b.world): by duality from a ≤ b, HContent(b) ⊆ a
    exact GContent_subset_implies_HContent_reverse a.world b.world a.is_mcs b.is_mcs h_le h_H

/--
The `constrained_forward_above` seed gives a fragment element `c` with:
- `a ≤ c` (from GContent(a) ⊆ c)
- `c ≤ b` (from HContent(b) ⊆ c, by duality)
- `G(ψ) ∈ c` (from seed)
- `ψ ∈ GContent(c)` (from G(ψ) ∈ c)
- Therefore `¬(c ≤ a)` since `ψ ∈ GContent(c)` but `ψ ∉ a.world`

This gives `a < c ≤ b` in the quotient, but NOT necessarily `c < b`.
-/
theorem constrained_forward_above
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (_h_not_le : ¬CanonicalR b.world a.world)
    (ψ : Formula)
    (h_Gψ_b : Formula.all_future ψ ∈ b.world)
    (h_ψ_not_a : ψ ∉ a.world) :
    ∃ (c : BidirectionalFragment M₀ h_mcs₀),
      CanonicalR a.world c.world ∧
      CanonicalR c.world b.world ∧
      ¬CanonicalR c.world a.world := by
  -- Seed = {G(ψ)} ∪ GContent(a.world) ∪ HContent(b.world) ⊆ b.world
  let seed := {Formula.all_future ψ} ∪ GContent a.world ∪ HContent b.world
  have h_seed_sub : seed ⊆ b.world :=
    constrained_seed_above_subset_b a b h_le ψ h_Gψ_b
  have h_seed_cons : SetConsistent seed :=
    fun L h_L_sub h_deriv => b.is_mcs.1 L (fun φ h_mem => h_seed_sub (h_L_sub φ h_mem)) h_deriv
  -- Extend to MCS via Lindenbaum
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum seed h_seed_cons
  -- W is in the fragment (forward-reachable from a)
  have h_GC_a_sub_W : GContent a.world ⊆ W := by
    intro φ h_φ
    exact h_extends (Set.mem_union_left _ (Set.mem_union_right _ h_φ))
  have h_R_aW : CanonicalR a.world W := h_GC_a_sub_W
  let c := a.forward_closed W h_W_mcs h_R_aW
  use c
  constructor
  · -- a ≤ c: CanonicalR a.world c.world
    exact h_R_aW
  constructor
  · -- c ≤ b: HContent(b) ⊆ c.world, by duality gives GContent(c) ⊆ b
    have h_HC_b_sub_W : HContent b.world ⊆ W := by
      intro φ h_φ
      exact h_extends (Set.mem_union_right _ h_φ)
    exact HContent_subset_implies_GContent_reverse b.world W b.is_mcs h_W_mcs h_HC_b_sub_W
  · -- ¬(c ≤ a): ψ ∈ GContent(c) but ψ ∉ a.world
    intro h_c_le_a
    -- G(ψ) ∈ W = c.world
    have h_Gψ_W : Formula.all_future ψ ∈ W :=
      h_extends (Set.mem_union_left _ (Set.mem_union_left _ (Set.mem_singleton _)))
    -- ψ ∈ GContent(c.world) = GContent(W)
    -- h_c_le_a : GContent(c.world) ⊆ a.world
    -- So ψ ∈ a.world
    have h_ψ_a : ψ ∈ a.world := h_c_le_a h_Gψ_W
    exact h_ψ_not_a h_ψ_a

/--
The `constrained_forward_below` seed gives a fragment element `c` with:
- `a ≤ c` (from GContent(a) ⊆ c)
- `c ≤ b` (from HContent(b) ⊆ c, by duality)
- `¬ψ ∈ c` (from seed)
- Therefore `¬(b ≤ c)` since `G(ψ) ∈ b.world` would give `ψ ∈ c`, contradicting `¬ψ ∈ c`

This gives `a ≤ c < b` in the quotient, but NOT necessarily `a < c`.
-/
theorem constrained_forward_below
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (_h_not_le : ¬CanonicalR b.world a.world)
    (ψ : Formula)
    (h_Gψ_b : Formula.all_future ψ ∈ b.world)
    (h_ψ_not_a : ψ ∉ a.world) :
    ∃ (c : BidirectionalFragment M₀ h_mcs₀),
      CanonicalR a.world c.world ∧
      CanonicalR c.world b.world ∧
      ¬CanonicalR b.world c.world := by
  -- Seed = {¬ψ} ∪ GContent(a.world) ∪ HContent(b.world) ⊆ a.world
  let seed := {Formula.neg ψ} ∪ GContent a.world ∪ HContent b.world
  have h_seed_sub : seed ⊆ a.world :=
    constrained_seed_below_subset_a a b h_le ψ h_ψ_not_a
  have h_seed_cons : SetConsistent seed :=
    fun L h_L_sub h_deriv => a.is_mcs.1 L (fun φ h_mem => h_seed_sub (h_L_sub φ h_mem)) h_deriv
  -- Extend to MCS via Lindenbaum
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum seed h_seed_cons
  -- W is in the fragment (forward-reachable from a)
  have h_GC_a_sub_W : GContent a.world ⊆ W := by
    intro φ h_φ
    exact h_extends (Set.mem_union_left _ (Set.mem_union_right _ h_φ))
  have h_R_aW : CanonicalR a.world W := h_GC_a_sub_W
  let c := a.forward_closed W h_W_mcs h_R_aW
  use c
  constructor
  · -- a ≤ c
    exact h_R_aW
  constructor
  · -- c ≤ b: HContent(b) ⊆ c.world, by duality
    have h_HC_b_sub_W : HContent b.world ⊆ W := by
      intro φ h_φ
      exact h_extends (Set.mem_union_right _ h_φ)
    exact HContent_subset_implies_GContent_reverse b.world W b.is_mcs h_W_mcs h_HC_b_sub_W
  · -- ¬(b ≤ c): if b ≤ c then G(ψ) ∈ b gives ψ ∈ c, contradicting ¬ψ ∈ c
    intro h_b_le_c
    have h_negψ_W : Formula.neg ψ ∈ W :=
      h_extends (Set.mem_union_left _ (Set.mem_union_left _ (Set.mem_singleton _)))
    -- G(ψ) ∈ b.world, and b ≤ c = GContent(b) ⊆ c.world = W
    have h_ψ_W : ψ ∈ W := h_b_le_c h_Gψ_b
    -- ψ and ¬ψ in same MCS: contradiction
    exact set_consistent_not_both h_W_mcs.1 ψ h_ψ_W h_negψ_W

end Bimodal.Metalogic.Bundle.DenseQuotient
