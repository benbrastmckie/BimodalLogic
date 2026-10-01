/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Unroll
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.LiveFix
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Live

/-!
# The Bridge: the Computed Liveness `Finset` Computes Declarative Liveness

`Live.lean` defines liveness declaratively — a position is live at a time when some bi-infinite
labelled run of the certificate occupies it and discharges every eventuality. `LiveFix.lean`
computes a `Finset` of timed positions by a nested greatest fixpoint on a finite window. This module
proves the two describe the same positions, and it is what makes a decidable checker possible: the
declarative form quantifies over runs of an infinite structure and is not decidable on its face,
while `Finset` membership is.

## The bridge is stated at a window time, and that is not a weakening

`G.liveT` lives on `verts`, whose times are the window times, so a statement of the form
`G.Live t p ↔ (p, s) ∈ G.liveT` needs a single window time `s` from which **both** half-line
readouts are available: `FoldF s t` for the forward walk and `FoldB s t` for the backward one. Those
two relations are disjoint away from the diagonal — `FoldF` holds only between times at or past
`G.NM`, `FoldB` only between negative times — so at a general `t` there is no such common `s`, and
the biconditional as the plan states it is not provable at a general `t`. At a window time it is
provable, because there both folds hold reflexively, and that is exactly the form a checker
evaluates: `winTimes` is the finite set it iterates over.

`exists_foldF` / `exists_foldB` are therefore not what supply the bridge's time. They remain what
`Unroll.lean` uses internally to read a walk at genuine times; here the time is a window time by
hypothesis, and reflexivity of both folds is what makes the two half-lines meet.

## The soundness direction does not factor into halves, and the completeness direction does

The **completeness** direction splits cleanly: `G.FwdLive s p → (p, s) ∈ G.fwdLiveT` and
`G.BwdLive s p → (p, s) ∈ G.bwdLiveT` are independent, each proved by handing
`fwdLiveT_greatest` / `bwdLiveT_greatest` the run's own visited timed positions as a
post-fixpoint.

The **soundness** direction does not. `G.FwdLive s p` demands a `LabRun`, which is bi-infinite;
membership in `G.fwdLiveT` yields a forward walk and says nothing at all about the past, and
`succP`-totality fails (see `Position.lean`), so no seriality argument recovers a backward half.
Both halves of `G.liveT` are therefore consumed together, and what comes out is `G.Live`, not a
separate forward statement. There is no `fwdLive_iff_mem_fwdLiveT` below, deliberately: it would be
false as stated, and asserting it would hand Phase 18 a lemma it cannot use.

## What the box clause costs, and why it is a clause

A walk carries labels that agree with the slice labelling on the state shapes and satisfy the
one-step temporal clauses. `PlusLocalCoherentSeqLab` demands one further thing no walk knows:
`box χ ∈ lab t ↔ G.bx χ = true`. `AgreesOnState` reduces it to
`box χ ∈ G.slab t w ↔ G.bx χ = true`, which is (C3b) `BoxLabelFaithful` and is a hypothesis of
every soundness statement below. (C3) `BoxFaithful` does not give it: (C3) constrains `G.bx χ`
against the subformula `χ`, not against the boxed formula `box χ`. See `Basic.lean`'s
`BoxLabelFaithful` for why the clause narrows the certificate class away from no certificate a
genuine countermodel presents.

## Main definitions

- `PlusSlicedCertificate.fwdOrbit` / `bwdOrbit` — the window times a wrapped walk visits
- `PlusSlicedCertificate.fwdVert` / `bwdVert` — a run's own timed positions, folded into the window
- `PlusSlicedCertificate.spliceWalkPos` — the position-level splice of a forward and a backward walk
- `PlusSlicedCertificate.runOfWalks` — the `LabRun` a spliced pair of walks presents

## Main results

- `PlusSlicedCertificate.mem_fwdLiveT_of_fwdLive` / `mem_bwdLiveT_of_bwdLive` — the two halves of
  the completeness direction, independent of each other and of (C3b)
- `PlusSlicedCertificate.mem_liveT_of_live` — the completeness direction
- `PlusSlicedCertificate.live_of_mem_liveT` — the soundness direction, by splicing
- `PlusSlicedCertificate.live_iff_mem_liveT` — **the bridge**
- `PlusSlicedCertificate.decidableLive` — liveness at a window time is decidable, which is the
  whole point

## Tags

plus-language · certificate · time-sliced · liveness · bridge · decidable
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## The folded orbit of a genuine half-line

A run lives on all of `ℤ`; the timed graph lives on `winTimes`. These two iterations are the
translation in the direction `Unroll.lean` does not cover: from a genuine time forward (resp.
backward), reading off the window time the graph would be at.
-/

/-- **The window time reached from `s` by `k` forward wraps.** -/
def fwdOrbit (G : PlusSlicedCertificate Γ Del) (s : ℤ) : ℕ → ℤ
  | 0 => s
  | k + 1 => G.nextTime (G.fwdOrbit s k)

/-- **The window time reached from `s` by `k` backward wraps.** -/
def bwdOrbit (G : PlusSlicedCertificate Γ Del) (s : ℤ) : ℕ → ℤ
  | 0 => s
  | k + 1 => G.prevTime (G.bwdOrbit s k)

@[simp] theorem fwdOrbit_zero (G : PlusSlicedCertificate Γ Del) (s : ℤ) :
    G.fwdOrbit s 0 = s := rfl

@[simp] theorem fwdOrbit_succ (G : PlusSlicedCertificate Γ Del) (s : ℤ) (k : ℕ) :
    G.fwdOrbit s (k + 1) = G.nextTime (G.fwdOrbit s k) := rfl

@[simp] theorem bwdOrbit_zero (G : PlusSlicedCertificate Γ Del) (s : ℤ) :
    G.bwdOrbit s 0 = s := rfl

