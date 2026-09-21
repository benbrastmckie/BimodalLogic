# Research Report: Task #644

- **Task**: 644 - Harden move-modules and record relocation method
- **Started**: 2026-09-21T14:50:00Z
- **Completed**: 2026-09-21T15:40:00Z
- **Effort**: ~1 hour
- **Dependencies**: None
- **Sources/Inputs**:
  - `scripts/move-modules.py` (full read, 582 lines)
  - `scripts/check-module-invariants.sh` (targeted reads: C9-DOCS, C11, C25, MODULE_INVARIANTS.md
    table)
  - `specs/archive/630_move_tool_and_boneyard_relocation/summaries/01_move-tool-boneyard-relocation-summary.md`
  - `specs/archive/632_bimodaltools_split/summaries/01_bimodaltools-library-split-summary.md`
  - `specs/archive/634_language_extension_directories_and_probe_tests/summaries/01_language-extension-directory-merge-summary.md`
  - `specs/archive/635_expressiveness_extraction/summaries/01_expressiveness-extraction-move-summary.md`
  - `scripts/measure-refactor-partitions.py` (`namespace-audit` mode)
  - `docs/development/MODULE_INVARIANTS.md`
  - Repository layout probes (`docs/architecture/`, `Boneyard/`, `typst/SYNC-MAP.md`)
- **Artifacts**: reports/01_harden-move-modules-relocation.md
- **Standards**: report-format.md, status-markers.md, artifact-management.md, tasks.md

## Executive Summary

- All six deliverables map cleanly onto concrete, already-diagnosed gaps in
  `scripts/move-modules.py`; the four cited task summaries (archived 630, 632, 634, 635) give
  precise reproductions for each failure mode, which is what the acceptance fixture tests should
  encode.
- One factual correction to the task description: the default `--no-rewrite` path list names
  `docs/adr/**`, but this repository's ADR directory is `docs/architecture/` — `docs/adr/` does
  not exist. The plan should use `docs/architecture/ADR-*.md` (or `docs/architecture/**`).
- Deliverable (5)'s exact bug is reproducible from the tool's own control flow: `run()` returns
  non-zero only on `move_failures` or a bare-form audit mismatch — never when citation rewrites
  happened but `move_trees` moved nothing. Task 632's "236 rewrites, 0 moved, exit 0" is this gap
  exactly, not a hypothetical.
- Deliverable (3)'s `resolve_move()` already contains a docstring explaining the
  directory-over-file preference and the exact hazard (orphaning `Syntax/{X}Language.lean` with
  citations already rewritten) — the fix is to make that ambiguity fail loudly instead of
  resolving silently.
- No fixture-test infrastructure exists anywhere under `scripts/` today (no pytest, no shell
  fixture harness for a Python script); the plan needs to design one from scratch, most naturally
  as a throwaway git repo under a temp directory, since `move-modules.py` refuses to run unless
  `.git` is present at the CWD (`main()`, line 576-577) and Class 6 shells out to `git mv`.
- Deliverable (6)'s content is largely already drafted piecemeal: the seven rewrite classes and
  the bare-token trap are documented almost verbatim in the tool's own module docstring (lines
  1-53); "assert the denominator" is a named principle already in `MODULE_INVARIANTS.md`'s C11
  row; `measure-refactor-partitions.py namespace-audit` is the existing namespace-audit-simulation
  tool task 634 used. `docs/development/MODULE_RELOCATION.md` is a synthesis task, not a
  from-scratch draft.

## Context & Scope

