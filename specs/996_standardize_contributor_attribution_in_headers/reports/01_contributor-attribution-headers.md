# Research Report: Task #996

**Task**: 996 - Standardize contributor attribution in Lean copyright headers, and backfill the files already edited without it
**Started**: 2026-11-25T16:40:00-08:00
**Completed**: 2026-11-25T17:33:00-08:00
**Effort**: Medium (one implementation round; every mechanism prototyped and measured here)
**Dependencies**: None
**Sources/Inputs**: - Codebase (`scripts/check-copyright-headers.sh`, `scripts/verify-all.sh`, `.github/workflows/ci.yml`, `scripts/readme-lint.sh`, `CONTRIBUTING.md`, `docs/development/LEAN_STYLE_GUIDE.md`, `CITATION.cff`, `.syncprotect`, `.gitignore`), git history (`git log`/`git shortlog`, `.mailmap` probe), Mathlib source (`Mathlib/Tactic/Linter/Header.lean`), agent-system source store (`verify.lua`, `deploy-orphan-detection.md`), live compiled gate runs (`lake build --wfail`, `check-copyright-headers.sh --strict`)
**Artifacts**: - specs/996_standardize_contributor_attribution_in_headers/reports/01_contributor-attribution-headers.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The whole deliverable-2 mechanism is prototyped and measured working.** A single-pass
  `git log --no-merges --format='%aN' --name-only` over the four Lean roots, read against a
  three-row `.mailmap` and a one-name exclusion set (`Claude`), runs in **0.8 s** and produces
  **exactly 30 candidates out of 1007 headed files — 977 clean, zero false positives**. The 30
  are precisely the 24 forward + 6 reverse candidates the task description names. Deliverable 2
  is not a design question any more; it is a transcription job.
- **Two load-bearing premises in the task description are measured FALSE**, and both change the
  implementation. (1) `git log --format=%an` is **mailmap-blind**: only `%aN`/`%aE` honor
  `.mailmap`, and `--use-mailmap` with `%an` was *also* measured ineffective on git 2.54.0. A
  check written as the description states it would ignore the identity map entirely. (2)
  `check-copyright-headers.sh` does **not** validate Mathlib's real multi-line continuation
  form — it rejects it (measured: `exit 1` on the live tree). Only a single-line joint
  `Authors:` line, or a non-Mathlib trailing-comma form, passes today.
- **`.mailmap` and a checker-side exclusion set are not alternatives; both are required.**
  `.mailmap` folds the six identity rows to three display names, correctly and for free. It is
  structurally incapable of *dropping* `Claude <noreply@anthropic.com>` — a mailmap renames, it
  never excludes. The hybrid is the only design that works.
- **`scripts/readme-lint.sh` + `scripts/readme-date-baseline.txt` is the in-repo precedent for
  the waiver mechanism**, and a far better one than Mathlib's `nolints.json`: it already
  implements "gate on *new* findings only, and a changed stamp permanently un-grandfathers a
  waived row" — which is exactly the "gate on unreviewed candidates, not raw mismatches"
  contract deliverable 2 requires.
- **The route decision: Route A, with its reach stated honestly — but it is not the durable
  surface.** `/.claude` is gitignored (`.gitignore:107`), so a Route A rule is **untracked**: it
  reaches agent dispatches in this working copy on this machine and nothing else — not a clone,
  not CI, not a collaborator. The only *tracked* instruction surfaces are the prose convention
  (deliverable 1) and the mechanical gate (deliverable 2). Route A is still worth implementing,
  because it is the only thing that reaches an agent's context mid-dispatch; it must not be
  described as repo-wide.
- **Recommended convention**: `Authors: Tanner Duve, Benjamin Brast-McKie` — single line,
  original `Copyright (c)` line untouched. Measured green against **both** gates on the live
  tree.

## Context & Scope

Researched: the existing header gate's exact predicate and what it does and does not accept; the
identity-map mechanism and its exclusion requirement; the waiver precedents available in-repo;
the agent-instruction route options and their real reach; the backfill candidate set,
re-derived; the barrel-root and reverse-direction discriminations; and the two unheadered
surfaces (`docs/`/`records/`/`README`, and `CITATION.cff`).

Out of scope per the dispatch, and respected: any path under the agent-system source store
(Route B), the clean Benjamin-headed files, and `Boneyard/`.

