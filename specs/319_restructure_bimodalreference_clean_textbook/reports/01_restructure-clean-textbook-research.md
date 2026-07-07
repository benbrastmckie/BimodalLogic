# Research Report: Restructure BimodalReference as Clean Textbook (Task 319)

**Date**: 2026-07-06
**Session**: sess_1783407088_0a61d1
**Task Type**: typst
**Status**: Research complete

## Summary

The BimodalReference book (`Theories/Bimodal/typst/`) is currently a five-part
"living monograph" with sync-class scaffolding installed by task 313. This report maps
every removal target (workstream 1), verifies the citation metadata for all three papers
against Crossref (workstream 2), catalogs the current include order and chapter inventory
for the restructure (workstream 3), and records the current state of follow-up tasks
314-318 (workstream 4). Baseline verification: `typst compile` is green today
(typst 0.14.2, two benign font warnings from thmbox), and `bibliography.bib` has 11
entries with **zero** `@`-citations wired into any `.typ` file (all `@sec:` references
are internal cross-refs, not bib citations), so References currently renders empty.

Notable discovery: **tasks 314-318 already list 319 in their `dependencies` arrays** in
`specs/state.json` — workstream 4 needs only description rewrites + `generate-todo.sh`,
not dependency edits.

## 1. File Inventory

All paths relative to `/home/benjamin/Projects/BimodalLogic/` unless noted.

```
Theories/Bimodal/typst/
├── BimodalReference.typ        299 lines  main file (title, abstract, legend, includes, bibliography)
├── template.typ                294 lines  theorem envs + sync-banner + part-divider + planned-chapter-notice
├── bibliography.bib             96 lines  11 entries, 0 citations wired
├── SYNC-MAP.md                 350 lines  sync-class contract (PDF-governing role to be retired)
├── sync-check-whitelist.txt               whitelist for sync-check Check 1
├── README.md                              build instructions + sync-class documentation (needs updating too)
├── notation/  (shared-notation.typ, bimodal-notation.typ)
├── generated/status.typ         29 lines  GENERATED counts (axiom/rule/sorry), stamp c44216042 2026-07-07
├── build/                                 output dir
└── chapters/  (19 .typ files, listed below)
scripts/typst-sync-check.sh     290 lines  4 checks (detail in section 5)
scripts/typst-status-counts.sh             generator for generated/status.typ (--json mode feeds check 4)
.claude/scripts/generate-todo.sh           TODO.md regeneration (workstream 4)
```

### Chapter inventory (with line counts and disposition)

| File | Lines | Current Part | Disposition per task description |
|------|-------|--------------|----------------------------------|
| `00-introduction.typ` | 171 | I | **REWRITE** — brief direct motivation; drop AI-practitioner-first framing, AI-reader protocol, book map with sync-classes |
| `p1-why-worlds.typ` | 27 | I | **DROP** (stub only; salvage topics into intro/citations) |
| `01-syntax.typ` | 157 | II | KEEP (remove banner :14) |
| `02-semantics.typ` | 165 | II | KEEP (remove banner :10) |
| `03-proof-theory.typ` | 357 | II | KEEP (remove banner :15; wire citations) |
| `p2-frame-classes.typ` | 101 | II | KEEP (remove banner :21 + inline symbols) |
| `04-metalogic.typ` | 233 | II | KEEP (remove banner :15, sorry inventory :157-199, status table symbols) |
| `p2-decidability-practice.typ` | 85 | II | KEEP (remove banner :18, Roadmap column of Closing Status Table :67-85) |
| `05-theorems.typ` | 205 | II | KEEP (remove banner :10; no inline symbols found) |
| `p3-ltl-to-tm.typ` | 26 | III | stub — **fold into bimodal Part** as real chapter (task 315 writes it) |
| `p3-vlach-blstar.typ` | 24 | III | stub — **fold into bimodal Part** as real chapter (task 315 writes it) |
| `p3-decidability-frontier.typ` | 47 | III | stub — keep concise, **PRESERVE `// SLOT-IN:` anchors** (:33, :38, :44) |
| `p3-open-future.typ` | 21 | III | **DROP** (stub only; salvage Determined/Deterministic + actuality topics) |
| `p4-proof-automation.typ` | 62 | IV | KEEP (remove banner :19, ⧖ status note :56) |
| `p4-dataset-pipeline.typ` | 85 | IV | KEEP (remove banner :19, ◇ marks :32, :81) |
| `p4-dual-verification.typ` | 63 | IV | KEEP (remove banner :18, ○/✓ marks :23, :28, :31) |
| `p5-constitutive.typ` | 25 | V | stub — becomes **final** Part (order inverted) |
| `p5-counterfactual.typ` | 31 | V | stub — becomes **second-to-last** Part (order inverted) |
| `06-notes.typ` | 173 | back matter | KEEP (remove banner :14, sorry-count prose :99, status table tweaks) |

