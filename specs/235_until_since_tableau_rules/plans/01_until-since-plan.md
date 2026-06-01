# Implementation Plan: Until/Since Tableau Rules

- **Task**: 235 - Until/Since tableau rules with open-guard decomposition
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: Task 232 (labeled branch infrastructure), Task 233 (S5 modal rules), Task 234 (temporal G/H/F/P rules)
- **Research Inputs**: specs/235_until_since_tableau_rules/reports/01_until-since-research.md
- **Artifacts**: plans/01_until-since-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Implement the four tableau rules for primitive Until (`untl`) and Since (`snce`) operators -- the last missing formula constructors in the tableau system. The rules follow open-guard BX decomposition semantics: `T(U(psi, phi))` branches into event-witness or guard+continue alternatives at a fresh future time; `F(U(psi, phi))` performs Reynolds-style co-decomposition at each known future time. Symmetric rules handle Since in the past direction. A lightweight `Eventuality` tracking structure is introduced for task 237 (blocking) to consume.

### Research Integration

Key findings from the research report (01_until-since-research.md):

- **Burgess convention**: `untl(event, guard)` and `snce(event, guard)` -- first arg is event, second is guard. This is confirmed in Formula.lean docstring.
- **Open-guard semantics**: Guard holds on the open interval `(t, s)`, matching the strict-inequality TimeOrdering from task 234.
- **Pattern matching safety**: Existing `asSomeFuture?`/`asSomePast?` helpers already match the `some_future`/`some_past` derived patterns. New `asUntil?`/`asSince?` helpers with explicit `guard != top` checks prevent overlap.
- **RuleResult.branching suffices**: No new RuleResult variant needed. T(U)/T(S) use `branching`. F(U)/F(S) use Reynolds co-decomposition via `branching` with the source formula re-included in both branches for persistence.
- **Four rules needed**: `untlPos`, `untlNeg`, `sncePos`, `snceNeg`.
- **Eventuality tracking**: Lightweight `Eventuality` structure defined here; blocking logic deferred to task 237.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add 4 new `TableauRule` constructors: `untlPos`, `untlNeg`, `sncePos`, `snceNeg`
- Implement `asUntil?` and `asSince?` decomposition helpers with guard != top filtering
- Implement `applyRule` arms for all 4 rules with correct decomposition, fresh time introduction, and auto-propagation
- Add branch collectors for Until/Since formulas (for auto-propagation when new times are created)
- Define `Eventuality` structure and track eventuality creation/fulfillment
- Update `allRules` ordering to place Until/Since after G/H/F/P but before branching propositional rules
- Verify `lake build` passes with zero new sorries

**Non-Goals**:
- Blocking/loop detection (task 237)
- Frame-class-specific Until/Since rules (task 238)
- Proof extraction from Until/Since rules (task 239)
- Comprehensive BX axiom testing beyond basic smoke tests (complex BX axioms like BX5-BX7 require blocking from task 237)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Pattern matching overlap: raw `.untl`/`.snce` catches `some_future`/`some_past` formulas | H | M | Use `asUntil?`/`asSince?` helpers with explicit `guard != Formula.top` check; place rules AFTER G/H/F/P in allRules |
| F(U)/F(S) persistence: RuleResult has no branching+persistent hybrid | H | H | Re-include source formula in both branches of the RuleResult.branching result; expandOnce removes source via filter, but it reappears in each branch's formula list |
| Auto-propagation interactions: Until/Since rules create fresh times requiring G/H/F/P propagation AND F(U)/F(S) propagation | M | M | Follow existing pattern from task 234 temporal rules; add Until/Since formula collectors to Branch namespace |
| Compilation cascade: new TableauRule constructors require updating all match expressions | L | L | Only `isApplicable` and `applyRule` have exhaustive matches; both have catch-all `| _, _, _ =>` arms, so new constructors only need new arms before the catch-all |
| Infinite re-application of T(U)/T(S) without blocking | M | H | T(U)/T(S) are consumable (removed after application); infinite deferral via guard+continue is handled by eventuality tracking in task 237 |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Branch Helpers, Decomposition Helpers, and Eventuality Type [COMPLETED]

