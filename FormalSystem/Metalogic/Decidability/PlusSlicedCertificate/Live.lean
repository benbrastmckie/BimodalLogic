/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Position

/-!
# Liveness of a Position, as a Property of the Certificate's Own Runs

A position at a slice time is **live** when the certificate admits a bi-infinite labelled run
through it whose eventualities are all discharged. This module defines that notion, splits it into
a forward half and a backward half, and proves **both** directions of the characterization:
a position occupied by a fulfilling run is live, and every live position is occupied by one.

## Why liveness is a property of the certificate rather than a demanded field

`PlusSlicedCertificate` carries no `witness` field, and it must not: a demanded all-threads
fulfilment condition on a finite, eventually periodic presentation is refuted by
`not_exists_plusCertifies_pumpTarget`. Liveness is therefore *read off* the certificate's own
`edge`/`slab` data — it quantifies over runs of the presented structure, adding no field and no
obligation on the certificate's author. That is exactly what removes the refutation's root cause:
positions that cannot fulfil are simply not live, rather than being a violated demand.

## The split, and its semantic counterpart

`FwdLive` asks only that the `untl` eventualities be discharged; `BwdLive` asks only that the
`snce` eventualities be. `Live` is the conjunction, and `live_iff` proves the conjunction is
equivalent to the existence of one run discharging **both** — which is the label-level counterpart
of `stab_factors` / `not_stab_factors` (`Splice.lean`), the semantic factorization Phases 18 and 19
consume. `stab_factors` splits an existential over `WorldHistory`; `live_iff` splits the same
existential over label sequences, and the two are the same argument at two levels. The splicing
here needs no `paste`: two runs agreeing at `t` splice by a literal `if s ≤ t`, and the
`PlusPasting` machinery is only required once the claim is transported to histories.

`stab_factors` supplies the *semantic* half and is not re-proved here; this module supplies the
*syntactic* half, and neither is derived from the other.

## The two propagation lemmas are the content

A run's forward half cannot discharge an `untl` pending strictly before the splice time, and its
backward half cannot discharge a `snce` pending strictly after it. What makes the splice work is
that an undischarged eventuality **propagates across the splice time**: `untl_push` shows an
`untl g e` pending at `s` is either discharged in `(s, t]`, with its guard holding throughout, or
still pending at `t`; `snce_push` is its mirror. Both are consequences of the one-step unfolding
clauses of `PlusLocalCoherentSeqLab` alone, so both hold of any locally coherent labelling, not
only of a run.

## What this module does NOT do, and where it went

The plan's Phase 15 asks for `fwdLive` as a *computed* `Finset`, by a decreasing iteration. That
computation is **not** here, and the reason is recorded at the plan's Phase 15 heading: the carrier
`Pos` factors time out, so a fixpoint of a slice-indexed condition lives in `(Finset Pos)^ℤ`,
which has infinite height. The computation belongs on a **timed** carrier with finiteness on a
`Finset` of vertices, transcribed from `SharingWitnessFamily.verts` / `succF` / `predF`, and it is
sub-phase 15.3's business. This module is the object that computation must be proved to compute:
its two directions are stated at an arbitrary `t : ℤ`, with no window restriction, because that is
the form Phases 18 and 19 cite.

## Main definitions

- `PlusFwdFulfilling` / `PlusBwdFulfilling` — the two halves of `PlusFulfillingSeqLab`
- `PlusSlicedCertificate.LabRun` — a bi-infinite labelled run of the certificate
- `PlusSlicedCertificate.FwdLive` / `BwdLive` / `Live` — liveness and its two halves

## Main results

- `untl_push` / `snce_push` — an undischarged eventuality propagates to any later (earlier) time
- `PlusSlicedCertificate.live_of_path` — the soundness direction
- `PlusSlicedCertificate.exists_path_of_live` — the completeness direction, by splicing
- `PlusSlicedCertificate.live_iff` — the two directions as one biconditional
- `PlusSlicedCertificate.fwdLive_step` / `bwdLive_step` — liveness advances along `succP` / `predP`

