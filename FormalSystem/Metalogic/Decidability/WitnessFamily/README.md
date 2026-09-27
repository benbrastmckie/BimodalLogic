# WitnessFamily — Presentation-Free Certificates for ℤ-Time Refutation

A **witness family** is the finite object a model checker returns when it refutes a ℤ-time
consequence `Γ ⊨ σ`: a box guess `bx : Formula → Bool` together with a non-empty list of
*labelled bi-lassos*, each a triple of label segments `back`, `mid`, `fwd` decoded into a
bi-infinite `ℤ → Finset Formula` by `Periodic.unrollOf`.

This directory proves that such an object, when it satisfies four checkable conditions, **is** a
machine-checkable countermodel: it presents a `ShiftSet intOrder` whose truth agrees with the
labels on the target closure, so `Γ ⊨ σ` fails over ℤ-time and, a fortiori, over the
unconstrained class.

## This is the soundness half only

The **completeness** direction — that every ℤ-time countermodel compresses to such a family — is
not here, and neither is the `Decidable (ValidZTime φ)` assembly that would follow from it. Those
belong to the compression work. Nothing in this directory presupposes either, and every theorem
below is unconditional.

### Cross-repository reduction condition: satisfiable in principle, not nearly done

The compression work's completeness direction ultimately reduces, on the consuming (model-checker)
side, to a condition over the searched witness-family space. That condition is now satisfiable
**in principle**: both of its former prerequisites are landed there — a certificate export on the
wire contract this tree documents (see `BimodalTools/README.md`, "Certificate re-verification
protocol"), and an independent pure-Python re-checker that decides the four conditions above
(`LocalCoherentLab`, `FulfillingLab`, `BoxFaithful`, `Target`) over the proved windows on every
reported countermodel, cross-checked against `lake exe check_certificate` where present.

"Satisfiable" is **not** "nearly done". The searched witness-family space is **not monotone** in
the `back`/`mid`/`fwd` bounds: the consuming registry folds those bounds by exact modulus, so a
search at bound `n` represents exactly the periods dividing `n`. The measured instance: one
formula is SAT at `(3, 1, 3)` and `(6, 1, 6)` and genuinely UNSAT (not a timeout) at `(4, 1, 4)`
and `(5, 1, 5)`, exactly as `6 ∤ 4` and `6 ∤ 5` predict. Consequently the condition **as originally
worded is false** — which is why it was rewritten into ordered sub-conditions on the consuming
side rather than simply marked satisfiable. The sole blocking sub-condition is fixing the length
space: either sweeping the bounds over the grid up to the compression bound, or restricting the
claim to bounds the folding actually covers. Without it, the condition is **unprovable, not
merely unproved**.

The corollary for the compression bound's *shape*: a bound of the form "segment lengths at least
`f` of the closure size" is insufficient on its own, because representability is a divisibility
(period) question, not a magnitude question — a family whose period does not divide the
configured length is unrepresentable however large that length is.

## Why a labelled family, and not something smaller

Two smaller candidates are ruled out by machine-checked results already in the tree.

- A finite `IntPresentation` is ruled out by `Probe476.fmp_false`
  (`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`).
- A bare window is ruled out by the three limits in `../BiLasso/Agreement.lean`.

What is left is the labelled family: the labels are the object, and the presented model's
valuation is read off their atom part. `Examples.lean`'s `posFamily` exhibits the gap concretely —
it certifies `□(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)`, whose three-region label pattern (`Fp` left of the
origin, `p` at it, `Pp` right of it) no single periodic window expresses.

## Presentation-free, unlike `BiLasso/`

`../BiLasso/`'s `Annot P φ` labels the positions of a path *through* an `IntPresentation`, and
carries three length agreements plus an alignment lemma (`Annot.readIndex`,
`Annot.label_unroll_aligned`) to keep labels and states in step. A `LabelledLasso` has no states,
so that entire alignment layer is absent rather than reproved — and `LocalCoherentLab` drops
`LocalCoherent`'s atom clause for the same reason. The only dependency on `../BiLasso/` is
`Periodic.lean`, which is deliberately directory-independent.

## Modules

| Module | Lines | Role |
|--------|-------|------|
| `Closure.lean` | 131 | `closureOf`, the set-level subformula closure of a `Context`, with `mem_closureOf`, `self_mem_closureOf` and the seven projections the agreement induction consumes |
| `Basic.lean` | 201 | `LabelledLasso` and `WitnessFamily`, the decoded label functions `lab` and `L`, the two periodicities `lab_sub_back_length` / `lab_add_fwd_length`, and `lab_subset` |
| `Predicates.lean` | 127 | `LocalCoherentLab`, `FulfillingLab`, `BoxFaithful`, `Target`, with the clause-by-clause correspondence to `../BiLasso/Annotation.lean` |
| `Std.lean` | 120 | `WitnessFamily.std`, the presented `ShiftSet intOrder`, with `std_isZTime`, `std_sat_ztime`, `std_sat_base` and `sh_surj` |
| `Agreement.lean` | 247 | **T1** `shiftTruth_iff_mem` and `truth_iff_mem`; **T1'** `not_consequence_ztime`, `not_consequence_base`, `joint_countermodel` |
| `Decide.lean` | 928 | **T2** the window collapses and the four named instances `decidableLocalCoherentLab`, `decidableFulfillingLab`, `decidableBoxFaithful`, `decidableTarget` |
| `Examples.lean` | 283 | **T3** the non-vacuity witness `posFamily`, the separation witness `sepFamily`, and `no_witnessFamily_of_validZTime` / `no_witnessFamily_of_MF` |

`WitnessFamily.lean`, beside this directory, is the subdirectory re-export and carries all seven.

## Field names are an export contract

`back`, `mid`, `fwd`, `bx` and `lassos` are mirrored field for field by the model checker's JSON
export. Renaming any of them is a breaking change on the consuming side, not a local refactor.

## Deliberate duplication, with a named retirement trigger

`Basic.lean`'s two periodicities and `Decide.lean`'s window collapses duplicate the corresponding
arithmetic in `../BiLasso/Annotation.lean` and `../BiLasso/Decide.lean`, at the other carrier of
the same periodic decoding. This is recorded rather than refactored: `../BiLasso/Basic.lean` is
held stable for the effective-periodic-extension work, `../BiLasso/Decide.lean` is consumed by
the live `check`, and a shared abstraction would put a large refactor under both.

**The trigger that retires it**: once a shared periodic-label presentation lands, both files'
window collapses should be redefined as its two instances and the duplicated arithmetic deleted.
That refactor belongs to whichever task owns the shared abstraction.

## Computable, not claimed choice-free

All four decision instances compute — there is no `open Classical` and no `Classical.dec` in
`Decide.lean`, and `Examples.lean`'s `#guard`s run each named instance rather than letting
synthesis pick one. That is strictly weaker than choice-freedom, and choice-freedom is **not**
claimed: `wlem_of_saturation`
(`Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean`) derives weak excluded middle from
`Saturation R` at a finite carrier over ℤ, so no finite-carrier route is choice-free. See
`../BiLasso/README.md` for the same distinction stated for `instDecidableSatAtState`.

## What replaced the exhaustive negative `#guard`

The original brief asked for a `#guard` that no witness family with all segment lengths `≤ 2`
exists for the negation of the bimodal axiom MF. That is infeasible by about twelve orders of
magnitude — the closure has 10 members, so one lasso admits up to `1024⁶ ≈ 1.2 · 10¹⁸` label
assignments. `no_witnessFamily_of_MF` proves the stronger statement, at every segment length and
at no enumeration cost, and `sepFamily` supplies the predicate separation the guard was also
reaching for.

## Argument order

Guard-first throughout, matching `Syntax/Formula.lean` and `../BiLasso/`: in `Formula.untl g e`
the guard `g` holds throughout the open interval and the event `e` is witnessed strictly later.

## Dependencies

- **Imports from**: `FormalSystem.Syntax.Context`, `FormalSystem.Syntax.SubformulaClosure.Closure`,
  `FormalSystem.Metalogic.Decidability.BiLasso.Periodic`, `FormalSystem.Semantics.ShiftSet`,
  `FormalSystem.Semantics.Validity`, `FormalSystem.Semantics.FrameClassValidity`,
  `FormalSystem.Metalogic.Soundness`, and both `Mathlib.Data.Int.SuccPred` and
  `Mathlib.Order.SuccPred.LinearLocallyFinite`
- **Imported by**: the re-export `FormalSystem.Metalogic.Decidability.WitnessFamily` beside this
  directory, and the generated library root `FormalSystem.lean`, which imports every module under
  `FormalSystem/` directly. Nothing here is outside the Lake build graph, and nothing here is
  listed in `scripts/module-invariants-manifest.txt`

## Related Documentation

- [Decidability README](../README.md)
- [BiLasso README](../BiLasso/README.md)

---

*Last verified: 2026-09-27*
