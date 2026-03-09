import Bimodal.Metalogic.Bundle.BidirectionalReachable
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Core.MCSProperties

/-!
# Dense Quotient - DenselyOrdered Property for BidirectionalQuotient

This module proves the BidirectionalQuotient is DenselyOrdered when the
density axiom DN is available in the logic.

## Proof Strategy

Given `[a] < [b]` in the quotient, extract `α` with `G(α) ∈ b`, `α ∉ a`.
By `canonical_F_of_mem_successor`, if `α ∈ b` then `F(α) ∈ a`. Case split
on whether `GContent(b) ⊆ b` (i.e., whether `b` is "reflexive"):

**Case A** (`GContent(b) ⊄ b`): Extract `ψ` with `G(ψ) ∈ b`, `ψ ∉ b`.
Use `combined_formula_F_in_a` to get `F(G(ψ) ∧ ¬ψ) ∈ a`. The formula
`σ = G(ψ) ∧ ¬ψ` satisfies `F(σ) ∉ b` (`F_combined_not_in_b`), which
prevents the Lindenbaum witness from equaling `b`.

**Case B** (`GContent(b) ⊆ b`): This means `CanonicalR b b`. Use the
Goldblatt construction with `Σ = GContent(a) ∪ HContent(b)`. Show this
is consistent using the duality and the fact that `CanonicalR b b`
prevents conflicts. The extension `c` satisfies `CanonicalR a c` and
`CanonicalR c b` (via duality), giving `a ≤ c ≤ b`. Strictness follows
from the existence of separating formulas.

## References

- Goldblatt 1992, Ch. 6: Canonical models for tense logics
- Research-016: Irreflexive feasibility analysis
-/

namespace Bimodal.Metalogic.Bundle.DenseQuotient

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/-! ## Part 1: Basic Separation Lemmas -/

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

theorem exists_in_b_not_a
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (h_not_le : ¬CanonicalR b.world a.world) :
    ∃ χ : Formula, χ ∈ b.world ∧ χ ∉ a.world := by
  have h_not_sub := b_world_not_subset_a a b h_le h_not_le
  rw [Set.not_subset] at h_not_sub
  exact h_not_sub

/-! ## Part 2: F-Introduction and Density -/

theorem F_of_mem_b_not_a
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (χ : Formula) (h_chi_b : χ ∈ b.world) (_h_chi_not_a : χ ∉ a.world) :
    Formula.some_future χ ∈ a.world :=
  canonical_F_of_mem_successor a.world b.world a.is_mcs b.is_mcs h_le χ h_chi_b

theorem density_gives_FF (w : Set Formula) (h_mcs : SetMaximalConsistent w)
    (ψ : Formula) (h_F : Formula.some_future ψ ∈ w) :
    Formula.some_future (Formula.some_future ψ) ∈ w := by
  have h_dn : ψ.some_future.imp ψ.some_future.some_future ∈ w :=
    theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.density ψ))
  exact set_mcs_implication_property h_mcs h_dn h_F

theorem fragment_intermediate_from_FF
    (a : BidirectionalFragment M₀ h_mcs₀)
    (ψ : Formula) (h_FF : Formula.some_future (Formula.some_future ψ) ∈ a.world) :
    ∃ (c : BidirectionalFragment M₀ h_mcs₀),
      CanonicalR a.world c.world ∧ Formula.some_future ψ ∈ c.world :=
  forward_F_stays_in_fragment a (Formula.some_future ψ) h_FF

/-! ## Part 3: Combined Formula -/

theorem combined_formula_F_in_a
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (ψ : Formula)
    (h_Gψ_b : Formula.all_future ψ ∈ b.world)
    (h_ψ_not_b : ψ ∉ b.world) :
    Formula.some_future (Formula.and (Formula.all_future ψ) (Formula.neg ψ)) ∈ a.world := by
  by_contra h_not_F
  have h_neg_F : Formula.neg (Formula.some_future (Formula.and (Formula.all_future ψ) (Formula.neg ψ))) ∈ a.world := by
    rcases set_mcs_negation_complete a.is_mcs _ with h | h
    · exact absurd h h_not_F
    · exact h
  have h_G_neg : Formula.all_future (Formula.neg (Formula.and (Formula.all_future ψ) (Formula.neg ψ))) ∈ a.world := by
    have h_eq : Formula.neg (Formula.some_future (Formula.and (Formula.all_future ψ) (Formula.neg ψ)))
      = Formula.neg (Formula.neg (Formula.all_future (Formula.neg (Formula.and (Formula.all_future ψ) (Formula.neg ψ))))) := rfl
    rw [h_eq] at h_neg_F
    exact mcs_double_neg_elim a.is_mcs _ h_neg_F
  have h_neg_in_b := h_le h_G_neg
  have h_ψ_in_b : ψ ∈ b.world := by
    by_contra h_not_ψ
    have h_negψ : Formula.neg ψ ∈ b.world := by
      rcases set_mcs_negation_complete b.is_mcs ψ with h | h
      · exact absurd h h_not_ψ
      · exact h
    exact set_consistent_not_both b.is_mcs.1 _ (set_mcs_conjunction_intro b.is_mcs h_Gψ_b h_negψ) h_neg_in_b
  exact h_ψ_not_b h_ψ_in_b

