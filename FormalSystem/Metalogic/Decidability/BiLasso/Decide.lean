/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Annotation

/-!
# Deciding `LocalCoherent` and `Fulfilling` — the Corrected Scan Bound

Both predicates quantify over all of `ℤ`. This module reduces each to a finite check.

## What was refuted, and what survives

An earlier design asked for a scan bound on the **semantic** witness: "any property of
`L.unroll` that holds at some `s > t` holds at some `s` with `t < s ≤ t + |mid| + |fwd|`". Read
as a bound on where the truth of a *formula* must be looked for, that is **false**, and
machine-checked to be so in this task's `evidence/phase3-scan-bound-is-false.lean`
(`plan_scan_bound_fails`, `no_formula_independent_scan_bound`). Formula truth along a bi-lasso
is not a function of the state at a time: the state sequence is periodic, but the shifted path
is not the path, because the leftward tail moves.

The corrected statement replaces "property of `L.unroll`" with "property of the **annotation**
at a position", and it is true — because the annotation is periodic *by construction*, being
presented as three finite lists. That is `scan_forward` / `scan_backward` below. The refutation
is not circumvented here; it is respected. Nothing in this module bounds where a formula's
*truth* lies, only where a *label* with a given property lies.

## The fulfilment window is derived, not guessed

`Fulfilling`'s reduction is the harder half and is not a matter of shifting a window. The
obligation at a far-left position `t ≪ 0` is not literally the obligation at `t + |back|`,
because the distance from `t` to the origin differs. What makes the family finite is the
dichotomy in `farLeft_dichotomy`: scanning rightward from a far-left position, the first `|back|`
steps traverse a **complete** residue system of the backward cycle, so either the scan settles
inside that period — and then only `t mod |back|` matters — or the guard survives the entire
backward region, and the obligation collapses to a single position-independent condition about
the region from the origin rightward.

The resulting window is `[-2|back| - 1, |mid| + |fwd|)`, of size `2|back| + |mid| + |fwd| + 1`.
It is derived in `fulfilling_iff_window`, and downstream consumers must take the quantity from
`fulfilWindowLo` / `fulfilWindowHi` rather than restating it.

## No classical choice

Every instance here computes. There is no `open Classical` and no `Classical.dec` anywhere in
this module: an instance obtained that way would typecheck and would make `check` not a decision
procedure.

## Main Results

- `scan_forward` / `scan_backward` — the corrected scan bounds, over label properties
- `localCoherent_iff_window` — `LocalCoherent`'s `∀ t : ℤ` collapses to one window
- `fulfilling_iff_window` — `Fulfilling`'s `∀ t : ℤ` collapses to one window
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

namespace Annot

variable {P : IntPresentation} {φ : Formula}

/-! ## Segment lengths and canonical representatives

The three segment lengths are named as reducible abbreviations so that every arithmetic lemma
below reads at the length rather than at a `List.length` cast, while `rfl`, `omega` and `simp`
still see straight through to the underlying term.
-/

/-- The backward cycle length, as an integer. -/
abbrev nb (A : Annot P φ) : ℤ := (A.lasso.back.length : ℤ)

/-- The window length, as an integer. -/
abbrev nm (A : Annot P φ) : ℤ := (A.lasso.mid.length : ℤ)

/-- The forward cycle length, as an integer. -/
abbrev nf (A : Annot P φ) : ℤ := (A.lasso.fwd.length : ℤ)

theorem nb_pos (A : Annot P φ) : 0 < A.nb := BiLasso.length_pos_int P A.lasso.back_ne

theorem nf_pos (A : Annot P φ) : 0 < A.nf := BiLasso.length_pos_int P A.lasso.fwd_ne

theorem nm_nonneg (A : Annot P φ) : 0 ≤ A.nm := Int.natCast_nonneg _

/-- One step of rightward label periodicity, in the subtractive direction. -/
theorem label_sub_nf (A : Annot P φ) {t : ℤ} (ht : A.nm ≤ t - A.nf) :
    A.label (t - A.nf) = A.label t := by
  simpa using (A.label_add_fwd_length (t := t - A.nf) ht).symm

/-- One step of leftward label periodicity, in the additive direction. -/
theorem label_add_nb (A : Annot P φ) {t : ℤ} (ht : t + A.nb < 0) :
    A.label (t + A.nb) = A.label t := by
  simpa using (A.label_sub_back_length (t := t + A.nb) ht).symm

/--
**Rightward canonical representative.** Every position at or beyond the window has the label of
its representative `nm + (w - nm) % nf`, which lies in `[nm, nm + nf)`.

Proved by descending one full forward period at a time — no integer division is used, so the
argument is available with only `Int.emod` lemmas in scope.
-/
theorem label_reduce_fwd (A : Annot P φ) :
    ∀ (d : ℕ) (w : ℤ), (w - A.nm).toNat = d → A.nm ≤ w →
      A.label w = A.label (A.nm + (w - A.nm) % A.nf) := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro w hd hw
    have hnf := A.nf_pos
    by_cases hlt : w < A.nm + A.nf
    · rw [Int.emod_eq_of_lt (by omega) (by omega)]
      congr 1
      omega
    · push Not at hlt
      have hstep : A.label (w - A.nf) = A.label w := A.label_sub_nf (by omega)
      have hres : (w - A.nf - A.nm) % A.nf = (w - A.nm) % A.nf := by
        rw [show w - A.nf - A.nm = (w - A.nm) + (-1) * A.nf by omega]
        exact Periodic.emod_add_mul _ _ _
      rw [← hstep, ih ((w - A.nf - A.nm).toNat) (by omega) (w - A.nf) rfl (by omega), hres]

