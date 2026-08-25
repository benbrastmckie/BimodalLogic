# Phase 1 handoff — Successor-Archimedean block

**Next action**: Phase 2 — create `FormalSystem/Semantics/IntTransfer.lean` with `TaskFrame.map`
(prototype lines 63-107).

**State**: `FormalSystem/Semantics/DurationClassification.lean` extended with
`import Mathlib.Order.SuccPred.Archimedean` and a `section SuccessorBranch` carrying
`isLeast_pos_succ_zero`, `succ_eq_add_succ_zero`, `succ_iterate_zero`, `archimedean_of_succ`,
`noncomputable def intIso`. `lake build FormalSystem.Semantics.DurationClassification` green,
zero warnings attributable to the new block, `#print axioms` on `archimedean_of_succ`, `intIso`,
`isLeast_pos_succ_zero` each `[propext, Classical.choice, Quot.sound]`.

**Key decisions**: the five declarations sit inside `section SuccessorBranch ... end
SuccessorBranch` so the `variable` bundle (`[SuccOrder D] [Nontrivial D]`) does not leak to
anything else in the namespace. `PredOrder`/`IsPredArchimedean` excluded as planned.

**Deviations**: none functional. `git diff --stat` reports 87 insertions against a ~45-line
Scope Hypothesis; the excess is docstring prose (the plan required a new docstring for
`archimedean_of_succ`, and `intIso`/`isLeast_pos_succ_zero` got matching ones). Declaration
count matches the plan exactly: 4 theorems + 1 `noncomputable def`.
