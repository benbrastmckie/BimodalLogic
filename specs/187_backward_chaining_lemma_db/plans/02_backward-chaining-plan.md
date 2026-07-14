# Implementation Plan: Backward-Chaining Lemma Database

- **Task**: 187 - Backward-chaining lemma database (solve_by_elim analogue)
- **Status**: [COMPLETED]
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

### Phase 1: LemmaDB attribute module + tag the 26 static-list theorems [COMPLETED]

**Goal**: `@[tm_lemma]` exists and enumerates exactly the 26 theorems currently hardcoded in `tryDerivedMatch`, with zero behavior change (`tryDerivedMatch` untouched this phase).

**Tasks**:
- [x] Create `Theories/Bimodal/Automation/LemmaDB.lean`: `import Lean` + module docstring + `register_label_attr tm_lemma` (~20 lines). Doc comment states the tagging policy: fc-polymorphic or Base-stated, empty-context theorems and inference rules only; never `ContextualProofs.lean` (task 188). *(completed — declared inside namespace `Bimodal.Automation.LemmaDB` because the macro emits an `ext` declaration; attribute name is still bare `tm_lemma`)*
- [x] Read the static list at `Helpers.lean:650-694`; record the 26 names verbatim (they drive tagging and the Phase 2 regression test). *(completed)*
- [x] For each of the 26: add `import Bimodal.Automation.LemmaDB` (exact module prefix per project convention — check an existing import line) to its defining file and tag the declaration `@[tm_lemma]`. Expected files: `Theorems/Combinators.lean`, `Theorems/Propositional/{Core,Connectives,Reasoning}.lean`, `Theorems/{ModalS5,ModalS4,TemporalDerived}.lean`, `Theorems/Perpetuity/{Principles,Bridge}.lean`. *(deviation: altered — actual files are Combinators, Propositional/{Core,Connectives,Reasoning}, TemporalDerived, ModalS5, Perpetuity/{Principles,Helpers}; box_to_future/box_to_past live in Perpetuity/Helpers.lean not Bridge.lean. Also `efq` is a `@[deprecated]` alias — tagged the primary `efq_neg` (identical statement) instead, since stacked attribute blocks do not parse and automation should not apply deprecated constants)*
- [x] Add a smoke check (test file or `#eval`-style assertion in `Tests/BimodalTest/Automation/`): `Lean.labelled `tm_lemma` returns exactly 26 names. *(completed — NEW file Tests/BimodalTest/Automation/LemmaDBTest.lean, registered in Tests/BimodalTest.lean; TacticsTest.lean is broken at baseline so tests go in the dedicated file per task-189 precedent)*

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

### Phase 2: tryLemmaMatch with recursion; delete tryDerivedMatch; migration regression [COMPLETED]

**Goal**: Attribute-driven, recursive lemma matching replaces the static strategy with the migration invariant machine-checked.

**Tasks**:
- [x] In `Helpers.lean`, add `tryLemmaMatch ...` per report SS3.2 sketch. *(completed — factored into `tryLemmaMatchCore (lemmas : Array Name) ...` + a thin `tryLemmaMatch` that passes `← Lean.labelled `tm_lemma`. This gives task 188 a parameterized entry point (`tryLemmaMatchCore`) to hook weakening-aware / context-specific matching without going through the attribute. Used `mkConstWithFreshMVarLevels` instead of `mkConst` so universe-polymorphic lemmas apply cleanly.)*
- [x] Gate recursion behind `depth > 1`; direct-apply path works at any depth. *(completed — `if depth ≤ 1 then throwError` after the empty-`newGoals` fast path)*
- [x] Replace the strategy 1b call in `searchProof` with `tryLemmaMatch`, keeping pipeline order. *(completed)*
- [x] Delete `tryDerivedMatch` and its 26-name static list; update the module docstring. *(completed — `def tryDerivedMatch` and its list removed; module docstring section 2 and the `searchProof` algorithm comment updated. Residual `tryDerivedMatch` mentions remain only in unrelated test/doc comments in Commands.lean/EdgeCaseTest.lean.)*
- [x] Add migration regression test. *(deviation: altered — placed in the NEW Tests/BimodalTest/Automation/LemmaDBTest.lean, not the baseline-broken TacticsTest.lean, per task-189 precedent. 26 empty-context `modal_search` goals, all closing.)*

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

### Phase 3: Head-symbol pre-filter + weakening fallback + chaining tests [COMPLETED]

**Goal**: Bound the branching factor and unlock closed-lemma application under non-empty contexts; prove the new chaining capability with tests.

