/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.DriftFrame
import FormalSystem.Metalogic.Independence.RealTranslationFrame
import FormalSystem.Metalogic.Independence.DeterminismUndefinable
import FormalSystem.Semantics.StarLanguage.StarDeterminism
import FormalSystem.Semantics.StarLanguage.StarNonValidities

/-!
# The discrimination footnote — store and recall separate `F°` from `F¹`

The live-text footnote following `app:deterministic-future`, transcribed:

> Unlike *Determined* from before, `sent:det` is refuted by the drift frame `F°` of `app:drift`
> while remaining valid over the **Deterministic** translation frame `F¹`, and so the store and
> recall operators discriminate between `F°` and `F¹` where `cor:no-characterization` shows that
> no sentence without them can.

`Metalogic/Independence/DeterminismUndefinable.lean` lands the negative half of that contrast:
`F°` and `F¹` **agree** on every `PlusFormula` (`fzero_plusValidOn_iff_f1`), so no set of
`PlusFormula`s defines the deterministic frames (`deterministic_not_plusDefinable`). This module
lands the positive half: one `StarFormula` — `sent:det` — tells the two frames apart.

## Main Definitions

- `driftLinear` — the affine possible worlds `t ↦ a · t` of `F°`, for a drift rate `a ∈ [1, 2]`;
  the manuscript's `τ(t) = t` and `σ(t) = 2t` are `driftLinear 1` and `driftLinear 2`
- `driftModel` — the model with `|p| = [3/2, ∞)`, the manuscript's valuation

## Main Results

- `fzero_refutes_sentDet` — `sent:det` is refuted over `F°`
- `f1_sentDet` — `sent:det` is valid over `F¹`, as `sentDet_of_deterministic` applied to
  `f1_deterministic`
- `sentDet_discriminates` — the two together, as one statement
- `star_discriminates_where_plus_cannot` — the discrimination set against
  `deterministic_not_plusDefinable`

## The witnesses are the manuscript's own

`app:drift`'s closing paragraph fixes them: `|p| = [3/2, ∞)`, `τ(t) = t`, `σ(t) = 2t`, evaluated
at `σ` and time `0` with register `2` holding `1`. Then `τ ∈ ⟨σ⟩₀` (both are `0` at time `0`),
`σ(1) = 2 ∈ |p|` and `τ(1) = 1 ∉ |p|`, so `σ` itself refutes the `⊡↓²¬p` disjunct while `τ`
refutes the `⊡↓²p` disjunct. Both disjuncts of `sent:det` fail at that point.

The histories are built by the affine-witness idiom of `Independence/DriftHistories.lean`
(`driftTranslation`) rather than through `cor:occurrence`, so this module adds no Zorn
dependence of its own.

## References

* JPL paper `app:drift` (and its closing paragraph, which supplies these witnesses),
  `cor:no-characterization`, `app:deterministic-future` and the footnote following it
* `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean` —
  `deterministic_not_plusDefinable`, `fzero_plusValidOn_iff_f1`
* `FormalSystem/Semantics/StarLanguage/StarDeterminism.lean` — `sentDet_of_deterministic`, the half `F¹` uses

## Tags

independence · drift-frame · store-recall · sent:det · cor:no-characterization
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.StarLanguage

/-! ## The manuscript's two affine possible worlds of `F°` -/

/--
The affine history `t ↦ a · t` of `F°`, for a drift rate `a` in the band `[1, 2]`.

Its increment over `[s, t]` is `a · (t - s)`, which lies in `[t - s, 2 (t - s)]` exactly because
`1 ≤ a ≤ 2` — and in the reflected interval when the duration is negative, which is what
`FrameOver.converse` demands. This is `driftTranslation`'s idiom
(`Independence/DriftHistories.lean`) at a general rate; no appeal to `thm:extension` or
`cor:occurrence`, and hence no Zorn.
-/
noncomputable def driftLinear (a : ℝ) (h1 : 1 ≤ a) (h2 : a ≤ 2) : ConvexHistory F0 :=
  ConvexHistory.ofTotal F0 (fun t => a * t) <| by
    intro s t
    show fzeroRel (a * s) (t - s) (a * t)
    rw [fzeroRel_iff]
    rcases le_total 0 (t - s) with h | h
    · left
      constructor <;> nlinarith
    · right
      constructor <;> nlinarith

theorem driftLinear_isTotal (a : ℝ) (h1 : 1 ≤ a) (h2 : a ≤ 2) :
    (driftLinear a h1 h2).IsTotal :=
  ConvexHistory.ofTotal_isTotal _ _ _

@[simp] theorem driftLinear_states (a : ℝ) (h1 : 1 ≤ a) (h2 : a ≤ 2) (t : ↑realTemporalOrder)
    (ht : (driftLinear a h1 h2).domain t) :
    (driftLinear a h1 h2).states t ht = a * t := rfl

/-- The manuscript's valuation: `|p| = [3/2, ∞)`, at every sentence letter. -/
noncomputable def driftModel : TaskModel F0 where
  valuation := fun w _ => (3 / 2 : ℝ) ≤ w

/-! ## `sent:det` is refuted over `F°` -/

/--
**`F°` refutes `sent:det`.**

