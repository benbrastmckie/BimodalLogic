# Implementation Plan: Wire Dense Completeness Domain Connection (v2)

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Status**: [NOT STARTED]
- **Effort**: 4 hours (remaining)
- **Dependencies**: Tasks 956 (D construction), 978 (typeclass architecture)
- **Research Inputs**:
  - specs/982_wire_dense_completeness_domain_connection/reports/research-001.md
  - specs/982_wire_dense_completeness_domain_connection/reports/research-002.md (blocker analysis)
- **Artifacts**: plans/implementation-002.md (this file), supersedes implementation-001.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

**v002 (2026-03-16)**: Revised based on research-002 blocker analysis. Adopts Approach A (Direct Truth Lemma over TimelineQuot) as the principled, publication-ready approach.

## Overview

The completeness wiring is structurally complete but blocked on one sorry: `timelineQuot_not_valid_of_neg_consistent`. Research-002 analyzed four approaches and recommends **Direct Truth Lemma over TimelineQuot** as the publication-quality solution.

### What's Already Done

- **Phase 1**: Complete - determined AddCommGroup transfers via DurationTransfer
- **Phase 2 (partial)**: Created TimelineQuotAlgebra.lean (sorry-free) and TimelineQuotCompleteness.lean (wiring structure)
- **Phase 4**: Complete - wired `dense_completeness_fc` to use `dense_completeness_theorem`

### What Remains

Build FMCS/BFMCS/TruthLemma infrastructure directly over TimelineQuot, then complete the sorry.

## Goals & Non-Goals

**Goals**:
- Complete `timelineQuot_not_valid_of_neg_consistent` (the single remaining sorry)
- Achieve zero-sorry dense completeness theorem
- Build reusable TimelineQuot canonical model infrastructure
- Publication-quality proof with no technical debt

**Non-Goals**:
- Discrete completeness (separate task)
- Removing `canonicalR_irreflexive` axiom (separate task)
- Any shortcuts that introduce technical debt

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| FMCS construction complexity | Medium | Low | Follow exact pattern from CanonicalFMCS.lean |
| Truth lemma case explosion | Medium | Low | Port structure from CanonicalConstruction.lean |
| CanonicalR representative issues | Low | Low | Already proven: timelineQuotMCS_is_mcs handles quotient |

## Sorry Characterization

### Current Sorries
- 1 sorry in `TimelineQuotCompleteness.lean:127` (`timelineQuot_not_valid_of_neg_consistent`)

### Expected Resolution
- Phase 3 builds truth lemma infrastructure, Phase 4 completes the sorry

### Remaining Debt
After this implementation:
- 0 sorries in dense completeness pipeline
- 1 axiom: `canonicalR_irreflexive` (documented, out of scope)

## Implementation Phases

### Phase 1: FMCS over TimelineQuot [NOT STARTED]

- **Dependencies**: Existing TimelineQuotCompleteness.lean
- **Goal**: Define FMCS structure indexed by TimelineQuot

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`
- [ ] Define `TimelineQuotFMCS` structure:
  - `mcs : TimelineQuot -> Set Formula` := `timelineQuotMCS` (already exists)
  - `is_mcs : forall t, SetMaximalConsistent (mcs t)` (use timelineQuotMCS_is_mcs)
  - `forward_G : forall t s, t < s -> forall phi, box (G phi) in mcs t -> G phi in mcs s`
  - `backward_H : forall t s, t < s -> forall phi, box (H phi) in mcs s -> H phi in mcs t`
- [ ] Prove forward_G using CanonicalR transitivity on representative MCSes
- [ ] Prove backward_H using g_content/h_content duality

**Key Insight**: TimelineQuot's `<` is defined via CanonicalR on representatives. Use `toAntisymmetrization_lt_toAntisymmetrization_iff` to relate quotient order to CanonicalR.

**Timing**: 1 hour

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - NEW

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" TimelineQuotCanonical.lean` returns empty

---

### Phase 2: BFMCS and Modal Coherence [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Define bundled FMCS with modal coherence properties

**Tasks**:
- [ ] Define `TimelineQuotBFMCS` structure in TimelineQuotCanonical.lean
  - Bundle of TimelineQuotFMCS families
  - Context containment (Gamma subset of root MCS)
  - Modal coherence properties
- [ ] Prove `modal_forward`: box phi in mcs t -> exists family with phi in mcs t
- [ ] Prove `modal_backward`: dual direction
- [ ] Prove `temporal_coherent_timelineQuot`: BFMCS is temporally coherent

**Pattern**: Follow CanonicalFMCS.lean structure exactly. The proofs transfer because TimelineQuot elements ARE MCSes (via ofAntisymmetrization).

**Timing**: 45 minutes

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - continue

**Verification**:
- `lake build` passes
- All BFMCS properties proven without sorry

---

### Phase 3: TaskFrame and Truth Lemma [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Define semantic structures and prove truth lemma

**Tasks**:
- [ ] Define `TimelineQuotTaskFrame : TaskFrame TimelineQuot` in TimelineQuotCanonical.lean
  - `WorldState := Subtype SetMaximalConsistent` (MCS subtype)
  - `task_rel := fun w1 w2 => exists f, f in B.families /\ exists t1 t2, t1 < t2 /\ ...`
