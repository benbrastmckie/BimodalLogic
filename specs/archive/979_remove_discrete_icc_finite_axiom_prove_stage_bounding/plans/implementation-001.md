# Implementation Plan: Task #979

- **Task**: 979 - remove_discrete_icc_finite_axiom_prove_stage_bounding
- **Status**: [PARTIAL]
- **Effort**: 5-7 hours
- **Dependencies**: Task 974 [COMPLETED]
- **Research Inputs**:
  - specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/reports/research-001.md (team research)
  - specs/974_prove_discrete_timeline_succorder_predorder/reports/research-006.md (prior research)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task removes the `discrete_Icc_finite_axiom` from `DiscreteTimeline.lean` by proving interval finiteness via the mathematically correct SuccOrder-first approach. The research identified a fundamental gap in the stage-bounding approach from research-006.md: the claim that elements in `Icc [a] [b]` have representatives at stage <= max(minStage a, minStage b) is likely FALSE because witnesses for F(phi_k) with k >> N are created at stage k+1 >> N.

The correct approach extracts the DF (discreteness forward) frame condition at the MCS level, proving that CanonicalR provides covering/immediate successor relationships, then uses this to construct SuccOrder independently of LocallyFiniteOrder. Finally, LocallyFiniteOrder is derived from SuccOrder + covering.

### Research Integration

From research-001.md (team research):
- Stage-bounding approach has fundamental gap (Teammate C)
- SuccOrder-first approach via DF frame condition extraction recommended (70% confidence)
- Key insight: DF axiom `(F top and phi and H phi) -> F(H phi)` corresponds to covering property

## Goals & Non-Goals

**Goals**:
- Remove `discrete_Icc_finite_axiom` (line 244) entirely
- Prove interval finiteness via SuccOrder + covering approach
- Maintain zero axioms in `DiscreteTimeline.lean`
- Preserve all existing functionality (SuccOrder, PredOrder, IsSuccArchimedean instances)

