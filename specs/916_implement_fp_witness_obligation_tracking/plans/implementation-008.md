# Implementation Plan: Task #916

- **Task**: 916 - Implement F/P Witness Obligation Tracking
- **Status**: [IMPLEMENTING]
- **Effort**: 12-20 hours (revised from 28-44)
- **Dependencies**: None
- **Research Inputs**: research-012.md (progress review with 48 errors)
- **Artifacts**: plans/implementation-008.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean
- **Lean Intent**: true
- **Version**: 008 (revised from 007 based on research-012)

## Overview

This plan revises implementation-007 based on research-012. The working copy of WitnessGraph.lean has 911 lines of mathematically-sound proof code attempting to close all 5 sorries, but with 48 mechanical build errors. The errors are fixable without changing the mathematical strategy.

### Key Changes from v007

1. **New Phase 3A**: Fix 48 build errors in working copy (NOT revert)
2. **Effort reduced**: 12-20 hours remaining (down from 28-44)
3. **Skip sorry-by-sorry approach**: Working copy already tackled all 5 sorries simultaneously
4. **Phases 3B-3D eliminated**: Merged into Phase 3A (error fixing preserves the existing proofs)

### Current State (from research-012)

| Metric | Committed (9d95c405) | Working Copy |
|--------|---------------------|--------------|
| Lines | 1,578 | 2,489 |
| Sorries | 5 | 0 (syntactically) |
| Build errors | 0 | **48** |
| Mathematical approach | - | Correct |

The working copy's approach:
- Modified `processStep` for F-blocks-P case
- Added `forward_witness_of_isWitnessed`/`backward_witness_of_isWitnessed` induction helpers
- Added `processStep_isWitnessed_monotone`
- Full induction proofs for GContent/HContent propagation

## Goals & Non-Goals

**Goals** (unchanged):
- Close forward_F and backward_P sorries in DovetailingChain.lean
- Produce BFMCS Int via witness graph construction

**Non-Goals** (unchanged):
- Modifying DovetailingChain.lean construction
- Cross-sign propagation (separate task)

## Error Classification (48 Errors)

From research-012:

| Category | Count | Lines | Fix Strategy |
|----------|-------|-------|--------------|
| Dependent elimination | 4 | 1427, 1459, 2366, 2417 | Use `rcases`/`obtain` instead of `cases` |
| `cases h :=` syntax | 6 | 1615, 1768, 1977 | Replace with `cases`/`by_cases`/`match` |
| Unknown identifier | 5 | 1467, 2317-2318, 2452-2453 | Move `processStep_edges_subset_or_new` earlier |
| Unsolved goals | 8 | 1464, 1606, 1612, ... | Complete proof steps |
| simp/omega failures | ~12 | 2192-2238 | Correct unfolding |
| Invalid projection | 2 | 2314, 2450 | Use `(h1, h2)` not `h_new.2.2` |
| Type mismatch | 5 | 2192-2238 | Fix edge validity types |
| Unknown tactic | 1 | 1523 | Fix `rfl.symm` usage |
| Cascading/missing `end` | ~5 | Various | Restore namespace closer |

## Implementation Phases

### Phase 3A: Fix 48 Build Errors [NOT STARTED]

- **Dependencies**: None
- **Goal**: Make WitnessGraph.lean build cleanly with 0 errors, 0 sorries
- **Estimated effort**: 4-6 hours

**Priority order for fixes:**

1. **Declaration ordering** (eliminates ~5 errors):
   - Move `processStep_edges_subset_or_new` (currently line ~2070) before `processStep_isWitnessed_monotone` (line ~1462)
   - The working copy version already handles the F-witnessed-then-P branch correctly

2. **Syntax fixes** (eliminates ~7 errors):
   - Replace `cases h :=` patterns with `cases h` or `by_cases` or explicit `match`
   - Fix `rfl.symm` → use `Eq.symm rfl` or `rfl`

3. **Dependent elimination** (eliminates ~4 errors):
   - Replace `cases h` on `List.mem_append` with `rcases h with (h|h)` or `obtain`
   - Lean 4's `cases` can't handle dependent elimination on these

4. **Projection fixes** (eliminates ~2 errors):
   - Change `h_new.2.2` to proper tuple destructuring `⟨h1, h2⟩`
   - The new backward edge case destructures as `(src_eq, psi_eq)` not a structure

5. **simp/omega failures** (eliminates ~12 errors):
   - In `processStep_edgesValid`, ensure proper unfolding of `addFutureWitness`/`addPastWitness`
   - Use `simp only [...]` with explicit lemmas instead of bare `simp`

6. **Unsolved goals** (eliminates ~8 errors):
   - Complete incomplete proof steps
   - Some may need additional helper lemmas

