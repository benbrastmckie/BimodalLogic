# Implementation Summary: Discharge the `DifficultyBounded` residual

- **Task**: 431 — Discharge `DifficultyBounded fc U D` (at `β ≥ 3`) on the totality terminus
- **Plan**: `specs/431_discharge_difficultybounded_residual/plans/01_discharge-difficultybounded-residual.md`
- **Status**: all 7 phases `[COMPLETED]`
- **Files modified**: `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` (only)
- **Build**: full `lake build` green (2333 jobs)
- **Sorries in MintBound.lean**: 0 (unchanged from baseline)
- **Axioms**: every new declaration depends only on `propext`, `Classical.choice`, `Quot.sound`.
  Zero `sorryAx`, zero `Lean.ofReduceBool`, zero `native_decide`.

## Outcome

The residual is settled, and the answer is a refutation plus a repair, not a proof.

`DifficultyBounded fc U D` — the hypothesis the landed terminus
`buildTableauAt_isSome_of_budget` carries — is **false at every `D`**, at every frame class, whenever
`U` contains a formula the engine fires on. `difficultyBounded_multiplicity_false` is the witness, and
it is stated in the general universally-quantified-in-`D` form (the plan's pre-declared
`decide`-on-a-concrete-`D` fallback was not needed). The cause is list multiplicity:
`estimateBranchDifficulty` sums over the branch **list** and adds `b.length / 4`, every confinement
fact in the development is about `b.toFinset`, and nothing in the repository asserts a branch is
`Nodup`.

Two things this is **not**:

1. It is not the `private` visibility of `temporalCount`/`modalCount` in `Saturation.lean`, which is
   what the residual's own docstring used to blame. `private` blocks name resolution, not unfolding:
   `estimateBranchDifficulty_length_le` proves a bound on `estimateBranchDifficulty` from inside
   `MintBound.lean` with the markers exactly as they are, and
   `estimateBranchDifficulty_le_of_subperm` proves an upper bound by unifying a lemma with
   universally quantified counters against the unfolded goal. The docstring is corrected in-source.
   **`Saturation.lean` was not edited**, and neither were `Fuel.lean` or `Tableau.lean` (md5s
   re-verified unchanged).
2. It is not about formula complexity. The refuting witness is `F(p → q)` between two atoms, on
   which both weighted counters are `0`; the whole refutation runs through the `b.length / 4` term.

The repair is `StepLengthBounded fc U L`: the same statement with `estimateBranchDifficulty _ ≤ D`
weakened to `_.length ≤ L`. It is **equivalent up to a factor of 4** to the difficulty bound, so
nothing is lost, and unlike the difficulty bound it is satisfiable.

## What landed

**The difficulty toolkit (Phases 1-2)**
- `estimateBranchDifficulty_length_le`, `length_le_of_estimateBranchDifficulty_le` — a difficulty
  bound *is* a length bound.
- `branchCount_le_of_subperm`, `difficultyShape_le_of_subperm`,
  `estimateBranchDifficulty_le_of_subperm` — monotonicity under sub-permutation, with the private
  counters supplied by unification.
- `canonicalBranch`, `difficultyCeiling` (both `noncomputable`), `subperm_canonicalBranch`,
  `estimateBranchDifficulty_le_ceiling`, `difficultyCeiling_mono`.

**The equivalence (Phase 3)**
- `StepLengthBounded`, `difficultyBounded_of_stepLengthBounded`,
  `stepLengthBounded_of_difficultyBounded`. `UniverseClosed`'s second conjunct turned out to cover
  the `.splitOrdered` arms with no extra hypothesis, as the plan's Scope Hypothesis predicted.

**The satisfiable form (Phase 4)**
- `StepLengthGrowth` (with the full 36-arm `applyRule` obligation map in its docstring),
  `DifficultyBoundedAt`, `difficultyBoundedAt_ceiling`.

**The sibling terminus (Phase 5)**
- `buildTableauAt_isSome_of_lengthBudget`, `buildTableauAt_isSome_at_seed_lengthBudget`. Each is one
  application of the landed theorem; the landed `buildTableauAt_isSome_of_budget`,
  `buildTableauAt_isSome_at_seed`, `expandBranchWithFuel_isSome_of_budget` and
  `stepDecreases_budgetPotential` proof terms are byte-identical (checked).

**The refutation (Phase 6)**
- `multWitness`, `multEmitted`, `multUniverse`, `multBranch`, `blockedTimes_empty`,
  `findApplicableRule_multWitness`, `expandOnceUnblocked_multBranch`,
  `difficultyBounded_multiplicity_false`.

