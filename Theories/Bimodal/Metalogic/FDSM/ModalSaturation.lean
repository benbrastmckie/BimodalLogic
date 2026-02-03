import Bimodal.Metalogic.FDSM.Core
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.FMP.Closure
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# Modal Saturation Construction for FDSM

This module implements the diamond witness construction for modal saturation.
The key insight is that modal_backward can be proven by contrapositive:

- **modal_backward**: If psi holds at ALL histories, then Box psi holds
- **Contrapositive**: If Box psi does NOT hold, then psi fails at SOME history

The modal saturation construction ensures that whenever Diamond psi holds
(i.e., neg (Box (neg psi))), there exists a witness history where psi holds.

## Key Definitions

- `diamond_formulas phi`: Diamond subformulas in closure
- `witness_set M psi`: The set {psi} ∪ {chi | Box chi ∈ M}
- `witness_set_consistent`: Consistency of witness sets
- `add_witness_history`: Adding a witness history for a diamond formula

## Why This Works

In a modally saturated FDSM:
- If Box psi is NOT in some history h at time t
- Then neg (Box psi) = Diamond (neg psi) IS in h at time t (by MCS completeness)
- By modal saturation, there exists h' where neg psi holds
- Contrapositive: if psi holds in ALL histories, Box psi must hold

## References

- Research report: specs/816_bmcs_temporal_modal_coherence_strengthening/reports/research-013.md
- Implementation plan: specs/816_bmcs_temporal_modal_coherence_strengthening/plans/implementation-003.md
-/

namespace Bimodal.Metalogic.FDSM

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.FMP

/-!
## Diamond Formulas in Closure

Identify diamond subformulas that need witnesses.
-/

/--
A formula is a diamond formula if it has the form neg (Box (neg psi)).
-/
def isDiamondFormula (f : Formula) : Prop :=
  ∃ psi : Formula, f = Formula.neg (Formula.box (Formula.neg psi))

/--
Extract the inner formula from a diamond formula.
-/
def diamondInner? (f : Formula) : Option Formula :=
  match f with
  | Formula.imp (Formula.box (Formula.imp psi Formula.bot)) Formula.bot =>
    some psi
  | _ => none

/-!
## Witness Set Construction

Given an MCS M and a formula psi, the witness set is the set of formulas
that must be true in a witness history for Diamond psi.
-/

/--
The witness set for a formula psi relative to an MCS M.

If Diamond psi holds in M (meaning neg (Box (neg psi)) ∈ M),
then the witness set contains:
- psi (the witnessed formula)
- All chi such that Box chi ∈ M (preserved necessities)
-/
def witnessSet (M : Set Formula) (psi : Formula) : Set Formula :=
  {psi} ∪ {chi | Formula.box chi ∈ M}

/--
psi is in the witness set.
-/
theorem psi_mem_witnessSet (M : Set Formula) (psi : Formula) :
    psi ∈ witnessSet M psi := by
  simp only [witnessSet, Set.mem_union, Set.mem_singleton_iff, true_or]

/--
If Box chi ∈ M, then chi is in the witness set.
-/
theorem box_in_M_implies_in_witnessSet (M : Set Formula) (psi chi : Formula)
    (h_box : Formula.box chi ∈ M) : chi ∈ witnessSet M psi := by
  simp only [witnessSet, Set.mem_union, Set.mem_setOf_eq]
  right
  exact h_box

/-!
## Witness Set Consistency

The key lemma: if M is an MCS containing Diamond psi, then the witness set is consistent.
-/

/--
The witness set for psi is consistent when M is an MCS containing Diamond psi.

**Proof Idea**:
By contrapositive. If witness_set M psi is inconsistent, then there exists a finite
subset L ⊆ witness_set M psi such that L ⊢ ⊥.

