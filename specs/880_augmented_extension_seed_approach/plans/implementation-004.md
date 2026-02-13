# Implementation Plan: Task #880 (v004) - RecursiveSeed Sorry-Free Path

**Task**: 880 - Complete RecursiveSeed temporal coherent family construction
**Version**: 004
**Created**: 2026-02-12
**Language**: lean
**Status**: [NOT STARTED]
**Estimated Effort**: 12-18 hours (current file) | 36-56 hours (full completeness)
**Research Input**: research-006.md (RecursiveSeed analysis)

## Overview

This plan pivots from Unified Chain DovetailingChain (v003, BLOCKED) to completing RecursiveSeed.lean. RecursiveSeed avoids cross-sign temporal propagation issues entirely because ALL temporal witnesses are pre-placed in the seed BEFORE any Lindenbaum extension.

### Why v003 Was Blocked

Unified Chain DovetailingChain failed at Phase 2 (`combined_seed_consistent`):
- Different MCSs in the chain can have incompatible temporal formulas
- M_0 can contain H(phi) while M_1 (an independent Lindenbaum extension) contains H(neg(phi))
- Combining HContent(M_0) and HContent(M_1) yields inconsistent set
- **Root cause**: Post-hoc cross-sign propagation through independent MCSs is impossible

### Why v004 Works

RecursiveSeed handles cross-sign trivially by construction:
1. When processing G phi at time t, phi is explicitly added to ALL future times in seed
2. This includes times on opposite side of time-zero
3. Happens BEFORE Lindenbaum - no cross-MCS propagation needed
4. Each (family, time) entry gets Lindenbaum extended independently

### Current State of RecursiveSeed.lean

**File**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
**Size**: 4,363 lines
**Namespace**: `Bimodal.Metalogic.Bundle`
**Sorries**: 12 (was estimated at 13, revised per research-006)

## Goals & Non-Goals

**Goals**:
- Eliminate all 12 sorries in RecursiveSeed.lean
- Achieve sorry-free `seedConsistent` theorem (transitively)
- Verify cross-sign propagation works as designed

**Non-Goals (Scope Boundary)**:
- Full completeness theorem (Phases 4-6, separate task)
- Modifying DovetailingChain.lean or UnifiedChain.lean
- Performance optimization

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| IH restructuring harder than expected | MEDIUM | LOW | Approach B (weaker statement) as fallback |
| Hidden dependencies between sorries | LOW | LOW | Sorry dependency graph in research-006 |
| List.modify API not in Mathlib | LOW | LOW | Direct proof via induction |

## Sorry Inventory (from research-006)

| Line | Category | Context | Effort |
|------|----------|---------|--------|
| 829 | API Issue | `filter_modify_eq_modify_filter` | 1-2h |
| 837 | API Issue | `map_modify_eq_map_of_eq` | 1-2h |
| 3878 | Structural | `h_seed2_single` in neg-Box case | Part of Phase 2 |
| 3963 | Structural | `h_seed2_single_time` in neg-G case | Part of Phase 2 |
| 4044 | Structural | `h_seed2_single_time` in neg-H case | Part of Phase 2 |
| 4128 | Structural | Duplicate neg-Box case | Part of Phase 2 |
| 4194 | Structural | Duplicate neg-G case | Part of Phase 2 |
| 4258 | Structural | Duplicate neg-H case | Part of Phase 2 |

## Implementation Phases

### Phase 1: Fix List.modify API Issues (2-4 hours) [NOT STARTED]

**Dependencies**: None
**Goal**: Resolve 2 API-related sorries at lines 829, 837

**Tasks**:
- [ ] Search Mathlib for existing `List.modify_*` lemmas
  ```
  lean_local_search "List.modify"
  lean_loogle "List.modify"
  ```
- [ ] If found: Apply existing lemmas
- [ ] If not found: Prove via structural induction on list and index
- [ ] Verify `filter_modify_eq_modify_filter` compiles
- [ ] Verify `map_modify_eq_map_of_eq` compiles
- [ ] Run `lake build` to confirm no new errors

**Verification**:
- [ ] Lines 829, 837 no longer contain `sorry`
- [ ] `lake build` succeeds
- [ ] Sorry count: 12 -> 10

---

### Phase 2: Restructure IH Hypotheses (8-12 hours) [NOT STARTED]

**Dependencies**: Phase 1
**Goal**: Resolve 6 structural false assertion sorries (lines 3878, 3963, 4044, 4128, 4194, 4258)

**Context**: The `buildSeedAux_preserves_seedConsistent` theorem passes `h_seed2_single` and `h_seed2_single_time` hypotheses to the IH, but these are FALSE as stated. However, the recursive call terminates in cases that don't need these hypotheses.

**Approach A (Recommended): Conditional Hypotheses**

1. Modify IH to accept `Or.inl (h_single)` OR `Or.inr (h_terminal_case)`
2. Terminal cases (generic implication, atoms) use `Or.inr`
3. Recursive cases use `Or.inl` with provably-true hypothesis
4. Each case then handles the appropriate branch

```lean
-- Current (BROKEN):
have h_seed2_single : result.1.familyIndices = [result.2] := by sorry

-- Proposed (FIXED):
have h_seed2_single_or_terminal :
    result.1.familyIndices = [result.2] ∨ inner.neg.isTerminal := by
  right
  exact imp_is_terminal inner
```

