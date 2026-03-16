# Implementation Plan: Task #974

- **Task**: 974 - prove_discrete_timeline_succorder_predorder
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/974_prove_discrete_timeline_succorder_predorder/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task resolves 7 sorries in `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` to establish `SuccOrder`, `PredOrder`, and `IsSuccArchimedean` instances on the discrete timeline quotient. Research identified that the current `succ` definition using `Classical.choice` is flawed - it does not select the least element greater than `a`, making `succ_le_of_lt` unprovable. The fix is to redefine `succ` using `WellFounded.min` to select the actual minimum of the strict upper bounds.

### Research Integration

Key findings from research-001.md:
- **Root cause**: `Classical.choice <b>` returns arbitrary element, not the minimum of `Set.Ioi a`
- **Solution**: Use `WellFounded.min wellFounded_lt (Set.Ioi a) h` to select the least strict upper bound
- **Prerequisite**: Must prove `WellFoundedLT` or establish that `Set.Ioi a` has a minimum via well-ordering
- **Existing infrastructure**: `NoMaxOrder`, `NoMinOrder`, `LinearOrder`, `canonicalR_irreflexive` all proven

## Goals & Non-Goals

**Goals**:
- Resolve all 7 sorries in DiscreteTimeline.lean (lines 179, 187, 200, 212, 213, 218, 231)
- Establish correct `succ`/`pred` definitions using `WellFounded.min` pattern
- Prove `SuccOrder`, `PredOrder`, and `IsSuccArchimedean` instances
- Maintain zero sorry count in completed file

**Non-Goals**:
- Proving `LocallyFiniteOrder` (alternative approach not selected)
- Fixing DurationTransfer.lean upstream errors (independent issue)
- Proving additional order-theoretic properties beyond these instances

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `WellFoundedLT` proof difficult | High | Medium | Use alternative: prove set-specific min exists via linearity + discreteness |
| `IsSuccArchimedean` induction complex | Medium | Medium | Consider using `LocallyFiniteOrder` instance if direct proof blocked |
| Upstream build errors in DurationTransfer.lean | Low | Known | These errors are independent; DiscreteTimeline.lean compiles separately |
| Discreteness axiom gap (semantic vs syntactic level) | Medium | Low | Pattern established by existing `NoMaxOrder`/`NoMinOrder` proofs using `canonicalR_irreflexive` |

## Sorry Characterization

### Pre-existing Sorries
- 7 sorries in `DiscreteTimeline.lean`:
  - Line 179: `SuccOrder.le_succ` - `a <= succ(a)`
  - Line 187: `SuccOrder.max_of_succ_le` - `IsMax a` when `succ(a) <= a`
  - Line 200: `SuccOrder.succ_le_of_lt` - coverness `a < b -> succ(a) <= b`
  - Line 212: `PredOrder.pred_le` - `pred(a) <= a`
  - Line 213: `PredOrder.min_of_le_pred` - `IsMin a` when `a <= pred(a)`
  - Line 218: `PredOrder.le_pred_of_lt` - coverness `a < b -> a <= pred(b)`
  - Line 231: `IsSuccArchimedean.exists_succ_iterate_of_le` - finite reachability

### Expected Resolution
- Phase 1 establishes helper lemmas for `WellFounded.min` usage
- Phase 2 redefines `succ` and proves SuccOrder properties (resolves lines 179, 187, 200)
- Phase 3 redefines `pred` and proves PredOrder properties (resolves lines 212, 213, 218)
- Phase 4 proves IsSuccArchimedean (resolves line 231)

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in `DiscreteTimeline.lean`
- Downstream `discreteCanonicalTaskFrame` will be sorry-free
- Complete pipeline to `T ≃o Z` characterization will be proven

## Implementation Phases

### Phase 1: Establish WellFounded Infrastructure [NOT STARTED]

- **Dependencies:** None
- **Goal:** Prove helper lemmas enabling `WellFounded.min` usage on `Set.Ioi a` and `Set.Iio a`

**Tasks:**
- [ ] Prove or locate `wellFounded_lt` for `DiscreteTimelineQuot` (linear order has this via `WellFounded.intro` or Mathlib instance)
- [ ] Verify `Set.Ioi a` is nonempty when `a` is not maximal (follows from `NoMaxOrder`)
- [ ] Prove `wellFounded_gt` symmetrically for `Set.Iio a` (for PredOrder)
- [ ] Test compilation: `lake build Bimodal.Metalogic.Domain.DiscreteTimeline`

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - add helper lemmas before SuccOrder instance

**Verification:**
- Helper lemmas compile without sorries
- `lake build` passes for the module
- `lean_goal` shows no goals at each proof end

---

### Phase 2: Redefine succ and Prove SuccOrder [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Replace `Classical.choice` definition of `succ` with `WellFounded.min` and prove all SuccOrder fields

