/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Cycle

/-!
# From Good Cycles to Fulfilment, at a Bare Label Sequence

`Cycle.lean` produces two bounded cycles that *deliver* the eventualities of their base type.
This module converts that into full `FulfillingSeqLab`: every eventuality carried at **every**
position of a bi-periodic locally coherent label sequence is discharged, with the interval guard
`FulfillingSeqLab` demands.

## The two propagation lemmas

An undischarged `untl` survives to the end of the stretch with its guard intact, and a `snce`
survives back to its start. Both are ℤ-inductions on the corresponding clause of
`LocalCoherentSeqLab`, which is a biconditional and therefore usable in this direction.

The `snce` lemma is stated separately rather than derived by duality, for the reason
`BiLasso/GoodCycle.lean` gives for the same pair: the tree has no `Formula` duality operation,
and inventing one for a single use costs more than the twelve lines it saves.

## The clearest instance of the duplication

`lab_add_mul_nfC` and `lab_sub_mul_nbC` transcribe `BiLasso/GoodCycle.lean`'s `lab_add_mul_nf`
and `lab_sub_mul_nb` with **no change at all**: those two lemmas are already presentation-free
there — their only variable is `{lab : ℤ → Finset Formula}` — and the only reason they cannot be
imported is the directory invariant recorded in `Cycle.lean`'s header. They are the sharpest
illustration of what the retirement trigger named there is meant to retire.

## Why the sequence-level route rather than the window collapse

`WitnessFamily/Decide.lean`'s collapses are stated for a `WitnessFamily`. The assembly needs the
fulfilment conclusion at **bare sequences**, before any family exists to state it about, so the
propagation route is the prescribed one here, not a fallback.

## Main Results

- `untl_propagates_to_endC` / `snce_propagates_to_startC` — the interior-eventuality reduction
- `lab_add_mul_nfC` / `lab_sub_mul_nbC` — the two iterated periodicities
- `fulfillingSeqLab_of_good_cycles` — **two good cycles plus periodicity give fulfilment**

