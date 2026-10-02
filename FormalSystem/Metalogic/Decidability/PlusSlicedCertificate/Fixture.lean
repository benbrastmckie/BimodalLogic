/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Live
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Window
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Bridge

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
- `Fixture.window_verdict` — the verdict stated against `Window.lean`'s actual `winLo`: the position
  is live at `-NB = -1` and dead at `winLo = -2 * NB = -2`, so the lower endpoint cannot be raised
  from the doubled value to the single-period one
- `Fixture.liveT_ne_empty_and_ne_verts` — the computed liveness `Finset` on this certificate is
  neither empty nor the whole vertex set, proved through the bridge in both directions rather than
  by evaluation

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
theorem Cl.untl_eq {g e : PlusFormula} (h : PlusFormula.untl g e ∈ Cl) : g = gd ∧ e = ev := by
  rcases (mem_Cl_iff _).mp h with h | h | h
  · rw [phi] at h; injection h with h1 h2; exact ⟨h1, h2⟩
  · exact absurd h (by simp [ev])
  · exact absurd h (by simp [gd])

/-- No implication is in the closure, so the implication clause is vacuous throughout. -/
theorem Cl.no_imp (a b : PlusFormula) : PlusFormula.imp a b ∉ Cl := by
  intro h
  rcases (mem_Cl_iff _).mp h with h | h | h
  · exact absurd h (by simp [phi])
  · exact absurd h (by simp [ev])
  · exact absurd h (by simp [gd])

/-- No `□`-formula is in the closure, so the box clause is vacuous throughout. -/
theorem Cl.no_box (a : PlusFormula) : PlusFormula.box a ∉ Cl := by
  intro h
  rcases (mem_Cl_iff _).mp h with h | h | h
  · exact absurd h (by simp [phi])
  · exact absurd h (by simp [ev])
  · exact absurd h (by simp [gd])

/-- No `snce` is in the closure, so the `snce` clause is vacuous throughout. -/
theorem Cl.no_snce (g e : PlusFormula) : PlusFormula.snce g e ∉ Cl := by
  intro h
  rcases (mem_Cl_iff _).mp h with h | h | h
  · exact absurd h (by simp [phi])
  · exact absurd h (by simp [ev])
  · exact absurd h (by simp [gd])

/-- No `⊡`-formula is in the closure. -/
theorem Cl.no_stab (a : PlusFormula) : PlusFormula.stab a ∉ Cl := by
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
    | .imp a b => exact absurd hψ (Cl.no_imp a b)
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
        | .imp a b => exact absurd hψ (Cl.no_imp a b)
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
          obtain ⟨hg, he⟩ := Cl.untl_eq hψ
          subst hg; subst he
          simp only [untlClauseAt, decide_eq_true_eq]
          constructor
          · intro _; left; simp
          · intro _; rw [p₀_snd, Finset.mem_singleton]; rfl
      | .snce g e => exact absurd hψ (Cl.no_snce g e)
      | .stab a => exact absurd hψ (Cl.no_stab a)
    · intro ψ hψ
      match ψ with
      | .atom _ => rfl
      | .bot => rfl
      | .imp _ _ => rfl
      | .box _ => rfl
      | .untl _ _ => rfl
      | .snce g e => exact absurd hψ (Cl.no_snce g e)
      | .stab a => exact absurd hψ (Cl.no_stab a)
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
    · intro a b hab; exact absurd hab (Cl.no_imp a b)
    · intro χ hχ; exact absurd hχ (Cl.no_box χ)
    · intro g e hge
      obtain ⟨hg, he⟩ := Cl.untl_eq hge
      subst hg; subst he
      rw [show PlusFormula.untl gd ev = phi from rfl, runLab_mem_phi_iff, runLab_mem_ev_iff,
        runLab_mem_phi_iff]
      constructor
      · intro h; left; omega
      · rintro (h | ⟨h, -⟩)
        · omega
        · exact absurd h (runLab_not_mem_gd _)
    · intro g e hge; exact absurd hge (Cl.no_snce g e)

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

/-! ## The verdict, stated against the window the checker will actually use

`Window.lean` defines `winLo := -2 * NB` with `NB := lcm G.nb G.target.nb`. This fixture's target
path has back period `1` as well, so `NB = 1` here and the combined window's lower endpoint is `-2`
while the single-period one would be `-1`. The verdict therefore reads on the **combined** window
unchanged — which is also why this fixture does **not** adjudicate between addendum (d)'s responses
(α) and (β), and must not be cited as if it did.
-/

@[simp] theorem cert_NBnat : cert.NBnat = 1 := by
  rw [NBnat]
  rfl

@[simp] theorem cert_NFnat : cert.NFnat = 1 := by
  rw [NFnat]
  rfl

@[simp] theorem cert_NB : cert.NB = 1 := by rw [NB, cert_NBnat]; rfl

