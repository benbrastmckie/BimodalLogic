# Implementation Plan: Backward-Chaining Lemma Database

- **Task**: 187 - Backward-chaining lemma database (solve_by_elim analogue)
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: Task 185 (complete axiom coverage) - satisfied/archived. Tasks 186, 188, 189, 192 are NOT prerequisites; boundary contracts noted in Non-Goals.
- **Research Inputs**: specs/187_backward_chaining_lemma_db/reports/02_backward-chaining-research.md (authoritative; supersedes reports/01_lemma-database-seed.md)
- **Artifacts**: plans/02_backward-chaining-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Replace the static 26-name lemma list in `tryDerivedMatch` (`Theories/Bimodal/Automation/Tactics/Helpers.lean:650-694`) with an attribute-driven database: a `@[tm_lemma]` label attribute declared in a NEW leaf module `Theories/Bimodal/Automation/LemmaDB.lean` (imports only `Lean`, so `Theorems/* -> Automation.LemmaDB` creates no import cycle), plus a `tryLemmaMatch` strategy that recurses into `DerivationTree` subgoals via `searchFn`, mirroring the existing `tryModusPonens` pattern (Helpers.lean:782). This adds the main new capability — backward chaining through inference-rule lemmas like `imp_trans` — while preserving all current behavior.

**Definition of done**: `@[tm_lemma]` registration live; `tryLemmaMatch` wired as `searchProof` strategy 1b; `tryDerivedMatch` and its static list deleted; head-symbol pre-filter and weakening fallback in place; tagging expanded beyond the original 26; `visitLimit` wired; `lake build` green at every phase boundary with zero sorries.

### Research Integration

Key findings honored from report 02:
- All needed mechanisms are in Lean core v4.27.0-rc1: `register_label_attr` + `Lean.labelled` (LabelAttribute.lean); DiscrTree rejected as overkill at <=100 lemmas; core `solve_by_elim` rejected because the search loop must interleave with `tryModalK`/`tryTemporalK` and frame-class discharge (report SS3.7).
- `tryLemmaMatch` signature mirrors `tryModusPonens` exactly: `(goal) (_ctx _formula) (searchFn : MVarId -> Nat -> TacticM Bool) (depth)`; `observing?` wrapping mandatory; `instantiateMVars` on subgoal types before `extractDerivationGoal`.
- Side goals from `apply` (frame-class `<=`, `Formula ∈ Γ` membership) discharged via `first | trivial | decide | simp` in that order (report SS1.3, risk 4).
- Weakening fallback recipe proven in `AesopRules.axiom_temp_4`: `DerivationTree.weakening [] Γ _ · (List.nil_subset Γ)` (report SS1.4, SS3.5).
- Noncomputable lemmas are a non-issue (existing static list already applies them).
- **Migration invariant**: every goal the old `tryDerivedMatch` closed must still close — all 26 static-list names become tags, and a regression test exercises all 26 statements via `modal_search`.

### Prior Plan Reference

No prior plan (plans/ directory empty; this is plan v1 for round 2 research).

### Roadmap Alignment

No roadmap context provided for this task.

## Goals & Non-Goals

**Goals**:
- Attribute-driven lemma registration (`@[tm_lemma]`) in a leaf module with no project imports.
- Recursive backward chaining through lemma premises (inference rules, necessitation variants).
- Migration invariant: all 26 statically-listed goals still close; static list deleted (no dual databases).
- Head-symbol pre-filter to bound branching; `SearchConfig.visitLimit` wired as a real abort counter.
- Weakening fallback so closed `⊢[fc] φ` lemmas apply under non-empty contexts.
- Expanded tagging across fc-polymorphic empty-context theorems (~30-60 beyond the original 26).

