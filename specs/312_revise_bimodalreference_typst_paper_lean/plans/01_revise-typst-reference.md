# Implementation Plan: Revise BimodalReference.typ to Match Paper + Lean Source

- **Task**: 312 - revise_bimodalreference_typst_paper_lean
- **Status**: [IMPLEMENTING]
- **Effort**: 11 hours
- **Dependencies**: None
- **Research Inputs**: specs/312_revise_bimodalreference_typst_paper_lean/reports/01_team-research.md (synthesis of 4 teammates; per-teammate detail in 01_teammate-{a,b,c,d}-findings.md)
- **Artifacts**: plans/01_revise-typst-reference.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: typst
- **Lean Intent**: false

## Overview

`Theories/Bimodal/typst/BimodalReference.typ` and its six chapter files have drifted multiple project-generations behind the Lean 4 source: three chapters (Syntax, Proof-Theory, Metalogic) need substantive rewrites, one (Notes) contains a self-contradiction about temporal semantics, and the Metalogic chapter documents a deleted architecture that now lives only in `Boneyard/`. This plan revises all seven chapter files with the **live Lean source as first-priority ground truth** and the paper `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` as the terminology/narrative guide. Definition of done: `typst compile` succeeds, every backtick-quoted Lean identifier in the document resolves in live source (outside `Boneyard/`), and all counts (axioms, sorries, layers) are regenerated from source rather than copied forward.

### Research Integration