`scripts/move-modules.py` is a one-shot relocation tool (582 lines) built in task 630 and reused
across four subsequent module moves (632, 634, 635, plus 630's own Boneyard move). Each use
surfaced a distinct correctness gap, hand-caught by review or by a dry run, never by a gate. This
task hardens the five gaps named in the dispatch and writes the operational playbook a future move
should read first. The task is explicitly low priority (payoff conditional on another scripted
move happening) except for the documentation half, which the dispatch says stands alone.

This report covers research only: locating and characterizing each gap against the tool's actual
code and against the four summaries' primary evidence, and surfacing implementation-relevant
facts (existing conventions, naming precedents, a repository-layout correction) for the planning
phase. It does not design the fix implementations.

## Findings

### (a) Historical-statement falsification — every move, no gate catches it

- The tool's dotted/slash/namespace regexes (`Mapping.dotted_re`, `.slash_re`;
  `NamespaceMapping.dotted_re`) match a bare old-name occurrence **anywhere** a rewrite class
  applies to the file (`classes_for()`, `move-modules.py:200-216`), with no notion of tense or
  of "this is prose about the past." A `namespace`/`open`/FQN token and a "moved from X to Y"
  sentence's `X` are syntactically identical to the regex.
- Task 630: seven "from X to Y" statements collapsed into "from Y to Y" across
  `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md` and
  `docs/development/PUBLICATION_REFACTOR.md`; the tool also rewrote its own worked-example
  docstring into self-contradictions (fixed by excluding `SELF_PATH` — `move-modules.py:197-208`,
  which is documented in the current docstring's "Exclusions" paragraph but was a **post-hoc**
  fix, not a designed-in one).
- Task 632: a harness header comment "just given" to the tool was rewritten (no separate
  quotation found in the summary beyond the dispatch's own claim; treat as consistent with the
  same mechanism).
- Task 634: three merged READMEs' historical statements were collapsed (per dispatch); the
  summary additionally records the tool rewrote 34 `namespace`/`end` lines as an *intended*
  effect, showing the same regex machinery used for both wanted and unwanted rewrites — there is
  no per-site tense distinction available to a purely lexical pass.
- Task 635 gives the fullest account and the fix heuristic actually used: "does the sentence
  assert something about the past? A provenance column, an 'original location', a 'used to be', a
  dated audit stamp — historical, revert. A navigational link, a 'the live tree keeps', a
  'develops toward' — present tense, update." 17 Boneyard provenance READMEs (headed "Path before
  consolidation" / "Live origin before archival") and `typst/SYNC-MAP.md` (which states outright
  "its historical stamps are preserved as written") were reverted wholesale and 4 lines
  hand-reapplied. This is exactly deliverable (1)'s `--no-rewrite` default list rationale.
- **Inverse error, same root cause**: task 635 also found 10 stale present-tense citations the
  tool's bare-form exclusion left untouched, including the repository root `README.md`. A
  `--no-rewrite` list only suppresses false-positive rewrites; it does nothing for false-negative
  skips, which remain a hand-audit responsibility. `docs/development/MODULE_RELOCATION.md` should
  state this limitation explicitly rather than implying `--no-rewrite` is a complete fix for class
  (a).
- **Repository-layout fact for deliverable (1)'s default list**: `docs/adr/` does not exist in
  this repository; ADRs live at `docs/architecture/ADR-*.md` (confirmed: `ls docs/adr` fails,
  `docs/architecture/` holds `ADR-001` through `ADR-011`). The default `--no-rewrite` path list
  should read `docs/architecture/ADR-*.md` (or `docs/architecture/**` if any historical prose is
  suspected outside the ADR files themselves — `docs/architecture/README.md` and
  `BFMCS_ARCHITECTURE.md` also live there and are not obviously historical-statement-bearing, so a
  narrower `ADR-*.md` glob is likely the more defensible default).
- `Boneyard/**/README.md` currently matches 56 files (post-635, across the whole consolidated
  archive), not the 17 specific to task 635's `WeakCanonical` subtree — the glob is
  appropriately move-agnostic; it will also catch provenance READMEs in parts of the archive no
  future move touches, which is safe (they are "reported but never rewritten", not excluded from
  the walk).

### (b) resolve_move directory-over-file preference; move_trees silent no-op