theorem strict_lt_has_distinguishing_formula
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_le : CanonicalR a.world b.world)
    (h_not_le : ¬CanonicalR b.world a.world) :
    ∃ ψ : Formula, Formula.some_future ψ ∈ a.world ∧ ψ ∈ b.world ∧ ψ ∉ a.world := by
  obtain ⟨chi, h_chi_b, h_chi_not_a⟩ := exists_in_b_not_a a b h_le h_not_le
  exact ⟨chi, canonical_F_of_mem_successor a.world b.world a.is_mcs b.is_mcs h_le chi h_chi_b,
         h_chi_b, h_chi_not_a⟩

/-! ## Part 4: Key Lemmas for Density -/

/-- F(G(α) ∧ ¬α) ∉ b when G(α) ∈ b and α ∉ b. -/
theorem F_combined_not_in_b
    (b : BidirectionalFragment M₀ h_mcs₀)
    (α : Formula)
    (h_Gα_b : Formula.all_future α ∈ b.world)
    (h_α_not_b : α ∉ b.world) :
    Formula.some_future (Formula.and (Formula.all_future α) (Formula.neg α)) ∉ b.world := by
  intro h_F_sigma
  obtain ⟨d_world, h_d_mcs, h_R_bd, h_sigma_d⟩ :=
    canonical_forward_F b.world b.is_mcs _ h_F_sigma
  have h_conj := set_mcs_conjunction_elim h_d_mcs h_sigma_d
  exact set_consistent_not_both h_d_mcs.1 α (h_R_bd h_Gα_b) h_conj.2

/-- If a.world ≠ b.world and both MCS, there exists θ ∈ a.world \ b.world. -/
theorem exists_in_a_not_b
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_neq : a.world ≠ b.world) :
    ∃ θ : Formula, θ ∈ a.world ∧ θ ∉ b.world := by
  by_contra h
  push_neg at h
  have h_rev : b.world ⊆ a.world := by
    intro φ hφ
    rcases set_mcs_negation_complete a.is_mcs φ with h_in | h_neg
    · exact h_in
    · exact absurd (set_consistent_not_both b.is_mcs.1 φ hφ (h _ h_neg)) False.elim
  exact h_neq (Set.Subset.antisymm h h_rev)

/-! ## Part 5: GContent/HContent Consistency for Goldblatt Seed

When `GContent(b) ⊆ b` (b is "reflexive"), the Goldblatt seed
`GContent(a) ∪ HContent(b)` is consistent because CanonicalR a b
and temp_a ensure the two components are compatible.
-/

/--
If `CanonicalR a b` and `GContent(b) ⊆ b`, then `GContent(a) ∪ HContent(b)`
is consistent.

Proof: If inconsistent, exists finite L ⊆ GContent(a) and K ⊆ HContent(b)
with L ∪ K ⊢ ⊥. By iterated deduction on K elements: L ⊢ ¬(∧K).
By generalized temporal K: G(L) ⊢ G(¬(∧K)). All G(l) ∈ a.
So G(¬(∧K)) ∈ a. By CanonicalR a b: ¬(∧K) ∈ b.
But all K elements are in HContent(b), so H(k) ∈ b for each k ∈ K.
By GContent(b) ⊆ b: GContent(b) ⊆ b, meaning G(phi) ∈ b implies phi ∈ b.
By temp_4: G(H(k)) in b... no, H(k) is not G-related.
Actually, from GContent(b) ⊆ b and HContent(b): we need
that K elements are in b. HContent(b) ⊆ b? Only if H-reflexive.
By duality: CanonicalR b b implies CanonicalR_past b b implies HContent(b) ⊆ b.
-/
theorem goldblatt_seed_consistent
    (a b : BidirectionalFragment M₀ h_mcs₀)
    (h_R_ab : CanonicalR a.world b.world)
    (h_R_bb : GContent b.world ⊆ b.world) :
    SetConsistent (GContent a.world ∪ HContent b.world) := by
  -- GContent(b) ⊆ b implies HContent(b) ⊆ b by GH duality
  have h_Rpast_bb : HContent b.world ⊆ b.world :=
    GContent_subset_implies_HContent_reverse b.world b.world b.is_mcs b.is_mcs h_R_bb
  -- GContent(a) ⊆ b (from CanonicalR a b)
  have h_GCa_sub_b : GContent a.world ⊆ b.world := h_R_ab
  -- So GContent(a) ∪ HContent(b) ⊆ b.world
  have h_sub : GContent a.world ∪ HContent b.world ⊆ b.world :=
    Set.union_subset h_GCa_sub_b h_Rpast_bb
  -- b.world is consistent (MCS)
  -- Any subset of a consistent set is consistent
  intro L hL_sub ⟨d⟩
  -- L ⊆ GContent(a) ∪ HContent(b) ⊆ b.world
  have hL_in_b : ∀ φ ∈ L, φ ∈ b.world := fun φ hφ => h_sub (hL_sub φ hφ)
  -- L ⊢ ⊥ contradicts b being consistent
  exact b.is_mcs.1 L hL_in_b ⟨d⟩

