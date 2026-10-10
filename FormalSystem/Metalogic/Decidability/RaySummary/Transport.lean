/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Compose
import FormalSystem.Metalogic.Decidability.RaySummary.Trace
import FormalSystem.Metalogic.WeakCanonical.Transfer

/-!
# Transport of a family triple along the deletion of a constant run

`Compose.lean` makes the `k`-type of a constant block `ℓ^m` eventually periodic in `m`, with
the threshold and the period together bounded by the count `Nat.card (KType sig k)`
(`kTypeOf_listSeg_replicate_eventually_periodic_bounded`). That is a statement about ONE finite
block. A family triple of a bi-infinite colouring `c` (`InFamily`, `KTypeSummary/Family.lean`)
is a statement about a `SegmentFactorization` of `c` — a monotone covering cutting sequence
`W : ℤ → ℤ` whose segments carry the three types `(τneg, τzero, τpos)`. This module is the
bridge between the two: it says when the periodicity of a block lets a factorization of `c` be
re-cut into a factorization of the colouring `deleteRun c s p` obtained from `c` by deleting
the `p` positions `[s, s + p)`, with the same triple.

## The keystone

`segZ_const_of_kTypeOf_eq_replicate`: at depth `k ≥ 1`, a segment of the time axis whose
`k`-type is that of a NONEMPTY constant block `ℓ^j` is itself nonempty and reads `ℓ` at every
position. Two depth-`1` sentences transfer along the `k`-equivalence (`k_equiv_monotone` to depth
`1`, then `k_equiv_preserves_sentence`): `∃ x, ¬ x < x` carries nonemptiness, and for each
predicate `P` the sentence `∀ x, P x` (or `∀ x, ¬ P x`, as the letter dictates) carries
constancy. At depth `0` nothing of the sort holds — depth-`0` sentences cannot see a point — so
every statement that uses the keystone carries `(hk : 1 ≤ k)`.

## The surgery, and what it does NOT claim

