# Sweep Evidence Report: Task #585

**Task**: 585 — Burn down the 316 live compiler warnings and add a warning gate
**Produced**: 2026-09-16 (repository hygiene sweep)
**Status**: Pre-research evidence. The full inventory is below; no further measurement is needed to start.
**Effort**: Large by volume, but highly phasable — 47 files, and the top 6 files hold 184 of the 316.
**Dependencies**: None. Overlaps with task 583 (the gate belongs in the same CI pass), so coordinate the gate half with it.
**Sources/Inputs**:
- `lake build` output, full, 2026-09-16 (exit 0, 2,653 jobs)
- `scripts/check-module-invariants.sh` C16 (`env_linter`) — establishes what is *not* covered
- `specs/reviews/review-2026-09-16.md`, Finding H4

## Executive Summary

- **`lake build` exits 0 with 316 warnings across 47 live files.** Nothing gates them: C16 runs
  the Batteries `env_linter` set (simpNF, docBlame, defsWithUnderscore, structureInType,
  tacticDocs, unusedArguments), which is a *declaration* linter and does not see Lean *compiler*
  warnings. The two sets are disjoint. This is a genuine hole in an otherwise comprehensive gate
  suite, not a redundancy.
- **75 of the 316 are forward-compatibility debt that will become build errors**: 71 deprecated
  `push_neg` and 4 deprecated `IsTrichotomous`/`IsIrrefl`. These should be fixed before the next
  Mathlib bump, not after it.
- **34 are correctness smells, not style**: 25 "tactic does nothing" and 9 "this tactic is never
  executed". Each marks a tactic whose removal changes nothing — usually a sign a proof drifted
  from the shape its author intended. These deserve reading, not bulk deletion.
- **Concentration makes this cheap to phase.** `SubformulaProperty.lean` alone holds 78 (25% of
  the total) and needs one kind of attention; the 21 files with a single warning each can be one
  closing sweep.

## Full inventory by kind

| Kind | Count | Nature |
|---|---|---|
| Unused auto-included section variable | 86 | Style; `variable` over-capture in section headers |
| Unused `simp` argument | 84 | Style, but see note — often a stale lemma name |
| `push_neg` deprecated → prefer `push Not` | 71 | **Forward-compat debt** |
| "tactic does nothing" | 25 | **Correctness smell** |
| Unreferenced variable name | 25 | Style; rename to `_x` |
| `Try this: intro …` | 12 | Mechanical; Lean supplies the replacement |
| "this tactic is never executed" | 9 | **Correctness smell** |
| Other Mathlib deprecation (`IsTrichotomous`, `IsIrrefl` → `Std.*`) | 4 | **Forward-compat debt** |
| **Total** | **316** | |

## Full inventory by file

| File | Total | Breakdown |
|---|---|---|
| `Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` | 78 | unused simp arg 54, does-nothing 19, never-executed 5 |
| `Metalogic/WeakCanonical/DenseModelSurgery/BadIntervals.lean` | 36 | push_neg 22, section var 14 |
| `Semantics/TaskFrame.lean` | 20 | section var 20 |
| `Metalogic/WeakCanonical/DenseModelSurgery/Lemma34.lean` | 19 | push_neg 12, section var 5, simp arg 2 |
| `Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean` | 16 | section var 9, unreferenced 5, Mathlib deprecation 2 |
| `Metalogic/Decidability/Verified/Termination/MintBound/MintPotential.lean` | 15 | simp arg 8, does-nothing 4, never-executed 3 |
| `Metalogic/Decidability/Verified/Bridge/IntTruth.lean` | 12 | unreferenced 8, section var 4 |
| `Metalogic/WeakCanonical/DenseModelSurgery/NoGaps.lean` | 11 | section var 6, unreferenced 4, push_neg 1 |
| `Metalogic/Decidability/Verified/Bridge/Interpolate.lean` | 11 | push_neg 11 |
| `Metalogic/WeakCanonical/DenseModelSurgery/Lemma5.lean` | 10 | push_neg 6, section var 4 |
| `Metalogic/Decidability/Tableau.lean` | 9 | simp arg 9 |
| `Metalogic/SoundnessLemmas/FrameClassVariants.lean` | 8 | Try this 8 |
| `Metalogic/Decidability/Verified/Decidable.lean` | 8 | push_neg 4, section var 4 |
| `Metalogic/WeakCanonical/DenseModelSurgery/TruthTransfer.lean` | 6 | push_neg 3, section var 3 |
| `Metalogic/Decidability/Verified/Bridge/DenseTruth.lean` | 5 | section var 5 |
| `Metalogic/Decidability/CountermodelExtraction.lean` | 4 | simp arg 4 |
| `Metalogic/Decidability/Verified/Bridge/TruthLemma.lean` | 4 | push_neg 4 |
| `Semantics/LexCarrier.lean` | 3 | section var 3 |
| `Metalogic/WeakCanonical/DenseModelSurgery/Singletons.lean` | 3 | section var 3 |
| `Metalogic/Decidability/Verified/Termination/MintBound/TimeCensus.lean` | 3 | simp arg 2, does-nothing 1 |
| `Metalogic/Decidability/Verified/Bridge/Valuation.lean` | 3 | section var 3 |
| `Semantics/DurationClassification.lean` | 2 | push_neg 2 |
| `Metalogic/Soundness.lean` | 2 | Try this 2 |
| `Metalogic/WeakCanonical/GroupModel/BlockDecomposition.lean` | 2 | Mathlib deprecation 2 |
| `Metalogic/Decidability/Verified/Termination/Fuel.lean` | 2 | does-nothing 1, never-executed 1 |
| `Metalogic/Decidability/BiLasso/Examples.lean` | 2 | simp arg 2 |
| `Metalogic/Conservativity/Z1Countermodel.lean` | 2 | push_neg 2 |

