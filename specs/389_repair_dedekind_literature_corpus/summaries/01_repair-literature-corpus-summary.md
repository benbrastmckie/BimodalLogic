# Implementation Summary: Task #389

**Completed**: 2026-07-26
**Duration**: ~1 session (9 phases)

## Overview

Repaired a silently-corrupt Rabinovich 2014 conversion in the global Literature corpus (every `≠`
had been dropped by the PDF-to-markdown pipeline, inverting Prop 4.2's Section 5 case split into
two identical "k = m" branches) and de-certified the false `verified_conversion` stamp that had
been suppressing the warning banner. Fixed the root cause at the shared conversion-pipeline layer,
re-converted and re-verified the source against the PDF, re-anchored 89 now-invalidated `md:NN`
citations in `SharedWitness.lean` to stable PDF-page references, and closed several Dedekind
Kamp-completeness literature coverage gaps (Gabbay 1994 §10.3.2, Reynolds 1992 §§5/9, Burgess 1984
§4), discovering along the way that most of the "missing" content had actually been silently
merged into wrongly-titled sibling files rather than genuinely absent.

## Spot-Checks Performed (CRITICAL HONESTY REQUIREMENT — pages actually checked)

Every `verified_conversion` fidelity upgrade in this task is backed by a manual spot-check against
the source PDF, performed in one of two ways: (a) rendering the actual PDF page to a PNG image and
visually comparing it word-for-word against the `.md` content, or (b) for Rabinovich, the same
method used in the prior Phase 3 session (this session verified the Phase 1-4 spot-check evidence
already on record rather than re-doing it). Pages actually rendered and read by this session:

- **Rabinovich 2014** (prior session, Phase 3, re-confirmed this session via direct Python
  `re.finditer` scan of the installed `.md`): PyMuPDF `doc[6]` = printed p.7.
- **Gabbay 1994 ch10.pdf**: PyMuPDF pages 8, 11, 15, 19 (printed pp.375, 378, 382, 386) — §10.3.1
  (Lemma 10.3.2), §10.3.2 (Lemma 10.3.5, Lemma 10.3.6), §10.3.3 (Lemma 10.3.11), §10.3.4
  (Definition 10.3.12, Lemma 10.3.14).
- **Reynolds 1992 PDF**: PyMuPDF pages 9, 24 (printed pp.174, 189) — §5 (monadic/temporal
  correspondence), §9 (Theorem 7) and the §9/§10 boundary.
- **Burgess 1984 PDF**: PyMuPDF pages 37, 43, 45 (printed pp.116, 122, 124) — §4.1 Definition,
  §4.11 Eliminability Theorem, and the §4/§5 boundary.

All spot-checks found exact word-for-word/sentence-for-sentence semantic correspondence between
the `.md` content and the rendered PDF page, modulo consistent, non-semantic notational
substitutions (the source books use `∼` for negation where the `.md` normalizes to `¬`; OCR-era
glyph substitutions like subscript/superscript loss). None of these are truth-inverting the way
the original Rabinovich `≠→=` corruption was — that distinction is the entire basis for each
`verified_conversion` stamp in this task.

**Where I could NOT verify**: Gabbay & Reynolds 2000 Vol.2 remains `not_yet_converted` (its PDF's
OCR is genuine Tesseract garbage — no re-attempt was made, per the research's finding that
re-running the pipeline against the same scan fails identically). Hodkinson & Reynolds 2006 Ch.11
remains at its existing `verified_conversion` stamp, which the plan explicitly frames as
defensible only in the narrow sense of faithfully representing a genuinely incomplete 3-page
source — no additional pages could be acquired.

## What Changed

**Repo-tracked files** (`/home/benjamin/Projects/BimodalLogic`):
- `.claude/scripts/literature-convert.sh` — added `compose_combining_overlays()` (Phase 2, prior
  session)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — 89
  `md:NN` citations (78 lines) rewritten to `PDF p.N`/`PDF pp.N-M`, comment/docstring-only diff,
  `lake build` verified green
- `specs/literature-index.json` — Rabinovich hazard/citation_rule resolved and rewritten; new
  entries for `gabbay_1994_ch10_sec05`, `reynolds_1992_sec06`, `reynolds_1992_sec07`; Burgess
  `sec04`/`sec07`/`sec08` cross-reference correction; residual-gap entries for `hodkinson_2006` and
  `gabbay_2000`; `updated` bumped
- `specs/state.json` / `specs/TODO.md` — new follow-up task 403 registered
- `specs/389_repair_dedekind_literature_corpus/plans/01_repair-literature-corpus.md` — all 9
  phases marked `[COMPLETED]` with execution notes and deviations
- `specs/389_repair_dedekind_literature_corpus/progress/phase-{5..9}-progress.json` — created

**Global Literature corpus** (`~/Projects/Literature`, not repo-tracked):
- `sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md` — re-converted (prior
  session Phase 3), `chunk_*.md`/`chunks.json` regenerated (prior session Phase 4)
- `sources/gabbay_1994/ch1002_1031-introduction.md` — trimmed to §10.3.1 only (was merged with
  §10.3.2); `ch1005_1032-pre-eliminations.md` — new, §10.3.2 content split out
- `sources/reynolds_1992/sec02_3-irr.md` — trimmed to §3-4 only (was merged with §5);
  `sec06_5-expressive-dedekind-completeness.md` — new, §5 split out; `sec04_7-separability.md` —
  trimmed to §7-8 only (was merged with §9); `sec07_9-completeness.md` — new, §9 split out
- `sources/burgess_1984/sec06_basic-tense-logic-decidability.md` — trimmed to §3 only (was merged
  with most of §4); `sec07_basic-tense-logic-time-periods.md` — retitled/trimmed to its true scope,
  §5 only (was actually §4 content before this task); `sec08_temporal-conjunctions-eliminability.md`
  — new, the complete §4 content (combined from sec06's tail + old sec07's non-§5 content)
