/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Stable

/-!
# The Decidable Checker for the Time-Sliced L⁺ Certificate

`Certifies` is the condition a time-sliced certificate must meet, and `decidableCertifies` is the
decision procedure for it. Nothing here is an assertion that the condition is decidable: every
clause is stated so that its quantifiers range over a `Finset` or a `Fintype`, and the instance is
*synthesized* from those clauses rather than postulated.

## The three structural conjuncts, each off a landed biconditional

`BiSerial`, `TailStable` and `BoxLabelFaithful` are conditions over **all** times; each is decided
on a window by a biconditional proved where the condition was defined:

* `biSerial_iff_window` (`Basic.lean`) reduces (C1) to the own window `[-|back|, |mid| + |fwd|)`;
* `tailStable_iff_window` / `tailStable_iff_window_fwd` (`Stable.lean`) are what make
  `TailStable` — already a pair of computed `Finset` equalities, hence already `Decidable` — a
  statement about liveness down both tails;
* `boxLabelFaithful_iff_window` (`Basic.lean`) reduces (C3b) to the same own window.

`Basic.lean` declares no `Decidable` instance at all, so the instances for (C1) and (C3b) are
written here, each through its own biconditional over a `Finset.Ico` of the **own** window — not the
combined window, since neither clause reads `G.target`.

**Why (C3b) is a structural conjunct and not merely a clause of the box group.** `Bridge.lean`'s
`live_of_mem_liveT`, `live_iff_mem_liveT` and `decidableLive` each take `hbox : G.BoxLabelFaithful`
as an explicit hypothesis, so the clause has to be *extractable from* `G.Certifies` or the soundness
direction cannot reach the bridge at all. Filing it inside the box group would be mathematically
equivalent; listing it beside `BiSerial` and `TailStable` is what makes the extraction a projection
rather than a dig through a nested conjunction.

## The existential side is stated on the position graph, not on the label sequence

The certificate's target path must be a genuine labelled path of `G`. The decidable way to say that
is **not** `PlusLocalCoherentSeqLab`, whose five clauses quantify over the closure under a shape
guard, nor `PlusFulfillingSeqLab`, whose two clauses are unbounded existentials over ℤ and are not
decidable at all. It is `TargetPathPos`: the target path's position lies in `G.posAt` at every time
and steps along `G.succP`. Those two `Finset` memberships are exactly `LabCoherent`,
`AgreesOnState`, `G.edge` and `StepClause`, which is to say exactly the four of the five
local-coherence clauses that are *local*; the fifth, the box clause, follows from (C3b) and
`AgreesOnState` together, by the same argument `Bridge.lean`'s `spliceWalkPos_coherent` makes.
`targetRun` is the `LabRun` the two assemble into.

Fulfilment is **not** demanded of the target path. It is supplied by liveness: `targetLive` asks
that the target path's position at `G.targetTime` lie in the computed `G.liveAt G.targetTime`, and
`Live.lean`'s `exists_path_of_live` turns that into a fulfilling run through the same position,
hence with the same label at `G.targetTime` — which is the only time the target clause reads. This
is the sense in which dropping the `witness` field costs the checker nothing.

## Liveness is read on the computed side, never on `Live`

`exists_path_of_live` is declarative and undecidable, so every clause below that mentions liveness
is written against `Stable.lean`'s computed `G.liveAt`, whose equality with `Live` at a window time
is `mem_liveAt_iff_live`. Writing a clause against `Live` directly would make `decidableCertifies`
unprovable, and that is the failure mode this module is organized to avoid. The biconditional is
cited for the mathematics and never for the computation.

## Nothing is aligned, and the one period-combining clause is folded by a named lemma

No clause mentions an alignment offset, a period product or an absolute origin: the slice time is
the only time there is. One clause does read `G.slice` and `G.target.datum` *together* at every
time — `TargetPathPos` — and that is a period-combining demand, not an alignment-offset one. It is
folded by `forall_iff_win_succ`, proved below from `Window.lean`'s combined periods: a named lemma,
not a `decide` that happens to typecheck. `forall_iff_win_succ` carries **one step of lookahead**,
which `Window.lean`'s `forall_iff_win` does not, because `succP` reads two consecutive slices; the
doubled window endpoints are what make the lookahead land inside the window on both tails.

## Declarations

- `boxArgs` / `stabArgs` with their membership lemmas — the reindexing that turns a shape-guarded
  quantifier `∀ χ, □χ ∈ closure → …` into a bounded one over a `Finset`
- `decidableBiSerial`, `decidableBoxLabelFaithful` — (C1) and (C3b), each through its own window
  biconditional