**Non-Goals**:
- Context-specific lemma application (`ContextualProofs.lean`, context-subset unification) — task 188. Do NOT tag these.
- Rule-set selection syntax (`modal_search +prop`), weight plumbing — task 192.
- Computable search (`ProofSearch/Core.lean`) lemma DB parity — task 186; intentionally untouched.
- Forward chaining / aesop rule-set rework (only a one-line TMLogic docstring fix, report SS1.6).
- DiscrTree indexing (documented upgrade path only, if DB grows past ~300 entries).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import cycle from `Theorems/* -> Automation.LemmaDB` | H | L | LemmaDB.lean imports only `Lean`; Phase 1 gate is a full `lake build` proving no cycle before any behavior change |
| Search blow-up with recursion over 60-90 lemmas | M | M | Head-symbol pre-filter (Phase 3), `depth > 1` gate on recursion, visitLimit abort (Phase 4); benchmark = Tests build time before/after |
| Migration regression (a static-list goal stops closing) | H | L | Phase 2 regression test enumerates all 26 statements via `modal_search` before deletion is committed |
| fc-pinned lemmas fail silently under `apply` | M | L | Tagging policy: only tag fc-polymorphic or Base-stated theorems; `trivial \| decide` discharges `<=` side goals |
| `simp` slow in side-goal discharge | L | M | Discharge ordered `trivial \| decide \| simp` so simp only runs for membership goals |
| mvar-state corruption on backtrack | H | L | `observing?` wrapping (established convention in every `try*` helper); `setGoals` restore discipline |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Fully sequential: each phase builds on the verified state of the previous one.

### Phase 1: LemmaDB attribute module + tag the 26 static-list theorems [NOT STARTED]

