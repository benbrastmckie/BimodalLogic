/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Profile
import FormalSystem.Metalogic.Decidability.RaySummary.Transport

/-!
# Periodic transport: ultimately periodic witnesses for the tail types of a colouring

`Profile.lean` supplies a summary of finite words that composes under concatenation and has
bounded representatives. This module applies it to the two tails of a colouring of `ℤ` around a
seam time `t` — the forward tail `[t + 1, ∞)` and the backward tail `(-∞, t)` — and proves that
every tail type is realized by a **bounded ultimately periodic** tail whose own tail types are
all among the original's. That is the completeness half of requirement (C) with the model
forgotten: `familyTriples sig k c` of a colouring with `now` exactly at `t` decomposes through
the seam into a backward tail pair, the letter at `t` and a forward tail pair
(`mem_familyTriples_iff_tails`), and `exists_periodic_subfamily` assembles the two one-sided
transports into a bi-ultimately-periodic colouring `w^(ω*) · m · v^ω` with `now` exactly at `t`.

**The colourings.** `periodicColouring sig w m v b` reads `w` periodically before time `b`,
`m` on `[b, b + |m|)`, and `v` periodically from `b + |m|` on; `fwdPeriodic sig u v t` is the
one-sided form reading `u` from `t + 1` and then `v^ω` (what it reads before `t + 1` is
irrelevant to the forward tail), and `bwdPeriodic sig w u t` reads `w^(ω*)` then `u` ending at
`t - 1`. The `DecidablePred` instance computes.

**The tail type sets.** `(α, σ) ∈ FwdTypes sig k c t` when the forward tail factors as a prefix
of type `α` followed by ω-many segments of type `σ` — the forward half of a
`SegmentFactorization` read from the seam; `BwdTypes` is the mirror. Both depend only on the
tail they read (`fwdTypes_congr`, `bwdTypes_congr`).

**The transport.** `exists_periodic_fwd` is the Ramsey-over-profile argument: colour pairs of
cuts of the forward factorization by the `(profile, cutProfile)` of the stretch between them,
take the monochromatic strictly monotone subsequence
(`Nat.exists_strictMono_const_pair_colour`), replace the prefix and the first block by bounded
representatives (`exists_rep_of_length_lt`), and read every tail type of the periodic word back
into the original tail block by block through `profile_flatten_congr` — the cut-pair obstruction
of `Profile.lean`'s docstring is exactly what the cut profile carries across. The backward
statement `exists_periodic_bwd` is the forward one on the reflected colouring, through the
order-dual transfer of `k`-types (`kTypeOf_listSeg_reverse_congr`, by the back-and-forth game
`kEquiv_iff_backForth`, whose atoms are symmetric under reversing the order).

**A count, not a complexity bound.** Every length bound here is `Nat.card (Profile sig k) ^ 2`
or a small multiple of it — a count of pairs of profiles, in the words of `Profile.lean`'s
docstring; nothing is timed and no procedure is bounded.

## Main definitions and results

* `periodicColouring`, `fwdPeriodic`, `bwdPeriodic` — the (bi-)ultimately periodic colourings,
  with the read-outs `labels_periodicColouring_mid`, `labels_periodicColouring_slice`,
  `labels_periodicColouring_period`, `labels_periodicColouring_bwd`.
* `FwdTypes`, `BwdTypes`, `fwdTypes_congr`, `bwdTypes_congr` — the tail type sets.
* `exists_periodic_fwd`, `exists_periodic_bwd` — the one-sided transports.
* `mem_familyTriples_iff_tails`, `exists_periodic_subfamily` — family triples through the seam
  and the seam assembly.

## References

* [W. Thomas, *Languages, Automata, and Logic*, 1997], §5.1, for the Ramsey route to ultimately
  periodic witnesses; re-proved here for the finitely many conditions `L_α L_σ^ω` through the
  profile, with no automaton.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.Expressiveness

variable (sig : MonadicSignature)

/-! ## Periodic colourings -/

section PeriodicColouring

/-- The letter of the bi-ultimately-periodic word `w^(ω*) · m · v^ω` at time `z`, with `m`
starting at time `b`: `w` read periodically (backwards from `b`) before `b`, `m` on
`[b, b + |m|)`, `v` read periodically from `b + |m|` on. -/
def periodicLetter (w m v : List (sig.preds → Bool)) (b z : ℤ) : sig.preds → Bool :=
  if z < b then w.getD ((z - b) % w.length).toNat default
  else if z < b + m.length then m.getD (z - b).toNat default
  else v.getD ((z - b - m.length) % v.length).toNat default