## Tags

plus-language · certificate · time-sliced · liveness · splicing
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

variable {Γ Del : PlusContext}

/-! ## The two halves of fulfilment -/

/--
**Forward fulfilment**: every `untl` eventuality carried by a label is discharged strictly later,
with its guard holding at every time strictly in between.

This is the first conjunct of `PlusFulfillingSeqLab`, named so that it can be demanded of a run
without demanding the second.
-/
def PlusFwdFulfilling (lab : ℤ → Finset PlusFormula) : Prop :=
  ∀ (t : ℤ) (g e : PlusFormula), PlusFormula.untl g e ∈ lab t →
    ∃ s : ℤ, t < s ∧ e ∈ lab s ∧ ∀ r : ℤ, t < r → r < s → g ∈ lab r

/-- **Backward fulfilment**, the mirror: every `snce` eventuality is discharged strictly earlier. -/
def PlusBwdFulfilling (lab : ℤ → Finset PlusFormula) : Prop :=
  ∀ (t : ℤ) (g e : PlusFormula), PlusFormula.snce g e ∈ lab t →
    ∃ s : ℤ, s < t ∧ e ∈ lab s ∧ ∀ r : ℤ, s < r → r < t → g ∈ lab r

/-- **Fulfilment is exactly the two halves.** Definitional, and stated so that no use site has to
unfold `PlusFulfillingSeqLab` to reach one conjunct. -/
theorem plusFulfillingSeqLab_iff_halves (lab : ℤ → Finset PlusFormula) :
    PlusFulfillingSeqLab lab ↔ PlusFwdFulfilling lab ∧ PlusBwdFulfilling lab := Iff.rfl

/-! ## Undischarged eventualities propagate

The two lemmas the splice rests on. Each consumes only the corresponding one-step unfolding clause
of `PlusLocalCoherentSeqLab`, so each holds of an arbitrary locally coherent labelling.
-/

/--
**An `untl` pending at `s` propagates forward.** At any `t ≥ s`, either the event has already been
delivered somewhere in `(s, t]` with the guard holding strictly in between, or the eventuality is
still pending at `t` and the guard has held throughout `(s, t]`.
-/
theorem untl_push {bx : PlusFormula → Bool} {lab : ℤ → Finset PlusFormula}
    (hcoh : PlusLocalCoherentSeqLab Γ Del bx lab) {g e : PlusFormula}
    (hmem : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) {s : ℤ}
    (h0 : PlusFormula.untl g e ∈ lab s) :
    ∀ t : ℤ, s ≤ t →
      (∃ r : ℤ, s < r ∧ r ≤ t ∧ e ∈ lab r ∧ ∀ q : ℤ, s < q → q < r → g ∈ lab q) ∨
        (PlusFormula.untl g e ∈ lab t ∧ ∀ q : ℤ, s < q → q ≤ t → g ∈ lab q) := by
  intro t ht
  induction t, ht using Int.leInduction with
  | base =>
      exact Or.inr ⟨h0, fun q hq1 hq2 => absurd hq1 (by omega)⟩
  | succ n hn ih =>
      rcases ih with ⟨r, hr1, hr2, hr3, hr4⟩ | ⟨hpend, hguard⟩
      · exact Or.inl ⟨r, hr1, by omega, hr3, hr4⟩
      · rcases ((hcoh n).2.2.2.1 g e hmem).mp hpend with hnow | ⟨hg, hlater⟩
        · refine Or.inl ⟨n + 1, by omega, le_rfl, hnow, ?_⟩
          intro q hq1 hq2
          exact hguard q hq1 (by omega)
        · refine Or.inr ⟨hlater, ?_⟩
          intro q hq1 hq2
          rcases eq_or_lt_of_le hq2 with heq | hlt
          · rw [heq]; exact hg
          · exact hguard q hq1 (by omega)

