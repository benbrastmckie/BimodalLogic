# Implementation Summary: Task #717

- **Task**: 717 - Write the three missing directory READMEs that fail `scripts/readme-lint.sh` in CI
- **Status**: [COMPLETED]
- **Started**: 2026-10-02T00:00:00Z
- **Completed**: 2026-10-02T00:00:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_missing-decidability-directory-readmes.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Three directories under `FormalSystem/Metalogic/Decidability/` held Lean modules but no
`README.md`, so `scripts/readme-lint.sh` Check 1 reported `Missing READMEs: 3` and exited 1 in the
CI `readme-lint` step. All three were authored at the depth of the named sibling exemplar
`WitnessFamily/Compression/README.md` — purpose statement, route narrative in dependency order,
per-module table, scope boundaries, dependencies block, link footer, `*Last verified:*` stamp — and
the two parent READMEs were updated to list the two subtrees. No Lean source was edited and no Lean
declaration was added. The acceptance criterion holds: `bash scripts/readme-lint.sh FormalSystem
BimodalTools` exits 0.

## What Changed

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/README.md` — created, 109 lines.
  The two incompleteness refutations, presented as a branch rather than a chain: `Targets.lean`
  supplies both limit targets and states no limit, while `HopFree.lean` and `NoCertificate.lean`
  are parallel siblings over different targets and different hypothesis classes. Records why
  `NoCertificate.lean` re-derives rather than imports the three shared opening steps (`hopClosure p`
  and `pumpClosure p` are distinct `Finset PlusFormula` values with no transporting membership
  fact), and keeps the "bounds a strategy" / "bounds the class" distinction explicit.
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/README.md` — created, 158
  lines. Mirrors the exemplar's structure while **inverting its conclusion**: the opening paragraph
  states that the L⁺ compression theorem does not exist and cannot exist for the landed certificate
  class, naming `Limits/NoCertificate.lean`'s `not_exists_plusCertifies_pumpTarget`. Documents the
  strict chain `Types → Cycle → Fulfil → Extract → Saturate`, what each module reuses by import
  versus transcribes, the retained-and-unused alignment half of `Extract.lean`, and the four design
  decisions (no added clause, unchanged bound shape, forced duplication with its named retirement
  trigger, separately stated `snce` propagation).
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md` — created, 224 lines, 25
  table rows. Six-layer route, a row per module, the infinite-carrier-is-forced argument, the
  proved / refuted / open closing record, the nine conjuncts of `Check.Certifies` with the two
  corrections that list carries, and the standing rule that a probe of a `TailStable`-like demand
  must carry both an `untl` and a `snce`.
- `FormalSystem/Metalogic/Decidability/README.md` — four Modules-table rows for the two subtrees
  and their re-exports, two Related Documentation links, stamp refreshed.
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` — three Modules bullets
  (`TransId.lean`, `Compression/`, `Limits/`), three links, stamp refreshed.

## Decisions

- **House style resolved against the exemplar, not the two written standards.** The two standards
  (`docs/development/DIRECTORY_README_STANDARD.md`, `docs/reference/readme-standard.md`) disagree on
  the module-table shape and on whether a stamp is required, and neither in-tree exemplar follows
  either literally. Landed: exemplar section order, a `| Module | Contents |` table with no `Lines`
  column, and a `*Last verified: YYYY-MM-DD*` footer in the tree's dominant form. Neither standard
  document was edited.
- **No inventory marker on any of the three files.** A `BEGIN GENERATED: inventory` or
  `INVENTORY: hand-maintained` marker opts the file into exhaustiveness checking for no gate
  benefit, and the route-ordered table these directories need is not the shape the generator emits.
  `check-module-invariants.sh --emit-inventory --check` still reports `PASS INV`.
- **Relative links confined to the Related Documentation footer.** Check 3's link scan is
  code-fence-blind — it treats any `]` immediately followed by `(` as a link — so module names are
  backticked rather than linked throughout, and every footer link target was confirmed with
  `test -e` resolved from the README's own directory.
- **The `PlusSlicedCertificate` layering follows the modules' `import` lines, not the plan's
  grouping.** `Fixture` imports `Bridge` and `Stable` imports `Fixture`, so the computed-liveness
  machinery genuinely precedes the width fixture rather than following it. The README says so
  explicitly, because the naive reading inverts it.
- **The refuted / open / research-finding distinctions are kept as separate named headings.** The
  finite-carrier finite model property is refuted; `exists_tailStable_repr` is refuted and therefore
  stated in no weakened form; the sliced finite model property is open; the doubly-exponential
  expected slice width is a research finding and explicitly not a theorem.

## Plan Deviations

- **Phase 2** altered: the file landed at 158 lines against the plan's 100-140 band. The withdrawal
  statement and the retained-and-unused section needed the extra prose.
