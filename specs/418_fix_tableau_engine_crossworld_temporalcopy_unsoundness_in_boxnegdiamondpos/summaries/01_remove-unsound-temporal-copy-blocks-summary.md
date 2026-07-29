# Implementation Summary: Task 418 — Remove the Unsound Cross-World Temporal Copies

- **Task**: 418 — fix_tableau_engine_crossworld_temporalcopy_unsoundness_in_boxnegdiamondpos
- **Plan**: `plans/01_remove-unsound-temporal-copy-blocks.md`
- **Status at end of this dispatch**: **PARTIAL** — Phases 1-5 [COMPLETED], Phase 6 [PARTIAL],
  Phases 7-8 [NOT STARTED]
- **Session**: `sess_1785302672_d06f95`

## What was done

The soundness fix itself is complete, committed, and the library build is green.

Six `let` blocks in each of `applyRule`'s `.boxNeg` and `.diamondPos` arms copied
temporal-universal and temporal-existential signed formulas verbatim from the current branch into
the freshly minted `□`/`◇`-witness world. `T(Gφ)` says φ holds along *this* history's future —
exactly what `□`/`◇` quantify over, and therefore exactly what may not be assumed of an
alternative world. All twelve blocks, both `temporalProps` assemblies, and both
`++ temporalProps` result-list suffixes are deleted. Each rule now emits
`.linear (witness :: boxProps ++ diaProps)`.

| Phase | Status | Outcome |
|---|---|---|
| 1 — build-reliability protocol | [COMPLETED] | Advisory lock convention established (none existed); environment snapshot; infra-vs-verdict triage checklist |
| 2 — BEFORE baseline | [COMPLETED] | Both builds green, RC 0; **corpus is 142 rows, not the plan's 145** |
| 3 — the deletion | [COMPLETED] | `Tableau.lean` edited; scoped build green |
| 4 — library build + prose | [COMPLETED] | `lake build` green with **zero** proof repairs needed |
| 5 — `boxAnchoredCheck` finding | [COMPLETED] | Measured, carrier list re-derived, handed to task 165 |
| 6 — AFTER corpus measurement | **[PARTIAL]** | 4 of 8 probe modules measured (14 moved rows); 4 still building when the dispatch ended |
| 7 — adjudicate and realign | [NOT STARTED] | blocked on Phase 6 |
| 8 — acceptance gate | [NOT STARTED] | blocked on Phase 7 |

## The headline result

`Tests/BimodalTest/BoxNegPreservationProbe.lean` row 3 was written to measure the unsoundness
directly, at the `applyRule` level. Its docstring reads:

> *"This is the measurement. A branch containing both is unsatisfiable outright, so the successor
> of a satisfiable branch is unsatisfiable and `RuleSound carrierBase .boxNeg` is false."*

It evaluated `true` before the fix. **It now evaluates `false`** — applying `.boxNeg` to that
branch no longer manufactures a same-formula/same-label/opposite-sign pair. Rows 1 and 4 give the
mechanism: `emitted.length` moved `2 → 1` and "the emitted set contains a `T(G p)` that was
standing at another world" moved `true → false`. The rule now emits the witness alone.

This is the most direct available confirmation that the task achieved its stated goal, and unlike
the `(G p) → □(G p)` verdict it is independent of any fuel budget or search-depth question.

## Before/after verdict-change table

Seventeen rows measured as moved, across five of the eight probe files. Every value is quoted
from Lean's own `- info:` / `+ info:` diff. Full detail, per-row, in `artifacts/after-verdicts.md`.