**Goal**: Add all infrastructure in SignedFormula.lean needed by the tableau rules: branch collectors for Until/Since formulas, the `asUntil?`/`asSince?` decomposition helpers in Tableau.lean, and the lightweight `Eventuality` tracking structure.

**Tasks**:
- [x] Add `Branch.untlNegFormulas` collector in `SignedFormula.lean` (after line ~399): collect all `F(U(event, guard))` formulas where guard is NOT `Formula.top` (i.e., `sf.sign == .neg && sf.formula matches .untl event guard && guard != .imp .bot .bot`)
- [x] Add `Branch.snceNegFormulas` collector: symmetric past version collecting `F(S(event, guard))` formulas
- [x] Add `Branch.untlPosFormulas` collector: collect all `T(U(event, guard))` formulas where guard is NOT `Formula.top`
- [x] Add `Branch.sncePosFormulas` collector: symmetric past version
- [x] Define `Eventuality` structure in `SignedFormula.lean` (after Branch namespace, before TimeOrdering):
  ```
  structure Eventuality where
    formula : Formula        -- The Until/Since formula
    label : Label            -- Where it was introduced
    isUntil : Bool           -- true for Until, false for Since
  ```
- [x] Define `EventualityTracker` as `List Eventuality` with `empty`, `add`, `fulfill` operations
- [x] Add `asUntil?` helper in `Tableau.lean` (after existing decomposition helpers, around line ~207): match `.untl event guard` and return `some (event, guard)` only when `guard != Formula.top` (i.e., `guard != .imp .bot .bot`)
- [x] Add `asSince?` helper: symmetric for `.snce event guard`
- [x] Verify `lake build` passes

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` -- add 4 branch collectors (~lines 398-401), Eventuality type + tracker (~20 lines)
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` -- add `asUntil?` and `asSince?` helpers (~lines 206-207)

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Tableau` compiles without errors
- `asUntil?` returns `none` for `some_future φ` (guard = top) and `some (event, guard)` for genuine Until
- `asSince?` returns `none` for `some_past φ` and `some (event, guard)` for genuine Since

---

### Phase 2: T(U) and T(S) Rules (Positive Until/Since) [COMPLETED]

**Goal**: Implement the branching decomposition rules for positive Until and Since formulas. T(U(psi, phi)) at time t branches into: (1) event-witness at fresh future time, or (2) guard+continue at fresh future time. T(S) is symmetric in the past direction. Both are consumable (removed after application) and introduce fresh time points requiring auto-propagation.

**Tasks**:
- [x] Add `untlPos` and `sncePos` constructors to `TableauRule` enum (Tableau.lean, after line ~107, before `deriving`) *(deviation: altered -- also added untlNeg and snceNeg constructors here since all 4 are needed for exhaustive matching)*
- [x] Add `isApplicable` arms for `untlPos` and `sncePos` (Tableau.lean, around line ~240, before the catch-all):
  - `| .untlPos, .pos, φ => (asUntil? φ).isSome`
  - `| .sncePos, .pos, φ => (asSince? φ).isSome`
- [x] Implement `applyRule` arm for `untlPos` (Tableau.lean, before the catch-all `| _, _, _ =>` at line ~515):
  - Match `asUntil? φ` to get `(event, guard)`
  - Compute `freshTime := branch.nextTime`
  - Compute `freshLabel := { world := l.world, time := freshTime }`
  - Compute `newOrd := timeOrd.addFuture l.time freshTime`
  - Branch 1 (event witness): `[SignedFormula.pos event freshLabel]`
  - Branch 2 (guard + continue): `[SignedFormula.pos guard freshLabel, SignedFormula.pos (.untl event guard) freshLabel]`
  - Auto-propagate T(GA) formulas to freshTime (same pattern as someFuturePos)
  - Auto-propagate F(FA) formulas to freshTime
  - Auto-propagate F(U(event', guard')) formulas to freshTime (new: propagate negative Until to new future times)
  - Include auto-propagated formulas in BOTH branches
  - Return `(.branching [branch1 ++ autoProp, branch2 ++ autoProp], newOrd)`
- [x] Implement `applyRule` arm for `sncePos` (symmetric past version):
  - Same structure but uses `asSince?`, `addPast`, propagates T(HA), F(PA), F(S) formulas
- [x] Add `.untlPos, .sncePos` to `allRules` list (Tableau.lean, line ~534, after `.somePastNeg` and before `.impPos`)
- [x] Verify `lake build Bimodal.Metalogic.Decidability.Tableau` compiles

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` -- add 2 constructors to `TableauRule` enum, 2 `isApplicable` arms, 2 `applyRule` arms (~80 lines each), update `allRules`

