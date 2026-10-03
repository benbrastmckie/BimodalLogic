# Semantics

Task frame semantics for TM bimodal logic.

The semantics of the three **extension languages** is not here. L⁻, L⁺ and L⋆ each live as a
self-contained component at the library root — [`../MinusLanguage/`](../MinusLanguage/README.md),
[`../PlusLanguage/`](../PlusLanguage/README.md), [`../StarLanguage/`](../StarLanguage/README.md) —
carrying their syntax, their proof system and their semantics in one directory. A fourth,
[`../OpenLanguage/`](../OpenLanguage/README.md), extends L⁺ by the open-future and open-past
modals and is semantic only. Two more semantic-only components,
[`../HybridLanguage/`](../HybridLanguage/README.md) (L⁺ plus the same-state modality, state
registers and the state binder) and [`../QuantLanguage/`](../QuantLanguage/README.md) (L plus
propositional quantifiers), rest on `HistoryMorphism.lean` below. What stays here
is L's own semantics, plus the two **cross-language bridges** that span two families and so
belong to neither: `DeterministicBridge.lean` and `StateLocalTransfer.lean`.

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
| Frames/ | The standard-frame index (2 files): `Standard` — home of `translationFrame` and `permissiveFrame`, and the linked census of every other standard frame; `TranslationProduct` — the translation product `FrameOver.translationProduct`, a proof device showing what L, L⁺ and L⋆ cannot see of a frame (recurrence, transposition), never an intended model |
| FrameProperty.lean | Frame properties as predicates on `TaskFrame` (`IsDense`, `IsDiscrete`, `IsSuccArchDiscrete`, `IsComplete`, `IsDedekind`, and `Deterministic`), and the `FrameClass` ordering they induce |
| FrameClassValidity.lean | `FrameClass.Sat` and the `sat_intro` binder adapters: validity relative to a frame class |
| FrameConstraintIndependence.lean | `def:frame`'s four constraints are **pairwise independent** over `ℤ`: four witness relations (`emptyRel`, `totalRel`, `rayRel`, `driftRel`), sixteen theorems placing each constraint against the other three, and the aggregate `constraints_pairwise_independent` — the tree's single citable statement that the four-clause frame-condition row cannot be compressed to three. **Not the tree's first independence witnesses**: `StateTopology/ConstraintWitnesses.lean` already carries a complete matrix, and this module's header cites it row by row. What is new is the aggregate, the first *Limit* refutation over **discrete** time (the funnel's needs `[DenselyOrdered ↑D]`), and import-light reachability from `Semantics.lean` — `TaskFrame` and `Mathlib.Data.Int.SuccPred` only, where the topology-carrying witnesses are deliberate leaves |
| IntNormalForm.lean | The ℤ-frame normal form: over `D = ℤ` a frame is its one-step relation |
| SlicedFrame.lean | Frame synthesis on a **sliced** carrier `ℤ × W`: infinite, with finite fibres. `FrameOver.ofSlicedStep` from a time-indexed one-step relation, its five frame laws as named lemmas (*Saturation* by `TaskFrame.saturation_of_fib_finite`, not by finiteness of the carrier), and the history space as exactly the **offset** step paths. **Not** `IntNormalForm.lean`'s `ofStep`, which requires `[Finite W]` on the whole carrier |
| TaskModel.lean | Task models with valuation functions |
| TruthClauses.lean | `TruthEnv` — the pointed truth relation with an inert environment parameter — and one class per primitive operator (`BotClause`, `ImpClause`, `BoxClause`, `UntlClause`, `SnceClause`, `StabClause`, `AllFutureClause`, `AllPastClause`) with the capability bundles over them; the derived operators as `abbrev`s and their characterization lemmas proved once, tiered by which primitives a language has. Carries the clause-layer extension contract |
| ValidityLayer.lean | `PointTruth` — the class abstracting truth at a point `(M, τ, x)` — and the validity layer written once against it: `TaskFrame.GenericValidOn`, `GenericValidOnFrames`, `GenericValidIn`, `GenericValid`, the two monotonicity lemmas, the eight binder-shape adapters and the three countermodel contrapositives; each language instantiates it and delegates. Carries the validity-layer extension contract |
| Truth.lean | `TruthAt`, the truth relation for formula evaluation, with its `truth_norm` simp-normal form and the clause lemmas that family comprises; the A-17 corollaries `truthAt_atomFree_history_indep`, `truthAt_gap`, `truthAt_cogap`, `truthAt_gap_shift` and `truthAt_gap_iff_cogap` |
| TruthTransport.lean | The model-to-model truth transport, factored out of `Truth.lean`: the relational `TruthCorr` / `Truth.truthAt_of_truthCorr` (one `induction φ`) from which `TimeShift.timeShift_preserves_truth`, `truthAt_of_truthIso` and `IntTransfer.truthAt_map` are derived; `TimeShift.ShiftRel`/`shiftCorr`; `TruthIso`/`TruthAntiIso`; and `Truth.box_const`/`box_time_const`, which sit here rather than beside the other `Truth` clause lemmas because their proofs consume `timeShift_preserves_truth` |
| ShiftSet.lean | Shift-set representation theorem: task models ↔ shift sets, both directions with truth correspondence |
| Validity.lean | Validity and semantic consequence |
| ConvexTruth.lean | The convex-index consequence relations C3 and C4: `TruthAtConvex`, a truth recursion written beside `TruthAt` at a partial-history index (box over the convex histories through the evaluation time, tenses restricted to the index's domain); `ValidC3`, `ValidC4` and their class-level and finite-context forms; the C3 clause lemmas; the germ theorems `c3_box_untl_unsat` / `c3_box_snce_unsat`; shift invariance `truthC3_timeShift` |
| ConvexTruthCut.lean | `TruthAtConvexCut`, the cut-back box range as a named alternative to `ConvexTruth.lean`'s: box over the convex histories whose domain contains the index's domain. A definition only — the box becomes index-dependent, so the primary survival table is not inherited |
| DeterministicBridge.lean | `lem:deterministic-singleton` as a **biconditional**: `TaskFrame.SingletonClasses`, `singletonClasses_of_deterministic` (choice-free), `deterministic_of_singletonClasses` (a theorem of ZFC, via `thm:extension`), `deterministic_iff_singletonClasses` |
| StateLocalTransfer.lean | `stateLocal_ofPlus_iff` — `(ofPlus φ).StateLocal ↔ φ.StateLocal`, a biconditional: the L⁺ state-locality fragment is exactly the `ofPlus`-preimage of the L⋆ one. Sits above both fragment modules so the L⁺ conservativity route acquires no L⋆ dependency |
| DurationClassification.lean | Classification of Dedekind-complete duration groups: discrete (`≃+o ℤ`) or densely ordered; also `duration_dense_or_least_pos`, the Archimedean-free order dichotomy |
| LexCarrier.lean | `LexInt`: `SuccOrder`/`PredOrder` instances, `isLeast_pos`, and the three non-Archimedean theorems for `α ×ₗ ℤ` at an arbitrary ordered abelian group `α` — instantiated at `ℚ` for the CEF countermodel and at `ℤ` for the `Sat .ZTime` separation |
| FrameAxioms.lean | The frame axioms (nullity, compositionality, reflection) as standalone statements |
| HistoryMorphism.lean | History-lifting morphisms between task frames over one temporal order (`HistMap`, `HistMorphism`, `HistMap.mapH`, `HistMap.pullM`) and `TaskFrame.RecurrenceFree` (no world history visits a world state twice), with `trivialFrame_not_recurrenceFree` and `exists_sat_not_recurrenceFree`: every frame class contains a frame with recurrence. A morphism preserves pulled-back valuations, the history/time structure and the same-state relation, **not** state identity. The language-independent layer beneath `HybridLanguage/` and `QuantLanguage/` |
| IntTransfer.lean | Transfer of ℤ-frame facts across the normal form |
| TimeIndexed.lean | `TimeIndexed`, the time-indexed frame structure — states plus a relation indexed by an ordered *pair of times* rather than by a duration — with its predicate family (`Hist`, `Limit`, `Compositional`, `Serial`, `Converse`, `Static`, `ConstantHistories`, `Stationary`, `P`) and the Dedekind rigidity boundary `constantHistories_of_lub`: over a densely ordered, Dedekind-complete time order, finitely many states plus *Limit* force every history to be constant. Shared infrastructure — the manuscript's frame-correspondence Theorem A is its other intended consumer, which is why the field names are that program's and not `FrameOver`'s |
| TimeIndexedSharpness.lean | Sharpness of both hypotheses of `TimeIndexed.constantHistories_of_lub`, and the duration-vs-time comparison: `qSwitchFrame`, the two-state frame over `ℚ` switching across `√2`, satisfying *Limit* yet not constant-historied (Dedekind completeness cannot be dropped), and `zSwitchFrame` over `ℤ` (density cannot be dropped). Carries the table at which the Archimedean and Dedekind boundaries are set side by side |
| Periodicity.lean | Pigeonhole, loop splicing and bounded reachability over a finite carrier, stated against `IntNormalForm.lean`'s `iter`/`IsStepPath`. **Not** `Correspondence/FwdRecPeriodicity.lean`: this module is the general finite-carrier toolkit the decision procedure's lasso search rests on, while that one is the forward-recurrence half of the frame-class Galois layer |
| PartialHistory.lean | Partial histories on arbitrary nonempty subsets of the duration group, the `IsTotal`/`IsConvex` predicates, time shift, and `WorldHistory` — the world histories (the paper's possible worlds), with the `state` accessor. Also the **restriction map** `PartialHistory.restrict`, the easy direction of the identification (`restrict_isPartialHistory`, `eq_restrict_of_extends`) and the alternative presentation `IsRestriction` — all at **no** frame constraint, not even an ambient `[F.IsRegular]` |
| PartialHistoryOrder.lean | The order structure on partial histories, the chain suprema and the Zorn instance, plus `restrict_mono` and `restrict_le_restrict_iff`. **Zero occurrences of `IsRegular`**: the Zorn layer is constraint-free, and that is a structural invariant, not an accident |
| Extension.lean | Aggregator for `Extension/` |
| Extension/ | Extension of partial histories: `Admissible`, `Completion`, `Constraint`, `Extension`, `PeriodicExtension`, `Step` (6 files). **`Completion`** isolates the exact condition `lem:step` consumes — `PartialHistory.Completion`, proved equivalent to the one-point extension property — derives `thm:extension` from it with no `[F.IsRegular]` binder at all (`extension_of_completion`), and shows *Saturation* is redundant over `def:BX-z`'s ℤ-time (`extension_of_isZTime`). **`Extension`** additionally carries the identification: partial histories **are** the restrictions of possible worlds, pointwise (`exists_restrict_eq`) and at the extension order (`exists_worldHistory_restricting_pair`) |
| Ultraproduct.lean | Aggregator for `Ultraproduct/` |
| Ultraproduct/ | The dependent ultraproduct of shift sets and Łoś's theorem: `Carrier`, `IndexFilter`, `ShiftSetProduct`, `Los` (4 files) |
| Presheaf.lean | Aggregator for `Presheaf/` |
| Presheaf/ | The interval site `Int(D)` and the behavior presheaf `Beh(F)` on it: `Site` (1 file). `Site` carries the translations `Tr p` of `def:interval-site`, the three category laws, `Tr.le_of_hom` and the Johnstone coverage (`coverLeft`/`coverRight`/`cover_germ_composites`), stated over a bare `TemporalOrder` with no task frame. Both modules close with `assert_not_exists` on the proof system, so the cluster is provably **below** `Truth.lean`. The source appendix `app:Structure` is cut from the paper in full, so `def:interval-site` and `def:behavior-presheaf` resolve against `docs/reference/paper-definitions-of-record.md` as `DANGLING` rows rather than against a live `\label{}` |
| Correspondence.lean | Aggregator for `Correspondence/` |
| Correspondence/ | The frame-class Galois layer: `Galois`, `Indicator`, `DurationFrames`, `FwdRec`, `FwdRecPeriodicity`, `FwdRecBridge`, and the rigidity theorem with its sharpness witnesses, `Rigidity`, `RigiditySharpness` (8 files) |
| StateTopology.lean | The state topology of a task frame: the cone-neighbourhood topology `𝒩_F` as the sole `TopologicalSpace` instance on a **general** frame's state space, the cone-subbasis topology `𝒯_F` of `def:task-topology` as a plain `def` with no instance, and `FrameOver.t1Space_iff_limit` — `𝒩_F` is T1 exactly when the frame satisfies *Limit*. Also carries the appendix register: `FrameOver.isOpen_iff` (open sets in one clause), `FrameOver.r0Space_stateTopology` (`app:topology-r0`, named), `FrameOver.iInter_cone_eq_singleton` (the paper's equality form of *Limit*), `TaskFrame.t1Space_nbhdTopology_iff_iInter_cone_of_serial` (the biconditional against that equality form, under *Seriality* alone), and the two formulation bridges `TaskFrame.t1Space_iff_closure_singleton` / `TaskFrame.r0Space_iff_mem_closure_comm`, which match the paper's closure phrasings to Mathlib's `T1Space` and `R0Space`. `TaskFrame.finalTopology_eq_of_surjective_open_history` is the converse of `finalTopology_le_nbhdTopology`: a **single** surjective open history collapses the final topology of all histories onto `𝒩_F`, with no relation-level hypothesis — specialised on the metric frame in `StateTopology/MetricFrame.lean` and obstructed by the hedgehog in `StateTopology/Counterexamples.lean`. **Deliberately outside this aggregator**: `Mathlib.Topology.*` brings order and completeness instances with it, and routing them through `Semantics.lean` would put them in scope for every downstream module. The generated library root imports it directly |
| StateTopology/ | Frame witnesses for the topology development: `Counterexamples`, `ConstraintWitnesses`, `MetricFrame` (3 files). **`Counterexamples`** — frames satisfying some `def:frame` constraints and not others: the four-state funnel is *Serial*, *Compositional* and *Saturated* and fails *Limit*, with `𝒯_F` T1 on it nonetheless; the two-origin half-line and the hedgehog are **regular task frames** (all four constraints, `TwoOrigins.frame_saturation`, `Hedgehog.frame_saturation`, both `IsRegular` instances), the first T1 and not Hausdorff (`TwoOrigins.taskFrame_t1_not_t2`), the second putting `𝒩_F` strictly below the final topology of all histories and naming `𝒯_F ≠ 𝒩_F` (`Hedgehog.coneTopology_ne_nbhdTopology`, strictly so in `Hedgehog.coneTopology_lt_nbhdTopology`). On the two-origin frame the two topologies **coincide** (`TwoOrigins.frame_coneTop_eq_stateTopology`) although *Triangle* fails there (`TwoOrigins.not_triangle`), so *Triangle* is sufficient but not necessary for cone-openness, and non-Hausdorffness is a property of the frame rather than of the choice of topology (`TwoOrigins.frame_not_t2Space_coneTop`). **`ConstraintWitnesses`** — a constraint or separation property *failing*: the ghost ray is *Serial* and *Compositional*, fails *Limit*, and its `𝒩_F` is **not R0** (`GhostRay.frame_not_r0Space`), so R0 is exactly as fragile as T1; the ℚ-carrier two-origin relation keeps the first three constraints and **fails *Saturation*** (`RationalTwoOrigins.not_rel_saturation`), which is why the real-carrier witness is over `ℝ`; and the **void** and **bump** frames on `Bool` over ℤ-time complete the independence matrix, failing *Seriality* (`voidFrame_not_serial`) and *Compositionality* (`bumpFrame_not_compositional`) respectively while satisfying the other three — so every one of `def:frame`'s four constraints now has a compiled independence witness. **`MetricFrame`** — names the metric frame `rel c r y u ↔ |u - r| ≤ c·|y|`, previously only prose; it is regular at every positive speed (`MetricFrame.isRegular`) and on it `𝒩_F` **is** the final topology of all histories (`MetricFrame.finalTopology_eq_nbhdTopology`), locating the hedgehog's separation in branching rather than in the cone construction. All three are leaves, for the same import-weight reason |

## Key Definitions

- `TaskFrame`: Frame structure with world-time pairs and accessibility
- `TaskModel`: Frame with valuation function for atoms
- `PartialHistory`: World states indexed by a nonempty set of times; the domain need not be all of `D`. The total ones are the world histories, `WorldHistory F`, at which truth is evaluated; convexity is the predicate `IsConvex`
- `truth_at`: Truth of formula at a world history and time
- `valid`: Formula true in all models at all possible worlds

## The ℤ-frame normal form

`IntNormalForm.lean` establishes that over `D = ℤ` a task frame is determined by its **one-step**
relation `step w u := TaskRel w 1 u`, in both directions:

- **Decomposition** — `taskRel_eq_iter`: `TaskRel w d u` is an `|d|`-fold iterate of `step`,
  forwards for `d ≥ 0` and backwards for `d ≤ 0`. The zero case is the derived theorem
  `FrameOver.nullity_identity` (from *Seriality* and *Limit*), the positive
  case is *Compositionality* at `y = 1`, and the negative case is the reflection law
  (`FrameOver.reflection`).
- **Synthesis** — `TaskFrame.ofStep`: a bi-serial relation on a finite nonempty carrier generates a
  `TaskFrame ℤ` with every obligation of `FrameOver.ofReflectiveRegular` discharged (the reflection
  law, the nonempty carrier, and the four `def:frame` constraints *Compositionality*, *Seriality*,
  *Limit* and *Saturation*, which are the fields of the class `FrameOver.IsRegular` rather than of
  the frame). All but one are free from the normal form; *Seriality* is
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

*Last verified: 2026-09-27*