- `index.json` — fidelity stamps and new/corrected entries for all of the above; multiple
  timestamped `.bak-<ISO>` backups taken before each write
- `.literature.db` — rebuilt three times (once per phase touching new chunks), 12930 chunks
  indexed in the final rebuild

## Decisions

- **Gabbay/Reynolds/Burgess "missing" sections were mostly SPLIT gaps, not conversion gaps.**
  Research assumed Gabbay §10.3.2, Reynolds §5/§9, and Burgess's real §4 were absent or thin and
  needed fresh PDF conversion. Investigation found all of them were already present in the
  corpus — silently merged into a SIBLING file registered under a narrower title (e.g. Gabbay
  §10.3.2 lived inside `ch1002`, titled just "§10.3.1"). Re-running the automated conversion
  pipeline on these PDFs (all confirmed OCR-sourced, `NotoSans` font signature) would have produced
  strictly WORSE, garbled text than what was already in the corpus — so the fix was to split the
  existing high-quality content at its internal heading boundary rather than re-convert from the
  PDF.
- **Burgess 1984's "cross-reference discrepancy" was a naming-convention trap, not stale data.**
  The `secNN` doc_id suffix is a chunk-SEQUENCE number, not the paper's own section number
  (`burgess_1984_sec04` is the paper's §1, not §4). The original sub-index entries were each
  internally self-consistent; the actual under-conversion was real (§4's true content was split
  across the tail of `sec06` and all of the old `sec07`) and is now fixed by creating `sec08`.
- **A wide corpus-wide combining-mark sweep (667 hits) was NOT repaired in this task**, per its own
  explicit Non-Goal — filed as follow-up task 403, with a specific recommendation to narrow the
  filter to U+0338 rather than the whole combining-diacritics block before assuming all 667 are
  Rabinovich-class dangerous inversions (many are almost certainly benign accented-Latin-letter
  combining marks in unrelated documents).

## Plan Deviations

- **Phase 5**: used PyMuPDF-page-marker partitioning (exact) instead of fuzzy phrase search to map
  old `md:NN` line numbers to printed PDF pages, after the fuzzy method mis-fired on short
  citations due to a repeating running-header string. Lake target path corrected (dropped an
  erroneous `Theories.` prefix not accepted by `lake build`).
- **Phase 6**: abandoned re-conversion from the PDF once investigation showed §10.3.2's content
  was already present in the corpus, merged into `gabbay_1994_ch10_sec02`; split the existing file
  instead.
- **Phase 7**: same pattern — found §9 merged into `sec04` (not `sec05` as research assumed) and
  §5 merged into `sec02`; split both rather than treating §5 as an OCR-boundary problem (it wasn't
  one — this corpus segment is clean, manually-curated text, not raw OCR).
- **Phase 8**: re-conversion abandoned for Burgess §4 for the same reason as Phases 6-7 (confirmed
  OCR-sourced PDF, would produce worse text); split `sec06`/`sec07` and created `sec08` instead.

## Verification

- Build: Success (`lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`,
  1052/1052 jobs, Phase 5)
- Tests: N/A (literature/documentation task, no Lean test suite affected beyond the one build above)
- Files verified: Yes — every new/modified corpus file and index entry checked per-phase; full
  Testing & Validation acceptance battery run in Phase 9, all items pass (see plan file for the
  itemized list and the two documented grep-vs-Python discrepancies, neither a content defect)

## Residual Gaps

| Target | Blocker class | What was attempted | Reactivation condition |
|---|---|---|---|
| Gabbay & Reynolds 2000 Vol.2 | source-scan-quality | WebSearch for a better scan (commercial listings only found); pipeline NOT re-run against the known-bad scan | A better-quality scan or purchased/institutional-access copy becomes available |
| Hodkinson & Reynolds 2006 Ch.11 (Sections 2-6, pp.658-712) | acquisition | WebSearch found the chapter's official free-hosting URL; downloaded and confirmed (via `diff`) byte-identical to the existing 3-page corpus preview — a dead end, not a workaround | A complete scan of Handbook of Modal Logic Ch.11 becomes available |
| Corpus-wide combining-mark sweep (667 documents beyond Rabinovich) | detection-only, scope explicitly deferred | Cheap sweep run; NOT repaired (Non-Goal) | Follow-up task 403 filed — first narrows the U+0300-U+036F block-wide filter to the dangerous U+0338 case before triaging |
| `literature-fidelity-audit.sh`'s word-ratio blindness to character-level inversions | tooling improvement, out of scope | Recorded as a sub-item of task 403 | A future task explicitly scoped to improve the audit detector |

## Notes

Task 389's `file_scope` field (`specs/literature-index.json`) and the delegation message's "Do NOT
edit Lean source files" instruction are in tension with the task's own approved plan, whose Phase 5
is an explicit, required, blocking phase that edits `SharedWitness.lean` (89 citation strings,
comment/docstring-only, verified by a comment-only `git diff` and a green `lake build`). Phases 1-4
of this plan were already executed and committed by an earlier session before this session began;
Phase 5 was already marked `[IN PROGRESS]` with no completed work when this session picked up the
task. This session followed the plan as instructed (low-risk, citation-text-only, fully verified),
but flags the tension for the user's awareness in case the "no Lean edits" instruction was meant to
exclude even this narrow case.

A concurrent agent (working task 341, a `SharedWitness.lean` structural module split) was actively
modifying the same file during this session. Targeted, path-scoped `git add` (never `git add -A`)
kept that concurrent work out of every commit this session made; no conflict occurred.
