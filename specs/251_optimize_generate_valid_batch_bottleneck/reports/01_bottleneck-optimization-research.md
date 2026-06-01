# Research Report: Optimize generateValidBatch O(n^2) MP Closure Bottleneck

- **Task**: 251 - Optimize generateValidBatch O(n^2) MP closure bottleneck
- **Started**: 2026-06-01T00:00:00Z
- **Effort**: Medium (algorithmic optimization in existing Lean 4 code)
- **Dependencies**: Unblocks task 217 (c9/c11 dataset generation)
- **Sources/Inputs**:
  - `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- generateValidBatch function (lines 989-1044)
  - `Theories/Bimodal/Automation/DatasetExport.lean` -- CLI pipeline calling generateFormulas
  - `specs/217_complexity_tier_extension_c9_c11/summaries/01_complexity-tier-summary.md` -- performance observations
- **Artifacts**:
  - This report: `specs/251_optimize_generate_valid_batch_bottleneck/reports/01_bottleneck-optimization-research.md`

---

## Executive Summary

The `generateValidBatch` function in `FormulaEnumerator.lean` has three compounding quadratic-or-worse bottlenecks that make it impractical for seed counts above ~500. The worst offender is the all-pairs MP closure loop (O(n^2) per round), but repeated `List.eraseDups` calls (also O(n^2)) and the use of `List` instead of `HashMap`/`HashSet` for the formula pool add significant constant-factor overhead. A combination of (1) an implication-index HashMap for O(n) MP closure, (2) replacing `eraseDups` with `HashSet`-based dedup, and (3) converting the pool from `List` to `HashSet` + `Array` can reduce the complexity from O(n^2 * rounds) to O(n * rounds) and enable 10K+ seed counts within minutes instead of hours.

---

## Current Algorithm Analysis

### Function: `generateValidBatch` (lines 989-1044)

The function operates in four phases:

**Phase 1 -- Seed Generation** (lines 993-999):
- Generates `seedCount` axiom instances via `instantiateAxiom` (IO-based, random)
- Appends 35 theorem seed formulas from `theoremSeedFormulas`
- Calls `pool.eraseDups` -- **O(n^2)** using `List.elem` for membership
- Cost: O(seedCount^2) for dedup

**Phase 2 -- Ex-falso Cap** (lines 1001-1019):
- Filters pool twice (`pool.filter isExFalso`, `pool.filter (!isExFalso)`) -- O(n) each
- If cap exceeded: generates replacement instances, appends, calls `pool.eraseDups` again -- **O(n^2)**
- Cost: O(n^2) worst case

**Phase 3 -- Fixpoint Nec/MP Closure** (lines 1021-1041):
This is the critical bottleneck. Up to 10 rounds of:

1. **Necessitation**: `pool.map generateValidFromNec` -- O(n), creates n new formulas
2. **Dedup after Nec**: `(pool ++ necFormulas).eraseDups` -- **O((2n)^2) = O(n^2)**
3. **MP closure (all-pairs)**: Nested `for phi in pool do for psi in pool do` -- **O(n^2)**
4. **Dedup after MP**: `(pool ++ mpResults).eraseDups` -- **O((n + mpResults)^2)**

**Per-round cost**: O(n^2) for MP loop + O(n^2) for eraseDups = O(n^2)
**Total Phase 3 cost**: O(n^2 * rounds) where n grows each round

**Phase 4 -- Filter** (lines 1043-1044):
- `pool.filter` -- O(n), negligible

### Concrete Cost Estimates

| seedCount | Pool after seeds | Per-round MP pairs | Estimated rounds | Total MP comparisons |
|-----------|-----------------|-------------------|-----------------|---------------------|
| 500       | ~400 unique     | 160,000           | ~5              | ~800,000            |
| 2,000     | ~1,500 unique   | 2,250,000         | ~5              | ~11,250,000         |
| 5,000     | ~3,500 unique   | 12,250,000        | ~5              | ~61,250,000         |
| 10,000    | ~6,500 unique   | 42,250,000        | ~5              | ~211,250,000        |

Additionally, each MP comparison involves:
- Pattern matching on `.imp` constructor (cheap)
- Formula equality check `lhs == antecedent` (structural equality, O(complexity))

With an average formula complexity of ~5-8 at c9, each equality check is ~5-8 comparisons. At 10K seeds, the inner loop performs roughly **1 billion** structural comparison steps.

### Additional Overhead: eraseDups

`List.eraseDups` has O(n^2) complexity because it calls `List.elem` (linear scan) for each element. In `generateValidBatch`:
- Called at least 3 times on pools of 400-6500+ formulas
- After Nec round: pool doubles (n -> 2n), dedup is O(4n^2)
- After MP round: pool grows by MP results, dedup is O((n+k)^2)
- Over 5 rounds: total eraseDups cost is O(sum of (pool_size_i)^2)

The file already has a `hashDedup` function (lines 1050-1058) that uses `Std.HashMap UInt64 Unit` for O(n) dedup, but it is NOT used in `generateValidBatch`.

---

## Optimization Strategies

### Strategy 1: Implication-Index HashMap (PRIMARY -- highest impact)

**Concept**: Instead of checking all pairs (phi, psi) for MP matches, build an index that maps each formula's LHS (when it's an implication) to its RHS.

**Current approach** (O(n^2)):
```lean
for phi in pool do
  for psi in pool do
    match generateValidFromMP phi psi with
    | some result => mpResults := result :: mpResults
    | none => pure ()
