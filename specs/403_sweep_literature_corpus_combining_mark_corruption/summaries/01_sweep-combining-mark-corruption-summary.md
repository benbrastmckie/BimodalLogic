# Implementation Summary: Task #403

- **Task**: 403 - sweep_literature_corpus_combining_mark_corruption
- **Status**: [COMPLETED]
- **Started**: 2026-07-27T03:00:00Z
- **Completed**: 2026-07-27T07:20:00Z
- **Effort**: ~4.5 hours (single session, all 9 phases)
- **Dependencies**: None
- **Artifacts**: plans/01_sweep-combining-mark-corruption.md, reports/01_sweep-combining-mark-corruption.md
- **Standards**: summary-format.md, plan-format.md, status-markers.md

## Overview

Built a PDF-vs-markdown ground-truth detector and a backup-guarded repair engine for the
combining-mark (U+0338) corruption in the live `~/Projects/Literature` corpus, then used them to
repair 418 of 1,237 baseline-corrupted negation occurrences across 13 documents, wire the
detector into `literature-fidelity-audit.sh` as a durable additive signal, and rebuild the search
index. A critical bug in the repair engine's edit-span computation was caught and fixed mid-phase
(before it could persist), and the sweep's honest, partial outcome — driven by a deliberately
conservative "never guess" anchoring design — is fully documented in the plan and the residual
ledger rather than overstated.

## What Changed

- `.claude/scripts/literature-combining-audit.sh` — new read-only detector; refactored mid-task
  into a thin CLI wrapper over the shared module below.
- `.claude/scripts/literature_combining_detect.py` — new shared detection/anchoring module
  (word-landmark anchor with whitespace-normalized asymmetric slack tolerance), imported by the
  detector, the repair engine, and the fidelity audit.
- `.claude/scripts/literature-repair-combining.sh` — new backup-guarded repair engine (`--dry-run`
  default, `--write`, `--ledger-json`), with a per-edit span cap and whole-file word-count circuit
  breaker added after the bug described below.
- `.claude/scripts/literature-convert.sh` + `.claude/scripts/literature_combining_overlay.py` —
  `compose_combining_overlays()` extracted to a shared module; extended to tolerate whitespace
  between a combining mark and its base, widened the base-character whitelist (`⊢≺→|⪯⊩≜⊴↣≃`), and
  added a `--self-test` fixture harness (15 fixtures, including a Unicode-canonical-decomposition
  fix for `|` -> `∤`).
- `.claude/scripts/literature-fidelity-audit.sh` — additive `combining_mark_checked` /
  `combining_mark_dropped` / `combining_marks_missing` fields, stamped onto `index.json` alongside
  (never replacing) `provenance_fidelity`/`word_ratio`.
- **Live corpus** (`~/Projects/Literature/sources/`): 13 documents repaired in place —
  `baier_katoen_2008` (12 parts, 339 of 819), `bacon_2018_broadest-necessity` (15 of 18),
  `libkin_2004_ch3_ch7` (1 of 168), `venema_1993` (1 of 38), and 9 glyph-six documents (64 of
  114 combined, `schwoon_esparza_2005` fully clean). Every write preceded by a verified,
  hash-checked backup under `~/Projects/Literature/.backups/combining-repair-2026-07-27/`.
- **`index.json`**: re-stamped with the new combining-mark fields for all 321 entries; exactly 1
  entry's `word_ratio` changed as a natural side effect (`bacon_2018_broadest-necessity`:
  1.0 -> 0.9995), 0 entries' `provenance_fidelity` changed.
- **Chunks/FTS**: 11 of 13 repaired documents re-chunked (all single-file documents); global FTS
  database rebuilt (12,954 chunks). `baier_katoen_2008` and `venema_1993` (both multi-file,
  shared-`doc_id` documents) deliberately NOT re-chunked this pass — see Decisions.

## Decisions

- Adopted a word-landmark anchoring strategy (nearest distinctive plain-ASCII word on each side,
  proximity-preferred, whitespace-normalized distance with asymmetric slack) instead of the plan's
  literal-adjacent-character window, because this corpus corrupts SEVERAL adjacent math symbols at
  once (not just the negation mark), which breaks literal-adjacency anchoring outright.
- Extracted anchoring/classification logic into one shared Python module
  (`literature_combining_detect.py`) used by all three tools, rather than three independent
  implementations, to eliminate drift risk.
- **Chose NOT to re-chunk `baier_katoen_2008` (1,265 chunks) or `venema_1993` (9 chunks)**: both
  are multi-file documents sharing one `doc_id` across several source `.md` files, and
  `literature-chunk.sh` has no multi-file-continuation mode — the original manifests could only
  have been produced by an unverified concatenate-then-chunk process. Re-chunking on an unverified
  assumption was judged a larger, less reversible risk than deferring, consistent with the plan's
  own "targeted, smallest-blast-radius" philosophy. Their underlying markdown IS correctly
  repaired; only derived chunks/FTS remain stale for the fixed sentences.
