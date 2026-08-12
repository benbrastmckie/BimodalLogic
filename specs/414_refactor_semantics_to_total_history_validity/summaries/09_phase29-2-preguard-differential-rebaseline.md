# Phase 29.2 — the pre-guard differential, and the re-baseline it made honest

**Headline: `lake build BimodalTest` goes from 40 `#guard_msgs` mismatches to 7**, and the 7 are
exactly the rows that were **already wrong before the guard landed** — identified at row level for
the first time, by measurement.

**Status**: `[COMPLETED WITH EXCLUSIONS]`. 33 of 40 rows re-baselined with measured attribution;
- **Task**: TBD
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
7 excluded, enumerated, and documented in-source with their pinned / pre-guard / current triples.

---

## 1. What this phase was asked to do, and what it turned out to require

Phase 29.1 cleared **4** rows to apply and explicitly withheld the other **36**, because a
`#guard_msgs` failure reports pinned-vs-current only and carries no pre-guard value. It named the
separating measurement — a **pre-guard differential against `edcecd551^`** — and recorded it as an
outstanding prerequisite rather than attempting it.

That differential **was obtained here**, and it settled every question 29.1 left open.

## 2. The four cleared rows, applied first

Applied before any investigative work, each with the required three-part record (old value, new
value, owner) written into the row's own docstring, extending rather than overwriting the
deliberate narrative history those docstrings carry:

| File:row | Old (pinned) | New (measured) |
|---|---|---|
| `BoxNegReachabilityProbe.lean` row 9 | `(0, 0)` | **`(2, 40)`** |
| `BoxNegReachabilityProbe.lean` row 10 | `(false, false, true, false, true)` | **`(false, true, false, false, false)`** |
| `BoxNegReachabilityProbe.lean` row 11 | `false` | **`true`** |
| `CrossWorldPropagationProbe.lean` row F | `(false, false, true, false, true)` | **`(false, true, false, false, false)`** |

Row 10's docstring now reads the full arc: *from a wrong answer, to no answer, to the right
answer*. Both modules verified green immediately after (`EXIT=0`, 0 mismatches) and committed as
their own green sub-step (`a6a72d014`).

## 3. The measurement: a three-point differential

| Point | Commit | Meaning | Outcome |
|---|---|---|---|
| **P0** | `edcecd551^` = `d49b977c0` | guard **defined but not consulted** — pre-guard behaviour | `FormalSystem` **GREEN**, 2331 jobs; the 6 needed probe modules elaborated in 3, 4, 6, 12, 34, 53 s |
| **P1** | `edcecd551` | guard consulted (VARIANT A) | `FormalSystem` **RED** — `CountermodelExtraction.lean` and `MintBound.lean` do not compile at this commit; only `TableauConformance` elaborated |
| **P2** | `HEAD` | today | the 29.1 census, re-measured |

**Method**: `git worktree add --detach` to a scratch path, with `.lake/packages` symlinked to the
main tree so Mathlib was reused and nothing was refetched. `lake-manifest.json`, `lakefile.lean`,
and `lean-toolchain` are **byte-identical** across the window, and `Tests/` is **unchanged** since
`edcecd551^` — so the pinned values compared against are the same pinned values in both trees.
No destructive git operation was run in the working tree; the worktree was removed at exit.

**`BoxNegReachabilityProbe` was never built at P0** — at that commit it hangs, which is the whole
reason this task exists. Only the 6 modules carrying the 36 withheld rows were built there, each
under its own explicit bound (`timeout --kill-after=30 900`); none came close, the slowest taking
53 s.

**P1 is only partially obtainable, and that is itself a finding.** The guard commit `edcecd551`
does not build: `CountermodelExtraction.lean` and `MintBound.lean` were left red by it and were
repaired later, in phases 27/28. Five of the six probe modules depend on them and therefore could
not elaborate at P1.

## 4. The result: the declared ten is correct, and 29.1's "14" is superseded

29.1 reported `RegionGateProbe` 4-of-10 against a declared 2 and `BoxSpreadProbe` 3-of-5 against a
declared 1, and inferred "**14 measured vs 10 declared** … evidence the 7/2/1 declaration was never
row-verified." **Measurement reverses that.** At P0 the mismatch count is **exactly 10**, split
**exactly 7 / 2 / 1**:

| File | Declared | **Measured at P0** | Rows (numbering at the time of measurement) |
|---|---:|---:|---|
| `TableauConformance.lean` | 7 | **7** | 411, 441, 506, 801, 811, 832, 838 |
| `RegionGateProbe.lean` | 2 | **2** | 243, 274 |
| `BoxSpreadProbe.lean` | 1 | **1** | 113 |
| **Total** | **10** | **10** | — |

This is the row-level identification Phase 24 deferred, 29.1 could not recover from three
independent routes, and six dispatches declined to guess at.

**Why 29.1's file-level counts looked like an overflow.** They were correct as counts but conflated
two causes:

- `RegionGateProbe` 4 current = **2 pre-existing** (243, 274) **+ 2 guard-caused** (226, 235).
- `BoxSpreadProbe` 3 current = **1 pre-existing** (113) **+ 2 guard-caused** (99, 106).
- `TableauConformance` 7 current = **4 pre-existing that still mismatch** (801, 811, 832, 838)
  **+ 3 guard-caused** (806, 816, 824) — while **3 further pre-existing rows (411, 441, 506) were
  repaired by the guard** and now pass at their pinned values. Seven in, seven out, different rows.

That last line resolves 29.1's sharpest puzzle — "exactly 7, matching the declaration, yet 6 of the
7 carry the guard signature" — as an arithmetic coincidence, measured rather than assumed.

## 5. Classification of all 40 rows

29.1 was right that the plan's buckets are not disjoint, and right to refuse to guess. With P0 in
hand they separate cleanly. Rule applied per row, stated plainly:

> **A row is re-baselined only when the guard is the sole cause of its present mismatch** — that
> is, when its pinned value equals its pre-guard (P0) value. If the pinned value already disagreed
> with P0, the row was wrong for a reason owned outside this task, and moving it to its current
> value would fold that separately-owned change into this attribution.

| Class | Test | Count | Disposition |
|---|---|---:|---|
| **guard-caused only** | pinned **==** P0, pinned ≠ P2 | **29** | **RE-BASELINED** |
| **both** (stale *and* guard-moved) | pinned ≠ P0 **and** P0 ≠ P2 | **7** | **EXCLUDED**, left pinned |
| **stale only** | pinned ≠ P0, P0 == P2 | **0** | none exist |
| **guard-repaired** | pinned ≠ P0, P2 **==** pinned | **3** | no edit needed; now passing |

Plus the 4 applied in §2 → **33 re-baselined, 7 excluded, 40 accounted for.**

29.1's "bucket (c) surprises" resolve cleanly: `TemporalWitnessProbe` (11), `UntlSnceCopyProbe` (7),
and `RayRegionProbe` (4) all measure **fully green at P0** — every one of those 22 rows has
pinned == P0. They are guard-caused, on evidence, not by assumption. And
`TableauConformance:811` — the row 29.1 flagged for moving **opposite** to the guard signature —
measures as class (c) and is **excluded**. 29.1 was right to warn that "shrinks" must not be the
acceptance criterion; the criterion actually used is pinned == P0, which is direction-blind.

## 6. Attribution is measured, not inferred

The window `edcecd551^ .. HEAD` contains exactly two kinds of change:

1. The guard consultation in `Tableau.lean` — **computational**, two sites in `findApplicableRule`,
   plus a proof-side widening of `saturated_downward_closed`.
2. Proof-body-only edits to `CountermodelExtraction.lean`,
   `Verified/Bridge/TemporalSaturation.lean`, and `Verified/Termination/MintBound.lean`.

Those three diffs add and remove **no `def`, `abbrev`, `instance`, `structure`, or `inductive` line
at all** — so no `#eval` in the suite can have moved because of them. This is corroborated by
direct measurement rather than left as a reading of the diff: `TableauConformance`, the one module
that elaborated at P1, has **P1 == P2 on every one of its ten rows**, while **P0 ≠ P1 on every one**.
The entire move happens at the guard commit.

