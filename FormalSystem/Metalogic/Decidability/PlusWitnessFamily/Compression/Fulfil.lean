/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Compression.Cycle

/-!
# From Good L⁺ Cycles to Fulfilment, at a Bare Label Sequence

`Compression/Cycle.lean` produces two bounded cycles that *deliver* the eventualities of their
base type. This module converts that into full `PlusFulfillingSeqLab`: every eventuality carried
at **every** position of a bi-periodic locally coherent L⁺ label sequence is discharged, with the
interval guard `PlusFulfillingSeqLab` demands.

## The two propagation lemmas

An undischarged `untl` survives to the end of the stretch with its guard intact, and a `snce`
survives back to its start. Both are ℤ-inductions on the corresponding clause of
`PlusLocalCoherentSeqLab`, which is a biconditional and therefore usable in this direction.

The `snce` lemma is stated separately rather than derived by duality, for the same reason its
`Formula`-side counterpart is: the tree has no `PlusFormula` duality operation, and inventing one
for a single use costs more than the lines it saves.

## The stability modal is absent from this module, and that is the point

Nothing here mentions `⊡`. `PlusFulfillingSeqLab` has two clauses, `untl` and `snce`, because
those are the only eventualities; `⊡` has no delivery obligation to propagate and no cycle to
spend. Its obligation is (C5), which is same-time and cross-index and belongs to the saturation
of Phase 8, not to a bi-infinite sequence. So the fulfilment layer transcribes at exactly the
`Formula` side's size, with `Formula` replaced by `PlusFormula` and nothing added.

## Why the sequence-level route rather than the window collapse

`PlusWitnessFamily/Decide.lean`'s collapses are stated for a `PlusWitnessFamily`. The assembly
needs the fulfilment conclusion at **bare sequences**, before any family exists to state it
about, so the propagation route is the prescribed one here, not a fallback.

## Main Results

- `plusUntl_propagates_to_endC` / `plusSnce_propagates_to_startC` — the interior-eventuality
  reduction
- `plusLab_add_mul_nfC` / `plusLab_sub_mul_nbC` — the two iterated periodicities
- `plusFulfillingSeqLab_of_good_cycles` — **two good cycles plus periodicity give fulfilment**

