# Research Report: Task #768

**Task**: 768 - Fix three independent defects in `lean-challenge-snapshot.sh`
**Started**: 2026-11-04
**Completed**: 2026-11-04
**Effort**: medium
**Dependencies**: None
**Research Inputs**: None
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- All three defects named in the dispatch were independently reproduced live against the
  current source-store copy of `lean-challenge-snapshot.sh`, using throwaway scratchpad
  fixtures built from scratch (not reconstructed from the dispatch's prose): defect (a)
  (`abbrev`/anonymous-`instance` swallowing), defect (b) (ASCII-only identifier truncation and
  collision), and defect (c)'s remaining non-keyword in-bullet residual all still reproduce
  exactly as described.
- The source store has progressed further than the dispatch's "ALREADY-LANDED, UNCOMMITTED"
  section describes: a third repair (an uncommitted "Goals preamble exclusion", test case R8)
  has already landed on top of the two the dispatch names, and the local full suite now reports
  **17 passed, 0 failed, 0 skipped** (not 16). The preamble fix also converted
  `extract_goal_names()` from a shell `grep -oP` pipeline to a Python helper, which changes
  defect (b)'s site inventory: there are now **four Python sites**, not three Python sites plus
  one shell site.
- The deployed `.claude/scripts/lean-challenge-snapshot.sh` and its test file are, as of this
  research pass, **already byte-identical** to the uncommitted source-store copies — contrary to
  the dispatch's claim that the deploy tree "does NOT yet carry any of it and still shows the
  old column-0 anchor". The deployed test suite currently reports 16 passed / 1 failed only
  because the new untracked fixture `plan_goals_preamble.md` (needed by R8) has not yet been
  copied into the deployed `fixtures/challenge/` directory; a redeploy resolves this
  automatically along with every other change.
- Recommended approach: fix the declaration-alternation over-reach (defect a) and the
  identifier-regex ASCII restriction (defect b) together at all occurrences (one shared Python
  helper/constant, not four independently edited literals), choose the delimited-position
  discrimination rule (candidate (i) from the dispatch) for defect (c)'s remaining residual, add
  the four acceptance-mandated failing-first test cases plus the fixed-deployed-copy assertion,
  commit the already-landed uncommitted work alongside the new fixes, and redeploy.

## Context & Scope

Researched the current state of `scripts/lean-challenge-snapshot.sh` and
`scripts/tests/test-lean-challenge-snapshot.sh` in the source store
(`/home/benjamin/.config/nvim/agent-system/extensions/lean`), per the dispatch's instruction to
read the source store (never the deploy tree) to establish current behavior, and to check the
cross-repo-overlap record before editing. Scope covered: enumerating every occurrence of the
declaration alternation and the ASCII-only identifier character class; reproducing each of the
three named defects against the live script with isolated scratchpad fixtures; diffing the
deployed copy against the source-store copy to assess the dispatch's deploy-freshness claim;
and checking the cross-repo sibling record's current status. No edits were made to the source
store, the deploy tree, or any fixture — this is a research-only dispatch.

## Findings

### Codebase Patterns

**File identity and layout** (source store,
`agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh`, 881 lines; test file
`scripts/tests/test-lean-challenge-snapshot.sh`, 432 lines). The tool has four main code paths
that matter to this record: `do_check()`'s `headers_by_name()` (drift detection against a
git-pinned Challenge), `extract_goal_names()` (Goals-block backtick harvest), `extract_r1()`
(plan-declared Challenge Statements assembler), and `extract_r2()` (git-baseline fallback
assembler).

**Defect (a) site inventory — the declaration alternation `(?:theorem|lemma|def|instance)` with
a REQUIRED named-identifier capture, at exactly three Python sites** (current source-store line
numbers; re-derive at implementation time, these are a starting point, not a durable anchor):

