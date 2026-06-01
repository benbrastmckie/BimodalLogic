# Implementation Plan: Temporal G/H/F/P Tableau Rules (Time-Indexed)

- **Task**: 234 - Temporal G/H/F/P tableau rules with time-indexed branches
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: Task 232 (labeled branch infrastructure, completed), Task 233 (S5 modal rules, completed)
- **Research Inputs**: specs/234_temporal_ghfp_tableau_rules/reports/01_temporal-ghfp-research.md
- **Artifacts**: plans/01_temporal-ghfp-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Replace four unsound identity-collapse temporal rule placeholders (lines 323-334 of Tableau.lean) with eight correct time-indexed temporal tableau rules. The current placeholders strip the temporal operator and keep the formula at the same time label, which is semantically incorrect. The correct implementation requires: (1) seven new Branch helper functions mirroring the existing world helpers from task 232/233, (2) a TimeOrdering structure tracking abstract temporal ordering constraints (needed because past-directed existential rules allocate fresh time indices that are numerically larger but logically earlier), (3) rewriting the four existing G/H rules as universal/persistent rules that propagate to all known future/past times, (4) adding four new F/P rules as existential/consumable rules with fresh time point introduction and auto-propagation, and (5) fixing two broken decomposition helpers (`asSomeFuture?`/`asSomePast?`).

### Research Integration

The research report (01_temporal-ghfp-research.md) provides:
- Confirmation that `.all_future`/`.all_past` pattern matching works via Lean 4 `def` unfolding (Section 1.3)
- Identification that `asSomeFuture?`/`asSomePast?` match the wrong structural form -- they look for `neg(G(neg(phi)))` but actual `some_future` is `untl phi top` (Section 3)
- Complete rule specifications for all 8 temporal rules with sign/direction classification (Section 5)
- Auto-propagation design mirroring the S5 modal pattern from task 233 (Section 5.3)
- TimeOrdering constraint structure design with explicit `(t1, t2)` pairs for abstract ordering (Section 6.4)
- Change surface: ~170 lines across 3 files (Section 8)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the "tableau-training" topic track. Tasks 236 (modal-temporal interaction), 237 (blocking/termination), and 238 (frame-class rules) all depend on task 234. Completing this task unblocks the entire temporal branch of the tableau training pipeline.

## Goals & Non-Goals

**Goals**:
- Replace 4 identity-collapse G/H temporal rules with correct universal/persistent rules
- Add 4 new F/P temporal rules (existential/consumable)
- Implement TimeOrdering constraint tracking for abstract temporal order
- Add 7 time-specific Branch helper functions
- Fix broken `asSomeFuture?` and `asSomePast?` decomposition helpers
- Add `asAllFuture?` and `asAllPast?` decomposition helpers
- Auto-propagate G/H/F/P-formulas to newly created time points
- Full `lake build` passes with zero new sorries

**Non-Goals**:
- Cross-modal-temporal interaction rules (task 236)
- Until/Since primitive rules (task 235)
- Blocking/termination strategy (task 237)
- Frame-class-specific rules (task 238)
- Transitive closure computation for `futureOf`/`pastOf` (immediate neighbors suffice for initial implementation; transitive closure is a refinement)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `.some_future`/`.some_past` pattern matching fails in Lean 4 | H | L | Research confirmed `.all_future`/`.all_past` work; same mechanism applies. Fall back to `.untl phi (.imp .bot .bot)` / `.snce phi (.imp .bot .bot)` explicit patterns. |
| TimeOrdering threading changes `expandOnce` signature, breaking downstream | M | M | Thread TimeOrdering as a parameter alongside Branch in expansion functions. Minimal signature changes -- add optional parameter with default `TimeOrdering.empty`. |
| Past-time allocation with numerically-larger-but-logically-earlier indices confuses `futureTimesOf`/`pastTimesOf` | H | M | Use explicit constraint list rather than Nat ordering. `futureOf`/`pastOf` consult the constraint list, not Nat comparison. |
| Persistent temporal rules cause non-termination in expansion loop | M | L | Existing fuel-based approach from task 233 handles persistent expansions. `recommendedFuel` heuristic may need bump but will not cause infinite loops. |
| `isExpanded` / `findUnexpanded` fails to recognize new rule forms | M | L | Extend `isApplicable` for all 8 rules. `findUnexpanded` delegates to `isExpanded` which calls `findApplicableRule` -- no separate changes needed. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1 |
| 4 | 4 | 2, 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Time Branch Helpers and TimeOrdering Structure [COMPLETED]

