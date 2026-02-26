import Bimodal.Metalogic.Bundle.FMCS
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.Theorems.Combinators
import Mathlib.Logic.Encodable.Basic

/-!
# Dovetailing Temporal Chain Construction

This module builds an `FMCS Int` with temporal coherence properties,
proving `temporal_coherent_family_exists` as a THEOREM (replacing the axiom in
`TemporalCoherentConstruction.lean`).

## Construction Overview

Given a consistent context Gamma, we build an `FMCS Int` using an
interleaved dovetailing construction that enables cross-sign temporal propagation:

### Construction Order (Dovetailing)

The construction order alternates between positive and negative indices:
  M_0, M_1, M_{-1}, M_2, M_{-2}, M_3, M_{-3}, ...

This is encoded by:
- `dovetailIndex n` maps construction step n to time index
- `dovetailRank t` maps time index t back to construction step

### Seed Construction

At each step n (constructing M_t where t = dovetailIndex(n)):
- Base context (if t = 0)
- GContent(M_{t-1}) if t-1 was already constructed
- HContent(M_{t+1}) if t+1 was already constructed
- F-witness formulas via dovetailing enumeration
- P-witness formulas via dovetailing enumeration

### F/P Witness Enumeration

For forward_F (F psi in M_t → ∃ s > t, psi in M_s), we use dovetailing:
- Enumerate all (time, formula) pairs using Nat.unpair on step number
- When processing pair (s, psi) at step n with t = dovetailIndex(n) > s,
  if F(psi) ∈ M_s, include psi in seed_t

## Proven Properties

