# AFTER Corpus Measurement — Every Moved Row

Task 418 — Phase 6 artifact. **Measurement only.** No test file was edited in the phase that
produced this document; Phase 7 adjudicates. Raw output: `after-corpus-raw.log`; olean bracketing
and exit code: `after-corpus-bracket.txt`.

## Bucket vocabulary (from the plan)

| Bucket | Meaning |
|---|---|
| (a) | **intended repair** — a previously-`allClosed`/`extractionFailed` verdict on an invalid formula is now `hasOpen`/`invalid` |
| (b) | **probe-pins-the-bug** — the row asserted the buggy behavior directly; its new value is the correct one |
| (c) | **suspected under-closing regression** — a valid formula that no longer closes |
| (d) | **saturation-metric change** — `\|T\|`, `anchor`, `check`, candidate-count vectors and similar structural measurements that moved because the fresh world now carries fewer formulas |
| (e) | **fuel/resource change** |

## Build accounting

An earlier attempt at this build was killed by a 10-minute foreground timeout and dropped the
olean count 405 → 398. **Per the Phase 1 triage checklist that run is INCONCLUSIVE and was
discarded, not recorded.** The measurement below comes from a re-run started from an olean
baseline of 398, run to completion in the background with no wall-clock ceiling.

The build's non-zero exit is entirely `#guard_msgs` mismatches — the **verdict** error class, not
the infrastructure class. Every error carries a `file:line:col` Lean diagnostic. There is no
`could not resolve import`, no missing `.olean`, and no diagnostic-free abrupt exit. The
measurement is therefore conclusive.

`lake` surfaced mismatches from **every** failing probe module independently rather than stopping
at the first, and within each module reported **every** mismatching row rather than only the
first. Per-module builds were therefore not needed to surface the full mismatch set — the plan
prescribed them as insurance against masking, and the raw log shows no masking occurred.

## Moved rows — 17 confirmed across 5 probe modules

All seventeen are quoted verbatim from Lean's `- info:` (old) / `+ info:` (new) diff pairs in
`after-corpus-raw.log`.

### `RayRegionProbe.lean` — 1 of 7 rows moved

| # | Row | Formula | Old | New | Bucket |
|---|---|---|---|---|---|
| 1 | D (`:139`) | `(□p ∧ ◇q) → r` | `"OPEN \|W\|=2 \|T\|=7 check=true rayUp=true rayDn=true rays=[(2, 2), (5, 5)]"` | `"OPEN \|W\|=2 \|T\|=7 check=false rayUp=false rayDn=false rays=[(2, 2), (0, 0)]"` | **(d)** |

Rows A, B, C, E and the two `#eval`-only rows are unmoved. **Confirms** the plan's prediction
exactly: "row D … rows A-C, E-G predicted safe."

World 0's ray is unchanged at `(2, 2)`; world 1 — the minted one — drops from `(5, 5)` to
`(0, 0)`, i.e. loses its witnessing label. Verdict is still `OPEN` with the same `|W|`/`|T|`.

### `BoxSpreadProbe.lean` — 3 of 5 rows moved

| # | Row | Formula / class | Old | New | Bucket |
|---|---|---|---|---|---|
| 2 | A (`:75`) | `(□p ∧ ◇q) → r`, `.Base` | `"OPEN spread=false anchor=true grid=true \|W\|=2 \|T\|=7"` | `"OPEN spread=false anchor=false grid=false \|W\|=2 \|T\|=7"` | **(d)** |
| 3 | B (`:80`) | `(□p ∧ ◇(G q)) → r`, `.Base` | `"OPEN spread=false anchor=true grid=true \|W\|=2 \|T\|=7"` | `"OPEN spread=false anchor=false grid=false \|W\|=2 \|T\|=7"` | **(d)** |
| 4 | C (`:85`) | `(□p ∧ ◇q) → r`, `.Dense` | `"OPEN spread=false anchor=true grid=true \|W\|=2 \|T\|=10"` | `"OPEN spread=false anchor=false grid=false \|W\|=2 \|T\|=8"` | **(d)** |

Rows D and E (`gapProbe`, single-world) unmoved — **confirms** the plan's prediction.

This is the `boxAnchoredCheck` finding seen from the test side; cross-reference
`boxanchored-finding.md` §1.2. **Beyond the plan's prediction**: `grid` moved too, and row C's
`|T|` moved 10 → 8.

### `RegionGateProbe.lean` — 4 of 10 rows moved