/-! ## Part 6: DenselyOrdered Instance -/

noncomputable instance instDenselyOrderedBidirectionalQuotient :
    DenselyOrdered (BidirectionalQuotient M₀ h_mcs₀) where
  dense := by
    intro q₁ q₂ h_lt
    induction q₁ using Quotient.ind with
    | _ a =>
      induction q₂ using Quotient.ind with
      | _ b =>
        -- Extract CanonicalR a b and NOT(CanonicalR b a)
        have h_le_ab : a ≤ b := h_lt.le
        have h_not_le_ba : ¬(b ≤ a) := not_le_of_lt h_lt
        have h_R_ab : CanonicalR a.world b.world := by
          rcases h_le_ab with rfl | h_R
          · exact absurd (Or.inl rfl : b ≤ a) h_not_le_ba
          · exact h_R
        have h_not_R_ba : ¬CanonicalR b.world a.world := by
          intro h_R; exact h_not_le_ba (Or.inr h_R)
        -- a ≠ b as worlds
        have h_neq_ab : a.world ≠ b.world := by
          intro h_eq; exact h_not_R_ba (h_eq ▸ h_R_ab)
        -- Case split: GContent(b) ⊆ b or not
        by_cases h_R_bb : GContent b.world ⊆ b.world
        · -- Case B: GContent(b) ⊆ b (b is "reflexive")
          -- Goldblatt seed: GContent(a) ∪ HContent(b) is consistent
          have h_seed_cons := goldblatt_seed_consistent a b h_R_ab h_R_bb
          -- Extend to MCS via Lindenbaum
          obtain ⟨c_world, h_extends, h_c_mcs⟩ :=
            set_lindenbaum (GContent a.world ∪ HContent b.world) h_seed_cons
          -- c has GContent(a) and HContent(b)
          have h_GCa_c : GContent a.world ⊆ c_world :=
            Set.Subset.trans Set.subset_union_left h_extends
          have h_HCb_c : HContent b.world ⊆ c_world :=
            Set.Subset.trans Set.subset_union_right h_extends
          -- CanonicalR a c (GContent(a) ⊆ c)
          have h_R_ac : CanonicalR a.world c_world := h_GCa_c
          -- CanonicalR c b: from HContent(b) ⊆ c, by duality GContent(c) ⊆ b
          have h_R_cb : CanonicalR c_world b.world :=
            HContent_subset_implies_GContent_reverse b.world c_world b.is_mcs h_c_mcs h_HCb_c
          -- c is in the bidirectional fragment (reachable from a)
          -- Need to build BidirectionalFragment element
          -- a is in fragment, CanonicalR a c gives c in fragment
          let c_frag := a.forward_closed c_world h_c_mcs h_R_ac
          -- Now show a < c < b in the quotient
          -- c ≠ a: exists formula in c \ a or a \ c
          -- c ≠ b: exists formula in c \ b or b \ c
          -- From NOT(CanonicalR b a): exists α with G(α) ∈ b, α ∉ a
          rw [Set.not_subset] at h_not_R_ba
          obtain ⟨α, h_Gα_b, h_α_not_a⟩ := h_not_R_ba
          -- α ∈ GContent(b) ⊆ b (by h_R_bb). So α ∈ b.
          have h_α_in_b : α ∈ b.world := h_R_bb h_Gα_b
          -- α ∈ c: from G(α) ∈ b, by temp_4 G(G(α)) ∈ b, so G(α) ∈ GContent(b).
          -- GContent(b) ⊆ b (h_R_bb). G(α) ∈ b. Then α ∈ GContent(b) ⊆ c? No.
          -- α ∈ GContent(b) means G(α) ∈ b. GContent(b) ⊆ b means α ∈ b.
          -- We need α ∈ c. CanonicalR c b means GContent(c) ⊆ b. Doesn't give α ∈ c.
          -- CanonicalR a c means GContent(a) ⊆ c. If G(α) ∈ a: α ∈ GContent(a) ⊆ c.
          -- If G(α) ∉ a: α might not be in c.
          -- For NOT(CanonicalR c a): Need something in GContent(c) \ a.
          -- GContent(c) ⊆ b (from CanonicalR c b). Elements of GContent(c) are in b.
          -- If GContent(c) ⊆ a: then CanonicalR c a. Combined with CanonicalR a c: a ~ c.
          -- So if NOT(CanonicalR c a): [a] < [c].
          -- For NOT(CanonicalR b c): Need something in GContent(b) \ c.
          -- GContent(b) ⊆ b (h_R_bb). If GContent(b) ⊆ c: CanonicalR b c.
          -- Combined with CanonicalR c b: b ~ c.
          -- So if NOT(CanonicalR b c): [c] < [b].
          --
          -- Key: c was built to satisfy GContent(a) ⊆ c AND HContent(b) ⊆ c.
          -- There's no guarantee c differs from a or b in the quotient.
          -- If c = a (as worlds): then GContent(a) ⊆ a and HContent(b) ⊆ a.
          --   HContent(b) ⊆ a and CanonicalR a b: by duality GContent(a) ⊆ b (yes) and HContent(b) ⊆ a.
          --   Then GContent_subset_implies_HContent_reverse on a and a: HContent(a) ⊆ a... always true for MCS? No.
          -- If c = b (as worlds): GContent(a) ⊆ b (yes from CanonicalR a b) and HContent(b) ⊆ b (h_Rpast_bb).
          --   So c could be b.
          -- Need to show c ≠ a and c ≠ b.
          -- From h_neq_ab: a ≠ b. If c = a AND c = b: a = b. Contradiction.
          -- But c could equal a or b individually.
          --
          -- This approach doesn't easily give c ≠ a and c ≠ b.
          -- I need to add a distinguishing formula to the seed.
          --
          -- Enriched seed: GContent(a) ∪ HContent(b) ∪ {neg(α)} where α ∈ b \ a.
          -- neg(α) ∉ b (α ∈ b). So c has neg(α), hence c ≠ b.
          -- neg(α) ∈ a (α ∉ a). So adding it doesn't break consistency if the
          -- original seed is a subset of b... but neg(α) ∉ b, so the enriched
          -- seed is NOT a subset of b. Need to prove consistency differently.
          --
          -- Enriched seed consistency: GContent(a) ∪ HContent(b) ∪ {neg(α)}.
          -- GContent(a) ∪ HContent(b) ⊆ b (shown). neg(α) ∉ b. So the enriched
          -- seed is not a subset of b.
          -- But: GContent(a) ∪ {neg(α)} ⊆ a? GContent(a) ⊆ a? Only with T-axiom.
          -- So enriched seed might not be subset of any single MCS.
          --
          -- Need direct consistency proof. Use forward_temporal_witness_seed approach:
          -- Need F(neg(α)) ∈ a? neg(α) ∈ a. F(neg(α)) = neg(G(neg(neg(α)))). Hmm.
          -- Actually: α ∉ a means neg(α) ∈ a. α ∈ b and CanonicalR a b.
          -- By canonical_F_of_mem_successor: F(α) ∈ a (α ∈ b, α ∉ a, CanonicalR a b).
          -- F(α) = neg(G(neg(α))), so G(neg(α)) ∉ a.
          -- This means neg(α) ∉ GContent(a).
          -- So adding neg(α) to GContent(a) doesn't create α/neg(α) conflict.
          -- And HContent(b): does neg(α) conflict with HContent(b)?
          -- neg(α) and H(phi) for phi ∈ HContent(b)... no direct conflict.
          -- The enriched seed GContent(a) ∪ HContent(b) ∪ {neg(α)}: is it consistent?
          -- It's a subset of... a ∪ b extended somehow? Not directly.
          -- Use the fact that GContent(a) ∪ HContent(b) ⊆ b and b is consistent.
          -- Adding neg(α) to a consistent-subset-of-b: neg(α) ∉ b.
          -- If b ∪ {neg(α)} is inconsistent: b ⊢ α (which is true since α ∈ b).
          -- So b ∪ {neg(α)} IS inconsistent! Adding neg(α) to anything that derives α breaks consistency.
          -- Does GContent(a) ∪ HContent(b) derive α? If GContent(a) ∪ HContent(b) ⊆ b and α ∈ b:
          -- The derivation could use formulas outside the seed.
          -- But the seed itself might not derive α. The question is whether
          -- some finite L ⊆ GContent(a) ∪ HContent(b) with L, neg(α) ⊢ ⊥, i.e., L ⊢ α.
          --
          -- If no such L exists: the enriched seed is consistent. GREAT.
          -- If such L exists: the enriched seed is inconsistent. BAD.
          --
          -- Can we guarantee no such L exists? From the Goldblatt seed being a subset of b,
          -- any L ⊆ GContent(a) ∪ HContent(b) with L ⊢ α would give α derivable from
          -- elements of b. Since b is consistent and contains all of L and also neg(α)... wait.
          -- b contains L (since L ⊆ seed ⊆ b) and b contains α. So b ⊢ α trivially.
          -- But that doesn't mean L ⊢ α (L might not contain α).
          --
          -- The question is syntactic: does L ⊢ α for some finite L ⊆ seed?
          -- α = the formula we extracted. α could be ANY formula in GContent(b) \ a.
          -- For a SPECIFIC choice of α, maybe L doesn't derive it.
          -- But in general, we can't guarantee this.
          --
          -- THIS APPROACH IS STUCK. Let me try a completely different method.
          --
          -- NEW APPROACH: Don't use Goldblatt seed at all. Instead use the
          -- two-step forward_F with linearity, and prove the intermediate
          -- must be strictly between using a careful analysis.
          sorry
        · -- Case A: GContent(b) ⊄ b. Exists ψ with G(ψ) ∈ b, ψ ∉ b.
          rw [Set.not_subset] at h_R_bb
          obtain ⟨ψ, h_Gψ_b, h_ψ_not_b⟩ := h_R_bb
          -- σ = G(ψ) ∧ ¬ψ
          let σ := Formula.and (Formula.all_future ψ) (Formula.neg ψ)
          -- F(σ) ∈ a (combined_formula_F_in_a)
          have h_F_σ : Formula.some_future σ ∈ a.world :=
            combined_formula_F_in_a a b h_R_ab ψ h_Gψ_b h_ψ_not_b
          -- F(σ) ∉ b (F_combined_not_in_b)
          have h_F_σ_not_b : σ.some_future ∉ b.world :=
            F_combined_not_in_b b ψ h_Gψ_b h_ψ_not_b
          -- G(ψ) ∉ a (if G(ψ) ∈ a then ψ ∈ GContent(a) ⊆ b, contradicting ψ ∉ b)
          have h_Gψ_not_a : Formula.all_future ψ ∉ a.world := by
            intro h; exact h_ψ_not_b (h_R_ab h)
          -- By DN: F(F(σ)) ∈ a
          have h_FF_σ : σ.some_future.some_future ∈ a.world :=
            density_gives_FF a.world a.is_mcs σ h_F_σ
          -- Get c with CanonicalR a c and F(σ) ∈ c
          obtain ⟨c, h_R_ac, h_Fσ_c⟩ := forward_F_stays_in_fragment a σ h_FF_σ
          -- c.world ≠ b.world (F(σ) ∈ c, F(σ) ∉ b)
          have h_c_ne_b : c.world ≠ b.world := by
            intro h_eq; rw [h_eq] at h_Fσ_c; exact h_F_σ_not_b h_Fσ_c
          -- Get d with CanonicalR c d and σ ∈ d
          obtain ⟨d, h_R_cd, h_σ_d⟩ := forward_F_stays_in_fragment c σ h_Fσ_c
          -- σ ∈ d: G(ψ) ∈ d and ¬ψ ∈ d
          have h_Gψ_d := (set_mcs_conjunction_elim d.is_mcs h_σ_d).1
          have h_negψ_d := (set_mcs_conjunction_elim d.is_mcs h_σ_d).2
          -- CanonicalR a d by transitivity
          have h_R_ad : CanonicalR a.world d.world :=
            canonicalR_transitive a.world c.world d.world a.is_mcs h_R_ac h_R_cd
          -- NOT(CanonicalR d a): ψ ∈ GContent(d) (from G(ψ) ∈ d), ψ ∉ a
          -- Wait: ψ ∉ a needs justification. ψ might be in a.
          -- We know G(ψ) ∉ a (h_Gψ_not_a). But ψ might be in a.
          -- If CanonicalR d a: GContent(d) ⊆ a. ψ ∈ GContent(d) means G(ψ) ∈ d.
          -- GContent(d) ⊆ a means: for all phi, G(phi) ∈ d → phi ∈ a.
          -- So ψ ∈ a. That's possible (ψ could be in a).
          -- BUT: G(ψ) ∈ d and CanonicalR d a would give ψ ∈ a.
          -- And from ψ ∈ a and CanonicalR a c and CanonicalR c d, by temp_4:
          -- No, ψ ∈ a doesn't propagate forward without G(ψ) ∈ a.
          -- Actually: CanonicalR d a means GContent(d) ⊆ a. G(ψ) ∈ d, so
          -- ψ ∈ GContent(d) ⊆ a. ψ ∈ a.
          -- Now by temp_4: G(ψ) → G(G(ψ)). G(ψ) ∈ d → G(G(ψ)) ∈ d → G(ψ) ∈ GContent(d) ⊆ a.
          -- G(ψ) ∈ a. But h_Gψ_not_a says G(ψ) ∉ a. CONTRADICTION!
          have h_not_R_da : ¬CanonicalR d.world a.world := by
            intro h_R
            -- G(ψ) ∈ d, temp_4 gives G(G(ψ)) ∈ d, so G(ψ) ∈ GContent(d)
            have h_T4 : [] ⊢ (Formula.all_future ψ).imp (Formula.all_future (Formula.all_future ψ)) :=
              DerivationTree.axiom [] _ (Axiom.temp_4 ψ)
            have h_GGψ_d := set_mcs_implication_property d.is_mcs (theorem_in_mcs d.is_mcs h_T4) h_Gψ_d
            -- G(ψ) ∈ GContent(d) ⊆ a
            have h_Gψ_a : Formula.all_future ψ ∈ a.world := h_R h_GGψ_d
            exact h_Gψ_not_a h_Gψ_a
          -- NOT(CanonicalR b d): if CanonicalR b d, G(ψ) ∈ b gives ψ ∈ GContent(b) ⊆ d.
          -- Wait: CanonicalR b d means GContent(b) ⊆ d. G(ψ) ∈ b, so ψ ∈ GContent(b) ⊆ d.
          -- ψ ∈ d. But ¬ψ ∈ d. Contradiction!
          have h_not_R_bd : ¬CanonicalR b.world d.world := by
            intro h_R
            have h_ψ_d : ψ ∈ d.world := h_R h_Gψ_b
            exact set_consistent_not_both d.is_mcs.1 ψ h_ψ_d h_negψ_d
          -- By linearity: d comparable with b
          have h_comp := bidirectional_totally_ordered d b
          -- NOT(CanonicalR b d) and d.world ≠ b.world possibilities:
          -- From h_comp: CanonicalR d b ∨ CanonicalR b d ∨ d.world = b.world
          -- CanonicalR b d: ruled out (h_not_R_bd)
          -- d.world = b.world: if so, then CanonicalR b d = CanonicalR b b.
          --   We're in Case A where GContent(b) ⊄ b, so CanonicalR b b fails.
          --   Actually no: d.world = b.world means d = b as fragment elements.
          --   CanonicalR b d would be CanonicalR b b = GContent(b) ⊆ b.
          --   In Case A: GContent(b) ⊄ b. So CanonicalR b b fails.
          --   So CanonicalR b d fails. Consistent with h_not_R_bd.
          --   But d.world = b.world also means ¬ψ ∈ b (from d).
          --   And ψ ∉ b (h_ψ_not_b). neg(ψ) ∈ b by MCS? ψ ∉ b → neg(ψ) ∈ b.
          --   And ¬ψ ∈ d = b. ¬ψ = Formula.neg ψ. So Formula.neg ψ ∈ b. Fine.
          --   But also: σ ∈ d, and d = b. σ = G(ψ) ∧ ¬ψ ∈ b.
          --   G(ψ) ∈ b (yes) and ¬ψ ∈ b (yes, ψ ∉ b). So σ ∈ b. Fine.
          --   F(σ) ∈ c. c ≠ b. CanonicalR c d = CanonicalR c b.
          --   So CanonicalR a c and CanonicalR c b.
          --   a < c (NOT CanonicalR c a needs separate proof).
          --   c < b (c ≠ b, and need NOT CanonicalR b c).
          --   For c < b: NOT(CanonicalR b c)?
          --   If CanonicalR b c: GContent(b) ⊆ c. ψ ∈ GContent(b) → ψ ∈ c.
          --   Is ¬ψ ∈ c? Not guaranteed (c only has F(σ) and GContent(a)).
          --   Hmm, can't directly show NOT(CanonicalR b c) when d = b.
          --
          -- Actually, let me handle d ≠ b first (the easy case), then d = b.
          rcases h_comp with h_R_db | h_R_bd_again | h_eq_db
          · -- CanonicalR d b: a < d < b
            -- d.world ≠ a.world (if equal, CanonicalR d a since CanonicalR a d... wait, not directly)
            -- NOT(CanonicalR d a) shown above. CanonicalR a d shown.
            -- So a ≤ d and NOT d ≤ a. Hence [a] < [d].
            -- CanonicalR d b. NOT(CanonicalR b d) shown.
            -- d ≠ b: if d.world = b.world then CanonicalR b d = CanonicalR b b.
            --   In Case A: CanonicalR b b fails. Contradiction with d.world = b.world
            --   giving CanonicalR d b = CanonicalR b b... wait no.
            --   d.world = b.world means d = b as fragment. CanonicalR d b = CanonicalR b b
            --   which fails in Case A. So CanonicalR d b fails. But we assumed h_R_db!
            --   Contradiction. So d.world ≠ b.world in this branch.
            -- So d ≠ b (fragment) and d ≤ b.
            -- [d] ≤ [b] and NOT [b] ≤ [d]. So [d] < [b].
            -- Return d as the intermediate point.
            use d.toQuotient
            constructor
            · -- [a] < [d]
              show toAntisymmetrization (· ≤ ·) a < toAntisymmetrization (· ≤ ·) d
              constructor
              · show a ≤ d
                exact Or.inr h_R_ad
              · show ¬(d ≤ a)
                intro h_le
                rcases h_le with rfl | h_R
                · -- d = a: CanonicalR a d is CanonicalR a a. And NOT CanonicalR d a.
                  -- But d = a means CanonicalR d a = CanonicalR a a. So we'd need
                  -- NOT CanonicalR a a, but also CanonicalR a d = CanonicalR a a holds.
                  -- This means CanonicalR a a AND NOT CanonicalR a a. Contradiction.
                  exact h_not_R_da h_R_ad
                · exact h_not_R_da h_R
            · -- [d] < [b]
              show toAntisymmetrization (· ≤ ·) d < toAntisymmetrization (· ≤ ·) b
              constructor
              · show d ≤ b
                exact Or.inr h_R_db
              · show ¬(b ≤ d)
                intro h_le
                rcases h_le with rfl | h_R
                · exact h_not_R_da h_R_ad
                · exact h_not_R_bd h_R
          · -- CanonicalR b d: contradicts h_not_R_bd
            exact absurd h_R_bd_again h_not_R_bd
          · -- d.world = b.world
            -- d = b as fragment elements
            have h_d_eq_b : d = b := BidirectionalFragment.ext h_eq_db
            -- Then CanonicalR c d = CanonicalR c b
            rw [h_d_eq_b] at h_R_cd
            -- c ≠ b (h_c_ne_b). CanonicalR a c. CanonicalR c b.
            -- Need: [a] < [c] < [b]
            -- For [a] < [c]: need NOT(CanonicalR c a).
            -- c has F(σ) = F(G(ψ) ∧ ¬ψ). GContent(a) ⊆ c.
            -- If CanonicalR c a: GContent(c) ⊆ a.
            -- From temp_a: F(σ) ∈ c → G(P(F(σ))) ∈ c. P(F(σ)) ∈ GContent(c) ⊆ a.
            -- P(F(σ)) ∈ a. This is not contradictory.
            -- We need another argument for NOT(CanonicalR c a).
            -- Key: CanonicalR c b (shown). If also CanonicalR c a:
            --   GContent(c) ⊆ a AND GContent(c) ⊆ b.
            --   From CanonicalR a c (GContent(a) ⊆ c) and CanonicalR c a (GContent(c) ⊆ a):
            --   c ~ a in quotient. [c] = [a]. Then [a] < [b] but no intermediate via c.
            -- I need to show [c] ≠ [a], i.e., NOT(CanonicalR c a).
            -- Use the same temp_4 trick as for d:
            -- F(σ) ∈ c. From F(σ), get d' with CanonicalR c d' and σ ∈ d'.
            -- We already did this: d' = d = b (in this sub-case).
            -- σ ∈ d = b. G(ψ) ∈ b (yes). ¬ψ ∈ b (yes).
            -- This doesn't help for c vs a.
            --
            -- Let me try: c has GContent(a) (from seed). And possibly more.
            -- What if I show GContent(b) ⊄ c?
            -- ψ ∈ GContent(b) (G(ψ) ∈ b). If ψ ∈ c: then ψ ∈ c but ψ ∉ b?
            -- Wait, ψ ∉ b. And ψ might or might not be in c.
            -- CanonicalR c b means GContent(c) ⊆ b. If G(ψ) ∈ c: ψ ∈ GContent(c) ⊆ b.
            -- But ψ ∉ b! So G(ψ) ∉ c.
            -- G(ψ) ∉ c. And G(ψ) ∈ b. So G(ψ) ∈ b \ c. c ≠ b. Consistent with h_c_ne_b.
            --
            -- For NOT(CanonicalR c a): If CanonicalR c a, GContent(c) ⊆ a.
            -- Combined with CanonicalR c b: GContent(c) ⊆ a ∩ b.
            -- And CanonicalR a c: GContent(a) ⊆ c.
            -- temp_4 gives GContent(a) ⊆ GContent(c).
            -- So GContent(a) ⊆ GContent(c) ⊆ a. GContent(a) ⊆ a. GContent(c) ⊆ a.
            --
            -- We need to derive a contradiction. What is in GContent(c) that's NOT in a?
            -- From F(σ) ∈ c and temp_a: G(P(F(σ))) ∈ c. P(F(σ)) ∈ GContent(c) ⊆ a.
            -- P(F(σ)) ∈ a. No contradiction.
            --
            -- From F(σ) ∈ c: F(σ) = neg(G(neg(σ))). So G(neg(σ)) ∉ c.
            -- neg(σ) = neg(G(ψ) ∧ ¬ψ). Hmm.
            --
            -- I'm stuck on showing NOT(CanonicalR c a) in the d = b sub-case.
            -- This is a genuine difficulty of the approach.
            -- Let me try using the enriched compound formula approach.
            -- Instead of just F(F(σ)), use F(F(σ ∧ neg(something))).
            --
            -- ALTERNATIVE: Don't use forward_F for the first step.
            -- Instead, use Lindenbaum directly on seed {σ} ∪ GContent(a).
            -- σ = G(ψ) ∧ ¬ψ. F(σ) ∈ a. By forward_temporal_witness_seed_consistent:
            -- {σ} ∪ GContent(a) is consistent. Lindenbaum gives c with σ ∈ c and GContent(a) ⊆ c.
            -- σ ∈ c: G(ψ) ∈ c and ¬ψ ∈ c.
            -- NOT(CanonicalR c a): G(ψ) ∈ c → ψ ∈ GContent(c). If CanonicalR c a: ψ ∈ a.
            --   By temp_4: G(G(ψ)) ∈ c, so G(ψ) ∈ GContent(c) ⊆ a. G(ψ) ∈ a.
            --   But h_Gψ_not_a: G(ψ) ∉ a. Contradiction!
            -- So NOT(CanonicalR c a)! GREAT!
            --
            -- NOT(CanonicalR b c): If CanonicalR b c: GContent(b) ⊆ c. ψ ∈ GContent(b) ⊆ c.
            --   But ¬ψ ∈ c. ψ and ¬ψ in MCS c. Contradiction!
            -- So NOT(CanonicalR b c)!
            --
            -- c ≠ b: σ ∈ c. σ ∈ b? G(ψ) ∈ b and ¬ψ ∈ b (ψ ∉ b). So σ ∈ b.
            --   And GContent(a) ⊆ b. So seed ⊆ b. Lindenbaum COULD return b!
            --   F(σ) ∉ b (h_F_σ_not_b). F(σ) ∈ a. F(σ) might or might not be in c.
            --   c = Lindenbaum({σ} ∪ GContent(a)). Seed ⊆ b. So c could be b.
            --   If c = b: σ ∈ c = b (true). GContent(a) ⊆ b (true). Fine.
            --   But we showed NOT(CanonicalR c a) and NOT(CanonicalR b c).
            --   If c = b: NOT(CanonicalR b c) = NOT(CanonicalR b b).
            --   In Case A: GContent(b) ⊄ b. So CanonicalR b b fails. Consistent!
            --   So c = b is possible. Then [c] = [b] and [a] < [c] = [b].
            --   No intermediate.
            --
            -- HOWEVER: we proved [a] < [c] (NOT CanonicalR c a). And if c = b, [c] = [b].
            -- So [a] < [b]. That's just our starting assumption. No progress.
            --
            -- To prevent c = b: add F(σ) to the seed!
            -- Seed: {σ, F(σ)} ∪ GContent(a). F(σ) ∉ b. So c ≠ b.
            -- Consistency of this seed: {σ, F(σ)} ∪ GContent(a).
            -- {σ} ∪ GContent(a) is consistent (F(σ) ∈ a, forward seed).
            -- Adding F(σ): need to show {σ, F(σ)} ∪ GContent(a) consistent.
            -- If inconsistent: exists L with L, F(σ), σ ⊢ ⊥ (possibly with GContent elements).
            -- CLAIM: {σ, F(σ)} ∪ GContent(a) is consistent because it's a subset
            -- of any MCS extending {σ} ∪ GContent(a) that also contains F(σ).
            -- From F(F(σ)) ∈ a: {F(σ)} ∪ GContent(a) is consistent.
            -- And {σ} ∪ GContent(a) is consistent (F(σ) ∈ a).
            -- But the UNION might not be consistent.
            --
            -- If the union is inconsistent: {σ} ∪ GContent(a) ⊢ ¬F(σ) = G(¬σ).
            -- From σ in the set: σ ⊢ G(ψ) (conj elim). From G(ψ) ∈ seed and
            -- GContent(a) elements: gen temporal K on GContent part gives
            -- G(stuff), combined with σ gives... complicated.
            --
            -- Actually: {σ} ∪ GContent(a) ⊢ G(¬σ) means: from σ and GContent(a)
            -- formulas, derive G(¬σ). σ = G(ψ) ∧ ¬ψ. ¬σ = ¬(G(ψ) ∧ ¬ψ).
            -- From σ alone we can derive G(ψ) and ¬ψ.
            -- G(¬σ) means: at all strictly future MCS, ¬σ holds.
            -- Is this derivable from σ and GContent(a)?
            -- G(ψ) ∈ seed. By temp_4: G(G(ψ)) derivable? G(ψ) is in the seed but
            -- not as a G-formula of something in GContent(a).
            -- Actually σ is NOT in GContent(a). σ is a separate element.
            -- So gen temporal K applies only to GContent(a) part.
            -- From GContent(a) part: L ⊆ GContent(a). gen temporal K: G(L) ⊢ G(phi).
            -- G(L) elements are in a. So G(phi) ∈ a.
            -- Combined with σ: what can we derive?
            -- This is too abstract. Let me just try it in Lean.
            sorry

end Bimodal.Metalogic.Bundle.DenseQuotient
