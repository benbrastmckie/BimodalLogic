/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.FrameProperty
import FormalSystem.Semantics.StarLanguage.StarDeterminism
import FormalSystem.Semantics.StarLanguage.StarNonValidities
import FormalSystem.Semantics.StarLanguage.StarStateLocal

/-!
# `F^N` — forward-deterministic, not deterministic

The separating frame that shows `sent:det` defines only **forward** determinism:

```
W = ℕ                          D = ⟨ℤ, +, 0, ≤⟩
f(0) = 0,  f(n) = n − 1        w ⇒_n u  iff  u = fⁿ(w)  for n ≥ 0
                               (n < 0 by the converse convention)
```

`F^N` is Laplacian about the future and indeterminate about the past: the absorbing predecessor
map is a *semiflow*, not a flow. It is forward-deterministic — every `⇒_d` with `d ≥ 0` is a
function — and **not** `Deterministic`, because `fib(0, −1) = {0, 1}`.

## Main Definitions

- `fnRel` — the task relation, in the sign-symmetric `max`-form described below
- `FN` — `F^N` as a `TaskFrame`

## Main Results

- `fn_forwardDeterministic` — `FN.ForwardDeterministic`
- `fn_not_deterministic` — `¬ FN.Deterministic`
- `states_eq_of_forwardDeterministic` — the forward analogue of `states_eq_of_deterministic`:
  possible worlds agreeing at `x` agree at every `y ≥ x`, and **not** before `x`
- `fn_sentDet_stateLocal` — `sent:det` at any **state-local** instance is valid over `FN`
- `fn_separates` — the separation: `sent:det` is valid over `FN` at every state-local instance
  while `FN` is not deterministic, so no reading of `app:deterministic-future` may be
  strengthened to a characterization
- `fn_refutes_sentDet_somePast` — the *schematic* reading of that validity is **false**: `FN`
  refutes `sent:det` at the past-looking instance `P p`
- `fn_sentDet_bounds` — the two-sided bound, as one machine-checked object: valid at every
  state-local instance, and refuted at a specific instance outside the fragment

## The relation is defined in a sign-symmetric `max`-form

Writing the relation as a case split on `sign d` makes `converse` a case analysis at every use
site. Instead:

```
fnRel w d u  :=  (u : ℤ) = max 0 ((w : ℤ) − d)  ∨  (w : ℤ) = max 0 ((u : ℤ) + d)
```

The two disjuncts are each other's reflection, so `converse` is literally `Or.comm`. And the
disjunction is not a weakening: for `d ≥ 0` the second disjunct is *contained in* the first (from
`u, d ≥ 0` it gives `w = u + d`, hence `u = w − d ≥ 0`, hence `u = max 0 (w − d)`), and for
`d ≤ 0` the first is contained in the second. So at each sign the disjunction collapses to the
intended clause — which is what `fn_rel_iff_of_nonneg` and `fn_rel_iff_of_nonpos` record.

## Why the carrier must be infinite

On a **finite** `W`, *Seriality* makes each `⇒_x` (`x ≥ 0`) surjective, and a surjective function
on a finite set is injective; so forward determinism already entails backward determinism there,
and no finite frame can separate the two notions. `W = ℕ` is not an incidental choice
(the PossibleWorlds determinism-axiom-correspondence report, §3.3, consequence 4).

## *Saturation* needs the finite-**fibres** helper

`cor:saturation-finite` (`TaskFrame.saturation_of_finite`) is the finite-**carrier** result and
does not apply: `ℕ` is infinite. `saturation_of_fib_subsingleton` does not apply either: the
negative-duration fibre `fib(0, −1) = {0, 1}` is not a subsingleton. What does apply is
`TaskFrame.saturation_of_fib_finite` (`Semantics/TaskFrame.lean`), landed for exactly this
consumer: every fibre of `fnRel` is contained in `Set.Iic (w + |d|)` and hence finite.

## References

