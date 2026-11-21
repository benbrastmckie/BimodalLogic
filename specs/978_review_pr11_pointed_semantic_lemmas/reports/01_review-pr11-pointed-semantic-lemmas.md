# Research Report: Task #978

**Task**: 978 - Review collaborator PR #11 (feat/pointed-semantic-lemmas) and prepare a merge recommendation and draft review
**Started**: 2026-11-21T22:05:13Z
**Completed**: 2026-11-21T23:21:00Z
**Effort**: ~75 minutes
**Dependencies**: None
**Sources/Inputs**:
- PR #11 head `c6cd983b79842368ae789488d38e488656f98992`, reviewed in a detached worktree at `/home/benjamin/Projects/.worktrees/BimodalLogic-pr11` fetched via `git fetch origin refs/pull/11/head`
- `records/milestones.md`, `records/proof-mode.md`, `records/proof-mode-architecture.md`, `records/theorem-library.md`, `records/README.md`
- `CONTRIBUTING.md`, `ORGANISATION.md`, `docs/theorem-index.md`, `.github/workflows/ci.yml`
- `specs/reviews/pr-reviews-2026-11-20/` (register for the draft)
- Compiled probes under `specs/978_review_pr11_pointed_semantic_lemmas/scratch/` (4 files, all run with `lake env lean` at the PR head)
- `gh pr view` / `gh pr checks` for #7–#11

