# Semantics

Task frame semantics for TM bimodal logic.

## Contents

| File | Description |
|------|-------------|
| TaskFrame.lean | Task frame structure (worlds, times, accessibility) |
| IntNormalForm.lean | The ℤ-frame normal form: over `D = ℤ` a frame is its one-step relation |
| TaskModel.lean | Task models with valuation functions |
| WorldHistory.lean | World histories for temporal evaluation |
| Truth.lean | Truth relation for formula evaluation |
| BLTruth.lean | `BLTruthAt` — the same truth relation for the tense-primitive base language, by native six-clause recursion on `BLFormula` per `def:BL-semantics` (not `TruthAt ∘ tr`) |
| ShiftSet.lean | Shift-set representation theorem: task models ↔ shift sets, both directions with truth correspondence |
| Validity.lean | Validity and semantic consequence |
| BLValidity.lean | `BLValid`, `BLSemanticConsequence`, `BLValidDense`, `BLValidDiscrete`, `BLValidDiscreteSucc`, `BLValidDedekindDense` — binder-for-binder base-language mirrors of Validity.lean |
| BLSchemaValidity.lean | DF/DN semantic lemmas (Lemmas B/C) and DF's `PredOrder` past-dual, consumed by `Metalogic/SpWitness.lean` and `bl_soundness_discrete_succ` |
| DurationClassification.lean | Classification of Dedekind-complete duration groups: discrete (`≃+o ℤ`) or densely ordered; also `duration_dense_or_least_pos`, the Archimedean-free order dichotomy |
| LexCarrier.lean | `SuccOrder`/`PredOrder` instances for `ℚ ×ₗ ℤ`, the non-Archimedean discrete carrier the CEF countermodel is built over |
| FrameAxioms.lean | The frame axioms (nullity, compositionality, reflection) as standalone statements |
| IntTransfer.lean | Transfer of ℤ-frame facts across the normal form |
| PartialHistory.lean | Partial world-histories on convex subsets of the duration group |
| PartialHistoryOrder.lean | The order structure on partial histories |
| Extension/ | Extension of partial histories: `Admissible`, `Constraint`, `Extension`, `PeriodicExtension`, `Step` (5 files) |
| Ultraproduct/ | The dependent ultraproduct of shift sets and Łoś's theorem: `Carrier`, `IndexFilter`, `ShiftSetProduct`, `Los` (4 files) |

## Key Definitions

- `TaskFrame`: Frame structure with world-time pairs and accessibility
- `TaskModel`: Frame with valuation function for atoms
- `WorldHistory`: Infinite sequence of worlds indexed by time
- `truth_at`: Truth of formula at world-history and time
- `valid`: Formula true in all models at all world-histories

## The ℤ-frame normal form

`IntNormalForm.lean` establishes that over `D = ℤ` a task frame is determined by its **one-step**
relation `step w u := TaskRel w 1 u`, in both directions:

- **Decomposition** — `taskRel_eq_iter`: `TaskRel w d u` is an `|d|`-fold iterate of `step`,
  forwards for `d ≥ 0` and backwards for `d ≤ 0`. The zero case is `nullity_identity`, the positive
  case is *Compositionality* at `y = 1`, and the negative case is the converse convention.
- **Synthesis** — `TaskFrame.ofStep`: a bi-serial relation on a finite nonempty carrier generates a
  `TaskFrame ℤ` with all seven fields discharged. Six are free from the normal form; *Seriality* is
  the one genuine obligation, and the module records the `Unit`-carrier counterexample showing that
  neither finiteness nor discreteness supplies it.
- **History space** — `mem_HF_iff_adjacent`: `H_F` over ℤ is exactly the set of bi-infinite
  step-paths `f : ℤ → WorldState` with `step (f n) (f (n+1))`. `def:world-history`'s all-pairs
  task-respect obligation is redundant over ℤ; adjacency implies it.

`Truth.box_const` is the companion fact on the truth side: a boxed formula's truth value depends on
neither the history nor the time, so it is a constant of the model. History-independence is
definitional (the box clause never mentions `τ`); time-independence is time-homogeneity.

Together these reduce the semantics of a finite-`WorldState` ℤ-frame to reachability in a finite
directed graph — the presentation `Metalogic/Decidability/IntPresentation.lean` computes on.

## Related Documentation

- [Parent README](../README.md)
- [Metalogic Soundness](../Metalogic/README.md) - Uses semantics for soundness

---

*Last verified: 2026-05-29*
