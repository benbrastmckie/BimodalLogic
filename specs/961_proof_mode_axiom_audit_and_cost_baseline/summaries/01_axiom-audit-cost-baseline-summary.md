# Implementation Summary: Task #961

- **Task**: 961 - Proof mode: axiom audit and cost baseline (M13, diagnostics standard)
- **Status**: [COMPLETED]
- **Started**: 2026-11-23T19:30:00Z
- **Completed**: 2026-11-23T22:10:00Z
- **Effort**: ~2.7 hours
- **Dependencies**: None hard (the file-split dependency was test-directory layout only)
- **Artifacts**: plans/01_axiom-audit-cost-baseline.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All eight phases completed. The task's own DONE WHEN is met — the axiom-audit module passes in
`lake test`, and `docs/development/proof-mode-cost-baseline.md` exists with its reproduction
command and the measuring script checked in — and so are the three revision clauses: one record
schema covering all seven pipeline stages, the two commands that emit its RE-PROVE and COMPARE
records with every `throwError` path pinned by a `#guard_msgs` test, and
`docs/reference/diagnostics.md` documenting every field of every stage.

Two of the research report's measured laws reproduced exactly on a fresh instrument: `lintro`
nesting is `5n² + 17n + 41` in term size with residual zero for every `n` from 2 to 16, and a
nested logical rewrite costs exactly +346 term nodes per scope level over `d = 0..4`. Both
reproductions corroborate the report rather than restate it — the figures were re-measured through
the emitters this task built, not transcribed.

## What Changed

- `Tests/BimodalTest/Automation/ProofModeAxioms.lean` — Created. 14 named `def` mirrors, one
  representative script per tactic family in TM and in TM⁺, each with a `#guard_msgs`-pinned
  `#print axioms` row. Pins the `[propext]`/classical **boundary**, not only its classical side:
  `lstart`/`lapply`/`lexact`/`lsplit` and the whole congruence kit stay at `[propext]`, while
  `lintro`, `lcases` on a disjunction and every scope introduction reach
  `[propext, Classical.choice, Quot.sound]`. TM⁺ measures lighter, at `[propext, Quot.sound]`. No
  row reports `Lean.ofReduceBool`. All 14 measured sets match the research report's Measurement 1
  table exactly.
- `BimodalLib/Diagnostics/Record.lean` — Created. The `Stage` enum over all seven pipeline stages,
  the six-field shared head, the closed `Outcome` (4), `FailureClass` (6) and `ReferenceKind` (2)
  enumerations, the `ReproveRecord` (11 fields) and `CompareRecord` (8 fields) payloads with
  snake_case JSON serialization, and `Stage.reservedKeys` fixing the five unimplemented stages'
  payload names so the tableau pipeline extends rather than renegotiates.
- `BimodalLib/Diagnostics/Size.lean` — Created. `derivationSize` and `plusDerivationSize`, the
  computable node count of a derivation beside the existing `height`, with `height ≤ size` proved
  for both. Measured on a closed script: height 1, size 3 — the measure genuinely separates a
  spindly tree from a wide one, which `height` alone cannot.
- `BimodalLib/Diagnostics/Emit.lean` — Created. `#reprove_record` (a measuring wrapper) and
  `#compare_record` (a reader), four `diagnostics.*` stamp options, and the environment readers
  that derive `term_size`, `axioms`, `frame_class`, `fragment` and both derivation measures. Eight
  reachable `throwError` paths, each pinned.
- `Tests/BimodalLibTest/DiagnosticsTest.lean` — Created. Three positive smoke records with their
  whole JSON object pinned, plus one `#guard_msgs` row per `throwError` path (8 of 8), plus four
  schema-invariant `#eval` assertions over the stage enumeration.
- `BimodalLib/Diagnostics/README.md` — Created. Directory README with a `Last verified` date
  (`readme-lint.sh` Check 1 is gated).
- `specs/evidence/proof-mode-cost-baseline/cost-probe.lean` — Created. 75 `#reprove_record` /
  `#compare_record` invocations: 48 acceptance-script mirrors, the `lintro` ladder at depth 1–16,
  the nested rewrite at 0–4 scopes, two simplifier rows, two views rows, and one script-against-hand
  COMPARE pair. Elaborates clean, `sorry`-free.
- `specs/evidence/proof-mode-cost-baseline/README.md` — Created. Measurement conditions on the
  `phase5-hoist-kernel-ab` precedent, including the explicit not-wired-into-`check-evidence-probes.sh`
  decision and its reason.
- `scripts/proof-mode-cost-baseline.sh` — Created. The one-command reproduction route: staleness
  re-probe first, guarded build, probe under the shared lock, record collection, bidirectional
  field-set check against the reference page, dataset plus sidecar.
