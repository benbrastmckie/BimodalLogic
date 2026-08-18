# Implementation Plan: Task #453

- **Task**: 453 - restore `BimodalTest` green and clear C6 / C9
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/453_restore_bimodaltest_green_and_clear_c6_c9/reports/01_guard-rebaseline-and-c6-c9.md
- **Artifacts**: plans/01_restore-guards-clear-c6-c9.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`lake build BimodalTest` currently exits 1 with exactly seven `#guard_msgs` docstring mismatches
and no other error; `lake build` (FormalSystem alone) exits 0. This plan settles that recorded
debt by re-recording the seven expectations from Lean's own generated `info:` strings, rewriting
the three in-source "Re-baseline record" headers that currently enumerate these seven rows as
deliberately excluded (plus the row narratives and one module-docstring verdict paragraph that
will otherwise contradict the landed values), adding the seven unreachable live modules to
`scripts/module-invariants-manifest.txt` to clear C6, and replacing one task-number citation with
a durable anchor to clear C9. Definition of done: `lake build` exits 0, `lake build BimodalTest`
exits 0, and `scripts/check-module-invariants.sh` reports C1/C6/C9 PASS with C2 and C3 unchanged
from the measured baseline in the research report §2.

**Hard constraint, in force for every phase**: no `.lean` semantics change. Every edit this plan
authorises is a docstring, a comment, or a manifest line. **If any guard cannot be made to pass by
re-recording the generated string alone, STOP and report** — do not adjust the engine, the probe
definitions, the fuel values, or the `#eval` bodies. That outcome would falsify the
stale-expectations verdict and is a different task.

### Research Integration

The research report (`reports/01_guard-rebaseline-and-c6-c9.md`) is load-bearing for this plan and
supplies four things the implementer must not re-derive:

- **§3 — the seven replacement strings, verbatim.** All seven generated `info:` lines are
  transcribed from the build log. Phase 1 is a transcription, not a measurement. The report also
  fixes the off-by-one: **the docstring line is one above the reported error line** in every case
  (the error is reported at the `#guard_msgs` command).
- **§4 — the verdict, independently re-verified.** W1 (`:872`) and W7 (`:915`) now generate
  byte-identical output, which is the invariant W7 exists to test; every property the rows assert
  still holds; and every `P2 current` value recorded in the three in-source headers on 2026-08-11
  is byte-identical to today's output (zero drift). This is the evidence the attribution note in
  Phases 2-4 must cite.
- **§5.2 — three stale-prose sites the task brief does not name**, all inside the same three
  files, plus a duplicated-sentence copy-paste defect in the "Re-baselined in this file" line of
  all three. `RegionGateProbe.lean:63-66` ("All nine rows report `gate=true`") is required, not
  optional: it will directly contradict the row-C value being landed.
- **§6 and §7 — C6 and C9 resolved.** All seven unmanifested modules build cleanly in isolation
  (`lake build <module>` exit 0 each), so seven **plain** manifest lines suffice and no `broken:`
  prefix is needed. C9's "task 3" refers to item 3 of a numbered list in the same docstring, not
  to a task number.

One correction the report makes to the task brief, which the manifest comment must respect: six of
the seven C6 modules are **already** compile-checked transitively via their manifested sibling
aggregators. `OuterGateFaithful` is the only genuine coverage gain. The manifest comment must not
claim `UltrafilterMCS` is currently compile-unchecked.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was supplied with this dispatch; `roadmap_flag` was not set. No roadmap phases
are included.

## Goals & Non-Goals

**Goals**:
- `lake build BimodalTest` exits 0 with all seven `#guard_msgs` expectations re-recorded from
  Lean's generated output.
- The three "Re-baseline record" headers state the settlement truthfully: the seven are attributed
  to the 2026-08-10/11 engine window (not to `trivialEventWitnessed`), W1/W7 agreement is recorded,
  RegionGate row C's gate loss is confirmed, and the values are noted stable since 2026-08-11.