From L = {psi, chi_1, ..., chi_n} where Box chi_i ∈ M, we can derive:
- L ⊢ ⊥
- By deduction theorem on psi: {chi_1, ..., chi_n} ⊢ psi → ⊥ = neg psi
- By necessitation and K axiom: {Box chi_1, ..., Box chi_n} ⊢ Box (neg psi)
- Since all Box chi_i ∈ M, we have Box (neg psi) derivable from M
- But M contains neg (Box (neg psi)) = Diamond psi, contradicting consistency of M
-/
theorem witness_set_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula)
    (h_diamond : Formula.neg (Formula.box (Formula.neg psi)) ∈ M) :
    SetConsistent (witnessSet M psi) := by
  intro L h_L_sub h_incons

  -- Get the derivation from L to bot
  obtain ⟨d_bot⟩ := h_incons

  -- Key insight: if psi :: Gamma ⊢ ⊥ and Gamma comes from Box formulas in M,
  -- then Gamma ⊢ neg psi, and by generalized_modal_k: Box Gamma ⊢ Box(neg psi)
  -- Since Box Gamma ⊆ M, we get Box(neg psi) ∈ M, contradicting Diamond psi ∈ M

  by_cases h_psi_in_L : psi ∈ L
  · -- Case 2: L contains psi
    -- Let Gamma = L.filter (· ≠ psi)
    let Gamma := L.filter (· ≠ psi)

    -- Show Gamma ⊆ {chi | Box chi ∈ M}
    have h_Gamma_box : ∀ chi ∈ Gamma, Formula.box chi ∈ M := by
      intro chi h_chi
      have h_chi_L : chi ∈ L := List.mem_of_mem_filter h_chi
      have h_chi_witness := h_L_sub chi h_chi_L
      simp only [witnessSet, Set.mem_union, Set.mem_singleton_iff, Set.mem_setOf_eq] at h_chi_witness
      rcases h_chi_witness with h_eq | h_box
      · -- chi = psi, but chi ∈ Gamma means chi ≠ psi
        have h_filter := List.mem_filter.mp h_chi
        have h_ne : chi ≠ psi := by
          simp only [ne_eq, decide_eq_true_eq] at h_filter
          exact h_filter.2
        exact absurd h_eq h_ne
      · exact h_box

    -- L ⊆ psi :: Gamma
    have h_L_sub_psiGamma : L ⊆ psi :: Gamma := by
      intro chi h_chi
      by_cases h_eq : chi = psi
      · subst h_eq
        simp
      · simp only [List.mem_cons]
        right
        exact List.mem_filter.mpr ⟨h_chi, by simp [h_eq]⟩

    -- Weaken d_bot to psi :: Gamma
    have d_bot' : DerivationTree (psi :: Gamma) Formula.bot :=
      DerivationTree.weakening L (psi :: Gamma) Formula.bot d_bot h_L_sub_psiGamma

    -- By deduction theorem: Gamma ⊢ neg psi
    have d_neg_psi : DerivationTree Gamma (Formula.neg psi) :=
      deduction_theorem Gamma psi Formula.bot d_bot'

    -- By generalized_modal_k: Box Gamma ⊢ Box(neg psi)
    have d_box_neg_psi : DerivationTree (Context.map Formula.box Gamma) (Formula.box (Formula.neg psi)) :=
      Theorems.generalized_modal_k Gamma (Formula.neg psi) d_neg_psi

    -- All elements of Box Gamma are in M
    have h_box_Gamma_in_M : ∀ chi ∈ Context.map Formula.box Gamma, chi ∈ M := by
      intro chi h_chi
      rw [Context.mem_map_iff] at h_chi
      obtain ⟨phi, h_phi_mem, h_chi_eq⟩ := h_chi
      subst h_chi_eq
      exact h_Gamma_box phi h_phi_mem

    -- Since M is MCS and Box Gamma ⊆ M derives Box(neg psi), we have Box(neg psi) ∈ M
    have h_box_neg_psi_in_M : Formula.box (Formula.neg psi) ∈ M :=
      set_mcs_closed_under_derivation h_mcs (Context.map Formula.box Gamma) h_box_Gamma_in_M d_box_neg_psi

    -- But M also contains neg(Box(neg psi)) = Diamond psi
    -- This contradicts MCS consistency: M contains both X and neg X
    exact set_consistent_not_both h_mcs.1 (Formula.box (Formula.neg psi)) h_box_neg_psi_in_M h_diamond

  · -- Case 1: L doesn't contain psi
    -- Then L ⊆ {chi | Box chi ∈ M}
    have h_L_box : ∀ chi ∈ L, Formula.box chi ∈ M := by
      intro chi h_chi
      have h_chi_witness := h_L_sub chi h_chi
      simp only [witnessSet, Set.mem_union, Set.mem_singleton_iff, Set.mem_setOf_eq] at h_chi_witness
      rcases h_chi_witness with rfl | h_box
      · exact absurd h_chi h_psi_in_L
      · exact h_box

    -- L ⊢ ⊥, and all elements of L have their Box in M
    -- By generalized_modal_k: Box L ⊢ Box ⊥
    have d_box_bot : DerivationTree (Context.map Formula.box L) (Formula.box Formula.bot) :=
      Theorems.generalized_modal_k L Formula.bot d_bot

    -- All elements of Box L are in M
    have h_box_L_in_M : ∀ chi ∈ Context.map Formula.box L, chi ∈ M := by
      intro chi h_chi
      rw [Context.mem_map_iff] at h_chi
      obtain ⟨phi, h_phi_mem, h_chi_eq⟩ := h_chi
      subst h_chi_eq
      exact h_L_box phi h_phi_mem

    -- Since M is MCS and Box L ⊆ M derives Box ⊥, we have Box ⊥ ∈ M
    have h_box_bot_in_M : Formula.box Formula.bot ∈ M :=
      set_mcs_closed_under_derivation h_mcs (Context.map Formula.box L) h_box_L_in_M d_box_bot

    -- By T axiom: Box ⊥ → ⊥
    have d_t_axiom : ⊢ (Formula.box Formula.bot).imp Formula.bot :=
      DerivationTree.axiom [] _ (Axiom.modal_t Formula.bot)

    -- T axiom is in every MCS
    have h_t_in_M : (Formula.box Formula.bot).imp Formula.bot ∈ M :=
      set_mcs_closed_under_derivation h_mcs [] (fun _ h => by simp at h) d_t_axiom

    -- So ⊥ ∈ M (by MCS implication property)
    have h_bot_in_M : Formula.bot ∈ M :=
      set_mcs_implication_property h_mcs h_t_in_M h_box_bot_in_M

    -- But M is consistent, so ⊥ ∉ M - contradiction
    -- [⊥] ⊢ ⊥ via assumption
    have d_bot_from_bot : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption [Formula.bot] Formula.bot (by simp)

    exact h_mcs.1 [Formula.bot] (by intro chi hchi; simp at hchi; subst hchi; exact h_bot_in_M) ⟨d_bot_from_bot⟩

