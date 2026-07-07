# Research Report: Editorial Review-and-Revise of BimodalReference (Task 323)

- **Task**: 323 `review_and_revise_bimodalreference_uniform_standard`
- **Date**: 2026-07-07
- **Baseline commit**: `9d85e4ec0`
- **Gates at baseline**: `typst compile Theories/Bimodal/typst/BimodalReference.typ` exits 0; `scripts/typst-sync-check.sh` PASS (all 3 checks green, 490 backtick candidates, 0 violations)

## 1. Inventory

All `.typ` files under `Theories/Bimodal/typst/` (3,880 lines total):

| File | Lines | Role / Depth assessment |
|---|---|---|
| `chapters/p5-counterfactual.typ` | 505 | **Strongest** (bar-setter) |
| `chapters/p5-constitutive.typ` | 383 | Strong |
| `chapters/03-proof-theory.typ` | 356 | **Strongest Part I** (bar-setter) |
| `BimodalReference.typ` | 254 | Main file: config, title page, abstract, part dividers, includes |
| `template.typ` | 217 | Template (no prose; out of editorial scope) |
| `chapters/05-theorems.typ` | 204 | Solid |
| `chapters/02-semantics.typ` | 169 | Mid; could deepen |
| `chapters/04-metalogic.typ` | 165 | Mid; heaviest status-prose density |
| `chapters/01-syntax.typ` | 156 | Mid |
| `chapters/06-notes.typ` | 152 | Back matter; "Discrepancy Notes" register |
| `chapters/ax-machine-appendix.typ` | 134 | Appendix wrapper (includes generated content) |
| `notation/bimodal-notation.typ` | 126 | Notation (light touch only) |
| `chapters/00-introduction.typ` | 112 | Thin-ish for a book introduction |
| `chapters/p3-vlach-blstar.typ` | 110 | Thin |
| `chapters/p2-frame-classes.typ` | 100 | Thin; heavy discrepancy-note density |
| `generated/machine-appendix.typ` | 98 | **GENERATED — never hand-edit** (Check 3) |
| `chapters/p3-ltl-to-tm.typ` | 94 | Thin; titled "Honest Positioning" |
| `chapters/p4-dataset-pipeline.typ` | 90 | Thin |
| `chapters/p3-decidability-frontier.typ` | 88 | Thin **by design** (embargo-constrained; see §3) |
| `chapters/p2-decidability-practice.typ` | 83 | Thin; opens with a documentation-dispute narrative |
| `notation/constitutive-notation.typ` | 66 | Notation |
| `notation/shared-notation.typ` | 66 | Notation (source of the one compile warning) |
| `chapters/p4-dual-verification.typ` | 62 | **Thinnest** |
| `chapters/p4-proof-automation.typ` | 61 | **Thinnest** |
| `generated/status.typ` | 29 | **GENERATED — never hand-edit** (Check 2) |

Weakest cluster = the entire Part II (p4-proof-automation 61, p4-dual-verification 62, p4-dataset-pipeline 90) plus p2-decidability-practice (83), p2-frame-classes (100), p3-ltl-to-tm (94), p3-vlach-blstar (110). Strong bar = 03-proof-theory (356) / p5-counterfactual (505). p3-decidability-frontier (88) cannot be expanded with Lk content (embargo); only published-literature survey material may grow it.

Include order (from `BimodalReference.typ:169-246`): 00-introduction; Part I: 01-syntax, 02-semantics, 03-proof-theory, p2-frame-classes, 04-metalogic, p2-decidability-practice, 05-theorems, p3-ltl-to-tm, p3-vlach-blstar, p3-decidability-frontier; Part II: p4-proof-automation, p4-dataset-pipeline, p4-dual-verification; Part III: p5-counterfactual; Part IV: p5-constitutive; back matter: 06-notes, ax-machine-appendix.

