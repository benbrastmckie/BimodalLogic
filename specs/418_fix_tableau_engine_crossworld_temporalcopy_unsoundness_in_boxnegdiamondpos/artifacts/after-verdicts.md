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

## The headline anchor row — `(G p) → □(G p)` — partially measured

The plan's headline acceptance criterion is that `buildTableau ((G p) → □(G p)) 1000 .Base` now
returns `.hasOpen`, and that `decide` on it returns `.invalid` with `getCountermodel?.isSome`.

**Measured so far** (scratch `#eval`, `lake env lean`, not committed):

| Fuel | Pre-fix | Post-fix |
|---|---|---|
| 1000 | `.allClosed` — the false claim of validity this task exists to remove (recorded in `reports/08_spawn-analysis.md`) | **not yet measured** — see below |
| 60 | not measured | `STALLED (none)` |
| 30 | not measured | `STALLED (none)` |

**What is established**: the engine no longer returns `.allClosed` at low fuel; the branch stays
open long enough to exhaust it. That is the fix working in the intended direction — the formula
is invalid, and a closed tableau on it was the defect.

**What is not yet established**: whether fuel 1000 now yields `.hasOpen` (the intended repair,
bucket (a)) or `none` / `.fuelExhausted` (a bucket-(e) resource outcome that would leave the
headline criterion unmet). A scratch probe running `buildTableau … 1000` and `decide` on this
formula ran for **over an hour without producing a result** and was stopped. That is itself the
measurement's most important interim datum, and it is why the plan's Phase 6 fuel-classification
step (`.hasOpen` vs fuel-exhausted vs `extractionFailed` kept separate rather than collapsed into
pass/fail) was the right instrument to specify.

The definitive value will come from `CrossWorldPropagationProbe.lean` **row B**, which is
`isValid ((G p) → □(G p))` — literally this formula — and which is one of the four modules still
building. Note that this row pins `isValid = false`, and `isValid` is `(decide φ).isValid`, which
is `true` only for `.valid`. Pre-fix the engine returned `.extractionFailed` here (closed tableau,
no proof term), so `isValid` read `false` on a formula the engine was wrongly closing. Post-fix
the row's *value* should survive at `false` whether the outcome is `.invalid` or `.fuelExhausted`
— which is exactly why the plan classed this file as "values predicted safe, narrative
superseded", and why the row cannot by itself discriminate (a) from (e). Reading the row is
necessary but not sufficient; the next dispatch should also run `decide` directly and record the
constructor.

## Modules still building

`TableauConformance` (27 rows) and `BoxNegReachabilityProbe` (12 rows) had not completed at the
time of writing. `BoxNegPreservationProbe` and `CrossWorldPropagationProbe`, initially recorded
here as incomplete, both finished — see their sections above.

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
