/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Annotation
import Mathlib.Data.Int.Interval

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

/-! ## Complete residue systems

Both far-position reductions need the same fact in mirrored forms: a run of `|back|` consecutive
negative positions (resp. `|fwd|` consecutive positions at or beyond the window) meets every
residue class, so a property holding throughout one such run holds throughout the whole periodic
region. This is what "the guard survives a full period" means, made precise.
-/

/-- A formula present throughout one full backward period is present at **every** negative
position. -/
theorem mem_all_neg_of_period (A : Annot P φ) {g : Formula} {a : ℤ} (ha : a + A.nb < 0)
    (h : ∀ r : ℤ, a < r → r ≤ a + A.nb → g ∈ A.label r) :
    ∀ r : ℤ, r < 0 → g ∈ A.label r := by
  intro r hr
  have hnb := A.nb_pos
  set r' : ℤ := (a + 1) + (r - (a + 1)) % A.nb with hr'
  have hlo : a + 1 ≤ r' := by
    have : 0 ≤ (r - (a + 1)) % A.nb := Int.emod_nonneg _ (by omega)
    omega
  have hhi : r' < (a + 1) + A.nb := by
    have : (r - (a + 1)) % A.nb < A.nb := Int.emod_lt_of_pos _ hnb
    omega
  have hres : r' % A.nb = r % A.nb := BiLasso.reduce_emod A.nb (a + 1) r
  have hlab : A.label r = A.label r' :=
    A.label_congr_back hr (by omega) hres.symm
  rw [hlab]
  exact h r' (by omega) (by omega)

/-- A formula present throughout one full forward period is present at **every** position at or
beyond the window. -/
theorem mem_all_fwd_of_period (A : Annot P φ) {g : Formula} {b : ℤ} (hb : A.nm ≤ b)
    (h : ∀ r : ℤ, b ≤ r → r < b + A.nf → g ∈ A.label r) :
    ∀ r : ℤ, A.nm ≤ r → g ∈ A.label r := by
  intro r hr
  have hnf := A.nf_pos
  set r' : ℤ := b + (r - b) % A.nf with hr'
  have hlo : b ≤ r' := by
    have : 0 ≤ (r - b) % A.nf := Int.emod_nonneg _ (by omega)
    omega
  have hhi : r' < b + A.nf := by
    have : (r - b) % A.nf < A.nf := Int.emod_lt_of_pos _ hnf
    omega
  have hres : r' % A.nf = r % A.nf := BiLasso.reduce_emod A.nf b r
  have hres' : (r' - A.nm) % A.nf = (r - A.nm) % A.nf := by
    rw [Int.sub_emod, Int.sub_emod r, hres]
  have hlab : A.label r = A.label r' :=
    A.label_congr_fwd hr (by omega) hres'.symm
  rw [hlab]
  exact h r' (by omega) (by omega)

/-- Residues are preserved by a common shift. -/
theorem emod_shift {x y k n : ℤ} (h : x % n = y % n) : (x + k) % n = (y + k) % n := by
  rw [Int.add_emod, h, ← Int.add_emod]

/-- Negative positions with equal residues modulo the backward period carry equal states. -/
theorem unroll_congr_back (A : Annot P φ) {u v : ℤ} (hu : u < 0) (hv : v < 0)
    (h : u % A.nb = v % A.nb) : A.lasso.unroll u = A.lasso.unroll v := by
  rw [BiLasso.unroll_neg _ hu, BiLasso.unroll_neg _ hv]
  exact BiLasso.cyc_congr P h

/-- Positions at or beyond the window with equal residues modulo the forward period carry equal
states. -/
theorem unroll_congr_fwd (A : Annot P φ) {u v : ℤ} (hu : A.nm ≤ u) (hv : A.nm ≤ v)
    (h : (u - A.nm) % A.nf = (v - A.nm) % A.nf) : A.lasso.unroll u = A.lasso.unroll v := by
  rw [BiLasso.unroll_fwd _ hu, BiLasso.unroll_fwd _ hv]
  exact BiLasso.cyc_congr P h

end Annot

/-! ## `LocalCoherent`, position by position

`LocalCoherent` as defined quantifies over `Atom` and over `Formula` — both **infinite** types —
guarded by closure membership. That is the right statement to prove theorems with and the wrong
one to compute with. `clauseAt` re-presents a single clause as a function of the data it actually
reads: the three labels at `t - 1`, `t`, `t + 1`, and the state at `t`. Quantifying it over the
closure as a `Finset` makes the per-position check decidable, and taking the label data as
explicit arguments makes the position-shift congruence a rewrite rather than an argument.
-/

/--
The local clause a single closure member imposes, at explicit label and state data.