Note: the abstract at `BimodalReference.typ:139-141` labels the parts "Part I ... Part II (Applications) ... Part III ... Part IV", while the section on p3 chapters calls them "the book's closing parts"; part labels are consistent, but the introduction's roadmap (`00-introduction.typ:98-101`) should be re-checked against the final part structure during the rewrite.

## 2. Honesty / Meta-Commentary Audit

Legend: **(a)** = tone/posture rewrite into neutral expository prose; **(b)** = genuine content gap -> "TO BE CONTINUED..." body marker + `// TO BE CONTINUED:` comment.

### 2.1 "Honest/honestly/honesty" (9 hits, all category (a))

| Location | Quote | Action |
|---|---|---|
| `p3-ltl-to-tm.typ:3` (comment) + `:14` | `= From LTL to TM: Honest Positioning <sec:ltl-to-tm>` | Retitle chapter (e.g. "From LTL to TM"). Label `<sec:ltl-to-tm>` must stay (referenced from other chapters). |
| `p3-ltl-to-tm.typ:93` | "On the Lean side, honesty requires the finer statement..." | Rewrite as plain factual statement of what `ConservativeExtension/` proves. |
| `p4-dataset-pipeline.typ:15` | chapter-header description "...and the honest Tier-2 response" | Rewrite description. |
| `p4-dataset-pipeline.typ:50` | `== The Tier-1 Feasibility Gate: Honest Results` | Retitle (e.g. "The Tier-1 Feasibility Gate"). |
| `p4-dataset-pipeline.typ:70` | caption "...gate decision *FAILED*, 3 of 6 hard criteria not met -- reported honestly, not rounded up" | Keep the factual FAILED result; drop the editorial clause. |
| `p4-proof-automation.typ:15` | description "...an honest account of what is wired to what" | Rewrite description. |
| `p2-decidability-practice.typ:14` | description "...followed by an honest account of what is and is not proven about it" | Rewrite description. |
| `p2-decidability-practice.typ:54` | `== Honest Metatheory` | Retitle (e.g. "Metatheory" or "Correctness Properties"). |

### 2.2 Self-narrating production process: task numbers, phases, "earlier revision", "the plan", discrepancy registers (category (a))

These narrate the book's own drafting/verification history and must be rewritten into neutral prose (factual content preserved):

