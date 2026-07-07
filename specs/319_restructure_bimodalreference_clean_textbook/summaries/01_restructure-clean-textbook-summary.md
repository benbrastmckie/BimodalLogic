# Implementation Summary: Restructure BimodalReference as Clean Textbook

- **Task**: 319 - restructure_bimodalreference_clean_textbook
- **Status**: [COMPLETED]
- **Session**: sess_1783407088_0a61d1
- **Plan**: specs/319_restructure_bimodalreference_clean_textbook/plans/01_restructure-clean-textbook-plan.md (all 9 phases completed)
- **Date**: 2026-07-07

## What Was Done

Converted the BimodalReference book (`Theories/Bimodal/typst/`) from the task-313
living-monograph-with-sync-scaffolding into a clean, direct four-part textbook.

### Workstream 1 — Sync machinery removal (Phases 2, 3, 7)
- Deleted all 18 `#sync-banner(...)` call sites and the `sync-banner` definition.
- Replaced all 7 `#planned-chapter-notice(...)` boxes with plain one-sentence placeholders
  (no task numbers, no styling); deleted the definition.
- Deleted the Reading-Guide/Sync-Class Legend block; removed the `dominant-class`
  parameter from `part-divider` (definition and all 5 call sites).
- 04-metalogic.typ: deleted the Sorry Inventory section (label `<sec:sorry-status>`),
  the Component Status table, and the Status Key; replaced with a 3-sentence plain-prose
  Implementation Status paragraph. All three `@sec:sorry-status` cross-references reworded
  (04-metalogic.typ x2, 00-introduction.typ x1).
- 06-notes.typ: status table replaced with plain prose; sorry-count/stamp prose reworded;
  imports trimmed to `axiom-count`/`rule-count` only.
- p2-decidability-practice.typ: Closing Status Table reduced to two de-symboled columns;
  symbol prose reworded at three sites.
- All remaining inline ✓/⧖/○/◇ symbols neutralized (p2-frame-classes, p4-dual-verification,
  p4-dataset-pipeline, p4-proof-automation). Zero symbols remain in chapters/ and the
  main file.
- `scripts/typst-sync-check.sh`: Checks 2 (banner presence) and 3 (legend discipline)
  deleted; Check 4 renumbered to Check 2; header and summary line updated. Runs green
  ("PASS (all 2 checks green)").
- `sync-check-whitelist.txt` pruned (entries used only by deleted stubs); SYNC-MAP.md
  reheadered as a repo-side historical dev document that no longer governs the PDF;
  README.md updated to the four-part structure and 2-check script.
- `generated/status.typ` and `scripts/typst-status-counts.sh` untouched (per plan);
  `axiom-count`/`rule-count`/frame-class count usages kept.

### Workstream 2 — Citations (Phases 1, 6)
- bibliography.bib: completed `brastmckie2025counterfactualworlds` (vol 54(3), pp 533-574,
  DOI, URL); `brastmckie2026possibleworlds` (draft URL, Forthcoming note); ADDED
  `brastmckie2021identity` (JPL 50(6):1471-1503, DOI, URL). Fixed `vlach1973nowandthen`
  (@phdthesis), `burgess1982axioms` (@article, NDJFL 23(4):367-374, note cleared),
  `demrigorankolange2016` (correct CUP 2016 book title, note cleared). Added
  `burgess1984basic`, `reynolds1992`, `doets1987`, `blackburnderijkevenema2001`,
  `gabbayhodkinsonreynolds1994`. Embargo header preserved; NO Lk entry.
- Wired `@`-citations throughout: Burgess (01-syntax x2, 03-proof-theory x5,
  04-metalogic x2, p2-frame-classes x1, 06-notes x1), Xu, Reynolds, Doets, Kamp, GHR,
  Blackburn-de Rijke-Venema, and `@brastmckie2026possibleworlds` in the intro, semantics,
  proof-theory, theorems (perpetuity P1-P6 salvage sentence), and notes chapters.
- Salvage remarks: perpetuity citation in 05-theorems; Determined/Deterministic +
  actuality remark appended to 02-semantics (cited, no puzzle exposition).
- References section renders non-empty: [1] The Construction of Possible Worlds,
  [2] Counterfactual Worlds, [3] Identity and Aboutness.

