# Implementation Summary: Task #996

- **Task**: 996 - Standardize contributor attribution in Lean copyright headers, and backfill the files already edited without it
- **Status**: [COMPLETED]
- **Started**: 2026-11-25T17:48:00Z
- **Completed**: 2026-11-25T18:55:00Z
- **Effort**: ~1.1 hours
- **Dependencies**: None
- **Artifacts**: plans/01_header-attribution-convention-gate.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All eight plan phases are complete. The repository now carries a recorded joint-`Authors:`
convention with an explicit attribution threshold, an identity-folding `.mailmap`, a new
candidate-reporting gate wired as the eleventh check in both `scripts/verify-all.sh` and
`.github/workflows/ci.yml`, and a backfill of every live attribution candidate — 17 headers
rewritten to the joint form and 10 reviewed waivers, each carrying its measurement. The scope of
the claim "attribution is correct across this repository" is recorded with its exclusion list
rather than asserted.

## What Changed

- `docs/development/LEAN_STYLE_GUIDE.md` — new §4 subsection "Copyright-Header Authorship": the
  form (both single-line and continuation), the threshold as two explicit lists, the backstop and
  waiver pointers, and a closing scope paragraph recording seven decisions and the exclusion list.
- `CONTRIBUTING.md` — §2 Style bullet extended with the `Authors:` clause and an anchor link.
- `scripts/check-copyright-headers.sh` — the continuation-line `case` arm relaxed so a comma-free
  continuation line is accepted when, and only when, its successor is the closing `-/`, the line
  is non-blank, and it does not end in a period. Header comment records the reason.
- `.mailmap` — new. Folds four `benbrastmckie` / `Benjamin Brast-McKie` identity rows onto
  `Benjamin Brast-McKie <benjamin@logos-labs.ai>`.
- `scripts/check-header-attribution.sh` — new gate. One `git log --no-merges --format='%aN'
  --name-only` pass; `.mailmap`-folded identities; a `Claude` exclusion constant; an
  import-only-diff pre-filter stated as a rule, not a filename list; a stamped baseline waiver;
  candidate-not-verdict output wording; `--strict` red only on unreviewed candidates.
- `scripts/header-attribution-baseline.txt` — new. 10 reviewed waiver rows as
  `<path>|<identity>|<stamp>`, each preceded by the measurement its judgment rests on.
- 17 `.lean` files under `FormalSystem/` and `Tests/` — line 4 rewritten to
  `Authors: Tanner Duve, Benjamin Brast-McKie`.
- `scripts/verify-all.sh` — new check 4, its `report` line, `expected=11`, four prose "ten" ->
  "eleven" corrections, and checks 4-10 renumbered to 5-11.
- `.github/workflows/ci.yml` — new step `id: header-attribution`, its `report` line,
  `expected=11`.
- `scripts/README.md` — one script-table row, one companion-data-table row.
- `.syncprotect` — entry `rules/authorship-attribution.md` with grounds (untracked file).
- `.claude/rules/authorship-attribution.md` — new repo-local Route A rule, `paths: "**/*.lean"`
  (untracked file).
- `CITATION.cff` — `Duve, Tanner` appended to the top-level `authors:` list.

### Theorems and proofs

None. This task's entire `.lean` footprint is 17 files at +1/-1, every changed line an `Authors:`
header line. `git diff` over `*.lean` against the pre-task commit shows zero non-header lines
changed. No declaration, proof, definition or axiom was added, removed or altered.

### The backfill judgment, per file

The threshold: a change earns attribution when it alters a declaration, a proof, or the substance
of a docstring or explanatory comment; it does not when it is a mechanical propagation.