@[simp] theorem bwdOrbit_succ (G : PlusSlicedCertificate Γ Del) (s : ℤ) (k : ℕ) :
    G.bwdOrbit s (k + 1) = G.prevTime (G.bwdOrbit s k) := rfl

/-- **The forward orbit never leaves the window.** -/
theorem fwdOrbit_mem (G : PlusSlicedCertificate Γ Del) {s : ℤ} (hs : s ∈ G.winTimes) :
    ∀ k : ℕ, G.fwdOrbit s k ∈ G.winTimes := by
  intro k
  induction k with
  | zero => simpa using hs
  | succ j ih => rw [fwdOrbit_succ]; exact G.nextTime_mem ih

/-- **The backward orbit never leaves the window.** -/
theorem bwdOrbit_mem (G : PlusSlicedCertificate Γ Del) {s : ℤ} (hs : s ∈ G.winTimes) :
    ∀ k : ℕ, G.bwdOrbit s k ∈ G.winTimes := by
  intro k
  induction k with
  | zero => simpa using hs
  | succ j ih => rw [bwdOrbit_succ]; exact G.prevTime_mem ih

/-- **Each forward orbit time is a fold of the genuine time it stands for.** The same induction as
`fwdWalk_foldF`, run on the orbit rather than on a walk. -/
theorem foldF_fwdOrbit (G : PlusSlicedCertificate Γ Del) {s : ℤ} (hs : s ∈ G.winTimes) :
    ∀ k : ℕ, G.FoldF (G.fwdOrbit s k) (s + (k : ℤ)) := by
  intro k
  induction k with
  | zero => simpa using G.foldF_refl s
  | succ j ih =>
      have h2 : G.FoldF (G.fwdOrbit s j + 1) (s + (j : ℤ) + 1) := foldF_succ ih
      have h3 : G.FoldF (G.nextTime (G.fwdOrbit s j)) (G.fwdOrbit s j + 1) :=
        G.foldF_nextTime (G.fwdOrbit_mem hs j)
      rw [fwdOrbit_succ, show s + ((j + 1 : ℕ) : ℤ) = s + (j : ℤ) + 1 from by omega]
      exact foldF_trans h3 h2

/-- **Each backward orbit time is a fold of the genuine time it stands for.** -/
theorem foldB_bwdOrbit (G : PlusSlicedCertificate Γ Del) {s : ℤ} (hs : s ∈ G.winTimes) :
    ∀ k : ℕ, G.FoldB (G.bwdOrbit s k) (s - (k : ℤ)) := by
  intro k
  induction k with
  | zero => simpa using G.foldB_refl s
  | succ j ih =>
      have h2 : G.FoldB (G.bwdOrbit s j - 1) (s - (j : ℤ) - 1) := foldB_pred ih
      have h3 : G.FoldB (G.prevTime (G.bwdOrbit s j)) (G.bwdOrbit s j - 1) :=
        G.foldB_prevTime (G.bwdOrbit_mem hs j)
      rw [bwdOrbit_succ, show s - ((j + 1 : ℕ) : ℤ) = s - (j : ℤ) - 1 from by omega]
      exact foldB_trans h3 h2

/-! ## A run's own timed positions

The post-fixpoint the completeness direction hands to `fwdLiveT_greatest` is built from these: the
position the run occupies at a genuine time, tagged with the window time the graph would be at.
-/

/-- **The timed position a run occupies `k` steps forward of a window time.** -/
def fwdVert (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) (s : ℤ) (k : ℕ) : G.TPos :=
  (R.pos (s + (k : ℤ)), G.fwdOrbit s k)

/-- **The timed position a run occupies `k` steps backward of a window time.** -/
def bwdVert (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) (s : ℤ) (k : ℕ) : G.TPos :=
  (R.pos (s - (k : ℤ)), G.bwdOrbit s k)

@[simp] theorem fwdVert_lab (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) (s : ℤ) (k : ℕ) :
    (G.fwdVert R s k).1.2.1 = R.lab (s + (k : ℤ)) := rfl

@[simp] theorem bwdVert_lab (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) (s : ℤ) (k : ℕ) :
    (G.bwdVert R s k).1.2.1 = R.lab (s - (k : ℤ)) := rfl

@[simp] theorem fwdVert_snd (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) (s : ℤ) (k : ℕ) :
    (G.fwdVert R s k).2 = G.fwdOrbit s k := rfl

@[simp] theorem bwdVert_snd (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) (s : ℤ) (k : ℕ) :
    (G.bwdVert R s k).2 = G.bwdOrbit s k := rfl

/-- **A run's forward vertices are vertices of the timed graph.** -/
theorem fwdVert_mem_verts (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) {s : ℤ}
    (hs : s ∈ G.winTimes) (k : ℕ) : G.fwdVert R s k ∈ G.verts := by
  rw [G.mem_verts]
  refine ⟨by simpa using G.fwdOrbit_mem hs k, ?_⟩
  have h := R.pos_mem_posAt (s + (k : ℤ))
  simpa [fwdVert, G.foldF_posAt (G.foldF_fwdOrbit hs k)] using h

/-- **A run's backward vertices are vertices of the timed graph.** -/
theorem bwdVert_mem_verts (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) {s : ℤ}
    (hs : s ∈ G.winTimes) (k : ℕ) : G.bwdVert R s k ∈ G.verts := by
  rw [G.mem_verts]
  refine ⟨by simpa using G.bwdOrbit_mem hs k, ?_⟩
  have h := R.pos_mem_posAt (s - (k : ℤ))
  simpa [bwdVert, G.foldB_posAt (G.foldB_bwdOrbit hs k)] using h

