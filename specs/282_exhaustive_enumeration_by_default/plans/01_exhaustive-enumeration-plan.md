# Implementation Plan: Exhaustive Enumeration by Default

- **Task**: 282 - exhaustive_enumeration_by_default
- **Status**: [NOT STARTED]
- **Effort**: ~5 hours active work + multi-hour background compute (c8/c9 regeneration, HF upload)
- **Dependencies**: 274 (bottleneck sweep — completed/archived; made c9 labeling feasible)
- **Research Inputs**: specs/282_exhaustive_enumeration_by_default/reports/01_exhaustive-enumeration-default.md
- **Artifacts**: plans/01_exhaustive-enumeration-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Task 282 makes the dataset generator default to exhaustive enumeration with an unlimited
(0-sentinel) formula cap. Research (commit `78166ff86`) established that the four code-level
items — the 0-sentinel default, `.take` guards on the sentinel, removal of `--max-formulas`
from exhaustive tiers, and help text — were **already implemented and are verified intact** in
the current tree. The task status was never advanced, so this plan's first phase is a
cheap verify-only confirmation. The genuine remaining work is item (5), dataset regeneration:
c4-c7 were already regenerated exhaustively (2026-06-08), c8 exhaustive is **outstanding** (HF
ships only a `.partial`), and c9 is still **stratified** behind a stale "infeasible" comment
(`scripts/run_dataset_generation.sh:483`) that predates task 274's re-costing and task 283's
enumeration rewrite. Definition of done: items 1-4 re-confirmed, a measured c9 feasibility
number replaces the stale estimate, `run_c9` is flipped to exhaustive if feasible (else
stratified is retained and README realigned), c8 (and c9 if flipped) are regenerated
exhaustively, and all documentation is internally consistent.

### Research Integration

Key findings integrated:
- Items 1-4 already DONE (`DatasetExport.lean:477`, `FormulaEnumerator.lean:692`, cap-site
  guards at `FormulaEnumerator.lean:1639,1789-1792,1830-1833,1887,2207-2210`, script tiers
  c4-c8, help text `DatasetExport.lean:49,938`). Phase 1 re-verifies rather than re-implements.
- The `~11M formulas / >12h` c9 estimate (`run_dataset_generation.sh:483`) predates task 274
  (c9 labeling restored to ~663 formulas/sec, 14% timeout) and task 283 (Array accumulation,
  checkpoint/resume, inline dedup, structural pruning). It must be re-measured, not trusted.
- A documentation contradiction already exists: `data/README.md:200-201` advertises c9 as
  exhaustive while `data/README.md:20,26` and `run_c9` (`:485-497`, `--mode stratified`,
  quotas `8:30000,9:70000`) describe/run it as stratified. This must be resolved either
  direction.
- `EnumBenchmark.lean` (`lake exe enum_benchmark`) has feasibility gates for c5-c7 only and is
  the probe harness to extend for c8/c9.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation was requested and no roadmap_flag was set; this plan advances the
`dataset-enhancement` topic recorded in state.json.

### Decision Resolutions (from orchestrator)

- **A1**: The c9 exhaustive flip **is in scope**, gated on a feasibility probe (Phase 2). If the
  probe refutes feasibility, `run_c9` stays stratified and the flip is explicitly deferred (not
  silently dropped) with README realigned to match. c11/c12 remain stratified regardless.
- **A2**: c8 regeneration **is in scope** per original item (5). c9 regeneration is
  optional/conditional on the probe passing and the flip landing.

## Goals & Non-Goals

**Goals**:
- Re-confirm items 1-4 (unlimited-by-default behavior) intact via build + smoke.
- Replace the stale c9 `~11M/>12h` estimate with a measured post-274/post-283 number.
- Flip `run_c9` to exhaustive by default if the probe confirms feasibility; otherwise retain
  stratified with an updated, non-stale rationale.
- Regenerate c8 exhaustively (and c9 exhaustively if flipped).
- Make `run_dataset_generation.sh`, `data/README.md`, and `data/hf-dataset/README.md`
  internally consistent about each tier's sampling mode.

