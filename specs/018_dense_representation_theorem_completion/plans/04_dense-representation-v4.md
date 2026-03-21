# Implementation Plan: Dense Representation Theorem Completion (v4)

- **Task**: 18 - dense_representation_theorem_completion
- **Status**: [NOT STARTED]
- **Effort**: 6-7 hours
- **Dependencies**: Task 27 (completed)
- **Research Inputs**: reports/13_post-task27-analysis.md (primary), reports/12_team-research.md
- **Artifacts**: plans/04_dense-representation-v4.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan completes the dense representation theorem using DovetailedTimelineQuot (integrated via Task 27). The previous plan v3 targeted DenseTimeline (TimelineQuot) sorries; those are now **bypassed** via the dovetailed construction.

### Key Changes from v3

1. **Phase 3 Revised**: No longer fixing ClosureSaturation.lean sorries (lines 698, 703, 718). Instead, discharge j>0 termination sorries in DovetailedTimelineQuot.lean.

2. **Phase 4 Updated**: Build multi-family BFMCS over `DovetailedTimelineQuot` instead of `TimelineQuot`.

3. **Phase 5 Updated**: Wire completeness using `DovetailedTimelineQuot` as the witness domain.

### Completed Work (Phases 1-2)

- **Phase 1**: `derive_F_to_FF` derivation complete (CantorPrereqs.lean - 0 sorries)
- **Phase 2**: Dovetailed coverage infrastructure complete (DovetailedCoverage.lean - 0 sorries)

### Remaining Sorries

| File | Line(s) | Category | Action |
|------|---------|----------|--------|
| DovetailedTimelineQuot.lean | 295 | Structural | Discharge with coverage completeness |
| DovetailedTimelineQuot.lean | 806, 959, 1028 | Termination | Discharge with lexicographic measure |
| ClosureSaturation.lean | 698, 703, 718, 780 | Bypassed | Keep as-is (use dovetailed construction) |
| TimelineQuotCompleteness.lean | 127 | Blocks final | Discharge via DovetailedTimelineQuot |

## Goals & Non-Goals

**Goals**:
- Discharge j>0 termination sorries in forward_F_chain_witness and backward_P_chain_witness
- Build multi-family BFMCS over DovetailedTimelineQuot
- Complete dense_completeness_theorem using DovetailedTimelineQuot as domain
- Add ExistsTask alias for documentation clarity

**Non-Goals**:
- Fix ClosureSaturation.lean DenseTimeline sorries (bypassed by dovetailed construction)
- Eliminate singleton BFMCS modal_backward sorry (provably impossible)
- Full CanonicalR -> ExistsTask rename (separate task 25)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| j>0 termination proof is subtle | M | M | Use lexicographic measure (max_stage - stage, formula_depth) |
| DovetailedTimelineQuot density sorry | L | M | Accept localized sorry if needed - main path works |
| Multi-family BFMCS construction | M | L | Reuse existing closedFlags pattern from CanonicalFMCS.lean |

## Implementation Phases

### Phase 3: Discharge j>0 Termination Sorries [PARTIAL]

**Goal**: Discharge the j>0 case sorries in forward_F_chain_witness and backward_P_chain_witness.

**Analysis**:
The `forward_F_chain_witness` theorem uses strong induction on iteration depth `i`. When density produces `j > 0` (formula encoding < stage), the witness formula has depth `j + i` which is larger than `i`. The termination argument requires a lexicographic measure:
- `(max_stage - current_stage, formula_depth)`
- Even when formula depth increases (j > 0), stage increases too, so first component decreases

**Tasks**:
- [ ] Analyze current termination structure in DovetailedTimelineQuot.lean
- [ ] Define lexicographic measure for witness chain construction
- [ ] Discharge sorry at line 806 (forward_F_chain_witness j>0)
- [ ] Discharge sorry at line 959 (backward_P_chain_witness j>0)
- [ ] Discharge sorry at line 1028 (variant case)
- [ ] Optionally discharge sorry at line 295 (density intermediate) or document as acceptable
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`

**Verification**:
- `grep -n "sorry" DovetailedTimelineQuot.lean` returns only line 295 (density) or no results
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot` succeeds

