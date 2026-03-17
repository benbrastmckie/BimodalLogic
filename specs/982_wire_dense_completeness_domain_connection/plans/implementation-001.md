# Implementation Plan: Wire Dense Completeness Domain Connection

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Status**: [IMPLEMENTING]
- **Effort**: 4.5 hours
- **Dependencies**: Tasks 956 (D construction), 978 (typeclass architecture)
- **Research Inputs**: specs/982_wire_dense_completeness_domain_connection/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Connect the CanonicalMCS-based truth lemma infrastructure (D = Int) to the TimelineQuot-based dense completeness statement. The user constraint is critical: **D must emerge from TimelineQuot's syntactic structure via Cantor's theorem, NOT be imported as Int or Rat**. This requires refactoring CanonicalConstruction.lean to be generic over D, then instantiating with TimelineQuot.

### Research Integration

Research-001 identified:
- **Domain Gap**: CanonicalMCS (all MCSs, Preorder) vs TimelineQuot (Antisymmetrization, DenselyOrdered)
- **Resolution**: Option D (Unified Domain Construction) - Build FMCS directly over TimelineQuot using representative MCSs
- **AddCommGroup Issue**: TimelineQuot lacks AddCommGroup; TaskFrame needs `D = TimelineQuot`
- **Key Insight**: `ofAntisymmetrization` extracts MCS from TimelineQuot elements

## Goals & Non-Goals

**Goals**:
- Resolve the sorry in `dense_completeness_fc` (FrameConditions/Completeness.lean)
- Build FMCS infrastructure over TimelineQuot (D discovered, not imported)
- Prove truth lemma for TimelineQuot-indexed families
- Achieve zero-sorry dense completeness theorem
- Maintain axiom transparency (only `canonicalR_irreflexive` axiom)

**Non-Goals**:
- Discrete completeness (blocked by `discrete_Icc_finite_axiom`, out of scope)
- Removing `canonicalR_irreflexive` axiom (separate task involving atom type change)
- Refactoring soundness proofs

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| AddCommGroup constraint blocks wiring | High | High | Refactor TaskFrame to not require AddCommGroup for all D, OR build algebraic structure on TimelineQuot |
| ofAntisymmetrization choice issues | High | Medium | Prove MCS equivalence preserved under representative choice using AntisymDual |
| Coherence proofs complex | Medium | Medium | Leverage existing CanonicalFMCS patterns, adapt for TimelineQuot domain |
| Existing Int-based proofs break | Medium | Low | Create new TimelineQuot-specific module, don't modify CanonicalConstruction |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `Theories/Bimodal/FrameConditions/Completeness.lean` line 127 (`dense_completeness_fc`)

### Expected Resolution
- Phase 4 resolves `dense_completeness_fc` sorry by wiring TimelineQuot truth lemma to completeness statement

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries in dense completeness pipeline
- 1 axiom remains: `canonicalR_irreflexive` (documented, resolution path exists via atom type change)

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom: `canonicalR_irreflexive` in `Canonical/CanonicalIrreflexivityAxiom.lean`

### Expected Resolution
- No change to this axiom in this task (out of scope)
- Axiom is inherited by TimelineQuot density properties

### New Axioms
- None. This task introduces zero new axioms.

### Remaining Debt
After this implementation:
- 1 axiom: `canonicalR_irreflexive` (publication requires disclosure or atom type change)

## Implementation Phases

### Phase 1: Analyze TaskFrame AddCommGroup Dependency [COMPLETED]

- **Dependencies**: None
- **Goal**: Determine if AddCommGroup is needed for TaskFrame or only for specific validity definitions

**Tasks**:
- [x] Read `Theories/Bimodal/Semantics/TaskFrame.lean` to understand AddCommGroup usage
- [x] Check if `valid_over` requires AddCommGroup or if it's only in DenseCompletenessStatement
- [x] Determine path: (A) remove AddCommGroup from TaskFrame, (B) remove from DenseCompletenessStatement, (C) build AddCommGroup on TimelineQuot via Cantor iso

**Timing**: 30 minutes

**Files to examine**:
- `Theories/Bimodal/Semantics/TaskFrame.lean` - TaskFrame definition
- `Theories/Bimodal/FrameConditions/Completeness.lean` - DenseCompletenessStatement
- `Theories/Bimodal/Semantics/Validity.lean` - valid_over definition

**Verification**:
- Clear understanding of where AddCommGroup is required
- Decision documented on which path to take