* The PossibleWorlds `02_determinism-axiom-correspondence.md` report, §3.3 — the frame,
  machine-verified, and its four consequences
* JPL paper `sent:det`, `app:deterministic-future`, `lem:deterministic-singleton`,
  `def:deterministic`
* `FormalSystem/Semantics/FrameProperty.lean` — `TaskFrame.ForwardDeterministic`
* `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame.saturation_of_fib_finite`

## Tags

independence · forward-determinism · sent:det · separating-frame
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.StarLanguage

/-! ## The relation -/

/-- `F^N`'s task relation, in the sign-symmetric `max`-form (see the module docstring). For
`d ≥ 0` it says `u = w ∸ d`, the `d`-fold absorbing predecessor; for `d < 0` it is the converse
of that. -/
def fnRel (w : ℕ) (d : ℤ) (u : ℕ) : Prop :=
  ((u : ℤ) = max 0 ((w : ℤ) - d)) ∨ ((w : ℤ) = max 0 ((u : ℤ) + d))

/-- At a **nonnegative** duration the relation is the functional clause `u = w ∸ d`. -/
theorem fn_rel_iff_of_nonneg {w : ℕ} {d : ℤ} {u : ℕ} (hd : 0 ≤ d) :
    fnRel w d u ↔ (u : ℤ) = max 0 ((w : ℤ) - d) := by
  constructor
  · rintro (h | h)
    · exact h
    · have hw : (0 : ℤ) ≤ (w : ℤ) := Int.natCast_nonneg w
      have hu : (0 : ℤ) ≤ (u : ℤ) := Int.natCast_nonneg u
      omega
  · exact Or.inl

/-- At a **nonpositive** duration the relation is the reflected clause. -/
theorem fn_rel_iff_of_nonpos {w : ℕ} {d : ℤ} {u : ℕ} (hd : d ≤ 0) :
    fnRel w d u ↔ (w : ℤ) = max 0 ((u : ℤ) + d) := by
  constructor
  · rintro (h | h)
    · have hw : (0 : ℤ) ≤ (w : ℤ) := Int.natCast_nonneg w
      have hu : (0 : ℤ) ≤ (u : ℤ) := Int.natCast_nonneg u
      omega
    · exact h
  · exact Or.inr

/-! ## The `FrameOver` obligations -/

/-- A zero-duration step changes nothing: both disjuncts collapse to `u = w`. This is the
hypothesis `fn_limit` hands to `TaskFrame.limit_of_succOrder`. -/
theorem fn_eq_of_zero (w u : ℕ) (h : fnRel w 0 u) : u = w := by
  rcases h with h | h <;>
  · have hw : (0 : ℤ) ≤ (w : ℤ) := Int.natCast_nonneg w
    have hu : (0 : ℤ) ≤ (u : ℤ) := Int.natCast_nonneg u
    omega

/-- The converse convention, by `Or.comm` on the two reflected disjuncts. -/
theorem fn_reflection (w : ℕ) (d : ℤ) (u : ℕ) : fnRel w d u ↔ fnRel u (-d) w := by
  unfold fnRel
  rw [sub_neg_eq_add, ← sub_eq_add_neg]
  exact Or.comm

/-- *Seriality*: `w ∸ x` is an `x`-successor of `w`, and `w + x` an `x`-predecessor. -/
theorem fn_serial : TaskFrame.Serial (D := TemporalOrder.of ℤ) fnRel := by
  intro w x hx
  have hx' : (0 : ℤ) ≤ x := hx
  have hw : (0 : ℤ) ≤ (w : ℤ) := Int.natCast_nonneg w
  constructor
  · refine ⟨((w : ℤ) - x).toNat, Or.inl ?_⟩
    rw [Int.toNat_eq_max]
    exact max_comm _ _
  · refine ⟨((w : ℤ) + x).toNat, Or.inl ?_⟩
    have hnn : (0 : ℤ) ≤ (w : ℤ) + x := by omega
    rw [Int.toNat_of_nonneg hnn]
    omega