/-!
## Modal Backward from Saturation

The key theorem: in a modally saturated model, the modal backward direction holds.
This means: if psi holds at ALL histories, then the world state must contain Box psi.

**Why this matters**:
The single-history construction trivializes modal operators (Box psi = psi).
With proper multi-history saturation:
- If Box psi is NOT in the world state, then neg(Box psi) = Diamond(neg psi) IS in the world state
- By modal saturation, there exists a witness history where neg psi holds
- Contrapositive: if psi holds at ALL histories, then Box psi must be in the world state

**Proof Strategy**:
1. Contrapositive: assume Box psi ∉ h.states t
2. By MCS negation completeness: (Box psi).neg ∈ h.states t
3. Rewrite (Box psi).neg as Diamond (psi.neg) using neg_box_eq_diamond_neg
4. By modal saturation (M.modal_saturated): exists h' where psi.neg holds
5. But h_all says psi holds at ALL histories including h'
6. Contradiction: h' has both psi and psi.neg (via MCS consistency)

**Note**: This proof requires that the world states are MCS-derived, ensuring
negation completeness. The theorem is formulated for world states that come
from a closure MCS construction.
-/

/--
Key identity: neg(Box psi) = neg(Box(neg(neg psi))) = Diamond(neg psi)

More precisely: (Box psi).neg unfolds to (Box psi) → ⊥,
and Diamond chi = neg(Box(neg chi)).
So neg(Box psi) is equivalent to Diamond(neg psi) by double negation in classical logic.

Actually, this is NOT direct syntactic equality. We have:
- (Box psi).neg = (Box psi).imp bot = Diamond psi.neg is FALSE
- neg(Box psi) = Box psi → ⊥
- Diamond chi = neg(Box(neg chi)) = (Box(chi.neg)).neg

For the equivalence, we need:
- neg(Box psi) ∈ MCS iff Diamond(neg psi) ∈ MCS

This follows from classical logic:
- neg(Box psi) = neg(neg(neg(Box psi))) (DNE)
- neg(neg(neg(Box psi))) = neg(neg(Diamond(neg psi))) (definition of Diamond)
- neg(neg(Diamond(neg psi))) ↔ Diamond(neg psi) (DNE again)
-/
theorem neg_box_iff_diamond_neg (phi : Formula) (S : Set Formula)
    (h_mcs : SetMaximalConsistent S) (psi : Formula)
    (h_box_neg_in : (Formula.box psi).neg ∈ S)
    (h_psi_neg_clos : psi.neg ∈ closure phi)
    (h_diamond_clos : Formula.neg (Formula.box (Formula.neg (psi.neg))) ∈ closure phi) :
    Formula.neg (Formula.box (Formula.neg (psi.neg))) ∈ S := by
  -- (Box psi).neg = (Box psi) → ⊥
  -- We need: (Box (neg (neg psi))).neg ∈ S

  -- Key observation: Box psi ↔ Box (neg (neg psi)) by DNE in the box
  -- And (Box X).neg ∈ MCS iff Box X ∉ MCS (by negation completeness)

  -- From h_box_neg_in: (Box psi) → ⊥ ∈ S, so Box psi ∉ S

  -- We need to show: neg(Box(neg(neg psi))) ∈ S
  -- i.e., (Box (neg (neg psi))) → ⊥ ∈ S

  -- Since neg(neg psi) ↔ psi (provably equivalent in classical logic),
  -- Box (neg (neg psi)) ↔ Box psi
  -- So (Box (neg (neg psi))).neg ∈ S iff (Box psi).neg ∈ S

  -- For now, we use the fact that psi and neg(neg psi) are classically equivalent
  -- The derivation uses DNE and necessitation
  sorry