**Progress:**

**Session: 2026-03-16, sess_1773705645_12453**
- Analyzed: TaskFrame requires AddCommGroup D in type signature (line 93)
- Analyzed: valid_over requires TaskFrame, so inherits AddCommGroup requirement
- Analyzed: TimelineQuot has all instances needed for DurationTransfer.ratAddCommGroup
- Decision: Use Option C - transfer AddCommGroup from Rat to TimelineQuot via Cantor isomorphism
- Key insight: DurationTransfer.lean already provides ratAddCommGroup for any T with LinearOrder, Countable, DenselyOrdered, NoMaxOrder, NoMinOrder, Nonempty

---

### Phase 2: Create TimelineQuotFMCS Module [PARTIAL]

- **Dependencies**: Phase 1
- **Goal**: Define FMCS over TimelineQuot using representative MCSs

**Tasks**:
- [x] Create `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotAlgebra.lean`
- [x] Define `timelineQuotAddCommGroup` via DurationTransfer.ratAddCommGroup
- [x] Prove `timelineQuotIsOrderedAddMonoid`
- [x] Prove `timelineQuotNontrivial`
- [x] Define `timelineQuot_instantiate_dense` for validity quantification
- [ ] Define `timelineQuotMCS : TimelineQuot -> Set Formula` using `ofAntisymmetrization`
- [ ] Prove `timelineQuot_lt_implies_canonicalR` for FMCS coherence
- [ ] Define `timelineQuotFMCS : FMCS TimelineQuot`

**Timing**: 1.5 hours (estimated additional 1 hour needed)

**Files created**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotAlgebra.lean` - NEW, builds successfully

**Blocking Issue**:
The proof of `timelineQuot_lt_implies_canonicalR` is complex because:
1. `ofAntisymmetrization` picks arbitrary representatives from equivalence classes
2. Representatives may differ from the original elements
3. Tracking CanonicalR through equivalent elements requires careful reasoning about g_content/h_content

**Alternative Approach**:
Instead of building FMCS directly over TimelineQuot, consider:
1. Using the existing `canonical_truth_lemma` over `BFMCS Int`
2. Building a TaskFrame over TimelineQuot (using timelineQuotAddCommGroup)
3. Transferring validity through the semantic model

**Progress:**

**Session: 2026-03-16, sess_1773705645_12453**
- Created: `TimelineQuotAlgebra.lean` with AddCommGroup transfer (builds successfully)
- Attempted: `TimelineQuotFMCS.lean` but proof of `timelineQuot_lt_implies_canonicalR` blocked
- Key insight: ofAntisymmetrization representative choice complicates CanonicalR tracking
- Alternative: May need to use TaskFrame over TimelineQuot with different model construction

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotAlgebra` passes

---

### Phase 3: Build TimelineQuot Truth Lemma [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Prove truth lemma for TimelineQuot-indexed FMCS families

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotTruthLemma.lean`
- [ ] Define `TimelineQuotTaskFrame : TaskFrame TimelineQuot` (using strict order as task_rel)
- [ ] Define `TimelineQuotTaskModel : TaskModel TimelineQuotTaskFrame`
- [ ] Define `to_history_quot : FMCS TimelineQuot -> WorldHistory TimelineQuotTaskFrame`
- [ ] Define `TimelineQuotOmega : BFMCS TimelineQuot -> Set (WorldHistory ...)`
- [ ] Prove `timelineQuot_truth_lemma`:
  ```lean
  theorem timelineQuot_truth_lemma
      (B : BFMCS TimelineQuot) (h_tc : B.temporally_coherent)
      (fam : FMCS TimelineQuot) (hfam : fam in B.families)
      (t : TimelineQuot) (phi : Formula) :
      phi in fam.mcs t <-> truth_at TimelineQuotTaskModel (TimelineQuotOmega B) (to_history_quot fam) t phi
  ```
- [ ] Adapt proof pattern from CanonicalConstruction.lean (it's structurally similar, just different D)

**Timing**: 1.5 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotTruthLemma.lean` - NEW

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotTruthLemma` passes
- `grep -n "\bsorry\b" TimelineQuotTruthLemma.lean` returns empty
- `lean_goal` shows "no goals" at truth lemma QED

---

### Phase 4: Wire Dense Completeness Theorem [NOT STARTED]

- **Dependencies**: Phase 2, Phase 3
- **Goal**: Resolve the sorry in `dense_completeness_fc`

**Tasks**:
- [ ] Update `Theories/Bimodal/FrameConditions/Completeness.lean`
- [ ] Import TimelineQuot truth lemma infrastructure
- [ ] Implement `dense_completeness_fc` proof:
  1. From `h_valid : forall D [constraints], valid_over D phi`
  2. Contrapositive: assume `phi` not provable
  3. Then `phi.neg` is consistent (else phi provable)
  4. Extend to MCS via Lindenbaum -> get `root_mcs`
  5. Construct BFMCS over `TimelineQuot root_mcs root_mcs_proof`
  6. Use `temporal_coherent_family_exists_CanonicalMCS` (adapted for TimelineQuot)
  7. By `timelineQuot_truth_lemma`: `phi.neg` true at evaluation point
  8. TimelineQuot satisfies DenselyOrdered, NoMaxOrder, NoMinOrder constraints
  9. Instantiate `h_valid` with `D = TimelineQuot` -> `phi` valid there
  10. Contradiction: `phi` valid but `phi.neg` satisfiable
- [ ] Remove the sorry, complete the proof

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` - resolve sorry