/-- *Compositionality* on the positive cone: `(w ∸ x) ∸ y = w ∸ (x + y)`. -/
theorem fn_comp : TaskFrame.Compositional (D := TemporalOrder.of ℤ) fnRel := by
  intro w v x y hx hy
  have hx' : (0 : ℤ) ≤ x := hx
  have hy' : (0 : ℤ) ≤ y := hy
  have hw : (0 : ℤ) ≤ (w : ℤ) := Int.natCast_nonneg w
  have hv : (0 : ℤ) ≤ (v : ℤ) := Int.natCast_nonneg v
  have hxy : (0 : ℤ) ≤ x + y := by omega
  rw [fn_rel_iff_of_nonneg hxy]
  constructor
  · intro h
    refine ⟨((w : ℤ) - x).toNat, ?_, ?_⟩
    · rw [fn_rel_iff_of_nonneg hx, Int.toNat_eq_max]
      exact max_comm _ _
    · rw [fn_rel_iff_of_nonneg hy, Int.toNat_eq_max]
      rcases le_total ((w : ℤ) - x) 0 with hc | hc
      · rw [max_eq_right hc]; omega
      · rw [max_eq_left hc]; omega
  · rintro ⟨u, hu, hvv⟩
    rw [fn_rel_iff_of_nonneg hx] at hu
    rw [fn_rel_iff_of_nonneg hy] at hvv
    have hu' : (0 : ℤ) ≤ (u : ℤ) := Int.natCast_nonneg u
    omega

/-- *Limit*, from `TaskFrame.limit_of_succOrder`: `ℤ` is a `SuccOrder` with `NoMaxOrder`, and
`fn_eq_of_zero` supplies the hypothesis. -/
theorem fn_limit :
    ∀ w u, (∀ x : ℤ, 0 < x → ∃ y, |y| < x ∧ fnRel w y u) → u = w :=
  TaskFrame.limit_of_succOrder (D := ℤ) fn_eq_of_zero

/-- Every fibre is bounded above by `w + |d|`. Both disjuncts of `fnRel` force it: the first
gives `u ≤ max 0 (w - d) ≤ w + |d|` outright, and the second gives either `u = w - d ≤ w + |d|`
or `u ≤ -d ≤ |d|`. -/
theorem fn_fib_subset (w : ℕ) (d : ℤ) :
    TaskFrame.Fib (D := TemporalOrder.of ℤ) fnRel w d ⊆
      ↑(Finset.range (w + d.natAbs + 1)) := by
  intro u hu
  have hu' : fnRel w d u := hu
  have hw : (0 : ℤ) ≤ (w : ℤ) := Int.natCast_nonneg w
  have huu : (0 : ℤ) ≤ (u : ℤ) := Int.natCast_nonneg u
  simp only [Finset.coe_range, Set.mem_Iio]
  rcases hu' with h | h <;> omega

/-- Every fibre is finite — the hypothesis `TaskFrame.saturation_of_fib_finite` consumes. -/
theorem fn_fib_finite (w : ℕ) (d : ℤ) :
    (TaskFrame.Fib (D := TemporalOrder.of ℤ) fnRel w d).Finite :=
  Set.Finite.subset (Finset.range (w + d.natAbs + 1)).finite_toSet (fn_fib_subset w d)

/-- *Saturation*, via the finite-**fibres** helper. `cor:saturation-finite` does not apply: `ℕ`
is infinite. -/
theorem fn_saturation : TaskFrame.Saturation (D := TemporalOrder.of ℤ) fnRel :=
  TaskFrame.saturation_of_fib_finite fn_fib_finite

/-! ## The frame -/

