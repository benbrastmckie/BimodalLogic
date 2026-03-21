# Implementation Plan: Task #916

- **Task**: 916 - Implement F/P Witness Obligation Tracking
- **Status**: [BLOCKED]
- **Effort**: 55-75 hours (WitnessGraph completion) OR 2-3 hours (sorry debt)
- **Dependencies**: None
- **Research Inputs**: research-014.md (team synthesis on path forward)
- **Artifacts**: plans/implementation-010.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean
- **Lean Intent**: true
- **Version**: 010 (revised from 009 based on research-014 and actual build status)

## Overview

This plan revises implementation-009 based on:
1. **Actual build status**: 5 errors, 4 sorries (not "0 errors, 0 sorries" as summary claimed)
2. **Research-014 synthesis**: 40-50% cumulative success probability for WitnessGraph
3. **Cost-benefit analysis**: 20-25x effort ratio (55-75h vs 2-3h for sorry debt)

### Key Realization

The Phase 3A "completion" was inaccurate. Current WitnessGraph.lean has:
- 5 build errors (unknown identifiers: `set_mcs_neg_or`, `GContent_subset_implies_HContent_reverse`)
- 4 sorries at lines 3025, 3033, 3104
- Warnings about unused simp arguments

This is the same fundamental obstruction identified in 14 prior research reports: **Lindenbaum opacity** prevents propagating witness obligations through chain construction.

### Current State (Actual)

| Metric | Value |
|--------|-------|
| Lines | ~3100 |
| Build errors | **5** |
| Sorries | **4** |
| Mathematical approach | Correct (but incomplete) |

### Error Inventory

| Error | Lines | Identifier Missing |
|-------|-------|-------------------|
| Unknown identifier | 2956, 2985 | `set_mcs_neg_or` |
| Unknown identifier | 3073, 3086 | `GContent_subset_implies_HContent_reverse` |
| sorry | 3025, 3033 | forward_F, backward_P |
| sorry | 3104 (×2) | forward_G, backward_H |

## Decision Point

**This task requires a user decision before proceeding.**

### Option A: Time-Boxed WitnessGraph Completion

**Effort**: 55-75 hours (expected)
**Success probability**: 40-50%
**Risk**: Context exhaustion, mathematical dead-ends
**Value**: Closes textbook theorem; no mathematical novelty

**Phases**:
1. Fix 5 build errors (2-4 hours)
2. Close 4 sorries or prove they require omega² (40-60 hours)
3. Integration with DovetailingChain.lean (5-10 hours)

**Hard stop**: Abort after 30 hours if no path to completion emerges.

### Option B: Accept Sorry Debt (Recommended)

**Effort**: 2-3 hours
**Success probability**: 100%
**Risk**: 0%
**Value**: BMCS completeness unaffected; standard practice for formalization gaps

**Phases**:
1. Document 2 sorries in DovetailingChain.lean per proof-debt-policy.md
2. Reference 14 research reports characterizing the obstruction
3. Mark task as completed with proof debt documentation

### Recommendation

**Accept Option B (sorry debt)** based on cost-benefit analysis:
- 20-25x more effort to close vs document
- BMCS completeness proof (main contribution) is already sorry-free
- The sorries are in the bridge from BFMCS to standard completeness
- WitnessGraph.lean (3100+ lines) serves as comprehensive documentation of the obstruction

---

## Implementation Phases (Option A Path)

### Phase 3B: Fix Remaining Build Errors [NOT STARTED]

- **Dependencies**: None
- **Goal**: Make WitnessGraph.lean build with 0 errors
- **Estimated effort**: 2-4 hours

**Error 1: `set_mcs_neg_or` (lines 2956, 2985)**
- This lemma is referenced but not defined
- Search codebase for existing lemma or define it:
```lean
lemma set_mcs_neg_or (M : Set Formula) (hM : SetMaximalConsistent M) (phi psi : Formula) :
    ¬phi ∈ M → ((.or phi psi) ∈ M ↔ psi ∈ M) := by
  intro hnphi
  constructor
  · intro hor
    have : phi ∈ M ∨ psi ∈ M := mcs_or_iff.mp hor
    rcases this with h | h
    · exact absurd h hnphi
    · exact h
  · intro hpsi
    exact mcs_or_iff.mpr (Or.inr hpsi)
```

**Error 2: `GContent_subset_implies_HContent_reverse` (lines 3073, 3086)**
- This is a speculative lemma (GContent propagation implies HContent reverses)
- Likely FALSE - the forward/backward asymmetry is fundamental
- Replace with direct proof or sorry

**Verification**:
```bash
lake build Bimodal.Metalogic.Bundle.WitnessGraph
# Target: 0 errors (sorries acceptable)
```

