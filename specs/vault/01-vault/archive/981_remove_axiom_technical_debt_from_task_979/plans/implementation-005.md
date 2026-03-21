# Implementation Plan: Task #981 (Revision 5)

- **Task**: 981 - remove_axiom_technical_debt_from_task_979
- **Status**: [PARTIAL]
- **Effort**: 12-16 hours
- **Dependencies**: None (builds on existing codebase)
- **Research Inputs**: research-006.md (Approach 2: Well-Founded Minimal Successor)
- **Artifacts**: plans/implementation-005.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

**What changed from v4**:
- **APPROACH CHANGE**: Incremental construction (Approach 1) ABANDONED due to architectural mismatch
- **New approach**: Well-Founded Minimal Successor (Approach 2 from research-006)
- **Key insight**: Define `succ(M) := min { K : MCS | CanonicalR M K }` using well-ordering
- **Why change**: Phase 2 of v4 was BLOCKED because `discreteStagedBuild` uses `forward_temporal_witness_seed` (no blocking formulas), not `discreteImmediateSuccSeed`
- **Advantage**: Does NOT require modifying StagedExecution.lean or staged build infrastructure
- Effort reduced from 16-24 hours to 12-16 hours (simpler mathematical approach)

**What stays from v4**:
- Phase 1 COMPLETED: Stage-indexed infrastructure (`IncrementalTimeline.lean`)
- Final goal unchanged: eliminate `discrete_Icc_finite_axiom`
- The stage-indexed types from Phase 1 may serve as utility/reference but are not required for Approach 2

## Overview

This plan eliminates `discrete_Icc_finite_axiom` using the **Well-Founded Minimal Successor** approach from research-006. Instead of constructing a specific successor with blocking formulas and proving covering post-hoc, we define the successor as the MINIMAL forward-accessible MCS. Covering then follows TRIVIALLY from minimality.

### Research Integration

**Research-006.md Approach 2 findings integrated**:
- Define `succ(M) := min { K : MCS | CanonicalR M K }` using a well-ordering on MCSs
- Covering is trivial: any K > M has `succ(M) <= K` by minimality
- No modification to staged build required
- Requires: (1) well-ordering on MCSs, (2) WellFounded.min from Mathlib

### Why Well-Founded Minimal Successor Works

The covering property states: For MCS M and successor W, any K with `CanonicalR M K` and `CanonicalR K W` must satisfy `K = M` or `K = W`.

With minimal successor definition:
1. `succ(M)` is the LEAST K (under some well-ordering) with `CanonicalR M K`
2. For any K with `CanonicalR M K` and `K != M`, we have `succ(M) <= K` by minimality
3. Covering follows: if `M < K < W = succ(M)`, then `succ(M) <= K < succ(M)`, contradiction

This is the same technique used in Mathlib's `SuccOrder.ofLinearWellFoundedLT`.

## Goals & Non-Goals

**Goals**:
- Define a well-ordering on `DiscreteTimelineQuot`
- Define `discreteSucc` as the minimal forward-accessible element
- Prove covering from minimality
- Derive `LocallyFiniteOrder` from covering + linearity
- Instantiate `SuccOrder` via `SuccOrder.ofCore`
- Delete `discrete_Icc_finite_axiom`
- Build passes with zero sorries in affected files

**Non-Goals**:
- Modifying `StagedExecution.lean` or the staged build infrastructure
- Using blocking formulas for covering (PROVEN IMPOSSIBLE by research-005)
- Incremental/colimit construction (Approach 1 - too complex without staged build changes)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Well-ordering formalization tricky | MEDIUM | MEDIUM | Use classical choice + Mathlib `WellFounded.min` |
| CanonicalR ordering doesn't align | MEDIUM | LOW | Use separate well-ordering independent of CanonicalR |
| Covering proof has edge cases | LOW | MEDIUM | Careful case analysis on M = min case |
| Existing proofs break | HIGH | LOW | Preserve existing API, add new construction |

## Sorry Characterization

### Pre-existing Sorries
- 3 sorries: `DiscreteSuccSeed.lean` lines ~525, ~562, ~595 (covering proof attempts from v3)
- These sorries are in the ABANDONED blocking formula approach

### Expected Resolution
- **DELETE** the covering proof attempts from v3 (they cannot work)
- Covering comes from minimal successor definition, not blocking formula constraints
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
- Phase 4 derives `LocallyFiniteOrder` from covering via minimal successor
- Phase 4 deletes the axiom declaration

### New Axioms
- None. NEVER introduce new axioms.

## Implementation Phases

### Phase 1: Stage-Indexed Infrastructure [COMPLETED]

**Progress:**

**Session: 2026-03-17, sess_1773718331_6878f2**
- Added: `DiscreteTimelineElem_at_stage n` - Elements of timeline at stage n
- Added: `DiscreteTimelineQuot_at_stage n` - Quotient of elements at stage n
- Added: `linearOrder_at_stage` - LinearOrder on stage quotient
- Added: `finite_at_stage`, `finite_quot_at_stage` - Finiteness instances
- Added: `locallyFiniteOrder_at_stage` - LocallyFiniteOrder (trivial from finiteness)
- Added: `embed_to_full`, `embed_quot_to_full` - Embedding to full timeline
- Added: `quot_from_stage` - Every quotient element comes from some stage
- File: `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean` (~310 lines)
- Status: lake build passes
- No sorries introduced