- `slice_sub_NB` / `target_datum_sub_NB` / `slice_add_NF` / `target_datum_add_NF` and
  `forall_iff_win_succ` — the combined-period shifts and the one-step-lookahead fold
- `targetPos`, `TargetPathPos`, `targetRun` — the existential side and the run it presents
- `StabFaithful` — the (C5) clause, a biconditional between the slice's `⊡`-content and the live
  positions over the state, carrying both the universal and the existential obligation
- `BoxLiveFaithful` — the box clause, on live positions rather than on the slice labelling; see its
  docstring for why `BoxFaithful` is not the clause a checker can use
- `Certifies` and `decidableCertifies`, with each structural conjunct's instance confirmed in
  isolation by an `example`

## Tags

plus-language · certificate · decidability · checker
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

variable {Γ Del : PlusContext}

/-! ## Bi-seriality at one slice is decidable -/

instance decidableBiSerialAt {n : ℕ} {C : Finset PlusFormula} (s : PlusSlice n C) :
    Decidable s.BiSerialAt := by
  unfold PlusSlice.BiSerialAt
  infer_instance

namespace PlusSlicedCertificate

/-! ## Reindexing the shape-guarded quantifiers

`BoxLabelFaithful` and the two clauses below it quantify over **all** `χ : PlusFormula` under the
guard `□χ ∈ closure`. That is not a bounded quantifier, and no instance resolves against it. These
two `Finset`s are the guard read as a domain: the arguments of the closure's `□`-formulas and of its
`⊡`-formulas.
-/

/-- **The arguments of the closure's `□`-formulas.** -/
def boxArgs (Γ Del : PlusContext) : Finset PlusFormula :=
  (plusClosureOf (Γ ++ Del)).biUnion fun ψ =>
    match ψ with
    | PlusFormula.box χ => {χ}
    | _ => (∅ : Finset PlusFormula)

theorem mem_boxArgs {Γ Del : PlusContext} {χ : PlusFormula} :
    χ ∈ boxArgs Γ Del ↔ PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) := by
  simp only [boxArgs, Finset.mem_biUnion]
  constructor
  · rintro ⟨ψ, hψ, hχ⟩
    cases ψ with
    | atom a => simp at hχ
    | bot => simp at hχ
    | imp a b => simp at hχ
    | box ξ =>
      rw [Finset.mem_singleton] at hχ
      subst hχ
      exact hψ
    | untl a b => simp at hχ
    | snce a b => simp at hχ
    | stab a => simp at hχ
  · intro h
    exact ⟨PlusFormula.box χ, h, Finset.mem_singleton_self χ⟩

/-- **The arguments of the closure's `⊡`-formulas.** -/
def stabArgs (Γ Del : PlusContext) : Finset PlusFormula :=
  (plusClosureOf (Γ ++ Del)).biUnion fun ψ =>
    match ψ with
    | PlusFormula.stab χ => {χ}
    | _ => (∅ : Finset PlusFormula)

theorem mem_stabArgs {Γ Del : PlusContext} {χ : PlusFormula} :
    χ ∈ stabArgs Γ Del ↔ PlusFormula.stab χ ∈ plusClosureOf (Γ ++ Del) := by
  simp only [stabArgs, Finset.mem_biUnion]
  constructor
  · rintro ⟨ψ, hψ, hχ⟩
    cases ψ with
    | atom a => simp at hχ
    | bot => simp at hχ
    | imp a b => simp at hχ
    | box a => simp at hχ
    | untl a b => simp at hχ
    | snce a b => simp at hχ
    | stab ξ =>
      rw [Finset.mem_singleton] at hχ
      subst hχ
      exact hψ
  · intro h
    exact ⟨PlusFormula.stab χ, h, Finset.mem_singleton_self χ⟩

/-! ## (C1) bi-seriality is decidable -/

/-- **(C1) on the own window is decidable**: finitely many times, finitely many states, a
`Bool`-valued edge. -/
instance decidableBiSerialWindow (G : PlusSlicedCertificate Γ Del) :
    Decidable G.BiSerialWindow :=
  decidable_of_iff (∀ t ∈ Finset.Ico (-G.nb) (G.nm + G.nf), (G.slice t).BiSerialAt) <| by
    constructor
    · intro h t h1 h2
      exact h t (Finset.mem_Ico.mpr ⟨h1, h2⟩)
    · intro h t ht
      exact h t (Finset.mem_Ico.mp ht).1 (Finset.mem_Ico.mp ht).2

/-- **(C1) is decidable**, through `biSerial_iff_window`. -/
instance decidableBiSerial (G : PlusSlicedCertificate Γ Del) : Decidable G.BiSerial :=
  decidable_of_iff G.BiSerialWindow G.biSerial_iff_window.symm