Argument order is **guard first**: `PlusFormula.untl g e`, `PlusFormula.snce g e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage
open FormalSystem.Semantics

variable {Γ Del : PlusContext} {bx : PlusFormula → Bool}

/-! ## The interior-eventuality reduction -/

/--
**An undischarged L⁺ `untl` survives to the end of the stretch, guard intact.**

If `PlusFormula.untl g e` is carried at `t` and its event `e` appears nowhere in `(t, T]`, then
the obligation is still carried at `T` and the guard `g` holds at every position of `(t, T]`.

Two consequences, both used below:

1. **The mark count is capped before any loop is chosen.** An `untl` carried at an interior
   position of a cycle either delivers inside the cycle or is still carried at the cycle's
   endpoint, whose type is the base type.
2. **The interval guard is free.** Taking `T` to be one less than the *least* delivery position
   turns this lemma's guard conclusion into exactly the interval condition
   `PlusFulfillingSeqLab` demands.

The proof is rightward ℤ-induction on the `untl` clause of `PlusLocalCoherentSeqLab`. It reads
only that clause — no atom clause (which does not exist here), no state sequence, and no `stab`
clause (which does not exist in this predicate at all).
-/
theorem plusUntl_propagates_to_endC {lab : ℤ → Finset PlusFormula}
    (hco : PlusLocalCoherentSeqLab Γ Del bx lab) {g e : PlusFormula}
    (hcl : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) {t : ℤ}
    (hmem : PlusFormula.untl g e ∈ lab t) :
    ∀ T : ℤ, t ≤ T → (∀ s : ℤ, t < s → s ≤ T → e ∉ lab s) →
      PlusFormula.untl g e ∈ lab T ∧ ∀ r : ℤ, t < r → r ≤ T → g ∈ lab r := by
  refine Int.rightInduction (t := t) (P := fun T =>
      (∀ s : ℤ, t < s → s ≤ T → e ∉ lab s) →
        PlusFormula.untl g e ∈ lab T ∧ ∀ r : ℤ, t < r → r ≤ T → g ∈ lab r) ?_ ?_
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
**The leftward mirror**: an undischarged L⁺ `snce` survives back to the start of the stretch.

Same statement with the two temporal directions exchanged, proved by leftward ℤ-induction on the
`snce` clause.
-/
theorem plusSnce_propagates_to_startC {lab : ℤ → Finset PlusFormula}
    (hco : PlusLocalCoherentSeqLab Γ Del bx lab) {g e : PlusFormula}
    (hcl : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) {t : ℤ}
    (hmem : PlusFormula.snce g e ∈ lab t) :
    ∀ T : ℤ, T ≤ t → (∀ s : ℤ, T ≤ s → s < t → e ∉ lab s) →
      PlusFormula.snce g e ∈ lab T ∧ ∀ r : ℤ, T ≤ r → r < t → g ∈ lab r := by
  refine Int.leftInduction (t := t) (P := fun T =>
      (∀ s : ℤ, T ≤ s → s < t → e ∉ lab s) →
        PlusFormula.snce g e ∈ lab T ∧ ∀ r : ℤ, T ≤ r → r < t → g ∈ lab r) ?_ ?_
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
theorem plusLab_add_mul_nfC {lab : ℤ → Finset PlusFormula} {nm nf : ℤ} (hnf : 0 < nf)
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
theorem plusLab_sub_mul_nbC {lab : ℤ → Finset PlusFormula} {nb : ℤ} (hnb : 0 < nb)
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
**Two good L⁺ cycles and periodicity give fulfilment.**

The hypotheses are exactly what the assembly produces: a locally coherent L⁺ label sequence whose
labels are closure subsets, periodic with period `nb` strictly left of the origin and with period
`nf` at or past `nm`, whose forward cycle discharges every `untl` carried at `nm` somewhere in
`(nm, nm + nf]`, and whose backward cycle discharges every `snce` carried at `-1` somewhere in
`[-1 - nb, -1)`.

The argument, in the `untl` direction (the `snce` direction is its mirror), has two steps and
both are needed:

1. **Some delivery exists.** Suppose none did. Then `plusUntl_propagates_to_endC` carries the
   obligation arbitrarily far right; in particular to `nm + A` for a shift `A` that is a multiple
   of `nf` large enough to reach past `t`. Periodicity identifies that label with `lab nm`, where
   the good cycle supplies a delivery at some `s₀ ∈ (nm, nm + nf]`; shifting that delivery back
   by the same `A` lands it strictly right of `t` — contradiction. **This is where the cycle's
   goodness is spent**, and it is the only place it is needed.
2. **The interval guard is free.** Take `s` to be the *least* delivery strictly right of `t`
   (`Int.exists_least_of_bdd`; the set is bounded below by `t` and nonempty by step 1). Then no
   delivery occurs in `(t, s)`, so `plusUntl_propagates_to_endC` run to `s - 1` returns exactly
   the guard `PlusFulfillingSeqLab` demands.
-/
theorem plusFulfillingSeqLab_of_good_cycles {Γ Del : PlusContext} {bx : PlusFormula → Bool}
    {lab : ℤ → Finset PlusFormula}
    (hco : PlusLocalCoherentSeqLab Γ Del bx lab)
    (hsub : ∀ t : ℤ, lab t ⊆ plusClosureOf (Γ ++ Del))
    {nb nf nm : ℤ} (hnb : 0 < nb) (hnf : 0 < nf)
    (hperb : ∀ t : ℤ, t < 0 → lab (t - nb) = lab t)
    (hperf : ∀ t : ℤ, nm ≤ t → lab (t + nf) = lab t)
    (hgoodf : ∀ g e : PlusFormula, PlusFormula.untl g e ∈ lab nm →
      ∃ s : ℤ, nm < s ∧ s ≤ nm + nf ∧ e ∈ lab s)
    (hgoodb : ∀ g e : PlusFormula, PlusFormula.snce g e ∈ lab (-1) →
      ∃ s : ℤ, -1 - nb ≤ s ∧ s < -1 ∧ e ∈ lab s) :
    PlusFulfillingSeqLab lab := by
  have hfw := plusLab_add_mul_nfC (lab := lab) (nm := nm) hnf hperf
  have hbw := plusLab_sub_mul_nbC (lab := lab) (nb := nb) hnb hperb
  constructor
  · -- the `untl` half
    intro t g e hmem
    have hcl : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del) := hsub t hmem
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
        plusUntl_propagates_to_endC hco hcl hmem (nm + A) hAt (fun s h1 _ => hno s h1)
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
      plusUntl_propagates_to_endC hco hcl hmem (s - 1) (by omega)
        (fun z h1 h2 hz => by have := hmin z ⟨h1, hz⟩; omega)
    exact hguard r hr1 (by omega)
  · -- the `snce` half
    intro t g e hmem
    have hcl : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del) := hsub t hmem
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
        plusSnce_propagates_to_startC hco hcl hmem (-1 - A) hAt (fun s _ h2 => hno s h2)
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
      plusSnce_propagates_to_startC hco hcl hmem (s + 1) (by omega)
        (fun z h1 h2 hz => by have := hmax z ⟨h2, hz⟩; omega)
    exact hguard r (by omega) hr2

end FormalSystem.Metalogic.Decidability