/--
**A `snce` pending at `s` propagates backward**, the mirror of `untl_push`.
-/
theorem snce_push {bx : PlusFormula → Bool} {lab : ℤ → Finset PlusFormula}
    (hcoh : PlusLocalCoherentSeqLab Γ Del bx lab) {g e : PlusFormula}
    (hmem : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) {s : ℤ}
    (h0 : PlusFormula.snce g e ∈ lab s) :
    ∀ t : ℤ, t ≤ s →
      (∃ r : ℤ, r < s ∧ t ≤ r ∧ e ∈ lab r ∧ ∀ q : ℤ, r < q → q < s → g ∈ lab q) ∨
        (PlusFormula.snce g e ∈ lab t ∧ ∀ q : ℤ, t ≤ q → q < s → g ∈ lab q) := by
  intro t ht
  induction t, ht using Int.leInductionDown with
  | base =>
      exact Or.inr ⟨h0, fun q hq1 hq2 => absurd hq2 (by omega)⟩
  | pred n hn ih =>
      rcases ih with ⟨r, hr1, hr2, hr3, hr4⟩ | ⟨hpend, hguard⟩
      · exact Or.inl ⟨r, hr1, by omega, hr3, hr4⟩
      · rcases ((hcoh n).2.2.2.2 g e hmem).mp hpend with hnow | ⟨hg, hearlier⟩
        · refine Or.inl ⟨n - 1, by omega, le_rfl, hnow, ?_⟩
          intro q hq1 hq2
          exact hguard q (by omega) hq2
        · refine Or.inr ⟨hearlier, ?_⟩
          intro q hq1 hq2
          rcases eq_or_lt_of_le hq1 with heq | hlt
          · rw [← heq]; exact hg
          · exact hguard q (by omega) hq2

/-- **Forward fulfilment from a half-line.** If every eventuality pending at or after `t` is
discharged, then every eventuality is, because one pending earlier propagates up to `t`. -/
theorem plusFwdFulfilling_of_ge {bx : PlusFormula → Bool} {lab : ℤ → Finset PlusFormula}
    (hcoh : PlusLocalCoherentSeqLab Γ Del bx lab)
    (hsub : ∀ s : ℤ, lab s ⊆ plusClosureOf (Γ ++ Del)) (t : ℤ)
    (h : ∀ s : ℤ, t ≤ s → ∀ g e : PlusFormula, PlusFormula.untl g e ∈ lab s →
      ∃ r : ℤ, s < r ∧ e ∈ lab r ∧ ∀ q : ℤ, s < q → q < r → g ∈ lab q) :
    PlusFwdFulfilling lab := by
  intro s g e hu
  rcases le_or_gt t s with hts | hst
  · exact h s hts g e hu
  · have hmem : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del) := hsub s hu
    rcases untl_push hcoh hmem hu t (le_of_lt hst) with
      ⟨r, hr1, _, hr3, hr4⟩ | ⟨hpend, hguard⟩
    · exact ⟨r, hr1, hr3, hr4⟩
    · obtain ⟨r, hr1, hr2, hr3⟩ := h t le_rfl g e hpend
      refine ⟨r, by omega, hr2, ?_⟩
      intro q hq1 hq2
      rcases le_or_gt q t with hqt | htq
      · exact hguard q hq1 hqt
      · exact hr3 q htq hq2

