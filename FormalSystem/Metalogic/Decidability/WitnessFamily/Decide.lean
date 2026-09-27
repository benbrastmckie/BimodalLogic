/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Predicates
import Mathlib.Data.Int.Interval

/-!
# Deciding the Certificate Predicates

**T2**: all four certificate predicates of `Predicates.lean` quantify over `ℤ`, and this module
reduces each to a finite check that runs.

## The window collapses, transposed from `BiLasso/Decide.lean`

Every window-collapse lemma in `BiLasso/Decide.lean` reads only the label function and the three
segment lengths — never the presentation — so each transposes to `LabelledLasso` by replacing
`Annot.label` with `LabelledLasso.lab`. The correspondence is name for name:

| here (`LabelledLasso.*`) | ancestor (`Annot.*` / `Decidability.*` in `BiLasso/Decide.lean`) |
|---|---|
| `lab_sub_nf`, `lab_add_nb`, `lab_add_nf`, `lab_sub_nb` | `label_` in place of `lab_`, same four |
| `lab_reduce_fwd`, `lab_reduce_back` | `label_reduce_fwd`, `label_reduce_back` |
| `lab_congr_fwd`, `lab_congr_back` | `label_congr_fwd`, `label_congr_back` |
| `scan_forward`, `scan_backward` | `scan_forward`, `scan_backward` |
| `mem_all_neg_of_period`, `mem_all_fwd_of_period` | same names |
| `labClauseAt`, `CoherentAt`, `Coherent` | `clauseAt`, `LocalCoherentAt`, `LocalCoherent` |
| `coherentAt_congr`, `coherent_iff_window` | `localCoherentAt_congr`, `localCoherent_iff_window` |
| `UntlObl`, `SnceObl`, `UntlOblB`, `SnceOblB` | same names |
| `untlObl_descend`, `snceObl_descend` | same names |
| `untlObl_iff_bounded`, `snceObl_iff_bounded` | same names |
| the four `untlObl_shift_*` / `snceObl_shift_*` | same names |
| `eventClauseAt`, `FulfilAt`, `Fulfil` | `eventClauseAt`, `FulfilAt`, `Fulfilling` |
| `fulfilAt_shift_back`, `fulfilAt_shift_fwd` | same names |
| `fulfil_iff_window` | `fulfilling_iff_window` |

The six names carrying a `lab`/`Lab` prefix here (`labClauseAt`, `instDecidableLabClauseAt`,
`labCohWindowLo`, `labCohWindowHi`, `labFulWindowLo`, `labFulWindowHi`) differ from their
ancestors only to keep the two files' base identifiers distinct: `C17`'s dead-declaration census
keys on the last dot-segment, so two declarations sharing a base name would mask each other.

Two of the ancestors are **dropped** rather than transposed: `unroll_congr_back` and
`unroll_congr_fwd` are statements about *states*, and a `LabelledLasso` has none. Their absence
is why `coherentAt_congr` takes three label hypotheses where `localCoherentAt_congr` takes four,
and it is the only structural difference between the two window collapses.

`BoxFaithful`'s collapse has no ancestor at all: it is the one genuinely new window in this
module, and it is the simplest, needing only the two period lemmas plus the `mid` window.

## Deliberate duplication against `BiLasso/Decide.lean`

The two files now carry the same arithmetic twice, at two carriers of the same periodic decoding.
This is recorded rather than refactored, for the same reason `BiLasso/Periodic.lean` records its
duplication against `BiLasso/Basic.lean`: `Decide.lean` is consumed by the live `check` and a
shared abstraction would put a large refactor under it. **The trigger that retires it**: once a
shared periodic-label presentation lands, both files' window collapses should be redefined as its
two instances and the duplicated arithmetic deleted.

## Computable, not claimed choice-free

Every instance below computes — there is no `open Classical` and no `Classical.dec` in this
module, because an instance obtained that way would typecheck and would not run. That is a
weaker claim than choice-freedom, and choice-freedom is **not** claimed: see
`BiLasso/Check.lean`'s note on `wlem_of_saturation` for why the distinction matters.

## Main Results

- `LabelledLasso.scan_forward` / `LabelledLasso.scan_backward` — the corrected scan bounds
- `WitnessFamily.decidableLocalCoherentLab` — **T2** for local coherence
- `WitnessFamily.decidableFulfillingLab` — **T2** for fulfilment
- `WitnessFamily.decidableBoxFaithful` — **T2** for box faithfulness
- `WitnessFamily.decidableTarget` — **T2** for the target
- `WitnessFamily.decidableCertifies` — the four, composed at a target time
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

namespace LabelledLasso

variable {C : Finset Formula}

/-! ## Arithmetic helpers

Both are pure `Int.emod` facts, restated here so that this module does not import
`BiLasso/Basic.lean` — the point of the family datatype is that it has no presentation, and
importing the presentation layer for two arithmetic lemmas would undo that.
-/

/-- Reducing an index into an interval anchored at `a` does not change its residue. -/
theorem reduce_emod (n a i : ℤ) : (a + (i - a) % n) % n = i % n := by
  conv_rhs => rw [show i = a + (i - a) by omega]
  rw [Int.add_emod a ((i - a) % n) n, Int.emod_emod_of_dvd _ (dvd_refl n), ← Int.add_emod]

/-- Residues are preserved by a common shift. -/
theorem emod_shift {x y k n : ℤ} (h : x % n = y % n) : (x + k) % n = (y + k) % n := by
  rw [Int.add_emod, h, ← Int.add_emod]

/-! ## One-step periodicity, in the four convenient directions -/

/-- One step of rightward label periodicity, in the subtractive direction. -/
theorem lab_sub_nf (Λ : LabelledLasso C) {t : ℤ} (ht : Λ.nm ≤ t - Λ.nf) :
    Λ.lab (t - Λ.nf) = Λ.lab t := by
  simpa using (Λ.lab_add_fwd_length (t := t - Λ.nf) ht).symm

/-- One step of leftward label periodicity, in the additive direction. -/
theorem lab_add_nb (Λ : LabelledLasso C) {t : ℤ} (ht : t + Λ.nb < 0) :
    Λ.lab (t + Λ.nb) = Λ.lab t := by
  simpa using (Λ.lab_sub_back_length (t := t + Λ.nb) ht).symm

/-- Rightward label periodicity, at the abbreviated period. -/
theorem lab_add_nf (Λ : LabelledLasso C) {t : ℤ} (ht : Λ.nm ≤ t) :
    Λ.lab (t + Λ.nf) = Λ.lab t := Λ.lab_add_fwd_length ht

/-- Leftward label periodicity, at the abbreviated period. -/
theorem lab_sub_nb (Λ : LabelledLasso C) {t : ℤ} (ht : t < 0) :
    Λ.lab (t - Λ.nb) = Λ.lab t := Λ.lab_sub_back_length ht

