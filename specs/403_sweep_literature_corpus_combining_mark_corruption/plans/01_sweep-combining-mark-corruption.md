# Implementation Plan: Task #403

- **Task**: 403 - sweep_literature_corpus_combining_mark_corruption
- **Status**: [IMPLEMENTING]
- **Effort**: 12 hours
- **Dependencies**: None (task 389 root-cause work already landed)
- **Research Inputs**: `specs/403_sweep_literature_corpus_combining_mark_corruption/reports/01_sweep-combining-mark-corruption.md`
- **Artifacts**: plans/01_sweep-combining-mark-corruption.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Repair the combining-mark (U+0338) corruption in the live `~/Projects/Literature` corpus that
silently inverts negated relations in converted markdown, and add a targeted detector so the
defect class cannot recur undetected. The work is: build a PDF-vs-markdown ground-truth detector,
close the residual gaps in `literature-convert.sh`'s existing overlay-composition fix, repair the
affected documents in place under per-file backup, re-chunk and re-index, and wire the detector
into `literature-fidelity-audit.sh` as an additive signal alongside `provenance_fidelity`.
Definition of done: the detector reports zero unaccounted-for combining-mark occurrences across
every corpus directory that has both a source PDF and converted markdown, or a documented,
per-occurrence residual ledger explaining each exception.

### Research Integration

The research report established the blast radius empirically: 14 documents with true silent
negation inversion (1,163 occurrences, 817 in `baier_katoen_2008` alone), 9 further documents with
a visible `6=` glyph-substitution artifact (114 occurrences), all 14 dangerous documents currently
stamped `provenance_fidelity: verified_conversion`, and `literature-fidelity-audit.sh`'s
word-ratio heuristic structurally blind to the whole defect class. The report's recommended
detector design (raw PyMuPDF extraction as ground truth; account each occurrence against
precomposed codepoint / bare combining pair / `\not`-prefixed LaTeX macro; flag the remainder) is
adopted as-is in Phase 1.

Four plan-shaping findings were established during planning that **correct or extend** the report
and must be carried into implementation:

1. **"Zero trace" is false for the two dominant documents.** The report characterised the
   dangerous class as leaving no trace to grep for. That holds for 12 of the 14 documents, but not
   for the two largest: in `baier_katoen_2008` and `bacon_2018_broadest-necessity` the overlay
   mark survives as a **C0 control character** (U+000F immediately preceding the base character —
   e.g. `TS(PG1 ||| PG2 ) \x0f= TS(PG1 )`). These two documents account for 835 of the 1,163
   occurrences (72%). For them detection and repair are a deterministic character-level
   substitution, not a fuzzy alignment problem. The report's spot-check transcripts read as clean
   equalities only because U+000F renders invisibly.
2. **`baier_katoen_2008`'s markdown carries control-character corruption far beyond negation** —
   roughly 7,700 C0 control characters across ~24 distinct code points (U+0002, U+0003 x3034,
   U+0005 x1239, U+000C, U+000F x791, ...), i.e. an entire symbol font mapped onto control codes.
   Only the negation subset is in scope here; the remainder is recorded as a residual finding, not
   fixed (see Non-Goals).
3. **`literature-convert.sh`'s existing `compose_combining_overlays()` fix is incomplete.**
   `_OVERLAY_REORDER_RE = re.compile(r"([̀-ͯ])([" + _OVERLAY_BASES + r"])")` requires the combining
   mark to sit *immediately* before the base character, but raw PyMuPDF extraction of this corpus
   also produces whitespace-separated pairs (verified: page index 58 of the Baier & Katoen PDF
   extracts as `TS(PG1 ||| PG2)̸ = TS(PG1)` — mark, space, `=`). `_OVERLAY_BASES` also omits bases
   the report observed in the wild (`⊢`, `≺`, `→`, `|`). Re-conversion through the current script
   would therefore **not** reliably restore negations; the converter must be fixed first.
4. **`literature-fidelity-audit.sh --write` recomputes `provenance_fidelity` and `word_ratio` for
   every matched entry corpus-wide from `classify_dir()`.** Any hand-edit correcting a false
   `verified_conversion` stamp would be silently overwritten on the next `--write`. Deliverable (c)
   must therefore be implemented as a **durable computed field**, not a manual index patch.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted for this task (no `roadmap_path` provided).

## Goals & Non-Goals

**Goals**:
- Restore semantically-correct negated relations in every affected converted markdown file, under
  reversible, per-file backup.
- Handle the `6=` glyph-substitution class using PDF ground truth so only genuine negations are
  rewritten.
- Make the corrected `provenance_fidelity` picture durable against re-runs of
  `literature-fidelity-audit.sh --write`.
- Add a cheap, targeted combining-mark detector as an additive second signal in
  `literature-fidelity-audit.sh`, reported alongside `provenance_fidelity` rather than folded into
  the word-ratio gate.
- Leave a machine-readable residual ledger for every occurrence that could not be repaired.

**Non-Goals**:
- Full re-conversion of the corpus, or of any individual document, as the primary repair path.
  Re-conversion is rejected as the default because `literature-convert.sh` emits a single
  `{doc_id}.md`, whereas the affected documents are stored as multi-file layouts
  (`Baier_Katoen_2008_part01..12.md`, `venema_1993/sec01..09_*.md`) with matching `index.json`
  entry ids and 1,265 already-built chunk files for `baier_katoen_2008` alone. Re-conversion would
  rename files, orphan index ids, and invalidate chunk ids across a live user corpus — a far
  larger and less reversible blast radius than the defect being fixed. Targeted in-place repair is
  explicitly sanctioned by the task description and is the chosen branch.
- Fixing the non-negation control-character corruption in `baier_katoen_2008` (~6,900 further
  control characters unrelated to U+0338). Recorded as a residual finding for a separate task.
- Investigating the `libkin_2004_ch3_ch7` `word_ratio: 0.0187` / `verified_conversion`
  inconsistency the report flagged. Phase 8's audit re-run will recompute and self-correct this
  stamp as a side effect; no separate investigation is in scope.