- `forward_G` for non-negative pairs: G phi in M_t → phi in M_{t'} for 0 ≤ t < t'
- `backward_H` for non-positive pairs: H phi in M_t → phi in M_{t'} for t' < t ≤ 0

## Technical Debt (2 sorries)

- `forward_F`: requires non-linear witness construction
- `backward_P`: requires non-linear witness construction

Previously 4 sorries; forward_G cross-sign and backward_H cross-sign were resolved
via cross-sign G/H propagation infrastructure in WitnessGraph.lean (Task 916).

The remaining 2 sorries cannot be resolved for this linear chain construction because
F-formulas do not persist through GContent seeds. Resolution requires a non-linear
construction such as omega-squared or witness-graph-guided chain. See
WitnessGraph.lean and Task 916 research reports for detailed analysis.

## Progress Over TemporalChain.lean

This module replaces the AXIOM `temporal_coherent_family_exists` with a THEOREM
(with sorry debt). An axiom is in the trusted kernel; a sorry'd theorem is not.
Additionally, this module provides the `past_temporal_witness_seed_consistent`
lemma which is a novel contribution needed for future backward_P proofs.

## References

- Task 843 plan v008, Phase 1 (interleaved chain approach)
- Prior work: TemporalChain.lean (4 sorries, no axiom replacement)
- Consistency lemma: temporal_witness_seed_consistent in TemporalCoherentConstruction.lean
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Dovetailing Index Functions

These functions encode the interleaved construction order:
  Step 0 → M_0
  Step 1 → M_1
  Step 2 → M_{-1}
  Step 3 → M_2
  Step 4 → M_{-2}
  ...

The pattern is:
- dovetailIndex 0 = 0
- dovetailIndex (2k+1) = k+1  (positive times)
- dovetailIndex (2k+2) = -(k+1) (negative times)
-/

/--
Map construction step (Nat) to time index (Int).

The construction order is: M_0, M_1, M_{-1}, M_2, M_{-2}, ...
- Step 0 → time 0
- Step 2k+1 → time k+1 (positive)
- Step 2k+2 → time -(k+1) (negative)
-/
def dovetailIndex : Nat → Int
| 0 => 0
| n + 1 =>
    if n % 2 = 0 then
      (n / 2 + 1 : Int)  -- n = 2k, so n+1 = 2k+1, result is k+1
    else
      -(n / 2 + 1 : Int) -- n = 2k+1, so n+1 = 2k+2, result is -(k+1)

/--
Map time index (Int) back to construction step (Nat).

This is the inverse of `dovetailIndex`:
- Time 0 → step 0
- Time k+1 (positive) → step 2k+1
- Time -(k+1) (negative) → step 2k+2
-/
def dovetailRank : Int → Nat
| (0 : Int) => 0
| (Int.ofNat (n + 1)) => 2 * n + 1  -- positive n+1 → step 2n+1
| (Int.negSucc n) => 2 * n + 2      -- -(n+1) → step 2n+2

/--
dovetailRank is a left inverse of dovetailIndex.

**Proof sketch**: By case analysis on n:
- n = 0: both sides are 0
- n = 2k+1 (step to positive k+1): rank(k+1) = 2*k + 1 = n
- n = 2k+2 (step to negative -(k+1)): rank(-(k+1)) = 2*k + 2 = n

**Technical note**: Verified computationally: `#eval (List.range 20).map (fun n => dovetailRank (dovetailIndex n) == n)`
The full proof requires careful handling of Int coercions between Int.ofNat and Int.negSucc patterns.
-/
theorem dovetailRank_dovetailIndex (n : Nat) : dovetailRank (dovetailIndex n) = n := by
  cases n with
  | zero => rfl
  | succ m =>
    simp only [dovetailIndex]
    split_ifs with h
    · -- m % 2 = 0, so dovetailIndex (m+1) = m/2 + 1
      simp only [dovetailRank]
      -- ↑m / 2 + 1 is Int.ofNat (m/2 + 1), so rank gives 2*(m/2) + 1
      conv_lhs => rw [show (↑m : Int) / 2 = ↑(m / 2) from Int.ofNat_ediv_ofNat]
      -- ↑(m/2) + 1 is Int.ofNat (m/2 + 1), and rank(n+1) = 2n + 1
      -- We need to show 2 * (m/2) + 1 = m + 1
      -- Since m % 2 = 0, m = 2 * (m/2), so 2*(m/2) + 1 = m + 1
      show 2 * (m / 2) + 1 = m + 1
      omega
    · -- m % 2 ≠ 0, so dovetailIndex (m+1) = -(m/2 + 1)
      simp only [dovetailRank]
      conv_lhs => rw [show (↑m : Int) / 2 = ↑(m / 2) from Int.ofNat_ediv_ofNat]
      -- -(↑(m/2) + 1) = Int.negSucc (m/2)
      have h_neg : (-(↑(m / 2) + 1 : Int)) = Int.negSucc (m / 2) := by
        simp only [Int.negSucc_eq]
      simp only [h_neg]
      -- rank(Int.negSucc n) = 2n + 2
      show 2 * (m / 2) + 2 = m + 1
      omega

/--
dovetailIndex is a left inverse of dovetailRank.

**Proof sketch**: By case analysis on t:
- t = 0: rank(0) = 0, index(0) = 0
- t = k+1 (positive): rank(k+1) = 2k+1, index(2k+1) = k+1
- t = -(k+1) (negative): rank(-(k+1)) = 2k+2, index(2k+2) = -(k+1)

**Technical note**: Verified computationally for the range of Int values tested.
-/
theorem dovetailIndex_dovetailRank (t : Int) : dovetailIndex (dovetailRank t) = t := by
  cases t with
  | ofNat n =>
    cases n with
    | zero => rfl
    | succ m => simp [dovetailRank, dovetailIndex]
  | negSucc n =>
    simp only [dovetailRank, dovetailIndex]
    -- (2 * n + 1) % 2 = 1 ≠ 0, so the else branch is taken
    have h_odd : ¬((2 * n + 1) % 2 = 0) := by omega
    simp only [h_odd, ↓reduceIte]
    -- Now goal: -(↑(2*n+1)/2 + 1) = Int.negSucc n
    -- First rewrite ↑(2*n+1) / 2 to ↑((2*n+1)/2)
    conv_lhs => rw [show (↑(2 * n + 1) : Int) / 2 = ↑((2 * n + 1) / 2) from Int.ofNat_ediv_ofNat]
    have h1 : (2 * n + 1) / 2 = n := by omega
    simp only [h1, Int.negSucc_eq]

/--
At step n > 0, exactly one of t-1 or t+1 has already been constructed.

This is the key property enabling the interleaved construction:
- For positive times t = k+1: t-1 = k was built at step 2(k-1)+1 or 0
- For negative times t = -(k+1): t+1 = -k was built at step 2(k-1)+2 or 0

**Sorry rationale**: This is a simple arithmetic fact about the dovetailing order.
Verified computationally for small cases. Full proof requires careful Int case analysis.
-/
theorem dovetail_neighbor_constructed (n : Nat) (hn : n > 0) :
    let t := dovetailIndex n
    (dovetailRank (t - 1) < n ∨ dovetailRank (t + 1) < n) := by
  match n with
  | 0 => omega
  | m + 1 =>
    simp only [dovetailIndex]
    split_ifs with h
    · -- Case: m % 2 = 0, so t = m / 2 + 1 (positive)
      left
      simp only [dovetailRank]
      conv_lhs => rw [show (↑m : Int) / 2 = ↑(m / 2) from Int.ofNat_ediv_ofNat]
      have h_simp : (↑(m / 2) : Int) + 1 - 1 = ↑(m / 2) := by omega
      simp only [h_simp]
      cases hm2 : m / 2 with
      | zero => omega
      | succ k =>
        -- ↑(k+1) = Int.ofNat (k+1), and the match on Int.ofNat n.succ gives 2*n+1
        -- Int.ofNat (k + 1) = Int.ofNat (k.succ) matches the second branch
        show 2 * k + 1 < m + 1
        have hm_ge : m ≥ 2 * (k + 1) := by
          have := Nat.div_mul_le_self m 2
          omega
        omega
    · -- Case: m % 2 ≠ 0, so t = -(m / 2 + 1) (negative)
      right
      simp only [dovetailRank]
      conv_lhs => rw [show (↑m : Int) / 2 = ↑(m / 2) from Int.ofNat_ediv_ofNat]
      -- The goal has -(↑(m/2) + 1) + 1 which equals -↑(m/2)
      have h_simp : (-(↑(m / 2) + 1 : Int) + 1) = -(↑(m / 2) : Int) := by omega
      simp only [h_simp]
      cases hm2 : m / 2 with
      | zero =>
        simp only [Int.ofNat_zero, neg_zero]
        omega
      | succ k =>
        have h_neg : (-(↑(k + 1) : Int)) = Int.negSucc k := by
          simp only [Int.negSucc_eq]
          omega
        simp only [h_neg]
        show 2 * k + 2 < m + 1
        have hm_ge : m ≥ 2 * (k + 1) := by
          have := Nat.div_mul_le_self m 2
          omega
        omega

/-!
## GContent and HContent Consistency

These are proved locally to avoid importing TemporalChain.lean.
-/

/-- GContent(M) is consistent when M is an MCS. -/
lemma dovetail_GContent_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (GContent M) := by
  intro L hL ⟨d⟩
  have hL_in_M : ∀ x ∈ L, x ∈ M := fun x hx => by
    have h_G : Formula.all_future x ∈ M := hL x hx
    have h_T := DerivationTree.axiom [] ((Formula.all_future x).imp x) (Axiom.temp_t_future x)
    exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G
  exact h_mcs.1 L hL_in_M ⟨d⟩

/-- HContent(M) is consistent when M is an MCS. -/
lemma dovetail_HContent_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (HContent M) := by
  intro L hL ⟨d⟩
  have hL_in_M : ∀ x ∈ L, x ∈ M := fun x hx => by
    have h_H : Formula.all_past x ∈ M := hL x hx
    have h_T := DerivationTree.axiom [] ((Formula.all_past x).imp x) (Axiom.temp_t_past x)
    exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H
  exact h_mcs.1 L hL_in_M ⟨d⟩

/-!
## GContent and HContent Monotonicity

These lemmas establish that GContent propagates along chains where each step
includes GContent of the previous step. The key ingredient is the 4-axiom:
G(phi) -> G(G(phi)), which ensures G(phi) is in GContent(M) whenever phi is.
-/

/--
GContent monotonicity: if GContent(M) ⊆ M', then GContent(M) ⊆ GContent(M').

**Proof**: Let phi ∈ GContent(M). Then G(phi) ∈ M.
By the 4-axiom (set_mcs_all_future_all_future): G(G(phi)) ∈ M.
So G(phi) ∈ GContent(M).
By hypothesis GContent(M) ⊆ M': G(phi) ∈ M'.
By definition of GContent: phi ∈ GContent(M').
-/
lemma GContent_mono (M M' : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_sub : GContent M ⊆ M') : GContent M ⊆ GContent M' := by
  intro phi h_phi
  -- phi ∈ GContent(M) means G(phi) ∈ M
  have h_G_phi : Formula.all_future phi ∈ M := h_phi
  -- By 4-axiom: G(G(phi)) ∈ M
  have h_GG_phi : Formula.all_future (Formula.all_future phi) ∈ M :=
    set_mcs_all_future_all_future h_mcs h_G_phi
  -- So G(phi) ∈ GContent(M)
  have h_G_phi_in_GContent : Formula.all_future phi ∈ GContent M := h_GG_phi
  -- By hypothesis: G(phi) ∈ M'
  exact h_sub h_G_phi_in_GContent

/--
HContent monotonicity: if HContent(M) ⊆ M', then HContent(M) ⊆ HContent(M').

Symmetric to GContent_mono, using the past 4-axiom (set_mcs_all_past_all_past).
-/
lemma HContent_mono (M M' : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_sub : HContent M ⊆ M') : HContent M ⊆ HContent M' := by
  intro phi h_phi
  have h_H_phi : Formula.all_past phi ∈ M := h_phi
  have h_HH_phi : Formula.all_past (Formula.all_past phi) ∈ M :=
    set_mcs_all_past_all_past h_mcs h_H_phi
  have h_H_phi_in_HContent : Formula.all_past phi ∈ HContent M := h_HH_phi
  exact h_sub h_H_phi_in_HContent

/--
GContent propagates along chains where each step includes GContent of the previous step.

If chain(0), chain(1), ... are MCSes with GContent(chain(n)) ⊆ chain(n+1) for all n,
then GContent(chain(m)) ⊆ chain(n) for all m < n.
-/
lemma GContent_path_propagates (chain : Nat → Set Formula)
    (h_mcs : ∀ n, SetMaximalConsistent (chain n))
    (h_seed : ∀ n, GContent (chain n) ⊆ chain (n + 1)) :
    ∀ m n, m < n → GContent (chain m) ⊆ chain n := by
  intro m n hmn
  induction hmn with
  | refl => exact h_seed m
  | step hmk ih => exact fun phi h => h_seed _ (GContent_mono _ _ (h_mcs m) ih h)

/--
HContent propagates along chains where each step includes HContent of the previous step.

Symmetric to GContent_path_propagates.
-/
lemma HContent_path_propagates (chain : Nat → Set Formula)
    (h_mcs : ∀ n, SetMaximalConsistent (chain n))
    (h_seed : ∀ n, HContent (chain n) ⊆ chain (n + 1)) :
    ∀ m n, m < n → HContent (chain m) ⊆ chain n := by
  intro m n hmn
  induction hmn with
  | refl => exact h_seed m
  | step hmk ih => exact fun phi h => h_seed _ (HContent_mono _ _ (h_mcs m) ih h)

/-!
## Past Temporal Witness Seed

The past analog of the forward temporal witness seed: {psi} union HContent(M).
Used for backward P-witness construction.
-/

/-- PastTemporalWitnessSeed for P(psi): {psi} union HContent(M). -/
def PastTemporalWitnessSeed (M : Set Formula) (psi : Formula) : Set Formula :=
  {psi} ∪ HContent M

/-- psi is in its own PastTemporalWitnessSeed. -/
lemma psi_mem_PastTemporalWitnessSeed (M : Set Formula) (psi : Formula) :
    psi ∈ PastTemporalWitnessSeed M psi :=
  Set.mem_union_left _ (Set.mem_singleton psi)

/-- HContent is a subset of PastTemporalWitnessSeed. -/
lemma HContent_subset_PastTemporalWitnessSeed (M : Set Formula) (psi : Formula) :
    HContent M ⊆ PastTemporalWitnessSeed M psi :=
  Set.subset_union_right

/--
Past temporal witness seed consistency: If P(psi) is in an MCS M, then
{psi} union HContent(M) is consistent.

This is the past analog of `temporal_witness_seed_consistent`.
-/
theorem past_temporal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_P : Formula.some_past psi ∈ M) :
    SetConsistent (PastTemporalWitnessSeed M psi) := by
  intro L hL_sub ⟨d⟩

  by_cases h_psi_in : psi ∈ L
  · -- Case: psi in L
    let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree (psi :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (h_perm x).symm)
    have d_neg : L_filt ⊢ Formula.neg psi :=
      deduction_theorem L_filt psi Formula.bot d_reord
    -- Get H chi in M for each chi in L_filt from HContent
    have h_H_filt_in_M : ∀ chi ∈ L_filt, Formula.all_past chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [PastTemporalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_hcontent
      · exact absurd h_eq h_ne
      · exact h_hcontent
    -- Apply generalized past K
    have d_H_neg : (Context.map Formula.all_past L_filt) ⊢ Formula.all_past (Formula.neg psi) :=
      Bimodal.Theorems.generalized_past_k L_filt (Formula.neg psi) d_neg
    -- All formulas in H(L_filt) are in M
    have h_H_context_in_M : ∀ phi ∈ Context.map Formula.all_past L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_H_filt_in_M chi h_chi_in
    -- By MCS closure, H(neg psi) in M
    have h_H_neg_in_M : Formula.all_past (Formula.neg psi) ∈ M :=
      set_mcs_closed_under_derivation h_mcs (Context.map Formula.all_past L_filt)
        h_H_context_in_M d_H_neg
    -- Contradiction: P psi = neg(H(neg psi)) is also in M
    have h_P_eq : Formula.some_past psi = Formula.neg (Formula.all_past (Formula.neg psi)) := rfl
    rw [h_P_eq] at h_P
    exact set_consistent_not_both h_mcs.1 (Formula.all_past (Formula.neg psi)) h_H_neg_in_M h_P
  · -- Case: psi not in L, so L subset HContent M subset M
    have h_L_in_M : ∀ chi ∈ L, chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [PastTemporalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_hcontent
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · have h_H_chi : Formula.all_past chi ∈ M := h_hcontent
        have h_T := DerivationTree.axiom [] ((Formula.all_past chi).imp chi) (Axiom.temp_t_past chi)
        exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H_chi
    exact h_mcs.1 L h_L_in_M ⟨d⟩

/-!
## Forward Temporal Witness Seed

The forward analog of `PastTemporalWitnessSeed`: {psi} ∪ GContent(M).
Used for forward F-witness construction.

Note: This is also defined in `TemporalCoherentConstruction.lean` as `TemporalWitnessSeed`.
We duplicate the definition and proof here to avoid a circular import
(TemporalCoherentConstruction imports DovetailingChain).
-/

/-- ForwardTemporalWitnessSeed for F(psi): {psi} union GContent(M). -/
def ForwardTemporalWitnessSeed (M : Set Formula) (psi : Formula) : Set Formula :=
  {psi} ∪ GContent M

/-- psi is in its own ForwardTemporalWitnessSeed. -/
lemma psi_mem_ForwardTemporalWitnessSeed (M : Set Formula) (psi : Formula) :
    psi ∈ ForwardTemporalWitnessSeed M psi :=
  Set.mem_union_left _ (Set.mem_singleton psi)

/-- GContent is a subset of ForwardTemporalWitnessSeed. -/
lemma GContent_subset_ForwardTemporalWitnessSeed (M : Set Formula) (psi : Formula) :
    GContent M ⊆ ForwardTemporalWitnessSeed M psi :=
  Set.subset_union_right

/--
Forward temporal witness seed consistency: If F(psi) is in an MCS M, then
{psi} union GContent(M) is consistent.

This is the forward analog of `past_temporal_witness_seed_consistent`.
The proof mirrors the past version, using G and F instead of H and P.

**Proof Strategy**:
Suppose {psi} ∪ GContent(M) is inconsistent.
Then there exist chi₁, ..., chi_n in GContent(M) such that {psi, chi₁, ..., chi_n} ⊢ ⊥.
By deduction: {chi₁, ..., chi_n} ⊢ ¬psi.
By temporal K-distribution: G{chi₁, ..., chi_n} ⊢ G(¬psi).
Since G chi_i ∈ M for all i, by MCS closure: G(¬psi) ∈ M.
But F(psi) = ¬G(¬psi) ∈ M by hypothesis.
Contradiction.
-/
theorem forward_temporal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    SetConsistent (ForwardTemporalWitnessSeed M psi) := by
  intro L hL_sub ⟨d⟩

  by_cases h_psi_in : psi ∈ L
  · -- Case: psi ∈ L
    let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree (psi :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (h_perm x).symm)

    have d_neg : L_filt ⊢ Formula.neg psi :=
      deduction_theorem L_filt psi Formula.bot d_reord

    -- Get G chi ∈ M for each chi ∈ L_filt from GContent
    have h_G_filt_in_M : ∀ chi ∈ L_filt, Formula.all_future chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [ForwardTemporalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_gcontent
      · exact absurd h_eq h_ne
      · exact h_gcontent

    -- Apply generalized temporal K (G distributes over derivation)
    have d_G_neg : (Context.map Formula.all_future L_filt) ⊢ Formula.all_future (Formula.neg psi) :=
      Bimodal.Theorems.generalized_temporal_k L_filt (Formula.neg psi) d_neg

    -- All formulas in G(L_filt) are in M
    have h_G_context_in_M : ∀ phi ∈ Context.map Formula.all_future L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_G_filt_in_M chi h_chi_in

    -- By MCS closure under derivation, G(neg psi) ∈ M
    have h_G_neg_in_M : Formula.all_future (Formula.neg psi) ∈ M :=
      set_mcs_closed_under_derivation h_mcs (Context.map Formula.all_future L_filt)
        h_G_context_in_M d_G_neg

    -- Contradiction - F psi = neg(G(neg psi)) is also in M
    have h_F_eq : Formula.some_future psi = Formula.neg (Formula.all_future (Formula.neg psi)) := rfl
    rw [h_F_eq] at h_F
    exact set_consistent_not_both h_mcs.1 (Formula.all_future (Formula.neg psi)) h_G_neg_in_M h_F

  · -- Case: psi ∉ L, so L ⊆ GContent M ⊆ M
    have h_L_in_M : ∀ chi ∈ L, chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [ForwardTemporalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_gcontent
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · -- chi ∈ GContent means G chi ∈ M, and by T-axiom chi ∈ M
        have h_G_chi : Formula.all_future chi ∈ M := h_gcontent
        have h_T := DerivationTree.axiom [] ((Formula.all_future chi).imp chi) (Axiom.temp_t_future chi)
        exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G_chi

    exact h_mcs.1 L h_L_in_M ⟨d⟩

/-!
## Shared Base MCS

Both forward and backward chains share a single base MCS at time 0.
This enables cross-sign temporal propagation.
-/

/-- Build the shared base MCS that both chains emanate from. -/
noncomputable def sharedBaseMCS (base : Set Formula) (h_base_cons : SetConsistent base) :
    { M : Set Formula // SetMaximalConsistent M } :=
  let h := set_lindenbaum base h_base_cons
  ⟨Classical.choose h, (Classical.choose_spec h).2⟩

/-- The shared base MCS extends the base. -/
lemma sharedBaseMCS_extends (base : Set Formula) (h_base_cons : SetConsistent base) :
    base ⊆ (sharedBaseMCS base h_base_cons).val :=
  (Classical.choose_spec (set_lindenbaum base h_base_cons)).1

/-!
## Formula Enumeration (for witness placement)

Since `Formula` derives `Countable`, we obtain an `Encodable` instance via
`Encodable.ofCountable`. This provides the enumeration used by the witness
chain construction in `dovetailForwardChainMCS` and `dovetailBackwardChainMCS`.
-/

-- Classical decidability is needed for set membership checks in chain definitions
attribute [local instance] Classical.propDecidable

/-- Encodable instance for Formula, derived from the Countable instance. -/
noncomputable instance formulaEncodable : Encodable Formula := Encodable.ofCountable Formula

/-- Decode a natural number to a formula (if it's in the range of the encoding).
Returns `none` for natural numbers not corresponding to any formula. -/
noncomputable def decodeFormula (k : Nat) : Option Formula :=
  @Encodable.decode Formula formulaEncodable k

/-- Encode a formula to a natural number. -/
noncomputable def encodeFormula (phi : Formula) : Nat :=
  @Encodable.encode Formula formulaEncodable phi

/-- Surjectivity of formula encoding: decoding the encoding of a formula
recovers the original formula. -/
lemma decodeFormula_encodeFormula (psi : Formula) :
    decodeFormula (encodeFormula psi) = some psi := by
  simp only [decodeFormula, encodeFormula]
  exact Encodable.encodek psi

/-!
## Forward Chain Construction

Forward chain: step 0 is the shared base, step n+1 extends GContent(M_n).
GContent seeds ensure forward_G for non-negative indices.
-/

/-- Build the forward chain: step 0 is shared base, step n+1 extends GContent(M_n).
With witness placement: if F(psi_n) is alive at step n, then psi_n is placed in the seed
for step n+1 (via ForwardTemporalWitnessSeed). This enables the forward_F coverage argument. -/
noncomputable def dovetailForwardChainMCS (base : Set Formula) (h_base_cons : SetConsistent base) :
    Nat → { M : Set Formula // SetMaximalConsistent M }
  | 0 => sharedBaseMCS base h_base_cons
  | n + 1 =>
    let prev := dovetailForwardChainMCS base h_base_cons n
    match decodeFormula n with
    | none =>
      let h_gc := dovetail_GContent_consistent prev.val prev.property
      let h := set_lindenbaum (GContent prev.val) h_gc
      ⟨Classical.choose h, (Classical.choose_spec h).2⟩
    | some psi =>
      if h_F : Formula.some_future psi ∈ prev.val then
        let h_seed := forward_temporal_witness_seed_consistent prev.val prev.property psi h_F
        let h := set_lindenbaum (ForwardTemporalWitnessSeed prev.val psi) h_seed
        ⟨Classical.choose h, (Classical.choose_spec h).2⟩
      else
        let h_gc := dovetail_GContent_consistent prev.val prev.property
        let h := set_lindenbaum (GContent prev.val) h_gc
        ⟨Classical.choose h, (Classical.choose_spec h).2⟩

/-!
## Backward Chain Construction

Backward chain: step 0 is the shared base, step n+1 extends HContent(M_n).
HContent seeds ensure backward_H for non-positive indices.
-/

/-- Build the backward chain: step 0 is shared base, step n+1 extends HContent(M_n).
With witness placement: if P(psi_n) is alive at step n, then psi_n is placed in the seed
for step n+1 (via PastTemporalWitnessSeed). This enables the backward_P coverage argument. -/
noncomputable def dovetailBackwardChainMCS (base : Set Formula) (h_base_cons : SetConsistent base) :
    Nat → { M : Set Formula // SetMaximalConsistent M }
  | 0 => sharedBaseMCS base h_base_cons
  | n + 1 =>
    let prev := dovetailBackwardChainMCS base h_base_cons n
    match decodeFormula n with
    | none =>
      let h_hc := dovetail_HContent_consistent prev.val prev.property
      let h := set_lindenbaum (HContent prev.val) h_hc
      ⟨Classical.choose h, (Classical.choose_spec h).2⟩
    | some psi =>
      if h_P : Formula.some_past psi ∈ prev.val then
        let h_seed := past_temporal_witness_seed_consistent prev.val prev.property psi h_P
        let h := set_lindenbaum (PastTemporalWitnessSeed prev.val psi) h_seed
        ⟨Classical.choose h, (Classical.choose_spec h).2⟩
      else
        let h_hc := dovetail_HContent_consistent prev.val prev.property
        let h := set_lindenbaum (HContent prev.val) h_hc
        ⟨Classical.choose h, (Classical.choose_spec h).2⟩

/-- Forward and backward chains share the same MCS at index 0. -/
lemma chains_share_base (base : Set Formula) (h_base_cons : SetConsistent base) :
    (dovetailForwardChainMCS base h_base_cons 0).val =
    (dovetailBackwardChainMCS base h_base_cons 0).val := rfl

/-- Unified dovetail temporal chain: non-negative uses forward, negative uses backward. -/
noncomputable def dovetailChainSet (base : Set Formula) (h_base_cons : SetConsistent base)
    (t : Int) : Set Formula :=
  if _ : 0 ≤ t then
    (dovetailForwardChainMCS base h_base_cons t.toNat).val
  else
    (dovetailBackwardChainMCS base h_base_cons ((-t - 1).toNat)).val

/-!
## Basic Chain Properties
-/

lemma dovetailForwardChainMCS_is_mcs (base : Set Formula) (h_base_cons : SetConsistent base) (n : Nat) :
    SetMaximalConsistent (dovetailForwardChainMCS base h_base_cons n).val :=
  (dovetailForwardChainMCS base h_base_cons n).property

lemma dovetailBackwardChainMCS_is_mcs (base : Set Formula) (h_base_cons : SetConsistent base) (n : Nat) :
    SetMaximalConsistent (dovetailBackwardChainMCS base h_base_cons n).val :=
  (dovetailBackwardChainMCS base h_base_cons n).property

lemma dovetailChainSet_is_mcs (base : Set Formula) (h_base_cons : SetConsistent base) (t : Int) :
    SetMaximalConsistent (dovetailChainSet base h_base_cons t) := by
  simp only [dovetailChainSet]
  split
  · exact dovetailForwardChainMCS_is_mcs base h_base_cons t.toNat
  · exact dovetailBackwardChainMCS_is_mcs base h_base_cons ((-t - 1).toNat)

lemma dovetailForwardChainMCS_zero_extends (base : Set Formula) (h_base_cons : SetConsistent base) :
    base ⊆ (dovetailForwardChainMCS base h_base_cons 0).val := by
  simp only [dovetailForwardChainMCS]
  exact (Classical.choose_spec (set_lindenbaum base h_base_cons)).1

lemma dovetailBackwardChainMCS_zero_extends (base : Set Formula) (h_base_cons : SetConsistent base) :
    base ⊆ (dovetailBackwardChainMCS base h_base_cons 0).val := by
  simp only [dovetailBackwardChainMCS]
  exact (Classical.choose_spec (set_lindenbaum base h_base_cons)).1

/-!
## GContent Extension (Forward Chain)
-/

lemma dovetailForwardChainMCS_GContent_extends (base : Set Formula) (h_base_cons : SetConsistent base) (n : Nat) :
    GContent (dovetailForwardChainMCS base h_base_cons n).val ⊆
      (dovetailForwardChainMCS base h_base_cons (n + 1)).val := by
  intro phi h_phi
  show phi ∈ (dovetailForwardChainMCS base h_base_cons (n + 1)).val
  simp only [dovetailForwardChainMCS]
  cases h_dec : decodeFormula n with
  | none =>
    simp only [h_dec]
    exact (Classical.choose_spec (set_lindenbaum (GContent (dovetailForwardChainMCS base h_base_cons n).val)
      (dovetail_GContent_consistent _ (dovetailForwardChainMCS_is_mcs base h_base_cons n)))).1 h_phi
  | some psi =>
    simp only [h_dec]
    split_ifs with h_F
    · -- F(psi) ∈ prev: seed = {psi} ∪ GContent(prev), GContent(prev) ⊆ seed ⊆ extension
      have h_in_seed : phi ∈ ForwardTemporalWitnessSeed (dovetailForwardChainMCS base h_base_cons n).val psi :=
        GContent_subset_ForwardTemporalWitnessSeed _ _ h_phi
      exact (Classical.choose_spec (set_lindenbaum
        (ForwardTemporalWitnessSeed (dovetailForwardChainMCS base h_base_cons n).val psi)
        (forward_temporal_witness_seed_consistent _ (dovetailForwardChainMCS_is_mcs base h_base_cons n) psi h_F))).1 h_in_seed
    · -- F(psi) ∉ prev: just extend GContent
      exact (Classical.choose_spec (set_lindenbaum (GContent (dovetailForwardChainMCS base h_base_cons n).val)
        (dovetail_GContent_consistent _ (dovetailForwardChainMCS_is_mcs base h_base_cons n)))).1 h_phi

/-!
## HContent Extension (Backward Chain)
-/

lemma dovetailBackwardChainMCS_HContent_extends (base : Set Formula) (h_base_cons : SetConsistent base) (n : Nat) :
    HContent (dovetailBackwardChainMCS base h_base_cons n).val ⊆
      (dovetailBackwardChainMCS base h_base_cons (n + 1)).val := by
  intro phi h_phi
  show phi ∈ (dovetailBackwardChainMCS base h_base_cons (n + 1)).val
  simp only [dovetailBackwardChainMCS]
  cases h_dec : decodeFormula n with
  | none =>
    simp only [h_dec]
    exact (Classical.choose_spec (set_lindenbaum (HContent (dovetailBackwardChainMCS base h_base_cons n).val)
      (dovetail_HContent_consistent _ (dovetailBackwardChainMCS_is_mcs base h_base_cons n)))).1 h_phi
  | some psi =>
    simp only [h_dec]
    split_ifs with h_P
    · -- P(psi) ∈ prev: seed = {psi} ∪ HContent(prev), HContent(prev) ⊆ seed ⊆ extension
      have h_in_seed : phi ∈ PastTemporalWitnessSeed (dovetailBackwardChainMCS base h_base_cons n).val psi :=
        HContent_subset_PastTemporalWitnessSeed _ _ h_phi
      exact (Classical.choose_spec (set_lindenbaum
        (PastTemporalWitnessSeed (dovetailBackwardChainMCS base h_base_cons n).val psi)
        (past_temporal_witness_seed_consistent _ (dovetailBackwardChainMCS_is_mcs base h_base_cons n) psi h_P))).1 h_in_seed
    · -- P(psi) ∉ prev: just extend HContent
      exact (Classical.choose_spec (set_lindenbaum (HContent (dovetailBackwardChainMCS base h_base_cons n).val)
        (dovetail_HContent_consistent _ (dovetailBackwardChainMCS_is_mcs base h_base_cons n)))).1 h_phi

/-!
## GContent/HContent Duality Lemmas

Key insight: if GContent(M) ⊆ M' for MCSes M and M', then HContent(M') ⊆ M.
This uses axiom temp_a (φ → G(P(φ))) and its dual φ → H(F(φ)).

These lemmas enable cross-sign propagation: the backward chain has implicit
GContent propagation (toward 0), and the forward chain has implicit HContent
propagation (toward 0).
-/

/-- Past analog of axiom temp_a: ⊢ φ → H(F(φ)).
Derived from temp_a via temporal duality. -/
noncomputable def past_temp_a (psi : Formula) :
    [] ⊢ psi.imp psi.some_future.all_past := by
  have h_ta := DerivationTree.axiom [] _ (Axiom.temp_a psi.swap_past_future)
  have h_dual := DerivationTree.temporal_duality _ h_ta
  have h_eq : (psi.swap_past_future.imp psi.swap_past_future.sometime_past.all_future).swap_past_future
    = psi.imp psi.some_future.all_past := by
    simp [Formula.swap_temporal, Formula.neg, Formula.sometime_past, Formula.some_past,
          Formula.some_future, Formula.swap_past_future, Formula.swap_past_future_involution]
  rw [h_eq] at h_dual; exact h_dual

/-- If GContent(M) ⊆ M', then HContent(M') ⊆ M.
Uses temp_a: φ → G(P(φ)). -/
theorem GContent_subset_implies_HContent_reverse
    (M M' : Set Formula) (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_GC : GContent M ⊆ M') :
    HContent M' ⊆ M := by
  intro phi h_H_phi_in_M'
  by_contra h_not_phi
  have h_neg_phi : Formula.neg phi ∈ M := by
    rcases set_mcs_negation_complete h_mcs phi with h | h
    · exact absurd h h_not_phi
    · exact h
  have h_ta : [] ⊢ (Formula.neg phi).imp (Formula.all_future (Formula.neg phi).sometime_past) :=
    DerivationTree.axiom [] _ (Axiom.temp_a (Formula.neg phi))
  have h_G_P_neg : Formula.all_future (Formula.neg phi).sometime_past ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_ta) h_neg_phi
  have h_P_neg_M' : (Formula.neg phi).sometime_past ∈ M' := h_GC h_G_P_neg
  have h_dni : [] ⊢ phi.imp phi.neg.neg := Bimodal.Theorems.Combinators.dni phi
  have h_H_dni : [] ⊢ (phi.imp phi.neg.neg).all_past :=
    Bimodal.Theorems.past_necessitation _ h_dni
  have h_pk : [] ⊢ (phi.imp phi.neg.neg).all_past.imp (phi.all_past.imp phi.neg.neg.all_past) :=
    Bimodal.Theorems.past_k_dist phi phi.neg.neg
  have h_H_imp : [] ⊢ phi.all_past.imp phi.neg.neg.all_past :=
    DerivationTree.modus_ponens [] _ _ h_pk h_H_dni
  have h_H_nn : phi.neg.neg.all_past ∈ M' :=
    set_mcs_implication_property h_mcs' (theorem_in_mcs h_mcs' h_H_imp) h_H_phi_in_M'
  have h_eq : (Formula.neg phi).sometime_past = Formula.neg (phi.neg.neg.all_past) := rfl
  rw [h_eq] at h_P_neg_M'
  exact set_consistent_not_both h_mcs'.1 (phi.neg.neg.all_past) h_H_nn h_P_neg_M'

/-- If HContent(M) ⊆ M', then GContent(M') ⊆ M.
Uses past_temp_a: φ → H(F(φ)). -/
theorem HContent_subset_implies_GContent_reverse
    (M M' : Set Formula) (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_HC : HContent M ⊆ M') :
    GContent M' ⊆ M := by
  intro phi h_G_phi_in_M'
  have h_G_phi : Formula.all_future phi ∈ M' := h_G_phi_in_M'
  by_contra h_not_phi
  have h_neg_phi : Formula.neg phi ∈ M := by
    rcases set_mcs_negation_complete h_mcs phi with h | h
    · exact absurd h h_not_phi
    · exact h
  have h_pta : [] ⊢ (Formula.neg phi).imp (Formula.neg phi).some_future.all_past :=
    past_temp_a (Formula.neg phi)
  have h_H_F_neg : (Formula.neg phi).some_future.all_past ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_pta) h_neg_phi
  have h_F_neg_M' : (Formula.neg phi).some_future ∈ M' := h_HC h_H_F_neg
  have h_dni : [] ⊢ phi.imp phi.neg.neg := Bimodal.Theorems.Combinators.dni phi
  have h_G_dni : [] ⊢ (phi.imp phi.neg.neg).all_future :=
    DerivationTree.temporal_necessitation _ h_dni
  have h_fk : [] ⊢ (phi.imp phi.neg.neg).all_future.imp (phi.all_future.imp phi.neg.neg.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist phi phi.neg.neg)
  have h_G_imp : [] ⊢ phi.all_future.imp phi.neg.neg.all_future :=
    DerivationTree.modus_ponens [] _ _ h_fk h_G_dni
  have h_G_nn : phi.neg.neg.all_future ∈ M' :=
    set_mcs_implication_property h_mcs' (theorem_in_mcs h_mcs' h_G_imp) h_G_phi
  have h_eq : (Formula.neg phi).some_future = Formula.neg (phi.neg.neg.all_future) := rfl
  rw [h_eq] at h_F_neg_M'
  exact set_consistent_not_both h_mcs'.1 (phi.neg.neg.all_future) h_G_nn h_F_neg_M'

/-!
## Cross-Chain Content Propagation

The backward chain has implicit GContent propagation toward index 0,
and the forward chain has implicit HContent propagation toward index 0.
-/

/-- GContent of backward chain propagates toward 0 (decreasing index).
Since HContent(M_n) ⊆ M_{n+1} by construction, GContent(M_{n+1}) ⊆ M_n by duality. -/
lemma dovetailBackwardChainMCS_GContent_reverse (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) :
    GContent (dovetailBackwardChainMCS base h_base_cons (n + 1)).val ⊆
      (dovetailBackwardChainMCS base h_base_cons n).val :=
  HContent_subset_implies_GContent_reverse
    (dovetailBackwardChainMCS base h_base_cons n).val
    (dovetailBackwardChainMCS base h_base_cons (n + 1)).val
    (dovetailBackwardChainMCS_is_mcs base h_base_cons n)
    (dovetailBackwardChainMCS_is_mcs base h_base_cons (n + 1))
    (dovetailBackwardChainMCS_HContent_extends base h_base_cons n)

/-- HContent of forward chain propagates toward 0 (decreasing index).
Since GContent(M_n) ⊆ M_{n+1} by construction, HContent(M_{n+1}) ⊆ M_n by duality. -/
lemma dovetailForwardChainMCS_HContent_reverse (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) :
    HContent (dovetailForwardChainMCS base h_base_cons (n + 1)).val ⊆
      (dovetailForwardChainMCS base h_base_cons n).val :=
  GContent_subset_implies_HContent_reverse
    (dovetailForwardChainMCS base h_base_cons n).val
    (dovetailForwardChainMCS base h_base_cons (n + 1)).val
    (dovetailForwardChainMCS_is_mcs base h_base_cons n)
    (dovetailForwardChainMCS_is_mcs base h_base_cons (n + 1))
    (dovetailForwardChainMCS_GContent_extends base h_base_cons n)

/-!
## Forward G Coherence (Nat-indexed forward chain)
-/

lemma dovetailForwardChain_G_propagates (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (dovetailForwardChainMCS base h_base_cons n).val) :
    Formula.all_future phi ∈ (dovetailForwardChainMCS base h_base_cons (n + 1)).val := by
  have h_mcs_n := dovetailForwardChainMCS_is_mcs base h_base_cons n
  have h_GG := set_mcs_all_future_all_future h_mcs_n h_G
  exact dovetailForwardChainMCS_GContent_extends base h_base_cons n h_GG

lemma dovetailForwardChain_G_propagates_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (dovetailForwardChainMCS base h_base_cons m).val) :
    Formula.all_future phi ∈ (dovetailForwardChainMCS base h_base_cons n).val := by
  induction h_le with
  | refl => exact h_G
  | step _ ih => exact dovetailForwardChain_G_propagates base h_base_cons _ phi ih

lemma dovetailForwardChain_forward_G (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (dovetailForwardChainMCS base h_base_cons m).val) :
    phi ∈ (dovetailForwardChainMCS base h_base_cons n).val := by
  have h_G_n := dovetailForwardChain_G_propagates_le base h_base_cons m n (Nat.le_of_lt h_lt) phi h_G
  have h_mcs_n := dovetailForwardChainMCS_is_mcs base h_base_cons n
  have h_T := DerivationTree.axiom [] ((Formula.all_future phi).imp phi) (Axiom.temp_t_future phi)
  exact set_mcs_implication_property h_mcs_n (theorem_in_mcs h_mcs_n h_T) h_G_n

/-!
## Backward H Coherence (Nat-indexed backward chain)
-/

lemma dovetailBackwardChain_H_propagates (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (dovetailBackwardChainMCS base h_base_cons n).val) :
    Formula.all_past phi ∈ (dovetailBackwardChainMCS base h_base_cons (n + 1)).val := by
  have h_mcs_n := dovetailBackwardChainMCS_is_mcs base h_base_cons n
  have h_HH := set_mcs_all_past_all_past h_mcs_n h_H
  exact dovetailBackwardChainMCS_HContent_extends base h_base_cons n h_HH

lemma dovetailBackwardChain_H_propagates_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (dovetailBackwardChainMCS base h_base_cons m).val) :
    Formula.all_past phi ∈ (dovetailBackwardChainMCS base h_base_cons n).val := by
  induction h_le with
  | refl => exact h_H
  | step _ ih => exact dovetailBackwardChain_H_propagates base h_base_cons _ phi ih

lemma dovetailBackwardChain_backward_H (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (dovetailBackwardChainMCS base h_base_cons m).val) :
    phi ∈ (dovetailBackwardChainMCS base h_base_cons n).val := by
  have h_H_n := dovetailBackwardChain_H_propagates_le base h_base_cons m n (Nat.le_of_lt h_lt) phi h_H
  have h_mcs_n := dovetailBackwardChainMCS_is_mcs base h_base_cons n
  have h_T := DerivationTree.axiom [] ((Formula.all_past phi).imp phi) (Axiom.temp_t_past phi)
  exact set_mcs_implication_property h_mcs_n (theorem_in_mcs h_mcs_n h_T) h_H_n

/-!
## Backward Chain Forward G Coherence (toward 0)

By GContent/HContent duality, the backward chain also has GContent propagation
toward index 0. This enables cross-sign forward_G.
-/

/-- G propagates toward 0 in the backward chain (decreasing index). -/
lemma dovetailBackwardChain_G_propagates_reverse (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (dovetailBackwardChainMCS base h_base_cons (n + 1)).val) :
    Formula.all_future phi ∈ (dovetailBackwardChainMCS base h_base_cons n).val := by
  have h_mcs_n1 := dovetailBackwardChainMCS_is_mcs base h_base_cons (n + 1)
  have h_GG := set_mcs_all_future_all_future h_mcs_n1 h_G
  exact dovetailBackwardChainMCS_GContent_reverse base h_base_cons n h_GG

/-- G propagates toward 0: from index n to index m (m ≤ n) in the backward chain. -/
lemma dovetailBackwardChain_G_propagates_reverse_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (dovetailBackwardChainMCS base h_base_cons n).val) :
    Formula.all_future phi ∈ (dovetailBackwardChainMCS base h_base_cons m).val := by
  induction h_le with
  | refl => exact h_G
  | step h_le ih =>
    have := dovetailBackwardChain_G_propagates_reverse base h_base_cons _ phi h_G
    exact ih this

