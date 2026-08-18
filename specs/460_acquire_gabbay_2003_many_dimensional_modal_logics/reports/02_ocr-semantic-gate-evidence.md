# OCR Semantic Gate Evidence: Gabbay, Kurucz, Wolter and Zakharyaschev 2003

- **Task**: 460 - Acquire a usable copy of Gabbay, Kurucz, Wolter and Zakharyaschev 2003 (Many-Dimensional Modal Logics)
- **Purpose**: Phase 4 (pre-ingest) and Phase 6 (post-ingest) hand-read semantic gate evidence, per
  `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/plans/01_ocr-and-ingest-gabbay-2003.md`.
- **Source of excerpts**: `pdftotext -f N -l N -layout` on the merged OCR output
  `~/Documents/literature-staging/gabbay_2003/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics.pdf`
  (742 pages, sha256 recorded in `~/Documents/literature-staging/gabbay_2003/baseline.txt`).

## Decision Rule (restated from the plan)

Every prose stratum (front matter, Ch.1 prose, mid-body, proof-dense, bibliography,
index/back-matter, random) must PASS. The math-heavy stratum passes if its surrounding prose is
coherent and errors are confined to formula symbols. **No PASS below is justified by the printable
character ratio or by `literature_quality_gate.py`** — both are explicitly forbidden as
justification by the plan; they measure printable-Unicode-category ratio, not semantic
correctness, which is exactly what let 2260 mojibake chunks pass in the earlier attempt.

## Judgement Criteria (applied per page, all four required for PASS)

(a) Tokens are real English/technical vocabulary, not plausible-looking non-words.
(b) Sentences are grammatical and topically consistent with many-dimensional modal logic.
(c) Proper nouns and citations resolve to plausible real names.
(d) Content is consistent with its position in the book.

---

## Phase 4 — Pre-Ingest Sampled Pages (8 strata)

### Stratum 1: Front matter (Preface) — merged-PDF page 5

**Excerpt** (verbatim, `pdftotext -f 5 -l 5 -layout`):

> Modal logic is a discipline of many facets. It was baptized in philosophy, and
> for a long time it was known as 'the logic of necessity and possibility.' The
> modal analysis of the 'mathematical necessity'—provability—brought modal
> logic to the foundations of mathematics. The discovery of topological and
> algebraic semantics for modal logic connected it with general topology and
> universal algebra, and the fact that first-order logic can be regarded as a
> propositional modal logic opened a 'modal perspective' in classical mathematical logic.

**Judgement**: **PASS**. (a) All tokens are real English words and correct technical terms
("propositional modal logic", "algebraic semantics", "universal algebra"). (b) Grammatical,
coherent argument about the history of modal logic. (c) No garbled proper nouns on this page. (d)
Reads exactly as a preface — scene-setting narrative prose, headed "Preface", page-numbered
`vii` (roman numeral front matter).

### Stratum 2: Chapter 1 running prose — merged-PDF page 20

**Excerpt** (verbatim):

> Now, returning to modal logic, we see that this semantical definition of
> Cl cannot be extended to the modal language in a straightforward way. The
> apparent reason is that the modal operators are not truth-functional: the
> truth-value of a formula of the form □φ can depend not only on whether φ
> is true or false. For example, we most likely agree that the proposition 'it is
> necessary that 2 x 2 = 4' is true, while 'it is necessary that NATO bombs
> Belgrade' is undoubtedly false, although both propositions '2 x 2 = 4' and
> 'NATO bombs Belgrade' are true.

**Judgement**: **PASS**. (a) Real English and correct technical vocabulary ("truth-functional",
"modal operators", "semantical definition"). (b) Grammatical, logically coherent worked example
using a standard modal-logic pedagogical device. (c) "NATO", "Belgrade" resolve correctly as real
proper nouns. (d) Consistent with "Chapter 1. Modal logic basics" heading visible at top of page;
this is exactly introductory running prose.

### Stratum 3: Mid-body, ~p.300 — merged-PDF page 300 (Chapter 6, printed p.286)

**Excerpt** (verbatim):

