# Implementation Plan: Task #768

- **Task**: 768 - Fix three independent defects in `lean-challenge-snapshot.sh`
- **Status**: [IMPLEMENTING]
- **Effort**: 9 hours
- **Dependencies**: None
- **Research Inputs**: specs/768_lean_challenge_snapshot_chunk_and_unicode_defects/reports/01_snapshot-chunk-and-unicode-defects.md
- **Artifacts**: plans/01_snapshot-chunk-and-unicode-defects.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Three defects in `lean-challenge-snapshot.sh` are repaired in one record because they share the
same four Python regex sites. Defect (a) (declaration-chunk boundary over-reach swallowing
`abbrev` and anonymous `instance`) and defect (b) (ASCII-only identifier class) are fixed by
replacing four independently-written regex literals with two shared definitions, then widening
the chunk-boundary match while deliberately **decoupling** boundary detection from name
harvesting and body forcing. Defect (c)'s remaining non-keyword residual is fixed structurally,
by narrowing Goals-identifier extraction to an identifier-leading bullet position, with the
newly-narrowed accepted surface stated in the script's own documentation and (behind a
cross-repo coordination gate) in `plan-format.md`. The `--dry-run` compile step is added as the
defect-(a)-generalizing safety net the originating request called higher-leverage.

### Research Integration

The research report reproduced all three defects live against the source store and is the
authority for the site inventory. Three of its conclusions were re-derived at plan-authoring
time, and two were corrected:

- **Confirmed**: the four ASCII-only identifier sites are all Python, at source-store lines
  235, 393, 492, 610. The dispatch's "fourth, non-Python `grep -oP` site at line 382" no longer
  exists — the landed preamble repair rewrote `extract_goal_names()` into a Python helper.
- **Confirmed**: R8 (Goals preamble exclusion) is already landed and uncommitted beyond what the
  dispatch describes. `git status` in the source store shows exactly three paths: two modified
  (`lean-challenge-snapshot.sh`, `tests/test-lean-challenge-snapshot.sh`) and one untracked
  (`tests/fixtures/challenge/plan_goals_preamble.md`). The dispatch's "two UNTRACKED fixtures"
  is stale — `plan_list_item_goals.md` and `plan_keyword_noise.md` are already tracked.
- **Corrected (blocking, if missed)**: the report states a redeploy "resolves [the missing
  deployed fixture] automatically". It does not. `agent-system/extensions/lean/manifest.json`'s
  `provides.scripts` array enumerates **every challenge fixture individually**, and
  `plan_goals_preamble.md` is absent from it (`grep -c` returns 0). A redeploy copies only what
  the manifest lists, so the deployed suite keeps failing R8 until `manifest.json` is edited.
  `manifest.json` is therefore in this plan's scope, and **every new fixture this plan adds must
  also be registered there**.
- **Corrected**: the report's recommendation 3 concrete form — "harvest only the first backticked
  token immediately after a bullet's leading `- `" — would drop genuine Goals in two existing
  green fixtures. `plan_r1.md` and `plan_keyword_noise.md` both place the identifier mid-sentence
  (`- Prove `comm` for natural number addition.`), so that rule harvests nothing from them and
  turns R1/R7 red. The rule adopted below keeps the identifier-leading position but pairs it with
  explicit fixture migration rather than assuming backward compatibility.
