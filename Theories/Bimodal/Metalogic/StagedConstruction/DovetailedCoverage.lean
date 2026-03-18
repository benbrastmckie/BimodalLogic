import Bimodal.Metalogic.StagedConstruction.DovetailedBuild
import Bimodal.Metalogic.StagedConstruction.CantorPrereqs

/-!
# Dovetailed Coverage via Density Argument

This module proves the key coverage lemmas for the dovetailed construction using
the density argument. The core insight: while `pair(L, k)` may be < s for a specific
encoding k (meaning the obligation was processed before point p existed), we can use
a semantically equivalent F-formula with larger encoding via density iteration.

## Key Theorems

- `iterated_future_encoding_unbounded`: For any bound N, there exists an iteration i
  such that the encoding of F^i(neg bot) is >= N.

- `density_large_step_exists`: For any point p in the dovetailed timeline at step n,
  there exists a formula psi such that F(psi) is in p.mcs AND pair(p.point_index, encoding(psi)) > n.

- `witness_at_large_step`: When the encoding is large enough that pair(p.point_index, k) > n,
  and p is in build at step n, then the forward witness is added at step pair(p.point_index, k).

## References

- Task 982: Dense completeness via full dovetailing
- reports/17_blocker-resolution.md: Density argument analysis
- DovetailedBuild.lean: Core dovetailed construction
- CantorPrereqs.lean: iteratedFuture, density lemmas
-/

namespace Bimodal.Metalogic.StagedConstruction.DovetailedCoverage

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem
open Bimodal.Metalogic.StagedConstruction
open Bimodal.Metalogic.StagedConstruction.Dovetailing
open Bimodal.Metalogic.StagedConstruction.DovetailedBuild

-- Classical decidability
attribute [local instance] Classical.propDecidable

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## Task 4.1: Pair Lower Bound

The pair(a, b) >= a + b property is already proven in Dovetailing.lean as `pair_ge_sum`.
We re-export it here for convenience.
-/

/-- Nat.pair(a, b) is at least a + b. This is `pair_ge_sum` from Dovetailing.lean. -/
theorem pair_ge_add (a b : Nat) : a + b ≤ Nat.pair a b := pair_ge_sum a b

/-!
## Task 4.2: Encoding Growth

We prove that for any bound N, there exists a formula with encoding >= N that is F(...).
The key is that iteratedFuture produces structurally distinct formulas with distinct encodings.
-/

/-- some_future increases sizeOf. -/
private theorem some_future_sizeOf_lt (phi : Formula) :
    sizeOf phi < sizeOf (Formula.some_future phi) := by
  -- some_future X = neg (all_future (neg X)) = (X.imp bot).all_future.imp bot
  unfold Formula.some_future Formula.neg
  simp
  omega

/-- iteratedFuture increases formula size strictly with n. -/
private theorem iteratedFuture_sizeOf_strict_mono (phi : Formula) :
    StrictMono (fun n => sizeOf (iteratedFuture n phi)) := by
  intro i j h_lt
  induction h_lt with
  | refl =>
    show sizeOf (iteratedFuture i phi) < sizeOf (iteratedFuture (i + 1) phi)
    conv_rhs => rw [show iteratedFuture (i + 1) phi = Formula.some_future (iteratedFuture i phi) from rfl]
    exact some_future_sizeOf_lt (iteratedFuture i phi)
  | @step m _ ih =>
    have h_step : sizeOf (iteratedFuture m phi) < sizeOf (iteratedFuture (m + 1) phi) := by
      conv_rhs => rw [show iteratedFuture (m + 1) phi = Formula.some_future (iteratedFuture m phi) from rfl]
      exact some_future_sizeOf_lt (iteratedFuture m phi)
    exact Nat.lt_trans ih h_step