/-- forward_G in the backward chain: G phi in M_n implies phi in M_m for m < n. -/
lemma dovetailBackwardChain_forward_G (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (dovetailBackwardChainMCS base h_base_cons n).val) :
    phi ∈ (dovetailBackwardChainMCS base h_base_cons m).val := by
  have h_G_m := dovetailBackwardChain_G_propagates_reverse_le base h_base_cons m n (Nat.le_of_lt h_lt) phi h_G
  have h_mcs_m := dovetailBackwardChainMCS_is_mcs base h_base_cons m
  have h_T := DerivationTree.axiom [] ((Formula.all_future phi).imp phi) (Axiom.temp_t_future phi)
  exact set_mcs_implication_property h_mcs_m (theorem_in_mcs h_mcs_m h_T) h_G_m

/-!
## Forward Chain Backward H Coherence (toward 0)

By GContent/HContent duality, the forward chain also has HContent propagation
toward index 0. This enables cross-sign backward_H.
-/

/-- H propagates toward 0 in the forward chain (decreasing index). -/
lemma dovetailForwardChain_H_propagates_reverse (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (dovetailForwardChainMCS base h_base_cons (n + 1)).val) :
    Formula.all_past phi ∈ (dovetailForwardChainMCS base h_base_cons n).val := by
  have h_mcs_n1 := dovetailForwardChainMCS_is_mcs base h_base_cons (n + 1)
  have h_HH := set_mcs_all_past_all_past h_mcs_n1 h_H
  exact dovetailForwardChainMCS_HContent_reverse base h_base_cons n h_HH