- Line 235, `do_check()`'s `DECL_HEADER_RE` (`headers_by_name()`).
- Line 492, `extract_r1()`'s `DECL_RE` (non-capturing keyword group).
- Line 610, `extract_r2()`'s `DECL_HEADER_RE`.

Confirmed mechanism in `extract_r1()`/`extract_r2()`: for consecutive regex matches `i` and
`i+1`, the chunk forced to `:= sorry` runs from match `i`'s start to match `i+1`'s start
(`end = matches[idx + 1].start() if idx + 1 < len(matches) else len(...)`), then
`head = chunk[:assign_pos].rstrip()` followed by `" := sorry\n"` **replaces everything from the
first top-level `:=` through the chunk end**, including any unmatched `abbrev`/anonymous
`instance` sitting in that span. `do_check()`'s `headers_by_name()` uses the same alternation
but is not exposed to the swallowing failure mode itself (it only reads `chunk[:assign_pos]`,
which never includes the unmatched tail) — it still needs the same fix for consistency with the
other two sites, per the dispatch's enumerate-every-occurrence instruction.

**Live reproduction of defect (a)** (scratchpad repo, `--dry-run`, source-store script):

- `abbrev` between two theorems: a Challenge Statements block of
  `theorem foo : True := by trivial` / `abbrev Bar := Nat` / `theorem baz : True := by trivial`
  assembles to only `theorem foo : True := sorry` and `theorem baz : True := sorry` — `Bar` is
  gone from the output entirely, no warning, exit 0.
- Anonymous `instance` between two theorems: identical outcome with
  `instance : Inhabited Nat := ⟨0⟩` in place of the `abbrev` line.

**Defect (b) site inventory — the ASCII-only identifier class, now at FOUR sites, all Python**
(current source-store line numbers):

- Line 235 — `do_check()`'s `DECL_HEADER_RE`, `[A-Za-z_][A-Za-zA-Z0-9_']*`.
- Line 393 — `extract_goal_names()`'s `TOKEN_RE`, `` `([a-zA-Z_][a-zA-Z0-9_']*)` ``.
- Line 492 — `extract_r1()`'s `DECL_RE`, `[A-Za-z_][A-Za-zA-Z0-9_']*`.
- Line 610 — `extract_r2()`'s `DECL_HEADER_RE`, `[A-Za-z_][A-Za-zA-Z0-9_']*`.

This differs from the dispatch's description ("the three Python sites... A FOURTH, non-Python
site... the Goals extractor's `grep -oP` class"): the already-landed, uncommitted preamble-
exclusion repair (see below) rewrote `extract_goal_names()` from a shell `sed`/`grep -oP`
pipeline into a Python helper with its own `TOKEN_RE`, which still carries the ASCII-only class
but is no longer a shell site. The fourth occurrence the dispatch anchored at "line 382 (shell
`grep -oP`)" no longer exists in that form; its Python successor is at line 393 today. The
redundant range noted in the dispatch (`A-Za-zA-Z0-9`, i.e. `A-Z` appearing via both `A-Za-z`
and the trailing `A-Z` before `0-9`) is present verbatim at all three declaration-header sites
(235, 492, 610); `TOKEN_RE` (393) does not carry this particular redundancy (`[a-zA-Z_]`), but
is ASCII-only in the same way.

**Live reproduction of defect (b)** (scratchpad repos, `--dry-run`):

- *Escape case*: a Goals bullet reading `` - Prove `foo₁`. `` with a Challenge Statement
  `theorem foo₁ : 1 + 1 = 2 := by decide` fails with
  `ERROR: no identifiers found under **Goals**: ... nothing to snapshot.` (exit 71) — `TOKEN_RE`
  requires the ASCII identifier run to be immediately followed by a literal closing backtick, so
  a token ending in a non-ASCII character does not match at all, rather than truncating.
- *Truncation-collision case*: a Goals bullet reading `` - Prove `foo`. `` (an ASCII-only token
  that DOES harvest) paired with Challenge Statement `theorem foo₁ : 1 + 1 = 2 := by decide`
  **exits 0** and reports `theorem_names: foo` — the declaration-header regex truncates the
  captured name to `foo` (no closing-backtick requirement constrains it in bare module text), so
  cross-validation silently passes even though the real declared identifier is `foo₁`, not
  `foo`. The manifest records a different identifier than the one actually proved — exactly the
  "worse than escaping" collision risk the dispatch describes, confirmed directly rather than
  inferred.

**Defect (c) — confirmed still unrepaired for the non-keyword in-bullet case, despite
additional landed work the dispatch does not mention.** Live reproduction using the dispatch's
own example sentence verbatim (Goals bullet:
`` - Prove `comm` in the `Nu` namespace, establishing a `witness` for the `EUFix` operator when the flag is `true`. ``,
Challenge Statement `theorem comm (n m : Nat) : n + m = m + n := sorry`) still exits 71:
`ERROR: identifier-set mismatch between **Goals**: and the Challenge declarations. named in **Goals**: but not declared: EUFix Nu true witness`.
This matches the dispatch's "MEASURED RESIDUAL" claim exactly and confirms the remaining work is
real and still needed.

### Already-landed, uncommitted source-store state (more than the dispatch describes)

The dispatch's "ALREADY-LANDED, UNCOMMITTED SOURCE-STORE WORK" section names two repairs (the
list-item Goals-anchor form, and the reserved-keyword denylist) and states "the full suite
reports 16 passed, 0 failed, 0 skipped". Running the suite today
(`bash scripts/tests/test-lean-challenge-snapshot.sh` from the source store) reports
**17 passed, 0 failed, 0 skipped**, covering test cases R1-R8, M1-M3, C1-C5, AV1. The test file's
own header explains the extra case: "Cases R6-R8 cover `extract_goal_names()`'s own Goals-block
parsing specifically: the list-item label form (R6), a Lean keyword backticked in prose (R7),
and a non-keyword word backticked in a preamble paragraph before the first bulleted identifier
(R8)." R8, and its fixture `fixtures/challenge/plan_goals_preamble.md` (untracked, alongside the
two fixtures the dispatch does name), are not described in the dispatch's landed-work section.

