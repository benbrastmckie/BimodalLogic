/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.StarLanguage.StarValidity
import FormalSystem.Semantics.DeterministicBridge

/-!
# `app:deterministic-future`'s positive half, `Det-pm`, and the definability theorem

Three results, in increasing strength:

1. **`app:deterministic-future`, positive half** — `sent:det` is valid over every deterministic
   task frame, for every `StarFormula` argument. This is the safe direction (frame condition ⟹
   validity) and is choice-free relative to the L⋆ apparatus.
2. **`Det-pm`** — `sent:det` with the universal future `\Future` replaced by `always` `△` — is
   likewise valid over every deterministic frame, at every `StarFormula` argument, by the same
   engine.
3. **The definability theorem** — a **three-way** equivalence: `Det-pm`'s validity at bare
   sentence letters, `F.Deterministic`, and `Det-pm`'s validity at every `StarFormula` are all
   equivalent. The atomic fragment already **forces** determinism, and determinism **delivers**
   the full schema. The (⇐) direction is (2); the (⇒) direction runs the singleton valuation and
   closes through `deterministic_of_singletonClasses`, and is therefore a theorem of **ZFC**.

## Main Definitions

- `detPM` — `Det-pm`, `sent:det`'s shape with `always` in place of `\Future`, at an arbitrary
  `StarFormula`

## Main Results

- `star_congr_of_deterministic` — the L⋆ collapse engine: over a deterministic frame, two
  possible worlds agreeing at one time satisfy the same `StarFormula` at every time and every
  stored-time vector
- `sentDet_of_deterministic` — `app:deterministic-future`, positive half
- `detPM_unfold`, `detPM_of_deterministic` — `Det-pm` and its validity over deterministic frames,
  at every `StarFormula`
- `deterministic_of_detPM` — the (⇒) direction, from the atomic fragment alone, via the singleton
  valuation
- `deterministic_starDefinable` — **Theorem C, `Det-pm` half**, as a three-way equivalence

## Theorem C is a report-level result, pending paper integration

`Det-pm` and the definability equivalence are **not manuscript text**. They are recorded in the
PossibleWorlds repository's determinism-axiom-correspondence report
(`reports/02_determinism-axiom-correspondence.md`, §4), whose §4.1 also records that a *single*
sentence letter suffices for the converse direction. That report is the citation of record for them here: they are cited as a
**report-level result pending paper integration**, never as manuscript text and never as a
conjecture. What *is* manuscript text is `sent:det` and `app:deterministic-future`, which are
results (1) and `Semantics/StarLanguage/StarNonValidities.lean` below.

## The single sentence letter is not uniform substitution

`deterministic_of_detPM` takes the validity of `detPM (StarFormula.atom p)` for atoms `p` and
concludes a frame condition. That is legitimate for the reason the
determinism-axiom-correspondence report's §4.1 gives: the forward direction is proved for an
**arbitrary** `StarFormula` on both sides of the module — `sentDet_of_deterministic` and
`detPM_of_deterministic` below each quantify over `φ : StarFormula` — while the converse needs
only **one valuation**, the singleton `|p| = {τ(y)}` at a single letter, to manufacture its
separating witness. The two are proved independently: no instance of the schema is inferred from
another, so this is not an appeal to uniform substitution, which is **unsound here**: `p → ⊡p` is
frame-valid over the drift frame `F°` while `Fp → ⊡Fp` is refutable over it
(`Metalogic/Independence/`).

This asymmetry is what `deterministic_starDefinable` records as a three-way equivalence rather
than a biconditional: the atomic fragment is the **weakest** hypothesis that forces determinism,
and the full schema is the **strongest** conclusion determinism delivers.

## Choice dependence

