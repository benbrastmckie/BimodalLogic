# Implementation Summary: Task #915

- **Task**: 915 - Re-convert and re-index reynolds_2001 with sections 5-8 included
- **Status**: [COMPLETED]
- **Started**: 2026-11-10T19:30:00Z
- **Completed**: 2026-11-10T19:47:00Z
- **Effort**: ~45 minutes (plan estimated 3.25 hours; actual was materially lower — see Decisions)
- **Dependencies**: None
- **Artifacts**: plans/01_reynolds-sections-5-8-splice.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Closed the §5-§8 gap in the `reynolds_2001` corpus entry so the Auxiliary Atoms (AA) rule has
a citable primary-source statement. All five plan phases completed. The implementation
diverged from the plan's literal Phase 1 method (a fresh PDF reconversion) after discovering
the target text already existed, verbatim and in house style, inside the existing `sec03` file
— the real cause of the search gap was an FTS indexing limit (500-word preview window), not
missing content. The four new sections were split out of that existing text instead, with
materially lower risk than a fresh conversion + hand-fit would have carried.

## What Changed

- `/home/benjamin/Projects/Literature/sources/reynolds_2001/chunks.json` — 4 new chunk entries
  spliced in (§5-§8); `source_path` updated on 7 renumbered existing entries; chain re-linked
  across the insertion point.
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec04_axiom-system-bundled-trees.md` — new (§5)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec05_limit-closure-axiom.md` — new (§6)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec06_auxiliary-atoms-rule.md` — new (§7, the task's target source statement)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec07_the-theorem.md` — new (§8)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec08_...` through `sec14_...` — 7 existing files renamed (content byte-identical), `sec04`-`sec10` -> `sec08`-`sec14`
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec03_47-equivalence-results-there-are-two-equ.md` — left byte-identical (plan Non-Goal); still physically contains the §5-§8 text in its tail (beyond the FTS preview window), which is now also present as dedicated, independently-searchable chunks
- `/home/benjamin/Projects/Literature/.literature.db` — rebuilt (global FTS5 index), `reynolds_2001` now at 14 indexed chunks (was 10); corpus total 38793 -> 38797
- `specs/literature-index.json` — dated `reindexed` addendum added to the `reynolds_2001` entry; `reason`/`added`/`source`/`citation_rule` left byte-identical

Committed in two separate repositories: `~/Projects/Literature/` (commit `59f97333`, that
repo's own convention) for the corpus changes, and this repository (five `task 915 phase N:`
commits) for the `specs/**` bookkeeping and the `literature-index.json` addendum.

## Decisions

- **Phase 1 extraction method changed from fresh PDF reconversion to direct extraction.**
  While verifying Phase 1's PDF cross-check, discovered that §5-§8's text already existed
  verbatim, in house style (clean `##` headings, bold Lemma/Definition/Theorem markers, no
  spurious bolding), embedded in the tail of the live `sec03_...md` file — past
  `literature-build-index.sh`'s 500-word FTS `content_preview` cutoff, which is the actual
  mechanism behind the reported search gap, not a conversion gap. Extracted the four sections
  by exact line range from that file instead of running `literature-convert.sh` and hand-fitting
  a fresh conversion, eliminating the plan's stated #1 risk (a hand-fitting transcription error)
  entirely, since no new text was authored.