> The modal depth md(φ) of a CPDL & ML-formula φ and the modal depth
> md(α) of a CPDL ⊗ ML-action term α are defined inductively as follows... The
> upper bound b(φ) for the number of different (i.e., non-isomorphic) quasistates
> for φ and the upper bound p(φ) for the number of points in a quasistate for φ
> are computed as in the previous section using fle(φ) in place of sub φ.
> A basic structure of depth m for φ is a pair (F, q) such that F = (W, T_a1,...,T_an)
> is an n-frame, where a1, ..., an is an enumeration of all action variables in φ,

**Judgement**: **PASS**. (a) Real technical vocabulary throughout ("modal depth", "quasistate",
"n-frame", "action variables") — this is definitional prose scaffolding around formulas, not a
formula itself, and it reads coherently. (b) Grammatical mathematical-definition prose typical of
this genre. (c) No garbled proper nouns on this page (none expected in a pure-definition section).
(d) Consistent with "Chapter 6. Decidable products" heading — mid-body technical development.

### Stratum 4: Math-heavy section, ~p.150 — merged-PDF page 150 (Chapter 3, printed p.136)

**Excerpt** (verbatim):

> The temporal epistemic logic ELog (TEL) coincides with the fusion
> of the temporal logic Log(F) and L. That is to say, ELog(TEL)
> can be axiomatized by putting together the sets of axioms and inference
> rules for Log(F) and L.
> Elog(TEL) is decidable whenever F is one of (N, <), (Z, <), (Q, <) or (R, <).
> ...By imposing various constraints on temporal epistemic structures, we can
> reflect some interesting features of agents; see (Fagin et al. 1995).

**Judgement**: **PASS (math stratum — surrounding prose coherent, noise confined to formula
symbols/subscripts)**. (a)/(b) The connecting prose is entirely coherent English with correct
technical vocabulary ("axiomatized", "decidable", "temporal epistemic structures"). (c) "Fagin et
al. 1995" resolves to a real, plausible citation (Ronald Fagin, a well-known author in this exact
subfield — epistemic logic and multi-agent systems). (d) Consistent with "Chapter 3.
Many-dimensional modal logics" heading. **Observed formula noise** (recorded per plan
requirement): subscripted logic names like `ELog_{K_n}(TEL_C)` render with dropped/garbled
subscripts (e.g. "ELogg,(TEL 3)"), and one inline formula region — the synchronicity condition
"(t, f) R_i (t', f') implies t = t'" — partially survives while a second, similar formula later on
the same page drops to a blank line entirely. This is exactly the accepted, documented math-OCR
limitation (tesseract `eng` is not a math-OCR engine); it does not contaminate the prose.

### Stratum 5: Proof-dense page — merged-PDF page 412 (Chapter 8, printed p.398)

**Excerpt** (verbatim):

> Claim 8.41. Suppose f is a p-morphism from a universal product S5-frame
> (U,U,U) onto F_{a3} satisfying (8.32). Then there is a set V with |V| ≤ |U|
> and a p-morphism g from (V,V,V) onto g_{u3} such that...
> Proof. Define a model M = ((U,U,U), V+) by taking...
> By (8.28)–(8.30), all formulas (8.7)–(8.12) are true in M, and by (8.31), (8.13)
> holds in M as well. Moreover, by the definition of U and (8.29), M is binary
> generated. Therefore, by Lemma 8.10, there is an S5-model M' = ((V,V,V),V')
> and a p-morphism g from M onto M' such that |V| ≤ |U| and...