/-- **Backward fulfilment from a half-line**, the mirror of `plusFwdFulfilling_of_ge`. -/
theorem plusBwdFulfilling_of_le {bx : PlusFormula → Bool} {lab : ℤ → Finset PlusFormula}
    (hcoh : PlusLocalCoherentSeqLab Γ Del bx lab)
    (hsub : ∀ s : ℤ, lab s ⊆ plusClosureOf (Γ ++ Del)) (t : ℤ)
    (h : ∀ s : ℤ, s ≤ t → ∀ g e : PlusFormula, PlusFormula.snce g e ∈ lab s →
      ∃ r : ℤ, r < s ∧ e ∈ lab r ∧ ∀ q : ℤ, r < q → q < s → g ∈ lab q) :
    PlusBwdFulfilling lab := by
  intro s g e hu
  rcases le_or_gt s t with hst | hts
  · exact h s hst g e hu
  · have hmem : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del) := hsub s hu
    rcases snce_push hcoh hmem hu t (le_of_lt hts) with
      ⟨r, hr1, _, hr3, hr4⟩ | ⟨hpend, hguard⟩
    · exact ⟨r, hr1, hr3, hr4⟩
    · obtain ⟨r, hr1, hr2, hr3⟩ := h t le_rfl g e hpend
      refine ⟨r, by omega, hr2, ?_⟩
      intro q hq1 hq2
      rcases le_or_gt t q with htq | hqt
      · exact hguard q htq hq2
      · exact hr3 q hq1 hqt

namespace PlusSlicedCertificate

/-! ## Runs of the certificate -/

/--
**A labelled run of the certificate**: a bi-infinite state function following the slice graph,
together with a bi-infinite labelling that agrees with the slice labelling on the state formulas
and is locally coherent against the certificate's own box guess.

Fulfilment is deliberately **not** a field: the whole point is to ask for it on one half at a time.
-/
structure LabRun (G : PlusSlicedCertificate Γ Del) where
  /-- The state visited at each slice time. -/
  st : ℤ → Fin G.n
  /-- The label carried at each slice time. -/
  lab : ℤ → Finset PlusFormula
  /-- Every label is drawn from the target closure. -/
  lab_sub : ∀ s : ℤ, lab s ⊆ plusClosureOf (Γ ++ Del)
  /-- Each label agrees with the slice labelling on the state formulas. -/
  agrees : ∀ s : ℤ, G.AgreesOnState s (st s) (lab s)
  /-- Consecutive states are joined by a slice edge. -/
  steps : ∀ s : ℤ, G.edge s (st s) (st (s + 1)) = true
  /-- The labelling satisfies the five local-coherence clauses. -/
  coherent : PlusLocalCoherentSeqLab Γ Del G.bx lab

namespace LabRun

variable {G : PlusSlicedCertificate Γ Del}

/-- The position a run occupies at a slice time. -/
def pos (R : G.LabRun) (t : ℤ) : G.Pos := G.posOf R.lab R.lab_sub R.st t

@[simp] theorem pos_fst (R : G.LabRun) (t : ℤ) : (R.pos t).1 = R.st t := rfl

@[simp] theorem pos_snd (R : G.LabRun) (t : ℤ) : (R.pos t).2.1 = R.lab t := rfl

