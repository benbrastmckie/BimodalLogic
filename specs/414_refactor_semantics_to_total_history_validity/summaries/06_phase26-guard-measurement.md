# Phase 26 — Measuring the landed guard on the live engine (go/no-go gate)

**VERDICT: GO.** All three GO conditions hold, measured on the unmodified engine. Report 05's
`[DERIVED, not measured]` claim 10 is now **measured and confirmed**: after `saturateBlocked`,
the literal `findUnexpanded … = none` holds, `findClosure = none`, and the end-to-end
`buildTableau ((G p) → □(G p)) 1000 .Base` returns `.hasOpen` with an open branch of length 40 —
probe row 9's owed `(2, _)`, measured as `(2, 40)`.

**Landed variant under test: A (suppress).** Per `summaries/05_phase25-trivial-event-guard.md`,
Phase 25 landed variant A, not B: the plan's variant-B Scope Hypothesis was measured and
REFUTED. So the guard under measurement here is `trivialEventWitnessed`
(`FormalSystem/Metalogic/Decidability/Tableau.lean:1924`), consulted as a disjunct beside
`witnessPresent` at exactly two sites inside `findApplicableRule` (`:1957` `.linear`, `:1981`
`.branching`).

## What this phase measures, and why it is a gate

Report 05's claim 10 — that under the fix the **unmodified** `buildTableau` returns
`.hasOpen` — is marked `[DERIVED, not measured]` in that report (§5.3). Report 05 simulated the
suppression **at the finder** (`Diag8.lean`'s `findUnexp'`), not inside the guard, and therefore
measured `literalNone = false` / `suppressedNone = true` and *derived* that a guard-side
placement would make the literal test read `none`. Phase 25 landed the guard-side placement.
This phase drives the **unmodified** engine and measures it.

Phases 27 and 28 pay real proof cost downstream of this measurement. A NO-GO here, clearly
evidenced, would have been a successful outcome of this phase: it would have saved that cost.
The measurement came back GO.

**Why the derivation was right.** `isExpanded` (`Tableau.lean:1999-2002`) is *defined* as
`(findApplicableRule sf branch timeOrd fc).isNone`, and `findUnexpanded`
(`Tableau.lean:2008-2010`) is `b.find? (¬ isExpanded ·)`. So a guard-side placement — which is
what landed — propagates into the literal test by definition, whereas report 05's finder-side
simulation could not. This is the mechanism behind the confirmed prediction, and it is checkable
from the two definitions without re-running anything.

## Method, and the bounds on it

No Lean source file under `FormalSystem/` or `Tests/` was edited by this phase. Standalone
drivers were written under the session scratchpad and compiled with `lake env lean` against the
oleans Phase 25 rebuilt (report 05 §3's method).

**Import discipline**: the drivers import `FormalSystem.Metalogic.Decidability.Saturation` and
never `…DecisionProcedure`. Phase 25 measured `Tableau` and `Saturation` green and rebuilt their
oleans; `DecisionProcedure`'s olean predates the Phase 25 edit, so importing it would load a
stale transitive closure and any number read off it would be untrustworthy. (`DecisionProcedure`
is instead *rebuilt* as its own measurement — see Measurement 4.)

**`lake build BimodalTest` was NOT run.** It hangs (`BoxNegReachabilityProbe.lean`'s `#eval`
pinned a core for >45 min and was killed twice). Phase 29.1 owns it.

Every measurement below carries a stated wall-clock bound. A measurement that exceeded its bound
was killed and is recorded as `[UNVERIFIED] — attempted, killed at N s`, never silently dropped
or retried at a lower fuel.

Drivers, verbatim, under
`/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/d728a978-af02-4055-a349-322cf8ed38ec/scratchpad/`:
`Phase26A.lean`, `Phase26B.lean`, `Phase26C.lean`, `Phase26D.lean`.

## Measurement 1 — live-engine round-by-round trajectory

Driver: `Phase26A.lean`. Drives the unmodified `expandOnceUnblocked` from `b0` (identical to
`BoxNegReachabilityProbe.lean:85-87`) at `.Base`, leftmost-branch walk mirroring report 05's
`run'`, rounds 0 through 48. Per round: branch length, `#times`, `#worlds`, `#blocked`,
blocking-aware saturation, the literal `findUnexpanded … = none`, and closure.

**Bound**: 540 s. **Actual**: 2 s, `EXIT=0`.

