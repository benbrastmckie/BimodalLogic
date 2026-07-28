# Implementation Summary: Phase 1 — Conformance Harness and Mechanical Calculus Repairs

- **Task**: 165 - establish_semantic_finite_model_property (tableau decidability rescope)
- **Plan**: `plans/01_tableau-decidability-two-track.md`
- **Phase**: 1 of 8 (R1, R3, R4) — `[COMPLETED]`
- **Type**: lean4

## What landed

### 1.1 Conformance corpus

`Tests/BimodalTest/TableauConformance.lean` (new, ~470 lines), registered in
`Tests/BimodalTest.lean`.

Four pinned verdict tables, one per `FrameClass`, each scored against that class's own
semantic target (`⊨`, `ValidDense`, `ValidDiscrete`, `ValidDedekindDense`). Every row carries
the verdict the engine produces, the verdict semantics requires, and a `[DEFECT]` marker when
they disagree. The tables are pinned with `#guard_msgs in #eval`, so any calculus change that
moves a verdict breaks the build and forces the flip to be justified in the same commit.

The verdict adapter reduces `buildTableau` to a `String` (`CLOSED`/`OPEN`/`STALLED`) rather
than using `decide`/`native_decide`/`rfl`, which stall on the fuel loop.

Corpus contents: the report 02 §2.1 controls; the five cslib seriality/dual probes; the
`F q → F^k ⊤` family for `k = 0..6`; both machine-produced counterexamples; the `temp_linearity`
/ `temp_linearity_past` / `linear_until` / `linear_since` / `until_F` / `since_P` axiom
instances; a per-class density probe; the two Discrete `prior_UZ`/`prior_SZ` rows; the three
Dedekind rows (`prior_U_gap`, `prior_S_gap`, `sep`).

### 1.2 R1 — transitive `futureOf` / `pastOf`

`TimeOrdering.futureOf` and `pastOf` were direct-edge filters. They are now the transitive
closures of the forward/backward constraint edges, computed by new private BFS helpers
`reachableForward` / `reachableBackward` with a visited set. The one-step readings are still
available as `directFutureOf` / `directPastOf`.

### 1.3 R3 + R4 — genuine blocking

- `ancestorTimes` followed `directPredecessors ++ directSuccessors`, i.e. the connected
  component, so every time incident to a constraint was its own ancestor and — because
  `isSubsetBlocked b t t` is reflexive — every such time was "blocked". It is now `ord.pastOf t`.
- `isTemporallyBlocked` called `allEventualitiesFulfilledOrDuplicated tracker t_anc t` against a
  `(t_new t_anc)` signature. Corrected to `tracker t t_anc`.

## Verification results

| Check | Result |
|---|---|
| `lake build` | green, 1902 jobs, 0 errors |
| `lake build BimodalTest` | green, 1943 jobs, 0 errors |
| Compiled-in sorries | 1 — `WeakCanonical/Transfer.lean:1225`, pre-existing, untouched |
| New sorries introduced | 0 |
| Vacuous definitions in `Decidability/` | 0 |
| `axiom` declarations | 0 (the two grep hits are prose inside comments) |
| `Saturation.lean` `#eval` suite | green, no `FAIL` |

`Tests/BimodalTest/Automation/ProofSearchTest.lean` emits pre-existing `FAIL: temp_*` lines from
its axiom-completeness summary. That file imports only `Automation/ProofSearch/Strategies` and
`ProofSystem`, nothing under `Decidability/`, so it is unaffected by this phase.

## Conformance corpus movement

| Row | Before | After |
|---|---|---|
| `A  Gp -> GGp` (counterexample A) | `STALLED` | **`CLOSED`** — target met, `[DEFECT]` cleared |
| `B  lin-perm` (counterexample B) | `STALLED` | `OPEN` — still `[DEFECT]`, the Phase 2.2 (R2) target |

Every other row held its verdict in all four classes: the controls, the axiom-instance rows, and
the Discrete `prior_UZ`/`prior_SZ` rows did not regress.

### Rows still failing (expected-current-failure, scheduled)

- **`S1`-`S5` seriality/dual** (all four classes): `F⊤`, `¬G⊥`, `Gp → Fp`, `Hp → Pp`, `P⊤` all
  answer OPEN. `serial_future`/`serial_past` are axioms of the system, so all five are theorems;
  no tableau rule manufactures a successor time from nothing. This is the exact failure mode the
  cslib survey recorded as its headline anti-lesson. It is a rule gap, not one of D1-D5, and is
  not assigned to a phase by the current plan.
- **`K2`-`K6`** (`F q → F^k ⊤`, `k ≥ 2`): same root cause as `S1`-`S5`. `K0`/`K1` close.
- **`B lin-perm`**: Phase 2.2 (R2 `orderTrichotomy`).
- **`C4 Fp -> FFp` at `.Dense` and `.Dedekind`**: the density rule does not fire on this shape.
- **`R1`-`R3` Dedekind rows**: `STALLED` — Phase 2.3 (R6 `dedekindRules`); no arm exists yet.

## Regression probes committed

`TransitivityProbe`: `ordA.futureOf 0 = [1, 2]` (was `[1]`), `ordA.pastOf 2 = [1, 0]`, empty
future/past at the endpoints, cycle termination, and the audit's rule-level probe —
`applyRule .someFutureNeg` on branch A now yields `persistent -> times [1, 2]`.

`BlockingProbe`: `ancestorTimes ⟨[(0,1)]⟩ 1 = [0]` (was `[0, 1]`), `ancestorTimes ⟨[(0,1)]⟩ 0 = []`,
and the §2.4 headline probe `isTemporallyBlocked b0 1 ⟨[(0,1)]⟩ = false` (was `true`). Three
further probes guard against over-correcting: blocking still fires when the subset condition
genuinely holds; an Until obligation pending at the blocked time withholds blocking; the same
obligation pending only at the ancestor does not.

## Plan deviations

- **1.2**: `isTimeOrderedBefore` could not be literally reused — it lives in
  `CountermodelExtraction.lean`, downstream of `SignedFormula.lean`. The same fuel-bounded
  reachability algorithm was implemented in `TimeOrdering`, with a visited set that additionally
  makes it cycle-safe and linear rather than exponential in the fuel. `isTimeOrderedBefore` is
  untouched and remains correct against the new `futureOf`.
- **1.3**: two contingent items needed no work. `blocking_sound` is stated about
  `findClosure openBranch = none`, not about the blocking predicate, so it re-elaborated
  unchanged; no `Closure.lean` monotonicity lemma broke. The 03 §4.5 per-branch tracker check
  found the cslib defect does not reproduce: each recursive `expandBranchWithFuel` call re-runs
  `registerEventualities`/`fulfillEventualities` against its own branch before consulting
  `findBlockedTime`, and the inherited tracker is a sound seed (every entry came from a formula
  on the parent branch, which is contained in each sub-branch). Recorded in-code at the `.split`
  arm so it is not re-litigated.

## Notes for the next dispatch

- Blocking no longer fires eagerly, so the engine explores considerably more before reaching a
  verdict. The corpus runs at a fixed `conformanceFuel := 200`; expect Phase 2.2's branching rule
  to raise this cost further, and re-check runtime when R2 lands (plan Risk 1).
- The seriality gap (`S1`-`S5`, `K2`-`K6`) is real, reproducible, and currently unowned by any
  phase. It is a missing rule rather than one of D1-D5, and it will block any truth lemma that
  needs a successor to exist. Worth an explicit decision before Phase 7.
