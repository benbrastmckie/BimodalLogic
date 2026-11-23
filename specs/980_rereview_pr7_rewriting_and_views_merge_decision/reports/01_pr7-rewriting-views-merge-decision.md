# Research Report: Task #980

**Task**: 980 - rereview_pr7_rewriting_and_views_merge_decision
**Started**: 2026-11-21T15:06:48-08:00
**Completed**: 2026-11-21T16:05:00-08:00
**Effort**: ~1 hour
**Dependencies**: None
**Sources/Inputs**:
- Pull request #7 head `5f5ad32bfee5be7e615d1d18b8bf59baffa9f4ce`, reviewed in a detached worktree at `/home/benjamin/Projects/.worktrees/BimodalLogic-pr7` (fetched via `git fetch origin refs/pull/7/head`); head re-checked with `gh pr view 7` after the work and unchanged
- `specs/reviews/pr-reviews-2026-11-20/pr7-review.md`, `pr7-followup.md`
- `records/milestones.md`, `records/proof-mode.md`, `records/proof-mode-architecture.md`, `records/theorem-library.md`
- `specs/state.json` task descriptions for `proof_mode_split_shared_test_and_guide_files` (960), `proof_mode_views_tier` (969), `proof_mode_abstract_frontend_interface` (952), `connective_signature_layer_shared_primitives` (977)
- CI run 44955562343 (`gh run view --log`)
- Local gates: `lake build --wfail`, `lake test`, `lake lint`, `lake build BimodalTools/BimodalToolsTest --wfail`, 15 `lean_exe` roots, `scripts/check-evidence-probes.sh`, `scripts/check-module-invariants.sh --no-build`, `scripts/typst-sync-check.sh`
- Lean probes written and run in the worktree (views behaviour, error messages, stopped wrappers, expression-node measurement), since deleted
**Artifacts**:
- `specs/980_rereview_pr7_rewriting_and_views_merge_decision/reports/01_pr7-rewriting-views-merge-decision.md`
- `specs/reviews/pr-reviews-2026-11-21/pr7-review.md`
**Standards**: report-format.md, subagent-return.md

## Items Needing Your Ruling

**Ruling 1 — which requests are conditions of merging (open decision 1 of `records/milestones.md`).**

| Option | What it makes a condition | Real cost |
|---|---|---|
| **A (recommended)** | The import line, the two `docBlame` docstrings, and a restated or dropped M17 "Current client" paragraph. Everything else becomes a follow-up or an M0/M16/D1/D2 obligation. | The layout record inherits roughly 45 declaration moves across 8 files (inventory in finding (7)) — work it is already written to do, and which the follow-up comment already offered to absorb. The views tier merges at 4 of ~17 operators, so M16 extracts rather than builds. |
| B | Every request, including the filing by family (3a-3d), request 4b's removal of the 14 `tmX`/`plusX` pairs, and the remaining `fail_if_success` conversions. | `proof_mode_split_shared_test_and_guide_files` cannot be dispatched while #7 is open, and it gates A4, A5 (PM-M1, PM-M2, PM-M6a, PM-M13) and A6/gate one. `records/milestones.md`: "Until the stack resolves, no derivation-tier record can be implemented." Five pre-gate records and gate one wait on a round-trip for mechanical moves that M0 will touch again regardless. |

**Recommendation: A.** The three conditions in A are all verified-red or verified-wrong in this task, so each is defensible as a condition on its own evidence; everything in B beyond them is filing or a record obligation. Request 4b in particular is already named by `proof_mode_abstract_frontend_interface` as *its* starting point ("make them fields of these classes and delete the pairs"), so asking the contributor to do it now would duplicate D2's work, not avoid it.

The review's own sub-questions under this ruling, with recommendations: the single S5 step — **met**, no condition needed (`Step.necessity`, instantiated three times); the `#guard_msgs` message tests — **partly met** (4 added, 11 `fail_if_success` remain), recommend follow-up rather than condition, since the four added ones cover the messages the review actually complained about; the option-exposed budgets — **met**, follow-up closed; a named client — **recorded, not landed**, and this is the one the recommendation upgrades to a condition, because the record now carries unverifiable numbers.

**Ruling 2 — is the merge-not-rebase history acceptable?**

| Option | Consequence |
|---|---|
| **Accept under a squash merge (recommended)** | `main` gains one commit whose parent is the current tip; `481d841c5 Merge current main into checked rewriting` never enters `main`'s history. The only residue is the default squash body, which would include that commit's subject line and is editable at merge time. |
| Ask for a rebase | A round-trip, and the merge-base (`06d1a460a`) is already 2 commits behind `main`, so the branch would need re-syncing before merge anyway. #8 and #9 will have to be rebased onto the merged result either way. |

**Recommendation: accept, and say so explicitly** rather than leaving request 1 half-answered — the contributor regenerated `status.typ` as asked and `typst-sync-check.sh` passes, so only the history question is open, and squash merge disposes of it. Verified: `allow_squash_merge: true` on the repository.

**Ruling 3 — what to do about the M17 "Current client" numbers.**

| Option | Consequence |
|---|---|
| **Ask the contributor to restate with method, or drop the paragraph (recommended)** | The record keeps the claim it can support (two tactics against nine lines of proof body) and loses four numbers that do not reproduce. One short request. |
| Correct them yourself in a record commit | Faster, but it silently replaces a contributor's measurement with yours in a record the review asked them to propose edits to, and it does not tell them the direction of the term-size claim was wrong. |

**Recommendation: ask.** The re-measurement is in finding (6): 245 vs 683 unshared expression nodes for the pair the paragraph names — the rewrite variant is about 2.8x *larger* — and 1923 nodes / 2 ms for the nested rewrite against the claimed 167 / 0.14 ms.