- `BimodalReference.typ:137` (abstract): "completeness is stated and wired through a canonical-model construction for each frame class, with its proof in progress and the remaining gaps stated openly" — rewrite: state what is proven; state completeness's open steps neutrally.
- `00-introduction.typ:21-22`: "It is deliberately *not* described here as ... (see @sec:notes for the full discrepancy note)"; "The accurate way to state the relationship is ... never as a description of what is formalized". Rewrite as direct positive exposition.
- `00-introduction.typ:110`: "completeness (stated and wired through a canonical-model construction; proof in progress)" — neutralize.
- `03-proof-theory.typ:217`: "TM_c ... and combined TM_dc are not yet formalized as frame classes" — neutral restatement ("are treated as paper-side extensions"; factual content must survive).
- `03-proof-theory.typ:221`: "Several schemata that were primitive axioms in earlier revisions of this system..." — this one is about the *Lean system's* history vs the paper, arguably legitimate content; recommend keeping but rephrasing away from revision-narrative.
- `04-metalogic.typ:18`: "its proof is *not yet sorry-free*: the remaining gaps are localized..." — restate as: the completeness argument has open steps in the chronicle construction (dense case) and discrete transfer. Never assert sorry-free completeness.
- `04-metalogic.typ:113-117`: heading `=== Status and Work in Progress`; "is in progress (tasks 303, 309--311) and should not be cited as a settled result" — retitle/rewrite; drop task numbers from prose.
- `04-metalogic.typ:156-160` `== Implementation Status`: "with its proof still in progress" — neutralize; consider merging into surrounding exposition.
- `04-metalogic.typ:164` footnote: "(task 93). An earlier revision of this manual described a reflexive convention; that description was stale." — drop the self-history.
- `p2-frame-classes.typ:55`: "*Discrepancy from the plan's initial source mapping*: ..." — drop the plan-reference; state the file locations directly.
- `p2-frame-classes.typ:66`: "*Caveat*: ... tracked here rather than silently repeated" — the fact (stale doc comments in Lean source) can move to a footnote or be dropped; remove editorial framing.
- `p2-frame-classes.typ:71`: "remains future work until a `Complete`-style typeclass ... are added" — neutral restatement (factual: Completeness property not formalized). |
- `p2-frame-classes.typ:92, 99`: "flagged as a discrepancy below, per the postmortem rule against unverified per-result correspondences"; "*Discrepancy note* (routed to @sec:notes's register, not silently dropped): ... needs re-verification ... has been mischaracterized in earlier documentation" — rewrite into a single neutral statement of what `lift_derivation_qfree` is and is not.
- `p2-decidability-practice.typ:19-32` `== FMP Status Resolution`: entire section narrates resolving a README-vs-earlier-chapter dispute ("Before stating any decidability-completeness claim, the discrepancy between ... is resolved here, against live source"; "*This is the sense in which the tableau FMP is 'in progress'*"). Rewrite as direct exposition: state `fmp_completeness` precisely, state the open semantic-validity bridge as an open problem. The theorem content (lines 26-31) is good and keeps.
- `p2-decidability-practice.typ:56-59` (post-retitle "Honest Metatheory" content): factual bullets are fine; keep the `validity_decidable` caveat (it prevents overclaiming) but phrase as neutral documentation.
- `p3-vlach-blstar.typ:107-110` `== The Formalization Frontier`: "Work toward a Kamp-style expressive-completeness theorem is in progress in `Metalogic/WeakCanonical/Kamp/` ... These modules are not sorry-free, and their results should not be cited as settled; ... the end-to-end theorem is the frontier." — category **(a)+(b)**: neutral statement of the open theorem + candidate TO BE CONTINUED if the section is meant to eventually present the theorem.
- `p3-decidability-frontier.typ:87`: "@sec:decidability-practice states this resolved status precisely, and that wording -- not any paraphrase -- is the book's normative account" — self-referential editorial; rewrite (body text; NOT part of the byte-preserve set, but same file as SLOT-INs — edit carefully).
- `p4-proof-automation.typ:23`: "*Discrepancy from the plan's initial source mapping*..." — drop; state locations directly.
- `p4-proof-automation.typ:27`: "a doc/implementation gap noted here rather than glossed over" — keep the fact, drop the editorializing.
- `p4-proof-automation.typ:28, 39-41`: "contrary to `Automation/README.md`'s usage example (quoted below), which is stale"; "*Discrepancy*: ..." — rewrite as direct statements of current behavior.
- `p4-proof-automation.typ:55`: "*Status note*: this module supports in-progress work ... (@sec:notes's tasks 303/309-311 pointer) ... so this chapter does not overstate the connection" — rewrite; drop task numbers and the self-defense.
- `p4-proof-automation.typ:57-61` `== A Note on Automation/README.md Staleness`: whole section is repo-documentation meta-commentary, not book content. Delete or reduce to a one-line footnote; reclaim space for real exposition of the search engine.
- `p4-dataset-pipeline.typ:31`: "*Enriched corrective signal (not yet wired)*: ... implemented and tested but not yet integrated ... targeted for Tier 2" — factual roadmap; neutral restatement, possible **(b)**.
- `p4-dataset-pipeline.typ:36`: "*Discrepancy noted, not silently repeated*: `docs/training/PIPELINE.md`'s Overview states 'six modules' but documents seven ... rather than resolving the arithmetic silently" — rewrite: just say seven modules and cite.
- `p4-dataset-pipeline.typ:80`: "Both are future work relative to this book: real code exists ... but neither ... has landed yet" — **(b)** candidate: TO BE CONTINUED marker for the Tier-2 section.
- `p4-dual-verification.typ:22, 30, 62`: "(with citation -- architectural vision, not a claim about this repository's own formalized theorems)"; "the cross-project vision above remains architectural only"; "the ModelChecker cross-verification described ... is an architectural vision, not a claim that this repository currently runs that cross-check" — say once, neutrally; the triple-repetition is apologetic. |
- `p4-dual-verification.typ:57`: "*Discrepancy, stated rather than repeated*: `Examples/README.md` describes ... but the live file only ..." — rewrite as direct description of what the file contains.
- `06-notes.typ:19`: "with its proof in progress ... with the FMP path under active development" — neutralize.
- `06-notes.typ:21` `== Discrepancy Notes`: the register itself is draft apparatus. Recommend retitling (e.g. "Relation to the Published Presentation") and rewriting entries as neutral paper-vs-formalization notes.
- `06-notes.typ:37-39`: "*Discrepancy correction (task 313 Phase 7)*: an earlier revision of this note additionally claimed ... Per-result verification against live source ... found that ..." — rewrite: state directly what `lift_derivation_qfree` is; keep the factual negative ("No Lean module currently formalizes the paper's conservativity theorem" -> neutral: "the paper's conservativity theorem is a paper-side result").
- `06-notes.typ:80`: "Ongoing work on the discrete case (... tasks 303 and 309--311) is in progress and not citable as settled" — neutralize, drop task numbers.
- `06-notes.typ:86`: "(resolved against live source, task 313 Phase 8 -- see the Part II ... chapter) ... remains open and unwired, not sorry-tainted" — neutralize; keep the mathematical openness.
- `p5-counterfactual.typ:481-482`: "states the completeness of appropriate extensions as future work; this book claims nothing stronger. The contrast with Part I is worth marking..." — keep the mathematical facts; drop the self-positioning clause ("this book claims nothing stronger"). Note :482 says "the bimodal logic of Parts I--II has a completeness theorem, formalized in Lean" — **this overstates** (completeness is not sorry-free); fix during rewrite (accuracy fix, direction opposite to overclaiming).
- `p5-counterfactual.typ:502-504` "*Formalization status.* To close where the chapter began: none of this chapter is formalized in this repository..." — rewrite once, neutrally (e.g. a short "Sources and formal status" paragraph); the facts (paper-side proofs; CL/CML/CTL completeness open everywhere) must survive.
- `p5-constitutive.typ:26-27`: "Nothing in this chapter is formalized in this repository: there is no local Lean development..." — keep the fact, state once, neutral register.