/-- Two runs occupy the same position exactly when their state and their label agree there. -/
theorem pos_eq_iff (R R' : G.LabRun) (t : ℤ) :
    R.pos t = R'.pos t ↔ R.st t = R'.st t ∧ R.lab t = R'.lab t := by
  constructor
  · intro h
    exact ⟨congrArg Prod.fst h, congrArg (fun p => p.2.1) h⟩
  · rintro ⟨h1, h2⟩
    refine Prod.ext h1 (Subtype.ext ?_)
    exact h2

/-- **A run occupies a position at every time.** -/
theorem pos_mem_posAt (R : G.LabRun) (t : ℤ) : R.pos t ∈ G.posAt t :=
  mem_posAt_of_path G R.lab R.lab_sub R.st R.coherent R.agrees t

/-- **A run's next position is a `succP`-successor of its current one.** -/
theorem pos_mem_succP (R : G.LabRun) (t : ℤ) : R.pos (t + 1) ∈ G.succP t (R.pos t) :=
  mem_succP_of_path G R.lab R.lab_sub R.st R.coherent R.agrees R.steps t

/-- **A run's previous position is a `predP`-predecessor of its current one.** -/
theorem pos_mem_predP (R : G.LabRun) (t : ℤ) : R.pos t ∈ G.predP (t + 1) (R.pos (t + 1)) :=
  mem_predP_of_path G R.lab R.lab_sub R.st R.coherent R.agrees R.steps t

end LabRun

/-! ## Liveness -/

/--
**A position is forward-live at `t`** when some run of the certificate occupies it at `t` and
discharges every `untl` eventuality. Its `snce` eventualities are unconstrained: that is the
backward half's job.
-/
def FwdLive (G : PlusSlicedCertificate Γ Del) (t : ℤ) (p : G.Pos) : Prop :=
  ∃ R : G.LabRun, PlusFwdFulfilling R.lab ∧ R.pos t = p

/-- **A position is backward-live at `t`**, the mirror of `FwdLive`. -/
def BwdLive (G : PlusSlicedCertificate Γ Del) (t : ℤ) (p : G.Pos) : Prop :=
  ∃ R : G.LabRun, PlusBwdFulfilling R.lab ∧ R.pos t = p

/--
**A position is live at `t`** when it is both forward-live and backward-live.

`live_iff` below is what makes this conjunction the right definition rather than a guess: it is
equivalent to occupancy by a single run discharging *both* halves. That equivalence is the
label-level counterpart of `stab_factors`.
-/
def Live (G : PlusSlicedCertificate Γ Del) (t : ℤ) (p : G.Pos) : Prop :=
  G.FwdLive t p ∧ G.BwdLive t p

/-- A forward-live position is a position of its slice. -/
theorem mem_posAt_of_fwdLive (G : PlusSlicedCertificate Γ Del) {t : ℤ} {p : G.Pos}
    (h : G.FwdLive t p) : p ∈ G.posAt t := by
  obtain ⟨R, _, hp⟩ := h
  rw [← hp]
  exact R.pos_mem_posAt t

/-- A live position is a position of its slice. -/
theorem mem_posAt_of_live (G : PlusSlicedCertificate Γ Del) {t : ℤ} {p : G.Pos}
    (h : G.Live t p) : p ∈ G.posAt t :=
  G.mem_posAt_of_fwdLive h.1

/-! ### Liveness advances along the one-step graph

The two lemmas sub-phase 15.3's transfer operators consume: forward liveness pushes forward along
`succP`, backward liveness pushes backward along `predP`. Only these directions are available from
the definitions, and deliberately so — the converse would require extending a run outside the
half-line it is constrained on, which is precisely what the splice, not a one-step lemma, delivers.
-/

/-- **Forward liveness advances along `succP`.** -/
theorem fwdLive_step (G : PlusSlicedCertificate Γ Del) {t : ℤ} {p : G.Pos} (h : G.FwdLive t p) :
    ∃ q ∈ G.succP t p, G.FwdLive (t + 1) q := by
  obtain ⟨R, hf, hp⟩ := h
  refine ⟨R.pos (t + 1), ?_, ⟨R, hf, rfl⟩⟩
  rw [← hp]
  exact R.pos_mem_succP t

/-- **Backward liveness advances along `predP`.** -/
theorem bwdLive_step (G : PlusSlicedCertificate Γ Del) {t : ℤ} {p : G.Pos}
    (h : G.BwdLive (t + 1) p) : ∃ q ∈ G.predP (t + 1) p, G.BwdLive t q := by
  obtain ⟨R, hb, hp⟩ := h
  refine ⟨R.pos t, ?_, ⟨R, hb, rfl⟩⟩
  rw [← hp]
  exact R.pos_mem_predP t

/-! ## The splice

Two runs agreeing at `t` splice into one run, following the first up to `t` and the second from `t`
on. No `paste` is needed: the agreement at the splice time makes every clause that straddles it
readable from whichever side owns the other index.
-/

section Splice

variable {G : PlusSlicedCertificate Γ Del}

/-- The spliced state function. -/
def spliceSt (Rb Rf : G.LabRun) (t : ℤ) : ℤ → Fin G.n :=
  fun s => if s ≤ t then Rb.st s else Rf.st s

/-- The spliced labelling. -/
def spliceLab (Rb Rf : G.LabRun) (t : ℤ) : ℤ → Finset PlusFormula :=
  fun s => if s ≤ t then Rb.lab s else Rf.lab s

theorem spliceSt_le (Rb Rf : G.LabRun) {t s : ℤ} (h : s ≤ t) :
    spliceSt Rb Rf t s = Rb.st s := if_pos h

theorem spliceLab_le (Rb Rf : G.LabRun) {t s : ℤ} (h : s ≤ t) :
    spliceLab Rb Rf t s = Rb.lab s := if_pos h

theorem spliceSt_ge (Rb Rf : G.LabRun) {t s : ℤ} (hst : Rb.st t = Rf.st t) (h : t ≤ s) :
    spliceSt Rb Rf t s = Rf.st s := by
  unfold spliceSt
  by_cases hs : s ≤ t
  · have : s = t := le_antisymm hs h
    subst this
    simp [hst]
  · simp [hs]

theorem spliceLab_ge (Rb Rf : G.LabRun) {t s : ℤ} (hlab : Rb.lab t = Rf.lab t) (h : t ≤ s) :
    spliceLab Rb Rf t s = Rf.lab s := by
  unfold spliceLab
  by_cases hs : s ≤ t
  · have : s = t := le_antisymm hs h
    subst this
    simp [hlab]
  · simp [hs]

/--
**The splice of two runs.** Follows `Rb` at every time `≤ t` and `Rf` at every time `≥ t`; the two
hypotheses say the runs occupy the same position at `t`, which is what makes the two descriptions
agree there.
-/
def splice (Rb Rf : G.LabRun) (t : ℤ) (hst : Rb.st t = Rf.st t) (hlab : Rb.lab t = Rf.lab t) :
    G.LabRun where
  st := spliceSt Rb Rf t
  lab := spliceLab Rb Rf t
  lab_sub := by
    intro s
    by_cases hs : s ≤ t
    · rw [spliceLab_le Rb Rf hs]; exact Rb.lab_sub s
    · rw [spliceLab_ge Rb Rf hlab (by omega)]; exact Rf.lab_sub s
  agrees := by
    intro s
    by_cases hs : s ≤ t
    · rw [spliceSt_le Rb Rf hs, spliceLab_le Rb Rf hs]; exact Rb.agrees s
    · rw [spliceSt_ge Rb Rf hst (by omega), spliceLab_ge Rb Rf hlab (by omega)]
      exact Rf.agrees s
  steps := by
    intro s
    by_cases hs : s + 1 ≤ t
    · rw [spliceSt_le Rb Rf (by omega), spliceSt_le Rb Rf hs]; exact Rb.steps s
    · rw [spliceSt_ge Rb Rf hst (by omega), spliceSt_ge Rb Rf hst (by omega)]
      exact Rf.steps s
  coherent := by
    intro s
    have hbot : PlusFormula.bot ∉ spliceLab Rb Rf t s := by
      by_cases hs : s ≤ t
      · rw [spliceLab_le Rb Rf hs]; exact (Rb.coherent s).1
      · rw [spliceLab_ge Rb Rf hlab (by omega)]; exact (Rf.coherent s).1
    have himp : ∀ a b : PlusFormula, PlusFormula.imp a b ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.imp a b ∈ spliceLab Rb Rf t s ↔
          (a ∈ spliceLab Rb Rf t s → b ∈ spliceLab Rb Rf t s)) := by
      by_cases hs : s ≤ t
      · rw [spliceLab_le Rb Rf hs]; exact (Rb.coherent s).2.1
      · rw [spliceLab_ge Rb Rf hlab (by omega)]; exact (Rf.coherent s).2.1
    have hbox : ∀ χ : PlusFormula, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.box χ ∈ spliceLab Rb Rf t s ↔ G.bx χ = true) := by
      by_cases hs : s ≤ t
      · rw [spliceLab_le Rb Rf hs]; exact (Rb.coherent s).2.2.1
      · rw [spliceLab_ge Rb Rf hlab (by omega)]; exact (Rf.coherent s).2.2.1
    have huntl : ∀ g e : PlusFormula, PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.untl g e ∈ spliceLab Rb Rf t s ↔
          (e ∈ spliceLab Rb Rf t (s + 1) ∨
            (g ∈ spliceLab Rb Rf t (s + 1) ∧
              PlusFormula.untl g e ∈ spliceLab Rb Rf t (s + 1)))) := by
      by_cases hs : s + 1 ≤ t
      · rw [spliceLab_le Rb Rf (by omega : s ≤ t), spliceLab_le Rb Rf hs]
        exact (Rb.coherent s).2.2.2.1
      · rw [spliceLab_ge Rb Rf hlab (by omega : t ≤ s),
          spliceLab_ge Rb Rf hlab (by omega : t ≤ s + 1)]
        exact (Rf.coherent s).2.2.2.1
    have hsnce : ∀ g e : PlusFormula, PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.snce g e ∈ spliceLab Rb Rf t s ↔
          (e ∈ spliceLab Rb Rf t (s - 1) ∨
            (g ∈ spliceLab Rb Rf t (s - 1) ∧
              PlusFormula.snce g e ∈ spliceLab Rb Rf t (s - 1)))) := by
      by_cases hs : s ≤ t
      · rw [spliceLab_le Rb Rf hs, spliceLab_le Rb Rf (by omega : s - 1 ≤ t)]
        exact (Rb.coherent s).2.2.2.2
      · rw [spliceLab_ge Rb Rf hlab (by omega : t ≤ s),
          spliceLab_ge Rb Rf hlab (by omega : t ≤ s - 1)]
        exact (Rf.coherent s).2.2.2.2
    exact ⟨hbot, himp, hbox, huntl, hsnce⟩