## Recommendation for the Pull Request

**REQUEST CHANGES**, on three items, each verified in this task:

1. `FormalSystem/Tactic/FormulaSyntax.lean:8`: `import Lean` -> `import Lean.Meta.AppBuilder`. This is the whole of the red CI: it fails the `--wfail` build and fails C28 of `check-module-invariants.sh`. Verified green.
2. Two docstrings: `FormalSystem/Automation/ProofMode/Simplification.lean:150` (the `lSimpOption` production) and `FormalSystem/Tactic/FormulaViews.lean:35` (the `views` environment extension). `lake lint` fails on both; CI never reached that step.
3. The M17 "Current client" paragraph: restate with the method, or drop it.

Then merge, by squash. Everything that needed judgment — the views and rewriting split, error propagation, the single S5 step, the removed `specs/` link — is done and verified. The filing by family goes to the layout record, and the views-tier gap goes into M16 as what it owes.

## Executive Summary

- **CI is red for exactly one reason, and the fix is one line.** `import Lean` at `FormalSystem/Tactic/FormulaSyntax.lean:8` trips Mathlib's `linter.style.header` under `--wfail`; that single warning fails the build *and* fails C28 of `check-module-invariants.sh` (no disposition row for `linter.style.header`). Replacing it with `import Lean.Meta.AppBuilder` makes `lake build --wfail` green with zero warnings, makes C28 pass, and leaves the file at 121 lines so no generated inventory block needs regenerating. Verified.
- **Running the gates CI never reached found one new red and nothing else.** `lake lint` fails with two `docBlame` errors in PR-added code (`Simplification.lean:150`, `FormulaViews.lean:35`). Everything else is green: `lake test` (3071 jobs), both tooling roots under `--wfail`, all 15 exe roots, the evidence probes, and `check-module-invariants.sh --no-build` in full.
- **The views split is real and the import discipline holds.** The import closures of `FormulaSyntax`, `FormulaPositions` and `FormulaViews` are 16, 17 and 18 modules; nothing under `FormalSystem/Automation/ProofMode/`, `FormalSystem/ProofSystem/` or the rewriting machinery is reachable from any of them. `lrewrite` now refuses a formula equality outright. This was the condition that needed judgment and it is met.
- **The views tier as contributed is a thin slice of M16, and it rests on a second table.** Four view names (`diamond`, `next`, `prev`, `dstab`) over seven rows, against roughly seventeen operators M16 names; no positional form; and the operator-matching helper (`Language.operatorName`, `positionNames`) is a *different* table from `coreViews`, which is exactly deliverable (3) of `proof_mode_views_tier`. `lunfold`/`lfold` call `rewriteTarget`/`rewriteLocalDecl` with no occurrence argument, so they rewrite the first matching instance only — and, at a goal, they will rewrite inside the object context in preference to the conclusion.
- **The M17 "Current client" numbers do not reproduce, and the one pair I could reconstruct runs the other way.** Re-measured: `Perpetuity.boxDne` is 245 unshared expression nodes / 104 objects; the two-tactic `lrewrite` variant is 683 / 123 — about 2.8x larger, not smaller. The nested `[pastBody, futureBody, boxBody]` rewrite measures 1923 unshared nodes and `lrewrite` takes 2 ms, not 167 nodes and 0.14 ms. `boxDne` itself is untouched in the tree, so request 8 is recorded rather than landed.
- **Recommendation: REQUEST CHANGES on three mechanical items, then merge.** The import line, the two docstrings, and the M17 paragraph. Carry the filing by family in `proof_mode_split_shared_test_and_guide_files`, which is already contracted to do it, and record the views-tier gap as what M16 still owes. The merge-not-rebase history is acceptable under a squash merge.

## Context & Scope

Re-review of PR #7 (`feat/proof-mode-rewriting`, head `5f5ad32bf`) against the nine requests of the posted review and the follow-up comment, with one aim: reach a merge decision. PR #7 is the base of the stack (#8 and #9 build on it) and the single blocker of `proof_mode_split_shared_test_and_guide_files`, which in turn gates every pre-gate derivation record.

Constraints observed: nothing posted, pushed, merged or approved; all work in a detached worktree, never the main working tree; every claim below is backed by a command run or a file and line read in this task, and the places where I could not verify something are named as such.

The worktree was given a hardlink clone of the main tree's `.lake/build` and a symlink to its `.lake/packages`, so the gates ran in minutes rather than a from-scratch Mathlib build. The worktree was restored to the pristine head and left clean.

## Findings

### Codebase Patterns

**(1) What CI actually failed on, and what the fix is.**

CI run 44955562343 reports two failing steps, not one:

| Step | Outcome | Cause |
|---|---|---|
| Build, test, and lint with Lean | `lake build` failed | `FormalSystem/Tactic/FormulaSyntax.lean:8:7: Files in mathlib cannot import the whole 'Lean' folder` under `--wfail`. `LEAN_TEST_STATUS` and `LEAN_LINT_STATUS` are both unset: the test and lint steps never ran. |
| Check module invariants (`--no-build`) | FAIL C28 | `warning-budget.py: observed linter class(es) with no disposition row in scripts/warning-budget.txt: linter.style.header` |

Both trace to the same line. `FormalSystem/Tactic/Attr.lean:7` also says `import Lean` and is not flagged, because `Attr.lean` imports nothing else and so never loads Mathlib's linters at all; `FormulaSyntax.lean` imports `FormalSystem.PlusLanguage.Formula`, which reaches Mathlib, so the header linter is live there.

