# Implementation Plan: Task #15 (v3) - Domain-Correct Completion

- **Task**: 15 - discrete_representation_theorem_axiom_removal
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Dependencies**: Plan v2 Phases 1-3 completed (modal_backward sorry-free at MCS level)
- **Research Inputs**:
  - specs/015_discrete_representation_theorem_axiom_removal/reports/04_domain-semantics-research.md
  - specs/015_discrete_representation_theorem_axiom_removal/reports/03_team-research-synthesis.md
- **Artifacts**: plans/03_domain-correct-plan.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Plan v3 completes task 15 by wiring the MCS-level modal saturation infrastructure to the Int-indexed BFMCS structure required by `DiscreteInstantiation.lean`. The key insight from research report 04 is the domain separation:

- **CanonicalMCS** = world STATE space (MCS), NOT time index domain
- **Int** = time INDEX domain with AddCommGroup structure
- **BFMCS D** = families indexed by D (temporal domain)

Plan v2 successfully established `discreteMCS_modal_backward` (sorry-free) at the MCS level. This plan bridges that infrastructure to the `BFMCS Int` interface and cleans up deprecated code.

### Research Integration

Key findings from domain semantics research (report 04):
- `discreteMCS_modal_backward` is sorry-free and works at MCS level
- The gap is connecting MCS-level saturation to `BFMCS Int` structure
- Several files have misleading comments conflating W (world states) with D (durations)
- Boneyard candidates: SuccChainBFMCS.lean, deprecated DurationTransfer functions, singleFamilyBFMCS_Int

### Supersedes

**Plan v1** (`01_discrete-rep-plan.md`) - ABANDONED: Singleton BFMCS impossible
**Plan v2** (`02_multi-bfmcs-plan.md`) - PARTIAL: Phases 1-3 complete, Phase 4 blocked by domain confusion

## Goals & Non-Goals

**Goals**:
- Move deprecated files to Boneyard directory
- Fix misleading comments about domain semantics
- Bridge MCS-level `discreteMCS_modal_backward` to `BFMCS Int` interface
- Complete `discrete_representation_unconditional` with correct domain separation
- Ensure `lake build` succeeds with reduced sorry count

**Non-Goals**:
- Full F/P witness elimination (dovetailing infrastructure needed)
- Changing parametric framework fundamentally
- Dense representation (separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BFMCS Int interface incompatible with MCS-level proofs | High | Medium | Use parametric approach with CanonicalMCS for modal, Int for temporal |
| Boneyard move breaks downstream imports | Medium | Low | Verify no active imports before moving |
| Comment fixes introduce factual errors | Low | Low | Cross-reference with research report 04 |
| Domain separation requires significant refactoring | Medium | Medium | Accept temporary bridging layer |

## Implementation Phases

### Phase 1: Boneyard Deprecated Files [COMPLETED]

**Goal**: Move deprecated singleton BFMCS files to Boneyard to prevent accidental usage.

**Tasks**:
- [ ] Create `Theories/Boneyard/` directory if needed
- [ ] Move `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean` to `Theories/Boneyard/SuccChainBFMCS.lean`
- [ ] Move `Theories/Bimodal/Metalogic/Bundle/IntFMCSTransfer.lean` to `Theories/Boneyard/IntFMCSTransfer.lean`
- [ ] Update `Theories/Bimodal.lean` to remove imports of moved files
- [ ] Verify no active imports depend on moved files via grep
- [ ] Add README.md to Boneyard explaining purpose

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Boneyard/` - Create directory
- `Theories/Bimodal.lean` - Remove imports
- `Theories/Boneyard/README.md` - Create explanation file

**Verification**:
- `lake build` succeeds without moved files
- No grep hits for `import.*SuccChainBFMCS` or `import.*IntFMCSTransfer` in active code

---

### Phase 2: Fix Misleading Comments [COMPLETED]

**Goal**: Correct documentation that conflates world states (W) with time indices (D).

**Tasks**:
- [ ] Fix `ModallyCoherentBFMCS.lean` lines 39-52: Clarify that CanonicalMCS-as-D is proof technique, not semantic model
- [ ] Add clarifying comment to `FMCSDef.lean` lines 20-31: Explicit "D != CanonicalMCS for semantic models"
- [ ] Review `CanonicalDomain.lean` deprecated functions: Ensure W=D conflation is documented as deprecated error
- [ ] Add domain semantics summary to module docstring of `ModallyCoherentBFMCS.lean`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ModallyCoherentBFMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`

**Verification**:
- Comments accurately describe domain separation
- No new `sorry` introduced
- `lake build` succeeds

---

### Phase 3: Bridge MCS Saturation to BFMCS Int [COMPLETED]

**Goal**: Create infrastructure to use MCS-level saturation proofs with Int-indexed families.

**Strategy**: The `discreteMCS_modal_backward` theorem works at MCS level. To use it with `BFMCS Int`, we need a bridge that:
1. Takes an Int-indexed family
2. Extracts the MCS at a given time t
3. Verifies that MCS is in `discreteClosedMCS M0`
4. Applies `discreteMCS_modal_backward`

**Tasks**:
- [ ] Define `ClosedFlagFMCS_Int`: Int-indexed FMCS where each `mcs t` is in discreteClosedMCS
- [ ] Prove that for any `fam : ClosedFlagFMCS_Int M0`, `modal_backward` holds via `discreteMCS_modal_backward`
- [ ] Define `ClosedFlagBFMCS_Int M0`: BFMCS Int built from ClosedFlagFMCS families
- [ ] Prove `ClosedFlagBFMCS_Int_modal_coherent`: modal_forward/backward for the bundle
- [ ] Document remaining F/P temporal coherence sorries (require dovetailing)

**Timing**: 1.5 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/ClosedFlagIntBFMCS.lean` - New file
- `Theories/Bimodal.lean` - Add import

**Verification**:
- `ClosedFlagBFMCS_Int M0 : BFMCS Int` type checks
- `modal_backward` has NO sorry (uses `discreteMCS_modal_backward`)
- `lake build Bimodal.Metalogic.Bundle.ClosedFlagIntBFMCS` succeeds

---

### Phase 4: Wire to DiscreteInstantiation [COMPLETED]

**Goal**: Restore `discrete_representation_unconditional` using domain-correct construction.

**Tasks**:
- [ ] Import `ClosedFlagIntBFMCS` in `DiscreteInstantiation.lean`
- [ ] Define `construct_bfmcs_impl_v3` using `ClosedFlagBFMCS_Int`
- [ ] Verify `construct_bfmcs_impl_v3` satisfies the `construct_bfmcs` signature
- [ ] Restore `discrete_representation_unconditional` theorem
- [ ] Document remaining sorries in theorem doc comment:
  - F/P temporal coherence (dovetailing gap)
  - Any other infrastructure sorries
- [ ] Verify `#print axioms` output

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean`

**Verification**:
- `discrete_representation_unconditional` compiles
- `#print axioms discrete_representation_unconditional` shows NO modal_backward sorry
- Documentation accurately lists remaining sorries

---

### Phase 5: Verification and Cleanup [COMPLETED]

**Goal**: Final verification, documentation update, and cleanup.

**Tasks**:
- [ ] Run `lake build` for entire project
- [ ] Verify `#print axioms` for key theorems
- [ ] Update `ModallyCoherentBFMCS.lean` docstrings with final status
- [ ] Update `DiscreteInstantiation.lean` summary section
- [ ] Create implementation summary at `specs/015_discrete_representation_theorem_axiom_removal/summaries/01_domain-correct-summary.md`
- [ ] Update ROAD_MAP.md with completion notes

**Timing**: 30 minutes

**Files to modify**:
- Various Lean files (docstrings)
- `specs/015_discrete_representation_theorem_axiom_removal/summaries/01_domain-correct-summary.md` (create)
- `ROAD_MAP.md`

**Verification**:
- `lake build` succeeds with no new errors
- Documentation accurately reflects implementation
- Summary captures lessons learned

---

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] `discrete_representation_conditional` still compiles (unchanged)
- [ ] `discrete_representation_unconditional` compiles with new construction
- [ ] `#print axioms discrete_representation_unconditional` shows:
  - NO `modal_backward` sorry (primary goal)
  - F/P sorries documented and acceptable
