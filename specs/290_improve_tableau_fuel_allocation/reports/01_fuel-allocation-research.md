# Research Report: Improve Tableau Fuel Allocation Heuristic

**Task**: 290 — Improve tableau fuel allocation heuristic for imbalanced branches
**Session**: sess_1780943005_25629c_290
**Date**: 2026-06-08

---

## 1. Executive Summary

This report investigates the current fuel allocation mechanics in the tableau decision procedure and evaluates the feasibility of an `estimateBranchDifficulty` heuristic for proportional fuel allocation. The key finding is that the current uniform `fuel / n` division at splits is simple and termination-safe, but structurally blind -- it allocates equal fuel to branches regardless of their formula composition. A difficulty-weighted allocation can improve timeout rates for formulas with imbalanced branching, but the design must preserve the termination invariant `branchFuel < fuel` for all sub-branches.

**Key findings**:
1. Fuel is decremented once per expansion step (`fuel + 1` match) and divided uniformly at splits (`fuel / max(1, n)`)
2. The initial fuel is always 500 in the production pipeline (`decideAutoAdaptive`), not the FMP-derived `soundFuel`
3. All branching rules create exactly 2 sub-branches, so the current division is always `fuel / 2`
4. The c6 timeout rate is ~1.6% (96 of 5,931 formulas) post-task 284, potentially reduced to ~1.1% after task 288
5. Proportional fuel allocation is termination-safe as long as each sub-branch receives at most `fuel - 1` fuel
6. Three metrics are readily available for difficulty estimation: temporal operator count, modal depth, and branch size

---

## 2. Current Fuel Mechanics

### 2.1 How fuel works in `expandBranchWithFuel`

**File**: `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`, lines 144-194

The function signature is:
```lean
def expandBranchWithFuel (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty)
    (applied : AppliedSet := {})
    : Option (ClosedBranch ⊕ (Branch × TimeOrdering × AppliedSet))
```

Fuel behavior:
- **Base case** (`fuel = 0`): Returns `none` (out of fuel / timeout)
- **Recursive case** (`fuel + 1`): Performs one expansion step using the inner `fuel` value
- **Linear extension** (`.extended`): Recurses with `fuel` (one less than the matched `fuel + 1`)
- **Split** (`.split branches`): Divides fuel equally among sub-branches as `fuel / (max 1 branches.length)`
- **Termination**: `termination_by fuel` with `decreasing_by exact Nat.lt_succ_of_le (Nat.div_le_self fuel (max 1 branches.length))`

The critical observation: at each split, each sub-branch gets `fuel / n` where `n = branches.length`. Since `fuel / n <= fuel` by `Nat.div_le_self`, and we need `branchFuel < fuel + 1`, the termination proof holds via `Nat.lt_succ_of_le`.

### 2.2 How initial fuel is determined

Three fuel computation mechanisms exist:

1. **`recommendedFuel`** (deprecated): `10 * complexity + 100` — ad hoc heuristic
2. **`soundFuel`**: `min (n * 2^n) 100000` where `n = |subformulaClosure(phi)|` — FMP-derived bound
3. **`decideAutoAdaptive`** (production): Fixed **fuel = 500** — task 264 confirmed a strictly bimodal decision landscape where formulas either resolve at fuel=500 or not at all

The production pipeline (`labelFormulaImpl`) calls `decideAutoAdaptive`, which always uses fuel=500. The `soundFuel` is used only in `decideAuto` and `buildTableauAuto`.

### 2.3 Current fuel distribution at splits

At every split, the code computes:
```lean
let branchFuel := fuel / (max 1 branches.length)
```

Examining all branching rules in `Tableau.lean` (lines 326-873):
- `andNeg`: 2 branches (`F(A /\ B) -> F(A) | F(B)`)
- `orPos`: 2 branches (`T(A \/ B) -> T(A) | T(B)`)
- `impPos`: 2 branches (`T(A -> B) -> F(A) | T(B)`)
- `untlPos`: 2 branches (event-witness | guard+continue)
- `sncePos`: 2 branches (event-witness | guard+continue)
- `untlNeg`: 2 branches (Reynolds co-decomposition)
- `snceNeg`: 2 branches (Reynolds co-decomposition)

**All branching rules produce exactly 2 sub-branches.** The current allocation is therefore always `fuel / 2`, giving each branch half the remaining fuel.

### 2.4 The split iteration strategy