Three candidate fixes were tried:

| Fix | `lake build --wfail` | Side effect |
|---|---|---|
| `import Lean.Meta` | warning persists ("the whole `Lean.Meta` folder") | — |
| delete line 8 | green, 0 warnings | file drops to 120 lines; `INV` then fails with 2 stale generated inventory blocks (`FormalSystem/Tactic/README.md`, `README.md`) |
| `import Lean.Meta.AppBuilder` | **green, 0 warnings** | none; file stays at 121 lines, `INV` green |

`import Lean.Meta.AppBuilder` is the fix to ask for. `INV` was confirmed green at the pristine head, so the stale-inventory failure is an artefact of the line-count change, not of the PR.

**(2) The gates CI never reached.** All run locally at the head with the one-line fix applied in the worktree only.

| Gate | Result |
|---|---|
| `lake build --wfail` (defaultTargets = `FormalSystem`, 3000 jobs) | PASS, 0 warnings |
| `lake test` (`BimodalTest`, 3071 jobs) | PASS |
| `lake lint` (`batteries/runLinter`) | **FAIL — 2 errors in 19777 declarations** |
| `lake build BimodalTools --wfail` | PASS |
| `lake build BimodalToolsTest --wfail` | PASS |
| 15 `lean_exe` roots (`lake_targets.py exe-roots`) | PASS, all 15 |
| `scripts/check-evidence-probes.sh` | PASS |
| `scripts/check-module-invariants.sh --no-build` | PASS — ALL CHECKS PASSED, C28 now "0 warning(s) across 0 file(s)" |
| `scripts/typst-sync-check.sh` | PASS (all 4 checks; `typst/generated/status.typ` is current) |

The two `lake lint` errors, verbatim:

```
-- FormalSystem.Automation.ProofMode.Simplification
FormalSystem/Automation/ProofMode/Simplification.lean:150:1: error:
  FormalSystem.Automation.ProofMode.«lSimpOption(_:=_)» definition missing documentation string

-- FormalSystem.Tactic.FormulaViews
FormalSystem/Tactic/FormulaViews.lean:35:1: error:
  FormalSystem.Tactic.FormulaViews.views constant missing documentation string
```

Both are in PR-added code and both are a one-line docstring. `Simplification.lean:150` is `syntax "(" ident " := " num ")" : lSimpOption` — the `declare_syntax_cat lSimpOption` above it has a docstring but the production does not. `FormulaViews.lean:35` is the `initialize views : SimplePersistentEnvExtension View (Array View)` block.

**(3) The request table.** File and line are at the reviewed head unless stated.

