# Phase 4 — Label Dimension and the Corrected 4.3c

- **Task**: 165, establish semantic finite model property
- **Phase**: 4 (Termination, WP3: T1/T2/T3), sub-phases 4.3c-prerequisite and 4.3c
- **Status**: Phase 4 remains `[PARTIAL]` — 4.2d and the three 4.3d residuals outstanding
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
- **Territory**: `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` only
- **Plan**: `specs/165_establish_semantic_finite_model_property/plans/01_tableau-decidability-two-track.md`

## What landed

All in `Fuel.lean` (468 → 917 lines), sorry-free, in four green commits.

### 4.3c-prerequisite — the label dimension

`chain_le_stock` had carried `∀ x ∈ run n, x.label ∈ L` as an open hypothesis. The decisive
observation is that it universally quantifies `L`, so instantiating at the run's **own** label set
makes the hypothesis a triviality and relocates the whole obligation into a *cardinality*.

- `Branch.labelFinset` / `worldFinset` / `timeFinset`, with `card_labelFinset_le` splitting the
  label count into the two components a `Label` actually has.
- `chain_le_own_labels`, `chain_le_worlds_times` — the relocation and the split.
- `TimeChain` — the run-level chain invariant, defined to be exactly
  `blocking_fires_of_card_lt`'s `hchain` at `ts := b.timeFinset`.
- `timeFinset_card_le_of_not_blocked` (+ empty-tracker variant) — **T2 contraposed** into the
  direction the fuel argument consumes: a branch the run has not blocked has at most `2 ^ (2·|C|)`
  times.
- `comparable_of_firstIncomparablePair_none` — `timeLinearity` is self-suppressing, so its silence
  *is* pairwise comparability of branch times.
- `timeChain_of_linearity_saturated`, `chain_le_worlds_of_not_blocked`,
  `chain_le_worlds_of_linearity_saturated` — the composition.

### 4.3c — `expandBranchWithFuel_isSome`, branch budget quantified

The plan's named deliverable `buildTableau_isSome` was refuted last dispatch. The corrected form
is proved here:

- `NoSplit` — the branch invariant under which the engine's step never splits and which survives
  an extending step.
- `expandBranchWithFuel_isSome_of_noSplit` — rules out **all three** sources of `none`: the branch
  budget guard by `branchesUsed + fuel ≤ maxBranches` (invariant along the run, since each step
  increments one and decrements the other); fuel exhaustion by the T3 progress measure
  (`U.card < b.toFinset.card + fuel`, already contradictory at `fuel = 0`); and the split arms by
  the invariant.
- `expandBranchWithFuel_isSome_of_stock` — the same at `signedUniverse C L`.
- `expandOnceUnblocked_nil`, `noSplit_nil`, `expandBranchWithFuel_nil_isSome` — a concrete
  non-vacuity witness, so `NoSplit` is demonstrably satisfiable rather than possibly empty.

The engine is untouched; `maxBranches = 50000` stands as the deliberate runtime guard.

## Findings that change the plan

1. **`OrderDual` is blocked by `private`, not by difficulty.** The one residual of the label
   dimension is that `firstIncomparablePair` records comparability as `futureOf`-membership while
   blocking reads it as `pastOf`. These are the two closures of the same constraint list, but
   `reachableForward`/`reachableBackward` (`SignedFormula.lean:741,751`) are `private`, so the
   induction cannot be *stated* from `Fuel.lean`. Discharge path: `open private … from …`, already
   used in this repo (`Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean:687`) — pure consumption,
   no engine edit. Five committed `#guard_msgs` rows run the condition on chain, fork, diamond,
   post-`identifyTime` and depth-30 orderings.
2. **Worlds are a dimension nobody had named.** T1 bounds formulas, T2 bounds times; a `Label` has
   *both* a world and a time, and **neither result bounds worlds**. `soundFuel' = 2·n·2^(2n)` has
   no world factor. The world count is carried as an explicit parameter `W`, and its argument (the
   S5 rules' fresh-world discipline) is a separate obligation.
3. **`buildTableau_isSome` stays unprovable at the default**, as the prior blocker note said. A
   `buildTableau`-level corollary needs a caller that fixes `maxBranches`.

## Verification

| Gate | Result |
|------|--------|
| `lake build FormalSystem.Metalogic.Decidability` | green (1054 jobs) |
| `lake build BimodalTest` | green (1949 jobs) |
| Sorries in `Verified/` | 0 |
| New vacuous definitions | 0 (the one repo-wide hit is pre-existing, `Examples/TemporalStructures.lean:277`) |
| New axioms | 0 (`propext`, `Classical.choice`, `Quot.sound` only) |
| Conformance corpus | verdict-neutral; 5 new `#guard_msgs` rows added |

`lake build` (full) is RED at
`FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` — pre-existing,
outside this phase's territory, and that module does not import `Decidability/`.

## Plan deviations

- **4.3c-prerequisite**: altered — does not fully discharge the label dimension; `OrderDual`
  remains a named hypothesis (annotated inline in the plan).
- **4.3c**: altered — `buildTableau_isSome` itself is not landed and cannot be at the engine's
  default; the `.split`/`.splitOrdered` arms are isolated behind `NoSplit` rather than proved.
- **4.2d**: not attempted (independent; blocks nothing).