/-! ## (C3b) the box-label clause is decidable -/

/-- **(C3b) on the own window is decidable**, with the shape-guarded quantifier reindexed by
`boxArgs`. -/
instance decidableBoxLabelFaithfulWindow (G : PlusSlicedCertificate Γ Del) :
    Decidable G.BoxLabelFaithfulWindow :=
  decidable_of_iff
    (∀ χ ∈ boxArgs Γ Del, ∀ t ∈ Finset.Ico (-G.nb) (G.nm + G.nf), ∀ w : Fin G.n,
      (PlusFormula.box χ ∈ G.slab t w ↔ G.bx χ = true)) <| by
    constructor
    · intro h χ hχ t h1 h2 w
      exact h χ (mem_boxArgs.mpr hχ) t (Finset.mem_Ico.mpr ⟨h1, h2⟩) w
    · intro h χ hχ t ht w
      exact h χ (mem_boxArgs.mp hχ) t (Finset.mem_Ico.mp ht).1 (Finset.mem_Ico.mp ht).2 w

/-- **(C3b) is decidable**, through `boxLabelFaithful_iff_window`. -/
instance decidableBoxLabelFaithful (G : PlusSlicedCertificate Γ Del) :
    Decidable G.BoxLabelFaithful :=
  decidable_of_iff G.BoxLabelFaithfulWindow G.boxLabelFaithful_iff_window.symm

/-! ## The combined-period shifts

`Basic.lean`'s periodicity lemmas shift by the certificate's own periods, which move the slice
sequence and leave the target path's data behind. These four shift by the **combined** periods of
`Window.lean` and move both at once. Each is a residue computation, not an induction: the shift
changes the index by a multiple of the component period, and `Periodic.cyc` reads only the residue.
-/

/-- **The combined back shift, on the slice sequence.** -/
theorem slice_sub_NB (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : t < 0) :
    G.slice (t - G.NB) = G.slice t := by
  have hB := G.NB_pos
  rw [G.slice_neg (by omega : t - G.NB < 0), G.slice_neg ht]
  refine Periodic.cyc_congr (emod_eq_of_dvd_of_emod_eq G.nb_dvd_NB ?_)
  rw [show t - G.NB = t + (-1) * G.NB from by omega, Periodic.emod_add_mul]

/-- **The combined back shift, on the target path's data.** -/
theorem target_datum_sub_NB (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : t < 0) :
    G.target.datum (t - G.NB) = G.target.datum t := by
  have hB := G.NB_pos
  rw [G.target.datum_neg (by omega : t - G.NB < 0), G.target.datum_neg ht]
  refine @Periodic.cyc_congr _ G.target.inh _ _ _
    (emod_eq_of_dvd_of_emod_eq G.target_nb_dvd_NB ?_)
  rw [show t - G.NB = t + (-1) * G.NB from by omega, Periodic.emod_add_mul]

/-- **The combined forward shift, on the slice sequence.** -/
theorem slice_add_NF (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : G.nm ≤ t) :
    G.slice (t + G.NF) = G.slice t := by
  have hF := G.NF_pos
  rw [G.slice_fwd (by omega : G.nm ≤ t + G.NF), G.slice_fwd ht]
  refine Periodic.cyc_congr (emod_eq_of_dvd_of_emod_eq G.nf_dvd_NF ?_)
  rw [show t + G.NF - G.nm = (t - G.nm) + 1 * G.NF from by omega, Periodic.emod_add_mul]

/-- **The combined forward shift, on the target path's data.** -/
theorem target_datum_add_NF (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : G.target.nm ≤ t) :
    G.target.datum (t + G.NF) = G.target.datum t := by
  have hF := G.NF_pos
  rw [G.target.datum_fwd (by omega : G.target.nm ≤ t + G.NF), G.target.datum_fwd ht]
  refine @Periodic.cyc_congr _ G.target.inh _ _ _
    (emod_eq_of_dvd_of_emod_eq G.target_nf_dvd_NF ?_)
  rw [show t + G.NF - G.target.nm = (t - G.target.nm) + 1 * G.NF from by omega,
    Periodic.emod_add_mul]

/-! ## The fold with one step of lookahead

`Window.lean`'s `forall_iff_win` folds a predicate that reads the slice and the target datum at
**one** time. A clause that steps — `succP` reads the slice at `t` and at `t + 1` — needs the
predicate's invariance at a *pair* of consecutive times, and that is what this lemma asks for. The
doubled window endpoints are what make it provable: on the left tail the representative and its
successor are both still negative, and on the right tail both are still at or past `G.NM`, so each
shift stays inside the region where the periodicity it uses holds.
-/