**Artifacts**:
- `specs/978_review_pr11_pointed_semantic_lemmas/reports/01_review-pr11-pointed-semantic-lemmas.md` (this report)
- `specs/reviews/pr-reviews-2026-11-21/pr11-review.md` (the draft the user posts)
- `specs/978_review_pr11_pointed_semantic_lemmas/scratch/AxiomProfile.lean`
- `specs/978_review_pr11_pointed_semantic_lemmas/scratch/LemmasOnlyControl.lean`
- `specs/978_review_pr11_pointed_semantic_lemmas/scratch/AtUsability.lean`
- `specs/978_review_pr11_pointed_semantic_lemmas/scratch/AtRemedies.lean`
- `specs/978_review_pr11_pointed_semantic_lemmas/scratch/CoincidenceAndReach.lean`

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- PR #11 is milestone C1 of `records/milestones.md` and item 2 of its own "What to do next" list. It is faithful to the list the user gave on #9: every requested family is present, placement matches `records/proof-mode-architecture.md` exactly, and no statement is wrong.
- Verification is strong and all of it was run, not assumed: `--wfail` build clean, the **full** `check-module-invariants.sh` (58 checks, stronger than CI's `--no-build` pass) reports ALL CHECKS PASSED including the `runLinter` batch, all 52 new theorems have axiom sets inside `[propext, Classical.choice, Quot.sound]`, zero `sorry`, and the upward-edge count is 10 at both main and the PR head.
- One measured design defect decides whether a third of the PR earns its place: `At` is an `abbrev`, so **no** clause lemma fires by `rw` through it — not the per-language one, not the generic one, and neither `simp only [At]` nor `unfold At` helps. The only working idiom is a `show` that writes out what `At` was meant to hide, and the PR's own two `PointTransport` tests never exercise a clause lemma.
- Tests are the other real gap: 9 of 22 temporal/rank declarations and 1 of 13 transport factories are named in a test, and the "once per clause class" claim is instantiated at L and L⁺ only, never at L⋆/L^▷/L^∀.
- `TemporalIntervals` names six operators it does not define, four of which already exist as `Formula.release`/`trigger`/`weakUntil`/`weakSince`. The generic lemmas **do** reach them (compiled), so this is discoverability, not correctness.
- Recommended disposition: **REQUEST CHANGES** on a four-item list that is a day's work, not a redesign. All four items are additive; nothing in the PR needs removing or restating.

## Items Needing the User's Ruling

### 1. Does `At` stay, and in what form?

**The measurement.** `At M p A` is `abbrev At (M : TaskModel F) (p : Point L F) (A : L) : Prop := TruthEnv.T M p.history p.time p.env A` (`FormalSystem/Semantics/PointTransport.lean:45`). Compiled probes (`scratch/AtUsability.lean`, `scratch/AtRemedies.lean`):

| Idiom, on goal `At M p (allFuture A)`, `p : Point PlusFormula F` | Result |
|---|---|
| `rw [PlusTruth.allFuture_iff]` | FAILS — pattern `PlusTruthAt ?M ?τ ?t (allFuture ?φ)` not found in `At M p A.allFuture` |
| `rw [TruthClauses.allFuture_iff]` | FAILS — two obstructions: `At` does not unfold, and `PlusFormula.allFuture` is not syntactically `TruthClauses.allFuture` |
| `simp only [At]` then `rw [allFuture_iff]` | FAILS — unfolds to `TruthEnv.T`, the per-language lemma then does not match |
| `unfold At` then `rw [allFuture_iff]` | FAILS, same reason |
| `show PlusTruthAt M p.history p.time (allFuture A)` then `rw` | WORKS |
| `exact (h : PlusTruthAt M p.history p.time (allFuture A))` | WORKS (reducible defeq at elaboration) |

So term-mode use is free and tactic-mode clause work is strictly worse than not using `Point`/`At` at all. This is consistent with what PR #9 did: its `ProofModeRules.lean` built a whole `Step`/demand kernel around `At`, which is what made it usable; stripped of the kernel, `At` carries a cost with no compensating mechanism.

**Options.**
- (a) Keep `At` and make it usable: add a `@[simp] theorem at_def` or `At`-level restatements of the clause lemmas, plus one test that rewrites under `At`. Cost: small; benefit: the vehicle the later mode will want.
- (b) Keep `At` as a statement-only vehicle and say so in the docstring. Cost: zero; the module then documents a sharp edge instead of removing it.
- (c) Drop `Point`/`At` and state the factories as plain `Iff` theorems over `(M, τ, t, e)`. Cost: the relations (`Shifted`, `Reflected`, `CorrRel`, …) lose their natural home; benefit: nothing in the tree then depends on a vehicle whose ergonomics are unsettled.

**Recommendation: (a), falling back to (b).** The structures do earn their place on the composition side — `FactTransport.trans`/`GoalTransport.trans` chain certificates through an intermediate judgment, which a bare `Iff` cannot express without naming the intermediate point by hand, and `IffTransport.symm` is one line because `Point` is a structure. Option (c) throws that away to fix an ergonomic problem that (a) fixes directly.

### 2. Do the interval lemmas get named operators, and whose?

`inclusiveUntil_iff`, `release_iff`, `trigger_iff`, `weakUntil_iff`, `weakSince_iff` name five operators that exist nowhere as definitions; `inclusiveSince_iff` a sixth. Four of the six already exist per-language: `Formula.release`, `Formula.trigger`, `Formula.weakUntil`, `Formula.weakSince` (`FormalSystem/Syntax/Formula.lean:530,580,572,589`), with `strongRelease`/`strongTrigger` beside them and syntactic unfolding lemmas in `Automation/Normalization.lean:148–158`.

**Options.**
- (a) Define generic `abbrev`s beside `TruthClauses.someFuture`/`allFuture`/`after`, state the `_iff` lemmas about them, and add `ValidityLayerTest` coincidence rows against the `Formula.*` operators.
- (b) Leave the lemmas stated on inline derived formulas and add a `## Main Results` note naming the per-language operators each instantiates to.
- (c) State the lemmas directly about `Formula.weakUntil` etc. — rejected on sight: that is one proof per language, which is the thing the clause-class design exists to avoid.

**Recommendation: (a).** The views tier (`proof_mode_views_tier`) will need the named operators anyway, and the `_iff` lemma names already promise them. Verified cheap: `release_iff (L := Formula) M τ t PUnit.unit event guard` typechecks against the truth condition of `Formula.release event guard`, and `weakUntil_iff` likewise against `Formula.weakUntil` (`scratch/CoincidenceAndReach.lean`, sections C and D), so the argument order already agrees and no proof work is involved.

### 3. Who performs the `next_iff_covBy` consolidation, and when?

`SourceLanguage/SentenceTruth.lean:156,166` holds `next_iff_covBy`/`prev_iff_covBy`, the base-language instance of the PR's `next_iff`/`prev_iff`. That module's own docstring (lines 56–62) calls the duplication "deliberate and unresolved" and names promotion into `FormalSystem/Semantics/Truth.lean` as "the eventual fix", blocked because the other copy of the `succ`-form fact is in `Metalogic/DiscreteNonCompactness.lean` and the import would be upward. Both `SentenceTruth` and the PR's modules are layer 1 (`scripts/measure-refactor-partitions.py:224` and the `Semantics/` row of `ORGANISATION.md`), so the promotion is now available at no layering cost. Verified: `next_iff (L := Formula) M τ t PUnit.unit φ` directly inhabits `next_iff_covBy`'s statement.

**Options.** (a) Ask the contributor to do it in this PR; (b) ask in a follow-up PR of theirs; (c) the user takes it.

**Recommendation: (c).** It touches `SourceLanguage/` and `Metalogic/`, neither of which is channel T's territory per `records/milestones.md`'s channel table (line 154), and it would widen a PR that is otherwise cleanly scoped.

### 4. MERGE now with follow-ups, or REQUEST CHANGES?

**Recommendation: REQUEST CHANGES**, on items 1–4 of the draft (the `At` ruling, tests, the named operators, the coincidence rows). Reasoning: `CONTRIBUTING.md` makes tests a stated requirement and 13 of 35 touched declarations have none; and the `At` question is better settled before anything in the tree depends on the vehicle. The counter-case is real — the user told the contributor on #9's follow-up "I will review and merge them on their merits", the merge value is high (milestone C1, priority 2 of 6, unblocks the countermodel half of the library), and nothing here is wrong. If the user prefers momentum, MERGE-plus-follow-up is defensible; the draft is written so that items 1–4 can be demoted to follow-ups by moving one heading.

## Recommendation for the Pull Request

**REQUEST CHANGES** — a four-item list, all additive, no redesign.

The draft is at `specs/reviews/pr-reviews-2026-11-21/pr11-review.md`, in the register of `specs/reviews/pr-reviews-2026-11-20/`: credit first and specific, numbered requests, conditions of merging separated from follow-ups, and every claim backed by something run in this task.

## Context & Scope

Reviewed PR #11 (`feat/pointed-semantic-lemmas`, head `c6cd983b7`, base `main`, +793/−12 across 14 files, author tannerduve) against: the list the user gave on #9 and its follow-up; `records/` (milestones, proof-mode, proof-mode-architecture, theorem-library); `CONTRIBUTING.md`; `ORGANISATION.md`; and the existing tree. Ground rules observed: nothing posted, merged, pushed or approved; all work in a separate worktree on the PR head; head re-checked with `gh pr view` at the end and unchanged.

**Worktree setup** (recorded because it is reusable): symlinked the main tree's `.lake/packages` (9.2G, manifest unchanged by the PR) into the worktree and real-copied only `.lake/build/lib` + `.lake/build/ir` (2.1G, 3.5s), excluding `.lake/build/bin` and the five `.lake/build-guard.*` runtime files the guard's header says must never be hardlink-shared. Lake then re-elaborated only the 7 changed modules (1920 jobs, rest cache hits). Cost of omitting `build/bin`: C25 relinked all 60 `lean_exe` roots.

## Findings

### 1. Build and trust

| Gate | Command | Result |
|---|---|---|
| Scoped build with `--wfail` | `lake build FormalSystem.Semantics BimodalTest.Semantics.TemporalRulesTest BimodalTest.Semantics.PointTransportTest --wfail`, via `lake-build-guard.sh` | exit 0, 1920/1920 jobs, "Build completed successfully" |
| Full invariants (with build) | `bash scripts/check-module-invariants.sh` | **ALL CHECKS PASSED**, 58 PASS / 0 FAIL |
| Linter | C16 `env_linter` batch (`defsWithUnderscore`, `docBlame`, `simpNF`, `structureInType`, `tacticDocs`, `unusedArguments`) | PASS, no un-nolisted finding |
| `sorry` | C3 | PASS, structural `sorry` inventory ZERO |
| Axiom pins | C2 (50 sets), C14, C21 | PASS |
| Generated inventories | INV | PASS, every generated block current |
| mk_all root | C33 (inside the full pass) | PASS |
| Copyright headers | `bash scripts/check-copyright-headers.sh --strict` | exit 0, 776 files, 0 missing, 0 duplicate |
| Metalogic cycles | `bash scripts/check-metalogic-cycles.sh` | exit 0 |
| Typst sync | `bash scripts/typst-sync-check.sh` | PASS (all 4 checks), `MISMATCH_COUNT=0` |
| Upward edges | `python3 scripts/measure-refactor-partitions.py upward-edges` | 10 at main, 10 at PR head — unchanged |
| CI | `gh pr checks 11` | "Build and Test" pass, 25m50s |

Two scripts fail, **identically at `main` (b626e2a16) and at the PR head**, so neither is a regression: `scripts/readme-lint.sh` (`RESULT: FAIL (1 new stale dates)` — the diff between the two runs is only the "directory last changed" dates; `FormalSystem/README.md` and `FormalSystem/Semantics/README.md` were already on the stale list before the PR) and `scripts/check-paper-definitions.sh` (`FAIL: drift detected against docs/reference/paper-definitions-of-record.md`). Not verified: why CI's own steps for these two are green while a local run is not.

**Axiom set of every new theorem** (`scratch/AxiomProfile.lean`, 52 `#print axioms`, run at the PR head): every one is a subset of `[propext, Classical.choice, Quot.sound]` — this repository's `pcq`. No `sorryAx`, no new `axiom`, no `Lean.ofReduceBool`/`native_decide`. Distribution: 22 theorems at `[propext]` alone, 5 at `[propext, Quot.sound]`, 25 at full `pcq`. One asymmetry worth nothing more than a note: `next_at` reaches `Classical.choice` while `prev_at` does not (`CovBy.unique_right` versus `CovBy.unique_left`).

### 2. Statements against the requested list

Every item on the #9 list is present:

| Requested | Delivered | File |
|---|---|---|
| covering-time Next/Previous | `next`, `prev`, `next_iff`, `prev_iff`, `next_at`, `prev_at` | `TemporalRules.lean` |
| G/H persistence | `allFuture_persist`, `allPast_persist` | `TemporalRules.lean` |
| F/P bind | `someFuture_bind`, `somePast_bind` (+ `_keeping` variants) | `TemporalRules.lean` |
| inclusive and weak Until/Since | `inclusiveUntil_iff`, `inclusiveSince_iff`, `weakUntil_iff`, `weakSince_iff` | `TemporalIntervals.lean` |
| `rank_progress` | `rank_progress` (+ `_strict`, `_truth`, `_truth_strict`) | `RankProgress.lean` |
| the transport structures | `Point`, `At`, `FactTransport`, `GoalTransport`, `IffTransport`, 9 point relations, 13 factories | `PointTransport.lean` |

**Nothing asked for is absent.** Present and not asked for: `release_iff`, `trigger_iff` (the two strict duals), the two `_keeping` bind variants, and the three `rank_progress` specializations. The `_keeping` and `rank_progress` additions are natural; `release_iff`/`trigger_iff` are the two weakest declarations in the PR — each is `simp only [neg_iff, untl_clause]` and the right-hand side is the negated `untl` clause transcribed, with no de Morgan and no positive reading, so they are restatements of the clause rather than characterizations of Release.

Declaration counts: TemporalRules 12, TemporalIntervals 6, RankProgress 4, PointTransport 46 — 68 total, 52 of them theorems.

**Strictness and endpoint conventions, checked against `Formula.untl`'s guard-first convention** (`TruthClauses.after`'s docstring: "Guard-first, so the event is pinned to the first strictly future `φ`-time"):
- `next φ := UntlClause.untl BotClause.bot φ` — guard first, `⊥` guard ⇒ the open interval is empty ⇒ covering. `next_iff`'s RHS `∃ s, t ⋖ s ∧ T s φ` is correct and assumes no successor or discreteness; the docstring says so.
- `inclusiveUntil_iff` half-open `[t, s)` with `t ≤ s`; `inclusiveSince_iff` half-open `(s, t]` with `s ≤ t`. Both correct and mirrored.
- `release_iff`/`trigger_iff`/`weakUntil_iff`/`weakSince_iff` take `(event guard)`, **event first**, as the docstrings say. Verified consistent with the tree: `Formula.release φ ψ = (Formula.untl ψ.neg φ.neg).neg` and `Formula.weakUntil φ ψ = (Formula.untl ψ φ).or ψ.allFuture` both put the event first. `Formula.release`'s own docstring (`Formula.lean:547`) records an "**Argument-order trap**": the paper's `Release` takes the arguments swapped. The PR adopts the Lean-side order silently and cites neither the paper's order nor the existing note.
- `rank_progress` is over `[Preorder D]` with the occurrence premise in `step` (`∃ u, s < u ∧ …`); the induction is `hwf.induction` on the rank. Correct.

