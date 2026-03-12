import Bimodal.Metalogic.StagedConstruction.StagedExecution
import Bimodal.Syntax.Subformulas
import Mathlib.Data.Finset.Card

/-!
# Density Frame Condition for Irreflexive Temporal Semantics

This module proves the canonical model density frame condition under
irreflexive semantics using temporal axioms alone: for all MCSs M, M'
with CanonicalR(M, M') and NOT CanonicalR(M', M), there exists W with
CanonicalR(M, W) AND CanonicalR(W, M').

## Strategy: Double-Density Trick + Reflexivity Case Split

The proof uses Case A analysis combined with the "double-density trick":

1. From NOT CanonicalR(M', M), find distinguishing formula delta with
   G(delta) in M' and delta not in M.
2. Case-split on G(delta) in M:
   - Case A (G(delta) not in M): F(neg(delta)) in M.
     Apply density twice: F(F(neg(delta))) in M gives intermediate W
     with CanonicalR(M, W) and F(neg(delta)) in W. Then forward witness
     V from W with CanonicalR(W, V) and neg(delta) in V.
     Temporal linearity on M, V, M' gives three cases:
     * CanonicalR(V, M'): V is intermediate.
     * CanonicalR(M', V): delta in GContent(M') subset V but neg(delta)
       in V. Contradiction.
     * V = M': CanonicalR(W, V) = CanonicalR(W, M'), so W is intermediate.
   - Case B (G(delta) in M): Sub-split on CanonicalR(M', M'):
     * B1 (M' reflexive): Take W = M'. Both CanonicalR(M, M') and
       CanonicalR(M', M') hold.
     * B2 (M' not reflexive): GContent(M') is not a subset of M', so
       there exists gamma with G(gamma) in M' and gamma not in M'.
       If G(gamma) were in M, then gamma would be in GContent(M) subset
       M' (by CanonicalR(M, M')), contradicting gamma not in M'. So
       G(gamma) not in M, and we apply Case A with gamma.

## References

- Task 957: density_frame_condition_irreflexive_temporal
- research-001 through research-004 (density frame condition analysis)
- SeparationLemma.lean: distinguishing_formula_exists, not_G_implies_F_neg
- StagedExecution.lean: canonical_forward_reachable_linear
-/

namespace Bimodal.Metalogic.StagedConstruction

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem

/-!
## Case B Helper Lemmas

When G(delta) in M (Case B), G(neg(delta)) cannot also be in M
(under CanonicalR(M, M')), because this would place both delta and
neg(delta) in M'.
-/

/--
In Case B (G(delta) in M with CanonicalR(M, M')), G(neg(delta)) is not in M.

Proof: If G(neg(delta)) in M, then neg(delta) in GContent(M) subset M'.
Also G(delta) in M gives delta in GContent(M) subset M'.
So both delta and neg(delta) in M', contradicting M' consistency.
-/
theorem caseB_G_neg_not_in_M
    {M M' : Set Formula} {delta : Formula}
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_G_delta_M : Formula.all_future delta ∈ M) :
    Formula.all_future (Formula.neg delta) ∉ M := by
  intro h_G_neg
  have h_delta_M' : delta ∈ M' := h_R h_G_delta_M
  have h_neg_delta_M' : Formula.neg delta ∈ M' := h_R h_G_neg
  exact set_consistent_not_both h_mcs'.1 delta h_delta_M' h_neg_delta_M'

/-!
## Double-Density Core Lemma

The key lemma: given F(neg(delta)) in M, construct two layers of witnesses
using density and forward witness construction, then apply temporal linearity.
This handles both sub-case 1 (delta in M') and sub-case 2 (delta not in M').
-/

/--
Core intermediate construction via double density.

Given:
- CanonicalR(M, M'), NOT CanonicalR(M', M)
- G(delta) in M', delta not in M
- F(neg(delta)) in M (Case A condition)

Then there exists W with CanonicalR(M, W) AND CanonicalR(W, M').

Strategy (double-density trick):
1. Density on F(neg(delta)): F(F(neg(delta))) in M. Get W_1 with
   CanonicalR(M, W_1) and F(neg(delta)) in W_1.
2. Forward witness from W_1 for neg(delta): Get V with
   CanonicalR(W_1, V) and neg(delta) in V.
3. CanonicalR(M, V) by transitivity.
4. Temporal linearity on M, V, M':
   - CanonicalR(M', V): delta in GContent(M') subset V, but
     neg(delta) in V. Contradiction.
   - CanonicalR(V, M'): V is intermediate.
   - V = M': CanonicalR(W_1, V) = CanonicalR(W_1, M'), so W_1 is intermediate.
-/
theorem density_frame_condition_caseA
    {M M' : Set Formula} {delta : Formula}
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_G_delta_M' : Formula.all_future delta ∈ M')
    (h_F_neg_delta : Formula.some_future (Formula.neg delta) ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' := by
  -- Step 1: Density on F(neg(delta)) gives F(F(neg(delta))) in M
  -- Then get W_1 with CanonicalR(M, W_1) and F(neg(delta)) in W_1
  obtain ⟨W₁, h_W₁_mcs, h_R_MW₁, h_F_neg_W₁⟩ :=
    density_of_canonicalR M h_mcs (Formula.neg delta) h_F_neg_delta
  -- Step 2: Forward witness from W_1 for neg(delta)
  -- F(neg(delta)) in W_1, so get V with CanonicalR(W_1, V) and neg(delta) in V
  obtain ⟨V, h_V_mcs, h_R_W₁V, h_neg_delta_V⟩ :=
    canonical_forward_F W₁ h_W₁_mcs (Formula.neg delta) h_F_neg_W₁
  -- Step 3: CanonicalR(M, V) by transitivity
  have h_R_MV : CanonicalR M V := canonicalR_transitive M W₁ V h_mcs h_R_MW₁ h_R_W₁V
  -- Step 4: Temporal linearity on M, V, M'
  have h_lin := canonical_forward_reachable_linear M V M' h_mcs h_V_mcs h_mcs' h_R_MV h_R
  rcases h_lin with h_VM' | h_M'V | h_eq
  · -- CanonicalR(V, M'): V is the intermediate
    exact ⟨V, h_V_mcs, h_R_MV, h_VM'⟩
  · -- CanonicalR(M', V): delta in GContent(M') subset V, neg(delta) in V. Contradiction.
    exfalso
    have h_delta_GContent : delta ∈ GContent M' := h_G_delta_M'
    have h_delta_V : delta ∈ V := h_M'V h_delta_GContent
    exact set_consistent_not_both h_V_mcs.1 delta h_delta_V h_neg_delta_V
  · -- V = M': CanonicalR(W_1, V) = CanonicalR(W_1, M'), so W_1 is intermediate
    rw [h_eq] at h_R_W₁V
    exact ⟨W₁, h_W₁_mcs, h_R_MW₁, h_R_W₁V⟩

/-!
## Main Density Frame Condition

Combines Case A and Case B analysis.

- **Case A** (G(delta) not in M): Apply double-density trick directly
  with F(neg(delta)) in M. Fully proven by `density_frame_condition_caseA`.

- **Case B** (G(delta) in M, delta not in M): Two sub-cases:
  - **B1** (CanonicalR(M', M') holds): Take W = M' directly. Both
    CanonicalR(M, M') (given) and CanonicalR(M', M') (sub-case) hold.
  - **B2** (CanonicalR(M', M') fails): Since GContent(M') is not a subset
    of M', there exists gamma with G(gamma) in M' and gamma not in M'.
    Crucially, G(gamma) cannot be in M: if it were, gamma would be in
    GContent(M) subset M' (by CanonicalR(M, M')), contradicting gamma
    not in M'. So G(gamma) not in M, giving F(neg(gamma)) in M. This
    is exactly the Case A setup with gamma, so we apply Case A.
-/

/--
The density frame condition under irreflexive temporal semantics.

For all MCSs M, M' with CanonicalR(M, M') and NOT CanonicalR(M', M),
there exists an intermediate MCS W with CanonicalR(M, W) AND CanonicalR(W, M').

The proof does not require the IRR rule -- it uses a purely syntactic argument
that reduces Case B to Case A by finding an alternative distinguishing formula
from GContent(M') that is not in M'.
-/
theorem density_frame_condition
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : ¬CanonicalR M' M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' := by
  -- Step 1: Get distinguishing formula delta with G(delta) in M' and delta not in M
  obtain ⟨delta, h_G_delta_M', h_delta_not_M⟩ :=
    distinguishing_formula_exists h_mcs h_mcs' h_not_R'
  -- Step 2: Case split on G(delta) in M
  by_cases h_G_delta_M : Formula.all_future delta ∈ M
  · -- Case B: G(delta) in M, delta not in M
    -- Sub-case split on whether M' is reflexive (CanonicalR(M', M')).
    by_cases h_R'_self : CanonicalR M' M'
    · -- Sub-case B1: CanonicalR(M', M') holds.
      -- Take W = M'. Then CanonicalR(M, M') (given) and CanonicalR(M', M') hold.
      exact ⟨M', h_mcs', h_R, h_R'_self⟩
    · -- Sub-case B2: CanonicalR(M', M') does not hold.
      -- ¬(GContent(M') ⊆ M'), so ∃ gamma with G(gamma) ∈ M' and gamma ∉ M'.
      rw [CanonicalR, Set.not_subset] at h_R'_self
      obtain ⟨gamma, h_gamma_GContent, h_gamma_not_M'⟩ := h_R'_self
      -- gamma ∈ GContent(M') means G(gamma) ∈ M'
      have h_G_gamma_M' : Formula.all_future gamma ∈ M' := h_gamma_GContent
      -- Claim: G(gamma) ∉ M.
      -- Proof: If G(gamma) ∈ M, then gamma ∈ GContent(M) ⊆ M' (by CanonicalR(M, M')).
      -- But gamma ∉ M'. Contradiction.
      have h_G_gamma_not_M : Formula.all_future gamma ∉ M := by
        intro h_G_gamma_M
        have h_gamma_M' : gamma ∈ M' := h_R h_G_gamma_M
        exact h_gamma_not_M' h_gamma_M'
      -- G(gamma) ∉ M gives F(neg(gamma)) ∈ M by not_G_implies_F_neg
      have h_F_neg_gamma : Formula.some_future (Formula.neg gamma) ∈ M :=
        not_G_implies_F_neg h_mcs h_G_gamma_not_M
      -- Apply the Case A core lemma with gamma
      exact density_frame_condition_caseA h_mcs h_mcs' h_R h_G_gamma_M' h_F_neg_gamma
  · -- Case A: G(delta) not in M
    -- F(neg(delta)) in M by not_G_implies_F_neg
    have h_F_neg_delta : Formula.some_future (Formula.neg delta) ∈ M :=
      not_G_implies_F_neg h_mcs h_G_delta_M
    -- Apply the Case A core lemma
    exact density_frame_condition_caseA h_mcs h_mcs' h_R h_G_delta_M' h_F_neg_delta

/-!
## Strict Density Frame Condition

The density_frame_condition theorem provides an intermediate W with
CanonicalR(M, W) ∧ CanonicalR(W, M'). For the Cantor application, we need
the STRICT version: W is strictly between M and M' in the CanonicalR ordering.

The key insight is that when NOT CanonicalR(M', M) (which is our hypothesis),
Case A witnesses are automatically strict because they come from the double-density
construction which produces a fresh MCS.
-/

/--
When density_frame_condition fires via Case A (the double-density trick), the
intermediate W satisfies the STRICT ordering property: M < W < M' in the sense
that CanonicalR(M, W) ∧ CanonicalR(W, M') ∧ ¬CanonicalR(W, M) ∧ ¬CanonicalR(M', W).

The proof analyzes the Case A construction:
- W is either V (when CanonicalR(V, M')) or W₁ (when V = M')
- In both cases, we use the formula membership to show non-accessibility
-/
theorem density_frame_condition_strict
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : ¬CanonicalR M' M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧
      CanonicalR M W ∧ CanonicalR W M' ∧
      ¬CanonicalR W M ∧ ¬CanonicalR M' W := by
  -- Get the distinguishing formula
  obtain ⟨delta, h_G_delta_M', h_delta_not_M⟩ :=
    distinguishing_formula_exists h_mcs h_mcs' h_not_R'
  -- Case analysis on G(delta) ∈ M
  by_cases h_G_delta_M : Formula.all_future delta ∈ M
  · -- Case B: G(delta) ∈ M
    -- Sub-case on reflexivity of M'
    by_cases h_R'_self : CanonicalR M' M'
    · -- Sub-case B1: M' is reflexive
      -- KEY INSIGHT: G(neg(delta)) ∉ M by caseB_G_neg_not_in_M.
      -- By MCS negation completeness: ¬G(¬delta) ∈ M, i.e., F(delta) ∈ M!
      -- This gives us a direct forward witness V with delta ∈ V.
      --
      -- We also have:
      -- - G(delta) ∈ M' and M' reflexive, so delta ∈ M'
      -- - delta ∉ M (distinguishing formula)
      --
      -- Construct V from F(delta) in M. Then:
      -- - CanonicalR(M, V) (from forward witness)
      -- - delta ∈ V (from forward witness)
      -- - CanonicalR(V, M') (by linearity - to be shown)
      -- - ¬CanonicalR(V, M) (delta ∈ GContent(V)? or other argument)
      -- - ¬CanonicalR(M', V) (delta ∈ M', ¬delta... no, we have delta ∈ V)
      --
      -- Wait, we need ¬CanonicalR(M', V), but delta ∈ M' and delta ∈ V, so
      -- GContent(M') containing delta means delta ∈ V which holds. No contradiction.
      --
      -- The strict condition requires something else. Let me think again.
      --
      -- For ¬CanonicalR(M', V): need phi with G(phi) ∈ M' and phi ∉ V.
      -- For ¬CanonicalR(V, M): need psi with G(psi) ∈ V and psi ∉ M.
      --
      -- Key: if G(delta) ∈ V, then delta ∈ GContent(V). Since delta ∉ M,
      -- we'd have GContent(V) ⊄ M, hence ¬CanonicalR(V, M).
      --
      -- So we need G(delta) ∈ V. V is forward witness from F(delta) in M.
      -- V = Lindenbaum({delta} ∪ GContent(M)).
      -- G(delta) ∈ M (Case B condition), so G(delta) ∈ GContent(M)? No!
      -- GContent(M) = {phi | G(phi) ∈ M}, so delta ∈ GContent(M) iff G(delta) ∈ M.
      -- We have G(delta) ∈ M, so delta ∈ GContent(M).
      -- Therefore delta ∈ V (from the seed {delta} ∪ GContent(M)).
      --
      -- But we need G(delta) ∈ V, not just delta ∈ V.
      --
      -- Hmm. G(delta) is in GContent(M) only if G(G(delta)) ∈ M.
      -- By Temporal 4 (G(phi) → G(G(phi))), from G(delta) ∈ M, we get G(G(delta)) ∈ M.
      -- So G(delta) ∈ GContent(M), hence G(delta) ∈ V!
      --
      -- So we have G(delta) ∈ V, therefore delta ∈ GContent(V).
      -- Since delta ∉ M, GContent(V) ⊄ M, hence ¬CanonicalR(V, M)!
      --
      -- For ¬CanonicalR(M', V): we need phi with G(phi) ∈ M' and phi ∉ V.
      -- This is trickier. If CanonicalR(M', V), then GContent(M') ⊆ V.
      --
      -- Claim: V and M' are in the same equivalence class if both CanonicalR(V, M')
      -- and CanonicalR(M', V). But we want STRICT between.
      --
      -- Let's check linearity first to see where V sits.
      have h_G_neg_not_M : Formula.all_future (Formula.neg delta) ∉ M :=
        caseB_G_neg_not_in_M h_mcs' h_R h_G_delta_M
      -- ¬G(¬delta) ∈ M means F(delta) ∈ M (since F(phi) = ¬G(¬phi))
      -- MCS negation completeness: G(neg(delta)) ∉ M → neg(G(neg(delta))) ∈ M
      have h_F_delta : Formula.some_future delta ∈ M := by
        cases set_mcs_negation_complete h_mcs (Formula.all_future (Formula.neg delta)) with
        | inl h => exact absurd h h_G_neg_not_M
        | inr h => exact h
      -- Forward witness: get V with CanonicalR(M, V) and delta ∈ V
      obtain ⟨V, h_V_mcs, h_R_MV, h_delta_V⟩ :=
        canonical_forward_F M h_mcs delta h_F_delta
      -- G(delta) ∈ M, so by Temporal 4: G(G(delta)) ∈ M
      have h_T4 : [] ⊢ (Formula.all_future delta).imp (Formula.all_future (Formula.all_future delta)) :=
        DerivationTree.axiom [] _ (Axiom.temp_4 delta)
      have h_GG_delta_M : Formula.all_future (Formula.all_future delta) ∈ M :=
        set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T4) h_G_delta_M
      -- G(delta) ∈ GContent(M), so G(delta) ∈ V (V extends GContent(M))
      have h_G_delta_V : Formula.all_future delta ∈ V := h_R_MV h_GG_delta_M
      -- delta ∈ GContent(V), and delta ∉ M, so ¬CanonicalR(V, M)
      have h_not_VM : ¬CanonicalR V M := by
        intro h_VM
        have h_delta_M : delta ∈ M := h_VM h_G_delta_V
        exact h_delta_not_M h_delta_M
      -- Now we need to show CanonicalR(V, M') and ¬CanonicalR(M', V)
      -- By linearity: CanonicalR(V, M') or CanonicalR(M', V) or V = M'
      have h_lin := canonical_forward_reachable_linear M V M' h_mcs h_V_mcs h_mcs' h_R_MV h_R
      rcases h_lin with h_VM' | h_M'V | h_eq
      · -- CanonicalR(V, M'): V is intermediate
        -- Need to show ¬CanonicalR(M', V)
        -- If CanonicalR(M', V), then GContent(M') ⊆ V.
        -- Since M' is reflexive, delta ∈ GContent(M') (G(delta) ∈ M').
        -- So delta ∈ V, which we already know. No contradiction yet.
        --
        -- Alternative: find gamma with G(gamma) ∈ M' and gamma ∉ V.
        -- This requires V to be "strictly less" than M' in some sense.
        --
        -- Key observation: if CanonicalR(M', V), combined with CanonicalR(V, M'),
        -- we have M' ~ V in the quotient. Then GContent(M') = GContent(V) (up to equiv).
        -- But we've shown G(delta) ∈ V and delta ∈ GContent(V).
        -- If CanonicalR(M', V) and M' reflexive, M' should also have...
        --
        -- Actually, the issue is subtle. Let me try: assume CanonicalR(M', V).
        -- Then GContent(M') ⊆ V. M' is reflexive, so GContent(M') ⊆ M'.
        -- Combined with CanonicalR(V, M') means GContent(V) ⊆ M'.
        -- So GContent(M') ⊆ V and GContent(V) ⊆ M'.
        --
        -- Now, we have delta ∈ GContent(V) (from G(delta) ∈ V).
        -- If CanonicalR(M', V), then delta ∈... wait, delta ∈ GContent(M') iff G(delta) ∈ M',
        -- which is true. So delta ∈ GContent(M'). If CanonicalR(M', V), delta ∈ V. Consistent.
        --
        -- We need to find something that distinguishes M' from V.
        -- V = Lindenbaum({delta} ∪ GContent(M)). The key is that V might NOT contain
        -- all of M' because V was built from M's GContent, not M'.
        --
        -- Since ¬CanonicalR(M', M), there's a gap. Can we leverage that?
        -- ¬CanonicalR(M', M) means GContent(M') ⊄ M. We already have delta witnessing this.
        -- But delta ∈ V, so delta doesn't help distinguish V from M'.
        --
        -- We need gamma with G(gamma) ∈ M' and gamma ∉ V.
        -- Since M' is reflexive, G(gamma) ∈ M' implies gamma ∈ M'.
        -- For gamma ∉ V, we need gamma not in Lindenbaum({delta} ∪ GContent(M)).
        --
        -- Claim: ¬delta ∉ V (since delta ∈ V and V consistent).
        -- If G(¬delta) ∈ M', then ¬delta ∈ GContent(M'). If CanonicalR(M', V),
        -- ¬delta ∈ V. But V has delta, contradiction! So G(¬delta) ∉ M'.
        --
        -- Hmm, this doesn't directly give ¬CanonicalR(M', V).
        --
        -- Let me try proof by contradiction. Assume CanonicalR(M', V).
        -- Then GContent(M') ⊆ V.
        -- Since V has delta and ¬delta would make V inconsistent,
        -- we need GContent(M') to not force ¬delta into V.
        -- G(¬delta) ∈ M' would put ¬delta ∈ GContent(M') ⊆ V. Contradiction with V consistent.
        -- So we need to show G(¬delta) ∈ M' if CanonicalR(M', V) held... but that's not automatic.
        --
        -- Actually, the situation might be that CanonicalR(M', V) CAN hold in some cases.
        -- The quotient construction allows M' ~ V. But for the strict density, we need
        -- a V that's strictly between.
        --
        -- Given the complexity, let me try using the non-strict density and then
        -- applying additional structure.
        --
        -- Alternative: use the specific construction from density_frame_condition_caseA.
        -- In Case A, we use the double-density trick which might give stricter control.
        --
        -- For now, let me check if there's a simpler argument.
        -- We have:
        -- - CanonicalR(M, V) and CanonicalR(V, M')
        -- - ¬CanonicalR(V, M) (proven)
        -- - Need: ¬CanonicalR(M', V)
        --
        -- The forward witness V = Lindenbaum({delta} ∪ GContent(M)).
        -- For ¬CanonicalR(M', V): need to show GContent(M') ⊄ V.
        --
        -- Suppose CanonicalR(M', V). Then for all phi, G(phi) ∈ M' → phi ∈ V.
        -- M' is reflexive, so for all phi, G(phi) ∈ M' → phi ∈ M'.
        -- Combined: for all phi, G(phi) ∈ M' → phi ∈ V ∩ M'.
        --
        -- Consider: what formulas are NOT in V?
        -- V is the Lindenbaum extension of {delta} ∪ GContent(M).
        -- A formula phi is NOT in V iff ¬phi is derivable from {delta} ∪ GContent(M),
        -- or equivalently, phi.neg ∈ V.
        --
        -- Key: ¬delta ∉ V (since delta ∈ V and V consistent).
        -- So if G(¬delta) ∈ M', then ¬delta ∈ GContent(M'), and if CanonicalR(M', V),
        -- ¬delta ∈ V. Contradiction!
        --
        -- So: if G(¬delta) ∈ M', then ¬CanonicalR(M', V).
        -- Does G(¬delta) ∈ M'? We have G(delta) ∈ M' (given).
        -- In general, G(delta) and G(¬delta) can both be in M' if delta ∈ M' and ¬delta ∈ M',
        -- which would make M' inconsistent. So at most one of G(delta), G(¬delta) is in M'.
        -- We know G(delta) ∈ M'. Does this exclude G(¬delta)?
        --
        -- If M' is reflexive and consistent:
        -- G(delta) ∈ M' → delta ∈ M' (reflexivity)
        -- If G(¬delta) ∈ M' → ¬delta ∈ M' (reflexivity)
        -- delta ∈ M' and ¬delta ∈ M' → M' inconsistent. Contradiction.
        -- So G(¬delta) ∉ M' (since M' is MCS hence consistent).
        --
        -- Hmm, so G(¬delta) ∉ M', which doesn't help directly.
        --
        -- Try another approach: since ¬CanonicalR(M', M), there exists a formula
        -- witnessing this. We used delta. But in M', since M' is reflexive,
        -- delta ∈ M'. And delta ∉ M. So M' has something M doesn't.
        --
        -- For V: V was built from M's seed. V has delta (explicitly added).
        -- V has GContent(M). What's in M' but not in V?
        --
        -- Consider: CanonicalR(M, M') means GContent(M) ⊆ M'.
        -- So V ⊇ GContent(M), and M' ⊇ GContent(M). Both contain GContent(M).
        -- V additionally has delta (and its closure).
        -- M' is reflexive, so M' ⊇ GContent(M').
        --
        -- The gap: GContent(M') might have things not in GContent(M).
        -- Specifically, since G(delta) ∈ M' but G(delta) ∈ M too (Case B!).
        -- So delta ∈ GContent(M) ∩ GContent(M').
        --
        -- What about G(G(delta))? By Temp 4, G(delta) ∈ M → G(G(delta)) ∈ M.
        -- So G(delta) ∈ GContent(M).
        -- Similarly for M'.
        --
        -- It seems like GContent(M) and GContent(M') might overlap significantly in Case B.
        --
        -- Let me try: what if CanonicalR(V, M') AND CanonicalR(M', V)? Then V ~ M' in quotient.
        -- But we've shown ¬CanonicalR(V, M) and CanonicalR(M, V).
        -- So M < V ~ M' in the quotient ordering. That's STILL a strict intermediate!
        -- [M] < [V] = [M'] means we found something strictly between [M] and [M'].
        -- But wait, [V] = [M'] means V is in the same equivalence class as M'.
        -- So V is NOT strictly between M and M' in the quotient.
        --
        -- This means we need V ~ M' to be FALSE for V to be a strict intermediate.
        -- I.e., either ¬CanonicalR(V, M') or ¬CanonicalR(M', V).
        -- We've established CanonicalR(V, M') in this branch.
        -- So we need ¬CanonicalR(M', V).
        --
        -- The proof is getting complex. Let me try a different witness.
        -- Instead of using F(delta) directly, use the double-density trick from Case A.
        --
        -- Actually, I realize: we have G(¬delta) ∉ M (by caseB_G_neg_not_in_M).
        -- So F(¬¬delta) ∈ M by not_G_implies_F_neg.
        -- And F(¬¬delta) using double-density might give a better witness.
        --
        -- But this is getting too complex. Let me use the existing
        -- density_frame_condition and check if the result is strict.
        -- If not, iterate with a different approach.
        --
        -- For now, I'll establish the refine structure and see where we are.
        refine ⟨V, h_V_mcs, h_R_MV, h_VM', h_not_VM, ?_⟩
        -- Need: ¬CanonicalR M' V
        -- Strategy: ¬delta ∉ V (since delta ∈ V), so if G(¬delta) ∈ M', then ¬CanonicalR(M', V)
        -- But we showed G(¬delta) ∉ M' when M' is reflexive and consistent with G(delta) ∈ M'.
        -- So this approach doesn't work directly.
        --
        -- Alternative: find ANY gamma with G(gamma) ∈ M' and gamma ∉ V.
        -- Since V = Lindenbaum({delta} ∪ GContent(M)) and M' ≠ V (hopefully),
        -- there should be such a gamma.
        --
        -- Claim: M' and V differ because M' has formulas from its own closure that V lacks.
        -- M' = some MCS, V = Lindenbaum starting from M's GContent.
        --
        -- Key insight for Case B1 + CanonicalR(V, M'):
        -- If we also have CanonicalR(M', V), then M' ~ V.
        -- But ¬CanonicalR(V, M) means [V] > [M].
        -- And CanonicalR(M, M') means [M] ≤ [M'].
        -- If [V] = [M'], then [M] ≤ [M'] = [V], and [V] > [M].
        -- So [M] < [M'] = [V], meaning M' is strictly above M in the quotient.
        -- But we need an intermediate BETWEEN [M] and [M'], not equal to [M'].
        --
        -- So if CanonicalR(M', V), our V is NOT the right witness.
        -- We need to find a DIFFERENT witness in Case B1 + CanonicalR(V, M') + CanonicalR(M', V).
        --
        -- This is where iteration comes in: apply density to M and V (or M and M'')
        -- with a different distinguishing formula.
        --
        -- For now, let me assume ¬CanonicalR(M', V) and see if we can prove it or
        -- need to restructure.
        --
        -- Actually, let me use the research insight: Case B1 requires iteration.
        -- The termination argument is that some measure decreases.
        --
        -- For now, use sorry for this subcase. The full solution requires
        -- well-founded iteration as described in the plan.
        sorry
      · -- CanonicalR(M', V): delta ∈ GContent(M') ⊆ V, but delta ∈ V already. Consistent.
        -- This case means M' sees V. But V also has delta from construction.
        -- We have:
        -- - CanonicalR(M, V) - V is forward from M
        -- - CanonicalR(M', V) - M' sees V
        -- - ¬CanonicalR(V, M) - V doesn't see back to M
        --
        -- In terms of the quotient: [M] ≤ [V] (CanonicalR(M, V)) and [M'] ≤ [V] (CanonicalR(M', V)).
        -- Also [M] ≤ [M'] (CanonicalR(M, M')).
        -- And [M] < [V] (since ¬CanonicalR(V, M)).
        --
        -- By linearity of ≤: either [M'] ≤ [M] or [M] ≤ [M'].
        -- We have ¬CanonicalR(M', M), so... wait, that doesn't directly give [M'] > [M].
        -- ¬CanonicalR(M', M) means GContent(M') ⊄ M, but quotient ≤ is about existence of witness.
        --
        -- Actually, the quotient order is: [M] ≤ [M'] iff CanonicalR(M, M') ∨ [M] = [M'].
        -- [M] < [M'] iff CanonicalR(M, M') ∧ ¬CanonicalR(M', M).
        --
        -- We have CanonicalR(M, M') and ¬CanonicalR(M', M), so [M] < [M'].
        --
        -- Now, if CanonicalR(M', V) and CanonicalR(M, V):
        -- [M'] ≤ [V] and [M] ≤ [V].
        -- If also CanonicalR(V, M'), then [V] = [M'].
        -- If CanonicalR(V, M), then [V] = [M]. But ¬CanonicalR(V, M), so [V] ≠ [M].
        --
        -- We need V to be strictly between M and M'.
        -- [M] < [V] (from ¬CanonicalR(V, M)) and [V] < [M'] (need CanonicalR(V, M') ∧ ¬CanonicalR(M', V)).
        -- But in this branch, we have CanonicalR(M', V), which means [M'] ≤ [V].
        -- Combined with CanonicalR(M, M') → CanonicalR(M, V) (transitivity? not directly).
        --
        -- Hmm, we have CanonicalR(M, V) already.
        --
        -- In this branch (h_M'V): CanonicalR(M', V) holds.
        -- For V to be strictly between M and M' in the quotient:
        -- [M] < [V] < [M'].
        -- But CanonicalR(M', V) means [M'] ≤ [V], so [V] ≥ [M'], not [V] < [M'].
        --
        -- This means V is NOT strictly between M and M'. V is "above or equal to" M'.
        -- So V is not the right witness in this branch.
        --
        -- We need a different approach: find W that's strictly between.
        -- One option: use density_frame_condition on M and V (if [M] < [V]).
        -- But that requires CanonicalR(M, V) and ¬CanonicalR(V, M), which we have!
        -- So we can recurse: find W' strictly between M and V, then W' is between M and M' too.
        --
        -- This is the iteration approach!
        -- The measure that decreases: V is "closer" to M than M' was? Not obvious.
        --
        -- Alternative: In this branch, since CanonicalR(M', V), V has all of GContent(M').
        -- But V was built from GContent(M). So GContent(M') ⊆ GContent(V) ⊆ ... ?
        --
        -- Actually, the canonical relation is transitive, so:
        -- CanonicalR(M, V) and CanonicalR(M', V) and CanonicalR(M, M')
        -- This doesn't directly help.
        --
        -- Let me try: since [M] < [M'] and [M'] ≤ [V] (CanonicalR(M', V)),
        -- we have [M] < [V] (transitivity in the quotient order).
        -- And ¬CanonicalR(V, M) confirms [V] ≠ [M].
        --
        -- But we need [V] strictly between [M] and [M'], which requires [V] < [M'].
        -- CanonicalR(M', V) means [M'] ≤ [V], so [V] ≥ [M'], contradiction with [V] < [M'].
        --
        -- So in this branch, V is NOT the right witness. We need iteration.
        --
        -- For now, use sorry. The full solution requires well-founded iteration.
        exfalso
        -- Actually, can we derive a contradiction in this branch?
        -- We have:
        -- - CanonicalR(M', V): GContent(M') ⊆ V
        -- - delta ∈ GContent(M') (since G(delta) ∈ M')
        -- - delta ∈ V (from forward witness construction)
        -- - delta ∉ M (distinguishing formula)
        -- - CanonicalR(M, V): GContent(M) ⊆ V
        --
        -- These are all consistent, no contradiction.
        --
        -- The issue: we need a witness strictly between M and M', but V is not it.
        -- Case B1 with h_M'V leads to non-strict intermediate.
        --
        -- For now, sorry.
        sorry
      · -- V = M': use a different witness
        -- If V = M', then the forward witness from F(delta) in M landed at M'.
        -- This means M' is exactly Lindenbaum({delta} ∪ GContent(M)).
        -- We have:
        -- - CanonicalR(M, M') (given)
        -- - ¬CanonicalR(M', M) (given, distinguishing formula)
        -- - delta ∈ M' (from forward witness)
        -- - G(delta) ∈ M (Case B)
        -- - M' reflexive (Case B1)
        --
        -- We need a strict intermediate between M and M'.
        --
        -- Try: apply density to M and M' using the existing density_frame_condition.
        -- The result W satisfies CanonicalR(M, W) and CanonicalR(W, M').
        -- Case B1 gives W = M'. But since V = M' is the forward witness from F(delta),
        -- maybe this iteration doesn't help.
        --
        -- Alternative: use a DIFFERENT formula to construct the intermediate.
        -- We have G(neg(delta)) ∉ M. So F(neg(neg(delta))) ∈ M.
        -- Use this to get a different witness.
        --
        -- Actually, F(neg(neg(delta))) = ¬G(¬(¬¬delta)) = ¬G(neg(neg(neg(delta)))).
        -- This is getting complex.
        --
        -- For now, sorry. The full solution needs more careful analysis or iteration.
        sorry
    · -- Sub-case B2: M' is not reflexive
      -- This reduces to Case A with a different formula
      rw [CanonicalR, Set.not_subset] at h_R'_self
      obtain ⟨gamma, h_gamma_GContent, h_gamma_not_M'⟩ := h_R'_self
      have h_G_gamma_M' : Formula.all_future gamma ∈ M' := h_gamma_GContent
      have h_G_gamma_not_M : Formula.all_future gamma ∉ M := by
        intro h_G_gamma_M
        have h_gamma_M' : gamma ∈ M' := h_R h_G_gamma_M
        exact h_gamma_not_M' h_gamma_M'
      have h_F_neg_gamma : Formula.some_future (Formula.neg gamma) ∈ M :=
        not_G_implies_F_neg h_mcs h_G_gamma_not_M
      -- Now apply Case A logic with gamma
      obtain ⟨W₁, h_W₁_mcs, h_R_MW₁, h_F_neg_W₁⟩ :=
        density_of_canonicalR M h_mcs (Formula.neg gamma) h_F_neg_gamma
      obtain ⟨V, h_V_mcs, h_R_W₁V, h_neg_gamma_V⟩ :=
        canonical_forward_F W₁ h_W₁_mcs (Formula.neg gamma) h_F_neg_W₁
      have h_R_MV : CanonicalR M V := canonicalR_transitive M W₁ V h_mcs h_R_MW₁ h_R_W₁V
      have h_lin := canonical_forward_reachable_linear M V M' h_mcs h_V_mcs h_mcs' h_R_MV h_R
      rcases h_lin with h_VM' | h_M'V | h_eq
      · -- V is intermediate: CanonicalR(V, M')
        -- Need to prove strictness: ¬CanonicalR(V, M) ∧ ¬CanonicalR(M', V)
        refine ⟨V, h_V_mcs, h_R_MV, h_VM', ?_, ?_⟩
        · -- ¬CanonicalR(V, M): Show GContent(V) ⊄ M
          -- V has neg(gamma) ∈ V (from construction)
          -- If G(neg(gamma)) ∈ V, then neg(gamma) ∈ GContent(V)
          -- Then if CanonicalR(V, M), neg(gamma) ∈ M
          -- But G(gamma) ∉ M and G(neg(gamma)) ∉ M... wait, we don't know G(neg(gamma)) ∈ V
          sorry
        · -- ¬CanonicalR(M', V): Show GContent(M') ⊄ V
          -- G(gamma) ∈ M' so gamma ∈ GContent(M')
          -- If CanonicalR(M', V), gamma ∈ V
          -- But neg(gamma) ∈ V, contradiction with V consistent
          intro h_M'V_converse
          have h_gamma_V : gamma ∈ V := h_M'V_converse h_G_gamma_M'
          exact set_consistent_not_both h_V_mcs.1 gamma h_gamma_V h_neg_gamma_V
      · -- CanonicalR(M', V): gamma in GContent(M') ⊆ V, but neg(gamma) in V. Contradiction.
        exfalso
        have h_gamma_V : gamma ∈ V := h_M'V h_G_gamma_M'
        exact set_consistent_not_both h_V_mcs.1 gamma h_gamma_V h_neg_gamma_V
      · -- V = M': use W₁ instead
        rw [h_eq] at h_R_W₁V
        refine ⟨W₁, h_W₁_mcs, h_R_MW₁, h_R_W₁V, ?_, ?_⟩
        · -- ¬CanonicalR(W₁, M)
          sorry
        · -- ¬CanonicalR(M', W₁)
          -- V = M' and CanonicalR(W₁, V) = CanonicalR(W₁, M')
          -- W₁ has F(neg(gamma)) ∈ W₁
          -- If CanonicalR(M', W₁), then GContent(M') ⊆ W₁
          -- gamma ∈ GContent(M') so gamma ∈ W₁
          -- We need neg(gamma) ∈ W₁ to get contradiction, but W₁ has F(neg(gamma)), not neg(gamma)
          sorry
  · -- Case A: G(delta) ∉ M
    have h_F_neg_delta : Formula.some_future (Formula.neg delta) ∈ M :=
      not_G_implies_F_neg h_mcs h_G_delta_M
    obtain ⟨W₁, h_W₁_mcs, h_R_MW₁, h_F_neg_W₁⟩ :=
      density_of_canonicalR M h_mcs (Formula.neg delta) h_F_neg_delta
    obtain ⟨V, h_V_mcs, h_R_W₁V, h_neg_delta_V⟩ :=
      canonical_forward_F W₁ h_W₁_mcs (Formula.neg delta) h_F_neg_W₁
    have h_R_MV : CanonicalR M V := canonicalR_transitive M W₁ V h_mcs h_R_MW₁ h_R_W₁V
    have h_lin := canonical_forward_reachable_linear M V M' h_mcs h_V_mcs h_mcs' h_R_MV h_R
    rcases h_lin with h_VM' | h_M'V | h_eq
    · -- V is intermediate with CanonicalR(V, M')
      refine ⟨V, h_V_mcs, h_R_MV, h_VM', ?_, ?_⟩
      · -- ¬CanonicalR(V, M): Show GContent(V) ⊄ M
        -- If CanonicalR(V, M), then for all phi, G(phi) ∈ V implies phi ∈ M
        -- V has neg(delta) ∈ V. If G(neg(delta)) ∈ V, then neg(delta) ∈ M...
        -- But we don't know G(neg(delta)) ∈ V.
        -- Different approach: we know delta ∉ M.
        -- If CanonicalR(V, M), then delta ∉ M means G(delta) ∉ V... wait, that's backwards.
        -- Hmm, let me think again.
        -- Actually, the distinguishing formula gives us:
        --   G(delta) ∈ M' and delta ∉ M
        -- If CanonicalR(V, M), then GContent(V) ⊆ M.
        -- We need to find phi with G(phi) ∈ V and phi ∉ M.
        -- V has neg(delta) ∈ V. Does V have G(neg(delta))? Not necessarily.
        -- V is constructed as forward witness from W₁ for neg(delta).
        -- V is Lindenbaum extension of {neg(delta)} ∪ GContent(W₁).
        -- So GContent(V) = {phi | G(phi) ∈ V}.
        -- The issue is we don't know what G-formulas are in V.
        --
        -- Alternative: by linearity of CanonicalR on M, V, M':
        -- CanonicalR(V, M') holds, CanonicalR(M, V) holds.
        -- If also CanonicalR(V, M), then by transitivity/linearity...
        -- We have CanonicalR(M, V) and CanonicalR(V, M), so M ~ V in the quotient.
        -- We have CanonicalR(V, M') and ¬CanonicalR(M', V) (need to check).
        --
        -- Wait, I should check: if CanonicalR(V, M) held, combined with CanonicalR(M, V),
        -- we'd have M ~ V. Then since CanonicalR(M, M') and CanonicalR(V, M'), these
        -- are consistent. But we need to derive a contradiction.
        --
        -- The key is: if M ~ V (mutual accessibility), then V satisfies the same
        -- G-formulas as M (up to equivalence). Specifically, if G(phi) ∈ M, then
        -- phi ∈ M (since GContent(M) ⊆ M by ... wait, we don't have reflexivity of M).
        --
        -- New approach: use formula membership directly.
        -- delta ∉ M. V has neg(delta). We want to show CanonicalR(V, M) is false.
        -- CanonicalR(V, M) means GContent(V) ⊆ M.
        -- We need to find a formula phi with G(phi) ∈ V and phi ∉ M.
        --
        -- Consider: by the density construction, W₁ is from {F(neg(delta))} ∪ GContent(M).
        -- Then V is from {neg(delta)} ∪ GContent(W₁).
        -- The G-formulas in V depend on the Lindenbaum extension.
        --
        -- INSIGHT: If G(neg(delta)) is consistent with V's seed, then G(neg(delta)) ∈ V
        -- (by maximality). And neg(delta) ∈ GContent(V). Then if CanonicalR(V, M),
        -- neg(delta) ∈ M. But we have delta ∉ M...
        -- Wait, delta ∉ M doesn't imply neg(delta) ∈ M (not complete for negation).
        -- And neg(delta) ∈ M doesn't contradict delta ∉ M (though it would mean delta ∉ M).
        --
        -- Proof by contradiction: assume CanonicalR(V, M) and derive contradiction or
        -- show M must be reflexive (problematic case).
        intro h_VM
        -- If CanonicalR(V, M) and CanonicalR(M, V) (which follows from h_R_MV via W₁), then
        -- M and V are in the same equivalence class.
        --
        -- We have CanonicalR(M, W₁), CanonicalR(W₁, V), so CanonicalR(M, V) (h_R_MV).
        -- If also CanonicalR(V, M), then by transitivity pattern, M is reflexive.
        have h_M_refl : CanonicalR M M := by
          intro phi h_phi_GContent
          -- phi ∈ GContent(M) means G(phi) ∈ M
          -- By Temporal 4: G(G(phi)) ∈ M, so G(phi) ∈ GContent(M)
          -- G(phi) ∈ GContent(M) ⊆ W₁ (by h_R_MW₁)
          -- G(phi) ∈ W₁ gives phi ∈ GContent(W₁) ⊆ V (by h_R_W₁V)
          -- phi ∈ V and if CanonicalR(V, M), phi ∈ ... wait, that's not quite right.
          -- We need: G(phi) ∈ V and if CanonicalR(V, M), then phi ∈ M.
          have h_T4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
            DerivationTree.axiom [] _ (Axiom.temp_4 phi)
          have h_GG_phi_M : Formula.all_future (Formula.all_future phi) ∈ M :=
            set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T4) h_phi_GContent
          -- G(phi) ∈ GContent(M) ⊆ W₁
          have h_G_phi_W₁ : Formula.all_future phi ∈ W₁ := h_R_MW₁ h_GG_phi_M
          -- By Temporal 4 in W₁: G(G(phi)) ∈ W₁
          have h_GG_phi_W₁ : Formula.all_future (Formula.all_future phi) ∈ W₁ :=
            set_mcs_implication_property h_W₁_mcs (theorem_in_mcs h_W₁_mcs h_T4) h_G_phi_W₁
          -- G(phi) ∈ GContent(W₁) ⊆ V
          have h_G_phi_V : Formula.all_future phi ∈ V := h_R_W₁V h_GG_phi_W₁
          -- phi ∈ GContent(V) ⊆ M (by h_VM)
          exact h_VM h_G_phi_V
        -- Now M is reflexive. The contradiction must come from formula membership.
        -- With M reflexive, GContent(M) ⊆ M.
        -- We have delta ∉ M. Since M is reflexive and G(delta) ∉ M:
        --   If G(delta) ∈ M, then delta ∈ GContent(M) ⊆ M. But delta ∉ M. Contradiction.
        --   So G(delta) ∉ M, which is h_G_delta_M. Consistent.
        --
        -- The issue: we need to show ¬CanonicalR(V, M) but we've assumed it.
        -- We need to derive a contradiction from h_VM.
        --
        -- Key observation: V has neg(delta). If G(neg(delta)) ∈ V, then neg(delta) ∈ GContent(V).
        -- If CanonicalR(V, M), then neg(delta) ∈ M. Since delta ∉ M, neg(delta) ∈ M (MCS).
        -- This is consistent, not a contradiction.
        --
        -- Alternative: V comes from W₁ via canonical_forward_F for neg(delta).
        -- V = Lindenbaum({neg(delta)} ∪ GContent(W₁)).
        --
        -- If M ~ V (from h_VM and h_R_MV), then GContent(M) = GContent(V) (up to equivalence).
        -- But V has neg(delta) ∈ V. Does GContent(V) differ from GContent(M)?
        --
        -- For now, this case requires iteration. Use sorry.
        sorry
      · -- ¬CanonicalR(M', V): Show GContent(M') ⊄ V
        -- G(delta) ∈ M' so delta ∈ GContent(M')
        -- If CanonicalR(M', V), delta ∈ V
        -- But neg(delta) ∈ V, contradiction with V consistent
        intro h_M'V_converse
        have h_delta_V : delta ∈ V := h_M'V_converse h_G_delta_M'
        exact set_consistent_not_both h_V_mcs.1 delta h_delta_V h_neg_delta_V
    · -- CanonicalR(M', V): delta in GContent(M') ⊆ V, but neg(delta) in V. Contradiction.
      exfalso
      have h_delta_V : delta ∈ V := h_M'V h_G_delta_M'
      exact set_consistent_not_both h_V_mcs.1 delta h_delta_V h_neg_delta_V
    · -- V = M': use W₁ as intermediate
      rw [h_eq] at h_R_W₁V
      refine ⟨W₁, h_W₁_mcs, h_R_MW₁, h_R_W₁V, ?_, ?_⟩
      · -- ¬CanonicalR(W₁, M)
        -- Proof by contradiction: assume CanonicalR(W₁, M) and CanonicalR(M, W₁).
        -- Then by the mutual_canonicalR_implies_refl pattern, M must be reflexive.
        -- But if M is reflexive, GContent(M) ⊆ M.
        -- Combined with CanonicalR(M, M') and M' having G(delta), we can derive
        -- that M' must be in the "forward" direction from M.
        -- The key: if W₁ ~ M in quotient, and V = M' = forward from W₁,
        -- then M ~ W₁ < M'. But we also need ¬CanonicalR(W₁, M) for strictness.
        --
        -- Strategy: show that if CanonicalR(W₁, M), combined with CanonicalR(M, W₁),
        -- forces a contradiction with the structure of V = M'.
        intro h_W₁M
        -- h_W₁M : CanonicalR W₁ M means GContent(W₁) ⊆ M
        -- h_R_MW₁ : CanonicalR M W₁ means GContent(M) ⊆ W₁
        -- By Temporal 4 propagation, this makes M reflexive
        have h_M_refl : CanonicalR M M := by
          intro phi h_phi_GContent
          -- phi ∈ GContent(M) means G(phi) ∈ M
          -- By Temporal 4: G(G(phi)) ∈ M, so G(phi) ∈ GContent(M) ⊆ W₁
          have h_T4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
            DerivationTree.axiom [] _ (Axiom.temp_4 phi)
          have h_GG_phi_M : Formula.all_future (Formula.all_future phi) ∈ M :=
            set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T4) h_phi_GContent
          -- G(phi) ∈ GContent(M) ⊆ W₁
          have h_G_phi_W₁ : Formula.all_future phi ∈ W₁ := h_R_MW₁ h_GG_phi_M
          -- phi ∈ GContent(W₁) ⊆ M
          exact h_W₁M h_G_phi_W₁
        -- Now M is reflexive. Since GContent(M) ⊆ M, delta ∉ GContent(M) means G(delta) ∉ M.
        -- This is h_G_delta_M which we already have.
        -- The contradiction: V = M' and M' is not reflexive (since G(delta) ∈ M' and neg(delta) ∈ M'),
        -- but M' is the Lindenbaum of {neg(delta)} ∪ GContent(W₁).
        -- Since W₁ ~ M, GContent(W₁) = GContent(M) (by the reflexivity).
        -- So M' = Lindenbaum({neg(delta)} ∪ GContent(M)).
        -- But M' has G(delta) ∈ M' (h_G_delta_M'), which means G(delta) was added by Lindenbaum.
        -- This requires neg(G(delta)) = F(neg(delta)) to NOT be in the consistent seed.
        -- But neg(delta) is in the seed, and from neg(delta)... hmm, this doesn't derive F(neg(delta)).
        -- Actually, the issue is more subtle.
        --
        -- Alternative: use h_not_R' : ¬CanonicalR M' M directly.
        -- Since W₁ ~ M and CanonicalR(W₁, M'), we have CanonicalR(M, M') (by transitivity).
        -- If also CanonicalR(M', W₁), then M' ~ W₁ ~ M, so CanonicalR(M', M). Contradiction.
        -- So ¬CanonicalR(M', W₁).
        -- But we're trying to show ¬CanonicalR(W₁, M), not ¬CanonicalR(M', W₁).
        --
        -- Hmm, this is still complex. Let me try using the irreflexive_mcs_has_strict_future.
        -- If M is reflexive, this lemma doesn't apply directly.
        --
        -- Wait, maybe the issue is that M being reflexive leads to V = M' ~ M, which contradicts
        -- ¬CanonicalR(M', M).
        --
        -- If W₁ ~ M and CanonicalR(W₁, M') and V = M':
        -- - CanonicalR(M, W₁) ✓
        -- - CanonicalR(W₁, M) (assumption for contradiction)
        -- - CanonicalR(W₁, M') ✓ (this is h_R_W₁V with V = M')
        -- By transitivity: CanonicalR(M, M') (which we have as h_R)
        --
        -- If additionally CanonicalR(M', W₁):
        -- - Then CanonicalR(M', M) by transitivity (M' → W₁ → M). Contradiction with h_not_R'.
        -- So ¬CanonicalR(M', W₁).
        --
        -- But ¬CanonicalR(M', W₁) means there exists phi with G(phi) ∈ M' and phi ∉ W₁.
        -- We have G(delta) ∈ M' (h_G_delta_M'). Is delta ∉ W₁?
        --
        -- If delta ∈ W₁:
        -- - By our assumption CanonicalR(W₁, M): GContent(W₁) ⊆ M
        -- - If G(delta) ∈ W₁, then delta ∈ GContent(W₁) ⊆ M. But delta ∉ M. Contradiction.
        -- - So G(delta) ∉ W₁.
        -- - But delta ∈ W₁ and G(delta) ∉ W₁ is consistent.
        --
        -- If delta ∉ W₁:
        -- - Then G(delta) ∈ M' and delta ∉ W₁, witnessing ¬CanonicalR(M', W₁).
        --
        -- So either:
        -- 1. delta ∈ W₁: Then G(delta) ∉ W₁ (shown above), which doesn't contradict our assumption.
        -- 2. delta ∉ W₁: Consistent with ¬CanonicalR(M', W₁).
        --
        -- The key is: does delta ∈ W₁ or delta ∉ W₁?
        --
        -- W₁ = Lindenbaum({F(neg(delta))} ∪ GContent(M)).
        -- If delta is consistent with the seed, it might be added.
        -- If neg(delta) is in the seed or derivable, then delta ∉ W₁.
        --
        -- Is neg(delta) derivable from {F(neg(delta))} ∪ GContent(M)?
        -- F(neg(delta)) doesn't derive neg(delta) alone.
        -- GContent(M): if G(neg(delta)) ∈ M, then neg(delta) ∈ GContent(M), so neg(delta) ∈ W₁.
        --
        -- Is G(neg(delta)) ∈ M?
        -- We have h_G_neg_not_M from caseB... wait, that's for Case B.
        -- In Case A, we have G(delta) ∉ M, but we don't know about G(neg(delta)).
        --
        -- If G(neg(delta)) ∈ M, then neg(delta) ∈ W₁, so delta ∉ W₁.
        -- If G(neg(delta)) ∉ M, then F(delta) ∈ M (by MCS). F(delta) is in M but not directly in W₁'s seed.
        --
        -- Let's case-split on G(neg(delta)) ∈ M.
        by_cases h_G_neg_delta_M : Formula.all_future (Formula.neg delta) ∈ M
        · -- G(neg(delta)) ∈ M, so neg(delta) ∈ GContent(M) ⊆ W₁
          have h_neg_delta_W₁ : Formula.neg delta ∈ W₁ := h_R_MW₁ h_G_neg_delta_M
          -- So delta ∉ W₁ (by W₁ consistent)
          have h_delta_not_W₁ : delta ∉ W₁ := fun h => set_consistent_not_both h_W₁_mcs.1 delta h h_neg_delta_W₁
          -- G(delta) ∈ M' and delta ∉ W₁ means ¬CanonicalR(M', W₁)
          -- This is consistent with our structure but doesn't give ¬CanonicalR(W₁, M) directly.
          -- We need to find phi with G(phi) ∈ W₁ and phi ∉ M.
          -- Since G(neg(delta)) ∈ M, by Temporal 4: G(G(neg(delta))) ∈ M.
          -- So G(neg(delta)) ∈ GContent(M) ⊆ W₁.
          have h_T4_neg : [] ⊢ (Formula.all_future (Formula.neg delta)).imp
              (Formula.all_future (Formula.all_future (Formula.neg delta))) :=
            DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.neg delta))
          have h_GG_neg_delta_M : Formula.all_future (Formula.all_future (Formula.neg delta)) ∈ M :=
            set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T4_neg) h_G_neg_delta_M
          have h_G_neg_delta_W₁ : Formula.all_future (Formula.neg delta) ∈ W₁ := h_R_MW₁ h_GG_neg_delta_M
          -- neg(delta) ∈ GContent(W₁). If CanonicalR(W₁, M), then neg(delta) ∈ M.
          have h_neg_delta_M : Formula.neg delta ∈ M := h_W₁M h_G_neg_delta_W₁
          -- But we have delta ∉ M, which is consistent with neg(delta) ∈ M.
          -- We need a different witness.
          -- Since M is reflexive (h_M_refl), GContent(M) ⊆ M.
          -- GContent(W₁) ⊆ M (from h_W₁M).
          -- By our earlier analysis, GContent(M) = GContent(W₁) when M is reflexive and W₁ ~ M.
          -- So everything in GContent(W₁) is in M. No contradiction here.
          --
          -- The contradiction must come from V = M'.
          -- M' = Lindenbaum({neg(delta)} ∪ GContent(W₁)).
          -- M' has G(delta) (given). So G(delta) was added by Lindenbaum.
          -- If G(delta) is added, then neg(G(delta)) = F(neg(delta)) is not in the Lindenbaum extension.
          -- But F(neg(delta)) ∈ W₁, and if the seed includes something that derives F(neg(delta))...
          -- GContent(W₁) might include G(F(neg(delta))) if it's in W₁.
          --
          -- Actually, F(neg(delta)) ∈ W₁. If G(F(neg(delta))) ∈ W₁, then F(neg(delta)) ∈ GContent(W₁).
          -- Then F(neg(delta)) ∈ M' (seed includes GContent(W₁)).
          -- If F(neg(delta)) ∈ M', can M' also have G(delta)?
          -- F(neg(delta)) = neg(G(delta)). So F(neg(delta)) and G(delta) are contradictory!
          -- If F(neg(delta)) ∈ M' and G(delta) ∈ M', M' is inconsistent. Contradiction.
          --
          -- So: if G(F(neg(delta))) ∈ W₁, then M' is inconsistent.
          -- Therefore: G(F(neg(delta))) ∉ W₁.
          -- This means F(neg(delta)) ∉ GContent(W₁).
          --
          -- But F(neg(delta)) ∈ W₁. So G(F(neg(delta))) ∉ W₁ means F(neg(delta)) ∉ GContent(W₁).
          -- This is consistent: F(neg(delta)) is in W₁ but G(F(neg(delta))) is not.
          --
          -- OK so we can't derive a contradiction from M' directly.
          -- Let me think more...
          --
          -- Actually, we have shown that if CanonicalR(W₁, M) and G(neg(delta)) ∈ M, then M is reflexive.
          -- We've also shown V = M' has both G(delta) and neg(delta), so M' is not reflexive.
          -- And W₁ sees M' (CanonicalR(W₁, M')).
          --
          -- If W₁ ~ M (both directions), then by transitivity:
          -- CanonicalR(M, M') from CanonicalR(M, W₁) and CanonicalR(W₁, M'). We have h_R.
          -- CanonicalR(M', M)? From CanonicalR(M', W₁) and CanonicalR(W₁, M)?
          -- We need CanonicalR(M', W₁) for this.
          --
          -- Is CanonicalR(M', W₁)?
          -- M' = Lindenbaum({neg(delta)} ∪ GContent(W₁)).
          -- GContent(M') ⊆ W₁ would be needed.
          -- GContent(M') = {phi | G(phi) ∈ M'}.
          -- G(delta) ∈ M', so delta ∈ GContent(M').
          -- delta ∈ W₁? We established delta ∉ W₁ (since neg(delta) ∈ W₁).
          -- So delta ∈ GContent(M') but delta ∉ W₁. Hence ¬CanonicalR(M', W₁).
          --
          -- So ¬CanonicalR(M', W₁). This is fine, but doesn't give ¬CanonicalR(W₁, M) directly.
          --
          -- Wait, I think I need to re-examine. We have:
          -- - W₁ ~ M (assumption for contradiction)
          -- - ¬CanonicalR(M', W₁) (just shown)
          -- - CanonicalR(W₁, M') (h_R_W₁V with V = M')
          --
          -- This means [W₁] < [M'] strictly (since CanonicalR(W₁, M') and ¬CanonicalR(M', W₁)).
          -- And [M] = [W₁] (by W₁ ~ M).
          -- So [M] = [W₁] < [M'].
          --
          -- But we also have h_R : CanonicalR M M', so [M] ≤ [M']. Consistent.
          -- And h_not_R' : ¬CanonicalR M' M, so [M'] > [M]. Consistent.
          --
          -- So [M] = [W₁] < [M'] with both orderings correct.
          -- There's no direct contradiction in the quotient structure.
          --
          -- The contradiction must come from formula membership.
          --
          -- We have:
          -- - M reflexive (h_M_refl)
          -- - W₁ ~ M
          -- - M' not reflexive
          -- - CanonicalR(W₁, M')
          -- - ¬CanonicalR(M', W₁)
          --
          -- M' = Lindenbaum({neg(delta)} ∪ GContent(W₁))
          -- M' has G(delta) ∈ M' (from h_G_delta_M')
          --
          -- Since GContent(W₁) = GContent(M) (by W₁ ~ M and M reflexive)...
          -- Wait, is this true? Let me check.
          --
          -- W₁ ~ M means CanonicalR(W₁, M) and CanonicalR(M, W₁).
          -- GContent(M) ⊆ W₁ and GContent(W₁) ⊆ M.
          -- By Temporal 4: GContent(M) ⊆ GContent(W₁) and GContent(W₁) ⊆ GContent(M).
          -- So GContent(M) = GContent(W₁).
          --
          -- Therefore M' = Lindenbaum({neg(delta)} ∪ GContent(M)).
          --
          -- Now, M is reflexive, so GContent(M) ⊆ M.
          -- M has neg(delta) (since delta ∉ M by MCS).
          -- So {neg(delta)} ∪ GContent(M) ⊆ M.
          --
          -- M' is the Lindenbaum extension of a subset of M. Could M' = M?
          -- If {neg(delta)} ∪ GContent(M) ⊆ M and M is MCS, then M' could be M itself!
          -- Lindenbaum({neg(delta)} ∪ GContent(M)) = some MCS extending the set.
          -- M is an MCS extending the set (since M ⊇ {neg(delta)} ∪ GContent(M)).
          -- So Lindenbaum could choose M' = M.
          --
          -- If M' = M:
          -- - G(delta) ∈ M' means G(delta) ∈ M. But h_G_delta_M says G(delta) ∉ M. Contradiction!
          --
          -- So M' ≠ M. The Lindenbaum extension must produce a DIFFERENT MCS.
          -- But M is a valid extension of the seed. Lindenbaum just picks one.
          --
          -- Actually, Lindenbaum is not unique - it's an existential construction.
          -- The canonical_forward_F chooses one specific MCS.
          --
          -- The key insight: canonical_forward_F constructs a SPECIFIC MCS that realizes the
          -- witnessed formula. In this case, V = canonical_forward_F W₁ neg(delta).
          -- V is constructed to have neg(delta), which M' should have.
          --
          -- But h_eq : V = M' came from the linearity case split. It's possible V = M' by coincidence
          -- of the construction, but it requires V and M' to be the same set.
          --
          -- If V = M', then M' = canonical_forward_F W₁ neg(delta).
          -- This specific construction has neg(delta) ∈ M'.
          -- And G(delta) ∈ M' (from h_G_delta_M').
          --
          -- If also M' = M (from the above reasoning when M is reflexive), then:
          -- - neg(delta) ∈ M
          -- - G(delta) ∈ M
          -- But h_G_delta_M says G(delta) ∉ M. Contradiction!
          --
          -- So M ≠ M'. But wait, we derived that the seed for M' is ⊆ M, so M could be M'.
          -- The resolution: Lindenbaum doesn't have to return M even if M extends the seed.
          -- But canonical_forward_F specifically constructs an MCS with the witnessed formula.
          -- If M already has neg(delta) and extends GContent(W₁), could M be V?
          --
          -- V is defined as the Lindenbaum of the seed. Lindenbaum is an arbitrary choice.
          -- But V ≠ M because G(delta) ∈ M' = V but G(delta) ∉ M.
          --
          -- So: V ≠ M, hence M' ≠ M (since V = M').
          --
          -- Now, we've established:
          -- - M is reflexive
          -- - W₁ ~ M
          -- - M' ≠ M
          -- - [M] < [M'] strictly
          --
          -- For ¬CanonicalR(W₁, M):
          -- We assumed CanonicalR(W₁, M), leading to M reflexive.
          -- But M' ≠ M and G(delta) ∈ M' but G(delta) ∉ M doesn't directly contradict.
          --
          -- Hmm, I'm still stuck. Let me try one more approach.
          --
          -- Since W₁ ~ M and M' = V is the forward witness from W₁:
          -- M' is constructed from W₁'s GContent.
          -- GContent(W₁) = GContent(M) (since W₁ ~ M and M reflexive).
          -- So M' is the forward witness from M (via W₁).
          --
          -- Now, M is reflexive, so seriality from M gives an MCS M'' with CanonicalR(M, M'').
          -- By the structure, M'' could be M itself (reflexive case) or a different MCS.
          -- Since M is reflexive, GContent(M) ⊆ M, and M itself is a valid forward continuation.
          --
          -- But M' ≠ M, so M' is a DIFFERENT forward MCS from M.
          -- M' has G(delta) but M doesn't.
          --
          -- For W₁ ~ M and CanonicalR(W₁, M'):
          -- By transitivity: CanonicalR(M, M'). We have this as h_R.
          -- CanonicalR(M', M)? We have ¬CanonicalR(M', M) as h_not_R'.
          --
          -- If W₁ ~ M and M' is "ahead" of W₁, is M' also "ahead" of M?
          -- [M] = [W₁] < [M'], so [M] < [M']. Yes.
          --
          -- Everything is consistent. The contradiction isn't in the quotient.
          --
          -- Actually wait, let me reconsider. The assumption is CanonicalR(W₁, M), meaning W₁ ~ M.
          -- I derived that M is reflexive.
          -- Then GContent(M) = GContent(W₁).
          -- M' = Lindenbaum({neg(delta)} ∪ GContent(W₁)) = Lindenbaum({neg(delta)} ∪ GContent(M)).
          --
          -- The seed is {neg(delta)} ∪ GContent(M).
          -- M has neg(delta) (since delta ∉ M) and GContent(M) ⊆ M (reflexive).
          -- So the seed ⊆ M.
          --
          -- If the seed ⊆ M and M is MCS, then M is a valid extension of the seed.
          -- Lindenbaum could return M, but it doesn't have to.
          --
          -- The canonical_forward_F returns the Lindenbaum of {psi} ∪ GContent(W₁) for some psi.
          -- Here psi = neg(delta).
          --
          -- The claim V = M' comes from h_eq : V = M'.
          -- This means the specific Lindenbaum extension chosen is M'.
          -- And G(delta) ∈ M' (given).
          --
          -- If the Lindenbaum could have returned M, then M would satisfy G(delta) ∈ M.
          -- But G(delta) ∉ M. So M is NOT a valid Lindenbaum result here.
          --
          -- Wait, this is the key! Lindenbaum returns an MCS that CONTAINS the seed, but
          -- the MCS could have ADDITIONAL formulas beyond the seed.
          -- M contains the seed, so M could be the Lindenbaum result.
          -- But Lindenbaum might return a DIFFERENT MCS, namely M'.
          --
          -- The fact that G(delta) ∈ M' and G(delta) ∉ M means M' ≠ M.
          -- Both M and M' are MCSes extending the seed, but they differ.
          --
          -- Here's the key insight: since h_eq : V = M', the specific Lindenbaum extension
          -- chosen for canonical_forward_F is M'. This is not necessarily the same as M.
          --
          -- So we have:
          -- - Seed S = {neg(delta)} ∪ GContent(W₁) = {neg(delta)} ∪ GContent(M)
          -- - M ⊇ S, M is MCS
          -- - M' ⊇ S, M' is MCS (the Lindenbaum result)
          -- - M ≠ M' (since G(delta) ∈ M', G(delta) ∉ M)
          --
          -- Both M and M' are MCSes containing S. They're different MCSes.
          --
          -- Now, in the quotient:
          -- - [M] < [M'] (since CanonicalR(M, M') and ¬CanonicalR(M', M))
          -- - [W₁] = [M] (by assumption CanonicalR(W₁, M) and CanonicalR(M, W₁))
          --
          -- CanonicalR(W₁, M') is h_R_W₁V (with V = M').
          -- So W₁ sees M'.
          --
          -- By transitivity: M sees M' (CanonicalR(M, M')). We have h_R.
          --
          -- Now, G(delta) ∈ M' means delta ∈ GContent(M').
          -- If CanonicalR(M', M), then delta ∈ M. But delta ∉ M. So ¬CanonicalR(M', M). ✓ (h_not_R')
          -- If CanonicalR(M', W₁), then delta ∈ W₁.
          --   We have neg(delta) ∈ W₁ (from G(neg(delta)) ∈ M and CanonicalR(M, W₁)).
          --   If delta ∈ W₁, W₁ inconsistent. So delta ∉ W₁.
          --   Hence ¬CanonicalR(M', W₁).
          --
          -- So [M'] > [W₁] = [M], i.e., M' is strictly ahead of both W₁ and M.
          -- This is consistent with [M] = [W₁] < [M'].
          --
          -- The quotient structure is consistent. Where's the contradiction?
          --
          -- I've been assuming CanonicalR(W₁, M) and derived M is reflexive, W₁ ~ M, [M] < [M'].
          -- But I haven't found a formula-level contradiction.
          --
          -- Let me try a completely different approach: maybe the goal IS satisfiable and
          -- we can prove it directly without assuming for contradiction.
          --
          -- We want to show ¬CanonicalR(W₁, M), i.e., find phi with G(phi) ∈ W₁ and phi ∉ M.
          --
          -- What G-formulas are in W₁?
          -- W₁ = Lindenbaum({F(neg(delta))} ∪ GContent(M)).
          -- By Temporal 4, all G-formulas from M propagate: if G(psi) ∈ M, then G(psi) ∈ W₁.
          -- Lindenbaum might add more G-formulas.
          --
          -- One candidate: G(F(neg(delta))). Is this in W₁?
          -- G(F(neg(delta))) = "always, sometime neg(delta)".
          -- W₁ has F(neg(delta)). By Temporal 4 in W₁: if F(neg(delta)) ∈ W₁, is G(F(neg(delta))) added?
          -- Temporal 4 says G(psi) → G(G(psi)), not F(psi) → G(F(psi)).
          -- So we can't conclude G(F(neg(delta))) ∈ W₁ from F(neg(delta)) ∈ W₁.
          --
          -- Actually, in temporal logic, there might be an axiom F(psi) → G(F(psi)) for serial dense frames?
          -- Let me check... Hmm, I don't recall this being an axiom.
          --
          -- Without such an axiom, G(F(neg(delta))) might or might not be in W₁.
          --
          -- If G(F(neg(delta))) ∈ W₁:
          -- Is F(neg(delta)) ∈ M? Yes, h_F_neg_delta says so.
          -- So we'd need F(neg(delta)) ∉ M to get a contradiction. But F(neg(delta)) ∈ M.
          --
          -- So G(F(neg(delta))) doesn't give us the witness.
          --
          -- What about G(neg(delta))?
          -- We're in the sub-case where G(neg(delta)) ∈ M (h_G_neg_delta_M).
          -- By Temporal 4: G(G(neg(delta))) ∈ M, so G(neg(delta)) ∈ GContent(M) ⊆ W₁.
          -- So G(neg(delta)) ∈ W₁.
          -- Is neg(delta) ∈ M? Since delta ∉ M, neg(delta) ∈ M (by MCS).
          -- So G(neg(delta)) ∈ W₁ and neg(delta) ∈ M. Not a witness for ¬CanonicalR(W₁, M).
          --
          -- Hmm. All the G-formulas I can identify in W₁ are also satisfied in M.
          --
          -- The issue: W₁ ~ M might actually be CONSISTENT in this sub-case.
          -- If W₁ and M are in the same equivalence class, then CanonicalR(W₁, M) and we can't
          -- prove its negation.
          --
          -- This means the sorry might not be provable in this sub-case with the current structure.
          --
          -- But wait, the goal is to prove density_frame_condition_STRICT. If W₁ ~ M, then W₁ is
          -- NOT strictly between M and M'. It's in the same class as M.
          --
          -- The resolution: when W₁ ~ M, we need to find a DIFFERENT witness, not W₁.
          -- The current proof structure uses W₁ when V = M'. But if W₁ ~ M, W₁ is not the right witness.
          --
          -- In this case (V = M' and W₁ ~ M), we should use a different intermediate.
          -- But the current proof structure doesn't account for this.
          --
          -- This is why the well-founded iteration approach is mentioned in the plan.
          -- When the first attempt doesn't give a strict witness, we iterate.
          --
          -- For now, I'll leave this as sorry and document the issue.
          sorry
        · -- G(neg(delta)) ∉ M, so F(delta) ∈ M
          have h_F_delta_M : Formula.some_future delta ∈ M := by
            cases set_mcs_negation_complete h_mcs (Formula.all_future (Formula.neg delta)) with
            | inl h => exact absurd h h_G_neg_delta_M
            | inr h => exact h
          -- Now we have F(delta) ∈ M. Let's see if this helps.
          -- W₁ = Lindenbaum({F(neg(delta))} ∪ GContent(M)).
          -- F(delta) is not a G-formula, so it's not directly in the seed.
          -- But F(delta) might be in W₁ by the Lindenbaum extension.
          --
          -- Actually, F(delta) = neg(G(neg(delta))). Since G(neg(delta)) ∉ M:
          -- - The seed doesn't force G(neg(delta)) into W₁.
          -- - W₁ might have G(neg(delta)) or not.
          --
          -- If G(neg(delta)) ∈ W₁:
          -- - neg(delta) ∈ GContent(W₁) ⊆ V = M'.
          -- - But neg(delta) ∈ M' anyway (h_neg_delta_V with V = M').
          -- If G(neg(delta)) ∉ W₁:
          -- - F(delta) ∈ W₁ (by MCS).
          --
          -- So W₁ has either G(neg(delta)) or F(delta).
          --
          -- If G(neg(delta)) ∈ W₁ and CanonicalR(W₁, M):
          -- - neg(delta) ∈ GContent(W₁) ⊆ M.
          -- - But neg(delta) ∈ M anyway (since delta ∉ M). No new info.
          --
          -- If F(delta) ∈ W₁:
          -- - F(delta) = neg(G(neg(delta))), so G(neg(delta)) ∉ W₁.
          -- - Does this help?
          --
          -- Hmm, let me think about the V = M' case with F(delta) ∈ M.
          --
          -- V = M' = Lindenbaum({neg(delta)} ∪ GContent(W₁)).
          -- M' has G(delta) ∈ M' (given).
          -- M' has neg(delta) (seed).
          --
          -- If G(delta) ∈ M' and M' is the Lindenbaum of {neg(delta)} ∪ GContent(W₁):
          -- G(delta) was added by Lindenbaum (not in seed, since G(delta) ∉ GContent(W₁) would mean G(G(delta)) ∉ W₁).
          --
          -- Wait, is G(G(delta)) ∈ W₁?
          -- W₁ = Lindenbaum({F(neg(delta))} ∪ GContent(M)).
          -- G(delta) ∉ M (h_G_delta_M). So G(G(delta)) ∉ M (by contrapositive of Temporal 4? No, Temporal 4 says G → GG, not the converse).
          -- Actually, we can't conclude G(G(delta)) ∉ M just from G(delta) ∉ M.
          -- G(G(delta)) ∈ M would mean G(delta) ∈ GContent(M). And G(delta) ∈ M iff delta ∈ GContent(M)?
          -- No, G(delta) ∈ M directly, not via GContent.
          --
          -- Let me re-examine. G(delta) ∈ M means... wait, h_G_delta_M says G(delta) ∉ M.
          -- So delta ∈ GContent(M) is equivalent to G(delta) ∈ M, which is false.
          -- Hence delta ∉ GContent(M).
          --
          -- Does G(G(delta)) ∈ M? If so, G(delta) ∈ GContent(M), so G(delta) ∈ W₁.
          -- But we showed earlier G(delta) ∉ W₁ (else delta ∈ M' and neg(delta) ∈ M', contradiction).
          -- So G(G(delta)) ∉ M (else G(delta) ∈ GContent(M) ⊆ W₁).
          --
          -- Hence G(delta) ∉ GContent(M), so G(delta) ∉ GContent(W₁) (since GContent(M) ⊆ GContent(W₁)).
          -- So G(delta) ∉ seed of M'. G(delta) was added by Lindenbaum.
          --
          -- For Lindenbaum to add G(delta), F(neg(delta)) must not be derivable from the seed.
          -- Seed = {neg(delta)} ∪ GContent(W₁).
          -- Does GContent(W₁) contain something that derives F(neg(delta))?
          --
          -- If G(F(neg(delta))) ∈ W₁, then F(neg(delta)) ∈ GContent(W₁) ⊆ seed of M'.
          -- Then M' ⊇ {F(neg(delta))}, so F(neg(delta)) ∈ M'.
          -- F(neg(delta)) = neg(G(delta)). So neg(G(delta)) ∈ M'.
          -- But G(delta) ∈ M' (given). Contradiction with M' consistent.
          --
          -- So G(F(neg(delta))) ∉ W₁. Hence F(neg(delta)) ∉ GContent(W₁).
          --
          -- But F(neg(delta)) ∈ W₁ (seed). So F(neg(delta)) ∈ W₁ but G(F(neg(delta))) ∉ W₁.
          -- This means the G-formula of F(neg(delta)) is NOT in W₁.
          --
          -- Now, for ¬CanonicalR(W₁, M):
          -- We need phi with G(phi) ∈ W₁ and phi ∉ M.
          --
          -- The G-formulas in W₁:
          -- 1. All from GContent(M) (by Temporal 4 propagation)
          -- 2. Possibly others added by Lindenbaum
          --
          -- For (1): G(psi) ∈ W₁ where G(G(psi)) ∈ M. Then psi ∈ GContent(M).
          --   For such psi, is psi ∈ M?
          --   If M is reflexive, yes. If M is not reflexive, maybe not.
          --
          -- If M is NOT reflexive:
          -- There exists psi with G(psi) ∈ M and psi ∉ M.
          -- By Temporal 4: G(G(psi)) ∈ M, so G(psi) ∈ GContent(M) ⊆ W₁.
          -- So G(psi) ∈ W₁ and psi ∉ M. This is our witness!
          --
          -- So: if M is not reflexive, we can find a witness for ¬CanonicalR(W₁, M).
          --
          -- We derived earlier that if CanonicalR(W₁, M) and CanonicalR(M, W₁), then M is reflexive.
          -- Contrapositive: if M is not reflexive, then ¬CanonicalR(W₁, M) or ¬CanonicalR(M, W₁).
          -- We have CanonicalR(M, W₁) (h_R_MW₁), so if M is not reflexive, ¬CanonicalR(W₁, M).
          --
          -- Let me implement this case-split:
          by_cases h_M_refl' : CanonicalR M M
          · -- M is reflexive. Need a different argument.
            -- In this sub-case, we have G(neg(delta)) ∉ M and M reflexive.
            -- We still need ¬CanonicalR(W₁, M).
            -- With M reflexive and CanonicalR(W₁, M) assumption, we derived GContent(W₁) ⊆ GContent(M).
            -- Combined with GContent(M) ⊆ GContent(W₁) (Temporal 4), GContent(M) = GContent(W₁).
            -- So W₁ ~ M.
            -- But we need W₁ < M (strictly) for the density proof.
            -- This is the problematic case requiring iteration.
            sorry
          · -- M is not reflexive. But we proved h_M_refl : CanonicalR M M earlier!
            -- This is a contradiction with h_M_refl'.
            exact absurd h_M_refl h_M_refl'
      · -- ¬CanonicalR(M', W₁)
        -- V = M' and W₁ sees V, so W₁ sees M'.
        -- If CanonicalR(M', W₁), then GContent(M') ⊆ W₁.
        -- G(delta) ∈ M', so delta ∈ W₁.
        -- W₁ is constructed from {F(neg(delta))} ∪ GContent(M).
        -- We need to show delta ∉ W₁ or derive a contradiction.
        -- W₁ has F(neg(delta)) ∈ W₁. If delta ∈ W₁, is there a contradiction?
        -- F(neg(delta)) and delta can coexist in W₁ (F means future sees, delta is now).
        -- No immediate contradiction.
        --
        -- Alternative: we can get a forward witness U from W₁ for neg(delta).
        -- U has neg(delta) ∈ U. If also delta ∈ U (from GContent(M') ⊆ U via
        -- transitivity M' -> W₁ -> U), contradiction.
        -- But wait, we already did this - U is V, and V = M' in this case.
        -- So V = M' has neg(delta)? No wait, V has neg(delta), and V = M'.
        -- So M' has neg(delta)? Let's check.
        -- If V = M', then neg(delta) ∈ V = M'.
        -- But G(delta) ∈ M', so delta ∈ M' (by reflexivity if M' is reflexive...
        -- wait, we don't know M' is reflexive in this Case A branch).
        --
        -- Actually in Case A, we're in the G(delta) ∉ M case, which tells us
        -- nothing about M' reflexivity.
        --
        -- If V = M' and neg(delta) ∈ V, then neg(delta) ∈ M'.
        -- And G(delta) ∈ M' means delta ∈ GContent(M').
        -- For delta ∈ M' (the set, not GContent), we'd need M' reflexive.
        --
        -- Hmm, if M' is not reflexive, GContent(M') ⊄ M'.
        -- So there exists gamma with G(gamma) ∈ M' and gamma ∉ M'.
        -- We have G(delta) ∈ M'. Is delta ∈ M' or delta ∉ M'?
        -- If delta ∈ M' and neg(delta) ∈ M' (since V = M' and neg(delta) ∈ V),
        -- then M' is inconsistent. Contradiction with M' being MCS.
        --
        -- So we have: neg(delta) ∈ M' (from V = M' and neg(delta) ∈ V).
        -- And G(delta) ∈ M'. If M' is reflexive, delta ∈ M', contradiction.
        -- If M' is not reflexive, we can't conclude delta ∈ M'.
        --
        -- But wait, what we want to show is ¬CanonicalR(M', W₁).
        -- CanonicalR(M', W₁) means GContent(M') ⊆ W₁.
        -- delta ∈ GContent(M') (since G(delta) ∈ M').
        -- So if CanonicalR(M', W₁), then delta ∈ W₁.
        -- W₁ is {F(neg(delta))} ∪ GContent(M) extended to MCS.
        -- delta ∉ M (by distinguishing formula).
        -- Does delta ∈ GContent(M)? That would mean G(delta) ∈ M.
        -- But in Case A, G(delta) ∉ M!
        -- So delta ∉ GContent(M).
        -- W₁ = Lindenbaum({F(neg(delta))} ∪ GContent(M)).
        -- If delta were added, it would be by consistency extension.
        -- The question: is delta consistent with {F(neg(delta))} ∪ GContent(M)?
        -- F(neg(delta)) means "there exists a future where neg(delta) holds".
        -- delta being true now is consistent with that.
        -- GContent(M) = {phi | G(phi) ∈ M}. delta ∉ GContent(M).
        -- So {F(neg(delta))} ∪ GContent(M) doesn't force delta in.
        -- But it might be added by the Lindenbaum extension process.
        --
        -- Actually, the Lindenbaum extension adds formulas to make a maximal
        -- consistent set. It adds delta if and only if ¬delta is not derivable
        -- from the current set.
        --
        -- Can we show neg(delta) is derivable from {F(neg(delta))} ∪ GContent(M)?
        -- Not directly - F(neg(delta)) doesn't imply neg(delta).
        --
        -- Can we show delta is NOT added? I.e., neg(delta) is consistent with
        -- {F(neg(delta))} ∪ GContent(M)? That's plausible since we can extend
        -- to have neg(delta) now and F(neg(delta)) (there's a future where
        -- neg(delta) holds).
        --
        -- If neg(delta) is in W₁, then delta ∉ W₁ (by consistency).
        -- So we need: neg(delta) ∈ W₁.
        --
        -- Hmm, W₁ has F(neg(delta)) but not necessarily neg(delta).
        -- W₁ could have delta and F(neg(delta)) consistently.
        --
        -- This is getting quite involved. Let me use sorry for now.
        sorry

/-!
## Well-Founded Approach to Strict Density

The direct proof of strict density has many cases. An alternative approach uses
well-founded recursion: if the non-strict density gives a witness that's not
strictly between (either CanonicalR(W, M) or CanonicalR(M', W) holds), we iterate.

The measure that decreases is the cardinality of "candidate distinguishing formulas"
between M and M'. Each iteration either:
1. Returns a strict witness (success), OR
2. Consumes a candidate formula, reducing the measure

By Finset.strongInduction, this terminates.

TODO: Implement this approach if the direct proofs prove too difficult.
-/

/-!
## Helper: Irreflexive MCS has Strict Seriality Future

If M is not reflexive (¬CanonicalR M M), then the seriality witness W
satisfies ¬CanonicalR W M (strict future). This is because:
1. If ¬CanonicalR M M, then ∃ phi with G(phi) ∈ M and phi ∉ M
2. The seriality witness W ⊇ GContent(M), so phi ∈ W
3. By Temporal 4, G(phi) ∈ GContent(M) ⊆ W, so G(phi) ∈ W
4. Therefore phi ∈ GContent(W), but phi ∉ M
5. So GContent(W) ⊄ M, hence ¬CanonicalR W M
-/

/--
If M is not reflexive, then its seriality future W is strict: ¬CanonicalR W M.
-/
theorem irreflexive_mcs_has_strict_future
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_not_refl : ¬CanonicalR M M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ ¬CanonicalR W M := by
  -- Get the seriality witness
  obtain ⟨W, h_W_mcs, h_R_MW⟩ := mcs_has_strict_future M h_mcs
  refine ⟨W, h_W_mcs, h_R_MW, ?_⟩
  -- Show ¬CanonicalR W M using the irreflexivity witness
  rw [CanonicalR, Set.not_subset] at h_not_refl ⊢
  obtain ⟨phi, h_phi_GContent, h_phi_not_M⟩ := h_not_refl
  -- phi ∈ GContent(M), so G(phi) ∈ M
  -- By Temporal 4: G(phi) → G(G(phi)), so G(G(phi)) ∈ M
  -- Therefore G(phi) ∈ GContent(M) ⊆ W
  have h_T4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 phi)
  have h_GG_phi_M : Formula.all_future (Formula.all_future phi) ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T4) h_phi_GContent
  -- G(phi) ∈ GContent(M) ⊆ W
  have h_G_phi_W : Formula.all_future phi ∈ W := h_R_MW h_GG_phi_M
  -- phi ∈ GContent(W) because G(phi) ∈ W
  exact ⟨phi, h_G_phi_W, h_phi_not_M⟩

/--
The candidate distinguishing formulas between M and M': formulas phi where
G(phi) ∈ M' and phi ∉ M. This set characterizes "how different" M' is from M.

Note: For finiteness, in practice we'd intersect with anchor.subformulas,
but that requires importing Subformulas.lean.
-/
def candidateDistinguishing (M M' : Set Formula) : Set Formula :=
  { phi | Formula.all_future phi ∈ M' ∧ phi ∉ M }

/--
Strict density via well-founded iteration.

This version uses an anchor formula to bound the candidate set to a finite set,
then applies Finset.strongInduction.

Note: The implementation uses sorry for now. The full proof requires:
1. Define candidateFormulas as a Finset (using anchor.subformulas.toFinset.filter)
2. Show that each iteration either succeeds or reduces the candidate set
3. Use Finset.strongInductionOn to establish termination
-/
theorem density_frame_condition_strict_wf
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : ¬CanonicalR M' M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧
      CanonicalR M W ∧ CanonicalR W M' ∧
      ¬CanonicalR W M ∧ ¬CanonicalR M' W := by
  -- For now, delegate to the direct proof (which has sorries)
  exact density_frame_condition_strict M M' h_mcs h_mcs' h_R h_not_R'

end Bimodal.Metalogic.StagedConstruction
