# Research Report: Task #404

**Task**: 404 - complete_combining_negation_repair
**Started**: 2026-07-27T18:15:08Z
**Completed**: 2026-07-27T18:18:25Z
**Effort**: ~1 session (codebase-only research, no web search needed)
**Dependencies**: task 403 (produced the detector, repair engine, and residual ledger this task builds on)
**Sources/Inputs**: - Codebase (`.claude/scripts/literature_combining_detect.py`,
  `literature-repair-combining.sh`, `literature-combining-audit.sh`), the live
  `~/Projects/Literature` corpus, `specs/403_.../residual-ledger.json` (824 entries),
  `~/Projects/Literature/index.json`, `specs/403_.../summaries/01_...-summary.md`
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The 819 repairable residual occurrences split into two very different problems, not one: 82
  (10%) are pure configuration gaps in the shared detection module (extend `PRECOMPOSED`, widen
  gap-classification patterns) with **zero new anchoring logic required**; the remaining 714
  ambiguous/unanchored occurrences need a genuinely stronger anchor, and the fix differs sharply
  by document.
- **`baier_katoen_2008` (484 residual, 59% of total) is dominated by `ambiguous_anchor` (362 of
  484)**, not by missing evidence. Its 12 `Baier_Katoen_2008_partNN.md` files are a clean,
  non-overlapping, in-order split of one converted markdown stream (verified: part01's last
  sentence continues verbatim as part02's first sentence, no duplication or gap). The word-anchor
  search is un-scoped across all 12 files at once, so ordinary textbook vocabulary
  ("transition", "state") recurs across files and produces spurious extra matches. Resolving
  which part-file a given PDF offset falls in *before* anchoring — using the same
  `frac = idx/pdf_len` proportional-position technique the module already uses for its
  `latex_macro` fallback — is directly applicable and should collapse most of this category.
- **`libkin_2004_ch3_ch7` (167 residual, second-largest) is a different failure class entirely.**
  159 of 167 are `anchor_not_found`, and the document's `index.json` `word_ratio` is `0.0187` —
  the converted markdown (2,682 words) is a heavily condensed paraphrase of a 2.2MB, two-chapter
  PDF, not a full transcription. Verified directly: the anchor words genuinely are not present in
  the markdown because that content was never transcribed, not because the anchor algorithm
  failed to find them. No anchoring strategy can repair text that was never converted. This
  document needs a fidelity/re-conversion decision, not an anchoring fix, and should very likely
  be one of the DoD's "individually-justified, human-reviewable" residuals rather than a target
  for 100% repair. All eight other multi-hundred/multi-ten-occurrence documents checked
  (`venema_1993`, `derijke_1995`, `venema_1997`, `goldblatt_2003`, `fine_2010`,
  `marinmoralesstrassburger_2021`, `piterman_2007`, `kupferman_vardi_2001`) have healthy
  `word_ratio` (0.92-1.07) — libkin is the outlier, not the pattern.
- The `unrecognized_gap` (69) cases split into two distinct sub-causes: 24/69 (`=`), 11 (`∈`),
  7 (`≈`), and others are likely narrow gap-window misses fixable by loosening
  `classify_gap_text`'s tolerance; but 12/69 are literal `TS ̸|= Psafe`-style turnstile
  occurrences where PyMuPDF extracts the two-character sequence `|` `=` from the PDF as the
  "base", yet the corresponding markdown span never contains a literal `|` at all (it was very
  likely rendered through a different code path, e.g. as `⊨`/`⊭` directly, or the two characters
  landed with unrelated text between them). This is a genuine base-character-model gap: `find_base`
  and `PRECOMPOSED` both assume a single-character base, but this corpus's `|=` (models/satisfies)
  relation is a compound base that needs its own handling, not a `PRECOMPOSED` entry.
- The `unmapped_base_char` (13) cases are overwhelmingly `≈` (U+2248, "almost equal to"): 12 of
  13 sampled contexts show `≈div`/`≈TS`/`≈obs`-style relations that should read `⊄̸≈` →
  `≉` (U+2249). `PRECOMPOSED` already has `∼` (∼, tilde operator) mapped but is missing
  `≈` (≈) entirely — this is a one-line dict addition plus a fixture-harness case, exactly
  the "extend the composition map" quick win the task description names.
- The multi-file re-chunking blocker (`baier_katoen_2008`, `venema_1993`) has a concrete, checkable
  answer for `baier_katoen_2008`: the 12 part files are proven contiguous (no overlap/gap at the
  part01/part02 boundary), so the correct re-chunking procedure is "concatenate the 12 parts in
  filename order into one temporary stream, run the existing single-file `literature-chunk.sh`
  over it once with `--doc-id baier_katoen_2008`, discard the temp file" — the same
  concatenate-then-chunk process task 403 suspected produced the original 1,265-chunk manifest,
  now doable *verifiably* because task 403 already proved the parts are gapless. `venema_1993` is
  structurally different (9 semantically-titled `secNN_*.md` section files, each already its own
  `index.json` entry with its own title) and should be re-verified for gaplessness/overlap
  independently before assuming the same concatenation approach applies.
- The upstream "port scripts into the literature extension source store" task has **not landed**:
  `.claude/` (the entire directory, including `.claude/scripts/` and `.claude/extensions/`) is
  git-ignored in this repository (`.gitignore:81` matches `/.claude`), and no
  `.claude/extensions/*/context/**/*combining*` file exists on disk. This task should therefore
  work directly against the deployed `.claude/scripts/` copies as instructed by the task's
  tooling note, and flag (not attempt) the extension-source port as a separate coordination item.

## Context & Scope

This is a `general`-type follow-on task to the sweep in `specs/403_...` (status `COMPLETED`),
which built the detector/repair engine/audit-signal tooling and repaired 418 of 1,237
baseline-corrupted combining-mark (U+0338) negation occurrences (34%), stopping deliberately at
every ambiguous or unanchorable case rather than guessing. The 819 remaining "repairable" plus 5
"note" entries are fully recorded in `specs/403_.../residual-ledger.json`, each carrying the PDF
ground truth (file, char offset, base char, context window) that made this task tractable in
principle. Scope is bounded to `file_scope`: the live corpus under `~/Projects/Literature/sources/`
and `index.json`, plus the four `.claude/scripts/literature-{repair-combining,combining-audit}.sh`
/ `literature_combining_{detect,overlay}.py` tool files. This research pass characterizes *why*
each residual category failed to anchor, validates the task description's own candidate
directions against the actual data, and identifies which residuals are genuinely
anchoring-algorithm gaps versus something else (document fidelity, compound-base modeling) that
no anchoring improvement can fix.

## Findings

### Codebase Patterns

**Shared anchoring module** (`literature_combining_detect.py`, imported identically by the
detector, repair engine, and fidelity audit — no independent re-implementations):

- `find_base(text, idx)`: locates the single character adjacent to a `̸` mark in the raw
  PyMuPDF-extracted PDF text, preferring the character *after* the mark, falling back to *before*.
  Never crosses a newline. This is where the compound-base (`|=`) blind spot originates — it only
  ever returns one character.
- `PRECOMPOSED` (line 23-40): a `base_char -> negated_codepoint` dict, 16 entries. Missing `≈`
  (U+2248 -> U+2249) confirmed against the ledger (12 of 13 `unmapped_base_char` entries).
- `nearest_word` / `_find_word_in_window`: finds the nearest run of >=4 ASCII letters on each side
  of the corruption complex in the **PDF** text (proximity-preferred, length as tiebreak), used as
  the anchor landmark pair.
- `classify_occurrence`: builds a regex `word_before(.{gap_min,gap_max}?)word_after` (whitespace-
  normalized expected-gap estimate with asymmetric slack: -90/+15 chars) and runs it against
  **every** markdown file in the directory (`md_texts_raw`, one file at a time, `total_matches`
  summed across all files). `total_matches == 1` -> uniquely anchored, safe to repair.
  `total_matches == 0` -> `anchor_not_found` (with a `latex_macro` fuzzy-window fallback keyed on
  `frac = idx / pdf_len`). `total_matches > 1` -> `ambiguous_anchor`. **This per-directory,
  all-files-at-once search is exactly what makes multi-file documents disproportionately prone to
  `ambiguous_anchor`** — a landmark word appearing once in each of 12 part files produces 12
  matches instantly, vs. a single-file document where the same word can only match within that
  one file's own text.
- `classify_gap_text`: given a matched gap substring, requires the literal `base_char` (or its
  `PRECOMPOSED` replacement) to be *present* in the gap, then classifies by what's adjacent
  (`bare_pair` if another `̸` present, `glyph_six` if a literal "6", `control_char` if a
  low-codepoint control char, else `absent`). Returns `None` -> `unrecognized_gap` when the gap
  doesn't contain the base char at all — confirmed as the `|=`/turnstile compound-base failure
  mode above.

**Repair engine** (`literature-repair-combining.sh`, Python heredoc): acts only on
`{control_char, glyph_six, absent}` signatures with a `PRECOMPOSED` entry; narrows every accepted
edit to a precise sub-span via `_find_sub_spans` (never uses the raw anchor-search gap as the
edit region — this was the exact bug task 403 caught and fixed); enforces a 6-char per-edit span
cap and a whole-file word-count circuit breaker; backs up before writing (sha256-verified,
never overwrites an existing same-day backup); `--dry-run` default, `--write` explicit;
`--ledger-json` emits residual entries as JSON. This engine is sound and safe as-is — the
required work is almost entirely upstream, in `literature_combining_detect.py`'s classification
logic, plus the two document-specific problems below.

### Residual Category Root Causes (verified against the live ledger and corpus, not assumed)

| Category | Count | Root cause (verified) | Fix class |
|---|---|---|---|
| `unmapped_base_char` | 13 | `≈` (U+2248) missing from `PRECOMPOSED` (12/13 sampled) | Config: add dict entry + fixture |
| `unrecognized_gap` (non-`\|`) | ~57 | Gap-window/whitespace tolerance edge cases across `=`,`∈`,`≜`,`≺`,`⊆`,`⊩` bases | Config: widen `classify_gap_text` tolerance |
| `unrecognized_gap` (`\|`) | 12 | Compound base `\|=` (turnstile/satisfies) — markdown span never contains literal `\|` | New logic: compound-base detection, not a `PRECOMPOSED` entry |
| `ambiguous_anchor` in `baier_katoen_2008` | 362 | Un-scoped cross-part-file word search on a verified-contiguous 12-file document | New logic: PDF-offset -> part-file resolution before anchoring |
| `anchor_not_found` in `libkin_2004_ch3_ch7` | 159 | Document fidelity gap (`word_ratio` 0.0187) — content genuinely absent from markdown | **Not an anchoring bug** — needs fidelity/re-conversion decision |
| `overlapping_edit` | 17 | Multiple occurrences' narrowed sub-spans collide within one gap | Likely resolved automatically once part-scoping / compound-base fixes reduce false-positive gap widths |
| `narrow_failed` | 6 | `_find_sub_spans` can't isolate a clean literal sub-span in the gap | Case-by-case; small enough for manual review |
| `chunks_not_regenerated` | 2 | `literature-chunk.sh` has no multi-file-continuation mode | Concatenate-then-chunk (verified feasible for `baier_katoen_2008`; must re-verify for `venema_1993`) |

### External Resources

None consulted — this is a pure codebase/corpus task with no external API, library, or
documentation dependency; the existing tooling and ledger are self-contained ground truth.

### Recommendations

1. **Do the two config-only quick wins first** (lowest risk, ~82 occurrences, no new anchoring
   logic): add `≈: ≉` to `PRECOMPOSED`; extend `literature-convert.sh --self-test`'s
   fixture set with a `≈` case; widen `classify_gap_text`'s non-`|` tolerance per the sampled
   `unrecognized_gap` contexts above.
2. **Build PDF-offset -> part-file resolution as a new, explicit step in `classify_occurrence`
   for multi-file documents**, gated on `len(md_texts_raw) > 1`: compute a cumulative
   character-offset table across `md_texts_raw` in file order (already available — `find_md_paths`
   sorts by filename, and part filenames sort correctly), then use the existing
   `frac = idx / pdf_len` proportional estimate (already proven in the `latex_macro` fallback) to
   select a *candidate* part-file (with a small fallback window spanning into the adjacent part,
   to handle boundary occurrences) before running the word-anchor regex — scoping the search to
   1-2 files instead of all 12 should collapse the bulk of `baier_katoen_2008`'s 362
   `ambiguous_anchor` entries into uniquely-anchored matches. Re-verify the part01/part02
   contiguity spot-check (done in this research pass) across a few more part boundaries before
   trusting the cumulative-offset table corpus-wide.
3. **Treat `libkin_2004_ch3_ch7` as a separate track, not an anchoring problem.** Before spending
   any anchoring effort on its 167 residual entries, get an explicit decision (from the
   task's DoD "individually-justified, human-reviewable reason" clause): either (a) accept its
   residuals as permanently unrepairable-by-this-methodology and document the `word_ratio: 0.0187`
   fidelity gap as the per-occurrence justification (fastest, matches the DoD's own escape valve),
   or (b) spin off a re-conversion task for this document specifically (out of this task's
   `file_scope`, which is negation-repair tooling, not general re-conversion). Recommend (a) for
   this task's scope, with a one-line follow-up recommendation for (b).
4. **Add compound-base detection as a distinct code path**, not a `PRECOMPOSED` entry: detect when
   `find_base`'s single character is part of a recognized multi-char relation
   (`\|=` for now; keep the list short and evidence-driven) and search for the *pair* in markdown
   rather than the lone `\|`. This is new logic, scoped narrowly, and should only need to cover
   the one confirmed compound (`\|=`) unless further sampling in implementation surfaces others.
5. **Re-chunking**: verify `baier_katoen_2008`'s cumulative-offset table (step 2) also validates
   the "clean concatenation" assumption end-to-end (no dropped/duplicated content across all 12
   part boundaries, not just part01/part02), then run
   `cat Baier_Katoen_2008_part{01..12}.md > /tmp/concat.md && literature-chunk.sh /tmp/concat.md
   sources/baier_katoen_2008/ --doc-id baier_katoen_2008` (replacing the existing 1,265-chunk
   manifest), verify chunk count/coverage sanity, then rebuild the global FTS index. For
   `venema_1993`, first check whether its 9 titled section files are meant to be chunked
   *individually* (each already has its own `index.json` entry with a distinct title/section,
   unlike `baier_katoen_2008`'s uniform part files) rather than concatenated — the existing
   `chunks.json` metadata and section titles suggest venema's original chunking may have been
   per-section, not concat-then-split, which would mean a different (and likely simpler) fix than
   baier_katoen's.
6. **Order of work for a planner**: (1) config quick wins, (2) `baier_katoen_2008` part-scoping
   (highest-yield single change), (3) compound-base `|=` handling, (4) libkin_2004 DoD
   documentation decision, (5) remaining small-count documents via the now-strengthened generic
   anchor (re-run the detector after 1-3 land and re-triage what's left before deciding whether
   any of it needs bespoke handling), (6) re-chunking both multi-file documents, (7) rebuild FTS +
   re-stamp `index.json` combining-mark fields, (8) retrieval verification via
   `literature-search.sh` for a sample of newly-repaired sentences in both re-chunked documents.

## Decisions

- Scoped this research to root-cause verification against the live ledger/corpus rather than
  prototyping fixes — task 404 is `general`-type research, and the anchoring/chunking changes
  below are non-trivial enough (new PDF-offset-resolution logic, a new compound-base code path,
  an unverified multi-file chunking procedure) to warrant a planning pass before implementation.
- Recommended libkin_2004_ch3_ch7 be treated as a DoD-sanctioned documented residual rather than
  an implementation target, based on directly re-reading its markdown and comparing to its PDF
  size/word_ratio — this is a scope decision a planner should confirm, not silently inherit.

## Risks & Mitigations

- **Part-file offset resolution could be wrong at part boundaries** (an occurrence near the
  part01/part02 seam might resolve to the wrong candidate file). Mitigation: search a small
  adjacent-file window (not just the single best-fit file) when the proportional estimate lands
  within some margin of a part boundary, falling back to the current all-files search if the
  narrowed search finds zero matches (never let scoping reduce recall to zero).
- **Compound-base handling scope creep**: `\|=` is the only compound confirmed by this research;
  do not preemptively build a general N-character-base framework without further evidence from
  the other `unrecognized_gap` bases (`≜`, `≺`, `⊩`, etc.) during implementation triage — check
  each individually first since most single-`unrecognized_gap` non-`|` bases are likely
  gap-window tolerance issues, not compound bases.
- **`venema_1993` re-chunking assumption**: do not assume the same concatenate-then-chunk fix that
  applies to `baier_katoen_2008` applies here without first confirming whether its 9 section files
  were originally chunked individually or concatenated — get this wrong and the fix could produce
  a `chunks.json` that mismatches the section-titled `index.json` entries already pointing at
  those exact section files.
- **100% DoD target vs. libkin's fidelity gap**: if a future planner/implementer is not made aware
  of the `word_ratio: 0.0187` finding, they risk spending significant anchoring-algorithm effort
  on a document where no anchoring algorithm can succeed. This report's findings section should be
  read before any libkin_2004-specific work begins.

## Context Extension Recommendations

- **Topic**: Multi-file/shared-`doc_id` document handling for the literature extension's chunking
  and combining-mark tooling.
- **Gap**: No existing context file documents the "part-split" vs. "section-split" multi-file
  patterns this research found in the corpus (`baier_katoen_2008`'s uniform part-NN split vs.
  `venema_1993`'s titled-section split), nor the PDF-offset-to-markdown-position proportional
  estimation technique (`frac = idx / pdf_len`) already used once in
  `literature_combining_detect.py` and recommended here for reuse.
- **Recommendation**: once this task's implementation lands a working part-file resolution
  approach, capture it as a literature-extension context/pattern file (e.g. under
  `.claude/extensions/literature/context/patterns/multi-file-documents.md`, if that extension
  source location exists once the separate upstream porting task lands) so future multi-file
  corpus documents don't re-derive this from scratch.

## Appendix

### Searches/commands used

```bash
jq '.active_projects[] | select(.project_number == 404)' specs/state.json
jq -r '.[] | .reason' specs/403_.../residual-ledger.json | sort | uniq -c
jq '[.[] | select(.dir=="baier_katoen_2008")] | group_by(.reason) | map({reason, count: length})' ...
jq -r '.entries[] | select(.path // "" | test("libkin"; "i")) | {id, word_ratio, provenance_fidelity}' ~/Projects/Literature/index.json
wc -w ~/Projects/Literature/sources/libkin_2004_ch3_ch7/*.md   # 2,682 words vs a 2.2MB two-chapter PDF
tail -c 200 .../Baier_Katoen_2008_part01.md; head -c 200 .../Baier_Katoen_2008_part02.md   # contiguity check
git check-ignore -v .claude/scripts/literature-repair-combining.sh   # confirms /.claude gitignored
```

### Key files read

- `.claude/scripts/literature_combining_detect.py` (full)
- `.claude/scripts/literature-repair-combining.sh` (full)
- `specs/403_sweep_literature_corpus_combining_mark_corruption/summaries/01_...-summary.md`
- `specs/403_sweep_literature_corpus_combining_mark_corruption/residual-ledger.json` (824 entries,
  queried via `jq`, not fully read inline)
- `~/Projects/Literature/index.json` (queried via `jq`)
- `~/Projects/Literature/sources/baier_katoen_2008/chunks.json`,
  `~/Projects/Literature/sources/venema_1993/chunks.json` (structure only)