Every re-baselined row is therefore attributed to
`FormalSystem/Metalogic/Decidability/Tableau.lean`'s `def trivialEventWitnessed` — **not**
`Decidability/Saturation.lean` (report 04's guess), **not** the semantics refactor.

## 7. What was written into the source

- **Per row** (29 rows): a two-line `-- RE-BASELINED (guard):` note directly above the expectation,
  giving the old value verbatim, the new value verbatim, and the owner.
- **Per file** (6 files): a `Re-baseline record` header stating the owner, the three-point evidence
  table, the exact rule used to decide re-baseline vs. exclusion, and — where applicable — the
  **enumerated exclusions with their pinned / P0 / P2 triples**.

The excluded rows' expectations and docstrings are **byte-unchanged**. They are documented without
being edited, which is what the plan's never-silent rule and its exclusion prohibition jointly
require.

## 8. Reasoned Exclusions — the 7 rows left pinned

| # | File:line (current) | pinned → P0 → P2 | Why excluded |
|---|---|---|---|
| 1 | `BoxSpreadProbe.lean:165` | `\|T\|=8` → `\|T\|=10` → `\|T\|=6` | three distinct values: stale pre-guard **and** moved again |
| 2 | `RegionGateProbe.lean:299` | `\|T\|=8 gate=true check=true` → `\|T\|=10 gate=false` → `\|T\|=6 gate=false` | same; its `gate`/`check` flags were already wrong pre-guard |
| 3 | `RegionGateProbe.lean:330` | `\|T\|=10` → `\|T\|=9` → `\|T\|=6` | same |
| 4 | `TableauConformance.lean:873` | `knownTimes` 9 → 10 → 8 entries | same |
| 5 | `TableauConformance.lean:885` | 8 → 9 → 10 entries | same; 29.1's flagged opposite-direction row |
| 6 | `TableauConformance.lean:910` | full record → **`CLOSED`** → different record | sharpest case: pre-guard the branch closed outright |
| 7 | `TableauConformance.lean:916` | 10 entries → 10 in a different order → 8 | same |

**Owner**: the 2026-07-29 engine-behaviour change, owned outside this task.
**Follow-up**: a dedicated dispatch re-baselining these seven against that change. It is now cheap:
each row's pinned / pre-guard / current triple is recorded in-source, so the identification problem
that blocked six dispatches is solved and only the ownership decision remains.

## 9. The true remaining distance to a green `BimodalTest`

Stated honestly with a number, not fudged.

| Measure | Value |
|---|---|
| Mismatches at phase entry | **40** |
| Mismatches at phase exit | **7** |
| Exit status of `lake build BimodalTest` | **`EXIT=1`** — still non-zero |
| What the 7 are | exactly the enumerated exclusions in §8, at `BoxSpreadProbe:165`, `RegionGateProbe:299,330`, `TableauConformance:873,885,910,916` |
| Errors of any other kind | **0** — no compilation failure, no non-`#guard_msgs` error in the suite |

**The task-level gate "the full test suite under `Tests/BimodalTest/` passes" is NOT met**, and
this phase does not claim it. The remaining distance is 7 rows, all attributed to an
engine-behaviour change owned outside this task, all documented in-source, and none of them
re-baselinable here without laundering that change into this refactor's attribution. Closing them
is a separately-owned follow-up, and it is now a small one.

## 10. Gates at exit

| Gate | Result |
|---|---|
| `lake build` (default `FormalSystem` target) | **GREEN**, `EXIT=0`, **2331 jobs** — byte-identical to the Phase 24/28/29.1 baseline |
| `lake build BimodalTest` | `EXIT=1` from **7** enumerated exclusions only (was 40) |
| Live (non-Boneyard) sorries | **1**, unchanged: `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1084` |
| New sorries introduced | **0** (`git diff -- Tests/` adds no `sorry`) |
| `^axiom` declarations | **0** (6 matches, all docstring prose) — unchanged |
| `git diff -- FormalSystem/` | **empty** — `Tableau.lean` needed no edit; `witnessPresent` byte-identical |
| Removed `#eval` / `#guard_msgs` lines | **0** |
| Fuel figures changed | **0** — fuel unchanged at 1000 |
| Probes weakened, deleted, `sorry`'d, or excluded from the build | **none** |
| Scratch `git worktree` | removed at exit |

## 11. Routed, not fixed

The Phase 28 Layer-0 `isConsistent = false` finding is **not** touched. The suite remains silent on
it — no `#guard_msgs` row in the entire suite asserts `isConsistent`. `BoxNegReachabilityProbe`
row 11's docstring now records that the row asserts only that extraction returns `some`, and that
the `isConsistent` question is un-owned by it. The finding stands exactly where Phase 28 left it.
