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

---

# Phase 7 — Adjudication and Corpus Realignment

Every expectation changed below is listed with the bucket it falls in and the reason its **new**
value is the semantically correct one. No `#guard_msgs` block was deleted, commented out, or
weakened; no `#eval` expression was altered. The mechanical guarantee is
`git diff Tests/ | grep -E '^[+-]#eval'`, which yields exactly one line — the single **added**
row F in `CrossWorldPropagationProbe` — and no removed line at all.

## Corpus directive count — the plan's 145 is wrong; the true figure is 142

`grep -c '#guard_msgs'` counts three prose mentions of the string inside module docstrings
(`TableauConformance.lean:57,62` and `RayRegionProbe.lean:52`). The invariant Phase 7 must hold
is over **directives**, `grep -c '^#guard_msgs in'`:

| File | Directives |
|---|---|
| `TemporalWitnessProbe.lean` | 71 |
| `TableauConformance.lean` | 27 |
| `BoxNegReachabilityProbe.lean` | 12 |
| `RegionGateProbe.lean` | 10 |
| `RayRegionProbe.lean` | 7 |
| `CrossWorldPropagationProbe.lean` | 5 → **6** (one justified addition, below) |
| `BoxSpreadProbe.lean` | 5 |
| `BoxNegPreservationProbe.lean` | 5 |
| **Total** | **142 → 143** |

The only movement is upward, by addition. The anti-weakening invariant — that no count *falls* —
holds on every file.

## Bucket (b) — `BoxNegPreservationProbe.lean`, the rows that pinned the defect

These three rows were written to refute `RuleSound carrierBase .boxNeg`. They succeeded; the
defect was then removed; they now pin its absence. The new value is correct because the rule is
correct.

| Row | Assertion | Old | New | Why the new value is right |
|---|---|---|---|---|
| 1 (`:103`) | `emitted.length` | `2` | `1` | `.boxNeg` is entitled to emit the existential witness `F(G p)` and whatever `boxProps`/`diaProps` supply. On `b0` the latter two are empty, so exactly one formula is correct. The second emission was the `tempGProps` copy. |
| 3 (`:116`) | same formula, same label, opposite signs | `true` | `false` | **This is the soundness defect itself.** A branch carrying both is unsatisfiable outright, so the rule mapped a satisfiable branch to an unsatisfiable one. `false` says it no longer does. |
| 4 (`:122`) | a `T(G p)` from another world is present | `true` | `false` | The mechanism behind row 3. `tempGProps` was the only route by which a `T(G·)` at another world could reach the minted world; with it deleted there is none. |

Rows 2 and 5 unmoved. Row 5's *meaning* changed and its docstring was rewritten accordingly: its
`false` was `extractionFailed` after a wrongly-closed tableau and is now `fuelExhausted`.

The module docstring was rewritten from present to past tense throughout, with a new "The repair"
section naming the deleted blocks and a "What this file does *not* establish" section recording
that the countermodel is still owed.

## Bucket (d) — the saturation-metric set, all four files

Every row here is a decidable structural gate or count on a **two-world** branch. Each was
computing `true` *because of* the unsound copies: the minted world used to receive
`T(G·)`/`T(H·)` verbatim from another world, which is what gave it an eligible region label. With
the copies gone it has none, so the gates go false. The new value is correct because it reports
the branch the engine actually builds. No verdict (`CLOSED`/`OPEN`/`STALLED`) moved anywhere in
this set, and every single-world row in all four files is unmoved.

Cross-reference for all of them: `boxanchored-finding.md` — this is the `boxAnchoredCheck`
consequence observed from the test side.

| File | Row | Field(s) moved | Old → New |
|---|---|---|---|
| `RayRegionProbe` | D (`:139`) | `check`, `rayUp`, `rayDn`, world 1's ray | `true/true/true, (5, 5)` → `false/false/false, (0, 0)` |
| `BoxSpreadProbe` | A (`:75`) | `anchor`, `grid` | `true/true` → `false/false` |
| `BoxSpreadProbe` | B (`:80`) | `anchor`, `grid` | `true/true` → `false/false` |
| `BoxSpreadProbe` | C (`:85`) | `anchor`, `grid`, `\|T\|` | `true/true/10` → `false/false/8` |
| `RegionGateProbe` | A (`:216`) | `gate`, `check`, world 1's vector | `true/true/[3×8]` → `false/false/[0×8]` |
| `RegionGateProbe` | B (`:222`) | `gate`, `check`, world 1's vector | `true/true/[3,3,3,3,1,1,1,1]` → `false/false/[0×8]` |
| `RegionGateProbe` | C (`:227`) | `\|T\|`, world 1's vector | `10/[3×11]` → `8/[1×9]` (**keeps** `gate=true check=true`) |
| `RegionGateProbe` | H (`:255`) | `gate`, `check`, world 1's vector | `true/true/[3,3,3,3,1×7]` → `false/false/[0×11]` |
| `TemporalWitnessProbe` | D ×6 (`:408`, `:521`, `:629`, `:775`, `:927`, `:1085`) | `check`; also `rP`/`self` at `:408` and `:1085` | `true` → `false` |

