# Implementation Summary: Tableau Correctness Theorems

- **Task**: 164 - Prove tableau correctness theorem for decision procedure
- **Status**: PARTIAL
- **Phases Completed**: 1 fully, 2 substantially, 2 partially
- **Sessions**: sess_1780355308_a08e2f_164, sess_1780359083_872316, sess_1780361777_843697 (rounds 1-4)

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

### Phase 3: Temporal Saturation Invariants (PARTIAL -- Round 3 Progress)

**Round 2 progress:**
- **sat_untl_pos** (sorry-free): Proved vacuously via `untlPos_not_expanded`.
- **sat_snce_pos** (sorry-free): Proved vacuously via `sncePos_not_expanded`.
- **truthLemma_pos untl/snce** (sorry-free): Also vacuous by same argument.

**Round 3 progress (this session):**

1. **ARCHITECTURAL FIX COMPLETED**: Threaded `TimeOrdering` through `ExpandedTableau.hasOpen`.
   - Reordered constructor fields: `hasOpen (openBranch : Branch) (timeOrdering : TimeOrdering) (saturated : findUnexpanded openBranch (timeOrd := timeOrdering) = none)`
   - Updated `buildTableau` and `expandBranchesWithFuel` to pass real ordering to `findUnexpanded`
   - Updated ALL saturation invariant signatures to accept `(timeOrd : TimeOrdering)`
   - Updated `truthLemma_neg` to accept `(hOrd : cm.timeOrdering = timeOrd)`
   - Updated all downstream pattern matches across 4 files
   - **This resolves the architectural blocker** that prevented proving `sat_untl_neg` and `sat_snce_neg`

2. **SIGNATURE CHANGE**: `sat_untl_neg` now quantifies over `timeOrd.futureOf t` (real future times from expansion) instead of `b.knownTimes` (all times in branch). Similarly `sat_snce_neg` quantifies over `timeOrd.pastOf t`.

3. **Still sorry**: `sat_untl_neg`, `sat_snce_neg` proofs. The signatures are correct and the blocker is removed. The proof strategy (case-splitting on `applyRule` result, showing the notApplicable case contradicts the filter being non-empty) is identified but not yet mechanized due to complexity of unfolding `applyRule` in Lean.

**Round 4 progress:**
- Added `@[simp]` lemmas `RuleResult.branching_ne_notApplicable`, `linear_ne_notApplicable`, `persistent_ne_notApplicable` to Tableau.lean
- Fixed `set_option`/docstring ordering bug (`set_option` must precede docstring in Lean 4)
- Established proof structure: `set result_pair; cases result` works for the non-notApplicable cases
- Identified root cause for `notApplicable` case: **filter predicate form mismatch** -- `applyRule` uses `!(a||b)` but after `simp` normalization the goal has `!a && !b` (De Morgan). `generalize`/`rw`/`simp only` cannot bridge this gap because the anonymous lambdas are syntactically different
- Recommended fix: refactor `applyRule` to use `!a && !b` natively, eliminating the mismatch at source

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

| File | Before (start) | After round 2 | After round 3 | After round 4 | Resolved |
|------|----------------|----------------|----------------|----------------|----------|
| Correctness.lean | 0 | 0 | 0 | 0 | +2 theorems |
| CountermodelExtraction.lean | 9 | 4 | 4 | 4 | 5 |
| Saturation.lean | 3 | 1 | 1 | 1 | 2 |
| Tableau.lean | 0 | 0 | 0 | 0 | +3 simp lemmas |
| **Total** | **12** | **5** | **5** | **5** | **7** |

## What Remains (5 sorry sites)

### CountermodelExtraction.lean (4 sorry sites)

**Unblocked** (architectural fix complete, proofs needed):
- `sat_untl_neg` (L634): Now quantifies over `timeOrd.futureOf t`
- `sat_snce_neg` (L649): Now quantifies over `timeOrd.pastOf t`
- `truthLemma_neg` untl (L758): Depends on sat_untl_neg
- `truthLemma_neg` snce (L762): Depends on sat_snce_neg

### Saturation.lean (1 sorry site)

- `blocking_terminates` (L663): Pigeonhole argument over time types

## Proof Strategy for sat_untl_neg

The proof follows the same pattern as `sat_box_pos` but for temporal rules:

1. From saturation, extract `findApplicableRule = none` via `findUnexpanded_none_all_expanded`
2. Use `List.findSome?_eq_none_iff` to extract that `untlNeg` rule's lambda returns `none`
3. Simplify `isApplicable` (true since `guard != top` via `asUntil?`)
4. Case-split on `applyRule .untlNeg ...` result:
   - `notApplicable`: Means the filter `(timeOrd.futureOf t).filter (fun t'' => !(contains event || contains guard))` is `[]`. But if any `t'` lacks both `F(event)` and `F(guard)`, it passes the filter, making the list non-empty. Contradiction.
   - `linear/branching/persistent`: Lambda returns `some(...)`, contradicting `= none`.

The challenge is mechanizing step 4.notApplicable: after unfolding `applyRule`, the goal contains a complex match on the filter list. The `split at hRule` tactic or manual case analysis on the filter list should work, but the syntactic form of the unfolded expression needs careful matching.

## Build Status

Full `lake build` passes with no new errors. Pre-existing errors in `ChronicleToCountermodel` and Mathlib are unrelated.

## Plan Deviations

- Phase 1 Task 1.1: Altered -- simplified `decide_sound` signature to take derivation tree directly
- Phase 2 Task 2.3: Altered -- used `List.findSome?_eq_none_iff` instead of simp-based unfolding
- Phase 2 Bonus: Added truthLemma_pos imp case (not in original plan)
- Phase 3 sat_untl_pos/sat_snce_pos: Altered -- proved vacuously (formulas can't exist in saturated branch)
- Phase 3 sat_untl_neg/sat_snce_neg: Altered -- changed conclusion from `b.knownTimes` to `timeOrd.futureOf/pastOf`; architectural fix completed but proofs still sorry
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
