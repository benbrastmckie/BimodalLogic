/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Live

/-!
# The Window-Width Fixture: Identical Slices, Different Liveness

A concrete `PlusSlicedCertificate` whose slice sequence is **constant on the negatives** — back
period `1`, so every negative time carries literally the same `PlusSlice` — and in which one and the
same position is occupied by a fulfilling run at time `-1` and by **no** run at all at any time
`≤ -2`.

That is the fact the checker's window width has to respect, and it is the reason the window cannot
be the single-period window `[-nb, nm + nf)` that `Basic.lean`'s `exists_window_eq` supplies.

## What this fixture decides, and for which phase

The liveness computation is performed on a rolled *timed* carrier with wrapping time successors, so
a window time stands in for infinitely many real times. The wrap is sound only if liveness really is
constant across the times a window time represents. This module settles the width:

* `succP_ne_empty_neg_one` and `succP_eq_empty_of_le_neg_two` — the one-step position graph out of
  `p₀` is non-empty at `-1` and empty at every `t ≤ -2`, although `posAt (-1) = posAt t` and
  `slice (-1) = slice t` for all those `t`. So a window whose lower endpoint is `-nb = -1` folds
  `-2` onto `-1` and reads the **wrong** one-step graph. `winLo = -nb` is therefore **unsound**, and
  this is a proved fact about a named certificate rather than an expectation.
* `not_exists_labRun_of_le_neg_two` — every time `t ≤ -2` agrees: `p₀` is occupied by no run at any
  of them. So `-2 = -2 * nb` *is* a faithful representative of the whole left tail here, which is
  what makes the doubled endpoint `winLo = -2 * nb` the right width rather than merely a wider one.

The doubling is therefore **confirmed, not assumed** — which is exactly what the plan's Phase 16
amendment asks this fixture to do before sub-phase 15.3 fixes `winLo` / `winHi`.

## Why the mechanism is temporal, not spatial

The asymmetry is the distance to the non-periodic window. The event atom `q` is labelled **only** at
the mid slice, time `0`. An `untl gd ev` carried at `-1` is discharged one step later, at `0`, with
no intervening time at which the guard would have to hold. The same label carried at `-2` would need
the guard `gd` — or the event — at `-1`; the back slice labels neither atom at any state, so the
one-step unfolding clause of `PlusLocalCoherentSeqLab` is violated outright. Nothing about the
*graph* differs between `-1` and `-2`; only the distance to time `0` does.

This is the phenomenon the plan's Phase 16 amendment names: "an eventuality may only be
dischargeable by reaching the non-periodic window and the distance to it differs between
same-residue times".

## DEVIATION: this is not the plan's `Fixture.fourState`, and the redesign is deliberate

The plan asks for a four-state fixture — back slice `{a, b}` with `a → a`, `a → b`, `b → b` and the
atom `q` true at `b` only, `mid = [c]` with `a → c`, `b → c`, forward tail `{d}` — whose
discriminating formula is `⊡(XX ¬q)`, evaluated at `(-1, a)` and `(-2, a)`. That design is **not
realizable in this carrier**, for three independent reasons, each found by attempting it:

1. **Slice width is uniform and the edge relation is per slice.** Every slice is a relation on the
   same `Fin n`, so the plan's `a → c` / `b → c` edges, being the step *out of* a negative time,
   must live in the back slice's single `edge` — and therefore also hold at `-2`, `-3`, … . The
   intended asymmetry does not survive: `a → c` is an edge at every negative time.
2. **`q` true at `b` only in the back slice destroys the asymmetry the fixture is for.** A run
   sitting at `a` at `-2` could then step to `b` at `-1` and discharge the eventuality there, so the
   position would be live at `-2` as well.
3. **`XX` is not in L⁺ and `⊡`-truth is not `Decidable`.** `PlusFormula` has no `next`; and the
   `⊡`-clause is a universal over histories of an infinite carrier, so neither `#eval` nor `#guard`
   can reach it. The plan's own stronger requirement — named lemmas rather than an evaluation — is
   what is satisfied here.