/-! ## Canonical representatives -/

/--
**Rightward canonical representative.** Every position at or beyond the window has the label of
its representative `nm + (w - nm) % nf`, which lies in `[nm, nm + nf)`.
-/
theorem lab_reduce_fwd (Λ : LabelledLasso C) :
    ∀ (d : ℕ) (w : ℤ), (w - Λ.nm).toNat = d → Λ.nm ≤ w →
      Λ.lab w = Λ.lab (Λ.nm + (w - Λ.nm) % Λ.nf) := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro w hd hw
    have hnf := Λ.nf_pos
    by_cases hlt : w < Λ.nm + Λ.nf
    · rw [Int.emod_eq_of_lt (by omega) (by omega)]
      congr 1
      omega
    · push Not at hlt
      have hstep : Λ.lab (w - Λ.nf) = Λ.lab w := Λ.lab_sub_nf (by omega)
      have hres : (w - Λ.nf - Λ.nm) % Λ.nf = (w - Λ.nm) % Λ.nf := by
        rw [show w - Λ.nf - Λ.nm = (w - Λ.nm) + (-1) * Λ.nf by omega]
        exact Periodic.emod_add_mul _ _ _
      rw [← hstep, ih ((w - Λ.nf - Λ.nm).toNat) (by omega) (w - Λ.nf) rfl (by omega), hres]

/--
**Leftward canonical representative.** Every negative position has the label of its
representative `w % nb - nb`, which lies in `[-nb, 0)`.
-/
theorem lab_reduce_back (Λ : LabelledLasso C) :
    ∀ (d : ℕ) (w : ℤ), (-w).toNat = d → w < 0 →
      Λ.lab w = Λ.lab (w % Λ.nb - Λ.nb) := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro w hd hw
    have hnb := Λ.nb_pos
    by_cases hge : -Λ.nb ≤ w
    · have hres : (w + Λ.nb) % Λ.nb = w % Λ.nb := by simp
      have hval : w % Λ.nb = w + Λ.nb := by
        rw [← hres]
        exact Int.emod_eq_of_lt (by omega) (by omega)
      rw [hval]
      congr 1
      omega
    · push Not at hge
      have hstep : Λ.lab (w + Λ.nb) = Λ.lab w := Λ.lab_add_nb (by omega)
      have hres : (w + Λ.nb) % Λ.nb = w % Λ.nb := by simp
      rw [← hstep, ih ((-(w + Λ.nb)).toNat) (by omega) (w + Λ.nb) rfl (by omega), hres]

/-- Positions at or beyond the window with equal residues modulo the forward period carry equal
labels. -/
theorem lab_congr_fwd (Λ : LabelledLasso C) {u v : ℤ} (hu : Λ.nm ≤ u) (hv : Λ.nm ≤ v)
    (h : (u - Λ.nm) % Λ.nf = (v - Λ.nm) % Λ.nf) : Λ.lab u = Λ.lab v := by
  rw [Λ.lab_reduce_fwd _ u rfl hu, Λ.lab_reduce_fwd _ v rfl hv, h]

/-- Negative positions with equal residues modulo the backward period carry equal labels. -/
theorem lab_congr_back (Λ : LabelledLasso C) {u v : ℤ} (hu : u < 0) (hv : v < 0)
    (h : u % Λ.nb = v % Λ.nb) : Λ.lab u = Λ.lab v := by
  rw [Λ.lab_reduce_back _ u rfl hu, Λ.lab_reduce_back _ v rfl hv, h]

/-! ## The corrected scan bounds

Stated for an arbitrary predicate on `Finset Formula`, because it is the label sequence's
periodicity that carries the argument and no feature of the predicate is used.
-/

/--
**Corrected forward scan bound.** If some label strictly to the right of `t` satisfies `Q`, then
one does within the explicit range `(t, max t |mid| + |fwd|]`.
-/
theorem scan_forward (Λ : LabelledLasso C) (Q : Finset Formula → Prop) :
    ∀ (d : ℕ) (t s : ℤ), (s - t).toNat = d → t < s → Q (Λ.lab s) →
      ∃ s' : ℤ, t < s' ∧ s' ≤ max t Λ.nm + Λ.nf ∧ Q (Λ.lab s') := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro t s hd hts hQ
    have hnf := Λ.nf_pos
    have hmr : Λ.nm ≤ max t Λ.nm := le_max_right _ _
    have hml : t ≤ max t Λ.nm := le_max_left _ _
    by_cases hle : s ≤ max t Λ.nm + Λ.nf
    · exact ⟨s, hts, hle, hQ⟩
    · push Not at hle
      have hlab : Λ.lab (s - Λ.nf) = Λ.lab s := Λ.lab_sub_nf (by omega)
      exact ih ((s - Λ.nf - t).toNat) (by omega) t (s - Λ.nf) rfl (by omega) (hlab ▸ hQ)

/--
**Corrected backward scan bound** — the leftward mirror, over the explicit range
`[min t 0 - |back|, t)`.
-/
theorem scan_backward (Λ : LabelledLasso C) (Q : Finset Formula → Prop) :
    ∀ (d : ℕ) (t s : ℤ), (t - s).toNat = d → s < t → Q (Λ.lab s) →
      ∃ s' : ℤ, s' < t ∧ min t 0 - Λ.nb ≤ s' ∧ Q (Λ.lab s') := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro t s hd hst hQ
    have hnb := Λ.nb_pos
    have hmr : min t 0 ≤ 0 := min_le_right _ _
    have hml : min t 0 ≤ t := min_le_left _ _
    by_cases hge : min t 0 - Λ.nb ≤ s
    · exact ⟨s, hst, hge, hQ⟩
    · push Not at hge
      have hlab : Λ.lab (s + Λ.nb) = Λ.lab s := Λ.lab_add_nb (by omega)
      exact ih ((t - (s + Λ.nb)).toNat) (by omega) t (s + Λ.nb) rfl (by omega) (hlab ▸ hQ)

/-! ## Complete residue systems -/

/-- A formula present throughout one full backward period is present at **every** negative
position. -/
theorem mem_all_neg_of_period (Λ : LabelledLasso C) {g : Formula} {a : ℤ} (ha : a + Λ.nb < 0)
    (h : ∀ r : ℤ, a < r → r ≤ a + Λ.nb → g ∈ Λ.lab r) :
    ∀ r : ℤ, r < 0 → g ∈ Λ.lab r := by
  intro r hr
  have hnb := Λ.nb_pos
  set r' : ℤ := (a + 1) + (r - (a + 1)) % Λ.nb with hr'
  have hlo : a + 1 ≤ r' := by
    have : 0 ≤ (r - (a + 1)) % Λ.nb := Int.emod_nonneg _ (by omega)
    omega
  have hhi : r' < (a + 1) + Λ.nb := by
    have : (r - (a + 1)) % Λ.nb < Λ.nb := Int.emod_lt_of_pos _ hnb
    omega
  have hres : r' % Λ.nb = r % Λ.nb := reduce_emod Λ.nb (a + 1) r
  have hlab : Λ.lab r = Λ.lab r' := Λ.lab_congr_back hr (by omega) hres.symm
  rw [hlab]
  exact h r' (by omega) (by omega)

