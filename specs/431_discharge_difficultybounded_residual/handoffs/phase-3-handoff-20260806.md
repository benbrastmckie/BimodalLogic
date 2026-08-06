# Phase 3 handoff (task 431)

## Immediate next action
Phase 4: `StepLengthGrowth`, `DifficultyBoundedAt`, `difficultyBoundedAt_ceiling`, plus the
full `applyRule` obligation-map docstring. Insertion point in
`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` is immediately after
`stepLengthBounded_of_difficultyBounded` (end of the Phase 3 block, inside the difficulty
toolkit section that sits between `MintPaysForTime` and `budgetPotential_step_unordered`).

## State
Phases 1, 2, 3 `[COMPLETED]`, each committed separately. Module build green; every new
declaration checked with `#print axioms` and depends only on `propext`, `Classical.choice`,
`Quot.sound` (no `sorryAx`, no `Lean.ofReduceBool`). Zero sorries in the file.

Landed declarations, in file order:
- `estimateBranchDifficulty_length_le`, `length_le_of_estimateBranchDifficulty_le`
- `natSum_le_of_sublist`, `natSum_le_of_subperm`, `subperm_map_of_subperm` (private plumbing)
- `branchCount_le_of_subperm`, `difficultyShape_le_of_subperm`,
  `estimateBranchDifficulty_le_of_subperm`
- `canonicalBranch`, `difficultyCeiling` (both `noncomputable`)
- `sublist_flatMap_of_mem`, `sublist_flatMap_mono` (private)
- `subperm_canonicalBranch`, `estimateBranchDifficulty_le_ceiling`, `difficultyCeiling_mono`
- `StepLengthBounded`, `difficultyBounded_of_stepLengthBounded`,
  `stepLengthBounded_of_difficultyBounded`

## Key decisions
- Scope option (b) held: `Saturation.lean`, `Fuel.lean`, `Tableau.lean` untouched. md5s pinned
  at start: Saturation `ae47004e06e77f2846cc3e1dfa408382`, Fuel `8a395bd7117a682c1f8302a2ac5f0f1f`,
  Tableau (at `FormalSystem/Metalogic/Decidability/Tableau.lean`, *not* under Verified/Termination)
  `cfd82332c8e400ac97ab709ece5dfb4a`.
- The generic-counter unification trick works in the real file exactly as the planning probe
  predicted: `simp only [estimateBranchDifficulty]` then `exact difficultyShape_le_of_subperm _ _ h`.
- Phase 3's Scope Hypothesis confirmed: `UniverseClosed`'s second conjunct covers `.splitOrdered`
  arm 3 with no extra hypothesis.

## Deviations so far
- `difficultyCeiling`/`canonicalBranch` must be `noncomputable` (`Finset.toList`), so Phase 2's
  `#eval` sanity check was run on an explicit literal canonical list instead: `U = {T□p, F(p U q)}`,
  `L = 3` gives length 6, difficulty 17.
