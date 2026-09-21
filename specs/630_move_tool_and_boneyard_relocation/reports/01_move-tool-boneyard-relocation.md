# Research Report: Task #630

**Task**: 630 - Move tool and Boneyard relocation
**Started**: 2026-09-20T00:00:00Z
**Completed**: 2026-09-20T00:00:00Z
**Effort**: Large (two deliverables: a new rewrite tool, and its first production use on a 225-file relocation touching 41 external citer files plus the invariant harness)
**Dependencies**: None blocking. Task 631 (deliverable hygiene) has no edge in either direction; tasks 632/633 depend on this one.
**Sources/Inputs**:
- Codebase: `scripts/check-module-invariants.sh` (4,375 lines), `scripts/lib/live_walk.py`, `scripts/boneyard-import-waivers.txt`, `lakefile.toml`, `FormalSystem/Boneyard/**` (225 tracked files)
- `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md`, `ADR-009-Boneyard-Retention.md`, `ADR-005-Single-Boneyard.md`
- `docs/development/PUBLICATION_REFACTOR.md` Phase 0 and Phase 2
- Measured baseline: `bash scripts/check-module-invariants.sh --no-build` (ALL CHECKS PASSED, exit 0)
- lean-lsp MCP: not used — this task contains no proof obligation and no Mathlib lemma search (see Tactic Survey Results)

**Artifacts**: - specs/630_move_tool_and_boneyard_relocation/reports/01_move-tool-boneyard-relocation.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The tree is green today and every precondition the move needs already holds.** Measured, not
  assumed: `--no-build` harness passes with zero FAIL; exactly one `Boneyard` directory exists
  repository-wide; all 169 archived `.lean` files carry `#exit`; zero live files import
  `FormalSystem.Boneyard.*`; zero `.olean` under any `Boneyard` path; C11 reports *539* archived
  import lines in *169* files, 8 waived. Three prose figures in the ADRs are stale against this
  (see Risks) and should be corrected in the same commit.
- **The rewrite surface is small and exactly enumerable.** Outside the archive, only **41 tracked
  files** carry `FormalSystem/Boneyard` or `FormalSystem.Boneyard` (20 `docs/`, 12 `FormalSystem/`,
  6 `scripts/`, 2 `typst/`, `ORGANISATION.md`). Inside the archive, 88 files carry archived
  `import FormalSystem.Boneyard.*` lines (178 of the 539 total import lines).
- **The dangerous class is the one that must *not* be rewritten.** 77 files outside the archive
  cite the archive in the *bare* form `Boneyard/Foo/Bar.lean` — currently relative to
  `FormalSystem/`, and *correct repo-root paths after the move*. Any rewrite rule keyed on the
  token `Boneyard` rather than on the prefix `FormalSystem/Boneyard` will corrupt all of them.
- **Relative links inside moved markdown must be re-based, not `../`-counted.** Simulated over all
  83 links in the archive's 56 markdown files: 76 resolve unchanged, 3 need one `../` *dropped*,
  and 2 need a `FormalSystem/` segment *inserted*. A single general algorithm (resolve against the
  old location → apply the path map → recompute relative to the new location) handles all three
  cases; a "strip one `../`" heuristic gets 2 of them wrong.
- **Six harness edits are hand edits, not tool output, and two of them are silent-gate-loss
  risks.** B0's search root, C11's scan root, C17's hardcoded archive path, `archive_dir_count()`'s
  root, plus widening C12's `slash_re` and C5's `mod_re` to admit `Boneyard`. Without the last two,
  40 C12-gated and 6 C5-gated citations silently fall out of gate scope the moment they lose their
  `FormalSystem/` prefix. Simulated: widening both turns nothing red.
- **A sorry-free, axiom-neutral change.** Nothing under the archive is compiled, so no `#print
  axioms` baseline, no declaration name and no proof is touched; the C2/C14/MainResults rewrite
  class the tool must implement is a *no-op for this particular mapping* and is exercised only by
  later programme phases. This is stated as a design requirement, not skipped.

## Context & Scope

Two deliverables, in order:

1. `scripts/move-modules.py` — a general module-relocation tool: old→new module mapping plus an
   optional namespace mapping, rewriting imports, dotted and slash path citations, namespace/open/
   FQN occurrences, the C2/C14 axiom baselines and `MainResults.lean`; with a dry-run mode; ending
   by running `bash scripts/check-module-invariants.sh --no-build`.
