# Implementation Plan: Task #404

- **Task**: 404 - complete_combining_negation_repair
- **Status**: [IMPLEMENTING]
- **Effort**: 16 hours
- **Dependencies**: None (the preceding sweep task is COMPLETED; its residual ledger is an input artifact)
- **Research Inputs**: specs/404_complete_combining_negation_repair/reports/01_combining-negation-repair.md
- **Artifacts**: plans/01_combining-negation-repair.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Drive the combining-mark (U+0338) negation repair of the `~/Projects/Literature` corpus from 34%
coverage toward the task's definition of done: every residual occurrence either repaired and
verified, or carrying an individually-justified, human-reviewable reason checkable against its
cited PDF offset. The 819 repairable residuals are not one problem — they decompose into five
disjoint root causes with five different fixes (composition-map gaps, gap-classification
tolerance, a compound-base blind spot in `find_base`, an un-scoped cross-file anchor search on
multi-file documents, and one document whose markdown is a condensed paraphrase rather than a
transcription). Phases follow those root-cause boundaries, each ending in a bounded, backed-up,
verified corpus write. Scope is the live corpus under `~/Projects/Literature/sources/`,
`~/Projects/Literature/index.json`, and the four deployed `.claude/scripts/literature*combining*`
tool files; the non-negotiable safety contract (backup-first with sha256 manifest, precise
sub-span edit regions, per-edit cap, whole-file circuit breaker, `--dry-run` default,
idempotence, refuse-rather-than-guess) is carried forward unchanged and is itself audited in
Phase 1.

### Research Integration

The research report's root-cause table, its recommended phase order, and its two document-specific
findings (baier_katoen_2008 part-file scoping; libkin_2004_ch3_ch7 fidelity gap) are the backbone
of this plan. All of its headline counts were re-verified against the live ledger and corpus
during planning and hold exactly. Three refinements emerged from that verification and are
incorporated below rather than inherited:

1. **The composition-map gap is sharper than reported.** All 13 `unmapped_base_char` entries are
   `≈` (U+2248) — 13/13, not the "12 of 13 sampled" the report states — and a further 7
   `unrecognized_gap` entries also carry `base_char: "≈"`. Because `classify_gap_text` accepts
   either the literal base char *or* its `PRECOMPOSED` replacement in the gap, adding `≈ -> ≉`
   plausibly clears up to 20 occurrences, not 13.
2. **`unrecognized_gap` splits four ways, not two.** Its 69 entries by `base_char` are: `=` 24,
   `|` 12, `∈` 11, `≈` 7, `⊩` 4, `T` 2, `≺` 2, `≜` 2, `↣` 2, `L` 1, `C` 1, `⊆` 1. Critically,
   `=`, `∈`, `≺`, and `⊆` are **already present** in `PRECOMPOSED` — so those 38 are genuinely
   gap-window/tolerance failures and confirm the report's tolerance hypothesis. `≜` and `↣` have
   **no precomposed negated form in Unicode at all**, which is a policy question the report did
   not surface. `T`/`L`/`C` (4 entries) are letters, i.e. `find_base` misidentification, almost
   certainly the same `|=` compound-base family.
3. **venema_1993 very likely needs no re-chunking.** Its `chunks.json` holds 9 entries whose
   `source_path` values point *directly at* the `secNN_*.md` section files the repair engine
   edits (there are no `chunk_*.md` files in that directory), and `literature-build-index.sh:171`
   reads FTS content from `manifest_dir/source_path`. So repairs to venema's section files
   propagate to FTS by rebuilding the index alone. baier_katoen_2008 is the opposite case: 1,265
   separate `chunk_NNNN.md` files holding copied content, which genuinely must be regenerated.
   This collapses the "two multi-file re-chunking blockers" into one, and answers the report's
   open question about venema in the direction it suspected.

A fourth verified detail constrains the final verification phase: `literature-build-index.sh`
stores only the **first ~500 words** of each chunk file in the FTS `content` column. baier's
chunks (~481 tokens) fall entirely inside that window; venema's section files (~1,500-3,000 words)
do not. Retrieval verification must sample repaired sentences that fall within the first 500 words
of their chunk or it will report false failures.

### Prior Plan Reference

No prior plan for this task. The preceding sweep task's plan and summary informed the safety
contract carried forward here (notably: an earlier engine build used an over-wide anchor span as
its literal edit region and deleted 137 words from one document and 84 from another before being
caught and rolled back from backup — which is why every phase below writes only via
`_find_sub_spans`-narrowed regions, and why each write phase is its own rollback boundary).

### Roadmap Alignment

No ROADMAP.md consulted (no `roadmap_path` in delegation context).

### Residual Accounting (re-derived from the live ledger during planning)

824 ledger entries = 819 repairable + 5 notes. Root-cause partition of the 819:

| Root cause | Count | Where | Fix class | Phase |
|---|---|---|---|---|
| Composition-map gap: `≈` (U+2248 -> U+2249), `⊩` (U+22A9 -> U+22AE) | 13 + 11 | corpus-wide | Config: extend `PRECOMPOSED` | 2 |
| No precomposed Unicode negation exists: `≜`, `↣` | 4 | corpus-wide | Policy: emit `base + U+0338` sequence | 2 |
| Gap-window/whitespace tolerance, base already mapped: `=`, `∈`, `≺`, `⊆` | 38 | corpus-wide | Config: widen `classify_gap_text` | 3 |
| Compound base `\|=` plus letter-base misidentification (`T`/`L`/`C`) | 16 | mostly baier | New logic in `find_base` | 4 |
| Un-scoped cross-file anchor search on multi-file documents | ~460 | baier 426, venema 25 | New logic: PDF-offset -> file resolution | 5, 6 |
| Engine-side edit collisions: `overlapping_edit`, `narrow_failed` | 23 | mostly baier | Re-triage after 2-6 land | 7 |
| Single-file long tail: `ambiguous_anchor` / `anchor_not_found` outside the two large documents | ~130 | ~30 documents | Re-triage against strengthened anchor | 7 |
| **Document fidelity gap — not an anchoring bug** | **167** | **libkin_2004_ch3_ch7** | **Not repaired; individually justified** | **8** |

