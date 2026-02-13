# Implementation Plan: Task #880 (v005) - Weaken Theorem Hypotheses

**Task**: 880 - Complete RecursiveSeed temporal coherent family construction
**Version**: 005
**Created**: 2026-02-13
**Language**: lean
**Status**: [IMPLEMENTING]
**Estimated Effort**: 18-26 hours
**Research Input**: research-007.md (Approach 3 analysis), handoffs/phase-2-handoff-20260212.md

## Overview

This plan implements **Option A: Weaken the theorem hypotheses** from research-007.md. Rather than patching individual sorry locations with case splits (Option B), we restructure `buildSeedAux_preserves_seedConsistent` to use weaker, always-satisfiable hypotheses.

### Why v004 Was Blocked

Phase 2 discovered that 6 sorries (lines 3908, 3993, 4074, 4158, 4224, 4288) claim FALSE hypotheses:
```lean
have h_seed2_single : result.1.familyIndices = [result.2] := by sorry
```

This is false because after `createNewFamily`, familyIndices has TWO elements `[famIdx, result.2]`, not one.

### Why v005 Succeeds

The current hypotheses are unnecessarily strong:
```lean
(h_single_family : seed.familyIndices = [famIdx])
(h_single_time : seed.timeIndices famIdx = [timeIdx])
```

These demand the seed has EXACTLY one family/time, which breaks after any `createNewFamily`/`createNewTime` call. The proof doesn't actually need this - it only needs:
1. The target family/time EXISTS in the seed
2. The target family/time has a valid index

Weakened hypotheses:
```lean
(h_family_valid : famIdx < seed.nextFamilyIdx)
(h_entry_exists : seed.findEntry famIdx timeIdx <> none)
```

These remain true after `createNewFamily`/`createNewTime` because:
- Creating new families only INCREASES `nextFamilyIdx`
- Creating new times only ADDS entries, doesn't remove existing ones
- Existing entries preserve their indices

## Goals & Non-Goals

**Goals**:
- Restructure `buildSeedAux_preserves_seedConsistent` with weaker hypotheses
- Eliminate all 6 sorry locations (3908, 3993, 4074, 4158, 4224, 4288)
- Achieve sorry-free `seedConsistent` theorem transitively
- Clean refactoring without changing proof semantics

**Non-Goals**:
- Full completeness theorem (out of scope)
- Performance optimization
- Modifying other files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Weaker hypotheses insufficient for some proofs | HIGH | LOW | Option B (case split) as fallback |
| Many call sites need updates | MEDIUM | MEDIUM | Systematic refactoring in Phase 2 |
| Hidden proof dependencies on strong hypotheses | MEDIUM | LOW | Careful analysis in Phase 1 |

## Sorry Inventory

| Line | Category | Current Goal | Fix |
|------|----------|--------------|-----|
| 3908 | Structural | `result.1.familyIndices = [result.2]` | Use weakened hypothesis |
| 3993 | Structural | `seed2.timeIndices famIdx = [newTime]` | Use weakened hypothesis |
| 4074 | Structural | `seed2.timeIndices famIdx = [newTime]` | Use weakened hypothesis |
| 4158 | Structural | `result.1.familyIndices = [result.2]` | Use weakened hypothesis |
| 4224 | Structural | `seed2.timeIndices famIdx = [newTime]` | Use weakened hypothesis |
| 4288 | Structural | `seed2.timeIndices famIdx = [newTime]` | Use weakened hypothesis |

## Implementation Phases

### Phase 1: Analysis and Lemma Discovery (3-5 hours) [COMPLETED]

**Dependencies**: None
**Goal**: Identify exactly how `h_single_family` and `h_single_time` are used in proofs

**Tasks**:
1. **Map hypothesis usage**
   - Search for all uses of `h_single_family` in `buildSeedAux_preserves_seedConsistent`
   - Search for all uses of `h_single_time`
   - Identify which proof steps actually REQUIRE these hypotheses

2. **Identify required supporting lemmas**
   Find or prove:
   ```lean
   -- createNewFamily preserves index validity
   lemma createNewFamily_preserves_family_valid (seed : ModelSeed) (timeIdx : Int) (phi : Formula)
       (famIdx : Nat) (h : famIdx < seed.nextFamilyIdx) :
       famIdx < (seed.createNewFamily timeIdx phi).1.nextFamilyIdx

   -- createNewFamily preserves entry existence
   lemma createNewFamily_preserves_entry_exists (seed : ModelSeed) (timeIdx : Int) (phi : Formula)
       (famIdx : Nat) (t : Int) (h : seed.findEntry famIdx t <> none) :
       (seed.createNewFamily timeIdx phi).1.findEntry famIdx t <> none

   -- Similar for createNewTime
   lemma createNewTime_preserves_family_valid ...
   lemma createNewTime_preserves_entry_exists ...
   ```

3. **Check existing lemmas**
   ```bash
   lean_local_search "createNewFamily"
   lean_local_search "preserves"
   lean_hover_info  # on existing lemmas
   ```

**Verification**:
- [ ] Complete map of hypothesis usage
- [ ] List of required supporting lemmas (existing vs need-to-prove)
- [ ] Confidence assessment for Phase 2

---

### Phase 2: Restructure Theorem Signature (8-12 hours) [NOT STARTED]

**Dependencies**: Phase 1
**Goal**: Change `buildSeedAux_preserves_seedConsistent` to use weaker hypotheses