**Tasks**:
- [x] Pre-filter (report SS3.3): head-symbol filter via `formulaHead` + `lemmaConclusionHead` (`forallTelescope` on `ConstantInfo.type`, read the `DerivationTree` conclusion's head const). *(completed — recomputed per lemma per invocation as planned; `some g, some l => if g != l then continue`, variable/none heads treated as wildcard)*
- [x] Weakening fallback (report SS3.5): reduce non-empty-context `Γ ⊢[fc] φ` to `[] ⊢[fc] φ` via `DerivationTree.weakening [] Γ φ ?d (List.nil_subset Γ)` and recurse. *(completed — guarded by `isNilContext` to guarantee termination; empty list built with `mkAppOptM ``List.nil #[some Formula]` — plain `mkAppM` throws since `List.nil` has no explicit args)*
- [x] Chaining tests. *(deviation: altered — tests placed in the NEW LemmaDBTest.lean (TacticsTest broken at baseline). Implemented: (c) weakening fallback (3 goals) and (d) depth-exhaustion/non-derivability via `fail_if_success` (robust vs. brittle message-text matching, and also asserts the weakening recursion TERMINATES on unprovable goals). (a)/(b) NOT implemented as passing tests — see below.)*
- [x] Tag `imp_trans`. *(deviation: skipped — `imp_trans` intentionally left UNtagged. Empirically verified: its conclusion `A.imp C` leaves the middle `B` free, and the greedy backtrack-free search greedily mis-unifies it (`identity : A→A` grabs `?B`), so tagging adds cost with no reliable benefit. Documented at `Combinators.imp_trans`. Test (a) imp_trans-chaining and (b) necessitation-chaining are therefore not included: (a) is unsupported by this architecture (needs metavariable backtracking, out of scope), and (b) `⊢ □φ` recursion is already handled by `tryModalK`, not `tryLemmaMatch`. The genuinely-new recursion capability is demonstrated via the determined-premise weakening fallback (tests c/d).)*

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

### Phase 4: Expand tagging, wire visitLimit, doc fixes, benchmark [COMPLETED]

**Goal**: Grow the database to its intended coverage, cap search cost, and clean up documentation.

**Tasks**:
- [x] Expand `@[tm_lemma]` tagging. *(deviation: altered — added 9 premise-free empty-context theorems for a total of 35 (not ~30-60): `lem`, `efq_axiom`, `peirce_axiom` (Core); `t_box_consistency`, `box_disj_intro` (ModalS5); `contrapositive` (TemporalDerived); `box_to_box_past`, `mb_diamond` (Perpetuity/Principles); `box_to_present` (Perpetuity/Helpers). Deliberately conservative: only premise-free theorems tagged, so no new inference-rule branching that could blow up search — free-middle inference rules (imp_trans) stay untagged per Phase 3. GeneralizedNecessitation and ContextualProofs untouched as instructed.)*
- [x] Wire `SearchConfig.visitLimit`. *(completed — `IO.mkRef cfg.visitLimit` in `runModalSearch`/`runTemporalSearch`/`runPropositionalSearch`; `searchProof` takes the `IO.Ref Nat` as its curried first param (so `searchProof counter` keeps the `searchFn` shape for the `try*` helpers — minimal churn, no new struct), decrements in its preamble, aborts at 0. Dropped the unused `_maxDepth` param.)*
- [x] Update the label-count smoke check. *(completed — relaxed to `≥ 26`; current total 35, comment updated)*
- [x] Doc fixes: `Commands.lean` visitLimit docstring + `AesopRules.lean` TMLogic bug. *(completed — AesopRules docstring corrected to `aesop` (default rule set); confirmed `declare_aesop_rule_sets [TMLogic]` is absent so `rule_sets [TMLogic]` was invalid)*
- [x] Benchmark check. *(completed — full `lake build` (1755 jobs) green; `BimodalTest.Automation.LemmaDBTest` builds in ~1.7s with all 5 test groups. No material regression observed; the head-symbol pre-filter bounds per-node branching and visitLimit caps total cost.)*

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

- [x] Per-phase gate: full `lake build` (project + Tests) green, zero sorries in all touched files — no phase committed red.
- [x] Migration invariant (Phase 2, re-checked Phases 3-4): all 26 former static-list goals close via `modal_search` (Group 2 of LemmaDBTest).
- [x] New-capability tests (Phase 3): weakening fallback (Group 3 c) and depth-exhaustion/non-derivability (Group 3 d). *(deviation: `imp_trans` chaining and necessitation recursion not tested — imp_trans free-middle chaining is unsupported by the greedy search and necessitation is handled by `tryModalK`; new capability shown via the determined-premise weakening fallback instead.)*
- [x] Label-count smoke check tracks the tagged total (≥ 26 lower bound; current 35).
- [x] Performance proxy: Tests build time not materially regressed (LemmaDBTest ~1.7s; full build green).

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