The redesign keeps the *obligation* and drops the *shape*: what Phase 16 and sub-phase 15.3 need is
a proved instance of "identical slices, different liveness", and that is
`live_not_determined_by_slice` below. The theorem was not weakened; the fixture was rebuilt. Two
states are kept (rather than collapsing to one) so that the failure at `-2` is visibly not a lack of
successors: the edge relation is **total** at every slice, so every state has successors at every
time, and `succP (-2) p₀` is empty for a purely label-theoretic reason.

## Main definitions

- `Fixture.gd` / `ev` / `phi` / `ctx` / `Cl` — the guard atom, the event atom, `gd U ev`, the
  one-formula context, and its closure `{phi, ev, gd}`
- `Fixture.sliceBack` / `sliceMid` / `sliceFwd` / `cert` — the certificate, back period `1`
- `Fixture.p₀` — the position `(0, {phi})`, a position of **every** negative slice
- `Fixture.run` — the fulfilling run occupying `p₀` at `-1`

## Main results

- `Fixture.biSerial` — the fixture is a bona fide bi-serial certificate
- `Fixture.posAt_eq_of_neg` — every negative time has the same position set
- `Fixture.succP_ne_empty_neg_one` / `succP_eq_empty_of_le_neg_two` — the one-step asymmetry
- `Fixture.live_neg_one` / `not_live_of_le_neg_two` — the liveness asymmetry
- `Fixture.live_not_determined_by_slice` — the headline: same slice, different liveness
- `Fixture.not_exists_labRun_of_le_neg_two` — `-2` faithfully represents the whole left tail

## Tags

plus-language · certificate · time-sliced · fixture · window-width
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

namespace Fixture

/-! ## The formulas

One `untl` and its two atoms. The closure is `{phi, ev, gd}` — no `⊥`, no implication, no `□`, no
`snce` and no `⊡` — so every coherence clause except the `untl` one is vacuous, and the fixture's
content is not hidden behind incidental clause bookkeeping.
-/

/-- The guard atom of the fixture's eventuality. -/
def gd : PlusFormula := .atom (Syntax.Atom.mkBase "p")

/-- The event atom of the fixture's eventuality: labelled **only** at the mid slice. -/
def ev : PlusFormula := .atom (Syntax.Atom.mkBase "q")

/-- The fixture's eventuality, `gd U ev`. -/
def phi : PlusFormula := .untl gd ev

/-- The fixture's context: the eventuality alone. -/
def ctx : PlusContext := [phi]

/-- The fixture's closure, in the exact form the certificate's type demands. -/
abbrev Cl : Finset PlusFormula := plusClosureOf (ctx ++ ([] : PlusContext))

theorem phi_ne_ev : phi ≠ ev := by decide

theorem phi_ne_gd : phi ≠ gd := by decide

theorem ev_ne_gd : ev ≠ gd := by decide

theorem bot_ne_phi : PlusFormula.bot ≠ phi := by decide

theorem bot_ne_ev : PlusFormula.bot ≠ ev := by decide

/-- **The closure is exactly the three formulas.** -/
theorem mem_Cl_iff (ψ : PlusFormula) : ψ ∈ Cl ↔ (ψ = phi ∨ ψ = ev ∨ ψ = gd) := by
  have h1 : Cl = plusSubformulaClosure phi := by
    simp [Cl, ctx, plusClosureOf]
  have h2 : PlusFormula.subformulas phi = [phi, ev, gd] := rfl
  rw [h1, plusSubformulaClosure, h2]
  simp

theorem mem_Cl_phi : phi ∈ Cl := (mem_Cl_iff _).mpr (Or.inl rfl)

theorem mem_Cl_ev : ev ∈ Cl := (mem_Cl_iff _).mpr (Or.inr (Or.inl rfl))

theorem mem_Cl_gd : gd ∈ Cl := (mem_Cl_iff _).mpr (Or.inr (Or.inr rfl))

/-- The only `untl` in the closure is `phi`. -/
theorem Cl_untl_eq {g e : PlusFormula} (h : PlusFormula.untl g e ∈ Cl) : g = gd ∧ e = ev := by
  rcases (mem_Cl_iff _).mp h with h | h | h
  · rw [phi] at h; injection h with h1 h2; exact ⟨h1, h2⟩
  · exact absurd h (by simp [ev])
  · exact absurd h (by simp [gd])

