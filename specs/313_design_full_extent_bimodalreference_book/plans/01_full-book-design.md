# Implementation Plan: Full-Extent BimodalReference Book (Skeleton)

- **Task**: 313 - design_full_extent_bimodalreference_book
- **Status**: [IN PROGRESS]
- **Effort**: 26 hours (skeleton plan; follow-up tasks carry ~22 additional hours)
- **Dependencies**: None (task 312 complete at commit `a883361bf`)
- **Research Inputs**:
  - specs/313_design_full_extent_bimodalreference_book/reports/01_team-research.md (synthesis)
  - specs/313_design_full_extent_bimodalreference_book/reports/01_teammate-{a,b,c,d}-findings.md
- **Artifacts**: plans/01_full-book-design.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-formats.md; state-management.md
- **Type**: typst
- **Session**: sess_1783397654_de90e8
- **Mode**: hard (H3 source mapping, H7 territory contracts, H8 phase sizing, skeleton per Stage 4a)

## Overview

Transform `Theories/Bimodal/typst/BimodalReference.typ` (currently a ~1,880-line synced
reference core, chapters 00-06) into the five-part living monograph designed by the task-313
team research: Part I Motivation & Positioning, Part II The Bimodal Core (lean-verified),
Part III Expressive Power & Its Price, Part IV Automated & Neural Reasoning, Part V Toward
the Logos. The primary audience is **AI-training practitioners** (user decision 1): decidable
fragments, the dataset pipeline, dual verification, and machine-readable appendices lead;
philosophical motivation serves that audience. This plan is a **skeleton** (per H8 escape
valve): it lands the four infrastructure preconditions, the five-part scaffolding, the
rewritten introduction, Part II's two new chapters, and Part IV's three chapters — everything
lean-verified or promotable from existing docs. Parts I(motivation)/III/V, the machine-readable
appendix, and the post-TACAS Lk slot-in are deferred to five follow-up tasks
(314-318) declared in `.skeleton-return.json`. Definition of done for
this plan: `typst compile` green, `typst-sync-check.sh` green, every new chapter carrying a
sync-class banner, deferred chapters present as stub division points, SYNC-MAP re-stamped.

### Fixed User Decisions (constraints, not open questions)

1. **Audience**: AI-training practitioners primary. Part IV lands early (in this plan);
   deep philosophical motivation (paper §1-§2) is follow-up 314.
2. **Lk embargo — abstract, no citation**: The Decidability Frontier chapter (follow-up
   315) cites NO Lk-specific results (no BL⋆-ladder table, no L_k complexity
   theorems attributed) until TACAS acceptance; it is structured with named slot-in anchors
   so 318 can insert Lk content without renumbering.
3. **Ownership**: BimodalReference OWNS the Logos roadmap and constitutive/counterfactual
   exposition (full adapted chapters, propositional restriction — 317);
   LogosManual will link to this book.
4. **Text reuse**: Adapt freely with citation (private research artifact; revisit before
   any publication).

### Research Integration

Integrates 01_team-research.md (consolidated 5-part shape, 4 preconditions, 4 resolved
conflicts) and all four teammate findings: A's 24-row source→chapter table (H3 base),
B's template-port inventory + 9-item counterfactual staging + 4 divergence resolutions,
C's six postmortem corrections (all mandatory below), D's living-monograph shape, R6
sequencing, and R5 creative additions.

### Preserved Assets

The following work is complete and must not regress. Task 312 established the SYNC-MAP
verified-reference contract; every phase in this plan extends it, none may dilute it.

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| SYNC-MAP claim-verification contract (271 resolved Lean names, zero stale) | Theories/Bimodal/typst/SYNC-MAP.md | [COMPLETED] task 312 | 2026-07-06, commit a883361bf |
| Synced chapters 00-06 (~1,560 lines, accurate at a883361bf) | Theories/Bimodal/typst/chapters/00-06*.typ | [COMPLETED] task 312 | 2026-07-06 |
| Honest metalogic/decidability status prose ("should not be cited as a settled result") | chapters/04-metalogic.typ, chapters/06-notes.typ | [COMPLETED] task 312 | 2026-07-06 |
| Strict/irreflexive semantics documentation (task 93 convention) | chapters/02-semantics.typ, 06-notes.typ | [COMPLETED] | 2026-07-06 |
| Ground-truth counts methodology (42 constructors/8 layers, 7 rules, 43 sorries, "do not copy forward") | SYNC-MAP.md Phase 1 section | [COMPLETED] task 312 | 2026-07-06 |
| Compiling book (`typst compile` exit 0) | BimodalReference.typ | [COMPLETED] | 2026-07-06 |

Restructuring rule: existing chapter content may be *moved* (e.g., decidability material out
of 04-metalogic into the new Part II chapter) but never deleted-without-destination, and every
moved Lean-name claim keeps its verified status. Chapters 00-06 keep their filenames.

## Postmortem Constraints

Binding rules for all implementation dispatches (and inherited by all follow-up tasks).
Derived from teammate C's critic findings, task-312 lessons, and user decisions. No prior
failed attempts exist for this task; rules derive from research risk factors.

**Do NOT**:
- **Never hand-copy sorry/status counts into prose.** All counts (sorries, axiom
  constructors, rules, theorem tallies) come from the Phase 2 generator output
  (Boneyard excluded, commit-stamped) or are replaced by structural statements. A
  hand-typed number is a defect. (C-F4; counts are method-dependent: 38/43/~53.)
- **Never describe TM as "vanilla LTL + S5" (or LTL+S5+Vlach) as if it were the
  formalized system.** TM is Until/Since temporal logic over linear orders (ℤ/ℚ), fused
  with S5 plus load-bearing interaction (MF) and uniformity axiom layers over task frames.
  LTL+S5+Vlach is the *extension roadmap only* (TM → TM⁺ → BL⋆ tower), always explicitly
  marked unformalized. The PTL×S5 identification belongs to Lk's L₁ over trace sets — a
  different logic; never import it as a description of TM. (C-F1, synthesis conflict 1.)
- **Never present decidability as a settled asset.** `validity_decidable`
  (`Metalogic/Decidability/Correctness.lean:72`) is literally `Classical.em` — vacuous;
  there is no `Decidable` instance; `decide` is fuel-based with a timeout branch; tableau
  soundness is proven but the semantic completeness link runs through the sorry-tainted
  chain. Decidability is a program to *report on*. (C-F4.)
- **Never place a `lean-verified` (✓) label on paper-sourced (○) or outlook (◇) chapters
  or claims.** The Phase 4 sync-check enforces this mechanically. (C-F3, D-F4.)