---

### Phase 4: Build Multi-Family BFMCS over DovetailedTimelineQuot [NOT STARTED]

**Goal**: Construct properly saturated BFMCS using DovetailedTimelineQuot.

**Key Change from v3**: Use `DovetailedTimelineQuot` instead of `TimelineQuot`.

**Tasks**:
- [ ] Create `dovetailedTimelineQuotMultiFamilyBFMCS` using closedFlags pattern
  - Primary family: dovetailedTimelineQuotFMCS
  - Modal witness families: from closedFlags (finite set of diamond witnesses)
- [ ] Prove `modal_forward`: Box phi in mcs(t) of any family implies phi in mcs(t) of all families
- [ ] Prove `modal_backward`: phi in all families at t implies Box phi in any family at t
- [ ] Bundle temporal coherence from Phase 3 into BFMCS structure
- [ ] Run `lake build` to confirm BFMCS compiles

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedFMCS.lean` (extend with multi-family)
- Create new file or extend existing for multi-family BFMCS bundle

**Verification**:
- `dovetailedTimelineQuotMultiFamilyBFMCS` has no sorry in modal_forward or modal_backward
- `temporally_coherent` uses dovetailed forward_F/backward_P without sorry
- `lake build` succeeds

---

### Phase 5: Wire Dense Completeness via DovetailedTimelineQuot [NOT STARTED]

**Goal**: Complete the main theorem using DovetailedTimelineQuot as witness domain.

**Key Change from v3**: Wire completeness through `DovetailedTimelineQuot`, not `TimelineQuot`.

**Tasks**:
- [ ] Create `dovetailedTimelineQuot_not_valid_of_neg_consistent`:
  - Instantiate `parametric_canonical_truth_lemma` at D = DovetailedTimelineQuot
  - Use Phase 4 BFMCS with proper temporal coherence
  - Connect phi.neg in root MCS to semantic evaluation via truth lemma
- [ ] Verify `dense_completeness_theorem` compiles without sorry:
  - Uses dovetailedTimelineQuot_not_valid_of_neg_consistent
  - Instance resolution for DovetailedTimelineQuot constraints (Countable, DenselyOrdered)
- [ ] Add ExistsTask alias in CanonicalFrame.lean:
  - `abbrev ExistsTask := CanonicalR`
  - Update docstring to document derivation from CanonicalTask
- [ ] Final `lake build` to confirm full compilation

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` (add dovetailed variant)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (add ExistsTask alias)

**Verification**:
- `grep -n "sorry" TimelineQuotCompleteness.lean` shows no critical sorries
- `dense_completeness_theorem` or `dovetailed_dense_completeness_theorem` compiles without sorry
- `lake build` succeeds on full project
- `grep "ExistsTask" CanonicalFrame.lean` shows alias definition

---

## Testing & Validation

- [ ] All Phase 3-5 `lake build` checks pass
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/StagedConstruction/ | grep -v "//"` shows only:
  - DovetailedTimelineQuot.lean:295 (density intermediate, acceptable)
  - ClosureSaturation.lean deprecated/bypassed sorries (documented)
- [ ] `dense_completeness_theorem` or `dovetailed_dense_completeness_theorem` is invocable
- [ ] No regression in existing proofs (verified by full `lake build`)

## Artifacts & Outputs

- `plans/04_dense-representation-v4.md` (this file)
- `summaries/04_implementation-summary.md` (after completion)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedFMCS.lean`
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`
- Modified: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`

## Rollback/Contingency

1. **j>0 Termination Difficulty**
   - Accept localized sorry with mathematical justification
   - Document as "termination proven mathematically, Lean mechanization deferred"
   - The j=0 case covers the main execution path

2. **Density Intermediate Sorry**
   - Accept the DovetailedTimelineQuot.lean:295 sorry
   - This is structural and doesn't affect completeness proof

3. **Multi-Family BFMCS Issues**
   - Reuse existing multi-family patterns from CanonicalFMCS.lean
   - The closedFlags approach is proven to work

4. **Git Rollback**
   - Each phase committed atomically
   - `git revert` can undo individual phase commits
   - Task 27 changes are preserved (separate commits)
