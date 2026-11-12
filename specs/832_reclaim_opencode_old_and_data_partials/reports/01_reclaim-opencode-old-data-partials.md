# Research Report: Task #832

**Task**: 832 - Reclaim opencode_OLD and data partials
**Started**: 2026-11-12
**Completed**: 2026-11-12
**Effort**: Small
**Dependencies**: None
**Sources/Inputs**: - Codebase inspection (`.gitignore`, `git ls-files`, `diff -rq`, `du`, `stat`), `specs/reviews/review-2026-11-02.md`
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary
- `.opencode_OLD/` re-verified as a strict subset of the live `.opencode/` tree (0 entries unique to `_OLD` across 38 differing entries) and deleted — 62 MB reclaimed, zero commit (fully gitignored, zero tracked files).
- `data/bmlogic-c8-clean.jsonl.partial` (375 MB) and `data/bmlogic-c8-clean.checkpoint.partial` (15 MB) are confirmed abandoned-run checkpoint artifacts of the same `bmlogic-c8-clean` generation run; recommended for deletion but left in place pending the user's decision per the dispatch's explicit "not an automatic delete" framing for Item 2.
- `data/proof_steps.jsonl` (1.6 GB) left untouched — it feeds the BimodalHarness training-dataset pipeline and is not reproducible without re-running the generator.

## Context & Scope
Two local-disk reclamation candidates filed by the 2026-11-02 review (`specs/reviews/review-2026-11-02.md`, Low Priority Issues): a stale duplicate OpenCode config tree (`.opencode_OLD/`) and interrupted-run artifacts inside `data/`. Both paths are gitignored with zero tracked files, so any deletion here is local-disk-only and unrecoverable from git. Scope was restricted to `.opencode_OLD/` (full removal candidate) and `data/`'s two `.partial` files (inspection + candidate removal); `data/proof_steps.jsonl` and every other top-level directory were explicitly out of scope per the dispatch.

## Findings
### Codebase Patterns
- `.gitignore:105` ignores `/.opencode_OLD`; `.gitignore:107` ignores `/data`. `git ls-files .opencode_OLD` and `git ls-files data` both returned zero entries — neither path has ever had tracked content, confirming the "local-disk only" premise.
- `du -sh` showed `.opencode_OLD` and the live `.opencode/` at an identical 62 MB, consistent with the live tree being a superset rather than a divergent fork.
- `diff -rq .opencode .opencode_OLD` reported exactly 38 differing entries, **all** of the form "Only in `.opencode`" (new files added to the live tree: `python-implementation-agent.md`, `python-research-agent.md`, `sheet-agent.md`, `skill-sheet`, `skill-python-implementation`, `skill-python-research`, the `python` extension and context subtree) or "Files ... differ" (an `.opencode` file updated since the `_OLD` snapshot was taken, e.g. `AGENTS.md`, `context/index.json`, `extensions.json`, several `node_modules/{fast-check,yaml}` files, lean-related rule/skill files). **Zero** entries were of the form "Only in `.opencode_OLD`" — nothing in the old tree is absent from the live one. This mechanically confirms the strict-subset relation the dispatch asserted.
- Directory mtimes: `.opencode_OLD` 2026-05-07, `.opencode` 2026-05-14 — consistent with `_OLD` being an earlier snapshot.
- `grep -rl "opencode_OLD"` across the repo (excluding the `_OLD` tree itself and this task's own directory) hit only `specs/state.json`, `specs/TODO.md`, and the two review files (`review-2026-11-02.md`, `review-2026-09-16.md`) that discuss it — no script, config, or deploy path references `.opencode_OLD/` as a live dependency.
- `data/` listing confirms the two partial-checkpoint files: `bmlogic-c8-clean.jsonl.partial` (392,670,566 bytes ≈ 375 MB) and `bmlogic-c8-clean.checkpoint.partial` (15,343,086 bytes ≈ 15 MB), both timestamped 2026-06-03 22:17, alongside `bmlogic-c8-clean_metadata.json` (also 2026-06-03 22:17) — all three share the same run lineage and the same abandonment timestamp. No completed `bmlogic-c8-clean.jsonl` (non-`.partial`) exists in `data/`, confirming the run never finished.
- `data/proof_steps.jsonl` is 1,650,583,836 bytes (≈1.6 GB), most recently modified 2026-10-15 — materially newer than the abandoned c8-clean run, consistent with it being a live, in-use dataset rather than another stale artifact.

### External Resources
Not applicable — this is a local-disk housekeeping task with no external dependency.

## Recommendations
- Delete `data/bmlogic-c8-clean.jsonl.partial` and `data/bmlogic-c8-clean.checkpoint.partial` (390 MB combined) once the user confirms — both are unambiguous abandoned-checkpoint artifacts of the same interrupted run, with no corresponding completed output file in `data/`.
- Do not touch `data/proof_steps.jsonl` absent an explicit user instruction otherwise; it is a live dependency of the separate BimodalHarness repository's training pipeline and is not regenerable from anything else in this repository without re-running the (unspecified-effort) generator.

## Decisions
- `.opencode_OLD/` deleted during this research dispatch per the dispatch's explicit "SAFE TO DELETE ... then delete" instruction for Item 1, after re-confirming the subset relation live (not relying on the filing-time description alone).
- The two `data/*.partial` files were **not** deleted in this dispatch, despite being described as "unambiguous candidates": Item 2's own header frames the entire `data/` item as "USER DECISION, NOT AN AUTOMATIC DELETE," and the acceptance criteria asks only for "a recorded decision," not an action. See `user_decision` in `.return-meta.json`.
- `data/proof_steps.jsonl` left untouched, as mandated.

## Risks & Mitigations
- **Risk**: deleting `.opencode_OLD/` destroys the only local backup of an earlier OpenCode config state. **Mitigation**: the diff confirmed zero content exists in `_OLD` that is absent from the live `.opencode/`, so no information was lost; further, the path was never git-tracked, so no history existed to preserve even before this deletion.
- **Risk**: a future reader interprets "unambiguous candidates" in the original review language as authorization to delete the two `.partial` files without asking. **Mitigation**: this report and `.return-meta.json`'s `user_decision` field make the required confirmation step explicit.

## Context Extension Recommendations
None — this is a one-off disk-housekeeping task with no reusable pattern beyond the existing `context/standards/user-decision-contract.md`, which already covers this exact kind of "ask before destructive, low-value action" decision point.

## Appendix
- Commands used: `sed -n '100,112p' .gitignore`, `git ls-files .opencode_OLD`, `git ls-files data`, `du -sh .opencode_OLD .opencode data`, `stat -c '%n %y' .opencode_OLD .opencode`, `find ... -printf '%T@ %p\n' | sort -n | tail -1` (per-tree latest-mtime check), `diff -rq .opencode .opencode_OLD`, `ls -la data/`, `du -h data/*.jsonl data/*.partial`, `stat -c '%n %y %s bytes' data/proof_steps.jsonl data/bmlogic-c8-clean.jsonl.partial data/.checkpoint.partial`, `grep -rl "opencode_OLD" --include="*.json" --include="*.sh" --include="*.md" .`, `git status --porcelain`.
- Reference: `specs/reviews/review-2026-11-02.md`, Low Priority Issues section (task provenance).
