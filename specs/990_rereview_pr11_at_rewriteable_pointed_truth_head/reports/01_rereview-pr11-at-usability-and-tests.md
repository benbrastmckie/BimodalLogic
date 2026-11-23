# Research Report: Task #990

**Task**: 990 - Rereview pr11 at rewriteable pointed truth head
**Started**: 2026-11-23T00:56:00Z
**Completed**: 2026-11-23T02:35:00Z
**Effort**: ~1.6 hours (dominated by one from-scratch `lake build` of the review worktree)
**Dependencies**: None
**Sources/Inputs**:
- `specs/reviews/pr-reviews-2026-11-21/pr11-comment.md` (the posted `CHANGES_REQUESTED` body; the three conditions)
- `specs/reviews/pr-reviews-2026-11-21/pr11-review.md` (the long backing review)
- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` (post list and decided positions)
- GitHub: `gh pr view 11`, `gh api .../pulls/11/reviews`, `gh api .../issues/11/comments`, `gh run list`
- Review worktree `/home/benjamin/Projects/.worktrees/BimodalLogic-pr11-rereview` at `b2eb3ac0b`, `.lake/build` built from scratch
- Eight single-example Lean probe files, compiled individually with `lake env lean`
**Artifacts**:
- `specs/990_rereview_pr11_at_rewriteable_pointed_truth_head/reports/01_rereview-pr11-at-usability-and-tests.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- All three posted conditions are met at head `b2eb3ac0b`. The recommendation is **approve**.
- The head has not moved: `b2eb3ac0b57d0f6082235aee0b861d8249bd7687`, `updatedAt` 2026-11-23T04:33:16Z, `OPEN`, not draft, `mergeable=MERGEABLE`, `mergeStateStatus=CLEAN`. Checked at the start and again at the end of this dispatch, unchanged. CI run `45112546558` on this head: `success`.
- Condition 1 (rebase and regenerate) is met by the generators' own verdicts, not by inspection: `lake exe mk_all --lib FormalSystem` reports "No update necessary", `check-module-invariants.sh --emit-inventory` reports "no generated inventory block needed a rewrite", and the full invariants run's C33 reports `FormalSystem.lean` byte-for-byte generated with 791 import lines. The tree stays clean through all three.
- Condition 2 (`At` usable) is met **as asked**, with a shape worth stating plainly: `rw` still does not see through `At`. What now works is a three-lemma `simp only [at_def, TruthEnv.T, <language clause lemma>]`, measured to work in goal and hypothesis position and at L, L⁺ and L⋆. `at_def` is genuinely load-bearing for that route (omitting it leaves `simp` with no progress to make) and redundant on a generic clause former.
- Condition 3 (tests) is met: every lemma named in the posted comment now has a test, 7 of the 13 transport factories are exercised — one per family — and two L⋆ rows thread the non-`PUnit` environment `regs : ℕ → F.Duration` explicitly.
- Gates at the head: `lake build --wfail` green (3010 jobs, zero warnings), `lake test` green (3086 jobs), `lake lint` green, full `check-module-invariants.sh` ALL CHECKS PASSED (57 PASS, no FAIL/WARN, C3 sorry inventory zero), and all 69 declarations of the four PR modules inside `[propext, Classical.choice, Quot.sound]`.

## Context & Scope

A `CHANGES_REQUESTED` review was posted on PR #11 at 2026-11-23T01:57:16Z against `c6cd983b7`, carrying exactly three conditions: rebase onto `main` and regenerate the generated files; make `At` usable in tactic proofs, with one test that rewrites a clause under it; and add tests for the named untested lemmas, including at least one at L⋆. Everything else in that comment was explicitly filed as "after the merge, not conditions of it".

The contributor pushed `b2eb3ac0b` ("Make pointed truth rewriteable and exercise semantic rule families") at 2026-11-23T04:33:14Z. The earlier review record closed against the old head and never saw it. This research checks each of the three conditions against the new head by building and testing it in an isolated worktree, and settles whether the response should be an approval or a restatement of what is still open.

Scope limits: nothing is posted, pushed, merged or approved here. The draft response and the `FOLLOWUP.md` entry are implementation-phase deliverables; this report fixes the verdict and the evidence behind it.