R8's mechanism — a **preamble exclusion**: `extract_goal_names()` now tracks whether the first
bulleted (`- ...`) line in the Goals range has been seen yet; any line before it is a preamble
and is never scanned for backticked identifiers, "however many backticks it contains." This
closes exactly one shape of over-reading: prose sitting *between* the `**Goals**:` label and the
first real bullet (the shape documented in the uncommitted diff's own comment, citing a landed
plan at `specs/761_ladder_realization_theorem/plans/01_ladder-realization-blocked-probe.md`,
whose preamble sentence used `abbrev`, `gPast_adm`, and other backticked tokens before the first
real Goal bullet). It does **not** address — and was never claimed to address — the dispatch's
"MEASURED RESIDUAL" shape: non-keyword backticked prose *inside* a bulleted Goals line, which
remains live per the reproduction above. R8's own fixture and the dispatch's acceptance
criterion for "a Goals range carrying backticked NON-KEYWORD prose" are therefore two distinct,
non-overlapping test shapes — consistent with the dispatch's own instruction that the new case
"must be DISTINCT from the existing R7... a new case that R7's denylist already passes is not
exercising this defect" (here, R8's preamble fixture, not R7's denylist, is the one to keep
distinct from).

### Deploy-tree state (corrects a stale claim in the dispatch)

The dispatch states: "The DEPLOYED `.claude/scripts/lean-challenge-snapshot.sh` does NOT yet
carry any of it and still shows the old column-0 anchor, so an implementer who reads the deploy
tree to establish current behavior will reach a wrong conclusion -- read the source store."