**Language reach, measured from the clause instances.** `UntlClauses`/`StabClauses` instances exist for `Formula`, `PlusFormula`, `StarFormula`, `OpenFormula`, `HybridFormula`, `QuantFormula` — six languages get the temporal and interval lemmas for free. `MinusFormula` has only `TenseClauses` (primitive `allFuture`/`allPast`, no `untl`), so **L⁻ is not covered**, including by `allFuture_persist`, even though `TruthClauses` keeps the parallel `someFuture_iff_of_allFuture`/`somePast_iff_of_allPast` pair for exactly that case. Three languages have a non-trivial `TruthEnv.Env` (L⋆ `ℕ → F.Duration`, L^▷ `ℕ → F.WorldState`, L^∀ `Set (Set F.WorldState)`), which is what makes `Point`'s `env` field necessary rather than decorative.

### 3. Duplication

| New declaration | Verdict |
|---|---|
| `next_iff`, `prev_iff` | **Generic form that should replace per-language copies.** `SourceLanguage/SentenceTruth.lean:156,166` `next_iff_covBy`/`prev_iff_covBy` are the base-language instance; `next_iff (L := Formula) M τ t PUnit.unit φ` inhabits that statement (compiled). The `succ`-form corollaries elsewhere (`SentenceTruth.next_iff_succ`, `Metalogic/DiscreteNonCompactness.truthAt_next_iff`, `NomicTruth.next_iff_succ`, `Metalogic/AuxiliaryAtoms.plusTruthAt_next_iff_succ`, `SeparationZ/Syntax.usTruth_next_iff`) stay as corollaries. See ruling 3. |
| `next`, `prev` abbrevs | **Fourth copy of an encoding with three existing per-language definitions** (`Formula.next` at `Syntax/Formula.lean:496`, `PlusFormula.next` at `PlusLanguage/Formula.lean:176`, `StarFormula.next` at `StarLanguage/Formula.lean:194`; a fifth as `USForm.next`). All six coincidence rows are `rfl` (compiled) but none is recorded, and the home for generic derived operators is `TruthClauses.lean` (which owns `someFuture`, `allFuture`, `somePast`, `allPast`, `kPlus`, `kMinus`, `always`, `after`, `diamond`, `neg`, `top`, `and`, `or`), not a new namespace. |
| `allFuture_persist`, `allPast_persist` | **New at the truth level.** No existing semantic persistence lemma found. The validity-level statement `Metalogic/Soundness.temp_4_valid` (`Gφ → GGφ`) and the derivation-level `ProofMode/PlusTemporal.futureAnd` are different layers, not duplicates. |
| `someFuture_bind`, `somePast_bind`, `_keeping` | **Semantic mirrors of existing derivation-tier combinators**, not duplicates: `ProofMode/Temporal.lean` and `ProofMode/PlusTemporal.lean:55–120` already hold `futureBind`, `pastBind`, `futureAnd`, `pastAnd`, `progressTrans`. Note the names will not line up across the two tiers (`futureBind` vs `someFuture_bind`). |
| the four interval clauses | **New at the truth level**, but about operators that already exist syntactically (`Formula.weakUntil` etc.) with only syntactic unfolds in `Automation/Normalization.lean`. See ruling 2. |
| `rank_progress` family | **New.** No comparable well-founded progress lemma in the tree. |
| the 13 transport factories | **Wrappers, deliberately and with citation**, over `Truth.truthAt_of_truthCorr`/`truthIso`/`truthAntiIso`, `TimeShift.shiftCorr`, `truthAt_rev`, `Truth.box_const`, `plusTruthAt_timeShift`, `plusTruthAt_rev`, `box_global`, `stab_state_only`, `isPlusStateLocal_of_stateLocal`, `plusStateLocal_stab_iff`, `HistMorphism.plus_invariance`. Each docstring names its source. No duplication; the question is whether the wrapper layer earns its place (ruling 1). |
| `Point` | **Does not duplicate** `Metalogic/SetConsequence.PointedModel`, which bundles frame + class membership + model + hist + time + the satisfaction proof at layer 3. Field-name divergence only (`history` vs `hist`). |
| `StateLocalTransfer.lean` | No overlap — that module is about `StateLocal` agreeing along the `ofPlus` embedding. |