### 2.3 File-header comments (non-rendering)

Every chapter carries a header comment like `// Written task 313 Phase 9. Every module claim below was re-verified against live source...` (`p4-proof-automation.typ:5-8`, `p2-frame-classes.typ:5-6`, `p2-decidability-practice.typ:5-6`, `p3-vlach-blstar.typ:5`, `p3-ltl-to-tm.typ:5`, `p4-dataset-pipeline.typ:5`, `p4-dual-verification.typ:5-6`, `p5-constitutive.typ:5`, `p5-counterfactual.typ:5`, `01/03/04/06` "Synced against live Lean source (see ../SYNC-MAP.md), 2026-07-06"). These do not render in the PDF. Recommendation: clean them opportunistically (they are draft narration), EXCEPT the `p3-decidability-frontier.typ` header, which is byte-preserve (§3). Low priority; rendered prose is the primary directive.

### 2.4 Genuine content gaps -> TO BE CONTINUED markers (category (b))

Principle for the planner: **open mathematical problems are stated neutrally as open problems (finished books do that); TO BE CONTINUED markers are only for unwritten book content.** Candidates:

1. `p4-dataset-pipeline.typ` Tier-2 section (~:74-80): theorem-mining generator and enriched-signal wiring not landed. Either neutral "the pipeline's second tier comprises..." roadmap prose or a TBC marker.
2. `p4-dual-verification.typ`: the ModelChecker cross-verification run (never executed). If the book intends to eventually show a cross-checked example, TBC; otherwise present the architecture neutrally.
3. `p3-vlach-blstar.typ` "Formalization Frontier" section: end-to-end Kamp theorem. If the book will eventually present it, TBC; otherwise fold into a neutral open-problem statement.
4. Any section the implementer cannot expand to bar quality within the plan's budget: TBC rather than thin prose.