- **Never write an unresolvable backticked Lean name.** SYNC-MAP discipline extends to
  every new chapter: every backticked Lean identifier/path must resolve under
  `Theories/Bimodal/` (excluding `Boneyard/`) at the stamped commit. External-repo (Logos)
  references are cited as external, commit-pinned, never as local names. (Task 312 contract.)
- **Never state the FMP status without first resolving the discrepancy**:
  `Metalogic/Decidability/README.md` says all modules incl. `FMP/` sorry-free;
  `04-metalogic.typ:260` says "Tableau FMP — In progress" (`fmp_completeness`,
  `Correctness.lean:123`, is stated over closure MCS bundles, not semantic validity).
  Phase 8 resolves this against `Correctness.lean` before any chapter states either. (C/A flag.)
- **Never cite, attribute, or lift Lk-specific results** (BL⋆-ladder table, L_k complexity
  theorems, hardware case study) anywhere in the book until TACAS acceptance
  (user decision 2; Lk is an anonymous double-blind submission — deanonymization risk).
- **Never duplicate content this plan promotes.** `docs/training/PIPELINE.md` content is
  *moved and cited* into the Part IV chapter (D-R4), leaving a pointer; do not maintain
  two divergent copies. Same for LogosManual: link, don't fork exposition owned there.

**MUST preserve**:
- All rows of the Preserved Assets table above (271-name resolution, honest status prose,
  strict-semantics documentation, compiling build).
- The `06-notes.typ` discrepancy-notes register — new chapters route their own
  discrepancies there or to per-chapter notes, never silently drop them.

**Design decisions are SETTLED** (do not re-open without concrete counterexample):
- Five-part living monograph with per-chapter sync-class legend
  (✓ lean-verified / ⧖ with-sorries / ○ paper-sourced / ◇ outlook-planned) — synthesis
  consolidated shape; all four teammates converged on it.
