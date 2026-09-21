# Implementation Plan: Harden move-modules and record relocation method

- **Task**: 644 - Harden move-modules and record relocation method
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None
- **Research Inputs**: specs/644_harden_move_modules_and_record_relocation_method/reports/01_harden-move-modules-relocation.md
- **Artifacts**: plans/01_harden-move-modules-relocation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

`scripts/move-modules.py` is a 582-line one-shot relocation tool reused across five module moves,
each of which surfaced a distinct correctness gap caught by hand review or a dry run, never by a
gate. This plan closes the five named gaps as five independently fixture-tested changes to that
one file, builds the stdlib-only fixture harness those tests need (none exists anywhere under
`scripts/` today), and writes `docs/development/MODULE_RELOCATION.md` as the operational
playbook a future move reads first. Done means: every deliverable has a test that was observed
red before its change and green after, a dry run replaying the archived Expressiveness-extraction
module map reports that move's provenance READMEs as skipped, and
`bash scripts/check-module-invariants.sh --no-build` is green.

### Research Integration

The research report is integrated as follows:

- **Path correction adopted.** The task description's default `--no-rewrite` entry `docs/adr/**`
  is wrong for this repository: `docs/adr/` does not exist and ADRs live at
  `docs/architecture/ADR-*.md` (confirmed: `ADR-001` through `ADR-011` plus non-ADR siblings
  `README.md`, `BFMCS_ARCHITECTURE.md`, `total-history-validity-decisions.md`,
  `untl-snce-argument-order.md`). Phase 4 uses the narrower `docs/architecture/ADR-*.md` glob, so
  the non-ADR siblings stay rewritable.
- **Deliverables (3) and (5) merged into one phase** (Phase 3): both are edits to
  `resolve_move`/`move_trees`/`run`'s exit logic and `report`, and both are reproduced by the
  same archived incident class.
- **Recommendation 3 adopted**: deliverable (2)'s new check stays wholly separate from the
  existing bare-form audit (`bare_form_count`, the sentinel re-run at `move-modules.py:495-500`).
  They detect different failure classes and the bare-form audit's unconditional-fail behavior is
  not weakened.
- **Recommendation 4 resolved explicitly** (Phase 3, Decision D2): the resolve_move ambiguity
  check runs BOTH up front over all mappings before any write AND per-mapping inside
  `move_trees`.
- **Recommendation 5 adopted** (Phase 6): `--namespace-paths` takes an explicit user-supplied
  path/glob list rather than inferring the moved-file set through `resolve_move`, sidestepping
  the rewrite-loop-runs-before-move-resolution ordering problem entirely.
- **Recommendation 6 adopted** (Phase 2): `MODULE_RELOCATION.md` is a synthesis of six existing
  sources, not fresh prose — the tool's own module docstring (classes, bare-token trap,
  resolve-map-recompute), `docs/development/MODULE_INVARIANTS.md`'s C11 and C25 rows, and the
  four archived task summaries' Decisions sections.
- **Recommendation 7 adopted**: the harness's C9-DOCS check already gates `docs/**/*.md` for
  task-number citations, so the "no task numbers outside specs/" acceptance criterion and the
  "harness green" acceptance criterion are satisfied by one `--no-build` invocation. No separate
  grep is planned.
- **Testing-infrastructure finding acted on** (Phase 1): option (a) from the report — a
  disposable `tempfile.TemporaryDirectory()` git repo — is chosen over subprocess stubbing,
  because the acceptance criteria reference report *text* and a real dry-run reproduction.

### Prior Plan Reference

No prior plan.

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
- `--namespace-map` refusing a row whose old prefix is also declared by a file outside the move
  set, printing every offending file, plus a `--namespace-paths` flag to scope class-4 rewrites.
- A report that states files actually moved next to citations rewritten, and a non-zero exit when
  rows were requested and zero files moved.
- `docs/development/MODULE_RELOCATION.md` recording the nine method items the task enumerates.
- A stdlib-only fixture harness at `scripts/test-move-modules.py` with one red-before/green-after
  test per deliverable.

**Non-Goals**:

- Detecting the *inverse* error — stale present-tense citations the bare-form exclusion leaves
  untouched (ten were found by hand in the Expressiveness extraction, including the root
  `README.md`). `--no-rewrite` suppresses false-positive rewrites only. Phase 2's doc states this
  limitation explicitly rather than implying the flag is a complete fix.
- Any semantic or tense-aware understanding of prose. Deliverable (2) is a syntactic
  before/after comparison, not a historical-statement detector.
- Running `move-modules.py` in apply mode against this repository at any point in this task. Every
  invocation outside a temp fixture is `--dry-run`.
- Adding a pytest, tox, or third-party test dependency. The harness is stdlib `unittest` only.
- Introducing an override flag for the new zero-move exit (see Risk R3).
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

**Do NOT touch** (concurrent sibling territory, confirmed from this dispatch's territory block):

- `scripts/check-module-invariants.sh`, `scripts/reanchor-lean-citations.py`,
  `docs/development/MODULE_INVARIANTS.md`, `docs/development/REFERENCE_NORMAL_FORM.md` — sibling
  task's scope. `MODULE_RELOCATION.md` may *cite* `MODULE_INVARIANTS.md` (by filename and by gate
  ID such as C11/C25) but must never edit it.
- `scripts/module-invariants-manifest.txt`, `scripts/check-copyright-headers.sh`, `ORGANISATION.md`,
  `CLAUDE.md`, `FormalSystem/FormalSystem.lean` — another sibling's scope.
- Every `FormalSystem/**/README.md` and `typst/chapters/p4-dataset-pipeline.typ` — a third
  sibling's scope.

Per the dispatch's concurrency note: re-read any shared file immediately before editing it, stage
only this task's own hunks with an explicit file list (never a directory or glob `git add`), and
never run `git-snapshot.sh` in its reverting default mode.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| R1: the `--no-rewrite` default list silently suppresses a rewrite a future move genuinely needs | M | H | Every skipped file is listed by path in the report (deliverable (1) says "reported but never rewritten"), so the omission is visible in the dry run; Phase 2's doc states hand-review of skipped files remains mandatory |
| R2: deliverable (2)'s detector false-positives on a line whose two sides were already identical before the rewrite | M | M | Compare the BEFORE and AFTER forms of the same line and warn only when the two sides differed before and match after — the sentinel-rerun before/after technique already used by the bare-form audit |
| R3: the new zero-move exit breaks a legitimate workflow (e.g. re-running a map whose rows already moved, or `--no-verify` map composition) | M | M | Accepted deliberately: a zero-move run is always worth investigating. No override flag (explicit Non-Goal). Documented in `MODULE_RELOCATION.md` and in the flag's `--help` text. Phase 7's replay is expected to exit non-zero for exactly this reason and asserts the skip listing rather than the exit code |
| R4: hand-rolled `**` glob translation gets an edge case wrong (`fnmatch` matches `/` with `*`; `PurePath.match` handles `**` inconsistently across versions) | M | M | Phase 4 implements one explicit translator with its own dedicated unit tests, reused verbatim by Phase 6's `--namespace-paths` |
| R5: a pre-existing harness redness is misattributed to this task at Phase 7 | L | M | Phase 1 captures a baseline `check-module-invariants.sh --no-build` result BEFORE any change and records it in the progress file |
| R6: `--namespace-paths` scoping breaks the external citation rewriting the tool currently and correctly performs (e.g. `open BimodalTools` at external sites) | H | M | The flag is opt-in and user-supplied; when absent, class-4 behavior is byte-identical to today. Class 5 axiom baselines are never scoped out (Decision D5). Phase 6's negative fixture test asserts the no-flag path is unchanged |
| R7: six phases edit one 582-line file, so a later phase silently reverts an earlier one | M | M | Phases 3-6 are strictly sequential (one per wave), and each phase's first task is re-reading `move-modules.py` in full; Phase 7 re-runs the whole fixture suite, not only the last phase's tests |

## Design Decisions

Fixed here so Phases 3-6 do not re-litigate them:

- **D1 — flag names**: `--no-rewrite`, `--strict`, `--namespace-paths`. Phase 2's doc may name
  these before they exist because this plan pins them.
- **D2 — resolve_move ambiguity check runs twice**: once up front over every mapping against the
  pre-move tree (before any file is written, so no citation is rewritten for a move that will
  fail), and once per mapping at its own resolution point inside `move_trees` (catching ambiguity
  that only arises between two rows of the same invocation). Both name both offending paths.
- **D3 — `--no-rewrite` values ADD to the built-in defaults**; they never replace them. A file on
  the default list can only be rewritten by hand. No "clear the defaults" flag is added.
- **D4 — skipped files are excluded from the bare-form audit accounting entirely.** No write
  happens to them, so a before/after delta for them is vacuous and would only add noise.
- **D5 — `--namespace-paths` does not scope class 5.** The two axiom-baseline sites
  (`scripts/check-module-invariants.sh`, `FormalSystem/MainResults.lean`) pin fully-qualified
  names as DATA and must always track a namespace rename, or every pinned check turns red at once.
- **D6 — the refusal check keys on a `namespace` DECLARATION line**, not on any citation of the
  old prefix. "Declared by a file outside the move set" is the task's own wording; a file that
  merely mentions the prefix is a legitimate citation site the rewrite should reach.
- **D7 — the move set for the refusal check is computed with `map_repo_path(path, mappings)`**
  over `walk_repo()`, a pure path-mapping function with no dependency on `resolve_move` or on
  filesystem state, so it is available at rewrite time without reordering `run()`.

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

### Phase 1: Fixture harness scaffolding [NOT STARTED]

**Goal**: A stdlib-only test harness at `scripts/test-move-modules.py` that can build a
disposable git repo, invoke `move-modules.py`'s `run()` in process, capture stdout/stderr, and
assert on both the return code and the report text — with one baseline test that passes against
today's unmodified tool.

**Tasks**:

- [ ] Capture a baseline `bash scripts/check-module-invariants.sh --no-build` result before any
      change and record the outcome (green/red, and which checks if red) in the progress file, so
      Phase 7 can attribute any redness.
- [ ] Create `scripts/test-move-modules.py` using stdlib `unittest` only; runnable as
      `python3 scripts/test-move-modules.py`.
- [ ] Load the tool with `importlib.util.spec_from_file_location("move_modules",
      "scripts/move-modules.py")` — the hyphen in the filename makes a plain `import` impossible.
- [ ] Implement a `fixture_repo(files: dict[str, str])` context manager: `tempfile.TemporaryDirectory()`,
      write each file (creating parents), `git init -q`, `git -c user.email=... -c user.name=... add`
      + `commit -q`, `os.chdir` in and restore the original CWD on exit. `run()` walks `.` and
      `move_trees` shells out to `git mv`, so a real git repo at the CWD is required.
- [ ] Implement a single centralized `run_tool(**overrides) -> tuple[int, str, str]` helper that
      builds the `argparse.Namespace` with every current flag defaulted
      (`module_map`, `namespace_map=None`, `dry_run=False`, `no_verify=True`) and captures output
      via `contextlib.redirect_stdout`/`redirect_stderr` around `move_modules.run(args)`. Every
      later phase adds its new flag's default in this one place.
- [ ] Add a `write_map(lines)` helper producing a temporary `old -> new` mapping file.
- [ ] Add one baseline smoke test: a fixture with `FormalSystem/Foo/Bar.lean`, a citing
      `docs/x.md` (dotted and slash forms) and a citing `FormalSystem/Other.lean` import line;
      assert `rc == 0`, non-zero class 1/2/3 counts in the report, and the file actually moved.
- [ ] Add the `test-move-modules.py` row to `scripts/README.md` (that file states every script
      under `scripts/` is named in it).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts it adds exactly one new file plus one `scripts/README.md`
row. Confirm with `git status --short` before committing: exactly two paths, and
`scripts/move-modules.py` must NOT appear.

**Files to modify**:

- `scripts/test-move-modules.py` - new; fixture harness plus the baseline smoke test
- `scripts/README.md` - one row under the appropriate section describing the new test file

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
        let the class numbering drift from the code's.
  - [ ] **The bare-form trap** — why every rule is anchored on the full old prefix and why a
        bare-form citation must survive byte-identical.
  - [ ] **Resolve-map-recompute for relative links** — resolve against the old directory, apply
        the path mapping, recompute from the new directory; never `../`-counting, which gets the
        cases wrong where the target stays put but the file's distance to the root moves the
        other way.
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
  - [ ] **Tooling** — name `--no-rewrite` (with its three built-in defaults), `--strict`,
        `--namespace-paths`, and the zero-move non-zero exit, per Decisions D1-D7 above.
  - [ ] **Pre-move checklist** — an ordered, runnable sequence ending in a dry run and a hand
        review of the skipped list.
- [ ] Cite only durable anchors — filenames, section headings, ADR names, gate IDs (C11, C25).
      **No task numbers anywhere in this file**: `check-module-invariants.sh`'s C9-DOCS check
      (enabled by default) fails the harness on any task-number citation under `docs/`.
- [ ] Add a `MODULE_RELOCATION.md` row to `docs/development/README.md`'s "Project Organization"
      table, alongside `MODULE_ORGANIZATION.md` and `MODULE_INVARIANTS.md`.
- [ ] Verify every relative link in the new file resolves from `docs/development/`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: prose

**Files to modify**:

- `docs/development/MODULE_RELOCATION.md` - new; the nine method items plus Tooling and checklist
- `docs/development/README.md` - one row in the "Project Organization" table

**Verification**:

- `bash scripts/check-module-invariants.sh --no-build` is green (this covers C9-DOCS's
  task-number gate and the markdown link checks in one invocation).
- Every one of the nine enumerated method items has its own heading in the file.
- `grep -nE '[Tt]ask [0-9]+' docs/development/MODULE_RELOCATION.md` returns nothing.

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
  - [ ] Ambiguity: fixture containing both `FormalSystem/Syntax/Lang/` (a directory) and
        `FormalSystem/Syntax/Lang.lean`, with a map row `FormalSystem.Syntax.Lang -> ...`. Assert
        `rc != 0`, both paths named in stderr, and — critically — that the citing files are
        byte-unchanged (nothing was rewritten for a move that will fail).
  - [ ] Zero moves: fixture whose map row's stem does not exist on disk but whose citations do.
        Assert `rc != 0`, a non-zero class 2/3 count, `0 path(s)` for class 6, and the presence of
        the new moved-vs-rewritten report line.
- [ ] Change `resolve_move` to signal ambiguity rather than silently preferring the directory:
      when `os.path.isdir(stem)` AND `os.path.isfile(stem + ".lean")` both hold, report the
      ambiguity naming both paths. Keep the existing directory-only and file-only branches
      unchanged. Do not use a bare `sys.exit` inside `resolve_move` — the in-process fixture
      harness needs a return code, so signal via a distinct return value or a dedicated
      exception that `run`/`move_trees` translate into a non-zero return.
- [ ] Per Decision D2, add an up-front ambiguity scan over every mapping at the top of `run()`,
      before the rewrite loop writes anything, returning non-zero immediately; and keep a
      per-mapping check at each mapping's own resolution point inside `move_trees` as the backstop
      for ambiguity that only arises between two rows of the same invocation.
- [ ] Add a moved-vs-rewritten line to `report()`: files actually moved stated next to the total
      citation-rewrite count, as one line, so the two figures cannot be read apart.
- [ ] Add the zero-move branch to `run()`'s exit logic: mappings are always non-empty
      (`parse_map` exits on an empty file), so the condition is simply "`moved` is empty". Print a
      named failure line to stderr explaining that rows were requested and nothing moved. Place it
      alongside the existing `bare_before != bare_after` and `move_failures` branches, not folded
      into them.
- [ ] Re-run the fixture suite and observe green; confirm Phase 1's baseline smoke test still
      passes.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:

- `scripts/move-modules.py` - `resolve_move`, `move_trees`, `run`, `report`
- `scripts/test-move-modules.py` - two new fixture tests

