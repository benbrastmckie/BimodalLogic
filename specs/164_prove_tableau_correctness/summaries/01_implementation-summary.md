# Implementation Summary: Tableau Correctness Theorems

- **Task**: 164 - Prove tableau correctness theorem for decision procedure
- **Status**: PARTIAL
- **Phases Completed**: 3 fully (1, 2, 3), 1 blocked (4), 1 partial (5), 1 not started (6)
- **Sessions**: sess_1780355308_a08e2f_164, sess_1780359083_872316, sess_1780361777_843697 (rounds 1-5)

## What Was Accomplished

### Phase 1: decide_sound (COMPLETED)

Proved `decide_sound : (phi : Formula) -> (d : DerivationTree FrameClass.Base [] phi) -> valid phi` in `Correctness.lean`. The proof follows immediately from the existing `soundness` theorem with empty context. Also added `decide_sound'` variant.

- **File**: `Theories/Bimodal/Metalogic/Decidability/Correctness.lean`
- **New theorems**: `decide_sound`, `decide_sound'` (both sorry-free)

### Phase 2: Propositional/Modal Saturation Invariants (COMPLETED)

Resolved all propositional and modal saturation sorry sites:

1. **sat_imp_neg** (sorry-free): F(psi -> chi) cannot exist in a saturated branch because `impNeg` always applies. Proved via `impNeg_not_expanded` helper.

2. **sat_box_neg** (sorry-free): F(box phi) cannot exist in a saturated branch because `boxNeg` always applies. Proved via `boxNeg_not_expanded` helper.

3. **sat_box_pos** (sorry-free): T(box phi) in a saturated branch implies T(phi) at all known worlds. Proved using `List.findSome?_eq_none_iff` to extract `boxPos` rule result individually, showing the filterMap is empty (all worlds already have the formula).

4. **truthLemma_pos imp case** (sorry-free): T(psi -> chi) cannot exist in a saturated branch because `impPos` always applies (branching rule). Proved via `impPos_not_expanded` helper.

### Phase 3: Temporal Saturation Invariants (COMPLETED -- Rounds 2-5)

**Round 2 progress:**
- **sat_untl_pos** (sorry-free): Proved vacuously via `untlPos_not_expanded`.
- **sat_snce_pos** (sorry-free): Proved vacuously via `sncePos_not_expanded`.
- **truthLemma_pos untl/snce** (sorry-free): Also vacuous by same argument.

**Round 3 progress:**
- Threaded `TimeOrdering` through `ExpandedTableau.hasOpen` (architectural fix)
- Changed `sat_untl_neg`/`sat_snce_neg` signatures to quantify over `timeOrd.futureOf/pastOf` instead of `b.knownTimes`

**Round 4 progress:**
- Added `@[simp]` lemmas for `RuleResult` constructors
- Identified root cause: filter predicate form mismatch (`!(a||b)` vs `!a && !b`)

