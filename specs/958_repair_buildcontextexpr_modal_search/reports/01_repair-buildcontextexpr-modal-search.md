# Research Report: Task #958

**Task**: 958 - Repair FormalSystem/Tactic/Meta.lean's buildContextExpr, which throws on every call and hard-fails modal_search on any box-headed goal.
**Started**: 2026-11-19T18:52:59-08:00
**Completed**: 2026-11-19T19:38:00-08:00
**Effort**: ~45 minutes research; implementation estimated at 1 phase / under 1 hour
**Dependencies**: None (task 955 depends on this one, not the reverse)
**Sources/Inputs**:
- `FormalSystem/Tactic/Meta.lean` (the defect)
- `FormalSystem/Automation/Tactics/Search.lean` (both consumers)
- `FormalSystem/Automation/ProofMode/Meta.lean` (`contextExpr`, the working twin)
- `FormalSystem/Metalogic/Decidability/Propositional/Tactic.lean` (`mkListLit` precedent)
- `Tests/BimodalTest/Automation/LemmaDBTest.lean` (existing coverage, test home)
- `lakefile.toml` (lint/test wiring)
- lean-lsp MCP `lean_run_code` (isolated elaborator probes)
- `lake-build-guard.sh` compiled builds (`BimodalTest.Automation.LemmaDBTest`, `BimodalTest`, full `build`, `test`)
**Artifacts**:
- `specs/958_repair_buildcontextexpr_modal_search/reports/01_repair-buildcontextexpr-modal-search.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Bug reproduced exactly as filed.** `FormalSystem/Tactic/Meta.lean:113` passes an explicit
  argument for `List.nil`'s implicit type parameter, so `mkAppM` raises `too many explicit
  arguments provided to @List.nil` on *every* input, the empty list included. Measured in an
  isolated `lean_run_code` probe: the current shape threw on `[]` and on `[p]`; `mkAppM
  ``List.cons #[f, result]` in the same loop is correct and needs no change.
- **Repair (1) is the convention match, decisively.** `FormalSystem/Automation/ProofMode/Meta.lean:100-106`
  contains `contextExpr`, a line-for-line working twin of `buildContextExpr` that differs only in
  using `mkAppOptM ``List.nil #[some type]`. The repo has three existing `mkAppOptM ``List.nil
  #[some ...]` call sites — one of them at `Search.lean:265`, inside the same file as the two
  broken consumers — and zero uses of the raw `mkApp (mkConst ``List.nil [Level.zero])` shape
  proposed as repair (2). Both repairs were measured working; (1) wins on convention alone.
- **Yes, both `Search.lean` call sites belong inside their `observing?` blocks**, and
  `Search.lean:265` is the in-file precedent: it already builds its nil context inside an
  `observing?`. Moving them is what converts an elaboration failure in a speculative search
  branch from a hard tactic error into a failed branch — the exact reason this defect was
  user-visible rather than a silent search miss.
- **The entire repair plus its tests is already compile-verified green**, end to end: `lake build`
  and `lake test` both exit 0 with zero errors and zero warnings, three `modal_search` acceptance
  examples compile (box-headed at empty context, box-headed at a non-empty all-boxed context, and
  `allFuture`-headed), an invoked `buildContextExpr` probe passes, and the axiom profile is the
  standard `[propext, Classical.choice, Quot.sound]` trio with no `sorryAx`. A counterfactual
  build confirms the box-headed acceptance example is **red** pre-repair, so it is a genuine
  regression test rather than a tautology.
- **One non-obvious gate collision**: moving the call inside `observing?` carries its comment
  with it and leaves a bare blank line that trips Mathlib's "do not place empty lines within
  commands" linter at `Search.lean:473` and `:525`. The repair must delete those two blank lines
  or the zero-warning gate fails.

## Context & Scope

Researched: the precise mechanism of the `buildContextExpr` defect; which of the two proposed
repairs matches this codebase's metaprogramming conventions; whether the two `Search.lean` call
sites should move inside their `observing?` blocks; what a regression test that actually invokes
`buildContextExpr` should look like; whether a `modal_search` acceptance test on a box-headed goal
passes once repaired; and whether the stated verification gate (`lake build` + `lake test` green,
zero warnings, no new axioms) is reachable.

