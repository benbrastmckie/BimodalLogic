# Implementation Plan: Reconcile LaTeX Metalogic Docs With Live Tree

- **Task**: 409 - reconcile_latex_metalogic_docs_with_live_tree
- **Status**: [COMPLETED]
- **Effort**: 6.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/409_reconcile_latex_metalogic_docs_with_live_tree/reports/01_latex-metalogic-live-tree-audit.md`
- **Artifacts**: plans/01_latex-metalogic-reconcile.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md,
  .claude/rules/no-task-references-in-deliverables.md
- **Type**: general
- **Lean Intent**: false

## Overview

`latex/subfiles/04-Metalogic.tex` and `latex/subfiles/06-Notes.tex` describe a metalogic
architecture that no longer exists: retired Lean identifiers (`representation_theorem`,
`semantic_weak_completeness`, `IndexedMCSFamily`, `main_provable_iff_valid`, …), missing file
paths (`FormalSystem/Metalogic/Representation/`), a false "Syntactic vs Semantic canonical
model" dichotomy, and a sorry inventory attributed to a module (`Metalogic_v2`) that was
deleted. This plan replaces every stale identifier and path with its live counterpart or
historicizes it, restates the completeness narrative around the live three-development
architecture (`BXCanonical/`, `WeakCanonical/`, `Algebraic/` over shared `Core/` and `Bundle/`),
and redraws both tikz diagrams and the status tables. Done means: both subfiles compile with
`pdflatex` exit 0 after every phase, no retired identifier from the audit table survives in
either file, and no claim is made that the live tree does not support.

### Research Integration

The audit report is authoritative and is not re-derived. Specifically integrated:

- The **identifier audit table** (report "Identifier Audit" section) supplies the stale-to-live
  mapping used verbatim in Phases 1, 2, 3, 4, 7, and 8. Every identifier flagged there has
  **zero** live hits outside `Boneyard/`.
- The **file-path audit** confirms `FormalSystem/Metalogic/Representation/TruthLemma.lean` and
  `.../Representation/UniversalCanonicalModel.lean` do not exist; there is no `Representation/`,
  `Completeness/`, or `Applications/` directory at all.
- The **live module layout** block supplies the replacement content for the directory tikz
  diagram in Phase 6.
- The **architecture narrative** (report points 1-5) supplies the replacement prose for
  Phases 2, 3, and 5.
- The **per-class completeness terminus table** supplies the exact sorry/axiom claims for
  Phases 1, 7, and 8.
- The **section-by-section rewrite plan** supplies the phase boundaries below, including which
  sections must NOT be touched.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and no roadmap review/update phases
were requested. The research report notes this work coordinates with (but does not own) the
completeness programme's strong-completeness leg tracked in `specs/ROADMAP.md`; nothing in this
plan writes to that file.

## Standing Constraints (apply to EVERY phase)

These are binding for the whole task, not per-phase advice. Any phase that violates one is
failed, not partially complete.

1. **Build lock — no Lean toolchain writes or builds.** A separate session owns the advisory
   build lock `.lake/.task-418-build.lock`. The implementation MUST NOT run `lake build`,
   `lake clean`, or the `lean_build` MCP tool.
2. **Write territory is `latex/subfiles/` only.** No file under `FormalSystem/` or `Tests/` may
   be created, edited, or deleted. Read-only `grep`/`Read` of `FormalSystem/` and read-only
   `lean-lsp` queries (`lean_hover_info`, `lean_declaration_file`, `lean_local_search`,
   `lean_verify`) are permitted and encouraged for confirming an identifier before writing it.
3. **Verification is `pdflatex` only.** The per-phase gate is, run from `latex/subfiles/`:
   ```
   TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 04-Metalogic.tex   # exit 0
   TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 06-Notes.tex       # exit 0
   ```
   Both compile standalone today (confirmed in research); both must still compile after every
   phase. A non-zero exit is a phase failure, not a warning to carry forward.
4. **No task-number citations in the `.tex` files.** Per
   `.claude/rules/no-task-references-in-deliverables.md`, `latex/` is a deliverable tree.
   Reference live module names, file paths, and theorem identifiers as durable anchors —
   never "task N", "(task N)", or a task-tracker reference. This applies to LaTeX comments as
   well as rendered text.
5. **Accuracy floor — three claims that must never be overstated.** Every phase that touches
   completeness status must respect:
   - `completeness` (Base frame class, `BXCanonical/Completeness.lean:196`) has **exactly one**
     live `sorryAx`, sourced from the deprecated `WeakCanonical.countermodel_discrete` fallback
     in its discrete branch. It is not sorry-free and must not be presented as such.
   - `completeness_dense` (`:255`) and `completeness_discrete` (`:296`) are **sorryAx-free**,
     axioms exactly `[propext, Classical.choice, Quot.sound]`.
   - **Unconditional `completeness_dedekind` DOES NOT EXIST.** Only the conditional
     `completeness_dedekind_of_engine` and `consequence_completeness_dedekind_of_engine`
     (`StrongCompleteness.lean:274,308`) are landed. The `.tex` must not claim an unconditional
     Dedekind terminus.
6. **Do NOT rewrite already-accurate sections.** `04-Metalogic.tex`'s "Strong Completeness and
   Compactness" subsection (lines 280-316 at baseline) is confirmed accurate against
   `StrongCompleteness.lean` and is explicitly out of scope. Also leave unchanged: the 15
   axiom-validity lemma names in the Soundness table, the Consistency and Lindenbaum
   subsections, the entire Decidability subsection (348-426), and the Decidability
   Implementation status table (493-511).
7. **Line numbers cited in this plan are baseline (pre-edit) positions and WILL DRIFT.** Every
   phase after Phase 1 edits `04-Metalogic.tex` and shifts subsequent line numbers. Locate
   sections by `\subsection`/`\subsubsection` heading text or by the identifier being replaced,
   never by the line number alone.

## Goals & Non-Goals

**Goals**:

- Replace or historicize every stale `\texttt{...}` Lean identifier and every stale
  `FormalSystem/` path in `latex/subfiles/04-Metalogic.tex` and `latex/subfiles/06-Notes.tex`,
  using the research report's audit table as the authoritative mapping.
- Restate the completeness-proof narrative around the live three-development architecture,
  replacing the false two-approach dichotomy and the retired quotient construction.
- Redraw the theorem-dependency tikz figure and the directory-structure tikz diagram against the
  live module layout and live theorem names.
- Replace the `Metalogic_v2` sorry inventory with the accurate live per-class sorry picture.
- Keep both files compiling with `pdflatex` at every phase boundary.

**Non-Goals**:

- Any edit under `FormalSystem/` or `Tests/`, or any `lake`/`lean_build` invocation.
- Rewriting the "Strong Completeness and Compactness" subsection (already accurate).
- Fixing drift found in other subfiles. The audit flagged `00-Introduction.tex` (stale
  `Bimodal/` root name) and `05-Theorems.tex` (`Propositional.lean` is now a directory); both
  are recorded in the research report as out of scope and are deliberately left for a follow-up.
- Landing any new Lean result, or presenting an in-flight result as landed.
- Rewriting `06-Notes.tex`'s Discrepancy Notes / Terminology / Axiom Naming / M5 Collapse or
  Decidability Implementation subsections (confirmed accurate).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| tikz redraw breaks compilation (node/anchor/coordinate errors) | H | M | Phases 4 and 6 isolate one diagram each; compile immediately after the redraw, before any adjacent prose edit. Keep the existing `box`/`dirbox`/`arrow` style definitions and node-anchor idiom rather than introducing new tikz libraries. |
| Line numbers in this plan drift as earlier phases edit the file, causing a later phase to edit the wrong region | H | H | Standing Constraint 7: locate by heading text or by the target identifier, never by line number. Each phase's Scope Hypothesis names the anchor text to grep for. |
| A "live replacement" identifier is written from the report without re-confirmation and is itself stale or misspelled | M | L | Read-only `grep -rn '<id>' FormalSystem/ --include='*.lean' \| grep -v Boneyard` before writing any new identifier. This is permitted under the build lock (read-only). |
| Deleting a `\subsubsection` or `\label` breaks an in-file `\Cref` or the parent document `BimodalReference.tex` | M | M | Only one label exists in the file (`\label{fig:theorem-deps}`, referenced once at the same file's line 192). Phase 4 keeps that label name. Phase 1 records a parent-document compile baseline; Phase 9 re-checks it. |
| Overstating a completeness result (especially an unconditional Dedekind terminus) | H | M | Standing Constraint 5 pins the exact three claims; Phases 1, 7, and 8 each restate them as explicit success criteria. |
| Author `% FIX`/`% TODO` comments in the rewritten regions get silently dropped | M | M | Phases 2 and 5 explicitly require each comment be resolved-in-place or carried forward with updated wording; deletion without either is a phase failure. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 8 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 9 | 7, 8 |

Phases within the same wave can execute in parallel. Phases 2-7 are a strict chain because they
all write `04-Metalogic.tex`; Phase 8 writes only `06-Notes.tex` and is therefore
parallel-eligible with that chain.

---

### Phase 1: Baseline Capture and Low-Risk Identifier Corrections [COMPLETED]

**Goal**: Establish the compile baseline (including the parent document) and land the three
single-token corrections in sections that are otherwise already accurate, so the riskier
rewrites start from a known-green, known-correct state.

**Tasks**:

- [x] From `latex/subfiles/`, run both required `pdflatex` commands and record the exit codes as
      the pre-edit baseline. *(completed: both exit 0)*
- [x] From `latex/`, run `pdflatex -interaction=nonstopmode BimodalReference.tex` once and record
      its exit code as the parent-document baseline (used by Phase 9 for comparison; a
      pre-existing parent failure must be recorded now, not discovered at the end). *(completed:
      exit 1, pre-existing failure — missing `bimodal-notation.sty`, unrelated to this task and
      to `latex/subfiles/`'s own `../assets` TEXINPUTS; recorded as the Phase 9 comparison
      baseline)*
- [x] In the Soundness subsection, replace `\texttt{WorldHistory.time\_shift}` with
      `\texttt{WorldHistory.timeShift}` (live def, `FormalSystem/Semantics/WorldHistory.lean:246`).
      Optionally note the mixed convention: the def is camelCase, its supporting lemmas
      (`time_shift_domain_iff`, `time_shift_inverse_domain`, `time_shift_time_shift_states`,
      `time_shift_congr`) are snake_case. *(completed)*
- [x] In the Weak Completeness subsection, replace the footnote's `semantic\_weak\_completeness`
      with the live per-class set: `completeness` (Base, `BXCanonical/Completeness.lean:196`,
      carrying one live `sorryAx` from the deprecated `WeakCanonical.countermodel_discrete`
      fallback), `completeness_dense` (`:255`, sorryAx-free), `completeness_discrete` (`:296`,
      sorryAx-free). Leave the surrounding proof-sketch prose alone — generic contrapositive
      reasoning, still accurate. *(completed)*
- [x] In the Consequence Completeness subsection, correct the cited declaration name to
      `consequence_completeness_dedekind_of_engine` (with the `_of_engine` suffix). Do not
      otherwise rewrite this subsection. *(completed)*
- [x] Confirm no task-number citation was introduced. *(completed: grep for task-number patterns
      in 04-Metalogic.tex returns no hits)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts exactly three edit sites in `04-Metalogic.tex`
(`WorldHistory.time_shift` at baseline line 54; the Weak Completeness footnote at baseline
233-247; the Consequence Completeness footnote at baseline 249-278) and zero edits elsewhere.
Confirm at implementation time by `grep -n 'time_shift\|semantic_weak_completeness\|consequence_completeness'
latex/subfiles/04-Metalogic.tex` before and after; the after-count for the first two patterns
must be 0 within this file's Soundness and Weak Completeness regions. If grep reveals additional
occurrences beyond the three sites, record them and handle them here rather than deferring.

**Files to modify**:

- `latex/subfiles/04-Metalogic.tex` — three identifier corrections in already-accurate sections.

**Verification**:

- From `latex/subfiles/`: `TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 04-Metalogic.tex`
  exits 0.
- From `latex/subfiles/`: `TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 06-Notes.tex`
  exits 0.
- `grep -n 'time\\_shift' latex/subfiles/04-Metalogic.tex` returns no hit for the retired
  `WorldHistory.time_shift` form.
- Parent-document baseline exit code recorded in the phase notes.

---

### Phase 2: Rewrite Canonical World States Against the Live Construction [COMPLETED]

**Goal**: Replace the retired quotient-of-(history,time)-pairs construction with the live
`Bundle/` + `BXCanonical/` picture, eliminating `SemanticTaskRelV2`, `SemanticWorldState`,
`IndexedMCSFamily D`, `canonical_model D family`, the bare `truth_lemma` name, and the missing
`FormalSystem/Metalogic/Representation/TruthLemma.lean` path.

**Tasks**:

- [x] Rewrite the `\subsubsection{Canonical World States}` block (baseline 111-164). Replacement
      content, from the research report's architecture narrative:
      - `FMCS` ("Family of MCS", `FormalSystem/Metalogic/Bundle/FMCSDef.lean`) — a single
        time-indexed family of maximal consistent sets; the direct conceptual successor to the
        retired `IndexedMCSFamily`.
      - `BFMCS` ("Bundle of FMCS", `FormalSystem/Metalogic/Bundle/BFMCS.lean`) — a bundle of
        `FMCS` instances with modal coherence; the successor to the retired "canonical model"
        role. Structurally a *bundle*, not a quotient, precisely so `□` quantifies over the
        bundled histories rather than all histories.
      - The chain construction: `BXCanonical/CanonicalChain.lean` and
        `BXCanonical/CanonicalModel.lean` build a `BFMCS Int` by resolving formulas along an
        enumeration schedule using forward/backward temporal witness seeds
        (`Bundle/WitnessSeed.lean`).
      - Task-relatedness is realized per-development (`BXCanonical.CanonicalTaskRelation`,
        `Bundle/CanonicalTaskRelation.lean`) — there is no single live "task relation" type
        playing the retired `SemanticTaskRelV2` role, and the rewrite must not invent one.
      - The truth lemma is per-development: `BXCanonical/TruthLemma.lean`,
        `WeakCanonical/TruthLemma.lean`, `Algebraic/ParametricTruthLemma.lean` (plus
        `RestrictedParametricTruthLemma.lean`). Cite the `BXCanonical/` one as the lemma feeding
        the landed completeness theorems.
- [x] Delete the retired `\texttt{SemanticWorldState}` footnote and the "quotient construction"
      paragraph (baseline 162-164) rather than patching them — the construction they describe
      does not exist. *(completed)*
- [x] Rename `\subsection{Representation Theory}` (baseline 106) to a name that matches the live
      architecture (e.g. `Canonical Model Construction`) and update its two-sentence lead-in
      (108-109), which currently presents the Representation Theorem as "the core of the
      metalogic". No `\label` is attached to this heading and nothing `\Cref`s it, so the rename
      is compile-safe — confirm with a grep before renaming. *(completed: confirmed no
      `\label`/`\Cref` targets this heading; renamed to "Canonical Model Construction")*
- [x] Resolve or carry forward the four author comments in this region (baseline 116, 130, 132,
      160). Each must either be resolved by the rewrite (and removed with the resolution
      reflected in the new prose) or restated against the live construction. Silently deleting
      one is a phase failure. In particular the comment at 130 (whether integers force time to
      be discrete, versus a frame's temporal order being any totally ordered commutative group)
      is a live open design question about the `BFMCS Int` instantiation and should be carried
      forward, not dropped. *(completed: 116 and 132 resolved by the rewrite itself — the new
      definitions are precise and the world-state terminology is folded into FMCS/BFMCS, so both
      comments are removed; 130 and 160 are restated as `% TODO` comments carried forward,
      updated to reference the live `BFMCS Int` construction)*

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the rewrite is confined to baseline lines 106-164 of
`04-Metalogic.tex` (the `Representation Theory` subsection lead-in through the end of the
quotient-construction paragraph), and that five retired identifiers (`SemanticTaskRelV2`,
`SemanticWorldState`, `IndexedMCSFamily`, `canonical_model`, `truth_lemma`) plus one missing path
(`Metalogic/Representation/TruthLemma.lean`) all occur within it. Confirm by grepping each
identifier across the whole file before editing: `IndexedMCSFamily` is known to also occur in the
File Organization prose (baseline 430) and the Metalogic status table (baseline 523), which are
Phases 6 and 7's territory — do not fix them here, but do confirm the split matches expectation
and record any occurrence found outside all three regions.

**Files to modify**:

- `latex/subfiles/04-Metalogic.tex` — Canonical World States subsection and its parent subsection
  heading/lead-in.

**Verification**:

- From `latex/subfiles/`: `TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 04-Metalogic.tex`
  exits 0.
- From `latex/subfiles/`: `TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 06-Notes.tex`
  exits 0.
- `grep -c 'SemanticTaskRelV2\|SemanticWorldState' latex/subfiles/04-Metalogic.tex` returns 0.
- `grep -n 'Metalogic/Representation' latex/subfiles/04-Metalogic.tex` returns no hit for
  `Representation/TruthLemma.lean`.
- Every new Lean identifier written in this phase has a confirmed non-`Boneyard` hit under
  `FormalSystem/`.

---

### Phase 3: Retire the Representation Theorem and Provable-iff-Valid Statements [COMPLETED]

**Goal**: Remove the two theorem environments that have no live counterpart
(`representation_theorem`, `strong_representation_theorem`, `main_provable_iff_valid`) and
replace them with an accurate account of how the argument is actually structured live.

**Tasks**:

- [x] Replace the `\subsubsection{Representation Theorem}` block (baseline 166-188). No live 1:1
      analogue exists for either `representation_theorem` or `strong_representation_theorem`.
      The replacement must state that the argument those theorems encapsulated — consistent set
      to Lindenbaum extension to canonical world to truth lemma to satisfiability — is now
      **inlined directly inside each `completeness*` proof** in
      `FormalSystem/Metalogic/BXCanonical/Completeness.lean` (`set_lindenbaum`, then a case
      split on dense/discrete/mixed, then `countermodel_*`, then contradiction with the semantic
      validity hypothesis), rather than factored into a standalone reusable theorem. Do not hunt
      for a name replacement; there is none.
- [x] Preserve the two still-accurate elements of that block: the `\texttt{contextToSet}`
      citation (live, `Core/MaximalConsistent.lean:123`) and the proof-strategy enumeration,
      restated against the inlined structure. *(completed)*
- [x] Replace the `\begin{theorem}[Provable iff Valid]` block (baseline 318-324). No
      unconditional `⊢ φ ↔ ⊨ φ` declaration exists live under any name. Replace with a paragraph
      stating the biconditional holds compositionally per frame class, pairing
      `completeness`/`completeness_dense`/`completeness_discrete` (right-to-left,
      `BXCanonical/Completeness.lean`) with `soundness`/`soundness_dense`/`soundness_discrete`
      (left-to-right, `FormalSystem/Metalogic/Soundness.lean`), and noting it is not available
      under a single declaration name. The existing follow-on prose about soundness and
      completeness aligning is accurate and can be kept. *(completed)*
- [x] Do not touch the intervening Weak Completeness, Consequence Completeness, or Strong
      Completeness and Compactness subsections. *(completed: confirmed unchanged)*

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts exactly two edit regions (baseline 166-188 and 318-324)
and that `representation_theorem`, `strong_representation_theorem`, and
`main_provable_iff_valid` occur only there and in the Metalogic Implementation status table
(baseline 525, 528 — Phase 7's territory). Confirm with
`grep -n 'representation\\_theorem\|main\\_provable\\_iff\\_valid' latex/subfiles/04-Metalogic.tex`
before editing; any occurrence outside those three regions must be handled here.

**Files to modify**:

- `latex/subfiles/04-Metalogic.tex` — Representation Theorem subsection and the Provable iff
  Valid theorem environment.

**Verification**:

- From `latex/subfiles/`: both required `pdflatex` commands exit 0.
- `grep -c 'strong\\_representation\\_theorem' latex/subfiles/04-Metalogic.tex` returns 0.
- No claim of an unconditional biconditional survives outside the per-class framing.
- The file's single `\label{fig:theorem-deps}` and its `\Cref` are untouched (no "undefined
  reference" warning introduced in the `.log`).

---

### Phase 4: Redraw the Theorem Dependency Diagram [COMPLETED]

**Goal**: Replace the tikz figure whose central node is the retired `representation_theorem`
with a diagram of the live dependency structure.

**Tasks**:

- [x] Redraw the `\begin{figure}` / `tikzpicture` block (baseline 195-224) against the live
      structure:
      - Foundations layer: `Core/` — `deductionTheorem` (and the newer dot-notation form
        `Derivable.deduction`, `Core/DeductionTheorem.lean`), `set_lindenbaum`,
        `MaximalConsistent` (all `Core/MaximalConsistent.lean`).
      - Construction layer: `Bundle/` — `FMCS` / `BFMCS`, feeding
        `BXCanonical/CanonicalModel.lean`.
      - Truth-lemma layer: `BXCanonical/TruthLemma.lean`.
      - Terminus layer: `BXCanonical/Completeness.lean` — `completeness`, `completeness_dense`,
        `completeness_discrete`; and `StrongCompleteness.lean` —
        `consequence_completeness_dedekind_of_engine`.
      - The retired `deduction_theorem` node label becomes `deductionTheorem`; the
        `representation_theorem` node is removed entirely, not renamed.
- [x] Keep the `\label{fig:theorem-deps}` name unchanged so the in-file `\Cref` at baseline 192
      still resolves. Update the caption and the surrounding lead-in (192-193) and follow-on
      (226-227) prose, both of which currently describe the Representation Theorem as the
      central node. *(completed: confirmed exactly two hits for `fig:theorem-deps` in `latex/`,
      no undefined-reference warning after a second `pdflatex` pass)*
- [x] Reuse the existing `box`/`arrow` tikz style definitions and the existing node-anchor
      arrow idiom. Do not introduce new tikz libraries or packages — `formatting.sty` under
      `latex/assets/` is not in this task's write territory. *(completed: same style names/idiom
      reused, one new style `teal!15` fill color added inline, no new tikz libraries)*
- [x] Per the research report's mitigation, name the aggregator files (`Core.lean`,
      `BXCanonical.lean`, `WeakCanonical.lean`, `Algebraic.lean`, `Bundle.lean`) in the caption
      or an adjacent footnote, so a future reconciliation pass can re-derive the diagram from
      those docstrings rather than walking the whole module tree. *(completed)*

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: This phase asserts the figure occupies baseline lines 195-224 with lead-in
at 192-193 and follow-on at 226-227, and that exactly one `\label` (`fig:theorem-deps`) and one
`\Cref` to it exist in the repository. Confirm with
`grep -rn 'fig:theorem-deps' latex/` — expect exactly two hits, both in
`latex/subfiles/04-Metalogic.tex`. More hits means an external reference exists and the label
must be preserved verbatim (it is preserved either way; the check exists to catch a
parent-document dependency before it breaks).

**Files to modify**:

- `latex/subfiles/04-Metalogic.tex` — theorem dependency figure and its surrounding prose.

**Verification**:

- From `latex/subfiles/`: both required `pdflatex` commands exit 0.
- `04-Metalogic.log` contains no `LaTeX Warning: Reference \`fig:theorem-deps' ... undefined`.
- From `latex/`: `pdflatex -interaction=nonstopmode BimodalReference.tex` exit code matches the
  Phase 1 parent baseline (the `interface` tier's enumerated dependent is the parent document).
- No node label in the figure names a retired identifier.

---

### Phase 5: Replace the Two-Approach Dichotomy With the Live Architecture [COMPLETED]

**Goal**: Replace the false "Syntactic (Boneyard) vs Semantic (quotient)" dichotomy with the
live three-development architecture. This is the single largest architecture-fidelity gap in the
chapter.

**Tasks**:

- [x] Rewrite the `\subsubsection{Two Canonical Model Approaches}` block (baseline 326-346),
      including retitling it (the "two approaches" framing is itself the error). Replacement
      content, from the research report's architecture narrative point 2 — three parallel,
      independently-developed completeness routes over a shared foundation:
      - **Shared foundation** `Core/`: `Consistent`, `MaximalConsistent`, `SetConsistent`,
        `SetMaximalConsistent`, `set_lindenbaum`, `contextToSet`, `deductionTheorem` /
        `Derivable.deduction`. Not tied to any one route.
      - **`BXCanonical/`** — the BX (chronicle/Henkin-style) route; builds a `BFMCS Int` via the
        chain construction and is the home of the landed `completeness*` theorems.
      - **`WeakCanonical/`** — the Reynolds/Doets discrete route, including the large `Kamp/`
        subtree (Kamp's-theorem-style normal-form translation machinery bridging temporal
        formulas to monadic first-order structures for the Doets k-types argument). Its export
        `countermodel_discrete` (`WeakCanonical/Transfer.lean`) is the **deprecated** fallback
        still wired into the general `completeness` theorem's discrete branch and is the sole
        sorry source; its sorry-free sibling `countermodel_discrete_reynolds_v2`
        (`WeakCanonical/IntegerModel/ReynoldsBridge.lean:739`) is what `completeness_discrete`
        actually uses. These are two different pipelines and must not be conflated.
      - **`Algebraic/`** — the Lindenbaum-Tarski quotient-algebra route
        (`LindenbaumQuotient.lean`, `ParametricCanonical.lean`, `ParametricTruthLemma.lean`,
        `UltrafilterMCS.lean`). Closest in spirit to the retired quotient prose, but a *third*
        independently-developed route, not the same construction renamed, and not currently the
        route feeding the landed `completeness*` theorems.
      - **`Bundle/`** supplies the shared canonical-frame vocabulary (`FMCS`, `BFMCS`) used by
        `BXCanonical/`.
- [x] Historicize rather than delete the syntactic-approach paragraph: the claim that world
      states are directly identified with maximal consistent sets, with accessibility via modal
      witnesses, and that this line is archived in `Boneyard/`, remains accurate. Present it as
      archived history, not as one of two current approaches. *(completed)*
- [x] Preserve or explicitly resolve the author comment at baseline 331 (arguing the syntactic
      approach is in the correct spirit and should be ported from `Boneyard/`). It is a live
      design position, not stale text; silently dropping it is a phase failure. *(completed:
      restated as a `% TODO` comment against the live three-development architecture)*
- [x] Do not claim any route is "primary" beyond the verifiable fact that `BXCanonical/` is where
      the landed `completeness*` theorems live. *(completed; also fixed a stale Phase-4 caption
      cross-reference to this subsection's old name, discovered during this phase's compile
      check)*

**Timing**: 1.25 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the rewrite is confined to baseline lines 326-346, and
that the three-development split is not described anywhere else in the file (i.e. this is the
only place the architecture is narrated at this level). Confirm by grepping for `BXCanonical`,
`WeakCanonical`, and `Algebraic` across `latex/subfiles/04-Metalogic.tex` after Phases 2-4 have
landed: hits are expected in the Canonical World States rewrite (Phase 2) and the dependency
figure (Phase 4); a hit in any *other* region indicates an overlap to reconcile here.

**Files to modify**:

- `latex/subfiles/04-Metalogic.tex` — Two Canonical Model Approaches subsection.

**Verification**:

- From `latex/subfiles/`: both required `pdflatex` commands exit 0.
- The rendered section names all three live developments and the shared `Core/`/`Bundle/`
  foundation, and contains no "two approaches" framing.
- The deprecated `countermodel_discrete` and the sorry-free `countermodel_discrete_reynolds_v2`
  are described as distinct pipelines.
- The author comment at baseline 331 is present (possibly reworded) or its resolution is stated
  in the new prose.

---

### Phase 6: Rewrite File Organization Prose and the Directory Diagram [COMPLETED]

**Goal**: Replace the stale directory tikz diagram and its prose. `Representation/`,
`Completeness/`, and `Applications/` do not exist; `Soundness` is a file not a directory; there
is no top-level `FMP.lean` hub.

**Tasks**:

- [x] Rewrite the lead-in prose (baseline 428-432), removing the claim that the active metalogic
      uses "the `IndexedMCSFamily` approach" and the `Boneyard/Metalogic_v2/` framing of the live
      organization. *(completed)*
- [x] Redraw the directory `tikzpicture` (baseline 434-465) against the live top-level layout
      from the research report's module-layout block:
      - `Core/` (shared foundations) at the base.
      - Three parallel routes above it: `BXCanonical/`, `WeakCanonical/`, `Algebraic/`.
      - `Bundle/` (shared BFMCS canonical-frame construction) feeding `BXCanonical/`.
      - `Soundness.lean` and `SoundnessLemmas/` as top-level file/directory, and
        `StrongCompleteness.lean` as a top-level file — not directories.
      - `Decidability/` (tableau decision procedure), with `Decidability/FMP/FMP.lean` shown as
        nested inside it, not as a top-level central hub.
      - Remove the `Representation/`, `Completeness/`, and `Applications/` nodes entirely.
      *(completed: confirmed every retained directory/file exists on disk via read-only `ls`)*
- [x] Rewrite the "Directory descriptions" itemize list (baseline 467-476) to match the new
      diagram, one entry per live node. *(completed)*
- [x] Reuse the existing `dirbox`/`arrow` style definitions; introduce no new tikz libraries.
      *(completed)*
- [x] Keep the diagram summary-level. `WeakCanonical/Kamp/` (~90 files) and
      `Decidability/Verified/` are large internal machinery and should be named, not expanded.
      *(completed)*

**Timing**: 1.25 hours

**Depends on**: 5

**Verification Tier**: local

**Commit Mode**: atomic-batch

**Scope Hypothesis**: This phase asserts the region is baseline lines 428-476 and that after it
lands, no reference to a non-existent directory (`Metalogic/Representation/`,
`Metalogic/Completeness/`, `Metalogic/Applications/`) survives anywhere in
`latex/subfiles/04-Metalogic.tex`. Confirm with
`grep -n 'Representation/\|Completeness/\|Applications/' latex/subfiles/04-Metalogic.tex`
returning zero hits for those three paths after the edit. Also confirm each retained directory
name against the filesystem with a read-only
`ls FormalSystem/Metalogic/` before writing it — the diagram is the most drift-prone artifact in
the chapter.

**Files to modify**:

- `latex/subfiles/04-Metalogic.tex` — File Organization and Dependencies subsection (prose,
  tikz diagram, and directory-description list).

**Verification**:

- From `latex/subfiles/`: both required `pdflatex` commands exit 0.
- `grep -c 'IndexedMCSFamily' latex/subfiles/04-Metalogic.tex` shows only the remaining status
  table occurrence (Phase 7's territory), or 0.
- Every directory named in the diagram exists under `FormalSystem/Metalogic/` (verified by
  read-only `ls`).
- No node names `Representation/`, `Completeness/`, or `Applications/`.

---

### Phase 7: Replace the Sorry Inventory and the Metalogic Status Table [COMPLETED]

**Goal**: Replace the `Metalogic_v2` sorry inventory (describing a module that no longer exists)
with the accurate live per-class picture, and update the Metalogic Implementation table's "Lean"
column to live identifiers.

**Tasks**:

- [x] Replace the `\subsubsection{Sorry Status}` block (baseline 480-491) entirely. The three
      listed sorries (`semantic_task_rel_compositionality`, `main_provable_iff_valid_v2`,
      `finite_model_property_constructive`) are all in modules that no longer exist
      (`SemanticCanonicalModel.lean`, `FiniteModelProperty.lean`, all of `Metalogic_v2`).
      Replacement content, exactly per Standing Constraint 5:
      - `completeness` (Base, `BXCanonical/Completeness.lean:196`) carries **exactly one** live
        `sorryAx`, sourced from the deprecated `WeakCanonical.countermodel_discrete` fallback in
        its discrete branch. Its dense branch (`countermodel_dense_enriched`) and mixed branch
        (`Chronicle.mcs_mixed_case_absurd`) are individually sorryAx-free.
      - `completeness_dense` (`:255`) and `completeness_discrete` (`:296`) are **sorryAx-free**,
        axioms exactly `[propext, Classical.choice, Quot.sound]`.
      - Unconditional `completeness_dedekind` **does not exist**; only
        `completeness_dedekind_of_engine` and `consequence_completeness_dedekind_of_engine`
        (`StrongCompleteness.lean:274,308`) are landed, both conditional on a supplied
        single-formula completeness engine hypothesis.
      - State the blocker specifically, not vaguely: per `Completeness.lean`'s own docstring, the
        underlying `succ_cofinal` argument behind `WeakCanonical.countermodel_discrete` is
        characterized as provably unfixable and has been archived; closing it needs a genuine new
        construction (a Base-to-Discrete MCS transfer or a Henkin-style discrete model), not a
        re-wiring. A future reader must be able to tell at a glance whether the blocker is still
        open.
      - Delete the now-false claim that "the core completeness result
        `semantic_weak_completeness` is fully proven without sorries". *(completed)*
- [x] Rewrite the `\subsubsection{Metalogic Implementation}` table's "Lean" column (baseline
      513-533), row by row, per the audit table:
      - `deduction_theorem` -> `deductionTheorem` (with `Derivable.deduction` as the general
        dot-notation form).
      - `set_lindenbaum` -> unchanged (live).
      - `IndexedMCSFamily` row -> replace with `FMCS` / `BFMCS` (`Bundle/`).
      - `truth_lemma` -> per-development truth lemmas; cite `BXCanonical/TruthLemma.lean`.
      - `representation_theorem` row -> remove (no live analogue; the argument is inlined).
      - `semantic_weak_completeness` -> `completeness` / `completeness_dense` /
        `completeness_discrete`, with the Base-case sorry caveat in the Status column.
      - `consequence_completeness_*` -> `consequence_completeness_dedekind_of_engine`, with the
        conditional-on-engine caveat.
      - `main_provable_iff_valid` row -> remove or restate as per-class compositional.
      - `finite_model_property` -> `mcs_finite_model_property`
        (`Decidability/FMP/FMP.lean:204`), used by `Decidability/Correctness.lean:177`.
      - `soundness` and `decide_sound` -> unchanged (both live).
      *(completed: verified `mcs_finite_model_property` at `FMP.lean:204` and its use at
      `Correctness.lean:177` via read-only grep; removed the Representation Theorem and Provable
      iff Valid rows rather than restating them, since Phase 3 already gives the latter a full
      paragraph treatment)*
- [x] Update the trailing footnote (baseline 535-540). Its terminology distinction (consequence
      vs strong completeness) is already correct and must be preserved; only its final sentence
      ("The three sorries listed above affect only the finite model property path") is false and
      must be replaced. *(completed)*
- [x] Do NOT touch the Decidability Implementation table (baseline 493-511) — confirmed accurate.
      *(completed: confirmed byte-identical via diff)*

**Timing**: 1.25 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts eleven rows in the Metalogic Implementation table and
one Sorry Status block, and that after it lands, zero retired identifiers from the research
report's audit table survive anywhere in `04-Metalogic.tex`. Confirm at implementation time by
running the residual sweep over the full audit identifier list (see Phase 9) scoped to this file;
a non-zero count means either a row was missed here or an occurrence exists outside the regions
Phases 1-6 claimed, and must be resolved before the phase closes.

**Files to modify**:

- `latex/subfiles/04-Metalogic.tex` — Sorry Status subsection, Metalogic Implementation table,
  and the trailing footnote.

**Verification**:

- From `latex/subfiles/`: both required `pdflatex` commands exit 0.
- `grep -c 'Metalogic\\_v2\|SemanticCanonicalModel\|FiniteModelProperty\|semantic\\_task\\_rel\\_compositionality\|finite\\_model\\_property\\_constructive'
  latex/subfiles/04-Metalogic.tex` returns 0.
- The three accuracy-floor claims (one Base sorry; dense/discrete sorryAx-free; no unconditional
  Dedekind) are each stated and none is overstated.
- The Decidability Implementation table is byte-identical to its pre-phase state.

---

### Phase 8: Reconcile 06-Notes.tex [COMPLETED]

**Goal**: Update `06-Notes.tex`'s Completeness Status bullets and the Implementation Status
summary row, leaving its confirmed-accurate sections untouched.

**Tasks**:

- [x] Replace the retired identifiers in the `\subsubsection{Completeness Status}` bullet list
      (baseline 72-77):
      - `set_lindenbaum` -> unchanged (live).
      - `semantic_truth_lemma_v2` -> the per-development truth lemmas; cite
        `BXCanonical/TruthLemma.lean`. There is no single live name playing this role.
      - `semantic_weak_completeness` -> `completeness` / `completeness_dense` /
        `completeness_discrete`, same replacement as `04-Metalogic.tex`.
      - `main_provable_iff_valid` -> removed or restated per-class compositionally.
      *(completed)*
- [x] Replace the "world states as equivalence classes of history-time pairs" prose (baseline 78)
      with the `FMCS`/`BFMCS` bundle picture. *(completed)*
- [x] Update the sorry caveat (baseline 79) to name the current single sorry source — the
      deprecated `WeakCanonical.countermodel_discrete` in the general `completeness` theorem's
      discrete branch — rather than a generic "bridge sorries remain". **Preserve this line's
      terminology verbatim** where it distinguishes the finite-context form from strong
      completeness over infinite premise sets; that wording is already correct and only the
      sorry-count/identifier claims change. *(completed: the finite-context/strong-completeness
      sentence is preserved verbatim)*
- [x] In the Implementation Status summary table (baseline 8-23), change the Completeness row's
      "Semantic" qualifier — now ambiguous, since three developments exist — to a per-class
      statement (Base proven modulo one sorry; Dense and Discrete proven sorry-free; Dedekind
      conditional only). *(completed)*
- [x] Do NOT touch: Discrepancy Notes, Terminology, Axiom Naming, M5 Collapse Axiom (all ten
      `Axiom.*` names confirmed live), or the Decidability Implementation subsection.
      *(completed: confirmed byte-identical via diff)*

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts exactly three retired identifiers in `06-Notes.tex`
(`semantic_truth_lemma_v2`, `semantic_weak_completeness`, `main_provable_iff_valid`) and two edit
regions (baseline 8-23 and 67-79). Confirm with
`grep -n 'semantic\\_truth\\_lemma\\_v2\|semantic\\_weak\\_completeness\|main\\_provable\\_iff\\_valid' latex/subfiles/06-Notes.tex`
before and after; the after-count must be 0.

**Files to modify**:

- `latex/subfiles/06-Notes.tex` — Implementation Status summary row and Completeness Status
  subsection.

**Verification**:

- From `latex/subfiles/`: `TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 06-Notes.tex`
  exits 0.
- From `latex/subfiles/`: `TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 04-Metalogic.tex`
  exits 0 (unchanged by this phase, but the gate runs on both files every phase).
- The three retired identifiers return zero grep hits in `06-Notes.tex`.
- The Axiom Naming and M5 Collapse subsections are byte-identical to their pre-phase state.

---

### Phase 9: Residual Sweep and Full-Document Verification [COMPLETED]

**Goal**: Prove no retired identifier or missing path survives in either target file, fix any
that do, and confirm the parent document still compiles.

**Tasks**:

- [x] Run a residual sweep over both target files for the full retired-identifier list from the
      research report's audit table: `semantic_weak_completeness`, `main_provable_iff_valid`,
      `main_provable_iff_valid_v2`, `representation_theorem`, `strong_representation_theorem`,
      `deduction_theorem` (bare, not `deductionTheorem`), `semantic_task_rel_compositionality`,
      `finite_model_property_constructive`, `semantic_truth_lemma_v2`, `IndexedMCSFamily`,
      `canonical_model`, `SemanticTaskRelV2`, `SemanticWorldState`, `WorldHistory.time_shift`,
      `Metalogic_v2`, `SemanticCanonicalModel`, `FiniteModelProperty`. Expected count: 0 in both
      files. Fix any survivor here rather than reporting it. *(completed: all 17 return 0 in
      both files)*
- [x] Run a residual sweep for stale paths: `Metalogic/Representation/`, `Metalogic/Completeness/`,
      `Metalogic/Applications/`. Expected count: 0. *(completed: 0 hits)*
- [x] Spot-check that every `FormalSystem/...` path now cited in either file exists on disk
      (read-only `ls`/`test -f`), and that every `\texttt{...}` Lean identifier now cited has a
      non-`Boneyard` hit under `FormalSystem/`. *(completed: every cited `.lean` path, including
      the abbreviated forms whose directory is established by surrounding context, resolves to
      an existing non-Boneyard file; the identifiers added in Phases 5-8
      (`countermodel_dense_enriched`, `Chronicle.mcs_mixed_case_absurd`, `succ_cofinal`,
      `countermodel_discrete_reynolds_v2`, `countermodel_discrete`) all confirmed live)*
- [x] Verify no task-number citation was introduced into either file, per
      `.claude/rules/no-task-references-in-deliverables.md`. *(completed: 0 hits)*
- [x] Re-confirm the three accuracy-floor claims are stated consistently across both files and
      that neither file claims an unconditional Dedekind completeness terminus. *(completed: no
      occurrence of an unconditional `completeness_dedekind`; both files consistently state the
      one-Base-sorry / dense-discrete-sorry-free / Dedekind-conditional-only picture)*
- [x] Compile the parent document and compare against the Phase 1 baseline. *(completed: exit 1,
      identical pre-existing `bimodal-notation.sty not found` failure as the Phase 1 baseline —
      unrelated to this task's edits)*

**Timing**: 0.5 hours

**Depends on**: 7, 8

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts the residual sweep returns zero hits across both files
for all seventeen retired identifiers and three stale paths listed above. That is the hypothesis;
the sweep itself is the confirmation. A non-zero result is a finding to fix in this phase, not a
reason to narrow the list.

**Files to modify**:

- `latex/subfiles/04-Metalogic.tex` — only if the sweep finds a survivor.
- `latex/subfiles/06-Notes.tex` — only if the sweep finds a survivor.

**Verification**:

- From `latex/subfiles/`: `TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 04-Metalogic.tex`
  exits 0.
- From `latex/subfiles/`: `TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 06-Notes.tex`
  exits 0.
- From `latex/`: `pdflatex -interaction=nonstopmode BimodalReference.tex` exit code matches the
  Phase 1 parent baseline.
- Residual sweep returns 0 hits for every retired identifier and stale path.
- No `lake build`, `lake clean`, or `lean_build` was run at any point; no file under
  `FormalSystem/` or `Tests/` was modified (confirm with `git status --short`).

---

## Testing & Validation

- [x] `TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 04-Metalogic.tex` exits 0 from
      `latex/subfiles/`, after every phase.
- [x] `TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 06-Notes.tex` exits 0 from
      `latex/subfiles/`, after every phase.
- [x] `pdflatex -interaction=nonstopmode BimodalReference.tex` from `latex/` matches its Phase 1
      baseline exit code. *(exit 1, pre-existing `bimodal-notation.sty` failure, both before and
      after this task)*
- [x] Residual sweep for all retired identifiers and stale paths returns 0 hits in both target
      files.
- [x] Every `FormalSystem/...` path cited in either file exists on disk.
- [x] Every `\texttt{...}` Lean identifier cited in either file has a non-`Boneyard` hit under
      `FormalSystem/`.
- [x] The three accuracy-floor claims (Standing Constraint 5) are stated and none is overstated.
- [x] `git status --short` shows no modification under `FormalSystem/` or `Tests/`.
- [x] No task-number citation appears in either `.tex` file.
- [x] The explicitly out-of-scope sections are unchanged: Strong Completeness and Compactness,
      the Decidability subsection and its status table, and `06-Notes.tex`'s Discrepancy
      Notes / Terminology / Axiom Naming / M5 Collapse / Decidability Implementation.

## Artifacts & Outputs

- `latex/subfiles/04-Metalogic.tex` (rewritten sections; compiles clean)
- `latex/subfiles/06-Notes.tex` (rewritten Completeness Status and summary row; compiles clean)
- `specs/409_reconcile_latex_metalogic_docs_with_live_tree/plans/01_latex-metalogic-reconcile.md`
  (this file)
- `specs/409_reconcile_latex_metalogic_docs_with_live_tree/summaries/01_latex-metalogic-reconcile-summary.md`
- LaTeX build byproducts under `latex/subfiles/` (`.aux`, `.log`, `.out`, `.pdf`) — expected and
  harmless

## Rollback/Contingency

Every phase is a self-contained edit to one or two `.tex` files with a compile gate, committed
per green sub-step. To revert a single phase, `git revert` that phase's commit; the preceding
commit is a known-compiling state. To abandon the whole task, revert the task's commit range —
nothing outside `latex/subfiles/` is touched, so no Lean build state, `specs/` state outside this
task directory, or concurrent session's work is affected.

If a tikz redraw (Phase 4 or 6) cannot be made to compile within its budget, the contingency is
to replace the figure with a `\begin{itemize}` structural description of the same content and
record the diagram as deferred, rather than leaving a non-compiling file or a knowingly stale
diagram. That is a `[COMPLETED WITH EXCLUSIONS]` outcome requiring a `#### Reasoned Exclusions`
record in the phase body, not a silent substitution.

If the build lock is released mid-task, that does NOT relax Standing Constraints 1 or 2 — this
task's verification contract is `pdflatex` only regardless of lock state.
