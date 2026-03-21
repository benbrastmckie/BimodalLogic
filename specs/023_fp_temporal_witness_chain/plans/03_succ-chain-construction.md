# Implementation Plan: Task #23 (Revision 3)

- **Task**: 23 - F/P Temporal Witness Chain Construction
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours
- **Dependencies**: None (infrastructure already exists)
- **Research Inputs**: specs/023_fp_temporal_witness_chain/reports/08_team-research.md
- **Artifacts**: plans/03_succ-chain-construction.md (this file)
- **Standards**: plan-format.md, status-markers.md
- **Type**: lean4
- **Lean Intent**: false

## Revision Notes

**Previous Plans**:
- `01_succ-based-fp-witnesses.md`: Proposed analyzing 3 axioms
- `02_no-axioms-fp-witnesses.md`: Path A/B approach with NO AXIOMS constraint; concluded with CanonicalFMCS reroute

**ARCHITECTURE CORRECTION** (from report 08_team-research.md):
Previous research was fundamentally confused about type architecture:
- **WRONG**: CanonicalMCS needs AddCommGroup (it doesn't - it's WorldState, not D)
- **CORRECT**: TaskFrame uses D=Int (has AddCommGroup), WorldState=CanonicalMCS (no algebra needed)

**New Finding**: The Succ-based approach works because:
1. Succ-constrained construction (NOT generic Lindenbaum) prevents F-obligation killing
2. `bounded_witness` theorem already proven in CanonicalTaskRelation.lean
3. Infrastructure exists - this is integration work, not new research

## Overview

This plan creates `SuccChainFMCS.lean` using the existing Succ infrastructure to construct FMCS chains that satisfy F/P temporal witnesses BY CONSTRUCTION (not by axiom).

**Key Insight**: Generic Lindenbaum extension CAN kill F-obligations arbitrarily. Succ-constrained construction CANNOT because:
- Deferral seed includes `φ ∨ F(φ)` for each `F(φ)`
- F-step is enforced by construction, not assumed
- `bounded_witness` provides finite witness bounds

## Goals & Non-Goals

**Goals**:
- Eliminate 4 IntBFMCS sorries via Succ-chain construction
- Create `SuccChainFMCS.lean` using existing infrastructure
- Wire new construction to completeness path
- Optionally prove 3 SuccExistence axioms (if straightforward)

**Non-Goals**:
- Modifying CanonicalFMCS (already sorry-free)
- Creating new mathematical infrastructure (exists already)
- Forcing axiom proofs if genuinely hard

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Succ chain construction doesn't compose | H | L | bounded_witness already proven; composition is mechanical |
| forward_F/backward_P proofs harder than expected | M | M | Use bounded_witness theorem directly |
| 3 axioms genuinely unprovable | M | M | Accept 3 axioms instead of 4 sorries (net improvement) |
| DirectMultiFamilyBFMCS requires deep changes | M | L | Incremental refactor, keep IntBFMCS as fallback |

## Implementation Phases

### Phase 1: Create SuccChainFMCS.lean [COMPLETED]

**Goal**: Define FMCS Int using Succ-chain construction.

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- [ ] Define chain construction:
  - At t=0: root MCS
  - At t+1: Apply `successor_from_deferral_seed` (from SuccExistence.lean)
  - At t-1: Apply `predecessor_from_deferral_seed`
- [ ] Define `SuccChainFMCS : FMCS Int` structure
- [ ] Import required modules: SuccRelation, SuccExistence, CanonicalTaskRelation

**Timing**: 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` - Succ definition
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - successor/predecessor existence
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - bounded_witness

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccChainFMCS` compiles

---

### Phase 2: Prove Temporal Coherence [PARTIAL]

**Goal**: Prove forward_G, backward_H, forward_F, backward_P for SuccChainFMCS.

**Tasks**:
- [ ] Prove `forward_G`: From Succ G-persistence (`g_content(u) ⊆ v`)
  - Should be direct from Succ definition
