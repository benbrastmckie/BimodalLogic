# Implementation Plan: Remove singleFamily_modal_backward_axiom

- **Task**: 843 - remove_singleFamily_modal_backward_axiom
- **Status**: [NOT STARTED]
- **Effort**: 9 hours
- **Dependencies**: Task 856 (COMPLETED - provides EvalCoherentBundle infrastructure)
- **Research Inputs**: reports/research-001.md, reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Remove the `singleFamily_modal_backward_axiom` from the codebase by rewiring the completeness theorems to use the proven `EvalBMCS` infrastructure from task 856. The EvalCoherentBundle approach proves modal backward via contraposition using multi-family saturation, which is mathematically sound and avoids the converse T-axiom problem that necessitated the axiom.

### Research Integration

- **research-001.md**: Identified axiom usage sites (Construction.lean:264, SaturatedConstruction.lean:181), mapped dependency chain through `construct_bmcs` to completeness theorems, outlined 4-phase implementation approach
- **research-002.md**: Confirmed EvalCoherentBundle avoids converse T-axiom via contraposition proof structure, validated that multi-family saturation is mathematically sound

## Goals & Non-Goals

**Goals**:
- Remove dependency on `singleFamily_modal_backward_axiom` from completeness theorems
- Create EvalBMCS truth infrastructure mirroring existing BMCS truth definitions
- Rewire `bmcs_representation`, `bmcs_weak_completeness`, and `bmcs_strong_completeness` to use `construct_eval_bmcs`
- Verify build passes with axiom commented out
- Reduce repository axiom count by 1

**Non-Goals**:
- Removing temporal sorries (independent issue, task 857)
- Modifying the EvalCoherentBundle infrastructure (already proven in task 856)
- Eliminating the `saturated_extension_exists` axiom (orthogonal, unused after this change)
- Converting EvalBMCS to full BMCS (unnecessary - EvalBMCS suffices for completeness)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| EvalBMCS truth definitions have subtle type mismatches | High | Low | Mirror existing definitions exactly, use same structure |
| Box case in truth lemma does not close | High | Low | Proof structure is identical - use `modal_forward_eval` and `modal_backward_eval` |
| Completeness theorem rewiring breaks other dependents | Medium | Low | Run full `lake build` after each phase, preserve old infrastructure |
| Type universe issues in EvalBMCS definitions | Medium | Medium | Study existing BMCS patterns, use same universe annotations |

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom in `Construction.lean:228`: `singleFamily_modal_backward_axiom` (asserts `phi in fam.mcs t -> Box phi in fam.mcs t`)

### Expected Resolution
- Phase 4 eliminates axiom dependency by rewiring completeness theorems to use `construct_eval_bmcs`
- Structural proof approach: EvalCoherentBundle's multi-family saturation proves modal backward via contraposition
- The proof shows: `NOT(Box phi in eval) -> NOT(phi in ALL families)` via saturation witnesses

### New Axioms
- None. The entire approach uses structural proofs from task 856.

### Remaining Debt
After this implementation:
- 0 axioms related to modal backward in saturation module
- `saturated_extension_exists` axiom remains but is orphaned (not used by completeness theorems)
- Completeness theorems become axiom-free for modal properties (temporal sorries remain but are independent)

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `TruthLemma.lean` at lines 387, 400 (temporal backward directions)
- These are inherited from prior work and independent of the axiom removal

### Expected Resolution
- This task does NOT resolve temporal sorries (blocked on task 857)
- The new `eval_bmcs_truth_lemma` will inherit the same 2 temporal sorries

### New Sorries
- None expected. The EvalBMCS truth infrastructure uses identical proof patterns.
- If complexity requires temporary sorry, will document with specific remediation plan.

### Remaining Debt
After this implementation:
- 2 sorries remain in truth lemma (temporal backward)
- These block publication but are orthogonal to axiom removal
- Remediation: task 857 (`add_temporal_backward_properties`)

## Implementation Phases

### Phase 1: EvalBMCS Truth Definitions [NOT STARTED]

**Goal**: Create truth definitions for EvalBMCS that mirror existing BMCS truth definitions