**Verification**:

- Both new tests observed red before the change and green after (record both outputs).
- `python3 scripts/test-move-modules.py` exits 0.
- The ambiguity test asserts byte-unchanged citing files, proving the up-front scan runs before
  the write loop.

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
  - [ ] Unit tests for the glob translator covering `Boneyard/**/README.md` (matching at depth 1
        and deeper), `typst/SYNC-MAP.md` (exact), `docs/architecture/ADR-*.md` (matching
        `ADR-010-...md` but NOT `README.md` or `BFMCS_ARCHITECTURE.md` in the same directory), and
        a `*` that must not cross a `/`.
- [ ] Implement one explicit glob-to-regex translator: `**/` becomes `(?:.*/)?`, `*` becomes
      `[^/]*`, `?` becomes `[^/]`, everything else is escaped. Do NOT use `fnmatch` (its `*`
      crosses `/`) or `PurePath.match` (inconsistent `**` handling across versions). Keep the
      translator a standalone module-level function — Phase 6 reuses it verbatim.
- [ ] Add `--no-rewrite` as `action="append"`, repeatable, taking a path or glob. Per Decision D3,
      supplied values ADD to the built-in default list `Boneyard/**/README.md`,
      `typst/SYNC-MAP.md`, `docs/architecture/ADR-*.md` (note: `docs/architecture/`, not the
      non-existent `docs/adr/`). Document the ADD semantics in the flag's help text.
- [ ] In `run()`'s walk loop, still compute what the rewrite WOULD change for a matching file, so
      the report can state both the file count and how many of them carried citations that would
      have been rewritten — but never append it to `changed`, so no write occurs.
- [ ] Per Decision D4, exclude matching files from the bare-form audit accounting.
- [ ] Add a skipped section to `report()`: the count, and every skipped path that would have been
      rewritten, listed by path (not merely counted) — deliverable (1) requires them reported.
- [ ] Re-run the whole fixture suite green, including Phases 1 and 3's tests.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: the default list is asserted to be exactly three entries. Confirm at
implementation time that `docs/architecture/ADR-*.md` matches the ADR files and none of the three
non-ADR siblings in that directory (`README.md`, `BFMCS_ARCHITECTURE.md`,
`total-history-validity-decisions.md`, `untl-snce-argument-order.md`) — run the translator against
a real `ls docs/architecture/` listing.

**Files to modify**:

- `scripts/move-modules.py` - new translator function, `main`'s argument parser, `run`'s walk loop,
  `report`
- `scripts/test-move-modules.py` - skip-behavior test plus glob-translator unit tests
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
- [ ] Write the fixture tests first and observe red:
  - [ ] Prose: a line reading "moved from `FormalSystem/Old` to `FormalSystem/New`" under the map
        row `FormalSystem.Old -> FormalSystem.New`. Assert a warning naming the file and line
        number, `rc == 0` without `--strict`, `rc != 0` with `--strict`.
  - [ ] Table: a two-column markdown row `| FormalSystem/Old | FormalSystem/New |` under the same
        map. Assert the same.
  - [ ] Negative (the R2 false-positive guard): a line whose two sides were ALREADY identical
        before the rewrite. Assert no warning is emitted, under `--strict` too.
  - [ ] Negative: a line the rewrite changes but which contains no two-sided construct at all.
        Assert no warning.
- [ ] Implement a per-line, per-file detector that compares the BEFORE and AFTER forms of the same
      line. Extract two-sided constructs from the BEFORE line — an explicit "X to Y" / "X -> Y" /
      "X → Y" phrase over path- or dotted-name-shaped tokens, and a markdown table row with two or
      more cells — and warn only when a pair differed before and is equal after. Warning text
      carries the file path, the line number, and both forms of the line.
- [ ] Add `--strict` (`action="store_true"`): any such warning becomes a non-zero exit at the end
      of `run()`. Without it, warnings are printed and the exit code is unaffected.
- [ ] Keep this entirely separate from `bare_form_count` and the sentinel re-run: no shared
      counter, no shared exit branch, and the bare-form audit's unconditional-fail behavior is
      untouched.