/-- Iterated futures are all distinct: if i ≠ j then iteratedFuture i phi ≠ iteratedFuture j phi. -/
theorem iteratedFuture_injective (phi : Formula) :
    Function.Injective (fun n => iteratedFuture n phi) := by
  intro i j h_eq
  by_contra h_ne
  have h_size_eq : sizeOf (iteratedFuture i phi) = sizeOf (iteratedFuture j phi) := congrArg sizeOf h_eq
  rcases Nat.lt_trichotomy i j with h_lt | h_eq_ij | h_gt
  · have h_strict : sizeOf (iteratedFuture i phi) < sizeOf (iteratedFuture j phi) :=
      iteratedFuture_sizeOf_strict_mono phi h_lt
    exact Nat.lt_irrefl (sizeOf (iteratedFuture j phi)) (h_size_eq ▸ h_strict)
  · exact h_ne h_eq_ij
  · have h_strict : sizeOf (iteratedFuture j phi) < sizeOf (iteratedFuture i phi) :=
      iteratedFuture_sizeOf_strict_mono phi h_gt
    exact Nat.lt_irrefl (sizeOf (iteratedFuture i phi)) (h_size_eq.symm ▸ h_strict)

/-- For any bound N, there exists i such that the encoding of iteratedFuture i (F(neg bot)) is >= N.
    Since iteratedFuture is injective and encodings are injective, among N+1 distinct formulas,
    at least one must have encoding >= N. -/
theorem iterated_future_encoding_unbounded (N : Nat) :
    ∃ i : Nat,
      @Encodable.encode Formula formulaEncodableStaged
        (iteratedFuture i (Formula.some_future (Formula.neg Formula.bot))) ≥ N := by
  by_contra h_all_small
  push_neg at h_all_small
  -- h_all_small : ∀ i, encode(iteratedFuture i (F ¬⊥)) < N
  -- We have N+1 distinct formulas (for i = 0, 1, ..., N) with encodings in {0, ..., N-1}
  -- By pigeonhole, this is impossible
  have h_enc_inj := @Encodable.encode_injective Formula formulaEncodableStaged
  let phi_base := Formula.some_future (Formula.neg Formula.bot)
  let f : Fin (N + 1) → Fin N := fun i =>
    ⟨@Encodable.encode Formula formulaEncodableStaged (iteratedFuture i.val phi_base),
     h_all_small i.val⟩
  have h_f_inj : Function.Injective f := by
    intro a b hab
    simp only [f, Fin.mk.injEq] at hab
    have h_formula_eq := h_enc_inj hab
    have h_idx_eq := iteratedFuture_injective phi_base h_formula_eq
    exact Fin.ext h_idx_eq
  have h_le := Fintype.card_le_of_injective f h_f_inj
  simp only [Fintype.card_fin] at h_le
  omega

/-- **Generalized encoding unboundedness**: For any base formula phi_base and any bound N,
    there exists i such that the encoding of iteratedFuture i phi_base is >= N.

    This is the general version needed for the small-step case in forward_F/backward_P proofs. -/
theorem iterated_future_encoding_unbounded_general (phi_base : Formula) (N : Nat) :
    ∃ i : Nat,
      @Encodable.encode Formula formulaEncodableStaged (iteratedFuture i phi_base) ≥ N := by
  by_contra h_all_small
  push_neg at h_all_small
  -- h_all_small : ∀ i, encode(iteratedFuture i phi_base) < N
  -- We have N+1 distinct formulas (for i = 0, 1, ..., N) with encodings in {0, ..., N-1}
  -- By pigeonhole, this is impossible
  have h_enc_inj := @Encodable.encode_injective Formula formulaEncodableStaged
  let f : Fin (N + 1) → Fin N := fun i =>
    ⟨@Encodable.encode Formula formulaEncodableStaged (iteratedFuture i.val phi_base),
     h_all_small i.val⟩
  have h_f_inj : Function.Injective f := by
    intro a b hab
    simp only [f, Fin.mk.injEq] at hab
    have h_formula_eq := h_enc_inj hab
    have h_idx_eq := iteratedFuture_injective phi_base h_formula_eq
    exact Fin.ext h_idx_eq
  have h_le := Fintype.card_le_of_injective f h_f_inj
  simp only [Fintype.card_fin] at h_le
  omega

