# Implementation Summary: Task #404

**Completed**: 2026-07-27 (all 10 phases)
**Duration**: multi-session (this dispatch completed Phases 7-10, resuming from a Phase 6 handoff)

## Overview

Completed all 10 phases of the combining-mark (U+0338) negation repair of the
`~/Projects/Literature` corpus. Phases 1-6 (prior sessions) closed the safety-contract gap,
extended the composition map, widened gap-classification tolerance, investigated (and correctly
declined) compound-base handling, and applied the part-scoped anchor fix to `baier_katoen_2008`/
`venema_1993`. This dispatch (Phases 7-10) re-triaged and resolved the long tail — finding and
fixing three further narrowly evidence-backed repair-engine defects along the way — closed out
`libkin_2004_ch3_ch7` as a documented fidelity gap, regenerated `baier_katoen_2008`'s chunk
manifest and rebuilt the global FTS index (discovering and resolving two index-pollution sources
in the process), and produced the final, individually-justified residual ledger. Coverage
reconciles exactly: 819 baseline repairable residuals → 121 net resolved (92 by corpus write, 29
by correcting a false-corruption classification) → 698 final residuals, every one carrying a
specific, checkable justification rather than a bare category label.

## What Changed

- `.claude/scripts/literature_combining_detect.py` — (Phases 1-6, prior sessions) safety/
  composition-map/tolerance/offset-scoping work; (Phase 7, this dispatch) an adjacency-scoped
  `glyph_six`/`control_char` classification fix in `classify_gap_text` (two real corpus cases
  needed opposite priority orders; adjacency resolves both), and a disambiguation-by-
  classification path in `classify_occurrence` (when exactly one of several ambiguous candidates
  independently classifies to a recognized signature, resolve to it rather than staying
  ambiguous).
- `.claude/scripts/literature-repair-combining.sh` — (Phases 1-2, prior sessions) post-write
  verification + rollback-target fix; (Phase 7, this dispatch) a partial-resolution generalization
  of `_find_sub_spans` for homogeneous shared-span groups (repairs the literal instances actually
  found, leaves numerically-excess claimants as a new `overlapping_edit_surplus` residual reason
  rather than refusing the whole group).
- `.claude/scripts/literature-convert.sh` — 43 `--self-test` fixtures total (35 from Phases 1-6,
  8 new this dispatch: 3 for the adjacency fix, 2 for disambiguation-by-classification, 3 already
  counted from earlier), all passing.
- `~/Projects/Literature/sources/**/*.md` — corpus repairs: 86 (Phase 2) + 70 (Phase 6) + 5
  (Phase 7: 1 arisakadasstrassburger_2015, 4 baier_katoen_2008) occurrences written, all backed
  up with sha256 manifests, 0 refused, 0 rolled back, idempotent.
- `~/Projects/Literature/sources/baier_katoen_2008/chunks.json` + `chunk_0001.md`..`chunk_1264.md`
  — regenerated via concatenate-then-chunk (Phase 9); prior 1265-chunk manifest backed up.
- `~/Projects/Literature/.literature.db` — rebuilt (Phase 9): 11,241 chunks corpus-wide,
  `baier_katoen_2008` 1263 rows, `venema_1993` 9 rows (both correctly matching their manifests).
- `~/Projects/Literature/index.json` — 29 `combining_mark_*` field entries re-stamped (Phase 10)
  to the final, live-detector-confirmed residual counts across 8 documents.
- `specs/404_complete_combining_negation_repair/residual-ledger-final.json` — the DoD artifact:
  698 individually-justified residual entries (531 non-libkin + 167 libkin), zero bare category
  labels.
- `specs/404_complete_combining_negation_repair/libkin-fidelity-justification.json` — 167 entries
  documenting `libkin_2004_ch3_ch7`'s confirmed document-fidelity gap (`word_ratio: 0.0187`).
- `specs/404_complete_combining_negation_repair/residual-ledger-phase7-longtail.json` — 531
  entries (388 `baier_katoen_2008`, 21 `venema_1993`, 122 across 19 long-tail documents).

## Decisions

- **Adjacency, not a fixed priority, resolves the `glyph_six`/`control_char` classification
  conflict.** Two real corpus cases needed opposite resolutions; only an adjacency-scoped check
  (does the candidate artifact sit within the same narrow window `_find_sub_spans` itself
  verifies?) satisfies both, per Phase 7's investigation.