/--
**A predicate invariant under the combined shift at a pair of consecutive times is decided on the
window.**

Proved by induction on the number of period shifts needed to bring a time into the window, one shift
at a time, so that each shift's side condition is discharged where it holds rather than at a
multiple of the period.
-/
theorem forall_iff_win_succ (G : PlusSlicedCertificate Γ Del) {P : ℤ → Prop}
    (hP : ∀ s t : ℤ, G.slice s = G.slice t → G.slice (s + 1) = G.slice (t + 1) →
      G.target.datum s = G.target.datum t → G.target.datum (s + 1) = G.target.datum (t + 1) →
      (P s ↔ P t)) :
    (∀ t : ℤ, P t) ↔ ∀ t ∈ G.winTimes, P t := by
  have hB := G.NB_pos
  have hF := G.NF_pos
  have hM := G.NM_nonneg
  have hnm := G.nm_le_NM
  have htnm := G.target_nm_le_NM
  have hLo : G.winLo = -2 * G.NB := rfl
  have hHi : G.winHi = G.NM + 2 * G.NF := rfl
  constructor
  · intro h t _
    exact h t
  · intro h
    -- The left tail: shift rightward by the combined back period, one period at a time.
    have left : ∀ k : ℕ, ∀ t : ℤ, G.winLo - (k : ℤ) ≤ t → t < G.winLo → P t := by
      intro k
      induction k with
      | zero =>
        intro t h1 h2
        exfalso
        push_cast at h1
        omega
      | succ k ih =>
        intro t h1 h2
        push_cast at h1
        -- `P (t + G.NB)` holds, either by the induction hypothesis or because it is in the window.
        have hnext : P (t + G.NB) := by
          by_cases hin : t + G.NB < G.winLo
          · exact ih (t + G.NB) (by omega) hin
          · refine h (t + G.NB) (G.mem_winTimes _ |>.mpr ⟨by omega, by omega⟩)
        -- Transport it back one period.
        refine (hP t (t + G.NB) ?_ ?_ ?_ ?_).mpr hnext
        · have e := G.slice_sub_NB (t := t + G.NB) (by omega)
          rwa [show t + G.NB - G.NB = t from by omega] at e
        · have e := G.slice_sub_NB (t := t + 1 + G.NB) (by omega)
          rw [show t + 1 + G.NB - G.NB = t + 1 from by omega] at e
          rwa [show t + 1 + G.NB = t + G.NB + 1 from by omega] at e
        · have e := G.target_datum_sub_NB (t := t + G.NB) (by omega)
          rwa [show t + G.NB - G.NB = t from by omega] at e
        · have e := G.target_datum_sub_NB (t := t + 1 + G.NB) (by omega)
          rw [show t + 1 + G.NB - G.NB = t + 1 from by omega] at e
          rwa [show t + 1 + G.NB = t + G.NB + 1 from by omega] at e
    -- The right tail: shift leftward by the combined forward period, one period at a time.
    have right : ∀ k : ℕ, ∀ t : ℤ, t < G.winHi + (k : ℤ) → G.winHi ≤ t → P t := by
      intro k
      induction k with
      | zero =>
        intro t h1 h2
        exfalso
        push_cast at h1
        omega
      | succ k ih =>
        intro t h1 h2
        push_cast at h1
        have hnext : P (t - G.NF) := by
          by_cases hin : G.winHi ≤ t - G.NF
          · exact ih (t - G.NF) (by omega) hin
          · refine h (t - G.NF) (G.mem_winTimes _ |>.mpr ⟨by omega, by omega⟩)
        refine (hP t (t - G.NF) ?_ ?_ ?_ ?_).mpr hnext
        · have e := G.slice_add_NF (t := t - G.NF) (by omega)
          rwa [show t - G.NF + G.NF = t from by omega] at e
        · have e := G.slice_add_NF (t := t - G.NF + 1) (by omega)
          rwa [show t - G.NF + 1 + G.NF = t + 1 from by omega] at e
        · have e := G.target_datum_add_NF (t := t - G.NF) (by omega)
          rwa [show t - G.NF + G.NF = t from by omega] at e
        · have e := G.target_datum_add_NF (t := t - G.NF + 1) (by omega)
          rwa [show t - G.NF + 1 + G.NF = t + 1 from by omega] at e
    intro t
    by_cases hlo : t < G.winLo
    · have hk : ((G.winLo - t).toNat : ℤ) = G.winLo - t := Int.toNat_of_nonneg (by omega)
      exact left (G.winLo - t).toNat t (by omega) hlo
    · by_cases hhi : G.winHi ≤ t
      · have hk : ((t - G.winHi + 1).toNat : ℤ) = t - G.winHi + 1 :=
          Int.toNat_of_nonneg (by omega)
        exact right (t - G.winHi + 1).toNat t (by omega) hhi
      · exact h t (G.mem_winTimes t |>.mpr ⟨by omega, by omega⟩)

