# Implementation Plan: Proof mode — axiom audit, diagnostics standard and cost baseline

- **Task**: 961 - Proof mode: axiom audit and cost baseline (M13, diagnostics standard)
- **Status**: [NOT STARTED]
- **Effort**: 13 hours
- **Dependencies**: None hard. The dependency on the file split is for test-directory layout only. PR #7 (the `lrewrite`/`lsimp` congruence kit) has MERGED, which activates the task's conditional nested-logical-rewrite baseline. PRs #8, #9, #10 remain open.
- **Research Inputs**: specs/961_proof_mode_axiom_audit_and_cost_baseline/reports/01_axiom-audit-cost-baseline.md
- **Artifacts**: plans/01_axiom-audit-cost-baseline.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The task carries four deliverable surfaces: one diagnostics record schema for every stage of the
library pipeline, the two commands that emit its RE-PROVE and COMPARE records, the reference page
that documents every field, and the original pair — an axiom-audit test module plus a recorded
cost baseline with its reproduction script. Research already measured the entire baseline at
commit `521385a9`, so no phase below is discovery work: each one checks in the harness that
reproduces an already-compiled figure. Definition of done is the task's own DONE WHEN — the audit
test passes in `lake test` and `docs/development/proof-mode-cost-baseline.md` exists with its
reproduction command — plus the three revision clauses (schema, emitters, `docs/reference/diagnostics.md`).

### Research Integration

Every figure the plan schedules is already measured, and the plan's shape is driven by three of
the report's findings rather than by its recommendations alone:

- **`#print axioms` cannot name an `example`** (probed: `#print axioms P6._example` →
  `Unknown constant`). All 52 proof-mode acceptance declarations are anonymous `example`s and the
  task forbids changing them, so both the audit module and the cost probe measure **named
  mirrors** instead of annotating the fixtures. Re-derived at plan-authoring time:
  `grep -c '^example'` over the five `Tests/BimodalTest/Automation/ProofMode*Test.lean` modules
  gives 31 + 6 + 4 + 6 + 5 = **52**.
- **The tactic-family partition is not the axiom partition.** `lstart`/`lapply`/`lexact`/`lsplit`
  rest on `[propext]` alone; a single `lintro`, and `lcases` on a disjunction, pull in
  `[propext, Classical.choice, Quot.sound]` through the deduction theorem. TM⁺ rows measure
  *lighter* (`[propext, Quot.sound]`, no `Classical.choice`). So the audit pins the
  `[propext]`/classical **boundary**, not a one-row-per-family census.
- **The record's open question is answered and the answer is two-part.** `lintro` nesting costs
  `5n² + 17n + 41` in elaborated term size (exact, residual zero, `n = 2..16`) while heartbeats
  grow linearly at ~5.3/level: the quadratic is kernel-side, not elaborator-side. The nested
  logical rewrite is `785 + 346·d`, linear. Both laws are recorded, not just the single
  five-step point the task asks for.

Both measurement instruments exist in the pinned tree with no new dependency: Mathlib's
`#count_heartbeats` and `Lean.Expr.sizeWithoutSharing`, with `DerivationTree.height` by `#eval`
on closed instances.

### Prior Plan Reference

No prior plan. This is the task's first planning round.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and `roadmap_flag` is not set, so no roadmap
phases are added. The task's own milestone anchor is M13 of `records/proof-mode.md`
(*Diagnostics standard, trust and cost baseline*), Evaluation lane, which files its work in
`BimodalLib/Diagnostics/` and `docs/development/` — exactly where this plan puts it. Two records
consume this one hard: `proof_mode_reprove_perpetuity` (the adequacy gate, which needs a quotable
cost figure) and `theorem_library_tableau_pipeline` (which writes the other five stages' emitters
against this schema).

## Goals & Non-Goals

**Goals**:

- One diagnostics record schema covering all seven pipeline stages, keyed by statement identifier
  and stage, carrying fragment, frame class, commit and the producing command in a shared head,
  with the RE-PROVE and COMPARE payloads implemented and the other five stages' keys reserved.
- Two command elaborators that emit the RE-PROVE and COMPARE records for a proof-mode script,
  each `throwError` path pinned by a `#guard_msgs` negative test.
- A computable node-count measure beside the existing derivation height, so a record can report
  built-derivation size and not only height.
- Every field of the schema documented at `docs/reference/diagnostics.md`, since a stage is not
  complete until its fields are documented.
- An axiom-audit test module on the pattern of `Tests/BimodalTest/WalkthroughAxioms.lean`,
  asserting the axiom set of at least one derivation per tactic family in TM and in TM⁺, and
  pinning the `[propext]`/classical boundary the research measured.
- A recorded cost baseline at `docs/development/proof-mode-cost-baseline.md` with its measuring
  script checked in: derivation-term size and elaboration time for each acceptance example, for a
  long script with at least five nested `lintro` steps, for one nested logical rewrite, and per
  tier (views, derivation).

**Non-Goals**:

- Changing any proof-mode rule, tactic or elaborator. The task is measurement only and does not
  wait on the Perpetuity adequacy verdict for that reason.
- Modifying the 52 existing acceptance `example`s. They stay byte-identical; the task requires
  them to keep passing unchanged.
- Implementing the enumerate, decide, extract, certify or admit emitters. Their keys are reserved
  in the schema and the reference page; `theorem_library_tableau_pipeline` writes them.
- Pinning any measured number with `#guard_msgs`. Heartbeats and term sizes are not stable across
  a Lean or Mathlib bump; only axiom sets are pinned.
- Touching `FormalSystem/` at all (see Decisions), and therefore any of the four generated
  surfaces a `FormalSystem/` line-count change would move.
