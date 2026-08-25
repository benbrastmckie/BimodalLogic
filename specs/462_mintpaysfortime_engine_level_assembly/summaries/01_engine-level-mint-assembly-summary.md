# Implementation Summary: Engine-Level Assembly for `MintPaysForTimeFixed` at a Nonempty Universe

- **Task**: 462 - mintpaysfortime_engine_level_assembly
- **Plan**: `specs/462_mintpaysfortime_engine_level_assembly/plans/01_engine-level-mint-assembly.md`
- **Report**: `specs/462_mintpaysfortime_engine_level_assembly/reports/01_engine-level-mint-assembly.md`
- **Type**: lean4
- **Status**: COMPLETED

## What Landed

A new section **D5** in
`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`, inserted immediately
before the C9 do-not-re-attempt register, discharging `MintPaysForTimeFixed fc U Tmax` at an
**arbitrary** universe under the single frame-class hypothesis
`¬ (FormalSystem.ProofSystem.FrameClass.Dense ≤ fc)`.

Every Lean change is an addition. No engine definition, no predicate statement, no figure, and no
previously landed declaration was altered. The one in-place edit is prose: C9 entry 20's
"*What is left*" paragraph.

### Declarations added

| Declaration | Role |
|---|---|
| `pick_stage_source_rule` (private) | The strengthened three-stage pick bridge: stage one keeps its `findApplicableRule` equation, stages two and three report `ruleMintsFreshTime r = false` |
| `findApplicableRule_ne_densityRule` | Density exclusion under `¬ (Dense ≤ fc)` |
| `applyRule_ne_persistent_of_fresh` (private) | The six witness-guarded minting rules never report `.persistent` |
| `isApplicable_untlNeg_trigger` / `isApplicable_snceNeg_trigger` | Trigger-shape recovery |
| `applyRule_untlNeg_active_guard` / `applyRule_snceNeg_active_guard` | ACTIVE-guard inversion, one `by_contra` each |
| `rule_census` (private) | The four-bucket partition of all thirty-six constructors, by `cases r <;> decide` |
| `pick_singleton_source`, `pick_singleton_source_noMint` (private) | Destructured-pick source adapters |
| `pickBranches_knownTimes_card_le_succ` (private) | One step adds at most one known time, at pick level |
| `mintPays_bucketA` / `_bucketB` / `_bucketC_untlNeg` / `_bucketC_snceNeg` (private) | The four buckets |
| `pickBranches_mintPays` (private) | The census case split |
| `expandOnceUnblocked_mintPays` | The engine lift |
| `mintPaysForTimeFixed_of_not_dense` | **The discharge** |
| `mintPaysForTimeFixed_signedUniverse_of_not_dense` | The `signedUniverse C L` instantiation, for every `C` |

## The Honest Scope Statement

**Landing this makes no terminus in `MintBound.lean` non-vacuous.** Both halves:

1. The **nine** statements carrying `hlab : UnorderedSuccessorLabelClosed fc L` stay vacuous at
   every nonempty `L`, because `unorderedSuccessorLabelClosed_nonempty_false` pins that predicate's
   satisfiability set at exactly `{∅}`. This work restates none of them and removes `hmint` from
   none of them.
2. Every `hlab`-free `hmint`-carrying terminus stays conditioned on `UniverseClosedAt fc U` plus
   `DifficultyBounded`/`StepLengthBounded` plus `PostBlockingSettles`/`PostBlockingSettlesRun` —
   three of which C9 entries 9, 11 and 22 refute outright.

What the work does deliver, and all it claims:

1. **The discharge itself**, at an arbitrary universe off `.Dense`, with no hypothesis added to the
   predicate and no figure changed.
2. **C9 entry 20's item (a) retired** — the engine-level assembly, the last non-density obstruction
   to the mint predicate itself. Item (b), the density coordinate, is untouched and remains the only
   thing left; `gapPotential` is still implemented nowhere and assumed by nothing.
3. **D3's discharge generalized** from the `untl`/`snce`-free fragment to arbitrary `C` including
   temporal operators — the case entry 20 itself calls the hard one.

The frame-class restriction is **one** hypothesis, `¬ (FrameClass.Dense ≤ fc)`, written visibly in
the theorem statement. It excludes `.Dense` and `.Dedekind` together and admits exactly `.Base` and
`.Discrete`.

## Phase 2 Route Taken (recorded as the plan requires)

The plan's first Phase 2 task was to cost the research report's §8 alternative — a `.persistent`
variant of `mintPotential_lt_of_pick_linear_sigmaFixed` that would replace six per-rule shape
lemmas — before writing the shape lemmas.