**Backfilled (17)** — `Semantics/TemporalIntervals.lean` (+40/-0 release/trigger reading,
clause-class mixins), `Automation/ProofMode/TemporalBoolean.lean` (3-line authored reachability
note beyond the rename), `Tests/.../ProofModeCarryingTest.lean` (+22/-0 tests),
`Automation/ProofMode/Basic.lean` (+22/-8 instance-synthesis ordering and its doc-comment
contract), `Automation/ProofMode/Temporal.lean` (+14/-0, +19/-2), `Tactic/FormulaSyntax.lean`
(+74/-64), `Semantics/TemporalRules.lean` (+44/-0, +29/-0), `Semantics/RankProgress.lean` (module
docstring rewritten with Main Results / References / Tags), `PlusLanguage/TemporalViews.lean` (six
definition bodies rewritten to `sig%` forms), `Tests/.../ProofModeTest.lean`,
`Tests/.../ProofModeTemporalTest.lean`, `Tests/.../ProofModeTemporalBooleanProgressTest.lean`,
`Tests/.../ProofModeTemporalZTimeTest.lean` (all new test declarations),
`Automation/ProofMode/TemporalZTime.lean` (2-line authored reachability note beyond the rename),
`Tests/.../TemporalRulesTest.lean`, `Semantics/PointTransport.lean` (+73/-2, +42/-1),
`Tests/.../PointTransportTest.lean` (two new `example` declarations with proofs).

**Waived (10)** — `Carrying.lean`, `Discrete.lean`, `Meta.lean`, `Modal.lean`, `Rewriting.lean`,
`Tactic/FormulaPositions.lean`: one `judgment.language` -> `judgment.language.formulaType` /
`language.operatorName` -> `operatorConst` signature-propagation sweep (commits 5f8156d1,
9ad4b32a). `Theorems/ProofMode/TemporalComposition/TemporalZTime.lean`: the `Fold`->`Contract` /
`Unfold`->`Expand` rename plus its forced re-wraps, confirmed at `-U2` to carry no changed proof
term. Both `RaySummary/` files: commit 640c44a6, whose entire repository footprint is those two
files at 1/1 and 8/8 (verified live, no third path), propagating one rename.
`FormalSystem/Automation.lean`: barrel root, one import plus one one-line docs pointer.

## Decisions

- **`.mailmap`, not a checker-side map.** `.mailmap` is git's own mechanism and needs no lookup
  code; the fallback was never required. The exclusion of `Claude` still had to live in the
  checker, because a mailmap has no "drop" form by construction.
- **Stamped baseline, not `nolints.json`.** `scripts/readme-date-baseline.txt` already implements
  the stamp-based un-grandfathering the "gate on unreviewed candidates" contract needs; Mathlib's
  `nolints.json` does not.
- **`|` as the baseline field separator**, against the plan's bare space: two of the three fields
  (identity, stamp) contain spaces.
- **The import-only-diff rule, not a filename list**, for the barrel roots. The grounds recorded
  are the rule plus `FormalSystem/Automation.lean`'s measured one-line residue — explicitly not
  "the body is an import list", which is measured false (27 / 73 / 79 / 297 non-import body
  lines).
- **The new check inserted as check 4**, beside its copyright-header sibling, rather than appended
  after the lake-dependent trio; this renumbered checks 4-10 to 5-11.
- **`CITATION.cff`: `Duve, Tanner` added; `version` and `date-released` deliberately NOT bumped.**
  Per the recorded user decision. The entry matches the existing one's `family-names` /
  `given-names` shape; `email` is omitted because the only address on record is a GitHub noreply
  alias, which is not a contact address. `version: "1.0.0"` and `date-released: "2026-09-07"` were
  left unchanged on the grounds that correcting an already-released record's attribution is not
  itself a release, and bumping either field would assert a release that did not happen. The file
  remains valid CFF 1.2.0: `yaml.safe_load` parses it, all four required keys are present, and
  every `authors` entry carries `family-names` and `given-names`. The separate `references:`
  paper-author list is untouched — it names the paper's authors, not the software's.
- **Written-record surfaces are not an attribution surface this repository tracks.** 50 non-`.lean`
  files carry a second contributor's commits (live re-derivation; corrects the description's ~30)
  and **zero** carry a copyright header, so there is no `Authors:` line to repair.