In the split case, branches are processed via `List.foldl`:
```lean
branches.foldl tryBranch (some (.inl dummy))
```
where `tryBranch` short-circuits on the first open branch found. This means:
- The **first sub-branch** is always explored
- The **second sub-branch** is only explored if the first one closes
- If the first branch times out (returns `none`), the result is `none` regardless of the second branch

This asymmetry is important: the first branch in the list gets preferential treatment in that it is always tried, while the second only runs if the first closes. Fuel allocation should account for this.

---

## 3. Structural Properties Predicting Branch Difficulty

### 3.1 Available metrics on Formula

The codebase already provides several metrics:

| Metric | Function | Location | Description |
|--------|----------|----------|-------------|
| `complexity` | `Formula.complexity` | Formula.lean:170 | Structural connective count (pattern-aware for derived ops) |
| `modalDepth` | `Formula.modalDepth` | Formula.lean:332 | Max nesting of box operators |
| `temporalDepth` | `Formula.temporalDepth` | Formula.lean:353 | Max nesting of untl/snce operators |
| `countImplications` | `Formula.countImplications` | Formula.lean:373 | Count of implication operators |
| `atoms` | `Formula.atoms` | Formula.lean:700 | Set of propositional atoms |

### 3.2 Available metrics on Branch/SignedFormula

| Metric | Function | Location | Description |
|--------|----------|----------|-------------|
| `totalComplexity` | `Branch.totalComplexity` | SignedFormula.lean:292 | Sum of complexities |
| `unexpandedComplexity` | `unexpandedComplexity` | SignedFormula.lean:918 | Work remaining per SF |
| `branchUnexpandedComplexity` | `branchUnexpandedComplexity` | SignedFormula.lean:932 | Total unexpanded work |
| `knownWorlds` | `Branch.knownWorlds` | SignedFormula.lean:299 | Distinct world indices |
| `knownTimes` | `Branch.knownTimes` | SignedFormula.lean:342 | Distinct time indices |
| `untlNegFormulas` | `Branch.untlNegFormulas` | SignedFormula.lean:406 | Negative Until formulas |
| `snceNegFormulas` | `Branch.snceNegFormulas` | SignedFormula.lean:417 | Negative Since formulas |

### 3.3 What predicts difficulty

Based on the tableau rule analysis, the main sources of difficulty are:

1. **Temporal operator count** (Until/Since formulas): These create fresh time points and branching. Each positive Until/Since creates 2 branches AND a new time point. Negative Until/Since create persistent co-decomposition at every future/past time. More temporal operators = exponentially more branching.

2. **Modal depth** (Box/Diamond nesting): Each box-negative or diamond-positive rule creates a fresh world with auto-propagation of ALL existing box/diamond formulas. Deep modal nesting leads to many world-creating steps.

3. **Branch size** (number of signed formulas): Larger branches take more time per step due to `List.contains` checks, `filter` operations, and the `findUnexpanded` scan. This is a per-step cost multiplier, not a branching factor.

4. **Number of existing time points** (from `knownTimes`): More time points mean more targets for persistent temporal rule propagation, increasing the per-step cost.

5. **Eventuality count** (pending eventualities): Unfulfilled Until/Since eventualities delay blocking, requiring more expansion before termination.

---

## 4. Design of `estimateBranchDifficulty`

### 4.1 Proposed heuristic

```lean
/-- Estimate the expansion difficulty of a branch.
    Higher values indicate branches likely to require more fuel. -/
def estimateBranchDifficulty (b : Branch) : Nat :=
  let temporalCount := b.foldl (fun acc sf =>
    match sf.formula with
    | .untl _ _ => acc + 3   -- Until creates branching + fresh time
    | .snce _ _ => acc + 3   -- Since creates branching + fresh time
    | _ => acc) 0
  let modalCount := b.foldl (fun acc sf =>
    match sf.formula with
    | .box _ => acc + 2      -- Box propagates to all worlds
    | _ =>
      match sf.formula with
      | .imp (.box (.imp _ .bot)) .bot => acc + 2  -- Diamond creates fresh world
      | _ => acc) 0
  let sizeWeight := b.length / 4   -- Branch size as minor factor
  1 + temporalCount + modalCount + sizeWeight
```

The function returns a positive natural number (minimum 1) representing estimated difficulty. The weights (3 for temporal, 2 for modal, 1/4 for size) reflect the relative branching impact of each operator type.

### 4.2 Proportional fuel allocation

At a split with branches `[b1, b2]` and remaining fuel `fuel`:

