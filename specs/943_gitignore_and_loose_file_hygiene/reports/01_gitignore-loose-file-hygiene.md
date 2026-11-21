# Research Report: Task #943

**Task**: 943 - Close three small gitignore and loose-file hygiene gaps at the repository root
**Started**: 2026-11-19
**Completed**: 2026-11-19
**Effort**: small
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `.gitignore`, `latex/`, `.pid`, `Challenge.lean`, `ORGANISATION.md`, `Boneyard/README.md`, `lakefile.toml`
- `specs/reviews/review-2026-11-19.md` (source of record for all three findings)
- `git log`/`git check-ignore`/`git ls-files` live evidence
- `.claude/scripts/lean-challenge-snapshot.sh` and `agent-system/extensions/lean/context/project/lean4/domain/challenge-snapshot.md` (design record)
**Artifacts**: specs/943_gitignore_and_loose_file_hygiene/reports/01_gitignore-loose-file-hygiene.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **(A) is already fully resolved in the live working tree** — the review's premise does not
  hold. Every file currently under `latex/build/` and `latex/subfiles/` is already matched by an
  existing `.gitignore` rule (the generic bare `build/` pattern on line 3, or `latex/**/*.log` on
  line 44), confirmed with `git check-ignore -v`. Adding the dispatch's proposed explicit
  `latex/build/` rule is still worth doing for clarity/robustness (defense-in-depth, matching the
  documented intent of the `latex/**/*.log` line), but it changes nothing about what is currently
  ignored and there is zero tracked content under `latex/` to put at risk.
- **(B) is a straightforward, low-risk fix**: add `/.pid` (anchored) to `.gitignore`. No other
  root-level `.pid` file exists; every other `*.pid` in the tree lives under `specs/.orchestration/`
  or `specs/archive/**/untracked-backup-*/`, already covered by the separate `specs/**/.*` rule
  family and outside this task's scope.