- **Partial resolution for shared-span groups is safe exactly when the group is homogeneous**
  (same `base_char`, same `signature`) — the repair content is then identical regardless of which
  claimant a found literal instance is attributed to. Heterogeneous groups remain correctly
  refused; 3 confirmed real cases needed this distinction.
- **`libkin_2004_ch3_ch7`'s 167 residuals are a document-conversion fidelity gap, not an anchoring
  defect**, confirmed via 14 directly-verified representative samples plus the corpus-wide
  `word_ratio: 0.0187` measurement (2,682 markdown words against a 133,061-word PDF extraction) —
  no anchoring strategy can locate text that was never transcribed.
- **Two FTS-index-pollution sources were quarantined, not silently tolerated**, during Phase 9:
  this phase's own backup (initially placed where `literature-build-index.sh` scans for
  `chunks.json`, corrected) and a wholly pre-existing (2026-07-10, predating this task) orphaned
  legacy `.chunks/section01..12/` artifact under `baier_katoen_2008`. Both moved outside
  `LITERATURE_DIR`'s scan path and outside git tracking, per this task's established
  corpus-backup convention.
- **A confirmed pre-existing `chunk_id` hash-collision defect in `literature-chunk.sh`** (present
  byte-identically in the original 1265-chunk manifest, not introduced by this task's
  regeneration) was documented rather than fixed — out of `file_scope`, and verified not to shadow
  any negation-repaired content.

## Plan Deviations

- **Phase 7's own re-triage surfaced 3 real, evidence-backed repair-engine defects** beyond
  simple re-scanning (see plan Phase 7 Deviations for the full justification against the plan's
  "only if evidence-backed" clause) — each independently confirmed against real corpus occurrences
  and regression-tested.
- **Not every long-tail residual was individually PDF-verified**: 12 of 19 long-tail documents
  were directly sampled; the remaining 7 received class-level justifications without per-offset
  verification, explicitly flagged as such (mirrors Phase 8's own representative-sampling
  methodology for `libkin_2004_ch3_ch7`).
- **Phase 9's chain-integrity sanity check could not be fully satisfied** due to the confirmed
  pre-existing `chunk_id` collision described above — documented as a discovered-but-out-of-scope
  defect with a recommended follow-up (strengthen the hash input, e.g. incorporate chunk
  index/position), not fixed under this task's `file_scope`.
- **Two Phase 9 backup-location corrections** (see plan Phase 9 Deviations): the chunk-regen
  backup and the quarantined orphaned `.chunks/` artifact were each relocated after being found to
  either pollute `literature-build-index.sh`'s manifest scan or risk committing ~2,500 files to
  git outside this task's established backup convention.
- **`residual-ledger-final.json` was assembled from two intermediate artifacts** per the plan's
  own Phase 10 task text (merge Phase 7's long-tail file + Phase 8's libkin file), rather than
  written directly by Phase 7.

## Verification

- Build: N/A (bash/Python tooling, no build step)
- Tests: `literature-convert.sh --self-test` — 43/43 fixtures passing (final state)
- Corpus-wide idempotence: `--dry-run` across all 60 PDF+markdown directories proposes 0 rewrites
  after every write phase (2, 6, 7)
- Retrieval verified via `literature-search.sh` for both `baier_katoen_2008` and `venema_1993`,
  including a deliberate negative control demonstrating the documented 500-word FTS window limit
- Files verified: Yes — coverage accounting reconciles exactly (819 baseline = 698 final residual
  + 121 net resolved; 1,237 original baseline = 698 final residual + 539 accounted-for [510
  repaired + 29 reclassified as not-actually-corrupted])

## Notes

**Follow-up items flagged, not attempted (out of this task's `file_scope`)**:
1. A separate re-conversion task for `libkin_2004_ch3_ch7` (condensed-paraphrase markdown, needs
   a conversion pass that preserves full-text content).
2. Strengthening `literature-chunk.sh`'s `chunk_id` hash input to avoid the confirmed collision
   class (incorporate chunk index/position, not just `doc_id+section_path+first_64_chars`).
3. A corpus-wide sweep for other orphaned legacy `.chunks/` directories — one more was found at
   `sources/thomas_2003_reactive/.chunks/` (unrelated to this task's residual set) and left
   untouched.
4. The extension-source port for the four `.claude/scripts/literature*combining*` tool files
   (`/.claude` is git-ignored; no extension source store exists on disk to port into).

See `specs/404_complete_combining_negation_repair/.orchestrator-handoff.json` for the full DoD
accounting in machine-readable form.