```

**Optimized approach** (O(n)):
```lean
-- Build implication index: for each (A -> B) in pool, map A -> [B]
let mut impIndex : Std.HashMap Formula (List Formula) := {}
for psi in pool do
  match psi with
  | .imp lhs rhs =>
    impIndex := impIndex.alter lhs fun
      | some existing => some (rhs :: existing)
      | none => some [rhs]
  | _ => pure ()

-- For each phi in pool, look up impIndex[phi] to get all consequents
let mut mpResults : List Formula := []
for phi in pool do
  match impIndex[phi]? with
  | some rhsList =>
    for rhs in rhsList do
      mpResults := rhs :: mpResults
  | none => pure ()
```

**Complexity**: O(n) to build index + O(n * avg_matches) for lookups. In practice, avg_matches is small (most formulas don't appear as the LHS of many implications), so total is close to O(n).

**Feasibility**: Fully feasible. `Formula` has `Hashable` and `BEq` instances (deriving-based). `Std.HashMap` is already imported.

**Expected speedup**: 100x-1000x at 10K seeds. The dominant cost moves from n^2 equality comparisons to n hash computations + n lookups.

**Implementation complexity**: Low. ~15 lines of code change in Phase 3.

**Risk**: None for correctness -- produces identical results. Hash collisions are handled by `Std.HashMap`'s bucket chains with BEq fallback.

### Strategy 2: Replace eraseDups with HashSet-based Dedup

**Concept**: Replace all `pool.eraseDups` calls with `hashDedup` (already exists in file) or a `Std.HashSet`-based approach.

**Current**: `pool.eraseDups` is O(n^2) using `List.elem`
**Optimized**: Use `hashDedup` or maintain a `Std.HashSet Formula` alongside the pool

**Three sub-options**:

**Option A -- Use existing `hashDedup`**:
Replace `pool.eraseDups` with `hashDedup pool`. Minimal change but note: `hashDedup` uses `UInt64` hash as key, which has a theoretical collision risk (two different formulas with same hash would drop one). For a pool of ~10K formulas this is negligible (collision probability ~10^-15).

**Option B -- Use `Std.HashSet Formula`**:
Maintain a `Std.HashSet Formula` as the pool's backing store. This provides O(1) amortized insertion with dedup built in.

**Option C -- Hybrid: Array + HashSet**:
Keep an `Array Formula` for ordered iteration and a `Std.HashSet Formula` for O(1) membership. Insert into both when adding new formulas.

**Feasibility**: All options fully feasible. Option B or C is preferred for correctness (uses full BEq, not just hash).

**Expected speedup**: 5-10x improvement on dedup alone. At 10K pool size, eraseDups does ~100M comparisons per call; HashSet does ~10K hash+insert.

**Implementation complexity**: Low (Option A: 3 line changes) to Medium (Option C: ~30 lines refactor).

**Risk**: Option A has theoretical hash collision risk (negligible in practice). Options B/C are provably correct.

### Strategy 3: Pool Data Structure Change (List -> HashSet + Array)

**Concept**: Convert the entire pool from `List Formula` to `Std.HashSet Formula` (for membership/dedup) + `Array Formula` (for iteration). This eliminates ALL quadratic dedup overhead and makes insertion O(1) amortized.

**Current flow per round**:
1. Nec: `pool.map` -> new list -> append -> eraseDups
2. MP: nested for -> mpResults list -> append -> eraseDups

**Optimized flow per round**:
1. Nec: iterate poolArray, for each phi, if `box phi` not in poolSet, add to both
2. MP: use impIndex, for each result, if not in poolSet, add to both

**Feasibility**: Fully feasible. Requires refactoring the `mut pool : List Formula` to `mut poolSet : Std.HashSet Formula` + `mut poolArr : Array Formula`.

**Expected speedup**: Combined with Strategy 1, this eliminates all O(n^2) operations. Total per-round cost becomes O(n).

**Implementation complexity**: Medium. ~60 lines of refactoring.

**Risk**: Low. The logic is equivalent; only the data structure changes.

### Strategy 4: Incremental Closure (Avoid Reprocessing Old Pairs)

**Concept**: In each round, only process NEW formulas against the existing pool (not all-pairs of the full pool).

**Current**: Every round checks all n^2 pairs, even pairs that were checked in previous rounds.

**Optimized**: Track a "frontier" of newly added formulas. In each round:
- Nec: Only apply to frontier formulas
- MP: Check (frontier x pool) and (pool x frontier), not (pool x pool)

**Implementation**:
```lean
let mut frontier := initialPool
let mut pool := initialPool
while ... do
  let newFromNec := frontier.map generateValidFromNec |>.filter (not in pool)
  let newFromMP := mpClosure(frontier, pool) |>.filter (not in pool)
  frontier := newFromNec ++ newFromMP
  pool := pool ++ frontier