/-- **A run's forward vertices step along `succT`.** The wrap is invisible to the run: the edge is
read at the genuine time and transported by `foldF_succP`. -/
theorem fwdVert_mem_succT (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) {s : ℤ}
    (hs : s ∈ G.winTimes) (k : ℕ) :
    G.fwdVert R s (k + 1) ∈ G.succT (G.fwdVert R s k) := by
  rw [G.mem_succT]
  refine ⟨G.fwdVert_mem_verts R hs (k + 1), by simp [fwdVert], ?_⟩
  have hcast : s + ((k + 1 : ℕ) : ℤ) = s + (k : ℤ) + 1 := by omega
  simp only [fwdVert, hcast, G.foldF_succP (G.foldF_fwdOrbit hs k)]
  exact R.pos_mem_succP (s + (k : ℤ))

/-- **A run's backward vertices step along `predT`.** -/
theorem bwdVert_mem_predT (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) {s : ℤ}
    (hs : s ∈ G.winTimes) (k : ℕ) :
    G.bwdVert R s (k + 1) ∈ G.predT (G.bwdVert R s k) := by
  rw [G.mem_predT]
  refine ⟨G.bwdVert_mem_verts R hs (k + 1), by simp [bwdVert], ?_⟩
  have hcast : s - ((k + 1 : ℕ) : ℤ) = s - (k : ℤ) - 1 := by omega
  have hstep := R.pos_mem_predP (s - (k : ℤ) - 1)
  rw [show s - (k : ℤ) - 1 + 1 = s - (k : ℤ) from by omega] at hstep
  simp only [bwdVert, hcast, G.foldB_predP (G.foldB_bwdOrbit hs k)]
  exact hstep

/-! ## A run's own timed positions at a folded time

`fwdVert` reads the run at the window time itself. The forward half of the bridge has to be
available at the **folded** times a window time stands for as well — at `G.NM + G.NF + k * G.NF` and
not only at `G.NM + G.NF` — because the forward demand of tail-stability is read against the
computed forward-live set at the reference time while the liveness it has to capture sits
arbitrarily far down the periodic right tail. The generalization is free: nothing in the forward
construction looks at the run's time except through `FoldF`, and `FoldF` is transitive.
-/