Counts overlap slightly across rows (an occurrence's category may change once an earlier phase
lands), which is exactly why Phase 1 re-derives the ledger live and Phase 7 re-triages. Treat the
table as the partition of causes, not a fixed budget.

## Goals & Non-Goals

**Goals**:

- Repair every residual occurrence whose failure is an anchoring, composition-map, gap-tolerance,
  or base-modeling defect in the tooling — the ~650 occurrences covered by Phases 2-7.
- Produce, for every occurrence that remains unrepaired, a specific written justification naming
  what was tried and why the edit region could not be bounded safely, checkable by a human against
  the cited `pdf_file` + `pdf_char_offset`. A bare category label is not an acceptable
  justification.
- Preserve the safety contract in full, and strengthen it where Phase 1's audit finds it short of
  the task's stated non-negotiables.
- Make the repairs actually retrievable: regenerate baier_katoen_2008's chunk manifest, rebuild the
  global FTS index, re-stamp `index.json`'s `combining_mark_checked` / `combining_mark_dropped` /
  `combining_marks_missing` fields, and verify a sample of repaired sentences through
  `literature-search.sh`.

**Non-Goals** — what this plan explicitly does NOT attempt to repair, and why:

- **libkin_2004_ch3_ch7's 167 residuals will not be repaired by anchoring.** Its converted
  markdown is 2,682 words against a 2.2MB two-chapter PDF (`word_ratio: 0.0187`, verified live in
  `index.json`). The anchor words are genuinely absent from the markdown because that content was
  never transcribed — this is a condensed paraphrase, not a failed anchor search. No anchoring
  strategy can repair text that does not exist. Phase 8 produces per-occurrence justifications
  citing the fidelity measurement, and recommends a separate re-conversion task. Attempting
  anchoring work here would burn effort on an unwinnable problem; this is the single largest
  scope decision in the plan and is made deliberately, not by omission.
- **Re-conversion of any document.** Out of `file_scope`, which covers negation-repair tooling and
  the corpus files it edits — not the conversion pipeline.
- **The 64 corpus source directories with no on-disk PDF.** The PDF-vs-markdown methodology
  cannot check them at all; their combining-mark status is permanently unknown absent PDF
  re-acquisition. Carried forward unchanged as a scope boundary.
- **`troelstra_schwichtenberg_lectures`.** Holds only `source.pdf` and `PROVENANCE.txt`; no
  converted markdown exists to repair.
- **baier_katoen_2008's 8,514 non-negation control characters across 24 distinct code points.**
  An entire symbol font mapped onto control codes. Only U+0338 negation is in scope; this remains
  a recorded residual finding for a separate task.
- **venema_1993's FTS coverage shortfall.** Only the first ~500 words of each ~1,500-3,000-word
  section file reach the FTS `content` column. This is a pre-existing chunking-granularity
  property of that document, unrelated to negation repair, and is not fixed here — but it is
  documented so the Phase 10 verification does not misread it as a repair failure.
- **Porting the tooling into the literature extension source store.** Verified during research:
  `/.claude` is git-ignored (`.gitignore:81`) and no `.claude/extensions/*/context/**/*combining*`
  file exists on disk, so there is no extension source to carry changes back to. This plan works
  against the deployed `.claude/scripts/` copies and flags the port as a coordination item in
  Phase 10 rather than attempting it.
- **A general N-character compound-base framework.** `|=` is the only compound confirmed by
  evidence. Phase 4 handles it plus the letter-base misidentifications it explains, and stops
  there.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A widened `classify_gap_text` tolerance admits a false positive and corrupts good text | H | M | Every tolerance change lands with a `--self-test` fixture first; corpus run is `--dry-run` and the proposed-edit diff is reviewed before `--write`; per-edit 6-char span cap and whole-file circuit breaker unchanged; each write phase is its own backup/rollback boundary |
| Part-file offset resolution mis-resolves an occurrence near a part boundary | H | M | Verify contiguity across all 12 baier part boundaries (not just part01/part02) before trusting the cumulative-offset table; search an adjacent-file window, not a single best-fit file; **fall back to the current all-files search whenever the narrowed search finds zero matches** — scoping may only reduce ambiguity, never recall |
| Concatenate-then-chunk produces a chunk manifest that mismatches `index.json` | H | M | Back up `chunks.json` + all 1,265 `chunk_*.md` before regenerating; verify post-regeneration chunk count, total token coverage, and doc_id consistency against the pre-state; venema is verified as *not* needing this path at all before any of it runs |
| Repairing all candidates when several are indistinguishable inverts a correct passage | H | L | Apply the task's own rule strictly: repair-all is permitted **only** when every candidate site is itself a corrupted occurrence of the same relation (so there is no wrong answer). Any candidate set containing a non-corrupt site falls back to refuse-and-justify |
| Effort sinks into libkin's 167 because a later dispatch misses the fidelity finding | M | M | Phase 8 is scheduled early (wave 2, parallel with Phase 2) and writes a standalone justification artifact, so the finding is materialized before the anchoring phases run |
| The 403-era ledger is stale relative to corpus edits made since | M | H | Phase 1 re-runs the detector to produce a current ledger and reconciles it against the 824 baseline before any repair work keys off category counts |
| Safety contract is weaker than the task's stated non-negotiables (post-write byte-delta check + auto-rollback not confirmed present) | H | M | Phase 1 audits the engine against each stated non-negotiable and adds what is missing before any `--write` in later phases |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 8 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 9 | 7 |
| 9 | 10 | 8, 9 |