**Goal**: Add time-specific Branch helper functions and the TimeOrdering constraint structure to SignedFormula.lean.

**Tasks**:
- [x] Add `Branch.knownTimes : Branch -> List TimeIndex` -- collect distinct time indices via `(b.map (·.label.time)).eraseDups`
- [x] Add `Branch.maxTime : Branch -> TimeIndex` -- `b.foldl (fun acc sf => max acc sf.label.time) 0`
- [x] Add `Branch.nextTime : Branch -> TimeIndex` -- `b.maxTime + 1`
- [x] Add `Branch.allFuturePosFormulas : Branch -> List SignedFormula` -- filter `T(GA)` formulas (match `.pos, .all_future _`)
- [x] Add `Branch.someFutureNegFormulas : Branch -> List SignedFormula` -- filter `F(FA)` formulas (match `.neg, .some_future _` or `.neg, .untl _ (.imp .bot .bot)`)
- [x] Add `Branch.allPastPosFormulas : Branch -> List SignedFormula` -- filter `T(HA)` formulas (match `.pos, .all_past _`)
- [x] Add `Branch.somePastNegFormulas : Branch -> List SignedFormula` -- filter `F(PA)` formulas (match `.neg, .some_past _` or `.neg, .snce _ (.imp .bot .bot)`)
- [x] Define `TimeOrdering` structure with field `constraints : List (TimeIndex x TimeIndex)` where `(a, b)` means `a < b` in abstract temporal order
- [x] Add `TimeOrdering.empty : TimeOrdering` -- `{ constraints := [] }`
- [x] Add `TimeOrdering.addFuture (to : TimeOrdering) (t t_new : TimeIndex) : TimeOrdering` -- prepend `(t, t_new)` *(deviation: altered -- parameter named `ord` instead of `to` since `to` is a Lean 4 reserved keyword)*
- [x] Add `TimeOrdering.addPast (to : TimeOrdering) (t t_new : TimeIndex) : TimeOrdering` -- prepend `(t_new, t)` *(deviation: altered -- parameter named `ord` instead of `to`)*
- [x] Add `TimeOrdering.futureOf (to : TimeOrdering) (t : TimeIndex) : List TimeIndex` -- filter constraints for all `t'` where `(t, t')` exists *(deviation: altered -- parameter named `ord` instead of `to`)*
- [x] Add `TimeOrdering.pastOf (to : TimeOrdering) (t : TimeIndex) : List TimeIndex` -- filter constraints for all `t'` where `(t', t)` exists *(deviation: altered -- parameter named `ord` instead of `to`)*
- [x] Add `TimeOrdering.initWithTime0 : TimeOrdering` -- initial ordering with time 0 as seed (empty constraints, time 0 exists implicitly)

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` -- add 7 Branch helpers after `diamondNegFormulas` (line ~337), add `TimeOrdering` structure after `Branch` namespace end

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.SignedFormula` compiles cleanly
- All 7 helper functions type-check
- TimeOrdering structure and methods type-check

---

### Phase 2: Fix Decomposition Helpers and Add F/P Rule Constructors [COMPLETED]

**Goal**: Fix broken `asSomeFuture?`/`asSomePast?` helpers, add `asAllFuture?`/`asAllPast?` helpers, and add 4 new F/P rule constructors to `TableauRule`.

**Tasks**:
- [x] Rewrite `asSomeFuture?` (Tableau.lean, line ~178) to match `.some_future phi` (i.e., `.untl phi (.imp .bot .bot)`) instead of the current wrong pattern `.imp (.all_future (.imp phi .bot)) .bot`
- [x] Rewrite `asSomePast?` (Tableau.lean, line ~169) to match `.some_past phi` (i.e., `.snce phi (.imp .bot .bot)`) instead of the current wrong pattern `.imp (.all_past (.imp phi .bot)) .bot`
- [x] Add `asAllFuture? : Formula -> Option Formula` matching `.all_future phi`
- [x] Add `asAllPast? : Formula -> Option Formula` matching `.all_past phi`
- [x] Add `TableauRule.someFuturePos` constructor with docstring: `T(FA) -> T(A) at fresh future time (existential, consumable)`
- [x] Add `TableauRule.someFutureNeg` constructor with docstring: `F(FA) -> propagate F(A) to all future times (universal, persistent)`
- [x] Add `TableauRule.somePastPos` constructor with docstring: `T(PA) -> T(A) at fresh past time (existential, consumable)`
- [x] Add `TableauRule.somePastNeg` constructor with docstring: `F(PA) -> propagate F(A) to all past times (universal, persistent)`

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` -- rewrite helpers at lines 169-180, add new helpers, add 4 new constructors to `TableauRule` inductive (lines 92-99)

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Tableau` compiles cleanly
- New helpers correctly decompose `.some_future` and `.some_past` patterns
- All 4 new rule constructors appear in `TableauRule`

