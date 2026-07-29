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
(`ConditionallyCompleteLinearOrderedField.to_archimedean`) require a field.

Deliberate duplicate of `FormalSystem.Semantics.archimedean_of_lub`
(`Semantics/DurationClassification.lean`), which is the public `Semantics`-layer statement of
the same fact and the one the `FrameClass` / `Validity` docstrings cite. This copy stays
`private` and stays here because `exists_countable_order_dense` below uses it and moving it
would drag the Reynolds Sep chain into a rebase for no gain. -/
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

/-- **The nested-interval endgame** of Reynolds §7 lemma 10.

Hypotheses: `S` is a subset of the open interval `(t, s)` that is dense in itself (`hSdense`),
and `hF` assigns to each `u ∈ (t, s)` a point of the countable set `Q` separating the members of
`S` below `u` from those above. If `S` has two distinct members, this is contradictory.

Construction: shrink `(a₀, b₀)` step by step, at stage `n` choosing a sub-interval with endpoints
in `S` that avoids the `n`-th element of `Q` (either lying wholly to its right or wholly to its
left). The left endpoints increase and are bounded above, so `h_lub` supplies `x = sup`, which
lies strictly inside every stage interval. The separator `q` attached to `x` by `hF` must be
`qf n` for some `n`, and must lie strictly between the endpoints of stage `n+1` — which is
exactly what stage `n` was chosen to prevent.