- **Route A implemented, Route B recorded as a follow-up.** Route A reaches agent dispatches in
  this working copy only, and that limit is written into the rule file's own text.

## Plan Deviations

- **Phase 5**: the plan reads as though all 24 forward candidates would be backfilled. Judged
  individually against the Phase 1 threshold as the plan itself requires, 7 of the 24 fall below
  it and were waived instead. Final split: 17 backfilled, 10 waived, 27 resolved.
- **Phase 6**: `verify-all.sh` needed **five** edits, not the plan's four. "ten" appears in four
  prose places (the PURPOSE line, the EXIT CODE CONTRACT line, the `echo` above the check list,
  and the Decision-3 "checks 8 to 10" note), not one.
- **Phase 7**: the plan listed `.syncprotect` under "Files to modify", implying it was tracked.
  Measured live, `/.syncprotect` is gitignored at `.gitignore:83` and untracked, so **Route A is
  untracked end to end** — both the rule file and the entry protecting it live only in this
  working copy. The rule file's reach statement was amended to say so, and the exclusion list in
  the style guide records it.
- **Phase 3**: the `.mailmap` delta criterion was discharged against `readme-lint.sh` alone — the
  only check in the set that reads `git log` — rather than a second full `verify-all.sh` run, per
  the dispatch's batch-deferral directive. Its output is byte-identical pre and post `.mailmap`.
- **Phase 2**: two negative controls beyond the plan's three (a blank continuation line, and a
  final continuation line ending in a period) were added and the predicate tightened to fail both.
- **Phase 8**: the `full` tier was discharged against `bash .claude/scripts/verify-touched.sh`
  under the dispatch's batch-gate deferral; the complete gate set is deferred to the batch stage.

## Verification

- Build: **Success**. `lake build` via `lake-build-guard.sh`: guard exit 0, "Build completed
  successfully (3029 jobs)", 0 `error:`, 0 `warning:`. `lake build BimodalTest` separately: guard
  exit 0, 3114 jobs, 0/0 — required because `BimodalTest` is absent from `defaultTargets`, so the
  plain build leaves the 7 touched test modules' oleans stale. All 17 touched modules carry an
  `.olean` newer than their source.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: **2**, unchanged from the pre-task commit's 2. Both pre-date this task
  (`PointTransport.lean:215` `def AnyPoint ... := True`, a genuine always-true relation;
  `Examples/TemporalStructures.lean:495` `theorem int_domain_universal ... := trivial`, a real
  proof that an integer-domain history is total). This task added no Lean code.
- Axiom count: **14**, unchanged from the pre-task commit's 14.
- `scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools BimodalLib`: exit 0,
  892/892 conforming. `--strict Tests`: exit 0, 115/115.
- `scripts/check-header-attribution.sh --strict FormalSystem Tests BimodalTools BimodalLib`:
  exit 0 — 1007 headed files, 997 clean, 3 import-only cleared, 10 waived, **0 unreviewed
  candidates**, 0 false positives (all 27 candidates swept).
- Pre-backfill, the same invocation exited 1 with 27 candidates. The `%an` control
  (`AUTHOR_FORMAT=%an`) flags **980** candidates against `%aN`'s 27 — the one-character
  difference demonstrated on this tree rather than carried from research.
- `scripts/verify-all.sh`: **11 outcomes**, no out-of-sync error, 9 PASS / 2 FAIL / 0 SKIPPED.
  Both FAILs (`readme-lint.sh`, `check-paper-definitions.sh`) are the pre-task baseline pair, and
  `readme-lint.sh`'s output is byte-identical to the pre-task capture — zero new FAIL.
- `.github/workflows/ci.yml`: 11 `report` lines, `expected=11`, `yaml.safe_load` parses cleanly,
  `id: header-attribution` matches `steps.header-attribution.outcome`.