- `resolve_move()` (`move-modules.py:383-404`) already carries a docstring naming the exact hazard
  deliverable (3) targets: "Only the directory case existed when this tool was written, and a
  file-granular row silently reported `skip ... (not present)` — every citation rewritten, nothing
  moved, and a report that looked orderly. The directory is preferred when both somehow exist,
  matching the prefix semantics of the module map itself." This is task 632's bug, fixed once
  already (the pre-fix behavior task 632 encountered), but the **current** code still silently
  prefers the directory when both a directory and a `stem + ".lean"` file exist (lines 400-403:
  `if os.path.isdir(stem): return stem, ""` short-circuits before the file check ever runs) —
  deliverable (3) asks for this specific case (both exist) to become a loud non-zero exit naming
  both, not a silent directory preference.
- Task 634 is the concrete near-miss for the *other* half of this hazard class: the plan assumed
  one tool invocation could carry both file-granular rows and a directory-aggregator row on the
  same relocation, expecting the file rows to "consume" the directory first. They do not —
  `resolve_move()` resolves every mapping independently against the **current on-disk state**
  before any move executes, so all three aggregator rows resolved to the directory up front (the
  silent-orphan hazard: `Syntax/{X}Language.lean`, a same-named sibling file, orphaned with its
  citations already rewritten). Caught only by the dry run, not by any assertion. This is
  evidence the deliverable (3) fix must apply per-mapping, at each mapping's own resolution time
  in the run, not merely once at start — or the run must reject any module map whose rows would
  create this file/directory ambiguity for each other (a directory row and a file row sharing a
  stem prefix), which is a related but distinct check worth naming for the planning phase.

### (c) `--namespace-map` is an unscoped repo-wide rewrite

- `NamespaceMapping.dotted_re` (`move-modules.py:140-141`) is a single global regex per mapping,
  applied via `apply_namespace()` to every file `classes_for()` marks as `dotted`/`slash`-eligible
  (`.lean`, `.md`, `.typ`, plus `scripts/*.sh|.py|.txt`) — there is no notion of "files this move
  actually touches" versus "files elsewhere in the tree that happen to share the old namespace
  prefix." Nothing in `load_mappings()`, `run()`, or `apply_namespace()` cross-checks a namespace
  mapping's `old_ns` against the file set the corresponding module mapping actually relocates.