Method: isolated elaborator probes via `lean_run_code` for the `MetaM`-level facts, then four
compiled builds through `lake-build-guard.sh` against a temporary working-tree patch for the
integration-level facts, with a counterfactual build to establish that the proposed acceptance
test discriminates. All working-tree edits were reverted; `git diff -- FormalSystem Tests` is
empty and `FormalSystem/Tactic/Meta.lean` matches its pre-research md5 (`6fe6cc24…`).

Out of scope, deliberately: the `FrameClass.Base` hard-coding in `tryModalK`/`tryTemporalK`, which
both functions' own docstrings already record as a separately deferred capability gap. Repairing
`buildContextExpr` does not touch it and does not make it worse.

## Findings

### Codebase Patterns

**The defect, exactly.** `FormalSystem/Tactic/Meta.lean:111-116`:

```lean
def buildContextExpr (formulas : List Expr) : MetaM Expr := do
  let formulaType := mkConst ``Formula
  let mut result ← mkAppM ``List.nil #[formulaType]   -- line 113: THROWS, always
  for f in formulas.reverse do
    result ← mkAppM ``List.cons #[f, result]
  return result
```

`mkAppM`'s `Array Expr` is its *explicit* arguments. `List.nil : {α : Type u} → List α` has zero
explicit arguments, so one is one too many. `List.cons : {α} → α → List α → List α` has exactly
two, so the loop body is already correct — only line 113 is wrong.

**The working twin.** `FormalSystem/Automation/ProofMode/Meta.lean:100-106`:

```lean
def contextExpr (language : Language) (formulas : Array Expr) : MetaM Expr := do
  let type := mkConst language.formulaNamespace
  let mut result ← mkAppOptM ``List.nil #[some type]
  for formula in formulas.reverse do
    result ← mkAppM ``List.cons #[formula, result]
  return result
```

Same `let mut` + reverse-fold shape, same `mkAppM ``List.cons`, differing only in the nil line.
This settles the "which repair matches the surrounding conventions" question that the task
description left open: repair (1) makes `buildContextExpr` identical to a function that already
works in this repository.

**Convention census.** `mkAppOptM ``List.nil #[some ...]` appears at
`ProofMode/Meta.lean:103`, `Automation/Tactics/Search.lean:265`, and (two-argument form)
`ProofMode/Modal.lean:58`. `Lean.mkApp (Lean.mkConst ``List.nil [Level.zero])` appears nowhere.
`Meta.mkListLit` appears once, at `Metalogic/Decidability/Propositional/Tactic.lean:137`.

**The `observing?` placement.** Both consumers build the context expression *outside* the block:

| Site | Current shape |
|------|---------------|
| `Search.lean:474-476` (`tryModalK`) | `let unboxedCtxExpr ← buildContextExpr unboxedCtx` then `let success ← observing? do` |
| `Search.lean:526-528` (`tryTemporalK`) | `let unfuturedCtxExpr ← buildContextExpr unfuturedCtx` then `let success ← observing? do` |

Three facts make moving them the right call. First, it is why this bug is a hard tactic error
rather than a search miss — the exception escapes `tryModalK` entirely instead of being recorded
as a failed branch. Second, `Search.lean:265` in the same file already builds its nil context
*inside* an `observing?`, so the in-file convention is unambiguous. Third, the repair does not
make the throw impossible in principle: `mkAppM ``List.cons #[f, result]` can still fail if `f`
is not a well-typed `Formula` (`extractUnboxedContext` pattern-matches `.app (.const
``Formula.box _) inner` at the `Expr` level, which does not by itself guarantee `inner`'s type in
a metavariable context). A speculative search branch should absorb that, not abort the tactic.

**No existing test can regress.** Because `buildContextExpr` currently throws unconditionally, any
test that reached `tryModalK` or `tryTemporalK` would already be red. Measured baseline before any
edit: `lake build BimodalTest` exits 0 with zero errors and zero warnings. Therefore **no test in
the suite currently reaches either function**, and the repair can only enable paths, never change
a passing one. The nearest box-headed goal in the suite, `Tests/BimodalTest/Theorems/PerpetuityTest.lean:41`
(`⊢ (φ.imp φ).box`), is proved by hand from `Axiom.prop_s`/`Axiom.prop_k`, not by `modal_search` —
consistent with that baseline.

**Test home is correct as filed.** `Tests/BimodalTest/Automation/LemmaDBTest.lean:230-278`
(`section MetaHelperProbes`) already holds the `MetaM` probes for `Tactic/Meta.lean`'s helpers, and
its own prose at lines 235-241 documents precisely why `buildContextExpr` is `#check`ed and never
applied — naming the `mkAppM ``List.nil` defect and stating that "the repair belongs to whoever
edits that declaration". That paragraph is the thing this task retires; it must be rewritten, not
left standing beside a now-passing invoked probe.