| # | Probe row / formula | Old verdict | New verdict | Bucket |
|---|---|---|---|---|
| 1 | `RayRegionProbe` D — `(□p ∧ ◇q) → r` | `OPEN \|W\|=2 \|T\|=7 check=true rayUp=true rayDn=true rays=[(2,2),(5,5)]` | `OPEN \|W\|=2 \|T\|=7 check=false rayUp=false rayDn=false rays=[(2,2),(0,0)]` | (d) |
| 2 | `BoxSpreadProbe` A — `(□p ∧ ◇q) → r`, `.Base` | `OPEN spread=false anchor=true grid=true \|W\|=2 \|T\|=7` | `OPEN spread=false anchor=false grid=false \|W\|=2 \|T\|=7` | (d) |
| 3 | `BoxSpreadProbe` B — `(□p ∧ ◇(G q)) → r` | `OPEN spread=false anchor=true grid=true \|W\|=2 \|T\|=7` | `OPEN spread=false anchor=false grid=false \|W\|=2 \|T\|=7` | (d) |
| 4 | `BoxSpreadProbe` C — `(□p ∧ ◇q) → r`, `.Dense` | `OPEN spread=false anchor=true grid=true \|W\|=2 \|T\|=10` | `OPEN spread=false anchor=false grid=false \|W\|=2 \|T\|=8` | (d) |
| 5 | `RegionGateProbe` A | `gate=true check=true cands=[[3×8],[3×8]]` | `gate=false check=false cands=[[3×8],[0×8]]` | (d) |
| 6 | `RegionGateProbe` B | `gate=true check=true cands=[[3×8],[3,3,3,3,1,1,1,1]]` | `gate=false check=false cands=[[3×8],[0×8]]` | (d) |
| 7 | `RegionGateProbe` C (`.Dense`) | `\|T\|=10 gate=true check=true cands=[[3×11],[3×11]]` | `\|T\|=8 gate=true check=true cands=[[3×9],[1×9]]` | (d) |
| 8 | `RegionGateProbe` H | `gate=true check=true cands=[[3×11],[3,3,3,3,1,1,1,1,1,1,1]]` | `gate=false check=false cands=[[3×11],[0×11]]` | (d) |
| 9 | `TemporalWitnessProbe` D `:408` | `check=true … rP=true` (U and S) | `check=false … rP=false` (U and S) | (d) |
| 10 | `TemporalWitnessProbe` D `:521` | `D check=true uNAR=true sNAR=true` | `D check=false uNAR=true sNAR=true` | (d) |
| 11 | `TemporalWitnessProbe` D `:629` | `D gen=false check=true …` | `D gen=false check=false …` | (d) |
| 12 | `TemporalWitnessProbe` D `:775` | `D gen=false check=true …` | `D gen=false check=false …` | (d) |
| 13 | `TemporalWitnessProbe` D `:927` | `D gen=false check=true …` | `D gen=false check=false …` | (d) |
| 14 | `TemporalWitnessProbe` D `:1085` | `D gen=false check=true uPR=true [self=true …]` | `D gen=false check=false uPR=false [self=false …]` | (d) |
| 15 | `BoxNegPreservationProbe` 1 — `emitted.length` | `2` | `1` | **(b)** |
| 16 | `BoxNegPreservationProbe` 3 — opposite-sign clash in `emitted` | `true` | `false` | **(b)** |
| 17 | `BoxNegPreservationProbe` 4 — copied `T(G p)` present in `emitted` | `true` | `false` | **(b)** |

**Rows that did not change, in aggregate**: 86 of the 103 rows in the five measured files
(`TemporalWitnessProbe` 65/71, `RegionGateProbe` 6/10, `RayRegionProbe` 6/7, `BoxSpreadProbe` 2/5,
`BoxNegPreservationProbe` 2/5) plus **all 5** of `CrossWorldPropagationProbe`, which **built
green**. The remaining 39 rows across `TableauConformance` (27) and `BoxNegReachabilityProbe` (12)
are **not yet measured**.

**Fourteen of the 17 are bucket (d)** — decidable branch-gates or structural metrics on a
multi-world branch, every one of which used to compute `true` *because of* the unsound copies: the
corpus was measuring the bug and reporting it as health. **Three are bucket (b)** — the
`BoxNegPreservationProbe` rows that pinned the defect directly and now pin its absence.

**No verdict** (`CLOSED`/`OPEN`/`STALLED`, `isValid`) moved anywhere in the measured set, and
**no bucket-(c) under-closing regression was found**. `CrossWorldPropagationProbe` — five rows
pinning `isValid` on three invalid formulas and two controls — passes completely unchanged.

**That last conclusion is provisional.** The 39 unmeasured rows sit in `TableauConformance` (27)
and `BoxNegReachabilityProbe` (12), and `TableauConformance` is the one file that pins
CLOSED/OPEN/STALLED verdicts directly, across four frame classes. It is therefore exactly where a
genuine under-closing regression would surface. "Zero bucket-(c)" is a true statement about the
103 rows read, not yet about the corpus.

## The anchor result — measured, and the plan's headline criterion is NOT met

```
decide: valid=false invalid=false fuelExhausted=true extractionFailed=false countermodel?=false
buildTableau 1000 = STALLED (none)
```