- Changing `provenance_fidelity` enum values, the `RATIO_THRESHOLD` gate, or any downstream
  consumer of `verified_conversion` (`literature-search.sh` / `literature-briefing.sh`
  `[UNVERIFIED ...]` banner logic).
- Re-acquiring PDFs for the 64 corpus directories that have no on-disk PDF. Their combining-mark
  status stays permanently unknown; this is recorded, not resolved.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Repair corrupts the user's real corpus | H | M | Every phase that writes to `~/Projects/Literature` first mirrors the target files into `$LITERATURE_DIR/.backups/combining-repair-{ISO_DATE}/` and records a sha256 manifest in the task dir. Repair script is `--dry-run` by default and refuses to run if a backup for the target file is absent. |
| Fuzzy PDF-to-markdown anchoring rewrites the wrong character | H | M | Anchoring uses a whitespace-stripped context window with an offset map back to the original file, and rewrites **only** where the anchor matches exactly once in the target file. Ambiguous (0 or >1 match) occurrences are never written — they go to the residual ledger. Verified necessary: the markdown differs from PDF text by inserted spaces (`TS(PG1 )` vs `TS(PG1)`). |
| Repair regresses sections already correct via LaTeX-macro transcription | M | M | Phase 6 handles the five mixed documents separately, with an explicit pre-write diff review; occurrences already accounted for as `\not=`/`\notin`/`\not\leq` are excluded by the detector before repair is attempted. |
| `6=` rewriting damages legitimate text containing digit 6 followed by `=` | M | M | Phase 7 rewrites only at positions the PDF ground truth confirms carry U+0338. No pattern-only `6=` substitution anywhere. |
| Repaired markdown not reflected in search results | M | H | Phase 9 re-chunks every repaired document and rebuilds the global FTS database. |
| Manual index corrections overwritten by the next audit `--write` | M | H | Deliverable (c) is implemented as a computed field written by the audit script itself (Phase 8), so it is reproduced on every run rather than patched once. |
| Audit `--write` reformats/rewrites all 321 index entries | M | H | Known, documented, idempotent behaviour of the existing script. `index.json` is backed up before the run and the post-run diff is reviewed for unintended `provenance_fidelity` transitions outside the expected set. |
| Detector re-derives numbers that disagree with the research report | L | M | Treat the detector's numbers as authoritative and record any divergence from the report's table in the phase output; the report's counts were spot-check-classified, the detector's are exhaustive. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5, 6, 7 | 4 |
| 5 | 8 | 5, 6, 7 |
| 6 | 9 | 8 |

Phases within the same wave can execute in parallel. Phases 5, 6 and 7 operate on disjoint
corpus directories, so parallel execution is territory-safe; Phase 4 is deliberately sequenced
first and alone so the repair engine is validated on the highest-evidence case before being
applied more widely.

---

### Phase 1: Ground-truth detector and baseline measurement [COMPLETED]

**Goal**: Produce a standalone, re-runnable detector that measures combining-mark fidelity for
every corpus directory holding both a PDF and converted markdown, and capture the pre-repair
baseline.

**Tasks**:
- [x] Write `.claude/scripts/literature-combining-audit.sh`. Contract: iterate
      `$LITERATURE_DIR/sources/*/`; for each directory with at least one `*.pdf` and at least one
      non-`chunk_*` `*.md`, extract raw PDF text via PyMuPDF `page.get_text("text")` (NOT
      `pdftotext`, which itself substitutes `6` for the overlay), enumerate every U+0338, and
      account each occurrence against one of: precomposed target codepoint present; bare
      combining pair present; `\not`-prefixed LaTeX macro present; C0 control-character
      substitution present; literal `6` substitution present; unaccounted (true drop).
      *(completed: per-occurrence classification uses a whitespace-normalized-distance,
      plain-ASCII-word-landmark anchor with a "gap must contain the base/precomposed char"
      filter — see phase notes below for why simpler literal-adjacent-character anchoring
      failed on this corpus.)*
- [x] Classify each occurrence by signature: `precomposed` / `bare_pair` / `latex_macro` (all
      three = accounted, no action) versus `control_char` / `glyph_six` / `absent` (all three =
      corrupted, actionable). *(completed: added a seventh bucket, `unanchored`, folded into the
      "corrupted, actionable" tally — see deviation note below.)*
- [x] Emit both a TSV summary (one row per directory) and a `--json` mode carrying per-occurrence
      records (base character, signature, PDF byte offset, context window). The JSON mode is the
      input contract for the Phase 3 repair engine — define it once here. *(completed)*
- [x] Support `--dir <name>` to scope to a single document, and honour `LITERATURE_DIR`.
      *(completed)*
- [x] Never write to the corpus or to `index.json`; this script is read-only by construction.
      *(completed: script only ever opens files in `"r"` mode; verified via `git status` on
      `~/Projects/Literature` before/after — see phase notes.)*
- [x] Run the detector corpus-wide and save the baseline to
      `specs/403_sweep_literature_corpus_combining_mark_corruption/baseline-combining-audit.tsv`
      and `.json`. *(completed: 61 directories scanned corpus-wide, 24 with non-zero corrupted
      count.)*
- [x] Record in the phase notes any divergence between the detector's per-document counts and the
      research report's table (Findings, Part 1+2). *(completed, see below.)*

**Phase notes — divergence from the research report's table and detector design rationale**:

The report's counts were manual/spot-check-classified; this detector's are exhaustive and
mechanical, and per the plan's own risk table ("Detector re-derives numbers that disagree with
the research report... treat the detector's numbers as authoritative"), divergences below are
recorded rather than silently reconciled:

- `baier_katoen_2008`: detector finds 819 PDF occurrences (report: 819, exact match) but only
  classifies 377 confidently as `control_char` (report's qualitative claim: ~791/817 missing are
  this signature) plus 1 `glyph_six`, 12 `absent`, and **429 `unanchored`** (detector could not
  confidently locate the occurrence in the markdown at all — 0 or >1 candidate anchor matches).
  Root cause: this document's corruption is NOT limited to the negation mark — an entire symbol
  font is control-character-mapped (per the plan's finding #2: ~7,700 control chars across ~24
  code points), so immediately-adjacent PDF context (e.g. `∥`, `H′`) is frequently ALSO corrupted
  in the markdown, breaking literal-adjacency anchoring. A plain-ASCII-word-landmark anchor
  (finding the nearest distinctive run of letters on each side, ignoring intervening symbols)
  recovers most of these, but dense math-formula passages with few nearby prose words (e.g.
  `TS1 ∥H (TS2 ∥H′ TS3) ̸= (TS1 ∥H TS2) ∥H′ TS3`) remain genuinely hard to anchor confidently at
  the exhaustive, corpus-wide-script level. All 429 unanchored occurrences are counted as
  corrupted/actionable (conservative), not silently absorbed into "accounted". Phase 4's targeted,
  single-document repair pass (with its own closer manual verification against the report's 4
  spot-checked sentences) is expected to resolve most of these directly rather than via this
  generic detector.
- `bacon_2018_broadest-necessity`: 18/18 PDF occurrences found (report: 18, exact match); 16
  classified `control_char`, 2 `unanchored`. Consistent with the report's claim that all 18 are
  this signature.
- `rabinovich_2014` (negative control): 2/2 PDF occurrences found, both `precomposed`, 0
  corrupted — matches the report and the plan's expectation exactly.
- `schwoon_esparza_2005`: 1 PDF occurrence found (this document's actual PDF U+0338 count, not
  independently reported by the research report at the per-document level), correctly classified
  `glyph_six` (the "6=" glyph-substitution pattern) after fixing an initial anchor-selection bug
  (the naive "prefer longest nearby word" heuristic picked a repeated local variable name --
  "lowlink" appears both before and after the target -- over the much closer but shorter word
  "goal"; switched to a proximity-first, length-as-tiebreak selection).
- Corpus-wide: 61 directories have both a PDF and non-chunk markdown; 24 have a non-zero
  corrupted count (report: "14 dangerous + 9 glyph-six" = 23; the detector's 24th is
  `schwoon_esparza_2005` itself, already counted in the report's 9-document glyph-six list, so
  this is consistent, not a discrepancy).

**Post-hoc update (during Phase 3)**: the detector's core anchoring logic (`literature_combining_
detect.py`, extracted from this script's earlier inline implementation) was retuned during Phase 3
to fix a real idempotence bug (see Phase 3's verification notes: an asymmetric slack widening,
`slack_low=90`/`slack_high=15`, was needed so re-scanning an already-repaired file with several
nearby fixes doesn't misclassify correctly-fixed occurrences as `unanchored`). The baseline
artifacts above were regenerated with this final tuning rather than left as the earlier, less-
tuned snapshot, so Phase 9's final-vs-baseline diff compares like-for-like methodology.

**Deviation from the plan's minimum signature set**: added an eighth reported value,
`unanchored`, beyond the plan's six (`precomposed`/`bare_pair`/`latex_macro`/`control_char`/
`glyph_six`/`absent`). This is additive, not a substitution: it is folded into the "corrupted,
actionable" tally exactly as the plan's five-value corrupted bucket would be, and exists because
an exhaustive, corpus-wide script cannot always confidently anchor an occurrence in the
markdown — declaring it a false `absent`/`control_char` would misclassify it; declaring it
`unanchored` (never `accounted`) keeps the conservative safety property the plan requires
("ambiguous anchors are logged to the residual ledger, never written") intact one phase early.

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `.claude/scripts/literature-combining-audit.sh` - new detector script (do not cite task numbers
  in the file per `.claude/rules/no-task-references-in-deliverables.md`)
- `specs/403_sweep_literature_corpus_combining_mark_corruption/baseline-combining-audit.{tsv,json}` - baseline artifacts

**Verification**:
```bash
bash .claude/scripts/literature-combining-audit.sh --dir baier_katoen_2008
# expect: ~819 PDF occurrences, ~791 signature=control_char, residual accounted=0
bash .claude/scripts/literature-combining-audit.sh --dir bacon_2018_broadest-necessity
# expect: 18 PDF occurrences, 18 corrupted (control_char)
bash .claude/scripts/literature-combining-audit.sh --dir rabinovich_2014
# expect: 0 corrupted (already repaired) -- the negative control
bash .claude/scripts/literature-combining-audit.sh --dir schwoon_esparza_2005
# expect: all corrupted occurrences classified signature=glyph_six
bash .claude/scripts/literature-combining-audit.sh > /tmp/full.tsv && awk -F'\t' '$3>0' /tmp/full.tsv | wc -l
# expect: ~23 directories with a non-zero corrupted count (14 dangerous + 9 glyph-six)
git diff --stat ~/Projects/Literature 2>/dev/null; echo "corpus untouched check: no writes expected"
```

---

### Phase 2: Close the residual gaps in `literature-convert.sh` [COMPLETED]

**Goal**: Make `compose_combining_overlays()` actually handle the overlay orderings this corpus
produces, so future conversions are genuinely protected and any future re-conversion of an
affected document would restore rather than re-drop negations.

**Tasks**:
- [x] Extend `_OVERLAY_REORDER_RE` to tolerate intervening horizontal whitespace between the
      combining mark and its base character (verified real: `TS(PG1 ||| PG2)̸ = TS(PG1)`), while
      still refusing to reorder across a newline or across a non-whitespace character.
      *(completed: `[ \t]{0,2}` between the mark and base groups; a self-test fixture
      (`newline-must-not-reorder`) confirms a mark/base pair separated by `\n` is left alone.)*
- [x] Extend `_OVERLAY_BASES` with the bases observed in this corpus but currently missing: `⊢`,
      `≺`, `→`, `|` (and any further bases the Phase 1 detector's base-character tally reports).
      Keep the whitelist approach — do not widen to arbitrary characters, so ordinary Latin
      diacritics stay untouched. *(completed: added `⊢≺→|⪯⊩≜⊴↣⊑≃` per the Phase 1 baseline JSON's
      base-character tally, excluding three tally entries — `T`, `L`, `C` — that are almost
      certainly false-positive base picks from dense-math-region detector noise, not real
      combining-overlay bases; deviation noted below.)*
- [x] Add an inline fixture-based self-test (runnable block or adjacent test invocation) covering:
      mark-immediately-before-base, mark-space-before-base, mark-after-base (already NFC-composable),
      accented-letter non-interference (`e` + U+0301 must stay `é`, never reordered), and
      idempotence (composing twice equals composing once). *(completed via `--self-test`; see
      exact command below. Added three fixtures beyond the plan's minimum: a `mark-tab-before-base`
      variant, the `newline-must-not-reorder` safety check, and per-new-base composition checks for
      all four plan-mandated additions plus `new-base-divides`.)*
- [x] Do not alter the engine-tier selection logic, the quality gate, or exit-code semantics.
      *(completed: verified via the pre-existing `.claude/scripts/tests/test-literature-convert.sh`
      suite — all 8 existing tests still pass unchanged after this phase's edits.)*

**Implementation deviation**: extracted `_OVERLAY_BASES`/`_OVERLAY_REORDER_RE`/
`compose_combining_overlays()` out of the inline heredoc into a new shared module,
`.claude/scripts/literature_combining_overlay.py`, imported by both the live conversion heredoc
(via `sys.path.insert` + `LITERATURE_CONVERT_SCRIPT_DIR` env var) and the new `--self-test` mode.
Not in the plan's original "Files to modify" list, but necessary to give the self-test and the
live pipeline exactly one hand-maintained copy of the regex/whitelist rather than two that could
silently drift. Also discovered and fixed a real composition gap while writing the self-test:
Unicode's canonical decomposition of "does not divide" (U+2224) is `2223 0338` (the dedicated MATH
"divides" symbol, U+2223), **not** `007C 0338` (ASCII vertical bar) — even though this corpus's
PDFs render "divides" using the plain ASCII pipe. Added a small `_CANONICAL_BASE_OVERRIDE` map
(`"|"` -> `"∣"`) applied during reordering so NFC can actually compose this case; all other
whitelisted bases already equal their own NFC-canonical base.

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `.claude/scripts/literature-convert.sh` - `_OVERLAY_BASES`, `_OVERLAY_REORDER_RE`,
  `compose_combining_overlays()` and its explanatory comment *(now imported from the new shared
  module below; a `--self-test` argument branch added near the top of the script)*
- `.claude/scripts/literature_combining_overlay.py` - **new** shared module (not in the original
  plan; see deviation note above)

**Verification**:
```bash
# fixture self-test must pass -- exact command actually used (chosen entry point):
bash .claude/scripts/literature-convert.sh --self-test
# result: "[self-test] All fixtures passed." / exit 0 (15 fixtures, 0 failures)