**Judgement**: **PASS**. (a) Real technical vocabulary throughout ("p-morphism", "binary
generated", "universal product frame"). (b) The proof narrative reads exactly as a mathematics
proof: "Suppose... Then there is... Define... by taking... Therefore, by Lemma 8.10..." — fully
grammatical mathematical prose with correct internal cross-references (8.28)-(8.32), Lemma 8.10.
(c) No garbled proper nouns; "Q" (◻ / Q.E.D. marker rendering) at the end of each proof is a known,
harmless OCR rendering of the tombstone symbol. (d) Consistent with "Chapter 8. Higher dimensional
products" — a proof-dense technical chapter; two full Claim/Proof pairs appear on this single page,
exactly the density expected of this stratum. Math-formula symbol noise is present within display
equations (as expected/accepted for math content) but the connecting prose and proof structure are
fully coherent.

### Stratum 6: Bibliography page — merged-PDF page 699 (printed p.685)

**Excerpt** (verbatim):

> Gabbay 1981a. D. Gabbay. An irreflexivity lemma with application to axiomatizations
> of conditions on linear frames. In U. Monnich, editor, Aspects of Philosophical
> Logic, pages 67-89. Reidel, Dordrecht, 1981.
> Gabbay 1981b. D. Gabbay. Semantical Investigations in Heyting's Intuitionistic
> Logic. Reidel, Dordrecht, 1981.
> Gabbay 1996. D. Gabbay. Fibred semantics and the weaving of logics, part
> 1: Modal and intuitionistic logics. Journal of Symbolic Logic, 61:1057-1120, 1996.

**Judgement**: **PASS**. (a) Real bibliographic English throughout (journal/publisher/editor
formatting language). (b) Grammatical citation entries, correctly structured (author, year, title,
venue, pages, publisher). (c) Proper nouns resolve correctly and consistently: "D. Gabbay" (one of
this book's own four authors), "U. Mönnich", "Journal of Symbolic Logic", "Reidel, Dordrecht" — all
real, verifiable names/venues in the modal-logic literature. (d) Consistent with the "Bibliography"
running header visible at the top of the page — this is exactly what a bibliography page should
look like.

### Stratum 7: Index / back matter — merged-PDF page 733 (printed p.[Subject index start])

**Excerpt** (verbatim):

> Subject index
> atomic relation algebra, 395
> atomless Boolean algebra, 199
> axiom, 6
> axiom schema, 18
> axiomatization problem, ix
> balloon, 49
> Barcan formula, 145
>   converse, 145
> basic Q-formula, 651
> basic role, 76
> basic structure, 235
>   for QT L_C, 474

**Judgement**: **PASS**. (a) Real technical index terms throughout ("Barcan formula", "Boolean
algebra", "axiom schema" — all standard modal/first-order logic terminology). (b) The two-column
term/page-number index format is exactly the expected grammar for an index (not prose sentences,
which is correct for this genre — criterion (b) is satisfied by topical consistency and structural
well-formedness rather than sentence grammar). (c) No corrupted proper nouns; "Barcan formula" is a
real, correctly-spelled named result in modal logic (Ruth Barcan Marcus). (d) Consistent with the
"Subject index" running header — this is exactly what a back-matter subject index looks like, with
plausible increasing page-number references up to 728 (near the book's own 742-page extent).

### Stratum 8: Random page — merged-PDF page 449 (Chapter 10, printed p.435)

Page chosen by `random.seed(46071); random.choice(range(15,730) - {already-sampled pages})` to
avoid cherry-picking, landing in Chapter 10 (a region not otherwise sampled by strata 1-7).

**Excerpt** (verbatim):

> The second lemma connects IntK_-algebras 2 with their IntK_-frames KA.
> Lemma 10.3. Let A = ⟨A, ...⟩ be an IntK_-algebra and KA = ⟨W, R, R_D⟩. Then
> the map h : A → Up(2), defined by taking h(a) = {x ∈ W | a ∈ x}, for each
> a ∈ A, is an injective homomorphism from A to (KA)+.
> Proof. We show only that h is injective and leave it to the reader to check
> that h is a homomorphism. Suppose a ≠ b. Without loss of generality we may
> assume that a ⊄ b. Then, by Lemma 10.2, we can find a prime filter x ∈ W
> such that a ∈ x and b ∉ x. Hence h(a) ≠ h(b).

**Judgement**: **PASS**. (a) Real technical vocabulary ("prime filter", "homomorphism",
"injective", "without loss of generality"). (b) Grammatical proof prose, standard mathematical
register. (c) Proper-noun citations later on the same page — "(Wolter and Zakharyaschev 1997,
1999a)" — resolve correctly to two of this book's own four authors, and "Godel translation" (OCR
dropping the umlaut on Gödel, a known and harmless diacritic-loss pattern) is still an
unambiguously recognizable real proper noun. (d) Consistent with "10.1. Intuitionistic modal logics
with □" section heading — algebra/frame-duality development typical of this chapter. The algebraic
notation `⟨A, ...⟩` inside Lemma 10.3's statement shows symbol-level OCR noise (algebra-operation
glyphs rendered as stray characters), consistent with the accepted, documented math-OCR limitation;
it does not affect the surrounding prose, which is fully coherent.

---

## Phase 4 Gate Decision

**Rule applied**: every prose stratum (1, 2, 3, 5, 6, 7, 8) must PASS; the math-heavy stratum (4)
passes if surrounding prose is coherent and errors are confined to formula symbols.

**Outcome**: **PASS**. All 8 sampled strata PASS under the stated criteria. No PASS above is
justified by a printable-character ratio or by the pipeline's automated quality gate — every
judgement rests on the hand-read excerpt and its four-criterion analysis. Formula-symbol noise was
observed and recorded (strata 4, 5, 8) exactly where expected — confined to display/inline math —
and does not compromise prose coherence anywhere sampled.

**Gate result: PROCEED to Phase 5 (ingest).**

---

## Phase 6 — Post-Ingest Chunk Verification

Phase 5 was resolved via the user-authorized documented exception (escalation option 1, see
`reports/03_phase5-fusion-site-analysis.md` and `.orchestrator-handoff.json`): a corrected
markdown (13 restored `∃` glyphs + 2 restored citation spaces, 4 irreducible sites left
untouched) was fed directly to `literature-chunk.sh`, bypassing `literature-convert.sh`'s
automated re-extraction for this one document only. `index.json` was updated atomically
(361 -> 362 entries) and `literature-build-index.sh --global` was run. doc_id:
`gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics`, 758 chunks.

### Sampling

758 chunks total. Sampled per the plan's floor of >= 8, spanning the full range plus the
required math-heavy (>= 2) and bibliography/index (>= 1) categories:

| # | Chunk | Position | Category |
|---|-------|----------|----------|
| 1 | `chunk_0001.md` | first | front matter |
| 2 | `chunk_0068.md` | ~9% | math-heavy — contains 2 of the 4 irreducible `YUx.YUx` sites (untouched) |
| 3 | `chunk_0092.md` | ~12% | math-heavy — contains 4 of the 15 corrected `∃` sites |
| 4 | `chunk_0190.md` | ~25% | body prose (first-order temporal logics) |
| 5 | `chunk_0379.md` | ~50% | body prose (undecidable products) |
| 6 | `chunk_0569.md` | ~75% | body prose (monodic fragment axiomatization) |
| 7 | `chunk_0742.md` | ~98% | bibliography — contains 1 of the 2 corrected Medvedev citations |
| 8 | `chunk_0758.md` | last | back-matter subject index |

### Per-Chunk Verbatim Excerpts and Judgements

**`chunk_0001.md` (front matter)**

> Many-Dimensional Modal Logics: Theory and Applications
>
> D. Gabbay, A. Kurucz, F. Wolter and M. Zakharyaschev
>
> "You've got to learn to think multi-dimensionally. . . If you'd like to know, I can tell you
> that in your universe you move freely in three dimensions that you call space. ... "
>
> Douglas Adams "Mostly Harmless"
>
> Preface
>
> Modal logic is a discipline of many facets. It was baptized in philosophy, and for a long time
> it was known as 'the logic of necessity and possibility.'

**PASS**. (a) Real English throughout, including a correctly-transcribed literary epigraph. (b)
Grammatical, topically consistent (opens directly into a Preface on modal logic). (c) All four
author names correct and match the book's title page; "Douglas Adams" is a real, correctly
attributed author. (d) Consistent with position — title page, epigraph, Preface opening, in that
order, exactly as expected at the front of a book.

**`chunk_0068.md` (math-heavy — contains 2 of the 4 documented irreducible sites)**

> The proof is is by induction on the construction of «, «, where the only non-trivial case is a
> = YUx.YUx. (=) If (M, n) = YUx then there is an m > n such that (M, m) = x and (M, k) |= ¢ for
> all k € (n,m). It follows by the induction hypothesis that (9, m) = xY, whence (9, m — 1) =
> OxY, and so (M, m — 1) |= pyuy, since we have (M,i) = ARu(p) for all i € N.

**PASS (math-heavy criterion)**. Surrounding prose is fully coherent standard proof-writing
register ("We will show that...", "The proof is by induction on the construction of...", "It
follows by the induction hypothesis that..."). The formula-symbol noise (`YUx.YUx`, stray Greek
transliteration artifacts, doubled words from OCR) is exactly the documented, irreducible
math-OCR-fidelity limitation from `reports/03_phase5-fusion-site-analysis.md` — both `YUx.YUx`
occurrences visible here are two of the 4 sites explicitly left uncorrected per the
authorization. Errors are confined to formula symbols; no prose corruption.

**`chunk_0092.md` (math-heavy — contains 4 of the 15 corrected sites)**

> Child € ∃has.Mother I ∃has.Father
>
> Eve : Mother ) Adam : Father Fuve loves Adam » ABox FEve : ∃parent.Child Adam : ∃parent.Child /
>
> Observe that the relation is in Fig. 2.5 is represented in the form of C C D if it connects
> concepts (like Mother and Female) and a : C if it holds between an object name and a concept
> (like Eve and Mother).