2. Its first production use: `FormalSystem/Boneyard/` → root-level `Boneyard/`, module names
   `FormalSystem.Boneyard.*` → `Boneyard.*`; B0 and C11 re-rooted; the two new invariants ADR-010
   names added; ADR-010 moved to **Accepted** and ADR-009's status pointer updated.

Acceptance (from the dispatch and `PUBLICATION_REFACTOR.md` Phase 2): `lake build` and
`lake build BimodalTest` exit 0; `check-module-invariants.sh` green; no `.olean` under `Boneyard/`;
the archive README's counts regenerate from the new location.

Out of scope: retiring `latex/` (task 631's Phase 1; ADR-010 decision 4 explicitly disclaims
dependence on it), the `BimodalTools` split (Phase 3), `mk_all --check` (Phase 8).

## Findings

### Measured baseline (all figures verified this dispatch)

| Fact | Value | How measured |
|---|---|---|
| Harness `--no-build` | exit 0, zero FAIL | `bash scripts/check-module-invariants.sh --no-build` |
| `Boneyard` directories repo-wide | 1 (`./FormalSystem/Boneyard`) | `find . -type d -name Boneyard -not -path './.git/*'` |
| Archived `.lean` files | 169 | `find FormalSystem/Boneyard -name '*.lean'` |
| Archived `.md` files | 56 | same, `-name '*.md'` |
| Tracked files under the archive | 225 | `git ls-files FormalSystem/Boneyard` |
| Top-level archive subtrees | 40 | `ls -d FormalSystem/Boneyard/*/` |
| Archived import lines (C11 scope) | 539, 8 waived | C11 output |
| …of which `import FormalSystem.Boneyard.*` | 178, across 88 files | grep |
| Archived files carrying `#exit` | 169 / 169 | grep |
| Live files importing `FormalSystem.Boneyard.*` | 0 | grep over `FormalSystem/`+`Tests/` |
| `.olean` under any `Boneyard` path | 0 | `find .lake -path '*Boneyard*' -name '*.olean'` |
| `Boneyard` in `lakefile.toml` / `FormalSystem.lean` | absent from both | grep |

### The external citer census (files to rewrite, excluding `specs/`)

41 tracked files outside the archive carry `FormalSystem/Boneyard` (slash) or
`FormalSystem.Boneyard` (dotted):

| Root | Files | Notes |
|---|---|---|
| `docs/` | 20 | incl. 5 relative markdown links into the archive (C13-gated) and 40 C12-gated slash paths |
| `FormalSystem/` | 12 | 7 slash occurrences in live `.lean` docstrings + live `README.md`s |
| `scripts/` | 6 | `check-module-invariants.sh`, `boneyard-import-waivers.txt` (comments only), `module-invariants-manifest.txt`, `check-copyright-headers.sh`, `check-metalogic-cycles.sh`, `typst-module-map.sh` |
| `typst/` | 2 | `chapters/p4-proof-automation.typ`, `SYNC-MAP.md` |
| root | 1 | `ORGANISATION.md` |

Plus `README.md`'s tree diagram, which shows `Boneyard/` nested under `FormalSystem/` and needs a
structural edit rather than a string substitution, and `.github/workflows/ci.yml`'s
`check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem` invocation, whose
`--exclude` becomes a harmless no-op (the archive leaves the scanned root entirely).

### The bare-`Boneyard/` class — the one that must be left alone

77 files outside the archive (and 37 inside it) cite the archive as `Boneyard/Foo/Bar.lean`, with
no `FormalSystem/` prefix: 76 occurrences in live `.lean` docstrings, 78 across markdown and typst.
These read today as paths relative to `FormalSystem/`; after the move they are *correct repo-root
paths*. They must be left byte-identical.

The consequence for the tool: its slash-rewrite rule is anchored on the full old prefix
(`FormalSystem/Boneyard` → `Boneyard`), never on the bare token. A rule of the shape
`s|Boneyard/|<new>/|` would corrupt 114 files. This is the single most likely way to get the move
wrong, and it is why the dry run must report *per-class* counts, not just a file list.

### Relative-link re-basing inside moved markdown (simulated)

Over all 83 markdown links in the archive's 56 `.md` files, resolving each from the post-move
location and mapping `Boneyard/*` back to disk:

| Outcome | Count | Example |
|---|---|---|
| Resolves unchanged | 76 | `BundleDeadHalf/README.md` (sibling-relative) |
| Needs one `../` dropped | 3 | `Boneyard/README.md` → `../../docs/architecture/ADR-009-…` becomes `../docs/…` |
| Needs `FormalSystem/` inserted | 2 | `Boneyard/Kamp/…/Hierarchy/README.md` → `../../../../../Metalogic/…` becomes `…/../FormalSystem/Metalogic/…` |
| Regex false positives (`](a)`) | 2 | not links |

