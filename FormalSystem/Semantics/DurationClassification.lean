/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.GroupTheory.ArchimedeanDensely
import Mathlib.Order.SuccPred.Archimedean
import FormalSystem.Semantics.TaskFrame

/-!
# Hölder Classification of Dedekind-Complete Duration Groups

Pure order/group theory about the duration type `D` of a `TaskFrame`. Nothing here mentions
formulas or truth; the point is to make the *sharp* Hölder picture citable from the `FrameClass`
and `Validity` docstrings, instead of the vaguer "paradigmatically ℝ" prose those files used to
carry.

## The binder convention

Every lemma below takes the repository's standard duration binders — `AddCommGroup D`,
`LinearOrder D`, `IsOrderedAddMonoid D` (see `TaskFrame`) — plus Dedekind completeness in the
**explicit Prop-valued form** the semantics uses throughout:

  `h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x`

rather than a `ConditionallyCompleteLinearOrder D` instance. That choice is deliberate and is
explained at `ValidDedekind` in `FormalSystem/Semantics/Validity.lean`: it keeps every
`[LinearOrder D]`-indexed lemma applicable with no instance-unification risk.

## The classification

`complete_duration_discrete_or_dense`: a Dedekind-complete duration group is **either**
order-and-group isomorphic to `ℤ` **or** densely ordered — and `complete_not_dense_iso_int`
shows the two branches are exclusive. This is what pins down the two frame classes the
repository actually cares about:

* the discrete branch is *exactly* `ℤ` (not merely "ℤ-like"), which is `FrameClass.Discrete` /
  `ValidDiscrete`;
* the dense branch is the real flow, which is `FrameClass.Dedekind` / `ValidDedekindDense`.

## What is deliberately *not* proved here

The packaged statement "a **nontrivial dense** Dedekind-complete ordered abelian group is
`≃+o ℝ`". It is true, and it is what would license calling `ValidDedekindDense` the real-flow
predicate outright rather than up to the composition below, but it is a ~100-200 line
order-topology development with no Mathlib equivalent. The composition path, recorded here so
the omission is a scoped decision rather than a gap:

1. `archimedean_of_lub` (this file) — completeness gives `Archimedean D`;
2. `Archimedean.exists_orderAddMonoidHom_real_injective`
   (`Mathlib/Data/Real/Embedding.lean`) — an injective `D →+o ℝ`;
3. `AddSubgroup.dense_or_cyclic` (`Mathlib/Topology/Algebra/Order/Archimedean.lean`) — the
   image is dense in `ℝ` once `D` is not cyclic, which density rules out by step 4 of
   `complete_duration_discrete_or_dense`;
4. surjectivity of the embedding from Dedekind completeness of `D`.

## Relation to `Metalogic/SoundnessLemmas/Separability.lean`

That file carries a `private` copy of the same Archimedean argument (`arch_of_lub`), used there
to feed Reynolds' separability lemma. It is `private` and sits in the `Metalogic` layer, so it
is unreachable from `Semantics`; `archimedean_of_lub` below is the public `Semantics`-layer
statement of the same fact. The duplication is deliberate and is noted in both places rather
than resolved by moving the helper, which would drag `Metalogic` proofs into a rebase.

## Main results

- `archimedean_of_lub`: Dedekind completeness ⇒ `Archimedean`.
- `complete_duration_discrete_or_dense`: `Nonempty (D ≃+o ℤ) ∨ DenselyOrdered D`.
- `complete_not_dense_iso_int`: not densely ordered ⇒ `Nonempty (D ≃+o ℤ)`.
-/

namespace FormalSystem.Semantics

/--
**Dedekind completeness forces Archimedean.**

If some `y > 0` had all of its `ℕ`-multiples bounded above by `x`, the set `{n • y}` would have
a supremum `s`; but `s - y < s`, so some `n • y` exceeds `s - y`, whence `(n+1) • y > s`,
contradicting that `s` bounds the set.

**Mathlib has no group-level version of this.** The only completeness-to-Archimedean route it
provides is `ConditionallyCompleteLinearOrderedField.to_archimedean`, which requires a field —
useless for a duration *group*. So this is a genuine new lemma, not a re-export.

## This is the Dedekind branch only; the discrete branch has no analogue in this tree