`Lm`, `Lt`, `Lp` are the labels at `t - 1`, `t` and `t + 1`; `w` is the state at `t`.
-/
def clauseAt (P : IntPresentation) (bx : Formula → Bool)
    (Lm Lt Lp : Finset Formula) (w : Fin P.card) : Formula → Prop
  | Formula.atom p => (Formula.atom p ∈ Lt ↔ P.val p w = true)
  | Formula.bot => True
  | Formula.imp a b => (Formula.imp a b ∈ Lt ↔ (a ∈ Lt → b ∈ Lt))
  | Formula.box χ => (Formula.box χ ∈ Lt ↔ bx χ = true)
  | Formula.untl g e => (Formula.untl g e ∈ Lt ↔ (e ∈ Lp ∨ (g ∈ Lp ∧ Formula.untl g e ∈ Lp)))
  | Formula.snce g e => (Formula.snce g e ∈ Lt ↔ (e ∈ Lm ∨ (g ∈ Lm ∧ Formula.snce g e ∈ Lm)))

instance instDecidableClauseAt (P : IntPresentation) (bx : Formula → Bool)
    (Lm Lt Lp : Finset Formula) (w : Fin P.card) :
    DecidablePred (clauseAt P bx Lm Lt Lp w) := by
  intro ψ
  cases ψ <;> (dsimp only [clauseAt]; infer_instance)

variable {P : IntPresentation} {φ : Formula} {bx : Formula → Bool}

/-- `LocalCoherent`'s content at a single position, quantified over the closure as a `Finset`. -/
def LocalCoherentAt (P : IntPresentation) (φ : Formula) (bx : Formula → Bool)
    (A : Annot P φ) (t : ℤ) : Prop :=
  Formula.bot ∉ A.label t ∧
    ∀ ψ ∈ subformulaClosure φ,
      clauseAt P bx (A.label (t - 1)) (A.label t) (A.label (t + 1)) (A.lasso.unroll t) ψ

instance instDecidableLocalCoherentAt (A : Annot P φ) :
    DecidablePred (LocalCoherentAt P φ bx A) := by
  intro t
  dsimp only [LocalCoherentAt]
  infer_instance

/-- `LocalCoherent` is exactly `LocalCoherentAt` at every position. -/
theorem localCoherent_iff_forall (A : Annot P φ) :
    LocalCoherent P φ bx A ↔ ∀ t : ℤ, LocalCoherentAt P φ bx A t := by
  constructor
  · intro h t
    refine ⟨(h t).2.1, fun ψ hψ => ?_⟩
    cases ψ with
    | atom p => exact (h t).1 p hψ
    | bot => trivial
    | imp a b => exact (h t).2.2.1 a b hψ
    | box χ => exact (h t).2.2.2.1 χ hψ
    | untl g e => exact (h t).2.2.2.2.1 g e hψ
    | snce g e => exact (h t).2.2.2.2.2 g e hψ
  · intro h t
    exact ⟨fun p hp => (h t).2 (Formula.atom p) hp,
      (h t).1,
      fun a b hab => (h t).2 (Formula.imp a b) hab,
      fun χ hχ => (h t).2 (Formula.box χ) hχ,
      fun g e hge => (h t).2 (Formula.untl g e) hge,
      fun g e hge => (h t).2 (Formula.snce g e) hge⟩