| # | Row | Old | New | Bucket |
|---|---|---|---|---|
| 5 | A (`:216`) | `"OPEN \|W\|=2 \|T\|=7 total=true gate=true check=true cands=[[3,3,3,3,3,3,3,3], [3,3,3,3,3,3,3,3]]"` | `"… total=true gate=false check=false cands=[[3,3,3,3,3,3,3,3], [0,0,0,0,0,0,0,0]]"` | **(d)** |
| 6 | B (`:222`) | `"OPEN \|W\|=2 \|T\|=7 total=true gate=true check=true cands=[[3×8], [3,3,3,3,1,1,1,1]]"` | `"… total=true gate=false check=false cands=[[3×8], [0×8]]"` | **(d)** |
| 7 | C (`:227`) | `"OPEN \|W\|=2 \|T\|=10 total=true gate=true check=true cands=[[3×11], [3×11]]"` | `"OPEN \|W\|=2 \|T\|=8 total=true gate=true check=true cands=[[3×9], [1×9]]"` | **(d)** |
| 8 | H (`:255`) | `"OPEN \|W\|=2 \|T\|=10 total=true gate=true check=true cands=[[3×11], [3,3,3,3,1,1,1,1,1,1,1]]"` | `"… total=true gate=false check=false cands=[[3×11], [0×11]]"` | **(d)** |

Rows D-G and I unmoved — **confirms** the plan's prediction ("rows A, B, C, H … rows D-G, I
predicted safe") on all ten rows.

`timeOrderTotal` (`total`) stays `true` throughout: the deletion did not disturb the time order,
only the minted world's formula content. Row C is notable — it keeps `gate=true check=true`
while its `|T|` shrinks 10 → 8 and world 1's candidate count falls 3 → 1; it is the one moved
`RegionGateProbe` row that does **not** lose its gate.

### `TemporalWitnessProbe.lean` — 6 of 71 rows moved, all the same formula

Every one is **row D**, `(□p ∧ ◇q) → r` — the only multi-world formula among the C/D/E triples
that each of the six probe helpers (`probe`, `probe2` … `probe6`) runs.

| # | Line | Helper | Change | Bucket |
|---|---|---|---|---|
| 9 | `:408` | `probe` | `check=true → false`; `U[… rP=true → rP=false …]`, `S[… rP=true → rP=false …]` | **(d)** |
| 10 | `:521` | `probe2` | `D check=true → check=false` (`uNAR`/`sNAR` unchanged, both `true`) | **(d)** |
| 11 | `:629` | `probe3` | `D gen=false check=true → check=false` (`uRL`/`uRLs`/`sRU`/`sRUs` unchanged) | **(d)** |
| 12 | `:775` | `probe4` | `D gen=false check=true → check=false` (all `uGW`/`sGW`/`uRD`/`sRU` blocks unchanged) | **(d)** |
| 13 | `:927` | `probe5` | `D gen=false check=true → check=false` (`uNRU`/`sNRD` blocks unchanged) | **(d)** |
| 14 | `:1085` | `probe6` | `D gen=false check=true → check=false`; `uPR=true → false [self=true → false]`, `sPR` likewise | **(d)** |

The plan predicted row D "recurring at `:407`, `:520-522`, `:628-630`, `:774-776` and near
`:914`" — five sites. **Measured: six**, the sixth at `:1085` (`probe6`). The plan's "near `:914`"
resolves to `:927`. All 65 other rows in this file are unmoved.

### `BoxNegPreservationProbe.lean` — 3 of 5 rows moved — **bucket (b), and the headline result**

This file was written to pin the defect directly, at the `applyRule` level rather than the verdict
level. Its rows moving is the task's central evidence.

| # | Row | What it evaluates | Old | New | Bucket |
|---|---|---|---|---|---|
| 15 | 1 (`:103`) | `emitted.length` | `2` | **`1`** | **(b)** |
| 16 | 3 (`:116`) | `emitted` contains the same formula at the same label with **opposite signs** | `true` | **`false`** | **(b)** |
| 17 | 4 (`:122`) | `emitted` contains a `T(G p)` that was standing at another world | `true` | **`false`** | **(b)** |

Rows 2 (`:107`, both emitted formulas sit at the minted world) and 5 (`:130`, `isValid = false`)
are **unmoved** — exactly as the plan predicted, row for row, on all five.

**Row 3 is the soundness defect itself, measured as repaired.** Its docstring reads: *"This is the
measurement. A branch containing both is unsatisfiable outright, so the successor of a satisfiable
branch is unsatisfiable and `RuleSound carrierBase .boxNeg` is false."* That row now evaluates
`false`: applying `.boxNeg` to this branch no longer manufactures a contradictory pair. This is
the most direct available confirmation that the task achieved its stated goal, and it is
independent of any fuel budget or search-depth question.