| Criterion | Plan required | Measured | Met? |
|---|---|---|---|
| `buildTableau ((G p) → □(G p)) 1000 .Base` | `.hasOpen` | `none` | **NO** |
| `decide` constructor | `.invalid` | `.fuelExhausted` | **NO** |
| `getCountermodel?.isSome` | `true` | `false` | **NO** |

| | Pre-fix | Post-fix |
|---|---|---|
| `buildTableau … 1000` | `.allClosed` | `none` |
| `decide` | `.extractionFailed` | `.fuelExhausted` |
| What the procedure claims | **"φ is valid"** — false, φ is invalid | **"undetermined"** |

**The soundness defect is gone.** By this codebase's own R7 semantics
(`DecisionProcedure.lean`), `extractionFailed` means *the tableau closed, so the formula is
valid, we just could not rebuild the proof term* — `isKnownValid` is true of it. That was a false
assertion about an invalid formula. `fuelExhausted` is the only constructor `isUndecided`
recognises. The procedure moved from **a wrong answer to no answer**, which is the direction that
matters for soundness.

**But the intended repair did not land.** The plan wanted the engine to positively refute the
formula with an extracted countermodel. It does not reach saturation within fuel 1000 — fuel 30,
60 and 1000 all return `none`, so the ceiling is not yet bracketed from above. This is
**bucket (e)**, the same phenomenon as the slowdown below.

Per the plan's Rollback/Contingency section this is recorded and triaged, **not** repaired by
reinstating a deleted block: reverting would trade honest ignorance for a false claim of
validity, which is strictly worse. Three options for the next dispatch — raise the fuel and
re-measure; investigate whether the branch saturates at all (a termination question for
`Verified/Termination/Fuel.lean` rather than a budget question); or accept `.fuelExhausted` as
the correct current verdict and record the countermodel as owed — are set out in
`artifacts/after-verdicts.md`. **Option three needs an explicit decision, not a default**, since
it leaves the task's stated headline goal unmet.

One corpus gap worth naming: `CrossWorldPropagationProbe` row B is `isValid ((G p) → □(G p))` and
passes green, but `isValid` is `true` only for `.valid`, so it reads `false` under `.invalid` and
`.fuelExhausted` alike. **The corpus does not currently pin the distinction that matters here.**
Adding a row that pins the `decide` constructor on this formula would be a real improvement.

## Performance — a material cost, now quantified

| Module | Baseline | Post-fix | Factor |
|---|---|---|---|
| `CrossWorldPropagationProbe` | **1.2 s** | **1363 s** (~23 min, built green) | **~1100×** |
| `BoxNegPreservationProbe` | cached at baseline | **1048 s** (~17 min) | — |
| `RayRegionProbe` / `BoxSpreadProbe` / `RegionGateProbe` / `TemporalWitnessProbe` | cached | 3.3 s / 7.8 s / 12 s / 21 s | negligible |

The two slow modules are exactly the two whose rows run `isValid`/`decide` on formulas that used
to close and now do not. The four fast modules call `buildTableau` at explicit low fuel (200) and
are barely affected.

This is the plan's risk-asymmetry argument surfacing as wall-clock: removing emitted formulas
shrinks a branch's contradiction surface, so branches that used to close now stay open and
`decide` runs the whole fuel budget plus proof search plus countermodel extraction instead of
terminating early. It is the expected direction and a cost, not a soundness problem — but a full
corpus build must now be budgeted in tens of minutes at minimum, run in the background, never in
a foreground window that can time out.

## The `boxAnchoredCheck` finding — handoff to task 165

Full write-up: `artifacts/boxanchored-finding.md`.

`boxAnchoredCheck` computed `true` on multi-world branches only because of the deleted blocks; it
now computes `false` (measured on `BoxSpreadProbe` rows A/B/C). **`boxGridCheck` — the conclusion
the truth lemma's `box` case actually consumes — collapses too**, which the plan did not predict
and which closes the "just prove the grid directly" repair route. The corpus measurement shows the
*whole family* of decidable branch gates going false on minted worlds: `regionGate`,
`regionLabelCheck`, `rayUpOk`/`rayDnOk` as well.

Nothing breaks at typecheck. All 14 carrier lemmas (3 + 1 in `BoxSaturation.lean`, 6 in
`IntTruth.lean`, 5 in `DenseTruth.lean`) take the check as a hypothesis they never unfold, and the
library build is green with zero repairs. What is lost is *dischargeability by computation on real
engine output*. Three repair options are sketched with their soundness obligations; none is
implemented, deliberately.

