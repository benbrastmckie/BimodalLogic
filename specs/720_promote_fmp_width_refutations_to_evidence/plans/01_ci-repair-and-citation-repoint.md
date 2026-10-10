# Implementation Plan: Task #720

- **Task**: 720 - Promote FMP width refutations to evidence (re-scoped: CI repair of the untracked `WIRED_REPO` entries + citation re-point to the landed `Limits/` theorems)
- **Status**: [IMPLEMENTING]
- **Effort**: 2 hours
- **Dependencies**: 706, 710 (both archived as completed; their `Limits/` landings are in the tree at HEAD)
- **Research Inputs**: specs/720_promote_fmp_width_refutations_to_evidence/reports/01_ci-repair-and-citation-repoint.md
- **Artifacts**: plans/01_ci-repair-and-citation-repoint.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The evidence-probe gate `scripts/check-evidence-probes.sh` is red on every CI push because two of
its three `WIRED_REPO` entries point at files git does not track (archived under the gitignored
`specs/archive/`, present on disk locally, absent from a clean checkout), and `check_probe` tests
only `[ ! -f ]`. This plan (1) closes the mechanism by adding a tracked-ness check
(`git ls-files --error-unmatch`) that fails loudly on a present-but-untracked target, (2) deletes
the two entries, whose content the `lake build`-guarded library modules
`PlusSlicedCertificate/Limits/FiniteCarrier.lean` and `Limits/NoFiniteWidth.lean` fully subsume,
(3) re-points `FMP/README.md` and `Limits/README.md` from the archived `Probe706.`/`Probe710.`
names and the now-false "compiled outside the build graph" / "probe is retained" prose to the
landed library names, and (4) records the archival-`mv` un-tracking rule beside the `mv` in the
source store's `task-abandon-mode.md`. No Lean source changes; `lake build` is run as the finish
line the task description names, not because a `.lean` file moves.

### Research Integration

- Root cause and CI red are confirmed from logs and git, not inferred (report Executive Summary,
  F1-F3): `git ls-files --error-unmatch` fails on both entries; both are matched by `.gitignore`
  line 94 (`specs/archive/`); the 2026-10-05 CI run prints `FAIL (missing: ...)` for exactly
  these two. Re-derived at plan-authoring time: both remain `UNTRACKED` and on disk; the 476
  entry is `TRACKED`.
- Full subsumption (F5, F6): every declaration in both archived probes has a library twin; the
  only rename is `S_hist_unique` -> `shift_hist_unique`. Nothing survives unlanded, so option
  (a) DELETE is adopted for Deliverable B (R3), and `.github/workflows/ci.yml` needs no edit.
- Namespace correction (F5): the carrier family lives in
  `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FiniteCarrier`, the width family in
  `...PlusSlicedCertificate.NoFiniteWidth` -- the task description's single-namespace claim
  applies only to the width family. Re-derived: `FiniteCarrier.lean:114/118/123` and
  `NoFiniteWidth.lean:95/99/103` open those namespaces; headline theorems at
  `FiniteCarrier.lean:248` (`no_finite_carrier_sat`), `:349` (`not_finite_carrier_fmp`),
  `NoFiniteWidth.lean:1200` (`no_finite_width_sat`), `:1257` (`not_sliced_complete`), `:1280`
  (`not_finite_width_fmp`).
- An unnamed citation site (F9, R5): `Limits/README.md`'s Provenance paragraph says "The probe is
  retained as the provenance record and is not superseded", which becomes false once the entries
  are deleted. `state.json` already carries `Limits/README.md` in this task's `file_scope`, so it
  is in scope without a scope change.
- CI will not be fully green after this task (F8): `check-metalogic-cycles.sh` and
  `typst-sync-check.sh` fail at HEAD for unrelated reasons. Acceptance is the evidence-probes
  step plus `lake build`, not the whole job.
- Ordering refinement adopted from the research's negative-test note (R1): landing the
  tracked-ness check BEFORE deleting the entries makes the two live untracked entries the
  negative test, with no temporary edit and no restore step.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context, so no roadmap phases are added.
Read-only consultation of `specs/ROADMAP.md` (lines 98-103) shows this task listed as "720 — CI
repair", promoted ahead of the sliced-certificate pair, with the tracked-ness check named as the
deliverable; this plan advances exactly that item. `ROADMAP.md` is not modified by this plan.

## Goals & Non-Goals