The hypothesis here is the least-upper-bound property, so this lemma serves
`Semantics/Validity.lean`'s `ValidDense`/Dedekind-complete side. The **successor**-based analogue
— the one that would serve `ValidDiscrete`, whose binder bundle offers `[SuccOrder D] [PredOrder D]
[IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]` and *not* a lub hypothesis — **is
absent**: this file's entire theorem inventory is `archimedean_of_lub`,
`complete_duration_discrete_or_dense`, and `complete_not_dense_iso_int`, and none of them takes a
successor-structured `D`.

What that missing lemma must produce is fixed by its consumer. The transfer
`LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos : D ≃+o ℤ` needs exactly two
inputs the `ValidDiscrete` bundle does not already supply:

1. `Archimedean D` — which does **not** synthesize from `[IsSuccArchimedean D] [IsPredArchimedean D]`;
   those are order-successor conditions, not the additive Archimedean property; and
2. an `IsLeast {y : D | 0 < y}` witness — which is what the successor structure is there to produce.

**The recorded wrong turn**: `orderIsoIntOfLinearSuccPredArch` fits the `ValidDiscrete` bundle
verbatim, needs neither of the two inputs above, and is therefore the tempting reach. It yields
only `D ≃o ℤ` — an *order* isomorphism. Durations **add**: `TaskRel`'s *Compositionality* is stated
at `x + y`, so an order-only isomorphism cannot carry a frame across. The additive iso is the one
actually needed. `Semantics/IntNormalForm.lean`'s module docstring carries the full binder-fit
finding for both Mathlib results.
-/
theorem archimedean_of_lub {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) : Archimedean D := by
  refine ⟨fun x y hy => ?_⟩
  by_contra hcon
  simp only [not_exists, not_le] at hcon
  have hbdd : BddAbove (Set.range (fun n : ℕ => n • y)) := by
    refine ⟨x, ?_⟩
    rintro _ ⟨n, rfl⟩
    exact (hcon n).le
  obtain ⟨s, hs⟩ := h_lub (Set.range (fun n : ℕ => n • y))
    ⟨(0 : ℕ) • y, Set.mem_range_self 0⟩ hbdd
  have h1 : s - y < s := by simpa using sub_lt_self s hy
  obtain ⟨_, ⟨n, rfl⟩, hn, -⟩ := hs.exists_between h1
  have hle : (n + 1) • y ≤ s := hs.1 ⟨n + 1, rfl⟩
  have h2 : s < (n + 1) • y := by
    rw [succ_nsmul]
    exact sub_lt_iff_lt_add.mp hn
  exact absurd hle (not_le_of_gt h2)

/--
**Hölder dichotomy for Dedekind-complete duration groups**: such a group is either
order-and-group isomorphic to `ℤ`, or densely ordered.

`archimedean_of_lub` supplies the `Archimedean D` instance that
`LinearOrderedAddCommGroup.discrete_or_denselyOrdered` needs; the typeclass sets match exactly
(`AddCommGroup` + `LinearOrder` + `IsOrderedAddMonoid` + `Archimedean`), so no adapter is
required.

This is the statement that makes `FrameClass.Dedekind`'s density binder substantive rather than
decorative: without density the class would also admit `ℤ`, on which `Axiom.density` and
`Axiom.dense_indicator` are both false.
-/
theorem complete_duration_discrete_or_dense {D : Type*} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) :
    Nonempty (D ≃+o ℤ) ∨ DenselyOrdered D :=
  letI : Archimedean D := archimedean_of_lub h_lub
  LinearOrderedAddCommGroup.discrete_or_denselyOrdered D

/--
**The discrete branch is exactly `ℤ`.** A Dedekind-complete duration group that is *not*
densely ordered is order-and-group isomorphic to the integers.

Via `LinearOrderedAddCommGroup.discrete_iff_not_denselyOrdered`, again with the `Archimedean`
instance from `archimedean_of_lub`. Together with `complete_duration_discrete_or_dense` this
makes the dichotomy exclusive, which is why `ValidDiscrete` and `ValidDedekindDense` carve up
the complete case with nothing left over.
-/
theorem complete_not_dense_iso_int {D : Type*} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (h_not_dense : ¬ DenselyOrdered D) :
    Nonempty (D ≃+o ℤ) :=
  letI : Archimedean D := archimedean_of_lub h_lub
  (LinearOrderedAddCommGroup.discrete_iff_not_denselyOrdered D).mpr h_not_dense

section SuccessorBranch

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [SuccOrder D] [Nontrivial D]