The manuscript's own witnesses, transcribed: with `|p| = [3/2, ∞)`, the possible worlds
`τ(t) = t` and `σ(t) = 2t` agree at time `0`, while `σ(1) = 2 ∈ |p|` and `τ(1) = 1 ∉ |p|`. So at
`(σ, 0)` with register `2` holding `1`, the world `σ` itself refutes the `⊡↓²¬p` disjunct and
`τ` refutes the `⊡↓²p` disjunct; both disjuncts fail, and `sentDet_unfold` carries the failure
to `sent:det`.

Contrast `fzero_determined` (`Independence/DeterminismUndefinable.lean`): every instance of
*Determined* — an L⁺ schema — **is** valid over `F°`. The store and recall operators are exactly
what makes the difference.
-/
theorem fzero_refutes_sentDet (p : Atom) :
    ¬ F0.StarValidOn (sentDet (StarFormula.atom p)) := by
  have h2 : (1 : ℝ) ≤ 2 := by norm_num
  have h2' : (2 : ℝ) ≤ 2 := le_refl _
  have h1 : (1 : ℝ) ≤ 1 := le_refl _
  have h1' : (1 : ℝ) ≤ 2 := by norm_num
  refine not_starValidOn_sentDet driftModel (driftLinear 2 h2 h2')
    (driftLinear_isTotal 2 h2 h2') (0 : ↑realTemporalOrder) (1 : ↑realTemporalOrder)
    (by norm_num) (driftLinear 2 h2 h2') (driftLinear 1 h1 h1')
    (driftLinear_isTotal 2 h2 h2') (driftLinear_isTotal 1 h1 h1')
    (SameStateAt.refl _ _) ?_ ?_ ?_
  · -- `τ(0) = 0 = σ(0)`, so `τ ∈ ⟨σ⟩₀`.
    intro _ _
    show (2 : ℝ) * (0 : ℝ) = (1 : ℝ) * (0 : ℝ)
    ring
  · -- `σ` satisfies `p` at time `1`: `σ(1) = 2 ≥ 3/2`.
    refine fun _ => ⟨driftLinear_isTotal 2 h2 h2' 1, ?_⟩
    show (3 / 2 : ℝ) ≤ (2 : ℝ) * (1 : ℝ)
    norm_num
  · -- `τ` fails `p` at time `1`: `τ(1) = 1 < 3/2`.
    rintro _ ⟨_, hval⟩
    have hval' : (3 / 2 : ℝ) ≤ (1 : ℝ) * (1 : ℝ) := hval
    norm_num at hval'

/-! ## `sent:det` is valid over `F¹` -/

/--
**`F¹` validates `sent:det`**, at every instance.

`F¹` is deterministic (`f1_deterministic`), so this is `sentDet_of_deterministic` instantiated —
one line, and deliberately so: the positive half of `app:deterministic-future` is proved once,
in `Semantics/StarLanguage/StarDeterminism.lean`, and never re-derived at a particular frame.
-/
theorem f1_sentDet (φ : StarFormula) : F1.StarValidOn (sentDet φ) :=
  sentDet_of_deterministic f1_deterministic φ

/-! ## The discrimination -/

/--
**The discrimination footnote, as one statement.** `sent:det` is valid over `F¹` and refuted over
`F°`, so the single `StarFormula` `sent:det` tells the two frames apart.

Stated as a conjunction rather than as two theorems so that neither half can be read alone: the
content of the footnote is the *contrast*, and `star_discriminates_where_plus_cannot` below is
what makes it a contrast with something.
-/
theorem sentDet_discriminates (p : Atom) :
    F1.StarValidOn (sentDet (StarFormula.atom p)) ∧
      ¬ F0.StarValidOn (sentDet (StarFormula.atom p)) :=
  ⟨f1_sentDet _, fzero_refutes_sentDet p⟩

/--
**Store and recall discriminate where nothing without them can.**

The two halves of the footnote in one statement: some `StarFormula` separates `F°` from `F¹`
(`sent:det`, by `sentDet_discriminates`), while no set of `PlusFormula`s defines the
deterministic frames at all (`deterministic_not_plusDefinable`, `cor:no-characterization`) —
because `F°` and `F¹` agree on every `PlusFormula` (`fzero_plusValidOn_iff_f1`).

Note what the second conjunct is and is not. It is *elimination by indistinguishability*, and it
is why the first conjunct cannot be obtained by any L⁺ sentence whatsoever. It is **not** an
appeal to uniform substitution, which is unsound here: `p → ⊡p` is frame-valid over `F°` while
`Fp → ⊡Fp` is refutable (`refute_determined`).
-/
theorem star_discriminates_where_plus_cannot :
    (∃ φ : StarFormula, F1.StarValidOn φ ∧ ¬ F0.StarValidOn φ) ∧
      ¬ ∃ Γ : Set FormalSystem.PlusLanguage.PlusFormula,
          ∀ F : TaskFrame, F.Deterministic ↔ ∀ φ ∈ Γ, F.PlusValidOn φ :=
  ⟨⟨sentDet (StarFormula.atom (Atom.mkBase "p")),
    sentDet_discriminates (Atom.mkBase "p")⟩,
   deterministic_not_plusDefinable⟩

end FormalSystem.Metalogic.Independence
