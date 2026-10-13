/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.GroupModel.MonoDiscrete
import FormalSystem.Metalogic.Decidability.RaySummary.Profile
import FormalSystem.Metalogic.Decidability.RaySummary.Transport
import FormalSystem.Metalogic.Decidability.RaySummary.Trace

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

-- The module crosses the package-wide `longFile` limit (`lakefile.toml`, 1500): the forward
-- transport, its reversal, and the seam assembly are one argument and stay in one module.
set_option linter.style.longFile 1700

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

/-! ## Refining stretches of pieces into a factorization

A cut sequence whose stretches are flattenings of nonempty pieces of type `σ` refines to a cut
sequence whose every segment is one piece: the refined cut `n` names a block `a` and a piece `j`
of that block (`refineIdx`, stepping to the next piece or to the first piece of the next block),
and sits at the piece's offset inside the block (`refineCut`). Used twice: to read a membership
`(α, σ) ∈ FwdTypes` off `PrefixStar`/`StarPlus` stretches of a periodic colouring, and to read
one off the transported stretches of the original colouring. -/

section Refine

variable {L : Type}

/-- The offset of the `j`-th piece inside the flattening of `ps`. -/
def pieceOff (ps : List (List L)) (j : ℕ) : ℕ := ((ps.take j).flatten).length

theorem pieceOff_zero (ps : List (List L)) : pieceOff ps 0 = 0 := by simp [pieceOff]

theorem pieceOff_succ (ps : List (List L)) {j : ℕ} (hj : j < ps.length) :
    pieceOff ps (j + 1) = pieceOff ps j + ps[j].length := by
  unfold pieceOff
  rw [List.take_add_one, List.getElem?_eq_getElem hj, Option.toList_some, List.flatten_append,
    List.flatten_cons, List.flatten_nil, List.append_nil, List.length_append]

theorem pieceOff_length (ps : List (List L)) : pieceOff ps ps.length = ps.flatten.length := by
  simp [pieceOff]

theorem pieceOff_le (ps : List (List L)) (j : ℕ) : pieceOff ps j ≤ ps.flatten.length := by
  unfold pieceOff
  conv_rhs => rw [← List.take_append_drop j ps]
  rw [List.flatten_append, List.length_append]
  omega

/-- The `j`-th piece is the slice of the flattening at its offset. -/
theorem flatten_slice (ps : List (List L)) {j : ℕ} (hj : j < ps.length) :
    (ps.flatten.drop (pieceOff ps j)).take ps[j].length = ps[j] := by
  have h : ps.flatten = (ps.take j).flatten ++ (ps[j] ++ (ps.drop (j + 1)).flatten) := by
    conv_lhs => rw [← List.take_append_drop j ps]
    rw [List.flatten_append, List.drop_eq_getElem_cons hj, List.flatten_cons]
  rw [h, pieceOff, List.drop_left, List.take_left]

/-- The refinement index: `(a, j)` names piece `j` of block `a`; the successor moves to the next
piece of the block, or to the first piece of the next block. -/
def refineIdx (Bl : ℕ → List (List L)) : ℕ → ℕ × ℕ
  | 0 => (0, 0)
  | n + 1 =>
    if (refineIdx Bl n).2 + 1 < (Bl (refineIdx Bl n).1).length then
      ((refineIdx Bl n).1, (refineIdx Bl n).2 + 1)
    else ((refineIdx Bl n).1 + 1, 0)

theorem refineIdx_lt {Bl : ℕ → List (List L)} (hBl : ∀ a, Bl a ≠ []) (n : ℕ) :
    (refineIdx Bl n).2 < (Bl (refineIdx Bl n).1).length := by
  induction n with
  | zero =>
    simp only [refineIdx]
    exact List.length_pos_iff.mpr (hBl 0)
  | succ n ih =>
    simp only [refineIdx]
    split_ifs with h
    · exact h
    · exact List.length_pos_iff.mpr (hBl _)

/-- The refined cut: the start of the named piece inside its block. -/
def refineCut (V : ℕ → ℤ) (Bl : ℕ → List (List L)) (n : ℕ) : ℤ :=
  V (refineIdx Bl n).1 + pieceOff (Bl (refineIdx Bl n).1) (refineIdx Bl n).2

theorem refineCut_zero (V : ℕ → ℤ) (Bl : ℕ → List (List L)) : refineCut V Bl 0 = V 0 := by
  simp [refineCut, refineIdx, pieceOff_zero]

end Refine

section RefineCut

variable {sig k}

