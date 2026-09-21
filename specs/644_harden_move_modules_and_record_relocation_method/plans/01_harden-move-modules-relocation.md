# Implementation Plan: Harden move-modules and record relocation method

- **Task**: 644 - Harden move-modules and record relocation method
- **Status**: [IMPLEMENTING]
- **Effort**: 10.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/644_harden_move_modules_and_record_relocation_method/reports/01_harden-move-modules-relocation.md
- **Artifacts**: plans/01_harden-move-modules-relocation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false
- **Plan Version**: 2 (revision of the same-path v1; v1 is preserved in git history)
- **Reports Integrated**: 01_harden-move-modules-relocation.md

## Overview

`scripts/move-modules.py` is a 582-line one-shot relocation tool reused across five module moves,
each of which surfaced a distinct correctness gap caught by hand review or a dry run, never by a
gate. This plan closes the five named gaps as five independently fixture-tested changes to that
one file, builds the stdlib-only fixture harness those tests need (none exists anywhere under
`scripts/` today), and writes `docs/development/MODULE_RELOCATION.md` as the operational
playbook a future move reads first. Done means: every deliverable has a test that was observed
red before its change and green after; a dry run of the archived Expressiveness-extraction maps,
executed against an export of that move's own pre-move commit, reports exactly that move's 17
provenance READMEs (plus two ADRs and `typst/SYNC-MAP.md`) as skipped; and
`bash scripts/check-module-invariants.sh --no-build` is green.

### Revision Summary (v1 -> v2)

This is a forced re-plan round with no new research report. Every phase of v1 was
`[NOT STARTED]`, so nothing completed is at stake and the seven-phase structure, numbering and
wave order are kept. The revision is a verification pass: each load-bearing claim in v1 was
checked against `scripts/move-modules.py` and against the archived move it proposes to replay.
Four v1 claims did not survive, and each is a defect an implementer would have hit mid-phase:

1. **v1's move-set predicate (Decision D7) is wrong for file-granular rows.** `map_repo_path`
   compares a path against the extension-free stem `old` and `old + "/"`, so for a file-granular
   row it never recognises `old + ".lean"`. Measured:
   `map_repo_path("FormalSystem/Metalogic/WeakCanonical/NormalForm.lean")` returns its input
   unchanged under the row that moves exactly that file. Under v1 the refusal check would have
   named the moved file itself as an "outside the move set" offender — on precisely the
   file-granular shape of the tooling-library split that motivated deliverable (4). Fixed in D7.
2. **v1's refusal rule (Decision D6) refuses the Expressiveness extraction's own, correct
   namespace map.** At that move's pre-move commit, 67 archived `.lean` files under `Boneyard/`
   declare `namespace FormalSystem.Metalogic.WeakCanonical.Kamp...` and 16 declare
   `...WeakCanonical.Separation...`, all outside the move set; today all 83 declare the new
   namespace and none the old, so renaming them was the accepted outcome. They were renamed by
   class 2, not class 4: the replay reports `class 4 namespace/open/FQN 0 occurrence(s)` because
   a namespace that coincides with a moved module prefix is consumed by the dotted-citation
   rewrite first. A refusal keyed on "a declaration of the old prefix exists outside the move
   set" is therefore a false positive exactly where class 4 rewrites nothing. D6 is re-keyed on
   what class 4 would actually rewrite.
3. **v1's Phase 7 replay cannot demonstrate the acceptance criterion.** v1 replays on the
   current tree and enumerates "the 17 specific paths from the archived summary". The summary
   does not enumerate them, and on the current tree only 16 `Boneyard/**/README.md` files still
   cite the old prefixes (one lost its citations when four present-tense lines were hand
   re-applied). At the pre-move commit the figure is exactly 17. Phase 7 now replays there,
   which also removes v1's awkward "the replay is expected to exit non-zero" carve-out: at that
   commit all 13 rows resolve and the run exits 0.
4. **The archived move's real map files exist** (`module-map.txt`, `namespace-map.txt` in the
   archived task directory, and in-tree at the pre-move commit), so nothing needs to be
   "reconstructed from the summary".

Four smaller tightenings: a `--no-rewrite` / class 7 interaction v1 left undefined (D8); the
identical-sides detector's placement and pair semantics pinned so the sentinel re-run cannot
double-fire it (D9); class counts defined to exclude skipped files so deliverable (5)'s
moved-vs-rewritten line stays honest (D10); and the aggregator-layout consequence of deliverable
(3) recorded as a risk with its known remedy (R8).

### Research Integration

Newly integrated in this revision: none (no report is newer than v1). The one report remains
integrated as follows, with revision-time corrections marked:

- **Path correction adopted.** The task description's default `--no-rewrite` entry `docs/adr/**`
  is wrong for this repository: `docs/adr/` does not exist and ADRs live at
  `docs/architecture/ADR-*.md` (nine files: `ADR-001` and `ADR-004` through `ADR-011`; plus four
  non-ADR siblings: `README.md`, `BFMCS_ARCHITECTURE.md`,
  `total-history-validity-decisions.md`, `untl-snce-argument-order.md`). Phase 4 uses the narrower `docs/architecture/ADR-*.md` glob, so
  the non-ADR siblings stay rewritable.
- **Deliverables (3) and (5) merged into one phase** (Phase 3): both are edits to
  `resolve_move`/`move_trees`/`run`'s exit logic and `report`.
- **Recommendation 3 adopted**: deliverable (2)'s check stays wholly separate from the existing
  bare-form audit (`bare_form_count`, the sentinel re-run at `move-modules.py:495-500`).
- **Recommendation 4 resolved explicitly** (Decision D2), with the backstop's limits now stated.
- **Recommendation 5 adopted** (Phase 6): `--namespace-paths` takes an explicit user-supplied
  path/glob list rather than inferring the moved-file set through `resolve_move`.
- **Recommendation 6 adopted** (Phase 2): `MODULE_RELOCATION.md` is a synthesis of six existing
  sources, not fresh prose.
- **Recommendation 7 adopted**: the harness's C9-DOCS check already gates `docs/**/*.md` for
  task-number citations, so one `--no-build` invocation discharges both acceptance criteria.
- **Testing-infrastructure finding acted on** (Phase 1): a disposable
  `tempfile.TemporaryDirectory()` git repo, chosen over subprocess stubbing.
- **Revision-time correction to the report's Finding (c)**: the report treats the residual
  namespace problems as class-4 problems. The replay shows the archived-file namespace renames
  arrive through class 2 whenever namespace and module prefix coincide. This does not change the
  deliverable, but it changes D6 and adds one item to the playbook (Phase 2).

### Prior Plan Reference