Note: the dropped chapters `p1-why-worlds.typ` and `p3-open-future.typ` are *stubs*
(27/21 lines, notice-box only) — no prose is lost by deleting them. Their planned
technical content (perpetuity principles as touchstone, Determined/Deterministic
`app:deterministic`, actuality operators) must be surfaced with citations where formally
relevant (perpetuity is already covered ✓ in `05-theorems.typ` P1-P6).

## 2. Workstream 1 — Removal targets (file:line)

### 2.1 `#sync-banner(...)` call sites (16 chapters + definition)

| File | Line |
|------|------|
| `chapters/00-introduction.typ` | 17 |
| `chapters/01-syntax.typ` | 14 |
| `chapters/02-semantics.typ` | 10 |
| `chapters/03-proof-theory.typ` | 15 |
| `chapters/p2-frame-classes.typ` | 21 |
| `chapters/04-metalogic.typ` | 15 |
| `chapters/p2-decidability-practice.typ` | 18 |
| `chapters/05-theorems.typ` | 10 |
| `chapters/p3-ltl-to-tm.typ` | 13 |
| `chapters/p3-vlach-blstar.typ` | 13 |
| `chapters/p3-decidability-frontier.typ` | 21 |
| `chapters/p3-open-future.typ` | 13 |
| `chapters/p4-proof-automation.typ` | 19 |
| `chapters/p4-dataset-pipeline.typ` | 19 |
| `chapters/p4-dual-verification.typ` | 18 |
| `chapters/p5-constitutive.typ` | 13 |
| `chapters/p5-counterfactual.typ` | 13 |
| `chapters/06-notes.typ` | 14 |

Definition: `template.typ:261-294` (`#let sync-banner`), with explanatory comment block
`template.typ:195-202` (approx; "sync-class banner" comment). The import in
`BimodalReference.typ:18` re-exports `sync-banner, part-divider` and must be trimmed.

### 2.2 Main-file front matter (`BimodalReference.typ`)

- **Title-page Sources list**: lines 111-118 — item 3 (line 117) mentions
  "ground truth for every ✓/⧖-marked claim". Sources list itself can stay but symbol
  mention must go; note item 2 (line 116, Counterfactual Worlds) has no link — add the
  Springer URL/DOI here or replace the list with bibliography citations.
- **Abstract**: lines 134-141 — the whole abstract is written in living-monograph voice
  ("living, five-part monograph", "styled stubs naming their follow-up task", line 141's
  sync-class sentence). Needs rewriting as direct textbook abstract, not just symbol
  deletion.
- **Reading-Guide/Sync-Class Legend box**: lines 145-161 (the `#block(...)` with
  "Reading Guide -- Sync-Class Legend") — delete entirely.

### 2.3 `#part-divider` dominant-class labels

Definition `template.typ:236-253` takes a `dominant-class` positional arg rendered at
`:244`. Five call sites in `BimodalReference.typ`, each passing a class string:

| Lines | Part | dominant-class string to remove |
|-------|------|-------------------------------|
| 192-203 | I | `"outlook -- planned (follow-up task 314)"` |
| 210-222 | II | `"lean-verified (✓ core, ⧖ completeness)"` |
| 234-245 | III | `"outlook -- planned (follow-up task 315; Lk-embargoed)"` |
| 254-265 | IV | `"lean-verified (✓) -- the primary audience's entry point"` |
| 273-284 | V | `"outlook -- planned (follow-up task 317)"` |

The scope-paragraph bodies also mention sync classes/stubs and need rewording during
restructure. Simplest change: drop the `dominant-class` parameter from `part-divider`'s
signature and all call sites.