Twenty-one further files carry exactly one warning each: `Semantics/PartialHistoryOrder.lean`,
`Semantics/FrameAxioms.lean`, `Semantics/Ultraproduct/ShiftSetProduct.lean`,
`Metalogic/SoundnessLemmas/Separability.lean`, `Metalogic/BXCanonical/Chronicle/PointInsertion.lean`,
`Metalogic/Algebraic/FlowFrame.lean`, `Metalogic/WeakCanonical/MixedSum.lean`,
`Metalogic/WeakCanonical/RealModel/ShuffleReal.lean`, `Metalogic/Decidability/Saturation.lean`,
`Metalogic/Core/RestrictedMCS/Basic.lean`, `Metalogic/Decidability/FMP/FMP.lean`,
`Metalogic/Decidability/Verified/Termination/MintBound/OrientedGate.lean`,
`Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`,
`Metalogic/Decidability/BiLasso/Enumerate.lean`, `Metalogic/Conservativity/Plus/Atomization.lean`,
`Metalogic/Independence/CoarsenedModels.lean`,
`Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean`,
`Metalogic/Conservativity/DenseObstructionTransfer.lean`,
`Metalogic/Decidability/CancellableExpansion.lean`, `Automation/DatasetGenerator.lean`.

## Notes on the individual kinds

**Unused `simp` argument (84, 54 of them in one file).** Lean's hint is "Omit it from the simp
argument list," and for most of the 84 that is right. But an unused `simp` argument is also what a
*renamed or deleted* lemma looks like from the call site — the name still resolves but no longer
fires. Before bulk-removing `SubformulaProperty.lean`'s 54, check whether the same few names
recur; a repeated unused argument across many `simp` calls suggests one lemma changed shape and
the proofs are now leaning on something else.

**"tactic does nothing" (25) and "never executed" (9).** These two co-occur with the unused-simp
cluster (`SubformulaProperty.lean` 19+5, `MintPotential.lean` 4+3, `Fuel.lean` 1+1), which
reinforces the reading above: one termination-layer refactor left several proofs carrying tactics
that no longer bite. Treat those three files as one investigation, not as 33 separate removals.

**Unused section variable (86).** `Semantics/TaskFrame.lean` contributes 20 and `BadIntervals.lean`
14. The fix is narrowing `variable` lines or adding `include`/`omit`, and it is safe, but it does
change what is in scope for every theorem in the section — rebuild per file.

**`push_neg` (71).** Mechanical: `push_neg` → `push Not`. Verify the replacement is behaviourally
identical on at least one goal in each file before doing the rest by substitution.

**`Try this: intro …` (12).** Lean supplies the exact replacement text in the warning. Purely
mechanical.

## The gate half

Once the count is at (or near) zero, add a gate so it stays there. Options, in increasing
strictness:

1. A CI step that greps `lake build` output for `warning:` and fails on a count above a recorded
   baseline — the `scripts/nolints.json` pattern, applied to compiler warnings. Lets the count
   ratchet down without requiring zero on day one.
2. `-DwarningAsError=true` in `theoryLeanOptions` in `lakefile.lean`. Strictest, and it would have
   prevented all 316; but it also makes every future Mathlib deprecation an immediate build
   break, which may be too brittle for a project pinned to a Mathlib tag.

Recommend (1), with the baseline file committed and the number visible, so a PR that adds a
warning is a PR that edits the baseline and has to say why. Coordinate with task 583 so this
lands as one CI change rather than two.

## Recommended phasing

| Phase | Scope | Size |
|---|---|---|
| 1 | `push_neg` ×71 + Mathlib deprecations ×4, all files | 75, mechanical, highest value (forward-compat) |
| 2 | The termination-layer trio: `SubformulaProperty`, `MintPotential`, `Fuel` — investigate the does-nothing/never-executed/unused-simp cluster as one cause | 95, needs reading |
| 3 | Section variables ×86, per file, rebuild each | 86, safe but scope-changing |
| 4 | Unreferenced names ×25 + `Try this` ×12 + remaining simp args | 40, mechanical |
| 5 | The gate | — |

## Verification

- `lake build 2>&1 | grep -c 'warning:'` reports the target count (0, or the recorded baseline).
- `lake build` still exits 0 and `bash scripts/check-module-invariants.sh` passes in full — in
  particular C2/C14 axiom baselines must not move, since some of these edits touch proof tactics.
- No `sorry` introduced (C3).
- Each phase committed separately, so a regression bisects to a kind.
