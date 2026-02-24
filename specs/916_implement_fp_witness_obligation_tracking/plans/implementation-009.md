# Implementation Plan: Task #916

- **Task**: 916 - Implement F/P Witness Obligation Tracking
- **Status**: [IMPLEMENTING]
- **Effort**: 8-14 hours (revised from 12-20)
- **Dependencies**: None
- **Research Inputs**: research-013.md (8 error fix analysis with Option A recommendation)
- **Artifacts**: plans/implementation-009.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean
- **Lean Intent**: true
- **Version**: 009 (revised from 008 based on research-013)

## Overview

This plan revises implementation-008 based on research-013's detailed analysis of the remaining 8 build errors. Research-013 identified that all 8 errors stem from a common root cause: dependent type rewriting when `processStep` output must be equated with `addFutureWitness` or `addPastWitness`. Option A (dependent rewrite patterns) is the recommended fix approach.

### Key Changes from v008

1. **Phase 3A refined**: Focus on 8 specific errors using `congrArg`-based patterns
2. **Effort reduced**: 8-14 hours remaining (down from 12-20)
3. **Specific fix order**: Prioritized from easiest to hardest per research-013
4. **Contingency plan**: Targeted sorries if any single error takes >1 hour

### Current State (from research-013)

| Metric | Value |
|--------|-------|
| Lines | 2,419 |
| Sorries | 0 (syntactically) |
| Build errors | **8** |
| Mathematical approach | Correct |

### Error Classification (8 Errors)

| Category | Lines | Root Cause |
|----------|-------|------------|
| Dependent index transport | 1700, 1816 | Struct rewrite through indexed access |
| processStep unfolding | 1980-1981 | Split targets wrong expression |
| Placeholder synthesis | 2135 | `[_]` in list literal |
| Split on unfolded processStep | 2260, 2386 | Match on Nat.unpair not recognized |

## Goals & Non-Goals

**Goals** (unchanged):
- Close forward_F and backward_P sorries in DovetailingChain.lean
- Produce BFMCS Int via witness graph construction

**Non-Goals** (unchanged):
- Modifying DovetailingChain.lean construction
- Cross-sign propagation (separate task)

## Implementation Phases

### Phase 3A: Fix 8 Build Errors [COMPLETED]

- **Dependencies**: None
- **Goal**: Make WitnessGraph.lean build cleanly with 0 errors, 0 sorries
- **Estimated effort**: 2.5-3.5 hours

**Historical Progress (from v008):**

**Session: 2026-02-24, sess_1771904039_b1889e**
- Reduced errors from 48 to 33, then to 8
- Key fixes: Declaration ordering, syntax fixes, dependent elimination
- Remaining: 8 specific errors documented in research-013

**Fix Implementation Order** (per research-013, easiest to hardest):

#### Step 1: Line 2135 (placeholder synthesis) - 10 min
**Location**: `processStep_new_edge_nodes_gt`, contradiction case
**Problem**: `have : g.edges.length = (g.edges ++ [_]).length` fails (placeholder in list literal)
**Fix Pattern**:
```lean
-- Replace [_] placeholder with congrArg approach
have := congrArg List.length h_edges
simp at this
```
This avoids the placeholder entirely by leveraging the existing equality `h_edges`.

#### Step 2: Line 1816 (direct congrArg) - 10 min
**Location**: `backward_witness_of_isWitnessed`, case: processStep = addPastWitness
**Problem**: `congr 1; exact h_ps_eq` decomposes getElem incorrectly
**Fix Pattern**:
```lean
-- Replace congr 1 with direct field access
exact congrArg WitnessGraph.nodes h_ps_eq
```