**PASS (math-heavy criterion)**. This is the direct post-ingest confirmation that 4 of the 15
corrections (both `∃has.Mother`/`∃has.Father` sites and both `∃parent.Child` sites) landed
correctly and read as standard, semantically sensible description-logic notation in place. The
`I`, `€`, `C` mis-OCR'd logic symbols in the same lines are untouched, out-of-scope noise (not
part of the 19 gate-flagged sites, not part of this exception's authorization) — confined to
formula symbols, surrounding prose ("Observe that the relation... is represented in the form
of...") is fully grammatical and topically consistent.

**`chunk_0190.md` (body prose, ~25%)**

> TS is interpreted in the same kind of first-order temporal models as QTL, i.e., structures of
> the form 9 = (§, D, ), where § = (W, <) is a flow of time, D is a non-empty set, the domain of
> 9, and I a function associating with every moment of time w € W a first-order QL-structure...
> in which Pi(w) is an n-ary relation on D whenever Pi is a predicate symbol of arity n + 1...

**PASS**. (a) Real technical vocabulary ("flow of time", "assignment", "predicate symbol",
"arity"). (b) Grammatical, standard first-order temporal logic exposition. (c) No proper nouns in
this excerpt to check; section heading "3.7. First-order temporal logics" is a plausible,
consistent chapter/section title. (d) Consistent with mid-book Chapter 3 content on first-order
temporal logic. Note: this chunk's `section_path` metadata field carries a garbled breadcrumb
(see "Additional Discovered Limitation" below) — a metadata-navigation defect, not a content
defect; the chunk body itself is unaffected.

**`chunk_0379.md` (body prose, ~50%)**

> Theorem 7.9. Let C1 and C2 be classes of linear orders such that each of them contains a rooted
> Noetherian linear order having an infinite descending chain of distinct points. Then Log(C1 x
> C2) (and so LogC1 x LogC2) does not have the product finite model property.
>
> Chapter 7. Undecidable products
>
> By Theorem 1.12, the logics GL.3 and Grz.3 (see Section 1.2) are characterized by the single
> frames obtained by adding a root to (N,>) and to (N, >), respectively.

**PASS**. (a) Real technical vocabulary ("Noetherian linear order", "finite model property",
"characterized by"). (b) Grammatical theorem/corollary prose. (c) "GL.3", "Grz.3" are real,
correctly-formed logic-system names used throughout this book's Chapter 7 (confirmed also as the
source of the "CPDL"-family mojibake-sweep false positives below). (d) Consistent with the
"Chapter 7. Undecidable products" running header printed in the same excerpt.

