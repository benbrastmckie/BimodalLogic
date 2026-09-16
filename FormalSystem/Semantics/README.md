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
| MinusTruth.lean | `MinusTruthAt` — the same truth relation for the tense-primitive base language, by native six-clause recursion on `MinusFormula` per `def:BL-semantics` (not `TruthAt ∘ tr`) |
| MinusFrame.lean | `MinusFrame` — a native L⁻ frame notion not bound to `TaskFrame` (points with an unbounded, transitive, irreflexive, forward- and backward-linear strict order, no group structure), its truth recursion `MinusFrameTruth` with `□` as the universal modality, `MinusFrameValid`, the `MinusFrameTruth.*` characterization family, and the order-reversal transfer lemma `truth_swap`; the frame class a countermodel to `(Sp)` lives on |
| ShiftSet.lean | Shift-set representation theorem: task models ↔ shift sets, both directions with truth correspondence |
| Validity.lean | Validity and semantic consequence |
| MinusValidity.lean | `MinusValid`, `MinusSemanticConsequence`, `MinusValidDense`, `MinusValidZTime`, `MinusValidZTimeSucc`, `MinusValidRTime` — binder-for-binder base-language mirrors of Validity.lean |
| MinusSchemaValidity.lean | DF/DN semantic lemmas (Lemmas B/C) and DF's `PredOrder` past-dual, consumed by `Metalogic/Conservativity/SpWitness.lean` and `minus_soundness_ztime_succ` |
| PlusTruth.lean | `SameStateAt` (the paper's `⟨τ⟩_x`) and `PlusTruthAt` — the truth recursion for L⁺ (L plus the stability modal `⊡`, `PlusLanguage/Formula.lean`), the `PlusTruth.*` clause lemmas, the S5 validities of `⊡`, and `stab_state_only` |
| PlusValidity.lean | `PlusValidOnFrames`, `PlusValidIn`, `PlusValid` and per-class abbreviations — L⁺ mirrors of Validity.lean; `plusTruthAt_ofFormula` and `plusValidIn_ofFormula_iff`, semantic conservativity of L⁺ over L at every frame class |
| PlusPasting.lean | `paste` — two total histories sharing a state paste into a total history — the purity congruences, and the pasting validities PS/US/FS/GS with their past mirrors |
| PlusNonValidities.lean | The five refutations on `natFrame` over ℤ that bound the `⊡` axiom set from above (`⊡p → □⊡p`, `G⊡p → ⊡Gp`, `⊡GPp → G⊡Pp`, *Determined*, `P⊡p → ⊡Pp`) |
| PlusDeterminism.lean | `app:deterministic`'s positive half: `states_eq_of_deterministic` (the singleton bridge), `stab_iff_of_deterministic`, `determined_of_deterministic`, `stab_biconditional_plusValidOn_of_deterministic` — the collapse `⊡φ ↔ φ` over every `TaskFrame.Deterministic` frame, choice-free (`[propext]` only) |
| DeterministicBridge.lean | `lem:deterministic-singleton` as a **biconditional**: `TaskFrame.SingletonClasses`, `singletonClasses_of_deterministic` (choice-free), `deterministic_of_singletonClasses` (a theorem of ZFC, via `thm:extension`), `deterministic_iff_singletonClasses` |
| StarTruth.lean | `StarTruthAt` — the truth recursion for L⋆ (L⁺ plus the time registers, `StarLanguage/Formula.lean`) over the manuscript's points `(τ, x, v⃗)`; the `StarTruth.*` clause lemmas; `starTruthAt_ofPlus`; and the transport layer `star_truth_congr_ext`, `update_shift_comm`, `starTruthAt_timeShift` (the vector **shifted**, never dropped) |
| StarValidity.lean | `TaskFrame.StarValidOn`, `StarValidOnFrames`, `StarValidIn`, `StarValid` — L⋆ mirrors of Validity.lean with the stored-time vector as an extra binder; `starValidOn_ofPlus`; `settledDisj`, `sentDet` (`sent:det`), `sentDet_unfold` (the paper's `(∗)` chain), and `not_starValidOn_sentDet` |
| StarDeterminism.lean | `app:deterministic-future`'s positive half (`sentDet_of_deterministic`) and Theorem C's `Det-pm` half: `star_congr_of_deterministic`, `detPM` (schematic in `φ : StarFormula`), `detPM_unfold`, `detPM_of_deterministic` (schematic), `deterministic_of_detPM` (hypothesis at atoms), `deterministic_starDefinable` (the three-way equivalence: the atomic fragment forces determinism, determinism delivers the full schema) — the last two theorems of ZFC |
| StarNonValidities.lean | `app:deterministic-future`'s negative half: `refute_sentDet` over `NF`, the same countermodel `refute_determined` uses, and `not_starValid_sentDet` |
| PlusStateLocal.lean | The **state-locality** fragment of L⁺: `PlusFormula.StateLocal` (syntactic, by structural recursion over all seven constructors — `box` and `stab` admitted for an *arbitrary* argument, `untl`/`snce` excluded) and `IsPlusStateLocal` (semantic); `isPlusStateLocal_box`, `isPlusStateLocal_stab`, the soundness induction `isPlusStateLocal_of_stateLocal`, the two non-preservation witnesses `not_isPlusStateLocal_someFuture` / `not_isPlusStateLocal_somePast` on `NF`, the headline `φ ↔ ⊡φ` (`plusStateLocal_stab_iff`, `plusStateLocal_plusValid_iff_stab`), and `stab_of_stateLocal` — the AS witness, strictly generalizing the atom-level `p → ⊡p` |
| StarStateLocal.lean | The **state-locality** fragment of L⋆: `StarFormula.StateLocal` (syntactic, by structural recursion — `box` and `stab` admitted for an *arbitrary* argument, `untl`/`snce`/`timeRecall` excluded) and `IsStateLocal` (semantic); `isStateLocal_box`, `isStateLocal_stab`, the soundness induction `isStateLocal_of_stateLocal`, the three non-preservation witnesses `not_isStateLocal_someFuture` / `not_isStateLocal_somePast` / `not_isStateLocal_timeRecall` on `NF`, and the headline `φ ↔ ⊡φ` (`stateLocal_stab_iff`, `stateLocal_starValid_iff_stab`) |
| StateLocalTransfer.lean | `stateLocal_ofPlus_iff` — `(ofPlus φ).StateLocal ↔ φ.StateLocal`, a biconditional: the L⁺ state-locality fragment is exactly the `ofPlus`-preimage of the L⋆ one. Sits above both fragment modules so the L⁺ conservativity route acquires no L⋆ dependency |
| DurationClassification.lean | Classification of Dedekind-complete duration groups: discrete (`≃+o ℤ`) or densely ordered; also `duration_dense_or_least_pos`, the Archimedean-free order dichotomy |
| LexCarrier.lean | `LexInt`: `SuccOrder`/`PredOrder` instances, `isLeast_pos`, and the three non-Archimedean theorems for `α ×ₗ ℤ` at an arbitrary ordered abelian group `α` — instantiated at `ℚ` for the CEF countermodel and at `ℤ` for the `Sat .Discrete` separation |
| FrameAxioms.lean | The frame axioms (nullity, compositionality, reflection) as standalone statements |
| IntTransfer.lean | Transfer of ℤ-frame facts across the normal form |
| PartialHistory.lean | Partial histories on arbitrary nonempty subsets of the duration group — the tier *below* convexity |
| PartialHistoryOrder.lean | The order structure on partial histories |
| Extension/ | Extension of partial histories: `Admissible`, `Constraint`, `Extension`, `PeriodicExtension`, `Step` (5 files) |
| Ultraproduct/ | The dependent ultraproduct of shift sets and Łoś's theorem: `Carrier`, `IndexFilter`, `ShiftSetProduct`, `Los` (4 files) |
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

*Last verified: 2026-09-15*