/-- H propagates toward 0: from index n to index m (m ≤ n) in the forward chain. -/
lemma dovetailForwardChain_H_propagates_reverse_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (dovetailForwardChainMCS base h_base_cons n).val) :
    Formula.all_past phi ∈ (dovetailForwardChainMCS base h_base_cons m).val := by
  induction h_le with
  | refl => exact h_H
  | step h_le ih =>
    have := dovetailForwardChain_H_propagates_reverse base h_base_cons _ phi h_H
    exact ih this

/-- backward_H in the forward chain: H phi in M_n implies phi in M_m for m < n. -/
lemma dovetailForwardChain_backward_H (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (dovetailForwardChainMCS base h_base_cons n).val) :
    phi ∈ (dovetailForwardChainMCS base h_base_cons m).val := by
  have h_H_m := dovetailForwardChain_H_propagates_reverse_le base h_base_cons m n (Nat.le_of_lt h_lt) phi h_H
  have h_mcs_m := dovetailForwardChainMCS_is_mcs base h_base_cons m
  have h_T := DerivationTree.axiom [] ((Formula.all_past phi).imp phi) (Axiom.temp_t_past phi)
  exact set_mcs_implication_property h_mcs_m (theorem_in_mcs h_mcs_m h_T) h_H_m

/-!
## Int-indexed Coherence Proofs
-/