```

**Feasibility**: Fully feasible. Natural extension of the fixpoint pattern.

**Expected speedup**: Depends on growth rate. If each round adds ~10% new formulas, the frontier is ~0.1n, so MP checks drop from n^2 to 0.2*n^2 (frontier x pool in both directions). Combined with Strategy 1 (impIndex), the frontier approach further reduces work but has less impact since impIndex already makes MP O(n).

**Implementation complexity**: Medium. Requires tracking frontier separately.

**Risk**: None. Produces identical results (fixpoint is the same regardless of traversal order).

### Strategy 5: Early Complexity Filtering

**Concept**: During Nec and MP rounds, immediately discard formulas that exceed `maxComplexity`. Currently, all formulas are kept in the pool regardless of complexity, and filtering only happens at Phase 4.

**Observation**: `generateValidFromNec(phi)` produces `box phi` with complexity = `phi.complexity + 1`. After a few Nec rounds, many formulas exceed maxComplexity but remain in the pool, participating in future MP pairs.

**Implementation**:
```lean
-- In Nec round: only add if within bounds
let necFormulas := pool.filterMap fun phi =>
  let boxPhi := generateValidFromNec phi
  if boxPhi.complexity <= maxComplexity then some boxPhi else none

-- In MP round: only add if within bounds
match generateValidFromMP phi psi with
| some result =>
  if result.complexity <= maxComplexity then
    mpResults := result :: mpResults