@[simp] theorem splice_lab (Rb Rf : G.LabRun) (t : ℤ) (hst : Rb.st t = Rf.st t)
    (hlab : Rb.lab t = Rf.lab t) : (splice Rb Rf t hst hlab).lab = spliceLab Rb Rf t := rfl

@[simp] theorem splice_st (Rb Rf : G.LabRun) (t : ℤ) (hst : Rb.st t = Rf.st t)
    (hlab : Rb.lab t = Rf.lab t) : (splice Rb Rf t hst hlab).st = spliceSt Rb Rf t := rfl

/-- **The splice occupies the shared position at the splice time.** -/
theorem splice_pos (Rb Rf : G.LabRun) (t : ℤ) (hst : Rb.st t = Rf.st t)
    (hlab : Rb.lab t = Rf.lab t) : (splice Rb Rf t hst hlab).pos t = Rb.pos t := by
  rw [LabRun.pos_eq_iff]
  exact ⟨spliceSt_le Rb Rf le_rfl, spliceLab_le Rb Rf le_rfl⟩

/-- **The splice inherits the forward half's `untl` fulfilment.** -/
theorem splice_fwdFulfilling (Rb Rf : G.LabRun) (t : ℤ) (hst : Rb.st t = Rf.st t)
    (hlab : Rb.lab t = Rf.lab t) (hf : PlusFwdFulfilling Rf.lab) :
    PlusFwdFulfilling (splice Rb Rf t hst hlab).lab := by
  set R := splice Rb Rf t hst hlab with hR
  refine plusFwdFulfilling_of_ge R.coherent R.lab_sub t ?_
  intro s hs g e hu
  rw [hR, splice_lab, spliceLab_ge Rb Rf hlab hs] at hu
  obtain ⟨r, hr1, hr2, hr3⟩ := hf s g e hu
  refine ⟨r, hr1, ?_, ?_⟩
  · rw [hR, splice_lab, spliceLab_ge Rb Rf hlab (by omega)]; exact hr2
  · intro q hq1 hq2
    rw [hR, splice_lab, spliceLab_ge Rb Rf hlab (by omega)]
    exact hr3 q hq1 hq2