Two corrections to the plan's static analysis, both recorded: the mechanism claim is refined
(nested `T(□□χ)` still reaches a minted world with `T(Gχ)` via `boxProps` + `boxTemporal`, and
`Saturation.lean`'s MT4/MT6 rows still print PASS, corroborating it), and the carrier list
composition differs from the prediction (`IntTruth.lean:366` is not a carrier;
`sat_box_grid_of_anchored` is one and was missed).

## Constraints honored

- **`Verified/Decidable.lean` was not modified.** Confirmed absent from `git diff --name-only`.
- **The `RuleSound` proof was not attempted.**
- **No replacement propagation block was added.** `git diff <phase-3-commit> -- Tableau.lean` is
  empty at every later phase boundary.
- **No `sorry`, no vacuous definition, no new axiom.** The `Verified/` tree still has zero
  term-level `sorry` (the 4 grep hits are the string "sorry-free" and one docstring mention).
- **No `#guard_msgs` block was deleted, commented out, or weakened.** No test file was edited at
  all in this dispatch.
- **`lake clean` was never run.**

## Corrections to the plan, recorded rather than suppressed

1. The corpus is **142** `#guard_msgs` directives, not 145. Three of the plan's grep hits are
   prose mentions (`TableauConformance` ×2, `RayRegionProbe` ×1).
2. Phase 4 predicted zero compile-time repairs. **Confirmed exactly** — 1983 jobs, zero errors,
   with only inert simp-list pruning and prose rewrites performed.
3. `boxGridCheck` collapses alongside `boxAnchoredCheck`.
4. `TemporalWitnessProbe` row D moved at **six** sites, not the predicted five.
5. The mechanism and carrier-list corrections above.
6. The plan's Phase 3 check `grep -n 'witness :: boxProps ++ diaProps' Tableau.lean` "returns
   exactly two lines" now returns **three**. Two are the code sites (lines 570, 596); the third
   (line 487) is a mention inside the `applyRule` docstring this task added, which quotes the new
   emitted shape verbatim. Same prose-vs-directive distinction as the 145 → 142 correction. The
   precise invariant is `grep -cE '^\s*\(\.linear \(witness :: boxProps \+\+ diaProps\), timeOrd\)'`
   **= 2**, which holds.

## Plan Deviations

- Phase 4's prose rewrite of `sat_box_grid_of_anchored`'s docstring in `BoxSaturation.lean` was
  performed during Phase 5 rather than Phase 4 *(deviation: altered — the stale sentence
  ("the invariant this consumes is one the engine's output actually satisfies") was only
  identified while re-deriving the carrier list in Phase 5; a scoped rebuild confirmed green
  before the Phase 5 commit)*.
- Phase 6's per-module builds were not run separately *(deviation: skipped — `lake build
  BimodalTest` surfaced every failing module independently and every mismatching row within each
  module, so the insurance the plan prescribed against masking was demonstrably unnecessary; the
  raw log shows no masking)*.
- Phase 6's anchor-row check at fuel 1000 was not completed *(deviation: deferred — the
  measurement did not terminate in over an hour; low-fuel data recorded instead, and the full
  measurement is carried into the continuation)*.

## Artifacts

| Path | Contents |
|---|---|
| `artifacts/build-environment.md` | lock protocol, environment snapshot, triage checklist |
| `artifacts/baseline-build.log`, `baseline-corpus.log` | BEFORE builds, both RC 0 |
| `artifacts/baseline-verdicts.md` | per-file counts, greenness, anchor baseline, the 145→142 correction |
| `artifacts/baseline-rows-raw.md` | all 142 rows with their expected values, verbatim |
| `artifacts/boxanchored-finding.md` | the measurement, mechanism, 14-carrier list, gate-family evidence, repair options |
| `artifacts/after-corpus-raw.log`, `after-corpus-bracket.txt` | AFTER build output and olean bracketing |
| `artifacts/after-verdicts.md` | per-row moved/unmoved record with bucket classification |
| `handoffs/phase-5-handoff-20260728.md`, `phase-6-handoff-20260728.md` | recovery points |

## Modified source files

- `FormalSystem/Metalogic/Decidability/Tableau.lean` — the fix
- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` — pruned six
  inert accessor names from two `simp only` lists; family docstring
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/BoxSaturation.lean` — three prose sites
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean` — the O3 status block
