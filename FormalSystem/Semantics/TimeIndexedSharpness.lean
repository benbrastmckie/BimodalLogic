/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TimeIndexed
import Mathlib.NumberTheory.Real.Irrational

/-!
# Sharpness of the Dedekind hypothesis, and the duration-vs-time comparison

`Semantics/TimeIndexed.lean` proves that over a densely ordered, Dedekind-complete time order a
time-indexed frame with finitely many states satisfying *Limit* has only constant histories. This
module makes the remark "Dedekind completeness cannot be dropped" a compiled witness: a two-state
time-indexed frame over `ℚ` whose state flips exactly where the time line crosses `√2`.

`ℚ` is densely ordered and Archimedean, and it satisfies every hypothesis of the positive theorem
except completeness. The frame `qSwitchFrame` on `Bool` permits a change of state between `x` and
`y` exactly when one of the two times lies below `√2` and the other does not. It satisfies
*Converse*, *Seriality*, *Compositionality* and — this is the point — *Limit*, yet its switching
history `switchHist` takes both values, so the frame is neither static nor constant-historied.

## Why *Limit* survives

No rational number **is** the cut point, so every rational time `x` has a whole neighbourhood
lying on `x`'s own side of `√2` (`exists_radius`). Inside that neighbourhood no state change is
permitted, which is exactly *Limit*. What fails is uniformity **in time**: the radius returned at
`x` shrinks to `0` as `x` approaches `√2`, so there is no single radius that works along the whole
time line. Over a Dedekind-complete order that degeneration is impossible — the supremum argument
of `constantHistories_of_lub` walks up to the would-be cut point, finds it *in* the order, and
closes the gap there. Over `ℚ` the cut point is missing from the order and the argument has
nothing to land on. The order-level companion of this frame-level fact is
`FormalSystem.Metalogic.Independence.rat_not_complete`, cited here in prose only: `Semantics/`
never imports `Metalogic/`, and no import for it is added.

## Density cannot be dropped either

The second hypothesis of the positive theorem is density, and it is witnessed over `ℤ`, which is
Dedekind-complete but not densely ordered. `zSwitchFrame` flips its state across `0` instead of
across `√2`; over `ℤ` the constraint `|s - t| < 1` forces `s = t`, so *Limit* holds for the cheap
reason that the neighbourhoods are singletons, and the switching history is again non-constant.
The two witnesses together show each hypothesis of `constantHistories_of_lub` is load-bearing,
the discipline `Correspondence/RigiditySharpness.lean` already follows for the duration-indexed
theorem's own two hypotheses.

## Duration-indexed versus time-indexed: the boundaries differ

| Order | Dense | Arch. | Dedekind | Duration-indexed | Time-indexed |
|---|---|---|---|---|---|
| `ℤ` | no | yes | yes | not rigid | not rigid |
| `ℚ ×ₗ ℚ` | yes | no | no | not rigid | — |
| `ℚ` | yes | yes | no | **rigid** | **not rigid** |
| `ℝ` | yes | yes | yes | rigid | rigid |

"Duration-indexed" is `Rigidity.lean`'s theorem, "time-indexed" is `TimeIndexed.lean`'s, and the
witnesses go row by row. Over `ℤ`: `permissiveFrame_not_static` on the duration side,
`zSwitchFrame_not_constantHistories` on the time side. Over `ℚ ×ₗ ℚ`: `lexRatFrame_not_static`
on the duration side; the time-indexed cell is blank because both hypotheses already fail there,
so no witness is called for. Over `ℚ`: `FrameOver.static_of_finite` applies on the duration side,
while `qSwitchFrame_not_constantHistories` refutes rigidity on the time side.

The `ℚ` row is the entire point: it is the one order where the two boundaries disagree, and it is
what makes "Dedekind, not Archimedean" a genuine claim about time-indexed frames rather than a
restatement of the duration-indexed theorem. The two hypotheses are not independent —
`FormalSystem.Semantics.archimedean_of_lub` shows that over a duration *group* Dedekind
completeness implies the Archimedean property, so the time-indexed hypothesis is strictly the
stronger of the two — and `ℚ` separates them.

The reason for the asymmetry is in the two proofs. The duration-indexed argument chops: a task of
duration `x` is factored by *Compositionality* into finitely many sub-tasks each shorter than the
dwell radius, and the Archimedean property is what guarantees finitely many suffice. The
time-indexed argument has no duration to chop and never uses *Compositionality* at all; it must
instead close a gap in the time line, and Dedekind completeness is what guarantees the gap has a
point in it.

## Import discipline