/-- No implication is in the closure, so the implication clause is vacuous throughout. -/
theorem Cl_no_imp (a b : PlusFormula) : PlusFormula.imp a b ∉ Cl := by
  intro h
  rcases (mem_Cl_iff _).mp h with h | h | h
  · exact absurd h (by simp [phi])
  · exact absurd h (by simp [ev])
  · exact absurd h (by simp [gd])

/-- No `□`-formula is in the closure, so the box clause is vacuous throughout. -/
theorem Cl_no_box (a : PlusFormula) : PlusFormula.box a ∉ Cl := by
  intro h
  rcases (mem_Cl_iff _).mp h with h | h | h
  · exact absurd h (by simp [phi])
  · exact absurd h (by simp [ev])
  · exact absurd h (by simp [gd])

/-- No `snce` is in the closure, so the `snce` clause is vacuous throughout. -/
theorem Cl_no_snce (g e : PlusFormula) : PlusFormula.snce g e ∉ Cl := by
  intro h
  rcases (mem_Cl_iff _).mp h with h | h | h
  · exact absurd h (by simp [phi])
  · exact absurd h (by simp [ev])
  · exact absurd h (by simp [gd])

/-- No `⊡`-formula is in the closure. -/
theorem Cl_no_stab (a : PlusFormula) : PlusFormula.stab a ∉ Cl := by
  intro h
  rcases (mem_Cl_iff _).mp h with h | h | h
  · exact absurd h (by simp [phi])
  · exact absurd h (by simp [ev])
  · exact absurd h (by simp [gd])

theorem singleton_phi_sub : ({phi} : Finset PlusFormula) ⊆ Cl := by
  intro x hx
  rw [Finset.mem_singleton] at hx
  subst hx
  exact mem_Cl_phi

theorem singleton_ev_sub : ({ev} : Finset PlusFormula) ⊆ Cl := by
  intro x hx
  rw [Finset.mem_singleton] at hx
  subst hx
  exact mem_Cl_ev

/-! ## The three slices

The edge relation is **total** at every slice — every state has successors and predecessors at every
time — so nothing below turns on a missing edge. The only difference between the slices is the
labelling, and the only labelled atom anywhere is `ev`, at the mid slice.
-/

/-- The back slice: total edge relation, no atom labelled at either state. Repeated at every
negative time, since the back period is `1`. -/
def sliceBack : PlusSlice 2 Cl where
  edge := fun _ _ => true
  lab := fun _ => ∅
  lab_sub := fun _ => Finset.empty_subset _

/-- The mid slice, at time `0`: the **only** slice labelling the event atom. -/
def sliceMid : PlusSlice 2 Cl where
  edge := fun _ _ => true
  lab := fun _ => {ev}
  lab_sub := fun _ => singleton_ev_sub

/-- The forward slice: like the back slice, repeated at every time `≥ 1`. -/
def sliceFwd : PlusSlice 2 Cl where
  edge := fun _ _ => true
  lab := fun _ => ∅
  lab_sub := fun _ => Finset.empty_subset _

/-- A target path, present only because `PlusSlicedCertificate` carries one. Nothing below reads
it. -/
def tgt : PlusGraphPath 2 Cl where
  back := [(∅, 0)]
  mid := []
  fwd := [(∅, 0)]
  back_ne := List.cons_ne_nil _ _
  fwd_ne := List.cons_ne_nil _ _
  label_sub := by
    intro X hX
    rcases List.mem_append.mp hX with hX | hX
    · rcases List.mem_append.mp hX with hX | hX
      · rw [List.mem_singleton.mp hX]; exact Finset.empty_subset _
      · exact absurd hX (by simp)
    · rw [List.mem_singleton.mp hX]; exact Finset.empty_subset _

