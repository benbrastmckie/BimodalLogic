# Research Report: proof_wanted trust surface and external library dependency assessment lessons

- **Task**: 904 - File three method lessons from the cslib omega-automata reassessment report's Context Extension Recommendations
- **Started**: 2026-11-09T14:19:00Z
- **Completed**: 2026-11-09T14:30:00Z
- **Effort**: ~30 minutes
- **Dependencies**: None
- **Sources/Inputs**:
  - `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md` (Context Extension Recommendations section, and the finding rows it rests on)
  - `.claude-extensions.json` (`source_dir` resolution for the lean and core extensions)
  - Source store: `~/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/metadata-trust-surfaces.md`
  - Source store: `~/.config/nvim/agent-system/extensions/lean/context/project/lean4/patterns/dependency-tracing.md` (style/structure template for the new pattern file)
  - Source store: `~/.config/nvim/agent-system/extensions/core/context/formats/report-format.md`
- **Artifacts**:
  - `specs/904_proof_wanted_trust_surface_and_external_library_dependency_assessment/reports/01_proof-wanted-trust-surface-and-dependency-assessment-lessons.md` (this report)
  - `~/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/metadata-trust-surfaces.md` (edited: new §6, renumbered §6→§7, new practical-consequences bullet)
  - `~/.config/nvim/agent-system/extensions/lean/context/project/lean4/patterns/external-library-dependency-assessment.md` (new file)
  - `~/.config/nvim/agent-system/extensions/core/context/formats/report-format.md` (edited: new "Amending a Prior Verdict" subsection)
- **Standards**: report-format.md, subagent-return.md, source-store-deploy-boundary.md

## Executive Summary

- This is a meta task: all three method lessons named in the dispatch were authored directly in
  the source store resolved from `.claude-extensions.json`'s `source_dir` field, per
  `rules/source-store-deploy-boundary.md` — none were hand-authored under `.claude/**`.
- Lesson 1 (`proof_wanted` as a trust surface distinct from `sorry`) landed as a new §6 in
  `lean/context/project/lean4/domain/metadata-trust-surfaces.md`, with the prior §6 "Practical
  consequences" renumbered to §7 and a cross-referencing bullet added there.
- Lesson 2 (external-library-dependency checklist) landed as a new pattern file,
  `lean/context/project/lean4/patterns/external-library-dependency-assessment.md`, in the same
  directory and prose register as the existing `dependency-tracing.md` and
  `mcp-fallback-table.md` pattern files.
- Lesson 3 ("ground overturned, outcome preserved" as a distinct verdict-amendment kind) landed
  as a new subsection in `core/context/formats/report-format.md`, placed between the existing
  "Carried-Figure Discipline" and "Example Skeleton" sections, since the report-format standard
  (rather than the task-status-marker standard, which only governs task lifecycle states) is
  where a report author's `## Decisions` writing guidance already lives.
- No file under `FormalSystem/` or `Tests/` was touched, no `lakefile.toml`/`lake-manifest.json`
  edit was made, and no redeploy was run or claimed, matching the dispatch's NON-GOALS.
- The source-store git repository (`~/.config/nvim/agent-system`) was left uncommitted: it
  already carries a substantial number of unrelated modified/untracked paths from concurrent
  work outside this task's scope, and this dispatch's contract names authoring the files, not
  committing a shared repository on another task's behalf.

## Context & Scope

The dispatch is a `meta` task whose sole content is filing three context-extension
recommendations raised by an earlier report's own "Context Extension Recommendations" section
(`specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md`,
lines 317-331). That section names three gaps verbatim, each with a Topic/Gap/Recommendation
triple, and this dispatch's own Description reproduces each with additional concrete detail
(line numbers, measured counts, command forms). The scope is therefore narrow and
well-specified: author exactly the three artifacts the dispatch names, in the exact location the
source-store/deploy-boundary rule requires, with no implementation or FormalSystem-side work.

Constraints carried from the dispatch and the repository's own rules:
- `rules/source-store-deploy-boundary.md`: `.claude/**` in this deployed tree is disposable;
  edits belong in the source store at the `source_dir` each extension's manifest names.
