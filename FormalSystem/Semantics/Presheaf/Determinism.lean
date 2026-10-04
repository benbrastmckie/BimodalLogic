/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import FormalSystem.Semantics.FrameProperty
import FormalSystem.Semantics.Presheaf.Sheaf
import FormalSystem.Semantics.Presheaf.Ray

/-!
# The *Determinism* clause: separatedness of `Beh F`

The clause of `app:presheaf-dictionary` reading: `F` is deterministic exactly when every
restriction map of the behavior presheaf is injective. This module carries everything statable
below the cluster's `assert_not_exists` lock — the predicate `Separated`, the choice-free (⇒)
half, the world-to-section bridge, and the content of the converse's frame-side conclusion. The
biconditional itself is `Semantics/DeterministicBridge.lean`'s `deterministic_iff_separated`,
because its (⇐) half names `TaskFrame.SingletonClasses`, which lives above this lock.

## Main Definitions

- `Separated` — every restriction map of `Beh F` is injective
- `secOf` — a possible world cut down to the section over `[0, l]` based at a time `m`

## Main Results

- `states_eq_of_deterministic_sec` — the section-level singleton bridge
- `separated_of_deterministic` — the (⇒) half of the clause; choice-free
- `secOf_states` — the reading equation of `secOf`, which is `rfl`
- `states_eq_of_separated` — the content of the (⇐) half's conclusion, with
  `TaskFrame.SingletonClasses` unfolded

## Implementation Notes

**`states_eq_of_separated` states its conclusion unfolded on purpose.** Its content *is*
`TaskFrame.SingletonClasses`, but that name is declared in `Semantics/DeterministicBridge.lean`,
which transitively imports `FormalSystem.ProofSystem.Axioms` through
`PlusValidity → Validity → ValidityLayer → FrameClassValidity`. A module in this cluster
importing it could not close with the cluster's `assert_not_exists` lock. The name is attached in
that file instead, as the one-line `singletonClasses_of_separated`.

**`Semantics/FrameProperty.lean` is imported for `TaskFrame.Deterministic` alone.** It carries
only `Semantics/TaskFrame.lean` and two Mathlib order files, so it is strictly below the proof
system and the cluster's `assert_not_exists` lock still closes. What would break the lock is
`Semantics/DeterministicBridge.lean`, which is not imported here.

**Measured axiom profile** (`#print axioms`): `states_eq_of_deterministic_sec` is `[propext]`;
`separated_of_deterministic` and `states_eq_of_separated` are `[propext, Quot.sound]`. All three
are therefore **choice-free**, in the same measured sense `Presheaf/README.md` records for
*Germs* and *Sheaf*.
-/

namespace FormalSystem.Semantics.Presheaf

variable {F : TaskFrame}

/--
**Separatedness of `Beh F`**: every restriction map of the behavior presheaf is injective.

Two sections over `l` that agree after restricting to the window `[p, p + l']` are equal. Taking
`l' = 0` already makes this the statement that the *germ* maps are injective, which is the form
every consumer below actually uses.
-/
def Separated (F : TaskFrame) : Prop :=
  ∀ (l p l' : F.Duration) (hp : 0 ≤ p) (hl' : 0 ≤ l') (hple : p + l' ≤ l),
    Function.Injective (Beh.restrict (l := l) p l' hp hl' hple)

/--
**Section-level singleton bridge**: on a deterministic frame, two sections over the same duration
agreeing at one time of their common domain agree at every time of it.