Row 1 (`2 → 1`) and row 4 (`true → false`) are the mechanism: the rule used to emit the witness
`F(G p)` **plus** the copied `T(G p)`; it now emits the witness alone.

### `CrossWorldPropagationProbe.lean` — 0 of 5 rows moved — **built green**

`✔ [2028/2031] Built BimodalTest.CrossWorldPropagationProbe (1363s)`. All five rows pass
unchanged, **confirming the plan's prediction exactly** ("all five rows predicted safe in value —
they pin `isValid` only — but superseded in narrative").

This includes **row B**, which is `isValid ((G p) → □(G p))` — the headline formula — still
pinning `false`. As noted below, `isValid` is `true` only for `.valid`, so this row reads `false`
under both `.invalid` and `.fuelExhausted` and does not by itself discriminate the two. What it
does establish is that the engine does **not** now report this invalid formula as valid.

The file's narrative is nonetheless superseded: its title is *"Does the fresh-world temporal copy
make the engine decide wrongly? Measured, and it does not"*, and its thesis is that the copy is
suspect but harmless at the verdict level. The copy is now gone, so the whole framing is
historical. Phase 7 must rewrite it even though no value moved.

## The headline anchor row — MEASURED. The plan's acceptance criterion is NOT met.

Measured with a targeted scratch `#eval` (`lake env lean`, not committed), run without competing
load:

```
"decide: valid=false invalid=false fuelExhausted=true extractionFailed=false countermodel?=false"
"buildTableau 1000 = STALLED (none)"
```

| Criterion (plan, Phase 6 and Testing & Validation) | Required | **Measured** | Met? |
|---|---|---|---|
| `buildTableau ((G p) → □(G p)) 1000 .Base` | `.hasOpen` | **`none`** (fuel exhausted) | **NO** |
| `decide` constructor | `.invalid` | **`.fuelExhausted`** | **NO** |
| `getCountermodel?.isSome` | `true` | **`false`** | **NO** |

### What actually happened, stated exactly

| | Pre-fix | Post-fix |
|---|---|---|
| `buildTableau … 1000` | `.allClosed` | `none` |
| `decide` | `.extractionFailed` | `.fuelExhausted` |
| What the procedure claims | **"φ is valid"** — false; φ is invalid | **"undetermined"** |

**The soundness defect is gone.** Pre-fix the engine closed every branch on an invalid formula
and `decide` returned `.extractionFailed`, which by this codebase's own R7 semantics
(`DecisionProcedure.lean`: `isKnownValid` is true for `extractionFailed`; `isUndecided` is true
only for `fuelExhausted`) is an assertion that **the formula is valid**. That assertion was
false. Post-fix the engine returns `.fuelExhausted`, which `isUndecided` recognises as honest
ignorance. The move is from *a wrong answer* to *no answer*.

**But the intended repair did not land.** The plan wanted `.hasOpen` with an extracted
countermodel — the engine positively refuting the formula. It does not get there within fuel
1000; the branch stays open long enough to exhaust the budget without saturating. This is
**bucket (e)**, and it is the same phenomenon as the ~1100× slowdown recorded above: removing
emitted formulas shrinks the contradiction surface, so searches that used to terminate by closing
now run to the fuel ceiling.

### Triage — this is not a revert trigger

Per the plan's Rollback/Contingency section, a bucket-(e) resource outcome is recorded and
triaged, never repaired by reinstating a deleted block. Reverting would trade honest ignorance
for a false claim of validity, which is strictly worse. Options for the next dispatch, none
performed here:

1. **Raise the fuel** and re-measure. Cheapest first step; establishes whether `.hasOpen` is
   reachable at all or whether the branch never saturates. Note fuel 30, 60 and 1000 all give
   `none`, so the ceiling has not yet been bracketed from above.
2. **Investigate why the branch does not saturate.** If some rule now fires unboundedly on this
   shape, that is a termination question rather than a fuel-budget question, and it belongs with
   `Verified/Termination/Fuel.lean`'s bounds.
3. **Accept `.fuelExhausted` as the correct current verdict** for this formula and record the
   countermodel as owed. Defensible — the procedure is sound and honest — but it leaves the
   task's stated headline goal unmet, so it needs an explicit decision rather than a default.

