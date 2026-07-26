# Implementation Plan: Task #394

- **Task**: 394 - resolve_mathlib_naming_convention_compliance
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/394_resolve_mathlib_naming_convention_compliance/reports/01_naming-convention-decision-evidence.md`
- **Artifacts**: plans/01_defprop-conversion-nolints-suppression.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, no-task-references-in-deliverables.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Execute route (c′) — the settled decision — in two mechanical steps: convert the 38
`linter.defProp` declarations from `def` to `theorem`, then add a **filtered**
`scripts/nolints.json` covering the residual 860 `defsWithUnderscore` findings, and record the
deviation in `docs/development/`. The route decision is closed: no declaration is renamed, no
`Prop`-wrapper refactor is attempted, and no `def` outside the pre-approved 38 is converted.
Definition of done: `lake exe runLinter Bimodal` reports `defsWithUnderscore` 0 and `defProp` 0,
every sibling linter category is bit-for-bit unchanged, `lake build` is green at 1874 jobs,
`lake build BimodalTest` is green at 1909 jobs, and exactly one live `sorry` remains.

### Research Integration

The research report pre-validated the *entire* 38-declaration conversion end-to-end in a scratch
clone (full build + Tests green, zero new warnings, `defProp` 38→0, `defsWithUnderscore`
888→860, all sibling categories frozen at 122/115/39/4/1) and separately verified the filtered
`nolints.json` mechanism (`defsWithUnderscore`→0 with siblings intact). This plan is therefore
sized to *transcription and verification*, not to discovery. Three empirically-found traps are
encoded as hard requirements in Phase 2 (§ noncomputable, `@[instance_reducible]`, line-number
offset), and the `--update` indiscriminacy trap is encoded in Phase 3.

The report's most load-bearing negative finding drives the verification design: `defsWithUnderscore`
is a Batteries env-linter that emits **nothing** during `lake build`, and CI runs `lean-action`
with `lint: false`. A green build is *not evidence* about this category. Every count in this plan
must come from an explicit `lake exe runLinter Bimodal` invocation.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- Convert exactly 38 `Prop`-typed `def`s to `theorem`s across 13 files, dropping `noncomputable`
  on the 31 that carry it and `@[instance_reducible]` on the one that carries it.
- Drive `linter.defProp` from 38 to 0 (and, as a verified side effect, `classDefReducibility`
  from 2 to 0).
- Add `scripts/nolints.json` containing **only** `defsWithUnderscore` entries, driving that
  category to 0 while leaving every sibling category numerically identical.
- Record the deviation as a deliberate engineering decision in `docs/development/`.
- Preserve the repository's core asset at every phase boundary: 1874-job green build, 1909-job
  green Tests, exactly one live `sorry`.

**Non-Goals**:
- Renaming any declaration (route (b) is rejected — 24,364 resolved call sites, 46.4% naive-replace
  error rate).
- The `Derivable`-restatement / `Prop`-wrapper refactor (rejected — permanent doubling of the
  combinator API for 135 of 888 findings).
- Converting `Bimodal.Metalogic.Bundle.canonicalR_transitive` (an `abbrev`, outside the
  `defProp`-defined subset — see report §2.6). Do not let it ride along.
- Renaming the 121 `→ Prop` predicates to UpperCamelCase (report §6.4 — costed separately, not
  approved).
- Anything under `Boneyard/` (unbuilt, inert).
- Touching the live `sorry` at `countermodel_discrete` (out of scope, report §8).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `noncomputable theorem` fails to elaborate | H | H (31 of 38 affected) | Phase 2 requires dropping `noncomputable` in the same edit as the `def`→`theorem` change; the build gate catches any miss immediately |
| `@[instance_reducible]` on a theorem fails ("not a definition") | H | Certain for 1 decl | Phase 2 explicitly deletes the attribute on `limitDomSubtype_denselyOrdered_from_F'T`; its sole consumer is a `letI` 22 lines below, build-verified in research |
| Position-anchored edit lands on the wrong line | H | M | Reported line numbers point at the **doc comment**, not the `def` keyword (offset 1-14 lines). Forward-scan from the anchor to the first `def` token of the named declaration. Never global substring replace (a sibling task silently corrupted `List.take_succ_cons` that way) |
| `runLinter --update` sweeps in sibling-owned categories | H | Certain if unfiltered | Phase 3 generates then **filters** to `defsWithUnderscore` only, and the Phase 3 gate is *equality* on all five sibling counts |
| Green `lake build` mistaken for evidence about `defsWithUnderscore` | M | M | Every phase gate names `lake exe runLinter Bimodal` explicitly; build-greenness is a separate, non-substituting criterion |
| Silent trespass onto a sibling task's linter category read as a "bonus" | M | L | Differential gate is strict equality (not `<=`) on `unusedArguments` / `LINTER FAILED` / `docBlame` / `tacticDocs` / `structureInType` |
| Deliverable docs cite ephemeral task numbers | L | M | Phase 4 writes to `docs/development/` under `no-task-references-in-deliverables.md`: cite `ProofSystem/Derivation.lean`, the Mathlib `scripts/nolints.json` precedent, and section headings — never "task 394" |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is fully sequential: each phase's
gate supplies the frozen baseline the next phase is measured against.

