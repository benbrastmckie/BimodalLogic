# Research Report: Task #614

**Task**: 614 - Refresh stale README date stamps across FormalSystem, repair archive links, re-point typst citations
**Started**: 2026-09-21T00:00:00Z
**Completed**: 2026-09-21T00:00:00Z
**Effort**: Medium (3 independent mechanical sweeps + 1 editorial judgment call)
**Dependencies**: Task 634 (satisfied — the five XLanguage READMEs are gone from their pre-merge paths)
**Sources/Inputs**: - Codebase (`scripts/readme-lint.sh`, `scripts/typst-sync-check.sh`, `scripts/check-module-invariants.sh`, `.github/workflows/ci.yml`, `.gitignore`), live lint runs at HEAD, a clean `git archive HEAD` export used to reproduce CI's view of the tree, `training/PIPELINE.md`, `typst/chapters/p4-dataset-pipeline.typ`
**Artifacts**: - specs/614_refresh_stale_readme_date_stamps_across/reports/01_readme-stamps-lint-repair.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Re-derived all three work items at HEAD.** The dispatch's counts are close but not exact:
  53 READMEs need a stamp (not 42/47), 21 broken archive links across 11 files (matches), and
  the typst citation problem is materially larger than "re-point the nine".
- **The stamp sweep must use CI's two-root invocation.** CI runs `readme-lint.sh FormalSystem
  BimodalTools`; a bare `readme-lint.sh` misses `BimodalTools/README.md`, which is stale.
  51 `STALE DATE` + 2 `MISSING DATE` = **53 files**.
- **All 21 broken links are pure `../`-depth errors and every corrected target was verified to
  exist on disk.** The corrected path table is in Findings; four of the eleven files need two
  extra `../` because task 635 moved them one level deeper.
- **The typst half does not reduce to a path rewrite.** Five of the nine citations point at
  content that was *deliberately deleted* from `PIPELINE.md` and consolidated into the citing
  chapter itself; their line ranges (`:687-740`, `:744-762`) exceed the file's 701 lines and
  never resolved against this file. Only four citations have surviving anchors, and all four
  need new line numbers.
- **A straight re-point to `training/PIPELINE.md` leaves CI red.** `/training/` is gitignored
  (`.gitignore:91`, deliberate, task 631 phase 4); a clean checkout has no `training/` at all.
  Verified by running the check against `git archive HEAD`.
- **That same clean-checkout run exposed a 10th violation the local tree masks**:
  `` `lakefile.lean` `` in `typst/chapters/ax-lean-appendix.typ:191` resolves locally only via
  `.lake/packages/mathlib/lakefile.lean`. It is a deliberate negative reference and needs a
  whitelist entry, or the revised acceptance criterion cannot be met on CI.

## Context & Scope

Task 614 was written as an advisory date-stamp sweep and widened (SCOPE REVISION, 2026-09-21)
to clear two red CI steps. This research re-derives every input list at HEAD rather than
trusting the 47-file list in `specs/reviews/review-2026-09-17.md`, per the dispatch's explicit
instruction, and validates each proposed remedy against the environment CI actually sees.

Baselines captured at HEAD (commit `657c41892`, working tree carrying only `specs/` churn):

| Check | Invocation | Exit | Gating finding |
|-------|-----------|------|----------------|
| `scripts/readme-lint.sh FormalSystem BimodalTools` | CI's form | **1** | 21 broken references |
| `scripts/readme-lint.sh` | bare | 1 | 21 broken references |
| `scripts/typst-sync-check.sh` | local tree | **1** | `TOTAL_VIOLATIONS=9` |
| `scripts/typst-sync-check.sh` | clean `git archive HEAD` | **1** | `TOTAL_VIOLATIONS=10` |
| `typst compile --root .. typst/BimodalReference.typ` | — | 0 | (warnings only) |
| `typst compile --root .. typst/FormalFoundations.typ` | — | 0 | (warnings only) |
| `scripts/check-module-invariants.sh` | — | **0** | green, including C13 |

Territory: this task's edits land on `FormalSystem/**/README.md`, `BimodalTools/README.md`,
`typst/chapters/p4-dataset-pipeline.typ`, `typst/chapters/ax-lean-appendix.typ` and
`typst/sync-check-whitelist.txt`. None of these appear in the declared `file_scope` of
concurrent siblings 637, 643 or 644. No script under `scripts/` needs editing.

## Findings

### Codebase Patterns

#### What actually gates `readme-lint.sh`

Only Check 1 (missing READMEs) and Check 3 (broken references) affect the exit code
(`scripts/readme-lint.sh:30-39`, `:287-295`). Check 2's 89 `NOT LISTED` lines and Check 4's
stamp findings are measured but never gated. The revised acceptance criterion ("exits 0 with
zero BROKEN lines and zero stale stamps") is therefore *stricter* than exit 0 requires: exit 0
needs only the 21 link fixes; the stamp sweep is what makes Check 4 silent. The 89 `NOT LISTED`
entries are **out of scope** for this task — they are a separate README-inventory drift,
concentrated in `Metalogic/Expressiveness/Kamp/` (78 of 89).

#### The stale-stamp check is self-referential — and that constrains the commit

Check 4 compares the stamp against `git log -1 --format=%cs -- "$dir"`
(`scripts/readme-lint.sh:220-225`), the directory's own last commit date, and `git log` on a
directory includes its whole subtree. Two consequences the implementation must respect:

1. **Committing the sweep re-dates every ancestor directory.** Any commit under
   `FormalSystem/Metalogic/…` makes `FormalSystem/Metalogic/` and `FormalSystem/` last-changed
   today, so their own READMEs must carry today's date too. Both are already in the 53.
2. **The stamp must equal the commit's date.** The predicate is strict (`STAMP_DATE <
   COMMIT_DATE`), so stamping `2026-09-21` is green *only if the commit lands on 2026-09-21*.
   If implementation rolls past midnight, all 53 stamps go stale again. Re-run the lint
   immediately after committing, not before.

The 7 READMEs *not* in the 53 are safe: six already read `2026-09-21`, and the seventh
(`FormalSystem/Tactic/README.md`, stamped and last-changed `2026-09-20`) sits in a leaf
directory this task does not touch.

#### The 53 READMEs needing a stamp (CI's two-root invocation)

51 `STALE DATE` + 2 `MISSING DATE`:

```
BimodalTools/README.md                                              (stale — invisible to a bare readme-lint.sh run)
FormalSystem/README.md
FormalSystem/Automation/README.md
FormalSystem/Automation/ProofSearch/README.md
FormalSystem/Automation/Tactics/README.md
FormalSystem/Examples/README.md
FormalSystem/ForMathlib/README.md
FormalSystem/ForMathlib/Order/README.md
FormalSystem/ProofSystem/README.md
FormalSystem/Semantics/README.md
FormalSystem/Semantics/Correspondence/README.md
FormalSystem/Semantics/Extension/README.md
FormalSystem/Semantics/Frames/README.md
FormalSystem/Semantics/Ultraproduct/README.md
FormalSystem/Syntax/README.md
FormalSystem/Syntax/SubformulaClosure/README.md
FormalSystem/Theorems/README.md
FormalSystem/Theorems/Perpetuity/README.md
FormalSystem/Theorems/Propositional/README.md
FormalSystem/Metalogic/README.md
FormalSystem/Metalogic/Algebraic/README.md
FormalSystem/Metalogic/Bundle/README.md
FormalSystem/Metalogic/BXCanonical/README.md
FormalSystem/Metalogic/BXCanonical/Chronicle/README.md
FormalSystem/Metalogic/BXCanonical/Filtration/README.md
FormalSystem/Metalogic/BXCanonical/Quasimodel/README.md
FormalSystem/Metalogic/Conservativity/README.md
FormalSystem/Metalogic/Conservativity/Plus/README.md
FormalSystem/Metalogic/Conservativity/Star/README.md                (MISSING DATE — needs a new line)
FormalSystem/Metalogic/Core/README.md
FormalSystem/Metalogic/Core/RestrictedMCS/README.md
FormalSystem/Metalogic/Decidability/README.md
FormalSystem/Metalogic/Decidability/BiLasso/README.md
FormalSystem/Metalogic/Decidability/FMP/README.md
FormalSystem/Metalogic/Decidability/Propositional/README.md
FormalSystem/Metalogic/Decidability/Verified/README.md
FormalSystem/Metalogic/Decidability/Verified/Bridge/README.md
FormalSystem/Metalogic/Decidability/Verified/Termination/README.md
FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/README.md   (MISSING DATE)
FormalSystem/Metalogic/Deterministic/README.md
FormalSystem/Metalogic/Expressiveness/EFGames/README.md
FormalSystem/Metalogic/Expressiveness/Kamp/README.md
FormalSystem/Metalogic/Expressiveness/Kamp/EANegationFix/README.md
FormalSystem/Metalogic/Expressiveness/Kamp/EANegationFixFaithful/README.md
FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/README.md
FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/SharedWitness/README.md
FormalSystem/Metalogic/Expressiveness/Separation/README.md
FormalSystem/Metalogic/Independence/README.md
FormalSystem/Metalogic/SoundnessLemmas/README.md
FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/README.md
FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md
FormalSystem/Metalogic/WeakCanonical/IntegerModel/README.md
FormalSystem/Metalogic/WeakCanonical/RealModel/README.md
```

Note the dispatch's third "missing date" file, `Syntax/StarLanguage/README.md`, no longer
exists; `FormalSystem/StarLanguage/README.md` (its post-634 home) is already stamped today.

#### Stamp line formats — four variants, two of them irregular

Across the 51 stale files:

| Count | Shape |
|-------|-------|
| 40 | `*Last verified: YYYY-MM-DD*` |
| 9 | `**Last verified**: YYYY-MM-DD` |
| 1 | `*Last verified: YYYY-MM-DD — `lake build` clean and sorry-free, …` (trailing prose) |
| 1 | `*Last updated: YYYY-MM-DD (retirement of the canonical-frame half to `Boneyard/BundleDeadHalf/`)*` |

The lint reads only the **first** line matching `last verified|last updated`
(`scripts/readme-lint.sh:212`). **Eleven READMEs carry two such lines** and need both kept
consistent, or the file will contradict itself:

```
FormalSystem/Metalogic/Algebraic/README.md
FormalSystem/Metalogic/Bundle/README.md
FormalSystem/Metalogic/Decidability/Verified/Bridge/README.md
FormalSystem/Metalogic/Decidability/Verified/Termination/README.md
FormalSystem/Metalogic/Expressiveness/Kamp/EANegationFixFaithful/README.md
FormalSystem/Metalogic/Independence/README.md
FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/README.md
FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md
FormalSystem/Metalogic/WeakCanonical/RealModel/README.md
FormalSystem/Semantics/Correspondence/README.md
FormalSystem/Semantics/Extension/README.md
```

`Metalogic/Bundle/README.md` is the one genuine wrinkle: its *first* match (line 229) is a
**historical event record** — "retirement of the canonical-frame half to
`Boneyard/BundleDeadHalf/`" on 2026-09-02 — not a verification stamp. Bumping its date would
falsify a dated fact. The clean fix is to reword line 229 so it no longer begins `*Last
updated:` (e.g. `*The canonical-frame half was retired to `Boneyard/BundleDeadHalf/` on
2026-09-02.*`), leaving the real stamp at line 233 as the first match.

Placement convention for the two `MISSING DATE` files: a trailing `*Last verified: YYYY-MM-DD*`
after a `---` rule at end of file, matching the 40-file majority.

#### The 21 broken archive links — every correction verified on disk

All 21 are relative links from a `FormalSystem/**/README.md` into the repository-root
`Boneyard/`, left short when task 630 moved the archive out of `FormalSystem/`. Every one of the
nine distinct targets exists at the repository root. Corrections (each verified by testing
`[ -e "$dir/$newlink" ]`):

| File | × | Old | New |
|------|---|-----|-----|
| `FormalSystem/README.md` | 4 | `Boneyard/README.md` | `../Boneyard/README.md` |
| `FormalSystem/Automation/README.md` | 1 | `../Boneyard/RetiredTactics/README.md` | `../../Boneyard/RetiredTactics/README.md` |
| `FormalSystem/Automation/Tactics/README.md` | 1 | `../../Boneyard/RetiredTactics/README.md` | `../../../Boneyard/RetiredTactics/README.md` |
| `FormalSystem/Metalogic/README.md` | 1 | `../Boneyard/README.md` | `../../Boneyard/README.md` |
| `FormalSystem/Metalogic/README.md` | 1 | `../Boneyard/Kamp/README.md` | `../../Boneyard/Kamp/README.md` |
| `FormalSystem/Metalogic/Bundle/README.md` | 1 | `../../Boneyard/BundleDeadHalf/README.md` | `../../../Boneyard/BundleDeadHalf/README.md` |
| `FormalSystem/Metalogic/Core/README.md` | 2 | `../../Boneyard/RestrictedMCSBoundedness/README.md` | `../../../Boneyard/RestrictedMCSBoundedness/README.md` |
| `FormalSystem/Metalogic/WeakCanonical/README.md` | 1 | `../../Boneyard/README.md` | `../../../Boneyard/README.md` |
| `FormalSystem/Metalogic/WeakCanonical/README.md` | 1 | `../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md` | `../../../Boneyard/…/ExpressiveCompleteness/README.md` |
| `FormalSystem/Metalogic/Expressiveness/EFGames/README.md` | 1 | `../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md` | `../../../../Boneyard/…/ExpressiveCompleteness/README.md` |
| `FormalSystem/Metalogic/Expressiveness/GameTransfer/README.md` | 1 | `../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md` | `../../../../Boneyard/…/ExpressiveCompleteness/README.md` |
| `FormalSystem/Metalogic/Expressiveness/Kamp/README.md` | 2 | `../../../Boneyard/Kamp/KampWeakCanonical/README.md` | `../../../../Boneyard/Kamp/KampWeakCanonical/README.md` |
| `FormalSystem/Metalogic/Expressiveness/Kamp/README.md` | 1 | `../../../Boneyard/Kamp/README.md` | `../../../../Boneyard/Kamp/README.md` |
| `FormalSystem/Metalogic/Expressiveness/Kamp/README.md` | 1 | `../../../Boneyard/README.md` | `../../../../Boneyard/README.md` |
| `FormalSystem/Metalogic/Expressiveness/Separation/README.md` | 1 | `../../../Boneyard/Kamp/KampWeakCanonical/Separation/DedekindZ/README.md` | `../../../../Boneyard/…/DedekindZ/README.md` |
| `FormalSystem/Metalogic/Expressiveness/Separation/README.md` | 1 | `../../../Boneyard/Kamp/KampWeakCanonical/Separation/Hierarchy/README.md` | `../../../../Boneyard/…/Hierarchy/README.md` |

The dispatch's prediction holds exactly: the four `Expressiveness/` files need **two** extra
`../` (task 635 moved them `WeakCanonical/X` → `Expressiveness/X`), the rest need one.

Bare-prose `Boneyard/…` mentions (e.g. `Metalogic/Algebraic/README.md`'s
`Boneyard/ChainCompleteness/`) are **not** markdown links and are already correct relative to
the repository root — leave them alone. Check 3 only extracts `[text](path)` spans
(`scripts/readme-lint.sh:166`).

Safety: `check-module-invariants.sh` C13 scans `docs/` + root `README.md` only
(`scripts/check-module-invariants.sh:31`), not `FormalSystem/**/README.md`, and is currently
green. These edits cannot regress it.

#### The typst citations — five of nine are orphaned, not misdirected

`typst/chapters/p4-dataset-pipeline.typ` carries 13 occurrences of `docs/training/PIPELINE.md`
(one of them the non-backticked comment at line 4), collapsing to 9 distinct backtick spans,
which is what `TOTAL_VIOLATIONS=9` counts. The file is now at `training/PIPELINE.md`, 701 lines.

Its pre-move version (`git show d7b7bd6ee^:docs/training/PIPELINE.md`) was **also 701 lines**,
differing only in `FormalSystem/Automation/…` → `BimodalTools/…` path strings. So `:687-740`
and `:744-762` were out of range before the move too — these citations have never resolved
against this file. The reason is recorded in the file itself:

- `training/PIPELINE.md:10` — "the dual-signal architecture description, the module-count
  discrepancy note, the Tier-1 feasibility gate results, and the Tier-2 theorem-mining
  recommendation **live in the book chapter, not here**, to avoid maintaining two divergent
  copies."
- `training/PIPELINE.md:676` — "the 6-criterion feasibility gate table (3 of 6 FAILED),
  root-cause analysis, and the Tier-2 … recommendations are in the book's Part IV
  dataset-pipeline chapter … **not duplicated here**."

The chapter is therefore quoting a source that was deliberately emptied *into the chapter
itself*. Grepping `training/`, `typst/` and `docs/` for the quoted sentences ("The policy
network learns to predict…", "The value network learns to estimate…", "Generate formulas by
composing known axiom instances…") finds them **only** in
`typst/chapters/p4-dataset-pipeline.typ`. They are not recoverable from any tracked or
untracked file.

Citation-by-citation disposition:

| # | `.typ` line | Citation | Status | Surviving anchor |
|---|------------|----------|--------|------------------|
| 1 | 4, 22, 35, 113 | bare `docs/training/PIPELINE.md` | **live** | `training/PIPELINE.md` (line 35's "Module Reference section" is at `:54`) |
| 2 | 70 | `:14` (artifact-only wording) | **live, wrong line** | `:576` — verbatim sentence |
| 3 | 70 | `:612` (sync mechanism) | **live, wrong line** | `:578-592` — `### Sync Mechanism` + code block |
| 4 | 61 | `:428-437` (lakefile exe decls) | **live, wrong line** | `:391-403` — `## Executable Targets` + `[[lean_exe]]` block |
| 5 | 30 | `:42-44` (EnrichedCountermodel Tier 2) | **live, wrong line** | `:230` — "Implemented, tested … Targeted for Tier 2 integration" |
| 6 | 28 | `:24-31` (policy network) | **orphaned** | none — content is the chapter's own |
| 7 | 29 | `:33-40` (value network) | **orphaned** | none — content is the chapter's own |
| 8 | 93 | `:687-740` (Tier-1 gate table) | **orphaned** | partial: `:651-676` holds config + conformance and delegates the table |
| 9 | 100 | `:744-762` (Priority 1 recommendation) | **orphaned** | none — content is the chapter's own |

