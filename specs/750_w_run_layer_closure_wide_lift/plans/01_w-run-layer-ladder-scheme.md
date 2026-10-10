# Implementation Plan: Task #750

- **Task**: 750 - (W)'s run layer, phase 1: the deadline-ladder frame scheme, landed and gate-compiled
- **Status**: [IMPLEMENTING]
- **Effort**: 6.5 hours
- **Dependencies**: None (no edge to the bound record, by the task's own instruction; serialization with it comes from the `file_scope` overlap on `RaySummary/README.md` and `docs/theorem-index.md`)
- **Research Inputs**: specs/750_w_run_layer_closure_wide_lift/reports/01_w-run-layer-design.md
- **Artifacts**: plans/01_w-run-layer-ladder-scheme.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research round settled the task's phase 1 (the design question): the frame scheme for
obligation (i) is **thread-indexed unfolding in its general form, the deadline ladder** — two
counters per `⊡`-forced eventuality, the current deadline counting down deterministically and the
next deadline drifting by at most one per step, so that no state ever chooses a deadline — and
the depth the run layer needs is **`k = 1`**. Both bounded-deadline variants are refuted by landed
theorems (a fixed cap gives a finite slice, `not_finite_width_fmp`; a state-chosen deadline is
the `Rok`/`Rbad` shape of `b2b-frame-constructor-branching.lean`), and the ladder relation `Rlad`
over `Q × ℕ × ℕ` was compiled with two-sided finite branching for every finite object
(`specs/750_w_run_layer_closure_wide_lift/evidence/01_deadline-ladder-branching.lean`, axiom
profile `[propext, Classical.choice, Quot.sound]`).

This plan lands that decision as code and record, and nothing more: a parallel constructor
`ofSlicedStepFinBranch` (the `ofSlicedStep` body with `[Finite W]` replaced by two-sided finite
branching in its one `Saturation` slot) and its instance `ladderFrame` in
`RaySummary/RunLayer.lean`; the ladder's branching verdict as a ninth wired probe beside the
eighth; axiom pins, a C14 pair and one `theorem-index` row for the regularity part of obligation
(i); and the README's (W) section rewritten to state the decision, the depth, the measured
figure, the precise phase-2 obstacle, phase 3 verbatim, and the literature paragraph the task
requires. The task's phases 2–3 (obligation (ii), soundness and completeness halves) are
characterized in the README and in the Non-Goals below, and are **not planned, priced or
attempted here** — the dispatch stops at phase 1, exactly as the task and the research report's
R2 instruct.

### Research Integration

- **D1 (frame scheme = deadline ladder)** is the content of Phase 1: `Drift`, `Count`, `Rlad`,
  `Rlad_fwd`, `Rlad_bwd`, `Rlad_slice_infinite` transcribed from the compiled scratch into the
  library, and `ladderFrame` built on them through the generic constructor.
- **D2 (`k = 1`)** is recorded in the README's (W) section (Phase 4) with its grounds from F8
  (every landed bridge carries `hk : 1 ≤ k`; run conditions are enforced structurally, never read
  off types; the `k = 3` type-read alternative is named and rejected).
- **D3 (obligation (i) split)**: the regularity part is a transcription and is landed (Phase 1);
  the seriality/admissibility part is an OBJECT condition — the constructor takes `fwd`/`bwd` as
  explicit hypotheses exactly as `ofSlicedStep` does, and the admissibility restriction `Adm q`
  of F5 is named in the README as uncosted; the realization part is phase 2 and is not planned.
- **F4 (measured analogues)**: `ofStep` (51 lines), `ofSlicedStep` through
  `ofSlicedStep_mem_HF_iff` (73 lines), Probe746's branching core (66 lines), the scratch (119
  lines). These are the transcription sources named per sub-step in Phase 1.
- **F6 (phase-2 obstacle)** and **R-A** go into the README verbatim in substance: cells are indexed
  by `(q, deadline class)`, not by `q`; the stabilization-in-`c` lemma is phase 2's first
  statement; until it is stated and proved phase 2 has no cost figure.
- **R1** (promote the scratch beside Probe746; record `k = 1`) is Phases 2 and 4. **R3** (the
  README paragraph) is Phase 4, text carried from the report's "The README paragraph" section.
  **R4** (what not to do) is carried into Binding Constraints below.
- **F7**: neither probe is weakened. `stab_iff_of_presented_nowUnique` needs trace-level
  `Presented` plus `nowUnique`; `modelOf_incomplete` is about `ofSlicedStep` on finite `Q`. The
  ladder's slice is infinite and its realization hypothesis would be Hit-level; nothing here
  touches either probe.
