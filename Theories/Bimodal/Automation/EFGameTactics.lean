import Bimodal.Metalogic.WeakCanonical.EFGames.CustomGame
import Lean

/-!
# EF Game Automation Tactics

Custom tactics for automating repetitive proof patterns in the EF game
infrastructure (GHR93 expressive completeness proof).

## Components

- **Component B**: `simp_game_tuple` — simp rewrite set for game_tuple normalization
- **Component C**: `pivot_order` — auto-fill interval bounds for pivot_chain_order
- **Component D**: `winning_condition_tac` — 4-way index split for gap_point/formula agreement
- **Component A**: `same_order_type_grid` — N×N grid dispatch for same_order_type

## References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Section 8
- Task 195: EF Game Automation Tactics
-/

namespace Bimodal.Metalogic.WeakCanonical

open Lean Elab Tactic
open Bimodal.Syntax

/-! ## Component B: game_tuple_simp -/

/-- `simp_game_tuple` simplifies `game_tuple` expressions using the four
    index-category lemmas: `game_tuple_zero_eq`, `game_tuple_b_eq`,
    `game_tuple_y_eq`, `game_tuple_sel_eq`.

    Usage:
    - `simp_game_tuple` — simplify the goal
    - `simp_game_tuple at h` — simplify hypothesis `h`
    - `simp_game_tuple at h1 h2` — simplify multiple hypotheses
    - `simp_game_tuple at *` — simplify goal and all hypotheses -/
macro "simp_game_tuple" loc:(Lean.Parser.Tactic.location)? : tactic =>
  match loc with
  | some loc =>
    `(tactic| simp only [game_tuple_zero_eq, game_tuple_b_eq,
        game_tuple_y_eq, game_tuple_sel_eq] $loc)
  | none =>
    `(tactic| simp only [game_tuple_zero_eq, game_tuple_b_eq,
        game_tuple_y_eq, game_tuple_sel_eq])

/-- `game_tuple_unfold` unfolds game_tuple via its definition (using dite)
    and resolves the conditional branches with `split_ifs` and `omega`.

    Usage:
    - `game_tuple_unfold` — unfold in the goal
    - `game_tuple_unfold at h` — unfold in hypothesis `h` -/
macro "game_tuple_unfold" loc:(Lean.Parser.Tactic.location)? : tactic =>
  match loc with
  | some loc =>
    `(tactic| (simp only [game_tuple] $loc; split_ifs <;> try omega))
  | none =>
    `(tactic| (simp only [game_tuple]; split_ifs <;> try omega))

-- Note: For compound index expressions like `⟨1+n, ...⟩` where `n` is a
-- variable, `simp_game_tuple` cannot fire because `game_tuple_sel_eq` requires
-- `k : Fin n` which can't unify with raw arithmetic. Use `game_tuple_sel_nat_eq`
-- from EFGames.lean directly, or manually unfold `game_tuple` and resolve the
-- dite conditions:
--
--   simp only [game_tuple, show (1+n:Nat) ≠ 0 from by omega,
--     show ¬((1+n:Nat) = m+1) from by omega, ...
--     dite_false, dite_true, show 1+n-1=n from by omega] at h

/-! ## Component C: pivot_order -/

/-- `pivot_chain_order'` is a convenience wrapper around `pivot_chain_order` that
    takes the left and right ordering witnesses as pairs rather than as 4
    separate arguments. This matches the natural shape of hypotheses extracted
    from `same_order_type` sub-game results.

    Instead of:
    ```
    exact pivot_chain_order hap hpb ha'q hqb' hord_l.1 hord_l.2 hord_r.1 hord_r.2
    ```
    Write:
    ```
    exact pivot_chain_order' hap hpb ha'q hqb' hord_l hord_r
    ``` -/
theorem pivot_chain_order' {α β : Type*} [LinearOrder α] [LinearOrder β]
    {a p b : α} {a' q b' : β}
    (hap : a ≤ p) (hpb : p ≤ b) (ha'q : a' ≤ q) (hqb' : q ≤ b')
    (hord_l : (a < p ↔ a' < q) ∧ (a = p ↔ a' = q))
    (hord_r : (p < b ↔ q < b') ∧ (p = b ↔ q = b')) :
    (a < b ↔ a' < b') ∧ (a = b ↔ a' = b') :=
  pivot_chain_order hap hpb ha'q hqb' hord_l.1 hord_l.2 hord_r.1 hord_r.2

/-- `pivot_chain_order_rev'` is a convenience wrapper around `pivot_chain_order_rev`
    that takes the ordering witnesses as pairs. -/