**Lint/test wiring.** `lakefile.toml` sets `testDriver = "BimodalTest"` (so `lake test` builds the
whole test library) and enables `weak.linter.mathlibStandardSet = true` at package level, which is
what produces the blank-line finding below. The `BimodalTest` library opts out of
`linter.hashCommand` only, so `#eval`/`#check` probes are sanctioned content there.

### Compiled Verification Record

Every row below was measured in this research dispatch, not projected.

| # | What was measured | Method | Result |
|---|-------------------|--------|--------|
| 1 | Current shape throws on `[]` and on `[p]` | `lean_run_code`, `observing?`-wrapped | **Throws both** — bug confirmed |
| 2 | Repair (1) `mkAppOptM ``List.nil #[some formulaType]` | `lean_run_code`; `inferType` vs `Context`, `Meta.check` | **PASS** — `[]` and `[p,q]` both build, both `Context` |
| 3 | Repair (2) `Lean.mkApp (Lean.mkConst ``List.nil [Level.zero]) formulaType` | same | **PASS** — also works |
| 4 | `mkListLit (mkConst ``Formula) formulas` equals the repaired loop | `lean_run_code`, `Expr` `==` | **Syntactically identical** for `[]` and `[p,q]` |
| 5 | Repair (1) + invoked probe + box-headed `modal_search` | `lake build BimodalTest.Automation.LemmaDBTest` | **exit 0**, probe printed, 0 warnings |
| 6 | Counterfactual: same acceptance example, repair reverted | same build | **exit 1**, `AppBuilder for `mkAppM`, too many explicit arguments provided to` at the example |
| 7 | Both call sites moved inside `observing?` | same build | **exit 0**, but 2 linter warnings (see below) |
| 8 | Same, with the two stray blank lines deleted | same build | **exit 0**, zero errors, zero warnings |
| 9 | Full repair + 3 acceptance examples + invoked probe | same build | **exit 0**, zero warnings |
| 10 | Stated gate, part 1 | `lake build` (full project) | **exit 0**, zero errors, zero warnings |
| 11 | Stated gate, part 2 | `lake test` | **exit 0**, 3061/3061 built, zero warnings |
| 12 | No new axioms | `#print axioms` on named copies of the box- and `allFuture`-headed goals | `[propext, Classical.choice, Quot.sound]` only; no `sorryAx` |
| 13 | Pre-edit baseline (no test reaches the broken function) | `lake build BimodalTest` | **exit 0**, zero errors, zero warnings |

Rows 5-11 were run against a temporary working-tree patch; the patch is reverted and the tree is
byte-identical to its pre-research state.

**The gate collision (row 7).** Moving the `buildContextExpr` call inside `observing?` takes its
`-- Build the unboxed context expression` comment with it. What remains is a blank line directly
above `let success ← observing? do`, which Mathlib's standard linter set rejects:

```
warning: FormalSystem/Automation/Tactics/Search.lean:473:0: Please, write a comment here or
remove this line, but do not place empty lines within commands!
```

— once for `tryModalK` at `:473` and once for `tryTemporalK` at `:525`. The blank line was legal
before the move only because a comment line followed it. The repair must delete both blank lines
(row 8 confirms that clears it) or keep a comment in place. This is invisible to review and only a
compiled build surfaces it.

**The three acceptance examples that compile (row 9).** All verified green together:

```lean
-- box-headed, empty context (the example named in the task description)
example : ⊢ ((Formula.atomS "p").imp (Formula.atomS "p")).box := by modal_search

-- box-headed, non-empty all-boxed context: exercises the map-box/cons path, not just nil
example : [(Formula.atomS "p").box] ⊢ ((Formula.atomS "p").imp (Formula.atomS "p")).box := by
  modal_search

-- allFuture-headed: covers tryTemporalK, the second consumer
example : ⊢ ((Formula.atomS "p").imp (Formula.atomS "p")).allFuture := by modal_search
```

The second is worth keeping: with an empty context `buildContextExpr` is only ever called on `[]`,
so a nil-only test would leave the `List.cons` fold unexercised through the tactic. The third
covers `tryTemporalK`, whose call site is being changed identically and which otherwise gets no
acceptance coverage at all.

