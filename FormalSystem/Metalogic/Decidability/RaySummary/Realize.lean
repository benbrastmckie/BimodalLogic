/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Trace
import FormalSystem.Metalogic.Decidability.RaySummary.HitOf
import FormalSystem.Semantics.SlicedFrame

/-!
# Realizing a finite labelled presentation (B2b, the soundness half)

`Trace.lean`'s `hit_eq_hitOf_of_presented` says a seam's `HitCl` IS the computable `hitOf` —
under the explicit realization hypothesis `Presented`, which that module discharges for no
non-trivial model. This module discharges it for a model built FROM the presentation. That is
requirement (S) of the `RaySummary/README.md` verdict, and it is Hodkinson–Wolter–Zakharyaschev
2000's Theorem 14 in the (⇐) direction for the box-dot fibre.

## What is realized, and what is not

Realized: ONE seam `(τ, t)` of ONE constructed model, for `box`/`stab`-free `φ` of L⁺, under
`[F.IsRegular]`, over the ℤ time axis. That is the (S)/(W) line the verdict already drew.

NOT realized, and never stated here in any form:

* no validity claim — `Decidable (PlusValidZTime φ)` does not follow from one seam, and lifting
  a seam to validity is requirement (W), a separate record;
* no complexity bound, upper or lower;
* no `box`/`stab` realization beyond the degenerate one that `box`/`stab`-freeness makes
  vacuous;
* no finite-fibre and no finite-width assumption. `not_finite_width_fmp` refutes that shape, and
  this construction concedes infinite fibres: the ONLY finiteness anywhere below is `[Fintype Q]`
  on the PRESENTATION, never on the model's carrier or on any of its fibres.

## Where the consistency conditions come from

`Cons` is read off `Probe735.not_presented`'s pumping proof: its conditions are exactly what
rules out the object `Probe735.pump_isRun` manufactures — a `step`-cycle every state of which
claims an eventuality and lacks its event, which realizes a deferred eventuality together with
its limit and which no `LocalRun` reads.

`Cons` is NOT a transcription of HWZ Definition 10's bare set of types. Task 742's wired probe
`quasistate_does_not_determine_hit` exhibits two models with EQUAL HWZ-verbatim quasistates and
UNEQUAL `Hit`, so a bare type set is the wrong alphabet for this semantics: `seamOmegaEquiv`
makes the box-dot fibre a PRODUCT of a backward and a forward ray set, so any history set a
per-state summary describes is splice-closed, and the summary must therefore be a product over
the two atom-sequence ray languages with types DERIVED by the trace map — which is what
`Anchored` already implements.

The fixtures below are FORWARD-ONLY: no backward Bool-fixture bridge exists in this tree, so no
`snce`-side statement is obtained by symmetry from an `untl`-side one.

## Contents

The forward (`untl`) half of the consistency conditions is below: the per-edge unfolding
coherence `UCoh`, the deferral graph `deferGraph` and its acyclicity `ULive`, the discharge
predicate `Disch`, and `untl_iff_of_UCoh_ULive`, which forces `LocalRun`'s `untl` clause on
every `step`-path of the presentation. All of it is generic over `sig` and `Q`: no model, no
frame, and no carrier finiteness appears in any statement.

The backward (`snce`) half follows it, proved outright rather than transported: the backward
unfolding coherence `SCoh`, the backward deferral graph `bwdDeferGraph` and its acyclicity
`SLive`, the backward discharge predicate `DischBwd`, and `snce_iff_of_SCoh_SLive`. Its
orientation is read off `LocalRun.snce`'s own clause, and the graph handed to `live` reverses
the underlying `step` relation in the manner of `Present.lean`'s `bwdLive`.

The `Cons` bundle follows: the eleven-field consistency structure on a finite labelled
presentation, and `cons_localRun`, which reads every field of `LocalRun` off it — `bot` and
`imp` from the per-state label equations, `untl` and `snce` by citing the two theorems above,
with no new induction and no formula recursion anywhere. Ten of the eleven fields mirror a
`LocalRun` field or a frame law; the eleventh, `nowUnique`, was derived from the realization
theorem's own obligation and is documented at the field.

The constructed model closes the file: `frameOf`, the presentation's own state set carried
through `FrameOver.ofSlicedStep` with the time-constant step relation; its regularity instance
and the explicit record `frameOf_not_finite_worldState` that the carrier `ℤ × Q` is infinite;
`modelOf`, whose valuation reads the state component's label; and the three rewrite lemmas
`modelOf_valuation`, `frameOf_step` and `frameOf_mem_HF_iff` through which the realization
theorem reads runs off histories and back. Every frame law is CITED from
`Semantics/SlicedFrame.lean`, none re-proved.

The realization theorem closes the file: `anchored_runTrace_of_boxStabFree`, which anchors a
run's trace to the corresponding history of the constructed model (`now` from `IsRun`, `atom`
from the valuation, `box` and `stab` VACUOUSLY on the `box`/`stab`-free fragment), and
`presented_modelOf`, which discharges `Presented` at a seam in both directions through the one
uniqueness lemma `eq_clTrace_of_localRun_anchored`. Three small helpers serve them:
`exists_stepPath_of_chain` (a finite `StepPath` cut out of a bi-infinite chain, the object
`Cons.nowOnce` is quantified over), `run_seam_state` (`Cons.nowUnique` at the seam) and
`isRun_of_chain_seam` (the converse packaging, `Cons.nowOnce` consumed in both time
directions).

The Hit-level equality this yields through `hit_eq_hitOf_of_presented` is owed to a later
module section and is not claimed here. Nothing in this module states, or is a step toward
stating, `Decidable (PlusValidZTime φ)`: `presented_modelOf` speaks of ONE seam of ONE
constructed model, and the lift to validity is a separate requirement the
`RaySummary/README.md` verdict records as still open. No complexity bound is claimed anywhere.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.PlusLanguage FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.Expressiveness

set_option linter.unusedSectionVars false

-- linter.unusedFintypeInType / linter.unusedDecidableInType: the `[Fintype sig.preds]` and
-- `[DecidableEq sig.preds]` binders are carried by every declaration of this namespace so that
-- the presentation-level binder shape is uniform — they are consumed by the decidability
-- instances and by the `Cons` bundle, and omitting them per-declaration would make the forward
-- conditions and their consumers disagree on the shape of a presentation.
set_option linter.unusedFintypeInType false
set_option linter.unusedDecidableInType false

/-! ## The forward consistency conditions -/

section Untl

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
variable {Q : Type} [Fintype Q] [DecidableEq Q]

