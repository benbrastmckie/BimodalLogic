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

*(To be completed after Phase 5 ingest produces corpus chunks. This section is appended by the
Phase 6 dispatch step, not populated at Phase 4 time.)*
