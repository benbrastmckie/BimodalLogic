# BiLasso — the Decision Layer for Presented ℤ-Frames

A decision procedure for formulas evaluated on an `IntPresentation` — a finite directed graph on
`Fin card` with a `Bool`-valued valuation, mapped into the semantics through the ℤ-frame normal
form (`Decidability/IntPresentation.lean`).

**This directory does not decide the logic.** `cor:tm-decidability` records decidability of TM as
open. What is decided here is truth on a *presented* ℤ-frame: the frame is given as data, and the
procedure searches the finitely presented paths of that specific frame.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Basic.lean` | 300 | The `BiLasso` structure, its decoding `unroll`, the two periodicities, and `unroll_isStepPath` |

## The two design constraints

Both are refutations, not preferences, and each is backed by a machine-checked evidence file in
`specs/417_semantic_fmp_finite_worldstate_over_z/evidence/`.

**The evaluator must not recurse on the formula at a state.** A signature `check P w φ` that
recurses on `φ` with a *world state* `w` fixed is refuted outright — the implication case of such
a procedure is not compositional over the temporal operators. The shape used here instead fixes a
*path and a time* `(L, t)`, recurses on the formula against those, and puts the existential over
paths strictly *outside* the recursion.

**The lasso must be bi-infinite.** `TaskFrame.mem_HF_iff_adjacent`
(`Semantics/IntNormalForm.lean`) makes `H_F` over ℤ exactly the set of bi-infinite step-paths, and
`Formula.snce` quantifies leftward without bound. A right-only prefix-plus-cycle lasso leaves the
`snce` case with an unbounded backward search. Hence three segments — `back`, `mid`, `fwd` — with
both cycles required non-empty.

## Argument order

Every `untl` / `snce` term in this directory is **guard-first**: in `Formula.untl g e` the guard
`g` holds throughout the open interval and the event `e` is witnessed strictly later
(`Syntax/Formula.lean`; `specs/decisions/untl-snce-argument-order.md`). `Formula.prettyPrint`'s
prefix rendering `U(e, g)` is event-first and is a *display* convention only.

## Dependencies

- **Imports from**: `FormalSystem.Metalogic.Decidability.IntPresentation`
- **Imported by**: (nothing yet — the subtree is additive until its re-export lands)

## Related Documentation

- [Decidability README](../README.md)
- [FMP README](../FMP/README.md)

---

*Last verified: 2026-08-17*