### Carried-figure re-validation (dispatch description vs. measurement)

| Claim in the description | Status | Evidence |
|---|---|---|
| head `b2eb3ac0b`, pushed 2026-11-23T04:33Z | CONFIRMED | `gh pr view 11 --json headRefOid,updatedAt` |
| review posted 2026-11-23T01:57Z against `c6cd983b7` | CONFIRMED | `gh api .../pulls/11/reviews` -> one `CHANGES_REQUESTED`, `submitted_at` 01:57:16Z, `commit_id` `c6cd983b79842368ae789488d38e488656f98992` |
| the push merges `main`; conflict gone; PR is `MERGEABLE` | CONFIRMED | `b2eb3ac0b` is a merge of `c6cd983b7` and `171021f4b` (= `origin/main`); `mergeable=MERGEABLE`, `mergeStateStatus=CLEAN` |
| `PointTransport.lean` +7/-2 | CONFIRMED | `git diff --numstat c6cd983b7 b2eb3ac0b` -> `7 2` |
| `TemporalRulesTest.lean` (+72) | **CORRECTED** | measured `65 7`, not `+72`: the `someFuture_bind`/`somePast_bind` rows were rewritten in place, not added beside |
| `PointTransportTest.lean` (+35) | **CORRECTED** | measured `34 1` |
| "plus the generated files" | CONFIRMED | `FormalSystem.lean` `15 0`, `FormalSystem/README.md` `1 1`, `README.md` `3 3`, `typst/generated/status.typ` `7 7`, `Tests/BimodalTest.lean` `4 0`, plus the files `main` brought in |

Neither correction changes any verdict below.

## Findings

### Codebase Patterns

- **The PR's own surface against `main` is exactly 14 paths.** `git diff --name-only origin/main b2eb3ac0b` returns the 14 files `gh pr view 11 --json files` lists and nothing else; `origin/main` is `171021f4b`, the merge's second parent. Four of those are new Lean modules (`Semantics/{PointTransport,RankProgress,TemporalIntervals,TemporalRules}.lean`), two are new test modules, five are generated or root-import files, and three are README inventory rows.
- **`at_def`'s placement follows the file's existing shape.** It sits in `section Pointed` immediately after the `At` abbrev, with a docstring that names the extra simp-set entry the idiom needs. The only other source change is the `Point.env` docstring, "inert environment" -> "evaluation environment" — a correction, since L⋆'s environment is `ℕ → F.Duration` and is not inert.
- **The `_keeping` lemmas really do depend on the lemmas whose tests they replaced.** `someFuture_bind_keeping` is proved from `someFuture_bind` and `allFuture_persist`; `somePast_bind_keeping` from `somePast_bind` and `allPast_persist` (`FormalSystem/Semantics/TemporalRules.lean`). So the test rewrite leaves those four exercised transitively rather than dropping them.
- **The thirteen transport factories fall into seven relation families** by the relation each quantifies over: `CorrRel`/`IsoRel`/`AntiIsoRel` (correspondence), `Shifted` (time shift, TM and TM⁺), `Reflected` (reversal, TM and TM⁺), `AnyPoint` (box, TM and TM⁺), `SameState` (stab), `SameStateNow` plus `Eq` (state-local), `MorphRel` (history morphism).

### External Resources

- CI on the head: run `45112546558`, workflow `CI`, `conclusion: success`, 04:33:18Z -> 04:50:38Z.
- Contributor response: none in prose. `gh api .../issues/11/comments` and `gh api .../pulls/11/comments` are both empty; the commit message body is empty. The three conditions were answered by code alone.

### Condition 1 — rebase onto `main` and regenerate

Met. Every check ran in the worktree at the head, on a clean tree.

| Check | Result |
|---|---|
| `lake exe mk_all --lib FormalSystem` | `No update necessary`; `git status --short` stays empty |
| `bash scripts/check-module-invariants.sh --emit-inventory` | `no generated inventory block needed a rewrite`; tree stays empty |
| full `check-module-invariants.sh`, check C33 | `FormalSystem.lean is byte-for-byte the generated root: 791 import line(s), one per .lean file under FormalSystem/` |
| `bash scripts/typst-status-counts.sh` | every count regenerates identically; only the stamp changes (`stamp-commit` `c6cd983` -> `b2eb3ac0b`) |