/--
Modal backward via contrapositive (for MCS-derived world states).

In a modally saturated FDSM where world states are MCS-derived:
If psi holds at ALL histories at time t, then Box psi ∈ (h.states t).toSet.

**Precondition**: The world state (h.states t) must be MCS-derived, meaning
it comes from a closure MCS construction that ensures negation completeness.
This is the case for FDSM models built via `fdsm_from_saturated_histories`.

**Proof** (by contrapositive):
1. Assume Box psi ∉ (h.states t).toSet
2. By MCS negation completeness: (Box psi).neg ∈ (h.states t).toSet
3. By classical equivalence: Diamond(psi.neg) ∈ (h.states t).toSet
4. By modal saturation: exists h' where psi.neg ∈ (h'.states t).toSet
5. But h_all says psi ∈ (h'.states t).toSet for ALL h'
6. Contradiction: MCS cannot contain both psi and psi.neg
-/
theorem modal_backward_from_saturation {phi : Formula}
    (M : FiniteDynamicalSystemModel phi)
    (h : FDSMHistory phi) (h_mem : h ∈ M.histories)
    (psi : Formula) (h_psi_clos : psi ∈ closure phi)
    (t : FDSMTime phi)
    (h_all : ∀ h' ∈ M.histories, (h'.states t).models psi h_psi_clos) :
    ∃ h_box_clos : Formula.box psi ∈ closure phi,
      (h.states t).models (Formula.box psi) h_box_clos := by
  -- This requires:
  -- 1. Box psi ∈ closure phi (closure property)
  -- 2. The world state is MCS-derived (for negation completeness)
  -- 3. The model has modal saturation (for witness existence)
  --
  -- The complete proof requires the full truth lemma infrastructure.
  -- For now, we acknowledge this sorry represents the key modal backward property
  -- that will be resolved when TruthLemma.lean is completed.
  sorry

/-!
## Saturation Fixed Point Construction (Phase 4)

Iteratively add witness histories until saturation.
-/

/--
Check if a model needs more witnesses (is not fully saturated).
Returns the first unsaturated diamond formula if one exists.
-/
noncomputable def needsWitness (phi : Formula) (histories : Finset (FDSMHistory phi))
    (t : FDSMTime phi) : Option (FDSMHistory phi × Formula) := by
  -- For each history h and each formula psi in closure,
  -- check if Diamond psi holds but no witness exists
  -- This is a finite check since histories and closure are finite
  exact none  -- Placeholder

/--
The maximum number of histories needed for saturation.
Bounded by 2^closureSize since each history is determined by world states
at finitely many times.
-/
def maxHistories (phi : Formula) : Nat :=
  2 ^ closureSize phi

/-!
## Summary

This module provides the modal saturation infrastructure:

1. **witnessSet**: Construction of witness sets for diamond formulas
2. **witness_set_consistent**: PROVEN - Consistency of witness sets using generalized_modal_k
3. **modal_backward_from_saturation**: Modal backward property (requires truth lemma completion)

**Completed Proofs**:
- `witness_set_consistent`: Uses generalized_modal_k to lift derivations from Gamma to Box Gamma,
  then applies MCS closure properties. The key insight is that if the witness set were inconsistent,
  we could derive Box(neg psi) in M, contradicting Diamond psi in M.

**Remaining Sorries**:
- `neg_box_iff_diamond_neg`: Classical equivalence between neg(Box psi) and Diamond(psi.neg)
- `modal_backward_from_saturation`: Requires truth lemma infrastructure for complete proof

**Why the remaining sorries exist**:
The `modal_backward_from_saturation` proof requires connecting:
1. World state membership (from MCS construction)
2. Model truth (from FDSM semantics)
3. Modal saturation (from model property)

This connection is established by the truth lemma in TruthLemma.lean.

**Next Steps**:
- Complete truth lemma cases in TruthLemma.lean
- Use truth lemma to complete modal_backward_from_saturation
- Update Completeness.lean to use multi-history construction
-/

end Bimodal.Metalogic.FDSM