# pre-existing regression suite must still pass unchanged (engine-tier/quality-gate/
# exit-code guard):
bash .claude/scripts/tests/test-literature-convert.sh
# result: "Results: 8 passed, 0 failed"

# end-to-end: a 3-page slice of the Baier & Katoen PDF must now yield composed negations
python3 - <<'EOF'
import fitz, sys, importlib.util
D='/home/benjamin/Projects/Literature/sources/baier_katoen_2008/'
doc=fitz.open(D+'Baier_Katoen_2008_Principles_Model_Checking.pdf')
raw=doc[58].get_text('text')
assert 'TS(PG1 ||| PG2)' in raw
print('raw repr:', repr(raw.split('in general,')[1][:50]))
EOF
# after applying the fixed compose_combining_overlays() to that raw text, expect the
# substring "TS(PG1 ||| PG2) ≠ TS(PG1)" with a precomposed U+2260 and zero U+0338 left
```

---

### Phase 3: Repair engine (validated dry-run only) [COMPLETED]

**Goal**: Build the in-place repair tool that consumes the Phase 1 detector's JSON and rewrites
corrupted occurrences under backup, and validate it end-to-end without writing to the corpus.

**Tasks**:
- [x] Write `.claude/scripts/literature-repair-combining.sh`. Default mode is `--dry-run`; writing
      requires an explicit `--write`. *(completed)*
- [x] Backup contract: before any write to a file, mirror it to
      `$LITERATURE_DIR/.backups/combining-repair-{ISO_DATE}/sources/<dir>/<file>` preserving
      layout; never overwrite an existing backup of the same file; refuse `--write` for any file
      whose backup could not be created. Emit a sha256 manifest. *(completed: manifest at
      `.../combining-repair-{ISO_DATE}/manifest.json`, merged across runs, never overwriting an
      existing entry's hash.)*
- [x] Anchoring contract: for each corrupted occurrence, build a context window from the PDF text
      (leading context + base character + trailing context), strip all whitespace, and search the
      whitespace-stripped target markdown while maintaining an offset map back to original
      character positions. Rewrite **only** on exactly one match. Zero matches or multiple matches
      are never written — they are emitted to the residual ledger with their context.
      *(completed via a different but equivalent-safety mechanism — see deviation note below.)*
- [x] Rewrite action by signature: `control_char` -> delete the control character and replace the
      base with its precomposed negated codepoint; `glyph_six` -> delete the literal `6` and
      replace the base; `absent` -> replace the base character in place with the precomposed
      codepoint. Use one shared base->precomposed map (`=`->`≠`, `∈`->`∉`, `⊆`->`⊈`, `<`->`≮`,
      `>`->`≯`, `≡`->`≢`, `∼`->`≁`, `≤`->`≰`, `≥`->`≱`, `|`->`∤`, `⊢`->`⊬`, `≺`->`⊀`, `→`->`↛`,
      extended as the detector's base tally requires). *(completed; shared map lives in
      `literature_combining_detect.py` as `PRECOMPOSED`, imported by both the detector and the
      repair engine.)*
- [x] Idempotence: a second run over an already-repaired file must find zero corrupted occurrences
      and write nothing. *(completed by construction: a repaired occurrence re-classifies as
      `precomposed` — accounted, no action — on re-scan; verified directly, see below.)*
- [x] Emit a per-run residual ledger JSON (unrepaired occurrences with reason:
      `ambiguous_anchor` / `anchor_not_found` / `unmapped_base`). *(completed via `--ledger-json`;
      reason vocabulary extended — see Phase 1's `unanchored`-bucket deviation note plus two new
      repair-specific reasons, `unmapped_base_char` and `overlapping_edit` — documented below.)*
- [x] Validate against `bacon_2018_broadest-necessity` (18 occurrences, single markdown file) in
      dry-run only. Confirm the proposed rewrite of the named axiom reads
      `THE NECESSITY OF DISTINCTNESS: A ≠ B → L(A ≠ B)`. *(completed and confirmed byte-for-byte;
      16 of 18 occurrences proposed for rewrite, 2 remain genuinely ambiguous — see deviation
      note.)*

**Implementation deviations**:

1. **Anchoring mechanism differs from the plan's literal description, at equivalent safety.** The
   plan describes a literal-adjacent-character context window with a whitespace-stripped offset
   map. Phase 1's own notes already recorded why that literal approach fails on this corpus
   (adjacent math symbols are frequently ALSO corrupted, breaking literal-context matching) and why
   a whitespace-normalized-distance, plain-word-landmark anchor was adopted instead — that decision
   carries forward into this repair engine unchanged, since it reuses `literature_combining_detect
   .classify_occurrence()` directly rather than re-implementing anchoring a second time (avoiding
   exactly the two-hand-maintained-copies risk flagged in Phase 2). The safety property the plan
   actually cares about — **rewrite only on exactly one confident match; zero or ambiguous matches
   are never written** — holds identically.
2. **New residual-ledger reasons**: `unmapped_base_char` (a corrupted occurrence's base character
   has no entry in `PRECOMPOSED` — never observed in practice so far, but guarded rather than
   assumed) and `overlapping_edit` (two occurrences in the same file computed overlapping rewrite
   spans). `overlapping_edit` needed a further refinement, described next.
3. **Shared-span refinement (new, not in the original plan).** Multiple close-together negations in
   the same sentence can independently anchor to the IDENTICAL word-landmark-bracketed span, since
   there is no distinguishing word between them (verified real: bacon_2018's own named axiom, "A
   <mark>= B ->L(A <mark>= B)", and its "∃pqr(p<mark>=q ∧ q<mark>=r ∧ p<mark>=r)" sentence, three
   occurrences sharing one span). Before treating identical spans as an unresolvable conflict, the
   engine now looks inside the shared span for exactly as many distinct literal corruption
   instances (control-char/base or base/control-char, tolerating up to 2 intervening whitespace
   characters, mirroring Phase 2's converter fix) as there are occurrences claiming it, and splits
   them out in left-to-right order. Without this refinement, bacon_2018_broadest-necessity's own
   validation target — the named axiom — would have been REFUSED as an unresolvable overlap; with
   it, both instances resolve correctly (verified: `A ≠ B → L(A ≠ B)`, byte-for-byte). A genuine
   count mismatch still falls through to the ordinary overlap-conflict path.
4. **`bacon_2018_broadest-necessity` proposes 16, not 18, rewrites.** 2 of the 18 PDF occurrences
   (a `δ1`/`δ2` axiom-schema pair: "A = B →δABCD = C" / "A ̸= B →δABCD = D") have MULTIPLE "="
   tokens close together, one of which is not corrupted at all — the anchor cannot disambiguate
   which "=" is the true corruption site, and correctly refuses to guess, reporting
   `ambiguous_anchor` instead. This is the conservative behavior the plan's own risk table
   requires ("ambiguous...occurrences are never written — they go to the residual ledger"), not a
   defect; the two remaining occurrences are visible in the residual ledger for manual review in a
   later phase if desired (out of this phase's validation scope).

**Timing**: 2 hours

**Depends on**: 1, 2

**Files to modify**:
- `.claude/scripts/literature-repair-combining.sh` - new repair engine
- `.claude/scripts/literature_combining_detect.py` - **new** shared detection/anchoring module
  (extracted from `literature-combining-audit.sh`, not in the original plan's file list — the
  audit script was refactored into a thin CLI wrapper importing this module so the detector and
  the repair engine share exactly one anchoring implementation)

**Verification** (commands actually run, with actual results):
```bash
bash .claude/scripts/literature-repair-combining.sh --dir bacon_2018_broadest-necessity --dry-run
# ACTUAL: "16 proposed rewrite(s) across 1 file(s); 2 residual (unrepaired) occurrence(s)"
# (18 expected per plan; 2 are a genuinely ambiguous δ1/δ2 axiom-schema pair -- see deviation
# note 4 above -- NO files written either way)