| # | Request | State | Evidence |
|---|---|---|---|
| 1 | Rebase onto `main`; regenerate `status.typ` | **partly** | `main` was *merged* (`481d841c5 Merge current main into checked rewriting`), not rebased onto; merge-base is `06d1a460a` and `main` is now 2 commits past it. `typst/generated/status.typ` regenerated and `typst-sync-check.sh` PASS. |
| 2 | Split views from rewriting (condition of merging) | **done** | `Rewriting.lean:351` throws `formula equalities belong to named views (lunfold or lfold)`. `lunfold`/`lfold` are in `FormalSystem/Tactic/FormulaViews.lean`; the planner in `FormalSystem/Tactic/FormulaPositions.lean`; `assert_not_exists FormalSystem.ProofSystem.DerivationTree FormalSystem.PlusLanguage.PlusDerivationTree` at `FormulaViews.lean:17-18`. Import closures measured clean (see (4)). |
| 3a | Split `Congruence.lean` by family; keep `Kit`, `Step.comp`, path composition generic | **not done / done** | One file, 449 lines, `FormalSystem/Theorems/ProofMode/Congruence.lean`, with `section TM` (line 120) and `section Plus` (line 267). `Kit` (45), `Step` (55), `Step.identity` (73), `Step.necessity` (81), `Step.comp` (109) are generic. |
| 3b | Move `lsimp` seed rules to `ModalBoolean` | **not done** | Seeds live in `FormalSystem/Theorems/ProofMode/Simplification.lean` (`doubleNegationIff` 25, `conjunctionSelfIff` 30, and the five TM⁺ ones 49-67) and in pre-existing `Theorems/ModalS5`. No `*ModalBoolean*` module exists anywhere under `FormalSystem/` or `Tests/`. |
| 3c | Move `□`→`G`/`H` conversions to `ModalTemporalBoolean` | **not done** | `FormalSystem/Theorems/ProofMode/ScopeConversions.lean:27-49` (`boxToFuture`, `boxToPast`, `boxIteration`, `futureIteration`, `pastIteration`, `boxToStability`). No `*ModalTemporal*` module exists. |
| 3d | One test file and one guide page per family | **not done** | Tests still in the shared `Tests/BimodalTest/Automation/ProofModeExtensionsTest.lean` (192 lines); docs still one page, `docs/user-guide/derivation-proof-mode.md` (+59 lines). |
| 4a | State the S5 step once over a structure with the necessity operator as a field | **done** | `Congruence.lean:81` `Step.necessity (box : L → L) (distribution) (mono)`, instantiated three times: `tmBox` (170), `plusBox` (351), `plusStability` (358). |
| 4b | Add no further `tmX`/`plusX` name pairs | **not done** | 14 new pairs in `Congruence.lean` (`tmKit`/`plusKit`, `tmImpLeft`/`plusImpLeft`, `tmImpRight`, `tmBox`, `tmFuture`, `tmPast`, `tmUntilGuard`, `tmUntilEvent`, `tmSinceGuard`, `tmSinceEvent`, `tmNext`, `tmPrev`, `tmNextFuture`, `tmPrevPast`), plus the unpaired `plusStability`. They are *dispatched* through `Language.ruleName`, not removed; 53 `ruleName` call sites under `FormalSystem/` (9 of them pre-existing in `Basic.lean`). See (5). |
| 5a | `lsimp` must not send rule errors to a trace | **partly** | Rules are now pre-validated outside the match loop (`Simplification.lean:63-71`: `elaborateProof`, then `prepareRewriteRule` under `withoutModifyingState`), so a typo reaches the user. The per-attempt `catch error => trace[proofMode.simp] ...` at `Simplification.lean:106-108` remains. |
| 5b | `lrewrite` has the same problem | **done** | `Meta.lean:162` `elaborateProof` now wraps in `Term.withoutErrToSorry`. `nativeRewrite`'s outer handler (`Rewriting.lean:456-458`) restores state and rethrows. |
| 5c | Plan on syntax first, elaborate the rule once, build one certificate | **done** | `prepareRewriteRule` is called once per rule in both tactics; the planner (`planPath`, `FormulaPositions.lean:160`) is pure metadata and builds no proof. |
| 6a | Expose `lsimp`'s attempt and scope budgets as options | **done** | `Simplification.lean:149-151` + `160-167`: `(maxSteps := n)`, `(maxAttempts := n)`, `(maxScopes := n)`. `visits`, `nodes`, `depth` stay fixed; the review asked for attempts and scopes. |
| 6b | `lrewrite` should fail on a no-op | **done** | `Rewriting.lean:256` `rewrite would leave the formula unchanged`, asserted by a `#guard_msgs` test. |
| 6c | Say so when traversal stops at an unregistered wrapper | **done** | `Rewriting.lean:400-403`. Verified: `lrewrite` against a goal containing `A.always` gives `no matching rewrite occurrence; traversal stopped at [FormalSystem.Syntax.Formula.always] (no registered position)`, at a goal and at a hypothesis alike. No test asserts it. |
| 7a | Assert messages with `#guard_msgs` | **partly** | Four `#guard_msgs` tests at the end of `ProofModeExtensionsTest.lean` (unknown identifier; formula-equality refusal; no-op; budget exhaustion). Eleven `fail_if_success` occurrences remain. |
| 7b | Add the past direction, TM⁺ `lsimp`, goal-side polarity | **done** | Past: `ProofModeExtensionsTest.lean:151-158` (`allPast`, `prevBody`, `sinceGuard`). TM⁺ `lsimp`: `166-171`. Goal-side: `160-164` (`lrewrite ←` at `[boxBody]`) and `36-42`. |
| 7c | Move the misplaced soundness test | **done** | No soundness test remains in the file. |
| 8 | Name a client; record term size and elaboration time | **partly** | `records/proof-mode.md` gains a "Current client" paragraph under M17. `FormalSystem/Theorems/Perpetuity/Principles.lean:481` `boxDne` is untouched (`git diff origin/main -- FormalSystem/Theorems/Perpetuity/` is empty), so no existing proof is actually made shorter in the tree. The numbers do not reproduce; see (6). |
| 9 | Remove the `docs/development/README.md` row linking into `specs/`; remove plan labels | **done** | `grep -n "specs/" docs/development/README.md` is empty; no reference to `specs/proof-mode-extensions` outside `specs/` itself; no `P0's`/`Proposed `/bare `P0`-`P2` labels in the new source, tests or guide. `C10` ("zero references to FormalSystem/{docs,latex,typst} outside specs/") and `C9`/`C9D` pass. |

One item not in the nine: the PR body still says `lrewrite` "rewrites goals and named facts using one-way implications, equivalences, **or formula equalities**", which the code now refuses.

**(4) The views tier as contributed.**

Import closures, computed by walking `import` lines from each root:

| Module | Modules in closure | `FormalSystem.*` members | Reaches `Automation/`, `ProofSystem/` or rewriting? |
|---|---|---|---|
| `FormalSystem.Tactic.FormulaSyntax` | 16 | 7 | no |
| `FormalSystem.Tactic.FormulaPositions` | 17 | 8 | no |
| `FormalSystem.Tactic.FormulaViews` | 18 | 8 | no |

The `FormalSystem.*` members are only `Init`, `PlusLanguage.Formula`, `Syntax.Atom`, `Syntax.Context`, `Syntax.Formula`, `Tactic.Attr` and the three modules themselves. The `assert_not_exists` is therefore a live guard, not decoration.

Behaviour of `lunfold`/`lfold`, probed in a module downstream of `FormalSystem.Automation.ProofMode` and read off `trace_state`:

| Probe | Goal/hypothesis before | After `lunfold diamond` |
|---|---|---|
| two distinct occurrences, goal | `Γ ⊢[fc] A.diamond.and B.diamond` | `Γ ⊢[fc] A.neg.box.neg.and B.diamond` — only the first |
| same occurrence twice, goal | `Γ ⊢[fc] A.diamond.and A.diamond` | `Γ ⊢[fc] A.neg.box.neg.and A.neg.box.neg` — both |
| context and conclusion | `A.diamond :: Γ ⊢[fc] B.diamond` | `A.neg.box.neg :: Γ ⊢[fc] B.diamond` — **the object context, not the conclusion** |
| under another operator, goal | `Γ ⊢[fc] A.diamond.box` | `Γ ⊢[fc] A.neg.box.neg.box` |
| two distinct occurrences, at `h` | `Γ ⊢[fc] A.diamond.and B.diamond` | `Γ ⊢[fc] A.neg.box.neg.and B.diamond` — only the first |
| `lfold diamond at h` | `Γ ⊢[fc] A.neg.box.neg` | `Γ ⊢[fc] A.diamond` |
| `lunfold next`, goal | `Γ ⊢[fc] A.next` | `Γ ⊢[fc] Formula.bot.untl A` |

