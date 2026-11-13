# Implementation Plan: Task #743

- **Task**: 743 - Teach typst-sync-check.sh Check 1 to resolve namespaced Lean declarations, or rule on the whitelist-vs-docstring convention it currently depends on
- **Status**: [IMPLEMENTING]
- **Effort**: 3.75 hours
- **Dependencies**: None
- **Research Inputs**: specs/743_typst_sync_check1_namespace_resolution/reports/01_namespace-resolution-feasibility.md
- **Artifacts**: plans/01_check1-namespace-resolution.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Adopt the research report's recommended route — **Option (a)**: teach Check 1 real namespace
resolution — implemented as an *additive* third resolution path in Check 1's bare-identifier /
dotted-name branch (`scripts/typst-sync-check.sh:704-708`), never replacing the existing literal
`grep -F`. A comment-aware, build-free namespace-stack scan over `LEAN_SRC_ROOTS` builds a
fully-qualified-declaration index once per Check 1 run; a dotted candidate resolves if the
literal grep succeeds (unchanged) **or** the candidate is a key in that index. The fix is then
made load-bearing rather than theoretical by restoring the manual's one historically-failing
fully-qualified citation and by proving, via a length-preserving negative control, that the one
surviving fully-qualified leaf citation no longer depends on an unrelated docstring. Finally the
mechanism and its explicit limits are documented in the three places the next citation author
will actually look.

### Research Integration

The report's four load-bearing findings drive this plan directly:

1. **Option (a) is feasible build-free.** A scratchpad Python prototype resolved both the
   historical case (`FormalSystem.Semantics.validZTime_iff_validInt`, single-level
   `namespace FormalSystem.Semantics` at `IntTransfer.lean:70`) and the live case
   (`FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime`, a **two-level nested**
   stack at `WitnessFamily/Compression/Assembly.lean:94,128`) in sub-second time over the whole
   tree. Multi-level nesting is therefore a requirement, not an edge case.
2. **Comment-awareness is mandatory, not a refinement.** The naive line-start-regex prototype
   over-collected by ~1.3% by matching keyword-shaped text inside `/- ... -/` blocks and
   docstrings. Phase 1 implements stripping of `--` line comments and nested `/- ... -/` blocks
   before any regex match, and Phase 1's verification measures both passes to confirm the gap.
3. **Exactly one leaf citation exists today, not two.** The report corrects the dispatch
   narrative: seven of the eight fully-qualified `` `FormalSystem.*` `` spans are *namespace*
   names, which resolve literally by construction (`namespace FormalSystem.ProofSystem.Axioms`
   is a verbatim occurrence of its own dotted name). Only
   `` `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` `` is a
   `<namespace-path>.<leaf>` citation.
4. **The accidental dependency is confirmed and single-sourced.** That dotted string appears in
   exactly one `.lean` file — a docstring at `FormalSystem/Metalogic/Decidability.lean:181` — and
   nowhere near its own declaration site. (Its other occurrences are in `README.md` files, which
   Check 1's `--include=*.lean` excludes.) This is the lever Phase 2's negative control pulls.

The report's additive-not-replacing constraint is honoured throughout: the literal grep remains
the only path by which a dotted name declared *outside* `FormalSystem`/`BimodalTools` (a Mathlib
name merely used here) can resolve, so removing it would narrow coverage.

### Prior Plan Reference

No prior plan. `prior_plan_path` was not provided in this dispatch's delegation context and
`specs/743_typst_sync_check1_namespace_resolution/plans/` was empty at plan-authoring time.

### Roadmap Alignment

No roadmap context was provided in this dispatch's delegation context (`roadmap_path` absent,
`roadmap_flag` absent). `specs/ROADMAP.md` exists in the repository but was not loaded as
roadmap context and is **not** read, modified, or advanced by this plan.

## Goals & Non-Goals

**Goals**:

- Check 1 resolves a correctly-cited `<namespace-path>.<declaration-leaf>` Lean name structurally,
  by parsing `namespace`/`end` nesting in build-free text, rather than by hoping the dotted string
  appears verbatim somewhere in a `.lean` file.
- The resolution is **additive**: every candidate that resolves today still resolves after the
  change, by the same branch it used before.
- The resolver is comment- and docstring-aware, so keyword-shaped prose inside `/- ... -/` blocks
  cannot inject spurious declarations into the index.
- The fix is load-bearing, not theoretical: at least one live manual citation resolves *only*
  through the new path, so a regression in the resolver turns the CI gate red.
- A recorded verdict names the route taken (Option (a)) and why Options (b), (c), and the
  dispatch's "fourth" docstring route were rejected.
- The mechanism's limits are stated where the next citation author will see them:
  `scripts/typst-sync-check.sh`'s own header, `typst/sync-check-whitelist.txt`'s header, and
  `typst/SYNC-MAP.md`'s enforcement rules.
- `bash scripts/typst-sync-check.sh` exits 0 (all four checks green) at task completion.

**Non-Goals** (carried from the dispatch, unchanged):

- No change to Check 2 (status.typ counts), Check 2b (module map), or Check 3 (machine appendix).
- No change to what any generator emits.
- The script must stay **build-free**: no `lake`, no `.olean`, no built-library dependency. Its
  build-free property is load-bearing for the pre-commit gate installed by
  `scripts/install-git-hooks.sh`.
- No change to Check 4's separately-duplicated `grep_lean` resolver
  (`scripts/typst-sync-check.sh:425-434`). The report flags factoring the two resolvers into one
  shared module as a *later, separate* task; the task title scopes this work to Check 1.
- No new whitelist entry for `decidableValidZTime` or any other valid-but-unresolvable
  declaration name. The whitelist route (Option (c)/(2)) is explicitly rejected, so there is
  nothing to suppress.
