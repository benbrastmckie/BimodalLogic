# Implementation Plan: Task #880 (v006) - Weaken Hypotheses with Construction Fix

**Task**: 880 - Complete RecursiveSeed temporal coherent family construction
**Version**: 006
**Created**: 2026-02-13
**Language**: lean
**Status**: [NOT STARTED]
**Estimated Effort**: 12-18 hours (reduced from v005 due to completed construction fix)
**Previous**: v005 (partially executed - construction fix done, hypothesis weakening not done)

## What v005 Accomplished

Phase 2 of v005 **fixed the construction** (valuable work retained):
- Added seed4 propagation: G psi / H psi now correctly propagate to future/past times
- This semantic fix is prerequisite for the proof strategy to work

However, v005 Phase 2 did **NOT** implement the planned hypothesis weakening. The theorem still uses:
```lean
(h_single_family : seed.familyIndices = [famIdx])
(h_single_time : seed.timeIndices famIdx = [timeIdx])
```

## What v006 Must Complete

1. **Weaken theorem hypotheses** (the actual v005 Phase 2 goal)
2. **Prove supporting lemmas** (2 sorries at lines 2809, 2826)
3. **Eliminate 6 false-claim sorries** (now provable with weakened hypotheses)

## Key Insight from Phase 3 Analysis

The 6 sorries at lines 4005, 4090, 4171, 4255, 4321, 4385 claim "dead code" but:
- They assert `result.1.familyIndices = [result.2]` after `createNewFamily`
- This is **FALSE** (list has TWO elements: `[famIdx, result.2]`)
- Nested operators like `box(box p)` **CAN** reach these cases

**Solution**: With weakened hypotheses, we don't need to prove these false claims. Instead, we prove monotonic properties that survive `createNewFamily`/`createNewTime`.

## Current State

| Metric | Value |
|--------|-------|
| Sorries in RecursiveSeed.lean | 8 |
| False hypothesis sorries | 6 (lines 4005, 4090, 4171, 4255, 4321, 4385) |
| Supporting lemma sorries | 2 (lines 2809, 2826) |
| Lake build | Success (with sorry warnings) |
| Construction fix | Done (seed4 propagation) |

## Implementation Phases

### Phase 1: Weaken Theorem Hypotheses (4-6 hours) [NOT STARTED]

**Dependencies**: None (construction fix already done)
**Goal**: Change `buildSeedAux_preserves_seedConsistent` to use weaker hypotheses

**Current signature**:
```lean
theorem buildSeedAux_preserves_seedConsistent
    (phi : Formula) (famIdx : Nat) (timeIdx : Int) (seed : ModelSeed)
    (h_cons : SeedConsistent seed) (h_wf : SeedWellFormed seed)
    (h_phi_in : phi ∈ seed.getFormulas famIdx timeIdx)
    (h_phi_cons : FormulaConsistent phi)
    (h_single_family : seed.familyIndices = [famIdx])      -- STRONG (false after createNewFamily)
    (h_single_time : seed.timeIndices famIdx = [timeIdx]) : -- STRONG (false after createNewTime)
    SeedConsistent (buildSeedAux phi famIdx timeIdx seed)
```

**New signature**:
```lean
theorem buildSeedAux_preserves_seedConsistent
    (phi : Formula) (famIdx : Nat) (timeIdx : Int) (seed : ModelSeed)
    (h_cons : SeedConsistent seed) (h_wf : SeedWellFormed seed)
    (h_phi_in : phi ∈ seed.getFormulas famIdx timeIdx)
    (h_phi_cons : FormulaConsistent phi)
    (h_family_valid : famIdx < seed.nextFamilyIdx)         -- WEAK (monotonic, survives creation)
    (h_entry_exists : seed.findEntry famIdx timeIdx ≠ none) : -- WEAK (monotonic, survives creation)
    SeedConsistent (buildSeedAux phi famIdx timeIdx seed)
```

**Tasks**:
1. Change the two hypothesis types in the theorem signature
2. Update all IH applications to provide the new hypothesis proofs
3. Delete the 6 false-claim sorries (they claimed the strong hypotheses)
4. At each recursive call site, prove:
   - `famIdx < result.nextFamilyIdx` (monotonic - always true after creation)
   - `result.findEntry famIdx timeIdx ≠ none` (monotonic - entries not deleted)

**Verification**:
- [ ] Theorem signature changed
- [ ] All IH applications updated
- [ ] 6 false-claim sorries removed
- [ ] `lake build` succeeds

---

### Phase 2: Prove Monotonicity Lemmas (3-5 hours) [NOT STARTED]

**Dependencies**: Phase 1
**Goal**: Prove the lemmas needed for IH applications