- [ ] Add a warning-count line to `report()` (count of warnings and of files carrying them).
- [ ] Note as a code comment that `--module-map`/`--namespace-map` files themselves reuse the
      `old -> new` separator but are not part of the repository walk (they live under `specs/`,
      which `PRUNE_DIRS` prunes), so the detector cannot trip on them.
- [ ] Re-run the whole fixture suite green.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:

- `scripts/move-modules.py` - new detector, `rewrite_text` or its caller, `run`'s exit logic,
  `main`'s parser, `report`
- `scripts/test-move-modules.py` - two positive and two negative fixture tests
- `scripts/move-modules.py` module docstring - the `Inputs` section gains `--strict`

**Verification**:

- Four new tests red before (the two positives) and green after; both negatives must be green
  before AND after, proving no false positive was introduced.
- `python3 scripts/test-move-modules.py` exits 0.

---

### Phase 6: Deliverable (4) — namespace-map refusal and --namespace-paths [NOT STARTED]

**Goal**: `--namespace-map` refuses a row whose old prefix is also declared by a file outside the
move set, printing every offending file; and `--namespace-paths` scopes class-4 rewrites to an
explicit user-supplied path/glob list.

**Tasks**:

- [ ] Re-read `scripts/move-modules.py` in full before editing.
- [ ] Write the fixture tests first and observe red:
  - [ ] Refusal: a fixture where a namespace-map row's old prefix (e.g.
        `FormalSystem.Automation -> ...`) is also declared by a `namespace FormalSystem.Automation`
        line in a file the module map does NOT move. Assert `rc != 0`, the offending file printed
        with its declaring line, and every file byte-unchanged (the refusal precedes all writes).
  - [ ] Scoped: the same fixture plus `--namespace-paths` covering only the moved subtree. Assert
        `rc == 0`, the in-scope file's namespace rewritten, the staying file untouched.
  - [ ] Negative: a fixture with no shared prefix and no `--namespace-paths`. Assert behavior is
        byte-identical to today's (guards R6).
- [ ] Implement the move set per Decision D7: `map_repo_path(path, mappings) != path` over
      `walk_repo()`. No dependency on `resolve_move` and no reordering of `run()`.
- [ ] Implement the refusal check per Decision D6: key on a `namespace` DECLARATION line naming
      the old prefix (exactly, or as a dotted prefix), in a file outside the move set. Print every
      offending file with its declaring line and return non-zero BEFORE any write.
- [ ] Add `--namespace-paths` (`action="append"`, repeatable, path or glob) reusing Phase 4's glob
      translator verbatim. When supplied, class-4 namespace/open/FQN rewrites apply only to
      matching files, and the refusal check considers only offending files that fall WITHIN the
      scope — that is what makes the flag the remedy for a refused row rather than an unrelated
      knob.
- [ ] Per Decision D5, class 5 axiom baselines are never scoped out: the two
      `AXIOM_BASELINE_SITES` entries are always rewritten regardless of `--namespace-paths`. Add a
      code comment stating why (a pinned FQN that misses a rename turns every pinned check red at
      once).
- [ ] Document in the flag's help text that the user is responsible for including external
      citation sites in the scope — scoping to strictly the moved files would drop legitimate
      external `open`/FQN rewrites.
- [ ] Re-run the whole fixture suite green.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Files to modify**:

- `scripts/move-modules.py` - move-set computation, refusal check, `main`'s parser, class-4 scoping
  in `rewrite_text`/`apply_namespace`'s caller, `report`
- `scripts/test-move-modules.py` - two positive and one negative fixture test
- `scripts/move-modules.py` module docstring - the `Inputs` section gains `--namespace-paths`

**Verification**:

- New tests red before, green after; the negative test green both before and after.
- The refusal test asserts every file byte-unchanged, proving the refusal precedes the write loop.
- `python3 scripts/test-move-modules.py` exits 0.

---

### Phase 7: Acceptance — replay, harness, and doc reconciliation [NOT STARTED]

**Goal**: Every acceptance criterion in the task is demonstrated, and the playbook's Tooling
section matches the flags as actually implemented.