- [ ] No active code imports Boneyard files
- [ ] Comments accurately describe domain semantics

## Artifacts & Outputs

- `Theories/Boneyard/SuccChainBFMCS.lean` (moved from Bundle/)
- `Theories/Boneyard/IntFMCSTransfer.lean` (moved from Bundle/)
- `Theories/Boneyard/README.md` (new)
- `Theories/Bimodal/Metalogic/Bundle/ClosedFlagIntBFMCS.lean` (new)
- `Theories/Bimodal/Metalogic/Bundle/ModallyCoherentBFMCS.lean` (modified - comments)
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` (modified - v3 construction)
- `specs/015_discrete_representation_theorem_axiom_removal/summaries/01_domain-correct-summary.md` (new)
- `specs/015_discrete_representation_theorem_axiom_removal/plans/03_domain-correct-plan.md` (this file)

## Rollback/Contingency

If Phase 3 (bridge construction) fails:
1. Keep `discrete_representation_conditional` as primary result
2. Document the domain separation issue for future work
3. Create follow-up task for proper Int-indexed bundle construction

If Phase 4 (wiring) introduces new sorries:
1. Document the specific sorries and their causes
2. Assess if they represent real mathematical gaps vs infrastructure
3. Accept F/P sorries as documented debt (they exist in current code already)

If Boneyard move breaks builds:
1. Revert moves
2. Keep deprecated banners instead
3. Add import guards or warnings

## Appendix: Domain Semantics Quick Reference

| Component | Type | Domain | Purpose |
|-----------|------|--------|---------|
| MCS | `Set Formula` | World states | Instantaneous semantic content |
| CanonicalMCS | Structure | World states | Proof-theoretic universe |
| Int | `Int` | Time indices | Discrete temporal position |
| FMCS D | `D -> MCS` | World history | Trajectory through state space |
| BFMCS D | `Set (FMCS D)` | Space of histories | Bundle for completeness proof |

**Key Insight**: `discreteMCS_modal_backward` works at MCS level because modal saturation is a property of the MCS SET (discreteClosedMCS), not the BFMCS families. The bridge construction lifts this to Int-indexed families by ensuring each family's MCS values stay within the saturated set.