| n | branch len | #times | #worlds | #blocked | blocking-aware `sat`? | literal `none`? |
|---|---|---|---|---|---|---|
| 0 | 2 | 1 | 1 | 0 | no | no |
| 4 | 8 | 2 | 2 | 0 | no | no |
| 12 | 20 | 4 | 2 | 1 | no | no |
| 19 | 30 | 6 | 2 | 2 | no | no |
| 22 | 34 | 6 | 2 | 2 | no | no |
| **23** | **36** | **6** | 2 | 2 | **yes** | no |
| 24-48 | 36 | 6 | 2 | 2 | yes | no |

- **Saturation is first reached at step 23** and holds at **every** step from 23 through 48 — a
  contiguous run, i.e. a fixpoint, not a transient. Branch length, time count, world count and
  blocked count are all constant across that run.
- **Time count settles at 6 and stops.** World count is constant at 2 throughout, as report 05
  §1 measured for the unfixed engine too (the blow-up was purely temporal).
- `closed=false` at every round: the branch is open throughout.

**Quantitative comparison with report 05 §5.2** (which the plan explicitly says is a finding to
record, not a failure — only the qualitative hypothesis was under test):

| Quantity | Report 05 §5.2 (simulated at the finder) | Phase 26 (live engine, guard-side) |
|---|---|---|
| First saturation | step 31 | **step 23** |
| Stable through | 44 | **48** (the full range driven) |
| #times at saturation | 8 | **6** |
| #worlds | 2 | 2 (unchanged) |
| branch len at saturation | 47 | **36** |

The live engine saturates **earlier and smaller** than the simulation predicted. This is the
expected direction: with the guard inside `findApplicableRule`, the suppressed `T(F ⊤)` /
`T(P ⊤)` formulas stop being expandable at all, whereas the finder-side simulation left them
expandable and merely skipped them as sources.

## Measurement 2 — the claim-10 measurement (the decisive one)

Driver: `Phase26B.lean`. Runs `saturateBlocked b 1000 o .Base` on the first
blocking-aware-saturated branch exactly as `Saturation.lean:1176` does, then evaluates the
**literal** `findUnexpanded … = none` that `ExpandedTableau.hasOpen` (`Saturation.lean:75`)
demands and that `buildTableau` checks at `:1171` and `:1179`.

**Bound**: 540 s. **Actual**: 2 s, `EXIT=0`.

**Before `saturateBlocked`, at n=23** — the literal test is *not* yet `none`, and the driver
identifies exactly why:

```
blockedTimes = [5, 3]
literal findUnexpanded = some @ (w=0, t=5)  blockedTime=true
  sf = neg (imp (atom p) bot) @ {world := 0, time := 5}
```

The one literally-unexpanded formula sits at time 5, which **is** a blocked time — precisely the
case `buildTableau`'s post-blocking `saturateBlocked` pass exists to clear. It is a propositional
residue (`F(¬p)`), not a seriality demand, so it is not evidence about the guard either way.

**After `saturateBlocked`** — the certificate is reached, at every saturated round tested:

| start round n | result | len | #times | #worlds | `literalNone` | `findClosure = none` |
|---|---|---|---|---|---|---|
| 23 | OPEN | 39 | 6 | 2 | **true** | **true** |
| 24 | OPEN | 39 | 6 | 2 | **true** | **true** |
| 30 | OPEN | 39 | 6 | 2 | **true** | **true** |
| 40 | OPEN | 39 | 6 | 2 | **true** | **true** |
| 48 | OPEN | 39 | 6 | 2 | **true** | **true** |

`saturateBlocked` never returns `.inl` (closed) on this branch, so the engine does **not** report
this invalid formula valid. `literalNone = true` is the claim-10 confirmation: report 05
measured `literalNone = false` for the finder placement and derived `true` for the guard
placement. Guard placement landed; the literal test reads `none`. **Measured, not derived.**

## Measurement 3 — end-to-end `buildTableau`

Driver: `Phase26C.lean`, which is probe row 9 (`BoxNegReachabilityProbe.lean:220-224`) evaluated
outside the probe file. The probe file was **not** edited and its expectation was **not**
re-baselined (Phase 29.2 owns that).

**Bound**: 900 s. **Actual**: 2 s, `EXIT=0`. Fuel was **not** lowered — 1000 throughout.

```
#eval match buildTableau (gp.imp gp.box) 1000 .Base with
      | none => (0, 0) | some (.allClosed bs) => (1, bs.length) | some (.hasOpen ob _ _ _) => (2, ob.length)
--> (2, 40)
```

**`(2, 40)`.** The constructor is `.hasOpen`; the actual open-branch length is **40**. This is
the `(2, _)` end state `BoxNegReachabilityProbe.lean:216-217` names as owed, reached on the
**unmodified** `buildTableau` at unchanged fuel.