grep -c $'\x0f' ~/Projects/Literature/sources/bacon_2018_broadest-necessity/bacon_2018_broadest-necessity.md
# ACTUAL: 14 -- unchanged from baseline (dry-run did not write)

ls ~/Projects/Literature/.backups/ 2>/dev/null
# ACTUAL: (nothing; exit 2) -- no backup directory created by a dry-run, confirmed

# idempotence + named-axiom correctness, verified end-to-end against a throwaway copy
# (never against the live corpus) in .../scratchpad/idem-test/:
#   1st --write: 16 rewritten, 2 residual
#   2nd --dry-run over the written copy: 0 proposed, confirming idempotence
#   detector re-scan of the written copy: precomposed=16, unanchored=2 (same 2 as above)
#   axiom line reads exactly: "THE NECESSITY OF DISTINCTNESS: A ≠ B → L(A ≠ B)."
```

**Idempotence tuning discovered during this verification**: the first idempotence attempt
revealed a real bug, not just a documentation gap -- re-scanning an ALREADY-REPAIRED file with
several nearby fixes produced false `unanchored` results for occurrences that were, in fact,
correctly repaired. Root cause: each control-char/glyph-six fix shrinks the markdown by 1-2
characters, and when several such fixes land within one word-landmark window, the cumulative
shrinkage pushed later occurrences' PDF-measured expected-gap estimate outside the (then-symmetric
±12) slack tolerance. Fixed by widening the tolerance ASYMMETRICALLY in
`literature_combining_detect.py` (`slack_low=90` downward / `slack_high=15` upward) -- a repair
can only ever shrink text, never grow it, so only the downward direction needed real headroom.
Re-verified this did not reintroduce ambiguous-match regressions across all six previously-checked
directories (baier_katoen_2008, rabinovich_2014, verbrugge_2004, schwoon_esparza_2005,
bacon_2018_broadest-necessity, venema_1993, goldblatt_2003) before proceeding. The Phase 1 baseline
artifacts were regenerated with this final tuning (see Phase 1 notes) so Phase 9's final-vs-
baseline diff compares like-for-like methodology, not an earlier, less-tuned detector pass.

---

### Phase 4: Repair the control-character class [NOT STARTED]

**Goal**: Repair `baier_katoen_2008` (12 markdown parts) and `bacon_2018_broadest-necessity` —
835 of the 1,163 dangerous occurrences, 72% of total blast radius — and prove the repair engine
correct on the highest-evidence case before widening.

**Tasks**:
- [ ] Run the repair engine with `--write` for `bacon_2018_broadest-necessity` first (smallest,
      fully spot-checked in research), verify, then for `baier_katoen_2008`.
- [ ] Confirm backups exist and the sha256 manifest is recorded under the task directory.
- [ ] Verify the four sentence-level spot-checks from the research report now read correctly:
      the `TS(PG1 ||| PG2) ≠ ...` inequality, the `τ ∉ H` membership, the two-inequality
      `TS1 ∥H (TS2 ∥H′ TS3) ≠ ... for H ≠ H′` sentence, and the Bacon named axiom.
- [ ] Record, without fixing, the count of remaining non-negation control characters in
      `baier_katoen_2008` (expected ~6,900 across ~23 further code points) as a residual finding
      for a separate task.
- [ ] Re-run the detector for both directories and confirm zero corrupted occurrences remain, or
      log each exception to the residual ledger.

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `~/Projects/Literature/sources/baier_katoen_2008/Baier_Katoen_2008_part01..12.md` - negation repair
- `~/Projects/Literature/sources/bacon_2018_broadest-necessity/bacon_2018_broadest-necessity.md` - negation repair
- `specs/403_sweep_literature_corpus_combining_mark_corruption/residual-ledger.json` - created/appended

**Verification**:
```bash
bash .claude/scripts/literature-combining-audit.sh --dir baier_katoen_2008
bash .claude/scripts/literature-combining-audit.sh --dir bacon_2018_broadest-necessity
# expect for both: corrupted = 0