---

### Phase 1: Establish and Freeze the Measured Baseline [COMPLETED]

**Goal**: Reproduce the research baseline in the working tree and freeze the sibling-category
values that every later differential gate is checked against. Nothing is mutated in this phase.

**Tasks**:
- [ ] Confirm working tree is clean (`git status --porcelain` empty) before starting.
- [ ] Run `lake build` and record job count and exit code. Expect **1874 jobs, exit 0**.
- [ ] Run `lake build BimodalTest` and record job count. Expect **1909 jobs, exit 0**.
- [ ] Locate the sole live `sorry` **by content** — search for `countermodel_discrete` in
      `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` — and confirm the count of live
      `sorry` occurrences project-wide (excluding `Boneyard/`) is exactly 1. Do not trust the
      line number 1242.
- [ ] Run `lake exe runLinter Bimodal`, capture full output to a scratch file, and tabulate
      per-category counts using the inherited `runlinter.py`.
- [ ] Record the measured `defProp` count from the `lake build` warning stream (this linter is
      syntactic and surfaces during `lake build`, unlike `defsWithUnderscore`). Expect **38**.
- [ ] **Freeze** the measured sibling values into a scratch baseline file. Research clone values
      for comparison: `unusedArguments` 122, `LINTER FAILED` 115, `docBlame` 39, `tacticDocs` 4,
      `structureInType` 1, `defsWithUnderscore` 888. If any measured value differs from these,
      **use the measured value as the frozen value** and note the divergence in the summary — do
      not adjust the code to match the report.

**Timing**: 0.5 hours (dominated by build time; builds should be near-incremental if the tree is
already built)

**Depends on**: none

**Files to modify**:
- None. This phase is read-only measurement.

**Tooling**:
- Prefer `specs/400_clear_lean_v433_deprecation_warnings/tools/runlinter.py` for parsing.
  Its `run_lint` carries a fix for a missing `-DautoImplicit=false` that made the harness
  elaborate more permissively than `lake build`. Solved parser traps already handled there:
  raw `lean` emits `PATH:L:C: severity: msg` while lake emits `severity: PATH:L:C: msg`;
  `LINTER FAILED` appears in two row shapes (positioned, and positionless `#check`) and can
  appear mid-message.
- Build targets are `Bimodal.*`, **not** `Theories.Bimodal.*` — the lakefile sets
  `srcDir := "Theories"` with the root namespace `Bimodal`.

**Verification**:
- `lake build` exit 0 at 1874 jobs; `lake build BimodalTest` exit 0 at 1909 jobs.
- Exactly 1 live `sorry`, located by content at `countermodel_discrete`.
- A frozen baseline file exists containing all six linter category counts.
- No files under `Theories/`, `Tests/`, or `scripts/` were modified.

---

### Phase 2: Convert the 38 `defProp` Declarations to `theorem` [COMPLETED]

**Goal**: Apply the pre-approved, research-proven conversion: 38 `def` → `theorem` edits across
13 files, dropping `noncomputable` on 31 and `@[instance_reducible]` on 1.

**Tasks**:
- [ ] For each of the 38 declarations listed in the research report's §2.2 table, locate the
      `def` keyword by **forward scan from the reported anchor line** for the named declaration.
      The reported line is the start of the command *including its doc comment*; the `def` keyword
      is 1-14 lines below. Never assume the reported line holds the `def`.
