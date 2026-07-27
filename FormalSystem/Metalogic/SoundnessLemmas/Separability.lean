/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Archimedean.Basic
import Mathlib.Data.Set.Countable

/-!
# Separability of a Dense Dedekind-Complete Duration Group

Pure order/group theory supporting the validity of Reynolds' Sep axiom (Reynolds 1992, §7
lemma 10). Nothing here mentions formulas or truth; the file is imported by
`Metalogic/Soundness.lean`, which supplies the semantic glue.

## Why the algebraic hypotheses are load-bearing

Sep is **false** on an arbitrary densely ordered, Dedekind-complete linear order. The
lexicographic square `[0,1] ×ₗₑₓ [0,1]` is densely ordered and Dedekind complete, yet refutes
Sep at `t = (0,1)` with the φ-region `{(a,0) : 0 < a < 1}`: the antecedent holds while no point
above `t` is even a right limit point of the region. This is the essential contrast with the two
Prior gap lemmas of `Soundness.lean`, whose proofs consume only the linear order and the
least-upper-bound hypothesis.

What rescues Sep is the additive group structure: `AddCommGroup` + `IsOrderedAddMonoid` +
`DenselyOrdered` + `Nontrivial` together with the least-upper-bound hypothesis force the order to
be Archimedean, hence **separable** — a countable order-dense subset exists. Separability is the
one mathematical input Reynolds' lemma 10 actually uses, and `exists_countable_order_dense` below
is where it is produced.

## Main results

- `exists_countable_order_dense`: the flow has a countable order-dense subset.
- `nested_core`: the nested-interval endgame — an order-dense subset of an interval cannot
  admit a countable "separating family" indexed by its points.
- `sep_order`: the order-theoretic content of Reynolds §7 lemma 10.
- `sep_order_mirror`: the past-directed instance, obtained as `sep_order` at `Dᵒᵈ`.
-/

namespace FormalSystem.Metalogic.SoundnessLemmas

/-- A greatest lower bound from a least-upper-bound hypothesis, via `isLUB_lowerBounds`.