/-- For any bound N, there exists a formula phi and encoding k such that:
    1. decodeFormulaStaged k = some phi
    2. k >= N
    3. phi is of the form F(...) (i.e., phi = some_future psi for some psi) -/
theorem encoding_growth_exists (N : Nat) :
    ∃ phi k, decodeFormulaStaged k = some phi ∧
             k ≥ N ∧
             ∃ psi, phi = Formula.some_future psi := by
  obtain ⟨i, h_enc_ge⟩ := iterated_future_encoding_unbounded N
  let phi := iteratedFuture i (Formula.some_future (Formula.neg Formula.bot))
  let k := @Encodable.encode Formula formulaEncodableStaged phi
  have h_decode : decodeFormulaStaged k = some phi :=
    @Encodable.encodek Formula formulaEncodableStaged phi
  refine ⟨phi, k, h_decode, h_enc_ge, ?_⟩
  -- Show phi is of the form some_future psi
  cases i with
  | zero => exact ⟨Formula.neg Formula.bot, rfl⟩
  | succ i' => exact ⟨iteratedFuture i' (Formula.some_future (Formula.neg Formula.bot)), rfl⟩

/-!
## Task 4.3: Density Iteration

If F(phi) is in M, then F^n(phi) is in M for all n. This is essentially `iterated_future_in_mcs`
from CantorPrereqs.lean. We provide a more convenient form here.
-/

/-- F(phi) in M implies F^n(F(phi)) = F^{n+1}(phi) in M for all n.
    This is `iterated_future_in_mcs` from CantorPrereqs.lean. -/
theorem density_iterate_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) (n : Nat) :
    iteratedFuture n (Formula.some_future phi) ∈ M :=
  iterated_future_in_mcs M h_mcs phi h_F n

/-!
## Task 4.4: Large-Step Coverage

The key coverage lemma: when encoding is large enough that pair(p.point_index, k) > n,
and p is in the dovetailed build at step n, then at step pair(p.point_index, k),
p is still in the build and the forward witness is added.
-/