The `Beh`-layer counterpart of `PlusLanguage.states_eq_of_deterministic`, by the same three-step
proof: read `respects_task` at the pair `(t, s)` in each section, rewrite along the hypothesis,
and apply determinism at the (possibly negative) duration `s - t`. It is **not** an instance of
that theorem, which is stated for *total* histories; the two meet through `secOf`.
-/
theorem states_eq_of_deterministic_sec (hD : F.Deterministic) {l : F.Duration}
    {σ τ : Beh F l} {t : F.Duration} (ht0 : 0 ≤ t) (htl : t ≤ l)
    (h : σ.val.states t (Beh.mem_dom σ ht0 htl) = τ.val.states t (Beh.mem_dom τ ht0 htl))
    (s : F.Duration) (hs0 : 0 ≤ s) (hsl : s ≤ l) :
    σ.val.states s (Beh.mem_dom σ hs0 hsl) = τ.val.states s (Beh.mem_dom τ hs0 hsl) := by
  have hσ := σ.val.respects_task t s (Beh.mem_dom σ ht0 htl) (Beh.mem_dom σ hs0 hsl)
  have hτ := τ.val.respects_task t s (Beh.mem_dom τ ht0 htl) (Beh.mem_dom τ hs0 hsl)
  rw [h] at hσ
  exact hD _ (s - t) hσ hτ

/--
**Determinism ⟹ separatedness**, the (⇒) half of the *Determinism* clause.

