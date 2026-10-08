/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Trace

/-!
# The per-seam `⊡` check on a presentation, by liveness — conditional on `Presented`

`Trace.lean` ends with `plusStab_iff_forall_run_of_presented`: under the realization hypothesis
`Presented`, `⊡φ` at the seam is the run-level condition that every run of the finite
presentation anchored at `t` reads `φ`'s letter at its `now` state. This module **decides that
run-level condition** on the presentation alone, with no `k`-type evaluated and no `hitOf`
computed, and then composes the decider with the bridge.

## What is decided

A state `q` is the `now` state of some anchored run (`OnRun`) iff it reads `now` and starts an
infinite chain in each of the two `now`-free step graphs — forward (`fwdNowFree`: a step whose
target does not read `now`) and backward (`bwdNowFree`: a step into the state from a source
that does not read `now`) — `onRun_iff_live`. Both directions glue at the anchor: a run restricted
to `[t, ∞)` and `(-∞, t]` is a pair of chains, and a pair of chains with a common origin `q` is
a run `ρ z := if t ≤ z then f (z - t).toNat else g (t - z).toNat`. Liveness in a finite graph is
`live`, the greatest fixpoint of `Present.lean`, decided by `live_iff`. So the decider
`stabCheckSig lab step now phi` — every live `now` state reads `phi` — decides the run-level
condition at every anchor (`stabCheckSig_iff`; `t` does not occur in the decider, the anchor is
carried by the marker letter `now`).

At the closure instance, `stabCheck_iff_of_presented` composes `stabCheckSig_iff` with
`plusStab_iff_forall_run_of_presented`, and `decidableStabOfPresented` packages it as a
`Decidable (PlusTruthAt M τ t (.stab φ))` **under `Presented`**.

## What is NOT decided — read this before citing anything above

* **Nothing here is a decision procedure for any model in the tree.** Every closure-instance
  statement is conditional on `Presented M τ t φ lab step`, and `Presented` is refuted as a
  completeness carrier: the wired probe
  `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean`
  (`Probe735.not_presented`) shows that on a three-state regular `ℤ`-model (model A) at the
  seam with `φ := Fp`, no finite `Q`, `lab`, `step` satisfies `Presented` — by pumping a repeated
  run state against the `untl` run condition through `clTrace_localRun`. On such a model
  `stabCheck_iff_of_presented` and `decidableStabOfPresented` are **vacuous**: their
  hypothesis has no inhabitant, so they decide nothing there. The one-line positive content is
  the presentation-level `stabCheckSig_iff`, which is about runs of a presentation and makes no
  claim about any model.
* **Nothing about `PlusValidZTime`.** No declaration in this module mentions validity, and no
  enumeration of `Presented`-presentations can decide it, because a refuting model need not
  have one (the probe above). The programme's stated aim on this route — a decidable check for
  L⁺ over discrete time — is NOT delivered here, and this module must not be read as a step
  towards it that only awaits a successor: see the verdict in the RaySummary README.
* **No complexity bound**, no finite-fibre or finite-width assumption (the presentation is
  finite; the fibre it is a hypothesis about is not), and the cited fixtures are forward-only
  (no backward Bool-fixture bridge exists; nothing about `⊡(Pp)`).
* **The three missing theorems.** What would turn a presentation-level decider into a
  model-level one is named, not filed, in the RaySummary README's verdict section: (C) Hit-level
  completeness with a computable bound, (S) Hit-level soundness (the B2b record restated at
  `hitOf` level, whose consistency conditions must exclude pumpable eventuality-deferring run
  sets), and (W) a closure-wide quasimodel over all seams and times. None exists in the tree or
  as a record; `Presented` cannot carry (C), by the probe.

Everything stays under `[F.IsRegular]` where the seam's fibre is used, over the `ℤ` time axis.

## Main definitions and results

* `fwdNowFree`, `bwdNowFree` — the `now`-free step graphs of a presentation.
* `OnRun`, `onRun_iff_live` — the `now` states of anchored runs are the live `now` states.
* `stabCheckSig`, `stabCheckSig_iff` — the decider and its correctness at every anchor.
* `stabCheck_iff_of_presented`, `decidableStabOfPresented` — the closure instance, under
  `Presented` (vacuous on model A).

## References

* [I. Hodkinson, F. Wolter, M. Zakharyaschev, *Decidable fragments of first-order temporal
  logics*, 2000], Def. 11 (runs); the liveness reading of a run's two halves is the
  formalization's own.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.Expressiveness

variable {sig : MonadicSignature}

/-! ## The `now`-free step graphs and the states on anchored runs -/