**Tasks:**
- [ ] Redefine `succ` using:
  ```lean
  succ := fun a =>
    if h : (Set.Ioi a).Nonempty then
      WellFounded.min wellFounded_lt (Set.Ioi a) h
    else a
  ```
- [ ] Prove `le_succ`: use `WellFounded.min_mem` to get `succ(a) > a`, hence `a <= succ(a)`
- [ ] Prove `max_of_succ_le`: if `succ(a) <= a` and `succ(a) > a`, contradiction; if set empty, `a` is max
- [ ] Prove `succ_le_of_lt`: use `WellFounded.min_le` since `b in Set.Ioi a` when `a < b`
- [ ] Remove sorries at lines 179, 187, 200
- [ ] Test compilation: `lake build`

**Timing:** 45 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - rewrite SuccOrder instance (lines 161-200)

**Verification:**
- SuccOrder instance compiles without sorries
- `grep -n "\bsorry\b" DiscreteTimeline.lean` returns only PredOrder and IsSuccArchimedean sorries (lines 212, 213, 218, 231)
- `lake build` passes

---

### Phase 3: Redefine pred and Prove PredOrder [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Symmetrically define `pred` using `WellFounded.min` on `Set.Iio a` and prove all PredOrder fields

**Tasks:**
- [ ] Redefine `pred` using:
  ```lean
  pred := fun a =>
    if h : (Set.Iio a).Nonempty then
      WellFounded.min wellFounded_gt (Set.Iio a) h
    else a
  ```
- [ ] Prove `pred_le`: symmetric to `le_succ` using `min_mem` on `Set.Iio a`
- [ ] Prove `min_of_le_pred`: symmetric to `max_of_succ_le`
- [ ] Prove `le_pred_of_lt`: symmetric to `succ_le_of_lt` using `min_le`
- [ ] Remove sorries at lines 212, 213, 218
- [ ] Test compilation: `lake build`

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - rewrite PredOrder instance (lines 208-218)

**Verification:**
- PredOrder instance compiles without sorries
- `grep -n "\bsorry\b" DiscreteTimeline.lean` returns only IsSuccArchimedean sorry (line 231)
- `lake build` passes

---

### Phase 4: Prove IsSuccArchimedean [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove finite reachability via succ iterations

**Tasks:**
- [ ] Prove `exists_succ_iterate_of_le` using well-founded induction on the interval size
- [ ] Strategy: Given `a <= b`, proceed by strong induction on `b` using `wellFounded_lt`:
  - If `a = b`: `n = 0` works, `succ^[0](a) = a = b`
  - If `a < b`: by IH, `succ(a) <= b` (from `succ_le_of_lt`), and `exists m, succ^[m](succ(a)) = b`, so `n = m + 1`
- [ ] Alternative: Use Mathlib's `LinearLocallyFiniteOrder.isSuccArchimedean` if available and simpler
- [ ] Remove sorry at line 231
- [ ] Test compilation: `lake build`

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - complete IsSuccArchimedean instance (lines 226-231)

**Verification:**
- IsSuccArchimedean instance compiles without sorries
- `grep -n "\bsorry\b" DiscreteTimeline.lean` returns empty
- `lake build` passes for full project

---

### Phase 5: Final Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Verify zero-debt completion and clean up documentation

**Tasks:**
- [ ] Run full build: `lake build`
- [ ] Verify zero sorries: `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
- [ ] Verify no new axioms: `grep -n "^axiom " DiscreteTimeline.lean`
- [ ] Update module docstring to reflect resolved sorries
- [ ] Verify downstream compilation: `discreteCanonicalTaskFrame` compiles without sorry propagation
- [ ] If any sorry remains, mark [BLOCKED] with requires_user_review: true

**Timing:** 15 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - docstring updates only

**Verification:**
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" DiscreteTimeline.lean` returns empty (zero-debt gate)
- `grep -n "^axiom " DiscreteTimeline.lean` shows no new axioms
- Module docstring accurately reflects proof status

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Each phase verified independently before proceeding to next
- [ ] Incremental commits after each phase completion

## Artifacts & Outputs

- `specs/974_prove_discrete_timeline_succorder_predorder/plans/implementation-001.md` (this file)
- `specs/974_prove_discrete_timeline_succorder_predorder/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

## Rollback/Contingency

If implementation fails at any phase:
1. Git revert to last known good state before phase
2. Preserve phase-by-phase commits for rollback granularity
3. If fundamental approach blocked (e.g., `WellFoundedLT` unprovable):
   - Consider `LocallyFiniteOrder` alternative path from research
   - Mark task [BLOCKED] with details for plan revision
4. If single sorry proves intractable:
   - Mark specific phase [BLOCKED] with `requires_user_review: true`
   - Do not use sorry placeholder and mark complete