So: `applyView` calls `rewriteTarget equation fold` / `rewriteLocalDecl equation fold id` (`FormulaViews.lean:97-100`) with no occurrence argument, which gives it `rw` semantics — the first match fixes the metavariable and every occurrence of *that instance* is rewritten, the rest are not. Because the rewrite is on the whole goal type, a view that occurs in the object context is reached before one in the conclusion. There is no positional form of either tactic.

The `private theorem` equations resolve from a downstream module: `lunfold next` worked, and `mkCIdent row.equation` (`FormulaViews.lean:94`) carries a preresolved `Syntax.Preresolved.decl`, which bypasses private-name visibility. Verified, not inferred.

`applyView` discards the underlying error (`catch _ => saved.restore`, `FormulaViews.lean:103-104`) and reports a fixed message. Measured consequence:

```
lunfold noSuchView   ->  unknown formula view noSuchView
lunfold diamond      ->  view diamond does not match a formula in this location   (no occurrence)
lunfold dstab        ->  view dstab does not match a formula in this location     (TM goal; dstab is TM⁺-only)
lunfold always       ->  unknown formula view always
```

The `dstab` case is the misleading one: `Language.operatorName` already knows to say `same-state possibility requires TM⁺` (`FormulaSyntax.lean:76`), but `applyView` never consults the language, so the user is told the formula does not match when the real answer is that the view does not exist for this formula type.

The table holds seven rows over four names: `diamond`, `next`, `prev` for `Formula`, and `diamond`, `dstab`, `next`, `prev` for `PlusFormula` (`FormulaViews.lean:58-63`). `lunfold` also works on a goal that is not a derivation at all (`A.diamond = A.diamond`), which is consistent with a view being a cast, but worth knowing.

Against the deliverables of `proof_mode_views_tier` (969, M16):

| M16 deliverable | State |
|---|---|
| (1) fold/unfold on the goal or a named hypothesis, at the head **or at a named position** | partly — no positional form |
| (2) expansion lemmas, each `rfl` or a stated equality, **filed with the syntax of the operator they expand** | partly — seven `private theorem`s inside `FormulaViews.lean`, not filed with the syntax |
| (3) **the operator-matching helper (`operatorArgs?`, the occurrence views) expressed through the same table** | **not done** — `operatorArgs?`/`positionChildren` read `Language.operatorName` and `positionNames`/`viewOperators`; `lunfold`/`lfold` read `coreViews` + the `views` extension. Two tables. |
| (4) tests and a guide page stating the tier boundary | partly — one example in the shared test file; a `lunfold`/`lfold` row and paragraph in the single guide page |
| done-when: a fold and an unfold for every defined operator in TM and TM⁺, each direction tested | not met — 4 names against the ~17 M16 lists and the 28 derived operator defs in `FormalSystem/Syntax/Formula.lean` |
| done-when: a `#print axioms` check on a views-only script | not present |
| done-when: a negative test asserting the wrong-shape message | not present (no `#guard_msgs` on either views error) |

`records/proof-mode-architecture.md`'s "Where the work sits" views row still says "the first rows of the view table are contributed with the rewriting tactics, exposed through the pair" — which is now accurate as written. What needs revising is the claim implicit in M16 deliverable (3): the architecture record describes the operator-matching helper as "resting on the same table", and in the contributed code it does not. M16 should state that it owes (a) one table, by folding `coreViews` and the operator/position tables together, (b) the remaining ~13 TM view names and their TM⁺ counterparts, (c) a positional form, (d) the axiom-freedom probe and the negative test, and (e) re-siting the equations with the syntax of the operators they expand. None of those is a reason to hold the merge; all of them are M16's job and M16 is already sequenced after M0.

**(5) The `Language` table.**

`FormulaSyntax.lean:17-20` is `inductive Language | tm | plus deriving BEq`; `Language.ruleName` (28) selects by it; `Language.operatorName` (31-79) is a hand-written pair table of 19 operator entries, each naming a `Formula` constructor and its `PlusFormula` twin (`stab` and `dstab` map to the same TM⁺ name and refuse TM).

Judged against request 4 and the two records:

- `proof_mode_abstract_frontend_interface` (952, M8/D2) says in terms: *"STARTING POINT IF PULL REQUEST #7 HAS MERGED: its `Kit` and `Step` structures in `Congruence.lean` are already generic over the language and are then instantiated twice (`tmBox` / `plusBox`, ...) and selected by name pairs; make them fields of these classes and delete the pairs."* So the 14 congruence pairs are an **accepted intermediate** that D2 is already contracted to remove. Request 4b is unmet in letter, and the record anticipates exactly that.
- `connective_signature_layer_shared_primitives` (977, D1) is the other half. Its stated defect is "duplication, not the primitive choice": eighteen derived operators defined verbatim in both `FormalSystem/Syntax/Formula.lean` and `FormalSystem/PlusLanguage/Formula.lean`, to be written once as classes with `Formula` and `PlusFormula` as instances. `Language.operatorName` is a *third* statement of that same `Formula`/`PlusFormula` correspondence, in a module D1 does not touch, and D1 will make it redundant for every derived row.
- Join 4 of `records/milestones.md` places D1's implementation "after A1 merges and before A2 is rebased". So the third copy would exist for exactly one window and then be collapsible.

