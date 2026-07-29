# BEFORE Baseline — Corpus Verdict State on Unmodified Source

Task 418 — Phase 2 artifact. Captured at `HEAD = 6c4dc2711aa47f407ff241f631a97ad61402421b`
with zero `.lean` files modified (`git status --short` showed only `specs/` churn).

## 1. Build Results — both green

| Build | Command | RC | olean before | olean after | Verdict |
|-------|---------|----|--------------|-------------|---------|
| Library | `lake build` | **0** | 405 | 405 | Green. "Build completed successfully (1983 jobs)." |
| Corpus | `lake build BimodalTest` | **0** | 405 | 405 | Green. "Build completed successfully (2031 jobs)." |

`grep -c 'error:'` over both logs returns **0**. Only linter warnings (unused simp arguments,
unreferenced binders, one deprecation) are present, and those pre-date this task.

Olean counts are stable across both builds because the clone was already warm; nothing was
rebuilt and nothing was deleted. Per the Phase 1 triage checklist, `rc == 0` with
`after >= before` means **the build ran to completion** — this baseline is conclusive, not
inconclusive.

Logs: `baseline-build.log`, `baseline-corpus.log`.

**The baseline is fully green. There are zero pre-existing failing rows.** Every before/after
verdict move measured in Phase 6 is therefore attributable to this task's edit, with no
pre-existing failure to exclude from attribution.

## 2. Corpus Size — a correction to the plan's stated count

The plan asserts **145 `#guard_msgs` rows across eight probe files**, from a planning-time
`grep -c '#guard_msgs'` sweep. Re-counting confirms the eight-file list and the total grep-hit
count of 145, but **145 is not the row count**. Three of the 145 hits are prose mentions of the
string `#guard_msgs` inside module docstrings, not directives.

The actual number of `#guard_msgs` **directives** is **142**.

| Probe file | `grep -c '#guard_msgs'` (plan's number) | Real directives (`^\s*#guard_msgs`) | Prose mentions |
|---|---|---|---|
| `TemporalWitnessProbe.lean` | 71 | **71** | 0 |
| `TableauConformance.lean` | 29 | **27** | 2 (lines 57, 62) |
| `BoxNegReachabilityProbe.lean` | 12 | **12** | 0 |
| `RegionGateProbe.lean` | 10 | **10** | 0 |
| `RayRegionProbe.lean` | 8 | **7** | 1 (line 52) |
| `CrossWorldPropagationProbe.lean` | 5 | **5** | 0 |
| `BoxSpreadProbe.lean` | 5 | **5** | 0 |
| `BoxNegPreservationProbe.lean` | 5 | **5** | 0 |
| **Total** | **145** | **142** | **3** |

The eight-file list itself is confirmed correct: all eight are imported by `Tests/BimodalTest.lean`.
A ninth file, `Tests/BimodalTest/Automation/DeductionTest.lean`, carries 2 further `#guard_msgs`
directives, but they pin natural-deduction failure modes and have no tableau dependency; they are
outside the tableau corpus and are not tracked here.

Per the Phase 2 Scope Hypothesis instruction, this discrepancy is recorded as information rather
than suppressed. **All later phases use 142 as the row count**, and the per-file counts above as
the per-file baseline that Phase 7's `grep -c` invariant check must match.

## 3. Per-Row Expected Values

Every one of the 142 directives, with its full `/-- info: ... -/` expectation and its `#eval`
body, is extracted verbatim into the companion artifact **`baseline-rows-raw.md`** (142 rows,
grouped by file, each keyed by source line number). Because both builds exited zero, every one of
those written expectations **is** the engine's actual baseline verdict — a green `#guard_msgs`
is precisely the assertion that expected equals actual.

The authoritative frozen copy is the git object at
`6c4dc2711aa47f407ff241f631a97ad61402421b`; `baseline-rows-raw.md` is the readable rendering of it.

## 4. `boxAnchoredCheck` Anchor Baseline (for Phase 5)

`Tests/BimodalTest/BoxSpreadProbe.lean` rows A, B and C are the pre-fix `boxAnchoredCheck` datum.
Verbatim from the unmodified source:

```lean
-- A. The minimal witness: one box, one diamond, an unrelated consequent. The world is minted at
-- the same time the box sits at, so the failure is purely the later time-minting.
/-- info: "OPEN spread=false anchor=true grid=true |W|=2 |T|=7" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia q)) r)

-- B. The witness world carries a temporal universal of its own.
/-- info: "OPEN spread=false anchor=true grid=true |W|=2 |T|=7" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia (.allFuture q))) r)

-- C. The same shape under `.Dense`, where the density rules mint further times.
/-- info: "OPEN spread=false anchor=true grid=true |W|=2 |T|=10" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia q)) r) 200 .Dense
```

**Anchor baseline, pre-fix:**

| Row | Formula | `spread` | `anchor` | `grid` | `\|W\|` | `\|T\|` |
|---|---|---|---|---|---|---|
| A | `(□p ∧ ◇q) → r`, `.Base`, fuel 200 | `false` | **`true`** | `true` | 2 | **7** |
| B | `(□p ∧ ◇(G q)) → r`, `.Base`, fuel 200 | `false` | **`true`** | `true` | 2 | **7** |
| C | `(□p ∧ ◇q) → r`, `.Dense`, fuel 200 | `false` | **`true`** | `true` | 2 | **10** |

`probe` is defined in the same file as
`s!"OPEN spread={boxTemporalSpreadCheck ob} anchor={boxAnchoredCheck ob} grid={boxGridCheck ob} |W|={ob.knownWorlds.length} |T|={ob.knownTimes.length}"`.

Rows D and E use a different helper (`gapProbe`, single-world compound-`□` configuration) and are
not part of the anchor baseline.

**This is the before-value Phase 5 compares against.** `anchor=true` on multi-world branches
(`|W|=2`) is the property predicted to become `false` after the deletion.

## 5. Phase 2 Verification Checklist

- [x] Both logs exist; both builds exited zero.
- [x] Pre-build and post-build olean counts consistent with a completed build (405 / 405, both).
- [x] `baseline-verdicts.md` enumerates every probe file with its row count and greenness.
- [x] The `BoxSpreadProbe` anchor baseline is recorded verbatim.
- [x] `git diff --stat` shows zero changes under `FormalSystem/` and `Tests/`.
- [x] Corrected the plan's 145 to the measured 142, with the 3-prose-mention explanation.