`Mathlib.NumberTheory.Real.Irrational` is imported for `irrational_sqrt_two` and is confined to
this module, so the shared `TimeIndexed.lean` infrastructure stays at `TaskFrame` weight for the
frame-correspondence program that also consumes it.
-/

namespace FormalSystem.Semantics
namespace TimeIndexed

/-! ## Dedekind completeness cannot be dropped: the `ℚ` witness -/

/-- A rational time lies below the irrational cut `√2`. -/
def belowCut (x : ℚ) : Prop := (x : ℝ) < Real.sqrt 2

/-- No rational time **is** the cut point. This is the whole content of the witness: the cut is a
gap in `ℚ`, not a point of it. -/
theorem cut_not_rat (x : ℚ) : (x : ℝ) ≠ Real.sqrt 2 := fun h => irrational_sqrt_two ⟨x, h⟩

/-- Lying below the cut is downward closed. -/
theorem belowCut_mono {x y : ℚ} (h : x ≤ y) (hy : belowCut y) : belowCut x :=
  lt_of_le_of_lt (by exact_mod_cast h) hy

/-- `1 < √2`, so the time `1` lies below the cut. -/
theorem one_belowCut : belowCut 1 := by
  have : (1:ℝ) < Real.sqrt 2 := by
    nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]
  simpa [belowCut] using this

/-- `√2 < 2`, so the time `2` lies above the cut. -/
theorem two_not_belowCut : ¬ belowCut 2 := by
  have h : Real.sqrt 2 < (2:ℝ) := by
    nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]
  simp only [belowCut]; push Not; push_cast; linarith

/--
**Every rational time has a cut-free neighbourhood.** Since no rational equals `√2`, the distance
from `x` to the cut is a positive real, and a rational below it bounds a neighbourhood of `x`
lying entirely on `x`'s own side.

The radius is **not uniform in `x`**: it is bounded by `|x - √2|`, which tends to `0` as `x`
approaches the cut. That is precisely why *Limit* holds for `qSwitchFrame` while rigidity fails.
-/
theorem exists_radius (x : ℚ) :
    ∃ ε : ℚ, 0 < ε ∧ ∀ s : ℚ, |s - x| < ε → (belowCut s ↔ belowCut x) := by
  have hne : (x : ℝ) ≠ Real.sqrt 2 := cut_not_rat x
  obtain ⟨ε, hε0, hεd⟩ := exists_rat_btwn (abs_pos.mpr (sub_ne_zero.mpr hne))
  refine ⟨ε, by exact_mod_cast hε0, ?_⟩
  intro s hs
  have hs' : |(s:ℝ) - (x:ℝ)| < (ε:ℝ) := by
    have h : ((|s - x| : ℚ) : ℝ) < ((ε:ℚ):ℝ) := by exact_mod_cast hs
    rwa [Rat.cast_abs, Rat.cast_sub] at h
  have habs : |(s:ℝ) - (x:ℝ)| < |(x:ℝ) - Real.sqrt 2| := lt_trans hs' hεd
  rcases lt_or_gt_of_ne hne with hx | hx
  · have h1 : |(x:ℝ) - Real.sqrt 2| = Real.sqrt 2 - (x:ℝ) := by
      rw [abs_sub_comm, abs_of_pos (sub_pos.mpr hx)]
    rw [h1] at habs
    have h2 : (s:ℝ) - (x:ℝ) < Real.sqrt 2 - (x:ℝ) := lt_of_le_of_lt (le_abs_self _) habs
    exact iff_of_true (show (s:ℝ) < Real.sqrt 2 by linarith) (show (x:ℝ) < Real.sqrt 2 from hx)
  · have h1 : |(x:ℝ) - Real.sqrt 2| = (x:ℝ) - Real.sqrt 2 := abs_of_pos (sub_pos.mpr hx)
    rw [h1] at habs
    have h2 : (x:ℝ) - (s:ℝ) < (x:ℝ) - Real.sqrt 2 :=
      lt_of_le_of_lt ((le_abs_self _).trans (abs_sub_comm _ _).le) habs
    exact iff_of_false (show ¬ ((s:ℝ) < Real.sqrt 2) by push Not; linarith)
      (show ¬ ((x:ℝ) < Real.sqrt 2) by push Not; linarith)

/-- The presenting relation: the state changes exactly when the cut is crossed. Written in an
already-converse-symmetric shape rather than as a forward relation plus a reflection convention,
so that `Converse` is a direct computation. -/
def switchRel (w : Bool) (x y : ℚ) (u : Bool) : Prop :=
  w = u ∨ (w = false ∧ u = true ∧ belowCut x ∧ ¬ belowCut y)
        ∨ (w = true ∧ u = false ∧ belowCut y ∧ ¬ belowCut x)