## 3. Preserve-Exact Inventory (`chapters/p3-decidability-frontier.typ`)

Byte-preserve items, exact current positions (file is 88 lines + trailing newline):

**EMBARGO header comment, lines 1-13** (full banner):
```
// ============================================================================
// p3-decidability-frontier.typ
// Part I chapter -- The Decidability Frontier
//
// Written at a Lk-abstracted level (no Lk-specific results until TACAS
// acceptance).
//
// EMBARGO (user decision 2, task 313): this file may NEVER cite, attribute,
// or lift Lk-specific results (BL*-ladder table, L_k complexity theorems,
// hardware case study) until the Lk paper (anonymous TACAS 2027 double-blind
// submission) is accepted. The // SLOT-IN: anchors below are the ONLY
// sanctioned insertion points for that content, reserved for task 318.
// ============================================================================
```

**Three SLOT-IN anchors**:
- Lines 57-60: `// SLOT-IN: ladder-table` + 3 continuation comment lines ("Reserved for task 318 (post-TACAS-acceptance): the BL* ladder table from Lk 07-related-work.tex (tab:bl-star-ladder). Do not populate before the embargo lifts.")
- Lines 67-71: `// SLOT-IN: complexity-map` + 4 continuation lines (includes "L1 = PTL x S5 EXPSPACE-complete; L_k undecidable for k >= 2; ... (Theorem F-B); forall-AF-L_k PSPACE-complete flagship (Theorem F-A)").
- Lines 78-81: `// SLOT-IN: case-study` + 3 continuation lines (hardware case study, constant-time as forall-forall, reset convergence, SVA/Logos-Hardware bridge, Lk 06-case-study.tex).

If body-prose edits above/below these anchors shift line numbers, that is acceptable — the constraint is byte-identical *content* of these comment blocks, not absolute line positions. Plan should instruct: never edit any line beginning `// SLOT-IN:` or inside these comment blocks, never touch lines 1-13 of this file. One rendered-prose edit IS needed in this file (line 87 self-referential clause; possibly the "Written at a Lk-abstracted level" note is inside the preserved header so untouched). Recommend a post-edit `git diff` check asserting the four comment blocks are unchanged.

## 4. Factual-Accuracy Guardrails