/-- A formula present throughout one full forward period is present at **every** position at or
beyond the window. -/
theorem mem_all_fwd_of_period (Λ : LabelledLasso C) {g : Formula} {b : ℤ} (hb : Λ.nm ≤ b)
    (h : ∀ r : ℤ, b ≤ r → r < b + Λ.nf → g ∈ Λ.lab r) :
    ∀ r : ℤ, Λ.nm ≤ r → g ∈ Λ.lab r := by
  intro r hr
  have hnf := Λ.nf_pos
  set r' : ℤ := b + (r - b) % Λ.nf with hr'
  have hlo : b ≤ r' := by
    have : 0 ≤ (r - b) % Λ.nf := Int.emod_nonneg _ (by omega)
    omega
  have hhi : r' < b + Λ.nf := by
    have : (r - b) % Λ.nf < Λ.nf := Int.emod_lt_of_pos _ hnf
    omega
  have hres : r' % Λ.nf = r % Λ.nf := reduce_emod Λ.nf b r
  have hres' : (r' - Λ.nm) % Λ.nf = (r - Λ.nm) % Λ.nf := by
    rw [Int.sub_emod, Int.sub_emod r, hres]
  have hlab : Λ.lab r = Λ.lab r' := Λ.lab_congr_fwd hr (by omega) hres'.symm
  rw [hlab]
  exact h r' (by omega) (by omega)

/-! ## Local coherence, position by position

`labClauseAt` re-presents a single clause as a function of the data it actually reads: the three
labels at `t - 1`, `t`, `t + 1`. The `atom` case is `True` — there is no presentation to compare
an atom against, which is exactly the point of the family datatype.
-/

/--
The local clause a single closure member imposes, at explicit label data.

`Lm`, `Lt`, `Lp` are the labels at `t - 1`, `t` and `t + 1`.
-/
def labClauseAt (bx : Formula → Bool) (Lm Lt Lp : Finset Formula) : Formula → Prop
  | Formula.atom _ => True
  | Formula.bot => True
  | Formula.imp a b => (Formula.imp a b ∈ Lt ↔ (a ∈ Lt → b ∈ Lt))
  | Formula.box χ => (Formula.box χ ∈ Lt ↔ bx χ = true)
  | Formula.untl g e => (Formula.untl g e ∈ Lt ↔ (e ∈ Lp ∨ (g ∈ Lp ∧ Formula.untl g e ∈ Lp)))
  | Formula.snce g e => (Formula.snce g e ∈ Lt ↔ (e ∈ Lm ∨ (g ∈ Lm ∧ Formula.snce g e ∈ Lm)))

/-- `labClauseAt` is decidable at every formula: each constructor's clause is a Boolean combination
of `Finset` memberships and `Bool` equalities. -/
instance instDecidableLabClauseAt (bx : Formula → Bool) (Lm Lt Lp : Finset Formula) :
    DecidablePred (labClauseAt bx Lm Lt Lp) := by
  intro ψ
  cases ψ <;> (dsimp only [labClauseAt]; infer_instance)

/-- Local coherence's content at a single position of a single lasso. -/
def CoherentAt (bx : Formula → Bool) (Λ : LabelledLasso C) (t : ℤ) : Prop :=
  Formula.bot ∉ Λ.lab t ∧
    ∀ ψ ∈ C, labClauseAt bx (Λ.lab (t - 1)) (Λ.lab t) (Λ.lab (t + 1)) ψ

/-- `CoherentAt` is decidable at every position: its closure quantifier ranges over a `Finset`. -/
instance instDecidableCoherentAt (bx : Formula → Bool) (Λ : LabelledLasso C) :
    DecidablePred (CoherentAt bx Λ) := by
  intro t
  dsimp only [CoherentAt]
  infer_instance

/-- Local coherence of a single lasso, at every position. -/
def Coherent (bx : Formula → Bool) (Λ : LabelledLasso C) : Prop :=
  ∀ t : ℤ, CoherentAt bx Λ t