Two rows deserve individual notes rather than the blanket justification:

* **`RegionGateProbe` row C is the one moved two-world row that keeps its gate.** Under `.Dense`
  the minted world's per-region count falls `3 → 1` rather than to `0`, so an eligible label
  survives everywhere and `gate`/`check` stay `true`. Its `|T|` shrinks `10 → 8` because two of
  the times the removed copies used to force into existence are no longer minted. This row is
  positive evidence that the collapse elsewhere is a real structural consequence and not the
  gate simply having been switched off.
* **`RegionGateProbe` row B collapses onto row A.** Its `T(G q)` reached the minted world *only*
  via the deleted copy, so the "single eligible label from rank 4 up" it used to report — the
  `G q` biting — is gone entirely.

`timeOrderTotal` (`total`) stays `true` on every `RegionGateProbe` row, and `|W|` is unmoved
everywhere: the deletion disturbed the minted world's formula content and nothing about the time
order or the world set.

`TemporalWitnessProbe`'s stated file-level invariant — "every row with `check=true` reports
`true` on all ten candidate rows, and every `false` sits on a row where `regionLabelCheck` is
already `false`" — **survives** the movement and is in fact what the movement respects: row D's
`rP` went false exactly alongside its `check`.

### A near-miss worth recording

`TemporalWitnessProbe.lean:397` (row B, `P p → p`, single-world) carries a docstring **byte-identical**
to row D's at `:407`, by coincidence of output. Row B did not move. A naive whole-file
find-and-replace on the old expected string would have silently corrupted an unmoved
single-world row; the edit was applied positionally to line 407 instead, and the count assertion
that caught it is the reason it was noticed.

## Bucket (c) — suspected under-closing regression

**None.** No row in the measured set is a valid formula that stopped closing. Every moved row is
either a probe that pinned the defect directly (bucket b) or a structural gate on a multi-world
branch (bucket d).

## The one justified addition — `CrossWorldPropagationProbe.lean` row F

**The problem.** All five existing rows call `isValid`, and `isValid` is `(decide φ).isValid`,
`true` only for the `.valid` constructor. Every one of them therefore reads `false` under
`.invalid`, `.fuelExhausted` and `.extractionFailed` alike. Row B is
`isValid ((G p) → □(G p))` — the anchor formula — and it passed green across the deletion
**without moving**, because its `false` meant `extractionFailed` before and `fuelExhausted` now.
The corpus as it stood could not detect the outcome that matters most to this task.

**The addition.** Row F pins the `decide` constructor directly on that formula, as the tuple
`(isValid, isInvalid, isFuelExhausted, isExtractionFailed, isUndecided)`, matching
`BoxNegReachabilityProbe.lean` row 10's shape:

* before the deletion: `(false, false, false, true, false)` — `extractionFailed`, which by this
  codebase's R7 semantics (`isKnownValid` is true for `extractionFailed`) is an assertion that
  the formula is **valid**. It is not.
* now: `(false, false, true, false, true)` — `fuelExhausted`, which `isUndecided` recognises as
  honest ignorance.

This is an addition, not a weakening: it strictly increases what the corpus can detect, and it
pins the task's *unmet* criterion rather than hiding it. A future change that moves this formula
to `.invalid`-with-countermodel — the outcome still owed — will now fail this row loudly instead
of passing unnoticed.

## Prose rewritten (a corrected number under contradicting prose is not an acceptable end state)