- [ ] Prove `backward_H`: Symmetric to forward_G
- [ ] Prove `forward_F`: Using bounded_witness theorem
  - Key theorem: If `F^n(φ) ∈ u` but `F^{n+1}(φ) ∉ u`, then φ is witnessed within n Succ steps
  - Connect bounded_witness to chain construction
- [ ] Prove `backward_P`: Symmetric to forward_F

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- All 4 temporal coherence properties proven (no sorries in SuccChainFMCS)
- `lake build` succeeds

---

### Phase 3: Wire to Completeness [BLOCKED]

**Goal**: Update completeness path to use SuccChainFMCS.

**Tasks**:
- [ ] Update `DirectMultiFamilyBFMCS.lean` to use SuccChainFMCS
- [ ] Update `construct_bfmcs_from_mcs_Int` to new construction
- [ ] Mark IntBFMCS forward_F/backward_P as deprecated or remove
- [ ] Verify algebraic completeness path still works

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DirectMultiFamilyBFMCS.lean`
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` (deprecation/removal)

**Verification**:
- 4 IntBFMCS sorries eliminated (via SuccChainFMCS substitution)
- `lake build` succeeds on full project
- No regression in algebraic completeness

---

### Phase 4: Axiom Assessment [NOT STARTED]

**Goal**: Assess and optionally prove SuccExistence axioms.

The 3 axioms in SuccExistence.lean:
1. `successor_deferral_seed_consistent_axiom`
2. `predecessor_deferral_seed_consistent_axiom`
3. `predecessor_f_step_axiom`

**Tasks**:
- [ ] Attempt proof of each axiom (30 min each, hard timeout)
- [ ] For provable axioms: convert to theorems
- [ ] For unprovable axioms: document why, accept as semantic axioms
- [ ] Update implementation summary with axiom status

**Timing**: 1.5 hours (30 min × 3 axioms)

**Decision Logic**:
- **Net improvement calculation**: Start with 4 sorries + 1 axiom in IntBFMCS
- If we eliminate 4 sorries and keep 3 axioms: still net improvement (4+1 → 3)
- If we prove any axioms: even better

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- Axiom status documented
- `lake build` succeeds

## Files Summary

| File | Status | Action |
|------|--------|--------|
| `SuccRelation.lean` | EXISTS | Reference only |
| `CanonicalTaskRelation.lean` | EXISTS | Reference (bounded_witness) |
| `SuccExistence.lean` | EXISTS (3 axioms) | Optionally convert axioms to theorems |
| `SuccChainFMCS.lean` | NEW | Create FMCS Int via Succ chains |
| `IntBFMCS.lean` | EXISTS (4 sorries) | Deprecate or delete F/P |
| `DirectMultiFamilyBFMCS.lean` | EXISTS | Update to use SuccChain |

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No sorries in SuccChainFMCS.lean
- [ ] IntBFMCS forward_F, backward_P sorries eliminated
- [ ] Algebraic completeness path still works
- [ ] Net axiom/sorry count improved

## Artifacts & Outputs

- `specs/023_fp_temporal_witness_chain/plans/03_succ-chain-construction.md` - this plan
- `specs/023_fp_temporal_witness_chain/summaries/02_succ-chain-summary.md` - implementation summary (created in Phase 4)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - new file
- Modified `Theories/Bimodal/Metalogic/Algebraic/DirectMultiFamilyBFMCS.lean`
- Deprecated/removed `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` F/P sorries

## Rollback/Contingency

**If Phase 2 blocks** (temporal coherence proofs harder than expected):
1. Examine bounded_witness theorem more closely
2. Consider alternative proof strategy
3. Escalate if fundamental issue discovered

**If Phase 3 breaks algebraic path**:
1. Keep IntBFMCS as fallback
2. Create adapter layer between SuccChainFMCS and existing infrastructure
3. Gradual migration instead of replacement