| none => pure ()
```

**Feasibility**: Fully feasible. `Formula.complexity` is a simple recursive function, already used elsewhere.

**Expected speedup**: Moderate. Reduces pool growth rate, which compounds across rounds. At c9 (maxComplexity=9), Nec of a complexity-9 formula yields complexity 10, which would be filtered. This prevents pool inflation from high-complexity formulas.

**Implementation complexity**: Very low. ~4 line changes.

**Risk**: Slightly different results than current (pool will be smaller), but all formulas that pass the final filter would still be generated. The only difference is that some intermediate formulas used in MP derivations might be missing. However, since the goal is formulas within the complexity range, filtering intermediates that are too complex is unlikely to miss derivable in-range formulas (an intermediate out of range is unlikely to combine via MP to produce something in range).

**Mitigation**: Could filter only for pool membership but still use as MP antecedents. Or keep a separate "derivation pool" that includes out-of-range formulas but don't iterate them in the MP outer loop.

### Strategy 6: Parallelism via Lean 4 Tasks

**Concept**: Parallelize the MP closure across multiple Lean 4 `Task`s.

**Observation**: The MP round can be partitioned: split the pool into chunks, each chunk processes independently, merge results.

**Feasibility**: Partially feasible. Lean 4 has `Task.spawn` for spawning lightweight green threads. However:
- The pool is mutable state (`mut pool`), requiring coordination
- Each worker would need a read-only snapshot of the pool + impIndex
- Results would need to be merged and deduped

**Expected speedup**: Linear in core count (2-4x on typical machines). But Strategy 1 already reduces the MP cost by 100-1000x, so parallelism provides diminishing returns.

**Implementation complexity**: High. Lean 4's concurrency model requires careful handling of shared state. The `BaseIO`/`IO` monad doesn't have built-in parallel combinators like Haskell's `par`.

**Risk**: Medium. Race conditions, non-determinism in output order (though results are deduped so order doesn't matter for correctness).

**Recommendation**: Defer. Strategy 1 alone provides more speedup than parallelism, with much less complexity.

### Strategy 7: Caching MP Results Across Batches

**Concept**: If `generateValidBatch` is called multiple times (e.g., for different complexity levels), cache the closure results.

**Current usage**: `generateValidBatch` is called once per `generateFormulas` invocation, so inter-batch caching provides no benefit in the current pipeline.

**Feasibility**: Not applicable -- single invocation per pipeline run.

**Expected speedup**: None in current usage.

**Recommendation**: Skip.

### Strategy 8: Reduce Seed Count, Increase Axiom Diversity

**Concept**: Instead of generating 10K random axiom instances (many of which are duplicates or trivially similar), generate fewer but more diverse seeds.

**Observation**: With 14 axiom schemata and random sub-formulas up to maxParamSize, many instances will be structurally similar. The `eraseDups` after Phase 1 likely reduces 10K generated instances to 6-7K unique ones.

**Approach**: Generate only the unique instances needed:
- Use deterministic enumeration of sub-formula parameters instead of random sampling
- Enumerate all schemata x all atom combinations x sizes 1..maxParamSize
- This gives a bounded, complete set without duplicates

**Feasibility**: Feasible but changes the semantics of the function (deterministic vs random).

**Expected speedup**: Reduces seed count while maintaining diversity. But doesn't address the MP closure bottleneck directly.

**Implementation complexity**: Medium.

**Risk**: May reduce randomness/diversity that random sampling provides.

**Recommendation**: Consider as a supplementary optimization, not primary.

---

## Recommended Approach (Prioritized)

### Priority 1: Implication-Index HashMap (Strategy 1) + HashSet Pool (Strategy 3)

**Combined implementation**: Refactor `generateValidBatch` to use:
- `Std.HashSet Formula` for the pool (O(1) membership, built-in dedup)
- `Array Formula` for ordered iteration
- `Std.HashMap Formula (Array Formula)` as the implication index

This eliminates ALL O(n^2) operations in a single refactoring pass.

**Expected total speedup**: 100-1000x for 10K seeds (from hours to seconds/minutes).

**Implementation effort**: ~80-100 lines changed in `generateValidBatch`. Estimated 1-2 hours of implementation + testing.

### Priority 2: Early Complexity Filtering (Strategy 5)

**Add after Priority 1**: Filter formulas exceeding `maxComplexity` during Nec and MP rounds.

**Expected additional speedup**: 2-5x by reducing pool growth rate.

**Implementation effort**: ~10 lines. Can be done in the same pass as Priority 1.

### Priority 3: Incremental Frontier (Strategy 4)

**Add if needed**: Track a frontier of newly added formulas to avoid reprocessing.

**Expected additional speedup**: 2-3x on top of Priority 1+2.

**Implementation effort**: ~20 additional lines.

---

## Implementation Sketch

```lean
partial def generateValidBatch (seedCount : Nat) (maxComplexity : Nat)
    (atoms : List Atom) : IO (List Formula) := do
  let maxParamSize := max 1 (maxComplexity / 3)

  -- Phase 1: Seed pool using HashSet for O(1) dedup
  let mut poolSet : Std.HashSet Formula := {}
  let mut poolArr : Array Formula := #[]
  let addToPool := fun (poolS : Std.HashSet Formula) (poolA : Array Formula) (phi : Formula) =>
    if poolS.contains phi then (poolS, poolA)
    else (poolS.insert phi, poolA.push phi)

  for _ in List.range seedCount do
    let axiomInst ← instantiateAxiom atoms maxParamSize
    let (s, a) := addToPool poolSet poolArr axiomInst
    poolSet := s; poolArr := a

  for phi in theoremSeedFormulas do
    let (s, a) := addToPool poolSet poolArr phi
    poolSet := s; poolArr := a

  -- Phase 2: Ex-falso cap (same logic, using poolArr for iteration)
  -- ... (omitted for brevity, same structure)

  -- Phase 3: Fixpoint Nec/MP closure with implication index
  let mut round : Nat := 0
  while round < 10 && poolArr.size < 10000 do
    let prevSize := poolArr.size

    -- Nec round with early complexity filter
    let snapshot := poolArr
    for phi in snapshot do
      let boxPhi := generateValidFromNec phi
      if boxPhi.complexity <= maxComplexity && !poolSet.contains boxPhi then
        poolSet := poolSet.insert boxPhi
        poolArr := poolArr.push boxPhi

    -- Build implication index from current pool
    let mut impIndex : Std.HashMap Formula (Array Formula) := {}
    for psi in poolArr do
      match psi with
      | .imp lhs rhs =>
        impIndex := impIndex.alter lhs fun
          | some existing => some (existing.push rhs)
          | none => some #[rhs]
      | _ => pure ()

    -- MP round: for each phi, look up consequents via index
    let snapshot2 := poolArr
    for phi in snapshot2 do
      match impIndex[phi]? with
      | some rhsArr =>
        for rhs in rhsArr do
          if rhs.complexity <= maxComplexity && !poolSet.contains rhs then
            poolSet := poolSet.insert rhs
            poolArr := poolArr.push rhs
      | none => pure ()

    round := round + 1
    let growth := poolArr.size - prevSize
    let growthRate := if prevSize > 0 then growth * 100 / prevSize else 100
    if growthRate < 1 then break

  -- Phase 4: Filter by complexity range
  return poolArr.toList.filter fun phi => phi.complexity >= 3 && phi.complexity <= maxComplexity
