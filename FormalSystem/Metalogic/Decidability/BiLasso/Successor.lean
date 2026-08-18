/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.IntPresentation

/-!
# Choice-Free Computable Successor Selection on a Presentation

`IntPresentation` carries seriality as two `Prop`-valued existentials, `fwd : ∀ w, ∃ u, step w u`
and `bwd : ∀ w, ∃ v, step v w`. Extending a window into an orbit needs a *chosen* successor at
every state, and reading one out of those existentials with `Classical.choice` would produce a
selection that no `#eval` can run — which is the opposite of what a presentation exists for.

The selection here is made instead by `List.find?` over `List.finRange P.card`, so it is a
concrete first-match rule: deterministic, computable, and measured at `[propext, Quot.sound]`.
Seriality is still what makes it total, but it is consumed only to refute the `none` branch — an
elimination of `∃` into `False`, which costs nothing.

This is the part of the "visibly cheaper than the general construction" hope that genuinely cashes
out. It is **not** the part that removes `Classical.choice` from the extension theorem as a whole:
the pigeonhole step and the reused `BiLasso` periodicity lemmas each carry it independently, for
reasons that have nothing to do with successor selection. See `BiLasso/Extend.lean`'s
`IntPresentation.extend_periodic` docstring for the full accounting.

## Main Definitions

- `IntPresentation.succOf` / `IntPresentation.predOf` — the chosen one-step successor / predecessor
- `IntPresentation.iterSucc` / `IntPresentation.iterPred` — their iterates

## Main Results

- `IntPresentation.succOf_step` / `IntPresentation.predOf_step` — the selections really do step
- `IntPresentation.iterSucc_step` / `IntPresentation.iterPred_step` — the iterates step at every
  index, in the direction each is named for
-/

namespace FormalSystem.Metalogic.Decidability

namespace IntPresentation

/--
The **chosen successor** of `w`: the first state in `List.finRange P.card` that `w` steps to.

The `none` branch is unreachable and is discharged from `P.fwd`, which is used *only* to derive
`False` there — so no choice principle is involved and the definition is genuinely `#eval`-able.
-/
def succOf (P : IntPresentation) (w : Fin P.card) : Fin P.card :=
  match hfind : (List.finRange P.card).find? (fun u => P.step w u) with
  | some u => u
  | none => False.elim (by
      obtain ⟨u, hu⟩ := P.fwd w
      have hall := List.find?_eq_none.mp hfind u (List.mem_finRange u)
      simp [hu] at hall)

/-- **The chosen successor really is a successor.** -/
theorem succOf_step (P : IntPresentation) (w : Fin P.card) : P.step w (P.succOf w) = true := by
  unfold succOf
  split
  · next u heq => simpa using List.find?_some heq
  · next heq =>
      exfalso
      obtain ⟨u, hu⟩ := P.fwd w
      have hall := List.find?_eq_none.mp heq u (List.mem_finRange u)
      simp [hu] at hall

/--
The **chosen predecessor** of `w`: the first state in `List.finRange P.card` that steps to `w`.
The mirror of `succOf`, with `P.bwd` refuting the `none` branch.
-/
def predOf (P : IntPresentation) (w : Fin P.card) : Fin P.card :=
  match hfind : (List.finRange P.card).find? (fun v => P.step v w) with
  | some v => v
  | none => False.elim (by
      obtain ⟨v, hv⟩ := P.bwd w
      have hall := List.find?_eq_none.mp hfind v (List.mem_finRange v)
      simp [hv] at hall)

/-- **The chosen predecessor really is a predecessor.** -/
theorem predOf_step (P : IntPresentation) (w : Fin P.card) : P.step (P.predOf w) w = true := by
  unfold predOf
  split
  · next v heq => simpa using List.find?_some heq
  · next heq =>
      exfalso
      obtain ⟨v, hv⟩ := P.bwd w
      have hall := List.find?_eq_none.mp heq v (List.mem_finRange v)
      simp [hv] at hall

/-- The forward orbit of `w` under the chosen successor: `iterSucc w n` is `n` steps to the
*right* of `w`. -/
def iterSucc (P : IntPresentation) (w : Fin P.card) : ℕ → Fin P.card
  | 0 => w
  | n + 1 => P.succOf (P.iterSucc w n)

@[simp]
theorem iterSucc_zero (P : IntPresentation) (w : Fin P.card) : P.iterSucc w 0 = w := rfl

theorem iterSucc_succ (P : IntPresentation) (w : Fin P.card) (n : ℕ) :
    P.iterSucc w (n + 1) = P.succOf (P.iterSucc w n) := rfl

/-- The backward orbit of `w` under the chosen predecessor: `iterPred w n` is `n` steps to the
*left* of `w`. -/
def iterPred (P : IntPresentation) (w : Fin P.card) : ℕ → Fin P.card
  | 0 => w
  | n + 1 => P.predOf (P.iterPred w n)

@[simp]
theorem iterPred_zero (P : IntPresentation) (w : Fin P.card) : P.iterPred w 0 = w := rfl

theorem iterPred_succ (P : IntPresentation) (w : Fin P.card) (n : ℕ) :
    P.iterPred w (n + 1) = P.predOf (P.iterPred w n) := rfl

/-- Consecutive entries of a forward orbit are adjacent, in the forward direction. -/
theorem iterSucc_step (P : IntPresentation) (w : Fin P.card) (n : ℕ) :
    P.step (P.iterSucc w n) (P.iterSucc w (n + 1)) = true := by
  rw [iterSucc_succ]; exact P.succOf_step _

/-- Consecutive entries of a backward orbit are adjacent, in the backward direction: the *later*
index is the earlier time, so the step runs from `n + 1` to `n`. -/
theorem iterPred_step (P : IntPresentation) (w : Fin P.card) (n : ℕ) :
    P.step (P.iterPred w (n + 1)) (P.iterPred w n) = true := by
  rw [iterPred_succ]; exact P.predOf_step _

end IntPresentation

/-!
## Computability, exhibited

`succOf` and `predOf` are not merely choice-free as proofs; they run. The two-state cycle
`flipPresentation` (`Decidability/IntPresentation.lean`) steps `0 ⇄ 1`, so the first match in
`List.finRange 2` from state `0` is state `1`, and conversely.
-/

section Computation

/-- info: 1 -/
#guard_msgs in
#eval flipPresentation.succOf 0

/-- info: 0 -/
#guard_msgs in
#eval flipPresentation.succOf 1

/-- info: 1 -/
#guard_msgs in
#eval flipPresentation.predOf 0

/-- info: 0 -/
#guard_msgs in
#eval flipPresentation.iterSucc 0 2

end Computation

end FormalSystem.Metalogic.Decidability