Verdict: acceptable as an intermediate, not a third copy to be undone by the contributor. `Language.ruleName` is in fact an improvement on the status quo — it replaces string concatenation (`derivationName ++ `lift`) with checked `` `` `` names that fail at compile time on a source rename (`Meta.lean:50-64`). The thing to record, not to request, is that D1 owns collapsing `Language.operatorName` into the signature classes and D2 owns deleting the congruence pairs.

**(6) The record edits, re-measured.**

The M17 paragraph as contributed:

> **Current client**: `Perpetuity.boxDne` takes two tactics in the rewrite variant, down from seven proof-body lines. Lean reports 393 versus 159 unshared expression nodes. A rewrite at `[pastBody, futureBody, boxBody]` produces 167 nodes and took 0.14 ms in one warm profiler run on the pinned toolchain. The full comparison still waits on the M3 selection.

Re-measured in the worktree at the head on Lean v4.33.0-rc1, using `Expr.sizeWithoutSharing` (the "unshared expression nodes" metric), `Expr.numObjs`, and `numObjs` after `ShareCommon.shareCommon'`:

| Declaration | unshared | objects | shared objects |
|---|---|---|---|
| `FormalSystem.Theorems.Perpetuity.boxDne` (as in the tree) | 245 | 104 | 104 |
| the same proof body, re-elaborated | 245 | 143 | 104 |
| the two-tactic `lrewrite ← doubleNegation (path := [boxBody])` variant | **683** | 123 | 109 |
| nested `lrewrite ←` at `[pastBody, futureBody, boxBody]`, goal side | 1923 | 182 | 157 |
| the same nested rewrite, fact side | 1939 | 191 | 165 |

`set_option profiler true` on the two-tactic variant reports `tactic execution of FormalSystem.Automation.ProofMode.lrewrite took 2ms`.

None of 393, 159, 167 or 0.14 ms appears, under any reading I tried — including reading "393 versus 159" as the `[size unshared/objects/shared]` pair that `Lean/PrettyPrinter.lean:40` prints. And the direction is wrong on the one pair the paragraph names: the rewrite variant is about 2.8x larger in unshared nodes and larger in objects too. The real saving is in source lines (two tactics against nine non-comment lines, five tactic steps), which is a different claim.

Against the deliverable rules the paragraph also fails `.claude/rules/no-record-versioning-in-deliverables.md` only in spirit, not in letter — it narrates no draft history. What it does breach is the standard the records hold themselves to: a measured number with no statement of what was measured or how is not checkable, which is the whole point of putting it in a record. The architecture-record row edit ("Generic path composition, closed family congruence, and seed equivalences from Boolean interactions | M17; `lrewrite` and `lsimp` apply native rules only. The syntax planner is shared with other tiers.") is accurate and carries no task-number citation, no version language and no link into `specs/`; `C9`, `C9D`, `C10`, `C12` and `C13` all pass.

**(7) What the filing by family would cost `proof_mode_split_shared_test_and_guide_files`.**

M0 (960) is already contracted for it: *"#7 and #8 edit the very files this record moves (the single guide, both ProofMode READMEs, `Meta.lean`, `Modal.lean`, `Temporal.lean`) and add a shared test file `ProofModeExtensionsTest.lean`. Do NOT dispatch the implementation of this record while either is open: run it after each is merged or declined, and move whatever they added into the same layout."*

Everything #7 adds that M0 would then have to move, by file and declaration:

| File | Lines | What moves |
|---|---|---|
| `FormalSystem/Theorems/ProofMode/Congruence.lean` | 449 | `Kit`, `Step`, `Step.identity`, `Step.necessity`, `compTransfer`, `Step.comp` stay generic (a `Congruence.lean` or `Boolean.lean`); `tmKit`/`plusKit`, `tmImpLeft`/`plusImpLeft`, `tmImpRight`/`plusImpRight` -> Boolean; `tmBox`/`plusBox`, `plusStability` -> Modal; `tmFuture`/`plusFuture`, `tmPast`/`plusPast`, `tmUntilGuard`/`plusUntilGuard`, `tmUntilEvent`/`plusUntilEvent`, `tmSinceGuard`/`plusSinceGuard`, `tmSinceEvent`/`plusSinceEvent`, `tmNext`/`plusNext`, `tmPrev`/`plusPrev`, `tmNextFuture`/`plusNextFuture`, `tmPrevPast`/`plusPrevPast` -> Temporal. 29 declarations in 3-4 destinations. |
| `FormalSystem/Theorems/ProofMode/Simplification.lean` | 70 | `ProofMode.doubleNegationIff`, `conjunctionSelfIff` -> Boolean; `PlusLanguage.ProofMode.doubleNegationIff`, `conjunctionSelfIff` -> PlusBoolean; `boxConjIff`, `diamondDisjIff`, `s5DiamondBox` -> PlusModalBoolean; the private `atom`/`assign` helpers follow. 9 declarations. |
| `FormalSystem/Theorems/ProofMode/ScopeConversions.lean` | 52 | `boxToFuture`, `boxToPast`, `futureIteration`, `pastIteration` -> PlusModalTemporalBoolean; `boxIteration`, `boxToStability` -> PlusModal; private `atom` follows. 7 declarations. |
| `FormalSystem/Automation/ProofMode/Rewriting.lean` | 558 | `onePosition`'s 20-arm match is the family split in the elaborator; `scopeConversion`/iteration arms (210-230) are the ModalTemporalBoolean part. One file into 3-4 tactic modules, or left whole with the generic/family boundary made explicit. |
| `FormalSystem/Automation/ProofMode/Simplification.lean` | 177 | the 11 `register_lrewrite` seed registrations (23-33) follow their rules; `SimpBudget`, `nativeSimp` and the `lsimp` syntax are generic. |
| `FormalSystem/Automation/ProofMode/RuleRegistry.lean` | 65 | generic; stays. |
| `Tests/BimodalTest/Automation/ProofModeExtensionsTest.lean` | 192 | 20 examples and 2 private helpers split across one test file per family; the 4 `#guard_msgs` blocks go with the tactic they assert. |
| `docs/user-guide/derivation-proof-mode.md` | +59 | the "Checked rewriting and simplification" section split across one guide page per family. |
| `FormalSystem/Tactic/{FormulaSyntax,FormulaPositions,FormulaViews}.lean` | 432 | **nothing moves**; they are the views tier's own modules and M16 owns them. |
| `FormalSystem/Automation/ProofMode/{Meta,Modal,Temporal}.lean`, both `README.md`s, `FormalSystem/Tactic/README.md` | — | already on M0's list; #7's edits to them are absorbed, not added work. |

So the filing is roughly 45 declarations across 8 files, all of it moves with statements and proofs unchanged — which is precisely the shape M0 was written for and the shape the follow-up comment offered to absorb ("the filing work is mechanical... If you would rather not spend your time on it, I will do those moves myself after merge").

Cost of holding the merge for it instead: `proof_mode_split_shared_test_and_guide_files` cannot be dispatched while #7 or #8 is open, and A3 (family layout) gates A4 (views tier), A5 (scope core, leaf closure, error coverage, cost baseline: PM-M1, PM-M2, PM-M6a, PM-M13) and A6 (gate one). `records/milestones.md` is explicit: "Until the stack resolves, no derivation-tier record can be implemented." Holding the merge for mechanical filing therefore holds five pre-gate records and gate one behind a round-trip with the contributor, for work the layout record is going to touch again anyway.

**(8) Merge, not rebase.** The branch carries `481d841c5 Merge current main into checked rewriting` plus the head commit. The repository allows squash merge (`allow_squash_merge: true`, `squash_merge_commit_title: COMMIT_OR_PR_TITLE`, `squash_merge_commit_message: COMMIT_MESSAGES`). Under a squash merge the merge commit does not enter `main`'s history at all: `main` gains one commit whose parent is the current tip. The only residue is that the default squash body would include the line "Merge current main into checked rewriting", which is editable at merge time. The merge-base is `06d1a460a` and `main` is 2 commits past it, so the merge commit is already stale regardless; `mergeable: MERGEABLE`, `mergeStateStatus: UNSTABLE` (red CI, not a conflict).

### External Resources

No external search was needed. The one Lean-API question that arose — whether a `private theorem` referenced through `mkCIdent` resolves from a downstream module — was settled by running it rather than by reading documentation. `Expr.sizeWithoutSharing` and `Expr.numObjs` were located in the pinned toolchain source (`~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/src/lean/Lean/Expr.lean:2075`, `Lean/Util/NumObjs.lean:48`) and the `[size a/b/c]` convention in `Lean/PrettyPrinter.lean:40`.

### Recommendations

- **Request exactly three changes, then merge: the import line, the two docstrings, and the M17 paragraph.** [VERIFIED: PASS — `import Lean.Meta.AppBuilder` substituted at `FormulaSyntax.lean:8` in the worktree, then `lake build --wfail` (3000 jobs, 0 warnings, exit 0), `lake test` (3071 jobs, exit 0) and `scripts/check-module-invariants.sh --no-build` (ALL CHECKS PASSED, C28 green) all run; the two `lake lint` docBlame errors are the only remaining red, and both are a missing docstring]
- **Do not make the filing by family a condition; carry it in `proof_mode_split_shared_test_and_guide_files`.** [No compiled gate applicable — this is a sequencing judgment; its support is 960's own text forbidding its dispatch while #7 is open, and the 45-declaration inventory in finding (7)]
- **Accept the merge-not-rebase history under a squash merge, and say so rather than leaving it unanswered.** [VERIFIED: PASS — `gh api repos/benbrastmckie/BimodalLogic` reports `allow_squash_merge: true`; `git merge-base` and `git log` confirm the branch's only extra commit is the merge and that it is already behind `main` by 2 commits]
- **Record the views-tier gap as what M16 owes, not as a request on the contributor.** [No compiled gate applicable — a record-content recommendation; the gap itself is measured in finding (4)]
- **Ask for the M17 numbers to be restated with their method, or dropped, rather than silently corrected.** [VERIFIED: FAIL — re-measurement gives 245 vs 683 unshared nodes for the pair the paragraph names, with the direction of benefit reversed, and 1923 nodes / 2 ms for the nested rewrite against the claimed 167 / 0.14 ms; revised to: ask that the paragraph say what was measured and how, and that it claim the saving it actually has (two tactics against nine lines of proof body) rather than a term-size saving the measurement contradicts]
- **Record the residual swallowed errors as follow-ups with the two measured examples, not as conditions.** [VERIFIED: PASS — `lsimp only [density] at provider as reduced` with no `FrameClass.Dense ≤ fc` in scope gives `lsimp made no decreasing change with the supplied rules`, and `lunfold dstab` on a TM goal gives `view dstab does not match a formula in this location`; both measured by running them]
- **Add the PR-body correction to the list, since the body is what a future reader sees.** [No compiled gate applicable — the body text was read from `gh pr view 7 --json body`]

## Decisions

- Reviewed the head recorded in the task description, `5f5ad32bfee5be7e615d1d18b8bf59baffa9f4ce`, and re-checked it with `gh pr view 7` after the work: unchanged, so no new commits needed reviewing.
- Chose `import Lean.Meta.AppBuilder` over deleting line 8, because deleting it changes the file's line count and thereby invalidates two generated inventory blocks — a second, avoidable request on the contributor.
- Did not treat the `INV` failure as a PR defect once it was shown to be an artefact of my own one-line change: `INV` was re-run at the pristine head and passes.
- Ran `lake lint`, `lake test` and the tooling/exe/probe/invariant gates separately rather than trusting the CI report, because CI's own log shows the test and lint steps never ran.
- Treated the 14 `tmX`/`plusX` congruence pairs as an accepted intermediate rather than a merge condition, on the strength of `proof_mode_abstract_frontend_interface`'s own text naming them as its starting point.
- Measured `Expr.sizeWithoutSharing` rather than any proxy, because that is the metric the phrase "unshared expression nodes" names in the Lean source.

## Risks & Mitigations

- **The three requested changes are small enough that the contributor may apply them and re-push without CI going green on the first try.** Mitigation: the draft names the exact replacement import and the exact two declarations, and states that `lake lint` and `lake test` were never reached by CI, so the author knows which gates to run locally.
- **Merging with the views tier at 4 of ~17 operators leaves M16 extracting from merged code rather than building fresh.** `proof_mode_views_tier` already contemplates this ("If #7 or #8 has merged, extract the views already inside them... do not write a second copy"), so the risk is bounded to an extraction that record is written for. Mitigation: record the five specific gaps in M16 before dispatching it.
- **The two tables (`coreViews` against `Language.operatorName`/`positionNames`) can drift: an operator could be positionally traversable but have no view, or vice versa, with nothing announcing it.** Today `diamond`, `next`, `prev`, `dstab` have both and `always`, `sometimes`, `and`, `or` have positions but no view. Mitigation: M16 deliverable (3) is exactly the fix; until then the failure mode is a confusing message, not an unsound proof.
- **`lunfold` reaching into the object context before the conclusion is a correctness-adjacent surprise** — it cannot make an unsound step (a view is a cast and the import graph forbids an axiom), but it can silently change the wrong thing. Mitigation: raised as a follow-up with the measured probe; the positional form M16 owes is the real fix.
- **I did not verify** that `lake lint` is green on `main` at the merge-base; I inferred the two `docBlame` errors are new from the fact that both named declarations are added by this PR. I also did not re-run the `--no-build`-skipped invariants (C1, C2, C6, C24, C25, C36b) in full-build mode, and did not attempt the second gate-one run (A11), which M17 itself still owes.

## Tactic Survey Results

Not applicable (no tactic survey performed). The Lean work in this task was behavioural probing of the contributed tactics and measurement of the terms they produce, not a search for a tactic to close a goal.

## Context Extension Recommendations

- **Topic**: reviewing a pull request's CI failure locally when the project's `.lake/build` is 16 GB and a detached worktree starts empty.
- **Gap**: `context/project/lean4/operations/long-builds.md` covers waiting on a build; nothing covers making a review worktree cheap. The working recipe — symlink `.lake/packages` at the main tree's, `cp -al` its `.lake/build`, copy `.lake/config` and `lakefile.olean`, and keep the five `.lake/build-guard.*` files out of the clone as `lake-build-guard.sh`'s own header requires — turned a from-scratch build into a 20-second incremental one and is not written down anywhere.
- **Recommendation**: add a short section to `context/project/lean4/operations/` (or a sibling `review-worktree-setup.md`) stating the recipe, the hardlink hazard the build guard already documents, and the fact that a PR worktree needs `--no-share` on the guard so it does not replay the main tree's result.

## Appendix

**Commands of record** (worktree `/home/benjamin/Projects/.worktrees/BimodalLogic-pr7`, head `5f5ad32bfee5be7e615d1d18b8bf59baffa9f4ce`):

```
git fetch origin refs/pull/7/head && git worktree add <wt> 5f5ad32bf --detach
gh run view 44955562343 --log-failed ; gh run view 44955562343 --log
lake-build-guard.sh build --no-share -- build --wfail          # 3000 jobs, 0 warnings, exit 0
lake-build-guard.sh build --no-share -- test                   # 3071 jobs, exit 0
lake-build-guard.sh build --no-share -- lint                   # exit 1, 2 docBlame errors
lake-build-guard.sh build --no-share -- build BimodalTools --wfail        # exit 0
lake-build-guard.sh build --no-share -- build BimodalToolsTest --wfail    # exit 0
for root in $(python3 scripts/lake_targets.py exe-roots); do lake build $root; done   # 15/15 exit 0
bash scripts/check-evidence-probes.sh                          # exit 0
bash scripts/check-module-invariants.sh --no-build              # ALL CHECKS PASSED
bash scripts/typst-sync-check.sh                                # PASS (4/4)
gh pr view 7 --json headRefOid,mergeable,mergeStateStatus,body
gh api repos/benbrastmckie/BimodalLogic --jq '{squash,merge,rebase}'
```

**References**

- Review being answered: `specs/reviews/pr-reviews-2026-11-20/pr7-review.md`, `pr7-followup.md`
- Open decision 1: `records/milestones.md`, "Open decisions"
- M17, M16, M0, M8: `records/proof-mode.md`
- Tier and family scheme, "Where the work sits": `records/proof-mode-architecture.md`
- Task descriptions in `specs/state.json`: 960 (`proof_mode_split_shared_test_and_guide_files`), 969 (`proof_mode_views_tier`), 952 (`proof_mode_abstract_frontend_interface`), 977 (`connective_signature_layer_shared_primitives`)
- Draft response: `specs/reviews/pr-reviews-2026-11-21/pr7-review.md`
