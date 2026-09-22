# Implementation Plan: Task #645

- **Task**: 645 - Port the translation-product proof device into the library
- **Status**: [IMPLEMENTING]
- **Effort**: 5.5 hours
- **Dependencies**: None at the artifact level (task 534 is recorded as a state.json dependency and is complete). Do not run concurrently with task 625 (shares `Semantics/Frames/README.md`) or with any other module-adding task (shares the generated root and README inventory blocks).
- **Research Inputs**: specs/645_port_translation_product_into_library/reports/01_port-translation-product.md
- **Artifacts**: plans/01_port-translation-product.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Transcribe the compiled, sorry-free probe
`specs/624_translation_product_task_semantics_visibility/probes/01_translation-product-live.lean`
into two library modules — `FormalSystem/Semantics/Frames/TranslationProduct.lean` (the product
relation, the live `FrameOver.translationProduct`, history lifting/projection, the three truth
invariances, and the three class-validity theorems) and
`FormalSystem/Metalogic/Independence/TranslationProductCoarse.lean` (coarse-model lifting and
paste-closure transfer) — restated against the live definitions. The research report established
that the probe compiles today with only two import-path repairs and that `HistMap`, `HistMorphism`
and `TaskFrame.RecurrenceFree` are already live in `Semantics/HistoryMorphism.lean`, so this is a
transcription with docstring rewriting and wiring, not a re-derivation. Definition of done:
`lake build --wfail` green, zero `sorry`, the three `*ValidIn_iff_recurrenceFree` theorems at
`[propext, Classical.choice, Quot.sound]` and pinned under C14, `check-module-invariants.sh` fully
green, `lake exe mk_all --lib FormalSystem --check` exit 0.

### Deliverables (prose)

- Module 1 at `FormalSystem/Semantics/Frames/TranslationProduct.lean` carrying every declaration
  the dispatch names, plus the frame-level non-reflection theorem and the projection morphism
  instance (see Decisions).
- Module 2 at `FormalSystem/Metalogic/Independence/TranslationProductCoarse.lean` (a separate
  file, not an addendum to `PastedCoarseModels.lean`).
- Aggregators, READMEs, generated inventory blocks, regenerated root, three theorem-index rows,
  and the matching C14 pins.
- The zeroFix mirror (probe 02) copied to a tracked, task-independent path under
  `specs/evidence/` and cited from the Module 1 docstring.

### Research Integration

Every finding of `reports/01_port-translation-product.md` is consumed directly:
- The two import repairs (`FormalSystem.PlusLanguage.PlusValidity`,
  `FormalSystem.StarLanguage.StarValidity`) and the removal of
  `set_option linter.unusedSectionVars false` (Finding 1, 4; Appendix A).