/-- A slice of a label list is the label list of the sub-interval. -/
theorem labels_slice (c : sig.preds → ℤ → Prop) [∀ p, DecidablePred (c p)] (a b : ℤ) (i i' : ℕ)
    (hi : i ≤ i') (hi' : a + i' ≤ b) :
    labels c (a + i) (a + i') = ((labels c a b).drop i).take (i' - i) := by
  apply List.ext_getElem
  · rw [labels_length, List.length_take, List.length_drop, labels_length]
    omega
  · intro n h₁ h₂
    funext p
    rw [List.getElem_take, List.getElem_drop, labels_getElem, labels_getElem]
    simp only [show a + (i : ℤ) + n = a + ((i + n : ℕ) : ℤ) by push_cast; ring]

/-- If the label list of `[a, b)` is `l₁ ++ l₂`, the two parts are the label lists of
`[a, a + |l₁|)` and `[a + |l₁|, b)`. -/
theorem labels_split_of_eq_append (c : sig.preds → ℤ → Prop) [∀ p, DecidablePred (c p)]
    {a b : ℤ} {l₁ l₂ : List (sig.preds → Bool)} (h : labels c a b = l₁ ++ l₂) :
    labels c a (a + l₁.length) = l₁ ∧ labels c (a + l₁.length) b = l₂ := by
  have hlen : (b - a).toNat = l₁.length + l₂.length := by
    rw [← labels_length c a b, h, List.length_append]
  by_cases hab : a ≤ b
  · rw [labels_append c a (a + l₁.length) b (by omega) (by omega)] at h
    exact List.append_inj h (by rw [labels_length]; omega)
  · have hnil : l₁ ++ l₂ = [] := by
      rw [← h]
      exact List.eq_nil_of_length_eq_zero (by rw [labels_length]; omega)
    obtain ⟨rfl, rfl⟩ := List.append_eq_nil_iff.mp hnil
    exact ⟨List.eq_nil_of_length_eq_zero (by rw [labels_length]; simp),
      List.eq_nil_of_length_eq_zero (by rw [labels_length]; simp; omega)⟩

variable {c : sig.preds → ℤ → Prop} [∀ p, DecidablePred (c p)] {V : ℕ → ℤ}
  {Bl : ℕ → List (List (sig.preds → Bool))}

theorem refineCut_succ (hV : StrictMono V) (hBl : ∀ a, Bl a ≠ [])
    (hlab : ∀ a, labels c (V a) (V (a + 1)) = (Bl a).flatten) (n : ℕ) :
    refineCut V Bl (n + 1) =
      V (refineIdx Bl n).1 + pieceOff (Bl (refineIdx Bl n).1) ((refineIdx Bl n).2 + 1) := by
  have hlt := refineIdx_lt hBl n
  unfold refineCut
  simp only [refineIdx]
  split_ifs with h
  · rfl
  · have hj : (refineIdx Bl n).2 + 1 = (Bl (refineIdx Bl n).1).length := by omega
    rw [pieceOff_zero, hj, pieceOff_length]
    have h1 := labels_length c (V (refineIdx Bl n).1) (V ((refineIdx Bl n).1 + 1))
    rw [hlab] at h1
    have h2 := hV (show (refineIdx Bl n).1 < (refineIdx Bl n).1 + 1 by omega)
    push_cast
    omega

/-- The segment between consecutive refined cuts is the named piece. -/
theorem labels_refineCut (hV : StrictMono V) (hBl : ∀ a, Bl a ≠ [])
    (hlab : ∀ a, labels c (V a) (V (a + 1)) = (Bl a).flatten) (n : ℕ) :
    labels c (refineCut V Bl n) (refineCut V Bl (n + 1)) =
      (Bl (refineIdx Bl n).1)[(refineIdx Bl n).2]'(refineIdx_lt hBl n) := by
  have hlt := refineIdx_lt hBl n
  rw [refineCut_succ hV hBl hlab n]
  unfold refineCut
  rw [pieceOff_succ _ hlt]
  have h1 := labels_length c (V (refineIdx Bl n).1) (V ((refineIdx Bl n).1 + 1))
  rw [hlab] at h1
  have h2 := hV (show (refineIdx Bl n).1 < (refineIdx Bl n).1 + 1 by omega)
  have h3 := pieceOff_le (Bl (refineIdx Bl n).1) ((refineIdx Bl n).2 + 1)
  rw [pieceOff_succ _ hlt] at h3
  rw [labels_slice c (V (refineIdx Bl n).1) (V ((refineIdx Bl n).1 + 1)) _ _ (by omega)
    (by push_cast; omega), Nat.add_sub_cancel_left, hlab, flatten_slice _ hlt]

theorem refineCut_strictMono (hV : StrictMono V) (hBl : ∀ a, Bl a ≠ [])
    (hpieces : ∀ a, ∀ p ∈ Bl a, p ≠ [])
    (hlab : ∀ a, labels c (V a) (V (a + 1)) = (Bl a).flatten) :
    StrictMono (refineCut V Bl) := by
  apply strictMono_nat_of_lt_succ
  intro n
  have hlt := refineIdx_lt hBl n
  rw [refineCut_succ hV hBl hlab n]
  unfold refineCut
  rw [pieceOff_succ _ hlt]
  have : 0 < (Bl (refineIdx Bl n).1)[(refineIdx Bl n).2].length :=
    List.length_pos_iff.mpr (hpieces _ _ (List.getElem_mem hlt))
  push_cast
  omega

/-- **Refining stretches of pieces into a factorization**: a cut sequence whose stretches are
flattenings of nonempty pieces of type `σ`, with the prefix `[t + 1, V 0)` of type `α`, witnesses
`(α, σ) ∈ FwdTypes c t`. -/
theorem mem_fwdTypes_of_pieces [Finite sig.preds] {t : ℤ} {α σ : KType sig k}
    (hV : StrictMono V) (h0 : t + 1 ≤ V 0) (hBl : ∀ a, Bl a ≠ [])
    (hpieces : ∀ a, ∀ p ∈ Bl a, p ≠ [] ∧ kTypeOf sig k (listSeg p) = σ)
    (hlab : ∀ a, labels c (V a) (V (a + 1)) = (Bl a).flatten)
    (hα : kTypeOf sig k (listSeg (labels c (t + 1) (V 0))) = α) :
    (α, σ) ∈ FwdTypes sig k c t := by
  refine ⟨refineCut V Bl, refineCut_strictMono hV hBl (fun a p hp => (hpieces a p hp).1) hlab,
    by rw [refineCut_zero]; exact h0, ?_, fun i => ?_⟩
  · rw [kTypeOf_segZ_eq_listSeg, refineCut_zero]
    exact hα
  · rw [kTypeOf_segZ_eq_listSeg, labels_refineCut hV hBl hlab i]
    exact (hpieces _ _ (List.getElem_mem (refineIdx_lt hBl i))).2

end RefineCut

/-! ## Forward transport

(★₊): a forward tail type `(α, σ)` of `c` is a forward tail type of a bounded one-sided periodic
colouring `fwdPeriodic u v t` whose forward tail types are all forward tail types of `c`. The
prefix `u` and the period `v` are bounded representatives (`exists_rep_of_length_lt`) of the
Ramsey prefix and the first Ramsey block of `exists_blocks_fwd`; membership is read off the two
profiles through `prefixStar_iff_profile`/`starPlus_iff_profile` and refined
(`mem_fwdTypes_of_stretches`); containment is the cut transport — two cuts of a factorization of
the periodic tail at the same offset `o` of the period bound a stretch `v[o, |v|) · v^(s-1) ·
v[0, o)` in `L_σ'^+`, whose profile is matched block by block in `c` by cuts chosen from the
equal cut profiles (`profile_flatten_congr`), so the matched cuts factor `c`'s tail the same
way. -/

section ForwardTransport

variable {sig k}

theorem forall₂_append' {α β : Type} {R : α → β → Prop} {l₁ u₁ : List α} {l₂ u₂ : List β}
    (h₁ : List.Forall₂ R l₁ l₂) (h₂ : List.Forall₂ R u₁ u₂) :
    List.Forall₂ R (l₁ ++ u₁) (l₂ ++ u₂) := by
  induction h₁ with
  | nil => simpa using h₂
  | cons hab _ ih => exact List.Forall₂.cons hab ih

theorem forall₂_map_replicate {α β : Type} {R : α → β → Prop} {f : ℕ → α} {x : β} (n : ℕ)
    (h : ∀ i < n, R (f i) x) :
    List.Forall₂ R ((List.range n).map f) (List.replicate n x) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [List.range_succ, List.map_append, List.replicate_succ', List.map_singleton]
    exact forall₂_append' (ih fun i hi => h i (by omega))
      (List.Forall₂.cons (h n (by omega)) List.Forall₂.nil)

/-- The label list between two cuts of a cut sequence is the flattening of the blocks between
them. -/
theorem labels_blocks (c : sig.preds → ℤ → Prop) [∀ p, DecidablePred (c p)] {V : ℕ → ℤ}
    (hV : StrictMono V) (n d : ℕ) :
    labels c (V n) (V (n + d)) =
      ((List.range d).map fun i => labels c (V (n + i)) (V (n + i + 1))).flatten := by
  induction d with
  | zero =>
    rw [Nat.add_zero]
    apply List.eq_nil_of_length_eq_zero
    rw [labels_length]
    simp
  | succ d ih =>
    rw [← Nat.add_assoc, labels_append c (V n) (V (n + d)) (V (n + d + 1))
      (hV.monotone (Nat.le_add_right n d)) (hV.monotone (Nat.le_succ (n + d))), ih,
      List.range_succ, List.map_append, List.flatten_append, List.map_singleton,
      List.flatten_cons, List.flatten_nil, List.append_nil]

/-- **Reading `d` periods from the `n`-th**: the label list on
`[b + |m| + n·|v|, b + |m| + (n + d)·|v|)` is `v^d`. -/
theorem labels_periodicColouring_replicate' (w m v : List (sig.preds → Bool)) (b : ℤ) (n d : ℕ) :
    labels (periodicColouring sig w m v b) (b + m.length + n * v.length)
      (b + m.length + ((n + d : ℕ) : ℤ) * v.length) = (List.replicate d v).flatten := by
  induction d with
  | zero =>
    rw [Nat.add_zero]
    apply List.eq_nil_of_length_eq_zero
    rw [labels_length]
    simp
  | succ d ih =>
    have hnv : (0 : ℤ) ≤ (n : ℤ) * v.length := by positivity
    have hdv : (0 : ℤ) ≤ (d : ℤ) * v.length := by positivity
    have e1 : ((n + d : ℕ) : ℤ) * v.length = n * v.length + d * v.length := by push_cast; ring
    have e2 : ((n + (d + 1) : ℕ) : ℤ) * v.length = n * v.length + d * v.length + v.length := by
      push_cast; ring
    rw [labels_append _ (b + m.length + n * v.length) (b + m.length + ((n + d : ℕ) : ℤ) * v.length)
      _ (by rw [e1]; omega) (by rw [e1, e2]; omega), ih]
    have h := labels_periodicColouring_period w m v b (n + d)
    rw [show b + (m.length : ℤ) + ((n + (d + 1) : ℕ) : ℤ) * v.length =
      b + m.length + (((n + d : ℕ) : ℤ) + 1) * v.length by push_cast; ring, h,
      List.replicate_succ', List.flatten_append, List.flatten_cons, List.flatten_nil,
      List.append_nil]

/-- The forward periodic colouring on `[t + 1, t + 1 + |u| + a₀·|v| + o)` reads
`u · v^a₀ · v[0, o)`. -/
theorem labels_fwdPeriodic_prefix (u v : List (sig.preds → Bool)) (t : ℤ) (a₀ o : ℕ)
    (ho : o ≤ v.length) :
    labels (fwdPeriodic sig u v t) (t + 1) (t + 1 + u.length + a₀ * v.length + o) =
      u ++ (List.replicate a₀ v).flatten ++ v.take o := by
  have hnv : (0 : ℤ) ≤ (a₀ : ℤ) * v.length := by positivity
  rw [labels_append _ (t + 1) (t + 1 + u.length) _ (by omega) (by omega),
    labels_append _ (t + 1 + u.length) (t + 1 + u.length + a₀ * v.length) _ (by omega) (by omega)]
  have h3 := labels_periodicColouring_slice v u v (t + 1) a₀ 0 o (Nat.zero_le _) ho
  rw [Nat.cast_zero, add_zero, List.drop_zero, Nat.sub_zero] at h3
  rw [labels_periodicColouring_mid, labels_periodicColouring_replicate, h3, List.append_assoc]

/-- The forward periodic colouring on the stretch between two cuts at the same offset `o` of
periods `a₀` and `a₀ + s` reads `v[o, |v|) · v^(s - 1) · v[0, o)`. -/
theorem labels_fwdPeriodic_stretch (u v : List (sig.preds → Bool)) (t : ℤ) (a₀ s o : ℕ)
    (ho : o ≤ v.length) (hs : 1 ≤ s) :
    labels (fwdPeriodic sig u v t) (t + 1 + u.length + a₀ * v.length + o)
        (t + 1 + u.length + ((a₀ + s : ℕ) : ℤ) * v.length + o) =
      v.drop o ++ (List.replicate (s - 1) v).flatten ++ v.take o := by
  have hnv : (0 : ℤ) ≤ (a₀ : ℤ) * v.length := by positivity
  have hs1 : (0 : ℤ) ≤ ((s - 1 : ℕ) : ℤ) * v.length := by positivity
  have e1 : ((a₀ + 1 : ℕ) : ℤ) * v.length = a₀ * v.length + v.length := by push_cast; ring
  have e2 : ((a₀ + s : ℕ) : ℤ) * v.length = ((a₀ + 1 : ℕ) : ℤ) * v.length +
      ((s - 1 : ℕ) : ℤ) * v.length := by
    rw [show a₀ + s = (a₀ + 1) + (s - 1) by omega]
    push_cast
    ring
  rw [labels_append _ _ (t + 1 + u.length + ((a₀ + 1 : ℕ) : ℤ) * v.length) _
      (by rw [e1]; omega) (by rw [e2]; omega),
    labels_append _ (t + 1 + u.length + ((a₀ + 1 : ℕ) : ℤ) * v.length)
      (t + 1 + u.length + ((a₀ + s : ℕ) : ℤ) * v.length) _ (by rw [e2]; omega) (by omega)]
  have h1 := labels_periodicColouring_slice v u v (t + 1) a₀ o v.length ho le_rfl
  rw [List.take_of_length_le (by rw [List.length_drop]),
    show t + 1 + (u.length : ℤ) + a₀ * v.length + v.length =
      t + 1 + u.length + ((a₀ + 1 : ℕ) : ℤ) * v.length by push_cast; ring] at h1
  have h2 := labels_periodicColouring_replicate' v u v (t + 1) (a₀ + 1) (s - 1)
  rw [show a₀ + 1 + (s - 1) = a₀ + s by omega] at h2
  have h3 := labels_periodicColouring_slice v u v (t + 1) (a₀ + s) 0 o (Nat.zero_le _) ho
  rw [Nat.cast_zero, add_zero, List.drop_zero, Nat.sub_zero] at h3
  rw [h1, h2, h3, List.append_assoc]

/-- Two of any `L + 1` cuts have the same offset modulo `L`. -/
theorem exists_offset_collision (W : ℕ → ℤ) (base : ℤ) {L : ℕ} (hL : 0 < L) :
    ∃ i j, i < j ∧ (W i - base).toNat % L = (W j - base).toNat % L := by
  obtain ⟨i, j, hne, heq⟩ := Fintype.exists_ne_map_eq_of_card_lt
    (fun r : Fin (L + 1) => (⟨(W r.1 - base).toNat % L, Nat.mod_lt _ hL⟩ : Fin L))
    (by simp)
  have heq' : (W i.1 - base).toNat % L = (W j.1 - base).toNat % L := congrArg Fin.val heq
  rcases lt_or_gt_of_ne (Fin.val_ne_of_ne hne) with hij | hij
  · exact ⟨i.1, j.1, hij, heq'⟩
  · exact ⟨j.1, i.1, hij, heq'.symm⟩

/-- **Stretches in `L_α L_σ^*` and `L_σ^+` witness a forward tail type**: merge the prefix's
pieces into the first block and refine (`mem_fwdTypes_of_pieces`). -/
theorem mem_fwdTypes_of_stretches [Finite sig.preds] {c : sig.preds → ℤ → Prop}
    [∀ p, DecidablePred (c p)] {t : ℤ} {α σ : KType sig k} {V : ℕ → ℤ}
    (hV : StrictMono V) (h0 : t + 1 ≤ V 0)
    (hp : PrefixStar sig k α σ (labels c (t + 1) (V 0)))
    (hs : ∀ a, StarPlus sig k σ (labels c (V a) (V (a + 1)))) :
    (α, σ) ∈ FwdTypes sig k c t := by
  obtain ⟨p, q, hpq, hpα, ps₀, hps₀, rfl⟩ := hp
  choose ps hps using hs
  obtain ⟨hp1, hp2⟩ := labels_split_of_eq_append c hpq
  have hlen : (V 0 - (t + 1)).toNat = p.length + ps₀.flatten.length := by
    rw [← labels_length c (t + 1) (V 0), hpq, List.length_append]
  have hpV : t + 1 + p.length ≤ V 0 := by omega
  let V' : ℕ → ℤ := fun a => match a with
    | 0 => t + 1 + p.length
    | a + 1 => V (a + 1)
  let Bl : ℕ → List (List (sig.preds → Bool)) := fun a => match a with
    | 0 => ps₀ ++ ps 0
    | a + 1 => ps (a + 1)
  have hV'0 : V' 0 = t + 1 + p.length := rfl
  have hV's : ∀ a, V' (a + 1) = V (a + 1) := fun _ => rfl
  have hBl0 : Bl 0 = ps₀ ++ ps 0 := rfl
  have hBls : ∀ a, Bl (a + 1) = ps (a + 1) := fun _ => rfl
  refine mem_fwdTypes_of_pieces (V := V') (Bl := Bl) ?_ (by rw [hV'0]; omega) ?_ ?_ ?_ ?_
  · apply strictMono_nat_of_lt_succ
    intro a
    cases a with
    | zero =>
      rw [hV'0]
      change t + 1 + (p.length : ℤ) < V 1
      have := hV Nat.zero_lt_one
      omega
    | succ a =>
      rw [hV's, hV's]
      exact hV (show a + 1 < a + 1 + 1 by omega)
  · intro a
    cases a with
    | zero =>
      rw [hBl0]
      simp [(hps 0).1]
    | succ a =>
      rw [hBls]
      exact (hps (a + 1)).1
  · intro a x hx
    cases a with
    | zero =>
      rw [hBl0] at hx
      rcases List.mem_append.mp hx with h | h
      · exact hps₀ x h
      · exact (hps 0).2.1 x h
    | succ a =>
      rw [hBls] at hx
      exact (hps (a + 1)).2.1 x hx
  · intro a
    cases a with
    | zero =>
      rw [hV'0, hV's, hBl0, List.flatten_append,
        labels_append c (t + 1 + p.length) (V 0) (V (0 + 1)) hpV
          (hV.monotone (Nat.zero_le _)), hp2, (hps 0).2.2]
    | succ a =>
      rw [hV's, hV's, hBls]
      exact ((hps (a + 1)).2.2).symm
  · rw [hV'0, hp1]
    exact hpα

/-- **The cut transport**: every forward tail type of the bounded periodic witness built from the
Ramsey blocks of `c` is a forward tail type of `c`. -/
theorem fwdTypes_fwdPeriodic_subset [Finite sig.preds] (hk : 1 ≤ k) {c : sig.preds → ℤ → Prop}
    [∀ p, DecidablePred (c p)] {t : ℤ} {V : ℕ → ℤ} (hV : StrictMono V) (h0 : t + 1 ≤ V 0)
    {E : Profile sig k} {CP : Set (Profile sig k × Profile sig k)}
    (hprof : ∀ a, profile sig k (labels c (V a) (V (a + 1))) = E)
    (hcut : ∀ a, cutProfile sig k (labels c (V a) (V (a + 1))) = CP)
    {u v : List (sig.preds → Bool)} (hv : v ≠ [])
    (hu : profile sig k u = profile sig k (labels c (t + 1) (V 0)))
    (hvE : profile sig k v = E) (hcv : cutProfile sig k v ⊆ CP) :
    FwdTypes sig k (fwdPeriodic sig u v t) t ⊆ FwdTypes sig k c t := by
  rintro ⟨α', σ'⟩ ⟨W', hW', hW'0, hα', hσ'⟩
  simp only at hα' hσ'
  rw [kTypeOf_segZ_eq_listSeg] at hα'
  simp only [kTypeOf_segZ_eq_listSeg] at hσ'
  have hLpos : 0 < v.length := List.length_pos_iff.mpr hv
  have hW'base : ∀ r, t + 1 + u.length ≤ W' (u.length + r) := fun r => by
    have := strictMono_le_add_nat hW' (u.length + r)
    push_cast at this
    omega
  obtain ⟨i, j, hij, hoff⟩ :=
    exists_offset_collision (fun r => W' (u.length + r)) (t + 1 + u.length) hLpos
  -- the two collided cuts, in period/offset form
  have hdi := Nat.div_add_mod (W' (u.length + i) - (t + 1 + u.length)).toNat v.length
  have hdj := Nat.div_add_mod (W' (u.length + j) - (t + 1 + u.length)).toNat v.length
  set a₀ := (W' (u.length + i) - (t + 1 + u.length)).toNat / v.length with ha₀
  set a₁ := (W' (u.length + j) - (t + 1 + u.length)).toNat / v.length with ha₁
  set o := (W' (u.length + i) - (t + 1 + u.length)).toNat % v.length with ho
  have hoL : o < v.length := Nat.mod_lt _ hLpos
  rw [← hoff] at hdj
  have hWi : W' (u.length + i) = t + 1 + u.length + a₀ * v.length + o := by
    have h := Int.toNat_of_nonneg (show 0 ≤ W' (u.length + i) - (t + 1 + u.length) from
      by have := hW'base i; omega)
    rw [← hdi] at h
    push_cast at h
    linarith
  have hWj : W' (u.length + j) = t + 1 + u.length + a₁ * v.length + o := by
    have h := Int.toNat_of_nonneg (show 0 ≤ W' (u.length + j) - (t + 1 + u.length) from
      by have := hW'base j; omega)
    rw [← hdj] at h
    push_cast at h
    linarith
  have hWij : W' (u.length + i) < W' (u.length + j) := hW' (by omega)
  have ha : a₀ < a₁ := by
    by_contra h
    have h' : a₁ ≤ a₀ := not_lt.mp h
    have : (a₁ : ℤ) * v.length ≤ a₀ * v.length := by
      exact_mod_cast Nat.mul_le_mul_right v.length h'
    omega
  set s := a₁ - a₀ with hs
  have hs1 : 1 ≤ s := by omega
  have ha₁s : a₁ = a₀ + s := by omega
  -- the periodic side: prefix and stretch, in `L_α' L_σ'^*` and `L_σ'^+`
  have hpre : labels (fwdPeriodic sig u v t) (t + 1) (W' (u.length + i)) =
      u ++ (List.replicate a₀ v).flatten ++ v.take o := by
    rw [hWi]
    exact labels_fwdPeriodic_prefix u v t a₀ o hoL.le
  have hstr : labels (fwdPeriodic sig u v t) (W' (u.length + i)) (W' (u.length + j)) =
      v.drop o ++ (List.replicate (s - 1) v).flatten ++ v.take o := by
    rw [hWi, hWj, ha₁s]
    exact labels_fwdPeriodic_stretch u v t a₀ s o hoL.le hs1
  have hpre' : PrefixStar sig k α' σ'
      (labels (fwdPeriodic sig u v t) (t + 1) (W' (u.length + i))) := by
    rw [labels_append _ (t + 1) (W' 0) (W' (u.length + i)) hW'0
      (hW'.monotone (Nat.zero_le _))]
    exact ⟨_, _, rfl, hα', by simpa using starZero_labels hW' hσ' 0 (u.length + i)⟩
  have hstr' : StarPlus sig k σ'
      (labels (fwdPeriodic sig u v t) (W' (u.length + i)) (W' (u.length + j))) := by
    rw [starPlus_iff]
    refine ⟨?_, ?_⟩
    · apply List.ne_nil_of_length_pos
      rw [labels_length]
      omega
    · have := starZero_labels hW' hσ' (u.length + i) (j - i)
      rwa [show u.length + i + (j - i) = u.length + j by omega] at this
  -- the cut choice in every block of `c`
  have hcutv : (profile sig k (v.take o), profile sig k (v.drop o)) ∈ cutProfile sig k v :=
    ⟨v.take o, v.drop o, (List.take_append_drop o v).symm, rfl⟩
  have hcut' : ∀ a, ∃ z y : List (sig.preds → Bool), labels c (V a) (V (a + 1)) = z ++ y ∧
      profile sig k z = profile sig k (v.take o) ∧ profile sig k y = profile sig k (v.drop o) := by
    intro a
    have hmem : (profile sig k (v.take o), profile sig k (v.drop o)) ∈
        cutProfile sig k (labels c (V a) (V (a + 1))) := by
      rw [hcut a]
      exact hcv hcutv
    obtain ⟨z, y, hzy, hpr⟩ := hmem
    exact ⟨z, y, hzy, (Prod.mk.inj hpr).1.symm, (Prod.mk.inj hpr).2.symm⟩
  choose z y hzy hz hy using hcut'
  have hXz : ∀ a, labels c (V a) (V a + (z a).length) = z a :=
    fun a => (labels_split_of_eq_append c (hzy a)).1
  have hXy : ∀ a, labels c (V a + (z a).length) (V (a + 1)) = y a :=
    fun a => (labels_split_of_eq_append c (hzy a)).2
  have hyne : ∀ a, y a ≠ [] := fun a =>
    ne_nil_of_kTypeOf_eq hk (kTypeOf_eq_of_profile_eq (hy a).symm)
      (by rw [ne_eq, List.drop_eq_nil_iff]; omega)
  have hXlt : ∀ a, V a + (z a).length < V (a + 1) := fun a => by
    have h1 := labels_length c (V a + (z a).length) (V (a + 1))
    rw [hXy a] at h1
    have h2 := List.length_pos_iff.mpr (hyne a)
    omega
  have hVle : ∀ a d, V a ≤ V (a + d) := fun a d => hV.monotone (Nat.le_add_right a d)
  -- the matched prefix of `c`
  have hcpre : profile sig k (labels c (t + 1) (V a₀ + (z a₀).length)) =
      profile sig k (labels (fwdPeriodic sig u v t) (t + 1) (W' (u.length + i))) := by
    rw [hpre, labels_append c (t + 1) (V 0) _ h0 (by have := hVle 0 a₀; simp at this; omega),
      labels_append c (V 0) (V a₀) _ (by simpa using hVle 0 a₀) (by omega), hXz a₀,
      show V a₀ = V (0 + a₀) by rw [Nat.zero_add], labels_blocks c hV 0 a₀]
    have := profile_flatten_congr hk (sig := sig) (k := k)
      (L := [labels c (t + 1) (V 0)] ++
        (List.range a₀).map (fun i => labels c (V (0 + i)) (V (0 + i + 1))) ++ [z a₀])
      (L' := [u] ++ List.replicate a₀ v ++ [v.take o])
      (forall₂_append' (forall₂_append' (List.Forall₂.cons hu.symm List.Forall₂.nil)
        (forall₂_map_replicate a₀ fun i _ => by rw [hprof]; exact hvE.symm))
        (List.Forall₂.cons (hz a₀) List.Forall₂.nil))
    simpa [List.flatten_append] using this
  -- the matched stretches of `c`
  have hcstr : ∀ a, profile sig k (labels c (V a + (z a).length) (V (a + s) + (z (a + s)).length)) =
      profile sig k
        (labels (fwdPeriodic sig u v t) (W' (u.length + i)) (W' (u.length + j))) := by
    intro a
    have has : a + 1 + (s - 1) = a + s := by omega
    have hV1s : V (a + 1) ≤ V (a + s) := by
      have := hVle (a + 1) (s - 1)
      rwa [has] at this
    rw [hstr, labels_append c _ (V (a + 1)) _ (hXlt a).le (by omega),
      labels_append c (V (a + 1)) (V (a + s)) _ hV1s (by omega),
      hXy a, hXz (a + s), show V (a + s) = V (a + 1 + (s - 1)) by rw [has],
      labels_blocks c hV (a + 1) (s - 1)]
    have := profile_flatten_congr hk (sig := sig) (k := k)
      (L := [y a] ++ (List.range (s - 1)).map
        (fun i => labels c (V (a + 1 + i)) (V (a + 1 + i + 1))) ++ [z (a + s)])
      (L' := [v.drop o] ++ List.replicate (s - 1) v ++ [v.take o])
      (forall₂_append' (forall₂_append' (List.Forall₂.cons (hy a) List.Forall₂.nil)
        (forall₂_map_replicate (s - 1) fun i _ => by rw [hprof]; exact hvE.symm))
        (List.Forall₂.cons (hz (a + s)) List.Forall₂.nil))
    simpa [List.flatten_append] using this
  -- assemble the refined factorization of `c`
  refine mem_fwdTypes_of_stretches (V := fun n => V (a₀ + n * s) + (z (a₀ + n * s)).length)
    ?_ ?_ ?_ ?_
  · apply strictMono_nat_of_lt_succ
    intro n
    change V (a₀ + n * s) + ((z (a₀ + n * s)).length : ℤ) <
      V (a₀ + (n + 1) * s) + ((z (a₀ + (n + 1) * s)).length : ℤ)
    have h1 := hXlt (a₀ + n * s)
    have h2 := hVle (a₀ + n * s + 1) (s - 1)
    rw [show a₀ + n * s + 1 + (s - 1) = a₀ + (n + 1) * s by
      rw [Nat.add_mul, Nat.one_mul]; omega] at h2
    have h3 : (0 : ℤ) ≤ (z (a₀ + (n + 1) * s)).length := by positivity
    omega
  · rw [Nat.zero_mul, Nat.add_zero]
    have := hVle 0 a₀
    rw [Nat.zero_add] at this
    have h3 : (0 : ℤ) ≤ (z a₀).length := by positivity
    omega
  · rw [Nat.zero_mul, Nat.add_zero]
    exact prefixStar_of_profile_eq hk hcpre.symm hpre'
  · intro n
    rw [show a₀ + (n + 1) * s = a₀ + n * s + s by rw [Nat.add_mul, Nat.one_mul]; omega]
    exact starPlus_of_profile_eq hk (hcstr (a₀ + n * s)).symm hstr'

/-- **(★₊) Forward transport.** Every forward tail type of `c` from `t` is a forward tail type of
a bounded one-sided periodic colouring `fwdPeriodic u v t` — prefix and period both shorter than
`Nat.card (Profile sig k) ^ 2`, a count of pairs of profiles — whose forward tail types are all
forward tail types of `c`. -/
theorem exists_periodic_fwd [Finite sig.preds] (hk : 1 ≤ k) (c : sig.preds → ℤ → Prop) (t : ℤ)
    {x : KType sig k × KType sig k} (hx : x ∈ FwdTypes sig k c t) :
    ∃ u v : List (sig.preds → Bool), v ≠ [] ∧
      u.length < Nat.card (Profile sig k) ^ 2 ∧ v.length < Nat.card (Profile sig k) ^ 2 ∧
      x ∈ FwdTypes sig k (fwdPeriodic sig u v t) t ∧
      FwdTypes sig k (fwdPeriodic sig u v t) t ⊆ FwdTypes sig k c t := by
  classical
  obtain ⟨α, σ⟩ := x
  obtain ⟨V, E, CP, hV, h0, hp, hs, hprof, hcut⟩ := exists_blocks_fwd hx
  obtain ⟨u, hul, hup, hucp⟩ := exists_rep_of_length_lt hk (labels c (t + 1) (V 0))
  obtain ⟨v, hvne, hvl, hvp, hvcp⟩ := exists_rep_of_length_lt_ne_nil hk
    (l := labels c (V 0) (V (0 + 1))) (starPlus_iff.mp (hs 0)).1
  have hLpos : 0 < v.length := List.length_pos_iff.mpr hvne
  refine ⟨u, v, hvne, hul, hvl, ?_, ?_⟩
  · refine mem_fwdTypes_of_stretches (V := fun a => t + 1 + u.length + a * v.length) ?_ ?_ ?_ ?_
    · apply strictMono_nat_of_lt_succ
      intro n
      push_cast
      nlinarith
    · simp
    · simp only [Nat.cast_zero, zero_mul, add_zero]
      rw [labels_periodicColouring_mid]
      exact prefixStar_of_profile_eq hk hup.symm hp
    · intro a
      have h := labels_periodicColouring_period v u v (t + 1) a
      rw [Nat.cast_succ]
      change StarPlus sig k σ (labels (periodicColouring sig v u v (t + 1)) _ _)
      rw [h]
      exact starPlus_of_profile_eq hk hvp.symm (hs 0)
  · exact fwdTypes_fwdPeriodic_subset hk hV h0 hprof hcut hvne hup
      (hvp.trans (hprof 0)) (hvcp.trans (by rw [hcut 0]))

end ForwardTransport

/-! ## Reversal: the order dual and the reflected colouring

The backward statement is the forward one on the reflected colouring
`reflectColouring c p z := c p (-z)`.
What makes this a transfer rather than a duplication is that the `k`-type of a reversed word is
a function of the `k`-type of the word (`kTypeOf_listSeg_reverse_congr`): `k`-equivalence is the
Ehrenfeucht–Fraïssé game `kEquiv_iff_backForth`, whose atoms are predicates at points and the
order between two points, and reversing the order sends the atom `order i j` to `order j i` —
so a Duplicator strategy for `M`, `N` is one for their order duals
(`backForth_of_dualStructure` in `GroupModel/MonoDiscrete.lean`, whose `dualStructure` is
reused here; `kEquiv_dual` is its converse through the double dual). The
reversal is packaged as a classical involution `revType` on `k`-types, the backward tail types
are the forward tail types of the reflection up to `revType` (`mem_bwdTypes_iff_reflect`), and
the reflection of `bwdPeriodic w u t` is `fwdPeriodic u.reverse w.reverse (-t)`
(`reflectColouring_bwdPeriodic`). This is the precedent-free alternative to applying Ramsey once per
orientation; the forward transport is applied once, to the reflection. -/

section Reversal

variable {sig k}

/-- `k`-equivalent structures have `k`-equivalent order duals: the converse of
`kEquiv_of_dualStructure` (`GroupModel/MonoDiscrete.lean`), through the double dual, which is
order-isomorphic to the original by `OrderIso.dualDual`. -/
theorem kEquiv_dual [Finite sig.preds] {M N : OrderedMonadicStructure sig}
    (h : KEquiv sig k M N) : KEquiv sig k (dualStructure M) (dualStructure N) := by
  apply kEquiv_of_dualStructure
  have hM : KEquiv sig k (dualStructure (dualStructure M)) M :=
    k_equiv_of_iso sig k _ _ (OrderIso.dualDual M.carrier).symm (fun _ _ => Iff.rfl)
  have hN : KEquiv sig k (dualStructure (dualStructure N)) N :=
    k_equiv_of_iso sig k _ _ (OrderIso.dualDual N.carrier).symm (fun _ _ => Iff.rfl)
  exact hM.trans (h.trans hN.symm)

/-- The reversed list segment is the order dual of the list segment. -/
theorem listSeg_reverse_kEquiv_dual [Finite sig.preds] (l : List (sig.preds → Bool)) :
    KEquiv sig k (listSeg l.reverse) (dualStructure (listSeg l)) := by
  have hlen : l.reverse.length = l.length := List.length_reverse
  let f : (listSeg l.reverse).carrier → (dualStructure (listSeg l)).carrier :=
    fun i => OrderDual.toDual (⟨l.length - 1 - i.1, by have := i.2; omega⟩ : Fin l.length)
  have hf : StrictMono f := by
    rintro ⟨i, hi⟩ ⟨j, hj⟩ hij
    change (⟨l.length - 1 - j, _⟩ : Fin l.length) < ⟨l.length - 1 - i, _⟩
    rw [Fin.mk_lt_mk]
    have : i < j := hij
    omega
  have hs : Function.Surjective f := by
    intro m
    have hm := (OrderDual.ofDual m).2
    refine ⟨⟨l.length - 1 - (OrderDual.ofDual m).1, by omega⟩, ?_⟩
    apply OrderDual.ofDual.injective
    apply Fin.ext
    change l.length - 1 - (l.length - 1 - (OrderDual.ofDual m).1) = (OrderDual.ofDual m).1
    omega
  refine k_equiv_of_iso sig k _ _ (StrictMono.orderIsoOfSurjective f hf hs) ?_
  rintro p ⟨i, hi⟩
  change (l.reverse[i]'hi) p = true ↔ (l[l.length - 1 - i]'(by omega)) p = true
  rw [List.getElem_reverse]

/-- **Reversal transfer**: the `k`-type of the reversal of a word is a function of the `k`-type
of the word. -/
theorem kTypeOf_listSeg_reverse_congr [Finite sig.preds] {l l' : List (sig.preds → Bool)}
    (h : kTypeOf sig k (listSeg l) = kTypeOf sig k (listSeg l')) :
    kTypeOf sig k (listSeg l.reverse) = kTypeOf sig k (listSeg l'.reverse) :=
  (listSeg_reverse_kEquiv_dual l).trans
    ((kEquiv_dual h).trans (listSeg_reverse_kEquiv_dual l').symm)

open Classical in
/-- **The reversal of a `k`-type**, as a classical involution: the type of the reversal of any
representative, and the type itself when it has no finite representative. -/
noncomputable def revType (τ : KType sig k) : KType sig k :=
  if h : ∃ l : List (sig.preds → Bool), kTypeOf sig k (listSeg l) = τ then
    kTypeOf sig k (listSeg h.choose.reverse)
  else τ

theorem revType_listSeg [Finite sig.preds] (l : List (sig.preds → Bool)) :
    revType (kTypeOf sig k (listSeg l)) = kTypeOf sig k (listSeg l.reverse) := by
  unfold revType
  rw [dif_pos (⟨l, rfl⟩ :
    ∃ l' : List (sig.preds → Bool), kTypeOf sig k (listSeg l') = kTypeOf sig k (listSeg l))]
  exact kTypeOf_listSeg_reverse_congr (Classical.choose_spec (⟨l, rfl⟩ :
    ∃ l' : List (sig.preds → Bool), kTypeOf sig k (listSeg l') = kTypeOf sig k (listSeg l)))

theorem revType_revType [Finite sig.preds] (τ : KType sig k) : revType (revType τ) = τ := by
  by_cases h : ∃ l : List (sig.preds → Bool), kTypeOf sig k (listSeg l) = τ
  · obtain ⟨l, rfl⟩ := h
    rw [revType_listSeg, revType_listSeg, List.reverse_reverse]
  · unfold revType
    rw [dif_neg h, dif_neg h]

theorem revType_injective [Finite sig.preds] :
    Function.Injective (revType (sig := sig) (k := k)) :=
  Function.LeftInverse.injective revType_revType

/-- **The reflected colouring**: time reversed about `0`. -/
def reflectColouring (c : sig.preds → ℤ → Prop) : sig.preds → ℤ → Prop := fun p z => c p (-z)

theorem reflectColouring_reflectColouring (c : sig.preds → ℤ → Prop) :
    reflectColouring (reflectColouring c) = c := by
  funext p z
  simp [reflectColouring]

/-- The reflection of a segment is the order dual of the segment. -/
theorem kTypeOf_segZ_reflect [Finite sig.preds] (c : sig.preds → ℤ → Prop) (a b : ℤ) :
    kTypeOf sig k (segZ sig (reflectColouring c) (1 - b) (1 - a)) =
      kTypeOf sig k (dualStructure (segZ sig c a b)) := by
  let f : (segZ sig (reflectColouring c) (1 - b) (1 - a)).carrier →
      (dualStructure (segZ sig c a b)).carrier :=
    fun z => OrderDual.toDual (⟨-z.1, by have := z.2; omega⟩ : (segZ sig c a b).carrier)
  have hf : StrictMono f := by
    rintro ⟨i, hi⟩ ⟨j, hj⟩ hij
    change (⟨-j, _⟩ : (segZ sig c a b).carrier) < ⟨-i, _⟩
    rw [Subtype.mk_lt_mk]
    have : i < j := hij
    omega
  have hs : Function.Surjective f := by
    intro m
    have hm := (OrderDual.ofDual m).2
    refine ⟨⟨-(OrderDual.ofDual m).1, by omega⟩, ?_⟩
    apply OrderDual.ofDual.injective
    apply Subtype.ext
    change -(-(OrderDual.ofDual m).1) = (OrderDual.ofDual m).1
    omega
  refine k_equiv_of_iso sig k _ _ (StrictMono.orderIsoOfSurjective f hf hs) ?_
  rintro p ⟨z, hz⟩
  exact Iff.rfl

/-- The reversal of the `k`-type of a segment is the `k`-type of the reflected segment. -/
theorem revType_segZ [Finite sig.preds] (c : sig.preds → ℤ → Prop) (a b : ℤ) :
    revType (kTypeOf sig k (segZ sig c a b)) =
      kTypeOf sig k (segZ sig (reflectColouring c) (1 - b) (1 - a)) := by
  classical
  rw [kTypeOf_segZ_eq_listSeg c a b k, revType_listSeg, kTypeOf_segZ_reflect]
  exact (listSeg_reverse_kEquiv_dual _).trans (kEquiv_dual (kTypeOf_segZ_eq_listSeg c a b k).symm)

/-- **The backward tail types are the forward tail types of the reflection**, up to reversal of
the two types. -/
theorem mem_bwdTypes_iff_reflect [Finite sig.preds] (c : sig.preds → ℤ → Prop) (t : ℤ)
    (x : KType sig k × KType sig k) :
    x ∈ BwdTypes sig k c t ↔
      (revType x.2, revType x.1) ∈ FwdTypes sig k (reflectColouring c) (-t) := by
  constructor
  · rintro ⟨W, hW, h0, h1, h2⟩
    refine ⟨fun i => 1 - W i, fun i j hij => by have := hW hij; simp only; omega,
      by simp only; omega, ?_, fun i => ?_⟩
    · simp only
      rw [show -t + 1 = 1 - t by ring, ← revType_segZ, h1]
    · simp only
      rw [← revType_segZ, h2]
  · rintro ⟨W, hW, h0, h1, h2⟩
    simp only at h1 h2
    refine ⟨fun i => 1 - W i, fun i j hij => by have := hW hij; simp only; omega,
      by simp only; omega, ?_, fun i => ?_⟩
    · simp only
      apply revType_injective
      rw [revType_segZ, show 1 - (1 - W 0) = W 0 by ring, ← h1, show -t + 1 = 1 - t by ring]
    · simp only
      apply revType_injective
      rw [revType_segZ, show 1 - (1 - W i) = W i by ring,
        show 1 - (1 - W (i + 1)) = W (i + 1) by ring]
      exact h2 i

/-- Reading a reversed list at `i` is reading the list at `|l| - 1 - i`. -/
theorem getD_reverse {L : Type} [Inhabited L] (l : List L) {i : ℕ} (hi : i < l.length) :
    l.reverse.getD i default = l.getD (l.length - 1 - i) default := by
  rw [List.getD_eq_getElem?_getD, List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem (by rw [List.length_reverse]; exact hi),
    List.getElem?_eq_getElem (by omega), List.getElem_reverse]

/-- The residue of `-(n + 1)` modulo `L > 0` is `L - 1 - n % L`. -/
theorem toNat_neg_succ_emod (n L : ℕ) (hL : 0 < L) :
    ((-((n : ℤ) + 1)) % L).toNat = L - 1 - n % L := by
  have hdm := Nat.div_add_mod n L
  have hlt := Nat.mod_lt n hL
  have h : -((n : ℤ) + 1) = ((L - 1 - n % L : ℕ) : ℤ) + (L : ℤ) * (-((n / L : ℕ) : ℤ) - 1) := by
    push_cast [show n % L ≤ L - 1 by omega, show 1 ≤ L by omega]
    have : ((L : ℕ) : ℤ) * ((n / L : ℕ) : ℤ) + ((n % L : ℕ) : ℤ) = n := by exact_mod_cast hdm
    linarith
  rw [h, Int.add_mul_emod_self_left, Int.emod_eq_of_lt (by omega) (by omega), Int.toNat_natCast]

/-- **The reflection of the backward periodic colouring is the forward periodic colouring of the
reversed words.** -/
theorem reflectColouring_bwdPeriodic (w u : List (sig.preds → Bool)) (t : ℤ) (hw : w ≠ []) :
    reflectColouring (bwdPeriodic sig w u t) = fwdPeriodic sig u.reverse w.reverse (-t) := by
  have hL : 0 < w.length := List.length_pos_iff.mpr hw
  funext p z
  simp only [reflectColouring, fwdPeriodic, bwdPeriodic, periodicColouring]
  rw [eq_iff_iff]
  apply Eq.to_iff
  congr 1
  by_cases hA : z < -t + 1
  · -- `-z ≥ t`: in the `w^ω` part of the backward colouring, the `w^(ω*)` part of the forward one
    rw [periodicLetter_of_ge w u w (t - u.length) (by omega),
      periodicLetter_of_lt w.reverse u.reverse w.reverse (-t + 1) hA]
    set n := (-z - t).toNat with hn
    have hn' : (n : ℤ) = -z - t := Int.toNat_of_nonneg (by omega)
    rw [show -z - (t - (u.length : ℤ)) - u.length = n by omega,
      show z - (-t + 1) = -((n : ℤ) + 1) by omega, List.length_reverse, toNat_neg_succ_emod n _ hL,
      ← Int.natCast_emod, Int.toNat_natCast,
      getD_reverse w (i := w.length - 1 - n % w.length) (by omega)]
    have := Nat.mod_lt n hL
    rw [show w.length - 1 - (w.length - 1 - n % w.length) = n % w.length by omega]
  · by_cases hB : z < -t + 1 + u.length
    · -- in `u`, read backwards
      rw [periodicLetter_of_mid w u w (t - u.length) (by omega) (by omega),
        periodicLetter_of_mid w.reverse u.reverse w.reverse (-t + 1) (by omega)
          (by rw [List.length_reverse]; omega),
        getD_reverse u (i := (z - (-t + 1)).toNat) (by omega)]
      rw [show u.length - 1 - (z - (-t + 1)).toNat = (-z - (t - (u.length : ℤ))).toNat by omega]
    · -- `-z < t - |u|`: in the `w^(ω*)` part of the backward colouring, the `w^ω` part of the
      -- forward one
      rw [periodicLetter_of_lt w u w (t - u.length) (by omega),
        periodicLetter_of_ge w.reverse u.reverse w.reverse (-t + 1)
          (by rw [List.length_reverse]; omega)]
      set n := (z + t - 1 - u.length).toNat with hn
      have hn' : (n : ℤ) = z + t - 1 - u.length := Int.toNat_of_nonneg (by omega)
      have hmod := Nat.mod_lt n hL
      rw [show -z - (t - (u.length : ℤ)) = -((n : ℤ) + 1) by omega,
        show z - (-t + 1) - (u.reverse.length : ℤ) = n by rw [List.length_reverse]; omega,
        List.length_reverse, toNat_neg_succ_emod n _ hL, ← Int.natCast_emod, Int.toNat_natCast,
        getD_reverse w (i := (n % w.length)) hmod]

/-- **(★₋) Backward transport**: the forward transport applied to the reflected colouring. -/
theorem exists_periodic_bwd [Finite sig.preds] (hk : 1 ≤ k) (c : sig.preds → ℤ → Prop) (t : ℤ)
    {x : KType sig k × KType sig k} (hx : x ∈ BwdTypes sig k c t) :
    ∃ w u : List (sig.preds → Bool), w ≠ [] ∧
      w.length < Nat.card (Profile sig k) ^ 2 ∧ u.length < Nat.card (Profile sig k) ^ 2 ∧
      x ∈ BwdTypes sig k (bwdPeriodic sig w u t) t ∧
      BwdTypes sig k (bwdPeriodic sig w u t) t ⊆ BwdTypes sig k c t := by
  rw [mem_bwdTypes_iff_reflect] at hx
  obtain ⟨u', v', hv', hu'l, hv'l, hmem, hsub⟩ :=
    exists_periodic_fwd hk (reflectColouring c) (-t) hx
  have hw : v'.reverse ≠ [] := by simpa using hv'
  refine ⟨v'.reverse, u'.reverse, hw, by simpa using hv'l, by simpa using hu'l, ?_, ?_⟩
  · rw [mem_bwdTypes_iff_reflect, reflectColouring_bwdPeriodic _ _ _ hw, List.reverse_reverse,
      List.reverse_reverse]
    exact hmem
  · intro y hy
    rw [mem_bwdTypes_iff_reflect] at hy ⊢
    rw [reflectColouring_bwdPeriodic _ _ _ hw, List.reverse_reverse, List.reverse_reverse] at hy
    exact hsub hy

end Reversal

/-! ## Family triples through the seam

A colouring whose `now` letter holds exactly at `t` has every factorization's middle segment
`[W 0, W 1)` containing `t` (`now_mem_middle`: a non-middle segment containing `t` would force,
by `exists_interp_iff_of_kTypeOf_eq`, a second `now` position in its neighbour of the same
type), so its family triples are exactly the triples `(σ₋, τ, σ₊)` with `(σ₋, β)` a backward
tail pair, `(α, σ₊)` a forward tail pair, and `τ` the type of `β · ℓ · α` for the letter `ℓ`
at `t` (`mem_familyTriples_iff_tails`). The middle type is stated through representatives, as
every composition in this cluster is (`kTypeOf_listSeg_append_congr`). -/

section Seam

open FormalSystem.Metalogic.Decidability.RaySummary (familyTriples mem_familyTriples)

variable {sig k}

/-- The letter of a colouring at a time, classically. -/
noncomputable def letterAt (c : sig.preds → ℤ → Prop) (t : ℤ) : sig.preds → Bool :=
  fun p => @decide (c p t) (Classical.propDecidable _)

theorem labels_single (c : sig.preds → ℤ → Prop) [∀ p, DecidablePred (c p)] (t : ℤ) :
    labels c t (t + 1) = [letterAt c t] := by
  apply List.ext_getElem
  · rw [labels_length]
    simp
  · intro i h₁ h₂
    rw [labels_length] at h₁
    have hi : i = 0 := by omega
    subst hi
    funext p
    rw [labels_getElem, Nat.cast_zero, add_zero]
    simp only [List.getElem_cons_zero, letterAt]
    exact decide_eq_decide.mpr Iff.rfl

/-- Two distinct segments of a monotone cut sequence with the same `k`-type cannot both avoid
and contain `now`: if `t` lies in one, `now` is realized in the other too (type-visible at
`k ≥ 1`), at a second position. -/
theorem not_now_of_eq_segments (hk : 1 ≤ k) {c : sig.preds → ℤ → Prop}
    {now : sig.preds} {t : ℤ} (hnow : ∀ z, c now z ↔ z = t) {W : ℤ → ℤ} (hW : Monotone W)
    {za zb : ℤ} (hne : za ≠ zb)
    (hab : kTypeOf sig k (segZ sig c (W za) (W (za + 1))) =
      kTypeOf sig k (segZ sig c (W zb) (W (zb + 1)))) :
    ¬ (W za ≤ t ∧ t < W (za + 1)) := by
  rintro ⟨hl, hr⟩
  have hex : ∃ x : (segZ sig c (W za) (W (za + 1))).carrier,
      (segZ sig c (W za) (W (za + 1))).interp now x := ⟨⟨t, hl, hr⟩, (hnow t).mpr rfl⟩
  obtain ⟨⟨z, hz1, hz2⟩, hz⟩ := (exists_interp_iff_of_kTypeOf_eq hk now hab).mp hex
  have hzt : z = t := (hnow z).mp hz
  subst hzt
  rcases lt_or_gt_of_ne hne with h | h
  · have := hW (show za + 1 ≤ zb by omega)
    omega
  · have := hW (show zb + 1 ≤ za by omega)
    omega

/-- **`now` sits in the middle segment of every factorization** of a colouring with `now`
exactly at `t`, at `k ≥ 1`. -/
theorem now_mem_middle [Fintype sig.preds] [DecidableEq sig.preds]
    (hk : 1 ≤ k) {c : sig.preds → ℤ → Prop}
    (F : SegmentFactorization sig k c) {now : sig.preds} {t : ℤ}
    (hnow : ∀ z, c now z ↔ z = t) : F.W 0 ≤ t ∧ t < F.W 1 := by
  obtain ⟨z, hz1, hz2⟩ := F.cover t
  rcases lt_trichotomy z 0 with hz | rfl | hz
  · exact absurd ⟨hz1, hz2⟩ (not_now_of_eq_segments hk hnow F.mono (show z ≠ z - 1 by omega)
      ((F.neg_type z hz).trans (F.neg_type (z - 1) (by omega)).symm))
  · exact ⟨hz1, by simpa using hz2⟩
  · exact absurd ⟨hz1, hz2⟩ (not_now_of_eq_segments hk hnow F.mono (show z ≠ z + 1 by omega)
      ((F.pos_type z hz).trans (F.pos_type (z + 1) (by omega)).symm))

/-- The segments of a factorization are nonempty, at `k ≥ 1`: the extremal ones are by
`strict_pos`/`strict_neg`, and nonemptiness is type-visible. -/
theorem segmentFactorization_lt [Fintype sig.preds] [DecidableEq sig.preds]
    (hk : 1 ≤ k) {c : sig.preds → ℤ → Prop}
    (F : SegmentFactorization sig k c) (z : ℤ) (hz : z ≠ 0) : F.W z < F.W (z + 1) := by
  rcases lt_or_gt_of_ne hz with h | h
  · have hne : Nonempty (segZ sig c (F.W (-2)) (F.W (-1))).carrier :=
      ⟨⟨F.W (-2), le_rfl, F.strict_neg⟩⟩
    have heq : kTypeOf sig k (segZ sig c (F.W z) (F.W (z + 1))) =
        kTypeOf sig k (segZ sig c (F.W (-2)) (F.W (-1))) := by
      rw [F.neg_type z h]
      have := F.neg_type (-2) (by norm_num)
      rw [show (-2 : ℤ) + 1 = -1 by norm_num] at this
      exact this.symm
    obtain ⟨⟨s, hs1, hs2⟩⟩ := (nonempty_iff_of_kTypeOf_eq hk heq).mpr hne
    omega
  · have hne : Nonempty (segZ sig c (F.W 1) (F.W 2)).carrier :=
      ⟨⟨F.W 1, le_rfl, F.strict_pos⟩⟩
    have heq : kTypeOf sig k (segZ sig c (F.W z) (F.W (z + 1))) =
        kTypeOf sig k (segZ sig c (F.W 1) (F.W 2)) := by
      rw [F.pos_type z h]
      have := F.pos_type 1 (by norm_num)
      rw [show (1 : ℤ) + 1 = 2 by norm_num] at this
      exact this.symm
    obtain ⟨⟨s, hs1, hs2⟩⟩ := (nonempty_iff_of_kTypeOf_eq hk heq).mpr hne
    omega

/-- **Family triples through the seam.** -/
theorem mem_familyTriples_iff_tails [Fintype sig.preds] [DecidableEq sig.preds]
    (hk : 1 ≤ k) {c : sig.preds → ℤ → Prop}
    {now : sig.preds} {t : ℤ} (hnow : ∀ z, c now z ↔ z = t)
    (x : KType sig k × KType sig k × KType sig k) :
    x ∈ familyTriples sig k c ↔
      ∃ β α : KType sig k, (x.1, β) ∈ BwdTypes sig k c t ∧ (α, x.2.2) ∈ FwdTypes sig k c t ∧
        ∃ lβ lα : List (sig.preds → Bool), kTypeOf sig k (listSeg lβ) = β ∧
          kTypeOf sig k (listSeg lα) = α ∧
          x.2.1 = kTypeOf sig k (listSeg (lβ ++ letterAt c t :: lα)) := by
  classical
  constructor
  · rintro ⟨F, hneg, hzero, hpos⟩
    obtain ⟨h0, h1⟩ := now_mem_middle hk F hnow
    refine ⟨kTypeOf sig k (segZ sig c (F.W 0) t), kTypeOf sig k (segZ sig c (t + 1) (F.W 1)),
      ⟨fun i => F.W (-(i : ℤ)), ?_, by simpa using h0, rfl, fun i => ?_⟩,
      ⟨fun i => F.W ((i : ℤ) + 1), ?_, by simpa using h1, rfl, fun i => ?_⟩,
      labels c (F.W 0) t, labels c (t + 1) (F.W 1), (kTypeOf_segZ_eq_listSeg _ _ _ k).symm,
      (kTypeOf_segZ_eq_listSeg _ _ _ k).symm, ?_⟩
    · apply strictAnti_nat_of_succ_lt
      intro i
      have := segmentFactorization_lt hk F (-((i : ℤ) + 1)) (by omega)
      simp only [Nat.cast_succ]
      rwa [show -((i : ℤ) + 1) + 1 = -(i : ℤ) by ring] at this
    · simp only [Nat.cast_succ]
      rw [← hneg, ← F.neg_type (-((i : ℤ) + 1)) (by omega),
        show -((i : ℤ) + 1) + 1 = -(i : ℤ) by ring]
    · apply strictMono_nat_of_lt_succ
      intro i
      have := segmentFactorization_lt hk F ((i : ℤ) + 1) (by omega)
      simp only [Nat.cast_succ]
      exact this
    · simp only [Nat.cast_succ]
      rw [← hpos, ← F.pos_type ((i : ℤ) + 1) (by omega)]
    · rw [← hzero, ← F.zero_type, kTypeOf_segZ_eq_listSeg,
        labels_append c (F.W 0) t (F.W 1) h0 (by omega),
        labels_append c t (t + 1) (F.W 1) (by omega) (by omega), labels_single,
        List.singleton_append]
  · rintro ⟨β, α, ⟨Wb, hWb, hb0, hb1, hb2⟩, ⟨Wf, hWf, hf0, hf1, hf2⟩, lβ, lα, hlβ, hlα, hmid⟩
    simp only at hb1 hb2 hf1 hf2
    let W : ℤ → ℤ := fun z => if 0 < z then Wf (z - 1).toNat else Wb (-z).toNat
    have hWpos : ∀ z : ℤ, 0 < z → W z = Wf (z - 1).toNat := fun z hz => if_pos hz
    have hWnonpos : ∀ z : ℤ, ¬ 0 < z → W z = Wb (-z).toNat := fun z hz => if_neg hz
    have hW0 : W 0 = Wb 0 := hWnonpos 0 (by omega)
    have hW1 : W 1 = Wf 0 := hWpos 1 (by omega)
    have hbf : Wb 0 < Wf 0 := by omega
    have hmono : Monotone W := by
      intro z z' hzz'
      by_cases hz : 0 < z
      · rw [hWpos z hz, hWpos z' (by omega)]
        exact hWf.monotone (by omega)
      · by_cases hz' : 0 < z'
        · rw [hWnonpos z hz, hWpos z' hz']
          have h1 := hWb.antitone (Nat.zero_le (-z).toNat)
          have h2 := hWf.monotone (Nat.zero_le (z' - 1).toNat)
          omega
        · rw [hWnonpos z hz, hWnonpos z' hz']
          exact hWb.antitone (by omega)
    refine ⟨⟨W, hmono, ?_, x.2.2, x.1, ?_, ?_, ?_, ?_, x.2.1, ?_⟩, rfl, rfl, rfl⟩
    · intro s
      by_cases hs1 : Wf 0 ≤ s
      · obtain ⟨i, hi1, hi2⟩ := exists_seg_of_strictMono hWf hs1
        refine ⟨(i : ℤ) + 1, ?_, ?_⟩
        · rw [hWpos _ (by omega), show ((i : ℤ) + 1 - 1).toNat = i by omega]
          exact hi1
        · rw [hWpos _ (by omega), show ((i : ℤ) + 1 + 1 - 1).toNat = i + 1 by omega]
          exact hi2
      · by_cases hs2 : s < Wb 0
        · obtain ⟨i, hi1, hi2⟩ := exists_seg_of_strictAnti hWb hs2
          refine ⟨-((i : ℤ) + 1), ?_, ?_⟩
          · rw [hWnonpos _ (by omega), show (-(-((i : ℤ) + 1))).toNat = i + 1 by omega]
            exact hi1
          · rw [hWnonpos _ (by omega), show (-(-((i : ℤ) + 1) + 1)).toNat = i by omega]
            exact hi2
        · exact ⟨0, by rw [hW0]; omega, by rw [zero_add, hW1]; omega⟩
    · intro z hz
      rw [hWpos z hz, hWpos (z + 1) (by omega), show (z + 1 - 1).toNat = (z - 1).toNat + 1 by omega]
      exact hf2 _
    · intro z hz
      rw [hWnonpos z (by omega)]
      obtain ⟨n, hn⟩ : ∃ n : ℕ, (-z).toNat = n + 1 := ⟨(-z).toNat - 1, by omega⟩
      rw [hn]
      have : W (z + 1) = Wb n := by
        by_cases hz1 : 0 < z + 1
        · omega
        · rw [hWnonpos _ hz1]
          congr 1
          omega
      rw [this]
      exact hb2 n
    · rw [hW1, hWpos 2 (by norm_num), show ((2 : ℤ) - 1).toNat = 1 by norm_num]
      exact hWf (show 0 < 1 by norm_num)
    · rw [hWnonpos (-2) (by norm_num), hWnonpos (-1) (by norm_num),
        show (-(-2 : ℤ)).toNat = 2 by decide, show (-(-1 : ℤ)).toNat = 1 by decide]
      exact hWb (show 1 < 2 by norm_num)
    · rw [hW0, hW1, kTypeOf_segZ_eq_listSeg, labels_append c (Wb 0) t (Wf 0) hb0 (by omega),
        labels_append c t (t + 1) (Wf 0) (by omega) (by omega), labels_single, hmid]
      rw [kTypeOf_segZ_eq_listSeg] at hb1 hf1
      change kTypeOf sig k (listSeg (labels c (Wb 0) t ++ ([letterAt c t] ++
        labels c (t + 1) (Wf 0)))) = kTypeOf sig k (listSeg (lβ ++ ([letterAt c t] ++ lα)))
      exact kTypeOf_listSeg_append_congr k (hb1.trans hlβ.symm)
        (kTypeOf_listSeg_append_congr k rfl (hf1.trans hlα.symm))

end Seam

/-! ## The seam assembly

(★): every family triple of a colouring with `now` exactly at `t` is a family triple of a
bounded bi-ultimately-periodic colouring, with `now` exactly at `t`, whose family triples all
belong to the original's. The backward and forward transports supply `w, u_b` and `u_f, v`; the
glued colouring `w^(ω*) · (u_b · ℓ · u_f) · v^ω` with `ℓ` the letter at `t` agrees with
`bwdPeriodic w u_b t` before `t` and with `fwdPeriodic u_f v t` after `t`
(`periodicLetter_glue_lt`, `periodicLetter_glue_gt`), so its tail types are theirs
(`bwdTypes_congr`, `fwdTypes_congr`); `now` holds exactly at `t` because a tail type shared
with a `now`-free tail is realized `now`-free (`fwd_now_free_transfer`, type-visibility at
`k ≥ 1`). The length of the middle word is `|u_b| + 1 + |u_f| ≤ 2 · Nat.card (Profile sig k) ^ 2`,
a count of pairs of profiles. -/

section Assembly

open FormalSystem.Metalogic.Decidability.RaySummary (familyTriples mem_familyTriples)

variable {sig k}

/-- A forward tail type shared with a `now`-free forward tail is realized `now`-free: every time
after `t` lies in a segment of the factorization, whose type is that of a `now`-free segment. -/
theorem fwd_now_free_transfer (hk : 1 ≤ k) {c c' : sig.preds → ℤ → Prop}
    {now : sig.preds} {t : ℤ} (hc : ∀ z, t < z → ¬ c now z) {α σ : KType sig k}
    (hx : (α, σ) ∈ FwdTypes sig k c t) (hx' : (α, σ) ∈ FwdTypes sig k c' t) :
    ∀ z, t < z → ¬ c' now z := by
  obtain ⟨W, hW, h0, hα, hσ⟩ := hx
  obtain ⟨W', hW', h0', hα', hσ'⟩ := hx'
  simp only at hα hσ hα' hσ'
  intro z hz hnz
  by_cases hzW : z < W' 0
  · have hex : ∃ x : (segZ sig c' (t + 1) (W' 0)).carrier,
        (segZ sig c' (t + 1) (W' 0)).interp now x := ⟨⟨z, by omega, hzW⟩, hnz⟩
    obtain ⟨⟨y, hy1, hy2⟩, hy⟩ :=
      (exists_interp_iff_of_kTypeOf_eq hk now (hα'.trans hα.symm)).mp hex
    exact hc y (by omega) hy
  · obtain ⟨i, hi1, hi2⟩ := exists_seg_of_strictMono hW' (not_lt.mp hzW)
    have hex : ∃ x : (segZ sig c' (W' i) (W' (i + 1))).carrier,
        (segZ sig c' (W' i) (W' (i + 1))).interp now x := ⟨⟨z, hi1, hi2⟩, hnz⟩
    obtain ⟨⟨y, hy1, hy2⟩, hy⟩ :=
      (exists_interp_iff_of_kTypeOf_eq hk now ((hσ' i).trans (hσ i).symm)).mp hex
    have := h0.trans (hW.monotone (Nat.zero_le i))
    exact hc y (by omega) hy

/-- The backward mirror, through the reflection. -/
theorem bwd_now_free_transfer [Finite sig.preds] (hk : 1 ≤ k) {c c' : sig.preds → ℤ → Prop}
    {now : sig.preds} {t : ℤ} (hc : ∀ z, z < t → ¬ c now z) {x : KType sig k × KType sig k}
    (hx : x ∈ BwdTypes sig k c t) (hx' : x ∈ BwdTypes sig k c' t) :
    ∀ z, z < t → ¬ c' now z := by
  rw [mem_bwdTypes_iff_reflect] at hx hx'
  have h := fwd_now_free_transfer hk (c := reflectColouring c) (c' := reflectColouring c')
    (now := now) (t := -t) (fun z hz => hc (-z) (by omega)) hx hx'
  intro z hz hnz
  exact h (-z) (by omega) (by simpa [reflectColouring] using hnz)

/-- Reading a list at an index below the length of its first part. -/
theorem getD_append_of_lt {L : Type} [Inhabited L] (l₁ l₂ : List L) {i : ℕ} (hi : i < l₁.length) :
    (l₁ ++ l₂).getD i default = l₁.getD i default := by
  rw [List.getD_eq_getElem?_getD, List.getD_eq_getElem?_getD, List.getElem?_append_left hi]

/-- Reading a list past its first part. -/
theorem getD_append_of_le {L : Type} [Inhabited L] (l₁ l₂ : List L) {i : ℕ} (hi : l₁.length ≤ i) :
    (l₁ ++ l₂).getD i default = l₂.getD (i - l₁.length) default := by
  rw [List.getD_eq_getElem?_getD, List.getD_eq_getElem?_getD, List.getElem?_append_right hi]

/-- Before `t`, the glued colouring reads the backward periodic one. -/
theorem periodicLetter_glue_lt (w ub uf v : List (sig.preds → Bool)) (ℓ : sig.preds → Bool)
    (t z : ℤ) (hz : z < t) :
    periodicLetter sig w (ub ++ ℓ :: uf) v (t - ub.length) z =
      periodicLetter sig w ub w (t - ub.length) z := by
  have hm : ((ub ++ ℓ :: uf).length : ℤ) = ub.length + 1 + uf.length := by
    rw [List.length_append, List.length_cons]
    push_cast
    ring
  by_cases hzb : z < t - ub.length
  · rw [periodicLetter_of_lt _ _ _ _ hzb, periodicLetter_of_lt _ _ _ _ hzb]
  · rw [periodicLetter_of_mid _ _ _ _ (by omega) (by rw [hm]; omega),
      periodicLetter_of_mid _ _ _ _ (by omega) (by omega), getD_append_of_lt _ _ (by omega)]

/-- After `t`, the glued colouring reads the forward periodic one. -/
theorem periodicLetter_glue_gt (w ub uf v : List (sig.preds → Bool)) (ℓ : sig.preds → Bool)
    (t z : ℤ) (hz : t < z) :
    periodicLetter sig w (ub ++ ℓ :: uf) v (t - ub.length) z =
      periodicLetter sig v uf v (t + 1) z := by
  have hm : ((ub ++ ℓ :: uf).length : ℤ) = ub.length + 1 + uf.length := by
    rw [List.length_append, List.length_cons]
    push_cast
    ring
  by_cases hzf : z < t + 1 + uf.length
  · rw [periodicLetter_of_mid _ _ _ _ (by omega) (by rw [hm]; omega),
      periodicLetter_of_mid _ _ _ _ (by omega) hzf, getD_append_of_le _ _ (by omega),
      show (z - (t - (ub.length : ℤ))).toNat - ub.length = (z - (t + 1)).toNat + 1 by omega,
      List.getD_cons_succ]
  · rw [periodicLetter_of_ge _ _ _ _ (by rw [hm]; omega),
      periodicLetter_of_ge _ _ _ _ (by omega), hm]
    ring_nf

/-- At `t`, the glued colouring reads `ℓ`. -/
theorem periodicLetter_glue_t (w ub uf v : List (sig.preds → Bool)) (ℓ : sig.preds → Bool)
    (t : ℤ) : periodicLetter sig w (ub ++ ℓ :: uf) v (t - ub.length) t = ℓ := by
  have hm : ((ub ++ ℓ :: uf).length : ℤ) = ub.length + 1 + uf.length := by
    rw [List.length_append, List.length_cons]
    push_cast
    ring
  rw [periodicLetter_of_mid _ _ _ _ (by omega) (by rw [hm]; omega),
    getD_append_of_le _ _ (by omega),
    show (t - (t - (ub.length : ℤ))).toNat - ub.length = 0 by omega]
  rfl

/-- **(★) The seam assembly.** Every family triple of a colouring with `now` exactly at `t` is a
family triple of a bounded bi-ultimately-periodic colouring with `now` exactly at `t`, whose
family triples all belong to the original's. The bounds count pairs of profiles.

Paper: — (the formalization's own realizability device; HWZ 2000 Def. 12 and Thm 14 orient the
quasimodel shape and source no claim) -/
theorem exists_periodic_subfamily [Fintype sig.preds] [DecidableEq sig.preds] (hk : 1 ≤ k)
    (c : sig.preds → ℤ → Prop)
    (now : sig.preds) (t : ℤ) (hnow : ∀ z, c now z ↔ z = t)
    {x : KType sig k × KType sig k × KType sig k} (hx : x ∈ familyTriples sig k c) :
    ∃ (w m v : List (sig.preds → Bool)) (b : ℤ), w ≠ [] ∧ v ≠ [] ∧
      w.length < Nat.card (Profile sig k) ^ 2 ∧ m.length ≤ 2 * Nat.card (Profile sig k) ^ 2 ∧
      v.length < Nat.card (Profile sig k) ^ 2 ∧
      (∀ z, periodicColouring sig w m v b now z ↔ z = t) ∧
      x ∈ familyTriples sig k (periodicColouring sig w m v b) ∧
      familyTriples sig k (periodicColouring sig w m v b) ⊆ familyTriples sig k c := by
  classical
  obtain ⟨β, α, hb, hf, lβ, lα, hlβ, hlα, hmid⟩ := (mem_familyTriples_iff_tails hk hnow x).mp hx
  obtain ⟨w, ub, hw, hwl, hubl, hbmem, hbsub⟩ := exists_periodic_bwd hk c t hb
  obtain ⟨uf, v, hv, hufl, hvl, hfmem, hfsub⟩ := exists_periodic_fwd hk c t hf
  have hagree_b : ∀ p z, z < t →
      (periodicColouring sig w (ub ++ letterAt c t :: uf) v (t - ub.length) p z ↔
        bwdPeriodic sig w ub t p z) := fun p z hz => by
    simp only [periodicColouring, bwdPeriodic, periodicLetter_glue_lt w ub uf v _ t z hz]
  have hagree_f : ∀ p z, t < z →
      (periodicColouring sig w (ub ++ letterAt c t :: uf) v (t - ub.length) p z ↔
        fwdPeriodic sig uf v t p z) := fun p z hz => by
    simp only [periodicColouring, fwdPeriodic, periodicLetter_glue_gt w ub uf v _ t z hz]
  have ht : ∀ p, periodicColouring sig w (ub ++ letterAt c t :: uf) v (t - ub.length) p t ↔
      c p t := fun p => by
    simp only [periodicColouring, periodicLetter_glue_t, letterAt, decide_eq_true_iff]
  have hB := bwdTypes_congr (k := k) hagree_b
  have hF := fwdTypes_congr (k := k) hagree_f
  have hnow' : ∀ z, periodicColouring sig w (ub ++ letterAt c t :: uf) v (t - ub.length) now z ↔
      z = t := by
    intro z
    rcases lt_trichotomy z t with h | rfl | h
    · rw [hagree_b now z h]
      constructor
      · intro hc
        exact absurd hc (bwd_now_free_transfer hk
          (fun z' hz' hc' => by rw [hnow] at hc'; omega) hb (hB ▸ hbmem) z h)
      · intro h'
        omega
    · simp only [ht, hnow]
    · rw [hagree_f now z h]
      constructor
      · intro hc
        exact absurd hc (fwd_now_free_transfer hk
          (fun z' hz' hc' => by rw [hnow] at hc'; omega) hf (hF ▸ hfmem) z h)
      · intro h'
        omega
  have hletter :
      letterAt (periodicColouring sig w (ub ++ letterAt c t :: uf) v (t - ub.length)) t =
        letterAt c t := by
    funext p
    simp only [letterAt]
    exact decide_eq_decide.mpr (ht p)
  refine ⟨w, ub ++ letterAt c t :: uf, v, t - ub.length, hw, hv, hwl, ?_, hvl, hnow', ?_, ?_⟩
  · rw [List.length_append, List.length_cons]
    omega
  · rw [mem_familyTriples_iff_tails hk hnow', hletter]
    exact ⟨β, α, hB ▸ hbmem, hF ▸ hfmem, lβ, lα, hlβ, hlα, hmid⟩
  · intro y hy
    rw [mem_familyTriples_iff_tails hk hnow', hletter] at hy
    rw [mem_familyTriples_iff_tails hk hnow]
    obtain ⟨β', α', hb', hf', lβ', lα', h1, h2, h3⟩ := hy
    exact ⟨β', α', hbsub (hB ▸ hb'), hfsub (hF ▸ hf'), lβ', lα', h1, h2, h3⟩

end Assembly

end FormalSystem.Metalogic.WeakCanonical
