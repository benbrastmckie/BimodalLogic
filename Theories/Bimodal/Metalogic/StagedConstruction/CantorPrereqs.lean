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

end Bimodal.Metalogic.StagedConstruction