- Task 634's residual-namespace problem (three `TaskFrame.{Minus,Plus,Star}ValidOn` declarations
  had to stay in `namespace FormalSystem.Semantics` for dot-notation reasons) and task 635's
  20-residual-modules problem (`WeakCanonical` stayed as a residual namespace for files that did
  not move, while `Expressiveness` was the new name for files that did) are both instances of
  exactly the shared-bare-prefix hazard the dispatch names
  (`FormalSystem.Metalogic.WeakCanonical`, `FormalSystem.Automation`,
  `FormalSystem.Semantics` are cited explicitly). In each case the fix was manual — hand-editing
  the residual files out of the shared namespace, or simply not using `--namespace-map` for the
  shared prefix and doing the namespace rename by hand instead (632's summary: "6 files
  hand-edited out of the shared bare `FormalSystem.Automation` namespace (a bare map row would
  have rewritten the staying library's own namespace)"). Deliverable (4)'s refusal check and
  `--namespace-paths` scoping mechanism would let `--namespace-map` be used directly in these
  cases rather than requiring a hand-rewrite workaround every time.
- `--namespace-paths` will need a definition of "the moved files" available at namespace-rewrite
  time — that set is exactly what `move_trees()` computes (via `resolve_move()` per mapping) but
  currently only for `git mv` purposes; the namespace-rewrite pass in `run()`'s main loop happens
  earlier in program order (in `rewrite_text()`, called before `move_trees()` at line 511) and
  currently has no data dependency on the move-set at all. The planning phase should note this
  ordering: either resolve the move set before entering the rewrite loop (already available data,
  since `resolve_move()` is a pure filesystem query independent of dry-run/apply), or compute
  `--namespace-paths`' scope independently from the file/glob argument the flag takes, without
  going through `resolve_move()` at all. The latter is simpler and matches the flag's stated
  purpose ("scope the rewrite to the moved files" — an explicit user-supplied list is more
  auditable than an inferred one, and avoids the ordering dependency entirely).

### Deliverable (2): identical-sides-of-a-rewrite warning

- No related detection exists today. The tool's only "did I do something suspicious" check is the
  bare-form audit (`bare_form_count`, sentinel re-run in `run()` lines 495-500), which is a
  **different** failure class — accidental rewriting of an already-relative bare citation — not
  the historical-statement collapse this deliverable targets. The two are easy to conflate in the
  plan; they should stay separate mechanisms (the bare-form audit already exits 1 unconditionally
  on any mismatch, no `--strict` gate; deliverable (2)'s new check needs its own warning/`--strict`
  promotion path).
- The concrete shape to catch: a line containing the old name and the new name adjacent in a
  templated pattern (`"from {old} to {new}"`, or a two-column table row `"| {old} | {new} |"`)
  where, after per-mapping substitution, both sides read identical because the substitution
  target *was* the "to" side already. This needs a per-line, per-mapping post-substitution
  comparison against a small set of "two-sided" patterns (an explicit "X to Y" / "X -> Y" phrase,
  or a markdown table row with 2+ cells) — a general "did this line's rewrite make two
  spans identical" check, not scoped only to `->`-shaped module-map syntax (the map file's own
  `old -> new` syntax reuses that separator and must not trip the same detector when parsing
  `--module-map`/`--namespace-map` files themselves, though those files are not part of the
  repository walk `walk_repo()` performs, since they typically live under `specs/`, itself pruned
  — worth an explicit non-goal note in the plan either way).

### Deliverable (5): report/exit-code gap

- `report()` (`move-modules.py:527-559`) prints class 1-7 counts, `moved` paths, and the bare-form
  audit — but never cross-references "citations rewritten" against "files actually moved" as a
  single asserted invariant. `run()`'s exit logic (lines 516-524) is: fail if
  `bare_before != bare_after`; fail if `move_failures`; otherwise succeed (dry-run/no-verify) or
  propagate the harness exit code. There is no branch for "rows were requested (mappings loaded,
  guaranteed non-empty by `parse_map`'s `if not pairs: sys.exit(...)`) and zero files ended up in
  `moved`."
- This is precisely task 632's discovered defect before its own fix: "the first dry run moved
  **0 paths** while cheerfully reporting 236 citation rewrites" — reproduced today by any
  file-granular-only module map whose stems happen not to resolve (e.g., a typo in a leaf module
  name), since `move_trees()`'s per-row `continue` on `resolve_move() is None` accumulates no
  failure count at all, only a printed `skip` line. `moved` staying empty while `changed`
  (citation rewrites) is non-empty is a well-defined, easily-asserted condition for the fixture
  test this deliverable's acceptance criterion names.

### Testing infrastructure gap (cross-cutting, relevant to all fixture-test acceptance criteria)

- No pytest, unittest, or shell-based fixture-test harness exists anywhere under `scripts/` today
  (`grep -rl fixture scripts/` matches only an unrelated pyc file and a lean-debug helper's
  docstring use of the word). The five fixture tests deliverables (1)-(5) require will need new
  scaffolding, not an extension of an existing one.
- `move-modules.py` hard-refuses to run outside a git repository root (`main()`,
  `move-modules.py:576-577`: `if not os.path.isdir(".git"): sys.exit(...)`) and Class 6
  (`move_trees`) shells out to `git mv` directly. A fixture harness therefore needs either (a) a
  disposable `git init`-ed temp directory per test case (clean, fully isolated, but pays `git`
  process overhead per test) or (b) monkeypatching/stubbing `subprocess.run` for the `git mv` call
  while still supplying `os.path.isdir(".git")` truthily via a fake `.git` directory marker — the
  latter is more surgical for tests that only need to exercise Classes 1-5 and 7 (rewrite-class
  correctness) without touching the filesystem move at all. The planning phase should pick one
  approach; a real disposable git repo is more faithful to the dry-run reproduction the acceptance
  criteria explicitly ask for ("a dry run reproducing task 635's move reports the 17 provenance
  READMEs as skipped"), which argues for (a) at least for that specific acceptance test.
- `run(args)` takes an `argparse.Namespace`, so a fixture test can construct one directly
  (`argparse.Namespace(module_map=..., namespace_map=None, dry_run=True, no_verify=True, ...)`)
  and call `run()` in-process rather than shelling out to the CLI — cheaper and gives direct
  access to return codes without parsing stdout, though the acceptance criteria for (1) and (5)
  specifically reference *report* text ("reported but never rewritten", "the report states..."),
  so at least those fixture tests likely need to capture and assert on the printed report, which
  argues for capturing stdout (`contextlib.redirect_stdout`) around an in-process `run()` call
  rather than parsing subprocess output — both avoid a full CLI subprocess round-trip.

### Deliverable (6): docs/development/MODULE_RELOCATION.md — existing raw material

Much of the requested content already exists in scattered, precise form and should be synthesized
rather than authored from scratch:

- **The seven rewrite classes**: documented near-verbatim in `move-modules.py`'s own module
  docstring, lines 27-37 (Classes 1-7 with one-line descriptions each) — the doc can summarize
  this at a higher level and point to the docstring as the executable source of truth, or restate
  it; either is legitimate, but should not silently drift from the code's own class numbering.
- **The bare-form trap**: `move-modules.py:38-52` ("The bare-token trap" section of the docstring)
  already explains the mechanism and the exclusion rationale precisely.
- **resolve-map-recompute for relative links**: `rebase_links()`'s own docstring
  (`move-modules.py:343-353`) names the algorithm and explicitly rejects the naive alternative
  ("Resolve-map-recompute, never `../`-counting... A heuristic that merely strips one `../` per
  level of depth change gets the cases wrong...").
- **Assert-the-denominator**: already a named principle in `docs/development/MODULE_INVARIANTS.md`
  at the C11 row ("When re-rooting a counting gate, assert the denominator, not just the PASS"),
  itself citing the concrete incident (C11's own import regex, reusing C4's pattern, would match
  no archived module name and print PASS on an empty denominator). Task 630's summary makes the
  same point for a different gate (C11's "539 archived import lines across 169 files, 8 waived —
  the carried pre-move figure, which is what distinguishes a real pass from a PASS on a shrunken
  denominator").
- **Widen every gate's scan root BEFORE the move, so each widening is a verifiable no-op**: this
  is task 632's central, explicitly-named methodology ("The plan's central commitment — widen
  every gate's scan root **before** anything moves, so a narrowing is loud rather than silent —
  was executed and paid off twice"), and task 630's Decisions section states the atomicity
  argument precisely ("Widened first, the pre-existing bare `Boneyard/…` citations enter C12 scope
  while the archive is still under `FormalSystem/`, where they do not resolve; moved first, 46
  citations silently leave scope with a green board. Neither ordering is green, so they are
  atomic.").
- **Re-rooting a gate to a top-level directory narrows what a path-shaped pattern can match**:
  task 630's Phase 7 deviation is the exact worked example — 46 pre-move-gated citations, only 26
  remained gated post-move, because 20 cited the archive root itself and "neither a path-shaped
  nor a module-shaped pattern gates a bare top-level name." Task 634's Impacts section gives a
  second instance: the three language directories sit outside `LAYERS`, so `layer_of` returns
  `None` for them and every import into/out of them is invisible to the upward-edge measurement —
  "No harness check catches a regression here."
- **Exe roots sit outside every build closure; only the build-inclusive harness (C25) catches a
  broken one**: `MODULE_INVARIANTS.md`'s C25 row states this precisely, with the
  `BimodalTools/ProofExtractorMain.lean` incident (873 masked errors, tree green throughout,
  because no gate could observe it) as the motivating case. Task 632's Decisions section is a
  second, independent occurrence: "5 of the 13 [exe] roots did not compile" while `lake build`,
  the two library builds, and `lake test` were all green — "C25 is what caught it."
- **A namespace-audit simulation must precede any directory merge**: task 634's Decisions section
  is the direct source ("The plan assumed one `move-modules.py` invocation could carry both the
  file rows and the three syntax-aggregator rows... They do not... Caught in the dry run"), and
  `measure-refactor-partitions.py`'s existing `namespace-audit` mode (used post-hoc in task 634:
  "`measure-refactor-partitions.py namespace-audit`: `unrelated` = 8, verified by name") is the
  concrete tool this doc should point to as the pre-merge simulation step, run *before* committing
  to a directory-merge module map rather than only as a post-move verification.
- **The historical-statement blind spot**: task 635's Decisions section, quoted in Finding (a)
  above, is the fullest and most usable account, including the explicit test ("does the sentence
  assert something about the past?") and the inverse-error caveat (stale present-tense citations
  the bare-form rule leaves untouched).
- The doc belongs at `docs/development/`, not `.claude/context/` — the dispatch states this
  directly ("There is no agent-system/ source store in this repository") and it is consistent with
  every other operational playbook already in that directory (`MODULE_INVARIANTS.md`,
  `MODULE_ORGANIZATION.md`, `PUBLICATION_REFACTOR.md`).
- **Task-number citation constraint**: `check-module-invariants.sh`'s C9-DOCS check
  (`ENFORCE_C9_DOCS=1` by default, confirmed at `scripts/check-module-invariants.sh:564`) gates
  `docs/**/*.md` for task-number citations and fails the harness on any hit. The acceptance
  criterion "No task numbers in any file outside specs/" is therefore not just a style rule here —
  it is mechanically enforced by the same `--no-build` harness run the other acceptance criterion
  names, so both acceptance criteria can be satisfied by the same single gate invocation.

## Decisions

None — this is a research-only dispatch; no code or documentation changes were made. The one
substantive correction (the `docs/adr/**` → `docs/architecture/ADR-*.md` path fact) is recorded
above as a finding for the planning phase to act on, not a decision made here.

## Recommendations

1. **Planning phase should treat deliverables (1)-(5) as five independent, small, separately
   fixture-tested changes to `move-modules.py`**, each with a red-before/green-after test built
   against a disposable temp git repo (see Testing infrastructure gap above) — the acceptance
   criteria are already phrased this way and each deliverable's failure mode has a concrete,
   citable historical reproduction to build the fixture from.
2. **Fix the `docs/adr/**` path in deliverable (1)'s default list** to `docs/architecture/ADR-*.md`
   before implementation, since `docs/adr/` does not exist in this repository.
3. **Keep deliverable (2)'s new check separate from the existing bare-form audit** — they detect
   different failure classes (accidental-collapse-to-tautology vs. accidental-bare-citation-
   rewrite) and conflating them risks either weakening the existing audit's unconditional-fail
   behavior or making the new check inherit exemptions that do not apply to it.
4. **For deliverable (3), decide explicitly whether the ambiguity check runs once up front over
   all mappings or per-mapping at each mapping's resolution point** — task 634's near-miss shows
   the ambiguity can depend on which mappings have already been "consumed" by earlier moves in the
   same invocation, so a single up-front check may not be sufficient if a future relocation batches
   a directory row and a file row that only become ambiguous relative to each other (not each
   individually ambiguous against the pre-move tree).
5. **For deliverable (4)'s `--namespace-paths`, take an explicit user-supplied path/glob argument
   rather than inferring the moved-file set from `resolve_move()`** — this sidesteps the
   rewrite-loop-runs-before-move-resolution ordering issue identified above and is more auditable,
   consistent with the tool's existing design principle (stated in its own docstring) that mapping
   files are the sole source of truth and nothing is "derived" that could silently drift.
6. **Treat `docs/development/MODULE_RELOCATION.md` as a synthesis task**: the plan should draft it
   by pulling near-verbatim from the six sources identified in the Deliverable (6) finding above
   (the tool's own docstring for classes/bare-token-trap/resolve-map-recompute,
   `MODULE_INVARIANTS.md`'s C11/C25 rows for assert-the-denominator and the exe-root blind spot,
   and the four task summaries' Decisions/Follow-ups sections for the rest) rather than drafting
   fresh prose, to keep the doc's claims traceable to their original incidents.
7. **Since C9-DOCS already gates task-number citations under `docs/`**, verifying the new doc
   passes `check-module-invariants.sh --no-build` (the acceptance criterion already names this)
   is sufficient to also verify the "no task numbers" acceptance criterion — no separate grep is
   needed in the plan or implementation phase.

## Risks & Mitigations

- **Risk**: a fixture test built against a real disposable git repo could be slow or flaky in CI
  if not carefully isolated (temp dir cleanup, no reliance on the ambient repo's `.git` config).
  **Mitigation**: use `tempfile.TemporaryDirectory()` plus a minimal `git init -q` and
  `git -c user.email=... -c user.name=... commit` sequence scoped entirely to the fixture, never
  touching the real repository's working tree.
- **Risk**: deliverable (2)'s "two sides became identical" heuristic could produce false positives
  on legitimate cases where old and new names are supposed to coincide in a rewritten sentence
  (e.g., a sentence that already read correctly and happens to repeat the new name twice for
  emphasis). **Mitigation**: scope the check narrowly to sentences/rows that *only* became
  identical as a direct consequence of the mapping's own substitution (compare pre- and
  post-rewrite versions of the same span, not just the post-rewrite text in isolation) — the
  bare-form audit's sentinel-rerun technique (`move-modules.py:222-233`, `:495-500`) is a directly
  reusable pattern for this kind of before/after distinction.
- **Risk**: `--namespace-paths` scoping could interact awkwardly with Class 4's current behavior of
  rewriting `namespace`/`open`/FQN occurrences inside the **moved** files themselves (which must
  still be rewritten) versus in files that reference the moved declarations from elsewhere.
  **Mitigation**: the plan should explicitly define whether `--namespace-paths` scopes "files
  whose namespace rewrite is applied" to only the listed paths (excluding citation sites) or to
  "files where the check for ambiguity/conflict applies" while rewriting still occurs tool-wide —
  these are different scoping semantics and the dispatch's wording ("scope the rewrite to the
  moved files") suggests the former, but that would break external citation rewriting the tool
  currently and correctly performs (e.g., task 632's 13 `open BimodalTools` external sites).

## Context Extension Recommendations

- **Topic**: Lean-adjacent Python tooling (`scripts/*.py`) has no fixture-test convention anywhere
  in this repository.
  **Gap**: no `docs/development/` or `.claude/context/` file documents how a `scripts/*.py` change
  should be tested; `check-module-invariants.sh` covers structural/build invariants but not
  script-internal unit behavior.
  **Recommendation**: once this task establishes a fixture-test pattern for `move-modules.py`,
  consider documenting the pattern (temp-git-repo fixture, in-process `run()` invocation,
  stdout capture) as a reusable convention for future `scripts/*.py` hardening work — out of this
  task's scope, but worth flagging for later.

## Appendix

- Search/read queries used: `Read scripts/move-modules.py` (full); `Read` on all four task
  summaries listed under Sources/Inputs; `grep -n "^# C[0-9]\|check_c[0-9]"`
  `scripts/check-module-invariants.sh`; `sed -n` extracts of `MODULE_INVARIANTS.md` lines 1-40 and
  `check-module-invariants.sh` lines 4516-4549, 564; `find`/`ls` probes of `docs/adr`,
  `docs/architecture/`, `Boneyard/**/README.md` (count), `typst/SYNC-MAP.md`;
  `grep -rl fixture scripts/`; `grep -n "namespace-audit\|def main\|add_argument"
  scripts/measure-refactor-partitions.py`; `jq` query of `.claude/context/index.json` for
  existing lean4/general module-relocation coverage (none found).
- Relevant existing files (unmodified by this research pass): `scripts/move-modules.py`,
  `scripts/check-module-invariants.sh`, `scripts/measure-refactor-partitions.py`,
  `docs/development/MODULE_INVARIANTS.md`.