### 2.4 'How to Read This Book If You Are an AI' protocol

`chapters/00-introduction.typ:151-160` (heading `== How to Read...` at :151; six-item
protocol :155-160). Item :159 is the **anchor that task 316 points its JSONL appendix
at** — workstream 4 must pick a replacement anchor (suggestion: an appendix pointer
sentence in the applications Part or `06-notes.typ`). Additional sync-class content in
the intro beyond :151-160: banner :17, roadmap-symbol prose :31, grid ◇ cells
:124-138 (figure content — ◇ cell labels), Book Map with per-part sync classes
:141-149. The intro rewrite (workstream 3) supersedes line-level excision here.

### 2.5 Status tables

- **Closing Status Table with Roadmap column**: `chapters/p2-decidability-practice.typ:67-85`
  (figure at :69-85; header row :75 has the `[*Roadmap*]` column; ✓/⧖/◇ symbols in rows
  :77-81). Task says remove the table's Roadmap column and status symbols (or the table).
  Also symbol prose at :33, :58, :60.
- **`04-metalogic.typ` status tables**: Sorry Inventory section `:157-199`
  (`<sec:sorry-status>` label at :157; sorry-count prose :161-162; sorry table
  :164-192 driven by `sorry-table` import :11) — reader-facing sorry reporting must go.
  Component Status table `:205-228` + Status Key `:230-233` — symbol-free but uses
  "Stated, in progress" language; can be kept/toned as plain prose per plan. NOTE:
  `@sec:sorry-status` is referenced from `04-metalogic.typ:15,19,91` and
  `00-introduction.typ:107` — all refs must be fixed when the section is removed.
- **`06-notes.typ` status table**: `:20-41` (uses `#sorry-total` at :34); sorry-count
  prose at `:99` (uses `sorry-total`, `stamp-commit`, `stamp-date`); import at `:10`.

### 2.6 `#planned-chapter-notice` stub boxes

Definition `template.typ:212-226` (+ comment block :204-210). Seven call sites:

| File | Line | Task named |
|------|------|-----------|
| `chapters/p1-why-worlds.typ` | 15 | 314 |
| `chapters/p3-ltl-to-tm.typ` | 15 | 315 |
| `chapters/p3-vlach-blstar.typ` | 15 | 315 |
| `chapters/p3-decidability-frontier.typ` | 23 | 315 |
| `chapters/p3-open-future.typ` | 15 | 315 |
| `chapters/p5-constitutive.typ` | 15 | 317 |
| `chapters/p5-counterfactual.typ` | 15 | 317 |

Per task: drop the stub includes or replace each with a single plain sentence. The
p1/p3-open-future stubs are dropped with their files; the other five remain as includes
(they are written by tasks 315/317) so each needs a one-sentence placeholder.

### 2.7 Inline sync symbols in keeper chapters (44 total occurrences)

Beyond banners, these lines carry ✓/⧖/○/◇ inline: `p2-frame-classes.typ:21,67,71,72,89,100`;
`p2-decidability-practice.typ:18,33,58,60,77-81`; `p4-dual-verification.typ:18,23,28,31,63`;
`p4-dataset-pipeline.typ:19,32,81`; `p4-proof-automation.typ:56`; `06-notes.typ:60`;
`00-introduction.typ` (18 occurrences, superseded by rewrite); `p3-ltl-to-tm.typ:23`.
`05-theorems.typ`, `01-syntax.typ`, `02-semantics.typ`, `03-proof-theory.typ`,
`04-metalogic.typ` prose: symbol-free apart from banners (metalogic uses words not
symbols). These should be rewritten as plain prose ("proven sorry-free" → "proven", or
neutral wording), keeping honest open/closed statements without the symbol system.

### 2.8 Generated counts

`generated/status.typ` defines `axiom-count 42, rule-count 7, base-count 37,
dense-only-count 2, discrete-only-count 3, sorry-total 43, sorry-total-excl-boneyard 41,
sorry-table` (stamp c44216042, 2026-07-07). Import/usage sites:

- `00-introduction.typ:12` (axiom-count :166, rule-count :166) — KEEP counts OK
- `03-proof-theory.typ:11` (axiom-count :17,:23; rule-count :17,:246; base/dense/discrete :211) — KEEP
- `p2-frame-classes.typ:12` (:48 discrete-only-count etc.) — KEEP
- `04-metalogic.typ:11` (imports **sorry-total, sorry-total-excl-boneyard, sorry-table**, axiom-count, stamps; sorry uses :161-162,:164-192; axiom-count :36) — REMOVE sorry-facing uses
- `06-notes.typ:10` (imports **sorry-total**, stamps; uses :31,:34,:64,:99) — REMOVE sorry-facing uses

Decision point for the planner: keep axiom/rule/frame-class counts (script-generated,
harmless) and strip all `sorry-*` imports/usages from reader-facing text. The
`sorry-*` bindings can stay in `generated/status.typ` (it's generated; check 4 compares
all fields) or the generator can be left untouched — simplest is to leave the generator
and generated file alone and only remove *usages*.

### 2.9 SYNC-MAP.md

Header (lines 1-40 read) declares the PDF-governing enforcement contract with legend and
4 mechanical rules. Workstream 1: update its header to state it is a repo-side dev doc
(claim-verification history), no longer governing the compiled PDF. Also update
`Theories/Bimodal/typst/README.md`, which documents the sync-class legend, the five-part
table with sync-class column, and stubs (lines ~28-46) — it will be stale after the
restructure (not named in the task description but flagged here as required collateral).

## 3. Workstream 2 — Citations

### 3.1 Verified metadata (Crossref, 2026-07-06)

Direct Springer fetch 303-redirects to `idp.springer.com` (bot wall); Crossref API used
instead — authoritative for DOI metadata.

1. **Counterfactual Worlds**, Benjamin Brast-McKie, *Journal of Philosophical Logic*
   **54**(3): 533-574, 2025. DOI `10.1007/s10992-025-09793-8`. Published online
   2025-06-03. URL https://link.springer.com/article/10.1007/s10992-025-09793-8
2. **Identity and Aboutness**, Benjamin Brast-McKie, *Journal of Philosophical Logic*
   **50**(6): 1471-1503, 2021. DOI `10.1007/s10992-021-09612-w`. Published online
   2021-10-25. URL https://link.springer.com/article/10.1007/s10992-021-09612-w
3. **The Construction of Possible Worlds**, Benjamin Brast-McKie, forthcoming, *Journal
   of Philosophical Logic* (2026). Draft URL verified live (HTTP 200, application/pdf,
   788,800 bytes): https://benbrastmckie.com/wp-content/uploads/2026/07/possible_worlds.pdf

### 3.2 bibliography.bib current state (`Theories/Bimodal/typst/bibliography.bib`)

- `brastmckie2026possibleworlds` (:13-19) — exists; **lacks URL and note about
  forthcoming status**; add `url = {...possible_worlds.pdf}`, `note = {Forthcoming}`.
- `brastmckie2025counterfactualworlds` (:21-27) — exists; **lacks volume/issue/pages/DOI/URL**; complete per 3.1.
- **No Identity and Aboutness entry** — must be added (key suggestion:
  `brastmckie2021identity`), relevant to the constitutive-logic Part (Fine-style
  ground/essence; p5-constitutive).
- Embargo header :8-10 — keep unchanged (no Lk entry).
- Third-party entries all carry `note = {verify before print}`: `burgess1982axioms`
  (:29-35, typed `@book` but is a journal article — Notre Dame J. Formal Logic 23(4):367-374,
  1982, listed as publisher not journal: fix), `xu1988until` (:37-42), `vlach1973nowandthen`
  (:44-50, typed `@article` with `school = {UCLA}` — should be `@phdthesis`),
  `kamp1971formalproperties` (:52-58, Theoria 37(3):227-273), `cresswell1990entities`
  (:60-66), `blackburn2000hybrid` (:68-73), `gabbay2003manyvalued` (:75-81),
  `demrigorankolange2016` (:83-88, actually a 2016 Cambridge University Press *book*:
  "Temporal Logics in Computer Science: Finite-State Systems" — title in bib is wrong;
  verify at implementation), `baierkatoen2008` (:90-96). Missing but cited in prose:
  **Reynolds 1992** (`03-proof-theory.typ:181`), **Doets 1987** (:181), **Burgess 1984**
  ("Burgess (1982/84)" at :72 — Basic Tense Logic, Handbook of Philosophical Logic 1984),
  Goldblatt / van Benthem / Blackburn-de Rijke-Venema (`06-notes.typ:136,144` — BdRV
  *Modal Logic*, CUP 2001), GHR93 Gabbay-Hodkinson-Reynolds (`p4-proof-automation.typ:55`).
