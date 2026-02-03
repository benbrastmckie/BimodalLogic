import Bimodal.Metalogic.FDSM.Core
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.FMP.Closure
import Bimodal.Metalogic.Bundle.Construction
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
## Phase 2: Saturation Infrastructure

The following definitions implement the multi-history saturation construction:
- `unsatisfiedDiamonds`: Find diamond formulas needing witnesses
- `buildWitnessHistory`: Construct a witness history from a consistent witness set
- `saturation_step`: One round of adding all missing witnesses
-/

/-!
### Checking Diamond Satisfaction

Given a collection of histories, check which diamond formulas lack witnesses.
-/

/--
Check if a specific diamond formula (Diamond psi = neg(Box(neg psi))) has a witness
in the given set of histories at time t.

A witness exists if there is some history h' where psi holds at time t.
-/
def hasDiamondWitness (phi : Formula) (hists : Finset (FDSMHistory phi))
    (t : FDSMTime phi) (psi : Formula) (h_psi_clos : psi ∈ closure phi) : Prop :=
  ∃ h' ∈ hists, (h'.states t).models psi h_psi_clos

/--
A DecidablePred for hasDiamondWitness would require classical reasoning,
so we provide a noncomputable instance.
-/
noncomputable instance hasDiamondWitness_decidable (phi : Formula)
    (hists : Finset (FDSMHistory phi)) (t : FDSMTime phi)
    (psi : Formula) (h_psi_clos : psi ∈ closure phi) :
    Decidable (hasDiamondWitness phi hists t psi h_psi_clos) :=
  Classical.dec _

/--
For a given history h and time t, find all diamond formulas psi such that:
1. Diamond psi holds at h.states t (i.e., neg(Box(neg psi)) is in the world state)
2. No witness history exists in hists where psi holds at t