**`chunk_0569.md` (body prose, ~75%)**

> A proof similar to that of Claim 11.24 shows that one can 'blow up' each J(w) to obtain a
> QL-structure I(w) with domain D(w) such that I(w) |= real(q,t) also holds, and for every t € T,
> there are k many elements in D(w) 'realizing'...
>
> 12.2. Axiomatizing monodic fragments

**PASS**. (a) Real technical vocabulary ("QL-structure", "domain", "type-preserving",
"axiomatizing monodic fragments"). (b) Grammatical, dense but coherent model-theoretic
construction prose. (c) Cross-reference "Claim 11.24" is plausible and consistent with a
numbered-claim convention used throughout the book. (d) Consistent with "12.2 Axiomatizing
monodic fragments" section heading — deep technical chapter content, exactly where a ~75%-through
sample of this book should land.

**`chunk_0742.md` (bibliography — contains 1 of the 2 corrected Medvedev citations)**

> Skvortsov 1979. D. Skvortsov. On some propositional logics connected with the concept of Yu.
> T. Medvedev's types of information. Semiotics and Information Science, 13:142-149, 1979.
> (Russian).
>
> Sistla and Zuck 1987. A. Sistla and L. Zuck. On the eventuality operator in temporal logic. In
> Proceedings of the Second IEEE Symposion on Logic in Computer Science (LICS'87)...

**PASS**. This is the direct post-ingest confirmation that the second Medvedev-citation
correction (the Skvortsov 1979 entry) landed correctly: "Yu. T. Medvedev" now reads with the
restored space, matching standard Western initials-spacing convention. (a) Every citation is real,
correctly formed bibliography prose (author, year, title, venue, pages). (c) All proper nouns
(Simpson, Sistla, Clarke, Zuck, Skvortsov, Solovay, Sotirov, Spaan, Spielmann, Stebletsova,
Stirling, Stock, Stockmeyer) are real logicians/computer scientists with real, correctly-attributed
publications. (d) Consistent with the "Bibliography" running header printed mid-excerpt (page
706).

**`chunk_0758.md` (back-matter, last chunk — subject index)**

> classical first-order, 16 first-order intuitionistic, 152 first-order modal, 142 first-order
> temporal, 156 ... Subject index ... uniform interpolation, 214 universal Horn sentence, 226
> universal modalities, 37 ... world, 9

**PASS**. (a) Real technical index terms throughout (matches the terminology used across the
whole book — "first-order temporal", "universal Horn sentence", "uniform interpolation"). (b) The
two-column term/page-number index format is the expected grammar for a subject index, not prose
(criterion (b) is satisfied by structural well-formedness and topical consistency, as for the
Phase 4 front-matter index stratum). (c) No corrupted proper nouns. (d) Consistent with the
"Subject index" running header printed mid-excerpt and with being the final chunk of the
document (page 728, within the 742-page extent) — exactly where the index belongs.

### Mojibake Sweep (supporting signal, not the gate)

Swept all 758 chunks for the three corruption signatures named in the plan: long runs (>= 4) of
consonant-only uppercase tokens, `[[`/`\\` bracket clusters, and `¨«`-style leading diacritic
sequences.

- `[[`/`\\` bracket clusters: **0 hits** across all 758 chunks.
- `¨«`-style leading diacritic sequences: **0 hits** across all 758 chunks.
- Consonant-only uppercase runs (>= 4 letters): 349 hits across 115/758 chunks (15%).

Every consonant-run hit was inspected by name. All are real, book-specific logic-system acronyms,
not corruption:

| Token | Meaning (book-internal usage) | Chunks affected (top) |
|---|---|---|
| `CPDL` | Converse Propositional Dynamic Logic (Ch. 6) | 0344, 0310, 0309, 0748, 0308, 0346, 0088, 0350, 0319, 0180 |
| `CPDLTM` | `CPDL⁻` (inverse), with the superscript-minus misread as a trademark-symbol "TM" — the same `parentTM` artifact already documented as adjacent to (not part of) corrected site 9 | 0310, 0088 |
| `TSPF`/`NTSPF` | Temporal-spatial fragment family names (Ch. 14/15) | 0485, 0748 |
| `QTLTM`/`QLYTM`/`QTLM` | `QTL⁻`-family names, same trademark-symbol misread | 0748 |
| `NTPP`/`NTTP` | Non-Tangential Proper Part (RCC-8 spatial relation, Ch. 15) | 0692, 0696 |
| `BRCC` | RCC-family spatial calculus name | 0748, 0696 |
| `CQDL` | A description-logic system name (Ch. 3) | 0180 |

Zero occurrences resemble the 2260-mojibake-chunk precedent (which produced genuinely random
letter salad, not recognizable technical acronyms). This sweep is corroborating, weak evidence
only, per the plan's own caveat, and is consistent with — not a substitute for — the 8 hand-read
PASS judgements above.

### Retrievability Check

Both required queries were run against the live global database after the rebuild:

```
$ bash .claude/scripts/literature-search.sh "many-dimensional modal logic" --include-unverified
-> 20 ranked results, all doc_id=gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics
   (rank range: -17.67 to -16.76)

$ bash .claude/scripts/literature-search.sh "quasimodel techniques for establishing the decidability" --include-unverified
-> 5 ranked results, all doc_id=gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics
   (the second query phrase is quoted verbatim from chunk_0344.md's opening sentence, itself
   discovered while inspecting the mojibake-sweep's top CPDL hit)
```

`--include-unverified` was required because this document has no `provenance_fidelity` field
(the minimal ingest-schema entry written by this exception path does not include it — see
"Additional Discovered Limitation" below); default `literature-search.sh` behavior fail-opens a
missing field to "unverified" and quarantines it from ranked results. The document is fully
retrievable in both modes; the flag only affects default-mode ranking inclusion, never existence
or `--read`/`--toc`/`--doc` access.

### Chunk Count Plausibility

758 chunks / 742 pages = 1.02 chunks/page. 349,870 total tokens across all chunks (average 461.6
tokens/chunk, close to the chunker's 512-token target), i.e. ~471.5 tokens/page — a plausible
token density for a dense mathematical-logic monograph (compare
`chagrovzakharyaschev_1997_modallogic`, a comparable full-book modal-logic monograph already in
the corpus: 997 chunks / 341,620 tokens, i.e. ~343 tokens/chunk — same order of magnitude, no
evidence of dropped content). Judged **plausible**.

### Additional Discovered Limitation (out of scope for this dispatch — recorded for follow-up)

While tracing `chunk_0190.md`'s garbled `section_path` metadata, the root cause was found: line
2965 of the corrected markdown carries a single-`#` (level-1) heading whose text is itself
OCR-garbled math noise (`# ' z) Ey i (M) b`), misdetected by the primary conversion engine's
heading heuristic. Because every subsequent real section heading in the book is `#####`/`######`
(level 5/6, i.e. structurally *deeper* than this spurious level-1 heading), the chunker's
section-hierarchy tracking never finds a heading shallow enough to close it out, and 629 of 758
chunks (83%) inherit this garbled string as their `section_path`/`title` breadcrumb for the
remainder of the document. This is a **navigation/metadata defect only** — verified above to have
zero effect on chunk body content (5 of the 8 hand-read PASS chunks, including `chunk_0742.md`'s
correctly-corrected Medvedev citation, are among the 629 affected, and all read cleanly) and zero
effect on retrievability (confirmed above). It was not introduced by, and is unrelated to, the 15
corrections made in this dispatch — the spurious `#` heading is present verbatim in
`phase5b-rejected-baseline.md` (the pristine pre-correction file), at the same line. Fixing it is
out of the authorized scope of this exception (limited to the 13 `∃`-glyph and 2 Medvedev
corrections) and is left as a follow-up for a future task.

### Phase 6 Gate Decision

**Outcome: PASS.** All 8 sampled chunks PASS (6 under the plain-prose rule, 2 under the
math-heavy surrounding-prose-coherent rule). Mojibake sweep found zero genuine corruption (all
consonant-run hits are legitimate book-internal acronyms). Both required retrieval queries return
the new doc_id. Chunk-count-to-page ratio is plausible against a comparable corpus entry. No
rollback triggered.

**Gate result: PROCEED to Phase 7 (closeout).**