**Note for Approach 2**: This infrastructure is retained but not strictly required. The key result `quot_from_stage` (every element comes from some stage) may be useful for proving properties, but the core Approach 2 path works directly on `DiscreteTimelineQuot`.

---

### Phase 2: Well-Ordering on DiscreteTimelineQuot [BLOCKED]

**Progress:**

**Session: 2026-03-17, sess_1773756442_ae96f4**
- Analyzed: Mathematical foundations of Approach 2 (well-founded minimal successor)
- Discovered: **Fundamental conceptual flaw** in Approach 2
- Issue: An arbitrary well-ordering `≺` on MCSs gives `≺`-minimal elements, NOT timeline-minimal elements
- The `SuccOrder.ofCore` condition requires `a < b ↔ succ a ≤ b` in the **timeline order**
- `WellFounded.min` with an arbitrary well-order does NOT guarantee timeline minimality
- Mathlib's `exists_wellOrder` can give a well-order, but it's unrelated to the timeline order
- The timeline order `<` is NOT well-founded (unbounded in both directions)
- **Blocker**: Need to prove that well-order minimality implies timeline minimality, which requires a specific relationship between the two orders that does not exist in general

**Alternative Approaches Analyzed**:
1. Use `SuccOrder.ofLinearWellFoundedLT` - blocked because timeline `<` is not well-founded
2. Prove `WellFoundedLT` on `Ioi M` - requires proving no infinite descending chains, which IS the covering property
3. Use staged construction - `discreteStagedBuild` uses `forward_temporal_witness_seed` (no blocking formulas)
4. Use `discreteImmediateSucc` covering - has 3 sorries at lines 525, 562, 595 of `DiscreteSuccSeed.lean`

**Recommendation**: The approach in this plan has a mathematical gap. Consider:
1. Proving the blocking formula covering (complete the sorries in `DiscreteSuccSeed.lean`)
2. OR: Modifying `discreteStagedBuild` to use `discreteImmediateSuccSeed` instead of `forward_temporal_witness_seed`
3. OR: Accepting the axiom as documented technical debt

- **Dependencies:** None
- **Goal:** Define a well-ordering on `DiscreteTimelineQuot` suitable for minimal successor extraction

**Mathematical Approach**:

MCSs can be well-ordered by formula membership:
1. Enumerate all formulas as `f_0, f_1, f_2, ...` (finite formula language has enumeration)
2. Define `mcs_lt M N := exists i, f_i in M \ N and (forall j < i, f_j in M <-> f_j in N)`
3. This is a well-ordering: any two distinct MCSs differ on some formula

Alternatively, use Mathlib's `WellFounded.wellOrderExtension` to extend any well-founded relation to a well-ordering.

**Tasks:**
- [ ] Define formula enumeration `formulaIndex : Formula -> Nat` (or use existing)
- [ ] Define `mcsLT : DiscreteTimelineQuot -> DiscreteTimelineQuot -> Prop`:
```lean
def mcsLT (M N : DiscreteTimelineQuot root_mcs root_mcs_proof) : Prop :=
  -- Lexicographic on formula membership
  exists i : Nat, (formulaAt i ∈ mcsOf M) ≠ (formulaAt i ∈ mcsOf N) ∧
    ∀ j < i, (formulaAt j ∈ mcsOf M) ↔ (formulaAt j ∈ mcsOf N)
```
- [ ] Prove `WellFounded mcsLT`:
```lean
theorem mcsLT_wellFounded : WellFounded mcsLT := by
  -- Any descending chain must stabilize by formula index
  sorry
```
- [ ] Alternative: Use `Classical.choice` with `WellFounded.wellOrderExtension`
- [ ] Verify with `lake build`

