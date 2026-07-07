# Implementation Plan: Task #323

- **Task**: 323 - Review and revise BimodalReference monograph to uniform finished-book standard
- **Status**: [COMPLETED]
- **Effort**: 9 hours
- **Dependencies**: None
- **Research Inputs**: specs/323_review_and_revise_bimodalreference_uniform_standard/reports/01_editorial-review-research.md
- **Artifacts**: plans/01_editorial-uniform-standard.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

Full editorial review-and-revise pass over `Theories/Bimodal/typst/` (25 files, 3,880 lines) to raise the BimodalReference monograph to a uniform finished-book standard: remove all "honest account" refrain and draft-narration meta-commentary, rewrite hedging into confident neutral exposition, expand the thinnest chapters (Part II cluster: 61-90 lines each) toward the bar set by 03-proof-theory (356 lines) and p5-counterfactual (505 lines), and fix the one latent overclaim at `p5-counterfactual.typ:482`. The change is tone and completeness-posture, never truth-value: every factual guardrail in the research report (Section 4) must survive rewrites in neutral form. Definition of done: both acceptance gates green, adversarial banned-pattern audit returns zero hits outside whitelisted locations, byte-preserve blocks in `p3-decidability-frontier.typ` unchanged, and a per-chapter quality assessment delivered in the final summary.

### Research Integration

The plan follows the research report's 7-phase recommendation (report Section 6) and encodes its complete audit inventory: 9 "honest" hits (Section 2.1), ~35 self-narration sites with file:line targets (Section 2.2), byte-preserve inventory for `p3-decidability-frontier.typ` (Section 3), 8 factual-accuracy guardrails (Section 4), and gate mechanics including the Lean-drift caution for sync Checks 2/3 (Section 5.2).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context provided for this task.

## Goals & Non-Goals

**Goals**:
- Zero occurrences of the honesty refrain and draft-status meta-commentary in rendered prose (outside whitelisted comment blocks).
- Uniform confident, neutral expository voice across all chapters, front matter, and notation prose.
- Thin chapters expanded to consistent expository depth (targets in Phases 3 and 5), or given clean TO BE CONTINUED markers where content genuinely remains unwritten.
- Accuracy fix at `p5-counterfactual.typ:482` (no Lean-formalized completeness theorem may be asserted).
- Both acceptance gates green after every phase and at end: `typst compile Theories/Bimodal/typst/BimodalReference.typ` exits 0; `scripts/typst-sync-check.sh` passes all checks.
- Byte-identical preservation of `p3-decidability-frontier.typ` EMBARGO header (lines 1-13) and the three `// SLOT-IN:` blocks.

