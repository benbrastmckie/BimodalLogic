# Implementation Plan: Restructure BimodalReference as Clean Textbook

- **Task**: 319 - restructure_bimodalreference_clean_textbook
- **Status**: [COMPLETED]
- **Effort**: 10 hours
- **Dependencies**: None (task 313 complete; tasks 314-318 depend on this task)
- **Research Inputs**: specs/319_restructure_bimodalreference_clean_textbook/reports/01_restructure-clean-textbook-research.md
- **Artifacts**: plans/01_restructure-clean-textbook-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

Convert the BimodalReference book (`Theories/Bimodal/typst/`) from the task-313
living-monograph-with-sync-scaffolding into a clean, direct textbook: remove all
sync-class/status-symbol machinery (workstream 1), wire real `@`-citations so the
References section renders non-empty (workstream 2), restructure to the new narrative
arc bimodal system -> applications -> counterfactual -> constitutive with two puzzle
chapters dropped (workstream 3), and revise follow-up task descriptions 314-318 in
state.json (workstream 4). Definition of done: `typst compile` green, revised
`scripts/typst-sync-check.sh` green (checks 1 and 4 only), References non-empty with
the three Brast-McKie papers, all three `// SLOT-IN:` anchors intact.

All file:line targets below are from the research report (repo state at commit
a88f4f483); the implementer should re-verify line numbers with grep before editing,
since earlier phases shift lines in later phases' targets.

### Research Integration

The research report (01_restructure-clean-textbook-research.md) provides: the full
banner/notice/legend removal map (18 `#sync-banner` sites, 7 `#planned-chapter-notice`
sites, 5 `#part-divider` dominant-class labels), Crossref-verified citation metadata
for all three papers, the current vs. target include order, the 3 SLOT-IN anchors, the
sync-check.sh check boundaries, and the state of tasks 314-318 (dependencies already
include 319; only descriptions need rewriting). Baseline `typst compile` is green.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted (not provided in delegation context).

## Goals & Non-Goals

**Goals**:
- Compiled PDF free of sync-class symbols, banners, legend, stub notice boxes, sorry
  reporting, and AI-reader protocol.
- References section renders with (at least) the three Brast-McKie papers; plain-text
  author-year mentions converted to `@`-citations backed by corrected bib entries.
- New four-part structure with `p1-why-worlds.typ` and `p3-open-future.typ` deleted and
  Part V order inverted (counterfactual before constitutive).
- `scripts/typst-sync-check.sh` reduced to checks 1 (backtick resolution) and 4 (count
  freshness); SYNC-MAP.md retired to dev-doc status; README.md updated as collateral.
- Tasks 314-318 descriptions revised in state.json; TODO.md regenerated.
- Book compiles green at the end of every phase.

**Non-Goals**:
- Writing the real content of the stub chapters (p3-ltl-to-tm, p3-vlach-blstar,
  p5-counterfactual, p5-constitutive) — that is tasks 315/317.
- Filling the SLOT-IN anchors in p3-decidability-frontier.typ — that is task 318.
- Adding any Lk bibliography entry (embargo, bibliography.bib:8-10, unchanged).
- Modifying `generated/status.typ` or `scripts/typst-status-counts.sh` — both stay as
  is; only reader-facing *usages* of `sorry-*` bindings are removed.
- Lean source changes of any kind.

## Fixed Decisions (planner calls, binding for the implementer)

1. **Folded chapters placement**: `p3-ltl-to-tm.typ`, `p3-vlach-blstar.typ`,
   `p3-decidability-frontier.typ` go at the end of the bimodal Part, after
   `05-theorems.typ`, in that order.
2. **04-metalogic status tables**: delete the Sorry Inventory section (`:157-199`,
   including label `<sec:sorry-status>`) entirely; delete the Component Status table
   (`:205-228`) and Status Key (`:230-233`), replacing both with a 2-3 sentence plain
   prose paragraph stating what is formalized in Lean and where completeness stands
   (no symbols, no counts of sorries).
3. **p2-decidability-practice Closing Status Table**: keep the table but delete the
   Roadmap column and all ✓/⧖/◇ symbols; remaining columns state component and its
   Lean location. If the de-symboled table carries no information, replace with prose.
