# Research Report: Task #63

**Task**: Prove Box backward via BFMCS modal saturation and eliminate singleton-Omega dead end
**Date**: 2026-03-24
**Mode**: Team Research (2 teammates)
**Session**: sess_1774416291_9b9e37

## Summary

`boxClassFamilies_modal_backward` (UltrafilterChain.lean:1678) is **already proven and sorry-free**. The singleton-Omega sorry in SuccChainTruth.lean:254 is mathematically unprovable and should remain as-is. The path forward is to wire completeness through the BFMCS bundle using `parametric_canonical_truth_lemma`, which handles Box backward via `B.modal_backward`. However, a **critical build failure** in SuccChainFMCS.lean blocks downstream modules, and **temporal coherence** for G/H backward remains an unsolved gap for full completeness.

## Key Findings

### Primary Approach (from Teammate A)

**Structural Difference**: The singleton-Omega model has exactly ONE history, making `psi ∈ MCS t → Box(psi) ∈ MCS t` unprovable (would collapse modality). The BFMCS bundle quantifies over ALL families agreeing on box-content, enabling contrapositive proof via `box_theory_witness_exists`.

**The Sorry Cannot Be "Fixed" Locally**: The sorry at SuccChainTruth.lean:254 is a correct placeholder — the goal is genuinely unprovable in the singleton-Omega architecture. The fix requires architectural change: use BFMCS bundle instead.

**Recommended Architecture**:
1. Define `bfmcs_from_mcs` using `boxClassFamilies` — all 4 modal fields are sorry-free
2. Use `parametric_canonical_truth_lemma` (Box backward case at ParametricTruthLemma.lean:259-269 delegates to `B.modal_backward`)
3. Wire completeness through `parametric_algebraic_representation_relative` instead of `succ_chain_truth_forward`

**IH Dependency**: The Imp forward case requires backward IH on subformulas. This is structurally necessary (not a deficiency) and works in the parametric version because induction provides the full biconditional.

### Blocker Analysis (from Teammate B)

**Sorry-Free Verification**:
| Theorem | Sorry-Free? | Verification Method |
|---------|-------------|---------------------|
| `boxClassFamilies_modal_backward` | YES | lean_verify + manual inspection |
| `box_theory_witness_exists` | YES | lean_verify + manual inspection |
| `construct_bfmcs` | NO (deprecated) | Docstring warning, f_nesting_is_bounded chain |
| `succ_chain_truth_forward` | NO | #print axioms shows sorryAx |

**CRITICAL Build Blocker**: `SuccChainFMCS.lean:2215` references `restricted_bounded_witness`, which was deleted in Task 56. This breaks the build for all modules importing SuccChainFMCS (including SuccChainTruth.lean and SuccChainCompleteness.lean).

**Temporal Coherence Gap**: `boxClassFamilies_temporally_coherent` is `@[deprecated]` because its sorry chain goes through the mathematically false `f_nesting_is_bounded`. The restricted chain path (`DeferralRestrictedSerialMCS`) is the intended fix but requires repairing `restricted_forward_chain_iter_F_witness`.

### Key Insight: Box Backward ≠ Full Completeness

Box backward is **purely modal** — it requires no temporal coherence. The BFMCS path separates concerns:
- Modal (Box/Diamond): Solved by `boxClassFamilies_modal_backward` (sorry-free)
- Temporal (G/H/F/P): Requires temporal coherence (`forward_F`/`backward_P`), still blocked

## Synthesis

### Conflicts Resolved

No conflicts between teammates — findings are complementary:
- Teammate A focused on the wiring architecture (how to use the proven theorem)
- Teammate B focused on dependency verification (confirming it's truly sorry-free and identifying blockers)

### Gaps Identified

1. **Build failure** in SuccChainFMCS.lean must be fixed first (Teammate B finding)
2. **Temporal coherence** for G/H backward remains blocked — `bfmcs_from_mcs` can be constructed without it, but full completeness requires it
3. **Scope question**: Can Task 63 deliver a modal-only completeness theorem, or does it need full temporal coverage?

### Recommendations

**Phase 1: Fix Build Blocker**
- Repair `restricted_forward_chain_iter_F_witness` in SuccChainFMCS.lean:2215
- Replace `restricted_bounded_witness` call with `restricted_forward_chain_F_step_witness` + recursion

**Phase 2: Create BFMCS Construction**
```lean
noncomputable def bfmcs_from_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) : BFMCS Int :=
  { families := boxClassFamilies M h_mcs
    nonempty := boxClassFamilies_nonempty M h_mcs
    modal_forward := boxClassFamilies_modal_forward M h_mcs
    modal_backward := boxClassFamilies_modal_backward M h_mcs
    eval_family := SuccChainFMCS (MCS_to_SerialMCS M h_mcs)
    eval_family_mem := eval_family_mem_boxClassFamilies M h_mcs }
```

**Phase 3: Wire Completeness**
- Use `parametric_canonical_truth_lemma` with `bfmcs_from_mcs` instead of `succ_chain_truth_forward`
- Box backward is sorry-free; G/H backward requires sorry for temporal coherence
- Net effect: reduces sorries by eliminating Box backward, but G/H remain

**Phase 4: Documentation**
- Update SuccChainTruth.lean comments to mark singleton-Omega as dead end
- Update ROADMAP.md to document the BFMCS path
- Mark `succ_chain_truth_forward` as deprecated

**Scope Assessment**:
- **Achievable**: Eliminate Box backward sorry, create `bfmcs_from_mcs`, wire modal completeness
- **Not achievable in this task**: Full sorry-free completeness (blocked by temporal coherence)
- **Estimated effort**: 4-6 hours for phases 1-4

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary wiring approach | completed | high |
| B | Sorry dependency verification | completed | high |

## References

- `UltrafilterChain.lean:1678-1782` — `boxClassFamilies_modal_backward` (proven)
- `UltrafilterChain.lean:903-920` — `box_theory_witness_exists` (proven)
- `ParametricTruthLemma.lean:259-269` — Box backward case using `B.modal_backward`
- `SuccChainTruth.lean:254` — The sorry to eliminate
- `SuccChainFMCS.lean:2215` — Build blocker
- `SuccChainCompleteness.lean:154` — Completeness injection point
- Task 62 reports: singleton-Omega is mathematically impossible