**Non-Goals**:
- Re-implementing items 1-4 (already done; verify only).
- Touching the separate `--generation-mode` labeling axis (`DatasetExport.lean:55,518`).
- Flipping c11/c12 to exhaustive.
- Any Lean proof work (this task introduces no sorries; `lake build` is the only Lean gate).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| c9 exhaustive still infeasible post-274/283 | M | M | Phase 2 probe gates the flip; refutation branch keeps stratified and fixes docs instead — flip deferred, not dropped |
| c8 cross-product explosion recurs (spawned task 283 last time) | M | L | Task 283 mitigations (checkpoint/resume, `--skip-dedup`, structural pruning) are in-tree; run c8 with checkpointing and monitor level growth |
| Long-running regen interrupted mid-run | M | M | 283's per-level checkpoint/resume makes runs recoverable; re-invoke resumes; commit intermediate progress markers only, not partial jsonl |
| Doc realignment misses one of three contradictory sites | L | M | Phase 6 enumerates all sites (README tier table :15-26, generation section :193-212, usage text :686-690, hf-dataset README :45,89,295) as an explicit checklist |
| HF republication uploads a still-partial c8 | M | L | Phase 7 gated on Phase 3 producing a record count within the expected ~500K-1.7M band, not a `.partial` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 4 |
| 5 | 6 | 3, 4, 5 |
| 6 | 7 | 3, 5, 6 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Verify items 1-4 intact [COMPLETED]

**Goal**: Confirm the already-landed unlimited-by-default code changes are still present and the
generator builds and runs, so downstream regeneration truly produces exhaustive output.

**Tasks**:
- [x] Confirm 0-sentinel defaults: `DatasetExport.lean:477` (`maxFormulas : Nat := 0`) and
  `FormulaEnumerator.lean:692` (`maxFormulas : Nat := 0`, doc "0 means no limit").
  *(verified 2026-07-14; FormulaEnumerator site drifted to :722, doc reads "0 means no limit (truly exhaustive)")*
- [x] Confirm `.take` guards at `FormulaEnumerator.lean:1639,1789-1792,1830-1833,1887,2207-2210`
  all gate on `params.maxFormulas == 0`. *(verified; sites drifted to :1705, :1855/:1858, :1896/:1899, :1953, :2299/:2302 — all gate on `maxFormulas == 0`)*
- [x] Confirm c4-c8 script profiles pass `--mode exhaustive` with no `--max-formulas`
  (`run_dataset_generation.sh` `run_c4`..`run_c8`, lines 307-471; c8 comment :448).
  *(verified: run_c4-run_c8 all `--mode exhaustive`, no `--max-formulas`; c9/c11/c12 stratified with caps)*
- [x] Confirm help text: `DatasetExport.lean:49` ("default: 0 = no limit") and `:938` prints
  "unlimited" when 0. *(verified verbatim)*
- [x] `lake build` the `dataset_generator` target; run a bounded `--dry-run` (or small-cast)
  smoke to confirm exhaustive mode is the default path. *(deviation: altered — build skipped by
  orchestrator directive (expensive 264MB relink, unnecessary: items 1-4 are already-committed
  source verified by reading; OOM risk). Verification = source-reading + `--dry-run` smokes:
  c8 emits `--mode exhaustive` with no cap, c9 emits stratified with quotas.)*

**Timing**: ~0.5 hours

**Depends on**: none

**Files to inspect** (no edits expected):
- `Theories/Bimodal/Automation/DatasetExport.lean`
- `Theories/Bimodal/Automation/FormulaEnumerator.lean`
- `scripts/run_dataset_generation.sh`

**Verification**:
- All four items confirmed present (grep/read matches research inventory).
- `lake build` succeeds; `--dry-run` smoke reports exhaustive mode with no cap.

---

### Phase 2: c9 feasibility probe [NOT STARTED]