/-- If p is in the build at step n, then p.point_index < list length at step n. -/
theorem point_index_lt_length_of_mem {n : Nat} {p : DovetailedPoint}
    (hp : p ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points) :
    p.point_index < (dovetailedBuildState root_mcs root_mcs_proof n).points.length := by
  have h_inv := dovetailedBuildState_pointIndexInvariant root_mcs root_mcs_proof n
  obtain ⟨i, h_get⟩ := List.mem_iff_get.mp hp
  have h_i_lt := i.isLt
  have h_idx : ((dovetailedBuildState root_mcs root_mcs_proof n).points[i]'h_i_lt).point_index = i := h_inv i h_i_lt
  rw [List.get_eq_getElem] at h_get
  -- h_get : points[↑i] = p
  -- Need: p.point_index < length
  -- From h_idx: points[i].point_index = ↑i, and points[i] = points[↑i] by definition
  have h_p_idx : p.point_index = i := by
    rw [← h_get]
    exact h_idx
  rw [h_p_idx]
  exact h_i_lt

/-- When pair(p.point_index, k) > n and p is in build at step n, p is in build at step pair(p.point_index, k) - 1. -/
theorem point_in_build_before_process_step {n : Nat} {p : DovetailedPoint}
    (hp : p ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points)
    (k : Nat) (h_large : Nat.pair p.point_index k > n) :
    p ∈ (dovetailedBuildState root_mcs root_mcs_proof (Nat.pair p.point_index k - 1)).points := by
  -- pair(p.point_index, k) > n implies pair(p.point_index, k) - 1 >= n
  have h_ge : Nat.pair p.point_index k - 1 ≥ n := by omega
  -- By monotonicity, p is in build at step (pair(...) - 1)
  have h_mem_at_n : p ∈ dovetailedBuild root_mcs root_mcs_proof n := by
    simp only [dovetailedBuild]
    exact List.mem_toFinset.mpr hp
  have h_mem_at_large := dovetailedBuild_monotone_le root_mcs root_mcs_proof h_ge h_mem_at_n
  simp only [dovetailedBuild, List.mem_toFinset] at h_mem_at_large
  exact h_mem_at_large

/-- The main coverage lemma: at step pair(p.point_index, k), if p is in build and F(phi) is in p.mcs
    where phi has encoding k, then a forward witness with CanonicalR is added. -/
theorem witness_at_large_step
    (p : DovetailedPoint) (n : Nat)
    (hp : p ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points)
    (phi : Formula) (h_F : Formula.some_future phi ∈ p.mcs)
    (k : Nat) (h_dec : decodeFormulaStaged k = some phi)
    (h_large : Nat.pair p.point_index k > n) :
    ∃ w ∈ (dovetailedBuildState root_mcs root_mcs_proof (Nat.pair p.point_index k)).points,
      CanonicalR p.mcs w.mcs ∧ phi ∈ w.mcs := by
  -- At step pair(p.point_index, k), we process obligation (p.point_index, k)
  let process_step := Nat.pair p.point_index k
  -- dovetailedBuildState process_step = dovetailedStep (dovetailedBuildState (process_step - 1)) process_step
  have h_step_eq : dovetailedBuildState root_mcs root_mcs_proof process_step =
    dovetailedStep (dovetailedBuildState root_mcs root_mcs_proof (process_step - 1)) process_step := by
    have h_pos : process_step > 0 := by
      calc process_step = Nat.pair p.point_index k := rfl
        _ > n := h_large
        _ ≥ 0 := Nat.zero_le n
    have h_succ : process_step = (process_step - 1) + 1 := by omega
    conv_lhs => rw [h_succ]
    simp only [dovetailedBuildState]
    congr 1
    omega
  -- p is in build at step process_step - 1
  have h_p_before := point_in_build_before_process_step root_mcs root_mcs_proof hp k h_large
  -- By invariant, getPointAt at index p.point_index returns p
  have h_inv := dovetailedBuildState_pointIndexInvariant root_mcs root_mcs_proof (process_step - 1)
  have h_lookup : getPointAt (dovetailedBuildState root_mcs root_mcs_proof (process_step - 1)) p.point_index = some p :=
    getPointAt_of_mem h_inv h_p_before
  -- At step process_step, obligation (p.point_index, k) is processed
  have h_obl_point : (obligationAtStep process_step).point_index = p.point_index :=
    obligationAtStep_point_index p.point_index k
  have h_obl_enc : (obligationAtStep process_step).formula_encoding = k :=
    obligationAtStep_formula_encoding p.point_index k
  -- Use dovetailedStep_adds_witness_when_processed
  have h_adds := dovetailedStep_adds_witness_when_processed
    (dovetailedBuildState root_mcs root_mcs_proof (process_step - 1))
    process_step p phi h_obl_point (h_obl_enc ▸ h_dec) h_lookup h_F
  rw [← h_step_eq] at h_adds
  exact h_adds

/-!
## Combined Coverage: Density + Large Step

The final coverage theorem: for any point p in the timeline with F(phi) in p.mcs,
there exists a witness with CanonicalR in the timeline.
-/

/-- For any point p in the dovetailed timeline at step n, we can find a formula psi
    and encoding k such that:
    1. F(psi) ∈ p.mcs (by density from F(neg bot))
    2. pair(p.point_index, k) > n (so p exists when processed)
    3. A witness with CanonicalR is added -/
theorem density_large_step_exists
    (p : DovetailedPoint) (n : Nat)
    (hp : p ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points) :
    ∃ psi k,
      Formula.some_future psi ∈ p.mcs ∧
      decodeFormulaStaged k = some psi ∧
      Nat.pair p.point_index k > n := by
  -- F(neg bot) is in every MCS by seriality
  have h_F_serial : Formula.some_future (Formula.neg Formula.bot) ∈ p.mcs :=
    SetMaximalConsistent.contains_seriality_future p.mcs p.is_mcs
  -- We need pair(p.point_index, k) > n
  -- pair(a, b) >= a + b, so we need k such that p.point_index + k > n, i.e., k > n - p.point_index
  let target := n + 1  -- Since pair(a, b) >= a + b >= b, we need k >= n + 1 - p.point_index, but safer to use n+1
  -- By iterated_future_encoding_unbounded, there exists i with encoding >= target
  obtain ⟨i, h_enc_ge⟩ := iterated_future_encoding_unbounded target
  -- Let psi = iteratedFuture i (F(neg bot))
  -- F(psi) = F(iteratedFuture i (F(neg bot))) = iteratedFuture (i+1) (F(neg bot)) in p.mcs by density
  let psi := iteratedFuture i (Formula.some_future (Formula.neg Formula.bot))
  have h_F_psi : Formula.some_future psi ∈ p.mcs := by
    have h_iter : iteratedFuture (i + 1) (Formula.some_future (Formula.neg Formula.bot)) ∈ p.mcs :=
      density_iterate_in_mcs p.mcs p.is_mcs (Formula.neg Formula.bot) h_F_serial (i + 1)
    simp only [iteratedFuture] at h_iter
    exact h_iter
  let k := @Encodable.encode Formula formulaEncodableStaged psi
  have h_dec : decodeFormulaStaged k = some psi :=
    @Encodable.encodek Formula formulaEncodableStaged psi
  have h_pair_large : Nat.pair p.point_index k > n := by
    -- pair(p.point_index, k) >= p.point_index + k >= k >= target = n + 1 > n
    have h_k_ge : k ≥ target := h_enc_ge
    have h_pair_ge_sum := pair_ge_add p.point_index k
    omega
  exact ⟨psi, k, h_F_psi, h_dec, h_pair_large⟩

/-- Every point in the dovetailed timeline has a CanonicalR-future that is also in the timeline.
    This is the key theorem for NoMaxOrder on the dovetailed timeline. -/
theorem dovetailedTimeline_has_future
    (p : DovetailedPoint) (hp : p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof) :
    ∃ q : DovetailedPoint,
      q ∈ dovetailedTimelineUnion root_mcs root_mcs_proof ∧
      CanonicalR p.mcs q.mcs := by
  obtain ⟨n, hn⟩ := hp
  simp only [dovetailedBuild, List.mem_toFinset] at hn
  -- Find psi, k with F(psi) in p.mcs and pair(p.point_index, k) > n
  obtain ⟨psi, k, h_F_psi, h_dec, h_large⟩ := density_large_step_exists root_mcs root_mcs_proof p n hn
  -- At step pair(p.point_index, k), a witness is added
  obtain ⟨w, hw_mem, hw_R, _⟩ := witness_at_large_step root_mcs root_mcs_proof p n hn psi h_F_psi k h_dec h_large
  -- w is in the timeline union
  refine ⟨w, ?_, hw_R⟩
  use Nat.pair p.point_index k
  simp only [dovetailedBuild, List.mem_toFinset]
  exact hw_mem

/-!
## Symmetric Past Coverage

The same argument works for P-formulas using `iteratedPast` and backward witnesses.
-/

/-- some_past increases sizeOf. -/
private theorem some_past_sizeOf_lt (phi : Formula) :
    sizeOf phi < sizeOf (Formula.some_past phi) := by
  unfold Formula.some_past Formula.neg
  simp
  omega

/-- iteratedPast increases formula size strictly with n. -/
private theorem iteratedPast_sizeOf_strict_mono (phi : Formula) :
    StrictMono (fun n => sizeOf (iteratedPast n phi)) := by
  intro i j h_lt
  induction h_lt with
  | refl =>
    show sizeOf (iteratedPast i phi) < sizeOf (iteratedPast (i + 1) phi)
    conv_rhs => rw [show iteratedPast (i + 1) phi = Formula.some_past (iteratedPast i phi) from rfl]
    exact some_past_sizeOf_lt (iteratedPast i phi)
  | @step m _ ih =>
    have h_step : sizeOf (iteratedPast m phi) < sizeOf (iteratedPast (m + 1) phi) := by
      conv_rhs => rw [show iteratedPast (m + 1) phi = Formula.some_past (iteratedPast m phi) from rfl]
      exact some_past_sizeOf_lt (iteratedPast m phi)
    exact Nat.lt_trans ih h_step

/-- Iterated pasts are all distinct. -/
theorem iteratedPast_injective (phi : Formula) :
    Function.Injective (fun n => iteratedPast n phi) := by
  intro i j h_eq
  by_contra h_ne
  have h_size_eq : sizeOf (iteratedPast i phi) = sizeOf (iteratedPast j phi) := congrArg sizeOf h_eq
  rcases Nat.lt_trichotomy i j with h_lt | h_eq_ij | h_gt
  · have h_strict : sizeOf (iteratedPast i phi) < sizeOf (iteratedPast j phi) :=
      iteratedPast_sizeOf_strict_mono phi h_lt
    exact Nat.lt_irrefl (sizeOf (iteratedPast j phi)) (h_size_eq ▸ h_strict)
  · exact h_ne h_eq_ij
  · have h_strict : sizeOf (iteratedPast j phi) < sizeOf (iteratedPast i phi) :=
      iteratedPast_sizeOf_strict_mono phi h_gt
    exact Nat.lt_irrefl (sizeOf (iteratedPast i phi)) (h_size_eq.symm ▸ h_strict)

/-- For any bound N, there exists i such that the encoding of iteratedPast i (P(neg bot)) is >= N. -/
theorem iterated_past_encoding_unbounded (N : Nat) :
    ∃ i : Nat,
      @Encodable.encode Formula formulaEncodableStaged
        (iteratedPast i (Formula.some_past (Formula.neg Formula.bot))) ≥ N := by
  by_contra h_all_small
  push_neg at h_all_small
  have h_enc_inj := @Encodable.encode_injective Formula formulaEncodableStaged
  let phi_base := Formula.some_past (Formula.neg Formula.bot)
  let f : Fin (N + 1) → Fin N := fun i =>
    ⟨@Encodable.encode Formula formulaEncodableStaged (iteratedPast i.val phi_base),
     h_all_small i.val⟩
  have h_f_inj : Function.Injective f := by
    intro a b hab
    simp only [f, Fin.mk.injEq] at hab
    have h_formula_eq := h_enc_inj hab
    have h_idx_eq := iteratedPast_injective phi_base h_formula_eq
    exact Fin.ext h_idx_eq
  have h_le := Fintype.card_le_of_injective f h_f_inj
  simp only [Fintype.card_fin] at h_le
  omega

/-- **Generalized encoding unboundedness for past**: For any base formula phi_base and any bound N,
    there exists i such that the encoding of iteratedPast i phi_base is >= N. -/
theorem iterated_past_encoding_unbounded_general (phi_base : Formula) (N : Nat) :
    ∃ i : Nat,
      @Encodable.encode Formula formulaEncodableStaged (iteratedPast i phi_base) ≥ N := by
  by_contra h_all_small
  push_neg at h_all_small
  have h_enc_inj := @Encodable.encode_injective Formula formulaEncodableStaged
  let f : Fin (N + 1) → Fin N := fun i =>
    ⟨@Encodable.encode Formula formulaEncodableStaged (iteratedPast i.val phi_base),
     h_all_small i.val⟩
  have h_f_inj : Function.Injective f := by
    intro a b hab
    simp only [f, Fin.mk.injEq] at hab
    have h_formula_eq := h_enc_inj hab
    have h_idx_eq := iteratedPast_injective phi_base h_formula_eq
    exact Fin.ext h_idx_eq
  have h_le := Fintype.card_le_of_injective f h_f_inj
  simp only [Fintype.card_fin] at h_le
  omega

/-- P(phi) in M implies P^n(P(phi)) in M for all n. -/
theorem density_iterate_past_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) (n : Nat) :
    iteratedPast n (Formula.some_past phi) ∈ M :=
  iterated_past_in_mcs M h_mcs phi h_P n