- `docs/reference/diagnostics.md` — Created. The schema and every field of every stage, the three
  nullability rules, both timing fields, both emitter commands and all eight error messages.
- `docs/development/proof-mode-cost-baseline.md` — Created. The recorded baseline: provenance,
  reproduction command, the two growth laws, per-tier figures, the acceptance corpus and the one
  COMPARE row, plus what the document explicitly does not claim.
- `BimodalLib.lean`, `Tests/BimodalTest.lean`, `Tests/BimodalLibTest.lean` — Import lines added.
- `BimodalLib/README.md`, `Tests/BimodalTest/Automation/README.md`,
  `Tests/BimodalLibTest/README.md`, `docs/README.md`, `docs/reference/README.md`,
  `docs/development/README.md` — Inventory rows and date refreshes.
- `typst/generated/status.typ` — Regenerated `tests-file-count` / `tests-line-count` (blocking via
  `.githooks/pre-commit`).
- `specs/961_proof_mode_axiom_audit_and_cost_baseline/gate-baseline.md` — Created. The Phase 1
  captured gate baseline every later phase's criterion is a delta against.
- `data/proof-mode-diagnostics.jsonl`, `data/proof-mode-diagnostics_metadata.json`,
  `data/README.md` — Written on disk, **not committed**: this repository ignores `/data` outright
  and carries zero tracked files under it. See Follow-ups.

## Decisions

- **The node-count measure is filed in `BimodalLib/Diagnostics/`, not beside `height` in
  `FormalSystem/ProofSystem/Derivation.lean`.** Executed the plan's recorded decision: siting it in
  the core would move `formalsystem-line-count` in `typst/generated/status.typ`, stale a generated
  inventory row and a `Last verified` date, and oblige a full `--wfail` rebuild — for a measure
  that proves nothing and whose only consumer is at the `BimodalLib` layer.
- **`#reprove_record` is a measuring wrapper rather than a reader.** Heartbeats and wall-clock time
  exist only *during* the elaboration that produces a declaration. A reader taking them as
  arguments would have made every figure hand-fed; the wrapper measures them itself, which is what
  made the two growth laws reproducible at all.
- **A fourth stamp option, `diagnostics.zeroTimings`, was added beside the plan's three.** Those two
  timing fields are the only parts of a record that are not a function of the commit and the
  toolchain, hence the only obstacle to a byte-stable record. Without the option no positive smoke
  record could be pinned by `#guard_msgs` and the script's `--json` determinism contract could not
  hold.
- **The staleness pin is the head of the measured surface, not of the repository.** Pinning
  repository HEAD would report a stale baseline after every later commit — including the one
  recording the figures — so the gate would fire always and mean nothing. The surface is the mode's
  elaborators, its rules, the diagnostics library and the probe; it excludes the script, the
  document and the dataset, because a change to how a figure is *reported* does not invalidate it.
- **The sidecar's `fields` array is parsed out of the reference page, and the agreement is
  enforced.** The script fails (exit 2) when the page's key set and the emitted records' key set
  differ in either direction. The plan asked that the doc and the sidecar "cannot drift"; a parse
  plus a bidirectional check is that, where a convention would not have been.
- **No formula JSON codec is imported.** Checked field by field: neither implemented stage carries
  a formula-valued field. The obligation is recorded on the reference page for the two reserved
  stages that do carry one, rather than exercised here for a cross-library edge that buys nothing.

## Plan Deviations

- **Phase 2** altered: the `#guard_msgs` expectations were captured from a scratch `lake env lean`
  probe run under the real target namespace before the module was authored, rather than iterated
  against build failures. The module compiled green on its first build.
- **Phase 3** altered: the two cross-references in `BimodalLib/Diagnostics/README.md` to files later
  phases create are backticked paths, not markdown links — `readme-lint.sh` Check 3 resolves link
  targets against the filesystem at run time. Each was promoted to a link in the phase that created
  its target.
- **Phase 4** altered: a fourth registered option (`diagnostics.zeroTimings`) was added beside the
  plan's three stamps, for the reason under Decisions. The plan's primary `-D` stamp route works, so
  the scratch-copy fallback is neither taken nor implemented.
- **Phase 4** scope hypothesis resolved: the plan estimated four `throwError` paths. The real count
  is **eight**, each pinned one-for-one. The emitters were also refactored so that no `throwError`
  is unreachable — an unreachable path is one a `#guard_msgs` cannot pin.
- **Phase 5** altered: **48 mirrors, not 52.** The plan's 52 is `grep -c '^example'`, which counts
  the four `#guard_msgs`-guarded *negative* fixtures in `ProofModeBooleanTest.lean`, whose `example`
  also begins at column 0. Measured positive/guarded per module: 31/0, 2/4, 4/0, 5/0, 6/0. Mirroring
  a script asserted to fail would have put four deliberately-failing declarations into a probe
  required to elaborate clean.