- Preconditions land before any content expansion (synthesis preconditions 1-4).
- Part IV before Part III (audience decision 1 overrides D-R6's original order for this pair).
- Part V last, full adapted chapters owned here (user decisions 3-4).
- New chapter files use part-based prefixes (`p2-*.typ`, `p4-*.typ`, ...); existing 00-06
  filenames unchanged; include order in `BimodalReference.typ` is authoritative for book
  order (renumber-proof, required by decision 2's slot-in constraint).
- The book stays propositional; FOL generalization is pointed to LogosManual (B-F5.3).

## Goals & Non-Goals

- **Goals**:
  - Land the four infrastructure preconditions (status legend, drift detector, scripted
    counts, template port) before any content growth.
  - Restructure the book into the five-part scaffold with sync-class banners and stub
    division points for deferred chapters.
  - Write the AI-practitioner-led introduction, Part II's two new lean-verified chapters
    (Frame Classes & Extensions; Decidability in Practice), and Part IV's three chapters
    (Proof Automation; BMLogic Dataset Pipeline; Dual Verification & Worked Examples).
  - Declare follow-up tasks for Part I motivation, Part III, Part V, the machine-readable
    appendix, and the Lk slot-in.
  - Add the book as a named track in `specs/ROADMAP.md` (D-F1).
- **Non-Goals**:
  - No new Lean formalization (no Vlach operators, no constitutive layer, no `Decidable`
    instance work) — the book reports on the formalization; it does not extend it.
  - No Lk-derived content in any form (embargo).
  - No LaTeX mirror sync (`latex/BimodalReference.tex` stays declared-divergent per SYNC-MAP D3).
  - No publication-facing copyright clearance (decision 4 defers it).

## Risks & Mitigations

- **Risk**: Parallel content phases collide on shared files (main file, SYNC-MAP.md).
  **Mitigation**: Phase 5 pre-creates ALL include lines and stub chapter files; content
  phases own exactly one chapter file each (territory contract); SYNC-MAP claim-table
  extension is serialized into Phase 12 only.
- **Risk**: Lean target moves mid-plan (tasks 303/309-311 in flight) and stamped claims
  go stale. **Mitigation**: volatile facts confined to generated counts (Phase 2) and the
  status tables; Phase 12 re-runs the sync-check and re-stamps at the then-current commit;
  drift detector (Phase 4) makes future staleness mechanically visible.
- **Risk**: Sync-class legend is adopted in prose but not enforced, recreating pre-312
  drift. **Mitigation**: Phase 4's checker fails on missing banners, ✓-labels in ○/◇
  chapters, and unresolvable backticked names; Phase 12 gates completion on it.
- **Risk**: The dataset-pipeline chapter drifts from `docs/training/PIPELINE.md` (dual
  ownership). **Mitigation**: move-and-cite (postmortem rule); PIPELINE.md reduced to an
  operational pointer + build commands, book owns the narrative.
- **Risk**: Stub chapters read as broken book. **Mitigation**: each stub is a styled
  one-page "planned chapter" notice with sync-class ◇, its follow-up task number, and a
  one-paragraph abstract — a feature of the living-monograph design, not a hole.
- **Risk**: Template port changes rendering of existing synced chapters. **Mitigation**:
  Phase 1 verifies `typst compile` before/after with no content edits to 00-06; theorem
  environment styles are additive (Logos template is a strict superset, B-F4).

## Source-to-Implementation Mapping (H3)

Tier 1 (literature-backed) mapping for in-plan phases, distilled from teammate A's 24-row
table (rows cited as A#n) and teammate B/D findings. Follow-up-task rows are listed at the
bottom for completeness. Status: ✓ = lean-verified content, ○ = paper-sourced, ◇ = outlook.

| Phase | Source (file:lines) | What it supplies | Target artifact | Sync-class |
|-------|--------------------|------------------|-----------------|------------|
| 1 | `~/Projects/Logos/Theory/typst/manual/template.typ:54-60,93-96,111-130,136-171,183-216,219-250` (254 ln) | proposition/corollary/example/notation-env; leansrc/leanref; chapter-header; items; principles/pr; fletcher helpers | `typst/template.typ` (extended) | n/a (infra) |
| 1 | `LogosManual.typ:40-51,195-197` | Chapter supplement show rule; bibliography block | `BimodalReference.typ`, `typst/bibliography.bib` | n/a |
| 1 | B-F4 notation collisions (3): `bimodal-notation.typ:37,42` vs Logos `basic-notation.typ:94`, `02-constitutive.typ:252,257`; triangles already aligned | Deliberate notation reconciliation | `notation/bimodal-notation.typ` (+ decisions recorded in file comments) | n/a |
| 2 | `SYNC-MAP.md` Ground-Truth Counts (Phase 1 methodology: comment-stripped `\bsorry\b`, Boneyard excluded) | Count methodology to script | `scripts/typst-status-counts.sh` + `typst/generated/status.typ` | n/a |
| 3 | Synthesis precondition 1; C-R1 (`sync-class` header field); D-R2 (legend ✓⧖○◇) | Legend spec + per-chapter banners | `SYNC-MAP.md` (legend section), chapters 00-06 banner blocks | n/a |
| 4 | SYNC-MAP Phase 6 extraction method (backtick-name grep vs `Theories/Bimodal/` excl. Boneyard); task-312 suggested follow-up | Drift-detector checks | `scripts/typst-sync-check.sh` | n/a |
| 5 | Synthesis Consolidated Book Shape; D-R1 part skeleton; D-R5.4 grid frontispiece contract | Five-part scaffold, stubs, front matter (3 source pillars + Lean repo, per A-F8) | `BimodalReference.typ`, stub `chapters/p*-*.typ` | ◇ (stubs) |
| 6 | `chapters/00-introduction.typ` (92 ln, current); `README.md:183-184` (dual verification); `docs/training/PIPELINE.md` Overview; D-R5.2/R5.3 (dual-track style, AI-reader preface); C-F1 honest framing | Rewritten introduction | `chapters/00-introduction.typ` | ✓/◇ mixed, banner-marked |
| 7 | `possible_worlds.tex:1162-1256` (§3.3 DF/DN/CO, TM_f/d/c/dc lattice, Next/Previous X φ := ⊥ U φ) [A#8]; app. `app:discrete/dense/complete` [A#13]; `Theories/Bimodal/FrameConditions/` (FrameClass.lean, Validity.lean, Soundness.lean, Compatibility.lean); `Metalogic/ConservativeExtension/` (0 sorries) [A#23]; paper `thm:ConservativeExtension` [A#14]; SYNC-MAP frame-class counts (Base 37 / Discrete 3 / Dense 2) | Frame Classes & Extensions chapter | `chapters/p2-frame-classes.typ` | ✓ core, ○ for TM_c/TM_dc + unformalized correspondences |
| 8 | `Metalogic/Decidability/` — `DecisionProcedure.lean:122` (fuel/timeout), `Correctness.lean:72-123` (`validity_decidable`=Classical.em, `decide_sound`, `fmp_completeness` over closure MCS), `TraceCertificate.lean`, `CountermodelExtraction.lean`, README module table [A#21]; `04-metalogic.typ:240-268` (status table, FMP row); D-R3 normative table | Decidability in Practice chapter + trimmed 04-metalogic | `chapters/p2-decidability-practice.typ`, `chapters/04-metalogic.typ` | ✓ procedure, ⧖/◇ metatheory |
| 9 | `Automation/README.md` module table; `Automation/Tactics/Commands.lean` (431 ln: `tm_auto`, `apply_axiom`, `modal_t`), `AesopRules.lean` (276 ln, TMLogic), `ProofSearch/Core.lean` (1,018 ln) [A#19] | Proof Automation chapter | `chapters/p4-proof-automation.typ` | ✓ |
| 10 | `docs/training/PIPELINE.md` (full: dual-signal architecture, 6 modules, `lake exe dataset_generator`, BimodalHarness artifact-only integration, Tier-1 gate incl. 3.2% ratio honesty); `Automation/{FormulaEnumerator,DatasetGenerator,BenchmarkOracle,ProofStepExport,EnrichedCountermodel}.lean` [A#19]; D-R4 | BMLogic Dataset Pipeline chapter (canonical home) | `chapters/p4-dataset-pipeline.typ`, `docs/training/PIPELINE.md` (pointer) | ✓ pipeline, ◇ Tier-2 plans |
| 11 | `Logos .../manual/chapters/01-introduction.typ:69-95` (Proof Certificates / Counterexamples / Soundness Guarantees framing, adapt-with-citation) [B-F3.4]; `README.md:183-184`; `Theories/Bimodal/Examples/` (sorry-free `BimodalProofs.lean`, `TemporalStructures.lean`) [A#20] | Dual Verification & Worked Examples chapter | `chapters/p4-dual-verification.typ` | ✓ examples, ○ framing |
| 12 | SYNC-MAP Phase 6 method; `specs/ROADMAP.md:1423-1431` (publication phase, no book item) [D-F1] | Consolidated claim-table extension, re-stamp, ROADMAP book track | `SYNC-MAP.md`, `specs/ROADMAP.md`, `typst/README.md` | n/a |
| FOLLOWUP:0 | `possible_worlds.tex:413-874` (§1-§2) [A#1-4]; app. `app:expressive/frame-impossible/abundant` [A#11-12] | Why Construct Possible Worlds chapter | `chapters/p1-why-worlds.typ` | ○ |
| FOLLOWUP:1 | `possible_worlds.tex:1007-1073,1246-1256,1291-1541` [A#6,8,9,10]; Kamp scoping (strict U/S, Dedekind-complete) at Lk-independent level; `Metalogic/WeakCanonical/Kamp/` status [A#22]; B-F3 prior art (Gabbay et al., Demri-Goranko-Lange, hybrid-logic Vlach/Cresswell/Blackburn — verify citations before print) | Part III chapters (Lk-abstracted) | `chapters/p3-*.typ` | ○/◇ |
| FOLLOWUP:2 | `counterfactual_worlds.tex` (2,277 ln: §2.2:624-679, §3:686-864, §4:872-1211, §5:1220-1370, App:1495+) [B-F1/F2, 9-item staging]; Logos `02-constitutive.typ` (1,623 ln), `03-dynamics.typ` (475 ln), `07-proof-theory.typ` (127 ln); B-F5 4 divergence resolutions | Part V chapters | `chapters/p5-*.typ` | ○(published)/◇ |
| FOLLOWUP:3 | `Automation/DatasetExporter.lean` schema; D-R5.1 | Machine-readable JSONL appendix | Lean export + book appendix | ✓ |
| FOLLOWUP:4 | `Lk/main.tex` + `sections/*` (post-acceptance only) [A#15-18] | Lk slot-in for Decidability Frontier | `chapters/p3-decidability-frontier.typ` anchors | ○ |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4, 5 | 3 (4 also: 2; 5 also: 1) |
| 4 | 6, 7, 8, 9, 10, 11 | 4, 5 |
| 5 | 12 | 6, 7, 8, 9, 10, 11 |

Phases within the same wave can execute in parallel under the territory contracts below.
Wave 4 phases each own exactly one new chapter file (Phase 8 additionally owns
`04-metalogic.typ`; Phase 10 additionally owns `docs/training/PIPELINE.md`; Phase 6 owns
`00-introduction.typ`) — no shared files inside the wave. `BimodalReference.typ` is owned
exclusively by Phase 5 after Phase 1's import-block edit; `SYNC-MAP.md` is owned by Phase 3
then Phase 12; no Wave-4 phase touches either.

### Phase 1: Template and Bibliography Port from LogosManual [COMPLETED]

- **Goal:** `typst/template.typ` becomes a superset of its current self with LogosManual's
  environments ported, a bibliography apparatus exists, and notation collisions are resolved
  — with zero rendering regression in chapters 00-06.
- **Territory:** `Theories/Bimodal/typst/template.typ`, `typst/bibliography.bib` (new),
  `notation/bimodal-notation.typ`, `BimodalReference.typ` (import/show-rule block ONLY,
  lines 14-62 region).
- **Tasks:**
  - [x] Port from `~/Projects/Logos/Theory/typst/manual/template.typ`: `proposition`,
        `corollary`, `example`, `notation-env` (:54-60); `leansrc`/`leanref` (:93-96);
        `chapter-header(description, dependencies, connections)` (:111-130); `items`/`item`
        (:136-171); `principles`/`principle`/`pr()` (:183-216); fletcher `extension-node`
        helpers (:219-250). Keep existing `thmbox-show`, `definition/theorem/lemma/axiom/
        remark/proof` untouched.
  - [x] Add a `sync-banner(class, source, note)` helper rendering the per-chapter
        sync-class banner (✓/⧖/○/◇ + source citation + "not formalized in this repository"
        note where class is ○/◇) — new, Bimodal-specific.
  - [x] Add heading `supplement: "Chapter"` + `ref` show rule (from `LogosManual.typ:40-51`)
        to `BimodalReference.typ`.
  - [x] Create `typst/bibliography.bib` seeded with: Brast-McKie possible-worlds (JPL),
        Brast-McKie counterfactual-worlds (JPL 2025), Burgess 1982, Xu, Vlach 1973,
        Kamp 1971, Cresswell 1990, Blackburn 2000, Gabbay et al. 2003,
        Demri-Goranko-Lange 2016, Baier-Katoen 2008 — entries marked `note = {verify
        before print}` where sourced from training knowledge (B-F3 caution). Wire
        `#bibliography` into the main file back matter. NO Lk entry (embargo).
  - [x] Resolve the 3 notation collisions (B-F4): keep Bimodal's `taskto` glyph as the
        book-wide task arrow (matches synced chapter 02), note Logos divergence in a
        comment; confirm `Dur`/triangle conventions already aligned; do NOT import the
        Logos constitutive layer now (that is 317's
        `notation/constitutive-notation.typ`).
  - [x] Verify: `typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0;
        visually spot-check one theorem box renders identically.
- **Estimated output:** ~220 lines (template additions + bib + import edits).
- **Done when:** compile green with all new environments available and bibliography rendering.
- **Timing:** 2 hours.
- **Depends on:** none.

### Phase 2: Scripted Status Counts Generator [COMPLETED]

- **Goal:** One single-source-of-truth generator for all volatile counts; no hand-copied
  number survives anywhere the book states a count.
- **Territory:** `scripts/typst-status-counts.sh` (new),
  `Theories/Bimodal/typst/generated/status.typ` (new, generated), `typst/generated/.gitignore`
  decision (commit the generated file — it is the stamped artifact).
- **Tasks:**
  - [x] Write `scripts/typst-status-counts.sh`: reproduces SYNC-MAP Phase 1 methodology —
        comment-stripped `\bsorry\b` count over `Theories/Bimodal/Metalogic/**/*.lean`
        (block `/- -/` and line `--` comments removed), `Boneyard/` and nested
        `WeakCanonical/Kamp/Boneyard/` reported separately; `inductive Axiom` constructor
        count via the SYNC-MAP awk pattern; `DerivationTree` rule count; per-subtree sorry
        table. Output: `typst/generated/status.typ` defining typst values
        (`#let sorry-total`, `#let sorry-table`, `#let axiom-count`, `#let rule-count`,
        `#let stamp-commit`, `#let stamp-date`) — commit-stamped from `git rev-parse --short HEAD`.
  - [x] Emit the same data as JSON to stdout (for `typst-sync-check.sh` consumption in Phase 4).
  - [x] Run it; verify output matches SYNC-MAP's stamped values at `a883361bf` (42/7/43)
        or document the delta if the tree moved.
  - [x] Add a header comment: "generated file — never edit; regenerate via
        scripts/typst-status-counts.sh".
- **Estimated output:** ~120 lines (script + generated file).
- **Done when:** script runs green, generated values match independent SYNC-MAP derivation.
- **Timing:** 1.5 hours.
- **Depends on:** none.

### Phase 3: SYNC-MAP Status-Legend Extension and Per-Chapter Banners [COMPLETED]

- **Goal:** SYNC-MAP gains the four-class legend as a first-class contract; every existing
  chapter carries a sync-class banner; hand-copied counts in chapters are replaced by
  generated imports.
- **Territory:** `Theories/Bimodal/typst/SYNC-MAP.md`, `chapters/00-06*.typ` (banner block +
  count-import edits only).
- **Tasks:**
  - [x] Add a "Sync-Class Legend" section to SYNC-MAP.md defining:
        ✓ lean-verified (every formal claim carries a resolving Lean anchor, sorry-free or
        sorry-status stated) / ⧖ with-sorries (Lean-anchored, open obligations) /
        ○ paper-sourced (proved in a cited paper, not formalized here) / ◇ outlook-planned
        (design/roadmap content, no proof anywhere). Record the enforcement rules: no ✓
        label in ○/◇ chapters; no unstamped Lean claim anywhere; per-claim overrides allowed
        inside a chapter via inline markers.
  - [x] Add `#sync-banner(...)` (Phase 1 helper) to each chapter 00-06 with classes:
        00 ✓/◇-mixed, 01 ✓, 02 ✓, 03 ✓, 04 ⧖, 05 ✓, 06 ⧖ — citing SYNC-MAP as authority.
  - [x] Replace hand-copied counts in `06-notes.typ` (43-sorry claim, :91 region) and
        `04-metalogic.typ` (any stated counts) with imports from `generated/status.typ`;
        keep the SYNC-MAP-stamp footnote pattern.
  - [x] Record in SYNC-MAP that per-chapter banners exist and are checkable (input to Phase 4).
  - [x] Verify: compile green; grep confirms no literal sorry-count digits remain in
        chapter prose outside generated imports.
- **Estimated output:** ~150 lines across 8 files.
- **Done when:** all 7 chapters banner-marked, zero hand-copied counts, compile green.
- **Timing:** 2 hours.
- **Depends on:** 1, 2.

### Phase 4: typst-sync-check.sh Drift Detector [COMPLETED]

- **Goal:** The task-312 follow-up exists: a CI-runnable script that mechanically detects
  book↔Lean drift and legend violations.
- **Territory:** `scripts/typst-sync-check.sh` (new).
- **Tasks:**
  - [x] Check 1 — name resolution: extract all backticked names from
        `Theories/Bimodal/typst/**/*.typ`, resolve each via
        `grep -rn --include='*.lean' -F <name> Theories/Bimodal --exclude-dir=Boneyard`
        plus filesystem path checks (the SYNC-MAP Phase 6 method); whitelist file for
        deliberate historical `Boneyard/` references and external-repo (Logos) citations.
  - [x] Check 2 — banner presence: every file in `chapters/` included by
        `BimodalReference.typ` contains a `#sync-banner(` call.
  - [x] Check 3 — legend discipline: no ✓/lean-verified banner or inline marker in a file
        whose banner class is ○ or ◇.
  - [x] Check 4 — count freshness: regenerate via `scripts/typst-status-counts.sh` (JSON
        mode) and diff against committed `generated/status.typ`; fail on mismatch.
  - [x] Exit non-zero on any failure with a per-violation report; document usage in
        `typst/README.md` is deferred to Phase 12 (README owned there).
  - [x] Verify: run against the Phase-3 tree — must pass; inject one fake stale name in a
        scratch copy — must fail.
- **Estimated output:** ~180 lines.
- **Done when:** both the pass case and the seeded-failure case behave correctly.
- **Timing:** 1.5 hours.
- **Depends on:** 2, 3.

### Phase 5: Five-Part Restructure of the Main File with Stub Division Points [COMPLETED]

- **Goal:** `BimodalReference.typ` presents the five-part monograph: part dividers with
  sync-class summaries, updated front matter, and every deferred chapter present as a styled
  stub — so no later phase or follow-up ever edits the main file again.
- **Territory:** `BimodalReference.typ` (structure), new stub files
  `chapters/p1-why-worlds.typ`, `chapters/p3-ltl-to-tm.typ`, `chapters/p3-vlach-blstar.typ`,
  `chapters/p3-decidability-frontier.typ`, `chapters/p3-open-future.typ`,
  `chapters/p5-constitutive.typ`, `chapters/p5-counterfactual.typ`, plus empty-shell files
  for Wave-4 chapters (`p2-frame-classes.typ`, `p2-decidability-practice.typ`,
  `p4-proof-automation.typ`, `p4-dataset-pipeline.typ`, `p4-dual-verification.typ`).
- **Tasks:**
  - [x] Reorganize includes into five parts with divider pages:
        Part I (00-introduction, p1-why-worlds stub); Part II (01-syntax, 02-semantics,
        03-proof-theory, p2-frame-classes, 04-metalogic, p2-decidability-practice,
        05-theorems); Part III (p3-ltl-to-tm, p3-vlach-blstar, p3-decidability-frontier,
        p3-open-future — all stubs); Part IV (p4-proof-automation, p4-dataset-pipeline,
        p4-dual-verification); Part V (p5-constitutive, p5-counterfactual — stubs);
        back matter (06-notes, bibliography). Each divider states the part's dominant
        sync-class and one-paragraph scope.
  - [x] Each stub file: `#sync-banner(◇, ...)` + chapter title + one-paragraph abstract
        (from the synthesis book shape) + "Planned chapter — to be written under task
        {{FOLLOWUP:i}}" notice (314 for p1-why-worlds; 315 for the
        four p3-* stubs; 317 for the two p5-* stubs). Wave-4 shell files carry
        only banner + title (filled by Phases 6-11, same file, no main-file edit).
  - [x] `p3-decidability-frontier.typ` stub additionally declares the named slot-in
        anchors (`// SLOT-IN: ladder-table`, `// SLOT-IN: complexity-map`,
        `// SLOT-IN: case-study`) required by decision 2 and consumed by 318.
  - [x] Front matter: title page "Primary Reference" block becomes a "Sources" block —
        possible-worlds paper, counterfactual-worlds paper (published), and the Lean
        repository as ground truth (A-F8; the Lk paper is NOT listed — embargo); abstract
        updated to describe the five-part living-monograph structure and the legend.
  - [x] Reading-guide legend box after the abstract: the four sync-class symbols and what
        a reader (human or AI) may treat as ground truth.
  - [x] Verify: compile green; TOC shows five parts; stubs render as styled notices.
- **Estimated output:** ~280 lines (main-file rewrite + 12 small files).
- **Done when:** compile green, all includes wired, main file frozen for the rest of the plan.
- **Timing:** 2 hours.
- **Depends on:** 1, 3.

### Phase 6: Introduction Rewrite for the AI-Practitioner Arc [COMPLETED]

- **Goal:** `00-introduction.typ` states the whole book's arc up front, led by the
  AI-training use case, with honest TM framing and the AI-reader guide.
- **Territory:** `chapters/00-introduction.typ` only.
- **Tasks:**
  - [x] Open with the practitioner thesis: TM as a verified reasoning substrate — decidable
        operational fragment for fully automated checking vs the full logic as a generator
        of dual-signal training data (proof traces → policy, countermodels → value), every
        output deterministically checkable (`README.md:183-184`, PIPELINE.md Overview —
        cite forward to Part IV).
  - [x] Honest system description (postmortem rule): Until/Since temporal logic over linear
        orders fused with S5 plus interaction/uniformity layers over task frames; the
        LTL → +S5 → +store/recall tower presented ONLY as the extension roadmap, marked ◇.
  - [x] Book map: the five parts, one paragraph each, with sync-class of each part; keep and
        re-caption the existing light-cone diagram; add the unification-grid frontispiece
        (D-R5.4: horizontal operator axis × vertical world-state-structure axis, TM shaded
        as the first verified cell) using Phase-1 fletcher helpers.
  - [x] "How to Read This Book If You Are an AI" section (D-R5.3): what the legend means,
        which claims are safe as ground truth (✓ only), where the machine-readable appendix
        will live (316), how names map to `Theories/Bimodal/` declarations.
  - [x] Keep the Project Structure section, updating the `Automation/`/`Examples/` line
        (no longer "not covered in this manual" — point to Part IV).
  - [x] Verify: compile green; `scripts/typst-sync-check.sh` passes (all cited names resolve).
- **Estimated output:** ~250 lines.
- **Done when:** chapter reads as the book's front door for the primary audience; checks green.
- **Timing:** 2 hours.
- **Depends on:** 4, 5.

### Phase 7: Part II Chapter — Frame Classes and Extensions [COMPLETED]

- **Goal:** The D2-deferred frame-class chapter exists: DF/DN/CO correspondence, the
  frame-class lattice as implemented, Next/Previous as derived, and the conservative
  extension theorem stated — ✓-class core with explicitly marked ○ islands.
- **Territory:** `chapters/p2-frame-classes.typ` only.
- **Tasks:**
  - [x] Frame classes as implemented: `FrameClass` (Base/Dense/Discrete, partial order),
        `minFrameClass` assignment (Base 37 / Discrete 3 / Dense 2 from generated counts),
        `FrameConditions/` semantics (FrameClass.lean, Validity.lean, Soundness.lean,
        Compatibility.lean) — all ✓ with resolving anchors.
  - [x] DF/DN/CO axioms and frame correspondence: paper §3.3 (`possible_worlds.tex:1162-1256`)
        + `app:discrete`/`app:dense`/`app:complete`; per-result status marks — Dense/Discrete
        formalized ✓, completeness-class TM_c/TM_dc and unformalized correspondences ○ with
        paper citations (A#8, A#13: per-item status verified against Lean during this phase,
        not assumed).
  - [x] Next/Previous as derived operators (X φ := ⊥ U φ over the strict Until/Since basis;
        `thm:BLplus-NextPrevious` cited ○; definability-in-Lean noted ✓ where the derived
        forms exist in `Syntax/Formula.lean` — verify, do not assume).
  - [x] Conservative extension: state the theorem the paper calls `thm:ConservativeExtension`
        with its Lean counterpart from `Metalogic/ConservativeExtension/` (0 sorries per
        SYNC-MAP) — resolve the exact declaration name from source before writing it.
  - [x] Chapter-header dependency preamble (assumes ch. 01-03) and `#sync-banner(✓, ...)`
        with inline ○ marks.
  - [x] Verify: compile green; sync-check green (every backticked name resolves).
- **Estimated output:** ~300 lines.
- **Done when:** chapter complete, per-result status verified against live Lean, checks green.
- **Timing:** 3 hours.
- **Depends on:** 4, 5.

### Phase 8: Part II Chapter — Decidability in Practice (+ 04-metalogic trim) [COMPLETED]

- **Goal:** The operational decision procedure gets its own honest chapter (entry points,
  fuel semantics, certificates, countermodels) and `04-metalogic.typ` sheds the moved
  material; the FMP discrepancy is resolved before either document states a status.
- **Territory:** `chapters/p2-decidability-practice.typ`, `chapters/04-metalogic.typ`.
- **Tasks:**
  - [x] FIRST: resolve the FMP discrepancy against `Metalogic/Decidability/Correctness.lean`
        — read `fmp_completeness` (:123) and determine whether "In progress"
        (`04-metalogic.typ:260`) reflects an unwired completeness direction (stated over
        closure MCS bundles, not semantic validity) rather than sorries (README says
        sorry-free). Record the resolution in the chapter, in `06-notes`-style wording, and
        carry the corrected row into the status table. Both documents must state the SAME
        resolved status.
  - [x] Operational chapter content: `decide`/`isValid`/`isSatisfiable`, `DecisionResult`,
        fuel semantics and the `timeout` branch (`DecisionProcedure.lean:122`),
        `TraceCertificate`/`TraceExport` certificate format, `CountermodelExtraction` —
        presented as a usable artifact with invocation examples.
  - [x] Honest metatheory section (postmortem rule): `decide_sound` proven ✓;
        `validity_decidable` is `Classical.em` — stated plainly as vacuous; no `Decidable`
        instance; semantic completeness of the tableau runs through the sorry-tainted chain
        (⧖); inherits `06-notes.typ:96-100` honesty.
  - [x] Closing normative status table (D-R3): rows = fragments/properties (tableau
        soundness, FMP, verified termination, target decidable fragment), columns =
        status (✓/⧖/○/◇) — every non-✓ row phrased as a candidate roadmap task (feeds
        tasks 165/82/290/300).
  - [x] Trim `04-metalogic.typ`: replace its Decidability subsection with a two-paragraph
        summary + cross-reference to this chapter; keep the component-status table (with the
        corrected FMP row); preserve every Lean anchor either in place or in the new chapter.
  - [x] Verify: compile green; sync-check green; no decidability claim stronger than the
        resolved facts.
- **Estimated output:** ~330 lines (new chapter ~280, 04-metalogic delta ~50).
- **Done when:** FMP resolution recorded once and consistently; chapter + trim complete; checks green.
- **Timing:** 3 hours.
- **Depends on:** 4, 5.

### Phase 9: Part IV Chapter — Proof Automation [COMPLETED]

- **Goal:** The ~8,900-line `Automation/` proof-automation half is surfaced: tactics, Aesop
  rule set, and the bounded proof-search engine, as a ✓-class chapter.
- **Territory:** `chapters/p4-proof-automation.typ` only.
- **Tasks:**
  - [x] Tactics: `tm_auto`, `apply_axiom`, `modal_t` (`Automation/Tactics/Commands.lean`) —
        what each does, one worked invocation each (drawn from library usage, verified to
        exist).
  - [x] Aesop integration: the `TMLogic` rule set (`AesopRules.lean`), forward chaining and
        normalization rules, when to reach for it vs `tm_auto`.
  - [x] Bounded proof search: `ProofSearch/Core.lean` engine and `Strategies.lean` — search
        space, bounds, relationship to the tableau procedure (cross-ref Phase 8 chapter).
  - [x] `SuccessPatterns.lean` and `EFGameTactics.lean` one-section survey (the latter
        cross-referenced to the Kamp frontier, marked ⧖ where it serves in-progress work).
  - [x] Chapter-header preamble (assumes ch. 03 proof theory) + `#sync-banner(✓, ...)`.
  - [x] Verify: compile green; sync-check green.
- **Estimated output:** ~260 lines.
- **Done when:** chapter complete with all module claims resolving; checks green.
- **Timing:** 2.5 hours.
- **Depends on:** 4, 5.

### Phase 10: Part IV Chapter — The BMLogic Dataset Pipeline [COMPLETED]

- **Goal:** The book becomes the canonical narrative home of the dual-signal training
  pipeline (move-and-cite from `docs/training/PIPELINE.md`), the centerpiece chapter for the
  primary audience.
- **Territory:** `chapters/p4-dataset-pipeline.typ`, `docs/training/PIPELINE.md`.
- **Tasks:**
  - [x] Adapt PIPELINE.md's architecture narrative: dual-signal design (proof traces →
        policy network; countermodels → value network), pipeline flow (enumeration →
        oracle labeling → trace/countermodel extraction → JSONL export), the six
        `Automation/` modules and two `lake exe` executables, BimodalHarness artifact-only
        integration (`make sync-data`).
  - [x] Keep the honesty content: Tier-1 feasibility gate results including the 3.2%-valid
        provability-ratio imbalance and the Tier-2 theorem-mining response;
        `EnrichedCountermodel` marked implemented-but-not-wired (◇ for Tier-2 plans).
  - [x] Frame with the practitioner thesis (decidable fragments = full automation; full
        logic = training signal with cheap deterministic checking) — the D-R4/Logos-labs
        pitch grounded in shipped code, cited to `README.md:183-184`.
  - [x] Reduce `docs/training/PIPELINE.md` to: operational quick-reference (build/run
        commands, config knobs) + prominent pointer "canonical narrative:
        BimodalReference Part IV" — no duplicated architecture prose (postmortem rule).
  - [x] Chapter-header preamble + `#sync-banner(✓, ...)` with ◇ marks on Tier-2/future items.
  - [x] Verify: compile green; sync-check green; PIPELINE.md still serves `lake exe` users.
- **Estimated output:** ~320 lines (chapter ~270, PIPELINE.md rewrite ~50).
- **Done when:** single canonical narrative exists; operational doc still functional; checks green.
- **Timing:** 2.5 hours.
- **Depends on:** 4, 5.

### Phase 11: Part IV Chapter — Dual Verification and Worked Examples [NOT STARTED]

- **Goal:** One chapter presenting the dual-verification architecture (proof certificates vs
  countermodels) and surfacing the sorry-free `Examples/` directory as worked material.
- **Territory:** `chapters/p4-dual-verification.typ` only.
- **Tasks:**
  - [ ] Dual-verification section: ProofChecker derivations vs ModelChecker/Z3 countermodel
        search (`README.md:183-184`), adapting the Proof Certificates / Counterexamples /
        Soundness Guarantees framing from Logos `01-introduction.typ:69-95` with citation
        (○ where the claim is architectural vision, ✓ where shipped).
  - [ ] Worked examples: curated derivations from `Examples/BimodalProofs.lean` (sorry-free)
        rendered dual-track (informal motivation paragraph + Lean-anchored statement box —
        the D-R5.2 house style, demonstrated here for adoption by later chapters).
  - [ ] Concrete temporal structures from `Examples/TemporalStructures.lean`: the dense and
        discrete instantiations as semantics-made-tangible.
  - [ ] Chapter-header preamble + `#sync-banner(✓, ...)` with ○ marks on the
        cross-project framing.
  - [ ] Verify: compile green; sync-check green.
- **Estimated output:** ~250 lines.
- **Done when:** chapter complete; house style demonstrated; checks green.
- **Timing:** 2.5 hours.
- **Depends on:** 4, 5.

### Phase 12: Integration, SYNC-MAP Re-Stamp, and Roadmap Registration [NOT STARTED]

- **Goal:** The grown book passes the full verification battery, SYNC-MAP covers every new
  chapter, and the book exists as a named roadmap track.
- **Territory:** `Theories/Bimodal/typst/SYNC-MAP.md`, `typst/README.md`, `specs/ROADMAP.md`.
- **Tasks:**
  - [ ] Extend SYNC-MAP's claim-verification coverage: run the Phase-6-style extraction over
        all new/rewritten chapters (p2-*, p4-*, 00-introduction, trimmed 04-metalogic),
        append a "Task 313 chapters" verification section, re-stamp date + commit.
  - [ ] Re-run `scripts/typst-status-counts.sh` and commit the regenerated `status.typ` at
        the stamp commit (document any drift from `a883361bf` caused by in-flight Lean tasks).
  - [ ] Run `scripts/typst-sync-check.sh` — must exit 0 (all four checks).
  - [ ] Full `typst compile BimodalReference.typ build/BimodalReference.pdf` — exit 0;
        TOC review: five parts, stubs styled, no orphaned includes.
  - [ ] Update `typst/README.md`: five-part structure, sync-class legend, how to run the
        two scripts, follow-up task pointers (314-318).
  - [ ] Add the book to `specs/ROADMAP.md` as a named documentation/publication track under
        the Post-Completeness section (:1423-1431): the five parts, their sync classes, and
        the follow-up task numbers (D-F1) — additive edit only, no restructuring of the
        completeness roadmap.
  - [ ] Verify: all checks green; git status shows only plan-scoped files.
- **Estimated output:** ~200 lines across 3 files.
- **Done when:** verification battery green; SYNC-MAP authoritative for the whole book.
- **Timing:** 2 hours.
- **Depends on:** 6, 7, 8, 9, 10, 11.

## Planned Strategic Sorries

Skeleton division points (plan_metadata.skeleton: true). Each row is a deliberate deferral
created as a styled stub in Phase 5; the "sorry" analogue in this typst task is the stub
chapter/anchor, evaluated under the anti-analysis 5-condition test (pre-declared, tightly
scoped to one chapter set, documented in the stub text, tracked here, build-green — stubs
compile). Columns map to the `sorry_inventory` schema fields verbatim.

| Division Point | File / Line / Statement | Assumption | Why Deferred | Follow-Up Task |
|-----------------|--------------------------|------------|---------------|----------------|
| Part I motivation chapter | `chapters/p1-why-worlds.typ` (stub, Phase 5) | Paper §1-§2 motivation (possible_worlds.tex:413-874) adapts with citation into one ○ chapter backed by app:expressive/frame-impossible/abundant | Audience decision 1: philosophy serves, does not lead; not on the practitioner-critical path of this plan | 314 |
| Part III expressive-power chapters (4) | `chapters/p3-ltl-to-tm.typ`, `p3-vlach-blstar.typ`, `p3-decidability-frontier.typ`, `p3-open-future.typ` (stubs, Phase 5) | Honest positioning + Vlach/BL⋆ + Lk-abstracted frontier + open future are writable from possible_worlds §3.1/§3.3/§4 and prior art without Lk citations | A full Part (~4 chapters, ○/◇ class, embargo-constrained wording) exceeds this plan's phase ceiling; Lk-free abstraction level needs its own careful pass | 315 |
| Part V Logos chapters (2) | `chapters/p5-constitutive.typ`, `p5-counterfactual.typ` (stubs, Phase 5) | Adaptation (propositional restriction) of counterfactual_worlds.tex + Logos 02/03/07 chapters per B's 9-item staging and 4 divergence resolutions; BimodalReference owns this exposition (decision 3) | Sequenced last (D-R6): depends on Logos-side stability and the B staging re-verification at drafting time; largest ○ block in the book | 317 |
| Machine-readable appendix | back-matter stub reference in `BimodalReference.typ` + `00-introduction.typ` AI-reader pointer (Phase 5/6) | Axiom table, rules, and derived-operator definitions exportable from Lean matching the `DatasetExporter` JSONL schema | Requires new Lean export code (out of this plan's no-new-Lean non-goal); high audience value as its own bounded task | 316 |
| Lk slot-in anchors | `chapters/p3-decidability-frontier.typ` `// SLOT-IN:` anchors (Phase 5) | Post-TACAS-acceptance, the BL⋆ ladder, complexity map, and case study insert at the anchors without renumbering (decision 2) | Hard embargo on an external event (TACAS 2027 decision); cannot be scheduled, only prepared for | 318 |

Deviation flag: any implementer-created stub or deferral NOT on this table must be flagged
in the implementation summary as a plan-unanticipated deviation.

## Testing & Validation

- [ ] `typst compile Theories/Bimodal/typst/BimodalReference.typ build/BimodalReference.pdf`
      exits 0 after every phase (per-phase gate).
- [ ] `bash scripts/typst-status-counts.sh` output matches an independent SYNC-MAP-method
      derivation (Phase 2 gate); regenerated cleanly at Phase 12.
- [ ] `bash scripts/typst-sync-check.sh` exits 0 from Phase 4 onward (per-phase gate for
      Waves 4-5); seeded-failure test demonstrates non-zero exit (Phase 4 gate).
- [ ] Legend discipline audit at Phase 12: zero ✓ labels in ○/◇ chapters; every chapter
      banner-marked; zero hand-copied volatile counts (grep for digit-literals near
      "sorr"/"axiom" in chapter prose).
- [ ] Embargo audit at Phase 12: `grep -ri "lk\b\|TACAS\|hyperproperties ladder" typst/`
      style sweep confirms no Lk citation or attributed result anywhere.
- [ ] Preserved-assets regression check: the 271 task-312 names still resolve (subsumed by
      sync-check Check 1); 06-notes honesty sections intact.

## Artifacts & Outputs

- plans/01_full-book-design.md (this file)
- specs/313_design_full_extent_bimodalreference_book/.skeleton-return.json (follow-up declarations)
- `Theories/Bimodal/typst/template.typ` (extended), `typst/bibliography.bib` (new)
- `scripts/typst-status-counts.sh`, `scripts/typst-sync-check.sh` (new),
  `Theories/Bimodal/typst/generated/status.typ` (generated, committed)
- `Theories/Bimodal/typst/BimodalReference.typ` (five-part restructure)
- New chapters: `chapters/p2-frame-classes.typ`, `p2-decidability-practice.typ`,
  `p4-proof-automation.typ`, `p4-dataset-pipeline.typ`, `p4-dual-verification.typ`
- Rewritten: `chapters/00-introduction.typ`; trimmed: `chapters/04-metalogic.typ`
- Stubs: `chapters/p1-why-worlds.typ`, `p3-*.typ` (4), `p5-*.typ` (2)
- Updated: `Theories/Bimodal/typst/SYNC-MAP.md`, `typst/README.md`,
  `docs/training/PIPELINE.md` (pointerized), `specs/ROADMAP.md` (book track)
- summaries/01_full-book-design-summary.md (at implementation completion)

## Success Criteria

1. The book compiles as a five-part monograph; every chapter (real or stub) carries a
   sync-class banner; the sync-check and status-count scripts run green.
2. Part II contains the frame-classes and operational-decidability chapters with per-result
   Lean-verified status and the FMP discrepancy resolved consistently in all documents.
3. Part IV tells the automation/dataset/dual-verification story as the canonical home
   (PIPELINE.md pointerized), serving the primary AI-practitioner audience.
4. The introduction leads with the practitioner arc, frames TM honestly (never as vanilla
   LTL+S5), and includes the AI-reader guide and unification-grid frontispiece.
5. Zero Lk citations/attributions anywhere; slot-in anchors exist for post-acceptance insertion.
6. Five follow-up tasks exist with correct dependencies (all on this skeleton task;
   Part V additionally after Part III; Lk slot-in after Part III), and every stub names its
   follow-up task number.
7. Task-312 preserved assets fully intact (271 names resolve; honest prose preserved).

## Rollback/Contingency

- **Per-phase rollback**: every phase commits only at green (compile + applicable script
  checks); a failed phase is reverted via `bash .claude/scripts/git-snapshot.sh` + targeted
  restore of its territory files only — territories are disjoint, so rollback never touches
  another phase's work.
- **Template regression (Phase 1)**: if ported environments break rendering of chapters
  00-06, revert `template.typ` to the 74-line original (git) and re-port environment-by-
  environment; the phase is additive by design.
- **Sync-check false positives (Phase 4)**: maintain the whitelist file rather than
  weakening checks; if the checker cannot be made reliable in-phase, mark Phase 4 [PARTIAL]
  with Checks 1-2 landed (name resolution + banners) and spawn a fix task — Checks 1-2 are
  the load-bearing pair.
- **Wave-4 partial completion**: each chapter phase is independently green; an incomplete
  wave leaves the book compiling with that chapter as its Phase-5 shell (banner + title) —
  acceptable intermediate state; Phase 12 proceeds only when all six are done, otherwise the
  missing chapter is converted to a stub division point with a spawned follow-up
  (deviation-flagged per the Planned Strategic Sorries rules).
- **Lean-tree drift mid-plan** (tasks 303/309-311 landing): do NOT chase moving targets
  inside content phases; Phase 12 re-stamps at the final commit and documents deltas. If a
  landing task invalidates a written claim, the fix is scoped to Phase 12's re-stamp pass.
- **Full abort**: the book remains valid at every wave boundary (compile-green invariant);
  aborting after Wave 3 still leaves the infrastructure preconditions (the highest-value
  standalone assets) in place.

## plan_metadata

```json
{
  "phases": 12,
  "total_effort_hours": 26,
  "complexity": "complex",
  "research_integrated": true,
  "plan_version": 1,
  "dependency_waves": [[1, 2], [3], [4, 5], [6, 7, 8, 9, 10, 11], [12]],
  "reports_integrated": [
    {
      "path": "reports/01_team-research.md",
      "integrated_in_plan_version": 1,
      "integrated_date": "2026-07-06"
    }
  ],
  "skeleton": true,
  "follow_up_tasks": []
}
```

`follow_up_tasks` is populated by skill-planner-hard postflight after `{{FOLLOWUP:i}}`
substitution (see `.skeleton-return.json`).
