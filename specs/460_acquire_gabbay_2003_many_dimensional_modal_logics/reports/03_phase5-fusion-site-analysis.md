# Report: Phase 5 Ingest Rejection — Sentence-Boundary-Glue Fusion-Site Analysis

- **Task**: 460 - Acquire a usable copy of Gabbay, Kurucz, Wolter and Zakharyaschev 2003
- **Artifact**: reports/03_phase5-fusion-site-analysis.md
- **Standards**: artifact-management.md

## Purpose

Phase 5's `literature-ingest.sh` run rejected the OCR'd merged PDF at the conversion quality gate:

```
[convert] QUALITY GATE FAILED (pymupdf4llm): sentence-boundary-glue: 19 zero-space
word/sentence-fusion transition(s) found (threshold 3)
```

This report locates and quotes all 19 flagged sites, cross-checks each against the independent
`ocrmypdf` sidecar extraction, and records the resulting verdict on the central question: is this
a genuine text-layer defect requiring an input fix, or an artifact of the `pymupdf4llm` extraction
path specifically. It also records a good-faith attempt at the plan's sanctioned "retry OCR with
different settings" contingency, and the resulting decision to treat Phase 5 as blocked rather
than force the ingest through.

## Method

`literature-ingest.sh`'s temp conversion directory (`mktemp -d`) is deleted on quality-gate
rejection, so the rejected `.md` no longer existed after the failed run. `literature-convert.sh`
was re-run standalone (same unmodified script, same PDF, a fresh scratch output directory) to
regenerate the identical rejected output for inspection — this reproduces, but does not alter,
the exact conversion the ingest pipeline performed. The counting/exemption logic of
`literature_quality_gate.py`'s `sentence_boundary_glue_count()` was replicated verbatim (`Ph\.D\.?`
strip, then `[∀∃λ][a-z]\.[A-Z]` binder-notation strip, then count `[a-z]\.[A-Z]`) against the
reproduced `.rejected` file, confirming 19 matches — the same count the live gate reported.

For each match, the surrounding ~160 characters were read and compared against the same passage
in `ocr-full.txt` (the concatenated `ocrmypdf --sidecar` OCR text — the same text Phase 4's
semantic gate hand-read and passed) by grepping for literal substrings. Physical PDF page numbers
were resolved with PyMuPDF where a substring was unique enough to locate directly.

## All 19 Flagged Sites, Quoted

| # | Match | Context (pymupdf4llm `.rejected` output) | Category |
|---|-------|-------------------------------------------|----------|
| 1 | `x.Y` | "...the only non-trivial case is a = **YUx.YUx**. (=) If (M, n) = YUx then there is an m > n such that..." | Proof-lemma formula (garbled) |
| 2 | `x.Y` | "...case is a = **YUx.YUx**.\n\nNow it follows from (2.6) that (90,0) £~ ¢, as required..." | Proof-lemma formula (garbled), second occurrence |
| 3 | `s.M` | "Child € **dhas.Mother** I dhas.Father" | DL existential role restriction (∃has.Mother) |
| 4 | `s.F` | "Child € dhas.Mother I **dhas.Father**" | DL existential role restriction (∃has.Father) |
| 5 | `t.C` | "Eve : Mother, Adam : Father, Fuve loves Adam » ABox FEve : **dparent.Child** Adam : dparent.Child" | DL existential role restriction (∃parent.Child) |
| 6 | `t.C` | "...FEve : dparent.Child Adam : **dparent.Child** /\n\nObserve that the relation..." | Same, second occurrence |
| 7 | `t.C` | "Eve : **3_sparent.Child**\n\n(Eve has two children)," | Same construct, different corrupted prefix ("3_s" for ∃) |
| 8 | `s.M` | "Child C **9_;has.Mother**\n\n(every child has one mother)," | Same construct, corrupted prefix "9_;" |
| 9 | `s.C` | "First_Parent C J(parent o parentTM).**3drives.Car**" | DL role composition + existential restriction |
| 10 | `s.C` | "John : **dhas.Car**" | DL existential role restriction (∃has.Car) |
| 11 | `s.C` | "Modern_car = Car M **Jhas.Computer**" | DL existential role restriction (∃has.Computer) |
| 12 | `s.C` | "Customer = Homo_sapiens N (sometime in the past) **dbuys.Car**" | DL existential role restriction (∃buys.Car) |
| 13 | `s.C` | "Faithful_customer = Customer I J[always|**buys.Car**]" | DL + temporal-modal combined formula |
| 14 | `s.M` | "(John believes) (next year) (Male_customer C J**buys.Modern_car**)" | DL existential role restriction (∃buys.Modern_car) |
| 15 | `n.P` | "Mortal = Living_being N (3**lives_in.Place**) I ..." | DL existential role restriction (∃lives_in.Place) |
| 16 | `n.T` | "(MM, (w0, Y0)) & @**n.T**-\n\nThen we define a map..." | Hybrid-logic satisfaction formula (@n.⊤, garbled) |
| 17 | `p.L` | "Opl — OO**p.L** is valid in all synchronous systems based on (N, <)..." | Temporal-logic formula (garbled) |
| 18 | `u.T` | "Medvedev 1962. **Yu.T. Medvedev**. Finite problems. Soviet Mathematics Doklady, 3:227-230, 1962." | Bibliography citation, initials |
| 19 | `u.T` | "...the concept of **Yu.T. Medvedev**'s types of information. Semiotics and Information Science..." | Same citation, second occurrence |

