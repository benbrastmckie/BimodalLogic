# Implementation Plan: Remove singleFamily_modal_backward_axiom (Revised)

- **Task**: 843 - remove_singleFamily_modal_backward_axiom
- **Version**: 002
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours (revised down from 9)
- **Dependencies**: Task 856 (COMPLETED - provides EvalCoherentBundle infrastructure)
- **Related**: Task 857 (temporal backward - aligned approach)
- **Research Inputs**: research-001.md, research-002.md, research-003.md (blocking analysis)
- **Type**: lean
- **Lean Intent**: true

## Overview

This revised plan adopts the **eval-only strategy** aligned with task 857. The key insight from research-003 is that completeness theorems only use the **forward direction** (.mp) of the truth lemma and only evaluate at eval_family. This means we don't need full modal coherence at all families - only at the evaluation point.

### What Changed from v001

1. **Recognized the blocking issue** - Phase 2 was blocked because EvalBMCS lacks full modal coherence at all families
2. **Identified the correct solution** - eval-only pattern: truth lemma only needs forward direction at eval_family
3. **Dramatically reduced scope** - only 2 phases needed (not 4), much simpler approach
4. **Aligned with task 857** - both tasks use same structural pattern

### Key Insight from Research-003

> "The completeness theorems in Completeness.lean only use the **forward direction** (.mp) of the truth lemma... This doesn't require the IFF at other families because we're only going membership -> truth at eval_family."

**Implication**: We don't need to prove the full bidirectional truth lemma. We only need:
- φ ∈ eval_family.mcs t → truth φ at eval_family (forward direction)

This is **already provable** with existing EvalBMCS infrastructure.

## Goals & Non-Goals

**Goals**:
- Prove eval-only forward truth lemma for EvalBMCS
- Rewire completeness theorems to use `construct_eval_bmcs` with eval-only truth lemma
- Comment out `singleFamily_modal_backward_axiom` (no longer needed)
- Reduce repository axiom count by 1

**Non-Goals**:
- Proving full bidirectional truth lemma at all families (impossible with EvalBMCS)
- Removing temporal sorries (task 857)
- Achieving BoxEquivalent coherence (proven impossible in research-003)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Eval-only forward direction doesn't suffice for completeness | High | Very Low | Research-003 verified completeness only uses .mp |
| Type mismatches in eval-only definitions | Medium | Low | Follow existing patterns exactly |
| Build failures in dependent code | Medium | Low | All changes are additive, original preserved |

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom in `Construction.lean:228`: `singleFamily_modal_backward_axiom`

### Expected Resolution
- Phase 2 comments out the axiom after completeness is rewired
- Axiom becomes orphaned - no longer in completeness dependency chain

### New Axioms
- None. The eval-only approach uses structural proofs only.

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in TruthLemma.lean (temporal backward - task 857)
- 2 sorries in eval_bmcs_truth_lemma (modal backward at non-eval families)

### Expected Resolution
- Temporal sorries: Not in scope (task 857)
- Modal backward sorries: **Accepted as documented limitations** - they don't affect completeness because completeness only uses forward direction at eval_family

### New Sorries
- None. The eval-only truth lemma forward direction is fully provable.

### Remaining Debt
- Modal backward sorries: Documented limitation (not blocking completeness)
- Temporal sorries: Remediation via task 857

## Implementation Phases

### Phase 1: Eval-Only Forward Truth Lemma [NOT STARTED]

**Goal**: Prove the forward direction of the truth lemma for EvalBMCS at eval_family only.

**Key Insight**: The forward direction at eval_family:
```lean
-- Goal: φ ∈ eval_family.mcs t → truth φ at eval_family
-- For box case:
--   □ψ ∈ eval_family.mcs t
--   → ψ ∈ fam'.mcs t for all fam' (via modal_forward_eval)
--   → truth ψ at fam' for all fam' (needs IH at all families? NO!)
--   → We only need: truth ψ at ALL families for the semantics
--   → We get this from membership at all families via separate reasoning
```

Actually, re-examining: the forward direction of the box case requires `ψ ∈ fam'.mcs → truth ψ at fam'` for ALL families, which needs the IH at all families.

**Revised Approach**: Create `eval_bmcs_forward_truth_lemma` that only proves the forward direction, with explicit handling of the box case:

```lean
-- Forward-only truth at eval_family
theorem eval_bmcs_forward_truth_lemma (B : EvalBMCS D) (t : D) (φ : Formula) :
    φ ∈ B.eval_family.mcs t → eval_bmcs_truth_at B B.eval_family t φ
```

The box case forward direction:
1. □ψ ∈ eval_family.mcs t
2. By modal_forward_eval: ψ ∈ fam'.mcs t for all fam'
3. Need: eval_bmcs_truth_at B fam' t ψ for all fam'
4. **This requires proving forward truth at ALL families recursively**