```

### Key Changes Summary

| Component | Before | After | Complexity Change |
|-----------|--------|-------|-------------------|
| Pool data structure | `List Formula` | `HashSet Formula` + `Array Formula` | membership: O(n) -> O(1) |
| Dedup (eraseDups) | O(n^2) per call, 5+ calls | Built into HashSet insert | O(n^2) -> O(1) amortized |
| MP closure | O(n^2) all-pairs nested loop | O(n) implication-index lookup | O(n^2) -> O(n) |
| Nec round | O(n) map + O(n^2) eraseDups | O(n) iterate + O(1) insert | O(n^2) -> O(n) |
| Complexity filter | Phase 4 only (end) | Each insertion point | Reduces pool growth |

### Expected Performance at Target Seed Counts

| seedCount | Current Time (est.) | Optimized Time (est.) | Speedup |
|-----------|--------------------|-----------------------|---------|
| 500       | ~2-5 min           | ~2-5 sec              | 30-60x  |
| 2,000     | ~26+ min           | ~10-30 sec            | 50-100x |
| 5,000     | ~hours             | ~1-3 min              | ~100x   |
| 10,000    | >47 min (DNF)      | ~3-8 min              | >100x   |
| 20,000    | DNF                | ~10-20 min            | N/A     |

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Hash collisions cause missed formulas | Very Low | Low | `Std.HashMap`/`HashSet` use BEq fallback in bucket chains |
| Early complexity filter misses derivable in-range formulas | Low | Low | Intermediates out of range rarely combine to in-range results |
| HashSet iteration order differs from List | None | None | Results are filtered and sorted by complexity anyway |
| `Formula.hash` is slow | Very Low | Low | Derived `Hashable` is structural; still much faster than equality |
| Pool growth exceeds 10K cap faster | Low | None | Cap is preserved; just hit sooner with more efficient closure |

---

## Additional Observations

### The `hashDedup` Function Already Exists

Lines 1050-1058 define `hashDedup` using `Std.HashMap UInt64 Unit`. This is used in `generateFormulas` (line 1140) but NOT in `generateValidBatch`. Simply replacing `eraseDups` with `hashDedup` throughout `generateValidBatch` would provide an immediate 5-10x improvement with minimal code change, even before the implication-index optimization.

### Lean 4 `Std.HashSet` Availability

`Std.Data.HashMap` is already imported (line 3). `Std.HashSet` is available via `import Std.Data.HashSet` or can be constructed from `Std.HashMap Formula Unit`. Either approach works.

### The Pool Cap (10,000) May Need Adjustment

With an efficient O(n) closure, the pool may grow faster and hit the 10K cap sooner. This is actually desirable -- it means more valid formulas are discovered. The cap may need to be raised (e.g., to 50K or 100K) to take advantage of the improved performance, or kept at 10K if the goal is simply speed.

### Consideration: Intermediate Formulas for MP

The early complexity filter (Strategy 5) could theoretically miss some in-range formulas that are only derivable through out-of-range intermediates. For example, if `A` (complexity 5) and `A -> B` (complexity 12, out of range at c9) are both in the pool, then `B` (complexity 6, in range) would not be derived if the implication is filtered out.

**Mitigation**: Keep the implication index over ALL formulas (including those above maxComplexity), but only add Nec-derived formulas that are in range. This way, high-complexity implications still serve as derivation paths, but the pool doesn't grow with high-complexity atomic formulas.

---

## Estimated Implementation Effort

| Phase | Effort | Description |
|-------|--------|-------------|
| Phase 1: HashSet pool + hashDedup | 30 min | Replace List with HashSet+Array, eliminate eraseDups |
| Phase 2: Implication index | 30 min | Build HashMap index, replace nested loop |
| Phase 3: Early complexity filter | 15 min | Add complexity checks at insertion points |
| Phase 4: Testing | 45 min | Run at seedCount=500, 2000, 10000; verify output matches |
| Phase 5: Benchmark | 30 min | Compare wall-clock times before/after |
| **Total** | **~2.5 hours** | |

---

## Conclusion

The `generateValidBatch` bottleneck is caused by three compounding O(n^2) operations: all-pairs MP closure, `List.eraseDups`, and implicit linear membership checks. All three can be eliminated by switching to `HashSet`-based pool management and an implication-index `HashMap` for MP closure. The recommended implementation combines all three fixes in a single refactoring pass, reducing overall complexity from O(n^2 * rounds) to O(n * rounds). This should reduce wall-clock time from >47 minutes (DNF at 10K seeds) to under 10 minutes, unblocking task 217's c9/c11 dataset generation with meaningful valid formula enrichment.