- `rules/no-task-references-in-deliverables.md` and `rules/no-record-versioning-in-deliverables.md`:
  the three authored files live outside `specs/**`, so task numbers and draft-history language
  were avoided throughout (the new text cites file paths and measured facts, never "task 902").
- The dispatch's NON-GOALS: no hand-authored `.claude/**` file, no redeploy claim, no change
  under `FormalSystem/` or `Tests/`.

## Findings

### Codebase Patterns

- `.claude-extensions.json`'s `extensions.lean.source_dir` resolves to
  `/home/benjamin/.config/nvim/agent-system/extensions/lean`, and `extensions.core.source_dir`
  to the sibling `.../extensions/core` — confirming both target files for Lessons 1-2 (lean
  domain/patterns) and Lesson 3 (core formats) live under the same source-store root.
- `metadata-trust-surfaces.md` is organized as six numbered sections (`## 1.` … `## 6.`) ending
  in a "Practical consequences" bullet list; inserting a new numbered section required
  renumbering the final section and was done by shifting `## 6. Practical consequences` to
  `## 7.` and adding the new `## 6.` before it. All existing `§N` cross-references in the file
  (`§2`, `§3`, `§5`) were checked after the edit and none pointed at the old `§6`, so no other
  cross-reference needed updating.
  - `lean/context/project/lean4/patterns/dependency-tracing.md` was read as the structural/style
  template for the new pattern file: numbered or lettered checklist items, each with a
  "Do this instead" command block and a concrete measured consequence drawn from a real
  assessment, closing with a "See Also" cross-reference section. The new file,
  `external-library-dependency-assessment.md`, follows the same shape.
- `core/context/formats/report-format.md` already documents a `## Carried-Figure Discipline`
  subsection with its own "Placement record" convention (stating why the rule lives in this one
  file rather than being duplicated); the new "Amending a Prior Verdict" subsection follows that
  same placement-record pattern implicitly by citing the `## Decisions` section as its home
  rather than introducing a third document.
- `core/context/standards/status-markers.md` was read and found to govern only task-lifecycle
  status markers (`[RESEARCHING]`, `[PLANNED]`, `[COMPLETED]`, etc.) — a different concept from
  a report's internal verdict (e.g. a NO-GO recommendation about an external dependency), so
  `report-format.md` was the better of the two homes the dispatch's Lesson 3 text offered
  ("report-format or status-markers standard").

### External Resources

None consulted; this is a meta task entirely about this repository's own context architecture
and a prior report's own findings. No WebSearch or WebFetch call was made.

## Recommendations

- No further action is required to "finish" these three lessons beyond what this dispatch
  performed: each is a complete, standalone addition to its target file.
- A future reader extending `metadata-trust-surfaces.md` further should keep the `§N`
  cross-reference discipline this edit preserved: grep for `§[0-9]` before adding or renumbering
  any section, since the file's own internal references are not auto-updated.
- A future `require` assessment of CSLib (or any other external Lean library) should use the new
  `external-library-dependency-assessment.md` checklist directly rather than re-deriving its
  five items from scratch, since each item names the specific command form that avoided a prior
  measurement error.

## Decisions

- **All three lessons were authored in the source store, never under `.claude/**`**, per
  `rules/source-store-deploy-boundary.md`; no redeploy was run or claimed, matching the
  dispatch's NON-GOALS.
- **Lesson 1 was placed as a new numbered section in `metadata-trust-surfaces.md` rather than as
  a bullet appended to the existing "Practical consequences" list**, because the gap named in
  the dispatch — `proof_wanted`'s distinct elaborate-and-discard semantics — is a standalone
  trust-surface finding on the same footing as the file's other five numbered sections (kernel
  invisibility, mutable registries, the `meta`-import flag, native-axiom naming, verified API
  locations), not a corollary of any one of them. A one-line cross-reference was added to
  "Practical consequences" instead, consistent with how that section already cross-references
  §2 and §3.