- Typst bibliography is wired at `BimodalReference.typ:297-299` (`style: "ieee"`); Typst
  only renders **cited** entries by default, hence the empty References today.

### 3.3 Plain-text author-year mentions to convert (file:line)

| Mention | Locations |
|---------|-----------|
| Vlach 1973 | `p3-vlach-blstar.typ:13,18` (stub text; real conversion lands with task 315 chapter; the placeholder sentence can carry `@vlach1973nowandthen`) |
| Cresswell 1990 | `p3-vlach-blstar.typ:13,18` |
| Blackburn 2000 | `p3-vlach-blstar.typ:13,18` |
| Burgess (1982/84) | `03-proof-theory.typ:72,107,117,202`; `04-metalogic.typ:104,111`; `01-syntax.typ:26,105`; `p2-frame-classes.typ:78` (convention mentions); `06-notes.typ:144` |
| Xu (1988) | `03-proof-theory.typ:72`; `06-notes.typ:144` |
| Reynolds 1992 | `03-proof-theory.typ:181` |
| Doets 1987 | `03-proof-theory.typ:181` |
| Kamp | `06-notes.typ:101`; `04-metalogic.typ:117,118,143,179`; `p4-proof-automation.typ:55-56`; `p3-vlach-blstar.typ:19` |
| Blackburn-de Rijke-Venema | `06-notes.typ:136,144` |
| Reynolds/Doets pipeline | `04-metalogic.typ:105,143` |
| Prior (tradition) | `06-notes.typ:142-144`; `03-proof-theory.typ:161-181` (axiom names, not citations) |

The three Brast-McKie papers should be cited at minimum: possible-worlds in the intro +
semantics/proof-theory chapters + `06-notes.typ` discrepancy register (:56-64 mention
"the paper" throughout); Counterfactual Worlds in Part-divider/placeholder for the
counterfactual Part and `p5-*.typ` placeholders; Identity and Aboutness in the
constitutive placeholder.

## 4. Workstream 3 — Restructure

### 4.1 Current include order (`BimodalReference.typ:190-291`)

```
Part I   (:192-203 divider)  00-introduction (:205), p1-why-worlds (:206)
Part II  (:210-222 divider)  01-syntax (:224), 02-semantics (:225), 03-proof-theory (:226),
                             p2-frame-classes (:227), 04-metalogic (:228),
                             p2-decidability-practice (:229), 05-theorems (:230)
Part III (:234-245 divider)  p3-ltl-to-tm (:247), p3-vlach-blstar (:248),
                             p3-decidability-frontier (:249), p3-open-future (:250)
Part IV  (:254-265 divider)  p4-proof-automation (:267), p4-dataset-pipeline (:268),
                             p4-dual-verification (:269)
Part V   (:273-284 divider)  p5-constitutive (:286), p5-counterfactual (:287)  ← constitutive FIRST currently
Back     06-notes (:291), References (:297-299)
```

### 4.2 Target structure (from task description)

```
Front    00-introduction (rewritten: brief, direct; motivation = unifying tense+modality
         in a verified system; outline: bimodal system → applications → counterfactual → constitutive)
Part I   The Bimodal System:
         01-syntax, 02-semantics, 03-proof-theory, p2-frame-classes, 04-metalogic,
         p2-decidability-practice, 05-theorems,
         + p3-ltl-to-tm (honest LTL-to-TM positioning, folded in as direct formal chapter)
         + p3-vlach-blstar (folded in)
         + p3-decidability-frontier (concise formal chapter, SLOT-IN anchors PRESERVED)
Part II  Applications: p4-proof-automation, p4-dataset-pipeline, p4-dual-verification
         (AI-training motivation kept brief)
Part III Counterfactual Logic: p5-counterfactual   ← INVERTED
Part IV  Constitutive Logic: p5-constitutive        ← now concluding Part
Back     06-notes, References
DROPPED  p1-why-worlds.typ, p3-open-future.typ (delete includes + files)
```