v1 of this same file (same path, same artifact round; recoverable with
`git log -- specs/644_harden_move_modules_and_record_relocation_method/plans/`). v1 was never
executed: all seven phases were `[NOT STARTED]`. Carried over unchanged: Phase 1's harness design,
Phase 2's nine method items, Phase 4's glob translator, Decisions D1-D5, Risks R1-R7. Changed:
D6, D7, Phase 6's tests and tasks, Phase 7's replay; added D8-D10 and R8-R9.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no ROADMAP.md was consulted.

## Goals & Non-Goals

**Goals**:

- A `--no-rewrite` path list (repeatable file/glob argument) with the built-in defaults
  `Boneyard/**/README.md`, `typst/SYNC-MAP.md`, `docs/architecture/ADR-*.md`; matching files are
  walked and reported but never written.
- A warning whenever a rewrite makes the two sides of one sentence or one table row identical,
  promoted to a non-zero exit under a new `--strict` flag.
- `resolve_move` failing loudly, naming both paths, when a mapping stem resolves to BOTH a
  directory and a same-named `.lean` file — before anything is written, and again per mapping at
  move time.
- `--namespace-map` refusing a row that would rewrite a `namespace` declaration in a file outside
  the move set, printing every offending file, plus a `--namespace-paths` flag to scope class-4
  rewrites.
- A report that states files actually moved next to citations rewritten, and a non-zero exit when
  rows were requested and zero files moved.
- `docs/development/MODULE_RELOCATION.md` recording the nine method items the task enumerates.
- A stdlib-only fixture harness at `scripts/test-move-modules.py` with one red-before/green-after
  test per deliverable, plus a history-gated replay test.

**Non-Goals**:

- Detecting the *inverse* error — stale present-tense citations the bare-form exclusion leaves
  untouched (ten were found by hand in the Expressiveness extraction, including the root
  `README.md`). `--no-rewrite` suppresses false-positive rewrites only. Phase 2's doc states this
  limitation explicitly rather than implying the flag is a complete fix.
- Any semantic or tense-aware understanding of prose. Deliverable (2) is a syntactic
  before/after comparison, not a historical-statement detector.
- Scoping or refusing class 2. A namespace that coincides with a moved module prefix is rewritten
  by the dotted-citation class wherever it appears, including in archived files; that is
  module-citation semantics the tool performs correctly today. The playbook records it; the tool
  is not changed for it.
- A way to move a directory and its same-named aggregator `.lean` file in one row. Deliverable
  (3) asks for a refusal, not a new mapping syntax (see R8 for the remedy).
- Running `move-modules.py` in apply mode against this repository at any point in this task.
  Apply mode runs only inside temp fixtures; the Phase 7 replay is `--dry-run` in a scratch
  export.
- Adding a pytest, tox, or third-party test dependency. The harness is stdlib `unittest` only.
- Introducing an override flag for the new zero-move exit (see R3).
- Editing `scripts/check-module-invariants.sh`, `scripts/reanchor-lean-citations.py`,
  `docs/development/MODULE_INVARIANTS.md`, or `docs/development/REFERENCE_NORMAL_FORM.md` — all
  four are a concurrent sibling task's declared territory (see Territory below).
- Extending `scripts/README.md`'s scope beyond the single row Phase 1 adds.

## Territory

**Declared file scope for this task** (every file any phase below writes):

- `scripts/move-modules.py`
- `scripts/test-move-modules.py` (new)
- `scripts/README.md` (one row added)
- `docs/development/MODULE_RELOCATION.md` (new)
- `docs/development/README.md` (one row added)

The task's `file_scope` in `specs/state.json` currently names only the first, third and fourth of
these. `scripts/test-move-modules.py` and `docs/development/README.md` are additions this plan
makes; neither overlaps any sibling's declared scope in this dispatch's territory block.