```lean
let d1 := estimateBranchDifficulty b1
let d2 := estimateBranchDifficulty b2
let total := d1 + d2
-- Allocate proportionally, ensuring each gets at least 1 and at most fuel-1
let raw1 := fuel * d1 / total
let raw2 := fuel * d2 / total
let fuel1 := max 1 (min raw1 (fuel - 1))
let fuel2 := max 1 (min raw2 (fuel - 1))
```

For the general case with `n` branches:
```lean
let difficulties := branches.map estimateBranchDifficulty
let totalDifficulty := difficulties.foldl (· + ·) 0
let allocations := difficulties.map fun d =>
  max 1 (min (fuel * d / max 1 totalDifficulty) (fuel - 1))
```

### 4.3 Impact analysis for 2-branch splits

Since all current splits produce exactly 2 branches, the allocation simplifies to distributing fuel between two branches. Key scenarios:

1. **Balanced branches** (d1 = d2): Each gets `fuel / 2` — same as current behavior
2. **Imbalanced branches** (e.g., d1 = 3, d2 = 1): Branch 1 gets `3/4 * fuel`, Branch 2 gets `1/4 * fuel`
3. **Highly imbalanced** (e.g., temporal vs. propositional): The temporal branch could get up to ~75% of fuel

**Example**: For `T(U(p, q))` expansion (untlPos rule):
- Branch 1 (event): `[T(p) @ t']` — simple, difficulty ~1
- Branch 2 (guard+continue): `[T(q) @ t', T(U(p,q)) @ t']` — recursive, difficulty ~4
- Current: each gets `fuel / 2`
- Proposed: Branch 1 gets `fuel / 5`, Branch 2 gets `4 * fuel / 5`

This is exactly the right behavior: the guard+continue branch needs more fuel because it carries the recursive Until obligation.

---

## 5. Termination Implications

### 5.1 Current termination proof

The termination proof has two components:
1. **`termination_by fuel`**: Lean's structural recursion uses `fuel` as the decreasing measure
2. **`decreasing_by`**: For the split case, the proof obligation is `branchFuel < fuel + 1`
   - Current proof: `exact Nat.lt_succ_of_le (Nat.div_le_self fuel (max 1 branches.length))`
   - This works because `fuel / n <= fuel` for any `n >= 1`

### 5.2 Requirements for proportional allocation

For termination to hold with proportional allocation, we need:
- **For each sub-branch `i`**: `allocatedFuel_i < fuel + 1`, i.e., `allocatedFuel_i <= fuel`

This is satisfied as long as:
1. `allocatedFuel_i <= fuel` for all `i`
2. For the `extended` (linear) case, `fuel < fuel + 1` still holds (unchanged)

The proposed allocation ensures `min raw (fuel - 1)` which gives `allocatedFuel <= fuel - 1 < fuel + 1`.

### 5.3 Proof adjustment needed

The `decreasing_by` block would change from:
```lean
exact Nat.lt_succ_of_le (Nat.div_le_self fuel (max 1 branches.length))
```
to:
```lean
exact Nat.lt_succ_of_le (Nat.min_le_right _ fuel)
-- or more precisely: the min(..., fuel) bound ensures allocatedFuel <= fuel
```

**Critical constraint**: The `foldl tryBranch` pattern means each branch's fuel allocation must be a compile-time-predictable expression of `fuel` and `branches` for the termination checker. Since the allocation depends on `estimateBranchDifficulty` applied to each branch, and these values are not available in the `termination_by` measure, we may need to restructure.

**Solution**: Instead of using `foldl`, use a helper function that explicitly passes `fuel` and `branchIndex` and proves `allocatedFuel branchIndex < fuel + 1` for each index. Alternatively, keep the `foldl` pattern but compute allocation BEFORE the fold and store it in a list, then use the list elements (which are all `<= fuel`) in the recursive calls.

### 5.4 Soundness proof impact

The `expandBranchWithFuel_sound` theorem (lines 1029-1065) uses strong induction on fuel. The proof structure is:
```lean
induction fuel using Nat.strongRecOn with
| _ n ih => ...
  exact foldl_preserves_findClosure (k / (max 1 branches.length)) ...
    (ih _ hbf) ...
```

With proportional allocation, the `k / (max 1 branches.length)` would be replaced by the allocated fuel for each branch. Since each allocated fuel is `<= k` (which is `fuel - 1`), the strong induction hypothesis `ih` applies to each. However, the `foldl_preserves_findClosure` helper would need adjustment because it currently assumes a SINGLE fuel value shared across all branches in the fold. With proportional allocation, different branches have different fuel values.