Key findings integrated from `reports/01_team-research.md`:
- **Strict/irreflexive temporal semantics is current** (`Semantics/Truth.lean:10-17`, task 93). `02-semantics.typ` is already correct; `04-metalogic.typ:154` and `06-notes.typ:118-126` claim reflexive is current and must be rewritten. Fully resolved — no ambiguity remains.
- **Syntax primitives are `{atom, bot, imp, box, untl, snce}`** (`Syntax/Formula.lean:70-85`) with H/G/F/P derived (`:109-155`); the doc's `{atom, bot, imp, box, H, G}` is stale.
- **Proof system is the 42-constructor Burgess-Xu (BX) system in 8 layers** (`ProofSystem/Axioms.lean:37`) with a `FrameClass` parameter on `DerivationTree` (`ProofSystem/Derivation.lean:85-93`); the doc's "14 axioms" is stale. The 7 inference rules ARE still accurate.
- **`04-metalogic.typ` cites a deleted architecture** (`semantic_weak_completeness`, `FMP/`, `Representation/` — all Boneyard-only). Completeness is NOT sorry-free (~38-42 genuine sorries outside Boneyard); Soundness and Perpetuity P1-P6 ARE sorry-free.
- **Missing content**: Task-Frame Reflection constraint (paper `:902-907`), frame-class axis (Base/Dense/Discrete), paper §3.3 Extensions.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` loaded (read-only). This task advances the publication/documentation dimension of the BX completeness roadmap but maps to no explicit roadmap checkbox. Critically, ROADMAP.md itself is a *fourth* partially-stale doc surface: it states "41 BX axioms in 6 layers" (research found 42 constructors / 8 layers) and designates the **Chronicle path** (`Metalogic/BXCanonical/Chronicle/`) as the primary and only active completeness path — disagreeing with `Metalogic/README.md` (Bundle/BFMCS) and with the typst doc (deleted FMP path). This three-way disagreement is exactly why Phase 0 verifies the live wiring from source before any chapter is rewritten.

## Goals & Non-Goals

**Goals**:
- Every Lean identifier, filename, directory, axiom formula, and count in `typst/` chapters verified against live `Theories/Bimodal` source (excluding `Boneyard/`)
- Full rewrites of `04-metalogic.typ`, `03-proof-theory.typ`, `01-syntax.typ`; targeted edits to `02-semantics.typ`, `06-notes.typ`, `05-theorems.typ`, `00-introduction.typ`
- Paper terminology/notation adopted as target vocabulary where it does not conflict with Lean structure (Lean wins on conflicts)
- A reusable claim-verification table (`SYNC-MAP.md`) as a first-class deliverable
- Doc hygiene: README dependency claim (`great-theorems` -> `thmbox`), stray top-level PDF
- Compile smoke-test as the verification gate

**Non-Goals**:
- Documenting the paper's unformalized philosophy: Objective Modality, 2D Semantics (out of scope by decision)
- Presenting Kamp/task-303/309-311 work as settled results (in-progress note only; it is NO-GO-gated and in-flux)
- Syncing `latex/BimodalReference.tex` or `docs/reference/*.md` (declared divergence + follow-up flag; see Phase 0)
- Restructuring typst chapters to 1:1-mirror Lean module boundaries (pedagogical structure is correct; SYNC-MAP provides traceability)
- Building drift-detection tooling (`typst-sync-check.sh`) — spawn as follow-up, do not scope-creep
- Documenting `Automation/` or `Examples/` directories

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Wrong "primary completeness" narrative lands (3 doc surfaces disagree: README=Bundle, ROADMAP=Chronicle, teammate A=BXCanonical wiring) | H | M | Phase 0 verifies live wiring from imports + `lean_verify`/grep on actual theorem names before ch04 is touched; all three stale surfaces treated as hypotheses, not authorities |
| Copying stale counts forward (42 vs 41 axioms, 8 vs 6 layers, sorry counts) | H | M | All counts regenerated from source by scripted grep in Phase 1 and re-verified in Phase 6; never transcribed from any README/ROADMAP/report |
| Lean source moves mid-task (tasks 303/311 active on Metalogic) | M | M | Phase 6 re-runs the full identifier grep against HEAD at completion time; sorry counts stamped with date + commit |
| Typst compile fails on new notation macros | M | L | Add macros additively to `notation/bimodal-notation.typ`; compile after each chapter phase, not only at the gate |
| Scope creep into latex/ mirror or docs/reference/ | M | M | Explicit non-goals; Phase 0 records divergence declaration; Phase 6 only updates the two READMEs' parity claims |
| Paper file outside repo changes during task | L | M | Paper used for narrative/terminology only; all factual cells sourced from Lean, so paper drift cannot corrupt correctness |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2, 3, 4 | 1 |
| 4 | 5 | 2, 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel (Phases 2, 3, 4 touch disjoint files).

### Phase 0: Scope Decisions and Live Completeness-Wiring Verification [COMPLETED]

**Goal**: Record the scoping calls explicitly and resolve the one open factual question (primary completeness path) from live source, so every later phase transcribes rather than guesses.

**Tasks**:
- [x] Verify the CURRENT primary completeness wiring from live source, treating all doc surfaces as suspect: inspect `Theories/Bimodal/Metalogic/Metalogic.lean` imports, `Metalogic/Completeness.lean`, `Metalogic/BXCanonical/Completeness.lean`, `Metalogic/Bundle/`, and grep for the candidate top-level theorems (`completeness_discrete`, `fmp_completeness`, `countermodel_dense`, `bmcs_weak_completeness`). Record which theorem(s) are the wired, importable entry points and which paths are active-secondary. Candidates from conflicting sources: Chronicle path per `specs/ROADMAP.md`; Bundle/BFMCS per `Metalogic/README.md:11-13` (self-warned stale); BXCanonical wiring per teammate A. Decision rule: imports and `lean_verify`/grep on live source win over every README/ROADMAP claim.
- [x] Decide frame-class parametrization scope. Recommended: IN scope for `03-proof-theory.typ` (the `FrameClass` parameter and Base/Dense/Discrete axiom layers are inseparable from an accurate 42-constructor presentation, `ProofSystem/Derivation.lean:85-93`) and summary-level in `04-metalogic.typ` (per-frame-class soundness variants named, not proof-sketched); a dedicated frame-class chapter is deferred.
- [x] Record the `latex/BimodalReference.tex` decision: declared divergence this pass. Both `typst/README.md` and `latex/` README get an explicit "latex mirror is stale as of {DATE}; typst is authoritative" note in Phase 6; full latex sync is a follow-up task suggestion, not scope.
- [x] Record: Kamp/tasks 303/309-311 material appears only as a short "work in progress, not citable" note; paper's Objective Modality and 2D Semantics out of scope; `docs/reference/*.md` staleness flagged in the summary but not edited; paper §3.3 Extensions documented only where Lean-formalized (frame classes), else a one-line "not yet formalized" note.
- [x] Write all decisions into the preamble of `Theories/Bimodal/typst/SYNC-MAP.md` (created here, populated in Phase 1) so downstream phases and future tasks can cite them.

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/typst/SYNC-MAP.md` - new file: decisions preamble (claim table added in Phase 1)

**Verification**:
- SYNC-MAP.md exists with a filled "Scope Decisions" section including the confirmed-primary completeness theorem name and its file path in live source
- The primary-completeness decision cites at least one live-source evidence line (an import chain or theorem location), not a README/ROADMAP sentence

---

### Phase 1: Ground-Truth Inventory (SYNC-MAP) [COMPLETED]

**Goal**: Produce a complete claim -> verified/stale/not-found mapping for every Lean reference in the typst document, plus regenerated ground-truth counts, as the single factual basis for all chapter rewrites.

**Tasks**:
- [x] Extract every backtick-quoted Lean identifier, filename, and directory name from all 7 chapter files (`chapters/00-introduction.typ` ... `06-notes.typ`) and `BimodalReference.typ` (e.g., `grep -oE '\x60[^\x60]+\x60'` per file, deduplicated)
- [x] Grep-verify each extracted name against live `Theories/Bimodal/` **excluding `Boneyard/`** (`grep -rn --include='*.lean' -F "{name}" Theories/Bimodal --exclude-dir=Boneyard`); classify as `verified` (resolves, meaning matches), `stale` (resolves only in Boneyard or meaning changed), or `not-found`
- [x] Record the verdict table in `Theories/Bimodal/typst/SYNC-MAP.md` with columns: chapter:line, claimed name, verdict, live location (file:line) or replacement
- [x] Regenerate ground-truth counts from source and record them in SYNC-MAP: axiom constructor count and layer structure from the `inductive Axiom` block in `ProofSystem/Axioms.lean` (count the constructors; do NOT copy 42/41 from any document), sorry count per `Metalogic/` subdirectory (`grep -rc sorry` excluding Boneyard, comments filtered), frame-class list from `ProofSystem/Derivation.lean:85-93` and `Semantics/FrameConditions/` (confirm directory name from source)
- [x] Confirm sorry-free status of Soundness (`Metalogic/Soundness.lean`, `DenseSoundness.lean`, `DiscreteSoundness.lean`) and Perpetuity P1-P6 (`Theorems/Perpetuity/`) — research says both are genuinely sorry-free; verify, do not assume
- [x] Stamp SYNC-MAP with date and git commit hash of the Lean source it was generated against

**Timing**: 1.5 hours

**Depends on**: 0

**Files to modify**:
- `Theories/Bimodal/typst/SYNC-MAP.md` - claim table + regenerated counts appended

**Verification**:
- Every backticked name from all 7 chapters appears exactly once in the table with a verdict
- Counts section contains a constructor count and per-directory sorry counts each traceable to a recorded grep command
- `semantic_weak_completeness`, `FMP/`, `Representation/` all carry `stale` verdicts with Boneyard noted (sanity check against research finding 4)

---

### Phase 2: Rewrite 04-metalogic.typ [NOT STARTED]

**Goal**: Full rewrite of the Metalogic chapter to describe the actual live `Metalogic/` tree, the Phase-0-confirmed primary completeness path, and an honest regenerated sorry inventory.

**Tasks**:
- [x] Replace the architecture description: real subdirectory tree is `Core/`, `Bundle/`, `Algebraic/`, `BXCanonical/`, `WeakCanonical/`, `ConservativeExtension/`, `Decidability/`, `Relational/`, `SoundnessLemmas/` plus `Completeness.lean`, `Soundness.lean`, `DenseSoundness.lean`, `DiscreteSoundness.lean` (verify listing against filesystem at write time)
- [x] Delete all references to `semantic_weak_completeness`, `FMP/SemanticCanonicalModel.lean`, `Representation/`, and the "primary sorry-free completeness theorem" claim (all stale per SYNC-MAP; live only in Boneyard)
- [x] Present the Phase-0-confirmed primary completeness approach with its actual top-level theorem name(s) and file location; give the other active approaches (Bundle/BFMCS, BXCanonical, WeakCanonical, Algebraic) scoped secondary treatment — none silently dropped. Authorities: Phase 0 decision record; `Metalogic/Metalogic.lean:9-24`; `Metalogic/BXCanonical/Completeness.lean`; `Metalogic/README.md:11-13,21,23-28` (narrative cross-check only, self-warned stale)
- [x] Replace the sorry narrative: completeness is NOT sorry-free; use Phase 1 regenerated per-directory counts (research baseline: ~38-42 outside Boneyard — Chronicle/ChronicleToCountermodel ~20, WeakCanonical/TruthLemma ~20, Transfer ~17, BXCanonical/Completeness ~8, plus Kamp modules — but the landed numbers MUST be Phase 1's, stamped with date/commit). State plainly that Soundness (all 3 variants) and Perpetuity P1-P6 are sorry-free (as confirmed in Phase 1)
- [x] Delete the reflexive-semantics design narrative at `04-metalogic.typ:154` and its mis-citation of `02-semantics.typ`; the current semantics is strict/irreflexive per `Semantics/Truth.lean:10-17` and `Metalogic/Metalogic.lean:9-16` (task 93)
- [x] Fix the chapter-abstract axiom count (currently "15") to the Phase 1 regenerated count, consistent with ch03
- [x] Add a short "work in progress" note for the Kamp/discrete-completeness closure (tasks 303/309-311) without presenting results as settled
- [x] Compile check: `typst compile Theories/Bimodal/typst/BimodalReference.typ build/BimodalReference.pdf`

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - full rewrite

**Verification**:
- No occurrence of `semantic_weak_completeness`, `FMP`, `Representation/`, or "reflexive ... current" remains in the chapter
- Every Lean name in the rewritten chapter has a `verified` verdict in SYNC-MAP
- Document compiles

---

### Phase 3: Rewrite 03-proof-theory.typ [COMPLETED]

**Goal**: Full rewrite of the proof-theory chapter around the actual BX axiom system (all constructors, organized by layer) and the FrameClass parameter, with every axiom formula transcribed from the Lean `Axiom` constructors.

**Tasks**:
- [x] Replace the "14 axiom schemata" presentation with the full BX constructor listing from `ProofSystem/Axioms.lean:37` (Phase 1's regenerated count), organized by the layers as they appear in the source (research: Propositional / S5 Modal / BX Temporal x2 with primed past-mirrors / Modal-Temporal Interaction / Uniformity / Prior / Z1 / Density — confirm layer names and grouping from the source file's own structure/comments, not from this plan)
- [x] Transcribe each axiom's formula directly from its Lean constructor definition — every table cell checked against the actual `Axiom` constructor before landing; no formula re-derived from the paper or from the old chapter. In particular fix TL (typst currently states `always phi -> G H phi`; paper `:1103` has future-linearity; the Lean constructor is authoritative) and include TB/seriality if and as it exists in the constructors
- [x] Remove TK, T4, TA, TL, TF from the axiom listing where they are now derived theorems: `Axioms.lean:38,74,111-112` confirms temp_k_dist/temp_4 derived; derived homes in `Theorems/TemporalDerived.lean` (task 116). Present them in a "derived from BX" subsection with their theorem names
- [x] Document the `FrameClass` parameter on `DerivationTree` (`ProofSystem/Derivation.lean:85-93`): Base/Dense/Discrete, which axiom layers activate per class, and the correspondence to the paper's TM / TM+ / TM_F / TM_D / TM_C / TM_DC hierarchy (per Phase 0 scope decision)
- [x] Keep the 7 inference rules (axiom, assumption, modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening) — verified still accurate; re-check names against `ProofSystem/Derivation.lean` while editing
- [x] Add an exposition aside contrasting the paper's economical 12-schema core TM presentation (`possible_worlds.tex:1087-1105`) with the Lean constructor-level system, explaining the granularity difference (CPL combinators spelled out, primed past-mirrors, frame-class axioms)
- [x] Add any needed notation macros additively to `notation/bimodal-notation.typ` (e.g., frame-class axiom notation, TB); do not restructure existing macros
- [x] Compile check

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/typst/chapters/03-proof-theory.typ` - full rewrite
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` - additive macros only

**Verification**:
- Axiom table row count equals the Phase 1 constructor count; each row cites its constructor name
- No axiom row exists for a name lacking an `Axiom` constructor in live source; derived theorems appear only in the derived subsection
- Document compiles

---

### Phase 4: Rewrite 01-syntax.typ and Update 02-semantics.typ [COMPLETED]

**Goal**: Correct the syntax chapter to the Until/Since primitive basis and complete the semantics chapter with the Reflection constraint and Until/Since truth clauses (its strict truth conditions are already correct and must be preserved).

**Tasks**:
- [x] `01-syntax.typ:14-18`: replace the 6-primitive set `{atom, bot, imp, box, H, G}` with `{atom, bot, imp, box, untl, snce}` per `Syntax/Formula.lean:70-85` (Until/Since, Burgess convention: `untl(event, guard)` = Burgess `U(alpha, beta)`, event at witness, guard at intermediates — verify convention comment in source)
- [x] Present H/G/F/P as derived definitions with their actual Lean names (`Formula.all_future`, `Formula.all_past`, `Formula.some_future`, `Formula.some_past`, `Syntax/Formula.lean:109-155`), transcribing each definition from source
- [x] Add a note that the paper's base TM language (`possible_worlds.tex:~446`) uses H/G as primitives and that Lean's Until/Since basis is a conservative presentation change — Lean wins per task priority
- [x] `02-semantics.typ:34-38`: add the third Task Frame constraint, **Reflection** (`w =>_x u ==> u =>_{-x} w`), alongside Nullity and Compositionality; transcribe the formal statement from the Lean task-frame definition (locate in `Semantics/` — likely `TaskFrame.lean`; cite the found file:line in the chapter), cross-check paper `:902-907`
- [x] Add a `leanReflection` (or consistently-named) notation macro to `notation/bimodal-notation.typ`
- [x] Add truth clauses for `untl`/`snce` transcribed from `Semantics/Truth.lean`; PRESERVE the existing strict `<` truth conditions for H/G at `02-semantics.typ:85-90` (already correct — matches `Truth.lean:10-17` and paper `:948-949`)
- [x] Compile check

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/typst/chapters/01-syntax.typ` - rewrite primitives section
- `Theories/Bimodal/typst/chapters/02-semantics.typ` - add Reflection + untl/snce clauses (targeted edits)
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` - additive macros only

**Verification**:
- `01-syntax.typ` lists exactly the constructors of `inductive Formula` as primitives; derived operators carry their Lean `def` names
- `02-semantics.typ` states three frame constraints and truth clauses for all six primitives; strict `<` clauses unchanged
- Document compiles

---

### Phase 5: Rewrite 06-notes.typ, Fix 05-theorems.typ and 00-introduction.typ [COMPLETED]

**Goal**: Remove the reflexive-semantics self-contradiction, correct the historical/status tables, and align the light chapters with the counts and structure landed in Phases 2-4.

**Tasks**:
- [x] `06-notes.typ:118-126`: delete the "Reflexive Temporal Semantics (Current)" section and its mis-citation of `02-semantics.typ`; replace with a short, correct history note: reflexive semantics was superseded by the strict/irreflexive A2 guard convention in task 93 (`Semantics/Truth.lean:10-17`), under which the temporal T-axioms are not valid
- [x] Rewrite the discrepancy/axiom-naming tables in `06-notes.typ` against the Phase 3 landed axiom presentation (BX constructor names vs paper schema names; TK/T4/TA/TL/TF now derived)
- [x] Correct all sorry/status counts in `06-notes.typ` from the Phase 1 SYNC-MAP regenerated numbers (the "20 sorries, all deprecated" claim is wrong); stamp with date + commit
- [x] `05-theorems.typ`: spot-fix the module table — `Propositional`/`Perpetuity` are subdirectories of `Theorems/`, not single files; add `ContextualProofs.lean` and `TemporalDerived.lean`; verify the full `Theorems/` listing against the filesystem; state Perpetuity P1-P6 sorry-free status as confirmed in Phase 1
- [x] `00-introduction.typ`: fix the "14 axioms / 7 rules" summary to the Phase 1 counts (rules stay 7), fix the directory listing to the live tree, and align the chapter-by-chapter abstract sentences with the rewritten chapters
- [x] Add "in progress" framing for Kamp/task-303/309-311 anywhere these chapters mention discrete completeness status
- [x] Compile check

**Timing**: 1.5 hours

**Depends on**: 2, 3, 4

**Files to modify**:
- `Theories/Bimodal/typst/chapters/06-notes.typ` - rewrite stale narrative + tables
- `Theories/Bimodal/typst/chapters/05-theorems.typ` - module table spot-fixes
- `Theories/Bimodal/typst/chapters/00-introduction.typ` - counts, directory list, abstracts

**Verification**:
- No text anywhere in `typst/` asserts reflexive semantics is current (`grep -ri reflexive Theories/Bimodal/typst/` reviewed — remaining hits are historical-past-tense only)
- Introduction counts match ch03's landed axiom count and SYNC-MAP
- Document compiles

---

### Phase 6: Doc Hygiene and Verification Gate [NOT STARTED]

**Goal**: Land the hygiene fixes and enforce the Definition of Done: clean compile, all Lean references resolving in live source, all counts regenerated.

**Tasks**:
- [ ] Fix `Theories/Bimodal/typst/README.md:43`: dependency is `thmbox` (per `template.typ:10`), not `great-theorems`
- [ ] Remove (or move into `build/`) the stray top-level `BimodalReference.pdf` so output location matches the documented `build/` convention
- [ ] Add the Phase 0 latex-divergence note to `typst/README.md` (and the latex README if present): latex mirror stale as of {DATE}, typst authoritative; suggest follow-up task in the summary (do NOT edit `latex/` content)
- [ ] Verification gate 1 — compile: `typst compile Theories/Bimodal/typst/BimodalReference.typ build/BimodalReference.pdf` succeeds with no errors
- [ ] Verification gate 2 — reference resolution: re-run the Phase 1 extraction over the REVISED chapters against current HEAD; every backticked Lean name must resolve under `Theories/Bimodal` excluding `Boneyard/`; update SYNC-MAP verdicts to all-`verified` (any name resolving only in Boneyard is a bug — fix before closing)
- [ ] Verification gate 3 — counts: re-derive axiom constructor count, layer count, and sorry counts from HEAD and confirm the landed chapter text matches (regenerated, not copied); refresh SYNC-MAP date/commit stamp
- [ ] In the implementation summary, flag (without editing): `docs/reference/{axiom-reference,operators,tactic-reference}.md` staleness, and suggested follow-up tasks for latex/ sync and a `typst-sync-check.sh` drift detector

**Timing**: 1 hour

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/typst/README.md` - thmbox fix + divergence note
- `Theories/Bimodal/typst/SYNC-MAP.md` - final verdicts + re-stamp
- `Theories/Bimodal/typst/BimodalReference.pdf` - remove/relocate stray artifact

**Verification**:
- `typst compile` exit code 0
- Extraction re-run reports zero `stale`/`not-found` names across all 7 chapters
- SYNC-MAP final state: all verdicts `verified`, counts stamped with HEAD commit

## Testing & Validation

- [ ] `typst compile Theories/Bimodal/typst/BimodalReference.typ build/BimodalReference.pdf` succeeds (run per chapter phase and at the gate)
- [ ] Every backtick-quoted Lean identifier/filename in all 7 chapters resolves in live `Theories/Bimodal` source excluding `Boneyard/`
- [ ] Axiom count, layer structure, and per-directory sorry counts in the document match a fresh grep of `ProofSystem/Axioms.lean` and `Metalogic/` at completion HEAD
- [ ] No remaining claim that reflexive temporal semantics is current; no reference to `semantic_weak_completeness`, `FMP/`, or `Representation/`
- [ ] Primary completeness narrative matches the Phase 0 live-wiring verification, with Bundle/BXCanonical/WeakCanonical/Algebraic all mentioned as active approaches
- [ ] The 7 inference rules and the strict `<` truth conditions at `02-semantics.typ:85-90` are preserved (regression check — these were already correct)
- [ ] SYNC-MAP.md exists, is complete, and is stamped with date + source commit

## Artifacts & Outputs

- `Theories/Bimodal/typst/chapters/00-introduction.typ` … `06-notes.typ` (revised, 7 files)
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` (additive macros)
- `Theories/Bimodal/typst/SYNC-MAP.md` (new: scope decisions + claim-verification table — reusable deliverable)
- `Theories/Bimodal/typst/README.md` (hygiene + divergence note)
- `build/BimodalReference.pdf` (compiled output)
- `specs/312_revise_bimodalreference_typst_paper_lean/summaries/01_revise-typst-reference-summary.md` (implementation summary with follow-up task suggestions)

## Rollback/Contingency

All changes are documentation-only (no Lean source touched), scoped to `Theories/Bimodal/typst/` plus one README. Each phase commits independently per the commit-per-green-substep mandate, so any bad phase reverts with a targeted `git revert` of that phase's commit without touching other chapters. If `typst compile` breaks mid-phase and cannot be fixed forward quickly, revert only the offending chapter file to its last committed state (via snapshot-first discipline) and re-attempt. If Phase 0 cannot conclusively determine the primary completeness path from live source, ch04 presents the completeness approaches as a set of active parallel efforts (Bundle, BXCanonical/Chronicle, WeakCanonical, Algebraic) with the ROADMAP sorry-chain as the stated critical path, and the ambiguity is flagged in the summary for user adjudication — the task still completes.
