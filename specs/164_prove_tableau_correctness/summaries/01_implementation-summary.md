# Implementation Summary: Tableau Correctness Theorems

- **Task**: 164 - Prove tableau correctness theorem for decision procedure
- **Status**: PARTIAL
- **Phases Completed**: 1 fully, 2 substantially, 2 partially
- **Sessions**: sess_1780355308_a08e2f_164, sess_1780359083_872316

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

### Phase 3: Temporal Saturation Invariants (PARTIAL)

Key discovery: T(U(event, guard)) and T(S(event, guard)) CANNOT exist in a saturated branch. For any guard value, either `someFuturePos`/`somePastPos` (guard = top) or `untlPos`/`sncePos` (guard != top) is a consumable rule that removes the formula.

1. **sat_untl_pos** (sorry-free): Proved vacuously via `untlPos_not_expanded`.
2. **sat_snce_pos** (sorry-free): Proved vacuously via `sncePos_not_expanded`.
3. **truthLemma_pos untl/snce** (sorry-free): Also vacuous by same argument.
4. **sat_untl_neg**, **sat_snce_neg**: BLOCKED (see Architectural Blocker below).
5. **truthLemma_neg untl/snce**: BLOCKED (depends on sat_untl_neg/sat_snce_neg).

### Phase 5: Blocking Correctness (PARTIAL)

1. **subformula_property** (sorry-free): Proved trivially -- the theorem as stated only covers the initial branch `[F(phi)]`, where the only formula is `phi` itself.

2. **blocking_sound** (sorry-free): If `expandBranchWithFuel` returns an open branch, that branch has `findClosure = none`. Proved via `expandBranchWithFuel_sound` with induction on fuel. Required three helper lemmas:
   - `tryBranch_inr`: The fold step function preserves the findClosure invariant
   - `foldl_preserves_findClosure`: `List.foldl` with tryBranch preserves the invariant
   - `expandBranchWithFuel_sound`: Main induction on fuel handling all code paths

3. **blocking_terminates**: Still sorry. Requires generalized subformula property for expanded branches (not just initial), pigeonhole argument over time types, and Fintype infrastructure.

### Helper Lemmas Added

**From Phase 2 (prior session)**:
- `findUnexpanded_none_all_expanded`: Bridge from `findUnexpanded b = none` to per-formula `isExpanded`
- `expanded_iff_no_applicable`: Equivalence between `isExpanded` and `findApplicableRule = none`
- `contains_iff_mem`: Bridge between `Branch.contains` (Bool) and list membership (Prop)
- `impNeg_not_expanded`, `impPos_not_expanded`, `boxNeg_not_expanded`: Vacuity lemmas

**New in this session**:
- `untlPos_not_expanded`: T(U(event, guard)) is never expanded (either someFuturePos or untlPos applies)
- `sncePos_not_expanded`: T(S(event, guard)) is never expanded (mirror)
- `tryBranch_inr`: Fold step preserves findClosure invariant
- `foldl_preserves_findClosure`: Foldl preserves findClosure invariant
- `expandBranchWithFuel_sound`: General soundness of expansion (induction on fuel)

## Sorry Site Accounting

| File | Before | After | Resolved |
|------|--------|-------|----------|
| Correctness.lean | 0 | 0 | N/A (added 2 sorry-free theorems) |
| CountermodelExtraction.lean | 9 | 4 | 5 |
| Saturation.lean | 3 | 1 | 2 |
| **Total** | **12** | **5** | **7** |

## What Remains (5 sorry sites)

### CountermodelExtraction.lean (4 sorry sites)

**Architecturally blocked** (see below):
- `sat_untl_neg` (L636): F(U(event, guard)) Reynolds co-decomposition
- `sat_snce_neg` (L650): F(S(event, guard)) co-decomposition (mirror)
- `truthLemma_neg` untl (L756): depends on sat_untl_neg
- `truthLemma_neg` snce (L760): depends on sat_snce_neg

### Saturation.lean (1 sorry site)

- `blocking_terminates` (L663): Pigeonhole argument over time types

## Architectural Blocker: Temporal Negative Saturation

The `sat_untl_neg` and `sat_snce_neg` theorems require showing that F(U(event, guard)) in a saturated branch implies F(event) or F(guard) at all known times. The proof depends on the `untlNeg`/`snceNeg` persistent rules propagating these formulas to future times.

**Root cause**: `findUnexpanded` (which defines saturation) uses `TimeOrdering.empty` by default. With empty time ordering, `timeOrd.futureOf l.time = []`, so the `untlNeg` rule sees no future times and always returns `notApplicable`. This means the saturation condition provides no information about temporal propagation -- the temporal persistent rules are trivially satisfied without actually propagating anything.

**The gap**: The actual expansion process uses a real `TimeOrdering` that grows as new times are created. The temporal rules propagate formulas during expansion using this real ordering. But the final saturation check (`findUnexpanded b = none`) forgets the ordering. The truth lemma needs the temporal propagation that only happened under the real ordering.

**Possible fixes**:
1. Thread the `TimeOrdering` through the saturation condition: Change `ExpandedTableau.hasOpen` to carry `findUnexpanded openBranch timeOrd = none` instead of `findUnexpanded openBranch = none`. This would make `sat_untl_neg` provable but requires changes to the `ExpandedTableau` type and all code that constructs it.
2. Add a separate invariant: Prove that after expansion with a real `TimeOrdering`, the branch already contains all temporal propagations. This requires tracking the expansion history.
3. Weaken the truth lemma: Only prove it for `cm.timeOrdering = TimeOrdering.empty`, which makes the temporal cases vacuously true (no ordered times means no temporal obligations). This weakens the overall completeness theorem but still works for the empty time ordering case.

## Plan Deviations

- Phase 1 Task 1.1: Altered -- simplified `decide_sound` signature to take derivation tree directly
- Phase 2 Task 2.3: Altered -- used `List.findSome?_eq_none_iff` instead of simp-based unfolding
- Phase 2 Bonus: Added truthLemma_pos imp case (not in original plan)
- Phase 3 sat_untl_pos/sat_snce_pos: Altered -- proved vacuously (formulas can't exist in saturated branch)
- Phase 3 sat_untl_neg/sat_snce_neg: Deferred -- architecturally blocked by empty time ordering
- Phase 5 subformula_property: Altered -- theorem as stated only covers initial branch, proved trivially
- Phase 5 blocking_sound: Completed -- full induction with foldl helper lemmas
- Phase 5 blocking_terminates: Deferred -- needs generalized subformula property

## Key Proof Technique: List.findSome?_eq_none_iff

The breakthrough for persistent rule proofs (Phase 2-3) was using `List.findSome?_eq_none_iff` instead of unfolding the entire 20+ rule list via `simp`. This lemma states:

```
List.findSome? f l = none ↔ ∀ x ∈ l, f x = none
```

Applied to `findApplicableRule`:
1. From `isExpanded sf b = true`, extract `findApplicableRule sf b = none`
2. Apply `List.findSome?_eq_none_iff` to get: for every rule in the list, the lambda returns `none`
3. Instantiate with the specific rule of interest (e.g., `.boxPos`, `.untlPos`)
4. Since `isApplicable` is true for the target rule, `applyRule` must have returned `notApplicable`
5. Extract the semantic consequence (e.g., filterMap is empty for persistent rules)

This avoids the exponential blowup from stepping through 20+ rules sequentially.

## Build Status

Full `lake build` passes with no new errors. All existing sorry sites compile without issues.