Returns a set of pairs (psi, h_psi_clos) representing unsatisfied diamond inner formulas.
-/
def unsatisfiedDiamondFormulas (phi : Formula) (hists : Finset (FDSMHistory phi))
    (h : FDSMHistory phi) (t : FDSMTime phi) :
    Set { psi : Formula // psi ∈ closure phi } :=
  { ⟨psi, h_psi_clos⟩ |
    -- Diamond psi is in the world state
    (Formula.neg (Formula.box (Formula.neg psi))) ∈ (h.states t).toSet ∧
    -- But no witness exists
    ¬hasDiamondWitness phi hists t psi h_psi_clos }

/-!
### Building Witness Histories

When a diamond formula Diamond psi lacks a witness, we build a new history
from the witness set using Lindenbaum extension and closure MCS projection.
-/

/--
Build a witness history for a diamond formula.

Given:
- An MCS M containing Diamond psi
- A proof that the witness set for psi is consistent

We construct a new FDSMHistory whose world state at time t contains psi.

The construction:
1. Extend the witness set to a full MCS using Lindenbaum
2. Project to a closure MCS
3. Build a constant FDSMHistory from the closure MCS
-/
noncomputable def buildWitnessHistory (phi : Formula) (M : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (psi : Formula)
    (h_diamond : Formula.neg (Formula.box (Formula.neg psi)) ∈ M) :
    FDSMHistory phi :=
  -- Step 1: The witness set is consistent (by witness_set_consistent)
  let W := witnessSet M psi
  -- Note: We need M to be the MCS that induced a closure MCS
  -- For the full construction, we use set_lindenbaum to extend W to an MCS
  -- Then project to closure MCS and build the history

  -- Since we need the witness set to be consistent to extend it,
  -- and witness_set_consistent proves this for SetMaximalConsistent M,
  -- we can safely use Lindenbaum
  have h_W_cons : SetConsistent W := witness_set_consistent M h_mcs psi h_diamond

  -- Step 2: Extend W to full MCS M'
  let M' := Bimodal.Metalogic.Bundle.lindenbaumMCS_set W h_W_cons
  let h_M'_mcs := Bimodal.Metalogic.Bundle.lindenbaumMCS_set_is_mcs W h_W_cons
  let h_W_sub_M' := Bimodal.Metalogic.Bundle.lindenbaumMCS_set_extends W h_W_cons

  -- Step 3: Project M' to closure MCS
  let S := mcs_projection phi M'
  let h_S_mcs : ClosureMaximalConsistent phi S := mcs_projection_is_closure_mcs phi M' h_M'_mcs

  -- Step 4: Build constant FDSM history from closure MCS
  fdsm_history_from_closure_mcs phi S h_S_mcs

/--
The witness history has psi in its world state at the origin time.

This follows from:
1. psi ∈ witnessSet M psi (by definition)
2. witnessSet M psi ⊆ M' (Lindenbaum extension)
3. psi ∈ closure phi ⇒ psi ∈ closureWithNeg phi
4. Therefore psi ∈ mcs_projection phi M' = S
5. By worldStateFromClosureMCS_models_iff, psi is modeled
-/
theorem buildWitnessHistory_models_psi (phi : Formula) (M : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (psi : Formula)
    (h_psi_clos : psi ∈ closure phi)
    (h_diamond : Formula.neg (Formula.box (Formula.neg psi)) ∈ M)
    (t : FDSMTime phi) :
    (buildWitnessHistory phi M h_mcs psi h_diamond).states t |>.models psi h_psi_clos := by
  -- Unfold buildWitnessHistory to expose the construction
  unfold buildWitnessHistory

  -- The witness set contains psi
  have h_psi_in_W : psi ∈ witnessSet M psi := psi_mem_witnessSet M psi

  -- Set up abbreviations for clarity
  set W := witnessSet M psi with hW_def
  have h_W_cons : SetConsistent W := witness_set_consistent M h_mcs psi h_diamond

  set M' := Bimodal.Metalogic.Bundle.lindenbaumMCS_set W h_W_cons with hM'_def
  have h_W_sub_M' := Bimodal.Metalogic.Bundle.lindenbaumMCS_set_extends W h_W_cons
  have h_M'_mcs := Bimodal.Metalogic.Bundle.lindenbaumMCS_set_is_mcs W h_W_cons

  -- psi ∈ W ⊆ M'
  have h_psi_in_M' : psi ∈ M' := h_W_sub_M' h_psi_in_W

  -- psi ∈ closure phi implies psi ∈ closureWithNeg phi
  have h_psi_closneg : psi ∈ closureWithNeg phi := closure_subset_closureWithNeg phi h_psi_clos

  -- psi ∈ M' and psi ∈ closureWithNeg implies psi ∈ mcs_projection phi M'
  set S := mcs_projection phi M' with hS_def
  have h_psi_in_S : psi ∈ S := mem_mcs_projection_of_mem_both phi M' psi h_psi_in_M' h_psi_closneg

  -- S is a closure MCS
  have h_S_mcs : ClosureMaximalConsistent phi S := mcs_projection_is_closure_mcs phi M' h_M'_mcs

  -- The history is constant, so states t = worldStateFromClosureMCS phi S h_S_mcs
  have h_states_eq : (fdsm_history_from_closure_mcs phi S h_S_mcs).states t =
      worldStateFromClosureMCS phi S h_S_mcs := fdsm_history_from_closure_mcs_states phi S h_S_mcs t

  -- Now convert the goal: we need to show the model property for the world state
  -- The goal after unfolding has the form involving the constructed S and h_S_mcs
  -- We use convert to handle the definitional equality
  convert (worldStateFromClosureMCS_models_iff phi S h_S_mcs psi h_psi_clos).mp h_psi_in_S using 1
  -- The states t should equal worldStateFromClosureMCS phi S h_S_mcs
  -- This follows from h_states_eq but we need to show it for the specific S
  rfl

/-!
### Saturation Step

One round of adding witness histories for all unsatisfied diamond formulas.
-/

/--
Specification of what it means for a history h' to be a valid witness addition
for some unsatisfied diamond formula in the current histories.
-/
def IsWitnessFor (phi : Formula) (hists : Finset (FDSMHistory phi))
    (t : FDSMTime phi) (h' : FDSMHistory phi) : Prop :=
  ∃ h ∈ hists, ∃ psi : Formula, ∃ h_psi_clos : psi ∈ closure phi,
    -- Diamond psi holds in h but no witness existed
    (Formula.neg (Formula.box (Formula.neg psi))) ∈ (h.states t).toSet ∧
    ¬hasDiamondWitness phi hists t psi h_psi_clos ∧
    -- h' witnesses psi
    (h'.states t).models psi h_psi_clos

/--
Noncomputable decidability for IsWitnessFor via classical logic.
-/
noncomputable instance IsWitnessFor_decidable (phi : Formula)
    (hists : Finset (FDSMHistory phi)) (t : FDSMTime phi) (h' : FDSMHistory phi) :
    Decidable (IsWitnessFor phi hists t h') :=
  Classical.dec _

/--
Full saturation step: union of the current histories with all new witness histories.

This is defined relative to a mapping from histories to their underlying MCS.
In the actual construction, this mapping comes from the FDSM construction.

The implementation uses Classical.dec to handle the decidability of the existential.
-/
noncomputable def saturation_step (phi : Formula)
    (hists : Finset (FDSMHistory phi))
    (t : FDSMTime phi) : Finset (FDSMHistory phi) :=
  -- Union of current histories with witnesses for all unsatisfied diamonds
  hists ∪ (Finset.univ.filter (fun h' => IsWitnessFor phi hists t h'))

/--
Saturation step is monotone: the original histories are preserved.
-/
theorem saturation_step_subset (phi : Formula)
    (hists : Finset (FDSMHistory phi))
    (t : FDSMTime phi) :
    hists ⊆ saturation_step phi hists t := by
  intro h hh
  simp only [saturation_step, Finset.mem_union]
  left
  exact hh

/--
Saturation step preserves nonemptiness.
-/
theorem saturation_step_nonempty (phi : Formula)
    (hists : Finset (FDSMHistory phi))
    (h_ne : hists.Nonempty)
    (t : FDSMTime phi) :
    (saturation_step phi hists t).Nonempty := by
  obtain ⟨h, hh⟩ := h_ne
  exact ⟨h, saturation_step_subset phi hists t hh⟩

/-!
## Summary

This module provides the modal saturation infrastructure:

1. **witnessSet**: Construction of witness sets for diamond formulas
2. **witness_set_consistent**: PROVEN - Consistency of witness sets using generalized_modal_k
3. **hasDiamondWitness**: Check if a diamond formula has a witness
4. **unsatisfiedDiamondFormulas**: Find diamond formulas needing witnesses
5. **buildWitnessHistory**: Construct a witness history from a consistent witness set
6. **buildWitnessHistory_models_psi**: PROVEN - The witness history contains psi
7. **saturation_step**: One round of adding all missing witnesses
8. **saturation_step_subset**: PROVEN - Monotonicity of saturation
9. **modal_backward_from_saturation**: Modal backward property (requires truth lemma completion)

**Completed Proofs (Phase 1 + Phase 2)**:
- `witness_set_consistent`: Uses generalized_modal_k to lift derivations from Gamma to Box Gamma,
  then applies MCS closure properties.
- `buildWitnessHistory_models_psi`: The witness history contains psi via Lindenbaum extension
  and worldStateFromClosureMCS_models_iff.
- `saturation_step_subset`: Monotonicity follows directly from union definition.

**Remaining Sorries**:
- `neg_box_iff_diamond_neg`: Classical equivalence between neg(Box psi) and Diamond(psi.neg)
- `modal_backward_from_saturation`: Requires truth lemma infrastructure for complete proof

**Next Steps (Phase 3-7)**:
- Phase 3: Implement fixed-point construction with termination proof
- Phase 4: Prove modal saturation property at fixed point
- Phase 5: Complete modal_backward_from_saturation
- Phase 6: Update Completeness.lean to use multi-history construction
- Phase 7: Verification and sorry audit
-/

end Bimodal.Metalogic.FDSM