@[simp] theorem cert_NF : cert.NF = 1 := by rw [NF, cert_NFnat]; rfl

@[simp] theorem cert_NM : cert.NM = 1 := by
  rw [NM, cert_nm]
  rfl

@[simp] theorem cert_winLo : cert.winLo = -2 := by rw [winLo, cert_NB]; rfl

@[simp] theorem cert_winHi : cert.winHi = 3 := by rw [winHi, cert_NM, cert_NF]; rfl

/--
**The verdict against the real window endpoints.**

`p₀` is live at `-cert.NB`, the lower endpoint a single-period window would have, and dead at
`cert.winLo`, the doubled one. So the doubled endpoint cannot be raised to the single-period one
without asserting liveness at `winLo` on behalf of a time where it fails. This is the fact
`Window.lean`'s `winLo` is defined the way it is *because of*, and it is a proved lemma about a
named certificate rather than an expectation.
-/
theorem window_verdict :
    cert.winLo = -2 ∧ -cert.NB = (-1 : ℤ) ∧
      cert.Live (-cert.NB) p₀ ∧ ¬ cert.Live cert.winLo p₀ := by
  refine ⟨cert_winLo, by rw [cert_NB], ?_, ?_⟩
  · rw [cert_NB]
    exact live_neg_one
  · rw [cert_winLo]
    exact not_live_of_le_neg_two le_rfl

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

/-! ## The computed liveness `Finset` is neither empty nor the whole vertex set

Phase 15's last verification criterion, discharged as named theorems rather than by evaluation.
`liveT` is `Nu.gfp` over `verts` iterated `verts.card + 1` times, and every iteration runs an inner
`EUFix.lfp` of the same height over a vertex set of size `n * 2 ^ |Cl| * |winTimes|`, so `decide` is
not a route to either fact and no amount of patience makes it one.

`Bridge.lean`'s equality is the route, and it is used in **both** directions, which is why the gate
is evidence that the bridge is not vacuous either way: non-emptiness is the completeness direction
applied to `live_neg_one`, and properness is the soundness direction contraposed against
`not_live_of_le_neg_two`. Neither direction alone would give both halves.
-/

/-- **(C3b) holds of the fixture, vacuously**: its closure carries no `□`-formula, so the box guess
has nothing to be faithful to. The fixture therefore exercises the bridge's soundness direction
without the box clause doing any work — which is the right test of the rest of the splice. -/
theorem boxLabelFaithful : cert.BoxLabelFaithful := fun χ hχ => absurd hχ (Cl.no_box χ)

theorem mem_winTimes_neg_one : (-1 : ℤ) ∈ cert.winTimes := by
  rw [cert.mem_winTimes, cert_winLo, cert_winHi]
  omega

theorem mem_winTimes_neg_two : (-2 : ℤ) ∈ cert.winTimes := by
  rw [cert.mem_winTimes, cert_winLo, cert_winHi]
  omega

/-- **`p₀` at `-1` is a live vertex**, by the bridge's completeness direction. -/
theorem mem_liveT_neg_one : (p₀, (-1 : ℤ)) ∈ cert.liveT :=
  cert.mem_liveT_of_live mem_winTimes_neg_one live_neg_one

/-- **`p₀` at `-2` is a vertex.** Stated separately, because "not the whole position space" is only
informative if the excluded pair is a vertex to begin with. -/
theorem mem_verts_neg_two : (p₀, (-2 : ℤ)) ∈ cert.verts :=
  (cert.mem_verts _).mpr ⟨mem_winTimes_neg_two, mem_posAt_p₀ (by omega)⟩

/-- **`p₀` at `-2` is not a live vertex**, by the bridge's soundness direction against this module's
own `not_live_of_le_neg_two`. -/
theorem not_mem_liveT_neg_two : (p₀, (-2 : ℤ)) ∉ cert.liveT := by
  intro hv
  have h : cert.Live (-2) p₀ := cert.live_of_mem_liveT boxLabelFaithful hv
  exact not_live_of_le_neg_two le_rfl h

/--
**The gate: the computed liveness `Finset` is neither empty nor the whole vertex set.**

One and the same position is a live vertex at `-1` and a dead one at `-2`, on a certificate whose
slice is literally the same at both times. So the fixpoint discards something and keeps something,
and it is not discarding or keeping on the strength of the slice alone.
-/
theorem liveT_ne_empty_and_ne_verts : cert.liveT ≠ ∅ ∧ cert.liveT ≠ cert.verts := by
  refine ⟨?_, ?_⟩
  · intro hE
    have h := mem_liveT_neg_one
    rw [hE] at h
    simp at h
  · intro hV
    exact not_mem_liveT_neg_two (by rw [hV]; exact mem_verts_neg_two)

/-! ## The re-presentation family

