# Implementation Plan: Task 65 (v2 - Revised)

- **Task**: 65 - build_taskmodel_from_restricted_construction
- **Status**: [NOT STARTED]
- **Effort**: 3-4 hours
- **Dependencies**: Task 58 (parent - wire_completeness_to_frame_conditions)
- **Research Inputs**: specs/065_build_taskmodel_from_restricted_construction/reports/03_team-research.md
- **Artifacts**: plans/02_revised-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Revision Notes

**Removed**: Phase 2B (Bundle-Level Truth Lemma) - This approach does not resolve the coherence mismatch. The backward G case requires same-family witnesses (`neg(phi) in fam.mcs s` for the SAME `fam`), but bundle-level coherence only provides any-family witnesses (`fam' in families`). The path is fundamentally blocked.

**Simplified**: Two-phase plan focusing on verification then wiring existing infrastructure.

## Overview

The existing bundle infrastructure (`construct_bfmcs_bundle`, `ShiftClosedCanonicalOmega`, `shifted_truth_lemma`) is 95% complete. The gap is model-theoretic glue: instantiating `valid_over Int phi` with the canonical model and connecting to MCS membership.

This plan verifies the exact coherence requirements of `shifted_truth_lemma`, then wires the existing pieces together if viable.

## Goals & Non-Goals

**Goals**:
- Verify exact coherence requirements of `shifted_truth_lemma`
- Wire existing infrastructure to complete semantic completeness
- Eliminate the 3 target sorries in Completeness.lean

**Non-Goals**:
- Building new truth lemma variants (the bundle-level approach is blocked)
- Proving family-level coherence from bundle-level (proven infeasible)
- Modifying core `shifted_truth_lemma` proof

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Family-level coherence truly required | High | Medium | Document blocker, spawn focused task |
| Type/universe level mismatches | Medium | Medium | Careful instantiation, try `unify?` |
| Termination proof issues | Medium | Low | Use existing termination patterns |

## Implementation Phases

### Phase 1: Verify shifted_truth_lemma Requirements [COMPLETED]

**Goal**: Determine if existing `shifted_truth_lemma` works with bundle construction output

**Tasks**:
- [ ] Use `lean_hover_info` on `shifted_truth_lemma` to confirm exact signature
- [ ] Check hypothesis: does it require `B.temporally_coherent` (family-level)?
- [ ] If yes, trace proof to find where same-family witnesses are used
- [ ] Document finding with file:line references

**Timing**: 0.5 hours

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean:648-750` - shifted_truth_lemma proof
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean:216-219` - BFMCS.temporally_coherent definition

**Decision Gate**:
- If `shifted_truth_lemma` works with `BFMCS_Bundle` -> Proceed to Phase 2
- If requires family-level coherence -> ABORT with documented blocker

---

### Phase 2: Wire Existing Infrastructure [BLOCKED]

**Goal**: Complete the model-theoretic glue using existing bundle construction

**Condition**: Phase 1 confirms bundle-level coherence sufficient

**Tasks**:
- [ ] Create instantiation lemma: `valid_over Int phi` -> truth_at CanonicalTaskModel
- [ ] Verify `ShiftClosedCanonicalOmega B` satisfies shift-closure requirement
- [ ] Apply `shifted_truth_lemma` backward direction: truth -> MCS membership
- [ ] Connect to `construct_bfmcs_bundle_eval_at_zero`: evaluation at time 0
- [ ] Wire to target sorries in `Completeness.lean:186-214`
- [ ] Run `lake build` and `#print axioms` verification

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - add instantiation lemmas
- `Theories/Bimodal/Metalogic/Completeness.lean` - eliminate sorries

**Verification**:
- `lake build` compiles without new sorries
- `#print axioms` on new lemmas shows no sorryAx

---

## Testing & Validation

- [ ] `lake build` compiles all files without errors
- [ ] `#print axioms bundle_validity_implies_provability` shows no sorryAx
- [ ] `#print axioms dense_completeness_fc` shows no sorryAx
- [ ] `#print axioms discrete_completeness_fc` shows no sorryAx

## Artifacts & Outputs

- `plans/02_revised-plan.md` (this file)
- Modified Lean files: `CanonicalConstruction.lean`, `Completeness.lean`
- `summaries/01_implementation-summary.md` (after completion)

## Rollback/Contingency

If Phase 1 reveals family-level coherence is required:

1. **Document the specific blocking requirement** with proof trace
2. **Spawn focused subtask** for one of:
   - Weaken `shifted_truth_lemma` hypothesis (if proof allows)
   - Strengthen `construct_bfmcs_bundle` to provide family-level coherence
   - Alternative completeness proof strategy (syntactic vs semantic)
3. **Do not attempt** the Bundle-Level Truth Lemma approach (proven blocked)

**Why Bundle-Level Truth Lemma is blocked**:
The backward G case requires: `G(phi) not in fam.mcs t` -> exists `s > t, neg(phi) in fam.mcs s` (SAME family).
Bundle coherence only provides: exists `fam' in families, s > t, neg(phi) in fam'.mcs s` (ANY family).
This is an unbridgeable gap without family-level coherence.