- [ ] Define `TimelineQuotTaskModel : TaskModel TimelineQuotTaskFrame`
  - `valuation M p := atom p in M.val`
- [ ] Define `to_history_quot : TimelineQuotFMCS -> WorldHistory TimelineQuotTaskFrame`
- [ ] Define `ShiftClosedTimelineQuotOmega : TimelineQuotBFMCS -> Set (WorldHistory ...)`
- [ ] Prove `timelineQuot_truth_lemma`:
  ```lean
  theorem timelineQuot_truth_lemma (B : TimelineQuotBFMCS) (h_tc : B.temporally_coherent)
      (phi : Formula) (fam : TimelineQuotFMCS) (hfam : fam in B.families) (t : TimelineQuot) :
      phi in fam.mcs t <->
      truth_at TimelineQuotTaskModel (ShiftClosedTimelineQuotOmega B) (to_history_quot fam) t phi
  ```

**Proof Structure** (by induction on phi):
- `atom p`: Direct from valuation definition
- `bot`: MCS consistency (bot notin any MCS)
- `phi.imp psi`: MCS implication property
- `box psi`: modal_forward/modal_backward from BFMCS
- `all_future psi`: forward_G + quantification over shifted histories
- `all_past psi`: backward_H + quantification over shifted histories

**Timing**: 1.5 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - continue

**Verification**:
- `lean_goal` shows "no goals" at truth lemma QED
- `lake build` passes

---

### Phase 4: Complete timelineQuot_not_valid_of_neg_consistent [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Use truth lemma to complete the single remaining sorry

**Tasks**:
- [ ] In TimelineQuotCompleteness.lean, import TimelineQuotCanonical
- [ ] Prove `timelineQuot_not_valid_of_neg_consistent`:
  1. Given: `phi.neg` consistent, let `M_0 := lindenbaumMCS [phi.neg] h_cons`
  2. Build: `B : TimelineQuotBFMCS` with root MCS containing `phi.neg`
  3. By truth lemma: `phi.neg in M_0` implies `truth_at ... phi.neg`
  4. Since `truth_at ... phi.neg = not (truth_at ... phi)`, we have `not truth_at ... phi`
  5. Exhibit the countermodel: TaskFrame, TaskModel, Omega, history, time
  6. This witnesses `not valid_over TimelineQuot phi`

**Key Proof Step**:
```lean
-- phi.neg true at root implies phi false at root
have h_neg_true : truth_at TimelineQuotTaskModel Omega tau t phi.neg := by
  exact timelineQuot_truth_lemma B h_tc phi.neg root_fam root_fam_mem t
    |>.mp h_neg_in_mcs
-- truth_at for phi.neg = not truth_at phi (by imp/bot semantics)
have h_phi_false : not truth_at TimelineQuotTaskModel Omega tau t phi := by
  simp [Formula.neg, truth_at] at h_neg_true
  exact h_neg_true
-- Exhibit countermodel
exact ⟨TimelineQuotTaskFrame, TimelineQuotTaskModel, Omega, tau, ⟨h_sc, h_mem⟩, t, h_phi_false⟩
```

**Timing**: 30 minutes

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFIED

**Verification**:
- `grep -n "\bsorry\b" TimelineQuotCompleteness.lean` returns empty
- `lake build Bimodal.FrameConditions.Completeness` passes

---

### Phase 5: Final Verification [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Verify zero-sorry status and publication readiness

**Tasks**:
- [ ] Run `lake build` to verify full build passes
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuot*.lean` - verify empty
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/FrameConditions/Completeness.lean` - verify only discrete sorries
- [ ] Run `grep -n "^axiom " Theories/Bimodal/` - verify no new axioms
- [ ] Verify `dense_completeness_fc` has no sorry dependency
- [ ] Update implementation summary

**Timing**: 15 minutes

**Verification**:
- Dense completeness pipeline: 0 sorries, 1 disclosed axiom
- Publication-ready status confirmed

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Publication Quality Checklist
- [ ] Truth lemma follows standard modal logic completeness structure
- [ ] No transfer tricks or embedding hacks
- [ ] All infrastructure reusable for future TimelineQuot work
- [ ] Proof structure mirrors Int-based canonical construction

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - NEW (FMCS, BFMCS, truth lemma)
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFIED (sorry resolved)
- `specs/982_wire_dense_completeness_domain_connection/summaries/implementation-summary-{DATE}.md` - UPDATED

## Rollback/Contingency

If Approach A proves intractable:
1. **Fallback to Approach C** (minimal semantic argument): Build direct countermodel without full infrastructure
2. **Mark BLOCKED** if fundamental obstacle discovered (e.g., quotient representative issues)

## Notes

**Why Direct Truth Lemma**: Research-002 evaluated four approaches. Direct truth lemma over TimelineQuot is:
- Publication-quality (standard mathematical structure)
- Reusable (infrastructure supports future work)
- Zero-debt (no axioms, no sorries)
- Low risk (follows proven Int-based pattern)

**Key Technical Insight**: TimelineQuot elements contain MCSes via `ofAntisymmetrization`. The `timelineQuotMCS` function extracts this. All CanonicalR-based reasoning from the Int case transfers because:
1. `TimelineQuot.lt` is defined via CanonicalR on representatives
2. MCS properties (consistency, maximality) are preserved
3. Truth lemma structure is domain-agnostic
