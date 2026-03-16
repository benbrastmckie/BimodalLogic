# Implementation Plan: Task #974 (v3 - Discrete Staged Construction)

- **Task**: 974 - prove_discrete_timeline_succorder_predorder
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**:
  - research-001.md (initial analysis, WellFounded.min approach)
  - research-002.md (staged construction finiteness, DF vacuity discovery)
  - research-003.md (team research - Option B discrete staged construction)
- **Artifacts**: plans/implementation-003.md (this file, supersedes implementation-002.md)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan resolves the 3 remaining sorries in `DiscreteTimeline.lean` via **Option B: Discrete Staged Construction** as identified in research-003.md. The v2 plan's Phase 4 was blocked because `buildStagedTimeline` unconditionally adds density intermediates at odd stages using `processDensity` -> `density_of_canonicalR` -> DN axiom. This v3 plan creates a new `discreteStagedBuild` that skips odd stages entirely.

**Key insight**: Two DN dependencies exist:
1. Primary: `buildStagedTimeline` -> `oddStage` -> `processDensity` -> `density_of_canonicalR`
2. Secondary: `staged_timeline_has_future` -> `iterated_future_in_mcs` -> `density_F_to_FF`

Both must be eliminated for a truly discrete construction.

### Research Integration

From research-003.md (team research, 3 teammates):
- **Option A (quotient collapse) is INFEASIBLE**: DenseTimeline.lean lines 551-591 documents the Lindenbaum obstruction
- **Option B (discrete staged construction) is recommended**: Skip odd stages, prove DN-free has_future via MCS richness
- **Option C reduces to Option B**: DF under reflexive semantics is trivially valid
- **Task 978 does NOT help 974**: Typeclass refactoring is orthogonal to order-theoretic proofs

From research-002.md:
- DF under reflexive semantics uses `s = t` as witness - cannot derive discreteness
- Discreteness follows from staged construction lacking DN (confirmed in v3 approach)

### Prior Plan Status

- **v1 (implementation-001.md)**: Phases 1-3 completed (reduced sorries from 7 to 3)
- **v2 (implementation-002.md)**: Phase 4 BLOCKED on architectural issue (buildStagedTimeline uses DN)
- **v3 (this plan)**: New Phases 4-8 using discrete staged construction approach

## Goals & Non-Goals

**Goals**:
- Define `discreteStagedBuild` that skips odd stages (no density insertion)
- Prove DN-free `discrete_staged_has_future` via MCS richness
- Redefine `DiscreteTimelineElem` to use `buildDiscreteStagedTimeline`
- Prove local finiteness of intervals in discrete construction
- Resolve 3 remaining sorries (lines 193, 251, 296) from LocallyFiniteOrder
- Maintain zero-debt completion (no new sorries or axioms)

**Non-Goals**:
- Modifying the existing `buildStagedTimeline` (used by dense timeline)
- Changing DN axiom semantics or DF frame correspondence
- Refactoring task 978's typeclass architecture (orthogonal work)
- Proving anything about DenseTimeline (separate construction path)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| DN-free has_future proof is harder than expected | High | Medium | Research identifies MCS richness approach; if stuck >1.5h, mark [BLOCKED] with escape valve |
| Redefining DiscreteTimelineElem breaks downstream | Medium | Low | Check dependents before modification; preserve existing structure |
| Local finiteness proof requires complex Finset arithmetic | Medium | Medium | Use existing Mathlib patterns; may axiomatize temporarily if >4h total |
| NoMaxOrder/NoMinOrder proofs need update | Low | High | Already identified in research; update is straightforward once has_future is DN-free |

## Sorry Characterization

### Pre-existing Sorries (3 remaining from v1/v2)
- Line ~193: `discrete_timeline_lt_succFn` - `a < succFn a` (key discreteness for succ)
- Line ~251: `discrete_timeline_predFn_lt` - `predFn a < a` (key discreteness for pred)
- Line ~296: `IsSuccArchimedean.exists_succ_iterate_of_le` - finite reachability

### Resolution Path
- **Phase 4**: Define `discreteStagedBuild` (no DN dependencies)
- **Phase 5**: Prove DN-free `discrete_staged_has_future` via MCS richness
- **Phase 6**: Redefine `DiscreteTimelineElem`, update NoMax/NoMin proofs
- **Phase 7**: Prove local finiteness -> 3 sorries
- **Phase 8**: Final verification

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries in `DiscreteTimeline.lean`
- 0 new axioms introduced
- Complete discrete order infrastructure (SuccOrder, PredOrder, IsSuccArchimedean)
- Task 977 Phase 6 (discrete completeness) unblocked

---