**Goals**:
- `check_probe` fails loudly, with a distinct message, on a `WIRED_REPO`/`WIRED` target that is
  present on disk but not tracked by git; the script header states the rule (TRACKED, NOT MERELY
  PRESENT) and why an archival `mv` produces exactly this case.
- The two untracked `WIRED_REPO` entries and their comment paragraph are removed; the gate prints
  `PASS  all 26 wired probe(s) compile` and exits 0 on a clean checkout.
- `FMP/README.md`'s "The finite-carrier route is refuted, not merely open" subsection cites the
  landed library names, drops the "compiled outside the build graph" parenthetical, and keeps
  both scope-limit paragraphs intact in substance.
- `Limits/README.md`'s Provenance paragraph states that the library modules are the record and
  the sole guarded copy, anchored to the research commits.
- One sentence beside the `mv` in the source store's `context/patterns/task-abandon-mode.md`
  (and the matching `skills/skill-todo/SKILL.md` site) records the un-tracking consequence.

**Non-Goals**:
- The third `WIRED_REPO` entry (`specs/archive/476_.../evidence/fmp-hypothesis-is-false.lean`):
  tracked, out of scope under the task description; the new check passes on it unchanged.
- `.github/workflows/ci.yml`: no edit under option (a); the `file_scope` entry is unused. The
  comment at `ci.yml:239-240` gives a count of force-tracked archive files, not a list, and that
  count is unchanged by this plan.
- `.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` and every other path
  under `.claude/**`: regenerated deploy artifacts, never hand-edited.
- `scripts/decidability-inventory-baseline.txt`: a recorded snapshot by its own header; its
  `--diff` output continuing to show two removed `REFUTED repopath:` records is correct history.
- `specs/evidence/seam-gluing-ray-product/backward-dual-*.lean` docstring mentions of
  `Probe710`: prose only, no path or import; left untouched.
- Repairing `check-metalogic-cycles.sh` or `typst-sync-check.sh` failures.
- Option (b) (promote the probe files into `specs/evidence/` as `WIRED` entries): rejected on
  content grounds (nothing survives unlanded) and cost grounds (~20 s redundant CI per push plus
  a 1,529-line duplicate that can only drift). Recorded here so the choice is visible; the
  implementer does not re-open it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 1 closes with the gate exiting 1 (the two untracked entries now fail with the new message) | L | certain | This is the phase's intended negative test, not a failed operation: CI is already red on the same two entries. Phase 1's verification criterion is the exact two-line failure set; Phase 2 immediately turns it green. State this in the Phase 1 commit message. |