## Sidecar Cross-Check (independent OCR extraction)

The same substrings were located verbatim in `ocr-full.txt` (the `ocrmypdf --sidecar` text — the
extraction Phase 4's hand-read semantic gate already sampled and passed):

```
$ grep -n "has.Mother" ocr-full.txt
3611:Child € dhas.Mother I dhas.Father
4045:Child C 9_;has.Mother

$ grep -n "Medvedev" ocr-full.txt
32399:Medvedev 1962. Yu.T. Medvedev. Finite problems. Soviet Mathematics Dok-
32767:the concept of Yu.T. Medvedev's types of information. Semiotics and In-

$ grep -n "drives.Car" ocr-full.txt
4049:First_Parent C J(parent o parent™).3drives.Car

$ grep -n "YUx" ocr-full.txt
2617:case is a = YUx.
2619:(=) If (M, n) = YUx then there is an m > n such that (M, m) = x
```

**Every checked fusion is present, character-for-character, in the sidecar too.** This is
decisive: the `pymupdf4llm` markdown extraction and the independent `ocrmypdf` sidecar extraction
agree on these transitions. The fusions are not an artifact introduced by `pymupdf4llm`'s
markdown-conversion step (the failure mode named in `sentence_boundary_glue_count()`'s own
docstring — dropped spaces around `<sup>`/`<sub>` markdown spans). They are genuinely present in
the OCR'd text layer itself, upstream of either extraction path.

## Physical Location

PyMuPDF page lookup on unique substrings resolves the sites to two tight page clusters:

- `dhas.Mother` → PDF page 82; `3drives.Car` → PDF page 91. All of sites 3–15 (the 13
  description-logic ∃-role-restriction fusions) fall inside this single ~10-page span — book
  §3.8 "Description logics with modal operators" (the "163" and surrounding page numbers visible
  in the excerpts are the book's own printed pagination, not PDF page indices).
- `Yu.T. Medvedev` → PDF pages 712 and 719 — both in the bibliography, both the same recurring
  citation.
- Sites 1–2 (`YUx.YUx`) and 16–17 (`@n.T`, `Opl—OOp.L`) are isolated proof/formula lines in other
  math-heavy sections.

**Zero of the 19 sites occur in ordinary prose.** None resemble the corruption signature
`sentence_boundary_glue_count()` was originally built to catch (the Goldblatt/Hodkinson/Venema
`<sup>`/`<sub>`-span word-fusion precedent, e.g. "Thesecondlinefollowsby"). All 19 sit inside
mathematical/logical notation or a single repeated citation.

## Root Cause

13 of 19 sites (68%) are the standard, textbook description-logic existential-restriction
notation `∃R.C` (e.g. `∃has.Mother`, `∃buys.Car`), which by domain convention carries **no space**
around the `.` — the notation is *supposed* to look exactly like this. The only actual defect is
that `tesseract`'s `eng` model does not reliably recognize the `∃` glyph and substitutes a stray
ASCII character in its place (`d`, `3`, `3_`, `9_`, `J`, depending on the instance) — a symbol
substitution, not a missing space. `sentence_boundary_glue_count()` already carries an exemption
for exactly this notation class when the binder character is legible
(`[∀∃λ][a-z]\.[A-Z]`), but it cannot recognize an already-mis-OCR'd binder.

2 of 19 sites are the same recurring bibliography citation "Yu.T. Medvedev" (a dropped space
between initials — trivial and non-systemic).

4 of 19 sites (`YUx.YUx` ×2, `@n.T`, `Opl—OOp.L`) are proof/formula fragments too garbled to
confidently reconstruct without guessing at the original symbols.

This is precisely the plan's own pre-declared, accepted risk: *"Math-heavy pages OCR poorly and
propagate wrong formulas into chunks... Known and accepted... Prose fidelity, not formula
fidelity, is the acceptance bar"* (plan Risks & Mitigations table) — confirmed here with a
concentrated, fully-accounted-for set of sites rather than scattered, unexplained noise.

## Retry-OCR Contingency Attempted (per plan Rollback/Contingency: "retry OCR with different
`ocrmypdf` settings... on the failing strata")

PDF page 82 (source slice `batches/src_01.pdf`, page 82) was re-OCR'd in isolation with three
alternative settings to test whether a settings change recovers the `∃` glyph:

| Setting | Result on "Child € dhas.Mother I dhas.Father" |
|---|---|
| `-l eng` (baseline, matches Phase 2) | `dhas.Mother`, `dhas.Father` — unchanged |
| `-l eng --oversample 400` | `dhas.Mother`, `dhas.Father` — unchanged |
| `-l eng --tesseract-pagesegmode 6` | `dhas.Mother`, `dhas.Father` — unchanged |
| `-l eng+equ` | Rejected by `ocrmypdf`/tesseract: `equ` is an internal-use-only model, not directly selectable |

None of the three viable settings changes tesseract's rendering of `∃`. This is consistent with
the symbol being outside `eng`'s trained glyph set entirely (a model-capability limitation, not a
scan-quality or page-segmentation issue that oversampling/PSM tuning could address). No further
OCR-settings retry is expected to help without a different, math-symbol-trained OCR engine, which
the task's own research already established is not available in this environment.

## Verdict

**Neither (a) nor (b) as originally framed is quite right.** The fusions are not a `pymupdf4llm`-
specific extraction artifact (ruled out by the sidecar cross-check — hypothesis (b) is false as
stated). But they are also not evidence of the kind of systemic, printable-but-wrong corruption
this task's quality gates exist to catch (the 2260-mojibake precedent) — they are the accepted
math/DL-notation OCR-fidelity limitation the plan already priced in, concentrated in one ~10-page
DL-notation passage plus one recurring citation plus 4 isolated formula lines, with zero prose
corruption anywhere in the 19 sites.

Even a maximally honest correction — restoring the unambiguous citation spacing (2 sites) and the
well-evidenced `∃` symbol at every DL-notation site sharing the same corrupted-prefix pattern (13
sites) — still leaves 4 irreducible formula-noise sites (`YUx.YUx` ×2, `@n.T`, `Opl—OOp.L`) that
cannot be reconstructed without guessing at unverifiable symbols. 4 ≥ the gate's threshold of 3,
so **no honest, non-fabricating correction of this OCR'd text can pass the unmodified
`sentence_boundary_glue_count()` check.** Fabricating plausible-looking replacement symbols at
those 4 sites to force a pass would reproduce exactly the failure mode this task exists to
prevent, and is not attempted here.

Given the explicit constraint against weakening, disabling, raising the threshold of, bypassing,
or working around the conversion quality gate to force this ingest through, **Phase 5 is recorded
as `[BLOCKED]`**, not force-completed. See the plan's Phase 5 section and this task's
`.orchestrator-handoff.json` for the blocker record and escalation options.
