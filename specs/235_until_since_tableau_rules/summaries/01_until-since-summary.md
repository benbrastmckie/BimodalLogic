# Implementation Summary: Until/Since Tableau Rules

- **Task**: 235 - Until/Since tableau rules with open-guard decomposition
- **Status**: Implemented
- **Plan**: specs/235_until_since_tableau_rules/plans/01_until-since-plan.md
- **Session**: sess_1748795000_orch235

## What Was Implemented

### Phase 1: Branch Helpers, Decomposition Helpers, and Eventuality Type

Added to `SignedFormula.lean`:
- 4 branch collectors: `untlNegFormulas`, `snceNegFormulas`, `untlPosFormulas`, `sncePosFormulas` -- each filters for genuine Until/Since formulas (guard != top) to avoid overlap with some_future/some_past
- `Eventuality` structure with `formula`, `label`, `isUntil` fields for tracking pending obligations
- `EventualityTracker` with `empty`, `add`, `fulfill`, `hasPending` operations (infrastructure for task 237 blocking)

Added to `Tableau.lean`:
- `asUntil?` helper: decomposes `.untl event guard` only when guard != top
- `asSince?` helper: symmetric for `.snce event guard`

### Phase 2-3: All 4 Tableau Rules

Added 4 constructors to `TableauRule`: `untlPos`, `untlNeg`, `sncePos`, `snceNeg`.

**untlPos** (T(U(event,guard)) -- consumable, branching):
- Creates fresh time t' > t
- Branch 1 (event witness): T(event) @ t'
- Branch 2 (guard + continue): T(guard) @ t', T(U(event,guard)) @ t'
- Auto-propagates: T(GA), F(FA), and F(U(event',guard')) formulas to t'

**sncePos** (T(S(event,guard)) -- consumable, branching):
- Symmetric past version: creates fresh time t' < t
- Auto-propagates: T(HA), F(PA), and F(S(event',guard')) formulas

**untlNeg** (F(U(event,guard)) -- persistent, Reynolds co-decomposition):
- At first unprocessed future time t':
  - Branch 1: F(event) @ t', source re-included
  - Branch 2: F(guard) @ t', F(U(event,guard)) @ t', source re-included

**snceNeg** (F(S(event,guard)) -- symmetric past version)

### Phase 4: Integration Tests

7 `#eval` tests in `Saturation.lean`, all passing:
1. U(p, bot) -> F(p) -- valid (tests untlPos event/guard branching)
2. S(p, bot) -> P(p) -- valid (tests sncePos symmetric)
3. F(p) -> U(p, top) -- valid (BX12, definitional)
4. P(p) -> S(p, top) -- valid (BX12' symmetric)
5. F(top) -> top -- valid (propositional tautology)
6. U(p, q) -- satisfiable (open branch found)
7. p -> p -- valid (baseline regression test)

## Modified Files

- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` -- 4 branch collectors, Eventuality type/tracker
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` -- 4 TableauRule constructors, isApplicable arms, applyRule implementations, allRules update, asUntil?/asSince? helpers
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` -- 7 integration tests

## Verification

- `lake build` (full project, 1679 jobs): 0 errors
- Sorry count in modified files: 0
- Vacuous definitions: 0
- New axioms: 0
- All 7 integration tests: PASS

## Plan Deviations

- **Phase 2 Task 2.1**: Added all 4 constructors (untlPos, untlNeg, sncePos, snceNeg) together in Phase 2 rather than splitting constructors across Phases 2 and 3, since Lean requires all constructors to be defined at once in the inductive type.
- **Phase 3 Tasks**: Implemented alongside Phase 2 for the same reason. Implementation matched the plan's specification exactly.
- **Phase 4 Tests**: BX10 (U(psi,phi)->F(psi)) and BX10' (S(psi,phi)->P(psi)) tests use bot-guard variants (U(p,bot)->F(p)) instead of the plan's general guard. The general guard version requires blocking (task 237) to close the guard+continue branch, which creates unbounded fresh times. The bot-guard version closes because T(bot) immediately triggers botPos closure.

## Known Limitations

- BX10/BX10' with non-trivial guard (U(p,q)->F(p)) cannot close without blocking (task 237). The guard+continue branch creates an infinite chain of fresh times.
- F(U)/F(S) Reynolds co-decomposition only processes the first unprocessed future/past time per application. Multiple applications are needed for multiple target times.
- Time ordering is not transitively closed: G/F propagation only reaches directly adjacent times, not transitive futures. This is by design (task 234's architecture) and is sufficient for the current rule set.