/-! ## The existential side: the target path is a labelled path of `G` -/

/-- **The position the target path occupies at a time.** -/
def targetPos (G : PlusSlicedCertificate Γ Del) (t : ℤ) : G.Pos :=
  G.posOf G.target.lab (fun s => G.target.lab_sub s) G.target.st t

@[simp] theorem targetPos_fst (G : PlusSlicedCertificate Γ Del) (t : ℤ) :
    (G.targetPos t).1 = G.target.st t := rfl

@[simp] theorem targetPos_snd (G : PlusSlicedCertificate Γ Del) (t : ℤ) :
    (G.targetPos t).2.1 = G.target.lab t := rfl

/-- **The target path's position depends on the time only through the target path's data.** -/
theorem targetPos_congr (G : PlusSlicedCertificate Γ Del) {s t : ℤ}
    (h : G.target.datum s = G.target.datum t) : G.targetPos s = G.targetPos t := by
  have hst : G.target.st s = G.target.st t := by
    rw [PlusGraphPath.st, PlusGraphPath.st, h]
  have hlab : G.target.lab s = G.target.lab t := by
    rw [PlusGraphPath.lab, PlusGraphPath.lab, h]
  exact Prod.ext hst (Subtype.ext hlab)

/--
**The existential side's structural clause**: the target path occupies a position of its own slice
at every time, and steps along the one-step position graph.

This is `LabCoherent`, `AgreesOnState`, `G.edge` and `StepClause` all at once, read off two `Finset`
memberships. It is deliberately *not* `PlusLocalCoherentSeqLab`: see this module's header.
-/
def TargetPathPos (G : PlusSlicedCertificate Γ Del) : Prop :=
  ∀ t : ℤ, G.targetPos t ∈ G.posAt t ∧ G.targetPos (t + 1) ∈ G.succP t (G.targetPos t)

/-- **The existential side's structural clause is decided on the combined window**, by
`forall_iff_win_succ`. -/
instance decidableTargetPathPos (G : PlusSlicedCertificate Γ Del) : Decidable G.TargetPathPos :=
  decidable_of_iff
    (∀ t ∈ G.winTimes,
      G.targetPos t ∈ G.posAt t ∧ G.targetPos (t + 1) ∈ G.succP t (G.targetPos t))
    (G.forall_iff_win_succ
      (P := fun t => G.targetPos t ∈ G.posAt t ∧ G.targetPos (t + 1) ∈ G.succP t (G.targetPos t))
      (by
        intro s t h1 h2 h3 h4
        rw [G.targetPos_congr h3, G.targetPos_congr h4, G.posAt_congr h1,
          G.succP_congr h1 h2])).symm

/-! ### What the structural clause yields

The four local pieces, projected out one at a time, and then the `LabRun` they assemble into. The
box clause of local coherence is the one piece that is *not* local, and it comes from (C3b) together
with `AgreesOnState` — exactly the argument `Bridge.lean`'s `spliceWalkPos_coherent` makes for a
spliced pair of walks.
-/

theorem target_labCoherent (G : PlusSlicedCertificate Γ Del) (hp : G.TargetPathPos) (t : ℤ) :
    LabCoherent Γ Del (G.target.lab t) :=
  ((G.mem_posAt t (G.targetPos t)).mp (hp t).1).1

theorem target_agrees (G : PlusSlicedCertificate Γ Del) (hp : G.TargetPathPos) (t : ℤ) :
    G.AgreesOnState t (G.target.st t) (G.target.lab t) :=
  ((G.mem_posAt t (G.targetPos t)).mp (hp t).1).2

theorem target_edge (G : PlusSlicedCertificate Γ Del) (hp : G.TargetPathPos) (t : ℤ) :
    G.edge t (G.target.st t) (G.target.st (t + 1)) = true :=
  ((G.mem_succP t (G.targetPos t) (G.targetPos (t + 1))).mp (hp t).2).2.1

theorem target_stepClause (G : PlusSlicedCertificate Γ Del) (hp : G.TargetPathPos) (t : ℤ) :
    StepClause Γ Del (G.target.lab t) (G.target.lab (t + 1)) :=
  ((G.mem_succP t (G.targetPos t) (G.targetPos (t + 1))).mp (hp t).2).2.2