Phases within the same wave can execute in parallel. Phases 2, 3, and 4 are logically independent
of one another but all edit `literature_combining_detect.py` and each ends in a corpus write, so
they are deliberately serialized: shared-file territory plus per-phase rollback boundaries
outweigh the parallelism. Phase 8 touches no code and writes a standalone artifact, so it is
genuinely parallel with Phase 2.

---

### Phase 1: Baseline, safety audit, and live re-triage harness [COMPLETED]

**Goal**: Establish a current, trustworthy picture of the residual set and confirm the safety
contract meets the task's non-negotiables before any write.

**Tasks**:
- [x] Re-run `literature-combining-audit.sh` corpus-wide to produce a *current* residual ledger at
      `specs/404_complete_combining_negation_repair/residual-ledger-baseline.json`; reconcile
      against the 824-entry baseline and record any drift with an explanation. *(completed:
      re-derived 819 repairable entries via `literature-repair-combining.sh --dir <d>
      --ledger-json` over all 60 PDF+markdown directories; per-category counts are byte-for-byte
      identical to the 403 baseline — ambiguous_anchor 428, anchor_not_found 286,
      unrecognized_gap 69, overlapping_edit 17, unmapped_base_char 13, narrow_failed 6 — plus the
      5 carried-forward note entries. Zero drift.)*
- [x] Write a small re-triage helper (or documented `jq` recipe) that emits category x document x
      `base_char` counts from any ledger — reused verbatim by Phases 2-7 and 10 to measure yield.
      *(completed: `specs/404_complete_combining_negation_repair/scripts/retriage.sh`)*
- [x] Audit `literature-repair-combining.sh` against each stated non-negotiable: backup-first with
      sha256 manifest, sub-span-only edit regions, per-edit size cap, whole-file circuit breaker,
      `--dry-run` default, idempotence, refuse-rather-than-guess. Record which are present.
      *(completed: all present; see progress/phase-1-progress.json objective 3 for the per-item
      audit. Whole-file circuit breaker confirmed short of the non-negotiable exactly as the
      dispatch brief stated — addressed by the next task.)*