- **Evidence tier (R-F)**: `lean_local_search` was unavailable during research; every existence
  claim below was checked by file read at a cited line range or by compiling. The implementer
  re-checks each cited signature with `lean_hover_info` or a `Read` before transcribing.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md`'s Run block lists this record as "Phase 1 is a design question … dispatch it
and STOP; its outcome makes phases 2–3 costable and chooses the depth `k`". This plan is that
outcome landed; it adds no dependency edge to the bound record and reads the roadmap only. No
`roadmap_flag` was set, so no roadmap-review or roadmap-update phase is included.

## Binding Constraints (carried from the task, binding on every phase)

- **No complexity bound anywhere**, upper or lower; the argued CTL⋆ 2EXPTIME ceiling is never an
  upper-bound source; `Nat.card (KType (clSig φ) k)` and every cell count is a COUNT, never a bound
  on any procedure.
- **`Decidable (PlusValidZTime φ)` appears in no statement** of any file this plan touches, and
  in prose only inside sentences saying it is not stated. The semi-decidability caveat is carried
  verbatim and unchanged in the README.
- **Never write that L⁺ is decidable or undecidable unqualified**; every claim carries frame
  class, fragment, premise set and hypothesis, `[F.IsRegular]` at minimum.
- **No finite-width or finite-fibre assumption** is introduced on any model: `ladderFrame`'s only
  finiteness is `[Finite Q]` on the OBJECT; its slice `Q × ℕ × ℕ` is infinite by theorem. No
  fourth certificate class is filed.
- **Sorry-free completion required.** A route that does not close is marked `[BLOCKED]` with the
  obstruction named — never a `sorry`, never a vacuous placeholder, never a finite-fibre retreat.
- **Deliverable hygiene**: every file outside `specs/**` (the Lean module, the README, the
  aggregator docstring, `docs/theorem-index.md`, the two scripts, the pin test) carries no task
  number and no record-versioning language; durable anchors only (file names, theorem names,
  author-year citations, section headings). The write-time hook rejects a violation.
- **Plan compliance** (`rules/plan-compliance.md`): the Lean decomposition below is the contract;
  the signatures under `## Lean Challenge Statements` are part of it.

## Goals & Non-Goals

- **Goals**:
  - `FwdFinBranch`, `BwdFinBranch`, `iterS_fwd_finite`, `iterS_bwd_finite`,
    `fib_finite_of_finBranch`, `saturation_of_finBranch`, `ofSlicedStepFinBranch`,
    `ofSlicedStepFinBranch_isRegular`, `ofSlicedStepFinBranch_step`,
    `ofSlicedStepFinBranch_not_finite_worldState`, `ofSlicedStepFinBranch_mem_HF_iff`, `Drift`,
    `Count`, `Rlad`, `Rlad_fwd`, `Rlad_bwd`, `Rlad_slice_infinite`, `ladderFrame`,
    `ladderFrame_isRegular`, `ladderFrame_step`
  - A ninth wired probe, `specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean`,
    gate-compiled by `scripts/check-evidence-probes.sh`
  - Axiom pins for every new library declaration, a C14 pair for `ladderFrame_isRegular`, and one
    `docs/theorem-index.md` row for it
  - The README's (W) section stating the design decision, `k = 1`, the measured figure, the
    phase-2 obstacle, phase 3 verbatim, and the literature paragraph

- **Non-Goals**:
  - **Phase 2 of the task (obligation (ii), soundness half)**: a Hit-level realization theorem for
    `ladderFrame`, per ladder cell `(q, c, n)`, under run-layer consistency conditions analogous
    to `Cons`. Its first lemma must be the stabilization-in-`c` statement (F6); until that lemma
    is stated and proved the phase has no cost figure. Not planned, not priced, not attempted.
  - **Phase 3 of the task (obligation (ii), completeness half = (C)'s general row)**: "For every
    regular `ℤ`-model `M`, seam `(τ, t)`, formula `φ` and depth `1 ≤ k`, a finite labelled
    presentation `(Q, lab, step)` with `Fintype.card Q` below a computable bound in `φ`, such that
    `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`". Open mathematics: one positive fixture
    (`Probe745.hitPresented_modelA`), no Hit-level negative anywhere, no general argument, no
    figure. Not planned.
  - The admissibility restriction of the ladder's carrier (`c ∈ Adm q`, F5) and the run-layer
    consistency bundle that would play `Cons`'s role: named in the README, not built.
  - Any in-place generalization of `ofSlicedStep` or edit to `Semantics/SlicedFrame.lean`,
    `Semantics/TaskFrame.lean`, or any existing probe (prohibited; the constructor is parallel).
  - A composition theorem, a lift to `¬ PlusValidZTime φ`, or any statement about
    `PlusValidZTime` in any form.
  - Showing that `NoFiniteWidth.Node` embeds into the ladder (the research report's "one-region
    special case" reading) — a plausible remark, not a theorem this plan commits to.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A transcription source silently depends on `[Finite W]` beyond the `Saturation` slot (most plausibly inside `ofSlicedStep_mem_HF_iff`'s proof) | M | L | The proof routes through `FrameOver.mem_HF_iff_adjacent` and the `_step` lemma only (read at `SlicedFrame.lean:356-388`); if a finiteness instance is nonetheless demanded, mark the sub-step `[BLOCKED]` naming the lemma — never add `[Finite _]` (a refuted shape) |
| `FrameOver.ofReflectiveRegular` needs an instance (`Nonempty`, `Inhabited`) the generic `W` lacks | L | L | Mirror `ofSlicedStep`'s `[Nonempty W]`; `[Nonempty (Q × ℕ × ℕ)]` is derived from `[Nonempty Q]` by the product instance |
| Name clash under `open` in files importing the aggregator (`FwdFinBranch` etc. are also defined in `Probe746`'s namespace, but probes are outside the build graph) | L | L | Library declarations live in `FormalSystem.Metalogic.Decidability.RaySummary`; the new probe imports the library and defines NO duplicate of a library name |
| `lake exe mk_all --lib FormalSystem --check` fails because `FormalSystem.lean` does not list the new module | M | H if forgotten | Phase 1 adds the import line to `FormalSystem.lean` in alphabetical position and runs the check |
| A `theorem-index` row claiming `pinned:C14` with no C14 baseline behind it (the inventory script's one hard-failure condition) | M | M | Phase 3 adds the matched pair (baseline line + `#print axioms` line + comment) in `scripts/check-module-invariants.sh` in the same commit as the row |
| C15's second assertion: the row's declaration lacks a `Paper:` doc-comment line | L | M | `ladderFrame_isRegular`'s docstring carries `Paper: — (…)` from Phase 1 |
| README edit trips C14's stale-literal scan or the task-reference / version-language hooks | L | M | Phase 4 runs `check-module-invariants.sh --no-build` and `check-task-references.sh` on the README; the paragraph text is the report's hygiene-checked draft |
| Carried line figures (117–139 regularity, 119 ladder) prove wrong | L | M | They are hypotheses, confirmed by `wc -l` at Phase 1's close and written into the README as measured, replacing the carried "~120-160" |
| Scope drift into phases 2–3 ("just state the stabilization lemma") | H | M | Non-Goals above; any such statement is a plan deviation on a `.lean` file and must be raised as `[BLOCKED]`, not added |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Land `RunLayer.lean` — the finitely branching sliced constructor and the deadline ladder [COMPLETED]

**Goal**: A new library module `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean`
holding (a) the generic constructor `ofSlicedStepFinBranch` — `ofSlicedStep`'s body with the
`[Finite W]`-gated `ofSlicedStep_saturation` replaced by `saturation_of_finBranch` in its one
`Saturation` slot — with its regularity instance, step lemma, infinite-carrier record and history
characterization; and (b) the deadline ladder `Rlad` with its two-sided branching theorems and
the frame `ladderFrame` it yields. Everything is a transcription of a landed proof with one slot
changed; the module is wired into the aggregator and the generated library root.

**Tasks**:
- [x] Create `RunLayer.lean` with the copyright header (copy the shape of `RaySummary.lean:1-5`)
      and a module docstring stating: the design decision (deadline ladder, not a bounded-deadline
      encoding, with the two refutations named by theorem: `not_finite_width_fmp`;
      `Rok_fwd_infinite`/`Rbad_bwd_infinite` in `b2b-frame-constructor-branching.lean`); depth
      `k = 1` and why; that seriality is an object condition taken as `fwd`/`bwd` hypotheses;
      that realization (phase 2) and (C)'s general row (phase 3) are NOT here; no
      `PlusValidZTime`, no complexity bound. Namespace
      `FormalSystem.Metalogic.Decidability.RaySummary`; `open FormalSystem.Semantics
      FormalSystem.Semantics.TaskFrame`; import `FormalSystem.Semantics.SlicedFrame`.
- [x] Transcribe the branching core from `b2b-frame-constructor-branching.lean:100-173`
      (`FwdFinBranch`, `BwdFinBranch`, `iterS_fwd_finite`, `iterS_bwd_finite`,
      `fib_finite_of_finBranch`, `saturation_of_finBranch`), docstrings naming the probe as the
      source and stating that the probe is untouched. The probe cannot be imported — probes sit
      outside the Lake build graph — which is why the library carries its own copy.
- [x] Define `ofSlicedStepFinBranch` from `SlicedFrame.lean:283-290` with
      `(saturation_of_finBranch R hf hb)` in the last slot and `[Finite W]` dropped; add the
      `@[simp]` helper `ofSlicedStepFinBranch_taskRel` (from `ofSlicedStep_taskRel`), then
      `ofSlicedStepFinBranch_isRegular`, `ofSlicedStepFinBranch_step`,
      `ofSlicedStepFinBranch_not_finite_worldState` (`ℤ × W` is infinite through `ℤ`), each a
      one-slot transcription of `SlicedFrame.lean:293-328`.
- [x] Transcribe `ofSlicedStep_mem_HF_iff` (`SlicedFrame.lean:356-388`) as
      `ofSlicedStepFinBranch_mem_HF_iff`, routing through `FrameOver.mem_HF_iff_adjacent` and
      `ofSlicedStepFinBranch_step`; confirm no finiteness instance is demanded (Risk 1).
- [x] Transcribe the ladder from the compiled scratch
      `specs/750_w_run_layer_closure_wide_lift/evidence/01_deadline-ladder-branching.lean`:
      `Drift`, `Count`, `Rlad`, the helper `tri`/`tri_finite`, `Rlad_fwd`, `Rlad_bwd`,
      `Rlad_slice_infinite`, with their docstrings (the "no early discharge with leftover" clause
      is what keeps the backward side finite; say so at `Count`).
- [x] Define `ladderFrame step pend fwd bwd := ofSlicedStepFinBranch (Rlad step pend)
      (Rlad_fwd step pend) (Rlad_bwd step pend) fwd bwd`; add `ladderFrame_isRegular` (its
      docstring carries the `Paper: — (…)` line C15's second assertion requires, naming HWZ 2000
      Def 12 as the nearest literature object and stating that no counterpart constructor exists
      there because the run set is not chosen) and `ladderFrame_step`.
- [x] Add `import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer` to
      `FormalSystem/Metalogic/Decidability/RaySummary.lean` (after `AnchorLayer`) and a
      `* RaySummary.RunLayer — …` bullet to its module docstring in the style of the
      `RaySummary.AnchorLayer` bullet, ending with "No `[F.IsRegular]`-free claim about validity,
      nothing about `PlusValidZTime`, no realization theorem (the run layer's phase 2, open)".
- [x] Add `import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer` to `FormalSystem.lean`
      between the `Realize` and `Seam` lines; run `lake exe mk_all --lib FormalSystem --check`.
- [x] Read every `#print axioms` for the twenty Goals declarations (scratch file or
      `lean_verify`): each `[propext, Classical.choice, Quot.sound]` or a subset, no `sorryAx`.
- [x] Record the measured line counts: `wc -l RunLayer.lean`, and the line span of the
      constructor part versus the ladder part, for Phase 4's README figure. *(measured: 373
      lines total; module header 1–71; branching core + constructor 72–250 = 179 lines; ladder +
      `ladderFrame` 251–373 = 123 lines; 20 Goals declarations + 3 helpers, all profiles within
      `[propext, Classical.choice, Quot.sound]`, `FwdFinBranch`/`BwdFinBranch`/`Drift`/`Count`/`Rlad`
      axiom-free)*

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Twenty library declarations (the Goals set) plus three helpers
(`ofSlicedStepFinBranch_taskRel`, `tri`, `tri_finite`), at roughly 117–139 lines for the
constructor part and 119 for the ladder — figures CARRIED from
`reports/01_w-run-layer-design.md` F4 and the compiled scratch; confirm by `wc -l` and by the
declaration count at phase close, and write the measured numbers into the README in Phase 4.

**Tier Justification**: A scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.RunLayer` and of the aggregator
`FormalSystem.Metalogic.Decidability.RaySummary`, plus `lake exe mk_all --lib FormalSystem
--check`, covers the new module and its two new import edges; no existing signature changes, so
no dependent beyond the aggregator can break at type level.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` - new module: branching core, `ofSlicedStepFinBranch` and lemmas, ladder and `ladderFrame`
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - aggregator import plus docstring bullet
- `FormalSystem.lean` - generated-root import line (checked by `mk_all --check`)

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.RunLayer` detached, exit 0, no warnings about `sorry`
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary` detached, exit 0
- `lake exe mk_all --lib FormalSystem --check` exit 0
- `bash scripts/check-copyright-headers.sh --strict` exit 0
- `#print axioms` on all twenty Goals declarations: each within `[propext, Classical.choice, Quot.sound]`, none mentioning `sorryAx`
- `grep -c "PlusValidZTime" RunLayer.lean` returns only occurrences inside the docstring sentences that say it is not stated; `grep -n "Finite\b" RunLayer.lean` shows `[Finite Q]` on the object and the `¬ Finite` records only — no `[Finite W]` on any constructor

---

### Phase 2: Promote the ladder verdict to a ninth wired probe [COMPLETED]

**Goal**: The design decision is gate-compiled: a probe beside Probe746 cites the library's
`Rlad_fwd`, `Rlad_bwd`, `Rlad_slice_infinite` and `ladderFrame_isRegular`, re-proves none of
them, and records the one refutation the library does not carry — a capped ladder has a finite
carrier, which is the bounded-deadline encoding and the shape `not_finite_width_fmp` refutes.

**Tasks**:
- [x] Create `specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean` importing
      `FormalSystem.Metalogic.Decidability.RaySummary.RunLayer` (and
      `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth` only if
      `not_finite_width_fmp` is cited by name in a statement; otherwise cite it in the header
      only). Header in the style of the eighth probe: what it establishes (the ladder has
      two-sided finite branching for EVERY finite object and an infinite slice, so Probe746's
      positive half applies to it unchanged), what it refutes (the capped variant), what it does
      NOT say (nothing about realization, `HitPresented`, `⊡(Pp)`, `PlusValidZTime`, or any
      bound), and the compile command.
- [x] Headline declarations, each citing the library: `ladder_fwd` / `ladder_bwd` /
      `ladder_slice_infinite` as one-line corollaries of the library theorems (the probe's own
      names, so a future API change is tracked here rather than silently inherited), and
      `capped_carrier_finite : Finite (Q × Fin (N + 1) × Fin (N + 1))` with a docstring saying
      this is the bounded-deadline encoding's carrier and why a frame on it is the shape
      `not_finite_width_fmp` refutes. `#print axioms` lines at the end for every headline.
- [x] Add the comment-table entry and the `WIRED` array entry
      `"seam-gluing-ray-product/deadline-ladder-branching"` to `scripts/check-evidence-probes.sh`
      directly after the `w-soundness-shape-refuted` entries; the table text carries no task
      number (name the record by the README section "(W): what landed and what did not").
- [x] Run `bash scripts/check-evidence-probes.sh`; the new line reads `PASS` and every existing
      line still reads `PASS`.
- [x] Record via `issue-record.sh` (`kind: win` or `issue`) whether the probe compiled first time
      against the library names. *(recorded: `kind: win`, compiled first time; the gate's only
      pre-commit non-PASS was the expected `FAIL (untracked)` on the new file, cleared by the
      phase commit — confirmed by a second gate run after it)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This is the NINTH probe in the README's own ordinal sequence (its Evidence
section currently ends at "An eighth wired probe") and the twentieth
`seam-gluing-ray-product/` entry in the `WIRED` array; confirm both counts by reading the README
paragraph and `grep -c '"seam-gluing-ray-product/' scripts/check-evidence-probes.sh` before
writing "ninth" anywhere.

**Tier Justification**: `bash scripts/check-evidence-probes.sh` compiles the new probe and every
existing one outside the build graph, which is the only surface this phase's edits touch; the
library is unchanged.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean` - new wired probe
- `scripts/check-evidence-probes.sh` - comment-table entry and `WIRED` array entry

**Verification**:
- `bash scripts/check-evidence-probes.sh` exit 0; the new entry and all prior entries `PASS`
- `lake env lean specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean` exit 0; every `#print axioms` line within `[propext, Classical.choice, Quot.sound]`
- `git ls-files --error-unmatch specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean` succeeds after the phase commit (the gate tests tracked-ness)

---

### Phase 3: Pins, the C14 pair, and the `theorem-index` row [NOT STARTED]

**Goal**: Every new library declaration is pinned by the test library; the regularity part of
obligation (i) has one ledger row whose `pinned:C14` cell is backed by a C14 baseline pair.

**Tasks**:
- [ ] In `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, add a section
      `/-! ## Requirement (W): the run layer's frame scheme (`RaySummary/RunLayer.lean`) -/`
      after the anchor-layer section, with a `#guard_msgs in #print axioms` pin for each of the
      twenty Goals declarations, in the exact shape of the `anchorCons_anchorCells` pin (the
      file already imports the aggregator, which now imports `RunLayer`).
- [ ] In `scripts/check-module-invariants.sh`, extend the C14 block: a comment sentence in the
      "(W)" paragraph (near the "Four further matched pairs" text) naming
      `...ladderFrame_isRegular` (`RaySummary/RunLayer.lean`) as the frame-scheme constructor's
      regularity instance — infinite slice, `[Finite Q]` on the object only, not a decision
      procedure, realization not claimed; the baseline line
      `'FormalSystem.Metalogic.Decidability.RaySummary.ladderFrame_isRegular' depends on axioms: [propext, Classical.choice, Quot.sound]`
      directly after the `anchorConsFin_iff` baseline line; and the matching
      `#print axioms FormalSystem.Metalogic.Decidability.RaySummary.ladderFrame_isRegular` line
      directly after the `anchorConsFin_iff` print line. Confirm the profile by reading Phase 1's
      `#print axioms` output first; if it is a strict subset, write that subset.
- [ ] Add one row to `docs/theorem-index.md`'s Decidability table, directly after the
      `anchorConsFin_iff` row: label `—`; statement: the frame-scheme constructor of requirement
      (W)'s obligation (i), regularity part — a finite object `(Q, step, pend)` yields the regular
      `ℤ`-frame `ladderFrame` on the carrier `ℤ × (Q × ℕ × ℕ)` whose one-step relation is the
      deadline ladder `Rlad`, with two-sided finite branching for EVERY finite object (`Rlad_fwd`,
      `Rlad_bwd`) and an infinite slice (`Rlad_slice_infinite`), so `Saturation` comes from
      `saturation_of_finBranch` with no `[Finite W]` and `not_finite_width_fmp` is not
      contradicted; seriality is the object's own `fwd`/`bwd` hypotheses; the bounded-deadline
      variants are refuted (`not_finite_width_fmp`; the ninth wired probe
      `deadline-ladder-branching.lean` beside Probe746's `Rok`/`Rbad`); depth `k = 1`. **What it
      is not**: no realization theorem (the run layer's phase 2, whose first lemma is the
      stabilization of realized type sets in the deadline counter, unproved), nothing about
      `HitPresented`, nothing about `PlusValidZTime` in any form, no complexity bound. Lean name
      `FormalSystem.Metalogic.Decidability.RaySummary.ladderFrame_isRegular`, file
      `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean`, frame class `ZTime`, axioms
      `pcq pinned:C14`.
- [ ] Run `bash scripts/check-module-invariants.sh` (C14 half (ii) compiles the pin scratch; C15
      second assertion checks the row's `Paper:` line) and
      `bash scripts/generate-decidability-inventory.sh --diff` (advisory; the only acceptable
      diff is the one new PROVED row).

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: Twenty pins (one per Goals declaration) and exactly one new ledger row with
exactly one new C14 pair; confirm the pin count against the Goals list and the pair count by
`grep -c ladderFrame_isRegular scripts/check-module-invariants.sh` returning 3 (comment,
baseline, print).

**Tier Justification**: `bash scripts/check-module-invariants.sh` (the C14 pin compile and the
C15 row-anchoring assertion) together with a scoped guarded build of
`BimodalTest.Metalogic.KTypeSummaryAxiomTest` cover the three edited surfaces exactly; nothing in
the library changes.

**Files to modify**:
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - twenty `#guard_msgs` axiom pins
- `scripts/check-module-invariants.sh` - C14 comment sentence, baseline line, `#print axioms` line
- `docs/theorem-index.md` - one Decidability row for `ladderFrame_isRegular`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` detached, exit 0 (every `#guard_msgs` matches)
- `bash scripts/check-module-invariants.sh` exit 0 with `PASS C14` and `PASS C15` lines
- `bash scripts/generate-decidability-inventory.sh --diff` shows the one new row and nothing else
- `bash .claude/scripts/check-task-references.sh docs/theorem-index.md` exit 0

---

### Phase 4: The README's (W) section — decision, depth, figure, phases 2–3, literature [NOT STARTED]

**Goal**: `RaySummary/README.md` states the current design of (W)'s run layer: the frame scheme
chosen and why, `k = 1`, the measured figure replacing the carried one, the phase-2 obstacle made
precise, phase 3 verbatim, the literature paragraph the task requires, the ninth probe, and the
new module — with every binding constraint and the semi-decidability caveat unchanged.

**Tasks**:
- [ ] "What it holds" table: add a `RunLayer.lean` row with Phase 1's measured line count and a
      description in the style of the `AnchorLayer.lean` row (constructor, ladder, `ladderFrame`;
      what it is not: no realization theorem, nothing about `PlusValidZTime`, no bound).
- [ ] "(W): what landed and what did not", obligation (i) item: replace "neither refuted nor
      built" and the carried "~120-160 line figure … carried, unverified" with the landed state —
      the deadline ladder (two counters per `⊡`-forced eventuality: deterministic countdown while
      pending, next deadline drifting by at most one per step at every step, so no state chooses
      a deadline; `Node` of `Limits/NoFiniteWidth.lean` is the shape this generalizes), the two
      refutations (a fixed cap: finite slice, `not_finite_width_fmp`; a state-chosen deadline:
      `Rok_fwd_infinite`/`Rbad_bwd_infinite`), `ladderFrame` in `RunLayer.lean` with `Rlad_fwd`,
      `Rlad_bwd`, `Rlad_slice_infinite`, the MEASURED line count (regularity part and ladder part
      separately), seriality as an object condition (`fwd`/`bwd`), and the named-not-costed
      admissibility restriction `c ∈ Adm q` and run-layer consistency conditions.
- [ ] Same section: record **depth `k = 1`** with its grounds — every landed bridge the run layer
      consumes carries `hk : 1 ≤ k` and nothing asks more; run conditions are enforced by the
      object's step structure as `Cons` does for (S), never read off types; the alternative
      (making `LocalRun.untl`/`.snce` `DeterminedByKType` targets through
      `determinedByKType_eval`) costs `k = 3` by `MonadicFormula.quantifierDepth` and is rejected,
      since `Nat.card (KType sig k)` — a count, never a complexity bound — grows with `k`.
- [ ] Same section, obligation (ii): state the phase-2 obstacle precisely — ladder states
      `(q, c, n)` with small `c` realize PROPER subsets of the types at large `c` (`Node`'s `pre 0`
      reads `⊡Xp` where `pre (k+1)` reads `¬⊡Xp`), so cells are indexed by `(q, deadline class)`
      and the Hit-level per-cell hypothesis must be stated at ladder states; the stabilization of
      realized type sets in `c` past a bound syntactic in `φ` is plausible, unproved, and is
      phase 2's FIRST statement; until it is proved phase 2 has no cost figure, and if it fails
      the honest outcome is `[BLOCKED]`, never a finite-fibre retreat. State phase 3 as (C)'s
      general row verbatim (the sentence from "The verdict"), open, one positive fixture
      (`Probe745.hitPresented_modelA`), no Hit-level negative anywhere, no figure.
- [ ] Keep "What the lift would deliver even with the run layer, and what it would not" verbatim
      (the semi-decidability caveat). Update "Successor." to say phases 2–3 of the run layer are
      their own successor records, never phases appended to this one.
- [ ] Insert, after the "Successor" paragraph, the literature paragraph exactly as drafted in
      `reports/01_w-run-layer-design.md`, "The README paragraph" (beginning "**The obstruction
      has a literature description.**" and ending "… exactly what (W)'s soundness half is
      about."), re-checking its anchors: HWZ 2000 Definition 12, Remark 13 (PDF p. 11), Theorem
      14 ⇐; GKWZ 2003 Theorem 13.6 (Chapter 6 quasimodels with Chapter 11 MSO embeddings);
      `cellAt_eq_cellAt` (`AnchorLayer.lean`); `mem_HF_iff_adjacent`
      (`Semantics/IntNormalForm.lean`); `seamOmegaEquiv`; `blc_plusValid`; `stab_state_only`
      (`PlusLanguage/PlusTruth.lean`). Confirm each Lean name resolves (`grep -rn` or
      `lean_local_search` with `index: consulted`) before citing it.
- [ ] "Evidence": add "A ninth wired probe, `deadline-ladder-branching.lean`, …" after the eighth,
      in the same shape: what it establishes, what it cites and re-proves none of, what it does
      not say.
- [ ] If "The verdict" table's (W) row enumerates the three obligations, update it consistently
      (obligation (i): regularity part landed, realization part open; (ii): open; (iii):
      discharged) — read lines 103–158 first.
- [ ] Update `*Last verified: …*` to the implementation date.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: The README's Evidence section ends at "An eighth wired probe" and its (W)
section's obligation list is the three-item list quoted in the task; confirm by reading the
section before editing, and confirm the measured figures by reading Phase 1's `wc -l` record
rather than the carried 120–160 band.

**Tier Justification**: A diff read-through confirming every hunk is prose, plus
`bash .claude/scripts/check-task-references.sh FormalSystem/Metalogic/Decidability/RaySummary/README.md`,
`bash scripts/readme-lint.sh FormalSystem/Metalogic/Decidability/RaySummary` and
`bash scripts/check-module-invariants.sh --no-build` (C14's stale-literal scan over the README)
cover a markdown edit with no compile surface; `suite_selection_select` has no suite for this
path (`__FULL_SWEEP__`), so no suite is claimed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - "What it holds" row, (W) section, Evidence paragraph, verdict row if applicable, date

**Verification**:
- `git diff -- FormalSystem/Metalogic/Decidability/RaySummary/README.md` read through: no task numbers, no version language ("no longer", "previously", "v2", "supersedes"), every cited Lean name exists in the tree
- `grep -n "Decidable (PlusValidZTime" FormalSystem/Metalogic/Decidability/RaySummary/README.md`: every hit is inside a sentence saying it is not stated
- `grep -n -i "2EXPTIME\|complexity bound" FormalSystem/Metalogic/Decidability/RaySummary/README.md`: every hit is a disclaimer, none a claim
- `bash .claude/scripts/check-task-references.sh FormalSystem/Metalogic/Decidability/RaySummary/README.md` exit 0
- `bash scripts/readme-lint.sh FormalSystem/Metalogic/Decidability/RaySummary` exit 0 and no `NOT LISTED` for `RunLayer.lean`
- `bash scripts/check-module-invariants.sh --no-build` exit 0

---

### Phase 5: Full gate and sorry-free close [NOT STARTED]

**Goal**: The complete gate set runs green on the whole tree and every new declaration is
sorry-free, before the task closes.

**Tasks**:
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full `FormalSystem`), detached
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest`, detached
- [ ] `bash scripts/check-evidence-probes.sh`
- [ ] `bash scripts/check-module-invariants.sh`
- [ ] `bash scripts/check-copyright-headers.sh --strict`
- [ ] `bash scripts/readme-lint.sh`
- [ ] `bash scripts/check-metalogic-cycles.sh`
- [ ] `lake exe mk_all --lib FormalSystem --check`
- [ ] `lake exe lint-style` (the long-file linter is inert for the new module; confirm no new findings)
- [ ] `bash .claude/scripts/verify-deploy.sh` — the complete aggregator gate set
- [ ] `bash .claude/scripts/check-task-references.sh` over every non-`specs/**` file touched
- [ ] `lean_verify` (or `#print axioms` in a scratch) on all twenty Goals declarations and the
      probe's headlines: no `sorryAx`, profiles within `[propext, Classical.choice, Quot.sound]`
- [ ] Write the summary artifact per `summary-format.md`, stating plainly: what landed (the
      regularity part of obligation (i), the probe, the pins, the row, the README), what did not
      and why (phases 2–3: characterized, not attempted — by instruction, not by failure), and the
      measured figures that replaced the carried ones

**Timing**: 1 hour

**Depends on**: 3, 4

**Verification Tier**: full

**Files to modify**:
- none planned — this phase edits nothing unless a gate fails, in which case the fix is forward (`context/contracts/recovery.md`) in the file the gate names and the phase that owns it is re-verified

**Verification**:
- Every command above exits 0; the two guarded builds report green through the guard's own `result`
- `bash .claude/scripts/verify-deploy.sh` exit 0
- No `sorry`, `sorryAx`, or vacuous placeholder (`:= True`, `:= trivial`) in `RunLayer.lean` or the probe (`grep -n "sorry\|:= True\|:= trivial" …` returns nothing outside docstring prose)
- `git status --short` shows only the files enumerated in Phases 1–4

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.SlicedFrame

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Semantics FormalSystem.Semantics.TaskFrame

/-- Forward finite branching of a time-indexed step relation. -/
def FwdFinBranch {W : Type} (R : ℤ → W → W → Prop) : Prop :=
  ∀ t w, {u | R t w u}.Finite

/-- Backward finite branching: the preimage side, which finiteness is not stable under. -/
def BwdFinBranch {W : Type} (R : ℤ → W → W → Prop) : Prop :=
  ∀ t u, {w | R t w u}.Finite

theorem iterS_fwd_finite {W : Type} (R : ℤ → W → W → Prop) (hf : FwdFinBranch R) :
    ∀ (n : ℕ) (t : ℤ) (w : W), {u | iterS R n t w u}.Finite := sorry

theorem iterS_bwd_finite {W : Type} (R : ℤ → W → W → Prop) (hb : BwdFinBranch R) :
    ∀ (n : ℕ) (t : ℤ) (u : W), {w | iterS R n t w u}.Finite := sorry

theorem fib_finite_of_finBranch {W : Type} (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R) :
    ∀ (p : ℤ × W) (d : ℤ), (TaskFrame.Fib (ofSlicedStepRel R) p d).Finite := sorry

theorem saturation_of_finBranch {W : Type} (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R) :
    TaskFrame.Saturation (ofSlicedStepRel R) := sorry

/-- `ofSlicedStep`'s body with the `[Finite W]`-gated `Saturation` slot replaced by
`saturation_of_finBranch`; no carrier finiteness anywhere. -/
def ofSlicedStepFinBranch {W : Type} [Nonempty W] (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) : FrameOver intOrder :=
  FrameOver.ofReflectiveRegular (ℤ × W) (ofSlicedStepRel R)
    (fun p d q => ofSlicedStepRel_reflect R p d q)
    (ofSlicedStep_compositional R)
    (ofSlicedStep_serial R fwd bwd)
    (ofSlicedStep_limit R)
    (saturation_of_finBranch R hf hb)

instance ofSlicedStepFinBranch_isRegular {W : Type} [Nonempty W] (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) :
    (ofSlicedStepFinBranch R hf hb fwd bwd).IsRegular := sorry

theorem ofSlicedStepFinBranch_step {W : Type} [Nonempty W] (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) (p q : ℤ × W) :
    (ofSlicedStepFinBranch R hf hb fwd bwd).step p q ↔ q.1 = p.1 + 1 ∧ R p.1 p.2 q.2 := sorry

theorem ofSlicedStepFinBranch_not_finite_worldState {W : Type} [Nonempty W]
    (R : ℤ → W → W → Prop) (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) :
    ¬ Finite (ofSlicedStepFinBranch R hf hb fwd bwd).WorldState := sorry

theorem ofSlicedStepFinBranch_mem_HF_iff {W : Type} [Nonempty W] (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) (f : ℤ → ℤ × W) :
    (∃ τ : WorldHistory (ofSlicedStepFinBranch R hf hb fwd bwd), τ.path = f) ↔
      ∃ (k : ℤ) (g : ℤ → W), IsSlicedStepPath R k g ∧ f = fun t => (t + k, g t) := sorry

/-- The next-deadline counter drifts by at most one per step. -/
def Drift (n n' : ℕ) : Prop := n' = n ∨ n' = n + 1 ∨ n' + 1 = n

/-- The current-deadline counter: deterministic countdown while a region continues, handed the
next-deadline value when a region starts, `0` while idle; a region ends exactly at `0`. -/
def Count (px py : Bool) (c n c' : ℕ) : Prop :=
  if py then (if px then c' + 1 = c else c' = n) else (c' = 0 ∧ (px = true → c = 0))

/-- The deadline ladder over a finite object `(step, pend)`: states `(q, c, n)`. -/
def Rlad {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) :
    ℤ → (Q × ℕ × ℕ) → (Q × ℕ × ℕ) → Prop :=
  fun _ x y => step x.1 y.1 = true ∧ (pend x.1 = false → x.2.1 = 0) ∧
    Drift x.2.2 y.2.2 ∧ Count (pend x.1) (pend y.1) x.2.1 x.2.2 y.2.1

theorem Rlad_fwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    FwdFinBranch (Rlad step pend) := sorry

theorem Rlad_bwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    BwdFinBranch (Rlad step pend) := sorry

theorem Rlad_slice_infinite {Q : Type} [Nonempty Q] : ¬ Finite (Q × ℕ × ℕ) := sorry

/-- The frame-scheme constructor of requirement (W)'s obligation (i), regularity part. -/
def ladderFrame {Q : Type} [Finite Q] [Nonempty Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, Rlad step pend t x y) (bwd : ∀ t x, ∃ y, Rlad step pend (t - 1) y x) :
    FrameOver intOrder :=
  ofSlicedStepFinBranch (Rlad step pend) (Rlad_fwd step pend) (Rlad_bwd step pend) fwd bwd

instance ladderFrame_isRegular {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, Rlad step pend t x y) (bwd : ∀ t x, ∃ y, Rlad step pend (t - 1) y x) :
    (ladderFrame step pend fwd bwd).IsRegular := sorry

theorem ladderFrame_step {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, Rlad step pend t x y) (bwd : ∀ t x, ∃ y, Rlad step pend (t - 1) y x)
    (x y : ℤ × (Q × ℕ × ℕ)) :
    (ladderFrame step pend fwd bwd).step x y ↔ y.1 = x.1 + 1 ∧ Rlad step pend x.1 x.2 y.2 := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

The `def`s carry their real bodies because their body IS their statement (a snapshot tool forces
every body to `sorry` regardless, which is harmless here: every theorem's signature still
type-checks against the sorried definitions). Helpers not in this set (`ofSlicedStepFinBranch_taskRel`,
`tri`, `tri_finite`) are permitted and expected; nothing else is added to the module.

This block was type-checked standalone at plan-authoring time (`lake env lean` on the extracted
block, exit 0, thirteen `declaration uses 'sorry'` warnings and no error), so every signature
above resolves against the current tree and `ofSlicedStepFinBranch`'s real body elaborates with
`saturation_of_finBranch` in the `Saturation` slot under `[Nonempty W]` alone — Risk 2 is
retired by that compile, not by argument.

## Testing & Validation

- [ ] Scoped guarded builds of `RunLayer`, the aggregator, and `KTypeSummaryAxiomTest` green (Phases 1, 3)
- [ ] `check-evidence-probes.sh` green with the ninth probe `PASS` (Phase 2)
- [ ] `check-module-invariants.sh` green: C14 pair compiles, C15 row anchoring passes (Phase 3)
- [ ] `generate-decidability-inventory.sh --diff` shows exactly one new PROVED row (Phase 3)
- [ ] README hygiene: task-reference lint, readme-lint, C14 stale-literal scan, manual
      version-language read-through (Phase 4)
- [ ] Full `lake build` of `FormalSystem` and `BimodalTest`, `mk_all --check`, copyright,
      cycles, `lint-style`, `verify-deploy.sh` (Phase 5)
- [ ] Axiom profiles of all twenty Goals declarations and the probe headlines within
      `[propext, Classical.choice, Quot.sound]`, no `sorryAx` (Phases 1, 2, 5)
- [ ] `Decidable (PlusValidZTime φ)` absent from every new statement; present in prose only in
      sentences saying it is not stated (Phases 1, 3, 4)

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` (new)
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` and `FormalSystem.lean` (import lines; aggregator docstring bullet)
- `specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean` (new wired probe)
- `scripts/check-evidence-probes.sh` (ninth entry)
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (twenty pins)
- `scripts/check-module-invariants.sh` (one C14 pair)
- `docs/theorem-index.md` (one row)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` ((W) section, Evidence, table, literature paragraph)
- `specs/750_w_run_layer_closure_wide_lift/summaries/01_w-run-layer-ladder-scheme-summary.md`

## Rollback/Contingency

- **Transcription hits a hidden finiteness dependency (Phase 1)**: mark that sub-step `[BLOCKED]`
  naming the lemma and the goal state; land the rest of the module without it (a missing
  `_mem_HF_iff` leaves `ladderFrame` and its regularity intact); never introduce `[Finite W]`.
- **`FrameOver.ofReflectiveRegular` demands an instance the generic carrier lacks**: specialize
  only as far as `[Nonempty W]`; if more is needed, `[BLOCKED]` with the demanded instance named
  — do not weaken to a finite carrier.
- **Phase 1 blocks entirely**: Phase 2 falls back to promoting the research scratch VERBATIM as
  the ninth probe (it is self-contained, importing only `SlicedFrame`), so the design verdict is
  still gate-compiled; Phase 3 is skipped (no library declarations to pin or index); Phase 4
  records the block with the obstruction named; the task closes `[BLOCKED]` honestly.
- **Reverting a phase**: fix forward first (`context/contracts/recovery.md`). Only for a genuine
  rollback, run `bash .claude/scripts/git-snapshot.sh 750` and then the destructive command; an
  ordinary defensive checkpoint before risky work is `bash .claude/scripts/git-snapshot.sh
  --no-revert 750`, never the default form. Each phase is its own commit
  (`git-commit-scoped.sh`), so a bad phase is reverted by its commit alone.
- **A gate in Phase 5 fails on a file outside this plan's list**: do not edit it; record the
  failure in the summary and the issue log, and leave the task `[PARTIAL]` with the gate named.