- No narrative comment in the three probe files contradicts a landed value.
- C6 PASSes: the seven unreachable live modules are manifested with justification comments that
  say what would have to change for each line to be deleted.
- C9 PASSes: the sole task-number citation is replaced with a durable anchor.
- C1 PASSes; C2 and C3 unchanged against the measured baseline in report §2.

**Non-Goals**:
- No change to the tableau engine, `Saturation.lean`, or `MintBound.lean`.
- No re-opening of the 29 rows re-recorded by `86eb8963c`, and no edit to
  `TableauConformance.lean`'s rows at `483`, `513`, `578` (already self-repaired and green).
- No guard-regeneration script (worth doing; scope separately).
- No `import` line added to `Kamp/NfMultiAnchorBridge.lean` to wire in `OuterGateFaithful`. That is
  arguably the more correct repair but it is a build-graph change, forbidden by this task's
  no-semantics-change clause. Record it in the manifest comment as the eventual fix instead.
- The three out-of-scope copies of the duplicated-sentence defect
  (`UntlSnceCopyProbe.lean:136`, `RayRegionProbe.lean:88`, `TemporalWitnessProbe.lean:222`) stay
  untouched.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A re-recorded string is normalised, re-sorted, or reflowed | H | M | `knownTimes` and `constraints` print in engine list order, not sorted. Copy verbatim from report §3; `#guard_msgs` compares the rendered message. Verify per module immediately after each file's edit. |
| Line numbers shift under the prose rewrites, so a docstring is edited at the wrong site | H | M | Phase 1 lands all seven re-records **before** any prose rewrite, and matches **by content, not line number** (every old string is unique in its file). Report §3 confirms uniqueness. |
| The "Re-baseline record" headers cite line numbers that the rewrite invalidates | M | H | In Phases 2-4, replace line-number citations with row letters (A-I, W1-W7), which are stable, rather than re-deriving numbers that will drift again. |
| An edit crosses out of a comment region into a `/-- info: ... -/` guard | H | L | Every documentation phase closes with a build of that one module (`local` tier). Cheapest module first. |
| A guard still mismatches after re-recording | H | L | STOP condition: report and halt. Do not touch the engine. Report §4.4 shows zero drift since 2026-08-11, so this is not expected. |
| The C9 replacement still matches the task-number regex and is blocked at the tool boundary | M | M | `validate-no-task-references.sh` blocks the write, it does not merely flag it. Avoid `task N`, `tasks N`, `task #N`, `task-N` in any case. Use "item 3" / "step 3" / "the third piece". |
| A manifest entry names a module that is actually reachable | M | L | C6 fails on phantom and stale-reachable entries too. Phase 5 verifies with `check-module-invariants.sh --no-build` (cheap), Phase 7 with the full run. |
| `TableauConformance` iteration cost (~28 s incremental, ~49 s cold) makes trial-and-error expensive | L | M | Do the two cheap modules first (BoxSpreadProbe ~1.9 s, RegionGateProbe ~2.3 s) to shake out transcription technique, then TableauConformance once. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 5, 6 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 7 | 1, 2, 3, 4, 5, 6 |

Phases within the same wave can execute in parallel. Phases 1, 5 and 6 touch disjoint file sets
(the three probe modules / the manifest / one `FormalSystem` module). Phases 2, 3 and 4 each own
exactly one probe file and are file-disjoint from one another.

---

### Phase 1: Re-record the seven guard docstrings [COMPLETED]

**Goal**: `lake build BimodalTest` exits 0, with all seven `#guard_msgs` expectations replaced by
Lean's generated strings and nothing else changed.

**Tasks**:
- [x] Re-read report §3 in full. The seven replacement strings there are authoritative; do not
      re-measure them, only verify by building.
- [x] `Tests/BimodalTest/BoxSpreadProbe.lean` — replace the row C (`.Dense`) expectation at
      docstring line 164 (error reported at 165). Only `|T|` moves, `8 -> 6`; `spread`, `anchor`,
      `grid` and `|W|` are unchanged. Verify: `lake build BimodalTest.BoxSpreadProbe` (~1.9 s).
      Commit on green.