**Timing**: 4 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` (add well-ordering)

**Verification**:
- `lake build` passes
- `mcsLT_wellFounded` compiles without sorry

---

### Phase 3: Minimal Successor Definition [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Define `discreteSucc` as the minimal forward-accessible element using `WellFounded.min`

**Mathematical Definition**:
```
discreteSucc(M) := WellFounded.min mcsLT_wf { K | CanonicalR M K ∧ K ≠ M } h_nonempty
```

where `h_nonempty` comes from seriality (task frame has no maximal elements).

**Tasks:**
- [ ] Prove forward successors exist (from seriality):
```lean
theorem forward_successors_nonempty (M : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    { K | CanonicalR M K ∧ K ≠ M }.Nonempty := by
  -- From NoMaxOrder / seriality
  sorry
```
- [ ] Define minimal successor:
```lean
noncomputable def discreteSucc (M : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    DiscreteTimelineQuot root_mcs root_mcs_proof :=
  WellFounded.min mcsLT_wf { K | CanonicalR M K ∧ K ≠ M } (forward_successors_nonempty M)
```
- [ ] Prove `discreteSucc` properties:
```lean
theorem discreteSucc_mem (M : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    CanonicalR M (discreteSucc M) ∧ discreteSucc M ≠ M :=
  WellFounded.min_mem mcsLT_wf _ _

theorem discreteSucc_minimal (M K : DiscreteTimelineQuot root_mcs root_mcs_proof)
    (hK : CanonicalR M K) (hK_ne : K ≠ M) :
    ¬mcsLT K (discreteSucc M) :=
  WellFounded.not_lt_min mcsLT_wf _ _ ⟨hK, hK_ne⟩
```
- [ ] Verify with `lake build`

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Verification**:
- `lake build` passes
- `discreteSucc` compiles without sorry

---

### Phase 4: Covering from Minimality and Axiom Elimination [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove covering, derive LocallyFiniteOrder, instantiate SuccOrder, delete axiom

**Key Insight**: The covering property follows TRIVIALLY from minimality:
- If M < K < discreteSucc(M), then K is in `{ K | CanonicalR M K ∧ K ≠ M }`
- By minimality, `discreteSucc(M) ≤ K` in the well-ordering
- Combined with `K < discreteSucc(M)` in the timeline order, we get contradiction

Actually, the argument is cleaner: we prove `discreteSucc` satisfies `SuccOrder.ofCore` condition.

**Tasks:**
- [ ] Prove the `SuccOrder.ofCore` condition:
```lean
theorem discreteSucc_ofCore (M : DiscreteTimelineQuot root_mcs root_mcs_proof)
    (h_not_max : ¬IsMax M) (K : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    M < K ↔ discreteSucc M ≤ K := by
  -- Forward: M < K means K is a strict successor, so discreteSucc M ≤ K by minimality
  -- Backward: discreteSucc M ≤ K and discreteSucc M > M, so M < discreteSucc M ≤ K
  sorry
```
- [ ] Instantiate `SuccOrder` via `SuccOrder.ofCore`:
```lean
noncomputable instance : SuccOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) :=
  SuccOrder.ofCore discreteSucc
    (fun h_not_max K => discreteSucc_ofCore _ h_not_max K)
    (fun M h_max => by simp [discreteSucc, h_max])  -- max case
```
- [ ] Derive `LocallyFiniteOrder` from `SuccOrder` + linearity:
```lean
-- SuccOrder + LinearOrder → intervals are finite
-- Specifically: Icc a b = {a, succ a, succ (succ a), ..., b}
instance : LocallyFiniteOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) :=
  LinearLocallyFiniteOrder.ofSuccOrder
```
- [ ] **DELETE** `discrete_Icc_finite_axiom` from `DiscreteTimeline.lean`
- [ ] **DELETE** attempted covering proofs from `DiscreteSuccSeed.lean`
- [ ] Run full `lake build` to verify no regressions
- [ ] Run axiom/sorry verification:
```bash
grep -rn "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean
grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean
```

**Timing**: 5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` (main changes)
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` (cleanup)

**Verification**:
- `lake build` passes with no errors
- `grep -n "^axiom " DiscreteTimeline.lean` returns empty
- `grep -n "\bsorry\b" DiscreteTimeline.lean` returns empty
- All downstream theorems still work

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] All proofs verified with `lean_goal` showing "no goals"
- [ ] `discreteCanonicalTaskFrame` still compiles and works
- [ ] Downstream completeness proofs still work

### General
- [ ] No regressions in existing functionality
- [ ] Implementation summary created

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` (MODIFIED - axiom removed, SuccOrder added)
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` (MODIFIED - failed attempts removed)
- `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean` (RETAINED from Phase 1)
- `specs/981_remove_axiom_technical_debt_from_task_979/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation fails at any phase:
1. **Phase 2 stuck**: Formula enumeration may be tricky; use `Classical.arbitrary` + ordinal assignment instead
2. **Phase 3 stuck**: `WellFounded.min` usage may have edge cases; consult Mathlib examples
3. **Phase 4 stuck**: `SuccOrder.ofCore` condition may need careful case analysis; check IsMax handling
4. **All phases stuck**: Return to documenting the axiom as accepted technical debt (LAST RESORT)

Original `DiscreteTimeline.lean` and `DiscreteSuccSeed.lean` preserved in git history.

## Comparison with v4

| Aspect | v4 (Incremental Construction) | v5 (Well-Founded Minimal Successor) |
|--------|------------------------------|-------------------------------------|
| Approach | Stage-by-stage construction | Minimal element definition |
| Effort | 16-24 hours | 12-16 hours |
| Confidence | HIGH (literature-backed) | MEDIUM-HIGH (mathematically elegant) |
| Blocker | discreteStagedBuild mismatch | None known |
| Key insight | Freshness = no intermediates | Minimality = covering trivial |
| Risk | Staged build modification | Well-ordering formalization |
| Reuses Phase 1 | Required | Optional (utility only) |