## Implementation Phases

### Phases 1-3: [COMPLETED in v1]

Phases 1-3 from implementation-001.md are completed:
- Phase 1: Restructured SuccOrder using succFn pattern
- Phase 2: Restructured PredOrder using LUB pattern
- Phase 3: Updated IsSuccArchimedean documentation

Sorries reduced from 7 to 3. Proceed to v3 Phase 4.

---

### Phase 4: Define discreteStagedBuild [NOT STARTED]

- **Dependencies:** Phases 1-3 (completed)
- **Goal:** Create a staged construction that skips odd stages (no density insertion)

**Tasks:**
- [ ] Create new file or section in `StagedExecution.lean` for discrete variant
- [ ] Define `discreteStagedBuild`:
  ```lean
  noncomputable def discreteStagedBuild : Nat -> Finset StagedPoint
    | 0 => stage0 root_mcs root_mcs_proof
    | n + 1 =>
      let prev := discreteStagedBuild n
      if n % 2 = 0 then
        evenStage prev (n / 2) (n + 1)  -- F/P witnesses only
      else
        prev                             -- SKIP density insertion
  ```
- [ ] Prove basic properties: monotonicity, stage membership
- [ ] Define `buildDiscreteStagedTimeline` union analogous to `buildStagedTimeline`
- [ ] Verify with `lean_goal` that definitions compile

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` - add discrete variant

**Verification:**
- `discreteStagedBuild` compiles without sorries
- `lake build` passes

---

### Phase 5: Prove DN-free has_future [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Prove existence of future witnesses without using DN axiom

**Key Insight**: The existing `staged_timeline_has_future` uses `iterated_future_in_mcs` which invokes `density_F_to_FF` (DN). For the discrete construction, we need a DN-free proof using MCS richness: every MCS contains infinitely many formulas, so encoding-sufficient formulas exist without F-nesting via DN.

**Tasks:**
- [ ] Study existing `staged_timeline_has_future` proof structure
- [ ] Identify MCS richness lemmas (every MCS is infinite, contains encoding-sufficient formulas)
- [ ] Prove `discrete_staged_has_future`:
  ```lean
  theorem discrete_staged_has_future
      (x : DiscreteTimelineElem root_mcs root_mcs_proof) :
      exists y, DiscreteTimelineR x y := by
    -- Use MCS richness: x.val.mcs contains formulas with arbitrarily large encodings
    -- F-witness exists from seriality + MCS completeness
    -- No DN required: encoding sufficiency from formula structure, not F-nesting
  ```
- [ ] Prove symmetric `discrete_staged_has_past`
- [ ] Verify both proofs with `lean_goal`
- [ ] If proof stuck >1.5 hours, mark [BLOCKED] with `review_reason`

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` or new discrete prereqs file
- Possibly `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Verification:**
- `discrete_staged_has_future` and `discrete_staged_has_past` compile without sorries
- No DN axiom in proof dependencies (check with `#print axioms`)
- `lake build` passes

---

### Phase 6: Redefine DiscreteTimelineElem and update proofs [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Wire up discrete construction to DiscreteTimeline.lean

**Tasks:**
- [ ] Redefine `DiscreteTimelineElem` to use `buildDiscreteStagedTimeline`:
  ```lean
  def DiscreteTimelineElem (root_mcs : MCS M) (root_mcs_proof : ...) :=
    { p : StagedPoint // p in buildDiscreteStagedTimeline.union }
  ```
- [ ] Update `DiscreteTimelineR` relation if needed
- [ ] Update `NoMaxOrder` proof to use DN-free `discrete_staged_has_future`
- [ ] Update `NoMinOrder` proof to use DN-free `discrete_staged_has_past`
- [ ] Verify existing infrastructure still compiles
- [ ] Verify with `lean_goal` that NoMax/NoMin have no goals

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - redefine and update proofs

**Verification:**
- `DiscreteTimelineElem` uses discrete construction
- `NoMaxOrder` and `NoMinOrder` instances compile without sorries
- `lake build` passes

---

### Phase 7: Prove local finiteness and resolve 3 sorries [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Prove intervals are finite, derive discreteness, resolve remaining sorries

**Key Mathematical Claim**: In `discreteStagedBuild`, without odd stages, only F/P witnesses are added. Each witness lies between existing points. The construction produces a well-ordered tree bounded by formula encodings. For any `a <= b`, the interval `[a, b]` is finite.

**Part A: Prove local finiteness**