| The re-point silently weakens the two scope-limit paragraphs in `FMP/README.md` | M | L | Diff review of lines 94-100: only "probe(s)" -> "proof(s)"/"theorem(s)" and the two declaration names change; every other word survives. |
| A new task-number reference lands in a deliverable file (script header, READMEs, source-store note) | M | M | Cite durable anchors only: file paths, declaration names, commit SHAs `1b7b8431f` / `b1180dbf8`, `.gitignore`'s `specs/archive/` line. The write-time hook `validate-no-task-references.sh` blocks a slip. |
| `git ls-files` invoked outside a git checkout | L | L | The script already `cd`s to the repository root (line 42) and runs only inside a checkout (local or `actions/checkout@v5`); no extra guard is added. |
| Source-store edit lands in a different repository (`/home/benjamin/.config/nvim`) with unrelated dirty files | M | M | Stage with an explicit file list only (`git add -- <path>`), never `-A`/`.`; if committing there is blocked for this dispatch, leave the edit in that working tree and report it in the summary rather than hand-editing `.claude/`. |
| CI still red after this task because of unrelated steps | L | certain | Acceptance criterion is the evidence-probes step + `lake build` (Phase 5); the two other failing steps are named in Non-Goals so the implementer does not chase them. |
| `verify-deploy.sh` reports the deployed `.claude/` tree stale relative to the source store | L | H | Pre-existing (the dispatch's deploy-freshness context already says `core` is stale) and made certain by Phase 4's source-store edit. Report it as pre-existing/expected, not as a regression; redeploying via `deploy-headless.sh` is the operator's call and not required for acceptance. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel. Phase 4 edits a different repository and
has no file overlap with Phase 3; both wait on Phase 2 only so that no README or note claims the
probes are superseded while the script still guards them.

### Phase 1: Tracked-ness check in `check_probe` (Deliverable A, script half) [COMPLETED]

**Goal**: Make `scripts/check-evidence-probes.sh` reject a wired target that is present on disk
but not tracked by git, with a message distinct from the missing-file case, and document the rule
in the script's own header and footer.

**Tasks**:
- [x] Re-derive the baseline before editing: run
      `awk '/^WIRED_REPO=\(/,/^\)/' scripts/check-evidence-probes.sh | grep -o '"[^"]*"' | tr -d '"' | while read -r f; do git ls-files --error-unmatch -- "$f" >/dev/null 2>&1 || echo "UNTRACKED $f"; done`
      and confirm exactly the 706 and 710 paths print.
- [x] In `check_probe` (currently lines 714-731), insert after the `[ ! -f "$file" ]` branch and
      before the `lake env lean` call:
      ```bash
        if ! git ls-files --error-unmatch -- "$file" >/dev/null 2>&1; then
          echo "FAIL (untracked: $file -- present on disk but not in version control; a fresh clone has no such file)"
          failures=$((failures + 1))
          return
        fi
      ```
      Keep the missing-file branch first so an absent file still reports `missing`, not
      `untracked`.
- [x] Add one header paragraph after the "TWO ENTRY FORMS" paragraph (currently lines 28-33),
      titled in the header's own style (e.g. `TRACKED, NOT MERELY PRESENT.`): a wired probe must
      be tracked by git, because `[ -f ]` is satisfied by a gitignored file under
      `specs/archive/` -- which is exactly what an archival `mv` of a task directory produces --
      so a gate testing presence alone stays green for everyone who has the file on disk and
      fails on every clean checkout. Name the check (`git ls-files --error-unmatch`) and the
      consequence for `WIRED_REPO` entries pointing into a task directory: the entry must be
      re-pointed, or the file promoted to `specs/evidence/`, before that task is archived. Cite
      `.gitignore`'s `specs/archive/` line and no task numbers.
- [x] Extend the footer guidance (currently lines 757-761) with one clause covering the untracked
      case: a `FAIL (untracked: ...)` means the record has left version control, and the repair
      is to promote the file into `specs/evidence/` (or delete the entry if the library now
      carries the result), never to force-track it under `specs/archive/`.
- [x] Run `bash -n scripts/check-evidence-probes.sh` (syntax) and then
      `bash scripts/check-evidence-probes.sh`; capture the output.
- [x] Record the outcome via `issue-record.sh` (`--kind win` if the built-in negative test
      behaves exactly as expected, `--kind issue` otherwise).

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The script's `check_probe` body is at lines 714-731, the "TWO ENTRY FORMS"
paragraph at 28-33, and the footer at 757-761 (carried from the research report, re-opened at
plan-authoring time against a 762-line file); confirm with `grep -n 'check_probe\|TWO ENTRY FORMS\|A probe failing means'` before editing, and treat the line numbers as locators only.

**Tier Justification**: `bash -n scripts/check-evidence-probes.sh` plus a full run of
`bash scripts/check-evidence-probes.sh` is the complete covering check -- the edit is confined to
one standalone script with no caller other than `ci.yml`'s one `run:` line, which passes no
arguments.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - tracked-ness branch in `check_probe`; one header
  paragraph; one footer clause

**Verification**:
- `bash -n scripts/check-evidence-probes.sh` exits 0.
- `bash scripts/check-evidence-probes.sh` exits 1 and prints exactly two `FAIL (untracked: ...)`
  lines -- for `specs/archive/706_.../probes/NoFiniteCarrierModel.lean` and
  `specs/archive/710_.../probes/NoFiniteWidthModel.lean` -- with every `WIRED` entry and the 476
  `WIRED_REPO` entry printing `PASS`, and the summary line `FAIL  2 of 28 wired probe(s) failed`.
  This red result IS the negative test for the new check; the phase commit message says so.
- `grep -c 'ls-files --error-unmatch' scripts/check-evidence-probes.sh` is at least 1 inside
  `check_probe`.
- No `task N` reference appears in the added prose (`grep -nE 'task [0-9]+' scripts/check-evidence-probes.sh` shows no new hit).

---

### Phase 2: Delete the two untracked `WIRED_REPO` entries (Deliverable B) [COMPLETED]

**Goal**: Remove the 706/710 `WIRED_REPO` entries and their comment paragraph so the gate guards
only tracked files, leaving the 476 entry and its paragraphs untouched.

**Tasks**:
- [x] Delete the comment paragraph beginning `# specs/706_.../probes/NoFiniteCarrierModel.lean and
      specs/710_.../probes/NoFiniteWidthModel.lean` through `# collection together with that
      promotion, not before.` (currently lines 685-692).
- [x] Delete the two array lines
      `"specs/archive/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean"`
      and `"specs/archive/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean"`
      from `WIRED_REPO=( ... )` (currently lines 695-696), leaving the 476 line as the sole entry.
- [x] Leave the 476 paragraphs (currently lines 657-684) byte-for-byte unchanged; do not touch
      the `NOTE ON VERSION CONTROL` text, which remains accurate for that one file.
- [x] Do NOT delete, move, or force-track the two archived probe files themselves: they are
      outside version control already, and `specs/archive/` is out of scope.
- [x] Run `bash scripts/check-evidence-probes.sh` and the tracked-ness loop over every remaining
      wired target:
      ```bash
      { awk '/^WIRED=\(/,/^\)/' scripts/check-evidence-probes.sh | grep -o '"[^"]*"' | tr -d '"' | sed 's|^|specs/evidence/|; s|$|.lean|';
        awk '/^WIRED_REPO=\(/,/^\)/' scripts/check-evidence-probes.sh | grep -o '"[^"]*"' | tr -d '"'; } |
      while read -r f; do git ls-files --error-unmatch -- "$f" >/dev/null 2>&1 || echo "UNTRACKED: $f"; done
      ```

**Timing**: 0.25 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: After deletion the gate counts 26 wired probes (25 `WIRED` + 1
`WIRED_REPO`; re-derived at plan-authoring time: `awk '/^WIRED=\(/,/^\)/' ... | grep -c '^ *"'`
gives 25). Confirm the printed total matches `PASS  all 26 wired probe(s) compile`; if a `WIRED`
entry was added since, the count moves and the assertion is the formula, not the number.

**Tier Justification**: A full run of `bash scripts/check-evidence-probes.sh` plus the
tracked-ness loop above is the complete covering check; the edit deletes two array entries and a
comment in one standalone script and touches no file any other module reads.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - remove the 706/710 comment paragraph and the two
  `WIRED_REPO` array lines

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 and prints `PASS  all 26 wired probe(s) compile`
  (no `FAIL` line of either kind).
- The tracked-ness loop prints nothing.
- `awk '/^WIRED_REPO=\(/,/^\)/' scripts/check-evidence-probes.sh` shows exactly one entry, the
  476 path.
- `git diff --stat` for this phase touches only `scripts/check-evidence-probes.sh`.

---

### Phase 3: Re-point `FMP/README.md` and `Limits/README.md` (Deliverable 1) [NOT STARTED]

**Goal**: Replace the archived `Probe706.`/`Probe710.` citations with the landed library names,
delete the now-false "compiled outside the build graph" parenthetical and "probe is retained"
sentence, and keep both scope-limit paragraphs intact in substance.

**Tasks**:
- [ ] In `FormalSystem/Metalogic/Decidability/FMP/README.md`, subsection
      `### The finite-carrier route is refuted, not merely open` (heading at line 79):
  - [ ] First paragraph (lines 81-92): replace `Probe706.no_finite_carrier_sat` with
        `` `FiniteCarrier.no_finite_carrier_sat` `` and `Probe710.not_finite_width_fmp` with
        `` `NoFiniteWidth.not_finite_width_fmp` ``, giving the full prefix
        `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.` once on first mention, and
        link each module by relative path
        (`../PlusSlicedCertificate/Limits/FiniteCarrier.lean`,
        `../PlusSlicedCertificate/Limits/NoFiniteWidth.lean`). Delete the parenthetical
        "(compiled outside the build graph; see `scripts/check-evidence-probes.sh`)" entirely;
        replace it, if a locator is wanted, with "(in the build graph, imported by
        `PlusSlicedCertificate.lean`)". Optionally name the corollaries
        `FiniteCarrier.not_finite_carrier_fmp` and `NoFiniteWidth.not_sliced_complete` in the
        same sentence, matching the `docs/theorem-index.md` rows.
  - [ ] Second paragraph "Two limits" (lines 94-100): change only "both probes rely on" ->
        "both proofs rely on", "Neither probe says" -> "Neither theorem says", and the two
        declaration names to their `FiniteCarrier.` / `NoFiniteWidth.` forms. Every other word
        stays; the ℤ-only limit and the `⊡`-free-versus-`⊡`-bearing distinction are statements
        about the witnesses and must not be weakened.
  - [ ] Under `## Related Documentation`, add
        `- [Limits README](../PlusSlicedCertificate/Limits/README.md)`.
  - [ ] Bump `*Last verified: 2026-10-02*` to the implementation date.
