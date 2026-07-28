/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Saturation
import Mathlib.Order.Defs.LinearOrder
import Mathlib.Order.Basic

/-!
# The Branch Order — a finite linear order out of a saturated branch

The semantic bridge needs the times a saturated open branch talks about to carry a genuine
**linear** order, because the countermodel is built by embedding those times monotonically into
a carrier `D` (`Bridge/Carrier.lean`, `Bridge/Embed.lean`) and interpolating between them.
What the engine hands over instead is `TimeOrdering` — a *list of strict constraints* — plus the
decidable gate `timeOrderTotal` saying no two branch times are left incomparable.

This file closes that gap: from one decidable Bool gate on `(b, ord)` it packages
`LinearOrder (BranchTime b)` where `BranchTime b := Fin b.knownTimes.length`.

## Why the gate is three conditions and not one

`timeOrderTotal` alone is **not** enough, and the reason is worth stating because it is easy to
assume otherwise.

`LinearOrder` needs reflexivity, transitivity, antisymmetry and totality. `timeOrderTotal`
delivers only the last. The other two order-theoretic obligations are about the *relation*
`strictBefore ord t₁ t₂ := (ord.futureOf t₁).contains t₂`, and neither is free:

* **Transitivity is not free** because `TimeOrdering.futureOf` is a *fuel-bounded* breadth-first
  search (`SignedFormula.lean`, default `fuel := 100`). At any fixed fuel there is a constraint
  list on which it under-reports: a chain longer than the fuel has `t₂ ∈ futureOf t₁` and
  `t₃ ∈ futureOf t₂` while `t₃ ∉ futureOf t₁`. So "`futureOf` is a transitive closure, hence
  transitive" is false as stated about the function the engine actually calls. Do not attempt to
  prove `strictBefore` transitive outright — it is not a theorem.
* **Antisymmetry is not free** because the constraint list can be cyclic. `addFuture` never
  checks for cycles, and `identifyTime` drops only the constraints that collapse to `(t,t)`, not
  longer cycles it may create. On a cyclic list `futureOf` reports both `t₁ ∈ futureOf t₂` and
  `t₂ ∈ futureOf t₁`, which is exactly the antisymmetry failure.

Both are, however, **decidable on the finitely many branch times**, and that is the route taken
here: `branchOrderValid` conjoins `timeOrderTotal` with an irreflexivity check and a cubic
transitivity check, all quantified over `b.knownTimes`. It is one `Bool`, so a certificate can
carry it exactly the way `timeOrderTotal` was designed to be carried, and the calculus-side work
that makes it come out `true` (the order-level branching rule) is unchanged in kind: one more
conjunct to flip, measured the same way.

## Indexing: why `Fin b.knownTimes.length` is the right index type

The plan left a choice open — index over the times occurring in `ord.constraints` **union**
`b.knownTimes`, or over `b.knownTimes` alone. `b.knownTimes` alone is correct, and it is correct
*because of* non-destructive expansion:

Pre-2.5 the engine's destructive expansion could consume every formula sitting at a time, and
that time then vanished from `knownTimes` even though `ord.constraints` still mentioned it. The
measured symptom (report 04 §Q2.2) was `constraints = [(0,2),(0,1)]` with `knownTimes = [2,1]`:
the order *induced on the known times* was empty, so `timeOrderTotal` read `false` for a branch
whose real order was perfectly total, and the union indexing was the natural repair. 2.5's
non-destructive expansion removed the cause — the root's formulas are kept, hence so is the root
time — so `knownTimes` is now closed under "mentioned by a live constraint" for the constraints
that matter, and the simple indexing is faithful. Indexing over the union would additionally
force the bridge to invent semantic content for times carrying no formulas, which the truth
lemma has nothing to say about.

## SETTLED: blocking semantics is identification/deletion, never edge-addition