This replaces Reynolds' own endgame (thin `S` to a countable dense order, invoke Cantor's
`≅ ℚ` theorem, count gaps) with the standard Baire-style argument; see the `sep_valid` docstring
in `Metalogic/Soundness.lean` for the recorded fidelity note. -/
theorem nested_core {D : Type} [LinearOrder D]
    (h_lub : ∀ X : Set D, X.Nonempty → BddAbove X → ∃ x, IsLUB X x)
    (Q : Set D) (hQc : Q.Countable) (S : Set D) (t s : D)
    (hSsub : ∀ x ∈ S, t < x ∧ x < s)
    (hSdense : ∀ a ∈ S, ∀ b ∈ S, a < b → ∃ c ∈ S, a < c ∧ c < b)
    (hF : ∀ u, t < u → u < s → ∃ q ∈ Q, ∀ a ∈ S, ∀ b ∈ S, a < u → u < b → a < q ∧ q < b)
    (a0 b0 : D) (ha0 : a0 ∈ S) (hb0 : b0 ∈ S) (hab : a0 < b0) : False := by
  have hQne : Q.Nonempty := by
    obtain ⟨c, hc, hac, hcb⟩ := hSdense a0 ha0 b0 hb0 hab
    obtain ⟨q, hq, -⟩ := hF c (hSsub c hc).1 (hSsub c hc).2
    exact ⟨q, hq⟩
  obtain ⟨qf, hqf⟩ := hQc.exists_eq_range hQne
  have step : ∀ (n : ℕ) (p : D × D), ∃ p' : D × D,
      (p.1 ∈ S ∧ p.2 ∈ S ∧ p.1 < p.2) →
      (p'.1 ∈ S ∧ p'.2 ∈ S ∧ p.1 < p'.1 ∧ p'.1 < p'.2 ∧ p'.2 < p.2 ∧
        (qf n ≤ p'.1 ∨ p'.2 ≤ qf n)) := by
    intro n p
    by_cases h : p.1 ∈ S ∧ p.2 ∈ S ∧ p.1 < p.2
    · obtain ⟨h1, h2, h3⟩ := h
      obtain ⟨c2, hc2, hac2, hc2b⟩ := hSdense _ h1 _ h2 h3
      obtain ⟨c1, hc1, hac1, hc1c2⟩ := hSdense _ h1 _ hc2 hac2
      obtain ⟨c3, hc3, hc2c3, hc3b⟩ := hSdense _ hc2 _ h2 hc2b
      rcases le_or_gt (qf n) c2 with hq | hq
      · exact ⟨(c2, c3), fun _ => ⟨hc2, hc3, hac2, hc2c3, hc3b, Or.inl hq⟩⟩
      · exact ⟨(c1, c2), fun _ => ⟨hc1, hc2, hac1, hc1c2, hc2c3.trans hc3b, Or.inr hq.le⟩⟩
    · exact ⟨p, fun h' => absurd h' h⟩
  choose G hG using step
  set seq : ℕ → D × D := fun n => Nat.rec (a0, b0) (fun n p => G n p) n with hseq
  have hinv : ∀ n, (seq n).1 ∈ S ∧ (seq n).2 ∈ S ∧ (seq n).1 < (seq n).2 := by
    intro n; induction n with
    | zero => exact ⟨ha0, hb0, hab⟩
    | succ n ih =>
      obtain ⟨u1, u2, _, u4, _, _⟩ := hG n (seq n) ih
      exact ⟨u1, u2, u4⟩
  have hstep : ∀ n, (seq n).1 < (seq (n+1)).1 ∧ (seq (n+1)).2 < (seq n).2 ∧
      (qf n ≤ (seq (n+1)).1 ∨ (seq (n+1)).2 ≤ qf n) := by
    intro n
    obtain ⟨_, _, h3, _, h5, h6⟩ := hG n (seq n) (hinv n)
    exact ⟨h3, h5, h6⟩
  have hmonoA : ∀ m n : ℕ, m ≤ n → (seq m).1 ≤ (seq n).1 := by
    intro m n hmn
    induction n with
    | zero => simp_all
    | succ n ih =>
      rcases Nat.lt_or_ge m (n+1) with h | h
      · exact le_trans (ih (Nat.lt_succ_iff.mp h)) (hstep n).1.le
      · have hm : m = n+1 := le_antisymm hmn h
        subst hm; exact le_refl _
  have hmonoB : ∀ m n : ℕ, m ≤ n → (seq n).2 ≤ (seq m).2 := by
    intro m n hmn
    induction n with
    | zero => simp_all
    | succ n ih =>
      rcases Nat.lt_or_ge m (n+1) with h | h
      · exact le_trans (hstep n).2.1.le (ih (Nat.lt_succ_iff.mp h))
      · have hm : m = n+1 := le_antisymm hmn h
        subst hm; exact le_refl _
  have hbdd : BddAbove (Set.range (fun n : ℕ => (seq n).1)) := by
    refine ⟨b0, ?_⟩
    rintro _ ⟨m, rfl⟩
    exact le_of_lt (lt_of_lt_of_le (hinv m).2.2 (hmonoB 0 m (Nat.zero_le m)))
  obtain ⟨x, hx⟩ := h_lub _ ⟨(seq 0).1, Set.mem_range_self 0⟩ hbdd
  have hlt : ∀ n, (seq n).1 < x := fun n =>
    lt_of_lt_of_le (hstep n).1 (hx.1 (Set.mem_range_self (n+1)))
  have hub : ∀ n, x ≤ (seq n).2 := by
    intro n
    refine hx.2 ?_
    rintro _ ⟨m, rfl⟩
    rcases le_or_gt m n with h | h
    · exact le_of_lt (lt_of_le_of_lt (hmonoA m n h) (hinv n).2.2)
    · exact le_trans (hinv m).2.2.le (hmonoB n m h.le)
  have hgt : ∀ n, x < (seq n).2 := fun n => lt_of_le_of_lt (hub (n+1)) (hstep n).2.1
  have htx : t < x := lt_of_lt_of_le (hSsub a0 ha0).1 (hlt 0).le
  have hxs : x < s := lt_trans (hgt 0) (hSsub b0 hb0).2
  obtain ⟨q, hqQ, hqprop⟩ := hF x htx hxs
  obtain ⟨n, hn⟩ : ∃ n, qf n = q := by
    rw [hqf] at hqQ; obtain ⟨n, hn⟩ := hqQ; exact ⟨n, hn⟩
  obtain ⟨hq1, hq2⟩ := hqprop (seq (n+1)).1 (hinv (n+1)).1 (seq (n+1)).2 (hinv (n+1)).2.1
    (hlt (n+1)) (hgt (n+1))
  rcases (hstep n).2.2 with h | h
  · exact absurd (hn ▸ h : q ≤ (seq (n+1)).1) (not_le_of_gt hq1)
  · exact absurd (hn ▸ h : (seq (n+1)).2 ≤ q) (not_le_of_gt hq2)