Sub-phase 16.2c's first half. The plan asked for `exists_tailStable_repr` — every certificate has a
tail-stable re-presentation, obtained by absorbing the pre-period into `mid` and multiplying the
period by the cycle length — with this fixture as its worked example. This section builds the
family of re-presentations the recipe describes, `certRep a b c`, and everything about it that can
be said without `Stable.lean`: its decoded slice sequence, the shift identity showing every member
presents `cert`'s own frame moved right by `b`, bi-seriality, the two positions the verdict is
about, the two one-step clauses, and the fulfilling run.

The verdict itself — that **no** member is tail-stable, so `exists_tailStable_repr` is false — is in
`PlusSlicedCertificate/FixtureStable.lean`, because it mentions `ΦBack`, `ΦFwd`, `L₀`, `R₀` and
`TailStable`, all of which live in `Stable.lean`, which imports *this* module. Read that module's
header for the finding; nothing here asserts it.

Two facts recorded here are worth naming because they are what make the family a genuine
re-presentation rather than a different certificate: `certRep_slice_shift` (the slice sequence is
`cert`'s, shifted) and `certRep_slab_shift` (hence so is the presented model's valuation). The
guessed fields and the target path are untouched in every member.
-/

/-- The back and forward slices are the same datum: total edge relation, empty labelling. This is
what makes the fixture's slice sequence a function of "is this the mid time?" alone, and hence what
makes a re-presentation a pure time shift. -/
theorem sliceBack_eq_sliceFwd : sliceBack = sliceFwd := rfl

private theorem cyc_replicate {α : Type*} [Inhabited α] {m : ℕ} (hm : 0 < m) (x : α) (i : ℤ) :
    Periodic.cyc (List.replicate m x) i = x := by
  have hm' : (0 : ℤ) < (m : ℤ) := by exact_mod_cast hm
  have h1 : 0 ≤ i % (m : ℤ) := Int.emod_nonneg _ (by omega)
  have h2 : i % (m : ℤ) < (m : ℤ) := Int.emod_lt_of_pos _ hm'
  have hlt : (i % (m : ℤ)).toNat < m := by omega
  rw [Periodic.cyc]
  simp only [List.length_replicate]
  rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem (by simpa using hlt)]
  simp