grep -c 'TS(PG1 ||| PG2 ) ≠ TS(PG1 )' ~/Projects/Literature/sources/baier_katoen_2008/Baier_Katoen_2008_part01.md
grep -c 'τ ∉ H' ~/Projects/Literature/sources/baier_katoen_2008/Baier_Katoen_2008_part01.md
grep -c 'NECESSITY OF DISTINCTNESS' ~/Projects/Literature/sources/bacon_2018_broadest-necessity/bacon_2018_broadest-necessity.md
# and read that line: must contain "A ≠ B" twice, not "A = B"

ls ~/Projects/Literature/.backups/combining-repair-*/sources/baier_katoen_2008/ | wc -l   # expect 12
bash .claude/scripts/literature-repair-combining.sh --dir baier_katoen_2008 --dry-run     # expect 0 proposed (idempotent)
```

---

### Phase 5: Repair the true-drop class (unmixed documents) [NOT STARTED]

**Goal**: Repair the dangerous-class documents whose negations were dropped entirely and which
have no known LaTeX-macro-preserved sections.

**Tasks**:
- [ ] Repair, in this order: `libkin_2004_ch3_ch7` (168), `troelstra_schwichtenberg_lectures` (57),
      `marinmoralesstrassburger_2021_fully_labelled_proof_system_intuitionistic_modal` (16),
      `fine_2010_some-puzzles-of-ground` (12), `venema_2001` (2), `van_doorn_2015` (1).
- [ ] Resolve the `troelstra_schwichtenberg_lectures` caveat first: the research report found the
      directory holds only `source.pdf` and `PROVENANCE.txt` with no converted markdown and no
      matching `index.json` id. If there is no markdown to repair, record it as
      `not_yet_converted` and skip — do not convert it as part of this task.
- [ ] Confirm each directory's backup and per-file rewrite count before moving to the next.
- [ ] Append every unrepaired occurrence to the residual ledger with its reason and context.

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `~/Projects/Literature/sources/{libkin_2004_ch3_ch7,marinmoralesstrassburger_2021_*,fine_2010_some-puzzles-of-ground,venema_2001,van_doorn_2015}/*.md` - negation repair
- `specs/403_sweep_literature_corpus_combining_mark_corruption/residual-ledger.json` - appended

**Verification**:
```bash
for d in libkin_2004_ch3_ch7 troelstra_schwichtenberg_lectures \
         marinmoralesstrassburger_2021_fully_labelled_proof_system_intuitionistic_modal \
         fine_2010_some-puzzles-of-ground venema_2001 van_doorn_2015; do
  bash .claude/scripts/literature-combining-audit.sh --dir "$d"
done
# expect: corrupted = 0 for every directory that has converted markdown;
#         troelstra_schwichtenberg_lectures reported as having no markdown to audit
jq '[.[] | select(.reason)] | length' specs/403_sweep_literature_corpus_combining_mark_corruption/residual-ledger.json
```

---

### Phase 6: Repair the mixed documents with per-section review [NOT STARTED]

**Goal**: Repair the five documents that are only partially corrupted, without regressing the
sections already correct via LaTeX-macro transcription.

**Tasks**:
- [ ] Handle `venema_1993` (28 of 38 corrupted), `venema_1997` (14 of 19), `derijke_1995` (13 of
      18), `goldblatt_2003` (14 of 15), `obendrauf_2024` (2 of 6), `venema_1993_since` (1 of 2).
- [ ] Before writing each document, produce and review a dry-run diff. Confirm that every
      occurrence the detector classified as `latex_macro` or `bare_pair` is absent from the
      proposed-rewrite set — those sections must be byte-identical after the run.
- [ ] Write with `--write`, then diff each repaired file against its backup and confirm the number
      of changed hunks equals the number of proposed rewrites (no incidental edits).
- [ ] Append unrepaired occurrences to the residual ledger.

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `~/Projects/Literature/sources/{venema_1993,venema_1997,derijke_1995,goldblatt_2003,obendrauf_2024,venema_1993_since}/*.md` - negation repair
- `specs/403_sweep_literature_corpus_combining_mark_corruption/residual-ledger.json` - appended

**Verification**:
```bash
for d in venema_1993 venema_1997 derijke_1995 goldblatt_2003 obendrauf_2024 venema_1993_since; do
  bash .claude/scripts/literature-combining-audit.sh --dir "$d"
done
# expect: corrupted = 0; accounted counts for latex_macro/bare_pair unchanged from Phase 1 baseline

# LaTeX-macro sections must be untouched
B=$(ls -d ~/Projects/Literature/.backups/combining-repair-*/ | tail -1)
diff <(grep -o '\\not[a-z=]*' "$B/sources/venema_1993/"*.md | sort | uniq -c) \
     <(grep -o '\\not[a-z=]*' ~/Projects/Literature/sources/venema_1993/*.md | sort | uniq -c)
# expect: no differences
```

---

### Phase 7: Repair the `6=` glyph-substitution class [NOT STARTED]

**Goal**: Replace the visible `6=`-style glyph substitution with correct precomposed negations in
the 9 affected documents, rewriting only at positions PDF ground truth confirms.

**Tasks**:
- [ ] Repair `arisakadasstrassburger_2015_onnestedsequentsforconstructivemodallogics`,
      `courcoubetis_1992`, `kupferman_vardi_2001`, `massacci_2000`, `pacheco_2024`,
      `piterman_2007`, `schewe_2009`, `schwoon_esparza_2005`, `yan_2008` (114 occurrences total).
- [ ] Enforce the safety property explicitly: the engine must never perform a pattern-only `6=`
      substitution. Every rewrite must be anchored to a confirmed U+0338 position in the PDF text.
- [ ] Before writing, count occurrences of a literal digit `6` immediately followed by a relation
      character in each target file, and after writing confirm the delta equals exactly the number
      of anchored rewrites — no legitimate `6` was consumed.
- [ ] Append unrepaired occurrences to the residual ledger.

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `~/Projects/Literature/sources/{arisakadasstrassburger_2015_*,courcoubetis_1992,kupferman_vardi_2001,massacci_2000,pacheco_2024,piterman_2007,schewe_2009,schwoon_esparza_2005,yan_2008}/*.md` - glyph-substitution repair
- `specs/403_sweep_literature_corpus_combining_mark_corruption/residual-ledger.json` - appended

**Verification**:
```bash
for d in arisakadasstrassburger_2015_onnestedsequentsforconstructivemodallogics courcoubetis_1992 \
         kupferman_vardi_2001 massacci_2000 pacheco_2024 piterman_2007 schewe_2009 \
         schwoon_esparza_2005 yan_2008; do
  bash .claude/scripts/literature-combining-audit.sh --dir "$d"
done
# expect: corrupted = 0 for all nine

grep -o 'goal ≠ ⊥' ~/Projects/Literature/sources/schwoon_esparza_2005/*.md | head
# expect: the report's contrast example now reads "goal ≠ ⊥", not "goal 6= ⊥"
grep -c '6=' ~/Projects/Literature/sources/schwoon_esparza_2005/*.md
# expect: 0, or only occurrences the ledger records as legitimate digit-6 text
```

---

### Phase 8: Wire the detector into the fidelity audit and re-stamp the index [NOT STARTED]

**Goal**: Add the combining-mark signal to `literature-fidelity-audit.sh` as an additive,
recomputed field, and correct the now-known-false `provenance_fidelity` picture durably.

**Tasks**:
- [ ] Add a combining-mark check to `literature-fidelity-audit.sh` that reuses the Phase 1
      detector's logic via its own PyMuPDF-based extraction path, kept **distinct** from the
      existing `pdf_word_count()` `pdftotext -layout` call (pdftotext itself substitutes `6` for
      the overlay and cannot serve as ground truth).
- [ ] Surface the result as new fields stamped alongside `provenance_fidelity` — do not modify the
      `ratio >= RATIO_THRESHOLD` gate, the six-value enum, or any downstream banner logic:
      `combining_mark_checked` (bool), `combining_mark_dropped` (bool),
      `combining_marks_missing` (int).
- [ ] Add the new columns to the TSV report output and to the `--dry-run` population summary.
- [ ] Preserve the script's idempotence contract: a second `--write` over an unchanged corpus must
      produce no diff.
- [ ] Back up `index.json`, run `--dry-run` and review, then run `--write`.
- [ ] Review the resulting `index.json` diff: confirm the 14 previously-false `verified_conversion`
      entries now carry `combining_mark_dropped: false` with `combining_marks_missing: 0` (the
      stamp is now *true*), and that no `provenance_fidelity` value changed unexpectedly. Note
      that `libkin_2004_ch3_ch7`'s inconsistent stamp will be recomputed as a side effect.

**Timing**: 2 hours

**Depends on**: 5, 6, 7

**Files to modify**:
- `.claude/scripts/literature-fidelity-audit.sh` - additive combining-mark check, new stamped
  fields, report columns, header documentation
- `~/Projects/Literature/index.json` - re-stamped (backed up first)

**Verification**:
```bash
cp ~/Projects/Literature/index.json /tmp/index.pre.json
bash .claude/scripts/literature-fidelity-audit.sh --dry-run > /tmp/audit.tsv 2>/tmp/audit.err
head -1 /tmp/audit.tsv    # expect new combining_* columns present
awk -F'\t' 'NR>1 && $NF>0' /tmp/audit.tsv | wc -l   # expect 0 remaining dropped-mark directories

bash .claude/scripts/literature-fidelity-audit.sh --write
jq -r '.entries[] | select(.id|startswith("baier_katoen_2008")) | "\(.id) \(.provenance_fidelity) \(.combining_mark_dropped) \(.combining_marks_missing)"' ~/Projects/Literature/index.json
# expect: verified_conversion false 0   (for all 12 parts)

# idempotence
cp ~/Projects/Literature/index.json /tmp/index.a.json
bash .claude/scripts/literature-fidelity-audit.sh --write
diff /tmp/index.a.json ~/Projects/Literature/index.json && echo "IDEMPOTENT OK"
```

---

### Phase 9: Re-chunk, rebuild search index, final verification [NOT STARTED]

**Goal**: Propagate repairs into the chunk files and FTS database, and close the task with a
corpus-wide clean detector run plus a complete residual ledger.

**Tasks**:
- [ ] Re-chunk every repaired document with `literature-chunk.sh` using each document's existing
      `doc_id` so chunk identity and index paths stay consistent (note: `baier_katoen_2008` alone
      has 1,265 chunk files plus `chunks.json`).
- [ ] Rebuild the global FTS database: `literature-build-index.sh --global`.
- [ ] Confirm a repaired sentence is retrievable through `literature-search.sh` with the corrected
      negation.
- [ ] Run the detector corpus-wide and diff against the Phase 1 baseline; every previously
      corrupted directory must now report zero, or appear in the residual ledger.
- [ ] Finalise `residual-ledger.json` and record the permanent scope boundary: the 64 corpus
      directories with no on-disk PDF cannot be checked by this methodology, and
      `baier_katoen_2008`'s non-negation control-character corruption is left unfixed.
- [ ] Write the implementation summary to
      `specs/403_sweep_literature_corpus_combining_mark_corruption/summaries/01_sweep-combining-mark-corruption-summary.md`.

**Timing**: 1.5 hours

**Depends on**: 8

**Files to modify**:
- `~/Projects/Literature/sources/*/chunk_*.md`, `~/Projects/Literature/sources/*/chunks.json` - regenerated for repaired documents
- `~/Projects/Literature/.literature.db` - rebuilt
- `specs/403_sweep_literature_corpus_combining_mark_corruption/residual-ledger.json` - finalised
- `specs/403_sweep_literature_corpus_combining_mark_corruption/summaries/01_sweep-combining-mark-corruption-summary.md` - new

**Verification**:
```bash
bash .claude/scripts/literature-build-index.sh --global
bash .claude/scripts/literature-search.sh "handshake actions distinguished" | head -20
# expect: a Baier & Katoen chunk containing "τ ∉ H"

bash .claude/scripts/literature-combining-audit.sh > /tmp/final.tsv
diff <(awk -F'\t' '{print $1, $3}' specs/403_sweep_literature_corpus_combining_mark_corruption/baseline-combining-audit.tsv) \
     <(awk -F'\t' '{print $1, $3}' /tmp/final.tsv)
# expect: every previously non-zero corrupted count is now 0

awk -F'\t' 'NR>1 && $3>0' /tmp/final.tsv
# expect: no rows, or only rows explained in residual-ledger.json
jq 'length' specs/403_sweep_literature_corpus_combining_mark_corruption/residual-ledger.json
```

---

## Testing & Validation

- [ ] Detector reproduces the research report's document classification (14 dangerous, 9
      glyph-substitution), with any divergence documented rather than silently absorbed.
- [ ] `rabinovich_2014` and `verbrugge_2004` serve as negative controls: zero corrupted
      occurrences before and after all repairs.
- [ ] Converter fixture self-test passes, including the accented-letter non-interference case.
- [ ] Every repair phase is idempotent: a second `--dry-run` after `--write` proposes zero
      rewrites.
- [ ] Every write is preceded by a verified backup; the sha256 manifest matches the pre-repair
      file contents.
- [ ] `literature-fidelity-audit.sh --write` remains idempotent after the additive change.
- [ ] Repaired text is retrievable via `literature-search.sh` after the FTS rebuild.
- [ ] Corpus-wide final detector run reports zero corrupted occurrences outside the residual
      ledger.
- [ ] No script authored by this task cites a task number (per
      `.claude/rules/no-task-references-in-deliverables.md`).

## Artifacts & Outputs

- `.claude/scripts/literature-combining-audit.sh` - standalone PDF-vs-markdown combining-mark detector
- `.claude/scripts/literature-repair-combining.sh` - backup-guarded, anchored in-place repair engine
- `.claude/scripts/literature-convert.sh` - overlay-composition gaps closed (whitespace tolerance, widened base whitelist, self-test)
- `.claude/scripts/literature-fidelity-audit.sh` - additive combining-mark signal and stamped fields
- `~/Projects/Literature/index.json` - re-stamped with corrected, durable fidelity fields
- `~/Projects/Literature/sources/*/` - repaired markdown, regenerated chunks
- `~/Projects/Literature/.backups/combining-repair-{ISO_DATE}/` - full pre-repair backup tree
- `specs/403_sweep_literature_corpus_combining_mark_corruption/baseline-combining-audit.{tsv,json}` - pre-repair baseline
- `specs/403_sweep_literature_corpus_combining_mark_corruption/residual-ledger.json` - unrepaired-occurrence ledger
- `specs/403_sweep_literature_corpus_combining_mark_corruption/summaries/01_sweep-combining-mark-corruption-summary.md` - implementation summary

## Rollback/Contingency

- **Corpus markdown**: every modified file is mirrored to
  `$LITERATURE_DIR/.backups/combining-repair-{ISO_DATE}/` before its first write, with a sha256
  manifest. Restore by copying the backup tree back over `sources/`, then re-running
  `literature-chunk.sh` for the restored documents and `literature-build-index.sh --global`.
- **`index.json`**: backed up before the Phase 8 `--write`. Restore by copying the backup back; the
  audit script's own `--write` is idempotent, so a subsequent re-run reproduces the same state.
- **Chunks and FTS database**: derived artifacts, fully regenerable from the markdown by
  `literature-chunk.sh` + `literature-build-index.sh --global`. No backup required.
- **Scripts**: all changes to `.claude/scripts/` are in-repo and revertible with git. Phases 1-3
  produce no corpus mutations at all, so aborting before Phase 4 leaves the corpus untouched.
- **Partial-phase abort**: repair phases operate directory-by-directory and are idempotent, so a
  phase interrupted mid-run can be resumed by re-running the same command; already-repaired
  directories report zero proposed rewrites and are skipped.