### 4. Design: do `FactTransport`/`GoalTransport`/`IffTransport` earn their place?

They are bare `∀`-quantified propositions (`∀ p q, R p q → At M p A → At M' q B`). Against stating the factories as plain `Iff` theorems:

**For keeping them.** `FactTransport.trans`/`GoalTransport.trans` compose two certificates through an intermediate judgment, producing `fun p r => ∃ q, R p q ∧ R' q r` — a bare `Iff` cannot express that without the caller naming the intermediate point, and `PointTransportTest.lean`'s second example is exactly that composition. `IffTransport.symm` is one line because the relation is a parameter. The directional split (fact forward, goal backward) is the asymmetry the record's semantic tier will need and is cheap to state once.

**Against.** The 13 factories are each a one-line `rintro` + `subst` + `exact` over an existing theorem, so as a *bundle* they buy nothing on their own; their value is entirely in composing, and nothing in the PR composes a factory with a factory (the one composition test chains `iffTransport_box` with itself). The `At` obstruction in ruling 1 means the vehicle currently costs more than it saves at clause level. And `records/proof-mode-architecture.md`'s own position (echoed in `specs/reviews/pr-reviews-2026-11-20/pr7-followup.md`) is that the semantic mode's real automation is *evaluation* — "recursion on the formula against the model's data" — not a transport calculus.