/-- **`F^N` is a task frame**: all five `FrameOver` axiom fields. `@[reducible]` for the same
reason `fzeroFrame` carries it — without it `FN.WorldState` does not reduce to `ℕ`. -/
@[reducible] def fnFrameOver : FrameOver (TemporalOrder.of ℤ) where
  WorldState := ℕ
  PosRel w x u := fnRel w x u
  comp := TaskFrame.compositional_reflect_of_reflective fn_reflection fn_comp
  serial := TaskFrame.serial_reflect_of_reflective fn_reflection fn_serial
  limit := TaskFrame.limit_reflect_of_reflective fn_reflection fn_limit
  saturation := TaskFrame.saturation_reflect_of_reflective fn_reflection fn_saturation

/-- `F^N` as a `TaskFrame`. -/
@[reducible] def FN : TaskFrame := fnFrameOver.toTaskFrame

/-- `F^N`'s task relation, definitionally. -/
theorem fn_taskRel_iff (w : ℕ) (d : ℤ) (u : ℕ) : FN.TaskRel w d u ↔ fnRel w d u :=
  TaskFrame.reflect_restrict_iff (R := fnRel) fn_reflection

/-! ## Forward-deterministic, not deterministic -/

/-- **`F^N` is forward-deterministic**: at a nonnegative duration the relation is the function
`w ↦ w ∸ d`, so its fibres are subsingletons. -/
theorem fn_forwardDeterministic : FN.ForwardDeterministic := by
  intro w d hd u hu u' hu'
  rw [TaskFrame.mem_Fib, fn_taskRel_iff, fn_rel_iff_of_nonneg hd] at hu hu'
  exact_mod_cast hu.trans hu'.symm

/-- **`F^N` is not deterministic**: `0 ⇒₋₁ 0` and `0 ⇒₋₁ 1`, i.e. `fib(0, −1) = {0, 1}`. The
absorbing state has two `(−1)`-predecessors, which is exactly the past-indeterminacy the frame
was built to exhibit. -/
theorem fn_not_deterministic : ¬ FN.Deterministic := by
  rw [TaskFrame.deterministic_iff]
  intro h
  have h0 : fnRel 0 (-1) 0 := Or.inr (by norm_num)
  have h1 : fnRel 0 (-1) 1 := Or.inl (by norm_num)
  exact absurd (h 0 0 1 (-1) ((fn_taskRel_iff _ _ _).mpr h0) ((fn_taskRel_iff _ _ _).mpr h1))
    (by decide)

/-- Forward determinism is *strictly* weaker than determinism, witnessed. -/
theorem forwardDeterministic_not_deterministic :
    ∃ F : TaskFrame, F.ForwardDeterministic ∧ ¬ F.Deterministic :=
  ⟨FN, fn_forwardDeterministic, fn_not_deterministic⟩

/-! ## The forward engine and what `sent:det` actually defines -/

/--
**The forward analogue of `states_eq_of_deterministic`.** On a forward-deterministic frame, two
possible worlds agreeing on their world state at `x` agree at every time `y ≥ x`.

This is `states_eq_of_deterministic`'s proof (`Semantics/PlusLanguage/PlusDeterminism.lean`) with the duration
`y - x` now **nonnegative**, which is exactly the instance the guarded binder supports. Note what
is *not* concluded: nothing about `y < x`, and `F^N`'s own two possible worlds
`τ ≡ 0` and `σ(n) = max(0, −n)` agree at `0` while differing at every negative time.
-/
theorem states_eq_of_forwardDeterministic {F : TaskFrame} (hD : F.ForwardDeterministic)
    {τ σ : PartialHistory F} (hτ : τ.IsTotal) (hσ : σ.IsTotal) {x : F.Duration}
    (h : SameStateAt τ σ x) {y : F.Duration} (hxy : x ≤ y) :
    τ.states y (hτ y) = σ.states y (hσ y) := by
  have hτr := τ.respects_task x y (hτ x) (hτ y)
  have hσr := σ.respects_task x y (hσ x) (hσ y)
  rw [h (hτ x) (hσ x)] at hτr
  exact hD (σ.states x (hσ x)) (y - x) (sub_nonneg.mpr hxy) hτr hσr

/--
**`sent:det` is valid over `F^N` at every state-local instance.**