**Approach**: Either (a) use the max of allocated fuels in the fold helper, or (b) restructure to not use `foldl` at all (iterate explicitly with per-branch fuel). Option (b) is simpler for the proof but changes the code structure more.

### 5.5 Impact on traced expansion

`expandBranchWithFuel_tracedImpl` (lines 277-332) mirrors the exact structure of `expandBranchWithFuel` and must be updated in parallel. It has the same termination proof structure.

---

## 6. Current c6 Timeout Data

### 6.1 Baseline numbers (post-task 284)

From the task 288 research report (Section 6):

| Metric | Value |
|--------|-------|
| c6 total formulas | 5,931 |
| c6 valid (incl. prefiltered) | ~596 |
| c6 invalid | ~5,239 |
| c6 timeout | 96 |
| c6 timeout rate | ~1.6% |

### 6.2 Post-task 288 (estimated)

Task 288 added structural invalid prefilters:
- Conservative estimate: 66 timeouts remaining (~1.1%)
- Optimistic estimate: 46 timeouts remaining (~0.8%)

### 6.3 Remaining timeout patterns

All 96 remaining timeouts are of the form `box(U(X,Y)) -> Z` or `box(S(X,Y)) -> Z` where X is not bot. These are "fast timeouts" (0-1ms at fuel=500), meaning the tableau exhausts fuel quickly due to exponential branching from the Until/Since inside the box.

### 6.4 Expected impact of fuel reallocation

The remaining timeouts involve formulas with a box wrapping an Until/Since. When the tableau expands these:
1. `F(box(U(X,Y)) -> Z)` produces `T(box(U(X,Y)))` and `F(Z)`
2. `T(box(U(X,Y)))` via boxPos propagates `T(U(X,Y))` to all worlds
3. `T(U(X,Y))` via untlPos creates 2 branches with a fresh time point
4. The event branch (Branch 1) is simpler, the guard+continue branch (Branch 2) is harder

With proportional allocation, Branch 2 (carrying the recursive Until) would get more fuel, while Branch 1 (just the event witness) would get less. This could allow more timeout formulas to be decided within the same total fuel budget.

**Estimated impact**: 2-5% relative reduction in remaining timeouts, i.e., catching 2-5 additional formulas out of the 96 (or 46-66 post-task 288). This is a modest improvement because the dominant cost is not branch imbalance but the exponential blowup from nested temporal-modal interaction.

---

## 7. Existing Reusable Infrastructure

### 7.1 Formula metrics (directly reusable)

- `Formula.complexity` (pattern-aware, handles derived operators)
- `Formula.modalDepth` (max box nesting)
- `Formula.temporalDepth` (max untl/snce nesting)
- `Formula.countImplications` (imp operator count)
- `Formula.atoms` (propositional atom set)

### 7.2 Branch metrics (directly reusable)

- `Branch.totalComplexity` (sum of formula complexities)
- `branchUnexpandedComplexity` (unexpanded work remaining)
- `Branch.knownWorlds` / `Branch.knownTimes` (structural extent)
- `Branch.untlNegFormulas` / `Branch.snceNegFormulas` (temporal obligation count)

### 7.3 Trace infrastructure (for benchmarking)

- `expandBranchWithFuel_traced` returns a `ProofCertificate` with full expansion trace
- `TraceEntry.ruleFired` records rule type, source formula, and branch depth
- Can be used to profile fuel consumption per branch for empirical validation

---

## 8. Implementation Approach

### 8.1 Recommended plan structure

**Phase 1**: Define `estimateBranchDifficulty` in `SignedFormula.lean` or `Saturation.lean`
- Pure function `Branch -> Nat`, counting temporal/modal/size metrics
- Unit tests verifying expected difficulty ordering

**Phase 2**: Implement proportional fuel allocation in `expandBranchWithFuel`
- Replace `let branchFuel := fuel / (max 1 branches.length)` with difficulty-weighted allocation
- Ensure `allocatedFuel <= fuel` for all branches (termination safety)
- Update `decreasing_by` proof accordingly

**Phase 3**: Mirror changes in `expandBranchWithFuel_tracedImpl`
- Same allocation logic in the traced variant
- Verify termination proof compiles

**Phase 4**: Update soundness proof `expandBranchWithFuel_sound`
- Adjust `foldl_preserves_findClosure` helper for per-branch fuel
- Update strong induction argument

**Phase 5**: Benchmark on c6
- Run `labelBatch` on c6 formula set before and after
- Compare timeout counts and decision times
- Profile with traced variant to see fuel distribution