- **Phase 3** altered: the six-layer grouping was re-derived from the per-module `import` lines
  rather than taken from the plan, per that phase's own Scope Hypothesis ("if a module's imports
  contradict the layer it is placed in, follow the imports"). Landed grouping: (1) `Basic`, `Frame`,
  `Window`; (2) `Position`, `Live`, `Canon`, `Splice`; (3) `Timed`, `Fixpoint`, `Computed`, `Fold`,
  `Unroll`, `LiveFix`; (4) `Bridge`; (5) `Fixture`, `Stable`, `Tail`, `FixtureStable`, `HalfRun`;
  (6) `Check`, `Sound`, `Complete`, `Embed`, `EmbedComplete`, `Examples`.
- **Phase 3** altered: the file landed at 224 lines against the plan's 160-220 band.
- **Phase 5** altered: three Modules bullets were added to `PlusWitnessFamily/README.md` rather
  than the planned one. `TransId.lean` was also reported `NOT LISTED` in the same file and `Limits/`
  had no Modules bullet of its own, so all three were added together.

## Verification

- Build: Success — `lake-build-guard.sh build --timeout 1800 -- build` run detached, guard
  `exit_status=0`, `Build completed successfully (2807 jobs)`, zero `error:` lines over both
  captured streams, and every `.olean` under the three documented subtrees newer than its source.
  No `.lean` file was modified by this task (`git diff --name-only` since the pre-task commit lists
  only `.md` paths), so the build graph is unchanged from the pre-task verified state.
- Sorry count: 0 (`lean-sorry-census.sh` over all resolved source roots). The three documented
  subtrees are sorry-free; the single `grep` hit under them is prose inside `EmbedComplete.lean`'s
  docstring.
- Vacuous count: 1, pre-existing and untouched — `FormalSystem/Examples/TemporalStructures.lean`'s
  `int_domain_universal`, where `trivial` discharges a genuinely trivial domain predicate. Not
  introduced here: no `.lean` file was modified.
- Axiom count: 14, unchanged. No `axiom` declaration exists anywhere under the three documented
  subtrees. The build's `#print axioms` output reports only `propext`, `Classical.choice` and
  `Quot.sound`.
- Tests: N/A — no Lean source edited.
- Gate: `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0, with
  `Missing READMEs: 0`, `Total READMEs found: 75`, `Broken file references: 0` and an empty
  `Check 3` section. Counter movement matches the research baseline exactly
  (`3 → 0`, `72 → 75`, `0 → 0`).
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 with `PASS INV`.
- No `NOT LISTED`, `MISSING`, `MISSING DATE` or `STALE DATE` line anywhere in the lint output now
  mentions either L⁺ subtree. `Files not listed (info)` fell from 97 to 91.
- Zero task-number, phase-number or sub-phase citations in any file written under `FormalSystem/`.
  `FixtureStable.lean`'s docstring sub-phase reference and `Extract.lean`'s plan-stage reference
  were deliberately not transcribed.
- Files verified: Yes.

## Impacts

- The CI `readme-lint` step is green for `FormalSystem` and `BimodalTools`, which was the whole
  point of the task.
- Three previously undocumented subtrees — 33 Lean modules in total — now carry a navigable record.
  The two that matter most are records of **negative** results: `Limits/` documents the two
  refutations that withdraw the L⁺ compression theorem, and `Compression/` documents that the
  theorem it was built toward cannot exist for the landed certificate class. Both were previously
  recoverable only by reading module docstrings.
- `PlusSlicedCertificate/README.md` now carries the only consolidated statement in the tree of
  which L⁺ results are proved, which are refuted, and which remain open, and of the fact that the
  doubly-exponential slice width is a research finding and not a theorem.
- A future reader who finds `Extract.lean`'s alignment half in a dead-declaration census report has
  a documented explanation rather than an apparent oversight.

## Follow-ups

- `FormalSystem/README.md` and `FormalSystem/Metalogic/README.md` now carry `STALE DATE` because a
  descendant directory gained files today. Refreshing those stamps asserts a re-verification of
  their content, which this task did not perform, and the tree-wide stale-stamp backlog was an
  explicit Non-Goal. Check 4 is info-only and ungated.
- The 91 remaining `Files not listed (info)` warnings and the 3 `MISSING DATE` warnings elsewhere
  in the tree are untouched, as planned.
- The two competing README standards in `docs/` still disagree. This summary and the three new
  files record the de facto house style they follow; reconciling the documents was a Non-Goal.

## References

- `specs/717_missing_decidability_directory_readmes/plans/01_missing-decidability-directory-readmes.md`
- `specs/717_missing_decidability_directory_readmes/reports/01_missing-decidability-directory-readmes.md`
- `specs/717_missing_decidability_directory_readmes/handoffs/phase-1-handoff-20261002.md`
- `specs/717_missing_decidability_directory_readmes/handoffs/phase-2-handoff-20261002.md`
- `specs/717_missing_decidability_directory_readmes/handoffs/phase-3-handoff-20261002.md`
- `specs/717_missing_decidability_directory_readmes/handoffs/phase-5-handoff-20261002.md`
- `docs/development/DIRECTORY_README_STANDARD.md`, `docs/reference/readme-standard.md`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md` (the depth exemplar)