**For Phase 29.2, measured rather than predicted** (recorded here; **not** applied — this phase
re-baselines nothing):

| Probe row | Current pinned expectation | Measured under the landed guard |
|---|---|---|
| row 9 (`BoxNegReachabilityProbe.lean:219-224`) | `(0, 0)` | **`(2, 40)`** |

Attribution path for the re-baseline is
**`FormalSystem/Metalogic/Decidability/Tableau.lean`** — note that the standing Phase 29.2
attribution names `FormalSystem/Automation/Tableau.lean`, **which does not exist**. Phase 25's
summary flagged the same wrong path; it is still uncorrected in the plan and must be fixed
before Phase 29.2 runs.

Row-10/11 values (the `decide` tuple and the countermodel) are covered by Measurement 4.

## Measurement 4 — `decide` (rows 10-12): NOT MEASURABLE, with a measured reason

`decide` lives in `DecisionProcedure.lean`, which imports `CountermodelExtraction.lean`. Rather
than read `decide` off a stale olean, `DecisionProcedure` was **rebuilt**.

Command: `lake build FormalSystem.Metalogic.Decidability.DecisionProcedure`.
**Bound**: 900 s. **Actual**: 6 s, `EXIT=1`.

```
✔ [1355/1357] Built FormalSystem.Metalogic.Decidability.ProofExtraction (1.4s)
✖ [1356/1357] Building FormalSystem.Metalogic.Decidability.CountermodelExtraction (4.5s)
Some required targets logged failures:
- FormalSystem.Metalogic.Decidability.CountermodelExtraction
```

**1355 of 1357 jobs green; exactly one module red.** `decide` therefore cannot be evaluated at
all in this dispatch, and probe rows 10, 11 and 12 are recorded as
**`[UNVERIFIED] — not measurable until `CountermodelExtraction.lean` is green`**, which is Phase
28's territory. This is not a timeout and not a guess: the module does not compile, so there is
no `decide` to run. Lowering fuel, weakening a probe, or excluding a file would not have changed
this and was not attempted.

### Evidence sizing Phases 27-28 — Phase 25's `[UNVERIFIED]` prediction, now MEASURED

Phase 25 predicted `[UNVERIFIED]` that downstream cost would land in
`CountermodelExtraction.lean` and `Verified/Bridge/*`. The `CountermodelExtraction` half is now
**confirmed by measurement**, and it is exactly the shape predicted:

| # | Site | Enclosing theorem |
|---|---|---|
| 1 | `CountermodelExtraction.lean:520:20` unsolved goals | `sat_box_neg` (`:505`) |
| 2 | `CountermodelExtraction.lean:551:98` unsolved goals | `sat_untl_pos` (`:534`) |
| 3 | `CountermodelExtraction.lean:567:22` unsolved goals | `sat_untl_pos` (`:534`) |
| 4 | `CountermodelExtraction.lean:597:96` unsolved goals | `sat_snce_pos` (`:581`) |
| 5 | `CountermodelExtraction.lean:612:22` unsolved goals | `sat_snce_pos` (`:581`) |

**Five errors, three theorems, one file.** Every residual goal has the same shape — the file
`unfold`s `findApplicableRule`, which now reads
`if (witnessPresent … || trivialEventWitnessed …) = true then none`, leaving:

```
⊢ witnessPresent  TableauRule.sncePos {…} b timeOrd = false
∧ trivialEventWitnessed TableauRule.sncePos {…} b timeOrd = false
```

This is precisely the `not_or.mp` treatment Phase 25 applied to `saturated_downward_closed`, so
the repair pattern is already established in-tree rather than novel. No new `sorry` and no new
axiom is implied by it.

## Measurement 5 — the `Verified/` side, and a phase-ordering finding

Command: `lake build …Verified.Bridge.TemporalSaturation …Verified.Bridge.PropSaturation
…Verified.Bridge.BoxSaturation`. **Bound**: 900 s. **Actual**: 550 s, `EXIT=1`.

**Green (measured this dispatch)**:

| Module | Status |
|---|---|
| `Verified/Termination/Fuel.lean` | **BUILT GREEN** |
| `Verified/Termination/SubformulaProperty.lean` | **BUILT GREEN** |
| `Verified/Termination/TimeTypeBound.lean` | **BUILT GREEN** |
| `Verified/Bridge/BranchOrder.lean` | **BUILT GREEN** |