As of this research pass, `diff` between
`/home/benjamin/Projects/BimodalLogic/.claude/scripts/lean-challenge-snapshot.sh` and the
source-store copy, and between the two `test-lean-challenge-snapshot.sh` files, both report
**zero differences** — the deployed copies already carry every uncommitted source-store change,
including the Python rewrite of `extract_goal_names()` and the preamble exclusion. Running the
deployed suite (`bash .claude/scripts/tests/test-lean-challenge-snapshot.sh` from the project
root) reports **16 passed, 1 failed, 0 skipped**; the sole failure is R8, and only because the
deployed `fixtures/challenge/` directory is missing `plan_goals_preamble.md` (present in the
source store as an untracked file, not yet mirrored to the deploy tree) — `make_repo`'s `sed`
over a nonexistent fixture produces a plan missing the `## Lean Challenge Statements` section
entirely, which the tool correctly (if confusingly, for this one fixture-sync gap) routes into
the R2 degraded-fallback path and fails there. This is a plain fixture-sync gap, not a script
defect, and the dispatch's required redeploy (`bash .claude/scripts/deploy-headless.sh`) resolves
it the same way it resolves everything else — this finding does not change the redeploy
instruction, only the diagnosis of what, specifically, is stale in the deploy tree today (one
fixture, not the whole repair set).

This correction matters operationally: an implementer who trusted the dispatch's "deployed copy
still shows the old column-0 anchor" framing and diffed the deploy tree against a from-scratch
reconstruction of the "old" behavior would be comparing against a conclusion already falsified by
the live deploy tree. The redeploy step remains necessary regardless (to pick up the missing
fixture and any new work from this record), but the reason to redeploy is fixture-sync, not
script staleness.

### Cross-repo overlap record status

The sibling source-store record `lean4_plan_with_zero_lean_goals` (file_scope:
`agent-system/extensions/core/context/formats/plan-format.md`,
`agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh`,
`agent-system/extensions/lean/context/project/lean4/domain/challenge-snapshot.md`) is currently
**`not_started`** in the source-store repository's own `specs/state.json` — no implementation
work has landed or is in flight there. Its subject (a sanctioned zero-theorem lean4 plan shape,
currently indistinguishable from a malformed section because both exit 71) is confirmed disjoint
from all three defects in this record. No live race exists today, but the file-scope overlap is
real and should be re-checked immediately before this record's implementation phase edits land,
since `not_started` can change at any time and there is no mechanical dependency edge across the
two repositories' task spaces to catch a collision automatically.

### External Resources

No external (web) research was needed — this is a self-contained, already-extensively-
documented internal tooling defect record; the dispatch itself supplies the originating evidence,
reproduction recipes, and remedy candidates, and the source store's own code/tests/design record
were the authoritative and sufficient sources.

## Recommendations

1. **Fix the declaration alternation and the identifier character class together, at a single
   shared definition, consumed by all affected sites** — not four independently edited literals.
   Concretely: extend the alternation to recognize `abbrev` and an *anonymous* `instance`
   (`instance\s*(?:name)?\s*(?::|:=)`) as valid chunk-boundary matches at all three sites (235,
   492, 610), and replace the ASCII-only identifier class at all four sites (235, 393, 492, 610)
   with one Unicode-aware definition. A plain `\w` (Python's default-Unicode `\w`, confirmed
   empirically to match Lean-legal subscript digits like `₁` and Greek letters) covering the
   continuation characters, combined with an explicit `'` in the continuation class and a
   leading-character class that excludes digits, is a reasonable first approximation of Lean's
   actual identifier grammar; this is a decision for the plan/implementation phase, not fixed
   here.
2. **For anonymous `instance`, decide the chunk-boundary semantics deliberately**: an anonymous
   `instance` has no name to put in `theorem_names`/`declared_names`, so it can never be a cross-
   validated Goal — the fix only needs to stop it from being *swallowed into* the preceding
   declaration's forced-sorry body; it does not need (and should not gain) its own name-keyed
   entry in the harvested identifier sets.