/-- **The five local-coherence clauses of the target path's labelling.** -/
theorem target_coherent (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hp : G.TargetPathPos) : PlusLocalCoherentSeqLab Γ Del G.bx G.target.lab := by
  intro t
  have hlab := G.target_labCoherent hp t
  have hagr := G.target_agrees hp t
  refine ⟨hlab.1, ?_, ?_, ?_, ?_⟩
  · intro a b hab
    have hc := hlab.2 _ hab
    simp only [impClauseAt, decide_eq_true_eq] at hc
    exact hc
  · intro χ hχ
    have hst : IsStateShape (PlusFormula.box χ) = true := rfl
    exact (hagr (PlusFormula.box χ) hχ hst).trans (hbox χ hχ t _)
  · intro g e hge
    have hc := (G.target_stepClause hp t).1 _ hge
    simp only [untlClauseAt, decide_eq_true_eq] at hc
    exact hc
  · intro g e hge
    have hc := (G.target_stepClause hp (t - 1)).2 _ hge
    rw [show t - 1 + 1 = t from by omega] at hc
    simp only [snceClauseAt, decide_eq_true_eq] at hc
    exact hc

/-- **The run the target path presents.** -/
def targetRun (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hp : G.TargetPathPos) : G.LabRun where
  st := G.target.st
  lab := G.target.lab
  lab_sub := fun s => G.target.lab_sub s
  agrees := G.target_agrees hp
  steps := G.target_edge hp
  coherent := G.target_coherent hbox hp

@[simp] theorem targetRun_lab (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hp : G.TargetPathPos) (t : ℤ) : (G.targetRun hbox hp).lab t = G.target.lab t := rfl

@[simp] theorem targetRun_st (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hp : G.TargetPathPos) (t : ℤ) : (G.targetRun hbox hp).st t = G.target.st t := rfl

theorem targetRun_pos (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hp : G.TargetPathPos) (t : ℤ) : (G.targetRun hbox hp).pos t = G.targetPos t :=
  Prod.ext rfl (Subtype.ext rfl)

/-! ## The (C5) clause: the slice's `⊡`-content against the live positions over a state -/

/--
**(C5) `StabFaithful`**: a slice labels `⊡χ` at a state exactly when **no** live position over that
state omits `χ`.

The biconditional carries both obligations the plan separates. Read `→`, it is the **universal**
side: every live position over a state whose slice labels `⊡χ` carries `χ`. Read `←`, it is the
**existential** side, and it is what pays for the dropped `witness` field: when the slice does not
label `⊡χ`, some live position over that state omits `χ`, and `exists_path_of_live` turns that
position into a genuine labelled path. No witness path has to be carried, because the computed live
set already knows which positions are occupied.

Stated on the combined window's times, and on the **computed** `G.liveAt` rather than on `Live`:
`mem_liveAt_iff_live` is the equality between the two at a window time, cited for the mathematics
and never for the computation. Under tail-stability the window's verdict extends to every time,
which is `tailStable_iff_window`'s business and not this clause's.
-/
def StabFaithful (G : PlusSlicedCertificate Γ Del) : Prop :=
  ∀ t ∈ G.winTimes, ∀ (w : Fin G.n) (χ : PlusFormula),
    PlusFormula.stab χ ∈ plusClosureOf (Γ ++ Del) →
      (PlusFormula.stab χ ∈ G.slab t w ↔ ∀ p ∈ G.liveAt t, p.1 = w → χ ∈ p.2.1)

instance decidableStabFaithful (G : PlusSlicedCertificate Γ Del) : Decidable G.StabFaithful :=
  decidable_of_iff
    (∀ t ∈ G.winTimes, ∀ (w : Fin G.n), ∀ χ ∈ stabArgs Γ Del,
      (PlusFormula.stab χ ∈ G.slab t w ↔ ∀ p ∈ G.liveAt t, p.1 = w → χ ∈ p.2.1)) <| by
    constructor
    · intro h t ht w χ hχ
      exact h t ht w χ (mem_stabArgs.mpr hχ)
    · intro h t ht w χ hχ
      exact h t ht w χ (mem_stabArgs.mp hχ)

/-! ## The box clause -/

/--
**The box clause**: the box guess reports `χ` exactly when every live position of every window slice
carries `χ`.

**Why this and not (C3) `BoxFaithful`.** `BoxFaithful` relates `G.bx χ` to `χ ∈ G.slab t w`, and
that is the wrong object for a general `χ`. The slice labelling is pinned to truth only on the
**state shapes** — `AgreesOnState` constrains atoms, `□`-formulas and `⊡`-formulas and nothing else
— so for a `χ` of any other shape `χ ∈ G.slab t w` is unconstrained data, and a demand stated
against it would neither follow from nor imply `χ`'s holding at the carrier element. A position's
label *is* pinned to truth at every shape, by the truth lemma the soundness direction proves, so
liveness is the object a box clause has to read. `BoxFaithful` stays in `Basic.lean`, where it
records (C3)'s shape, and is not a conjunct of `Certifies`.