1. **Metaphysical modality is derived, soundness-only; completeness genuinely open.** Lives at: `p5-counterfactual.typ:19` (chapter-header: necessity derived, `nec A define top boxright A`), `:294`, `:329-331` (soundness "at characteristic-schemata strength"), `:481` ("states the completeness of appropriate extensions as future work"), `:502-504` ("completeness of *CL*, *CML*, and *CTL* is open everywhere"; counterfactual soundness proven in the paper's appendix, not Lean). Also `BimodalReference.typ:141, 222`, `00-introduction.typ:15, 100`. **Caution**: `p5-counterfactual.typ:482` currently claims Part I "has a completeness theorem, formalized in Lean" — already an overstatement to fix.
2. **Local TM completeness is NOT sorry-free.** `04-metalogic.typ:18, 115-117, 159`, `06-notes.typ:19, 86`, `BimodalReference.typ:137`, `00-introduction.typ:110`. Rewrites must never assert completed completeness; the open steps (dense chronicle coherence, discrete truth-lemma/transfer, FMP semantic-validity bridge) remain open in neutral wording.
3. **Decidability frontier cites no embargoed Lk results.** `p3-decidability-frontier.typ` body cites only published third-party results (@sistlaClarke1985, @marx1999, @hirschHodkinsonKurucz2002, @arecesBlackburnMarx2001, @franceschetEtAl2003, @demriLazic2009, @finkbeiner2015/2016/2017, @goranko1996, ...). Line 55: "That is an expectation, not a theorem -- no result about the tower is stated or attributed here" — this sentence is load-bearing for the embargo; keep its content (may be lightly rephrased but must keep the no-attribution meaning).
4. **Countermodels: only #1, #8, #9 of 1-12 fully interpreted.** `p5-counterfactual.typ:353`: "The paper presents fully interpreted countermodels for #1, #8, and #9, and disposes of #11 and #12 by argument; the remaining schemata are recorded as invalid without worked models". Must survive rewrites intact in meaning.
5. **`validity_decidable` is a classical tautology, not constructive decidability** (`p2-decidability-practice.typ:57`); `fmp_completeness` is a finite-filtration statement with the semantic bridge open (`:24-31, 58`). Keep both caveats (neutrally phrased).
6. **No nonexistent local Lean theorems.** Every backticked token must resolve (sync Check 1). External Logos names and paper labels are whitelisted/cited-as-external only (`sync-check-whitelist.txt`, `p5-constitutive.typ:21, 26-27`).
7. **`generated/status.typ` and `generated/machine-appendix.{typ,jsonl}` are never hand-edited** (Checks 2-3 enforce byte agreement with regeneration). Count references in prose use `#axiom-count` etc. imported from status.typ — do not replace with literal digits.
8. **The paper's TM_c/TM_dc (order-completeness) frame classes are not formalized** (`p2-frame-classes.typ:71-72`, `03-proof-theory.typ:217`) and the paper's L-vs-L+ conservativity theorem has no Lean formalization (`06-notes.typ:39`, `p2-frame-classes.typ:99`) — facts to preserve in neutral form.

## 5. Acceptance-Gate Mechanics

### 5.1 `typst compile` (baseline: exit 0)

`typst compile Theories/Bimodal/typst/BimodalReference.typ` exits 0 today. One pre-existing non-fatal warning at `notation/shared-notation.typ:44` (the `#let tuple(..args)` definition); not required to fix, must not become an error.

### 5.2 `scripts/typst-sync-check.sh` (baseline: PASS, 490 candidates, 0 violations)

Three checks (script is 337 lines; former banner/legend checks retired in task 319 — the compiled book carries no sync-class markings):

1. **Check 1 — backtick name resolution**: extracts every `` `...` `` span from `typst/**/*.typ` (excluding `generated/`). Resolution order: whitelist exact match (`Theories/Bimodal/typst/sync-check-whitelist.txt`, 69 lines: type-signature illustrations, template API names, external paper filenames/labels, JSONL field illustrations) -> multi-word spans must literal-grep in Lean source (excl. `Boneyard/`) -> path-like candidates (containing `/` or `.lean/.md/.sh/.typ` suffix, optional `:123` line suffix stripped) must exist under `Theories/Bimodal/` or repo root (suffix search allowed) -> bare identifiers must grep in `*.lean` under `Theories/Bimodal/` excl. Boneyard.
   **Editing implications**: (i) deleting backticked tokens is always safe; (ii) any NEW backticked token must resolve or be whitelisted; (iii) `#raw(...)` spans are NOT extracted (regex targets backticks only); (iv) code blocks with triple backticks — the regex `` `([^`\n]+)` `` operates per line, so fenced code lines can produce candidates; the current corpus passes, so preserve existing fenced blocks verbatim where possible.
2. **Check 2 — count freshness**: committed `generated/status.typ` `#let` scalar counts (axiom-count, rule-count, base/dense/discrete counts, sorry totals) and the sorry-table tuples must match a live regeneration via `scripts/typst-status-counts.sh --json` (stamp fields excluded). Editorial work must not touch this file.
3. **Check 3 — machine-appendix freshness**: committed `generated/machine-appendix.jsonl` counts must match live awk scans of `ProofSystem/Axioms.lean` / `ProofSystem/Derivation.lean`, and `machine-appendix.typ` must byte-match a re-render (`typst-machine-appendix.sh --render-only`). Do not touch either file. `chapters/ax-machine-appendix.typ` (the wrapper prose) is editable, but its backticked names must keep resolving.

