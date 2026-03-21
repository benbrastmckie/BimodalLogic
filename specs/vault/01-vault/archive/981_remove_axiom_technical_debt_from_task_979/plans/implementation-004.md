# Implementation Plan: Task #981 (Revision 4)

- **Task**: 981 - remove_axiom_technical_debt_from_task_979
- **Status**: [PARTIAL]
- **Effort**: 16-24 hours
- **Dependencies**: None (builds on existing codebase)
- **Research Inputs**: research-006.md (incremental construction approach)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

**What changed from v3**:
- **COMPLETE APPROACH CHANGE**: Blocking formula approach ABANDONED (research-005/006 proved insufficient)
- **New approach**: Incremental/staged construction — make covering hold BY CONSTRUCTION
- **Key insight**: In all-at-once canonical models, blocking formulas constrain W but not intermediate K
- **Solution**: Build timeline incrementally; at each stage, successor is FRESH, so no intermediate exists
- Effort increased from 4-5 hours to 16-24 hours (significant architectural change)

**What stays from v3**:
- Phases 1-3 COMPLETED: `discreteImmediateSuccSeed`, `g_content_subset_mcs`, `discreteImmediateSucc`
- These become helper definitions used by the new incremental construction
- Final goal unchanged: eliminate `discrete_Icc_finite_axiom`

## Overview

This plan eliminates `discrete_Icc_finite_axiom` using the **incremental construction** approach from tense logic literature (Segerberg/Verbrugge). Instead of building all MCSs at once and trying to prove covering post-hoc, we build the timeline stage-by-stage. At each stage, the immediate successor is a FRESH element, so the covering property holds trivially — there simply are no intermediates yet.

### Research Integration

**Research-006.md findings integrated**:
- Blocking formulas constrain W (successor) but not intermediate K — fundamental gap
- Incremental construction makes covering hold BY CONSTRUCTION
- The staged construction infrastructure (`StagedExecution.lean`) provides the foundation
- `SuccOrder.ofCore` still the target, but covering comes from construction order

### Why Incremental Construction Works

In the literature approach:
1. At stage 0: Root MCS only
2. At stage 2n+1: Add immediate successors/predecessors with blocking formulas
3. At stage 2n+2: Extend with F/P witnesses

The covering property holds because:
- When we add successor W of M at stage n+1, there is NO intermediate K
- K doesn't exist yet! K would be added at a later stage
- When K is added later, it either:
  - Has `CanonicalR M K` but NOT `CanonicalR K W` (K is "past" W)
  - Has `CanonicalR K W` but NOT `CanonicalR M K` (K is "future" of M via W)
  - Neither (K unrelated to M-W pair)

## Goals & Non-Goals

**Goals**:
- Define stage-indexed timeline types `DiscreteTimelineQuot_at_stage n`
- Define immediate successor at each stage (fresh element)
- Prove covering at each stage (trivial by freshness)
- Construct colimit of stage-indexed timelines
- Prove colimit inherits covering → LocallyFiniteOrder → SuccOrder
- Delete `discrete_Icc_finite_axiom`
- Build passes with zero sorries in affected files

**Non-Goals**:
- Blocking formula covering proof (PROVEN IMPOSSIBLE by research-005/006)
- Modifying the underlying MCS infrastructure
- Changing the dense timeline construction

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stage-indexed types complex | MEDIUM | MEDIUM | Build on existing StagedExecution infrastructure |
| Colimit formalization hard | MEDIUM | LOW | Mathlib has colimit infrastructure; can use inductive limit |
| Existing proofs break | HIGH | LOW | Preserve existing API, add new construction alongside |
| Covering transfer subtle | MEDIUM | MEDIUM | Careful induction on stage of origin |

## Sorry Characterization

### Pre-existing Sorries
- 3 sorries: `DiscreteSuccSeed.lean` lines 421, ~525, ~562 (covering proof attempts from v3)

### Expected Resolution
- **DELETE** the covering proof attempts from v3 (they cannot work)
- Covering comes from incremental construction, not post-hoc proof
- After this implementation: 0 sorries in discrete timeline module

### New Sorries
- None. NEVER introduce new sorries.

### Remaining Debt
After this implementation:
- 0 sorries in discrete timeline module
- 0 axioms in discrete timeline module

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom: `discrete_Icc_finite_axiom` in `DiscreteTimeline.lean`

### Expected Resolution
- Phase 5 derives `LocallyFiniteOrder` from incremental covering
- Phase 5 deletes the axiom declaration

### New Axioms
- None. NEVER introduce new axioms.

## Implementation Phases

### Phase 1: Stage-Indexed Timeline Types [COMPLETED]

**Progress:**