- The declaration map (R1) fixes the probe-to-port renames: `prodFrame` ->
  `FrameOver.translationProduct` (+ `_taskRel`, `_sat`, `_deterministic_iff`); `liftM` ->
  `liftModel` (core's `liftM` collides); `prod_no_recurrence`/`prod_no_transposition` ->
  `no_recurrence`/`no_transposition`; `prodFrame_recurrenceFree` ->
  `translationProduct_recurrenceFree` stated against the live `TaskFrame.RecurrenceFree`.
- Do NOT re-declare `HistMap`, `HistMorphism`, `RecurrenceFree`, `p₀` (Finding 2).
- Layering: `Semantics/Frames/` may import `StarLanguage.StarValidity` (layer 1 -> layer 1, the
  `StateLocalTransfer.lean` precedent); no `LANGUAGE_FILE_LAYERS` edit (Finding 3, D1).
- Module 2 is a separate file (R2, D5).
- Docstring hazards: cite `sub:AbsoluteTime` + the *Abundance* phrase, never `app:abundant`;
  never a `specs/NNN_` path or a manuscript line number in a `.lean` file (Finding 4, R3, R5).
- The documentation surface a new module touches (Finding 5) is the Phase 4 file list.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found (no `roadmap_path` in the dispatch).

## Goals & Non-Goals

- **Goals**: `validIn_iff_recurrenceFree`, `plusValidIn_iff_recurrenceFree`,
  `starValidIn_iff_recurrenceFree`
- **Non-Goals**:
  - `Semantics/HistoryMorphism.lean` additions (`HistMorphism.surj_of_occurs`,
    `histMorphism_invariance`), `Clock`, `prodClock`, `clockedFactor*`, `stateClock*` — the
    categorical reading is out of scope by the dispatch.
  - Any manuscript edit.
  - Anything about the stability modal beyond state-locality (the 624 report's Q5 records the
    device is silent there).
  - A test file under `Tests/BimodalTest/` — not required by the acceptance criteria and not
    added for `HistoryMorphism.lean`; the three C14 pins are the durable gate.
  - A `context/project/lean4/patterns/new-module-checklist.md` context page (the research
    report's context-extension recommendation) — a follow-up task, not this one.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A docstring keeps a probe-era citation (`Probe624`, "probe 559/04", "report 03 §3.2", "report 04 §3.3", "for 618", "lines 832-937") | H (C9 gate fails; manuscript line numbers are not gated and would silently rot) | M | Phase 1 and 2 checklists each end with `grep -nE '[0-9]{3,4}' <file>` over the new module and a manual read of every hit; C9 via `check-module-invariants.sh --no-build` at the end of Phase 2 |
| `app:abundant` cited by label | M (C15 fails) | L | Cite `sub:AbsoluteTime` and quote the *Abundance* clause; `sub:` labels are not gated |
| Header linter rejects the module docstring (a `set_option`, `open`, or `namespace` before `/-! -/`) | M | L | Copy `Standard.lean`'s header shape exactly: copyright block, imports, `/-! -/`, then `namespace`/`open`; no `set_option` anywhere in either module |
| `Semantics/Frames/README.md` is also touched by task 625 | M (merge conflict or lost row) | L | Dispatch forbids concurrent runs; Phase 4 re-reads the README immediately before editing rather than applying a stored diff |
| `--emit-inventory` rewrites root `README.md` totals and `FormalSystem/README.md` line counts that other in-flight tasks also regenerate | M | M | Run `--emit-inventory` once, last, in Phase 4 immediately before the gate; stage only the files this task touched, listed explicitly |
| Files outside the declared `file_scope` (`docs/theorem-index.md`, `scripts/check-module-invariants.sh`, `FormalSystem/Semantics/README.md`, `FormalSystem/Semantics.lean`, `specs/evidence/...`) are not staged by postflight | M | M | The implementer lists every touched file in `modified_files` (repo-relative, individual paths) — the plan's per-phase file lists are the source |
| `Classical.choice` in the profile read as Zorn | L | L | Module 1 docstring records the provenance (`TaskFrame.limit_of_shift`'s `exists_ne`), as `TaskFrame.lean` does; `prodRel_saturation` is `[propext, Quot.sound]` |
| A `lake build --wfail` warning in a new file (unused variable, unused section variable) | M | L | The probe compiles with zero warnings without the suppression (Appendix A of the report); any warning that does appear is fixed at source, never suppressed with an unscoped `set_option` (C29/C30) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel. Phases 2 and 3 edit disjoint files; Phase 3
needs only Phase 1's `translationProduct`, `translationProduct_taskRel`, `liftH`, `projH`,
`projH_liftH`, `liftH_projH` and `liftModel`, which is why `liftModel` and `liftH_through` are
placed in Phase 1 rather than with the invariances.

### Phase 1: Module 1 — relation, live frame, histories, module docstring [COMPLETED]

**Goal**: Create `FormalSystem/Semantics/Frames/TranslationProduct.lean` with the copyright
header, imports, the complete module docstring, and the probe's `Bare`, `Frame` and `Histories`
material transcribed against live names (probe lines 50-313, plus `liftModel` and
`liftH_through` from lines 319-326), building green under `--wfail` as a scoped module.

**Tasks**:
- [x] Header, in `Standard.lean`'s exact shape: copyright block; `import Mathlib.Tactic.Abel`,
      `import FormalSystem.StarLanguage.StarValidity`,
      `import FormalSystem.Semantics.HistoryMorphism` (transitively `PlusValidity`, `Validity`,
      `TaskFrame`, `PartialHistory`; do NOT import `Frames.Standard`, `Mathlib`, or `Lean`);
      then the module docstring as the first command; then `namespace FormalSystem.Semantics`
      and `open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.StarLanguage`.
- [x] Module docstring (R3 of the report), sections in this order: title; the standing caveat in
      the first paragraph (a PROOF DEVICE showing what L, L⁺ and L⋆ cannot see of a task frame —
      recurrence and transposition — never an intended model; a state carrying a clock reading is
      not a world state in the manuscript's sense); the construction as time-unfolding, quoting
      `sub:Conclusion`'s "recovered by unfolding the transitions that the task relation permits";
      `## Main Definitions` / `## Main Results` lists; `## Frame-level validity is not reflected`
      (`p → Gp` valid on the one-state frame, refuted on its product by `V (u, e) p := e ≤ 0`;
      the extra valuations are `sub:AbsoluteTime`'s abundant two-dimensional models, quoted by
      the *Abundance* clause; name `frame_validity_not_reflected`); `## What the device does not
      settle` (neutral on Saturation and determinism; silent on the stability modal beyond
      state-locality); `## Limit` (nil beyond the zero loops of `lem:nullity`; the Mathlib-only
      mirror at `specs/evidence/translation-product/limit-idle-mirror.lean` records the zeroFix
      results outside the library because no non-Limit frame type exists in the tree); `## Paper
      correspondence` in `HistoryMorphism.lean`'s style (the manuscript defines no product of task
      frames; formalization-native); a one-line axiom note (`pcq`, provenance
      `TaskFrame.limit_of_shift`).
- [x] Section `Bare` (`variable {D : TemporalOrder} {W : Type} (R : W → ↑D → W → Prop)`):
      `prodRel`, `prodRel_reflection`, `prodRel_comp`, `prodRel_serial`, `prodRel_limit`,
      `prodRel_const_clock`, `prodRel_fib_image`, `prodRel_seg_image` (helpers; `private` is
      acceptable), `prodRel_saturation`, `saturation_of_prodRel`, `colourClock`
      (`[Finite W] [Nonempty W]`, no Limit hypothesis). Proofs verbatim from the probe. *(deviation: altered — five goal-changing `show` tactics became `change` (`linter.style.show` fires under the package's linter set; the probe was compiled outside it))*
- [x] Section `Frame` (`variable {D : TemporalOrder} (F : FrameOver D)`):
      `FrameOver.translationProduct : FrameOver D` (probe `prodFrame`),
      `@[simp] FrameOver.translationProduct_taskRel`, `FrameOver.translationProduct_sat`
      (`cases fc <;> exact Iff.rfl`), `FrameOver.translationProduct_deterministic_iff`.
- [x] Histories: `liftH`, `projH`, `liftH_state`, `projH_state`, `projH_liftH`, `clock_eq`,
      `liftH_projH`, `no_recurrence`, `no_transposition`,
      `translationProduct_recurrenceFree : F.translationProduct.toTaskFrame.RecurrenceFree`
      (against the live predicate; body `fun τ' _ _ h => no_recurrence F τ' h`), then
      `liftModel` (probe `liftM`) and `liftH_through`.
- [x] Per-declaration docstrings rewritten with durable anchors only: no `Probe624`, no
      "probe NNN/NN", no "report NN §", no "for NNN", no manuscript line numbers. Pinned labels
      available: `def:frame`, `def:world-history`, `lem:nullity`, `cor:saturation-finite`
      (`colourClock`), `def:deterministic` (`translationProduct_deterministic_iff`).
- [x] Scoped build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
      FormalSystem.Semantics.Frames.TranslationProduct` (detached, `run_in_background: true`),
      green with zero warnings.
- [x] `grep -nE '[0-9]{3,4}' FormalSystem/Semantics/Frames/TranslationProduct.lean` — read every
      hit; the only legitimate matches are the copyright year and numerals inside Lean code.
- [x] Commit: `task 645 phase 1: translation product — relation, frame, histories`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Approximately 250 lines of Lean (probe lines 50-313 plus `liftModel` and
`liftH_through`, about 200 lines of declarations) plus about 100 lines of module and declaration
docstrings. Confirm at implementation time by `wc -l` on the new file after the scoped build is
green; a count outside 280-420 means a section was dropped or the docstring was padded.

**Files to modify**:
- `FormalSystem/Semantics/Frames/TranslationProduct.lean` - create (header, docstring, `Bare`,
  `Frame`, histories, `liftModel`, `liftH_through`)

**Verification**:
- Scoped `lake build` of `FormalSystem.Semantics.Frames.TranslationProduct` exits 0 with no
  warnings under the package's `--wfail`-equivalent options.
- `grep -c sorry FormalSystem/Semantics/Frames/TranslationProduct.lean` is 0.
- `grep -nE 'set_option|import Mathlib$|import Lean' FormalSystem/Semantics/Frames/TranslationProduct.lean`
  is empty.
- The module docstring is the first command after the imports (header linter shape).

---

### Phase 2: Module 1 — invariances, class-validity theorems, non-reflection example [COMPLETED]

**Goal**: Complete Module 1 with the three truth invariances, the three `*ValidOn_of_prod`
lemmas, the three flagship `*ValidIn_iff_recurrenceFree` theorems, `frame_validity_not_reflected`,
and the projection morphism instance; scoped build green; `--no-build` invariants clean on the
file's docstrings.

**Tasks**:
- [x] Section `Frame` (continued): `truth_invariance`, `plus_invariance`, `star_invariance`
      (probe lines 328-432, verbatim; the model argument is `liftModel F M`).
- [x] `plusValidOn_of_prod`, `starValidOn_of_prod`, `validOn_of_prod` (probe lines 443-461),
      docstring noting the converse fails (`frame_validity_not_reflected`).
- [x] `FrameOver.translationProductProj : HistMorphism F.translationProduct F` (probe `prodProj`,
      lines 628-634) — the instance `HistoryMorphism.lean`'s docstring says "lives with the
      translation product". Name chosen over `translationProduct.proj` to avoid nesting a
      declaration under a `def`'s namespace and over `translationProduct_proj` because C26
      forbids non-trailing underscores in `def` names.
- [x] Section `ClassValidity`: `plusValidIn_iff_recurrenceFree`, `validIn_iff_recurrenceFree`,
      `starValidIn_iff_recurrenceFree` with RHS predicate `fun G => fc.Sat G ∧ G.RecurrenceFree`
      (exact signatures in `## Lean Challenge Statements`). Each docstring ends with the line
      `Paper: — (formalization-native; the paper defines no product of task frames)` in
      `HistoryMorphism.lean`'s exact style (C15's second assertion requires it once the
      theorem-index rows exist).
- [x] `frame_validity_not_reflected` (probe lines 509-536) with the atom inlined as
      `⟨"p", none⟩` (no global `p₀`); *(deviation: altered — the two goal-changing `show`s became `change`, as in Phase 1)* docstring cites `sub:AbsoluteTime`'s *Abundance* clause by
      quotation, never `app:abundant` and never a line range.
- [x] `end FormalSystem.Semantics`; scoped build green with zero warnings.
- [x] `bash scripts/check-module-invariants.sh --no-build` — read the C9, C15, C23, C26 results
      for the new file; fix any docstring finding at source. (C33/INV/C14 findings about the
      unwired module are expected at this point and are Phase 4's job — record them, do not
      chase them here.)
- [x] `grep -nE '[0-9]{3,4}' FormalSystem/Semantics/Frames/TranslationProduct.lean` — re-read
      every hit.
- [x] `lean_verify` on `FormalSystem.Semantics.validIn_iff_recurrenceFree`,
      `FormalSystem.Semantics.plusValidIn_iff_recurrenceFree`,
      `FormalSystem.Semantics.starValidIn_iff_recurrenceFree`: expect exactly
      `[propext, Classical.choice, Quot.sound]`, no sorry.
- [x] Commit: `task 645 phase 2: translation product — invariances and class validity`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Approximately 220 lines added (probe lines 328-536 and 628-634, about
180 lines of declarations, plus docstrings), bringing the file to roughly 470 lines total — under
the 1500-line `longFile` limit, so no baseline `set_option` is needed. Confirm by `wc -l` after
the scoped build; a total above 600 means docstrings were padded, below 400 means a declaration
was dropped.

**Files to modify**:
- `FormalSystem/Semantics/Frames/TranslationProduct.lean` - append invariances,
  `*ValidOn_of_prod`, `translationProductProj`, `ClassValidity` section

**Verification**:
- Scoped build green, zero warnings, zero `sorry`.
- `lean_verify` on the three flagship theorems returns standard axioms only.
- `check-module-invariants.sh --no-build` reports no C9/C15/C23/C26 finding against
  `TranslationProduct.lean`.
- Every dispatch-named declaration for Module 1 resolves: `lean_local_search` for each of
  `prodRel`, `prodRel_reflection`, `prodRel_comp`, `prodRel_serial`, `prodRel_limit`,
  `prodRel_saturation`, `saturation_of_prodRel`, `translationProduct`,
  `translationProduct_taskRel`, `translationProduct_sat`,
  `translationProduct_deterministic_iff`, `colourClock`, `liftH`, `projH`, `projH_liftH`,
  `liftH_projH`, `clock_eq`, `no_recurrence`, `no_transposition`, `truth_invariance`,
  `plus_invariance`, `star_invariance`, `validOn_of_prod`, `plusValidOn_of_prod`,
  `starValidOn_of_prod`, `validIn_iff_recurrenceFree`, `plusValidIn_iff_recurrenceFree`,
  `starValidIn_iff_recurrenceFree`.

---

### Phase 3: Module 2 — coarse-model lifting [COMPLETED]

**Goal**: Create `FormalSystem/Metalogic/Independence/TranslationProductCoarse.lean` carrying
`liftK`, `c_invariance`, `pasteClosed_liftK`, `pasteClosed_of_liftK`, `c_refuted_lift` (probe
lines 702-775), building green as a scoped module.

**Tasks**:
- [x] Header in `Standard.lean`'s shape; imports
      `FormalSystem.Semantics.Frames.TranslationProduct` and
      `FormalSystem.Metalogic.Independence.PastedCoarseModels`; module docstring first; then
      `namespace FormalSystem.Metalogic.Independence`, `open FormalSystem.Syntax
      FormalSystem.PlusLanguage FormalSystem.Semantics CTruth` (as `PastedCoarseModels.lean`
      does), `variable {D : TemporalOrder} (F : FrameOver D)`.
- [x] Module docstring: what transfers (coarse refutations and paste-closure) and in which
      direction; the standing "proof device, never an intended model" caveat in one sentence with
      a pointer to `Semantics/Frames/TranslationProduct.lean` for the full statement; why this is
      a separate file from `PastedCoarseModels.lean` (that module is upstream of
      `LimitClosureCountermodel` and `PlusIncompleteness`, is written over a bare `TaskFrame`,
      and must not acquire `StarLanguage.StarValidity` in its closure); `Paper: —` line.
- [x] `liftK`, `c_invariance`, `pasteClosed_liftK`, `pasteClosed_of_liftK`, `c_refuted_lift`
      verbatim, with `prodFrame` -> `F.translationProduct`, `liftM` -> `liftModel`.
- [x] Docstrings with durable anchors only (same rule as Phases 1-2).
- [x] Scoped build: `... -- build FormalSystem.Metalogic.Independence.TranslationProductCoarse`,
      green, zero warnings.
- [x] `lean_verify` on `FormalSystem.Metalogic.Independence.c_refuted_lift`: expect
      `[propext, Classical.choice, Quot.sound]`, no sorry.
- [x] `grep -nE '[0-9]{3,4}'` over the new file; read every hit.
- [x] Commit: `task 645 phase 3: translation product — coarse-model lifting`.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Approximately 110 lines (about 75 lines of declarations plus docstrings).
Confirm by `wc -l`; a count above 180 means the docstring restates Module 1's caveat at length
instead of pointing to it.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/TranslationProductCoarse.lean` - create

**Verification**:
- Scoped build green, zero warnings, zero `sorry`.
- `lean_verify` on `c_refuted_lift` returns standard axioms only.
- `grep -n 'StarValidity' FormalSystem/Metalogic/Independence/PastedCoarseModels.lean` is empty
  (the addendum route was not taken).

---

### Phase 4: Wiring, evidence record, generated surfaces, pins, full gates [NOT STARTED]

**Goal**: Import both modules from their aggregators, document them, copy the mirror record to
`specs/evidence/`, regenerate the root and inventory blocks, pin the three flagship theorems
under C14 with theorem-index rows, and pass every acceptance gate.

**Tasks**:
- [ ] `FormalSystem/Semantics/Frames.lean`: add
      `import FormalSystem.Semantics.Frames.TranslationProduct` and a `## Modules` bullet
      (`Frames.TranslationProduct` — the translation product `FrameOver.translationProduct`, a
      proof device for what L, L⁺ and L⋆ cannot see of a frame).
- [ ] `FormalSystem/Metalogic/Independence.lean`: add
      `import FormalSystem.Metalogic.Independence.TranslationProductCoarse` and a `## Contents`
      bullet. Do NOT add a numbered result to the "Five results are carried here" list — the
      device is not an underivability result.
- [ ] `FormalSystem/Semantics.lean` docstring, at the clause "`DeterministicBridge` and
      `StateLocalTransfer` — the two cross-language bridges": add one clause naming
      `Frames.TranslationProduct` as a third cross-language module reached through the `Frames`
      aggregator.
- [ ] `FormalSystem/Semantics/README.md` row for `Frames/`: "`Standard` (1 file)" becomes 2 files
      with a one-line mention of `TranslationProduct`.
- [ ] `FormalSystem/Semantics/Frames/README.md` (RE-READ the file first; task 625 shares it):
      `## Key Definitions` bullet for `FrameOver.translationProduct` and the three flagship
      theorems; in the generated block, fill the trailing description column for the new row AND
      the existing `Standard.lean` row (currently `<!-- TODO: add description -->`).
- [ ] `FormalSystem/Metalogic/Independence/README.md`: generated-block description for the new
      row; one sentence under the result-8 paragraph noting that coarse refutations and
      paste-closure transfer to the translation product.
- [ ] `mkdir -p specs/evidence/translation-product` and copy
      `specs/624_translation_product_task_semantics_visibility/probes/02_limit-idle-mirror.lean`
      to `specs/evidence/translation-product/limit-idle-mirror.lean` unchanged (Mathlib-only;
      `lake env lean specs/evidence/translation-product/limit-idle-mirror.lean` exits 0). Confirm
      the Module 1 docstring's `## Limit` note cites exactly this path.
- [ ] `docs/theorem-index.md`: three rows (label `—`, axioms `pcq pinned:C14`) for
      `FormalSystem.Semantics.validIn_iff_recurrenceFree`,
      `FormalSystem.Semantics.plusValidIn_iff_recurrenceFree`,
      `FormalSystem.Semantics.starValidIn_iff_recurrenceFree`, file
      `FormalSystem/Semantics/Frames/TranslationProduct.lean`, under a new
      `### The translation product` subsection placed after "Characterization and definability".
- [ ] `scripts/check-module-invariants.sh`: append three lines to the `C14BASE` heredoc
      (`'FormalSystem.Semantics.validIn_iff_recurrenceFree' depends on axioms: [propext,
      Classical.choice, Quot.sound]` and the two siblings) and the three matching
      `#print axioms FormalSystem.Semantics.…` lines to the `C14LEAN` heredoc, in the same order
      (the two heredocs are compared by exact string equality).
- [ ] `lake exe mk_all --lib FormalSystem` (never hand-edit `FormalSystem.lean`).
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory` — last, immediately before the
      gates. Expected touched files: `FormalSystem/Semantics/Frames/README.md`,
      `FormalSystem/Metalogic/Independence/README.md`, `FormalSystem/README.md`, root `README.md`.
      Diff-read each; a change to any other file is a finding to investigate, not to stage.
- [ ] Full build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
      (detached), then confirm the `--wfail` configuration reports zero warnings.
- [ ] Gates: `lake exe mk_all --lib FormalSystem --check` exit 0;
      `bash scripts/check-module-invariants.sh` (full, with build) all checks pass, including
      C14 (new pins match), C15 (the three `Paper: —` lines resolve), C33, INV;
      `bash scripts/check-metalogic-cycles.sh` passes (assertion B: no new upward edge).
- [ ] `lean_verify` on the three flagship theorems once more against the full build: standard
      axioms only.
- [ ] Commit: `task 645 phase 4: wiring, evidence record, pins and gates`, staging only the
      files in this phase's list plus the two modules (explicit path list, never a directory
      pathspec).

**Timing**: 1.5 hours

**Depends on**: 2, 3

**Verification Tier**: full

**Scope Hypothesis**: Twelve files touched outside the two modules: `Semantics/Frames.lean`,
`Metalogic/Independence.lean`, `Semantics.lean`, `Semantics/README.md`, `Semantics/Frames/README.md`,
`Metalogic/Independence/README.md`, `FormalSystem/README.md`, root `README.md`, `FormalSystem.lean`
(generated), `docs/theorem-index.md`, `scripts/check-module-invariants.sh`,
`specs/evidence/translation-product/limit-idle-mirror.lean`. Confirm with `git status --short`
before the commit; any file outside this list plus the two modules is unexplained and must be
accounted for before staging.

**Files to modify**:
- `FormalSystem/Semantics/Frames.lean` - import + `## Modules` bullet
- `FormalSystem/Metalogic/Independence.lean` - import + `## Contents` bullet
- `FormalSystem/Semantics.lean` - one docstring clause
- `FormalSystem/Semantics/README.md` - `Frames/` row
- `FormalSystem/Semantics/Frames/README.md` - key-definitions bullet, two generated-row descriptions
- `FormalSystem/Metalogic/Independence/README.md` - generated-row description, one sentence
- `FormalSystem/README.md`, `README.md` - regenerated by `--emit-inventory` only
- `FormalSystem.lean` - regenerated by `mk_all` only
- `docs/theorem-index.md` - three rows, one subsection heading
- `scripts/check-module-invariants.sh` - three lines in each of two C14 heredocs
- `specs/evidence/translation-product/limit-idle-mirror.lean` - create (copy of probe 02)

**Verification**:
- `lake build --wfail` green (via the guarded, detached invocation).
- `lake exe mk_all --lib FormalSystem --check` exits 0.
- `bash scripts/check-module-invariants.sh` — every check passes.
- `bash scripts/check-metalogic-cycles.sh` passes.
- `lean_verify` on the three `*ValidIn_iff_recurrenceFree` theorems: standard axioms only.
- `grep -rnE '\b(tasks?[[:space:]]+#?[0-9]+|task-[0-9]+)\b|specs/[0-9]{3}_' FormalSystem/ docs/theorem-index.md`
  returns nothing new.

## Lean Challenge Statements

```lean
import FormalSystem.StarLanguage.StarValidity
import FormalSystem.Semantics.HistoryMorphism

namespace FormalSystem.Semantics

theorem validIn_iff_recurrenceFree (fc : FormalSystem.ProofSystem.FrameClass)
    (φ : FormalSystem.Syntax.Formula) :
    ValidIn fc φ ↔ ValidOnFrames (fun G => fc.Sat G ∧ G.RecurrenceFree) φ := sorry

theorem plusValidIn_iff_recurrenceFree (fc : FormalSystem.ProofSystem.FrameClass)
    (φ : FormalSystem.PlusLanguage.PlusFormula) :
    FormalSystem.PlusLanguage.PlusValidIn fc φ ↔
      FormalSystem.PlusLanguage.PlusValidOnFrames (fun G => fc.Sat G ∧ G.RecurrenceFree) φ := sorry

theorem starValidIn_iff_recurrenceFree (fc : FormalSystem.ProofSystem.FrameClass)
    (φ : FormalSystem.StarLanguage.StarFormula) :
    FormalSystem.StarLanguage.StarValidIn fc φ ↔
      FormalSystem.StarLanguage.StarValidOnFrames (fun G => fc.Sat G ∧ G.RecurrenceFree) φ := sorry

end FormalSystem.Semantics
```

## Testing & Validation

- [ ] Phase 1-3: scoped builds of each new module green with zero warnings and zero `sorry`.
- [ ] Phase 2: `check-module-invariants.sh --no-build` clean on C9/C15/C23/C26 for Module 1.
- [ ] Phase 4: full `lake build --wfail` green.
- [ ] Phase 4: `lake exe mk_all --lib FormalSystem --check` exit 0.
- [ ] Phase 4: `check-module-invariants.sh` (full) all checks pass; `check-metalogic-cycles.sh`
      passes.
- [ ] Phase 4: `lean_verify` on the three flagship theorems returns
      `[propext, Classical.choice, Quot.sound]` and no sorry.
- [ ] Phase 4: `lake env lean specs/evidence/translation-product/limit-idle-mirror.lean` exit 0.
- [ ] Every phase: `grep -nE '[0-9]{3,4}'` over the new module reviewed; no task numbers,
      probe/report numbers, or manuscript line numbers in any file outside `specs/`.

## Artifacts & Outputs

- `FormalSystem/Semantics/Frames/TranslationProduct.lean` (new, about 470 lines)
- `FormalSystem/Metalogic/Independence/TranslationProductCoarse.lean` (new, about 110 lines)
- `specs/evidence/translation-product/limit-idle-mirror.lean` (new, copy of probe 02)
- Edited: the aggregator, README, docstring, theorem-index and invariants-script files listed in
  Phase 4; regenerated: `FormalSystem.lean`, `FormalSystem/README.md`, `README.md`
- `specs/645_port_translation_product_into_library/summaries/01_port-translation-product-summary.md`

## Rollback/Contingency

- Each phase is committed only when green, so any failure leaves a green `HEAD`; the remedy for
  an in-progress phase that cannot be made green is fix-forward first (the proofs compile today —
  a failure is a transcription slip, an import path, or a docstring gate, each fixable at
  source). See `context/contracts/recovery.md`'s ladder.
- If an uncommitted working tree must genuinely be discarded, follow
  `context/contracts/recovery.md`'s rollback rung (snapshot-then-rollback; this task's declared
  `file_scope` omits several Phase 4 files, so the rung's out-of-scope override applies to a
  Phase 4 rollback). Never emit a bare `git-snapshot.sh 645` as a start-of-phase precaution.
- If Phase 4's `--emit-inventory` or `mk_all` touches files another in-flight task owns, do not
  stage them; report the collision in the summary and leave the regeneration for a clean tree.
- No `[BLOCKED]` condition is foreseeable short of an unrelated tree breakage; if `lake build`
  fails outside the new modules, mark the phase `[BLOCKED]` with the failing module named and
  stop rather than repairing unrelated code.