**The invoked probe that passes (row 9).** This is the regression test the task asks for — it
invokes `buildContextExpr` on both the empty and a two-element list, checks the results type-check,
and pins them against `Meta.mkListLit`:

```lean
#eval show MetaM Unit from do
  let p := mkApp (mkConst ``Formula.atomS) (mkStrLit "p")
  let q := mkApp (mkConst ``Formula.atomS) (mkStrLit "q")
  let nil ← buildContextExpr []
  Meta.check nil
  unless (← Meta.isDefEq (← Meta.inferType nil) (mkConst ``Context)) do
    throwError "buildContextExpr [] : {← Meta.inferType nil}, expected Context"
  unless nil == (← Meta.mkListLit (mkConst ``Formula) []) do
    throwError "buildContextExpr [] built {nil}"
  let two ← buildContextExpr [p, q]
  Meta.check two
  unless two == (← Meta.mkListLit (mkConst ``Formula) [p, q]) do
    throwError "buildContextExpr [p, q] built {two}"
```

Note `Meta.check`, not bare `check`: the test file opens `Lean` but not `Lean.Meta`, and a first
attempt with bare `check` failed with `Unknown identifier `check``.

### External Resources

No Mathlib search was needed and none was performed. Every question this task raises is answered by
in-repo precedent plus the Lean 4 `Lean.Meta` `AppBuilder` API (`mkAppM`, `mkAppOptM`, `mkListLit`),
whose behaviour was measured directly rather than looked up. `lean_local_search` and the
rate-limited search tools were therefore not consulted; `lean_run_code` and compiled `lake` builds
supplied the whole evidence base, which is the stronger tier.

### Recommendations

- **Apply repair (1) at `FormalSystem/Tactic/Meta.lean:113`**: replace
  `let mut result ← mkAppM ``List.nil #[formulaType]` with
  `let mut result ← mkAppOptM ``List.nil #[some formulaType]`, leaving the `List.cons` loop
  untouched. [VERIFIED: PASS — `lean_run_code` probe produced `[]` and `[Formula.atomS "p",
  Formula.atomS "q"]`, both `inferType`-checked as `Context`; then `lake build` and `lake test`
  both exit 0 with zero warnings]
- **Prefer (1) over (2) on convention grounds**, not on behaviour: both work, but
  `ProofMode/Meta.lean:100-106`'s `contextExpr` is the same function already written with
  `mkAppOptM`, the repo has three `mkAppOptM ``List.nil` sites and zero raw-`mkConst`-with-explicit-`Level.zero`
  sites, and one of the three is in `Search.lean` itself. [VERIFIED: PASS — repair (2) measured
  working too, so this is a style ruling over two green options, not a correctness claim]
- **Move both `buildContextExpr` calls inside their `observing?` blocks** (`Search.lean` in
  `tryModalK` and `tryTemporalK`), as the first statement of the block, above `setGoals [goal]`.
  The call does not depend on goal state, and `observing?`'s state rollback on failure is harmless
  to it. [VERIFIED: PASS — compiled green at row 8, and `Search.lean:265`'s existing
  inside-`observing?` nil build is the in-file precedent]
