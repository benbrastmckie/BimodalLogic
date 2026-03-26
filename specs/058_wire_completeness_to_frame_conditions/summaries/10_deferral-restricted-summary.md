# Implementation Summary: Task #58 - Deferral-Restricted Task Construction (v9)

## Status: PARTIAL

**Session**: sess_1774545733_aec808
**Date**: 2026-03-26
**Plan**: plans/09_deferral-restricted-task.md

## Phase Status

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 1 | [PARTIAL] | Box closure lemmas added; `deferralClosure_closed_under_box_class` not needed as originally stated |
| Phase 2 | [NOT STARTED] | Deferral-restricted BFMCS construction blocked on backward chain |
| Phase 3 | [NOT STARTED] | Wire to parametric truth lemma blocked on Phase 2 |
| Phase 4 | [NOT STARTED] | Eliminate target sorries blocked on Phase 3 |

## Accomplished Work

### Box Closure Lemmas (SubformulaClosure.lean)

Added the following theorems to `Theories/Bimodal/Syntax/SubformulaClosure.lean`:

```lean
-- Any box formula in deferralClosure is in closureWithNeg
theorem box_in_deferralClosure_is_in_closureWithNeg

-- If Box(psi) is in closureWithNeg(phi), then psi is in subformulaClosure(phi)
theorem box_inner_in_subformulaClosure_of_closureWithNeg

-- If Box(psi) is in deferralClosure(phi), then psi is in subformulaClosure(phi)
theorem box_inner_in_subformulaClosure_of_deferralClosure

-- If Box(psi) is in deferralClosure(phi), then psi is in closureWithNeg(phi)
theorem box_inner_in_closureWithNeg_of_deferralClosure

-- If Box(psi) is in deferralClosure(phi), then psi is in deferralClosure(phi)
theorem box_inner_in_deferralClosure
```

These lemmas prove that `deferralClosure` is closed under extracting the inner formula from Box formulas, which is a key property for maintaining closure bounds through box_class_agree transitions.

### Build Verification

- `lake build` passes successfully
- No new sorries introduced
- All new lemmas verified with `#print axioms` (no sorry axiom)

## Key Findings

### Plan Reassessment

The original plan's Phase 1 goal ("Prove `deferralClosure_closed_under_box_class`") was based on a misunderstanding. The theorem as stated is mathematically impossible:

> "If M0 is restricted to `deferralClosure(phi)`, and W has `box_class_agree M0 W`, then W is also restricted to `deferralClosure(phi)`"

This is FALSE because W is an arbitrary MCS obtained via Lindenbaum extension. W can contain formulas outside `deferralClosure(phi)` even if its Box-content agrees with M0.

The ACTUAL property we need is weaker: W's box content stays within bounds because:
1. `box_class_agree M0 W` means W has the same Box-formulas as M0
2. M0's Box-formulas come from `deferralClosure(phi)` (by restriction)
3. If `Box(psi) ∈ W`, then `Box(psi) ∈ M0 ⊆ deferralClosure(phi)`
4. By `box_inner_in_deferralClosure`: `psi ∈ deferralClosure(phi)`

This property is what the added lemmas provide. However, this is not sufficient to proceed with Phases 2-4.

### The Real Gap

The completeness proof has two possible paths:

**Path A: Family-Level Coherence**
- Requires: `BFMCS D` with `temporally_coherent` (F/P witnesses in SAME family)
- Status: Blocked on implementing `constrained_predecessor_restricted` (backward chain)
- Infrastructure: `restricted_forward_chain_forward_F` is proven (forward direction only)

**Path B: Bundle-Level Coherence**
- Requires: Bundle truth lemma for `BFMCS_Bundle`
- Status: Not implemented
- Infrastructure: `construct_bfmcs_bundle` and `boxClassFamilies_bundle_temporally_coherent` are sorry-free

Both paths require significant additional work beyond the scope of Phase 1.

## Remaining Work

### For Path A (Family-Level)

1. Implement `constrained_predecessor_restricted` in SuccChainFMCS.lean
   - Symmetric to `constrained_successor_restricted`
   - Needs `h_content` (backward analogue of g_content)
   - Needs `f_step_blocking_formulas_restricted` (backward analogue)

2. Build `restricted_backward_chain` with P coherence

3. Combine into `DeferralRestrictedFMCS` with both F and P coherence

4. Wire to `parametric_shifted_truth_lemma`

### For Path B (Bundle-Level)

1. Define TaskModel/TaskFrame for `BFMCS_Bundle`
   - World-states: MCS elements
   - Task relation: Bundle modal coherence

2. Prove bundle truth lemma:
   - Forward: `phi ∈ fam.mcs t → truth_at BundleModel ... phi`
   - Does NOT require family-level temporal coherence

3. Connect to `valid_over` definition

## Target Sorries Status

The 3 target sorries remain:

| Location | Line | Status | Blocker |
|----------|------|--------|---------|
| `dense_completeness_fc` | 120 | Sorry | Needs Int completeness or dense-specific proof |
| `discrete_completeness_fc` | 163 | Sorry | Follows from Int completeness (Int is discrete) |
| `bundle_validity_implies_provability` | 214 | Sorry | Core gap - needs bundle-to-model conversion |

## Files Modified

- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Added box closure lemmas
- `specs/058_wire_completeness_to_frame_conditions/plans/09_deferral-restricted-task.md` - Updated phase markers

## Recommendations

1. **Prioritize Path B**: Bundle-level completeness is closer to working since `construct_bfmcs_bundle` is sorry-free. The gap is the bundle truth lemma.

2. **Consider weaker completeness**: The forward direction of the truth lemma (MCS membership → truth) does NOT require temporal coherence. A "weak completeness" using only forward direction may suffice.

3. **Document infrastructure**: The existing sorry-free infrastructure is substantial but scattered. A consolidated "completeness roadmap" document would help future work.