**Note for whoever picks this up**: `CrossWorldPropagationProbe` row B, which is
`isValid ((G p) → □(G p))`, passes green and pins `false`. It cannot detect this outcome —
`isValid` is `true` only for `.valid`, so it reads `false` under `.invalid` and `.fuelExhausted`
alike. The corpus does **not** currently pin the distinction that matters here. Adding a row that
pins the `decide` *constructor* on this formula would be a genuine improvement to the corpus, and
is the sort of addition Phase 7 could justify.

## Fuel sweep on the anchor row, and two process notes

The fuel sweep, kept because it brackets the behaviour and the section above reports only 1000:

| Fuel | Pre-fix | Post-fix |
|---|---|---|
| 30 | not measured | `STALLED (none)` |
| 60 | not measured | `STALLED (none)` |
| 400 | not measured | `decide = .fuelExhausted`, `isUndecided = true`, `getCountermodel?.isSome = false`, **returns in ~0 ms** |
| 1000 | `.allClosed` (recorded in `reports/08_spawn-analysis.md`) | `STALLED (none)`, `decide = .fuelExhausted` |

Every measured fuel gives fuel exhaustion. The ceiling above which `.hasOpen` might appear is
**not bracketed**, and nothing here shows the branch ever saturates.

The fuel-400 row comes from `artifacts/rescued/anchor418c.out`, produced by a separate dispatch of
this session and committed under `artifacts/rescued/` with its own `PROVENANCE.md`. It is an
**independent corroboration** of the fuel-1000 finding above, taken with different code, and it
adds something the fuel-1000 measurement lacked: it **returns essentially instantly**. That rules
out "the measurement is just slow" and confirms the engine is genuinely reporting fuel exhaustion
rather than grinding. `isUndecided = true` is recorded explicitly there, which is the R7 predicate
that distinguishes honest ignorance from the pre-fix false claim of validity.

**One rescued file is deliberately NOT used here.** `artifacts/rescued/reach418.out` is a scratch
re-encoding of `BoxNegReachabilityProbe`-style queries (8 rows), not a build of the real
`Tests/BimodalTest/BoxNegReachabilityProbe.lean` (12 `#guard_msgs` rows). Its own `PROVENANCE.md`
flags it as "a lead to confirm, not the AFTER measurement", and that caveat is honored:
`BoxNegReachabilityProbe` is counted as **unmeasured** throughout this document. Its
`row6 (clash at fresh world) = false` is nonetheless consistent with `BoxNegPreservationProbe`
row 3 moving `true → false`.

Two mistakes made while taking this measurement, recorded so they are not repeated:

1. **A combined probe is unrecoverable.** The first attempt put rows A/B/C, the mechanism check,
   `buildTableau … 1000` and `decide` in one file. `#eval` output is buffered until the whole file
   elaborates, so after ~20 minutes the run was stopped with **nothing** recoverable. Split cheap
   and expensive measurements into separate files.
2. **"Over an hour without returning" was partly CPU contention, not the formula.** That probe ran
   alongside a full corpus build. Run alone and with the expensive rows split out, `decide` on this
   formula returns in minutes. The earlier reading in this document overstated the cost; the real
   cost is the ~1100x figure in the resource section, which is measured from lake's own timings.

A third note, on instrumentation rather than process: `CrossWorldPropagationProbe` row B was
expected to settle this question and **cannot**. It pins `isValid`, which is `true` only for
`.valid`, so it reads `false` under `.invalid` and `.fuelExhausted` alike. Only a direct
measurement of the `decide` constructor distinguishes the intended repair from fuel exhaustion.

## Modules still building at dispatch end — 2 of 8, 39 rows

`TableauConformance` (27 rows) and `BoxNegReachabilityProbe` (12 rows) had not completed when this
dispatch ended, after the build had run for several hours. `BoxNegPreservationProbe` and
`CrossWorldPropagationProbe`, recorded earlier in this document as incomplete, both finished — see
their sections above.

**The build was left running and `after-corpus-raw.log` is appended in place.** The next dispatch
should read it before re-running: it may already contain the missing 39 rows' verdicts. Verify
first that the process actually completed (a trailing `Build completed` / `error: Lean exited`
line for each of the two modules, and a `[2031/2031]` entry) rather than assuming the log is final
— a truncated log from a killed process is an INCONCLUSIVE run under the Phase 1 triage checklist,
not a measurement.

These two are expected to carry the remaining bucket-(a) and bucket-(b) rows, and they are the
only remaining source of a possible bucket-(c) under-closing regression. **None of the 17 rows
measured so far is bucket (c), but that conclusion is provisional until these 39 rows are read.**
`TableauConformance` in particular pins CLOSED/OPEN/STALLED verdicts directly across four frame
classes, so it is the one file where a genuine verdict regression would show.