/-- **The bi-ultimately-periodic colouring** `w^(ω*) · m · v^ω` with `m` starting at time `b`. -/
def periodicColouring (w m v : List (sig.preds → Bool)) (b : ℤ) : sig.preds → ℤ → Prop :=
  fun p z => periodicLetter sig w m v b z p = true

/-- The periodic colouring is decidable letter by letter, computably. -/
instance periodicColouringDecidable (w m v : List (sig.preds → Bool)) (b : ℤ) :
    ∀ p, DecidablePred (periodicColouring sig w m v b p) :=
  fun p z => inferInstanceAs (Decidable (periodicLetter sig w m v b z p = true))

/-- **The forward one-sided form**: `u` read from `t + 1`, then `v^ω`; what is read before
`t + 1` (a copy of `v^(ω*)`) is irrelevant to the forward tail. -/
abbrev fwdPeriodic (u v : List (sig.preds → Bool)) (t : ℤ) : sig.preds → ℤ → Prop :=
  periodicColouring sig v u v (t + 1)

/-- **The backward one-sided form**: `w^(ω*)` then `u` ending at `t - 1`; what is read from `t`
on (a copy of `w^ω`) is irrelevant to the backward tail. -/
abbrev bwdPeriodic (w u : List (sig.preds → Bool)) (t : ℤ) : sig.preds → ℤ → Prop :=
  periodicColouring sig w u w (t - u.length)

variable {sig}
variable (w m v : List (sig.preds → Bool)) (b : ℤ)

theorem periodicLetter_of_lt {z : ℤ} (hz : z < b) :
    periodicLetter sig w m v b z = w.getD ((z - b) % w.length).toNat default := by
  simp only [periodicLetter, if_pos hz]

theorem periodicLetter_of_mid {z : ℤ} (h₁ : b ≤ z) (h₂ : z < b + m.length) :
    periodicLetter sig w m v b z = m.getD (z - b).toNat default := by
  simp only [periodicLetter, if_neg (not_lt.mpr h₁), if_pos h₂]

theorem periodicLetter_of_ge {z : ℤ} (h : b + m.length ≤ z) :
    periodicLetter sig w m v b z = v.getD ((z - b - m.length) % v.length).toNat default := by
  simp only [periodicLetter, if_neg (not_lt.mpr (by omega : b ≤ z)), if_neg (not_lt.mpr h)]

theorem periodicColouring_iff (p : sig.preds) (z : ℤ) :
    periodicColouring sig w m v b p z ↔ periodicLetter sig w m v b z p = true := Iff.rfl