- Phase 2 controls: Mathlib's real multi-line form now passes and the pre-relaxation script from
  `HEAD` exits 1 on it (so the relaxation is load-bearing); five negative controls each still
  exit 1.
- `git diff --numstat -- '*.lean'`: 1/1 on every touched file — zero net line delta, so no
  `typst/generated/status.typ` drift and no `--fix` remedy needed.
- `git check-ignore -v .claude/rules/authorship-attribution.md` -> `.gitignore:107:/.claude`;
  `.syncprotect` -> `.gitignore:83:/.syncprotect`.
- Scoped tier (batch deferral): `bash .claude/scripts/verify-touched.sh` resolved 197 touched
  paths and ran 142 + 95 suites. Every failing suite is an agent-system deploy/routing/orchestrate
  test, and this dispatch's own context declared the deployed `core` extension STALE; two name
  that divergence in their own assertion text. Every suite that reads this task's touched surfaces
  passed: `test-script-inventory.sh`, `test-deploy-orphans.sh`, `test-check-task-references.sh`,
  `test-check-record-versioning.sh`, `test-lint-scoped-commit-boundary.sh`,
  `test-deploy-propagation.sh`, `test-git-commit-scoped.sh`.
- Tests: Passed (`lake build BimodalTest` green; the agent-system battery's failures are
  attributed above).
- Files verified: Yes.

## Impacts

- A missing header attribution is now a red gate in both `scripts/verify-all.sh` and CI, where
  before it was invisible: the existing checker validated shape and never compared names.
- `.mailmap` folds author identities for every later `git log` and `git shortlog` in this
  repository, not only the checker's own. Measured: `git shortlog -sne` now reports three parties
  (17776 / 46 / 9) instead of six rows.
- `check-copyright-headers.sh` now accepts Mathlib's real multi-line `Authors:` form, so a third
  contributor is not blocked by a predicate stricter than upstream's.
- `CITATION.cff` is the repository's most externally visible attribution surface and is consumed
  by citation tooling; it now names both contributors.

## Follow-ups

- **Route B, the durable half.** A rule under the lean extension's own `source_dir` stating the
  generic, name-free principle — append to `Authors:` when you materially edit a file someone
  else authored — would reach every repository the extension deploys into. It must be filed as its
  own task in the repository whose filesystem holds that `source_dir`; it is out of this task's
  edit scope by the task-siting rule, and nothing was written across that boundary. Route A as
  shipped is untracked end to end and survives only in this working copy.
- **The trailer hole.** `%aN` does not surface `Co-Authored-By` trailers, so a future human
  co-author contributed only by trailer would be missed. All 16 distinct trailer values today are
  Claude model variants or `OpenCode`, so no human is affected; re-run
  `git log --no-merges --format='%(trailers:key=Co-authored-by,valueonly)' | sort -u` when a third
  party joins.
- **Adding `Tests/` to the CI copyright step** remains a one-word change with its own denominator
  consequences, deliberately not made here. `--strict Tests` is green today (115/115).
- **The deployed `.claude/` tree is stale** for the `core` extension, as this dispatch's context
  declared. No redeploy was scheduled, so no whole-tree claim is made; the `verify-touched.sh`
  failures above are attributed to that staleness.
- **Two pre-existing `verify-all.sh` FAILs** (`readme-lint.sh`: 2 new stale README dates;
  `check-paper-definitions.sh`) pre-date this task and are untouched by it.

## References

- `specs/996_standardize_contributor_attribution_in_headers/plans/01_header-attribution-convention-gate.md`
- `specs/996_standardize_contributor_attribution_in_headers/reports/01_contributor-attribution-headers.md`
- `specs/996_standardize_contributor_attribution_in_headers/handoffs/` — per-phase handoffs 1-7,
  carrying the live measurements each phase recorded
- `docs/development/LEAN_STYLE_GUIDE.md` §4 "Copyright-Header Authorship"
- `scripts/check-header-attribution.sh`, `scripts/header-attribution-baseline.txt`, `.mailmap`
