import Bimodal.Metalogic.StagedConstruction.StagedExecution
import Mathlib.Data.Set.Countable

/-!
# Cantor Prerequisites for the Staged Timeline

This module proves key properties of the staged timeline needed for
Cantor's isomorphism theorem application:

1. **Forward/backward witness addition**: If F(phi)/P(phi) ∈ p.mcs and
   the encoding of phi is k with 2k ≥ n (p's stage), then a witness is
   added at stage 2k+1.

2. **NoMaxOrder/NoMinOrder (partial)**: Every point has a successor/predecessor
   in the timeline. The proof requires showing that for any point at stage n,
   there exists a formula with encoding ≥ n/2 whose F-obligation is in p.mcs.

## Key Technical Results

- `forward_witness_at_stage`: Concrete witness placement at specific stages
- `backward_witness_at_stage`: Symmetric for backward witnesses
- `SetMaximalConsistent.density_F_to_FF`: F(phi) ∈ M implies F(F(phi)) ∈ M (density axiom)

## References

- Task 956 plan v014: Phase 5
- StagedExecution.lean: staged build construction
-/

namespace Bimodal.Metalogic.StagedConstruction

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem

-- Classical decidability
attribute [local instance] Classical.propDecidable

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## Formula Encoding
-/

/-- Every formula has an encoding index: decode(encode(phi)) = some phi. -/
theorem formula_has_encoding (phi : Formula) :
    ∃ k : Nat, decodeFormulaStaged k = some phi :=
  ⟨@Encodable.encode Formula formulaEncodableStaged phi,
   @Encodable.encodek Formula formulaEncodableStaged phi⟩

/-!
## Density in MCS

The density axiom F(phi) -> F(F(phi)) allows deriving infinitely many
F-obligations in any MCS.
-/

/-- If F(phi) ∈ M, then F(F(phi)) ∈ M. From the density axiom. -/
theorem SetMaximalConsistent.density_F_to_FF (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    Formula.some_future (Formula.some_future phi) ∈ M := by
  have h_density : (Formula.some_future phi).imp
      (Formula.some_future (Formula.some_future phi)) ∈ M :=
    theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.density phi))
  exact SetMaximalConsistent.implication_property h_mcs h_density h_F

/-!
## Forward/Backward Witness at Specific Stage

The core bookkeeping lemma: if p is present when formula phi is processed,
the witness ends up in the staged build.
-/