By `plusBox_const` the truth of `□χ` is independent of both history and time, so "every live
position carries `χ`" is exactly what a global modality's guess must report; by the periodicity
lemmas the window suffices.
-/
def BoxLiveFaithful (G : PlusSlicedCertificate Γ Del) : Prop :=
  ∀ χ : PlusFormula, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) →
    (G.bx χ = true ↔ ∀ t ∈ G.winTimes, ∀ p ∈ G.liveAt t, χ ∈ p.2.1)

instance decidableBoxLiveFaithful (G : PlusSlicedCertificate Γ Del) :
    Decidable G.BoxLiveFaithful :=
  decidable_of_iff
    (∀ χ ∈ boxArgs Γ Del, (G.bx χ = true ↔ ∀ t ∈ G.winTimes, ∀ p ∈ G.liveAt t, χ ∈ p.2.1)) <| by
    constructor
    · intro h χ hχ
      exact h χ (mem_boxArgs.mpr hχ)
    · intro h χ hχ
      exact h χ (mem_boxArgs.mp hχ)

/-! ## (C4) the target clause is decidable

`Target` is a pair of bounded quantifiers over the two contexts, which are `List`s; the instance
needs only that `Target` be unfolded so that resolution can see them.
-/

instance decidableTarget (G : PlusSlicedCertificate Γ Del) : Decidable G.Target := by
  unfold Target
  infer_instance

/-! ## The checker -/

/--
**The condition the checker decides.**

Three structural conjuncts, then the target group. Reading them in order:

1. `BiSerial` — (C1), the frame construction's seriality obligation in both directions.
2. `TailStable` — the wrap-faithfulness demand, so that the window's liveness verdict is the
   verdict at every time. Its forward conjunct is the **liveness-filtered** transfer
   `Φ_fwd R₀ ∩ R₀fwd = R₀`; nothing here reads that conjunct's internal shape.
3. `BoxLabelFaithful` — (C3b), which the bridge takes as an explicit hypothesis and which therefore
   has to be projectable out of this conjunction.
4. `targetTime ∈ winTimes` — the target is read at a window time. See the note below.
5. `TargetPathPos` — the target path is a labelled path of `G`, stated on the position graph.
6. `targetPos targetTime ∈ liveAt targetTime` — some fulfilling run passes through the target
   path's position at the target time. This replaces the dropped `witness` field.
7. `StabFaithful` — (C5), carrying both the universal and the existential `⊡`-obligation.
8. `BoxLiveFaithful` — the box clause, on live positions.
9. `Target` — (C4), the premises in and the conclusions out of the target label.

**Why `targetTime ∈ winTimes` is a clause.** Liveness is not a function of the slice
(`Fixture.live_not_determined_by_slice`), so the computed live set is available at window times
only, and `targetTime` is an unconstrained field of the structure. Demanding that it be a window
time is the cheapest honest way to make clause 6 computable; it narrows the class not at all, since
the origin `0` is always a window time and any presentation can be read with its target there.
-/
def Certifies (G : PlusSlicedCertificate Γ Del) : Prop :=
  G.BiSerial ∧ G.TailStable ∧ G.BoxLabelFaithful ∧
    G.targetTime ∈ G.winTimes ∧ G.TargetPathPos ∧
    G.targetPos G.targetTime ∈ G.liveAt G.targetTime ∧
    G.StabFaithful ∧ G.BoxLiveFaithful ∧ G.Target

/-- **The checker.** Synthesized from the clauses, not postulated. -/
instance decidableCertifies (G : PlusSlicedCertificate Γ Del) : Decidable G.Certifies := by
  unfold Certifies
  infer_instance

/-! ### The instances, confirmed in isolation

Each structural conjunct is confirmed separately, so that a failure is localized to the conjunct
that caused it rather than reported as "`Certifies` is not decidable".
-/

example (G : PlusSlicedCertificate Γ Del) : Decidable G.BiSerial := inferInstance