4. **generated counts**: keep `axiom-count`, `rule-count`, `base-count`,
   `dense-only-count`, `discrete-only-count` usages; strip all `sorry-total`,
   `sorry-total-excl-boneyard`, `sorry-table`, `stamp-*` usages from chapter prose.
   sync-check check 4 needs no change.
5. **Task 314**: absorbed — the rewritten introduction (Phase 5) carries all the brief
   motivation the book needs. Record the decision in 314's description and set its
   status to `abandoned` in state.json.
6. **Task 316 re-anchor**: the JSONL appendix pointer moves to the dataset pipeline
   chapter (`p4-dataset-pipeline.typ`), the natural home for artifact pointers.
7. **Template**: delete `sync-banner` and `planned-chapter-notice` definitions from
   `template.typ`; keep `part-divider` but remove its `dominant-class` parameter.
8. **New-entry bib keys**: `brastmckie2021identity`, `burgess1984basic`,
   `reynolds1992`, `doets1987`, `blackburnderijkevenema2001`, `gabbayhodkinsonreynolds1994`
   (GHR, *Temporal Logic: Mathematical Foundations and Computational Aspects*, OUP 1994).
   Third-party entries whose metadata the implementer verifies get their
   `note = {verify before print}` cleared; unverified ones keep it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing `<sec:sorry-status>` breaks `@sec:sorry-status` refs (`04-metalogic.typ:19,91`, `00-introduction.typ:107`) | H (compile error) | H | Phase 3 rewords all three refs in the same edit batch as the section removal; compile check before phase close |
| Deleting template functions while call sites remain breaks compile | H | M | Strict ordering: Phase 2 removes ALL call sites and definitions in one phase, compile-verified |
| SLOT-IN anchors lost during p3-decidability-frontier edits | H (blocks task 318) | M | Phase 4 verification includes `grep -c '// SLOT-IN:' == 3`; anchors and EMBARGO comment (:10-15) copied verbatim |
| Wrong bib metadata propagates to print | M | M | Phase 1 uses Crossref-verified data from research report section 3.1; `verify before print` notes retained where unverified |
| `demrigorankolange2016` entry names the wrong work; `vlach1973nowandthen` has wrong type; `burgess1982axioms` typed as book | M | H (already wrong) | Phase 1 fixes all three explicitly (see tasks) |
| Line numbers drift between phases | M | H | Each phase re-greps its targets before editing; targets listed with search strings, not just line numbers |
| state.json corruption during Phase 8 jq edits | H | L | Edit via jq to temp file + `jq empty` validation before move; git provides rollback |
| README/SYNC-MAP left stale (documenting removed machinery) | L | M | Phase 7 explicitly covers both as collateral |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 3 |
| 4 | 5, 6, 7 | 4 |
| 5 | 8 | 5 |
| 6 | 9 | 5, 6, 7, 8 |

Phases within the same wave can execute in parallel (disjoint file territories:
Phase 1 = bibliography.bib only; Phase 2 = chapters/template/main file; Phase 5 =
intro + main-file front matter; Phase 6 = keeper-chapter prose; Phase 7 = scripts +
repo docs). A single sequential implementer runs 1, 2, 3, 4, 5, 6, 7, 8, 9.

---

### Phase 1: Bibliography completion and corrections [COMPLETED]

**Goal**: `bibliography.bib` is complete and correct so later phases can cite freely.
Purely additive/corrective — no `.typ` changes, compile trivially stays green.

**Tasks**:
- [ ] `brastmckie2025counterfactualworlds` (bibliography.bib:21-27): add
  `volume = {54}`, `number = {3}`, `pages = {533--574}`,
  `doi = {10.1007/s10992-025-09793-8}`,
  `url = {https://link.springer.com/article/10.1007/s10992-025-09793-8}`, year 2025,
  Journal of Philosophical Logic.
- [ ] `brastmckie2026possibleworlds` (:13-19): add
  `url = {https://benbrastmckie.com/wp-content/uploads/2026/07/possible_worlds.pdf}`
  and `note = {Forthcoming}` (Journal of Philosophical Logic).