/-- **The fixture.** Back period `1`, window length `1`, forward period `1`. -/
def cert : PlusSlicedCertificate ctx [] where
  n := 2
  n_pos := by norm_num
  back := [sliceBack]
  mid := [sliceMid]
  fwd := [sliceFwd]
  back_ne := List.cons_ne_nil _ _
  fwd_ne := List.cons_ne_nil _ _
  bx := fun _ => false
  target := tgt
  targetTime := 0

@[simp] theorem cert_nb : cert.nb = 1 := by simp [cert]

@[simp] theorem cert_nm : cert.nm = 1 := by simp [cert]

@[simp] theorem cert_nf : cert.nf = 1 := by simp [cert]

/-! ### The decoded slice sequence -/

private theorem cyc_singleton {α : Type*} [Inhabited α] (a : α) (i : ℤ) :
    Periodic.cyc [a] i = a := by
  simp [Periodic.cyc, Int.emod_one]

/-- **Every negative time carries the same slice.** Back period `1`. -/
theorem slice_of_neg {t : ℤ} (ht : t < 0) : cert.slice t = sliceBack := by
  rw [PlusSlicedCertificate.slice_neg cert ht]
  exact cyc_singleton _ _

theorem slice_zero : cert.slice 0 = sliceMid := by
  rw [PlusSlicedCertificate.slice_mid cert le_rfl (by simp)]
  rfl

theorem slice_of_one_le {t : ℤ} (ht : 1 ≤ t) : cert.slice t = sliceFwd := by
  rw [PlusSlicedCertificate.slice_fwd cert (by simp; omega)]
  exact cyc_singleton _ _

/-- **The slice at `-1` is the slice at every earlier time.** The hypothesis of the whole
window-width question. -/
theorem slice_neg_one_eq {t : ℤ} (ht : t < 0) : cert.slice (-1) = cert.slice t := by
  rw [slice_of_neg (by omega), slice_of_neg ht]

/-! ### The slice labelling: `ev` at time `0` only, `gd` nowhere -/

theorem slab_mem_ev_iff (t : ℤ) (w : Fin cert.n) : ev ∈ cert.slab t w ↔ t = 0 := by
  rcases lt_trichotomy t 0 with ht | ht | ht
  · rw [slab, slice_of_neg ht]
    simp [sliceBack, ht.ne]
  · subst ht
    rw [slab, slice_zero]
    simp [sliceMid]
  · rw [slab, slice_of_one_le (by omega)]
    simp [sliceFwd]
    omega

theorem slab_not_mem_gd (t : ℤ) (w : Fin cert.n) : gd ∉ cert.slab t w := by
  rcases lt_trichotomy t 0 with ht | ht | ht
  · rw [slab, slice_of_neg ht]; simp [sliceBack]
  · subst ht; rw [slab, slice_zero]; simp [sliceMid, ev_ne_gd.symm]
  · rw [slab, slice_of_one_le (by omega)]; simp [sliceFwd]

/-! ### Bi-seriality

The edge relation is total at every slice, so the fixture is a bona fide certificate rather than a
degenerate one: the failure at `-2` recorded below is never for want of an edge.
-/

theorem edge_eq_true (t : ℤ) (w u : Fin cert.n) : cert.edge t w u = true := by
  rcases lt_trichotomy t 0 with ht | ht | ht
  · rw [edge, slice_of_neg ht]; rfl
  · subst ht; rw [edge, slice_zero]; rfl
  · rw [edge, slice_of_one_le (by omega)]; rfl

/-- **The fixture is bi-serial.** -/
theorem biSerial : cert.BiSerial := by
  intro t
  exact ⟨fun w => ⟨w, edge_eq_true t w w⟩, fun u => ⟨u, edge_eq_true t u u⟩⟩

/-! ## The position, and why it belongs to every negative slice -/

/-- **The position the fixture is about**: state `0`, carrying the pending eventuality. -/
def p₀ : cert.Pos := (⟨0, cert.n_pos⟩, ⟨{phi}, Finset.mem_powerset.mpr singleton_phi_sub⟩)

@[simp] theorem p₀_snd : p₀.2.1 = ({phi} : Finset PlusFormula) := rfl

