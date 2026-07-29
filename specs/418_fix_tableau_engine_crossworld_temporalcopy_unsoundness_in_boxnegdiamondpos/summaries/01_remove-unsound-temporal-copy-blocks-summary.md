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

## Before/after verdict-change table

Fourteen rows measured as moved, across four of the eight probe files. Every value is quoted
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

**Rows that did not change, in aggregate**: 79 of the 93 rows in the four measured files
(`TemporalWitnessProbe` 65/71, `RegionGateProbe` 6/10, `RayRegionProbe` 6/7, `BoxSpreadProbe` 2/5).
The remaining 49 rows across `TableauConformance` (27), `BoxNegReachabilityProbe` (12),
`CrossWorldPropagationProbe` (5) and `BoxNegPreservationProbe` (5) are **not yet measured**.

**Every one of the 14 is bucket (d)** — a decidable branch-gate or structural metric on a
multi-world branch. **No verdict** (`CLOSED`/`OPEN`/`STALLED`, `isValid`) moved in the measured
set, and **no bucket-(c) under-closing regression was found**. Every moved row is one that used to
compute `true` *because of* the unsound copies: the corpus was measuring the bug and reporting it
as health.

## The anchor result

Not yet fully measured, and this is the main gap.

- **Pre-fix**: `buildTableau ((G p) → □(G p)) 1000 .Base` returned `.allClosed` — a false claim of
  validity on an invalid formula, with `decide` returning `.extractionFailed`.
- **Post-fix, fuel 30 and 60**: `STALLED (none)`. The engine no longer closes it.
- **Post-fix, fuel 1000**: **unmeasured.** A scratch probe ran for over an hour without
  returning and was stopped.

So the defect (a closed tableau on an invalid formula) is demonstrably gone, but whether the
engine now reaches `.hasOpen` with a countermodel at fuel 1000, or exhausts fuel, is open. See
"Performance" below — this is the same phenomenon.

## Performance — a material, unresolved cost

`CrossWorldPropagationProbe.lean` built in **1.2 s** at baseline. Post-fix it, both `BoxNeg*Probe`
files, and `TableauConformance.lean` ran for **tens of minutes without completing**.

This is the plan's risk-asymmetry argument surfacing as wall-clock: removing emitted formulas
shrinks a branch's contradiction surface, so branches that used to close now stay open and
`decide` runs the whole fuel budget plus proof search plus countermodel extraction instead of
terminating early. It is the expected direction and a cost, not a soundness problem — but it is
large enough that a full corpus build must now be budgeted in tens of minutes to hours, and it may
need addressing before the Phase 8 gate can be run at all.

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