---

### Phase 5: Global Temporal Coherence [BLOCKED]

- **Dependencies**: Phase 3B
- **Goal**: Close 4 sorries for temporal coherence
- **Estimated effort**: 40-60 hours (or IMPOSSIBLE without omega²)

**Mathematical Obstruction** (documented in research-003 through research-014):

The fundamental problem is **Lindenbaum opacity**: when extending a seed `{psi} ∪ GContent(M)` to an MCS via Lindenbaum's lemma, we cannot control which F-formulas appear in the result. This means:
- We prove `psi ∈ witness` but cannot prove `F(psi') ∈ witness` for nested obligations
- Each F-witness can create new F-obligations requiring their own witnesses
- This requires omega² (or transfinite) construction, not a linear chain

**Status**: These 4 sorries may be PROVABLY IMPOSSIBLE to close without architectural redesign.

**Sorries**:
- [ ] `enrichedChainBFMCS.forward_F` - sorry (omega² required)
- [ ] `enrichedChainBFMCS.backward_P` - sorry (omega² required)
- [ ] `enrichedChainBFMCS.forward_G` - sorry (cross-sign propagation)
- [ ] `enrichedChainBFMCS.backward_H` - sorry (cross-sign propagation)

---

### Phase 6: Integration [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Replace sorries in DovetailingChain.lean
- **Estimated effort**: 5-10 hours (if Phase 5 succeeds)

**Tasks**:
- [ ] Import WitnessGraph.lean into DovetailingChain.lean
- [ ] Wire `witnessGraphBFMCS_forward_F` to close sorry at line 1754
- [ ] Wire `witnessGraphBFMCS_backward_P` to close sorry at line 1761

---

## Implementation Phases (Option B Path)

### Phase D1: Document Sorry Debt [NOT STARTED]

- **Dependencies**: None
- **Goal**: Document 2 sorries per proof-debt-policy.md
- **Estimated effort**: 2-3 hours

**Tasks**:
1. Update DovetailingChain.lean with structured sorry documentation:
   ```lean
   /-- forward_F requires omega-squared construction.
       See: specs/916_implement_fp_witness_obligation_tracking/reports/research-014.md
       Obstruction: Lindenbaum opacity prevents witness obligation propagation.
       Confidence: Mathematical result is textbook standard (99%).
       Status: Formalization gap, not mathematical doubt. -/
   sorry
   ```

2. Create proof debt entry in project documentation
3. Reference WitnessGraph.lean as partial resolution (3100+ lines of exploration)

**Verification**:
- Documentation complete and accurate
- References all 14 research reports
- Follows proof-debt-policy.md format

---

## Summary

| Aspect | Option A (WitnessGraph) | Option B (Sorry Debt) |
|--------|------------------------|----------------------|
| Effort | 55-75 hours | 2-3 hours |
| Success probability | 40-50% | 100% |
| Risk | High (context exhaustion, dead-ends) | None |
| Value | Textbook theorem (no novelty) | Main contribution intact |
| BMCS completeness | Unaffected | Unaffected |

**Recommendation**: Option B - the cost-benefit analysis strongly favors sorry debt acceptance.

## Success Criteria (Option B)

- [x] Decision point reached with user
- [ ] Sorries documented per proof-debt-policy.md
- [ ] WitnessGraph.lean referenced as exploration artifact
- [ ] Task marked completed with proof debt note

## Success Criteria (Option A - if chosen)

- [ ] WitnessGraph.lean: 0 errors, 0 sorries
- [ ] DovetailingChain.lean forward_F/backward_P: 0 sorries
- [ ] `lake build` succeeds
- [ ] No new axioms introduced

## Historical Progress

### Phases 1-2: [COMPLETED]
- WitnessGraph structure and construction (sess_1771892810_8cdc73)
- ~1090 lines, 0 sorries, 0 errors

### Phases 3-4: [PARTIAL]
- Property proofs and Int embedding attempted
- ~2000+ additional lines
- Blocked by Lindenbaum opacity obstruction

### Phase 5: [BLOCKED]
- Mathematical obstruction confirmed by 14 research reports
- omega² construction required (55-75 hours)

---

## References

### Research Reports (14 total)
- research-001: Initial 4-sorry analysis
- research-003: Team consensus on omega² approach
- research-007: Derivation surgery gap identified
- research-014: **Synthesis recommending sorry debt**

### Key Files
- `DovetailingChain.lean`: 2 sorries (lines 1754, 1761)
- `WitnessGraph.lean`: 5 errors, 4 sorries (current)
- `forward_temporal_witness_seed_consistent`: DovetailingChain.lean (proven)