- [ ] ADD `brastmckie2021identity`: Brast-McKie, "Identity and Aboutness", Journal of
  Philosophical Logic 50(6):1471-1503, 2021, `doi = {10.1007/s10992-021-09612-w}`,
  `url = {https://link.springer.com/article/10.1007/s10992-021-09612-w}`.
- [ ] FIX `vlach1973nowandthen` (:44-50): change entry type `@article` -> `@phdthesis`
  (keeps `school = {UCLA}`).
- [ ] FIX `burgess1982axioms` (:29-35): change `@book` -> `@article`, journal = Notre
  Dame Journal of Formal Logic, volume 23, number 4, pages 367-374, 1982.
- [ ] FIX `demrigorankolange2016` (:83-88): correct title to *Temporal Logics in
  Computer Science: Finite-State Systems*, Cambridge University Press, 2016.
- [ ] ADD missing entries cited in prose (keys per Fixed Decision 8): `burgess1984basic`
  (Basic Tense Logic, Handbook of Philosophical Logic vol. II, 1984), `reynolds1992`,
  `doets1987`, `blackburnderijkevenema2001` (*Modal Logic*, CUP 2001),
  `gabbayhodkinsonreynolds1994`. Add `note = {verify before print}` to any whose full
  metadata the implementer cannot confirm from the research report or web check.
- [ ] Do NOT touch the embargo header (:8-10); confirm no Lk entry added.

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/typst/bibliography.bib` — entry completion/correction/addition

**Verification**:
- `cd Theories/Bimodal/typst && typst compile BimodalReference.typ build/BimodalReference.pdf` green
- `grep -c "brastmckie" bibliography.bib` shows 3 entries; `grep -i "lk" bibliography.bib` shows no Lk entry

---

### Phase 2: Remove banner/legend/notice machinery (calls + definitions) [COMPLETED]

**Goal**: All `#sync-banner` calls, the legend box, `dominant-class` labels, and
`#planned-chapter-notice` boxes are gone from the compiled book; template definitions
deleted in the same phase so compile stays green.

**Tasks**:
- [ ] Delete all 18 `#sync-banner(...)` call sites (grep `sync-banner` to locate;
  research map: 00-introduction:17, 01-syntax:14, 02-semantics:10, 03-proof-theory:15,
  p2-frame-classes:21, 04-metalogic:15, p2-decidability-practice:18, 05-theorems:10,
  p3-ltl-to-tm:13, p3-vlach-blstar:13, p3-decidability-frontier:21, p3-open-future:13,
  p4-proof-automation:19, p4-dataset-pipeline:19, p4-dual-verification:18,
  p5-constitutive:13, p5-counterfactual:13, 06-notes:14). Multi-line calls: delete the
  whole call expression.
- [ ] Replace the 7 `#planned-chapter-notice(...)` boxes with a single plain sentence
  each ("This chapter will present ... directly from the formal development."), no task
  numbers, no styling: p1-why-worlds:15 and p3-open-future:15 (interim — files deleted
  in Phase 4), p3-ltl-to-tm:15, p3-vlach-blstar:15, p3-decidability-frontier:23,
  p5-constitutive:15, p5-counterfactual:15. In p3-decidability-frontier, do not touch
  the `// SLOT-IN:` comments (:33,:38,:44) or the EMBARGO comment (:10-15).
- [ ] `BimodalReference.typ:145-161`: delete the Reading-Guide/Sync-Class Legend block
  entirely.
- [ ] `BimodalReference.typ` five `#part-divider` calls (:192-203, :210-222, :234-245,
  :254-265, :273-284): remove the dominant-class positional argument from each call
  (the scope-paragraph prose is rewritten in Phase 4 — here only the class string
  argument is dropped).
- [ ] `template.typ`: delete `#let sync-banner` (:261-294) and its comment block
  (~:195-202); delete `#let planned-chapter-notice` (:212-226) and comment (:204-210);
  remove the `dominant-class` parameter from `#let part-divider` (:236-253, rendered
  at :244).
