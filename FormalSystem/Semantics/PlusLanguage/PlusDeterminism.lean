/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.FrameProperty
import FormalSystem.Semantics.PlusLanguage.PlusValidity

/-!
# The deterministic collapse of the stability modal — `app:deterministic`, positive half

Over a frame satisfying `def:deterministic` the stability modal `⊡` is *semantically trivial*:
`⊡φ ↔ φ` is valid, for every `PlusFormula φ`. This module carries that result, together with the
singleton bridge it rests on.

## Main Results

- `states_eq_of_deterministic` — the **singleton bridge**, (⇒) half of
  `lem:deterministic-singleton`: two world histories of a deterministic frame that agree on their
  world state at one time agree at *every* time
- `stab_iff_of_deterministic` — the collapse at a point: `⊡φ` and `φ` are equivalent at every
  world history and time
- `determined_of_deterministic` — *Determined* `φ → ⊡φ` is frame-valid on every deterministic
  frame
- `stab_biconditional_plusValidOn_of_deterministic` — both halves of `⊡φ ↔ φ` as frame validities

Those four names are the stable import surface of this module; downstream work consumes them
rather than re-deriving the collapse.

## Why this is choice-free

The proof uses only the (⇒) half of `lem:deterministic-singleton`. It never appeals to
`thm:extension` (the Zorn-based total-history extension of `Semantics/Extension/Extension.lean`),
and it never uses the frame's `serial`, `limit` or `saturation` fields — the determinism
hypothesis alone drives every step. Choice-dependence here tracks a *direction*: the converse
reading, "*Determined* is valid over `F` ⟹ `F` is deterministic", is false as stated (see
`Metalogic/Independence/`), and the genuine converse of the *bridge* — `⟨τ⟩_x = {τ}` ⟹
deterministic — needs `thm:extension` and hence Zorn. Everything here is the safe direction.

**The statements below therefore stay implications, deliberately.** Restating
`determined_of_deterministic` as a biconditional correspondence between the deterministic frames
and the frames validating *Determined* would be both false (the drift frame `F°` validates
*Determined* without being deterministic) and, in the repairable direction, ZFC. `#print axioms`
on the four results above reports only `propext`, `Classical.choice`-free — the pin recorded
below.

## The bridge is pointwise on states, not history equality

`states_eq_of_deterministic` concludes that the two histories' *states* agree at every time, not
that the histories are equal. That is weaker than `lem:deterministic-singleton`'s `⟨τ⟩_x = {τ}`,
and it is free — it follows from `respects_task` at the pair `(t, s)` and determinism at the
possibly negative duration `s - t`. It is also sufficient: `truth_congr_ext`
(`Semantics/PlusLanguage/PlusTruth.lean`) already converts pointwise state agreement into agreement on every
`PlusFormula`, the `stab` clause included, so nothing downstream needs the stronger form.

Note where the unrestricted duration binder of `TaskFrame.Deterministic` is used: at `s - t`,
which is negative whenever `s < t`. A determinism predicate guarded by `0 ≤ d` would not close
this proof.

## Axiom pin (C4)

Recorded from `#print axioms` at the time of writing, and re-checkable by uncommenting:

```
#print axioms FormalSystem.Semantics.states_eq_of_deterministic
#print axioms FormalSystem.Semantics.stab_iff_of_deterministic
#print axioms FormalSystem.Semantics.determined_of_deterministic
#print axioms FormalSystem.Semantics.stab_biconditional_plusValidOn_of_deterministic
```

All four report `[propext]` only — in particular **no `Classical.choice`**.

## References

* JPL paper `def:deterministic`, `lem:deterministic-singleton`, `app:deterministic`
* `FormalSystem/Semantics/FrameProperty.lean` — `TaskFrame.Deterministic`
* `FormalSystem/Semantics/PlusLanguage/PlusNonValidities.lean` — `refute_determined`, the negative half of
  `app:deterministic`

## Tags

plus-language · determinism · stability-modal · app:deterministic
-/

namespace FormalSystem.Semantics

open FormalSystem.PlusLanguage

variable {F : TaskFrame}

/--
**The singleton bridge**, (⇒) half of `lem:deterministic-singleton`.

On a deterministic frame, two world histories agreeing on their world state at a single time `t`
have the same world state at *every* time `s`.

The proof is three rewrites: `respects_task t s` on each history gives
`τ.states t ⇒_{s - t} τ.states s` and likewise for `σ`; the hypothesis identifies the two sources;
determinism at the duration `s - t` identifies the two targets. `s - t` is negative whenever
`s < t`, which is precisely why `TaskFrame.Deterministic` quantifies `d` over all of `F.Duration`.
-/
theorem states_eq_of_deterministic (hD : F.Deterministic)
    {τ σ : WorldHistory F} {t : F.Duration}
    (h : τ.state t = σ.state t) (s : F.Duration) :
    τ.state s = σ.state s := by
  have hτr : F.TaskRel (τ.state t) (s - t) (τ.state s) :=
    τ.val.respects_task t s (τ.property t) (τ.property s)
  have hσr : F.TaskRel (σ.state t) (s - t) (σ.state s) :=
    σ.val.respects_task t s (σ.property t) (σ.property s)
  rw [h] at hτr
  exact hD (σ.state t) (s - t) hτr hσr

/--
**The collapse at a point**: over a deterministic frame `⊡φ` and `φ` are equivalent at every world
history and time, for every `PlusFormula φ`.

(⇒) is `of_stab` — T for `⊡` — and holds on every frame. (⇐) is where determinism enters: any
`σ ∈ ⟨τ⟩_t` agrees with `τ` at every time by `states_eq_of_deterministic`, so `truth_congr_ext`
transports the truth of `φ` from `τ` to `σ`.
-/
theorem stab_iff_of_deterministic (hD : F.Deterministic) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) :
    PlusTruthAt M τ t (.stab φ) ↔ PlusTruthAt M τ t φ := by
  constructor
  · exact of_stab M τ t φ
  · intro h σ hsame
    exact (truth_congr_ext M φ τ σ t (states_eq_of_deterministic hD hsame)).mp h

/--
**`app:deterministic`, positive half.** *Determined* — `φ → ⊡φ` — is valid on every deterministic
frame, at every instance, `φ` an arbitrary `PlusFormula`.

The negative half is `refute_determined` (`Semantics/PlusLanguage/PlusNonValidities.lean`), which refutes the
*same schema* over a non-deterministic frame. Note that the two halves do **not** compose into a
characterization: the converse fails, and demonstrably so — see `Metalogic/Independence/`, where
a non-deterministic frame validating this schema is exhibited.
-/
theorem determined_of_deterministic (hD : F.Deterministic) (φ : PlusFormula) :
    F.PlusValidOn (.imp φ (.stab φ)) :=
  fun M τ t h => (stab_iff_of_deterministic hD M τ t φ).mpr h

/--
**The full collapse** `⊡φ ↔ φ`, as the pair of frame validities. The first component holds on
every frame (it is T for `⊡`); only the second needs determinism.
-/
theorem stab_biconditional_plusValidOn_of_deterministic (hD : F.Deterministic)
    (φ : PlusFormula) :
    F.PlusValidOn (.imp (.stab φ) φ) ∧ F.PlusValidOn (.imp φ (.stab φ)) :=
  ⟨fun M τ t h => (stab_iff_of_deterministic hD M τ t φ).mp h,
   determined_of_deterministic hD φ⟩

end FormalSystem.Semantics