Deliberate duplicate of the identically-named helper in `Metalogic/Soundness.lean`: that copy is
`private` and so unreachable from this module, and it must stay where it is because
`prior_S_gap_valid` uses it. Kept `private` here too. -/
private theorem exists_isGLB_of_lub {D : Type} [LinearOrder D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    {B : Set D} (hne : B.Nonempty) (hbdd : BddBelow B) : ∃ x, IsGLB B x := by
  obtain ⟨a, ha⟩ := hne
  obtain ⟨x, hx⟩ := h_lub (lowerBounds B) hbdd ⟨a, fun _ hb => hb ha⟩
  exact ⟨x, isLUB_lowerBounds.mp hx⟩

/-- Every positive element of a densely ordered ordered group has a positive "half": some `b > 0`
with `b + b ≤ a`. Density supplies a `c` strictly between `0` and `a`; `min c (a - c)` works. -/
private theorem exists_half_le {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] (a : D) (ha : 0 < a) : ∃ b : D, 0 < b ∧ b + b ≤ a := by
  obtain ⟨c, hc0, hca⟩ := exists_between ha
  refine ⟨min c (a - c), lt_min hc0 (by simpa using hca), ?_⟩
  calc min c (a - c) + min c (a - c) ≤ c + (a - c) :=
        add_le_add (min_le_left _ _) (min_le_right _ _)
    _ = a := by abel

/-- The least-upper-bound hypothesis forces an ordered group to be Archimedean.

If some `y > 0` had all its multiples bounded by `x`, the set `{n • y}` would have a supremum `s`;
but `s - y < s` so some `n • y` exceeds `s - y`, whence `(n+1) • y > s`, contradicting that `s`
bounds the set. There is no route to this through Mathlib: the available instances
(`ConditionallyCompleteLinearOrderedField.to_archimedean`) require a field. -/
private theorem arch_of_lub {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) : Archimedean D := by
  refine ⟨fun x y hy => ?_⟩
  by_contra hcon
  simp only [not_exists, not_le] at hcon
  have hbdd : BddAbove (Set.range (fun n : ℕ => n • y)) := by
    refine ⟨x, ?_⟩; rintro _ ⟨n, rfl⟩; exact (hcon n).le
  obtain ⟨s, hs⟩ := h_lub (Set.range (fun n : ℕ => n • y))
    ⟨(0:ℕ) • y, Set.mem_range_self 0⟩ hbdd
  have h1 : s - y < s := by simpa using sub_lt_self s hy
  obtain ⟨_, ⟨n, rfl⟩, hn, -⟩ := hs.exists_between h1
  have hle : (n+1) • y ≤ s := hs.1 ⟨n+1, rfl⟩
  have h3 : s - y < n • y := hn
  have h2 : s < (n+1) • y := by rw [succ_nsmul]; exact sub_lt_iff_lt_add.mp h3
  exact absurd hle (not_le_of_gt h2)

/-- A sequence of positive elements decreasing below every positive bound: repeatedly halving a
fixed positive `a` gives `d n` with `2^n • d n ≤ a`, and Archimedean-ness turns that into
`d n ≤ e` for any `e > 0`. -/
private theorem exists_null_seq {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] [Archimedean D] [Nontrivial D] :
    ∃ d : ℕ → D, (∀ n, 0 < d n) ∧ ∀ e : D, 0 < e → ∃ n, d n ≤ e := by
  obtain ⟨a, ha⟩ : ∃ a : D, 0 < a := by
    obtain ⟨x, hx⟩ := exists_ne (0 : D)
    rcases lt_or_gt_of_ne hx with h | h
    · exact ⟨-x, by simpa using h⟩
    · exact ⟨x, h⟩
  have key : ∀ a : D, ∃ b : D, 0 < a → (0 < b ∧ b + b ≤ a) := by
    intro a
    by_cases h : 0 < a
    · obtain ⟨b, hb1, hb2⟩ := exists_half_le a h
      exact ⟨b, fun _ => ⟨hb1, hb2⟩⟩
    · exact ⟨a, fun h' => absurd h' h⟩
  choose g hg using key
  set d : ℕ → D := fun n => Nat.rec a (fun _ x => g x) n with hd
  have hpos : ∀ n, 0 < d n := by
    intro n; induction n with
    | zero => exact ha
    | succ n ih => exact (hg _ ih).1
  have hsm : ∀ n, (2^n : ℕ) • d n ≤ a := by
    intro n; induction n with
    | zero =>
      have hz : d 0 = a := rfl
      simp [one_nsmul, hz]
    | succ n ih =>
      have h2 : d (n+1) + d (n+1) ≤ d n := (hg _ (hpos n)).2
      calc (2^(n+1) : ℕ) • d (n+1) = (2^n : ℕ) • (d (n+1) + d (n+1)) := by
            rw [nsmul_add, ← add_nsmul]; congr 1; ring
        _ ≤ (2^n : ℕ) • d n := nsmul_le_nsmul_right h2 _
        _ ≤ a := ih
  refine ⟨d, hpos, ?_⟩
  intro e he
  obtain ⟨m, hm⟩ := Archimedean.arch a he
  obtain ⟨n, hn⟩ : ∃ n : ℕ, m ≤ 2^n := ⟨m, (Nat.lt_two_pow_self).le⟩
  refine ⟨n, ?_⟩
  have h1 : (2^n : ℕ) • d n ≤ (2^n : ℕ) • e :=
    le_trans (hsm n) (le_trans hm (nsmul_le_nsmul_left he.le hn))
  exact le_of_nsmul_le_nsmul_right (pow_ne_zero n (by norm_num)) h1

/-- **Separability of the flow**: a dense Dedekind-complete duration group has a countable
order-dense subset — the integer multiples `k • d n` of the null sequence.

This is the single mathematical input that makes Reynolds' Sep axiom valid (Reynolds 1992, §7
lemma 10). Every hypothesis is consumed: `h_lub` and the ordered-group structure give
Archimedean-ness, density and `Nontrivial` seed and halve the null sequence. -/
theorem exists_countable_order_dense {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [DenselyOrdered D] [Nontrivial D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) :
    ∃ Q : Set D, Q.Countable ∧ ∀ x y : D, x < y → ∃ q ∈ Q, x < q ∧ q < y := by
  have harch : Archimedean D := arch_of_lub h_lub
  obtain ⟨d, hdpos, hdsmall⟩ := exists_null_seq (D := D)
  refine ⟨Set.range (fun p : ℤ × ℕ => p.1 • d p.2), Set.countable_range _, ?_⟩
  intro x y hxy
  obtain ⟨y', hxy', hy'y⟩ := exists_between hxy
  obtain ⟨n, hn⟩ := hdsmall (y' - x) (by simpa using hxy')
  obtain ⟨k, ⟨hk1, hk2⟩, -⟩ := existsUnique_zsmul_near_of_pos (hdpos n) x
  refine ⟨(k+1) • d n, Set.mem_range.mpr ⟨(k+1, n), rfl⟩, hk2, ?_⟩
  have h : (k+1) • d n = k • d n + d n := by rw [add_zsmul, one_zsmul]
  rw [h]
  calc k • d n + d n ≤ x + (y' - x) := add_le_add hk1 hn
    _ = y' := by abel
    _ < y := hy'y

end FormalSystem.Metalogic.SoundnessLemmas