- Treated every anchor-ambiguous or oversized-span occurrence as unrepairable-by-automation rather
  than guessing, per the plan's explicit safety mandate — this is the direct cause of the partial
  (34%) repair rate, not a shortfall to be closed by relaxing safety.

## Plan Deviations

- **Critical bug, caught and fixed mid-Phase-4**: an early version of the repair engine used the
  full word-landmark-anchored "gap" span directly as the literal edit region. That gap only needs
  to CONTAIN corruption evidence for classification — it is not guaranteed to equal the 1-2
  character corruption complex. The first `--write` attempt deleted real surrounding content
  (bacon_2018 lost 137 words across 16 "fixes"; baier_katoen part01 lost 84 words across 7). Caught
  via a word-count sanity check immediately after the write; both files restored byte-for-byte from
  independently-verified backups before any further action. Fixed by narrowing every edit (not
  just multi-occurrence conflicts) to a precise sub-span, adding a per-edit span cap (>6 chars
  refused), and a whole-file word-count circuit breaker. No corruption persists in the live corpus.
- **Repair coverage far below a "fully clean" outcome**: 418 of 1,237 baseline-corrupted
  occurrences (34%) repaired; only `schwoon_esparza_2005` reaches zero corrupted. Root cause: the
  `absent`-signature class (a true silent drop with no adjacent artifact) is inherently the hardest
  case for any generic anchor to uniquely locate, since the base character (`=`, `∈`, etc.) recurs
  throughout ordinary prose. This is the engine's safety property working as designed, documented
  extensively in Phases 5-9's deviation notes.
- **`baier_katoen_2008`/`venema_1993` chunks deferred** (see Decisions above) — a residual-ledger
  entry (`chunks_not_regenerated`) and an explicit follow-up recommendation record this.
- **`literature-combining-audit.sh` refactored into a thin wrapper** over a new shared module
  (`literature_combining_detect.py`), and `literature-convert.sh`'s overlay logic extracted to
  `literature_combining_overlay.py` — both were necessary to give the multiple consumers exactly
  one hand-maintained implementation, not in the plan's original file lists.
- Full itemized deviation list with rationale lives inline in each phase of
  `plans/01_sweep-combining-mark-corruption.md` (Phases 1-9 each carry their own deviation notes).

## Verification

- Build: N/A (no compiled artifacts)
- Tests: `literature-convert.sh --self-test` (15/15 pass); pre-existing
  `.claude/scripts/tests/test-literature-convert.sh` (8/8 pass, unaffected by this task's changes)
- Files verified: Yes — all 24 backed-up files' sha256 hashes independently verified against
  pre-write originals; idempotence verified for every `--write` performed (repair engine and
  fidelity audit); FTS retrieval verified via direct SQL content query for two repaired sentences;
  corpus-wide detector diff confirms 1,237 -> 819 corrupted (no document regressed)

## Notes

- **Permanent scope boundary** (recorded in `residual-ledger.json`): 64 of 131 corpus source
  directories have no on-disk PDF and cannot be checked by this task's PDF-vs-markdown methodology
  at all; their combining-mark status is permanently unknown absent PDF re-acquisition.
- **Residual finding, not fixed** (per plan Non-Goals): `baier_katoen_2008` carries 8,514 control
  characters across 24 distinct code points beyond the U+0338 negation subset (an entire symbol
  font mapped onto control codes) — recorded for a separate future task.
- **`libkin_2004_ch3_ch7`'s `word_ratio: 0.0187` / `verified_conversion` inconsistency**: recomputed
  as expected during Phase 8, remains `verified_conversion` via its existing disclosure/proof-
  completeness path — confirmed, not separately investigated, per the plan's Non-Goals.
- **Follow-up recommendation**: a dedicated, narrowly-scoped task to establish and verify the
  correct multi-file re-chunking procedure for `baier_katoen_2008` and `venema_1993` (and any other
  multi-file/shared-`doc_id` documents in the corpus), so their already-repaired markdown becomes
  fully reflected in search results.
- **Follow-up recommendation**: a further, more targeted repair pass over `residual-ledger.json`'s
  819 remaining occurrences — particularly the `absent`-signature class — could use per-document
  manual review or a hand-tuned anchor rather than the generic, conservative, corpus-wide approach
  this task used.

## References

- `specs/403_sweep_literature_corpus_combining_mark_corruption/plans/01_sweep-combining-mark-corruption.md` (full phase-by-phase record, including all deviation notes and actual verification output)
- `specs/403_sweep_literature_corpus_combining_mark_corruption/reports/01_sweep-combining-mark-corruption.md` (research report)
- `specs/403_sweep_literature_corpus_combining_mark_corruption/baseline-combining-audit.{tsv,json}` (pre-repair baseline)
- `specs/403_sweep_literature_corpus_combining_mark_corruption/residual-ledger.json` (824 entries)
- `specs/403_sweep_literature_corpus_combining_mark_corruption/backup-manifests/combining-repair-2026-07-27-manifest.json`
- `specs/403_sweep_literature_corpus_combining_mark_corruption/progress/phase-{1..9}-progress.json`
