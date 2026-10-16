/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.IntNormalFormEffective
import FormalSystem.Metalogic.Decidability.BiLasso.Orbit

/-!
# A Computable Orbit from an Enumerated Carrier

`FrameOver.extend_periodic` gets two things from `Classical.choice`: a successor at every state,
read out of *Seriality*'s existential with `Classical.choose`, and a revisit in each orbit, taken
from `exists_repeat_of_card_le`, whose statement mentions `Nat.card` and is therefore
choice-carrying before its proof is even read. This module supplies both choice-free, at a frame
whose carrier arrives as **data**: a list `enum` together with a proof that every state occurs in
it.

The selection is `List.find?` over `enum`, so it is a concrete first-match rule — deterministic,
computable, and `#eval`-able. *Seriality* is still what makes it total, but it is consumed only
to refute the `none` branch, an elimination of `∃` into `False`, which costs nothing. The shape
is modelled on `IntPresentation.succOf`, whose choice-freedom an existing guard test already
measures.

## Why a list rather than `[Finite W]`

`Finite` is a `Prop`: it asserts that a bijection with some `Fin n` exists without producing
one. Every route out of it — `Fintype.ofFinite`, `Finset.toList`, `Multiset.toList` — is
choice-carrying, so no enumeration can be extracted from it, and a period bound phrased with
`Nat.card` carries `Classical.choice` in the statement alone. Taking the enumeration as data is
what avoids both. `FrameOver.extend_periodic` keeps the `[Finite W]` hypothesis the paper's own
statement literally supports; the two coexist and neither is a corollary of the other.

## Why this module is not under `Semantics/`

No file under `FormalSystem/Semantics/` imports `FormalSystem.Metalogic`, and the choice-free
pigeonhole reused below, `exists_dup_lt`, lives under `Metalogic/Decidability/`. Duplicating
that pigeonhole into `Semantics/` was considered and rejected: it is a substantial induction with
a recorded subtlety about `BEq` at `Fin`, and a second copy would be a second thing to keep
scrubbed. The layering cost is paid here instead, and the consumers
(`EffectivePeriodicExtension.lean`, `FrameLassoCertificate.lean`) sit beside it.

## Not in the generated aggregator

This module is deliberately **not** added to
`FormalSystem/Metalogic/Decidability.lean`. The generated library root imports every module
directly, and the `Extend` / `Successor` / `Orbit` / `Agreement` precedent in this directory is
deliberate non-aggregation.

## Main Definitions

- `succOfEnum` / `predOfEnum` — the chosen one-step successor and predecessor, by first match in
  `enum`
- `iterSuccEnum` / `iterPredEnum` — their orbits

## Main Results

- `succOfEnum_step` / `predOfEnum_step` — the selections really do step
- `iterSuccEnum_step` / `iterPredEnum_step` — the orbits step at every index
- `exists_dup_of_enum` — pigeonhole at an enumerated carrier, replacing
  `exists_repeat_of_card_le`

## Tags

effective · choice-free · orbit · pigeonhole
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Semantics

section Selection

variable (F : FrameOver intOrder) [F.IsRegular] [DecidableRel F.step]

omit [DecidableRel F.step] in
/-- Forward one-step seriality, read off `FrameOver.serial` at duration `1`. Used only to refute
the `none` branch of the selections below. -/
theorem exists_step_fwd (w : F.WorldState) : ∃ u, F.step w u :=
  (F.serial w 1 zero_le_one).1

omit [DecidableRel F.step] in
/-- Backward one-step seriality, the mirror. -/
theorem exists_step_bwd (w : F.WorldState) : ∃ v, F.step v w :=
  (F.serial w 1 zero_le_one).2

/--
The **chosen successor** of `w`: the first state of `enum` that `w` steps to.

Replaces the `Classical.choose` selection in `FrameOver.extend_periodic`'s proof. The `none`
branch is unreachable and is discharged from one-step *Seriality* together with `henum`, used
*only* to derive `False`, so the definition is genuinely `#eval`-able.
-/
def succOfEnum (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState) :
    F.WorldState :=
  match hfind : enum.find? (fun u => decide (F.step w u)) with
  | some u => u
  | none => False.elim (by
      obtain ⟨u, hu⟩ := exists_step_fwd F w
      have hall := List.find?_eq_none.mp hfind u (henum u)
      simp [hu] at hall)

/-- **The chosen successor really is a successor.** -/
theorem succOfEnum_step (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState) :
    F.step w (succOfEnum F enum henum w) := by
  unfold succOfEnum
  split
  · next u heq => simpa using List.find?_some heq
  · next heq =>
      exfalso
      obtain ⟨u, hu⟩ := exists_step_fwd F w
      have hall := List.find?_eq_none.mp heq u (henum u)
      simp [hu] at hall

/--
The **chosen predecessor** of `w`: the first state of `enum` that steps to `w`. The mirror of
`succOfEnum`, with backward seriality refuting the `none` branch.
-/
def predOfEnum (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState) :
    F.WorldState :=
  match hfind : enum.find? (fun v => decide (F.step v w)) with
  | some v => v
  | none => False.elim (by
      obtain ⟨v, hv⟩ := exists_step_bwd F w
      have hall := List.find?_eq_none.mp hfind v (henum v)
      simp [hv] at hall)

