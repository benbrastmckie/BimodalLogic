/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Computed

/-!
# The Eventuality-Aware Liveness Fixpoint

`Computed.lean` supplies the two halves separately: `fwdWalkable`, the positions that begin some
infinite walk, and `untlReach`, the positions from which some walk delivers one eventuality. Neither
is liveness, and their conjunction is not liveness either. This module computes the object that is:
a **nested** greatest fixpoint whose inner reachability test is taken inside the set being
contracted, together with the single fair walk it yields.

## Why the two halves cannot simply be conjoined

`untlReach` takes its reachability inside all of `verts`, so a discharging path it certifies may
leave the set from which the walk can be continued forever. A segment that delivers the eventuality
but strands the walk at a dead end does not extend to a fair walk, so there is nothing to
concatenate. The reachability must therefore be *relativized* to the set being contracted — and,
for the same reason one step further in, so must the **delivering vertex**: a path whose interior
stays inside the set but whose endpoint leaves it strands the walk exactly as badly. `Fair.inSet`
is that endpoint condition, and `EUFix.lfp_mono_all` is what keeps the resulting outer contraction
monotone when its inner test varies with the set.

## What the fixpoint does and does not buy

Being the right **set** does not by itself produce the single walk that discharges **every**
eventuality: each eventuality is separately deliverable, and a walk chasing one may forever neglect
another. `Fair.exists_fair_walk` closes that gap by round-robin concatenation, and this module's
business at that layer is only to supply its four hypotheses — continuation, relativized discharge,
propagation, and a schedule — from the certificate's own data.

## Relation to `Live.lean`

Nothing here claims that `fwdLiveT` and `Live.lean`'s declarative `FwdLive` describe the same
positions. That equality is the bridge, it needs the position-level splice and the fold, and it is
deliberately absent: no declaration below mentions `FwdLive`, `BwdLive`, `Live`, or `LabRun`, and no
placeholder stands in for the bridge. What is here is the computed object, both directions of its
own fixpoint characterization, and the fair walk a soundness proof will read off it.

## Main definitions

- `PlusSlicedCertificate.untlLive` / `snceLive` — the relativized inner reachability at one
  eventuality
- `PlusSlicedCertificate.untlLiveAt` / `snceLiveAt` — the per-formula clause, `Bool`-valued with a
  vacuous default at the wrong shape
- `PlusSlicedCertificate.fwdLiveStep` / `bwdLiveStep` — the two contractions
- `PlusSlicedCertificate.fwdLiveT` / `bwdLiveT` / `liveT` — the computed liveness `Finset`s
- `PlusSlicedCertificate.untlSched` / `snceSched` — the round-robin schedules over the closure

## Main results

- `PlusSlicedCertificate.fwdLiveT_fixed` / `fwdLiveT_greatest`, and the backward pair — the fixpoint
  and its coinduction principle, so a soundness proof cites one and a completeness proof the other
- `PlusSlicedCertificate.fwdLiveT_subset_fwdWalkable` / `bwdLiveT_subset_bwdWalkable` — liveness is
  strictly stronger than walkability