/-- **The timed position a run occupies `k` steps forward of a genuine time `s'`**, tagged with the
window time the graph would be at after `k` forward wraps from a `FoldF`-equivalent window time `s`.
`fwdVert` is the diagonal case `s' = s`. -/
def fwdVertFold (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) (s s' : ℤ) (k : ℕ) : G.TPos :=
  (R.pos (s' + (k : ℤ)), G.fwdOrbit s k)

@[simp] theorem fwdVertFold_lab (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) (s s' : ℤ)
    (k : ℕ) : (G.fwdVertFold R s s' k).1.2.1 = R.lab (s' + (k : ℤ)) := rfl

@[simp] theorem fwdVertFold_snd (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) (s s' : ℤ)
    (k : ℕ) : (G.fwdVertFold R s s' k).2 = G.fwdOrbit s k := rfl

/-- **`fwdVert` is the diagonal case**, so nothing below duplicates it. -/
theorem fwdVertFold_self (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) (s : ℤ) (k : ℕ) :
    G.fwdVertFold R s s k = G.fwdVert R s k := rfl

/-- **The forward fold relation is closed under adding a common natural number.** -/
theorem foldF_add_nat (G : PlusSlicedCertificate Γ Del) {a b : ℤ} (h : G.FoldF a b) (k : ℕ) :
    G.FoldF (a + (k : ℤ)) (b + (k : ℤ)) := by
  induction k with
  | zero => simpa using h
  | succ j ih =>
      rw [show a + ((j + 1 : ℕ) : ℤ) = a + (j : ℤ) + 1 from by push_cast; omega,
        show b + ((j + 1 : ℕ) : ℤ) = b + (j : ℤ) + 1 from by push_cast; omega]
      exact foldF_succ ih

/-- **Each forward orbit time is a fold of the genuine time the folded run is read at.** -/
theorem foldF_fwdOrbit_fold (G : PlusSlicedCertificate Γ Del) {s s' : ℤ} (hs : s ∈ G.winTimes)
    (hfold : G.FoldF s s') (k : ℕ) : G.FoldF (G.fwdOrbit s k) (s' + (k : ℤ)) :=
  foldF_trans (G.foldF_fwdOrbit hs k) (G.foldF_add_nat hfold k)

/-- **A folded run's forward vertices are vertices of the timed graph.** -/
theorem fwdVertFold_mem_verts (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) {s s' : ℤ}
    (hs : s ∈ G.winTimes) (hfold : G.FoldF s s') (k : ℕ) :
    G.fwdVertFold R s s' k ∈ G.verts := by
  rw [G.mem_verts]
  refine ⟨by simpa using G.fwdOrbit_mem hs k, ?_⟩
  have h := R.pos_mem_posAt (s' + (k : ℤ))
  simpa [fwdVertFold, G.foldF_posAt (G.foldF_fwdOrbit_fold hs hfold k)] using h

/-- **A folded run's forward vertices step along `succT`.** -/
theorem fwdVertFold_mem_succT (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) {s s' : ℤ}
    (hs : s ∈ G.winTimes) (hfold : G.FoldF s s') (k : ℕ) :
    G.fwdVertFold R s s' (k + 1) ∈ G.succT (G.fwdVertFold R s s' k) := by
  rw [G.mem_succT]
  refine ⟨G.fwdVertFold_mem_verts R hs hfold (k + 1), by simp [fwdVertFold], ?_⟩
  have hcast : s' + ((k + 1 : ℕ) : ℤ) = s' + (k : ℤ) + 1 := by push_cast; omega
  simp only [fwdVertFold, hcast, G.foldF_succP (G.foldF_fwdOrbit_fold hs hfold k)]
  exact R.pos_mem_succP (s' + (k : ℤ))

/-! ## The completeness direction

Each half hands the fixpoint's own coinduction principle the run's visited vertices. The `untl`
clause is where the run's fulfilment enters: the discharging segment is a segment *of the run*, so
it never leaves the set, which is precisely what the relativized inner reachability demands.
-/

/--
**A forward-live position at a folded time is in the computed forward fixpoint at the window time it
folds to.**

The generalization of `mem_fwdLiveT_of_fwdLive` that the forward half of tail-stability needs: the
run may be read at any `s'` with `G.FoldF s s'`, and not only at the window time `s` itself.
`FoldF`-equivalent times carry the same slice, hence the same positions and the same one-step graph,
and the run's own `untl` fulfilment is a property of the run rather than of where the window is. So
the construction is the original one with the run read at `s'` and the orbit walked from `s`, and
`mem_fwdLiveT_of_fwdLive` becomes its diagonal instance.

**Why there is no backward counterpart.** `FoldB` relates two *negative* times, so it does not
relate the right-tail times `G.NM + G.NF + k * G.NF` at all, and a backward walk out of such a time
leaves the right tail after finitely many steps. That asymmetry is the reason the repaired
forward conjunct of `TailStable` filters by the **forward** computed liveness and not by `liveAt`.
-/
theorem mem_fwdLiveT_of_fwdLive_fold (G : PlusSlicedCertificate Γ Del) {s s' : ℤ}
    (hs : s ∈ G.winTimes) (hfold : G.FoldF s s') {p : G.Pos} (hp : G.FwdLive s' p) :
    (p, s) ∈ G.fwdLiveT := by
  classical
  obtain ⟨R, hful, hpos⟩ := hp
  refine G.fwdLiveT_greatest (X := G.verts.filter (fun v => ∃ k : ℕ, G.fwdVertFold R s s' k = v))
    (Finset.filter_subset _ _) ?_ ?_
  · intro v hv
    obtain ⟨-, k, hk⟩ := Finset.mem_filter.mp hv
    subst hk
    have hmemX : ∀ j : ℕ, G.fwdVertFold R s s' j ∈
        G.verts.filter (fun v => ∃ k : ℕ, G.fwdVertFold R s s' k = v) := fun j =>
      Finset.mem_filter.mpr ⟨G.fwdVertFold_mem_verts R hs hfold j, j, rfl⟩
    refine ⟨⟨G.fwdVertFold R s s' (k + 1), G.fwdVertFold_mem_succT R hs hfold k,
      hmemX (k + 1)⟩, ?_⟩
    intro ψ hψ
    match ψ with
    | .atom _ => rfl
    | .bot => rfl
    | .imp _ _ => rfl
    | .box _ => rfl
    | .snce _ _ => rfl
    | .stab _ => rfl
    | .untl g e =>
        simp only [untlLiveAt, decide_eq_true_eq]
        intro hpend
        rw [fwdVertFold_lab] at hpend
        obtain ⟨r, hr1, hr2, hr3⟩ := hful (s' + (k : ℤ)) g e hpend
        obtain ⟨j, hj⟩ := exists_nat_add (le_of_lt hr1)
        have hj0 : 0 < j := by omega
        have hpath : ∀ i : ℕ, G.fwdVertFold R s s' (k + (i + 1)) ∈
            G.succT (G.fwdVertFold R s s' (k + i)) :=
          fun i => G.fwdVertFold_mem_succT R hs hfold (k + i)
        have hkey := EUFix.mem_lfp_of_path
          (G.verts.filter (fun v => ∃ k : ℕ, G.fwdVertFold R s s' k = v)) G.succT
          (Fair.inSet (G.verts.filter (fun v => ∃ k : ℕ, G.fwdVertFold R s s' k = v))
            (G.atPosT e))
          (G.atPosT g) (fun i => G.fwdVertFold R s s' (k + i)) j hj0
          (fun i _ => hmemX (k + i)) (fun i _ => hpath i) ?_ ?_
        · unfold untlLive
          simpa using hkey
        · rw [Fair.inSet_iff]
          refine ⟨?_, hmemX (k + j)⟩
          rw [G.atPosT_iff, fwdVertFold_lab, show s' + ((k + j : ℕ) : ℤ) = r from by omega]
          exact hr2
        · intro i hi0 hij
          rw [G.atPosT_iff, fwdVertFold_lab]
          exact hr3 (s' + ((k + i : ℕ) : ℤ)) (by omega) (by omega)
  · have h0 : G.fwdVertFold R s s' 0 = (p, s) := by simp [fwdVertFold, hpos]
    rw [← h0]
    exact Finset.mem_filter.mpr ⟨G.fwdVertFold_mem_verts R hs hfold 0, 0, rfl⟩

/-- **A forward-live position is in the computed forward fixpoint.** The diagonal instance of
`mem_fwdLiveT_of_fwdLive_fold`; its statement is unchanged from the one this module landed. -/
theorem mem_fwdLiveT_of_fwdLive (G : PlusSlicedCertificate Γ Del) {s : ℤ} (hs : s ∈ G.winTimes)
    {p : G.Pos} (hp : G.FwdLive s p) : (p, s) ∈ G.fwdLiveT :=
  G.mem_fwdLiveT_of_fwdLive_fold hs (G.foldF_refl s) hp

/-- **A backward-live position is in the computed backward fixpoint.** -/
theorem mem_bwdLiveT_of_bwdLive (G : PlusSlicedCertificate Γ Del) {s : ℤ} (hs : s ∈ G.winTimes)
    {p : G.Pos} (hp : G.BwdLive s p) : (p, s) ∈ G.bwdLiveT := by
  classical
  obtain ⟨R, hful, hpos⟩ := hp
  refine G.bwdLiveT_greatest (X := G.verts.filter (fun v => ∃ k : ℕ, G.bwdVert R s k = v))
    (Finset.filter_subset _ _) ?_ ?_
  · intro v hv
    obtain ⟨-, k, hk⟩ := Finset.mem_filter.mp hv
    subst hk
    have hmemX : ∀ j : ℕ, G.bwdVert R s j ∈
        G.verts.filter (fun v => ∃ k : ℕ, G.bwdVert R s k = v) := fun j =>
      Finset.mem_filter.mpr ⟨G.bwdVert_mem_verts R hs j, j, rfl⟩
    refine ⟨⟨G.bwdVert R s (k + 1), G.bwdVert_mem_predT R hs k, hmemX (k + 1)⟩, ?_⟩
    intro ψ hψ
    match ψ with
    | .atom _ => rfl
    | .bot => rfl
    | .imp _ _ => rfl
    | .box _ => rfl
    | .untl _ _ => rfl
    | .stab _ => rfl
    | .snce g e =>
        simp only [snceLiveAt, decide_eq_true_eq]
        intro hpend
        rw [bwdVert_lab] at hpend
        obtain ⟨r, hr1, hr2, hr3⟩ := hful (s - (k : ℤ)) g e hpend
        obtain ⟨j, hj⟩ := exists_nat_sub (le_of_lt hr1)
        have hj0 : 0 < j := by omega
        have hpath : ∀ i : ℕ, G.bwdVert R s (k + (i + 1)) ∈ G.predT (G.bwdVert R s (k + i)) :=
          fun i => G.bwdVert_mem_predT R hs (k + i)
        have hkey := EUFix.mem_lfp_of_path
          (G.verts.filter (fun v => ∃ k : ℕ, G.bwdVert R s k = v)) G.predT
          (Fair.inSet (G.verts.filter (fun v => ∃ k : ℕ, G.bwdVert R s k = v)) (G.atPosT e))
          (G.atPosT g) (fun i => G.bwdVert R s (k + i)) j hj0
          (fun i _ => hmemX (k + i)) (fun i _ => hpath i) ?_ ?_
        · unfold snceLive
          simpa using hkey
        · rw [Fair.inSet_iff]
          refine ⟨?_, hmemX (k + j)⟩
          rw [G.atPosT_iff, bwdVert_lab, show s - ((k + j : ℕ) : ℤ) = r from by omega]
          exact hr2
        · intro i hi0 hij
          rw [G.atPosT_iff, bwdVert_lab]
          exact hr3 (s - ((k + i : ℕ) : ℤ)) (by omega) (by omega)
  · have h0 : G.bwdVert R s 0 = (p, s) := by simp [bwdVert, hpos]
    rw [← h0]
    exact Finset.mem_filter.mpr ⟨G.bwdVert_mem_verts R hs 0, 0, rfl⟩

/-- **A live position is in the computed fixpoint.** The two halves are independent, so this is
their conjunction and nothing more. -/
theorem mem_liveT_of_live (G : PlusSlicedCertificate Γ Del) {s : ℤ} (hs : s ∈ G.winTimes)
    {p : G.Pos} (hp : G.Live s p) : (p, s) ∈ G.liveT :=
  (G.mem_liveT (p, s)).mpr ⟨G.mem_fwdLiveT_of_fwdLive hs hp.1, G.mem_bwdLiveT_of_bwdLive hs hp.2⟩

/-! ## The position-level splice

`Live.lean`'s own `splice` takes two `LabRun`s and is `live_iff`'s justification; it is not usable
here, because a walk is a half-line and not a run. This splice takes the two half-lines.
-/

/-- **The position a spliced pair of walks occupies at a genuine time**: the forward walk's readout
at or after the common start, the backward walk's before it. -/
def spliceWalkPos (G : PlusSlicedCertificate Γ Del) (f h : ℕ → G.TPos) (t : ℤ) : G.Pos :=
  if (f 0).2 ≤ t then G.fwdWalkPos f t else G.bwdWalkPos h t

/-- **A forward walk's readout at its own start is its own first position.** -/
theorem fwdWalkPos_start (G : PlusSlicedCertificate Γ Del) (f : ℕ → G.TPos) :
    G.fwdWalkPos f (f 0).2 = (f 0).1 := by
  have h := G.fwdWalkPos_add f 0
  simpa using h

/-- **A backward walk's readout at its own start is its own first position.** -/
theorem bwdWalkPos_start (G : PlusSlicedCertificate Γ Del) (f : ℕ → G.TPos) :
    G.bwdWalkPos f (f 0).2 = (f 0).1 := by
  have h := G.bwdWalkPos_sub f 0
  simpa using h

theorem spliceWalkPos_ge (G : PlusSlicedCertificate Γ Del) {f h : ℕ → G.TPos} {t : ℤ}
    (ht : (f 0).2 ≤ t) : G.spliceWalkPos f h t = G.fwdWalkPos f t := by
  unfold spliceWalkPos
  rw [if_pos ht]

theorem spliceWalkPos_le (G : PlusSlicedCertificate Γ Del) {f h : ℕ → G.TPos} (hfh : h 0 = f 0)
    {t : ℤ} (ht : t ≤ (f 0).2) : G.spliceWalkPos f h t = G.bwdWalkPos h t := by
  unfold spliceWalkPos
  by_cases hc : (f 0).2 ≤ t
  · have heq : t = (f 0).2 := le_antisymm ht hc
    subst heq
    have e1 : (f 0).1 = (h 0).1 := by rw [hfh]
    have e2 : (f 0).2 = (h 0).2 := by rw [hfh]
    rw [if_pos hc, G.fwdWalkPos_start, e1, e2, G.bwdWalkPos_start]
  · rw [if_neg hc]

theorem spliceWalkPos_add (G : PlusSlicedCertificate Γ Del) (f h : ℕ → G.TPos) (k : ℕ) :
    G.spliceWalkPos f h ((f 0).2 + (k : ℤ)) = (f k).1 := by
  rw [G.spliceWalkPos_ge (by omega : (f 0).2 ≤ (f 0).2 + (k : ℤ)), G.fwdWalkPos_add]

theorem spliceWalkPos_sub (G : PlusSlicedCertificate Γ Del) {f h : ℕ → G.TPos} (hfh : h 0 = f 0)
    (k : ℕ) : G.spliceWalkPos f h ((f 0).2 - (k : ℤ)) = (h k).1 := by
  rw [G.spliceWalkPos_le hfh (by omega : (f 0).2 - (k : ℤ) ≤ (f 0).2),
    show (f 0).2 = (h 0).2 from by rw [hfh], G.bwdWalkPos_sub]

/-! ### The five `LabRun` fields, read off the splice

Four of them are a case split over the two half-line readouts of `Unroll.lean`. The fifth — the box
clause of `coherent` — is not a half-line fact at all and is where (C3b) enters.
-/

section Splice

variable {G : PlusSlicedCertificate Γ Del} {f h : ℕ → G.TPos}

theorem spliceWalkPos_labCoherent (hfV : ∀ k, f k ∈ G.verts)
    (hfs : ∀ k, f (k + 1) ∈ G.succT (f k)) (hhV : ∀ k, h k ∈ G.verts)
    (hhs : ∀ k, h (k + 1) ∈ G.predT (h k)) (hfh : h 0 = f 0) (t : ℤ) :
    LabCoherent Γ Del (G.spliceWalkPos f h t).2.1 := by
  by_cases ht : (f 0).2 ≤ t
  · rw [G.spliceWalkPos_ge ht]
    exact G.fwdWalkPos_labCoherent hfV hfs ht
  · rw [G.spliceWalkPos_le hfh (by omega : t ≤ (f 0).2)]
    exact G.bwdWalkPos_labCoherent hhV hhs (by rw [hfh]; omega)

theorem spliceWalkPos_agrees (hfV : ∀ k, f k ∈ G.verts)
    (hfs : ∀ k, f (k + 1) ∈ G.succT (f k)) (hhV : ∀ k, h k ∈ G.verts)
    (hhs : ∀ k, h (k + 1) ∈ G.predT (h k)) (hfh : h 0 = f 0) (t : ℤ) :
    G.AgreesOnState t (G.spliceWalkPos f h t).1 (G.spliceWalkPos f h t).2.1 := by
  by_cases ht : (f 0).2 ≤ t
  · rw [G.spliceWalkPos_ge ht]
    exact G.fwdWalkPos_agrees hfV hfs ht
  · rw [G.spliceWalkPos_le hfh (by omega : t ≤ (f 0).2)]
    exact G.bwdWalkPos_agrees hhV hhs (by rw [hfh]; omega)

theorem spliceWalkPos_edge (hfV : ∀ k, f k ∈ G.verts)
    (hfs : ∀ k, f (k + 1) ∈ G.succT (f k)) (hhV : ∀ k, h k ∈ G.verts)
    (hhs : ∀ k, h (k + 1) ∈ G.predT (h k)) (hfh : h 0 = f 0) (t : ℤ) :
    G.edge t (G.spliceWalkPos f h t).1 (G.spliceWalkPos f h (t + 1)).1 = true := by
  by_cases ht : (f 0).2 ≤ t
  · rw [G.spliceWalkPos_ge ht, G.spliceWalkPos_ge (by omega : (f 0).2 ≤ t + 1)]
    exact G.fwdWalkPos_edge hfV hfs ht
  · rw [G.spliceWalkPos_le hfh (by omega : t ≤ (f 0).2),
      G.spliceWalkPos_le hfh (by omega : t + 1 ≤ (f 0).2)]
    have hb := G.bwdWalkPos_edge hhV hhs (show t + 1 ≤ (h 0).2 by rw [hfh]; omega)
    rwa [show t + 1 - 1 = t from by omega] at hb

theorem spliceWalkPos_stepClause (hfV : ∀ k, f k ∈ G.verts)
    (hfs : ∀ k, f (k + 1) ∈ G.succT (f k)) (hhV : ∀ k, h k ∈ G.verts)
    (hhs : ∀ k, h (k + 1) ∈ G.predT (h k)) (hfh : h 0 = f 0) (t : ℤ) :
    StepClause Γ Del (G.spliceWalkPos f h t).2.1 (G.spliceWalkPos f h (t + 1)).2.1 := by
  by_cases ht : (f 0).2 ≤ t
  · rw [G.spliceWalkPos_ge ht, G.spliceWalkPos_ge (by omega : (f 0).2 ≤ t + 1)]
    exact G.fwdWalkPos_stepClause hfV hfs ht
  · rw [G.spliceWalkPos_le hfh (by omega : t ≤ (f 0).2),
      G.spliceWalkPos_le hfh (by omega : t + 1 ≤ (f 0).2)]
    have hb := G.bwdWalkPos_stepClause hhV hhs (show t + 1 ≤ (h 0).2 by rw [hfh]; omega)
    rwa [show t + 1 - 1 = t from by omega] at hb

/--
**The five local-coherence clauses of the spliced labelling.**

The box clause consumes (C3b) and `AgreesOnState` together, and nothing else: `box` is a state
shape, so the labelling's box content is the slice labelling's, and (C3b) is what pins the slice
labelling's box content to the box guess.
-/
theorem spliceWalkPos_coherent (hbox : G.BoxLabelFaithful) (hfV : ∀ k, f k ∈ G.verts)
    (hfs : ∀ k, f (k + 1) ∈ G.succT (f k)) (hhV : ∀ k, h k ∈ G.verts)
    (hhs : ∀ k, h (k + 1) ∈ G.predT (h k)) (hfh : h 0 = f 0) :
    PlusLocalCoherentSeqLab Γ Del G.bx (fun t => (G.spliceWalkPos f h t).2.1) := by
  intro t
  have hlab := spliceWalkPos_labCoherent hfV hfs hhV hhs hfh t
  have hagr := spliceWalkPos_agrees hfV hfs hhV hhs hfh t
  refine ⟨hlab.1, ?_, ?_, ?_, ?_⟩
  · intro a b hab
    have hc := hlab.2 _ hab
    simp only [impClauseAt, decide_eq_true_eq] at hc
    exact hc
  · intro χ hχ
    have hst : IsStateShape (PlusFormula.box χ) = true := rfl
    exact (hagr (PlusFormula.box χ) hχ hst).trans (hbox χ hχ t _)
  · intro g e hge
    have hc := (spliceWalkPos_stepClause hfV hfs hhV hhs hfh t).1 _ hge
    simp only [untlClauseAt, decide_eq_true_eq] at hc
    exact hc
  · intro g e hge
    have hc := (spliceWalkPos_stepClause hfV hfs hhV hhs hfh (t - 1)).2 _ hge
    rw [show t - 1 + 1 = t from by omega] at hc
    simp only [snceClauseAt, decide_eq_true_eq] at hc
    exact hc

/-- **The run a spliced pair of walks presents.** -/
def runOfWalks (hbox : G.BoxLabelFaithful) (hfV : ∀ k, f k ∈ G.verts)
    (hfs : ∀ k, f (k + 1) ∈ G.succT (f k)) (hhV : ∀ k, h k ∈ G.verts)
    (hhs : ∀ k, h (k + 1) ∈ G.predT (h k)) (hfh : h 0 = f 0) : G.LabRun where
  st := fun t => (G.spliceWalkPos f h t).1
  lab := fun t => (G.spliceWalkPos f h t).2.1
  lab_sub := fun _ => G.pos_lab_sub _
  agrees := spliceWalkPos_agrees hfV hfs hhV hhs hfh
  steps := spliceWalkPos_edge hfV hfs hhV hhs hfh
  coherent := spliceWalkPos_coherent hbox hfV hfs hhV hhs hfh

@[simp] theorem runOfWalks_lab (hbox : G.BoxLabelFaithful) (hfV : ∀ k, f k ∈ G.verts)
    (hfs : ∀ k, f (k + 1) ∈ G.succT (f k)) (hhV : ∀ k, h k ∈ G.verts)
    (hhs : ∀ k, h (k + 1) ∈ G.predT (h k)) (hfh : h 0 = f 0) (t : ℤ) :
    (runOfWalks hbox hfV hfs hhV hhs hfh).lab t = (G.spliceWalkPos f h t).2.1 := rfl

@[simp] theorem runOfWalks_st (hbox : G.BoxLabelFaithful) (hfV : ∀ k, f k ∈ G.verts)
    (hfs : ∀ k, f (k + 1) ∈ G.succT (f k)) (hhV : ∀ k, h k ∈ G.verts)
    (hhs : ∀ k, h (k + 1) ∈ G.predT (h k)) (hfh : h 0 = f 0) (t : ℤ) :
    (runOfWalks hbox hfV hfs hhV hhs hfh).st t = (G.spliceWalkPos f h t).1 := rfl

theorem runOfWalks_pos (hbox : G.BoxLabelFaithful) (hfV : ∀ k, f k ∈ G.verts)
    (hfs : ∀ k, f (k + 1) ∈ G.succT (f k)) (hhV : ∀ k, h k ∈ G.verts)
    (hhs : ∀ k, h (k + 1) ∈ G.predT (h k)) (hfh : h 0 = f 0) (t : ℤ) :
    (runOfWalks hbox hfV hfs hhV hhs hfh).pos t = G.spliceWalkPos f h t :=
  Prod.ext rfl (Subtype.ext rfl)

theorem runOfWalks_pos_start (hbox : G.BoxLabelFaithful) (hfV : ∀ k, f k ∈ G.verts)
    (hfs : ∀ k, f (k + 1) ∈ G.succT (f k)) (hhV : ∀ k, h k ∈ G.verts)
    (hhs : ∀ k, h (k + 1) ∈ G.predT (h k)) (hfh : h 0 = f 0) :
    (runOfWalks hbox hfV hfs hhV hhs hfh).pos (f 0).2 = (f 0).1 := by
  rw [runOfWalks_pos, G.spliceWalkPos_ge (le_refl _), G.fwdWalkPos_start]

/-! ### Fulfilment, lifted from the two half-lines

The walks discharge their own eventualities on their own half-lines; `plusFwdFulfilling_of_ge` and
`plusBwdFulfilling_of_le` turn each half-line discharge into full fulfilment, because an
eventuality pending off the half-line propagates onto it.
-/

/-- **The spliced run is forward-fulfilling**, from the forward walk's fairness alone. -/
theorem fwdFulfilling_runOfWalks (hbox : G.BoxLabelFaithful) (hfV : ∀ k, f k ∈ G.verts)
    (hfs : ∀ k, f (k + 1) ∈ G.succT (f k)) (hhV : ∀ k, h k ∈ G.verts)
    (hhs : ∀ k, h (k + 1) ∈ G.predT (h k)) (hfh : h 0 = f 0)
    (hfair : ∀ (k : ℕ) (g e : PlusFormula), PlusFormula.untl g e ∈ (f k).1.2.1 →
      ∃ m, k < m ∧ e ∈ (f m).1.2.1 ∧ ∀ j, k < j → j < m → g ∈ (f j).1.2.1) :
    PlusFwdFulfilling (runOfWalks hbox hfV hfs hhV hhs hfh).lab := by
  set R := runOfWalks hbox hfV hfs hhV hhs hfh with hR
  refine plusFwdFulfilling_of_ge R.coherent R.lab_sub (f 0).2 ?_
  intro u hu g e hmem
  obtain ⟨k, hk⟩ := exists_nat_add hu
  subst hk
  rw [hR, runOfWalks_lab, G.spliceWalkPos_add] at hmem
  obtain ⟨m, hm1, hm2, hm3⟩ := hfair k g e hmem
  refine ⟨(f 0).2 + (m : ℤ), by omega, ?_, ?_⟩
  · rw [hR, runOfWalks_lab, G.spliceWalkPos_add]
    exact hm2
  · intro q hq1 hq2
    obtain ⟨j, hj⟩ := exists_nat_add (show (f 0).2 ≤ q from by omega)
    subst hj
    rw [hR, runOfWalks_lab, G.spliceWalkPos_add]
    exact hm3 j (by omega) (by omega)

/-- **The spliced run is backward-fulfilling**, from the backward walk's fairness alone. -/
theorem bwdFulfilling_runOfWalks (hbox : G.BoxLabelFaithful) (hfV : ∀ k, f k ∈ G.verts)
    (hfs : ∀ k, f (k + 1) ∈ G.succT (f k)) (hhV : ∀ k, h k ∈ G.verts)
    (hhs : ∀ k, h (k + 1) ∈ G.predT (h k)) (hfh : h 0 = f 0)
    (hfair : ∀ (k : ℕ) (g e : PlusFormula), PlusFormula.snce g e ∈ (h k).1.2.1 →
      ∃ m, k < m ∧ e ∈ (h m).1.2.1 ∧ ∀ j, k < j → j < m → g ∈ (h j).1.2.1) :
    PlusBwdFulfilling (runOfWalks hbox hfV hfs hhV hhs hfh).lab := by
  set R := runOfWalks hbox hfV hfs hhV hhs hfh with hR
  refine plusBwdFulfilling_of_le R.coherent R.lab_sub (f 0).2 ?_
  intro u hu g e hmem
  obtain ⟨k, hk⟩ := exists_nat_sub hu
  subst hk
  rw [hR, runOfWalks_lab, G.spliceWalkPos_sub hfh] at hmem
  obtain ⟨m, hm1, hm2, hm3⟩ := hfair k g e hmem
  refine ⟨(f 0).2 - (m : ℤ), by omega, ?_, ?_⟩
  · rw [hR, runOfWalks_lab, G.spliceWalkPos_sub hfh]
    exact hm2
  · intro q hq1 hq2
    obtain ⟨j, hj⟩ := exists_nat_sub (show q ≤ (f 0).2 from by omega)
    subst hj
    rw [hR, runOfWalks_lab, G.spliceWalkPos_sub hfh]
    exact hm3 j (by omega) (by omega)

end Splice

/-! ## The soundness direction, and the bridge -/

/--
**A member of the computed fixpoint is live.**

Both halves of `G.liveT` are consumed at once, and the reason is stated in this module's header:
`FwdLive` demands a bi-infinite run, so the forward half alone cannot produce one.
-/
theorem live_of_mem_liveT (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    {v : G.TPos} (hv : v ∈ G.liveT) : G.Live v.2 v.1 := by
  obtain ⟨hvf, hvb⟩ := (G.mem_liveT v).mp hv
  obtain ⟨f, hf0, hfL, hfs, hffair⟩ := G.exists_fwdLive_walk hvf
  obtain ⟨h, hh0, hhL, hhs, hhfair⟩ := G.exists_bwdLive_walk hvb
  have hfV : ∀ k, f k ∈ G.verts := fun k => G.fwdLiveT_subset (hfL k)
  have hhV : ∀ k, h k ∈ G.verts := fun k => G.bwdLiveT_subset (hhL k)
  have hfh : h 0 = f 0 := by rw [hh0, hf0]
  have hpos : (runOfWalks hbox hfV hfs hhV hhs hfh).pos v.2 = v.1 := by
    have e2 : (f 0).2 = v.2 := by rw [hf0]
    have e1 : (f 0).1 = v.1 := by rw [hf0]
    rw [← e2, runOfWalks_pos_start, e1]
  exact ⟨⟨_, fwdFulfilling_runOfWalks hbox hfV hfs hhV hhs hfh hffair, hpos⟩,
    ⟨_, bwdFulfilling_runOfWalks hbox hfV hfs hhV hhs hfh hhfair, hpos⟩⟩

/--
**The bridge**: at a window time, declarative liveness and membership in the computed `Finset` are
the same condition.

This is what Phase 17's checker is written against and what Phase 18's soundness proof reads in the
other direction. `live_iff` (`Live.lean`) is the mathematics of the conjunction `Live` is; this is
the mathematics of the computation.
-/
theorem live_iff_mem_liveT (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful) {s : ℤ}
    (hs : s ∈ G.winTimes) (p : G.Pos) : G.Live s p ↔ (p, s) ∈ G.liveT :=
  ⟨G.mem_liveT_of_live hs, fun hv => G.live_of_mem_liveT hbox hv⟩

/--
**Liveness at a window time is decidable.**

The payoff of the whole sub-phase, and the reason the computed form was built at all: `Live` as
`Live.lean` states it quantifies over runs of a structure with an infinite carrier and admits no
direct instance, while `G.liveT` is a `Finset` over a decidable-equality type.
-/
def decidableLive (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful) {s : ℤ}
    (hs : s ∈ G.winTimes) (p : G.Pos) : Decidable (G.Live s p) :=
  decidable_of_iff ((p, s) ∈ G.liveT) (G.live_iff_mem_liveT hbox hs p).symm

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