`Fuel.lean` building green is a second confirmation of Phase 25's variant-A reasoning: variant A
gives `findApplicableRule` only a **new `none` path**, so every `some` it produces is unchanged,
and `findApplicableRule_applyRule_eq` (`Fuel.lean:238-242`) — the theorem Phase 25 identified as
falsified *at the statement level* by variant B — is untouched. Phase 25 recorded that as
`[UNVERIFIED: derived, not built]`. It is now **built**.

**Still unmeasured**: `Verified/Bridge/BoxSaturation.lean`, `…/PropSaturation.lean`,
`…/TemporalSaturation.lean` were **never reached** — the build failed upstream on
`CountermodelExtraction`. Their status is unmeasured, **not** known-broken.

**Phase-ordering finding (actionable for the orchestrator).** The import graph is:

```
CountermodelExtraction.lean
  └── Verified/Bridge/BoxSaturation.lean
        ├── Verified/Bridge/PropSaturation.lean
        └── Verified/Bridge/TemporalSaturation.lean   (also imports BranchOrder)
```

The plan assigns `Verified/Bridge/*` to **Phase 27** and `CountermodelExtraction.lean` to
**Phase 28**. But `BoxSaturation.lean` *imports* `CountermodelExtraction.lean`, so **Phase 27's
territory cannot be compiled at all until Phase 28's `CountermodelExtraction` repair lands.** As
written, Phase 27 would spend itself unable to verify anything. Either the five
`CountermodelExtraction` errors move into Phase 27, or Phases 27 and 28 swap order. This is a
plan defect surfaced by measurement; **this phase does not edit Phases 27-28 to fix it** — that
is the orchestrator's call.

## GO condition

| # | Condition | Result |
|---|---|---|
| 1 | Blocking-aware saturation reached at a bounded step and holds as a contiguous run, time count settling | **MET** — first at step 23, contiguous 23-48, times settle at 6, worlds constant at 2 (Measurement 1) |
| 2 | After `saturateBlocked`, the **literal** `findUnexpanded … = none` holds | **MET** — `literalNone = true` at every saturated start round tested (Measurement 2) |
| 3 | `findClosure = none` on that branch (open, hence `.invalid`) | **MET** — `findClosureNone = true` at every saturated start round tested; `saturateBlocked` never returns closed (Measurement 2) |

All three hold. **VERDICT: GO** — Phase 27 may proceed.

## Scope notes carried forward from Phase 25

- `isApplicable .untlPos` is `(asUntil? φ).isSome` and `asUntil?` returns `none` when
  `guard == Formula.top`, so `.untlPos` can never fire on the `F ⊤` trigger. Its arm in
  `trivialEventWitnessed`, and the `.sncePos` mirror, are unreachable defensive code. **Nothing
  measured here is evidence about those two arms either way.** The termination effect measured
  above is carried entirely by the `.someFuturePos` / `.somePastPos` arms.
- Modules outside `Tableau` and `Saturation` were **unmeasured, not known-broken** on entry
  (declared red window for Phases 25-28). This dispatch narrowed that: see Measurements 4 and 5
  for what is now measured green, measured red, and still unmeasured.

## Green / knowingly red / unmeasured at exit

**Green (measured this dispatch)**: `Verified/Termination/Fuel.lean`,
`Verified/Termination/SubformulaProperty.lean`, `Verified/Termination/TimeTypeBound.lean`,
`Verified/Bridge/BranchOrder.lean`, `ProofExtraction.lean`, plus everything in the 1355-job
prefix of the `DecisionProcedure` build. `Tableau.lean` and `Saturation.lean` remain green
(replayed from cache, unmodified by this phase).

**Knowingly red (measured this dispatch)**: `CountermodelExtraction.lean` — 5 errors, 3
theorems, listed above. This is inside the declared Phase 25-28 red window.

**Unmeasured (not known-broken)**: `Verified/Bridge/BoxSaturation.lean`, `…/PropSaturation.lean`,
`…/TemporalSaturation.lean`, `DecisionProcedure.lean`, `TraceCertificate.lean`, and every module
downstream of `CountermodelExtraction`. `BimodalTest` is unmeasured by dispatch constraint
(Phase 29.1 owns it).

## What this phase did NOT do

- No file under `FormalSystem/` or `Tests/` was edited. `git status --short -- FormalSystem/
  Tests/` is empty at exit.
- No probe expectation was re-baselined. Row 9's measured `(2, 40)` is **recorded** above for
  Phase 29.2 to apply; the probe file is untouched.
- No fuel was lowered, no probe weakened, no file excluded from the build, no `sorry` and no
  axiom added.
- `lake build BimodalTest` was not run.
