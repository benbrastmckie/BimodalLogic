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

end FormalSystem.Metalogic.Decidability