Recorded here because this is the file whose order the unwinding of blocked loops has to respect
(plan constraint 4, and the consumer is Phase 7.1's loop-unwinding argument).

When the engine blocks a time `t_new` against an earlier `t_anc`, the branch is **not** repaired
by adding an ordering edge between them. It is repaired by *identifying* the two instants —
`Branch.identifyTime` relabels everything at `src` to `tgt`, and `TimeOrdering.identifyTime`
substitutes `src := tgt` throughout the constraint list, dropping constraints that collapse to
`(t,t)`. `src` then disappears from `knownTimes` entirely.

The reason edge-addition is excluded is structural, not stylistic: `TimeOrdering` is a list of
**strict** `<` pairs and has no way to express `t_new = t_anc`. An added edge would assert one of
`t_new < t_anc` / `t_anc < t_new`, both of which are strictly stronger than what blocking
established and both of which are unsound in the direction that matters — the branch recorded
that the two instants are indistinguishable, not that they are ordered. Dropping `(t,t)` is part
of the same decision: `(t,t)` asserts `t < t`, which `futureOf` propagates into a spurious cycle
making every time reachable from every other, and `branchOrderValid` would then read `true` for
a branch whose order is inconsistent (the irreflexivity conjunct is precisely the guard against
this).

The consequence relied on downstream: **identification shrinks `knownTimes`**, so the creation
index of the identified time strictly decreases, and (since 2.6's `blockCandidates` made blocking
bidirectional, a time being blockable only by one created strictly earlier) the unwinding
argument has a well-founded measure in both directions.

## Non-goal, explicitly: no linear extension of a partial branch order

Do **not** attempt to repair a `false` gate by taking the branch's partial order and extending it
to a linear one — Mathlib's `extend_partialOrder` / `LinearExtension`. It is **unsound**, with a
measured counterexample (report 04 §Q2.3, and the same argument is recorded at `timeOrderTotal`'s
own docstring in `Saturation.lean`):

In `¬(F(G p) ∧ F(¬p))` the two incomparable sibling times carry `T(G p)` and `F(p)`. The
extension that places the `G p` time first forces `p` true exactly where the branch asserts
`F(p)`; the other extension does not. The formula is satisfiable, so **exactly one** of the two
extensions is a model — and nothing on the branch records which. The calculus has to branch on
the order; the model construction cannot choose it afterwards. The identical argument kills
"propagate universals to incomparable times" as a repair.

This is why `branchOrderValid` is a **gate consumed as a hypothesis**, never a theorem proved
about arbitrary branches.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Metalogic.Decidability

/-! ## The strict relation and its decidable gate -/

/--
`t₂` lies strictly after `t₁` in the branch's abstract time order.

This is `TimeOrdering.futureOf` read as a relation. It is the *only* order primitive the bridge
consumes, deliberately: `futureOf` is already the transitive-closure-shaped reading the temporal
rules use (`allFuturePos` and friends), so the model built from it agrees with the rules that
produced the branch.
-/
def strictBefore (ord : TimeOrdering) (t₁ t₂ : TimeIndex) : Bool :=
  (ord.futureOf t₁).contains t₂

/-- No branch time lies strictly after itself: the acyclicity half of the gate. -/
def orderIrrefl (b : Branch) (ord : TimeOrdering) : Bool :=
  b.knownTimes.all fun t => !strictBefore ord t t

/--
`strictBefore` is transitive *on the branch times*.

Quantified over `b.knownTimes` only, which is what makes it decidable (cubically many checks in
the number of branch times) and what makes it honest: `strictBefore` is not transitive in
general, because `futureOf` is fuel-bounded. See the module docstring.
-/
def orderTransOn (b : Branch) (ord : TimeOrdering) : Bool :=
  b.knownTimes.all fun t₁ => b.knownTimes.all fun t₂ => b.knownTimes.all fun t₃ =>
    !(strictBefore ord t₁ t₂ && strictBefore ord t₂ t₃) || strictBefore ord t₁ t₃

/--
The single decidable gate the bridge consumes: the branch's times carry a strict linear order.

Conjunction of `timeOrderTotal` (delivered by the order-level branching rule) with the two
order-theoretic conditions that `timeOrderTotal` does not imply. Carried on an open-branch
certificate exactly as `timeOrderTotal` is.
-/
def branchOrderValid (b : Branch) (ord : TimeOrdering) : Bool :=
  timeOrderTotal b ord && orderIrrefl b ord && orderTransOn b ord

/-! ## Unpacking the gate -/

section Unpack

variable {b : Branch} {ord : TimeOrdering}

theorem timeOrderTotal_of_valid (h : branchOrderValid b ord = true) :
    timeOrderTotal b ord = true := by
  unfold branchOrderValid at h
  simp only [Bool.and_eq_true] at h
  exact h.1.1

theorem orderIrrefl_of_valid (h : branchOrderValid b ord = true) :
    orderIrrefl b ord = true := by
  unfold branchOrderValid at h
  simp only [Bool.and_eq_true] at h
  exact h.1.2

theorem orderTransOn_of_valid (h : branchOrderValid b ord = true) :
    orderTransOn b ord = true := by
  unfold branchOrderValid at h
  simp only [Bool.and_eq_true] at h
  exact h.2

/-- Totality, in relational form: any two branch times are equal or comparable. -/
theorem total_of_valid (h : branchOrderValid b ord = true)
    {t₁ t₂ : TimeIndex} (h₁ : t₁ ∈ b.knownTimes) (h₂ : t₂ ∈ b.knownTimes) :
    t₁ = t₂ ∨ strictBefore ord t₁ t₂ = true ∨ strictBefore ord t₂ t₁ = true := by
  have ht := timeOrderTotal_of_valid h
  unfold timeOrderTotal at ht
  rw [List.all_eq_true] at ht
  have h₁' := ht t₁ h₁
  rw [List.all_eq_true] at h₁'
  have h₂' := h₁' t₂ h₂
  simp only [Bool.or_eq_true, beq_iff_eq] at h₂'
  rcases h₂' with (heq | hf) | hf
  · exact Or.inl heq
  · exact Or.inr (Or.inl hf)
  · exact Or.inr (Or.inr hf)

/-- Irreflexivity, in relational form. -/
theorem irrefl_of_valid (h : branchOrderValid b ord = true)
    {t : TimeIndex} (ht : t ∈ b.knownTimes) : strictBefore ord t t = false := by
  have hi := orderIrrefl_of_valid h
  unfold orderIrrefl at hi
  rw [List.all_eq_true] at hi
  have := hi t ht
  simpa using this

/-- Transitivity on branch times, in relational form. -/
theorem trans_of_valid (h : branchOrderValid b ord = true)
    {t₁ t₂ t₃ : TimeIndex} (h₁ : t₁ ∈ b.knownTimes) (h₂ : t₂ ∈ b.knownTimes)
    (h₃ : t₃ ∈ b.knownTimes)
    (h₁₂ : strictBefore ord t₁ t₂ = true) (h₂₃ : strictBefore ord t₂ t₃ = true) :
    strictBefore ord t₁ t₃ = true := by
  have hT := orderTransOn_of_valid h
  unfold orderTransOn at hT
  rw [List.all_eq_true] at hT
  have e₁ := hT t₁ h₁
  rw [List.all_eq_true] at e₁
  have e₂ := e₁ t₂ h₂
  rw [List.all_eq_true] at e₂
  have e₃ := e₂ t₃ h₃
  simp only [Bool.or_eq_true, Bool.not_eq_true', Bool.and_eq_false_imp] at e₃
  rcases e₃ with hbad | hgood
  · rw [h₁₂] at hbad
    simp at hbad
    rw [h₂₃] at hbad
    exact absurd hbad (by simp)
  · exact hgood

end Unpack

/-! ## The index type -/

/--
The branch's times, indexed.

`Fin b.knownTimes.length` rather than a subtype of `TimeIndex`, so that the finite-linear-order
embedding lemmas (`Bridge/Embed.lean`) apply with no `Fintype` bridging, and so that the
interpolation in Phase 6 can walk the times in index order.
-/
abbrev BranchTime (b : Branch) : Type := Fin b.knownTimes.length

/-- The time an index names. -/
def timeAt (b : Branch) (i : BranchTime b) : TimeIndex := b.knownTimes[i]

theorem timeAt_mem (b : Branch) (i : BranchTime b) : timeAt b i ∈ b.knownTimes :=
  List.getElem_mem i.isLt

/-! ## The order relation -/

/--
The strict branch order on indices.

The `timeAt b i = timeAt b j ∧ i < j` disjunct is an index-level tiebreak. On a real branch it
never fires, because `Branch.knownTimes` is built by `eraseDups` and so lists each time once;
carrying the tiebreak anyway means trichotomy and irreflexivity hold **unconditionally** in the
index, with no `List.Nodup` side condition to thread through every downstream lemma. The
resulting order is the same one in every case that arises.

The packaged order is built from this *strict* relation rather than from a `≤` directly, via
`linearOrderOfSTO`: that hands back the `min`/`max`/`compare`/`lt` plumbing already discharged,
where a hand-rolled `LinearOrder` literal with an opaque `le` field cannot synthesise the `rfl`
defaults for those fields.
-/
def branchLT (b : Branch) (ord : TimeOrdering) (i j : BranchTime b) : Prop :=
  strictBefore ord (timeAt b i) (timeAt b j) = true ∨ (timeAt b i = timeAt b j ∧ i < j)

instance instDecidableBranchLT (b : Branch) (ord : TimeOrdering) :
    DecidableRel (branchLT b ord) := fun i j => by
  unfold branchLT; infer_instance

section Order

variable {b : Branch} {ord : TimeOrdering} (h : branchOrderValid b ord = true)

include h in
theorem branchLT_irrefl (i : BranchTime b) : ¬ branchLT b ord i i := by
  rintro (hs | ⟨_, hlt⟩)
  · rw [irrefl_of_valid h (timeAt_mem b i)] at hs
    exact absurd hs (by simp)
  · exact absurd hlt (lt_irrefl i)

include h in
theorem branchLT_trans {i j k : BranchTime b}
    (hij : branchLT b ord i j) (hjk : branchLT b ord j k) : branchLT b ord i k := by
  rcases hij with hs | ⟨he, hlt⟩
  · rcases hjk with hs' | ⟨he', _⟩
    · exact Or.inl (trans_of_valid h (timeAt_mem b i) (timeAt_mem b j) (timeAt_mem b k) hs hs')
    · exact Or.inl (he' ▸ hs)
  · rcases hjk with hs' | ⟨he', hlt'⟩
    · exact Or.inl (he ▸ hs')
    · exact Or.inr ⟨he.trans he', lt_trans hlt hlt'⟩

include h in
theorem branchLT_trichotomous (i j : BranchTime b) :
    branchLT b ord i j ∨ i = j ∨ branchLT b ord j i := by
  rcases total_of_valid h (timeAt_mem b i) (timeAt_mem b j) with heq | hs | hs
  · rcases lt_trichotomy i j with hlt | hij | hlt
    · exact Or.inl (Or.inr ⟨heq, hlt⟩)
    · exact Or.inr (Or.inl hij)
    · exact Or.inr (Or.inr (Or.inr ⟨heq.symm, hlt⟩))
  · exact Or.inl (Or.inl hs)
  · exact Or.inr (Or.inr (Or.inl hs))

include h in
/-- The strict branch relation is a strict total order — the input `linearOrderOfSTO` wants. -/
theorem branchLT_isStrictTotalOrder : IsStrictTotalOrder (BranchTime b) (branchLT b ord) where
  irrefl := branchLT_irrefl h
  trans := fun _ _ _ => branchLT_trans h
  trichotomous := fun i j hij hji => by
    rcases branchLT_trichotomous h i j with hlt | heq | hgt
    · exact absurd hlt hij
    · exact heq
    · exact absurd hgt hji

/--
**The Phase 5.1 deliverable.** A saturated branch whose time order passes the decidable gate
carries a genuine finite linear order on its times.

Consumed by `Bridge/Embed.lean` (`embed_finite` needs a `LinearOrder` on a `Finite` type) and by
Phase 6's interpolation, which walks the times in this order.
-/
@[instance_reducible]
def BranchOrder (b : Branch) (ord : TimeOrdering) (h : branchOrderValid b ord = true) :
    LinearOrder (BranchTime b) :=
  haveI := branchLT_isStrictTotalOrder h
  linearOrderOfSTO (branchLT b ord)

end Order

/-! ## Facts a consumer needs about the packaged order -/

section Facts

variable {b : Branch} {ord : TimeOrdering} (h : branchOrderValid b ord = true)

/-- `<` in the packaged order is `branchLT`, definitionally. -/
theorem BranchOrder_lt_iff (i j : BranchTime b) :
    (BranchOrder b ord h).lt i j ↔ branchLT b ord i j := Iff.rfl

/-- `≤` in the packaged order is "equal or strictly before", definitionally. -/
theorem BranchOrder_le_iff (i j : BranchTime b) :
    (BranchOrder b ord h).le i j ↔ (i = j ∨ branchLT b ord i j) := Iff.rfl

/--
The bridge direction the truth lemma consumes: a strict `futureOf` fact between two branch times
is a strict `<` fact in the packaged order.
-/
theorem lt_of_strictBefore {i j : BranchTime b}
    (hs : strictBefore ord (timeAt b i) (timeAt b j) = true) :
    (BranchOrder b ord h).lt i j := Or.inl hs

/-- …hence also an `≤` fact. -/
theorem le_of_strictBefore {i j : BranchTime b}
    (hs : strictBefore ord (timeAt b i) (timeAt b j) = true) :
    (BranchOrder b ord h).le i j := Or.inr (Or.inl hs)

/--
The converse direction, for indices carrying distinct times: `<` between indices naming
different times is a strict `futureOf` fact.
-/
theorem strictBefore_of_lt {i j : BranchTime b}
    (hlt : (BranchOrder b ord h).lt i j) (hne : timeAt b i ≠ timeAt b j) :
    strictBefore ord (timeAt b i) (timeAt b j) = true := by
  rcases hlt with hs | ⟨he, _⟩
  · exact hs
  · exact absurd he hne

/-- The order is finite: `BranchTime b` is a `Fin`, so `Finite` is immediate. -/
instance : Finite (BranchTime b) := inferInstanceAs (Finite (Fin _))

/-- …and a `Fintype`, which the embedding lemmas want. -/
instance : Fintype (BranchTime b) := inferInstanceAs (Fintype (Fin _))

end Facts

/-! ## Regression probes

These pin the gate's behaviour on the shapes the repair has to move. They are `#guard_msgs`
rows so a silent change in `futureOf`, `knownTimes` or `identifyTime` fails the build rather than
being absorbed.
-/

section Probes

/-- A three-element chain `0 < 1 < 2`, all three times live on the branch. Total, acyclic,
transitive — the gate passes. -/
private def chainBranch : Branch :=
  [ { sign := .pos, formula := .atom (.mkBase "p"), label := { world := 0, time := 0 } },
    { sign := .pos, formula := .atom (.mkBase "p"), label := { world := 0, time := 1 } },
    { sign := .pos, formula := .atom (.mkBase "p"), label := { world := 0, time := 2 } } ]

private def chainOrd : TimeOrdering := ⟨[(0, 1), (1, 2), (0, 2)]⟩

/-- info: true -/
#guard_msgs in
#eval branchOrderValid chainBranch chainOrd

/-- The same chain *without* the transitive edge. `futureOf` is a transitive closure, so the
gate still passes — this is the probe that would catch a regression to a direct-edge reading
of `futureOf` (which would break `G p → G G p`; see `futureOf`'s docstring). -/
private def chainOrdNoShortcut : TimeOrdering := ⟨[(0, 1), (1, 2)]⟩

/-- info: true -/
#guard_msgs in
#eval branchOrderValid chainBranch chainOrdNoShortcut

/-- Two incomparable siblings under a common root — the measured `¬(F(G p) ∧ F(¬p))` shape.
Totality fails, so the gate fails. This is the row the order-level branching rule has to flip. -/
private def forkOrd : TimeOrdering := ⟨[(0, 1), (0, 2)]⟩

/-- info: false -/
#guard_msgs in
#eval branchOrderValid chainBranch forkOrd

/-- Totality alone is not the gate: a **cycle** makes every time reachable from every other, so
`timeOrderTotal` reports `true` while the order is inconsistent. `branchOrderValid` rejects it on
the irreflexivity conjunct. This row is the reason the gate is three conditions. -/
private def cycleOrd : TimeOrdering := ⟨[(0, 1), (1, 2), (2, 0)]⟩

/-- info: true -/
#guard_msgs in
#eval timeOrderTotal chainBranch cycleOrd

/-- info: false -/
#guard_msgs in
#eval branchOrderValid chainBranch cycleOrd

-- Identification is the sanctioned repair (never edge-addition): identifying `2` into `1`
-- collapses the fork to a two-element chain, and the gate passes on the identified branch.
/-- info: true -/
#guard_msgs in
#eval branchOrderValid (chainBranch.identifyTime 2 1) (forkOrd.identifyTime 2 1)

-- The identified branch really did lose a time — `knownTimes` shrinks, which is the measure the
-- loop-unwinding argument inducts on.
/-- info: [0, 1] -/
#guard_msgs in
#eval (chainBranch.identifyTime 2 1).knownTimes

end Probes

end FormalSystem.Metalogic.Decidability.Verified.Bridge