- [x] `Tests/BimodalTest/RegionGateProbe.lean` — replace the row C expectation at docstring 298
      (error 299) and the row H expectation at docstring 329 (error 330). Rows C and H now generate
      the **same** string; that is expected, not a copy-paste error. Verify:
      `lake build BimodalTest.RegionGateProbe` (~2.3 s). Commit on green.
- [x] `Tests/BimodalTest/TableauConformance.lean` — replace the four expectations at docstrings
      872 (W1), 884 (W3), 909 (W6), 915 (W7). W3 **grows** (`|knownTimes|` 8 -> 10) against the
      general shrinking trend; this is expected per report §3.5. W7's new value is byte-identical
      to W1's new value; that is the point, not a mistake. Verify:
      `lake build BimodalTest.TableauConformance` (~28 s incremental). Commit on green.
- [x] Whole-target confirmation: `lake build BimodalTest` exits 0.
- [x] Do **not** touch the rows at `TableauConformance.lean:483`, `:513`, `:578` — the exclusion
      block lists them as already self-repaired and they are green today.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: exactly seven `#guard_msgs` mismatches exist, at the seven docstring
locations enumerated above, and each old string is unique within its file. Confirm at
implementation time by (a) grepping each old string and observing exactly one hit per file before
editing, and (b) `lake build BimodalTest` exiting 0 after all seven edits with no eighth mismatch
appearing. If an eighth mismatch surfaces, or if a re-recorded row still mismatches, invoke the
STOP condition below rather than widening the edit.

**Files to modify**:
- `Tests/BimodalTest/BoxSpreadProbe.lean` — one `/-- info: ... -/` docstring (row C)
- `Tests/BimodalTest/RegionGateProbe.lean` — two `/-- info: ... -/` docstrings (rows C, H)
- `Tests/BimodalTest/TableauConformance.lean` — four `/-- info: ... -/` docstrings (W1, W3, W6, W7)

**Verification**:
- Each module builds clean in isolation after its own edit (`lake build BimodalTest.<Module>`).
- `lake build BimodalTest` exits 0.
- `git diff` shows exactly seven changed docstring lines and no other line in any `.lean` file.
- **STOP condition**: if any guard cannot be made to pass by substituting the generated string
  alone, halt and report. Do not adjust the engine, probe definitions, fuel values, or `#eval`
  bodies.

---

### Phase 2: BoxSpreadProbe documentation settlement [COMPLETED]

**Goal**: `Tests/BimodalTest/BoxSpreadProbe.lean`'s prose is consistent with the row-C value landed
in Phase 1, and its "Re-baseline record" header records the settlement instead of asserting an
exclusion.

**Tasks**:
- [x] Rewrite the `**EXCLUDED — left pinned and unedited**` subsection (block at 59-105, exclusion
      list at 94-104) so it records row C as **settled**, not excluded. It must state: the row is
      attributed to the 2026-08-10/11 engine window (the semantics refactor plus the tableau-engine
      work that rewrote `Tableau.lean` and `Saturation.lean` and added
      `Verified/Termination/MintBound.lean`), **not** to `trivialEventWitnessed`, which is the
      separately-owned change the original exclusion was protecting; and that the P2 value recorded
      on 2026-08-11 is byte-identical to what Lean generates today, so this settles recorded debt
      rather than establishing a fresh baseline.
- [x] Fix the row narrative at 161-163: "`|T|` shrinks to `8`" is now `|T|=6`.
- [x] Fix the module docstring at line 29: "**The anchor and the grid are now false as well**
      (rows A, B, C)" — rows A and B now report `grid=true` (both at `|T|=4`). This staleness
      predates the task; it is in the paragraph a reader consults and is cheap to correct here.
      *(deviation: altered — the same staleness recurs in the "The rows" summary paragraph at
      133-141 ("all three conditions are false", "row C's `|T|` moved `10 → 8`"), which the plan
      does not name; corrected in the same pass since it contradicts a landed value.)*