**Tasks**:
- [ ] Read existing `bmcs_truth_at` definition structure in BMCSTruth.lean
- [ ] Create `eval_bmcs_truth_at : EvalBMCS D -> IndexedMCSFamily D -> D -> Formula -> Prop`
- [ ] Create helper lemmas: `eval_bmcs_truth_neg`, `eval_bmcs_truth_impl`, `eval_bmcs_truth_and`
- [ ] Create `eval_bmcs_satisfies` predicate for formula satisfaction
- [ ] Verify definitions compile without errors

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` - add EvalBMCS truth definitions

**Verification**:
- `lake build` passes
- New definitions type-check correctly
- No imports missing

---

### Phase 2: EvalBMCS Truth Lemma [NOT STARTED]

**Goal**: Create truth lemma for EvalBMCS linking formula membership to semantic truth

**Tasks**:
- [ ] Read existing `bmcs_truth_lemma` structure in TruthLemma.lean
- [ ] Create `eval_bmcs_truth_lemma` with same inductive structure
- [ ] Implement propositional cases (var, neg, impl, and) - direct mirror
- [ ] Implement box case using `modal_forward_eval` and `modal_backward_eval`
- [ ] Implement temporal cases with same sorries as existing lemma (inherited debt)
- [ ] Verify the truth lemma compiles

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - add EvalBMCS truth lemma

**Verification**:
- `lake build` passes
- Box case closes using EvalBMCS modal properties
- Same sorry count as existing truth lemma (2 temporal sorries)

---

### Phase 3: Completeness Theorem Rewiring [NOT STARTED]

**Goal**: Update completeness theorems to use EvalBMCS infrastructure instead of axiom-dependent BMCS

**Tasks**:
- [ ] Read current completeness theorem structure in Completeness.lean
- [ ] Create `eval_bmcs_representation` using `construct_eval_bmcs` instead of `construct_bmcs`
- [ ] Create `eval_bmcs_context_representation` for context preservation
- [ ] Create `eval_bmcs_valid_Int` and related validity definitions
- [ ] Create `eval_bmcs_weak_completeness` theorem
- [ ] Create `eval_bmcs_strong_completeness` theorem
- [ ] Verify all new theorems compile
- [ ] Update or alias the main exports to use EvalBMCS versions

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - rewire to EvalBMCS

**Verification**:
- `lake build` passes
- `#check @eval_bmcs_strong_completeness` shows no axiom dependencies
- Completeness theorems usable from external code

---

### Phase 4: Axiom Removal and Final Verification [NOT STARTED]

**Goal**: Remove axiom dependency and verify axiom-free completeness

**Tasks**:
- [ ] Comment out `singleFamily_modal_backward_axiom` in Construction.lean with explanation
- [ ] Comment out `singleFamilyBMCS` definition (no longer needed)
- [ ] Comment out axiom usage in SaturatedConstruction.lean if still referenced
- [ ] Run full `lake build` to verify no dependencies on axiom remain
- [ ] Run `#check @eval_bmcs_strong_completeness` to verify no axiom in dependency chain
- [ ] Update state.json repository_health.axiom_count
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - comment out axiom
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - comment out axiom usage if needed

**Verification**:
- Full `lake build` passes
- `#check` on completeness theorems shows no axiom dependencies
- Grep for axiom usage returns only comments
- Repository axiom count decremented in state.json

---

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No new sorries introduced (count should remain same or decrease)
- [ ] `#check @eval_bmcs_strong_completeness` shows no axiom dependencies
- [ ] `#check @eval_bmcs_weak_completeness` shows no axiom dependencies
- [ ] Completeness theorems remain usable (type signatures preserved)
- [ ] `grep -r "singleFamily_modal_backward_axiom" Theories/` returns only comments

## Artifacts & Outputs

- `specs/843_remove_singleFamily_modal_backward_axiom/plans/implementation-001.md` (this file)
- `specs/843_remove_singleFamily_modal_backward_axiom/summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified files:
  - `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean`
  - `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
  - `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
  - `Theories/Bimodal/Metalogic/Bundle/Construction.lean`

## Rollback/Contingency

If implementation fails:
1. All new definitions are additive (eval_bmcs_* prefixed) - can be removed without affecting existing code
2. Original BMCS infrastructure preserved - completeness theorems still work with axiom
3. Axiom is only commented, not deleted - can be uncommented if needed
4. Git revert to pre-implementation commit restores original state

If EvalBMCS truth lemma cannot close:
1. Review task 856 proof structure for modal_backward_eval
2. Check universe levels match
3. Verify EvalBMCS structure is correctly imported
4. Consult research-002.md for contraposition proof structure