/-- When P(phi) is in point.mcs, processBackwardObligationDovetailed adds a witness. -/
theorem processBackwardObligationDovetailed_adds_witness
    (state : DovetailedBuildState) (point : DovetailedPoint) (phi : Formula) (stage : Nat)
    (h_P : Formula.some_past phi ∈ point.mcs) :
    ∃ w ∈ (processBackwardObligationDovetailed state point phi stage).points,
      CanonicalR w.mcs point.mcs ∧ phi ∈ w.mcs := by
  simp only [processBackwardObligationDovetailed, dif_pos h_P, addPoint]
  refine ⟨DovetailedPoint.mk (executeBackwardStep point.mcs point.is_mcs phi h_P)
    executeBackwardStep_mcs stage state.next_index, ?_, ?_, ?_⟩
  · simp only [List.mem_append, List.mem_singleton, or_true]
  · exact executeBackwardStep_canonicalR (h_mcs := point.is_mcs) (h_P := h_P)
  · exact executeBackwardStep_contains_phi (h_mcs := point.is_mcs) (h_P := h_P)

/-- At step pair(p_idx, f_enc), if p_idx is valid and f decodes to phi with P(phi) in point.mcs,
    then a backward witness with CanonicalR is added. -/
theorem dovetailedStep_adds_backward_witness_when_processed
    (state : DovetailedBuildState) (step : Nat) (point : DovetailedPoint) (phi : Formula)
    (h_obl_point : (obligationAtStep step).point_index = point.point_index)
    (h_obl_phi : decodeFormulaStaged (obligationAtStep step).formula_encoding = some phi)
    (h_lookup : getPointAt state point.point_index = some point)
    (h_P : Formula.some_past phi ∈ point.mcs) :
    ∃ w ∈ (dovetailedStep state step).points,
      CanonicalR w.mcs point.mcs ∧ phi ∈ w.mcs := by
  simp only [dovetailedStep]
  simp only [h_obl_point, h_lookup, h_obl_phi]
  unfold processObligationsDovetailed
  -- The backward witness is added by processBackwardObligationDovetailed
  let state' := processForwardObligationDovetailed state point phi step
  have h_bwd := processBackwardObligationDovetailed_adds_witness state' point phi step h_P
  obtain ⟨w, hw_mem, hw_R, hw_phi⟩ := h_bwd
  use w
  constructor
  · exact processDensityDovetailed_monotone _ point phi step hw_mem
  · exact ⟨hw_R, hw_phi⟩