- [x] Fix the duplicated-sentence copy-paste defect in the "Re-baselined in this file" line
      (line 92): the fragment "— each carrying its own `RE-BASELINED (guard)` note with the old and
      new value." appears twice.
- [x] Replace line-number citations in the rewritten block with row letters, which do not drift.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `Tests/BimodalTest/BoxSpreadProbe.lean` — module docstring 29, Re-baseline record block 59-105
  (incl. duplicated sentence at 92 and exclusion list 94-104), row narrative 161-163

**Verification**:
- `lake build BimodalTest.BoxSpreadProbe` exits 0 (~1.9 s) — confirms no edit crossed out of a
  comment region into the adjacent guard docstring.
- `git diff` for this phase touches only comment and docstring regions; the row-C `/-- info: -/`
  line is byte-identical to what Phase 1 landed.

---

### Phase 3: RegionGateProbe documentation settlement and row-C gate confirmation [COMPLETED]

**Goal**: `Tests/BimodalTest/RegionGateProbe.lean` states the correct measured verdict, and the
record carries the one-sentence confirmation that row C's gate loss is expected behaviour, not a
defect.

**Tasks**:
- [x] Rewrite the module docstring's measured-verdict paragraph at 63-66. "**All nine rows report
      `gate=true`**" is false: rows A, B, H already reported `gate=false` and row C now joins them.
      The accurate replacement, per report §5.3.3, is the uniform rule: **every two-world row
      (A `:279`, B `:290`, C `:298`, H `:329`) reports `gate=false` with world 1's candidate vector
      all-zero; every single-world row (D, E, F, G, I) reports `gate=true`.** Also correct the
      stale per-row sizes in the same paragraph (65-66): row A is now `|T|=4` with world 1
      all-zero, and row B likewise.
- [x] Add the row-C confirmation sentence (task deliverable (c)) to the record. It must say that
      row C joined rows A/B/H in pinning `gate=false` for the documented over-approximation reason:
      the module's own "Two deliberate over-approximations" section (53-59) states the gate is
      **harder** to pass than the induction needs, so "failing it would not by itself refute
      anything"; the unsound cross-world temporal copies were the only route by which
      `T(Gφ)`/`T(Hφ)` reached a freshly minted world, and with them gone a minted world receives
      none. Note also that the probe's designed cross-check still holds — `gate` (probe-computed)
      and `check` (library-computed) moved to `false` together.