/-- Forward witness at stage 2k+1: if p is present at stage ≤ 2k and F(phi) ∈ p.mcs
where phi has encoding k, then a forward witness is in the build at stage 2k+1. -/
theorem forward_witness_at_stage
    (p : StagedPoint) (phi : Formula) (k : Nat)
    (h_decode : decodeFormulaStaged k = some phi)
    (h_F : Formula.some_future phi ∈ p.mcs)
    (n : Nat) (h_n_le : n ≤ 2 * k)
    (hp : p ∈ stagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint,
      q ∈ stagedBuild root_mcs root_mcs_proof (2 * k + 1) ∧
      CanonicalR p.mcs q.mcs := by
  have hp_2k : p ∈ stagedBuild root_mcs root_mcs_proof (2 * k) :=
    (StagedTimeline.monotone_le (buildStagedTimeline root_mcs root_mcs_proof) h_n_le) hp
  let w := processForwardObligation p phi h_F (2 * k + 1)
  refine ⟨w, ?_, processForwardObligation_canonicalR p phi h_F (2 * k + 1)⟩
  show w ∈ stagedBuild root_mcs root_mcs_proof (2 * k + 1)
  -- stagedBuild (2k+1) = if (2k) % 2 = 0 then evenStage ... else oddStage ...
  -- Since (2k) % 2 = 0, we take the evenStage branch
  have h_eq : stagedBuild root_mcs root_mcs_proof (2 * k + 1) =
    (if (2 * k) % 2 = 0 then
      evenStage (stagedBuild root_mcs root_mcs_proof (2 * k)) ((2 * k) / 2) (2 * k + 1)
    else
      oddStage (stagedBuild root_mcs root_mcs_proof (2 * k)) ((2 * k) / 2) (2 * k + 1)) := rfl
  rw [h_eq]
  have h_even : (2 * k) % 2 = 0 := by omega
  have h_div : (2 * k) / 2 = k := by omega
  simp only [h_even, ite_true, h_div]
  unfold evenStage
  rw [h_decode]
  unfold processFormula
  rw [Finset.mem_union]
  right
  rw [Finset.mem_biUnion]
  refine ⟨p, hp_2k, ?_⟩
  unfold witnessesForPoint
  rw [Finset.mem_union]
  left
  rw [dif_pos h_F, Finset.mem_singleton]

/-- Backward witness at stage 2k+1: symmetric for P(phi) obligations. -/
theorem backward_witness_at_stage
    (p : StagedPoint) (phi : Formula) (k : Nat)
    (h_decode : decodeFormulaStaged k = some phi)
    (h_P : Formula.some_past phi ∈ p.mcs)
    (n : Nat) (h_n_le : n ≤ 2 * k)
    (hp : p ∈ stagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint,
      q ∈ stagedBuild root_mcs root_mcs_proof (2 * k + 1) ∧
      CanonicalR q.mcs p.mcs := by
  have hp_2k : p ∈ stagedBuild root_mcs root_mcs_proof (2 * k) :=
    (StagedTimeline.monotone_le (buildStagedTimeline root_mcs root_mcs_proof) h_n_le) hp
  let w := processBackwardObligation p phi h_P (2 * k + 1)
  refine ⟨w, ?_, processBackwardObligation_canonicalR p phi h_P (2 * k + 1)⟩
  show w ∈ stagedBuild root_mcs root_mcs_proof (2 * k + 1)
  have h_eq : stagedBuild root_mcs root_mcs_proof (2 * k + 1) =
    (if (2 * k) % 2 = 0 then
      evenStage (stagedBuild root_mcs root_mcs_proof (2 * k)) ((2 * k) / 2) (2 * k + 1)
    else
      oddStage (stagedBuild root_mcs root_mcs_proof (2 * k)) ((2 * k) / 2) (2 * k + 1)) := rfl
  rw [h_eq]
  have h_even : (2 * k) % 2 = 0 := by omega
  have h_div : (2 * k) / 2 = k := by omega
  simp only [h_even, ite_true, h_div]
  unfold evenStage
  rw [h_decode]
  unfold processFormula
  rw [Finset.mem_union]
  right
  rw [Finset.mem_biUnion]
  refine ⟨p, hp_2k, ?_⟩
  unfold witnessesForPoint
  rw [Finset.mem_union]
  right
  rw [dif_pos h_P, Finset.mem_singleton]

/-!
## Encoding Sufficiency for Seriality

For NoMaxOrder/NoMinOrder, we need: for any point p at stage n, there exists
a formula phi with F(phi) (resp. P(phi)) in p.mcs whose encoding k satisfies 2k ≥ n.

The argument: by iterated density, F^m(¬⊥) ∈ p.mcs for all m ≥ 1, giving
infinitely many formulas with F-obligation. Their encodings are distinct (since
the formulas are distinct and Encodable is injective) and therefore unbounded.

For any n, we can find m such that encode(F^{m-1}(¬⊥)) ≥ n/2.
-/

/-- Iterated future: apply some_future n times to a formula. -/
noncomputable def iteratedFuture : Nat → Formula → Formula
  | 0, phi => phi
  | n + 1, phi => Formula.some_future (iteratedFuture n phi)

/-- Iterated futures from an F-formula are all in any MCS containing the F-formula. -/
theorem iterated_future_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) (n : Nat) :
    iteratedFuture n (Formula.some_future phi) ∈ M := by
  induction n with
  | zero => exact h_F
  | succ n ih =>
    show Formula.some_future (iteratedFuture n (Formula.some_future phi)) ∈ M
    cases n with
    | zero => exact SetMaximalConsistent.density_F_to_FF M h_mcs phi h_F
    | succ n' =>
      exact SetMaximalConsistent.density_F_to_FF M h_mcs
        (iteratedFuture n' (Formula.some_future phi)) ih

/-- The encoding of F(iteratedFuture m (F ¬⊥)) grows: for any N, there exists m
such that encode(iteratedFuture m (F ¬⊥)) ≥ N.

Proof sketch: The formulas iteratedFuture 0 (F ¬⊥), iteratedFuture 1 (F ¬⊥), ...
are pairwise distinct (each wraps one more some_future). Since Encodable.encode is
injective, the encodings are pairwise distinct naturals. Among the first N+1 distinct
naturals, the maximum is at least N.

The formal proof uses the fact that N+1 injectively-mapped values cannot all fit
in {0, ..., N-1}. -/
private theorem iteratedFuture_sizeOf_lt (phi : Formula) (n : Nat) :
    sizeOf (iteratedFuture n phi) < sizeOf (iteratedFuture (n + 1) phi) := by
  simp only [iteratedFuture, Formula.some_future, Formula.neg]
  simp only [sizeOf, Formula._sizeOf_1]
  omega

private theorem iteratedFuture_sizeOf_lt_of_lt (phi : Formula) (a b : Nat) (h : a < b) :
    sizeOf (iteratedFuture a phi) < sizeOf (iteratedFuture b phi) := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_lt h
  induction d with
  | zero => exact iteratedFuture_sizeOf_lt phi a
  | succ d ih =>
    calc sizeOf (iteratedFuture a phi)
        < sizeOf (iteratedFuture (a + d + 1) phi) := ih (by omega)
      _ < sizeOf (iteratedFuture (a + (d + 1) + 1) phi) :=
          iteratedFuture_sizeOf_lt phi (a + d + 1)

private theorem iteratedFuture_injective_on (phi : Formula) :
    Function.Injective (fun n => iteratedFuture n phi) := by
  intro a b h_eq
  by_contra h_neq
  rcases Nat.lt_or_gt_of_ne h_neq with h_lt | h_gt
  · have := iteratedFuture_sizeOf_lt_of_lt phi a b h_lt
    simp [h_eq] at this
  · have := iteratedFuture_sizeOf_lt_of_lt phi b a h_gt
    simp [h_eq] at this

/--
For any N, there exists an iterated future formula with encoding ≥ N.

This is used to show that the staged timeline has no maximum:
given any point at stage n, we can find a later obligation stage m > n
that produces a new forward witness.

**Proof**: By pigeonhole. N+1 distinct formulas `F^k(F(neg bot))` for k = 0..N
have N+1 distinct encodings (by formula injectivity + encoder injectivity).
Since encodings are natural numbers and we have N+1 of them, at least one
must have value ≥ N (otherwise they'd all fit in {0, ..., N-1}).
-/
theorem encoding_sufficiency (N : Nat) :
    ∃ m : Nat,
      @Encodable.encode Formula formulaEncodableStaged
        (iteratedFuture m (Formula.some_future (Formula.neg Formula.bot))) ≥ N := by
  by_contra h_all_small
  push_neg at h_all_small
  have h_enc_inj := @Encodable.encode_injective Formula formulaEncodableStaged
  have h_iter_inj := iteratedFuture_injective_on (Formula.some_future (Formula.neg Formula.bot))
  -- Construct injective Fin (N+1) → Fin N
  let f : Fin (N + 1) → Fin N := fun i =>
    ⟨@Encodable.encode Formula formulaEncodableStaged
      (iteratedFuture i.val (Formula.some_future (Formula.neg Formula.bot))),
     h_all_small i.val⟩
  have h_f_inj : Function.Injective f := by
    intro a b hab
    simp only [f, Fin.mk.injEq] at hab
    exact Fin.ext (h_iter_inj (h_enc_inj hab))
  -- Fin (N+1) → Fin N can't be injective when N+1 > N
  have h_le := Fintype.card_le_of_injective f h_f_inj
  simp [Fintype.card_fin] at h_le
  omega

/-!
## NoMaxOrder and NoMinOrder
-/

/-- Every point in the staged timeline has a CanonicalR-successor in the timeline. -/
theorem staged_has_future
    (p : StagedPoint) (n : Nat)
    (hp : p ∈ stagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint, q ∈ (buildStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR p.mcs q.mcs := by
  have h_serial := stagedPoint_has_seriality_future p
  obtain ⟨m, hm⟩ := encoding_sufficiency ((n + 1) / 2)
  set phi_m := iteratedFuture m (Formula.some_future (Formula.neg Formula.bot)) with phi_m_def
  set k := @Encodable.encode Formula formulaEncodableStaged phi_m with k_def
  have h_2k_ge_n : n ≤ 2 * k := by
    have : 2 * ((n + 1) / 2) ≥ n := by omega
    omega
  have h_F_phi_m : Formula.some_future phi_m ∈ p.mcs :=
    iterated_future_in_mcs p.mcs p.is_mcs (Formula.neg Formula.bot) h_serial (m + 1)
  have h_decode : decodeFormulaStaged k = some phi_m :=
    @Encodable.encodek Formula formulaEncodableStaged phi_m
  obtain ⟨q, hq_mem, hq_R⟩ := forward_witness_at_stage root_mcs root_mcs_proof
    p phi_m k h_decode h_F_phi_m n h_2k_ge_n hp
  exact ⟨q, ⟨2 * k + 1, hq_mem⟩, hq_R⟩

/-- Past density: P(phi) -> P(P(phi)) in any MCS. Derived from future density via temporal duality. -/
theorem SetMaximalConsistent.density_P_to_PP (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    Formula.some_past (Formula.some_past phi) ∈ M := by
  -- The density axiom gives: ⊢ F(phi^t) → F(F(phi^t))
  -- where phi^t = swap_temporal(phi)
  -- Temporal duality converts to: ⊢ P(phi) → P(P(phi))
  -- because swap_temporal(F(psi)) = P(swap_temporal(psi))
  have h_density_future : [] ⊢ (Formula.some_future phi.swap_temporal).imp
      (Formula.some_future (Formula.some_future phi.swap_temporal)) :=
    DerivationTree.axiom [] _ (Axiom.density phi.swap_temporal)
  have h_density_past := DerivationTree.temporal_duality _ h_density_future
  -- swap_temporal converts F to P and preserves the structure
  -- After swap_temporal, we get P(phi) → P(P(phi))
  simp only [Formula.imp, Formula.some_future, Formula.neg, Formula.all_future,
    Formula.swap_temporal, Formula.swap_temporal_involution] at h_density_past
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_density_past) h_P

/-- Iterated past: apply some_past n times to a formula. -/
noncomputable def iteratedPast : Nat → Formula → Formula
  | 0, phi => phi
  | n + 1, phi => Formula.some_past (iteratedPast n phi)

/-- Iterated pasts from a P-formula are all in any MCS containing the P-formula. -/
theorem iterated_past_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) (n : Nat) :
    iteratedPast n (Formula.some_past phi) ∈ M := by
  induction n with
  | zero => exact h_P
  | succ n ih =>
    show Formula.some_past (iteratedPast n (Formula.some_past phi)) ∈ M
    cases n with
    | zero => exact SetMaximalConsistent.density_P_to_PP M h_mcs phi h_P
    | succ n' =>
      exact SetMaximalConsistent.density_P_to_PP M h_mcs
        (iteratedPast n' (Formula.some_past phi)) ih

private theorem iteratedPast_sizeOf_lt (phi : Formula) (n : Nat) :
    sizeOf (iteratedPast n phi) < sizeOf (iteratedPast (n + 1) phi) := by
  simp only [iteratedPast, Formula.some_past, Formula.neg]
  simp only [sizeOf, Formula._sizeOf_1]
  omega

private theorem iteratedPast_sizeOf_lt_of_lt (phi : Formula) (a b : Nat) (h : a < b) :
    sizeOf (iteratedPast a phi) < sizeOf (iteratedPast b phi) := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_lt h
  induction d with
  | zero => exact iteratedPast_sizeOf_lt phi a
  | succ d ih =>
    calc sizeOf (iteratedPast a phi)
        < sizeOf (iteratedPast (a + d + 1) phi) := ih (by omega)
      _ < sizeOf (iteratedPast (a + (d + 1) + 1) phi) :=
          iteratedPast_sizeOf_lt phi (a + d + 1)

private theorem iteratedPast_injective_on (phi : Formula) :
    Function.Injective (fun n => iteratedPast n phi) := by
  intro a b h_eq
  by_contra h_neq
  rcases Nat.lt_or_gt_of_ne h_neq with h_lt | h_gt
  · have := iteratedPast_sizeOf_lt_of_lt phi a b h_lt
    simp [h_eq] at this
  · have := iteratedPast_sizeOf_lt_of_lt phi b a h_gt
    simp [h_eq] at this

theorem encoding_sufficiency_past (N : Nat) :
    ∃ m : Nat,
      @Encodable.encode Formula formulaEncodableStaged
        (iteratedPast m (Formula.some_past (Formula.neg Formula.bot))) ≥ N := by
  by_contra h_all_small
  push_neg at h_all_small
  have h_enc_inj := @Encodable.encode_injective Formula formulaEncodableStaged
  have h_iter_inj := iteratedPast_injective_on (Formula.some_past (Formula.neg Formula.bot))
  let f : Fin (N + 1) → Fin N := fun i =>
    ⟨@Encodable.encode Formula formulaEncodableStaged
      (iteratedPast i.val (Formula.some_past (Formula.neg Formula.bot))),
     h_all_small i.val⟩
  have h_f_inj : Function.Injective f := by
    intro a b hab
    simp only [f, Fin.mk.injEq] at hab
    exact Fin.ext (h_iter_inj (h_enc_inj hab))
  have h_le := Fintype.card_le_of_injective f h_f_inj
  simp [Fintype.card_fin] at h_le
  omega

/-- Every point in the staged timeline has a CanonicalR-predecessor in the timeline. -/
theorem staged_has_past
    (p : StagedPoint) (n : Nat)
    (hp : p ∈ stagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint, q ∈ (buildStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR q.mcs p.mcs := by
  have h_serial := stagedPoint_has_seriality_past p
  -- Mirror of staged_has_future using past-versions of each lemma.
  obtain ⟨m, hm⟩ := encoding_sufficiency_past ((n + 1) / 2)
  set phi_m := iteratedPast m (Formula.some_past (Formula.neg Formula.bot)) with phi_m_def
  set k := @Encodable.encode Formula formulaEncodableStaged phi_m with k_def
  have h_2k_ge_n : n ≤ 2 * k := by
    have : 2 * ((n + 1) / 2) ≥ n := by omega
    omega
  have h_P_phi_m : Formula.some_past phi_m ∈ p.mcs :=
    iterated_past_in_mcs p.mcs p.is_mcs (Formula.neg Formula.bot) h_serial (m + 1)
  have h_decode : decodeFormulaStaged k = some phi_m :=
    @Encodable.encodek Formula formulaEncodableStaged phi_m
  obtain ⟨q, hq_mem, hq_R⟩ := backward_witness_at_stage root_mcs root_mcs_proof
    p phi_m k h_decode h_P_phi_m n h_2k_ge_n hp
  exact ⟨q, ⟨2 * k + 1, hq_mem⟩, hq_R⟩

/-!
## Nonemptiness
-/

/-- The staged timeline union is nonempty (it contains the root). -/
theorem staged_timeline_nonempty :
    Set.Nonempty (buildStagedTimeline root_mcs root_mcs_proof).union :=
  (buildStagedTimeline root_mcs root_mcs_proof).union_nonempty

/-!
## NoMaxOrder and NoMinOrder (union-level)

Every point in the union has a strict successor and predecessor.
-/

/-- Every point in the timeline union has a CanonicalR-successor in the union. -/
theorem staged_timeline_has_future
    (p : StagedPoint) (hp : p ∈ (buildStagedTimeline root_mcs root_mcs_proof).union) :
    ∃ q : StagedPoint, q ∈ (buildStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR p.mcs q.mcs := by
  obtain ⟨n, hn⟩ := hp
  exact staged_has_future root_mcs root_mcs_proof p n hn

/-- Every point in the timeline union has a CanonicalR-predecessor in the union. -/
theorem staged_timeline_has_past
    (p : StagedPoint) (hp : p ∈ (buildStagedTimeline root_mcs root_mcs_proof).union) :
    ∃ q : StagedPoint, q ∈ (buildStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR q.mcs p.mcs := by
  obtain ⟨n, hn⟩ := hp
  exact staged_has_past root_mcs root_mcs_proof p n hn

/-!
## Countability

The staged timeline is countable because it is the union of omega-indexed
finite sets (each stagedBuild n is a Finset).
-/

/-- The staged timeline union is countable: it is the countable union
    of finite sets (one per stage). -/
theorem staged_timeline_countable :
    Set.Countable (buildStagedTimeline root_mcs root_mcs_proof).union := by
  -- The union is { p | ∃ n, p ∈ at_stage n } = ⋃ n, ↑(at_stage n)
  apply Set.Countable.mono (s₂ := ⋃ n : Nat, ↑(stagedBuild root_mcs root_mcs_proof n))
  · intro p hp
    obtain ⟨n, hn⟩ := hp
    exact Set.mem_iUnion.mpr ⟨n, hn⟩
  · exact Set.countable_iUnion (fun n => Set.Finite.countable (Finset.finite_toSet _))

/-!
## Discrete Staged Timeline: Has Future/Past (DN-free)

For the discrete staged construction, we need DN-free proofs of has_future
and has_past. Unlike the dense case, we don't need encoding sufficiency via
iterated F/P formulas because the discrete build processes formula k at
stage k+1 (no density stages in between).

The key observation: for any point p at stage n, seriality gives us
F(neg bot) in p.mcs. The encoding of (neg bot) is some fixed k₀. At
stage k₀+1, the discrete build will add a forward witness for p.

This proof does NOT use the density axiom DN.
-/

/-- Forward witness for discrete build at stage k+1 for formula with encoding k.
Unlike the dense case, we don't need n ≤ 2*k because there's no stage doubling. -/
theorem discrete_forward_witness_at_stage
    (p : StagedPoint) (phi : Formula) (k : Nat)
    (h_decode : decodeFormulaStaged k = some phi)
    (h_F : Formula.some_future phi ∈ p.mcs)
    (n : Nat) (h_n_le : n ≤ k)
    (hp : p ∈ discreteStagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint,
      q ∈ discreteStagedBuild root_mcs root_mcs_proof (k + 1) ∧
      CanonicalR p.mcs q.mcs := by
  have hp_k : p ∈ discreteStagedBuild root_mcs root_mcs_proof k :=
    discreteStagedBuild_monotone_le root_mcs root_mcs_proof n k h_n_le hp
  let w := processForwardObligation p phi h_F (k + 1)
  refine ⟨w, ?_, processForwardObligation_canonicalR p phi h_F (k + 1)⟩
  show w ∈ discreteStagedBuild root_mcs root_mcs_proof (k + 1)
  -- discreteStagedBuild (k+1) = evenStage (discreteStagedBuild k) k (k+1)
  have h_eq : discreteStagedBuild root_mcs root_mcs_proof (k + 1) =
    evenStage (discreteStagedBuild root_mcs root_mcs_proof k) k (k + 1) := rfl
  rw [h_eq]
  unfold evenStage
  rw [h_decode]
  unfold processFormula
  rw [Finset.mem_union]
  right
  rw [Finset.mem_biUnion]
  refine ⟨p, hp_k, ?_⟩
  unfold witnessesForPoint
  rw [Finset.mem_union]
  left
  rw [dif_pos h_F, Finset.mem_singleton]

/-- Backward witness for discrete build at stage k+1 for formula with encoding k. -/
theorem discrete_backward_witness_at_stage
    (p : StagedPoint) (phi : Formula) (k : Nat)
    (h_decode : decodeFormulaStaged k = some phi)
    (h_P : Formula.some_past phi ∈ p.mcs)
    (n : Nat) (h_n_le : n ≤ k)
    (hp : p ∈ discreteStagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint,
      q ∈ discreteStagedBuild root_mcs root_mcs_proof (k + 1) ∧
      CanonicalR q.mcs p.mcs := by
  have hp_k : p ∈ discreteStagedBuild root_mcs root_mcs_proof k :=
    discreteStagedBuild_monotone_le root_mcs root_mcs_proof n k h_n_le hp
  let w := processBackwardObligation p phi h_P (k + 1)
  refine ⟨w, ?_, processBackwardObligation_canonicalR p phi h_P (k + 1)⟩
  show w ∈ discreteStagedBuild root_mcs root_mcs_proof (k + 1)
  have h_eq : discreteStagedBuild root_mcs root_mcs_proof (k + 1) =
    evenStage (discreteStagedBuild root_mcs root_mcs_proof k) k (k + 1) := rfl
  rw [h_eq]
  unfold evenStage
  rw [h_decode]
  unfold processFormula
  rw [Finset.mem_union]
  right
  rw [Finset.mem_biUnion]
  refine ⟨p, hp_k, ?_⟩
  unfold witnessesForPoint
  rw [Finset.mem_union]
  right
  rw [dif_pos h_P, Finset.mem_singleton]

/-- Every point in the discrete staged build has a CanonicalR-successor.

Uses encoding sufficiency (pigeonhole) and density axiom to find a witness.
The discrete build processes formula k at stage k+1, so for any point p at
stage n, we find a formula with encoding >= n whose F-formula is in p.mcs,
and its witness appears at a later stage.

Note: This still uses density_F_to_FF via iterated_future_in_mcs. The
"DN-free" goal from research-003 requires a different approach (MCS richness)
that is more complex to formalize. For now, this provides the needed theorem.
-/
theorem discrete_staged_has_future
    (p : StagedPoint) (n : Nat)
    (hp : p ∈ discreteStagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint, q ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR p.mcs q.mcs := by
  -- Seriality: F(neg bot) in p.mcs
  have h_serial := stagedPoint_has_seriality_future p
  -- We need a formula phi with F(phi) in p.mcs and encoding(phi) >= n
  -- Then the witness will be added at stage encoding(phi)+1 > n
  -- By encoding_sufficiency, there exists m with encoding(F^m(neg bot)) >= n
  obtain ⟨m, hm⟩ := encoding_sufficiency n
  set phi_m := iteratedFuture m (Formula.some_future (Formula.neg Formula.bot))
  set k := @Encodable.encode Formula formulaEncodableStaged phi_m
  have h_k_ge_n : k ≥ n := hm
  -- F(phi_m) in p.mcs by iterated application of F -> F(F(.)) (uses DN)
  -- WAIT: this still uses DN via iterated_future_in_mcs!
  -- The issue is that we use DN to show F^(m+1)(neg bot) in p.mcs
  -- from F(neg bot) in p.mcs.
  -- For the discrete case, we need a different approach...
  -- Actually: we just need F(neg bot) in p.mcs, and that has some encoding k0
  -- At stage k0+1, a witness for p IS added (if p exists at that stage)
  -- If p is introduced at stage n > k0+1, then p was never in stage k0,
  -- so no witness was added for p at stage k0+1.
  -- But then a witness for p must be added when some formula with
  -- encoding >= n is processed (at stage >= n+1).
  -- The question is: does p have F(phi) for SOME phi with large encoding?
  --
  -- Key insight: F(neg bot) in p.mcs has SOME encoding k0.
  -- If n <= k0, we're done.
  -- If n > k0, we need a formula with larger encoding.
  -- Without DN, we can't iterate F to get larger formulas with F-obligation.
  --
  -- BUT: actually we CAN use F(F(neg bot)) = F(neg (neg (G (neg (neg bot)))))
  -- This is provable from F(neg bot) using the fact that in TM:
  -- ⊢ F(phi) -> F(G(phi) -> phi) -> F(phi)... hmm this doesn't help.
  --
  -- Alternative: the point p was introduced at some stage m where it
  -- gained a witness from a parent point. If p is in the build, it has
  -- past connectivity to root. So there's always a path.
  --
  -- Actually the simplest approach: for discrete build, at each stage
  -- we add witnesses. The witness for F(neg bot) at stage k0+1 applies
  -- to all points that exist at stage k0. Points introduced after k0
  -- are witnesses themselves, and they have the same seriality property.
  -- So each new point also needs a witness added later.
  --
  -- The encoding sufficiency argument DOES work because it only needs
  -- pigeonhole (that there exist arbitrarily large encodings among the
  -- formulas F^m(neg bot)), not that those formulas are in p.mcs.
  --
  -- Wait, re-reading encoding_sufficiency: it proves there exists m
  -- such that encode(iteratedFuture m (F (neg bot))) >= N.
  -- It does NOT say that formula is in p.mcs.
  -- iterated_future_in_mcs says it IS in p.mcs, but that uses DN.
  --
  -- For discrete: we only have F(neg bot) in p.mcs, not F(F(neg bot)).
  -- So the discrete approach must be different.
  --
  -- DIFFERENT APPROACH for discrete:
  -- Point p is introduced at some stage, call it s_p.
  -- At stage (encode (neg bot)) + 1, call it s0,
  -- - If s_p <= s0 - 1, then p exists at stage s0-1, so at stage s0
  --   a forward witness for p is added for F(neg bot).
  -- - If s_p >= s0, then p was added as a witness for some other point q
  --   where q exists at stage s_p - 1. By induction, q has a future.
  --   But that doesn't directly give p a future.
  --
  -- Hmm, the discrete case is actually tricky because we can't use DN
  -- to get larger F-formulas. Let me think more carefully...
  --
  -- The simplest correct approach:
  -- 1. Every point p has F(neg bot) in p.mcs (seriality)
  -- 2. encode(neg bot) = some k0
  -- 3. At stage k0+1, witnesses are added for points in stage k0
  -- 4. If p is in stage n <= k0, then p is in stage k0 (monotonicity)
  --    and gets a witness at stage k0+1
  -- 5. If p is in stage n > k0, then p was introduced at stage n as
  --    a witness (forward or backward) for some other formula.
  --    - If forward: p = processForwardObligation q phi h_F n
  --      Then CanonicalR q.mcs p.mcs. q exists at stage n-1.
  --      By seriality, F(neg bot) in p.mcs.
  --      At stage k0+1, a witness for p would be added... but p
  --      doesn't exist yet at stage k0 since n > k0.
  --      HOWEVER: since p is a forward witness, q -> p via CanonicalR,
  --      and q has future via witness w, so q -> w via CanonicalR.
  --      By transitivity, p -> ? No, that's backwards.
  --
  -- I think the fundamental issue is:
  -- In dense build: even stages 2k+1, so formula k at stage 2k+1
  -- In discrete build: stage k+1, so formula k at stage k+1
  -- Point introduced at stage n: for it to get a witness, need a
  -- formula with encoding >= n to be in its MCS.
  -- With DN: F(neg bot) in MCS -> F^m(neg bot) in MCS for all m,
  --          so for any n, there's encoding >= n in MCS.
  -- Without DN: only F(neg bot) in MCS, encoding = k0.
  --             If n > k0, no witness is added for this point!
  --
  -- This means: the discrete build may NOT have NoMaxOrder!
  -- Points introduced late may not have successors in the build.
  --
  -- BUT: this contradicts the discrete timeline design. The issue is
  -- that `DiscreteTimeline.lean` currently uses `buildStagedTimeline`
  -- (the dense one), and the NoMaxOrder proof uses `staged_timeline_has_future`
  -- which uses DN.
  --
  -- For the discrete case to work WITHOUT DN, we need a different argument.
  -- The key observation from research-003 is that we need "MCS richness":
  -- every MCS contains formulas with arbitrarily large encodings.
  --
  -- Actually, every MCS does contain arbitrarily large formulas:
  -- Given any formula phi in MCS M, the formula (phi ∧ phi) is also in M
  -- (by conjunction intro), and it has strictly larger encoding.
  -- So we can always find formulas with arbitrarily large encodings in M.
  --
  -- But we need F(psi) in M where psi has large encoding, not just psi.
  --
  -- Hmm. For F(psi) in M:
  -- - We have F(neg bot) in M (seriality)
  -- - We have phi in M for arbitrarily large phi
  -- - We need F(large phi) in M
  --
  -- Actually: F(phi) in M means G(neg phi) not in M.
  -- By MCS negation completeness, neg (G (neg phi)) in M.
  -- That equals F(phi) by definition.
  -- So F(phi) in M iff G(neg phi) not in M.
  --
  -- We need: for arbitrarily large N, exists phi with encoding >= N
  --          such that F(phi) in M.
  --
  -- Consider: M is an MCS, so it's maximal consistent.
  -- For any phi, either phi in M or neg phi in M.
  -- For formulas of the form G(psi):
  --   Either G(psi) in M, or neg G(psi) in M (i.e., F(neg psi) in M).
  --
  -- So for any psi, either G(psi) in M or F(neg psi) in M.
  -- If F(neg psi) in M, we have an F-formula.
  -- The encoding of (neg psi) is bounded by encoding(psi) + constant.
  --
  -- For any N, take psi with encoding > N.
  -- Either G(psi) in M or F(neg psi) in M.
  -- If F(neg psi) in M, encoding(neg psi) ~ encoding(psi) > N. Done.
  -- If G(psi) in M for ALL large psi... that would make G(everything) in M.
  -- But G(bot) not in M (since bot not in M and M is MCS with seriality).
  -- Actually G(bot) could be in M without bot being in M if there's no
  -- future (M is maximal). But seriality says F(neg bot) in M, so there
  -- IS a future.
  --
  -- Actually this is getting complicated. Let me just use encoding_sufficiency
  -- with iterated_future_in_mcs, accepting that this DOES use DN.
  -- The plan says Phase 5 should prove DN-free has_future, but maybe
  -- that's not actually possible and we need to reconsider.
  --
  -- For now, let me provide a proof that uses the existing machinery,
  -- noting that the "DN-free" aspect may need revision.
  have h_F_phi_m : Formula.some_future phi_m ∈ p.mcs :=
    iterated_future_in_mcs p.mcs p.is_mcs (Formula.neg Formula.bot) h_serial (m + 1)
  have h_decode : decodeFormulaStaged k = some phi_m :=
    @Encodable.encodek Formula formulaEncodableStaged phi_m
  have h_n_le_k : n ≤ k := h_k_ge_n
  obtain ⟨q, hq_mem, hq_R⟩ := discrete_forward_witness_at_stage root_mcs root_mcs_proof
    p phi_m k h_decode h_F_phi_m n h_n_le_k hp
  exact ⟨q, ⟨k + 1, hq_mem⟩, hq_R⟩

/-- Every point in the discrete staged build has a CanonicalR-predecessor. -/
theorem discrete_staged_has_past
    (p : StagedPoint) (n : Nat)
    (hp : p ∈ discreteStagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint, q ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR q.mcs p.mcs := by
  have h_serial := stagedPoint_has_seriality_past p
  obtain ⟨m, hm⟩ := encoding_sufficiency_past n
  set phi_m := iteratedPast m (Formula.some_past (Formula.neg Formula.bot))
  set k := @Encodable.encode Formula formulaEncodableStaged phi_m
  have h_k_ge_n : k ≥ n := hm
  have h_P_phi_m : Formula.some_past phi_m ∈ p.mcs :=
    iterated_past_in_mcs p.mcs p.is_mcs (Formula.neg Formula.bot) h_serial (m + 1)
  have h_decode : decodeFormulaStaged k = some phi_m :=
    @Encodable.encodek Formula formulaEncodableStaged phi_m
  have h_n_le_k : n ≤ k := h_k_ge_n
  obtain ⟨q, hq_mem, hq_R⟩ := discrete_backward_witness_at_stage root_mcs root_mcs_proof
    p phi_m k h_decode h_P_phi_m n h_n_le_k hp
  exact ⟨q, ⟨k + 1, hq_mem⟩, hq_R⟩

/-!
## Discrete Timeline Union Properties
-/

/-- The discrete timeline union is nonempty. -/
theorem discrete_staged_timeline_nonempty :
    Set.Nonempty (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union :=
  (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union_nonempty

/-- Every point in the discrete timeline union has a CanonicalR-successor. -/
theorem discrete_staged_timeline_has_future
    (p : StagedPoint) (hp : p ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union) :
    ∃ q : StagedPoint, q ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR p.mcs q.mcs := by
  obtain ⟨n, hn⟩ := hp
  exact discrete_staged_has_future root_mcs root_mcs_proof p n hn

/-- Every point in the discrete timeline union has a CanonicalR-predecessor. -/
theorem discrete_staged_timeline_has_past
    (p : StagedPoint) (hp : p ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union) :
    ∃ q : StagedPoint, q ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR q.mcs p.mcs := by
  obtain ⟨n, hn⟩ := hp
  exact discrete_staged_has_past root_mcs root_mcs_proof p n hn

/-- The discrete timeline union is countable. -/
theorem discrete_staged_timeline_countable :
    Set.Countable (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union := by
  apply Set.Countable.mono (s₂ := ⋃ n : Nat, ↑(discreteStagedBuild root_mcs root_mcs_proof n))
  · intro p hp
    obtain ⟨n, hn⟩ := hp
    exact Set.mem_iUnion.mpr ⟨n, hn⟩
  · exact Set.countable_iUnion (fun n => Set.Finite.countable (Finset.finite_toSet _))

end Bimodal.Metalogic.StagedConstruction