- Any semantic-tier measurement. The semantic mode is not in merged state (PRs #9 and #10 open)
  and the task names exactly the views and derivation tiers.
- Enlarging, re-sweeping or re-proving the `BimodalLib` registry. No row is added, so no index
  regeneration is implied.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A commit staging any `.lean` path is refused because `typst/generated/status.typ` has drifted (`.githooks/pre-commit`, blocking) | H | H | `tests-file-count`/`tests-line-count` are tracked fields, so every phase that adds a `Tests/` module regenerates `status.typ` **in that same phase**: `lake build && bash scripts/typst-sync-check.sh --fix && git add typst/generated/status.typ`. Phases 2, 4 and 5 carry the file in their own scope. |
| `readme-lint.sh` Check 1 (gated) fails because a new directory holding `.lean` files has no `README.md` | M | H | `BimodalLib/Diagnostics/README.md` is created in the same phase as the first module under it (Phase 3). |
| `readme-lint.sh` Check 4 (gated, `ENFORCE_README_DATES=1`) reports a newly stale `Last verified` date | M | H | Adding `BimodalLib/Diagnostics/` makes `BimodalLib/README.md`'s date stale by `git log -1 -- BimodalLib`. Phase 3 refreshes it and adds the `Diagnostics/` row. Each touched directory README's date is refreshed in the phase that touches the directory. |
| C30 fails on an unscoped `set_option maxHeartbeats 0` / `profiler true` in the timing probe | H | M | C30 scans `FormalSystem/`, `Tests/` and `scripts/` only. The probe is therefore sited under `specs/evidence/`, where the identical pattern already lives in `specs/evidence/phase5-hoist-kernel-ab/ab-new.lean` with the "correct HERE and nowhere in the library" header note. No `.lean` timing probe is placed under `scripts/`. |
| A `lake env lean` probe outside the build graph rots unobserved | M | M | Follow the established precedent exactly: state in the probe's own header that it is **deliberately not wired** into `scripts/check-evidence-probes.sh`, with the reason (a wall-clock timing comparison is not a compile-check invariant), as `ab-new.lean` does. The script's own run is what exercises it, and Phase 7 makes a re-probe against the pinned commit the script's first action. |
| PR #8 lands mid-task and moves `lintro`/`linduction` cost, silently invalidating a checked-in figure | M | M | Pin the measurement commit in the baseline document and make the script's first action a re-probe against that pin, so a moved head reports a **stale baseline** rather than a wrong figure. This is the pattern that worked on the #8 re-review. |
| A checked-in heartbeat figure becomes a brittle test | M | M | Split by determinism: the **audit** module asserts axiom sets only (`#guard_msgs`, fully deterministic, runs in `lake test`); the **baseline** figures live in a regenerated markdown document with no `#guard_msgs` pin on any number. The DONE WHEN clause is satisfied exactly by this split. |
| Schema churn when `theorem_library_tableau_pipeline` writes the other five emitters | M | M | Fix the shared head now and reserve the five unimplemented stages' keys in `docs/reference/diagnostics.md`, with their field lists copied from `records/theorem-library.md` § Diagnostics, so that record extends rather than renegotiates. |
| The stamp-injection route (`lake env lean -D<option>` for commit/date/command) does not work as expected | M | M | Primary route: `register_option` string options read by the emitters. Fallback, if `-D` cannot carry a string option: the script writes the stamp lines into a scratch copy of the probe, keeping the tracked probe stamp-free (which the `--json` zeroed-stamp determinism contract wants anyway). Decide at implementation time by probing, not by assumption. |
| A repo-wide gate is red for pre-existing, unrelated reasons and is misread as this task's failure | M | M | Per `plan-authoring-gate-collisions.md` Condition 4, every gate criterion below is scoped to the files the phase touches, with a build-free baseline captured in Phase 1 for the delta form. A gate whose only failures are pre-existing and outside this task's file scope is a recorded PASS, enumerated with evidence. |
| `#`-command linter (`hashCommand`) fires on a use of `#reprove_record` / `#compare_record` | L | M | Only `BimodalTest`, `BimodalToolsTest` and `BimodalLibTest` carry `weak.linter.hashCommand = false`. The emitters are **declared** in `BimodalLib/Diagnostics/` (a declaration, not a use) and every **use** site is in a test library with the opt-out or in a `lake env lean` probe outside the build graph, where a warning is not fatal. |

## Decisions

- **The new derivation node-count measure lands in `BimodalLib/Diagnostics/`, not in
  `FormalSystem/ProofSystem/Derivation.lean`.** The research report deferred this choice to
  planning with both options satisfying every stated constraint; it is decided here on measured
  gate cost. Touching `Derivation.lean` would move `formalsystem-line-count` in
  `typst/generated/status.typ` (commit-blocking via `.githooks/pre-commit`), go stale the
  generated inventory row `` `Derivation.lean` | 418 `` in `FormalSystem/ProofSystem/README.md`,
  move the `Live lines of code` totals block in `README.md`, make
  `FormalSystem/ProofSystem/README.md`'s `Last verified` date newly stale, and oblige a full
  `lake build --wfail` of `FormalSystem`. Siting the measure in `BimodalLib/Diagnostics/` trips
  none of these: `status.typ` counts `FormalSystem/`, `Tests/` and `BimodalTools/`, and not
  `BimodalLib/`. The cost of the choice is conceptual — a measure of a core type filed outside
  the core — and it is the right side of the trade because the measure is a *diagnostic*, not
  part of the proof system's API, and its eventual consumer (the Extract stage of
  `theorem_library_tableau_pipeline`) works at the `BimodalLib` layer. `records/proof-mode.md`'s
  Lanes table already files M13's work in `BimodalLib/Diagnostics/`.
- **The two stages this record implements carry no formula-valued field, so no formula JSON codec
  is imported.** The research recommended reusing `Formula.toJson` from
  `BimodalTools/DataExport.lean` verbatim. Checked field by field: the shared head is six strings,
  the RE-PROVE payload is scalars plus two string arrays, and the COMPARE payload is scalars plus
  two fragment strings — not one formula AST among them. Reusing the codec would mean a new
  `BimodalLib` → `BimodalTools` import for nothing. The codec obligation is therefore **recorded
  in the reference page for the reserved stages** (enumerate and extract, which do carry formula
  fields) rather than exercised here, which keeps the two schemas from being invented beside each
  other without buying a cross-library edge now.