theorem pivot_chain_order_rev' {α β : Type*} [LinearOrder α] [LinearOrder β]
    {a p b : α} {a' q b' : β}
    (hpa : p ≤ a) (hbp : b ≤ p) (hqa' : q ≤ a') (hb'q : b' ≤ q)
    (hord_l : (p < a ↔ q < a') ∧ (p = a ↔ q = a'))
    (hord_r : (b < p ↔ b' < q) ∧ (b = p ↔ b' = q)) :
    (a < b ↔ a' < b') ∧ (a = b ↔ a' = b') :=
  pivot_chain_order_rev hpa hbp hqa' hb'q hord_l.1 hord_l.2 hord_r.1 hord_r.2

/-- `order_refl` closes goals of the form
    `(a < a ↔ b < b) ∧ (a = a ↔ b = b)` — the diagonal case in the
    same_order_type grid where both indices refer to the same element. -/
theorem order_refl_pair {α β : Type*} [Preorder α] [Preorder β] (a : α) (b : β) :
    (a < a ↔ b < b) ∧ (a = a ↔ b = b) :=
  ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
   ⟨fun _ => rfl, fun _ => rfl⟩⟩

/-- `order_refl` tactic closes goals of the form
    `(a < a ↔ b < b) ∧ (a = a ↔ b = b)`. -/
macro "order_refl" : tactic =>
  `(tactic| exact order_refl_pair _ _)

/-! ## Component D: winning_condition_tac -/

/-- Helper lemma for gap_point_agreement proofs: dispatch a 4-way case split
    over game_tuple indices. Given agreement facts for x (index 0),
    b (index n+1), y (index n+2), and selection indices, proves
    gap_point_agreement for the full game tuple. -/
theorem gap_point_agreement_of_cases {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {n : Nat}
    {x y : ExtendedCarrier M atomMap r} {a : Fin n → ExtendedCarrier M atomMap r}
    {b_M : M.carrier}
    {x' y' : ExtendedCarrier N atomMap r} {a' : Fin n → ExtendedCarrier N atomMap r}
    {b_N : N.carrier}
    (hgp_x : (IsPoint x ↔ IsPoint x') ∧ (IsGap x ↔ IsGap x'))
    (hgp_b : (IsPoint (@extendPoint sig M atomMap r b_M) ↔
              IsPoint (@extendPoint sig N atomMap r b_N)) ∧
             (IsGap (@extendPoint sig M atomMap r b_M) ↔
              IsGap (@extendPoint sig N atomMap r b_N)))
    (hgp_y : (IsPoint y ↔ IsPoint y') ∧ (IsGap y ↔ IsGap y'))
    (hgp_sel : ∀ k : Fin n, (IsPoint (a k) ↔ IsPoint (a' k)) ∧
               (IsGap (a k) ↔ IsGap (a' k))) :
    gap_point_agreement n (game_tuple x y a b_M) (game_tuple x' y' a' b_N) := by
  intro i
  simp only [game_tuple]
  by_cases hi0 : i.val = 0
  · simp [hi0]; exact hgp_x
  · by_cases hi_b : i.val = n + 1
    · simp [hi_b]; exact hgp_b
    · by_cases hi_y : i.val = n + 2
      · simp [hi_y]; exact hgp_y
      · simp [hi0, hi_b, hi_y]; exact hgp_sel ⟨i.val - 1, by omega⟩

/-- Helper lemma for formula_agreement proofs: dispatch a 4-way case split
    over game_tuple indices. Given agreement facts for x (index 0),
    b (index n+1), y (index n+2), and selection indices, proves
    formula_agreement for the full game tuple. -/
theorem formula_agreement_of_cases {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {n : Nat}
    {x y : ExtendedCarrier M atomMap r} {a : Fin n → ExtendedCarrier M atomMap r}
    {b_M : M.carrier}
    {x' y' : ExtendedCarrier N atomMap r} {a' : Fin n → ExtendedCarrier N atomMap r}
    {b_N : N.carrier}
    (hform_x : ∀ A : StaviFormula, stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r x A ↔
       stavi_temporal_truth_mu N atomMap r x' A))
    (hform_b : ∀ A : StaviFormula, stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r (@extendPoint sig M atomMap r b_M) A ↔
       stavi_temporal_truth_mu N atomMap r (@extendPoint sig N atomMap r b_N) A))
    (hform_y : ∀ A : StaviFormula, stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r y A ↔
       stavi_temporal_truth_mu N atomMap r y' A))
    (hform_sel : ∀ (k : Fin n) (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r (a k) A ↔
       stavi_temporal_truth_mu N atomMap r (a' k) A)) :
    formula_agreement n (game_tuple x y a b_M) (game_tuple x' y' a' b_N) := by
  intro i A hA
  simp only [game_tuple]
  by_cases hi0 : i.val = 0
  · simp [hi0]; exact hform_x A hA
  · by_cases hi_b : i.val = n + 1
    · simp [hi_b]; exact hform_b A hA
    · by_cases hi_y : i.val = n + 2
      · simp [hi_y]; exact hform_y A hA
      · simp [hi0, hi_b, hi_y]
        exact hform_sel ⟨i.val - 1, by omega⟩ A hA

/-! ## Component E: order_reverse -/

/-- Reverse ordering: given `(a < b ↔ a' < b') ∧ (a = b ↔ a' = b')`,
    derive `(b < a ↔ b' < a') ∧ (b = a ↔ b' = a')`.

    This is needed when the grid dispatch produces a goal about `(j, i)` ordering
    but the hypothesis provides `(i, j)` ordering. The proof uses trichotomy:
    `b < a ↔ ¬(a ≤ b) ↔ ¬(a < b ∨ a = b)`, etc. -/
theorem order_reverse {α β : Type*} [LinearOrder α] [LinearOrder β]
    {a b : α} {a' b' : β}
    (h : (a < b ↔ a' < b') ∧ (a = b ↔ a' = b')) :
    (b < a ↔ b' < a') ∧ (b = a ↔ b' = a') := by
  obtain ⟨h_lt, h_eq⟩ := h
  constructor
  · -- b < a ↔ b' < a': by trichotomy, b < a ↔ ¬(a ≤ b) ↔ ¬(a < b ∨ a = b)
    constructor
    · intro hba
      rcases lt_trichotomy a' b' with h1 | h1 | h1
      · exact absurd (h_lt.mpr h1) (not_lt.mpr (le_of_lt hba))
      · exact absurd (h_eq.mpr h1) (ne_of_gt hba)
      · exact h1
    · intro hba'
      rcases lt_trichotomy a b with h1 | h1 | h1
      · exact absurd (h_lt.mp h1) (not_lt.mpr (le_of_lt hba'))
      · exact absurd (h_eq.mp h1) (ne_of_gt hba')
      · exact h1
  · -- b = a ↔ b' = a': trivially from a = b ↔ a' = b'
    exact ⟨fun h => (h_eq.mp h.symm).symm, fun h => (h_eq.mpr h.symm).symm⟩

/-- `order_reverse` tactic applies `order_reverse` to close goals of the form
    `(b < a ↔ b' < a') ∧ (b = a ↔ b' = a')` when a hypothesis of the form
    `(a < b ↔ a' < b') ∧ (a = b ↔ a' = b')` exists in context.

    Usage: `order_reverse` -/
macro "order_rev" : tactic =>
  `(tactic| (first | exact order_reverse ‹_› | exact order_reverse (And.symm ‹_›)))