/-- **`p₀` is a position of every negative slice.** It is `LabCoherent` — the closure has no `⊥` and
no implication — and it agrees with the back slice's labelling, which labels no atom at all. -/
theorem mem_posAt_p₀ {t : ℤ} (ht : t < 0) : p₀ ∈ cert.posAt t := by
  rw [mem_posAt]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · intro h
    rw [p₀_snd, Finset.mem_singleton] at h
    exact bot_ne_phi h
  · intro ψ hψ
    match ψ with
    | .atom _ => rfl
    | .bot => rfl
    | .imp a b => exact absurd hψ (Cl_no_imp a b)
    | .box _ => rfl
    | .untl _ _ => rfl
    | .snce _ _ => rfl
    | .stab _ => rfl
  · intro ψ hψ _
    rcases (mem_Cl_iff ψ).mp hψ with h | h | h
    · subst h; simp [IsStateShape, phi] at *
    · subst h
      rw [p₀_snd]
      simp only [Finset.mem_singleton]
      rw [slab_mem_ev_iff]
      constructor
      · intro h; exact absurd h phi_ne_ev.symm
      · intro h; omega
    · subst h
      rw [p₀_snd]
      simp only [Finset.mem_singleton]
      constructor
      · intro h; exact absurd h phi_ne_gd.symm
      · intro h; exact absurd h (slab_not_mem_gd _ _)

/-- **Every negative time has the same slice labelling.** -/
theorem slab_eq_of_neg {t s : ℤ} (ht : t < 0) (hs : s < 0) (w : Fin cert.n) :
    cert.slab t w = cert.slab s w := by
  rw [slab, slab, slice_of_neg ht, slice_of_neg hs]

/-- **Every negative time has the same position set.** Immediate from `slice_of_neg`, and the reason
the one-step asymmetry below cannot be explained away as a difference of position spaces. -/
theorem posAt_eq_of_neg {t s : ℤ} (ht : t < 0) (hs : s < 0) : cert.posAt t = cert.posAt s := by
  ext p
  rw [mem_posAt, mem_posAt]
  constructor
  · intro h
    refine ⟨h.1, fun ψ hψ hst => ?_⟩
    rw [← slab_eq_of_neg ht hs p.1]
    exact h.2 ψ hψ hst
  · intro h
    refine ⟨h.1, fun ψ hψ hst => ?_⟩
    rw [slab_eq_of_neg ht hs p.1]
    exact h.2 ψ hψ hst

/-! ## The one-step asymmetry

`succP t` is **not** a function of `slice t`: it reads `posAt (t + 1)` as well, and at `t = -1` that
is the mid slice. These two lemmas are the fixture's decisive content, and both are about the
one-step graph alone — no fixpoint, no run.
-/

/-- **No successor at any time `≤ -2`.** Every candidate successor lies at a negative time, where no
atom is labelled, so the `untl` clause of `StepClause` cannot be met. -/
theorem succP_eq_empty_of_le_neg_two {t : ℤ} (ht : t ≤ -2) : cert.succP t p₀ = ∅ := by
  rw [Finset.eq_empty_iff_forall_notMem]
  intro q hq
  rw [mem_succP] at hq
  obtain ⟨hmem, -, hstep⟩ := hq
  have hcl := hstep.1 phi mem_Cl_phi
  simp only [phi, untlClauseAt, decide_eq_true_eq] at hcl
  have hin : PlusFormula.untl gd ev ∈ p₀.2.1 := by
    rw [p₀_snd, Finset.mem_singleton]; rfl
  have hagree := (mem_posAt _ _ _).mp hmem |>.2
  have hev : ev ∉ q.2.1 := by
    intro h
    have := (hagree ev mem_Cl_ev rfl).mp h
    rw [slab_mem_ev_iff] at this
    omega
  have hgd : gd ∉ q.2.1 := by
    intro h
    exact slab_not_mem_gd _ _ ((hagree gd mem_Cl_gd rfl).mp h)
  rcases hcl.mp hin with h | ⟨h, -⟩
  · exact hev h
  · exact hgd h

