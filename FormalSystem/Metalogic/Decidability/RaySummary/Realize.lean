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

The `Cons` bundle and the constructed model itself are owed to this module's later sections and
are not claimed here.
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

end FormalSystem.Metalogic.Decidability.RaySummary
