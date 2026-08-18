# Implementation Summary: Monotone time issuance across identification

- **Task**: 437 - repair_time_index_reuse_in_identification_plus_nexttime_bookkeeping
- **Plan**: `specs/437_repair_time_index_reuse_in_identification_plus_nexttime_bookkeeping/plans/01_monotone-time-issuance.md`
- **Status**: COMPLETED — all 10 phases
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
- **Verification**: `lake build` exit 0 (2458 jobs); `lake build BimodalTest` exit 0 (2508 jobs); sorry-free; axiom-free

## What was done

The ordered split's identification arm (`Tableau.lean`, the `.timeLinearity` `.branchingOrdered`
arm) called `branch.identifyTime t₂ t₁`, retiring `t₂` whatever its magnitude.
`firstIncomparablePair_spec` guarantees only `t₂ ≠ t₁`, never `t₁ < t₂`, so the arm could retire the
branch's **largest** time; `Branch.maxTime` fell with it and `Branch.nextTime = maxTime + 1` handed
back the value just retired.

The arm now merges `min t₁ t₂` into `max t₁ t₂`. Which numeral survives is semantically arbitrary —
identification asserts the two instants are the same, and nothing in the semantics reads a time
index's magnitude — so the orientation costs nothing and makes `Branch.maxTime` non-decreasing at
the only branch step that could lower it.

**The whole engine-side change is one arm in one file.** No new state, no signature change, no
threaded counter. `Branch.nextTime`, `Branch.maxTime`, `Branch.identifyTime` and
`TimeOrdering.identifyTime` are byte-unchanged; `SignedFormula.lean` and `Saturation.lean` are
absent from the task's cumulative diff.

## Key results landed

| Declaration | What it establishes |
|---|---|
| `maxTime_le_identifyTime_of_le` | Identifying a time into a time at least as large never lowers `maxTime`. Arbitrary branch, arbitrary times, **no membership hypothesis** |
| `retired_lt_nextTime_oriented` | The retired index is strictly below the post-arm `nextTime` — the statement that replaces the obstruction |
| `expandOnce_branch_shape_census` | Arm 3 is the engine's only non-additive branch step, **checked** rather than cited |
| `maxTime_monotone_along_run`, `nextTime_monotone_along_run` | Run-level: no successor of any shape has a smaller `maxTime`/`nextTime` than the branch it came from |
| `oriented_engine_does_not_produce_reuse` | Decided at the reuse witness: the arm now hands back `maxTime = 2` / `nextTime = 3` where it used to hand back `1` / `2` |
| `incomparableB_symm` (+ `orderDual_backward`) | R1 closed favourably — incomparability is symmetric |
| `runInvariant_identifyTime_oriented`, `ordTimesKnown_identifyTime_oriented` | Register entries 7/16's settled repair survives |
| `universeClosedAt_identify_at_trigger_oriented`, `timeMergeClosed_identifyTime_oriented` | Entries 10-12's confinement survives, discharging clause 2 **as it stands** |
| `knownTimes_card_lt_at_arm3_oriented`, `splitOrderedRank_lt_identifyTime` | The `.splitOrdered` termination measure's first component still strictly drops |
| C9 **register entry 18** | The verdict record, with the ladder costs and the scope fact a future reader needs |

## Findings worth carrying forward

**1. The reuse is closed; the measure is not.** Entry 18 says this explicitly. Entry 14's
refutation of `MintPaysForTime` as literally stated is untouched. Entry 17's refutation of the
`selfGuardRules ×ˢ U` ledger stands as a statement **about the unoriented arm** — its σ-hit
obligation was inherited from entry 15's reuse configuration, and that configuration no longer
occurs on the engine path. Whether a measure-side fourth component is now *provable* is a genuinely
open follow-on question that this task does not answer.

**2. The plan's R5 prediction inverted, and the honest response was the opposite of what the plan
scripted.** No engine-driven `decide` witness changed value. `reuse_driven_through_engine` is driven
from `reuseWitnessState`, which is assembled by a **direct** `Branch.identifyTime` call rather than
by the arm, so what it decides is a conditional — *if* a run reaches a branch whose `maxTime` has
fallen, the engine re-mints the retired index — which the repair does not touch. Both it and
`gate_step_fires` were kept at their original values with docstring paragraphs saying why, and the
measurement they cannot make was landed beside them as `oriented_engine_does_not_produce_reuse`.
This also corrects entry 15's wording ("a run and not a hand-assembled `Branch`"), which entry 18
carries because entry 15 itself is a preserved asset.

`gate_step_fires` survives for a sharper reason: the gate's trigger is `some (2, 0)`, so `min = 0`
and `max = 2` — the oriented arm and the unoriented one are **literally the same list** there.