**Required lemmas** (may already exist - check first):
```lean
-- createNewFamily preserves family validity (monotonic)
lemma createNewFamily_preserves_family_valid (seed : ModelSeed) (timeIdx : Int) (phi : Formula)
    (famIdx : Nat) (h : famIdx < seed.nextFamilyIdx) :
    famIdx < (seed.createNewFamily timeIdx phi).1.nextFamilyIdx

-- createNewFamily preserves entry existence (monotonic)
lemma createNewFamily_preserves_entry_exists (seed : ModelSeed) (timeIdx : Int) (phi : Formula)
    (famIdx : Nat) (t : Int) (h : seed.findEntry famIdx t ≠ none) :
    (seed.createNewFamily timeIdx phi).1.findEntry famIdx t ≠ none

-- Similar for createNewTime
lemma createNewTime_preserves_family_valid ...
lemma createNewTime_preserves_entry_exists ...

-- Similar for addFormula, addToAllFutureTimes, addToAllPastTimes
```

**Tasks**:
1. Check which lemmas already exist with `lean_local_search`
2. Prove missing lemmas near the definitions they reference
3. Apply these in Phase 1's IH sites

**Verification**:
- [ ] All required lemmas proven (no sorries)
- [ ] `lake build` succeeds

---

### Phase 3: Prove Supporting Lemmas (3-5 hours) [NOT STARTED]

**Dependencies**: Phase 1, Phase 2
**Goal**: Eliminate the 2 supporting lemma sorries

**Current sorries**:
- Line 2809: `addToAllFutureTimes_preserves_seedConsistent_with_gpsi`
- Line 2826: `addToAllPastTimes_preserves_seedConsistent_with_hpsi`

**Proof strategy** (from Phase 1 handoff):
```
G psi at timeIdx implies psi derivable at all future times:
1. temp_4: G psi -> G(G psi)  [G psi derivable at all future times]
2. temp_t: G psi -> psi       [at each future time, psi derivable from G psi]
```

With the construction fix (seed4 propagation), G psi IS now present at future times, enabling this derivation.

**Tasks**:
1. Prove `addToAllFutureTimes_preserves_seedConsistent_with_gpsi`:
   - Unfold `addToAllFutureTimes` (fold over future time entries)
   - For each entry, use `temp_t_future` axiom to derive psi from G psi
   - Apply `addFormula_preserves_consistent` at each step
2. Prove `addToAllPastTimes_preserves_seedConsistent_with_hpsi` similarly

**Verification**:
- [ ] Both lemmas proven (no sorries)
- [ ] `lake build` succeeds

---

### Phase 4: Update Call Sites & Verify (2-3 hours) [NOT STARTED]

**Dependencies**: Phases 1-3
**Goal**: Update callers and verify sorry-freedom

**Tasks**:
1. Update the call site in `seedConsistent` theorem:
   - Replace `initial_familyIndices_eq` with proof of `0 < initialSeed.nextFamilyIdx`
   - Replace `initial_timeIndices_eq` with proof of `initialSeed.findEntry 0 0 ≠ none`
   - These should be straightforward (initial seed has these properties)

2. Count sorries:
   ```bash
   grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean
   ```
   Expected: 0

3. Full build verification:
   ```bash
   lake build
   ```

**Verification**:
- [ ] `seedConsistent` compiles without sorry
- [ ] grep returns 0 sorries
- [ ] `lake build` succeeds with clean output
- [ ] Key theorems verified via `#check`

---

## Dependencies Diagram

```
Phase 1 (Weaken Hypotheses)
    ↓
Phase 2 (Monotonicity Lemmas)
    ↓
Phase 3 (Supporting Lemmas)
    ↓
Phase 4 (Call Sites & Verify)
```

Sequential execution required - each phase builds on the previous.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Monotonicity lemmas already exist | LOW (positive) | MEDIUM | Check with lean_local_search first |
| Weakened hypotheses insufficient somewhere | HIGH | LOW | Original hypotheses still available as fallback |
| temp_t derivation more complex than expected | MEDIUM | MEDIUM | Research-007 confirmed approach viability |

## Comparison to v005

| Aspect | v005 Plan | v006 Plan |
|--------|-----------|-----------|
| Construction fix | Phase 2 (done) | Retained from v005 |
| Hypothesis weakening | Phase 2 (not done) | Phase 1 |
| Monotonicity lemmas | Implicit | Phase 2 (explicit) |
| Supporting lemmas | Part of Phase 2 | Phase 3 (separated) |
| Call site updates | Phase 3 | Phase 4 |
| Total phases | 4 | 4 |
| Estimated effort | 18-26h | 12-18h (construction done) |

## Success Criteria

- [ ] Theorem signature uses weaker hypotheses
- [ ] All 8 sorries eliminated (6 false-claim + 2 supporting)
- [ ] `lake build` succeeds with no sorries
- [ ] `seedConsistent` is transitively sorry-free
- [ ] Key theorems verified

## Rollback

If Phase 1 blocks, the construction fix from v005 is preserved. The file can continue to build with sorries while an alternative approach is investigated.