/-- The per-position check depends only on the three labels, so equal data at two positions makes
the checks equivalent. Three hypotheses where `Annot`'s congruence needs four: there is no state
to match. -/
theorem coherentAt_congr (bx : Formula → Bool) (Λ : LabelledLasso C) {t t' : ℤ}
    (h0 : Λ.lab t = Λ.lab t') (hp : Λ.lab (t + 1) = Λ.lab (t' + 1))
    (hm : Λ.lab (t - 1) = Λ.lab (t' - 1)) :
    CoherentAt bx Λ t ↔ CoherentAt bx Λ t' := by
  unfold CoherentAt
  rw [h0, hp, hm]

/-- Lower end of the local-coherence window. -/
def labCohWindowLo (Λ : LabelledLasso C) : ℤ := -2 * Λ.nb

/-- Upper end (exclusive) of the local-coherence window. -/
def labCohWindowHi (Λ : LabelledLasso C) : ℤ := Λ.nm + 2 * Λ.nf

/--
**Local coherence collapses to one finite window.**

Two periods wide on each side rather than one, because the check at `t` reads `t - 1` and `t + 1`
as well as `t`: a representative must have its whole neighbourhood in the periodic region.
-/
theorem coherent_iff_window (bx : Formula → Bool) (Λ : LabelledLasso C) :
    Coherent bx Λ ↔
      ∀ t : ℤ, labCohWindowLo Λ ≤ t → t < labCohWindowHi Λ → CoherentAt bx Λ t := by
  constructor
  · intro h t _ _; exact h t
  · intro h t
    have hnb := Λ.nb_pos
    have hnf := Λ.nf_pos
    have hnm := Λ.nm_nonneg
    rcases lt_or_ge t (-1) with hfar | hmid
    · -- far left: represent `t` in `[-2|back|, -|back| - 1]`
      set t' : ℤ := t % Λ.nb - 2 * Λ.nb with ht'
      have h0 : 0 ≤ t % Λ.nb := Int.emod_nonneg _ (by omega)
      have h1 : t % Λ.nb < Λ.nb := Int.emod_lt_of_pos _ hnb
      have hres : t' % Λ.nb = t % Λ.nb := by
        have hrw : t' = t % Λ.nb + (-2) * Λ.nb := by omega
        rw [hrw, Periodic.emod_add_mul, Int.emod_emod_of_dvd _ (dvd_refl _)]
      refine (coherentAt_congr bx Λ ?_ ?_ ?_).mpr
        (h t' (by simp only [labCohWindowLo]; omega) (by simp only [labCohWindowHi]; omega))
      · exact Λ.lab_congr_back (by omega) (by omega) hres.symm
      · exact Λ.lab_congr_back (by omega) (by omega) (emod_shift hres.symm)
      · exact Λ.lab_congr_back (by omega) (by omega) (emod_shift hres.symm)
    rcases le_or_gt t Λ.nm with hin | hfar
    · -- middle: already inside the window
      exact h t (by simp only [labCohWindowLo]; omega) (by simp only [labCohWindowHi]; omega)
    · -- far right: represent `t` in `[|mid| + |fwd|, |mid| + 2|fwd|)`
      set t' : ℤ := Λ.nm + (t - Λ.nm) % Λ.nf + Λ.nf with ht'
      have h0 : 0 ≤ (t - Λ.nm) % Λ.nf := Int.emod_nonneg _ (by omega)
      have h1 : (t - Λ.nm) % Λ.nf < Λ.nf := Int.emod_lt_of_pos _ hnf
      have hres : (t' - Λ.nm) % Λ.nf = (t - Λ.nm) % Λ.nf := by
        have hrw : t' - Λ.nm = (t - Λ.nm) % Λ.nf + 1 * Λ.nf := by omega
        rw [hrw, Periodic.emod_add_mul, Int.emod_emod_of_dvd _ (dvd_refl _)]
      refine (coherentAt_congr bx Λ ?_ ?_ ?_).mpr
        (h t' (by simp only [labCohWindowLo]; omega) (by simp only [labCohWindowHi]; omega))
      · exact Λ.lab_congr_fwd (by omega) (by omega) hres.symm
      · refine Λ.lab_congr_fwd (by omega) (by omega) ?_
        have e1 : t + 1 - Λ.nm = (t - Λ.nm) + 1 := by omega
        have e2 : t' + 1 - Λ.nm = (t' - Λ.nm) + 1 := by omega
        rw [e1, e2]
        exact emod_shift hres.symm
      · refine Λ.lab_congr_fwd (by omega) (by omega) ?_
        have e1 : t - 1 - Λ.nm = (t - Λ.nm) + (-1) := by omega
        have e2 : t' - 1 - Λ.nm = (t' - Λ.nm) + (-1) := by omega
        rw [e1, e2]
        exact emod_shift hres.symm

/-- Local coherence of one lasso is decidable: the window is finite, and the per-position check is
decidable. -/
instance instDecidableCoherent (bx : Formula → Bool) (Λ : LabelledLasso C) :
    Decidable (Coherent bx Λ) :=
  decidable_of_iff
    (∀ t ∈ Finset.Ico (labCohWindowLo Λ) (labCohWindowHi Λ), CoherentAt bx Λ t)
    (by
      rw [coherent_iff_window]
      constructor
      · intro h t hlo hhi; exact h t (Finset.mem_Ico.mpr ⟨hlo, hhi⟩)
      · intro h t ht
        obtain ⟨hlo, hhi⟩ := Finset.mem_Ico.mp ht
        exact h t hlo hhi)

/-! ## Fulfilment, position by position

The harder reduction, and not a matter of shifting a window. The forward obligation at a far-left
position searches rightward across an interval whose length grows without bound as the position
decreases, so no fixed scan range works uniformly. Two things make the family finite, and they
are different from each other: a **bounded witness** (`untlObl_iff_bounded`), which makes the
check at a fixed position finite, and a **position shift** (`untlObl_shift_back`), which needs
one *extra* period of headroom — in the subcase where the witness lies at or beyond the origin
the guard is known across a complete residue system, hence, by `mem_all_neg_of_period`, across
the whole negative region.
-/

/-- The forward eventuality obligation: a witness for the event, with the guard throughout. -/
def UntlObl (Λ : LabelledLasso C) (t : ℤ) (g e : Formula) : Prop :=
  ∃ s : ℤ, t < s ∧ e ∈ Λ.lab s ∧ ∀ r : ℤ, t < r → r < s → g ∈ Λ.lab r

/-- The backward eventuality obligation. -/
def SnceObl (Λ : LabelledLasso C) (t : ℤ) (g e : Formula) : Prop :=
  ∃ s : ℤ, s < t ∧ e ∈ Λ.lab s ∧ ∀ r : ℤ, s < r → r < t → g ∈ Λ.lab r

/-- The forward obligation with the witness confined to an explicit finite range. -/
def UntlOblB (Λ : LabelledLasso C) (t : ℤ) (g e : Formula) : Prop :=
  ∃ s ∈ Finset.Ioc t (max t Λ.nm + Λ.nf),
    e ∈ Λ.lab s ∧ ∀ r ∈ Finset.Ioo t s, g ∈ Λ.lab r

/-- The backward obligation with the witness confined to an explicit finite range. -/
def SnceOblB (Λ : LabelledLasso C) (t : ℤ) (g e : Formula) : Prop :=
  ∃ s ∈ Finset.Ico (min t 0 - Λ.nb) t,
    e ∈ Λ.lab s ∧ ∀ r ∈ Finset.Ioo s t, g ∈ Λ.lab r

/-- The bounded forward obligation is decidable, because its witness ranges over an explicit
finite interval. The unbounded `UntlObl` has no such instance; decide it through `UntlOblB`. -/
instance instDecidableUntlOblB (Λ : LabelledLasso C) (t : ℤ) (g e : Formula) :
    Decidable (UntlOblB Λ t g e) := by
  dsimp only [UntlOblB]; infer_instance

/-- The bounded backward obligation is decidable, for the mirrored reason. -/
instance instDecidableSnceOblB (Λ : LabelledLasso C) (t : ℤ) (g e : Formula) :
    Decidable (SnceOblB Λ t g e) := by
  dsimp only [SnceOblB]; infer_instance

/-- Descent for the forward obligation: a witness beyond one forward period past the window can
be pulled back one period, because the labels there repeat and the guard interval only shrinks. -/
theorem untlObl_descend (Λ : LabelledLasso C) (g e : Formula) :
    ∀ (d : ℕ) (t s : ℤ), (s - t).toNat = d → t < s → e ∈ Λ.lab s →
      (∀ r : ℤ, t < r → r < s → g ∈ Λ.lab r) → UntlOblB Λ t g e := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro t s hd hts hes hgs
    have hnf := Λ.nf_pos
    have hmr : Λ.nm ≤ max t Λ.nm := le_max_right _ _
    have hml : t ≤ max t Λ.nm := le_max_left _ _
    by_cases hle : s ≤ max t Λ.nm + Λ.nf
    · exact ⟨s, Finset.mem_Ioc.mpr ⟨hts, hle⟩, hes,
        fun r hr => hgs r (Finset.mem_Ioo.mp hr).1 (Finset.mem_Ioo.mp hr).2⟩
    · push Not at hle
      have hlab : Λ.lab (s - Λ.nf) = Λ.lab s := Λ.lab_sub_nf (by omega)
      refine ih ((s - Λ.nf - t).toNat) (by omega) t (s - Λ.nf) rfl (by omega) (hlab ▸ hes) ?_
      exact fun r hr1 hr2 => hgs r hr1 (by omega)

/-- Descent for the backward obligation — the leftward mirror. -/
theorem snceObl_descend (Λ : LabelledLasso C) (g e : Formula) :
    ∀ (d : ℕ) (t s : ℤ), (t - s).toNat = d → s < t → e ∈ Λ.lab s →
      (∀ r : ℤ, s < r → r < t → g ∈ Λ.lab r) → SnceOblB Λ t g e := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro t s hd hst hes hgs
    have hnb := Λ.nb_pos
    have hmr : min t 0 ≤ 0 := min_le_right _ _
    have hml : min t 0 ≤ t := min_le_left _ _
    by_cases hge : min t 0 - Λ.nb ≤ s
    · exact ⟨s, Finset.mem_Ico.mpr ⟨hge, hst⟩, hes,
        fun r hr => hgs r (Finset.mem_Ioo.mp hr).1 (Finset.mem_Ioo.mp hr).2⟩
    · push Not at hge
      have hlab : Λ.lab (s + Λ.nb) = Λ.lab s := Λ.lab_add_nb (by omega)
      refine ih ((t - (s + Λ.nb)).toNat) (by omega) t (s + Λ.nb) rfl (by omega) (hlab ▸ hes) ?_
      exact fun r hr1 hr2 => hgs r (by omega) hr2

/-- **The forward obligation has a bounded witness.** -/
theorem untlObl_iff_bounded (Λ : LabelledLasso C) (t : ℤ) (g e : Formula) :
    UntlObl Λ t g e ↔ UntlOblB Λ t g e := by
  constructor
  · rintro ⟨s, hts, hes, hgs⟩
    exact Λ.untlObl_descend g e (s - t).toNat t s rfl hts hes hgs
  · rintro ⟨s, hs, hes, hgs⟩
    obtain ⟨hlo, _⟩ := Finset.mem_Ioc.mp hs
    exact ⟨s, hlo, hes, fun r hr1 hr2 => hgs r (Finset.mem_Ioo.mpr ⟨hr1, hr2⟩)⟩

/-- **The backward obligation has a bounded witness.** -/
theorem snceObl_iff_bounded (Λ : LabelledLasso C) (t : ℤ) (g e : Formula) :
    SnceObl Λ t g e ↔ SnceOblB Λ t g e := by
  constructor
  · rintro ⟨s, hst, hes, hgs⟩
    exact Λ.snceObl_descend g e (t - s).toNat t s rfl hst hes hgs
  · rintro ⟨s, hs, hes, hgs⟩
    obtain ⟨_, hhi⟩ := Finset.mem_Ico.mp hs
    exact ⟨s, hhi, hes, fun r hr1 hr2 => hgs r (Finset.mem_Ioo.mpr ⟨hr1, hr2⟩)⟩

/-- **Pure shift: the forward obligation at far-right positions.** -/
theorem untlObl_shift_fwd (Λ : LabelledLasso C) {t : ℤ} (ht : Λ.nm ≤ t) (g e : Formula) :
    UntlObl Λ t g e ↔ UntlObl Λ (t + Λ.nf) g e := by
  have hnf := Λ.nf_pos
  constructor
  · rintro ⟨s, hts, hes, hgs⟩
    refine ⟨s + Λ.nf, by omega, ?_, fun r hr1 hr2 => ?_⟩
    · rw [Λ.lab_add_nf (by omega)]; exact hes
    · have hg := hgs (r - Λ.nf) (by omega) (by omega)
      rwa [← Λ.lab_sub_nf (t := r) (by omega)]
  · rintro ⟨s, hts, hes, hgs⟩
    refine ⟨s - Λ.nf, by omega, ?_, fun r hr1 hr2 => ?_⟩
    · rw [Λ.lab_sub_nf (by omega)]; exact hes
    · have hg := hgs (r + Λ.nf) (by omega) (by omega)
      rwa [Λ.lab_add_nf (by omega)] at hg

/-- **Pure shift: the backward obligation at far-left positions.** -/
theorem snceObl_shift_back (Λ : LabelledLasso C) {t : ℤ} (ht : t + Λ.nb ≤ -1) (g e : Formula) :
    SnceObl Λ t g e ↔ SnceObl Λ (t + Λ.nb) g e := by
  have hnb := Λ.nb_pos
  constructor
  · rintro ⟨s, hst, hes, hgs⟩
    refine ⟨s + Λ.nb, by omega, ?_, fun r hr1 hr2 => ?_⟩
    · rw [Λ.lab_add_nb (by omega)]; exact hes
    · have hg := hgs (r - Λ.nb) (by omega) (by omega)
      rwa [Λ.lab_sub_nb (t := r) (by omega)] at hg
  · rintro ⟨s, hst, hes, hgs⟩
    refine ⟨s - Λ.nb, by omega, ?_, fun r hr1 hr2 => ?_⟩
    · rw [Λ.lab_sub_nb (by omega)]; exact hes
    · have hg := hgs (r + Λ.nb) (by omega) (by omega)
      rwa [Λ.lab_add_nb (by omega)] at hg

/--
**The forward obligation at far-left positions**, with two backward periods of headroom.

The `←` direction is where the work is. Given a witness `s` for the position `t + |back|`, if `s`
is still negative the witness translates. If `s` has reached the origin it cannot — but then the
guard is known throughout an interval containing a complete residue system of the backward cycle,
so `mem_all_neg_of_period` gives the guard at **every** negative position and the same `s` serves.
-/
theorem untlObl_shift_back (Λ : LabelledLasso C) {t : ℤ} (ht : t + 2 * Λ.nb ≤ -1) (g e : Formula) :
    UntlObl Λ t g e ↔ UntlObl Λ (t + Λ.nb) g e := by
  have hnb := Λ.nb_pos
  constructor
  · rintro ⟨s, hts, hes, hgs⟩
    rcases lt_or_ge (t + Λ.nb) s with hgt | hle
    · exact ⟨s, hgt, hes, fun r hr1 hr2 => hgs r (by omega) hr2⟩
    · refine ⟨s + Λ.nb, by omega, ?_, fun r hr1 hr2 => ?_⟩
      · rw [Λ.lab_add_nb (by omega)]; exact hes
      · have hg := hgs (r - Λ.nb) (by omega) (by omega)
        rwa [Λ.lab_sub_nb (t := r) (by omega)] at hg
  · rintro ⟨s, hts, hes, hgs⟩
    rcases lt_or_ge s 0 with hneg | hnn
    · refine ⟨s - Λ.nb, by omega, ?_, fun r hr1 hr2 => ?_⟩
      · rw [Λ.lab_sub_nb (by omega)]; exact hes
      · have hg := hgs (r + Λ.nb) (by omega) (by omega)
        rwa [Λ.lab_add_nb (by omega)] at hg
    · have hall : ∀ r : ℤ, r < 0 → g ∈ Λ.lab r := by
        refine Λ.mem_all_neg_of_period (a := t + Λ.nb) (by omega) ?_
        intro r hr1 hr2
        exact hgs r hr1 (by omega)
      exact ⟨s, by omega, hes, fun r hr1 hr2 => by
        rcases lt_or_ge (t + Λ.nb) r with h | h
        · exact hgs r h hr2
        · exact hall r (by omega)⟩

/--
**The backward obligation at far-right positions**, with two forward periods of headroom — the
mirror of `untlObl_shift_back`, using `mem_all_fwd_of_period`.
-/
theorem snceObl_shift_fwd (Λ : LabelledLasso C) {t : ℤ} (ht : Λ.nm + 2 * Λ.nf ≤ t) (g e : Formula) :
    SnceObl Λ t g e ↔ SnceObl Λ (t - Λ.nf) g e := by
  have hnf := Λ.nf_pos
  have hnm := Λ.nm_nonneg
  constructor
  · rintro ⟨s, hst, hes, hgs⟩
    rcases lt_or_ge s (t - Λ.nf) with hlt | hge
    · exact ⟨s, hlt, hes, fun r hr1 hr2 => hgs r hr1 (by omega)⟩
    · refine ⟨s - Λ.nf, by omega, ?_, fun r hr1 hr2 => ?_⟩
      · rw [Λ.lab_sub_nf (by omega)]; exact hes
      · have hg := hgs (r + Λ.nf) (by omega) (by omega)
        rwa [Λ.lab_add_nf (by omega)] at hg
  · rintro ⟨s, hst, hes, hgs⟩
    rcases le_or_gt Λ.nm s with hin | hout
    · refine ⟨s + Λ.nf, by omega, ?_, fun r hr1 hr2 => ?_⟩
      · rw [Λ.lab_add_nf (by omega)]; exact hes
      · have hg := hgs (r - Λ.nf) (by omega) (by omega)
        rwa [← Λ.lab_sub_nf (t := r) (by omega)]
    · have hall : ∀ r : ℤ, Λ.nm ≤ r → g ∈ Λ.lab r := by
        refine Λ.mem_all_fwd_of_period (b := Λ.nm) le_rfl ?_
        intro r hr1 hr2
        exact hgs r (by omega) (by omega)
      exact ⟨s, by omega, hes, fun r hr1 hr2 => by
        rcases lt_or_ge r (t - Λ.nf) with h | h
        · exact hgs r hr1 h
        · exact hall r (by omega)⟩

/-- The fulfilment clause a single closure member imposes at a position. Non-temporal formulas
impose nothing. -/
def eventClauseAt (Λ : LabelledLasso C) (t : ℤ) : Formula → Prop
  | Formula.untl g e => Formula.untl g e ∈ Λ.lab t → UntlOblB Λ t g e
  | Formula.snce g e => Formula.snce g e ∈ Λ.lab t → SnceOblB Λ t g e
  | _ => True

/-- `eventClauseAt` is decidable at every formula. -/
instance instDecidableEventClauseAt (Λ : LabelledLasso C) (t : ℤ) :
    DecidablePred (eventClauseAt Λ t) := by
  intro ψ
  cases ψ <;> (dsimp only [eventClauseAt]; infer_instance)

/-- Fulfilment's content at a single position, quantified over the closure as a `Finset`. -/
def FulfilAt (Λ : LabelledLasso C) (t : ℤ) : Prop :=
  ∀ ψ ∈ C, eventClauseAt Λ t ψ

/-- `FulfilAt` is decidable at every position. -/
instance instDecidableFulfilAt (Λ : LabelledLasso C) : DecidablePred (FulfilAt Λ) := by
  intro t
  dsimp only [FulfilAt]
  infer_instance

/-- Fulfilment of a single lasso, at every position and every eventuality. -/
def Fulfil (Λ : LabelledLasso C) : Prop :=
  (∀ (t : ℤ) (g e : Formula), Formula.untl g e ∈ Λ.lab t → UntlObl Λ t g e) ∧
  (∀ (t : ℤ) (g e : Formula), Formula.snce g e ∈ Λ.lab t → SnceObl Λ t g e)

/-- Fulfilment is exactly `FulfilAt` at every position. The two unbounded formula quantifiers
collapse to one `Finset` quantifier because labels are subsets of the closure. -/
theorem fulfil_iff_forall (Λ : LabelledLasso C) :
    Fulfil Λ ↔ ∀ t : ℤ, FulfilAt Λ t := by
  constructor
  · intro h t ψ hψ
    cases ψ with
    | atom p => trivial
    | bot => trivial
    | imp a b => trivial
    | box χ => trivial
    | untl g e =>
      intro hmem
      exact (Λ.untlObl_iff_bounded t g e).mp (h.1 t g e hmem)
    | snce g e =>
      intro hmem
      exact (Λ.snceObl_iff_bounded t g e).mp (h.2 t g e hmem)
  · intro h
    constructor
    · intro t g e hmem
      have hψ : Formula.untl g e ∈ C := Λ.lab_subset t hmem
      exact (Λ.untlObl_iff_bounded t g e).mpr (h t (Formula.untl g e) hψ hmem)
    · intro t g e hmem
      have hψ : Formula.snce g e ∈ C := Λ.lab_subset t hmem
      exact (Λ.snceObl_iff_bounded t g e).mpr (h t (Formula.snce g e) hψ hmem)

/-- **Far-left shift of the whole fulfilment check.** -/
theorem fulfilAt_shift_back (Λ : LabelledLasso C) {t : ℤ} (ht : t + 2 * Λ.nb ≤ -1) :
    FulfilAt Λ t ↔ FulfilAt Λ (t + Λ.nb) := by
  have hnb := Λ.nb_pos
  have hlab : Λ.lab (t + Λ.nb) = Λ.lab t := Λ.lab_add_nb (by omega)
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
      rw [← Λ.untlObl_iff_bounded]
      exact (Λ.untlObl_shift_back (by omega) g e).mp
        ((Λ.untlObl_iff_bounded t g e).mpr (h (Formula.untl g e) hψ hmem))
    | snce g e =>
      intro hmem
      rw [hlab] at hmem
      rw [← Λ.snceObl_iff_bounded]
      exact (Λ.snceObl_shift_back (by omega) g e).mp
        ((Λ.snceObl_iff_bounded t g e).mpr (h (Formula.snce g e) hψ hmem))
  · intro h ψ hψ
    cases ψ with
    | atom p => trivial
    | bot => trivial
    | imp a b => trivial
    | box χ => trivial
    | untl g e =>
      intro hmem
      rw [← hlab] at hmem
      rw [← Λ.untlObl_iff_bounded]
      exact (Λ.untlObl_shift_back (by omega) g e).mpr
        ((Λ.untlObl_iff_bounded (t + Λ.nb) g e).mpr (h (Formula.untl g e) hψ hmem))
    | snce g e =>
      intro hmem
      rw [← hlab] at hmem
      rw [← Λ.snceObl_iff_bounded]
      exact (Λ.snceObl_shift_back (by omega) g e).mpr
        ((Λ.snceObl_iff_bounded (t + Λ.nb) g e).mpr (h (Formula.snce g e) hψ hmem))

/-- **Far-right shift of the whole fulfilment check.** -/
theorem fulfilAt_shift_fwd (Λ : LabelledLasso C) {t : ℤ} (ht : Λ.nm + 2 * Λ.nf ≤ t) :
    FulfilAt Λ t ↔ FulfilAt Λ (t - Λ.nf) := by
  have hnf := Λ.nf_pos
  have hnm := Λ.nm_nonneg
  have hlab : Λ.lab (t - Λ.nf) = Λ.lab t := Λ.lab_sub_nf (by omega)
  have hshift : ∀ g e : Formula, UntlObl Λ (t - Λ.nf) g e ↔ UntlObl Λ t g e := by
    intro g e
    have hs := Λ.untlObl_shift_fwd (t := t - Λ.nf) (by omega) g e
    rwa [show t - Λ.nf + Λ.nf = t by omega] at hs
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
      rw [← Λ.untlObl_iff_bounded]
      exact (hshift g e).mpr ((Λ.untlObl_iff_bounded t g e).mpr (h (Formula.untl g e) hψ hmem))
    | snce g e =>
      intro hmem
      rw [hlab] at hmem
      rw [← Λ.snceObl_iff_bounded]
      exact (Λ.snceObl_shift_fwd (by omega) g e).mp
        ((Λ.snceObl_iff_bounded t g e).mpr (h (Formula.snce g e) hψ hmem))
  · intro h ψ hψ
    cases ψ with
    | atom p => trivial
    | bot => trivial
    | imp a b => trivial
    | box χ => trivial
    | untl g e =>
      intro hmem
      rw [← hlab] at hmem
      rw [← Λ.untlObl_iff_bounded]
      exact (hshift g e).mp
        ((Λ.untlObl_iff_bounded (t - Λ.nf) g e).mpr (h (Formula.untl g e) hψ hmem))
    | snce g e =>
      intro hmem
      rw [← hlab] at hmem
      rw [← Λ.snceObl_iff_bounded]
      exact (Λ.snceObl_shift_fwd (by omega) g e).mpr
        ((Λ.snceObl_iff_bounded (t - Λ.nf) g e).mpr (h (Formula.snce g e) hψ hmem))

/-- Lower end of the fulfilment window. -/
def labFulWindowLo (Λ : LabelledLasso C) : ℤ := -2 * Λ.nb

/-- Upper end (exclusive) of the fulfilment window. -/
def labFulWindowHi (Λ : LabelledLasso C) : ℤ := Λ.nm + 2 * Λ.nf

/-- **Fulfilment collapses to one finite window.** -/
theorem fulfil_iff_window (Λ : LabelledLasso C) :
    Fulfil Λ ↔ ∀ t : ℤ, labFulWindowLo Λ ≤ t → t < labFulWindowHi Λ → FulfilAt Λ t := by
  rw [fulfil_iff_forall]
  have hnb := Λ.nb_pos
  have hnf := Λ.nf_pos
  have hnm := Λ.nm_nonneg
  constructor
  · intro h t _ _; exact h t
  · intro h
    have left : ∀ (d : ℕ) (t : ℤ), (-t).toNat = d → t < labFulWindowLo Λ → FulfilAt Λ t := by
      intro d
      induction d using Nat.strong_induction_on with
      | _ d ih =>
        intro t hd hlt
        simp only [labFulWindowLo] at hlt
        refine (Λ.fulfilAt_shift_back (by omega)).mpr ?_
        by_cases hin : t + Λ.nb < labFulWindowLo Λ
        · exact ih ((-(t + Λ.nb)).toNat) (by simp only [labFulWindowLo] at hin; omega)
            (t + Λ.nb) rfl hin
        · push Not at hin
          refine h (t + Λ.nb) hin ?_
          simp only [labFulWindowHi]
          omega
    have right : ∀ (d : ℕ) (t : ℤ), t.toNat = d → labFulWindowHi Λ ≤ t → FulfilAt Λ t := by
      intro d
      induction d using Nat.strong_induction_on with
      | _ d ih =>
        intro t hd hge
        simp only [labFulWindowHi] at hge
        refine (Λ.fulfilAt_shift_fwd (by omega)).mpr ?_
        by_cases hin : labFulWindowHi Λ ≤ t - Λ.nf
        · exact ih ((t - Λ.nf).toNat) (by simp only [labFulWindowHi] at hin; omega)
            (t - Λ.nf) rfl hin
        · push Not at hin
          refine h (t - Λ.nf) ?_ hin
          simp only [labFulWindowLo]
          omega
    intro t
    rcases lt_or_ge t (labFulWindowLo Λ) with hl | hl
    · exact left ((-t).toNat) t rfl hl
    rcases lt_or_ge t (labFulWindowHi Λ) with hr | hr
    · exact h t hl hr
    · exact right t.toNat t rfl hr

/-- Fulfilment of one lasso is decidable, with no appeal to classical choice for the instance
data. -/
instance instDecidableFulfil (Λ : LabelledLasso C) : Decidable (Fulfil Λ) :=
  decidable_of_iff
    (∀ t ∈ Finset.Ico (labFulWindowLo Λ) (labFulWindowHi Λ), FulfilAt Λ t)
    (by
      rw [fulfil_iff_window]
      constructor
      · intro h t hlo hhi; exact h t (Finset.mem_Ico.mpr ⟨hlo, hhi⟩)
      · intro h t ht
        obtain ⟨hlo, hhi⟩ := Finset.mem_Ico.mp ht
        exact h t hlo hhi)

/-! ## The global-membership window

The one collapse in this module with no ancestor in `BiLasso/Decide.lean`, and the simplest:
`mem_all_neg_of_period` covers the negatives, the `mid` window covers `[0, |mid|)`, and
`mem_all_fwd_of_period` covers the rest. One period on each side suffices, because unlike the
local check this one reads no neighbours.
-/

/-- **Global label membership collapses to one finite window** of width `|back| + |mid| + |fwd|`. -/
theorem mem_all_iff_window (Λ : LabelledLasso C) (χ : Formula) :
    (∀ t : ℤ, χ ∈ Λ.lab t) ↔ ∀ t ∈ Finset.Ico (-Λ.nb) (Λ.nm + Λ.nf), χ ∈ Λ.lab t := by
  have hnb := Λ.nb_pos
  have hnf := Λ.nf_pos
  have hnm := Λ.nm_nonneg
  constructor
  · intro h t _; exact h t
  · intro h
    have hwin : ∀ r : ℤ, -Λ.nb ≤ r → r < Λ.nm + Λ.nf → χ ∈ Λ.lab r :=
      fun r h1 h2 => h r (Finset.mem_Ico.mpr ⟨h1, h2⟩)
    intro t
    rcases lt_or_ge t 0 with hneg | hnn
    · refine Λ.mem_all_neg_of_period (a := -Λ.nb - 1) (by omega) ?_ t hneg
      intro r hr1 hr2
      exact hwin r (by omega) (by omega)
    rcases lt_or_ge t Λ.nm with hmid | hfar
    · exact hwin t (by omega) (by omega)
    · refine Λ.mem_all_fwd_of_period (b := Λ.nm) le_rfl ?_ t hfar
      intro r hr1 hr2
      exact hwin r (by omega) (by omega)

end LabelledLasso

namespace WitnessFamily

variable {Γ Del : Context}

/-! ## Lifting the per-lasso collapses to the family

Each family predicate is the corresponding per-lasso predicate at every lasso, and the family has
finitely many lassos, so `Fintype.decidableForallFintype` closes the outer quantifier once the
per-lasso instance is in place.
-/

/-- Local coherence of the family is local coherence of each of its lassos. -/
theorem localCoherentLab_iff_lassos (W : WitnessFamily Γ Del) :
    W.LocalCoherentLab ↔
      ∀ i : Fin W.lassos.length, LabelledLasso.Coherent W.bx (W.lassos.get i) := by
  constructor
  · intro h i t
    refine ⟨(h i t).1, fun ψ hψ => ?_⟩
    cases ψ with
    | atom p => trivial
    | bot => trivial
    | imp a b => exact (h i t).2.1 a b hψ
    | box χ => exact (h i t).2.2.1 χ hψ
    | untl g e => exact (h i t).2.2.2.1 g e hψ
    | snce g e => exact (h i t).2.2.2.2 g e hψ
  · intro h i t
    exact ⟨(h i t).1,
      fun a b hab => (h i t).2 (Formula.imp a b) hab,
      fun χ hχ => (h i t).2 (Formula.box χ) hχ,
      fun g e hge => (h i t).2 (Formula.untl g e) hge,
      fun g e hge => (h i t).2 (Formula.snce g e) hge⟩

/-- **T2** — local coherence decides by a bounded window scan, one window per lasso. -/
instance decidableLocalCoherentLab (W : WitnessFamily Γ Del) : Decidable W.LocalCoherentLab :=
  decidable_of_iff _ (W.localCoherentLab_iff_lassos).symm

/-- Fulfilment of the family is fulfilment of each of its lassos. -/
theorem fulfillingLab_iff_lassos (W : WitnessFamily Γ Del) :
    W.FulfillingLab ↔ ∀ i : Fin W.lassos.length, LabelledLasso.Fulfil (W.lassos.get i) := by
  constructor
  · intro h i
    exact ⟨fun t g e hm => h.1 i t g e hm, fun t g e hm => h.2 i t g e hm⟩
  · intro h
    exact ⟨fun i t g e hm => (h i).1 t g e hm, fun i t g e hm => (h i).2 t g e hm⟩

/-- **T2** — fulfilment decides by a bounded window scan, one window per lasso. -/
instance decidableFulfillingLab (W : WitnessFamily Γ Del) : Decidable W.FulfillingLab :=
  decidable_of_iff _ (W.fulfillingLab_iff_lassos).symm

/-- Global membership along one lasso collapses to that lasso's own window. Stated at `W.L` so
that instance search matches the form `BoxFaithful` actually uses. -/
theorem mem_all_iff_window (W : WitnessFamily Γ Del) (i : Fin W.lassos.length) (χ : Formula) :
    (∀ t : ℤ, χ ∈ W.L i t) ↔
      ∀ t ∈ Finset.Ico (-(W.lassos.get i).nb) ((W.lassos.get i).nm + (W.lassos.get i).nf),
        χ ∈ W.L i t :=
  LabelledLasso.mem_all_iff_window (W.lassos.get i) χ

/-- Global membership along one lasso is decidable. -/
instance instDecidableMemAll (W : WitnessFamily Γ Del) (i : Fin W.lassos.length) (χ : Formula) :
    Decidable (∀ t : ℤ, χ ∈ W.L i t) :=
  decidable_of_iff _ (W.mem_all_iff_window i χ).symm

/-- The box-faithfulness clause a single closure member imposes. Only boxed formulas impose
anything; this is what turns `BoxFaithful`'s unbounded `∀ χ : Formula` into a `Finset`
quantifier. -/
def boxClause (W : WitnessFamily Γ Del) : Formula → Prop
  | Formula.box χ => (W.bx χ = true ↔ ∀ (i : Fin W.lassos.length) (t : ℤ), χ ∈ W.L i t)
  | _ => True

/-- `boxClause` is decidable at every formula, by `instDecidableMemAll` and finiteness of the
lasso index. -/
instance instDecidableBoxClause (W : WitnessFamily Γ Del) : DecidablePred W.boxClause := by
  intro ψ
  cases ψ <;> (dsimp only [boxClause]; infer_instance)

/-- Box faithfulness is exactly `boxClause` at every closure member. -/
theorem boxFaithful_iff_forall (W : WitnessFamily Γ Del) :
    W.BoxFaithful ↔ ∀ ψ ∈ closureOf (Γ ++ Del), W.boxClause ψ := by
  constructor
  · intro h ψ hψ
    cases ψ with
    | atom p => trivial
    | bot => trivial
    | imp a b => trivial
    | box χ => exact h χ hψ
    | untl g e => trivial
    | snce g e => trivial
  · intro h χ hχ
    exact h (Formula.box χ) hχ

/-- **T2** — box faithfulness decides by the `mid` window plus the two periodicities. -/
instance decidableBoxFaithful (W : WitnessFamily Γ Del) : Decidable W.BoxFaithful :=
  decidable_of_iff _ (W.boxFaithful_iff_forall).symm

/-- **T2** — the target decides outright, by two list scans. -/
instance decidableTarget (W : WitnessFamily Γ Del) (t : ℤ) : Decidable (W.Target t) := by
  dsimp only [Target]
  infer_instance

/-- **T2** for the bundle: `Certifies` decides by composing the four instances above through
`instDecidableAnd`, which short-circuits left to right in `Certifies`' conjunction order. This
is the instance an accepting checker branch discharges its `refutes_of_certifies` hypothesis
with. -/
instance decidableCertifies (W : WitnessFamily Γ Del) (t : ℤ) : Decidable (W.Certifies t) := by
  dsimp only [Certifies]
  infer_instance

end WitnessFamily

end FormalSystem.Metalogic.Decidability