**Alternative**: Define truth semantically (independent of membership) and show membership implies truth:

```lean
-- Define semantic truth directly
def semantic_truth (families : Set (IndexedMCSFamily D)) (t : D) : Formula → Prop
| .var n => true  -- or however vars are evaluated
| .box ψ => ∀ fam ∈ families, semantic_truth families t ψ
| ...

-- Prove membership implies semantic truth
theorem membership_implies_semantic_truth (B : EvalBMCS D) (φ : Formula) (t : D) :
    φ ∈ B.eval_family.mcs t → semantic_truth B.families t φ
```

**Tasks**:
- [ ] Define `eval_semantic_truth` predicate (independent of membership)
- [ ] Prove `eval_membership_implies_truth`: φ ∈ eval_family.mcs t → truth φ
- [ ] For box case: use modal_forward_eval + induction
- [ ] Leave backward direction as sorry (documented limitation)
- [ ] Verify compilation

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - add eval-only forward lemma

**Verification**:
- `lake build` passes
- Forward direction fully proven (no sorry)
- Backward direction has sorry (documented)

---

### Phase 2: Completeness Rewiring and Axiom Removal [NOT STARTED]

**Goal**: Rewire completeness to use EvalBMCS with eval-only truth, then remove axiom.

**Key Observation**: The completeness theorem structure:
```lean
theorem bmcs_representation (φ : Formula) (h_cons : ContextConsistent [φ]) :
    ∃ (B : BMCS Int), bmcs_truth_at B B.eval_family 0 φ := by
  ...
  have h_in_mcs : φ ∈ B.eval_family.mcs 0 := ...
  exact (bmcs_truth_lemma B B.eval_family B.eval_family_mem 0 φ).mp h_in_mcs
```

Only `.mp` (forward direction) is used, and only at `B.eval_family`.

**Tasks**:
- [ ] Create `eval_bmcs_representation` using `construct_eval_bmcs`
- [ ] Use eval-only forward truth lemma to close the goal
- [ ] Create `eval_bmcs_weak_completeness` and `eval_bmcs_strong_completeness`
- [ ] Verify no axiom dependencies: `#check @eval_bmcs_strong_completeness`
- [ ] Comment out `singleFamily_modal_backward_axiom` with explanation
- [ ] Update repository_health.axiom_count in state.json
- [ ] Create implementation summary

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - EvalBMCS versions
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - comment out axiom

**Verification**:
- `lake build` passes
- `#check @eval_bmcs_strong_completeness` shows no axiom dependencies
- `grep -r "singleFamily_modal_backward_axiom" Theories/` returns only comments

---

## Testing & Validation

- [ ] `lake build` passes with no errors
- [ ] `#check @eval_bmcs_strong_completeness` shows no axiom dependencies
- [ ] `grep -r "singleFamily_modal_backward_axiom" Theories/` returns only comments
- [ ] Forward direction of eval-only truth lemma has no sorry
- [ ] Completeness theorem chain is axiom-free

## Artifacts & Outputs

- `specs/843_remove_singleFamily_modal_backward_axiom/plans/implementation-002.md` (this file)
- `specs/843_remove_singleFamily_modal_backward_axiom/summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified files:
  - `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
  - `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
  - `Theories/Bimodal/Metalogic/Bundle/Construction.lean`

## Alignment with Task 857

| Aspect | Task 843 (Modal) | Task 857 (Temporal) |
|--------|------------------|---------------------|
| Problem | Full modal coherence needed for bidirectional truth lemma | Full temporal saturation needed for bidirectional truth lemma |
| Solution | Eval-only forward truth lemma | Eval-only forward truth lemma |
| What's proven | Forward: membership → truth at eval_family | Forward: membership → truth at eval_family |
| What's sorry | Backward: truth → membership | Backward: truth → membership (at non-eval times) |
| Completeness impact | None - only .mp used | None - only .mp used |

## Comparison to v001

| Aspect | v001 | v002 |
|--------|------|------|
| Total phases | 4 | 2 |
| Estimated hours | 9 | 4-6 |
| Blocking issue | Phase 2 - full modal coherence | Recognized as unnecessary |
| Key insight | Need full bidirectional truth lemma | Only need forward direction at eval |
| Approach | Try to strengthen EvalBMCS | Accept eval-only pattern |
| Alignment | None | Aligned with task 857 |

## Rollback/Contingency

If eval-only approach doesn't work:
1. Verify that completeness really only uses .mp direction
2. If backward direction is somehow needed, document the gap
3. Original BMCS infrastructure preserved - can fall back
4. The axiom is only commented, not deleted

If the forward direction itself fails:
1. Re-examine the box case induction
2. Check if we need a stronger induction hypothesis
3. Consider alternative truth definition