- [ ] `BimodalReference.typ:18`: trim the template import list (remove `sync-banner`;
  keep `part-divider`); check chapters' own imports of these names
  (`grep -rn "sync-banner\|planned-chapter-notice" chapters/ notation/ *.typ`) and
  remove stale import references.

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/typst/template.typ` — delete two definitions, simplify part-divider
- `Theories/Bimodal/typst/BimodalReference.typ` — legend box, divider args, import line
- all 19 files in `Theories/Bimodal/typst/chapters/` — banner/notice call removal

**Verification**:
- `grep -rn "sync-banner\|planned-chapter-notice" Theories/Bimodal/typst/` returns nothing
- `typst compile` green
- `grep -c '// SLOT-IN:' chapters/p3-decidability-frontier.typ` == 3

---

### Phase 3: Remove status tables, sorry reporting, inline symbols; fix cross-refs [COMPLETED]

**Goal**: No ✓/⧖/○/◇ symbols and no sorry-count reporting anywhere in reader-facing
text; all cross-references that pointed at removed content reworded; compile green.

**Tasks**:
- [ ] `chapters/04-metalogic.typ`: delete Sorry Inventory section `:157-199` (label
  `<sec:sorry-status>` at :157, sorry prose :161-162, `#sorry-table` :164-192); delete
  Component Status table `:205-228` and Status Key `:230-233`; replace both with one
  2-3 sentence plain prose paragraph per Fixed Decision 2. Trim the import at `:11` to
  drop `sorry-total`, `sorry-total-excl-boneyard`, `sorry-table`, and stamp bindings
  (keep `axiom-count`, used at :36).
- [ ] **Cross-ref repair (compile-critical)**: reword `@sec:sorry-status` references at
  `04-metalogic.typ:19` and `:91` (footnote refs — replace with plain prose such as
  "the Lean sources record remaining gaps") and `00-introduction.typ:107` (interim
  reword; the file is fully rewritten in Phase 5). Grep `@sec:sorry-status` afterwards:
  zero hits.
- [ ] `chapters/06-notes.typ`: delete/replace status table `:20-41` (uses
  `#sorry-total` at :34) with plain prose; reword sorry-count prose at `:99` (uses
  `sorry-total`, `stamp-commit`, `stamp-date`); trim import `:10` accordingly; fix the
  inline symbol at `:60`.
- [ ] `chapters/p2-decidability-practice.typ`: apply Fixed Decision 3 to the Closing
  Status Table (figure :69-85; drop `[*Roadmap*]` column in header row :75 and the
  ✓/⧖/◇ cells :77-81); reword symbol prose at :33, :58, :60.