**The register (Phase 7)**
- Entry 9, and the register head updated from eight entries to nine.

## Plan Deviations

1. **Phase 2 — `difficultyCeiling` must be `noncomputable`** (`Finset.toList` is). Consequence: the
   plan's `#eval` sanity check is impossible on the definition itself. The equivalent check was run
   on the canonical list written as an explicit literal: at `U = {T□p, F(p U q)}` and `L = 3` the
   canonical branch has length 6 and difficulty 17 — finite, as required.
2. **Phase 4 — three figures in the plan's obligation map were wrong and are corrected in-source**,
   as the phase's Scope Hypothesis instructed:
   - `applyRule` has **36** arms, not the plan's "~25".
   - Two arms the plan's map omitted are present, and both are constant: `.orderTrichotomy`
     (Tableau.lean:1282, three `.branching` arms of length 2) and `.denseIndicatorClosure`
     (Tableau.lean:1331, `.linear []`).
   - **`c = 3` is too small; `c = 5` is the corrected constant.** The
     `witness :: gProps ++ fNegProps ++ modalProps` arms carry a *fourth* branch-length term, because
     `modalProps` is `boxDiamondPersistence` (Tableau.lean:434-442), itself two branch `filterMap`s
     concatenated. The `.branching` arms of `.untlPos`/`.sncePos`/`.untlNeg`/`.snceNeg` reach
     `2 + 4 * b.length`, so a successor reaches `2 + 5 * b.length`. The statements are parametric in
     `c`, so widening cost nothing downstream.
   - `.z1Rule` is at Tableau.lean:1408, not 1409.
   - The plan's "13 branch-mapped arms", "4 ordering-driven arms" and "six `prior*`/`z1`/`sep` arms"
     counts all checked out exactly.
3. **Phase 6 — the pre-declared fallback was not used.** The generic reduction went through, and more
   cleanly than anticipated: `blockedTimes b TimeOrdering.empty fc tr = []` holds for an *arbitrary*
   branch, frame class and tracker (`blockCandidates` is empty at the empty ordering), so no
   `knownTimes`/`timeType` reasoning about the padded branch was needed at all. Phase 6 is
   `[COMPLETED]`, not `[COMPLETED WITH EXCLUSIONS]`, and no Reasoned Exclusions table is required.

No other deviations. Every plan-specified declaration landed under its planned name, in the planned
order, with the planned proof route.

## Verification performed

- Full `lake build` green from the current tree; module-scoped
  `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green at each
  phase.
- `#print axioms` sweep over all 26 externally-addressable new declarations: only `propext`,
  `Classical.choice`, `Quot.sound`. Zero `sorryAx`, zero `Lean.ofReduceBool`. `native_decide` does
  not appear in the file.
- `grep -c sorry MintBound.lean` = 0, unchanged from its pre-task value.
- `git diff --stat` shows `MintBound.lean` as the only modified `.lean` file (689 insertions, 10
  deletions; all 10 deletions are docstring prose).
- md5 pins re-checked and unchanged: `Saturation.lean` `ae47004e06e77f2846cc3e1dfa408382`,
  `Fuel.lean` `8a395bd7117a682c1f8302a2ac5f0f1f`, `Tableau.lean` (at
  `FormalSystem/Metalogic/Decidability/Tableau.lean`) `cfd82332c8e400ac97ab709ece5dfb4a`.
- The four landed terminus-chain proof terms confirmed byte-identical against the pre-task baseline.
- Every file:line citation in every new docstring resolved against the current sources; one stale
  figure found and fixed (`.z1Rule` 1409 to 1408), and one same-file line citation replaced by a
  declaration name so it cannot go stale.
- Do-not-re-attempt register (now nine entries): none of entries 1-8 re-attempted, confirmed by
  targeted greps over the additions. In particular no branch-cardinality claim about `.splitOrdered`
  arms (entry 3), no lower bound on `(b.identifyTime t₂ t₁).toFinset.card` (entry 6), and
  `OrdTimesLeMaxTime` never mentioned (entry 7) — `RunInvariant` is consumed as a hypothesis only.
- `bash .claude/scripts/check-task-references.sh`: PASS, 0 unexempted occurrences.

## Follow-up

Proving `StepLengthGrowth fc 5` — a 36-arm case analysis over `applyRule`, with the four
ordering-driven arms routed through `OrdTimesKnown`. The complete obligation map is recorded on
`StepLengthGrowth`'s docstring, so no fresh reconnaissance is needed. Landing it turns
`difficultyBoundedAt_ceiling` into an unconditional discharge of the satisfiable form of this
residual, which is the furthest it can be taken. Recommend `/spawn`.