- No redeploy of `.claude/**`. This dispatch's deploy-freshness context reports the deployed tree
  stale for six extensions; that is pre-existing, is not this task's defect, and must be reported
  rather than repaired here (see Risks).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `namespace`/`end` parsing edge cases (re-opened namespaces, `section` nested inside a namespace, an `end` whose argument does not exactly repeat its `namespace` command's) silently corrupt the index | H | M | LIFO pop only on exact match of the current stack top, mirroring Lean's own pairing rule; do **not** treat `section` as namespace-affecting; validate against the full live tree (Phase 1) and diff the comment-aware vs. naive declaration counts rather than a synthetic sample |
| False positives from keyword-shaped text inside docstrings produce a bogus fully-qualified name that happens to match a bogus citation | M | M | Comment stripping (`--` line comments, nested `/- ... -/` blocks) is a Phase 1 implementation requirement, not an option; Phase 1 verification measures the naive-vs-stripped delta to prove the stripper is doing work |
| The new index *narrows* coverage by displacing the literal grep, breaking a currently-passing Mathlib-style or cross-root dotted citation | H | L | The wiring is `grep_lean(cand) or cand in ns_index` — a disjunction with the grep evaluated first and unchanged; Phase 1 verification requires `TOTAL_VIOLATIONS=0` before and after |
| Phase 2's negative-control probe mutates tracked files and a sibling task's concurrent commit or an abandoned dispatch leaves the mutation behind | H | L | Probes are length-preserving *content* swaps (never line insertions or deletions, so Check 2's line counts stay green and cannot confound the result); each probe is immediately reverted and confirmed by `git diff --exit-code -- <path>`; nothing from a probe is ever staged |
| Phase 2's restoration of the fully-qualified citation re-reds CI if the Phase 1 resolver is subtly wrong | M | L | Phase 2 runs the full gate after the restoration and before closing; the restoration is a one-line, trivially revertible edit |
| Runtime regression in the pre-commit gate from indexing ~900 `.lean` files | M | L | Research measured sub-second over the full tree; build the index **lazily** (only when at least one dotted candidate reaches that branch) and **once** per run, and time the gate before and after in Phase 1 verification |
| Phase 4's `verify-deploy.sh` reports failures caused by the pre-existing deployed-tree staleness (six extensions) rather than by this task | M | H | Record such a finding as pre-existing with the gate's own output, separate it explicitly from this task's own gates, and do **not** redeploy or hand-patch `.claude/**` to make it green |
| A concurrent sibling task (772, 774, 785) edits a shared file | M | L | Declared `file_scope` is disjoint from all three siblings' scopes (they are confined to `.claude/context/**` and `agent-system/extensions/**`); still re-read every file immediately before editing and stage only this task's own hunks, per the dispatch's territory note |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel. Phase 2 and Phase 3 touch disjoint files
(Phase 2: `typst/FormalFoundations.typ`, `FormalSystem/Metalogic/Decidability.lean`; Phase 3:
`scripts/typst-sync-check.sh`, `typst/sync-check-whitelist.txt`, `typst/SYNC-MAP.md`), so the
parallelism is real rather than nominal.

---

### Phase 1: Comment-Aware Namespace-Stack Resolver, Wired Additively [COMPLETED]

**Goal**: Check 1's dotted-name branch resolves a `<namespace-path>.<leaf>` citation structurally,
with the literal grep retained unchanged as the first-tried path.

**Tasks**:

- [x] Capture the baseline before editing: run `bash scripts/typst-sync-check.sh` and record the
      exit code and each check's violation count; run
      `grep -rno '\`FormalSystem\.[A-Za-z0-9_.]*\`' typst --include=*.typ | grep -v '/generated/'`
      and record the full span inventory, classifying each span as *namespace name* or
      *`<path>.<leaf>` declaration citation* by checking for a matching `namespace` line in source. *(completed: exit 0, 894 candidates, 0 violations; 8 spans = 7 namespace names + 1 leaf citation; gate 21.8s)*
- [x] Confirm the accidental dependency non-destructively:
      `grep -rn --include=*.lean -F 'FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime' FormalSystem/ BimodalTools/`
      must return exactly one hit, a docstring line, and that line must not be the declaration's
      own site (the declaration is `def decidableValidZTime` in
      `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`). Record the
      measured line numbers. *(completed: exactly one hit, Decidability.lean:181, a docstring; declaration is Assembly.lean:188)*
- [x] In the Check 1 Python heredoc (`scripts/typst-sync-check.sh`, heredoc opens at line 595),
      add a comment stripper applied per file before any regex matching: remove `--` line-comment
      suffixes and `/- ... -/` block-comment spans, tracking block nesting depth (Lean permits
      nested block comments) across lines. *(deviation: altered — also blanks string-literal contents so a `--` or `/-` inside a string cannot open a comment)*
- [x] Add a namespace-stack scanner over the stripped text: push the `.`-split components on
      `namespace X.Y.Z`; pop on `end X.Y.Z` **only** when the argument exactly matches the current
      stack top (LIFO, mirroring Lean's own pairing rule). Do not treat `section` as
      namespace-affecting. *(deviation: altered — `section`/`mutual` contribute nothing to the prefix but are tracked on the scope stack so their `end` is paired with them instead of popping a namespace; namespace paths themselves are also indexed)*
- [x] Add declaration-keyword extraction on the stripped text: `theorem`, `lemma`, `def`,
      `abbrev`, `instance`, `structure`, `inductive`, `class`, `axiom`, optionally preceded by
      `@[...]`, `private`, `protected`, `noncomputable`, `scoped`. Join the extracted identifier
      to the current stack as `".".join(stack + [local_name])` — the join handles an already-dotted
      local name unchanged. *(completed: also `opaque`, `class inductive`/`class abbrev`; `_root_.` honoured)*
- [x] Build the index once per Check 1 run, over `bimodal_dirs` (the existing `LEAN_SRC_ROOTS`
      parse) with `Boneyard/` excluded to match every other Check 1 branch; build it **lazily**,
      on first need, so a run with no dotted candidate pays nothing. Map fully-qualified name ->
      `file:line` so a future diagnostic can name the resolution site. *(completed)*
- [x] Wire additively into the dotted branch at `scripts/typst-sync-check.sh:704-708`: keep
      `if grep_lean(cand): continue` first and unchanged, then add the index lookup as a second
      `continue` condition. Do not alter the whitelist branch, the multi-word-span branch, or the
      path-like branch. *(completed)*
- [x] Extend the violation message for a still-unresolved dotted candidate to say that neither the
      literal scan nor namespace resolution found it, so the failure mode is distinguishable. *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Three figures are CARRIED from
`specs/743_typst_sync_check1_namespace_resolution/reports/01_namespace-resolution-feasibility.md`
and are hypotheses, not facts: (i) the comment-aware prototype collected **16,773** declarations
versus the naive pass's **16,998** (a 225-entry, ~1.3% over-collection); (ii) **eight**
fully-qualified `` `FormalSystem.*` `` backtick spans exist in `typst/` outside
`typst/generated/`, of which **exactly one** is a `<path>.<leaf>` declaration citation and seven
are namespace names; (iii) full-tree resolver runtime is sub-second. Confirm all three at
implementation time: (i) by temporarily instrumenting the new index to print its key count under
both a stripped and an unstripped pass and comparing, (ii) by the baseline survey grep in this
phase's first two tasks, (iii) by timing `bash scripts/typst-sync-check.sh` before and after the
change. Report the measured numbers; do not restate the carried ones as results.

**Tier Justification**: The edit is confined to one script's Check 1 Python heredoc with no
change to the script's CLI, exit-code contract, or any externally visible signature, and is
covered by `bash scripts/typst-sync-check.sh` (the script exercising itself end to end over the
live tree) together with `bash .claude/scripts/tests/run-all.sh --only test-plan-file-scope-harvest.sh`,
the one suite `suite_selection_select "scripts/typst-sync-check.sh"` maps this path to.

**Files to modify**:

- `scripts/typst-sync-check.sh` - add the comment stripper, namespace-stack scanner, lazy
  declaration index, and the additive index lookup in Check 1's dotted-name branch; extend that
  branch's violation message

**Verification**:

- `bash scripts/typst-sync-check.sh` exits 0 with `TOTAL_VIOLATIONS=0` for Check 1 and all of
  Checks 2, 2b, 3, 4 green — i.e. byte-for-byte the same verdict as the recorded baseline.
- `bash scripts/typst-sync-check.sh --counts-only` still exits 0 (the build-free Check 2-only
  path is untouched).
- `bash scripts/typst-sync-check.sh --help` exits 0 and `bash scripts/typst-sync-check.sh --bogus`
  exits 2 (the usage contract is unchanged).
- No `lake`, `.olean`, or built-library reference was introduced: `grep -n 'lake\|olean'
  scripts/typst-sync-check.sh` shows only pre-existing occurrences (Check 2's `--fix` path), none
  inside Check 1.
- The instrumented index resolves both target names to their own declaration sites, not to a
  docstring: `FormalSystem.Semantics.validZTime_iff_validInt` ->
  `FormalSystem/Semantics/IntTransfer.lean` (the `theorem` line, measured — research recorded 338),
  and `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` ->
  `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` (the `def` line,
  measured — research recorded 147).
- The stripped-vs-unstripped key counts differ, confirming the comment stripper is load-bearing.
- `bash .claude/scripts/tests/run-all.sh --only test-plan-file-scope-harvest.sh` passes.
- Measured gate wall-clock is within the same order as the baseline (no multi-second regression).

---

### Phase 2: Make the Fix Load-Bearing — Controls and Citation Restoration [NOT STARTED]

**Goal**: Prove by experiment that the resolver, and not an unrelated docstring, is what resolves
the manual's namespaced citations, and leave at least one live citation whose resolution depends
on the new path so a future regression turns CI red.

**Tasks**:

- [ ] **Negative control (temporary, reverted).** Re-read
      `FormalSystem/Metalogic/Decidability.lean` immediately beforehand. Replace the dotted name
      inside the docstring at the measured line (research recorded line 181) with a shorter form
      (e.g. `Compression.decidableValidZTime`), as a **content swap on that one line only** — never
      a line insertion or deletion, so the file's line count is unchanged and Check 2's
      `formalsystem-line-count` cannot confound the result.
- [ ] Run `bash scripts/typst-sync-check.sh`. Expected: exit 0, Check 1 `TOTAL_VIOLATIONS=0`,
      Check 2 still green. Record the output. A Check 1 violation here means the index did not
      cover the nested two-level case and Phase 1 is incomplete — stop and return to Phase 1
      rather than proceeding.
- [ ] Revert the probe. Confirm with
      `git diff --exit-code -- FormalSystem/Metalogic/Decidability.lean` (must exit 0). Nothing
      from this probe is ever staged or committed.
- [ ] **Positive control, made durable.** Re-read `typst/FormalFoundations.typ` immediately
      beforehand, then restore the fully-qualified citation form at the measured line (research
      recorded the current module-path-plus-leaf text at line 807: `` `validZTime_iff_validInt` ``
      in `` `Semantics/IntTransfer.lean` ``), rewriting it to cite
      `` `FormalSystem.Semantics.validZTime_iff_validInt` ``. Keep the surrounding sentence
      grammatical. This is the rendered reference manual, so read the full sentence before editing
      rather than substituting a bare string.
- [ ] Verify the restored citation resolves **only** through the new path: confirm
      `grep -rn --include=*.lean -F 'FormalSystem.Semantics.validZTime_iff_validInt' FormalSystem/ BimodalTools/`
      returns no hit (so the literal grep cannot be what resolves it) while
      `bash scripts/typst-sync-check.sh` exits 0 with Check 1 clean.
- [ ] Record the verdict material for Phase 4: which citation now depends on the resolver, and the
      measured before/after of both controls.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The line numbers used by this phase's probes are CARRIED from
`reports/01_namespace-resolution-feasibility.md` (`Decidability.lean:181` for the docstring,
`typst/FormalFoundations.typ:807` for the citation) and from Phase 1's own baseline capture. Both
are hypotheses: re-grep for the literal strings immediately before editing and use the measured
line, never the carried number, as the edit target.

**Tier Justification**: The only durable edit is a one-line prose citation in a non-compiled
`.typ` source file, and the `.lean` probe is net-zero by construction — covered by
`bash scripts/typst-sync-check.sh` (which is precisely the gate whose behavior is under test) plus
`git diff --exit-code` on the probed `.lean` path, which mechanically proves the probe left no
residue.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability.lean` - **temporary, net-zero**: a length-preserving
  content swap on one docstring line for the negative control, reverted and verified clean within
  this phase; no committed change to this file
- `typst/FormalFoundations.typ` - restore the fully-qualified citation form
  `` `FormalSystem.Semantics.validZTime_iff_validInt` `` at the measured line

**Verification**:

- Negative control: with the docstring's dotted name swapped out, `bash scripts/typst-sync-check.sh`
  exits 0 and Check 1 reports `TOTAL_VIOLATIONS=0` — demonstrating that the accidental docstring
  dependency the dispatch identified is gone.
- `git diff --exit-code -- FormalSystem/Metalogic/Decidability.lean` exits 0 after the revert, and
  `git status --short` shows no unexpected `.lean` modification.
- Positive control: the restored fully-qualified citation has **no** literal `.lean` occurrence,
  yet `bash scripts/typst-sync-check.sh` exits 0 — so the new path, not the grep, is what resolves
  it.
- `bash scripts/typst-sync-check.sh` exits 0 with all four checks green, including Check 2's
  counts (confirming no line-count drift was introduced).
- `typst compile --root .. typst/BimodalReference.typ /tmp/t743.pdf` succeeds, or, if the manual is
  not compilable in this environment for a pre-existing reason, that is recorded as pre-existing
  with the compiler's own output rather than attributed to this edit.

---

### Phase 3: Document the Mechanism and Its Limits Where Citation Authors Look [NOT STARTED]

**Goal**: The next citation author, and the next person tempted to add a whitelist entry, can see
what namespace resolution does and does not cover without reading the implementation.

**Tasks**:

- [ ] Re-read `scripts/typst-sync-check.sh` immediately beforehand (Phase 1 changed it). Update
      the file-header block's Check 1 description (currently
      `scripts/typst-sync-check.sh:5-8`) to state that a backticked span resolves against the
      whitelist, a literal scan of live Lean source, **or** namespace-aware resolution of a
      `<namespace-path>.<leaf>` name, and that the whole check remains build-free.
- [ ] Add a comment immediately above Check 1's dotted-name branch naming the limits explicitly:
      resolution covers declarations under `LEAN_SRC_ROOTS` (`FormalSystem`, `BimodalTools`)
      reachable through literal `namespace`/`end` nesting; a name introduced only by `export`, by
      an `open ... in` one-liner, or from outside those two roots still depends on the literal
      scan and, failing that, the whitelist.
- [ ] Re-read `typst/sync-check-whitelist.txt`, then extend its header comment block with a new
      paragraph: namespace resolution now exists, so a *valid* namespaced declaration should no
      longer need an entry; and an entry added for a valid-but-unresolvable Lean declaration name
      **suppresses a resolution gap rather than certifying the name** and must say so inline. Add
      this as `#`-prefixed comment lines only — the file is data the script parses, and
      `#`-prefixed lines are the sanctioned comment form.
- [ ] Re-read `typst/SYNC-MAP.md`, then amend enforcement rule 2 (currently at
      `typst/SYNC-MAP.md:46-49`) to name the sanctioned citation styles — fully-qualified
      `Namespace.Path.leaf`, module-path-plus-leaf, and bare leaf — and state that the
      fully-qualified style resolves structurally rather than by coincidence of source text.
- [ ] Do **not** restate the mechanism's implementation in `CONTRIBUTING.md` or `scripts/README.md`;
      both describe the gate at a level this change does not alter.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: The two line anchors this phase names — `scripts/typst-sync-check.sh:5-8`
for the header's Check 1 description and `typst/SYNC-MAP.md:46-49` for enforcement rule 2 — were
measured at plan-authoring time, and the first of them will have *shifted* by whatever Phase 1
added to that file. Both are hypotheses: locate each target by grepping for its text (the
`1. Name resolution` header bullet; the `No backticked Lean identifier or path` rule sentence) and
edit the measured location, never the number written here. The claim that exactly three files
need documentation edits is likewise a hypothesis — confirm no fourth location states the Check 1
resolution rule by grepping `CONTRIBUTING.md`, `scripts/README.md`, and `typst/README.md` for
`Check 1` and `backtick` before closing the phase.

**Tier Justification**: Every hunk in this phase lies inside a shell comment block, a
`#`-prefixed whitelist comment line, or markdown prose with zero compile or elaboration surface —
confirmed by a diff read-through, plus one confirming `bash scripts/typst-sync-check.sh` run
because the whitelist file is data the script parses, so the gate run proves the added comment
lines changed no parse result.

**Files to modify**:

- `scripts/typst-sync-check.sh` - header-block Check 1 description; a limits comment above the
  dotted-name branch (comment text only)
- `typst/sync-check-whitelist.txt` - header comment block: namespace resolution exists; a
  whitelist entry for a valid-but-unresolvable declaration name suppresses a gap and must say so
- `typst/SYNC-MAP.md` - enforcement rule 2: the sanctioned citation styles and the structural
  basis of fully-qualified resolution

**Verification**:

- Diff read-through confirms every changed hunk lies inside a comment or markdown-prose region;
  no executable line of `scripts/typst-sync-check.sh` is touched by this phase.
- `bash scripts/typst-sync-check.sh` exits 0 with all four checks green, and Check 1's violation
  count is unchanged from Phase 1's post-change baseline (proving the whitelist additions parsed
  as comments and added no entries).
- `bash .claude/scripts/check-task-references.sh` reports no new finding for the three touched
  paths (none of which is under `specs/**`, so the no-task-references rule applies in full).
- `bash .claude/scripts/check-record-versioning.sh` reports no new finding — the documentation
  states the current mechanism only and must not narrate "previously the check did a literal
  grep".

---

### Phase 4: Full Gate and Recorded Verdict [NOT STARTED]

**Goal**: The complete gate set is green, and the task leaves behind an explicit verdict naming
the route taken and the routes rejected.

**Tasks**:

- [ ] Run `bash scripts/typst-sync-check.sh` and record all four checks' output verbatim.
- [ ] Run `bash .claude/scripts/verify-deploy.sh` (the complete gate set). Where a failure is
      attributable to the pre-existing deployed-tree staleness this dispatch reported for the
      `core formal lean literature memory typst` extensions, record it as pre-existing **with the
      gate's own output**, separated explicitly from this task's own verification; do not redeploy
      and do not hand-patch any file under `.claude/**`.
- [ ] Run `bash .claude/scripts/tests/run-all.sh` (the full shell suite, Gate 8's battery) and
      record the result.
- [ ] Write the verdict into the task summary: **Option (a) taken** — Check 1 learned
      comment-aware namespace resolution, added additively. **Option (b) rejected**: ruling that
      the manual may cite only module-path-plus-leaf would have made the one surviving
      fully-qualified leaf citation non-conforming and would have left the mechanism gap intact for
      any future author who reaches for the fully-qualified form. **Option (c) rejected**: keeping
      the literal grep leaves a correct citation's validation dependent on whether an unrelated
      docstring happens to mention it — the condition that made this a recurring finding, and the
      one the Phase 2 negative control measures directly. **The dispatch's "fourth" route
      (adding the dotted cross-reference to `IntTransfer.lean`'s module docstring) rejected**: it
      formalizes the coincidence rather than fixing it, is Option (c) under another name, and
      would have forced a `typst/generated/status.typ` regeneration over a stylistically
      inconsistent docstring entry. **No whitelist entry was added**, so nothing is suppressed.
- [ ] State in the summary which live citation now depends on the resolver (the restored
      `FormalSystem.Semantics.validZTime_iff_validInt` at `typst/FormalFoundations.typ`), so a
      future reader knows the regression guard exists and where it lives.
- [ ] Record the report's out-of-scope flag for a follow-up: Check 4's duplicated `grep_lean` body
      (`scripts/typst-sync-check.sh:425-434`) is an independent copy of the same literal-grep
      idea and does not share this defect today only because it never assembles a dotted string.

**Timing**: 0.5 hours

**Depends on**: 2, 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:

- `specs/743_typst_sync_check1_namespace_resolution/summaries/01_check1-namespace-resolution-summary.md` -
  the recorded verdict and gate evidence

**Verification**:

- `bash scripts/typst-sync-check.sh` exits 0 with all four checks green (the task's stated
  ACCEPTANCE criterion).
- The complete gate set runs and is observed green: `bash .claude/scripts/verify-deploy.sh`,
  including its full Gate 8 shell-suite battery via `bash .claude/scripts/tests/run-all.sh`. Any
  failure is either fixed within this task's scope or recorded, with the gate's own output, as
  pre-existing and attributable to the reported deploy staleness — never waved past and never
  masked by a redeploy or a hand-patch under `.claude/**`.
- `git status --short` shows modifications confined to this plan's declared `file_scope` plus this
  task's own `specs/` directory; in particular `FormalSystem/Metalogic/Decidability.lean` is
  unmodified, confirming Phase 2's probe left no residue.
- The summary contains the four-route verdict and names the regression-guard citation.

---

## Testing & Validation

- [ ] `bash scripts/typst-sync-check.sh` exits 0, all four checks green.
- [ ] `bash scripts/typst-sync-check.sh --counts-only` exits 0; `--help` exits 0; an unrecognized
      flag exits 2 (the CLI contract is unchanged).
- [ ] Check 1's violation set is identical to the pre-change baseline — the change is additive and
      narrows nothing.
- [ ] Negative control passes: with `Decidability.lean`'s docstring dotted name swapped out
      (length-preserving, then reverted), Check 1 still resolves
      `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime`.
- [ ] Positive control passes: the restored `FormalSystem.Semantics.validZTime_iff_validInt`
      citation resolves although the dotted string occurs in no `.lean` file.
- [ ] The resolver is comment-aware: stripped and unstripped index key counts differ.
- [ ] Build-free property intact: no `lake` or `.olean` reference anywhere in Check 1.
- [ ] `git diff --exit-code -- FormalSystem/Metalogic/Decidability.lean` exits 0 at task
      completion.
- [ ] `bash .claude/scripts/verify-deploy.sh` and `bash .claude/scripts/tests/run-all.sh` observed
      green, or any failure recorded as pre-existing with its own output.

## Artifacts & Outputs

- `scripts/typst-sync-check.sh` — Check 1 gains a comment-aware namespace-stack declaration index
  and an additive index lookup in its dotted-name branch; header and inline limits documentation.
- `typst/FormalFoundations.typ` — one citation restored to fully-qualified form, now resolving
  structurally and serving as the live regression guard.
- `typst/sync-check-whitelist.txt` — header note: namespace resolution exists; a whitelist entry
  for a valid-but-unresolvable declaration name suppresses a gap and must say so.
- `typst/SYNC-MAP.md` — enforcement rule 2 names the sanctioned citation styles.
- `specs/743_typst_sync_check1_namespace_resolution/summaries/01_check1-namespace-resolution-summary.md`
  — the recorded four-route verdict and gate evidence.

## Rollback/Contingency

Every phase's change is a self-contained, revertible text edit; no generated file, no schema, and
no build output is involved.

- **Phase 1 resolver misbehaves (a false resolution, or a currently-passing candidate stops
  resolving)**: revert the Phase 1 commit. Check 1 returns to literal-grep-only behavior and the
  gate returns to its current green state, because the wiring is a disjunction that only ever adds
  a resolution path.
- **Phase 2's probe cannot be cleanly reverted**: `git checkout`-style discard of an uncommitted
  change is governed by `rules/git-workflow.md`; take
  `bash .claude/scripts/git-snapshot.sh --no-revert 743` as a defensive checkpoint *before*
  starting the probe, then restore the one line by editing it back to the recorded original text
  and confirm with `git diff --exit-code`. Never run `git-snapshot.sh` in its default reverting
  mode here — a sibling task is live on this same working tree.
- **Phase 2's citation restoration re-reds CI**: revert that single line to the
  module-path-plus-leaf form. The gate returns green immediately and the resolver stays in place;
  the plan then falls back to the report's Option (b) (module-path-plus-leaf is the sanctioned
  style) for the *documentation* half, with the resolver retained as defense in depth, and the
  Phase 4 verdict is amended accordingly.
- **Option (a) proves infeasible at implementation time** (parsing complexity beyond this
  budget): fall back to the report's recorded Option (b) — rewrite the single surviving
  fully-qualified leaf citation at `typst/FormalFoundations.typ` (research recorded line 796) to
  module-path-plus-leaf form, document that convention in `typst/SYNC-MAP.md` and the whitelist
  header, and record Option (b) as the verdict with Option (a)'s measured blocker named. Do
  **not** silently fall back to a whitelist entry; if a whitelist entry is used at all, it must say
  inline that it suppresses a resolution gap and does not certify the name.