**Non-Goals**:
- Creating generic `Antisymmetrization.locallyFiniteOrder` instance
- Modifying the staged construction itself
- Changing the DN-based seriality proofs (existing tech debt, out of scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| DF frame condition extraction complex | High | Medium | Use existing Soundness.lean infrastructure; mark [BLOCKED] if stuck >2h |
| Covering proof harder than expected | High | Medium | Escape valve: document proof sketch, mark [BLOCKED] for user review |
| IsSuccArchimedean derivation circular | Medium | Low | Use direct chain induction approach if Mathlib instance insufficient |
| LocallyFiniteOrder from SuccOrder complex | Medium | Low | Use Mathlib `LocallyFiniteOrder.ofFiniteIcc` with covering-based finiteness |

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom in `DiscreteTimeline.lean`: `discrete_Icc_finite_axiom` (line 244) - interval finiteness assumption

### Expected Resolution
- Phase 3 eliminates axiom via structural proof using DF frame condition
- Structural proof approach: extract covering from DF soundness, prove interval finiteness from covering chain

### New Axioms
- None. NEVER introduce new axioms. If proof cannot be completed, mark [BLOCKED] with requires_user_review: true.

### Remaining Debt
After this implementation:
- 0 axioms expected in `DiscreteTimeline.lean`
- The module becomes publication-ready (no axiom disclosure needed)

## Sorry Characterization

### Pre-existing Sorries
- 0 sorries in `DiscreteTimeline.lean` (resolved in task 974)

### Expected Resolution
- Not applicable (no sorries to resolve)

### New Sorries
- None. NEVER introduce new sorries. If proof stuck, mark [BLOCKED] with requires_user_review: true.

### Remaining Debt
- 0 sorries expected after implementation

---

## Implementation Phases

### Phase 1: Locate and Analyze DF Frame Condition Infrastructure [COMPLETED]

- **Dependencies:** None
- **Goal:** Understand existing DF soundness proof and determine extraction path

**Tasks:**
- [ ] Search `Soundness.lean` for DF-related theorems (`discreteness_forward_valid`, `df_frame_condition`)
- [ ] Identify the formal statement of DF frame condition in soundness proof
- [ ] Determine what form the covering property takes in the canonical model
- [ ] Document the extraction path: what lemmas need to be stated, what dependencies exist
- [ ] If DF infrastructure missing or complex, assess feasibility and document in plan update

**Timing:** 45 minutes

**Files to examine:**
- `Theories/Bimodal/Metalogic/Soundness.lean` - DF validity proof
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - CanonicalR definition
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - target file

**Verification:**
- Path to DF frame condition extraction documented
- Feasibility assessment complete
- If infeasible, mark [BLOCKED] with review_reason

---

### Phase 2: Extract DF Frame Condition at MCS Level [BLOCKED]

- **Dependencies:** Phase 1
- **Goal:** Prove the covering lemma for CanonicalR using DF soundness

**Tasks:**
- [ ] State the covering theorem at MCS level:
  ```lean
  theorem df_frame_condition_canonical
      (M : Set Formula) (h_mcs : SetMaximalConsistent M)
      (h_serial : exists N, CanonicalR M N) :
      exists N, CanonicalR M N and forall K, CanonicalR M K -> CanonicalR N K or N = K
  ```
- [ ] Connect to DF soundness: if DF is valid, then every non-maximal element has an immediate successor
- [ ] Prove the lemma using soundness infrastructure
- [ ] Handle equivalence class considerations (same MCS at different stages)
- [ ] If proof stuck >2h, mark [BLOCKED] with requires_user_review: true

**Timing:** 2-3 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - add covering lemma

**Verification:**
- `df_frame_condition_canonical` compiles without sorry
- `lake build` passes

---

### Phase 3: Define Direct SuccOrder Without LocallyFiniteOrder [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Define `discreteSuccFn` independently and prove SuccOrder properties from covering

The current code defines SuccOrder using `LinearLocallyFiniteOrder.succFn`, which requires LocallyFiniteOrder. We need to define the successor function directly using the DF frame condition, then derive LocallyFiniteOrder from it.

**Tasks:**
- [ ] Define `discreteImmediateSucc` on `StagedPoint` using forward witness construction
- [ ] Prove well-definedness on quotient: same MCS -> same successor class
- [ ] Define `discreteSuccFn_direct`:
  ```lean
  noncomputable def discreteSuccFn_direct (a : DiscreteTimelineQuot) :
      DiscreteTimelineQuot :=
    -- Use df_frame_condition_canonical to get immediate successor
    Quotient.liftOn a (fun a' => ...) (well_definedness_proof)
  ```
- [ ] Prove `discreteSuccFn_direct` is covering: `forall c, a < c -> discreteSuccFn_direct a <= c`
- [ ] Prove `a < discreteSuccFn_direct a` (strictness from covering + NoMaxOrder)

**Timing:** 1.5-2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - add direct successor definition

**Verification:**
- `discreteSuccFn_direct` compiles
- Covering property proven
- Strictness proven
- `lake build` passes

---

### Phase 4: Prove LocallyFiniteOrder from SuccOrder + Covering [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Derive interval finiteness from the covering structure, then instantiate LocallyFiniteOrder

**Tasks:**
- [ ] Prove `icc_finite_from_covering`:
  ```lean
  theorem icc_finite_from_covering
      (a b : DiscreteTimelineQuot) :
      (Set.Icc a b).Finite := by
    -- If a > b, empty and trivially finite
    -- If a = b, singleton
    -- If a < b, Icc a b = {a} union Icc (succ a) b, induct
    -- Termination: covering ensures strict progress, reaching b in finite steps
  ```
- [ ] The key insight: covering (no element between a and succ a) + linearity ensures the chain from a to b has finite length
- [ ] Use well-founded induction on the covering chain
- [ ] Instantiate `LocallyFiniteOrder.ofFiniteIcc` with the proven finiteness

**Timing:** 1-1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - add finiteness proof

**Verification:**
- `icc_finite_from_covering` compiles without sorry
- `LocallyFiniteOrder` instance compiles
- `lake build` passes

---

### Phase 5: Refactor SuccOrder/PredOrder to Use Direct Definition [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Update existing SuccOrder/PredOrder instances to use direct definition, remove axiom

**Tasks:**
- [ ] Verify the new `LocallyFiniteOrder` instance is compatible with existing `SuccOrder`
- [ ] If needed, refactor `SuccOrder` instance to use `discreteSuccFn_direct` instead of `LinearLocallyFiniteOrder.succFn`
- [ ] Ensure `PredOrder` instance remains valid (uses `discretePredFn` which should still work)
- [ ] Remove `discrete_Icc_finite_axiom` declaration (line 244)
- [ ] Update `discrete_Icc_finite` to use `icc_finite_from_covering` instead of axiom
- [ ] Update docstrings to reflect that interval finiteness is now proven
- [ ] Verify `IsSuccArchimedean` still derives automatically

**Timing:** 30-45 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - remove axiom, update proofs

**Verification:**
- `grep -n "^axiom " DiscreteTimeline.lean` returns empty
- `grep -n "\bsorry\b" DiscreteTimeline.lean` returns empty
- All instances (SuccOrder, PredOrder, LocallyFiniteOrder, IsSuccArchimedean) compile
- `discreteCanonicalTaskFrame` compiles
- `lake build` passes

---

### Phase 6: Final Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Ensure zero-debt completion and clean implementation

**Tasks:**
- [ ] Run `lake build` for full project verification
- [ ] Verify `grep -rn "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] Verify `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] Review docstrings: update technical debt comments to reflect resolution
- [ ] Remove "AXIOM (Technical Debt)" comment block (lines 232-242)
- [ ] Check dependent files still compile (any files importing DiscreteTimeline.lean)

**Timing:** 30 minutes

**Verification:**
- Zero axioms in DiscreteTimeline.lean
- Zero sorries in DiscreteTimeline.lean
- `lake build` passes completely
- All dependent files compile

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Key Lemmas to Verify
| Lemma | Expected State |
|-------|---------------|
| `df_frame_condition_canonical` | Proven (no sorry) |
| `icc_finite_from_covering` | Proven (no sorry) |
| `discrete_Icc_finite` | Uses `icc_finite_from_covering` (not axiom) |
| `discreteCanonicalTaskFrame` | Compiles successfully |

## Artifacts & Outputs

- `specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/plans/implementation-001.md` (this file)
- `specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
- Possibly modified: `Theories/Bimodal/Metalogic/Soundness.lean` (if DF extraction requires new exports)

## Rollback/Contingency

**If Phase 1 reveals DF infrastructure missing**:
- Document gap in plan update
- Mark [BLOCKED] with review_reason: "DF frame condition not extractable from current Soundness.lean"
- User decides: expand scope to include Soundness.lean work, or defer task

**If Phase 2 covering proof intractable (>2h)**:
- Mark [BLOCKED] with requires_user_review: true
- Document proof sketch and specific blocker
- Do NOT introduce sorry or axiom

**If Phase 4 finiteness proof circular**:
- Try alternative: direct well-founded induction on interval size
- If still stuck, mark [BLOCKED] with review_reason
- Do NOT leave axiom in place

**Full rollback**:
- `git checkout HEAD -- Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
- Restores axiom version from task 974