- [ ] Replace the `def` keyword with `theorem` using **position-anchored replacement**. Global or
      substring replacement is forbidden.
- [ ] For each of the **31 declarations carrying `noncomputable`**, delete the `noncomputable`
      modifier in the same edit. `noncomputable theorem` does not elaborate — this is not optional.
- [ ] For `limitDomSubtype_denselyOrdered_from_F'T` in
      `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`,
      additionally delete its `@[instance_reducible]` attribute. Its only consumer is a `letI`
      ~22 lines below in the same file; research build-verified the removal.
- [ ] Convert **exactly** these 38 and no others. In particular, do NOT touch
      `Bimodal.Metalogic.Bundle.canonicalR_transitive` (an `abbrev`).
- [ ] Run `lake build`; fix-forward any elaboration error (expected classes: a missed
      `noncomputable`, a missed attribute, or an edit landing on the wrong line).
- [ ] Run `lake build BimodalTest`.
- [ ] Diff the build warning census line-by-line against the Phase 1 capture.
- [ ] Commit at green build.

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify** (13 files, 38 declarations):
- `Theories/Bimodal/FrameConditions/FrameClass.lean` — 2 (`DenseTemporalFrame.mk'`,
  `DiscreteTemporalFrame.mk'`; neither `noncomputable`)
- `Theories/Bimodal/FrameConditions/Soundness.lean` — 1 (`soundness_over`; not `noncomputable`)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — 9 (all `noncomputable`)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` — 1 (`noncomputable`)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` — 1
  (not `noncomputable`; **carries `@[instance_reducible]`**)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` — 4 (all
  `noncomputable`)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — 5 (all `noncomputable`)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` — 2 (all `noncomputable`)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` — 2 (all `noncomputable`)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CustomGame.lean` — 2 (all `noncomputable`)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` — 1 (`noncomputable`)
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` — 5 (all `noncomputable`)
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` — 3 (`mcs` not
  `noncomputable`; the other 2 are)

**Verification**:
- `lake build` exit 0 at **1874 jobs**; `lake build BimodalTest` exit 0 at **1909 jobs**.
- `linter.defProp` warnings: **38 → 0**.
- `classDefReducibility` warnings: **2 → 0** (verified side effect on the two `mk'` declarations).
- Total build warnings **70 → 30**; **zero** warnings *added* (line-by-line census diff against
  Phase 1).
- `lake exe runLinter Bimodal`: `defsWithUnderscore` **888 → 860** (exactly −28; the other 10 of
  the 38 were never in that category — 3 have no underscore, 7 are namespace-excluded).
- **Differential gate — strict equality** on the Phase-1-frozen sibling values:
  `unusedArguments` == 122, `LINTER FAILED` == 115, `docBlame` == 39, `tacticDocs` == 4,
  `structureInType` == 1. Any inequality in *either* direction is trespass and must be
  investigated, not accepted as a bonus.
- Exactly 1 live `sorry`, still at `countermodel_discrete` (by content).
- Commit: `task 394 phase 2: convert 38 Prop-typed defs to theorems`.

---

### Phase 3: Add a Filtered `scripts/nolints.json` [COMPLETED]

**Goal**: Suppress the residual 860 `defsWithUnderscore` findings via a curated nolints file
covering that category **only**, leaving every sibling category live.

**Tasks**:
- [ ] Run `lake exe runLinter Bimodal --update` to generate `scripts/nolints.json` in one command.
      Note: this file does not exist in the repository today, so this creates it. The invocation
      CWD matters — `nolintsFile := "scripts/nolints.json"` is resolved relative to CWD.
- [ ] **Filter the generated file to `defsWithUnderscore` entries only.** `--update` is
      indiscriminate: unfiltered it would also silence the 122 `unusedArguments`, 115
      `LINTER FAILED`, 39 `docBlame`, 4 `tacticDocs`, and 1 `structureInType` that belong to
      sibling tasks. Schema is `Array (Name × Name)` = `[[linterName, declName], …]`; retain only
      rows whose `linterName` is `defsWithUnderscore`. Keep the file sorted, as `--update` writes it.