**Tasks**:
1. **Create backup**
   ```bash
   cp RecursiveSeed.lean RecursiveSeed.lean.backup-v004
   ```

2. **Modify theorem signature**

   Current:
   ```lean
   theorem buildSeedAux_preserves_seedConsistent
       (phi : Formula) (famIdx : Nat) (timeIdx : Int) (seed : ModelSeed)
       (h_consistent : seedConsistent seed)
       (h_single_family : seed.familyIndices = [famIdx])
       (h_single_time : seed.timeIndices famIdx = [timeIdx]) :
       seedConsistent (buildSeedAux phi famIdx timeIdx seed)
   ```

   New:
   ```lean
   theorem buildSeedAux_preserves_seedConsistent
       (phi : Formula) (famIdx : Nat) (timeIdx : Int) (seed : ModelSeed)
       (h_consistent : seedConsistent seed)
       (h_family_valid : famIdx < seed.nextFamilyIdx)
       (h_entry_exists : seed.findEntry famIdx timeIdx <> none) :
       seedConsistent (buildSeedAux phi famIdx timeIdx seed)
   ```

3. **Update induction hypothesis calls**
   - Each recursive call site needs updated hypothesis proofs
   - After `createNewFamily`, prove new hypotheses using supporting lemmas
   - After `createNewTime`, prove new hypotheses using supporting lemmas

4. **Fix each sorry location systematically**
   For each sorry at lines 3908, 3993, 4074, 4158, 4224, 4288:
   - Delete the sorry line (which claimed false hypothesis)
   - Apply IH with proofs of weakened hypotheses
   - Use `createNewFamily_preserves_*` / `createNewTime_preserves_*` lemmas

5. **Incremental verification**
   ```bash
   lake build  # After each sorry elimination
   ```

**Verification**:
- [ ] Theorem signature changed
- [ ] All 6 sorry locations eliminated
- [ ] `lake build` succeeds
- [ ] No new sorries introduced

---

### Phase 3: Update Call Sites (4-6 hours) [NOT STARTED]

**Dependencies**: Phase 2
**Goal**: Update all callers of `buildSeedAux_preserves_seedConsistent` to provide new hypotheses

**Tasks**:
1. **Find all call sites**
   ```bash
   grep -n "buildSeedAux_preserves_seedConsistent" RecursiveSeed.lean
   ```

2. **Update each caller**
   - Replace `h_single_family` argument with `h_family_valid` proof
   - Replace `h_single_time` argument with `h_entry_exists` proof
   - These should be EASIER to prove at call sites

3. **Verify transitivity**
   - `seedConsistent` should compile without sorry
   - Check dependency chain is sorry-free

**Verification**:
- [ ] All call sites updated
- [ ] `seedConsistent` compiles without sorry
- [ ] `lake build` succeeds

---

### Phase 4: Verify Sorry-Freedom (2-3 hours) [NOT STARTED]

**Dependencies**: Phase 3
**Goal**: Confirm complete sorry elimination

**Tasks**:
1. **Count sorries**
   ```bash
   grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean
   ```
   Expected: 0

2. **Full build**
   ```bash
   lake build
   ```

3. **Verify key theorems**
   ```lean
   #check seedConsistent
   #check buildSeedAux_preserves_seedConsistent
   ```

4. **Document completion**
   - Update SORRY_REGISTRY.md (if exists)
   - Create implementation summary

**Verification**:
- [ ] `grep sorry` returns 0 matches
- [ ] `lake build` succeeds with clean build
- [ ] Key theorems compile without warnings

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] Sorry count: 12 -> 6 (Phase 2) -> 0 (Phase 3)
- [ ] No new axioms introduced
- [ ] Theorem signatures are cleaner/more general

## Comparison to v004

| Aspect | v004 (Case Split) | v005 (Weaken Hypotheses) |
|--------|-------------------|--------------------------|
| Approach | Local fixes at sorry sites | Structural refactoring |
| Confidence | 75% (modal cases uncertain) | 90% (principled fix) |
| Effort | 24-36 hours | 18-26 hours |
| Risk | High (modal case complexity) | Medium (refactoring scope) |
| Maintainability | Lower (fragile workarounds) | Higher (cleaner design) |
| Reusability | None | Supporting lemmas reusable |

## Key Insight

The original hypotheses `h_single_family` and `h_single_time` were written for a simpler proof where the seed never grows. But `buildSeedAux` DOES grow the seed via `createNewFamily`/`createNewTime`. The hypotheses need to express invariants that survive these operations.

The weakened hypotheses `h_family_valid` and `h_entry_exists` express exactly this: "the target location exists and remains valid". These are monotonic properties - they can only become MORE true as the seed grows.

## Rollback/Contingency

**If Phase 2 blocks**:
- Restore from backup: `cp RecursiveSeed.lean.backup-v004 RecursiveSeed.lean`
- Fall back to v004 Approach B (case split)
- Document blocking issue for future reference

**Partial progress**:
- Each phase committed separately
- Can stop after Phase 2 if Phase 3 proves difficult
- Partial sorry reduction still valuable

## Next Steps

1. Start Phase 1: Map hypothesis usage in buildSeedAux_preserves_seedConsistent
2. Identify which supporting lemmas exist vs need creation
3. Estimate difficulty before committing to full refactor
4. Proceed to Phase 2 with clear understanding of scope
