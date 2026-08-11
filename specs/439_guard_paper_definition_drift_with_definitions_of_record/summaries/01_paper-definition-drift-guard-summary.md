# Implementation Summary: Task #439

- **Task**: 439 - guard_paper_definition_drift_with_definitions_of_record
- **Status**: [COMPLETED]
- **Started**: 2026-08-11T00:00:00Z
- **Completed**: 2026-08-11T00:30:00Z
- **Effort**: ~2.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_paper-definition-drift-guard.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This task did not author `specs/paper-definitions-of-record.md`, `scripts/check-paper-definitions.sh`,
or the task-424 description rewrite — a prior research dispatch had already produced all three,
uncommitted. The work here was **independent verification**: every claim the research agent
self-reported was re-derived from scratch (never trusted as evidence), and a genuinely live
tracked-anchor drift was caught and corrected mid-verification, then the deliverables were
committed. Six phases executed as planned; one real correction was applied (Phase 5); everything
else closed clean with recorded evidence.

## What Changed

- `scripts/check-paper-definitions.sh` — unchanged (audited, no defect found; already correct).
- `specs/paper-definitions-of-record.md` — corrected: `thm:occurrence` renamed to `cor:occurrence`
  (the paper itself renamed and merged the anchor mid-verification), `thm:extension`'s
  cross-referencing footnote re-hashed to match, the manifest updated, the provenance table
  re-pinned to the new live checksum/line count (`485aa764...` / 3999 lines), and a new "Drift
  correction" subsection added documenting the event, the fix, and a known downstream consequence
  (see below).
- `specs/state.json` / `specs/TODO.md` — not modified by this task. Task 424's dependency edge
  (`[361, 414]`) was independently audited and **kept** (see "424 edge verdict" below); no
  correction was needed, so no write was made.
- `specs/439_guard_paper_definition_drift_with_definitions_of_record/summaries/01_paper-definition-drift-guard-summary.md` — this file, new.

## Decisions

- **424 edge verdict: KEEP `[361, 414]`.** The warrant was independently confirmed by reading
  `FormalSystem/Semantics/Truth.lean:128` directly (`TruthAt` does take an explicit
  `Omega : Set (WorldHistory F)` parameter; `Box` quantifies over `σ ∈ Omega`), the governing
  design document (`specs/archive/361_.../design/02_compactness-route.md`, whose representation
  theorem states `Ω := Omega` directly against that parameter), and task 414's own description
  (chartered explicitly to "eliminate the Omega parameter from the semantics core"). A full-graph
  cycle scan confirmed adding the edge introduces no cycle (424 is not reachable from 414;
  414's own dependencies are `[420, 438]`, matching the plan's hypothesis exactly). The
  pre-rewrite vs post-rewrite diff of 424's description was reviewed and found to preserve the
  original scope, gate contract, cancel condition, and acceptance criteria verbatim (only the
  governing-design-document path was corrected, from the pre-archive to the post-archive
  location, which was independently confirmed to exist on disk).
- **A genuine tracked-anchor drift was found and corrected, not just the pre-recorded dirty-pin
  wave.** While Phase 1-3 verification was in progress, the live paper moved twice more (checksum
  `efe6fc74...` (recording) → `645018ae...` (mid-verification) → `485aa764...` (final, stable)),
  and one of those live edits renamed `\label{thm:occurrence}` to `\label{cor:occurrence}`,
  merging it with a separate `app:nonempty` corollary into a strictly stronger statement. This is
  exactly the failure mode the lint exists to catch, and it was caught: the live no-argument run
  correctly reported case (c) (FAIL, exit 1) before correction. The record was corrected (anchor
  renamed, text and hash updated, provenance re-pinned) and the live run now reports case (a)
  (silent pass, exit 0).
- **`--against <recorded base commit>` now reports a (correctly explained) case (c) for
  `cor:occurrence`/`thm:extension`.** Because the rename is an uncommitted edit in the paper's
  working tree, checking the corrected (post-rename) record against the pre-rename base commit
  necessarily disagrees on that one anchor. This is documented explicitly in the record's new
  "Drift correction" section as an expected consequence of the dirty-pin design, not a defect —
  the checksum (re-pinned), not the base commit, remains the authoritative pin.

## Plan Deviations

- None (implementation followed plan). The plan's own risk table anticipated exactly this
  scenario ("A tracked anchor genuinely drifted since recording") and its Phase 5 mitigation was
  applied as written.

## Verification

- **Phase 1 (three-outcome contract)**: `bash -n` exits 0; script executable; lives in `scripts/`
  not `.claude/scripts/`. `filter_noncomment_keep_ln` confirmed applied to the `env` label search,
  `env` end-marker search, and `aitem` content search by direct call; the `item` content search
  uses an equivalent inline filter (`grep -v -E '^[[:space:]]*%'`) rather than calling the named
  helper — functionally identical, not a defect, but the research report's phrasing ("applied to
  all three resolvers... item's and aitem's content search") is slightly imprecise about which
  site calls the shared function by name versus an inline equivalent. Case (b) reproduced against
  the recorded base commit (exit 0, notice, "18 recorded definitions... unchanged"). Case (c)
  reproduced against `c3da9852` (exit 1, exactly 6 drifted anchors + 3 unresolvable, matching the
  plan's scope hypothesis precisely: `def:frame` + its 4 axiom sub-anchors + `def:world-history`
  drifted; `def:temporal-order`, `def:task-relation`, `def:directed` unresolvable). The `%% OLD:`
  comment-filter regression was probed directly (`--resolve` on `def:frame#Compositionality`
  against `c3da9852`) and confirmed to return live axiom text, not the shadowing comment. The live
  no-argument run (before correction) unexpectedly returned case (c) — real drift, handled in
  Phase 5.