**Required algorithm**: for every relative link in a file the mapping moves, resolve the target
against the *old* directory to a repo-relative path, apply the path mapping to that repo-relative
path, then recompute the relative path from the *new* directory. Counting `../` segments gets the
two `FormalSystem/`-insertion cases wrong in the direction that produces a silently broken link
(these links are outside C13's `docs/` + `README.md` scope, so no gate would catch the error).

### The nine generated inventory markers

`dir=FormalSystem/Boneyard…` appears in 9 `<!-- BEGIN GENERATED: inventory -->` markers (the
archive README twice, plus 7 subtree READMEs). These are ordinary slash-path rewrites, but
regeneration afterwards is mandatory: `--emit-inventory` must be re-run and `INV` re-checked, which
is exactly ADR-009 obligation 1 and the dispatch's "the archive README's counts regenerate from the
new location" acceptance clause.

### Harness edits (hand edits — explicitly NOT the tool's job)

The tool rewrites *citations*. The *check logic* is a separate, reviewed hand edit. Six sites:

| # | Site | Today | Required change |
|---|---|---|---|
| 1 | B0 search, `check-module-invariants.sh:689` | `find FormalSystem -type d -name Boneyard` | search from `.`, excluding `./.lake/*` and `./.git/*`; assert exactly 1 **and** that it is `./Boneyard` |
| 2 | B0 load-bearing half, `:698-704` | asserts `ALL_LEAN > LIVE_LEAN` under `FormalSystem/` | **inverts**: assert `find Boneyard -name '*.lean'` is non-zero **and** the `FormalSystem/` walk now finds zero archived files (`ALL_LEAN == LIVE_LEAN`) |
| 3 | C11 archive root, `:1136-1143` | `os.walk("FormalSystem")`, collecting dirs named `Boneyard` | root the scan at `Boneyard/`; same waiver file, same resolution rule |
| 4 | C17 archive occurrence scan, `:2877` | `os.walk(os.path.join("FormalSystem","Boneyard"))` | `os.walk("Boneyard")` |
| 5 | `archive_dir_count(root="FormalSystem")`, `:290-295` | counts under `FormalSystem/` | root at `.` with the same `.lake`/`.git` exclusions — otherwise the archive README's "Archive directories in the repository" row regenerates as **0** |
| 6 | C12 `slash_re` `:1322` and C5 `mod_re` (C5 block) | `FormalSystem\|Tests\|Logos\|Bimodal` / `FormalSystem\|BimodalTest` | add `Boneyard` to both — see next section |

`scripts/lib/live_walk.py` needs **no change**: it filters on the directory *name*, which ADR-010
decision 5 and ADR-005 both rely on, and the name does not change.

### Silent gate loss if C12/C5 are not widened (simulated)

- **C12**: 40 occurrences in `docs/` + `README.md` are gated today *because* they start
  `FormalSystem/`. Stripped of that prefix they stop matching `slash_re` and fall out of scope
  entirely. Simulated with `Boneyard` added to `slash_re`: all 40 resolve post-move, plus 2
  already-present bare occurrences — **0 new failures**.
- **C5**: 6 dotted `FormalSystem.Boneyard.*` occurrences in non-archive markdown are gated today;
  as `Boneyard.*` they stop matching `mod_re`. C5's `resolves()` already maps a leading non-
  `BimodalTest` component to the repo root, so `Boneyard.X` → `./Boneyard/X` resolves with no
  further change.
- **C4/C11 `imp_re`** (`:840`) matches only `FormalSystem|BimodalTest`. After the move, an archived
  `import Boneyard.*` line matches *nothing*, so C11 would stop counting the 178 rewritten lines
  and still report PASS on a shrunken denominator. Give C11 its own regex admitting `Boneyard`, and
  leave C4's alone — a live file importing `Boneyard.*` is the *new invariant's* failure, not a
  C4 resolution question.

**Denominator assertion**: C11 must continue to report 539 import lines across 169 files after the
move. A post-move C11 line reading anything less than 539 is the signature of this exact regression
and should be treated as a gate failure even though the check prints PASS.

### The two new invariants ADR-010 names

- **B1** — `Boneyard` appears nowhere in `lakefile.toml` and nowhere in the root aggregator
  `FormalSystem.lean`. Starts green (verified).
- **B2** — no live `.lean` under `FormalSystem/` or `Tests/` carries `import Boneyard.*`. Starts
  green (verified: 0 today, for the `FormalSystem.Boneyard.*` form).

Both are cheap greps and belong next to B0. Their headers must be added to the script's check list
(lines 7-91) and to `docs/development/MODULE_INVARIANTS.md`'s table, which also documents B0 and
C11 against the old location (lines 19, 30, 91, 320).

### `move-modules.py` design

**Inputs**

- `--module-map FILE`: lines `old.module -> new.module`. Entries are matched as **module prefixes**,
  longest first, so the archive move is a single line: `FormalSystem.Boneyard -> Boneyard`.
- `--namespace-map FILE` (optional): lines `Old.Ns -> New.Ns`, driving the `namespace` / `open` /
  FQN rewrite class. Empty for this move.
- `--dry-run`: report only.
- `--no-verify`: skip the closing harness run (for composing several maps).

**Derived path map.** Each module pair induces a path pair (`FormalSystem/Boneyard` → `Boneyard`),
which is what the slash-path, link-re-basing and `git mv` classes consume. Deriving it rather than
taking it as a second input is what keeps the two from drifting.

**Rewrite classes**, each separately counted in the dry-run report:

1. `import` lines in `FormalSystem/**`, `Tests/**` and the archive — anchored `^import <old>(\.…)?$`.
2. Dotted occurrences elsewhere: `\bFormalSystem\.Boneyard\b` → `Boneyard`, across `.lean`
   docstrings, markdown, `.typ`, `scripts/` (`.sh`, `.py`, `.txt`), `ORGANISATION.md`.
3. Slash paths: `\bFormalSystem/Boneyard\b` → `Boneyard`, same scope plus `.github/workflows/`.
   Anchored on the full old prefix — never the bare token (see the bare-`Boneyard/` finding).
4. `namespace` / `open` / FQN occurrences, when a namespace map is given. No-op here.
5. The C2 and C14 axiom baselines in `check-module-invariants.sh` and every `#print axioms` line in
   `FormalSystem/MainResults.lean`. No-op for this mapping (no live declaration changes namespace),
   but implemented and exercised by a unit-style dry run so Phase 3 and ADR-011's extraction can
   rely on it.
6. `git mv <old-path> <new-path>` for the tree itself.
7. Relative-link re-basing in every markdown file the mapping moves, by the resolve-map-recompute
   algorithm above.

**Exclusions**: `specs/**` (the historical record legitimately names old paths — C5, C9 and C10 all
exclude it), `.git/`, `.lake/`, `build/`.

**Closing step**: `bash scripts/check-module-invariants.sh --no-build`, exit code propagated.

**Constraints on the new file**: it lands under `scripts/`, which C9 scans for task-number
citations (zero permitted — also the repo-wide `no-task-references-in-deliverables` rule), and
`scripts/README.md` names every script in the directory, so it needs a row there.

## Decisions

- **Prefix mapping, not a 169-line enumeration.** One `FormalSystem.Boneyard -> Boneyard` line is
  auditable; a generated 169-row map is not, and would have to be regenerated whenever the archive
  gains a file.
- **The tool rewrites citations; the harness is hand-edited.** B0's inversion and C11's re-rooting
  are semantic changes to what is asserted, not string substitutions, and pretending otherwise
  would let the tool "fix" a gate to agree with whatever it just produced.
- **Bare `Boneyard/…` citations are left byte-identical.** They become correct by construction. The
  dry run must show a zero count for any rule that would touch them.
- **C12 and C5 are widened in the same commit as the move.** Deferring it leaves 46 citations
  ungated with a green board — the precise failure mode ADR-009 recorded for the archive's counts.
- **No sorry, no axiom, no new `axiom` declaration is involved anywhere in this task.** Nothing
  under the archive compiles; C2/C14 baselines are untouched by this mapping. The zero-debt gate is
  satisfiable in full.
- **Land independently of task 631.** ADR-010 decision 4 disclaims dependence on the frozen-LaTeX
  retirement, and `latex/` contains no `Boneyard` reference at all (verified: grep returns nothing).

## Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| A rewrite rule keyed on the bare token `Boneyard` | 114 files corrupted, 76 live docstring paths silently wrong | Anchor every rule on the full `FormalSystem/Boneyard` / `FormalSystem.Boneyard` prefix; assert a zero touch-count for bare-form occurrences in the dry run |
| C11's `imp_re` not widened | C11 prints PASS on a shrunken denominator; the archive rots unobserved | Assert the post-move C11 line still reads **539 import lines in 169 files, 8 waived** |
| C12/C5 not widened | 46 citations silently leave gate scope | Widen both; simulated to produce 0 new failures |
| `archive_dir_count()` left rooted at `FormalSystem` | Archive README regenerates "Archive directories in the repository" as 0, and `INV --check` goes red | Re-root at `.`; re-run `--emit-inventory` and diff |
| Relative links re-based by `../`-counting | 2 archive READMEs get silently broken links, outside C13 scope | Use resolve-map-recompute; spot-check the 5 known non-trivial links by hand after the move |
| `git mv` of 225 files done as a delete+add | Provenance lost, ADR-009 obligation 2 (durable anchors) weakened | Single `git mv` of the directory; verify with `git log --follow` on one archived file |
| Stale prose figures shipped alongside an accepted ADR | An accepted record that disagrees with the tree it describes | Correct in the same commit: ADR-009 says "168 archived files" / "536 archived import lines" / "7 waived" in its body and "49 recorded C11 waivers" in Related — the tree has **169**, **539**, **8**, and the waiver file has **8 entries**. ADR-010 says "538 archived imports", "169 modules", "48 live docstrings", "43 markdown files" — measured: **539**, **169**, **47** live `.lean` citers, **43** non-specs markdown citers |
| Concurrent sibling dispatch (task 626) on the same tree | Foreign edits mistaken for regressions | Per the dispatch territory note: re-read before editing, stage only this task's hunks, never `git add` a directory or glob |

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task contains no proof obligation: the archive
  is never compiled, the move changes module *names* only, and no declaration, proof or axiom
  baseline is touched. `lean_leansearch` / `lean_loogle` / `lean_state_search` have no goal to
  search against, and `lean_goal` / `lean_multi_attempt` have no proof position to query. The
  verification surface is `lake build`, `lake build BimodalTest` and
  `scripts/check-module-invariants.sh`, all of which were exercised or baselined directly.

## Context Extension Recommendations

- **Topic**: Mechanical repository-wide module relocation in a gated Lean tree.
- **Gap**: `context/project/lean4/` documents MCP tools, blocked tools and fallbacks, but nothing
  covers the pattern this task establishes — a citation-rewrite tool whose correctness depends on
  anchoring rules to a full old prefix, and whose gates must be widened in the same commit or
  silently lose scope.
- **Recommendation**: after `scripts/move-modules.py` proves itself on this move, add
  `context/project/lean4/patterns/module-relocation.md` recording the seven rewrite classes, the
  bare-form trap, the resolve-map-recompute link algorithm, and the
  "assert the denominator, not just the PASS" rule for re-rooted gates.

## Appendix

**Commands used (all read-only except the baseline harness run)**

```
bash scripts/check-module-invariants.sh --no-build            # green baseline, exit 0
find . -type d -name Boneyard -not -path './.git/*'           # 1
find FormalSystem/Boneyard -name '*.lean' | wc -l             # 169
git ls-files FormalSystem/Boneyard | wc -l                    # 225
grep -rl '^#exit' FormalSystem/Boneyard --include='*.lean'    # 169
grep -rn '^import FormalSystem\.Boneyard' FormalSystem Tests \
  --include='*.lean' | grep -v '/Boneyard/'                   # 0
find .lake -path '*Boneyard*' -name '*.olean' | wc -l         # 0
```

Three Python simulations were run against the current tree (C12 widening impact; C12-scope
`FormalSystem/Boneyard` post-move resolution; archive markdown link re-basing). Each resolved
candidate post-move paths by mapping `Boneyard/*` back onto `FormalSystem/Boneyard/*` on disk, so
no file was moved or modified.

**Key source anchors**

- `scripts/check-module-invariants.sh:689` (B0 search), `:698` (B0 load-bearing half),
  `:840` (`imp_re`), `:1136` (C11 archive roots), `:1322` (C12 `slash_re`), `:2877` (C17 archive
  walk), `:290` (`archive_dir_count`)
- `scripts/lib/live_walk.py:13` (`BONEYARD_DIR_NAME`) — unchanged by the move
- `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md:70-87` (the gate-change table)
- `docs/development/PUBLICATION_REFACTOR.md:283-322` (Phase 0 and Phase 2)
- `docs/development/MODULE_INVARIANTS.md:19,30,91,320` (B0/C11 documentation to update)