- [x] Confirmed gap to close: the engine's word-count check at `literature-repair-combining.sh:384-392`
      runs **pre-write** (refuses the write) and covers word delta only. Add a **post-write**
      per-file verification against the backup covering both word count and byte delta, with
      automatic rollback from backup on any delta the accepted edits do not fully account for.
      *(completed: post-write verification block added to the `--write` loop, re-reading both the
      written file and its backup fresh from disk and requiring an exact match on word delta, byte
      delta, written-matches-intended, and backup-matches-pre-edit; any mismatch triggers automatic
      rollback. A test-only `LITERATURE_REPAIR_TEST_INJECT_CORRUPTION=1` hook was added to make the
      rollback path empirically provable — see next task. *(deviation: altered post-hoc — Phase 2's
      first real-corpus write exposed that this initial design's rollback TARGET was the on-disk
      day-start backup, which is only safe for a file's first write of the UTC day; on a file
      already legitimately written earlier the same day this would roll back past that legitimate
      edit. Corrected in Phase 2 to always roll back to the invocation's own captured pre-edit
      read instead. See Phase 2's Deviations note for the full incident and fix; this Phase 1
      checklist item and its scratch-test verification below remain independently valid since all
      of Phase 1's own tests happened to be single-session cases where the two targets coincide.)*)*
- [x] Verify `literature-convert.sh --self-test` passes as a regression baseline. *(completed: 15/15
      fixtures pass.)*
- [x] Verify engine idempotence empirically: re-run `--write` over an already-repaired directory
      and confirm zero proposed edits. *(completed: real-corpus `--dry-run` over 4 of task 403's
      already-repaired directories all proposed 0 rewrites; a scratch-copy end-to-end test (outside
      the real corpus, deleted after use) additionally proved the corruption-injection hook's
      induced mismatch triggers rollback and restores byte-identical original content.)*

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `.claude/scripts/literature-repair-combining.sh` — add post-write backup-comparison verification
  and auto-rollback
- `specs/404_complete_combining_negation_repair/residual-ledger-baseline.json` — new artifact

**Verification**:
- Baseline ledger exists and its total reconciles against 824 with any drift explained in writing.
- `--self-test` passes.
- Idempotence re-run proposes zero edits.
- A deliberately induced bad write (in a scratch copy) triggers rollback from backup.

---

### Phase 2: Extend the composition map; decide the no-precomposed-form policy [COMPLETED]

**Goal**: Clear the pure composition-map gaps and settle how bases with no Unicode precomposed
negation are repaired.

**Tasks**:
- [x] Add `≈ -> ≉` (`≈` -> `≉`, NOT ALMOST EQUAL TO) to `PRECOMPOSED`. Expected reach:
      all 13 `unmapped_base_char` entries plus up to 7 `unrecognized_gap` entries carrying
      `base_char: "≈"`. *(completed: all 13 unmapped_base_char cleared. The 7 unrecognized_gap
      "up to" contribution did NOT materialize -- re-triage confirms zero of those 7 entries had a
      gap containing the base char or precomposed form; they remain ambiguous_anchor/
      anchor_not_found for other reasons, correctly left for Phases 3/7. This is the plan's own
      hedged "plausibly clears up to 20, not 13" language resolving to exactly 13 in this corpus.)*
- [x] Add `⊩ -> ⊮` (`⊩` -> `⊮`, DOES NOT FORCE) to `PRECOMPOSED`. Expected reach: 4.
      *(completed: dict entry added; zero real-corpus unmapped_base_char entries existed for ⊩
      specifically (all 4 unrecognized_gap ⊩ entries are ambiguous/gap-window failures, not
      composition-map gaps) -- verified via retriage, correctly deferred to Phases 3/7.)*
- [x] Decide and implement the policy for `≜` (U+225C) and `↣` (U+21A3), which have **no**
      precomposed negated codepoint: emit the canonical combining sequence `base + U+0338` rather
      than skipping. Record the decision and its rationale in the script's header comment so a
      future reader does not mistake it for an unmapped base. Expected reach: 4. *(completed: new
      `NO_PRECOMPOSED_FORM` dict + merged `REPLACEMENTS` mapping added to
      literature_combining_detect.py with full rationale in the header comment; end-to-end proven
      via a scratch fixture — see progress file. Zero real-corpus unmapped_base_char entries
      existed for ≜/↣ either; their unrecognized_gap entries are gap-window failures, correctly
      deferred.)*
- [x] Add `--self-test` fixtures for each new mapping and for the combining-sequence policy,
      including an idempotence fixture (repairing an already-repaired sequence is a no-op).
      *(completed: 8 new fixtures — new-base-almost-equal, new-base-forces,
      no-precomposed-delta-equal, no-precomposed-arrow-tail, plus their idempotence counterparts —
      added to literature-convert.sh --self-test; 21/21 total fixtures pass.)*
- [x] Run the engine `--dry-run` over the affected directories; review the proposed-edit diff.
      *(completed: baier_katoen_2008, marinmoralesstrassburger_2021_..., venema_1997, venema_2001
      — the 4 directories with ≈/⊩/≜/↣ occurrences per the ledger. Only baier_katoen_2008 had any
      unmapped_base_char (13, all ≈) to write.)*
- [x] Run `--write`; confirm the post-write backup comparison from Phase 1 passes on every file.
      *(completed with a significant correction — see Deviations below: the first --write attempt
      on baier_katoen_2008 correctly caught and rolled back on a stale same-day backup rather than
      silently mis-writing, which exposed a real defect in the Phase 1 rollback-target logic
      (rolling back to the on-disk day-start backup instead of this invocation's own pre-edit
      read). Fixed literature-repair-combining.sh to always use the invocation's own captured
      pre-edit content as both the delta baseline and the rollback target, re-verified via a new
      multi-session scratch regression test, then re-ran --write successfully: 86 occurrences
      written across part07/part08 with 0 rolled back, idempotent on re-run, 0 proposed rewrites
      corpus-wide afterward.)*

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `.claude/scripts/literature_combining_detect.py` — `PRECOMPOSED` entries, no-precomposed-form path
- `.claude/scripts/literature-convert.sh` — `--self-test` fixtures
- `~/Projects/Literature/sources/**/*.md` — repaired occurrences

**Verification**:
- `--self-test` passes with the new fixtures.
- Re-triage shows `unmapped_base_char` at 0 and `unrecognized_gap` reduced by the `≈`/`⊩`/`≜`/`↣`
  contribution. *(confirmed: unmapped_base_char is 0 corpus-wide. unrecognized_gap for these 4
  bases is unchanged at 15 -- the "reduced by" language was conditional/hedged in the plan itself
  and did not materialize for this corpus's actual gap contents; documented, not a defect.)*
- Post-write word/byte delta verification passes on every touched file. *(confirmed, after the
  rollback-target fix described above.)*
- Second `--write` run over the same directories proposes zero edits. *(confirmed corpus-wide: 0
  proposed rewrites across all 60 PDF+markdown directories after this phase's write.)*

**Deviations**:
- **Rollback-target defect found and fixed mid-phase** (see progress file `deviations` for full
  detail): the Phase 1 post-write verification's rollback target was `backup_on_disk`, which is
  only correct when a file receives its FIRST write of the UTC day. baier_katoen_2008's part07/
  part08 had already been legitimately written once earlier the same day (by the preceding sweep
  task), so the day-start backup predated that edit. The first --write attempt this phase
  correctly detected the resulting delta mismatch and refused/rolled back rather than silently
  mis-writing -- but the rollback itself used the stale backup as its restore target, which
  reverted part07/part08 all the way to their pre-earlier-repair state before this phase's own
  edit was even applied. No data was lost: the repair engine is deterministic given the same
  input and current code, so re-running --write against the (now correctly pre-edit) files
  reproduced the earlier repairs plus this phase's new ≈ fix in one clean, verified pass (86
  occurrences, 0 rolled back). The underlying rollback-target logic was corrected to always use
  the invocation's own captured pre-edit read as both the delta baseline and the restore target,
  never the potentially-stale day-level backup, and this was proven via a new scratch multi-session
  regression test before retrying the real-corpus write.

---

### Phase 3: Widen gap classification tolerance for already-mapped bases [COMPLETED]

**Goal**: Clear the 38 `unrecognized_gap` occurrences whose base char (`=`, `∈`, `≺`, `⊆`) is
already in `PRECOMPOSED` — proving these are gap-window/whitespace tolerance failures, not map gaps.

**Tasks**:
- [x] Sample the context windows of the `=` (24), `∈` (11), `≺` (2), `⊆` (1) entries and
      characterize precisely why the gap substring fails the `classify_gap_text` base-presence
      check (whitespace normalization, intervening markup, gap-window boundary). *(completed: a
      debug harness reproducing `classify_occurrence` for all 38 entries found the true shape is
      "intervening markup" — but NOT whitespace: 19/38 are correctly-transcribed LaTeX math
      (`\neq`/`\ne`/`\notin` macros instead of literal Unicode), not corrupted at all. The other 19
      are NOT a tolerance problem: 6 baier_katoen_2008 + 6 libkin_2004_ch3_ch7 + 7 single-file
      false-positive anchor matches (wrong-location gaps unrelated to the actual occurrence) that
      belong to Phases 5/6, 8, and 7 respectively — see Deviations below.)*
- [x] Widen `classify_gap_text`'s tolerance to cover the characterized cases — narrowly, driven by
      the sampled evidence, not by a blanket loosening of the asymmetric `-90/+15` slack.
      *(completed: added `LATEX_NEGATION_MACROS` (base_char -> word-boundary-safe regexes for
      `\neq`/`\ne`/`\notin`) consulted by `classify_gap_text` before the literal-base-char check;
      returns the existing `latex_macro` signature (already "accounted", already excluded from
      `REPAIRABLE_SIGNATURES` — no new write path needed). Scoped ONLY to `=` and elem-of, the two
      bases with confirmed sampled evidence; `≺`/`⊆` were NOT extended since their only sampled
      entries were libkin false-positives, not genuine LaTeX-macro occurrences.)*
- [x] Add `--self-test` fixtures reproducing each characterized failure shape, plus at least one
      negative fixture confirming the widened tolerance still rejects a non-corrupt gap.
      *(completed: 11 new fixtures in `literature-convert.sh --self-test` — 4 positive (real
      sampled gap text verbatim, covering `\neq`, `\ne` inline, `\ne` after a superscript brace,
      `\notin`), 3 word-boundary negative fixtures (`\newcommand`, `\nearrow`, `\notinvariant` must
      NOT match), 2 real-corpus false-positive-anchor negative fixtures (verbatim gaps from
      baier_katoen_2008/obendrauf_2024 that must stay rejected). 32/32 total fixtures pass.)*
- [x] `--dry-run`, review diff, then `--write` with post-write verification.
      *(completed with a deviation: no `--write` was needed or run. The `latex_macro` signature
      was already excluded from `REPAIRABLE_SIGNATURES` before this phase — it is "accounted"
      (nothing was ever corrupted), so the repair engine has nothing to rewrite for these 19
      occurrences. `--dry-run` was run over all 7 affected directories and confirmed 0 proposed
      rewrites in every one, both before and after the fix — the entries simply exit the residual
      ledger via reclassification, not via a corpus write. See Deviations.)*

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `.claude/scripts/literature_combining_detect.py` — `classify_gap_text`
- `.claude/scripts/literature-convert.sh` — fixtures
- `~/Projects/Literature/sources/**/*.md`

**Verification**:
- Negative fixture confirms no false-positive admission. *(confirmed: 5 negative fixtures pass,
  plus a differential corpus-wide scan proving `control_char`/`glyph_six`/`absent` signature
  counts for `=`/elem-of are byte-for-byte identical before and after the fix — zero regression
  in genuinely repairable occurrences.)*
- Re-triage shows the `=`/`∈`/`≺`/`⊆` `unrecognized_gap` population cleared or individually
  justified. *(confirmed: 19/38 cleared via reclassification to `latex_macro`; the remaining 19
  are individually justified by directory in the Deviations note below, each pointing to the
  specific later phase that owns it.)*
- Post-write verification passes; second run is a no-op. *(N/A — no write occurred; see
  Deviations. `--dry-run` over all 7 affected directories confirms 0 proposed rewrites.)*

**Deviations**:
- **19 of the 38 target entries are NOT this phase's territory and were deliberately left
  unrecognized_gap**, each earmarked for the phase whose root cause actually explains it:
  - **baier_katoen_2008 (6: `=`×5, `∈`×1)**: sampled gaps are unrelated prose fragments (e.g. "we
    write the stack", "10.75 on page 825.") — classic wrong-file/wrong-location anchor matches on
    this 12-part multi-file document. This is exactly Phase 5/6's un-scoped cross-file anchor
    search root cause; re-triage after Phase 6 lands is the right next check, not a Phase 3 fix.
  - **libkin_2004_ch3_ch7 (6: `=`×2, `≺`×2, `∈`×1, `⊆`×1)**: sampled gaps are unrelated paraphrased
    prose, consistent with the Phase 8 fidelity-gap finding (`word_ratio: 0.0187`) — these are the
    same non-repairable class Phase 8 documents, not a gap-tolerance defect.
  - **7 single-file false-positive anchor matches** (derijke_1995 ×3, obendrauf_2024 ×1,
    venema_1993 ×1, yan_2008 ×2): the word-anchor search found exactly one candidate gap but it is
    unrelated prose elsewhere in the same file — a wrong-match, not a tolerance-window problem. Two
    of these (baier's and obendrauf's) are used verbatim as negative self-test fixtures so a future
    change cannot silently start accepting them. Left for Phase 7's long-tail re-triage.
  - This split was verified precisely, not estimated: a differential scan (pre-phase-3 code vs.
    post-phase-3 code) over every `=`/elem-of occurrence corpus-wide shows `unanchored` dropping
    by exactly 19 (478 -> 459) and `latex_macro` rising by exactly 19 (2 -> 21), with every other
    signature bucket (`precomposed` 257, `bare_pair` 18, `control_char` 12, `absent` 3) unchanged.

---

### Phase 4: Compound-base handling for `|=` [NOT STARTED]

**Goal**: Model the `|=` (models/satisfies turnstile) compound base, which `find_base` cannot
represent because it only ever returns a single character.

**Tasks**:
- [ ] Confirm the mechanism on the 12 `base_char: "\|"` entries: PyMuPDF extracts `|` `=` as two
      characters from the PDF while the corresponding markdown span contains no literal `|` at all.
- [ ] Check whether the 4 letter-base entries (`T` 2, `L` 1, `C` 1) are the same family —
      `find_base` grabbing an adjacent letter from `TS ̸|= Psafe`-shaped text. Handle them here if
      so; route them to Phase 7 individual justification if not.
- [ ] Add a compound-base code path: when `find_base`'s single character is part of a recognized
      multi-character relation, search markdown for the *pair* (and its precomposed/negated
      renderings, e.g. `⊨`/`⊭`) rather than the lone character. Keep the recognized-compound list
      to `|=` only unless implementation triage surfaces further evidence.
- [ ] Add `--self-test` fixtures for the compound path, including the `⊨`/`⊭` markdown rendering.
- [ ] `--dry-run`, review diff, then `--write` with post-write verification.

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `.claude/scripts/literature_combining_detect.py` — `find_base` and its callers
- `.claude/scripts/literature-convert.sh` — fixtures
- `~/Projects/Literature/sources/**/*.md`

**Verification**:
- Fixtures pass; the compound list contains only evidence-backed entries.
- Re-triage shows `unrecognized_gap` at or near 0, with any remainder individually characterized.
- Post-write verification passes; second run is a no-op.

---

### Phase 5: PDF-offset to part-file resolution for multi-file documents (dry-run only) [NOT STARTED]

**Goal**: Build and validate the anchor-scoping change that addresses the single largest residual
category, without yet writing to the corpus.

**Tasks**:
- [ ] Verify contiguity across **all 12** baier_katoen_2008 part boundaries (tail of partNN vs.
      head of partNN+1), not just part01/part02, before trusting a cumulative-offset table.
- [ ] In `classify_occurrence`, gated on `len(md_texts_raw) > 1`: build a cumulative character-offset
      table across `md_texts_raw` in filename order (`find_md_paths` already sorts, and both
      `partNN` and `secNN` names sort correctly), then use the existing `frac = idx / pdf_len`
      proportional estimate — the same technique already proven in the `latex_macro` fallback — to
      select a candidate file.
- [ ] Search a candidate window spanning the best-fit file plus its immediate neighbours when the
      estimate lands near a boundary.
- [ ] **Recall guard**: if the narrowed search finds zero matches, fall back to the existing
      all-files search. Scoping may only reduce ambiguity, never recall. Add a fixture asserting
      this fallback fires.
- [ ] Add `--self-test` fixtures for the offset table and the boundary-window behaviour.
- [ ] Run `--dry-run` over baier_katoen_2008 and venema_1993; record the before/after
      `ambiguous_anchor` and `anchor_not_found` counts. **No `--write` in this phase.**

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `.claude/scripts/literature_combining_detect.py` — `classify_occurrence`, new offset-table helper
- `.claude/scripts/literature-convert.sh` — fixtures

**Verification**:
- All 12 part boundaries verified contiguous (no duplication, no gap), with the check recorded.
- Recall-guard fixture passes.
- Dry-run shows a substantial reduction in `ambiguous_anchor` for baier_katoen_2008 with no
  increase in `anchor_not_found`; single-file documents show byte-identical classification to
  before (the gate must be inert for them).

---

### Phase 6: Apply part-scoped repair to baier_katoen_2008 and venema_1993 [NOT STARTED]

**Goal**: Land the corpus write for the two multi-file documents, under the full safety contract.

**Tasks**:
- [ ] Review the Phase 5 dry-run diff for baier_katoen_2008 in detail — this document holds 59% of
      the residual work and was one of the two documents damaged by the earlier over-wide-span bug.
- [ ] Run `--write` over baier_katoen_2008; confirm backup created with sha256 manifest before any
      edit, and that post-write word/byte delta verification passes on all 12 part files.
- [ ] Run `--write` over venema_1993 across its 9 `secNN_*.md` section files, same verification.
- [ ] Re-run the detector over both documents and record the new residual counts.
- [ ] Spot-check a sample of repaired passages against their cited `pdf_char_offset` to confirm the
      repaired reading matches the PDF ground truth.

**Timing**: 1.5 hours

**Depends on**: 5

**Files to modify**:
- `~/Projects/Literature/sources/baier_katoen_2008/Baier_Katoen_2008_part{01..12}.md`
- `~/Projects/Literature/sources/venema_1993/sec{01..09}_*.md`

**Verification**:
- Backups exist under `$LITERATURE_DIR/.backups/` with a verified sha256 manifest for every
  touched file.
- Post-write delta verification passes on every file; no rollback triggered.
- Manual spot-check of sampled repairs matches PDF ground truth at the cited offsets.
- Second `--write` run over both documents proposes zero edits.

---

### Phase 7: Re-triage and resolve the long tail [NOT STARTED]

**Goal**: Bring every remaining non-libkin residual to either repaired or individually justified.

**Tasks**:
- [ ] Re-run the detector corpus-wide and re-triage against the strengthened anchor. Several
      categories are expected to have shifted rather than simply shrunk.
- [ ] Handle `overlapping_edit` (17, mostly baier): confirm the report's hypothesis that narrower
      gap widths from Phases 4-6 dissolve most collisions; resolve the remainder case by case.
- [ ] Handle `narrow_failed` (6): small enough for individual review; repair where `_find_sub_spans`
      can now bound a clean literal sub-span, justify individually where it cannot.
- [ ] Handle the ~130 single-file `ambiguous_anchor` / `anchor_not_found` occurrences across the
      ~30 long-tail documents.
- [ ] Apply the repair-all disambiguation rule **only** under its precondition: when every remaining
      candidate site is itself a corrupted occurrence of the same relation, repair all of them
      (there is no wrong answer). If any candidate site is not corrupt, refuse and justify.
- [ ] `--dry-run`, review, `--write` with post-write verification per affected directory.
- [ ] For every occurrence still unrepaired, write a specific justification naming what was tried
      and why the edit region could not be bounded — never a bare category label.

**Timing**: 2 hours

**Depends on**: 6

**Files to modify**:
- `~/Projects/Literature/sources/**/*.md` — long-tail repairs
- `.claude/scripts/literature_combining_detect.py` — only if triage surfaces a further evidence-backed
  gap (do not speculatively generalize)
- `specs/404_complete_combining_negation_repair/residual-ledger-final.json` — justified residuals

**Verification**:
- Every remaining entry in the final ledger carries a per-occurrence justification, not a category
  label; a sample is spot-checked against its cited PDF offset by a human-readable reading.
- Repair-all decisions each record the precondition check that licensed them.
- Post-write verification passes for every touched directory.

---

### Phase 8: libkin_2004_ch3_ch7 fidelity determination (no repair attempted) [NOT STARTED]

**Goal**: Close out the 167 largest-single-block residuals as a documented fidelity gap rather than
an anchoring target, with justification specific enough to satisfy the definition of done.

**Tasks**:
- [ ] Record the fidelity measurement as evidence: `word_ratio: 0.0187` from `index.json`, 2,682
      words of converted markdown against a 2.2MB two-chapter PDF.
- [ ] For a representative sample of the 159 `anchor_not_found` entries, verify directly that the
      anchor words are absent from the markdown because the surrounding content was never
      transcribed — not because the anchor algorithm failed. Record the sampled offsets and the
      verification method so a reader can re-run it.
- [ ] Determine the exact category split of all 167 entries from the Phase 1 baseline ledger
      (159 `anchor_not_found`, 6 `unrecognized_gap`, and the ~2 remainder) and confirm the fidelity
      explanation covers each category, or separate out any that it does not.
- [ ] Write per-occurrence justifications to
      `specs/404_complete_combining_negation_repair/libkin-fidelity-justification.json`, each citing
      `pdf_file` + `pdf_char_offset` + the fidelity measurement, phrased so a human can check it.
- [ ] Record a one-line follow-up recommendation: a separate re-conversion task for this document
      (out of this task's `file_scope`).
- [ ] Confirm the eight other multi-occurrence documents have healthy `word_ratio` (0.92-1.07) so
      this is documented as an outlier, not a corpus-wide pattern.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `specs/404_complete_combining_negation_repair/libkin-fidelity-justification.json` — new artifact

**Verification**:
- Every one of the 167 entries has a justification entry.
- The sampled direct verifications are reproducible from the recorded offsets.
- No repair write is made to `libkin_2004_ch3_ch7` in this phase.

---

### Phase 9: Regenerate baier_katoen_2008 chunks; confirm venema needs none; rebuild FTS [NOT STARTED]

**Goal**: Make the repairs visible to retrieval.

**Tasks**:
- [ ] **Confirm the venema_1993 finding before acting on it**: its `chunks.json` holds 9 entries
      whose `source_path` values point directly at the `secNN_*.md` files the repair engine edited,
      and there are no `chunk_*.md` files in that directory. If confirmed, venema needs **no
      re-chunking** — only an index rebuild — and its `chunks_not_regenerated` ledger entry is
      resolved as a false blocker with that reasoning recorded.
- [ ] Back up baier_katoen_2008's existing `chunks.json` and all 1,265 `chunk_*.md` files before
      touching them.
- [ ] Regenerate baier's chunks via concatenate-then-chunk:
      `cat Baier_Katoen_2008_part{01..12}.md > $TMP/concat.md` then
      `literature-chunk.sh $TMP/concat.md sources/baier_katoen_2008/ --doc-id baier_katoen_2008`;
      discard the temp file. This is licensed by the Phase 5 all-boundaries contiguity verification,
      which is what the preceding task lacked when it deferred this work.
- [ ] Sanity-check the regenerated manifest: chunk count in the neighbourhood of the prior 1,265,
      total token coverage consistent with the concatenated source, single consistent `doc_id`, and
      `prev_chunk_id`/`next_chunk_id` chain intact end to end.
- [ ] Remove stale `chunk_*.md` files not referenced by the new manifest.
- [ ] Rebuild the global FTS index via `literature-build-index.sh`.

**Timing**: 2 hours

**Depends on**: 7

**Files to modify**:
- `~/Projects/Literature/sources/baier_katoen_2008/chunks.json` and `chunk_*.md`
- `~/Projects/Literature/.literature.db` (rebuilt)

**Verification**:
- Backup of the prior baier chunk manifest and chunk files exists and is restorable.
- Regenerated manifest passes all four sanity checks above.
- venema_1993's chunk manifest is either confirmed unchanged-and-correct, or the confirmation
  failed and the phase escalates rather than assuming baier's fix applies.
- FTS index rebuild completes without error and chunk counts match the manifests.

---

### Phase 10: Re-stamp index.json, verify retrieval, finalize the DoD ledger [NOT STARTED]

**Goal**: Bring recorded fidelity metadata into line with the repaired state, prove retrievability,
and deliver the definition-of-done artifact.

**Tasks**:
- [ ] Re-stamp `index.json`'s `combining_mark_checked`, `combining_mark_dropped`, and
      `combining_marks_missing` fields for every document touched, from a final detector run.
- [ ] Verify retrieval through `literature-search.sh` for a sample of newly-repaired sentences in
      baier_katoen_2008 and venema_1993. **Sample only sentences falling within the first ~500 words
      of their chunk** — `literature-build-index.sh:171-179` stores only that prefix in the FTS
      `content` column, so a sentence beyond it is unfindable for reasons unrelated to this repair.
      Record that constraint alongside the results.
- [ ] Merge the Phase 7 long-tail justifications and the Phase 8 libkin justifications into a single
      final ledger at `specs/404_complete_combining_negation_repair/residual-ledger-final.json`.
- [ ] Produce the coverage accounting: occurrences repaired in this task, cumulative coverage
      against the 1,237 baseline, and the count of individually-justified residuals by reason class.
- [ ] Flag — do not attempt — the extension-source port coordination item, recording that `/.claude`
      is git-ignored and no extension source store for these scripts exists on disk, so the engine
      improvements made here live only in the deployed tree until that port lands.

**Timing**: 1.5 hours

**Depends on**: 8, 9

**Files to modify**:
- `~/Projects/Literature/index.json` — combining-mark fields
- `specs/404_complete_combining_negation_repair/residual-ledger-final.json` — final DoD artifact

**Verification**:
- Every document touched has re-stamped combining-mark fields consistent with the final detector run.
- Sampled repaired sentences are retrievable via `literature-search.sh`, with any misses explained
  by the documented 500-word FTS content limit rather than left unexplained.
- The final ledger's entry count plus the repaired count reconciles exactly against the 819
  repairable baseline.
- Every final-ledger entry carries an individually-justified, human-checkable reason. Zero entries
  carry a bare category label.

---

## Testing & Validation

- [ ] `literature-convert.sh --self-test` passes after every phase that touches
      `literature_combining_detect.py`, with new fixtures added by that phase.
- [ ] At least one negative fixture per tolerance-widening change confirms non-corrupt gaps are
      still rejected.
- [ ] Idempotence: a second `--write` run over any repaired directory proposes zero edits.
- [ ] Every write is preceded by a verified sha256 backup and followed by a word-count and
      byte-delta comparison against that backup, with rollback on any unaccounted delta.
- [ ] Single-file documents classify byte-identically before and after the Phase 5 multi-file gate
      (the gate must be inert for them).
- [ ] Sampled repairs are verified by hand against their cited `pdf_file` + `pdf_char_offset`.
- [ ] Regenerated baier chunk manifest passes count, coverage, doc_id, and chain-integrity checks.
- [ ] Sampled repaired sentences are retrievable via `literature-search.sh`.
- [ ] Final ledger reconciles against the 819 repairable baseline with zero bare-category
      justifications.

## Artifacts & Outputs

- `specs/404_complete_combining_negation_repair/plans/01_combining-negation-repair.md` (this file)
- `specs/404_complete_combining_negation_repair/residual-ledger-baseline.json` (Phase 1)
- `specs/404_complete_combining_negation_repair/libkin-fidelity-justification.json` (Phase 8)
- `specs/404_complete_combining_negation_repair/residual-ledger-final.json` (Phases 7, 10)
- `specs/404_complete_combining_negation_repair/summaries/01_combining-negation-repair-summary.md`
- Modified: `.claude/scripts/literature_combining_detect.py`,
  `.claude/scripts/literature-repair-combining.sh`, `.claude/scripts/literature-convert.sh`
- Modified: `~/Projects/Literature/sources/**/*.md`, `~/Projects/Literature/index.json`,
  `~/Projects/Literature/sources/baier_katoen_2008/chunks.json` + `chunk_*.md`,
  `~/Projects/Literature/.literature.db`

## Rollback/Contingency

Each write phase is an independent rollback boundary. Corpus files are restorable from
`$LITERATURE_DIR/.backups/combining-repair-{ISO_DATE}/` via the sha256 manifest; the engine never
overwrites an existing same-day backup, so a backup always reflects pre-repair state for that day.
The Phase 1 post-write verification triggers automatic rollback from backup on any unaccounted
word or byte delta, before a bad write can propagate to a later phase.

baier_katoen_2008's chunk regeneration (Phase 9) is separately reversible: the prior `chunks.json`
and all 1,265 `chunk_*.md` files are backed up before regeneration, and the FTS index is fully
rebuildable from whichever manifest is in place. If the regenerated manifest fails its sanity
checks, restore the backup and re-run `literature-build-index.sh` — the corpus markdown repairs
survive independently of the chunk manifest.

Tooling changes live in `.claude/scripts/`, which is git-ignored, so they are not recoverable via
git. Before modifying any of the four in-scope scripts, copy the current version alongside it (or
into the task directory) so a bad tooling change can be reverted without re-deriving it.
