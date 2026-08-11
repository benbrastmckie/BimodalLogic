# Phase 29.1 — `lake build BimodalTest` measurement record

**Headline: `BimodalTest` TERMINATED in 35 s.** The gate that had been unrunnable for this entire
task — killed twice, once by `timeout 3000` (`EXIT=124`) and once by hand, after pinning a core at
~99.7% for >45 min — now completes in **35 seconds**. The milestone is met.

**Status**: COMPLETED. This sub-phase is measurement-only: **no file under `Tests/` or
`FormalSystem/` was edited** (`git status --porcelain Tests/ FormalSystem/` empty at entry and at
exit). The re-baseline is Phase 29.2's exclusive job and is **not** applied here.

---

## 1. Run parameters (recorded before the build started)

| Field | Value |
|-------|-------|
| Command | `lake build BimodalTest` |
| Wall-clock bound | **3600 s** (`timeout 3600`) |
| Start time | 2026-08-11T15:49 -07:00 |
| Working tree | clean w.r.t. `FormalSystem/` and `Tests/` |
| Baseline for comparison | Phase 24 / Phase 28: `lake build` (default `FormalSystem` target) = 2331 jobs, 1 live sorry, 0 axiom declarations |
| Prior state of this target | UNRUNNABLE — see headline |

## 2. The milestone fact

| Measure | Value |
|---|---|
| **Terminates?** | **YES** |
| **Wall-clock** | **35 s** (bound 3600 s; used 0.97% of budget) |
| Exit status | `EXIT=1` — build failed on `#guard_msgs` **expectation** mismatches only |
| Job count | **2380** (`[2378/2380]` final), vs. the 2331-job `FormalSystem`-only baseline: **+49 test-module jobs** |
| Errors outside `Tests/` | **0** (`grep -c '^error: FormalSystem/'` = 0) |

`EXIT=1` is **not** a compilation failure. Every error in the log is a
`❌️ Docstring on '#guard_msgs' does not match generated message` — i.e. a stale *expectation*, which
is precisely what this phase exists to measure and Phase 29.2 exists to re-baseline. No module
failed to elaborate.

### 2.1 The probes were genuinely elaborated, not replayed from cache

This distinction is load-bearing: a cached replay would prove nothing about termination. Lake
reports `Building` (fresh elaboration) rather than `Replayed` (cache) for **all eight** probe
modules:

| Module | Lake line | Time |
|---|---|---|
| `BimodalTest.RayRegionProbe` | `✖ [1452/1463] Building` | 1.6 s |
| **`BimodalTest.BoxNegReachabilityProbe`** | `✖ [1472/1488] Building` | **1.0 s** |
| `BimodalTest.BoxSpreadProbe` | `✖ [1474/1488] Building` | 2.1 s |
| `BimodalTest.RegionGateProbe` | `✖ [1475/1488] Building` | 2.3 s |
| **`BimodalTest.CrossWorldPropagationProbe`** | `✖ [1476/1705] Building` | **1.7 s** |
| `BimodalTest.TemporalWitnessProbe` | `✖ [2372/2380] Building` | 8.4 s |
| `BimodalTest.UntlSnceCopyProbe` | `✖ [2376/2380] Building` | 31 s |
| `BimodalTest.TableauConformance` | `✖ [2377/2380] Building` | 34 s |

The two headline numbers, against their pre-fix records:

- `BoxNegReachabilityProbe`: **1.0 s**, previously **killed after >45 min, twice**, leaving no `.olean`.
- `CrossWorldPropagationProbe`: **1.7 s**, previously **2418 s**. A ~1400x improvement.

This confirms the Phase 26 prediction (`buildTableau ((G p) → □(G p)) 1000 .Base` = `(2, 40)` in 2 s)
holds under the real build, at unchanged fuel 1000, with no probe weakened.

## 3. Tree-wide gate re-verified at exit