7. **Namespace closer** (eliminates ~1 cascading error):
   - Add `end Bimodal.Metalogic.Bundle` at end of file

**Verification**:
```bash
lake build Bimodal.Metalogic.Bundle.WitnessGraph
# Must produce: 0 errors, 0 warnings (sorries show as warnings in some configs)
```

**Exit criteria**:
- [ ] `lake build Bimodal.Metalogic.Bundle.WitnessGraph` succeeds
- [ ] 0 sorries in WitnessGraph.lean
- [ ] `end Bimodal.Metalogic.Bundle` present at file end

---

### Phase 4: Int Embedding [NOT STARTED]

- **Dependencies**: Phase 3A
- **Goal**: Define BFMCS Int from witness graph
- **Estimated effort**: 3-5 hours

**Simplification**: Since edges satisfy `src < dst` (proven in WitnessGraph as `witnessGraph_edges_acyclic`), use node index directly as the Int embedding. No topological sort needed.

**Tasks**:
- [ ] Define `witnessGraphBFMCS : WitnessGraph → BFMCS Int`:
  ```lean
  def witnessGraphBFMCS (g : WitnessGraph) : BFMCS Int where
    mcs t := if t < 0 then g.mcsAt 0  -- negative: default to root
             else if h : t.toNat < g.nodes.length then g.mcsAt t.toNat
             else g.mcsAt (g.nodes.length - 1)  -- beyond: default to last
  ```
- [ ] Prove `witnessGraphBFMCS_at_node`: For valid node i, mcs(i) = g.mcsAt i
- [ ] Prove embedding preserves strict ordering on edges

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.WitnessGraph` succeeds (0 sorries)

---

### Phase 5: Global Temporal Coherence [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Prove all 4 temporal coherence properties for BFMCS
- **Estimated effort**: 3-5 hours

**Key insight**: These become near-corollaries of Phase 3A properties combined with Phase 4 embedding.

**Tasks**:
- [ ] Prove `witnessGraphBFMCS_forward_G`:
  - If G(phi) ∈ mcs(t) and t < s, then phi ∈ mcs(s)
  - Uses: GContent propagation + embedding
- [ ] Prove `witnessGraphBFMCS_backward_H`:
  - Symmetric to forward_G
- [ ] Prove `witnessGraphBFMCS_forward_F`:
  - If F(phi) ∈ mcs(t), then ∃s > t with phi ∈ mcs(s)
  - Uses: `witnessGraph_forward_F_local` + embedding
- [ ] Prove `witnessGraphBFMCS_backward_P`:
  - Symmetric to forward_F

**Verification**:
- All 4 theorems proven without sorry

---

### Phase 6: Integration [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Replace sorries in DovetailingChain.lean
- **Estimated effort**: 2-4 hours

**Tasks**:
- [ ] Add import of WitnessGraph.lean to DovetailingChain.lean
- [ ] Define `buildDovetailingChainFamily` using `witnessGraphBFMCS`
- [ ] Wire `witnessGraphBFMCS_forward_F` to close sorry at line 1754
- [ ] Wire `witnessGraphBFMCS_backward_P` to close sorry at line 1761
- [ ] Verify `lake build` succeeds with 0 new sorries
- [ ] Create implementation summary

**Verification**:
```bash
lake build
# Must succeed with no new sorries in DovetailingChain.lean
```

---

## Summary of Changes from v007

| Aspect | v007 | v008 |
|--------|------|------|
| Total effort | 28-44 hours | 12-20 hours |
| Phase 3 approach | 4 sub-phases (3A-3D) | Single error-fixing phase |
| Starting point | Committed version (5 sorries) | Working copy (48 errors, 0 sorries) |
| Mathematical work | To be done | Already done (needs debugging) |
| Phases 4-6 | Unchanged | Simplified estimates |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Cascading errors harder than expected | LOW | MEDIUM | Fix in priority order (declaration ordering first) |
| Working copy has logical errors (not just syntax) | LOW | HIGH | Fallback: revert to committed, apply changes incrementally |
| Some proofs genuinely incomplete | MEDIUM | MEDIUM | Add `sorry` temporarily, track as sub-tasks |

## Fallback Plan

If Phase 3A proves too complex (>8 hours without progress):

1. Revert WitnessGraph.lean: `git checkout HEAD -- Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`
2. Apply changes incrementally, building after each logical unit
3. Follow original v007 sub-phases (3A → 3B → 3C → 3D)

## Success Criteria

- [ ] WitnessGraph.lean: 0 sorries (currently 0 syntactically, 48 errors)
- [ ] DovetailingChain.lean forward_F/backward_P: 0 sorries (currently 2)
- [ ] `lake build` succeeds
- [ ] No new axioms introduced