/-- **The chosen predecessor really is a predecessor.** -/
theorem predOfEnum_step (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState) :
    F.step (predOfEnum F enum henum w) w := by
  unfold predOfEnum
  split
  · next v heq => simpa using List.find?_some heq
  · next heq =>
      exfalso
      obtain ⟨v, hv⟩ := exists_step_bwd F w
      have hall := List.find?_eq_none.mp heq v (henum v)
      simp [hv] at hall

/-- The forward orbit of `w` under the chosen successor: `iterSuccEnum w n` is `n` steps to the
*right* of `w`. -/
def iterSuccEnum (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState) :
    ℕ → F.WorldState
  | 0 => w
  | n + 1 => succOfEnum F enum henum (iterSuccEnum enum henum w n)

@[simp]
theorem iterSuccEnum_zero (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState) :
    iterSuccEnum F enum henum w 0 = w := rfl

theorem iterSuccEnum_succ (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState)
    (n : ℕ) :
    iterSuccEnum F enum henum w (n + 1) = succOfEnum F enum henum (iterSuccEnum F enum henum w n) :=
  rfl

/-- The backward orbit of `w` under the chosen predecessor: `iterPredEnum w n` is `n` steps to
the *left* of `w`. -/
def iterPredEnum (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState) :
    ℕ → F.WorldState
  | 0 => w
  | n + 1 => predOfEnum F enum henum (iterPredEnum enum henum w n)

@[simp]
theorem iterPredEnum_zero (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState) :
    iterPredEnum F enum henum w 0 = w := rfl

theorem iterPredEnum_succ (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState)
    (n : ℕ) :
    iterPredEnum F enum henum w (n + 1) = predOfEnum F enum henum (iterPredEnum F enum henum w n) :=
  rfl

/-- Consecutive entries of a forward orbit are adjacent, in the forward direction. -/
theorem iterSuccEnum_step (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState)
    (n : ℕ) :
    F.step (iterSuccEnum F enum henum w n) (iterSuccEnum F enum henum w (n + 1)) := by
  rw [iterSuccEnum_succ]; exact succOfEnum_step F enum henum _

/-- Consecutive entries of a backward orbit are adjacent, in the backward direction: the *later*
index is the earlier time, so the step runs from `n + 1` to `n`. -/
theorem iterPredEnum_step (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState)
    (n : ℕ) :
    F.step (iterPredEnum F enum henum w (n + 1)) (iterPredEnum F enum henum w n) := by
  rw [iterPredEnum_succ]; exact predOfEnum_step F enum henum _

end Selection

-- linter.unusedDecidableInType, suppressed deliberately: `[DecidableEq W]` is consumed by the
-- PROOF (`List.idxOf` needs a lawful `BEq`) and not by the TYPE. A deletion trial was run: with
-- the binder removed and `classical` supplying the instance in the proof, the declaration still
-- compiles and `#print axioms` reports `[propext, Classical.choice, Quot.sound]` instead of
-- `[propext, Quot.sound]` -- i.e. the linter's standing remedy destroys the one property this
-- declaration exists to have. The binder stays.
set_option linter.unusedDecidableInType false in
/--
**Pigeonhole at an enumerated carrier, choice-free.** Any window longer than the enumeration
repeats a value.

This replaces `FormalSystem.Semantics.exists_repeat_of_card_le` on the choice-carrying path.
That statement's bound is `Nat.card W`, and `Nat.card` is defined through `Cardinal.toNat`, so
the bound carries `Classical.choice` *in the statement* — before the proof is read, and with no
proof-side scrub able to remove it. The bound here is `enum.length`, a natural number of the
data.

The proof composes `List.idxOf` into `Fin enum.length` and applies
`FormalSystem.Metalogic.Decidability.exists_dup_lt`, the direct `Fin` pigeonhole; the round trip
back to `W` is `List.getElem_idxOf` at an index bound, not at a membership proof.

`[DecidableEq W]` is load-bearing in the **proof** — `List.idxOf` needs a lawful `BEq` — but
does not appear in the **type**. The standing remedy for that lint, dropping the binder and
reaching for `classical` in the proof, would reintroduce `Classical.choice` and defeat this
declaration's whole purpose, so the binder stays and the lint is scoped off above.
-/
theorem exists_dup_of_enum {W : Type} [DecidableEq W] (enum : List W) (henum : ∀ w, w ∈ enum)
    (n : ℕ) (hn : enum.length < n) (g : ℕ → W) :
    ∃ i j, i < j ∧ j < n ∧ g i = g j := by
  have hidx : ∀ k : ℕ, enum.idxOf (g k) < enum.length := fun k =>
    List.idxOf_lt_length_of_mem (henum (g k))
  obtain ⟨i, j, hij, hjn, heq⟩ :=
    exists_dup_lt enum.length n hn (fun k => ⟨enum.idxOf (g k), hidx k⟩)
  refine ⟨i, j, hij, hjn, ?_⟩
  have hval : enum.idxOf (g i) = enum.idxOf (g j) := congrArg Fin.val heq
  have hi := List.getElem_idxOf (x := g i) (xs := enum) (hidx i)
  have hj := List.getElem_idxOf (x := g j) (xs := enum) (hidx j)
  rw [← hi, ← hj]
  simp [hval]

end FormalSystem.Metalogic.Decidability
