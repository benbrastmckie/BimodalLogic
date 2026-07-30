# Phase 29.8 — §6 on a Parameterized Structure Class

- **Task**: 408 | **Phase**: 29.8 | **Effort**: `--hard` | **Session**: `sess_1785362916_22a871_408`
- **Status**: [COMPLETED]. Full build green (1983 jobs), scoped build green (2234 jobs).

## What landed

`IsContempEquivDenseOn ε C` (`DenseModelSurgery/Defs.lean`) states Reynolds' three clauses against
an arbitrary class `C` of structures. Clause (i) is split `refl` / `symm` / `trans`, with
`IsContempEquivDenseOn.equiv` reassembling it so call sites read unchanged. Membership is carried by
a typeclass, `InStructureClass C M`, which is what keeps the propagation on binder lines: not one
call site in §6 mentions the class.

Two named classes instantiate it. `UnrestrictedClass sig` is Reynolds' own reading, and
`IsContempEquivDense` is now an `abbrev` for the bundle at it — a specialization, not a separate
structure. `CountableDense sig` is the reading `epsDense` supports.

Both closure conditions are in:

| Condition | Where | Instance at `UnrestrictedClass` | Instance at `CountableDense` |
|---|---|---|---|
| `C M → C (dual M)` | `IsDualClosed`, `Dual.lean` | trivial | `OrderDual.denselyOrdered` + `inferInstanceAs (Countable M.carrier)` |
| `C M → IsBadIntervalSurgery … → C (surgeredStructure …)` | `IsSurgeryClosed`, `TruthTransfer.lean` | trivial | **derived** from Phase 29.7's `countable_surgeredStructure` and `denselyOrdered_surgeredStructure` |

`isContempEquivDense_dualize` now **preserves** `C` instead of changing it, which is why all ~10
dual projection sites needed no edit at all.

## The no-weakening constraint is machine-checked

`section NoWeakening` (`ChronicleInstance.lean`) restates seven pre-parameterization signatures
verbatim — same explicit arguments, same order, same conclusion — and discharges each by direct
application: `no_gaps_dense_prior`, `no_gaps_dense_prior_left`, `reynolds_theorem5`,
`dense_singletons_of_sep`, `chronicleMonadic_no_gaps`, `chronicleMonadic_no_gaps_left`,
`chronicleMonadic_dense_singletons`. All three class obligations are left to instance search, so
`C := UnrestrictedClass sig` costs no extra argument. Had the parameterization narrowed any of
them, the corresponding line would not elaborate. `StrongCompleteness.lean` is byte-identical.

## Two things measured, not assumed

1. Report 11 §2.1 proposed restricting clauses (i) and (ii). The actual requirement is narrower:
   `simDense_refl`, `simDense_symm`, `simDense_convex` and `simDense_contemporary`
   (`EpsilonDense.lean:136,140,199,673`) carry no instance hypotheses; `simDense_trans` (`:988`) is
   the only one that does. So `refl`/`symm` are class-free. Clause (ii) is still gated, but for an
   unrelated reason: the dual transport reconstructs it at `N` out of clause (ii) *and transitivity*
   at `dual N`, so an ungated field would have demanded `C (dual N)` at every `N`.
2. Report 11's High-confidence claim that `reynolds_lemma9` is the **only** site projecting the
   gated clauses at `surgeredStructure` is confirmed by the compiler: after the rename the build
   reported exactly one unsatisfied `InStructureClass C (surgeredStructure …)` obligation, there.

## Verification

| Check | Result |
|---|---|
| Full `lake build` | green, 1983 jobs |
| Scoped build (`ChronicleInstance` + `RealModel.DoetsTheorem`) | green, 2234 jobs |
| Non-Boneyard sorry census | 1 at entry, 1 at exit (`Transfer.lean:1242`, pre-existing, unrelated) |
| Vacuous definitions introduced | 0 |
| New axioms | 0 |
| `StrongCompleteness.lean` | unchanged |

Cost: 9 files, 569 insertions / 192 deletions, six commits, each at a green build.

## Follow-ups, named rather than left implicit

1. `epsDense`'s own `IsContempEquivDenseOn (epsDense sig k) (CountableDense sig)` witness — a
   one-liner over `simDense_refl` / `simDense_symm` / `epsDense_isContempEquivDenseCD`, but it
   belongs in `RealModel/EpsilonDense.lean`, outside this phase's `Owns`.
   `IsContempEquivDenseCD.toOn` names it and states its two inputs.
2. Chronicle-level `CountableDense` membership, supplied at the call from
   `chronicleIsDensePriorSepStructure`'s `countable` / `denselyOrdered` fields
   (`ChronicleMonadicBridge.lean:1027-1030`). It cannot be a global instance because `h_mcs` and
   `h_box_dense` are non-class explicit arguments.

Both unblock Phase 29's anti-vacuity checkbox and Phase 30's `countermodel_dedekind_dense`.
