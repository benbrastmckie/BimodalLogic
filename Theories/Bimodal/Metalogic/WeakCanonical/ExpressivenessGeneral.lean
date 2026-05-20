import Bimodal.Metalogic.WeakCanonical.EFGames

/-!
# GHR93 Theorem 6: Forward-to-Backward Game Transfer

This file contains Theorem 6 from GHR93 (Gabbay, Hodkinson, Reynolds, 1994),
Chapter 9, Section 8: the forward-to-backward theorem for custom EF games.

## Statement

(*)_n: For all n, r: if Duplicator wins G_{1+3n; r}(M, xy; N, x'y'),
then she wins G_{n; r}(N, x'y'; M, xy).

This is stated at a uniform rank r for both games. The full GHR93 statement
uses rank r+4n for the forward game and rank r for the backward game;
that version requires an embedding between ExtendedCarrier types at
different ranks. This uniform-rank version suffices when combined with
Lemma 10 (round monotonicity).

## References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Theorem 6
- Task 155 plan: Phase 4C, Task 4C.1
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Symmetry of the Winning Condition -/

/-- The winning condition is symmetric: swapping the tuples (and structures)
    preserves it. -/
theorem ghr93_winning_condition_symm {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {n : Nat}
    {tM : Fin (n + 3) → ExtendedCarrier M atomMap r}
    {tN : Fin (n + 3) → ExtendedCarrier N atomMap r}
    (h : ghr93_winning_condition n tM tN) :
    ghr93_winning_condition n tN tM := by
  obtain ⟨hord, hgp, hform⟩ := h
  refine ⟨?_, ?_, ?_⟩
  · intro i j; exact ⟨(hord i j).1.symm, (hord i j).2.symm⟩
  · intro i; exact ⟨(hgp i).1.symm, (hgp i).2.symm⟩
  · intro i A hA; exact (hform i A hA).symm

/-! ## Base Case Helper: Embedding 0-Game into 1-Game Tuples

For the base case of Theorem 6, we need to relate game_tuples for the
0-game (3 indices: x, b, y) to game_tuples for the 1-game (4 indices:
x, a(0), b_resp, y). The 0-game indices {0, 1, 2} map to 1-game indices
{0, 1, 3} respectively. -/

/-- Embedding from 0-game indices (Fin 3) to 1-game indices (Fin 4). -/
private def base_case_emb : Fin 3 → Fin 4 := fun k =>
  if k.val = 0 then ⟨0, by omega⟩
  else if k.val = 1 then ⟨1, by omega⟩
  else ⟨3, by omega⟩

/-- The M-side game_tuple for the 0-game at index k equals the M-side
    game_tuple for the 1-game (with constant selection) at the embedded index. -/
private theorem base_case_M_eq {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (x y : ExtendedCarrier M atomMap r) (b_sp : M.carrier) (b_resp : M.carrier)
    (k : Fin 3) :
    game_tuple x y Fin.elim0 b_sp k =
    game_tuple x y (fun _ : Fin 1 => extendPoint b_sp) b_resp (base_case_emb k) := by
  simp only [game_tuple, base_case_emb]
  have hk := k.isLt
  by_cases h0 : k.val = 0
  · simp [h0]
  · by_cases h1 : k.val = 1
    · simp [h1, show ¬(1 : Nat) = 0 from by omega,
            show ¬(1 : Nat) = 1 + 1 from by omega,
            show ¬(1 : Nat) = 1 + 2 from by omega]
    · -- k = 2 -> emb(k) = 3
      have hk2 : k.val = 2 := by omega
      simp [hk2, show ¬(2 : Nat) = 0 from by omega,
            show ¬(2 : Nat) = 1 from by omega]

/-- The N-side game_tuple for the 0-game at index k equals the N-side
    game_tuple for the 1-game at the embedded index, given that the
    selection a'_resp(0) equals extendPoint q. -/
private theorem base_case_N_eq {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (x' y' : ExtendedCarrier N atomMap r) (q : N.carrier) (p : N.carrier)
    (a'_resp : Fin 1 → ExtendedCarrier N atomMap r)
    (hq_eq : a'_resp ⟨0, by omega⟩ = extendPoint q)
    (k : Fin 3) :
    game_tuple x' y' Fin.elim0 q k =
    game_tuple x' y' a'_resp p (base_case_emb k) := by
  simp only [game_tuple, base_case_emb]
  have hk := k.isLt
  by_cases h0 : k.val = 0
  · simp [h0]
  · by_cases h1 : k.val = 1
    · simp [h1, show ¬(1 : Nat) = 0 from by omega,
            show ¬(1 : Nat) = 1 + 1 from by omega,
            show ¬(1 : Nat) = 1 + 2 from by omega]
      exact hq_eq.symm
    · have hk2 : k.val = 2 := by omega
      simp [hk2, show ¬(2 : Nat) = 0 from by omega,
            show ¬(2 : Nat) = 1 from by omega]

/-! ## GHR93 Theorem 6: Forward-to-Backward Transfer -/

/-- **GHR93 Theorem 6** (Forward-to-backward transfer, uniform rank version):
    (*)_n: If Duplicator wins G_{1+3n; r}(M, xy; N, x'y'),
    then she wins G_{n; r}(N, x'y'; M, xy).

    The hypothesis `h_pt` requires that [x',y'] contains an actual point
    from N. This is needed for the base case to trigger Round 2 of the
    forward game and extract a matching point.

    The proof is by induction on n. The base case (n=0) uses the 1-round
    forward strategy with the Spoiler's point as the selection, extracts
    a matching point via gap_point_agreement, and transfers the winning
    condition via the base_case embedding. The inductive step is sorry'd
    for Phase 4C.2-4C.7. -/
theorem ghr93_forward_to_backward {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n r : Nat)
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y') :
    ghr93_duplicator_wins N M atomMap n r x' y' x y := by
  induction n with
  | zero =>
    -- Base case: G_{1;r}(M,xy;N,x'y') → G_{0;r}(N,x'y';M,xy)
    simp only [Nat.mul_zero, Nat.add_zero] at h
    unfold ghr93_duplicator_wins at h ⊢
    intro a_bwd _ha_bwd
    refine ⟨Fin.elim0, fun i => Fin.elim0 i, ?_⟩
    intro b_sp hb_sp
    -- Apply forward 1-game with selection = extendPoint b_sp
    obtain ⟨a'_resp, ha'_resp, hwin_fwd⟩ :=
      h (fun _ : Fin 1 => extendPoint b_sp) (fun _ => hb_sp)
    -- Trigger Round 2 with witness point p from N ∩ [x',y']
    obtain ⟨p, hp⟩ := h_pt
    obtain ⟨b_resp, _, hcond_fwd⟩ := hwin_fwd p hp
    -- Extract gap_point_agreement at index 1 (the selection position)
    obtain ⟨hord_fwd, hgp_fwd, hform_fwd⟩ := hcond_fwd
    have hgp1 := hgp_fwd ⟨1, by omega⟩
    simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
               show ¬(1 : Nat) = 1 + 1 from by omega,
               show ¬(1 : Nat) = 1 + 2 from by omega, dite_false] at hgp1
    -- a'_resp(0) is a point (since extendPoint b_sp is a point)
    obtain ⟨q, hq_eq⟩ := hgp1.1.mp ⟨b_sp, rfl⟩
    have hq_in : inClosedInterval x' y' (extendPoint q) := by
      have := ha'_resp ⟨0, by omega⟩
      rwa [show extendPoint q = a'_resp ⟨0, by omega⟩ from hq_eq.symm]
    refine ⟨q, hq_in, ?_⟩
    -- Transfer winning condition from 1-game to 0-game via embedding
    -- Use game_tuple_zero_eq to normalize the a_bwd function
    rw [show a_bwd = Fin.elim0 from funext (fun i => Fin.elim0 i)]
    -- The backward 0-game winning condition at (N, M) follows from
    -- the forward 1-game winning condition at (M, N) restricted to
    -- the embedded indices, with Iff direction swapped (symmetry).
    refine ⟨?_, ?_, ?_⟩
    · -- same_order_type 0: transfer via embedding + symmetry
      intro i j
      rw [base_case_M_eq x y b_sp b_resp i, base_case_M_eq x y b_sp b_resp j,
          base_case_N_eq x' y' q p a'_resp hq_eq i,
          base_case_N_eq x' y' q p a'_resp hq_eq j]
      exact ⟨(hord_fwd _ _).1.symm, (hord_fwd _ _).2.symm⟩
    · -- gap_point_agreement 0: transfer via embedding + symmetry
      intro i
      rw [base_case_M_eq x y b_sp b_resp i,
          base_case_N_eq x' y' q p a'_resp hq_eq i]
      exact ⟨(hgp_fwd _).1.symm, (hgp_fwd _).2.symm⟩
    · -- formula_agreement 0: transfer via embedding + symmetry
      intro i A hA
      rw [base_case_M_eq x y b_sp b_resp i,
          base_case_N_eq x' y' q p a'_resp hq_eq i]
      exact (hform_fwd _ A hA).symm
  | succ n _ih =>
    -- Inductive step: (*)_n → (*)_{n+1}
    -- Given: Duplicator wins G_{4+3n; r}(M, xy; N, x'y')
    -- Goal: Duplicator wins G_{n+1; r}(N, x'y'; M, xy)
    -- This is the heart of the GHR93 proof with 4 cases:
    --   Case I: a_0 < d (the "split" case)
    --   Case II: a_n is a point
    --   Case III: a_n is a left-defined gap
    --   Case IV: a_n is a gap, not left-defined
    -- Sorry'd for Phase 4C.2-4C.7.
    sorry

end Bimodal.Metalogic.WeakCanonical