/-- **The splice inherits the backward half's `snce` fulfilment.** -/
theorem splice_bwdFulfilling (Rb Rf : G.LabRun) (t : ℤ) (hst : Rb.st t = Rf.st t)
    (hlab : Rb.lab t = Rf.lab t) (hb : PlusBwdFulfilling Rb.lab) :
    PlusBwdFulfilling (splice Rb Rf t hst hlab).lab := by
  set R := splice Rb Rf t hst hlab with hR
  refine plusBwdFulfilling_of_le R.coherent R.lab_sub t ?_
  intro s hs g e hu
  rw [hR, splice_lab, spliceLab_le Rb Rf hs] at hu
  obtain ⟨r, hr1, hr2, hr3⟩ := hb s g e hu
  refine ⟨r, hr1, ?_, ?_⟩
  · rw [hR, splice_lab, spliceLab_le Rb Rf (by omega)]; exact hr2
  · intro q hq1 hq2
    rw [hR, splice_lab, spliceLab_le Rb Rf (by omega)]
    exact hr3 q hq1 hq2

end Splice

/-! ## The two directions of the characterization -/

/--
**The soundness direction.** Every position a fulfilling run occupies is live.
-/
theorem live_of_path (G : PlusSlicedCertificate Γ Del) (R : G.LabRun)
    (hf : PlusFulfillingSeqLab R.lab) (t : ℤ) : G.Live t (R.pos t) :=
  ⟨⟨R, hf.1, rfl⟩, ⟨R, hf.2, rfl⟩⟩