- `PlusSlicedCertificate.untl_step_dichotomy` / `snce_step_dichotomy` — the (C1') propagation clause
- `PlusSlicedCertificate.exists_fwdLive_walk` / `exists_bwdLive_walk` — **one** walk inside the
  fixpoint discharging **every** eventuality pending anywhere along it, guard included

## Tags

plus-language · certificate · time-sliced · fixpoint · liveness · fairness · decidable
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## The relativized inner reachability

`Computed.lean`'s `untlReach` with `verts` replaced by the set being contracted, and with the
delivering vertex required to land back in that set. Both relativizations are needed; see this
module's header.
-/

/-- **Some forward walk inside `X` delivers `e` and lands back inside `X`**, carrying `g` at every
strictly intermediate vertex. -/
def untlLive (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) (g e : PlusFormula) :
    Finset G.TPos :=
  EUFix.lfp X G.succT (Fair.inSet X (G.atPosT e)) (G.atPosT g)

/-- **The `snce` dual**, on the backward graph. -/
def snceLive (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) (g e : PlusFormula) :
    Finset G.TPos :=
  EUFix.lfp X G.predT (Fair.inSet X (G.atPosT e)) (G.atPosT g)

/-- **The inner test is monotone in the set it is relativized to.** This is the step that needs
monotonicity in the *event* predicate and not only in the vertex set, because the event carries the
`w ∈ X` conjunct. -/
theorem untlLive_mono (G : PlusSlicedCertificate Γ Del) {X Y : Finset G.TPos} (h : X ⊆ Y)
    (g e : PlusFormula) : G.untlLive X g e ⊆ G.untlLive Y g e :=
  EUFix.lfp_mono_all h G.succT (Fair.inSet_mono h (G.atPosT e)) (fun _ hb => hb)

theorem snceLive_mono (G : PlusSlicedCertificate Γ Del) {X Y : Finset G.TPos} (h : X ⊆ Y)
    (g e : PlusFormula) : G.snceLive X g e ⊆ G.snceLive Y g e :=
  EUFix.lfp_mono_all h G.predT (Fair.inSet_mono h (G.atPosT e)) (fun _ hb => hb)

/-! ## The per-formula clause

`Bool`-valued on a formula with a vacuous default at the wrong shape, exactly as `Position.lean`'s
`impClauseAt` / `untlClauseAt` are, so that the whole of the liveness clause is decided by a bounded
quantifier over the closure rather than by an unbounded one over all formulas.
-/

/-- The forward liveness clause at one formula: an `untl` carried by the position's own label
must be deliverable without leaving `X`. -/
def untlLiveAt (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) (v : G.TPos) :
    PlusFormula → Bool
  | .untl g e => decide (PlusFormula.untl g e ∈ v.1.2.1 → v ∈ G.untlLive X g e)
  | _ => true

/-- The backward liveness clause at one formula. -/
def snceLiveAt (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) (v : G.TPos) :
    PlusFormula → Bool
  | .snce g e => decide (PlusFormula.snce g e ∈ v.1.2.1 → v ∈ G.snceLive X g e)
  | _ => true

theorem untlLiveAt_mono (G : PlusSlicedCertificate Γ Del) {X Y : Finset G.TPos} (h : X ⊆ Y)
    (v : G.TPos) (ψ : PlusFormula) (hψ : G.untlLiveAt X v ψ = true) :
    G.untlLiveAt Y v ψ = true := by
  cases ψ
  case untl g e =>
      simp only [untlLiveAt, decide_eq_true_eq] at hψ ⊢
      exact fun hmem => G.untlLive_mono h g e (hψ hmem)
  all_goals simp [untlLiveAt]

theorem snceLiveAt_mono (G : PlusSlicedCertificate Γ Del) {X Y : Finset G.TPos} (h : X ⊆ Y)
    (v : G.TPos) (ψ : PlusFormula) (hψ : G.snceLiveAt X v ψ = true) :
    G.snceLiveAt Y v ψ = true := by
  cases ψ
  case snce g e =>
      simp only [snceLiveAt, decide_eq_true_eq] at hψ ⊢
      exact fun hmem => G.snceLive_mono h g e (hψ hmem)
  all_goals simp [snceLiveAt]

/-! ## The two contractions and their fixpoints -/

/-- **One forward contraction**: keep the vertices of `X` that continue inside `X` and can discharge
every eventuality their own label carries without leaving `X`. -/
def fwdLiveStep (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) : Finset G.TPos :=
  X.filter (fun v => (∃ w ∈ G.succT v, w ∈ X) ∧
    ∀ ψ ∈ plusClosureOf (Γ ++ Del), G.untlLiveAt X v ψ = true)

/-- **One backward contraction**, the mirror. -/
def bwdLiveStep (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) : Finset G.TPos :=
  X.filter (fun v => (∃ w ∈ G.predT v, w ∈ X) ∧
    ∀ ψ ∈ plusClosureOf (Γ ++ Del), G.snceLiveAt X v ψ = true)

theorem mem_fwdLiveStep (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) (v : G.TPos) :
    v ∈ G.fwdLiveStep X ↔ v ∈ X ∧ (∃ w ∈ G.succT v, w ∈ X) ∧
      ∀ ψ ∈ plusClosureOf (Γ ++ Del), G.untlLiveAt X v ψ = true := Finset.mem_filter

theorem mem_bwdLiveStep (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) (v : G.TPos) :
    v ∈ G.bwdLiveStep X ↔ v ∈ X ∧ (∃ w ∈ G.predT v, w ∈ X) ∧
      ∀ ψ ∈ plusClosureOf (Γ ++ Del), G.snceLiveAt X v ψ = true := Finset.mem_filter

theorem fwdLiveStep_subset (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) :
    G.fwdLiveStep X ⊆ X := Finset.filter_subset _ _

theorem bwdLiveStep_subset (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) :
    G.bwdLiveStep X ⊆ X := Finset.filter_subset _ _

theorem fwdLiveStep_mono (G : PlusSlicedCertificate Γ Del) {X Y : Finset G.TPos} (h : X ⊆ Y) :
    G.fwdLiveStep X ⊆ G.fwdLiveStep Y := by
  intro v hv
  rw [G.mem_fwdLiveStep] at hv ⊢
  obtain ⟨hvX, ⟨w, hw1, hw2⟩, hall⟩ := hv
  exact ⟨h hvX, ⟨w, hw1, h hw2⟩, fun ψ hψ => G.untlLiveAt_mono h v ψ (hall ψ hψ)⟩

theorem bwdLiveStep_mono (G : PlusSlicedCertificate Γ Del) {X Y : Finset G.TPos} (h : X ⊆ Y) :
    G.bwdLiveStep X ⊆ G.bwdLiveStep Y := by
  intro v hv
  rw [G.mem_bwdLiveStep] at hv ⊢
  obtain ⟨hvX, ⟨w, hw1, hw2⟩, hall⟩ := hv
  exact ⟨h hvX, ⟨w, hw1, h hw2⟩, fun ψ hψ => G.snceLiveAt_mono h v ψ (hall ψ hψ)⟩

/-- **The forward-live timed positions.** -/
def fwdLiveT (G : PlusSlicedCertificate Γ Del) : Finset G.TPos := Nu.gfp G.verts G.fwdLiveStep

/-- **The backward-live timed positions.** -/
def bwdLiveT (G : PlusSlicedCertificate Γ Del) : Finset G.TPos := Nu.gfp G.verts G.bwdLiveStep

/-- **The live timed positions**: both directions at once. The conjunction is not itself justified
here; that is what the bridge's counterpart of `Live.lean`'s `live_iff` will do. -/
def liveT (G : PlusSlicedCertificate Γ Del) : Finset G.TPos := G.fwdLiveT ∩ G.bwdLiveT

theorem fwdLiveT_subset (G : PlusSlicedCertificate Γ Del) : G.fwdLiveT ⊆ G.verts :=
  Nu.gfp_subset _ (fun X => G.fwdLiveStep_subset X)

theorem bwdLiveT_subset (G : PlusSlicedCertificate Γ Del) : G.bwdLiveT ⊆ G.verts :=
  Nu.gfp_subset _ (fun X => G.bwdLiveStep_subset X)

theorem liveT_subset (G : PlusSlicedCertificate Γ Del) : G.liveT ⊆ G.verts :=
  subset_trans (Finset.inter_subset_left) G.fwdLiveT_subset

theorem mem_liveT (G : PlusSlicedCertificate Γ Del) (v : G.TPos) :
    v ∈ G.liveT ↔ v ∈ G.fwdLiveT ∧ v ∈ G.bwdLiveT := Finset.mem_inter

/-- **It is a fixpoint.** -/
theorem fwdLiveT_fixed (G : PlusSlicedCertificate Γ Del) :
    G.fwdLiveStep G.fwdLiveT = G.fwdLiveT :=
  Nu.gfp_fixed _ (fun X => G.fwdLiveStep_subset X) (fun _ _ h => G.fwdLiveStep_mono h)

theorem bwdLiveT_fixed (G : PlusSlicedCertificate Γ Del) :
    G.bwdLiveStep G.bwdLiveT = G.bwdLiveT :=
  Nu.gfp_fixed _ (fun X => G.bwdLiveStep_subset X) (fun _ _ h => G.bwdLiveStep_mono h)

/-- **It is the greatest post-fixpoint** — the coinduction principle, and what makes membership a
*complete* test rather than a merely sufficient one. -/
theorem fwdLiveT_greatest (G : PlusSlicedCertificate Γ Del) {X : Finset G.TPos}
    (hXV : X ⊆ G.verts)
    (hX : ∀ v ∈ X, (∃ w ∈ G.succT v, w ∈ X) ∧
      ∀ ψ ∈ plusClosureOf (Γ ++ Del), G.untlLiveAt X v ψ = true) : X ⊆ G.fwdLiveT :=
  Nu.gfp_greatest _ (fun _ _ h => G.fwdLiveStep_mono h) hXV
    (fun v hv => (G.mem_fwdLiveStep X v).mpr ⟨hv, hX v hv⟩)

theorem bwdLiveT_greatest (G : PlusSlicedCertificate Γ Del) {X : Finset G.TPos}
    (hXV : X ⊆ G.verts)
    (hX : ∀ v ∈ X, (∃ w ∈ G.predT v, w ∈ X) ∧
      ∀ ψ ∈ plusClosureOf (Γ ++ Del), G.snceLiveAt X v ψ = true) : X ⊆ G.bwdLiveT :=
  Nu.gfp_greatest _ (fun _ _ h => G.bwdLiveStep_mono h) hXV
    (fun v hv => (G.mem_bwdLiveStep X v).mpr ⟨hv, hX v hv⟩)

/-! ### Reading the fixpoint's two clauses off a member -/

theorem exists_succT_mem_fwdLiveT (G : PlusSlicedCertificate Γ Del) {v : G.TPos}
    (hv : v ∈ G.fwdLiveT) : ∃ w ∈ G.succT v, w ∈ G.fwdLiveT := by
  rw [← G.fwdLiveT_fixed, G.mem_fwdLiveStep] at hv
  exact hv.2.1

theorem exists_predT_mem_bwdLiveT (G : PlusSlicedCertificate Γ Del) {v : G.TPos}
    (hv : v ∈ G.bwdLiveT) : ∃ w ∈ G.predT v, w ∈ G.bwdLiveT := by
  rw [← G.bwdLiveT_fixed, G.mem_bwdLiveStep] at hv
  exact hv.2.1

/-- **Every eventuality a live position's label carries is deliverable without leaving the
fixpoint.** -/
theorem untlLive_of_mem_fwdLiveT (G : PlusSlicedCertificate Γ Del) {v : G.TPos}
    (hv : v ∈ G.fwdLiveT) {g e : PlusFormula} (hmem : PlusFormula.untl g e ∈ v.1.2.1) :
    v ∈ G.untlLive G.fwdLiveT g e := by
  have hcl : G.untlLiveAt G.fwdLiveT v (PlusFormula.untl g e) = true := by
    rw [← G.fwdLiveT_fixed, G.mem_fwdLiveStep] at hv
    exact hv.2.2 _ (G.pos_lab_sub v.1 hmem)
  simp only [untlLiveAt, decide_eq_true_eq] at hcl
  exact hcl hmem

theorem snceLive_of_mem_bwdLiveT (G : PlusSlicedCertificate Γ Del) {v : G.TPos}
    (hv : v ∈ G.bwdLiveT) {g e : PlusFormula} (hmem : PlusFormula.snce g e ∈ v.1.2.1) :
    v ∈ G.snceLive G.bwdLiveT g e := by
  have hcl : G.snceLiveAt G.bwdLiveT v (PlusFormula.snce g e) = true := by
    rw [← G.bwdLiveT_fixed, G.mem_bwdLiveStep] at hv
    exact hv.2.2 _ (G.pos_lab_sub v.1 hmem)
  simp only [snceLiveAt, decide_eq_true_eq] at hcl
  exact hcl hmem

/-- **Liveness is strictly stronger than walkability.** A one-line consequence, and emphatically not
a substitute: `fwdWalkable` is plain `EG ⊤` and says nothing about eventualities. -/
theorem fwdLiveT_subset_fwdWalkable (G : PlusSlicedCertificate Γ Del) :
    G.fwdLiveT ⊆ G.fwdWalkable :=
  EGFix.gfp_greatest _ _ G.fwdLiveT_subset (fun _ hv => G.exists_succT_mem_fwdLiveT hv)

theorem bwdLiveT_subset_bwdWalkable (G : PlusSlicedCertificate Γ Del) :
    G.bwdLiveT ⊆ G.bwdWalkable :=
  EGFix.gfp_greatest _ _ G.bwdLiveT_subset (fun _ hv => G.exists_predT_mem_bwdLiveT hv)

/-! ## The (C1') propagation clause

An eventuality pending at a position is, at the very next step, either delivered or still pending
with its guard. This is `Position.lean`'s `untlClauseAt` / `snceClauseAt` read along an edge, and it
is what makes a *late* discharge answer an *early* demand in the round-robin below.
-/

/-- **A forward eventuality propagates along a `succT` edge.** -/
theorem untl_step_dichotomy (G : PlusSlicedCertificate Γ Del) {v w : G.TPos}
    (hw : w ∈ G.succT v) {g e : PlusFormula} (hmem : PlusFormula.untl g e ∈ v.1.2.1) :
    e ∈ w.1.2.1 ∨ (g ∈ w.1.2.1 ∧ PlusFormula.untl g e ∈ w.1.2.1) := by
  have hsp := G.fst_mem_succP_of_mem_succT hw
  have hsc : StepClause Γ Del v.1.2.1 w.1.2.1 := ((G.mem_succP v.2 v.1 w.1).mp hsp).2.2
  have hcl := hsc.1 (PlusFormula.untl g e) (G.pos_lab_sub v.1 hmem)
  simp only [untlClauseAt, decide_eq_true_eq] at hcl
  exact hcl.mp hmem

/-- **A backward eventuality propagates along a `predT` edge.** -/
theorem snce_step_dichotomy (G : PlusSlicedCertificate Γ Del) {v w : G.TPos}
    (hw : w ∈ G.predT v) {g e : PlusFormula} (hmem : PlusFormula.snce g e ∈ v.1.2.1) :
    e ∈ w.1.2.1 ∨ (g ∈ w.1.2.1 ∧ PlusFormula.snce g e ∈ w.1.2.1) := by
  have hpp := G.fst_mem_predP_of_mem_predT hw
  have hsc : StepClause Γ Del w.1.2.1 v.1.2.1 := ((G.mem_predP v.2 w.1 v.1).mp hpp).2.2
  have hcl := hsc.2 (PlusFormula.snce g e) (G.pos_lab_sub v.1 hmem)
  simp only [snceClauseAt, decide_eq_true_eq] at hcl
  exact hcl.mp hmem

/-! ## The round-robin schedule

Obligations are indexed by the `(guard, event)` pair itself. The list is drawn from the target
closure — the only place a label's formulas can come from — with a dummy head so that it is never
empty. The head is an obligation like any other: if some label really carries `⊥ U ⊥` it is
discharged like any other, so nothing depends on the head being unreachable.

The four declarations below are `noncomputable` because `Finset.toList` is. That costs nothing here:
a schedule is consumed only as the parameter of an existence theorem, and no part of the decidable
checker ever evaluates one. Every `Finset` the checker does evaluate — `verts`, `succT`, `predT`,
`fwdLiveT`, `bwdLiveT`, `liveT` — stays computable.
-/

/-- The `untl` obligations of the target closure, as `(guard, event)` pairs. -/
noncomputable def untlTasks (Γ Del : PlusContext) : List (PlusFormula × PlusFormula) :=
  (PlusFormula.bot, PlusFormula.bot) ::
    (plusClosureOf (Γ ++ Del)).toList.filterMap
      (fun ψ => match ψ with | .untl g e => some (g, e) | _ => none)

/-- The `snce` obligations of the target closure. -/
noncomputable def snceTasks (Γ Del : PlusContext) : List (PlusFormula × PlusFormula) :=
  (PlusFormula.bot, PlusFormula.bot) ::
    (plusClosureOf (Γ ++ Del)).toList.filterMap
      (fun ψ => match ψ with | .snce g e => some (g, e) | _ => none)

theorem untlTasks_length_pos (Γ Del : PlusContext) : 0 < (untlTasks Γ Del).length := by
  simp [untlTasks]

theorem snceTasks_length_pos (Γ Del : PlusContext) : 0 < (snceTasks Γ Del).length := by
  simp [snceTasks]

theorem mem_untlTasks (Γ Del : PlusContext) {g e : PlusFormula}
    (h : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) : (g, e) ∈ untlTasks Γ Del := by
  refine List.mem_cons_of_mem _ ?_
  rw [List.mem_filterMap]
  exact ⟨PlusFormula.untl g e, Finset.mem_toList.mpr h, rfl⟩

theorem mem_snceTasks (Γ Del : PlusContext) {g e : PlusFormula}
    (h : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) : (g, e) ∈ snceTasks Γ Del := by
  refine List.mem_cons_of_mem _ ?_
  rw [List.mem_filterMap]
  exact ⟨PlusFormula.snce g e, Finset.mem_toList.mpr h, rfl⟩

/-- The forward schedule: block `n` attends to obligation `n` modulo the obligation count. -/
noncomputable def untlSched (Γ Del : PlusContext) (n : ℕ) : PlusFormula × PlusFormula :=
  (untlTasks Γ Del).getD (n % (untlTasks Γ Del).length) (PlusFormula.bot, PlusFormula.bot)

/-- The backward schedule. -/
noncomputable def snceSched (Γ Del : PlusContext) (n : ℕ) : PlusFormula × PlusFormula :=
  (snceTasks Γ Del).getD (n % (snceTasks Γ Del).length) (PlusFormula.bot, PlusFormula.bot)

/-- **Every listed obligation is scheduled arbitrarily late**, which is all the fairness argument
asks of a schedule. -/
theorem untlSched_late (Γ Del : PlusContext) {ge : PlusFormula × PlusFormula}
    (h : ge ∈ untlTasks Γ Del) (n : ℕ) : ∃ m, n ≤ m ∧ untlSched Γ Del m = ge := by
  obtain ⟨c, hc, hget⟩ := List.mem_iff_getElem.mp h
  refine ⟨c + (untlTasks Γ Del).length * (n + 1), ?_, ?_⟩
  · have hmul : n + 1 ≤ (untlTasks Γ Del).length * (n + 1) :=
      Nat.le_mul_of_pos_left (n + 1) (untlTasks_length_pos Γ Del)
    omega
  · unfold untlSched
    rw [Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt hc]
    simp [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hc, hget]

theorem snceSched_late (Γ Del : PlusContext) {ge : PlusFormula × PlusFormula}
    (h : ge ∈ snceTasks Γ Del) (n : ℕ) : ∃ m, n ≤ m ∧ snceSched Γ Del m = ge := by
  obtain ⟨c, hc, hget⟩ := List.mem_iff_getElem.mp h
  refine ⟨c + (snceTasks Γ Del).length * (n + 1), ?_, ?_⟩
  · have hmul : n + 1 ≤ (snceTasks Γ Del).length * (n + 1) :=
      Nat.le_mul_of_pos_left (n + 1) (snceTasks_length_pos Γ Del)
    omega
  · unfold snceSched
    rw [Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt hc]
    simp [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hc, hget]

/-! ## The fair walk

The headline of this module, and the piece with no counterpart anywhere else in the tree: the
`Formula` side never needs it, because there the fulfilment demand is universal over threads and is
proved directly.
-/

/--
**A forward-live position begins one infinite walk inside the fixpoint that discharges every `untl`
eventuality pending anywhere along it**, with the guard at every time strictly in between.

The conclusion's shape is deliberately the shape of `Live.lean`'s `PlusFwdFulfilling`, read along a
walk instead of along a labelling, so that the bridge has nothing left to rearrange.
-/
theorem exists_fwdLive_walk (G : PlusSlicedCertificate Γ Del) {v : G.TPos}
    (hv : v ∈ G.fwdLiveT) :
    ∃ f : ℕ → G.TPos, f 0 = v ∧ (∀ k, f k ∈ G.fwdLiveT) ∧
      (∀ k, f (k + 1) ∈ G.succT (f k)) ∧
      ∀ (k : ℕ) (g e : PlusFormula), PlusFormula.untl g e ∈ (f k).1.2.1 →
        ∃ m, k < m ∧ e ∈ (f m).1.2.1 ∧ ∀ j, k < j → j < m → g ∈ (f j).1.2.1 := by
  have hdis : ∀ u ∈ G.fwdLiveT, ∀ ge : PlusFormula × PlusFormula,
      G.atPosT (PlusFormula.untl ge.1 ge.2) u = true →
      u ∈ EUFix.lfp G.fwdLiveT G.succT (Fair.inSet G.fwdLiveT (G.atPosT ge.2))
        (G.atPosT ge.1) := by
    intro u hu ge hp
    exact G.untlLive_of_mem_fwdLiveT hu ((G.atPosT_iff _ u).mp hp)
  have hprop : ∀ u ∈ G.fwdLiveT, ∀ w ∈ G.succT u, w ∈ G.fwdLiveT →
      ∀ ge : PlusFormula × PlusFormula, G.atPosT (PlusFormula.untl ge.1 ge.2) u = true →
      G.atPosT ge.2 w = true ∨
        (G.atPosT ge.1 w = true ∧ G.atPosT (PlusFormula.untl ge.1 ge.2) w = true) := by
    intro u _ w hw _ ge hp
    rcases G.untl_step_dichotomy hw ((G.atPosT_iff _ u).mp hp) with he | ⟨hg, hu'⟩
    · exact Or.inl ((G.atPosT_iff _ w).mpr he)
    · exact Or.inr ⟨(G.atPosT_iff _ w).mpr hg, (G.atPosT_iff _ w).mpr hu'⟩
  have hsched : ∀ (ge : PlusFormula × PlusFormula) (n : ℕ),
      (∃ u ∈ G.fwdLiveT, G.atPosT (PlusFormula.untl ge.1 ge.2) u = true) →
      ∃ m, n ≤ m ∧ untlSched Γ Del m = ge := by
    intro ge n hex
    obtain ⟨u, _, hp⟩ := hex
    have hmem := (G.atPosT_iff _ u).mp hp
    exact untlSched_late Γ Del (mem_untlTasks Γ Del (G.pos_lab_sub u.1 hmem)) n
  obtain ⟨f, hf0, hfW, hfs, hfair⟩ :=
    Fair.exists_fair_walk (W := G.fwdLiveT) (succ := G.succT)
      (pend := fun ge u => G.atPosT (PlusFormula.untl ge.1 ge.2) u)
      (isE := fun ge u => G.atPosT ge.2 u) (isG := fun ge u => G.atPosT ge.1 u)
      (untlSched Γ Del) (fun _ hu => G.exists_succT_mem_fwdLiveT hu) hdis hprop hsched hv
  refine ⟨f, hf0, hfW, hfs, ?_⟩
  intro k g e hmem
  obtain ⟨m, hm1, hm2, hm3⟩ := hfair k (g, e) ((G.atPosT_iff _ (f k)).mpr hmem)
  exact ⟨m, hm1, (G.atPosT_iff _ (f m)).mp hm2,
    fun j hj1 hj2 => (G.atPosT_iff _ (f j)).mp (hm3 j hj1 hj2)⟩

/-- **The backward mirror.** Its conclusion is the shape of `Live.lean`'s `PlusBwdFulfilling`, read
backwards along a `predT` walk. -/
theorem exists_bwdLive_walk (G : PlusSlicedCertificate Γ Del) {v : G.TPos}
    (hv : v ∈ G.bwdLiveT) :
    ∃ f : ℕ → G.TPos, f 0 = v ∧ (∀ k, f k ∈ G.bwdLiveT) ∧
      (∀ k, f (k + 1) ∈ G.predT (f k)) ∧
      ∀ (k : ℕ) (g e : PlusFormula), PlusFormula.snce g e ∈ (f k).1.2.1 →
        ∃ m, k < m ∧ e ∈ (f m).1.2.1 ∧ ∀ j, k < j → j < m → g ∈ (f j).1.2.1 := by
  have hdis : ∀ u ∈ G.bwdLiveT, ∀ ge : PlusFormula × PlusFormula,
      G.atPosT (PlusFormula.snce ge.1 ge.2) u = true →
      u ∈ EUFix.lfp G.bwdLiveT G.predT (Fair.inSet G.bwdLiveT (G.atPosT ge.2))
        (G.atPosT ge.1) := by
    intro u hu ge hp
    exact G.snceLive_of_mem_bwdLiveT hu ((G.atPosT_iff _ u).mp hp)
  have hprop : ∀ u ∈ G.bwdLiveT, ∀ w ∈ G.predT u, w ∈ G.bwdLiveT →
      ∀ ge : PlusFormula × PlusFormula, G.atPosT (PlusFormula.snce ge.1 ge.2) u = true →
      G.atPosT ge.2 w = true ∨
        (G.atPosT ge.1 w = true ∧ G.atPosT (PlusFormula.snce ge.1 ge.2) w = true) := by
    intro u _ w hw _ ge hp
    rcases G.snce_step_dichotomy hw ((G.atPosT_iff _ u).mp hp) with he | ⟨hg, hu'⟩
    · exact Or.inl ((G.atPosT_iff _ w).mpr he)
    · exact Or.inr ⟨(G.atPosT_iff _ w).mpr hg, (G.atPosT_iff _ w).mpr hu'⟩
  have hsched : ∀ (ge : PlusFormula × PlusFormula) (n : ℕ),
      (∃ u ∈ G.bwdLiveT, G.atPosT (PlusFormula.snce ge.1 ge.2) u = true) →
      ∃ m, n ≤ m ∧ snceSched Γ Del m = ge := by
    intro ge n hex
    obtain ⟨u, _, hp⟩ := hex
    have hmem := (G.atPosT_iff _ u).mp hp
    exact snceSched_late Γ Del (mem_snceTasks Γ Del (G.pos_lab_sub u.1 hmem)) n
  obtain ⟨f, hf0, hfW, hfs, hfair⟩ :=
    Fair.exists_fair_walk (W := G.bwdLiveT) (succ := G.predT)
      (pend := fun ge u => G.atPosT (PlusFormula.snce ge.1 ge.2) u)
      (isE := fun ge u => G.atPosT ge.2 u) (isG := fun ge u => G.atPosT ge.1 u)
      (snceSched Γ Del) (fun _ hu => G.exists_predT_mem_bwdLiveT hu) hdis hprop hsched hv
  refine ⟨f, hf0, hfW, hfs, ?_⟩
  intro k g e hmem
  obtain ⟨m, hm1, hm2, hm3⟩ := hfair k (g, e) ((G.atPosT_iff _ (f k)).mpr hmem)
  exact ⟨m, hm1, (G.atPosT_iff _ (f m)).mp hm2,
    fun j hj1 hj2 => (G.atPosT_iff _ (f j)).mp (hm3 j hj1 hj2)⟩

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