/-! ## Component A: same_order_type Grid Setup -/

/-- `same_order_type_grid` macro sets up the 4×4 grid proof for
    same_order_type goals. It does:
    1. `intro i j` to introduce the two index variables
    2. `simp only [game_tuple]` to unfold game_tuple
    3. `split_ifs` to case-split on index categories

    After this macro, there are 16 goals corresponding to all pairs
    of index categories: {x=0, b=n+1, y=n+2, sel} × {x=0, b=n+1, y=n+2, sel}.

    Usage:
    ```
    · -- same_order_type
      same_order_type_grid <;> first
        | order_refl
        | ...  -- handle off-diagonal cases
    ``` -/
macro "same_order_type_grid" : tactic =>
  `(tactic| (intro i j; simp only [game_tuple]; split_ifs))

/-- `same_order_type_grid_uh` is a variant of `same_order_type_grid` that uses
    `unhygienic` to preserve access to `i` and `j` variable names through
    the `<;>` combinator. Without `unhygienic`, variables introduced by `intro`
    become inaccessible after `<;>`, preventing per-case tactics from
    referencing the index values.

    Usage:
    ```
    · -- same_order_type
      same_order_type_grid_uh <;>
        first
          | order_refl
          | exact order_reverse ‹_›
          | ...
    ``` -/
macro "same_order_type_grid_uh" : tactic =>
  `(tactic| unhygienic (intro i j; simp only [game_tuple]; split_ifs))

/-- `extract_order h i j` is a helper macro for extracting ordering data
    from a sub-game same_order_type hypothesis at specific indices.
    It creates a new hypothesis with the ordering at indices i, j,
    with game_tuple simplified away.

    Usage:
    ```
    have hord_ij := extract_order hord ⟨0, by omega⟩ ⟨L.card + 2, by omega⟩
    -- hord_ij now contains the value-level ordering, with game_tuple simplified
    ``` -/
macro "extract_order" h:ident i:term j:term : tactic =>
  `(tactic| (have h := $h $i $j; simp_game_tuple at h; exact h))

end Bimodal.Metalogic.WeakCanonical