section NowFree

variable {Q : Type} (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (now : sig.preds)

/-- The forward `now`-free step graph: a step whose target does not read `now`. -/
def fwdNowFree : Q → Q → Bool := fun x y => step x y && !lab y now

/-- The backward `now`-free step graph: a step into `x` from a source `y` not reading `now`. -/
def bwdNowFree : Q → Q → Bool := fun x y => step y x && !lab y now

/-- `q` is the `now` state of some run of the presentation anchored at `t`. -/
def OnRun (t : ℤ) (q : Q) : Prop := ∃ ρ : ℤ → Q, IsRun lab step now t ρ ∧ ρ t = q

end NowFree

/-! ## Liveness decides the states on anchored runs -/

section StabCheck

variable {Q : Type} [Fintype Q] [DecidableEq Q] (lab : Q → sig.preds → Bool)
  (step : Q → Q → Bool) (now : sig.preds)

/-- **A state is on an anchored run iff it reads `now` and is live in both `now`-free graphs.**
Forward: the run's halves `ρ (t + n)` and `ρ (t - n)` are chains (`IsRun`'s `now` clause gives
`¬ lab (ρ z) now` for `z ≠ t`). Backward: two chains with common origin `q` glue to the run
`ρ z := if t ≤ z then f (z - t).toNat else g (t - z).toNat`. -/
theorem onRun_iff_live (t : ℤ) (q : Q) :
    OnRun lab step now t q ↔
      lab q now = true ∧ live (fwdNowFree lab step now) q = true ∧
        live (bwdNowFree lab step now) q = true := by
  constructor
  · rintro ⟨ρ, ⟨hstep, hnow⟩, rfl⟩
    have hoff : ∀ z, z ≠ t → lab (ρ z) now = false := fun z hz =>
      Bool.eq_false_iff.mpr (fun h => hz ((hnow z).mp h))
    refine ⟨(hnow t).mpr rfl, ?_, ?_⟩
    · rw [live_iff]
      refine ⟨fun n => ρ (t + n), by simp, fun n => ?_⟩
      change (step (ρ (t + n)) (ρ (t + ((n + 1 : ℕ) : ℤ))) && !lab (ρ (t + ((n + 1 : ℕ) : ℤ))) now)
        = true
      rw [show t + ((n + 1 : ℕ) : ℤ) = t + n + 1 by push_cast; ring, hstep, hoff _ (by omega)]
      rfl
    · rw [live_iff]
      refine ⟨fun n => ρ (t - n), by simp, fun n => ?_⟩
      change (step (ρ (t - ((n + 1 : ℕ) : ℤ))) (ρ (t - n)) && !lab (ρ (t - ((n + 1 : ℕ) : ℤ))) now)
        = true
      rw [show t - n = t - ((n + 1 : ℕ) : ℤ) + 1 by push_cast; ring, hstep,
        hoff _ (by push_cast; omega)]
      rfl
  · rintro ⟨hq, hf, hb⟩
    rw [live_iff] at hf hb
    obtain ⟨f, hf0, hfc⟩ := hf
    obtain ⟨g, hg0, hgc⟩ := hb
    have hf' : ∀ n, step (f n) (f (n + 1)) = true ∧ lab (f (n + 1)) now = false := fun n => by
      have h := hfc n
      simp only [fwdNowFree, Bool.and_eq_true, Bool.not_eq_true'] at h
      exact h
    have hg' : ∀ n, step (g (n + 1)) (g n) = true ∧ lab (g (n + 1)) now = false := fun n => by
      have h := hgc n
      simp only [bwdNowFree, Bool.and_eq_true, Bool.not_eq_true'] at h
      exact h
    refine ⟨fun z => if t ≤ z then f (z - t).toNat else g (t - z).toNat, ⟨?_, ?_⟩, ?_⟩
    · intro z
      dsimp only
      by_cases hz : t ≤ z
      · rw [if_pos hz, if_pos (by omega : t ≤ z + 1),
          show (z + 1 - t).toNat = (z - t).toNat + 1 by omega]
        exact (hf' _).1
      · by_cases hz' : z + 1 = t
        · rw [if_neg hz, if_pos (by omega : t ≤ z + 1), show (t - z).toNat = 1 by omega,
            show (z + 1 - t).toNat = 0 by omega, hf0, ← hg0]
          exact (hg' 0).1
        · rw [if_neg hz, if_neg (by omega : ¬ t ≤ z + 1),
            show (t - z).toNat = (t - (z + 1)).toNat + 1 by omega]
          exact (hg' _).1
    · intro z
      dsimp only
      by_cases hz : z = t
      · subst hz
        rw [if_pos le_rfl, sub_self, Int.toNat_zero, hf0]
        exact ⟨fun _ => rfl, fun _ => hq⟩
      · by_cases hz' : t ≤ z
        · rw [if_pos hz', show (z - t).toNat = (z - t - 1).toNat + 1 by omega, (hf' _).2]
          exact ⟨fun h => absurd h (by decide), fun h => absurd h hz⟩
        · rw [if_neg hz', show (t - z).toNat = (t - z - 1).toNat + 1 by omega, (hg' _).2]
          exact ⟨fun h => absurd h (by decide), fun h => absurd h hz⟩
    · change (if t ≤ t then f (t - t).toNat else g (t - t).toNat) = q
      rw [if_pos le_rfl, sub_self, Int.toNat_zero, hf0]

/-- **The decider**: every live `now` state reads `phi`. The anchor `t` does not occur; it is
carried by the marker letter `now`. Computable: `live` is the greatest fixpoint of
`Present.lean`, and `Q` is finite. -/
def stabCheckSig (phi : sig.preds) : Bool :=
  decide (∀ q : Q, lab q now = true → live (fwdNowFree lab step now) q = true →
    live (bwdNowFree lab step now) q = true → lab q phi = true)

/-- **`stabCheckSig` decides the run-level condition, at every anchor**: it is `true` iff every
run anchored at `t` reads `phi` at `t`. By `onRun_iff_live` in both directions. This is a
statement about runs of a presentation; it says nothing about any model. -/
theorem stabCheckSig_iff (phi : sig.preds) (t : ℤ) :
    stabCheckSig lab step now phi = true ↔
      ∀ ρ : ℤ → Q, IsRun lab step now t ρ → lab (ρ t) phi = true := by
  unfold stabCheckSig
  rw [decide_eq_true_iff]
  constructor
  · intro h ρ hρ
    obtain ⟨hn, hf, hb⟩ := (onRun_iff_live lab step now t (ρ t)).mp ⟨ρ, hρ, rfl⟩
    exact h _ hn hf hb
  · intro h q hn hf hb
    obtain ⟨ρ, hρ, rfl⟩ := (onRun_iff_live lab step now t q).mpr ⟨hn, hf, hb⟩
    exact h ρ hρ

end StabCheck

end FormalSystem.Metalogic.WeakCanonical

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.Expressiveness FormalSystem.Semantics

/-! ## The closure instance, under `Presented` -/

section Presented

variable {F : FrameOver intOrder} [F.IsRegular] {Q : Type} [Fintype Q] [DecidableEq Q]

/-- **Conditional on `Presented`**: the liveness decider at the closure letters `clNow φ`,
`clPhi φ` agrees with `⊡φ` at the seam — `stabCheckSig_iff` composed with
`plusStab_iff_forall_run_of_presented`.

`Presented` is refuted as a completeness carrier by the wired probe
`specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` (`Probe735.not_presented`):
on model A at the seam with `φ := Fp` no finite presentation satisfies it, so on that model this
statement is vacuous. It is not a decision procedure for `⊡` on any model in the tree, it is not
a decision procedure for `PlusValidZTime`, and nothing here mentions validity.

Paper: — (the formalization's own device) -/
theorem stabCheck_iff_of_presented (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool)
    (hP : Presented M τ t φ lab step) :
    stabCheckSig lab step (clNow φ) (clPhi φ) = true ↔ PlusTruthAt M τ t (.stab φ) := by
  rw [stabCheckSig_iff lab step (clNow φ) (clPhi φ) t,
    plusStab_iff_forall_run_of_presented M τ t φ lab step hP]

/-- **Conditional on `Presented`**: `⊡φ` at the seam is decidable, by `stabCheckSig`.

The hypothesis `hP` is explicit and is refuted on model A by
`specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` for every finite
presentation, so this instance is vacuous there: it is not a decision procedure for `⊡` on any
model in the tree, and it is not a decision procedure for `PlusValidZTime` — nothing here
mentions validity, and no enumeration of presentations can reach it (a refuting model need not
have one). A `def`, not an `instance`: the hypothesis must be supplied by hand.

Paper: — (the formalization's own device) -/
def decidableStabOfPresented (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool)
    (hP : Presented M τ t φ lab step) :
    Decidable (PlusTruthAt M τ t (.stab φ)) :=
  decidable_of_iff _ (stabCheck_iff_of_presented M τ t φ lab step hP)

end Presented

end FormalSystem.Metalogic.Decidability.RaySummary
