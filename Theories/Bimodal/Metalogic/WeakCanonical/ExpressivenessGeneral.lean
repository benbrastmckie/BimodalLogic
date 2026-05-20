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

/-! ## GHR93 Theorem 6: Inductive Step Infrastructure

The inductive step of Theorem 6 converts a forward (4+3n)-round strategy
into a backward (n+1)-round strategy. The proof introduces key quantities
from the GHR93 argument:

- **d**: A "split point" in N_r that separates the interval [x',y'] based on
  where the forward strategy's type pattern changes. Formally, d is defined
  using the interval type A = X_{(a_{n-1}, a_n)} and a continuation formula C.

- **c**: The corresponding split point in M_r, obtained by applying the
  forward strategy to d.

- **σ, τ**: Backward strategies on sub-intervals [x',d]/[x,c] and
  [d,y']/[c,y], obtained by restricting the master forward strategy and
  applying the inductive hypothesis (*)_n.

The proof then splits into four cases based on the nature of a_n (Spoiler's
last selection in the backward game). -/

/-- Properties of the split points c, d that are needed for the case analysis.

    These encapsulate the key facts established in the GHR93 proof about
    the relationship between c, d, the forward strategy, and the IH.
    All properties are sorry'd pending the full infimum/strategy-restriction
    infrastructure.

    The record bundles:
    - Interval containment: d ∈ [x',y'], c ∈ [x,y]
    - Position bound: d ≤ a_n (Spoiler's last pick is past the split)
    - Sub-interval backward strategies σ, τ from the IH -/
structure SplitPointProps {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (n : Nat)
    (x y : ExtendedCarrier M atomMap r)
    (x' y' : ExtendedCarrier N atomMap r)
    (c : ExtendedCarrier M atomMap r)
    (d : ExtendedCarrier N atomMap r)
    (a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r) where
  /-- c is in [x, y] -/
  hc_interval : inClosedInterval x y c
  /-- d is in [x', y'] -/
  hd_interval : inClosedInterval x' y' d
  /-- The split point d is at or below a_n -/
  hd_le_an : d ≤ a_bwd ⟨n, by omega⟩
  /-- x ≤ c (for sub-interval well-formedness) -/
  hxc : x ≤ c
  /-- c ≤ y (for sub-interval well-formedness) -/
  hcy : c ≤ y
  /-- x' ≤ d (for sub-interval well-formedness) -/
  hx'd : x' ≤ d
  /-- d ≤ y' (for sub-interval well-formedness) -/
  hdy' : d ≤ y'
  /-- Backward strategy σ on the left sub-interval:
      Duplicator wins G_{n;r}(N, x'd; M, xc) -/
  sigma : ghr93_duplicator_wins N M atomMap n r x' d x c
  /-- Backward strategy τ on the right sub-interval:
      Duplicator wins G_{n;r}(N, dy'; M, cy) -/
  tau : ghr93_duplicator_wins N M atomMap n r d y' c y

/-- Obtain the split point properties. This is the core setup lemma for
    the inductive step, combining infimum computation, strategy restriction,
    and IH application.

    Sorry'd: requires infimum infrastructure on ExtendedCarrier and
    strategy restriction lemmas (restricting a forward G_{4+3n;r} strategy
    to sub-intervals and applying the IH to get backward strategies). -/
private theorem obtain_split_point_props {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (_h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (_ih : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y' →
           ghr93_duplicator_wins N M atomMap n r x' y' x y)
    (h_fwd : ghr93_duplicator_wins M N atomMap (4 + 3 * n) r x y x' y')
    (a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r)
    (_ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i)) :
    ∃ (c : ExtendedCarrier M atomMap r) (d : ExtendedCarrier N atomMap r),
      SplitPointProps n x y x' y' c d a_bwd := by
  -- The full construction:
  -- 1. Compute A = X_{(a_{n-1}, a_n)} (interval type before a_n)
  -- 2. Define C from A (continuation formula)
  -- 3. d = inf{t ∈ [x',y'] : C holds on (t,y') in N_r}
  -- 4. c = the point in M_r that the forward strategy maps d to
  -- 5. Restrict the forward strategy to [x,c] and [c,y]
  -- 6. Apply IH to get σ and τ
  --
  -- Requires: infimum computation on ExtendedCarrier, strategy restriction,
  -- and the IH for sub-interval strategies.
  --
  -- For now, use x and x' as trivial split points to establish the
  -- type-level structure. The properties are sorry'd.
  refine ⟨x, x', ?_⟩
  exact {
    hc_interval := ⟨le_refl x, hxy⟩
    hd_interval := ⟨le_refl x', hx'y'⟩
    hd_le_an := by sorry
    hxc := le_refl x
    hcy := hxy
    hx'd := le_refl x'
    hdy' := hx'y'
    sigma := by sorry
    tau := by sorry
  }

/-! ### Case I: The Split Case

When at least one of Spoiler's backward selections a_0,...,a_n lies below
the split point d, Duplicator uses a "split" strategy: she applies the
backward strategy σ (on [x',d]/[x,c]) to selections below d, and the
backward strategy τ (on [d,y']/[c,y]) to selections above d. The responses
are combined into a single (n+1)-element response.

This is the simplest case because it doesn't construct new StaviFormulas.
It reduces to combining two backward strategies, each of which was obtained
from the IH.

Note: In Case I, the "split" means we partition the n+1 selections into
those ≤ d (at most n of them) and those > d (at most n of them). Since
σ and τ each handle n-round backward games, and at most n elements fall
on each side, round monotonicity (Lemma 10) allows the sub-strategies to
handle their portions. -/

/-- **Case I helper**: Given backward strategies σ on [x',d]/[x,c] and
    τ on [d,y']/[c,y], if Spoiler's n+1 selections split across d
    (at least one below d and at least one at or above d), construct
    Duplicator's combined response.

    The key insight is that among n+1 selections, if some are below d
    and some are at or above d, then each side has at most n selections.
    Since σ and τ handle n-round games, round monotonicity applies.

    Sorry'd: The combination of σ and τ responses requires careful index
    manipulation to merge two partial responses into a single (n+1)-element
    response while preserving order type, gap/point agreement, and formula
    agreement. This is the content of Phase 4C.3. -/
private theorem ghr93_case_I {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n x y x' y' c d a_bwd)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i))
    (h_split : ∃ i : Fin (n + 1), a_bwd i < d) :
    ∃ (a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a'_resp i)) ∧
      ∀ (b_sp : M.carrier),
        inClosedInterval x y (extendPoint b_sp) →
        ∃ (b_resp : N.carrier),
          inClosedInterval x' y' (extendPoint b_resp) ∧
          ghr93_winning_condition (n + 1)
            (game_tuple x' y' a_bwd b_resp)
            (game_tuple x y a'_resp b_sp) := by
  -- Case I proof sketch (GHR93):
  -- 1. Partition a_bwd into L = {i : a_bwd i < d} and R = {i : a_bwd i ≥ d}
  -- 2. |L| ≤ n and |R| ≤ n (since |L| + |R| = n+1 and both are non-empty)
  -- 3. Apply σ to the L-elements (padded to n elements) to get responses in [x,c]
  -- 4. Apply τ to the R-elements (padded to n elements) to get responses in [c,y]
  -- 5. Merge the responses preserving order
  -- 6. For Round 2: if b_sp ∈ [x,c], use σ's Round 2 handler;
  --                  if b_sp ∈ [c,y], use τ's Round 2 handler
  -- 7. Verify the combined winning condition
  --
  -- The main technical challenge is the index manipulation for merging
  -- two partial selections into one (n+1)-element response, and showing
  -- that the merged response satisfies the winning condition by combining
  -- the individual winning conditions from σ and τ.
  sorry

/-! ### Cases II-IV: Tail Cases

When ALL of Spoiler's backward selections a_0,...,a_n lie in (d,y'),
the proof depends on the nature of a_n (the last selection):

- **Case II** (a_n is a point): Use standard Until U(B, A) where
  B = X_{a_n} is the type at a_n. Duplicator finds a matching point
  in M via the Until witness.

- **Case III** (a_n is a left-defined gap): Use Stavi Until U'(B, A)
  via the gap detection formula left(B, D). Duplicator finds a matching
  gap in M via Lemma 9.

- **Case IV** (a_n is a gap not left-defined): Use right(B, D) gap
  detection. Duplicator finds a matching gap in M defined on the right.

These cases are sorry'd for Phase 4C.4-4C.6. -/

/-- **Cases II-IV helper**: When all selections lie in (d,y'), construct
    Duplicator's response based on the nature of a_n.

    Sorry'd for Phase 4C.4-4C.6. -/
private theorem ghr93_cases_II_III_IV {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n x y x' y' c d a_bwd)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i))
    (h_no_split : ∀ i : Fin (n + 1), d ≤ a_bwd i) :
    ∃ (a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a'_resp i)) ∧
      ∀ (b_sp : M.carrier),
        inClosedInterval x y (extendPoint b_sp) →
        ∃ (b_resp : N.carrier),
          inClosedInterval x' y' (extendPoint b_resp) ∧
          ghr93_winning_condition (n + 1)
            (game_tuple x' y' a_bwd b_resp)
            (game_tuple x y a'_resp b_sp) := by
  -- Case II:  IsPoint (a_bwd ⟨n, by omega⟩) → use Until U(B, A)
  -- Case III: IsGap (a_bwd ⟨n, by omega⟩) ∧ (left-defined) → use left(B, D)
  -- Case IV:  IsGap (a_bwd ⟨n, by omega⟩) ∧ (not left-defined) → use right(B, D)
  sorry

/-! ### Assembly: The Inductive Step -/

/-- **GHR93 Theorem 6, inductive step**: combines the setup (split points
    c, d and sub-interval strategies σ, τ) with the 4-case analysis.

    This theorem is factored out of `ghr93_forward_to_backward` to keep
    the main proof clean and allow each case to be addressed independently. -/
private theorem ghr93_inductive_step {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n r : Nat)
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (ih : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y' →
          ghr93_duplicator_wins N M atomMap n r x' y' x y)
    (h_fwd : ghr93_duplicator_wins M N atomMap (4 + 3 * n) r x y x' y') :
    ghr93_duplicator_wins N M atomMap (n + 1) r x' y' x y := by
  -- Unfold the backward game
  unfold ghr93_duplicator_wins
  intro a_bwd ha_bwd
  -- Obtain split points c, d and their properties
  obtain ⟨c, d, props⟩ :=
    obtain_split_point_props hxy hx'y' h_pt ih h_fwd a_bwd ha_bwd
  -- Case split: does any selection fall strictly below d?
  by_cases h_split : ∃ i : Fin (n + 1), a_bwd i < d
  · -- Case I: at least one selection below d (the "split" case)
    exact ghr93_case_I props ha_bwd h_split
  · -- Cases II-IV: all selections are at or above d
    push_neg at h_split
    exact ghr93_cases_II_III_IV props ha_bwd h_split

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
    condition via the base_case embedding. The inductive step delegates to
    `ghr93_inductive_step`, which establishes split points c (in M_r) and
    d (in N_r), obtains sub-interval backward strategies σ and τ via the
    IH, and splits into four cases:
      Case I:   ∃ i, a_i < d (split case — sorry'd, Phase 4C.3)
      Case II:  all a_i ≥ d, a_n is a point (sorry'd, Phase 4C.4)
      Case III: all a_i ≥ d, a_n is a left-defined gap (sorry'd, Phase 4C.5)
      Case IV:  all a_i ≥ d, a_n is a gap not left-defined (sorry'd, Phase 4C.6) -/
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
    --
    -- GHR93 Theorem 6 proof structure:
    --   Setup: Define A (interval type), C (continuation formula),
    --          c (infimum in M), d (infimum in N),
    --          σ (backward strategy on [x,c]), τ (backward strategy on [c,y])
    --   Case I:   ∃ i, a_i < d (the "split" case)
    --   Case II:  all a_i in [d,y'], a_n is a point
    --   Case III: all a_i in [d,y'], a_n is a left-defined gap
    --   Case IV:  all a_i in [d,y'], a_n is a gap not left-defined
    --
    -- Note: 1 + 3 * (n + 1) = 4 + 3 * n
    have h_rounds : 1 + 3 * (n + 1) = 4 + 3 * n := by omega
    rw [h_rounds] at h
    -- Apply the inductive step helper to keep the proof organized
    exact ghr93_inductive_step atomMap n r hxy hx'y' h_pt _ih h

/-! ## Rank-Varying Theorem 6

The full GHR93 statement of Theorem 6 uses different ranks for the forward
and backward games: the forward game uses rank r+4n, the backward game
uses rank r. With rank_embed now available, we can state this version.

The positions x, y, x', y' live at rank r (the backward game's rank).
The forward game plays at rank r+4n, so we embed these positions via
rank_embed (by omega : r ≤ r+4n).

This version is derived from the uniform-rank version by pre-composing
with round monotonicity (Lemma 10) and rank embedding. -/

/-- **GHR93 Theorem 6** (Forward-to-backward transfer, rank-varying version):
    If Duplicator wins G_{1+3n; r+4n}(M, xy; N, x'y') on the rank-(r+4n)
    extended carriers, then she wins G_{n; r}(N, x'y'; M, xy) on the
    rank-r extended carriers.

    The positions are given at rank r and embedded to rank r+4n via
    rank_embed for the forward game hypothesis. -/
theorem ghr93_forward_to_backward_rank_varying {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n r : Nat)
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 4 * n)
           (rank_embed (by omega : r ≤ r + 4 * n) x)
           (rank_embed (by omega : r ≤ r + 4 * n) y)
           (rank_embed (by omega : r ≤ r + 4 * n) x')
           (rank_embed (by omega : r ≤ r + 4 * n) y')) :
    ghr93_duplicator_wins N M atomMap n r x' y' x y := by
  -- Use the uniform-rank version at rank r+4n, then transport back to rank r.
  -- Step 1: Apply the uniform-rank Theorem 6 at rank r+4n.
  -- Step 2: The result gives a backward strategy at rank r+4n.
  -- Step 3: Transport the backward strategy back to rank r using rank_embed properties.
  -- For now, this is sorry'd pending the full inductive step proof.
  sorry

end Bimodal.Metalogic.WeakCanonical