/-- A letter of the label list of the periodic colouring is the periodic letter there. -/
theorem labels_periodicColouring_getElem (a a' : ℤ) (i : ℕ)
    (hi : i < (labels (periodicColouring sig w m v b) a a').length) :
    (labels (periodicColouring sig w m v b) a a')[i] = periodicLetter sig w m v b (a + i) := by
  funext p
  rw [labels_getElem, Bool.eq_iff_iff, decide_eq_true_iff]
  exact Iff.rfl

/-- **Reading `m`**: the label list on `[b, b + |m|)` is `m`. -/
theorem labels_periodicColouring_mid :
    labels (periodicColouring sig w m v b) b (b + m.length) = m := by
  apply List.ext_getElem
  · rw [labels_length]
    omega
  · intro i h₁ h₂
    rw [labels_periodicColouring_getElem, periodicLetter_of_mid w m v b (by omega) (by omega),
      show (b + (i : ℤ) - b).toNat = i by omega, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem h₂]
    rfl

/-- **Reading a slice of a period**: the label list on `[s + o, s + o')` with
`s := b + |m| + n·|v|` the start of the `n`-th period and `o ≤ o' ≤ |v|` is `v[o, o')`. -/
theorem labels_periodicColouring_slice (n o o' : ℕ) (ho : o ≤ o') (ho' : o' ≤ v.length) :
    labels (periodicColouring sig w m v b) (b + m.length + n * v.length + o)
        (b + m.length + n * v.length + o') = (v.drop o).take (o' - o) := by
  have hnv : (0 : ℤ) ≤ (n : ℤ) * v.length := by positivity
  apply List.ext_getElem
  · rw [labels_length, List.length_take, List.length_drop]
    omega
  · intro i h₁ h₂
    have hi : i < o' - o := by rw [List.length_take, List.length_drop] at h₂; omega
    rw [labels_periodicColouring_getElem, periodicLetter_of_ge w m v b (by omega),
      show b + (m.length : ℤ) + n * v.length + o + i - b - m.length =
        ((o + i : ℕ) : ℤ) + (v.length : ℤ) * n by push_cast; ring,
      Int.add_mul_emod_self_left, Int.emod_eq_of_lt (by omega) (by omega),
      Int.toNat_natCast, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem (by omega : o + i < v.length), List.getElem_take,
      List.getElem_drop]
    rfl

/-- **Reading a whole period**: the label list on the `n`-th period is `v`. -/
theorem labels_periodicColouring_period (n : ℕ) :
    labels (periodicColouring sig w m v b) (b + m.length + n * v.length)
        (b + m.length + (n + 1) * v.length) = v := by
  have h := labels_periodicColouring_slice w m v b n 0 v.length (Nat.zero_le _) le_rfl
  rw [show b + (m.length : ℤ) + n * v.length + ((0 : ℕ) : ℤ) =
    b + m.length + n * v.length by simp] at h
  rw [show b + (m.length : ℤ) + (n + 1) * v.length =
    b + m.length + n * v.length + v.length by ring]
  rw [h, List.drop_zero, Nat.sub_zero, List.take_length]

/-- **Reading `n` periods**: the label list on `[b + |m|, b + |m| + n·|v|)` is `v^n`. -/
theorem labels_periodicColouring_replicate (n : ℕ) :
    labels (periodicColouring sig w m v b) (b + m.length) (b + m.length + n * v.length) =
      (List.replicate n v).flatten := by
  induction n with
  | zero =>
    rw [show b + (m.length : ℤ) + ((0 : ℕ) : ℤ) * v.length = b + m.length by simp]
    apply List.ext_getElem
    · rw [labels_length]
      simp
    · intro i h₁ h₂
      rw [labels_length] at h₁
      omega
  | succ n ih =>
    have hnv : (0 : ℤ) ≤ (n : ℤ) * v.length := by positivity
    have hsucc : ((n : ℤ) + 1) * v.length = n * v.length + v.length := by ring
    rw [Nat.cast_succ,
      labels_append _ (b + m.length) (b + m.length + n * v.length) _ (by omega) (by omega),
      ih, labels_periodicColouring_period, List.replicate_succ', List.flatten_append,
      List.flatten_cons, List.flatten_nil, List.append_nil]

/-- **Reading `w` backwards**: the label list on the `n`-th period before `b` is `w`. -/
theorem labels_periodicColouring_bwd (n : ℕ) :
    labels (periodicColouring sig w m v b) (b - (n + 1) * w.length) (b - n * w.length) = w := by
  have hnw : (0 : ℤ) ≤ (n : ℤ) * w.length := by positivity
  have hsucc : ((n : ℤ) + 1) * w.length = n * w.length + w.length := by ring
  apply List.ext_getElem
  · rw [labels_length]
    omega
  · intro i h₁ h₂
    rw [labels_periodicColouring_getElem, periodicLetter_of_lt w m v b (by omega),
      show b - ((n : ℤ) + 1) * w.length + i - b = (i : ℤ) - ((n + 1 : ℕ) : ℤ) * w.length by
        push_cast; ring,
      Int.sub_mul_emod_self_right, Int.emod_eq_of_lt (by omega) (by omega), Int.toNat_natCast,
      List.getD_eq_getElem?_getD, List.getElem?_eq_getElem h₂]
    rfl

end PeriodicColouring

/-! ## The tail type sets -/

section TailTypes

variable (k : ℕ)

/-- **The forward tail types of `c` from `t`**: the pairs `(α, σ)` such that the forward tail
`[t + 1, ∞)` factors as a prefix of `k`-type `α` followed by ω-many segments of `k`-type `σ`,
along a strictly increasing cut sequence starting at or after `t + 1`. -/
def FwdTypes (c : sig.preds → ℤ → Prop) (t : ℤ) : Set (KType sig k × KType sig k) :=
  {x | ∃ W : ℕ → ℤ, StrictMono W ∧ t + 1 ≤ W 0 ∧
    kTypeOf sig k (segZ sig c (t + 1) (W 0)) = x.1 ∧
    ∀ i, kTypeOf sig k (segZ sig c (W i) (W (i + 1))) = x.2}

/-- **The backward tail types of `c` from `t`**: the pairs `(σ, β)` such that the backward tail
`(-∞, t)` factors as ω*-many segments of `k`-type `σ` followed by a suffix `[W 0, t)` of
`k`-type `β`, along a strictly decreasing cut sequence starting at or before `t`. -/
def BwdTypes (c : sig.preds → ℤ → Prop) (t : ℤ) : Set (KType sig k × KType sig k) :=
  {x | ∃ W : ℕ → ℤ, StrictAnti W ∧ W 0 ≤ t ∧
    kTypeOf sig k (segZ sig c (W 0) t) = x.2 ∧
    ∀ i, kTypeOf sig k (segZ sig c (W (i + 1)) (W i)) = x.1}

variable {sig k}

/-- Two colourings that agree on `[a, b)` give that segment the same `k`-type: the identity is
an order isomorphism of the two segments preserving every letter. -/
theorem kTypeOf_segZ_congr [Finite sig.preds] {c c' : sig.preds → ℤ → Prop} {a b : ℤ}
    (h : ∀ p z, a ≤ z → z < b → (c p z ↔ c' p z)) :
    kTypeOf sig k (segZ sig c a b) = kTypeOf sig k (segZ sig c' a b) :=
  k_equiv_of_iso sig k (segZ sig c a b) (segZ sig c' a b) (OrderIso.refl _)
    (fun p t => h p t.1 t.2.1 t.2.2)

/-- A strictly increasing integer sequence grows at least linearly. -/
theorem strictMono_le_add_nat {W : ℕ → ℤ} (hW : StrictMono W) (n : ℕ) : W 0 + n ≤ W n := by
  induction n with
  | zero => simp
  | succ n ih =>
    have := hW (show n < n + 1 by omega)
    push_cast
    omega

/-- A strictly decreasing integer sequence falls at least linearly. -/
theorem strictAnti_le_sub_nat {W : ℕ → ℤ} (hW : StrictAnti W) (n : ℕ) : W n ≤ W 0 - n := by
  induction n with
  | zero => simp
  | succ n ih =>
    have := hW (show n < n + 1 by omega)
    push_cast
    omega

/-- **Every time from `W 0` on lies in a segment of a strictly increasing cut sequence.** -/
theorem exists_seg_of_strictMono {W : ℕ → ℤ} (hW : StrictMono W) {z : ℤ} (hz : W 0 ≤ z) :
    ∃ i, W i ≤ z ∧ z < W (i + 1) := by
  classical
  set N : ℕ := (z - W 0).toNat + 1 with hN
  have hWN : z < W N := by
    have := strictMono_le_add_nat hW N
    omega
  set P : ℕ → Prop := fun i => W i ≤ z with hP
  set j : ℕ := Nat.findGreatest P N with hj
  have hPj : P j := Nat.findGreatest_spec (Nat.zero_le N) (by simpa [hP] using hz)
  have hjle : j ≤ N := Nat.findGreatest_le N
  have hjN : j ≠ N := by
    intro hje
    have : W N ≤ z := hje ▸ hPj
    omega
  refine ⟨j, hPj, ?_⟩
  have hnot : ¬ P (j + 1) :=
    Nat.findGreatest_is_greatest (n := N) (by omega) (by omega)
  simpa [hP] using hnot

/-- **Every time up to `W 0` lies in a segment of a strictly decreasing cut sequence.** -/
theorem exists_seg_of_strictAnti {W : ℕ → ℤ} (hW : StrictAnti W) {z : ℤ} (hz : z < W 0) :
    ∃ i, W (i + 1) ≤ z ∧ z < W i := by
  classical
  set N : ℕ := (W 0 - z).toNat with hN
  have hWN : W N ≤ z := by
    have := strictAnti_le_sub_nat hW N
    omega
  set P : ℕ → Prop := fun i => z < W i with hP
  set j : ℕ := Nat.findGreatest P N with hj
  have hPj : P j := Nat.findGreatest_spec (Nat.zero_le N) (by simpa [hP] using hz)
  have hjle : j ≤ N := Nat.findGreatest_le N
  have hjN : j ≠ N := by
    intro hje
    have : z < W N := hje ▸ hPj
    omega
  refine ⟨j, ?_, hPj⟩
  have hnot : ¬ P (j + 1) :=
    Nat.findGreatest_is_greatest (n := N) (by omega) (by omega)
  simpa [hP] using hnot

/-- **The forward tail types depend only on the forward tail.** -/
theorem fwdTypes_congr [Finite sig.preds] {c c' : sig.preds → ℤ → Prop} {t : ℤ}
    (h : ∀ p z, t < z → (c p z ↔ c' p z)) : FwdTypes sig k c t = FwdTypes sig k c' t := by
  have hseg : ∀ a b : ℤ, t + 1 ≤ a →
      kTypeOf sig k (segZ sig c a b) = kTypeOf sig k (segZ sig c' a b) :=
    fun a b ha => kTypeOf_segZ_congr fun p z hz _ => h p z (by omega)
  ext x
  simp only [FwdTypes, Set.mem_setOf_eq]
  constructor
  · rintro ⟨W, hW, h0, h1, h2⟩
    refine ⟨W, hW, h0, by rw [← hseg _ _ le_rfl]; exact h1, fun i => ?_⟩
    rw [← hseg _ _ (h0.trans (hW.monotone (Nat.zero_le i)))]
    exact h2 i
  · rintro ⟨W, hW, h0, h1, h2⟩
    refine ⟨W, hW, h0, by rw [hseg _ _ le_rfl]; exact h1, fun i => ?_⟩
    rw [hseg _ _ (h0.trans (hW.monotone (Nat.zero_le i)))]
    exact h2 i

/-- **The backward tail types depend only on the backward tail.** -/
theorem bwdTypes_congr [Finite sig.preds] {c c' : sig.preds → ℤ → Prop} {t : ℤ}
    (h : ∀ p z, z < t → (c p z ↔ c' p z)) : BwdTypes sig k c t = BwdTypes sig k c' t := by
  have hseg : ∀ a b : ℤ, b ≤ t →
      kTypeOf sig k (segZ sig c a b) = kTypeOf sig k (segZ sig c' a b) :=
    fun a b hb => kTypeOf_segZ_congr fun p z _ hz => h p z (by omega)
  ext x
  simp only [BwdTypes, Set.mem_setOf_eq]
  constructor
  · rintro ⟨W, hW, h0, h1, h2⟩
    refine ⟨W, hW, h0, by rw [← hseg _ _ le_rfl]; exact h1, fun i => ?_⟩
    rw [← hseg _ _ ((hW.antitone (Nat.zero_le i)).trans h0)]
    exact h2 i
  · rintro ⟨W, hW, h0, h1, h2⟩
    refine ⟨W, hW, h0, by rw [hseg _ _ le_rfl]; exact h1, fun i => ?_⟩
    rw [hseg _ _ ((hW.antitone (Nat.zero_le i)).trans h0)]
    exact h2 i

end TailTypes

/-! ## Forward Ramsey blocks

Colour a pair `i < j` of cuts of a forward factorization by the profile and the cut profile of
the stretch `[W i, W j)` between them — a finite colour type, `Profile sig k` times the Bool
tables on `Profile sig k × Profile sig k`. Infinite Ramsey for pairs
(`Nat.exists_strictMono_const_pair_colour`) gives a strictly monotone subsequence of cuts on
which the colour is constant: consecutive blocks `[V a, V (a + 1))`, each a union of
consecutive `σ`-segments (so in `L_σ^+`), all with the same profile and the same cut profile.
The equal cut profiles are what `Profile.lean`'s cut-pair obstruction needs: a cut of the
periodic repetition of one block at an interior offset is matched, in EVERY block, by a cut
with the same pair of profiles. -/

section Blocks

variable {sig k}

/-- Consecutive segments of type `σ` along a strictly increasing cut sequence concatenate to a
word of `L_σ^*`. -/
theorem starZero_labels {c : sig.preds → ℤ → Prop} [∀ p, DecidablePred (c p)] {W : ℕ → ℤ}
    (hW : StrictMono W) {σ : KType sig k}
    (hσ : ∀ i, kTypeOf sig k (listSeg (labels c (W i) (W (i + 1)))) = σ) (n d : ℕ) :
    StarZero sig k σ (labels c (W n) (W (n + d))) := by
  induction d with
  | zero =>
    rw [Nat.add_zero]
    have : labels c (W n) (W n) = [] := by
      apply List.eq_nil_of_length_eq_zero
      rw [labels_length]
      omega
    rw [this]
    exact starZero_nil σ
  | succ d ih =>
    rw [← Nat.add_assoc,
      labels_append c (W n) (W (n + d)) (W (n + d + 1)) (hW.monotone (Nat.le_add_right n d))
      (hW.monotone (Nat.le_succ (n + d)))]
    refine starZero_append ih (starZero_single ?_ (hσ (n + d)))
    apply List.ne_nil_of_length_pos
    rw [labels_length]
    have := hW (show n + d < n + d + 1 by omega)
    omega

/-- **Forward Ramsey blocks.** From `(α, σ) ∈ FwdTypes c t`, a cut sequence `V` whose prefix
`[t + 1, V 0)` is in `L_α L_σ^*` and whose stretches `[V a, V (a + 1))` are in `L_σ^+`, all with
the same profile `E` and the same cut profile `CP`. Infinite Ramsey for pairs on the colouring
`(i, j) ↦ (profile, cutProfile)` of the stretch `[W i, W j)` of the given factorization, the cut
profile taken as its Bool table so that the colour type is finite. -/
theorem exists_blocks_fwd [Finite sig.preds] {c : sig.preds → ℤ → Prop}
    [∀ p, DecidablePred (c p)] {t : ℤ} {α σ : KType sig k}
    (hx : (α, σ) ∈ FwdTypes sig k c t) :
    ∃ (V : ℕ → ℤ) (E : Profile sig k) (CP : Set (Profile sig k × Profile sig k)),
      StrictMono V ∧ t + 1 ≤ V 0 ∧
      PrefixStar sig k α σ (labels c (t + 1) (V 0)) ∧
      (∀ a, StarPlus sig k σ (labels c (V a) (V (a + 1)))) ∧
      (∀ a, profile sig k (labels c (V a) (V (a + 1))) = E) ∧
      (∀ a, cutProfile sig k (labels c (V a) (V (a + 1))) = CP) := by
  classical
  haveI := Fintype.ofFinite sig.preds
  haveI := Classical.decEq sig.preds
  haveI : Finite (Profile sig k) := Finite.of_fintype _
  haveI : Finite (Profile sig k × Profile sig k → Bool) := Pi.finite
  obtain ⟨W, hW, h0, hα, hσ⟩ := hx
  simp only at hα hσ
  rw [kTypeOf_segZ_eq_listSeg] at hα
  simp only [kTypeOf_segZ_eq_listSeg] at hσ
  obtain ⟨g, hg, ⟨E, CB⟩, hcol⟩ := Nat.exists_strictMono_const_pair_colour
    (fun i j => (profile sig k (labels c (W i) (W j)),
      fun pr => decide (pr ∈ cutProfile sig k (labels c (W i) (W j)))))
  have hV : StrictMono (fun a => W (g a)) := hW.comp hg
  refine ⟨fun a => W (g a), E, {pr | CB pr = true}, hV, h0.trans (hW.monotone (Nat.zero_le _)),
    ?_, fun a => ?_, fun a => ?_, fun a => ?_⟩
  · rw [labels_append c (t + 1) (W 0) (W (g 0)) h0 (hW.monotone (Nat.zero_le _))]
    exact ⟨_, _, rfl, hα, by simpa using starZero_labels hW hσ 0 (g 0)⟩
  · rw [starPlus_iff]
    refine ⟨?_, ?_⟩
    · apply List.ne_nil_of_length_pos
      change 0 < (labels c (W (g a)) (W (g (a + 1)))).length
      rw [labels_length]
      have := hW (hg (show a < a + 1 by omega))
      omega
    · have := starZero_labels hW hσ (g a) (g (a + 1) - g a)
      rwa [Nat.add_sub_of_le (hg.monotone (Nat.le_succ a))] at this
  · exact congrArg Prod.fst (hcol a (a + 1) (by omega))
  · ext pr
    have h := congrFun (congrArg Prod.snd (hcol a (a + 1) (by omega))) pr
    simp only at h
    rw [Set.mem_setOf_eq, ← h, decide_eq_true_iff]

end Blocks

end FormalSystem.Metalogic.WeakCanonical