#### `training/` is gitignored — a straight re-point leaves CI red

`.gitignore:91` ignores `/training/` (and `/research/`), with an explicit comment that the
relocation out of `docs/` was deliberate: an ignored file left under `docs/` would still be
walked by C13's filesystem scan. `git ls-files training/` returns 0 files.

`typst-sync-check.sh` Check 1 resolves a path-like candidate by filesystem existence under
`FormalSystem/`, `BimodalTools/`, the repo root, then a suffix walk
(`scripts/typst-sync-check.sh:148-167`). It never reads git. So `training/PIPELINE.md` resolves
on a developer's disk and **fails on a clean checkout**.

Verified directly: `git archive HEAD | tar -x` into a scratch directory produces a tree with no
`training/` at all, and running the check there gives:

```
TOTAL_VIOLATIONS=10
```

— the same 9, plus:

```
VIOLATION: `lakefile.lean` -- path does not exist under any Lean source root … nor under the repo root
           (in: typst/chapters/ax-lean-appendix.typ)
```

`ax-lean-appendix.typ:191` reads: "Lake is Lean's build tool, configured declaratively by
`lakefile.toml` rather than by a Lean-syntax `lakefile.lean`." That is a **deliberate negative
reference** — the repo has no `lakefile.lean`. It passes locally only because the suffix walk
finds `.lake/packages/mathlib/lakefile.lean`. The whitelist already has a documented category
for exactly this shape (`thm:BLplus-NextPrevious`: "a deliberate negative-resolution citation,
not a Lean claim").

No other typst backtick span depends on an untracked path — grepping `typst/**/*.typ` for
`training/` and `research/` returns `p4-dataset-pipeline.typ` only.

### External Resources

None required. This task touches no Lean source, no Mathlib declaration and no proof obligation;
no LeanSearch / Loogle / LeanFinder query was needed. `lean_local_search` was not invoked
because no lemma or identifier is in scope.

## Decisions

1. **Derive the stamp list from `readme-lint.sh FormalSystem BimodalTools`, not the bare form.**
   CI uses two roots (`.github/workflows/ci.yml:152`); the bare form silently omits
   `BimodalTools/README.md`, which is stale. 53 files, not 52.
2. **Treat the 89 `NOT LISTED` findings as out of scope.** They are ungated, pre-existing, and
   concentrated in a directory (`Expressiveness/Kamp/`) whose inventory drift is a separate
   problem. The revised acceptance criteria do not mention them.
3. **Fix the 21 links by `../`-depth correction only.** Every corrected target was verified to
   exist; no link needs retargeting or deletion, and no bare-prose `Boneyard/` mention changes.
4. **Do not bump `Metalogic/Bundle/README.md:229`'s date.** It records a dated historical event.
   Reword it out of stamp shape instead, so the lint reads the real stamp at line 233.
5. **Re-derive every surviving typst line number against the live file.** Four of the nine
   citations have genuine anchors, and all four line numbers are wrong; copying them forward
   with only the `docs/` prefix stripped would leave four false citations behind a green check.
6. **Fix `lakefile.lean` in the same sweep.** It is invisible locally but red on CI, and the
   revised acceptance criterion ("`typst-sync-check.sh` exits 0 with `TOTAL_VIOLATIONS=0`")
   cannot be met on CI without it. It is one whitelist line.
7. **Verify the typst half against a clean export, not the working tree.** `git archive HEAD |
   tar -x` into a scratch directory is the cheap, reliable reproduction of CI's view and is what
   caught both the `training/` and `lakefile.lean` problems.

## Recommendations

Four phases, each independently verifiable and independently committable. Phases 1-2 are
mechanical; phase 3 carries the one editorial judgment call.

**Phase 1 — Archive link depth (unblocks CI's README step).** Correct the 21 links across the
11 files per the table above. Verify: `bash scripts/readme-lint.sh FormalSystem BimodalTools`
prints `Broken file references: 0` and `RESULT: PASS`. Commit.

**Phase 2 — Date stamps (53 files).** Rewrite the first `last verified|last updated` date in
each of the 51 stale files to the commit's own date; keep the 11 second stamps consistent;
reword `Bundle/README.md:229` out of stamp shape; append a `*Last verified: YYYY-MM-DD*` line
(after a `---`) to `Metalogic/Conservativity/Star/README.md` and
`Metalogic/Decidability/Verified/Termination/MintBound/README.md`. Commit, then **re-run the
lint after the commit** — the check reads `git log`, so a pre-commit run proves nothing. Expect
zero `STALE DATE` and zero `MISSING DATE`. If the commit lands on a later calendar day than the
stamps, re-stamp to that day.

**Phase 3 — Typst citations.** Recommended composite (see the user decision below):

- *Re-point the four live citations to the correct lines*: bare → `training/PIPELINE.md`;
  `:14` → `:576`; `:612` → `:578-592`; `:428-437` → `:391-403`; `:42-44` → `:230`. Fix the
  line-4 comment too.
- *De-cite the four fully orphaned footnotes* (`.typ` lines 28, 29, 100 and the parenthetical on
  93): the quoted sentences are the chapter's own canonical prose per `PIPELINE.md:10`. Drop the
  quotation marks and the `PIPELINE.md` pointer so the chapter states them in its own voice, or
  re-point to a durable in-repo anchor where one exists.
- *Re-point the gate-results caption on line 93* to `training/PIPELINE.md:651-676` for the
  surviving configuration + conformance material, noting the table itself is the chapter's own.
- *Add a whitelist block* to `typst/sync-check-whitelist.txt` under a new heading covering the
  surviving `training/PIPELINE.md…` spans (they name a deliberately gitignored local-only
  operational doc, absent from any checkout) plus `lakefile.lean` (deliberate negative
  reference). One entry per distinct backtick span, exact match.

Verify: `bash scripts/typst-sync-check.sh` prints `TOTAL_VIOLATIONS=0` **and** the same check
run inside a fresh `git archive HEAD` export also prints `TOTAL_VIOLATIONS=0`.

**Phase 4 — Whole-gate re-verification.** `readme-lint.sh FormalSystem BimodalTools` exit 0
with zero BROKEN and zero stale; `typst-sync-check.sh` exit 0 both locally and in a clean
export; `typst compile --root .. typst/BimodalReference.typ` and
`… typst/FormalFoundations.typ` both exit 0; `check-module-invariants.sh` still exit 0;
`git status` shows nothing modified under `Boneyard/`.

### User decision (non-blocking — phase 3 proceeds on the recommendation)

The task was scoped as mechanical, but four footnotes cite content that no longer exists in any
file. Removing or rewording them edits published prose in the reference manual, which is an
editorial change rather than a path fix. Options:

- **A (recommended)**: de-cite the four orphaned footnotes and whitelist the surviving
  `training/PIPELINE.md` spans. Honest, CI-green, consistent with the de-duplication already
  recorded in `PIPELINE.md:10` and `:676`.
- **B**: un-ignore `/training/` and `git add -f` it, then re-point all nine. Keeps every
  citation but reverses a deliberate task-631 decision and still leaves four citations pointing
  at absent content.
- **C**: whitelist all nine spans unchanged and change nothing in the chapter. Cheapest, turns
  CI green, but leaves nine knowingly-false citations in a published document.

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Stamps go stale again because the commit lands after midnight | Stamp with the commit's own date; re-run the lint *after* committing, not before |
| Phase 2's commit re-dates ancestor directories and re-stales a README not in the 53 | Only `FormalSystem/Tactic/README.md` is at risk, and it is a leaf this task never touches; the final phase-4 lint run catches any surprise |
| A concurrent sibling (637/643/644) edits a file mid-sweep | No declared scope overlap; still re-read each README immediately before editing and stage explicit file lists, never a directory pathspec |
| A local run passes while CI fails | Re-verify `typst-sync-check.sh` inside a `git archive HEAD` export as the gating check |
| De-citing footnotes loses provenance | Record in the summary that the content's canonical home is the chapter itself, citing `PIPELINE.md:10` and `:676` as the decision record |
| Mass `sed` corrupts an irregular stamp line | Four distinct formats and 11 double-stamp files are enumerated above; edit per file, and diff-review before committing |

## Tactic Survey Results

- Not applicable (no Lean proof goals in scope; no tactic survey performed).

## Context Extension Recommendations

- **Topic**: Lints whose resolution depends on untracked working-tree state
- **Gap**: Nothing in `context/project/lean4/` or the repo's development docs warns that
  `typst-sync-check.sh` Check 1 and `readme-lint.sh` Check 3/4 resolve against the filesystem
  and `git log`, so a green local run can hide a red CI run (here: `training/PIPELINE.md`
  masked by local disk, `lakefile.lean` masked by `.lake/packages/`).
- **Recommendation**: add a short note — to `docs/development/` or a lean4 context file — giving
  `git archive HEAD | tar -x -C <tmp>` as the standard way to reproduce CI's view before
  declaring a documentation lint green.

## Appendix

### Commands run

```bash
bash scripts/readme-lint.sh                                  # exit 1, 21 broken
bash scripts/readme-lint.sh FormalSystem BimodalTools        # exit 1, 21 broken, 51 stale + 2 missing (CI's form)
bash scripts/typst-sync-check.sh                             # exit 1, TOTAL_VIOLATIONS=9
bash scripts/check-module-invariants.sh                      # exit 0 (C13 green)
typst compile --root .. typst/BimodalReference.typ  …        # exit 0
typst compile --root .. typst/FormalFoundations.typ …        # exit 0
git archive HEAD | tar -x -C <scratch>                       # clean-checkout reproduction
(cd <scratch> && bash scripts/typst-sync-check.sh)           # exit 1, TOTAL_VIOLATIONS=10
(cd <scratch> && bash scripts/readme-lint.sh FormalSystem BimodalTools)   # 21 broken (identical)
git ls-files training/                                       # 0 files
git check-ignore -v training/PIPELINE.md                     # .gitignore:91:/training/
git show d7b7bd6ee^:docs/training/PIPELINE.md | wc -l        # 701 (same as now)
```

### Key file references

- `scripts/readme-lint.sh:30-39` — what is gated vs. merely reported
- `scripts/readme-lint.sh:212-225` — first-match stamp extraction and the `git log` comparison
- `scripts/readme-lint.sh:166` — Check 3 extracts `[text](path)` spans only
- `scripts/typst-sync-check.sh:148-167` — path-like candidate resolution, line-suffix stripping
- `.github/workflows/ci.yml:148-177` — the two red steps and their exact invocations
- `.gitignore:85-91` — why `/training/` and `/research/` are deliberately untracked
- `training/PIPELINE.md:10`, `:676` — the de-duplication decision that orphaned five citations
- `typst/chapters/ax-lean-appendix.typ:191` — the deliberate `lakefile.lean` negative reference
- `typst/sync-check-whitelist.txt:1-15` — whitelist format and existing categories