---

### Phase 3: Thread TimeOrdering Through Expansion [NOT STARTED]

**Goal**: Modify `applyRule`, `expandOnce`, and `expandBranchWithFuel` (in Saturation.lean) to accept and propagate a `TimeOrdering` parameter, enabling correct temporal constraint tracking.

**Tasks**:
- [ ] Add `timeOrd : TimeOrdering := TimeOrdering.empty` parameter to `applyRule` signature
- [ ] Update `findApplicableRule` to pass `timeOrd` to `applyRule`
- [ ] Modify `RuleResult` or `applyRule` return to include updated `TimeOrdering` when existential temporal rules create new time points. Approach: return `RuleResult x TimeOrdering` from temporal cases, or add a `.temporalLinear` variant that carries the updated ordering. Simplest: make `applyRule` return `(RuleResult, TimeOrdering)` and pass the updated ordering through expansion.
- [ ] Update `expandOnce` (Saturation.lean, line ~400) to accept and propagate `TimeOrdering`
- [ ] Update `expandBranchWithFuel` (Saturation.lean) to thread `TimeOrdering` through recursive calls
- [ ] Update `buildTableau` entry point to initialize with `TimeOrdering.empty`
- [ ] Ensure `ExpandedTableau`, `BranchListResult`, and downstream types compile

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` -- `applyRule` signature, `findApplicableRule`
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` -- `expandOnce`, `expandBranchWithFuel`, `buildTableau`
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` -- if `buildTableau` signature changes, update callers

**Verification**:
- `lake build` compiles cleanly with the threading changes
- Existing propositional and modal tests still pass (TimeOrdering is `empty` by default, no behavioral change for non-temporal rules)

---

### Phase 4: Rewrite G/H Rules and Add F/P Rules [NOT STARTED]

**Goal**: Replace the 4 identity-collapse temporal rule placeholders with correct universal/persistent G/H rules, and implement 4 new existential/consumable F/P rules, including auto-propagation logic.

**Tasks**:
- [ ] **T(GA) @ (w,t)**: Rewrite `allFuturePos` case to use `timeOrd.futureOf t` to find all known future times, propagate `T(A) @ (w, t')` for each future time `t'`, return `.persistent` (formula stays for future propagation)
- [ ] **F(GA) @ (w,t)**: Rewrite `allFutureNeg` case to introduce fresh `t_new = branch.nextTime`, create `F(A) @ (w, t_new)`, update `timeOrd` with `addFuture t t_new`, auto-propagate all `T(GA)` and `F(FA)` from times `t'' <= t` to `t_new`, return `.linear` with updated `TimeOrdering`
- [ ] **T(HA) @ (w,t)**: Rewrite `allPastPos` case to use `timeOrd.pastOf t` to find all known past times, propagate `T(A) @ (w, t')` for each past time `t'`, return `.persistent`
- [ ] **F(HA) @ (w,t)**: Rewrite `allPastNeg` case to introduce fresh `t_new = branch.nextTime`, create `F(A) @ (w, t_new)`, update `timeOrd` with `addPast t t_new`, auto-propagate all `T(HA)` and `F(PA)` from times `t''` that have `t < t''` to `t_new`, return `.linear` with updated `TimeOrdering`
- [ ] **T(FA) @ (w,t)**: Implement `someFuturePos` -- existential, create fresh `t_new = branch.nextTime`, `T(A) @ (w, t_new)`, update `timeOrd` with `addFuture t t_new`, auto-propagate all `T(GA)` and `F(FA)` to `t_new`, return `.linear`
- [ ] **F(FA) @ (w,t)**: Implement `someFutureNeg` -- universal persistent, propagate `F(A) @ (w, t')` for all future times `t'` from `timeOrd.futureOf t`, return `.persistent`
- [ ] **T(PA) @ (w,t)**: Implement `somePastPos` -- existential, create fresh `t_new = branch.nextTime`, `T(A) @ (w, t_new)`, update `timeOrd` with `addPast t t_new`, auto-propagate all `T(HA)` and `F(PA)` to `t_new`, return `.linear`
- [ ] **F(PA) @ (w,t)**: Implement `somePastNeg` -- universal persistent, propagate `F(A) @ (w, t')` for all past times `t'` from `timeOrd.pastOf t`, return `.persistent`
- [ ] Update `isApplicable` with 4 new cases for `someFuturePos`, `someFutureNeg`, `somePastPos`, `somePastNeg`
- [ ] Update `allRules` list to include the 4 new F/P rules after the existing G/H rules

**Timing**: 2.5 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` -- `isApplicable` (lines 189-210), `applyRule` (lines 220-335), `allRules` (lines 345-355)

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Tableau` compiles cleanly
- All 8 temporal rules appear in `allRules`
- All 8 temporal `isApplicable` cases return `true` for correct formula/sign combinations
- No identity-collapse patterns remain

---

### Phase 5: Integration Testing and Full Build Verification [NOT STARTED]

**Goal**: Verify correctness via `#eval` tests for G/H/F/P formulas, confirm the full project builds with zero new sorries.

**Tasks**:
- [ ] Add `#eval` test: `G p -> G p` should be VALID (propositional tautology, tests basic G rule firing)
- [ ] Add `#eval` test: `G (p -> q) -> (G p -> G q)` should be VALID (temporal K distribution)
- [ ] Add `#eval` test: `H (p -> q) -> (H p -> H q)` should be VALID (past temporal K)
- [ ] Add `#eval` test: `G p -> p` should be INVALID (T-axiom fails under strict semantics -- open guard)
- [ ] Add `#eval` test: `H p -> p` should be INVALID (past T-axiom fails under strict semantics)
- [ ] Add `#eval` test: `p -> G p` should be INVALID (non-theorem)
- [ ] Add `#eval` test: `F p -> F p` should be VALID (propositional tautology)
- [ ] Run full `lake build` and confirm zero errors
- [ ] Verify no new sorries introduced via `grep -r "sorry" Theories/Bimodal/Metalogic/Decidability/`
- [ ] Confirm downstream modules (Closure.lean, ProofExtraction.lean, CountermodelExtraction.lean, DecisionProcedure.lean, Correctness.lean) still compile

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` or a test file -- add `#eval` tests
- No other modifications expected; this phase is verification-only

**Verification**:
- All validity tests return expected results
- All invalidity tests return expected results
- `lake build` completes with zero errors
- `grep -r "sorry" Theories/Bimodal/Metalogic/Decidability/` shows no new sorries

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Decidability.SignedFormula` passes after Phase 1
- [ ] `lake build Bimodal.Metalogic.Decidability.Tableau` passes after Phase 2
- [ ] `lake build` (full project) passes after Phase 3
- [ ] All 8 temporal rules fire correctly for appropriate formula/sign combinations
- [ ] Universal rules (T(GA), F(FA), T(HA), F(PA)) return `.persistent` and propagate to all known times
- [ ] Existential rules (F(GA), T(FA), F(HA), T(PA)) return `.linear`, create fresh time points, and auto-propagate
- [ ] `G p -> G p` evaluates as VALID
- [ ] `G p -> p` evaluates as INVALID (strict semantics)
- [ ] `G (p -> q) -> (G p -> G q)` evaluates as VALID (temporal K)
- [ ] Full `lake build` passes with zero new sorries

## Artifacts & Outputs

- `specs/234_temporal_ghfp_tableau_rules/plans/01_temporal-ghfp-plan.md` (this file)
- `specs/234_temporal_ghfp_tableau_rules/summaries/01_temporal-ghfp-summary.md` (created during implementation)
- Modified files:
  - `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` (Branch helpers + TimeOrdering)
  - `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` (rules + helpers)
  - `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` (TimeOrdering threading)
  - `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` (if signature changes)

## Rollback/Contingency

All changes are confined to the `Metalogic/Decidability/` directory. If implementation fails:
1. Revert to the identity-collapse placeholders (known to compile)
2. Revert TimeOrdering additions to SignedFormula.lean (pure additions, no existing code modified)
3. `git checkout -- Theories/Bimodal/Metalogic/Decidability/` restores prior state
4. If past-time allocation proves intractable with explicit constraints, fall back to future-only rules first (4 rules) and defer past-directed rules to a follow-up task