- **Lesson 2 was placed as a new file rather than as a section inside `dependency-tracing.md`**,
  because the dispatch's own recommendation names a specific new filename
  (`external-library-dependency-assessment.md`) and the two files answer different questions —
  `dependency-tracing.md` traces whether one declaration depends on another inside a single
  environment, while the new file assesses whether to adopt an external library at all. At
  authoring time, a "See Also" cross-link was added only from the new file to
  `dependency-tracing.md`, one direction only, because editing `dependency-tracing.md` itself
  was out of scope for this dispatch; the implementation phase of this same task added the
  reverse link to `dependency-tracing.md`, so the cross-link is bidirectional in its final
  state.
- **Lesson 3 was placed in `report-format.md`, not `status-markers.md`**, because the pattern it
  names — a verdict's *ground* being wrong while its *outcome* is preserved — is a property of
  how a report amends a prior report's reasoning, which is exactly the subject
  `report-format.md`'s `## Decisions` guidance already governs, whereas `status-markers.md`'s
  scope is task-lifecycle state transitions, a different kind of "status" than a report's
  internal verdict.
- **The source-store repository was not committed.** `git status --porcelain` in
  `~/.config/nvim/agent-system` showed numerous unrelated modified and untracked paths already
  present before this dispatch touched anything (other in-flight work in a shared repository),
  and this dispatch's contract is to author the three files, not to commit a shared repository
  on behalf of unrelated concurrent work. The BimodalLogic-side commit for this phase (via
  `skill-git-workflow`/postflight) covers this report and metadata file only.

## Risks & Mitigations

- **Risk: a future section renumbering in `metadata-trust-surfaces.md` could silently break a
  `§N` cross-reference this edit did not introduce.** *Mitigation*: this report records the
  grep-check performed (`§[0-9]` sweep, confirming no reference pointed at the old `§6`) so a
  future editor knows the check exists and should be repeated after any further renumbering.
- **Risk: Lesson 2's new pattern file could drift out of sync with `dependency-tracing.md`'s
  style if that file is revised later without updating this one.** *Mitigation*: the new file's
  "See Also" section names the specific shared technique (import-closure computation) so a
  future reader of either file is pointed at the other.
- **Risk: placing Lesson 3 in `report-format.md` rather than `status-markers.md` could be
  second-guessed by a future reader expecting it under "status".** *Mitigation*: this report's
  Decisions section states the reasoning explicitly (task-lifecycle status vs. report-internal
  verdict are different concepts), so the choice is traceable rather than silent.
- **Risk: the source-store repository's uncommitted state (pre-existing, unrelated to this
  dispatch) could be mistaken for this dispatch's own mess by a later reader of its `git
  status`.** *Mitigation*: this report names the specific three paths this dispatch touched
  there, distinguishing them from the pre-existing unrelated dirty paths this dispatch
  observed but did not create or touch.

## Context Extension Recommendations

None. This dispatch's entire content is filing three previously-identified context-extension
recommendations; it does not identify new ones.

## Appendix

### Commands run

```
# source_dir resolution
jq -r '.extensions | to_entries[] | "\(.key): \(.value.source_dir // "NONE")"' .claude-extensions.json

# locating existing target files and sibling pattern files
find lean -iname '*metadata-trust*'
find lean/context/project/lean4 -maxdepth 1 -type d
find core -iname 'report-format.md' -o -iname 'status-markers.md'

# cross-reference sweep after renumbering metadata-trust-surfaces.md
grep -n '§[0-9]' lean/context/project/lean4/domain/metadata-trust-surfaces.md

# style-register check for the no-record-versioning rule
grep -nE "task [0-9]+|no longer|previously|formerly|used to|carried forward from|supersedes|withdrawn" <each authored file>

# source-store dirty-state check before deciding not to commit there
cd ~/.config/nvim/agent-system && git status --porcelain
```

### References

- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md` — the report whose Context Extension Recommendations section this dispatch discharges
- `~/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/metadata-trust-surfaces.md` — edited for Lesson 1
- `~/.config/nvim/agent-system/extensions/lean/context/project/lean4/patterns/external-library-dependency-assessment.md` — new file for Lesson 2
- `~/.config/nvim/agent-system/extensions/core/context/formats/report-format.md` — edited for Lesson 3
