# Implementation Plan: Task #974 (v2 — Staged Construction Approach)

- **Task**: 974 - prove_discrete_timeline_succorder_predorder
- **Status**: [NOT STARTED]
- **Effort**: 2.5-3 hours
- **Dependencies**: None (task 973 unblocked independently by task 972)
- **Research Inputs**:
  - research-001.md (initial analysis, WellFounded.min approach)
  - research-002.md (staged construction finiteness — REVISED approach)
- **Artifacts**: plans/implementation-002.md (this file, supersedes implementation-001.md)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan resolves the 3 remaining sorries in `DiscreteTimeline.lean` using the **staged construction finiteness** approach identified in research-002.md. The original plan (v1) attempted to extract discreteness from the DF axiom frame condition, but research-002 proved this is impossible under reflexive semantics (DF is trivially valid).

**Key insight**: The discrete timeline is discrete BY CONSTRUCTION, not by virtue of DF validity. Since DN (density axiom) is excluded from the discrete axiom set, the staged construction never adds density intermediates, yielding finite intervals.

### Research Integration

From research-002.md:
- **Critical finding**: DF under reflexive semantics uses `s = t` as witness — cannot derive discreteness
- **Correct path**: Discreteness follows from staged construction lacking DN
- **Proof strategy**: Finite intervals → GLB = min → `succFn a > a`
- **Final step**: `LocallyFiniteOrder` → `IsSuccArchimedean` via Mathlib

From research-001.md (phases 1-3, COMPLETED):
- Restructured SuccOrder using `succFn` pattern
- Restructured PredOrder using LUB pattern
- Reduced sorries from 7 to 3

### Compatibility with Task 977

Task 977 ("Organize TM base logic with extensions") depends on this task:
- 977 Phase 6 requires discrete completeness infrastructure
- This task provides `SuccOrder`/`PredOrder`/`IsSuccArchimedean` instances needed for `DiscreteTimelineQuot ≃o ℤ`
- The staged construction finiteness approach aligns with 977's principle of "additive enhancement" — no semantic changes required

### Compatibility with Task 973

Task 973 ("Prove NoMaxOrder/NoMinOrder on ConstructiveQuotient") is blocked on task 972 (naming conventions). Once 972 completes:
- Task 973 and 974 can proceed in parallel
- Both use seriality witnesses but for different purposes
- No conflicts — different files, different proof strategies

## Goals & Non-Goals

**Goals**:
- Resolve 3 remaining sorries in DiscreteTimeline.lean (lines 193, 251, 296)
- Prove discreteness via staged construction finiteness
- Establish `LocallyFiniteOrder` instance
- Derive `IsSuccArchimedean` from Mathlib
- Maintain zero-debt completion (no new sorries or axioms)

**Non-Goals**:
- Modifying the DF axiom or temporal semantics
- Proving DF frame correspondence (not meaningful under reflexive semantics)
- Refactoring staged construction infrastructure
- Adding new lemmas outside DiscreteTimeline.lean (prefer using existing infrastructure)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Staged construction finiteness not already formalized | Medium | Medium | May need helper lemma in CantorPrereqs.lean or DiscreteTimeline.lean |
| Finset.Icc construction complex on quotient type | Medium | Low | Use existing `LocallyFiniteOrder` patterns from Mathlib |
| `LocallyFiniteOrder.instIsSuccArchimedean` requires additional instances | Low | Low | Check instance requirements; may need `OrderBot`/`OrderTop` negation |

## Sorry Characterization

### Pre-existing Sorries (3 remaining from v1)
- Line 193: `discrete_timeline_lt_succFn` — `a < succFn a` (key discreteness for succ)
- Line 251: `discrete_timeline_predFn_lt` — `predFn a < a` (key discreteness for pred)
- Line 296: `IsSuccArchimedean.exists_succ_iterate_of_le` — finite reachability

### Resolution Path (REVISED)
- ~~Phase 4 (old): Extract DF frame condition at MCS level~~ **ABANDONED** — vacuous under reflexive semantics
- **Phase 4 (new)**: Prove finite intervals from staged construction (absence of DN)
- **Phase 5 (revised)**: Derive discreteness from finite intervals, then LocallyFiniteOrder → IsSuccArchimedean

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries in `DiscreteTimeline.lean`
- Downstream `discreteCanonicalTaskFrame` will be sorry-free
- Complete pipeline to `DiscreteTimelineQuot ≃o ℤ` characterization will be proven
- Task 977 discrete completeness framework unblocked

---

## Implementation Phases

### Phases 1-3: [COMPLETED in v1]

Phases 1-3 from implementation-001.md are completed:
- Phase 1: Restructured SuccOrder using succFn ✓
- Phase 2: Restructured PredOrder using LUB ✓
- Phase 3: Updated IsSuccArchimedean documentation ✓

Sorries reduced from 7 to 3. Proceed to revised Phase 4.

---

### Phase 4: Prove staged construction finiteness [NOT STARTED]