### Workstream 3 — Restructure (Phases 4, 5)
- DELETED `chapters/p1-why-worlds.typ` and `chapters/p3-open-future.typ` (notice-only stubs).
- New structure: Front matter (00-introduction) / Part I The Bimodal System (01-syntax,
  02-semantics, 03-proof-theory, p2-frame-classes, 04-metalogic, p2-decidability-practice,
  05-theorems, p3-ltl-to-tm, p3-vlach-blstar, p3-decidability-frontier) / Part II
  Applications (p4-proof-automation, p4-dataset-pipeline, p4-dual-verification) / Part III
  Counterfactual Logic (p5-counterfactual) / Part IV Constitutive Logic (p5-constitutive,
  concluding — order INVERTED vs old Part V) / Back matter (06-notes, References).
- All four part-divider scope paragraphs rewritten in direct textbook voice.
- Stub placeholders carry citations: vlach-blstar (@vlach1973nowandthen,
  @cresswell1990entities, @blackburn2000hybrid, @kamp1971formalproperties);
  p5-counterfactual (@brastmckie2025counterfactualworlds); p5-constitutive
  (@brastmckie2021identity); p3-ltl-to-tm (@demrigorankolange2016, @baierkatoen2008).
- 00-introduction.typ fully rewritten (171 -> 127 lines): direct motivation, worldline
  figure kept (caption reworded), four-part outline, Project Structure kept; practitioner
  thesis, unification grid, Book Map, and AI-reader protocol dropped.
- Abstract rewritten in textbook voice; title-page Sources list now cites all three papers
  with links, symbol mention removed.

### Workstream 4 — Follow-up task revision (Phase 8)
- Task 314: absorption decision recorded, status set to `abandoned`.
- Task 315: three chapters only (inside Part I), open-future dropped, banner constraints
  dropped, backtick-resolution/Lk-embargo/SLOT-IN language kept.
- Task 316: JSONL appendix pointer re-anchored to `chapters/p4-dataset-pipeline.typ`.
- Task 317: reordered counterfactual-then-constitutive (Parts III/IV), banner constraints
  dropped.
- Task 318: "mark all results with publication status" reworded to plain-prose honesty;
  SLOT-IN language unchanged.
- `jq empty` validated; TODO.md regenerated via generate-todo.sh.

## Final Verification (Phase 9)

| Check | Result |
|-------|--------|
| `typst compile` | GREEN (exit 0; only the two pre-existing thmbox font warnings; 59 pages) |
| `bash scripts/typst-sync-check.sh` | GREEN (exit 0, "PASS (all 2 checks green)", 459 candidates, 0 violations) |
| Three papers cited | All three `@brastmckie*` keys cited; References renders [1]-[3] in the PDF |
| Residual `sync-banner`/`planned-chapter-notice`/`sync-class` | CLEAN in *.typ and chapters/ |
| Residual ✓/⧖/○/◇ | CLEAN in chapters/ and BimodalReference.typ |
| SLOT-IN anchors | 3 line-start `// SLOT-IN:` anchors + EMBARGO comment intact verbatim |
| `task 31[4-8]` in book | PDF text clean; source hits only in p3-decidability-frontier.typ comments (see deviations) |
| `jq empty specs/state.json` | PASS; 314 abandoned, 315-318 not_started |

## Plan Deviations

- **`task 31[4-8]` residual grep (Phase 9)**: 4 hits remain, all inside
  `chapters/p3-decidability-frontier.typ` source comments (the EMBARGO header and the
  three `// SLOT-IN:` anchor comments referencing task 318). These were mandated to be
  preserved verbatim (plan Phase 4 verification; delegation invariant for task 318), which
  takes precedence over the residual grep. The compiled PDF contains no task 314-318
  numbers.
- **Phase 2 placeholder note in p3-vlach-blstar**: the interim Phase 2 sentence used
  `BL#super[★]` (star glyph); Phase 4's rewrite restored the chapter's canonical
  `BL#super[⋆]` glyph. No net deviation.
- **generate-todo.sh warnings**: pre-existing non-fatal arithmetic-syntax warnings at
  script line 243 during regeneration (exit code 0; output correct). Not introduced by
  this task; left as-is.
- Otherwise: implementation followed plan.

## Files Modified

- `Theories/Bimodal/typst/BimodalReference.typ`, `template.typ`, `bibliography.bib`,
  `SYNC-MAP.md`, `README.md`, `sync-check-whitelist.txt`
- 17 chapter files under `Theories/Bimodal/typst/chapters/`
- Deleted: `chapters/p1-why-worlds.typ`, `chapters/p3-open-future.typ`
- `scripts/typst-sync-check.sh`
- `specs/state.json`, `specs/TODO.md`

## Commits

One commit per phase (`task 319 phase {P}: ...`, phases 1-8), plus the final
implementation-completion commit.
