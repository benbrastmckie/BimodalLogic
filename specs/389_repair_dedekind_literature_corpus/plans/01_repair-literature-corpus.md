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

### Phase 5: Re-anchor the 89 dangling md:NN citations to stable references [NOT STARTED]

**Goal**: The re-conversion invalidates every `md:NN` line-number citation. Convert all 89
occurrences in `SharedWitness.lean` to references that survive future re-conversions: keep the
already-present structural label (`**Lemma 5.1**`, `Def 3.1`, `Cor 5.4`, `Prop 3.5`, …) as the
primary anchor and replace the volatile `md:NN` with a printed-PDF-page reference.

**Tasks**:
- [ ] Enumerate all 89 occurrences (78 distinct lines) and their line-number ranges
      (`md:72`, `md:154-157`, `md:61-74`, …).
- [ ] Derive an old-line -> printed-PDF-page mapping mechanically: for each old `md:NN`, read line
      `NN` of the **pre-fix** `.md` backup created in Phase 3, extract a distinctive phrase, and
      locate that phrase in the PDF's per-page extracted text to obtain the printed page number.
- [ ] Rewrite each citation as `PDF p.N` (ranges become `PDF pp.N-M`), preserving the surrounding
      structural label so the citation remains meaningful even if the page mapping is later revised.
- [ ] Confirm every edit lands inside a comment or docstring — no proof term, statement, or
      identifier changes.
- [ ] Verify the module still builds.

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

### Phase 6: Close the Gabbay 1994 Ch.10 §10.3.2 conversion gap [NOT STARTED]

**Goal**: Convert, chunk, and register §10.3.2 "Pre-eliminations" — the negation-lemma machinery
(`Lemma 10.3.5`, identities for `~U(A,B)` / `~S(A,B)` over Dedekind complete flows) that is the
load-bearing separation content for this effort — and adjudicate the three sibling sections whose
`provenance_fidelity` is currently absent.

**Tasks**:
- [ ] Extract PyMuPDF page indices 11–14 of
      `sources/gabbay_1994/Gabbay_Hodkinson_Reynolds_1994_..._ch10.pdf` into a temporary
      single-section PDF, then convert it with the Phase 2 normalization in place.
- [ ] Confirm the extracted range actually begins at the `10.3.2` heading and ends before `10.3.3`
      (heading indices confirmed by research: 10.3.1@8, 10.3.2@11, 10.3.3@15, 10.3.4@19).
- [ ] Chunk and register the new section in `index.json` as a sibling of the existing
      `gabbay_1994_ch10_sec02/03/04` entries, with `page_range` and `parent_doc` matching the
      existing convention.
- [ ] Add its `doc_id` to `specs/literature-index.json`.
- [ ] **Spot-check §10.3.2 and each of 10.3.1 / 10.3.3 / 10.3.4 against the PDF** before assigning
      `provenance_fidelity`. Assign `verified_conversion` only to those that pass; for any that do
      not, assign the honest enum value and note why.
- [ ] Rebuild the global FTS5 index.

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

---

### Phase 7: Close Reynolds 1992 §9 and adjudicate §5 [NOT STARTED]

**Goal**: Split §9 "Completeness" (real-flow weak completeness — directly on-topic, currently
straddled by the `sec05` chunk whose page range starts on the same page §9 begins) into its own
registered chunk, and reach a decided outcome on §5.

**Tasks**:
- [ ] Confirm the `9 Completeness` heading at PyMuPDF page index 24 (**printed page 189**) and
      locate the `10 …` heading that bounds it.
- [ ] Re-chunk the 189-193 range so §9 and §10 are separate sections rather than one `sec05` chunk
      labelled "§10"; correct the existing `sec05` entry's `section` / `page_range` accordingly.
- [ ] Register the new §9 entry in `index.json` and add its `doc_id` to `specs/literature-index.json`.
- [ ] **§5, time-boxed to 30 minutes**: visually inspect printed pp.177-180 (PyMuPDF indices 12-15)
      for the §5 heading. This PDF's OCR is poor (`K-(-,R)` for `¬(¬R)`, `vy` for `∀y`), so automated
      heading search is known-unreliable here. If the boundary is found, chunk and register §5 the
      same way. If it is not found within the time box, stop and record §5 as a residual gap with
      "OCR quality prevents reliable section-boundary detection" as the reason — do not guess.
- [ ] Spot-check §9 (and §5 if converted) against the PDF before assigning any fidelity value.
- [ ] Rebuild the global FTS5 index.

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

---

### Phase 8: Time-boxed acquisition attempts and residual-gap documentation [NOT STARTED]

**Goal**: Reach an honest, recorded outcome for the three Part 2 targets the research established
are NOT fixable by re-running the conversion pipeline, and resolve the Burgess sub-index
cross-reference discrepancy.

**Tasks**:
- [ ] **Gabbay & Reynolds 2000 Vol.2** (source-scan-quality blocker; `.md.rejected` is genuine
      Tesseract garbage). Time-box 30 min: run `literature-discover.sh` for a better-quality scan.
      If none is obtainable, leave `provenance_fidelity: "not_yet_converted"` (already correct) and
      record the blocker. Do not re-run the pipeline on the same scan — the research established it
      will fail the quality gate identically.
- [ ] **Hodkinson & Reynolds 2006 Ch.11** (acquisition blocker; the source PDF is 3 pages —
      TOC + Introduction only; Sections 2-6 / pp.658-712 were never acquired). Time-box 30 min:
      attempt discovery of the complete 65-page chapter. If unobtainable, keep the entry but qualify
      it: the existing `verified_conversion` is defensible only in the narrow sense that it
      faithfully represents an incomplete source, and the `.md` already carries a tail disclosure
      note. Ensure that limitation is also visible in `index.json`'s `summary` and in the sub-index.
- [ ] **Burgess 1984 §4**: resolve the cross-reference discrepancy the research flagged — the
      sub-index's `burgess_1984_sec04` entry describes "Chronicles and Killing Lemma" content while
      the thin 982-token/11-page chunk in `index.json` is `burgess_1984_sec07`. Determine which
      section the sub-index actually intends, correct the `doc_id` reference, and, if §4 "Expressive
      Completeness and Kamp's Theorem" is genuinely under-converted, re-convert its page range with
      the Phase 2 normalization in place and spot-check before stamping.
- [ ] Write a "Residual Gaps" record into the task summary artifact listing, for each unresolved
      item: the target, the blocker class (acquisition / source-scan-quality / OCR-boundary), what
      was attempted, and the condition under which it becomes actionable.

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