- **Dependencies:** Phases 1-3 (completed)
- **Goal:** Establish that between any two elements in `DiscreteTimelineQuot`, there are finitely many elements

**Key Insight**: The discrete staged construction does NOT use `density_of_canonicalR` (which requires DN). Without DN, each formula's F-obligation creates at most one forward witness per MCS. The witnesses between any two MCSs are bounded by the formula encodings distinguishing them — a finite set.

**Tasks:**
- [ ] Review `CantorPrereqs.lean` for existing finiteness infrastructure
- [ ] Search for `staged_build_finitely_between` or similar theorem using `lean_local_search`
- [ ] If not present, prove helper lemma:
  ```lean
  theorem discrete_staged_finitely_between (a b : DiscreteTimelineQuot root_mcs root_mcs_proof)
      (hab : a < b) : Set.Finite {x | a < x ∧ x < b}
  ```
- [ ] Proof sketch:
  1. Both `a` and `b` appear at finite stages `n_a`, `n_b` in staged construction
  2. All points in `(a, b)` must appear by stage `max(n_a, n_b)` (monotonicity)
  3. Each stage adds finitely many points
  4. Hence the interval is finite
- [ ] Verify with `lean_goal` that finite set proof is complete

**Timing:** 1-1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` — add finiteness theorem
- Possibly `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` if helper needed

**Verification:**
- Finiteness theorem compiles without sorries
- `lake build` passes

---

### Phase 5: Derive discreteness and LocallyFiniteOrder [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Prove the 3 remaining sorries using finite interval properties

**Part A: Discreteness theorems**

Use Phase 4's finiteness to prove GLB = min for finite sets:
- [ ] Prove `discrete_timeline_lt_succFn`:
  ```lean
  theorem discrete_timeline_lt_succFn (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
      a < LinearLocallyFiniteOrder.succFn a := by
    -- Set.Ioi a restricted to any bounded interval is finite (Phase 4)
    -- Finite nonempty sets have a minimum (Mathlib)
    -- succFn a = min(Set.Ioi a) when finite
    -- Hence a < succFn a (min is in the set)
  ```
- [ ] Prove `discrete_timeline_predFn_lt` symmetrically for pred
- [ ] Verify both theorems with `lean_goal`

**Part B: LocallyFiniteOrder instance**

- [ ] Define `Finset.Icc` for `DiscreteTimelineQuot` using Phase 4 finiteness
- [ ] Register `LocallyFiniteOrder` instance:
  ```lean
  instance : LocallyFiniteOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
    finsetIcc := fun a b => ...  -- from Phase 4 finiteness
    finsetIco := fun a b => ...
    finsetIoc := fun a b => ...
    finsetIoo := fun a b => ...
  ```
- [ ] Verify instance compiles

**Part C: IsSuccArchimedean from Mathlib**

- [ ] Apply Mathlib's automatic instance:
  ```lean
  instance : IsSuccArchimedean (DiscreteTimelineQuot root_mcs root_mcs_proof) :=
    LinearLocallyFiniteOrder.instIsSuccArchimedean
  ```
- [ ] If Mathlib instance requires additional constraints, provide them
- [ ] Verify final sorry at line 296 is resolved

**Timing:** 1-1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Verification:**
- All 3 remaining sorries resolved
- `grep -rn "\bsorry\b" DiscreteTimeline.lean` returns empty
- `lake build` passes completely

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Downstream Verification
- [ ] `discreteCanonicalTaskFrame` compiles without sorries
- [ ] Verify no regressions in dependent files

### Task 977 Compatibility Check
- [ ] After completion, verify Phase 6 of task 977 (discrete completeness) is unblocked
- [ ] Document any infrastructure gaps discovered for 977

## Artifacts & Outputs

- `specs/974_prove_discrete_timeline_succorder_predorder/plans/implementation-002.md` (this file)
- `specs/974_prove_discrete_timeline_succorder_predorder/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
- Possibly modified: `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean`

## Rollback/Contingency

If implementation fails at any phase:
1. Git revert to last known good state before phase
2. Preserve phase-by-phase commits for rollback granularity
3. If staged construction finiteness proves intractable:
   - Consider axiomatizing `staged_build_discrete_finite` (analogous to `canonicalR_irreflexive` approach)
   - Mark specific phase [BLOCKED] with `requires_user_review: true`
4. If LocallyFiniteOrder instance has unexpected requirements:
   - Check Mathlib documentation for LinearLocallyFiniteOrder prerequisites
   - May need to prove additional order-theoretic properties first

## Supersession Note

This plan (v2) supersedes implementation-001.md. Key changes:
- **Phase 4**: Replaced DF frame condition extraction (vacuous) with staged construction finiteness
- **Phase 5**: Streamlined to derive discreteness from finiteness, then chain to IsSuccArchimedean
- **Added**: Explicit compatibility analysis with tasks 973 and 977
- **Preserved**: Phases 1-3 completion status from v1