- [ ] Prove `discrete_staged_finitely_between`:
  ```lean
  theorem discrete_staged_finitely_between
      (a b : DiscreteTimelineQuot root_mcs root_mcs_proof)
      (hab : a < b) : Set.Finite {x | a < x /\ x < b}
  ```
  - Proof sketch:
    1. Both `a` and `b` appear at finite stages `n_a`, `n_b`
    2. All points in `(a, b)` appear by stage `max(n_a, n_b)` (monotonicity)
    3. Each stage adds finitely many points (F/P witnesses only, no density)
    4. Hence the interval is finite
- [ ] Define `LocallyFiniteOrder` instance using finiteness
- [ ] Verify with `lean_goal`

**Part B: Resolve 3 sorries**

- [ ] Prove `discrete_timeline_lt_succFn` (line ~193):
  ```lean
  -- Set.Ioi a restricted to any bounded interval is finite
  -- Finite nonempty sets have minimum (Mathlib)
  -- succFn a = min(Set.Ioi a) when finite
  -- Hence a < succFn a
  ```
- [ ] Prove `discrete_timeline_predFn_lt` (line ~251) symmetrically
- [ ] Derive `IsSuccArchimedean` from `LocallyFiniteOrder`:
  ```lean
  instance : IsSuccArchimedean (DiscreteTimelineQuot root_mcs root_mcs_proof) :=
    LinearLocallyFiniteOrder.instIsSuccArchimedean
  ```
- [ ] Verify all 3 sorries resolved with `lean_goal`

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - finiteness and sorry resolution

**Verification:**
- `grep -rn "\bsorry\b" DiscreteTimeline.lean` returns empty
- `LocallyFiniteOrder` instance compiles
- `IsSuccArchimedean` instance compiles
- `lake build` passes

---

### Phase 8: Final verification and cleanup [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Verify zero-debt completion and document changes

**Tasks:**
- [ ] Run `lake build` for full project verification
- [ ] Verify no new sorries: `grep -rn "\bsorry\b" DiscreteTimeline.lean StagedExecution.lean CantorPrereqs.lean`
- [ ] Verify no new axioms: `grep -n "^axiom " <modified files>`
- [ ] Check downstream dependencies compile (discreteCanonicalTaskFrame)
- [ ] Update plan status markers to [COMPLETED]
- [ ] Create implementation summary

**Timing:** 0.5 hours

**Files to modify:**
- This plan file - status updates
- Summary file creation

**Verification:**
- Zero sorries in modified files
- Zero new axioms
- `lake build` passes completely
- Task 977 Phase 6 is unblocked

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty (zero-debt gate)
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` returns empty for discrete additions
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Downstream Verification
- [ ] `discreteCanonicalTaskFrame` compiles without sorries
- [ ] No regressions in dependent files
- [ ] DenseTimeline.lean unchanged and still compiles

### Task 977 Compatibility Check
- [ ] After completion, verify Phase 6 of task 977 (discrete completeness) is unblocked
- [ ] Document any infrastructure gaps discovered for 977

## Artifacts & Outputs

- `specs/974_prove_discrete_timeline_succorder_predorder/plans/implementation-003.md` (this file)
- `specs/974_prove_discrete_timeline_succorder_predorder/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean`
- Possibly modified: `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean`

## Rollback/Contingency

If implementation fails at any phase:

1. **Phase 4 fails**: Discrete staged build definition issues
   - Git revert; reconsider file organization
   - May need to extract helper definitions first

2. **Phase 5 fails**: DN-free has_future proof stuck
   - Mark [BLOCKED] with `requires_user_review: true`
   - Escape valve: Consider axiomatizing `discrete_mcs_has_encoding_sufficient_formula` temporarily
   - Document proof difficulty for future research

3. **Phase 6 fails**: Wiring breaks existing infrastructure
   - Git revert to Phase 5
   - May need to preserve old definition alongside new one during transition

4. **Phase 7 fails**: Local finiteness proof intractable
   - If >4h total, consider temporary axiom:
     ```lean
     axiom discrete_staged_finite_intervals :
         forall (a b : DiscreteTimelineQuot ...), a < b -> Finite (Set.Ioo a b)
     ```
   - Mark as technical debt with remediation timeline
   - Complete pipeline (SuccOrder -> PredOrder -> IsSuccArchimedean) using axiom

5. **General rollback**: Preserve phase-by-phase commits for granular rollback

## Supersession Note

This plan (v3) supersedes implementation-002.md. Key changes:
- **New approach**: Option B discrete staged construction (skip odd stages)
- **Phases 4-8**: Complete rewrite for discrete construction approach
- **Addresses both DN dependencies**: processDensity AND density_F_to_FF
- **Research-backed**: Team research (3 teammates) confirmed Option B feasibility
- **Preserved**: Phases 1-3 completion status from v1/v2