- **Delete the two blank lines left above `let success ← observing? do`** at what are currently
  `Search.lean:473` and `:525` as part of that move. [VERIFIED: FAIL then PASS — the move alone
  produced two `linter.style` "empty lines within commands" warnings (row 7), which would fail the
  task's zero-warning gate; deleting the blank lines cleared both (row 8)]
- **Add the invoked `MetaM` regression probe and all three `modal_search` acceptance examples** to
  `Tests/BimodalTest/Automation/LemmaDBTest.lean`'s `section MetaHelperProbes`, keeping the
  existing `#check @buildContextExpr` beside them. Keep all three acceptance examples: the
  non-empty-context one is the only thing that drives the `List.cons` fold through the tactic, and
  the `allFuture` one is the only coverage `tryTemporalK` gets. [VERIFIED: PASS — exact bodies
  above compiled green together at row 9, with the probe's `IO.println` observed in the build log]
- **Rewrite `LemmaDBTest.lean:235-241`**, the paragraph explaining why `buildContextExpr` is
  `#check`ed and never applied. It names the now-fixed defect and says "the repair belongs to
  whoever edits that declaration"; left in place it would contradict the invoked probe sitting
  directly beneath it. [No compiled gate applicable — prose]
- **Do not touch the `FrameClass.Base` hard-coding** in `tryModalK`/`tryTemporalK`. Both
  docstrings already record it as a deliberately deferred elaborator gap, it is orthogonal to this
  defect, and the acceptance examples all pass at `FrameClass.Base`. [No compiled gate applicable
  — scope ruling]
- **One phase is enough.** The repair is three edited lines in two source files plus one test
  block, and the whole thing is already measured green against the stated gate. A multi-phase
  decomposition would add ceremony without adding verification. [No compiled gate applicable —
  planning judgment]

## Decisions

- **Repair (1), `mkAppOptM`, over repair (2).** Decided on in-repo convention: a line-for-line
  working twin exists at `ProofMode/Meta.lean:100-106`, and the raw-`mkConst` shape has no
  precedent in this codebase. Both were measured working, so this is a style call between two
  verified options.
- **`mkListLit` noted but not recommended.** `Meta.mkListLit (mkConst ``Formula) formulas` produces
  a syntactically identical `Expr` to the repaired loop (measured, row 4) and would collapse
  `buildContextExpr` to one line. Rejected as the primary recommendation anyway: it moves the
  function *away* from its twin rather than toward it, and a one-line rewrite is a larger change
  than the one-token fix the defect actually calls for. Recorded here so the option is visible if
  a later consolidation pass wants both `buildContextExpr` and `contextExpr` simplified together.
- **Both `observing?` moves are in scope.** The task description asked this to be "assessed"; the
  assessment resolves yes, on the in-file precedent plus the residual throw path through
  `mkAppM ``List.cons`.
- **Verified during research rather than deferred to the plan.** The repair names a concrete
  artifact and the project's own `lake build`/`lake test` gate decides its acceptance, so the gate
  was run here. This also produced the blank-line finding, which a paper plan would have missed.
- **Working-tree discipline.** All probe edits were made against saved copies in the session
  scratchpad and restored from them, not via `git checkout --`, because the shared tree carries
  other sessions' uncommitted `specs/` changes and the destructive-git guard blocks a pathspec
  discard on any dirty tree. Post-revert md5 and an empty `git diff -- FormalSystem Tests` confirm
  the restore.

## Risks & Mitigations

- **Stale build cache from this research.** The probe builds left `.lake` oleans compiled from the
  patched sources for `FormalSystem.Tactic.Meta`, `…Tactics.Search`, `…Tactics.Commands` and
  `BimodalTest.Automation.LemmaDBTest`. The sources are now reverted, so Lake will recompile those
  four on the next build; nothing needs cleaning. Mitigation: none required, but do not read a
  fast first build as evidence the repair is already applied — check the source line.
- **The blank-line linter finding is easy to reintroduce.** Any later reflow of those two blocks
  can put the blank line back. Mitigation: the `lake build` zero-warning gate catches it, which is
  how it was found; keep that gate in the phase's verification criteria rather than relying on a
  scoped build of the test module alone.
- **`tryModalK` now actually fires, so it becomes reachable for the first time.** Its
  `goal.assign proof` does not typecheck the assignment, so a context/formula mismatch would
  surface as a downstream elaboration error rather than a clean branch failure. Measured risk is
  low — all three acceptance examples compile and `lake test` is green across 3061 targets — but
  this is genuinely new code coverage, not a restoration. Mitigation: the full `lake test` run is
  the check, and it passed.
- **`Formula.allFuture` is a `def`, not a constructor** (`Syntax/Formula.lean:168`), so
  `tryTemporalK`'s `.app (.const ``Formula.allFuture _) inner` match depends on the goal remaining
  unfolded. The `allFuture`-headed acceptance example compiles, so it does hold as written.
  Mitigation: that example *is* the guard; keep it.
- **Task 955 consumes this function.** As the task description records, 955 would use
  `modal_search` as a bounded fallback and depends on this repair landing first. Mitigation: no
  action here beyond not widening scope into 955's territory.

## Tactic Survey Results

Not applicable in the usual sense: this task's goals are elaborator-level, not proof-goal-level, so
there is no open `MetaM` goal for `simp`/`omega`/`aesop` to attack and `lean_multi_attempt` has no
proof position to work at. The three `modal_search` acceptance examples below are the tactic-level
measurement that corresponds to this section, and all were run through compiled builds rather than
speculative attempts.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `⊢ ((atomS "p").imp (atomS "p")).box` | `modal_search` | success (post-repair) | default depth/visitLimit; routes via `tryModalK` + `generalizedModalK` |
| `[(atomS "p").box] ⊢ ((atomS "p").imp (atomS "p")).box` | `modal_search` | success (post-repair) | default; exercises the `List.cons` fold |
| `⊢ ((atomS "p").imp (atomS "p")).allFuture` | `modal_search` | success (post-repair) | default; routes via `tryTemporalK` + `generalizedTemporalK` |
| `⊢ ((atomS "p").imp (atomS "p")).box` | `modal_search` | **fail** (pre-repair) | `AppBuilder for `mkAppM`, too many explicit arguments provided to` |

## Context Extension Recommendations

- **Topic**: `mkAppM` vs `mkAppOptM` argument-arity discipline in this repo's `MetaM` helpers
- **Gap**: `context/project/lean4/` has `tools/mcp-tools-guide.md` and
  `patterns/dependency-tracing.md` but nothing on the `AppBuilder` API. This defect's entire
  mechanism — `mkAppM`'s array is *explicit* arguments only, so any implicit type parameter must go
  through `mkAppOptM` with `some`/`none` slots — is a trap that compiles clean and fails only at
  elaboration time, and the repo already contains one correct and one incorrect instance of the
  same three-line idiom.
- **Recommendation**: add `context/project/lean4/patterns/appbuilder-argument-arity.md` recording
  the rule, the `buildContextExpr`/`contextExpr` pair as the worked contrast, the
  `Meta.mkListLit` shortcut for list literals, and the standing obligation that a `MetaM` helper
  needs an *invoked* `#eval` probe rather than a `#check` — since a `#check` pins the signature of a
  function that throws on every input, which is exactly how this defect survived.

## Appendix

**Compiled probes and build logs** (session scratchpad, cleared on reboot):

- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/8737ee4e-d283-4903-ab90-224e3af02571/scratchpad/probe-build2.log` — repair (1) + invoked probe + box-headed example, green
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/8737ee4e-d283-4903-ab90-224e3af02571/scratchpad/probe-build3.log` — counterfactual, red with the `AppBuilder` error
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/8737ee4e-d283-4903-ab90-224e3af02571/scratchpad/probe-build4.log` — `observing?` moves, green with 2 linter warnings
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/8737ee4e-d283-4903-ab90-224e3af02571/scratchpad/probe-build5.log` — blank lines deleted, zero warnings
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/8737ee4e-d283-4903-ab90-224e3af02571/scratchpad/probe-build6.log` — full candidate test block, green
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/8737ee4e-d283-4903-ab90-224e3af02571/scratchpad/full-build.log` — `lake build`, exit 0, zero warnings
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/8737ee4e-d283-4903-ab90-224e3af02571/scratchpad/full-test.log` — `lake test`, exit 0, 3061/3061
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/8737ee4e-d283-4903-ab90-224e3af02571/scratchpad/test-baseline.log` — pre-edit `lake build BimodalTest` baseline, exit 0

**Search queries used**: none against LeanSearch, Loogle, LeanFinder or `lean_local_search` — see
`### External Resources` for why. Evidence came from `lean_run_code` probes, `grep` sweeps of the
working tree, and eight compiled `lake-build-guard.sh` runs.

**Key source locations**:

- `FormalSystem/Tactic/Meta.lean:111-116` — `buildContextExpr`, the defect at `:113`
- `FormalSystem/Automation/ProofMode/Meta.lean:100-106` — `contextExpr`, the working twin
- `FormalSystem/Automation/Tactics/Search.lean:474-476`, `:526-528` — the two call sites to move
- `FormalSystem/Automation/Tactics/Search.lean:265` — in-file `mkAppOptM ``List.nil` inside `observing?`
- `FormalSystem/Metalogic/Decidability/Propositional/Tactic.lean:137` — the `mkListLit` precedent
- `FormalSystem/Theorems/GeneralizedNecessitation.lean:148`, `:183` — `generalizedModalK`, `generalizedTemporalK`
- `FormalSystem/Syntax/Formula.lean:168` — `allFuture` is a `def`, not a constructor
- `Tests/BimodalTest/Automation/LemmaDBTest.lean:230-278` — `section MetaHelperProbes`, the test home
- `Tests/BimodalTest/Automation/LemmaDBTest.lean:235-241` — the paragraph this task retires
- `lakefile.toml:20-21`, `:30-34`, `:58-61` — `testDriver`, the Mathlib linter set, the `BimodalTest` opt-out