**Approach B (Fallback): Remove Hypotheses**

If Approach A proves too complex:
1. Analyze which proofs actually USE `h_single_family` / `h_single_time`
2. If none, simply delete the hypotheses
3. If some, prove they're only needed in provable cases

**Tasks**:
- [ ] Analyze `buildSeedAux_preserves_seedConsistent` structure (lines 3600-4340)
- [ ] Identify which recursive calls actually use single-X hypotheses
- [ ] Implement Approach A OR Approach B
- [ ] Update all 6 sorry locations consistently
- [ ] Run `lake build` after each change
- [ ] Verify `buildSeedAux_preserves_seedConsistent` compiles without sorry

**Verification**:
- [ ] Lines 3878, 3963, 4044, 4128, 4194, 4258 no longer contain `sorry`
- [ ] `buildSeedAux_preserves_seedConsistent` compiles without direct sorries
- [ ] Sorry count: 10 -> 4 -> 0

---

### Phase 3: Verify Transitive Sorry-Freedom (2 hours) [NOT STARTED]

**Dependencies**: Phase 2
**Goal**: Confirm `seedConsistent` and all dependencies are sorry-free

**Tasks**:
- [ ] Run `grep -n "sorry" RecursiveSeed.lean` - expect 0 matches
- [ ] Verify `seedConsistent` theorem compiles
- [ ] Verify transitive closure:
  - `seedConsistent` calls `buildSeedAux_preserves_seedConsistent`
  - `buildSeedAux_preserves_seedConsistent` calls supporting lemmas
  - All supporting lemmas must be sorry-free
- [ ] Run `lake build` for full project

**Verification**:
- [ ] `grep sorry RecursiveSeed.lean` returns empty
- [ ] `lake build` succeeds with clean build
- [ ] `#check seedConsistent` shows no sorry warning

---

## Extended Phases (Full Completeness - Separate Task)

These phases complete the full temporal coherent family construction but are OUT OF SCOPE for the current sorry-elimination goal.

### Phase 4: Implement seedToMCS (4-6 hours) [NOT IN SCOPE]

Apply Lindenbaum extension to each seed entry to obtain MCS family.

### Phase 5: Prove Formula Satisfaction (8-12 hours) [NOT IN SCOPE]

Prove the completed MCS family satisfies the original formula.

### Phase 6: Prove Temporal/Modal Coherence (12-20 hours) [NOT IN SCOPE]

Prove the MCS family forms a temporal and modal coherent structure.

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] Sorry count decreases: 12 -> 10 -> 0
- [ ] `seedConsistent` theorem compiles without warnings
- [ ] No new axioms introduced
- [ ] Cross-sign test: verify G phi at t=-1 reaches t=1 in seed construction

## Artifacts & Outputs

- `plans/implementation-004.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Updated `RecursiveSeed.lean` (12 sorries eliminated)
- Updated `docs/project-info/SORRY_REGISTRY.md`

## Rollback/Contingency

**Phase-level rollback**:
- Each phase committed separately
- If phase breaks invariants, revert to previous commit

**If Phase 2 blocks (IH restructuring)**:
- Try Approach B (remove hypotheses)
- If still blocked, accept technical debt with documentation
- Document in SORRY_REGISTRY.md with detailed rationale

**Full rollback**:
- RecursiveSeed.lean preserved with current sorries
- Document learnings for future attempts

## Comparison to Prior Versions

| Aspect | v001 (ZornFamily) | v002 (Two-Chain) | v003 (Unified Chain) | v004 (RecursiveSeed) |
|--------|-------------------|------------------|----------------------|----------------------|
| Target | ZornFamily.lean | DovetailingChain | UnifiedChain.lean | RecursiveSeed.lean |
| Architecture | Zorn partial families | Forward/backward chains | Combined seeds | Formula-driven seed |
| Cross-sign | BLOCKED (forward_F flaw) | BLOCKED (chain separation) | BLOCKED (MCS incompatibility) | **WORKS** (pre-placed witnesses) |
| Sorries | 5 -> BLOCKED | 4 -> BLOCKED | 4 -> BLOCKED | **12 -> 0 (target)** |
| Effort | 29-45h (blocked) | 15-21h (blocked) | 29-43h (blocked) | **12-18h (viable)** |
| Risk | HIGH | HIGH | HIGH | **MEDIUM** |

## Key Insight

RecursiveSeed succeeds where DovetailingChain variants fail because it builds the ENTIRE temporal structure syntactically BEFORE any Lindenbaum extension. Each (family, time) entry is then independently extended to an MCS. There is no "cross-MCS propagation" because all temporal constraints are already in the seed.

This is analogous to the difference between:
- **DovetailingChain**: Build house room-by-room, then try to connect plumbing between rooms
- **RecursiveSeed**: Draw complete plumbing blueprint, then build rooms around it

The blueprint approach avoids the fundamental issue of connecting independent constructions.

## Next Steps

1. Start Phase 1: Search for `List.modify` lemmas in Mathlib
2. If found, apply directly; if not, prove via induction
3. Proceed to Phase 2 after `lake build` confirms success