- [ ] Rewrite remaining inline-symbol prose as neutral text ("proven sorry-free" ->
  "proven"; keep honest open/closed statements without symbols):
  `p2-frame-classes.typ:67,71,72,89,100`; `p4-dual-verification.typ:23,28,31,63`;
  `p4-dataset-pipeline.typ:32,81`; `p4-proof-automation.typ:56`; `p3-ltl-to-tm.typ:23`.
  (00-introduction's 18 occurrences are handled by the Phase 5 rewrite; leave them
  unless they break nothing — they don't.)
- [ ] Final sweep: `grep -rn "✓\|⧖\|○\|◇" chapters/ BimodalReference.typ` — remaining
  hits only in 00-introduction.typ (Phase 5 territory) or justified non-status uses.

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `chapters/04-metalogic.typ`, `chapters/06-notes.typ`,
  `chapters/p2-decidability-practice.typ`, `chapters/p2-frame-classes.typ`,
  `chapters/p4-dual-verification.typ`, `chapters/p4-dataset-pipeline.typ`,
  `chapters/p4-proof-automation.typ`, `chapters/p3-ltl-to-tm.typ`

**Verification**:
- `grep -rn "@sec:sorry-status" Theories/Bimodal/typst/` empty
- `grep -rn "sorry-total\|sorry-table" Theories/Bimodal/typst/chapters/` empty
- `typst compile` green

---

### Phase 4: Restructure — include order, part dividers, drop chapters [COMPLETED]

**Goal**: The book has the new four-part arc; two puzzle chapters deleted; stub
placeholders carry citations; SLOT-IN anchors intact; compile green.

**Tasks**:
- [ ] Delete `chapters/p1-why-worlds.typ` and `chapters/p3-open-future.typ` (both are
  notice-only stubs; no prose lost) and remove their `#include` lines
  (`BimodalReference.typ:206`, `:250`).
- [ ] Rewrite the part structure in `BimodalReference.typ` (:190-291 region) to:
  - Front matter: `00-introduction` (no part divider of its own, or a slim "Introduction"
    heading — implementer's call).
  - **Part I: The Bimodal System** — 01-syntax, 02-semantics, 03-proof-theory,
    p2-frame-classes, 04-metalogic, p2-decidability-practice, 05-theorems,
    p3-ltl-to-tm, p3-vlach-blstar, p3-decidability-frontier (Fixed Decision 1).
  - **Part II: Applications** — p4-proof-automation, p4-dataset-pipeline,
    p4-dual-verification.
  - **Part III: Counterfactual Logic** — p5-counterfactual.
  - **Part IV: Constitutive Logic** — p5-constitutive (order INVERTED vs. current
    Part V — constitutive concludes).
  - Back matter: 06-notes, bibliography (unchanged at :297-299).
- [ ] Rewrite the four part-divider scope paragraphs in direct textbook voice: no
  sync-class language, no stub language, no follow-up task numbers (current prose at
  :192-203, :210-222, :254-265, :273-284 mentions tasks 314/315/317 — all must go).
- [ ] Give the three remaining stub chapters citation-bearing placeholder sentences:
  `p3-vlach-blstar.typ` cites `@vlach1973nowandthen`, `@cresswell1990entities`,
  `@blackburn2000hybrid`; `p5-counterfactual.typ` cites
  `@brastmckie2025counterfactualworlds`; `p5-constitutive.typ` cites
  `@brastmckie2021identity`; `p3-ltl-to-tm.typ` keeps its neutral sentence (cite
  `@demrigorankolange2016` or `@baierkatoen2008` if natural).
- [ ] `chapters/p3-decidability-frontier.typ`: verify the EMBARGO comment (:10-15) and
  all three `// SLOT-IN:` anchors (:33,:38,:44) survived verbatim.

**Timing**: 1.5 hours

**Depends on**: 1, 3

**Files to modify**:
- `Theories/Bimodal/typst/BimodalReference.typ` — include order + part dividers
- `chapters/p3-vlach-blstar.typ`, `chapters/p5-counterfactual.typ`,
  `chapters/p5-constitutive.typ`, `chapters/p3-ltl-to-tm.typ` — placeholder sentences
- DELETE `chapters/p1-why-worlds.typ`, `chapters/p3-open-future.typ`

**Verification**:
- `typst compile` green (internal `@sec:` refs survive reordering — labels move with files)
- `grep -c '// SLOT-IN:' chapters/p3-decidability-frontier.typ` == 3
- `grep -rn "p1-why-worlds\|p3-open-future" Theories/Bimodal/typst/` empty
- constitutive include appears AFTER counterfactual include in BimodalReference.typ

---

### Phase 5: Rewrite front matter — introduction, abstract, title-page Sources [COMPLETED]

**Goal**: The book opens as a direct textbook: brief motivated introduction, textbook
abstract, citation-backed Sources. This is the prose-heavy phase.

**Tasks**:
- [ ] Rewrite `chapters/00-introduction.typ` (171 lines currently) as a brief, direct
  introduction: motivation = unifying tense and modality in a formally verified system
  (no philosophical puzzles, no AI-practitioner-first framing); outline = bimodal
  system -> applications -> counterfactual logic -> constitutive logic. KEEP: the
  accurate "What TM Actually Is" content (:26-32), the worldline cetz figure (:34-101,
  reword the caption's outlook sentence :94), the Project Structure section (:162-171,
  with `axiom-count`/`rule-count` — retain `generated/status.typ` import :12 and cetz
  import :13). DROP: practitioner thesis (:19-24), the ◇-bearing unification grid
  (:104-139, or keep only if fully de-symboled and de-Part-numbered), the Book Map
  (:141-149, replace with the new four-part outline), the AI-reader protocol
  (:151-160). Cite `@brastmckie2026possibleworlds` for the semantic framework, plus one
  sentence noting the counterfactual/constitutive extensions with
  `@brastmckie2025counterfactualworlds` and `@brastmckie2021identity`.
- [ ] Rewrite the abstract (`BimodalReference.typ:134-141`) in direct textbook voice —
  no "living monograph", no stubs, no sync-class sentence.
- [ ] Title-page Sources list (`BimodalReference.typ:111-118`): remove the ✓/⧖ mention
  in item 3 (:117); add the Springer link/DOI for Counterfactual Worlds (:116) — or
  replace the hand-written list with citation-backed items.
- [ ] One sentence somewhere natural in the intro covering the dropped puzzle material
  (eternalism/Prior/Kaplan debates) as a pointer to `@brastmckie2026possibleworlds` —
  nothing more.

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `chapters/00-introduction.typ` — full rewrite
- `Theories/Bimodal/typst/BimodalReference.typ` — abstract :134-141, Sources :111-118

**Verification**:
- `typst compile` green
- `grep -n "✓\|⧖\|○\|◇\|sync" chapters/00-introduction.typ` empty
- intro contains `@brastmckie2026possibleworlds`

---

### Phase 6: Wire citations into keeper-chapter prose [COMPLETED]

**Goal**: Plain-text author-year mentions become real `@`-citations; salvaged technical
pointers from the dropped chapters land where formally relevant; References will render
with all wired entries.

**Tasks**:
- [ ] Burgess: convert mentions at `03-proof-theory.typ:72,107,117,202`,
  `04-metalogic.typ:104,111`, `01-syntax.typ:26,105`, `p2-frame-classes.typ:78`,
  `06-notes.typ:144` — use `@burgess1982axioms` and/or `@burgess1984basic` as the
  context requires ("Burgess (1982/84)" cites both).
- [ ] Xu (1988): `03-proof-theory.typ:72`, `06-notes.typ:144` -> `@xu1988until`.
- [ ] Reynolds 1992 and Doets 1987: `03-proof-theory.typ:181` (and pipeline mentions
  `04-metalogic.typ:105,143`) -> `@reynolds1992`, `@doets1987`.
- [ ] Kamp: `06-notes.typ:101`, `04-metalogic.typ:117,118,143,179`,
  `p4-proof-automation.typ:55-56` -> `@kamp1971formalproperties`; GHR93 at
  `p4-proof-automation.typ:55` -> `@gabbayhodkinsonreynolds1994`.
- [ ] Blackburn-de Rijke-Venema: `06-notes.typ:136,144` -> `@blackburnderijkevenema2001`.
- [ ] `06-notes.typ` "the paper" voice (:56-64 discrepancy register, :99-118 region):
  convert to explicit `@brastmckie2026possibleworlds` citations.
- [ ] Possible-worlds citations in the formal core: one each in `02-semantics.typ`
  (task-frame semantics source) and `03-proof-theory.typ` (axiom system source).
- [ ] Salvage remarks (research section 4.4): in `05-theorems.typ`, one sentence citing
  `@brastmckie2026possibleworlds` for the perpetuity principles P1-P6; in
  `02-semantics.typ` or `p2-frame-classes.typ`, a short cited remark on
  Determined/Deterministic and actuality operators (source: possible_worlds.tex
  1291-1541) — 2-4 sentences total, no puzzle exposition.
- [ ] Prior mentions in axiom names (`03-proof-theory.typ:161-181`) are names, not
  citations — leave unless a natural `@`-cite exists (optional).

**Timing**: 1.5 hours

**Depends on**: 4 (runs in parallel with 5 and 7 — disjoint files)

**Files to modify**:
- `chapters/01-syntax.typ`, `chapters/02-semantics.typ`, `chapters/03-proof-theory.typ`,
  `chapters/p2-frame-classes.typ`, `chapters/04-metalogic.typ`,
  `chapters/05-theorems.typ`, `chapters/06-notes.typ`, `chapters/p4-proof-automation.typ`

**Verification**:
- `typst compile` green with no unresolved-citation warnings
- `grep -rn "@brastmckie" chapters/ | wc -l` >= 5 across the book
- References section in the compiled PDF non-empty

---

### Phase 7: Scripts and repo docs — sync-check, whitelist, SYNC-MAP, README [COMPLETED]

**Goal**: `scripts/typst-sync-check.sh` runs checks 1 and 4 only and passes; repo docs
no longer claim the sync-class system governs the PDF.

**Tasks**:
- [ ] `scripts/typst-sync-check.sh` (290 lines): DELETE Check 2 (banner presence,
  :160-184) and Check 3 (legend discipline, :186-206); KEEP Check 1 (backtick name
  resolution, :34-158) and Check 4 (count freshness, :208-278) unchanged; update the
  header comment (:2-21) and the summary line (:287 "all 4 checks green" -> "all 2
  checks green" / equivalent wording); renumber check labels in output if the script
  prints them.
- [ ] `Theories/Bimodal/typst/sync-check-whitelist.txt`: prune entries that existed
  only for the removed machinery ("Planned files for follow-up tasks" block,
  `sync-banner`/`planned-chapter-notice` API names). Stale entries are harmless to
  check 1, so prune conservatively — when unsure, keep.
- [ ] `Theories/Bimodal/typst/SYNC-MAP.md`: rewrite the header (lines 1-40 region) to
  state it is a repo-side development document recording claim-verification history —
  it no longer governs the compiled PDF; the compiled book carries no sync-class
  markings. Leave the body tables as historical record.
- [ ] `Theories/Bimodal/typst/README.md`: update the sync-class legend documentation
  and the five-part table with sync-class column (~lines 28-46) to describe the new
  four-part structure and the 2-check sync script.

**Timing**: 1 hour

**Depends on**: 4 (docs must describe the final structure; script edit itself only
needs Phase 2)

**Files to modify**:
- `scripts/typst-sync-check.sh`
- `Theories/Bimodal/typst/sync-check-whitelist.txt`
- `Theories/Bimodal/typst/SYNC-MAP.md`
- `Theories/Bimodal/typst/README.md`

**Verification**:
- `bash scripts/typst-sync-check.sh` exits 0
- `grep -n "check 2\|check 3\|banner" scripts/typst-sync-check.sh` shows no live check-2/3 code

---

### Phase 8: Revise follow-up tasks 314-318 in state.json [COMPLETED]

**Goal**: Follow-up task descriptions match the restructured book; TODO.md regenerated.
Dependencies already include 319 (research finding) — descriptions only.

**Tasks**:
- [ ] Task 314: record the absorption decision (Fixed Decision 5) — rewrite description
  to "Decision (task 319): the rewritten introduction carries the book's motivation;
  chapter p1-why-worlds.typ deleted; task absorbed into 319." and set status to
  `abandoned` in state.json.
- [ ] Task 315: rewrite description — three chapters only (p3-ltl-to-tm.typ,
  p3-vlach-blstar.typ, p3-decidability-frontier.typ), now inside the bimodal Part;
  DROP the p3-open-future puzzle chapter (its technical content — Determined/
  Deterministic, actuality — now lives as cited remarks per Phase 6); DROP all
  sync-banner/legend constraints; KEEP the backtick-resolution constraint, the Lk
  embargo, and SLOT-IN preservation language.
- [ ] Task 316: re-anchor the JSONL appendix pointer to the dataset pipeline chapter
  (`p4-dataset-pipeline.typ`, Fixed Decision 6); "sync-check green" wording stays valid
  (checks 1+4).
- [ ] Task 317: reorder to counterfactual-then-constitutive book order (p5-counterfactual
  is Part III, p5-constitutive concludes as Part IV); drop banner/sync-class
  constraints.
- [ ] Task 318: remove banner/publication-status-marker constraints; reword "Mark all
  results with their publication status" to plain-prose honesty ("state openly which
  results are established in print and which are new"); SLOT-IN anchors unchanged.
- [ ] Validate edited state.json (`jq empty specs/state.json`), then run
  `bash .claude/scripts/generate-todo.sh` and review the TODO.md diff.

**Timing**: 1 hour

**Depends on**: 5 (decisions reference the final intro and structure)

**Files to modify**:
- `specs/state.json` — descriptions for 314-318, status for 314
- `specs/TODO.md` — regenerated (never hand-edited)

**Verification**:
- `jq empty specs/state.json` passes
- `jq -r '.active_projects[] | select(.project_number >= 314 and .project_number <= 318) | "\(.project_number) \(.status)"' specs/state.json` shows 314 abandoned, others unchanged
- `git diff specs/TODO.md` shows only the five expected task entries changed

---

### Phase 9: Final verification sweep [COMPLETED]

**Goal**: All task VERIFY criteria confirmed on the finished state; residual-artifact
greps clean.

**Tasks**:
- [ ] `cd Theories/Bimodal/typst && typst compile BimodalReference.typ build/BimodalReference.pdf`
  — green (only the two pre-existing thmbox font warnings tolerated).
- [ ] `bash scripts/typst-sync-check.sh` — exit 0 with 2-check structure.
- [ ] References non-empty: `grep -rn "@brastmckie2026possibleworlds\|@brastmckie2025counterfactualworlds\|@brastmckie2021identity" Theories/Bimodal/typst/chapters/ Theories/Bimodal/typst/BimodalReference.typ`
  — all three keys cited at least once; optionally `pdftotext build/BimodalReference.pdf - | grep -A5 "References"` shows entries.
- [ ] `grep -rn "sync-banner\|planned-chapter-notice\|Sync-Class\|sync-class" Theories/Bimodal/typst/*.typ Theories/Bimodal/typst/chapters/` — empty (SYNC-MAP.md/README.md may mention the history in prose).
- [ ] `grep -rn "✓\|⧖\|○\|◇" Theories/Bimodal/typst/chapters/ Theories/Bimodal/typst/BimodalReference.typ` — empty or justified non-status uses only.
- [ ] `grep -c '// SLOT-IN:' Theories/Bimodal/typst/chapters/p3-decidability-frontier.typ` == 3; EMBARGO comment present.
- [ ] `grep -rn "task 31[4-8]" Theories/Bimodal/typst/chapters/ Theories/Bimodal/typst/BimodalReference.typ` — empty (no task numbers in the book).
- [ ] Fix any failures found (small reword/ref fixes are in-phase; structural failures
  reopen the owning phase).

**Timing**: 0.5 hours

**Depends on**: 5, 6, 7, 8

**Files to modify**:
- None expected (small fixes in any book file if a check fails)

**Verification**:
- All seven checks above pass; results recorded in the implementation summary

## Testing & Validation

- [ ] `typst compile` green at the END OF EVERY PHASE (phase gate, not just Phase 9)
- [ ] `scripts/typst-sync-check.sh` exit 0 after Phase 7 and at Phase 9
- [ ] Three Brast-McKie papers cited and rendering in References (Phase 9)
- [ ] SLOT-IN anchor count == 3 after Phases 2, 4, and 9
- [ ] `jq empty specs/state.json` after Phase 8
- [ ] Commit after each green phase per git-workflow.md (`task 319 phase {P}: {name}`)

## Artifacts & Outputs

- `specs/319_restructure_bimodalreference_clean_textbook/plans/01_restructure-clean-textbook-plan.md` (this file)
- Modified: `Theories/Bimodal/typst/BimodalReference.typ`, `template.typ`,
  `bibliography.bib`, `SYNC-MAP.md`, `README.md`, `sync-check-whitelist.txt`,
  17 chapter files; `scripts/typst-sync-check.sh`; `specs/state.json`; `specs/TODO.md`
- Deleted: `chapters/p1-why-worlds.typ`, `chapters/p3-open-future.typ`
- `specs/319_restructure_bimodalreference_clean_textbook/summaries/01_restructure-clean-textbook-summary.md` (written by implementer)

## Rollback/Contingency

- Each phase is committed independently when green (commit-per-green-substep mandate);
  rollback = `git revert` of the offending phase commit(s). No destructive git on
  uncommitted work; use `git-snapshot.sh` before any intentional rollback.
- Phase 2/3 breakage (missing function / dangling ref): the compile error names the
  file:line; fix forward — the removal maps above are complete, so failures are
  missed-call-site issues, not design issues.
- Phase 8 state.json issues: jq-validate before writing; git history restores the
  previous state.json; regenerate TODO.md afterwards.
- If the restructure (Phase 4) stalls, Phases 1-3 alone leave the book compilable and
  strictly cleaner than baseline — safe intermediate resting point.