The `status.typ` stamp naming `c6cd983` rather than the merge commit is the generator recording the HEAD it was run at, one commit before the merge that carries it. Every substantive figure in the file — `formalsystem-file-count = 791`, `formalsystem-line-count = 418901`, `tests-file-count = 91`, `tests-line-count = 29480` — reproduces exactly at the head. This is not a hand-resolved conflict.

### Condition 2 — make `At` usable in tactic proofs, with a test

Met as asked. The contributor took the `at_def` option the comment offered and added one test. The measured behaviour is more specific than "it works", and the response should say which part works.

What shipped (`FormalSystem/Semantics/PointTransport.lean`):

```
@[simp] theorem at_def (M : TaskModel F) (p : Point L F) (A : L) :
    At M p A ↔ TruthEnv.T M p.history p.time p.env A := Iff.rfl
```

with a docstring stating that a concrete language clause additionally needs `TruthEnv.T` in the simp set to reduce the instance projection, and one test in `PointTransportTest.lean` using `simp only [at_def, TruthEnv.T, PlusTruth.allFuture_iff]`.

Measured at the head, one example per file, each compiled on its own with `lake env lean`:

| # | Goal / position | Tactic | Result |
|---|---|---|---|
| 1 | `At M p A.allFuture`, `p : Point PlusFormula F` | `rw [PlusTruth.allFuture_iff]` | FAIL — pattern not found; unchanged from the review |
| 2 | same | `rw [TruthClauses.allFuture_iff]` | FAIL — pattern not found |
| 3 | same | `rw [at_def]` | **SUCCEEDS**; goal becomes `TruthEnv.T M p.history p.time p.env A.allFuture` |
| 4 | after (3) | `rw [PlusTruth.allFuture_iff]` | FAIL — instance projection not reduced |
| 5 | same | `simp only [at_def]` then `rw [PlusTruth.allFuture_iff]` | FAIL, same reason |
| 6 | same, `at_def` omitted | `simp only [TruthEnv.T, PlusTruth.allFuture_iff]` | FAIL — "`simp` made no progress" |
| 7 | same | `simp only [at_def, TruthClauses.allFuture_iff]` | partial — `at_def` fires, the generic lemma is reported unused (the formula is `PlusFormula.allFuture`, not `TruthClauses.allFuture`) |
| 8 | same (the shipped idiom) | `simp only [at_def, TruthEnv.T, PlusTruth.allFuture_iff]` | **SUCCEEDS** |
| 9 | hypothesis `h : At M p A.allFuture` | `simp only [at_def, TruthEnv.T, PlusTruth.allFuture_iff] at h` | **SUCCEEDS** |
| 10 | `At M p A.allFuture`, `p : Point Formula F` | `simp only [at_def, TruthEnv.T, Truth.future_iff]` | **SUCCEEDS** |
| 11 | `At M p A.allFuture`, `p : Point StarFormula F` | `simp only [at_def, TruthEnv.T, StarTruth.allFuture_iff]` | **SUCCEEDS** |
| 12 | `At M p (TruthClauses.allFuture A)` | `simp only [at_def, TruthClauses.allFuture_iff]` | SUCCEEDS, with `at_def` reported **unused** |

Three things follow, and all three belong in the response.

1. **`at_def` is load-bearing, not cosmetic.** Row 6 is the control: with `at_def` omitted and everything else held fixed, `simp` makes no progress at all. Row 3 shows `rw [at_def]` genuinely rewrites `At` away.
2. **`rw` still does not reach a clause lemma under `At`.** Rows 4 and 5 are the measured form of the original complaint's residue: getting to `TruthEnv.T` is necessary but not sufficient, because the per-language clause lemma is stated about `PlusTruthAt`/`TruthAt`, and the instance projection has to be reduced before it matches. The working idiom is a three-lemma `simp only`, and the docstring says so.
3. **The idiom is uniform across the languages and across goal/hypothesis position.** Rows 8-11 cover L, L⁺ and L⋆ — including L⋆'s non-`PUnit` environment — and row 9 covers `... at h`. Row 12 shows `at_def` is needed only on the language-specific route; on a generic clause former `simp` already sees through the reducible `At`.