Open placement question for the planner: whether the three folded p3 chapters sit after
05-theorems inside the bimodal Part or as a titled subdivision; task says "folded in as
direct formal chapters" of the bimodal Part. Part numbering/naming ("Part on the bimodal
system", etc.) is the planner's to fix; part-divider scope paragraphs must be rewritten
without sync-class/stub/task-number language.

### 4.3 SLOT-IN anchors (confirmed, must survive verbatim)

`chapters/p3-decidability-frontier.typ`:
- `:33` `// SLOT-IN: ladder-table`
- `:38` `// SLOT-IN: complexity-map`
- `:44` `// SLOT-IN: case-study`

Plus the EMBARGO header comment `:10-15`. Task 318 inserts at exactly these anchors;
any rewrite of this file must keep all three comment anchors and the embargo note.

### 4.4 Salvageable content from dropped chapters

Both dropped files are notice-box stubs; the content to "present where formally
relevant" already exists elsewhere or arrives via revised task 315:
- Perpetuity principles: formally in `05-theorems.typ` (P1-P6, `Theorems/Perpetuity/`) —
  add a citing sentence to `@brastmckie2026possibleworlds` there.
- Determined/Deterministic (`app:deterministic`), actuality operators: no formal Lean
  counterpart; belongs as short cited remarks in the semantics or frame-classes chapter
  (planner decision), sourced to possible_worlds.tex :1291-1541.
- Eternalism/Prior/Montague/Kaplan puzzle material: dropped entirely per task; a single
  citing sentence in the intro suffices.

### 4.5 00-introduction.typ rewrite notes

Current 171 lines: practitioner thesis (:19-24), What TM Actually Is (:26-32, keeper
content — accurate TM description), worldline cetz figure (:34-101, keeper candidate,
symbol-free except caption's outlook sentence :94), unification grid (:104-139, contains
◇ symbols and Part-number references — either purge symbols/Part refs or drop), Book Map
(:141-149, replace with new four-part outline), AI-reader protocol (:151-160, remove),
Project Structure (:162-171, keeper, uses axiom-count/rule-count). The `#import
"../generated/status.typ"` (:12) and cetz import (:13) survive per what's kept. The grid
references `extension-node` (template) at :128-129.

## 5. Workstream 1 — scripts/typst-sync-check.sh changes

Current structure (290 lines):
- **Check 1** (:34-158): backtick name resolution via embedded python — KEEP. Note the
  whitelist `sync-check-whitelist.txt` includes "Planned files for follow-up tasks" and
  typst API names (`sync-banner` etc. likely present) — prune stale entries after removal.
- **Check 2** (:160-184): banner presence per included chapter — REMOVE.
- **Check 3** (:186-206): legend discipline (no check-banner in paper/outlook files) — REMOVE.
- **Check 4** (:208-278): count freshness, compares `generated/status.typ` against
  `scripts/typst-status-counts.sh --json` — KEEP if counts kept (recommended). It
  compares axiom/rule/frame-class counts **and sorry fields**; if sorry bindings stay in
  the generated file (recommended, since it is generated), check 4 needs no change.
- Header comment (:2-21) and summary line (:287 "all 4 checks green") must be updated.

Run command: `scripts/typst-sync-check.sh` from repo root (no args). Verified present;
whitelist at `Theories/Bimodal/typst/sync-check-whitelist.txt`.

