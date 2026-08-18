# Implementation Summary: Task #453

- **Task**: 453 - restore `BimodalTest` green and clear C6 / C9
- **Plan**: plans/01_restore-guards-clear-c6-c9.md
- **Report**: reports/01_guard-rebaseline-and-c6-c9.md
- **Status**: COMPLETED
- **Phases**: 7 of 7 completed
- **Base commit**: `11ad049b8`
- **Type**: lean4

## Outcome

`lake build BimodalTest` exits 0, and `scripts/check-module-invariants.sh` reports
`ALL CHECKS PASSED` — every check group green, with C1, C6 and C9 all flipped to PASS and C2/C3
unchanged from the measured baseline.

No `.lean` semantics changed. Every `.lean` edit is inside a comment or a docstring; the sole
non-`.lean` change is `scripts/module-invariants-manifest.txt`. The Phase 1 STOP condition was not
triggered: all seven guards were made to pass by re-recording the generated string alone.

## What Was Done

### Phase 1 — the seven guard docstrings

All seven replacement strings were re-verified against Lean's own generated `info:` output
(by building each module and reading the `#guard_msgs` mismatch report) rather than trusted from
the research report's transcription. All seven matched the report byte-for-byte.

| Module | Rows | Move |
|---|---|---|
| `Tests/BimodalTest/BoxSpreadProbe.lean` | C | `\|T\|` 8 -> 6; `spread`/`anchor`/`grid`/`\|W\|` unchanged |
| `Tests/BimodalTest/RegionGateProbe.lean` | C, H | both to `\|T\|=6`, `gate=false check=false`, world 1 all-zero |
| `Tests/BimodalTest/TableauConformance.lean` | W1, W3, W6, W7 | W3 grows 8 -> 10; the rest shrink |

**W1 ≡ W7 confirmed.** W7 is W1 at five times the fuel, and the row exists to test that the two
agree. The pinned pair did not agree (9 vs 10 known times, differing constraint lists); the
generated pair is byte-identical, character for character. Current engine behaviour satisfies the
invariant the row was written to test and the recorded expectation did not — the strongest single
piece of evidence that these were stale expectations rather than a regression.

The rows at `TableauConformance.lean` 483/513/578 were not touched: they are already green and are
recorded as such.

### Phases 2-4 — documentation settlement

Each of the three files' `**EXCLUDED — left pinned and unedited**` subsections was rewritten into a
settlement record carrying: the 2026-08-10/11 engine-window attribution (semantics refactor plus
the tableau-engine work that rewrote `Tableau.lean` / `Saturation.lean` and added
`Verified/Termination/MintBound.lean`) rather than attribution to `trivialEventWitnessed`; the
zero-drift-since-2026-08-11 stability finding; and per-row before/P0/now values. Line-number
citations in the rewritten blocks were replaced with row letters and labels, which do not drift.

Narrative prose that the re-record would otherwise contradict was repaired:

- `RegionGateProbe.lean` — "**All nine rows report `gate=true`**" replaced with the uniform rule
  actually measured: every two-world row (A, B, C, H) reports `gate=false` with world 1's candidate
  vector all-zero; every single-world row (D, E, F, G, I) reports `gate=true`. Row C's gate loss
  carries the four-point confirmation that it is declared-tolerance behaviour, not a defect (the
  gate is a declared over-approximation; the cause is the already-documented removal of the unsound
  cross-world temporal copies; the resulting rule is uniform; and the probe's `gate`/`check`
  cross-check still agrees, both having moved to `false` together). Row C and row H narratives
  rewritten; the two rows now generate identical strings.
- `BoxSpreadProbe.lean` — module docstring and row-C narrative corrected; the "The rows" summary
  paragraph was corrected too (see Plan Deviations).
- `TableauConformance.lean` — W1 ≡ W7 agreement and the W3-growth rationale recorded; the
  "W1-W4 order eight to ten times each" count corrected to "seven to ten" (W2 now orders 7).
- The duplicated-sentence copy-paste defect in the "Re-baselined in this file" line was fixed in
  all three in-scope files. The three out-of-scope copies (`UntlSnceCopyProbe.lean`,
  `RayRegionProbe.lean`, `TemporalWitnessProbe.lean`) were verified still present and untouched.

### Phase 5 — C6

Seven plain (unprefixed) entries added to `scripts/module-invariants-manifest.txt` under two
commented blocks: six children of already-manifested importer-less aggregators, and one genuine
orphan (`OuterGateFaithful`). Each block states what would have to change for its lines to be
deleted. The comment does not claim the six are compile-unchecked — verified against the C6
implementation (`check-module-invariants.sh:365-378`, which runs `lake build <module>`, building
transitive dependencies) and against the three aggregators' import lines: all six are already
compile-checked transitively today. `OuterGateFaithful` is the only real coverage gain.

### Phase 6 — C9

`FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean` — the sole task-number
citation replaced with a durable in-file anchor. See Plan Deviations for the referent correction.

## Verification

| Gate | Result |
|---|---|
| `lake build` | exit 0 |
| `lake build BimodalTest` | exit 0 (was exit 1, seven `#guard_msgs` mismatches) |
| C1 | PASS, both lines |
| C2 | PASS — all four flagship axiom sets match baseline (`completeness` with `sorryAx`; `completeness_dense`, `completeness_discrete`, `Chronicle.countermodel_dense` without) |
| C3 | PASS — sole structural sorry still `countermodel_discrete` in `WeakCanonical/Transfer.lean` |
| C6 | PASS on all four sub-assertions (37 manifested / no phantom / no stale-reachable / 35 compile in isolation) |
| C9 | PASS — zero citations |
| B0, C4, C5, C8, C10 | PASS, unchanged |
| Overall | `ALL CHECKS PASSED` |
| Diff audit | zero semantics-bearing lines changed; sorries in `Tests/` 0; `axiom` count 9, unchanged from base |

## Plan Deviations

- **Phase 2, altered** — the staleness the plan names at the module docstring (line 29) recurs in
  the "The rows" summary paragraph (133-141: "all three conditions are false", "row C's `|T|` moved
  `10 → 8`"), which the plan does not name. Corrected in the same pass, since it contradicts a
  landed value and the plan's own goal forbids that.
- **Phase 6, altered** — the research report identifies the flagged "3" with item 3 of a numbered
  list "immediately above" in the same docstring. That identification does not hold: the numbered
  list sits ~50 lines *below* the citation (at 234-249) and enumerates the four rungs of the
  faithful re-base, whereas the flagged sentence heads `## The composition — sorry-free` and
  introduces `uSExpressivelyCompleteOverDensePrior_of_faithful`. The report's suggested replacement
  ("item 3 of the composition enumerated above") would have been a wrong anchor. A referent-neutral
  in-file anchor was used instead — the `uSExpressivelyCompleteOverDensePrior_of_faithful` bullet of
  "What this module lands", which names the same charter piece and is verifiable in the file.

## Files Modified

- `Tests/BimodalTest/BoxSpreadProbe.lean`
- `Tests/BimodalTest/RegionGateProbe.lean`
- `Tests/BimodalTest/TableauConformance.lean`
- `scripts/module-invariants-manifest.txt`
- `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean`

## Follow-ups (not done here, deliberately)

- Wire `OuterGateFaithful` into the build graph with one `import` line in
  `Kamp/NfMultiAnchorBridge.lean` and delete its manifest line in the same commit. Deferred as a
  build-graph change, forbidden by this task's no-semantics-change clause; recorded in the manifest
  comment.
- A guard-regeneration script. There is none; re-recording is manual.
- The three out-of-scope copies of the duplicated-sentence defect.