- **Phase 6** altered: the forward reference to the Phase 8 document is a backticked path, promoted
  to a link in Phase 8 (same C13 reason as Phase 3).
- **Phase 7** altered: the staleness pin is the measured-surface head rather than repository HEAD,
  for the reason under Decisions.
- **Phase 7** blocked by repository configuration, not by the work: `data/README.md`, the dataset and
  its sidecar are all gitignored (`.gitignore` ignores `/data`; `git ls-files data/` returns zero).
  All three were written correctly on disk and dropped from the commit by `git-commit-scoped.sh`.

## Verification

- Build: **Success**. Full `lake build --wfail` exit 0 (3017 jobs);
  `lake build BimodalLib BimodalLibTest --wfail` exit 0 (3053 jobs). `.olean` newer than source
  confirmed per module for every file this task touched.
- Tests: **Passed**. `lake test` exit 0 (3095 jobs), with
  `Tests/BimodalTest/Automation/ProofModeAxioms.lean` in the root import list. All 16 `#guard_msgs`
  rows in `Tests/BimodalLibTest/DiagnosticsTest.lean` pass.
- Sorry count: **0** (`lean-sorry-census.sh` over all resolved source roots).
- Vacuous count: **0 in this task's files**. The repo-wide grep reports 2, both in
  `FormalSystem/` (`PointTransport.lean:163` `AnyPoint`, `TemporalStructures.lean:495`
  `int_domain_universal`), last touched by PR #11 and pre-existing; this task changed no
  `FormalSystem/` file at all.
- Axiom count: **14, unchanged**. Identical to the count over the same roots at the base commit
  `889bf7c0`, verified by `git archive` of that commit.
- No row anywhere reports `Lean.ofReduceBool`.
- The 52 acceptance `example`s are byte-identical to their base-commit state:
  `git diff --stat 889bf7c0 -- Tests/BimodalTest/Automation/ProofMode*Test.lean` is empty.
- Field-set agreement between `BimodalLib/Diagnostics/Record.lean` and
  `docs/reference/diagnostics.md` holds in **both directions for all seven stages** (6 head +
  11 reprove + 8 compare + the five reserved lists), checked mechanically.
- `scripts/proof-mode-cost-baseline.sh` exits 0, writes 75 records and a 25-field sidecar; two
  `--json` runs are byte-identical under `cmp`; the staleness re-probe fires with exit 3 on a wrong
  pin; every record line is valid JSON carrying all six shared-head fields.
- `scripts/typst-sync-check.sh --counts-only`: `MISMATCH_COUNT=0`.
- `scripts/check-copyright-headers.sh --strict`: 0 nonconforming, 0 missing, 862 total.
- `scripts/library-index.sh --no-build --check`: `BimodalLib/INDEX.md is current` (no registry row
  was added, so none should have moved).
- Files verified: Yes.

**Scoped-tier discharge and batch deferral.** Phase 8 declares `**Verification Tier**: full`. Per
this dispatch's batch-gate deferral directive the complete deploy gate set
(`verify-deploy.sh`) was **deferred to the batch stage** rather than independently run; this task
touches no path under `.claude/**` and no source-store path, so that set has nothing of this task's
to observe. The scoped discharge was the plan's own nine named checks, each run directly and scoped
to this task's files, plus `scripts/verify-all.sh` as a delta against Phase 1's captured baseline.

**`verify-all.sh` delta against the Phase 1 baseline: 6 PASS, 3 FAIL, every failure outside this
task's file scope**, confirmed mechanically against `git diff --name-only 889bf7c0..HEAD`:

| check | outcome | attribution |
|---|---|---|
| `check-evidence-probes.sh` | PASS | — |
| `check-module-invariants.sh --no-build` | FAIL | C12 at exactly 2 and C20 at exactly 9, both identical to the Phase 1 baseline, both naming only `docs/development/stability-operator-family.md` and `FormalSystem/Metalogic/**` |
| `check-copyright-headers.sh --strict` | PASS | — |
| `readme-lint.sh` | FAIL | 4 new stale dates, identical to the Phase 1 baseline, all under `FormalSystem/` — a tree this task never touched |
| `check-metalogic-cycles.sh` | PASS | — |
| `typst-sync-check.sh` | PASS | — |
| `check-paper-definitions.sh` | FAIL | Paper-anchor drift on `lem:uniq` and `thm:s5` in LaTeX manuscript text. This task touched no `latex/` file and not `docs/reference/paper-definitions-of-record.md` |
| `mk_all --lib FormalSystem --check` | PASS | — |
| `lint-style` | PASS | — |