`sentDet_unfold`'s `∀ y > x` restriction is what makes the forward engine sufficient: at each
`y > x`, forward determinism gives `σ(y) = τ(y)` for every `σ ∈ ⟨τ⟩ₓ`, and a **state-local** `φ`
(`Semantics/StarLanguage/StarStateLocal.lean`) cannot distinguish two possible worlds carrying the same world
state at the time of evaluation. One disjunct of `settledDisj` then holds outright.

This is the principled closure of the sentence-letter form this theorem replaces. That form gave
as its reason "an atom's truth depends on nothing but the state at the time of evaluation" — a
reason that is not about atoms at all, but about state-locality, and
`StarFormula.StateLocal` is exactly the syntactic fragment carrying it. The old statement is
recovered as the instance `fn_sentDet_stateLocal (.atom p) (stateLocal_atom p)`; nothing is lost
by retiring it.

The fragment is strictly wider than the atoms: it contains `⊥`, is closed under `→` (hence under
`¬`, `∧`, `∨`), admits `□φ` and `⊡φ` for **arbitrary** `φ`, and admits `↑ⁱ`. What it excludes —
`U`, `S` and `↓ⁱ` — it excludes by theorem, each with a countermodel
(`not_isStateLocal_someFuture`, `not_isStateLocal_somePast`, `not_isStateLocal_timeRecall`).