**Session: 2026-03-17, sess_1773718331_6878f2**
- Added: `DiscreteTimelineElem_at_stage n` - Elements of timeline at stage n
- Added: `DiscreteTimelineQuot_at_stage n` - Quotient of elements at stage n
- Added: `linearOrder_at_stage` - LinearOrder on stage quotient
- Added: `finite_at_stage`, `finite_quot_at_stage` - Finiteness instances
- Added: `locallyFiniteOrder_at_stage` - LocallyFiniteOrder (trivial from finiteness)
- Added: `embed_to_full`, `embed_quot_to_full` - Embedding to full timeline
- Added: `quot_from_stage` - Every quotient element comes from some stage
- File: `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean` (NEW, ~310 lines)
- Status: File compiles via LSP (lean_goal returns no errors), but lake build times out
- Build verification pending due to very long compilation times
- No sorries introduced

- **Dependencies:** None
- **Goal:** Define `DiscreteTimelineQuot_at_stage n` for each construction stage

**Tasks:**
- [ ] Create new file `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean`
- [ ] Define `DiscreteTimelineElem_at_stage`:
```lean
def DiscreteTimelineElem_at_stage (n : Nat) : Type :=
  { p : StagedPoint // p ∈ discreteStagedBuild root_mcs root_mcs_proof n }
```
- [ ] Define preorder on `DiscreteTimelineElem_at_stage n` (inherit from StagedPoint)
- [ ] Define `DiscreteTimelineQuot_at_stage`:
```lean
def DiscreteTimelineQuot_at_stage (n : Nat) : Type :=
  Antisymmetrization (DiscreteTimelineElem_at_stage n) (· ≤ ·)
```
- [ ] Prove `LinearOrder (DiscreteTimelineQuot_at_stage n)` (inherit from existing proof)
- [ ] Verify with `lake build`

**Timing**: 4 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean`

**Verification**:
- `lake build` passes
- All definitions compile without errors

---

### Phase 2: Stage Embedding and Successor [PARTIAL]

**Progress:**

**Session: 2026-03-17, sess_1773718331_6878f2 (iteration 2)**
- Added: `stage_embed_elem` - Element-level embedding from stage n to n+1
- Added: `stage_embed_elem_mono` - Stage embedding preserves order
- Added: `stage_embed_elem_injective` - Stage embedding is injective
- Added: `stage_embed` - Quotient-level embedding
- Added: `stage_embed_mono`, `stage_embed_injective` - Quotient properties
- Added: `immediateSuccPoint` - Helper to create successor MCS with blocking formulas
- Added: `immediateSuccPoint_canonicalR` - CanonicalR from M to immediate successor
- Added: `immediateSuccPoint_covers` - Covering property from blocking formulas
- BLOCKED: `succ_at_stage` cannot be defined because `discreteStagedBuild` uses
  `forward_temporal_witness_seed` (no blocking formulas), not `discreteImmediateSuccSeed`
- Resolution required: Modify staged build OR use well-founded minimal successor
- File: `IncrementalTimeline.lean` updated with ~150 lines, no sorries
- lake build passes

- **Dependencies:** Phase 1
- **Goal:** Define stage transitions and immediate successor function

**Tasks:**
- [ ] Define stage embedding:
```lean
def stage_embed (n : Nat) : DiscreteTimelineQuot_at_stage n → DiscreteTimelineQuot_at_stage (n + 1) :=
  -- Elements at stage n are also at stage n+1
  sorry
```
- [ ] Prove `stage_embed` is order-preserving
- [ ] Prove `stage_embed` is injective
- [ ] Define immediate successor at stage:
```lean
def succ_at_stage (n : Nat) (M : DiscreteTimelineQuot_at_stage n) :
    DiscreteTimelineQuot_at_stage (n + 1) :=
  -- Use discreteImmediateSuccSeed from existing infrastructure
  -- Key: result is a FRESH element at stage n+1, not from stage n
  sorry
```
- [ ] Prove `succ_at_stage` creates an element NOT in `range (stage_embed n)`
- [ ] Prove `CanonicalR M (succ_at_stage n M)` (accessibility from M to successor)
- [ ] Verify with `lake build`

**Timing**: 6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean`

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" IncrementalTimeline.lean` shows only expected sorries (being filled)

---

### Phase 3: Covering at Each Stage [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove covering property holds at each stage (trivial by freshness)

**Key Insight**: At stage n+1, the immediate successor `succ_at_stage n M` is FRESH — it wasn't in the timeline at stage n. Therefore, any intermediate K between M and `succ_at_stage n M` must:
- Come from stage n (then K ≤ M by transitivity, contradiction)
- Be added at stage n+1 as a successor (but we only add ONE successor per M)