- [x] Rewrite the row C narrative at 292-294 ("The one moved two-world row that keeps its gate ...
      `|T|` shrinks `10 -> 8` ... world 1's per-region count falls `3 -> 1` rather than to `0`") —
      every clause is now contradicted: `|T|=6`, world 1's vector is all-zero, gate lost.
- [x] Rewrite the row H narrative at 325-327 ("Unlike row C, `|T|` is unmoved at `10` here — the
      `◇(G q)` shape still forces the same density mints"): H is now `|T|=6` and C and H generate
      identical strings.
- [x] Rewrite the `**EXCLUDED — left pinned and unedited**` subsection (block 75-125, exclusion
      list 110-124) into a settlement record carrying the same attribution as Phase 2 (2026-08-10/11
      engine window; not `trivialEventWitnessed`; values stable since 2026-08-11), plus the row-C
      confirmation above.
- [x] Fix the duplicated-sentence copy-paste defect at line 108.
- [x] Replace line-number citations in the rewritten block with row letters.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `Tests/BimodalTest/RegionGateProbe.lean` — module docstring 63-66, Re-baseline record block
  75-125 (incl. duplicated sentence at 108 and exclusion list 110-124), row narratives 292-294 and
  325-327

**Verification**:
- `lake build BimodalTest.RegionGateProbe` exits 0 (~2.3 s).
- No remaining occurrence of "All nine rows report `gate=true`" or of the `|T|=10` / `3 -> 1`
  claims in the file.
- `git diff` for this phase touches only comment and docstring regions; both `/-- info: -/` lines
  are byte-identical to what Phase 1 landed.

---

### Phase 4: TableauConformance documentation settlement [COMPLETED]

**Goal**: `Tests/BimodalTest/TableauConformance.lean`'s Re-baseline record settles W1, W3, W6, W7
and records the W1 ≡ W7 agreement, without disturbing the three already-green rows the same block
lists.

**Tasks**:
- [x] Rewrite the `**EXCLUDED — left pinned and unedited**` subsection (block 69-139, exclusion
      list 104-138) so W1, W3, W6, W7 read as settled. Carry the same attribution as Phases 2-3
      (2026-08-10/11 engine window; not `trivialEventWitnessed`; P2 values byte-identical to
      today's output, so zero drift since 2026-08-11).
- [x] Record the W1 ≡ W7 agreement explicitly — this is the strongest single item of evidence and
      the task brief names it as required. W7 is by construction "W1 at fuel 2000, five times W1's
      own `linearityFuel`. Identical, so the flip to `total=true` is `timeLinearity` firing and not
      a budget artifact" (comment at 913-914). The **pinned** pair was not identical; the
      **generated** pair is byte-identical. Current engine behaviour satisfies the invariant the
      row was written to test, and the recorded expectation did not.
- [x] Note that W3 grew (`|knownTimes|` 8 -> 10) against the shrinking trend, and why that is
      consistent rather than anomalous: renumbering can leave a row with more surviving times, and
      W3 still reports `total=true incomparable=[]`.
- [x] Preserve, without re-recording or restructuring away, the block's entries for rows `483`,
      `513`, `578`, each recorded as `P2 current: (now matches the pinned value — the guard
      repaired this row)`. They are green and out of scope.
- [x] Fix the narrative at 806-807: "W1-W4 order eight to ten times each" — W2 now orders 7. A
      one-word fix.
- [x] Fix the duplicated-sentence copy-paste defect at line 102.
- [x] Replace line-number citations in the rewritten block with row labels (W1, W3, W6, W7), which
      do not drift.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `Tests/BimodalTest/TableauConformance.lean` — Re-baseline record block 69-139 (incl. duplicated
  sentence at 102 and exclusion list 104-138), narrative 806-807

**Verification**:
- `lake build BimodalTest.TableauConformance` exits 0 (~28 s incremental).
- `git diff` for this phase touches only comment and docstring regions; all four `/-- info: -/`
  lines are byte-identical to what Phase 1 landed, and the rows at 483/513/578 are untouched.

---

### Phase 5: Clear C6 — manifest the seven unreachable live modules [COMPLETED]

**Goal**: `scripts/check-module-invariants.sh` C6 PASSes on all four of its sub-assertions
(manifested / no phantom / no stale-reachable / all compile).

**Tasks**:
- [x] Add seven **plain** (unprefixed) entries to `scripts/module-invariants-manifest.txt`. No
      `broken:` prefix: report §6.2 measured `lake build <module>` exit 0 with zero `error:` lines
      for every one of the seven.
- [x] Group them under two commented blocks, following the existing BiLasso block's precedent
      (which already lists every child alongside its aggregator, so listing children is the
      established convention here, not a new one):
      - **Block A — six children of already-manifested unreachable aggregators**:
        `FormalSystem.Metalogic.Algebraic.{BooleanStructure, InteriorOperators, LindenbaumQuotient,
        UltrafilterMCS}`, `FormalSystem.Metalogic.Bundle.Construction`,
        `FormalSystem.Metalogic.SoundnessLemmas.CoValidity`. Comment must record: each is reached
        only through a sibling aggregator that is itself manifested as deliberately importer-less,
        so it inherits that unreachability; and the contrast case that proves the pattern —
        `Algebraic/FlowFrame.lean`, the fifth file in the same directory, **is** imported directly
        (by `BXCanonical/Completeness.lean` and `BXCanonical/Chronicle/ChronicleMonadicBridge.lean`)
        and is correctly absent from the manifest. State what would have to change for these lines
        to be deleted: a direct importer outside the aggregator.
      - **Block B — one genuine orphan**:
        `FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGateFaithful`, which has
        no importer anywhere in the live tree. Its aggregator `Kamp/NfMultiAnchorBridge.lean` is
        itself reachable and imports `NfMultiAnchorBridge.OuterGate` but not `OuterGateFaithful`.
        The comment must record that wiring it in with one `import` line in
        `Kamp/NfMultiAnchorBridge.lean` is the eventual fix, deliberately deferred here because it
        is a build-graph change, and that deleting this line is what wiring it in means.
- [x] Do **not** claim in the comment that `UltrafilterMCS` is compile-unchecked. Per report §6.4,
      six of the seven are already compile-checked transitively (C6 runs `lake build` on the
      manifested aggregators, which compiles transitive dependencies). `OuterGateFaithful` is the
      only genuine coverage gain — say that, and only that.
- [x] Add no task-number citation of any form to the manifest comments (this file is outside
      `specs/**`; `validate-no-task-references.sh` will block the write and C9 would re-fail).

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: exactly seven modules are unreachable-and-unmanifested, they are the seven
enumerated in report §6.1, and all seven build clean so no `broken:` prefix is required. Confirm at
implementation time by running `bash scripts/check-module-invariants.sh --no-build` before the edit
and observing C6 FAIL naming exactly those seven, then after the edit observing C6's
absence-assertion clear. The compile sub-assertion is confirmed in Phase 7's full run.

**Files to modify**:
- `scripts/module-invariants-manifest.txt` — seven entries under two new commented blocks

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` — C6's absence assertion clears; no phantom
  entry and no stale-reachable entry reported. (The `--no-build` flag skips C6's compile-check;
  that sub-assertion is verified in Phase 7.)
- B0, C3, C4, C5, C8, C10 unchanged (all PASS).

---

### Phase 6: Clear C9 — replace the task-number citation with a durable anchor [COMPLETED]

**Goal**: `scripts/check-module-invariants.sh` C9 PASSes with zero hits, and `lake build` still
exits 0.

**Tasks**:
- [x] Edit `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean:185`. The current
      sentence reads "This is the plan's task 3, discharged in full." The "3" refers to item 3 of a
      numbered list in the **same docstring** (the `**Source status**` region enumerates the four
      pieces of the faithful re-base, item 3 being "the bridge interface and the six trichotomy
      arms") — it is not a task-management reference. Replace with a durable anchor such as: "This
      is item 3 of the composition enumerated above, discharged in full."
      *(deviation: altered — the report's identification of the referent does not hold. That
      numbered list sits ~50 lines BELOW the citation, not above it, and enumerates the four rungs
      of the faithful re-base, whereas the flagged sentence heads `## The composition — sorry-free`
      and introduces `uSExpressivelyCompleteOverDensePrior_of_faithful`. "item 3 ... enumerated
      above" would therefore have been a wrong anchor. Used a referent-neutral in-file anchor
      instead: the `uSExpressivelyCompleteOverDensePrior_of_faithful` bullet of "What this module
      lands", which is the same charter piece and is verifiable in the file.)*
- [x] Leave the remainder of the sentence intact ("Every step of the chartered composition that the
      tree supports is taken here; the only thing standing between this and an unconditional
      `uSExpressivelyCompleteOverDensePrior` is the obligation above.").
- [x] **Implementation warning**: `validate-no-task-references.sh` is a write-time hook that
      **blocks** writes to non-`specs/**` paths matching the task-number pattern — a replacement
      still containing `task 3` will fail at the tool boundary, not merely be flagged by C9. The
      C9 regex is case-insensitive `\b(tasks?[[:space:]]+#?[0-9]+|task-[0-9]+)\b`. Safe substitutes:
      "item 3", "step 3", "the third piece", "the bridge-interface rung".

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean` — one docstring sentence at
  line 185

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` — C9 PASS (zero hits).
- `lake build` exits 0 (the edit is inside a docstring in a live `FormalSystem` module).

---

### Phase 7: Full verification gate [COMPLETED]

**Goal**: every verification clause in the task brief is measured green in one clean run, in the
cheap-to-expensive order the research report recommends.

**Tasks**:
- [x] `bash scripts/check-module-invariants.sh --no-build` — expect C6 and C9 flipped to PASS, and
      B0, C3, C4, C5, C8, C10 unchanged (all PASS). C1 and C2 are skipped by the flag.
- [x] `lake build` — expect exit 0.
- [x] `lake build BimodalTest` — expect exit 0. If a guard mismatches here, iterate per module
      (`lake build BimodalTest.<Module>`) rather than rebuilding the whole target.
- [x] `bash scripts/check-module-invariants.sh` (full, with build) — expect C1 both lines PASS; C2
      matching the four-line baseline recorded in report §2 (`completeness` with `sorryAx`;
      `completeness_dense`, `completeness_discrete`, `Chronicle.countermodel_dense` without); C3
      PASS with the sole structural sorry still `countermodel_discrete` in
      `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`; C6 PASS on all four sub-assertions; C9
      PASS.
- [x] Final diff audit: confirm every changed line across all `.lean` files is inside a docstring
      or a comment, and that the only non-`.lean` change is
      `scripts/module-invariants-manifest.txt`. No `def`, `theorem`, `#eval`, fuel value, or import
      line changed anywhere.

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3, 4, 5, 6

**Verification Tier**: full

**Verification**:
- All four commands above produce the expected exit codes and check verdicts.
- The diff audit finds zero semantics-bearing changes.

---

## Testing & Validation

- [x] `lake build` exits 0.
- [x] `lake build BimodalTest` exits 0 (was: exit 1 with seven `#guard_msgs` mismatches).
- [x] `bash scripts/check-module-invariants.sh` reports C1 PASS, C6 PASS, C9 PASS.
- [x] C2 matches the four-line axiom baseline measured in report §2, byte-for-byte.
- [x] C3 unchanged: sole structural sorry is still `countermodel_discrete` in
      `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`.
- [x] B0, C4, C5, C8, C10 unchanged (all PASS).
- [x] Diff audit: every `.lean` change is a docstring or comment; the sole non-`.lean` change is
      the manifest.
- [x] No narrative comment in the three probe files contradicts a landed value — specifically, no
      surviving "All nine rows report `gate=true`", no surviving `|T|=8` / `|T|=10` / `3 -> 1`
      claims for the re-recorded rows, and no surviving "W1-W4 order eight to ten times each".

## Artifacts & Outputs

- `specs/453_restore_bimodaltest_green_and_clear_c6_c9/plans/01_restore-guards-clear-c6-c9.md`
  (this plan)
- `specs/453_restore_bimodaltest_green_and_clear_c6_c9/summaries/01_restore-guards-clear-c6-c9-summary.md`
  (implementation summary, written at completion)
- Modified: `Tests/BimodalTest/TableauConformance.lean`, `Tests/BimodalTest/RegionGateProbe.lean`,
  `Tests/BimodalTest/BoxSpreadProbe.lean`, `scripts/module-invariants-manifest.txt`,
  `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean`

## Rollback/Contingency

Every phase is comment-, docstring-, or manifest-only and each commits independently on green, so
rollback is per-phase `git revert` of that phase's commit with no cross-phase entanglement.

- **If a guard cannot be made green by re-recording alone** (Phase 1 STOP condition): halt, leave
  the partial re-records committed (each was verified green in isolation before commit), and report
  the failing row with its generated-vs-expected pair. Do not touch the engine, probe definitions,
  fuel values, or `#eval` bodies — that would falsify the stale-expectations verdict and belongs to
  a different task.
- **If C6 still fails after the manifest edit**, read which sub-assertion failed. A phantom-entry or
  stale-reachable failure means a module name is misspelled or is in fact reachable; a compile
  failure means the isolation build regressed since the research measurement — in that case add the
  `broken:` prefix only for the specific failing module and record why.
- **If the C9 edit is blocked by the write-time hook**, the replacement text still matches the
  task-number regex. Rewrite it, do not disable the hook.