**Verdict.** They earn their place on composition, conditional on ruling 1 being resolved. `release_iff`/`trigger_iff` are the declarations I would actually drop, not these.

### 5. Placement and naming

- **Layer.** `records/proof-mode-architecture.md:79` — "the semantic lemmas are general semantics and sit in `FormalSystem/Semantics/`, at layer 1". The PR does exactly that. Line 97 — "the semantic lemmas need neither [the record nor a measured client] and come first" — confirms nothing here waits on `records/semantic-proof-mode.md`.
- **Upward imports.** `PointTransport.lean` imports `PlusLanguage.PlusTruth`/`PlusReversal`/`PlusStateLocal`, all layer-1 rows in `measure-refactor-partitions.py:200–201`, so intra-layer, with three existing precedents in the same directory (`DeterministicBridge`, `HistoryMorphism`, `StateLocalTransfer`). Upward-edge total 10 before and after. No violation.
- **Aggregators.** `FormalSystem.lean` insertions are alphabetical (mk_all-generated; C33 PASS). `FormalSystem/Semantics.lean` is hand-curated in dependency order and the five insertions sit correctly (the three generic modules after `TruthClauses`, `PointTransport` after `Reversal`).
- **README inventory rows.** Four rows added to `FormalSystem/Semantics/README.md`, two to `Tests/BimodalTest/Semantics/README.md`, and the two generated count blocks updated. INV PASS. Row prose is terser than most neighbours but within range (`ShiftSet.lean`'s row is comparable).
- **`typst/generated/status.typ`.** Counts regenerated and correct (`typst-sync-check.sh` Check 2: `MISMATCH_COUNT=0`). `stamp-commit = "06d1a46"` names the base commit while the counts are this tree's (776 vs 772 files); the script checks counts, not the stamp, so cosmetic.
- **Docstring house style.** Measured over `FormalSystem/Semantics/*.lean` (47 files): 44 open with a `# ` title, 28 carry `## Tags`, 23 carry `## Main Definitions`/`## Main Results`. `TemporalRules`, `TemporalIntervals` and `RankProgress` have no `# ` title; none of the four has Tags or Main Results. Every declaration does have a docstring (C16 `docBlame` PASS).
- **`assert_not_exists`.** Three spellings across four files, none matching the directory's 16-fold `FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`. All four names used exist (`FrameClass` at `ProofSystem/Axioms.lean:505`, `Axiom` at 172, `Derivable` at `Derivable.lean:69`, `PlusDerivationTree` at `PlusLanguage/Derivation.lean:72`), so none is a vacuous assertion, and the generic trio's `FrameClass` lock is strictly stronger than `Axiom` (same declaring file).
- **Naming.** TM factories are `iffTransport_*`, TM⁺ factories `plus_iffTransport_*`; the tree's convention for L⁺ analogues is a camel prefix (`plusTruthAt_*`), not `plus_`. C26 does not fire (it reads `def`/`abbrev` names only) and C23 is clean (no `lemma`).
- **Records and docs.** No `records/` or `docs/` file is touched. Milestone C1 of `records/milestones.md` and the "Where it stands" Semantic row will need updating on merge, but that is channel B's; the PR changes no design, so `CONTRIBUTING.md` §3 is satisfied in substance. The PR body cites #9 and #10 but not C1 by slug.
- **Plan labels.** Clean: no `§`, `(P4)`, `branch-N`, `plan`, task number, `TODO`, `FIX:` or `NOTE:` in any of the six new files — the #9 complaint is fixed here.
- **`docs/theorem-index.md`.** No rows needed; it is the per-theorem ledger for headline results pinned by C2/C14, and C15 PASSes unchanged.

### 6. Tests

`TemporalRulesTest.lean` (65 lines, 7 examples) and `PointTransportTest.lean` (28 lines, 2 examples).

**What they exercise.** `next_at` at L, `prev_at` at L⁺, `someFuture_bind` + `allFuture_persist` at L, `somePast_bind` + `allPast_persist` at L⁺, `inclusiveUntil_iff` at L (degenerate case: current witness, `⊥` guard), `weakSince_iff` at L⁺ (right disjunct), `rank_progress_strict` on `ℕ` with `Nat.lt_wfRel.wf`; and `iffTransport_box` in both directions (`.goal.reduce`, `.fact.trans.apply`).

**What they omit.** By name, 11 of the 22 temporal/rank declarations: `next_iff`, `prev_iff`, `someFuture_bind_keeping`, `somePast_bind_keeping`, `inclusiveSince_iff`, `release_iff`, `trigger_iff`, `weakUntil_iff`, `rank_progress`, `rank_progress_truth`, `rank_progress_truth_strict`. The generic `next`/`prev` abbrevs are never named — the tests write `A.next` (`Formula.next`) and rely on the unasserted defeq. Of `PointTransport`'s 13 theorem factories, 12 are untested: every TM correspondence factory (`truthCorr`, `truthIso`, `truthAntiIso`, `timeShift`, `rev`) and all seven TM⁺ factories (`timeShift`, `rev`, `box`, `stab`, `stateLocal`, `stateLocalStab`, `histMorphism`). Of 9 point relations, none is introduced through its own `.intro`.

**Past variants.** Present for the four pairs that have tests at all (`prev_at`, `allPast_persist`, `somePast_bind`, `weakSince_iff`) — but by the past member only in two cases, so no pair is tested in both directions at the same language.

**TM⁺ and L⋆.** L⁺ is exercised in four examples. **L⋆ is not exercised at all**, nor L^▷ or L^∀, although all three carry the required clause instances and L⋆'s `Env F = ℕ → F.Duration` is the one case that would catch an environment threaded wrongly. This matters because "proved once for every language" is the PR's central claim; `ValidityLayerTest.lean`'s "toy fifth-language conformance check" is the existing pattern for asserting it.

### 7. Use: the lemmas-only control on `refute_allFuture_stab`

Ran the control `records/proof-mode-architecture.md` asks for (and `records/milestones.md` C3 names) against `FormalSystem.PlusLanguage.refute_allFuture_stab` (`G⊡p → ⊡Gp`, `PlusLanguage/PlusNonValidities.lean:100`). Scratch file `scratch/LemmasOnlyControl.lean`, compiled clean at the PR head; not committed to the library.

| Version | Tactic source lines | PR #11 declarations used |
|---|---|---|
| A. the proof in the tree, restated | 13 | none |
| B. statement routed through `Point`/`At` | 17 | `Point`, `At`, `SameStateNow`, `plus_iffTransport_stab`, `IffTransport.apply` |
| C. tightest version using a PR lemma | 13 | `plus_iffTransport_stab`, `IffTransport.apply`, `At`, `Point` |

**Result: no saving.** Exactly one of the 52 new theorems applies at all — `plus_iffTransport_stab`, which moves `⊡Gp` between two points agreeing in state — and it replaces nothing, because the refutation's content is *eliminating* `⊡` at an alternative history whose state differs, which is the opposite of what a truth-preserving certificate does. Version B is 4 lines longer for the reason in ruling 1. I also checked the module's other four refutations for applicability by inspection: `refute_stab_box`, `refute_stab_allFuture_past`, `refute_determined` and `refute_somePast_stab` have the same shape and the same answer.

This is not a mark against the PR — the user's own note on #7 already says satisfaction is "computation against a structure" with no proof-theoretic counterpart, and these lemmas are not an evaluator. It is useful data for C3: on this client, the lemmas-only control reports zero saving before the evaluator exists, so the comparison the record wants will be evaluator-versus-nothing, not evaluator-versus-lemmas.

### 8. Interaction with the other open pull requests

- #7, #8, #9 and #11 all touch `FormalSystem.lean`, `FormalSystem/README.md`, `README.md` and `typst/generated/status.typ`. They will conflict pairwise in any merge order; the fix is a rebase plus `lake exe mk_all --lib FormalSystem` and `check-module-invariants.sh --emit-inventory`, never a hand resolution of the counts.
- #11 is a faithful carve-out of #9's semantic layer under new names: #9 has `ProofModeTemporalRules.lean` (139), `ProofModeIntervals.lean` (240), `ProofModeTransport.lean` (324) and `ProofModeRules.lean` (752). The last contains `next`/`prev`/`next_iff`/`next_at`, `Point`/`At`, `allFuture_persist` **and** the `Step`/`Oriented`/demand kernel the user asked to set aside. On rebase, #9 must drop the three renamed modules and the lemma half of `ProofModeRules.lean` or the same results land twice.
- Nothing in #11 depends on #10 (`docs/semantic-proof-mode-record`), consistent with `records/milestones.md` line 33.

### Recommendations

- Post the draft at `specs/reviews/pr-reviews-2026-11-21/pr11-review.md` as a **REQUEST CHANGES** review on #11, on the four-item list. [No compiled gate applicable]
- Make `At` usable before anything depends on it: add a `@[simp] theorem at_def` or `At`-level clause restatements, plus a test that rewrites under `At`. [VERIFIED: FAIL — `rw [PlusTruth.allFuture_iff]`, `rw [TruthClauses.allFuture_iff]`, `simp only [At]` and `unfold At` all fail on an `At` goal via `lake env lean scratch/AtUsability.lean` and `scratch/AtRemedies.lean`; only `show PlusTruthAt …` and term-mode `exact` succeed. Revised to: the request above, stated as condition 1 of the draft rather than as a bare "keep `At`" endorsement.]
- Add six `ValidityLayerTest.lean` coincidence rows for `next`/`prev` at `Formula`, `PlusFormula`, `StarFormula`. [VERIFIED: PASS — all six `:= rfl` compile via `lake env lean scratch/CoincidenceAndReach.lean` section A.]
- Define the generic interval abbrevs and state the `_iff` lemmas about them, citing `Formula.release`'s argument-order trap. [VERIFIED: PASS — `release_iff (L := Formula) …` and `weakUntil_iff (L := Formula) …` already inhabit the truth conditions of `Formula.release event guard` and `Formula.weakUntil event guard`, so the argument order agrees and the change needs no proof work; `scratch/CoincidenceAndReach.lean` sections C and D.]
- Take the `next_iff_covBy` promotion as the user's own follow-up; it is intra-layer and now unblocked. [VERIFIED: PASS — `next_iff (L := Formula) M τ t PUnit.unit φ` inhabits `next_iff_covBy`'s statement (`scratch/CoincidenceAndReach.lean` section B); `SentenceTruth` and `Semantics/` are both layer 1, and the upward-edge count is 10 at main and at the PR head.]
- Ask for L⁻ persistence siblings under `AllFutureClause`/`AllPastClause` and L⋆ transport factories as follow-ups. [No compiled gate applicable]
- Do not ask for `records/` changes as a merge condition: the PR changes no design, and milestone C1's row is channel B's to close. [No compiled gate applicable]

