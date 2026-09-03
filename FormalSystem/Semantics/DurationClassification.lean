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

Pure order/group theory about the carrier `D` of a frame's temporal order. Nothing here mentions
formulas or truth; the point is to make the *sharp* Hölder picture citable from the `FrameClass`
and `Validity` docstrings, instead of the vaguer "paradigmatically ℝ" prose those files used to
carry.

## The binder convention

Every lemma below takes the repository's standard duration binders — `AddCommGroup D`,
`LinearOrder D`, `IsOrderedAddMonoid D` (see `TemporalOrder`) — plus Dedekind completeness in the
**explicit Prop-valued form** the semantics uses throughout:

  `h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x`

rather than a `ConditionallyCompleteLinearOrder D` instance. That choice is deliberate and is
explained at `ValidComplete` in `FormalSystem/Semantics/Validity.lean`: it keeps every
`[LinearOrder D]`-indexed lemma applicable with no instance-unification risk.

## The classification

`complete_duration_discrete_or_dense`: a Dedekind-complete duration group is **either**
order-and-group isomorphic to `ℤ` **or** densely ordered — and `complete_not_dense_iso_int`
shows the two branches are exclusive. This is what pins down the two frame classes the
repository actually cares about:

* the discrete branch is *exactly* `ℤ` (not merely "ℤ-like"), which is `FrameClass.Discrete` /
  `ValidDiscrete`;
* the dense branch is the real flow, which is `FrameClass.Dedekind` / `ValidDedekind`.

## What is deliberately *not* proved here

The packaged statement "a **nontrivial dense** Dedekind-complete ordered abelian group is
`≃+o ℝ`". It is true, and it is what would license calling `ValidDedekind` the real-flow
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

That file feeds Reynolds' separability lemma with the Archimedean step, and it consumes
`archimedean_of_lub` below directly — it used to carry a `private` copy (`arch_of_lub`) instead.
The copy is gone. The stated reason for keeping it, that resolving the duplication "would drag
`Metalogic` proofs into a rebase", did not survive measurement: the transitive `FormalSystem`
closure of this module is exactly three modules (`Semantics.DurationClassification`,
`Semantics.TaskFrame`, `Semantics.TemporalOrder`) and contains no `FormalSystem.Metalogic`
module, so the edge `Separability.lean → DurationClassification.lean` is acyclic and cheap.
`archimedean_of_lub` is now the single statement of this fact in the tree.

## Main results

- `archimedean_of_lub`: Dedekind completeness ⇒ `Archimedean` (the Dedekind branch).
- `complete_duration_discrete_or_dense`: `Nonempty (D ≃+o ℤ) ∨ DenselyOrdered D`.
- `complete_not_dense_iso_int`: not densely ordered ⇒ `Nonempty (D ≃+o ℤ)`.
- `isLeast_pos_succ_zero`: `Order.succ 0` is the least strictly positive element.
- `archimedean_of_succ`: `IsSuccArchimedean` ⇒ `Archimedean` (the discrete branch, the
  successor-side companion to `archimedean_of_lub`).
- `intIso`: the packaged additive transfer `D ≃+o ℤ` for a nontrivial successor-Archimedean
  duration group; consumed by `Semantics/IntTransfer.lean`'s `validDiscrete_iff_validInt`.
- `duration_dense_or_least_pos`: **the order-theoretic dichotomy with no lub hypothesis and no
  Archimedean hypothesis at all** — every nontrivial totally ordered abelian group is either
  densely ordered or has a least strictly positive element. This is *not* a corollary of
  `complete_duration_discrete_or_dense` above: that theorem assumes the least-upper-bound
  property (Dedekind completeness), which this one must not, since it is the pivot of the (Sp)
  validity argument on an arbitrary `TaskFrame.Duration` — no completeness is available there.
  It is also not `isLeast_pos_succ_zero`, which assumes `[SuccOrder D]` outright rather than
  deriving the least-positive witness from bare linearity.
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

## Both branches are present: this is the Dedekind one

The hypothesis here is the least-upper-bound property, so this lemma serves
`Semantics/Validity.lean`'s `ValidDense`/Dedekind-complete side. The **successor**-based analogue
— the one that serves `ValidDiscrete`, whose binder bundle offers `[SuccOrder D] [PredOrder D]
[IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]` and *not* a lub hypothesis — is
`archimedean_of_succ`, further down this same file. Measured: it needs only the **successor** half
of that bundle (`[SuccOrder D] [IsSuccArchimedean D] [Nontrivial D]`); `PredOrder D` and
`IsPredArchimedean D` are not used by it or by `intIso`.