**Goal**: `@[tm_lemma]` exists and enumerates exactly the 26 theorems currently hardcoded in `tryDerivedMatch`, with zero behavior change (`tryDerivedMatch` untouched this phase).

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/LemmaDB.lean`: `import Lean` + module docstring + `register_label_attr tm_lemma` (~20 lines). Doc comment states the tagging policy: fc-polymorphic or Base-stated, empty-context theorems and inference rules only; never `ContextualProofs.lean` (task 188).
- [ ] Read the static list at `Helpers.lean:650-694`; record the 26 names verbatim (they drive tagging and the Phase 2 regression test).
- [ ] For each of the 26: add `import Bimodal.Automation.LemmaDB` (exact module prefix per project convention — check an existing import line) to its defining file and tag the declaration `@[tm_lemma]`. Expected files: `Theorems/Combinators.lean`, `Theorems/Propositional/{Core,Connectives,Reasoning}.lean`, `Theorems/{ModalS5,ModalS4,TemporalDerived}.lean`, `Theorems/Perpetuity/{Principles,Bridge}.lean`.
- [ ] Add a smoke check (test file or `#eval`-style assertion in `Tests/BimodalTest/Automation/`): `Lean.labelled `tm_lemma` returns exactly 26 names.

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/LemmaDB.lean` - NEW leaf module
- `Theories/Bimodal/Theorems/*.lean` (files hosting the 26) - import + tags only
- `Tests/BimodalTest/Automation/` - label-count smoke check

**Verification**:
- `lake build` green (proves no import cycle) — full project including Tests
- Smoke check confirms 26 labelled names
- Zero sorries in touched files (`grep -rn "sorry" <touched files>` empty)
- Commit: `task 187 phase 1: LemmaDB attribute + tag 26 static-list theorems`

---

### Phase 2: tryLemmaMatch with recursion; delete tryDerivedMatch; migration regression [NOT STARTED]

**Goal**: Attribute-driven, recursive lemma matching replaces the static strategy with the migration invariant machine-checked.

**Tasks**:
- [ ] In `Helpers.lean`, add `tryLemmaMatch (goal : MVarId) (_ctx _formula : Expr) (searchFn : MVarId -> Nat -> TacticM Bool) (depth : Nat) : TacticM Bool` per report SS3.2 sketch: enumerate `<- Lean.labelled `tm_lemma``; per lemma, inside `observing?`: `goal.apply (mkConst lemmaName)`; for each subgoal, `instantiateMVars` its type, then if `extractDerivationGoal` matches recurse `searchFn sub (depth - 1)`, else discharge via `first | trivial | decide | simp`; fail the attempt if anything remains. (~50 lines)
- [ ] Gate recursion behind `depth > 1`; at `depth = 1` allow only the direct-apply path (empty `newGoals` — subsumes old `isEmpty` fast path for free).
- [ ] Replace the strategy 1b call in `searchProof` (`Helpers.lean:1007`) with `tryLemmaMatch`, keeping pipeline order: 1 `tryAxiomMatch`, 1b `tryLemmaMatch`, 2 `tryAssumptionMatch`, 3 `tryModusPonens`, 4/5 `tryModalK`/`tryTemporalK`.
- [ ] Delete `tryDerivedMatch` and its 26-name static list (`Helpers.lean:650-694`); update the module docstring (`Helpers.lean:37-46`). Do not keep two databases.
- [ ] Add migration regression test in `Tests/BimodalTest/Automation/TacticsTest.lean`: for each of the 26 recorded names, a `modal_search` goal restating its (empty-context) statement — all must close.

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics/Helpers.lean` - add tryLemmaMatch, swap 1b, delete tryDerivedMatch, docstring
- `Tests/BimodalTest/Automation/TacticsTest.lean` - 26-goal migration regression

**Verification**:
- `lake build` green including Tests; all 26 regression goals close (migration invariant holds)
- Zero sorries in touched files
- Existing automation tests unchanged and green (no behavioral churn beyond strategy swap)
- Commit: `task 187 phase 2: tryLemmaMatch backward chaining, static list removed`

---

### Phase 3: Head-symbol pre-filter + weakening fallback + chaining tests [NOT STARTED]

**Goal**: Bound the branching factor and unlock closed-lemma application under non-empty contexts; prove the new chaining capability with tests.

**Tasks**:
- [ ] Pre-filter (report SS3.3): for each labelled lemma, extract under `forallTelescope` on `ConstantInfo.type` the conclusion's `Formula` head constant (same `.app` pattern as `extractDerivationGoal`); build `HashMap Name (Option Name)` per `modal_search` invocation (recompute in `tryLemmaMatch` is acceptable for v1 — ~100 signature reads; no `IO.Ref` caching unless benchmarks demand). Only `apply` lemmas whose conclusion head matches the goal formula's head or is a variable.
- [ ] Weakening fallback (report SS3.5): if direct `apply` fails and the goal context is non-empty, second attempt wrapped as `DerivationTree.weakening [] Γ _ · (List.nil_subset Γ)` (recipe from `AesopRules.axiom_temp_4`), recursing into the resulting empty-context premise.
- [ ] Chaining tests in `Tests/BimodalTest/Automation/TacticsTest.lean` (and `EdgeCaseTest.lean` where it fits): (a) a goal closable only via `imp_trans` composing two registered lemmas; (b) a necessitation-variant chain (`(⊢ φ) -> ⊢ □φ` premise recursion); (c) a closed lemma under non-empty context via the weakening fallback; (d) a depth-exhaustion case failing with the existing "no proof found" error (negative test).
- [ ] Tag `imp_trans` and any inference-rule lemmas needed by the chaining tests if not already among the 26 (Combinators.lean:83).

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics/Helpers.lean` - pre-filter + weakening fallback inside tryLemmaMatch
- `Theories/Bimodal/Theorems/Combinators.lean` - tag inference rules if needed
- `Tests/BimodalTest/Automation/TacticsTest.lean`, `EdgeCaseTest.lean` - chaining/fallback/negative tests

**Verification**:
- `lake build` green including Tests; chaining tests (a)-(c) close; negative test (d) fails as expected
- 26-goal migration regression still green
- Zero sorries in touched files
- Commit: `task 187 phase 3: pre-filter, weakening fallback, chaining tests`

---

### Phase 4: Expand tagging, wire visitLimit, doc fixes, benchmark [NOT STARTED]

**Goal**: Grow the database to its intended coverage, cap search cost, and clean up documentation.

**Tasks**:
- [ ] Expand `@[tm_lemma]` tagging across remaining fc-polymorphic empty-context theorems (~30-60 more) per report SS1.7 inventory: `Theorems/Propositional/{Core,Connectives,Reasoning}.lean`, `TemporalDerived.lean`, `ModalS5.lean`, `ModalS4.lean`, `Perpetuity/{Principles,Bridge}.lean` (`diamond_4`, `modal_5`, `box_to_future`, `box_to_past`, + candidates). Skip `GeneralizedNecessitation.lean` rules already special-cased by `tryModalK`/`tryTemporalK` (duplicative). Never tag `ContextualProofs.lean` or fc-pinned theorems.
- [ ] Wire `SearchConfig.visitLimit` (report SS3.6): `IO.Ref Nat` counter created in `runModalSearch` (`Commands.lean`), decremented in `searchProof`'s preamble, abort at 0 (~15 lines; thread via parameter or a small `SearchState` structure — pick the minimal-churn option).
- [ ] Update the label-count smoke check from Phase 1 to the new total (or relax to `>= 26`).
- [ ] Doc fixes: `Commands.lean` docstring (visitLimit now live); fix the `aesop (rule_sets [TMLogic])` docstring bug in `AesopRules.lean` (no such rule set is declared — report SS1.6, one line).
- [ ] Benchmark check: time `lake build` of `Tests/BimodalTest/Automation/` before/after this phase's tagging; if materially slower, tighten the pre-filter or lower default visitLimit and note in summary.

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Theorems/*.lean` - expanded tags + imports
- `Theories/Bimodal/Automation/Tactics/Commands.lean` - visitLimit wiring + docstring
- `Theories/Bimodal/Automation/Tactics/Helpers.lean` - visit counter in searchProof preamble
- `Theories/Bimodal/Automation/AesopRules.lean` - one-line docstring fix
- `Tests/BimodalTest/Automation/` - smoke-check update

**Verification**:
- `lake build` green including Tests; migration regression + chaining tests still green
- `modal_search` on an unprovable goal terminates within visitLimit (no hang)
- Zero sorries in touched files
- Commit: `task 187 phase 4: expand tagging, visitLimit, doc fixes`

## Testing & Validation

- [ ] Per-phase gate: full `lake build` (project + Tests) green, zero sorries in all touched files — no phase is committed red.
- [ ] Migration invariant (Phase 2, re-checked Phases 3-4): all 26 former static-list goals close via `modal_search`.
- [ ] New-capability tests (Phase 3): `imp_trans` chaining, necessitation premise recursion, weakening fallback, depth-exhaustion negative test.
- [ ] Label-count smoke check tracks the tagged total.
- [ ] Performance proxy: Tests build time not materially regressed after Phase 4 expansion.

## Artifacts & Outputs

- `Theories/Bimodal/Automation/LemmaDB.lean` (new leaf attribute module)
- Modified: `Automation/Tactics/{Helpers,Commands}.lean`, `Automation/AesopRules.lean`, tagged files under `Theorems/`
- Extended: `Tests/BimodalTest/Automation/{TacticsTest,EdgeCaseTest}.lean`
- `specs/187_backward_chaining_lemma_db/summaries/02_backward-chaining-summary.md` (at completion)

## Rollback/Contingency

- Each phase is an independent green commit; `git revert` of the phase commit(s) restores the prior working state.
- Phase 1 is behavior-neutral (tryDerivedMatch untouched) — if the import direction is vetoed during review, relocate the attribute to `Theories/Bimodal/LemmaAttr.lean` (contents identical, report SS3.1) before Phase 2.
- If Phase 2's migration regression cannot be made fully green, do NOT delete `tryDerivedMatch`; keep it as strategy 1b, land `tryLemmaMatch` as 1c behind it, and record the failing goals for a follow-up — dual databases are acceptable only as a temporary, flagged fallback.
- Search blow-up discovered late: lower default `visitLimit` / raise the `depth > 1` recursion gate to `depth > 2`; both are one-line mitigations.
