# Semantics

Task frame semantics for TM bimodal logic.

## Contents

This table is ordered by the layering, not alphabetically, and carries no line counts, so it is
registered as hand-maintained rather than generated. Registration is not an exemption from being
checked: the `INV` check in `scripts/check-module-invariants.sh` asserts it has a row for every
live file and subdirectory here, and no row for anything else.

<!-- INVENTORY: hand-maintained (dir=FormalSystem/Semantics) -->

| File | Description |
|------|-------------|
| TemporalOrder.lean | `TemporalOrder` — a nontrivial totally ordered abelian group, `def:temporal-order`'s object, bundled with its four algebraic instances; `intOrder` |
| TaskFrame.lean | Task frame structure (worlds, times, accessibility), the fibre/total-space pair, the class-helper families A-D, and the frame constants |
| Frames.lean | Aggregator for `Frames/` |
| Frames/ | The standard-frame index: `Standard` (1 file) — home of `translationFrame` and `permissiveFrame`, and the linked census of every other standard frame |
| FrameProperty.lean | Frame properties as predicates on `TaskFrame` (`IsDense`, `IsDiscrete`, `IsSuccArchDiscrete`, `IsComplete`, `IsDedekind`, and `Deterministic`), and the `FrameClass` ordering they induce |
| FrameClassValidity.lean | `FrameClass.Sat` and the `sat_intro` binder adapters: validity relative to a frame class |
| IntNormalForm.lean | The ℤ-frame normal form: over `D = ℤ` a frame is its one-step relation |
| TaskModel.lean | Task models with valuation functions |
| ConvexHistory.lean | Convex histories for temporal evaluation, and `TaskFrame.HF` — the paper's possible worlds |
| TruthClauses.lean | `TruthEnv` — the pointed truth relation with an inert environment parameter — and one class per primitive operator (`BotClause`, `ImpClause`, `BoxClause`, `UntlClause`, `SnceClause`, `StabClause`, `AllFutureClause`, `AllPastClause`) with the capability bundles over them; the derived operators as `abbrev`s and their characterization lemmas proved once, tiered by which primitives a language has. Carries the clause-layer extension contract |
| ValidityLayer.lean | `PointTruth` — the class abstracting truth at a point `(M, τ, x)` — and the validity layer written once against it: `TaskFrame.GenericValidOn`, `GenericValidOnFrames`, `GenericValidIn`, `GenericValid`, the two monotonicity lemmas, the eight binder-shape adapters and the three countermodel contrapositives; each language instantiates it and delegates. Carries the validity-layer extension contract |
| Truth.lean | `TruthAt`, the truth relation for formula evaluation, with its `truth_norm` simp-normal form and the clause lemmas that family comprises; the A-17 corollaries `truthAt_atomFree_history_indep`, `truthAt_gap`, `truthAt_cogap`, `truthAt_gap_shift` and `truthAt_gap_iff_cogap` |
| TruthTransport.lean | The model-to-model truth transport, factored out of `Truth.lean`: the relational `TruthCorr` / `Truth.truthAt_of_truthCorr` (one `induction φ`) from which `TimeShift.timeShift_preserves_truth`, `truthAt_of_truthIso` and `IntTransfer.truthAt_map` are derived; `TimeShift.ShiftRel`/`shiftCorr`; `TruthIso`/`TruthAntiIso`; and `Truth.box_const`/`box_time_const`, which sit here rather than beside the other `Truth` clause lemmas because their proofs consume `timeShift_preserves_truth` |
| ShiftSet.lean | Shift-set representation theorem: task models ↔ shift sets, both directions with truth correspondence |
| Validity.lean | Validity and semantic consequence |
| DeterministicBridge.lean | `lem:deterministic-singleton` as a **biconditional**: `TaskFrame.SingletonClasses`, `singletonClasses_of_deterministic` (choice-free), `deterministic_of_singletonClasses` (a theorem of ZFC, via `thm:extension`), `deterministic_iff_singletonClasses` |
| StateLocalTransfer.lean | `stateLocal_ofPlus_iff` — `(ofPlus φ).StateLocal ↔ φ.StateLocal`, a biconditional: the L⁺ state-locality fragment is exactly the `ofPlus`-preimage of the L⋆ one. Sits above both fragment modules so the L⁺ conservativity route acquires no L⋆ dependency |
| DurationClassification.lean | Classification of Dedekind-complete duration groups: discrete (`≃+o ℤ`) or densely ordered; also `duration_dense_or_least_pos`, the Archimedean-free order dichotomy |
| LexCarrier.lean | `LexInt`: `SuccOrder`/`PredOrder` instances, `isLeast_pos`, and the three non-Archimedean theorems for `α ×ₗ ℤ` at an arbitrary ordered abelian group `α` — instantiated at `ℚ` for the CEF countermodel and at `ℤ` for the `Sat .Discrete` separation |
| FrameAxioms.lean | The frame axioms (nullity, compositionality, reflection) as standalone statements |
| IntTransfer.lean | Transfer of ℤ-frame facts across the normal form |
| PartialHistory.lean | Partial histories on arbitrary nonempty subsets of the duration group — the tier *below* convexity |
| PartialHistoryOrder.lean | The order structure on partial histories |
| MinusLanguage.lean | Aggregator for `MinusLanguage/`; imported by the root aggregator `FormalSystem/FormalSystem.lean`, mirroring `Syntax/MinusLanguage.lean` |
| [MinusLanguage/](MinusLanguage/README.md) | L⁻ semantics: `MinusTruth`, `MinusFrame`, `MinusValidity`, `MinusSchemaValidity` (4 files) — native truth for the tense-primitive base language, its `TaskFrame`-free frame notion, and its validity predicates |
| PlusLanguage.lean | Aggregator for `PlusLanguage/`; imported by the root aggregator `FormalSystem/FormalSystem.lean`, mirroring `Syntax/PlusLanguage.lean` |
| [PlusLanguage/](PlusLanguage/README.md) | L⁺ semantics: `PlusTruth`, `PlusValidity`, `PlusPasting`, `PlusNonValidities`, `PlusDeterminism`, `PlusStateLocal` (6 files) — the stability modal `⊡`'s truth, validity, pasting, refutations, deterministic collapse and state-locality |
| StarLanguage.lean | Aggregator for `StarLanguage/`; imported by the root aggregator `FormalSystem/FormalSystem.lean`, mirroring `Syntax/StarLanguage.lean` |
| [StarLanguage/](StarLanguage/README.md) | L⋆ semantics: `StarTruth`, `StarValidity`, `StarDeterminism`, `StarNonValidities`, `StarStateLocal` (5 files) — truth over `(τ, x, v⃗)`, `sent:det` in both halves, `Det-pm` and state-locality |
| Extension.lean | Aggregator for `Extension/` |
| Extension/ | Extension of partial histories: `Admissible`, `Constraint`, `Extension`, `PeriodicExtension`, `Step` (5 files) |
| Ultraproduct.lean | Aggregator for `Ultraproduct/` |
| Ultraproduct/ | The dependent ultraproduct of shift sets and Łoś's theorem: `Carrier`, `IndexFilter`, `ShiftSetProduct`, `Los` (4 files) |
| Correspondence.lean | Aggregator for `Correspondence/` |
| Correspondence/ | The frame-class Galois layer: `Galois`, `Indicator`, `DurationFrames`, `FwdRec`, `FwdRecPeriodicity`, `FwdRecBridge` (6 files) |