Measurement hygiene: one compiled probe temporarily modified
`FormalSystem/Semantics/TemporalRules.lean` and was restored byte-exact (`git status --porcelain`
clean on that path afterwards; the `.olean` was rebuilt). The `.mailmap` probe was run via
`git -c mailmap.file=<scratch path>` and wrote nothing to the tree.

## Findings

### Codebase Patterns

**The existing gate's `Authors:` predicate, read exactly.** `scripts/check-copyright-headers.sh`
validates line 4 against `^Authors: [^ ].*[^.]$`, then walks lines 5-12 with
`case "$ln" in Authors:*|*,) ;; *) ok=0 ;; esac`, stopping at `-/`. The consequence, which the
task description gets wrong: **every continuation line, including the last, must end in a
comma.** Mathlib's own convention does the opposite.

Measured on the live tree, with the real CI invocation
(`--strict FormalSystem BimodalTools BimodalLib`, 892 headed files in that scope):

| Form | `lake build --wfail` (Mathlib `linter.style.header`) | `check-copyright-headers.sh --strict` |
|---|---|---|
| `Authors: Tanner Duve, Benjamin Brast-McKie` (one line) | **PASS** — clean build, 0 warnings | **PASS** — 892/892 conforming, exit 0 |
| `Authors: Tanner Duve,` / `  Benjamin Brast-McKie` (Mathlib's real form) | **PASS** — clean build under `--wfail` | **FAIL** — exit 1, file reported nonconforming |
| `Authors: A,` / `B,` (trailing comma on last line) | not probed on the live tree | PASS (scratch probe, exit 0) |

Mathlib's predicate (`Mathlib/Tactic/Linter/Header.lean`, `authorsLineChecks`) joins the
`Authors:` block across lines and requires only: starts with `Authors: `, no `  ` double space
"except possibly after a line break", no ` and `, does not end with `.`, at least one author. It
never requires a trailing comma. The repo's shell checker is therefore *stricter than Mathlib in
a direction Mathlib does not go*, and that strictness blocks the multi-line form a third
contributor would eventually need.

**Identity rows and the `%aN` discovery.** `git shortlog -sne` returns six rows for three
parties: `benbrastmckie` at three emails (14065 + 3698 + 4 = 17767), `Claude
<noreply@anthropic.com>` (46), `Tanner Duve` (9), `Benjamin Brast-McKie
<64314593+...>` (5).

Measured: **all five `Benjamin Brast-McKie` commits are merge commits** (`git log --merges`
confirms each; `--no-merges` reduces that identity's `.lean`-touching count from 1 to 0). So
under `--no-merges` that row never appears in any per-file committer set at all. The display name
the headers use is contributed entirely by the `benbrastmckie` rows.

The `.mailmap` probe, three rows folding all `benbrastmckie` emails onto
`Benjamin Brast-McKie <benjamin@logos-labs.ai>`:

```
%an  + mailmap          -> benbrastmckie 17724, Claude 46, Tanner Duve 9   (UNCHANGED)
%an  + --use-mailmap    -> benbrastmckie ...                               (UNCHANGED)
%aN  + mailmap          -> Benjamin Brast-McKie 17724, Claude 46, Tanner Duve 9
```

`%aN` folds six rows to three display names, two of which match the header strings verbatim.
`%an` — the spelling the task description specifies — does not. `.mailmap` at the repo root needs
no git config; it is read automatically.

**`.mailmap` cannot express the exclusion.** A mailmap maps an identity to another *identity*; it
has no "drop" form. `Claude <noreply@anthropic.com>` must be excluded by the checker. So the
design is: `.mailmap` for folding, a short checker-side list for exclusion. These do different
jobs and neither substitutes for the other.

**The `Co-Authored-By` concern dissolves in the favorable direction.** 8337 commits carry such
trailers. Every distinct value is a Claude model variant (`Claude Opus 4.5` 4521, `Claude Opus
4.6 (1M context)` 1892, ... ) or `OpenCode` (15). **Zero name Tanner** (`grep -ci tanner` on all
trailer values = 0). So `%aN`'s blindness to trailers under-reports exactly the identities the
exclusion set drops anyway. It is aligned with the policy, not a hole in it. This should be
recorded, not merely assumed: a future human co-author added by trailer *would* be missed, and
that is the stated limit.

**Merge commits need no special handling.** `git log --name-only` emits no file names for a merge
commit (diffs are suppressed), and `--no-merges` removes them outright. The only merge commit on
`.lean` paths authored under a *header display name* is `72a375eea` "Merge pull request #8 from
tannerduve/...". Inspected directly: no commit on any of the 24 forward candidates has more than
one parent, and every `benbrastmckie` commit on them is a substantive task phase
(`task 977 phase 7: Interval Lemmas and the One next/prev Encoding`,
`task 984 phase 1: promote the generic succ/pred pair into TemporalRules.lean`, ...). The
"merger vs. editor" ambiguity the description flags is real in principle and empty in this tree.

**The barrel-root grounds in the description are wrong; the conclusion survives via a different
rule.** The claim "each file's entire body below the header block is an `import` list" is false.
Non-import, non-blank lines below the header: `Tests/BimodalTest.lean` 27,
`FormalSystem/Theorems.lean` 73, `FormalSystem/Automation.lean` 79,
`FormalSystem/Semantics.lean` **297**. All four carry substantial module docstrings. A
*file-body* classification cannot justify the exclusion.

The per-commit **import-only-diff** rule the description itself prefers does better — but
measured, it does not finish the job:

| File | Tanner's non-import `+/-` lines | Import-only rule verdict |
|---|---|---|
| `FormalSystem/Semantics.lean` | 0 | cleared |
| `FormalSystem/Theorems.lean` | 0 | cleared |
| `Tests/BimodalTest.lean` | 0 | cleared |
| `FormalSystem/Automation.lean` | **1** | **survives — not cleared** |

The one line is a docstring reference (`` `docs/user-guide/derivation-proof-mode.md`. ``) added
in the same commit as the import. So the import-only rule clears 3 of 4 and leaves 1 for the
waiver path. That is fine — the waiver path exists anyway — but it must be planned for rather
than discovered.

**The reverse-direction pair is a mechanical rename, not new content.** Both
`RaySummary/LadderAgree.lean` (1/1) and `RaySummary/LadderStepFrag.lean` (8/8) are touched by
*one* Tanner commit, `640c44a64f89c5dae4a8506eeeec05bd7818be7e`, titled "Fix the ladder naming
and paper-anchor checks", whose entire footprint is those two files. Its content is the
propagation of one rename, `Zrel_of_kappa_eq` -> `Zrel.of_kappa_eq`, through a theorem signature
and several docstrings, plus deletion of two prose lines. The description calls these "genuine
content edits"; they are genuine *non-import* edits, but they are precisely the "mechanical lint
repair / naming fix" class that deliverable 1's threshold exists to exclude.

**The waiver precedent is in this repo already.** `scripts/readme-lint.sh` Check 4 pins its debt
in `scripts/readme-date-baseline.txt` as `<class> <path> <stamp>` rows (83 lines), grandfathered
by exact match, with the exit code responding only to a finding absent from the baseline — and
"refreshing a stamp permanently un-grandfathers that README". That staleness-invalidation
property is what Mathlib's `nolints.json` lacks and what deliverable 2 needs: a waiver keyed to
`<path> <identity> <stamp>` so a *later* material edit by a *different* third party re-opens the
candidate instead of inheriting a permanent blindfold.

That script is also the CLI-shape precedent: positional roots, a documented
`ROOTS=("FormalSystem")` default hazard, and an explicit gated-vs-reported split stated in its
own header.

**Two hard wiring gates, both with an explicit out-of-sync assertion.** `scripts/verify-all.sh`
carries `expected=10` and exits 1 if the number of reported outcomes differs;
`.github/workflows/ci.yml`'s "Report results" step carries the same `expected=10` and an
`::error::` on mismatch, with a comment reading "A task wiring a new check step adds a `report`
line for it here in the same change, and bumps `expected`." Adding an 11th check therefore
requires three coordinated edits (new step/invocation, new `report` line, `expected=11`) in
**both** files. Missing any one turns the gate red for a bookkeeping reason.

`scripts/README.md` documents every script in a table (`check-copyright-headers.sh` at line 16,
`readme-lint.sh` at 15, and companion data files at 184); a new script and a new baseline file
each need a row.

**Route A's real reach, and the deploy mechanics.** `.claude/rules/lean4.md` already carries
`paths: "**/*.lean"`, so a sibling `.claude/rules/authorship-attribution.md` with the same
frontmatter is the correct shape. Three mechanical facts:

1. **`/.claude` is gitignored** (`.gitignore:107`; `git check-ignore -v .claude/rules/lean4.md`
   confirms). A Route A rule is untracked — present only in this working copy.
2. A plain `deploy-headless.sh` resync will **not** delete it: the copy engine
   (`loader.copy_category`) is "additive-only by design: it never deletes a deployed file just
   because the source no longer has one"
   (`context/patterns/deploy-orphan-detection.md`).
3. `deploy-headless.sh --wipe` **does** `rm -rf .claude`, snapshotting and restoring only
   `.syncprotect`-listed paths. So the `.syncprotect` entry (`rules/authorship-attribution.md`,
   relative to the sync base) is required for `--wipe` survival — and it additionally exempts
   the file from the reverse-direction orphan detector, since `manager.find_orphans` is called
   with `protected_paths` and `verify.lua` documents `.syncprotect`-listed paths as "exempt from
   BOTH presence and hash checks". Without the entry the file would be reported as a real
   orphan.

The lean extension's `source_dir` resolves to
`/home/benjamin/.config/nvim/agent-system/extensions/lean` — present on this machine, confirming
Route B is mechanically available but correctly out of this task's edit scope.

**The unheadered surfaces, re-derived.** `git log --no-merges --author='Tanner Duve'
--name-only` yields **50** non-`.lean` files, not ~30: the description's list omits 18
`specs/proof-mode-extensions/**` files and `typst/generated/status.typ`. Measured: **zero of the
50 carry a copyright header** (`head -10 | grep -i copyright` matched none), confirming
position (a)'s factual premise. Two of the 50 are not candidate surfaces on independent
grounds: everything under `specs/**` is the development record (CONTRIBUTING.md §3: "It is not
maintained afterwards"), and `typst/generated/status.typ` is generated.

**`CITATION.cff`** names only `Brast-McKie, Benjamin`, with `version: "1.0.0"` and
`date-released: "2026-09-07"`. It is the externally-consumed attribution surface and nothing
else in this task touches it.

**Counts corrected.** 1007 headed `.lean` files, not ~1034: 953 `Authors: Benjamin Brast-McKie`
and 54 `Authors: Tanner Duve` (FormalSystem 810, Tests 115, BimodalTools 44, BimodalLib 38).
Every one of the 1007 carries `Authors:` on line 4. The CI invocation's own scope is 892 (it
excludes `Tests/`).

**Rename-history clearance re-confirmed independently.** The prototype's per-file committer map
found history for all 1007 files (`no history (renamed): 0`), so no headed file is invisible to
a non-`--follow` derivation. The description's clearance holds.

### External Resources

- `Mathlib/Tactic/Linter/Header.lean` — `authorsLineChecks` and `copyrightHeaderChecks`. The
  authoritative upstream predicate; read directly rather than inferred. Confirms the repo's
  shell checker is stricter on continuation lines and that Mathlib joins the block across lines.
- Mathlib's own multi-author headers in `.lake/packages/mathlib/Mathlib/` — the real convention
  is `Authors: A, B, C,` / `  D, E` (line 4 comma-terminated, continuation indented two spaces,
  **final line not comma-terminated**). Sampled in `Algebra/Module/LinearMap/Rat.lean` and
  `Algebra/GroupWithZero/Divisibility.lean`.
- `git` 2.54.0 mailmap semantics: `.mailmap` is honored by `%aN`/`%aE` and by `git shortlog`,
  not by `%an`/`%ae`. Measured, not assumed.
- Agent-system source store: `extensions/core/context/patterns/deploy-orphan-detection.md`
  (additive-only copy engine, `.syncprotect` exclusion class) and
  `lua/neotex/plugins/ai/shared/extensions/verify.lua` (`protected_paths` threading into
  `find_orphans`, and the documented presence/hash exemption).

### Recommendations

- **Adopt the single-line joint form `Authors: Tanner Duve, Benjamin Brast-McKie` as the
  convention, leaving the `Copyright (c) YEAR HOLDER` line untouched.**
  [VERIFIED: PASS — applied to `FormalSystem/Semantics/TemporalRules.lean` on the live tree;
  `lake build FormalSystem.Semantics.TemporalRules` built clean (1181/1181, 0 warnings) and
  `scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools BimodalLib` reported
  892/892 conforming, exit 0. File restored byte-exact afterwards.]

- ~~Use the multi-line continuation form, which the checker already validates.~~
  [VERIFIED: FAIL — Mathlib's real continuation form (`Authors: Tanner Duve,` /
  `  Benjamin Brast-McKie`) applied to the same live file: `lake build --wfail` passed clean,
  but `check-copyright-headers.sh --strict` returned **exit 1** with that file listed
  nonconforming. The shell predicate requires a trailing comma on the final continuation line;
  Mathlib's convention omits it. A scratch probe confirmed the diagnosis: a trailing-comma
  variant passes, a non-comma final line fails.
  **Revised to**: use the single-line form for this backfill (two names are ~41 characters, far
  inside any line limit), **and** in the same change relax the continuation predicate to accept
  Mathlib's real form — change the `case "$ln" in Authors:*|*,)` arm so a final continuation
  line need not end in a comma, keeping the `-/`-by-line-12 closure and the no-trailing-period
  rule. Without that relaxation the convention is unusable the moment a third name makes the
  single line too long, and the repo's gate stays stricter than Mathlib for no recorded reason.]

- **Derive per-file committers with `git log --no-merges --format='%aN' --name-only` in a single
  pass, not per-file and not with `%an`.**
  [VERIFIED: PASS — the full prototype (single `git log` + a three-row probe `.mailmap` + the
  `{Claude}` exclusion set, read against each file's line-4 `Authors:`) ran in **0.8 s** over
  **1007** headed files and reported **977 clean / 30 candidates / 0 false positives**, the 30
  being exactly the 24 forward + 6 reverse files. The `%an` control reported `benbrastmckie`
  under the same mailmap and would have flagged essentially every file;
  `--use-mailmap` with `%an` was equally ineffective. A per-file `git log` loop was separately
  measured as exceeding **120 s** and is not viable.]

- **Adopt `.mailmap` at the repo root for the rename folding, AND a short checker-side exclusion
  list for `Claude`. Both, not either.**
  [VERIFIED: PASS for the folding half — a three-row probe mailmap plus `%aN` folded the six
  `git shortlog -sne` identity rows to exactly three display names (`Benjamin Brast-McKie`
  17724, `Claude` 46, `Tanner Duve` 9), two matching the header strings verbatim and needing no
  checker-side lookup. The exclusion half carries no compiled gate to run against it: a mailmap
  has no "drop" form by construction, so `Claude` cannot be expressed there and must live in the
  checker. Record that split as the reason, rather than recording `.mailmap` as "sufficient" or
  as a "fallback-avoided".]

- **Model the waiver on `scripts/readme-date-baseline.txt`, not on Mathlib's `nolints.json`, and
  key each row to a stamp so a later edit re-opens the candidate.** Suggested row shape:
  `<path> <waived-identity> <stamp>`, where the stamp is the reviewed commit sha or the file's
  current `Authors:` line; gate the exit code on candidates *absent from the baseline*, and let
  a changed stamp un-grandfather a row.
  [No compiled gate applicable — this names a file format to be designed, and no existing
  predicate in the tree decides its acceptance. The precedent's own behavior was read from
  `scripts/readme-lint.sh`'s header and `scripts/readme-date-baseline.txt`'s format comment, not
  measured.]

- **Apply the import-only-diff rule as a cheap pre-filter, and expect it to leave
  `FormalSystem/Automation.lean` for the waiver path.**
  [VERIFIED: FAIL for the rule as a complete barrel-root exclusion — measured non-import `+/-`
  line counts across Tanner's commits: `FormalSystem/Semantics.lean` 0,
  `FormalSystem/Theorems.lean` 0, `Tests/BimodalTest.lean` 0, but
  `FormalSystem/Automation.lean` **1** (a docstring reference line added alongside the import).
  The rule clears 3 of 4. **Revised to**: keep the import-only-diff rule (it is narrower and
  more durable than a filename list, exactly as the description argues, and it clears three
  files for free), and waive `FormalSystem/Automation.lean` as one reviewed baseline row with
  its measured 1-line non-import diff recorded as the reason. Do **not** justify the exclusion
  by "the body is an import list" — measured false: the four roots carry 27 / 73 / 79 / 297
  non-import body lines.]

- **Judge both `RaySummary/` reverse candidates BELOW the threshold and waive them, recording
  the measured grounds.**
  [VERIFIED: PASS on the measurement that settles it — both files are touched by exactly one
  Tanner commit, `640c44a6`, whose entire footprint is those two files at 1/1 and 8/8 lines, and
  whose content is the propagation of a single rename `Zrel_of_kappa_eq` -> `Zrel.of_kappa_eq`
  through one theorem signature and several docstrings. That is the mechanical-naming-fix class
  deliverable 1's threshold is written to exclude. The judgment itself is deliberately left to
  the plan/user; the evidence for it is measured and recorded here.]

- **Record the convention in `docs/development/LEAN_STYLE_GUIDE.md` §4 "Documentation
  Requirements", with a one-line pointer from `CONTRIBUTING.md` §2's existing Style bullet.**
  §4 already owns module and declaration docstrings and is where a header rule belongs; §10's
  Lint-Suppression Policy already establishes the "scoped, never blanket, reason recorded at the
  site" idiom the waiver should echo. `CONTRIBUTING.md` §2's Style bullet already says "every
  file has a module docstring and a copyright header" — extend that sentence rather than adding
  a section.
  [No compiled gate applicable — a documentation-placement decision; no predicate in the tree
  decides it.]

- **Wire the new check as an 11th gate in BOTH `scripts/verify-all.sh` and
  `.github/workflows/ci.yml`, bumping `expected` from 10 to 11 in each.**
  [No compiled gate applicable to a not-yet-written script — but the collision is measured
  textually and is hard: both files carry `expected=10` and an explicit out-of-sync assertion
  that exits 1 / emits `::error::` when the reported-outcome count differs. Three coordinated
  edits per file. Also add a `scripts/README.md` row for the new script and for its baseline
  file, matching the existing rows at lines 15-16 and 184.]

- **Implement Route A, and state its reach as "agent dispatches in this working copy", not
  "repo-wide".** A new `.claude/rules/authorship-attribution.md` with
  `paths: "**/*.lean"` (matching `.claude/rules/lean4.md`), plus a `.syncprotect` entry
  `rules/authorship-attribution.md`.
  [VERIFIED: PASS on the three mechanical preconditions, each read from the source store rather
  than assumed — (i) the copy engine is additive-only and never deletes an undeclared deployed
  file, so a plain resync preserves it; (ii) `--wipe` does `rm -rf .claude` and restores only
  `.syncprotect`-listed paths, so the entry is required there; (iii) `find_orphans` is called
  with `protected_paths` and `.syncprotect`-listed paths are documented as exempt from both
  presence and hash checks, so the entry also prevents the file being reported as a real orphan.
  **Reach correction, measured**: `git check-ignore -v .claude/rules/lean4.md` returns
  `.gitignore:107:/.claude`, so the rule file is untracked and reaches neither a clone nor CI
  nor a collaborator. Route A is the right choice for what it does — it is the only surface that
  reaches an agent's context mid-dispatch — but the convention's *durable* home remains
  deliverable 1's tracked prose plus deliverable 2's tracked gate.]

- **Decide the written-record question as "not an attribution surface", with the grounds
  recorded, and correct the file count.**
  [VERIFIED: PASS on the premise — re-derived **50** non-`.lean` files with Tanner commits (not
  ~30; the description's list omits 18 `specs/proof-mode-extensions/**` files and
  `typst/generated/status.typ`), and **zero of the 50 carry a copyright header**. Two
  independent grounds narrow the set further: `specs/**` is the unmaintained development record
  by `CONTRIBUTING.md` §3, and `typst/generated/status.typ` is generated. The "no" answer is
  defensible as the description says; what must not survive is the uncorrected count.]

- **Escalate `CITATION.cff` to the user rather than deciding it here.** See `user_decision` on
  `.return-meta.json`.
  [No compiled gate applicable — an external-consequence decision about a published citation
  record; no predicate decides it and research cannot settle it.]

## Decisions

- **`.mailmap` + `%aN`, not a checker-side rename table.** Decided on the measurement: `%aN`
  folds six rows to three with zero lookup code, and the two folded names match the header
  strings verbatim. The description's "checker-side data file is the FALLBACK" framing is
  upheld — but only for the rename half.
- **The exclusion set is checker-side and non-derivable.** Decided because `.mailmap` has no
  drop form. Initial content: `Claude`. Recorded with it: the trailer survey (8337 trailers, all
  Claude variants or `OpenCode`, zero naming Tanner), and the stated limit that a future human
  co-author added only by trailer would be missed.
- **`--no-merges` on the derivation.** Decided on the measurement that all five commits under
  the `Benjamin Brast-McKie` display-name identity are merges, and that `git log --name-only`
  suppresses merge diffs anyway. This retires the "merger vs. editor" ambiguity for this tree
  without a heuristic.
- **Single-line `Authors:` form for the backfill, plus a predicate relaxation.** Decided on the
  two measured gate runs. Backfilling in the multi-line form would turn CI red.
- **Import-only-diff as a pre-filter, not as the whole barrel-root exclusion.** Decided on the
  measured 1-line residue in `FormalSystem/Automation.lean`.
- **Route A implemented; its reach stated as working-copy-only.** Decided on the gitignore
  measurement. The alternative of describing it as repo-wide was rejected as false.
- **Deliverable 1's threshold, proposed wording for the plan to settle**: an `Authors:` entry is
  earned by a change that adds, removes or alters a declaration, a proof, a definition, or the
  substance of a docstring. It is **not** earned by: an import-list edit, a mechanical rename or
  naming-convention propagation, a lint or whitespace repair, a typo fix, or a generated-file
  regeneration. This wording is what makes both `RaySummary/` files and
  `FormalSystem/Automation.lean` fall below the line, and it is derived from what was actually
  measured in their diffs rather than chosen abstractly.

## Risks & Mitigations

- **Risk: the gate goes red for bookkeeping.** Both `verify-all.sh` and `ci.yml` assert their
  own report-line count against `expected=10`. *Mitigation*: treat the 11th-gate wiring as one
  atomic change across both files (step + `report` line + `expected=11`), and run
  `bash scripts/verify-all.sh` locally before committing.
- **Risk: a permanent blindfold from a filename-only waiver.** A waived path would never be
  re-examined when a *third* contributor materially edits it. *Mitigation*: the stamped row
  shape above, borrowed from `readme-date-baseline.txt`'s un-grandfathering behavior.
- **Risk: the relaxed continuation predicate loosens the gate.** *Mitigation*: relax exactly one
  arm (the final continuation line's comma requirement), keep closure-by-line-12 and the
  no-trailing-period rule, and re-run `--strict FormalSystem BimodalTools BimodalLib` plus
  `--strict Tests` to confirm 1007/1007 still conform.
- **Risk: Route A is believed to be repo-wide.** *Mitigation*: state the untracked,
  working-copy-only reach in the rule file's own text and in the summary, so the
  "attribution is correct across this repository" claim is never made on its strength.
- **Risk: the `%an` -> `%aN` detail is lost in transcription.** It is a one-character difference
  with a 977-false-positive consequence. *Mitigation*: the new script's header comment should
  state it explicitly, in the same voice `check-copyright-headers.sh`'s own header uses for the
  `grep -cxF` anchoring lesson.
- **Risk: an unreviewed `.mailmap` row changes other tooling's output.** `.mailmap` is read by
  every later `git log`/`git shortlog`, including `readme-lint.sh`'s date derivation.
  *Mitigation*: the folding is name-only (all rows already belong to one person); re-run
  `bash scripts/verify-all.sh` after adding it.

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task carries no proof obligation: the work is
  a shell gate, an identity map, prose conventions, and header-line backfills. The Lean-side
  verification used was the compiled header linter via `lake build --wfail`, reported under
  Findings and tagged on the recommendations rather than as a tactic table.

## Context Extension Recommendations

- **Topic**: `git log` format-specifier mailmap awareness (`%an` vs `%aN`).
  **Gap**: nothing in `.claude/context/` records that `%an` ignores `.mailmap` while `%aN`
  honors it, nor that `--use-mailmap` does not rescue `%an`. The task description itself
  specified the mailmap-blind spelling, which is evidence the trap is not written down anywhere
  an author would meet it.
  **Recommendation**: add a short subsection to the lean extension's
  `context/project/lean4/patterns/` (or a core `context/patterns/` git note) recording the
  measured behavior on git 2.54.0 and the 977-false-positive consequence of getting it wrong.

- **Topic**: the repo's two `expected=N` gate-count assertions.
  **Gap**: `scripts/verify-all.sh` and `.github/workflows/ci.yml` each carry an out-of-sync
  guard, and `ci.yml`'s comment is the only place the "bump `expected` in the same change" rule
  is written. `scripts/verify-all.sh` has no such note, and nothing in `.claude/context/`
  mentions either.
  **Recommendation**: record the dual-wiring requirement in
  `context/project/lean4/patterns/plan-authoring-gate-collisions.md`, which already exists for
  exactly this class of collision.

- **Topic**: the untracked reach of `.claude/rules/*` in a deployed tree.
  **Gap**: `source-store-deploy-boundary.md` covers where to *edit*, and
  `deploy-orphan-detection.md` covers survival across a deploy, but neither states that
  `/.claude` is gitignored in consumer repos and that a Route-A-style repo-local rule therefore
  reaches only one working copy. That is the fact that decides whether Route A is sufficient.
  **Recommendation**: add it to the source-store-deploy-boundary narrative's Exceptions
  discussion.

## Appendix

### Commands and probes used

```bash
# Header predicate and census
sed -n 4p <file>                         # 1007 headed files; 953 Benjamin, 54 Tanner
bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools BimodalLib

# Compiled gate probes (file restored byte-exact afterwards)
lake build FormalSystem.Semantics.TemporalRules            # form A: clean, 1181/1181
lake build --wfail FormalSystem.Semantics.TemporalRules    # Mathlib continuation form: clean

# Identity rows and mailmap behavior
git shortlog -sne HEAD
git -c mailmap.file=<probe> log --format='%aN' --no-merges | sort | uniq -c
git -c mailmap.file=<probe> log --format='%an' --no-merges | sort | uniq -c   # control: unchanged
git -c mailmap.file=<probe> log --use-mailmap --format='%an' ...              # control: unchanged

# The prototype derivation (0.8 s, 1007 files, 30 candidates, 0 false positives)
git -c mailmap.file=<probe> log --no-merges --format='C%x09%aN' --name-only \
    -- 'FormalSystem/*.lean' 'Tests/*.lean' 'BimodalTools/*.lean' 'BimodalLib/*.lean'

# Discriminations
git show --format='' --numstat 640c44a6 -- <RaySummary files>
git show --format='' --unified=0 <sha> -- <file> | grep -E '^[+-]' | grep -vE '^[+-]import '
git log --merges --format='%h|%an|%s' -- '*.lean'
git log --format='%(trailers:key=Co-Authored-By,valueonly)' | sort | uniq -c

# Route A mechanics
git check-ignore -v .claude/rules/lean4.md     # -> .gitignore:107:/.claude
```

### Probe `.mailmap` content (the three rows measured working)

```
Benjamin Brast-McKie <benjamin@logos-labs.ai> <benbrastmckie@gmail.com>
Benjamin Brast-McKie <benjamin@logos-labs.ai> <64314593+benbrastmckie@users.noreply.github.com>
Benjamin Brast-McKie <benjamin@logos-labs.ai> <benjamin@logos-labs.ai>
```

A fourth row folding `Benjamin Brast-McKie <64314593+...>` onto the same canonical identity is
cosmetically worth adding for `git shortlog` hygiene, though `--no-merges` means the checker
never sees that row.

### The 30 candidates, as the prototype reports them

Forward (24, header `Authors: Tanner Duve`, missing `Benjamin Brast-McKie`):
`FormalSystem/Automation/ProofMode/{Basic,Carrying,Discrete,Meta,Modal,Rewriting,Temporal,TemporalBoolean,TemporalZTime}.lean`,
`FormalSystem/PlusLanguage/TemporalViews.lean`,
`FormalSystem/Semantics/{PointTransport,RankProgress,TemporalIntervals,TemporalRules}.lean`,
`FormalSystem/Tactic/{FormulaPositions,FormulaSyntax}.lean`,
`FormalSystem/Theorems/ProofMode/TemporalComposition/TemporalZTime.lean`,
`Tests/BimodalTest/Automation/{ProofModeCarryingTest,ProofModeTemporalBooleanProgressTest,ProofModeTemporalTest,ProofModeTemporalZTimeTest,ProofModeTest}.lean`,
`Tests/BimodalTest/Semantics/{PointTransportTest,TemporalRulesTest}.lean`.

Reverse (6, header `Authors: Benjamin Brast-McKie`, missing `Tanner Duve`): the four barrel
roots `FormalSystem/{Automation,Semantics,Theorems}.lean` and `Tests/BimodalTest.lean`, plus
`FormalSystem/Metalogic/Decidability/RaySummary/{LadderAgree,LadderStepFrag}.lean`.

### References

- `scripts/check-copyright-headers.sh` — the gate's header comment on Mathlib's
  `isInLibraryRoot` blind spots; read before changing the predicate, as the dispatch directs.
- `scripts/readme-lint.sh` + `scripts/readme-date-baseline.txt` — the waiver precedent.
- `docs/development/LEAN_STYLE_GUIDE.md` §4 (Documentation Requirements), §10 (Lint-Suppression
  Policy).
- `CONTRIBUTING.md` §2 (What a Contribution Must Satisfy), §3 (Where Documents Live).
- `.lake/packages/mathlib/Mathlib/Tactic/Linter/Header.lean` — `authorsLineChecks`.
- `.config/nvim/agent-system/extensions/core/context/patterns/deploy-orphan-detection.md`;
  `lua/neotex/plugins/ai/shared/extensions/verify.lua`.