/-- Backward witness at large step. -/
theorem backward_witness_at_large_step
    (p : DovetailedPoint) (n : Nat)
    (hp : p ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points)
    (phi : Formula) (h_P : Formula.some_past phi ∈ p.mcs)
    (k : Nat) (h_dec : decodeFormulaStaged k = some phi)
    (h_large : Nat.pair p.point_index k > n) :
    ∃ w ∈ (dovetailedBuildState root_mcs root_mcs_proof (Nat.pair p.point_index k)).points,
      CanonicalR w.mcs p.mcs ∧ phi ∈ w.mcs := by
  let process_step := Nat.pair p.point_index k
  have h_step_eq : dovetailedBuildState root_mcs root_mcs_proof process_step =
    dovetailedStep (dovetailedBuildState root_mcs root_mcs_proof (process_step - 1)) process_step := by
    have h_pos : process_step > 0 := Nat.lt_of_lt_of_le (Nat.zero_lt_succ n) h_large
    have h_succ : process_step = (process_step - 1) + 1 := by omega
    conv_lhs => rw [h_succ]
    simp only [dovetailedBuildState]
    congr 1
    omega
  have h_p_before := point_in_build_before_process_step root_mcs root_mcs_proof hp k h_large
  have h_inv := dovetailedBuildState_pointIndexInvariant root_mcs root_mcs_proof (process_step - 1)
  have h_lookup : getPointAt (dovetailedBuildState root_mcs root_mcs_proof (process_step - 1)) p.point_index = some p :=
    getPointAt_of_mem h_inv h_p_before
  have h_obl_point : (obligationAtStep process_step).point_index = p.point_index :=
    obligationAtStep_point_index p.point_index k
  have h_obl_enc : (obligationAtStep process_step).formula_encoding = k :=
    obligationAtStep_formula_encoding p.point_index k
  have h_adds := dovetailedStep_adds_backward_witness_when_processed
    (dovetailedBuildState root_mcs root_mcs_proof (process_step - 1))
    process_step p phi h_obl_point (h_obl_enc ▸ h_dec) h_lookup h_P
  rw [← h_step_eq] at h_adds
  exact h_adds