- **The records are emitted to stdout, one JSON object per invocation, and collected by the
  script.** This is the `trace_exporter` / `machine_appendix` idiom already in the tree: a command
  that writes a tracked file as an elaboration side effect is both untestable and
  non-composable. The collected file lands in `data/` with a `*_metadata.json` sidecar carrying
  the `fields` array, matching the existing dataset idiom the task asks the schema to be designed
  against. `scripts/validate_datasets.py` reads an explicit `DATASETS` list rather than globbing,
  so a new `data/` member adds no validator obligation — only a `data/README.md` inventory row.
- **The audit module's mirrors and the cost probe's mirrors are deliberately separate copies.**
  `#count_heartbeats` can only measure an elaboration it performs itself, so the probe cannot
  import already-elaborated mirrors from the test library. The duplication is forced by the
  instrument, not an oversight, and each copy is stated to be so in its own header.
- **Two timing fields are recorded, not one.** `heartbeats` is deterministic for a fixed
  toolchain and is the figure a gate can quote; `elab_ms` is wall clock from
  `set_option profiler true`, which is what the record's "elaboration time" literally asks for.
  Recording both costs nothing and keeps the reproducible figure separable from the
  human-legible one.
- **This plan has no theorem deliverable**, which is why `## Lean Challenge Statements` below
  carries the zero-goal marker. Everything it adds is a structure, two command elaborators, a
  computable `def`, a module of axiom assertions, a shell script and two reference pages. No
  proposition is proved, so there is no statement to pin.

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5, 6 | 4 |
| 5 | 7 | 5 |
| 6 | 8 | 2, 6, 7 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Capture the Build-Free Gate Baseline [NOT STARTED]

**Goal**: Record the pre-change outcome of the two build-free repo-wide gates, so every later
phase can state its criterion as a delta against a captured baseline rather than as an absolute
zero that a pre-existing finding would make unmeetable.