/--
**The completeness direction.** Every live position is occupied by a run discharging **both**
halves of fulfilment — built by splicing the backward witness into the forward one at `t`.

This is the label-level `stab_factors`: the two halves are computed independently and combined,
and this lemma is what licenses the combination.
-/
theorem exists_path_of_live (G : PlusSlicedCertificate Γ Del) {t : ℤ} {p : G.Pos}
    (h : G.Live t p) : ∃ R : G.LabRun, PlusFulfillingSeqLab R.lab ∧ R.pos t = p := by
  obtain ⟨⟨Rf, hff, hposf⟩, ⟨Rb, hbb, hposb⟩⟩ := h
  have hagree : Rb.pos t = Rf.pos t := hposb.trans hposf.symm
  obtain ⟨hst, hlab⟩ := (LabRun.pos_eq_iff Rb Rf t).mp hagree
  refine ⟨splice Rb Rf t hst hlab, ⟨?_, ?_⟩, ?_⟩
  · exact splice_fwdFulfilling Rb Rf t hst hlab hff
  · exact splice_bwdFulfilling Rb Rf t hst hlab hbb
  · rw [splice_pos Rb Rf t hst hlab]; exact hposb

/--
**Both directions, as one biconditional.** Phase 18 cites the `←` direction (a certified structure
supplies runs, hence live positions) and Phase 19 the `→` direction (a live position supplies a
run); neither has to re-derive the other.
-/
theorem live_iff (G : PlusSlicedCertificate Γ Del) (t : ℤ) (p : G.Pos) :
    G.Live t p ↔ ∃ R : G.LabRun, PlusFulfillingSeqLab R.lab ∧ R.pos t = p := by
  constructor
  · exact G.exists_path_of_live
  · rintro ⟨R, hf, hp⟩
    rw [← hp]
    exact G.live_of_path R hf t

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