## Decisions

- Reviewed the PR head in a detached worktree with the main tree's `.lake/packages` symlinked and only `build/lib` + `build/ir` real-copied, rather than a cold build or a build in the main tree — satisfies ground rule (ii) at ~4 minutes instead of hours, and the guard's own "never hardlink-share `.lake/build-guard.*`" convention is respected because those five files were not copied at all.
- Ran the **full** `check-module-invariants.sh` rather than CI's `--no-build` pass, so C1, C2, C6, C16, C24, C25 and C36b are locally measured rather than inherited from CI.
- Reported `readme-lint.sh` and `check-paper-definitions.sh` as baseline failures only after running both at `main` and diffing the output, rather than attributing them to the PR.
- Treated the `Point`/`At` question as a user ruling rather than a flat request, because the answer depends on whether the later semantic mode is expected to use the vehicle — which the unwritten `records/semantic-proof-mode.md` decides.
- Kept the scratch probes under the task directory and did not add them to the library, per the dispatch.

## Risks & Mitigations

- **The `At` finding could be read as fatal to `PointTransport`.** It is not: term mode works, and composition is the layer's real value. Mitigated by framing it as ruling 1 with three options and a recommendation, and by naming `release_iff`/`trigger_iff` as the declarations actually worth dropping.
- **Four PRs regenerating the same four files.** Any merge invalidates the other three's counts. Mitigated by the merge-mechanics paragraph in the draft, which asks for a regeneration rather than a hand resolution.
- **#9 landing the same lemmas twice under two names.** Mitigated by the closing paragraph of the draft; task 979 owns #9's disposition and should carry the same instruction.
- **The head could move before the user posts.** Re-checked with `gh pr view 11` at the end of this task: still `c6cd983b79842368ae789488d38e488656f98992`, `updatedAt` `2026-11-21T22:05:08Z`, `MERGEABLE`. The draft names the commit reviewed, so a later push is visible as a mismatch.
- **Not verified**: why `readme-lint.sh` and `check-paper-definitions.sh` are green in CI and red locally at both revisions; whether `lake exe lint-style`'s text linters pass locally (CI's step is green and was not re-run here); the behaviour of these lemmas at `OpenFormula`, `HybridFormula` and `QuantFormula` beyond the existence of their clause instances.