#### Step 3: Line 1700 (node transport) - 20-30 min
**Location**: `forward_witness_of_isWitnessed`, case: processStep = addFutureWitness
**Problem**: `simp` can't rewrite through dependent bound proof in indexed access
**Fix Pattern**:
```lean
-- Extract .nodes equality first, then transport
have h_nodes_eq : (processStep g m).nodes = (g.addFutureWitness ...).nodes :=
  congrArg WitnessGraph.nodes h_ps_eq
rw [show (processStep g m).nodes[idx] = (g.addFutureWitness ...).nodes[idx] from by simp [h_nodes_eq]]
```

#### Step 4: Lines 1980-1981 (split targeting) - 30-45 min
**Location**: `witnessGraph_backward_P_local`, isWitnessed becomes true
**Problem**: `split` picks wrong expression after `unfold processStep`
**Fix Pattern**:
```lean
-- Rewrite decode BEFORE split to collapse the match
unfold processStep
simp only [h_unpair, show i < g_n.nodes.length from h_i_at_n, dite_true]
have h_decode := decodeFormulaWG_encodeFormulaWG psi
rw [h_decode]  -- rewrite BEFORE split
simp only [h_F_at_n, dite_true, h_F_wit_false, ite_false]
-- Now we're directly in addFutureWitness branch
```

#### Step 5: Lines 2260, 2386 (avoid unfold) - 45-60 min + 30-45 min
**Location**: `witnessGraph_GContent_propagates` and `witnessGraph_HContent_propagates`
**Problem**: `split` fails on match over `Nat.unpair` result
**Fix Pattern** (do NOT unfold processStep):
```lean
-- Instead of unfold processStep, use processStep_outcome
have h_out := processStep_outcome g n
rcases h_out with h_unchanged | ⟨nIdx, h_nIdx, psi, h_F, h_ps_eq⟩ |
    ⟨nIdx, h_nIdx, psi, h_P, h_ps_eq⟩
-- In the addFutureWitness case:
have h_nodes_eq := congrArg WitnessGraph.nodes h_ps_eq
simp only [WitnessGraph.addFutureWitness] at h_nodes_eq
-- Use addFutureWitness_GContent_extends / addPastWitness_HContent_extends
```

May require a helper lemma connecting `processStep_outcome` with `processStep_edges_subset_or_new`.

**Contingency**: If any single error takes >1 hour, insert a targeted `sorry` for that location and continue. This limits proof debt to 1-2 sorries rather than blocking all progress.

**Verification**:
```bash
lake build Bimodal.Metalogic.Bundle.WitnessGraph
# Must produce: 0 errors, 0 warnings
```

**Exit criteria**:
- [x] `lake build Bimodal.Metalogic.Bundle.WitnessGraph` succeeds
- [x] 0 sorries in WitnessGraph.lean
- [x] `end Bimodal.Metalogic.Bundle` present at file end

**Progress:**

**Session: 2026-02-24, sess_1771904039_b1889e**
- Reduced errors from 48 to 33, then to 8
- Key fixes: Declaration ordering, syntax fixes, dependent elimination
- Remaining: 8 specific errors documented in research-013

**Session: 2026-02-23, sess_1771912616_e1d1af**
- Fixed: Line 2135 placeholder synthesis - replaced `[_]` with `congrArg List.length h_edges`
- Fixed: Line 1816 type mismatch - replaced `congr 1` with `congrArg WitnessGraph.nodes h_ps_eq; simp`
- Fixed: Line 1700 simp no progress - extracted `.nodes` equality via `congrArg`, then transported index
- Fixed: Lines 1980-1981 split targeting - rewrote decode BEFORE split with `simp only [h_decode]`
- Fixed: Lines 2260/2386 split failure - replaced `unfold processStep; split` with `processStep_outcome` + `congrArg`
- Completed: Phase 3A (all 8 errors fixed)
- Build errors: 8 -> 0

---

### Phase 4: Int Embedding [COMPLETED]

- **Dependencies**: Phase 3A
- **Goal**: Define BFMCS Int from witness graph
- **Estimated effort**: 3-5 hours