Paper: — (the manuscript has no forward-determinism separation: the result is report-level, from
the PossibleWorlds determinism-axiom-correspondence report, §3.2, Theorem A, and this statement is
strictly stronger than that report's, which is stated at sentence letters)
-/
theorem fn_sentDet_stateLocal (φ : StarFormula) (hφ : φ.StateLocal) :
    FN.StarValidOn (sentDet φ) := by
  refine TaskFrame.StarValidOn.of_forall_total ?_
  intro M τ hτ x v
  rw [sentDet_unfold]
  intro y hy
  rw [settledDisj_iff, update_two_apply_two]
  by_cases hp : StarTruthAt M τ y (Function.update (Function.update v 1 x) 2 y) φ
  · refine Or.inr fun σ hσ hsame => ?_
    refine (isStateLocal_of_stateLocal hφ FN M τ σ hτ hσ y _ ?_).mp hp
    exact fun _ _ =>
      states_eq_of_forwardDeterministic fn_forwardDeterministic hτ hσ hsame (le_of_lt hy)
  · refine Or.inl fun σ hσ hsame hcon => hp ?_
    refine (isStateLocal_of_stateLocal hφ FN M τ σ hτ hσ y _ ?_).mpr hcon
    exact fun _ _ =>
      states_eq_of_forwardDeterministic fn_forwardDeterministic hτ hσ hsame (le_of_lt hy)

/--
**The separation.** `sent:det` is valid over `F^N` at every state-local instance, while `F^N` is
not deterministic. So no reading of `app:deterministic-future` may be strengthened to a
characterization of the deterministic frames: what `sent:det` defines is *forward* determinism.

Contrast `deterministic_starDefinable` (`Semantics/StarLanguage/StarDeterminism.lean`), where replacing
`\Future` by `always` closes exactly this gap — `always` reaches the past, and the past is where
`F^N` is indeterminate.

Stated as one conjunction so that neither half can be read alone.
-/
theorem fn_separates :
    (∀ φ : StarFormula, φ.StateLocal → FN.StarValidOn (sentDet φ)) ∧ ¬ FN.Deterministic :=
  ⟨fn_sentDet_stateLocal, fn_not_deterministic⟩

/--
`lem:deterministic-singleton` genuinely requires the **bidirectional** reading of
`def:deterministic`.

Weakening `def:deterministic` to the guarded `0 ≤ d` binder would make `F^N` deterministic
(`fn_forwardDeterministic`) while `F^N` has a possible world whose stability class is not a
singleton — the frame is not deterministic in the real sense (`fn_not_deterministic`), so
`deterministic_iff_singletonClasses` would become false under that weakening. Recorded as a
statement rather than only as prose, since it is the reason `TaskFrame.Deterministic`'s
unrestricted binder is a correctness requirement (the PossibleWorlds
determinism-axiom-correspondence report, §3.3, consequence 2).
-/
theorem fn_forwardDeterministic_not_singletonClasses :
    FN.ForwardDeterministic ∧ ¬ FN.SingletonClasses :=
  ⟨fn_forwardDeterministic,
   fun h => fn_not_deterministic (deterministic_of_singletonClasses h)⟩

/-! ## The schematic reading of `fn_sentDet` is false

`fn_sentDet_stateLocal` above is stated at a **state-local** instance, and that restriction is
not a convenience. The schematic form — `∀ φ : StarFormula, FN.StarValidOn (sentDet φ)` — is
**refutable**, and the two theorems below are the machine-checked refutation.

The reason is exactly the reason `F^N` exists: forward determinism settles the *future* and says
nothing about the past. `states_eq_of_forwardDeterministic` gives agreement at every `y ≥ x` and
at no earlier time, so a `φ` whose truth at `y` looks *backwards* — `P p`, say — can differ
between two possible worlds of `⟨τ⟩ₓ` at the very `y > x` that `sent:det` tests. That is what
`fnRampHist` and `fnZeroHist` witness: they agree at `0` and differ at every negative time.

The result this module transcribes (the PossibleWorlds determinism-axiom-correspondence
report, §3.2, Theorems A and B) is stated at the sentence-letter level: frame validity quantifies
over all valuations, and the argument runs the singleton valuation `|p| = {τ(y)}`. Nothing there
claims, or needs, the schematic form. `fn_sentDet_stateLocal` widens that report's Theorem A to
the whole state-local fragment, and `fn_sentDet_bounds` records the widened statement together
with the refutation, so the two-sided bound is one object rather than two paragraphs. -/

/-- The constant possible world `τ ≡ 0` of `F^N` — the absorbing state, held forever. -/
def fnZeroHist : PartialHistory FN :=
  PartialHistory.ofTotal FN (fun _ => 0) <| by
    intro s t
    refine (fn_taskRel_iff _ _ _).mpr ?_
    show fnRel 0 (t - s) 0
    unfold fnRel
    rcases le_total s t with h | h
    · have h' : (0 : ℤ) ≤ t - s := sub_nonneg.mpr h
      left; push_cast; omega
    · have h' : (0 : ℤ) ≤ s - t := sub_nonneg.mpr h
      right; push_cast; omega

theorem fnZeroHist_isTotal : fnZeroHist.IsTotal := PartialHistory.ofTotal_isTotal _ _ _

/-- The ramp possible world `σ(n) = max(0, −n)` of `F^N`: it descends to the absorbing state by
time `0` and stays there. It agrees with `fnZeroHist` at `0` and differs at every negative
time — the pair the PossibleWorlds determinism-axiom-correspondence report, §3.3, exhibits. -/
def fnRampHist : PartialHistory FN :=
  PartialHistory.ofTotal FN (fun n => (-n).toNat) <| by
    intro s t
    refine (fn_taskRel_iff _ _ _).mpr ?_
    show fnRel ((-s).toNat) (t - s) ((-t).toNat)
    unfold fnRel
    rcases le_total s t with h | h
    · have h' : (0 : ℤ) ≤ t - s := sub_nonneg.mpr h
      left; rw [Int.toNat_eq_max, Int.toNat_eq_max]; omega
    · have h' : (0 : ℤ) ≤ s - t := sub_nonneg.mpr h
      right; rw [Int.toNat_eq_max, Int.toNat_eq_max]; omega

theorem fnRampHist_isTotal : fnRampHist.IsTotal := PartialHistory.ofTotal_isTotal _ _ _

/-- The two possible worlds agree at time `0`: both are at the absorbing state there. -/
theorem fn_hists_sameStateAt_zero :
    SameStateAt fnZeroHist fnRampHist (0 : ℤ) := by
  intro _ _
  show (0 : ℕ) = ((-(0 : ℤ)).toNat)
  norm_num

/-- The model with `|p| = {3}` — a state the ramp world occupies at time `−3` and the constant
world never occupies. -/
def fnModel : TaskModel FN where
  valuation := fun n _ => n = 3

/--
**The schematic reading of `sent:det`'s validity over `F^N` is false.**

`F^N` refutes `sent:det` at the past-looking instance `P p`: at `(τ, 0)` with register `2`
holding `1`, the ramp world `σ ∈ ⟨τ⟩₀` satisfies `P p` at time `1` (it was at state `3` at time
`−3`) while `τ ≡ 0` refutes it, so neither disjunct of `settledDisj` can hold.

This is what confines `fn_sentDet_stateLocal` to the state-local fragment, and it is recorded as a theorem
rather than as prose because the distinction is easy to lose: `sentDet_of_deterministic`
**is** schematic (full determinism gives agreement at every time, past included), and only the
forward-deterministic case degrades.
-/
theorem fn_refutes_sentDet_somePast (p : Atom) :
    ¬ FN.StarValidOn (sentDet (StarFormula.somePast (StarFormula.atom p))) := by
  refine not_starValidOn_sentDet fnModel fnZeroHist fnZeroHist_isTotal
    (0 : ℤ) (1 : ℤ) (by norm_num) fnRampHist fnZeroHist
    fnRampHist_isTotal fnZeroHist_isTotal fn_hists_sameStateAt_zero
    (SameStateAt.refl _ _) ?_ ?_
  · -- the ramp world was at state `3` at time `−3`, so `P p` holds for it at time `1`
    intro v
    rw [StarTruth.somePast_iff]
    refine ⟨(-3 : ℤ), ?_, ⟨trivial, ?_⟩⟩
    · show (-3 : ℤ) < (1 : ℤ)
      omega
    · show ((-(-3 : ℤ)).toNat) = 3
      decide
  · -- the constant world is never at state `3`, so `P p` fails for it at every time
    intro v h
    rw [StarTruth.somePast_iff] at h
    obtain ⟨_, _, _, hval⟩ := h
    have h3 : (0 : ℕ) = 3 := hval
    omega

/-- The schematic form is refutable outright: some `StarFormula` instance of `sent:det` fails
over the forward-deterministic frame `F^N`. -/
theorem not_forall_fn_sentDet :
    ¬ ∀ φ : StarFormula, FN.StarValidOn (sentDet φ) :=
  fun h => fn_refutes_sentDet_somePast (Atom.mkBase "p")
    (h (StarFormula.somePast (StarFormula.atom (Atom.mkBase "p"))))

/--
**The two-sided bound on `sent:det` over `F^N`, as one machine-checked object.**

Above: valid at *every* state-local instance. Below: refuted at `P p`, which is outside the
fragment (`not_stateLocal_somePast`). So the truth is pinned from both sides — the validity is
not merely "at atoms" and not "schematic", it is exactly the state-local fragment on the
positive side and demonstrably not everything on the negative side.

The middle conjunct is what makes the pair non-vacuous: it certifies that the refuting instance
really does fall outside the fragment the first conjunct quantifies over, so the two halves
cannot be contradicting each other.

Paper: — (the manuscript has no forward-determinism separation, so it has no two-sided bound on
one either: both halves are report-level results of the PossibleWorlds
determinism-axiom-correspondence report, §3.2-§3.3)
-/
theorem fn_sentDet_bounds (p : Atom) :
    (∀ φ : StarFormula, φ.StateLocal → FN.StarValidOn (sentDet φ)) ∧
      ¬ StarFormula.StateLocal (StarFormula.somePast (.atom p)) ∧
      ¬ FN.StarValidOn (sentDet (StarFormula.somePast (.atom p))) :=
  ⟨fn_sentDet_stateLocal, not_stateLocal_somePast _, fn_refutes_sentDet_somePast p⟩

end FormalSystem.Metalogic.Independence