/--
The successor of `0` is the least strictly positive element.

This is the `IsLeast {y : D | 0 < y}` witness that
`LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` demands, and it is the whole
reason the successor structure is in the `ValidDiscrete` binder bundle: `Order.lt_succ` gives
membership, `Order.succ_le_of_lt` gives lower-boundedness.
-/
theorem isLeast_pos_succ_zero :
    IsLeast {y : D | 0 < y} (Order.succ (0 : D)) :=
  ⟨Order.lt_succ (0 : D), fun _ hy => Order.succ_le_of_lt hy⟩

/--
In an ordered group with a successor structure, `succ` is translation by `succ 0`.

Note the proof avoids `linarith`: the binder bundle here is a bare `AddCommGroup` +
`LinearOrder` with no ring structure, on which `linarith` does not fire. The `≥` direction goes
through `le_sub_iff_add_le` and `add_comm` instead.
-/
theorem succ_eq_add_succ_zero (z : D) : Order.succ z = z + Order.succ (0 : D) := by
  have hu : (0 : D) < Order.succ (0 : D) := Order.lt_succ (0 : D)
  refine le_antisymm ?_ ?_
  · exact Order.succ_le_of_lt (lt_add_of_pos_right z hu)
  · have h1 : (0 : D) < Order.succ z - z := sub_pos.mpr (Order.lt_succ z)
    have h2 : Order.succ (0 : D) ≤ Order.succ z - z :=
      (isLeast_pos_succ_zero (D := D)).2 h1
    rw [le_sub_iff_add_le, add_comm] at h2
    exact h2

/-- Iterating `succ` from `0` is `ℕ`-scalar multiplication by `succ 0`. -/
theorem succ_iterate_zero (n : ℕ) :
    (Order.succ)^[n] (0 : D) = n • Order.succ (0 : D) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih, succ_eq_add_succ_zero, succ_nsmul]

/--
**Successor-Archimedean forces additively Archimedean.**

The successor-branch companion to `archimedean_of_lub` above. Where that lemma reads the
Archimedean property off the least-upper-bound property (the Dedekind branch, serving
`ValidDense`), this one reads it off `IsSuccArchimedean` (the discrete branch, serving
`ValidDiscrete`).

`IsSuccArchimedean D` says every `x ≥ 0` is reached from `0` by finitely many `Order.succ`
steps; `succ_iterate_zero` turns that iterate into `n • Order.succ 0`; and
`isLeast_pos_succ_zero` says `Order.succ 0 ≤ y` for every positive `y`, so `n • y ≥ n •
Order.succ 0 ≥ x`. Note `Archimedean D` does **not** synthesize from `[IsSuccArchimedean D]`
on its own — those are order-successor conditions, not the additive Archimedean property.
-/
theorem archimedean_of_succ [IsSuccArchimedean D] : Archimedean D := by
  refine ⟨fun x y hy => ?_⟩
  rcases le_or_gt x 0 with hx | hx
  · exact ⟨0, by simpa using hx⟩
  · obtain ⟨n, hn⟩ := exists_succ_iterate_of_le (le_of_lt hx)
    refine ⟨n, ?_⟩
    rw [← hn, succ_iterate_zero]
    exact nsmul_le_nsmul_right ((isLeast_pos_succ_zero (D := D)).2 hy) n

/--
**The full transfer.** A nontrivial successor-Archimedean ordered abelian group *is* `ℤ`, as an
ordered group.

This supplies both inputs `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos`
needs — the `Archimedean D` instance from `archimedean_of_succ`, and the `IsLeast {y | 0 < y}`
witness from `isLeast_pos_succ_zero` — and is the transfer that
`Semantics/IntTransfer.lean`'s `validDiscrete_iff_validInt` runs on.

Note this is a `≃+o`, not a `≃o`. Durations **add** (`TaskRel`'s Compositionality is stated at
`x + y`), so an order-only isomorphism such as the one `orderIsoIntOfLinearSuccPredArch`
produces cannot carry a frame across; see the `archimedean_of_lub` docstring above for the full
recorded wrong turn.
-/
noncomputable def intIso [IsSuccArchimedean D] : D ≃+o ℤ :=
  letI : Archimedean D := archimedean_of_succ
  LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos
    (isLeast_pos_succ_zero (D := D))

end SuccessorBranch

end FormalSystem.Semantics