Argument order is **guard first**: `Formula.untl g e`, `Formula.snce g e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {Γ Del : Context} {bx : Formula → Bool}

/-! ## The interior-eventuality reduction -/

/--
**An undischarged `untl` survives to the end of the stretch, guard intact.**

If `Formula.untl g e` is carried at `t` and its event `e` appears nowhere in `(t, T]`, then the
obligation is still carried at `T` and the guard `g` holds at every position of `(t, T]`.

Two consequences, both used below:

1. **The mark count is capped before any loop is chosen.** An `untl` carried at an interior
   position of a cycle either delivers inside the cycle or is still carried at the cycle's
   endpoint, whose type is the base type.
2. **The interval guard is free.** Taking `T` to be one less than the *least* delivery position
   turns this lemma's guard conclusion into exactly the interval condition `FulfillingSeqLab`
   demands.

The proof is rightward ℤ-induction (`Int.rightInduction`, `BiLasso/Unfold.lean`) on the `untl`
clause of `LocalCoherentSeqLab`. It reads only that clause — no atom clause (which does not exist
here) and no state sequence.
-/
theorem untl_propagates_to_endC {lab : ℤ → Finset Formula}
    (hco : LocalCoherentSeqLab Γ Del bx lab) {g e : Formula}
    (hcl : Formula.untl g e ∈ closureOf (Γ ++ Del)) {t : ℤ}
    (hmem : Formula.untl g e ∈ lab t) :
    ∀ T : ℤ, t ≤ T → (∀ s : ℤ, t < s → s ≤ T → e ∉ lab s) →
      Formula.untl g e ∈ lab T ∧ ∀ r : ℤ, t < r → r ≤ T → g ∈ lab r := by
  refine Int.rightInduction (t := t) (P := fun T =>
      (∀ s : ℤ, t < s → s ≤ T → e ∉ lab s) →
        Formula.untl g e ∈ lab T ∧ ∀ r : ℤ, t < r → r ≤ T → g ∈ lab r) ?_ ?_
  · exact fun _ => ⟨hmem, fun r h1 h2 => absurd h1 (by omega)⟩
  · intro u hu ih hno
    obtain ⟨hcarry, hguard⟩ := ih (fun s h1 h2 => hno s h1 (by omega))
    have hclause := (hco u).2.2.2.1 g e hcl
    have hne : e ∉ lab (u + 1) := hno (u + 1) (by omega) (by omega)
    rcases hclause.mp hcarry with h | ⟨hg, hc⟩
    · exact absurd h hne
    · refine ⟨hc, fun r h1 h2 => ?_⟩
      rcases (by omega : r ≤ u ∨ r = u + 1) with hr | rfl
      · exact hguard r h1 hr
      · exact hg

/--
**The leftward mirror**: an undischarged `snce` survives back to the start of the stretch.

Same statement with the two temporal directions exchanged, proved by leftward ℤ-induction
(`Int.leftInduction`) on the `snce` clause.
-/
theorem snce_propagates_to_startC {lab : ℤ → Finset Formula}
    (hco : LocalCoherentSeqLab Γ Del bx lab) {g e : Formula}
    (hcl : Formula.snce g e ∈ closureOf (Γ ++ Del)) {t : ℤ}
    (hmem : Formula.snce g e ∈ lab t) :
    ∀ T : ℤ, T ≤ t → (∀ s : ℤ, T ≤ s → s < t → e ∉ lab s) →
      Formula.snce g e ∈ lab T ∧ ∀ r : ℤ, T ≤ r → r < t → g ∈ lab r := by
  refine Int.leftInduction (t := t) (P := fun T =>
      (∀ s : ℤ, T ≤ s → s < t → e ∉ lab s) →
        Formula.snce g e ∈ lab T ∧ ∀ r : ℤ, T ≤ r → r < t → g ∈ lab r) ?_ ?_
  · exact fun _ => ⟨hmem, fun r h1 h2 => absurd h1 (by omega)⟩
  · intro u hu ih hno
    obtain ⟨hcarry, hguard⟩ := ih (fun s h1 h2 => hno s (by omega) h2)
    have hclause := (hco u).2.2.2.2 g e hcl
    have hne : e ∉ lab (u - 1) := hno (u - 1) (by omega) (by omega)
    rcases hclause.mp hcarry with h | ⟨hg, hc⟩
    · exact absurd h hne
    · refine ⟨hc, fun r h1 h2 => ?_⟩
      rcases (by omega : u ≤ r ∨ r = u - 1) with hr | rfl
      · exact hguard r hr h2
      · exact hg

/-! ## Iterated periodicity -/

/-- Iterated rightward periodicity: the shift by any multiple of `nf` fixes labels at or past
`nm`. -/
theorem lab_add_mul_nfC {lab : ℤ → Finset Formula} {nm nf : ℤ} (hnf : 0 < nf)
    (hperf : ∀ t : ℤ, nm ≤ t → lab (t + nf) = lab t) :
    ∀ (j : ℕ) (u : ℤ), nm ≤ u → lab (u + (j : ℤ) * nf) = lab u := by
  intro j
  induction j with
  | zero => intro u _; simp
  | succ j ih =>
    intro u hu
    have hjnf : (0 : ℤ) ≤ (j : ℤ) * nf :=
      mul_nonneg (Int.natCast_nonneg j) (le_of_lt hnf)
    have hcast : ((j + 1 : ℕ) : ℤ) = (j : ℤ) + 1 := by omega
    have hexp : ((j : ℤ) + 1) * nf = (j : ℤ) * nf + nf := by rw [add_mul, one_mul]
    rw [hcast, hexp, ← add_assoc, hperf (u + (j : ℤ) * nf) (by omega)]
    exact ih u hu

/-- Iterated leftward periodicity: the shift by any multiple of `nb` fixes labels strictly left
of the origin. -/
theorem lab_sub_mul_nbC {lab : ℤ → Finset Formula} {nb : ℤ} (hnb : 0 < nb)
    (hperb : ∀ t : ℤ, t < 0 → lab (t - nb) = lab t) :
    ∀ (j : ℕ) (u : ℤ), u < 0 → lab (u - (j : ℤ) * nb) = lab u := by
  intro j
  induction j with
  | zero => intro u _; simp
  | succ j ih =>
    intro u hu
    have hjnb : (0 : ℤ) ≤ (j : ℤ) * nb :=
      mul_nonneg (Int.natCast_nonneg j) (le_of_lt hnb)
    have hcast : ((j + 1 : ℕ) : ℤ) = (j : ℤ) + 1 := by omega
    have hexp : ((j : ℤ) + 1) * nb = (j : ℤ) * nb + nb := by rw [add_mul, one_mul]
    rw [hcast, hexp, ← sub_sub, hperb (u - (j : ℤ) * nb) (by omega)]
    exact ih u hu

/-! ## From good cycles to fulfilment -/

/--
**Two good cycles and periodicity give fulfilment.**

The hypotheses are exactly what the assembly produces: a locally coherent label sequence whose
labels are closure subsets, periodic with period `nb` strictly left of the origin and with period
`nf` at or past `nm`, whose forward cycle discharges every `untl` carried at `nm` somewhere in
`(nm, nm + nf]`, and whose backward cycle discharges every `snce` carried at `-1` somewhere in
`[-1 - nb, -1)`.

The argument, in the `untl` direction (the `snce` direction is its mirror), has two steps and
both are needed:

1. **Some delivery exists.** Suppose none did. Then `untl_propagates_to_endC` carries the
   obligation arbitrarily far right; in particular to `nm + A` for a shift `A` that is a multiple
   of `nf` large enough to reach past `t`. Periodicity identifies that label with `lab nm`, where
   the good cycle supplies a delivery at some `s₀ ∈ (nm, nm + nf]`; shifting that delivery back
   by the same `A` lands it strictly right of `t` — contradiction. **This is where the cycle's
   goodness is spent**, and it is the only place it is needed.
2. **The interval guard is free.** Take `s` to be the *least* delivery strictly right of `t`
   (`Int.exists_least_of_bdd`; the set is bounded below by `t` and nonempty by step 1). Then no
   delivery occurs in `(t, s)`, so `untl_propagates_to_endC` run to `s - 1` returns exactly the
   guard `FulfillingSeqLab` demands.

`BiLasso/GoodCycle.lean`'s `fulfilling_of_good_cycles` takes a `LocalCoherentSeq P φ bx lab st`
and uses the state sequence `st` **nowhere** — only the `untl`/`snce` clauses are consumed, via
the two propagation lemmas. That is exactly why the transcription to `LocalCoherentSeqLab` is
faithful rather than a weakening: the deleted hypothesis was dead in the original.
-/
theorem fulfillingSeqLab_of_good_cycles {Γ Del : Context} {bx : Formula → Bool}
    {lab : ℤ → Finset Formula}
    (hco : LocalCoherentSeqLab Γ Del bx lab)
    (hsub : ∀ t : ℤ, lab t ⊆ closureOf (Γ ++ Del))
    {nb nf nm : ℤ} (hnb : 0 < nb) (hnf : 0 < nf)
    (hperb : ∀ t : ℤ, t < 0 → lab (t - nb) = lab t)
    (hperf : ∀ t : ℤ, nm ≤ t → lab (t + nf) = lab t)
    (hgoodf : ∀ g e : Formula, Formula.untl g e ∈ lab nm →
      ∃ s : ℤ, nm < s ∧ s ≤ nm + nf ∧ e ∈ lab s)
    (hgoodb : ∀ g e : Formula, Formula.snce g e ∈ lab (-1) →
      ∃ s : ℤ, -1 - nb ≤ s ∧ s < -1 ∧ e ∈ lab s) :
    FulfillingSeqLab lab := by
  have hfw := lab_add_mul_nfC (lab := lab) (nm := nm) hnf hperf
  have hbw := lab_sub_mul_nbC (lab := lab) (nb := nb) hnb hperb
  constructor
  · -- the `untl` half
    intro t g e hmem
    have hcl : Formula.untl g e ∈ closureOf (Γ ++ Del) := hsub t hmem
    have hex : ∃ s : ℤ, t < s ∧ e ∈ lab s := by
      by_contra hcon
      have hno : ∀ s : ℤ, t < s → e ∉ lab s := fun s h1 h2 => hcon ⟨s, h1, h2⟩
      obtain ⟨A, hAnn, hAt, hAper⟩ :
          ∃ A : ℤ, 0 ≤ A ∧ t ≤ nm + A ∧ ∀ u : ℤ, nm ≤ u → lab (u + A) = lab u := by
        refine ⟨(((t - nm).toNat : ℕ) : ℤ) * nf, ?_, ?_, fun u hu => hfw _ u hu⟩
        · exact mul_nonneg (Int.natCast_nonneg _) (le_of_lt hnf)
        · have h1 : (((t - nm).toNat : ℕ) : ℤ) ≤ (((t - nm).toNat : ℕ) : ℤ) * nf :=
            le_mul_of_one_le_right (Int.natCast_nonneg _) (by omega)
          omega
      obtain ⟨hcarry, -⟩ :=
        untl_propagates_to_endC hco hcl hmem (nm + A) hAt (fun s h1 _ => hno s h1)
      rw [hAper nm (le_refl nm)] at hcarry
      obtain ⟨s₀, hs₀1, hs₀2, hs₀3⟩ := hgoodf g e hcarry
      refine hno (s₀ + A) (by omega) ?_
      rw [hAper s₀ (by omega)]
      exact hs₀3
    obtain ⟨s, ⟨hts, hes⟩, hmin⟩ :=
      Int.exists_least_of_bdd (P := fun z => t < z ∧ e ∈ lab z)
        ⟨t, fun z hz => le_of_lt hz.1⟩ (by obtain ⟨s, h1, h2⟩ := hex; exact ⟨s, h1, h2⟩)
    refine ⟨s, hts, hes, fun r hr1 hr2 => ?_⟩
    obtain ⟨-, hguard⟩ :=
      untl_propagates_to_endC hco hcl hmem (s - 1) (by omega)
        (fun z h1 h2 hz => by have := hmin z ⟨h1, hz⟩; omega)
    exact hguard r hr1 (by omega)
  · -- the `snce` half
    intro t g e hmem
    have hcl : Formula.snce g e ∈ closureOf (Γ ++ Del) := hsub t hmem
    have hex : ∃ s : ℤ, s < t ∧ e ∈ lab s := by
      by_contra hcon
      have hno : ∀ s : ℤ, s < t → e ∉ lab s := fun s h1 h2 => hcon ⟨s, h1, h2⟩
      obtain ⟨A, hAnn, hAt, hAper⟩ :
          ∃ A : ℤ, 0 ≤ A ∧ -1 - A ≤ t ∧ ∀ u : ℤ, u < 0 → lab (u - A) = lab u := by
        refine ⟨(((-1 - t).toNat : ℕ) : ℤ) * nb, ?_, ?_, fun u hu => hbw _ u hu⟩
        · exact mul_nonneg (Int.natCast_nonneg _) (le_of_lt hnb)
        · have h1 : (((-1 - t).toNat : ℕ) : ℤ) ≤ (((-1 - t).toNat : ℕ) : ℤ) * nb :=
            le_mul_of_one_le_right (Int.natCast_nonneg _) (by omega)
          omega
      obtain ⟨hcarry, -⟩ :=
        snce_propagates_to_startC hco hcl hmem (-1 - A) hAt (fun s _ h2 => hno s h2)
      rw [hAper (-1) (by omega)] at hcarry
      obtain ⟨s₀, hs₀1, hs₀2, hs₀3⟩ := hgoodb g e hcarry
      refine hno (s₀ - A) (by omega) ?_
      rw [hAper s₀ (by omega)]
      exact hs₀3
    obtain ⟨s, ⟨hst, hes⟩, hmax⟩ :=
      Int.exists_greatest_of_bdd (P := fun z => z < t ∧ e ∈ lab z)
        ⟨t, fun z hz => le_of_lt hz.1⟩ (by obtain ⟨s, h1, h2⟩ := hex; exact ⟨s, h1, h2⟩)
    refine ⟨s, hst, hes, fun r hr1 hr2 => ?_⟩
    obtain ⟨-, hguard⟩ :=
      snce_propagates_to_startC hco hcl hmem (s + 1) (by omega)
        (fun z h1 h2 hz => by have := hmax z ⟨h2, hz⟩; omega)
    exact hguard r (by omega) hr2

end FormalSystem.Metalogic.Decidability