**Non-Goals**:
- No changes to `template.typ` (no prose; out of editorial scope).
- No edits to `generated/status.typ`, `generated/machine-appendix.typ`, or `generated/machine-appendix.jsonl` (sync Checks 2-3 enforce byte agreement; regeneration via sanctioned scripts only, and only to absorb inherited Lean-side drift).
- No new mathematical claims, no Lk-embargoed content, no strengthening of any formalization-status claim.
- No fix required for the pre-existing non-fatal warning at `notation/shared-notation.typ:44` (must not become an error).
- No restructuring of the book's part/chapter organization or include order.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Honesty-removal drifts into overclaiming (e.g., asserting completed completeness) | H | M | Guardrail checklist G1-G7 (below) run as verification in each touching phase and re-run adversarially in Phase 7; the direction of every rewrite is neutral restatement, never upgrade |
| Accidental edit to byte-preserve blocks in p3-decidability-frontier.typ | H | L | Phase 4 is a dedicated surgical pass; content-based `git diff`/extraction check fails the phase if any of the four comment blocks changed |
| New backticked tokens in expanded prose fail sync Check 1 | M | H | Expansion phases prefer existing resolving tokens; every new backtick must resolve against Lean source or be a sanctioned whitelist addition to `sync-check-whitelist.txt` (external names only, minimized); sync check runs per phase |
| Inherited Lean-side drift breaks sync Checks 2/3 mid-task (e.g., task 321 changes sorry counts) | M | M | Run both gates at phase START as well as end; if start-of-phase check fails on counts, regenerate via `scripts/typst-status-counts.sh` / `scripts/typst-machine-appendix.sh` (sanctioned) and commit separately before editorial edits |
| Cross-references break when sections are retitled | M | M | Labels (e.g., `<sec:ltl-to-tm>`) are never removed or renamed; only heading text changes; `typst compile` catches dangling refs per phase |
| Expansion produces filler rather than bar-quality exposition | M | M | Expansion sourced from the underlying Lean modules and the two papers already cited in-text; any section that cannot reach bar quality within budget gets a TBC marker instead of thin prose (report 2.4 principle) |
| Factual caveats silently dropped during rewrites (validity_decidable, countermodels #1/#8/#9, TM_c/TM_dc) | H | M | Guardrails G2, G4, G7 are explicit grep-plus-read checks in the phases touching those files and in Phase 7 |

## Voice Contract (governs all phases)

Phase 1 finalizes this contract; Phases 2-6 apply it; Phase 7 audits against it.

**Banned in rendered prose** (mechanically greppable; zero hits allowed outside whitelisted locations):
1. `honest` / `honestly` / `honesty` (any case, any inflection)
2. `in progress` (formalization/proof status narration)
3. Task-number references: `task 3[0-9][0-9]`, `tasks 30[0-9]`, `(task N)` forms
4. `earlier revision`, `earlier documentation`, `stale`
5. `discrepanc` (any inflection: discrepancy, discrepancies)
6. `silently` (as in "not silently repeated/dropped")
7. `stated openly`, `stated plainly`, `reported honestly`, `rounded up`
8. Self-referential normativity: `this book claims nothing stronger`, `the book's normative account`, `this chapter does not overstate`

**Review-flag list** (manual judgment, not hard-banned): `future work` (allowed only when attributing a statement to a cited paper, never for this repository's own roadmap), `sorry` in prose (allowed in neutral machine-appendix/status exposition; banned in confessional framing like "not yet sorry-free"), `frontier` (allowed as mathematical terminology).

**Whitelisted locations** (banned patterns may appear; audit excludes them):
- `chapters/p3-decidability-frontier.typ` lines 1-13 (EMBARGO header) and the three `// SLOT-IN:` comment blocks (contain "task 313"/"task 318")
- `generated/**` (never hand-edited)
- `// TO BE CONTINUED:` comment lines (may name tasks/remaining work concretely)
- `template.typ` (out of scope)

**Positive idioms**:
- Open mathematics -> neutral open-problem statement: "The completeness of TM with respect to F is an open problem." / "remains open." Finished books state open problems; they do not confess incompleteness. This applies to: TM completeness (dense chronicle coherence, discrete transfer, FMP semantic-validity bridge), metaphysical-modality completeness, CL/CML/CTL completeness, Kamp expressive-completeness.
- Unwritten book content -> body marker `_TO BE CONTINUED..._` (emphasized text) plus an adjacent typst comment `// TO BE CONTINUED: <concrete description of what remains>`. Every body marker must have a matching comment.
- Paper-vs-formalization relationships -> direct positive statements of what each side proves, without narrating how the alignment was verified.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 5, 6 | 1 |
| 3 | 7 | 2, 3, 4, 5, 6 |

Phases within the same wave can execute in parallel (file sets are disjoint). For a single implementer, sequential execution in numeric order is recommended; if executed in parallel, run the repo-wide gates once per wave rather than racing them per phase.

**Per-phase gate protocol** (applies to every phase; listed once here, referenced as "GATES" below):
1. START: run `typst compile Theories/Bimodal/typst/BimodalReference.typ` and `bash scripts/typst-sync-check.sh`. If sync Check 2/3 fails at START, the failure is inherited Lean drift: regenerate with `bash scripts/typst-status-counts.sh` / `bash scripts/typst-machine-appendix.sh`, commit that regeneration separately, and re-run the gate before editing.
2. END: both commands again; `typst compile` must exit 0, sync check must PASS all checks.
3. END: scoped banned-pattern grep over the phase's files: `grep -rniE 'honest|in progress|task 3[0-9][0-9]|earlier revision|discrepanc|silently|stated openly|claims nothing stronger' <phase files>` must return 0 hits outside whitelisted locations.
4. END: `git diff --name-only` must contain no `generated/` paths (except a sanctioned START regeneration committed separately) and no `template.typ`.

---

### Phase 1: Voice contract + front matter [COMPLETED]

**Goal**: Finalize the voice contract above and apply it to the book's front matter, establishing the tone that all later phases match.

**Tasks**:
- [x] Review the Voice Contract section of this plan against the actual front-matter text; record any needed refinements as edits to the working copy of the contract in the implementation summary (contract deviations must be justified, not silent).
- [x] `BimodalReference.typ:137` (abstract): rewrite "completeness is stated and wired through a canonical-model construction for each frame class, with its proof in progress and the remaining gaps stated openly" — state what is proven; state completeness's open steps as open problems (guardrail G1: never assert completed completeness).
- [x] `BimodalReference.typ` part-divider texts (lines ~169-246 region): sweep for hedging/status narration; rewrite to neutral descriptions of each part's content.
- [x] `00-introduction.typ:21-22`: replace "It is deliberately *not* described here as ... (see @sec:notes for the full discrepancy note)" and "The accurate way to state the relationship is ... never as a description of what is formalized" with direct positive exposition of the paper-vs-formalization relationship.
- [x] `00-introduction.typ:110`: neutralize "completeness (stated and wired through a canonical-model construction; proof in progress)".
- [x] `00-introduction.typ:98-101`: re-check the roadmap paragraph against the final Part I-IV structure (report Section 1 note); correct any drift.
- [x] `00-introduction.typ`: modest expansion toward a proper book introduction (currently 112 lines, thin-ish): motivate TM, preview the parts, orient the reader; target ~140-160 lines.
- [x] Run GATES.

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/typst/BimodalReference.typ` - abstract line 137, part-divider prose
- `Theories/Bimodal/typst/chapters/00-introduction.typ` - lines 21-22, 98-101, 110; expansion

**Verification**:
- GATES pass.
- `grep -niE 'honest|in progress|discrepanc|stated openly' Theories/Bimodal/typst/BimodalReference.typ Theories/Bimodal/typst/chapters/00-introduction.typ` returns 0 hits.
- G1 spot-check: neither file asserts a completed/formalized completeness theorem (`grep -niE 'completeness' both files` and read every hit).

---

### Phase 2: Part I core tone pass [COMPLETED]

**Goal**: Rewrite all status-narration and hedging in the six core Part I / back-matter chapters into neutral exposition. Mostly rewrites, little expansion.

**Tasks**:
- [x] `01-syntax.typ`, `02-semantics.typ`, `05-theorems.typ`: full read-through tone sweep (no specific hits inventoried; apply Voice Contract; fix anything matching banned patterns).
- [x] `03-proof-theory.typ:217`: rewrite "TM_c ... and combined TM_dc are not yet formalized as frame classes" as neutral fact (e.g., "TM_c and TM_dc are treated as paper-side extensions"); factual content must survive (guardrail G7).
- [x] `03-proof-theory.typ:221`: rephrase "Several schemata that were primitive axioms in earlier revisions of this system..." away from revision-narrative while keeping the legitimate system-history content (axioms now derived).
- [x] `04-metalogic.typ:18`: restate "its proof is *not yet sorry-free*: the remaining gaps are localized..." as: the completeness argument has open steps in the chronicle construction (dense case) and discrete transfer — neutral open-problem idiom (G1).
- [x] `04-metalogic.typ:113-117`: retitle `=== Status and Work in Progress` (e.g., "Open Steps in the Completeness Argument"); rewrite "is in progress (tasks 303, 309--311) and should not be cited as a settled result" dropping task numbers; state openness neutrally.
- [x] `04-metalogic.typ:156-160` (`== Implementation Status`): neutralize "with its proof still in progress"; merge into surrounding exposition where natural.
- [x] `04-metalogic.typ:164` footnote: drop "(task 93). An earlier revision of this manual described a reflexive convention; that description was stale." — keep only the current convention, stated positively.
- [x] `06-notes.typ:21`: retitle `== Discrepancy Notes` (e.g., "Relation to the Published Presentation") and rewrite register entries as neutral paper-vs-formalization notes.
- [x] `06-notes.typ:19`: neutralize "with its proof in progress ... with the FMP path under active development" (G1).
- [x] `06-notes.typ:37-39`: rewrite the "Discrepancy correction (task 313 Phase 7)" entry — state directly what `lift_derivation_qfree` is and is not; keep the factual negative as neutral: the paper's conservativity theorem is a paper-side result (G7).
- [x] `06-notes.typ:80`: neutralize "Ongoing work on the discrete case (... tasks 303 and 309--311) is in progress and not citable as settled"; drop task numbers.
- [x] `06-notes.typ:86`: neutralize "(resolved against live source, task 313 Phase 8 ...) ... remains open and unwired, not sorry-tainted"; keep the mathematical openness (G1).
- [x] Opportunistic: clean non-rendering file-header sync comments ("Synced against live Lean source ... 2026-07-06") in 01/03/04/06 (low priority; rendered prose first).
- [x] Run GATES.

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/typst/chapters/01-syntax.typ` - tone sweep
- `Theories/Bimodal/typst/chapters/02-semantics.typ` - tone sweep
- `Theories/Bimodal/typst/chapters/03-proof-theory.typ` - lines 217, 221
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - lines 18, 113-117, 156-160, 164 (heaviest)
- `Theories/Bimodal/typst/chapters/05-theorems.typ` - tone sweep
- `Theories/Bimodal/typst/chapters/06-notes.typ` - lines 19, 21, 37-39, 80, 86

**Verification**:
- GATES pass; scoped banned-pattern grep over the six files returns 0 hits.
- G1: no file asserts sorry-free/completed TM completeness (read every `completeness` hit in 04-metalogic and 06-notes).
- G7: TM_c/TM_dc not-formalized fact and conservativity-theorem paper-side fact still present in neutral form (`grep -n 'TM_c\|TM_dc\|conservativ' 03-proof-theory.typ 06-notes.typ` and read).
- No section labels removed (compile catches dangling `@sec:` refs).

---

### Phase 3: Part I thin chapters — rewrite + expand [COMPLETED]

**Goal**: Bring the four thin Part I chapters up to bar quality: dissolve status-resolution narratives into direct exposition and expand with worked examples, cross-references, and definitional completeness sourced from the underlying Lean modules and the two papers already cited in-text.

**Tasks**:
- [x] `p2-frame-classes.typ` (100 -> ~180+ lines):
  - [x] Line 55: drop "*Discrepancy from the plan's initial source mapping*"; state the file locations directly.
  - [x] Line 66: remove "tracked here rather than silently repeated" framing; move the stale-doc-comment fact to a footnote or drop it.
  - [x] Line 71: neutral restatement of "remains future work until a `Complete`-style typeclass ... are added" (factual: the Completeness property is not formalized — G7).
  - [x] Lines 92, 99: collapse the postmortem-rule/discrepancy-register narration into a single neutral statement of what `lift_derivation_qfree` is and is not.
  - [x] Expand: per-frame-class exposition (definitions, characteristic axioms, examples) from the Lean `Semantics/` frame-class modules.
- [x] `p2-decidability-practice.typ` (83 -> ~180+ lines):
  - [x] Lines 19-32: dissolve the `== FMP Status Resolution` README-dispute narrative into direct exposition: state `fmp_completeness` precisely (theorem content at lines 26-31 keeps); state the open semantic-validity bridge as an open problem (G4).
  - [x] Line 14 chapter description: rewrite "followed by an honest account of what is and is not proven about it".
  - [x] Line 54: retitle `== Honest Metatheory` (e.g., "Metatheory" or "Correctness Properties").
  - [x] Lines 56-59: keep the factual bullets; keep the `validity_decidable` classical-tautology caveat in neutral documentation register (G4 — this caveat prevents overclaiming and must survive).
  - [x] Expand: worked tableau example and complexity discussion from the tableau Lean modules.
- [x] `p3-ltl-to-tm.typ` (94 -> ~150+ lines):
  - [x] Lines 3, 14: retitle chapter from "From LTL to TM: Honest Positioning" to "From LTL to TM"; the label `<sec:ltl-to-tm>` MUST stay (cross-referenced).
  - [x] Line 93: rewrite "On the Lean side, honesty requires the finer statement..." as a plain factual statement of what `ConservativeExtension/` proves.
  - [x] Expand: the embedding's definition and worked translation examples.
- [x] `p3-vlach-blstar.typ` (110 -> ~160+ lines):
  - [x] Lines 107-110 (`== The Formalization Frontier`): rewrite "Work toward a Kamp-style expressive-completeness theorem is in progress ... not sorry-free ... should not be cited as settled" as a neutral open-problem statement of the Kamp-style theorem; if the section is meant to eventually present the theorem, add TBC marker + `// TO BE CONTINUED:` comment instead (decide per Voice Contract distinction: open mathematics = open problem; unwritten presentation = TBC).
  - [x] Expand: Vlach operators and BL* exposition with examples.
- [x] Any expansion target that cannot reach bar quality within this phase's budget: place a TBC marker + comment rather than thin prose.
- [x] New backticked tokens introduced by expansion: verify each resolves in Lean source before writing it; whitelist additions only for genuinely external names.
- [x] Run GATES.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/typst/chapters/p2-frame-classes.typ` - lines 55, 66, 71, 92, 99; expansion
- `Theories/Bimodal/typst/chapters/p2-decidability-practice.typ` - lines 14, 19-32, 54, 56-59; expansion
- `Theories/Bimodal/typst/chapters/p3-ltl-to-tm.typ` - lines 3, 14, 93; expansion
- `Theories/Bimodal/typst/chapters/p3-vlach-blstar.typ` - lines 107-110; expansion

**Verification**:
- GATES pass; scoped banned-pattern grep over the four files returns 0 hits (in particular zero `honest` hits — this phase clears 4 of the 9 inventoried occurrences).
- Label check: `grep -c 'sec:ltl-to-tm' Theories/Bimodal/typst/chapters/p3-ltl-to-tm.typ` >= 1 and compile succeeds (cross-refs intact).
- G4: `grep -n 'validity_decidable\|fmp_completeness' p2-decidability-practice.typ` — both present, caveats intact on read.
- Every TBC body marker added has a matching `// TO BE CONTINUED:` comment.
- Line-count spot check against targets (soft targets; quality over count, TBC where short).

---

### Phase 4: p3-decidability-frontier surgical pass [COMPLETED]

**Goal**: Smallest possible diff to this embargo-constrained file: fix the self-referential clause and tone spots in rendered prose while byte-preserving the EMBARGO header and all three SLOT-IN comment blocks.

**Tasks**:
- [x] Record pre-edit protected-block content: `git show 9d85e4ec0:Theories/Bimodal/typst/chapters/p3-decidability-frontier.typ | sed -n '1,13p'` and the awk SLOT-IN extraction (see Verification) saved to the scratchpad for comparison.
- [x] Line 87: rewrite the self-referential editorial "@sec:decidability-practice states this resolved status precisely, and that wording -- not any paraphrase -- is the book's normative account" into a plain cross-reference sentence.
- [x] Tone sweep of remaining body prose (lines 14-88 excluding SLOT-IN blocks) per Voice Contract.
- [x] Line 55: "That is an expectation, not a theorem -- no result about the tower is stated or attributed here" — load-bearing for the embargo; may be lightly rephrased but the no-attribution meaning MUST be preserved verbatim in force (G3).
- [x] Optional modest expansion using PUBLISHED literature only (existing citation set: @sistlaClarke1985, @marx1999, @hirschHodkinsonKurucz2002, etc.); absolutely no Lk-specific results, no new attributions to unpublished work (G3).
- [x] NEVER edit: lines 1-13; any line beginning `// SLOT-IN:`; any continuation line inside the three SLOT-IN comment blocks (currently at 57-60, 67-71, 78-81 — positions may shift, content may not).
- [x] Run GATES.

**Timing**: 0.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/typst/chapters/p3-decidability-frontier.typ` - line 87 + body tone spots ONLY

**Verification** (byte-preserve check — FAIL THE PHASE if any diff is non-empty):
- Header (positions fixed at file top):
  `diff <(git show 9d85e4ec0:Theories/Bimodal/typst/chapters/p3-decidability-frontier.typ | sed -n '1,13p') <(sed -n '1,13p' Theories/Bimodal/typst/chapters/p3-decidability-frontier.typ)` — must be empty.
- SLOT-IN blocks (content-based, position-independent):
  `diff <(git show 9d85e4ec0:Theories/Bimodal/typst/chapters/p3-decidability-frontier.typ | awk '/^\/\/ SLOT-IN:/{f=1} f && /^\/\//{print; next} {f=0}') <(awk '/^\/\/ SLOT-IN:/{f=1} f && /^\/\//{print; next} {f=0}' Theories/Bimodal/typst/chapters/p3-decidability-frontier.typ)` — must be empty.
- Fallback if HEAD advanced past 9d85e4ec0 without touching this file: substitute `HEAD` for the pinned SHA after confirming `git log --oneline 9d85e4ec0..HEAD -- Theories/Bimodal/typst/chapters/p3-decidability-frontier.typ` shows only this phase's commits.
- G3: `git diff 9d85e4ec0 -- Theories/Bimodal/typst/chapters/p3-decidability-frontier.typ` reviewed line-by-line: no new citation keys beyond the published set, no Lk result stated or attributed, the line-55 no-attribution sentence's meaning intact.
- GATES pass; scoped banned-pattern grep over rendered prose (excluding the four whitelisted comment blocks) returns 0 hits.

---

### Phase 5: Part II expansion [COMPLETED]

**Goal**: Heaviest expansion phase — bring the three thinnest chapters in the book up to bar quality, deleting repo-documentation meta-commentary and reclaiming the space for real exposition.

**Tasks**:
- [x] `p4-proof-automation.typ` (61 -> ~180+ lines):
  - [x] Line 15: rewrite chapter description "...an honest account of what is wired to what".
  - [x] Line 23: drop "*Discrepancy from the plan's initial source mapping*"; state locations directly.
  - [x] Line 27: keep the doc/implementation-gap fact; drop "noted here rather than glossed over".
  - [x] Lines 28, 39-41: rewrite "contrary to `Automation/README.md`'s usage example ... which is stale" and "*Discrepancy*: ..." as direct statements of current behavior.
  - [x] Line 55: rewrite the "*Status note*" — drop task numbers 303/309-311 and the "does not overstate" self-defense; state the module's role neutrally.
  - [x] Lines 57-61: DELETE `== A Note on Automation/README.md Staleness` (repo-documentation meta-commentary, not book content); at most a one-line footnote survives.
  - [x] Expand: real exposition of the proof-search engine and tactics from the `Automation/` Lean modules (architecture, search strategy, worked invocation examples).
- [x] `p4-dataset-pipeline.typ` (90 -> ~160+ lines):
  - [x] Line 15: rewrite chapter-header description "...and the honest Tier-2 response".
  - [x] Line 50: retitle `== The Tier-1 Feasibility Gate: Honest Results` -> "The Tier-1 Feasibility Gate".
  - [x] Line 70 caption: keep the factual "gate decision *FAILED*, 3 of 6 hard criteria not met"; drop "-- reported honestly, not rounded up".
  - [x] Line 31: neutral restatement of "*Enriched corrective signal (not yet wired)*" — either roadmap prose or TBC marker (decide per Voice Contract).
  - [x] Line 36: rewrite the six-vs-seven-modules "*Discrepancy noted, not silently repeated*" — just say seven modules and cite.
  - [x] Lines ~74-80 (Tier-2 section): "Both are future work relative to this book..." — genuine content gap: either neutral "the pipeline's second tier comprises..." roadmap prose or TBC marker + `// TO BE CONTINUED:` comment naming the theorem-mining generator and enriched-signal wiring.
  - [x] Expand: pipeline-stage exposition with concrete data examples from the pipeline modules/docs.
- [x] `p4-dual-verification.typ` (62 -> ~160+ lines):
  - [x] Lines 22, 30, 62: consolidate the triple "architectural vision, not a claim about this repository" disclaimer into ONE neutral statement (the fact must survive exactly once — it is a guardrail against overclaiming, G6-adjacent; the repetition is the defect, not the content).
  - [x] Line 57: rewrite "*Discrepancy, stated rather than repeated*: `Examples/README.md` describes ... but the live file only ..." as a direct description of what the file contains.
  - [x] Expand: worked examples from `Examples/` showing the verification workflow; if the ModelChecker cross-verification run is meant to eventually appear, TBC marker; otherwise present the architecture neutrally.
- [x] New backticked tokens: verify each resolves (or whitelist external Logos names only).
- [x] Any target not reachable at bar quality: TBC marker, not thin prose.
- [x] Run GATES.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/typst/chapters/p4-proof-automation.typ` - lines 15, 23, 27, 28, 39-41, 55, 57-61; expansion
- `Theories/Bimodal/typst/chapters/p4-dataset-pipeline.typ` - lines 15, 31, 36, 50, 70, 74-80; expansion
- `Theories/Bimodal/typst/chapters/p4-dual-verification.typ` - lines 22, 30, 57, 62; expansion

**Verification**:
- GATES pass; scoped banned-pattern grep over the three files returns 0 hits (this phase clears the remaining `honest` occurrences: p4-dataset-pipeline 15/50/70, p4-proof-automation 15).
- The "architectural vision" fact appears exactly once in p4-dual-verification.typ (`grep -c 'architectural' ...` == 1, read to confirm the no-claim meaning survives).
- The Tier-1 FAILED gate result is still reported as FAILED (fact preserved: `grep -n 'FAILED' p4-dataset-pipeline.typ`).
- Every TBC body marker has a matching `// TO BE CONTINUED:` comment.
- No nonexistent local Lean theorem asserted: every new backticked token resolved by sync Check 1 (G6).

---

### Phase 6: Parts III-IV light pass + notation [COMPLETED]

**Goal**: Fix the latent overclaim in p5-counterfactual, neutralize the remaining self-positioning in the two strongest chapters, and do comment hygiene on notation files.

**Tasks**:
- [x] `p5-counterfactual.typ:482` — ACCURACY FIX (direction opposite to overclaiming): the sentence "the bimodal logic of Parts I--II has a completeness theorem, formalized in Lean" overstates. Rewrite the Part-I contrast accurately: soundness is formalized in Lean; the completeness argument has open steps (neutral open-problem idiom). Never assert a Lean-formalized completeness theorem (G1).
- [x] `p5-counterfactual.typ:481`: keep the mathematical facts ("states the completeness of appropriate extensions as future work" — attribution to the paper is fine); drop the self-positioning clause "this book claims nothing stronger".
- [x] `p5-counterfactual.typ:502-504`: rewrite "*Formalization status.* To close where the chapter began: none of this chapter is formalized in this repository..." into a short neutral "Sources and formal status" paragraph, stated once; the facts MUST survive: proofs are paper-side; completeness of *CL*, *CML*, *CTL* is open everywhere (G1).
- [x] `p5-counterfactual.typ:353` — GUARDRAIL, verify untouched or meaning-preserved: "The paper presents fully interpreted countermodels for #1, #8, and #9, and disposes of #11 and #12 by argument; the remaining schemata are recorded as invalid without worked models" (G2). Do not upgrade any countermodel's status.
- [x] `p5-counterfactual.typ:19, 294, 329-331`: verify the derived-soundness-only posture of metaphysical modality survives any tone edits (G1: derived, soundness at characteristic-schemata strength; completeness genuinely open).
- [x] `p5-constitutive.typ:26-27`: keep the fact "no local Lean development" but state it once in neutral register (external Logos names remain cited-as-external per whitelist).
- [x] `p5-constitutive.typ`: light tone sweep (chapter is strong; minimal edits).
- [x] `notation/bimodal-notation.typ`, `notation/constitutive-notation.typ`, `notation/shared-notation.typ`: comment hygiene only; NO change to the `#let tuple(..args)` definition at shared-notation.typ:44 (pre-existing warning must not become an error).
- [x] Opportunistic: clean non-rendering file-header draft-narration comments in p5-* files.
- [x] Run GATES.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/typst/chapters/p5-counterfactual.typ` - lines 481-482 (overclaim fix), 502-504; guardrail checks at 19, 294, 329-331, 353
- `Theories/Bimodal/typst/chapters/p5-constitutive.typ` - lines 26-27; light sweep
- `Theories/Bimodal/typst/notation/*.typ` - comment hygiene only

**Verification**:
- GATES pass; scoped banned-pattern grep returns 0 hits.
- G1 (the headline check): `grep -niE 'completeness[^.]{0,80}formali[sz]ed in Lean' Theories/Bimodal/typst/chapters/*.typ Theories/Bimodal/typst/*.typ` returns 0 hits; read every remaining `completeness` mention in p5-counterfactual.typ to confirm no Lean-formalized completeness is asserted anywhere.
- G2: countermodel sentence at (former) line 353 intact in meaning — only #1/#8/#9 fully interpreted, #11/#12 by argument, rest recorded invalid without worked models.
- `typst compile` warning count not increased (the shared-notation.typ:44 warning may remain; no new warnings become errors).

---

### Phase 7: Final gates + adversarial re-audit [COMPLETED]

**Goal**: Prove the primary directive holds book-wide: both gates green, zero banned patterns outside whitelisted locations, all guardrails intact, byte-preserve confirmed end-to-end, per-chapter quality assessment written.

**Tasks**:
- [x] Full gates: `typst compile Theories/Bimodal/typst/BimodalReference.typ` exits 0; `bash scripts/typst-sync-check.sh` passes ALL checks.
- [x] Adversarial banned-pattern audit over the whole corpus:
  `grep -rniE 'honest|in progress|task 3[0-9][0-9]|task [0-9]{2,3}|earlier revision|discrepanc|silently|stated openly|rounded up|claims nothing stronger|normative account|does not overstate|stale' Theories/Bimodal/typst/ --include='*.typ'` — every hit must be inside a whitelisted location (p3-decidability-frontier.typ EMBARGO header / SLOT-IN blocks, `generated/**`, `// TO BE CONTINUED:` comment lines, template.typ). Zero hits in rendered prose. Any residual hit -> fix and re-run until clean.
- [x] Review-flag audit (manual read of each hit): `grep -rniE 'future work|sorry' Theories/Bimodal/typst/chapters/ Theories/Bimodal/typst/BimodalReference.typ` — each surviving occurrence must be either paper-attribution ("future work" in a cited paper's own terms) or neutral status exposition; no confessional framing.
- [x] TBC consistency: enumerate all body `TO BE CONTINUED` markers and all `// TO BE CONTINUED:` comments; confirm a 1:1 pairing and that each comment names concretely what remains.
- [x] Guardrail sweep G1-G7 (final):
  - [x] G1: no assertion of formalized/completed TM completeness, metaphysical-modality completeness, or CL/CML/CTL completeness anywhere (grep + read as in Phase 6).
  - [x] G2: countermodels #1/#8/#9 claim intact in p5-counterfactual.typ.
  - [x] G3: byte-preserve re-check (both diff commands from Phase 4, run against the final tree) empty; no Lk citation/attribution in p3-decidability-frontier.typ.
  - [x] G4: `validity_decidable` classical-tautology caveat and `fmp_completeness` open-bridge caveat present in p2-decidability-practice.typ.
  - [x] G5: `git diff 9d85e4ec0..HEAD --name-only` shows no `generated/` edits other than sanctioned regeneration commits and no `template.typ` edits.
  - [x] G6: sync Check 1 green (every backticked token resolves or is whitelisted); review `git diff` of `sync-check-whitelist.txt` — additions are external names only.
  - [x] G7: TM_c/TM_dc paper-side fact and conservativity-theorem paper-side fact present in neutral form.
- [x] PDF spot-check: compile output opened/inspected for the retitled headings ("From LTL to TM", "The Tier-1 Feasibility Gate", the 06-notes retitle, 04-metalogic retitle) and working cross-references.
- [x] Write the per-chapter quality assessment for the final task summary: a table with columns Chapter | Lines before | Lines after | Depth rating (bar / near-bar / TBC-flagged) | Banned-pattern hits removed | TBC markers | Notes. REQUIRED in the implementation summary.
- [x] Run GATES one final time after any residual fixes.

**Timing**: 1 hour

**Depends on**: 2, 3, 4, 5, 6

**Files to modify**:
- Residual fixes only (any file flagged by the audit)
- `specs/323_review_and_revise_bimodalreference_uniform_standard/summaries/01_editorial-uniform-standard-summary.md` - per-chapter quality assessment (created at implementation wrap-up)

**Verification**:
- Both gates green on the final tree.
- Banned-pattern audit: 0 hits outside whitelisted locations (paste the grep output into the summary as evidence).
- All G1-G7 checks pass and are recorded in the summary.
- Per-chapter quality assessment table present in the summary.

## Testing & Validation

- [x] `typst compile Theories/Bimodal/typst/BimodalReference.typ` exits 0 after every phase and at end.
- [x] `bash scripts/typst-sync-check.sh` passes all checks after every phase and at end (490-candidate baseline; count may grow with expansion, violations must stay 0).
- [x] Byte-preserve diffs (Phase 4 commands) empty at Phase 4 end and at Phase 7.
- [x] Corpus-wide banned-pattern grep returns 0 hits outside whitelisted locations (Phase 7).
- [x] Guardrails G1-G7 verified and recorded.
- [x] Every TBC body marker paired 1:1 with a `// TO BE CONTINUED:` comment.
- [x] PDF spot-check of retitled headings and cross-references.

## Artifacts & Outputs

- `specs/323_review_and_revise_bimodalreference_uniform_standard/plans/01_editorial-uniform-standard.md` (this plan)
- Revised corpus under `Theories/Bimodal/typst/` (all chapters, front matter, notation prose)
- `specs/323_review_and_revise_bimodalreference_uniform_standard/summaries/01_editorial-uniform-standard-summary.md` with the per-chapter quality assessment table and audit evidence
- Possibly: minimal additions to `Theories/Bimodal/typst/sync-check-whitelist.txt` (external names only)
- Per-phase git commits: `task 323 phase {P}: {phase name}`

## Rollback/Contingency

- Each phase is committed independently after its gates pass; a failed phase is reverted by discarding only that phase's uncommitted edits (snapshot first via `bash .claude/scripts/git-snapshot.sh` per git-workflow rules) — earlier green phases are untouched.
- If Phase 4's byte-preserve check fails: restore `p3-decidability-frontier.typ` from `git show 9d85e4ec0:...` (after snapshot), re-apply only the line-87/body-prose edits, re-verify.
- If sync Checks 2/3 fail from inherited Lean drift at any point: regenerate with `scripts/typst-status-counts.sh` / `scripts/typst-machine-appendix.sh` and commit separately; never hand-edit `generated/`.
- If an expansion cannot converge on bar quality: replace with TBC marker + comment and record it in the quality assessment — do not ship thin filler and do not block the task.
- Full rollback: `git revert` of the task's commit range (commits are scoped to this task's files, so revert is clean).
