# Implementation Plan: Task #15 (v2)

- **Task**: 15 - discrete_representation_theorem_axiom_removal
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (abandons Task 14's singleton approach)
- **Research Inputs**:
  - specs/015_discrete_representation_theorem_axiom_removal/reports/03_team-research-synthesis.md
  - specs/015_discrete_representation_theorem_axiom_removal/reports/02_teammate-a-findings.md
  - specs/015_discrete_representation_theorem_axiom_removal/reports/02_teammate-b-findings.md
- **Artifacts**: plans/02_multi-bfmcs-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is plan v2, replacing the failed v1 singleton BFMCS approach. The singleton approach in `SuccChainBFMCS.lean` requires `phi -> Box(phi)` (converse of T-axiom) for `modal_backward`, which is mathematically impossible for contingent formulas in TM logic. The correct construction uses a **multi-family modally saturated BFMCS** where `modal_backward` is derived via contraposition using the sorry-free `saturated_modal_backward` theorem from `ModalSaturation.lean`.

### Research Integration

Key findings integrated into this plan:
- **Singleton BFMCS is impossible**: The `modal_backward` sorry requires `phi -> Box(phi)`, which is false for contingent formulas (Teammate A, Teammate B, confirmed in codebase)
- **Multi-family saturation works**: `saturated_modal_backward` is proven sorry-free using modal saturation property
- **Infrastructure exists**: `closedFlags`, `saturated_modal_backward`, `canonicalMCSBFMCS` are all sorry-free
- **Domain transfer is the challenge**: Moving from `CanonicalMCS` to `Int` domain requires careful handling
- **Temporal coherence constraint**: Constant witness families violate `forward_G`, requiring ChainFMCS or FMCSTransfer approach

### Supersedes

**Plan v1** (`01_discrete-rep-plan.md`) is **ABANDONED**. That plan implemented:
- `SingletonBFMCS` wrapping SuccChainFMCS as a singleton bundle
- `construct_bfmcs_impl` using the singleton wrapper

This approach failed because `modal_backward` for a singleton requires `phi in MCS -> Box(phi) in MCS`, which is the converse of the T-axiom and does not hold in TM logic.

## Goals & Non-Goals

**Goals**:
- Deprecate singleton BFMCS artifacts (`SuccChainBFMCS.lean`)
- Remove dependency on singleton `construct_bfmcs_impl` from `DiscreteInstantiation.lean`
- Build multi-family modally saturated BFMCS over CanonicalMCS domain
- Wire multi-family construction to `discrete_representation_conditional`
- Document the singleton dead end in ROAD_MAP.md
- Eliminate the `modal_backward` sorry without introducing new axioms

**Non-Goals**:
- Full F/P temporal coherence for Int domain (requires dovetailing infrastructure not yet built)
- Changing the parametric framework to use CanonicalMCS as D (large refactor)
- Eliminating all sorries in discrete representation (scope limited to modal_backward)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Temporal coherence for witness families fails | High | Medium | Use ChainFMCS (Flag-based families) which provide valid FMCS |
| Domain transfer from CanonicalMCS to Int introduces new sorries | High | Medium | Initially target CanonicalMCS domain; defer Int transfer |
| `closedFlags` construction not compatible with BFMCS interface | Medium | Low | Infrastructure already proven compatible in existing files |
| Modal saturation proof depends on unverified lemmas | High | Low | `saturated_modal_backward` is documented as sorry-free |

## Implementation Phases

### Phase 1: Deprecate Singleton Artifacts [COMPLETED]

**Goal**: Mark the singleton BFMCS approach as deprecated and decouple from DiscreteInstantiation.

**Tasks**:
- [ ] Add DEPRECATED banner to `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean` marking `SingletonBFMCS` and `construct_bfmcs_impl` as dead ends
- [ ] Remove `import Bimodal.Metalogic.Bundle.SuccChainBFMCS` from `DiscreteInstantiation.lean`
- [ ] Comment out or remove `discrete_representation_unconditional` (which depends on the sorry)
- [ ] Correct misleading "trivial modal coherence" comments in `SuccChainBFMCS.lean`
- [ ] Add dead end entry to ROAD_MAP.md documenting singleton BFMCS for discrete representation

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean` - Add DEPRECATED banner
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` - Remove import, comment out unconditional theorem
- `ROAD_MAP.md` - Add dead end entry

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.DiscreteInstantiation` succeeds without SuccChainBFMCS import
- `discrete_representation_conditional` still exists and compiles
- ROAD_MAP.md contains new dead end entry

---

### Phase 2: Multi-Family BFMCS over CanonicalMCS [COMPLETED]

**Goal**: Create a modally saturated multi-family BFMCS construction over the CanonicalMCS domain using existing sorry-free infrastructure.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/ModallyCoherentBFMCS.lean`
- [ ] Define `CanonicalModalBFMCS M0`: multi-family BFMCS over CanonicalMCS containing:
  - Base family: `canonicalMCSBFMCS` (sorry-free F/P/G/H from `CanonicalFMCS.lean`)
  - Witness families: derived from `closedFlags M0` providing modal witnesses
- [ ] Prove `CanonicalModalBFMCS_modally_saturated M0` using `closedFlags_union_modally_saturated`
- [ ] Derive `modal_forward` (trivial, T-axiom direction)
- [ ] Derive `modal_backward` by applying `saturated_modal_backward` with saturation proof

**Timing**: 2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/ModallyCoherentBFMCS.lean`

**Files to modify**:
- `Theories/Bimodal.lean` - Add import

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.ModallyCoherentBFMCS` succeeds
- `CanonicalModalBFMCS M0 : BFMCS CanonicalMCS` type checks
- `modal_backward` proof has NO sorry (uses `saturated_modal_backward`)

---

### Phase 3: Witness Family Temporal Coherence [COMPLETED]

**Goal**: Ensure witness families in the multi-family BFMCS satisfy temporal coherence, addressing the constraint that constant families are invalid.

**Tasks**:
- [ ] Analyze `ChainFMCS.lean` to understand Flag-based FMCS structure
- [ ] For each Flag in `closedFlags M0`, construct a temporally coherent FMCS using the Flag's chain structure
- [ ] Prove that Flag-based families satisfy `forward_G` and `backward_H` (leverages chain ordering)
- [ ] Integrate witness families into `CanonicalModalBFMCS` with temporal coherence proofs
- [ ] If ChainFMCS approach is insufficient, explore alternative: FMCSTransfer retract using `intChainMCS`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ModallyCoherentBFMCS.lean` - Add temporal coherence proofs

**Verification**:
- All families in `CanonicalModalBFMCS` satisfy `forward_F`, `backward_P`, `forward_G`, `backward_H`
- No new `sorry` introduced for temporal coherence
- `CanonicalModalBFMCS_temporally_coherent` theorem exists

---

### Phase 4: Wire to DiscreteInstantiation [PARTIAL]

**Goal**: Connect the multi-family BFMCS construction to DiscreteInstantiation to restore the unconditional discrete representation theorem.

**Tasks**:
- [ ] Determine domain compatibility: `discrete_representation_conditional` requires `BFMCS Int`, current construction is `BFMCS CanonicalMCS`
- [ ] **Option A**: If parametric framework can be generalized, modify `DiscreteInstantiation.lean` to accept `BFMCS CanonicalMCS`
- [ ] **Option B**: Use `FMCSTransfer` with `intChainMCS` retract to transfer families from CanonicalMCS to Int domain
- [ ] Implement `construct_bfmcs_impl_v2` using the chosen approach
- [ ] Restore `discrete_representation_unconditional` using the new construction
- [ ] Document remaining sorries (if any from F/P dovetailing)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` - Add import, new construct_bfmcs_impl_v2, restore unconditional theorem
- `Theories/Bimodal/Metalogic/Bundle/ModallyCoherentBFMCS.lean` - Export construct_bfmcs_impl_v2 if needed

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.DiscreteInstantiation` succeeds
- `discrete_representation_unconditional` type checks
- `#print axioms discrete_representation_unconditional` shows no `modal_backward` sorry (may still have F/P sorries from domain transfer)

---

### Phase 5: Documentation and Cleanup [COMPLETED]

**Goal**: Document the approach, clean up artifacts, and update project state.

**Tasks**:
- [ ] Update module docstrings in `ModallyCoherentBFMCS.lean` explaining the multi-family approach
- [ ] Add comprehensive axiom documentation to `DiscreteInstantiation.lean`:
  - List all remaining sorries/axioms
  - Explain why modal_backward is now sorry-free
  - Document F/P dovetailing gap if still present
- [ ] Update research report or create summary documenting lessons learned
- [ ] Verify `lake build` succeeds for entire project
- [ ] Confirm sorry count reduction via `#print axioms`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ModallyCoherentBFMCS.lean` - Docstrings
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` - Axiom documentation

**Verification**:
- `lake build` succeeds with no new errors
- Documentation accurately reflects current state
- Sorry count for `modal_backward` is 0

---

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] `discrete_representation_conditional` still compiles
- [ ] `discrete_representation_unconditional` compiles (if domain transfer completes)
- [ ] `#print axioms discrete_representation_unconditional` shows no `modal_backward` sorry
- [ ] `saturated_modal_backward` is used in `modal_backward` derivation (not a new sorry)
- [ ] ROAD_MAP.md dead end entry exists and is accurate
- [ ] `SuccChainBFMCS.lean` has DEPRECATED banner

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/ModallyCoherentBFMCS.lean` (new)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean` (modified - DEPRECATED banner)
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` (modified - decoupled from singleton, rewired to multi-family)
- `ROAD_MAP.md` (modified - dead end entry)
- `specs/015_discrete_representation_theorem_axiom_removal/plans/02_multi-bfmcs-plan.md` (this file)

## Rollback/Contingency

If multi-family construction fails:
1. Keep `discrete_representation_conditional` as the primary result (already sorry-free for its signature)
2. Preserve deprecation of singleton artifacts (that approach is definitively blocked)
3. Document blockers for multi-family approach in ROAD_MAP.md
4. Create follow-up task to resolve domain transfer issues

If temporal coherence for witness families cannot be proven:
1. Keep modal_backward derivation incomplete
2. Document that witness temporal coherence is the blocker (not modal saturation)
3. Explore CanonicalMCS-as-D parametric generalization as future work

If domain transfer introduces new sorries:
1. Accept F/P dovetailing sorries as documented semantic debt
2. Note that modal_backward is now sorry-free (the original goal)
3. Track F/P sorries separately for future elimination