example (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStable := inferInstance

example (G : PlusSlicedCertificate Γ Del) : Decidable G.BoxLabelFaithful := inferInstance

example (G : PlusSlicedCertificate Γ Del) : Decidable G.TargetPathPos := inferInstance

example (G : PlusSlicedCertificate Γ Del) : Decidable G.StabFaithful := inferInstance

example (G : PlusSlicedCertificate Γ Del) : Decidable G.BoxLiveFaithful := inferInstance

example (G : PlusSlicedCertificate Γ Del) : Decidable G.Target := inferInstance

example (G : PlusSlicedCertificate Γ Del) : Decidable G.Certifies := inferInstance

/-! ### The clauses the structural conjuncts project to -/

theorem biSerial_of_certifies (G : PlusSlicedCertificate Γ Del) (h : G.Certifies) : G.BiSerial :=
  h.1

theorem tailStable_of_certifies (G : PlusSlicedCertificate Γ Del) (h : G.Certifies) :
    G.TailStable := h.2.1

theorem boxLabelFaithful_of_certifies (G : PlusSlicedCertificate Γ Del) (h : G.Certifies) :
    G.BoxLabelFaithful := h.2.2.1

theorem targetTime_mem_winTimes_of_certifies (G : PlusSlicedCertificate Γ Del)
    (h : G.Certifies) : G.targetTime ∈ G.winTimes := h.2.2.2.1

theorem targetPathPos_of_certifies (G : PlusSlicedCertificate Γ Del) (h : G.Certifies) :
    G.TargetPathPos := h.2.2.2.2.1

theorem targetLive_of_certifies (G : PlusSlicedCertificate Γ Del) (h : G.Certifies) :
    G.targetPos G.targetTime ∈ G.liveAt G.targetTime := h.2.2.2.2.2.1

theorem stabFaithful_of_certifies (G : PlusSlicedCertificate Γ Del) (h : G.Certifies) :
    G.StabFaithful := h.2.2.2.2.2.2.1

theorem boxLiveFaithful_of_certifies (G : PlusSlicedCertificate Γ Del) (h : G.Certifies) :
    G.BoxLiveFaithful := h.2.2.2.2.2.2.2.1

theorem target_of_certifies (G : PlusSlicedCertificate Γ Del) (h : G.Certifies) : G.Target :=
  h.2.2.2.2.2.2.2.2

/-- **The fulfilling run the target clause is read along.**

The payoff of clause 6: the target path's position at the target time is live, so some run occupies
it and discharges every eventuality in both directions. Its label at `G.targetTime` is the target
path's own, which is the only label the target clause reads.
-/
theorem exists_fulfilling_run_at_targetTime (G : PlusSlicedCertificate Γ Del) (h : G.Certifies) :
    ∃ R : G.LabRun, PlusFulfillingSeqLab R.lab ∧
      R.lab G.targetTime = G.target.lab G.targetTime := by
  obtain ⟨R, hf, hpos⟩ := G.exists_path_of_live
    (G.live_of_mem_liveAt (G.boxLabelFaithful_of_certifies h)
      (G.targetTime_mem_winTimes_of_certifies h) (G.targetLive_of_certifies h))
  refine ⟨R, hf, ?_⟩
  have := congrArg (fun p => (p.2 : Finset PlusFormula)) hpos
  simpa using this

/-! ## Running the checker on a concrete certificate

A checker that type-checks is not yet a checker that runs, so the certificate below is **evaluated**
rather than described. It is the finite-graph special case `onePointCertificate` exhibits, at the
empty context: one state, one self-edge, an empty closure, a constant target path, and the target
read at the origin. Each of the nine clauses and `Certifies` itself is a separate `#guard`, so a
failure names the clause that caused it.
-/

namespace Probe

/-- The empty context's closure is empty, which is what makes every closure-guarded clause vacuous
at this certificate. Stated rather than assumed. -/
theorem closure_empty :
    plusClosureOf (([] : PlusContext) ++ ([] : PlusContext)) = (∅ : Finset PlusFormula) := rfl

/-- **The one-state slice**: a single self-edge, no labels. -/
def slice1 : PlusSlice 1 (plusClosureOf (([] : PlusContext) ++ ([] : PlusContext))) where
  edge := fun _ _ => true
  lab := fun _ => ∅
  lab_sub := fun _ => Finset.empty_subset _

/-- **The constant target path** on the one-state slice. -/
def path1 : PlusGraphPath 1 (plusClosureOf (([] : PlusContext) ++ ([] : PlusContext))) where
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

/-- **The one-slice certificate at the empty context.** -/
def triv : PlusSlicedCertificate ([] : PlusContext) ([] : PlusContext) :=
  onePointCertificate [] [] Nat.one_pos slice1 (fun _ => false) path1 0

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard decide triv.BiSerial

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard decide triv.TailStable

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard decide triv.BoxLabelFaithful

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard decide (triv.targetTime ∈ triv.winTimes)

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard decide triv.TargetPathPos

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard decide (triv.targetPos triv.targetTime ∈ triv.liveAt triv.targetTime)

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard decide triv.StabFaithful

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard decide triv.BoxLiveFaithful

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard decide triv.Target

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard decide triv.Certifies

end Probe

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