`inFamily_of_shrink_run`: if a factorization `F` of `c` has a segment `[W z₀, W (z₀ + 1))`
containing a constant run `[s, s + j)` of letter `ℓ`, and `m₀ + p ≤ j` where `(m₀, p)` is a
threshold/period pair for `ℓ` (an explicit HYPOTHESIS `hper`, so the surgery is independent of
how the pair arises — `Compose.lean`'s theorem is plugged in only at the use site), then
`deleteRun c s p` has a factorization with the SAME triple: the cutting sequence is `W` up to
`z₀` and `W - p` beyond, the segments below `s` keep their letters, the segments above `s + p`
are translated, and the one segment holding the run loses `p` of its `ℓ`-positions — which the
periodicity and the congruence `kTypeOf_listSeg_append_congr` make invisible to its `k`-type.

The single-segment containment is a hypothesis, not a theorem: the "re-cut" case — a run met by
several short segments, none of which can absorb the `p` positions — is NOT handled here. The
honest general threshold for an unconditioned statement is `3 · (m₀ + p)` (at most three
segments meet a maximal run, so a run of that length has a piece of length `≥ m₀ + p` inside one
of them); it is not claimed, and no statement here reads `InFamily c ↔ InFamily c'`. Only the
shrink direction is landed. On fixture model A of the wired probe
`specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` the containment is a
theorem of the fixture, discharged there, and the corollary `familyTriples_subset_deleteRun`
is what that probe consumes.

## Decidability

`labels` (`Compose.lean`) needs a `DecidablePred` instance on the colouring, so every statement
about `labels` below carries `[∀ P, DecidablePred (c P)]`, and `deleteRun` inherits its instance
from `c`'s (`deleteRunDecidablePred`). Every statement whose conclusion mentions only `kTypeOf`,
`InFamily` or `familyTriples` is instance-free and discharges the instance by `classical` in its
proof, so a `Prop`-valued colouring such as a closure trace needs no instance to use the surgery.

## No complexity bound

None is claimed, upper or lower. `m₀ + p ≤ Nat.card (KType sig k)` is a COUNT of depth-`k`
types and nothing else — see `Compose.lean`'s "Eventual periodicity of constant blocks" section
for the disclaimer, quoted from `AnchorLayer.lean`.

## Main definitions and results

* `segZ_const_of_kTypeOf_eq_replicate` — the keystone: a segment with the `k`-type of a nonempty
  constant block is a nonempty constant block (`k ≥ 1`).
* `deleteRun` — the colouring with the positions `[s, s + p)` deleted; `labels_deleteRun_below`,
  `labels_deleteRun_above`, `kTypeOf_segZ_deleteRun_below`, `kTypeOf_segZ_deleteRun_above` — the
  untouched and the translated segments keep their letters and their `k`-types.
* `kTypeOf_segZ_deleteRun_of_const_run` — the segment holding the run keeps its `k`-type, with
  the threshold/period pair an explicit hypothesis.
* `inFamily_of_shrink_run` — the surgery; `inFamily_deleteRun_of_inFamily`,
  `familyTriples_subset_deleteRun` — its `InFamily` and `familyTriples` forms under a
  containment hypothesis quantified over every factorization.

## References

* [W. Thomas, *Ehrenfeucht-Fraïssé games, the composition method, and the monadic theory of
  ordinal words*, 1997] for the composition method the congruence instantiates.
* [K. Doets, *Monadic Π¹₁-theories of Π¹₁-properties*, 1989] for Lemma 1.1, the `k`-type /
  sentence transfer the keystone runs on (`k_equiv_preserves_sentence`).
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.Expressiveness

variable {sig : MonadicSignature}

/-! ## Two depth-`1` sentences -/

/-- The depth-`1` sentence `∃ x, ¬ x < x`: true exactly on a nonempty carrier. -/
def exTop : MonadicSentence sig := .ex (.not (.lt 0 0))

/-- `exTop` reads nonemptiness. -/
theorem eval_exTop (M : OrderedMonadicStructure sig) :
    eval M Fin.elim0 (exTop (sig := sig)) ↔ Nonempty M.carrier := by
  simp only [exTop, eval, Fin.cons_zero, lt_self_iff_false, not_false_eq_true]
  exact exists_true_iff_nonempty

@[simp] theorem quantifierDepth_exTop : (exTop (sig := sig)).quantifierDepth = 1 := by
  simp [exTop, MonadicFormula.quantifierDepth]

/-- The depth-`1` sentence "every point reads `b` at `P`": `∀ x, P x` when `b = true`,
`∀ x, ¬ P x` when `b = false`. -/
def allAtom (P : sig.preds) (b : Bool) : MonadicSentence sig :=
  .all (bif b then .atom P 0 else .not (.atom P 0))

/-- `allAtom P b` reads constancy of `P` at the value `b`. -/
theorem eval_allAtom (M : OrderedMonadicStructure sig) (P : sig.preds) (b : Bool) :
    eval M Fin.elim0 (allAtom P b) ↔ ∀ x, (M.interp P x ↔ b = true) := by
  cases b <;> simp [allAtom, eval]

@[simp] theorem quantifierDepth_allAtom (P : sig.preds) (b : Bool) :
    (allAtom P b).quantifierDepth = 1 := by
  cases b <;> simp [allAtom, MonadicFormula.quantifierDepth]

/-! ## The keystone -/

/-- **A segment with the `k`-type of a nonempty constant block is a nonempty constant block**
(`k ≥ 1`). The `k`-equivalence is weakened to depth `1` (`k_equiv_monotone`), and the two
depth-`1` sentences `exTop` and `allAtom P (ℓ P)` are transferred from the block to the segment
(`k_equiv_preserves_sentence`): the block is nonempty, so the segment is (`a < b`); the block
reads `ℓ P` at every point for every `P`, so the segment does.

Paper: — (the formalization's own transfer device, Doets 1989 Lemma 1.1 applied to two fixed
depth-`1` sentences; the manuscript carries no counterpart) -/
theorem segZ_const_of_kTypeOf_eq_replicate [Finite sig.preds] {k : ℕ} (hk : 1 ≤ k)
    (c : sig.preds → ℤ → Prop) (a b : ℤ) (ℓ : sig.preds → Bool) {j : ℕ} (hj : 0 < j)
    (h : kTypeOf sig k (segZ sig c a b) = kTypeOf sig k (listSeg (List.replicate j ℓ))) :
    a < b ∧ ∀ s, a ≤ s → s < b → ∀ P, (c P s ↔ ℓ P = true) := by
  have h1 : KEquiv sig 1 (segZ sig c a b) (listSeg (List.replicate j ℓ)) :=
    k_equiv_monotone sig hk h
  constructor
  · have := (k_equiv_preserves_sentence h1 exTop (by simp)).2
    rw [eval_exTop, eval_exTop] at this
    obtain ⟨⟨t, ht⟩⟩ := this ⟨⟨0, by simp; omega⟩⟩
    omega
  · intro s hs hsb P
    have := (k_equiv_preserves_sentence h1 (allAtom P (ℓ P)) (by simp)).2
    rw [eval_allAtom, eval_allAtom] at this
    have hall := this (by
      intro x
      obtain ⟨i, hi⟩ := x
      simp)
    exact hall ⟨s, hs, hsb⟩

/-! ## The deletion colouring -/

/-- **The colouring with the positions `[s, s + p)` deleted**: below `s` it is `c`, at and above
`s` it is `c` read `p` positions later. Its `DecidablePred` instance is inherited from `c`'s
(`deleteRunDecidablePred`). -/
def deleteRun (c : sig.preds → ℤ → Prop) (s : ℤ) (p : ℕ) : sig.preds → ℤ → Prop :=
  fun P u => if u < s then c P u else c P (u + p)

/-- `deleteRun` is decidable when `c` is. -/
instance deleteRunDecidablePred (c : sig.preds → ℤ → Prop) [∀ P, DecidablePred (c P)]
    (s : ℤ) (p : ℕ) : ∀ P, DecidablePred (deleteRun c s p P) :=
  fun P u => inferInstanceAs (Decidable (if u < s then c P u else c P (u + p)))

/-- Below `s`, `deleteRun` is `c`. -/
theorem deleteRun_of_lt {c : sig.preds → ℤ → Prop} {s : ℤ} {p : ℕ} {P : sig.preds} {u : ℤ}
    (h : u < s) : deleteRun c s p P u ↔ c P u := by
  simp [deleteRun, h]

/-- At and above `s`, `deleteRun` is `c` read `p` positions later. -/
theorem deleteRun_of_le {c : sig.preds → ℤ → Prop} {s : ℤ} {p : ℕ} {P : sig.preds} {u : ℤ}
    (h : s ≤ u) : deleteRun c s p P u ↔ c P (u + p) := by
  simp [deleteRun, not_lt.mpr h]

/-! ## Label lists under splitting, constancy and deletion -/

section Labels

variable (c : sig.preds → ℤ → Prop) [∀ P, DecidablePred (c P)]

/-- The label list of `[a, b)` splits at any interior point `m`. -/
theorem labels_append (a m b : ℤ) (ham : a ≤ m) (hmb : m ≤ b) :
    labels c a b = labels c a m ++ labels c m b := by
  apply List.ext_getElem
  · simp only [labels_length, List.length_append]; omega
  · intro i h₁ h₂
    funext P
    by_cases hi : i < (labels c a m).length
    · rw [List.getElem_append_left hi, labels_getElem, labels_getElem]
    · rw [List.getElem_append_right (not_lt.mp hi), labels_getElem, labels_getElem]
      rw [labels_length] at hi
      rw [show a + (i : ℤ) = m + ((i - (labels c a m).length : ℕ) : ℤ) by
        rw [labels_length]; omega]

/-- The label list of a constant run `[s, s + j)` of letter `ℓ` is `ℓ^j`. -/
theorem labels_const (s : ℤ) (j : ℕ) (ℓ : sig.preds → Bool)
    (hconst : ∀ u, s ≤ u → u < s + j → ∀ P, (c P u ↔ ℓ P = true)) :
    labels c s (s + j) = List.replicate j ℓ := by
  apply List.ext_getElem
  · simp only [labels_length, List.length_replicate]; omega
  · intro i h₁ h₂
    funext P
    rw [labels_getElem, List.getElem_replicate, Bool.eq_iff_iff, decide_eq_true_iff]
    rw [labels_length] at h₁
    exact hconst _ (by omega) (by omega) P

/-- The label list of any segment `[a, b)` on which `c` reads the constant letter `ℓ` is
`ℓ^((b - a).toNat)` — the empty-segment case included. -/
theorem labels_eq_replicate_of_const (a b : ℤ) (ℓ : sig.preds → Bool)
    (hconst : ∀ u, a ≤ u → u < b → ∀ P, (c P u ↔ ℓ P = true)) :
    labels c a b = List.replicate (b - a).toNat ℓ := by
  apply List.ext_getElem
  · simp only [labels_length, List.length_replicate]
  · intro i h₁ h₂
    funext P
    rw [labels_getElem, List.getElem_replicate, Bool.eq_iff_iff, decide_eq_true_iff]
    rw [labels_length] at h₁
    exact hconst _ (by omega) (by omega) P

/-- A segment entirely below `s` keeps its letters under `deleteRun`. -/
theorem labels_deleteRun_below (s : ℤ) (p : ℕ) (a b : ℤ) (hb : b ≤ s) :
    labels (deleteRun c s p) a b = labels c a b := by
  apply List.ext_getElem
  · simp only [labels_length]
  · intro i h₁ h₂
    funext P
    rw [labels_getElem, labels_getElem, Bool.eq_iff_iff, decide_eq_true_iff, decide_eq_true_iff]
    rw [labels_length] at h₁
    exact deleteRun_of_lt (by omega)

/-- A segment at or above `s` reads, under `deleteRun`, the letters of its translate by `p`. -/
theorem labels_deleteRun_above (s : ℤ) (p : ℕ) (a b : ℤ) (ha : s ≤ a) :
    labels (deleteRun c s p) a b = labels c (a + p) (b + p) := by
  apply List.ext_getElem
  · simp only [labels_length]; congr 1; omega
  · intro i h₁ h₂
    funext P
    rw [labels_getElem, labels_getElem, Bool.eq_iff_iff, decide_eq_true_iff, decide_eq_true_iff,
      deleteRun_of_le (by omega)]
    rw [show a + (i : ℤ) + p = a + p + i by omega]

end Labels

/-! ## Segment `k`-types under deletion -/

/-- A segment on which `c` reads the constant letter `ℓ` has the `k`-type of the constant block
of its length. Instance-free; the empty segment is the empty block. -/
theorem kTypeOf_segZ_eq_replicate_of_const [Finite sig.preds] (k : ℕ)
    (c : sig.preds → ℤ → Prop) (a b : ℤ) (ℓ : sig.preds → Bool)
    (hconst : ∀ u, a ≤ u → u < b → ∀ P, (c P u ↔ ℓ P = true)) :
    kTypeOf sig k (segZ sig c a b) = kTypeOf sig k (listSeg (List.replicate (b - a).toNat ℓ)) := by
  classical
  rw [kTypeOf_segZ_eq_listSeg, labels_eq_replicate_of_const c a b ℓ hconst]

/-- A segment entirely below `s` keeps its `k`-type under `deleteRun`. -/
theorem kTypeOf_segZ_deleteRun_below [Finite sig.preds] (k : ℕ) (c : sig.preds → ℤ → Prop)
    (s : ℤ) (p : ℕ) (a b : ℤ) (hb : b ≤ s) :
    kTypeOf sig k (segZ sig (deleteRun c s p) a b) = kTypeOf sig k (segZ sig c a b) := by
  classical
  rw [kTypeOf_segZ_eq_listSeg, kTypeOf_segZ_eq_listSeg, labels_deleteRun_below c s p a b hb]

/-- A segment at or above `s + p` has, after translation by `-p`, the `k`-type it had under `c`
in place: the translated segment of `deleteRun` reads the original letters. -/
theorem kTypeOf_segZ_deleteRun_above [Finite sig.preds] (k : ℕ) (c : sig.preds → ℤ → Prop)
    (s : ℤ) (p : ℕ) (a b : ℤ) (ha : s + p ≤ a) :
    kTypeOf sig k (segZ sig (deleteRun c s p) (a - p) (b - p)) =
      kTypeOf sig k (segZ sig c a b) := by
  classical
  rw [kTypeOf_segZ_eq_listSeg, kTypeOf_segZ_eq_listSeg,
    labels_deleteRun_above c s p (a - p) (b - p) (by omega), sub_add_cancel, sub_add_cancel]

/-- **The segment holding the run keeps its `k`-type.** If `[a, b)` contains a constant run
`[s, s + j)` of letter `ℓ` with `m₀ + p ≤ j`, where `(m₀, p)` is a threshold/period pair for `ℓ`
(`hper`), then deleting `p` positions of the run leaves the `k`-type unchanged: the label list
`u ++ ℓ^j ++ v` becomes `u ++ ℓ^(j - p) ++ v`, and `kTypeOf_listSeg_append_congr` applied twice
with `hper` at `m := j - p ≥ m₀` in the middle closes it. -/
theorem kTypeOf_segZ_deleteRun_of_const_run [Finite sig.preds] (k : ℕ)
    (c : sig.preds → ℤ → Prop) (s : ℤ) (ℓ : sig.preds → Bool) (j p m₀ : ℕ) (a b : ℤ)
    (ha : a ≤ s) (hb : s + j ≤ b)
    (hconst : ∀ u, s ≤ u → u < s + j → ∀ P, (c P u ↔ ℓ P = true)) (hpj : p ≤ j)
    (hper : ∀ m, m₀ ≤ m → kTypeOf sig k (listSeg (List.replicate (m + p) ℓ)) =
      kTypeOf sig k (listSeg (List.replicate m ℓ)))
    (hm : m₀ + p ≤ j) :
    kTypeOf sig k (segZ sig (deleteRun c s p) a (b - p)) = kTypeOf sig k (segZ sig c a b) := by
  classical
  haveI := Fintype.ofFinite sig.preds
  have hL : labels c a b = labels c a s ++ List.replicate j ℓ ++ labels c (s + j) b := by
    rw [labels_append c a s b ha (by omega), labels_append c s (s + j) b (by omega) hb,
      labels_const c s j ℓ hconst, List.append_assoc]
  have hc' : ∀ u, s ≤ u → u < s + ((j - p : ℕ) : ℤ) → ∀ P,
      (deleteRun c s p P u ↔ ℓ P = true) := by
    intro u hu hu' P
    rw [deleteRun_of_le hu]
    exact hconst _ (by omega) (by omega) P
  have hR : labels (deleteRun c s p) a (b - p) =
      labels c a s ++ List.replicate (j - p) ℓ ++ labels c (s + j) b := by
    rw [labels_append (deleteRun c s p) a s (b - p) ha (by omega),
      labels_append (deleteRun c s p) s (s + ((j - p : ℕ) : ℤ)) (b - p) (by omega) (by omega),
      labels_deleteRun_below c s p a s le_rfl, labels_const (deleteRun c s p) s (j - p) ℓ hc',
      labels_deleteRun_above c s p (s + ((j - p : ℕ) : ℤ)) (b - p) (by omega), List.append_assoc,
      show s + ((j - p : ℕ) : ℤ) + p = s + j by omega, sub_add_cancel]
  rw [kTypeOf_segZ_eq_listSeg, kTypeOf_segZ_eq_listSeg, hL, hR]
  have hmid : kTypeOf sig k (listSeg (List.replicate (j - p) ℓ)) =
      kTypeOf sig k (listSeg (List.replicate j ℓ)) := by
    have := hper (j - p) (by omega)
    rw [show j - p + p = j by omega] at this
    exact this.symm
  exact kTypeOf_listSeg_append_congr k (kTypeOf_listSeg_append_congr k rfl hmid) rfl

/-! ## The surgery -/

/-- **The cut surgery, shrink direction.** A factorization `F` of `c` whose segment
`[W z₀, W (z₀ + 1))` contains a constant run `[s, s + j)` of letter `ℓ`, with `p < j` and
`m₀ + p ≤ j` for a threshold/period pair `(m₀, p)` of `ℓ` (`hper`), yields a factorization of
`deleteRun c s p` with the SAME triple `(τneg, τzero, τpos)`: the cutting sequence is `W z` for
`z ≤ z₀` and `W z - p` beyond. Segments below `z₀` keep their letters
(`kTypeOf_segZ_deleteRun_below`), segments above are translated
(`kTypeOf_segZ_deleteRun_above`), and the segment at `z₀` loses `p` positions of its run
(`kTypeOf_segZ_deleteRun_of_const_run`). Monotonicity, coverage and the two nonemptiness fields
are integer arithmetic on `W`; `p < j` is what keeps the extremal segments nonempty when
`z₀ ∈ {1, -2}`.

The containment `hsub` is a HYPOTHESIS: a run met by several short segments is not re-cut here
(module docstring), and no `↔` is claimed.

Paper: — (the formalization's own cut surgery on a Ramsey factorization of the time axis; the
manuscript carries no counterpart) -/
theorem inFamily_of_shrink_run [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ)
    (c : sig.preds → ℤ → Prop) (F : SegmentFactorization sig k c) (z₀ s : ℤ)
    (ℓ : sig.preds → Bool) (j p m₀ : ℕ) (hpj : p < j) (hm : m₀ + p ≤ j)
    (hsub : F.W z₀ ≤ s ∧ s + j ≤ F.W (z₀ + 1))
    (hconst : ∀ u, s ≤ u → u < s + j → ∀ P, (c P u ↔ ℓ P = true))
    (hper : ∀ m, m₀ ≤ m → kTypeOf sig k (listSeg (List.replicate (m + p) ℓ)) =
      kTypeOf sig k (listSeg (List.replicate m ℓ))) :
    InFamily sig k F.τneg F.τzero F.τpos (deleteRun c s p) := by
  obtain ⟨hs₀, hs₁⟩ := hsub
  let W' : ℤ → ℤ := fun z => if z ≤ z₀ then F.W z else F.W z - p
  have hW'_le : ∀ z, z ≤ z₀ → W' z = F.W z := fun z hz => if_pos hz
  have hW'_gt : ∀ z, z₀ < z → W' z = F.W z - p := fun z hz => if_neg (not_le.mpr hz)
  -- every segment of `W'` has the `k`-type of the corresponding segment of `W`
  have hseg : ∀ z, kTypeOf sig k (segZ sig (deleteRun c s p) (W' z) (W' (z + 1))) =
      kTypeOf sig k (segZ sig c (F.W z) (F.W (z + 1))) := by
    intro z
    rcases lt_trichotomy z z₀ with hz | rfl | hz
    · rw [hW'_le z hz.le, hW'_le (z + 1) (by omega)]
      exact kTypeOf_segZ_deleteRun_below k c s p _ _
        (le_trans (F.mono (show z + 1 ≤ z₀ by omega)) hs₀)
    · rw [hW'_le z le_rfl, hW'_gt (z + 1) (by omega)]
      exact kTypeOf_segZ_deleteRun_of_const_run k c s ℓ j p m₀ _ _ hs₀ hs₁ hconst hpj.le hper hm
    · rw [hW'_gt z hz, hW'_gt (z + 1) (by omega)]
      exact kTypeOf_segZ_deleteRun_above k c s p _ _
        (by have := F.mono (show z₀ + 1 ≤ z by omega); omega)
  refine ⟨⟨W', ?_, ?_, F.τpos, F.τneg, fun z hz => (hseg z).trans (F.pos_type z hz),
    fun z hz => (hseg z).trans (F.neg_type z hz), ?_, ?_, F.τzero,
    (hseg 0).trans F.zero_type⟩, rfl, rfl, rfl⟩
  · -- `mono`: the one cross case `z ≤ z₀ < z'` needs `W (z₀ + 1) ≥ s + j ≥ W z₀ + p`
    intro z z' hzz'
    by_cases hz : z ≤ z₀ <;> by_cases hz' : z' ≤ z₀
    · rw [hW'_le z hz, hW'_le z' hz']; exact F.mono hzz'
    · rw [hW'_le z hz, hW'_gt z' (not_le.mp hz')]
      have h1 := F.mono hz
      have h2 := F.mono (show z₀ + 1 ≤ z' by omega)
      omega
    · omega
    · rw [hW'_gt z (not_le.mp hz), hW'_gt z' (not_le.mp hz')]
      have := F.mono hzz'
      omega
  · -- `cover`: below `s` use `F.cover t`, at or above `s` use `F.cover (t + p)`
    intro t
    by_cases ht : t < s
    · obtain ⟨z, h1, h2⟩ := F.cover t
      have hz : z ≤ z₀ := by
        by_contra hcon
        have := F.mono (show z₀ + 1 ≤ z by omega)
        omega
      refine ⟨z, ?_, ?_⟩
      · rw [hW'_le z hz]; exact h1
      · by_cases hz1 : z + 1 ≤ z₀
        · rw [hW'_le (z + 1) hz1]; exact h2
        · rw [hW'_gt (z + 1) (by omega)]
          have : z = z₀ := by omega
          subst this
          omega
    · obtain ⟨z, h1, h2⟩ := F.cover (t + p)
      have hz : z₀ ≤ z := by
        by_contra hcon
        have := F.mono (show z + 1 ≤ z₀ by omega)
        omega
      refine ⟨z, ?_, ?_⟩
      · rcases eq_or_lt_of_le hz with rfl | hz'
        · rw [hW'_le _ le_rfl]; omega
        · rw [hW'_gt z hz']; omega
      · rw [hW'_gt (z + 1) (by omega)]; omega
  · -- `strict_pos`
    rcases lt_trichotomy z₀ 1 with h | rfl | h
    · rw [hW'_gt 1 h, hW'_gt 2 (by omega)]; have := F.strict_pos; omega
    · rw [hW'_le 1 le_rfl, hW'_gt 2 (by omega)]
      have hs₁' : s + (j : ℤ) ≤ F.W 2 := by simpa using hs₁
      omega
    · rw [hW'_le 1 (by omega), hW'_le 2 (by omega)]; exact F.strict_pos
  · -- `strict_neg`
    rcases lt_trichotomy z₀ (-2) with h | rfl | h
    · rw [hW'_gt (-2) h, hW'_gt (-1) (by omega)]; have := F.strict_neg; omega
    · rw [hW'_le (-2) le_rfl, hW'_gt (-1) (by omega)]
      have hs₁' : s + (j : ℤ) ≤ F.W (-1) := by simpa using hs₁
      omega
    · rw [hW'_le (-2) (by omega), hW'_le (-1) (by omega)]; exact F.strict_neg

/-- **`InFamily` transports along the deletion** when EVERY factorization of `c` holds the run
inside one of its segments (`hcont`): unfold `InFamily`, take the factorization, apply the
surgery. -/
theorem inFamily_deleteRun_of_inFamily [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ)
    (c : sig.preds → ℤ → Prop) {τneg τzero τpos : KType sig k} (s : ℤ) (ℓ : sig.preds → Bool)
    (j p m₀ : ℕ) (hpj : p < j) (hm : m₀ + p ≤ j)
    (hcont : ∀ F : SegmentFactorization sig k c, ∃ z₀, F.W z₀ ≤ s ∧ s + j ≤ F.W (z₀ + 1))
    (hconst : ∀ u, s ≤ u → u < s + j → ∀ P, (c P u ↔ ℓ P = true))
    (hper : ∀ m, m₀ ≤ m → kTypeOf sig k (listSeg (List.replicate (m + p) ℓ)) =
      kTypeOf sig k (listSeg (List.replicate m ℓ)))
    (h : InFamily sig k τneg τzero τpos c) :
    InFamily sig k τneg τzero τpos (deleteRun c s p) := by
  obtain ⟨F, h1, h2, h3⟩ := h
  obtain ⟨z₀, hsub⟩ := hcont F
  subst h1 h2 h3
  exact inFamily_of_shrink_run k c F z₀ s ℓ j p m₀ hpj hm hsub hconst hper

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- **The family triples of `c` are among those of `deleteRun c s p`** under the same
containment hypothesis — the form the wired probe consumes. -/
theorem familyTriples_subset_deleteRun [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ)
    (c : sig.preds → ℤ → Prop) (s : ℤ) (ℓ : sig.preds → Bool)
    (j p m₀ : ℕ) (hpj : p < j) (hm : m₀ + p ≤ j)
    (hcont : ∀ F : SegmentFactorization sig k c, ∃ z₀, F.W z₀ ≤ s ∧ s + j ≤ F.W (z₀ + 1))
    (hconst : ∀ u, s ≤ u → u < s + j → ∀ P, (c P u ↔ ℓ P = true))
    (hper : ∀ m, m₀ ≤ m → kTypeOf sig k (listSeg (List.replicate (m + p) ℓ)) =
      kTypeOf sig k (listSeg (List.replicate m ℓ))) :
    familyTriples sig k c ⊆ familyTriples sig k (deleteRun c s p) :=
  fun _ hx => inFamily_deleteRun_of_inFamily k c s ℓ j p m₀ hpj hm hcont hconst hper hx

end FormalSystem.Metalogic.WeakCanonical