/-- **A successor at `-1`.** The mid slice labels the event atom, so the run below supplies one. -/
theorem succP_ne_empty_neg_one : cert.succP (-1) p₀ ≠ ∅ := by
  intro h
  have : ((0 : Fin cert.n), (⟨{ev}, Finset.mem_powerset.mpr singleton_ev_sub⟩ :
      Lab ctx [])) ∈ cert.succP (-1) p₀ := by
    rw [mem_succP]
    refine ⟨?_, edge_eq_true _ _ _, ?_, ?_⟩
    · rw [mem_posAt]
      refine ⟨⟨?_, ?_⟩, ?_⟩
      · intro hb
        simp only [Finset.mem_singleton] at hb
        exact bot_ne_ev hb
      · intro ψ hψ
        match ψ with
        | .atom _ => rfl
        | .bot => rfl
        | .imp a b => exact absurd hψ (Cl_no_imp a b)
        | .box _ => rfl
        | .untl _ _ => rfl
        | .snce _ _ => rfl
        | .stab _ => rfl
      · intro ψ hψ _
        rcases (mem_Cl_iff ψ).mp hψ with hh | hh | hh
        · subst hh; simp [IsStateShape, phi] at *
        · subst hh
          simp only [Finset.mem_singleton]
          constructor
          · intro _
            rw [show (-1 : ℤ) + 1 = 0 from by omega, slab_mem_ev_iff]
          · intro _
            trivial
        · subst hh
          simp only [Finset.mem_singleton]
          constructor
          · intro hh2; exact absurd hh2 ev_ne_gd.symm
          · intro hh2; exact absurd hh2 (slab_not_mem_gd _ _)
    · intro ψ hψ
      match ψ with
      | .atom _ => rfl
      | .bot => rfl
      | .imp _ _ => rfl
      | .box _ => rfl
      | .untl g e =>
          obtain ⟨hg, he⟩ := Cl_untl_eq hψ
          subst hg; subst he
          simp only [untlClauseAt, decide_eq_true_eq]
          constructor
          · intro _; left; simp
          · intro _; rw [p₀_snd, Finset.mem_singleton]; rfl
      | .snce g e => exact absurd hψ (Cl_no_snce g e)
      | .stab a => exact absurd hψ (Cl_no_stab a)
    · intro ψ hψ
      match ψ with
      | .atom _ => rfl
      | .bot => rfl
      | .imp _ _ => rfl
      | .box _ => rfl
      | .untl _ _ => rfl
      | .snce g e => exact absurd hψ (Cl_no_snce g e)
      | .stab a => exact absurd hψ (Cl_no_stab a)
  rw [h] at this
  exact absurd this (Finset.notMem_empty _)

/-! ## The fulfilling run through `p₀` at `-1` -/

/-- The run's labelling: the eventuality at `-1`, the event at `0`, nothing anywhere else. -/
def runLab : ℤ → Finset PlusFormula :=
  fun t => if t = -1 then {phi} else if t = 0 then {ev} else ∅

/-- The run's state function: the fixture's asymmetry is temporal, so the state never changes. -/
def runSt : ℤ → Fin cert.n := fun _ => ⟨0, cert.n_pos⟩

theorem runLab_mem_phi_iff (t : ℤ) : phi ∈ runLab t ↔ t = -1 := by
  unfold runLab
  split_ifs with h1 h2
  · simp [h1]
  · simp [phi_ne_ev, h1]
  · simp [h1]

theorem runLab_mem_ev_iff (t : ℤ) : ev ∈ runLab t ↔ t = 0 := by
  unfold runLab
  split_ifs with h1 h2
  · simp only [Finset.mem_singleton]
    constructor
    · intro h; exact absurd h phi_ne_ev.symm
    · intro h; omega
  · simp [h2]
  · simp [h2]

theorem runLab_not_mem_gd (t : ℤ) : gd ∉ runLab t := by
  unfold runLab
  split_ifs with h1 h2
  · simp only [Finset.mem_singleton]; exact fun h => phi_ne_gd h.symm
  · simp only [Finset.mem_singleton]; exact fun h => ev_ne_gd h.symm
  · simp

theorem runLab_sub (t : ℤ) : runLab t ⊆ Cl := by
  unfold runLab
  split_ifs
  · exact singleton_phi_sub
  · exact singleton_ev_sub
  · exact Finset.empty_subset _