## Resource finding (bucket (e)) — the corpus got materially slower, quantified

Lake's own per-module timings, post-fix, against the one baseline figure available:

| Module | Baseline | Post-fix | Factor |
|---|---|---|---|
| `CrossWorldPropagationProbe` | **1.2 s** | **1363 s** (~23 min) | **~1100×** |
| `BoxNegPreservationProbe` | not separately timed (cached) | **1048 s** (~17 min) | — |
| `RayRegionProbe` | not separately timed | 3.3 s | — |
| `BoxSpreadProbe` | not separately timed | 7.8 s | — |
| `RegionGateProbe` | not separately timed | 12 s | — |
| `TemporalWitnessProbe` | not separately timed | 21 s | — |

The two slow modules are precisely the two whose rows run `isValid`/`decide` on formulas that
**used to close and now do not**: `CrossWorldPropagationProbe` rows A/B/C and
`BoxNegPreservationProbe` row 5. The four fast modules run `buildTableau` at explicit low fuel
(200) and are barely affected.

This is the plan's risk-asymmetry argument showing up as wall-clock: removing emitted formulas
shrinks a branch's contradiction surface, so branches that used to close now stay open and
`decide` runs the whole fuel budget plus proof search plus countermodel extraction instead of
terminating early on a closed tableau. It is a **cost**, not a failure, and it is the expected
direction.

**Correction to an earlier reading in this document**: `CrossWorldPropagationProbe` was initially
recorded as "running tens of minutes without completing". It did complete, in 1363 s, and it
built **green**. The slowdown is real and large but it is not a hang.

Practical consequence: a full `lake build BimodalTest` must be run in the background with no
wall-clock ceiling and budgeted in tens of minutes at minimum. It must never be run in a
foreground window that can time out — doing so once already destroyed a run and dropped the olean
count 405 → 398.

## Rows that did not move

| Probe file | Rows | Moved | Unmoved |
|---|---|---|---|
| `TemporalWitnessProbe.lean` | 71 | 6 | 65 |
| `RegionGateProbe.lean` | 10 | 4 | 6 |
| `RayRegionProbe.lean` | 7 | 1 | 6 |
| `BoxSpreadProbe.lean` | 5 | 3 | 2 |
| `BoxNegPreservationProbe.lean` | 5 | 3 | 2 |
| `CrossWorldPropagationProbe.lean` | 5 | **0 (built green)** | 5 |
| `TableauConformance.lean` | 27 | not yet measured | — |
| `BoxNegReachabilityProbe.lean` | 12 | not yet measured | — |
| **Total** | **142** | **17 so far** | **86 so far** |

## Bucket summary so far

| Bucket | Count | Note |
|---|---|---|
| (a) intended repair | 0 so far | `CrossWorldPropagationProbe` built green, so no verdict moved there; `TableauConformance` not yet measured |
| (b) probe-pins-the-bug | **3** | `BoxNegPreservationProbe` rows 1, 3, 4 — including row 3, the unsoundness itself, measured as repaired |
| (c) suspected under-closing regression | **0** | none among the 17 measured |
| (d) saturation-metric change | **14** | the `RayRegion`/`BoxSpread`/`RegionGate`/`TemporalWitness` set |
| (e) fuel/resource change | see above | corpus-wide slowdown, not a per-row verdict |

**No bucket-(c) row has been found** among the 17 measured. Fourteen are decidable branch-gates or
structural metrics on a multi-world branch, every one of which was previously computing `true`
*because of* the unsound copies. Three are `BoxNegPreservationProbe` rows that pinned the defect
directly and now pin its absence. **No verdict** (`CLOSED`/`OPEN`/`STALLED`, `isValid`) has moved
in the measured set at all.

## Anticipation accounting

Of the plan's Phase 6 predictions, on the four modules measured:

- `RayRegionProbe` row D moved, A-C/E safe — **confirmed exactly**.
- `BoxSpreadProbe` A/B/C moved, D/E safe — **confirmed**, with two unpredicted extras (`grid`
  also false; row C `|T|` 10 → 8).
- `RegionGateProbe` A/B/C/H moved, D-G/I safe — **confirmed exactly** on all ten rows.
- `TemporalWitnessProbe` row D — **confirmed**, but at **six** sites rather than the predicted
  five.

No row moved that the plan did not anticipate as a *file*. The only unanticipated movements are
within-row (extra fields moving) and the sixth `TemporalWitnessProbe` site.