**Caution on Lean-side drift**: Checks 2/3 compare against *live Lean source*, so if unrelated Lean work (e.g. task 321) changes sorry counts between now and implementation, the check may fail for reasons outside this task. The plan's verification steps should re-run the sync check at phase start to distinguish inherited drift from self-inflicted breakage (inherited drift is fixed by `scripts/typst-status-counts.sh` / `typst-machine-appendix.sh` regeneration, which is sanctioned).

## 6. Recommended Phase Breakdown

Ordering principle: establish the new tone contract on front matter first (it defines the book's voice), then sweep chapters in include order grouped by risk; run both gates after every phase; finish with a mechanical banned-pattern re-audit.

- **Phase 1 — Voice contract + front matter (low risk)**: `BimodalReference.typ` (abstract line 137, part-divider texts), `00-introduction.typ` (lines 21-22, 110; modest expansion toward a proper book introduction). Deliverable includes a written style contract for later phases: banned patterns (honest/honestly, "in progress", task numbers, "earlier revision", "discrepancy", "stated openly/plainly", "not silently", self-referential normativity claims) + the neutral-open-problem idiom + the TBC-marker convention.
- **Phase 2 — Part I core tone pass (medium)**: `01-syntax`, `02-semantics`, `03-proof-theory` (line 217, 221), `04-metalogic` (heaviest: lines 18, 113-117, 156-160, 164), `05-theorems`, `06-notes` (retitle "Discrepancy Notes", rewrite 19, 37-39, 80, 86). Mostly rewrites, little expansion.
- **Phase 3 — Part I thin chapters: rewrite + expand (high effort)**: `p2-frame-classes` (100 -> ~180+), `p2-decidability-practice` (83 -> ~180+; dissolve "FMP Status Resolution" narrative into direct exposition), `p3-ltl-to-tm` (retitle; 94 -> ~150+), `p3-vlach-blstar` (110 -> ~160+; resolve Formalization Frontier section). Expansion sources: the underlying Lean modules and the two papers, already cited in-text.
- **Phase 4 — p3-decidability-frontier surgical pass (highest care, small diff)**: rewrite line 87's self-referential clause and any tone spots; byte-preserve lines 1-13 and the three SLOT-IN blocks (57-60, 67-71, 78-81); verify with `git diff` that all four comment blocks are unchanged; optional modest expansion using published literature only.
- **Phase 5 — Part II expansion (highest effort)**: `p4-proof-automation` (61 -> ~180+; delete README-staleness section, expand the search-engine and tactic exposition), `p4-dataset-pipeline` (90 -> ~160+; Tier-2 TBC decision), `p4-dual-verification` (62 -> ~160+; consolidate the triple "architectural vision" disclaimer, add worked examples from `Examples/`).
- **Phase 6 — Parts III-IV light pass**: `p5-counterfactual` (fix the line-482 overclaim; neutralize 481, 502-504; retain countermodel guardrail at 353), `p5-constitutive` (lines 26-27), notation files (comment hygiene only).
- **Phase 7 — Gates + adversarial re-audit**: `typst compile` exit 0; `scripts/typst-sync-check.sh` PASS; grep re-audit for the banned-pattern list (expect 0 hits in rendered prose outside preserved blocks); confirm every TBC body marker has a matching `// TO BE CONTINUED:` comment; spot-check PDF output for the retitled headings and references.

Per-phase verification: both gates + `grep -rniE 'honest|in progress|task 3[0-9][0-9]|earlier revision|discrepanc'` scoped to the phase's files.

## Key file paths

- Corpus: `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/typst/`
- Gate script: `/home/benjamin/Projects/BimodalLogic/scripts/typst-sync-check.sh`
- Whitelist: `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/typst/sync-check-whitelist.txt`
- Historical claim map: `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/typst/SYNC-MAP.md` (development document; does not govern the PDF)
- Byte-preserve file: `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/typst/chapters/p3-decidability-frontier.typ` (lines 1-13, 57-60, 67-71, 78-81)