- **Phase 2 (anchor resolution / manifest consistency)**: All 18 manifest rows independently
  re-resolved via `--resolve`; 17 matched immediately, 1 (`thm:occurrence`) mismatched (the same
  drift found in Phase 1). The manifest's actual composition is **12 `env` + 4 `item` + 2
  `aitem` = 18**, not the plan's stated scope hypothesis of "13 env, 4 item, 2 aitem" (which is
  also internally inconsistent — 13+4+2=19≠18); this is recorded as the actual count per the
  plan's own instruction to report observed counts rather than adopt stated ones. Every env/aitem
  `\label`/`\aitem` name independently confirmed present in the live paper via direct `grep`
  (bypassing the script). Every prose entry's quoted `sha256:` line cross-checked against its
  manifest row (all 18 matched) and, further, every quoted verbatim `latex` block was independently
  re-hashed in Python and confirmed to self-produce its claimed sha256 (all 12 env blocks
  confirmed). Every "cover at minimum" item from the task description mapped to a specific
  tracked anchor.
- **Phase 3 (provenance / satisfiability / invocation decision)**: All three provenance fields
  (commit SHA, checksum, line count) present in both the table and the sentinels. Dirty-pin
  caveat confirmed to name the checksum as authoritative and disclaim SHA-to-content
  byte-identity. Exhaustive case-insensitive `satisfiab` grep over the live paper returned 5 hits,
  every one individually inspected and confirmed to be informal prose (a comment gloss, a sea
  battle example, and a HyperLTL related-work discussion) — no `\label`led definitional clause
  exists; the gap claim is sustained. The Lean `satisfiable`/`SatisfiableAbs`/`FormulaSatisfiable`
  line numbers (129/138/154) were independently confirmed exact. The skill-preflight-vs-git-hook
  invocation decision is recorded with a stated choice (skill preflight, not a git hook, with the
  git-hook option explicitly rejected and reasoned) and an explicit out-of-scope marker.
- **Phase 4 (424 audit)**: see "Decisions" above — full diff review, cycle scan, and warrant check
  all independently reproduced with matching results.
- **Phase 5 (corrections)**: `thm:occurrence`→`cor:occurrence` rename applied with freshly-derived
  hashes; `bash -n` and all three outcome cases re-run clean after the edit; the full lint
  (no-argument invocation) re-run and confirmed case (a), exit 0.
- **Phase 6 (non-goal audit)**: paper repository's `git status --porcelain` path set and `git log
  -1` HEAD confirmed byte-identical to a baseline captured at the start of this session (the
  file's *content* moved twice during the live-paper wave described above — an external edit
  this task did not make — but the set of dirty/untracked paths and the commit history are
  unchanged, and no commit was created there). This repository's working-tree diff confirmed to
  touch no path under `FormalSystem/`, `latex/`, `typst/`, or `.claude/`. `scripts/check-paper-definitions.sh`
  confirmed to carry no task-number citation. Script placement confirmed to remain `scripts/`,
  with no duplicate under `.claude/scripts/`.
- Build: N/A (no Lean/build-affecting changes).
- Tests: the lint's own three-outcome contract is its test suite; all three outcomes reproduced
  with verbatim recorded output (see above).
- Files verified: Yes.

## Impacts

- `specs/paper-definitions-of-record.md` and `scripts/check-paper-definitions.sh` are now
  independently verified and committed, available for the `paper-refactor` cluster and task 424
  to cite instead of the paper directly.
- The live-paper drift caught and corrected here (thm:occurrence → cor:occurrence) means any
  existing task description that cites `\ref{thm:occurrence}` by that name against the paper
  directly (rather than against this record) is now citing a retired label. Fixing those
  citations is out of scope for this task (non-goal: do not perform paper-refactor cluster work)
  and is left for whichever task next touches that vocabulary.

## Follow-ups

- None required for this task's own scope. Optionally: a future task could grep other task
  descriptions in `specs/state.json` for stale `thm:occurrence` citations now that the paper has
  renamed the anchor, but that is paper-refactor cluster work, explicitly out of scope here.

## References

- Plan: `specs/439_guard_paper_definition_drift_with_definitions_of_record/plans/01_paper-definition-drift-guard.md`
- Research report: `specs/439_guard_paper_definition_drift_with_definitions_of_record/reports/01_paper-definition-drift-guard.md`
- Record file: `specs/paper-definitions-of-record.md`
- Lint script: `scripts/check-paper-definitions.sh`
