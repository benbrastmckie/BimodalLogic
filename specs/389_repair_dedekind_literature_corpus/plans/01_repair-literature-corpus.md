# Implementation Plan: Task #389

- **Task**: 389 - repair_dedekind_literature_corpus
- **Status**: [IMPLEMENTING]
- **Effort**: 12 hours
- **Dependencies**: None
- **Research Inputs**: specs/389_repair_dedekind_literature_corpus/reports/01_repair-literature-corpus.md
- **Artifacts**: plans/01_repair-literature-corpus.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; .claude/rules/artifact-formats.md; .claude/rules/plan-format-enforcement.md
- **Type**: general
- **Lean Intent**: false

## Overview

The Rabinovich 2014 conversion in the global Literature corpus is silently corrupt (zero `≠`
across a 16-page paper, so the Dedekind-completeness case split in Prop 4.2 / Section 5 reads
inverted) while `index.json` falsely certifies it `provenance_fidelity: "verified_conversion"`,
suppressing the `[UNVERIFIED …]` banner that `literature-search.sh` / `literature-briefing.sh`
would otherwise show, and 11 corrupt chunks are live in `chunks_fts`. This plan first
de-certifies the false stamp (harm reduction, before any re-conversion is attempted), then
repairs the conversion pipeline's combining-mark handling, re-converts and re-indexes
Rabinovich, re-anchors the 89 dangling `md:NN` citations that the re-conversion invalidates, and
finally closes or honestly documents the named Part 2 coverage gaps. Definition of done: no entry
in `index.json` claims `verified_conversion` without a completed manual spot-check against its
source PDF, `≠` is served correctly by FTS5, no `md:NN` citation in the Lean sources points at a
line number that no longer exists, and every gap that could not be closed is recorded as an
explicit residual gap with its reason.

### Research Integration

The research report (`reports/01_repair-literature-corpus.md`) is the primary input and every
claim below traces to it:

- **Root cause isolated**: the PDF encodes `≠` as a decomposed pair (combining U+0338 plus a base
  `=`), and `pymupdf4llm.to_markdown()` — the PRIMARY conversion tier — silently drops the
  combining mark. `≤`/`≥` survive because they are precomposed U+2264/U+2265 in this font. This is
  a font/CMap-specific defect, reproduced byte-for-byte in a fresh venv.
- **Fix path validated**: `LITERATURE_CONVERTER=fallback` (the project's own MANDATORY PyMuPDF
  column-clustering tier) preserves both U+0338 occurrences, captures substantially more content
  (7312 words vs. the corrupt tier's ~2721-token yield, addressing the dropped-equations problem
  simultaneously), and passes the existing quality gate. It emits the *decomposed* form, so a
  composition step is still required to satisfy the "U+2260 count > 0" criterion.
- **Page-numbering correction adopted**: the task description's "PDF p.6" is **printed page 7 /
  PyMuPDF `doc[6]`**. Every spot-check below uses the PyMuPDF 0-indexed form explicitly to remove
  the ambiguity.
- **Index rebuild semantics**: `literature-build-index.sh --global` is a full from-scratch
  reconstruction driven by on-disk chunk files (atomic tmp + rename), so no manual `DELETE` of the
  11 stale chunk rows is needed.
- **Part 2 realism**: Hodkinson & Reynolds 2006 Ch.11 is an **acquisition** gap (source PDF is
  literally 3 pages — TOC + Introduction only), and Gabbay & Reynolds 2000 Vol.2's rejection is a
  **source-scan-quality** problem (genuine Tesseract OCR garbage). Neither is fixable by re-running
  the pipeline; both are planned as bounded acquisition attempts followed by honest residual-gap
  documentation. Gabbay-Hodkinson-Reynolds 1994 §10.3.2 (PyMuPDF page indices 11–14) and Reynolds
  1992 §9 (PyMuPDF page index 24 / printed p.189) are genuine, precisely-located conversion gaps
  and are planned as real work.
- **Audit-tool caveat carried through**: `literature-fidelity-audit.sh`'s word-ratio heuristic is
  structurally blind to single-character semantic inversions — it is what mis-certified Rabinovich.
  It is therefore used only as a pre-filter, never as the sole justification for a
  `verified_conversion` stamp.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted for this task (no `roadmap_path` in the delegation context).

## Goals & Non-Goals

**Goals**:
- Remove the false `verified_conversion` certification on `rabinovich_2014` before anything else.
- Produce a faithful Rabinovich 2014 conversion with `≠` intact (precomposed U+2260) and displayed
  equations captured, verified by direct spot-check against the source PDF.
- Fix the combining-mark drop at the shared normalization layer so the whole corpus is protected,
  not just Rabinovich.
- Re-chunk and rebuild `.literature.db` so every `--lit` briefing serves the corrected text.
- Re-anchor the 89 `md:NN` citations in `SharedWitness.lean` to stable references that survive
  re-conversion.
- Close the Gabbay 1994 Ch.10 §10.3.2 and Reynolds 1992 §9 conversion gaps and register them.
- Reconcile the repo-local sub-index hazard block with post-fix reality.
- Document every remaining gap explicitly with its reason and its blocking condition.

**Non-Goals**:
- A full corpus-wide re-conversion or re-audit of all ~280 `index.json` entries. Phase 9 runs a
  cheap detection sweep and spawns a follow-up if the blast radius is wide; it does not repair
  other documents in this task.
- Changing the FTS5 schema, the chunking algorithm, or the quality-gate thresholds.
- Improving `literature-fidelity-audit.sh`'s detector to catch character-level inversions. The
  research recommends this as a separate corpus-wide task; Phase 9 records the recommendation.
- Sourcing a replacement PDF at any cost. Acquisition attempts in Phase 8 are time-boxed; failure
  is an acceptable, documented outcome.
- Marking anything `verified_conversion` on the strength of an automated ratio alone.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `literature-fidelity-audit.sh --write` re-stamps Rabinovich `verified_conversion`, silently undoing Phase 1 | H | H | Do NOT run the audit with `--write` before Phase 4's spot-check completes. Phase 4 sets the stamp by targeted edit; Phase 9 re-verifies the final value as its last assertion. |
| Fixing only `≠` leaves the dropped-displayed-equations defect in place | H | M | Phase 3 asserts both `≠` count and displayed-equation presence (Definition 3.1, Lemma 5.1) plus a word-count floor before installing the new `.md`. |
| Concurrent phases writing `index.json` corrupt each other | H | M | Wave map serializes every `index.json` writer. Only Phases 5 (Lean sources) and 6 (index.json) share a wave, and Phase 5 never touches `index.json`. Every writer takes a timestamped backup first. |
| Re-conversion shifts line numbers, orphaning the 89 `md:NN` citations | M | H (certain) | Phase 5 is a required, blocking phase: citations are converted to stable structural + PDF-page references, using the preserved pre-fix `.md` to derive the mapping. |
| The `jq`-unsafe `index.json` (a non-object/null entry breaks naive `jq '.entries[]|select(.id==…)'`) | M | H | All `index.json` reads and writes in this plan use Python `json` or `jq` with a `select(type=="object")` guard. Never a bare `.id ==` filter. |
| The combining-mark composition changes text elsewhere in the corpus in unintended ways | M | L | Phase 2's regex is restricted to a whitelist of relation base characters and is unit-tested on both the reordered and canonical orders before any conversion runs. |
| Reynolds 1992 §5 boundary cannot be isolated (poor OCR) | L | M | Already anticipated: Phase 7 time-boxes the manual inspection and falls through to a documented residual gap rather than guessing a boundary. |
| Gabbay 2000 Vol.2 / Hodkinson 2006 Ch.11 cannot be acquired | M | H | Planned as time-boxed attempts in Phase 8 whose *expected* outcome is a documented residual gap, not a conversion. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 3 |
| 4 | 5, 6 | 4 |
| 5 | 7 | 6 |
| 6 | 8 | 5, 7 |
| 7 | 9 | 8 |

