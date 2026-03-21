# Research Report: Task #852 - Implement CoherentBundle.toBMCS Conversion

**Task**: 852 - implement_coherentbundle_tobmcs
**Date**: 2026-02-03
**Focus**: Verify redundancy with task 851

## Summary

Task 852 requests implementing `CoherentBundle.toBMCS` conversion to provide axiom-free `modal_backward`. However, **task 851 already fully implemented this functionality**. The `toBMCS` conversion is complete at line 580 of `CoherentConstruction.lean` with no sorries. Task 852 is redundant and should be marked as completed with a note that it was subsumed by task 851.

## Findings

### toBMCS Implementation Already Exists

The `CoherentBundle.toBMCS` function is fully implemented in `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` at lines 580-612:

```lean
noncomputable def CoherentBundle.toBMCS (B : CoherentBundle D)
    (h_sat : B.isSaturated) : BMCS D where
  families := B.families
  nonempty := B.nonempty
  modal_forward := by
    intro fam h_fam phi t h_box fam' h_fam'
    exact B.chi_in_all_families phi fam h_fam t h_box fam' h_fam' t
  modal_backward := by
    intro fam h_fam phi t h_all
    by_contra h_not_box
    have h_mcs := fam.is_mcs t
    have h_neg_box : Formula.neg (Formula.box phi) ∈ fam.mcs t := by
      rcases set_mcs_negation_complete h_mcs (Formula.box phi) with h_box | h_neg
      · exact absurd h_box h_not_box
      · exact h_neg
    rcases h_sat phi fam h_fam t h_neg_box with ⟨fam', h_fam', h_neg_phi⟩
    have h_phi := h_all fam' h_fam'
    exact set_consistent_not_both (fam'.is_mcs t).1 phi h_phi h_neg_phi
  eval_family := B.eval_family
  eval_family_mem := B.eval_family_mem
```

### Proof Strategy Matches Task 852 Description

Task 852 describes the approach: "Uses contraposition: if phi in all families but Box phi not in fam.mcs, then Diamond(neg phi) in fam.mcs, so exists witness with neg phi, contradicting phi in all families."

The implemented proof follows exactly this approach:
1. Assume `Box phi` not in `fam.mcs t` (proof by contradiction)
2. By MCS negation completeness, `neg(Box phi)` in `fam.mcs t`
3. By saturation, exists `fam'` with `neg phi` in `fam'.mcs t`
4. But universal hypothesis says `phi` in `fam'.mcs t`
5. Contradiction via MCS consistency

### No Sorries in Module

Verified via grep: there are **zero sorries** in `CoherentConstruction.lean`. The entire toBMCS conversion is fully proven.

### Supporting Proofs Also Complete

The task 851 implementation also includes all supporting infrastructure:

- `modal_forward`: Proven via `chi_in_all_families` (mutual coherence)
- `modal_backward`: Proven by contraposition (as described above)
- `toBMCS_eval_family`: Preservation lemma
- `toBMCS_families`: Preservation lemma

### Task 851 Implementation Summary Confirms This

From `specs/851_define_coherentbundle_structure/summaries/implementation-summary-20260203.md`:

> **BMCS Conversion (Phase 4: toBMCS)**
> - `CoherentBundle.toBMCS`: **FULLY PROVEN** (no sorries!) conversion from saturated CoherentBundle to BMCS
>   - `modal_forward`: Proven via `chi_in_all_families` (mutual coherence)
>   - `modal_backward`: Proven by contraposition using MCS completeness and saturation

## Recommendations

1. **Mark task 852 as [COMPLETED]** with note that it was subsumed by task 851
2. **Update dependency graph**: Task 853 (Construct CoherentBundle from consistent context) previously depended on both 851 and 852; it now only needs to depend on 851
3. **No additional implementation work needed** for this task

## Why Task 852 Was Subsumed

Task 851's plan originally described toBMCS as Phase 4 work:

> **Phase 4: CoherentBundle to BMCS Conversion**
> **Goal**: Define conversion from saturated CoherentBundle to BMCS
> **Tasks**:
> - Define `CoherentBundle.toBMCS` function with saturation hypothesis
> - Prove `modal_forward` field: From mutual coherence + T-axiom
> - Prove `modal_backward` field: From saturation hypothesis via contraposition

This was originally scoped as potentially requiring a sorry (from the plan: "If sorry needed, document as technical debt"). However, the implementation succeeded in proving both modal_forward and modal_backward completely, eliminating the need for task 852.

## References

- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` (lines 580-612)
- `specs/851_define_coherentbundle_structure/plans/implementation-001.md` (Phase 4)
- `specs/851_define_coherentbundle_structure/summaries/implementation-summary-20260203.md`

## Next Steps

No implementation work required. Recommend closing task 852 as subsumed by task 851, and updating task 853's dependencies accordingly.