| File | What was false after the fix | What it says now |
|---|---|---|
| `BoxNegPreservationProbe.lean` | Whole docstring in present tense: the copy fires, the successor is unsatisfiable, `RuleSound` "is false" | Past tense throughout; new "The repair" section naming the six deleted blocks; new section recording that the countermodel is still owed |
| `CrossWorldPropagationProbe.lean` | Title "Measured, and it does not"; thesis that the copy is suspect but harmless at the verdict level | Retitled; new section explaining that the original conclusion did not follow from the measurement, and why row F was needed |
| `BoxSpreadProbe.lean` | "the anchor and the grid are both **true** on those same branches" — the file's entire thesis | New "What these rows used to say, and what they say now" section; the rows now measure the *cost* of the repair, with the carrier consequence stated |
| `RegionGateProbe.lean` | Rows header asserting every region of every world has an eligible label | Header records that the two-world rows moved and why; the single-world rows are called out as unmoved |
| `RayRegionProbe.lean` | Row D comment describing the per-world ray choice as working | Row D comment records the `(5, 5)` → `(0, 0)` collapse and its cause |
| `TemporalWitnessProbe.lean` | (rows header invariant survived) | New "Row D moved, in all six probe helpers" section |

No surviving docstring in the corpus asserts in the present tense that the cross-world temporal
copy fires.

## What was NOT done, deliberately

* No deleted block was reintroduced, in narrowed form or otherwise.
  `FormalSystem/Metalogic/Decidability/Tableau.lean` is byte-identical to its Phase 3 state.
* No assertion was weakened to make a row pass.
* No fuel level was lowered in any probe row.
* `Verified/Decidable.lean` was not touched; the `RuleSound` proof was not attempted.

---

# Phase 6 COMPLETION — the last two modules, measured

Build: `lake build BimodalTest.TableauConformance BimodalTest.BoxNegReachabilityProbe`,
detached (`setsid nohup`), no wall-clock ceiling. Raw log `after-corpus-2mod.log`, bracket
`phase6b-bracket.txt`.

**Conclusiveness triage** (Phase 1 checklist, applied one final time):

| Check | Result |
|---|---|
| olean count before / after | **399 / 399** — no drop |
| infrastructure-class errors (`could not resolve import`, missing `.olean`, diagnostic-free exit) | **none** |
| error class | every error is a `#guard_msgs` mismatch with a `file:line:col` diagnostic — **verdict class** |

The measurement is therefore **conclusive**, not inconclusive.

## `TableauConformance.lean` — 0 of 27 rows moved

This module was **not rebuilt** by the run: lake found its trace current and skipped it. Its
`.olean` is dated 23:22, later than the fixed engine's `Tableau.olean` at 22:43 (source edited
22:41), so it was compiled **against the repaired engine**, and since a `#guard_msgs` mismatch is
a hard error that prevents `.olean` emission, its existence is positive evidence that all 27 rows
passed post-fix.

This is also what the content predicts. Twenty-five of the 27 rows are purely temporal — the
`C`/`S`/`K`/`A`/`B`/`BX`/`Z`/`R` conformance tables across four frame classes, the `futureOf`
/`ancestorTimes` closure probes, the blocking-predicate rows, and the `W1`-`W7` order probes —
and contain no `□`/`◇` at all, so `boxNeg`/`diamondPos` never fire on them. The one modal row,
`certProbe diaP` (`◇p`, `formulas=51`), does fire `diamondPos`, and it did not move.

**Consequence for the bucket-(c) question**: `TableauConformance` is the only module pinning
`CLOSED`/`OPEN`/`STALLED` verdicts directly, across `.Base`/`.Dense`/`.Discrete`/`.Dedekind`, and
it is therefore exactly where an under-closing regression on a *valid* formula would surface.
It is unmoved. The "zero bucket-(c)" finding is now a statement about the whole corpus, not a
provisional one about the rows read so far.

## `BoxNegReachabilityProbe.lean` — 5 of 12 rows moved, in **3437 s**

| # | Row | What it evaluates | Old | New | Bucket |
|---|---|---|---|---|---|
| 18 | 6 (`:152`) | clash at the minted world | `true` | **`false`** | **(b)** |
| 19 | 7 (`:157`) | `(reached.length, #open)` | `(1, 0)` | **`(1, 1)`** | **(b)** |
| 20 | 8 (`:165`) | closure reason of the head branch | `some (1, 1, 0)` | **`none`** | **(b)** |
| 21 | 9 (`:183`) | `buildTableau ((G p) → □(G p)) 1000 .Base` | `(1, 1)` = `.allClosed` | **`(0, 0)`** = fuel-exhausted | **(a)-direction, lands (e)** |
| 22 | 10 (`:195`) | `decide` constructor 5-tuple | `(false, false, false, true, false)` | **`(false, false, true, false, true)`** | **(a)-direction, lands (e)** |