## Key Definitions

- `TaskFrame`: Frame structure with world-time pairs and accessibility
- `TaskModel`: Frame with valuation function for atoms
- `ConvexHistory`: World states indexed by a convex set of times; the domain need not be all of `D`, so a convex history may be bounded
- `truth_at`: Truth of formula at convex history and time
- `valid`: Formula true in all models at all possible worlds

## The ℤ-frame normal form

`IntNormalForm.lean` establishes that over `D = ℤ` a task frame is determined by its **one-step**
relation `step w u := TaskRel w 1 u`, in both directions:

- **Decomposition** — `taskRel_eq_iter`: `TaskRel w d u` is an `|d|`-fold iterate of `step`,
  forwards for `d ≥ 0` and backwards for `d ≤ 0`. The zero case is the derived theorem
  `FrameOver.nullity_identity` (from *Seriality* and *Limit*), the positive
  case is *Compositionality* at `y = 1`, and the negative case is the converse convention.
- **Synthesis** — `TaskFrame.ofStep`: a bi-serial relation on a finite nonempty carrier generates a
  `TaskFrame ℤ` with every field discharged (`comp`, `converse`, `serial`, `limit`, `saturation`,
  plus the nonempty carrier). All but one are free from the normal form; *Seriality* is
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

*Last verified: 2026-09-16*