Build baseline: `cd Theories/Bimodal/typst && typst compile BimodalReference.typ
build/BimodalReference.pdf` — verified green on typst 0.14.2 (only two "new computer
modern sans" font warnings from thmbox, pre-existing).

## 6. Workstream 4 — Follow-up tasks 314-318 (current state.json)

All five are `status: not_started` and **already have `dependencies: [313, 319]`** —
only descriptions and TODO.md regeneration remain. Current descriptions (summarized;
full text in `specs/state.json`):

- **314** `write_bimodalreference_part_i_motivation_chapter_w` — writes
  `p1-why-worlds.typ` from possible_worlds.tex §1-2 with sync-class banner constraints.
  Under 319 the chapter is dropped → 314 must **shrink to whatever brief motivation the
  rewritten introduction still needs, or be abandoned/absorbed — decide and record**
  (the decision itself is deferred to 319's implementation; the planner should propose
  one: given the intro rewrite happens *inside* 319, abandoning 314 with a
  completion/abandonment note is the natural reading).
- **315** — writes the four Part III chapters incl. `p3-open-future.typ` and
  paper-sourced/outlook banners. Revise: three chapters only (ltl-to-tm, vlach-blstar,
  decidability-frontier) now folded into the bimodal Part; drop open-future puzzle
  chapter (technical content resurfaces as cited remarks); drop all banner/legend
  constraints; keep backtick-resolution constraint; keep the Lk embargo + SLOT-IN
  preservation language.
- **316** (lean4) — JSONL appendix; description says "Wire the 'How to Read This Book If
  You Are an AI' introduction section ... to point at the shipped artifact" — re-anchor
  the pointer (replacement location to be decided: e.g. dataset-pipeline chapter or a
  back-matter appendix note). "sync-check green" wording stays valid (checks 1+4).
- **317** — currently orders constitutive **then** counterfactual ("(1)
  p5-constitutive.typ ... (2) p5-counterfactual.typ") and imposes paper-sourced/planned
  sync-class constraints. Revise to counterfactual-then-constitutive book order and drop
  banner constraints (content staging inside the task may keep any internal order, but
  the book order is counterfactual first).
- **318** — unchanged except removing "banner"/publication-status-marker constraints
  ("Mark all results with their publication status" sentence retained or reworded —
  planner call; SLOT-IN anchors preserved by workstream 3).

Procedure: edit `specs/state.json` descriptions, then
`bash .claude/scripts/generate-todo.sh`.

## 7. Verification plan (for the implementer)

1. `cd Theories/Bimodal/typst && typst compile BimodalReference.typ build/BimodalReference.pdf` — green.
2. `bash scripts/typst-sync-check.sh` — green with revised 2-check structure.
3. References section non-empty with (at least) the three Brast-McKie papers — grep the
   compiled PDF or confirm `@brastmckie...` citations present in `.typ` sources
   (Typst renders only cited entries; `#cite` or `@key` forms both work).
4. `grep -rn "sync-banner\|planned-chapter-notice\|Sync-Class" chapters/ BimodalReference.typ` — empty
   (template may retain dead definitions only if deliberately kept; cleaner to delete).
5. `// SLOT-IN:` count in `p3-decidability-frontier.typ` == 3.
6. `jq` state.json validity + `generate-todo.sh` regeneration diff.

## 8. Risks / notes for the planner

- **Cross-reference breakage**: removing `<sec:sorry-status>` (04-metalogic:157) breaks
  `@sec:sorry-status` refs at `04-metalogic.typ:15,19,91` and `00-introduction.typ:107`;
  banner removals kill :15's ref automatically, but :19,:91 footnote refs need rewording.
  Similarly `@sec:fmp-resolution`, `@sec:decidability-practice`, `@sec:notes` refs must
  survive chapter reordering (labels move with files — reordering includes is safe).
- **Whitelist drift**: `sync-check-whitelist.txt` whitelists template API names and
  "planned files"; after removals some entries become stale — check 1 doesn't fail on
  stale whitelist entries (they're just unused), so cleanup is optional hygiene.
- **`06-notes.typ` voice**: it refers to "the paper" throughout (:56-64, :99-118 region)
  — the natural place to convert to `@brastmckie2026possibleworlds` citations.
- **README.md + SYNC-MAP.md**: both document the living-monograph design; both need
  header/section updates (SYNC-MAP.md explicitly per task; README.md as collateral).
- **`demrigorankolange2016` bib entry has a wrong title** (it names a different work);
  since it is currently uncited it can be fixed or left, but if cited it must be
  corrected (likely intended: Demri, Goranko & Lange, *Temporal Logics in Computer
  Science*, CUP 2016).
- **Part-divider scope prose** references follow-up task numbers (314/315/317) and
  stub language — must be rewritten, not just the dominant-class arg removed.
- The abstract (BimodalReference.typ:134-141) needs a full rewrite in textbook voice,
  which is prose work beyond mechanical deletion — budget a phase for front-matter
  rewriting (title page Sources, abstract, part dividers, intro).