/-- forward_G for non-negative Int indices -/
lemma dovetailChainSet_forward_G_nonneg (base : Set Formula) (h_base_cons : SetConsistent base)
    (t t' : Int) (h_t_nn : 0 ≤ t) (h_t'_nn : 0 ≤ t') (h_lt : t < t')
    (phi : Formula) (h_G : Formula.all_future phi ∈ dovetailChainSet base h_base_cons t) :
    phi ∈ dovetailChainSet base h_base_cons t' := by
  simp only [dovetailChainSet, h_t_nn, h_t'_nn, ↓reduceDIte] at h_G ⊢
  have h_lt_nat : t.toNat < t'.toNat := by
    rw [← Int.ofNat_lt]
    rwa [Int.toNat_of_nonneg h_t_nn, Int.toNat_of_nonneg h_t'_nn]
  exact dovetailForwardChain_forward_G base h_base_cons t.toNat t'.toNat h_lt_nat phi h_G

/-- backward_H for non-positive Int indices -/
lemma dovetailChainSet_backward_H_nonpos (base : Set Formula) (h_base_cons : SetConsistent base)
    (t t' : Int) (h_t_neg : t < 0) (h_t'_neg : t' < 0) (h_lt : t' < t)
    (phi : Formula) (h_H : Formula.all_past phi ∈ dovetailChainSet base h_base_cons t) :
    phi ∈ dovetailChainSet base h_base_cons t' := by
  have h_t_not_nn : ¬(0 ≤ t) := not_le.mpr h_t_neg
  have h_t'_not_nn : ¬(0 ≤ t') := not_le.mpr h_t'_neg
  simp only [dovetailChainSet, h_t_not_nn, h_t'_not_nn, ↓reduceDIte] at h_H ⊢
  have h_idx_lt : (-t - 1).toNat < (-t' - 1).toNat := by
    rw [← Int.ofNat_lt]
    rw [Int.toNat_of_nonneg (by omega), Int.toNat_of_nonneg (by omega)]
    omega
  exact dovetailBackwardChain_backward_H base h_base_cons (-t - 1).toNat (-t' - 1).toNat h_idx_lt phi h_H

/-!
## Cross-Sign Coherence

forward_G for negative t (G phi in M_t where t < 0, need phi in M_{t'} where t' > t):
- Case t' < 0: both negative, use backward chain's forward_G (toward 0)
- Case t' = 0: backward chain forward_G to get phi in M_0 (shared base)
- Case t' > 0: bridge through M_0, then forward chain forward_G

backward_H for non-negative t (H phi in M_t where t >= 0, need phi in M_{t'} where t' < t):
- Case t' >= 0: both non-negative, use forward chain's backward_H (toward 0)
- Case t' < 0: bridge through M_0, then backward chain backward_H
-/

/-- forward_G for negative source: G phi in M_t (t < 0) implies phi in M_{t'} (t' > t). -/
lemma dovetailChainSet_forward_G_neg (base : Set Formula) (h_base_cons : SetConsistent base)
    (t t' : Int) (h_t_neg : t < 0) (h_lt : t < t')
    (phi : Formula) (h_G : Formula.all_future phi ∈ dovetailChainSet base h_base_cons t) :
    phi ∈ dovetailChainSet base h_base_cons t' := by
  have h_t_not_nn : ¬(0 ≤ t) := not_le.mpr h_t_neg
  -- G phi in backward chain at index (-t - 1)
  simp only [dovetailChainSet, h_t_not_nn, ↓reduceDIte] at h_G
  -- Step 1: Propagate G phi through backward chain to index 0 (= M_0)
  -- backward chain index: t maps to (-t-1).toNat
  -- M_0 is at backward chain index 0
  -- Need: G phi propagates from index (-t-1).toNat to index 0
  have h_G_at_0 : Formula.all_future phi ∈ (dovetailBackwardChainMCS base h_base_cons 0).val := by
    exact dovetailBackwardChain_G_propagates_reverse_le base h_base_cons 0 (-t - 1).toNat
      (Nat.zero_le _) phi h_G
  -- backward chain 0 = forward chain 0 = shared base
  have h_chain_eq : (dovetailBackwardChainMCS base h_base_cons 0).val =
      (dovetailForwardChainMCS base h_base_cons 0).val := chains_share_base base h_base_cons
  -- G phi at forward chain 0
  have h_G_fwd_0 : Formula.all_future phi ∈ (dovetailForwardChainMCS base h_base_cons 0).val := by
    rw [← h_chain_eq]; exact h_G_at_0
  -- Now branch on t'
  by_cases h_t'_nn : 0 ≤ t'
  · -- Case t' >= 0: use forward chain
    simp only [dovetailChainSet, h_t'_nn, ↓reduceDIte]
    by_cases h_t'_zero : t' = 0
    · -- t' = 0: apply T-axiom
      subst h_t'_zero
      have h_mcs := dovetailForwardChainMCS_is_mcs base h_base_cons 0
      have h_T := DerivationTree.axiom [] ((Formula.all_future phi).imp phi) (Axiom.temp_t_future phi)
      exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G_fwd_0
    · -- t' > 0: forward chain propagation
      have h_lt_nat : 0 < t'.toNat := by omega
      exact dovetailForwardChain_forward_G base h_base_cons 0 t'.toNat h_lt_nat phi h_G_fwd_0
  · -- Case t' < 0: both negative, use backward chain forward_G
    push_neg at h_t'_nn
    have h_t'_not_nn : ¬(0 ≤ t') := not_le.mpr h_t'_nn
    simp only [dovetailChainSet, h_t'_not_nn, ↓reduceDIte]
    have h_idx_lt : (-t' - 1).toNat < (-t - 1).toNat := by
      rw [← Int.ofNat_lt]
      rw [Int.toNat_of_nonneg (by omega), Int.toNat_of_nonneg (by omega)]
      omega
    exact dovetailBackwardChain_forward_G base h_base_cons (-t' - 1).toNat (-t - 1).toNat h_idx_lt phi h_G

/-- backward_H for non-negative source: H phi in M_t (t >= 0) implies phi in M_{t'} (t' < t). -/
lemma dovetailChainSet_backward_H_nonneg (base : Set Formula) (h_base_cons : SetConsistent base)
    (t t' : Int) (h_t_nn : 0 ≤ t) (h_lt : t' < t)
    (phi : Formula) (h_H : Formula.all_past phi ∈ dovetailChainSet base h_base_cons t) :
    phi ∈ dovetailChainSet base h_base_cons t' := by
  simp only [dovetailChainSet, h_t_nn, ↓reduceDIte] at h_H
  -- H phi in forward chain at index t.toNat
  -- Step 1: Propagate H phi through forward chain to index 0
  have h_H_at_0 : Formula.all_past phi ∈ (dovetailForwardChainMCS base h_base_cons 0).val := by
    exact dovetailForwardChain_H_propagates_reverse_le base h_base_cons 0 t.toNat
      (Nat.zero_le _) phi h_H
  -- forward chain 0 = backward chain 0
  have h_chain_eq : (dovetailForwardChainMCS base h_base_cons 0).val =
      (dovetailBackwardChainMCS base h_base_cons 0).val := (chains_share_base base h_base_cons).symm
  have h_H_bwd_0 : Formula.all_past phi ∈ (dovetailBackwardChainMCS base h_base_cons 0).val := by
    rw [← h_chain_eq]; exact h_H_at_0
  by_cases h_t'_neg : t' < 0
  · -- Case t' < 0: use backward chain
    have h_t'_not_nn : ¬(0 ≤ t') := not_le.mpr h_t'_neg
    simp only [dovetailChainSet, h_t'_not_nn, ↓reduceDIte]
    by_cases h_t'_m1 : t' = -1
    · -- t' = -1, backward index 0
      subst h_t'_m1; simp
      have h_mcs := dovetailBackwardChainMCS_is_mcs base h_base_cons 0
      have h_T := DerivationTree.axiom [] ((Formula.all_past phi).imp phi) (Axiom.temp_t_past phi)
      exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H_bwd_0
    · -- t' < -1, backward index > 0
      have h_lt_nat : 0 < (-t' - 1).toNat := by omega
      exact dovetailBackwardChain_backward_H base h_base_cons 0 (-t' - 1).toNat h_lt_nat phi h_H_bwd_0
  · -- Case t' >= 0: both non-negative, use forward chain backward_H
    push_neg at h_t'_neg
    simp only [dovetailChainSet, h_t'_neg, ↓reduceDIte]
    have h_lt_nat : t'.toNat < t.toNat := by
      rw [← Int.ofNat_lt]
      rwa [Int.toNat_of_nonneg h_t'_neg, Int.toNat_of_nonneg h_t_nn]
    exact dovetailForwardChain_backward_H base h_base_cons t'.toNat t.toNat h_lt_nat phi h_H

/-!
## Omega^2 Witness Chain Construction

The key construction for proving forward_F and backward_P.

At each Nat-indexed step n in the chain, we attempt to witness the n-th formula
(under the Encodable enumeration of Formula). If `F(psi_n) ∈ chain(n)`, we extend
`{psi_n} ∪ GContent(chain(n))` via Lindenbaum; otherwise we extend `GContent(chain(n))`.

### Formula Enumeration

Since `Formula` derives `Countable`, we obtain an `Encodable` instance via
`Encodable.ofCountable`. This provides:
- `decodeFormula k : Option Formula` - decode natural number k to a formula
- `encodeFormula phi : Nat` - encode a formula to a natural number
- `decodeFormula (encodeFormula phi) = some phi` - surjectivity

### Witness Chain Architecture

**Forward witness chain** (`witnessForwardChainMCS`):
- Step 0: Lindenbaum extension of the base set
- Step n+1: If `decodeFormula n = some psi` and `F(psi) ∈ chain(n)`:
  extend `{psi} ∪ GContent(chain(n))` (guaranteed consistent by
  `forward_temporal_witness_seed_consistent`)
  Otherwise: extend `GContent(chain(n))`

**Backward witness chain** (`witnessBackwardChainMCS`):
- Symmetric construction using `HContent` and `PastTemporalWitnessSeed`

### Key Properties

1. **GContent extension**: `GContent(chain(n)) ⊆ chain(n+1)` always holds,
   ensuring forward_G for the witness chain
2. **Witness placement**: When `F(psi) ∈ chain(n)` and `decode n = some psi`,
   then `psi ∈ chain(n+1)` (placed in the seed)
3. **Coverage**: Every formula psi has `decodeFormula (encodeFormula psi) = some psi`,
   so psi is processed at step `encodeFormula psi`. If `F(psi)` is still in the
   chain at that step, the witness is placed.

### Task 916 References

- Research: specs/916_implement_fp_witness_obligation_tracking/reports/research-003.md
- Plan: specs/916_implement_fp_witness_obligation_tracking/plans/implementation-003.md
- Core lemma: `forward_temporal_witness_seed_consistent` (defined in this file)
-/

/-! ### Forward Witness Chain -/

/--
Forward witness chain - alias for `dovetailForwardChainMCS` which now includes
temporal witness placement. Retained for backward compatibility with
Phase 1/2 lemma names.
-/
noncomputable def witnessForwardChainMCS (base : Set Formula) (h_base_cons : SetConsistent base) :
    Nat → { M : Set Formula // SetMaximalConsistent M } :=
  dovetailForwardChainMCS base h_base_cons

/-! ### Backward Witness Chain -/

/--
Backward witness chain - alias for `dovetailBackwardChainMCS` which now includes
past temporal witness placement. Retained for backward compatibility with
Phase 1/2 lemma names.
-/
noncomputable def witnessBackwardChainMCS (base : Set Formula) (h_base_cons : SetConsistent base) :
    Nat → { M : Set Formula // SetMaximalConsistent M } :=
  dovetailBackwardChainMCS base h_base_cons

/-! ### Basic Witness Chain Properties -/

/-- Every element of the forward witness chain is an MCS. -/
lemma witnessForwardChainMCS_is_mcs (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) :
    SetMaximalConsistent (witnessForwardChainMCS base h_base_cons n).val :=
  (witnessForwardChainMCS base h_base_cons n).property

/-- Every element of the backward witness chain is an MCS. -/
lemma witnessBackwardChainMCS_is_mcs (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) :
    SetMaximalConsistent (witnessBackwardChainMCS base h_base_cons n).val :=
  (witnessBackwardChainMCS base h_base_cons n).property

/-- The forward witness chain at step 0 extends the base set. -/
lemma witnessForwardChainMCS_zero_extends (base : Set Formula) (h_base_cons : SetConsistent base) :
    base ⊆ (witnessForwardChainMCS base h_base_cons 0).val := by
  simp only [witnessForwardChainMCS, dovetailForwardChainMCS]
  exact (Classical.choose_spec (set_lindenbaum base h_base_cons)).1

/-- The backward witness chain at step 0 extends the base set. -/
lemma witnessBackwardChainMCS_zero_extends (base : Set Formula) (h_base_cons : SetConsistent base) :
    base ⊆ (witnessBackwardChainMCS base h_base_cons 0).val := by
  simp only [witnessBackwardChainMCS, dovetailBackwardChainMCS]
  exact (Classical.choose_spec (set_lindenbaum base h_base_cons)).1

/-! ### GContent/HContent Extension -/

/-- GContent of each forward witness chain element extends to the next.
This ensures forward_G holds for the witness chain. -/
lemma witnessForwardChainMCS_GContent_extends (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) :
    GContent (witnessForwardChainMCS base h_base_cons n).val ⊆
      (witnessForwardChainMCS base h_base_cons (n + 1)).val := by
  intro phi h_phi
  simp only [witnessForwardChainMCS, dovetailForwardChainMCS]
  cases h_dec : decodeFormula n with
  | none =>
    simp only [h_dec]
    exact (Classical.choose_spec (set_lindenbaum (GContent (witnessForwardChainMCS base h_base_cons n).val)
      (dovetail_GContent_consistent _ (witnessForwardChainMCS base h_base_cons n).property))).1 h_phi
  | some psi =>
    simp only [h_dec]
    split_ifs with h_F
    · -- F(psi) ∈ prev: seed = {psi} ∪ GContent(prev), GContent(prev) ⊆ seed ⊆ extension
      have h_in_seed : phi ∈ ForwardTemporalWitnessSeed (witnessForwardChainMCS base h_base_cons n).val psi :=
        GContent_subset_ForwardTemporalWitnessSeed _ _ h_phi
      exact (Classical.choose_spec (set_lindenbaum
        (ForwardTemporalWitnessSeed (witnessForwardChainMCS base h_base_cons n).val psi)
        (forward_temporal_witness_seed_consistent _ (witnessForwardChainMCS base h_base_cons n).property psi h_F))).1 h_in_seed
    · -- F(psi) ∉ prev: just extend GContent
      exact (Classical.choose_spec (set_lindenbaum (GContent (witnessForwardChainMCS base h_base_cons n).val)
        (dovetail_GContent_consistent _ (witnessForwardChainMCS base h_base_cons n).property))).1 h_phi

/-- HContent of each backward witness chain element extends to the next.
This ensures backward_H holds for the witness chain. -/
lemma witnessBackwardChainMCS_HContent_extends (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) :
    HContent (witnessBackwardChainMCS base h_base_cons n).val ⊆
      (witnessBackwardChainMCS base h_base_cons (n + 1)).val := by
  intro phi h_phi
  simp only [witnessBackwardChainMCS, dovetailBackwardChainMCS]
  cases h_dec : decodeFormula n with
  | none =>
    simp only [h_dec]
    exact (Classical.choose_spec (set_lindenbaum (HContent (witnessBackwardChainMCS base h_base_cons n).val)
      (dovetail_HContent_consistent _ (witnessBackwardChainMCS base h_base_cons n).property))).1 h_phi
  | some psi =>
    simp only [] -- Instantiate the match on decodeFormula
    split_ifs with h_P
    · -- P(psi) ∈ prev: seed includes HContent
      have h_in_seed : phi ∈ PastTemporalWitnessSeed (witnessBackwardChainMCS base h_base_cons n).val psi :=
        HContent_subset_PastTemporalWitnessSeed _ _ h_phi
      exact (Classical.choose_spec (set_lindenbaum
        (PastTemporalWitnessSeed (witnessBackwardChainMCS base h_base_cons n).val psi)
        (past_temporal_witness_seed_consistent _ (witnessBackwardChainMCS base h_base_cons n).property psi h_P))).1 h_in_seed
    · -- P(psi) ∉ prev: just extend HContent
      exact (Classical.choose_spec (set_lindenbaum (HContent (witnessBackwardChainMCS base h_base_cons n).val)
        (dovetail_HContent_consistent _ (witnessBackwardChainMCS base h_base_cons n).property))).1 h_phi

/-! ### Witness Placement -/

/-- Forward witness placement: if `decodeFormula n = some psi` and
`F(psi) ∈ chain(n)`, then `psi ∈ chain(n+1)`.

This is the key property: when the n-th formula in the enumeration has its
F-obligation present in the chain at step n, the witness is placed in the
seed and therefore appears in the next MCS. -/
lemma witnessForwardChain_witness_placed (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (psi : Formula)
    (h_dec : decodeFormula n = some psi)
    (h_F : Formula.some_future psi ∈ (witnessForwardChainMCS base h_base_cons n).val) :
    psi ∈ (witnessForwardChainMCS base h_base_cons (n + 1)).val := by
  simp only [witnessForwardChainMCS, dovetailForwardChainMCS]
  simp only [h_dec]
  -- h_F mentions witnessForwardChainMCS which is dovetailForwardChainMCS; unfold for dite
  have h_F' : Formula.some_future psi ∈ (dovetailForwardChainMCS base h_base_cons n).val := h_F
  simp only [h_F', ↓reduceDIte]
  have h_in_seed : psi ∈ ForwardTemporalWitnessSeed (dovetailForwardChainMCS base h_base_cons n).val psi :=
    psi_mem_ForwardTemporalWitnessSeed _ _
  exact (Classical.choose_spec (set_lindenbaum
    (ForwardTemporalWitnessSeed (dovetailForwardChainMCS base h_base_cons n).val psi)
    (forward_temporal_witness_seed_consistent _ (dovetailForwardChainMCS_is_mcs base h_base_cons n) psi h_F'))).1 h_in_seed

/-- Backward witness placement: if `decodeFormula n = some psi` and
`P(psi) ∈ chain(n)`, then `psi ∈ chain(n+1)`. -/
lemma witnessBackwardChain_witness_placed (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (psi : Formula)
    (h_dec : decodeFormula n = some psi)
    (h_P : Formula.some_past psi ∈ (witnessBackwardChainMCS base h_base_cons n).val) :
    psi ∈ (witnessBackwardChainMCS base h_base_cons (n + 1)).val := by
  simp only [witnessBackwardChainMCS, dovetailBackwardChainMCS]
  simp only [h_dec]
  -- h_P mentions witnessBackwardChainMCS which is dovetailBackwardChainMCS; unfold for dite
  have h_P' : Formula.some_past psi ∈ (dovetailBackwardChainMCS base h_base_cons n).val := h_P
  simp only [h_P', ↓reduceDIte]
  have h_in_seed : psi ∈ PastTemporalWitnessSeed (dovetailBackwardChainMCS base h_base_cons n).val psi :=
    psi_mem_PastTemporalWitnessSeed _ _
  exact (Classical.choose_spec (set_lindenbaum
    (PastTemporalWitnessSeed (dovetailBackwardChainMCS base h_base_cons n).val psi)
    (past_temporal_witness_seed_consistent _ (dovetailBackwardChainMCS_is_mcs base h_base_cons n) psi h_P'))).1 h_in_seed

/-! ### Forward G Coherence for Witness Chain -/

/-- G propagates forward through the witness chain.
Since GContent(chain(n)) ⊆ chain(n+1), the 4-axiom G(phi) → G(G(phi))
ensures G(phi) ∈ chain(n) → G(phi) ∈ chain(n+1). -/
lemma witnessForwardChain_G_propagates (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (witnessForwardChainMCS base h_base_cons n).val) :
    Formula.all_future phi ∈ (witnessForwardChainMCS base h_base_cons (n + 1)).val := by
  have h_mcs_n := witnessForwardChainMCS_is_mcs base h_base_cons n
  have h_GG := set_mcs_all_future_all_future h_mcs_n h_G
  exact witnessForwardChainMCS_GContent_extends base h_base_cons n h_GG

/-- G propagates through multiple steps of the witness chain. -/
lemma witnessForwardChain_G_propagates_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (witnessForwardChainMCS base h_base_cons m).val) :
    Formula.all_future phi ∈ (witnessForwardChainMCS base h_base_cons n).val := by
  induction h_le with
  | refl => exact h_G
  | step _ ih => exact witnessForwardChain_G_propagates base h_base_cons _ phi ih

/-- forward_G for the witness chain: G(phi) at step m implies phi at step n for n > m. -/
lemma witnessForwardChain_forward_G (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (witnessForwardChainMCS base h_base_cons m).val) :
    phi ∈ (witnessForwardChainMCS base h_base_cons n).val := by
  have h_G_n := witnessForwardChain_G_propagates_le base h_base_cons m n (Nat.le_of_lt h_lt) phi h_G
  have h_mcs_n := witnessForwardChainMCS_is_mcs base h_base_cons n
  have h_T := DerivationTree.axiom [] ((Formula.all_future phi).imp phi) (Axiom.temp_t_future phi)
  exact set_mcs_implication_property h_mcs_n (theorem_in_mcs h_mcs_n h_T) h_G_n

/-! ### Backward H Coherence for Witness Chain -/

/-- H propagates forward through the backward witness chain. -/
lemma witnessBackwardChain_H_propagates (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (witnessBackwardChainMCS base h_base_cons n).val) :
    Formula.all_past phi ∈ (witnessBackwardChainMCS base h_base_cons (n + 1)).val := by
  have h_mcs_n := witnessBackwardChainMCS_is_mcs base h_base_cons n
  have h_HH := set_mcs_all_past_all_past h_mcs_n h_H
  exact witnessBackwardChainMCS_HContent_extends base h_base_cons n h_HH

/-- H propagates through multiple steps of the backward witness chain. -/
lemma witnessBackwardChain_H_propagates_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (witnessBackwardChainMCS base h_base_cons m).val) :
    Formula.all_past phi ∈ (witnessBackwardChainMCS base h_base_cons n).val := by
  induction h_le with
  | refl => exact h_H
  | step _ ih => exact witnessBackwardChain_H_propagates base h_base_cons _ phi ih

/-- backward_H for the backward witness chain: H(phi) at step m implies phi at step n for n > m. -/
lemma witnessBackwardChain_backward_H (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (witnessBackwardChainMCS base h_base_cons m).val) :
    phi ∈ (witnessBackwardChainMCS base h_base_cons n).val := by
  have h_H_n := witnessBackwardChain_H_propagates_le base h_base_cons m n (Nat.le_of_lt h_lt) phi h_H
  have h_mcs_n := witnessBackwardChainMCS_is_mcs base h_base_cons n
  have h_T := DerivationTree.axiom [] ((Formula.all_past phi).imp phi) (Axiom.temp_t_past phi)
  exact set_mcs_implication_property h_mcs_n (theorem_in_mcs h_mcs_n h_T) h_H_n

/-! ### Cross-Direction Duality for Witness Chains

By GContent/HContent duality (proven above), the backward witness chain also has
GContent propagation toward index 0, and the forward witness chain has HContent
propagation toward index 0. -/

/-- GContent of backward witness chain propagates toward 0 (decreasing index). -/
lemma witnessBackwardChainMCS_GContent_reverse (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) :
    GContent (witnessBackwardChainMCS base h_base_cons (n + 1)).val ⊆
      (witnessBackwardChainMCS base h_base_cons n).val :=
  HContent_subset_implies_GContent_reverse
    (witnessBackwardChainMCS base h_base_cons n).val
    (witnessBackwardChainMCS base h_base_cons (n + 1)).val
    (witnessBackwardChainMCS_is_mcs base h_base_cons n)
    (witnessBackwardChainMCS_is_mcs base h_base_cons (n + 1))
    (witnessBackwardChainMCS_HContent_extends base h_base_cons n)

/-- HContent of forward witness chain propagates toward 0 (decreasing index). -/
lemma witnessForwardChainMCS_HContent_reverse (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) :
    HContent (witnessForwardChainMCS base h_base_cons (n + 1)).val ⊆
      (witnessForwardChainMCS base h_base_cons n).val :=
  GContent_subset_implies_HContent_reverse
    (witnessForwardChainMCS base h_base_cons n).val
    (witnessForwardChainMCS base h_base_cons (n + 1)).val
    (witnessForwardChainMCS_is_mcs base h_base_cons n)
    (witnessForwardChainMCS_is_mcs base h_base_cons (n + 1))
    (witnessForwardChainMCS_GContent_extends base h_base_cons n)

/-! ### Inner Chain Properties (Phase 2)

Properties of the witness chains needed for the coverage argument (Phase 3).
These relate GContent monotonicity, base extension, and formula coverage. -/

/-- GContent is monotone through multiple steps of the forward witness chain.
If `m ≤ n`, then `GContent(chain(m)) ⊆ chain(n)`. This follows from
single-step GContent extension composed with the T-axiom. -/
lemma witnessForwardChainMCS_GContent_extends_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) :
    GContent (witnessForwardChainMCS base h_base_cons m).val ⊆
      (witnessForwardChainMCS base h_base_cons n).val := by
  intro phi h_phi
  -- phi ∈ GContent(chain(m)) means G(phi) ∈ chain(m)
  -- By forward_G for the witness chain, phi ∈ chain(n) for n > m
  -- But we need n ≥ m, so handle the equal case separately
  rcases Nat.eq_or_lt_of_le h_le with h_eq | h_lt
  · subst h_eq
    -- GContent(chain(m)) ⊆ chain(m) by T-axiom
    have h_mcs := witnessForwardChainMCS_is_mcs base h_base_cons m
    have h_G_phi : Formula.all_future phi ∈ (witnessForwardChainMCS base h_base_cons m).val := h_phi
    have h_T := DerivationTree.axiom [] ((Formula.all_future phi).imp phi) (Axiom.temp_t_future phi)
    exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G_phi
  · exact witnessForwardChain_forward_G base h_base_cons m n h_lt phi h_phi

/-- HContent is monotone through multiple steps of the backward witness chain. -/
lemma witnessBackwardChainMCS_HContent_extends_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) :
    HContent (witnessBackwardChainMCS base h_base_cons m).val ⊆
      (witnessBackwardChainMCS base h_base_cons n).val := by
  intro phi h_phi
  rcases Nat.eq_or_lt_of_le h_le with h_eq | h_lt
  · subst h_eq
    have h_mcs := witnessBackwardChainMCS_is_mcs base h_base_cons m
    have h_H_phi : Formula.all_past phi ∈ (witnessBackwardChainMCS base h_base_cons m).val := h_phi
    have h_T := DerivationTree.axiom [] ((Formula.all_past phi).imp phi) (Axiom.temp_t_past phi)
    exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H_phi
  · exact witnessBackwardChain_backward_H base h_base_cons m n h_lt phi h_phi

/-- Coverage property for the forward witness chain: if `F(psi)` is present
at the encoding index of `psi`, then `psi` enters the chain at the next step.

This is the key coverage lemma: it combines witness placement with encoding
surjectivity. For any formula `psi`, `encodeFormula psi` is the step at
which the chain checks for `F(psi)`. If `F(psi)` is present at that step,
`psi` is guaranteed to appear at step `encodeFormula psi + 1`. -/
lemma witnessForwardChain_coverage (base : Set Formula) (h_base_cons : SetConsistent base)
    (psi : Formula)
    (h_F : Formula.some_future psi ∈ (witnessForwardChainMCS base h_base_cons (encodeFormula psi)).val) :
    psi ∈ (witnessForwardChainMCS base h_base_cons (encodeFormula psi + 1)).val :=
  witnessForwardChain_witness_placed base h_base_cons (encodeFormula psi) psi
    (decodeFormula_encodeFormula psi) h_F

/-- Coverage property for the backward witness chain. -/
lemma witnessBackwardChain_coverage (base : Set Formula) (h_base_cons : SetConsistent base)
    (psi : Formula)
    (h_P : Formula.some_past psi ∈ (witnessBackwardChainMCS base h_base_cons (encodeFormula psi)).val) :
    psi ∈ (witnessBackwardChainMCS base h_base_cons (encodeFormula psi + 1)).val :=
  witnessBackwardChain_witness_placed base h_base_cons (encodeFormula psi) psi
    (decodeFormula_encodeFormula psi) h_P

/-- The forward witness chain at any step extends GContent of the base set's
Lindenbaum extension. That is, GContent(chain(0)) ⊆ chain(n) for all n.

This is an "extends base" property: the GContent of the initial MCS
propagates through all subsequent chain elements. -/
lemma witnessForwardChainMCS_extends_base_GContent (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) :
    GContent (witnessForwardChainMCS base h_base_cons 0).val ⊆
      (witnessForwardChainMCS base h_base_cons n).val :=
  witnessForwardChainMCS_GContent_extends_le base h_base_cons 0 n (Nat.zero_le n)

/-- The backward witness chain at any step extends HContent of the base set's
Lindenbaum extension. -/
lemma witnessBackwardChainMCS_extends_base_HContent (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) :
    HContent (witnessBackwardChainMCS base h_base_cons 0).val ⊆
      (witnessBackwardChainMCS base h_base_cons n).val :=
  witnessBackwardChainMCS_HContent_extends_le base h_base_cons 0 n (Nat.zero_le n)

/-- F-formula dichotomy in the forward witness chain: for any formula psi,
at any step n, either F(psi) is in the chain or its negation G(neg(psi)) is.

This follows from the fact that each chain element is an MCS, and
`F(psi) = neg(G(neg(psi)))`, so exactly one must hold. -/
lemma witnessForwardChain_F_dichotomy (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (psi : Formula) :
    Formula.some_future psi ∈ (witnessForwardChainMCS base h_base_cons n).val ∨
    Formula.all_future (Formula.neg psi) ∈ (witnessForwardChainMCS base h_base_cons n).val := by
  have h_mcs := witnessForwardChainMCS_is_mcs base h_base_cons n
  -- F(psi) = neg(G(neg(psi))), so by MCS negation completeness one must hold
  rcases set_mcs_negation_complete h_mcs (Formula.all_future (Formula.neg psi)) with h_G | h_neg_G
  · exact Or.inr h_G
  · -- neg(G(neg(psi))) = F(psi) ∈ chain(n)
    exact Or.inl h_neg_G

/-- P-formula dichotomy in the backward witness chain. -/
lemma witnessBackwardChain_P_dichotomy (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (psi : Formula) :
    Formula.some_past psi ∈ (witnessBackwardChainMCS base h_base_cons n).val ∨
    Formula.all_past (Formula.neg psi) ∈ (witnessBackwardChainMCS base h_base_cons n).val := by
  have h_mcs := witnessBackwardChainMCS_is_mcs base h_base_cons n
  rcases set_mcs_negation_complete h_mcs (Formula.all_past (Formula.neg psi)) with h_H | h_neg_H
  · exact Or.inr h_H
  · exact Or.inl h_neg_H

/-- If G(neg(psi)) enters the forward witness chain at step m,
it persists to all later steps. This is because G-formulas propagate
forward via the 4-axiom and GContent extension. -/
lemma witnessForwardChain_G_neg_persists (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (psi : Formula)
    (h_G : Formula.all_future (Formula.neg psi) ∈ (witnessForwardChainMCS base h_base_cons m).val) :
    Formula.all_future (Formula.neg psi) ∈ (witnessForwardChainMCS base h_base_cons n).val :=
  witnessForwardChain_G_propagates_le base h_base_cons m n h_le (Formula.neg psi) h_G

/-- If H(neg(psi)) enters the backward witness chain at step m,
it persists to all later steps. -/
lemma witnessBackwardChain_H_neg_persists (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (psi : Formula)
    (h_H : Formula.all_past (Formula.neg psi) ∈ (witnessBackwardChainMCS base h_base_cons m).val) :
    Formula.all_past (Formula.neg psi) ∈ (witnessBackwardChainMCS base h_base_cons n).val :=
  witnessBackwardChain_H_propagates_le base h_base_cons m n h_le (Formula.neg psi) h_H

/-- Key persistence lemma: If F(psi) is present at step 0 and G(neg(psi))
is NOT present at step n, then F(psi) is still present at step n.

This is the contrapositive of: if F(psi) dies (G(neg(psi)) enters),
G(neg(psi)) persists forever. So if G(neg(psi)) is absent at step n,
F(psi) must still be present. -/
lemma witnessForwardChain_F_persists_if_not_killed (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (psi : Formula)
    (h_not_G : Formula.all_future (Formula.neg psi) ∉ (witnessForwardChainMCS base h_base_cons n).val) :
    Formula.some_future psi ∈ (witnessForwardChainMCS base h_base_cons n).val := by
  rcases witnessForwardChain_F_dichotomy base h_base_cons n psi with h_F | h_G
  · exact h_F
  · exact absurd h_G h_not_G

/-- Key persistence lemma for backward chain. -/
lemma witnessBackwardChain_P_persists_if_not_killed (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (psi : Formula)
    (h_not_H : Formula.all_past (Formula.neg psi) ∉ (witnessBackwardChainMCS base h_base_cons n).val) :
    Formula.some_past psi ∈ (witnessBackwardChainMCS base h_base_cons n).val := by
  rcases witnessBackwardChain_P_dichotomy base h_base_cons n psi with h_P | h_H
  · exact h_P
  · exact absurd h_H h_not_H

/-- Forward F-persistence through chain: if F(psi) is at step 0 and
persists to step n (i.e., G(neg(psi)) never enters through step n),
then F(psi) is at step n.

Equivalent formulation: if F(psi) ∈ chain(0) and G(neg(psi)) ∉ chain(n),
then F(psi) ∈ chain(n). The hypothesis G(neg(psi)) ∉ chain(n) is sufficient
because if G(neg(psi)) entered at any step m ≤ n, it would persist to n
(by `witnessForwardChain_G_neg_persists`). -/
lemma witnessForwardChain_F_persists (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (psi : Formula)
    (_h_F_0 : Formula.some_future psi ∈ (witnessForwardChainMCS base h_base_cons 0).val)
    (h_not_killed : Formula.all_future (Formula.neg psi) ∉ (witnessForwardChainMCS base h_base_cons n).val) :
    Formula.some_future psi ∈ (witnessForwardChainMCS base h_base_cons n).val :=
  witnessForwardChain_F_persists_if_not_killed base h_base_cons n psi h_not_killed

/-- Backward P-persistence through chain. -/
lemma witnessBackwardChain_P_persists (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (psi : Formula)
    (_h_P_0 : Formula.some_past psi ∈ (witnessBackwardChainMCS base h_base_cons 0).val)
    (h_not_killed : Formula.all_past (Formula.neg psi) ∉ (witnessBackwardChainMCS base h_base_cons n).val) :
    Formula.some_past psi ∈ (witnessBackwardChainMCS base h_base_cons n).val :=
  witnessBackwardChain_P_persists_if_not_killed base h_base_cons n psi h_not_killed

/-- Contrapositive of G-persistence: if F(psi) is present at step n,
then G(neg(psi)) was absent at all steps m ≤ n.

This is crucial for the coverage argument: if F(psi) ∈ chain(n) and
k = encodeFormula(psi) with k ≤ n, then G(neg(psi)) ∉ chain(k),
so F(psi) ∈ chain(k) and the witness fires. -/
lemma witnessForwardChain_F_implies_G_neg_absent (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (psi : Formula)
    (h_F : Formula.some_future psi ∈ (witnessForwardChainMCS base h_base_cons n).val) :
    Formula.all_future (Formula.neg psi) ∉ (witnessForwardChainMCS base h_base_cons m).val := by
  intro h_G
  -- If G(neg(psi)) ∈ chain(m), it persists to chain(n)
  have h_G_n := witnessForwardChain_G_neg_persists base h_base_cons m n h_le psi h_G
  -- But F(psi) ∈ chain(n) and G(neg(psi)) ∈ chain(n) contradicts MCS consistency
  have h_mcs := witnessForwardChainMCS_is_mcs base h_base_cons n
  have h_F_eq : Formula.some_future psi = Formula.neg (Formula.all_future (Formula.neg psi)) := rfl
  rw [h_F_eq] at h_F
  exact set_consistent_not_both h_mcs.1 (Formula.all_future (Formula.neg psi)) h_G_n h_F

/-- Contrapositive for backward chain. -/
lemma witnessBackwardChain_P_implies_H_neg_absent (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (psi : Formula)
    (h_P : Formula.some_past psi ∈ (witnessBackwardChainMCS base h_base_cons n).val) :
    Formula.all_past (Formula.neg psi) ∉ (witnessBackwardChainMCS base h_base_cons m).val := by
  intro h_H
  have h_H_n := witnessBackwardChain_H_neg_persists base h_base_cons m n h_le psi h_H
  have h_mcs := witnessBackwardChainMCS_is_mcs base h_base_cons n
  have h_P_eq : Formula.some_past psi = Formula.neg (Formula.all_past (Formula.neg psi)) := rfl
  rw [h_P_eq] at h_P
  exact set_consistent_not_both h_mcs.1 (Formula.all_past (Formula.neg psi)) h_H_n h_P

/-- Coverage with persistence: if F(psi) is present at step n and n ≥ encodeFormula psi,
then psi is in the chain at step encodeFormula psi + 1.

This is the main coverage theorem for Phase 3: it handles the case where the
encoding index is at or before the current position. Since F(psi) ∈ chain(n)
implies G(neg(psi)) was never present at any earlier step (including encodeFormula psi),
F(psi) must be present at encodeFormula psi, so the witness fires. -/
lemma witnessForwardChain_coverage_of_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ (witnessForwardChainMCS base h_base_cons n).val)
    (h_le : encodeFormula psi ≤ n) :
    psi ∈ (witnessForwardChainMCS base h_base_cons (encodeFormula psi + 1)).val := by
  -- F(psi) ∈ chain(n) and encodeFormula psi ≤ n
  -- By contrapositive, G(neg(psi)) ∉ chain(encodeFormula psi)
  have h_G_absent := witnessForwardChain_F_implies_G_neg_absent base h_base_cons
    (encodeFormula psi) n h_le psi h_F
  -- So F(psi) ∈ chain(encodeFormula psi)
  have h_F_at_k := witnessForwardChain_F_persists_if_not_killed base h_base_cons
    (encodeFormula psi) psi h_G_absent
  -- And witness fires
  exact witnessForwardChain_coverage base h_base_cons psi h_F_at_k

/-- Coverage with persistence for backward chain. -/
lemma witnessBackwardChain_coverage_of_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (psi : Formula)
    (h_P : Formula.some_past psi ∈ (witnessBackwardChainMCS base h_base_cons n).val)
    (h_le : encodeFormula psi ≤ n) :
    psi ∈ (witnessBackwardChainMCS base h_base_cons (encodeFormula psi + 1)).val := by
  have h_H_absent := witnessBackwardChain_P_implies_H_neg_absent base h_base_cons
    (encodeFormula psi) n h_le psi h_P
  have h_P_at_k := witnessBackwardChain_P_persists_if_not_killed base h_base_cons
    (encodeFormula psi) psi h_H_absent
  exact witnessBackwardChain_coverage base h_base_cons psi h_P_at_k

/-!
## Derivation-Theoretic Structural Lemmas (Task 916, Phase 1)

Base structural facts about the relationship between GContent derivations,
G-formulas, and F-formulas in MCS. These block Routes 1 and 3 in the
derivation surgery approach for F-preserving seed consistency.

### Key Results

- `GContent_derives_neg_implies_G_neg_mem`: G-lifting for GContent derivations
- `FContent_blocks_GContent_derives_neg`: F(alpha) in MCS blocks GContent deriving neg(alpha)
- `F_in_MCS_implies_G_neg_not_theorem`: F(alpha) in MCS implies G(neg(alpha)) is not a theorem
-/

/--
If GContent(M) derives neg(alpha) (via some finite list L subset GContent(M)),
then G(neg(alpha)) is in M.

**Proof**: By G-lifting (generalized_temporal_k). Since each element chi of L
is in GContent(M), we have G(chi) in M. Applying generalized_temporal_k lifts
the derivation L ⊢ neg(alpha) to G(L) ⊢ G(neg(alpha)). Since all G(chi) in M,
by MCS closure under derivation, G(neg(alpha)) in M.
-/
theorem GContent_derives_neg_implies_G_neg_mem
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (alpha : Formula)
    (L : List Formula) (hL_sub : ∀ chi ∈ L, chi ∈ GContent M)
    (h_deriv : L ⊢ Formula.neg alpha) :
    Formula.all_future (Formula.neg alpha) ∈ M := by
  -- G-lift the derivation: L ⊢ neg(alpha) becomes G(L) ⊢ G(neg(alpha))
  have d_G : (Context.map Formula.all_future L) ⊢ Formula.all_future (Formula.neg alpha) :=
    Bimodal.Theorems.generalized_temporal_k L (Formula.neg alpha) h_deriv
  -- All elements of G(L) are in M: if chi in L, then chi in GContent(M), so G(chi) in M
  have h_G_in_M : ∀ phi ∈ Context.map Formula.all_future L, phi ∈ M := by
    intro phi h_mem
    rw [Context.mem_map_iff] at h_mem
    rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
    rw [← h_eq]
    exact hL_sub chi h_chi_in
  -- By MCS closure
  exact set_mcs_closed_under_derivation h_mcs (Context.map Formula.all_future L) h_G_in_M d_G

/--
If F(alpha) is in an MCS M, then GContent(M) does not derive neg(alpha).

**Proof**: Contrapositive of `GContent_derives_neg_implies_G_neg_mem`.
If GContent(M) derives neg(alpha), then G(neg(alpha)) in M. But
F(alpha) = neg(G(neg(alpha))) is also in M, contradicting MCS consistency.
-/
theorem FContent_blocks_GContent_derives_neg
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (alpha : Formula) (h_F : Formula.some_future alpha ∈ M) :
    ¬∃ (L : List Formula), (∀ chi ∈ L, chi ∈ GContent M) ∧ Nonempty (L ⊢ Formula.neg alpha) := by
  intro ⟨L, hL_sub, ⟨h_deriv⟩⟩
  -- By GContent_derives_neg_implies_G_neg_mem, G(neg(alpha)) in M
  have h_G_neg := GContent_derives_neg_implies_G_neg_mem M h_mcs alpha L hL_sub h_deriv
  -- But F(alpha) = neg(G(neg(alpha))) is also in M
  have h_F_eq : Formula.some_future alpha = Formula.neg (Formula.all_future (Formula.neg alpha)) := rfl
  rw [h_F_eq] at h_F
  exact set_consistent_not_both h_mcs.1 (Formula.all_future (Formula.neg alpha)) h_G_neg h_F

/--
If F(alpha) is in some MCS M, then G(neg(alpha)) is not a theorem
(i.e., not derivable from empty context).

**Proof**: If G(neg(alpha)) were a theorem, it would be in every MCS
(by `theorem_in_mcs`). But F(alpha) = neg(G(neg(alpha))) is also in M,
contradicting MCS consistency.

This blocks Route 3 (theorem route) in the derivation surgery argument.
-/
theorem F_in_MCS_implies_G_neg_not_theorem
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (alpha : Formula) (h_F : Formula.some_future alpha ∈ M) :
    ¬Nonempty ([] ⊢ Formula.all_future (Formula.neg alpha)) := by
  intro ⟨h_thm⟩
  -- If G(neg(alpha)) is a theorem, it's in M
  have h_G_neg_in_M : Formula.all_future (Formula.neg alpha) ∈ M :=
    theorem_in_mcs h_mcs h_thm
  -- But F(alpha) = neg(G(neg(alpha))) is also in M
  have h_F_eq : Formula.some_future alpha = Formula.neg (Formula.all_future (Formula.neg alpha)) := rfl
  rw [h_F_eq] at h_F
  exact set_consistent_not_both h_mcs.1 (Formula.all_future (Formula.neg alpha)) h_G_neg_in_M h_F

/--
Symmetric version for past: If P(alpha) is in some MCS M, then H(neg(alpha))
is not a theorem.
-/
theorem P_in_MCS_implies_H_neg_not_theorem
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (alpha : Formula) (h_P : Formula.some_past alpha ∈ M) :
    ¬Nonempty ([] ⊢ Formula.all_past (Formula.neg alpha)) := by
  intro ⟨h_thm⟩
  have h_H_neg_in_M : Formula.all_past (Formula.neg alpha) ∈ M :=
    theorem_in_mcs h_mcs h_thm
  have h_P_eq : Formula.some_past alpha = Formula.neg (Formula.all_past (Formula.neg alpha)) := rfl
  rw [h_P_eq] at h_P
  exact set_consistent_not_both h_mcs.1 (Formula.all_past (Formula.neg alpha)) h_H_neg_in_M h_P

/--
If HContent(M) derives neg(alpha) via some finite list L subset HContent(M),
then H(neg(alpha)) is in M. Past analog of `GContent_derives_neg_implies_G_neg_mem`.
-/
theorem HContent_derives_neg_implies_H_neg_mem
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (alpha : Formula)
    (L : List Formula) (hL_sub : ∀ chi ∈ L, chi ∈ HContent M)
    (h_deriv : L ⊢ Formula.neg alpha) :
    Formula.all_past (Formula.neg alpha) ∈ M := by
  have d_H : (Context.map Formula.all_past L) ⊢ Formula.all_past (Formula.neg alpha) :=
    Bimodal.Theorems.generalized_past_k L (Formula.neg alpha) h_deriv
  have h_H_in_M : ∀ phi ∈ Context.map Formula.all_past L, phi ∈ M := by
    intro phi h_mem
    rw [Context.mem_map_iff] at h_mem
    rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
    rw [← h_eq]
    exact hL_sub chi h_chi_in
  exact set_mcs_closed_under_derivation h_mcs (Context.map Formula.all_past L) h_H_in_M d_H

/--
If P(alpha) is in an MCS M, then HContent(M) does not derive neg(alpha).
Past analog of `FContent_blocks_GContent_derives_neg`.
-/
theorem PContent_blocks_HContent_derives_neg
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (alpha : Formula) (h_P : Formula.some_past alpha ∈ M) :
    ¬∃ (L : List Formula), (∀ chi ∈ L, chi ∈ HContent M) ∧ Nonempty (L ⊢ Formula.neg alpha) := by
  intro ⟨L, hL_sub, ⟨h_deriv⟩⟩
  have h_H_neg := HContent_derives_neg_implies_H_neg_mem M h_mcs alpha L hL_sub h_deriv
  have h_P_eq : Formula.some_past alpha = Formula.neg (Formula.all_past (Formula.neg alpha)) := rfl
  rw [h_P_eq] at h_P
  exact set_consistent_not_both h_mcs.1 (Formula.all_past (Formula.neg alpha)) h_H_neg h_P

/-!
## Dovetailing Chain Family Construction

Build the `FMCS Int` from the chain, with all forward_G and backward_H fully proven.
-/

/--
Build the dovetailing chain family from a consistent context.

**Proven** (all 4 FMCS fields):
- forward_G: G phi in M_t implies phi in M_{t'} for all t ≤ t' (fully proven, including cross-sign)
- backward_H: H phi in M_t implies phi in M_{t'} for all t' ≤ t (fully proven, including cross-sign)
- Context preservation at time 0

**Sorry debt** (2):
- forward_F: requires non-linear witness construction (not provable for this linear chain)
- backward_P: requires non-linear witness construction (not provable for this linear chain)

F-formulas (F(psi) = neg(G(neg(psi)))) do not persist through GContent seeds because
GContent only propagates G-formulas. The Lindenbaum extension at any step can introduce
G(neg(psi)), killing F(psi). Resolution requires a non-linear FMCS construction;
see WitnessGraph.lean for proven local witness existence.

Cross-sign G/H propagation is proven using the GContent/HContent duality lemmas:
if GContent(M) ⊆ M', then HContent(M') ⊆ M (and vice versa).
This enables G to propagate through the backward chain toward M_0, then
through the forward chain to positive times (and symmetrically for H).
-/
noncomputable def buildDovetailingChainFamily (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    FMCS Int where
  mcs := fun t =>
    let base := contextAsSet Gamma
    let h_base_cons := list_consistent_to_set_consistent h_cons
    dovetailChainSet base h_base_cons t
  is_mcs := fun t =>
    dovetailChainSet_is_mcs (contextAsSet Gamma) (list_consistent_to_set_consistent h_cons) t
  forward_G := fun t t' phi h_le h_G => by
    let base := contextAsSet Gamma
    let h_base_cons := list_consistent_to_set_consistent h_cons
    show phi ∈ dovetailChainSet base h_base_cons t'
    have h_G' : Formula.all_future phi ∈ dovetailChainSet base h_base_cons t := h_G
    rcases h_le.lt_or_eq with h_lt | h_eq
    · -- Strict case: t < t'
      by_cases h_t : 0 ≤ t
      · have h_t' : 0 ≤ t' := le_of_lt (lt_of_le_of_lt h_t h_lt)
        exact dovetailChainSet_forward_G_nonneg base h_base_cons t t' h_t h_t' h_lt phi h_G'
      · push_neg at h_t
        exact dovetailChainSet_forward_G_neg base h_base_cons t t' h_t h_lt phi h_G'
    · -- Equal case: t = t', use T-axiom
      subst h_eq
      have h_mcs := dovetailChainSet_is_mcs base h_base_cons t
      have h_T : [] ⊢ (Formula.all_future phi).imp phi :=
        Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_future phi)
      exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G'
  backward_H := fun t t' phi h_le h_H => by
    let base := contextAsSet Gamma
    let h_base_cons := list_consistent_to_set_consistent h_cons
    show phi ∈ dovetailChainSet base h_base_cons t'
    have h_H' : Formula.all_past phi ∈ dovetailChainSet base h_base_cons t := h_H
    rcases h_le.lt_or_eq with h_lt | h_eq
    · -- Strict case: t' < t
      by_cases h_t : t < 0
      · have h_t' : t' < 0 := lt_trans h_lt h_t
        exact dovetailChainSet_backward_H_nonpos base h_base_cons t t' h_t h_t' h_lt phi h_H'
      · push_neg at h_t
        exact dovetailChainSet_backward_H_nonneg base h_base_cons t t' h_t h_lt phi h_H'
    · -- Equal case: t' = t, use T-axiom
      subst h_eq
      have h_mcs := dovetailChainSet_is_mcs base h_base_cons t'
      have h_T : [] ⊢ (Formula.all_past phi).imp phi :=
        Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_past phi)
      exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H'

/-- The dovetailing chain family preserves the context at time 0. -/
lemma buildDovetailingChainFamily_preserves_context (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∀ gamma ∈ Gamma, gamma ∈ (buildDovetailingChainFamily Gamma h_cons).mcs 0 := by
  intro gamma h_mem
  simp only [buildDovetailingChainFamily, dovetailChainSet]
  simp only [show (0 : Int) ≥ 0 from le_refl _, ↓reduceDIte, Int.toNat_zero]
  exact dovetailForwardChainMCS_zero_extends (contextAsSet Gamma)
    (list_consistent_to_set_consistent h_cons) h_mem

/-- forward_F for the dovetailing chain.

**Sorry debt**: This cannot be proven for the linear chain construction because F-formulas
do not persist through GContent seeds. The Lindenbaum extension at any step can introduce
G(neg(psi)), killing F(psi). Resolution requires a non-linear FMCS construction.

## DO NOT TRY (Blocked approaches - Task 916 research reports 001-016)

- **Enriched linear chain**: F-formulas don't persist through GContent seeds (v011 analysis)
- **Witness-graph-guided chain**: DAG has LOCAL GContent propagation, not universal (research-016)
- **Constant family oracle**: F(psi) in M doesn't imply psi in M (Phase 6 analysis)
- **Two-timeline embedding**: Nodes reachable by both directions conflict (research-016 Teammate A)
- **Tree unraveling**: Destroys inverse relation for past operators (research-016 Teammate B)
- **Mosaic method**: 80-120h effort, no infrastructure (research-016 Teammate C)

## RESOLUTION PATH

Use omega-squared construction (OmegaSquaredChain.lean) which processes F-obligations
IMMEDIATELY when they appear, before Lindenbaum extension can introduce G(neg(psi)).
See Task 916 plan v012. -/
lemma buildDovetailingChainFamily_forward_F (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∀ t : Int, ∀ φ : Formula,
      Formula.some_future φ ∈ (buildDovetailingChainFamily Gamma h_cons).mcs t →
      ∃ s : Int, t < s ∧ φ ∈ (buildDovetailingChainFamily Gamma h_cons).mcs s := by
  sorry

/-- backward_P for the dovetailing chain.

**Sorry debt**: Symmetric to forward_F. This cannot be proven for the linear chain because
P-formulas do not persist through HContent seeds. See forward_F docstring and Task 916
analysis for the fundamental blocker. WitnessGraph.lean provides proven LOCAL witness
existence (witnessGraph_backward_P_local). -/
lemma buildDovetailingChainFamily_backward_P (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∀ t : Int, ∀ φ : Formula,
      Formula.some_past φ ∈ (buildDovetailingChainFamily Gamma h_cons).mcs t →
      ∃ s : Int, s < t ∧ φ ∈ (buildDovetailingChainFamily Gamma h_cons).mcs s := by
  sorry

/-!
## Main Theorem

This replaces the AXIOM `temporal_coherent_family_exists` with a THEOREM.
The axiom is removed from the trusted kernel; sorry debt remains but is
honest about incompleteness.

**Sorry inventory** (2 total in transitive closure):
- forward_F (witness construction - requires non-linear FMCS)
- backward_P (witness construction - requires non-linear FMCS)

Note: forward_G and backward_H cross-sign cases were previously sorry'd but are
now fully proven (DovetailingChain.lean cross-sign lemmas + WitnessGraph.lean).
-/
theorem temporal_coherent_family_exists_theorem
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (fam : FMCS Int),
      (∀ gamma ∈ Gamma, gamma ∈ fam.mcs 0) ∧
      (∀ t : Int, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : Int, t < s ∧ φ ∈ fam.mcs s) ∧
      (∀ t : Int, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t → ∃ s : Int, s < t ∧ φ ∈ fam.mcs s) := by
  use buildDovetailingChainFamily Gamma h_cons
  exact ⟨buildDovetailingChainFamily_preserves_context Gamma h_cons,
         buildDovetailingChainFamily_forward_F Gamma h_cons,
         buildDovetailingChainFamily_backward_P Gamma h_cons⟩

end Bimodal.Metalogic.Bundle