- **Confirmed**: the cross-repo sibling record `lean4_plan_with_zero_lean_goals` (task 385 in the
  source-store repository's own task space) is still `not_started`, and claims
  `plan-format.md`, `lean-challenge-snapshot.sh`, and `challenge-snapshot.md`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch; no ROADMAP.md consultation performed.

## Goals & Non-Goals

**Goals**:

- Stop `abbrev` and anonymous `instance` declarations from being silently absorbed into the
  preceding declaration's forced-`sorry` body (defect a), at every site that decides what counts
  as a declaration boundary.
- Make the identifier class Unicode-aware at all four sites, from **one shared definition**, so a
  non-ASCII Lean name neither escapes the Goals cross-check nor is truncated into a colliding
  name (defect b).
- Narrow Goals-identifier extraction structurally so ordinary backticked prose is not read as a
  committed declaration name, without ever dropping a genuine Goal and without extending the
  keyword denylist or filtering against the declared set (defect c).
- State the accepted Goals surface in documentation, so the script never silently accepts a
  narrower surface than the examples advertise.
- Extend `--dry-run` with a compile step that converts a silent swallow into a loud failure.
- Commit the already-landed R6/R7/R8 work and carry it into the deploy tree.

**Non-Goals**:

- Changing the equality semantics of `cross_validate_identifiers()`. The Goals set and the
  declared set are still compared for equality; narrowing one side is never done by filtering it
  through the other (the explicitly-named trap).
- Extending `LEAN_KEYWORDS`. The denylist is at its natural ceiling; every residual token
  (`Nu`, `witness`, `EUFix`, `true`) is a legal Lean declaration name.
- Supporting dotted identifiers (`Branch.cell`) in the Goals harvest. Dotted names do not match
  today and still will not; this is a pre-existing limitation, out of scope here.
- Re-implementing or re-justifying R6, R7, or R8. They are landed; they are committed, verified
  still green, and otherwise untouched.
- Editing `context/project/lean4/domain/challenge-snapshot.md`. It is claimed by the sibling
  cross-repo record and is deliberately not in this record's scope.
- Hand-editing anything under `.claude/**`. That tree is a regenerated deploy artifact.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Widening the boundary alternation also widens `declared_names`, newly **requiring** every `abbrev` to be a Goal and failing plans that pass today | H | H | Phase 3 decouples the three concerns explicitly: a boundary-only match set, a narrower name-harvest set, and a narrower body-forcing set. A regression assertion pins that an `abbrev` contributes no name. |
| Forcing a newly-recognized `abbrev`/`instance` body to `sorry` makes the assembled module non-compiling (`abbrev Bar := sorry` is unusable by downstream theorems) | H | M | Phase 3 preserves newly-recognized definitional bodies verbatim rather than forcing them; the Phase 5 compile step is the check that would catch the alternative being wrong. |
| The narrowed Goals rule drops a genuine Goal in an existing fixture or landed plan | H | H (if the report's drop-in form were used) | Already measured: `plan_r1.md` and `plan_keyword_noise.md` are mid-sentence shapes and are migrated explicitly in Phase 4. A non-conforming plan gets a loud, actionable exit, never a silent omission. |
| New fixtures are not registered in `manifest.json`, so the deployed suite fails even after a clean redeploy | M | H | Measured and corrected above; fixture registration is an explicit step in Phases 1, 4, and 5, and Phase 6 verifies deployed-tree suite parity rather than trusting the redeploy. |
| Cross-repo collision: the sibling record claims `lean-challenge-snapshot.sh` and `plan-format.md`, with no mechanical dependency edge spanning the two repositories | M | L | Phase 4's decision gate re-checks that record's status immediately before any `plan-format.md` edit; if it has moved off `not_started`, the one-sentence clarification is handed to that record instead of made here. |
| Unicode names sort differently on the two sides of `comm`, producing a false mismatch | M | L | UTF-8 byte order equals code-point order, so `LC_ALL=C comm` and Python `sorted()` already agree; Phase 2 asserts this with a non-ASCII name rather than assuming it. |
| The compile step cannot run in the test suite's throwaway repos (they are not Lake projects) | M | H | Phase 5 designs the step to detect an absent toolchain and degrade to an announced skip, and the test cases assert both the skip path and the non-compiling path via a stubbed toolchain on `PATH`. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel. Every wave here holds exactly one phase:
all phases edit the same two files (`lean-challenge-snapshot.sh` and its suite), so the chain is
genuinely serial and no parallelism is available to claim.

**Source-store boundary, applying to every phase below.** Resolve `source_dir` from
`/home/benjamin/Projects/BimodalLogic/.claude-extensions.json` for the `lean` extension
(expected: `/home/benjamin/.config/nvim/agent-system/extensions/lean`) and edit at the mirroring
path there. The `.claude/**` path in this task's `file_scope` is declared only so the admission
overlap gate can see the collision surface; it is never the edit target.

**Deliverable hygiene, applying to every phase below.** Every file edited by this plan is outside
`specs/**`. No edited file's prose may carry a task number, an issue `entry_id`, or
record-versioning language ("previously", "no longer", "used to", "v1"). Describe the Goals rule
in terms of what the code **now accepts**, never as a narration of what it once rejected. Cite
durable anchors only: file names, function names, flag names, section headings.

---

### Phase 1: Commit the Landed Work and Close the Fixture-Registration Gap [COMPLETED]

**Goal**: Put the already-landed R6/R7/R8 repair under version control, register the one fixture
the deploy manifest is missing, and establish a re-derived green baseline every later phase is
diffed against.

**Tasks**:

- [x] Re-check the sibling cross-repo record's status in the source-store repository's own
      `specs/state.json` (expected `not_started` for `lean4_plan_with_zero_lean_goals`). If it has
      moved to an active status, stop and record a blocker rather than editing the shared script.
      *(completed: confirmed `not_started` for project_number 385)*
- [x] Re-derive the uncommitted set with `git status --porcelain -- agent-system/extensions/lean/scripts/`
      in the source store. Confirm it is exactly two modified files plus the one untracked fixture.
      *(completed: confirmed exactly 2 modified + 1 untracked)*
- [x] Run the source-store suite and record the exact baseline counts. Do not carry the figure
      from this plan: re-derive it.
      *(completed: 17 passed, 0 failed, 0 skipped, matching the plan's Scope Hypothesis)*
- [x] Add `tests/fixtures/challenge/plan_goals_preamble.md` to `provides.scripts` in
      `agent-system/extensions/lean/manifest.json`, placed beside the other challenge fixtures.
      *(completed)*
- [x] Validate `manifest.json` still parses as JSON after the edit. *(completed)*
- [x] Commit the two modified files, the untracked fixture, and `manifest.json` with explicit,
      per-file staging (never `git add -A`, `.`, a directory pathspec, or `commit -am`).
      *(completed: source-store sha 80d43b2e2)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the uncommitted set is exactly three paths and that the
source-store suite currently reports 17 passed / 0 failed / 0 skipped. Both were measured at
plan-authoring time and both can drift. Confirm by re-running `git status --porcelain` and the
suite before committing, and reconcile any difference in the phase's own notes rather than
forcing the figures to match this plan.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for every
lean-extension script path, meaning no mapped suite covers this file, so the covering check is
named directly: `bash agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh`
together with `python3 -c "import json; json.load(open('manifest.json'))"` for the manifest edit.

**Files to modify**:

- `agent-system/extensions/lean/manifest.json` - register `tests/fixtures/challenge/plan_goals_preamble.md` in `provides.scripts`
- `agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh` - commit the landed modification unchanged (no new edits in this phase)
- `agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` - commit the landed modification unchanged
- `agent-system/extensions/lean/scripts/tests/fixtures/challenge/plan_goals_preamble.md` - commit the untracked fixture

**Verification**:

- `bash agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` exits 0 with
  zero failures, and the recorded pass count matches the re-derived baseline.
- `grep -c plan_goals_preamble agent-system/extensions/lean/manifest.json` returns a non-zero count.
- `git status --porcelain -- agent-system/extensions/lean/` is empty for the four paths above
  after the commit.

---

### Phase 2: One Shared Unicode-Aware Identifier Definition, Consumed by All Four Sites [COMPLETED]

**Goal**: Replace four independently-written ASCII-only identifier literals with a single shared,
Unicode-aware definition, so the Goals identifier set and the declared identifier set can never
again disagree about how to spell a name.

**Mechanism decision.** The four sites live in four separate quoted heredocs
(`python3 - ... <<'PYEOF'`), so no shell expansion reaches them and a shared definition cannot
simply be interpolated. Define the pattern **once** as a shell variable exported immediately
before the helpers, and read it in each heredoc via `os.environ`. This keeps every heredoc
`'PYEOF'`-quoted (so no `$` inside Python code is at risk of expansion), introduces no new
deployed file to register in the manifest, and leaves all four `argv` contracts unchanged. A
sibling Python module under `scripts/lib/` was considered and rejected: it would add a new
manifest-registered deploy artifact and a `sys.path` bootstrap in four places for no gain over
one exported variable.

**Pattern decision.** Use `[^\W\d][\w']*` — a word character that is not a digit, followed by
word characters and apostrophes, under Python's default Unicode `re` mode. Verified empirically
at plan-authoring time: it matches `foo`, `foo_bar`, `foo₁`, `foo₁₂`, `αβ`, `Σx`, `_priv`, `x'`
and rejects `1foo`, `a.b`, `foo%`. It also spans `foo₁` **in full**, where the current ASCII
class matches only the leading `foo` — which is the truncation-collision mechanism itself. It
over-accepts a leading subscript (`₁foo` matches, because `₁` is Unicode category No and `\d`
does not exclude it); this is harmless, since over-accepting a shape no real Lean name uses can
never drop a real identifier.

**Tasks**:

- [x] Re-derive the four site locations by pattern, not by line number:
      `grep -n "A-Za-z\|a-zA-Z" agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh`.
      *(completed: confirmed exactly 4 sites, at lines 235, 393, 492, 610 before this phase's edits)*
- [x] Define and export the shared identifier pattern once, above `do_check()`, with a header
      comment stating what it accepts and why one definition exists rather than four.
      *(completed: `export LEAN_IDENT_PATTERN="[^\W\d][\w']*"`)*
- [x] Replace the identifier class at all four sites with a read of the shared definition:
      `do_check()`'s `DECL_HEADER_RE`, `extract_goal_names()`'s `TOKEN_RE`, `extract_r1()`'s
      `DECL_RE`, and `extract_r2()`'s `DECL_HEADER_RE`. Removing the redundant `A-Za-zA-Z0-9`
      range falls out of this replacement rather than being a separate edit. *(completed)*
- [x] Assert no ASCII-only identifier literal survives anywhere in the file.
      *(completed: `grep -n "A-Za-z\|a-zA-Z"` returns no matches)*
- [x] Add failing-first test case **R9**: a declaration whose name carries a non-ASCII character,
      named under `**Goals**:` and declared in the `## Lean Challenge Statements` block, snapshots
      cleanly (exit 0) with that name appearing **in full** in `theorem_names` and in the
      assembled module. Add its fixture and register the fixture in `manifest.json`.
      *(completed: fixture plan_r9_unicode.md)*
- [x] Add failing-first test case **R10**, the truncation-collision guard: a Goals bullet naming
      the ASCII prefix of a non-ASCII declared name must **fail** cross-validation rather than
      silently passing. This is the case that currently exits 0 while recording the wrong
      identifier, so it is the mutation-killing half of defect (b).
      *(completed: fixture plan_r10_truncation.md)*
- [x] Confirm the two sides still sort consistently for a non-ASCII name (Python `sorted()` versus
      `LC_ALL=C comm`), rather than assuming UTF-8 byte order and code-point order agree.
      *(completed: both order ['assoc', 'comm₁', 'zed'] identically)*
- [x] Demonstrate R9 and R10 fail against the script as it stands before this phase's edits, and
      pass after. *(completed: verified against the Phase-1 commit sha 80d43b2e2 — R9 exited 71
      "no identifiers found", R10 exited 0 with the wrong truncated name "comm"; both now behave
      as specified)*

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts there are exactly four identifier-class sites, at
source-store lines 235, 393, 492, and 610. Line numbers are not durable anchors and will shift
as this phase edits the file. Confirm the count by re-running the `grep` above both before and
after, and assert the post-edit count of surviving ASCII-only literals is zero.

**Tier Justification**: All four sites are inside one file with no externally visible signature
change, and no mapped suite covers it (`suite_selection_select` returns `__FULL_SWEEP__`), so the
covering check is named directly:
`bash agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh`.

**Files to modify**:

- `agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh` - add the shared exported identifier pattern; replace the ASCII-only class at all four Python sites
- `agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` - add cases R9 and R10; extend the header comment's case inventory
- `agent-system/extensions/lean/scripts/tests/fixtures/challenge/` - new fixture(s) for the non-ASCII-name and truncation-collision cases
- `agent-system/extensions/lean/manifest.json` - register each new fixture in `provides.scripts`

**Verification**:

- `bash agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` exits 0 with
  zero failures and the pass count risen by exactly the number of cases added.
- R9 and R10 were each observed red before the edit and green after, in this dispatch.
- No ASCII-only identifier literal remains in the script.
- Every new fixture appears in `manifest.json`.

---

### Phase 3: Widen the Chunk Boundary Without Widening the Harvested Name Set [NOT STARTED]

**Goal**: Stop `abbrev` and anonymous `instance` from being swallowed into the preceding
declaration's forced-`sorry` body, while leaving the cross-validated identifier set and the
body-forcing policy exactly as they are today.

**Decoupling decision — the core of this phase.** The current code conflates three roles in one
regex: it decides where a chunk ends, which names are harvested, and whose body is forced to
`sorry`. Widening one alternation widens all three, which would newly **require** every `abbrev`
to be named as a Goal and fail plans that pass today. The three roles are therefore separated:

- **Boundary role (widened)**: recognize every declaration-starting keyword — at minimum
  `theorem`, `lemma`, `def`, `instance`, `abbrev`, plus the anonymous `instance` form with no
  identifier — so no declaration can fall inside another's chunk. Match the keyword with an
  *optional* identifier, since an anonymous `instance` has none.
- **Name-harvest role (unchanged in breadth)**: only a `theorem`/`lemma`/`def`/named-`instance`
  match contributes to `declared_names`. An `abbrev` contributes no name; an anonymous
  `instance` has none to contribute. This preserves the existing cross-validation contract
  exactly, which is what keeps plans that pass today passing.
- **Body-forcing role (unchanged in breadth)**: only declarations already forced to `:= sorry`
  today are forced. A newly-recognized `abbrev` or anonymous `instance` keeps its real body
  verbatim, because `abbrev Bar := sorry` is an unusable definition that would break every
  downstream theorem referencing `Bar` — and the Phase 5 compile step is the check that makes
  this concrete rather than asserted.

**Tasks**:

- [ ] Re-derive the three declaration-alternation sites by pattern:
      `grep -n 'theorem|lemma|def|instance' agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh`.
- [ ] Define the widened boundary alternation once, beside the Phase 2 shared identifier pattern,
      with a header comment stating the three-role separation above so a later reader does not
      re-conflate them.
- [ ] Apply the widened boundary at all three sites — `do_check()`'s `DECL_HEADER_RE`,
      `extract_r1()`'s `DECL_RE`, `extract_r2()`'s `DECL_HEADER_RE`. `do_check()` is not itself
      exposed to the swallowing failure mode (it reads only `chunk[:assign_pos]`), but it is fixed
      with the others so the three sites never disagree about what a declaration is.
- [ ] Separate the name-harvest filter from the boundary match in `extract_r1()` and
      `extract_r2()`, so `declared_names` is built only from name-contributing matches.
- [ ] Separate the body-forcing filter from the boundary match, so a non-forced declaration's
      chunk is emitted verbatim.
- [ ] Update the `extract_r1()` header comment, which currently concedes that it forces the body
      "regardless of what the block actually contains", to state the policy the code now applies.
- [ ] Add failing-first test case **R11**: an `abbrev` between two theorems survives into the
      assembled module with its real body, and both theorems are still forced to `sorry`.
- [ ] Add failing-first test case **R12**: an anonymous `instance` between two theorems survives
      into the assembled module, and contributes no entry to `theorem_names`.
- [ ] Add regression assertion **R13**: the `abbrev` of R11 contributes **no** name to
      `theorem_names`, so it is not newly required to appear under `**Goals**:`. This is the
      assertion that pins the decoupling and would fail under a naive one-regex widening.
- [ ] Add each new fixture to `manifest.json`.
- [ ] Demonstrate R11 and R12 fail against the pre-phase script and pass after.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts exactly three declaration-alternation sites, at
source-store lines 235, 492, and 610 before Phase 2's edits shift them. Re-derive by the `grep`
above rather than by line number, and assert after the edit that no site still carries a bare
`(theorem|lemma|def|instance)` alternation with a required identifier.

**Tier Justification**: The edits stay inside one file with no externally visible signature
change and no mapped suite covers it, so the covering check is named directly:
`bash agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh`, whose R11/R12/R13
trio plus the pre-existing R1-R8 regression set is what distinguishes a correct decoupled
widening from a naive one.

**Files to modify**:

- `agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh` - widened boundary alternation at three sites; separated name-harvest and body-forcing filters; corrected `extract_r1()` header comment
- `agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` - add cases R11, R12, R13; extend the header comment's case inventory
- `agent-system/extensions/lean/scripts/tests/fixtures/challenge/` - new fixtures for the `abbrev`-between-theorems and anonymous-`instance`-between-theorems cases
- `agent-system/extensions/lean/manifest.json` - register each new fixture

**Verification**:

- `bash agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` exits 0 with
  zero failures; R1-R10 are all still green, confirming no plan that passed before now fails.
- R11 and R12 were each observed red before the edit and green after, in this dispatch.
- R13 passes, pinning that an `abbrev` contributes no cross-validated name.

---

### Phase 4: Narrow the Goals Harvest to an Identifier-Leading Bullet Position [NOT STARTED]

**Goal**: Stop ordinary backticked prose inside a Goals bullet from being read as a committed
declaration name, structurally rather than by subtraction, and state the accepted surface in
documentation so the script never accepts less than the examples advertise.

**Rule decision, and why the alternatives were rejected.** Within a free-prose bullet, `comm` in
"Prove `comm` for natural number addition" and `Nu` in "in the `Nu` namespace" are positionally
and lexically indistinguishable — both are legal Lean names in identical syntactic positions. No
property of the token itself can separate them, which is why candidate (iii) (resolve against the
declared set) and any denylist extension are dead ends: (iii) makes the Goals set a subset of the
declared set by construction, so the equality check in `cross_validate_identifiers()` degenerates
into a tautology that can never fail, and the denylist cannot cover legal names without becoming
able to delete a real one. Discrimination must come from **position**, which is the dispatch's
candidate (i).

**The adopted rule**: a Goals bullet contributes identifiers only from its **leading identifier
run** — the maximal run of backtick-delimited tokens beginning at the bullet's first
non-whitespace content after its `- ` marker, separated only by whitespace, `,`, `/`, or `and`.
The run ends at the first content that is not such a token (a prose word, `--`, an em-dash, or
`:`), and everything after it on that line is descriptive prose, ignored by construction. A
bullet whose first content is not a backticked identifier contributes nothing.

**What this accepts, measured against real landed plans, not assumed**: the shape in
`specs/761_ladder_realization_theorem/plans/01_ladder-realization-blocked-probe.md`
(`` - `gPast_isPath` — prose ``) and in the `plan_goals_preamble.md` fixture
(`` - `comm` -- commutativity of addition. ``) both conform. The shape in
`specs/410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md`
leads with a backticked **file path**, which is not identifier-class, so that bullet contributes
nothing; this is a real narrowing, and the loud exit below is what makes it visible rather than
silent.

**No silent fallback.** A plan whose Goals block has no conforming bullet harvests zero
identifiers and takes the existing "no identifiers found under `**Goals**:`" hard exit. That is
a loud, actionable failure naming the documented shape — never the silent omission defects (a)
and (b) are about. A permissive whole-bullet fallback was considered and rejected: it would leave
the measured residual sentence over-reading exactly as it does today, making the fix an opt-in
rather than a fix.

**Tasks**:

- [ ] Implement the leading-identifier-run rule in `extract_goal_names()`, replacing the current
      whole-line `TOKEN_RE.findall(line)` scan. Keep the landed Goals-range anchors (both the
      column-0 and `- **Goals**:` list-item forms) and the landed preamble exclusion untouched;
      keep `LEAN_KEYWORDS` in place as a now-redundant-but-harmless second guard rather than
      removing a landed repair.
- [ ] Add failing-first test case **R14**: the measured residual sentence verbatim — a bullet
      reading ``- Prove `comm` in the `Nu` namespace, establishing a `witness` for the `EUFix` operator when the flag is `true`.`` —
      must no longer harvest `EUFix`, `Nu`, `witness`, or `true`. Build the fixture so the bullet
      conforms to the new rule for its real Goal (`comm` leading) and carries the spurious tokens
      as trailing prose, and assert exit 0 with `theorem_names` equal to `comm` alone.
- [ ] Ensure R14 covers **both** observed shapes — a capitalized namespace-style token (`Nu`,
      `EUFix`) and a lowercase prose word (`witness`, `true`) — and that it is distinct from both
      R7 (reserved keywords, denylist-covered) and R8 (preamble position). Assert explicitly that
      R14 fails against a build carrying R7's and R8's mechanisms but not this phase's, so the
      case is not vacuously passing on an already-landed repair.
- [ ] Migrate the two mid-sentence fixtures to the documented shape:
      `plan_r1.md` and `plan_keyword_noise.md`. Keep `plan_keyword_noise.md`'s backticked Lean
      keywords in its bullet's **trailing prose**, so R7 still exercises the denylist rather than
      being neutered by the migration.
- [ ] State the accepted Goals surface in the script's own header documentation: the
      identifier-leading-run rule, the separator set, the preamble exclusion, both Goals-range
      anchor forms, and the loud exit when no bullet conforms.
- [ ] **Decision gate — `plan-format.md` statement.** The dispatch requires the accepted surface
      to be stated in the plan-format examples; `plan-format.md` is outside this record's
      `file_scope` and inside the sibling cross-repo record's. Re-check that record's status in
      the source-store repository's `specs/state.json` immediately before this step.
      - Branch A (still `not_started`): make the minimal additive clarification in
        `agent-system/extensions/core/context/formats/plan-format.md`'s
        `## Lean Challenge Statements (format, lean/lean4 plans only)` section. That section
        already states that Goals bullets "name identifiers only (a backtick-delimited list)", so
        this is a tightening of an existing sentence into an explicit positional rule, not a new
        contract. Extend the task's `file_scope` to include the path, and record the coordination
        in the handoff.
      - Branch B (moved to any active status): make **no** `plan-format.md` edit. Record the
        one-sentence clarification as a coordination handoff to that record, note it in the issue
        log, and rely on the script's own header documentation as the stated surface — which the
        dispatch explicitly contemplates as the alternative home.
- [ ] Register each new fixture in `manifest.json`.
- [ ] Demonstrate R14 fails against the pre-phase script and passes after.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that exactly two fixtures (`plan_r1.md`,
`plan_keyword_noise.md`) place a Goals identifier mid-sentence and so need migration, and that
the three cited landed plans have the Goals shapes described above. Both were measured at
plan-authoring time by extracting each file's Goals block. Confirm by re-extracting every
fixture's Goals block before migrating, and treat any third mid-sentence fixture as in scope for
the same migration rather than leaving the suite red.

**Tier Justification**: This phase narrows an accepted **input** surface that other files depend
on, so verification spans the changed file plus its enumerated direct dependents: the dedicated
suite `bash agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` for the
script and fixtures, plus — only if the gate takes Branch A — the three suites
`suite_selection_select` maps `plan-format.md` to, via
`bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-phase-heading-patterns.sh,test-plan-file-scope-harvest.sh,test-resume-scan-nonconformance.sh`.

**Files to modify**:

- `agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh` - leading-identifier-run rule in `extract_goal_names()`; header documentation of the accepted Goals surface
- `agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` - add case R14; extend the header comment's case inventory
- `agent-system/extensions/lean/scripts/tests/fixtures/challenge/plan_r1.md` - migrate the Goals bullet to the identifier-leading shape
- `agent-system/extensions/lean/scripts/tests/fixtures/challenge/plan_keyword_noise.md` - migrate the Goals bullet, keeping the backticked keywords in trailing prose
- `agent-system/extensions/lean/scripts/tests/fixtures/challenge/` - new fixture for the non-keyword prose case
- `agent-system/extensions/lean/manifest.json` - register each new fixture
- `agent-system/extensions/core/context/formats/plan-format.md` - CONDITIONAL, Branch A of the decision gate only: one additive sentence making the Goals-bullet positional rule explicit

**Verification**:

- `bash agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` exits 0 with
  zero failures; R1-R13 are all still green after the fixture migration.
- R14 was observed red before the edit and green after, in this dispatch, and is confirmed
  distinct from R7 and R8 rather than passing on their mechanisms.
- The script's header states the accepted Goals surface, and the decision gate's branch is
  recorded with the sibling record's observed status.
- If Branch A fired: the three `plan-format.md` suites named above pass, and the task's
  `file_scope` includes the path.

---

### Phase 5: Extend `--dry-run` With an Opt-In Compile Step [NOT STARTED]

**Goal**: Convert a silent declaration-swallow into a loud failure, generalizing beyond the
specific keywords Phase 3 enumerated, so a future declaration form Lean adds cannot reintroduce
defect (a) unnoticed.

**Design decisions.** `--dry-run` already exists and prints the assembled module and resolved
`theorem_names`; this phase extends it rather than adding a flag. The compile runs **behind a
further opt-in flag**, not by default, because `--dry-run` today is a fast, dependency-free
inspection used inside the test suite's non-Lake throwaway repos, and making a Lake build
mandatory would turn every existing `--dry-run` call site into a slow or failing one. A compile
failure under the opt-in is **fatal** (a distinct non-zero exit, not reusing 65, 71, or 73),
because an assembled module that does not compile is not a usable Challenge and reporting it
advisorily would reproduce the silent-acceptance posture this record exists to remove. When no
Lean toolchain or Lake project is detectable, the step **announces a skip** and leaves the exit
status unchanged — an absent toolchain is not evidence of a broken module.

**Tasks**:

- [ ] Add the opt-in flag, accepted only together with `--dry-run`, and reject the combination
      with `--check` alongside the existing `--check`/`--dry-run`/`--force` guard.
- [ ] Implement toolchain and Lake-project detection, with an announced skip when either is
      absent and an explicit statement of which condition was missing.
- [ ] Compile the assembled module in a scratch location that cannot write into the target
      project, and surface the compiler's own diagnostics on failure.
- [ ] Choose and document the new exit code, and add it to the script header's exit-code
      vocabulary with its fatal status stated as explicitly as `--check`'s advisory-only status
      already is.
- [ ] Add test case **R15**: with a stubbed toolchain on `PATH` that reports failure, the opt-in
      compile step exits with the new fatal code and surfaces the diagnostics.
- [ ] Add test case **R16**: with no toolchain available, the step announces the skip and leaves
      the exit status at what `--dry-run` would have returned on its own.
- [ ] Add test case **R17**: the flag is rejected when passed without `--dry-run`, and when
      combined with `--check`.
- [ ] Confirm `--dry-run` without the opt-in behaves exactly as before, so no existing call site
      changes behavior. R1 passing unchanged is the primary evidence.
- [ ] Register any new fixture in `manifest.json`.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the test suite's throwaway repos are not Lake projects,
so a real `lake build` cannot run there and a stub on `PATH` is required. Confirm by inspecting
`make_repo` for the absence of a `lakefile`/`lean-toolchain` before building the stub, and if a
real toolchain turns out to be reachable, assert both the stubbed and real paths rather than
only the stub.

**Tier Justification**: The change is confined to one file's flag handling and one new code path
with no externally visible signature change, and no mapped suite covers the file, so the
covering check is named directly:
`bash agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh`, with R1's
continued pass as the specific evidence that unflagged `--dry-run` is unchanged.

**Files to modify**:

- `agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh` - new opt-in flag, compile step, toolchain detection, exit-code vocabulary and usage text
- `agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` - add cases R15, R16, R17 and the toolchain stub; extend the header comment's case inventory
- `agent-system/extensions/lean/scripts/tests/fixtures/challenge/` - fixture(s) for the non-compiling-module case, if the stub needs one
- `agent-system/extensions/lean/manifest.json` - register any new fixture

**Verification**:

- `bash agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` exits 0 with
  zero failures; every earlier case R1-R14 still green.
- R15 asserts the chosen fatal exit code explicitly, not merely "non-zero", so it cannot pass
  vacuously against a generic failure.
- R16 asserts the skip is announced, not silent.
- The script header documents the new flag and exit code with its fatal status stated.

---

### Phase 6: Full Gate Set, Redeploy, and Deployed-Tree Parity [NOT STARTED]

**Goal**: Run the complete gate set over the finished work, carry every change — including the
R6/R7/R8 repairs committed in Phase 1 — into the deploy tree, and verify the deployed suite is
green rather than trusting the redeploy's own report.

**Tasks**:

- [ ] Re-check the sibling cross-repo record's status one final time before the deploy, and record
      the observed value.
- [ ] Run the complete gate set from the source store:
      `bash agent-system/extensions/core/scripts/verify-deploy.sh /home/benjamin/.config/nvim/agent-system`
      (resolve the exact `TARGET` for the source store rather than relying on the no-argument
      form, whose default `$(pwd)` would silently make the doc-lint and task-reference gates SKIP).
- [ ] Confirm the task-reference and record-versioning lints find nothing in any edited file, and
      that no edited file's prose carries a task number, an `entry_id`, or draft-history language.
- [ ] Redeploy with the bounded-wait idiom:
      `timeout 540 bash .claude/scripts/deploy-headless.sh`, with the Bash tool timeout raised to
      600000ms. Confirm `RESULT=landed_verify_clean`.
- [ ] Verify deployed-tree parity directly rather than inferring it: `diff` the deployed script and
      suite against their source-store copies, and confirm the deployed
      `scripts/tests/fixtures/challenge/` directory contains **every** fixture the source store
      has — this is the gap `manifest.json` registration exists to close, and the deployed R8
      failure is the symptom that proves checking it is not redundant.
- [ ] Run the **deployed** suite from the project root and confirm zero failures.
- [ ] Record the final issue-log entries for this phase, including the deploy outcome.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the deployed fixtures directory currently holds nine
challenge fixtures against the source store's ten, and that the single missing one is
`plan_goals_preamble.md`. Confirm by listing both directories after the redeploy and comparing
them set-wise, rather than checking only the one fixture this plan happened to name.

**Files to modify**:

- `__WHOLE_TREE__` - this phase invokes `deploy-headless.sh`, regenerating the entire deployed tree
- `.claude/scripts/lean-challenge-snapshot.sh` - regenerated by the redeploy, never hand-edited
- `.claude/scripts/tests/test-lean-challenge-snapshot.sh` - regenerated by the redeploy
- `.claude/scripts/tests/fixtures/challenge/` - regenerated by the redeploy, now including every registered fixture

**Verification**:

- `bash agent-system/extensions/core/scripts/verify-deploy.sh <source_dir_target>` passes the
  complete gate set, with a non-zero exit treated as blocking and the command's exit status
  checked directly rather than a stdout diff against a baseline.
- `deploy-headless.sh` reports `RESULT=landed_verify_clean`.
- `diff` between each deployed file and its source-store copy reports no differences, and the two
  fixture directories hold the same set of fixtures.
- The deployed suite `bash .claude/scripts/tests/test-lean-challenge-snapshot.sh` exits 0 with
  zero failures — in particular R8 is green, closing the symptom the manifest gap caused.
- No file under `.claude/**` was hand-edited at any point.

---

## Testing & Validation

- [ ] The source-store suite reports zero failures at the end of every phase, never only at the end.
- [ ] Each new case (R9-R17) was observed **red** against the script as it stood before its own
      phase's edits, in this dispatch, and green after — not against the stale deployed copy and
      not against a pre-repair reconstruction.
- [ ] R14 is confirmed distinct from R7 (reserved keywords) and R8 (preamble position): it fails
      against a build carrying their mechanisms but not Phase 4's.
- [ ] R10 and R13 are the mutation-killing assertions: R10 fails if the Unicode class is only
      partly applied, R13 fails if the boundary widening is applied as one undifferentiated regex.
- [ ] R15 asserts a specific exit code, not merely a non-zero one.
- [ ] Cases R1-R8 are all still green at the end, confirming no plan that passed before this work
      fails after it.
- [ ] The deployed suite reports zero failures after the redeploy.

## Artifacts & Outputs

- Repaired `agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh` with two shared
  pattern definitions, a decoupled boundary/name/body policy, the identifier-leading Goals rule,
  the opt-in `--dry-run` compile step, and a header stating the accepted Goals surface and the
  new exit code.
- Extended `agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` covering
  cases R9-R17 alongside the existing R1-R8, M1-M3, C1-C5, and AV1.
- New and migrated fixtures under
  `agent-system/extensions/lean/scripts/tests/fixtures/challenge/`.
- `agent-system/extensions/lean/manifest.json` registering every fixture, closing the deployed-R8
  gap.
- Conditionally, one additive clarification sentence in
  `agent-system/extensions/core/context/formats/plan-format.md` (Branch A of Phase 4's gate only).
- A regenerated `.claude/**` deploy tree at `RESULT=landed_verify_clean`.

## Rollback/Contingency

- Phase 1 commits the pre-existing landed work first, so every later phase is a diff against a
  committed baseline and `git diff HEAD` always shows exactly this record's own changes.
- Each phase commits its own green sub-steps, so reverting one phase is a bounded revert of that
  phase's commits rather than an all-or-nothing undo.
- Before any intentional rollback that would discard uncommitted work, take a durable checkpoint
  first with `bash .claude/scripts/git-snapshot.sh 768 --no-revert`; use the default reverting
  form only in a genuine rollback.
- If Phase 3's decoupling turns out to break a landed plan that passed before, the contingency is
  to narrow the boundary widening to `abbrev` and the anonymous `instance` form alone rather than
  every declaration keyword, which is the minimum that closes the two reported symptoms.
- If Phase 4's narrowed rule turns out to drop a genuine Goal in a landed plan not inspected here,
  the contingency is to widen the separator set (not to restore a permissive whole-bullet
  fallback, which would reinstate the defect) and to migrate the affected fixture.
- If Phase 5's compile step proves unworkable in the suite's non-Lake repos even with a stub, it
  is the one deliverable the acceptance criteria make conditional ("If the compile step is
  added"); drop it, record the reason, and close the record on Phases 1-4 and 6.
- `.claude/**` is never hand-edited, so any deploy-tree problem is resolved by re-running
  `deploy-headless.sh`, never by patching the deployed copy.
