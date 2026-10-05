# Implementation Summary: Task #726

- **Task**: 726 - Make the decidability-programme inventory re-runnable from the tree
- **Status**: [COMPLETED]
- **Started**: 2026-10-05T00:00:00Z
- **Completed**: 2026-10-05T02:30:00Z
- **Effort**: 1 implementation dispatch (6 phases)
- **Dependencies**: None
- **Artifacts**: plans/01_rerunnable-inventory-mechanism.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Built `scripts/generate-decidability-inventory.sh`, a standing, dependency-free script that
regenerates the PROVED / NOT ESTABLISHED / WITHDRAWN / REFUTED inventory of the decidability
programme from three machine sources, cross-checks every `pinned:` cell in
`docs/theorem-index.md`'s Decidability table against the C2/C14 axiom baselines in
`scripts/check-module-invariants.sh` (the task's motivating defect class), and diffs the result
against a committed, hand-verified baseline (`scripts/decidability-inventory-baseline.txt`)
extracted from the archived decidability-programme review. All six plan phases completed; the
full acceptance suite passes.

## What Changed

- `scripts/generate-decidability-inventory.sh` — new, executable. Bash driver with an inline
  `python3` payload (following `check-module-invariants.sh`'s C36 pattern): parses source 1
  (`docs/theorem-index.md`'s `### Decidability` table), cross-checks `pinned:C2`/`pinned:C14`
  cells against the C2/C14 heredoc baselines (greedy trailing-prime-safe regex, citing C36's own
  comment), parses source 2 (`WIRED`/`WIRED_REPO` arrays in `check-evidence-probes.sh`) and source
  3 (the "Retired as vacuous" section in `Correctness.lean`), and carries WITHDRAWN forward from
  the committed baseline with drift verification. CLI: `--verbose`, `--strict`, `--diff
  [--baseline PATH]`, `--compile-probes`, `--extract-baseline [PATH]`, `--help`. Anti-silence
  guards on every anchor (named failure, exit 2, never a silent empty inventory). Exit 1 only on a
  pin mismatch (or, under `--strict --diff`, any REFUTED-category drift); exit 0 otherwise.
- `scripts/decidability-inventory-baseline.txt` — new. Committed, hand-verified baseline extracted
  from `specs/archive/721_decidability_programme_review_l_and_lplus/reports/`
  `01_decidability-programme-review.md`, section 1 (59 records: 37 PROVED, 9 NOT_ESTABLISHED, 4
  WITHDRAWN, 14 REFUTED). WITHDRAWN entries are hand-written per the script's own documented
  rationale (the report's "Withdrawn by" cells mix full inline type signatures with bare names,
  which a shape-only filter cannot reliably separate); REFUTED backfills the historical 11-member
  `WIRED` array (the report states this only as a prose count, "eleven WIRED plus three
  WIRED_REPO", with no itemised list) as the current array minus the one drift instance the
  archived review's own follow-on research identified.
- `scripts/README.md` — new rows for both files above, under "Other utilities" (an on-demand
  review instrument, not a build gate).
- `specs/ROADMAP.md` — Maintenance section: periodic-re-run ownership moved from this task to
  `scripts/generate-decidability-inventory.sh`, keeping the existing baseline citation intact and
  adding the committed data file as the diff target.
- `<lean-extension source_dir>/context/project/lean4/domain/decidability-provenance.md` — optional
  one-line pointer to the new script, added to the **source store** (resolved via
  `.claude-extensions.json`'s `source_dir`; this file lives in a separate repository and is not
  part of this repo's git history).

## Decisions

- **Standing script, not a `/review` step** — the `core` extension's deployed `.claude/` tree was
  flagged stale relative to its source store at dispatch time, so a `/review`-step edit risked
  silent discard; a script under `scripts/` runs from a fresh clone with no agent-system
  dependency, beside the two scripts it reads.
- **PROVED is not diffed.** The archived baseline's PROVED category is the review's own curated
  set of headline results (its section 1.1 table), not an exhaustive enumeration of every
  `docs/theorem-index.md` Decidability row. An early implementation diffed the two sets and
  produced ~33 false "added" lines for declarations that were already PROVED at baseline time but
  simply never individually cited in the curated table. Dropped in favor of an explicit note in
  the `--diff` output explaining why. The REFUTED diff (a well-founded comparison, since both
  sides enumerate the same `WIRED`/`WIRED_REPO`-shaped set) is unaffected.
- **Elided probe paths resolved by directory tracking.** 4 of the 5 `seam-gluing-ray-product/*`
  rows in the archived report's section 1.1 table spell their path as `.../name.lean` once the
  first row in the group has spelled the directory out in full. `--extract-baseline` tracks the
  last full `specs/evidence/<collection>/` directory seen in table order to resolve these, so all
  5 probes (not just 1) produce a `probe:` baseline record and hence a DISAGREEMENT line.
- **WITHDRAWN carried forward, never regenerated** — one baseline entry
  (`exists_tailStable_repr`) names a declaration that exists nowhere in the tree but in prose; two
  more are the *refuting* theorems for withdrawn subjects and are legitimately live, pinned `C2`
  rows in source 1 today (a source-1-only read would call them PROVED). Confirmed by direct grep
  of `docs/theorem-index.md` and `FormalSystem/` before committing the baseline.

## Plan Deviations

- **Phase 6, "Full repository gate set green"**: altered. 3 pre-existing, non-regression gate
  failures were observed and confirmed via `git log` as unrelated to this task before concluding
  they were not a regression:
  1. `check-module-invariants.sh`'s stale-generated-inventory check fails on `README.md` and
     `FormalSystem/Metalogic/README.md`, both last touched by concurrent sibling task 722's own
     commit (`146d699b7`, "task 722 phase 2: repository and library entry points") — outside this
     task's `file_scope`, not edited here.
  2. `check-metalogic-cycles.sh` fails on an unlayered module
     `FormalSystem.PlusLanguage.PlusRayFibre`, introduced by an unrelated prior commit
     (`6cd41837f`, dated 2026-10-03, "task 719 phase 6").
  3. `check-evidence-probes.sh` (standalone and via `--compile-probes`) reports 2 of 15 wired
     probes FAIL because `specs/706_lplus_finite_model_property_and_completeness/probes/`
     `NoFiniteCarrierModel.lean` and `specs/710_sliced_class_incompleteness_characterization/`
     `probes/NoFiniteWidthModel.lean` are absent from the working tree — reproduced identically
     running that script directly, independent of this task's work.

  All other gates (`lake build`, `readme-lint.sh`, `check-copyright-headers.sh`,
  `check-paper-definitions.sh`, `check-phantom-citations.sh`) pass green, and the two
  invariant/cycle scripts pass on every other check besides the two named failures above.

## Verification

- Build: N/A (bash/python script, no Lean build target of its own; `lake build` itself passes)
- Tests: Passed — full Testing & Validation checklist (plan file) satisfied; see per-phase
  verification detail in the plan's phase sections
- Files verified: Yes

### Acceptance evidence — `--diff` output (verbatim)

```
## DIFF
(against scripts/decidability-inventory-baseline.txt)
  + REFUTED  probe:seam-gluing-ray-product/backward-dual-asymmetric-fixture
  PROVED is not diffed here: the baseline's PROVED category is the archived review's own CURATED
  set of headline results (section 1.1), not an exhaustive enumeration of every
  docs/theorem-index.md Decidability row -- comparing the two sets would report dozens of rows the
  review simply never itemised individually as "added", which is noise, not drift. See the
  committed baseline file's own header for the per-table record counts.
```

- Pin cross-check: 0 mismatches on the clean tree (the task's motivating defect class is currently
  clean); verified to fire correctly via a synthetic bad row injected into
  `docs/theorem-index.md`, confirmed non-zero exit naming the row, then reverted immediately
  (`git diff -- docs/theorem-index.md` empty, re-confirmed clean exit 0).
- WITHDRAWN: `exists_tailStable_repr` confirmed still absent; the two still-live `pinned:C2`
  entries (`not_exists_plusCertifies_pumpTarget`, `not_exists_hopFree_plusCertifies_hopTarget`)
  reported with the explicit source-1-says-PROVED note.
- REFUTED: 5 DISAGREEMENT lines (all `seam-gluing-ray-product/*` probes the baseline classifies
  PROVED).
- `shellcheck scripts/generate-decidability-inventory.sh`: clean (exit 0).

## Impacts

- The decidability programme's four-status inventory is now a re-runnable `--diff`, not an
  archaeology exercise: the next review is `bash scripts/generate-decidability-inventory.sh --diff`.
- `specs/ROADMAP.md` no longer carries an open ownership gap for the periodic re-run.
- The pin cross-check is now a standing, mechanical backstop against the exact defect class
  (`pinned:` claims with no baseline behind them) found by hand on three rows previously.

## Follow-ups

- The 3 pre-existing gate failures recorded above (stale generated-inventory block, unlayered
  `PlusRayFibre` module, 2 missing wired-probe files) are outside this task's scope and were not
  fixed here; they belong to their respective owning tasks/files.
- A future task could wire `--strict` into CI (explicit non-goal here, by design — see the plan's
  Non-Goals).
- A future task could add a thin `/review` step that shells out to this script, now that it exists
  (the plan's Decisions section records this as a natural next step, not undertaken here).

## References

- `specs/726_rerunnable_decidability_programme_inventory/plans/01_rerunnable-inventory-mechanism.md`
- `specs/726_rerunnable_decidability_programme_inventory/reports/01_rerunnable-inventory-mechanism.md`
- `specs/archive/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md`
- `scripts/generate-decidability-inventory.sh`, `scripts/decidability-inventory-baseline.txt`