**Do NOT touch** (concurrent sibling territory, confirmed from this dispatch's territory block):

- `scripts/check-module-invariants.sh`, `scripts/reanchor-lean-citations.py`,
  `docs/development/MODULE_INVARIANTS.md`, `docs/development/REFERENCE_NORMAL_FORM.md` — a sibling
  that is in its IMPLEMENT phase this cycle, so these files may change under this task's feet.
  `MODULE_RELOCATION.md` may *cite* `MODULE_INVARIANTS.md` (by filename and by gate ID such as
  C11/C25) but must never edit it.
- `scripts/module-invariants-manifest.txt`, `scripts/check-copyright-headers.sh`, `ORGANISATION.md`,
  `CLAUDE.md`, `FormalSystem/FormalSystem.lean`, `.syncprotect`, `.gitattributes` — another
  sibling's scope.
- Every `FormalSystem/**/README.md` and `typst/chapters/p4-dataset-pipeline.typ` — a third
  sibling's scope.

Per the dispatch's concurrency note: re-read any shared file immediately before editing it, stage
only this task's own hunks with an explicit file list (never a directory or glob `git add`), and
never run `git-snapshot.sh` in its reverting default mode.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| R1: the `--no-rewrite` default list silently suppresses a rewrite a future move genuinely needs | M | H | Every skipped file that would have been rewritten is listed by path in the report, so the omission is visible in the dry run; Phase 2's doc states hand-review of the skipped list remains mandatory. Measured on the replay: 66 files match the defaults, 20 of them carry would-be rewrites |
| R2: deliverable (2)'s detector false-positives on a line whose two sides were already identical before the rewrite | M | M | D9: warn only when the two sides differed before and match after |
| R3: the new zero-move exit breaks a legitimate workflow (e.g. re-running a map whose rows already moved) | M | M | Accepted deliberately: a zero-move run is always worth investigating. No override flag (explicit Non-Goal). Documented in `MODULE_RELOCATION.md` and in `--help`. A second-pass rename map composed with `--no-verify` still moves files, so that workflow is unaffected |
| R4: hand-rolled `**` glob translation gets an edge case wrong (`fnmatch` matches `/` with `*`; `PurePath.match` handles `**` inconsistently across versions) | M | M | Phase 4 implements one explicit translator with dedicated unit tests, reused verbatim by Phase 6's `--namespace-paths`. The translator semantics in Phase 4 were exercised during this revision and reproduce the 17/2/1 split exactly |
| R5: a pre-existing harness redness is misattributed to this task at Phase 7 | L | H | Phase 1 captures a baseline `--no-build` result BEFORE any change. Likelihood raised from v1: a sibling is editing the harness itself this cycle, so redness may be the sibling's in-flight edit — check `git log -- scripts/check-module-invariants.sh` before attributing it |
| R6: `--namespace-paths` scoping breaks the external citation rewriting the tool currently and correctly performs (e.g. `open BimodalTools` at external sites) | H | M | The flag is opt-in and user-supplied; when absent, class-4 behavior is byte-identical to today. Class 5 axiom baselines are never scoped out (D5). Phase 6's negative fixture test asserts the no-flag path is unchanged |
| R7: six phases edit one 582-line file, so a later phase silently reverts an earlier one | M | M | Phases 3-6 are strictly sequential (one per wave), and each phase's first task is re-reading `move-modules.py` in full; every phase re-runs the whole fixture suite |
| R8: deliverable (3)'s refusal fires on the most common subtree shape. Lean's aggregator layout puts `Foo.lean` beside `Foo/`; this repository has 41 such pairs today (e.g. `FormalSystem/Metalogic`, `FormalSystem/Metalogic/WeakCanonical`, `FormalSystem/Metalogic/Decidability`). A row naming any of them will now be refused, where before it silently moved the directory and orphaned the file | M | H | This is the intended trade (a loud refusal replaces a silent orphan), but the refusal text must carry the remedy or it is a dead end: split the directory's contents into child rows in a first invocation, remove the emptied directory, then move the aggregator file in a second invocation — the sequence the language-directory merge used. Phase 3 puts that remedy in the error text; Phase 2 records it in the playbook |
| R9: the Phase 7 replay depends on a commit (`3419bdb8d`) that a shallow clone or a future history rewrite may not contain | L | L | The permanent replay test is gated with `unittest.skipUnless` on `git cat-file -e`; the one-time acceptance run in Phase 7 is performed in this working clone, where the commit is present |

## Design Decisions

Fixed here so Phases 3-6 do not re-litigate them. D1-D5 are unchanged from v1; D6 and D7 are
replaced; D8-D10 are new.

- **D1 — flag names**: `--no-rewrite`, `--strict`, `--namespace-paths`. Phase 2's doc may name
  these before they exist because this plan pins them.
- **D2 — resolve_move ambiguity check runs twice**: once up front over every mapping against the
  pre-move tree (before any file is written, so no citation is rewritten for a move that will
  fail), and once per mapping at its own resolution point inside `move_trees`. Both name both
  offending paths. **Stated limits of the second check**: it can only fire in apply mode (a dry
  run moves nothing, so inter-row ambiguity never materialises on disk), and when it fires the
  citation writes have already happened. It is a loud backstop, not a guarantee; the up-front
  scan is the check that protects a dry run. The known historical incident is the up-front case.
- **D3 — `--no-rewrite` values ADD to the built-in defaults**; they never replace them. A file on
  the default list can only be rewritten by hand. No "clear the defaults" flag is added.
- **D4 — skipped files are excluded from the bare-form audit accounting entirely.** No write
  happens to them, so a before/after delta for them is vacuous and would only add noise.
- **D5 — `--namespace-paths` does not scope class 5.** The two axiom-baseline sites pin
  fully-qualified names as DATA and must always track a namespace rename.
- **D6 (replaced) — the refusal is keyed on what class 4 would actually rewrite.** A
  namespace-map row is refused when the class-4 step, applied after classes 1-3 exactly as
  `rewrite_text` orders them, would change a line that is a `namespace` DECLARATION
  (`^\s*namespace\s`) in a file outside the move set (and, when `--namespace-paths` is given,
  inside the scope — class 4 does not run elsewhere). The mere existence of a declaration of the
  old prefix outside the move set is NOT sufficient: if class 2 has already rewritten that line
  because the namespace coincides with a moved module prefix, class 4 changes nothing there and
  there is nothing to refuse. A file that merely *cites* the old prefix (`open`, FQN) is a
  legitimate rewrite site and never an offender. `end` lines are not checked separately: they
  carry the same name as their `namespace` line and cannot be rewritten without it.
- **D7 (replaced) — the move set is a pure path predicate that handles both row granularities.**
  `in_move_set(path, mappings)` is true when `map_repo_path(path, mappings) != path` OR
  `path == m.old_path_slash + ".lean"` for some mapping `m`. `map_repo_path` alone misses every
  file-granular row (measured). The second clause is safe: if the stem is a directory only, no
  `stem + ".lean"` exists; if both exist, D2's up-front scan has already refused the run. The
  predicate stays independent of `resolve_move` and of filesystem state, so it is available
  inside the walk loop without reordering `run()`. `map_repo_path` itself is NOT changed — class
  7 depends on its current behavior and only ever passes it `.md` paths.
- **D8 (new) — `--no-rewrite` suppresses class 7 too, and says so.** "Never rewritten" means no
  write of any class. A no-rewrite file that is itself inside the move set therefore keeps
  relative links computed for its old directory. The report lists such files under their own
  heading ("skipped AND moved: relative links not re-based") so the hand fix is visible. On the
  replay this list is empty (measured), so the case is covered by a fixture test, not by history.
- **D9 (new) — the identical-sides detector lives in `run()`, not in `rewrite_text`, and runs
  only over files that will be written.** `rewrite_text` is called twice per file (the real pass
  and the sentinel re-run), so a detector inside it fires twice or needs a guard; `run()` has the
  before and after texts side by side and `rewrite_text` is line-preserving, so lines are zipped
  by index. Skipped (`--no-rewrite`) files are excluded — nothing is written to them, and a
  `--strict` failure over a file the tool refuses to touch would be a false alarm. Pair
  semantics: extract side strings from the BEFORE line; warn when `a != b` and
  `rw(a) == rw(b)`, where `rw` applies the same per-line rewrite (classes 2-4, throwaway
  counters) to the side text in isolation. This avoids aligning tokens between the two lines.
  Sides come from two constructs only: (i) two name-shaped tokens (containing `/` or `.`,
  optionally wrapped in backticks or quotes) joined by one of the closed connector set
  ` to `, ` into `, `->`, `→`, `=>`; (ii) a markdown table row (line begins with `|`), every
  unordered pair of non-empty cells — all pairs, not adjacent cells, because the provenance
  tables that motivated this put the two path columns apart.
- **D10 (new) — class counts exclude skipped files.** A skipped file's would-be rewrites are
  computed with a throwaway counter and reported only in the skipped section. Otherwise
  deliverable (5)'s "citations rewritten" figure would count rewrites that never happen.

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 2, 6 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint file sets
(`scripts/` versus `docs/development/`). Phases 3-6 all edit `scripts/move-modules.py` and are
therefore strictly serialized.

---

### Phase 1: Fixture harness scaffolding [COMPLETED]

**Goal**: A stdlib-only test harness at `scripts/test-move-modules.py` that can build a
disposable git repo, invoke `move-modules.py`'s `run()` in process, capture stdout/stderr, and
assert on both the return code and the report text — with one baseline test that passes against
today's unmodified tool.

**Tasks**:

- [x] Capture a baseline `bash scripts/check-module-invariants.sh --no-build` result before any
      change and record the outcome (green/red, and which checks if red) in the progress file,
      together with `git log -1 --format=%h -- scripts/check-module-invariants.sh`, so Phase 7 can
      tell this task's redness from a sibling's in-flight harness edit (R5). *(completed)*
- [x] Create `scripts/test-move-modules.py` using stdlib `unittest` only; runnable as
      `python3 scripts/test-move-modules.py`. *(completed)*
- [x] Load the tool with `importlib.util.spec_from_file_location("move_modules", <abs path>)` —
      the hyphen in the filename makes a plain `import` impossible. Resolve the absolute path
      from `__file__` at import time, BEFORE any `os.chdir`, and keep the repository root in a
      module-level constant for Phase 7's replay test. *(completed)*
- [x] Implement a `fixture_repo(files: dict[str, str])` context manager: `tempfile.TemporaryDirectory()`,
      write each file (creating parents), `git init -q`, `git -c user.email=... -c user.name=... add`
      + `commit -q`, `os.chdir` in and restore the original CWD on exit (in a `finally`). `run()`
      walks `.` and `move_trees` shells out to `git mv`, so a real git repo at the CWD is required. *(completed)*
- [x] Implement a single centralized `run_tool(**overrides) -> tuple[int, str, str]` helper that
      builds the `argparse.Namespace` with every current flag defaulted
      (`module_map`, `namespace_map=None`, `dry_run=False`, `no_verify=True`) and captures output
      via `contextlib.redirect_stdout`/`redirect_stderr` around `move_modules.run(args)`. It must
      catch `SystemExit` and translate it into a return code plus the message on stderr —
      `parse_map` reports a malformed map with `sys.exit(str)`. Every later phase adds its new
      flag's default in this one place. *(completed)*
- [x] Add a `write_map(lines)` helper producing a temporary `old -> new` mapping file OUTSIDE the
      fixture repo's walked tree (a second temp directory), so a map file is never itself a
      rewrite or detector target. *(completed)*
- [x] Add a `snapshot(paths)` helper returning `{path: bytes}` for byte-identity assertions; four
      later tests assert "nothing was written". *(completed)*
- [x] Add one baseline smoke test: a fixture with `FormalSystem/Foo/Bar.lean`, a citing
      `docs/x.md` (dotted and slash forms) and a citing `FormalSystem/Other.lean` import line;
      assert `rc == 0`, non-zero class 1/2/3 counts in the report, and the file actually moved. *(completed)*
- [x] Add the `test-move-modules.py` row to `scripts/README.md` (that file states every script
      under `scripts/` is named in it), next to the existing `move-modules.py` row. *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts it adds exactly one new file plus one `scripts/README.md`
row. Confirm with `git status --short -- scripts/` before committing: exactly two paths, and
`scripts/move-modules.py` must NOT appear. (Other tasks' paths may be dirty elsewhere in this
shared tree; scope the check to `scripts/`.)

**Files to modify**:

- `scripts/test-move-modules.py` - new; fixture harness plus the baseline smoke test
- `scripts/README.md` - one row describing the new test file

**Verification**:

- `python3 scripts/test-move-modules.py` exits 0 with the baseline test passing.
- No change to `scripts/move-modules.py` in this phase's diff.
- The temp directory is removed and the original CWD restored even when a test fails (assert by
  running the suite twice in a row from the repository root).

---

### Phase 2: docs/development/MODULE_RELOCATION.md [NOT STARTED]

**Goal**: The relocation playbook exists, synthesized from the six existing sources rather than
drafted fresh, and is reachable from the development documentation index.

**Tasks**:

- [ ] Create `docs/development/MODULE_RELOCATION.md` with sections covering, in this order:
  - [ ] **The seven rewrite classes** — summarize at playbook level and point to
        `scripts/move-modules.py`'s module docstring as the executable source of truth; do not
        let the class numbering drift from the code's. Include the ordering fact this revision
        measured: classes run 1, 2, 3, then 4 on each line, so a namespace that coincides with a
        moved module prefix is rewritten by class 2 — everywhere, including archived files — and
        class 4 then finds nothing. `--namespace-map` is needed only where namespace and module
        prefix differ, and `--namespace-paths` cannot scope what class 2 does.
  - [ ] **The bare-form trap** — why every rule is anchored on the full old prefix and why a
        bare-form citation must survive byte-identical.
  - [ ] **Resolve-map-recompute for relative links** — resolve against the old directory, apply
        the path mapping, recompute from the new directory; never `../`-counting.
  - [ ] **Assert the denominator** — a re-rooted counting gate can PASS on a shrunken scan set;
        cite `MODULE_INVARIANTS.md`'s C11 row and the carried pre-move figure practice.
  - [ ] **Widen every gate's scan root BEFORE the move** so each widening is a verifiable no-op,
        with the atomicity argument: widened first, pre-existing bare citations enter scope while
        the subtree is still at its old location where they do not resolve; moved first,
        citations silently leave scope with a green board. Neither ordering is green alone, so the
        two steps are atomic.
  - [ ] **Re-rooting a gate to a top-level directory narrows what a path-shaped pattern can
        match** — neither a path-shaped nor a module-shaped pattern gates a bare top-level name;
        a directory outside the layer map makes every import into or out of it invisible to the
        upward-edge measurement.
  - [ ] **Exe roots sit outside every build closure** — only the build-inclusive harness (C25)
        catches a broken one; a library build, `lake build` and `lake test` can all be green while
        exe roots do not compile.
  - [ ] **A namespace-audit simulation must precede any directory merge** — name
        `scripts/measure-refactor-partitions.py namespace-audit` as the pre-merge step to run
        *before* committing to a directory-merge module map, not only as post-move verification;
        record the paths-only-merge hazard (a merge that would have moved unrelated files into the
        wrong bucket).
  - [ ] **The historical-statement blind spot** — the tool cannot tell a citation of a module's
        current location from a historical statement about its old one; give the operative test
        ("does the sentence assert something about the past? a provenance column, an 'original
        location', a 'used to be', a dated audit stamp — historical, revert; a navigational link,
        a 'the live tree keeps' — present tense, update"); state the INVERSE error explicitly
        (stale present-tense citations the bare-form exclusion skips, found by hand review only);
        state that `--no-rewrite` addresses the false-positive half only and hand review of the
        skipped list remains mandatory.
  - [ ] **Moving a directory that has an aggregator file** — `Foo.lean` beside `Foo/` is the
        normal Lean layout and the tool refuses a row whose stem names both. Record the remedy:
        child rows first, remove the emptied directory, then the aggregator row in a second
        invocation (R8).
  - [ ] **Tooling** — name `--no-rewrite` (with its three built-in defaults and ADD semantics),
        `--strict`, `--namespace-paths`, the namespace-declaration refusal and what it does NOT
        refuse (D6), and the zero-move non-zero exit, per Decisions D1-D10 above.
  - [ ] **Pre-move checklist** — an ordered, runnable sequence ending in a dry run and a hand
        review of the skipped list.
- [ ] Cite only durable anchors — filenames, section headings, ADR names, gate IDs (C11, C25).
      **No task numbers anywhere in this file**, and no archived task-directory names (they
      embed a number): `check-module-invariants.sh`'s C9-DOCS check fails the harness on any
      task-number citation under `docs/`. Refer to past moves by what they moved ("the
      Expressiveness extraction", "the tooling-library split", "the language-directory merge",
      "the archive relocation").
- [ ] Add a `MODULE_RELOCATION.md` row to `docs/development/README.md`'s "Project Organization"
      table, alongside `MODULE_ORGANIZATION.md` and `MODULE_INVARIANTS.md`.
- [ ] Verify every relative link in the new file resolves from `docs/development/`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: prose

**Files to modify**:

- `docs/development/MODULE_RELOCATION.md` - new; the nine method items plus the aggregator
  remedy, Tooling and checklist
- `docs/development/README.md` - one row in the "Project Organization" table

**Verification**:

- `bash scripts/check-module-invariants.sh --no-build` is green, or no redder than Phase 1's
  baseline (this covers C9-DOCS's task-number gate and the markdown link checks).
- Every one of the nine enumerated method items has its own heading in the file.
- `grep -nE '[Tt]asks?[ _#-]+[0-9]+' docs/development/MODULE_RELOCATION.md` returns nothing.

---

### Phase 3: Move-set integrity — resolve_move ambiguity and the zero-move exit [NOT STARTED]

**Goal**: Deliverables (3) and (5). A mapping stem that resolves to both a directory and a
same-named `.lean` file fails loudly naming both, before anything is written; and the report
states files moved next to citations rewritten, with a non-zero exit when rows were requested and
zero files moved.

**Tasks**:

- [ ] Re-read `scripts/move-modules.py` in full before editing (a sibling task may have touched
      the tree).
- [ ] Write the fixture tests FIRST and observe them red against the unmodified tool; record the
      red output in the progress file:
  - [ ] Ambiguity: fixture containing both `FormalSystem/Syntax/Lang/` (a directory with one
        child module) and `FormalSystem/Syntax/Lang.lean`, with a map row
        `FormalSystem.Syntax.Lang -> ...`. Run in APPLY mode. Assert `rc != 0`, both paths named
        in stderr, the remedy sentence present, and — critically — every file byte-unchanged and
        nothing moved (nothing is rewritten for a move that will fail).
  - [ ] Zero moves: fixture whose map row's stem does not exist on disk but whose citations do.
        Assert `rc != 0`, a non-zero class 2/3 count, `0 path(s)` for class 6, and the presence of
        the new moved-vs-rewritten report line.
- [ ] Change `resolve_move` to signal ambiguity rather than silently preferring the directory:
      when `os.path.isdir(stem)` AND `os.path.isfile(stem + ".lean")` both hold, report the
      ambiguity naming both paths. Keep the existing directory-only and file-only branches
      unchanged. Do not use a bare `sys.exit` inside `resolve_move`; signal via a dedicated
      exception that `run`/`move_trees` translate into a non-zero return, so library-style
      callers get a return code. Update `resolve_move`'s docstring: its last sentence ("The
      directory is preferred when both somehow exist") becomes false.
- [ ] Per Decision D2, add an up-front ambiguity scan over every mapping at the top of `run()`,
      before the walk loop, returning non-zero immediately; and keep a per-mapping check at each
      mapping's own resolution point inside `move_trees` as the backstop, counted as a move
      failure. Put D2's stated limits in a code comment at the backstop.
- [ ] Make the refusal text actionable (R8): name both paths, state that `Foo.lean` beside `Foo/`
      is the normal aggregator layout, and give the remedy in one sentence.
- [ ] Add a moved-vs-rewritten line to `report()`: files actually moved stated next to the total
      citation-rewrite count (classes 1-5 summed), as one line, so the two figures cannot be read
      apart.
- [ ] Add the zero-move branch to `run()`'s exit logic: mappings are always non-empty
      (`parse_map` exits on an empty file), so the condition is simply "`moved` is empty" — and
      `moved` is populated in dry-run mode too, so the branch is dry-run-safe. Print a named
      failure line to stderr explaining that rows were requested and nothing moved. Place it
      alongside the existing `bare_before != bare_after` and `move_failures` branches, not folded
      into them.
- [ ] Re-run the fixture suite and observe green; confirm Phase 1's baseline smoke test still
      passes.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:

- `scripts/move-modules.py` - `resolve_move` (and its docstring), `move_trees`, `run`, `report`
- `scripts/test-move-modules.py` - two new fixture tests

**Verification**:

- Both new tests observed red before the change and green after (record both outputs).
- `python3 scripts/test-move-modules.py` exits 0.
- The ambiguity test runs in apply mode and asserts byte-unchanged files, proving the up-front
  scan runs before the write loop.

---

### Phase 4: Deliverable (1) — the --no-rewrite path list [NOT STARTED]

**Goal**: A repeatable `--no-rewrite` file/glob argument, plus the three built-in defaults, whose
matching files are walked and reported but never written.

**Tasks**:

- [ ] Re-read `scripts/move-modules.py` in full before editing.
- [ ] Write the fixture tests first and observe red:
  - [ ] A fixture containing `Boneyard/X/README.md` whose body carries a historical statement
        ("moved from `FormalSystem/Old` to `FormalSystem/New`") plus an ordinary citing file.
        Run in APPLY mode (not dry-run) and assert the Boneyard README is byte-identical
        afterwards, that it appears by path in the report's skipped listing, and that the ordinary
        file WAS rewritten.
  - [ ] Count honesty (D10): in the same fixture, assert the class 2/3 counts equal the ordinary
        file's citations only, and that the skipped section carries the README's would-be count.
  - [ ] Class 7 interaction (D8): a fixture whose map moves a directory containing a `README.md`
        that a user-supplied `--no-rewrite` glob matches and that holds a relative link. Assert
        the file is moved, byte-identical, and listed under the "skipped AND moved" heading.
  - [ ] Unit tests for the glob translator covering `Boneyard/**/README.md` (matching at depth 1
        and deeper, and `Boneyard/README.md` at depth 0), `typst/SYNC-MAP.md` (exact),
        `docs/architecture/ADR-*.md` (matching `ADR-010-...md` but NOT `README.md` or
        `BFMCS_ARCHITECTURE.md` in the same directory), and a `*` that must not cross a `/`.
- [ ] Implement one explicit glob-to-regex translator: `**/` becomes `(?:.*/)?`, `*` becomes
      `[^/]*`, `?` becomes `[^/]`, everything else is escaped; anchor with `^...$` and match
      against the forward-slash repo-relative path `rel()` already produces. Do NOT use `fnmatch`
      (its `*` crosses `/`) or `PurePath.match` (inconsistent `**` handling across versions). Keep
      the translator a standalone module-level function — Phase 6 reuses it verbatim.
- [ ] Add `--no-rewrite` as `action="append"`, repeatable, taking a path or glob. Per Decision D3,
      supplied values ADD to the built-in default list `Boneyard/**/README.md`,
      `typst/SYNC-MAP.md`, `docs/architecture/ADR-*.md` (note: `docs/architecture/`, not the
      non-existent `docs/adr/`). Document the ADD semantics in the flag's help text. Read the
      flag with `getattr(args, "no_rewrite", None) or []` so a caller-built `Namespace` without it
      still works.
- [ ] In `run()`'s walk loop, still compute what the rewrite WOULD change for a matching file —
      with throwaway `counts`/`files` dicts (D10) and skipping class 7 (D8) — so the report can
      state the file count and how many carried would-be rewrites; never append it to `changed`,
      so no write occurs.
- [ ] Per Decision D4, exclude matching files from the bare-form audit accounting.
- [ ] Add a skipped section to `report()`: total files matching, and every skipped path that
      would have been rewritten listed by path with its would-be occurrence count; then the
      "skipped AND moved" sub-list (D8), printed only when non-empty.
- [ ] Re-run the whole fixture suite green, including Phases 1 and 3's tests.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: the default list is asserted to be exactly three entries, and
`docs/architecture/ADR-*.md` is asserted to match the nine ADR files (`ADR-001`, `ADR-004` through
`ADR-011`; v1 implied eleven) and none of the FOUR
non-ADR siblings in that directory (`README.md`, `BFMCS_ARCHITECTURE.md`,
`total-history-validity-decisions.md`, `untl-snce-argument-order.md`; v1 said "three" while
listing four). Confirm at implementation time by running the translator against a real
`ls docs/architecture/` listing.

**Files to modify**:

- `scripts/move-modules.py` - new translator function, `main`'s argument parser, `run`'s walk loop,
  `report`
- `scripts/test-move-modules.py` - skip-behavior, count-honesty and class-7 tests plus
  glob-translator unit tests
- `scripts/move-modules.py` module docstring - the `Inputs` section gains `--no-rewrite`

**Verification**:

- New tests red before, green after.
- The APPLY-mode test proves byte-identity of the skipped file, not merely a dry-run claim.
- `python3 scripts/test-move-modules.py` exits 0 (all phases' tests).

---

### Phase 5: Deliverable (2) — identical-sides warning and --strict [NOT STARTED]

**Goal**: A warning whenever a rewrite makes the two sides of one sentence or one table row
identical, promoted to a non-zero exit under `--strict`, kept wholly separate from the existing
bare-form audit.

**Tasks**:

- [ ] Re-read `scripts/move-modules.py` in full before editing.
- [ ] Write the fixture tests first and observe red. Every fixture file here lives at a path the
      `--no-rewrite` defaults do NOT match (e.g. `docs/notes.md`), or the detector never sees it:
  - [ ] Prose: a line reading "moved from `FormalSystem/Old` to `FormalSystem/New`" under the map
        row `FormalSystem.Old -> FormalSystem.New`. Assert a warning naming the file and line
        number, `rc == 0` without `--strict`, `rc != 0` with `--strict`.
  - [ ] Table, non-adjacent columns: a three-column markdown row
        `| FormalSystem/Old | some note | FormalSystem/New |` under the same map. Assert the same
        (guards D9's all-pairs rule).
  - [ ] Negative (the R2 false-positive guard): a line whose two sides were ALREADY identical
        before the rewrite. Assert no warning is emitted, under `--strict` too.
  - [ ] Negative: a line the rewrite changes but which contains no two-sided construct at all.
        Assert no warning.
  - [ ] Negative (D9's skipped-file rule): the prose line placed in `Boneyard/X/README.md` with
        `--strict`. Assert `rc == 0` and no warning — the file is skipped, not written.
- [ ] Implement the detector per Decision D9: in `run()`, after `new_text` is computed and only
      for files headed into `changed`, zip BEFORE and AFTER lines by index, skip unchanged lines,
      extract side strings from the BEFORE line by the two constructs D9 fixes, and warn when
      `a != b` and `rw(a) == rw(b)`. Implement `rw` as a small helper that applies the per-line
      class 2/3/4 rewrite to a string with throwaway counters — do not route it through the real
      `counts` dict. Warning text carries the file path, the line number, and both forms of the
      line.
- [ ] Add `--strict` (`action="store_true"`): any such warning becomes a non-zero exit at the end
      of `run()`. Without it, warnings are printed and the exit code is unaffected.
- [ ] Keep this entirely separate from `bare_form_count` and the sentinel re-run: no shared
      counter, no shared exit branch, and the bare-form audit's unconditional-fail behavior is
      untouched. Do not call the detector from the sentinel pass.
- [ ] Add a warning-count line to `report()` (count of warnings and of files carrying them).
- [ ] Note as a code comment that `--module-map`/`--namespace-map` files themselves reuse the
      `old -> new` separator but are not part of the repository walk (they live under `specs/`,
      which `PRUNE_DIRS` prunes), so the detector cannot trip on them.
- [ ] Re-run the whole fixture suite green.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:

- `scripts/move-modules.py` - new detector and `rw` helper, `run`'s walk loop and exit logic,
  `main`'s parser, `report`
- `scripts/test-move-modules.py` - two positive and three negative fixture tests
- `scripts/move-modules.py` module docstring - the `Inputs` section gains `--strict`

**Verification**:

- The two positives red before and green after; the three negatives green before AND after,
  proving no false positive was introduced.
- `python3 scripts/test-move-modules.py` exits 0.

---

### Phase 6: Deliverable (4) — namespace-map refusal and --namespace-paths [NOT STARTED]

**Goal**: `--namespace-map` refuses a row that would rewrite a `namespace` declaration in a file
outside the move set, printing every offending file; and `--namespace-paths` scopes class-4
rewrites to an explicit user-supplied path/glob list.

**Tasks**:

- [ ] Re-read `scripts/move-modules.py` in full before editing.
- [ ] Write the fixture tests first and observe red:
  - [ ] Refusal, file-granular shape (the tooling-library split): module rows move two single
        files (`FormalSystem.Automation.A -> Tools.A`, `...B -> Tools.B`); a namespace row
        `FormalSystem.Automation -> Tools`; a staying `FormalSystem/Automation/Stay.lean` declares
        `namespace FormalSystem.Automation`. Run in APPLY mode. Assert `rc != 0`, exactly
        `Stay.lean` printed with its declaring line and line number — and NOT `A.lean`/`B.lean`,
        which declare the same namespace but are in the move set (this is the assertion v1's D7
        would have failed) — and every file byte-unchanged with nothing moved.
  - [ ] Scoped: the same fixture plus `--namespace-paths` covering only the two moved files and
        one external `open` site. Assert `rc == 0`, the moved files' and the `open` site's
        namespaces rewritten, `Stay.lean` byte-identical.
  - [ ] No false refusal when class 2 consumes the declaration (the Expressiveness-extraction
        shape): a directory row `FormalSystem.M.Kamp -> FormalSystem.E.Kamp`, a namespace row with
        the same two names, and an `Archive/K.lean` outside the move set declaring
        `namespace FormalSystem.M.Kamp`. Assert `rc == 0`, `Archive/K.lean` rewritten, and the
        report's class 4 count is 0 (class 2 did it). This is green against the unmodified tool
        and must stay green — it is the guard against re-introducing v1's D6.
  - [ ] Negative: a fixture with no shared prefix and no `--namespace-paths`. Assert behavior is
        byte-identical to today's (guards R6).
- [ ] Implement `in_move_set(path, mappings)` per Decision D7, with both clauses, as a standalone
      function. Do not modify `map_repo_path`.
- [ ] Implement the refusal per Decision D6 inside the existing data flow: give `rewrite_text` an
      optional collector argument; at the class-4 step, when not in sentinel mode and the
      substitution count is non-zero and the pre-class-4 line matches `^\s*namespace\s`, append
      `(path, lineno, original_line)`. In `run()`, after the walk loop and BEFORE the write loop,
      filter the collector by `not in_move_set(...)`; if anything remains, print every offender
      and the remedy (`--namespace-paths`, or drop the row and rename by hand) to stderr and
      return non-zero. Nothing has been written or moved at that point, so no reordering of
      `run()` is needed.
- [ ] Add `--namespace-paths` (`action="append"`, repeatable, path or glob) reusing Phase 4's glob
      translator verbatim. When supplied, the class-4 step runs only in matching files. Pass the
      same scope to BOTH `rewrite_text` calls (the real pass and the sentinel re-run), or the
      bare-form audit's two counts diverge for a reason unrelated to bare forms.
- [ ] Per Decision D5, class 5 axiom baselines are never scoped out: the two
      `AXIOM_BASELINE_SITES` entries are always rewritten regardless of `--namespace-paths`. Add a
      code comment stating why.
- [ ] A `--no-rewrite` file can never be a refusal offender (it is not written); make the
      collector pass skip it, consistent with D9's treatment.
- [ ] Document in the flag's help text that the user is responsible for including external
      citation sites in the scope — scoping to strictly the moved files would drop legitimate
      external `open`/FQN rewrites — and that class 2 is not scoped by this flag.
- [ ] Re-run the whole fixture suite green.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Files to modify**:

- `scripts/move-modules.py` - `in_move_set`, the collector in `rewrite_text`, the refusal in
  `run`, `main`'s parser, class-4 scoping, `report`
- `scripts/test-move-modules.py` - two positive and two negative fixture tests
- `scripts/move-modules.py` module docstring - the `Inputs` section gains `--namespace-paths`

**Verification**:

- The refusal and scoped tests red before, green after; the class-2-consumes test and the
  no-flag negative green both before and after.
- The refusal test asserts every file byte-unchanged in apply mode, proving the refusal precedes
  the write loop, and asserts the moved file-granular files are NOT named as offenders.
- `python3 scripts/test-move-modules.py` exits 0.

---

### Phase 7: Acceptance — pre-move replay, harness, and doc reconciliation [NOT STARTED]

**Goal**: Every acceptance criterion in the task is demonstrated, and the playbook's Tooling
section matches the flags as actually implemented.

**Tasks**:

- [ ] Run the full fixture suite: `python3 scripts/test-move-modules.py`. All tests from Phases
      1 and 3-6 green in one invocation.
- [ ] Build the replay tree OUTSIDE the repository (a `mktemp -d` directory — never under the
      working tree, which siblings share and which `walk_repo` would then walk):
      `git archive 3419bdb8d | tar -x -C "$SCRATCH"`, then `mkdir "$SCRATCH/.git"`. `3419bdb8d` is
      the commit immediately before the Expressiveness extraction was applied; it carries that
      move's real `module-map.txt` and `namespace-map.txt` under its `specs/` tree. An empty
      `.git` directory suffices: `main()` only tests that it exists, and a dry run never shells
      out to git. No `git worktree` is used, so the shared repository's metadata is untouched.
- [ ] Re-measure the baseline with the export's OWN, unmodified copy of the tool (identical to
      today's pre-change tool — `git diff 3419bdb8d HEAD -- scripts/move-modules.py` was empty at
      planning time; re-confirm against this task's first commit):
      `--module-map` and `--namespace-map` set to the export's two map files, `--dry-run
      --no-verify`, run from `$SCRATCH`. Record the figures in the progress file.
- [ ] Copy the hardened `scripts/move-modules.py` over the export's copy and re-run the identical
      command. Assert, against the figures in the Scope Hypothesis below: `rc == 0`; class 6 is 13
      paths; the skipped-with-would-be-rewrites listing is exactly 20 files, of which exactly 17
      match `Boneyard/**/README.md`, two are `docs/architecture/ADR-006-...md` and
      `ADR-011-...md`, and one is `typst/SYNC-MAP.md`; `files changed` fell by exactly 20; the
      namespace refusal did not fire (class 4 is 0 on this replay); the bare-form audit's two
      figures are equal to each other. Derive the expected 17 independently of the tool with
      `git grep -lE` over the old dotted and slash prefixes at `3419bdb8d`, restricted to
      `Boneyard/**/README.md`, and compare the two lists path by path.
- [ ] Record, as information and not as an assertion, how many identical-sides warnings the
      replay emits with the defaults active. Two earlier moves collapsed "from X to Y" prose in
      files outside the default list, so a non-zero figure here is expected and useful context
      for the playbook's blind-spot section.
- [ ] Add the replay to `scripts/test-move-modules.py` as a permanent test gated by
      `unittest.skipUnless(<git cat-file -e 3419bdb8d^{commit} succeeds in the repo root>)`,
      performing the archive/extract/`mkdir .git` steps in a temp directory, copying the working
      tree's `scripts/move-modules.py` in, and asserting the 17/2/1 split and `rc == 0`. Locate
      the two map files inside the export by globbing `specs/*_expressiveness_extraction/`, so
      the test file names no archived task directory. Refer to the commit by hash only.
- [ ] Reconcile `docs/development/MODULE_RELOCATION.md`'s Tooling section against the flags as
      implemented (`--no-rewrite` and its three defaults, `--strict`, `--namespace-paths`, the
      declaration refusal, the zero-move exit), and its rewrite-class list against
      `move-modules.py`'s module docstring class numbering. Fix any drift in the doc, never in
      the tool's numbering.
- [ ] Confirm `move-modules.py`'s own module docstring `Inputs` section lists all three new flags
      (each phase added its own; verify none was missed). `SELF_PATH` excludes this file from
      rewriting, so editing its docstring is safe.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` and confirm green, comparing
      against Phase 1's recorded baseline and harness commit if anything is red (R5).
- [ ] Confirm `scripts/README.md` and `docs/development/README.md` each carry their one new row.
- [ ] Remove the scratch export.

**Timing**: 1.5 hours

**Depends on**: 2, 6

**Verification Tier**: full

**Scope Hypothesis**: every figure below was measured during this revision by running the
UNMODIFIED tool, and a probe using Phase 4's translator semantics, against an export of
`3419bdb8d`. They are hypotheses to re-measure (task 2 of this phase), not constants to trust.
Baseline report: class 1 369 occurrences in 149 files; class 2 638 in 215; class 3 149 in 27;
class 4 0; class 5 2 in 2; class 6 13 paths; class 7 6 re-based; bare-form 232 before and after
in 65 files; `files changed` 282 (280 by classes 1-5, two by class 7 alone). Default
`--no-rewrite` globs match 66 files in that tree (56 Boneyard READMEs, 9 ADRs, `SYNC-MAP.md`),
of which 20 carry would-be rewrites: 17 + 2 + 1. None of the 66 lies inside the move set, so
D8's list is empty on this replay. Expected after hardening: `files changed` 262, class 1-3
counts lower than baseline by exactly the would-be counts reported in the skipped section, and
bare-form figures lower than 232 but equal to each other. If the re-measured baseline differs,
trust the re-measurement and restate the expectations before asserting. The task's own figure
("17 provenance READMEs") matches this tree exactly; on the CURRENT tree the corresponding figure
is 16, which is why the replay does not run there.

**Files to modify**:

- `scripts/test-move-modules.py` - the history-gated replay test
- `docs/development/MODULE_RELOCATION.md` - reconciliation edits only, if drift is found
- `scripts/move-modules.py` - docstring `Inputs` completion only, if a flag was missed

**Verification**:

- `python3 scripts/test-move-modules.py` exits 0, with the replay test executed (not skipped) in
  this clone.
- `bash scripts/check-module-invariants.sh --no-build` exits 0 (this also discharges the "no task
  numbers outside specs/" criterion via C9-DOCS), or is no redder than the Phase 1 baseline with
  the difference attributed.
- The replay's skipped listing equals the independently derived 17-path list plus the two ADRs
  and `typst/SYNC-MAP.md`.
- `git status --short` shows, among this task's paths, only files from this plan's declared scope,
  and nothing under the scratch export.

---

## Testing & Validation

- [ ] Each of deliverables (1)-(5) has at least one fixture test observed RED before its change
      and GREEN after, with both outputs recorded in the progress file.
- [ ] `python3 scripts/test-move-modules.py` exits 0 with every phase's tests in one run.
- [ ] Negative tests (R2's already-identical line, D9's skipped-file rule, D6's
      class-2-consumes-the-declaration shape, R6's no-flag namespace path) are green both before
      and after their phase, proving no false positive or behavior regression.
- [ ] The file-granular refusal test names only the staying file as an offender (D7).
- [ ] A dry run of the archived Expressiveness-extraction maps against an export of that move's
      pre-move commit reports exactly that move's 17 provenance READMEs, two ADRs and
      `typst/SYNC-MAP.md` as skipped, exits 0, and moves 13 paths.
- [ ] `bash scripts/check-module-invariants.sh --no-build` is green.
- [ ] No task numbers in any file outside `specs/` (mechanically enforced by C9-DOCS for `docs/`
      and by the repository's write-time hook elsewhere); the replay test names a commit hash and
      a glob, never an archived task directory.
- [ ] `move-modules.py` was never run in apply mode against this repository.

## Artifacts & Outputs

- `scripts/test-move-modules.py` (new) - stdlib fixture harness, one or more tests per
  deliverable, plus the history-gated replay test
- `scripts/move-modules.py` (modified) - five hardening changes plus docstring updates
- `scripts/README.md` (modified) - one row for the new test file
- `docs/development/MODULE_RELOCATION.md` (new) - the relocation playbook
- `docs/development/README.md` (modified) - one row in the "Project Organization" table
- `specs/644_harden_move_modules_and_record_relocation_method/summaries/01_harden-move-modules-relocation-summary.md`

## Rollback/Contingency

Every phase is committed separately with a `task 644 phase {P}: ...` message, so any single phase
is revertible with `git revert` of its own commit — the preferred contingency, since it needs no
working-tree discard and is safe while sibling tasks share this tree.

Phases 3-6 are independent hardening changes to one file: reverting any one of them leaves the
others intact and the fixture suite green minus that phase's tests. Phase 2 is wholly independent
of the code phases and is explicitly the half worth keeping alone if the code work is abandoned —
it is scheduled in Wave 1 for exactly that reason. If the code phases are abandoned after Phase 2
lands, trim the playbook's Tooling section to the flags that actually exist rather than leaving
it describing unbuilt ones.

If Phase 7's re-measured baseline contradicts the Scope Hypothesis in a way that cannot be
explained (for example the 17 becomes another number at the same commit), stop and record the
discrepancy rather than adjusting assertions until they pass: that figure is the task's own
acceptance criterion.

If a working-tree rollback is genuinely required rather than a revert, follow
`context/contracts/recovery.md`'s rollback rung for the snapshot-then-rollback invocation shape,
including its out-of-scope override flag. Do not run `git-snapshot.sh` in its default reverting
mode as a routine checkpoint, and never run it at all while sibling tasks have uncommitted work in
this shared tree.