**Tasks**:

- [ ] Run the full fixture suite: `python3 scripts/test-move-modules.py`. All tests from Phases
      1 and 3-6 green in one invocation.
- [ ] Reconstruct the Expressiveness-extraction module map from its archived summary
      (`specs/archive/635_expressiveness_extraction/summaries/01_expressiveness-extraction-move-summary.md`)
      into a scratch map file OUTSIDE the repository tree, and run
      `python3 scripts/move-modules.py --module-map <scratch> --dry-run --no-verify` from the
      repository root. Assert each of that move's provenance READMEs appears in the report's
      skipped listing.
- [ ] Record the expected interaction explicitly in the progress file: because that move has
      already happened, no map row resolves, so the run exits non-zero via Phase 3's zero-move
      branch. That is correct behavior, not a failure of this acceptance criterion — the criterion
      is about the skipped listing, which is match-based and independent of whether anything moved.
- [ ] Reconcile `docs/development/MODULE_RELOCATION.md`'s Tooling section against the flags as
      implemented (`--no-rewrite` and its three defaults, `--strict`, `--namespace-paths`, the
      zero-move exit), and its rewrite-class list against `move-modules.py`'s module docstring
      class numbering. Fix any drift in the doc, never in the tool's numbering.
- [ ] Confirm `move-modules.py`'s own module docstring `Inputs` section lists all three new flags
      (each phase added its own; verify none was missed). `SELF_PATH` excludes this file from
      rewriting, so editing its docstring is safe.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` and confirm green, comparing
      against Phase 1's recorded baseline if anything is red.
- [ ] Confirm `scripts/README.md` and `docs/development/README.md` each carry their one new row.

**Timing**: 1 hour

**Depends on**: 2, 6

**Verification Tier**: full

**Scope Hypothesis**: the acceptance criterion names 17 provenance READMEs for that move. The
repository now holds roughly 56 files matching `Boneyard/**/README.md` after the consolidation, so
the skipped-listing total will be larger than 17. Confirm by enumerating the 17 specific paths
from the archived summary and asserting each is present in the listing — do NOT assert the total
count equals 17.

**Files to modify**:

- `docs/development/MODULE_RELOCATION.md` - reconciliation edits only, if drift is found
- `scripts/move-modules.py` - docstring `Inputs` completion only, if a flag was missed

**Verification**:

- `python3 scripts/test-move-modules.py` exits 0.
- `bash scripts/check-module-invariants.sh --no-build` exits 0 (this also discharges the "no task
  numbers outside specs/" criterion via C9-DOCS).
- The replay's skipped listing contains each enumerated provenance README path.
- `git status --short` shows only paths from this plan's declared file scope.

---

## Testing & Validation

- [ ] Each of deliverables (1)-(5) has at least one fixture test observed RED before its change
      and GREEN after, with both outputs recorded in the progress file.
- [ ] `python3 scripts/test-move-modules.py` exits 0 with every phase's tests in one run.
- [ ] Negative tests (R2's already-identical line, R6's no-flag namespace path) are green both
      before and after their phase, proving no false positive or behavior regression.
- [ ] A dry run replaying the archived Expressiveness-extraction module map reports that move's
      provenance READMEs as skipped.
- [ ] `bash scripts/check-module-invariants.sh --no-build` is green.
- [ ] No task numbers in any file outside `specs/` (mechanically enforced by C9-DOCS for `docs/`
      and by the repository's write-time hook elsewhere).
- [ ] `move-modules.py` was never run in apply mode against this repository.

## Artifacts & Outputs

- `scripts/test-move-modules.py` (new) - stdlib fixture harness, one or more tests per deliverable
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
it is scheduled in Wave 1 for exactly that reason.

If a working-tree rollback is genuinely required rather than a revert, follow
`context/contracts/recovery.md`'s rollback rung for the snapshot-then-rollback invocation shape,
including its out-of-scope override flag. Do not run `git-snapshot.sh` in its default reverting
mode as a routine checkpoint, and never run it at all while sibling tasks have uncommitted work in
this shared tree.