**Round 5 progress (COMPLETED):**
- **FILTER PREDICATE REFACTOR**: Changed `applyRule` in Tableau.lean from `!(branch.contains negEvent || branch.contains negGuard)` to `!branch.contains negEvent && !branch.contains negGuard` at lines 747 and 772 (untlNeg and snceNeg cases). Semantically identical (De Morgan's law) but eliminates normalization mismatch.

- **sat_untl_neg** (sorry-free): Proved via:
  1. Extract `isApplicable = true` for `.untlNeg` from `findApplicableRule = none`
  2. Extract `applyRule .untlNeg` must return `.notApplicable` (by match on RuleResult constructors: linear/branching/persistent all give `some`, contradicting `= none`)
  3. Unfold `applyRule` + `asUntil?` to get filter/match structure
  4. Show filter list non-empty (t' passes predicate via `hNotContainsE`, `hNotContainsG`)
  5. Rewrite cons case in hypothesis, get `branching = notApplicable` contradiction via `simp`

- **sat_snce_neg** (sorry-free): Mirror proof using `asSince?`/`pastOf`

### Phase 5: Blocking Correctness (PARTIAL)

1. **subformula_property** (sorry-free): Proved trivially -- the theorem as stated only covers the initial branch `[F(phi)]`, where the only formula is `phi` itself.

2. **blocking_sound** (sorry-free): If `expandBranchWithFuel` returns an open branch, that branch has `findClosure = none`. Proved via `expandBranchWithFuel_sound` with induction on fuel.

3. **blocking_terminates**: Still sorry. Requires generalized subformula property for expanded branches, pigeonhole argument over time types, and Fintype infrastructure.

### Helper Lemmas Added

**From Phase 2 (prior sessions)**:
- `findUnexpanded_none_all_expanded`: Bridge from `findUnexpanded b timeOrd = none` to per-formula `isExpanded`
- `expanded_iff_no_applicable`: Equivalence between `isExpanded` and `findApplicableRule = none`
- `contains_iff_mem`: Bridge between `Branch.contains` (Bool) and list membership (Prop)
- `impNeg_not_expanded`, `impPos_not_expanded`, `boxNeg_not_expanded`: Vacuity lemmas (generalized to any timeOrd)
- `untlPos_not_expanded`, `sncePos_not_expanded`: Temporal positive vacuity (generalized)

**From Phase 5 (prior sessions)**:
- `tryBranch_inr`: Fold step preserves findClosure invariant
- `foldl_preserves_findClosure`: Foldl preserves findClosure invariant
- `expandBranchWithFuel_sound`: General soundness of expansion (induction on fuel)

## Sorry Site Accounting

| File | Before (start) | After round 2 | After rounds 3-4 | After round 5 | Resolved |
|------|----------------|----------------|-------------------|----------------|----------|
| Correctness.lean | 0 | 0 | 0 | 0 | +2 theorems |
| CountermodelExtraction.lean | 9 | 4 | 4 | 2 | 7 |
| Saturation.lean | 3 | 1 | 1 | 1 | 2 |
| Tableau.lean | 0 | 0 | 0 | 0 | +3 simp lemmas, filter refactor |
| **Total** | **12** | **5** | **5** | **3** | **9** |

## What Remains (3 sorry sites)

### CountermodelExtraction.lean (2 sorry sites)

**BLOCKED** (requires propagation tracking):
- `truthLemma_neg` untl (L834): `sat_untl_neg` gives `F(event) OR F(guard)` at each immediate successor, but for direct successors with only `F(guard)`, the Until condition `branchTruth event t'` cannot be negated. The structural IH cannot be applied to `untl event guard` at a different time point. Requires F(U(event,guard)) propagation tracking through transitive closure.
- `truthLemma_neg` snce (L838): Mirror of untl blocker.

### Saturation.lean (1 sorry site)

- `blocking_terminates` (L663): Pigeonhole argument over time types (deferred)

## Proof Strategy for sat_untl_neg (COMPLETED in Round 5)

The proof follows the same pattern as `sat_box_pos` but adds a crucial intermediate step:

1. From saturation, extract `findApplicableRule = none` via `findUnexpanded_none_all_expanded`
2. Use `List.findSome?_eq_none_iff` to extract `untlNeg` rule's lambda returns `none`
3. Simplify `isApplicable` to true (since `guard != top` via `asUntil?`)
4. **Extract notApplicable**: Use `by_contra` + `match` on `RuleResult` to show `applyRule .untlNeg ...`.1 = .notApplicable. The non-notApplicable cases (linear/branching/persistent) would make the lambda return `some(...)`, contradicting `= none`.
5. **Unfold applyRule**: `unfold applyRule at hNA; simp only [asUntil?, hg', ite_false, Bool.false_eq_true] at hNA`
6. **Filter contradiction**: Show `t'` passes the filter predicate (both contains are false), so filter is non-empty (`List.exists_cons_of_ne_nil`). Rewrite cons case in hypothesis, then `simp` closes (branching.fst != notApplicable).

**Key insight (Round 5)**: The filter predicate refactor from `!(a || b)` to `!a && !b` in Tableau.lean was essential. After `simp` normalization, goals naturally contain `!a && !b` but the old definition had `!(a || b)`, creating an unbridgeable syntactic gap that blocked rounds 3-4.

## truthLemma_neg untl/snce Blocker Analysis

The `truthLemma_neg` untl case requires proving `¬branchTruth (untl event guard)`, i.e., for all future times `t'`, either event is false at `t'` or guard fails at some intermediate time. The `branchTruth` definition uses `isTimeOrderedBefore` (transitive closure), while `sat_untl_neg` only covers immediate successors (`futureOf`).

**Problematic case**: `t'` is a direct successor with only `F(guard)` in branch (not `F(event)`). The guard fails at `t'` by IH, but `t'` is the Until witness endpoint -- guard failure at the endpoint doesn't break the Until condition (guard only needs to hold at strictly intermediate times). And event could be true at `t'`.

**Possible solutions**:
- (a) Auxiliary induction over time ordering tracking `F(U(event,guard))` membership
- (b) Stronger saturation invariant: `F(event) OR (F(guard) AND F(U(event,guard)))` at each future time
- (c) Modify `branchTruth` for `untl` to use `futureOf` instead of `isTimeOrderedBefore`
- (d) Add `F(event)` to branch 2 of `untlNeg` rule

## Build Status

Full `lake build` passes with no new errors.

## Plan Deviations

- Phase 1 Task 1.1: Altered -- simplified `decide_sound` signature to take derivation tree directly
- Phase 2 Task 2.3: Altered -- used `List.findSome?_eq_none_iff` instead of simp-based unfolding
- Phase 2 Bonus: Added truthLemma_pos imp case (not in original plan)
- Phase 3 sat_untl_pos/sat_snce_pos: Altered -- proved vacuously (formulas can't exist in saturated branch)
- Phase 3 sat_untl_neg/sat_snce_neg: Altered -- changed conclusion from `b.knownTimes` to `timeOrd.futureOf/pastOf`; filter refactored to eliminate normalization mismatch; proofs completed in round 5
- Phase 4 truthLemma_neg untl/snce: Blocked -- requires F(U(event,guard)) propagation tracking
- Phase 5 subformula_property: Altered -- theorem as stated only covers initial branch, proved trivially
- Phase 5 blocking_sound: Completed -- full induction with foldl helper lemmas
- Phase 5 blocking_terminates: Deferred -- needs generalized subformula property

## Key Proof Technique: List.findSome?_eq_none_iff

The breakthrough for persistent rule proofs (Phase 2-3) was using `List.findSome?_eq_none_iff` instead of unfolding the entire 20+ rule list via `simp`. This lemma states:

```
List.findSome? f l = none <-> forall x in l, f x = none
```

Applied to `findApplicableRule`:
1. From `isExpanded sf b = true`, extract `findApplicableRule sf b = none`
2. Apply `List.findSome?_eq_none_iff` to get: for every rule in the list, the lambda returns `none`
3. Instantiate with the specific rule of interest (e.g., `.boxPos`, `.untlNeg`)
4. Since `isApplicable` is true for the target rule, `applyRule` must have returned `notApplicable`
5. Extract the semantic consequence (e.g., filterMap is empty for persistent rules)