theorem runLab_not_mem_bot (t : ℤ) : PlusFormula.bot ∉ runLab t := by
  unfold runLab
  split_ifs
  · simp only [Finset.mem_singleton]; exact bot_ne_phi
  · simp only [Finset.mem_singleton]; exact bot_ne_ev
  · simp

/-- **The run.** Its labelling agrees with the slice labelling on both atoms at every time, and its
only coherence obligation — the `untl` clause at `phi` — holds because `-1` is exactly one step
before the mid slice. -/
def run : cert.LabRun where
  st := runSt
  lab := runLab
  lab_sub := runLab_sub
  agrees := by
    intro s ψ hψ _
    rcases (mem_Cl_iff ψ).mp hψ with h | h | h
    · subst h; simp [IsStateShape, phi] at *
    · subst h
      rw [runLab_mem_ev_iff, slab_mem_ev_iff]
    · subst h
      constructor
      · intro h; exact absurd h (runLab_not_mem_gd s)
      · intro h; exact absurd h (slab_not_mem_gd _ _)
  steps := fun s => edge_eq_true s _ _
  coherent := by
    intro t
    refine ⟨runLab_not_mem_bot t, ?_, ?_, ?_, ?_⟩
    · intro a b hab; exact absurd hab (Cl_no_imp a b)
    · intro χ hχ; exact absurd hχ (Cl_no_box χ)
    · intro g e hge
      obtain ⟨hg, he⟩ := Cl_untl_eq hge
      subst hg; subst he
      rw [show PlusFormula.untl gd ev = phi from rfl, runLab_mem_phi_iff, runLab_mem_ev_iff,
        runLab_mem_phi_iff]
      constructor
      · intro h; left; omega
      · rintro (h | ⟨h, -⟩)
        · omega
        · exact absurd h (runLab_not_mem_gd _)
    · intro g e hge; exact absurd hge (Cl_no_snce g e)

@[simp] theorem run_lab : run.lab = runLab := rfl

@[simp] theorem run_st : run.st = runSt := rfl

/-- **The run is fulfilling**, in both directions: the only pending eventuality is `phi` at `-1`,
discharged at `0` with no intervening time; no `snce` is ever carried. -/
theorem run_fulfilling : PlusFulfillingSeqLab run.lab := by
  constructor
  · intro t g e hu
    have ht : t = -1 ∧ PlusFormula.untl g e = phi := by
      rw [run_lab] at hu
      unfold runLab at hu
      split_ifs at hu with h1 h2
      · rw [Finset.mem_singleton] at hu; exact ⟨h1, hu⟩
      · rw [Finset.mem_singleton] at hu; exact absurd hu (by simp [ev])
      · exact absurd hu (Finset.notMem_empty _)
    obtain ⟨ht1, ht2⟩ := ht
    rw [phi] at ht2
    injection ht2 with hg he
    subst hg; subst he; subst ht1
    refine ⟨0, by omega, ?_, fun r hr1 hr2 => absurd hr1 (by omega)⟩
    rw [run_lab, runLab_mem_ev_iff]
  · intro t g e hs
    rw [run_lab] at hs
    unfold runLab at hs
    split_ifs at hs with h1 h2
    · rw [Finset.mem_singleton] at hs; exact absurd hs (by simp [phi])
    · rw [Finset.mem_singleton] at hs; exact absurd hs (by simp [ev])
    · exact absurd hs (Finset.notMem_empty _)

/-- The run occupies `p₀` at `-1`. -/
theorem run_pos_neg_one : run.pos (-1) = p₀ := by
  refine Prod.ext rfl (Subtype.ext ?_)
  have h : runLab (-1) = ({phi} : Finset PlusFormula) := by
    unfold runLab
    rw [if_pos rfl]
  exact h

/-! ## The liveness asymmetry -/

/-- **`p₀` is live at `-1`.** -/
theorem live_neg_one : cert.Live (-1) p₀ := by
  rw [← run_pos_neg_one]
  exact cert.live_of_path run run_fulfilling (-1)