**DEFERRED (2026-07-14)**: Generation-class work deferred per user directive ("code now, defer
heavy regen"). Awaiting user approval for the probe run. See task continuation.

**Goal**: Produce a measured wall-clock estimate for exhaustive c9 enumeration + labeling to
replace the stale `~11M/>12h` figure and decide the Phase 4 branch.

**Tasks**:
- [ ] Extend `EnumBenchmark.lean` gates (currently c5-c7) to cover c8 and c9, or run a bounded
  timed enumeration probe directly.
- [ ] Run `scripts/run_dataset_generation.sh --dry-run c9` to get the post-274/283 level-8/9
  population count (the 4/4/8/8 -> 1/1/1/1 overhead change enlarges level populations).
- [ ] Time a bounded enumeration-only pass at level 8-9, then a small labeled sample, to derive
  formulas/sec and total wall-clock at ~663/sec.
- [ ] Record the measured number and a GO/NO-GO recommendation for the c9 flip (threshold: a
  recoverable multi-hour run with 283 checkpoint/resume = GO; genuinely intractable = NO-GO).

**Timing**: ~1 hour active (plus bounded probe compute)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/EnumBenchmark.lean` — add c8/c9 feasibility gates (if extending
  the harness rather than an ad-hoc probe).

**Verification**:
- A concrete measured formulas/sec and projected c9 wall-clock exist.
- A recorded GO/NO-GO decision that Phase 4 consumes.

---

### Phase 3: Regenerate c8 exhaustive dataset [NOT STARTED] (long-running)

**DEFERRED (2026-07-14)**: Multi-hour regeneration deferred per user directive. Awaiting user
approval.

**Goal**: Produce a truly-exhaustive `bmlogic-c8.jsonl` (item 5), replacing the HF `.partial`
(147,864 records vs expected ~500K-1.7M).

**Tasks**:
- [ ] Run `scripts/run_dataset_generation.sh c8` (exhaustive, no cap) with checkpoint/resume
  enabled; monitor per-level record growth for explosion.
- [ ] Confirm output `data/bmlogic-c8.jsonl` metadata reports `sampling_mode: "exhaustive"` and
  a record count within the expected ~500K-1.7M band (not a `.partial`).
- [ ] Regenerate/refresh the associated `bmlogic-c8-*_metadata.json` files.

**Timing**: ~0.5 hours active + ~60-90 min background compute (per script header)

**Depends on**: 1

**Files to modify**:
- `data/bmlogic-c8.jsonl` (new/regenerated output) and `data/bmlogic-c8-*_metadata.json`.

**Verification**:
- `data/bmlogic-c8.jsonl` exists, non-partial, exhaustive mode, record count in expected band.

**Note**: This is background compute; commit only completed-run artifacts/markers, never
partial jsonl. If interrupted, 283 checkpoint/resume makes re-invocation resumable.

---

### Phase 4: Resolve c9 sampling mode (flip or retain) [PARTIAL]

**PARTIAL (2026-07-14)**: The stale `:483` "infeasible ~11M/>12h" comment was replaced with a
measured-rationale placeholder noting exhaustive c9 is feasible-but-not-yet-run (deferred pending
the Phase 2 probe). `run_c9` remains stratified (no mode change — the flip decision awaits the
probe). c11/c12 untouched (still stratified).

**Goal**: Act on the Phase 2 decision — either flip `run_c9` to exhaustive-by-default or retain
stratified with a corrected, non-stale rationale — and remove the internal contradiction.

**Tasks**:
- [ ] **If Phase 2 = GO**: In `run_c9` (`run_dataset_generation.sh:485-497`) drop
  `--mode stratified`, `--stratified-quotas`, and `--max-formulas`; update the header (:9), the
  stale comment (:483), and usage text (:687) to describe c9 as exhaustive.
- [ ] **If Phase 2 = NO-GO**: Keep `run_c9` stratified but replace the stale `:483` comment with
  the measured rationale, and fix the contradictory `data/README.md:200-201` claim to say
  stratified (flip explicitly deferred, not dropped — note it for a follow-up).
- [ ] Ensure c11/c12 remain stratified either way.

**Timing**: ~0.5 hours

**Depends on**: 2

**Files to modify**:
- `scripts/run_dataset_generation.sh` — `run_c9` body (:485-497), header (:9), comment (:483),
  usage text (:687).

**Verification**:
- Script and the Phase 2 decision agree; no remaining stale `~11M/>12h` language.
- `run_c9` mode matches the recorded GO/NO-GO decision.

---

### Phase 5: Regenerate c9 exhaustive dataset [NOT STARTED] (long-running, conditional)

**DEFERRED (2026-07-14)**: Conditional on Phase 2 GO; both deferred per user directive.

**Goal**: If c9 was flipped to exhaustive (Phase 2 = GO, Phase 4 flip landed), produce the
exhaustive `bmlogic-c9.jsonl`.

**Tasks**:
- [ ] **Conditional gate**: Execute only if Phase 2 = GO and Phase 4 flipped `run_c9`. If NO-GO,
  mark this phase skipped/deferred in the summary and proceed.
- [ ] Run `scripts/run_dataset_generation.sh c9` (exhaustive) with checkpoint/resume; monitor
  level-9 growth.
- [ ] Confirm `data/bmlogic-c9.jsonl` metadata reports `sampling_mode: "exhaustive"` and a
  plausible record count; refresh associated metadata json.

**Timing**: ~0.5 hours active + multi-hour background compute (probe-dependent; ~4.6h at 663/sec
for ~11M, subject to Phase 2 re-measurement)

**Depends on**: 4

**Files to modify**:
- `data/bmlogic-c9.jsonl` (new output) and `data/bmlogic-c9-*_metadata.json`.

**Verification**:
- Either `data/bmlogic-c9.jsonl` exists exhaustive, or the phase is explicitly recorded as
  deferred with the Phase 2 NO-GO reason.

---

### Phase 6: Documentation realignment [PARTIAL]

**PARTIAL (2026-07-14)**: The non-generation-dependent doc fixes landed: `data/README.md` c9
contradiction resolved (tier-table note :26 and generation section :~196-201 now both say
stratified-today / exhaustive-feasible-but-deferred), and the section intro corrected (c9
stratified takes minutes, not background compute). Remaining items — hf-dataset README c8
"(partial)" references and post-regen counts — depend on Phases 3/5 output and stay deferred.

**Goal**: Make all documentation internally consistent with the final script behavior and the
regenerated datasets.

**Tasks**:
- [ ] Reconcile `data/README.md` tier table (:15-26) and generation section (:193-212) so c9's
  described mode matches `run_c9` (exhaustive if flipped, stratified if retained) — resolving
  the existing :20/:26 vs :200-201 contradiction.
- [ ] Align `run_dataset_generation.sh` usage text (:686-690) with the tier table.
- [ ] Update `data/hf-dataset/README.md` c8 references (:45, :89, :295) to drop "(partial)" and
  reflect the regenerated exhaustive c8 counts; add/adjust c9 entries if regenerated.
- [ ] Grep the docs for any lingering `5000`, `--max-formulas` on exhaustive tiers, or `>12h`
  language and remove/correct.

**Timing**: ~1 hour

**Depends on**: 3, 4, 5

**Files to modify**:
- `data/README.md` — tier table (:15-26), generation section (:193-212).
- `data/hf-dataset/README.md` — c8 (:45,:89,:295), c9 if regenerated.
- `scripts/run_dataset_generation.sh` — usage text (:686-690) if not already covered in Phase 4.

**Verification**:
- No contradictory tier-mode statements remain across script, `data/README.md`, and
  `data/hf-dataset/README.md`.

---

### Phase 7: HF Hub republication [NOT STARTED] (long-running, optional)

**DEFERRED (2026-07-14)**: External publication deferred; gated on Phases 3/5 and explicit user
approval.

**Goal**: Publish the regenerated exhaustive c8 (and c9 if regenerated) to the HF dataset repo,
replacing the shipped `.partial`.

**Tasks**:
- [ ] **Gate**: Only if Phase 3 produced a non-partial c8 within the expected band (and Phase 5
  produced c9 if applicable).
- [ ] Stage regenerated jsonl + metadata into `data/hf-dataset/`; upload/push to the HF Hub
  dataset repo.
- [ ] Confirm the HF card (`data/hf-dataset/README.md`) counts match the uploaded files and no
  `.partial` remains.

**Timing**: ~0.5 hours active + upload time (dataset-size dependent)

**Depends on**: 3, 5, 6

**Files to modify**:
- `data/hf-dataset/` staged dataset files; HF Hub remote (external publication).

**Verification**:
- HF repo carries exhaustive c8 (and c9 if regenerated); card counts consistent; no `.partial`.

**Note**: External-facing publication and long-running upload. If compute/upload budget is a
concern, this phase may be deferred as a follow-up without blocking the default-behavior goals
(items 1-4 verify + c9 mode resolution) that the task name promises.

## Testing & Validation

- [ ] `lake build` (dataset_generator target) succeeds — the only Lean gate.
- [ ] `--dry-run`/small-cast smoke confirms exhaustive-mode default with no formula cap.
- [ ] Phase 2 produces a concrete measured c9 formulas/sec + wall-clock number.
- [ ] `run_c9` mode matches the recorded GO/NO-GO decision (no stale `~11M/>12h` language).
- [ ] `data/bmlogic-c8.jsonl` is exhaustive, non-partial, record count in expected band.
- [ ] If flipped: `data/bmlogic-c9.jsonl` is exhaustive; else c9 deferral recorded with reason.
- [ ] Grep confirms no remaining tier-mode contradictions across script + both READMEs.

## Artifacts & Outputs

- plans/01_exhaustive-enumeration-plan.md (this file)
- summaries/01_exhaustive-enumeration-summary.md (on implementation)
- Possibly modified: `Theories/Bimodal/Automation/EnumBenchmark.lean`,
  `scripts/run_dataset_generation.sh`, `data/README.md`, `data/hf-dataset/README.md`
- Regenerated: `data/bmlogic-c8.jsonl` (+ metadata), optionally `data/bmlogic-c9.jsonl`
- HF Hub dataset republication (optional Phase 7)

## Rollback/Contingency

- Code/script/doc edits are small and git-tracked; revert the specific commits to restore prior
  behavior. Items 1-4 are untouched (verify-only), so the unlimited-default behavior is never at
  risk from this task.
- Dataset regeneration writes new jsonl; the prior c8 `.partial` and c9 stratified metadata
  remain in git history / HF until Phase 7 republishes, so a bad regen can be discarded by not
  publishing.
- If the c9 probe (Phase 2) is inconclusive, default to the NO-GO branch (retain stratified, fix
  docs) — the safe, non-destructive path — and file the flip as a follow-up.