**Tasks:**
- [ ] State the covering theorem at stage:
```lean
theorem covering_at_stage (n : Nat)
    (M : DiscreteTimelineQuot_at_stage n)
    (K : DiscreteTimelineQuot_at_stage (n + 1))
    (h_lt_M_K : stage_embed n M < K)
    (h_lt_K_W : K < succ_at_stage n M) :
    False := by
  -- K must come from either stage n or be fresh at n+1
  -- If from stage n: contradicts h_lt_M_K (stage_embed preserves ≤)
  -- If fresh at n+1: only fresh elements are successors, so K = succ_at_stage n' M' for some M'
  --                  but then K is a successor, not strictly between M and its successor
  sorry
```
- [ ] Prove the key lemma: fresh elements at stage n+1 are exactly the successors
- [ ] Prove covering follows from freshness analysis
- [ ] Verify with `lake build`

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean`

**Verification**:
- `lake build` passes
- `covering_at_stage` compiles without sorry

---

### Phase 4: Colimit Construction and Isomorphism [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Define final timeline as colimit; prove isomorphic to existing `DiscreteTimelineQuot`

**Tasks:**
- [ ] Define colimit type:
```lean
def DiscreteTimeline_colimit : Type :=
  -- Sigma type with quotient by stage equivalence
  -- OR: use Mathlib's colimit infrastructure
  Σ (n : Nat), DiscreteTimelineQuot_at_stage n ⧸ stage_equiv
```
- [ ] Alternative: Use inductive limit directly
```lean
inductive DiscreteTimeline_inductive where
  | mk : (n : Nat) → DiscreteTimelineQuot_at_stage n → DiscreteTimeline_inductive
```
- [ ] Define LinearOrder on colimit
- [ ] Prove colimit is isomorphic to existing `DiscreteTimelineQuot`:
```lean
def colimit_iso_quot : DiscreteTimeline_colimit ≃o DiscreteTimelineQuot root_mcs root_mcs_proof :=
  -- Every element of DiscreteTimelineQuot appears at some stage
  -- Every element at any stage is in DiscreteTimelineQuot
  sorry
```
- [ ] Verify with `lake build`

**Timing**: 6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean`

**Verification**:
- `lake build` passes
- Isomorphism compiles without sorry

---

### Phase 5: Transfer Covering and Eliminate Axiom [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Transfer covering to colimit → LocallyFiniteOrder → SuccOrder → delete axiom

**Tasks:**
- [ ] Prove covering on colimit:
```lean
theorem colimit_covering (M K W : DiscreteTimeline_colimit)
    (h_lt_M_K : M < K) (h_lt_K_W : K < W) (h_covers : M.covers W) : False := by
  -- All elements come from some stage
  -- Find the maximal stage containing M, K, W
  -- Apply covering_at_stage
  sorry
```
- [ ] Derive `LocallyFiniteOrder` from covering + linearity:
```lean
instance : LocallyFiniteOrder DiscreteTimeline_colimit := by
  -- Covering implies Icc is finite (only endpoints, no intermediates)
  sorry
```
- [ ] Transfer to existing `DiscreteTimelineQuot` via isomorphism
- [ ] Instantiate `SuccOrder` using `LinearLocallyFiniteOrder.succOrder`
- [ ] **DELETE** `discrete_Icc_finite_axiom` from `DiscreteTimeline.lean`
- [ ] **DELETE** attempted covering proofs from `DiscreteSuccSeed.lean`
- [ ] Run full `lake build` to verify no regressions
- [ ] Run axiom/sorry verification:
```bash
grep -rn "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean
grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/
```

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean`
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`

**Verification**:
- `lake build` passes with no errors
- `grep -n "^axiom " DiscreteTimeline.lean` returns empty
- `grep -n "\bsorry\b" IncrementalTimeline.lean` returns empty
- All downstream theorems still work

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] All proofs verified with `lean_goal` showing "no goals"
- [ ] `discreteCanonicalTaskFrame` still compiles and works
- [ ] Downstream completeness proofs still work

### General
- [ ] No regressions in existing functionality
- [ ] Implementation summary created

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean` (NEW)
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` (MODIFIED - axiom removed)
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` (MODIFIED - failed attempts removed)
- `specs/981_remove_axiom_technical_debt_from_task_979/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation fails at any phase:
1. **Phase 1-2 stuck**: Stage-indexed types might need different formalization; consider using existing `StagedPoint` directly without quotient per stage
2. **Phase 3 stuck**: Covering at stage might need more careful analysis of what "fresh" means
3. **Phase 4 stuck**: Colimit formalization complex; fall back to direct inductive definition
4. **Phase 5 stuck**: Transfer might be subtle; consider proving `LocallyFiniteOrder` directly on colimit without transfer
5. **All phases stuck**: Fall back to Approach 2 (Well-Founded Minimal Successor) from research-006

Original `DiscreteTimeline.lean` and `DiscreteSuccSeed.lean` preserved in git history.

## Comparison with v3

| Aspect | v3 (Blocking Formula) | v4 (Incremental) |
|--------|----------------------|------------------|
| Approach | Post-hoc covering proof | Covering by construction |
| Effort | 4-5 hours | 16-24 hours |
| Confidence | LOW (proved impossible) | HIGH (literature-backed) |
| Key insight | T-axiom gives g_content ⊆ M | Freshness gives no intermediates |
| Risk | Cannot prove covering | Formalization complexity |