- **(C) has a different correct answer than either option implies at face value.**
  `Challenge.lean` is not a stray scratch file — it is the deliberately-produced, git-committed
  trust-boundary artifact of `.claude/scripts/lean-challenge-snapshot.sh` (the Comparator
  statement-pinning mechanism), written to the project root under the fixed default name
  `Challenge.lean` by design. It is currently the output of the most recent of two now-archived
  tasks (849, then 850) that ran this snapshot tool; its content is tracked, clean, and matches
  `HEAD` exactly. **Relocating it to `Boneyard/` would be actively wrong**: it is not an
  abandoned/refuted approach (Boneyard's documented scope), and the snapshot tool's design
  explicitly writes to `<project_root>/Challenge.lean` as its trust boundary — moving the file
  would defeat a mechanism that future lean tasks rely on. The correct fix is the dispatch's
  other option: **document it in ORGANISATION.md's "Everything else" table.**

## Context & Scope

Three small, independent hygiene gaps identified by `specs/reviews/review-2026-11-19.md`
(1 Medium + 2 Low severity), to be closed in a single pass touching only `.gitignore`,
`ORGANISATION.md`, and (if relocation were chosen) `Challenge.lean` itself. Out of scope per the
dispatch: `Boneyard/` itself, the already-gitignored `other/`/`research/`/`training/`/`data/`
directories, and `lakefile.toml`.

## Findings

### (A) `latex/build/` and `latex/subfiles/` — premise refuted by live evidence

Enumerated every file currently under `latex/` and checked its ignore status directly:

```
latex/*.log, latex/subfiles/*.log           -> ignored by .gitignore:44 latex/**/*.log
latex/build/*.{aux,fdb_latexmk,fls,log,
  out,pdf,toc,xdv}                          -> ignored by .gitignore:3  build/
latex/subfiles/build/*.{aux,fdb_latexmk,
  fls,log,out,pdf}                          -> ignored by .gitignore:3  build/
```

`.gitignore` line 3 is a bare, unanchored `build/` pattern (originally added under the "LEAN 4
build artifacts" comment, intended for Lean's own `build/`/`.lake/` output) — but an unanchored
gitignore pattern with no leading slash matches a directory of that name at **any** depth, so it
also incidentally catches `latex/build/` and `latex/subfiles/build/`. `git status --porcelain
--ignored -- latex` reports the whole `latex/` subtree as `!!` (ignored), and `git ls-files
latex` returns nothing — zero tracked files live under `latex/` today, so there is no
side-effect risk from any change here.

This means the review's literal claim ("matched by no .gitignore pattern") does not describe the
current tree. It is possible the review was written before the generic `build/` rule existed, or
the author did not run `git check-ignore`. Either way, closing this gap by adding an explicit
`latex/build/` rule (as the dispatch's Fix specifies) is still sound practice — it documents
intent explicitly rather than relying on an accidental, overbroad match from a rule whose comment
says it's for Lean — but it is not fixing an active unignored-cruft problem; it is making an
already-correct outcome robust against the `build/` line ever being narrowed or removed.

### (B) `/.pid` — confirmed gap, no complications

`.pid` at the repo root (content: a bare PID, `3291487`) is untracked and currently matched by no
`.gitignore` rule. It is the only `.pid` file at the repo root. Every other `*.pid` file in the
tree is under `specs/.orchestration/` (live orchestrator runtime state) or
`specs/archive/**/untracked-backup-*/` (archived task snapshots) — both already distinct from
the repo root and outside this task's declared file scope (`.gitignore`, `ORGANISATION.md`,
`Challenge.lean`). An anchored `/.pid` rule affects only the root file, as intended.

### (C) `Challenge.lean` — mechanically-produced artifact, not a stray scratch file

Git history shows exactly two commits touching this path, both from completed/archived tasks:

| Commit | Task | Message |
|---|---|---|
| `cd052276` | 849 (archived: `specs/archive/849_forward_slack_discharge_and_exact_shift_iteration/`) | `task 849: snapshot lean challenge statements` |
| `c1bc84a5` | 850 (archived: `specs/archive/850_upfirst_exact_shift_copy_boundary_types/`) | `task 850: snapshot lean challenge statements` |

Both tasks' archived directories contain a `challenge/manifest.json` recording the trust-boundary
metadata (`challenge_module: "Challenge"`, `challenge_path: "Challenge.lean"`,
`theorem_names: [...]`, the pinning `commit` SHA, and an independent `content_sha256`). These are
the exact manifest shape documented by
`agent-system/extensions/lean/context/project/lean4/domain/challenge-snapshot.md`, the design
record for `.claude/scripts/lean-challenge-snapshot.sh`. That script's job is to establish a
Comparator-trusted `Challenge.lean` **at the target project's root** (its own header: "writes the
assembled Challenge module ... and commits it into the TARGET PROJECT'S OWN git history"), by
design, so a future Comparator run can `git show <pinned-SHA>:Challenge.lean` and get back
exactly the intended, immutable theorem statements regardless of what's at `HEAD` later. The
default challenge module name is literally `Challenge` (matching vendored fixtures), which is why
each task's snapshot lands at the same root-level path and overwrites the previous one's
working-tree copy — the old content is never lost, because it's preserved forever at the old
commit SHA, not in the working tree.

The current working-tree `Challenge.lean` is tracked, clean, and identical to `HEAD`
(`git diff HEAD -- Challenge.lean` is empty) — it is simply task 850's snapshot, left in place
because the mechanism has no cleanup step (by design: cleanup would destroy the file the next
Comparator run needs, and the next task's own snapshot run is what's expected to overwrite it).
The `sorry` bodies the review noticed are expected and intentional: a Challenge module pins
**signatures**, not proofs — `lean-comparator-run.sh` compares an untrusted `Solution.lean`
against this `Challenge.lean`'s statements with bodies optionally `sorry`.

Consequences for the dispatch's two options:
- **Relocating to `Boneyard/`** would be a substantive error, not a hygiene improvement.
  `Boneyard/README.md` defines that archive's scope as "approaches that were tried and
  abandoned" with a hard `#exit`-after-imports convention and zero `.olean` output — none of
  which describes `Challenge.lean`. More importantly, the snapshot tool's entire trust model
  depends on writing to `<project_root>/Challenge.lean`; moving the file out of the root would
  not merely mis-file it, it would remove the location the next lean task's snapshot/Comparator
  cycle expects to write to and read from.
- **Documenting it in `ORGANISATION.md`** is therefore the only correct option between the two
  the dispatch offered, and it also happens to be the more useful one: it makes visible, for the
  first time at the repo-map level, a mechanism that otherwise exists only inside
  `.claude/scripts/`/`agent-system/extensions/lean/`.

No mechanical gate currently checks `ORGANISATION.md`'s "Everything else" table for completeness
against root-level files — `scripts/readme-lint.sh` is scoped to given roots (default
`FormalSystem/`) and does not scan root-level loose files, and `scripts/check-module-invariants.sh`'s
only `Challenge`-related lines (4204, 4216) are comments about recorded Challenge *statements*
inside unrelated `Metalogic` modules, not about this file. So this is a pure documentation/
discoverability fix with no gate interaction either way.

## Recommendations

1. **(A)** Add one line to `.gitignore`, directly beneath the existing `latex/**/*.log` /
   `typst/**/*.log` block (or immediately after it), matching that block's own comment style:
   ```gitignore
   latex/build/
   ```
   This is additive only — every file it newly covers is already ignored via line 3's generic
   `build/` rule, so there is no behavior change to verify beyond "still ignored, now explicitly
   and locally."

2. **(B)** Add, in the same general "temporary/runtime files" region of `.gitignore` (near
   `*.tmp`, or beside the other anchored root-only entries like `/CLAUDE.md`):
   ```gitignore
   /.pid
   ```

3. **(C)** Add one row to `ORGANISATION.md`'s "Everything else" table (after the `typst/` row,
   alphabetically consistent with the existing rows), e.g.:
   ```markdown
   | `Challenge.lean` | The committed, git-pinned output of `lean-challenge-snapshot.sh`: the current trust-boundary statement set for whichever lean task most recently ran the Comparator snapshot step. Not a Lake root, not built, bodies are `sorry` by design -- see `agent-system/extensions/lean/context/project/lean4/domain/challenge-snapshot.md` |
   ```
   Do **not** relocate the file to `Boneyard/` and do not delete it — both would break the
   mechanism's precondition that a trusted `Challenge.lean` exists at the project root.

4. Run the dispatch's named verification after the edits: `bash scripts/check-module-invariants.sh`
   and `bash scripts/readme-lint.sh`, confirming no new findings relative to a pre-change baseline;
   `git status --porcelain --ignored` to confirm `.pid` and the `latex/` byproducts show as `!!`
   and no currently-tracked file (there are none under `latex/`, and `Challenge.lean` is untouched
   by the `.gitignore` edits) becomes newly ignored.

## Decisions

- **(A)**: proceed with the dispatch's literal fix (add `latex/build/` to `.gitignore`) as a
  robustness/clarity improvement, while recording in the implementation artifact that the
  underlying cruft the review described does not currently exist — the files are already ignored
  via the unrelated generic `build/` rule. This is not a reason to skip the fix (explicit intent
  beats an accidental match), only a correction to the finding's stated impact.
- **(B)**: proceed exactly as specified — anchored `/.pid`.
- **(C)**: choose the ORGANISATION.md documentation option, not the Boneyard relocation option.
  This is a hard requirement, not a stylistic preference: relocation would be incorrect given
  what the file actually is (see Findings above), independent of which option might otherwise
  read as more thorough "cleanup."

## Risks & Mitigations

- **Risk**: a future reader (or agent) sees `Challenge.lean` sitting at the root with no
  in-repo-visible owner and "cleans it up" (deletes or moves it) without checking git history
  first, breaking a Comparator run that expects to `git show <pinned-SHA>:Challenge.lean` against
  a project where the mechanism's conventions are documented.
  **Mitigation**: the ORGANISATION.md row recommended above is exactly the fix for this —
  it gives a future reader the pointer to the design record before they act.
- **Risk**: the new `latex/build/` gitignore line is interpreted as "the fix for previously
  unignored cruft," and a future contributor concludes other `latex/` paths must also be audited.
  **Mitigation**: the Decisions section above states plainly that no such cruft currently exists;
  carry that caveat into the implementation summary so it isn't re-litigated.
- **Risk**: none identified for `/.pid` — it is the only root `.pid` file and the anchor prevents
  any interaction with `specs/.orchestration/`'s unrelated `*.pid` files.

## Context Extension Recommendations

- **Topic**: the `lean-challenge-snapshot.sh` mechanism and its root-level `Challenge.lean`
  artifact.
  **Gap**: nothing in `ORGANISATION.md`, `README.md`, or any root-level document currently
  mentions that a `Challenge.lean` file can appear at the repo root as a side effect of running a
  lean task through the Comparator snapshot step, or that it is expected and safe.
  **Recommendation**: the one-line ORGANISATION.md row this task adds closes the immediate gap;
  no further context file is needed beyond that row plus its existing pointer to
  `agent-system/extensions/lean/context/project/lean4/domain/challenge-snapshot.md`.

## Appendix

Search/verification commands used (all read-only):
- `cat .gitignore`
- `find latex -type f` + `git check-ignore -v <each file>`
- `git status --porcelain --ignored -- latex`; `git ls-files latex`
- `git status --porcelain .pid`; `find . -name "*.pid" -not -path "./.git/*"`
- `git log --follow --format='%H %ad %s' -- Challenge.lean`; `git show --stat <commit>`
- `git ls-files Challenge.lean`; `git diff HEAD -- Challenge.lean`
- `find . -iname "lean-challenge-snapshot.sh"` / `challenge-snapshot.md"` and read both in full
- `find specs -path "*/challenge/manifest.json"`; read both archived manifests
- `grep -n "Everything else" -A 30 ORGANISATION.md`; `cat Boneyard/README.md`
- `grep -n "Challenge\|ORGANISATION" scripts/check-module-invariants.sh scripts/readme-lint.sh`
