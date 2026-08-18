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
| `Basic.lean` | 316 | The `BiLasso` structure, its decoding `unroll`, the two periodicities, and `unroll_isStepPath` |
| `Unfold.lean` | 166 | The exact ℤ one-step unfolding of `TruthAt` for `untl` and `snce`, plus the two ℤ-distance induction principles |
| `Periodic.lean` | 130 | The three-segment periodic decoding at an arbitrary `[Inhabited α]`, shared in scheme with `Basic.lean`'s |
| `Annotation.lean` | 360 | The `Annot` datatype, its label decoding and alignment with the state decoding, and the three predicates `LocalCoherent`, `Fulfilling`, `BoxOracleSound` |
| `Examples.lean` | 442 | The non-vacuity witnesses: one annotated lasso satisfying both predicates, one satisfying `LocalCoherent` but not `Fulfilling` |
| `TruthLemma.lean` | 230 | `truth_along_annot` — truth equals label membership on the closure |
| `Decide.lean` | 905 | The corrected scan bounds and the window collapses that make `LocalCoherent` and `Fulfilling` decidable |
| `Enumerate.lean` | 325 | `boundedBiLassos` and `boundedAnnots`, with completeness and soundness |
| `SmallModel.lean` | 236 | The type sequence of a genuine history, shown locally coherent and fulfilling — the groundwork the extraction consumes |

The extraction itself (`exists_annot_of_truth`), the box oracle, and `check` are **not yet
present**: see `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase10-origin-anchoring-obstruction.lean`
for the machine-checked obstruction that halted the extraction, and the plan's Phase 10 blocker
record for the two available repairs.

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