The asymmetry between the two directions is **structural**, and must be read structurally: it is
a difference in which lemmas each direction routes through, **not** a difference in
`#print axioms`. Measured, not assumed: `settledDisj_of_deterministic`,
`sentDet_of_deterministic`, `detPM_of_deterministic`, `deterministic_of_detPM` and
`deterministic_starDefinable` all report the same axiom set,
`[propext, Classical.choice, Quot.sound]`, because `Classical.choice` is ambient in the L⋆
apparatus (`StarTruth`'s classical `or_iff`). No `#print axioms` figure distinguishes the two
directions, and none should be read as doing so.

The (⇐) direction — `sentDet_of_deterministic` and `detPM_of_deterministic`, both schematic in
`φ` — consumes `states_eq_of_deterministic` through `star_truth_congr_ext` (via
`star_congr_of_deterministic`) and adds **no extension-theorem step**. Its `Classical.choice` is
the ambient one and carries no Zorn dependence.

The (⇒) direction — `deterministic_of_detPM`, whose hypothesis is the atomic fragment — and hence
the three-way `deterministic_starDefinable`, route through `deterministic_of_singletonClasses`
(`Semantics/DeterministicBridge.lean`), which manufactures separating possible worlds by
`thm:extension` and hence by Zorn's lemma. They are **theorems of ZFC**. No `Classical.choice`-free
pin is promised or attempted for them, and none should be: this is the
"validity ⟹ frame condition" direction, which is ZFC by construction (the archived
correspondence-record-and-store-recall-recommendation report, §II.4's choice-asymmetry table).

## References

* JPL paper `app:deterministic-future` (statement and the `(∗)` chain), `sent:det`,
  `lem:deterministic-singleton`, `def:BLstar-semantics`
* The PossibleWorlds `02_determinism-axiom-correspondence.md` report, §4 — Theorem C,
  `Det-pm`, and the §4.1 single-letter note
* `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean` — `states_eq_of_deterministic`, the L⁺ collapse
* `FormalSystem/Semantics/StarLanguage/StarNonValidities.lean` — `app:deterministic-future`'s negative half

## Tags

determinism · star-language · sent:det · definability · app:deterministic-future
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.StarLanguage

variable {F : TaskFrame}

/-! ## The L⋆ collapse engine -/

/--
**The L⋆ collapse at a point.** Over a deterministic frame, two possible worlds that agree on
their world state at a single time satisfy the same `StarFormula` at *every* time and *every*
stored-time vector.

This is the L⋆ twin of `stab_iff_of_deterministic` (`Semantics/PlusLanguage/PlusDeterminism.lean`) and the
engine both validity results below run on. It consumes the singleton bridge
(`states_eq_of_deterministic`) rather than re-deriving the collapse, and transports along
`star_truth_congr_ext` — the transport lemma that survives time registers because it fixes the
vector on both sides.
-/
theorem star_congr_of_deterministic (hD : F.Deterministic) (M : TaskModel F)
    {τ σ : WorldHistory F} {x : F.Duration}
    (hsame : τ.state x = σ.state x) (y : F.Duration) (v : ℕ → F.Duration) (φ : StarFormula) :
    StarTruthAt M τ y v φ ↔ StarTruthAt M σ y v φ :=
  star_truth_congr_ext M φ τ σ y v (states_eq_of_deterministic hD hsame)

/--
**Every future time is settled, on a deterministic frame.** The common core of
`sentDet_of_deterministic` and `detPM_of_deterministic`: at any time `y` whatsoever, the
disjunction `settledDisj φ` holds at `(τ, x, v)` whenever `v 2 = y`.

This is the manuscript's own two-line argument: split on whether `φ` holds at `(τ, y, v)`; in
the positive case the engine carries `φ` to every `σ ∈ ⟨τ⟩_x`, giving the `⊡↓²φ` disjunct, and
in the negative case it carries the failure, giving `⊡↓²¬φ`.
-/
theorem settledDisj_of_deterministic (hD : F.Deterministic) (M : TaskModel F)
    (τ : WorldHistory F) (x : F.Duration) (v : ℕ → F.Duration)
    (φ : StarFormula) :
    StarTruthAt M τ x v (settledDisj φ) := by
  rw [settledDisj_iff]
  by_cases hφ : StarTruthAt M τ (v 2) v φ
  · exact Or.inr fun σ hsame =>
      (star_congr_of_deterministic hD M hsame (v 2) v φ).mp hφ
  · exact Or.inl fun σ hsame h =>
      hφ ((star_congr_of_deterministic hD M hsame (v 2) v φ).mpr h)

/-! ## `app:deterministic-future`, positive half -/

/--
**`app:deterministic-future`, positive half.** `sent:det` is valid over every deterministic task
frame, at every `StarFormula` instance.

`sentDet_unfold` reduces the goal to the manuscript's last line of `(∗)`, and
`settledDisj_of_deterministic` discharges it. The `∀ y > x` restriction that `\Future` imposes
is not used: the engine settles *every* time, which is exactly why `Det-pm` — the `always`
variant — is available below at no extra cost, and why `sent:det` alone defines only forward
determinism (`Metalogic/Independence/ForwardDeterministicFrame.lean`).

Axiom pin, recorded from `#print axioms` at the time of writing: `[propext, Classical.choice,
Quot.sound]`. The `Classical.choice` comes from the ambient L⋆ apparatus (`StarTruth`'s classical
`or_iff`), **not** from `thm:extension` — this result does not route through
`deterministic_of_singletonClasses` and carries no Zorn dependence.
-/
theorem sentDet_of_deterministic (hD : F.Deterministic) (φ : StarFormula) :
    F.StarValidOn (sentDet φ) := by
  intro M τ x v
  rw [sentDet_unfold]
  intro y _
  exact settledDisj_of_deterministic hD M τ x _ φ

/-! ## `Det-pm` — Theorem C's sentence -/

/--
**`Det-pm`**: `sent:det`'s shape with the universal future `\Future` replaced by the temporal
`always` `△`, at an arbitrary `StarFormula`:

`↑¹ △ ↑² ↓¹ (⊡ ↓² ¬φ ∨ ⊡ ↓² φ)`.

The schema is `sentDet`'s body with `always` in place of `allFuture`, so the two run on the same
engine `settledDisj_of_deterministic`. `detPM (StarFormula.atom p)` is the **atomic instance**,
and it is that instance alone that `deterministic_of_detPM` consumes: §4.1's observation that one
sentence letter suffices for the converse is what makes the converse's hypothesis the weakest
available, and it is *not* an appeal to uniform substitution (see this module's docstring).

Transcribed from the PossibleWorlds determinism-axiom-correspondence report, §4 — a
**report-level result pending paper integration**, not manuscript text.
-/
def detPM (φ : StarFormula) : StarFormula :=
  .timeStore 1 (StarFormula.always (.timeStore 2 (.timeRecall 1 (settledDisj φ))))

/--
**The `always` analogue of `sentDet_unfold`.**

The manuscript's `(∗)` chain transfers verbatim, because no temporal operator disturbs the
stored-time vector; the one new ingredient is `always`'s three-way unfolding into
`H · ∧ · ∧ G ·`, whose three arms reassemble into the single unrestricted `∀ y` by trichotomy.
-/
theorem detPM_unfold (M : TaskModel F) (τ : WorldHistory F) (x : F.Duration)
    (v : ℕ → F.Duration) (φ : StarFormula) :
    StarTruthAt M τ x v (detPM φ) ↔
      ∀ y : F.Duration, StarTruthAt M τ x (Function.update (Function.update v 1 x) 2 y)
        (settledDisj φ) := by
  have hQ : ∀ s : F.Duration,
      StarTruthAt M τ s (Function.update v 1 x)
          (.timeStore 2 (.timeRecall 1 (settledDisj φ))) ↔
        StarTruthAt M τ x (Function.update (Function.update v 1 x) 2 s)
          (settledDisj φ) := by
    intro s
    rw [StarTruth.timeStore_iff, StarTruth.timeRecall_iff, update_two_apply_one]
  unfold detPM
  rw [StarTruth.timeStore_iff, StarTruth.always_iff]
  constructor
  · rintro ⟨hpast, hnow, hfut⟩ y
    rcases lt_trichotomy y x with hy | hy | hy
    · exact (hQ y).mp (hpast y hy)
    · subst hy; exact (hQ y).mp hnow
    · exact (hQ y).mp (hfut y hy)
  · intro h
    exact ⟨fun s _ => (hQ s).mpr (h s), (hQ x).mpr (h x), fun s _ => (hQ s).mpr (h s)⟩

/--
**`Det-pm` is valid over every deterministic task frame, at every `StarFormula` instance.** The
(⇐) direction of Theorem C's `Det-pm` half, from the same engine as `sentDet_of_deterministic` —
the engine settles every time, so dropping `\Future`'s `y > x` restriction costs nothing, and it
settles the disjunction at an arbitrary `φ`, so the atom restriction costs nothing either.

The proof consumes `settledDisj_of_deterministic` exactly as `sentDet_of_deterministic` does. It
reaches `states_eq_of_deterministic` through `star_truth_congr_ext` (via
`star_congr_of_deterministic`) and adds no extension-theorem step.
-/
theorem detPM_of_deterministic (hD : F.Deterministic) (φ : StarFormula) :
    F.StarValidOn (detPM φ) := by
  intro M τ x v
  rw [detPM_unfold]
  intro y
  exact settledDisj_of_deterministic hD M τ x _ φ

/-! ## The definability theorem — Theorem C, `Det-pm` half -/

/--
**The (⇒) direction: `Det-pm`'s validity at bare sentence letters already forces determinism.**

The hypothesis is deliberately held at the **atomic fragment** — `detPM (StarFormula.atom p)` for
every atom `p`, and nothing more. That is the weakest hypothesis available and precisely the
strength of this converse; the schematic form is `detPM_of_deterministic`'s conclusion, not this
theorem's hypothesis.

Fix possible worlds `τ, σ` agreeing at `x` and a time `y`. Take the model over `F` whose
valuation is the **singleton** `|p| = {τ(y)}`. Then `τ` itself refutes the `⊡↓²¬p` disjunct of
`settledDisj` at register value `y`, so the `⊡↓²p` disjunct must hold; applying it to `σ` gives
`σ(y) = τ(y)`. As `y` was arbitrary this is `F.SingletonClasses`, and
`deterministic_of_singletonClasses` closes.

**This is a theorem of ZFC**, via `deterministic_of_singletonClasses`'s appeal to
`thm:extension` and hence to Zorn's lemma. `#print axioms` reports `Classical.choice`, as it
must; no choice-free pin is claimed.
-/
theorem deterministic_of_detPM
    (h : ∀ p : Atom, F.StarValidOn (detPM (StarFormula.atom p))) : F.Deterministic := by
  refine deterministic_of_singletonClasses ?_
  intro τ σ x hsame y
  set p : Atom := Atom.mkBase "p" with hp
  let M : TaskModel F := { valuation := fun w _ => w = τ.state y }
  have hvalid := h p M τ x (fun _ => 0)
  rw [detPM_unfold] at hvalid
  have hy := hvalid y
  rw [settledDisj_iff, update_two_apply_two] at hy
  rcases hy with hneg | hpos
  · exact absurd (show StarTruthAt M τ y _ (StarFormula.atom p) from rfl) (hneg τ rfl)
  · exact (show σ.state y = τ.state y from hpos σ hsame).symm

/--
**Theorem C, `Det-pm` half: `Det-pm` defines the deterministic task frames — in its strongest
form.** A three-way equivalence, hinged on `F.Deterministic`:

`(∀ p : Atom, F.StarValidOn (detPM (.atom p)))` ⟺ `F.Deterministic` ⟺
`(∀ φ : StarFormula, F.StarValidOn (detPM φ))`.

Read the two hinges in the two directions they are sharp in. The **atomic fragment already
forces** determinism: the validity of `Det-pm` at bare sentence letters alone — the weakest
hypothesis available — suffices, because the converse needs only the singleton valuation
`|p| = {τ(y)}` at one letter to manufacture its separating witness. And determinism **delivers
the full schema**: `detPM_of_deterministic` proves `detPM φ` valid at *every* `StarFormula`, not
merely at atoms. Together the two halves say that the atomic fragment and the full schema define
the same frame class, which is the sharpest form a definability theorem takes.

**This is not an appeal to uniform substitution.** No instance of the schema is inferred from
another. Each direction is proved outright — the (⇐) direction schematically in `φ` from the
engine, the (⇒) direction at one atom from the singleton valuation — and uniform substitution is
**unsound here** in any case (see this module's docstring for the drift-frame counterexample).

This is what `cor:no-characterization` shows no `PlusFormula` can do, and what the time registers
buy.

Recorded as a **report-level result pending paper integration** (the PossibleWorlds
determinism-axiom-correspondence report, §4), never as manuscript text. **A theorem of ZFC**,
through the (⇒) direction.
-/
theorem deterministic_starDefinable (F : TaskFrame) :
    ((∀ p : Atom, F.StarValidOn (detPM (StarFormula.atom p))) ↔ F.Deterministic) ∧
      (F.Deterministic ↔ ∀ φ : StarFormula, F.StarValidOn (detPM φ)) :=
  ⟨⟨deterministic_of_detPM, fun hD p => detPM_of_deterministic hD (StarFormula.atom p)⟩,
    ⟨fun hD φ => detPM_of_deterministic hD φ,
      fun h => deterministic_of_detPM fun p => h (StarFormula.atom p)⟩⟩

end FormalSystem.Semantics