/-- **The `ℚ` switching frame**: two states, flipping exactly across the irrational cut. -/
def qSwitchFrame : TimeIndexed (TemporalOrder.of ℚ) where
  W := Bool
  R := switchRel

/-- The `ℚ` witness satisfies the converse convention. -/
theorem qSwitchFrame_converse : qSwitchFrame.Converse := by
  intro w x y u
  change switchRel w x y u ↔ switchRel u y x w
  unfold switchRel
  constructor <;> rintro (h | ⟨h1,h2,h3,h4⟩ | ⟨h1,h2,h3,h4⟩)
  · exact Or.inl h.symm
  · exact Or.inr (Or.inr ⟨h2, h1, h3, h4⟩)
  · exact Or.inr (Or.inl ⟨h2, h1, h3, h4⟩)
  · exact Or.inl h.symm
  · exact Or.inr (Or.inr ⟨h2, h1, h3, h4⟩)
  · exact Or.inr (Or.inl ⟨h2, h1, h3, h4⟩)

/-- The `ℚ` witness is serial: staying put is always permitted. -/
theorem qSwitchFrame_serial : qSwitchFrame.Serial := fun w _ _ => ⟨⟨w, Or.inl rfl⟩, ⟨w, Or.inl rfl⟩⟩

/--
**The `ℚ` witness satisfies *Limit*.** Given a time `t`, `exists_radius` produces a radius inside
which the cut is not crossed, so no state change is permitted from `t` to any `s` that close —
which is exactly what *Limit* demands. The radius depends on `t`, and that is allowed.
-/
theorem qSwitchFrame_limit : qSwitchFrame.Limit := by
  intro w u t h
  obtain ⟨ε, hε, hrad⟩ := exists_radius t
  obtain ⟨s, hs, hR⟩ := h ε hε
  have hiff : belowCut s ↔ belowCut t := hrad s hs
  rcases hR with h0 | ⟨_,_,h3,h4⟩ | ⟨_,_,h3,h4⟩
  · exact h0.symm
  · exact absurd (hiff.mpr h3) h4
  · exact absurd (hiff.mp h3) h4

/-- The `ℚ` witness is compositional, so it cannot be dismissed as a degenerate relation that
fails the frame conditions the positive theorem does not use. -/
theorem qSwitchFrame_compositional : qSwitchFrame.Compositional := by
  intro w v x y z hxy hyz
  change switchRel w x z v ↔ ∃ u, switchRel w x y u ∧ switchRel u y z v
  unfold switchRel
  by_cases hA : belowCut x <;> by_cases hB : belowCut y <;> by_cases hC : belowCut z <;>
    cases w <;> cases v <;> simp_all [belowCut_mono hxy, belowCut_mono hyz]

/-- **The `ℚ` witness is not static**: the passage from `false` at time `1` to `true` at time `2`
crosses the cut and is permitted. -/
theorem qSwitchFrame_not_static : ¬ qSwitchFrame.Static := by
  intro h
  have := (h false 1 2 true).mp
    (show switchRel false 1 2 true from Or.inr (Or.inl ⟨rfl, rfl, one_belowCut, two_not_belowCut⟩))
  exact Bool.noConfusion this

open Classical in
/-- The switching history: `false` below the cut, `true` above it. -/
noncomputable def switchHist : ℚ → Bool := fun t => if belowCut t then false else true

/-- The switching assignment really is a history of the `ℚ` witness. -/
theorem switchHist_mem : switchHist ∈ qSwitchFrame.Hist := by
  intro x y
  change switchRel (switchHist x) x y (switchHist y)
  unfold switchRel switchHist
  by_cases hx : belowCut x <;> by_cases hy : belowCut y <;> simp [hx, hy]

/--
**Dedekind completeness cannot be dropped.** Over `ℚ` — densely ordered, Archimedean, and
finite-stated — the switching frame satisfies *Limit* (`qSwitchFrame_limit`) together with
*Converse*, *Seriality* and *Compositionality*, yet `switchHist` takes the value `false` at time
`1` and `true` at time `2`. So the conclusion of `constantHistories_of_lub` fails, and the
least-upper-bound hypothesis is load-bearing.

Contrast the duration-indexed theorem, which **does** apply over `ℚ`: `FrameOver.static_of_finite`
needs density and the Archimedean property, both of which `ℚ` has. This is the row of the
comparison table in this module's header at which the two rigidity boundaries genuinely disagree.