- [ ] In `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md`,
      `## Provenance` (lines 90-97): rewrite the paragraph so it states that each module is a
      transcription of a research probe recorded at commits `1b7b8431f`
      (`NoFiniteCarrierModel.lean`) and `b1180dbf8` (`NoFiniteWidthModel.lean`), with the
      arguments unchanged and the import set, namespace, and linter discipline the only
      transcription changes (keep that existing sentence); then replace "The probe is retained as
      the provenance record and is not superseded." with a sentence stating that the library
      modules are now the record and the sole guarded copy (checked by `lake build` on every
      commit), the probe files having left version control on archival. Correct the existing
      "nested under `PlusSlicedCertificate.NoFiniteWidth`" clause to name both namespaces
      (`...FiniteCarrier` and `...NoFiniteWidth`). Bump `*Last verified: 2026-10-03*`.
- [ ] Run `grep -rnE 'Probe706|Probe710' FormalSystem/ docs/` and confirm no hit remains outside
      docstrings that are deliberately out of scope (expected: none under `FormalSystem/` or
      `docs/`).
- [ ] Run `bash scripts/readme-lint.sh` and
      `timeout 400 bash scripts/check-module-invariants.sh --no-build` (C13 checks that relative
      README links resolve; C5/C12 cover README structure).

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: The four in-scope name citations sit at `FMP/README.md` lines 84, 87, 96,
98 and the parenthetical at 84-85 (carried from the research report; the heading was re-opened
at line 79 and `Last verified` at line 154 at plan-authoring time). Confirm with
`grep -nE 'Probe706|Probe710|outside the build graph' FormalSystem/Metalogic/Decidability/FMP/README.md`
before editing; the assertion is "exactly these citations and no path citation", not the line
numbers.