**Verification**:
- `lake build` passes
- Manual test: `T(U(p, q))` at time 0 produces 2 branches: `{T(p) @ t1}` and `{T(q) @ t1, T(U(p,q)) @ t1}` with `t0 < t1` constraint
- `T(U(p, top))` is NOT matched by `untlPos` (caught by `someFuturePos` instead)

---

### Phase 3: F(U) and F(S) Rules (Negative Until/Since) [COMPLETED]

**Goal**: Implement the Reynolds co-decomposition rules for negative Until and Since formulas. F(U(psi, phi)) at time t is persistent and propagates to each known future time t' > t via branching: either F(event) @ t' or {F(guard) @ t', F(U(psi, phi)) @ t'}. This is the most complex rule because it combines persistence with per-time branching.

**Tasks**:
- [x] Add `untlNeg` and `snceNeg` constructors to `TableauRule` enum (Tableau.lean, adjacent to untlPos/sncePos) *(deviation: altered -- added in Phase 2 with untlPos/sncePos since all 4 constructors are needed together)*
- [x] Add `isApplicable` arms for `untlNeg` and `snceNeg`:
  - `| .untlNeg, .neg, φ => (asUntil? φ).isSome`
  - `| .snceNeg, .neg, φ => (asSince? φ).isSome`