Paper: — (the manuscript states no rigidity theorem; stated at the hypothesis the proof uses)
-/
theorem qSwitchFrame_not_constantHistories : ¬ qSwitchFrame.ConstantHistories := by
  intro h
  have h2 := h switchHist switchHist_mem 1 2
  unfold switchHist at h2
  rw [if_pos one_belowCut, if_neg two_not_belowCut] at h2
  exact Bool.noConfusion h2


/-! ## Density cannot be dropped: the `ℤ` witness -/

/--
The presenting relation of the `ℤ` witness: the state changes exactly when the cut at `0` is
crossed. Same shape as `switchRel`, with the irrational cut replaced by the sign change — over a
discrete order a genuine gap is not needed, because the neighbourhoods are singletons anyway.
-/
def zSwitchRel (w : Bool) (x y : ℤ) (u : Bool) : Prop :=
  w = u ∨ (w = false ∧ u = true ∧ x < 0 ∧ 0 ≤ y)
        ∨ (w = true ∧ u = false ∧ y < 0 ∧ 0 ≤ x)

/-- **The `ℤ` switching frame**: two states, flipping across `0`. -/
def zSwitchFrame : TimeIndexed (TemporalOrder.of ℤ) where
  W := Bool
  R := zSwitchRel

/--
**The `ℤ` witness satisfies *Limit*.** Cheaply: the radius `1` works at every time, because over
`ℤ` the constraint `|s - t| < 1` forces `s = t`, and no state change is permitted from a time to
itself. Local constancy is vacuous over a discrete order, which is exactly why density is a
hypothesis of `constantHistories_of_lub`.
-/
theorem zSwitchFrame_limit : zSwitchFrame.Limit := by
  intro w u t h
  obtain ⟨s, hs, hR⟩ := h 1 one_pos
  have hst : s = t := by
    -- `omega` is run on genuine `ℤ` variables: on the carrier `↑(TemporalOrder.of ℤ)` the
    -- order and group instances are the projections of the bundle, which `omega` does not
    -- match syntactically even though they are definitionally `ℤ`'s own.
    have key : ∀ a b : ℤ, -1 < a - b → a - b < 1 → a = b := by
      intro a b h1 h2; omega
    obtain ⟨hlo, hhi⟩ := abs_lt.mp hs
    exact key s t hlo hhi
  subst hst
  rcases hR with h0 | ⟨_, _, h3, h4⟩ | ⟨_, _, h3, h4⟩
  · exact h0.symm
  · exact absurd h4 (not_le.mpr h3)
  · exact absurd h4 (not_le.mpr h3)

/-- The `ℤ` switching history: `false` strictly before `0`, `true` from `0` onward. -/
def zSwitchHist : ℤ → Bool := fun t => if t < 0 then false else true

/-- The `ℤ` switching assignment really is a history of the `ℤ` witness. -/
theorem zSwitchHist_mem : zSwitchHist ∈ zSwitchFrame.Hist := by
  intro x y
  change zSwitchRel (zSwitchHist x) x y (zSwitchHist y)
  unfold zSwitchRel zSwitchHist
  by_cases hx : x < 0 <;> by_cases hy : y < 0
  · exact Or.inl (by rw [if_pos hx, if_pos hy])
  · exact Or.inr (Or.inl ⟨if_pos hx, if_neg hy, hx, not_lt.mp hy⟩)
  · exact Or.inr (Or.inr ⟨if_neg hx, if_pos hy, hy, not_lt.mp hx⟩)
  · exact Or.inl (by rw [if_neg hx, if_neg hy])

/--
**Density cannot be dropped.** `ℤ` is Dedekind-complete — every nonempty set bounded above has a
greatest element, let alone a least upper bound — and the `ℤ` switching frame has two states and
satisfies *Limit* (`zSwitchFrame_limit`), yet `zSwitchHist` takes the value `false` at `-1` and
`true` at `0`. So the conclusion of `constantHistories_of_lub` fails and the `[DenselyOrdered ↑D]`
hypothesis is load-bearing.

Together with `qSwitchFrame_not_constantHistories` this closes the sharpness square: each of the
positive theorem's two hypotheses on the time order is refuted by dropping it alone. The
duration-indexed analogue is `permissiveFrame_not_static`, which drops density from
`FrameOver.static_of_finite` over this same carrier.
-/
theorem zSwitchFrame_not_constantHistories : ¬ zSwitchFrame.ConstantHistories := by
  intro h
  have h2 := h zSwitchHist zSwitchHist_mem (-1) 0
  unfold zSwitchHist at h2
  rw [if_pos (by norm_num : (-1 : ℤ) < 0), if_neg (by norm_num : ¬ (0 : ℤ) < 0)] at h2
  exact Bool.noConfusion h2

end TimeIndexed
end FormalSystem.Semantics