**3. R3 and R4 did not materialise.** `Decidable.lean` needed docstring edits only; no file-scope
escalation was raised. And only **14 of 85** arm-shape occurrences repo-wide were arm-bound: the 67
in `MintBound.lean` that Phase 7 was sized around are generically quantified in `src`/`tgt`, so
`identifyTime t₂ t₁` there is naming convention, not a claim about the arm. That is the favourable
reading — the orientation really is re-labelling.

**4. One lemma needed genuinely new content.** `incomparableB_symm` required the *backward* half of
the reachability duality; `orderDual_holds` in `Fuel.lean` states it forwards only, and the two
closure conjuncts trade places under the duality rather than being preserved. `orderDual_backward`
is the only new independent proof in the whole task — a missing mirror in a reachability calculus,
not a defect in the orientation.

**5. The scope fact that shaped the design.** `Verified/Decidable.lean` carries **102**
`Branch.nextTime` references consuming `nextTime = maxTime + 1` definitionally, and it had
independently rediscovered this same obstruction from the `OrdWithin` side. Holding the four
definitions byte-unchanged and repairing at the call site collapsed that exposure from 102
references to one docstring paragraph, and left `Tableau.lean`'s nine mint sites needing no edit at
all. The two fallback ladder rungs were costed but never prototyped (a `TimeOrdering.horizon` field:
29 files, 35+47 literal sites; a threaded mint counter: two engine signatures plus
`Saturation.lean`), and those costs are recorded in entry 18.

## Plan Deviations

- **Phase 2** — *altered*: `maxTime_le_identifyTime_oriented` landed with **no** membership
  hypotheses, via the stronger `maxTime_le_identifyTime_of_le` which asks only `src ≤ tgt`. A
  strengthening, not a shortcut.
- **Phase 3** — *altered*: `incomparableB_symm` needed one new independent lemma,
  `orderDual_backward`. Eight of nine declarations were direct instantiations.
- **Phase 3** — *altered*: the confinement obligation landed as two declarations (predicate-level
  bridge + concrete `signedUniverse` discharge) rather than one.
- **Phase 4** — *altered*: the census was written to `handoffs/phase-4-census.md` rather than to a
  progress file, since this agent keeps no progress file.
- **Phase 6** — *altered*: Phase 3's `knownTimes_card_lt_identifyTime_oriented` lives in
  `MintBound.lean`, **downstream** of `Fuel.lean` and so unavailable there. Landed the Fuel-local
  `firstIncomparablePair_spec_oriented` instead and fed it to the unchanged generic lemma. The
  fuel-figure arithmetic was extracted into a new generic helper `splitOrderedRank_lt_identifyTime`
  rather than restated in place; `MintBound.lean`'s twin block now reuses it.
- **Phase 6** — *altered*: of the five prose sites listed, `Fuel.lean:2364` and `2510-2523` turned
  out to be about `hT` and `splitAwareFuel` and said nothing about arm 3's orientation, so they
  needed no edit.
- **Phase 7** — *altered*: `reuse_driven_through_engine` did **not** change value; kept at its
  original value with an explanatory docstring, and `oriented_engine_does_not_produce_reuse` added.
  See finding 2.
- **Phase 7** — *altered*: `orderDual_backward` and `incomparableB_symm` were **relocated** from the
  D2 subsection into section A, where the engine-facing consumers reach them. Lean's dependency
  order, not a content change.
- **Phase 8** — *altered*: neither `BranchOrder.lean` `#eval` row changed value, so neither was
  edited; a comment records that they are orientation-independent. The prose at 39/74/406 is about
  the loop-blocking repair, not arm 3, so it needed no edit.
- **Phase 10** — the FALSE/UNDECIDED branch did not run (Phase 1 decided TRUE); its checklist item
  is left unchecked deliberately rather than marked done.

## Files Changed

| File | Change |
|---|---|
| `FormalSystem/Metalogic/Decidability/Tableau.lean` | The oriented arm + its comment block (+26/-6) |
| `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` | 2 shape lemmas, 2 measure-decrease proofs, 2 new generic helpers |
| `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` | 2 shape sites, 15 arm-3 proof cases, 7 new oriented bridges, the gate/monotonicity/invariant subsections, C9 entry 18 |
| `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` | Prose only |
| `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` | Docstring only |
| `FormalSystem/Metalogic/Decidability/Verified/Bridge/BranchOrder.lean` | One comment only |

Absent from the cumulative diff: `SignedFormula.lean`, `Saturation.lean`,
`Tests/BimodalTest/UntlSnceCopyProbe.lean`.