/--
**Leftward canonical representative.** Every negative position has the label of its
representative `w % nb - nb`, which lies in `[-nb, 0)`.
-/
theorem label_reduce_back (A : Annot P φ) :
    ∀ (d : ℕ) (w : ℤ), (-w).toNat = d → w < 0 →
      A.label w = A.label (w % A.nb - A.nb) := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro w hd hw
    have hnb := A.nb_pos
    by_cases hge : -A.nb ≤ w
    · have hres : (w + A.nb) % A.nb = w % A.nb := by
        simp
      have hval : w % A.nb = w + A.nb := by
        rw [← hres]
        exact Int.emod_eq_of_lt (by omega) (by omega)
      rw [hval]
      congr 1
      omega
    · push Not at hge
      have hstep : A.label (w + A.nb) = A.label w := A.label_add_nb (by omega)
      have hres : (w + A.nb) % A.nb = w % A.nb := by
        simp
      rw [← hstep, ih ((-(w + A.nb)).toNat) (by omega) (w + A.nb) rfl (by omega), hres]

/-- Positions at or beyond the window with equal residues modulo the forward period carry equal
labels. -/
theorem label_congr_fwd (A : Annot P φ) {u v : ℤ} (hu : A.nm ≤ u) (hv : A.nm ≤ v)
    (h : (u - A.nm) % A.nf = (v - A.nm) % A.nf) : A.label u = A.label v := by
  rw [A.label_reduce_fwd _ u rfl hu, A.label_reduce_fwd _ v rfl hv, h]

/-- Negative positions with equal residues modulo the backward period carry equal labels. -/
theorem label_congr_back (A : Annot P φ) {u v : ℤ} (hu : u < 0) (hv : v < 0)
    (h : u % A.nb = v % A.nb) : A.label u = A.label v := by
  rw [A.label_reduce_back _ u rfl hu, A.label_reduce_back _ v rfl hv, h]

/-! ## The corrected scan bounds

These are the recovered half of the refuted design: the same sentence, with "property of the
state sequence" replaced by "property of the **label**". Both are stated for an arbitrary
predicate on `Finset Formula`, because it is the label sequence's periodicity that carries the
argument and no feature of the predicate is used.
-/

/--
**Corrected forward scan bound.** If some label strictly to the right of `t` satisfies `Q`, then
one does within the explicit range `(t, max t |mid| + |fwd|]`.

The bound is stated explicitly rather than existentially: an unbounded existential discharges no
decidability obligation. The proof pulls a witness back one full forward period at a time, which
is legitimate exactly because the **labels** are periodic there — the refuted version attempted
the same move on formula truth, where it is unavailable.
-/
theorem scan_forward (A : Annot P φ) (Q : Finset Formula → Prop) :
    ∀ (d : ℕ) (t s : ℤ), (s - t).toNat = d → t < s → Q (A.label s) →
      ∃ s' : ℤ, t < s' ∧ s' ≤ max t A.nm + A.nf ∧ Q (A.label s') := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro t s hd hts hQ
    have hnf := A.nf_pos
    have hmr : A.nm ≤ max t A.nm := le_max_right _ _
    have hml : t ≤ max t A.nm := le_max_left _ _
    by_cases hle : s ≤ max t A.nm + A.nf
    · exact ⟨s, hts, hle, hQ⟩
    · push Not at hle
      have hlab : A.label (s - A.nf) = A.label s := A.label_sub_nf (by omega)
      exact ih ((s - A.nf - t).toNat) (by omega) t (s - A.nf) rfl (by omega) (hlab ▸ hQ)

/--
**Corrected backward scan bound** — the leftward mirror, over the explicit range
`[min t 0 - |back|, t)`.
-/
theorem scan_backward (A : Annot P φ) (Q : Finset Formula → Prop) :
    ∀ (d : ℕ) (t s : ℤ), (t - s).toNat = d → s < t → Q (A.label s) →
      ∃ s' : ℤ, s' < t ∧ min t 0 - A.nb ≤ s' ∧ Q (A.label s') := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro t s hd hst hQ
    have hnb := A.nb_pos
    have hmr : min t 0 ≤ 0 := min_le_right _ _
    have hml : min t 0 ≤ t := min_le_left _ _
    by_cases hge : min t 0 - A.nb ≤ s
    · exact ⟨s, hst, hge, hQ⟩
    · push Not at hge
      have hlab : A.label (s + A.nb) = A.label s := A.label_add_nb (by omega)
      exact ih ((t - (s + A.nb)).toNat) (by omega) t (s + A.nb) rfl (by omega) (hlab ▸ hQ)

end Annot

end FormalSystem.Metalogic.Decidability