- [ ] Confirm the filtered file contains **exactly 860** entries and that **no** entry names any
      other linter.
- [ ] Do **not** add any inline `@[nolint defsWithUnderscore]` attributes. Upstream Mathlib carries
      zero of these and uses the JSON file exclusively; keeping suppression in one auditable file
      is the point.
- [ ] Re-run `lake exe runLinter Bimodal` and tabulate.
- [ ] Run `lake build` and `lake build BimodalTest` to confirm the new file changed nothing about
      compilation.
- [ ] Commit at green.

**Timing**: 0.75 hours

**Depends on**: 2

**Files to modify**:
- `scripts/nolints.json` — **new file**, 860 `defsWithUnderscore` entries.

**Verification**:
- `lake exe runLinter Bimodal`: `defsWithUnderscore` **860 → 0**.
- **Differential gate — strict equality** on the frozen sibling values: `unusedArguments` == 122,
  `LINTER FAILED` == 115, `docBlame` == 39, `tacticDocs` == 4, `structureInType` == 1. These must
  still appear in the linter output; if any went to 0, the filter failed and swept in a sibling
  category.
- `jq` over `scripts/nolints.json` confirms 860 rows and exactly one distinct `linterName`.
- `lake build` exit 0 at 1874 jobs; `lake build BimodalTest` exit 0 at 1909 jobs; exactly 1 live
  `sorry`.
- Commit: `task 394 phase 3: add filtered scripts/nolints.json`.

---

### Phase 4: Document the Deviation [NOT STARTED]

**Goal**: Record snake_case retention as a deliberate, reasoned engineering decision with its
architectural cause and its upstream precedent — so a future reader (or a downstream port) meets
a decision, not an oversight.

**Tasks**:
- [ ] Write `docs/development/NAMING_CONVENTION_DEVIATION.md` covering:
  - **What the deviation is**: 860 declarations retain snake_case names that Mathlib's
    `defsWithUnderscore` env-linter would flag; they are suppressed via a curated
    `scripts/nolints.json`.
  - **Why snake_case is retained**: the names read as mathematics —
    `box_conj_iff`, `perpetuity_5`, `s4_box_diamond_box`. Renaming them to lowerCamelCase would
    degrade the readability of the layer where the library's mathematical content lives.
  - **The architectural root cause**: `DerivationTree` at `Theories/Bimodal/ProofSystem/Derivation.lean:85`
    is `Type`-valued, so every derived theorem built from it must be a `def` rather than a
    `theorem`, and `def` is what the linter inspects. This is genuinely load-bearing —
    `DerivationTree.height` is a computable `Nat`-valued recursor with dozens of references, and
    the `Automation/` proof-search layer consumes real trees, not `Nonempty` witnesses. Note that
    this explanation is precise for `Theorems/` (where it accounts for 100% of findings) and does
    not extend to the ordinary data definitions elsewhere, whose snake_case names are a stylistic
    choice.
  - **The upstream precedent**: Mathlib's own `scripts/nolints.json` carries 493
    `defsWithUnderscore` entries out of 719 total, and zero inline `@[nolint]` attributes.
    Curated suppression of this linter is established practice, not a workaround.
  - **What was actually fixed**: the 38 `Prop`-typed `def`s that were genuinely wrong have been
    converted to `theorem`s; `linter.defProp` and `classDefReducibility` are both at 0.
  - **Scope of the suppression and how to re-audit**: `defsWithUnderscore` emits nothing during
    `lake build` and CI runs with `lint: false`, so `lake exe runLinter Bimodal` is the only gate
    that observes this category. State that explicitly so a future reader does not read a green
    build as compliance.
  - **What would reopen the decision**: a port into a downstream library that enforces the
    env-linters as a hard gate.
- [ ] Add a short cross-reference from `docs/development/LEAN_STYLE_GUIDE.md` to the new document
      so the deviation is discoverable from the style guide rather than only from `scripts/`.
- [ ] **No task-number citations** in either file. Per
      `.claude/rules/no-task-references-in-deliverables.md`, cite durable anchors: the file paths
      `Theories/Bimodal/ProofSystem/Derivation.lean`, `scripts/nolints.json`, the Mathlib
      `scripts/nolints.json` precedent, and section headings. Never "task 394".
