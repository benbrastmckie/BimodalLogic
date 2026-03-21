# Implementation Plan: Task #9

- **Task**: 9 - add_existential_temporal_extractors
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/009_add_existential_temporal_extractors/reports/01_temporal-extractors.md
- **Artifacts**: plans/01_temporal-extractors-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Add two existential temporal content extractors (`f_content` and `p_content`) to `TemporalContent.lean`, complementing the existing universal extractors (`g_content` and `h_content`). These definitions extract formulas under the existential temporal operators F (some_future) and P (some_past). The implementation includes membership simp lemmas and duality lemmas relating existential and universal extractors via MCS negation completeness. This is foundational infrastructure for the Succ relation (tasks 10-15) and DenseTask relation (tasks 16-18).

### Research Integration

The research report (01_temporal-extractors.md) confirms:
- Definitions follow existing `g_content`/`h_content` pattern (2 lines each)
- Duality lemmas use `SetMaximalConsistent.negation_complete` and `set_consistent_not_both` from MCSProperties.lean
- No new imports required beyond existing dependencies
- Zero-sorry target achievable for all deliverables

## Goals & Non-Goals

**Goals**:
- Add `f_content` definition extracting formulas under F (some_future)
- Add `p_content` definition extracting formulas under P (some_past)
- Add `@[simp]` membership lemmas for both extractors
- Prove duality lemma: `f_content_iff_not_neg_in_g_content`
- Prove duality lemma: `p_content_iff_not_neg_in_h_content`
- Zero sorries in all new code

**Non-Goals**:
- `f_content_step_condition` (requires Succ relation context, deferred to tasks 10-15)
- `p_content_step_condition` (symmetric, deferred)
- Cross-MCS duality lemmas beyond basic single-MCS properties

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Definitional equality issues with `some_future`/`some_past` | M | L | Definitions are `rfl` by construction; test with `rfl` proof |
| MCS lemma incompatibility | M | L | Research confirmed `negation_complete` and `set_consistent_not_both` exist with correct signatures |
| Namespace issues | L | L | Follow existing `Bimodal.Metalogic.Bundle` namespace pattern |

## Implementation Phases

### Phase 1: Definitions and Membership Lemmas [NOT STARTED]

**Goal**: Add `f_content` and `p_content` definitions with simp lemmas

**Tasks**:
- [ ] Add `f_content` definition (2 lines + docstring)
- [ ] Add `p_content` definition (2 lines + docstring)
- [ ] Add `@[simp] lemma mem_f_content_iff` (3 lines)
- [ ] Add `@[simp] lemma mem_p_content_iff` (3 lines)
- [ ] Verify `lake build Bimodal.Metalogic.Bundle.TemporalContent` succeeds

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - add definitions and simp lemmas

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.TemporalContent` succeeds with no errors
- Definitions match pattern from `g_content`/`h_content`

---

### Phase 2: F/G Duality Lemma [NOT STARTED]

**Goal**: Prove `f_content_iff_not_neg_in_g_content` relating F and G extractors

**Tasks**:
- [ ] Add import for MCSProperties.lean (if not already present)
- [ ] Add `f_content_iff_not_neg_in_g_content` lemma with proof
- [ ] Verify proof uses `negation_complete` and `set_consistent_not_both` correctly
- [ ] Verify `lake build` succeeds

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - add duality lemma

**Proof Strategy**:
1. Forward direction: If `Fφ ∈ M` and `G(¬φ) ∈ M`, then `¬G(¬φ) ∈ M` (since `Fφ = ¬G¬φ` definitionally), contradicting MCS consistency via `set_consistent_not_both`
2. Backward direction: If `G(¬φ) ∉ M`, then by `negation_complete`, `¬G(¬φ) ∈ M`, which equals `Fφ`

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.TemporalContent` succeeds
- No sorry in proof

---

### Phase 3: P/H Duality Lemma [NOT STARTED]

**Goal**: Prove `p_content_iff_not_neg_in_h_content` (symmetric to Phase 2)

**Tasks**:
- [ ] Add `p_content_iff_not_neg_in_h_content` lemma with proof
- [ ] Verify proof follows symmetric pattern to F/G lemma
- [ ] Verify `lake build` succeeds

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - add duality lemma

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.TemporalContent` succeeds
- No sorry in proof

---

### Phase 4: Documentation and Final Verification [NOT STARTED]

**Goal**: Update module docstring and verify full build

**Tasks**:
- [ ] Update module docstring to document all four extractors
- [ ] Run `lake build` for full project to verify no downstream breakage
- [ ] Verify all new code has appropriate docstrings

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - update module header

**Verification**:
- Full `lake build` succeeds
- Module docstring documents f_content and p_content
- All definitions have docstrings explaining semantic role and downstream usage

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.TemporalContent` succeeds after each phase
- [ ] Full `lake build` succeeds after Phase 4
- [ ] No `sorry` in any new code
- [ ] Simp lemmas work: `simp only [mem_f_content_iff]` rewrites correctly
- [ ] Definitions match research specification exactly

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - modified with new definitions and lemmas
- `specs/009_add_existential_temporal_extractors/summaries/01_temporal-extractors-summary.md` - execution summary

## Rollback/Contingency

- If duality proofs become unexpectedly complex, mark lemmas with `sorry` and document blocker for follow-up task
- If import cycle issues arise, extract duality lemmas to separate file `ExistentialContent.lean`
- Git revert to pre-implementation state if fundamental approach issues discovered