3. **For defect (c)'s remaining residual, adopt discrimination rule (i) from the dispatch** —
   restrict Goals-identifier extraction to a delimited position (the existing per-bullet
   structure already in use: `- \`name\` -- description`), rather than attempting to further
   narrow by denylist (ruled out, cannot cover non-keywords) or by filtering against the declared
   set (ruled out as a tautology by the dispatch's own analysis, confirmed sound: filtering the
   harvested set through the declared set before an equality check against that same declared
   set can never fail). Concretely: harvest only the first backticked token immediately after a
   bullet's leading `- `, or any backticked token *before the first `--`/em-dash separator* on a
   bulleted line, and treat anything after it on that line as descriptive prose. This is
   narrower than today's (post-preamble-fix) behavior but still accepts every observed real
   usage in landed plans (a single name per bullet, named first). Whatever rule is chosen, state
   the accepted Goals surface in `plan-format.md`'s own Goals-block documentation — coordinating
   with the `lean4_plan_with_zero_lean_goals` record if that edit lands in `plan-format.md`
   itself, since that record currently claims the file (see Risks below).
4. **Extend `--dry-run` with an opt-in compile step** (remedy (1) from the dispatch) as the
   higher-leverage, defect-(a)-generalizing safety net: compiling the assembled module converts
   any future declaration-boundary miss into a loud compile error rather than a silent deletion,
   without the assembler needing to enumerate every Lean declaration keyword in advance. Decide
   at plan time whether it runs by default or behind a further flag, and whether a compile
   failure is fatal (new nonzero exit) or advisory (stderr warning, exit unchanged) — the
   dispatch leaves both open. This BimodalLogic repository's own pinned Lean/Mathlib toolchain
   (`lean-toolchain`, `lakefile.toml`) is an available target for exercising this compile step in
   the new test case the acceptance criteria require, if the chosen test harness needs a real
   `lake build` rather than a stub.
5. **Commit the already-landed uncommitted work (R6, R7, AND R8) together with the new fixes**,
   per the dispatch's explicit instruction not to leave it uncommitted — but update the dispatch
   record's own understanding (via this report) that R8 is part of what is being committed, not
   newly implemented. The plan/implementation phase should not re-derive or re-justify R8; it
   should treat it as landed, verify it still passes under the new fixes, and fold it into the
   same commit(s) as the rest of this record's work.
6. **Add the acceptance-mandated test cases** exactly as specified (abbrev-between-theorems,
   anonymous-instance-between-theorems, non-ASCII name in both the Goals cross-check and the
   assembled module, and a Goals bullet with backticked non-keyword prose covering both a
   capitalized namespace-style token and a lowercase prose word) — all four were demonstrated to
   fail against the current source-store script in this research pass (see Findings), satisfying
   the dispatch's "demonstrate each new case fails against the script as it stands" requirement
   without needing to re-derive the demonstration at implementation time. If the compile step
   from recommendation 4 is added, also add the non-compiling-module case the acceptance
   criteria require.
7. **Re-verify the cross-repo file-scope overlap immediately before editing**, since
   `lean4_plan_with_zero_lean_goals`'s `not_started` status in the source-store repo's own task
   space is a point-in-time read, not a durable guarantee, and no dependency edge spans the two
   repositories to catch a change automatically.

## Decisions

- Treated the live source store (`/home/benjamin/.config/nvim/agent-system/extensions/lean`) as
  the sole authority for current behavior, per the dispatch's explicit instruction, and verified
  every defect claim by direct reproduction rather than by reading code and inferring behavior.
- Did not attempt to resolve the discrimination-rule choice for defect (c) definitively — the
  dispatch frames this as a decision for the implementation phase ("evaluate, do not assume"),
  and this research pass's role is to narrow the option space with concrete evidence (ruling
  nothing further out beyond what the dispatch already excludes), not to make the final call.