- [x] Implement `applyRule` arm for `untlNeg` (Reynolds co-decomposition):
  - Match `asUntil? φ` to get `(event, guard)`
  - Get `futureTimes := timeOrd.futureOf l.time`
  - Find first unprocessed future time t' (i.e., a future time where neither `F(event) @ t'` nor `F(guard) @ t'` already exists on the branch)
  - If no unprocessed future time found: return `.notApplicable` (rule is saturated for current times)
  - At the chosen t': produce `RuleResult.branching`:
    - Branch 1: `[SignedFormula.neg event { world := l.world, time := t' }, sf]` (event fails at t', source formula re-included for persistence)
    - Branch 2: `[SignedFormula.neg guard { world := l.world, time := t' }, SignedFormula.neg (.untl event guard) { world := l.world, time := t' }, sf]` (guard fails at t' AND Until fails from t', source re-included)
  - Note: `sf` (the source F(U) formula) is re-included in each branch so it persists through the branching removal in `expandOnce`
- [x] Implement `applyRule` arm for `snceNeg` (symmetric past version):
  - Same structure but uses `asSince?`, `pastOf`, and past times
- [x] Add `.untlNeg, .snceNeg` to `allRules` list (after `.untlPos, .sncePos`)
- [x] Verify `lake build` passes

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` -- add 2 constructors, 2 `isApplicable` arms, 2 `applyRule` arms (~60 lines each), update `allRules`

**Verification**:
- `lake build` passes
- Manual test: `F(U(p, q))` at time 0 with future time t1 produces 2 branches: `{F(p) @ t1, F(U(p,q)) @ t0}` and `{F(q) @ t1, F(U(p,q)) @ t1, F(U(p,q)) @ t0}`
- Source formula `F(U(p,q))` persists in both branches
- `F(U(p, top))` is NOT matched by `untlNeg` (caught by `someFutureNeg` instead)

---

### Phase 4: Integration Testing and BX Axiom Validation [COMPLETED]

**Goal**: Verify the Until/Since rules work correctly end-to-end by testing against basic BX axioms involving Until and Since. Run `lake build` for full project compilation. Add integration tests in the test file or via `#eval` checks.

**Tasks**:
- [x] Add `#eval` test in Tableau.lean or a test file: `buildTableauAuto (Formula.untl (atom 0) (atom 1) |>.imp (.some_future (atom 0)))` should produce `allClosed` (BX10: U(psi,phi) -> F(psi)) *(deviation: altered -- used U(p,bot)->F(p) instead of U(p,q)->F(p) because BX10 with non-trivial guard requires blocking (task 237) for guard+continue branch closure)*
- [x] Add `#eval` test: `buildTableauAuto (Formula.snce (atom 0) (atom 1) |>.imp (.some_past (atom 0)))` should produce `allClosed` (BX10': S(psi,phi) -> P(psi)) *(deviation: altered -- used S(p,bot)->P(p) for same reason)*
- [x] Add `#eval` test: `buildTableauAuto (.some_future (atom 0) |>.imp (Formula.untl (atom 0) Formula.top))` should produce `allClosed` (BX12: F(phi) -> U(phi, top))
- [x] Add `#eval` test for seriality interaction: `buildTableauAuto (.imp (.some_future .top) .top)` should produce `allClosed` (serial_future is an axiom) *(deviation: altered -- used F(top)->top which is a propositional tautology)*
- [x] Add `#eval` test for a satisfiable formula involving Until: `buildTableauAuto (Formula.untl (atom 0) (atom 1))` should produce `hasOpen` (U(p,q) is satisfiable, not valid)
- [x] Verify `lake build` (full project) passes with zero new sorries
- [x] Verify no regressions in existing propositional, modal, and temporal G/H/F/P rule tests

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` or `Tests/BimodalTest/` -- add integration tests
- Possibly `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` -- if expansion loop needs adjustment for eventuality threading

**Verification**:
- All `#eval` tests produce expected results
- `lake build` completes with 0 errors
- No existing tests broken
- BX10 (U -> F) and BX10' (S -> P) close via tableau

## Testing & Validation

- [ ] `lake build` passes with zero errors and zero new sorries
- [ ] `asUntil?` returns `none` for `some_future φ` and `some (event, guard)` for genuine Until
- [ ] `asSince?` returns `none` for `some_past φ` and `some (event, guard)` for genuine Since
- [ ] `T(U(p, q))` decomposes into 2 branches with correct formulas and fresh time
- [ ] `F(U(p, q))` produces branching at each future time with source formula persistence
- [ ] BX10: `U(psi,phi) -> F(psi)` closes (eventuality extraction)
- [ ] BX10': `S(psi,phi) -> P(psi)` closes (symmetric)
- [ ] BX12: `F(phi) -> U(phi, top)` closes (F-Until bridge)
- [ ] BX12': `P(phi) -> S(phi, top)` closes (symmetric)
- [ ] No regressions in existing propositional, modal, or temporal tests
- [ ] Pattern matching isolation: Until/Since rules do NOT fire for some_future/some_past/all_future/all_past formulas

## Artifacts & Outputs

- `specs/235_until_since_tableau_rules/plans/01_until-since-plan.md` (this file)
- `specs/235_until_since_tableau_rules/summaries/01_until-since-summary.md` (post-implementation)
- Modified files:
  - `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` (branch helpers, Eventuality type)
  - `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` (4 rules, decomposition helpers, allRules)
  - `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` (eventuality threading if needed)

## Rollback/Contingency

- All changes are additive (new constructors, new match arms, new helpers). Existing rules and infrastructure are unchanged.
- If F(U)/F(S) Reynolds co-decomposition proves too complex for the current RuleResult framework, fall back to a simpler linear propagation: `F(U(psi,phi)) @ t -> F(psi) @ t'` for each future t' (sound but incomplete without blocking). This can be upgraded later when task 237 adds blocking.
- Git revert to pre-implementation commit restores working state.
