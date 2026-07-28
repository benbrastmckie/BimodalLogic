# Phase 4.1 (T1) Complete — Implementation Summary

**Date**: 2026-07-28 (Phase 4 dispatch 2)
**Module**: `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean`
**Status**: 4.1 COMPLETED; 4.2 BLOCKED on a measured design defect; 4.3 not started.

## What landed

All **36** rule cases of T1 (the generalized signed subformula property), sorry-free, plus the
combined theorem the plan specifies:

| Batch | Rules | Count |
|-------|-------|-------|
| Inherited (dispatch 1) | propositional 8, `boxTemporal`, `denseIndicatorClosure` | 10 |
| Late-arm repairs | `serialityRule`, `timeLinearity` | 2 |
| Persistent-universal | `boxPos`, `diamondNeg`, `allFuturePos`, `allPastPos`, `someFutureNeg`, `somePastNeg` | 6 |
| Fresh-witness | `boxNeg`, `diamondPos`, `allFutureNeg`, `allPastNeg`, `someFuturePos`, `somePastPos` | 6 |
| Until/Since | `untlPos`, `sncePos`, `untlNeg`, `snceNeg` | 4 |
| Frame-class | `priorUZ`, `priorSZ`, `z1Rule`, `priorUGap`, `priorSGap`, `sepRule`, `densityRule`, `orderTrichotomy` | 8 |

`applyRule_subformula_closed` assembles them by `cases rule`, which does not unfold `applyRule` —
so the combined statement, deliberately deferred by dispatch 1, costs nothing once the cases
exist. The module is 1,306 lines.

## The three pieces that made the propagation-heavy rules tractable

Dispatch 1 established the memory rule (one rule per declaration; `unfold applyRule` inlines a
900-line 36-arm match into every live goal, and a combined theorem is SIGTERMed by `earlyoom` at
19.2 GiB). That rule was kept. What it did not yet have was a way to close the propagation blocks
without a per-block choice of lemma:

1. **`mem_filterMap_sub`** — every propagation block emits a **subformula** of a branch formula.
   The blocks differ in shape (match-on-connective, time-guarded, pure relabel), but the emitted
   formula is always a component of the source or the source itself, and `subformulas` is
   reflexive. Routing through the `sub` field replaces a per-block lemma choice with one uniform
   obligation, discharged after `clear` has removed the unfolded `applyRule` term.
2. **`mem_of_branch_contains`** — `Branch.contains` is `List.any` with `BEq`, *not*
   `List.contains`, so `List.contains_iff_mem` does not apply to it. `orderTrichotomy` is the one
   case that must read a formula off the branch through that predicate.
3. **Closer-chain ordering.** The witness alternative must come first and must not mention `hg`:
   `rcases` auto-substitutes the witness equation, so `hg` no longer exists in that goal, and
   naming a missing hypothesis inside a `first` alternative is a hard elaboration error, not a
   backtrackable failure. This cost two iterations to find and is recorded in the section note.

Two late-arm quirks are also recorded in-module: in arms 35-36 the splitter's accumulated
hypothesis cascade makes `simp_all` decline to rewrite `hg`, so a targeted `simp only … at hg`
must follow it; and `timeLinearity` needs a *fixed* three-way `rcases`, because `repeat'` goes on
to destruct the `List.Mem` proofs themselves and shreds the branch into a cons pattern.

`orderTrichotomy` is confirmed analytic by construction rather than by assertion: `List.find?_some`
exposes the rule's own restriction-3 guard, which puts one `temp_linearity` disjunct on the branch
before the `trich` field supplies the other two.

## Why 4.2 is blocked, and what unblocks it

T1 is an implication and is complete. But T2 needs a **finite** `C` with `TableauClosed C`, and
**no finite non-trivial `C` exists** under the field list as currently stated. Three fields
re-trigger on their own output at strictly increasing formula size. All three were checked in
Lean against the landed definitions, not argued informally:

- `sep` applies to its own conclusion: `hC.sep _ (hC.sep _ h)` typechecks, and each step wraps
  the previous formula in `K⁺(· ∧ ·)`.
- `gapU`/`gapS` re-trigger through `sub`: from `U(⊤,g) ∈ C` the conclusion `U(¬g ∨ K⁺¬g, g)` has
  `K⁺¬g = ¬U(⊤,¬¬g)` as a subformula, so `U(⊤,¬¬g) ∈ C` and the field fires again on `¬¬g`.
- `trich` re-triggers on its own second disjunct: `F(x ∧ Fy)` is itself of the form `F(x ∧ y′)`,
  yielding `F(x ∧ FFy)`, `F(x ∧ FFFy)`, …

The cause is uniform: each of those fields is keyed on strictly **less** than the rule's real
trigger. `priorUGap` fires on `U(⊤,g) ∧ F¬g`, not on `U(⊤,g)`. `sepRule` fires on
`K⁺ψ ∧ ¬K⁺(ψ ∧ U(ψ,¬ψ))`, not on `K⁺ψ`. `orderTrichotomy` fires only when the branch carries the
negation of a disjunct at the common predecessor.

Re-keying `gapU`, `gapS` and `sep` to the conjunctions is mechanical and makes the rule cases
*shorter* (`hC.gapU _ hsf` in place of `hC.gapU _ (hC.and_left hsf)`), because the rule cases
already carry the whole conjunction in `hsf`. `trich` is the substantive one: its real guard is a
statement about the branch, not about `C`, so it may belong in the branch invariant `Fuel.lean`
carries rather than in `TableauClosed`.

## Verification

| Check | Result |
|-------|--------|
| `lake build` | green |
| `lake build BimodalTest` | green |
| Conformance corpus | verdict-neutral (no `#guard_msgs` movement) |
| Sorries in `SubformulaProperty.lean` | 0 |
| Vacuous definitions under `Verified/` | 0 |
| New axioms | 0 (the two `grep` hits repo-wide are prose inside docstrings, pre-existing) |

## Deviations from the plan

- **4.1 altered (carried from dispatch 1, unchanged)**: landed as one theorem per rule against an
  abstract `TableauClosed` predicate rather than as a single theorem against `closureWithNeg`.
  Both reasons are in the module docstring.
- **4.2/4.3 not started**: 4.2 is blocked on the defect above, which is recorded in the plan with
  its repair. 4.3 (`Fuel.lean`) depends on 4.2's bound and was not begun.