Choice-free. The proof consumes only the germ at the offset: restricting to `[p, p + l']` and
reading the restricted sections at time `0` gives agreement at `p` itself (two dependent
transports along `p + 0 = p`), and `states_eq_of_deterministic_sec` propagates that single
agreement across the whole of `[0, l]`.
-/
theorem separated_of_deterministic (hD : F.Deterministic) : Separated F := by
  intro l p l' hp hl' hple σ τ hστ
  have hpl : p ≤ l := le_trans (le_add_of_nonneg_right hl') hple
  have hd0 : (Beh.restrict p l' hp hl' hple σ).val.domain 0 := ⟨le_rfl, hl'⟩
  have hd0' : (Beh.restrict p l' hp hl' hple τ).val.domain 0 := ⟨le_rfl, hl'⟩
  have hp0 : (0 : F.Duration) ≤ p + 0 := by rw [add_zero]; exact hp
  have hpl0 : p + 0 ≤ l := by rw [add_zero]; exact hpl
  have h0 := states_eq_of_eq hστ 0 hd0 hd0'
  rw [Beh.restrict_states p l' hp hl' hple σ 0 hd0 (Beh.mem_dom σ hp0 hpl0),
      Beh.restrict_states p l' hp hl' hple τ 0 hd0' (Beh.mem_dom τ hp0 hpl0)] at h0
  have hσp : σ.val.states p (Beh.mem_dom σ hp hpl) = τ.val.states p (Beh.mem_dom τ hp hpl) := by
    rw [PartialHistory.states_eq_of_time_eq σ.val p (p + 0) (add_zero p).symm
          (Beh.mem_dom σ hp hpl) (Beh.mem_dom σ hp0 hpl0),
        PartialHistory.states_eq_of_time_eq τ.val p (p + 0) (add_zero p).symm
          (Beh.mem_dom τ hp hpl) (Beh.mem_dom τ hp0 hpl0)]
    exact h0
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z; exact propext ((σ.property z).trans (τ.property z).symm)
  · intro r hr _
    have hrr := (σ.property r).mp hr
    exact states_eq_of_deterministic_sec hD hp hpl hσp r hrr.1 hrr.2

/--
**The world-to-section bridge**: a possible world, cut down to the section over `[0, l]` based at
the time `m`.

Time-shift the world by `m`, take its forward ray at `0`, and cut that ray down to `[0, l]`. This
is the map through which the `Beh`-level clause meets `PlusLanguage.states_eq_of_deterministic`,
which is a statement about *total* histories.
-/
noncomputable def secOf (σ : WorldHistory F) (m l : F.Duration) (hl : 0 ≤ l) : Beh F l :=
  (futOf (σ.timeShift m) 0).toBeh l hl

/-- The reading equation of `secOf`: its state at `z` is the world's state at `z + m`. It is
`rfl`, which is what makes the bridge free. -/
theorem secOf_states (σ : WorldHistory F) (m l : F.Duration) (hl : 0 ≤ l) {z : F.Duration}
    (hz : (secOf σ m l hl).val.domain z) :
    (secOf σ m l hl).val.states z hz = σ.state (z + m) := rfl

/--
**Separatedness ⟹ singleton stability classes**, with `TaskFrame.SingletonClasses` unfolded: two
possible worlds agreeing on their world state at one time agree at *every* time.

Choice-free: it is the world-to-section bridge plus **one** germ-injectivity instance. The two
orderings of `x` and `y` are handled separately so the germ can be taken at whichever endpoint of
`[0, |y - x|]` the hypothesis sits at — base at `x` with the germ at the left endpoint when
`x ≤ y`, base at `y` with the germ at the right endpoint `x - y` otherwise.

The `SingletonClasses` *name* is behind this cluster's layering lock while its content is not;
`Semantics/DeterministicBridge.lean`'s `singletonClasses_of_separated` is the one-line
repackaging under that name. See this module's Implementation Notes.
-/
theorem states_eq_of_separated (hS : Separated F) (τ σ : WorldHistory F) (x : F.Duration)
    (h : τ.state x = σ.state x) (y : F.Duration) : τ.state y = σ.state y := by
  rcases le_total x y with hxy | hyx
  · -- base at `x`, germ at the left endpoint
    have hl : (0 : F.Duration) ≤ y - x := sub_nonneg.mpr hxy
    have hple : (0 : F.Duration) + 0 ≤ y - x := by rw [add_zero]; exact hl
    have hgerm : Beh.restrict 0 0 le_rfl le_rfl hple (secOf τ x (y - x) hl)
        = Beh.restrict 0 0 le_rfl le_rfl hple (secOf σ x (y - x) hl) := by
      refine Beh.ext (partialHistory_ext rfl ?_)
      intro r hr hr'
      obtain rfl : r = 0 := le_antisymm hr.2 hr.1
      change τ.state (0 + 0 + x) = σ.state (0 + 0 + x)
      simpa using h
    have heq := hS (y - x) 0 0 le_rfl le_rfl hple hgerm
    have hdom : (secOf τ x (y - x) hl).val.domain (y - x) := ⟨hl, le_rfl⟩
    have hdom' : (secOf σ x (y - x) hl).val.domain (y - x) := ⟨hl, le_rfl⟩
    have hst := states_eq_of_eq heq (y - x) hdom hdom'
    rw [secOf_states τ x (y - x) hl hdom, secOf_states σ x (y - x) hl hdom'] at hst
    simpa using hst
  · -- base at `y`, germ at the right endpoint `x - y`
    have hl : (0 : F.Duration) ≤ x - y := sub_nonneg.mpr hyx
    have hple : x - y + 0 ≤ x - y := by rw [add_zero]
    have hgerm : Beh.restrict (x - y) 0 hl le_rfl hple (secOf τ y (x - y) hl)
        = Beh.restrict (x - y) 0 hl le_rfl hple (secOf σ y (x - y) hl) := by
      refine Beh.ext (partialHistory_ext rfl ?_)
      intro r hr hr'
      obtain rfl : r = 0 := le_antisymm hr.2 hr.1
      change τ.state (x - y + 0 + y) = σ.state (x - y + 0 + y)
      simpa using h
    have heq := hS (x - y) (x - y) 0 hl le_rfl hple hgerm
    have hdom : (secOf τ y (x - y) hl).val.domain 0 := ⟨le_rfl, hl⟩
    have hdom' : (secOf σ y (x - y) hl).val.domain 0 := ⟨le_rfl, hl⟩
    have hst := states_eq_of_eq heq 0 hdom hdom'
    rw [secOf_states τ y (x - y) hl hdom, secOf_states σ y (x - y) hl hdom'] at hst
    simpa using hst

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