### 8.2 Risk assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Termination proof breaks | Medium | High | Pre-allocate fuels, use min bound |
| Soundness proof breaks | Medium | High | Keep foldl structure, adjust helper |
| Regression (more timeouts) | Low | Medium | Benchmark before/after, rollback |
| No measurable improvement | Medium | Low | Task is still useful for code quality |
| Proof overhead (heartbeats) | Low | Medium | Increase maxHeartbeats if needed |

### 8.3 Alternative approaches considered

1. **Fuel-free termination**: Use the subformula property for well-founded recursion instead of fuel. This is the "correct" approach but requires extensive proof work (the `blocking_terminates` theorem is still unproven).

2. **Adaptive fuel escalation**: Start with low fuel, re-try with more if timeout. This is what `decideAutoAdaptive` previously did with multi-tier escalation, but task 264 showed the second and third tiers never helped.

3. **Branch ordering optimization**: Instead of changing fuel allocation, reorder branches so the "easier" branch is tried first. Since the fold short-circuits on open branches, trying the easier branch first means timeouts on the harder branch are less wasteful. This is complementary to fuel reallocation and could be combined.

---

## 9. Answers to Research Questions

### Q1: How does fuel currently work in `expandBranchWithFuel`?

Fuel is a `Nat` parameter decremented by 1 at each expansion step (via `fuel + 1` pattern match). At `fuel = 0`, the function returns `none` (timeout). For splits, fuel is divided equally among sub-branches as `fuel / max(1, n)`. See Section 2.1.

### Q2: How is the initial fuel value determined?

The production pipeline uses a fixed `fuel = 500` via `decideAutoAdaptive`. The FMP-derived `soundFuel` (n * 2^n capped at 100000) is available but only used in `decideAuto`. See Section 2.2.

### Q3: When branches split, how is fuel distributed?

Currently distributed uniformly: `fuel / max(1, branches.length)`. Since all branching rules produce exactly 2 sub-branches, this is always `fuel / 2`. See Section 2.3.

### Q4: What structural properties predict difficulty?

Temporal operator count (highest impact due to time point creation + branching), modal depth (world creation), branch size (per-step cost), and eventuality count (delays blocking). See Section 3.3.

### Q5: How would `estimateBranchDifficulty` work?

A weighted sum of temporal formula count (weight 3), modal formula count (weight 2), and branch size (weight 1/4), with minimum value 1. See Section 4.1.

### Q6: What are the termination implications?

The termination proof requires `allocatedFuel < fuel + 1` for all sub-branches. Proportional allocation satisfies this with a `min(allocated, fuel - 1)` cap. The proof adjustment is straightforward but the soundness proof helper `foldl_preserves_findClosure` needs modification for per-branch fuel values. See Section 5.

### Q7: What is the current c6 timeout rate?

96 of 5,931 formulas (~1.6%) after task 284, potentially reduced to 46-66 after task 288 (~0.8-1.1%). See Section 6.

### Q8: Are there existing complexity or size metrics on Formula that could be reused?

Yes: `Formula.complexity`, `Formula.modalDepth`, `Formula.temporalDepth`, `Formula.countImplications`, `Branch.totalComplexity`, `branchUnexpandedComplexity`. See Section 7.

---

## 10. Tactic Survey Results

Not directly applicable for this research task since the implementation involves defining new functions and modifying fuel allocation logic rather than proving mathematical theorems. However, the termination and soundness proofs will likely use:

| Proof Goal | Expected Tactics | Notes |
|-----------|-----------------|-------|
| `allocatedFuel <= fuel` | `Nat.min_le_right`, `Nat.le_of_min` | Termination bound |
| `foldl preserves invariant` | `induction branches`, `simp` | Soundness helper |
| Strong induction step | `Nat.strongRecOn`, `ih` application | Main soundness |
| `branchFuel < fuel + 1` | `Nat.lt_succ_of_le`, `omega` | Decreasing measure |

---

## 11. Recommendations

1. **Proceed with implementation** -- the proportional allocation is sound and the code changes are localized to `Saturation.lean`
2. **Start with the simplest heuristic** -- temporal count only, since temporal operators are the primary source of branching complexity
3. **Preserve the existing proof structure** -- modify `foldl_preserves_findClosure` rather than rewriting the fold pattern
4. **Combine with branch ordering** -- try the simpler branch first to maximize the chance of short-circuit evaluation
5. **Benchmark empirically** -- use the traced expansion to validate that fuel is better distributed before and after the change