## Tactic Survey Results

Not applicable (no tactic survey performed — this was a review task, and the only proof work was the control probe in finding 7, where the tactic choices were fixed by the proof in the tree).

## Context Extension Recommendations

- **Topic**: Reviewing a collaborator PR at its head without a cold Lean build.
- **Gap**: `context/project/lean4/operations/long-builds.md` covers detaching and guarding a build in the working tree, but nothing records how to give a PR-head worktree a warm `.lake` safely. The two hazards are specific and both are easy to get wrong: hardlinking `build/` risks truncating the main tree's oleans in place, and the guard's own header forbids hardlink-sharing the five `.lake/build-guard.*` files.
- **Recommendation**: add `context/project/lean4/operations/review-worktree-setup.md` with the measured recipe used here (symlink `.lake/packages` when `lake-manifest.json` and `lean-toolchain` are unchanged; real-copy `build/lib` + `build/ir` only; copy `.lake/config` and `lakefile.olean`; never copy `build-guard.*`; expect C25 to relink the `lean_exe` roots if `build/bin` is omitted), and cross-reference it from `long-builds.md`.

- **Topic**: The lemmas-only control the proof-mode architecture record calls for.
- **Gap**: The control is specified in `records/proof-mode-architecture.md` and named in milestone C3, but there is no repeatable procedure for running it, so each run invents its own measure (here: tactic source lines, three variants).
- **Recommendation**: when `records/semantic-proof-mode.md` is drafted, fix the measure in it (what counts as a line, which declarations form the client set, and where the control proofs live) so that successive runs are comparable.