/-- **One-step unfolding coherence** for the `untl` letter `u` with guard `g` and event `e`:
`PlusTruthAt`'s `untl` clause unfolded across one `step`. Decidable, and local to an edge. -/
def UCoh (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u g e : sig.preds) : Prop :=
  ∀ q q', step q q' = true →
    (lab q u = true ↔ (lab q' e = true ∨ (lab q' g = true ∧ lab q' u = true)))

/-- **The deferral graph** of an `untl` letter: an edge out of every state claiming `u` without
carrying `e`. An infinite chain in it is a run deferring the eventuality forever — exactly what
`Probe735.pump_isRun` manufactures from a repeated state. -/
def deferGraph (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u e : sig.preds) :
    Q → Q → Bool :=
  fun x y => lab x u && !(lab x e) && step x y

/-- **No-deferral liveness**: no state begins an infinite `u`-claiming, `e`-free chain. Decided
through `Present.lean`'s `live`. -/
def ULive (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u e : sig.preds) : Prop :=
  ∀ q, live (deferGraph lab step u e) q = false

/-- The discharge condition at `z` along `ρ`: the event at some later point with the guard on
the open interval. This is the right-hand side of `LocalRun`'s `untl` field. -/
def Disch (lab : Q → sig.preds → Bool) (g e : sig.preds) (ρ : ℤ → Q) (z : ℤ) : Prop :=
  ∃ s, z < s ∧ lab (ρ s) e = true ∧ ∀ r, z < r → r < s → lab (ρ r) g = true

instance decidableUCoh (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u g e : sig.preds) :
    Decidable (UCoh lab step u g e) := by
  unfold UCoh; infer_instance

instance decidableULive (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u e : sig.preds) :
    Decidable (ULive lab step u e) := by
  unfold ULive; infer_instance

/-- **Persistence along an undischarged stretch**: if the claim holds at `z` and is never
discharged, then from `z + 1` on the run claims `u`, carries the guard, and never carries `e`.
The whole content of the `untl` run condition's hard direction is here. -/
theorem persist (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u g e : sig.preds)
    (hco : UCoh lab step u g e) {ρ : ℤ → Q}
    (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) {z : ℤ}
    (hu : lab (ρ z) u = true) (hno : ¬ Disch lab g e ρ z) :
    ∀ n : ℕ, ∀ m : ℕ, m ≤ n →
      lab (ρ (z + 1 + m)) u = true ∧ lab (ρ (z + 1 + m)) e = false
        ∧ lab (ρ (z + 1 + m)) g = true := by
  intro n
  induction n with
  | zero =>
    intro m hm
    have hm0 : m = 0 := Nat.le_zero.mp hm
    subst hm0
    have h := (hco (ρ z) (ρ (z + 1)) (hstep z)).mp hu
    have hz1 : z + 1 + ((0 : ℕ) : ℤ) = z + 1 := by norm_num
    rw [hz1]
    rcases h with he | ⟨hg, hu'⟩
    · exact absurd ⟨z + 1, by omega, he, fun r h1 h2 => absurd h2 (by omega)⟩ hno
    · refine ⟨hu', ?_, hg⟩
      by_contra hc
      have he : lab (ρ (z + 1)) e = true := by
        rcases Bool.eq_false_or_eq_true (lab (ρ (z + 1)) e) with h' | h'
        · exact h'
        · exact absurd h' hc
      exact absurd ⟨z + 1, by omega, he, fun r h1 h2 => absurd h2 (by omega)⟩ hno
  | succ n ih =>
    intro m hm
    rcases Nat.lt_succ_iff_lt_or_eq.mp (Nat.lt_succ_of_le hm) with hlt | heq
    · exact ih m (Nat.lt_succ_iff.mp hlt)
    · subst heq
      obtain ⟨hun, -, -⟩ := ih n le_rfl
      have hs : step (ρ (z + 1 + (n : ℤ))) (ρ (z + 1 + (n : ℤ) + 1)) = true := hstep _
      have hcast : z + 1 + ((n + 1 : ℕ) : ℤ) = z + 1 + (n : ℤ) + 1 := by push_cast; omega
      -- the guard on the whole open interval `(z, z + 1 + n + 1)`, from `ih`
      have hguard : ∀ r : ℤ, z < r → r < z + 1 + (n : ℤ) + 1 → lab (ρ r) g = true := by
        intro r h1 h2
        have hm' : ((r - z - 1).toNat : ℤ) = r - z - 1 := by omega
        have hle : (r - z - 1).toNat ≤ n := by omega
        have := (ih _ hle).2.2
        rwa [show z + 1 + ((r - z - 1).toNat : ℤ) = r by omega] at this
      rw [hcast]
      rcases (hco _ _ hs).mp hun with he | ⟨hg, hu'⟩
      · exact absurd ⟨z + 1 + (n : ℤ) + 1, by omega, he, hguard⟩ hno
      · refine ⟨hu', ?_, hg⟩
        by_contra hc
        have he : lab (ρ (z + 1 + (n : ℤ) + 1)) e = true := by
          rcases Bool.eq_false_or_eq_true (lab (ρ (z + 1 + (n : ℤ) + 1)) e) with h' | h'
          · exact h'
          · exact absurd h' hc
        exact absurd ⟨z + 1 + (n : ℤ) + 1, by omega, he, hguard⟩ hno

-- linter.style.show: the `show` inside `hchain` beta-reduces the `HasChain` lambda witness,
-- which the following `rw [hcast]` needs; the research tactic survey recorded that explicit
-- beta-reduction as required here, so it is kept rather than replaced by `change`.
-- Declaration-scoped.
set_option linter.style.show false in
/--
**The `untl` run condition's hard (⇒) direction, from the two decidable conditions alone.**
No model, no frame and no carrier finiteness: coherence per edge plus acyclicity of the
deferral graph forces every run of the presentation to discharge every claim it makes.
-/
theorem disch_of_UCoh_ULive (lab : Q → sig.preds → Bool) (step : Q → Q → Bool)
    (u g e : sig.preds) (hco : UCoh lab step u g e) (hlive : ULive lab step u e)
    {ρ : ℤ → Q} (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) {z : ℤ}
    (hu : lab (ρ z) u = true) : Disch lab g e ρ z := by
  by_contra hno
  have hp := persist lab step u g e hco hstep hu hno
  -- the undischarged stretch is an infinite chain in the deferral graph
  have hchain : HasChain (deferGraph lab step u e) (ρ (z + 1)) := by
    refine ⟨fun n => ρ (z + 1 + (n : ℤ)), by norm_num, fun n => ?_⟩
    obtain ⟨hun, hen, -⟩ := hp n n le_rfl
    have hcast : z + 1 + ((n + 1 : ℕ) : ℤ) = z + 1 + (n : ℤ) + 1 := by push_cast; omega
    -- linter.style.show: the explicit `show` beta-reduces the `HasChain` lambda witness, which
    -- `rw [hcast]` needs; keeping it (rather than `change`) is the research tactic survey's
    -- recorded finding for this proof.
    show deferGraph lab step u e (ρ (z + 1 + (n : ℤ))) (ρ (z + 1 + ((n + 1 : ℕ) : ℤ))) = true
    rw [hcast]
    simp only [deferGraph, Bool.and_eq_true, Bool.not_eq_true']
    exact ⟨⟨hun, hen⟩, hstep _⟩
  have := (live_iff (deferGraph lab step u e) (ρ (z + 1))).mpr hchain
  rw [hlive (ρ (z + 1))] at this
  exact Bool.false_ne_true this

/--
**The `untl` run condition's easy (⇐) direction**: a discharge witness forces the claim, by
walking the coherence back from the witness.
-/
theorem u_of_disch (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u g e : sig.preds)
    (hco : UCoh lab step u g e) {ρ : ℤ → Q}
    (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) {z : ℤ}
    (hd : Disch lab g e ρ z) : lab (ρ z) u = true := by
  obtain ⟨s, hzs, hes, hguard⟩ := hd
  -- backward induction on the distance from `z` to `s`
  have key : ∀ n : ℕ, ∀ w : ℤ, z ≤ w → w + (n : ℤ) + 1 = s → lab (ρ w) u = true := by
    intro n
    induction n with
    | zero =>
      intro w hzw hws
      refine (hco (ρ w) (ρ (w + 1)) (hstep w)).mpr (Or.inl ?_)
      rw [show w + 1 = s by omega]
      exact hes
    | succ n ih =>
      intro w hzw hws
      have hu1 : lab (ρ (w + 1)) u = true := ih (w + 1) (by omega) (by push_cast at hws ⊢; omega)
      refine (hco (ρ w) (ρ (w + 1)) (hstep w)).mpr (Or.inr ⟨?_, hu1⟩)
      exact hguard (w + 1) (by omega) (by push_cast at hws ⊢; omega)
  exact key (s - z - 1).toNat z le_rfl (by omega)

/--
**`LocalRun`'s `untl` field, discharged from decidable per-edge data**: per-edge unfolding
coherence plus acyclicity of the deferral graph force the `untl` clause on every `step`-path.
No model, no frame, no carrier finiteness.

`ULive` is precisely the negation of what `Probe735.pump_isRun` manufactures: a `step`-cycle
every state of which claims the eventuality `u` and lacks its event `e`. That object is why a
consistency condition on the presentation is needed at all, and ruling it out is all that is
needed.
-/
theorem untl_iff_of_UCoh_ULive (lab : Q → sig.preds → Bool) (step : Q → Q → Bool)
    (u g e : sig.preds) (hC : UCoh lab step u g e) (hL : ULive lab step u e)
    (ρ : ℤ → Q) (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) (z : ℤ) :
    lab (ρ z) u = true ↔ Disch lab g e ρ z :=
  ⟨fun hu => disch_of_UCoh_ULive lab step u g e hC hL hstep hu,
   fun hd => u_of_disch lab step u g e hC hstep hd⟩

end Untl

/-! ## The backward consistency conditions -/

section Snce

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
variable {Q : Type} [Fintype Q] [DecidableEq Q]

/-- **One-step unfolding coherence** for the `snce` letter `u` with guard `g` and event `e`:
`PlusTruthAt`'s `snce` clause unfolded across one `step`.

This is NOT `UCoh` with its arguments swapped, and nothing below is obtained by symmetry from
the forward half — this tree carries no backward Bool-fixture bridge, so the orientation was
read off `LocalRun.snce`'s own clause (`∃ s, s < z ∧ event s ∧ ∀ r, s < r → r < z → guard r`,
`Closure.lean`) rather than transported. Concretely: the claim is unfolded at the LATER state
`q'` in terms of the EARLIER state `q`, because `snce` looks into the past, whereas `UCoh`
unfolds the claim at `q` in terms of `q'`. Decidable, and local to an edge. -/
def SCoh (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u g e : sig.preds) : Prop :=
  ∀ q q', step q q' = true →
    (lab q' u = true ↔ (lab q e = true ∨ (lab q g = true ∧ lab q u = true)))

/-- **The backward deferral graph** of a `snce` letter: an edge out of every state claiming `u`
without carrying `e`, to that state's `step`-PREDECESSORS. An infinite chain in it is a run
deferring the past eventuality forever.

Argument order of `live`: `live`/`HasChain` (`Present.lean`) always read an edge `G x y` as
`x → y` and ask for an infinite FORWARD chain `f 0 = q`, `G (f n) (f (n + 1))`. A backward
deferral chain runs the other way along `step`, so the graph handed to `live` reverses the
underlying relation — `step y x`, not `step x y` — exactly as `Present.lean`'s `bwdLive` does
(`live (fun x y => decide (τ ∈ pathTypes … y x))`), while the label test stays at the edge's
SOURCE `x` as in `deferGraph`. Writing `step x y` here instead would hand `live` the forward
graph, whose acyclicity is equivalent over a finite `Q` but only via a cycle-extraction
argument; the reversed order is what makes `disch_of_SCoh_SLive` read `persistBwd`'s backward
stretch off directly. -/
def bwdDeferGraph (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u e : sig.preds) :
    Q → Q → Bool :=
  fun x y => lab x u && !(lab x e) && step y x

/-- **No-backward-deferral liveness**: no state ends an infinite `u`-claiming, `e`-free backward
chain. Decided through `Present.lean`'s `live`, on the reversed graph (see `bwdDeferGraph`). -/
def SLive (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u e : sig.preds) : Prop :=
  ∀ q, live (bwdDeferGraph lab step u e) q = false

/-- The backward discharge condition at `z` along `ρ`: the event at some earlier point with the
guard on the open interval. This is the right-hand side of `LocalRun`'s `snce` field — the
interval is the OPEN `(s, z)`, matching that field verbatim. -/
def DischBwd (lab : Q → sig.preds → Bool) (g e : sig.preds) (ρ : ℤ → Q) (z : ℤ) : Prop :=
  ∃ s, s < z ∧ lab (ρ s) e = true ∧ ∀ r, s < r → r < z → lab (ρ r) g = true

instance decidableSCoh (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u g e : sig.preds) :
    Decidable (SCoh lab step u g e) := by
  unfold SCoh; infer_instance

instance decidableSLive (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u e : sig.preds) :
    Decidable (SLive lab step u e) := by
  unfold SLive; infer_instance

/-- **Backward persistence along an undischarged stretch**: if the claim holds at `z` and is
never discharged in the past, then from `z - 1` backward the run claims `u`, carries the guard,
and never carries `e`. The whole content of the `snce` run condition's hard direction is here.

Proved by induction on the gap `m`, with the guard over the whole open interval `(z - 1 - n, z)`
recovered from the induction hypothesis at each step — not by any transport from `persist`. -/
theorem persistBwd (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u g e : sig.preds)
    (hco : SCoh lab step u g e) {ρ : ℤ → Q}
    (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) {z : ℤ}
    (hu : lab (ρ z) u = true) (hno : ¬ DischBwd lab g e ρ z) :
    ∀ n : ℕ, ∀ m : ℕ, m ≤ n →
      lab (ρ (z - 1 - m)) u = true ∧ lab (ρ (z - 1 - m)) e = false
        ∧ lab (ρ (z - 1 - m)) g = true := by
  intro n
  induction n with
  | zero =>
    intro m hm
    have hm0 : m = 0 := Nat.le_zero.mp hm
    subst hm0
    have hs : step (ρ (z - 1)) (ρ z) = true := by
      have := hstep (z - 1)
      rwa [show z - 1 + 1 = z by omega] at this
    have h := (hco (ρ (z - 1)) (ρ z) hs).mp hu
    have hz1 : z - 1 - ((0 : ℕ) : ℤ) = z - 1 := by norm_num
    rw [hz1]
    rcases h with he | ⟨hg, hu'⟩
    · exact absurd ⟨z - 1, by omega, he, fun r h1 h2 => absurd h2 (by omega)⟩ hno
    · refine ⟨hu', ?_, hg⟩
      by_contra hc
      have he : lab (ρ (z - 1)) e = true := by
        rcases Bool.eq_false_or_eq_true (lab (ρ (z - 1)) e) with h' | h'
        · exact h'
        · exact absurd h' hc
      exact absurd ⟨z - 1, by omega, he, fun r h1 h2 => absurd h2 (by omega)⟩ hno
  | succ n ih =>
    intro m hm
    rcases Nat.lt_succ_iff_lt_or_eq.mp (Nat.lt_succ_of_le hm) with hlt | heq
    · exact ih m (Nat.lt_succ_iff.mp hlt)
    · subst heq
      obtain ⟨hun, -, -⟩ := ih n le_rfl
      have hcast : z - 1 - ((n + 1 : ℕ) : ℤ) = z - 1 - (n : ℤ) - 1 := by push_cast; omega
      have hs : step (ρ (z - 1 - (n : ℤ) - 1)) (ρ (z - 1 - (n : ℤ))) = true := by
        have := hstep (z - 1 - (n : ℤ) - 1)
        rwa [show z - 1 - (n : ℤ) - 1 + 1 = z - 1 - (n : ℤ) by omega] at this
      -- the guard on the whole open interval `(z - 1 - n - 1, z)`, from `ih`
      have hguard : ∀ r : ℤ, z - 1 - (n : ℤ) - 1 < r → r < z → lab (ρ r) g = true := by
        intro r h1 h2
        have hm' : ((z - 1 - r).toNat : ℤ) = z - 1 - r := by omega
        have hle : (z - 1 - r).toNat ≤ n := by omega
        have := (ih _ hle).2.2
        rwa [show z - 1 - ((z - 1 - r).toNat : ℤ) = r by omega] at this
      rw [hcast]
      rcases (hco _ _ hs).mp hun with he | ⟨hg, hu'⟩
      · exact absurd ⟨z - 1 - (n : ℤ) - 1, by omega, he, hguard⟩ hno
      · refine ⟨hu', ?_, hg⟩
        by_contra hc
        have he : lab (ρ (z - 1 - (n : ℤ) - 1)) e = true := by
          rcases Bool.eq_false_or_eq_true (lab (ρ (z - 1 - (n : ℤ) - 1)) e) with h' | h'
          · exact h'
          · exact absurd h' hc
        exact absurd ⟨z - 1 - (n : ℤ) - 1, by omega, he, hguard⟩ hno

-- linter.style.show: as in `disch_of_UCoh_ULive`, the `show` inside `hchain` beta-reduces the
-- `HasChain` lambda witness, which the following `rw [hcast]` needs. Declaration-scoped.
set_option linter.style.show false in
/--
**The `snce` run condition's hard (⇒) direction, from the two decidable conditions alone.**
No model, no frame and no carrier finiteness: coherence per edge plus acyclicity of the backward
deferral graph forces every run of the presentation to have discharged every past claim it
makes.
-/
theorem disch_of_SCoh_SLive (lab : Q → sig.preds → Bool) (step : Q → Q → Bool)
    (u g e : sig.preds) (hco : SCoh lab step u g e) (hlive : SLive lab step u e)
    {ρ : ℤ → Q} (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) {z : ℤ}
    (hu : lab (ρ z) u = true) : DischBwd lab g e ρ z := by
  by_contra hno
  have hp := persistBwd lab step u g e hco hstep hu hno
  -- the undischarged backward stretch is an infinite chain in the backward deferral graph
  have hchain : HasChain (bwdDeferGraph lab step u e) (ρ (z - 1)) := by
    refine ⟨fun n => ρ (z - 1 - (n : ℤ)), by norm_num, fun n => ?_⟩
    obtain ⟨hun, hen, -⟩ := hp n n le_rfl
    have hcast : z - 1 - ((n + 1 : ℕ) : ℤ) = z - 1 - (n : ℤ) - 1 := by push_cast; omega
    show bwdDeferGraph lab step u e (ρ (z - 1 - (n : ℤ))) (ρ (z - 1 - ((n + 1 : ℕ) : ℤ))) = true
    rw [hcast]
    simp only [bwdDeferGraph, Bool.and_eq_true, Bool.not_eq_true']
    refine ⟨⟨hun, hen⟩, ?_⟩
    have := hstep (z - 1 - (n : ℤ) - 1)
    rwa [show z - 1 - (n : ℤ) - 1 + 1 = z - 1 - (n : ℤ) by omega] at this
  have := (live_iff (bwdDeferGraph lab step u e) (ρ (z - 1))).mpr hchain
  rw [hlive (ρ (z - 1))] at this
  exact Bool.false_ne_true this

/--
**The `snce` run condition's easy (⇐) direction**: a past discharge witness forces the claim, by
walking the coherence forward from the witness. Needs no liveness.
-/
theorem u_of_dischBwd (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u g e : sig.preds)
    (hco : SCoh lab step u g e) {ρ : ℤ → Q}
    (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) {z : ℤ}
    (hd : DischBwd lab g e ρ z) : lab (ρ z) u = true := by
  obtain ⟨s, hsz, hes, hguard⟩ := hd
  -- forward induction on the distance from the witness `s` up to `z`
  have key : ∀ n : ℕ, ∀ w : ℤ, w ≤ z → s + (n : ℤ) + 1 = w → lab (ρ w) u = true := by
    intro n
    induction n with
    | zero =>
      intro w hwz hsw
      have hs : step (ρ s) (ρ w) = true := by
        have := hstep s
        rwa [show s + 1 = w by omega] at this
      exact (hco (ρ s) (ρ w) hs).mpr (Or.inl hes)
    | succ n ih =>
      intro w hwz hsw
      have hu1 : lab (ρ (w - 1)) u = true := ih (w - 1) (by omega) (by push_cast at hsw ⊢; omega)
      have hs : step (ρ (w - 1)) (ρ w) = true := by
        have := hstep (w - 1)
        rwa [show w - 1 + 1 = w by omega] at this
      refine (hco (ρ (w - 1)) (ρ w) hs).mpr (Or.inr ⟨?_, hu1⟩)
      exact hguard (w - 1) (by push_cast at hsw ⊢; omega) (by omega)
  exact key (z - s - 1).toNat z le_rfl (by omega)

/--
**`LocalRun`'s `snce` field, discharged from decidable per-edge data** — owed work proved
outright, not a symmetry of `untl_iff_of_UCoh_ULive`. Backward per-edge unfolding coherence plus
acyclicity of the backward deferral graph force the `snce` clause on every `step`-path. No
model, no frame, no carrier finiteness.

The interval in `DischBwd` is the open `(s, z)` with `s < z`, matching `LocalRun.snce` verbatim.
`SLive` is the backward counterpart of what `Probe735.pump_isRun` manufactures: a `step`-cycle
every state of which claims the eventuality `u` and lacks its event `e` is readable in either
time direction, and ruling it out backward is all that is needed here.
-/
theorem snce_iff_of_SCoh_SLive (lab : Q → sig.preds → Bool) (step : Q → Q → Bool)
    (u g e : sig.preds) (hC : SCoh lab step u g e) (hL : SLive lab step u e)
    (ρ : ℤ → Q) (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) (z : ℤ) :
    lab (ρ z) u = true ↔ DischBwd lab g e ρ z :=
  ⟨fun hu => disch_of_SCoh_SLive lab step u g e hC hL hstep hu,
   fun hd => u_of_dischBwd lab step u g e hC hstep hd⟩

end Snce

/-! ## The consistency bundle -/

section Bundle

variable {Q : Type} [Fintype Q] [DecidableEq Q]

/--
**The consistency conditions on a finite labelled presentation** — the counterpart of
Hodkinson–Wolter–Zakharyaschev 2000's Definition 12, read off `Probe735.not_presented`'s pumping
proof rather than off HWZ Definition 10's bare set of types (which
`quasistate_does_not_determine_hit` refutes for this semantics; see the module header).

Eleven fields in six groups, each shaped to mirror the `LocalRun` field it discharges, so that
`cons_localRun` below is field-by-field with nothing re-derived:

1. `serialFwd` / `serialBwd` — bi-seriality of `step` in both senses. This is what a bi-infinite
   run needs to exist at all, and in both senses because the time axis is `ℤ`: the forward half
   alone would leave the past unpopulated.
2. `botFalse` / `impEq` — propositional coherence per state, as `Bool` equations on the label so
   that they are checkable on a concrete presentation. `impEq` spells the implication as
   `!a || b`, which is `LocalRun.imp`'s `a → b` once both sides are read through `runTrace`.
3. `ucoh` / `ulive` — `UCoh` and `ULive` at every `untl` letter of the closure, with the guard
   and event letters projected by `plusClosure_untl_right` and `plusClosure_untl_left`
   respectively (that is the orientation `LocalRun.untl` itself uses: for `ψ U χ` the event is
   `χ` and the guard is `ψ`).
4. `scoh` / `slive` — the `snce` mirror, projected by `plusClosure_snce_right` / `_left`. Not a
   symmetry of the previous group: the two cite theorems proved independently.
5. `nowOnce` / `nowUnique` — the marker conditions. `nowOnce` is once-only ALONG a path: no
   `step`-path of positive length (`2 ≤ p.length`, since a `StepPath`'s list carries one entry
   per state) out of a `clNow`-labelled state ends at a `clNow`-labelled state. `nowUnique` is
   once-only ACROSS the presentation: at most one state carries the marker at all. `LocalRun`
   imposes nothing on `now`; these two fields are what make a `step`-path anchored, i.e. an
   `IsRun`, and pin the anchor to the seam's own state, and both are consumed where that is
   needed rather than here. `nowUnique` is the one field of this bundle that was derived in the
   course of proving `presented_modelOf` rather than assembled with the rest — see its own
   docstring for the obstruction that forced it.
6. `boxStabFree` — the scope line. With it, `not_box_mem_plusSubformulaClosure` and
   `not_stab_mem_plusSubformulaClosure` make the `box` and `stab` fields of an `Anchored`
   certificate vacuously satisfiable, which is the only sense in which `box` and `stab` are
   realized by this construction.

The bundle is NOT decidable as a whole and is not claimed to be: `impEq`, `ucoh`, `ulive`,
`scoh` and `slive` quantify universally over `ψ χ : PlusFormula`, an infinite type, and
`nowOnce` over `List Q`. `nowUnique` alone is decidable over a `Fintype Q` by `decide`. Each
individual clause is decidable at a given letter triple
(`decidableUCoh`, `decidableULive`, `decidableSCoh`, `decidableSLive`), which is what makes the
conditions checkable on a concrete presentation; the finite quantification needed to decide the
bundle itself would range over `plusSubformulaClosure φ` and is not built here.
-/
structure Cons (φ : PlusFormula) (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool) :
    Prop where
  /-- Every state has a `step`-successor. -/
  serialFwd : ∀ q : Q, ∃ q' : Q, step q q' = true
  /-- Every state has a `step`-predecessor — needed because the time axis is `ℤ`. -/
  serialBwd : ∀ q : Q, ∃ q' : Q, step q' q = true
  /-- The `⊥` letter is carried by no state. -/
  botFalse : ∀ (h : PlusFormula.bot ∈ plusSubformulaClosure φ) (q : Q),
    lab q (clLetter φ h) = false
  /-- The `imp` letter is the Boolean implication of its parts, state by state. -/
  impEq : ∀ (ψ χ : PlusFormula) (h : PlusFormula.imp ψ χ ∈ plusSubformulaClosure φ) (q : Q),
    lab q (clLetter φ h) =
      (!lab q (clLetter φ (plusClosure_imp_left φ ψ χ h)) ||
        lab q (clLetter φ (plusClosure_imp_right φ ψ χ h)))
  /-- One-step unfolding coherence at every `untl` letter. -/
  ucoh : ∀ (ψ χ : PlusFormula) (h : PlusFormula.untl ψ χ ∈ plusSubformulaClosure φ),
    UCoh lab step (clLetter φ h) (clLetter φ (plusClosure_untl_right φ χ ψ h))
      (clLetter φ (plusClosure_untl_left φ χ ψ h))
  /-- No deferred `untl` eventuality at any `untl` letter — the negation of what
  `Probe735.pump_isRun` manufactures. -/
  ulive : ∀ (ψ χ : PlusFormula) (h : PlusFormula.untl ψ χ ∈ plusSubformulaClosure φ),
    ULive lab step (clLetter φ h) (clLetter φ (plusClosure_untl_left φ χ ψ h))
  /-- Backward one-step unfolding coherence at every `snce` letter. -/
  scoh : ∀ (ψ χ : PlusFormula) (h : PlusFormula.snce ψ χ ∈ plusSubformulaClosure φ),
    SCoh lab step (clLetter φ h) (clLetter φ (plusClosure_snce_right φ χ ψ h))
      (clLetter φ (plusClosure_snce_left φ χ ψ h))
  /-- No deferred `snce` eventuality at any `snce` letter. -/
  slive : ∀ (ψ χ : PlusFormula) (h : PlusFormula.snce ψ χ ∈ plusSubformulaClosure φ),
    SLive lab step (clLetter φ h) (clLetter φ (plusClosure_snce_left φ χ ψ h))
  /-- **The once-only `now` condition**: no `step`-path of positive length out of a
  `clNow`-labelled state ends at a `clNow`-labelled state. -/
  nowOnce : ∀ (q q' : Q) (p : List Q), StepPath step q q' p → 2 ≤ p.length →
    lab q (clNow φ) = true → lab q' (clNow φ) = false
  /-- **The seam-state condition**: the `clNow` marker is carried by AT MOST ONE state.

  Where `nowOnce` says the marker is read at most once ALONG a path, this says it is read by at
  most one state of the presentation at all — two distinct `clNow`-labelled states are forbidden
  even when neither is reachable from the other. The two conditions are independent: `nowOnce`
  alone permits two mutually unreachable `clNow`-labelled components, and `nowUnique` alone
  permits the single marked state to recur along one path.

  **Why this field exists, recorded rather than left implicit.** It is what makes
  `presented_modelOf`'s (⇐) direction provable, and it was NOT among the clause groups this
  plan's `Cons` enumeration carried; it was derived from the construction's own obligation while
  proving the realization theorem. `Presented` equates the trace set of the splices through ONE
  seam state with the trace set of ALL runs anchored at `t`. A run supplies only
  `lab (ρ t) (clNow φ) = true`, so without this field `ρ t` need not be the seam's own `q₀`, and
  the history `z ↦ (z, ρ z)` built from the run is then not an element of the seam's fibre at
  all. Concretely, two mutually unreachable `clNow`-labelled components carrying different atom
  labels satisfy every other field of this structure while giving the two seams disjoint
  splice-trace sets and one shared run-trace set, which refutes `Presented` at either seam. With
  this field, `hq₀` and `IsRun` together force `ρ t = q₀` (`run_seam_state` below), which is
  exactly the missing step. -/
  nowUnique : ∀ q q' : Q, lab q (clNow φ) = true → lab q' (clNow φ) = true → q = q'
  /-- The scope line: `φ` carries no `□` and no `⊡`. -/
  boxStabFree : φ.BoxStabFree

/--
**Every `step`-path of a consistent presentation satisfies the local run conditions.**

Field by field, with nothing re-derived: `bot` and `imp` are the `botFalse` / `impEq` label
equations read through `runTrace`, and `untl` / `snce` are exact applications of
`untl_iff_of_UCoh_ULive` and `snce_iff_of_SCoh_SLive` at the letter triple `Cons` stores. There
is no induction on `φ` and no induction on `ℤ` anywhere below — both inductions were paid for
once, in `persist` and `persistBwd`.

No model, no frame, and no carrier finiteness beyond `[Fintype Q]` on the PRESENTATION: `ρ` is
an arbitrary bi-infinite `step`-chain, not a history of any model, and the `now` letter plays no
part (`LocalRun` imposes no condition on it, and `Cons.nowOnce` is consumed elsewhere).
-/
theorem cons_localRun {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool}
    (hC : Cons φ lab step) (ρ : ℤ → Q) (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) :
    LocalRun φ (runTrace lab ρ) where
  bot := by
    intro h z
    simp only [runTrace, hC.botFalse h (ρ z)]
    exact Bool.false_ne_true
  imp := by
    intro ψ χ h z
    simp only [runTrace, hC.impEq ψ χ h (ρ z)]
    cases hl : lab (ρ z) (clLetter φ (plusClosure_imp_left φ ψ χ h)) <;>
      cases hr : lab (ρ z) (clLetter φ (plusClosure_imp_right φ ψ χ h)) <;> simp
  untl := by
    intro ψ χ h z
    exact untl_iff_of_UCoh_ULive lab step _ _ _ (hC.ucoh ψ χ h) (hC.ulive ψ χ h) ρ hstep z
  snce := by
    intro ψ χ h z
    exact snce_iff_of_SCoh_SLive lab step _ _ _ (hC.scoh ψ χ h) (hC.slive ψ χ h) ρ hstep z

end Bundle

/-! ## The constructed model -/

section Constructed

open FormalSystem.Syntax FormalSystem.Semantics

variable {Q : Type} [Fintype Q] [DecidableEq Q] [Nonempty Q]

/--
**The frame of a presentation**: `FrameOver.ofSlicedStep` on the presentation's own state set
`Q`, with the TIME-CONSTANT relation `fun _ q q' => step q q' = true`. The carrier is `ℤ × Q`.

The relation ignores its time argument, so the `t - 1` index in `ofSlicedStep`'s `bwd` argument
is immaterial here: the backward seriality obligation `∀ t q, ∃ q', R (t - 1) q' q` is discharged
by `Cons.serialBwd` at every `t` alike. That is the one place this constructor's signature could
mislead, since a genuinely time-indexed relation would have to supply a predecessor in the
PREVIOUS slice.

**No finiteness on the model.** `[Fintype Q]` and `[Nonempty Q]` are finiteness and
non-emptiness of the PRESENTATION, which is what `ofSlicedStep` consumes to discharge seriality
and saturation. The constructed frame's world-state type is `ℤ × Q`, which is infinite —
recorded as `frameOf_not_finite_worldState` below rather than left to the reader. No
finite-fibre and no finite-width assumption is introduced anywhere; `not_finite_width_fmp`
refutes that shape, and this construction concedes infinite fibres by design.
-/
def frameOf {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool}
    (hC : Cons φ lab step) : FrameOver intOrder :=
  FrameOver.ofSlicedStep (fun _ q q' => step q q' = true)
    (fun _ q => hC.serialFwd q) (fun _ q => hC.serialBwd q)

/-- **The constructed frame is regular**, by `FrameOver.ofSlicedStep_isRegular` — cited, not
re-proved. All five `ofReflectiveRegular` field discharges (`ofSlicedStepRel_reflect`,
`ofSlicedStep_compositional`, `ofSlicedStep_serial`, `ofSlicedStep_limit`,
`ofSlicedStep_saturation`) live in `Semantics/SlicedFrame.lean` and are usable at `W := Q` as
they stand. This instance is what supplies the `[F.IsRegular]` that `Presented` requires. -/
instance frameOf_isRegular {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool}
    {step : Q → Q → Bool} (hC : Cons φ lab step) : (frameOf hC).IsRegular :=
  FrameOver.ofSlicedStep_isRegular _ _ _

/-- **The constructed model's world-state type is NOT finite.** The explicit record that no
finite-width and no finite-fibre assumption has been reintroduced: the carrier is `ℤ × Q` with
`Q` nonempty, so it is infinite however small the presentation is. Cited from
`FrameOver.ofSlicedStep_not_finite_worldState`. -/
theorem frameOf_not_finite_worldState {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool}
    {step : Q → Q → Bool} (hC : Cons φ lab step) : ¬ Finite (frameOf hC).WorldState :=
  FrameOver.ofSlicedStep_not_finite_worldState _ _ _

/--
**The model of a presentation**: the valuation reads the state component's label.

An atom `p` holds at `(z, q)` exactly when `p` is an atom of `φ`'s subformula closure and the
presentation labels `q` with its letter. Off the closure the atom holds nowhere — the closure
membership is part of the existential, so an atom `φ` never mentions is false at every world
state. That is the only freedom `Anchored.atom` leaves: it constrains the valuation precisely at
the closure's atoms (`Anchored` quantifies over `h : PlusFormula.atom p ∈ plusSubformulaClosure
φ`), and an off-closure atom is read by no letter of `clSig φ`.

The existential over the membership proof is harmless: `plusSubformulaClosure φ` membership is a
`Prop`, so any two proofs are definitionally equal and `clLetter φ h'` is `clLetter φ h` —
which is what makes `modelOf_valuation` below hold by `⟨·.2, ⟨h, ·⟩⟩` with no transport.
-/
def modelOf (φ : PlusFormula) (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool)
    (hC : Cons φ lab step) : TaskModel (frameOf hC).toTaskFrame where
  valuation := fun w p =>
    ∃ h : PlusFormula.atom p ∈ plusSubformulaClosure φ, lab w.2 (clLetter φ h) = true

/-- **The valuation rewrite lemma**: at the world state `(z, q)` the constructed model's
valuation of a closure atom is the presentation's label at `q`. The time component plays no
part, which is what makes the valuation a per-STATE datum of the presentation. This is the
lemma `Anchored.atom` is discharged by. -/
theorem modelOf_valuation {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool}
    {step : Q → Q → Bool} (hC : Cons φ lab step) {p : Atom}
    (h : PlusFormula.atom p ∈ plusSubformulaClosure φ) (z : ℤ) (q : Q) :
    (modelOf φ lab step hC).valuation (z, q) p ↔ lab q (clLetter φ h) = true :=
  ⟨fun hv => hv.2, fun hl => ⟨h, hl⟩⟩

/-- **The step rewrite lemma**: a step of the constructed frame advances the slice by one and
takes a `step`-edge of the presentation. `FrameOver.ofSlicedStep_step` at this relation. -/
theorem frameOf_step {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool}
    {step : Q → Q → Bool} (hC : Cons φ lab step) (p q : ℤ × Q) :
    (frameOf hC).step p q ↔ q.1 = p.1 + 1 ∧ step p.2 q.2 = true :=
  FrameOver.ofSlicedStep_step _ _ _ p q

/--
**The history space of the constructed frame is exactly the set of offset `step`-paths.**

`FrameOver.ofSlicedStep_mem_HF_iff` at this relation, with `IsSlicedStepPath` beta-reduced: the
relation is time-constant, so the offset `k` survives in the time component of the path but
plays no part in the step condition on `g`.

Both directions are load bearing downstream. The `←` direction BUILDS a history from a
bi-infinite `step`-chain of the presentation, which is how a run of the presentation becomes a
history of the constructed model. The `→` direction says a history has no freedom beyond its
offset `k` — its time component is forced to be `t + k` and its state component is a
`step`-chain — which is how a condition on histories is read back as a condition on one slice.
-/
theorem frameOf_mem_HF_iff {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool}
    {step : Q → Q → Bool} (hC : Cons φ lab step) (f : ℤ → ℤ × Q) :
    (∃ τ : WorldHistory (frameOf hC).toTaskFrame, τ.path = f) ↔
      ∃ (k : ℤ) (g : ℤ → Q), (∀ t : ℤ, step (g t) (g (t + 1)) = true) ∧
        f = fun t => (t + k, g t) :=
  FrameOver.ofSlicedStep_mem_HF_iff _ _ _ f

/-! ## The realization theorem -/

/--
**A finite `step`-path cut out of a bi-infinite chain.** From a bi-infinite `step`-chain `ρ`,
the stretch from `a` to `a + n` is a `StepPath` whose list has `n + 1` entries.

This exists for one reason: `Cons.nowOnce` is quantified over `StepPath step q q' p` with
`2 ≤ p.length`, so consuming it on a run requires producing the path, and the length bound is
what turns "`z ≠ t`" into "`2 ≤ p.length`". The induction is on `n` with `StepPath.snoc`; the
`ℤ`/`ℕ` cast bookkeeping is `push_cast`.
-/
theorem exists_stepPath_of_chain {step : Q → Q → Bool} (ρ : ℤ → Q)
    (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) (a : ℤ) (n : ℕ) :
    ∃ p : List Q, StepPath step (ρ a) (ρ (a + (n : ℤ))) p ∧ p.length = n + 1 := by
  induction n with
  | zero => exact ⟨[ρ a], by simpa using StepPath.single (ρ a), rfl⟩
  | succ n ih =>
    obtain ⟨p, hp, hlen⟩ := ih
    refine ⟨p ++ [ρ (a + ((n : ℤ) + 1))], ?_, by simp [hlen]⟩
    have h2 : a + ((n + 1 : ℕ) : ℤ) = a + ((n : ℤ) + 1) := by push_cast; ring
    rw [h2]
    exact StepPath.snoc _ hp (by simpa [add_assoc] using hstep (a + (n : ℤ)))

/--
**A run's state at the anchor IS the seam's state.** `Cons.nowUnique` read at the seam.

This is the step `presented_modelOf`'s (⇐) direction cannot do without, and the reason
`Cons.nowUnique` exists: a run supplies only `lab (ρ t) (clNow φ) = true`, and the history
`z ↦ (z, ρ z)` built from it lies in the seam's fibre only if `ρ t` is the seam's own `q₀`.
-/
theorem run_seam_state {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool}
    {step : Q → Q → Bool} (hC : Cons φ lab step) {t : ℤ} {q₀ : Q}
    (hq₀ : lab q₀ (clNow φ) = true) {ρ : ℤ → Q} (hρ : IsRun lab step (clNow φ) t ρ) :
    ρ t = q₀ :=
  hC.nowUnique _ _ ((hρ.2 t).mpr rfl) hq₀

/--
**A bi-infinite chain through the seam state is a run.** The converse packaging of
`run_seam_state`: the `now` letter is read at `t` because `ρ t = q₀` is marked, and NOWHERE
else because `Cons.nowOnce` forbids a positive-length `step`-path between two marked states —
consumed in both time directions, since a marked `ρ z` with `z < t` would mark `ρ t` as the
path's end and a marked `ρ z` with `z > t` would be marked by the path out of `ρ t`.

`Cons.nowUnique` plays no part here; only `nowOnce` does. The two fields discharge the two
halves of `IsRun`'s anchor condition and neither substitutes for the other.
-/
theorem isRun_of_chain_seam {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool}
    {step : Q → Q → Bool} (hC : Cons φ lab step) (t : ℤ) {q₀ : Q}
    (hq₀ : lab q₀ (clNow φ) = true) (ρ : ℤ → Q)
    (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) (hρt : ρ t = q₀) :
    IsRun lab step (clNow φ) t ρ := by
  refine ⟨hstep, fun z => ⟨?_, fun hz => by rw [hz, hρt]; exact hq₀⟩⟩
  intro hnow
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · -- `z < t`: the stretch `[z, t]` is a `StepPath` out of a marked state, so `t` is unmarked
    obtain ⟨p, hp, hlen⟩ := exists_stepPath_of_chain ρ hstep z (t - z).toNat
    rw [show z + ((t - z).toNat : ℤ) = t by omega] at hp
    have := hC.nowOnce _ _ p hp (by omega) hnow
    rw [hρt, hq₀] at this
    simp at this
  · -- `z > t`: the stretch `[t, z]` is a `StepPath` out of the marked seam, so `z` is unmarked
    obtain ⟨p, hp, hlen⟩ := exists_stepPath_of_chain ρ hstep t (z - t).toNat
    rw [show t + ((z - t).toNat : ℤ) = z by omega] at hp
    have := hC.nowOnce _ _ p hp (by omega) (by rw [hρt]; exact hq₀)
    rw [hnow] at this
    simp at this

/--
**A run's trace is anchored to the corresponding history of the constructed model**, for
`box`/`stab`-free `φ`.

Four fields, each a citation:

* `now` is `IsRun`'s second conjunct VERBATIM — `Anchored.now` asks for
  `c (clNow φ) z ≤ftrightarrow z = t` at `c := runTrace lab ρ`, which unfolds to
  `lab (ρ z) (clNow φ) = true ≤ftrightarrow z = t`;
* `atom` is `modelOf_valuation` after rewriting `σ.state z` to `(z, ρ z)` through `hσ`;
* `box` and `stab` are VACUOUS, by `not_box_mem_plusSubformulaClosure` /
  `not_stab_mem_plusSubformulaClosure` applied to the field's own closure-membership hypothesis.

The last point is the whole content of this task's scope line: `box` and `stab` letters are
realized here only in the sense that a `box`/`stab`-free `φ` has none, and the fields hold
because their hypotheses are uninhabited. A `φ` carrying either operator would need the
per-time and per-state anchor conditions discharged on the constructed model, which this
construction does not attempt.

Paper: HWZ 2000, Theorem 14, the anchoring half of the state-function-to-run correspondence.
-/
theorem anchored_runTrace_of_boxStabFree {φ : PlusFormula} (hφ : φ.BoxStabFree)
    {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool} (hC : Cons φ lab step) (t : ℤ)
    (ρ : ℤ → Q) (hρ : IsRun lab step (clNow φ) t ρ)
    (σ : WorldHistory (frameOf hC).toTaskFrame) (hσ : σ.path = fun z => (z, ρ z)) :
    Anchored (modelOf φ lab step hC) φ t (runTrace lab ρ) σ where
  now z := hρ.2 z
  atom p h z := by
    have hst : σ.state z = (z, ρ z) := congrFun hσ z
    rw [hst, modelOf_valuation hC h z (ρ z)]
    exact Iff.rfl
  box ψ h _ := absurd h (not_box_mem_plusSubformulaClosure hφ ψ)
  stab ψ h _ := absurd h (not_stab_mem_plusSubformulaClosure hφ ψ)

-- linter.style.show: the `show` in the (⇐) branch is `Probe735.not_presented`'s own
-- splice-exhibition step, kept VERBATIM from that probe — it spells out the
-- `(seamOmegaEquiv ...).symm ((seamOmegaEquiv ...) x)` round trip so that
-- `Equiv.symm_apply_apply` has a syntactic target to rewrite. `change` would do the same
-- job but would diverge from the probe this block is copied from. Declaration-scoped.
set_option linter.style.show false in
/--
**REQUIREMENT (S), HWZ 2000 Theorem 14 (⇐) for the box-dot fibre.** A finite presentation
satisfying `Cons` is realized by the constructed regular ℤ-model at a seam anchored at a
`clNow`-labelled state: the closure traces of the seam's splices are EXACTLY the traces of the
presentation's runs anchored at `t`.

This discharges `Trace.lean`'s realization hypothesis `Presented` for a model CONSTRUCTED from
the presentation. Both directions route through the single uniqueness lemma
`eq_clTrace_of_localRun_anchored`, whose two inputs are supplied the same way on each side:
`cons_localRun` for the run conditions and `anchored_runTrace_of_boxStabFree` for the anchors.
No new induction on `PlusFormula` appears here, and the uniqueness lemma is cited, never
re-proved.

* (⇒) A splice is a history of the constructed frame, so `frameOf_mem_HF_iff` presents it as
  `z ↦ (z + k, g z)` for some offset `k`; the seam anchor `hτ` pins `k = 0` and `g t = q₀`,
  and `isRun_of_chain_seam` turns `g` into a run.
* (⇐) A run gives the bi-infinite step path `z ↦ (z, ρ z)` by `frameOf_step`, hence a
  history by `FrameOver.worldHistoryOfStepPath`; `run_seam_state` puts that history in the
  seam's fibre, and `seamOmegaEquiv` exhibits it as a splice.

**What this does NOT say.** The scope is `box`/`stab`-free `φ` (`hφ`) and ONE seam. It is
not a claim that the presentation is complete for `φ` — that is a separate requirement, and
`Probe735.not_presented` refutes `Presented` as a completeness carrier on a model NOT built
from a presentation, which is a statement in the other direction and is not touched here.
Nothing about validity follows: `Decidable (PlusValidZTime φ)` is not stated, is not implied,
and would need the closure-wide requirement the `RaySummary/README.md` verdict records as
(W). No complexity bound is claimed.

Paper: HWZ 2000, Theorem 14 (⇐), at the box-dot fibre.
-/
theorem presented_modelOf {φ : PlusFormula} (hφ : φ.BoxStabFree)
    {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool} (hC : Cons φ lab step)
    (t : ℤ) (q₀ : Q) (hq₀ : lab q₀ (clNow φ) = true)
    (τ : WorldHistory (frameOf hC).toTaskFrame) (hτ : τ.state t = (t, q₀)) :
    Presented (modelOf φ lab step hC) τ t φ lab (fun q q' => step q q' = true) := by
  -- `Presented`'s `step` argument is `Bool`-valued, so the pinned `fun q q' => step q q' = true`
  -- elaborates with a `decide`; normalize it away once, up front
  rw [show (fun q q' : Q => decide (step q q' = true)) = step from by funext q q'; simp]
  intro c
  constructor
  · -- (⇒) every splice through the seam is a run of the presentation
    rintro ⟨bf, rfl⟩
    have hσt : (spliced τ t bf).state t = τ.state t :=
      ((seamOmegaEquiv t (τ.state t)).symm bf).2
    obtain ⟨k, g, hg, hpath⟩ :=
      (frameOf_mem_HF_iff hC (spliced τ t bf).path).mp ⟨spliced τ t bf, rfl⟩
    -- the seam anchor pins the offset to `0` and the state at `t` to `q₀`
    have hseam : ((t + k, g t) : ℤ × Q) = (t, q₀) := by
      rw [← hτ, ← hσt]; exact (congrFun hpath t).symm
    have hk : k = 0 := by
      have := congrArg Prod.fst hseam
      simp at this
      omega
    have hgt : g t = q₀ := congrArg Prod.snd hseam
    subst hk
    have hpath0 : (spliced τ t bf).path = fun z => (z, g z) := by
      rw [hpath]; funext z; simp
    have hrun : IsRun lab step (clNow φ) t g := isRun_of_chain_seam hC t hq₀ g hg hgt
    exact ⟨g, hrun, (eq_clTrace_of_localRun_anchored (modelOf φ lab step hC) φ t _
      (cons_localRun hC g hg)
      (anchored_runTrace_of_boxStabFree hφ hC t g hrun _ hpath0)).symm⟩
  · -- (⇐) every run of the presentation is a splice through the seam
    rintro ⟨ρ, hρ, rfl⟩
    have hρt : ρ t = q₀ := run_seam_state hC hq₀ hρ
    have hisp : IsStepPath (frameOf hC) (fun z => (z, ρ z)) := by
      intro z
      rw [frameOf_step hC]
      exact ⟨rfl, hρ.1 z⟩
    set σ : WorldHistory (frameOf hC).toTaskFrame :=
      FrameOver.worldHistoryOfStepPath (frameOf hC) (fun z => (z, ρ z)) hisp with hσdef
    have hσpath : σ.path = fun z => (z, ρ z) := rfl
    have hσt : σ.state t = τ.state t := by
      rw [hτ, show σ.state t = (t, ρ t) from congrFun hσpath t, hρt]
    -- `Probe735.not_presented`'s own splice-exhibition block, at the constructed frame
    let x : Presheaf.StabFibre (frameOf hC).toTaskFrame t (τ.state t) := ⟨σ, hσt⟩
    refine ⟨seamOmegaEquiv t (τ.state t) x, ?_⟩
    have hrt := Equiv.symm_apply_apply (seamOmegaEquiv t (τ.state t)) x
    show runTrace lab ρ = clTrace (modelOf φ lab step hC) φ t
      ((seamOmegaEquiv t (τ.state t)).symm ((seamOmegaEquiv t (τ.state t)) x)).1
    rw [hrt]
    exact eq_clTrace_of_localRun_anchored (modelOf φ lab step hC) φ t σ
      (cons_localRun hC ρ hρ.1) (anchored_runTrace_of_boxStabFree hφ hC t ρ hρ σ hσpath)

end Constructed

end FormalSystem.Metalogic.Decidability.RaySummary