/-- **The order-theoretic content of Reynolds §7 lemma 10** (future-directed).

Read `P` as the region where the Sep antecedent's formula holds. The three semantic hypotheses
are Reynolds' own: `hK` says `P` accumulates at `t` from the right; `hNoStart` says no point of
`P` in `(t, s₁)` starts a `P`-free gap to its right (this is what makes `S := P ∩ (t, s)` dense in
itself, Reynolds' relative-density condition); `hNoTwo` says every `u ∈ (t, s₂)` has a `P`-free
interval on one side or the other (the failure of the Sep consequent), which yields the adjacent
intervals `I_u` and hence the separating map into the countable `Q`. Together they are
contradictory, which is exactly the validity of Sep.

Steps 1-6 of Reynolds' argument are here; the endgame is delegated to `nested_core`. -/
theorem sep_order {D : Type} [LinearOrder D] [DenselyOrdered D]
    (h_lub : ∀ X : Set D, X.Nonempty → BddAbove X → ∃ x, IsLUB X x)
    (Q : Set D) (hQc : Q.Countable) (hQd : ∀ x y : D, x < y → ∃ q ∈ Q, x < q ∧ q < y)
    (P : Set D) (t s₁ s₂ : D) (hs₁ : t < s₁) (hs₂ : t < s₂)
    (hK : ∀ v, t < v → ∃ u, t < u ∧ u < v ∧ u ∈ P)
    (hNoStart : ∀ u, t < u → u < s₁ → u ∈ P →
        ¬ ∃ v, u < v ∧ v ∈ P ∧ ∀ r, u < r → r < v → r ∉ P)
    (hNoTwo : ∀ u, t < u → u < s₂ →
        (∃ v, u < v ∧ ∀ w, u < w → w < v → w ∉ P) ∨
        (∃ v, v < u ∧ ∀ w, v < w → w < u → w ∉ P)) : False := by
  have hts : t < min s₁ s₂ := lt_min hs₁ hs₂
  have hss1 : min s₁ s₂ ≤ s₁ := min_le_left _ _
  have hss2 : min s₁ s₂ ≤ s₂ := min_le_right _ _
  set s := min s₁ s₂ with hsdef
  set S : Set D := {u | u ∈ P ∧ t < u ∧ u < s} with hS
  have hSsub : ∀ x ∈ S, t < x ∧ x < s := fun x hx => ⟨hx.2.1, hx.2.2⟩
  have hSdense : ∀ a ∈ S, ∀ b ∈ S, a < b → ∃ c ∈ S, a < c ∧ c < b := by
    intro a ha b hb hab
    by_contra hcon
    have hfree : ∀ r, a < r → r < b → r ∉ P := by
      intro r har hrb hrP
      exact hcon ⟨r, ⟨hrP, lt_trans ha.2.1 har, lt_trans hrb hb.2.2⟩, har, hrb⟩
    exact hNoStart a ha.2.1 (lt_of_lt_of_le ha.2.2 hss1) ha.1 ⟨b, hab, hb.1, hfree⟩
  have hF : ∀ u, t < u → u < s →
      ∃ q ∈ Q, ∀ a ∈ S, ∀ b ∈ S, a < u → u < b → a < q ∧ q < b := by
    intro u htu hus
    rcases hNoTwo u htu (lt_of_lt_of_le hus hss2) with ⟨v, huv, hv⟩ | ⟨v, hvu, hv⟩
    · obtain ⟨q, hqQ, huq, hqc⟩ := hQd u (min v s) (lt_min huv hus)
      refine ⟨q, hqQ, ?_⟩
      intro a _ b hb hau hub
      refine ⟨lt_trans hau huq, ?_⟩
      rcases le_or_gt (min v s) b with h | h
      · exact lt_of_lt_of_le hqc h
      · exact absurd hb.1 (hv b hub (lt_of_lt_of_le h (min_le_left _ _)))
    · obtain ⟨q, hqQ, hcq, hqu⟩ := hQd (max v t) u (max_lt hvu htu)
      refine ⟨q, hqQ, ?_⟩
      intro a ha b _ hau hub
      refine ⟨?_, lt_trans hqu hub⟩
      rcases le_or_gt a (max v t) with h | h
      · exact lt_of_le_of_lt h hcq
      · exact absurd ha.1 (hv a (lt_of_le_of_lt (le_max_left _ _) h) hau)
  obtain ⟨u1, htu1, hu1s, hu1P⟩ := hK s hts
  obtain ⟨u0, htu0, hu0, hu0P⟩ := hK u1 htu1
  exact nested_core h_lub Q hQc S t s hSsub hSdense hF u0 u1
    ⟨hu0P, htu0, lt_trans hu0 hu1s⟩ ⟨hu1P, htu1, hu1s⟩ hu0

/-- **The past-directed mirror** of `sep_order`, obtained by instantiating the forward core at
`Dᵒᵈ` rather than hand-dualising its ~130-line body. The least-upper-bound hypothesis transports
through `exists_isGLB_of_lub`; the remaining hypotheses transport by swapping the two strict
inequalities in each.

The `OrderDual` coercions must be written out explicitly. A bare `exact` on the transported
hypothesis, and rewriting with `OrderDual.toDual_lt_toDual`, both fail here with instance-defeq
errors. -/
theorem sep_order_mirror {D : Type} [LinearOrder D] [DenselyOrdered D]
    (h_lub : ∀ X : Set D, X.Nonempty → BddAbove X → ∃ x, IsLUB X x)
    (Q : Set D) (hQc : Q.Countable) (hQd : ∀ x y : D, x < y → ∃ q ∈ Q, x < q ∧ q < y)
    (P : Set D) (t s₁ s₂ : D) (hs₁ : s₁ < t) (hs₂ : s₂ < t)
    (hK : ∀ v, v < t → ∃ u, v < u ∧ u < t ∧ u ∈ P)
    (hNoStart : ∀ u, u < t → s₁ < u → u ∈ P →
        ¬ ∃ v, v < u ∧ v ∈ P ∧ ∀ r, v < r → r < u → r ∉ P)
    (hNoTwo : ∀ u, u < t → s₂ < u →
        (∃ v, v < u ∧ ∀ w, v < w → w < u → w ∉ P) ∨
        (∃ v, u < v ∧ ∀ w, u < w → w < v → w ∉ P)) : False := by
  refine sep_order (D := Dᵒᵈ) ?_ (Q : Set Dᵒᵈ) hQc ?_ (P : Set Dᵒᵈ)
    (OrderDual.toDual t) (OrderDual.toDual s₁) (OrderDual.toDual s₂) hs₁ hs₂ ?_ ?_ ?_
  · intro X hne hbdd
    exact exists_isGLB_of_lub h_lub (B := (X : Set D)) hne hbdd
  · intro x y hxy
    obtain ⟨q, hq, h1, h2⟩ := hQd (OrderDual.ofDual y) (OrderDual.ofDual x) hxy
    exact ⟨OrderDual.toDual q, hq, h2, h1⟩
  · intro v hv
    obtain ⟨u, h1, h2, h3⟩ := hK (OrderDual.ofDual v) hv
    exact ⟨OrderDual.toDual u, h2, h1, h3⟩
  · intro u h1 h2 h3 ⟨v, hv1, hv2, hv3⟩
    exact hNoStart (OrderDual.ofDual u) h1 h2 h3 ⟨OrderDual.ofDual v, hv1, hv2,
      fun r hr1 hr2 => hv3 (OrderDual.toDual r) hr2 hr1⟩
  · intro u h1 h2
    rcases hNoTwo (OrderDual.ofDual u) h1 h2 with ⟨v, hv1, hv2⟩ | ⟨v, hv1, hv2⟩
    · exact Or.inl ⟨OrderDual.toDual v, hv1, fun w hw1 hw2 => hv2 (OrderDual.ofDual w) hw2 hw1⟩
    · exact Or.inr ⟨OrderDual.toDual v, hv1, fun w hw1 hw2 => hv2 (OrderDual.ofDual w) hw2 hw1⟩

end FormalSystem.Metalogic.SoundnessLemmas