- [ ] Write the implementation summary to
      `specs/394_resolve_mathlib_naming_convention_compliance/summaries/01_defprop-conversion-nolints-suppression-summary.md`,
      including the full before/after linter table and any divergence from the research clone's
      frozen values.
- [ ] Commit at green.

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- `docs/development/NAMING_CONVENTION_DEVIATION.md` — new
- `docs/development/LEAN_STYLE_GUIDE.md` — add cross-reference
- `specs/394_resolve_mathlib_naming_convention_compliance/summaries/01_defprop-conversion-nolints-suppression-summary.md` — new

**Verification**:
- `docs/development/NAMING_CONVENTION_DEVIATION.md` exists, is non-empty, and covers all seven
  bullets above.
- `grep -niE 'task [0-9]+|tasks [0-9]+' docs/development/NAMING_CONVENTION_DEVIATION.md
  docs/development/LEAN_STYLE_GUIDE.md` returns no task-number citations.
- `lake build` exit 0 at 1874 jobs; `lake build BimodalTest` exit 0 at 1909 jobs; exactly 1 live
  `sorry` (markdown-only phase, but the invariant is checked at every phase boundary).
- Commit: `task 394 phase 4: document naming-convention deviation`.

---

## Testing & Validation

Run at **every** phase boundary (the standing invariant):

- [ ] `lake build` — exit 0, **1874 jobs**
- [ ] `lake build BimodalTest` — exit 0, **1909 jobs**
- [ ] Exactly **1** live `sorry`, located **by content** (`countermodel_discrete` in
      `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`), never by line number
- [ ] Commit on every green build (per-phase, and at any green sub-step within Phase 2)

Category-specific gates (`lake exe runLinter Bimodal` is the **only** gate that observes
`defsWithUnderscore` — a green `lake build` proves nothing here):

- [ ] After Phase 2: `defProp` 38 → **0**; `classDefReducibility` 2 → **0**;
      `defsWithUnderscore` 888 → **860**; total build warnings 70 → 30 with **0 added**
- [ ] After Phase 3: `defsWithUnderscore` 860 → **0**
- [ ] After Phases 2 and 3: sibling categories **equal** (not merely `<=`) their Phase-1-frozen
      values — `unusedArguments` 122, `LINTER FAILED` 115, `docBlame` 39, `tacticDocs` 4,
      `structureInType` 1
- [ ] `scripts/nolints.json` contains exactly 860 rows, all with `linterName ==
      defsWithUnderscore`
- [ ] Zero declarations renamed; exactly 38 `def`s converted to `theorem`

## Artifacts & Outputs

- `plans/01_defprop-conversion-nolints-suppression.md` (this file)
- `summaries/01_defprop-conversion-nolints-suppression-summary.md`
- `scripts/nolints.json` (new, 860 filtered entries)
- `docs/development/NAMING_CONVENTION_DEVIATION.md` (new)
- `docs/development/LEAN_STYLE_GUIDE.md` (cross-reference added)
- 38 `def` → `theorem` conversions across 13 files under `Theories/Bimodal/`

## Rollback/Contingency

Each phase commits only at a verified-green build, so rollback is per-phase and clean.

- **Phase 2 fails to build after edits**: fix forward. The three known failure classes each
  produce a compile-time error naming the declaration: a retained `noncomputable`, the retained
  `@[instance_reducible]`, or an edit that landed on the wrong line. If a fix-forward attempt is
  needed on a dirty tree, run `bash .claude/scripts/git-snapshot.sh` before any destructive git
  operation.
- **Phase 3 filter sweeps a sibling category** (detected by a sibling count dropping to 0):
  regenerate `scripts/nolints.json` from the Phase 2 commit and re-filter. The file is new and
  standalone — deleting it fully restores pre-Phase-3 linter behavior with zero effect on
  compilation.
- **Any phase leaves the build red**: revert to the last green phase commit. The repository's
  1874-job green build with a single tracked `sorry` is the asset being protected; no partial
  state that breaks it is acceptable.
- **Measured Phase 1 baseline diverges from the research clone's values**: do not adjust code to
  match the report. Freeze the measured values, proceed with those as the differential gate, and
  record the divergence in the summary.
