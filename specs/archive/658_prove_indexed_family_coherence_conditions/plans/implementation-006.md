# Implementation Plan: Task #658 (Revised v6)

- **Task**: 658 - Prove indexed family coherence conditions
- **Version**: 006 (Post-Task 697 Revision)
- **Status**: [PLANNED]
- **Effort**: 45 minutes - 1 hour
- **Priority**: Medium
- **Dependencies**: Task 681 (COMPLETED), Task 697 (COMPLETED)
- **Research Inputs**:
  - specs/658_prove_indexed_family_coherence_conditions/reports/research-004.md
  - specs/681_redesign_construct_indexed_family_coherent_approach/plans/implementation-006.md
  - specs/697_fix_universalcanonicalmodel_compilation_error/summaries/implementation-summary-20260129.md
- **Artifacts**: plans/implementation-006.md (this file)
- **Type**: lean
- **Lean Intent**: true

## Executive Summary

**Context Change**: Task 697 is now COMPLETED. It fixed the reflexive/strict semantics mismatch in TruthLemma.lean, which directly uses the coherence conditions from IndexedMCSFamily.

### What Task 697 Revealed

Task 697's fix shows that:
1. `forward_G` and `backward_H` ARE actively used in TruthLemma.lean (lines 407-436)
2. The Truth Lemma uses `family.forward_G` and `family.backward_H` from an `IndexedMCSFamily` parameter
3. The fix added case splits that use `family.forward_G t s psi h_t_lt h_mem` and `family.backward_H t s psi h_s_lt h_mem`

This confirms that **Option 2B (Replacement)** or **Option 2C (Wrapper)** is required - we cannot simply remove `construct_indexed_family` because downstream code depends on the `IndexedMCSFamily` interface.

### Task Clarification

Looking at the codebase carefully:
- `IndexedMCSFamily` is a **structure** defining the interface (4 coherence conditions)
- `construct_indexed_family` is a **function** that constructs an IndexedMCSFamily (with sorries)
- `construct_coherent_family` is a **function** that constructs a CoherentIndexedFamily (proven cases)
- `CoherentIndexedFamily.toIndexedMCSFamily` converts between them

The sorries in `construct_indexed_family` are **in the construction**, not in the interface. TruthLemma uses the interface, not a specific construction function.

### Key Insight

The question is: **What construction function does the representation theorem actually use?**

If it uses `construct_indexed_family` (with sorries) → We need to switch it to use `construct_coherent_family`
If it uses something else entirely → We need to understand the actual dependency chain

## Goals & Non-Goals

**Goals**:
- Trace the actual dependency from `representation_theorem` back to see which construction function is used
- If `construct_indexed_family` is used: Replace with `construct_coherent_family`
- If another path exists: Document and verify it's sorry-free for critical cases
- Ensure `lake build` passes

**Non-Goals**:
- Proving backward direction of Truth Lemma
- Proving cross-origin coherence cases
- Modifying TruthLemma.lean (Task 697 already fixed it)

## Implementation Phases

### Phase 1: Trace Dependency Chain [NOT STARTED]

**Goal**: Understand exactly how `IndexedMCSFamily` is constructed in the representation theorem.

**Tasks**:
- [ ] Read `UniversalCanonicalModel.lean` to find `representation_theorem`
- [ ] Trace what `IndexedMCSFamily` instance is passed to `truth_lemma_forward`
- [ ] Determine if `construct_indexed_family` or `construct_coherent_family` is used

**Expected Findings** (from Task 681 documentation):
The representation theorem should use the coherent construction path since Task 681 created it specifically for this purpose.

**Timing**: 15 minutes

---

### Phase 2: Verify/Update Construction Path [NOT STARTED]

**Goal**: Ensure the representation theorem uses the sorry-free coherent construction.

**Possible Actions**:

**If using `construct_indexed_family` (with sorries)**:
- Replace usage with `construct_coherent_family(...).toIndexedMCSFamily`
- The sorries in `construct_indexed_family` become unreachable

**If using `construct_coherent_family` (expected)**:
- Verify this is actually the case
- Document that Task 658's original goal is achieved via Task 681
- Mark `construct_indexed_family` as truly deprecated (not called)

**If using something else**:
- Investigate and document the actual construction path

**Timing**: 20 minutes

---

### Phase 3: Cleanup Superseded Code [NOT STARTED]

**Goal**: Remove or clearly deprecate `construct_indexed_family` since it's superseded.

**Tasks**:
- [ ] If not used anywhere: Remove the function entirely
- [ ] If used but shouldn't be: Update callers to use `construct_coherent_family`
- [ ] Update IndexedMCSFamily.lean module docstring
- [ ] Verify `lake build` passes

**Timing**: 15 minutes

---

### Phase 4: Final Verification [NOT STARTED]

**Goal**: Confirm the completeness proof chain is sorry-free for critical cases.

**Tasks**:
- [ ] Run `lake build` to verify no errors
- [ ] Verify that `representation_theorem` compiles without errors
- [ ] Document any remaining sorries and confirm they're non-critical

**Timing**: 10 minutes

---

## Previous Plan Analysis (v5)

**What Changed from v5**:
- v5 was written before Task 697 completed
- v5 assumed we needed to analyze dependencies but didn't know about TruthLemma.lean usage
- Task 697 showed that TruthLemma DOES use the coherence conditions
- v6 focuses on tracing the actual construction function used by representation_theorem

**What v6 Adds**:
- Task 697 context and its implications
- Clarification of interface vs construction function distinction
- Focused dependency trace from representation_theorem
- Simpler phase structure (trace, verify, cleanup, verify)

## Key References

From Task 697 implementation-summary:
> The fix leverages the T-axiom closure lemmas that were already available in IndexedMCSFamily.lean:
> - `mcs_closed_temp_t_past`: Shows `Hφ ∈ MCS` implies `φ ∈ MCS`
> - `mcs_closed_temp_t_future`: Shows `Gφ ∈ MCS` implies `φ ∈ MCS`

This confirms the T-axiom closure lemmas are working correctly, and the issue is about which construction function provides the `IndexedMCSFamily` to TruthLemma.

From Task 681 implementation-006.md:
> **The completeness proof only uses:**
> - `forward_G` Case 1 (both >= 0): PROVEN via `mcs_forward_chain_coherent`
> - `backward_H` Case 4 (both < 0): PROVEN via `mcs_backward_chain_coherent`

This confirms the critical cases are proven in CoherentConstruction.

## Success Criteria

1. ✅ Clear documentation of which construction function `representation_theorem` uses
2. ✅ If sorried path exists: Updated to use coherent construction
3. ✅ `construct_indexed_family` either removed or clearly marked deprecated
4. ✅ `lake build` passes with no new errors
5. ✅ Only expected warnings (backward Truth Lemma sorries, non-critical coherence cases)

## Timeline

| Phase | Effort | Cumulative |
|-------|--------|------------|
| Phase 1 (Trace) | 15 min | 15 min |
| Phase 2 (Verify/Update) | 20 min | 35 min |
| Phase 3 (Cleanup) | 15 min | 50 min |
| Phase 4 (Final) | 10 min | 60 min |
| **Total** | **~1 hour** | |

## References

- Task 681 summary: specs/681_redesign_construct_indexed_family_coherent_approach/summaries/implementation-summary-20260128-v4.md
- Task 697 summary: specs/697_fix_universalcanonicalmodel_compilation_error/summaries/implementation-summary-20260129.md
- Representation README: Theories/Bimodal/Metalogic/Representation/README.md
- CoherentConstruction: Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean
- TruthLemma: Theories/Bimodal/Metalogic/Representation/TruthLemma.lean