/-- The per-position check depends only on the three labels and the state, so equal data at two
positions makes the checks equivalent. This is a rewrite precisely because `clauseAt` takes that
data as arguments. -/
theorem localCoherentAt_congr (A : Annot P φ) {t t' : ℤ}
    (h0 : A.label t = A.label t') (hp : A.label (t + 1) = A.label (t' + 1))
    (hm : A.label (t - 1) = A.label (t' - 1))
    (hu : A.lasso.unroll t = A.lasso.unroll t') :
    LocalCoherentAt P φ bx A t ↔ LocalCoherentAt P φ bx A t' := by
  unfold LocalCoherentAt
  rw [h0, hp, hm, hu]

/-! ## The `LocalCoherent` window

Every position outside `[-2|back|, |mid| + 2|fwd|)` has a representative inside it at which the
three labels **and** the state all agree. The window is two backward periods wide on the left
and two forward periods wide on the right rather than one, because the check at `t` reads
`t - 1` and `t + 1` as well as `t`: a representative must have its whole neighbourhood in the
periodic region, not just itself.
-/

/-- Lower end of the local-coherence window. -/
def cohWindowLo (A : Annot P φ) : ℤ := -2 * A.nb

/-- Upper end (exclusive) of the local-coherence window. -/
def cohWindowHi (A : Annot P φ) : ℤ := A.nm + 2 * A.nf

/--
**`LocalCoherent` collapses to one finite window.**

The reduction is by cases on the region containing `t`: far left (`t ≤ -2`), the middle
(`-1 ≤ t ≤ |mid|`, already inside the window), and far right (`t ≥ |mid| + 1`).
-/
theorem localCoherent_iff_window (A : Annot P φ) :
    LocalCoherent P φ bx A ↔
      ∀ t : ℤ, cohWindowLo A ≤ t → t < cohWindowHi A → LocalCoherentAt P φ bx A t := by
  rw [localCoherent_iff_forall]
  constructor
  · intro h t _ _; exact h t
  · intro h t
    have hnb := A.nb_pos
    have hnf := A.nf_pos
    have hnm := A.nm_nonneg
    rcases lt_or_ge t (-1) with hfar | hmid
    · -- far left: represent `t` in `[-2|back|, -|back| - 1]`
      set t' : ℤ := t % A.nb - 2 * A.nb with ht'
      have h0 : 0 ≤ t % A.nb := Int.emod_nonneg _ (by omega)
      have h1 : t % A.nb < A.nb := Int.emod_lt_of_pos _ hnb
      have hres : t' % A.nb = t % A.nb := by
        have : t' = t % A.nb + (-2) * A.nb := by omega
        rw [this, Periodic.emod_add_mul, Int.emod_emod_of_dvd _ (dvd_refl _)]
      refine (localCoherentAt_congr A (bx := bx) ?_ ?_ ?_ ?_).mpr
        (h t' (by simp only [cohWindowLo]; omega) (by simp only [cohWindowHi]; omega))
      · exact A.label_congr_back (by omega) (by omega) hres.symm
      · exact A.label_congr_back (by omega) (by omega) (Annot.emod_shift hres.symm)
      · exact A.label_congr_back (by omega) (by omega) (Annot.emod_shift hres.symm)
      · exact A.unroll_congr_back (by omega) (by omega) hres.symm
    rcases le_or_gt t A.nm with hin | hfar
    · -- middle: already inside the window
      exact h t (by simp only [cohWindowLo]; omega) (by simp only [cohWindowHi]; omega)
    · -- far right: represent `t` in `[|mid| + |fwd|, |mid| + 2|fwd|)`
      set t' : ℤ := A.nm + (t - A.nm) % A.nf + A.nf with ht'
      have h0 : 0 ≤ (t - A.nm) % A.nf := Int.emod_nonneg _ (by omega)
      have h1 : (t - A.nm) % A.nf < A.nf := Int.emod_lt_of_pos _ hnf
      have hres : (t' - A.nm) % A.nf = (t - A.nm) % A.nf := by
        have : t' - A.nm = (t - A.nm) % A.nf + 1 * A.nf := by omega
        rw [this, Periodic.emod_add_mul, Int.emod_emod_of_dvd _ (dvd_refl _)]
      refine (localCoherentAt_congr A (bx := bx) ?_ ?_ ?_ ?_).mpr
        (h t' (by simp only [cohWindowLo]; omega) (by simp only [cohWindowHi]; omega))
      · exact A.label_congr_fwd (by omega) (by omega) hres.symm
      · refine A.label_congr_fwd (by omega) (by omega) ?_
        have e1 : t + 1 - A.nm = (t - A.nm) + 1 := by omega
        have e2 : t' + 1 - A.nm = (t' - A.nm) + 1 := by omega
        rw [e1, e2]
        exact Annot.emod_shift hres.symm
      · refine A.label_congr_fwd (by omega) (by omega) ?_
        have e1 : t - 1 - A.nm = (t - A.nm) + (-1) := by omega
        have e2 : t' - 1 - A.nm = (t' - A.nm) + (-1) := by omega
        rw [e1, e2]
        exact Annot.emod_shift hres.symm
      · exact A.unroll_congr_fwd (by omega) (by omega) hres.symm

/-- `LocalCoherent` is decidable: the window is finite, and the per-position check is decidable. -/
instance instDecidableLocalCoherent (A : Annot P φ) :
    Decidable (LocalCoherent P φ bx A) :=
  decidable_of_iff
    (∀ t ∈ Finset.Ico (cohWindowLo A) (cohWindowHi A), LocalCoherentAt P φ bx A t)
    (by
      rw [localCoherent_iff_window]
      constructor
      · intro h t hlo hhi; exact h t (Finset.mem_Ico.mpr ⟨hlo, hhi⟩)
      · intro h t ht
        obtain ⟨hlo, hhi⟩ := Finset.mem_Ico.mp ht
        exact h t hlo hhi)

/-! ## `Fulfilling`, position by position

This is the harder reduction, and it is not a matter of shifting a window. The forward obligation
at a far-left position `t` searches rightward across an interval whose length grows without bound
as `t` decreases, so no fixed scan range works uniformly and no naive periodicity argument
applies. The same problem appears mirrored for the backward obligation at far-right positions.

Two things make the family finite, and they are different from each other:

1. **A bounded witness.** If the obligation is met at all, it is met by a witness within one
   forward period of the window (`untlObl_iff_bounded`). This is the corrected scan bound doing
   its work, and it makes the check *at a fixed position* finite.
2. **A position shift.** The obligation at `t` and at `t + |back|` coincide once `t` is at least
   two backward periods left of the origin (`untlObl_shift_back`). The extra period is exactly
   what the argument needs: in the one subcase where the witness lies at or beyond the origin,
   the guard is known to hold throughout an interval containing a **complete residue system** of
   the backward cycle, hence — by `mem_all_neg_of_period` — throughout the entire negative
   region. That is the precise content of "the guard survives a full period", and it is why one
   period is not enough and two are.
-/

namespace Annot

variable {P : IntPresentation} {φ : Formula}

/-- The forward eventuality obligation: a witness for the event, with the guard throughout. -/
def UntlObl (A : Annot P φ) (t : ℤ) (g e : Formula) : Prop :=
  ∃ s : ℤ, t < s ∧ e ∈ A.label s ∧ ∀ r : ℤ, t < r → r < s → g ∈ A.label r

/-- The backward eventuality obligation. -/
def SnceObl (A : Annot P φ) (t : ℤ) (g e : Formula) : Prop :=
  ∃ s : ℤ, s < t ∧ e ∈ A.label s ∧ ∀ r : ℤ, s < r → r < t → g ∈ A.label r

/-- The forward obligation with the witness confined to an explicit finite range. -/
def UntlOblB (A : Annot P φ) (t : ℤ) (g e : Formula) : Prop :=
  ∃ s ∈ Finset.Ioc t (max t A.nm + A.nf),
    e ∈ A.label s ∧ ∀ r ∈ Finset.Ioo t s, g ∈ A.label r

/-- The backward obligation with the witness confined to an explicit finite range. -/
def SnceOblB (A : Annot P φ) (t : ℤ) (g e : Formula) : Prop :=
  ∃ s ∈ Finset.Ico (min t 0 - A.nb) t,
    e ∈ A.label s ∧ ∀ r ∈ Finset.Ioo s t, g ∈ A.label r

instance instDecidableUntlOblB (A : Annot P φ) (t : ℤ) (g e : Formula) :
    Decidable (UntlOblB A t g e) := by
  dsimp only [UntlOblB]; infer_instance

instance instDecidableSnceOblB (A : Annot P φ) (t : ℤ) (g e : Formula) :
    Decidable (SnceOblB A t g e) := by
  dsimp only [SnceOblB]; infer_instance

/-- Descent for the forward obligation: a witness beyond one forward period past the window can
be pulled back one period, because the labels there repeat and the guard interval only shrinks. -/
theorem untlObl_descend (A : Annot P φ) (g e : Formula) :
    ∀ (d : ℕ) (t s : ℤ), (s - t).toNat = d → t < s → e ∈ A.label s →
      (∀ r : ℤ, t < r → r < s → g ∈ A.label r) → UntlOblB A t g e := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro t s hd hts hes hgs
    have hnf := A.nf_pos
    have hmr : A.nm ≤ max t A.nm := le_max_right _ _
    have hml : t ≤ max t A.nm := le_max_left _ _
    by_cases hle : s ≤ max t A.nm + A.nf
    · exact ⟨s, Finset.mem_Ioc.mpr ⟨hts, hle⟩, hes,
        fun r hr => hgs r (Finset.mem_Ioo.mp hr).1 (Finset.mem_Ioo.mp hr).2⟩
    · push Not at hle
      have hlab : A.label (s - A.nf) = A.label s := A.label_sub_nf (by omega)
      refine ih ((s - A.nf - t).toNat) (by omega) t (s - A.nf) rfl (by omega) (hlab ▸ hes) ?_
      exact fun r hr1 hr2 => hgs r hr1 (by omega)

/-- Descent for the backward obligation — the leftward mirror. -/
theorem snceObl_descend (A : Annot P φ) (g e : Formula) :
    ∀ (d : ℕ) (t s : ℤ), (t - s).toNat = d → s < t → e ∈ A.label s →
      (∀ r : ℤ, s < r → r < t → g ∈ A.label r) → SnceOblB A t g e := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro t s hd hst hes hgs
    have hnb := A.nb_pos
    have hmr : min t 0 ≤ 0 := min_le_right _ _
    have hml : min t 0 ≤ t := min_le_left _ _
    by_cases hge : min t 0 - A.nb ≤ s
    · exact ⟨s, Finset.mem_Ico.mpr ⟨hge, hst⟩, hes,
        fun r hr => hgs r (Finset.mem_Ioo.mp hr).1 (Finset.mem_Ioo.mp hr).2⟩
    · push Not at hge
      have hlab : A.label (s + A.nb) = A.label s := A.label_add_nb (by omega)
      refine ih ((t - (s + A.nb)).toNat) (by omega) t (s + A.nb) rfl (by omega) (hlab ▸ hes) ?_
      exact fun r hr1 hr2 => hgs r (by omega) hr2

/-- **The forward obligation has a bounded witness.** -/
theorem untlObl_iff_bounded (A : Annot P φ) (t : ℤ) (g e : Formula) :
    UntlObl A t g e ↔ UntlOblB A t g e := by
  constructor
  · rintro ⟨s, hts, hes, hgs⟩
    exact A.untlObl_descend g e (s - t).toNat t s rfl hts hes hgs
  · rintro ⟨s, hs, hes, hgs⟩
    obtain ⟨hlo, _⟩ := Finset.mem_Ioc.mp hs
    exact ⟨s, hlo, hes, fun r hr1 hr2 => hgs r (Finset.mem_Ioo.mpr ⟨hr1, hr2⟩)⟩

/-- **The backward obligation has a bounded witness.** -/
theorem snceObl_iff_bounded (A : Annot P φ) (t : ℤ) (g e : Formula) :
    SnceObl A t g e ↔ SnceOblB A t g e := by
  constructor
  · rintro ⟨s, hst, hes, hgs⟩
    exact A.snceObl_descend g e (t - s).toNat t s rfl hst hes hgs
  · rintro ⟨s, hs, hes, hgs⟩
    obtain ⟨_, hhi⟩ := Finset.mem_Ico.mp hs
    exact ⟨s, hhi, hes, fun r hr1 hr2 => hgs r (Finset.mem_Ioo.mpr ⟨hr1, hr2⟩)⟩

/-! ### The four position shifts

Two are pure shifts: the forward obligation seen from far right, and the backward obligation seen
from far left, both search *into* the periodic region they already sit in, so translating the
witness by one period is all that is required.

The other two are the hard ones, and each needs one extra period of headroom together with
`mem_all_neg_of_period` / `mem_all_fwd_of_period`. In those, the search runs *out of* the
periodic region the position sits in and crosses the window, so in one subcase the witness
cannot be translated at all; what saves it is that the guard is then known across a complete
residue system and therefore across the whole region.
-/

/-- Rightward label periodicity, at the abbreviated period. -/
theorem label_add_nf (A : Annot P φ) {t : ℤ} (ht : A.nm ≤ t) :
    A.label (t + A.nf) = A.label t := A.label_add_fwd_length ht

/-- Leftward label periodicity, at the abbreviated period. -/
theorem label_sub_nb (A : Annot P φ) {t : ℤ} (ht : t < 0) :
    A.label (t - A.nb) = A.label t := A.label_sub_back_length ht

/--
**Pure shift: the forward obligation at far-right positions.**

At or beyond the window the whole rightward future is `|fwd|`-periodic, so a witness translates
in either direction.
-/
theorem untlObl_shift_fwd (A : Annot P φ) {t : ℤ} (ht : A.nm ≤ t) (g e : Formula) :
    UntlObl A t g e ↔ UntlObl A (t + A.nf) g e := by
  have hnf := A.nf_pos
  constructor
  · rintro ⟨s, hts, hes, hgs⟩
    refine ⟨s + A.nf, by omega, ?_, fun r hr1 hr2 => ?_⟩
    · rw [A.label_add_nf (by omega)]; exact hes
    · have := hgs (r - A.nf) (by omega) (by omega)
      rwa [← A.label_sub_nf (t := r) (by omega)]
  · rintro ⟨s, hts, hes, hgs⟩
    refine ⟨s - A.nf, by omega, ?_, fun r hr1 hr2 => ?_⟩
    · rw [A.label_sub_nf (by omega)]; exact hes
    · have := hgs (r + A.nf) (by omega) (by omega)
      rwa [A.label_add_nf (by omega)] at this

/--
**Pure shift: the backward obligation at far-left positions.**

Strictly left of the origin the whole leftward past is `|back|`-periodic.
-/
theorem snceObl_shift_back (A : Annot P φ) {t : ℤ} (ht : t + A.nb ≤ -1) (g e : Formula) :
    SnceObl A t g e ↔ SnceObl A (t + A.nb) g e := by
  have hnb := A.nb_pos
  constructor
  · rintro ⟨s, hst, hes, hgs⟩
    refine ⟨s + A.nb, by omega, ?_, fun r hr1 hr2 => ?_⟩
    · rw [A.label_add_nb (by omega)]; exact hes
    · have := hgs (r - A.nb) (by omega) (by omega)
      rwa [A.label_sub_nb (t := r) (by omega)] at this
  · rintro ⟨s, hst, hes, hgs⟩
    refine ⟨s - A.nb, by omega, ?_, fun r hr1 hr2 => ?_⟩
    · rw [A.label_sub_nb (by omega)]; exact hes
    · have := hgs (r + A.nb) (by omega) (by omega)
      rwa [A.label_add_nb (by omega)] at this

/--
**The forward obligation at far-left positions**, with two backward periods of headroom.

The `←` direction is where the work is. Given a witness `s` for the position `t + |back|`, if
`s` is still negative the witness translates. If `s` has reached the origin or beyond it cannot
translate — but then the guard is known throughout `(t + |back|, 0)`, an interval containing a
complete residue system of the backward cycle, so `mem_all_neg_of_period` gives the guard at
**every** negative position and the same `s` serves at `t`. The second period of headroom is
exactly what makes that interval long enough.
-/
theorem untlObl_shift_back (A : Annot P φ) {t : ℤ} (ht : t + 2 * A.nb ≤ -1) (g e : Formula) :
    UntlObl A t g e ↔ UntlObl A (t + A.nb) g e := by
  have hnb := A.nb_pos
  constructor
  · rintro ⟨s, hts, hes, hgs⟩
    rcases lt_or_ge (t + A.nb) s with hgt | hle
    · exact ⟨s, hgt, hes, fun r hr1 hr2 => hgs r (by omega) hr2⟩
    · refine ⟨s + A.nb, by omega, ?_, fun r hr1 hr2 => ?_⟩
      · rw [A.label_add_nb (by omega)]; exact hes
      · have := hgs (r - A.nb) (by omega) (by omega)
        rwa [A.label_sub_nb (t := r) (by omega)] at this
  · rintro ⟨s, hts, hes, hgs⟩
    rcases lt_or_ge s 0 with hneg | hnn
    · refine ⟨s - A.nb, by omega, ?_, fun r hr1 hr2 => ?_⟩
      · rw [A.label_sub_nb (by omega)]; exact hes
      · have := hgs (r + A.nb) (by omega) (by omega)
        rwa [A.label_add_nb (by omega)] at this
    · -- the witness has reached the origin: the guard survives a whole backward period
      have hall : ∀ r : ℤ, r < 0 → g ∈ A.label r := by
        refine A.mem_all_neg_of_period (a := t + A.nb) (by omega) ?_
        intro r hr1 hr2
        exact hgs r hr1 (by omega)
      exact ⟨s, by omega, hes, fun r hr1 hr2 => by
        rcases lt_or_ge (t + A.nb) r with h | h
        · exact hgs r h hr2
        · exact hall r (by omega)⟩

/--
**The backward obligation at far-right positions**, with two forward periods of headroom — the
mirror of `untlObl_shift_back`, using `mem_all_fwd_of_period`.
-/
theorem snceObl_shift_fwd (A : Annot P φ) {t : ℤ} (ht : A.nm + 2 * A.nf ≤ t) (g e : Formula) :
    SnceObl A t g e ↔ SnceObl A (t - A.nf) g e := by
  have hnf := A.nf_pos
  have hnm := A.nm_nonneg
  constructor
  · rintro ⟨s, hst, hes, hgs⟩
    rcases lt_or_ge s (t - A.nf) with hlt | hge
    · exact ⟨s, hlt, hes, fun r hr1 hr2 => hgs r hr1 (by omega)⟩
    · refine ⟨s - A.nf, by omega, ?_, fun r hr1 hr2 => ?_⟩
      · rw [A.label_sub_nf (by omega)]; exact hes
      · have := hgs (r + A.nf) (by omega) (by omega)
        rwa [A.label_add_nf (by omega)] at this
  · rintro ⟨s, hst, hes, hgs⟩
    rcases le_or_gt A.nm s with hin | hout
    · refine ⟨s + A.nf, by omega, ?_, fun r hr1 hr2 => ?_⟩
      · rw [A.label_add_nf (by omega)]; exact hes
      · have := hgs (r - A.nf) (by omega) (by omega)
        rwa [← A.label_sub_nf (t := r) (by omega)]
    · -- the witness lies left of the window: the guard survives a whole forward period
      have hall : ∀ r : ℤ, A.nm ≤ r → g ∈ A.label r := by
        refine A.mem_all_fwd_of_period (b := A.nm) le_rfl ?_
        intro r hr1 hr2
        exact hgs r (by omega) (by omega)
      exact ⟨s, by omega, hes, fun r hr1 hr2 => by
        rcases lt_or_ge r (t - A.nf) with h | h
        · exact hgs r hr1 h
        · exact hall r (by omega)⟩

/-! ### Assembling the fulfilment check

`Fulfilling` quantifies over all `g` and `e`, but a label is always a subset of the closure
(`Annot.label_subset_closure`), so only closure members can ever trigger an obligation. That is
what turns the two unbounded formula quantifiers into one `Finset` quantifier.
-/

/-- The fulfilment clause a single closure member imposes at a position. Non-temporal formulas
impose nothing. -/
def eventClauseAt (A : Annot P φ) (t : ℤ) : Formula → Prop
  | Formula.untl g e => Formula.untl g e ∈ A.label t → UntlOblB A t g e
  | Formula.snce g e => Formula.snce g e ∈ A.label t → SnceOblB A t g e
  | _ => True

instance instDecidableEventClauseAt (A : Annot P φ) (t : ℤ) :
    DecidablePred (eventClauseAt A t) := by
  intro ψ
  cases ψ <;> (dsimp only [eventClauseAt]; infer_instance)

/-- `Fulfilling`'s content at a single position, quantified over the closure as a `Finset`. -/
def FulfilAt (A : Annot P φ) (t : ℤ) : Prop :=
  ∀ ψ ∈ subformulaClosure φ, eventClauseAt A t ψ

instance instDecidableFulfilAt (A : Annot P φ) : DecidablePred (FulfilAt A) := by
  intro t
  dsimp only [FulfilAt]
  infer_instance

/-- `Fulfilling` is exactly `FulfilAt` at every position. -/
theorem fulfilling_iff_forall (A : Annot P φ) :
    Fulfilling P φ A ↔ ∀ t : ℤ, FulfilAt A t := by
  constructor
  · intro h t ψ hψ
    cases ψ with
    | atom p => trivial
    | bot => trivial
    | imp a b => trivial
    | box χ => trivial
    | untl g e =>
      intro hmem
      exact (A.untlObl_iff_bounded t g e).mp (h.1 t g e hmem)
    | snce g e =>
      intro hmem
      exact (A.snceObl_iff_bounded t g e).mp (h.2 t g e hmem)
  · intro h
    constructor
    · intro t g e hmem
      have hψ : Formula.untl g e ∈ subformulaClosure φ := A.label_subset_closure t hmem
      exact (A.untlObl_iff_bounded t g e).mpr (h t (Formula.untl g e) hψ hmem)
    · intro t g e hmem
      have hψ : Formula.snce g e ∈ subformulaClosure φ := A.label_subset_closure t hmem
      exact (A.snceObl_iff_bounded t g e).mpr (h t (Formula.snce g e) hψ hmem)

/-- **Far-left shift of the whole fulfilment check.** -/
theorem fulfilAt_shift_back (A : Annot P φ) {t : ℤ} (ht : t + 2 * A.nb ≤ -1) :
    FulfilAt A t ↔ FulfilAt A (t + A.nb) := by
  have hnb := A.nb_pos
  have hlab : A.label (t + A.nb) = A.label t := A.label_add_nb (by omega)
  constructor
  · intro h ψ hψ
    cases ψ with
    | atom p => trivial
    | bot => trivial
    | imp a b => trivial
    | box χ => trivial
    | untl g e =>
      intro hmem
      rw [hlab] at hmem
      rw [← A.untlObl_iff_bounded]
      exact (A.untlObl_shift_back (by omega) g e).mp
        ((A.untlObl_iff_bounded t g e).mpr (h (Formula.untl g e) hψ hmem))
    | snce g e =>
      intro hmem
      rw [hlab] at hmem
      rw [← A.snceObl_iff_bounded]
      exact (A.snceObl_shift_back (by omega) g e).mp
        ((A.snceObl_iff_bounded t g e).mpr (h (Formula.snce g e) hψ hmem))
  · intro h ψ hψ
    cases ψ with
    | atom p => trivial
    | bot => trivial
    | imp a b => trivial
    | box χ => trivial
    | untl g e =>
      intro hmem
      rw [← hlab] at hmem
      rw [← A.untlObl_iff_bounded]
      exact (A.untlObl_shift_back (by omega) g e).mpr
        ((A.untlObl_iff_bounded (t + A.nb) g e).mpr (h (Formula.untl g e) hψ hmem))
    | snce g e =>
      intro hmem
      rw [← hlab] at hmem
      rw [← A.snceObl_iff_bounded]
      exact (A.snceObl_shift_back (by omega) g e).mpr
        ((A.snceObl_iff_bounded (t + A.nb) g e).mpr (h (Formula.snce g e) hψ hmem))

/-- **Far-right shift of the whole fulfilment check.** -/
theorem fulfilAt_shift_fwd (A : Annot P φ) {t : ℤ} (ht : A.nm + 2 * A.nf ≤ t) :
    FulfilAt A t ↔ FulfilAt A (t - A.nf) := by
  have hnf := A.nf_pos
  have hnm := A.nm_nonneg
  have hlab : A.label (t - A.nf) = A.label t := A.label_sub_nf (by omega)
  have hshift : ∀ g e : Formula, UntlObl A (t - A.nf) g e ↔ UntlObl A t g e := by
    intro g e
    have := A.untlObl_shift_fwd (t := t - A.nf) (by omega) g e
    rwa [show t - A.nf + A.nf = t by omega] at this
  constructor
  · intro h ψ hψ
    cases ψ with
    | atom p => trivial
    | bot => trivial
    | imp a b => trivial
    | box χ => trivial
    | untl g e =>
      intro hmem
      rw [hlab] at hmem
      rw [← A.untlObl_iff_bounded]
      exact (hshift g e).mpr ((A.untlObl_iff_bounded t g e).mpr (h (Formula.untl g e) hψ hmem))
    | snce g e =>
      intro hmem
      rw [hlab] at hmem
      rw [← A.snceObl_iff_bounded]
      exact (A.snceObl_shift_fwd (by omega) g e).mp
        ((A.snceObl_iff_bounded t g e).mpr (h (Formula.snce g e) hψ hmem))
  · intro h ψ hψ
    cases ψ with
    | atom p => trivial
    | bot => trivial
    | imp a b => trivial
    | box χ => trivial
    | untl g e =>
      intro hmem
      rw [← hlab] at hmem
      rw [← A.untlObl_iff_bounded]
      exact (hshift g e).mp
        ((A.untlObl_iff_bounded (t - A.nf) g e).mpr (h (Formula.untl g e) hψ hmem))
    | snce g e =>
      intro hmem
      rw [← hlab] at hmem
      rw [← A.snceObl_iff_bounded]
      exact (A.snceObl_shift_fwd (by omega) g e).mpr
        ((A.snceObl_iff_bounded (t - A.nf) g e).mpr (h (Formula.snce g e) hψ hmem))

end Annot

/-! ## The `Fulfilling` window

The derived window is `[-2|back|, |mid| + 2|fwd|)`, of size `2|back| + |mid| + 2|fwd|`. It is
the *same* window as `LocalCoherent`'s, for a different reason: there it is because the local
check reads its immediate neighbours, here it is because the two hard shifts each need a second
period of headroom. Downstream consumers must read the bound off `fulWindowLo` / `fulWindowHi`
rather than restating the arithmetic.
-/

/-- Lower end of the fulfilment window. -/
def fulWindowLo (A : Annot P φ) : ℤ := -2 * A.nb

/-- Upper end (exclusive) of the fulfilment window. -/
def fulWindowHi (A : Annot P φ) : ℤ := A.nm + 2 * A.nf

/-- **`Fulfilling` collapses to one finite window.** -/
theorem fulfilling_iff_window (A : Annot P φ) :
    Fulfilling P φ A ↔
      ∀ t : ℤ, fulWindowLo A ≤ t → t < fulWindowHi A → Annot.FulfilAt A t := by
  rw [Annot.fulfilling_iff_forall]
  have hnb := A.nb_pos
  have hnf := A.nf_pos
  have hnm := A.nm_nonneg
  constructor
  · intro h t _ _; exact h t
  · intro h
    have left : ∀ (d : ℕ) (t : ℤ), (-t).toNat = d → t < fulWindowLo A → Annot.FulfilAt A t := by
      intro d
      induction d using Nat.strong_induction_on with
      | _ d ih =>
        intro t hd hlt
        simp only [fulWindowLo] at hlt
        refine (A.fulfilAt_shift_back (by omega)).mpr ?_
        by_cases hin : t + A.nb < fulWindowLo A
        · exact ih ((-(t + A.nb)).toNat) (by simp only [fulWindowLo] at hin; omega)
            (t + A.nb) rfl hin
        · push Not at hin
          refine h (t + A.nb) hin ?_
          simp only [fulWindowHi]
          omega
    have right : ∀ (d : ℕ) (t : ℤ), t.toNat = d → fulWindowHi A ≤ t → Annot.FulfilAt A t := by
      intro d
      induction d using Nat.strong_induction_on with
      | _ d ih =>
        intro t hd hge
        simp only [fulWindowHi] at hge
        refine (A.fulfilAt_shift_fwd (by omega)).mpr ?_
        by_cases hin : fulWindowHi A ≤ t - A.nf
        · exact ih ((t - A.nf).toNat) (by simp only [fulWindowHi] at hin; omega)
            (t - A.nf) rfl hin
        · push Not at hin
          refine h (t - A.nf) ?_ hin
          simp only [fulWindowLo]
          omega
    intro t
    rcases lt_or_ge t (fulWindowLo A) with hl | hl
    · exact left ((-t).toNat) t rfl hl
    rcases lt_or_ge t (fulWindowHi A) with hr | hr
    · exact h t hl hr
    · exact right t.toNat t rfl hr

/-- `Fulfilling` is decidable, with no appeal to classical choice for the instance data. -/
instance instDecidableFulfilling (A : Annot P φ) : Decidable (Fulfilling P φ A) :=
  decidable_of_iff
    (∀ t ∈ Finset.Ico (fulWindowLo A) (fulWindowHi A), Annot.FulfilAt A t)
    (by
      rw [fulfilling_iff_window]
      constructor
      · intro h t hlo hhi; exact h t (Finset.mem_Ico.mpr ⟨hlo, hhi⟩)
      · intro h t ht
        obtain ⟨hlo, hhi⟩ := Finset.mem_Ico.mp ht
        exact h t hlo hhi)

end FormalSystem.Metalogic.Decidability