/-- Density-based large step existence for past. -/
theorem density_large_step_exists_past
    (p : DovetailedPoint) (n : Nat)
    (hp : p ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points) :
    ∃ psi k,
      Formula.some_past psi ∈ p.mcs ∧
      decodeFormulaStaged k = some psi ∧
      Nat.pair p.point_index k > n := by
  have h_P_serial : Formula.some_past (Formula.neg Formula.bot) ∈ p.mcs :=
    SetMaximalConsistent.contains_seriality_past p.mcs p.is_mcs
  let target := n + 1
  obtain ⟨i, h_enc_ge⟩ := iterated_past_encoding_unbounded target
  let psi := iteratedPast i (Formula.some_past (Formula.neg Formula.bot))
  have h_P_psi : Formula.some_past psi ∈ p.mcs := by
    have h_iter : iteratedPast (i + 1) (Formula.some_past (Formula.neg Formula.bot)) ∈ p.mcs :=
      density_iterate_past_in_mcs p.mcs p.is_mcs (Formula.neg Formula.bot) h_P_serial (i + 1)
    simp only [iteratedPast] at h_iter
    exact h_iter
  let k := @Encodable.encode Formula formulaEncodableStaged psi
  have h_dec : decodeFormulaStaged k = some psi :=
    @Encodable.encodek Formula formulaEncodableStaged psi
  have h_pair_large : Nat.pair p.point_index k > n := by
    have h_k_ge : k ≥ target := h_enc_ge
    have h_pair_ge_sum := pair_ge_add p.point_index k
    omega
  exact ⟨psi, k, h_P_psi, h_dec, h_pair_large⟩

/-- Every point in the dovetailed timeline has a CanonicalR-past that is also in the timeline.
    This is the key theorem for NoMinOrder on the dovetailed timeline. -/
theorem dovetailedTimeline_has_past
    (p : DovetailedPoint) (hp : p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof) :
    ∃ q : DovetailedPoint,
      q ∈ dovetailedTimelineUnion root_mcs root_mcs_proof ∧
      CanonicalR q.mcs p.mcs := by
  obtain ⟨n, hn⟩ := hp
  simp only [dovetailedBuild, List.mem_toFinset] at hn
  obtain ⟨psi, k, h_P_psi, h_dec, h_large⟩ := density_large_step_exists_past root_mcs root_mcs_proof p n hn
  obtain ⟨w, hw_mem, hw_R, _⟩ := backward_witness_at_large_step root_mcs root_mcs_proof p n hn psi h_P_psi k h_dec h_large
  refine ⟨w, ?_, hw_R⟩
  use Nat.pair p.point_index k
  simp only [dovetailedBuild, List.mem_toFinset]
  exact hw_mem

end Bimodal.Metalogic.StagedConstruction.DovetailedCoverage