The attribute is well-formed: the full `check-module-invariants.sh` C16 `env_linter` batch (which includes `simpNF`) passes, and `lake lint` passes, at this head.

### Condition 3 — tests for the untested lemmas, one at L⋆

Met. Every name in the posted comment now has a test row.

| Lemma named as untested | Test row | Language |
|---|---|---|
| `next_iff` | `TemporalRulesTest.lean:31-33` | **L⋆**, with `regs : ℕ → F.Duration` |
| `prev_iff` | `TemporalRulesTest.lean:35-37` | L |
| `someFuture_bind_keeping` | `TemporalRulesTest.lean:39-47` | L |
| `somePast_bind_keeping` | `TemporalRulesTest.lean:49-58` | L⁺ |
| `inclusiveSince_iff` | `TemporalRulesTest.lean:71-74` | L |
| `release_iff` | `TemporalRulesTest.lean:76-79` | L |
| `trigger_iff` | `TemporalRulesTest.lean:81-84` | L |
| `weakUntil_iff` | `TemporalRulesTest.lean:86-88` | L |
| `rank_progress` | `TemporalRulesTest.lean:90-92` | ℕ |
| `rank_progress_truth` | `TemporalRulesTest.lean:94-100` | L⁺ |
| `rank_progress_truth_strict` | `TemporalRulesTest.lean:102-109` | **L⋆**, with `regs : ℕ → F.Duration` |

Transport factories: 7 of 13 are now exercised — `iffTransport_box` (pre-existing), plus `iffTransport_truthCorr`, `iffTransport_timeShift`, `iffTransport_rev`, `plus_iffTransport_stab`, `plus_iffTransport_stateLocal` and `plus_iffTransport_histMorphism`. That is one per family in the grouping the comment asked for. The point relations never exercised are `IsoRel`, `AntiIsoRel` and the `Eq` relation of `plus_iffTransport_stateLocalStab`; the formula-reflecting shape those first two share with `iffTransport_truthAntiIso` is covered by the `iffTransport_rev` row, which also carries `φ.reflectTime`.

L⋆: two rows, not one. Both pass `regs` explicitly, which is exactly the "environment threaded wrongly" case the comment named.

Three observations, none of them a condition and all small enough to go in a sentence or be dropped:

- The `someFuture_bind` and `somePast_bind` rows were **rewritten** into their `_keeping` forms rather than added beside them, so `someFuture_bind`, `somePast_bind`, `allFuture_persist` and `allPast_persist` no longer have direct rows. They stay exercised transitively, since the `_keeping` lemmas are proved from them.
- The `rank_progress` row is degenerate: it takes `I = Q = (· = 2)`, so the step premise is discharged by `(hn h).elim` and the result is taken by the `Or.inl` branch. The well-founded descent is never exercised by that row — it is exercised by the pre-existing `rank_progress_strict` row just below it.
- The `release_iff`, `trigger_iff` and `weakUntil_iff` rows state their goals with `Formula.release`, `Formula.trigger` and `Formula.weakUntil`. Those rows therefore compile the definitional agreement between the generic inline formula and the existing `Syntax/Formula.lean` operator — part of what the follow-up list wanted recorded, landed early and at no cost.
- `Tests/BimodalTest/Semantics/README.md`'s row for `TemporalRulesTest.lean` still reads "Covers, past and future persistence, witness endpoints, and well-founded progress", which no longer describes the interval and L⋆ rows.

### Gate evidence at `b2eb3ac0b`