- Did not edit `challenge-snapshot.md` or `plan-format.md` to state the accepted Goals surface,
  consistent with the dispatch's instruction that `challenge-snapshot.md` is claimed by the
  sibling cross-repo record and is not in this record's file_scope.
- Logged the discrepancy between the dispatch's "ALREADY-LANDED" description and the actual
  (further-progressed) source-store state as a non-blocking issue-log entry, and the successful
  three-for-three live reproduction of all named defects as a win-log entry, per the dispatch's
  issue-log instructions.

## Risks & Mitigations

- **Risk**: an implementation pass could re-implement or needlessly re-justify R8 (the preamble
  exclusion), believing it to be new work, since the dispatch's landed-work section omits it.
  **Mitigation**: this report documents R8's existence, mechanism, and test coverage explicitly;
  the implementation phase should treat R6, R7, and R8 as equally landed-and-to-be-committed.
- **Risk**: fixing defect (b)'s identifier class with a hand-rolled Unicode approximation at each
  of the four sites independently (rather than one shared definition) could leave the sites
  disagreeing again, reproducing the exact failure mode defect (b) itself describes.
  **Mitigation**: recommendation 1 above calls for one shared definition; the plan phase should
  make this an explicit constraint on the implementation, not an incidental choice.
- **Risk**: the cross-repo overlap record `lean4_plan_with_zero_lean_goals` could move from
  `not_started` to active between this research pass and the implementation phase, creating a
  real collision on `lean-challenge-snapshot.sh` with no automated detection.
  **Mitigation**: recommendation 7 above; re-check status immediately before editing.
- **Risk**: extending `--dry-run` with a compile step could be mistaken for a blocking gate change
  given this script's otherwise-careful "advisory only" framing for `--check`.
  **Mitigation**: the file's own header already states `--check`'s advisory-only status
  explicitly; the plan phase should state the new compile step's fatal-or-advisory status with
  equal explicitness in the same header and in `challenge-snapshot.md`'s exit-code vocabulary
  section (coordinating with the sibling record if that file is touched).

## Context Extension Recommendations

- **Topic**: Lean identifier Unicode handling across this tool's regex sites.
- **Gap**: no existing context file documents a canonical Unicode-aware identifier pattern for
  Lean 4 names, so each of the four affected sites was hand-rolled independently with the same
  ASCII-only mistake.
- **Recommendation**: once the implementation phase settles on a Unicode-aware identifier
  pattern (recommendation 1 above), consider recording it in
  `context/project/lean4/domain/lean4-syntax.md` (source store) as a reusable fact, so future
  tooling in this extension does not re-derive or re-break the same character class.

## Appendix

- Source-store repository root used for all code/test reads: `/home/benjamin/.config/nvim`.
- Commands run: `git status --porcelain`, `git diff`, `git log`, `git merge-base --is-ancestor`,
  `bash scripts/tests/test-lean-challenge-snapshot.sh` (source store and deployed copy),
  `diff` between deployed and source-store script/test files, direct invocations of
  `lean-challenge-snapshot.sh --dry-run` against five throwaway scratchpad git repos built to
  isolate each defect, and a `python3 -c` one-liner confirming Python's `\w` matches Unicode
  subscript digits and Greek letters under the default (Unicode) `re` mode.
- Scratchpad reproduction fixtures (not part of any deliverable, isolated under
  `/tmp/claude-1000/.../scratchpad/lcs-repro/`): `repo-a` (abbrev swallowing), `repo-b`
  (anonymous-instance swallowing), `repo-c` (Unicode escape, zero identifiers harvested),
  `repo-d` (Unicode truncation-collision, theorem_names: foo for theorem foo₁), `repo-e`
  (dispatch's exact MEASURED RESIDUAL sentence, still exits 71).
- Issue-log entries written this phase (via `issue-record.sh`, non-blocking): one `issue`
  (dispatch-context staleness re: R8 and deploy-tree freshness), one `win` (three-for-three live
  defect reproduction).