**Verification**:
- `lake build Bimodal.FrameConditions.Completeness` passes
- `grep -n "\bsorry\b" Completeness.lean` returns empty for dense_completeness_fc
- `#check @dense_completeness_fc` shows the theorem with no sorry

---

### Phase 5: Final Verification and Cleanup [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Verify zero-sorry status and clean up

**Tasks**:
- [ ] Run `lake build` to verify full build passes
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/` - verify no new sorries
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/FrameConditions/Completeness.lean` - verify only discrete sorries remain
- [ ] Run `grep -n "^axiom " Theories/Bimodal/` - verify no new axioms introduced
- [ ] Update module documentation to reflect TimelineQuot-based completeness
- [ ] Verify `canonicalR_irreflexive` is the only axiom in the completeness dependency chain

**Timing**: 30 minutes

**Files to verify**:
- All files created in Phases 2-4
- `Theories/Bimodal/FrameConditions/Completeness.lean`

**Verification**:
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuot*.lean` returns empty
- `grep -n "^axiom " Theories/Bimodal/Metalogic/` shows only `canonicalR_irreflexive`
- Dense completeness pipeline is publication-ready (axiom disclosed)

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Dense completeness theorem compiles without sorry
- [ ] TimelineQuot truth lemma is structurally complete
- [ ] No Int or Rat imports in the completeness chain (except CantorApplication which uses Rat for isomorphism target only)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotFMCS.lean` - NEW
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotTruthLemma.lean` - NEW
- `Theories/Bimodal/FrameConditions/Completeness.lean` - MODIFIED (sorry resolved)
- `specs/982_wire_dense_completeness_domain_connection/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation fails:
1. New files (TimelineQuotFMCS.lean, TimelineQuotTruthLemma.lean) can be deleted
2. Completeness.lean changes can be reverted via git
3. If Phase 1 determines AddCommGroup cannot be removed and TimelineQuot cannot have AddCommGroup, mark task [BLOCKED] with review_reason explaining the structural constraint

## Notes

**Critical User Constraint**: D must NOT be imported as Int or Rat. D emerges from TimelineQuot which is order-isomorphic to Rat via Cantor's theorem, but the actual domain is the syntactically-constructed TimelineQuot. The Rat isomorphism is only used to prove DenselyOrdered and related properties - Rat is never used as D itself.

**Why This Approach Works**: TimelineQuot elements contain MCSs (via `ofAntisymmetrization -> DenseTimelineElem.val.mcs`). The truth lemma structure from CanonicalConstruction.lean transfers directly because:
1. The MCS membership checks work the same way
2. The temporal coherence properties (forward_G, backward_H) are expressed in terms of CanonicalR
3. The ordering on TimelineQuot is derived from CanonicalR
4. The only difference is the domain type - structural proofs remain identical

**AddCommGroup Resolution**: The DenseCompletenessStatement requires AddCommGroup D, but this may be removable. TimelineQuot has LinearOrder and DenselyOrdered but NOT AddCommGroup. Options:
1. Remove AddCommGroup from DenseCompletenessStatement (preferred if validity doesn't require it)
2. Build AddCommGroup on TimelineQuot using Cantor isomorphism to transfer from Rat
3. Weaken validity definition to not require AddCommGroup

The choice is determined in Phase 1.
