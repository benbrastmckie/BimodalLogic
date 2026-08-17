/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Basic
import FormalSystem.Metalogic.Decidability.BiLasso.Periodic
import FormalSystem.Syntax.SubformulaClosure.Closure

/-!
# Annotated Bi-Lassos

A `BiLasso` presents a bi-infinite step path finitely. It does **not** present the *truth* of
formulas along that path: a machine-checked refutation
(`evidence/phase3-scan-bound-is-false.lean`, in this task's directory) shows that formula truth
along a bi-lasso is not a function of the state at a time and is not periodic in the time, even
though the state sequence is. The witness family is `prevⁿ p`, whose truth set along a fixed
`|back| = 1, |mid| = 0, |fwd| = 1` path is exactly `[n, ∞)`; since `n` is unbounded, no quantity
computed from the segment lengths alone bounds where truth must be looked for.

An **annotated** bi-lasso carries the missing information explicitly. Each position gets a
`Finset Formula` — its *type* — presented as three lists matching the three segment lengths and
decoded by the very same periodic scheme as the states. Label membership at a position **is** a
function of the annotation at that position, and the annotation is finite and periodic by
construction, so the scan bound the refutation kills for `TruthAt` is recovered verbatim for
label membership.

## Same decoding, not a parallel one

The label decoding is `Periodic.unrollOf` at `Finset Formula`; the state decoding is
`BiLasso.unrollOf` at `Fin P.card`. Both are the identical `emod` window scheme, and
`Annot.readIndex` together with `Annot.label_unroll_aligned` proves that at every time the two
consult the *same segment at the same offset*. That alignment is proved rather than assumed,
because a one-position slip between labels and states would make every clause relating a label
to its state silently wrong while remaining perfectly type-correct.

## Main Definitions

- `Annot` — the structure: a `BiLasso`, three label lists, three length agreements, and the
  closure-subset field
- `Annot.label` — the decoded label sequence `ℤ → Finset Formula`
- `Annot.readIndex` — the common segment offset that both decodings read at

## Main Results

- `Annot.label_unroll_aligned` — labels and states are read at the same index, at every time
- `Annot.label_sub_back_length` / `Annot.label_add_fwd_length` — the two label periodicities,
  at the same thresholds as `BiLasso.unroll_sub_back_length` / `BiLasso.unroll_add_fwd_length`
- `Annot.label_subset_closure` — every label is a subset of `subformulaClosure φ`
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

/--
An **annotated bi-lasso** over an `IntPresentation`, for a formula `φ`: a `BiLasso` together
with a per-position label drawn from `subformulaClosure φ`.

The labels are three plain `List (Finset Formula)` fields rather than a dependent packaging,
because the bounded enumeration downstream must build them by brute force and filter them with
`decide`; plain lists are `DecidableEq`, enumerable, and carry no proof obligations to transport
across the enumeration.

The three length agreements are what make the label decoding line up with the state decoding —
see `Annot.label_unroll_aligned`.
-/
structure Annot (P : IntPresentation) (φ : Formula) where
  /-- The underlying finitely-presented bi-infinite step path. -/
  lasso : BiLasso P
  /-- Labels for the leftward cycle, indexed left-to-right in time alongside `lasso.back`. -/
  backLab : List (Finset Formula)
  /-- Labels for the finite window `[0, |mid|)`. -/
  midLab : List (Finset Formula)
  /-- Labels for the rightward cycle, indexed left-to-right in time alongside `lasso.fwd`. -/
  fwdLab : List (Finset Formula)
  /-- The leftward labels match the leftward states position for position. -/
  backLab_length : backLab.length = lasso.back.length
  /-- The window labels match the window states position for position. -/
  midLab_length : midLab.length = lasso.mid.length
  /-- The rightward labels match the rightward states position for position. -/
  fwdLab_length : fwdLab.length = lasso.fwd.length
  /-- Every label is a set of subformulas of `φ`. Carried as a field rather than derived, because
  the bounded enumeration filters on it anyway and having it available without a side condition
  keeps the truth lemma's closure bookkeeping local. -/
  label_sub : ∀ L ∈ backLab ++ midLab ++ fwdLab, L ⊆ subformulaClosure φ

namespace Annot

variable {P : IntPresentation} {φ : Formula}

/-- The decoded label sequence, by exactly the scheme that decodes the states. -/
def label (A : Annot P φ) : ℤ → Finset Formula :=
  Periodic.unrollOf A.backLab A.midLab A.fwdLab

theorem label_def (A : Annot P φ) (t : ℤ) :
    A.label t = Periodic.unrollOf A.backLab A.midLab A.fwdLab t := rfl

/-- The empty label is the decoding's out-of-range default. Both `Periodic.cyc` and the window
lookup use `default`, and every index they use is in range, so this never appears in a decoded
annotation; it is recorded only so the alignment lemma can name it. -/
theorem default_finset : (default : Finset Formula) = ∅ := rfl

/-- The leftward labels are non-empty, inherited from `lasso.back_ne` through the length
agreement. -/
theorem backLab_ne (A : Annot P φ) : A.backLab ≠ [] := by
  intro h
  apply A.lasso.back_ne
  apply List.eq_nil_of_length_eq_zero
  rw [← A.backLab_length, h, List.length_nil]

/-- The rightward labels are non-empty, inherited from `lasso.fwd_ne`. -/
theorem fwdLab_ne (A : Annot P φ) : A.fwdLab ≠ [] := by
  intro h
  apply A.lasso.fwd_ne
  apply List.eq_nil_of_length_eq_zero
  rw [← A.fwdLab_length, h, List.length_nil]

/--
The common offset that time `t` is read at, stated in terms of the **lasso's** segment lengths.

Both the label decoding and the state decoding read their respective segment at this index. That
is the content of `label_unroll_aligned`; writing the index once, here, is what makes the two
provably the same term rather than two expressions that happen to look alike.
-/
def readIndex (A : Annot P φ) (t : ℤ) : ℕ :=
  if t < 0 then (t % (A.lasso.back.length : ℤ)).toNat
  else if t < (A.lasso.mid.length : ℤ) then t.toNat
  else ((t - (A.lasso.mid.length : ℤ)) % (A.lasso.fwd.length : ℤ)).toNat

/--
**Alignment: labels and states are read at the same index.**

At every time `t`, in whichever of the three regimes `t` falls, the label is the label list's
entry at `A.readIndex t` and the state is the state list's entry at the *same* `A.readIndex t`.

This is what rules out an off-by-one between the annotation and the path it annotates. It is
proved from the three length agreements — the label decoding's own thresholds and moduli are
stated with the *label* lengths, and every one of them must be transported to the corresponding
*state* length before the two indices are literally the same term.
-/
theorem label_unroll_aligned (A : Annot P φ) (t : ℤ) :
    (t < 0 →
        A.label t = A.backLab.getD (A.readIndex t) ∅ ∧
        A.lasso.unroll t = A.lasso.back.getD (A.readIndex t) default) ∧
    (0 ≤ t → t < (A.lasso.mid.length : ℤ) →
        A.label t = A.midLab.getD (A.readIndex t) ∅ ∧
        A.lasso.unroll t = A.lasso.mid.getD (A.readIndex t) default) ∧
    ((A.lasso.mid.length : ℤ) ≤ t →
        A.label t = A.fwdLab.getD (A.readIndex t) ∅ ∧
        A.lasso.unroll t = A.lasso.fwd.getD (A.readIndex t) default) := by
  refine ⟨fun ht => ⟨?_, ?_⟩, fun h0 ht => ⟨?_, ?_⟩, fun ht => ⟨?_, ?_⟩⟩
  · rw [label_def, Periodic.unrollOf_neg _ _ _ ht]
    simp only [Periodic.cyc, readIndex, if_pos ht, A.backLab_length]
    rfl
  · rw [BiLasso.unroll_neg _ ht]
    simp only [BiLasso.cyc, readIndex, if_pos ht]
  · have hnl : ¬ t < 0 := by omega
    have ht' : t < (A.midLab.length : ℤ) := by rw [A.midLab_length]; exact ht
    rw [label_def, Periodic.unrollOf_mid _ _ _ h0 ht']
    simp only [readIndex, if_neg hnl, if_pos ht]
    rfl
  · have hnl : ¬ t < 0 := by omega
    rw [BiLasso.unroll_def, BiLasso.unrollOf]
    simp only [readIndex, if_neg hnl, if_pos ht]
  · have hnl : ¬ t < 0 := by
      have : (0 : ℤ) ≤ (A.lasso.mid.length : ℤ) := Int.natCast_nonneg _
      omega
    have ht' : (A.midLab.length : ℤ) ≤ t := by rw [A.midLab_length]; exact ht
    rw [label_def, Periodic.unrollOf_fwd _ _ _ ht']
    simp only [Periodic.cyc, readIndex, if_neg hnl, if_neg (not_lt.mpr ht),
      A.midLab_length, A.fwdLab_length]
    rfl
  · have hnl : ¬ t < 0 := by
      have : (0 : ℤ) ≤ (A.lasso.mid.length : ℤ) := Int.natCast_nonneg _
      omega
    rw [BiLasso.unroll_fwd _ ht]
    simp only [BiLasso.cyc, readIndex, if_neg hnl, if_neg (not_lt.mpr ht)]

/--
**Leftward label periodicity.** Strictly left of the origin the labels have period `|back|` —
the same threshold and the same period as `BiLasso.unroll_sub_back_length` has for the states.
-/
theorem label_sub_back_length (A : Annot P φ) {t : ℤ} (ht : t < 0) :
    A.label (t - (A.lasso.back.length : ℤ)) = A.label t := by
  rw [← A.backLab_length]
  exact Periodic.unrollOf_sub_back_length _ _ _ A.backLab_ne ht

/--
**Rightward label periodicity.** At or past `|mid|` the labels have period `|fwd|` — the same
threshold and the same period as `BiLasso.unroll_add_fwd_length` has for the states.
-/
theorem label_add_fwd_length (A : Annot P φ) {t : ℤ} (ht : (A.lasso.mid.length : ℤ) ≤ t) :
    A.label (t + (A.lasso.fwd.length : ℤ)) = A.label t := by
  rw [← A.fwdLab_length]
  refine Periodic.unrollOf_add_fwd_length _ _ _ A.fwdLab_ne ?_
  rw [A.midLab_length]
  exact ht

/--
**Every label is a set of subformulas of `φ`.**

The structure field states this for the labels as they are *listed*; this restates it for the
labels as they are *decoded*, which is the form every consumer uses. The decoding only ever
returns a listed label or the default `∅`, and `∅` is a subset of anything.
-/
theorem label_subset_closure (A : Annot P φ) (t : ℤ) : A.label t ⊆ subformulaClosure φ := by
  have hmem : ∀ (l : List (Finset Formula)) (i : ℕ),
      (∀ L ∈ l, L ⊆ subformulaClosure φ) → l.getD i ∅ ⊆ subformulaClosure φ := by
    intro l i hl
    rcases lt_or_ge i l.length with hi | hi
    · rw [(List.getElem_eq_getD (l := l) (i := i) (h := hi) ∅).symm]
      exact hl _ (List.getElem_mem hi)
    · rw [List.getD_eq_getElem?_getD, List.getElem?_eq_none hi]
      simp
  have hsub := A.label_sub
  have hback : ∀ L ∈ A.backLab, L ⊆ subformulaClosure φ := by
    intro L hL; exact hsub L (by simp [hL])
  have hmid : ∀ L ∈ A.midLab, L ⊆ subformulaClosure φ := by
    intro L hL; exact hsub L (by simp [hL])
  have hfwd : ∀ L ∈ A.fwdLab, L ⊆ subformulaClosure φ := by
    intro L hL; exact hsub L (by simp [hL])
  obtain ⟨hneg, hmidr, hfwdr⟩ := A.label_unroll_aligned t
  rcases lt_or_ge t 0 with ht | ht
  · rw [(hneg ht).1]; exact hmem _ _ hback
  rcases lt_or_ge t (A.lasso.mid.length : ℤ) with ht2 | ht2
  · rw [(hmidr ht ht2).1]; exact hmem _ _ hmid
  · rw [(hfwdr ht2).1]; exact hmem _ _ hfwd

end Annot

end FormalSystem.Metalogic.Decidability