Two gate findings **were** attributable to this task's own files during Phase 6, and both were
fixed rather than waived: C5 read `FormalSystem.ProofSystem.DerivationTree` in
`BimodalLib/Diagnostics/README.md` as a module path (reworded to name the file), and C23 flagged
`frameClassOf` in `Emit.lean` as shadowing `BimodalLib.frameClassOf` (renamed `frameClassOfType`,
with the reason recorded in its docstring, because C17's dead-declaration census keys on a
declaration's last dot-segment and two declarations sharing a base name mask each other).

## Impacts

- `proof_mode_reprove_perpetuity` (hard consumer) now has a quotable cost figure for its adequacy
  report, and the figure has a shape rather than a point: term size grows **quadratically** in
  `lintro` nesting while heartbeats grow **linearly**, so a long script is cheap to write and
  increasingly expensive to verify. At the five-step threshold the cost is 251 term nodes and 68
  heartbeats; extrapolated, a 100-deep script is ~51,700 nodes. On cost grounds the mode is usable
  on long scripts and no rule change is called for.
- `theorem_library_tableau_pipeline` (hard consumer) has a fixed shared head, five reserved payload
  key lists mirrored in `Stage.reservedKeys`, a documented formula-codec obligation for the two
  reserved stages that carry formula fields, and a worked emitter pair to pattern the other five on.
- The merged congruence kit has the baseline it promised and recorded none of: a single certificate
  is large in absolute terms (1543 nodes at depth 0, ~18× a basic script) but composition is
  **linear** at exactly +346 nodes per scope, so certificates do not blow up. `lintro`'s quadratic
  overtakes a nested rewrite at around depth 20.
- Any later deletion of the TM⁺ rule copies in favour of a shared interface now has a tripwire: the
  `[propext, Quot.sound]`-against-`[propext, Classical.choice, Quot.sound]` asymmetry is pinned.
- `lsimp`'s classical axioms are now attributably from its **rule list**, not its simplifier:
  `lrewrite` through four nested scopes stays at `[propext]` on the same congruence engine.

## Follow-ups

- **The dataset is untracked by design, and the plan assumed otherwise.** `.gitignore` ignores
  `/data` and `git ls-files data/` returns zero files, so `data/proof-mode-diagnostics.jsonl`, its
  sidecar and the `data/README.md` inventory row exist on disk but are not in git. This is the right
  posture for generated data — the regenerating script and the schema it emits against are both
  tracked, so one command reproduces it — but a reader of the plan would expect committed files. If
  the dataset is wanted in git, that is a `.gitignore` negation decision, not this task's.
- **`verify-touched.sh` escalated to a full sweep and self-deadlocked.** An argument-free invocation
  resolved 14 working-tree paths, five unmappable (four `.githooks/*` files this task never touched,
  plus the brand-new baseline document). The OWED fallback ran the whole 102-suite agent-system
  battery (8 NEW failures, all under `.claude/scripts/tests/`), then launched a second pass that
  deadlocked on `/run/user/1000/.gate-lock` held by its own first pass. Torn down via `TaskStop`.
  Worth noting for a future dispatch: that script derives touched paths from the **working tree**,
  so a phase whose work is already committed sees only unrelated leftover dirt, and one unmapped
  unrelated path turns the narrow invocation into exactly the full sweep the directive exists to
  prevent.
- **One COMPARE row is not a distribution.** A real distribution of length ratios needs a reference
  proof per statement, which the tableau pipeline's Extract stage supplies. The `extracted` branch
  of `reference_kind` is exercised only in the test module, deliberately: emitting an `extracted`
  row now would mean fabricating a reference.
- **No semantic-tier figure**, and the baseline document says so explicitly. A semantic mode is not
  in merged state (PRs #9 and #10 open), and the task names exactly the views and derivation tiers.
- **Heartbeat figures are instrument-dependent.** A count taken by `#reprove_record` includes the
  wrapper's own record assembly and runs roughly twice the same script measured by
  `#count_heartbeats in`. Every claim in the baseline document rests on the *shape* of the growth,
  which is instrument-independent, and the document states this limitation rather than burying it.

## References

- `specs/961_proof_mode_axiom_audit_and_cost_baseline/plans/01_axiom-audit-cost-baseline.md`
- `specs/961_proof_mode_axiom_audit_and_cost_baseline/reports/01_axiom-audit-cost-baseline.md`
- `specs/961_proof_mode_axiom_audit_and_cost_baseline/gate-baseline.md`
- `specs/961_proof_mode_axiom_audit_and_cost_baseline/handoffs/phase-{2,4,7}-handoff-20261123.md`
- `docs/reference/diagnostics.md`, `docs/development/proof-mode-cost-baseline.md`
- `specs/evidence/proof-mode-cost-baseline/README.md`
- `records/proof-mode.md` (M13, Evaluation lane), `records/theorem-library.md` § Diagnostics