What that companion lemma must produce is fixed by its consumer, and `intIso` below is where both
halves are assembled. The transfer
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
theorem archimedean_of_lub {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
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
theorem complete_duration_discrete_or_dense {D : Type} [AddCommGroup D] [LinearOrder D]
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
makes the dichotomy exclusive, which is why `ValidDiscrete` and `ValidDedekind` carve up
the complete case with nothing left over.
-/
theorem complete_not_dense_iso_int {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (h_not_dense : ¬ DenselyOrdered D) :
    Nonempty (D ≃+o ℤ) :=
  letI : Archimedean D := archimedean_of_lub h_lub
  (LinearOrderedAddCommGroup.discrete_iff_not_denselyOrdered D).mpr h_not_dense

section LeastPositive

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Immediate neighbours from a least positive element

Two shared order lemmas, carried at the **weakest** hypotheses that support them:
`[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` and nothing else — no `Nontrivial`, no
`Archimedean`, no `SuccOrder`. That matters, because the three call sites they replace each
supply the `IsLeast` witness from a *different* source (`succOrder_of_isLeast_pos` from the
duration dichotomy, the two `LexInt` lemmas from a hand-built witness at `ℤ ×ₗ ℤ`) and none of
them has a successor structure available at the point of use — that is what they are building.

**Direction A is deliberately not merged here.** `isLeast_pos_succ_zero` below and
`BLSchemaValidity.isGreatest_neg_pred_zero` go the *converse* way — from a successor structure
to the least positive element — are three to four lines each, and the latter's docstring records
its duplication as a deliberate territory split from an earlier task. Merging them would need an
explicit note superseding that docstring.
-/

/--
**A least strictly positive `p` makes `x + p` the immediate successor of `x`.**

`x < x + p` is positivity; minimality is `p ≤ z - x` from `hp.2` applied to `0 < z - x`,
rearranged by `le_sub_iff_add_le` and `add_comm`. No `linarith`: the binder bundle is a bare
ordered abelian group with no ring structure, on which it does not fire.
-/
theorem isLeast_succ_of_isLeast_pos {p : D} (hp : IsLeast {y : D | 0 < y} p) (x : D) :
    IsLeast {z : D | x < z} (x + p) := by
  refine ⟨lt_add_of_pos_right x hp.1, fun z hz => ?_⟩
  have hpos : (0 : D) < z - x := sub_pos.mpr hz
  have hle : p ≤ z - x := hp.2 hpos
  have := le_sub_iff_add_le.mp hle
  rwa [add_comm] at this

/--
**The mirror: a least strictly positive `p` makes `x - p` the immediate predecessor of `x`.**

Same argument read downwards, through `sub_lt_self` and a second `le_sub_iff_add_le`.
-/
theorem isGreatest_pred_of_isLeast_pos {p : D} (hp : IsLeast {y : D | 0 < y} p) (x : D) :
    IsGreatest {z : D | z < x} (x - p) := by
  refine ⟨sub_lt_self x hp.1, fun z hz => ?_⟩
  have hpos : (0 : D) < x - z := sub_pos.mpr hz
  have hle : p ≤ x - z := hp.2 hpos
  have h2 := le_sub_iff_add_le.mp hle
  rw [add_comm] at h2
  exact le_sub_iff_add_le.mpr h2

end LeastPositive

section SuccessorBranch

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
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

section Dichotomy

/--
**Lemma A (report §4.1): the order-theoretic dichotomy.**

Every nontrivial totally ordered abelian group is either densely ordered, or has a least
strictly positive element. No least-upper-bound hypothesis, no Archimedean hypothesis — this is
deliberately weaker in its assumptions than `complete_duration_discrete_or_dense` and
`isLeast_pos_succ_zero` above, and is what lets the (Sp) validity argument
(`Metalogic/SpWitness.lean`) apply to an arbitrary `TaskFrame.Duration` rather than only to a
Dedekind-complete or successor-structured one.

**Proof idea**: if `D` is not densely ordered, some `a < b` has nothing strictly between them;
set `d := b - a`. Then `0 < d` (from `a < b`), and `d` is a lower bound for the positive cone: if
`0 < c < d` then `a < a + c < b`, contradicting the no-witness-between property of `a`, `b`.
-/
theorem duration_dense_or_least_pos {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] :
    DenselyOrdered D ∨ ∃ d : D, IsLeast {x : D | 0 < x} d := by
  by_cases hd : ∀ a b : D, a < b → ∃ c, a < c ∧ c < b
  · exact Or.inl ⟨hd⟩
  · right
    push_neg at hd
    obtain ⟨a, b, hab, hc⟩ := hd
    refine ⟨b - a, sub_pos.mpr hab, ?_⟩
    intro c hc'
    by_contra hlt
    push_neg at hlt
    have h1 : a < a + c := lt_add_of_pos_right a hc'
    have h2 : c + a < b := lt_sub_iff_add_lt.mp hlt
    have h3 : a + c < b := by rw [add_comm]; exact h2
    exact absurd h3 (not_lt.mpr (hc (a + c) h1))

end Dichotomy

/-! ### The prose implications of `TaskFrame.lean`, machine-checked

`Semantics/TaskFrame.lean` asserts in prose (on `limit_of_succOrder`) that `NoMaxOrder D` "is not
an extra burden in practice, because `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
[Nontrivial D]` already implies it by instance search", and that the repo's standard discrete
binder bundle "therefore subsumes both hypotheses". Both claims are discharged below by
`inferInstance`, so a future change to the duration-carrier binder bundle that invalidates either
one fails here rather than silently in a downstream proof.

The two frame-level statements are a bonus rather than a restatement of the prose: they pin that
`NoMaxOrder`/`NoMinOrder` never have to appear as *hypotheses* at a `TaskFrame`, because the
frame's `Duration` field already carries the bundle that implies them. -/

/-- The `TemporalOrder` binder bundle implies `NoMaxOrder` by instance search alone. -/
example (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] :
    NoMaxOrder D := inferInstance

/-- `NoMaxOrder` is never a hypothesis at a frame: the `Duration` field supplies it. -/
example (F : TaskFrame) : NoMaxOrder F.Duration := inferInstance

/-- `NoMinOrder` is never a hypothesis at a frame either. -/
example (F : TaskFrame) : NoMinOrder F.Duration := inferInstance

/-- The standard discrete binder bundle subsumes `[SuccOrder]` + `[NoMaxOrder]`. -/
example (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] :
    NoMaxOrder D := inferInstance

end FormalSystem.Semantics
