# Research Report: Task #67 — Blocker Analysis for bundle_validity_implies_provability

**Task**: 67 — prove_bundle_validity_implies_provability
**Date**: 2026-03-28
**Mode**: Team Research (2 teammates)
**Session**: sess_1774755166_b8a317

## Summary

Team investigation of the blocker found during implementation reveals a **clear resolution path** that was previously overlooked: the restricted chain infrastructure (`build_restricted_tc_family`) already provides sorry-free same-chain F/P witnesses. The Z_chain approach should be bypassed entirely. The remaining gap is constructing a `DeferralRestrictedSerialMCS phi` containing `neg(phi)` from a consistent set, then connecting the restricted truth lemma to the parametric canonical truth lemma.

## Key Findings

### 1. The Z_chain sorry is fundamental and should be bypassed (Teammate A)

The `Z_chain_forward_F` sorry (UltrafilterChain.lean:2485) cannot be filled because `omega_chain_forward` only resolves `F_top` at each step, not arbitrary F-obligations. Fixing this would require a complete Henkin-style fair-scheduling redesign.

**However**, this doesn't matter because the restricted chain infrastructure already solves the problem.

### 2. `build_restricted_tc_family` is sorry-free (Teammate A — HIGH confidence)

The restricted chain infrastructure in SuccChainFMCS.lean provides everything needed:

| Theorem | Line | Status |
|---------|------|--------|
| `restricted_forward_chain_forward_F` | 2887 | **Sorry-free** |
| `restricted_backward_chain_backward_P` | 4238 | **Sorry-free** |
| `build_restricted_tc_family` | 4642 | **Sorry-free** |

`build_restricted_tc_family` packages a `DeferralRestrictedSerialMCS` into a `RestrictedTemporallyCoherentFamily` with:
```
forward_F : ∀ n, ∀ psi, F(psi) ∈ chain(n) → ∃ m > n, psi ∈ chain(m)
backward_P : ∀ n, ∀ psi, P(psi) ∈ chain(n) → ∃ m < n, psi ∈ chain(m)
```

These are **same-chain** witnesses over the full Int-indexed family.

### 3. Task relation encoding confirms same-family requirement (Teammate B — HIGH confidence)

The task relation is `ExistsTask = g_content containment` (ParametricCanonical.lean:84). Every FMCS family already satisfies ExistsTask by construction via `forward_G`. The semantic truth evaluation `truth_at` quantifies over positions of the **same history**, which comes from a **single family**. Therefore:

- Forward_F witnesses from other families cannot help (wrong history)
- Same-family witnesses are mandatory, not a limitation but a fundamental property
- The restricted forward_F provides exactly these same-family witnesses

### 4. Forward-only truth lemma is confirmed impossible (Teammate B)

Since `neg(phi) = phi.imp bot`, forward `imp` requires backward IH, which requires forward_F for G/H cases. No restructuring can avoid this bidirectionality.

### 5. All alternative approaches rejected (Teammate B — HIGH confidence)

| Alternative | Verdict | Reason |
|------------|---------|--------|
| Alternative task relation encoding | Rejected | Cannot make other-family witnesses count for same-history truth |
| Forward-only truth lemma | Rejected | imp uses backward IH |
| Single-family Omega | Rejected | Box backward fails without modal saturation |
| Direct semantic proof | Rejected | Must go through TaskModel over Int |

## Synthesis

### Conflicts Resolved

**None** — both teammates independently converge on the restricted coherence path. Teammate A identifies the sorry-free infrastructure; Teammate B confirms why same-family witnesses are mandatory and rules out alternatives.

### Gaps Identified

**One critical gap**: A **restricted Lindenbaum lemma** is needed:

> Given `neg(phi)` consistent, construct a `DeferralRestrictedSerialMCS phi` containing `neg(phi)`.

This requires:
1. `deferralClosure(phi)` contains `neg(phi)` (by definition — phi is a subformula of itself)
2. A consistent set `{neg(phi)}` extends to a DeferralRestrictedMCS within `deferralClosure(phi)`
3. The resulting DRM is serial (has F_top, P_top)

### Resolution Path (Revised)

The original plan phases need revision. The Z_chain approach is abandoned. New path:

1. **Restricted Lindenbaum Lemma**: Prove that `{neg(phi)}` consistent → `DeferralRestrictedSerialMCS phi` containing `neg(phi)`. Check if `build_deferral_restricted_serial_mcs` or similar exists.

2. **Apply `build_restricted_tc_family`**: Feed the DRM seed into `build_restricted_tc_family` (already sorry-free) to get a `RestrictedTemporallyCoherentFamily` with same-chain F/P.

3. **Connect to `parametric_canonical_truth_lemma`**: Either:
   - (a) Adapt the parametric truth lemma to accept restricted coherence, OR
   - (b) Prove a new `restricted_parametric_truth_lemma` that uses `RestrictedTemporallyCoherentFamily` directly

4. **Wire to completeness**: Use restricted truth lemma to show `neg(phi)` is true in model → contradiction with validity.

### Key Architectural Insight

The **task relation is entirely symbolic** (g_content containment). Within any FMCS family, the task relation is automatically satisfied by `forward_G`. The restricted chain construction works because:
- F-nesting within `deferralClosure(phi)` is bounded
- The fuel-based termination is sound with `B^2` calls
- Same-chain F/P witnesses follow from the construction

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Z-chain construction & restricted infrastructure | Completed | HIGH |
| B | Task relation encoding & alternative approaches | Completed | HIGH |

## References

- `SuccChainFMCS.lean:2887` — `restricted_forward_chain_forward_F` (sorry-free)
- `SuccChainFMCS.lean:4642` — `build_restricted_tc_family` (sorry-free)
- `UltrafilterChain.lean:2485` — `Z_chain_forward_F` (sorry, fundamental gap)
- `ParametricCanonical.lean:84` — `parametric_canonical_task_rel` (ExistsTask)
- `ParametricTruthLemma.lean:320-331` — backward G case needing forward_F
- `FrameConditions/Completeness.lean:176` — the target sorry