private theorem getD_replicate_append {α : Type*} [Inhabited α] (x y : α) :
    ∀ (m i : ℕ), i ≤ m → (List.replicate m x ++ [y]).getD i default = if i < m then x else y
  | 0, 0, _ => by simp
  | 0, (i + 1), h => absurd h (by omega)
  | (m + 1), 0, _ => by simp [List.replicate_succ]
  | (m + 1), (i + 1), h => by
      rw [List.replicate_succ, List.cons_append, List.getD_cons_succ,
        getD_replicate_append x y m i (by omega)]
      by_cases h' : i < m
      · rw [if_pos h', if_pos (by omega)]
      · rw [if_neg h', if_neg (by omega)]

/--
**The re-presentation family.**

`certRep a b c` is the fixture re-presented: the back period repeated `a + 1` times, `b` copies of
the back slice absorbed into `mid` ahead of the mid slice, and the forward period repeated `c + 1`
times. The guessed fields and the target path are untouched; `targetTime` moves with the window.

`cert = certRep 0 0 0` (`cert_eq_certRep`), and `certRep_slice_shift` says every member presents
`cert`'s own slice sequence shifted right by `b`. So this family is exactly the plan's
re-presentation recipe — pre-period absorbed, period multiplied — instantiated at the one
certificate the plan named as its worked example.
-/
def certRep (a b c : ℕ) : PlusSlicedCertificate ctx [] where
  n := 2
  n_pos := by norm_num
  back := List.replicate (a + 1) sliceBack
  mid := List.replicate b sliceBack ++ [sliceMid]
  fwd := List.replicate (c + 1) sliceFwd
  back_ne := by simp
  fwd_ne := by simp
  bx := fun _ => false
  target := tgt
  targetTime := (b : ℤ)

/-- **The fixture is the family's first member.** -/
theorem cert_eq_certRep : cert = certRep 0 0 0 := rfl

@[simp] theorem certRep_n (a b c : ℕ) : (certRep a b c).n = 2 := rfl

theorem certRep_back (a b c : ℕ) : (certRep a b c).back = List.replicate (a + 1) sliceBack := rfl

theorem certRep_mid (a b c : ℕ) :
    (certRep a b c).mid = List.replicate b sliceBack ++ [sliceMid] := rfl

theorem certRep_fwd (a b c : ℕ) : (certRep a b c).fwd = List.replicate (c + 1) sliceFwd := rfl

@[simp] theorem certRep_nb (a b c : ℕ) : (certRep a b c).nb = (a : ℤ) + 1 := by
  simp [certRep, PlusSlicedCertificate.nb]

@[simp] theorem certRep_nm (a b c : ℕ) : (certRep a b c).nm = (b : ℤ) + 1 := by
  simp [certRep, PlusSlicedCertificate.nm]

@[simp] theorem certRep_nf (a b c : ℕ) : (certRep a b c).nf = (c : ℤ) + 1 := by
  simp [certRep, PlusSlicedCertificate.nf]

@[simp] theorem certRep_NBnat (a b c : ℕ) : (certRep a b c).NBnat = a + 1 := by
  rw [NBnat]
  simp [certRep, tgt]

@[simp] theorem certRep_NFnat (a b c : ℕ) : (certRep a b c).NFnat = c + 1 := by
  rw [NFnat]
  simp [certRep, tgt]

@[simp] theorem certRep_NB (a b c : ℕ) : (certRep a b c).NB = (a : ℤ) + 1 := by
  rw [NB, certRep_NBnat]; push_cast; omega

@[simp] theorem certRep_NF (a b c : ℕ) : (certRep a b c).NF = (c : ℤ) + 1 := by
  rw [NF, certRep_NFnat]; push_cast; omega

@[simp] theorem certRep_NM (a b c : ℕ) : (certRep a b c).NM = (b : ℤ) + 1 := by
  rw [NM, certRep_nm]
  have : (certRep a b c).target.nm = 0 := by simp [certRep, tgt, PlusGraphPath.nm]
  rw [this]
  have : (0 : ℤ) ≤ (b : ℤ) := Int.natCast_nonneg b
  exact max_eq_left (by omega)

@[simp] theorem certRep_winHi (a b c : ℕ) :
    (certRep a b c).winHi = (b : ℤ) + 2 * (c : ℤ) + 3 := by
  rw [winHi, certRep_NM, certRep_NF]; omega

/-! ### The slice sequence, and the shift identity -/

/-- **The decoded slice sequence of a re-presentation**: the mid slice at time `b`, the back slice
everywhere else. -/
theorem certRep_slice (a b c : ℕ) (t : ℤ) :
    (certRep a b c).slice t = if t = (b : ℤ) then sliceMid else sliceBack := by
  have hb : (0 : ℤ) ≤ (b : ℤ) := Int.natCast_nonneg b
  rcases lt_trichotomy t 0 with ht | ht | ht
  · rw [PlusSlicedCertificate.slice_neg _ ht, if_neg (by omega)]
    exact cyc_replicate (by omega) _ _
  · subst ht
    rcases Nat.eq_zero_or_pos b with hb0 | hb0
    · subst hb0
      rw [PlusSlicedCertificate.slice_mid _ le_rfl (by simp), if_pos (by simp)]
      simp [certRep]
    · rw [PlusSlicedCertificate.slice_mid _ le_rfl (by simp only [certRep_nm]; omega),
        if_neg (by omega)]
      change (List.replicate b sliceBack ++ [sliceMid]).getD (0 : ℤ).toNat default = sliceBack
      rw [show (0 : ℤ).toNat = 0 from rfl, getD_replicate_append _ _ b 0 (by omega), if_pos hb0]
  · rcases lt_or_ge t ((b : ℤ) + 1) with hlt | hge
    · rw [PlusSlicedCertificate.slice_mid _ (by omega) (by simp only [certRep_nm]; omega)]
      by_cases hbt : t = (b : ℤ)
      · subst hbt
        rw [if_pos rfl]
        change (List.replicate b sliceBack ++ [sliceMid]).getD ((b : ℤ)).toNat default = sliceMid
        rw [show ((b : ℤ)).toNat = b from by simp,
          getD_replicate_append _ _ b b le_rfl, if_neg (by omega)]
      · rw [if_neg hbt]
        have h1 : t.toNat < b := by omega
        change (List.replicate b sliceBack ++ [sliceMid]).getD t.toNat default = sliceBack
        rw [getD_replicate_append _ _ b t.toNat (by omega), if_pos h1]
    · rw [PlusSlicedCertificate.slice_fwd _ (by simp only [certRep_nm]; omega), if_neg (by omega),
        sliceBack_eq_sliceFwd, certRep_fwd]
      exact cyc_replicate (by omega) _ _

/-- **`cert`'s own slice sequence**, in the same closed form. -/
theorem cert_slice (t : ℤ) : cert.slice t = if t = 0 then sliceMid else sliceBack := by
  rcases lt_trichotomy t 0 with ht | ht | ht
  · rw [slice_of_neg ht, if_neg (by omega)]
  · subst ht; rw [slice_zero, if_pos rfl]
  · rw [slice_of_one_le (by omega), if_neg (by omega)]
    exact sliceBack_eq_sliceFwd.symm

/--
**The shift identity: every re-presentation presents the same slice sequence, shifted.**

`(certRep a b c).slice t = cert.slice (t - b)` at every time, with `n` unchanged. The presented
frame is `FrameOver.ofSlicedStep` at the decoded edge relation and the presented model values an
atom by the decoded slice labelling, so this identity (with `certRep_slab_shift`) is what "the same
frame and the same truth, up to a time shift" comes to here. It is stated as the shift identity
rather than through a frame-isomorphism API because this repository has no such API; nothing below
needs more than the identity.
-/
theorem certRep_slice_shift (a b c : ℕ) (t : ℤ) :
    (certRep a b c).slice t = cert.slice (t - (b : ℤ)) := by
  rw [certRep_slice, cert_slice]
  by_cases h : t = (b : ℤ)
  · rw [if_pos h, if_pos (by omega)]
  · rw [if_neg h, if_neg (by omega)]

/-- **The labelling shifts with the slice sequence**, hence so does the presented model's
valuation. -/
theorem certRep_slab_shift (a b c : ℕ) (t : ℤ) (w : Fin 2) :
    (certRep a b c).slab t w = cert.slab (t - (b : ℤ)) w := by
  change ((certRep a b c).slice t).lab w = (cert.slice (t - (b : ℤ))).lab w
  rw [certRep_slice_shift]

/-! ### The labelling, the edge relation, and bi-seriality -/

theorem certRep_edge_eq_true (a b c : ℕ) (t : ℤ) (w u : Fin (certRep a b c).n) :
    (certRep a b c).edge t w u = true := by
  change ((certRep a b c).slice t).edge w u = true
  rw [certRep_slice]
  split <;> rfl

/-- **Every member of the family is bi-serial.** -/
theorem certRep_biSerial (a b c : ℕ) : (certRep a b c).BiSerial := fun t =>
  ⟨fun w => ⟨w, certRep_edge_eq_true a b c t w w⟩,
    fun u => ⟨u, certRep_edge_eq_true a b c t u u⟩⟩

/-- **The event atom is labelled at the mid time only.** -/
theorem certRep_slab_mem_ev_iff (a b c : ℕ) (t : ℤ) (w : Fin (certRep a b c).n) :
    ev ∈ (certRep a b c).slab t w ↔ t = (b : ℤ) := by
  change ev ∈ ((certRep a b c).slice t).lab w ↔ t = (b : ℤ)
  rw [certRep_slice]
  by_cases h : t = (b : ℤ)
  · rw [if_pos h]
    change ev ∈ ({ev} : Finset PlusFormula) ↔ t = (b : ℤ)
    rw [Finset.mem_singleton]
    exact ⟨fun _ => h, fun _ => rfl⟩
  · rw [if_neg h]
    change ev ∈ (∅ : Finset PlusFormula) ↔ t = (b : ℤ)
    exact ⟨fun hx => absurd hx (Finset.notMem_empty _), fun hx => absurd hx h⟩

/-- **The guard atom is labelled nowhere.** -/
theorem certRep_slab_not_mem_gd (a b c : ℕ) (t : ℤ) (w : Fin (certRep a b c).n) :
    gd ∉ (certRep a b c).slab t w := by
  change gd ∉ ((certRep a b c).slice t).lab w
  rw [certRep_slice]
  by_cases h : t = (b : ℤ)
  · rw [if_pos h]
    change gd ∉ ({ev} : Finset PlusFormula)
    rw [Finset.mem_singleton]
    exact fun hh => ev_ne_gd hh.symm
  · rw [if_neg h]
    exact Finset.notMem_empty _

/-- **(C3b) holds vacuously of every member**: the closure carries no `□`-formula. -/
theorem certRep_boxLabelFaithful (a b c : ℕ) : (certRep a b c).BoxLabelFaithful :=
  fun χ hχ => absurd hχ (Cl.no_box χ)

/-! ### The two positions the failure is about -/

/-- **Internal coherence is free at this closure**: no `⊥` in the label is the whole of it, since
the closure has no implication. -/
theorem labCoherent_of_not_mem_bot {X : Finset PlusFormula} (h : PlusFormula.bot ∉ X) :
    LabCoherent ctx [] X := by
  refine ⟨h, ?_⟩
  intro ψ hψ
  match ψ with
  | .atom _ => rfl
  | .bot => rfl
  | .imp a b => exact absurd hψ (Cl.no_imp a b)
  | .box _ => rfl
  | .untl _ _ => rfl
  | .snce _ _ => rfl
  | .stab _ => rfl

/-- **Agreement on the state formulas, for an atom-free label at a non-mid time.** -/
theorem certRep_agreesOnState (a b c : ℕ) {t : ℤ} (ht : t ≠ (b : ℤ))
    (w : Fin (certRep a b c).n) {X : Finset PlusFormula} (hev : ev ∉ X) (hgd : gd ∉ X) :
    (certRep a b c).AgreesOnState t w X := by
  intro ψ hψ hst
  rcases (mem_Cl_iff ψ).mp hψ with h | h | h
  · subst h; exact absurd hst (by simp [IsStateShape, phi])
  · subst h
    exact ⟨fun hx => absurd hx hev,
      fun hx => absurd ((certRep_slab_mem_ev_iff a b c t w).mp hx) ht⟩
  · subst h
    exact ⟨fun hx => absurd hx hgd, fun hx => absurd hx (certRep_slab_not_mem_gd a b c t w)⟩

/-- **The dead label**, carrying the pending eventuality. `p₀`'s counterpart in the family. -/
def pR (a b c : ℕ) : (certRep a b c).Pos :=
  (⟨0, (certRep a b c).n_pos⟩, ⟨{phi}, Finset.mem_powerset.mpr singleton_phi_sub⟩)

/-- **The all-empty label.** The one every fulfilling run of the family carries away from the mid
time. -/
def eR (a b c : ℕ) : (certRep a b c).Pos :=
  (⟨0, (certRep a b c).n_pos⟩, ⟨∅, Finset.mem_powerset.mpr (Finset.empty_subset _)⟩)

@[simp] theorem pR_snd (a b c : ℕ) : (pR a b c).2.1 = ({phi} : Finset PlusFormula) := rfl

@[simp] theorem eR_snd (a b c : ℕ) : (eR a b c).2.1 = (∅ : Finset PlusFormula) := rfl

theorem pR_ne_eR (a b c : ℕ) : pR a b c ≠ eR a b c := by
  intro h
  have := congrArg (fun q => q.2.1) h
  rw [pR_snd, eR_snd] at this
  exact absurd (this ▸ Finset.mem_singleton_self phi) (Finset.notMem_empty phi)

/-- **`pR` is a position of every non-mid slice.** The dead label is perfectly legitimate: the
closure has no implication, `phi` is not a state shape, and neither atom is in the label. -/
theorem mem_posAt_pR (a b c : ℕ) {t : ℤ} (ht : t ≠ (b : ℤ)) :
    pR a b c ∈ (certRep a b c).posAt t := by
  rw [mem_posAt]
  refine ⟨labCoherent_of_not_mem_bot ?_, certRep_agreesOnState a b c ht _ ?_ ?_⟩
  · rw [pR_snd, Finset.mem_singleton]
    exact fun h => bot_ne_phi h
  · rw [pR_snd, Finset.mem_singleton]
    exact fun h => phi_ne_ev h.symm
  · rw [pR_snd, Finset.mem_singleton]
    exact fun h => phi_ne_gd h.symm

/-- **`eR` is a position of every non-mid slice.** -/
theorem mem_posAt_eR (a b c : ℕ) {t : ℤ} (ht : t ≠ (b : ℤ)) :
    eR a b c ∈ (certRep a b c).posAt t := by
  rw [mem_posAt]
  exact ⟨labCoherent_of_not_mem_bot (by rw [eR_snd]; exact Finset.notMem_empty _),
    certRep_agreesOnState a b c ht _ (by rw [eR_snd]; exact Finset.notMem_empty _)
      (by rw [eR_snd]; exact Finset.notMem_empty _)⟩

/-! ### The two one-step clauses the failure runs on -/

/-- **A step from the empty label to the empty label is legitimate.** -/
theorem stepClause_empty_empty : StepClause ctx [] ∅ ∅ := by
  refine ⟨?_, ?_⟩
  · intro ψ hψ
    match ψ with
    | .atom _ => rfl
    | .bot => rfl
    | .imp _ _ => rfl
    | .box _ => rfl
    | .untl g e =>
        simp only [untlClauseAt, decide_eq_true_eq]
        exact ⟨fun h => absurd h (Finset.notMem_empty _),
          fun h => by rcases h with h | ⟨h, -⟩ <;> exact absurd h (Finset.notMem_empty _)⟩
    | .snce g e => exact absurd hψ (Cl.no_snce g e)
    | .stab a => exact absurd hψ (Cl.no_stab a)
  · intro ψ hψ
    match ψ with
    | .atom _ => rfl
    | .bot => rfl
    | .imp _ _ => rfl
    | .box _ => rfl
    | .untl _ _ => rfl
    | .snce g e => exact absurd hψ (Cl.no_snce g e)
    | .stab a => exact absurd hψ (Cl.no_stab a)

/--
**A step from the empty label to the dead label is legitimate.**

This is the load-bearing fact, and it is worth reading twice. `untlClauseAt X Y` constrains
`untl g e ∈ X` — the **earlier** label — in terms of `Y`; it says nothing whatever about
`untl g e ∈ Y`. So the arriving label may carry an eventuality that nothing will discharge, and the
one-step graph has no objection. That is why a reachability transfer rightward cannot be a fixpoint
at the live set.
-/
theorem stepClause_empty_phi : StepClause ctx [] ∅ {phi} := by
  refine ⟨?_, ?_⟩
  · intro ψ hψ
    match ψ with
    | .atom _ => rfl
    | .bot => rfl
    | .imp _ _ => rfl
    | .box _ => rfl
    | .untl g e =>
        obtain ⟨hg, he⟩ := Cl.untl_eq hψ
        subst hg; subst he
        simp only [untlClauseAt, decide_eq_true_eq]
        refine ⟨fun h => absurd h (Finset.notMem_empty _), fun h => ?_⟩
        rcases h with h | ⟨h, -⟩
        · rw [Finset.mem_singleton] at h
          exact absurd h.symm phi_ne_ev
        · rw [Finset.mem_singleton] at h
          exact absurd h.symm phi_ne_gd
    | .snce g e => exact absurd hψ (Cl.no_snce g e)
    | .stab a => exact absurd hψ (Cl.no_stab a)
  · intro ψ hψ
    match ψ with
    | .atom _ => rfl
    | .bot => rfl
    | .imp _ _ => rfl
    | .box _ => rfl
    | .untl _ _ => rfl
    | .snce g e => exact absurd hψ (Cl.no_snce g e)
    | .stab a => exact absurd hψ (Cl.no_stab a)

/-! ### The all-empty run, and what it makes live -/

/-- The family's fulfilling run: the eventuality one step before the mid time, the event at it,
nothing anywhere else. -/
def repLab (b : ℕ) : ℤ → Finset PlusFormula :=
  fun t => if t = (b : ℤ) - 1 then {phi} else if t = (b : ℤ) then {ev} else ∅

theorem repLab_mem_phi_iff (b : ℕ) (t : ℤ) : phi ∈ repLab b t ↔ t = (b : ℤ) - 1 := by
  unfold repLab
  split_ifs with h1 h2
  · simp [h1]
  · exact ⟨fun h => absurd (Finset.mem_singleton.mp h) phi_ne_ev, fun h => absurd h h1⟩
  · exact ⟨fun h => absurd h (Finset.notMem_empty _), fun h => absurd h h1⟩

theorem repLab_mem_ev_iff (b : ℕ) (t : ℤ) : ev ∈ repLab b t ↔ t = (b : ℤ) := by
  unfold repLab
  split_ifs with h1 h2
  · exact ⟨fun h => absurd (Finset.mem_singleton.mp h).symm phi_ne_ev, fun h => by omega⟩
  · simp [h2]
  · exact ⟨fun h => absurd h (Finset.notMem_empty _), fun h => absurd h h2⟩

theorem repLab_not_mem_gd (b : ℕ) (t : ℤ) : gd ∉ repLab b t := by
  unfold repLab
  split_ifs
  · exact fun h => absurd (Finset.mem_singleton.mp h) (fun hh => phi_ne_gd hh.symm)
  · exact fun h => absurd (Finset.mem_singleton.mp h) (fun hh => ev_ne_gd hh.symm)
  · exact Finset.notMem_empty _

theorem repLab_not_mem_bot (b : ℕ) (t : ℤ) : PlusFormula.bot ∉ repLab b t := by
  unfold repLab
  split_ifs
  · exact fun h => bot_ne_phi (Finset.mem_singleton.mp h)
  · exact fun h => bot_ne_ev (Finset.mem_singleton.mp h)
  · exact Finset.notMem_empty _

theorem repLab_sub (b : ℕ) (t : ℤ) : repLab b t ⊆ Cl := by
  unfold repLab
  split_ifs
  · exact singleton_phi_sub
  · exact singleton_ev_sub
  · exact Finset.empty_subset _

/-- **The family's fulfilling run.** -/
def repRun (a b c : ℕ) : (certRep a b c).LabRun where
  st := fun _ => ⟨0, (certRep a b c).n_pos⟩
  lab := repLab b
  lab_sub := repLab_sub b
  agrees := by
    intro s ψ hψ hst
    rcases (mem_Cl_iff ψ).mp hψ with h | h | h
    · subst h
      exact absurd hst (by simp [IsStateShape, phi])
    · subst h
      rw [repLab_mem_ev_iff, certRep_slab_mem_ev_iff]
    · subst h
      exact ⟨fun h => absurd h (repLab_not_mem_gd b s),
        fun h => absurd h (certRep_slab_not_mem_gd a b c s _)⟩
  steps := fun s => certRep_edge_eq_true a b c s _ _
  coherent := by
    intro t
    refine ⟨repLab_not_mem_bot b t, ?_, ?_, ?_, ?_⟩
    · intro x y hxy; exact absurd hxy (Cl.no_imp x y)
    · intro χ hχ; exact absurd hχ (Cl.no_box χ)
    · intro g e hge
      obtain ⟨hg, he⟩ := Cl.untl_eq hge
      subst hg; subst he
      rw [show PlusFormula.untl gd ev = phi from rfl, repLab_mem_phi_iff, repLab_mem_ev_iff,
        repLab_mem_phi_iff]
      refine ⟨fun h => Or.inl (by omega), ?_⟩
      rintro (h | ⟨h, -⟩)
      · omega
      · exact absurd h (repLab_not_mem_gd b _)
    · intro g e hge; exact absurd hge (Cl.no_snce g e)

@[simp] theorem repRun_lab (a b c : ℕ) : (repRun a b c).lab = repLab b := rfl

/-- **The run is fulfilling**: its one pending eventuality is discharged at the next time, and no
`snce` is ever carried. -/
theorem repRun_fulfilling (a b c : ℕ) : PlusFulfillingSeqLab (repRun a b c).lab := by
  constructor
  · intro t g e hu
    rw [repRun_lab] at hu
    have ht : t = (b : ℤ) - 1 ∧ PlusFormula.untl g e = phi := by
      unfold repLab at hu
      split_ifs at hu with h1 h2
      · exact ⟨h1, Finset.mem_singleton.mp hu⟩
      · exact absurd (Finset.mem_singleton.mp hu) (by simp [ev])
      · exact absurd hu (Finset.notMem_empty _)
    obtain ⟨ht1, ht2⟩ := ht
    rw [phi] at ht2
    injection ht2 with hg he
    subst hg; subst he; subst ht1
    refine ⟨(b : ℤ), by omega, ?_, fun r hr1 hr2 => absurd hr1 (by omega)⟩
    rw [repRun_lab, repLab_mem_ev_iff]
  · intro t g e hs
    rw [repRun_lab] at hs
    unfold repLab at hs
    split_ifs at hs with h1 h2
    · exact absurd (Finset.mem_singleton.mp hs) (by simp [phi])
    · exact absurd (Finset.mem_singleton.mp hs) (by simp [ev])
    · exact absurd hs (Finset.notMem_empty _)

/-- **The run occupies `eR` away from the two special times.** -/
theorem repRun_pos_eq_eR (a b c : ℕ) {t : ℤ} (h1 : t ≠ (b : ℤ) - 1) (h2 : t ≠ (b : ℤ)) :
    (repRun a b c).pos t = eR a b c := by
  refine Prod.ext rfl (Subtype.ext ?_)
  change repLab b t = (∅ : Finset PlusFormula)
  unfold repLab
  rw [if_neg h1, if_neg h2]

/-- **`eR` is live away from the two special times.** -/
theorem live_eR (a b c : ℕ) {t : ℤ} (h1 : t ≠ (b : ℤ) - 1) (h2 : t ≠ (b : ℤ)) :
    (certRep a b c).Live t (eR a b c) := by
  rw [← repRun_pos_eq_eR a b c h1 h2]
  exact (certRep a b c).live_of_path (repRun a b c) (repRun_fulfilling a b c) t

/-! ### `pR` is occupied by no run except one step before the mid time -/

/--
**No run of `certRep a b c` occupies `pR` anywhere but at `b - 1`.**

Stronger than non-liveness, and proved from the one-step unfolding clause alone: a label carrying
`phi` at `t` forces the event or the guard at `t + 1`, the guard is labelled nowhere, and the event
is labelled at `b` alone. This is the general form of the landed `not_exists_labRun_of_le_neg_two`,
which is now its `a = b = c = 0`, `t ≤ -2` instance.
-/
theorem not_exists_labRun_pR (a b c : ℕ) {t : ℤ} (ht : t ≠ (b : ℤ) - 1) :
    ¬ ∃ R : (certRep a b c).LabRun, R.pos t = pR a b c := by
  rintro ⟨R, hR⟩
  have hlab : R.lab t = ({phi} : Finset PlusFormula) := by
    have h : (R.pos t).2.1 = (pR a b c).2.1 := congrArg (fun q => q.2.1) hR
    rw [LabRun.pos_snd, pR_snd] at h
    exact h
  have hin : phi ∈ R.lab t := by rw [hlab]; exact Finset.mem_singleton_self _
  have hcl := ((R.coherent t).2.2.2.1 gd ev mem_Cl_phi).mp hin
  have hev : ev ∉ R.lab (t + 1) := by
    intro h
    have := (R.agrees (t + 1) ev mem_Cl_ev rfl).mp h
    rw [certRep_slab_mem_ev_iff] at this
    omega
  have hgd : gd ∉ R.lab (t + 1) := by
    intro h
    exact certRep_slab_not_mem_gd a b c _ _ ((R.agrees (t + 1) gd mem_Cl_gd rfl).mp h)
  rcases hcl with h | ⟨h, -⟩
  · exact hev h
  · exact hgd h

/-- **`pR` is not live anywhere but at `b - 1`.** -/
theorem not_live_pR (a b c : ℕ) {t : ℤ} (ht : t ≠ (b : ℤ) - 1) :
    ¬ (certRep a b c).Live t (pR a b c) := by
  rintro ⟨⟨R, -, hR⟩, -⟩
  exact not_exists_labRun_pR a b c ht ⟨R, hR⟩

end Fixture

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