**Tier Justification**: Both edits are confined to Markdown prose with no compile surface, and
`bash scripts/readme-lint.sh` together with
`timeout 400 bash scripts/check-module-invariants.sh --no-build` (whose C13 resolves every
relative README link) is the covering check for the only thing prose can break here -- a
cross-reference.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/README.md` - re-point the refutation subsection,
  delete the parenthetical, add the Limits README link, bump `Last verified`
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` - rewrite the
  Provenance paragraph, correct the namespace clause, bump `Last verified`

**Verification**:
- `grep -nE 'Probe706|Probe710|outside the build graph' FormalSystem/Metalogic/Decidability/FMP/README.md FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` prints nothing.
- `grep -n 'not superseded' FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` prints nothing.
- `git diff FormalSystem/Metalogic/Decidability/FMP/README.md` shows the "Two limits" paragraph
  changed only in the four places listed above (diff read-through).
- Both relative links from `FMP/README.md` resolve (`test -f` on each target from the README's
  directory), and `bash scripts/readme-lint.sh` exits 0.
- `timeout 400 bash scripts/check-module-invariants.sh --no-build` exits 0 (it exited 0 at HEAD
  per the research report, so a non-zero exit here is a regression from this phase).
- No `task N` reference was introduced (`git diff | grep -nE '^\+.*task [0-9]+'` is empty).

---

### Phase 4: Archival-`mv` note in the source store (Deliverable A, pattern half) [NOT STARTED]

**Goal**: Record, beside the `mv` into `specs/archive/` in the source store's
`context/patterns/task-abandon-mode.md` (and at the matching `/todo` site), that the move
un-tracks everything under the directory, so a guard citing a file by its task-directory path
must be re-pointed first.

**Tasks**:
- [ ] Resolve the source store: `jq -r '.extensions.core.source_dir' .claude-extensions.json`
      (resolved at plan-authoring time to
      `/home/benjamin/.config/nvim/agent-system/extensions/core`, a git worktree rooted at
      `/home/benjamin/.config/nvim`). Do NOT edit `.claude/context/patterns/task-abandon-mode.md`
      in this repository -- it is a regenerated deploy artifact.