**The alternative is not available, and the reason is structural rather than a matter of effort.**
`findApplicableRule`'s `.persistent` arm carries **no guard at all**. Its `.linear` and `.branching`
arms test `witnessPresent rule sf branch timeOrd || trivialEventWitnessed …` and return `none` when
the test passes; the `.persistent` arm returns `some (rule, result, newOrd)` unconditionally, a
deliberate decision the engine's own comment records (every `.persistent` arm of `applyRule` already
filters its output against `branch.contains`). So there is no `findApplicableRule_guard_persistent`
to be had, and with it no `.persistent` payment lemma: the missing input is exactly the
`witnessPresent … = false` fact the guard would supply.

**Route actually taken**, and it is cheaper than either of the plan's two options: one lemma,
`applyRule_ne_persistent_of_fresh`, quantified over `r` under `ruleMintsFreshLabel r = true` and
`ruleMintsFreshTime r = true` — which is exactly the six — excluding `.persistent` on the rule side.
`.branchingOrdered` and `.notApplicable` need no exclusion at all, because neither contributes a
successor branch to `pickBranches`, so `.persistent` was the only shape left to close. Proof
skeleton is Probe 3's and Probe 6's, run once rather than six times.

## Deviations From the Plan

| Item | Deviation | Reason |
|---|---|---|
| Phase 2, six shape lemmas | Altered — one lemma replaces six | `applyRule_ne_persistent_of_fresh` covers all six at once; `.persistent` is the only shape needing exclusion |
| Phase 2, Probe 7 census | Altered — `cases r <;> decide` instead of `revert r; decide` | `TableauRule` has no `Fintype` instance, so the quantified form has no `Decidable` instance; the archived probe does not compile as written |
| Phase 2, `.persistent` docstring claim | Altered — the `.persistent` arm list was corrected | The plan named `allPastPos` and `someFutureNeg`; there are fifteen such arms, and the docstring now names them all |
| Phase 3, three private adapters | Added (not in the plan's declaration list) | `pick_singleton_source`, `pick_singleton_source_noMint`, and `pickBranches_knownTimes_card_le_succ` (the pick-level counterpart of `knownTimes_card_le_succ_of_unorderedSuccessor`, which buckets B and C need before the engine lift) |
| Per-declaration module builds | Altered — isolated `lake env lean` probe per phase, then one in-place module build per phase | A MintBound module build costs ~15 minutes; each phase was first compiled in isolation against the previous phase's olean (`open private` from Batteries), which is per-declaration evidence of the same kind |

## Scope Hypotheses

| Phase | Asserted | Actual | Verdict |
|---|---|---|---|
| 1 | ~55 declaration lines; Probe 4 transplants verbatim | 55 (bridge 45, exclusion 10); transplanted with no proof-script change beyond `private` and the name | confirmed |
| 2 | four-bucket partition is exact; six shape lemmas or one `.persistent` variant | partition confirmed by the `decide`-proved census; neither option taken — one exclusion lemma instead | partition confirmed; the either/or was a false dichotomy |
| 3 | ~200-280 lines; every bucket closes from a landed lemma with `omega` for both budget conjuncts | 257 lines; every bucket closed as described, no substitutes sought | confirmed |
| 4 | three declarations at ~30/~15/~8 lines; the `keyO` pattern transplants | 94 lines including the two 20-line `keyO`/`keyB` blocks; pattern transplanted unchanged | confirmed |
| 5 | ~60 lines of prose; register at 24 entries before and after; nine `hlab` carriers | 65 lines; 24 entries confirmed mechanically both sides; nine carriers confirmed by grep | confirmed |

Section D5's total is **665 lines**, against the plan's ~500-600 estimate — a ~11% overrun, entirely
in docstrings and section prose, not in proof script.

## Verification

| Check | Result |
|---|---|
| `lake build` | exits 0 |
| `bash scripts/check-module-invariants.sh` | ALL CHECKS PASSED — identical to the pre-task baseline |
| C2 flagship axiom sets | match baseline (`propext`, `Classical.choice`, `Quot.sound`) |
| `#print axioms` on the three new engine-level results | `propext`, `Classical.choice`, `Quot.sound` only |
| C3 structural `sorry` inventory | ZERO |
| C9 task-number citations under `FormalSystem/` | zero |
| Frozen files (`Fuel.lean`, `Saturation.lean`, `Tableau.lean`) | untouched (`git diff` empty) |
| Diff shape | 674 insertions, 9 deletions; every deletion inside C9 entry 20's prose paragraph |
| C9 register | exactly 24 entries before and after; header still reads "Twenty-four statements" |

## Files Modified

- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` (only source file touched)