/--
**No run of the fixture occupies `p₀` at any time `≤ -2`.**

Stronger than non-liveness, and proved from the one-step unfolding clause alone: a label carrying
`phi` at `t` forces the event or the guard at `t + 1`, and `t + 1` is still negative, where the back
slice labels no atom. This is also what makes `-2` a **faithful** representative of the entire left
tail, which is the half of the window question the doubling answers.
-/
theorem not_exists_labRun_of_le_neg_two {t : ℤ} (ht : t ≤ -2) :
    ¬ ∃ R : cert.LabRun, R.pos t = p₀ := by
  rintro ⟨R, hR⟩
  have hlab : R.lab t = ({phi} : Finset PlusFormula) := by
    have h : (R.pos t).2.1 = p₀.2.1 := congrArg (fun q => q.2.1) hR
    rw [LabRun.pos_snd, p₀_snd] at h
    exact h
  have hin : phi ∈ R.lab t := by rw [hlab]; exact Finset.mem_singleton_self _
  have hcl := ((R.coherent t).2.2.2.1 gd ev mem_Cl_phi).mp hin
  have hev : ev ∉ R.lab (t + 1) := by
    intro h
    have := (R.agrees (t + 1) ev mem_Cl_ev rfl).mp h
    rw [slab_mem_ev_iff] at this
    omega
  have hgd : gd ∉ R.lab (t + 1) := by
    intro h
    exact slab_not_mem_gd _ _ ((R.agrees (t + 1) gd mem_Cl_gd rfl).mp h)
  rcases hcl with h | ⟨h, -⟩
  · exact hev h
  · exact hgd h

/-- **`p₀` is not forward-live at any time `≤ -2`.** -/
theorem not_fwdLive_of_le_neg_two {t : ℤ} (ht : t ≤ -2) : ¬ cert.FwdLive t p₀ := by
  rintro ⟨R, -, hR⟩
  exact not_exists_labRun_of_le_neg_two ht ⟨R, hR⟩

/-- **`p₀` is not live at any time `≤ -2`.** -/
theorem not_live_of_le_neg_two {t : ℤ} (ht : t ≤ -2) : ¬ cert.Live t p₀ := fun h =>
  not_fwdLive_of_le_neg_two ht h.1

/--
**The headline: identical slices, identical position sets, different liveness.**

The three conjuncts say, in order: the slice at `-1` is literally the slice at `-2`; the position
sets agree there; and `p₀` is live at `-1` and not at `-2`. A checker that reads liveness at a
window whose lower endpoint is `-nb = -1` folds `-2` onto `-1` and therefore reads liveness at `-2`
off the wrong slice pair. The doubled endpoint `-2 * nb = -2` is what separates them, and
`not_exists_labRun_of_le_neg_two` is what shows `-2` then stands faithfully for the whole tail.
-/
theorem live_not_determined_by_slice :
    cert.slice (-1) = cert.slice (-2) ∧
      cert.posAt (-1) = cert.posAt (-2) ∧
      cert.Live (-1) p₀ ∧ ¬ cert.Live (-2) p₀ :=
  ⟨slice_neg_one_eq (by omega), posAt_eq_of_neg (by omega) (by omega), live_neg_one,
    not_live_of_le_neg_two le_rfl⟩

/--
**The single-period window is unsound, stated as a window fact.**

`cert.nb = 1`, so the single-period lower endpoint `-cert.nb` is `-1` and the doubled one is `-2`.
The time `-2` lies outside the first and inside the second, and liveness at `-2` differs from
liveness at `-1`. So no correct wrap can fold `-2` onto `-1`.
-/
theorem neg_two_outside_single_period_window :
    -cert.nb ≤ (-1 : ℤ) ∧ ¬ (-cert.nb ≤ (-2 : ℤ)) ∧ -2 * cert.nb ≤ (-2 : ℤ) ∧
      cert.Live (-1) p₀ ∧ ¬ cert.Live (-2) p₀ := by
  refine ⟨by simp, by simp, by simp, live_neg_one, not_live_of_le_neg_two le_rfl⟩

end Fixture

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