All measured in `/home/benjamin/Projects/.worktrees/BimodalLogic-pr11-rereview`, a fresh worktree whose `.lake/build` was built from scratch (`.lake/packages` is a symlink to the main repository's, so Mathlib is shared, not rebuilt).

| Gate | Result |
|---|---|
| `lake build --wfail` | green, `Build completed successfully (3010 jobs)`, zero `warning:`/`error:` lines |
| `lake test` | green, `3086 jobs`, zero `warning:`/`error:` lines |
| `lake lint` | `-- Linting passed for FormalSystem.` |
| `bash scripts/check-module-invariants.sh` (full, not `--no-build`) | `ALL CHECKS PASSED`, 57 `PASS` lines, zero `FAIL`/`WARN`; C3 structural sorry inventory ZERO; C16 `env_linter` batch clean; C33 generated root byte-for-byte |
| `#print axioms` over all 69 declarations of the four PR modules | every one inside `[propext, Classical.choice, Quot.sound]`; `at_def` is `[propext]` alone |

The 69 declarations are 53 theorems (the review's 52, plus `at_def`), 13 defs, 2 abbrevs and the `Point` structure. The enumeration was derived with `grep -oP '^(?:@\[simp\]\s*)?(?:theorem|def|abbrev|structure)\s+\K[A-Za-z_][A-Za-z0-9_.\x27]*'` over the four module files, and cross-checked against the `#print axioms` output, which reported a verdict line for all 69 and no `unknown identifier` error — a differently-shaped check, since it resolves each name against the compiled environment rather than against the source text.

### Recommendations

- **Approve PR #11 at `b2eb3ac0b`.** All three posted conditions are met; the gates are green at the head; the axiom profile is unchanged. [VERIFIED: PASS -- `lake build --wfail` (3010 jobs), `lake test` (3086 jobs), `lake lint`, full `check-module-invariants.sh` (ALL CHECKS PASSED) and a 69-declaration `#print axioms` sweep, all run in a from-scratch worktree at `b2eb3ac0b`]
- **Say in the approval what `At` usability now means**, rather than only that the condition is met: the working idiom is `simp only [at_def, TruthEnv.T, <language clause lemma>]`, it works on goals and hypotheses and at L, L⁺ and L⋆, and `rw` to a clause lemma under `At` still does not work. [VERIFIED: PASS -- twelve single-example probes compiled with `lake env lean`; rows 1-12 of the Condition 2 table, including the `at_def`-omitted control that fails with "`simp` made no progress"]
- **Do not reopen the four lemmas whose tests were rewritten.** `someFuture_bind`, `somePast_bind`, `allFuture_persist` and `allPast_persist` lost their direct rows but are consumed by the `_keeping` lemmas that replaced them. [VERIFIED: PASS -- read at `FormalSystem/Semantics/TemporalRules.lean`; `someFuture_bind_keeping` is `someFuture_bind hA fun s hts hs => body s hts (fun P hP => allFuture_persist (hkeep P hP) hts) hs`, and dually for the past form]
- **Mention the degenerate `rank_progress` row at most in passing, as a note and not a condition.** Its `I = Q` instantiation discharges the step premise vacuously, so that row names the lemma without exercising its descent. [VERIFIED: PASS -- `TemporalRulesTest.lean:90-92`, step argument `(fun _ h hn => (hn h).elim)`; the descent is exercised by the `rank_progress_strict` row at lines 112-121]
- **Keep the whole "after the merge" list intact and unchanged.** Nothing in this push touches `TemporalIntervals`'s named-operator question, the `next_iff_covBy`/`prev_iff_covBy` promotion, the Release positive-reading note, the module docstring titles, or the L⁻/L⋆ persistence and factory gaps. [No compiled gate applicable]
- **Optionally note the stale `Tests/BimodalTest/Semantics/README.md` row** for `TemporalRulesTest.lean`, which no longer describes the file. This is a one-line follow-up at most, not a merge condition. [No compiled gate applicable]
- **Record in the response that the three factories' relation shapes `IsoRel`, `AntiIsoRel` and the `Eq` of `plus_iffTransport_stateLocalStab` remain unexercised**, since the comment's bar was one per family rather than all thirteen, and say so as an acknowledgement rather than an ask. [VERIFIED: PASS -- enumerated the 13 `iffTransport`/`plus_iffTransport` factories in `PointTransport.lean` and the 7 exercised in `PointTransportTest.lean`; cross-checked by relation argument rather than by lemma name]

## Decisions

- **The verdict is approve, not a second round.** Each condition was taken literally as posted, and each is met. Where the substance is narrower than the words — `rw` under `At` still fails — the response states the measured shape instead of either glossing over it or reopening the condition.
- **Evidence tier: a from-scratch worktree build, not a seeded one.** Two false-green mechanisms were hit and discarded before any figure above was accepted; see Risks below. Every gate figure in this report comes from a build whose traces all point inside the review worktree, verified by a direct audit (`grep -rl 'worktrees/BimodalLogic-pr11/' .lake/build/lib/lean --include='*.trace'` -> 0).
- **The `status.typ` stamp naming `c6cd983` is not a finding.** The generator stamps the HEAD it runs at; every count reproduces exactly at the merge head, so the file is regenerated output and not a hand-resolved conflict.
- **The four lemmas that lost direct test rows are not reported as a regression.** The `_keeping` lemmas consume them in their proof terms, so the coverage is transitive and real.
- **The draft response file and the `FOLLOWUP.md` entry are left to the implementation phase.** This dispatch fixes the verdict and the evidence; it writes no file under `specs/reviews/`.

## Risks & Mitigations

- **Risk: a seeded `.lake` reports a false green.** Copying another worktree's `.lake/build` produced a `3006/3006` green run in which `PointTransport.olean` was never rebuilt — Lake's per-module `.trace` records the *absolute* source path of the worktree it was built in and re-hashes that path, so a module whose source differs between the two worktrees is judged up to date. Detected by a `#check at_def` probe reporting an unknown identifier after that green run. **Mitigated** by deleting `.lake/build` and rebuilding from scratch, then auditing every trace for out-of-worktree paths.
- **Risk: `lake-build-guard.sh --dir` does not chdir.** The flag resolves the project root for locking and result-record paths only; the wrapped `lake` runs in the caller's cwd. Invoking the guard from the main repository with `--dir <worktree>` therefore builds the *main repository* and writes a green result into the worktree's guard files. **Mitigated** by `cd`-ing into the worktree before every guard call. A secondary effect — the guard then REPLAYed that main-repository result for a subsequent worktree call, since the fingerprint matched — was cleared by removing the stale `.lake/build-guard.result` before re-running. Both are recorded in `issues.jsonl`.
- **Risk: the head moves between measurement and the user posting.** `b2eb3ac0b` was confirmed at the start and again at the end of this dispatch, and the draft response should be re-checked against `gh pr view 11 --json headRefOid` immediately before posting, exactly as `FOLLOWUP.md` already requires for the other three.
- **Risk: the approval reads as endorsing more than was measured.** The gates certify compilation, linting, the invariants suite and the axiom profile. They do not certify that any statement is the intended one; the earlier review's reading of the statements ("I could not find a wrong statement") is carried forward unchanged and was not re-derived here. [CARRIED-UNVERIFIED: `specs/reviews/pr-reviews-2026-11-21/pr11-review.md`, opening paragraph]

## Tactic Survey Results

The survey here was diagnostic rather than proof-search: the question was which tactic reaches a clause lemma through `At`, not which tactic closes a goal. Each row is a separate single-example file compiled with `lake env lean` in the worktree at `b2eb3ac0b`.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `At M p A.allFuture`, L⁺ | `rw` | fail | `PlusTruth.allFuture_iff` — pattern not found under `At` |
| `At M p A.allFuture`, L⁺ | `rw` | fail | `TruthClauses.allFuture_iff` — pattern not found under `At` |
| `At M p A.allFuture`, L⁺ | `rw` | success | `at_def` alone; leaves `TruthEnv.T M p.history p.time p.env A.allFuture` |
| `TruthEnv.T … A.allFuture`, L⁺ | `rw` | fail | `PlusTruth.allFuture_iff` — instance projection not reduced |
| `At M p A.allFuture`, L⁺ | `simp only` | fail | `[TruthEnv.T, PlusTruth.allFuture_iff]` — "made no progress" (the `at_def`-omitted control) |
| `At M p A.allFuture`, L⁺ | `simp only` | partial | `[at_def, TruthClauses.allFuture_iff]` — generic lemma unused |
| `At M p A.allFuture`, L⁺ | `simp only` | success | `[at_def, TruthEnv.T, PlusTruth.allFuture_iff]` (the shipped idiom) |
| `h : At M p A.allFuture`, L⁺ | `simp only … at h` | success | same three lemmas |
| `At M p A.allFuture`, L | `simp only` | success | `[at_def, TruthEnv.T, Truth.future_iff]` |
| `At M p A.allFuture`, L⋆ | `simp only` | success | `[at_def, TruthEnv.T, StarTruth.allFuture_iff]`, env `ℕ → F.Duration` |
| `At M p (TruthClauses.allFuture A)` | `simp only` | success | `[TruthClauses.allFuture_iff]`; `at_def` reported unused |

`lean_hammer_premise`, `lean_state_search` and the Mathlib search tools were not used: nothing here was a search for an unknown lemma, and every candidate tactic was named by the posted review itself.

## Context Extension Recommendations

- **Topic**: seeding a Lean review worktree's `.lake/build` by copying another worktree's.
- **Gap**: `context/project/lean4/operations/long-builds.md` covers detaching and guarding a build, and `context/patterns/batch-orchestration-guardrails.md` covers working-tree and build isolation, but neither states that Lake's `.trace` files key on absolute source paths, so a copied `.lake/build` silently reports modules as up to date against the *source worktree's* files. The failure mode is a green build that never compiled the file under review.
- **Recommendation**: add a short subsection to `long-builds.md` — "A copied `.lake/build` is not a warm cache" — stating the trace-path mechanism, the symptom (a green run with an un-rebuilt `.olean`), the audit (`grep -rl '<other worktree path>' .lake/build/lib/lean --include='*.trace'` must return 0) and the remedy (wipe `.lake/build`; `.lake/packages` may be shared by symlink).

- **Topic**: `lake-build-guard.sh --dir` semantics.
- **Gap**: `rules/lean4.md`'s Build Commands section and `long-builds.md`'s canonical invocation both show the guard call without a `--dir`, and neither says what `--dir` does. The script's own usage text describes it as "Directory to resolve the Lean project from", which reads as "build this directory" and is not what it does: the wrapped `lake` runs in the caller's cwd.
- **Recommendation**: one line in `long-builds.md`'s canonical-invocation block — `--dir` resolves the lock and result-record paths only; `cd` into the project you mean to build. Worth pairing with the replay note, since a stale result record under the named `--dir` will be replayed on the next call.

## Appendix

**GitHub queries**

- `gh pr view 11 --json number,title,headRefOid,headRefName,isDraft,mergeable,mergeStateStatus,state,updatedAt,baseRefName,files`
- `gh api repos/benbrastmckie/BimodalLogic/pulls/11/reviews`
- `gh api repos/benbrastmckie/BimodalLogic/issues/11/comments`
- `gh api repos/benbrastmckie/BimodalLogic/pulls/11/comments`
- `gh run list --branch feat/pointed-semantic-lemmas --limit 5 --json databaseId,headSha,conclusion,status,createdAt,updatedAt,workflowName`

**Git**

- `git fetch origin pull/11/head:pr11-b2eb3ac --force`
- `git log --oneline c6cd983b7..b2eb3ac0b`
- `git diff --name-only origin/main b2eb3ac0b`
- `git diff --numstat c6cd983b7 b2eb3ac0b -- <path>`
- `git worktree add /home/benjamin/Projects/.worktrees/BimodalLogic-pr11-rereview b2eb3ac0b --detach`

**Gates (each run with cwd inside the review worktree)**

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build --wfail`
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- test`
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- lint`
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- exe mk_all --lib FormalSystem`
- `bash scripts/check-module-invariants.sh` and `… --emit-inventory`
- `bash scripts/typst-status-counts.sh`
- `lake env lean <probe>.lean` (twelve probes) and `lake env lean <69-line #print axioms file>.lean`

**Related records**

- `specs/reviews/pr-reviews-2026-11-21/pr11-comment.md` — the posted body; the three conditions and the after-the-merge list
- `specs/reviews/pr-reviews-2026-11-21/pr11-review.md` — the long backing review against `c6cd983b7`
- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` — post list; item 1 is the posted `pr11-comment.md`, and its "re-check each head" instruction is the one this report discharges for #11
- `records/milestones.md` D1 — where the named interval operators and the one `next`/`prev` encoding belong, per the after-the-merge list
