# Implementation Summary: Task #426 — Settle the anchor row for `(G p) → □(G p)`

- **Task**: 426
- **Plan**: `plans/01_record-anchor-row-verdict.md` (5 phases, all COMPLETED)
- **Type**: lean4
- **Status**: implemented

## Verdict

**Hypothesis (a) — budget, and it was already satisfied.** The branch saturates; the measured
fuel ceiling is **25**; `decide ((G p) → □(G p)) = .invalid` with `getCountermodel?.isSome = true`.
No theorem, definition, or fuel bound needed to change, and none did. The task's premise
(`.fuelExhausted`, no countermodel) described a state the repository had already left behind.

Hypothesis (b) is real, but on a **different formula**: `F(G p)` reaches a stationary 21-formula
branch at every fuel from 25 to 4096, with an unfulfilled `T(F ¬p)` eventuality at a blocked time
as residue. No fuel figure can rescue it. The distinction the task asked for is therefore not
"which of (a) or (b) is true of the engine" but "which is true of *this* formula" — and for the
anchor row the answer is unambiguously (a).

## What was done, by phase

**Phase 1 — reproduce and bracket.** Every number Phases 2-4 write into source was re-derived
from scratch with `lake env lean`, not carried over from a docstring or the research report. The
ceiling was bracketed from both sides (largest `none` = 24, smallest `hasOpen` = 25), the
sub-ceiling `none` was attributed to fuel exhaustion inside `expandBranchWithFuel` rather than the
`maxBranches` arm (it survives raising `maxBranches` to `10^9`) or the unsaturated arm, and the
`F(G p)` residue was identified before and after `saturateBlocked`. Zero divergences from the
research. Recorded in `reports/02_measured-constants.md` with the exact source behind every
figure.

**Phase 2 — `CrossWorldPropagationProbe.lean` module docstring.** The paragraph claiming the
engine "no longer wrongly closes, but neither does it positively refute — it exhausts its fuel"
contradicted the file's own row F eleven lines below. Replaced with the explicit three-step
history (`extractionFailed` → `fuelExhausted` → `.invalid` with a countermodel), the measured
ceiling and its both-sided bracket, attribution of the state-2→3 move to `Tableau.lean`'s
`trivialEventWitnessed`, and a pointer to the `soundFuel'` record. The dangling
"see the plan's Phase 6 triage" pointer was deleted and not replaced with any task-number
citation. No other stale claim was found in the file; the deletion narrative in the opening
sections is accurate and was left untouched.

**Phase 3 — rows G and H.** Rows A and C were `isValid`-only, so each read `false` identically
under `.invalid`, `.fuelExhausted` and `.extractionFailed` — the exact indistinguishability that
let this formula family go a full cycle misread. Rows G and H pin the constructor tuple *and*
`getCountermodel?.isSome` for rows A's and C's formulas, both measuring
`((false, true, false, false, false), true)`. Pure addition: the diff removes zero lines, so
rows A-F are byte-identical.

**Phase 4 — `Fuel.lean`, two docstrings, no code.** `soundFuel'`'s docstring gains a measured
anchor, worded so the 25 is unmistakably empirical and adjacent to — not conflated with — the
proved figures (`soundFuel = 2048`, `soundFuel' = 1 048 576`, `worldFuel' … 1 =
1 099 512 676 352`, i.e. ~82×, ~4.2×10⁴ and ~4.4×10¹⁰ headroom). The `resolveOpenArm = none` note
keeps every existing claim and adds why no fuel figure can rescue the `F(G p)` witness, turning a
named counterexample into a diagnosed one.

**Phase 5 — gate.** All assertions pass; see Verification below.

## Verification

| Check | Result |
|---|---|
| `lake build` | **exit 0**, "Build completed successfully (2462 jobs)" |
| `lake env lean Tests/BimodalTest/CrossWorldPropagationProbe.lean` | clean; rows A-H all green |
| `lake env lean` on `Fuel.lean` | clean (warnings only, all pre-existing) |
| Source files in this task's commits | exactly the two declared `file_scope` files |
| `Tableau.lean` touched | no (0 of 4 commits) |
| `boxNeg`/`diamondPos` | both still emit `.linear (witness :: boxProps ++ diaProps)` |
| `BoxNegReachabilityProbe.lean`, `CountermodelExtraction.lean`, `DecisionProcedure.lean` | untouched |
| `sorry` count, both files | 0 |
| `axiom` count, both files | 0 |
| Rows A-F pinned values | byte-identical (Phase 3 diff removes zero lines) |
| Task-number references in either source file | none |
| `Fuel.lean` diff | 50 insertions / 1 deletion, every line inside a doc comment |

## Plan Deviations

- None (implementation followed plan).

## Follow-ups recorded, not worked

All three are outside this task's `file_scope` and must not be fixed silently:

1. `Tests/BimodalTest/BoxNegReachabilityProbe.lean` — its module docstring and row-12 docstring
   carry the identical superseded narrative on the identical formula that Phase 2 fixed here.
   Needs an explicit scope extension or a follow-up task.
2. `DecisionProcedure.lean:194` maps every `buildTableau = none` to `.fuelExhausted`, conflating
   fuel exhaustion, the `maxBranches` budget, and the "still not saturated" arm. On `F(G p)` it
   reports fuel exhaustion where §5 of the measurement report shows none was exhausted — the same
   misattribution that already cost this formula family a cycle.
3. `CountermodelExtraction.lean` flattens the `(world, time)` label out of the Layer-0
   `SimpleCountermodel`, so the returned valuation is unusable even though the refutation is
   sound. Already disclaimed by `BoxNegReachabilityProbe.lean` row 11.

## Artifacts

- `reports/02_measured-constants.md` — reproduced measurement table with reproduction sources.
- `Tests/BimodalTest/CrossWorldPropagationProbe.lean` — corrected module docstring, rows G and H.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` — measured anchor on
  `soundFuel'`, diagnosed `F(G p)` witness note.
