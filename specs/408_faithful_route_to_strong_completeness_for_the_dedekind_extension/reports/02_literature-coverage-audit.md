# Literature Coverage Audit — Task 408 (Strong Completeness over Dedekind-Complete Flows)

Secondary audit, scoped to literature infrastructure and bibliography only. Does not evaluate
the mathematical route itself.

## Pipeline Verification

**`--lit` mechanics work.** `bash .claude/scripts/literature-briefing.sh` emits a valid
`<literature-briefing>` block with the coverage marker `<!-- lit-coverage mode=repo seg_count=18
sparse=false threshold=3 -->` and the "How to Use" footer. All 18 entries in
`specs/literature-index.json` resolve against `~/Projects/Literature/index.json` — no dangling
`doc_id` references. FTS5 search (`literature-search.sh`) is functional and returns ranked,
relevant hits for "Dedekind complete" and "separation."

**But the sub-index has three classes of coverage gaps**, all confirmed against the global
index and by reading the actual chunk files:

1. **A load-bearing Reynolds 1992 chunk is missing.** `reynolds_1992_sec07` (PDF p.189,
   `verified_conversion`) is in the sub-index and states Theorem 7 ("**US/R** is sound and
   weakly complete... over structures with real flow"), whose proof explicitly invokes "Doets'
   theorem." But `reynolds_1992_sec04` (PDF pp.184-188, `verified_conversion`, titled "§7
   Separability" / "§8 Doets' Theorem") — which contains Lemma 10 (Sep validity), Theorem 5,
   Theorem 6 (= Doets' theorem as Reynolds states it), and Lemmas 11-13 (spot-checked by direct
   read; all present and match the task's citation) — is **absent from
   `specs/literature-index.json`**. The `--lit` briefing therefore never surfaces the exact
   Doets-theorem machinery Theorem 7 depends on.

2. **The single most on-topic Burgess chunk is missing.** `burgess_1984_sec05` (PDF pp.108-115,
   `verified_conversion`, titled "§2 Completeness for Discrete and **Dedekind-Complete** Time")
   is not referenced anywhere in the sub-index, even though the sub-index does include
   `burgess_1984_sec04` (§1), `sec07` (§5), and `sec08` (§4) from the same paper. Spot-read:
   this section gives Burgess's own completeness proof for tense logic over complete
   (gap-free) linear orders via a "completion" construction — directly on task 408's topic.

3. **Two entire already-converted document families are unregistered.** The global corpus
   contains, fully converted with `verified_conversion` provenance (except where noted):
   - `doets_1989_sec01/02/03` — Doets, "Monadic Π¹₁-Theories of Π¹₁-Properties" (the canonical
     Doets-theorem source itself, not just Reynolds's restatement); `sec02` is titled
     "Well-Orderings and **Complete Orderings**."
   - `doets_1987_sec01/02/03` — Doets, *Completeness and Definability* (game-theoretic
     background; sec01 = "Completeness for Z-time," Segerberg's theorem).
   - `venema_2001_sec01-04` — Venema's Handbook survey chapter on temporal logic, including a
     dedicated "§4 Since and Until" section (spot-read: Kamp's U/S semantics, expressiveness
     discussion).
   - `venema_1993_since_sec01/02` — Venema, "Completeness via Completeness: Since and Until"
     (extends Burgess/Xu's completeness technique). `sec01`'s `provenance_fidelity` is `None`
     (unverified) and `sec02` lacks the field entirely — both need verification before citing.

   None of these four document families appear in `specs/literature-index.json` at all. A
   researcher relying solely on the `--lit` briefing (rather than raw `literature-search.sh`
   queries against the global corpus) would never learn they exist.

**FTS spot-check findings:**
- `literature-search.sh "Dedekind complete"` and `"separation"` return relevant hits, but the
  top/near-top result for both is `gabbay_1994_ch10` (parent id, `no_source_pdf` — a
  hand-authored summary, not a PDF-backed conversion) which is titled "Chapter 10: **Temporal
  Logic over the Integers**" — a different chapter than the Dedekind-complete-flows chapter
  (`gabbay_1994_ch10_sec02`/`sec05`, which *are* `verified_conversion` and in the sub-index).
  Risk: an agent searching the raw corpus rather than following the curated sub-index could
  mistake the integer-flow summary for reals/Dedekind-complete-flow content — same book,
  same-looking `gabbay_1994_ch10*` id prefix, very different topic and provenance grade.
- `literature-search.sh "strong completeness"` returns **zero relevant hits** — only unrelated
  intuitionistic-modal-logic material (Simpson, Chagrov-Zakharyaschev, Mendelson). This
  confirms the local corpus has no direct treatment of strong completeness for this logic;
  external sourcing is necessary (see below).

**`gabbay_1994` chunks flagged `[UNVERIFIED - provenance_fidelity: unverified_summary]`** in the
briefing output: `gabbay_1994_ch09_sec02` (§9.3 Separation Equals Expressive Completeness),
`gabbay_1994_ch09_sec03` (§9.4 Generalized Separation Property), `gabbay_1993_sec03` (§4
Until/Since insufficiency for gaps), `gabbay_1993_sec05` (§8 Expressive completeness with Stavi
connectives). Spot-read of the ch09 pair: content reads as plausible, well-formed theorem/proof
text, but carries no PDF backing (`provenance_fidelity: null` in the raw global index) — the
primary agent must not treat any lemma/definition from these four chunks as load-bearing without
independent verification against the source PDF, consistent with the sub-index's own hazard
notes.

## Recommended Sources vs Local Holdings

| Source | Why relevant | In local corpus? | Provenance quality | Action needed |
|---|---|---|---|---|
| Reynolds 1992, *Studia Logica* 51:165-194, §7-8 (`reynolds_1992_sec04`) | Doets-theorem machinery (Lemmas 10-13) that Theorem 7's proof invokes by name | Yes, full text | `verified_conversion` | **Add to sub-index** — currently missing despite being load-bearing |
| Burgess 1984 (Handbook chapter), §2 (`burgess_1984_sec05`) | Direct historical completeness proof for tense logic over Dedekind-complete/gap-free orders | Yes, full text | `verified_conversion` | **Add to sub-index** — currently missing, single most on-topic Burgess chunk |
| Doets 1989, "Monadic Π¹₁-Theories of Π¹₁-Properties," *Notre Dame J. Formal Logic* 30 (`doets_1989_sec01-03`) | Canonical original source for Doets' transfer theorem (countable dense model → reals) | Yes, full text | `verified_conversion` | **Add whole family to sub-index** — currently entirely unregistered |
| Doets 1987, *Completeness and Definability* (`doets_1987_sec01-03`) | Game-theoretic background (Ehrenfeucht-Fraïssé, Segerberg's Z-time completeness) | Yes, full text | `verified_conversion` | Add to sub-index if the chosen route needs the game-theoretic background |
| Venema 2001/2002 Handbook survey, "Temporal Logic" (`venema_2001_sec01-04`) | Modern authoritative survey; own "§4 Since and Until" section covering the completeness landscape | Yes, full text | `verified_conversion` | **Add to sub-index** — currently unregistered; likely the best orienting secondary source |
| Venema 1993, "Completeness via Completeness: Since and Until," in *Diamonds and Defaults* (`venema_1993_since_sec01-02`) | Alternative completeness proof technique extending Burgess/Xu | Yes, full text | `sec01` unverified (`None`), `sec02` missing the field | Add to sub-index **and** verify against source PDF before load-bearing use |
| Goldblatt, "Strong completeness of a first-order temporal logic for real time," arXiv:2310.20069 / *Rev. Symb. Logic* | Directly on strong completeness over the reals: shows the **propositional** fragment is finitely axiomatizable, but the **first-order** counterpart is not recursively axiomatizable; strong completeness is obtained only for a restricted "admissible models" semantics, not the full real-flow semantics | **No** | N/A | **Ingest** — open access on arXiv; the single most important missing external source, bears directly on whether task 408's target is achievable in the ordinary (non-restricted) sense |
| Burgess & Gurevich 1985, "The decision problem for linear temporal logic," *Notre Dame J. Formal Logic* 26(2) | Companion decidability/complexity result frequently cited alongside completeness results for this family of logics | No | N/A | Verify open-access availability (project Euclid / NDJFL archive) and ingest if obtainable; lower priority than the Goldblatt paper |
| General non-compactness ⇒ no finitary strong completeness (folklore/model-theoretic fact, reflected in the Goldblatt abstract framing) | Governs whether task 408's target is achievable at all in the standard (non-admissible-model) sense | Not a single citable local source | N/A | Not a corpus-ingestion action — the primary agent needs to reason from the Goldblatt paper's own statement of this fact (see Gaps section) rather than expect a single "impossibility theorem" citation in the local corpus |

## Gaps That Matter for Task 408

Ranked by how much each could change the primary agent's verdict:

1. **The Goldblatt arXiv paper (strong completeness for FO temporal logic over the reals) is
   not in the local corpus and is the single most decision-relevant missing source.** Its
   abstract states that propositional temporal logic over the reals is finitely axiomatizable
   but the first-order counterpart is not recursively axiomatizable, and that strong
   completeness is achieved only for a restricted "admissible models" semantics — not full
   real-flow semantics. If task 408's target is strong completeness for the *full* semantics
   (not an admissible-models restriction), this is direct evidence the target may be
   unattainable as stated, or attainable only via a semantics change analogous to Goldblatt's.
   This should be read and folded into the primary route assessment before further Lean work
   proceeds. Note: Goldblatt's result is for **first-order** temporal logic; whether an
   analogous non-recursive-axiomatizability / restricted-semantics obstruction applies to the
   **propositional** bimodal TM this project formalizes is not yet established locally — this
   is itself an open question the primary agent should address, not assume.

2. **`reynolds_1992_sec04` (the actual Doets/Separability lemmas, pp.184-188) is unregistered
   in the sub-index despite being the direct dependency of the already-registered
   `reynolds_1992_sec07`.** Any Lean/route work citing Theorem 7 without also having this chunk
   in view is citing a proof whose key lemma is invisible to the `--lit` pipeline.

3. **`burgess_1984_sec05` (Dedekind-complete-time completeness, pp.108-115) is unregistered.**
   This is Burgess's own alternative/independent completeness proof for gap-free orders and is
   a natural cross-check or alternative-route candidate; currently invisible to `--lit`.

4. **Doets 1989 (the primary source) and Doets 1987 (background) are both fully converted and
   entirely unregistered.** If the chosen route leans on Doets' theorem as anything beyond "cite
   Reynolds's restatement," the primary source itself is sitting unused in the corpus.

5. **Venema's two relevant works (2001 survey, 1993 alternative proof) are unregistered**, and
   the 1993 one additionally needs provenance verification before any load-bearing citation.

6. **Confusable near-duplicate content**: `gabbay_1994_ch10` (integers chapter, `no_source_pdf`)
   ranks high in raw FTS queries for "Dedekind complete"/"separation" alongside the correct,
   `verified_conversion` `gabbay_1994_ch10_sec02`/`sec05` (Dedekind-complete-flows chapter).
   Anyone bypassing the sub-index and querying the raw corpus directly is one careless read
   away from citing the wrong chapter under a very similar id.

## Adversarial Self-Verification

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `--lit` briefing pipeline emits a valid coverage marker and no dangling doc_ids | `bash .claude/scripts/literature-briefing.sh` output; manual cross-check of all 18 sub-index doc_ids against `~/Projects/Literature/index.json` | Ran script directly; read both index files | High |
| `reynolds_1992_sec04` (pp.184-188) contains Lemmas 10-13, Theorem 5, Theorem 6 and is `verified_conversion` but absent from the sub-index | Direct read of `/home/benjamin/Projects/Literature/sources/reynolds_1992/sec04_7-separability.md`; grep of `specs/literature-index.json` for `reynolds_1992_sec04` (not present) | Full-file read + text search of sub-index JSON | High |
| `burgess_1984_sec05` (pp.108-115, "Completeness for Discrete and Dedekind-Complete Time") is `verified_conversion` and absent from the sub-index | Direct read of `sec05_basic-tense-logic-continuity.md`; global-index metadata query; sub-index text search | Read + structured query | High |
| `doets_1987`, `doets_1989`, `venema_2001`, `venema_1993_since` families exist in the global corpus, mostly `verified_conversion`, and are entirely absent from the sub-index | Python query of `~/Projects/Literature/index.json` entries by id prefix; spot-read of `doets_1989_sec02` and `venema_2001_sec03` | Structured query + direct file reads (2 of 12 chunks spot-read; titles/page-ranges read for all 12) | High for existence/provenance fields; Medium for exact relevance of every one of the 12 chunks (only 2 read in full) |
| Local corpus has no direct "strong completeness" treatment | `literature-search.sh "strong completeness"` returned only unrelated intuitionistic-logic hits | Ran FTS query, read result JSON | High |
| Goldblatt arXiv:2310.20069 proves strong completeness only for "admissible models" over the reals, not full real-flow semantics, and that the FO counterpart is not recursively axiomatizable | WebFetch of arXiv abstract page | Single WebFetch of the abstract; full paper body not read | Medium — abstract-level claim only, not verified against the paper's full technical content |
| Doets 1989 = "Monadic Π¹₁-Theories of Π¹₁-Properties," *Notre Dame J. Formal Logic* 30 (1989) is the correct canonical citation matching the task brief's "Monadic Pi-1-1 theories of Pi-1-1 properties" | WebSearch result naming this title/venue; cross-checked against local corpus entry title "Monadic Pi11 Axiomatizations... Introduction" for `doets_1989_sec01` | WebSearch + local corpus title cross-check (titles match) | High |
| Venema 1993 = "Completeness via Completeness: Since and Until," in *Diamonds and Defaults*, Kluwer, 1993, pp.279-286 | WebSearch result; local corpus filename `completeness-via-completeness-since-and...` matches | WebSearch + local filename cross-check | Medium — venue/page numbers not independently confirmed against a second source |
| Burgess & Gurevich 1985 paper is titled "The decision problem for linear temporal logic," *Notre Dame J. Formal Logic* 26(2), not "The temporal logic of the reals" as the task brief's working title suggested | WebSearch results (multiple hits, consistent title/venue/year) | WebSearch, no full-text read | Medium — bibliographic identity confirmed by search snippets only, not by opening the paper |
| No recommendations were modified after verification; all findings above are first-draft | — | — | — |

No contradictions requiring the Contradiction Resolution Protocol were found between sources
consulted.

**Verdict for this section**: the `--lit` pipeline mechanism is sound, but the curated sub-index
is under-populated relative to what the global corpus already holds — three concrete,
already-converted, on-topic document families (Doets 1987/1989, Venema 2001/1993) plus two
specific missing chunks from already-registered papers (Reynolds §7-8, Burgess §2) are invisible
to any agent that trusts the `--lit` briefing alone. Externally, the single highest-value gap is
Goldblatt's arXiv:2310.20069, which bears directly on whether "strong completeness" as stated is
even achievable for the full (non-admissible-model) semantics.