- **`sec03` left fully untouched.** The plan's Non-Goal explicitly scopes `sec01`-`sec03`
  content as byte-identical; honored literally even though this leaves the §5-§8 text
  duplicated (once in `sec03`'s un-indexed tail, once in the four new dedicated chunks). This
  duplication is harmless to every stated acceptance criterion (search, `--toc`, `--read` all
  pass) and avoids destabilizing an already-working, already-indexed existing chunk.
- **Skipped the optional global `index.json` `token_count` refresh.** That file also carries a
  second, chunk-level cache (10 `parent_doc: reynolds_2001` sub-entries distinct from
  `chunks.json`) that would need matching new entries to stay consistent if touched — an
  expansion of change surface the plan's own escape hatch permits skipping.
- **Full gate deferred to the batch stage** per this dispatch's Batch Gate Deferral directive;
  ran the scoped narrowing invocation instead (see Verification).

## Plan Deviations

- **Phase 1** (tasks 1.1-1.5) altered: extracted §5-§8 directly from the live `sec03` file
  instead of running `literature-convert.sh` into scratch and hand-fitting the output. Same
  Phase 1 goal and verification criteria met, lower risk.
- **Phase 5** (task 5.2) skipped: the optional `~/Projects/Literature/index.json` `token_count`
  drive-by refresh, per its own stated escape hatch (see Decisions).
- **Phase 5** (task 5.3) altered: the full gate set (`verify-deploy.sh`) was deferred to the
  batch stage per this dispatch's Batch Gate Deferral directive; the scoped narrowing invocation
  ran instead and passed.

## Verification

- Build: N/A (no Lean/compile step in this task)
- Tests: `bash .claude/scripts/tests/run-all.sh --only test-literature-build-index.sh,test-literature-search.sh` — PASS (run at both Phase 4 and Phase 5)
- Files verified: Yes — `chunks.json` validated (14 entries, 14 distinct `chunk_id`s, all `source_path` resolve, unbroken bidirectional chain); `git diff --stat -M` confirmed 7 pure renames with 0 content change; `literature-search.sh "auxiliary atoms"` returns the new §7 chunk as the top result; `"limit closure axiom"` returns the new §6 chunk as the top result; `--toc reynolds_2001` shows §1-§16 with no gap; `--read` on the new §7 chunk returns the full §7 text; `specs/literature-index.json` validated as parseable JSON with the `reynolds_2001` entry's other fields byte-identical.
- The repository-wide full gate set (`verify-deploy.sh`) is deferred to this `/orchestrate` batch invocation's once-per-batch stage, per the dispatch's Batch Gate Deferral directive, and is attributed back to this task via `modified_files`.

## Impacts

- The forward-cone unravelling line of work (and any future task needing the Auxiliary Atoms
  rule's primary-source statement) can now cite `reynolds_2001` §7, Definition 4, Lemma 6
  directly, rather than relying only on `FormalSystem/Metalogic/NamingRules.lean`'s recorded
  Saturation obligation.
- No other document's corpus coverage was affected (corpus total rose by exactly 4, matching
  the 4 new chunks added).

## Follow-ups

- `~/Projects/Literature/index.json`'s `reynolds_2001` doc-level `token_count` (32665) remains
  stale against the true chunk-sum (now ≈36200 post-splice) and its separate 10-entry
  chunk-level sub-cache under `parent_doc: reynolds_2001` does not yet reflect the 4 new chunks.
  Both are pre-existing staleness classes (research report Finding 8), left untouched per this
  task's own optionality; a future task could resync `index.json`'s chunk-level cache with
  `chunks.json` across the whole corpus (not just this document) if that inconsistency ever
  needs closing.
- `sec03_47-equivalence-results-there-are-two-equ.md`'s file content still physically includes
  the §5-§8 text in its un-indexed tail (and also §4.9, "Emergent branches", which was never
  reflected in its own chunk's `section_path`/`title` either — a pre-existing, independent
  quirk). This is harmless to search/retrieval but is latent redundant storage; not addressed
  here per the plan's explicit Non-Goal.

## References

- Plan: `specs/915_reconvert_reindex_reynolds_auxiliary_atoms_sections/plans/01_reynolds-sections-5-8-splice.md`
- Research report: `specs/915_reconvert_reindex_reynolds_auxiliary_atoms_sections/reports/01_reynolds-sections-5-8-reconversion.md`
- Progress files: `specs/915_reconvert_reindex_reynolds_auxiliary_atoms_sections/progress/phase-{1..5}-progress.json`
- Handoffs: `specs/915_reconvert_reindex_reynolds_auxiliary_atoms_sections/handoffs/phase-{1..4}-handoff-*.md`
- `Literature/` repo commit: `59f97333` ("corpus: splice reynolds_2001 sections 5-8 (LC axiom, AA rule) into chunks.json")