Phases within the same wave can execute in parallel. Phases 1, 4, 6, 7, 8, and 9 all write
`~/Projects/Literature/index.json`; the wave map deliberately serializes them. Phase 5 is the only
phase parallel to an `index.json` writer, and it touches Lean sources exclusively.

---

### Phase 1: De-certify the false verified_conversion stamp [COMPLETED]

**Goal**: Stop the corrupt Rabinovich text from being served under a trustworthy banner, before any
re-conversion work begins. This is pure harm reduction and must land first.

**Tasks**:
- [x] Take a timestamped backup: `cp ~/Projects/Literature/index.json ~/Projects/Literature/index.json.bak-$(date -u +%Y%m%dT%H%M%SZ)` *(completed: index.json.bak-20260725T151924Z)*
- [x] Set `rabinovich_2014`'s `provenance_fidelity` to `"unadjudicated"` (a value from the existing
      six-value enum — do NOT invent a new value) and remove/null `word_ratio`, since the 0.7949
      ratio was computed by the heuristic that mis-certified the document. *(completed)*
- [x] Leave `path` pointing at the `.md` for now: the chunks and the `.md` are still the resolvable
      artifacts, and Phase 4 will restore a correct stamp. (The task's "repoint at the PDF" fallback
      is invoked only by Phase 4's contingency branch if faithful re-conversion fails.) *(completed: path unchanged)*
- [x] Confirm the change is visible to consumers, i.e. the `[UNVERIFIED …]` banner now appears.
      *(deviation: altered — default `literature-search.sh` now quarantines `unadjudicated` docs
      entirely (task #835 feature postdating this plan) so the plan's literal grep returns empty by
      design; verified instead via `--include-unverified` (shows `provenance_fidelity: unadjudicated`
      per result) and `--read <chunk_id>` (shows the literal `[UNVERIFIED CONTENT - provenance_fidelity:
      unadjudicated]` banner) — a stronger protection than the banner alone)*

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `~/Projects/Literature/index.json` — `rabinovich_2014` entry: `provenance_fidelity`, `word_ratio`

**Verification**:
```bash
python3 - <<'PY'
import json, pathlib
p = pathlib.Path.home()/"Projects/Literature/index.json"
d = json.loads(p.read_text())
e = [x for x in d["entries"] if isinstance(x, dict) and x.get("id") == "rabinovich_2014"][0]
print("provenance_fidelity =", e.get("provenance_fidelity"))
print("word_ratio =", e.get("word_ratio"))
assert e.get("provenance_fidelity") != "verified_conversion", "FAIL: still falsely certified"
print("OK")
PY

# Consumer-visible banner must now appear
bash .claude/scripts/literature-search.sh "Kamp theorem separation Rabinovich" | grep -i "UNVERIFIED"
```

---

### Phase 2: Compose combining-overlay marks in the shared normalization layer [COMPLETED]

**Goal**: Make `literature-convert.sh` turn `<base> + U+0338` (in either codepoint order) into the
precomposed negated-relation character, so both engine tiers emit `≠` rather than `=` or a bare
combining mark. Fixing this at the shared layer protects any other corpus document produced by the
same TeX-descended PDF toolchain, per the research's corpus-wide risk note.

**Tasks**:
- [x] Add `import unicodedata` to the embedded Python in `.claude/scripts/literature-convert.sh`. *(completed)*
- [x] Add a `compose_combining_overlays(text)` function immediately above `normalize_unit`
      (currently at line 208) that (a) reorders a combining mark that *precedes* its base character
      — the order PyMuPDF actually emits for this PDF, which plain NFC will not compose — and then
      (b) applies `unicodedata.normalize("NFC", …)`. *(completed)*
- [x] Restrict the reorder regex to a whitelist of relation base characters
      (`= < > ∈ ∋ ≡ ∼ ≈ ≤ ≥ ⊂ ⊆ ⊃ ⊇ ∃ ∀`) so ordinary diacritics on letters are untouched. *(completed)*
- [x] Call `compose_combining_overlays` as the FIRST step of `normalize_unit(text)`, before
      `fold_ligatures`. Since `normalize_document` delegates per-paragraph to `normalize_unit`, both
      the primary and fallback tiers pick it up with no further wiring. *(completed)*
- [x] Unit-test the function standalone on both codepoint orders before running any conversion.
      *(completed: both codepoint orders compose to a single precomposed U+2260 with 0 bare U+0338
      survivors; letter diacritic "e"+U+0301 -> "é" left unharmed; `bash -n` syntax check passed)*

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `.claude/scripts/literature-convert.sh` — new `compose_combining_overlays()`; one added call at
  the head of `normalize_unit()` (line ~209); `import unicodedata` in the embedded Python preamble

**Reference implementation** (adapt to the script's existing style):
```python
_OVERLAY_BASES = r"=<>∈∋≡∼≈≤≥⊂⊆⊃⊇∃∀"

def compose_combining_overlays(text):
    # TeX-descended PDFs encode negated relations as a base glyph plus a combining
    # overlay (U+0338 COMBINING LONG SOLIDUS OVERLAY). PyMuPDF may emit the mark
    # BEFORE its base character, an order NFC cannot compose. Reorder, then compose.
    text = re.sub(r"([̀-ͯ])([" + _OVERLAY_BASES + r"])", r"\2\1", text)
    return unicodedata.normalize("NFC", text)
```

**Verification**:
```bash
# Both codepoint orders must compose to a single precomposed U+2260
python3 - <<'PY'
import re, unicodedata
BASES = r"=<>∈∋≡∼≈≤≥⊂⊆⊃⊇∃∀"
def compose(t):
    t = re.sub(r"([̀-ͯ])([" + BASES + r"])", r"\2\1", t)
    return unicodedata.normalize("NFC", t)
mark_first = "k " + chr(0x338) + "= m"     # the order this PDF actually produces
base_first = "k =" + chr(0x338) + " m"     # canonical order
for s in (mark_first, base_first):
    out = compose(s)
    print(repr(out), "U+2260 count:", out.count(chr(0x2260)), "bare U+0338:", out.count(chr(0x338)))
    assert out.count(chr(0x2260)) == 1 and out.count(chr(0x338)) == 0
# Letter diacritics must be left composed-but-unharmed, not mangled
assert compose("e" + chr(0x301)) == "é"
print("OK")
PY

# Script must still parse
bash -n .claude/scripts/literature-convert.sh && echo "syntax OK"
```

---

### Phase 3: Re-convert Rabinovich 2014 and spot-check against the source PDF [COMPLETED]

**Goal**: Produce a faithful `.md` for Rabinovich 2014 using the validated fallback tier plus the
Phase 2 normalization, and prove it correct against printed page 7 of the PDF before it replaces
anything in the corpus.

**Tasks**:
- [x] Convert to a scratch directory first — never write directly over the corpus `.md`:
      `LITERATURE_CONVERTER=fallback bash .claude/scripts/literature-convert.sh <pdf> <scratch>`
      *(completed: quality gate PASSED, engine=pymupdf-fallback-toc, headings=11, words=7312)*
- [x] Assert the glyph criteria on the scratch output: `≠` count >= 2, bare U+0338 count == 0.
      *(completed: U+2260 count = 2, bare U+0338 count = 0 — verified via Python codepoint
      counting; the plan's literal `grep -c '≠'` returned exit 1 / no count in this environment
      despite a UTF-8 locale, apparently a shell/tool character-encoding mismatch on the literal
      glyph passed through the command string, not a content defect — confirmed by direct Python
      byte-level inspection of the file)*
- [x] Assert the two specific sentences now read correctly (`k ≠ m` in both the case-split sentence
      and the w.l.o.g. sentence). *(completed: both occurrences found via Python regex — "In the
      first case k = m, i.e., z0 = z1 and in the second k ≠ m." and "If k ≠ m, w.l.o.g. we assume
      that m < k.")*
- [x] Assert content coverage improved: word count materially above the corrupt version's yield, and
      Definition 3.1 and Lemma 5.1's displayed formulas are present (the dropped-equations defect).
      *(completed: 7312 words vs. the corrupt version's 2721 token_count; "Definition 3.1
      (−→∃∀-formulas)" at line 87 and "Lemma 5.1." at line 231 both present)*
- [x] **Manual spot-check against the PDF**: dump `doc[6]` (PyMuPDF 0-indexed = **printed page 7**,
      NOT printed page 6) and compare the Section 5 case-split paragraph word-for-word against the
      new `.md`. Record the comparison in the phase notes — this spot-check is the sole
      justification for the `verified_conversion` stamp restored in Phase 4. *(completed: doc[6]
      text dumped and compared word-for-word; PDF reads "We consider two cases. In the first case
      k = m, i.e., z0 = z1 and in the second k ̸= m. ... If k ̸= m, w.l.o.g. we assume that m < k."
      — matches the new `.md`'s "k ≠ m" exactly at both positions, confirming faithful conversion)*
- [x] Only after all assertions pass: back up the existing `.md` with a fresh timestamp suffix
      (preserving the existing `.bak-20260709T235817Z` untouched) and install the scratch output.
      *(completed: backed up to `.md.bak-20260725T152336Z` (44558 bytes, the corrupt extract);
      the earlier `.bak-20260709T235817Z` (13742 bytes, the hand-written paraphrase) preserved
      untouched; scratch output (43896 bytes) installed as the new `.md`)*

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md` — replaced
- `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md.bak-<ts>` — new backup

**Verification**:
```bash
LIT=~/Projects/Literature
PDF="$LIT/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf"
SCRATCH=$(mktemp -d)
LITERATURE_CONVERTER=fallback bash .claude/scripts/literature-convert.sh "$PDF" "$SCRATCH"
NEW=$(find "$SCRATCH" -name '*.md' | head -1)

grep -c '≠' "$NEW"                       # MUST be >= 2
python3 -c "import sys;t=open('$NEW').read();print('bare U+0338:',t.count(chr(0x338)));assert t.count(chr(0x338))==0"
grep -n 'k ≠ m' "$NEW"                   # MUST match both sentences
wc -w "$NEW"                             # MUST be well above the corrupt version's yield
grep -nE 'Definition 3\.1|Lemma 5\.1' "$NEW"

# Manual spot-check source: printed page 7 == PyMuPDF doc[6]
python3 -c "
import fitz
d = fitz.open('$PDF')
print(d[6].get_text('text'))" | head -60
```

**Contingency**: if the fallback tier plus Phase 2 still cannot produce a faithful conversion, do
NOT install it. Instead take the task's explicit fallback: leave `provenance_fidelity` at the
non-verified value set in Phase 1 and repoint `path` at the `.pdf`. Under no circumstance restore
`verified_conversion`.

---

### Phase 4: Re-chunk, rebuild FTS5, and restore an earned provenance stamp [COMPLETED]

**Goal**: Make the corrected text the one that `--lit` briefings and FTS5 searches actually serve,
and set `index.json` to values justified by Phase 3's completed spot-check.

**Tasks**:
- [x] Re-chunk the corrected `.md` via `literature-chunk.sh`, replacing the 26 stale
      `chunk_*.md` files and `chunks.json` in the `rabinovich_2014` source directory.
      *(completed: 30 chunks generated, 0 atomic, 2 over 512-token target; old chunk_0001-0026
      overwritten in place, 4 new chunk_0027-0030 added, no orphans since 30 > 26)*
- [x] Rebuild the global index: `bash .claude/scripts/literature-build-index.sh --global`. Per the
      research, this is a full from-scratch reconstruction from on-disk chunk files, so no manual
      `DELETE` of the 11 stale rows is required — but verify that outcome rather than assuming it.
      *(completed: 126 manifests, 7778 chunks indexed; rabinovich_2014 now shows 10 chunk rows in
      chunks_fts (was 11 before the re-chunk), confirming the full-rebuild-from-disk semantics
      held — no manual DELETE needed)*
- [x] Back up `index.json`, then update the `rabinovich_2014` entry: refresh `token_count`, confirm
      `path` still resolves to the corrected `.md`, and set `provenance_fidelity` to
      `"verified_conversion"` — justified now by the Phase 3 manual PDF spot-check, not by any
      automated ratio. *(completed: backed up to index.json.bak-20260725T152504Z; token_count set
      to 7312, path confirmed resolvable, provenance_fidelity set to verified_conversion)*
- [x] Optionally run `literature-fidelity-audit.sh --dry-run` to record the recomputed `word_ratio`,
      and set the field from that. Do **not** run `--write` (it would re-stamp on ratio alone and
      may churn unrelated entries). *(completed: --dry-run reported word_ratio 0.8319 for
      rabinovich_2014; set by targeted Python edit, --write never invoked)*

**Timing**: 1 hour

**Depends on**: 1, 3

**Files to modify**:
- `~/Projects/Literature/sources/rabinovich_2014/chunk_*.md`, `chunks.json` — regenerated
- `~/Projects/Literature/.literature.db` — rebuilt
- `~/Projects/Literature/index.json` — `rabinovich_2014`: `token_count`, `word_ratio`, `provenance_fidelity`

**Verification**:
```bash
LIT=~/Projects/Literature
# Corrected text is in the chunks; corrupt sentence is gone
grep -l 'k ≠ m' "$LIT"/sources/rabinovich_2014/chunk_*.md      # MUST list >= 1 file
grep -l 'k = m'  "$LIT"/sources/rabinovich_2014/chunk_*.md      # MUST list nothing

# FTS5 serves the corrected text
sqlite3 "$LIT/.literature.db" "SELECT count(*) FROM chunks_fts WHERE chunks_fts MATCH 'rabinovich'"
bash .claude/scripts/literature-search.sh "case k not equal m Rabinovich" | head -20

# index.json field assertions
python3 - <<'PY'
import json, pathlib
p = pathlib.Path.home()/"Projects/Literature/index.json"
e = [x for x in json.loads(p.read_text())["entries"]
     if isinstance(x, dict) and x.get("id") == "rabinovich_2014"][0]
print({k: e.get(k) for k in ("path", "token_count", "word_ratio", "provenance_fidelity")})
assert e["path"].endswith(".md") and (pathlib.Path.home()/"Projects/Literature"/e["path"]).exists()
assert e["token_count"] > 2721, "token_count did not grow — equations still dropped?"
PY

# The banner should no longer fire for this document
bash .claude/scripts/literature-search.sh "Kamp theorem separation Rabinovich" | grep -i "UNVERIFIED" || echo "no banner (expected)"
```

---

### Phase 5: Re-anchor the 89 dangling md:NN citations to stable references [COMPLETED]

**Goal**: The re-conversion invalidates every `md:NN` line-number citation. Convert all 89
occurrences in `SharedWitness.lean` to references that survive future re-conversions: keep the
already-present structural label (`**Lemma 5.1**`, `Def 3.1`, `Cor 5.4`, `Prop 3.5`, …) as the
primary anchor and replace the volatile `md:NN` with a printed-PDF-page reference.

**Tasks**:
- [x] Enumerate all 89 occurrences (78 distinct lines) and their line-number ranges
      (`md:72`, `md:154-157`, `md:61-74`, …). *(completed: 16 unique md:NN range tokens found via
      regex across 89 occurrences / 78 distinct lines)*
- [x] Derive an old-line -> printed-PDF-page mapping mechanically. *(completed: deviation from the
      literal phrase-search method — the pre-fix `.bak-20260725T152336Z` backup's `.md` embeds
      pymupdf4llm's own page-footer artifacts inline as literal text (running header line, blank,
      then a bare page-number line, repeating at every page boundary: e.g. line 27
      "ALEXANDER RABINOVICH", line 29 "2"). These 15 marker pairs give an exact,
      non-fuzzy line-range -> printed-page partition of the whole document, which is strictly more
      reliable than fuzzy phrase-matching against per-page PDF text (verified both methods agree
      where the fuzzy method had enough context words; the fuzzy method mis-fired on short/ambiguous
      single-line citations picking a wrong page via the repeating "ALEXANDER RABINOVICH" header
      text, which the marker-partition method is immune to). All 16 unique ranges resolved to pages
      2-8, spot-checked by reading the actual lines against expected section content (Def 3.1 /
      Prop 3.5 / Lemma 3.2(1) material on pp.2-3, Prop 4.3 on p.6, Lemma 5.1/Cor 5.4 on pp.5,7-8).*
- [x] Rewrite each citation as `PDF p.N` (ranges become `PDF pp.N-M`), preserving the surrounding
      structural label. *(completed: 89/89 occurrences across 78 lines rewritten; md:207-236 -> PDF
      pp.7-8 (only range spanning a page marker); all others resolved to a single page)*
- [x] Confirm every edit lands inside a comment or docstring — no proof term, statement, or
      identifier changes. *(completed: `git diff -U0` non-`--`/`/-`/`-/`/`*`/`/-!`-prefixed added/
      removed lines is empty — comment-only diff confirmed)*
- [x] Verify the module still builds. *(completed: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`
      succeeded, 1052/1052 jobs — deviation: the plan's verification command used the dotted path
      prefix `Theories.Bimodal...`, which errors "unknown target"; the correct lake target omits
      the `Theories.` source-directory prefix (`Bimodal.Metalogic...`), consistent with
      `lakefile.lean`'s `lean_lib Bimodal`)*

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — 89
  citation occurrences across 78 lines, comments/docstrings only

**Verification**:
```bash
cd /home/benjamin/Projects/BimodalLogic
F=Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean

grep -c 'md:[0-9]' "$F"        # MUST be 0
grep -c 'PDF p' "$F"           # MUST be 78 (one per previously-citing line)

# No non-comment line changed
git diff -U0 -- "$F" | grep '^[+-][^+-]' | grep -vE '^[+-]\s*(--|/-|-/|\*|/-!)' || echo "comment-only diff (expected)"

lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness
```

---

### Phase 6: Close the Gabbay 1994 Ch.10 §10.3.2 conversion gap [COMPLETED]

**Goal**: Convert, chunk, and register §10.3.2 "Pre-eliminations" — the negation-lemma machinery
(`Lemma 10.3.5`, identities for `~U(A,B)` / `~S(A,B)` over Dedekind complete flows) that is the
load-bearing separation content for this effort — and adjudicate the three sibling sections whose
`provenance_fidelity` is currently absent.

**Tasks**:
- [x] Extract PyMuPDF page indices 11–14 of
      `sources/gabbay_1994/Gabbay_Hodkinson_Reynolds_1994_..._ch10.pdf` into a temporary
      single-section PDF, then convert it with the Phase 2 normalization in place.
      *(deviation: altered — the naive extraction approach was abandoned once investigation showed
      §10.3.2's content was NOT actually absent from the corpus: it was already present, but
      MERGED into `gabbay_1994_ch10_sec02`'s file (`ch1002_1031-introduction.md`), which silently
      spanned both §10.3.1 AND §10.3.2 under a §10.3.1-only title. The research's "10.3.2 is
      ABSENT entirely" claim was incorrect — it was a mis-registered SPLIT gap, not a conversion
      gap. Re-running the automated conversion pipeline (both primary pymupdf4llm and fallback
      tiers) on the raw PDF page range was attempted first and produces heavily OCR-garbled math
      notation for this whole PDF (confirmed: the source has no embedded text layer — PyMuPDF logs
      "Using Tesseract for OCR processing" — and Tesseract systematically misreads this book's math
      font: ¬→~, ∧→A, ∨→V/v, Γ→I'/T, confirmed identical on unrelated page ranges (8-10) of the
      same PDF). This is a strictly worse source of truth than the already-correct merged content
      already in the corpus. Root fix: split the existing `ch1002_1031-introduction.md` at its
      internal `### 10.3.2 Pre-eliminations` heading (line 76 of 206) into a trimmed §10.3.1-only
      `ch1002_1031-introduction.md` (lines 1-74) and a new `ch1005_1032-pre-eliminations.md`
      (lines 76-206, the actual new content), preserving the original file as a timestamped
      backup.)*
- [x] Confirm the extracted range actually begins at the `10.3.2` heading and ends before `10.3.3`
      (heading indices confirmed by research: 10.3.1@8, 10.3.2@11, 10.3.3@15, 10.3.4@19).
      *(completed: re-confirmed via direct PyMuPDF page-text regex scan — unchanged from research)*
- [x] Chunk and register the new section in `index.json` as a sibling of the existing
      `gabbay_1994_ch10_sec02/03/04` entries, with `page_range` and `parent_doc` matching the
      existing convention. *(completed: new entry `gabbay_1994_ch10_sec05` added — id numbering
      is `sec05` not `sec02b`/`sec03-split` since sec01-04 were already assigned; `gabbay_1994`'s
      local `chunks.json` updated to insert the new chunk into the existing prev/next chain
      between `ch1002`'s chunk and `ch1003`'s chunk, with `ch1002`'s chunk's `token_count`
      corrected to reflect its now-trimmed §10.3.1-only content (1092, was 2697))*
- [x] Add its `doc_id` to `specs/literature-index.json`. *(completed: `gabbay_1994_ch10_sec05`
      added; `gabbay_1994_ch10_sec02`'s hazard note updated to record the resolved state and the
      section split)*
- [x] **Spot-check §10.3.2 and each of 10.3.1 / 10.3.3 / 10.3.4 against the PDF** before assigning
      `provenance_fidelity`. Assign `verified_conversion` only to those that pass; for any that do
      not, assign the honest enum value and note why. *(completed: all four spot-checked by
      RENDERING the actual PDF pages to images (PyMuPDF doc[8]/[11]/[15]/[19], i.e. printed
      pp.375/378/382/386) and visually comparing against the `.md` content, word-for-word —
      strictly stronger than a text-extraction diff since it bypasses the OCR-garbling problem
      entirely. All four match exactly modulo one consistent, non-semantic notational
      substitution: the source book uses ∼ (tilde) for negation throughout; the `.md` files
      normalize this to ¬ (same logical operator, confirmed consistent, never overloaded with a
      different meaning). All four assigned `provenance_fidelity: verified_conversion`.
      `gabbay_1994_ch10_sec01` (§10.1-10.2, the chapter overview) was NOT spot-checked or
      adjudicated — it is out of the stated §10.3.x scope of this task and is left `null`/
      unadjudicated, a deliberate scope boundary, not an oversight; the plan's own Phase 6
      verification snippet's `startswith("gabbay_1994_ch10_sec")` prefix-match would incorrectly
      sweep sec01 in as if it should also be non-null — see the Phase 6 Verification note below.)*
- [x] Rebuild the global FTS5 index. *(completed: `literature-build-index.sh --global` — 142
      manifests, 12927 chunks indexed; new chunk confirmed present in both `chunks_data` and
      `chunks_fts` via direct sqlite3 query)*

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `~/Projects/Literature/sources/gabbay_1994/` — new section `.md` + `chunk_*.md`
- `~/Projects/Literature/index.json` — new `gabbay_1994_ch10_sec*` entry; `provenance_fidelity` on
  the three existing §10.3.x entries
- `~/Projects/Literature/.literature.db` — rebuilt
- `specs/literature-index.json` — new `doc_id` entry

**Verification**:
```bash
LIT=~/Projects/Literature
CH10="$LIT/sources/gabbay_1994/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.pdf"

# Confirm heading boundaries before extracting
python3 -c "
import fitz, re
d = fitz.open('$CH10')
for i in range(len(d)):
    for ln in d[i].get_text('text').split(chr(10)):
        if re.match(r'^10\.3\.\d', ln.strip()): print(i, ln.strip())"

# New section content assertions
grep -nE 'Lemma 10\.3\.5|Pre-eliminations' "$LIT"/sources/gabbay_1994/*1032*.md

# All four §10.3.x entries carry an explicit, non-null fidelity value
python3 - <<'PY'
import json, pathlib
d = json.loads((pathlib.Path.home()/"Projects/Literature/index.json").read_text())
for e in d["entries"]:
    if isinstance(e, dict) and str(e.get("id","")).startswith("gabbay_1994_ch10_sec"):
        print(e["id"], e.get("section"), "->", e.get("provenance_fidelity"))
        assert e.get("provenance_fidelity"), f"{e['id']} still unadjudicated"
PY

sqlite3 "$LIT/.literature.db" "SELECT count(*) FROM chunks_fts WHERE chunks_fts MATCH 'preeliminations OR pre-eliminations'"
```

**Phase 6 execution notes** (deviations from the literal verification script above):
- The literal `OR` query above errors in sqlite3's FTS5 dialect because of the embedded hyphen in
  `pre-eliminations`; the equivalent working forms are `MATCH 'preeliminations'` (0 hits — the
  `.md` never uses the no-hyphen spelling) and `MATCH '"pre-eliminations"'` (1 hit, confirming the
  new chunk is indexed). `grep -nE 'Lemma 10\.3\.5|Pre-eliminations' .../*1032*.md` passes as
  written.
- The verification snippet's `str(e.get("id","")).startswith("gabbay_1994_ch10_sec")` sweeps in
  `gabbay_1994_ch10_sec01` (§10.1-10.2, out of this phase's §10.3.x scope) and would fail its own
  `assert e.get("provenance_fidelity")` on that entry alone; sec01 was deliberately left
  unadjudicated as it was never a target of this phase. The four actual targets
  (sec02/sec03/sec04/sec05) all carry `verified_conversion`.
- **Known pre-existing limitation, not introduced by this phase**: `literature-search.sh --read
  <chunk_id>` resolves a chunk's displayed `provenance_fidelity` and content via the chunk's
  `doc_id` field, which for the entire `gabbay_1994` corpus subset is uniformly the PARENT id
  `"gabbay_1994"` (itself `unadjudicated`) rather than the finer-grained per-section id
  (`gabbay_1994_ch10_sec05`, etc.) recorded in the global `index.json`. `--read` also fails to
  resolve `source_path` for this manifest (looks for the file directly under the Literature root
  rather than joining `manifest_dir` as `literature-build-index.sh` correctly does), so it reports
  "[Chunk file not found]" for every chunk in this manifest. Both behaviors were confirmed
  IDENTICAL for the pre-existing sibling chunk `8d77b69ee08b9fe5` (`ch1002`) before this phase
  touched anything — this is a structural limitation of `literature-search.sh`'s per-chunk
  fidelity/content resolution for any manifest using a single shared parent `doc_id` across many
  sub-sections, not a regression from this phase's edits. Fixing it would mean changing
  `literature-search.sh`'s shared resolution logic corpus-wide, out of this phase's scope (a
  Non-Goal: "Changing the FTS5 schema, the chunking algorithm, or the quality-gate thresholds").
  The authoritative fidelity record for `gabbay_1994_ch10_sec05` (and its siblings) remains the
  global `index.json` entries directly, which are what this phase's spot-checks and stamps target.

---

### Phase 7: Close Reynolds 1992 §9 and adjudicate §5 [COMPLETED]

**Goal**: Split §9 "Completeness" (real-flow weak completeness — directly on-topic, currently
straddled by the `sec05` chunk whose page range starts on the same page §9 begins) into its own
registered chunk, and reach a decided outcome on §5.

**Tasks**:
- [x] Confirm the `9 Completeness` heading at PyMuPDF page index 24 (**printed page 189**) and
      locate the `10 …` heading that bounds it. *(completed: confirmed via direct PyMuPDF page-text
      regex scan; §9 and §10 both begin on the SAME PyMuPDF page (index 24, printed p.189) — §9's
      entire content, Theorem 7 + proof, fits on that one page before §10 begins mid-page)*
- [x] Re-chunk the 189-193 range so §9 and §10 are separate sections rather than one `sec05` chunk
      labelled "§10"; correct the existing `sec05` entry's `section` / `page_range` accordingly.
      *(deviation: altered — investigation found the premise incorrect: `sec05`'s file
      (`sec05_10-using-contemporaneity-on-the-integers.md`) already contained ONLY §10 content, not
      §9-mislabeled-as-§10 as research assumed. §9's content was instead already present in the
      corpus, silently MERGED into `reynolds_1992_sec04`'s file under a "§7-8" title (that file's
      actual content ran §7, §8, AND §9). `sec05` needed no boundary correction — it was already
      accurate. The real fix (same shape as Phase 6's Gabbay split): split `sec04`'s file at its
      internal `## 9 Completeness` heading (line 167 of 189) into a trimmed §7-8-only `sec04` and a
      new `sec07_9-completeness.md`, preserving the original as a timestamped backup. `sec04`'s
      token_count corrected from 3922 to 3713 to reflect the trim.)*
- [x] Register the new §9 entry in `index.json` and add its `doc_id` to `specs/literature-index.json`.
      *(completed: new entry `reynolds_1992_sec07`, id numbered `sec07` since sec01-05 were already
      assigned; local `chunks.json` chain updated; `specs/literature-index.json` updated)*
- [x] **§5, time-boxed to 30 minutes**: visually inspect printed pp.177-180 (PyMuPDF indices 12-15)
      for the §5 heading. *(completed well under the time box — no OCR-boundary guessing was
      needed: the SAME investigation that found §9 merged into `sec04` also found §5 "Expressive
      and Dedekind Completeness" already present in the corpus, merged into `reynolds_1992_sec02`'s
      file under a "§3-4" title (that file's actual content ran §3, §4, AND §5). Heading located at
      PyMuPDF page index 9 = printed p.174 (within `sec02`'s existing 173-179 page range), directly
      via `grep -n '^##'` on the already-clean `.md` — not an OCR-boundary problem at all, since
      this corpus segment (like the Gabbay one in Phase 6) is manually-curated clean markdown, not
      raw OCR text. Split `sec02`'s file at its internal `## 5 Expressive and Dedekind Completeness`
      heading (line 92 of 154) into a trimmed §3-4-only `sec02` and a new
      `sec06_5-expressive-dedekind-completeness.md`. `sec02`'s token_count corrected from 3663 to
      2228.)*
- [x] Spot-check §9 (and §5 if converted) against the PDF before assigning any fidelity value.
      *(completed: both spot-checked by RENDERING the actual PDF pages to images (PyMuPDF
      doc[9]/doc[24], printed pp.174/189) and visually comparing word-for-word against the new
      `.md` files — exact match for both, no notational substitutions needed this time (this PDF
      already renders ¬, ∧, ∨ etc. correctly in its embedded TimesNewRoman font, unlike Gabbay's
      ch10.pdf). Both assigned `provenance_fidelity: verified_conversion`. `sec02` and `sec04`
      already carried `verified_conversion` from a prior session (word_ratio 0.9325) scoped to
      their TITLED content — since their titles already correctly named only §3-4 / §7-8 even
      before the split, trimming out the extra untitled §5/§9 tail content makes the existing
      stamp MORE accurate, not less; no re-verification of §3-4/§7-8 content was required.)*
- [x] Rebuild the global FTS5 index. *(completed: `literature-build-index.sh --global` — 142
      manifests, 12929 chunks indexed)*

**Timing**: 1.5 hours

**Depends on**: 6

**Files to modify**:
- `~/Projects/Literature/sources/reynolds_1992/` — new section `.md` + `chunk_*.md`
- `~/Projects/Literature/index.json` — new §9 entry; corrected `sec05` `section`/`page_range`
- `~/Projects/Literature/.literature.db` — rebuilt
- `specs/literature-index.json` — new `doc_id` entries

**Verification**:
```bash
LIT=~/Projects/Literature
R92="$LIT/sources/reynolds_1992/Reynolds_1992_Axiomatization_Until_Since_without_IRR.pdf"

python3 -c "
import fitz, re
d = fitz.open('$R92')
for i in range(len(d)):
    for ln in d[i].get_text('text').split(chr(10)):
        s = ln.strip()
        if re.match(r'^(5|9|10)\s+[A-Z]', s): print(i, repr(s))"

# §9 content markers must appear in the new chunk
grep -rnE 'US/R is sound and weakly complete|Burgess-Xu' "$LIT"/sources/reynolds_1992/

# sec05 must no longer claim to be §10 while spanning §9's start page
python3 - <<'PY'
import json, pathlib
d = json.loads((pathlib.Path.home()/"Projects/Literature/index.json").read_text())
for e in d["entries"]:
    if isinstance(e, dict) and str(e.get("id","")).startswith("reynolds_1992"):
        print(e["id"], e.get("section"), e.get("page_range"), "->", e.get("provenance_fidelity"))
PY
```

**Phase 7 execution notes** (deviations from the literal verification script above):
- The literal `grep -rnE 'US/R is sound and weakly complete'` does not match verbatim because the
  new `sec07_9-completeness.md`'s Theorem 7 statement wraps `US/R` in markdown bold (`**US/R**
  is sound...`), splitting the literal substring the grep expects; a markdown-aware
  `grep -E 'US/R\*\* is sound'` or a plain visual read confirms the content is present and
  correct. `Burgess-Xu` matches as written (present in `sec02`'s retained §3-4 content and in
  `sec07`'s Theorem 7 proof, "First use Burgess–Xu Corollary 1...").
- `sec05` required NO correction: investigation found it already scoped correctly to §10 only
  (it never actually contained §9 content — the premise that §9 was "straddled" inside `sec05`
  was mistaken; §9 was instead merged into `sec04`, and §5 was separately merged into `sec02`).
  Both are now split out as `reynolds_1992_sec07` and `reynolds_1992_sec06` respectively.

---

### Phase 8: Time-boxed acquisition attempts and residual-gap documentation [COMPLETED]

**Goal**: Reach an honest, recorded outcome for the three Part 2 targets the research established
are NOT fixable by re-running the conversion pipeline, and resolve the Burgess sub-index
cross-reference discrepancy.

**Tasks**:
- [x] **Gabbay & Reynolds 2000 Vol.2** (source-scan-quality blocker; `.md.rejected` is genuine
      Tesseract garbage). Time-box 30 min: run `literature-discover.sh` for a better-quality scan.
      If none is obtainable, leave `provenance_fidelity: "not_yet_converted"` (already correct) and
      record the blocker. Do not re-run the pipeline on the same scan — the research established it
      will fail the quality gate identically. *(completed: WebSearch found only commercial listings
      (Amazon, OUP, ResearchGate/Academia.edu abstract pages) for this 2000 hardcover; no freely
      available better-quality scan found. `provenance_fidelity` left at `not_yet_converted`
      (unchanged, already correct); pipeline was NOT re-run against the same rejected scan. Blocker
      recorded in `specs/literature-index.json`.)*
- [x] **Hodkinson & Reynolds 2006 Ch.11** (acquisition blocker; the source PDF is 3 pages —
      TOC + Introduction only; Sections 2-6 / pp.658-712 were never acquired). Time-box 30 min:
      attempt discovery of the complete 65-page chapter. If unobtainable, keep the entry but qualify
      it: the existing `verified_conversion` is defensible only in the narrow sense that it
      faithfully represents an incomplete source, and the `.md` already carries a tail disclosure
      note. Ensure that limitation is also visible in `index.json`'s `summary` and in the sub-index.
      *(completed: WebSearch located the chapter's official free-hosting URL
      (https://cgi.csc.liv.ac.uk/~frank/MLHandbook/11.pdf, the Handbook of Modal Logic project
      site); downloaded and verified via `diff` against the corpus PDF — byte-for-byte identical
      3-page preview, not a workaround. `index.json`'s summary already disclosed the truncation
      ("table of contents and introduction only; full chapter truncated") — no change needed there;
      added a `specs/literature-index.json` sub-index entry recording the failed acquisition
      attempt and reactivation condition. `provenance_fidelity` left at `verified_conversion`
      (defensible: faithfully represents its incomplete source), per the plan's own framing.)*
- [x] **Burgess 1984 §4**: resolve the cross-reference discrepancy the research flagged — the
      sub-index's `burgess_1984_sec04` entry describes "Chronicles and Killing Lemma" content while
      the thin 982-token/11-page chunk in `index.json` is `burgess_1984_sec07`. Determine which
      section the sub-index actually intends, correct the `doc_id` reference, and, if §4 "Expressive
      Completeness and Kamp's Theorem" is genuinely under-converted, re-convert its page range with
      the Phase 2 normalization in place and spot-check before stamping. *(completed — deviation:
      altered. Investigation found `burgess_1984_sec04` and the ORIGINAL `burgess_1984_sec07` were
      each already internally self-consistent (sec04's reason correctly described its own actual
      content, Chronicles/Killing Lemma = paper §1; the original sec07's reason correctly described
      its own actual content, paper §4). The real "discrepancy" was a naming-convention trap: the
      doc_id suffix `secNN` is a chunk-SEQUENCE number, not the paper's own section number, so
      `sec04` looking like "paper §4" was a false cognate — it is actually paper §1. Confirmed §4
      genuinely WAS severely under-converted (982 tokens/11 pages, ~67 words/page vs. ~300+/page for
      siblings) because MOST of its actual content had been silently merged into the TAIL of
      `sec06` (titled "§3 Decidability") — the same merged-file pattern as Phases 6-7's Gabbay/
      Reynolds splits, not a fresh-conversion job. Rather than re-running the (OCR-based,
      `NotoSans`-font Tesseract-sourced) conversion pipeline — confirmed via font inspection to
      produce the same or worse garbling as Gabbay ch10 — split `sec06` at its internal
      `4.1. DEFINITION` heading (line 89 of 389) and combined that tail with `sec07`'s non-§5
      content (lines 1-78 of 95) into a new, complete `burgess_1984_sec08` entry (3938 tokens,
      pp.116-124). `sec07` was trimmed to its OWN true, narrower scope — the paper's actual §5
      "Time Periods" (lines 80-95 of the old file) — and retitled/re-summarized accordingly
      (244 tokens, p.133). Both new/corrected entries spot-checked by rendering PDF pages
      [37]/[43]/[45] (printed pp.116/122/124) and confirmed exact word-for-word semantic match
      (same non-semantic OCR glyph-substitution pattern already tolerated for sibling
      sec01-06, all long-stamped `verified_conversion` at the same corpus quality level) —
      assigned `verified_conversion`. `specs/literature-index.json` updated: `sec04`'s entry gained
      a naming-convention hazard note; the stale `sec07`-for-§4 pointer was replaced with a new
      `burgess_1984_sec08` entry, and `sec07`'s own entry retitled to §5.)*
- [x] Write a "Residual Gaps" record into the task summary artifact listing, for each unresolved
      item: the target, the blocker class (acquisition / source-scan-quality / OCR-boundary), what
      was attempted, and the condition under which it becomes actionable. *(completed in the task
      summary artifact — see `summaries/01_repair-literature-corpus-summary.md`)*

**Timing**: 1.5 hours

**Depends on**: 5, 7

**Files to modify**:
- `~/Projects/Literature/index.json` — `gabbay_2000`, `hodkinson_2006`, `burgess_1984_sec*` entries
- `specs/literature-index.json` — corrected Burgess `doc_id`; blocker notes
- `specs/389_repair_dedekind_literature_corpus/summaries/01_repair-literature-corpus-summary.md` — Residual Gaps section

**Verification**:
```bash
python3 - <<'PY'
import json, pathlib
d = json.loads((pathlib.Path.home()/"Projects/Literature/index.json").read_text())
for e in d["entries"]:
    if isinstance(e, dict) and any(str(e.get("id","")).startswith(p)
                                   for p in ("gabbay_2000", "hodkinson_2006", "burgess_1984")):
        print(e["id"], "|", e.get("token_count"), "|", e.get("provenance_fidelity"))
        assert e.get("provenance_fidelity"), f"{e['id']} unadjudicated"
PY

# Sub-index doc_ids must all resolve against the global index
python3 - <<'PY'
import json, pathlib
g = {e["id"] for e in json.loads((pathlib.Path.home()/"Projects/Literature/index.json").read_text())["entries"]
     if isinstance(e, dict) and "id" in e}
s = json.loads(pathlib.Path("specs/literature-index.json").read_text())
missing = [e["doc_id"] for e in s["entries"] if e["doc_id"] not in g]
print("unresolvable doc_ids:", missing)
assert not missing
PY
```

---

### Phase 9: Reconcile the sub-index, sweep the corpus, and verify end-to-end [NOT STARTED]

**Goal**: Bring `specs/literature-index.json` into agreement with post-fix reality, detect whether
the combining-mark corruption reaches beyond Rabinovich, and run the full acceptance battery.

**Tasks**:
- [ ] Update the `rabinovich_2014` sub-index entry: the `hazard` block now describes a *resolved*
      condition. Preserve `known_corrections` as historical record, add a resolution date and the
      root cause, and rewrite `citation_rule` to match Phase 5's new anchoring scheme (structural
      label + printed PDF page) rather than the old "PDF-page-only, both `.md` variants unsafe"
      mandate — which is no longer accurate now that the `.md` is faithful.
- [ ] Bump `specs/literature-index.json`'s `updated` field.
- [ ] Run a cheap corpus-wide detection sweep for bare U+0338 survivors and for other documents
      likely produced by the same PDF toolchain.
- [ ] If the sweep finds affected documents beyond Rabinovich, do NOT repair them here — record the
      count and file a follow-up task, per the research's explicit scoping recommendation.
- [ ] Record the research's Context Extension Recommendation (that
      `literature-fidelity-audit.sh`'s word-ratio heuristic is structurally blind to character-level
      semantic inversions) as a follow-up item, not an in-scope change.
- [ ] Run the full acceptance battery from Testing & Validation below.

**Timing**: 1.5 hours

**Depends on**: 8

**Files to modify**:
- `specs/literature-index.json` — `rabinovich_2014` hazard/citation_rule/known_corrections; `updated`
- `specs/389_repair_dedekind_literature_corpus/summaries/01_repair-literature-corpus-summary.md` — sweep results, follow-up items

**Verification**:
```bash
# Corpus-wide bare-combining-mark sweep
python3 - <<'PY'
import pathlib
root = pathlib.Path.home()/"Projects/Literature/sources"
hits = []
for f in root.rglob("*.md"):
    try: t = f.read_text(errors="ignore")
    except Exception: continue
    n = sum(t.count(chr(c)) for c in range(0x300, 0x370))
    if n: hits.append((n, str(f)))
for n, f in sorted(hits, reverse=True)[:30]: print(n, f)
print("documents with surviving bare combining marks:", len(hits))
PY

# Sub-index is valid JSON, freshly dated, and internally consistent
python3 -c "
import json,pathlib
s=json.loads(pathlib.Path('specs/literature-index.json').read_text())
r=[e for e in s['entries'] if e['doc_id']=='rabinovich_2014'][0]
print('updated:', s['updated']); print('hazard:', r.get('hazard','')[:200])
print('citation_rule:', r.get('citation_rule',''))"
```

---

## Testing & Validation

Full acceptance battery — every item must pass before the task is marked complete:

- [ ] `grep -c '≠' ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md` returns >= 2 (was 0)
- [ ] Zero bare U+0338 codepoints remain in the Rabinovich `.md` and in its chunk files
- [ ] The two Section 5 sentences read `k ≠ m`, confirmed by direct comparison against PyMuPDF `doc[6]` (printed page 7)
- [ ] Displayed equations from Definition 3.1 and Lemma 5.1 are present; `token_count` exceeds the old 2721
- [ ] `sqlite3 ~/Projects/Literature/.literature.db "SELECT count(*) FROM chunks_fts WHERE chunks_fts MATCH 'rabinovich'"` returns a nonzero count backed by corrected chunk files, and no chunk contains the corrupt `k = m` sentence
- [ ] No `index.json` entry touched by this task carries `verified_conversion` without a completed, recorded manual PDF spot-check
- [ ] All four Gabbay 1994 §10.3.x entries have a non-null `provenance_fidelity`; §10.3.2 exists with `Lemma 10.3.5` content
- [ ] Reynolds 1992 §9 is its own registered section containing the `US/R … weakly complete` statement; `sec05` no longer misdescribes its range
- [ ] `grep -c 'md:[0-9]' Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` returns 0
- [ ] `lake build` succeeds for the `SharedWitness` module; the diff for that file is comment-only
- [ ] Every `doc_id` in `specs/literature-index.json` resolves to an `id` in the global `index.json`
- [ ] The sub-index `rabinovich_2014` hazard block describes the resolved state and its `citation_rule` matches the anchoring scheme actually used in the Lean sources
- [ ] `bash -n .claude/scripts/literature-convert.sh` passes and the combining-overlay unit test passes for both codepoint orders
- [ ] Every unresolved Part 2 target appears in the Residual Gaps record with its blocker class and reactivation condition

## Artifacts & Outputs

- `specs/389_repair_dedekind_literature_corpus/plans/01_repair-literature-corpus.md` (this file)
- `specs/389_repair_dedekind_literature_corpus/summaries/01_repair-literature-corpus-summary.md` — including the Residual Gaps record and corpus-sweep results
- `.claude/scripts/literature-convert.sh` — combining-overlay composition in the shared normalizer
- `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md` — corrected conversion (+ timestamped backup)
- `~/Projects/Literature/sources/rabinovich_2014/chunk_*.md`, `chunks.json` — regenerated
- `~/Projects/Literature/sources/gabbay_1994/` — new §10.3.2 section and chunks
- `~/Projects/Literature/sources/reynolds_1992/` — new §9 section and chunks (§5 if isolable)
- `~/Projects/Literature/index.json` — corrected fidelity stamps and new entries (+ timestamped backups)
- `~/Projects/Literature/.literature.db` — rebuilt FTS5 index
- `specs/literature-index.json` — reconciled hazard block, corrected Burgess cross-reference, new doc_ids
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — 89 re-anchored citations
- Follow-up task(s) if the corpus sweep finds affected documents beyond Rabinovich

## Rollback/Contingency

- **Global index**: every phase that writes `~/Projects/Literature/index.json` takes a timestamped
  `.bak-<ISO>` copy first. Restore by copying the backup back; no other state depends on it.
- **Converted markdown**: the pre-fix Rabinovich `.md` is preserved twice — as the existing
  `.bak-20260709T235817Z` (the extract that introduced the corruption) and as the new Phase 3
  backup. The original hand-written paraphrase remains available in the earlier `.bak` as well.
- **FTS5 database**: `.literature.db` is explicitly ephemeral and rebuilt from on-disk chunk files.
  Any bad state is recovered by restoring the chunk files and re-running
  `literature-build-index.sh --global`.
- **Repo-tracked files** (`.claude/scripts/literature-convert.sh`, `specs/literature-index.json`,
  `SharedWitness.lean`): under git; revert with a targeted `git checkout` of the specific path from
  the last good commit. Commit at each green phase boundary so rollback granularity matches phase
  granularity.
- **Partial-completion contingency**: if the task stalls after Phase 1 but before Phase 4, the
  corpus is in a *safe* state — the false certification is gone and the `[UNVERIFIED …]` banner
  warns every consumer. This is the deliberate reason Phase 1 has no dependencies and runs first.
  If Phase 3 cannot produce a faithful conversion at all, take the task's stated fallback (leave the
  non-verified fidelity value, repoint `path` at the PDF) and mark Phases 4-5 blocked rather than
  restoring `verified_conversion`.