- [ ] In `<source_dir>/context/patterns/task-abandon-mode.md`, directly after the `mv` code
      block under "Move task directory to archive" (currently lines 58-67), add one sentence:
      because `specs/archive/` is gitignored, this `mv` removes every file under the directory
      from version control, so any guard that cites a file by its task-directory path (the
      evidence-probe gate's `WIRED_REPO` form in `scripts/check-evidence-probes.sh`) must be
      re-pointed, or the file promoted into `specs/evidence/`, before the task is archived.
      Cite no task numbers.
- [ ] Add the same sentence as a comment or note at the `/todo` archival site,
      `<source_dir>/skills/skill-todo/SKILL.md` step 4c (`mv "$source_dir" "$target_dir"`,
      currently line 546) -- this is the site that actually fired for the archive commit that
      un-tracked the two probes.
- [ ] Diff read-through of both hunks; confirm no task-number reference and no
      record-versioning language ("no longer", "previously") was introduced.
- [ ] Commit in the source-store repository with an explicit file list only
      (`git -C /home/benjamin/.config/nvim add -- agent-system/extensions/core/context/patterns/task-abandon-mode.md agent-system/extensions/core/skills/skill-todo/SKILL.md`),
      under this task's session id in the body. That worktree has unrelated dirty files; never
      use `-A`, `.`, or `-am`. If committing there is blocked for this dispatch, leave the edits
      in that working tree and say so in the summary; do not hand-patch `.claude/**` as a
      substitute.
- [ ] Record via `issue-record.sh` whether the source-store commit succeeded or was left
      uncommitted.

**Timing**: 0.25 hours

**Depends on**: 2

**Verification Tier**: prose

**Tier Justification**: Both hunks are pure-guidance Markdown with no executable surface, so
`suite_selection_select` returns `__FULL_SWEEP__` and no suite covers them; the honest covering
check is the diff read-through plus `bash .claude/scripts/verify-deploy.sh --only-gate 3,4`
(doc-lint and task-reference lint) per plan-format.md's `__FULL_SWEEP__` case.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/core/context/patterns/task-abandon-mode.md` - one sentence after the archive `mv` block (source store; outside this repository and outside `file_scope` by design)
- `/home/benjamin/.config/nvim/agent-system/extensions/core/skills/skill-todo/SKILL.md` - the same sentence at the step 4c `mv`

**Verification**:
- `grep -n 'gitignored\|specs/evidence/' <source_dir>/context/patterns/task-abandon-mode.md`
  shows the new sentence adjacent to the `mv` block.
- `grep -n 'specs/evidence/' <source_dir>/skills/skill-todo/SKILL.md` shows the new note at step
  4c.
- `bash .claude/scripts/verify-deploy.sh --only-gate 3,4` exits 0, or any finding it reports is
  pre-existing (not in the two added hunks).
- `git -C /home/benjamin/.config/nvim status --short` shows the two files committed (or, if
  blocked, still modified and reported as such in the summary).
- No `task [0-9]+` string in either added hunk.

---

### Phase 5: Full gate: evidence probes, invariants, `lake build` [NOT STARTED]

**Goal**: Run the complete verification set over the finished work and confirm the task
description's finish line -- `bash scripts/check-evidence-probes.sh` at exit 0 and `lake build`
green -- plus the repository gate set and the deploy gate.

**Tasks**:
- [ ] `bash scripts/check-evidence-probes.sh` -- exit 0, `PASS  all 26 wired probe(s) compile`.
- [ ] Tracked-ness loop from Phase 2 over every remaining wired target -- prints nothing.
- [ ] Guarded, detached `lake build` per `context/project/lean4/operations/long-builds.md`:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, waited on per
      `context/patterns/bounded-build-waiter.md` (hard timeout, `kill -0` on the captured PID,
      one waiter per log). No `.lean` file changed, so this is expected to be a cache hit; the
      task description names it as the finish line regardless.
- [ ] `timeout 400 bash scripts/check-module-invariants.sh --no-build` -- exit 0.
- [ ] `bash scripts/readme-lint.sh` -- exit 0.
- [ ] `bash .claude/scripts/verify-deploy.sh` -- the complete deploy gate set. A deploy-staleness
      finding for `core` is pre-existing (named in the dispatch's deploy-freshness context) and
      is made certain by Phase 4's source-store edit; report it as expected, not as a regression.
      Redeploying via `bash .claude/scripts/deploy-headless.sh` is the operator's call and is not
      required for acceptance.
- [ ] `grep -rnE 'Probe706|Probe710|NoFiniteCarrierModel|NoFiniteWidthModel' --exclude-dir=.lake --exclude-dir=.git --exclude-dir=archive FormalSystem/ docs/ scripts/check-evidence-probes.sh`
      -- no hit (the `specs/evidence/` docstring mentions and `scripts/decidability-inventory-baseline.txt` are out of scope by Non-Goals).
- [ ] Re-run `bash scripts/check-metalogic-cycles.sh` and `bash scripts/typst-sync-check.sh`
      once, only to confirm their exit status is unchanged from HEAD (both exit 1 before this
      task); record the result in the summary as pre-existing so the next CI run is read
      correctly.
- [ ] Record a final `issue-record.sh` entry (win or issue) for the gate run.

**Timing**: 0.5 hours (dominated by waiting on the guarded `lake build`)

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Files to modify**:
- none (verification only; the summary artifact is written by the implementation postflight)

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 with `PASS  all 26 wired probe(s) compile`.
- `lake build` (via `lake-build-guard.sh`) exits 0.
- `timeout 400 bash scripts/check-module-invariants.sh --no-build` exits 0.
- `bash scripts/readme-lint.sh` exits 0.
- `bash .claude/scripts/verify-deploy.sh` has been run and its findings recorded; every finding
  is either absent or classified pre-existing with the specific gate named.
- The repo-wide grep above prints nothing.
- `git status --short` in this repository shows only the files named in Phases 1-3 modified or
  committed; the source-store repository shows only Phase 4's two files.

## Testing & Validation

- [ ] Phase 1 negative test: with the two untracked entries still present, the gate prints
      exactly two `FAIL (untracked: ...)` lines and no `FAIL (missing: ...)` line.
- [ ] Phase 2 positive test: the gate prints `PASS  all 26 wired probe(s) compile`, exit 0, and
      the tracked-ness loop over all 26 targets prints nothing.
- [ ] README cross-references: `readme-lint.sh` and `check-module-invariants.sh --no-build` exit
      0; both new relative links from `FMP/README.md` resolve.
- [ ] No `Probe706`/`Probe710` citation remains under `FormalSystem/`, `docs/`, or in
      `scripts/check-evidence-probes.sh`.
- [ ] No task-number reference or record-versioning phrase introduced in any deliverable file
      (script, READMEs, source-store notes).
- [ ] `lake build` green via the build guard.
- [ ] CI expectation stated in the summary: the `check-evidence-probes.sh` step turns green on
      the next push; `check-metalogic-cycles.sh` and `typst-sync-check.sh` remain red for
      unrelated, already-known reasons.

## Artifacts & Outputs

- `scripts/check-evidence-probes.sh` -- tracked-ness check, header rule, footer clause; one
  `WIRED_REPO` entry remaining (476).
- `FormalSystem/Metalogic/Decidability/FMP/README.md` -- library-name citations, parenthetical
  removed, Limits README linked.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` -- Provenance
  paragraph anchored to commits `1b7b8431f` / `b1180dbf8`; library modules named as the record.
- Source store: `context/patterns/task-abandon-mode.md` and `skills/skill-todo/SKILL.md` -- the
  un-tracking sentence beside each `mv`.
- `specs/720_promote_fmp_width_refutations_to_evidence/summaries/01_ci-repair-and-citation-repoint-summary.md`
  (written by the implementation postflight).

## Rollback/Contingency

- Every phase is a small, independently revertible edit committed per green sub-step; revert by
  `git revert` of the phase commit(s) in this repository, and of the Phase 4 commit in the
  source-store repository. No `.lean` file changes, so no build-graph rollback is involved.
- If the tracked-ness check misfires on the 476 entry (it is tracked, so it should not), do not
  weaken the check: confirm with `git ls-files --error-unmatch -- <path>` and fix the predicate,
  not the entry.
- If `lake build` is red in Phase 5, the cause is outside this task (no `.lean` edits); report it
  as a blocker with the failing module, do not touch Lean sources under this task.
- If a genuine need for the probe files as standalone records surfaces (none was found), option
  (b) remains mechanically open: both archived probes compiled at HEAD in 9-10 s each; the
  procedure is plain `mv` + `git add` (not `git mv`, which refuses an untracked source) into
  `specs/evidence/seam-gluing-ray-product/`, fix the file's own `lake env lean` header path, and
  add `WIRED` entries, following the Phase 1 procedure in
  `specs/archive/718_omega_sequence_decidability_full_lplus/plans/02_route-probes-and-handoff.md`.