Rows 1-5 and 11-12 unmoved. **Row 5 in particular still reads `true`**: `boxNeg` still fires on
this branch and still mints world 1 carrying the witness `F(G p)`. The repair did not make the
branch unreachable and was never meant to — group 1 (the existential witness) is sound and was
left byte-identical. Only the copy that used to arrive beside the witness is gone.

### Rows 6-8 are the repair, measured from the reachability side

Row 7 is the single most direct statement of it anywhere in the corpus: **the one branch the
engine reaches went from closed to open.** The engine was closing a branch it had no grounds to
close, and it no longer does. Row 8 confirms nothing else closes it either — the closure reason
is `none`, not a different reason — which rules out the reading that some other rule silently
took over the closure.

### Rows 9-10 are the anchor row, and they confirm the criterion is unmet

Row 9's `(1, 1) → (0, 0)` and row 10's `extractionFailed → fuelExhausted` are the same event
seen twice. Pre-fix, `buildTableau` closed the tableau on an **invalid** formula and `decide`
reported `extractionFailed`, which by R7 semantics (`isKnownValid` is true for
`extractionFailed`) **asserts the formula is valid**. Post-fix, `fuelExhausted`, which
`isUndecided` recognises as honest ignorance.

The plan required `.hasOpen` (`(2, _)`) and `.invalid` with a countermodel. Neither holds.
**Rows 11 and 12 are unmoved precisely because the countermodel is still owed.** This is recorded
as bucket (e) and triaged — see "The headline anchor row" above — and is explicitly not repaired
here.

### Independent corroboration of rows 1-8

`artifacts/rescued/reach418.out`, a scratch re-encoding recovered from a stopped dispatch and
labelled UNVERIFIED, reported rows 1-5 `true`, row 6 `false`, row 7 `(1, 1)`, row 8 `none`. The
module build agrees with it on all eight. The scratch is thereby retired from "lead to confirm"
to "confirmed", and the module build — not the scratch — is what is recorded here.

### The 3437 s cost is the bucket-(e) finding, quantified

Rows 9-12 are four independent fuel-1000 searches on `(G p) → □(G p)` (`decide`'s default
`tableauFuel` is also 1000). Pre-fix each terminated early by closing the tableau; post-fix each
runs the budget to exhaustion. 3437 s / 4 ≈ 860 s per search, consistent with
`BoxNegPreservationProbe`'s 1048 s for one and `CrossWorldPropagationProbe`'s 1363 s for three.
The slowdown is a cost of the repair with the expected direction and magnitude, not a hang.

## Final corpus accounting

| Probe file | Rows | Moved | Unmoved |
|---|---|---|---|
| `TemporalWitnessProbe.lean` | 71 | 6 | 65 |
| `TableauConformance.lean` | 27 | **0** | 27 |
| `BoxNegReachabilityProbe.lean` | 12 | **5** | 7 |
| `RegionGateProbe.lean` | 10 | 4 | 6 |
| `RayRegionProbe.lean` | 7 | 1 | 6 |
| `CrossWorldPropagationProbe.lean` | 5 | 0 | 5 |
| `BoxSpreadProbe.lean` | 5 | 3 | 2 |
| `BoxNegPreservationProbe.lean` | 5 | 3 | 2 |
| **Total** | **142** | **22** | **120** |

| Bucket | Count | Rows |
|---|---|---|
| (a) intended repair, fully landed | **0** | — |
| (b) probe-pins-the-bug | **6** | `BoxNegPreservationProbe` 1/3/4, `BoxNegReachabilityProbe` 6/7/8 |
| (c) under-closing regression | **0** | none, corpus-wide |
| (d) saturation-metric change | **14** | the `RayRegion`/`BoxSpread`/`RegionGate`/`TemporalWitness` set |
| (e) fuel/resource change | **2** | `BoxNegReachabilityProbe` 9/10 — the anchor row |

**Every one of the 22 moved rows is accounted for, and none is a regression.** The six bucket-(b)
rows pinned the defect and now pin its absence. The fourteen bucket-(d) rows were computing
`true` because of the unsound copies. The two bucket-(e) rows are the anchor row, where a wrong
answer became no answer — an improvement that falls short of the plan's stated goal.