**Tasks**:
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` and record, verbatim, every
      non-PASS line it reports (no `lake` invocation, so this is fast).
- [ ] Run `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib` and record every
      error and every Check 4 finding it reports.
- [ ] Run `bash scripts/typst-sync-check.sh --counts-only` and record whether
      `typst/generated/status.typ` is already current at the task's base commit. If it is already
      drifted, say so in the baseline file: that drift is pre-existing and the first `.lean`
      commit of Phase 2 will be blocked by it until regenerated.
- [ ] Record the base commit sha (`git rev-parse HEAD`) in the same file; Phase 7's staleness
      re-probe and the baseline document's provenance line both cite it.
- [ ] Write all four to `specs/961_proof_mode_axiom_audit_and_cost_baseline/gate-baseline.md`.

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: The phase's only touched path is under `specs/**`, which no test suite
maps to, so the covering check is the `prose` row's diff read-through confirming the file records
each gate's actual output rather than a restatement of it.

**Files to modify**:
- `specs/961_proof_mode_axiom_audit_and_cost_baseline/gate-baseline.md` - new; the three gates' pre-change output and the base commit sha

**Verification**:
- The file exists and quotes each of the three commands with its own captured output.
- Each recorded figure is the command's real output, not a transcription from this plan or from
  the research report.

---

### Phase 2: Axiom Audit Test Module [NOT STARTED]

**Goal**: Satisfy the DONE WHEN clause that `lake test` covers — a test module on the pattern of
`Tests/BimodalTest/WalkthroughAxioms.lean` that asserts the axiom set of at least one derivation
per tactic family in TM and in TM⁺, and that pins the `[propext]`/classical boundary rather than
only its classical side.

**Tasks**:
- [ ] Create `Tests/BimodalTest/Automation/ProofModeAxioms.lean` with the repository copyright
      header and a module docstring copying `WalkthroughAxioms.lean` verbatim in form: the
      permitted set is `propext`, `Classical.choice`, `Quot.sound` or any subset;
      `Lean.ofReduceBool` (which a stray `native_decide` would introduce) is a hard stop. Add two
      sentences `WalkthroughAxioms.lean` has no need of: that TM⁺ rows measure at
      `[propext, Quot.sound]`, and that the `[propext]`-only rows are intentionally narrow, so a
      future reader does not "fix" one by widening it.
- [ ] Declare named `def` mirrors — never annotate or convert an existing `example` — one per
      row below, every name lowerCamelCase (`check-module-invariants.sh` C26 flags a non-trailing
      underscore in a live `def`/`abbrev` name; `theorem` is exempt, `def` is not. Confirm at
      implementation time whether C26's live scope reaches `Tests/`; write lowerCamelCase either
      way). Rows: `basicMP` (`lstart`/`lapply`/`lexact`), `basicSplit` (`lsplit`), `oneIntro`
      (one `lintro`), `basicCases` (`lcases` on a disjunction), `modalK` (`lmodal_intro`),
      `temporalK` (`ltemporal_intro`), `discreteStep` (`lstep` at `ZTime`), `plusModal` and
      `plusCases` (both over `PlusDerivationTree`), `rewriteNested4` (`lrewrite` through four
      nested scopes), `simpOneRule` (`lsimp only [...]`), `viewFold` and `viewFoldUnfold` (views
      tier), and `introLadder5` (five nested `lintro`, the task's stated long-script threshold).
- [ ] Give each mirror a `#guard_msgs`-pinned `#print axioms` row. **Paste the actual output**
      from a real run; do not transcribe the expected set from the research report's table or
      from this plan. A row whose measured set differs from the research table is a finding to
      record in the module docstring, not an error to paper over.
- [ ] Add `import BimodalTest.Automation.ProofModeAxioms` to `Tests/BimodalTest.lean`, inside the
      existing `BimodalTest.Automation.*` group, or `lake test` will never compile it.
- [ ] Add a row for the new module to `Tests/BimodalTest/Automation/README.md`'s contents table
      and refresh that file's own date line, keeping its existing `Last Updated` spelling rather
      than introducing a second convention in one file.
- [ ] Regenerate the tracked counts and stage them with this phase's commit:
      `lake build && bash scripts/typst-sync-check.sh --fix && git add typst/generated/status.typ`.
      This is not deferrable — `.githooks/pre-commit` refuses any commit staging a `.lean` path
      while `status.typ` is stale, and this phase moves `tests-file-count` and `tests-line-count`.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `lake test` builds the whole `BimodalTest` closure, which is the only
consumer of this module (nothing outside the test library imports it), so a single `lake test`
covers the edit's entire blast radius.

**Scope Hypothesis**: 14 audit rows over a corpus of 52 acceptance `example`s. The 52 is
re-derived at plan-authoring time (`grep -c '^example'` over the five
`Tests/BimodalTest/Automation/ProofMode*Test.lean` modules: 31 + 6 + 4 + 6 + 5). The 14-row set
is a hypothesis about sufficient coverage, and each row's expected axiom set is a figure carried
from the research report's Measurement 1 table (measured at commit `521385a9`): confirm every one
by running `lake test` and reading the `#guard_msgs` failure text, and add a row if a tactic
family turns out unrepresented.

**Files to modify**:
- `Tests/BimodalTest/Automation/ProofModeAxioms.lean` - new; the named mirrors and their pinned `#print axioms` rows
- `Tests/BimodalTest.lean` - one import line in the `Automation` group
- `Tests/BimodalTest/Automation/README.md` - contents-table row and date refresh
- `typst/generated/status.typ` - regenerated `tests-file-count` / `tests-line-count` (commit-blocking)

**Verification**:
- `lake test` passes, with the new module compiled (confirm by its absence from the build being
  impossible — the import line is in the root).
- `bash scripts/typst-sync-check.sh --counts-only` reports no drift.
- The five acceptance modules are byte-identical to their base-commit state:
  `git diff --stat <base> -- Tests/BimodalTest/Automation/ProofMode*Test.lean` is empty.
- No row anywhere reports `Lean.ofReduceBool`.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib` reports no finding naming a
  file this phase touched (Phase 1's baseline is the comparison; CI does not run readme-lint over
  `Tests/`, so this is a scoped check, not an absolute one).

---

### Phase 3: Diagnostics Record Schema and the Derivation-Size Measure [NOT STARTED]

**Goal**: One record schema for every stage of the library pipeline — keyed by statement
identifier and stage, carrying fragment, frame class, commit and the producing command — with the
RE-PROVE and COMPARE payloads implemented and the other five stages' keys reserved; plus the
computable node-count measure the RE-PROVE and COMPARE payloads need and which the tree does not
yet have.

**Tasks**:
- [ ] Create `BimodalLib/Diagnostics/Record.lean`: the `Stage` enum (`enumerate`, `decide`,
      `extract`, `certify`, `admit`, `reprove`, `compare`), the shared head (`statement`, `stage`,
      `fragment`, `frame_class`, `commit`, `command`), the `reprove` payload (`outcome`,
      `failure_class`, `tactic_count`, `distinct_tactics`, `escape_size`, `heartbeats`, `elab_ms`,
      `term_size`, `derivation_size`, `derivation_height`, `axioms`) and the `compare` payload
      (`script_length`, `hand_proof_length`, `length_ratio`, `reference_kind`,
      `built_derivation_size`, `reference_derivation_size`, `statement_fragment`,
      `proof_fragment`). Serialize snake_case at the top level, matching
      `data/proof_steps.jsonl`'s convention.
- [ ] Make `outcome` and `failure_class` closed enums over `records/theorem-library.md`'s own
      fixed lists — four outcomes (closed by the mode's rules alone, closed with leaf automation,
      closed with a term-mode escape, not closed) and six failure classes (missing rule, missing
      tactic for a rule that exists, automation too weak, script too awkward to write, too slow,
      defect in the mode) — so an invalid value cannot be recorded. `failure_class` is null on the
      first outcome only.
- [ ] Make `length_ratio` nullable and pair it with `reference_kind` (`hand` | `extracted`). The
      record is explicit that length is compared against hand proofs only; against a
      tableau-extracted proof a script is measured for coverage and built-derivation size, not
      brevity.
- [ ] Reserve the five unimplemented stages' payload keys in the same schema, so
      `theorem_library_tableau_pipeline` extends rather than renegotiates.
- [ ] Create `BimodalLib/Diagnostics/Size.lean`: a computable node-count measure for
      `DerivationTree` and `PlusDerivationTree`, sibling in spirit to the existing
      `DerivationTree.height` (`FormalSystem/ProofSystem/Derivation.lean`, found at line 223 at
      the research commit — locate it by name, not by line number). Keep it computable: both
      measures are read by `#eval` on closed instances. Docstring every declaration.
- [ ] Record, in `Size.lean`'s module docstring, why the measure is filed here and not beside
      `height` (the Decisions section above is the reasoning; the module states the conclusion),
      and that `derivation_size` / `derivation_height` are therefore nullable in a record whose
      mirror is schematic rather than closed.
- [ ] Create `BimodalLib/Diagnostics/README.md` with a `Last verified` date.
      `scripts/readme-lint.sh` Check 1 is GATED and requires a `README.md` in any directory
      holding `.lean` files.
- [ ] Add the two modules' import lines to `BimodalLib.lean`, keeping the file's sorted order.
- [ ] Add a `` `Diagnostics/` `` row to `BimodalLib/README.md`'s Modules table and refresh that
      file's `Last verified` date: adding a subdirectory moves `git log -1 -- BimodalLib`, which
      makes the existing date newly stale under `readme-lint.sh` Check 4
      (`ENFORCE_README_DATES=1`, gated).
- [ ] Give every new `.lean` file the repository copyright header; CI runs
      `check-copyright-headers.sh --strict FormalSystem BimodalTools BimodalLib`, so a
      `BimodalLib` file without one fails.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `lake build BimodalLib --wfail` compiles the only closure that reaches
these modules — `BimodalLib` is outside `defaultTargets` and `FormalSystem` never imports it — so
one invocation covers the whole blast radius.

**Files to modify**:
- `BimodalLib/Diagnostics/Record.lean` - new; the stage enum, shared head, two implemented payloads, five reserved stages
- `BimodalLib/Diagnostics/Size.lean` - new; the computable derivation node-count measure
- `BimodalLib/Diagnostics/README.md` - new; directory README with a `Last verified` date (readme-lint Check 1 is gated)
- `BimodalLib.lean` - two import lines, in sorted order
- `BimodalLib/README.md` - Modules-table row for `Diagnostics/` and a `Last verified` refresh

**Verification**:
- `lake build BimodalLib --wfail` exits 0 (warnings are fatal here, so a lint warning is a
  failure, not a note).
- `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib` reports no Check 1 or Check 4
  finding naming a file or directory this phase touched, compared against Phase 1's baseline.
- `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools BimodalLib` exits 0.
- `bash scripts/library-index.sh --no-build --check` exits 0 — no registry row was added, so the
  generated library index must be unchanged; a diff there means something was registered by
  accident.
- `#eval` on a closed derivation returns a node count greater than or equal to its height for the
  same instance (a sanity relation, not a theorem).

---

### Phase 4: The Two Emitter Commands and Their Negative Tests [NOT STARTED]

**Goal**: The commands that emit the RE-PROVE and COMPARE records for a proof-mode script, each
`throwError` path pinned by a `#guard_msgs` negative test, with the cost script of Phase 7 as
their first consumer.

**Tasks**:
- [ ] Create `BimodalLib/Diagnostics/Emit.lean` with two command elaborators, `#reprove_record`
      and `#compare_record`, each printing exactly one JSON object per invocation to stdout (the
      `trace_exporter` / `machine_appendix` idiom; no command writes a tracked file as an
      elaboration side effect).
- [ ] Read `term_size` off the named declaration via `ConstantInfo.value?` plus
      `Lean.Expr.sizeWithoutSharing`, `derivation_size` / `derivation_height` by evaluating the
      Phase 3 measures on a closed instance (null when the mirror is schematic), `axioms` from the
      same collector `#print axioms` uses, and `heartbeats` on `#count_heartbeats`' own mechanism
      (`Mathlib/Util/CountHeartbeats.lean`, present in the pinned tree).
- [ ] Derive `fragment` and `frame_class` from the registry row rather than retyping them, the
      discipline `BimodalLib/Registry.lean`'s `profile_eq` already enforces by `rfl`. For a
      statement with no registered row — which every mirror in this task is — fall back to the
      `data/`-style identifier convention and say so in the record, never silently emit an empty
      string.
- [ ] Carry `commit`, date and `command` as registered string options
      (`register_option`), set from outside via `lake env lean -D<option>=<value>` so the tracked
      probe stays stamp-free. If a string option cannot be carried by `-D`, fall back to the
      script writing stamp lines into a scratch copy of the probe, and record which route was
      taken in `Emit.lean`'s module docstring.
- [ ] Enumerate every `throwError` path added by this phase and write one `#guard_msgs` negative
      test per path asserting its exact message, in `Tests/BimodalLibTest/DiagnosticsTest.lean`.
      At minimum: an unknown declaration name, a declaration with no value, an unparseable or
      out-of-enum stage, and an out-of-enum failure class. Add one positive smoke record so a
      green run is distinguishable from a run that emitted nothing.
- [ ] Add `import BimodalLibTest.DiagnosticsTest` to `Tests/BimodalLibTest.lean`, add a row to
      `Tests/BimodalLibTest/README.md` and refresh that file's `Last verified` date.
- [ ] Add an `Emit.lean` row to `BimodalLib/Diagnostics/README.md`.
- [ ] Add the `Emit.lean` import to `BimodalLib.lean`, in sorted order.
- [ ] Regenerate and stage `typst/generated/status.typ` with this phase's commit; it adds a
      `Tests/` module and therefore moves `tests-file-count` and `tests-line-count`, which
      `.githooks/pre-commit` refuses to let drift.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: `lake build BimodalLib BimodalLibTest --wfail` is the only closure that
reaches these modules, so one invocation covers both the emitters and every negative test that
pins them.

**Scope Hypothesis**: four `throwError` paths, hence four negative tests. This is an estimate made
before the elaborators are written: enumerate the real paths by grepping the finished
`Emit.lean` for `throwError`, and write one `#guard_msgs` test per path found. The task's
constraint is one negative test per new `throwError` path, not four — if the count differs, the
tests follow the code.

**Files to modify**:
- `BimodalLib/Diagnostics/Emit.lean` - new; the two command elaborators and the stamp options
- `BimodalLib.lean` - one import line, in sorted order
- `BimodalLib/Diagnostics/README.md` - row for `Emit.lean`
- `Tests/BimodalLibTest/DiagnosticsTest.lean` - new; the `#guard_msgs` negative tests and one positive smoke record
- `Tests/BimodalLibTest.lean` - one import line
- `Tests/BimodalLibTest/README.md` - contents row and `Last verified` refresh
- `typst/generated/status.typ` - regenerated `tests-*` counts (commit-blocking)

**Verification**:
- `lake build BimodalLib BimodalLibTest --wfail` exits 0.
- Every `throwError` site in `Emit.lean` has a matching `#guard_msgs` test:
  `grep -c throwError BimodalLib/Diagnostics/Emit.lean` is accounted for, site by site, in
  `Tests/BimodalLibTest/DiagnosticsTest.lean`. Scope the count to this one file rather than
  asserting a repo-wide figure.
- One invocation of each emitter over a named mirror produces exactly one line of valid JSON:
  pipe it through `jq -e .` and check the exit status.
- `bash scripts/typst-sync-check.sh --counts-only` reports no drift.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib` shows no new finding naming a
  touched path, against Phase 1's baseline.

---

### Phase 5: The Cost-Baseline Probe [NOT STARTED]

**Goal**: A single `lake env lean` probe that reproduces every figure the baseline document will
quote: each acceptance example, the `lintro` ladder, the nested logical rewrite, the simplifier
rows and the two views-tier rows.

**Tasks**:
- [ ] Create `specs/evidence/proof-mode-cost-baseline/cost-probe.lean`, modelled on
      `specs/evidence/phase5-hoist-kernel-ab/ab-new.lean`. Its header states, in that file's own
      terms: that it is an evidence probe and not part of the library; that it is **deliberately
      not wired** into `scripts/check-evidence-probes.sh`, because a wall-clock timing comparison
      is not a compile-check invariant; that `set_option maxHeartbeats 0` is correct HERE and
      nowhere in the library, since a heartbeat cap would convert a slow arm into a failure and
      destroy the measurement; and that `set_option profiler true` is what makes per-declaration
      sites separable inside one file, since Lean reports `tactic execution of ... took` and
      `type checking took` per declaration in source order.
- [ ] Mirror all 52 acceptance `example`s as named `def`s, each one's script body copied
      verbatim from its fixture so the measured figure is the acceptance example's own cost, with
      a comment naming the source module and the fixture's position in it. Do not edit the
      fixtures.
- [ ] Add the ladders and the remaining rows: `lintro` at depth 1 through 16 (the closed form
      `5n² + 17n + 41` is what these confirm, and the task's stated minimum of five nested steps
      is a member of the range); `lrewrite` through 0 to 4 nested scopes (the `785 + 346·d` row
      set, in scope because PR #7 has merged); `lsimp only [...]` at one and at two rules; and the
      two views-tier rows (`lfold`, then `lfold; lunfold`).
- [ ] State in the header that these mirrors are a deliberate second copy of the Phase 2 audit
      module's mirrors, because `#count_heartbeats` can only measure an elaboration it performs
      itself and therefore cannot read an already-elaborated import.
- [ ] Create `specs/evidence/proof-mode-cost-baseline/README.md` recording the measurement
      conditions, copying `specs/evidence/phase5-hoist-kernel-ab/README.md`'s discipline: commit
      and toolchain pinned; zero rebuild (library built to completion before any timing run, every
      run one `lake env lean` elaboration against one unchanged build); serialized under an
      `flock` on `.lake/build-guard.lock` held to exit; arms interleaved so machine load moves
      them together; per-site attribution via `profiler true`.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Tier Justification**: Every touched path is under `specs/**`, which no suite maps to and which
no build target reaches, so the covering check is the probe's own compile —
`lake env lean specs/evidence/proof-mode-cost-baseline/cost-probe.lean` — plus the `prose` row's
diff read-through over the README.

**Scope Hypothesis**: 52 acceptance-example mirrors. Re-derived at plan-authoring time via
`grep -c '^example'` over the five `Tests/BimodalTest/Automation/ProofMode*Test.lean` modules
(31 + 6 + 4 + 6 + 5 = 52); re-run that count at implementation time, since PRs #8, #9 and #10 are
open against exactly this area and a merge between plan and implementation moves it. If the count
has moved, mirror whatever is there and say so in the probe header.

**Files to modify**:
- `specs/evidence/proof-mode-cost-baseline/cost-probe.lean` - new; the 52 mirrors, the two ladders, the simplifier and views rows
- `specs/evidence/proof-mode-cost-baseline/README.md` - new; measurement conditions on the established precedent

**Verification**:
- `lake env lean specs/evidence/proof-mode-cost-baseline/cost-probe.lean` elaborates with no
  error, and the probe contains no `sorry`.
- The probe emits one measurement per mirror, and the mirror count equals the re-derived
  acceptance-example count.
- `git diff --stat <base> -- Tests/BimodalTest/Automation/ProofMode*Test.lean` is still empty: no
  fixture was touched to make a mirror easier to write.
- The header states the not-wired decision and its reason explicitly, so a reader does not have to
  infer it from the absence of an entry in `scripts/check-evidence-probes.sh`.

---

### Phase 6: Reference Page for the Diagnostics Schema [NOT STARTED]

**Goal**: `docs/reference/diagnostics.md` documenting the schema and every field, since a stage is
not complete until its fields are documented there.

**Tasks**:
- [ ] Create `docs/reference/diagnostics.md`: the keying rule (one record per statement and
      stage), the shared head as a `{field, type, description}` table mirroring the
      `data/*_metadata.json` sidecar shape, and one such table per stage.
- [ ] Document the two implemented stages field for field, including both timing fields and why
      there are two (`heartbeats` deterministic and gateable; `elab_ms` wall clock, which is what
      "elaboration time" literally asks for), and the nullability rules (`failure_class` null on
      the first outcome only; `length_ratio` null when `reference_kind` is `extracted`;
      `derivation_size` / `derivation_height` null for a schematic mirror).
- [ ] Reserve the five unimplemented stages with their field lists copied from
      `records/theorem-library.md` § Diagnostics, each marked as written by
      `theorem_library_tableau_pipeline`, so that record has a schema to build against rather than
      a gap to guess at.
- [ ] Record the formula-codec obligation for the reserved stages that carry formula-valued
      fields: they reuse `Formula.toJson`'s `{"tag": ..., ...}` codec from
      `BimodalTools/DataExport.lean` rather than inventing a second one. State that neither
      implemented stage carries such a field, which is why no codec import exists yet.
- [ ] Document both emitter commands: their syntax, what each reads, and every error message a
      `#guard_msgs` test pins, so the message text has one documented home.
- [ ] Add the page to `docs/reference/README.md`'s listing and to `docs/README.md`'s
      `### reference/` list.
- [ ] Cite no task number anywhere on the page (`check-module-invariants.sh` C9D asserts zero
      task-number citations under `docs/`); cite durable anchors — a filename, a section heading,
      a declaration name — instead.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: prose

**Tier Justification**: The edit is confined to markdown with no compile or elaboration surface,
and the covering check is `bash scripts/check-module-invariants.sh --no-build`, whose C9D, C12 and
C13 are precisely the checks that read a new page under `docs/` (task-number citations,
slash-shaped source paths, relative markdown links).

**Files to modify**:
- `docs/reference/diagnostics.md` - new; the schema and every field, per stage
- `docs/reference/README.md` - listing row for the new page
- `docs/README.md` - `### reference/` list entry

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` reports no C9D, C12, C13 or C18 finding
  naming a file this phase touched, compared against Phase 1's baseline.
- Every field in `BimodalLib/Diagnostics/Record.lean` appears in the page, and every field on the
  page appears in `Record.lean`: check both directions, not only one.
- Every error message pinned by a `#guard_msgs` test in
  `Tests/BimodalLibTest/DiagnosticsTest.lean` appears verbatim on the page.
- Each of the five reserved stages lists the fields `records/theorem-library.md` § Diagnostics
  names for it.

---

### Phase 7: The Measuring Script and the Emitted Records [NOT STARTED]

**Goal**: The checked-in script that reproduces every baseline figure by one command, with the
emitted records collected into the `data/` idiom and a determinism contract that makes a moved
head report a stale baseline rather than a wrong figure.

**Tasks**:
- [ ] Create `scripts/proof-mode-cost-baseline.sh` on the `scripts/typst-machine-appendix.sh`
      pattern: `--stamp-commit` / `--stamp-date` injection, a build-free `--json` mode that zeroes
      the stamp fields so a sync check can compare, the shared `.lake/build-guard.lock` taken once
      and held to exit, and an explicit determinism contract (two runs from the same commit on the
      same UTC day produce byte-identical output). Never invoke bare `lake`.
- [ ] Make the script's first action a staleness re-probe against the commit pinned in the
      baseline document: on a moved head, report a stale baseline and exit non-zero rather than
      emitting a figure measured against different code. Phase 1's recorded base sha is the pin.
- [ ] Build the library to completion before any timing run, then drive the Phase 5 probe through
      `lake env lean`, interleaving the arms so machine load moves them together.
- [ ] Collect the emitted RE-PROVE and COMPARE records into
      `data/proof-mode-diagnostics.jsonl`, one JSON object per line, and emit
      `data/proof-mode-diagnostics_metadata.json` from the same source as the reference page's
      field tables so the doc and the sidecar cannot drift. The sidecar carries the existing
      `dataset_name` / `version` / `schema_version` / `description` / `generation_date` /
      `total_records` / `fields` shape.
- [ ] Add an inventory row for the new file to `data/README.md`.
      `scripts/validate_datasets.py` reads an explicit `DATASETS` list rather than globbing, so no
      validator entry is owed — confirm that at implementation time by reading the list rather
      than trusting this sentence.
- [ ] Record in the script's header which of the two stamp-injection routes (Phase 4's `-D`
      option, or a scratch copy of the probe) is in use.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Tier Justification**: The script's own two runs are the covering check —
`bash scripts/proof-mode-cost-baseline.sh --json` twice, compared byte for byte — since nothing
imports it and no suite maps to `scripts/*.sh` in this repository.

**Files to modify**:
- `scripts/proof-mode-cost-baseline.sh` - new; the measuring script, with stamping, `--json`, the shared lock and the determinism contract
- `data/proof-mode-diagnostics.jsonl` - new; the collected RE-PROVE and COMPARE records
- `data/proof-mode-diagnostics_metadata.json` - new; the `fields` sidecar, emitted from the same source as the reference page
- `data/README.md` - inventory row for the new file

**Verification**:
- `bash scripts/proof-mode-cost-baseline.sh` exits 0 and writes both the JSONL and its sidecar.
- Two consecutive `--json` runs from the same commit on the same UTC day are byte-identical
  (`cmp`), which is the determinism contract rather than a restatement of it.
- Every line of `data/proof-mode-diagnostics.jsonl` is valid JSON (`jq -e . </dev/null` style
  per-line check, exit status checked) and carries all six shared-head fields.
- The sidecar's `fields` array matches `docs/reference/diagnostics.md`'s field tables for the two
  implemented stages, field for field.
- The staleness re-probe fires: simulate a moved head (pass a wrong pin) and confirm the script
  reports a stale baseline and exits non-zero rather than printing a figure.
- No `.lean` file is added under `scripts/`, so C29 and C30 see nothing new there.

---

### Phase 8: The Baseline Document and the Final Gate [NOT STARTED]

**Goal**: `docs/development/proof-mode-cost-baseline.md` carrying the figures and the command that
reproduces them, which closes the task's DONE WHEN, followed by this repository's own complete
gate set.

**Tasks**:
- [ ] Create `docs/development/proof-mode-cost-baseline.md` from the Phase 7 script's output —
      never transcribed from the research report. Record the provenance line first (measurement
      commit, toolchain pin, Mathlib tag, date) and the reproduction command second, both before
      any figure.
- [ ] Record the `lintro` nesting law and not only the five-step point: the measured closed form
      for term size over the full depth range, the linear heartbeat trend beside it, and the plain
      statement that the quadratic is kernel-side while the elaborator pays only linearly — a long
      script is cheap to write and increasingly expensive to verify, which is the opposite of the
      usual tactic-cost shape and is the figure the adequacy gate will quote.
- [ ] Record the nested logical rewrite row set and both halves of the finding: a single
      congruence certificate is large in absolute terms, several times a basic script before any
      nesting, but composition is linear rather than compounding, so the certificates do not blow
      up. This is the baseline the merged contribution promised and recorded none of.
- [ ] Record the per-tier table (views and derivation only) and the acceptance-example figures,
      each with its axiom set beside its cost so the two deliverables read as one measurement.
- [ ] Add the page to `docs/development/README.md`'s listing and to `docs/README.md`'s
      `### development/` list. Cite no task number (C9D).
- [ ] State the one measurement the document does not claim: the semantic tier, which is not in
      merged state.
- [ ] Run this repository's complete gate set and record each outcome (see Verification below).

**Timing**: 1.5 hours

**Depends on**: 2, 6, 7

**Verification Tier**: full

**Files to modify**:
- `docs/development/proof-mode-cost-baseline.md` - new; the figures, the provenance line and the reproduction command
- `docs/development/README.md` - listing row for the new page
- `docs/README.md` - `### development/` list entry

**Verification**:
- **Scoped touched-path check, this dispatch's own obligation**: `lake build --wfail`,
  `lake test`, `lake build BimodalLib BimodalLibTest --wfail`,
  `bash scripts/typst-sync-check.sh --counts-only`,
  `bash scripts/check-module-invariants.sh --no-build`,
  `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib`,
  `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools BimodalLib`,
  `bash scripts/library-index.sh --no-build --check`, and
  `bash scripts/proof-mode-cost-baseline.sh` — each reporting no failure that names a file this
  task touched. A failure whose only findings are pre-existing and outside this task's file scope
  is a recorded PASS for this phase, enumerated against Phase 1's captured baseline with the
  evidence that each touched file passes its own check individually; it is not grounds to edit an
  out-of-scope file to force an absolute count to zero.
- **Repository-wide aggregate**: `bash scripts/verify-all.sh`, which mirrors CI's ten-check gate,
  stated as a delta against Phase 1's baseline rather than as an absolute exit 0.
- **Deferral statement**: the agent-system deploy gate set
  (`bash .claude/scripts/verify-deploy.sh`) is deferred to the orchestration close rather than
  invoked independently here. This task touches no path under `.claude/**` and no source-store
  path, so that set has nothing of this task's to observe; it is owed once per `/orchestrate`
  invocation and discharged at the orchestration close, not forgiven.
- The reproduction command printed in the document, run verbatim from a clean checkout of the
  measurement commit, reproduces the document's own figures.
- The 52 acceptance `example`s are still byte-identical to their base-commit state.

---

## Lean Challenge Statements

This plan has no theorem deliverable: it adds a record structure, two command elaborators, one
computable `def`, a module of axiom assertions, a shell script, a probe and three reference pages.
No proposition is proved, so there is no statement to pin. The rationale is recorded under
`## Decisions`.

<!-- lean-challenge-statements:none -->

## Testing & Validation

- [ ] `lake test` passes with `Tests/BimodalTest/Automation/ProofModeAxioms.lean` compiled, and no
      audit row reports `Lean.ofReduceBool`.
- [ ] `lake build BimodalLib BimodalLibTest --wfail` exits 0.
- [ ] One `#guard_msgs` negative test exists per `throwError` path in
      `BimodalLib/Diagnostics/Emit.lean`, accounted for site by site.
- [ ] `lake env lean specs/evidence/proof-mode-cost-baseline/cost-probe.lean` elaborates clean and
      the probe is `sorry`-free.
- [ ] `bash scripts/proof-mode-cost-baseline.sh` reproduces the document's figures; two `--json`
      runs from one commit on one UTC day are byte-identical.
- [ ] `bash scripts/typst-sync-check.sh --counts-only` reports no drift after every phase that
      staged a `.lean` path.
- [ ] The five acceptance modules are byte-identical to their base-commit state.
- [ ] Every field is documented in both directions between `Record.lean` and
      `docs/reference/diagnostics.md`.
- [ ] `bash scripts/verify-all.sh` reports no failure naming a touched file, against Phase 1's
      baseline.

## Artifacts & Outputs

- `Tests/BimodalTest/Automation/ProofModeAxioms.lean` — the axiom audit, reached by `lake test`
- `BimodalLib/Diagnostics/Record.lean` — the one record schema for all seven stages
- `BimodalLib/Diagnostics/Size.lean` — the computable derivation node-count measure
- `BimodalLib/Diagnostics/Emit.lean` — the RE-PROVE and COMPARE emitter commands
- `BimodalLib/Diagnostics/README.md` — directory README (readme-lint Check 1 is gated)
- `Tests/BimodalLibTest/DiagnosticsTest.lean` — the `#guard_msgs` negative tests
- `specs/evidence/proof-mode-cost-baseline/cost-probe.lean` and its `README.md` — the measurement
  probe and its conditions
- `scripts/proof-mode-cost-baseline.sh` — the checked-in measuring script
- `data/proof-mode-diagnostics.jsonl` and `data/proof-mode-diagnostics_metadata.json` — the
  emitted records and their `fields` sidecar
- `docs/reference/diagnostics.md` — the schema and every field
- `docs/development/proof-mode-cost-baseline.md` — the recorded baseline and its reproduction
  command
- Updated: `Tests/BimodalTest.lean`, `Tests/BimodalLibTest.lean`, `BimodalLib.lean`,
  `BimodalLib/README.md`, `Tests/BimodalTest/Automation/README.md`,
  `Tests/BimodalLibTest/README.md`, `data/README.md`, `docs/README.md`,
  `docs/reference/README.md`, `docs/development/README.md`, `typst/generated/status.typ`
- `specs/961_proof_mode_axiom_audit_and_cost_baseline/gate-baseline.md` — the captured gate
  baseline

## Rollback/Contingency

Every phase is additive: the task creates new files and adds import lines, README rows and
regenerated counts. Nothing existing is rewritten, and the 52 acceptance `example`s are
explicitly out of scope, so there is no behavioural surface to revert.

- **Per-phase rollback**: revert that phase's commit. The only cross-phase coupling is
  `typst/generated/status.typ`, which is regenerated rather than hand-edited, so reverting a
  `.lean` addition and re-running
  `lake build && bash scripts/typst-sync-check.sh --fix` restores it.
- **If a genuine rollback of uncommitted work is required** — a working tree that must be
  discarded, not fixed forward — take a snapshot first per `context/contracts/recovery.md`'s
  rollback rung, which names the invocation shape including its out-of-scope override flag. Do not
  emit a bare snapshot call as a routine start-of-phase precaution; an ordinary defensive
  checkpoint before risky work uses the non-reverting mode instead.
- **If the emitters cannot be made to work within their phase budget**: Phases 2, 5, 6 and 8 still
  stand on their own — the audit module, the probe and the baseline document satisfy the task's
  original DONE WHEN without the emitters. The honest outcome in that case is
  `[COMPLETED WITH EXCLUSIONS]` on Phase 4 with a `#### Reasoned Exclusions` record, plus a
  follow-up for the revision clause, never a silently reduced schema.
- **If a measured figure disagrees with the research report's table**: the measurement wins. The
  report's figures were taken at commit `521385a9`; PRs #8, #9 and #10 are open against this exact
  area. Record the new figure, note the divergence and its likely cause, and do not reshape the
  measurement to match a carried number.