**Design revision**: The original plan proposed a direct node-index-to-Int mapping
(`mcs t := g.mcsAt t.toNat`). Analysis revealed this does NOT give forward_G, because
the witness graph contains backward edges where HContent (not GContent) propagates.
Two consecutive nodes connected by a backward edge would violate the forward_G requirement
that G(phi) at time t implies phi at time t' for ALL t < t'.

**Revised approach**: Use a constant family (all times map to rootMCS). The T-axiom
(G phi -> phi, H phi -> phi) gives forward_G and backward_H trivially. The witness graph
serves as an "oracle" for Phase 5/6: it proves that F/P obligations at the root have
witnesses in the graph. Phase 5 will connect these to the BFMCS.

**Tasks**:
- [x] Define `mcs_G_implies_self`, `mcs_H_implies_self`, `mcs_G_implies_GG` helpers
- [x] Define `witnessGraphBFMCS : rootMCS → BFMCS Int` (constant family)
- [x] Prove `witnessGraphBFMCS_mcs_eq`: mcs(t) = rootMCS.val for all t
- [x] Prove `witnessGraphBFMCS_root_preserved`: context at time 0
- [x] Prove `witnessGraph_root_mcs`: node 0 in graph has rootMCS
- [x] Prove `witnessGraphBFMCS_edge_ordering_compatible`: edge ordering lifts to Int
- [x] Prove `witnessGraph_forward_F_at_root`: F(psi) at root has witness in graph
- [x] Prove `witnessGraph_backward_P_at_root`: P(psi) at root has witness in graph

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.WitnessGraph` succeeds (0 sorries, 0 errors)

**Progress:**

**Session: 2026-02-23, sess_1771912616_e1d1af**
- Added: `mcs_G_implies_self`, `mcs_H_implies_self`, `mcs_G_implies_GG` - T/4-axiom helpers
- Added: `witnessGraphBFMCS` - constant BFMCS Int from root MCS
- Added: `witnessGraph_root_mcs` - root node identity (induction on k)
- Added: `witnessGraph_forward_F_at_root` - F-witness bridge lemma
- Added: `witnessGraph_backward_P_at_root` - P-witness bridge lemma
- Completed: Phase 4 (revised from direct mapping to constant family approach)
- Design note: Direct node-index mapping fails for forward_G with backward edges

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

## Summary of Changes from v008

| Aspect | v008 | v009 |
|--------|------|------|
| Total effort | 12-20 hours | 8-14 hours |
| Phase 3A errors | 48 → "fix remaining" | 8 specific errors with patterns |
| Fix approach | Priority categories | Specific code patterns per error |
| Fix order | By category | By difficulty (easiest first) |
| Contingency | Revert to committed | Targeted sorry (max 1-2) |
| Research basis | research-012 | research-013 |

## Key Technical Insights

From research-013:

1. **Never unfold processStep in content propagation proofs**. Use `processStep_outcome` + `congrArg` instead.
2. **Work at the `.nodes` field level**, not the struct level, when transporting through indexed access.
3. **Rewrite decode before splitting** when manually unfolding processStep for isWitnessed proofs.
4. **`congrArg` is the key pattern**: `congrArg WitnessGraph.nodes h_ps_eq` extracts field equality from struct equality.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Lines 2260/2386 need helper lemma | MEDIUM | MEDIUM | Factor out processStep_outcome ↔ edges reconciliation |
| Line 1980 decode rewrite fails under binder | LOW | LOW | Use `conv` or `simp only` instead of `rw` |
| Cascading errors from fixes | LOW | LOW | Build after each fix |

## Fallback Plan

If Phase 3A proves too complex (>5 hours without progress):

1. Insert targeted sorries at the 4 hardest locations (2260, 2386, 1980-1981)
2. Complete Phases 4-6 with sorry scaffolding
3. Create follow-up task to close the 4 sorries

## Success Criteria

- [ ] WitnessGraph.lean: 0 sorries, 0 errors
- [ ] DovetailingChain.lean forward_F/backward_P: 0 sorries
- [ ] `lake build` succeeds
- [ ] No new axioms introduced