| Gate | Result |
|---|---|
| `lake build` (default `FormalSystem` target) | **GREEN**, `EXIT=0`, **2331 jobs** — byte-identical to the Phase 24/28 baseline |
| Live (non-Boneyard) sorries | **1**, unchanged: `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1084` |
| `^axiom` declarations | **6 matches, 0 declarations** — unchanged; all six are prose inside docstrings (Phase 28's finding, re-confirmed) |
| New sorries / new axioms introduced by this phase | **0 / 0** — trivially, since this phase edited no Lean file |

## 4. Every `#guard_msgs` mismatch in the suite: 40 rows across 8 files

| File | Total `#guard_msgs` rows | Mismatching rows | Mismatching row numbers (source lines) |
|---|---:|---:|---|
| `Tests/BimodalTest/TemporalWitnessProbe.lean` | 71 | **11** | 443, 448, 458, 468, 482, 495, 520, 525, 844, 856, 874 |
| `Tests/BimodalTest/UntlSnceCopyProbe.lean` | 37 | **7** | 346, 358, 642, 652, 672, 729, 739 |
| `Tests/BimodalTest/TableauConformance.lean` | 29 | **7** | 801, 806, 811, 816, 824, 832, 838 |
| `Tests/BimodalTest/RegionGateProbe.lean` | 10 | **4** | 226, 235, 243, 274 |
| `Tests/BimodalTest/RayRegionProbe.lean` | 8 | **4** | 123, 128, 144, 154 |
| `Tests/BimodalTest/BoxSpreadProbe.lean` | 5 | **3** | 99, 106, 113 |
| `Tests/BimodalTest/BoxNegReachabilityProbe.lean` | 12 | **3** | 220, 241, 250 |
| `Tests/BimodalTest/CrossWorldPropagationProbe.lean` | 6 | **1** | 124 |
| **Total** | **178** | **40** | |

Every other `#guard_msgs` row in the suite — 138 of them — **passes**. No test module fails to
compile.

---

## 5. Bucket (a): moved because of the new guard — the Phase 29.2 re-baseline set

### 5.1 The four rows the Scope Hypothesis predicted — all four confirmed exactly

Report 05 §7 predicted with high confidence that exactly these four rows move. **All four moved,
and each moved to exactly the predicted value.** Each is independently corroborated by a direct
Phase 26 / Phase 28 measurement, which is what makes the guard attribution evidentiary rather than
inferred.

| # | File:row | Row index | Old (pinned) | **New (measured)** | Independent corroboration |
|---|---|---|---|---|---|
| 1 | `BoxNegReachabilityProbe.lean:220` | row 9 | `(0, 0)` | **`(2, 40)`** | Phase 26 measured `buildTableau ((G p) → □(G p)) 1000 .Base = (2, 40)` in 2 s. `N = 40`. |
| 2 | `BoxNegReachabilityProbe.lean:241` | row 10 | `(false, false, true, false, true)` | **`(false, true, false, false, false)`** | Phase 28's `decide`: `(isValid, isInvalid, isFuelExhausted) = (false, true, false)`. Was unmeasurable until `DecisionProcedure.lean` compiled. |
| 3 | `BoxNegReachabilityProbe.lean:250` | row 11 | `false` | **`true`** | Phase 28 settled: `extractCountermodelFromTableau` returns `some`. **Confirms Phase 28's correction of the plan's original `false` expectation.** |
| 4 | `CrossWorldPropagationProbe.lean:124` | row F (row 6) | `(false, false, true, false, true)` | **`(false, true, false, false, false)`** | Same fuelExhausted-tuple → invalid-tuple move as row 10. |

**Attribution** for all four: `FormalSystem/Metalogic/Decidability/Tableau.lean`'s
`trivialEventWitnessed` guard, landed at `d49b977c0` (definition, Phase 25.1) and `edcecd551`
(consulted, VARIANT A, Phase 25.2).

### 5.2 The "may move" rows resolved: they did NOT move

The Scope Hypothesis flagged `BoxNegReachabilityProbe` rows 4-8 (`reached := run 12`) as "may
move". **They did not.** Rows 4-8 are source lines 144, 162, 173, 182, 193 — none appears in the
mismatch list. Row 12 (line 259), previously unmeasurable because `DecisionProcedure.lean` did not
compile, **also passes** at its pinned value. Of `BoxNegReachabilityProbe`'s 12 rows, exactly
rows 9, 10, 11 moved.

### 5.3 The 36 remaining mismatches carry the guard's signature, but see §6

Report 05 claim 16 recorded the rows in `TableauConformance`, `RegionGateProbe`, `BoxSpreadProbe`,
`TemporalWitnessProbe`, `RayRegionProbe`, and `UntlSnceCopyProbe` as `[UNVERIFIED]` — unmeasurable
without exactly this build. They are now measured. **The prediction erred: it is 40 rows, not 4.**
Per lesson 1's inverse, the measured list governs.

The measured moves are dominated by one signature — **the time-domain shrinks**, which is the
direct expected consequence of a guard that stops minting trivial seriality witnesses:

| File | Signature of the moves |
|---|---|
| `RegionGateProbe` | `\|T\|` 7→4, 7→4, 8→6, 10→6; `cands` lists shorten correspondingly |
| `BoxSpreadProbe` | `\|T\|` 7→4, 7→4, 8→6; one row also flips `grid=false`→`grid=true` |
| `RayRegionProbe` | `\|T\|` 6→5, 7→5, 7→4, 6→5; `check`/`rayUp`/`rayDn`/`rays` all unchanged |
| `TemporalWitnessProbe` (rows 443-525) | `\|T\|` 6→5, 7→5, 7→4, 6→5, 6→5, 7→5, 6→5, 6→5 |
| `TemporalWitnessProbe` (rows 844, 856, 874) | flag-only moves: `gw=false`→`gw=true` on rows 856/874; row 844 moves `wit=true`→`wit=false` on all four of `uGW`/`sGW`/`uRD`/`sRU` |
| `TableauConformance` | `knownTimes` shrinks on 6 of 7 rows (9→8, 9→7, 9→8, 9→6, 6→5, 10→8) and **grows on one** (row 811: 8→10); `constraints` shorten correspondingly |
| `UntlSnceCopyProbe` | numeric drift in ordinal/index lists, mostly downward (`[2,4,5,8,13,24,45]`→`[2,3,5,7,13,23,45]`), one upward (`[some 4,…]`→`[some 5,…]`, row 672; `…,10]`→`…,11]`, row 729) |

`TableauConformance` row 811 and `UntlSnceCopyProbe` rows 672/729 move in the **opposite**
direction to the rest. They are not counterevidence to guard attribution — a shorter witness chain
renumbers downstream indices, and renumbering is not monotone — but they are flagged here so
Phase 29.2 does not treat "shrinks" as the acceptance criterion.

---

## 6. Bucket (b): the ten pre-existing mismatches — row-level identification is **NOT** resolved, and this is a finding

Phase 24 deferred the row-level identification of the ten pre-existing, separately-declined
mismatches (`TableauConformance` 7 of 29, `RegionGateProbe` 2 of 10, `BoxSpreadProbe` 1 of 5) to
this sub-phase, on the stated ground that identifying them "requires running the suite". **That
ground turns out to be insufficient.** The suite has now been run, and the identification is still
not recoverable. Recording this plainly rather than guessing:

### 6.1 What the measurement shows about the three named files

| File | Declared pre-existing | **Measured mismatching** | Delta |
|---|---:|---:|---:|
| `TableauConformance.lean` | 7 of 29 | **7 of 29** | **0 — exact match** |
| `RegionGateProbe.lean` | 2 of 10 | **4 of 10** | **+2** |
| `BoxSpreadProbe.lean` | 1 of 5 | **3 of 5** | **+2** |
| **Total** | **10** | **14** | **+4** |

### 6.2 Why the build output cannot separate (a) from (b)

Both classes surface identically. A `#guard_msgs` failure reports only *pinned* vs *current*; it
carries no record of what the value was before the guard landed. Three independent routes to
recover the pre-guard row set were attempted and all came up empty:

1. **In-source markers** — Phase 24 already grepped all three files for
   `mismatch|pre-existing|stale|known.fail|XFAIL|…` and found **zero hits**. Re-confirmed: the
   files carry no annotation distinguishing a pre-existing mismatch.
2. **Upstream artifacts** — the 7/2/1 split originates from an engine-behaviour change owned
   outside this task and baselined 2026-07-29. A search of `specs/` outside `specs/414*` for a
   row-level record of that split returns nothing. Report 05 names the three files and the counts
   but does not pin the rows.
3. **Git history** — decisive on ordering, silent on rows. `trivialEventWitnessed` landed at
   `d49b977c0` / `edcecd551`, *after* every one of these files was last modified
   (`TableauConformance` 2026-07-28 `7681d9132`; `RegionGateProbe`/`BoxSpreadProbe`/`RayRegionProbe`
   2026-07-29 `d67059938`; `TemporalWitnessProbe` 2026-07-29 `269412954`). So no expectation in any
   of these files was written with knowledge of the guard — which establishes that all 40 pinned
   values are pre-guard, but does **not** say which were *already* stale beforehand.

### 6.3 The structural finding: the buckets are not disjoint

The plan's three-bucket scheme assumes each mismatching row belongs to exactly one bucket. The
measurement shows that assumption does not hold. A row that was *already* stale as of the
2026-07-29 engine change and has *additionally* been moved by the guard is in both (a) and (b)
simultaneously — its current value differs from its pinned value for two independent reasons, and
no re-baseline can honour the exclusion and correct the guard's effect at the same time.

`TableauConformance` is the sharpest case: its measured count is **exactly 7**, matching the
declared pre-existing 7 — yet 6 of those 7 rows show the `knownTimes`-shrink guard signature. Either
reading alone is unsupported by the evidence:

- *"These 7 are the pre-existing 7, untouched by the guard"* — contradicted by the shrink signature.
- *"These 7 all moved because of the guard"* — would silently absorb the excluded ten into the
  re-baseline, which the plan forbids in the strongest terms.

The `+2 / +2` overflow in `RegionGateProbe` and `BoxSpreadProbe` says the same thing from the other
side: the guard moved rows in files that already had declined mismatches.

### 6.4 What this means for Phase 29.2 — a decision rule, not a guess

Phase 29.2 can re-baseline **§5.1's four rows immediately**: each has an old value, a new value,
and an independent Phase 26/28 measurement backing the attribution.

For the other **36 rows**, the exclusion of the ten is **not checkable from this measurement**, and
Phase 29.2 must not proceed on any of them by assuming otherwise. The only measurement that
separates the classes is a **pre-guard differential**: elaborate the eight probe modules against
`edcecd551^` and diff the resulting `#guard_msgs` output against this record. Any row whose value is
identical pre-guard and post-guard is bucket (b) — pre-existing, still declined, untouched. Any row
that differs is bucket (a). Rows differing from *both* the pinned value and the pre-guard value are
the non-disjoint case of §6.3 and need an explicit decision, not a silent edit.

That differential was not run here: it needs a separate build tree at a historical commit, which is
a cold `lake build` including a Mathlib cache fetch — well outside a measurement sub-phase whose own
build took 35 s, and outside this phase's territory. **It is recorded as the outstanding
prerequisite for re-baselining anything in the three excluded files.**

---

## 7. Bucket (c): neither — surprises

| Finding | Why it is not bucket (a) or (b) |
|---|---|
| **Three files never declared in any bucket now show 22 mismatches**: `TemporalWitnessProbe` (11), `UntlSnceCopyProbe` (7), `RayRegionProbe` (4) | Report 05 claim 16 listed them as `[UNVERIFIED]`, not as pre-existing. They carry the guard signature and are *probably* bucket (a), but they inherit §6.2's separability problem: no pre-guard record exists for them either. |
| **`TableauConformance:811` moves in the opposite direction** — `knownTimes` grows 8→10 | Downstream renumbering explains it, but it is the one row whose direction contradicts the guard's expected effect, so it is flagged rather than assumed. |
| **The declared pre-existing counts are exceeded by +4** (§6.1) | Neither a guard effect nor a pre-existing mismatch as declared — it is evidence the 7/2/1 declaration was never row-verified and cannot be reconciled at file level. |

### 7.1 Routed, not fixed: the Layer-0 `isConsistent = false` finding

Phase 28 flagged that the returned Layer-0 `SimpleCountermodel` has `isConsistent = false`
(`trueAtoms = [p ×6]`, `falseAtoms = [p]`) because the Layer-0 flattening discards the
`(world, time)` label. **The `BimodalTest` output neither confirms nor contradicts it**: no
`#guard_msgs` row in the suite asserts `isConsistent` on the extracted countermodel, so the suite is
silent on the question. `BoxNegReachabilityProbe` row 11 asserts only that extraction returns
`some` (now measured `true`). The finding stands exactly where Phase 28 left it — un-owned, not a
regression, and **not** touched here.

---

## 8. Re-baseline declaration for Phase 29.2

**Apply these four, each with attribution to `FormalSystem/Metalogic/Decidability/Tableau.lean`'s
`trivialEventWitnessed` guard (`d49b977c0`, `edcecd551`):**

| File:row | Old | New |
|---|---|---|
| `Tests/BimodalTest/BoxNegReachabilityProbe.lean:220` (row 9) | `(0, 0)` | `(2, 40)` |
| `Tests/BimodalTest/BoxNegReachabilityProbe.lean:241` (row 10) | `(false, false, true, false, true)` | `(false, true, false, false, false)` |
| `Tests/BimodalTest/BoxNegReachabilityProbe.lean:250` (row 11) | `false` | `true` |
| `Tests/BimodalTest/CrossWorldPropagationProbe.lean:124` (row F) | `(false, false, true, false, true)` | `(false, true, false, false, false)` |

**Do not apply anything to the other 36 rows** until the §6.4 pre-guard differential separates
bucket (a) from the excluded ten. The full verbatim old/new pairs for all 36 are recorded in §5.3's
signature table and in the build log; they are deliberately not presented here as a re-baseline
list, because presenting them as one would be exactly the laundering the plan forbids.

**Expected state after 29.2 applies the four**: 36 mismatches remain, `lake build BimodalTest` still
exits 1. The suite does not go green at Phase 29.2, and the task-level gate *"the full test suite
under `Tests/BimodalTest/` passes"* is **not** met by applying this declaration alone. That gate now
has a measured, enumerated distance to green — 40 rows, of which 4 are cleared to move — rather than
an unrunnable build.