## Appendix

**Commands run (all at `/home/benjamin/Projects/.worktrees/BimodalLogic-pr11` unless noted)**

```
git fetch origin refs/pull/11/head:refs/remotes/pr/11
git worktree add /home/benjamin/Projects/.worktrees/BimodalLogic-pr11 refs/remotes/pr/11 --detach
ln -sfn <main>/.lake/packages .lake/packages ; cp -a <main>/.lake/build/{lib,ir} .lake/build/
bash <main>/.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build \
  FormalSystem.Semantics BimodalTest.Semantics.TemporalRulesTest \
  BimodalTest.Semantics.PointTransportTest --wfail          # exit 0, 1920 jobs
bash scripts/check-module-invariants.sh                      # ALL CHECKS PASSED, 58 PASS / 0 FAIL
bash scripts/check-copyright-headers.sh --strict             # exit 0
bash scripts/check-metalogic-cycles.sh                       # exit 0
bash scripts/typst-sync-check.sh                             # PASS (4/4)
bash scripts/readme-lint.sh                                  # FAIL (identical at main)
bash scripts/check-paper-definitions.sh                      # FAIL (identical at main)
python3 scripts/measure-refactor-partitions.py upward-edges   # 10 (also 10 at main)
lake env lean specs/978_.../scratch/AxiomProfile.lean         # 52 #print axioms, all ⊆ pcq
lake env lean specs/978_.../scratch/LemmasOnlyControl.lean    # clean; 13 / 17 / 13 lines
lake env lean specs/978_.../scratch/AtUsability.lean          # 3 expected failures
lake env lean specs/978_.../scratch/AtRemedies.lean           # 2 of 4 remedies fail
lake env lean specs/978_.../scratch/CoincidenceAndReach.lean  # clean (all 10 claims)
gh pr view 11 / gh pr checks 11 / gh pr view {7,8,9,10}
```

**Files read in full**: the four new library modules and two new test modules; `FormalSystem/Semantics/TruthClauses.lean` (clause classes, derived operators, the `After` tier); `FormalSystem/SourceLanguage/SentenceTruth.lean` (module docstring and the four `covBy`/`succ` lemmas); `FormalSystem/Syntax/Formula.lean` (the derived-operator block); `FormalSystem/Semantics/StateLocalTransfer.lean`; `FormalSystem/Theorems/ProofMode/PlusTemporal.lean`; `FormalSystem/PlusLanguage/PlusNonValidities.lean`; `Tests/BimodalTest/Semantics/ValidityLayerTest.lean` (coincidence tables); `records/README.md`, `records/milestones.md`, `records/proof-mode-architecture.md`; `CONTRIBUTING.md`; `ORGANISATION.md`; `docs/theorem-index.md` (header); `specs/reviews/pr-reviews-2026-11-20/pr9-review.md`, `pr9-followup.md`, `pr7-followup.md`.

**References**
- `records/proof-mode-architecture.md` — "Three tiers", the semantic-tier placement paragraph (line 79), the lemmas-come-first sentence (line 97), the capability table row at line 270
- `records/milestones.md` — milestone C1 (line 111), C3 (line 113), "What to do next" item 2 (line 48), the channel table (line 154)
- `CONTRIBUTING.md` §2 (no `sorry`/axiom, tests, style, placement, generated files) and §4 (the PR checklist)
- `ORGANISATION.md` — the five-layer table and the per-file language layering
- `scripts/check-module-invariants.sh` header — the C0–C37 check catalogue
